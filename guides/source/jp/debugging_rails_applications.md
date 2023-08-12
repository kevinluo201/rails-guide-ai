**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3cf93e3667cdacd242332d2d352d53fa
Railsアプリケーションのデバッグ
============================

このガイドでは、Ruby on Railsアプリケーションのデバッグ技術について紹介します。

このガイドを読み終えると、以下のことがわかるようになります：

* デバッグの目的
* テストでは特定できないアプリケーションの問題や課題を追跡する方法
* デバッグの異なる方法
* スタックトレースの分析方法

--------------------------------------------------------------------------------

デバッグのためのビューヘルパー
--------------------------

一般的なタスクの1つは、変数の内容を調査することです。Railsでは、次の3つの異なる方法を提供しています：

* `debug`
* `to_yaml`
* `inspect`

### `debug`

`debug`ヘルパーは、オブジェクトをYAML形式でレンダリングする`<pre>`タグを返します。これにより、任意のオブジェクトから人間が読めるデータが生成されます。たとえば、ビューで次のコードを持っている場合：

```html+erb
<%= debug @article %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

次のような結果が表示されます：

```yaml
--- !ruby/object Article
attributes:
  updated_at: 2008-09-05 22:55:47
  body: It's a very helpful guide for debugging your Rails app.
  title: Rails debugging guide
  published: t
  id: "1"
  created_at: 2008-09-05 22:55:47
attributes_cache: {}


Title: Rails debugging guide
```

### `to_yaml`

代わりに、任意のオブジェクトに`to_yaml`を呼び出すと、それをYAMLに変換できます。この変換されたオブジェクトを`simple_format`ヘルパーメソッドに渡して出力をフォーマットすることができます。これが`debug`が行っていることです。

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

上記のコードは、次のような結果を表示します：

```yaml
--- !ruby/object Article
attributes:
updated_at: 2008-09-05 22:55:47
body: It's a very helpful guide for debugging your Rails app.
title: Rails debugging guide
published: t
id: "1"
created_at: 2008-09-05 22:55:47
attributes_cache: {}

Title: Rails debugging guide
```

### `inspect`

オブジェクトの値を表示するための別の便利なメソッドは`inspect`です。特に配列やハッシュと一緒に作業する場合に役立ちます。これにより、オブジェクトの値が文字列として表示されます。たとえば：

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

次のように表示されます：

```
[1, 2, 3, 4, 5]

Title: Rails debugging guide
```

ロガー
----------

実行時に情報をログファイルに保存することも便利です。Railsは、各ランタイム環境ごとに別々のログファイルを保持しています。

### ロガーとは何ですか？

Railsは、ログ情報を書き込むために`ActiveSupport::Logger`クラスを使用します。他のロガー（例：`Log4r`）も代替できます。

`config/application.rb`や他の環境ファイルで代替ロガーを指定することができます。たとえば：

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

または、`Initializer`セクションに以下のいずれかを追加します。
```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

TIP: デフォルトでは、各ログは`Rails.root/log/`の下に作成され、ログファイルはアプリケーションが実行されている環境に基づいて名前が付けられます。

### ログレベル

何かがログに記録されると、メッセージのログレベルが設定されたログレベル以上である場合、対応するログに出力されます。現在のログレベルを知りたい場合は、`Rails.logger.level`メソッドを呼び出すことができます。

利用可能なログレベルは、`:debug`、`:info`、`:warn`、`:error`、`:fatal`、および`:unknown`であり、それぞれ0から5までのログレベルに対応しています。デフォルトのログレベルを変更するには、以下を使用します。

```ruby
config.log_level = :warn # 任意の環境初期化子で、または
Rails.logger.level = 0 # 任意のタイミングで
```

これは、開発やステージングでログを記録する際に、不要な情報で本番ログを埋め尽くすことを避けるために便利です。

TIP: デフォルトのRailsログレベルは`:debug`です。ただし、デフォルトで生成される`config/environments/production.rb`では、`production`環境では`:info`に設定されています。

### メッセージの送信

コントローラ、モデル、またはメーラー内から、現在のログに書き込むには、`logger.(debug|info|warn|error|fatal|unknown)`メソッドを使用します。

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
logger.info "Processing the request..."
logger.fatal "Terminating application, raised unrecoverable error!!!"
```

以下は、追加のログを使用して計測されたメソッドの例です。

```ruby
class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(article_params)
    logger.debug "New article: #{@article.attributes.inspect}"
    logger.debug "Article should be valid: #{@article.valid?}"

    if @article.save
      logger.debug "The article was saved and now the user is going to be redirected..."
      redirect_to @article, notice: 'Article was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ...

  private
    def article_params
      params.require(:article).permit(:title, :body, :published)
    end
end
```

以下は、このコントローラアクションが実行されたときに生成されるログの例です。

```
Started POST "/articles" for 127.0.0.1 at 2018-10-18 20:09:23 -0400
Processing by ArticlesController#create as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"XLveDrKzF1SwaiNRPTaMtkrsTzedtebPPkmxEFIU0ordLjICSnXsSNfrdMa4ccyBjuGwnnEiQhEoMN6H1Gtz3A==", "article"=>{"title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>"0"}, "commit"=>"Create Article"}
New article: {"id"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>false, "created_at"=>nil, "updated_at"=>nil}
Article should be valid: true
   (0.0ms)  begin transaction
  ↳ app/controllers/articles_controller.rb:31
  Article Create (0.5ms)  INSERT INTO "articles" ("title", "body", "published", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["title", "Debugging Rails"], ["body", "I'm learning how to print in logs."], ["published", 0], ["created_at", "2018-10-19 00:09:23.216549"], ["updated_at", "2018-10-19 00:09:23.216549"]]
  ↳ app/controllers/articles_controller.rb:31
   (2.3ms)  commit transaction
  ↳ app/controllers/articles_controller.rb:31
The article was saved and now the user is going to be redirected...
Redirected to http://localhost:3000/articles/1
Completed 302 Found in 4ms (ActiveRecord: 0.8ms)
```
このように追加のログを追加すると、ログ内の予期しないまたは異常な動作を検索することが容易になります。追加のログを追加する場合は、ログレベルを適切に使用して、生産ログを無駄な情報で埋めないように注意してください。

### 詳細なクエリログ

ログ内のデータベースクエリの出力を見ると、単一のメソッドが呼び出されたときに複数のデータベースクエリがトリガーされる理由がすぐにはわかりません。

```
irb(main):001:0> Article.pamplemousse
  Article Load (0.4ms)  SELECT "articles".* FROM "articles"
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

`bin/rails console` セッションで `ActiveRecord.verbose_query_logs = true` を実行して詳細なクエリログを有効にし、メソッドを再度実行すると、これらの個別のデータベース呼び出しが生成される単一のコード行が明らかになります。

```
irb(main):003:0> Article.pamplemousse
  Article Load (0.2ms)  SELECT "articles".* FROM "articles"
  ↳ app/models/article.rb:5
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
  ↳ app/models/article.rb:6
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

各データベースステートメントの下には、データベース呼び出しを生成したメソッドの特定のソースファイル名（および行番号）を示す矢印が表示されます。これにより、N+1クエリによって引き起こされるパフォーマンスの問題を特定し、対処することができます。N+1クエリは、複数の追加クエリを生成する単一のデータベースクエリです。

詳細なクエリログは、Rails 5.2以降の開発環境ログでデフォルトで有効になっています。

警告：本番環境ではこの設定の使用をお勧めしません。これはRubyの `Kernel#caller` メソッドに依存しており、メソッド呼び出しのスタックトレースを生成するために多くのメモリを割り当てる傾向があります。代わりにクエリログタグ（以下参照）を使用してください。

### 詳細なエンキューログ

上記の「詳細なクエリログ」と同様に、バックグラウンドジョブをエンキューするメソッドのソース位置を表示することができます。

これは開発環境でデフォルトで有効になっています。他の環境で有効にするには、`application.rb` または任意の環境イニシャライザに追加してください。

```rb
config.active_job.verbose_enqueue_logs = true
```

詳細なエンキューログも、本番環境では使用しないことをお勧めします。
SQLクエリのコメント
------------------

SQL文には、コントローラやジョブの名前などの実行時情報を含むタグでコメントを付けることができます。これにより、問題のあるクエリを生成したアプリケーションの領域にトレースすることができます。これは、遅いクエリをログに記録する場合（例：[MySQL](https://dev.mysql.com/doc/refman/en/slow-query-log.html)、[PostgreSQL](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT)）、現在実行中のクエリを表示する場合、またはエンドツーエンドのトレースツールに便利です。

有効にするには、`application.rb`または任意の環境初期化ファイルに追加します。

```rb
config.active_record.query_log_tags_enabled = true
```

デフォルトでは、アプリケーションの名前、コントローラの名前とアクション、またはジョブの名前がログに記録されます。デフォルトのフォーマットは[SQLCommenter](https://open-telemetry.github.io/opentelemetry-sqlcommenter/)です。例：

```
Article Load (0.2ms)  SELECT "articles".* FROM "articles" /*application='Blog',controller='articles',action='index'*/

Article Update (0.3ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ? WHERE "posts"."id" = ? /*application='Blog',job='ImproveTitleJob'*/  [["title", "Improved Rails debugging guide"], ["updated_at", "2022-10-16 20:25:40.091371"], ["id", 1]]
```

[`ActiveRecord::QueryLogs`](https://api.rubyonrails.org/classes/ActiveRecord/QueryLogs.html)の動作は、SQLクエリからの関連情報の接続に役立つもの（アプリケーションログのリクエストIDやジョブID、アカウントやテナントの識別子など）を含めるように変更できます。

### タグ付きログ

マルチユーザー、マルチアカウントのアプリケーションを実行する際には、カスタムルールを使用してログをフィルタリングできると便利です。Active Supportの`TaggedLogging`は、そのようなアプリケーションのデバッグを支援するために、サブドメイン、リクエストIDなどをログ行にスタンプするのに役立ちます。

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # "[BCX] Stuff"をログに記録
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # "[BCX] [Jason] Stuff"をログに記録
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # "[BCX] [Jason] Stuff"をログに記録
```

### パフォーマンスへのログの影響

ログは常にRailsアプリのパフォーマンスにわずかな影響を与えますが、特にディスクへのログ記録時に影響があります。さらに、いくつかの微妙な点があります。

`debug`レベルを使用すると、`fatal`よりもパフォーマンスに大きなペナルティが発生します。なぜなら、より多くの文字列が評価され、ログ出力（例：ディスク）に書き込まれるためです。

もう1つの潜在的な落とし穴は、コード内で`Logger`に対して多くの呼び出しがある場合です。

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

上記の例では、許可された出力レベルにdebugが含まれていなくても、パフォーマンスに影響があります。その理由は、Rubyがこれらの文字列を評価する必要があるためであり、これにはやや重い`String`オブジェクトのインスタンス化と変数の補間が含まれます。

したがって、ログメソッドにはブロックを渡すことを推奨します。これらは出力レベルが許可されたレベルと同じか、許可されたレベルに含まれている場合にのみ評価されます（つまり、遅延読み込み）。同じコードを書き直すと、次のようになります：
```ruby
logger.debug { "Person attributes hash: #{@person.attributes.inspect}" }
```

ブロックの内容、および文字列内挿は、デバッグが有効になっている場合にのみ評価されます。このパフォーマンスの節約は、大量のログを使用する場合にのみ実際に気付かれますが、良い慣行です。

情報：このセクションは、[Jon CairnsのStack Overflowの回答](https://stackoverflow.com/questions/16546730/logging-in-rails-is-there-any-performance-hit/16546935#16546935)によって書かれ、[cc by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/)でライセンスされています。

`debug` ジェムを使用したデバッグ
------------------------------

コードが予期しない方法で動作している場合、問題を診断するためにログやコンソールに出力してみることができます。残念ながら、この種のエラートラッキングは問題の根本原因を見つけるのに効果的ではない場合もあります。実際に実行中のソースコードに入る必要がある場合、デバッガーが最適な相棒です。

デバッガーは、Railsのソースコードについて学びたいが、どこから始めればいいかわからない場合にも役立ちます。アプリケーションへのリクエストをデバッグし、このガイドを使用して、自分が書いたコードから基礎となるRailsのコードに移動する方法を学ぶことができます。

Rails 7では、CRubyによって生成された新しいアプリケーションの`Gemfile`に`debug`ジェムが含まれています。デフォルトでは、`development`環境と`test`環境で使用できます。使用方法については、[ドキュメント](https://github.com/ruby/debug)をご確認ください。

### デバッグセッションへの入り方

デフォルトでは、デバッグセッションは`debug`ライブラリが必要とされるときに開始されます。これはアプリケーションの起動時に行われますが、心配しないでください、セッションはアプリケーションに干渉しません。

デバッグセッションに入るためには、`binding.break`とそのエイリアスである`binding.b`および`debugger`を使用できます。以下の例では`debugger`を使用します。

```rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    debugger
  end
  # ...
end
```

アプリケーションがデバッグステートメントを評価すると、デバッグセッションに入ります。

```rb
Processing by PostsController#index as HTML
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg)
```

デバッグセッションをいつでも終了し、`continue`（または`c`）コマンドでアプリケーションの実行を続行することができます。または、デバッグセッションとアプリケーションの両方を終了するには、`quit`（または`q`）コマンドを使用します。
### コンテキスト

デバッグセッションに入ると、RailsコンソールやIRBにいるかのようにRubyコードを入力することができます。

```rb
(rdbg) @posts    # ruby
[]
(rdbg) self
#<PostsController:0x0000000000aeb0>
(rdbg)
```

また、`p`または`pp`コマンドを使用してRuby式を評価することもできます。これは、変数名がデバッガコマンドと競合する場合に便利です。

```rb
(rdbg) p headers    # command
=> {"X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "X-Download-Options"=>"noopen", "X-Permitted-Cross-Domain-Policies"=>"none", "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg) pp headers    # command
{"X-Frame-Options"=>"SAMEORIGIN",
 "X-XSS-Protection"=>"1; mode=block",
 "X-Content-Type-Options"=>"nosniff",
 "X-Download-Options"=>"noopen",
 "X-Permitted-Cross-Domain-Policies"=>"none",
 "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg)
```

直接評価するだけでなく、デバッガはさまざまなコマンドを通じて豊富な情報を収集するのにも役立ちます。例えば次のようなコマンドがあります。

- `info`（または`i`）- 現在のフレームに関する情報。
- `backtrace`（または`bt`）- バックトレース（追加情報付き）。
- `outline`（または`o`、`ls`）- 現在のスコープで利用可能なメソッド、定数、ローカル変数、インスタンス変数。

#### `info`コマンド

`info`コマンドは、現在のフレームから見えるローカル変数とインスタンス変数の値の概要を提供します。

```rb
(rdbg) info    # command
%self = #<PostsController:0x0000000000af78>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fd91a037e38 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fd91a03ea08 @mon_data=#<Monitor:0x00007fd91a03e8c8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = []
@rendered_format = nil
```

#### `backtrace`コマンド

オプションなしで使用すると、`backtrace`コマンドはスタック上のすべてのフレームをリストします。

```rb
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  #2    AbstractController::Base#process_action(method_name="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/base.rb:214
  #3    ActionController::Rendering#process_action(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/rendering.rb:53
  #4    block in process_action at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/callbacks.rb:221
  #5    block in run_callbacks at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:118
  #6    ActionText::Rendering::ClassMethods#with_renderer(renderer=#<PostsController:0x0000000000af78>) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/rendering.rb:20
  #7    block {|controller=#<PostsController:0x0000000000af78>, action=#<Proc:0x00007fd91985f1c0 /Users/st0012/...|} in <class:Engine> (4 levels) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/engine.rb:69
  #8    [C] BasicObject#instance_exec at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:127
  ..... その他
```

各フレームには次の情報が含まれます。

- フレーム識別子
- 呼び出し場所
- 追加情報（ブロックやメソッドの引数など）

これにより、アプリケーションで何が起こっているかを把握することができます。ただし、おそらく次のことに気付くでしょう。

- フレームが多すぎる（通常、Railsアプリケーションでは50以上）。
- フレームのほとんどはRailsや他の使用しているライブラリからのものです。

`backtrace`コマンドには、フレームをフィルタリングするための2つのオプションがあります。

- `backtrace [num]` - `num`個のフレームのみ表示します。例：`backtrace 10`。
- `backtrace /pattern/` - 識別子または場所がパターンに一致するフレームのみ表示します。例：`backtrace /MyModel/`。

これらのオプションを組み合わせて使用することも可能です：`backtrace [num] /pattern/`。
#### `outline`コマンド

`outline`は、`pry`や`irb`の`ls`コマンドと似ています。現在のスコープからアクセス可能な要素を表示します。以下の要素が含まれます。

- ローカル変数
- インスタンス変数
- クラス変数
- メソッドとそのソースコード

```rb
ActiveSupport::Configurable#methods: config
AbstractController::Base#methods:
  action_methods  action_name  action_name=  available_action?  controller_path  inspect
  response_body
ActionController::Metal#methods:
  content_type       content_type=  controller_name  dispatch          headers
  location           location=      media_type       middleware_stack  middleware_stack=
  middleware_stack?  performed?     request          request=          reset_session
  response           response=      response_body=   response_code     session
  set_request!       set_response!  status           status=           to_a
ActionView::ViewPaths#methods:
  _prefixes  any_templates?  append_view_path   details_for_lookup  formats     formats=  locale
  locale=    lookup_context  prepend_view_path  template_exists?    view_paths
AbstractController::Rendering#methods: view_assigns

# .....

PostsController#methods: create  destroy  edit  index  new  show  update
instance variables:
  @_action_has_layout  @_action_name    @_config  @_lookup_context                      @_request
  @_response           @_response_body  @_routes  @marked_for_same_origin_verification  @posts
  @rendered_format
class variables: @@raise_on_missing_translations  @@raise_on_open_redirects
```

### ブレークポイント

デバッガには、ブレークポイントを挿入してトリガーするための多くの方法があります。コードにデバッグステートメント（例：`debugger`）を直接追加するだけでなく、次のコマンドでブレークポイントを挿入することもできます。

- `break`（または`b`）
  - `break` - すべてのブレークポイントをリスト表示します。
  - `break <num>` - 現在のファイルの`num`行にブレークポイントを設定します。
  - `break <file:num>` - `file`の`num`行にブレークポイントを設定します。
  - `break <Class#method>`または`break <Class.method>` - `Class#method`または`Class.method`にブレークポイントを設定します。
  - `break <expr>.<method>` - `<expr>`の結果の`<method>`メソッドにブレークポイントを設定します。
- `catch <Exception>` - `Exception`が発生したときに停止するブレークポイントを設定します。
- `watch <@ivar>` - 現在のオブジェクトの`@ivar`の結果が変更されたときに停止するブレークポイントを設定します（これは遅いです）。

そして、ブレークポイントを削除するには、次のコマンドを使用できます。

- `delete`（または`del`）
  - `delete` - すべてのブレークポイントを削除します。
  - `delete <num>` - IDが`num`のブレークポイントを削除します。

#### `break`コマンド

**指定された行番号にブレークポイントを設定します - 例：`b 28`**

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg) b 28    # break command
#0  BP - Line  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (line)
```

```rb
(rdbg) c    # continue command
[23, 32] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    23|   def create
    24|     @post = Post.new(post_params)
    25|     debugger
    26|
    27|     respond_to do |format|
=>  28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
    30|         format.json { render :show, status: :created, location: @post }
    31|       else
    32|         format.html { render :new, status: :unprocessable_entity }
=>#0    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  #1    ActionController::MimeResponds#respond_to(mimes=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/mime_responds.rb:205
  # and 74 frames (use `bt' command for all frames)

Stop by #0  BP - Line  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (line)
```
指定されたメソッド呼び出しにブレークポイントを設定します - 例：`b @post.save`。

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg) b @post.save    # break command
#0  BP - Method  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43

```

```rb
(rdbg) c    # continue command
[39, 48] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb
    39|         SuppressorRegistry.suppressed[name] = previous_state
    40|       end
    41|     end
    42|
    43|     def save(**) # :nodoc:
=>  44|       SuppressorRegistry.suppressed[self.class.name] ? true : super
    45|     end
    46|
    47|     def save!(**) # :nodoc:
    48|       SuppressorRegistry.suppressed[self.class.name] ? true : super
=>#0    ActiveRecord::Suppressor#save(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:44
  #1    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  # and 75 frames (use `bt' command for all frames)

Stop by #0  BP - Method  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43
```

#### `catch`コマンド

例外が発生したときに停止します - 例：`catch ActiveRecord::RecordInvalid`。

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg) catch ActiveRecord::RecordInvalid    # command
#1  BP - Catch  "ActiveRecord::RecordInvalid"
```

```rb
(rdbg) c    # continue command
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # and 88 frames (use `bt' command for all frames)

Stop by #1  BP - Catch  "ActiveRecord::RecordInvalid"
```

#### `watch`コマンド

インスタンス変数が変更されたときに停止します - 例：`watch @_response_body`。

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg) watch @_response_body    # command
#0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =
```
```rb
(rdbg) c    # 続行コマンド
[173, 182] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb
   173|       body = [body] unless body.nil? || body.respond_to?(:each)
   174|       response.reset_body!
   175|       return unless body
   176|       response.body = body
   177|       super
=> 178|     end
   179|
   180|     # Tests if render or redirect has already happened.
   181|     def performed?
   182|       response_body || response.committed?
=>#0    ActionController::Metal#response_body=(body=["<html><body>You are being <a href=\"ht...) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb:178 #=> ["<html><body>You are being <a href=\"ht...
  #1    ActionController::Redirecting#redirect_to(options=#<Post id: 13, title: "qweqwe", content:..., response_options={:allow_other_host=>false}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/redirecting.rb:74
  # and 82 frames (use `bt' command for all frames)

#0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =  -> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
(rdbg)
```

#### ブレークポイントオプション

さまざまなタイプのブレークポイントに加えて、より高度なデバッグワークフローを実現するためにオプションを指定することもできます。現在、デバッガは4つのオプションをサポートしています。

- `do: <cmd or expr>` - ブレークポイントがトリガされたときに、指定されたコマンド/式を実行してプログラムを続行します：
  - `break Foo#bar do: bt` - `Foo#bar` が呼び出されたときにスタックフレームを表示します
- `pre: <cmd or expr>` - ブレークポイントがトリガされたときに、停止する前に指定されたコマンド/式を実行します：
  - `break Foo#bar pre: info` - `Foo#bar` が呼び出されたときに、停止する前にその周囲の変数を表示します。
- `if: <expr>` - ブレークポイントは、`<expr>` の結果が true の場合にのみ停止します：
  - `break Post#save if: params[:debug]` - `params[:debug]` も true の場合に `Post#save` で停止します
- `path: <path_regexp>` - ブレークポイントは、トリガーとなるイベント（メソッド呼び出しなど）が指定されたパスから発生した場合にのみ停止します：
  - `break Post#save if: app/services/a_service` - メソッド呼び出しが Ruby の正規表現 `/app\/services\/a_service/` に一致するメソッドで `Post#save` で停止します。

また、前述したデバッグステートメントにも、`do:`、`pre:`、`if:` の3つのオプションが使用できることにも注意してください。例えば：

```rb
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger(do: "info")
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg:binding.break) info
%self = #<PostsController:0x00000000017480>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fce3ad336b8 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fce3ad397e8 @mon_data=#<Monitor:0x00007fce3ad396a8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = #<ActiveRecord::Relation [#<Post id: 2, title: "qweqwe", content: "qweqwe", created_at: "...
@rendered_format = nil
```
#### デバッグワークフローをプログラムする

これらのオプションを使用して、次のように1行でデバッグワークフローをスクリプト化することができます。

```rb
def create
  debugger(do: "catch ActiveRecord::RecordInvalid do: bt 10")
  # ...
end
```

そして、デバッガはスクリプト化されたコマンドを実行し、catchブレークポイントを挿入します。

```rb
(rdbg:binding.break) catch ActiveRecord::RecordInvalid do: bt 10
#0  BP - Catch  "ActiveRecord::RecordInvalid"
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # および 88 フレーム (`bt' コマンドで全フレームを表示)
```

catchブレークポイントがトリガされると、スタックフレームが表示されます。

```rb
Stop by #0  BP - Catch  "ActiveRecord::RecordInvalid"

(rdbg:catch) bt 10
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  #2    block in save! at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/transactions.rb:302
```

このテクニックは、繰り返し入力を省略し、デバッグ体験をスムーズにすることができます。

より詳しいコマンドや設定オプションについては、[ドキュメント](https://github.com/ruby/debug)を参照してください。

`web-console` ジェムを使用したデバッグ
------------------------------------

Web Consoleは、ブラウザで実行される `debug` のようなものです。ビューやコントローラのコンテキストで、任意のページでコンソールをリクエストすることができます。コンソールはHTMLコンテンツの隣にレンダリングされます。

### コンソール

コントローラのアクションやビューの内部で、`console` メソッドを呼び出すことでコンソールを起動できます。

例えば、コントローラ内で：

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

または、ビュー内で：

```html+erb
<% console %>

<h2>New Post</h2>
```

これにより、ビュー内にコンソールがレンダリングされます。`console` の呼び出しの場所については気にする必要はありません。呼び出しの場所にはレンダリングされず、HTMLコンテンツの隣に表示されます。

コンソールは純粋なRubyコードを実行します。カスタムクラスを定義したり、インスタンスを作成したり、変数を検査したりすることができます。

注意：1つのリクエストに対して1つのコンソールしかレンダリングできません。それ以外の場合、`web-console` は2回目の `console` 呼び出しでエラーを発生させます。

### 変数の検査

`instance_variables` を呼び出すことで、コンテキストで利用可能なすべてのインスタンス変数をリストアップすることができます。ローカル変数をリストアップするには、`local_variables` を使用します。

### 設定

* `config.web_console.allowed_ips`：許可されたIPv4またはIPv6のアドレスとネットワークのリスト（デフォルト：`127.0.0.1/8, ::1`）。
* `config.web_console.whiny_requests`：コンソールのレンダリングが防止された場合にメッセージをログに記録するかどうか（デフォルト：`true`）。
`web-console`はサーバー上でリモートでプレーンなRubyコードを評価するため、本番環境では使用しないでください。

メモリーリークのデバッグ
----------------------

Rubyアプリケーション（Railsを使用しているかどうかに関係なく）は、RubyコードまたはCコードレベルでメモリーリークが発生する可能性があります。

このセクションでは、Valgrindなどのツールを使用して、このようなリークを見つけて修正する方法について学びます。

### Valgrind

[Valgrind](http://valgrind.org/)は、Cベースのメモリーリークや競合状態を検出するためのアプリケーションです。

Valgrindには、多くのメモリ管理およびスレッド関連のバグを自動的に検出し、プログラムを詳細にプロファイルするツールがあります。たとえば、インタプリタのC拡張が`malloc()`を呼び出しても適切に`free()`を呼び出さない場合、このメモリはアプリケーションが終了するまで利用できません。

Valgrindのインストール方法とRubyとの使用方法の詳細については、Evan Weaverによる[Valgrind and Ruby](https://blog.evanweaver.com/2008/02/05/valgrind-and-ruby/)を参照してください。

### メモリーリークの検出

Derailedには、メモリーリークの検出と修正についての優れた記事があります。[こちらで読むことができます](https://github.com/schneems/derailed_benchmarks#is-my-app-leaking-memory)。

デバッグ用のプラグイン
---------------------

Railsのプラグインには、エラーの検出とアプリケーションのデバッグを支援するものがあります。以下はデバッグに役立つプラグインのリストです。

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master)：ログにクエリの起点のトレースを追加します。
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master)：Railsアプリケーションでエラーが発生した場合にメール通知を送信するためのメーラーオブジェクトとデフォルトのテンプレートを提供します。
* [Better Errors](https://github.com/charliesome/better_errors)：より多くの文脈情報（ソースコードや変数の検査など）を含む新しいRailsエラーページに置き換えます。
* [RailsPanel](https://github.com/dejan/rails_panel)：開発.logの追跡を終了するためのRails開発用のChrome拡張機能です。ブラウザの開発者ツールパネルにRailsアプリケーションのリクエストに関するすべての情報が表示されます。データベースの処理時間、レンダリング時間、パラメータリスト、レンダリングされたビューなどがわかります。
* [Pry](https://github.com/pry/pry)：IRBの代替となるランタイム開発者コンソールです。

参考文献
----------

* [web-console ホームページ](https://github.com/rails/web-console)
* [debug ホームページ](https://github.com/ruby/debug)
