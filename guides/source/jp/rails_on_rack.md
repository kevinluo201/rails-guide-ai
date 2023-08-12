**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 48f8290cbf9190673c32a3eb9777acba
Rack上のRails
=============

このガイドでは、RailsのRackとの統合と他のRackコンポーネントとのインターフェースについて説明します。

このガイドを読み終えると、以下のことがわかります。

* RailsアプリケーションでRackミドルウェアを使用する方法。
* Action Packの内部ミドルウェアスタック。
* カスタムミドルウェアスタックの定義方法。

--------------------------------------------------------------------------------

警告：このガイドは、Rackプロトコルやミドルウェア、URLマップ、`Rack::Builder`などのRackの基本的な知識を前提としています。

Rackの紹介
--------------------

Rackは、Rubyでウェブアプリケーションを開発するための最小限の、モジュラーで適応性のあるインターフェースを提供します。HTTPリクエストとレスポンスを可能な限りシンプルな方法でラップすることにより、ウェブサーバー、ウェブフレームワーク、およびその間のソフトウェア（いわゆるミドルウェア）のAPIを統一し、単一のメソッド呼び出しにまとめます。

Rackの動作原理について説明することは、このガイドの範囲外です。Rackの基本について詳しく知りたい場合は、以下の[リソース](#resources)セクションを参照してください。

Rack上のRails
-------------

### RailsアプリケーションのRackオブジェクト

`Rails.application`は、Railsアプリケーションの主要なRackアプリケーションオブジェクトです。Rack準拠のウェブサーバーは、Railsアプリケーションを提供するために`Rails.application`オブジェクトを使用する必要があります。

### `bin/rails server`

`bin/rails server`は、`Rack::Server`オブジェクトを作成し、ウェブサーバーを起動する基本的なジョブを行います。

以下は、`bin/rails server`が`Rack::Server`のインスタンスを作成する方法です。

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

`Rails::Server`は`Rack::Server`を継承し、次のように`Rack::Server#start`メソッドを呼び出します。

```ruby
class Server < ::Rack::Server
  def start
    # ...
    super
  end
end
```

### `rackup`

Railsの`bin/rails server`の代わりに`rackup`を使用するには、Railsアプリケーションのルートディレクトリの`config.ru`に次のコードを追加します。

```ruby
# Rails.root/config.ru
require_relative "config/environment"
run Rails.application
```

そして、サーバーを起動します。

```bash
$ rackup config.ru
```

さまざまな`rackup`オプションについて詳しく知りたい場合は、次のコマンドを実行します。

```bash
$ rackup --help
```

### 開発と自動リロード

ミドルウェアは一度だけロードされ、変更は監視されません。実行中のアプリケーションに変更を反映するには、サーバーを再起動する必要があります。

Action Dispatcherミドルウェアスタック
----------------------------------

Action Dispatcherの多くの内部コンポーネントは、Rackミドルウェアとして実装されています。`Rails::Application`は、さまざまな内部および外部のミドルウェアを組み合わせて完全なRails Rackアプリケーションを形成するために`ActionDispatch::MiddlewareStack`を使用します。

注意：`ActionDispatch::MiddlewareStack`は、`Rack::Builder`のRails版ですが、Railsの要件を満たすためにより柔軟性と機能が向上しています。

### ミドルウェアスタックの検査

Railsには、使用されているミドルウェアスタックを検査するための便利なコマンドがあります。

```bash
$ bin/rails middleware
```

新しく生成されたRailsアプリケーションでは、次のような結果が表示される場合があります。

```ruby
use ActionDispatch::HostAuthorization
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
use ActionDispatch::ServerTiming
use ActiveSupport::Cache::Strategy::LocalCache::Middleware
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use ActionDispatch::RemoteIp
use Sprockets::Rails::QuietAssets
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use WebConsole::Middleware
use ActionDispatch::DebugExceptions
use ActionDispatch::ActionableExceptions
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::Migration::CheckPending
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ContentSecurityPolicy::Middleware
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
use Rack::TempfileReaper
run MyApp::Application.routes
```

ここで表示されるデフォルトのミドルウェア（およびその他のいくつか）は、以下の[内部ミドルウェア](#internal-middleware-stack)セクションで要約されています。

### ミドルウェアスタックの設定

Railsは、`application.rb`または環境固有の設定ファイル`environments/<environment>.rb`を介して、ミドルウェアスタックにミドルウェアを追加、削除、変更するための簡単な設定インターフェース[`config.middleware`][]を提供しています。


#### ミドルウェアの追加

次のいずれかの方法を使用して、ミドルウェアスタックに新しいミドルウェアを追加できます。

* `config.middleware.use(new_middleware, args)` - 新しいミドルウェアをミドルウェアスタックの一番下に追加します。

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - 指定した既存のミドルウェアの前に新しいミドルウェアをミドルウェアスタックに追加します。

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - 指定した既存のミドルウェアの後に新しいミドルウェアをミドルウェアスタックに追加します。

```ruby
# config/application.rb

# Rack::BounceFaviconを一番下に追加
config.middleware.use Rack::BounceFavicon

# Lifo::CacheをActionDispatch::Executorの後に追加します。
# Lifo::Cacheに{ page_cache: false }引数を渡します。
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### ミドルウェアの交換

`config.middleware.swap`を使用して、ミドルウェアスタックの既存のミドルウェアを交換できます。

```ruby
# config/application.rb

# ActionDispatch::ShowExceptionsをLifo::ShowExceptionsで置き換える
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### ミドルウェアの移動

`config.middleware.move_before`および`config.middleware.move_after`を使用して、ミドルウェアスタック内の既存のミドルウェアを移動できます。

```ruby
# config/application.rb

# ActionDispatch::ShowExceptionsをLifo::ShowExceptionsの前に移動
config.middleware.move_before Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

```ruby
# config/application.rb

# ActionDispatch::ShowExceptionsをLifo::ShowExceptionsの後に移動
config.middleware.move_after Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

#### ミドルウェアの削除
アプリケーションの設定に次の行を追加してください：

```ruby
# config/application.rb
config.middleware.delete Rack::Runtime
```

そして、ミドルウェアスタックを検査すると、`Rack::Runtime`が含まれていないことがわかります。

```bash
$ bin/rails middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
...
run Rails.application.routes
```

セッション関連のミドルウェアを削除したい場合は、次の手順を実行してください：

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash
```

ブラウザ関連のミドルウェアを削除するには、

```ruby
# config/application.rb
config.middleware.delete Rack::MethodOverride
```

存在しないアイテムを削除しようとするとエラーが発生するようにするには、`delete!`を使用してください。

```ruby
# config/application.rb
config.middleware.delete! ActionDispatch::Executor
```

### 内部ミドルウェアスタック

Action Controllerの多くの機能はミドルウェアとして実装されています。以下のリストは、それぞれの目的を説明しています：

**`ActionDispatch::HostAuthorization`**

* DNSリバインディング攻撃から保護するために、リクエストを送信できるホストを明示的に許可します。設定手順については、[構成ガイド](configuring.html#actiondispatch-hostauthorization)を参照してください。

**`Rack::Sendfile`**

* サーバー固有のX-Sendfileヘッダーを設定します。[`config.action_dispatch.x_sendfile_header`][]オプションを使用してこれを設定します。


**`ActionDispatch::Static`**

* publicディレクトリから静的ファイルを提供するために使用されます。[`config.public_file_server.enabled`][]が`false`の場合は無効になります。


**`Rack::Lock`**

* `env["rack.multithread"]`フラグを`false`に設定し、アプリケーションをMutexでラップします。

**`ActionDispatch::Executor`**

* 開発中のスレッドセーフなコードリロードに使用されます。

**`ActionDispatch::ServerTiming`**

* リクエストのパフォーマンスメトリクスを含む[`Server-Timing`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server-Timing)ヘッダーを設定します。

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* メモリキャッシュに使用されます。このキャッシュはスレッドセーフではありません。

**`Rack::Runtime`**

* リクエストの実行にかかった時間（秒単位）を含むX-Runtimeヘッダーを設定します。

**`Rack::MethodOverride`**

* `params[:_method]`が設定されている場合、メソッドを上書きすることを許可します。これはPUTおよびDELETE HTTPメソッドをサポートするミドルウェアです。

**`ActionDispatch::RequestId`**

* レスポンスで一意の`X-Request-Id`ヘッダーを利用できるようにし、`ActionDispatch::Request#request_id`メソッドを有効にします。

**`ActionDispatch::RemoteIp`**

* IPスーフィング攻撃をチェックします。

**`Sprockets::Rails::QuietAssets`**

* アセットリクエストのロガー出力を抑制します。

**`Rails::Rack::Logger`**

* リクエストが開始したことをログに通知します。リクエストが完了した後、すべてのログをフラッシュします。

**`ActionDispatch::ShowExceptions`**

* アプリケーションによって返された例外をキャッチし、エンドユーザー向けの形式でラップする例外アプリを呼び出します。

**`ActionDispatch::DebugExceptions`**

* ローカルの場合、例外をログに記録し、デバッグページを表示する責任があります。

**`ActionDispatch::ActionableExceptions`**

* Railsのエラーページからアクションをディスパッチする方法を提供します。

**`ActionDispatch::Reloader`**

* 開発中のコードリロードを支援するための準備とクリーンアップのコールバックを提供します。

**`ActionDispatch::Callbacks`**

* リクエストのディスパッチ前と後に実行されるコールバックを提供します。

**`ActiveRecord::Migration::CheckPending`**

* 保留中のマイグレーションをチェックし、保留中のマイグレーションがある場合は`ActiveRecord::PendingMigrationError`を発生させます。

**`ActionDispatch::Cookies`**

* リクエストのためにクッキーを設定します。

**`ActionDispatch::Session::CookieStore`**

* セッションをクッキーに格納する責任があります。

**`ActionDispatch::Flash`**

* フラッシュキーを設定します。[`config.session_store`][]が値に設定されている場合にのみ使用できます。


**`ActionDispatch::ContentSecurityPolicy::Middleware`**

* Content-Security-Policyヘッダーを設定するためのDSLを提供します。

**`Rack::Head`**

* HEADリクエストを`GET`リクエストに変換し、それとして提供します。

**`Rack::ConditionalGet`**

* "条件付き`GET`"をサポートし、ページが変更されていない場合にサーバーが何も応答しないようにします。

**`Rack::ETag`**

* すべてのStringボディにETagヘッダーを追加します。ETagはキャッシュの検証に使用されます。

**`Rack::TempfileReaper`**

* マルチパートリクエストのバッファリングに使用される一時ファイルをクリーンアップします。

TIP: 上記のミドルウェアのいずれかをカスタムRackスタックで使用することができます。

リソース
---------

### Rackの学習

* [公式Rackウェブサイト](https://rack.github.io)
* [Rackの紹介](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### ミドルウェアの理解

* [RackミドルウェアについてのRailscast](http://railscasts.com/episodes/151-rack-middleware)
[`config.middleware`]: configuring.html#config-middleware
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.session_store`]: configuring.html#config-session-store
