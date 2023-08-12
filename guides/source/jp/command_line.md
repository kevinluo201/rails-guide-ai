**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 7dbd0564d604e07d111b2a827bef559f
Railsコマンドライン
======================

このガイドを読み終えると、以下のことがわかります：

* Railsアプリケーションの作成方法
* モデル、コントローラ、データベースマイグレーション、ユニットテストの生成方法
* 開発サーバーの起動方法
* インタラクティブシェルを通じてオブジェクトを試す方法

--------------------------------------------------------------------------------

注意：このチュートリアルでは、[Railsガイドのはじめに](getting_started.html)を読んで基本的なRailsの知識を持っていることを前提としています。

Railsアプリケーションの作成
--------------------

まず、`rails new`コマンドを使用してシンプルなRailsアプリケーションを作成しましょう。

このアプリケーションを使用して、このガイドで説明されているすべてのコマンドを試してみましょう。

情報：すでにインストールされていない場合は、`gem install rails`と入力してrails gemをインストールできます。

### `rails new`

`rails new`コマンドに渡す最初の引数はアプリケーション名です。

```bash
$ rails new my_app
     create
     create  README.md
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

Railsは、このような小さなコマンドに対して膨大な量の設定を行います！すぐに使える状態でシンプルなアプリケーションを実行するために必要なすべてのコードが含まれたRailsディレクトリ構造ができました。

生成されるファイルの一部をスキップしたり、一部のライブラリをスキップしたりするには、`rails new`コマンドに以下の引数を追加することができます：

| 引数                   | 説明                                                 |
| ----------------------- | ----------------------------------------------------------- |
| `--skip-git`            | git init、.gitignore、および.gitattributesをスキップする               |
| `--skip-docker`         | Dockerfile、.dockerignore、およびbin/docker-entrypointをスキップする    |
| `--skip-keeps`          | ソースコントロールの.keepファイルをスキップする                      |
| `--skip-action-mailer`  | Action Mailerファイルをスキップする                             |
| `--skip-action-mailbox` | Action Mailbox gemをスキップする                                  |
| `--skip-action-text`    | Action Text gemをスキップする                                     |
| `--skip-active-record`  | Active Recordファイルをスキップする                                 |
| `--skip-active-job`     | Active Jobをスキップする                                             |
| `--skip-active-storage` | Active Storageファイルをスキップする                               |
| `--skip-action-cable`   | Action Cableファイルをスキップする                                 |
| `--skip-asset-pipeline` | Asset Pipelineをスキップする                                         |
| `--skip-javascript`     | JavaScriptファイルをスキップする                                   |
| `--skip-hotwire`        | Hotwire統合をスキップする                                            |
| `--skip-jbuilder`       | jbuilder gemをスキップする                                           |
| `--skip-test`           | テストファイルをスキップする                                         |
| `--skip-system-test`    | システムテストファイルをスキップする                                  |
| `--skip-bootsnap`       | bootsnap gemをスキップする                                           |

これは`rails new`が受け入れるオプションの一部です。すべてのオプションの完全なリストについては、`rails new --help`と入力してください。

### 別のデータベースの事前設定

新しいRailsアプリケーションを作成する際に、アプリケーションが使用するデータベースの種類を指定するオプションがあります。これにより、数分間、そして確かに多くのキーストロークを節約できます。

`--database=postgresql`オプションがどのような効果をもたらすか見てみましょう：

```bash
$ rails new petstore --database=postgresql
      create
      create  app/controllers
      create  app/helpers
...
```

`config/database.yml`に何が生成されたかを見てみましょう：

```yaml
# PostgreSQL. Versions 9.3 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On macOS with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On Windows:
#   gem install pg
#       Choose the win32 build.
#       Install PostgreSQL and put its /bin directory on your path.
#
# Configure Using Gemfile
# gem "pg"
#
default: &default
  adapter: postgresql
  encoding: unicode

  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: petstore_development
...
```

選択したPostgreSQLに対応するデータベースの設定が生成されました。

コマンドラインの基本
-------------------

Railsの日常的な使用にはいくつかの重要なコマンドがあります。おそらく使用頻度の高い順に並べると以下のようになります：

* `bin/rails console`
* `bin/rails server`
* `bin/rails test`
* `bin/rails generate`
* `bin/rails db:migrate`
* `bin/rails db:create`
* `bin/rails routes`
* `bin/rails dbconsole`
* `rails new app_name`

現在のディレクトリによって異なる場合があるため、利用可能なrailsコマンドのリストを取得するには、`rails --help`と入力します。各コマンドには説明があり、必要なものを見つけるのに役立ちます。

```bash
$ rails --help
Usage:
  bin/rails COMMAND [options]

You must specify a command. The most common commands are:

  generate     Generate new code (short-cut alias: "g")
  console      Start the Rails console (short-cut alias: "c")
  server       Start the Rails server (short-cut alias: "s")
  ...

All commands can be run with -h (or --help) for more information.

In addition to those commands, there are:
about                               List versions of all Rails ...
assets:clean[keep]                  Remove old compiled assets
assets:clobber                      Remove compiled assets
assets:environment                  Load asset compile environment
assets:precompile                   Compile all the assets ...
...
db:fixtures:load                    Load fixtures into the ...
db:migrate                          Migrate the database ...
db:migrate:status                   Display status of migrations
db:rollback                         Roll the schema back to ...
db:schema:cache:clear               Clears a db/schema_cache.yml file
db:schema:cache:dump                Create a db/schema_cache.yml file
db:schema:dump                      Create a database schema file (either db/schema.rb or db/structure.sql ...
db:schema:load                      Load a database schema file (either db/schema.rb or db/structure.sql ...
db:seed                             Load the seed data ...
db:version                          Retrieve the current schema ...
...
restart                             Restart app by touching ...
tmp:create                          Create tmp directories ...
```
### `bin/rails server`

`bin/rails server`コマンドは、RailsにバンドルされているPumaという名前のWebサーバーを起動します。Webブラウザを通じてアプリケーションにアクセスする際に使用します。

追加の作業なしで、`bin/rails server`を実行すると、新しいRailsアプリが実行されます。

```bash
$ cd my_app
$ bin/rails server
=> Booting Puma
=> Rails 7.0.0 application starting in development
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Version 3.12.1 (ruby 2.5.7-p206), codename: Llamas in Pajamas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
```

たった3つのコマンドで、ポート3000でリッピなRailsサーバーが立ち上がりました。ブラウザを開いて[http://localhost:3000](http://localhost:3000)にアクセスすると、基本的なRailsアプリが実行されていることが確認できます。

情報: エイリアス"s"を使用してサーバーを起動することもできます: `bin/rails s`。

`-p`オプションを使用して、サーバーを別のポートで実行することもできます。デフォルトの開発環境は`-e`オプションを使用して変更することができます。

```bash
$ bin/rails server -e production -p 4000
```

`-b`オプションは、Railsを指定したIPにバインドします。デーモンとしてサーバーを実行するには、`-d`オプションを渡します。

### `bin/rails generate`

`bin/rails generate`コマンドは、テンプレートを使用してさまざまなものを生成します。`bin/rails generate`を単体で実行すると、利用可能なジェネレータのリストが表示されます。

情報: ジェネレータコマンドを呼び出すためのエイリアス"g"も使用できます: `bin/rails g`。

```bash
$ bin/rails generate
Usage:
  bin/rails generate GENERATOR [args] [options]

...
...

Please choose a generator below.

Rails:
  assets
  channel
  controller
  generator
  ...
  ...
```

注意: ジェネレータのgem、インストールすることが不可欠なプラグインの一部、または独自のジェネレータを追加することもできます。

ジェネレータを使用することで、アプリケーションの動作に必要な**ボイラープレートコード**を書く時間を節約できます。

コントローラジェネレータを使用して、独自のコントローラを作成しましょう。どのコマンドを使用すればよいかは、ジェネレータに尋ねてみましょう。

情報: Railsのすべてのコンソールユーティリティにはヘルプテキストがあります。ほとんどの*nixユーティリティと同様に、末尾に`--help`または`-h`を追加して試すことができます。例えば、`bin/rails server --help`とします。

```bash
$ bin/rails generate controller
Usage:
  bin/rails generate controller NAME [action action] [options]

...
...

Description:
    ...

    To create a controller within a module, specify the controller name as a path like 'parent_module/controller_name'.

    ...

Example:
    `bin/rails generate controller CreditCards open debit credit close`

    Credit card controller with URLs like /credit_cards/debit.
        Controller: app/controllers/credit_cards_controller.rb
        Test:       test/controllers/credit_cards_controller_test.rb
        Views:      app/views/credit_cards/debit.html.erb [...]
        Helper:     app/helpers/credit_cards_helper.rb
```

コントローラジェネレータは、`generate controller ControllerName action1 action2`の形式でパラメータを受け取ることを期待しています。**hello**というアクションを持つ`Greetings`コントローラを作成しましょう。このアクションは、私たちに何か良いことを言います。

```bash
$ bin/rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get 'greetings/hello'
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke    test_unit
```

これによって何が生成されたのでしょうか？アプリケーション内にいくつかのディレクトリが存在することを確認し、コントローラファイル、ビューファイル、機能テストファイル、ビューのためのヘルパー、JavaScriptファイル、スタイルシートファイルが作成されました。

コントローラを確認し、少し変更してみましょう（`app/controllers/greetings_controller.rb`）。

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Hello, how are you today?"
  end
end
```

次に、メッセージを表示するためのビューを変更します（`app/views/greetings/hello.html.erb`）。

```erb
<h1>A Greeting for You!</h1>
<p><%= @message %></p>
```

`bin/rails server`を使用してサーバーを起動します。

```bash
$ bin/rails server
=> Booting Puma...
```

URLは[http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello)です。

情報: 通常のプレーンなRailsアプリケーションでは、URLは一般的にhttp://(ホスト)/(コントローラ)/(アクション)のパターンに従います。http://(ホスト)/(コントローラ)のようなURLは、そのコントローラの**index**アクションにアクセスします。

Railsにはデータモデルのためのジェネレータも付属しています。

```bash
$ bin/rails generate model
Usage:
  bin/rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

...

ActiveRecord options:
      [--migration], [--no-migration]        # Indicates when to generate migration
                                             # Default: true

...

Description:
    Generates a new model. Pass the model name, either CamelCased or
    under_scored, and an optional list of attribute pairs as arguments.

...
```

注意: `type`パラメータの利用可能なフィールドタイプのリストについては、`SchemaStatements`モジュールの`add_column`メソッドの[APIドキュメント](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column)を参照してください。`index`パラメータは、カラムに対応するインデックスを生成します。
ただし、モデルを直接生成する代わりに（後で行う予定です）、スキャフォールドを設定しましょう。Railsの**スキャフォールド**は、モデル、そのモデルのデータベースマイグレーション、それを操作するためのコントローラ、データを表示および操作するためのビュー、および上記のそれぞれに対するテストスイートの完全なセットです。

私たちは、プレイしたビデオゲームの最高得点を追跡するための単純なリソース「HighScore」を設定します。

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20190416145729_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    create      test/system/high_scores_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke      test_unit
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    create      app/views/high_scores/_high_score.json.jbuilder
```

ジェネレータは、HighScoreのためのモデル、ビュー、コントローラ、**リソース**ルート、およびデータベースマイグレーション（`high_scores`テーブルを作成する）を作成します。そして、それらのためのテストを追加します。

マイグレーションでは、データベースのスキーマを変更するためにいくつかのRubyコード（上記の出力からの`20190416145729_create_high_scores.rb`ファイル）を**マイグレート**する必要があります。どのデータベースですか？Railsが`bin/rails db:migrate`コマンドを実行すると、作成するSQLite3データベースです。このコマンドについては後ほど詳しく説明します。

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: ユニットテストについて話しましょう。ユニットテストは、コードをテストし、アサーションを行うコードです。ユニットテストでは、例えばモデルのメソッドの一部であるコードの入力と出力をテストします。ユニットテストはあなたの友達です。コードをユニットテストすることで、生活の質が劇的に向上することに早く気づくほど良いです。本当に。詳細については、[テストガイド](testing.html)をご覧ください。

作成されたインターフェースを見てみましょう。

```bash
$ bin/rails server
```

ブラウザを開いて、[http://localhost:3000/high_scores](http://localhost:3000/high_scores)に移動します。これで新しいハイスコア（スペースインベーダーでの55,160点！）を作成できます。

### `bin/rails console`

`console`コマンドを使用すると、コマンドラインからRailsアプリケーションと対話することができます。内部では、`bin/rails console`はIRBを使用しているため、以前に使用したことがある場合はすぐに使い始めることができます。これは、コードのクイックなアイデアをテストしたり、ウェブサイトに触れずにデータをサーバーサイドで変更したりするために便利です。

INFO: コンソールを呼び出すためのエイリアスとして「c」を使用することもできます：`bin/rails c`。

`console`コマンドが動作する環境を指定することもできます。

```bash
$ bin/rails console -e staging
```

データを変更せずにいくつかのコードをテストしたい場合は、`bin/rails console --sandbox`を使用することができます。

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 7.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### `app`および`helper`オブジェクト

`bin/rails console`内では、`app`および`helper`インスタンスにアクセスできます。

`app`メソッドを使用すると、名前付きルートヘルパーにアクセスしたり、リクエストを行ったりすることができます。

```irb
irb> app.root_path
=> "/"

irb> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

`helper`メソッドを使用すると、Railsおよびアプリケーションのヘルパーにアクセスできます。

```irb
irb> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

irb> helper.my_custom_helper
=> "my custom helper"
```

### `bin/rails dbconsole`

`bin/rails dbconsole`は、使用しているデータベースを特定し、それに使用するコマンドラインインターフェースに移動します（それに対して渡すコマンドラインパラメータも特定します！）。MySQL（MariaDBを含む）、PostgreSQL、およびSQLite3をサポートしています。

INFO: `dbconsole`を呼び出すためのエイリアスとして「db」を使用することもできます：`bin/rails db`。

複数のデータベースを使用している場合、`bin/rails dbconsole`はデフォルトでプライマリデータベースに接続します。`--database`または`--db`を使用して接続するデータベースを指定することができます。

```bash
$ bin/rails dbconsole --database=animals
```

### `bin/rails runner`

`runner`は、Railsの非対話型コンテキストでRubyコードを実行します。例えば：

```bash
$ bin/rails runner "Model.long_running_method"
```

INFO: `runner`を呼び出すためのエイリアスとして「r」を使用することもできます：`bin/rails r`。

`runner`コマンドが動作する環境を指定することもできます。`-e`スイッチを使用して指定します。

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```

ランナーを使用してファイルに書かれたRubyコードを実行することもできます。

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `bin/rails destroy`

`destroy`は`generate`の反対と考えてください。generateが行ったことを特定し、それを元に戻します。

INFO: destroyコマンドを呼び出すためにエイリアス"d"を使用することもできます: `bin/rails d`。

```bash
$ bin/rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```

```bash
$ bin/rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

### `bin/rails about`

`bin/rails about`は、Ruby、RubyGems、Rails、Railsのサブコンポーネント、アプリケーションのフォルダ、現在のRails環境名、アプリケーションのデータベースアダプタ、およびスキーマバージョンのバージョン番号に関する情報を提供します。ヘルプを求める必要がある場合、セキュリティパッチが影響を与える可能性があるかどうかを確認する場合、または既存のRailsインストールの統計情報が必要な場合に便利です。

```bash
$ bin/rails about
About your application's environment
Rails version             7.0.0
Ruby version              2.7.0 (x86_64-linux)
RubyGems version          2.7.3
Rack version              2.0.4
JavaScript Runtime        Node.js (V8)
Middleware:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Application root          /home/foobar/my_app
Environment               development
Database adapter          sqlite3
Database schema version   20180205173523
```

### `bin/rails assets:`

`bin/rails assets:precompile`を使用して`app/assets`のアセットを事前コンパイルし、`bin/rails assets:clean`を使用して古いコンパイル済みアセットを削除することができます。`assets:clean`コマンドは、新しいアセットが構築されている間にまだ古いアセットにリンクしている可能性があるローリングデプロイを許可します。

`public/assets`を完全にクリアしたい場合は、`bin/rails assets:clobber`を使用できます。

### `bin/rails db:`

`db:`のrailsネームスペースの最も一般的なコマンドは`migrate`と`create`ですが、すべてのマイグレーションrailsコマンド（`up`、`down`、`redo`、`reset`）を試してみることは価値があります。トラブルシューティング時には、`bin/rails db:version`を使用してデータベースの現在のバージョンを確認すると便利です。

マイグレーションに関する詳細情報は、[マイグレーション](active_record_migrations.html)ガイドを参照してください。

### `bin/rails notes`

`bin/rails notes`は、特定のキーワードで始まるコメントをコード内で検索します。使用方法に関する情報については、`bin/rails notes --help`を参照してください。

デフォルトでは、拡張子が`.builder`、`.rb`、`.rake`、`.yml`、`.yaml`、`.ruby`、`.css`、`.js`、`.erb`のファイル内のFIXME、OPTIMIZE、TODOの注釈を検索します。

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

#### 注釈

`--annotations`引数を使用して特定の注釈を渡すことができます。デフォルトでは、FIXME、OPTIMIZE、TODOを検索します。
注釈は大文字と小文字を区別することに注意してください。

```bash
$ bin/rails notes --annotations FIXME RELEASE
app/controllers/admin/users_controller.rb:
  * [101] [RELEASE] We need to look at this before next release
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 17] [FIXME]
```

#### タグ

`config.annotations.register_tags`を使用して、検索するデフォルトのタグを追加することができます。タグのリストを受け取ります。

```ruby
config.annotations.register_tags("DEPRECATEME", "TESTME")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] do A/B testing on this
  * [ 42] [TESTME] this needs more functional tests
  * [132] [DEPRECATEME] ensure this method is deprecated in next release
```

#### ディレクトリ

`config.annotations.register_directories`を使用して、検索するデフォルトのディレクトリを追加することができます。ディレクトリ名のリストを受け取ります。

```ruby
config.annotations.register_directories("spec", "vendor")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```

#### 拡張子

`config.annotations.register_extensions`を使用して、検索するデフォルトのファイル拡張子を追加することができます。拡張子とそれに対応する正規表現のリストを受け取ります。

```ruby
config.annotations.register_extensions("scss", "sass") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/assets/stylesheets/application.css.sass:
  * [ 34] [TODO] Use pseudo element for this class

app/assets/stylesheets/application.css.scss:
  * [  1] [TODO] Split into multiple components

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```
### `bin/rails routes`

`bin/rails routes`は、定義されたすべてのルートをリストアップします。これは、アプリケーションのルーティングの問題を追跡するのに役立ちます。また、アプリケーションのURLの概要を把握するのにも役立ちます。

### `bin/rails test`

INFO: Railsには、ユニットテストの説明が[A Guide to Testing Rails Applications](testing.html)にあります。

Railsには、minitestというテストフレームワークが付属しています。Railsの安定性は、テストの使用によるものです。`test:`ネームスペースで利用可能なコマンドは、異なるテストを実行するのに役立ちます。

### `bin/rails tmp:`

`Rails.root/tmp`ディレクトリは、*nixの/tmpディレクトリと同様に、プロセスIDファイルやキャッシュされたアクションなどの一時ファイルの保管場所です。

`tmp:`ネームスペースのコマンドは、`Rails.root/tmp`ディレクトリをクリアして作成するのに役立ちます。

* `bin/rails tmp:cache:clear`は、`tmp/cache`をクリアします。
* `bin/rails tmp:sockets:clear`は、`tmp/sockets`をクリアします。
* `bin/rails tmp:screenshots:clear`は、`tmp/screenshots`をクリアします。
* `bin/rails tmp:clear`は、すべてのキャッシュ、ソケット、スクリーンショットファイルをクリアします。
* `bin/rails tmp:create`は、キャッシュ、ソケット、およびPIDのためのtmpディレクトリを作成します。

### その他

* `bin/rails initializers`は、Railsによって呼び出される順序で定義されたすべての初期化子を表示します。
* `bin/rails middleware`は、アプリケーションで有効になっているRackミドルウェアスタックをリストアップします。
* `bin/rails stats`は、コードの統計情報を表示するのに便利です。KLOC（コードの千行）やコードとテストの比率などを表示します。
* `bin/rails secret`は、セッションの秘密鍵として使用する擬似ランダムキーを生成します。
* `bin/rails time:zones:all`は、Railsが知っているすべてのタイムゾーンをリストアップします。

### カスタムRakeタスク

カスタムのRakeタスクは、`.rake`拡張子で`Rails.root/lib/tasks`に配置されます。これらのカスタムRakeタスクは、`bin/rails generate task`コマンドで作成できます。

```ruby
desc "私は短くても包括的な説明です"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # ここにあなたの魔法を書く
  # 有効なRubyコードなら何でも使えます
end
```

カスタムRakeタスクに引数を渡すには：

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

タスクをネームスペースでグループ化することもできます：

```ruby
namespace :db do
  desc "このタスクは何もしません"
  task :nothing do
    # 本当に何もしません
  end
end
```

タスクの呼び出しは次のようになります：

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # 引数全体を引用符で囲む必要があります
$ bin/rails "task_name[value 1,value2,value3]" # 複数の引数はカンマで区切ります
$ bin/rails db:nothing
```

アプリケーションのモデルとやり取りしたり、データベースクエリを実行したりする場合は、タスクは`environment`タスクに依存する必要があります。これにより、アプリケーションコードがロードされます。

```ruby
task task_that_requires_app_code: [:environment] do
  User.create!
end
```
