**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: df23e2b31bd56973a30f38f5a1c29b52
Ruby on Rails 5.0 リリースノート
===============================

Rails 5.0 のハイライト：

* Action Cable
* Rails API
* Active Record Attributes API
* テストランナー
* Rake ではなく `rails` CLI の排他的な使用
* Sprockets 3
* Turbolinks 5
* Ruby 2.2.2+ が必要です

これらのリリースノートは主要な変更のみをカバーしています。さまざまなバグ修正や変更については、changelog を参照するか、GitHub 上のメインの Rails リポジトリの [コミットのリスト](https://github.com/rails/rails/commits/5-0-stable) をチェックしてください。

--------------------------------------------------------------------------------

Rails 5.0 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合は、アップグレードする前に十分なテストカバレッジを持つことが重要です。また、Rails 5.0 への更新を試みる前に、まず Rails 4.2 にアップグレードし、アプリケーションが予想どおりに動作することを確認してください。アップグレード時に注意するべき事項のリストは、[Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0) ガイドで入手できます。


主な機能
--------------

### Action Cable

Action Cable は、Rails 5 で導入された新しいフレームワークです。これにより、[WebSockets](https://en.wikipedia.org/wiki/WebSocket) を他の Rails アプリケーションとシームレスに統合することができます。

Action Cable は、リアルタイムの機能を、Rails アプリケーションの他の部分と同じスタイルと形式で Ruby で記述することができます。また、パフォーマンスとスケーラビリティも備えています。これは、クライアント側の JavaScript フレームワークとサーバ側の Ruby フレームワークの両方を提供するフルスタックのオファリングです。Active Record や選択した ORM で記述されたフルドメインモデルにアクセスすることができます。

詳細については、[Action Cable の概要](action_cable_overview.html) ガイドを参照してください。

### API アプリケーション

Rails は、スリム化された API 専用アプリケーションを作成するために使用することができます。
これは、[Twitter](https://dev.twitter.com) や [GitHub](https://developer.github.com) API のような公開向けおよびカスタムアプリケーション向けの API を提供するために役立ちます。

次のコマンドを使用して、新しい API Rails アプリを生成できます：

```bash
$ rails new my_api --api
```
これにより、次の3つの主なことが行われます：

- アプリケーションを通常よりも制限されたミドルウェアのセットで開始するように設定します。具体的には、デフォルトではブラウザアプリケーションに主に有用なミドルウェア（クッキーサポートなど）は含まれません。
- `ApplicationController`を`ActionController::Base`ではなく`ActionController::API`から継承するようにします。ミドルウェアと同様に、これにより、ブラウザアプリケーションで主に使用される機能を提供するAction Controllerモジュールが除外されます。
- 新しいリソースを生成する際に、ビュー、ヘルパー、アセットの生成をスキップするようにジェネレータを設定します。

このアプリケーションは、APIの基盤を提供し、その後、アプリケーションのニーズに応じて機能を組み込むように[設定することができます](api_app.html)。

詳細については、[API専用アプリケーションのRailsの使用方法](api_app.html)ガイドを参照してください。

### Active Record属性API

モデルにタイプ付きの属性を定義します。必要に応じて既存の属性のタイプを上書きします。
これにより、モデルに割り当てられたときに値がSQLに変換される方法を制御することができます。
また、`ActiveRecord::Base.where`に渡される値の動作も変更されます。これにより、Active Recordの多くの部分でドメインオブジェクトを使用できるようになり、実装の詳細やモンキーパッチに頼る必要がありません。

これによって実現できることの一部：

- Active Recordによって検出されるタイプを上書きできます。
- デフォルト値も指定できます。
- 属性はデータベースのカラムでバックアップする必要はありません。

```ruby
# db/schema.rb
create_table :store_listings, force: true do |t|
  t.decimal :price_in_cents
  t.string :my_string, default: "original default"
end
```

```ruby
# app/models/store_listing.rb
class StoreListing < ActiveRecord::Base
end
```

```ruby
store_listing = StoreListing.new(price_in_cents: '10.1')

# before
store_listing.price_in_cents # => BigDecimal.new(10.1)
StoreListing.new.my_string # => "original default"

class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer # カスタムタイプ
  attribute :my_string, :string, default: "new default" # デフォルト値
  attribute :my_default_proc, :datetime, default: -> { Time.now } # デフォルト値
  attribute :field_without_db_column, :integer, array: true
end

# after
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes # => {field_without_db_column: [1, 2, 3]}
```
**カスタムタイプの作成:**

値のタイプで定義されたメソッドに応答する限り、独自のカスタムタイプを定義することができます。メソッド`deserialize`または`cast`は、データベースやコントローラからの生の入力とともに、タイプオブジェクトで呼び出されます。これは、Moneyデータなどのカスタム変換を行う場合に便利です。

**クエリの実行:**

`ActiveRecord::Base.where`が呼び出されると、モデルクラスで定義されたタイプが使用され、値がSQLに変換されるために、タイプオブジェクトで`serialize`が呼び出されます。

これにより、オブジェクトはSQLクエリを実行する際に値を変換する方法を指定できます。

**Dirty Tracking（変更の追跡）:**

属性のタイプは、Dirty Tracking（変更の追跡）の方法を変更することができます。

詳細な説明については、[ドキュメント](https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html)を参照してください。


### テストランナー

Railsからテストを実行する機能を強化するために、新しいテストランナーが導入されました。
このテストランナーを使用するには、単純に`bin/rails test`と入力します。

テストランナーは、`RSpec`、`minitest-reporters`、`maxitest`などに触発されています。
以下は、これらの注目すべき進歩のいくつかです：

- テストの行番号を使用して単一のテストを実行します。
- テストの行番号を指定して複数のテストを実行します。
- 失敗メッセージが改善され、失敗したテストを再実行しやすくなります。
- `-f`オプションを使用して、テストの実行中に失敗が発生した場合にすぐにテストを停止します。スイートの完了を待つのではなく。
- `-d`オプションを使用して、完全なテスト実行の終了までテストの出力を遅延させます。
- `-b`オプションを使用して、完全な例外のバックトレース出力を行います。
- minitestとの統合により、テストシードデータのための`-s`オプション、名前で特定のテストを実行するための`-n`オプション、より良い詳細な出力のための`-v`オプションなどのオプションを使用できます。
- カラー表示されたテストの出力。

Railties
--------

詳細な変更については、[変更履歴][railties]を参照してください。

### 削除された機能

*   デバッガーサポートが削除されました。代わりにbyebugを使用してください。`debugger`はRuby 2.2ではサポートされていません。
    ([commit](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))
*   廃止された `test:all` と `test:all:db` タスクを削除しました。
    ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   廃止された `Rails::Rack::LogTailer` を削除しました。
    ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   廃止された `RAILS_CACHE` 定数を削除しました。
    ([commit](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   廃止された `serve_static_assets` 設定を削除しました。
    ([commit](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   `doc:app`、`doc:rails`、および `doc:guides` のドキュメンテーションタスクを削除しました。
    ([commit](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   デフォルトのスタックから `Rack::ContentLength` ミドルウェアを削除しました。
    ([Commit](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### 廃止予定

*   `config.static_cache_control` を `config.public_file_server.headers` に置き換えるために、`config.static_cache_control` を廃止しました。
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   `config.serve_static_files` を `config.public_file_server.enabled` に置き換えるために、`config.serve_static_files` を廃止しました。
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*   `rails` タスク名前空間のタスクを `app` 名前空間のタスクに置き換えるために、`rails:update` と `rails:template` タスクを `app:update` と `app:template` に名前変更しました。
    ([Pull Request](https://github.com/rails/rails/pull/23439))

### 注目すべき変更点

*   Rails テストランナー `bin/rails test` を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/19216))

*   新しく生成されたアプリケーションとプラグインには、Markdown 形式の `README.md` が追加されます。
    ([commit](https://github.com/rails/rails/commit/89a12c931b1f00b90e74afffcdc2fc21f14ca663),
     [Pull Request](https://github.com/rails/rails/pull/22068))

*   `bin/rails restart` タスクを追加し、`tmp/restart.txt` をタッチして Rails アプリを再起動します。
    ([Pull Request](https://github.com/rails/rails/pull/18965))

*   `bin/rails initializers` タスクを追加し、Rails によって呼び出される順序で定義されたすべての初期化子を表示します。
    ([Pull Request](https://github.com/rails/rails/pull/19323))

*   開発モードでキャッシュを有効または無効にするための `bin/rails dev:cache` を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/20961))

*   開発環境を自動的に更新するための `bin/update` スクリプトを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/20972))

*   Rake タスクを `bin/rails` を介してプロキシします。
    ([Pull Request](https://github.com/rails/rails/pull/22457),
     [Pull Request](https://github.com/rails/rails/pull/22288))

*   新しいアプリケーションは、Linux と macOS でイベント駆動型のファイルシステムモニターが有効になります。ジェネレータに `--skip-listen` を渡すことで、この機能を無効にすることもできます。
    ([commit](https://github.com/rails/rails/commit/de6ad5665d2679944a9ee9407826ba88395a1003),
    [commit](https://github.com/rails/rails/commit/94dbc48887bf39c241ee2ce1741ee680d773f202))

*   新しいアプリケーションでは、環境変数 `RAILS_LOG_TO_STDOUT` を使用して、本番環境で STDOUT にログを出力するオプションが追加されました。
    ([Pull Request](https://github.com/rails/rails/pull/23734))

*   新しいアプリケーションに対して IncludeSubdomains ヘッダを使用して HSTS を有効にしました。
    ([Pull Request](https://github.com/rails/rails/pull/23852))

*   アプリケーションジェネレータは、Spring が追加の共通ファイルを監視するようにする新しいファイル `config/spring.rb` を書き込みます。
    ([commit](https://github.com/rails/rails/commit/b04d07337fd7bc17e88500e9d6bcd361885a45f8))

*   新しいアプリを生成する際に Action Mailer をスキップするための `--skip-action-mailer` を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/18288))

*   `tmp/sessions` ディレクトリとそれに関連するクリア rake タスクを削除しました。
    ([Pull Request](https://github.com/rails/rails/pull/18314))

*   スキャフォールドジェネレータによって生成される `_form.html.erb` をローカル変数を使用するように変更しました。
    ([Pull Request](https://github.com/rails/rails/pull/13434))
*   本番環境でのクラスの自動読み込みを無効化しました。
    ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

アクションパック
-----------

詳細な変更については、[変更履歴][action-pack]を参照してください。

### 削除

*   `ActionDispatch::Request::Utils.deep_munge`を削除しました。
    ([commit](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   `ActionController::HideActions`を削除しました。
    ([Pull Request](https://github.com/rails/rails/pull/18371))

*   `respond_to`と`respond_with`のプレースホルダメソッドを削除しました。この機能は
    [responders](https://github.com/plataformatec/responders) gemに抽出されました。
    ([commit](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   廃止予定のアサーションファイルを削除しました。
    ([commit](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   URLヘルパーでの文字列キーの使用を廃止しました。
    ([commit](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   `*_path`ヘルパーの`only_path`オプションを廃止しました。
    ([commit](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))

*   廃止予定の`NamedRouteCollection#helpers`を削除しました。
    ([commit](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*   `:to`オプションに`#`を含まないルートの定義を廃止しました。
    ([commit](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   廃止予定の`ActionDispatch::Response#to_ary`を削除しました。
    ([commit](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   廃止予定の`ActionDispatch::Request#deep_munge`を削除しました。
    ([commit](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   廃止予定の`ActionDispatch::Http::Parameters#symbolized_path_parameters`を削除しました。
    ([commit](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   コントローラーテストでの廃止予定の`use_route`オプションを削除しました。
    ([commit](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   `assigns`と`assert_template`を削除しました。両メソッドは
    [rails-controller-testing](https://github.com/rails/rails-controller-testing)
    gemに抽出されました。
    ([Pull Request](https://github.com/rails/rails/pull/20138))

### 廃止予定

*   `*_filter`コールバックをすべて`*_action`コールバックに廃止予定にしました。
    ([Pull Request](https://github.com/rails/rails/pull/18410))

*   `*_via_redirect`統合テストメソッドを廃止予定にしました。同じ動作をするために、リクエスト呼び出し後に手動で`follow_redirect!`を使用してください。
    ([Pull Request](https://github.com/rails/rails/pull/18693))

*   `AbstractController#skip_action_callback`を個別のskip_callbackメソッドに対して廃止予定にしました。
    ([Pull Request](https://github.com/rails/rails/pull/19060))

*   `render`メソッドの`:nothing`オプションを廃止予定にしました。
    ([Pull Request](https://github.com/rails/rails/pull/20336))

*   `head`メソッドの最初のパラメータを`Hash`とデフォルトのステータスコードとして渡すことを廃止予定にしました。
    ([Pull Request](https://github.com/rails/rails/pull/20407))

*   ミドルウェアクラス名に対して文字列やシンボルを使用することを廃止予定にしました。代わりにクラス名を使用してください。
    ([commit](https://github.com/rails/rails/commit/83b767ce))

*   MIMEタイプへのアクセスに定数を使用することを廃止予定にしました（例：`Mime::HTML`）。代わりに、シンボルを使用した添字演算子を使用してください（例：`Mime[:html]`）。
    ([Pull Request](https://github.com/rails/rails/pull/21869))

*   `redirect_to :back`を`redirect_back`に廃止予定しました。`fallback_location`引数を必須とし、`RedirectBackError`の可能性を排除します。
    ([Pull Request](https://github.com/rails/rails/pull/22506))

*   `ActionDispatch::IntegrationTest`と`ActionController::TestCase`は、位置引数をキーワード引数に対して廃止予定にしました。
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   `:controller`と`:action`のパスパラメータを廃止予定にしました。
    ([Pull Request](https://github.com/rails/rails/pull/23980))

*   コントローラーインスタンスでのenvメソッドを廃止予定にしました。
    ([commit](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   `ActionDispatch::ParamsParser`は廃止予定であり、ミドルウェアスタックから削除されました。パラメータパーサーを設定するには、`ActionDispatch::Request.parameter_parsers=`を使用してください。
    ([commit](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1),
    [commit](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))
### 注目すべき変更点

* `ActionController::Renderer`を追加して、コントローラーアクション以外でも任意のテンプレートをレンダリングできるようにしました。
（[プルリクエスト](https://github.com/rails/rails/pull/18546)）

* `ActionController::TestCase`および`ActionDispatch::Integration`のHTTPリクエストメソッドでキーワード引数の構文を使用するように移行しました。
（[プルリクエスト](https://github.com/rails/rails/pull/18323)）

* Action Controllerに`http_cache_forever`を追加し、期限切れにならないレスポンスをキャッシュできるようにしました。
（[プルリクエスト](https://github.com/rails/rails/pull/18394)）

* リクエストのバリアントにより簡単にアクセスできるようにしました。
（[プルリクエスト](https://github.com/rails/rails/pull/18939)）

* 対応するテンプレートがないアクションの場合、エラーを発生させる代わりに`head :no_content`をレンダリングするようにしました。
（[プルリクエスト](https://github.com/rails/rails/pull/19377)）

* コントローラーのデフォルトフォームビルダーをオーバーライドできるようにしました。
（[プルリクエスト](https://github.com/rails/rails/pull/19736)）

* API専用のアプリケーションをサポートするようにしました。
この種のアプリケーションには、`ActionController::Base`の代わりに`ActionController::API`が追加されました。
（[プルリクエスト](https://github.com/rails/rails/pull/19832)）

* `ActionController::Parameters`はもはや`HashWithIndifferentAccess`を継承しないようにしました。
（[プルリクエスト](https://github.com/rails/rails/pull/20868)）

* `config.force_ssl`と`config.ssl_options`に簡単にオプトインできるようにし、試すのが危険ではなく無効化しやすくしました。
（[プルリクエスト](https://github.com/rails/rails/pull/21520)）

* `ActionDispatch::Static`に任意のヘッダーを返す機能を追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/19135)）

* `protect_from_forgery`のデフォルトのprependを`false`に変更しました。
（[コミット](https://github.com/rails/rails/commit/39794037817703575c35a75f1961b01b83791191)）

* `ActionController::TestCase`はRails 5.1で独自のgemに移動されます。代わりに`ActionDispatch::IntegrationTest`を使用してください。
（[コミット](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d)）

* Railsはデフォルトで弱いETagを生成するようになりました。
（[プルリクエスト](https://github.com/rails/rails/pull/17573)）

* 明示的な`render`呼び出しがなく、対応するテンプレートもないコントローラーアクションは、エラーを発生させる代わりに`head :no_content`を暗黙的にレンダリングします。
（プルリクエスト [1](https://github.com/rails/rails/pull/19377)、[2](https://github.com/rails/rails/pull/23827)）

* フォームごとのCSRFトークンのオプションを追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/22275)）

* 統合テストにリクエストのエンコーディングとレスポンスの解析を追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/21671)）

* `ActionController#helpers`を追加して、コントローラーレベルでビューコンテキストにアクセスできるようにしました。
（[プルリクエスト](https://github.com/rails/rails/pull/24866)）

* 削除されたフラッシュメッセージはセッションに保存される前に削除されます。
（[プルリクエスト](https://github.com/rails/rails/pull/18721)）

* `fresh_when`および`stale?`にレコードのコレクションを渡すサポートを追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/18374)）

* `ActionController::Live`が`ActiveSupport::Concern`になりました。これにより、`ActionController::Live`を他のモジュールに単純に含めることはできず、それらを`ActiveSupport::Concern`または`ActionController::Live`で拡張する必要があります。また、ミドルウェアがスポーンされたスレッドによってスローされる`:warden`をキャッチできないため、特別な`Warden`/`Devise`認証失敗処理コードを含めるために別のモジュールを使用している場合もあります。
（[この問題の詳細はこちら](https://github.com/rails/rails/issues/25581)）
* `Response#strong_etag=`と`#weak_etag=`、および`fresh_when`と`stale?`に対応するオプションを導入しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/24387))

Action View
-------------

詳細な変更内容については、[変更履歴][action-view]を参照してください。

### 削除

* `AbstractController::Base::parent_prefixes`を非推奨としました。
    ([コミット](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

* `ActionView::Helpers::RecordTagHelper`を削除しました。この機能は
    [record_tag_helper](https://github.com/rails/record_tag_helper) gemに抽出されました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18411))

* `translate`ヘルパーの`rescue_format`オプションを削除しました。これはI18nでサポートされなくなったためです。
    ([プルリクエスト](https://github.com/rails/rails/pull/20019))

### 注目すべき変更

* デフォルトのテンプレートハンドラを`ERB`から`Raw`に変更しました。
    ([コミット](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

* コレクションのレンダリングは複数のパーシャルをキャッシュし、一度に取得できるようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18948),
    [コミット](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

* 明示的な依存関係にワイルドカードマッチングを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/20904))

* `disable_with`をsubmitタグのデフォルトの動作にしました。送信時にボタンを無効にして二重送信を防止します。
    ([プルリクエスト](https://github.com/rails/rails/pull/21135))

* パーシャルテンプレート名はもはや有効なRuby識別子である必要はありません。
    ([コミット](https://github.com/rails/rails/commit/da9038e))

* `datetime_tag`ヘルパーは、`datetime-local`のタイプを持つ入力タグを生成するようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/25469))

* `render partial:`ヘルパーでブロックを許可するようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/17974))

Action Mailer
-------------

詳細な変更内容については、[変更履歴][action-mailer]を参照してください。

### 削除

* メールビューでの非推奨の`*_path`ヘルパーを削除しました。
    ([コミット](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

* 非推奨の`deliver`および`deliver!`メソッドを削除しました。
    ([コミット](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### 注目すべき変更

* テンプレートの検索はデフォルトのロケールとI18nのフォールバックを尊重するようになりました。
    ([コミット](https://github.com/rails/rails/commit/ecb1981b))

* ジェネレータを介して作成されたメーラーに`_mailer`サフィックスを追加しました。これはコントローラとジョブで使用されている命名規則に従います。
    ([プルリクエスト](https://github.com/rails/rails/pull/18074))

* `assert_enqueued_emails`および`assert_no_enqueued_emails`を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18403))

* `config.action_mailer.deliver_later_queue_name`設定を追加し、メーラーキューの名前を設定できるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18587))

* Action Mailerビューでフラグメントキャッシュをサポートしました。
    テンプレートがキャッシュを実行するかどうかを決定するための新しい設定オプション`config.action_mailer.perform_caching`を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/22825))


Active Record
-------------

詳細な変更内容については、[変更履歴][active-record]を参照してください。

### 削除

* ネストされた配列をクエリ値として渡すことを許可する非推奨の動作を削除しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/17919))

* 非推奨の`ActiveRecord::Tasks::DatabaseTasks#load_schema`を削除しました。このメソッドは`ActiveRecord::Tasks::DatabaseTasks#load_schema_for`に置き換えられました。
    ([コミット](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))
*   廃止された`serialized_attributes`を削除しました。
    ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*   `has_many :through`での廃止された自動カウンターキャッシュを削除しました。
    ([commit](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

*   廃止された`sanitize_sql_hash_for_conditions`を削除しました。
    ([commit](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

*   廃止された`Reflection#source_macro`を削除しました。
    ([commit](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

*   廃止された`symbolized_base_class`と`symbolized_sti_name`を削除しました。
    ([commit](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

*   廃止された`ActiveRecord::Base.disable_implicit_join_references=`を削除しました。
    ([commit](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

*   文字列アクセサを使用した接続仕様へのアクセスの廃止を削除しました。
    ([commit](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

*   インスタンス依存の関連を事前に読み込むための廃止されたサポートを削除しました。
    ([commit](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

*   排他的な下限値を持つPostgreSQLの範囲の廃止されたサポートを削除しました。
    ([commit](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

*   キャッシュされたArelでリレーションを変更する際の廃止を削除しました。
    代わりに`ImmutableRelation`エラーが発生します。
    ([commit](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

*   `ActiveRecord::Serialization::XmlSerializer`をコアから削除しました。この機能は
    [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml)
    gemに抽出されました。 ([Pull Request](https://github.com/rails/rails/pull/21161))

*   コアからレガシーな`mysql`データベースアダプタのサポートを削除しました。ほとんどのユーザーは
    `mysql2`を使用できるはずです。メンテナンスを引き継いでくれる人が見つかった場合、別のgemに変換されます。 ([Pull Request 1](https://github.com/rails/rails/pull/22642),
    [Pull Request 2](https://github.com/rails/rails/pull/22715))

*   `protected_attributes` gemのサポートを削除しました。
    ([commit](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

*   PostgreSQLのバージョン9.1未満のサポートを削除しました。
    ([Pull Request](https://github.com/rails/rails/pull/23434))

*   `activerecord-deprecated_finders` gemのサポートを削除しました。
    ([commit](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

*   `ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES`定数を削除しました。
    ([commit](https://github.com/rails/rails/commit/a502703c3d2151d4d3b421b29fefdac5ad05df61))

### 廃止予定

*   クエリの値としてクラスを渡すことを廃止しました。代わりに文字列を渡すようにしてください。
    ([Pull Request](https://github.com/rails/rails/pull/17916))

*   Active Recordコールバックチェーンを停止するために`false`を返すことを廃止しました。
    推奨される方法は`throw(:abort)`です。 ([Pull Request](https://github.com/rails/rails/pull/17227))

*   `ActiveRecord::Base.errors_in_transactional_callbacks=`を廃止しました。
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

*   `Relation#uniq`の使用を廃止し、代わりに`Relation#distinct`を使用してください。
    ([commit](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

*   PostgreSQLの`:point`型を廃止し、代わりに`Array`ではなく`Point`オブジェクトを返す新しい型にしました。
    ([Pull Request](https://github.com/rails/rails/pull/20448))

*   関連メソッドに真の引数を渡すことで強制的に関連をリロードすることを廃止しました。
    ([Pull Request](https://github.com/rails/rails/pull/20888))

*   関連`restrict_dependent_destroy`のエラーのキーを新しいキー名に変更しました。
    ([Pull Request](https://github.com/rails/rails/pull/20668))

*   `#tables`の動作を同期化しました。
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   `SchemaCache#tables`、`SchemaCache#table_exists?`、`SchemaCache#clear_table_cache!`を廃止し、
    代わりに新しいデータソースの対応するメソッドを使用してください。
    ([Pull Request](https://github.com/rails/rails/pull/21715))
* SQLite3およびMySQLアダプターの`connection.tables`を非推奨としました。
    ([プルリクエスト](https://github.com/rails/rails/pull/21601))

* `#tables`への引数の渡し方を非推奨としました - 一部のアダプター(mysql2、sqlite3)の`#tables`メソッドはテーブルとビューの両方を返し、他のアダプター(postgresql)はテーブルのみを返します。振る舞いを一貫させるため、将来的には`#tables`はテーブルのみを返すようになります。
    ([プルリクエスト](https://github.com/rails/rails/pull/21601))

* `table_exists?`を非推奨としました - `#table_exists?`メソッドはテーブルとビューの両方をチェックしていました。`#tables`との振る舞いを一貫させるため、将来的には`#table_exists?`はテーブルのみをチェックするようになります。
    ([プルリクエスト](https://github.com/rails/rails/pull/21601))

* `find_nth`への`offset`引数の渡し方を非推奨としました。代わりにリレーションの`offset`メソッドを使用してください。
    ([プルリクエスト](https://github.com/rails/rails/pull/22053))

* `DatabaseStatements`の`{insert|update|delete}_sql`を非推奨としました。代わりに`{insert|update|delete}`の公開メソッドを使用してください。
    ([プルリクエスト](https://github.com/rails/rails/pull/23086))

* `use_transactional_fixtures`を明確さのために`use_transactional_tests`に非推奨としました。
    ([プルリクエスト](https://github.com/rails/rails/pull/19282))

* `ActiveRecord::Connection#quote`にカラムを渡すことを非推奨としました。
    ([コミット](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

* `find_in_batches`に`end`オプションを追加し、`start`パラメータと組み合わせてバッチ処理の停止位置を指定できるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/12257))


### 注目すべき変更点

* テーブル作成時に`references`に`foreign_key`オプションを追加しました。
    ([コミット](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

* 新しい属性APIを追加しました。
    ([コミット](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

* `enum`定義に`:_prefix`/`:_suffix`オプションを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/19813),
     [プルリクエスト](https://github.com/rails/rails/pull/20999))

* `ActiveRecord::Relation`に`#cache_key`を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/20884))

* `timestamps`のデフォルトの`null`値を`false`に変更しました。
    ([コミット](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

* `ActiveRecord::SecureToken`を追加し、`SecureRandom`を使用してモデルの属性の一意のトークンを生成するためのカプセル化を行いました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18217))

* `drop_table`に`if_exists`オプションを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18597))

* `ActiveRecord::Base#accessed_fields`を追加しました。これは、データベースから必要なデータのみを選択する場合に、モデルから読み取られたフィールドを素早く特定するために使用できます。
    ([コミット](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

* `ActiveRecord::Relation`に`#or`メソッドを追加し、WHEREまたはHAVING句を組み合わせるためにOR演算子を使用できるようにしました。
    ([コミット](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

* `ActiveRecord::Base.suppress`を追加し、指定されたブロック内でレシーバーの保存を防止します。
    ([プルリクエスト](https://github.com/rails/rails/pull/18910))

* `belongs_to`は、関連が存在しない場合にデフォルトでバリデーションエラーを発生させるようになりました。`optional: true`を使用して、個別の関連ごとにこれを無効にすることができます。また、`required`オプションを`optional`に非推奨としました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18937))
* `db:structure:dump`の動作を設定するために`config.active_record.dump_schemas`を追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/19347)）

* `config.active_record.warn_on_records_fetched_greater_than`オプションを追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/18846)）

* MySQLでネイティブのJSONデータ型サポートを追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/21110)）

* PostgreSQLで同時にインデックスを削除するサポートを追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/21317)）

* 接続アダプターに`#views`と`#view_exists?`メソッドを追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/21609)）

* Active Recordから一部のカラムを非表示にするために`ActiveRecord::Base.ignored_columns`を追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/21720)）

* `connection.data_sources`と`connection.data_source_exists?`を追加しました。
これらのメソッドは、Active Recordモデル（通常はテーブルとビュー）をバックエンドとして使用できる関係を決定します。
（[プルリクエスト](https://github.com/rails/rails/pull/21715)）

* フィクスチャファイルでYAMLファイル自体にモデルクラスを設定できるようにしました。
（[プルリクエスト](https://github.com/rails/rails/pull/20574)）

* データベースマイグレーションを生成する際にデフォルトで`uuid`をプライマリキーに設定できるようにしました。
（[プルリクエスト](https://github.com/rails/rails/pull/21762)）

* `ActiveRecord::Relation#left_joins`と`ActiveRecord::Relation#left_outer_joins`を追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/12071)）

* `after_{create,update,delete}_commit`コールバックを追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/22516)）

* マイグレーションクラスに提示されるAPIのバージョンを付けることで、既存のマイグレーションを壊すことなく、パラメータのデフォルトを変更したり、非推奨のサイクルを経て書き直すことができるようにしました。
（[プルリクエスト](https://github.com/rails/rails/pull/21538)）

* `ApplicationRecord`は、アプリケーションのモデル全体の動作を設定するための単一の場所を提供する、アプリケーションモデルの新しいスーパークラスです。これは、アプリケーションコントローラが`ActionController::Base`ではなく`ApplicationController`をサブクラス化するのと同様です。
（[プルリクエスト](https://github.com/rails/rails/pull/22567)）

* ActiveRecordの`#second_to_last`と`#third_to_last`メソッドを追加しました。
（[プルリクエスト](https://github.com/rails/rails/pull/23583)）

* PostgreSQLのデータベースオブジェクト（テーブル、カラム、インデックス）にコメントを追加する機能を追加しました。これらのコメントはデータベースのメタデータに保存されます。
（[プルリクエスト](https://github.com/rails/rails/pull/22911)）

* `mysql2`アダプターにプリペアドステートメントのサポートを追加しました（mysql2 0.4.4+用）。以前は非推奨の`mysql`レガシーアダプターでのみサポートされていました。有効にするには、`config/database.yml`で`prepared_statements: true`を設定します。
（[プルリクエスト](https://github.com/rails/rails/pull/23461)）

* 関連オブジェクト上で`ActionRecord::Relation#update`を呼び出す機能を追加しました。これにより、関連するすべてのオブジェクトでバリデーションとコールバックが実行されます。
（[プルリクエスト](https://github.com/rails/rails/pull/11898)）

* `save`メソッドに`touch`オプションを追加し、タイムスタンプを更新せずにレコードを保存できるようにしました。
（[プルリクエスト](https://github.com/rails/rails/pull/18225)）

* PostgreSQLの式インデックスとオペレータクラスのサポートを追加しました。
（[commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882)）
*   ネストされた属性のエラーにインデックスを追加するための `:index_errors` オプションを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/19686))

*   双方向の破棄依存関係のサポートを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18548))

*   トランザクション内のテストで `after_commit` コールバックをサポートするようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18458))

*   テーブルに外部キーが存在するかどうかを確認するための `foreign_key_exists?` メソッドを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18662))

*   `touch` メソッドに `:time` オプションを追加し、現在の時刻とは異なる時刻でレコードを更新するようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18956))

*   トランザクションコールバックのエラーをキャッチしないように変更しました。
    この変更前では、トランザクションコールバック内で発生したエラーはキャッチされ、ログに表示されていましたが、
    (新たに非推奨となった)`raise_in_transactional_callbacks = true` オプションを使用しない限り、
    これらのエラーはもはやキャッチされずに上位に伝播するようになりました。

    これにより、他のコールバックと同様の動作になります。
    ([コミット](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

Active Model
------------

詳細な変更については、[Changelog][active-model] を参照してください。

### 削除

*   廃止予定の `ActiveModel::Dirty#reset_#{attribute}` と `ActiveModel::Dirty#reset_changes` を削除しました。
    ([プルリクエスト](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

*   XML シリアライズを削除しました。この機能は [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) gem に抽出されました。
    ([プルリクエスト](https://github.com/rails/rails/pull/21161))

*   `ActionController::ModelNaming` モジュールを削除しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18194))

### 廃止予定

*   Active Model および `ActiveModel::Validations` コールバックチェーンを停止するための方法として `false` を返すことを廃止しました。推奨される方法は `throw(:abort)` です。
    ([プルリクエスト](https://github.com/rails/rails/pull/17227))

*   不一致な動作を持つ `ActiveModel::Errors#get`、`ActiveModel::Errors#set`、`ActiveModel::Errors#[]=` メソッドを廃止しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18634))

*   `validates_length_of` の `:tokenizer` オプションを廃止し、プレーンな Ruby を使用するようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/19585))

*   `ActiveModel::Errors#add_on_empty` と `ActiveModel::Errors#add_on_blank` を廃止し、代替方法はありません。
    ([プルリクエスト](https://github.com/rails/rails/pull/18996))

### 注目すべき変更

*   失敗したバリデータを特定するための `ActiveModel::Errors#details` を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18322))

*   `ActiveRecord::AttributeAssignment` を `ActiveModel::AttributeAssignment` に抽出し、それをインクルード可能なモジュールとして任意のオブジェクトで使用できるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/10776))

*   モデルが保存された後に記録された変更にアクセスするための `ActiveModel::Dirty#[attr_name]_previously_changed?` と `ActiveModel::Dirty#[attr_name]_previous_change` を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/19847))

*   `valid?` および `invalid?` で複数のコンテキストを同時に検証するように変更しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/21069))

*   `validates_acceptance_of` を `1` に加えて `true` をデフォルト値として受け入れるように変更しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18439))
Active Job
-----------

詳細な変更については、[Changelog][active-job]を参照してください。

### 注目すべき変更点

*   `ActiveJob::Base.deserialize`はジョブクラスに委譲されます。これにより、ジョブがシリアライズされる際に任意のメタデータを添付し、実行される際にそれを読み取ることができます。
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*   各ジョブに影響を与えることなく、ジョブごとにキューアダプタを設定できるようになりました。
    ([Pull Request](https://github.com/rails/rails/pull/16992))

*   生成されたジョブはデフォルトで`app/jobs/application_job.rb`を継承します。
    ([Pull Request](https://github.com/rails/rails/pull/19034))

*   `DelayedJob`、`Sidekiq`、`qu`、`que`、`queue_classic`が`provider_job_id`としてジョブIDを`ActiveJob::Base`に返すようになりました。
    ([Pull Request](https://github.com/rails/rails/pull/20064),
     [Pull Request](https://github.com/rails/rails/pull/20056),
     [commit](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

*   `concurrent-ruby`スレッドプールにジョブをキューイングするための単純な`AsyncJob`プロセッサと関連する`AsyncAdapter`を実装しました。
    ([Pull Request](https://github.com/rails/rails/pull/21257))

*   デフォルトのアダプタをインラインから非同期に変更しました。これは、テストが誤って同期的に発生する動作に依存しないようにするためのより良いデフォルトです。
    ([commit](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))

Active Support
--------------

詳細な変更については、[Changelog][active-support]を参照してください。

### 削除されたもの

*   廃止予定の`ActiveSupport::JSON::Encoding::CircularReferenceError`を削除しました。
    ([commit](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

*   廃止予定のメソッド`ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=`と`ActiveSupport::JSON::Encoding.encode_big_decimal_as_string`を削除しました。
    ([commit](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

*   廃止予定の`ActiveSupport::SafeBuffer#prepend`を削除しました。
    ([commit](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

*   `Kernel`から廃止予定のメソッド`silence_stderr`、`silence_stream`、`capture`、`quietly`を削除しました。
    ([commit](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

*   廃止予定の`active_support/core_ext/big_decimal/yaml_conversions`ファイルを削除しました。
    ([commit](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

*   廃止予定のメソッド`ActiveSupport::Cache::Store.instrument`と`ActiveSupport::Cache::Store.instrument=`を削除しました。
    ([commit](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

*   廃止予定の`Class#superclass_delegating_accessor`を削除しました。代わりに`Class#class_attribute`を使用してください。
    ([Pull Request](https://github.com/rails/rails/pull/16938))

*   `ThreadSafe::Cache`を削除しました。代わりに`Concurrent::Map`を使用してください。
    ([Pull Request](https://github.com/rails/rails/pull/21679))

*   Ruby 2.2で実装されているため、`Object#itself`を削除しました。
    ([Pull Request](https://github.com/rails/rails/pull/18244))

### 廃止予定

*   `MissingSourceFile`を`LoadError`に代わって廃止予定にしました。
    ([commit](https://github.com/rails/rails/commit/734d97d2))

*   `alias_method_chain`をRuby 2.0で導入された`Module#prepend`に代わって廃止予定にしました。
    ([Pull Request](https://github.com/rails/rails/pull/19434))

*   `ActiveSupport::Concurrency::Latch`を廃止予定にし、concurrent-rubyの`Concurrent::CountDownLatch`を使用するようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/20866))

*   `number_to_human_size`の`prefix`オプションを廃止予定にし、代替方法はありません。
    ([Pull Request](https://github.com/rails/rails/pull/21191))

*   `Module#qualified_const_`を廃止予定にし、組み込みの`Module#const_`メソッドを使用するようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*   コールバックを定義する際に文字列を渡すことを廃止予定にしました。
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*   `ActiveSupport::Cache::Store#namespaced_key`、`ActiveSupport::Cache::MemCachedStore#escape_key`、`ActiveSupport::Cache::FileStore#key_file_path`を廃止予定にしました。代わりに`normalize_key`を使用してください。
    ([Pull Request](https://github.com/rails/rails/pull/22215),
     [commit](https://github.com/rails/rails/commit/a8f773b0))
* `ActiveSupport::Cache::LocaleCache#set_cache_value`を`write_cache_value`に置き換えるように非推奨化しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/22215))

* `assert_nothing_raised`への引数の渡し方を非推奨化しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/23789))

* `Module.local_constants`を`Module.constants(false)`に置き換えるように非推奨化しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/23936))


### 注目すべき変更点

* `ActiveSupport::MessageVerifier`に`#verified`と`#valid_message?`メソッドを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/17727))

* コールバックチェーンを停止する方法を変更しました。今後は明示的に`throw(:abort)`を使用してコールバックチェーンを停止することが推奨されます。
    ([プルリクエスト](https://github.com/rails/rails/pull/17227))

* 新しい設定オプション`config.active_support.halt_callback_chains_on_return_false`を追加しました。これにより、ActiveRecord、ActiveModel、ActiveModel::Validationsのコールバックチェーンを'before'コールバックで`false`を返すことで停止させるかどうかを指定できます。
    ([プルリクエスト](https://github.com/rails/rails/pull/17227))

* デフォルトのテスト順序を`：sorted`から`：random`に変更しました。
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

* `Date`、`Time`、`DateTime`に`#on_weekend?`、`#on_weekday?`、`#next_weekday`、`#prev_weekday`メソッドを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18335),
     [プルリクエスト](https://github.com/rails/rails/pull/23687))

* `Date`、`Time`、`DateTime`に`#next_week`と`#prev_week`に`same_time`オプションを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18335))

* `Date`、`Time`、`DateTime`の`#yesterday`と`#tomorrow`に対する`#prev_day`と`#next_day`の対応を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18335))

* ランダムなbase58文字列を生成するための`SecureRandom.base58`を追加しました。
    ([commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b))

* `ActiveSupport::TestCase`に`file_fixture`を追加しました。これはテストケースでサンプルファイルにアクセスするための簡単なメカニズムを提供します。
    ([プルリクエスト](https://github.com/rails/rails/pull/18658))

* `Enumerable`と`Array`に`#without`を追加し、指定した要素を除いた列挙可能なコピーを返すようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/19157))

* `ActiveSupport::ArrayInquirer`と`Array#inquiry`を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/18939))

* `ActiveSupport::TimeZone#strptime`を追加し、指定したタイムゾーンからの時刻の解析を可能にしました。
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

* `Integer#positive?`と`Integer#negative?`のクエリメソッドを`Integer#zero?`のように追加しました。
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

* `ActiveSupport::OrderedOptions`のgetメソッドに、値が`.blank?`の場合に`KeyError`を発生させるバンドルバージョンを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/20208))

* 指定した年の日数、または引数が指定されていない場合は現在の年の日数を返す`Time.days_in_year`を追加しました。
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

* アプリケーションのソースコード、ルート、ロケールなどの変更を非同期に検出するためのイベント駆動型のファイルウォッチャーを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/22254))

* スレッドごとに生存するクラスとモジュール変数を宣言するための`thread_m/cattr_accessor/reader/writer`メソッドスイートを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/22630))
* `Array#second_to_last`メソッドと`Array#third_to_last`メソッドを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/23583))

* `ActiveSupport::Executor`と`ActiveSupport::Reloader`のAPIを公開し、コンポーネントやライブラリがアプリケーションコードの実行や再読み込みプロセスに参加・管理できるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/23807))

* `ActiveSupport::Duration`はISO8601形式のフォーマットとパースをサポートするようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16917))

* `ActiveSupport::JSON.decode`は、`parse_json_times`が有効な場合にISO8601のローカル時刻のパースをサポートするようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/23011))

* `ActiveSupport::JSON.decode`は、日付文字列に対して`Date`オブジェクトを返すようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/23011))

* `TaggedLogging`に複数のロガーをインスタンス化する機能を追加し、それらがお互いのタグを共有しないようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/9065))

クレジット
-------

Railsの安定かつ堅牢なフレームワークになるために、多くの人々が多くの時間を費やした、Railsへの[貢献者の完全なリスト](https://contributors.rubyonrails.org/)をご覧ください。彼ら全員に敬意を表します。

[railties]:       https://github.com/rails/rails/blob/5-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-0-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
