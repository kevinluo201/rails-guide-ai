**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4d8311a1435138a81e26a7e8f537dbde
Ruby on Rails 4.2 リリースノート
===============================

Rails 4.2 のハイライト：

* Active Job
* 非同期メール
* Adequate Record
* Web Console
* 外部キーのサポート

これらのリリースノートは主な変更点のみをカバーしています。他の機能、バグ修正、変更点については、変更ログを参照するか、GitHub 上のメインの Rails リポジトリの [コミットリスト](https://github.com/rails/rails/commits/4-2-stable) を確認してください。

--------------------------------------------------------------------------------

Rails 4.2 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合、アップグレード前に十分なテストカバレッジを持っていることが重要です。また、Rails 4.1 に先にアップグレードし、アプリケーションが正常に動作することを確認してから、Rails 4.2 にアップグレードすることをお勧めします。アップグレード時に注意すべき点のリストは、ガイドの [Ruby on Rails のアップグレード](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2) で入手できます。


主な機能
--------------

### Active Job

Active Job は、Rails 4.2 の新しいフレームワークです。これは、[Resque](https://github.com/resque/resque)、[Delayed Job](https://github.com/collectiveidea/delayed_job)、[Sidekiq](https://github.com/mperham/sidekiq) などのキューシステム上で共通のインターフェースを提供します。

Active Job API で書かれたジョブは、それぞれのアダプターによってサポートされるキューのいずれかで実行されます。Active Job には、ジョブを直ちに実行するインラインランナーがデフォルトで用意されています。

ジョブはしばしば Active Record オブジェクトを引数として受け取る必要があります。Active Job は、オブジェクト自体をマーシャリングするのではなく、オブジェクトへの参照を URI (uniform resource identifier) として渡します。新しい [Global ID](https://github.com/rails/globalid) ライブラリは、URI を構築し、それらが参照するオブジェクトを検索します。Active Record オブジェクトをジョブの引数として渡すことは、Global ID を内部的に使用することでうまく動作します。

たとえば、`trashable` が Active Record オブジェクトである場合、次のジョブはシリアライズなしで正常に実行されます：

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

詳細については、[Active Job Basics](active_job_basics.html) ガイドを参照してください。

### 非同期メール

Active Job をベースにして、Action Mailer には `deliver_later` メソッドが追加されました。このメソッドを使用すると、メールをキューを介して送信するため、キューが非同期である場合にはコントローラーやモデルをブロックしなくなります（デフォルトのインラインキューはブロックします）。

メールを直ちに送信することも、引き続き `deliver_now` で可能です。

### Adequate Record

Adequate Record は、Active Record のパフォーマンス改善セットであり、一般的な `find` や `find_by` の呼び出し、および一部の関連クエリを最大2倍高速化します。

これは、一般的な SQL クエリをプリペアドステートメントとしてキャッシュし、類似の呼び出しで再利用することで動作します。これにより、後続の呼び出しではクエリ生成のほとんどの作業をスキップできます。詳細については、[Aaron Patterson のブログ記事](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html) を参照してください。

Active Record は、ユーザーの関与やコードの変更なしに、サポートされる操作で自動的にこの機能を利用します。以下に、サポートされる操作のいくつかの例を示します：

```ruby
Post.find(1)  # 最初の呼び出しはプリペアドステートメントを生成してキャッシュする
Post.find(2)  # 後続の呼び出しはキャッシュされたプリペアドステートメントを再利用する

Post.find_by_title('first post')
Post.find_by_title('second post')

Post.find_by(title: 'first post')
Post.find_by(title: 'second post')

post.comments
post.comments(true)
```

上記の例が示すように、プリペアドステートメントはメソッド呼び出しに渡される値をキャッシュしません。代わりに、値のプレースホルダーを持っています。

次のシナリオではキャッシュは使用されません：
- モデルにはデフォルトのスコープがあります
- モデルは単一テーブル継承を使用しています
- `find` にIDのリストを指定します。例えば:

    ```ruby
    # キャッシュされていない
    Post.find(1, 2, 3)
    Post.find([1,2])
    ```

- `find_by` にSQLフラグメントを指定します:

    ```ruby
    Post.find_by('published_at < ?', 2.weeks.ago)
    ```

### Webコンソール

Rails 4.2で生成された新しいアプリケーションには、デフォルトで[Web
Console](https://github.com/rails/web-console) gemが含まれています。Web Consoleは、エラーページごとに対話型のRubyコンソールを追加し、`console`ビューとコントローラーヘルパーを提供します。

エラーページ上の対話型コンソールでは、例外が発生した場所のコンテキストでコードを実行することができます。`console`ヘルパーは、ビューまたはコントローラーのどこでも呼び出された場合、レンダリングが完了した後に最終的なコンテキストで対話型コンソールを起動します。

### 外部キーのサポート

マイグレーションDSLは、外部キーの追加と削除をサポートしています。これらは`schema.rb`にもダンプされます。現時点では、`mysql`、`mysql2`、`postgresql`アダプタのみが外部キーをサポートしています。

```ruby
# `articles.author_id`を`authors.id`を参照する外部キーを追加
add_foreign_key :articles, :authors

# `articles.author_id`を`users.lng_id`を参照する外部キーを追加
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# `accounts.branch_id`の外部キーを削除
remove_foreign_key :accounts, :branches

# `accounts.owner_id`の外部キーを削除
remove_foreign_key :accounts, column: :owner_id
```

詳細については、[add_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)と[remove_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)のAPIドキュメントを参照してください。


非互換性
-----------------

以前に非推奨とされていた機能は削除されました。このリリースでの新しい非推奨事項については、個々のコンポーネントを参照してください。

以下の変更は、アップグレード時に直ちに対応が必要な場合があります。

### 文字列引数を使用した`render`

以前は、コントローラのアクションで`render "foo/bar"`を呼び出すと、`render file: "foo/bar"`と同じ意味でした。Rails 4.2では、これは`render template: "foo/bar"`を意味するように変更されました。ファイルをレンダリングする必要がある場合は、コードを明示的な形式（`render file: "foo/bar"`）に変更してください。

### `respond_with` / クラスレベルの`respond_to`

`respond_with`と対応するクラスレベルの`respond_to`は、[responders](https://github.com/plataformatec/responders) gemに移動されました。使用するには、`Gemfile`に`gem 'responders', '~> 2.0'`を追加してください。

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

インスタンスレベルの`respond_to`は影響を受けません。

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

### `rails server`のデフォルトホスト

Rackの[変更](https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc)により、`rails server`はデフォルトで`0.0.0.0`ではなく`localhost`でリッスンするようになりました。これは、開発ワークフローにほとんど影響を与えません。自分のマシン上では、http://127.0.0.1:3000とhttp://localhost:3000の両方が以前と同様に機能します。

ただし、この変更により、開発環境が仮想マシンにあり、ホストマシンからアクセスしたい場合など、別のマシンからRailsサーバーにアクセスできなくなります。その場合は、`rails server -b 0.0.0.0`でサーバーを起動して、古い動作を復元してください。

これを行う場合は、ファイアウォールを適切に設定して、信頼できるネットワーク内のマシンのみが開発サーバーにアクセスできるようにしてください。
### `render`のための変更されたステータスオプションシンボル

[Rackの変更](https://github.com/rack/rack/commit/be28c6a2ac152fe4adfbef71f3db9f4200df89e8)により、`render`メソッドが受け入れる`:status`オプションのシンボルが変更されました。

- 306: `:reserved`が削除されました。
- 413: `:request_entity_too_large`が`：payload_too_large`に名前が変更されました。
- 414: `:request_uri_too_long`が`：uri_too_long`に名前が変更されました。
- 416: `:requested_range_not_satisfiable`が`：range_not_satisfiable`に名前が変更されました。

不明なシンボルで`render`を呼び出す場合、レスポンスステータスはデフォルトで500になります。

### HTMLサニタイザ

HTMLサニタイザは、[Loofah](https://github.com/flavorjones/loofah)と[Nokogiri](https://github.com/sparklemotion/nokogiri)を基にした新しい、より堅牢な実装に置き換えられました。新しいサニタイザはより安全で、サニタイズはより強力で柔軟です。

新しいアルゴリズムにより、特定の病的な入力に対してサニタイズされた出力が異なる場合があります。

古いサニタイザの正確な出力が必要な場合は、`Gemfile`に[rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer)ジェムを追加して、古い動作を行うことができます。このジェムはオプトインであり、非推奨の警告を発行しません。

`rails-deprecated_sanitizer`はRails 4.2のみサポートされ、Rails 5.0ではメンテナンスされません。

新しいサニタイザの変更の詳細については、[このブログ記事](https://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/)を参照してください。

### `assert_select`

`assert_select`は現在[Nokogiri](https://github.com/sparklemotion/nokogiri)をベースにしています。その結果、以前は有効だったセレクタの一部がサポートされなくなりました。アプリケーションがこれらのスペルを使用している場合は、更新する必要があります。

* 属性セレクタの値には、非英数字の文字が含まれている場合、引用符で囲む必要があるかもしれません。

    ```ruby
    # 以前
    a[href=/]
    a[href$=/]

    # 現在
    a[href="/"]
    a[href$="/"]
    ```

* 不正なHTMLを含むHTMLソースから構築されたDOMは、違いが生じる場合があります。

    例えば:

    ```ruby
    # content: <div><i><p></i></div>

    # 以前:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => false
    assert_select('i > p')    # => true

    # 現在:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => true
    assert_select('i > p')    # => false
    ```

* 選択されたデータにエンティティが含まれている場合、以前は生の値（例：`AT&amp;T`）が選択され、現在は評価されます（例：`AT&T`）。

    ```ruby
    # content: <p>AT&amp;T</p>

    # 以前:
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # 現在:
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

さらに、置換の構文も変更されました。

今は`:match` CSSのようなセレクタを使用する必要があります。

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

また、アサーションが失敗した場合、正規表現の置換は異なる見た目になります。ここでは`/hello/`:

```ruby
assert_select(":match('id', ?)", /hello/)
```

が`"(?-mix:hello)"`になります:

```
Expected at least 1 element matching "div:match('id', "(?-mix:hello)")", found 0..
Expected 0 to be >= 1.
```

`assert_select`の詳細については、[Rails Dom Testing](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b)のドキュメントを参照してください。


Railties
--------

詳細な変更については、[Changelog][railties]を参照してください。

### 削除

* アプリケーションジェネレータから`--skip-action-view`オプションが削除されました。([Pull Request](https://github.com/rails/rails/pull/17042))

* `rails application`コマンドが削除され、代替機能はありません。([Pull Request](https://github.com/rails/rails/pull/11616))

### 非推奨

* 本番環境の`config.log_level`の不足が非推奨となりました。([Pull Request](https://github.com/rails/rails/pull/16622))

* `rake test:all`は`test`フォルダ内のすべてのテストを実行するため、`rake test`に非推奨となりました。([Pull Request](https://github.com/rails/rails/pull/17348))
* `rake test:all:db`を`rake test:db`に置き換えるために非推奨にしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/17348))

* `Rails::Rack::LogTailer`を非推奨にしましたが、代替はありません。
    ([コミット](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### 注目すべき変更点

* デフォルトのアプリケーションの`Gemfile`に`web-console`を導入しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/11667))

* モデルジェネレータに`required`オプションを追加して、関連付けのために使用できるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16062))

* カスタムの設定オプションを定義するための`x`名前空間を導入しました：

    ```ruby
    # config/environments/production.rb
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries  = 3
    config.x.super_debugger              = true
    ```

    これらのオプションは設定オブジェクトを介して利用できます：

    ```ruby
    Rails.configuration.x.payment_processing.schedule # => :daily
    Rails.configuration.x.payment_processing.retries  # => 3
    Rails.configuration.x.super_debugger              # => true
    ```

    ([コミット](https://github.com/rails/rails/commit/611849772dd66c2e4d005dcfe153f7ce79a8a7db))

* 現在の環境の設定を読み込むための`Rails::Application.config_for`を導入しました。

    ```yaml
    # config/exception_notification.yml
    production:
      url: http://127.0.0.1:8080
      namespace: my_app_production
    development:
      url: http://localhost:3001
      namespace: my_app_development
    ```

    ```ruby
    # config/environments/production.rb
    Rails.application.configure do
      config.middleware.use ExceptionNotifier, config_for(:exception_notification)
    end
    ```

    ([プルリクエスト](https://github.com/rails/rails/pull/16129))

* アプリケーションジェネレータに`--skip-turbolinks`オプションを導入して、turbolinksの統合を生成しないようにしました。
    ([コミット](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

* アプリケーションをブートストラップする際の自動設定コードの慣例として`bin/setup`スクリプトを導入しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/15189))

* `config.assets.digest`のデフォルト値を開発環境で`true`に変更しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/15155))

* `rake notes`の新しい拡張機能を登録するためのAPIを導入しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14379))

* Railsテンプレートで使用するための`after_bundle`コールバックを導入しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16359))

* `Rails.gem_version`を導入し、`Gem::Version.new(Rails.version)`を返す便利なメソッドとしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

詳細な変更点については、[Changelog][action-pack]を参照してください。

### 削除

* `respond_with`とクラスレベルの`respond_to`をRailsから削除し、`responders` gem（バージョン2.0）に移動しました。これらの機能を引き続き使用するには、`Gemfile`に`gem 'responders', '~> 2.0'`を追加してください。
    ([プルリクエスト](https://github.com/rails/rails/pull/16526),
     [詳細はこちら](https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders))

* 非推奨の`AbstractController::Helpers::ClassMethods::MissingHelperError`を`AbstractController::Helpers::MissingHelperError`に置き換えました。
    ([コミット](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### 非推奨

* `*_path`ヘルパーの`only_path`オプションを非推奨にしました。
    ([コミット](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9))

* `assert_tag`、`assert_no_tag`、`find_tag`、`find_all_tag`を`assert_select`に置き換えました。
    ([コミット](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

* ルータの`:to`オプションにシンボルまたは"#"文字を含まない文字列を設定するサポートを非推奨にしました：

    ```ruby
    get '/posts', to: MyRackApp    => (変更の必要なし)
    get '/posts', to: 'post#index' => (変更の必要なし)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```

    ([コミット](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

* URLヘルパーで文字列のキーを使用することを非推奨にしました：

    ```ruby
    # bad
    root_path('controller' => 'posts', 'action' => 'index')

    # good
    root_path(controller: 'posts', action: 'index')
    ```

    ([プルリクエスト](https://github.com/rails/rails/pull/17743))

### 注目すべき変更点

* ドキュメントから`*_filter`メソッド群を削除しました。これらの使用は非推奨であり、`*_action`メソッド群を使用することが推奨されています：

    ```
    after_filter          => after_action
    append_after_filter   => append_after_action
    append_around_filter  => append_around_action
    append_before_filter  => append_before_action
    around_filter         => around_action
    before_filter         => before_action
    prepend_after_filter  => prepend_after_action
    prepend_around_filter => prepend_around_action
    prepend_before_filter => prepend_before_action
    skip_after_filter     => skip_after_action
    skip_around_filter    => skip_around_action
    skip_before_filter    => skip_before_action
    skip_filter           => skip_action_callback
    ```

    アプリケーションが現在これらのメソッドに依存している場合は、代わりに`*_action`メソッドを使用する必要があります。これらのメソッドは将来的に非推奨となり、最終的にRailsから削除されます。

    (コミット [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de),
    [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4))

* `render nothing: true`または`nil`のボディをレンダリングすると、レスポンスボディに単一のスペースのパディングが追加されなくなりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14883))
* Railsは、テンプレートのダイジェストをETagに自動的に含めるようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16527))

* URLヘルパーに渡されるセグメントは、自動的にエスケープされるようになりました。
    ([コミット](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

* グローバルに許可されるパラメータを構成するための`always_permitted_parameters`オプションを導入しました。この設定のデフォルト値は`['controller', 'action']`です。
    ([プルリクエスト](https://github.com/rails/rails/pull/15933))

* [RFC 4791](https://tools.ietf.org/html/rfc4791)からHTTPメソッド`MKCALENDAR`を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/15121))

* `*_fragment.action_controller`通知には、コントローラとアクション名がペイロードに含まれるようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14137))

* ルーティングエラーページを改善し、ルート検索に対して曖昧なマッチングを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14619))

* CSRFの失敗のログ記録を無効化するオプションを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14280))

* Railsサーバーが静的アセットを提供するように設定されている場合、クライアントがサポートしており、ディスク上に事前生成されたgzipファイル（`.gz`）がある場合、gzipアセットが提供されるようになりました。デフォルトでは、アセットパイプラインは圧縮可能なすべてのアセットに対して`.gz`ファイルを生成します。gzipファイルを提供することで、データ転送を最小限に抑え、アセットリクエストを高速化することができます。本番環境でRailsサーバーからアセットを提供している場合は、常に[CDNを使用](https://guides.rubyonrails.org/v4.2/asset_pipeline.html#cdns)してください。
    ([プルリクエスト](https://github.com/rails/rails/pull/16466))

* 統合テストで`process`ヘルパーを呼び出す場合、パスには先頭にスラッシュが必要です。以前は省略することができましたが、それは実装の副産物であり意図的な機能ではありませんでした。例：

    ```ruby
    test "list all posts" do
      get "/posts"
      assert_response :success
    end
    ```

Action View
-----------

詳細な変更については、[Changelog][action-view]を参照してください。

### 廃止予定

* `AbstractController::Base.parent_prefixes`を廃止しました。ビューを検索する場所を変更する場合は、`AbstractController::Base.local_prefixes`をオーバーライドしてください。
    ([プルリクエスト](https://github.com/rails/rails/pull/15026))

* `ActionView::Digestor#digest(name, format, finder, options = {})`を廃止しました。引数はハッシュとして渡す必要があります。
    ([プルリクエスト](https://github.com/rails/rails/pull/14243))

### 注目すべき変更

* `render "foo/bar"`は、`render template: "foo/bar"`ではなく、`render file: "foo/bar"`に展開されるようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16888))

* フォームヘルパーは、非表示フィールドの周りにインラインCSSを持つ`<div>`要素を生成しなくなりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14738))

* コレクションでレンダリングされるパーシャルに使用するための`#{partial_name}_iteration`という特別なローカル変数を導入しました。`index`、`size`、`first?`、`last?`メソッドを介して現在のイテレーションの状態にアクセスできます。
    ([プルリクエスト](https://github.com/rails/rails/pull/7698))

* プレースホルダのI18nは、`label`のI18nと同じ規則に従います。
    ([プルリクエスト](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

詳細な変更については、[Changelog][action-mailer]を参照してください。

### 廃止予定

* メーラー内の`*_path`ヘルパーを廃止しました。常に`*_url`ヘルパーを使用してください。
    ([プルリクエスト](https://github.com/rails/rails/pull/15840))

* `deliver` / `deliver!`を廃止し、`deliver_now` / `deliver_now!`を使用するようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16582))

### 注目すべき変更

* テンプレートで`link_to`と`url_for`はデフォルトで絶対URLを生成するようになりました。`only_path: false`を渡す必要はもはやありません。
    ([コミット](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

* 非同期にメールを配信するために、`deliver_later`を導入し、アプリケーションのキューにジョブをエンキューするようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16485))

* メーラープレビューを開発環境以外でも有効にするための`show_previews`構成オプションを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/15970))


Active Record
-------------

詳細な変更については、[Changelog][active-record]を参照してください。

### 削除

* `cache_attributes`および関連するメソッドを削除しました。すべての属性はキャッシュされます。
    ([プルリクエスト](https://github.com/rails/rails/pull/15429))

* 廃止予定のメソッド`ActiveRecord::Base.quoted_locking_column`を削除しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/15612))

* 廃止予定の`ActiveRecord::Migrator.proper_table_name`を削除しました。代わりに`ActiveRecord::Migration`のインスタンスメソッド`proper_table_name`を使用してください。
    ([プルリクエスト](https://github.com/rails/rails/pull/15512))

* 未使用の`:timestamp`タイプを削除しました。すべての場合において`:datetime`にエイリアスします。XMLシリアライズなど、Active Recordの外部にカラムタイプが送信される場合の不整合を修正します。
    ([プルリクエスト](https://github.com/rails/rails/pull/15184))
### 廃止予定

*   `after_commit`と`after_rollback`内でのエラーの無視を廃止しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16537))

*   `has_many :through`関連でのカウンターキャッシュの自動検出のサポートが廃止されました。
    代わりに、スルーレコードの`has_many`と`belongs_to`関連でカウンターキャッシュを手動で指定する必要があります。
    ([プルリクエスト](https://github.com/rails/rails/pull/15754))

*   `.find`または`.exists?`にActive Recordオブジェクトを渡すことは廃止されました。まずオブジェクトに対して`id`を呼び出してください。
    (コミット [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
    [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   PostgreSQLの範囲値の除外開始に対する不完全なサポートを廃止しました。現在、PostgreSQLの範囲をRubyの範囲にマッピングしていますが、Rubyの範囲は除外開始をサポートしていないため、完全な変換は不可能です。

    現在の解決策である開始の増分は正しくありませんし、廃止されました。`succ`が定義されていないサブタイプの場合、除外開始を持つ範囲に対しては`ArgumentError`が発生します。
    ([コミット](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   接続なしで`DatabaseTasks.load_schema`を呼び出すことは廃止されました。代わりに`DatabaseTasks.load_schema_current`を使用してください。
    ([コミット](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   置換なしで`sanitize_sql_hash_for_conditions`を廃止しました。クエリと更新を実行するために`Relation`を使用することが推奨されるAPIです。
    ([コミット](https://github.com/rails/rails/commit/d5902c9e))

*   `add_timestamps`と`t.timestamps`を`null`オプションを指定せずに使用することは廃止されました。Rails 5では、デフォルトの`null: true`が`null: false`に変更されます。
    ([プルリクエスト](https://github.com/rails/rails/pull/16481))

*   Active Recordで不要な`Reflection#source_macro`を置換なしで廃止しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16373))

*   置換なしで`serialized_attributes`を廃止しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/15704))

*   カラムが存在しない場合に`column_for_attribute`から`nil`を返すことは廃止されました。Rails 5.0では、代わりにヌルオブジェクトが返されます。
    ([プルリクエスト](https://github.com/rails/rails/pull/15878))

*   置換なしで、インスタンスの状態に依存する関連（引数を受け取るスコープで定義されたもの）を使用して`.joins`、`.preload`、`.eager_load`を使用することは廃止されました。
    ([コミット](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### 注目すべき変更点

*   `SchemaDumper`は`create_table`に`force: :cascade`を使用します。これにより、外部キーが存在する場合にスキーマを再読み込みすることが可能になります。

*   単数形の関連に`required`オプションを追加しました。これにより、関連に対して存在検証が定義されます。
    ([プルリクエスト](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty`は、可変値へのインプレース変更を検出するようになりました。Active Recordモデルのシリアライズされた属性は、変更がない場合に保存されなくなりました。これは、PostgreSQL上の文字列カラムやJSONカラムなどの他のタイプでも機能します。
    (プルリクエスト [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))

*   現在の環境のデータベースを空にするための`db:purge` Rakeタスクを導入しました。
    ([コミット](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

*   `ActiveRecord::Base#validate!`を導入しました。これにより、レコードが無効な場合に`ActiveRecord::RecordInvalid`が発生します。
    ([プルリクエスト](https://github.com/rails/rails/pull/8639))

*   `validate`を`valid?`のエイリアスとして導入しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14456))

*   `touch`は複数の属性を一度にタッチすることができるようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14423))

*   PostgreSQLアダプタは、PostgreSQL 9.4+で`jsonb`データ型をサポートするようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16220))

*   PostgreSQLおよびSQLiteアダプタは、文字列カラムのデフォルトの制限を255文字から削除しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14579))

*   PostgreSQLアダプタで`citext`カラムタイプをサポートするようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/12523))

*   PostgreSQLアダプタでユーザーが作成した範囲型をサポートするようになりました。
    ([コミット](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

*   `sqlite3:///some/path`は絶対システムパス`/some/path`に解決されるようになりました。相対パスの場合は、代わりに`sqlite3:some/path`を使用してください。
    （以前は、`sqlite3:///some/path`は相対パス`some/path`に解決されました。この動作はRails 4.1で廃止されました）。
    ([プルリクエスト](https://github.com/rails/rails/pull/14569))

*   MySQL 5.6以降での小数秒のサポートを追加しました。
    (プルリクエスト [1](https://github.com/rails/rails/pull/8240),
    [2](https://github.com/rails/rails/pull/14359))
*   モデルをきれいに表示するために、`ActiveRecord::Base#pretty_print`を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload`は、`m = Model.find(m.id)`と同じように動作するようになりました。
    つまり、カスタムの`SELECT`からの余分な属性を保持しなくなりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/15866))

*   `ActiveRecord::Base#reflections`は、シンボルキーの代わりに文字列キーを持つハッシュを返すようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/17718))

*   マイグレーションの`references`メソッドは、外部キーのタイプを指定するための`type`オプションをサポートするようになりました（例：`:uuid`）。
    ([プルリクエスト](https://github.com/rails/rails/pull/16231))

Active Model
------------

詳細な変更については、[Changelog][active-model]を参照してください。

### 削除

*   代替なしで非推奨の`Validator#setup`を削除しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/10716))

### 非推奨

*   `reset_#{attribute}`を`restore_#{attribute}`に非推奨としました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16180))

*   `ActiveModel::Dirty#reset_changes`を`clear_changes_information`に非推奨としました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16180))

### 注目すべき変更

*   `valid?`の別名として`validate`を導入しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14456))

*   `ActiveModel::Dirty`の`restore_attributes`メソッドを導入し、変更（dirty）された属性を以前の値に戻します。
    (プルリクエスト [1](https://github.com/rails/rails/pull/14861),
    [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password`は、デフォルトで空のパスワード（スペースのみを含むパスワード）を許可するようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16412))

*   `has_secure_password`は、バリデーションが有効な場合、与えられたパスワードが72文字未満であることを検証するようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/15708))

Active Support
--------------

詳細な変更については、[Changelog][active-support]を参照してください。

### 削除

*   非推奨の`Numeric#ago`、`Numeric#until`、`Numeric#since`、`Numeric#from_now`を削除しました。
    ([コミット](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   `ActiveSupport::Callbacks`の非推奨の文字列ベースの終端子を削除しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/15100))

### 非推奨

*   代替なしで非推奨の`Kernel#silence_stderr`、`Kernel#capture`、`Kernel#quietly`を削除しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/13392))

*   `Class#superclass_delegating_accessor`を非推奨とし、`Class#class_attribute`を使用するようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14271))

*   `ActiveSupport::SafeBuffer#prepend!`を非推奨とし、`ActiveSupport::SafeBuffer#prepend`が同じ機能を実行するようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/14529))

### 注目すべき変更

*   テストケースの実行順序を指定するための新しい設定オプション`active_support.test_order`を導入しました。このオプションは現在はデフォルトで`sorted`になっていますが、Rails 5.0では`random`に変更されます。
    ([コミット](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   `Object#try`と`Object#try!`は、ブロック内で明示的なレシーバーなしで使用することができるようになりました。
    ([コミット](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830),
    [プルリクエスト](https://github.com/rails/rails/pull/17361))

*   `travel_to`テストヘルパーは、`usec`コンポーネントを0に切り捨てるようになりました。
    ([コミット](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   `Object#itself`を同一関数として導入しました。
    (コミット [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810),
    [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   `Object#with_options`は、ブロック内で明示的なレシーバーなしで使用することができるようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16339))

*   文字列の単語数で文字列を切り詰めるための`String#truncate_words`を導入しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/16190))

*   `Hash#transform_values`と`Hash#transform_values!`を追加し、ハッシュの値を変更する一般的なパターンを簡素化しましたが、キーは変更しません。
    ([プルリクエスト](https://github.com/rails/rails/pull/15819))

*   `humanize`インフレクターヘルパーは、先頭のアンダースコアを削除するようになりました。
    ([コミット](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   `Concern#class_methods`を`module ClassMethods`の代替として導入し、`module Foo; extend ActiveSupport::Concern; end`の冗長なコードを避けるための`Kernel#concern`を導入しました。
    ([コミット](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   定数の自動ロードと再読み込みに関する新しい[ガイド](autoloading_and_reloading_constants_classic_mode.html)を追加しました。

クレジット
-------

Railsへの多くの時間を費やした多くの人々に感謝します。Railsを安定かつ堅牢なフレームワークにしてくれたすべての人々に感謝します。

[railties]:       https://github.com/rails/rails/blob/4-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/4-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/4-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/4-2-stable/actionmailer/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/4-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/4-2-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
