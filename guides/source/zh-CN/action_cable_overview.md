**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4f7308fdab05dc13d399bde6a8ac302c
Action Cable 概述
=====================

在本指南中，您将学习 Action Cable 的工作原理以及如何使用 WebSockets 将实时功能集成到您的 Rails 应用程序中。

阅读本指南后，您将了解以下内容：

* Action Cable 是什么以及其后端和前端集成
* 如何设置 Action Cable
* 如何设置频道
* 运行 Action Cable 的部署和架构设置

--------------------------------------------------------------------------------

什么是 Action Cable？
---------------------

Action Cable 无缝集成了 [WebSockets](https://en.wikipedia.org/wiki/WebSocket) 与您的 Rails 应用程序的其余部分。它允许以与您的 Rails 应用程序的其余部分相同的风格和形式使用 Ruby 编写实时功能，同时仍然具有高性能和可扩展性。它是一个全栈解决方案，提供了客户端 JavaScript 框架和服务器端 Ruby 框架。您可以访问使用 Active Record 或您选择的 ORM 编写的整个领域模型。

术语
-----------

Action Cable 使用 WebSockets 而不是 HTTP 请求-响应协议。Action Cable 和 WebSockets 都引入了一些不太熟悉的术语：

### 连接

*连接* 构成了客户端和服务器之间的基础关系。一个 Action Cable 服务器可以处理多个连接实例。它每个 WebSocket 连接有一个连接实例。如果用户在应用程序中使用多个浏览器选项卡或设备，那么一个用户可能会打开多个 WebSocket 连接。

### 消费者

WebSocket 连接的客户端称为 *消费者*。在 Action Cable 中，消费者是由客户端的 JavaScript 框架创建的。

### 频道

每个消费者可以订阅多个 *频道*。每个频道封装了一个逻辑工作单元，类似于典型的 MVC 设置中的控制器。例如，您可以有一个 `ChatChannel` 和一个 `AppearancesChannel`，消费者可以订阅其中一个或两个频道。至少，一个消费者应该订阅一个频道。

### 订阅者

当消费者订阅一个频道时，它们充当 *订阅者*。订阅者和频道之间的连接被称为订阅。一个消费者可以作为给定频道的订阅者任意次数。例如，一个消费者可以同时订阅多个聊天室。（请记住，一个物理用户可能有多个消费者，每个消费者对应一个打开到您的连接的选项卡/设备）。

### 发布/订阅

[发布/订阅](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern) 是一种消息队列范例，发送者（发布者）将数据发送给接收者（订阅者）的抽象类，而不指定个别接收者。Action Cable 使用这种方法在服务器和多个客户端之间进行通信。

### 广播

广播是一个发布/订阅链接，广播者发送的任何内容都直接发送给正在流式传输该命名广播的频道订阅者。每个频道可以流式传输零个或多个广播。

## 服务器端组件

### 连接

对于服务器接受的每个 WebSocket，都会实例化一个连接对象。该对象成为从此处创建的所有 *频道订阅* 的父级。连接本身不处理任何特定的应用程序逻辑，只处理身份验证和授权。WebSocket 连接的客户端称为连接的 *消费者*。每个用户将为其在浏览器选项卡、窗口或设备上打开的每个选项卡、窗口或设备创建一个消费者-连接对。

连接是 `ApplicationCable::Connection` 的实例，它扩展了 [`ActionCable::Connection::Base`][]。在 `ApplicationCable::Connection` 中，您可以对传入的连接进行授权，并在可以识别用户时继续建立连接。

#### 连接设置

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if verified_user = User.find_by(id: cookies.encrypted[:user_id])
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

在这个例子中，[`identified_by`][] 指定了一个连接标识符，可以用来在以后找到特定的连接。请注意，任何标记为标识符的内容都会自动在从连接创建的任何频道实例上创建一个同名的委托。

这个示例依赖于您已经在应用程序的其他地方处理了用户的身份验证，并且成功的身份验证会设置一个带有用户 ID 的加密 cookie。

当尝试建立新连接时，cookie 会自动发送到连接实例，您可以使用它来设置 `current_user`。通过使用相同的当前用户标识连接，您还确保可以稍后检索给定用户的所有打开连接（并在用户被删除或未经授权时可能断开所有连接）。
如果您的身份验证方法包括使用会话，您可以使用cookie存储会话，会话cookie的名称为`_session`，用户ID键为`user_id`，您可以使用以下方法：

```ruby
verified_user = User.find_by(id: cookies.encrypted['_session']['user_id'])
```


#### 异常处理

默认情况下，未处理的异常会被捕获并记录到Rails的日志记录器中。如果您希望全局拦截这些异常并将它们报告给外部错误跟踪服务，例如，您可以使用[`rescue_from`][]来实现：

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    rescue_from StandardError, with: :report_error

    private
      def report_error(e)
        SomeExternalBugtrackingService.notify(e)
      end
  end
end
```


#### 连接回调

在每个客户端接收到的命令之前、之后或周围调用的`before_command`、`after_command`和`around_command`回调可用于调用。这里的“命令”一词指的是客户端接收到的任何交互（订阅、取消订阅或执行操作）：

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    around_command :set_current_account

    private
      def set_current_account(&block)
        # 现在所有的频道都可以使用Current.account
        Current.set(account: user.account, &block)
      end
  end
end
```

### 频道

*频道*封装了一个逻辑工作单元，类似于典型的MVC设置中的控制器所做的工作。默认情况下，Rails创建一个父级`ApplicationCable::Channel`类（扩展[`ActionCable::Channel::Base`][]），用于封装频道之间的共享逻辑。

#### 父频道设置

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

然后，您可以创建自己的频道类。例如，您可以有一个`ChatChannel`和一个`AppearanceChannel`：

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
end
```

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
end
```


然后，消费者可以订阅这些频道中的任意一个或全部。

#### 订阅

消费者订阅频道，充当*订阅者*。他们的连接被称为*订阅*。生成的消息将根据频道消费者发送的标识符路由到这些频道订阅。

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # 当消费者成功成为此频道的订阅者时调用
  def subscribed
  end
end
```

#### 异常处理

与`ApplicationCable::Connection`一样，您也可以在特定频道上使用[`rescue_from`][]来处理引发的异常：

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  private
    def deliver_error_message(e)
      broadcast_to(...)
    end
end
```

#### 频道回调

`ApplicationCable::Channel`提供了一些回调函数，可以在频道的生命周期中触发逻辑。可用的回调函数有：

- `before_subscribe`
- `after_subscribe`（也可以使用别名：`on_subscribe`）
- `before_unsubscribe`
- `after_unsubscribe`（也可以使用别名：`on_unsubscribe`）

注意：无论使用`reject`方法拒绝订阅与否，`after_subscribe`回调都会在调用`subscribed`方法时触发。要仅在成功订阅时触发`after_subscribe`，请使用`after_subscribe :send_welcome_message, unless: :subscription_rejected?`

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  after_subscribe :send_welcome_message, unless: :subscription_rejected?
  after_subscribe :track_subscription

  private
    def send_welcome_message
      broadcast_to(...)
    end

    def track_subscription
      # ...
    end
end
```

## 客户端组件

### 连接

消费者在其端需要一个连接实例。这可以通过以下JavaScript来建立，这是Rails默认生成的：

#### 连接消费者

```js
// app/javascript/channels/consumer.js
// Action Cable提供了处理Rails中的WebSockets的框架。
// 您可以使用`bin/rails generate channel`命令生成WebSocket功能所在的新频道。

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
```

这将准备一个消费者，默认情况下将连接到服务器上的`/cable`。在您指定至少一个您感兴趣的订阅之前，连接不会建立。

消费者可以选择接受一个参数，该参数指定要连接的URL。这可以是字符串或返回字符串的函数，在WebSocket打开时将调用该函数。

```js
// 指定要连接的不同URL
createConsumer('wss://example.com/cable')
// 或在使用HTTP的情况下使用WebSockets时
createConsumer('https://ws.example.com/cable')

// 使用函数动态生成URL
createConsumer(getWebSocketURL)

function getWebSocketURL() {
  const token = localStorage.get('auth-token')
  return `wss://example.com/cable?token=${token}`
}
```

#### 订阅者

通过创建对给定频道的订阅，消费者成为订阅者：

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" })

// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AppearanceChannel" })
```

虽然这样创建了订阅，但需要在后面的描述中描述接收到的数据的功能。
一个消费者可以任意次数订阅给定频道。例如，一个消费者可以同时订阅多个聊天室：

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "1st Room" })
consumer.subscriptions.create({ channel: "ChatChannel", room: "2nd Room" })
```

## 客户端-服务器交互

### 流

*流* 提供了频道将发布的内容（广播）路由到其订阅者的机制。例如，以下代码使用 [`stream_from`][] 来订阅名为 `chat_Best Room` 的广播，当 `:room` 参数的值为 `"Best Room"` 时：

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

然后，在你的 Rails 应用的其他地方，你可以通过调用 [`broadcast`][] 来广播到这个房间：

```ruby
ActionCable.server.broadcast("chat_Best Room", { body: "This Room is Best Room." })
```

如果你有一个与模型相关的流，那么广播名称可以从频道和模型生成。例如，以下代码使用 [`stream_for`][] 来订阅类似 `posts:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE` 的广播，其中 `Z2lkOi8vVGVzdEFwcC9Qb3N0LzE` 是 Post 模型的 GlobalID。

```ruby
class PostsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

然后，你可以通过调用 [`broadcast_to`][] 来广播到这个频道：

```ruby
PostsChannel.broadcast_to(@post, @comment)
```


### 广播

*广播* 是一个发布/订阅链接，发布者发送的任何内容都会直接路由到正在流式传输该命名广播的频道订阅者。每个频道可以流式传输零个或多个广播。

广播纯粹是一个在线队列，且与时间相关。如果消费者没有流式传输（订阅给定频道），则他们在以后连接时将无法接收到广播。

### 订阅

当消费者订阅一个频道时，他们充当订阅者。这个连接被称为订阅。传入的消息将根据由 Cable 消费者发送的标识符路由到这些频道订阅。

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

### 向频道传递参数

在创建订阅时，你可以将参数从客户端传递到服务器端。例如：

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

作为 `subscriptions.create` 的第一个参数传递的对象将成为 Cable 频道中的 params 哈希。关键字 `channel` 是必需的：

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

```ruby
# 在你的应用的某个地方调用这个，也许是从 NewCommentJob 中调用。
ActionCable.server.broadcast(
  "chat_#{room}",
  {
    sent_by: 'Paul',
    body: 'This is a cool chat app.'
  }
)
```

### 重新广播消息

一个常见的用例是将一个客户端发送的消息*重新广播*给其他连接的客户端。

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def receive(data)
    ActionCable.server.broadcast("chat_#{params[:room]}", data)
  end
end
```

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    // data => { sent_by: "Paul", body: "This is a cool chat app." }
  }
}

chatChannel.send({ sent_by: "Paul", body: "This is a cool chat app." })
```

重新广播将被所有连接的客户端接收到，包括发送消息的客户端。注意，params 与你订阅频道时的参数相同。

## 全栈示例

以下设置步骤对两个示例都是通用的：

  1. [设置你的连接](#connection-setup)。
  2. [设置你的父频道](#parent-channel-setup)。
  3. [连接你的消费者](#connect-consumer)。

### 示例 1：用户出现

这是一个简单的示例，展示了一个跟踪用户是否在线以及他们所在页面的频道。（这对于创建在线状态功能很有用，比如在用户名旁边显示一个绿点表示他们在线）。

创建服务器端的出现频道：

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    current_user.appear
  end

  def unsubscribed
    current_user.disappear
  end

  def appear(data)
    current_user.appear(on: data['appearing_on'])
  end

  def away
    current_user.away
  end
end
```
当订阅被初始化时，将触发`subscribed`回调函数，我们利用这个机会来说“当前用户确实已出现”。出现/消失的API可以由Redis、数据库或其他任何方式支持。

创建客户端的出现频道订阅：

```js
// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("AppearanceChannel", {
  // 订阅创建时调用一次。
  initialized() {
    this.update = this.update.bind(this)
  },

  // 订阅准备好在服务器上使用时调用。
  connected() {
    this.install()
    this.update()
  },

  // WebSocket连接关闭时调用。
  disconnected() {
    this.uninstall()
  },

  // 服务器拒绝订阅时调用。
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // 在服务器上调用`AppearanceChannel#appear(data)`。
    this.perform("appear", { appearing_on: this.appearingOn })
  },

  away() {
    // 在服务器上调用`AppearanceChannel#away`。
    this.perform("away")
  },

  install() {
    window.addEventListener("focus", this.update)
    window.addEventListener("blur", this.update)
    document.addEventListener("turbo:load", this.update)
    document.addEventListener("visibilitychange", this.update)
  },

  uninstall() {
    window.removeEventListener("focus", this.update)
    window.removeEventListener("blur", this.update)
    document.removeEventListener("turbo:load", this.update)
    document.removeEventListener("visibilitychange", this.update)
  },

  get documentIsActive() {
    return document.visibilityState === "visible" && document.hasFocus()
  },

  get appearingOn() {
    const element = document.querySelector("[data-appearing-on]")
    return element ? element.getAttribute("data-appearing-on") : null
  }
})
```

#### 客户端-服务器交互

1. **客户端**通过`createConsumer()`连接到**服务器**。(`consumer.js`)。
   **服务器**通过`current_user`标识此连接。

2. **客户端**通过`consumer.subscriptions.create({ channel: "AppearanceChannel" })`订阅出现频道。(`appearance_channel.js`)

3. **服务器**识别出现频道的新订阅已被初始化，并运行其`subscribed`回调函数，调用`current_user`的`appear`方法。(`appearance_channel.rb`)

4. **客户端**识别出已建立订阅，并调用`connected`(`appearance_channel.js`)，它又调用`install`和`appear`。
   `appear`在服务器上调用`AppearanceChannel#appear(data)`，并提供一个数据哈希`{ appearing_on: this.appearingOn }`。
   这是可能的，因为服务器端的频道实例自动公开类上声明的所有公共方法（回调除外），以便可以通过订阅的`perform`方法作为远程过程调用来访问这些方法。

5. **服务器**接收到出现频道上的`appear`操作的请求，该请求针对由`current_user`标识的连接(`appearance_channel.rb`)。
   **服务器**从数据哈希中检索带有`:appearing_on`键的数据，并将其设置为传递给`current_user.appear`的`on`键的值。

### 示例2：接收新的Web通知

出现示例是关于将服务器功能公开给客户端通过WebSocket连接调用的。但是WebSocket的好处在于它是双向的。因此，现在，让我们展示一个服务器调用客户端操作的示例。

这是一个Web通知频道，允许您在广播到相关流时触发客户端的Web通知：

创建服务器端的Web通知频道：

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

创建客户端的Web通知频道订阅：

```js
// app/javascript/channels/web_notifications_channel.js
// 客户端假设您已经请求了发送Web通知的权限。
import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  received(data) {
    new Notification(data["title"], { body: data["body"] })
  }
})
```

从应用程序的其他位置向Web通知频道实例广播内容：

```ruby
# 在应用程序的某个地方调用此函数，可能是从NewCommentJob中调用的
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'New things!',
  body: 'All the news fit to print'
)
```

`WebNotificationsChannel.broadcast_to`调用将消息放置在当前订阅适配器的发布/订阅队列中，每个用户都有一个单独的广播名称。
对于ID为1的用户，广播名称将是`web_notifications:1`。

该频道已被指示将到达`web_notifications:1`的所有内容直接传递给客户端，通过调用`received`回调函数。
作为参数传递的数据是作为服务器端广播调用的第二个参数发送的哈希，经过JSON编码后通过网络传输，并解包为作为`received`到达的数据参数。

### 更完整的示例

请参阅[rails/actioncable-examples](https://github.com/rails/actioncable-examples)存储库，了解如何在Rails应用程序中设置Action Cable并添加频道的完整示例。

## 配置

Action Cable有两个必需的配置项：订阅适配器和允许的请求来源。

### 订阅适配器

默认情况下，Action Cable在`config/cable.yml`中查找配置文件。
该文件必须为每个Rails环境指定一个适配器。有关适配器的其他信息，请参见[Dependencies](#dependencies)部分。

```yaml
development:
  adapter: async

test:
  adapter: test

production:
  adapter: redis
  url: redis://10.10.3.153:6381
  channel_prefix: appname_production
```
#### 适配器配置

以下是可用于终端用户的订阅适配器列表。

##### 异步适配器

异步适配器用于开发/测试，不应在生产环境中使用。

##### Redis适配器

Redis适配器要求用户提供指向Redis服务器的URL。此外，可以提供`channel_prefix`以避免在多个应用程序使用相同的Redis服务器时发生通道名称冲突。有关更多详细信息，请参阅[Redis Pub/Sub文档](https://redis.io/docs/manual/pubsub/#database--scoping)。

Redis适配器还支持SSL/TLS连接。所需的SSL/TLS参数可以通过配置YAML文件中的`ssl_params`键传递。

```
production:
  adapter: redis
  url: rediss://10.10.3.153:tls_port
  channel_prefix: appname_production
  ssl_params: {
    ca_file: "/path/to/ca.crt"
  }
```

传递给`ssl_params`的选项将直接传递给`OpenSSL::SSL::SSLContext#set_params`方法，并且可以是SSL上下文的任何有效属性。有关其他可用属性，请参阅[OpenSSL::SSL::SSLContext文档](https://docs.ruby-lang.org/en/master/OpenSSL/SSL/SSLContext.html)。

如果您在防火墙后面为Redis适配器使用自签名证书并选择跳过证书检查，则ssl `verify_mode`应设置为`OpenSSL::SSL::VERIFY_NONE`。

警告：除非您完全了解安全性影响，否则不建议在生产环境中使用`VERIFY_NONE`。为了为Redis适配器设置此选项，配置应为`ssl_params: { verify_mode: <%= OpenSSL::SSL::VERIFY_NONE %> }`。

##### PostgreSQL适配器

PostgreSQL适配器使用Active Record的连接池，因此应用程序的`config/database.yml`数据库配置用于其连接。这可能会在将来发生变化。[#27214](https://github.com/rails/rails/issues/27214)

### 允许的请求来源

Action Cable仅接受来自指定来源的请求，这些来源作为数组传递给服务器配置。这些来源可以是字符串实例或正则表达式，将对其进行匹配检查。

```ruby
config.action_cable.allowed_request_origins = ['https://rubyonrails.com', %r{http://ruby.*}]
```

要禁用并允许来自任何来源的请求：

```ruby
config.action_cable.disable_request_forgery_protection = true
```

默认情况下，在开发环境中运行时，Action Cable允许来自localhost:3000的所有请求。

### 消费者配置

要配置URL，请在HTML布局的HEAD中添加对[`action_cable_meta_tag`][]的调用。这通常使用通过环境配置文件中的[`config.action_cable.url`][]设置的URL或路径。

### 工作池配置

工作池用于在与服务器的主线程隔离的环境中运行连接回调和通道操作。Action Cable允许应用程序配置工作池中同时处理的线程数。

```ruby
config.action_cable.worker_pool_size = 4
```

还要注意，您的服务器必须提供至少与您的工作器数量相同的数据库连接。默认的工作池大小设置为4，这意味着您必须至少提供4个数据库连接。您可以通过`config/database.yml`中的`pool`属性更改此设置。

### 客户端日志记录

默认情况下，禁用客户端日志记录。您可以通过将`ActionCable.logger.enabled`设置为true来启用此功能。

```ruby
import * as ActionCable from '@rails/actioncable'

ActionCable.logger.enabled = true
```

### 其他配置

配置的另一个常见选项是应用于每个连接记录器的日志标签。以下是一个示例，如果可用，则使用用户帐户ID，否则使用"no-account"作为标签：

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

有关所有配置选项的完整列表，请参阅`ActionCable::Server::Configuration`类。

## 运行独立的Cable服务器

Action Cable可以作为Rails应用程序的一部分运行，也可以作为独立服务器运行。在开发中，作为Rails应用程序的一部分运行通常是可以的，但在生产中，应该将其作为独立服务器运行。

### 在应用程序中

Action Cable可以与您的Rails应用程序一起运行。例如，要监听`/websocket`上的WebSocket请求，请将该路径指定给[`config.action_cable.mount_path`][]：

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

如果在布局中调用了[`action_cable_meta_tag`][]，则可以使用`ActionCable.createConsumer()`连接到cable服务器。否则，可以将路径作为`createConsumer`的第一个参数指定（例如`ActionCable.createConsumer("/websocket")`）。

对于您创建的每个服务器实例和您的服务器生成的每个工作器，您还将拥有一个新的Action Cable实例，但是Redis或PostgreSQL适配器会在连接之间同步消息。

### 独立运行

Cable服务器可以与您的常规应用程序服务器分离。它仍然是一个Rack应用程序，但它是自己的Rack应用程序。推荐的基本设置如下：
```ruby
# cable/config.ru
require_relative "../config/environment"
Rails.application.eager_load!

run ActionCable.server
```

然后启动服务器：

```
bundle exec puma -p 28080 cable/config.ru
```

这将在端口28080上启动一个cable服务器。要告诉Rails使用这个服务器，更新你的配置：

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_cable.mount_path = nil
  config.action_cable.url = "ws://localhost:28080" # 在生产环境中使用wss://
end
```

最后，确保你已经[正确配置了消费者](#consumer-configuration)。

### 注意

WebSocket服务器无法访问会话，但可以访问cookie。这在需要处理身份验证时可以使用。你可以在这篇[文章](https://greg.molnar.io/blog/actioncable-devise-authentication/)中看到使用Devise的一种方法。

## 依赖

Action Cable提供了一个订阅适配器接口来处理其发布订阅内部。默认情况下，包括异步、内联、PostgreSQL和Redis适配器。新的Rails应用程序的默认适配器是异步(`async`)适配器。

Ruby方面的工作是基于[websocket-driver](https://github.com/faye/websocket-driver-ruby)、[nio4r](https://github.com/celluloid/nio4r)和[concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby)构建的。

## 部署

Action Cable使用WebSockets和线程的组合来实现。框架的基础设施和用户指定的通道工作都是通过利用Ruby的本地线程支持来处理的。这意味着你可以毫无问题地使用所有现有的Rails模型，只要你没有犯任何线程安全的错误。

Action Cable服务器实现了Rack套接字劫持API，从而允许使用多线程模式来管理连接，无论应用程序服务器是否支持多线程。

因此，Action Cable可以与像Unicorn、Puma和Passenger这样的流行服务器一起使用。

## 测试

你可以在[测试指南](testing.html#testing-action-cable)中找到有关如何测试Action Cable功能的详细说明。
[`ActionCable::Connection::Base`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Base.html
[`identified_by`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Identification/ClassMethods.html#method-i-identified_by
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`ActionCable::Channel::Base`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html
[`broadcast`]: https://api.rubyonrails.org/classes/ActionCable/Server/Broadcasting.html#method-i-broadcast
[`broadcast_to`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Broadcasting/ClassMethods.html#method-i-broadcast_to
[`stream_for`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_for
[`stream_from`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_from
[`config.action_cable.url`]: configuring.html#config-action-cable-url
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
[`config.action_cable.mount_path`]: configuring.html#config-action-cable-mount-path
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
