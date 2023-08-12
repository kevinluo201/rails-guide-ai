**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b093936da01fde14532f4cead51234e1
アクティブサポートインストゥルメンテーション
==============================

アクティブサポートは、Rubyの言語拡張、ユーティリティ、その他のものを提供する、Railsのコアの一部です。その中には、Railsアプリケーションやフレームワーク自体内部のRubyコード内で発生する特定のアクションを計測するために使用できるインストゥルメンテーションAPIが含まれています。ただし、Railsに限定されるものではありません。必要に応じて、他のRubyスクリプトでも独立して使用することができます。

このガイドでは、アクティブサポートのインストゥルメンテーションAPIを使用して、Railsや他のRubyコード内のイベントを計測する方法について学びます。

このガイドを読み終えると、以下のことがわかります：

* インストゥルメンテーションが提供するもの
* フックにサブスクライバを追加する方法
* ブラウザでインストゥルメンテーションのタイミングを表示する方法
* インストゥルメンテーションのためのRailsフレームワーク内のフック
* カスタムインストゥルメンテーションの実装方法

--------------------------------------------------------------------------------

インストゥルメンテーションの紹介
-------------------------------

アクティブサポートが提供するインストゥルメンテーションAPIを使用すると、開発者は他の開発者がフックにフックすることができるフックを提供することができます。Railsフレームワーク内には、これらのフックがいくつかあります。このAPIを使用すると、開発者は自分のアプリケーションや他のRubyコード内で特定のイベントが発生したときに通知を受けることができます。

たとえば、Active Record内には、データベース上でActive RecordがSQLクエリを使用するたびに呼び出される[フック](#sql-active-record)があります。このフックは**サブスクライブ**され、特定のアクション中のクエリの数を追跡するために使用することができます。また、コントローラのアクションの処理に関する[別のフック](#process-action-action-controller)もあります。これは、特定のアクションがどれくらいの時間を要したかを追跡するために使用することができます。

また、後でサブスクライブすることができるアプリケーション内で[独自のイベント](#creating-custom-events)を作成することもできます。

イベントにサブスクライブする
-----------------------

イベントにサブスクライブするのは簡単です。[`ActiveSupport::Notifications.subscribe`][]を使用して、通知をリッスンするためのブロックを使用します。

ブロックは以下の引数を受け取ります：

* イベントの名前
* 開始時刻
* 終了時刻
* イベントを発生させたインストゥルメンタの一意のID
* イベントのペイロード

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # あなた自身のカスタムな処理
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 2019-05-05 13:43:57 -0800, finished: 2019-05-05 13:43:58 -0800)
end
```

`started`と`finished`の正確な経過時間を計算するために`started`と`finished`の正確な経過時間を計算するために`ActiveSupport::Notifications.monotonic_subscribe`[]を使用する場合は、上記と同じ引数がブロックに渡されますが、`started`と`finished`は壁時計の時間ではなく、正確な単調増加の時間を持つ値になります。

```ruby
ActiveSupport::Notifications.monotonic_subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # あなた自身のカスタムな処理
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 1560978.425334, finished: 1560979.429234)
end
```

毎回ブロック引数を定義するのは面倒です。[`ActiveSupport::Notifications::Event`][]を使用して、ブロック引数から[`ActiveSupport::Notifications::Event`][]を簡単に作成できます。

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (ミリ秒単位)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

また、1つの引数のみを受け取るブロックを渡すこともできます。この場合、イベントオブジェクトが渡されます。

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |event|
  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (ミリ秒単位)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

正規表現に一致するイベントにもサブスクライブすることができます。これにより、複数のイベントに一度にサブスクライブすることができます。たとえば、`ActionController`からのすべてのイベントにサブスクライブするには、次のようにします。

```ruby
ActiveSupport::Notifications.subscribe(/action_controller/) do |*args|
  # ActionControllerのすべてのイベントを調査する
end
```


ブラウザでインストゥルメンテーションのタイミングを表示する
-------------------------------------------------

Railsは、タイミング情報をWebブラウザで利用できるようにするために、[Server Timing](https://www.w3.org/TR/server-timing/)の標準を実装しています。有効にするには、環境設定（通常は`development.rb`が最も使用されるため）を編集して、次のようにします。

```ruby
  config.server_timing = true
```

設定が完了したら（サーバーを再起動することも含む）、ブラウザの開発者ツールペインに移動し、ネットワークを選択してページをリロードします。その後、Railsサーバーへのリクエストを選択すると、タイミングタブでサーバータイミングが表示されます。これを行う例については、[Firefoxのドキュメント](https://firefox-source-docs.mozilla.org/devtools-user/network_monitor/request_details/index.html#server-timing)を参照してください。

Railsフレームワークのフック
---------------------

Ruby on Railsフレームワーク内には、一般的なイベントに対して提供されるフックがいくつかあります。これらのイベントとそのペイロードについては、以下で詳細に説明します。
### アクションコントローラー

#### `start_processing.action_controller`

| キー           | 値                                                       |
| ------------- | --------------------------------------------------------- |
| `:controller` | コントローラー名                                         |
| `:action`     | アクション名                                            |
| `:params`     | フィルタリングされていないリクエストパラメータのハッシュ |
| `:headers`    | リクエストヘッダー                                       |
| `:format`     | html/js/json/xml など                                    |
| `:method`     | HTTP リクエストの動詞                                    |
| `:path`       | リクエストパス                                           |

```ruby
{
  controller: "PostsController",
  action: "new",
  params: { "action" => "new", "controller" => "posts" },
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts/new"
}
```

#### `process_action.action_controller`

| キー             | 値                                                       |
| --------------- | --------------------------------------------------------- |
| `:controller`   | コントローラー名                                         |
| `:action`       | アクション名                                            |
| `:params`       | フィルタリングされていないリクエストパラメータのハッシュ |
| `:headers`      | リクエストヘッダー                                       |
| `:format`       | html/js/json/xml など                                    |
| `:method`       | HTTP リクエストの動詞                                    |
| `:path`         | リクエストパス                                           |
| `:request`      | [`ActionDispatch::Request`][] オブジェクト               |
| `:response`     | [`ActionDispatch::Response`][] オブジェクト              |
| `:status`       | HTTP ステータスコード                                    |
| `:view_runtime` | ビューでの実行時間（ミリ秒）                             |
| `:db_runtime`   | データベースクエリの実行時間（ミリ秒）                   |

```ruby
{
  controller: "PostsController",
  action: "index",
  params: {"action" => "index", "controller" => "posts"},
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts",
  request: #<ActionDispatch::Request:0x00007ff1cb9bd7b8>,
  response: #<ActionDispatch::Response:0x00007f8521841ec8>,
  status: 200,
  view_runtime: 46.848,
  db_runtime: 0.157
}
```

#### `send_file.action_controller`

| キー     | 値                           |
| ------- | --------------------------- |
| `:path` | ファイルへの完全なパス       |

呼び出し元によって追加のキーが追加される場合があります。

#### `send_data.action_controller`

`ActionController` はペイロードに特定の情報を追加しません。すべてのオプションはペイロードに渡されます。

#### `redirect_to.action_controller`

| キー         | 値                                    |
| ----------- | ---------------------------------------- |
| `:status`   | HTTP レスポンスコード                       |
| `:location` | リダイレクト先の URL                       |
| `:request`  | [`ActionDispatch::Request`][] オブジェクト |

```ruby
{
  status: 302,
  location: "http://localhost:3000/posts/new",
  request: <ActionDispatch::Request:0x00007ff1cb9bd7b8>
}
```

#### `halted_callback.action_controller`

| キー       | 値                         |
| --------- | ----------------------------- |
| `:filter` | アクションを停止したフィルター |

```ruby
{
  filter: ":halting_filter"
}
```

#### `unpermitted_parameters.action_controller`

| キー           | 値                                                                         |
| ------------- | ----------------------------------------------------------------------------- |
| `:keys`       | 許可されていないキー                                                          |
| `:context`    | 以下のキーを持つハッシュ: `:controller`, `:action`, `:params`, `:request` |

### アクションコントローラー — キャッシュ

#### `write_fragment.action_controller`

| キー    | 値            |
| ------ | ---------------- |
| `:key` | 完全なキー |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `read_fragment.action_controller`

| キー    | 値            |
| ------ | ---------------- |
| `:key` | 完全なキー |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `expire_fragment.action_controller`

| キー    | 値            |
| ------ | ---------------- |
| `:key` | 完全なキー |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `exist_fragment?.action_controller`

| キー    | 値            |
| ------ | ---------------- |
| `:key` | 完全なキー |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### アクションディスパッチ

#### `process_middleware.action_dispatch`

| キー           | 値                  |
| ------------- | ---------------------- |
| `:middleware` | ミドルウェアの名前 |

#### `redirect.action_dispatch`

| キー         | 値                                    |
| ----------- | ---------------------------------------- |
| `:status`   | HTTP レスポンスコード                       |
| `:location` | リダイレクト先の URL                       |
| `:request`  | [`ActionDispatch::Request`][] オブジェクト |

#### `request.action_dispatch`

| キー         | 値                                    |
| ----------- | ---------------------------------------- |
| `:request`  | [`ActionDispatch::Request`][] オブジェクト |

### アクションビュー

#### `render_template.action_view`

| キー           | 値                              |
| ------------- | ---------------------------------- |
| `:identifier` | テンプレートへの完全なパス         |
| `:layout`     | 適用されるレイアウト               |
| `:locals`     | テンプレートに渡されるローカル変数 |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/index.html.erb",
  layout: "layouts/application",
  locals: { foo: "bar" }
}
```

#### `render_partial.action_view`

| キー           | 値                              |
| ------------- | ---------------------------------- |
| `:identifier` | テンプレートへの完全なパス         |
| `:locals`     | テンプレートに渡されるローカル変数 |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_form.html.erb",
  locals: { foo: "bar" }
}
```

#### `render_collection.action_view`

| キー           | 値                                 |
| ------------- | ------------------------------------- |
| `:identifier` | テンプレートへの完全なパス                 |
| `:count`      | コレクションのサイズ                    |
| `:cache_hits` | キャッシュから取得されたパーシャルの数 |

`:cache_hits` キーは、コレクションが `cached: true` でレンダリングされる場合にのみ含まれます。
```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_post.html.erb",
  count: 3,
  cache_hits: 0
}
```

#### `render_layout.action_view`

| キー           | 値                     |
| ------------- | --------------------- |
| `:identifier` | テンプレートのフルパス |


```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/layouts/application.html.erb"
}
```


### Active Record

#### `sql.active_record`

| キー                  | 値                                      |
| -------------------- | ---------------------------------------- |
| `:sql`               | SQLステートメント                         |
| `:name`              | 操作の名前                               |
| `:connection`        | コネクションオブジェクト                   |
| `:binds`             | バインドパラメータ                       |
| `:type_casted_binds` | 型変換されたバインドパラメータ             |
| `:statement_name`    | SQLステートメントの名前                   |
| `:cached`            | キャッシュされたクエリが使用された場合に `true` が追加されます |

アダプタは独自のデータを追加することもあります。

```ruby
{
  sql: "SELECT \"posts\".* FROM \"posts\" ",
  name: "Post Load",
  connection: <ActiveRecord::ConnectionAdapters::SQLite3Adapter:0x00007f9f7a838850>,
  binds: [<ActiveModel::Attribute::WithCastValue:0x00007fe19d15dc00>],
  type_casted_binds: [11],
  statement_name: nil
}
```

#### `strict_loading_violation.active_record`

このイベントは、[`config.active_record.action_on_strict_loading_violation`][] が `:log` に設定されている場合にのみ発生します。

| キー           | 値                                            |
| ------------- | ------------------------------------------------ |
| `:owner`      | `strict_loading` が有効になっているモデル          |
| `:reflection` | ロードを試みた関連のリフレクション               |


#### `instantiation.active_record`

| キー              | 値                                      |
| ---------------- | ----------------------------------------- |
| `:record_count`  | インスタンス化されたレコードの数           |
| `:class_name`    | レコードのクラス                         |

```ruby
{
  record_count: 1,
  class_name: "User"
}
```

### Action Mailer

#### `deliver.action_mailer`

| キー                   | 値                                                |
| --------------------- | ---------------------------------------------------- |
| `:mailer`             | メーラークラスの名前                                 |
| `:message_id`         | メッセージのID、Mail gem によって生成される           |
| `:subject`            | メールの件名                                        |
| `:to`                 | メールの宛先アドレス                                 |
| `:from`               | メールの送信元アドレス                               |
| `:bcc`                | メールのBCCアドレス                                  |
| `:cc`                 | メールのCCアドレス                                   |
| `:date`               | メールの日付                                        |
| `:mail`               | メールのエンコードされた形式                          |
| `:perform_deliveries` | このメッセージの配信が行われるかどうか                 |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails Guides",
  to: ["users@rails.com", "dhh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "...", # 省略
  perform_deliveries: true
}
```

#### `process.action_mailer`

| キー           | 値                     |
| ------------- | ------------------------ |
| `:mailer`     | メーラークラスの名前 |
| `:action`     | アクション               |
| `:args`       | 引数                     |

```ruby
{
  mailer: "Notification",
  action: "welcome_email",
  args: []
}
```

### Active Support — Caching

#### `cache_read.active_support`

| キー                | 値                   |
| ------------------ | ----------------------- |
| `:key`             | ストアで使用されるキー   |
| `:store`           | ストアクラスの名前       |
| `:hit`             | この読み取りがヒットした場合は `true` |
| `:super_operation` | [`fetch`][ActiveSupport::Cache::Store#fetch] で読み取りが行われた場合は `:fetch` |

#### `cache_read_multi.active_support`

| キー                | 値                   |
| ------------------ | ----------------------- |
| `:key`             | ストアで使用されるキー   |
| `:store`           | ストアクラスの名前       |
| `:hits`            | キャッシュヒットのキー   |
| `:super_operation` | [`fetch_multi`][ActiveSupport::Cache::Store#fetch_multi] で読み取りが行われた場合は `:fetch_multi` |

#### `cache_generate.active_support`

このイベントは、[`fetch`][ActiveSupport::Cache::Store#fetch] がブロックとともに呼び出された場合にのみ発生します。

| キー      | 値                   |
| -------- | ----------------------- |
| `:key`   | ストアで使用されるキー   |
| `:store` | ストアクラスの名前       |

`fetch` に渡されたオプションは、ストアへの書き込み時にペイロードとマージされます。

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_fetch_hit.active_support`

このイベントは、[`fetch`][ActiveSupport::Cache::Store#fetch] がブロックとともに呼び出された場合にのみ発生します。

| キー      | 値                   |
| -------- | ----------------------- |
| `:key`   | ストアで使用されるキー   |
| `:store` | ストアクラスの名前       |

`fetch` に渡されたオプションは、ペイロードとマージされます。

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write.active_support`

| キー      | 値                   |
| -------- | ----------------------- |
| `:key`   | ストアで使用されるキー   |
| `:store` | ストアクラスの名前       |

キャッシュストアは独自のデータを追加することもあります。

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write_multi.active_support`

| キー      | 値                                |
| -------- | ------------------------------------ |
| `:key`   | ストアに書き込まれたキーと値           |
| `:store` | ストアクラスの名前                   |
#### `cache_increment.active_support`

このイベントは、[`MemCacheStore`][ActiveSupport::Cache::MemCacheStore]または[`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore]を使用している場合にのみ発生します。

| キー       | 値                     |
| --------- | ----------------------- |
| `:key`    | ストアで使用されるキー   |
| `:store`  | ストアクラスの名前      |
| `:amount` | インクリメント量        |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 99
}
```

#### `cache_decrement.active_support`

このイベントは、MemcachedまたはRedisキャッシュストアを使用している場合にのみ発生します。

| キー       | 値                     |
| --------- | ----------------------- |
| `:key`    | ストアで使用されるキー   |
| `:store`  | ストアクラスの名前      |
| `:amount` | デクリメント量        |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 1
}
```

#### `cache_delete.active_support`

| キー      | 値                     |
| -------- | ----------------------- |
| `:key`   | ストアで使用されるキー   |
| `:store` | ストアクラスの名前      |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_delete_multi.active_support`

| キー      | 値                     |
| -------- | ----------------------- |
| `:key`   | ストアで使用されるキー   |
| `:store` | ストアクラスの名前      |

#### `cache_delete_matched.active_support`

このイベントは、[`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore]、[`FileStore`][ActiveSupport::Cache::FileStore]、または[`MemoryStore`][ActiveSupport::Cache::MemoryStore]を使用している場合にのみ発生します。

| キー      | 値                     |
| -------- | ----------------------- |
| `:key`   | 使用されるキーパターン   |
| `:store` | ストアクラスの名前      |

```ruby
{
  key: "posts/*",
  store: "ActiveSupport::Cache::RedisCacheStore"
}
```

#### `cache_cleanup.active_support`

このイベントは、[`MemoryStore`][ActiveSupport::Cache::MemoryStore]を使用している場合にのみ発生します。

| キー      | 値                                         |
| -------- | --------------------------------------------- |
| `:store` | ストアクラスの名前                       |
| `:size`  | クリーンアップ前のキャッシュのエントリ数 |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  size: 9001
}
```

#### `cache_prune.active_support`

このイベントは、[`MemoryStore`][ActiveSupport::Cache::MemoryStore]を使用している場合にのみ発生します。

| キー      | 値                                         |
| -------- | --------------------------------------------- |
| `:store` | ストアクラスの名前                       |
| `:key`   | キャッシュのターゲットサイズ（バイト単位）          |
| `:from`  | プルーニング前のキャッシュのサイズ（バイト単位）     |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  key: 5000,
  from: 9001
}
```

#### `cache_exist?.active_support`

| キー      | 値                     |
| -------- | ----------------------- |
| `:key`   | ストアで使用されるキー   |
| `:store` | ストアクラスの名前      |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```


### Active Support — メッセージ

#### `message_serializer_fallback.active_support`

| キー             | 値                         |
| --------------- | ----------------------------- |
| `:serializer`   | プライマリ（意図された）シリアライザ |
| `:fallback`     | フォールバック（実際の）シリアライザ  |
| `:serialized`   | シリアライズされた文字列             |
| `:deserialized` | デシリアライズされた値            |

```ruby
{
  serializer: :json_allow_marshal,
  fallback: :marshal,
  serialized: "\x04\b{\x06I\"\nHello\x06:\x06ETI\"\nWorld\x06;\x00T",
  deserialized: { "Hello" => "World" },
}
```

### Active Job

#### `enqueue_at.active_job`

| キー          | 値                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | ジョブを処理するQueueAdapterオブジェクト |
| `:job`       | ジョブオブジェクト                             |

#### `enqueue.active_job`

| キー          | 値                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | ジョブを処理するQueueAdapterオブジェクト |
| `:job`       | ジョブオブジェクト                             |

#### `enqueue_retry.active_job`

| キー          | 値                                  |
| ------------ | -------------------------------------- |
| `:job`       | ジョブオブジェクト                             |
| `:adapter`   | ジョブを処理するQueueAdapterオブジェクト |
| `:error`     | リトライの原因となったエラー        |
| `:wait`      | リトライの遅延                 |

#### `enqueue_all.active_job`

| キー          | 値                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | ジョブを処理するQueueAdapterオブジェクト |
| `:jobs`      | ジョブオブジェクトの配列                |

#### `perform_start.active_job`

| キー          | 値                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | ジョブを処理するQueueAdapterオブジェクト |
| `:job`       | ジョブオブジェクト                             |

#### `perform.active_job`

| キー           | 値                                         |
| ------------- | --------------------------------------------- |
| `:adapter`    | ジョブを処理するQueueAdapterオブジェクト        |
| `:job`        | ジョブオブジェクト                                    |
| `:db_runtime` | データベースクエリの実行にかかった時間（ミリ秒単位） |

#### `retry_stopped.active_job`

| キー          | 値                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | ジョブを処理するQueueAdapterオブジェクト |
| `:job`       | ジョブオブジェクト                             |
| `:error`     | リトライの原因となったエラー        |

#### `discard.active_job`

| キー          | 値                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | ジョブを処理するQueueAdapterオブジェクト |
| `:job`       | ジョブオブジェクト                             |
| `:error`     | 破棄の原因となったエラー      |
### Action Cable

#### `perform_action.action_cable`

| キー              | 値                        |
| ---------------- | ------------------------- |
| `:channel_class` | チャネルクラスの名前      |
| `:action`        | アクション                |
| `:data`          | データのハッシュ          |

#### `transmit.action_cable`

| キー              | 値                        |
| ---------------- | ------------------------- |
| `:channel_class` | チャネルクラスの名前      |
| `:data`          | データのハッシュ          |
| `:via`           | 経由                      |

#### `transmit_subscription_confirmation.action_cable`

| キー              | 値                        |
| ---------------- | ------------------------- |
| `:channel_class` | チャネルクラスの名前      |

#### `transmit_subscription_rejection.action_cable`

| キー              | 値                        |
| ---------------- | ------------------------- |
| `:channel_class` | チャネルクラスの名前      |

#### `broadcast.action_cable`

| キー             | 値                   |
| --------------- | -------------------- |
| `:broadcasting` | 名前付きのブロードキャスト |
| `:message`      | メッセージのハッシュ   |
| `:coder`        | コーダー              |

### Active Storage

#### `preview.active_storage`

| キー          | 値               |
| ------------ | ------------------- |
| `:key`       | セキュアトークン    |

#### `transform.active_storage`

#### `analyze.active_storage`

| キー          | 値                          |
| ------------ | ------------------------------ |
| `:analyzer`  | アナライザーの名前、例：ffprobe |

### Active Storage — Storage Service

#### `service_upload.active_storage`

| キー          | 値                        |
| ------------ | ---------------------------- |
| `:key`       | セキュアトークン             |
| `:service`   | サービスの名前              |
| `:checksum`  | データの整合性を確保するためのチェックサム |

#### `service_streaming_download.active_storage`

| キー          | 値               |
| ------------ | ------------------- |
| `:key`       | セキュアトークン    |
| `:service`   | サービスの名前     |

#### `service_download_chunk.active_storage`

| キー          | 値                           |
| ------------ | ------------------------------- |
| `:key`       | セキュアトークン                |
| `:service`   | サービスの名前                 |
| `:range`     | 読み取ろうとしたバイト範囲      |

#### `service_download.active_storage`

| キー          | 値               |
| ------------ | ------------------- |
| `:key`       | セキュアトークン    |
| `:service`   | サービスの名前     |

#### `service_delete.active_storage`

| キー          | 値               |
| ------------ | ------------------- |
| `:key`       | セキュアトークン    |
| `:service`   | サービスの名前     |

#### `service_delete_prefixed.active_storage`

| キー          | 値               |
| ------------ | ------------------- |
| `:prefix`    | キーのプレフィックス |
| `:service`   | サービスの名前     |

#### `service_exist.active_storage`

| キー          | 値                       |
| ------------ | --------------------------- |
| `:key`       | セキュアトークン            |
| `:service`   | サービスの名前             |
| `:exist`     | ファイルまたはブロブが存在するかどうか |

#### `service_url.active_storage`

| キー          | 値               |
| ------------ | ------------------- |
| `:key`       | セキュアトークン    |
| `:service`   | サービスの名前     |
| `:url`       | 生成されたURL       |

#### `service_update_metadata.active_storage`

このイベントは、Google Cloud Storageサービスを使用している場合にのみ発生します。

| キー             | 値                            |
| --------------- | -------------------------------- |
| `:key`          | セキュアトークン                 |
| `:service`      | サービスの名前                   |
| `:content_type` | HTTPの`Content-Type`フィールド    |
| `:disposition`  | HTTPの`Content-Disposition`フィールド |

### Action Mailbox

#### `process.action_mailbox`

| キー              | 値                                                  |
| -----------------| ------------------------------------------------------ |
| `:mailbox`       | [`ActionMailbox::Base`][]を継承したMailboxクラスのインスタンス |
| `:inbound_email` | 処理されているインバウンドメールに関するデータのハッシュ |

```ruby
{
  mailbox: #<RepliesMailbox:0x00007f9f7a8388>,
  inbound_email: {
    id: 1,
    message_id: "0CB459E0-0336-41DA-BC88-E6E28C697DDB@37signals.com",
    status: "processing"
  }
}
```


### Railties

#### `load_config_initializer.railties`

| キー            | 値                                               |
| -------------- | --------------------------------------------------- |
| `:initializer` | `config/initializers`内のロードされたイニシャライザのパス |

### Rails

#### `deprecation.rails`

| キー                    | 値                                                 |
| ---------------------- | ------------------------------------------------------|
| `:message`             | 廃止予定の警告メッセージ                               |
| `:callstack`           | 廃止予定の元の呼び出し元                               |
| `:gem_name`            | 廃止予定を報告しているgemの名前                        |
| `:deprecation_horizon` | 廃止予定の動作が削除されるバージョン                   |

例外
----------

計測中に例外が発生した場合、ペイロードに関する情報が含まれます。

| キー                 | 値                                                          |
| ------------------- | -------------------------------------------------------------- |
| `:exception`        | 2つの要素からなる配列。例外クラス名とメッセージ                 |
| `:exception_object` | 例外オブジェクト                                               |

カスタムイベントの作成
----------------------

独自のイベントを追加することも簡単です。Active Supportがすべての重い作業を代行してくれます。単に[`ActiveSupport::Notifications.instrument`][]を`name`、`payload`、およびブロックと共に呼び出すだけです。ブロックが返った後に通知が送信されます。Active Supportは開始時間と終了時間を生成し、計測器の固有のIDを追加します。`instrument`呼び出しに渡されたすべてのデータがペイロードに含まれます。
以下は例です：

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data do
  # ここでカスタムの処理を行います
end
```

これで、次のようにこのイベントをリッスンできます：

```ruby
ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

また、ブロックを渡さずに`instrument`を呼び出すこともできます。これにより、他のメッセージング用途でインストルメンテーションインフラストラクチャを活用することができます。

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data

ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

独自のイベントを定義する際には、Railsの規約に従う必要があります。フォーマットは`event.library`です。アプリケーションがツイートを送信している場合、`tweet.twitter`という名前のイベントを作成する必要があります。
[`ActiveSupport::Notifications::Event`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications/Event.html
[`ActiveSupport::Notifications.monotonic_subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-monotonic_subscribe
[`ActiveSupport::Notifications.subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-subscribe
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`ActionDispatch::Response`]: https://api.rubyonrails.org/classes/ActionDispatch/Response.html
[`config.active_record.action_on_strict_loading_violation`]: configuring.html#config-active-record-action-on-strict-loading-violation
[ActiveSupport::Cache::FileStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[ActiveSupport::Cache::MemCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemoryStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[ActiveSupport::Cache::RedisCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#fetch_multi]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch_multi
[`ActionMailbox::Base`]: https://api.rubyonrails.org/classes/ActionMailbox/Base.html
[`ActiveSupport::Notifications.instrument`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-instrument
