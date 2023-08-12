**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 30550ed8fa3c0983f3d99a0e91571a98
Ruby on Rails 3.2 リリースノート
===============================

Rails 3.2 のハイライト：

* より高速な開発モード
* 新しいルーティングエンジン
* 自動クエリの説明
* タグ付きログ

これらのリリースノートでは、主な変更のみをカバーしています。さまざまなバグ修正や変更については、変更ログを参照するか、GitHub のメイン Rails リポジトリの[コミットリスト](https://github.com/rails/rails/commits/3-2-stable)をチェックしてください。

--------------------------------------------------------------------------------

Rails 3.2 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合、アップグレードを行う前に十分なテストカバレッジを持っていることが重要です。また、Rails 3.2 への更新を試みる前に、まず Rails 3.1 にアップグレードし、アプリケーションが正常に動作することを確認してください。次に、以下の変更に注意してください：

### Rails 3.2 では Ruby 1.8.7 以上が必要です

Rails 3.2 では Ruby 1.8.7 以上が必要です。以前のすべての Ruby バージョンのサポートは公式に終了されており、できるだけ早くアップグレードする必要があります。Rails 3.2 は Ruby 1.9.2 とも互換性があります。

TIP: Ruby 1.8.7 p248 と p249 には、Rails をクラッシュさせるマーシャリングのバグがあります。Ruby Enterprise Edition では、1.8.7-2010.02 のリリース以降、これらのバグが修正されています。1.9.x を使用する場合、Ruby 1.9.1 は使用できません。なぜなら、それが完全にセグフォルトするからです。したがって、スムーズに動作するためには、1.9.2 または 1.9.3 に移行してください。

### アプリケーションの更新内容

* `Gemfile` を以下のように更新します
    * `rails = 3.2.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

* Rails 3.2 では `vendor/plugins` が非推奨となり、Rails 4.0 では完全に削除されます。これらのプラグインは、gem として抽出して `Gemfile` に追加することで置き換えることができます。gem にしない場合は、`lib/my_plugin/*` に移動し、`config/initializers/my_plugin.rb` に適切な初期化子を追加することができます。

* `config/environments/development.rb` に以下の新しい設定変更を追加する必要があります：

    ```ruby
    # Active Record モデルのマスアサインメント保護において例外を発生させる
    config.active_record.mass_assignment_sanitizer = :strict

    # この秒数以上かかるクエリのクエリプランをログに出力する（SQLite、MySQL、PostgreSQL で動作します）
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    `mass_assignment_sanitizer` の設定は、`config/environments/test.rb` にも追加する必要があります：

    ```ruby
    # Active Record モデルのマスアサインメント保護において例外を発生させる
    config.active_record.mass_assignment_sanitizer = :strict
    ```

### エンジンの更新内容

`script/rails` のコメントの下にあるコードを以下の内容で置き換えます：

```ruby
ENGINE_ROOT = File.expand_path('../..', __FILE__)
ENGINE_PATH = File.expand_path('../../lib/your_engine_name/engine', __FILE__)

require "rails/all"
require "rails/engine/commands"
```

Rails 3.2 アプリケーションの作成
--------------------------------

```bash
# 'rails' RubyGem がインストールされている必要があります
$ rails new myapp
$ cd myapp
```

### ジェムのベンダリング

Rails は、アプリケーションのルートにある `Gemfile` を使用して、アプリケーションの起動に必要なジェムを決定します。この `Gemfile` は、[Bundler](https://github.com/carlhuda/bundler) ジェムによって処理され、すべての依存関係がインストールされます。さらに、アプリケーションに依存関係がないように、すべての依存関係をローカルにインストールすることもできます。

詳細はこちら：[Bundler ホームページ](https://bundler.io/)

### 最新版の利用

`Bundler` と `Gemfile` により、新しい専用の `bundle` コマンドを使用して、Rails アプリケーションを簡単にフリーズすることができます。Git リポジトリから直接バンドルする場合は、`--edge` フラグを渡すことができます：

```bash
$ rails new myapp --edge
```

Rails リポジトリのローカルチェックアウトがあり、それを使用してアプリケーションを生成したい場合は、`--dev` フラグを渡すことができます：

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

主な機能
--------------

### より高速な開発モードとルーティング

Rails 3.2 には、著しく高速な開発モードが搭載されています。[Active Reload](https://github.com/paneq/active_reload)に触発され、Rails はファイルが実際に変更された場合にのみクラスをリロードします。これにより、大規模なアプリケーションでのパフォーマンスの向上が顕著です。また、新しい[Journey](https://github.com/rails/journey)エンジンのおかげで、ルートの認識も大幅に高速化されました。

### 自動クエリの説明

Rails 3.2 には、Arel が生成するクエリを説明するための `ActiveRecord::Relation` に `explain` メソッドを定義する素晴らしい機能が搭載されています。たとえば、`puts Person.active.limit(5).explain` のようなコマンドを実行すると、Arel が生成するクエリが説明されます。これにより、適切なインデックスやさらなる最適化を確認することができます。

実行に 0.5 秒以上かかるクエリは、開発モードでは*自動的に*説明されます。もちろん、この閾値は変更できます。

### タグ付きログ
マルチユーザー、マルチアカウントのアプリケーションを実行する際には、誰が何をしたかによってログをフィルタリングできると非常に便利です。Active SupportのTaggedLoggingを使用すると、このようなアプリケーションのデバッグを支援するために、ログ行にサブドメイン、リクエストIDなどをスタンプすることができます。

ドキュメント
-------------

Rails 3.2以降、RailsガイドはKindleおよびiPad、iPhone、Mac、Androidなどの無料のKindle Reading Appsで利用できます。

Railties
--------

* 依存関係ファイルが変更された場合にのみクラスを再読み込みして開発を高速化します。これは、`config.reload_classes_only_on_change`をfalseに設定することで無効にすることができます。

* 新しいアプリケーションでは、環境設定ファイルに`config.active_record.auto_explain_threshold_in_seconds`フラグが追加されます。`development.rb`では`0.5`の値が設定され、`production.rb`ではコメントアウトされます。`test.rb`には言及されていません。

* `config.exceptions_app`を追加して、例外が発生したときに`ShowException`ミドルウェアによって呼び出される例外アプリケーションを設定できるようにしました。デフォルトは`ActionDispatch::PublicExceptions.new(Rails.public_path)`です。

* `ShowExceptions`ミドルウェアから抽出された機能を含む`DebugExceptions`ミドルウェアを追加しました。

* `rake routes`でマウントされたエンジンのルートを表示します。

* `config.railties_order`を使用して、railtiesの読み込み順序を変更できるようにしました。以下のように設定できます。

    ```ruby
    config.railties_order = [Blog::Engine, :main_app, :all]
    ```

* APIリクエストのコンテンツがない場合、Scaffoldは204 No Contentを返します。これにより、Scaffoldをそのまま使用してjQueryと連携することができます。

* `Rails::Rack::Logger`ミドルウェアを更新して、`config.log_tags`で設定されたタグを`ActiveSupport::TaggedLogging`に適用します。これにより、サブドメインやリクエストIDなどのデバッグ情報をログ行にタグ付けすることが簡単になります。これは、マルチユーザーの本番アプリケーションのデバッグに非常に役立ちます。

* デフォルトの`rails new`オプションは`~/.railsrc`に設定できます。ホームディレクトリの`.railsrc`設定ファイルに、`rails new`が実行されるたびに使用される追加のコマンドライン引数を指定できます。

* `destroy`のエイリアスとして`d`を追加しました。これはエンジンでも機能します。

* Scaffoldとモデルのジェネレータの属性はデフォルトで文字列になります。これにより、次のようなことが可能になります：`bin/rails g scaffold Post title body:text author`

* Scaffold/モデル/マイグレーションのジェネレータが「index」と「uniq」の修飾子を受け入れるようになりました。例えば、

    ```bash
    bin/rails g scaffold Post title:string:index author:uniq price:decimal{7,2}
    ```

    これにより、`title`と`author`のインデックスが作成され、後者はユニークなインデックスになります。decimalなどの一部の型はカスタムオプションを受け入れます。この例では、`price`は精度7、スケール2のdecimalカラムになります。

* `Gemfile`のデフォルトから`turn`ジェムが削除されました。

* 古いプラグインジェネレータ`rails generate plugin`は、`rails plugin new`コマンドに置き換えられました。

* 古い`config.paths.app.controller`APIは、`config.paths["app/controller"]`に置き換えられました。

### 廃止予定

* `Rails::Plugin`は廃止予定であり、Rails 4.0で削除されます。`vendor/plugins`にプラグインを追加する代わりに、パスやGitの依存関係を使用するか、bundlerを使用してください。

Action Mailer
-------------

* `mail`のバージョンを2.4.0にアップグレードしました。

* Rails 3.0以降非推奨となっていた古いAction Mailer APIを削除しました。

Action Pack
-----------

### Action Controller

* `ActiveSupport::Benchmarkable`を`ActionController::Base`のデフォルトモジュールにし、コントローラのコンテキストで`#benchmark`メソッドを再び使用できるようにしました。

* `caches_page`に`:gzip`オプションを追加しました。デフォルトのオプションは`page_cache_compression`を使用してグローバルに設定できます。

* `:only`と`:except`の条件でレイアウトを指定した場合、Railsはデフォルトのレイアウト（例：「layouts/application」）を使用します。条件が失敗した場合には、`layouts/single_car`（リクエストが`:show`アクションに来た場合）または`layouts/application`（または`layouts/cars`が存在する場合）を使用します。

    ```ruby
    class CarsController
      layout 'single_car', :only => :show
    end
    ```

* `form_for`は、`:as`オプションが指定された場合、CSSクラスとIDに`#{action}_#{as}`を使用するように変更されました。以前のバージョンでは、`#{as}_#{action}`が使用されていました。

* Active Recordモデルの`ActionController::ParamsWrapper`は、`attr_accessible`属性が設定されている場合にのみラップします。設定されていない場合は、クラスメソッド`attribute_names`によって返される属性のみがラップされます。これにより、ネストされた属性を`attr_accessible`に追加することで、ネストされた属性のラップが修正されます。

* ビフォーコールバックが中断した場合、毎回「Filter chain halted as CALLBACKNAME rendered or redirected」とログに記録します。

* `ActionDispatch::ShowExceptions`をリファクタリングしました。コントローラが例外を表示するかどうかを選択するようになりました。コントローラで`show_detailed_exceptions?`をオーバーライドして、どのリクエストでエラーのデバッグ情報を提供するかを指定できます。

* レスポンダは、APIリクエストに応答ボディがない場合（新しいScaffoldと同様）、204 No Contentを返します。

* `ActionController::TestCase`のcookiesをリファクタリングしました。テストケースでのクッキーの割り当てには、`cookies[]`を使用する必要があります。
```ruby
cookies[:email] = 'user@example.com'
get :index
assert_equal 'user@example.com', cookies[:email]
```

クッキーをクリアするには、`clear`を使用します。

```ruby
cookies.clear
get :index
assert_nil cookies[:email]
```

HTTP_COOKIEを書き出さなくなり、クッキージャーはリクエスト間で永続的になりましたので、テストのために環境を操作する必要がある場合は、クッキージャーが作成される前に行う必要があります。

* `send_file`は、`:type`が指定されていない場合、ファイルの拡張子からMIMEタイプを推測するようになりました。

* PDF、ZIPなどの形式のMIMEタイプエントリが追加されました。

* `fresh_when/stale?`は、オプションのハッシュではなくレコードを受け取るようになりました。

* CSRFトークンが見つからない場合の警告のログレベルを`debug`から`warn`に変更しました。

* アセットはデフォルトでリクエストプロトコルを使用するか、リクエストが利用できない場合は相対パスをデフォルトとする必要があります。

#### 廃止予定

* 親に明示的なレイアウトが設定されているコントローラーの暗黙のレイアウト検索を廃止しました。

    ```ruby
    class ApplicationController
      layout "application"
    end

    class PostsController < ApplicationController
    end
    ```

    上記の例では、`PostsController`は自動的に投稿のレイアウトを検索しなくなります。この機能が必要な場合は、`ApplicationController`から`layout "application"`を削除するか、`PostsController`で明示的に`nil`に設定する必要があります。

* `ActionController::UnknownAction`を`AbstractController::ActionNotFound`に置き換えました。

* `ActionController::DoubleRenderError`を`AbstractController::DoubleRenderError`に置き換えました。

* 欠落しているアクションのために`method_missing`を`action_missing`に置き換えました。

* `ActionController#rescue_action`、`ActionController#initialize_template_class`、`ActionController#assign_shortcuts`を廃止しました。

### Action Dispatch

* `ActionDispatch::Response`のデフォルトの文字セットを設定するための`config.action_dispatch.default_charset`を追加しました。

* ユニークなX-Request-Idヘッダーをレスポンスで利用できるようにする`ActionDispatch::RequestId`ミドルウェアを追加し、`ActionDispatch::Request#uuid`メソッドを有効にします。これにより、スタック全体でリクエストを追跡し、Syslogなどの混合ログで個々のリクエストを識別することが容易になります。

* `ShowExceptions`ミドルウェアは、アプリケーションが失敗した場合に例外をレンダリングする責任を持つ例外アプリケーションを受け入れるようになりました。アプリケーションは、例外のコピーを`env["action_dispatch.exception"]`で受け取り、ステータスコードにPATH_INFOが書き換えられた状態で呼び出されます。

* `config.action_dispatch.rescue_responses`でレスキューレスポンスを設定できるようになりました。

#### 廃止予定

* コントローラーレベルでデフォルトの文字セットを設定する機能は廃止されました。代わりに、新しい`config.action_dispatch.default_charset`を使用してください。

### Action View

* `ActionView::Helpers::FormBuilder`に`button_tag`サポートを追加しました。このサポートは、`submit_tag`のデフォルトの動作を模倣します。

    ```erb
    <%= form_for @post do |f| %>
      <%= f.button %>
    <% end %>
    ```

* 日付ヘルパーは、新しいオプション`use_two_digit_numbers => true`を受け入れます。これにより、先頭にゼロを付けたまま、月と日の選択ボックスをレンダリングします。たとえば、'2011-08-01'のようなISO 8601スタイルの日付を表示するのに便利です。

* フォームのid属性の一意性を保証するために、フォームに名前空間を指定できるようになりました。生成されるHTMLのidには、アンダースコアで始まる名前空間属性が付加されます。

    ```erb
    <%= form_for(@offer, :namespace => 'namespace') do |f| %>
      <%= f.label :version, 'Version' %>:
      <%= f.text_field :version %>
    <% end %>
    ```

* `select_year`のオプションの数を1000に制限しました。独自の制限を設定するには、`:max_years_allowed`オプションを渡します。

* `content_tag_for`と`div_for`は、レコードのコレクションを受け取ることができるようになりました。また、ブロック内で受け取る引数を設定すると、レコードが最初の引数としてyieldされます。したがって、次のように書く必要がありません。

    ```ruby
    @items.each do |item|
      content_tag_for(:li, item) do
        Title: <%= item.title %>
      end
    end
    ```

    これを行うには、次のように書くことができます。

    ```ruby
    content_tag_for(:li, @items) do |item|
      Title: <%= item.title %>
    end
    ```

* `font_path`ヘルパーメソッドを追加しました。これは、`public/fonts`内のフォントアセットへのパスを計算します。

#### 廃止予定

* `render :template => "foo.html.erb"`のように、`render :template`などにフォーマットやハンドラを渡すことは廃止されました。代わりに、オプションとして直接`:handlers`と`:formats`を指定できます：`render :template => "foo", :formats => [:html, :js], :handlers => :erb`。

### Sprockets

* Sprocketsのログを制御するための`config.assets.logger`設定オプションを追加しました。ログをオフにするには`false`に設定し、`nil`に設定すると`Rails.logger`にデフォルトします。

Active Record
-------------

* 'on'と'ON'の値を持つブール型のカラムは、trueに型変換されます。

* `timestamps`メソッドが`created_at`と`updated_at`カラムを作成する際、デフォルトで非NULLになります。

* `ActiveRecord::Relation#explain`を実装しました。

* `ActiveRecord::Base.silence_auto_explain`を実装し、ブロック内で自動的なEXPLAINを選択的に無効にすることができるようにしました。

* 遅いクエリのための自動EXPLAINログを実装しました。新しい設定パラメータ`config.active_record.auto_explain_threshold_in_seconds`は、遅いクエリと見なされるものを決定します。これを`nil`に設定すると、この機能は無効になります。デフォルトは開発モードでは0.5、テストモードと本番モードでは`nil`です。Rails 3.2では、この機能はSQLite、MySQL（mysql2アダプタ）、およびPostgreSQLでサポートされています。
* `ActiveRecord::Base.store`を追加して、単一のカラムのキー/値ストアを宣言するための機能を追加しました。

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [ :color, :homepage ]
    end

    u = User.new(color: 'black', homepage: '37signals.com')
    u.color                          # アクセサで保存された属性にアクセス
    u.settings[:country] = 'Denmark' # アクセサで指定されていない属性にもアクセス可能
    ```

* 特定のスコープのみでマイグレーションを実行できるようにする機能を追加しました。これにより、削除する必要のあるエンジンからの変更を元に戻すために、特定のエンジンのみでマイグレーションを実行できます。

    ```
    rake db:migrate SCOPE=blog
    ```

* エンジンからコピーされたマイグレーションは、エンジンの名前でスコープが設定されるようになりました。例えば、`01_create_posts.blog.rb`のようになります。

* `ActiveRecord::Relation#pluck`メソッドを実装しました。これは、基礎となるテーブルから直接カラムの値の配列を返します。これは、シリアライズされた属性でも動作します。

    ```ruby
    Client.where(:active => true).pluck(:id)
    # SELECT id from clients where active = 1
    ```

* 生成された関連メソッドは、オーバーライドや組み合わせを可能にするために別のモジュール内に作成されます。MyModelという名前のクラスの場合、モジュールの名前は`MyModel::GeneratedFeatureMethods`となります。これは、Active Modelで定義された`generated_attributes_methods`モジュールの直後にモデルクラスにインクルードされるため、関連メソッドは同じ名前の属性メソッドをオーバーライドします。

* 一意のクエリを生成するための`ActiveRecord::Relation#uniq`を追加しました。

    ```ruby
    Client.select('DISTINCT name')
    ```

    ..は以下のように書くことができます:

    ```ruby
    Client.select(:name).uniq
    ```

    これにより、リレーション内の一意性を元に戻すことも可能です:

    ```ruby
    Client.select(:name).uniq.uniq(false)
    ```

* SQLite、MySQL、PostgreSQLアダプタでインデックスのソート順をサポートしました。

* 関連に対する`:class_name`オプションが文字列だけでなくシンボルも受け入れるようになりました。これは初心者を混乱させないため、および他のオプション（例：`:foreign_key`）がシンボルまたは文字列を受け入れることと一貫性を持たせるためです。

    ```ruby
    has_many :clients, :class_name => :Client # シンボルは大文字である必要があることに注意してください
    ```

* 開発モードでは、`db:drop`はテストデータベースも削除するようになりました。これにより、`db:create`と対称になります。

* 大文字小文字を区別しない一意性のバリデーションは、カラムが既に大文字小文字を区別しない照合順序を使用している場合、MySQLでLOWERを呼び出さないようになりました。

* トランザクションフィクスチャは、すべてのアクティブなデータベース接続を登録します。トランザクションフィクスチャを無効にすることなく、異なる接続でモデルをテストすることができます。

* Active Recordに`first_or_create`、`first_or_create!`、`first_or_initialize`メソッドを追加しました。これは、古い`find_or_create_by`ダイナミックメソッドよりも優れたアプローチです。なぜなら、どの引数がレコードを検索するために使用され、どの引数が作成するために使用されるかが明確になるからです。

    ```ruby
    User.where(:first_name => "Scarlett").first_or_create!(:last_name => "Johansson")
    ```

* Active Recordオブジェクトに`with_lock`メソッドを追加しました。これは、トランザクションを開始し、オブジェクトをロック（悲観的ロック）し、ブロックにイールドします。このメソッドは1つの（オプションの）パラメータを受け取り、`lock!`に渡します。

    これにより、次のように書くことができます:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        transaction do
          lock!
          # ... キャンセルのロジック
        end
      end
    end
    ```

    以下のように書くこともできます:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        with_lock do
          # ... キャンセルのロジック
        end
      end
    end
    ```

### 廃止予定

* スレッド内での自動的な接続のクローズは廃止予定です。例えば、次のコードは廃止予定です:

    ```ruby
    Thread.new { Post.find(1) }.join
    ```

    スレッドの終わりでデータベース接続をクローズするように変更する必要があります:

    ```ruby
    Thread.new {
      Post.find(1)
      Post.connection.close
    }.join
    ```

    この変更について心配する必要があるのは、アプリケーションコードでスレッドを生成する人だけです。

* `set_table_name`、`set_inheritance_column`、`set_sequence_name`、`set_primary_key`、`set_locking_column`メソッドは廃止予定です。代わりに代入メソッドを使用してください。例えば、`set_table_name`の代わりに`self.table_name=`を使用してください。

    ```ruby
    class Project < ActiveRecord::Base
      self.table_name = "project"
    end
    ```

    または、独自の`self.table_name`メソッドを定義してください:

    ```ruby
    class Post < ActiveRecord::Base
      def self.table_name
        "special_" + super
      end
    end

    Post.table_name # => "special_posts"
    ```

Active Model
------------

* 特定のエラーが追加されたかどうかを確認するための`ActiveModel::Errors#added?`を追加しました。

* `strict => true`で厳密なバリデーションを定義できるようになりました。これは常に例外を発生させるようになります。

* `mass_assignment_sanitizer`を提供し、サニタイザの動作を置き換えるための簡単なAPIをサポートしました。また、`:logger`（デフォルト）と`:strict`の両方のサニタイザの動作をサポートしています。

### 廃止予定

* `ActiveModel::AttributeMethods`の`define_attr_method`は廃止予定です。これは、Active Recordの`set_table_name`などのメソッドをサポートするために存在していたものであり、それ自体が廃止予定です。

* `Model.model_name.partial_path`は`model.to_partial_path`に代わるものとして廃止予定です。

Active Resource
---------------

* リダイレクトレスポンス：303 See Otherと307 Temporary Redirectは、301 Moved Permanentlyと302 Foundのように動作するようになりました。

Active Support
--------------

* 任意の標準の`Logger`クラスをラップしてタグ付け機能を提供する`ActiveSupport:TaggedLogging`を追加しました。

    ```ruby
    Logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    Logger.tagged("BCX") { Logger.info "Stuff" }
    # "[BCX] Stuff"とログが出力されます

    Logger.tagged("BCX", "Jason") { Logger.info "Stuff" }
    # "[BCX] [Jason] Stuff"とログが出力されます

    Logger.tagged("BCX") { Logger.tagged("Jason") { Logger.info "Stuff" } }
    # "[BCX] [Jason] Stuff"とログが出力されます
    ```
* `Date`、`Time`、および`DateTime`の`beginning_of_week`メソッドは、週の開始日を表すオプション引数を受け入れます。

* `ActiveSupport::Notifications.subscribed`は、ブロックが実行されている間にイベントに対するサブスクリプションを提供します。

* `Module#qualified_const_defined?`、`Module#qualified_const_get`、および`Module#qualified_const_set`という新しいメソッドを定義しました。これらのメソッドは、標準のAPIの対応するメソッドと同様ですが、修飾された定数名を受け入れます。

* `#deconstantize`を追加しました。これは、インフレクションの`#demodulize`と補完関係にあります。これにより、修飾された定数名の最も右のセグメントが削除されます。

* `safe_constantize`を追加しました。これは文字列を定数化しますが、定数（またはその一部）が存在しない場合に例外を発生させずに`nil`を返します。

* `ActiveSupport::OrderedHash`は、`Array#extract_options!`を使用する場合に抽出可能としてマークされます。

* `Array#prepend`を`Array#unshift`のエイリアスとして追加し、`Array#append`を`Array#<<`のエイリアスとして追加しました。

* Ruby 1.9の空の文字列の定義は、Unicodeの空白に拡張されました。また、Ruby 1.8では、表意文字スペースU`3000`も空白と見なされます。

* インフレクタはアクロニムを理解します。

* 範囲を生成する方法として、`Time#all_day`、`Time#all_week`、`Time#all_quarter`、および`Time#all_year`を追加しました。

    ```ruby
    Event.where(:created_at => Time.now.all_week)
    Event.where(:created_at => Time.now.all_day)
    ```

* `Class#cattr_accessor`および関連するメソッドのオプションとして`instance_accessor: false`を追加しました。

* `ActiveSupport::OrderedHash`は、パラメータをスプラットで受け入れるブロックを指定した場合、`#each`と`#each_pair`の動作が異なるようになりました。

* 開発およびテストで使用するための`ActiveSupport::Cache::NullStore`を追加しました。

* 標準ライブラリの`SecureRandom`を使用するため、`ActiveSupport::SecureRandom`を削除しました。

### 廃止予定

* `ActiveSupport::Base64`は、`::Base64`を使用するように廃止されました。

* Rubyのメモ化パターンを使用するため、`ActiveSupport::Memoizable`は廃止予定となりました。

* `Module#synchronize`は廃止予定で、代替手段はありません。Rubyの標準ライブラリからモニターを使用してください。

* `ActiveSupport::MessageEncryptor#encrypt`および`ActiveSupport::MessageEncryptor#decrypt`は廃止予定です。

* `ActiveSupport::BufferedLogger#silence`は廃止予定です。特定のブロックのログを抑制する場合は、そのブロックのログレベルを変更してください。

* `ActiveSupport::BufferedLogger#open_log`は廃止予定です。このメソッドは最初から公開されるべきではありませんでした。

* `ActiveSupport::BufferedLogger`のログファイルのディレクトリを自動的に作成する動作は廃止予定です。ログファイルのディレクトリをインスタンス化する前に作成してください。

* `ActiveSupport::BufferedLogger#auto_flushing`は廃止予定です。このようにして、基になるファイルハンドルの同期レベルを設定するか、ファイルシステムを調整してください。FSキャッシュがフラッシュを制御します。

    ```ruby
    f = File.open('foo.log', 'w')
    f.sync = true
    ActiveSupport::BufferedLogger.new f
    ```

* `ActiveSupport::BufferedLogger#flush`は廃止予定です。ファイルハンドルの同期を設定するか、ファイルシステムを調整してください。

クレジット
-------

Railsに多くの時間を費やした多くの人々に感謝します。[Railsの全貢献者のリスト](http://contributors.rubyonrails.org/)を参照してください。彼ら全員に敬意を表します。

Rails 3.2リリースノートは[Vijay Dev](https://github.com/vijaydev)によって編集されました。
