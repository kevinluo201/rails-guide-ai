**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4f7308fdab05dc13d399bde6a8ac302c
Action Cable 개요
=====================

이 가이드에서는 Action Cable이 작동하는 방식과 웹 소켓을 사용하여 실시간 기능을 Rails 애플리케이션에 통합하는 방법을 배우게 됩니다.

이 가이드를 읽은 후에는 다음을 알게됩니다:

* Action Cable이 무엇이고 백엔드와 프론트엔드와의 통합
* Action Cable 설정 방법
* 채널 설정 방법
* Action Cable 실행을 위한 배포 및 아키텍처 설정

--------------------------------------------------------------------------------

Action Cable이란 무엇인가?
---------------------

Action Cable은 [웹 소켓](https://en.wikipedia.org/wiki/WebSocket)을 Rails 애플리케이션의 나머지 부분과 완벽하게 통합합니다. 이를 통해 실시간 기능을 Ruby로 작성할 수 있으며, Rails 애플리케이션의 나머지 부분과 동일한 스타일과 형식으로 작성할 수 있습니다. 또한 성능과 확장성을 유지합니다. Action Cable은 클라이언트 측 JavaScript 프레임워크와 서버 측 Ruby 프레임워크를 모두 제공하는 풀 스택 오퍼링입니다. Active Record나 선택한 ORM으로 작성된 전체 도메인 모델에 액세스할 수 있습니다.

용어
-----------

Action Cable은 HTTP 요청-응답 프로토콜 대신 웹 소켓을 사용합니다. Action Cable과 웹 소켓은 일부 익숙하지 않은 용어를 도입합니다:

### Connections

*Connections*(연결)은 클라이언트-서버 관계의 기반을 형성합니다. 단일 Action Cable 서버는 여러 연결 인스턴스를 처리할 수 있습니다. WebSocket 연결당 하나의 연결 인스턴스를 가지고 있습니다. 단일 사용자는 여러 브라우저 탭이나 장치를 사용하여 애플리케이션에 대해 여러 웹 소켓을 열 수 있습니다.

### Consumers

WebSocket 연결의 클라이언트를 *consumer*(소비자)라고 합니다. Action Cable에서 consumer는 클라이언트 측 JavaScript 프레임워크에 의해 생성됩니다.

### Channels

각 consumer는 여러 *channels*(채널)에 구독할 수 있습니다. 각 채널은 일반적인 MVC 설정에서 컨트롤러가 하는 것과 유사한 논리적인 작업 단위를 캡슐화합니다. 예를 들어, `ChatChannel`과 `AppearancesChannel`이 있을 수 있으며, consumer는 이러한 채널 중 하나 또는 모두에 구독할 수 있습니다. 최소한 하나의 채널에 구독해야합니다.

### Subscribers

consumer가 채널에 구독하면 *subscriber*(구독자)로 작동합니다. 구독자와 채널 간의 연결은 구독이라고 합니다. consumer는 주어진 채널에 대해 여러 번 구독자로 작동할 수 있습니다. 예를 들어, consumer는 동시에 여러 채팅 룸에 구독할 수 있습니다. (물리적 사용자는 연결에 대해 여러 개의 consumer를 가질 수 있으며, 각각의 탭/장치에 대해 열려 있습니다).

### Pub/Sub

[Pub/Sub](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern) 또는 Publish-Subscribe는 발신자가 개별 수신자를 지정하지 않고 정보를 수신자의 추상 클래스에 전송하는 메시지 큐 패러다임을 참조합니다. Action Cable은 서버와 여러 클라이언트 간의 통신에 이 접근 방식을 사용합니다.

### Broadcastings

방송은 발송자가 전송하는 모든 것이 해당 이름의 방송을 스트리밍하는 채널 구독자에게 직접 전송되는 pub/sub 링크입니다. 각 채널은 0개 이상의 방송을 스트리밍 할 수 있습니다.

## 서버 측 구성 요소

### Connections

서버가 수락한 각 WebSocket에 대해 연결 객체가 인스턴스화됩니다. 이 객체는 이후에 생성되는 모든 *채널 구독*의 상위 개체가됩니다. 연결 자체는 인증 및 권한 부여를 포함한 특정 애플리케이션 로직을 다루지 않습니다. WebSocket 연결의 클라이언트를 연결 *consumer*라고 합니다. 개별 사용자는 브라우저 탭, 창 또는 장치당 하나의 consumer-connection 쌍을 생성합니다.

Connections는 `ApplicationCable::Connection`의 인스턴스입니다. 이는 [`ActionCable::Connection::Base`][]를 확장합니다. `ApplicationCable::Connection`에서는 들어오는 연결을 인증하고 확인된 경우 연결을 설정합니다.

#### 연결 설정

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

여기서 [`identified_by`][]는 나중에 특정 연결을 찾기 위해 사용할 수 있는 연결 식별자를 지정합니다. 식별자로 표시된 것은 연결에서 생성된 모든 채널 인스턴스에 동일한 이름의 대리자가 자동으로 생성됩니다.

이 예제는 이미 사용자의 인증을 애플리케이션의 다른 곳에서 처리했으며, 성공적인 인증이 사용자 ID가 포함된 암호화된 쿠키를 설정한다는 것을 전제로 합니다.

쿠키는 새로운 연결이 시도될 때 자동으로 연결 인스턴스로 전송되며, 이를 사용하여 `current_user`를 설정합니다. 동일한 현재 사용자로 연결을 식별함으로써 특정 사용자가 열린 모든 연결을 나중에 검색할 수 있음을 보장합니다 (사용자가 삭제되거나 권한이 없는 경우 모든 연결을 해제할 수도 있음).
인증 접근 방식에 세션을 사용하는 경우, 세션에는 쿠키 저장소를 사용하며 세션 쿠키는 `_session`이라는 이름을 가지고 있으며 사용자 ID 키는 `user_id`입니다. 이 접근 방식을 사용할 수 있습니다:

```ruby
verified_user = User.find_by(id: cookies.encrypted['_session']['user_id'])
```


#### 예외 처리

기본적으로 처리되지 않은 예외는 캐치되어 Rails의 로거에 기록됩니다. 예를 들어, 이러한 예외를 전역적으로 가로채고 외부 버그 추적 서비스에 보고하려면 [`rescue_from`][]을 사용할 수 있습니다:

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


#### 연결 콜백

클라이언트가 수신한 각 명령 전에 호출되는 `before_command`, `after_command`, `around_command` 콜백을 사용할 수 있습니다. 여기서 "명령"이란 클라이언트가 수신한 모든 상호작용(구독, 구독 취소 또는 작업 수행)을 의미합니다:

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    around_command :set_current_account

    private
      def set_current_account(&block)
        # 이제 모든 채널에서 Current.account를 사용할 수 있습니다
        Current.set(account: user.account, &block)
      end
  end
end
```

### 채널

*채널*은 일반적인 MVC 설정에서 컨트롤러가 수행하는 작업과 유사한 논리적인 작업 단위를 캡슐화합니다. 기본적으로 Rails는 공유 로직을 캡슐화하기 위해 [`ActionCable::Channel::Base`][]를 확장하는 부모 `ApplicationCable::Channel` 클래스를 생성합니다.

#### 부모 채널 설정

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

그런 다음 자체 채널 클래스를 만들 수 있습니다. 예를 들어, `ChatChannel`과 `AppearanceChannel`이 있을 수 있습니다:

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


그런 다음 소비자는 이러한 채널 중 하나 또는 둘 모두에 구독할 수 있습니다.

#### 구독

소비자는 채널에 구독하여 *구독자*로 작동합니다. 그들의 연결은 *구독*이라고 불립니다. 생성된 메시지는 채널 구독자가 보낸 식별자를 기반으로 이러한 채널 구독에 라우팅됩니다.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # 소비자가 이 채널에 성공적으로 구독한 경우 호출됩니다.
  def subscribed
  end
end
```

#### 예외 처리

`ApplicationCable::Connection`과 마찬가지로 특정 채널에서 [`rescue_from`][]을 사용하여 발생한 예외를 처리할 수도 있습니다:

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

#### 채널 콜백

`ApplicationCable::Channel`은 채널의 라이프 사이클 동안 로직을 트리거하는 데 사용할 수 있는 여러 콜백을 제공합니다. 사용 가능한 콜백은 다음과 같습니다:

- `before_subscribe`
- `after_subscribe` (또한 `on_subscribe`로 별칭 지정됨)
- `before_unsubscribe`
- `after_unsubscribe` (또한 `on_unsubscribe`로 별칭 지정됨)

참고: `after_subscribe` 콜백은 `subscribed` 메서드가 호출될 때마다 트리거됩니다. 심지어 `reject` 메서드로 구독이 거부된 경우에도입니다. 성공적인 구독에서만 `after_subscribe`를 트리거하려면 `after_subscribe :send_welcome_message, unless: :subscription_rejected?`를 사용하세요.

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

## 클라이언트 측 구성 요소

### 연결

소비자는 자신의 측에서 연결 인스턴스가 필요합니다. 이는 Rails에서 기본적으로 생성되는 다음 JavaScript를 사용하여 설정할 수 있습니다:

#### 소비자 연결

```js
// app/javascript/channels/consumer.js
// Action Cable은 Rails에서 WebSocket을 다루는 프레임워크를 제공합니다.
// `bin/rails generate channel` 명령을 사용하여 WebSocket 기능이 있는 새로운 채널을 생성할 수 있습니다.

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
```

이렇게 하면 기본적으로 서버의 `/cable`에 대한 연결이 준비됩니다. 최소한 하나 이상의 구독을 지정해야만 연결이 설정됩니다.

소비자는 연결할 URL을 지정하는 인수를 선택적으로 사용할 수 있습니다. 이는 문자열 또는 웹소켓이 열릴 때 호출되는 문자열을 반환하는 함수일 수 있습니다.

```js
// 다른 URL을 지정합니다
createConsumer('wss://example.com/cable')
// HTTP를 통해 웹소켓을 사용하는 경우
createConsumer('https://ws.example.com/cable')

// URL을 동적으로 생성하기 위해 함수를 사용합니다
createConsumer(getWebSocketURL)

function getWebSocketURL() {
  const token = localStorage.get('auth-token')
  return `wss://example.com/cable?token=${token}`
}
```

#### 구독자

소비자는 주어진 채널에 대한 구독을 생성함으로써 구독자가 됩니다:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" })

// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AppearanceChannel" })
```

이렇게 하면 구독이 생성되지만, 수신된 데이터에 대응하기 위해 필요한 기능은 나중에 설명됩니다.
소비자는 주어진 채널에 대해 여러 번 구독할 수 있습니다. 예를 들어, 소비자는 동시에 여러 개의 채팅방에 구독할 수 있습니다:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "1st Room" })
consumer.subscriptions.create({ channel: "ChatChannel", room: "2nd Room" })
```

## 클라이언트-서버 상호작용

### 스트림

*스트림*은 채널이 게시된 콘텐츠(방송)를 구독자에게 라우팅하는 메커니즘을 제공합니다. 예를 들어, 다음 코드는 `:room` 매개변수의 값이 `"Best Room"`일 때 `chat_Best Room`이라는 방송에 구독하기 위해 [`stream_from`][]을 사용합니다:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

그런 다음 Rails 애플리케이션의 다른 곳에서 [`broadcast`][]를 호출하여 해당 방송에 방송할 수 있습니다:

```ruby
ActionCable.server.broadcast("chat_Best Room", { body: "This Room is Best Room." })
```

모델과 관련된 스트림이 있는 경우, 방송 이름은 채널과 모델에서 생성될 수 있습니다. 예를 들어, 다음 코드는 [`stream_for`][]를 사용하여 `posts:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`와 같은 방송에 구독합니다. 여기서 `Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`는 Post 모델의 GlobalID입니다.

```ruby
class PostsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

그런 다음 [`broadcast_to`][]를 호출하여이 채널에 방송할 수 있습니다:

```ruby
PostsChannel.broadcast_to(@post, @comment)
```


### 방송

*방송*은 게시자가 전송하는 모든 것이 해당 방송을 스트리밍하는 채널 구독자로 직접 라우팅되는 pub/sub 링크입니다. 각 채널은 0개 이상의 방송을 스트리밍 할 수 있습니다.

방송은 순전히 온라인 큐이며 시간에 따라 달라집니다. 소비자가 스트리밍하지 않으면(주어진 채널에 구독하지 않으면) 나중에 연결하더라도 방송을받지 못합니다.

### 구독

소비자가 채널에 구독되면 구독자로서 작동합니다. 이 연결은 구독이라고합니다. 들어오는 메시지는 케이블 소비자가 보낸 식별자에 따라 이러한 채널 구독에 라우팅됩니다.

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

### 채널에 매개변수 전달

구독을 생성할 때 클라이언트 측에서 서버 측으로 매개변수를 전달할 수 있습니다. 예를 들어:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

`subscriptions.create`에 전달되는 객체는 케이블 채널의 params 해시가됩니다. 키워드 `channel`이 필요합니다:

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
# 앱의 어딘가에서 호출되는 이 코드입니다. 아마도
# NewCommentJob에서 호출됩니다.
ActionCable.server.broadcast(
  "chat_#{room}",
  {
    sent_by: 'Paul',
    body: 'This is a cool chat app.'
  }
)
```

### 메시지 재방송

일반적인 사용 사례는 한 클라이언트가 보낸 메시지를 다른 연결된 클라이언트에게 *재방송*하는 것입니다.

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

재방송은 보낸 메시지를 포함하여 모든 연결된 클라이언트에서 수신됩니다. 매개 변수는 채널에 구독 할 때와 동일합니다.

## 풀 스택 예제

다음 설정 단계는 두 예제에 모두 공통적입니다:

  1. [연결 설정](#connection-setup)을 설정합니다.
  2. [부모 채널 설정](#parent-channel-setup)을 설정합니다.
  3. [소비자 연결](#connect-consumer)을 설정합니다.

### 예제 1: 사용자 등장

사용자가 온라인인지 아닌지 및 어떤 페이지에 있는지 추적하는 채널의 간단한 예입니다. (온라인 상태인 경우 사용자 이름 옆에 녹색 점을 표시하는 등의 프레즌스 기능을 만드는 데 유용합니다).

서버 측 등장 채널을 만듭니다:

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
구독이 시작되면 `subscribed` 콜백이 호출되고, 우리는 이 기회를 이용하여 "현재 사용자가 실제로 나타났다"고 말합니다. 나타나기/사라지기 API는 Redis, 데이터베이스 또는 기타 어떤 것이든지로 지원될 수 있습니다.

클라이언트 측 외모 채널 구독을 생성합니다:

```js
// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("AppearanceChannel", {
  // 구독이 생성될 때 한 번 호출됩니다.
  initialized() {
    this.update = this.update.bind(this)
  },

  // 서버에서 사용할 준비가 되면 호출됩니다.
  connected() {
    this.install()
    this.update()
  },

  // WebSocket 연결이 닫힐 때 호출됩니다.
  disconnected() {
    this.uninstall()
  },

  // 서버에서 구독이 거부될 때 호출됩니다.
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // 서버에서 `AppearanceChannel#appear(data)`를 호출합니다.
    this.perform("appear", { appearing_on: this.appearingOn })
  },

  away() {
    // 서버에서 `AppearanceChannel#away`를 호출합니다.
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

#### 클라이언트-서버 상호작용

1. **클라이언트**는 `createConsumer()`를 통해 **서버**에 연결합니다. (`consumer.js`). **서버**는 `current_user`로 이 연결을 식별합니다.

2. **클라이언트**는 `consumer.subscriptions.create({ channel: "AppearanceChannel" })`를 통해 외모 채널에 구독합니다. (`appearance_channel.js`)

3. **서버**는 외모 채널에 대한 새로운 구독이 시작되었음을 인식하고, `subscribed` 콜백을 실행하여 `current_user`의 `appear` 메서드를 호출합니다. (`appearance_channel.rb`)

4. **클라이언트**는 구독이 설정되었음을 인식하고 `connected`를 호출합니다 (`appearance_channel.js`), 이는 `install`과 `appear`를 호출합니다. `appear`는 서버에서 `AppearanceChannel#appear(data)`를 호출하며, `this.appearingOn`을 포함한 데이터 해시를 제공합니다. 이는 서버 측 채널 인스턴스가 클래스에 선언된 모든 공개 메서드(콜백 제외)를 자동으로 노출시키므로, 이러한 메서드는 구독의 `perform` 메서드를 통해 원격 프로시저 호출로 도달할 수 있습니다.

5. **서버**는 외모 채널의 `appear` 액션에 대한 요청을 `current_user`로 식별된 연결에 대해 받습니다 (`appearance_channel.rb`). **서버**는 데이터 해시에서 `:appearing_on` 키로 데이터를 검색하고, `current_user.appear`에 전달되는 `:on` 키의 값으로 설정합니다.

### 예제 2: 새 웹 알림 수신

외모 예제는 서버 기능을 웹소켓 연결을 통해 클라이언트 측에서 호출할 수 있도록 노출하는 것이었습니다. 그러나 웹소켓의 큰 장점은 양방향 통신이 가능하다는 것입니다. 그래서 이제 서버가 클라이언트에게 작업을 호출하는 예제를 보여줄 것입니다.

이것은 관련 스트림에 방송할 때 클라이언트 측 웹 알림을 트리거할 수 있는 웹 알림 채널입니다:

서버 측 웹 알림 채널을 생성합니다:

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

클라이언트 측 웹 알림 채널 구독을 생성합니다:

```js
// app/javascript/channels/web_notifications_channel.js
// 이미 웹 알림을 보내기 위한 권한을 요청했다고 가정하는 클라이언트 측
import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  received(data) {
    new Notification(data["title"], { body: data["body"] })
  }
})
```

애플리케이션의 다른 곳에서 웹 알림 채널 인스턴스로 콘텐츠를 방송합니다:

```ruby
# 앱의 어딘가에서 호출되는 경우가 있습니다. 아마도 NewCommentJob에서 호출됩니다.
WebNotificationsChannel.broadcast_to(
  current_user,
  title: '새로운 내용!',
  body: '모든 뉴스가 인쇄에 적합합니다'
)
```

`WebNotificationsChannel.broadcast_to` 호출은 각 사용자에 대해 별도의 방송 이름으로 현재 구독 어댑터의 pubsub 큐에 메시지를 배치합니다. ID가 1인 사용자의 경우, 방송 이름은 `web_notifications:1`이 됩니다.

채널은 `web_notifications:1`에 도착하는 모든 것을 클라이언트에 직접 전달하기 위해 `received` 콜백을 호출하여 스트림에 도착하는 모든 데이터를 전달합니다. 전달되는 인수는 서버 측 방송 호출의 두 번째 매개변수로 전송되는 해시이며, 전송을 위해 JSON으로 인코딩되고 `received`로 도착하는 데이터 인수로 언팩됩니다.

### 더 완전한 예제

Action Cable을 Rails 앱에 설정하고 채널을 추가하는 방법에 대한 전체 예제는 [rails/actioncable-examples](https://github.com/rails/actioncable-examples) 저장소를 참조하십시오.

## 구성

Action Cable에는 구독 어댑터와 허용된 요청 원본이라는 두 가지 필수 구성이 있습니다.

### 구독 어댑터

Action Cable은 기본적으로 `config/cable.yml`에서 구성 파일을 찾습니다.
파일은 각 Rails 환경에 대해 어댑터를 지정해야 합니다. 어댑터에 대한 추가 정보는
[Dependencies](#dependencies) 섹션을 참조하십시오.

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
#### 어댑터 구성

아래는 최종 사용자를 위한 구독 어댑터 목록입니다.

##### Async 어댑터

Async 어댑터는 개발/테스트용으로 만들어졌으며, 운영 환경에서 사용해서는 안 됩니다.

##### Redis 어댑터

Redis 어댑터는 사용자가 Redis 서버를 가리키는 URL을 제공해야 합니다.
또한, 동일한 Redis 서버를 여러 애플리케이션에서 사용할 때 채널 이름 충돌을 피하기 위해 `channel_prefix`를 제공할 수 있습니다.
자세한 내용은 [Redis Pub/Sub 문서](https://redis.io/docs/manual/pubsub/#database--scoping)를 참조하세요.

Redis 어댑터는 SSL/TLS 연결도 지원합니다. 필요한 SSL/TLS 매개변수는 구성 YAML 파일의 `ssl_params` 키를 통해 전달할 수 있습니다.

```
production:
  adapter: redis
  url: rediss://10.10.3.153:tls_port
  channel_prefix: appname_production
  ssl_params: {
    ca_file: "/path/to/ca.crt"
  }
```

`ssl_params`에 주어진 옵션은 `OpenSSL::SSL::SSLContext#set_params` 메서드에 직접 전달되며, SSL 컨텍스트의 유효한 속성이 될 수 있습니다.
다른 사용 가능한 속성에 대해서는 [OpenSSL::SSL::SSLContext 문서](https://docs.ruby-lang.org/en/master/OpenSSL/SSL/SSLContext.html)를 참조하세요.

방화벽 뒤의 Redis 어댑터에 대해 자체 서명된 인증서를 사용하고 인증서 확인을 건너뛰려면, ssl `verify_mode`를 `OpenSSL::SSL::VERIFY_NONE`으로 설정해야 합니다.

경고: 보안 상의 이유를 정확히 이해하지 않는 한, 운영 환경에서는 `VERIFY_NONE`을 사용하는 것을 권장하지 않습니다. Redis 어댑터에 이 옵션을 설정하려면 구성은 `ssl_params: { verify_mode: <%= OpenSSL::SSL::VERIFY_NONE %> }`이어야 합니다.

##### PostgreSQL 어댑터

PostgreSQL 어댑터는 Active Record의 연결 풀을 사용하며, 따라서 애플리케이션의 `config/database.yml` 데이터베이스 구성을 사용합니다.
이는 나중에 변경될 수 있습니다. [#27214](https://github.com/rails/rails/issues/27214)

### 허용된 요청 원본

Action Cable은 지정된 원본에서만 요청을 허용합니다. 이는 서버 구성으로 배열로 전달됩니다. 원본은 문자열 또는 정규식의 인스턴스일 수 있으며, 일치 여부를 확인하기 위해 체크됩니다.

```ruby
config.action_cable.allowed_request_origins = ['https://rubyonrails.com', %r{http://ruby.*}]
```

비활성화하고 모든 원본에서 요청을 허용하려면:

```ruby
config.action_cable.disable_request_forgery_protection = true
```

기본적으로 개발 환경에서는 Action Cable이 localhost:3000에서의 모든 요청을 허용합니다.

### 소비자 구성

URL을 구성하려면 HTML 레이아웃 HEAD에 [`action_cable_meta_tag`][]를 호출하세요.
이는 일반적으로 환경 구성 파일의 [`config.action_cable.url`][]을 통해 설정된 URL 또는 경로를 사용합니다.


### 워커 풀 구성

워커 풀은 서버의 주 스레드와 격리되어 연결 콜백 및 채널 작업을 실행하는 데 사용됩니다. Action Cable은 응용 프로그램이 워커 풀에서 동시에 처리되는 스레드 수를 구성할 수 있도록 합니다.

```ruby
config.action_cable.worker_pool_size = 4
```

또한, 서버는 워커 수와 동일한 수의 데이터베이스 연결을 제공해야 합니다. 기본 워커 풀 크기는 4로 설정되어 있으므로, 최소한 4개의 데이터베이스 연결을 사용할 수 있어야 합니다.
`config/database.yml`에서 `pool` 속성을 통해 이를 변경할 수 있습니다.

### 클라이언트 측 로깅

기본적으로 클라이언트 측 로깅은 비활성화되어 있습니다. `ActionCable.logger.enabled`를 true로 설정하여 이를 활성화할 수 있습니다.

```ruby
import * as ActionCable from '@rails/actioncable'

ActionCable.logger.enabled = true
```

### 기타 구성

구성할 수 있는 다른 일반적인 옵션은 연결 로거에 적용되는 로그 태그입니다. 다음은 사용 가능한 경우 사용자 계정 ID를 사용하고, 그렇지 않으면 "no-account"를 태그로 사용하는 예입니다.

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

모든 구성 옵션의 전체 목록은 `ActionCable::Server::Configuration` 클래스를 참조하세요.

## 독립 실행형 케이블 서버 실행

Action Cable은 Rails 애플리케이션의 일부로 실행되거나 독립 실행형 서버로 실행될 수 있습니다. 개발 환경에서는 Rails 앱의 일부로 실행하는 것이 일반적으로 좋지만, 운영 환경에서는 독립 실행형으로 실행해야 합니다.

### 앱 내에서

Action Cable은 Rails 애플리케이션과 함께 실행될 수 있습니다. 예를 들어, WebSocket 요청을 `/websocket`에서 수신하도록 지정하려면 [`config.action_cable.mount_path`][]에 해당 경로를 지정하세요.

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

[`action_cable_meta_tag`][]가 레이아웃에서 호출되면 `ActionCable.createConsumer()`를 사용하여 케이블 서버에 연결할 수 있습니다. 그렇지 않으면 첫 번째 인수로 경로를 지정합니다 (`ActionCable.createConsumer("/websocket")`와 같이).

생성하는 서버의 각 인스턴스와 서버에서 생성하는 각 워커마다 Action Cable의 새 인스턴스가 생성되지만, Redis 또는 PostgreSQL 어댑터는 연결 간에 메시지를 동기화합니다.


### 독립 실행형

케이블 서버는 일반적인 애플리케이션 서버와 분리될 수 있습니다. 여전히 Rack 애플리케이션이지만, 자체 Rack 애플리케이션입니다. 권장하는 기본 설정은 다음과 같습니다.
```ruby
# cable/config.ru
require_relative "../config/environment"
Rails.application.eager_load!

run ActionCable.server
```

서버를 시작하려면:

```
bundle exec puma -p 28080 cable/config.ru
```

이렇게 하면 포트 28080에서 케이블 서버가 시작됩니다. Rails가 이 서버를 사용하도록 지정하려면 구성을 업데이트하세요:

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_cable.mount_path = nil
  config.action_cable.url = "ws://localhost:28080" # 프로덕션에서는 wss:// 사용
end
```

마지막으로, [소비자를 올바르게 구성](#consumer-configuration)했는지 확인하세요.

### 참고 사항

웹소켓 서버는 세션에 액세스할 수 없지만 쿠키에는 액세스할 수 있습니다. 이는 인증을 처리해야 할 때 사용할 수 있습니다. Devise를 사용한 한 가지 방법은 [이 문서](https://greg.molnar.io/blog/actioncable-devise-authentication/)에서 확인할 수 있습니다.

## 의존성

Action Cable은 pubsub 내부를 처리하기 위한 구독 어댑터 인터페이스를 제공합니다. 기본적으로 비동기, 인라인, PostgreSQL 및 Redis 어댑터가 포함되어 있습니다. 새로운 Rails 애플리케이션의 기본 어댑터는 비동기(`async`) 어댑터입니다.

Ruby 측면은 [websocket-driver](https://github.com/faye/websocket-driver-ruby), [nio4r](https://github.com/celluloid/nio4r) 및 [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) 위에 구축되었습니다.

## 배포

Action Cable은 웹소켓과 스레드의 조합으로 구동됩니다. 프레임워크의 내부적으로는 Ruby의 기본 스레드 지원을 활용하여 프레임워크 플러밍 및 사용자 지정 채널 작업을 처리합니다. 따라서 기존의 모든 Rails 모델을 문제없이 사용할 수 있습니다. 다만 스레드 안전성을 위반하지 않았다면입니다.

Action Cable 서버는 Rack 소켓 하이재킹 API를 구현하여 응용 프로그램 서버가 멀티 스레드인지 여부에 관계없이 내부적으로 연결을 관리하기 위해 멀티 스레드 패턴을 사용할 수 있습니다.

따라서 Action Cable은 Unicorn, Puma 및 Passenger와 같은 인기있는 서버와 함께 작동합니다.

## 테스트

Action Cable 기능을 테스트하는 방법에 대한 자세한 지침은 [테스트 가이드](testing.html#testing-action-cable)에서 찾을 수 있습니다.
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
