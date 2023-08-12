**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fe858c0828e87f595c5d8c23c4b6326e
API専用アプリケーションに対してRailsを使用する方法
=====================================

このガイドでは、以下の内容を学ぶことができます:

* API専用アプリケーションに対してRailsが提供する機能
* ブラウザ機能を含まないようにRailsを設定する方法
* 使用するミドルウェアを決定する方法
* コントローラで使用するモジュールを決定する方法

--------------------------------------------------------------------------------

APIアプリケーションとは何ですか？
---------------------------

従来、人々がRailsを「API」として使用すると言った場合、Webアプリケーションと並行してプログラムからアクセス可能なAPIを提供することを意味していました。例えば、GitHubは[API](https://developer.github.com)を提供しており、独自のカスタムクライアントから使用することができます。

クライアントサイドのフレームワークの登場により、より多くの開発者がRailsを使用して、Webアプリケーションと他のネイティブアプリケーション間で共有されるバックエンドを構築しています。

例えば、Twitterは[公開API](https://developer.twitter.com/)をWebアプリケーションで使用しており、JSONリソースを消費する静的サイトとして構築されています。

Railsを使用して、フォームやリンクを介してサーバーと通信するHTMLを生成する代わりに、多くの開発者がWebアプリケーションを単なるAPIクライアントとして扱い、JSON APIを消費するHTMLとJavaScriptで配信しています。

このガイドでは、APIクライアントにJSONリソースを提供するRailsアプリケーションの構築について説明します。これには、クライアントサイドのフレームワークも含まれます。

なぜJSON APIにRailsを使用するのですか？
----------------------------

Railsを使用してJSON APIを構築する際に多くの人々が抱く最初の疑問は、「Railsを使用してJSONを出力するのはオーバーキルではないか？Sinatraのようなものを使用すべきではないか？」というものです。

非常にシンプルなAPIの場合、これは当てはまるかもしれません。しかし、非常にHTML重視のアプリケーションでも、ほとんどのアプリケーションのロジックはビューレイヤーの外に存在します。

Railsを使用する理由は、開発者が多くの些細な決定をする必要なく、迅速に開発を始めることができるデフォルトの設定を提供しているからです。

デフォルトのRailsミドルウェアスタックが提供する価値を示すために、以下にいくつかのRailsが提供する機能を見てみましょう。

ミドルウェアレイヤーで処理されるもの:

- リロード: Railsアプリケーションは透過的なリロードをサポートしています。アプリケーションが大きくなり、リクエストごとにサーバーを再起動することが不可能になっても、これは機能します。
- 開発モード: Railsアプリケーションは開発に適したスマートなデフォルトを備えており、本番時のパフォーマンスに影響を与えることなく、開発を快適に行うことができます。
- テストモード: 開発モードと同様です。
- ロギング: Railsアプリケーションはすべてのリクエストをログに記録します。開発時のログには、リクエスト環境、データベースクエリ、基本的なパフォーマンス情報などが含まれます。
- セキュリティ: Railsは[IPスーフィング攻撃](https://en.wikipedia.org/wiki/IP_address_spoofing)を検出して防止し、[タイミング攻撃](https://en.wikipedia.org/wiki/Timing_attack)に対しては暗号署名を処理することができます。IPスーフィング攻撃やタイミング攻撃が何かわからない？まさにその通りです。
- パラメータの解析: パラメータをURLエンコードされた文字列ではなくJSONで指定したいですか？問題ありません。RailsはJSONをデコードし、`params`で利用できるようにします。ネストされたURLエンコードされたパラメータを使用したいですか？それも可能です。
- 条件付きGET: Railsは条件付きの`GET` (`ETag`および`Last-Modified`) リクエストヘッダーを処理し、正しいレスポンスヘッダーとステータスコードを返します。コントローラで[`stale?`](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F)を使用するだけで、RailsがHTTPの詳細をすべて処理します。
- HEADリクエスト: Railsは`HEAD`リクエストを透過的に`GET`リクエストに変換し、ヘッダーのみを返します。これにより、すべてのRails APIで`HEAD`が確実に機能します。

これらは既存のRackミドルウェアを使用して構築することもできますが、このリストは、単なるJSONの生成であっても、デフォルトのRailsミドルウェアスタックが多くの価値を提供していることを示しています。

Action Packレイヤーで処理されるもの:

- リソースフルなルーティング: RESTfulなJSON APIを構築する場合、Railsのルーターを使用することが望ましいです。HTTPからコントローラへのクリーンで一貫したマッピングにより、APIをHTTPの観点でモデル化する必要がありません。
- URL生成: ルーティングの裏側にはURL生成があります。HTTPに基づく良いAPIにはURLが含まれます（例: [GitHub Gist API](https://docs.github.com/en/rest/reference/gists)）。
- ヘッダーとリダイレクトレスポンス: `head :no_content`や`redirect_to user_url(current_user)`は便利です。もちろん、手動でレスポンスヘッダーを追加することもできますが、なぜそうする必要がありますか？
- キャッシュ: Railsはページ、アクション、フラグメントのキャッシュを提供します。フラグメントキャッシュは、ネストされたJSONオブジェクトを構築する際に特に役立ちます。
- ベーシック認証、ダイジェスト認証、トークン認証: RailsはHTTP認証の3種類をサポートしています。
- インストルメンテーション: Railsには、アクションの処理、ファイルやデータの送信、リダイレクト、データベースクエリなど、さまざまなイベントに対して登録されたハンドラをトリガーするインストルメンテーションAPIがあります。各イベントのペイロードには、関連する情報が含まれます（アクション処理イベントの場合、コントローラ、アクション、パラメータ、リクエストフォーマット、リクエストメソッド、リクエストの完全なパスなど）。
- ジェネレータ: リソースを生成し、モデル、コントローラ、テストスタブ、ルートを一度のコマンドで作成して、さらに調整することができると便利です。マイグレーションなども同様です。
- プラグイン: 多くのサードパーティライブラリは、ライブラリとWebフレームワークを設定して結びつけるコストを削減または排除するためのRailsのサポートを提供しています。これには、デフォルトのジェネレータのオーバーライド、Rakeタスクの追加、Railsの選択（ロガーやキャッシュバックエンドなど）の尊重などが含まれます。
もちろん、Railsの起動プロセスは、すべての登録されたコンポーネントを結びつける役割も果たします。
たとえば、Railsの起動プロセスは、Active Recordの設定時に`config/database.yml`ファイルを使用します。

**短いバージョンは**：ビューレイヤーを削除しても、Railsのどの部分がまだ適用可能かを考えたことがないかもしれませんが、答えはほとんどすべてです。

基本的な設定
-----------------------

最初にAPIサーバーとして機能するRailsアプリケーションを構築する場合、より限定されたRailsのサブセットから始めて必要に応じて機能を追加できます。

### 新しいアプリケーションの作成

新しいAPI Railsアプリを生成できます：

```bash
$ rails new my_api --api
```

これにより、次の3つの主なことが行われます：

- 通常よりも制限されたミドルウェアセットでアプリケーションを構成します。具体的には、デフォルトではブラウザアプリケーションに主に有用なミドルウェア（クッキーサポートなど）は含まれません。
- `ApplicationController`を`ActionController::Base`ではなく`ActionController::API`から継承するように構成します。ミドルウェアと同様に、ブラウザアプリケーションで主に使用される機能を提供するAction Controllerモジュールは除外されます。
- 新しいリソースを生成するときに、ビュー、ヘルパー、アセットの生成をスキップするようにジェネレータを構成します。

### 新しいリソースの生成

新しく作成したAPIがリソースの生成をどのように処理するかを確認するために、新しいGroupリソースを作成してみましょう。各グループには名前があります。

```bash
$ bin/rails g scaffold Group name:string
```

スキャフォールドされたコードを使用する前に、データベーススキーマを更新する必要があります。

```bash
$ bin/rails db:migrate
```

これで`GroupsController`を開くと、API RailsアプリではJSONデータのみをレンダリングしていることに気付くはずです。インデックスアクションでは、`Group.all`をクエリして`@groups`というインスタンス変数に割り当て、`:json`オプションを使用して自動的にグループをJSONとしてレンダリングします。

```ruby
# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show update destroy ]

  # GET /groups
  def index
    @groups = Group.all

    render json: @groups
  end

  # GET /groups/1
  def show
    render json: @group
  end

  # POST /groups
  def create
    @group = Group.new(group_params)

    if @group.save
      render json: @group, status: :created, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name)
    end
end
```

最後に、Railsコンソールからデータベースにいくつかのグループを追加できます：

```irb
irb> Group.create(name: "Rails Founders")
irb> Group.create(name: "Rails Contributors")
```

アプリにデータがある状態で、サーバーを起動し、<http://localhost:3000/groups.json>を訪れると、JSONデータが表示されます。

```json
[
{"id":1, "name":"Rails Founders", "created_at": ...},
{"id":2, "name":"Rails Contributors", "created_at": ...}
]
```

既存のアプリケーションの変更
--------------------

既存のアプリケーションをAPIアプリケーションに変更する場合は、以下の手順を読んでください。

`config/application.rb`で、`Application`クラスの定義の先頭に次の行を追加します。

```ruby
config.api_only = true
```

`config/environments/development.rb`で、[`config.debug_exception_response_format`][]を設定して、開発モードでエラーが発生した場合のレスポンスで使用するフォーマットを設定します。

デバッグ情報を含むHTMLページをレンダリングするには、値に`:default`を使用します。

```ruby
config.debug_exception_response_format = :default
```

レスポンスフォーマットを保持したままデバッグ情報をレンダリングするには、値に`:api`を使用します。

```ruby
config.debug_exception_response_format = :api
```

`config.debug_exception_response_format`は、`config.api_only`がtrueに設定されている場合にデフォルトで`:api`に設定されます。

最後に、`app/controllers/application_controller.rb`の次のコードを変更します：

```ruby
class ApplicationController < ActionController::Base
end
```

次のように変更します：

```ruby
class ApplicationController < ActionController::API
end
```


ミドルウェアの選択
--------------------

APIアプリケーションには、デフォルトで次のミドルウェアが含まれています：

- `ActionDispatch::HostAuthorization`
- `Rack::Sendfile`
- `ActionDispatch::Static`
- `ActionDispatch::Executor`
- `ActionDispatch::ServerTiming`
- `ActiveSupport::Cache::Strategy::LocalCache::Middleware`
- `Rack::Runtime`
- `ActionDispatch::RequestId`
- `ActionDispatch::RemoteIp`
- `Rails::Rack::Logger`
- `ActionDispatch::ShowExceptions`
- `ActionDispatch::DebugExceptions`
- `ActionDispatch::ActionableExceptions`
- `ActionDispatch::Reloader`
- `ActionDispatch::Callbacks`
- `ActiveRecord::Migration::CheckPending`
- `Rack::Head`
- `Rack::ConditionalGet`
- `Rack::ETag`

詳細については、[内部ミドルウェア](rails_on_rack.html#internal-middleware-stack)のセクションを参照してください。

Active Recordを含む他のプラグインは、追加のミドルウェアを追加する場合があります。一般的に、これらのミドルウェアはビルドするアプリケーションのタイプには関係なく、API専用のRailsアプリケーションで意味をなします。
アプリケーション内のすべてのミドルウェアのリストを取得するには、次のコマンドを使用します。

```bash
$ bin/rails middleware
```

### Rack::Cacheの使用

Railsと一緒に使用する場合、`Rack::Cache`はエンティティとメタストアにRailsキャッシュストアを使用します。つまり、例えばRailsアプリにmemcacheを使用している場合、組み込みのHTTPキャッシュはmemcacheを使用します。

`Rack::Cache`を使用するには、まず`Gemfile`に`rack-cache` gemを追加し、`config.action_dispatch.rack_cache`を`true`に設定する必要があります。機能を有効にするために、コントローラで`stale?`を使用する必要があります。以下に`stale?`の使用例を示します。

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

`stale?`の呼び出しは、リクエストの`If-Modified-Since`ヘッダーと`@post.updated_at`を比較します。ヘッダーが最終更新日より新しい場合、このアクションは「304 Not Modified」レスポンスを返します。それ以外の場合、レスポンスをレンダリングし、`Last-Modified`ヘッダーを含めます。

通常、このメカニズムはクライアントごとに使用されます。`Rack::Cache`を使用すると、このキャッシュメカニズムをクライアント間で共有できます。`stale?`の呼び出しでクロスクライアントキャッシュを有効にできます。

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end
end
```

これにより、`Rack::Cache`はURLの`Last-Modified`値をRailsキャッシュに保存し、同じURLに対する後続の受信リクエストに`If-Modified-Since`ヘッダーを追加します。

HTTPセマンティクスを使用したページキャッシュと考えてください。

### Rack::Sendfileの使用

Railsコントローラ内で`send_file`メソッドを使用すると、`X-Sendfile`ヘッダーが設定されます。`Rack::Sendfile`は実際のファイル送信を担当します。

フロントエンドサーバが高速ファイル送信をサポートしている場合、`Rack::Sendfile`は実際のファイル送信作業をフロントエンドサーバにオフロードします。

この目的でフロントエンドサーバが使用するヘッダーの名前を[`config.action_dispatch.x_sendfile_header`][]を使用して適切な環境の設定ファイルに設定できます。

[Rack::Sendfileのドキュメント](https://www.rubydoc.info/gems/rack/Rack/Sendfile)で、一般的なフロントエンドとの`Rack::Sendfile`の使用方法について詳しく説明しています。

これらのヘッダーの値は、これらのサーバが高速ファイル送信をサポートするように設定された場合に使用できます。

```ruby
# Apacheとlighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

`Rack::Sendfile`のドキュメントの指示に従って、これらのオプションをサポートするようにサーバを設定してください。

### ActionDispatch::Requestの使用

`ActionDispatch::Request#params`は、クライアントからJSON形式のパラメータを受け取り、それをコントローラ内の`params`で利用できるようにします。

これを使用するには、クライアントがJSONエンコードされたパラメータを指定し、`Content-Type`を`application/json`としてリクエストを行う必要があります。

以下はjQueryの例です。

```js
jQuery.ajax({
  type: 'POST',
  url: '/people',
  dataType: 'json',
  contentType: 'application/json',
  data: JSON.stringify({ person: { firstName: "Yehuda", lastName: "Katz" } }),
  success: function(json) { }
});
```

`ActionDispatch::Request`は`Content-Type`を認識し、パラメータは次のようになります。

```ruby
{ person: { firstName: "Yehuda", lastName: "Katz" } }
```

### セッションミドルウェアの使用

セッション管理に使用される次のミドルウェアは、通常、セッションを必要としないAPIアプリから除外されています。ただし、APIクライアントの1つがブラウザである場合は、これらのいずれかを追加する必要があります。

- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

これらを追加するためのトリックは、デフォルトでは追加時に`session_options`が渡されるため、`session_store.rb`イニシャライザを追加して`use ActionDispatch::Session::CookieStore`を追加するだけでは通常どおりにセッションが機能しないことです（セッションは機能するかもしれませんが、セッションオプションは無視されます。つまり、セッションキーはデフォルトで`_session_id`になります）。

イニシャライザの代わりに、ミドルウェアがビルドされる前に（`config/application.rb`など）関連するオプションを設定し、次のように好みのミドルウェアに渡す必要があります。

```ruby
# これは下記のuseのためにsession_optionsを設定します
config.session_store :cookie_store, key: '_interslice_session'

# セッション管理には必須（session_storeに関係なく）
config.middleware.use ActionDispatch::Cookies

config.middleware.use config.session_store, config.session_options
```

### その他のミドルウェア

Railsには、特にAPIアプリケーションで使用したい他の多くのミドルウェアが付属しています。特にAPIクライアントの1つがブラウザである場合は、これらのミドルウェアのいずれかを使用することができます。

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`

これらのミドルウェアは次のように追加できます。

```ruby
config.middleware.use Rack::MethodOverride
```

### ミドルウェアの削除

API専用のミドルウェアセットにデフォルトで含まれている使用しないミドルウェアがある場合は、次のコマンドを使用して削除できます。
```ruby
config.middleware.delete ::Rack::Sendfile
```

これらのミドルウェアを削除すると、Action Controllerの特定の機能のサポートも削除されます。

コントローラーモジュールの選択
---------------------------

APIアプリケーション（`ActionController::API`を使用）は、デフォルトで次のコントローラーモジュールを持っています：

|   |   |
|---|---|
| `ActionController::UrlFor` | `url_for`や同様のヘルパーを利用できるようにします。 |
| `ActionController::Redirecting` | `redirect_to`のサポート。 |
| `AbstractController::Rendering`と`ActionController::ApiRendering` | レンダリングの基本的なサポート。 |
| `ActionController::Renderers::All` | `render :json`や関連するメソッドのサポート。 |
| `ActionController::ConditionalGet` | `stale?`のサポート。 |
| `ActionController::BasicImplicitRender` | 明示的なレスポンスがない場合に空のレスポンスを返すようにします。 |
| `ActionController::StrongParameters` | Active Modelのマスアサインメントと組み合わせてパラメータのフィルタリングをサポートします。 |
| `ActionController::DataStreaming` | `send_file`と`send_data`のサポート。 |
| `AbstractController::Callbacks` | `before_action`や同様のヘルパーのサポート。 |
| `ActionController::Rescue` | `rescue_from`のサポート。 |
| `ActionController::Instrumentation` | Action Controllerで定義された計測フックのサポート（詳細は[計測ガイド](active_support_instrumentation.html#action-controller)を参照してください）。 |
| `ActionController::ParamsWrapper` | パラメータハッシュをネストされたハッシュにラップし、POSTリクエストを送信する際にルート要素を指定する必要がなくなります。
| `ActionController::Head` | コンテンツのないレスポンス（ヘッダーのみ）を返すためのサポート。 |

他のプラグインは追加のモジュールを追加する場合があります。`ActionController::API`に含まれるすべてのモジュールのリストをrailsコンソールで取得できます：

```irb
irb> ActionController::API.ancestors - ActionController::Metal.ancestors
=> [ActionController::API,
    ActiveRecord::Railties::ControllerRuntime,
    ActionDispatch::Routing::RouteSet::MountedHelpers,
    ActionController::ParamsWrapper,
    ... ,
    AbstractController::Rendering,
    ActionView::ViewPaths]
```

### 他のモジュールの追加

すべてのAction Controllerモジュールは、依存するモジュールについて知っていますので、コントローラに任意のモジュールを含めることができます。すべての依存関係も含まれ、設定されます。

追加したい一般的なモジュールのいくつか：

- `AbstractController::Translation`：`l`と`t`のローカライゼーションと翻訳メソッドのサポート。
- 基本、ダイジェスト、またはトークンのHTTP認証のサポート：
  * `ActionController::HttpAuthentication::Basic::ControllerMethods`
  * `ActionController::HttpAuthentication::Digest::ControllerMethods`
  * `ActionController::HttpAuthentication::Token::ControllerMethods`
- `ActionView::Layouts`：レンダリング時のレイアウトのサポート。
- `ActionController::MimeResponds`：`respond_to`のサポート。
- `ActionController::Cookies`：`cookies`のサポート。署名付きおよび暗号化されたクッキーのサポートも含まれます。これにはクッキーミドルウェアが必要です。
- `ActionController::Caching`：APIコントローラのビューキャッシュのサポート。ただし、コントローラ内でキャッシュストアを次のように手動で指定する必要があります：

    ```ruby
    class ApplicationController < ActionController::API
      include ::ActionController::Caching
      self.cache_store = :mem_cache_store
    end
    ```

    Railsはこの設定を自動的に渡しません。

モジュールを追加する最適な場所は`ApplicationController`ですが、個々のコントローラにもモジュールを追加できます。
[`config.debug_exception_response_format`]: configuring.html#config-debug-exception-response-format
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
