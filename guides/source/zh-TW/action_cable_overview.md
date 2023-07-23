**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4f7308fdab05dc13d399bde6a8ac302c
Action Cable 概述
=====================

在本指南中，您將學習 Action Cable 的工作原理以及如何使用 WebSockets 將實時功能整合到您的 Rails 應用程序中。

閱讀本指南後，您將了解以下內容：

* Action Cable 是什麼，以及它的後端和前端集成方式
* 如何設置 Action Cable
* 如何設置頻道
* 運行 Action Cable 的部署和架構設置

--------------------------------------------------------------------------------

什麼是 Action Cable？
---------------------

Action Cable 將 [WebSockets](https://en.wikipedia.org/wiki/WebSocket) 與您的 Rails 應用程序的其餘部分無縫集成在一起。它允許使用 Ruby 以與 Rails 應用程序的其餘部分相同的風格和形式編寫實時功能，同時保持高性能和可擴展性。它是一個全棧解決方案，提供了客戶端的 JavaScript 框架和服務器端的 Ruby 框架。您可以訪問使用 Active Record 或您選擇的 ORM 編寫的整個領域模型。

術語
-----------

Action Cable 使用 WebSockets 而不是 HTTP 請求-響應協議。Action Cable 和 WebSockets 都引入了一些不太熟悉的術語：

### 連接

*連接* 是客戶端和服務器端之間關係的基礎。一個 Action Cable 服務器可以處理多個連接實例。每個 WebSocket 連接對應一個連接實例。如果用戶在多個瀏覽器標籤或設備上使用您的應用程序，則一個用戶可能會對應多個 WebSocket 連接。

### 消費者

WebSocket 連接的客戶端稱為 *消費者*。在 Action Cable 中，消費者由客戶端的 JavaScript 框架創建。

### 頻道

每個消費者可以訂閱多個 *頻道*。每個頻道封裝了一個邏輯單元，類似於典型的 MVC 架構中的控制器。例如，您可以有一個 `ChatChannel` 和一個 `AppearancesChannel`，消費者可以訂閱這兩個頻道中的任何一個或兩個。至少，一個消費者應該訂閱一個頻道。

### 訂閱者

當消費者訂閱一個頻道時，它們充當 *訂閱者*。訂閱者和頻道之間的連接被稱為訂閱。一個消費者可以作為訂閱者多次訂閱同一個頻道。例如，一個消費者可以同時訂閱多個聊天室。（請記住，一個實際用戶可能會有多個消費者，每個消費者對應一個打開您的連接的標籤/設備）。

### 發布/訂閱

[發布/訂閱](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern) 是一種消息隊列範例，發送者（發布者）將數據發送給一個抽象類別的接收者（訂閱者），而不指定個別的接收者。Action Cable 使用這種方法在服務器和多個客戶端之間進行通信。
### 廣播

廣播是一種發布/訂閱連結，廣播者傳送的任何內容都會直接發送到正在串流該命名廣播的頻道訂閱者。每個頻道可以串流零個或多個廣播。

## 伺服器端元件

### 連線

對於伺服器接受的每個 WebSocket，都會實例化一個連線物件。從此之後，這個物件將成為所有*頻道訂閱*的父物件。連線本身不處理任何特定的應用邏輯，僅處理驗證和授權。WebSocket 連線的客戶端稱為連線*消費者*。每個使用者會為每個瀏覽器分頁、視窗或裝置建立一對消費者-連線。

連線是 `ApplicationCable::Connection` 的實例，它擴展了 [`ActionCable::Connection::Base`][]。在 `ApplicationCable::Connection` 中，您可以授權傳入的連線，並在可以識別使用者時建立連線。

#### 連線設定

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

在這個例子中，[`identified_by`][] 指定了一個連線識別碼，可以用來稍後找到特定的連線。請注意，任何標記為識別碼的內容都會自動在連線上創建一個同名的委派，以供從連線創建的所有頻道實例使用。

此範例假設您已經在應用程式的其他地方處理了使用者的驗證，並且成功的驗證會設置一個帶有使用者 ID 的加密 cookie。

當嘗試建立新連線時，該 cookie 會自動發送到連線實例，您可以使用它來設置 `current_user`。通過使用相同的當前使用者識別連線，您還確保您稍後可以檢索到特定使用者的所有開放連線（並在使用者被刪除或未經授權時可能斷開它們）。

如果您的驗證方法包括使用會話，並且您使用 cookie 存儲會話，您的會話 cookie 名稱為 `_session`，使用者 ID 鍵為 `user_id`，您可以使用以下方法：

```ruby
verified_user = User.find_by(id: cookies.encrypted['_session']['user_id'])
```

#### 例外處理

預設情況下，未處理的例外會被捕獲並記錄到 Rails 的記錄器中。如果您希望全局攔截這些例外並將它們報告給外部錯誤追蹤服務，您可以使用 [`rescue_from`][]：

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
#### 連線回呼

有 `before_command`、`after_command` 和 `around_command` 回呼可在每個客戶端接收到的指令之前、之後或周圍調用。

這裡的「指令」指的是客戶端接收到的任何互動（訂閱、取消訂閱或執行動作）：

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    around_command :set_current_account

    private
      def set_current_account(&block)
        # 現在所有的頻道都可以使用 Current.account
        Current.set(account: user.account, &block)
      end
  end
end
```

### 頻道

*頻道*封裝了一個邏輯單元，類似於典型的 MVC 架構中的控制器。預設情況下，Rails 會創建一個父 `ApplicationCable::Channel` 類（擴展 [`ActionCable::Channel::Base`][]）來封裝頻道之間的共享邏輯。

#### 父頻道設置

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

然後，您可以創建自己的頻道類。例如，您可以有一個 `ChatChannel` 和一個 `AppearanceChannel`：

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

然後，使用者可以訂閱這些頻道中的任意一個或全部。

#### 訂閱

使用者訂閱頻道，充當*訂閱者*。他們的連線被稱為*訂閱*。產生的訊息根據頻道使用者發送的識別符號路由到這些頻道訂閱。

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # 當使用者成功成為此頻道的訂閱者時調用
  def subscribed
  end
end
```

#### 例外處理

與 `ApplicationCable::Connection` 一樣，您也可以在特定頻道上使用 [`rescue_from`][] 處理引發的例外：

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

#### 頻道回呼

`ApplicationCable::Channel` 提供了一些回呼，可用於在頻道的生命週期中觸發邏輯。可用的回呼有：

- `before_subscribe`
- `after_subscribe`（也可以使用別名 `on_subscribe`）
- `before_unsubscribe`
- `after_unsubscribe`（也可以使用別名 `on_unsubscribe`）

注意：`after_subscribe` 回呼在 `subscribed` 方法被調用時觸發，即使使用 `reject` 方法拒絕訂閱。要僅在成功訂閱時觸發 `after_subscribe`，請使用 `after_subscribe :send_welcome_message, unless: :subscription_rejected?`

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

## 客戶端組件

### 連線

使用者在其端需要連線的實例。這可以使用以下 JavaScript 建立，Rails 默認生成：
#### 連接消費者

```js
// app/javascript/channels/consumer.js
// Action Cable 提供了處理 Rails 中的 WebSockets 的框架。
// 您可以使用 `bin/rails generate channel` 命令生成新的頻道，其中包含 WebSocket 功能。

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
```

這將準備一個消費者，預設情況下將連接到您的伺服器上的 `/cable`。
在您指定至少一個您有興趣訂閱的頻道之前，連接不會建立。

消費者可以選擇性地接受一個參數，該參數指定要連接的 URL。這可以是一個字符串或返回字符串的函數，當 WebSocket 打開時將調用該函數。

```js
// 指定連接到不同的 URL
createConsumer('wss://example.com/cable')
// 或在使用 HTTP 的 WebSockets 時
createConsumer('https://ws.example.com/cable')

// 使用函數動態生成 URL
createConsumer(getWebSocketURL)

function getWebSocketURL() {
  const token = localStorage.get('auth-token')
  return `wss://example.com/cable?token=${token}`
}
```

#### 訂閱者

通過創建對特定頻道的訂閱，消費者成為訂閱者：

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" })

// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AppearanceChannel" })
```

雖然這創建了訂閱，但對於接收到的數據做出回應所需的功能將在稍後描述。

消費者可以作為對特定頻道的訂閱者任意次數。例如，消費者可以同時訂閱多個聊天室：

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "1st Room" })
consumer.subscriptions.create({ channel: "ChatChannel", room: "2nd Room" })
```

## 客戶端-伺服器互動

### 流

*流* 提供了頻道將發布的內容（廣播）路由到其訂閱者的機制。例如，以下代碼使用 [`stream_from`][] 在 `:room` 參數的值為 `"Best Room"` 時訂閱名為 `chat_Best Room` 的廣播：

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

然後，在 Rails 應用程式的其他地方，您可以通過調用 [`broadcast`][] 將內容廣播到該聊天室：

```ruby
ActionCable.server.broadcast("chat_Best Room", { body: "This Room is Best Room." })
```

如果您有一個與模型相關的流，則廣播名稱可以從頻道和模型生成。例如，以下代碼使用 [`stream_for`][] 訂閱類似於 `posts:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE` 的廣播，其中 `Z2lkOi8vVGVzdEFwcC9Qb3N0LzE` 是帖子模型的 GlobalID。

```ruby
class PostsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```
您可以通过调用[`broadcast_to`][]来向该频道广播：

```ruby
PostsChannel.broadcast_to(@post, @comment)
```


### 广播

*广播*是一个发布/订阅链接，发布者传输的任何内容都会直接路由到正在流式传输该命名广播的频道订阅者。每个频道可以流式传输零个或多个广播。

广播纯粹是一个在线队列，且与时间有关。如果消费者没有流式传输（订阅给定频道），则稍后连接时将无法接收到广播。

### 订阅

当消费者订阅一个频道时，它们充当订阅者。这个连接被称为订阅。传入的消息会根据由Cable消费者发送的标识符路由到这些频道订阅。

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

### 将参数传递给频道

在创建订阅时，您可以将参数从客户端传递到服务器端。例如：

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

作为`subscriptions.create`的第一个参数传递的对象将成为Cable频道中的params哈希。关键字`channel`是必需的：

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
# 在您的应用程序中的某个地方调用此代码，可能是从NewCommentJob中调用。
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

重新广播将被所有连接的客户端接收，包括发送消息的客户端。请注意，params与您订阅频道时的参数相同。
## 全端示例

以下設置步驟適用於兩個示例：

  1. [設置連接](#connection-setup)。
  2. [設置父通道](#parent-channel-setup)。
  3. [連接消費者](#connect-consumer)。

### 示例1：使用者出現狀態

這是一個簡單的通道示例，用於追蹤使用者是否在線以及他們所在的頁面。（這對於創建顯示在使用者名稱旁邊的綠點表示其在線的功能非常有用）。

創建服務器端的出現狀態通道：

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

當訂閱被初始化時，`subscribed` 回調函數被觸發，我們利用這個機會來說明 "當前用戶確實出現了"。出現/消失的 API 可以由 Redis、數據庫或其他任何方式支持。

創建客戶端的出現狀態通道訂閱：

```js
// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("AppearanceChannel", {
  // 訂閱創建時調用一次。
  initialized() {
    this.update = this.update.bind(this)
  },

  // 連接準備就緒時調用。
  connected() {
    this.install()
    this.update()
  },

  // WebSocket 連接關閉時調用。
  disconnected() {
    this.uninstall()
  },

  // 訂閱被服務器拒絕時調用。
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // 在服務器上調用 `AppearanceChannel#appear(data)`。
    this.perform("appear", { appearing_on: this.appearingOn })
  },

  away() {
    // 在服務器上調用 `AppearanceChannel#away`。
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

#### 客戶端-服務器交互

1. **客戶端** 通過 `createConsumer()` 方法連接到 **服務器**。(**consumer.js**)。
   **服務器** 通過 `current_user` 來識別此連接。

2. **客戶端** 通過 `consumer.subscriptions.create({ channel: "AppearanceChannel" })` 訂閱出現狀態通道。(**appearance_channel.js**)

3. **服務器** 識別出已經初始化了一個新的出現狀態通道訂閱，並運行其 `subscribed` 回調函數，調用 `current_user` 的 `appear` 方法。(**appearance_channel.rb**)

4. **客戶端** 識別出訂閱已經建立，並調用 `connected`（**appearance_channel.js**），這將調用 `install` 和 `appear`。`appear` 在服務器上調用 `AppearanceChannel#appear(data)`，並提供數據哈希 `{ appearing_on: this.appearingOn }`。這是可能的，因為服務器端的通道實例自動公開了類中聲明的所有公共方法（回調函數除外），以便可以通過訂閱的 `perform` 方法作為遠程過程調用來訪問這些方法。
5. **伺服器**接收到對於由`current_user`識別的連接的外觀通道上的`appear`操作的請求（`appearance_channel.rb`）。**伺服器**從數據哈希中檢索帶有`:appearing_on`鍵的數據，並將其設置為傳遞給`current_user.appear`的`:on`鍵的值。

### 示例2：接收新的網絡通知

外觀示例是關於將伺服器功能暴露給客戶端通過WebSocket連接調用的。但是WebSocket的優點是它是雙向的。所以現在，讓我們展示一個伺服器在客戶端上調用操作的示例。

這是一個網絡通知通道，允許您在廣播到相關流時觸發客戶端的網絡通知：

創建伺服器端的網絡通知通道：

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

創建客戶端的網絡通知通道訂閱：

```js
// app/javascript/channels/web_notifications_channel.js
// 客戶端假設您已經請求了發送網絡通知的權限。
import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  received(data) {
    new Notification(data["title"], { body: data["body"] })
  }
})
```

從應用程序的其他地方向網絡通知通道實例廣播內容：

```ruby
# 在應用程序的某個地方調用此方法，可能是從NewCommentJob中
WebNotificationsChannel.broadcast_to(
  current_user,
  title: '新事物！',
  body: '所有適合打印的新聞'
)
```

`WebNotificationsChannel.broadcast_to`調用將一條消息放入當前訂閱適配器的發布訂閱隊列中，每個用戶都有一個單獨的廣播名稱。對於ID為1的用戶，廣播名稱將是`web_notifications:1`。

通道已被指示將到達`web_notifications:1`的所有內容直接通過調用`received`回調函數傳遞給客戶端。作為參數傳遞的數據是作為第二個參數發送到伺服器端廣播調用的哈希，經過JSON編碼後在傳輸過程中解包為到達的數據參數。

### 更完整的示例

請參閱[rails/actioncable-examples](https://github.com/rails/actioncable-examples)存儲庫，了解如何在Rails應用程序中設置Action Cable並添加通道的完整示例。

## 配置

Action Cable有兩個必需的配置：訂閱適配器和允許的請求來源。

### 訂閱適配器

默認情況下，Action Cable在`config/cable.yml`中查找配置文件。該文件必須為每個Rails環境指定一個適配器。有關適配器的其他信息，請參閱[依賴項](#dependencies)部分。

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

#### 適配器配置
以下是可供最終用戶使用的訂閱適配器列表。

##### Async Adapter

Async適配器適用於開發/測試，不應在生產環境中使用。

##### Redis Adapter

Redis適配器要求用戶提供指向Redis服務器的URL。
此外，可以提供“channel_prefix”以避免在多個應用程序使用同一個Redis服務器時出現通道名稱衝突。有關詳細信息，請參閱[Redis Pub/Sub文檔](https://redis.io/docs/manual/pubsub/#database--scoping)。

Redis適配器還支持SSL/TLS連接。必需的SSL/TLS參數可以在配置YAML文件中的“ssl_params”鍵中傳遞。

```
production:
  adapter: redis
  url: rediss://10.10.3.153:tls_port
  channel_prefix: appname_production
  ssl_params: {
    ca_file: "/path/to/ca.crt"
  }
```

傳遞給“ssl_params”的選項將直接傳遞給“OpenSSL::SSL::SSLContext#set_params”方法，可以是SSL上下文的任何有效屬性。有關其他可用屬性，請參閱[OpenSSL::SSL::SSLContext文檔](https://docs.ruby-lang.org/en/master/OpenSSL/SSL/SSLContext.html)。

如果您在防火牆後面使用自簽名證書作為Redis適配器並選擇跳過證書檢查，則ssl“verify_mode”應設置為“OpenSSL::SSL::VERIFY_NONE”。

警告：除非您完全了解安全性影響，否則不建議在生產環境中使用“VERIFY_NONE”。為了為Redis適配器設置此選項，配置應為“ssl_params: { verify_mode: <%= OpenSSL::SSL::VERIFY_NONE %> }”。

##### PostgreSQL Adapter

PostgreSQL適配器使用Active Record的連接池，因此使用應用程序的“config/database.yml”數據庫配置進行連接。這可能會在將來更改。[#27214](https://github.com/rails/rails/issues/27214)

### 允許的請求來源

Action Cable只接受來自指定來源的請求，這些來源以數組的形式傳遞給服務器配置。這些來源可以是字符串實例或正則表達式，將對其進行匹配檢查。

```ruby
config.action_cable.allowed_request_origins = ['https://rubyonrails.com', %r{http://ruby.*}]
```

要禁用並允許來自任何來源的請求：

```ruby
config.action_cable.disable_request_forgery_protection = true
```

默認情況下，Action Cable在開發環境中運行時允許從localhost:3000接受所有請求。

### 消費者配置

要配置URL，在HTML佈局的HEAD中添加一個[`action_cable_meta_tag`][]調用。這使用通常在環境配置文件中通過[`config.action_cable.url`][]設置的URL或路徑。

### 工作池配置

工作池用於在與服務器的主線程隔離的環境中運行連接回調和通道操作。Action Cable允許應用程序配置工作池中同時處理的線程數量。

```ruby
config.action_cable.worker_pool_size = 4
```

還要注意，您的服務器必須提供至少與工作程序數量相同的數據庫連接。默認的工作池大小設置為4，這意味著您必須提供至少4個數據庫連接。您可以通過`config/database.yml`中的“pool”屬性進行更改。
### 客戶端日誌記錄

默認情況下，客戶端日誌記錄是禁用的。您可以通過將 `ActionCable.logger.enabled` 設置為 true 來啟用它。

```ruby
import * as ActionCable from '@rails/actioncable'

ActionCable.logger.enabled = true
```

### 其他配置

另一個常見的配置選項是應用於每個連接記錄器的日誌標籤。以下是一個示例，如果可用，使用用戶帳戶 ID，否則使用 "no-account" 作為標籤：

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

有關所有配置選項的完整列表，請參見 `ActionCable::Server::Configuration` 類。

## 單獨運行 Cable 服務器

Action Cable 可以作為 Rails 應用程序的一部分運行，也可以作為獨立服務器運行。在開發中，作為 Rails 應用程序的一部分運行通常是可以的，但在生產環境中，應該將其作為獨立服務器運行。

### 在應用程序中

Action Cable 可以與 Rails 應用程序並行運行。例如，要在 `/websocket` 上監聽 WebSocket 請求，請將該路徑指定給 [`config.action_cable.mount_path`][]：

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

如果在佈局中調用了 [`action_cable_meta_tag`][]，則可以使用 `ActionCable.createConsumer()` 來連接到 cable 服務器。否則，可以將路徑作為 `createConsumer` 的第一個參數指定（例如 `ActionCable.createConsumer("/websocket")`）。

對於您創建的每個服務器實例，以及您的服務器生成的每個 worker，您還將擁有一個新的 Action Cable 實例，但是 Redis 或 PostgreSQL 适配器會在連接之間同步消息。

### 獨立運行

cable 服務器可以與正常的應用程序服務器分開。它仍然是一個 Rack 應用程序，但它是自己的 Rack 應用程序。建議的基本設置如下：

```ruby
# cable/config.ru
require_relative "../config/environment"
Rails.application.eager_load!

run ActionCable.server
```

然後啟動服務器：

```
bundle exec puma -p 28080 cable/config.ru
```

這將在端口 28080 上啟動一個 cable 服務器。要告訴 Rails 使用此服務器，請更新您的配置：

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_cable.mount_path = nil
  config.action_cable.url = "ws://localhost:28080" # 在生產環境中使用 wss://
end
```

最後，確保您已正確[配置了 consumer](#consumer-configuration)。

### 注意事項

WebSocket 服務器無法訪問會話，但可以訪問 cookie。這在需要處理身份驗證時可以使用。您可以在這篇[文章](https://greg.molnar.io/blog/actioncable-devise-authentication/)中看到使用 Devise 的一種方法。

## 依賴項

Action Cable 提供了一個訂閱适配器接口來處理其發布-訂閱內部。默認情況下，它包括異步、內嵌、PostgreSQL 和 Redis 适配器。新的 Rails 應用程序的默認适配器是異步（`async`）适配器。
在Ruby方面，我們使用[websocket-driver](https://github.com/faye/websocket-driver-ruby)、[nio4r](https://github.com/celluloid/nio4r)和[concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby)來構建。

## 部署

Action Cable使用WebSockets和線程的組合來運作。框架的內部處理和用戶指定的通道工作都是通過利用Ruby的本地線程支持來完成的。這意味著只要你沒有犯下任何線程安全的錯誤，你就可以使用所有現有的Rails模型。

Action Cable服務器實現了Rack socket hijacking API，這樣無論應用程序服務器是否支持多線程，都可以內部使用多線程模式來管理連接。

因此，Action Cable可以與像Unicorn、Puma和Passenger這樣的流行服務器一起使用。

## 測試

你可以在[測試指南](testing.html#testing-action-cable)中找到關於如何測試Action Cable功能的詳細說明。
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
