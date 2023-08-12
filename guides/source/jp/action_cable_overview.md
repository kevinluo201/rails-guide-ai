**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4f7308fdab05dc13d399bde6a8ac302c
Action Cableの概要
=====================

このガイドでは、Action Cableの動作方法とWebSocketsを使用してリアルタイム機能をRailsアプリケーションに組み込む方法について学びます。

このガイドを読み終えると、以下のことがわかります：

* Action Cableとは何か、およびそのバックエンドとフロントエンドの統合方法
* Action Cableのセットアップ方法
* チャンネルのセットアップ方法
* Action Cableを実行するためのデプロイとアーキテクチャのセットアップ

--------------------------------------------------------------------------------

Action Cableとは？
---------------------

Action Cableは、[WebSockets](https://en.wikipedia.org/wiki/WebSocket)をRailsアプリケーションの他の部分とシームレスに統合します。これにより、リアルタイム機能をRailsアプリケーションの他の部分と同じスタイルと形式でRubyで記述することができます。また、パフォーマンスとスケーラビリティも確保されます。Action Cableは、クライアント側のJavaScriptフレームワークとサーバー側のRubyフレームワークの両方を提供するフルスタックのオファリングです。Active Recordや選択したORMで記述されたドメインモデル全体にアクセスできます。

用語
-----------

Action Cableは、HTTPリクエスト-レスポンスプロトコルの代わりにWebSocketsを使用します。Action CableとWebSocketsの両方には、いくつかの馴染みのない用語が導入されます：

### Connections

*Connections*は、クライアントとサーバーの関係の基礎を形成します。単一のAction Cableサーバーは、複数の接続インスタンスを処理できます。WebSocket接続ごとに1つの接続インスタンスがあります。ユーザーは、複数のブラウザタブやデバイスを使用してアプリケーションに複数のWebSocketを開くことがあります。

### Consumers

WebSocket接続のクライアントは*consumer*と呼ばれます。Action Cableでは、consumerはクライアント側のJavaScriptフレームワークによって作成されます。

### Channels

各consumerは、複数の*channels*にサブスクライブできます。各チャンネルは、典型的なMVCセットアップのコントローラと同様の論理的な作業単位をカプセル化します。たとえば、`ChatChannel`や`AppearancesChannel`などがあり、consumerはこれらのチャンネルのいずれかまたは両方にサブスクライブできます。少なくとも1つのチャンネルにconsumerがサブスクライブしている必要があります。

### Subscribers

consumerがチャンネルにサブスクライブすると、彼らは*subscriber*として機能します。subscriberとチャンネルの間の接続は、予想通り*subscription*と呼ばれます。consumerは、同じチャンネルに対して任意の回数のsubscriberとして機能することができます。たとえば、consumerは同時に複数のチャットルームにサブスクライブすることができます。（また、物理的なユーザーは接続されているタブ/デバイスごとに複数のconsumerを持つ可能性があることを覚えておいてください）。

### Pub/Sub

[Pub/Sub](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern)またはPublish-Subscribeは、送信者（パブリッシャー）が個々の受信者を指定せずに情報を抽象的な受信者のクラス（サブスクライバー）に送信するメッセージキューパラダイムを指します。Action Cableは、サーバーと多数のクライアント間の通信にこのアプローチを使用します。

### Broadcastings

ブロードキャストは、ブロードキャスターによって送信されるすべてのものが、その名前付きのブロードキャストをストリーミングしているチャンネルのサブスクライバーに直接送信されるパブ/サブリンクです。各チャンネルは、0個以上のブロードキャストをストリーミングできます。

## サーバーサイドのコンポーネント

### Connections

サーバーが受け入れるWebSocketごとに、接続オブジェクトがインスタンス化されます。このオブジェクトは、以降作成されるすべての*channel subscriptions*の親となります。接続自体は、認証と認可を超えた特定のアプリケーションロジックを扱いません。WebSocket接続のクライアントは、接続*consumer*と呼ばれます。個々のユーザーは、ブラウザのタブ、ウィンドウ、またはデバイスごとに1つのconsumer-connectionペアを作成します。

Connectionsは、`ApplicationCable::Connection`のインスタンスです。これは[`ActionCable::Connection::Base`][]を拡張しています。`ApplicationCable::Connection`では、受信した接続を認証し、識別できる場合に接続を確立します。

#### Connectionのセットアップ

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

ここでは、[`identified_by`][]は、後で特定の接続を見つけるために使用できる接続識別子を指定します。識別子としてマークされたものは、接続から作成されたすべてのチャンネルインスタンスに同じ名前のデリゲートが自動的に作成されることに注意してください。

この例では、すでにユーザーの認証をアプリケーションの別の場所で処理していることを前提としています。成功した認証は、ユーザーIDを暗号化されたクッキーに設定します。

そのクッキーは、新しい接続が試行されたときに自動的に接続インスタンスに送信され、それを使用して`current_user`を設定します。この同じ現在のユーザーで接続を識別することにより、後で特定のユーザーによって開かれたすべての接続を取得できることも保証しています（ユーザーが削除された場合や認証されていない場合には、すべての接続を切断する可能性もあります）。
もし認証アプローチにセッションを使用する場合、セッションにはCookieストアを使用し、セッションのクッキーの名前は `_session` であり、ユーザーIDのキーは `user_id` である場合、次のアプローチを使用できます：

```ruby
verified_user = User.find_by(id: cookies.encrypted['_session']['user_id'])
```


#### 例外処理

デフォルトでは、未処理の例外はキャッチされ、Railsのロガーに記録されます。例外をグローバルにインターセプトし、外部のバグトラッキングサービスに報告する場合などは、[`rescue_from`][]を使用できます：

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


#### コネクションコールバック

クライアントが受け取ったコマンドの前、後、または周りで呼び出される `before_command`、`after_command`、および `around_command` のコールバックが利用可能です。
ここでの「コマンド」とは、クライアントが受け取った任意のインタラクション（購読、購読解除、アクションの実行）を指します：

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    around_command :set_current_account

    private
      def set_current_account(&block)
        # これですべてのチャンネルで Current.account を使用できます
        Current.set(account: user.account, &block)
      end
  end
end
```

### チャンネル

*チャンネル*は、典型的なMVCのセットアップでコントローラが行うような論理的な作業の単位をカプセル化します。デフォルトでは、Railsは親の `ApplicationCable::Channel` クラス（[`ActionCable::Channel::Base`]を拡張したもの）を作成して、チャンネル間で共有されるロジックをカプセル化します。

#### 親チャンネルのセットアップ

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

その後、独自のチャンネルクラスを作成します。たとえば、`ChatChannel` と `AppearanceChannel` を持つことができます：

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


その後、コンシューマはこれらのチャンネルのいずれかまたは両方に購読することができます。

#### 購読

コンシューマはチャンネルに購読し、*サブスクライバー*として動作します。彼らの接続は*サブスクリプション*と呼ばれます。生成されたメッセージは、チャンネルコンシューマが送信した識別子に基づいて、これらのチャンネルサブスクリプションにルーティングされます。

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # コンシューマがこのチャンネルに正常に購読したときに呼び出されます。
  def subscribed
  end
end
```

#### 例外処理

`ApplicationCable::Connection` と同様に、特定のチャンネルで [`rescue_from`][] を使用して発生した例外を処理することもできます：

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

#### チャンネルコールバック

`ApplicationCable::Channel` は、チャンネルのライフサイクル中にロジックをトリガーするために使用できるいくつかのコールバックを提供します。利用可能なコールバックは次のとおりです：

- `before_subscribe`
- `after_subscribe`（または `on_subscribe` ともエイリアス）
- `before_unsubscribe`
- `after_unsubscribe`（または `on_unsubscribe` ともエイリアス）

注意：`after_subscribe` コールバックは、`subscribed` メソッドが呼び出されたときに常にトリガーされますが、`reject` メソッドで購読が拒否された場合でもです。成功した購読の場合にのみ `after_subscribe` をトリガーするには、`after_subscribe :send_welcome_message, unless: :subscription_rejected?` を使用します。

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

## クライアントサイドコンポーネント

### コネクション

コンシューマは、自分側でコネクションのインスタンスを必要とします。これは、Railsによってデフォルトで生成される次のJavaScriptを使用して確立できます：

#### コンシューマの接続

```js
// app/javascript/channels/consumer.js
// Action Cableは、RailsでWebSocketsを扱うためのフレームワークを提供します。
// `bin/rails generate channel` コマンドを使用して、WebSocketの機能が存在する新しいチャンネルを生成できます。

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
```

これにより、デフォルトでサーバーの `/cable` に対して接続するコンシューマが準備されます。
少なくとも1つの購読を指定するまで、接続は確立されません。

コンシューマは、接続するURLを指定する引数をオプションで受け取ることもできます。これは文字列または文字列を返す関数である必要があります。WebSocketが開かれたときに呼び出されます。

```js
// 別のURLを指定する
createConsumer('wss://example.com/cable')
// HTTP経由でWebSocketsを使用する場合
createConsumer('https://ws.example.com/cable')

// URLを動的に生成するための関数を使用する
createConsumer(getWebSocketURL)

function getWebSocketURL() {
  const token = localStorage.get('auth-token')
  return `wss://example.com/cable?token=${token}`
}
```

#### サブスクライバー

コンシューマは、指定されたチャンネルに対して購読を作成することで、サブスクライバーになります：

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" })

// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AppearanceChannel" })
```

これにより、購読が作成されますが、受信したデータに応答するために必要な機能は後で説明されます。
消費者は、任意のチャネルに対して何度でも購読者として動作することができます。たとえば、消費者は同時に複数のチャットルームに購読することができます。

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "1st Room" })
consumer.subscriptions.create({ channel: "ChatChannel", room: "2nd Room" })
```

## クライアントとサーバーの相互作用

### ストリーム

*ストリーム*は、チャネルが公開されたコンテンツ（ブロードキャスト）をその購読者にルーティングするメカニズムを提供します。たとえば、次のコードは、`:room`パラメータの値が`"Best Room"`の場合に、`stream_from`を使用して`chat_Best Room`というブロードキャストに購読する方法を示しています。

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

その後、Railsアプリケーションの別の場所で、[`broadcast`]を呼び出すことで、そのようなルームにブロードキャストすることができます。

```ruby
ActionCable.server.broadcast("chat_Best Room", { body: "This Room is Best Room." })
```

モデルに関連するストリームがある場合、ブロードキャスト名はチャネルとモデルから生成されることがあります。たとえば、次のコードは、`posts:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`のようなブロードキャストに購読するために[`stream_for`]を使用しています。ここで、`Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`はPostモデルのGlobalIDです。

```ruby
class PostsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

その後、[`broadcast_to`]を呼び出すことで、このチャネルにブロードキャストすることができます。

```ruby
PostsChannel.broadcast_to(@post, @comment)
```


### ブロードキャスト

*ブロードキャスト*は、パブ/サブリンクであり、パブリッシャーによって送信されるすべてのものが、その名前のブロードキャストをストリーミングしているチャネルの購読者に直接ルーティングされます。各チャネルは、ゼロ個以上のブロードキャストをストリーミングできます。

ブロードキャストは純粋にオンラインのキューであり、時間に依存します。消費者がストリーミングしていない（特定のチャネルに購読していない）場合、後で接続してもブロードキャストは受信されません。

### 購読

消費者がチャネルに購読されているとき、彼らは購読者として動作します。この接続は購読と呼ばれます。着信メッセージは、ケーブル消費者によって送信された識別子に基づいて、これらのチャネルの購読にルーティングされます。

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

### チャネルへのパラメータの渡し方

サブスクリプションを作成する際に、クライアントサイドからサーバーサイドにパラメータを渡すことができます。たとえば：

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

`subscriptions.create`の最初の引数として渡されるオブジェクトは、ケーブルチャネルのparamsハッシュになります。キーワード`channel`が必要です。

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
# アプリケーションのどこかでこれが呼び出されるかもしれません
# NewCommentJobから呼び出されるかもしれません。
ActionCable.server.broadcast(
  "chat_#{room}",
  {
    sent_by: 'Paul',
    body: 'This is a cool chat app.'
  }
)
```

### メッセージの再ブロードキャスト

一般的なユースケースは、1つのクライアントが送信したメッセージを他の接続されたクライアントに*再ブロードキャスト*することです。

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

再ブロードキャストは、送信したメッセージを含むすべての接続されたクライアント、つまりメッセージを送信したクライアントも含まれます。パラメータは、チャネルに購読したときと同じです。

## フルスタックの例

以下のセットアップ手順は、両方の例で共通です：

  1. [接続のセットアップ](#connection-setup)。
  2. [親チャネルのセットアップ](#parent-channel-setup)。
  3. [コンシューマーの接続](#connect-consumer)。

### 例1：ユーザーの出現

ユーザーがオンラインかどうかと、どのページにいるかを追跡するチャネルの単純な例です（オンラインである場合にユーザー名の横に緑の点を表示するなどの存在機能を作成するのに便利です）。

サーバーサイドの出現チャネルを作成します：

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
サブスクリプションが開始されると、`subscribed`コールバックが呼び出され、その機会に「現在のユーザーが実際に表示されました」と言うことができます。この表示/非表示のAPIはRedis、データベース、またはその他のものでバックアップされる可能性があります。

クライアント側の表示チャネルのサブスクリプションを作成します。

```js
// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("AppearanceChannel", {
  // サブスクリプションが作成されたときに一度呼び出されます。
  initialized() {
    this.update = this.update.bind(this)
  },

  // サブスクリプションがサーバーで使用できる状態になったときに呼び出されます。
  connected() {
    this.install()
    this.update()
  },

  // WebSocket接続が閉じられたときに呼び出されます。
  disconnected() {
    this.uninstall()
  },

  // サブスクリプションがサーバーによって拒否されたときに呼び出されます。
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // サーバー上の`AppearanceChannel#appear(data)`を呼び出します。
    this.perform("appear", { appearing_on: this.appearingOn })
  },

  away() {
    // サーバー上の`AppearanceChannel#away`を呼び出します。
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

#### クライアント-サーバーの相互作用

1. **クライアント**は`createConsumer()`を介して**サーバー**に接続します（`consumer.js`）。**サーバー**は`current_user`によってこの接続を識別します。

2. **クライアント**は表示チャネルに対してサブスクライブします（`consumer.subscriptions.create({ channel: "AppearanceChannel" })`）（`appearance_channel.js`）。

3. **サーバー**は表示チャネルの新しいサブスクリプションが開始されたことを認識し、`subscribed`コールバックを実行し、`current_user`の`appear`メソッドを呼び出します（`appearance_channel.rb`）。

4. **クライアント**はサブスクリプションが確立されたことを認識し、`connected`を呼び出します（`appearance_channel.js`）。これにより、`install`と`appear`が呼び出されます。`appear`はサーバー上の`AppearanceChannel#appear(data)`を呼び出し、`{ appearing_on: this.appearingOn }`のデータハッシュを提供します。これは、サーバーサイドのチャネルインスタンスが、（コールバックを除く）クラスで宣言されたすべての公開メソッドを自動的に公開し、これらにサブスクリプションの`perform`メソッドを介してリモートプロシージャ呼び出しとして到達できるためです。

5. **サーバー**は、`current_user`で識別される接続の表示アクションのリクエストを受け取ります（`appearance_channel.rb`）。**サーバー**は、データハッシュから`:appearing_on`キーでデータを取得し、それを`current_user.appear`の渡される`:on`キーの値として設定します。

### 例2：新しいWeb通知の受信

表示の例は、サーバーの機能をWebSocket接続を介してクライアント側で呼び出す方法についてでした。ただし、WebSocketの素晴らしいところは、双方向の通信が可能であることです。次に、サーバーがクライアント上でアクションを呼び出す例を示します。

これは、関連するストリームにブロードキャストすると、クライアント側のWeb通知をトリガーすることができるWeb通知チャネルです。

サーバーサイドのWeb通知チャネルを作成します。

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

クライアント側のWeb通知チャネルのサブスクリプションを作成します。

```js
// app/javascript/channels/web_notifications_channel.js
// クライアント側では、すでにWeb通知の送信権限をリクエストしていることを前提としています。
import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  received(data) {
    new Notification(data["title"], { body: data["body"] })
  }
})
```

アプリケーションの他の場所からWeb通知チャネルインスタンスにコンテンツをブロードキャストします。

```ruby
# おそらくNewCommentJobから呼び出されるアプリケーションのどこかでこれが呼び出されます
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'New things!',
  body: 'All the news fit to print'
)
```

`WebNotificationsChannel.broadcast_to`呼び出しは、現在のサブスクリプションアダプタのパブサブキューにメッセージを配置し、各ユーザーごとに別個のブロードキャスト名の下に配置します。IDが1のユーザーの場合、ブロードキャスト名は`web_notifications:1`になります。

チャネルは、`web_notifications:1`に到着するすべてのものをクライアントに直接ストリーミングするように指示されており、`received`コールバックを呼び出すことで引数として渡されるデータは、サーバーサイドのブロードキャスト呼び出しの2番目のパラメータとして送信されるハッシュであり、ワイヤを介してJSONエンコードされ、`received`として到着するデータ引数としてアンパックされます。

### より完全な例

Action CableをRailsアプリに設定し、チャネルを追加する方法の完全な例については、[rails/actioncable-examples](https://github.com/rails/actioncable-examples)リポジトリを参照してください。

## 設定

Action Cableには2つの必須の設定があります：サブスクリプションアダプタと許可されたリクエストの起源。

### サブスクリプションアダプタ

デフォルトでは、Action Cableは`config/cable.yml`で設定ファイルを検索します。
ファイルは、各Rails環境ごとにアダプタを指定する必要があります。アダプタに関する詳細については、[Dependencies](#dependencies)セクションを参照してください。

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
#### アダプターの設定

以下は、エンドユーザーに利用可能なサブスクリプションアダプターのリストです。

##### Async アダプター

Async アダプターは開発/テスト用であり、本番環境では使用しないでください。

##### Redis アダプター

Redis アダプターでは、ユーザーが Redis サーバーを指す URL を提供する必要があります。
さらに、同じ Redis サーバーを複数のアプリケーションで使用する場合にチャネル名の衝突を回避するために `channel_prefix` を指定することもできます。
詳細については、[Redis Pub/Sub のドキュメント](https://redis.io/docs/manual/pubsub/#database--scoping)を参照してください。

Redis アダプターは SSL/TLS 接続もサポートしています。必要な SSL/TLS パラメータは、設定の YAML ファイルの `ssl_params` キーに渡すことができます。

```
production:
  adapter: redis
  url: rediss://10.10.3.153:tls_port
  channel_prefix: appname_production
  ssl_params: {
    ca_file: "/path/to/ca.crt"
  }
```

`ssl_params` に指定するオプションは、`OpenSSL::SSL::SSLContext#set_params` メソッドに直接渡され、SSL コンテキストの有効な属性であれば何でも使用できます。
他の利用可能な属性については、[OpenSSL::SSL::SSLContext のドキュメント](https://docs.ruby-lang.org/en/master/OpenSSL/SSL/SSLContext.html)を参照してください。

Redis アダプターでファイアウォールの背後にある自己署名証明書を使用し、証明書のチェックをスキップする場合、ssl `verify_mode` を `OpenSSL::SSL::VERIFY_NONE` に設定する必要があります。

警告: セキュリティ上の影響を完全に理解していない限り、本番環境では `VERIFY_NONE` を使用しないことをお勧めします。Redis アダプターのこのオプションを設定するには、設定は `ssl_params: { verify_mode: <%= OpenSSL::SSL::VERIFY_NONE %> }` である必要があります。

##### PostgreSQL アダプター

PostgreSQL アダプターは Active Record の接続プールを使用し、
アプリケーションの `config/database.yml` データベースの設定を使用して接続します。
将来的にはこれが変更される可能性があります。[#27214](https://github.com/rails/rails/issues/27214)

### 許可されたリクエスト元

Action Cable は、指定されたオリジンからのリクエストのみ受け付けます。これらのオリジンは、
サーバーの設定に配列として渡されます。オリジンは、文字列または正規表現のインスタンスであることができ、
一致のチェックが行われます。

```ruby
config.action_cable.allowed_request_origins = ['https://rubyonrails.com', %r{http://ruby.*}]
```

無効にして任意のオリジンからのリクエストを許可するには:

```ruby
config.action_cable.disable_request_forgery_protection = true
```

デフォルトでは、Action Cable は開発環境で実行されている場合にのみ、localhost:3000 からのすべてのリクエストを許可します。

### コンシューマーの設定

URL を設定するには、HTML レイアウトの HEAD に [`action_cable_meta_tag`][] を呼び出します。
これは通常、環境設定ファイルの [`config.action_cable.url`][] で設定される URL またはパスを使用します。


### ワーカープールの設定

ワーカープールは、接続コールバックとチャネルアクションをサーバーのメインスレッドから分離して実行するために使用されます。Action Cable では、アプリケーションがワーカープール内で同時に処理されるスレッドの数を設定できます。

```ruby
config.action_cable.worker_pool_size = 4
```

また、サーバーは少なくともワーカーの数と同じ数のデータベース接続を提供する必要があります。デフォルトのワーカープールサイズは 4 に設定されているため、少なくとも 4 つのデータベース接続を利用できるようにする必要があります。
これは `config/database.yml` の `pool` 属性を介して変更できます。

### クライアント側のログ記録

デフォルトでは、クライアント側のログ記録は無効になっています。`ActionCable.logger.enabled` を true に設定することで有効にできます。

```ruby
import * as ActionCable from '@rails/actioncable'

ActionCable.logger.enabled = true
```

### その他の設定

設定する一般的なオプションは、接続ごとのロガーに適用されるログタグです。以下は、ユーザーアカウント ID が利用可能な場合はそれを使用し、利用できない場合は "no-account" というタグを付ける例です。

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

すべての設定オプションの完全なリストについては、
`ActionCable::Server::Configuration` クラスを参照してください。

## スタンドアロンケーブルサーバーの実行

Action Cable は、Rails アプリケーションの一部として実行するか、スタンドアロンサーバーとして実行することができます。開発環境では、Rails アプリケーションの一部として実行することが一般的ですが、本番環境ではスタンドアロンで実行する必要があります。

### アプリ内

Action Cable は、Rails アプリケーションと並行して実行することができます。たとえば、WebSocket リクエストを `/websocket` で受け付けるようにするには、[`config.action_cable.mount_path`][] にそのパスを指定します。

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

[`action_cable_meta_tag`][] がレイアウトで呼び出された場合、`ActionCable.createConsumer()` を使用してケーブルサーバーに接続できます。それ以外の場合、`createConsumer` の第一引数にパスを指定します（例: `ActionCable.createConsumer("/websocket")`）。

作成するサーバーのインスタンスごとに、およびサーバーが生成する各ワーカーごとに、新しい Action Cable のインスタンスが作成されますが、Redis または PostgreSQL アダプターは接続間でメッセージを同期します。


### スタンドアロン

ケーブルサーバーは通常のアプリケーションサーバーから分離することができます。それはまだ Rack アプリケーションですが、独自の Rack アプリケーションです。推奨される基本的なセットアップは次のとおりです。
```ruby
# cable/config.ru
require_relative "../config/environment"
Rails.application.eager_load!

run ActionCable.server
```

サーバーを起動するには次のコマンドを実行します：

```
bundle exec puma -p 28080 cable/config.ru
```

これにより、ポート28080でケーブルサーバーが起動します。Railsがこのサーバーを使用するようにするには、設定を更新します：

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_cable.mount_path = nil
  config.action_cable.url = "ws://localhost:28080" # 本番環境ではwss://を使用します
end
```

最後に、[consumerの設定を正しく行っていること](#consumer-configuration)を確認してください。

### ノート

WebSocketサーバーはセッションにアクセスすることはできませんが、クッキーにはアクセスできます。これは認証を処理する必要がある場合に使用できます。Deviseを使用した方法は、この[記事](https://greg.molnar.io/blog/actioncable-devise-authentication/)で確認できます。

## 依存関係

Action Cableは、パブサブの内部処理を処理するためのサブスクリプションアダプターインターフェースを提供します。デフォルトでは、非同期、インライン、PostgreSQL、およびRedisアダプターが含まれています。新しいRailsアプリケーションのデフォルトアダプターは非同期（`async`）アダプターです。

Ruby側の処理は、[websocket-driver](https://github.com/faye/websocket-driver-ruby)、[nio4r](https://github.com/celluloid/nio4r)、および[concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby)をベースにしています。

## デプロイ

Action Cableは、WebSocketsとスレッドの組み合わせによって動作します。フレームワークのプラグインとユーザー指定のチャンネルの処理は、Rubyのネイティブスレッドサポートを利用して内部的に処理されます。これは、スレッドセーフティの問題がなければ、既存のRailsモデルを問題なく使用できることを意味します。

Action CableサーバーはRackソケットハイジャックAPIを実装しており、アプリケーションサーバーがマルチスレッドであるかどうかに関係なく、接続を管理するためのマルチスレッドパターンの使用を可能にします。

したがって、Action CableはUnicorn、Puma、Passengerなどの人気のあるサーバーと連携します。

## テスト

Action Cableの機能をテストする方法の詳細な手順については、[テストガイド](testing.html#testing-action-cable)を参照してください。
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
