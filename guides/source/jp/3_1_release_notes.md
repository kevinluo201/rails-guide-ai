**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: da25f37b5b3eddff86c5b5b2cd24007f
Ruby on Rails 3.1 リリースノート
===============================

Rails 3.1 のハイライト:

* ストリーミング
* 可逆マイグレーション
* アセットパイプライン
* デフォルトの JavaScript ライブラリとして jQuery

これらのリリースノートは主要な変更のみをカバーしています。さまざまなバグ修正や変更については、変更ログを参照するか、GitHub 上のメインの Rails リポジトリの[コミットリスト](https://github.com/rails/rails/commits/3-1-stable)をチェックしてください。

--------------------------------------------------------------------------------

Rails 3.1 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合、アップグレードする前に十分なテストカバレッジを持つことが重要です。また、Rails 3 にアップグレードしていない場合は、まずそれを行い、アプリケーションが正常に動作することを確認してから、Rails 3.1 に更新しようとしてください。次に、以下の変更に注意してください:

### Rails 3.1 では少なくとも Ruby 1.8.7 が必要です

Rails 3.1 では Ruby 1.8.7 以上が必要です。以前の Ruby バージョンのサポートは公式に終了しており、できるだけ早くアップグレードする必要があります。Rails 3.1 は Ruby 1.9.2 とも互換性があります。

TIP: Ruby 1.8.7 p248 と p249 には、Rails をクラッシュさせるマーシャリングのバグがあります。ただし、Ruby Enterprise Edition では 1.8.7-2010.02 リリース以降、これらのバグが修正されています。1.9 系では、1.9.1 はまったく使用できず、セグフォルトが発生するため、スムーズな動作をするためには 1.9.2 に移行する必要があります。

### アプリケーションの更新内容

以下の変更は、Rails 3.1.3、最新の 3.1.x バージョンにアプリケーションをアップグレードするためのものです。

#### Gemfile

`Gemfile` に以下の変更を加えてください。

```ruby
gem 'rails', '= 3.1.3'
gem 'mysql2'

# 新しいアセットパイプラインに必要
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# Rails 3.1 ではデフォルトの JavaScript ライブラリとして jQuery を使用します
gem 'jquery-rails'
```

#### config/application.rb

* アセットパイプラインには以下の追加が必要です:

    ```ruby
    config.assets.enabled = true
    config.assets.version = '1.0'
    ```

* アプリケーションがリソースのために "/assets" ルートを使用している場合、アセットのプレフィックスを変更して競合を避ける必要があります:

    ```ruby
    # デフォルトは '/assets'
    config.assets.prefix = '/asset-files'
    ```

#### config/environments/development.rb

* RJS 設定 `config.action_view.debug_rjs = true` を削除してください。

* アセットパイプラインを有効にしている場合、以下を追加してください。

    ```ruby
    # アセットを圧縮しない
    config.assets.compress = false

    # アセットを読み込む行を展開する
    config.assets.debug = true
    ```

#### config/environments/production.rb

* 再び、以下の変更はほとんどがアセットパイプラインに関するものです。これらについては、[アセットパイプライン](asset_pipeline.html)ガイドで詳細を読むことができます。

    ```ruby
    # JavaScript と CSS を圧縮する
    config.assets.compress = true

    # プリコンパイルされたアセットが見つからない場合、アセットパイプラインにフォールバックしない
    config.assets.compile = false

    # アセットの URL にダイジェストを生成する
    config.assets.digest = true

    # Rails.root.join("public/assets") がデフォルトです
    # config.assets.manifest = YOUR_PATH

    # 追加のアセットをプリコンパイルする (application.js、application.css、およびすべての非 JS/CSS は既に追加されています)
    # config.assets.precompile `= %w( admin.js admin.css )


    # アプリケーションへのすべてのアクセスを SSL で行い、Strict-Transport-Security を使用し、セキュアなクッキーを使用します。
    # config.force_ssl = true
    ```

#### config/environments/test.rb

```ruby
# パフォーマンスのために Cache-Control を使用してテスト用の静的アセットサーバーを設定する
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

#### config/initializers/wrap_parameters.rb

* パラメータをネストしたハッシュにラップする場合は、以下の内容でこのファイルを追加してください。これは新しいアプリケーションではデフォルトで有効になっています。

    ```ruby
    # このファイルを変更した場合は、サーバーを再起動してください。
    # このファイルにはデフォルトで有効になっている ActionController::ParamsWrapper の設定が含まれています。

    # JSON のパラメータラッピングを有効にします。:format を空の配列に設定することで、これを無効にすることもできます。
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters :format => [:json]
    end

    # JSON でのルート要素をデフォルトで無効にします。
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
    ```

#### ビュー内のアセットヘルパーの参照で :cache と :concat オプションを削除する

* アセットパイプラインでは、:cache と :concat オプションは使用されなくなりましたので、ビューからこれらのオプションを削除してください。

Rails 3.1 アプリケーションの作成
--------------------------------

```bash
# 'rails' RubyGem がインストールされている必要があります
$ rails new myapp
$ cd myapp
```

### ジェムのベンダリング

Rails は現在、アプリケーションのルートにある `Gemfile` を使用して、アプリケーションの起動に必要なジェムを決定します。この `Gemfile` は [Bundler](https://github.com/carlhuda/bundler) ジェムによって処理され、依存関係のあるすべてのジェムがインストールされます。さらに、これらの依存関係をアプリケーションにローカルにインストールすることもできます。
詳細情報：- [bundlerホームページ](https://bundler.io/)

### 最新の情報

`Bundler`と`Gemfile`は、新しい専用の`bundle`コマンドを使用して、Railsアプリケーションを簡単に凍結することができます。Gitリポジトリから直接バンドルする場合は、`--edge`フラグを渡すことができます。

```bash
$ rails new myapp --edge
```

Railsリポジトリのローカルチェックアウトがあり、それを使用してアプリケーションを生成したい場合は、`--dev`フラグを渡すことができます。

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

Railsのアーキテクチャの変更
---------------------------

### アセットパイプライン

Rails 3.1の主な変更点は、アセットパイプラインです。これにより、CSSとJavaScriptが一流のコードとして扱われ、プラグインやエンジンでの使用を含む適切な組織化が可能になります。

アセットパイプラインは[Sprockets](https://github.com/rails/sprockets)によって動作し、[アセットパイプライン](asset_pipeline.html)ガイドで説明されています。

### HTTPストリーミング

HTTPストリーミングは、Rails 3.1で新しく追加された変更です。これにより、サーバーがレスポンスを生成している間に、ブラウザがスタイルシートやJavaScriptファイルをダウンロードすることができます。これにはRuby 1.9.2が必要であり、オプトインであり、Webサーバーからのサポートも必要ですが、NGINXとUnicornの人気の組み合わせはこれを活用する準備ができています。

### デフォルトのJSライブラリはjQueryになりました

Rails 3.1には、デフォルトのJavaScriptライブラリとしてjQueryが付属しています。ただし、Prototypeを使用する場合は、簡単に切り替えることができます。

```bash
$ rails new myapp -j prototype
```

### Identity Map

Rails 3.1では、Active RecordにIdentity Mapが追加されています。Identity Mapは、以前にインスタンス化されたレコードを保持し、再度アクセスされた場合に関連付けられたオブジェクトを返します。Identity Mapはリクエストごとに作成され、リクエストの完了時にフラッシュされます。

Rails 3.1では、Identity Mapはデフォルトで無効になっています。

Railties
--------

* jQueryは新しいデフォルトのJavaScriptライブラリです。

* jQueryとPrototypeはもはやベンダーになっておらず、`jquery-rails`と`prototype-rails`のgemから提供されます。

* アプリケーションジェネレータは、任意の文字列であるオプション`-j`を受け入れます。 "foo"が渡されると、"foo-rails"のgemが`Gemfile`に追加され、アプリケーションのJavaScriptマニフェストが "foo"と "foo_ujs"を要求します。現在、"prototype-rails"と"jquery-rails"のみが存在し、これらのファイルをアセットパイプラインを介して提供します。

* アプリケーションまたはプラグインの生成は、`--skip-gemfile`または`--skip-bundle`が指定されていない限り、`bundle install`を実行します。

* コントローラーおよびリソースのジェネレータは、自動的にアセットのスタブを生成します（`--skip-assets`で無効にすることもできます）。これらのスタブは、CoffeeScriptとSassを使用します（これらのライブラリが利用可能な場合）。

* スキャフォールドおよびアプリケーションのジェネレータは、Ruby 1.9で実行される場合にはRuby 1.9スタイルのハッシュを生成します。古いスタイルのハッシュを生成するには、`--old-style-hash`を渡すことができます。

* スキャフォールドコントローラージェネレータは、XMLの代わりにJSON用のフォーマットブロックを作成します。

* Active RecordのログはSTDOUTにリダイレクトされ、コンソールにインラインで表示されます。

* `config.force_ssl`設定が追加されました。これにより、`Rack::SSL`ミドルウェアが読み込まれ、すべてのリクエストがHTTPSプロトコルの下にあるように強制されます。

* `rails plugin new`コマンドが追加されました。これにより、gemspec、テスト、テスト用のダミーアプリケーションを含むRailsプラグインが生成されます。

* デフォルトのミドルウェアスタックに`Rack::Etag`と`Rack::ConditionalGet`が追加されました。

* デフォルトのミドルウェアスタックに`Rack::Cache`が追加されました。

* エンジンは大幅に更新されました-任意のパスにマウントでき、アセットを有効にしたり、ジェネレータを実行したりすることができます。

Action Pack
-----------

### Action Controller

* CSRFトークンの正当性が検証できない場合、警告が表示されます。

* 特定のコントローラーでデータの転送をHTTPSプロトコルを使用するようにブラウザに強制するには、コントローラーで`force_ssl`を指定します。特定のアクションに制限するには、`:only`または`:except`を使用できます。

* `config.filter_parameters`で指定された機密クエリ文字列パラメータは、ログのリクエストパスからフィルタリングされるようになりました。

* `to_param`が`nil`を返すURLパラメータは、クエリ文字列から削除されるようになりました。

* `ActionController::ParamsWrapper`が追加され、パラメータをネストしたハッシュにラップします。新しいアプリケーションのJSONリクエストではデフォルトで有効になります。これは`config/initializers/wrap_parameters.rb`でカスタマイズできます。

* `config.action_controller.include_all_helpers`が追加されました。デフォルトでは、`ActionController::Base`で`helper :all`が実行され、デフォルトですべてのヘルパーが含まれます。`include_all_helpers`を`false`に設定すると、application_helperとコントローラーに対応するヘルパー（foo_controllerの場合はfoo_helper）のみが含まれるようになります。

* `url_for`と名前付きURLヘルパーは、オプションとして`subdomain`と`domain`を受け入れるようになりました。
* `Base.http_basic_authenticate_with`を追加し、単一のクラスメソッド呼び出しで簡単なHTTPベーシック認証を行うようにしました。

    ```ruby
    class PostsController < ApplicationController
      USER_NAME, PASSWORD = "dhh", "secret"

      before_filter :authenticate, :except => [ :index ]

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end

      private
        def authenticate
          authenticate_or_request_with_http_basic do |user_name, password|
            user_name == USER_NAME && password == PASSWORD
          end
        end
    end
    ```

    ..は以下のように書くことができます

    ```ruby
    class PostsController < ApplicationController
      http_basic_authenticate_with :name => "dhh", :password => "secret", :except => :index

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end
    end
    ```

* ストリーミングサポートを追加し、次のように有効にすることができます：

    ```ruby
    class PostsController < ActionController::Base
      stream
    end
    ```

    `:only`または`:except`を使用して一部のアクションに制限することもできます。詳細については[`ActionController::Streaming`](https://api.rubyonrails.org/v3.1.0/classes/ActionController/Streaming.html)のドキュメントを参照してください。

* リダイレクトルートメソッドは、URLの特定の部分のみを変更するオプションのハッシュまたは呼び出し可能なオブジェクトも受け入れるようになりました。

### Action Dispatch

* `config.action_dispatch.x_sendfile_header`はデフォルトで`nil`になり、`config/environments/production.rb`では特定の値を設定しません。これにより、サーバーが`X-Sendfile-Type`を通じて設定できるようになります。

* `ActionDispatch::MiddlewareStack`は継承ではなくコンポジションを使用するようになり、もはや配列ではありません。

* `ActionDispatch::Request.ignore_accept_header`を追加して、acceptヘッダーを無視するようにしました。

* デフォルトのスタックに`Rack::Cache`を追加しました。

* etagの責任を`ActionDispatch::Response`からミドルウェアスタックに移動しました。

* より互換性のあるために、`Rack::Session`ストアAPIに依存するようにしました。これは、`Rack::Session`が`#get_session`を4つの引数で受け入れ、単純に`#destroy`ではなく`#destroy_session`を要求するため、後方互換性がありません。

* テンプレートの検索は、継承チェーンの上方にも検索するようになりました。

### Action View

* `form_tag`に`authenticity_token`オプションを追加し、カスタム処理またはトークンを省略するために`authenticity_token => false`を渡すことができるようにしました。

* `ActionView::Renderer`を作成し、`ActionView::Context`のAPIを指定しました。

* Rails 3.1では、SafeBufferの変更が禁止されています。

* HTML5の`button_tag`ヘルパーを追加しました。

* `file_field`は自動的に囲むフォームに`multipart => true`を追加します。

* `:data`ハッシュのオプションからHTML5のdata-*属性を生成するための便利なイディオムを追加しました：

    ```ruby
    tag("div", :data => {:name => 'Stephen', :city_state => %w(Chicago IL)})
    # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
    ```

キーはダッシュ区切りになります。値は文字列とシンボル以外はJSONエンコードされます。

* `csrf_meta_tag`は`csrf_meta_tags`に名前が変更され、後方互換性のために`csrf_meta_tag`のエイリアスも追加されました。

* 古いテンプレートハンドラAPIは非推奨となり、新しいAPIではテンプレートハンドラが`call`に応答することを要求します。

* rhtmlとrxmlはついにテンプレートハンドラから削除されました。

* `config.action_view.cache_template_loading`が復活し、テンプレートをキャッシュするかどうかを決定することができるようになりました。

* submitフォームヘルパーはもはやid "object_name_id"を生成しません。

* `FormHelper#form_for`で`:method`を直接オプションとして指定できるようになりました。`form_for(@post, remote: true, method: :delete)`のように`form_for(@post, remote: true, html: { method: :delete })`ではなくなりました。

* `JavaScriptHelper#j()`を`JavaScriptHelper#escape_javascript()`のエイリアスとして提供しました。これにより、JavaScriptHelperを使用してテンプレート内でJSONジェムが追加する`Object#j()`メソッドを上書きします。

* datetimeセレクタでAM/PM形式を許可しました。

* `auto_link`はRailsから削除され、[rails_autolink gem](https://github.com/tenderlove/rails_autolink)に抽出されました。

Active Record
-------------

* 個々のモデルのテーブル名を単数形/複数形にするためのクラスメソッド`pluralize_table_names`を追加しました。以前は`ActiveRecord::Base.pluralize_table_names`を介してすべてのモデルに対してグローバルに設定することしかできませんでした。

    ```ruby
    class User < ActiveRecord::Base
      self.pluralize_table_names = false
    end
    ```

* 単数の関連付けに対して属性の設定をブロックで行うことができるようになりました。ブロックはインスタンスが初期化された後に呼び出されます。

    ```ruby
    class User < ActiveRecord::Base
      has_one :account
    end

    user.build_account{ |a| a.credit_limit = 100.0 }
    ```

* `ActiveRecord::Base.attribute_names`を追加し、属性名のリストを返すようにしました。モデルが抽象的であるか、テーブルが存在しない場合は空の配列が返されます。

* CSVフィクスチャは非推奨となり、Rails 3.2.0でサポートが削除されます。

* `ActiveRecord#new`、`ActiveRecord#create`、`ActiveRecord#update_attributes`は、属性を割り当てる際にどのロールを考慮するかを指定するためのオプションとして2番目のハッシュを受け入れるようになりました。これはActive Modelの新しい一括割り当て機能を基にしています。
```ruby
class Post < ActiveRecord::Base
  attr_accessible :title
  attr_accessible :title, :published_at, :as => :admin
end

Post.new(params[:post], :as => :admin)
```

* `default_scope`はブロック、ラムダ、または他のcallに応答するオブジェクトを受け入れるようになりました。

* デフォルトスコープは、Model.unscopedを介して取り除くことができなくなる問題を避けるために、最も遅い時点で評価されるようになりました。

* PostgreSQLアダプタは、PostgreSQLバージョン8.2以上のみをサポートしています。

* `ConnectionManagement`ミドルウェアは、rackのボディがフラッシュされた後に接続プールをクリーンアップするように変更されました。

* Active Recordに`update_column`メソッドが追加されました。この新しいメソッドは、バリデーションとコールバックをスキップしてオブジェクトの指定された属性を更新します。`updated_at`カラムの変更を含むすべてのコールバックを実行したくない場合を除き、`update_attributes`または`update_attribute`を使用することをお勧めします。新しいレコードでは呼び出すべきではありません。

* `:through`オプションを持つ関連は、他の`has_and_belongs_to_many`関連や`:through`オプションを持つ他の関連を含む、任意の関連を使用できるようになりました。

* 現在のデータベース接続の設定は、`ActiveRecord::Base.connection_config`を介してアクセスできるようになりました。

* COUNTクエリからlimitsとoffsetが削除されました。

```ruby
People.limit(1).count           # => 'SELECT COUNT(*) FROM people'
People.offset(1).count          # => 'SELECT COUNT(*) FROM people'
People.limit(1).offset(1).count # => 'SELECT COUNT(*) FROM people LIMIT 1 OFFSET 1'
```

* `ActiveRecord::Associations::AssociationProxy`が分割されました。関連操作を担当する`Association`クラス（およびサブクラス）と、コレクション関連をプロキシする独立した薄いラッパーである`CollectionProxy`が別々になりました。これにより、名前空間の汚染を防ぎ、関心を分離し、さらなるリファクタリングを可能にします。

* 単数の関連（`has_one`、`belongs_to`）にはもはやプロキシがなく、関連するレコードまたは`nil`を単純に返します。これは、`bob.mother.create`などの未公開のメソッドを使用しないでください。代わりに`bob.create_mother`を使用してください。

* `has_many :through`関連に`dependent`オプションをサポートしました。歴史的および実用的な理由から、`association.delete(*records)`によるデフォルトの削除戦略は、通常の`has_many`の場合には`nullify`ですが、`delete_all`です。また、これはソースリフレクションがbelongs_toである場合にのみ機能します。他の状況では、直接through関連を変更する必要があります。

* `has_and_belongs_to_many`および`has_many :through`の`association.destroy`の動作が変更されました。以前は、関連するレコード自体を破棄していましたが、結合テーブルのレコードは削除しませんでした。今では、結合テーブルのレコードを削除します。

* 以前は、`has_and_belongs_to_many.destroy(*records)`はレコード自体を破棄していましたが、結合テーブルのレコードは削除しませんでした。今では、結合テーブルのレコードを削除します。

* 以前は、`has_many_through.destroy(*records)`はレコード自体と結合テーブルのレコードを破棄していました。[注：これは常にそうではありませんでした。以前のバージョンのRailsでは、レコード自体のみを削除しました。]今では、結合テーブルのレコードのみを削除します。

* この変更はある程度後方互換性がありますが、変更する前に「非推奨」にする方法は残念ながらありません。この変更は、異なるタイプの関連に対する「destroy」または「delete」の意味の一貫性を持つために行われています。レコード自体を破棄したい場合は、`records.association.each(&:destroy)`を使用できます。

* `change_table`に`：bulk => true`オプションを追加して、単一のALTERステートメントを使用してブロックで定義されたすべてのスキーマ変更を行います。

```ruby
change_table(:users, :bulk => true) do |t|
  t.string :company_name
  t.change :birthdate, :datetime
end
```

* `has_and_belongs_to_many`結合テーブルの属性へのアクセスのサポートが削除されました。`has_many :through`を使用する必要があります。

* `has_one`および`belongs_to`関連のための`create_association!`メソッドが追加されました。

* マイグレーションは今や逆転可能であり、Railsはマイグレーションを逆転する方法を自動的に見つけ出します。逆転可能なマイグレーションを使用するには、単に`change`メソッドを定義します。

```ruby
class MyMigration < ActiveRecord::Migration
  def change
    create_table(:horses) do |t|
      t.column :content, :text
      t.column :remind_at, :datetime
    end
  end
end
```

* いくつかのことは自動的に逆転できません。それらを逆転する方法を知っている場合は、マイグレーションで`up`と`down`を定義する必要があります。逆転できないものをchangeで定義すると、下に移動する際に`IrreversibleMigration`例外が発生します。

* マイグレーションは、クラスメソッドではなくインスタンスメソッドを使用するようになりました：
```ruby
class FooMigration < ActiveRecord::Migration
  def up # Not self.up
    # ...
  end
end
```

* モデルと構築的なマイグレーションジェネレータから生成されたマイグレーションファイル（例：add_name_to_users）は、通常の`up`と`down`メソッドの代わりに、可逆マイグレーションの`change`メソッドを使用します。

* 関連付けの文字列SQL条件の補間サポートが削除されました。代わりに、procを使用する必要があります。

```ruby
has_many :things, :conditions => 'foo = #{bar}'          # 以前
has_many :things, :conditions => proc { "foo = #{bar}" } # 以降
```

proc内では、`self`は関連付けの所有者であるオブジェクトです。ただし、関連付けをイーガーロードしている場合は、`self`は関連付けが含まれるクラスです。

proc内には、通常の条件を含めることができるため、次のようにも機能します。

```ruby
has_many :things, :conditions => proc { ["foo = ?", bar] }
```

* 以前の`has_and_belongs_to_many`関連付けの`:insert_sql`と`:delete_sql`では、挿入または削除されるレコードを取得するために'record'を呼び出すことができました。これは、現在はprocの引数として渡されます。

* `ActiveRecord::Base#has_secure_password`（`ActiveModel::SecurePassword`を介して）が追加され、BCrypt暗号化とソルトを使用したシンプルなパスワードの使用をカプセル化します。

```ruby
# スキーマ: User(name:string, password_digest:string, password_salt:string)
class User < ActiveRecord::Base
  has_secure_password
end
```

* モデルが生成されると、`belongs_to`または`references`のカラムに対してデフォルトで`add_index`が追加されます。

* `belongs_to`オブジェクトのidを設定すると、オブジェクトへの参照が更新されます。

* `ActiveRecord::Base#dup`と`ActiveRecord::Base#clone`のセマンティクスが通常のRubyのdupとcloneのセマンティクスに近づきました。

* `ActiveRecord::Base#clone`を呼び出すと、レコードの浅いコピーが作成され、凍結状態もコピーされます。コールバックは呼び出されません。

* `ActiveRecord::Base#dup`を呼び出すと、レコードが複製され、after initializeフックが呼び出されます。凍結状態はコピーされず、すべての関連付けがクリアされます。複製されたレコードは`new_record?`に対して`true`を返し、`nil`のidフィールドを持ち、保存可能です。

* クエリキャッシュはプリペアドステートメントと連携します。アプリケーションに変更は必要ありません。

Active Model
------------

* `attr_accessible`は、ロールを指定するオプション`:as`を受け入れます。

* `InclusionValidator`、`ExclusionValidator`、および`FormatValidator`は、proc、lambda、または`call`に応答するオブジェクトをオプションとして受け入れるようになりました。このオプションは、現在のレコードを引数として受け取り、`InclusionValidator`の場合は`include?`に応答するオブジェクト、`ExclusionValidator`の場合は`include?`に応答するオブジェクト、`FormatValidator`の場合は正規表現オブジェクトを返します。

* BCrypt暗号化とソルトを使用したシンプルなパスワードの使用をカプセル化するために、`ActiveModel::SecurePassword`が追加されました。

* `ActiveModel::AttributeMethods`は、要求に応じて属性を定義できるようにします。

* オブザーバーの有効化と無効化を選択的にサポートするためのサポートが追加されました。

* 代替の`I18n`名前空間の検索はサポートされなくなりました。

Active Resource
---------------

* すべてのリクエストのデフォルトフォーマットがJSONに変更されました。XMLを引き続き使用する場合は、クラスで`self.format = :xml`を設定する必要があります。例：

```ruby
class User < ActiveResource::Base
  self.format = :xml
end
```

Active Support
--------------

* `ActiveSupport::Dependencies`は、`load_missing_constant`で既存の定数が見つかった場合に`NameError`を発生させるようになりました。

* `STDOUT`と`STDERR`の両方を無音にするための新しいレポートメソッド`Kernel#quietly`が追加されました。

* `String#inquiry`は、Stringを`StringInquirer`オブジェクトに変換するための便利なメソッドとして追加されました。

* オブジェクトが別のオブジェクトに含まれているかどうかをテストするための`Object#in?`が追加されました。

* `LocalCache`ストラテジーは、匿名クラスではなく、本当のミドルウェアクラスとして実装されました。

* `ActiveSupport::Dependencies::ClassCache`クラスが導入され、リロード可能なクラスへの参照を保持するために使用されます。

* `ActiveSupport::Dependencies::Reference`は、新しい`ClassCache`を直接利用するようにリファクタリングされました。

* Ruby 1.8で`Range#include?`のエイリアスとして`Range#cover?`をバックポートしました。

* Date/DateTime/Timeに`weeks_ago`と`prev_week`が追加されました。

* `ActiveSupport::Dependencies.remove_unloadable_constants!`に`before_remove_const`コールバックが追加されました。

非推奨:

* `ActiveSupport::SecureRandom`は、Ruby標準ライブラリの`SecureRandom`に代わって非推奨です。

クレジット
-------

Railsの多くの人々が多くの時間を費やして、安定かつ堅牢なフレームワークであるRailsを作り上げたため、[Railsへの貢献者の完全なリスト](https://contributors.rubyonrails.org/)を参照してください。彼ら全員に敬意を表します。

Rails 3.1リリースノートは[Vijay Dev](https://github.com/vijaydev)によってまとめられました。
