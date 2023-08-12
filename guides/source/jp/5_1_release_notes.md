**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ddd82b1a207070829b1ec46e4bb40d80
Ruby on Rails 5.1 リリースノート
===============================

Rails 5.1 のハイライト：

* Yarn サポート
* オプションの Webpack サポート
* jQuery はデフォルトの依存関係ではなくなりました
* システムテスト
* 暗号化されたシークレット
* パラメータ化されたメーラー
* 直接的で解決されたルート
* form_for と form_tag を form_with に統一

これらのリリースノートは主な変更のみをカバーしています。さまざまなバグ修正や変更については、changelog を参照するか、GitHub 上のメイン Rails リポジトリの [コミットリスト](https://github.com/rails/rails/commits/5-1-stable) をご覧ください。

--------------------------------------------------------------------------------

Rails 5.1 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合は、アップグレード前に十分なテストカバレッジを持つことが重要です。また、Rails 5.1 への更新を試みる前に、まず Rails 5.0 にアップグレードし、アプリケーションが正常に動作することを確認してください。アップグレード時に注意するべき事項のリストは、[Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1) ガイドで入手できます。

主な機能
--------------

### Yarn サポート

[Pull Request](https://github.com/rails/rails/pull/26836)

Rails 5.1 では、Yarn を介して npm から JavaScript の依存関係を管理することができます。これにより、React、VueJS などのライブラリを簡単に使用することができます。Yarn サポートはアセットパイプラインと統合されており、すべての依存関係が Rails 5.1 アプリケーションでシームレスに動作します。

### オプションの Webpack サポート

[Pull Request](https://github.com/rails/rails/pull/27288)

Rails アプリケーションは、新しい [Webpacker](https://github.com/rails/webpacker) gem を使用して、JavaScript アセットバンドラである [Webpack](https://webpack.js.org/) とより簡単に統合することができます。Webpack の統合を有効にするには、新しいアプリケーションを生成する際に `--webpack` フラグを使用します。

これはアセットパイプラインと完全に互換性があり、画像、フォント、サウンドなどのアセットには引き続きアセットパイプラインを使用することができます。アセットパイプラインで管理される JavaScript コードと、Webpack で処理される他のコードを持つこともできます。これらすべてはデフォルトで有効になっている Yarn によって管理されます。

### jQuery はデフォルトの依存関係ではなくなりました

[Pull Request](https://github.com/rails/rails/pull/27113)

以前のバージョンの Rails では、`data-remote`、`data-confirm` などの機能を提供するために jQuery がデフォルトで必要でした。しかし、UJS はプレーンな JavaScript を使用するように書き直されたため、これはもはや必要ではありません。このコードは現在、Action View の `rails-ujs` として提供されています。

必要な場合は引き続き jQuery を使用することができますが、デフォルトでは必要ありません。

### システムテスト

[Pull Request](https://github.com/rails/rails/pull/26703)

Rails 5.1 には、Capybara テストを書くための組み込みサポートであるシステムテストがあります。このようなテストのために Capybara やデータベースのクリーニング戦略を設定する必要はもはやありません。Rails 5.1 では、失敗スクリーンショットなどの追加機能を備えた Chrome でテストを実行するためのラッパーが提供されています。
### 暗号化されたシークレット

[プルリクエスト](https://github.com/rails/rails/pull/28038)

Railsは、[sekrets](https://github.com/ahoward/sekrets) gemに触発され、アプリケーションのシークレットを安全な方法で管理することができるようになりました。

`bin/rails secrets:setup`を実行して、新しい暗号化されたシークレットファイルをセットアップします。これにより、リポジトリの外部に保存する必要があるマスターキーも生成されます。シークレット自体は、暗号化された形式でリビジョン管理システムに安全にチェックインすることができます。

シークレットは、本番環境で`RAILS_MASTER_KEY`環境変数またはキーファイルに保存されたキーを使用して復号されます。

### パラメータ化されたメーラー

[プルリクエスト](https://github.com/rails/rails/pull/27825)

メーラークラスのすべてのメソッドで使用される共通パラメータを指定して、インスタンス変数、ヘッダー、およびその他の共通のセットアップを共有することができるようになりました。

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name}さんがあなたをBasecamp（#{@account.name}）に招待しました"
  end
end
```

```ruby
InvitationsMailer.with(inviter: person_a, invitee: person_b)
                 .account_invitation.deliver_later
```

### 直接的なルートと解決されたルート

[プルリクエスト](https://github.com/rails/rails/pull/23138)

Rails 5.1では、ルーティングDSLに`resolve`メソッドと`direct`メソッドの2つの新しいメソッドが追加されました。`resolve`メソッドを使用すると、モデルの多態性マッピングをカスタマイズすることができます。

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_for @basket do |form| %>
  <!-- バスケットフォーム -->
<% end %>
```

これにより、通常の`/baskets/:id`ではなく、単数形のURL `/basket`が生成されます。

`direct`メソッドを使用すると、カスタムのURLヘルパーを作成することができます。

```ruby
direct(:homepage) { "https://rubyonrails.org" }

homepage_url # => "https://rubyonrails.org"
```

ブロックの戻り値は、`url_for`メソッドの有効な引数である必要があります。したがって、有効な文字列URL、ハッシュ、配列、Active Modelのインスタンス、またはActive Modelクラスを渡すことができます。

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### form_forとform_tagをform_withに統合

[プルリクエスト](https://github.com/rails/rails/pull/26976)

Rails 5.1以前では、HTMLフォームを処理するための2つのインターフェースがありました。モデルインスタンスの場合は`form_for`、カスタムURLの場合は`form_tag`を使用します。

Rails 5.1では、これらのインターフェースを`form_with`で統合し、URL、スコープ、またはモデルに基づいてフォームタグを生成することができます。

URLのみを使用する場合：

```erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 生成されるHTML %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

スコープを追加すると、入力フィールドの名前にプレフィックスが付きます：

```erb
<%= form_with scope: :post, url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 生成されるHTML %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```
モデルを使用すると、URLとスコープの両方が推測されます：

```erb
<%= form_with model: Post.new do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 生成されるもの %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

既存のモデルを使用すると、更新フォームが作成され、フィールドの値が入力されます：

```erb
<%= form_with model: Post.first do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 生成されるもの %>

<form action="/posts/1" method="post" data-remote="true">
  <input type="hidden" name="_method" value="patch">
  <input type="text" name="post[title]" value="<投稿のタイトル>">
</form>
```

非互換性
-----------------

以下の変更は、アップグレード時に即座の対応が必要です。

### 複数の接続を持つトランザクションテスト

トランザクションテストは、すべてのActive Record接続をデータベーストランザクションでラップします。

テストが追加のスレッドを生成し、それらのスレッドがデータベース接続を取得する場合、これらの接続は特別に処理されます：

スレッドは、管理されたトランザクション内にある単一の接続を共有します。これにより、すべてのスレッドが同じ状態のデータベースを見ることができますが、最も外側のトランザクションは無視されます。以前は、このような追加の接続は、例えばフィクスチャの行を見ることができませんでした。

スレッドがネストされたトランザクションに入ると、一時的に接続の排他的な使用権を取得し、分離性を維持します。

テストが現在、生成されたスレッド内で別個のトランザクション外の接続を取得することに依存している場合、より明示的な接続管理に切り替える必要があります。

テストがスレッドを生成し、それらのスレッドが明示的なデータベーストランザクションを使用しながら相互作用する場合、この変更によりデッドロックが発生する可能性があります。

この新しい動作から抜け出す簡単な方法は、影響を受けるテストケースでトランザクションテストを無効にすることです。

Railties
--------

詳細な変更については、[変更履歴][railties]を参照してください。

### 削除

*   廃止予定の`config.static_cache_control`を削除しました。
    ([commit](https://github.com/rails/rails/commit/c861decd44198f8d7d774ee6a74194d1ac1a5a13))

*   廃止予定の`config.serve_static_files`を削除しました。
    ([commit](https://github.com/rails/rails/commit/0129ca2eeb6d5b2ea8c6e6be38eeb770fe45f1fa))

*   廃止予定のファイル`rails/rack/debugger`を削除しました。
    ([commit](https://github.com/rails/rails/commit/7563bf7b46e6f04e160d664e284a33052f9804b8))

*   廃止予定のタスク: `rails:update`, `rails:template`, `rails:template:copy`,
    `rails:update:configs`および`rails:update:bin`を削除しました。
    ([commit](https://github.com/rails/rails/commit/f7782812f7e727178e4a743aa2874c078b722eef))

*   `routes`タスクの`CONTROLLER`環境変数を廃止しました。
    ([commit](https://github.com/rails/rails/commit/f9ed83321ac1d1902578a0aacdfe55d3db754219))

*   `rails new`コマンドから-j（--javascript）オプションを削除しました。
    ([Pull Request](https://github.com/rails/rails/pull/28546))

### 注目すべき変更

*   すべての環境で読み込まれる`config/secrets.yml`に共有セクションを追加しました。
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   設定ファイル`config/secrets.yml`は、すべてのキーをシンボルとして読み込むようになりました。
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   デフォルトのスタックからjquery-railsを削除しました。Action Viewに付属しているrails-ujsがデフォルトのUJSアダプタとして含まれています。
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   新しいアプリケーションにYarnのサポートを追加し、yarn binstubとpackage.jsonを含めました。
    ([Pull Request](https://github.com/rails/rails/pull/26836))

*   `--webpack`オプションを介して新しいアプリケーションにWebpackのサポートを追加し、rails/webpacker gemに委譲します。
    ([Pull Request](https://github.com/rails/rails/pull/27288))
*   新しいアプリを生成する際に、オプション`--skip-git`が指定されていない場合は、Gitリポジトリを初期化します。
    ([プルリクエスト](https://github.com/rails/rails/pull/27632))

*   `config/secrets.yml.enc`に暗号化されたシークレットを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/28038))

*   `rails initializers`でrailtieクラス名を表示します。
    ([プルリクエスト](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

詳細な変更については、[Changelog][action-cable]を参照してください。

### 注目すべき変更点

*   `cable.yml`のRedisおよびイベント駆動型Redisアダプタに`channel_prefix`のサポートを追加し、同じRedisサーバーを複数のアプリケーションで使用する際の名前の衝突を回避します。
    ([プルリクエスト](https://github.com/rails/rails/pull/27425))

*   データをブロードキャストするための`ActiveSupport::Notifications`フックを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

詳細な変更については、[Changelog][action-pack]を参照してください。

### 削除された機能

*   `ActionDispatch::IntegrationTest`および`ActionController::TestCase`クラスの`#process`、`#get`、`#post`、`#patch`、`#put`、`#delete`、`#head`での非キーワード引数のサポートを削除しました。
    ([コミット](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [コミット](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

*   廃止予定の`ActionDispatch::Callbacks.to_prepare`および`ActionDispatch::Callbacks.to_cleanup`を削除しました。
    ([コミット](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

*   コントローラーフィルタに関連する廃止予定のメソッドを削除しました。
    ([コミット](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

*   `render`での`text`および`nothing`への廃止予定のサポートを削除しました。
    ([コミット](https://github.com/rails/rails/commit/79a5ea9eadb4d43b62afacedc0706cbe88c54496),
    [コミット](https://github.com/rails/rails/commit/57e1c99a280bdc1b324936a690350320a1cd8111))

*   `ActionController::Parameters`で`HashWithIndifferentAccess`メソッドを呼び出すサポートを廃止しました。
    ([コミット](https://github.com/rails/rails/pull/26746/commits/7093ceb480ad6a0a91b511832dad4c6a86981b93))

### 廃止予定の機能

*   `config.action_controller.raise_on_unfiltered_parameters`を廃止しました。Rails 5.1では何の効果もありません。
    ([コミット](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### 注目すべき変更点

*   ルーティングDSLに`direct`および`resolve`メソッドを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/23138))

*   アプリケーションでシステムテストを記述するための新しい`ActionDispatch::SystemTestCase`クラスを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/26703))

Action View
-------------

詳細な変更については、[Changelog][action-view]を参照してください。

### 削除された機能

*   `ActionView::Template::Error`の`#original_exception`を削除しました。
    ([コミット](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

*   `strip_tags`から`encode_special_chars`オプションを削除しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/28061))

### 廃止予定の機能

*   Erubis ERBハンドラをErubiに置き換えるためにErubis ERBハンドラを廃止しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/27757))

### 注目すべき変更点

*   Rawテンプレートハンドラ（Rails 5のデフォルトテンプレートハンドラ）は、HTMLセーフな文字列を出力するようになりました。
    ([コミット](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

*   `datetime_field`および`datetime_field_tag`を`datetime-local`フィールドを生成するように変更しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/25469))

*   HTMLタグのための新しいBuilderスタイルの構文（`tag.div`、`tag.br`など）を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/25543))

*   `form_tag`と`form_for`の使用方法を統一するために`form_with`を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/26976))

*   `current_page?`に`check_parameters`オプションを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

詳細な変更については、[Changelog][action-mailer]を参照してください。

### 注目すべき変更点

*   添付ファイルが含まれ、本文がインラインで設定されている場合にカスタムコンテンツタイプを設定できるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/27227))

*   `default`メソッドにラムダ式を値として渡すことができるようにしました。
    ([コミット](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   異なるメーラーアクション間で共有するために、メーラーのパラメータ化された呼び出しをサポートし、共通の前フィルタとデフォルトを共有できるようにしました。
    ([コミット](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   メーラーアクションへの引数を`process.action_mailer`イベントの`args`キーの下に渡すようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/27900))

Active Record
-------------

詳細な変更については、[Changelog][active-record]を参照してください。

### 削除された機能
* `ActiveRecord::QueryMethods#select` への引数とブロックの同時渡しのサポートを削除しました。
    ([Commit](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

* `activerecord.errors.messages.restrict_dependent_destroy.one` と `activerecord.errors.messages.restrict_dependent_destroy.many` の i18n スコープを削除しました。
    ([Commit](https://github.com/rails/rails/commit/00e3973a311))

* 単数形とコレクションの関連付けリーダーから非推奨の force-reload 引数を削除しました。
    ([Commit](https://github.com/rails/rails/commit/09cac8c67af))

* `#quote` にカラムを渡すサポートを削除しました。
    ([Commit](https://github.com/rails/rails/commit/e646bad5b7c))

* `#tables` から非推奨の `name` 引数を削除しました。
    ([Commit](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

* `#tables` と `#table_exists?` の非推奨な振る舞いを修正し、テーブルのみを返すようにしました。
    ([Commit](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

* `ActiveRecord::StatementInvalid#initialize` と `ActiveRecord::StatementInvalid#original_exception` の非推奨な `original_exception` 引数を削除しました。
    ([Commit](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

* クエリ内の値としてクラスを渡すサポートを削除しました。
    ([Commit](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

* LIMIT にカンマを使用してクエリを行うサポートを削除しました。
    ([Commit](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

* `#destroy_all` の非推奨な `conditions` パラメータを削除しました。
    ([Commit](https://github.com/rails/rails/commit/d31a6d1384cd740c8518d0bf695b550d2a3a4e9b))

* `#delete_all` の非推奨な `conditions` パラメータを削除しました。
    ([Commit](https://github.com/rails/rails/pull/27503/commits/e7381d289e4f8751dcec9553dcb4d32153bd922b))

* `#load_schema_for` メソッドを非推奨とし、`#load_schema` を使用するようにしました。
    ([Commit](https://github.com/rails/rails/commit/419e06b56c3b0229f0c72d3e4cdf59d34d8e5545))

* `#raise_in_transactional_callbacks` 設定を非推奨としました。
    ([Commit](https://github.com/rails/rails/commit/8029f779b8a1dd9848fee0b7967c2e0849bf6e07))

* `#use_transactional_fixtures` 設定を非推奨としました。
    ([Commit](https://github.com/rails/rails/commit/3955218dc163f61c932ee80af525e7cd440514b3))

### 非推奨

* `error_on_ignored_order_or_limit` フラグを `error_on_ignored_order` に非推奨としました。
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

* `sanitize_conditions` を `sanitize_sql` に非推奨としました。
    ([Pull Request](https://github.com/rails/rails/pull/25999))

* 接続アダプターの `supports_migrations?` を非推奨としました。
    ([Pull Request](https://github.com/rails/rails/pull/28172))

* `Migrator.schema_migrations_table_name` を `SchemaMigration.table_name` に変更しました。
    ([Pull Request](https://github.com/rails/rails/pull/28351))

* クォーテーションと型キャストで `#quoted_id` を使用することを非推奨としました。
    ([Pull Request](https://github.com/rails/rails/pull/27962))

* `#index_name_exists?` に `default` 引数を渡すことを非推奨としました。
    ([Pull Request](https://github.com/rails/rails/pull/26930))

### 注目すべき変更

* デフォルトのプライマリキーを BIGINT に変更しました。
    ([Pull Request](https://github.com/rails/rails/pull/26266))

* MySQL 5.7.5+ と MariaDB 5.2.0+ で仮想/生成列をサポートしました。
    ([Commit](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

* バッチ処理での LIMIT のサポートを追加しました。
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

* トランザクションテストは、すべての Active Record 接続をデータベーストランザクションでラップするようになりました。
    ([Pull Request](https://github.com/rails/rails/pull/28726))

* `mysqldump` コマンドの出力からコメントをデフォルトでスキップするようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/23301))

* `ActiveRecord::Relation#count` を修正し、ブロックが引数として渡された場合には Ruby の `Enumerable#count` を使用してレコードをカウントするようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/24203))

* `psql` コマンドに `"-v ON_ERROR_STOP=1"` フラグを渡して、SQL エラーを抑制しないようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/24773))

* `ActiveRecord::Base.connection_pool.stat` を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/26988))

* `ActiveRecord::Migration` から直接継承するとエラーが発生します。マイグレーションが書かれた Rails のバージョンを指定してください。
    ([Commit](https://github.com/rails/rails/commit/249f71a22ab21c03915da5606a063d321f04d4d3))

* `through` 関連付けに曖昧なリフレクション名がある場合にエラーが発生します。
    ([Commit](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

詳細な変更については、[Changelog][active-model] を参照してください。

### 削除

* `ActiveModel::Errors` の非推奨メソッドを削除しました。
    ([commit](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

* 長さバリデーターの `:tokenizer` オプションを削除しました。
    ([commit](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

* コールバックの返り値が false の場合にコールバックを中断する非推奨な振る舞いを削除しました。
    ([commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### 注目すべき変更

* モデル属性に割り当てられた元の文字列が誤って凍結されなくなりました。
    ([Pull Request](https://github.com/rails/rails/pull/28729))
アクティブジョブ
-----------

詳細な変更については、[変更履歴][active-job]を参照してください。

### 削除

*   `.queue_adapter` にアダプタクラスを渡すサポートが非推奨となりました。
    ([commit](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   `ActiveJob::DeserializationError` の `#original_exception` が非推奨となりました。
    ([commit](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### 注目すべき変更

*   `ActiveJob::Base.retry_on` と `ActiveJob::Base.discard_on` を使用した宣言的な例外処理の追加。
    ([Pull Request](https://github.com/rails/rails/pull/25991))

*   リトライが失敗した後のカスタムロジックで `job.arguments` のようなものにアクセスできるように、ジョブインスタンスをイールドします。
    ([commit](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

アクティブサポート
--------------

詳細な変更については、[変更履歴][active-support]を参照してください。

### 削除

*   `ActiveSupport::Concurrency::Latch` クラスが削除されました。
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   `halt_callback_chains_on_return_false` が削除されました。
    ([Commit](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))

*   戻り値が false の場合にコールバックを停止する非推奨の動作が削除されました。
    ([Commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### 廃止予定

*   トップレベルの `HashWithIndifferentAccess` クラスは、`ActiveSupport::HashWithIndifferentAccess` クラスにソフトウェア的に廃止予定となりました。
    ([Pull Request](https://github.com/rails/rails/pull/28157))

*   `set_callback` および `skip_callback` の条件オプション `:if` および `:unless` に文字列を渡すことは非推奨となりました。
    ([Commit](https://github.com/rails/rails/commit/0952552))

### 注目すべき変更

*   DST の変更に関して一貫性のあるパースとトラベリングを修正しました。
    ([Commit](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [Pull Request](https://github.com/rails/rails/pull/26597))

*   Unicode をバージョン 9.0.0 に更新しました。
    ([Pull Request](https://github.com/rails/rails/pull/27822))

*   Duration#ago および #since のエイリアスとして Duration#before および #after を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/27721))

*   現在のオブジェクトで定義されていないメソッド呼び出しをプロキシオブジェクトに委譲するための `Module#delegate_missing_to` を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/23930))

*   現在の日付と時刻を表す範囲を返す `Date#all_day` を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/24930))

*   テストのための `assert_changes` および `assert_no_changes` メソッドを導入しました。
    ([Pull Request](https://github.com/rails/rails/pull/25393))

*   `travel` および `travel_to` メソッドは、ネストした呼び出しで例外を発生させるようになりました。
    ([Pull Request](https://github.com/rails/rails/pull/24890))

*   `DateTime#change` を usec および nsec をサポートするように更新しました。
    ([Pull Request](https://github.com/rails/rails/pull/28242))

クレジット
-------

Rails の安定かつ堅牢なフレームワークに多くの時間を費やした多くの人々に感謝します。Rails の
[貢献者の完全なリスト](https://contributors.rubyonrails.org/)を参照してください。

[railties]:       https://github.com/rails/rails/blob/5-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-1-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
