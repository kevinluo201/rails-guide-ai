**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3cf93e3667cdacd242332d2d352d53fa
除錯 Rails 應用程式
====================

本指南介紹了除錯 Ruby on Rails 應用程式的技巧。

閱讀本指南後，您將了解以下內容：

* 除錯的目的。
* 如何追蹤應用程式中未被測試識別的問題和問題。
* 不同的除錯方式。
* 如何分析堆疊追蹤。

--------------------------------------------------------------------------------

用於除錯的視圖輔助方法
----------------------

一個常見的任務是檢查變數的內容。Rails 提供了三種不同的方法來完成這個任務：

* `debug`
* `to_yaml`
* `inspect`

### `debug`

`debug` 輔助方法將返回一個使用 YAML 格式呈現對象的 \<pre> 標籤。這將從任何對象生成可讀的數據。例如，如果您在視圖中有以下代碼：

```html+erb
<%= debug @article %>
<p>
  <b>標題：</b>
  <%= @article.title %>
</p>
```

您將看到類似以下的內容：

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


標題：Rails debugging guide
```

### `to_yaml`

或者，對任何對象調用 `to_yaml` 將其轉換為 YAML。您可以將此轉換後的對象傳遞給 `simple_format` 輔助方法以格式化輸出。這就是 `debug` 做其工作的方式。

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>標題：</b>
  <%= @article.title %>
</p>
```

上述代碼將呈現類似以下的內容：

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

標題：Rails debugging guide
```

### `inspect`

顯示對象值的另一個有用方法是 `inspect`，特別是在處理數組或哈希時。這將將對象值打印為字符串。例如：

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>標題：</b>
  <%= @article.title %>
</p>
```

將呈現：

```
[1, 2, 3, 4, 5]

標題：Rails debugging guide
```

日誌記錄器
----------

在運行時將信息保存到日誌文件中也可能很有用。Rails 為每個運行時環境維護一個單獨的日誌文件。

### 什麼是日誌記錄器？

Rails 使用 `ActiveSupport::Logger` 類來寫入日誌信息。其他日誌記錄器，如 `Log4r`，也可以替換。

您可以在 `config/application.rb` 或任何其他環境文件中指定替代日誌記錄器，例如：

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

或在 `Initializer` 部分，添加 _任何_ 以下內容之一

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

提示：默認情況下，每個日誌都在 `Rails.root/log/` 下創建，日誌文件的名稱是應用程式運行的環境。

### 日誌級別

當有東西被記錄時，如果消息的日誌級別等於或高於配置的日誌級別，則將其打印到相應的日誌中。如果您想知道當前的日誌級別，可以調用 `Rails.logger.level` 方法。

可用的日誌級別有：`:debug`、`:info`、`:warn`、`:error`、`:fatal` 和 `:unknown`，分別對應日誌級別從 0 到 5 的數字。要更改默認日誌級別，使用
```ruby
config.log_level = :warn # 在任何環境初始化器中，或者
Rails.logger.level = 0 # 在任何時候

這在您想要在開發或暫存環境下記錄日誌，而不會將不必要的信息洪水般地填滿生產日誌時非常有用。

提示：默認的 Rails 日誌級別是 `:debug`。但是，在默認生成的 `config/environments/production.rb` 中，它被設置為 `:info`。

### 發送消息

要在當前日誌中寫入，請在控制器、模型或郵件程序中使用 `logger.(debug|info|warn|error|fatal|unknown)` 方法：

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
logger.info "Processing the request..."
logger.fatal "Terminating application, raised unrecoverable error!!!"
```

這是一個使用額外日誌記錄的方法示例：

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

以下是執行此控制器動作時生成的日誌示例：

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

像這樣添加額外的日誌記錄，可以輕鬆搜索日誌中的意外或不尋常行為。如果添加額外的日誌記錄，請確保合理使用日誌級別，以避免將生產日誌填滿無用的琐事。

### 詳細查詢日誌

在查看日誌中的數據庫查詢輸出時，當調用單個方法時觸發多個數據庫查詢時，可能不會立即清楚原因：

```
irb(main):001:0> Article.pamplemousse
  Article Load (0.4ms)  SELECT "articles".* FROM "articles"
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

在 `bin/rails console` 會話中運行 `ActiveRecord.verbose_query_logs = true` 以啟用詳細查詢日誌，然後再次運行該方法，就會明顯看到哪一行代碼生成了所有這些獨立的數據庫調用：

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
```
在每個數據庫語句下，您可以看到指向導致數據庫調用的方法的特定源文件名稱（和行號）的箭頭。這可以幫助您識別和解決由N+1查詢引起的性能問題：單個數據庫查詢生成多個額外查詢的情況。

從Rails 5.2開始，開發環境日誌中默認啟用詳細查詢日誌。

警告：我們建議不要在生產環境中使用此設置。它依賴於Ruby的`Kernel#caller`方法，該方法在生成方法調用的堆棧跟踪時往往會分配大量內存。請改用查詢日誌標籤（見下文）。

### 詳細排隊日誌

與上面的“詳細查詢日誌”類似，允許打印排隊後台作業的方法的源位置。

在開發環境中默認啟用。要在其他環境中啟用，請在`application.rb`或任何環境初始化程序中添加：

```rb
config.active_job.verbose_enqueue_logs = true
```

與詳細查詢日誌一樣，不建議在生產環境中使用。

SQL查詢註釋
------------------

可以使用包含運行時信息的標籤對SQL語句進行註釋，例如控制器或作業的名稱，以將問題查詢追蹤回生成這些語句的應用程序區域。這在記錄緩慢查詢（例如[MySQL](https://dev.mysql.com/doc/refman/en/slow-query-log.html)、[PostgreSQL](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT)）、查看當前運行的查詢或用於端到端追蹤工具時非常有用。

要啟用，請在`application.rb`或任何環境初始化程序中添加：

```rb
config.active_record.query_log_tags_enabled = true
```

默認情況下，記錄應用程序的名稱、控制器的名稱和操作，或作業的名稱。默認格式為[SQLCommenter](https://open-telemetry.github.io/opentelemetry-sqlcommenter/)。例如：

```
Article Load (0.2ms)  SELECT "articles".* FROM "articles" /*application='Blog',controller='articles',action='index'*/

Article Update (0.3ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ? WHERE "posts"."id" = ? /*application='Blog',job='ImproveTitleJob'*/  [["title", "Improved Rails debugging guide"], ["updated_at", "2022-10-16 20:25:40.091371"], ["id", 1]]
```

[`ActiveRecord::QueryLogs`](https://api.rubyonrails.org/classes/ActiveRecord/QueryLogs.html)的行為可以修改，以包括任何有助於從SQL查詢中連接點的信息，例如請求和作業ID用於應用程序日誌、帳戶和租戶標識等。

### 標記日誌

在運行多用戶、多帳戶應用程序時，通常可以使用一些自定義規則來過濾日誌。Active Support中的`TaggedLogging`正是通過為日誌行添加子域、請求ID和其他有助於調試此類應用程序的信息來實現這一點。

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # 記錄 "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # 記錄 "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # 記錄 "[BCX] [Jason] Stuff"
```

### 日誌對性能的影響

日誌記錄對Rails應用程序的性能總是會有一定的影響，特別是在將日誌記錄到磁盤時。此外，還有一些細微之處：

使用`：debug`級別的性能損失比`：fatal`更大，因為需要評估並將更多的字符串寫入日誌輸出（例如磁盤）。

另一個潛在的陷阱是在代碼中對`Logger`進行過多的調用：

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

在上面的示例中，即使允許的輸出級別不包括debug，也會對性能產生影響。原因是Ruby需要評估這些字符串，其中包括實例化相對較重的`String`對象和插值變量。
因此，建議將區塊傳遞給日誌記錄方法，因為只有在輸出級別與允許的級別相同或包含在內時（即延遲加載），才會評估這些區塊。重寫相同的程式碼如下：

```ruby
logger.debug { "Person attributes hash: #{@person.attributes.inspect}" }
```

區塊的內容，以及因此的字串插值，只有在啟用 debug 時才會評估。這種效能節省只有在大量日誌記錄時才會真正顯著，但這是一種良好的實踐方法。

資訊：本節內容由 [Jon Cairns 在 Stack Overflow 的回答](https://stackoverflow.com/questions/16546730/logging-in-rails-is-there-any-performance-hit/16546935#16546935) 撰寫，並根據 [cc by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/) 授權。

使用 `debug` Gem 進行除錯
------------------------------

當您的程式碼表現出意外行為時，您可以嘗試將訊息輸出到日誌或控制台以診斷問題。不幸的是，有時這種錯誤追蹤方法無法有效找到問題的根本原因。當您實際需要進入正在運行的原始碼時，調試器是您最好的夥伴。

調試器還可以幫助您了解 Rails 原始碼，但不知道從何處開始。只需對應用程式進行任何請求並使用本指南學習如何從您編寫的程式碼轉到底層的 Rails 程式碼。

Rails 7 在由 CRuby 生成的新應用程式的 `Gemfile` 中包含了 `debug` gem。默認情況下，它在 `development` 和 `test` 環境中可用。請查閱其 [文檔](https://github.com/ruby/debug) 以了解使用方法。

### 進入調試會話

默認情況下，在需要時會在 `debug` 庫被引用後開始調試會話，這發生在您的應用程式啟動時。但請放心，該會話不會干擾您的應用程式。

要進入調試會話，您可以使用 `binding.break` 及其別名：`binding.b` 和 `debugger`。以下示例將使用 `debugger`：

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

一旦您的應用程式評估調試語句，它將進入調試會話：

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

您可以隨時退出調試會話並使用 `continue`（或 `c`）命令繼續執行應用程式。或者，要退出調試會話和應用程式，請使用 `quit`（或 `q`）命令。

### 上下文

進入調試會話後，您可以輸入 Ruby 程式碼，就像在 Rails 控制台或 IRB 中一樣。

```rb
(rdbg) @posts    # ruby
[]
(rdbg) self
#<PostsController:0x0000000000aeb0>
(rdbg)
```

您還可以使用 `p` 或 `pp` 命令評估 Ruby 表達式，這在變數名稱與調試器命令衝突時很有用。
```rb
(rdbg) p headers    # 命令
=> {"X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "X-Download-Options"=>"noopen", "X-Permitted-Cross-Domain-Policies"=>"none", "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg) pp headers    # 命令
{"X-Frame-Options"=>"SAMEORIGIN",
 "X-XSS-Protection"=>"1; mode=block",
 "X-Content-Type-Options"=>"nosniff",
 "X-Download-Options"=>"noopen",
 "X-Permitted-Cross-Domain-Policies"=>"none",
 "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg)
```

除了直接評估之外，調試器還可以通過不同的命令幫助您收集豐富的信息，例如：

- `info`（或`i`）- 關於當前框架的信息。
- `backtrace`（或`bt`）- 堆棧回溯（附加信息）。
- `outline`（或`o`，`ls`）- 當前作用域中可用的方法、常量、局部變量和實例變量。

#### `info` 命令

`info` 提供了從當前框架可見的局部變量和實例變量的值的概述。

```rb
(rdbg) info    # 命令
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

#### `backtrace` 命令

當不帶任何選項使用 `backtrace` 時，它會列出堆棧上的所有框架：

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
  ..... and more
```

每個框架都包含：

- 框架標識符
- 調用位置
- 附加信息（例如塊或方法參數）

這將讓您對應用程序中正在發生的情況有很好的了解。但是，您可能會注意到：

- 框架太多（通常在 Rails 應用程序中超過 50 個）。
- 大多數框架來自於您使用的 Rails 或其他庫。

`backtrace` 命令提供了 2 個選項，以幫助您過濾框架：

- `backtrace [num]` - 只顯示 `num` 個框架，例如 `backtrace 10`。
- `backtrace /pattern/` - 只顯示標識符或位置與模式匹配的框架，例如 `backtrace /MyModel/`。

也可以一起使用這些選項：`backtrace [num] /pattern/`。

#### `outline` 命令

`outline` 類似於 `pry` 和 `irb` 的 `ls` 命令。它將顯示當前作用域中可訪問的內容，包括：

- 局部變量
- 實例變量
- 類變量
- 方法及其源代碼

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

### 斷點

有多種方法可以在調試器中插入和觸發斷點。除了直接在代碼中添加調試語句（例如 `debugger`）之外，還可以使用以下命令插入斷點：

- `break`（或 `b`）
  - `break` - 列出所有斷點
  - `break <num>` - 在當前文件的第 `num` 行設置斷點
  - `break <file:num>` - 在 `file` 的第 `num` 行設置斷點
  - `break <Class#method>` 或 `break <Class.method>` - 在 `Class#method` 或 `Class.method` 上設置斷點
  - `break <expr>.<method>` - 在 `<expr>` 結果的 `<method>` 方法上設置斷點。
- `catch <Exception>` - 設置當引發 `Exception` 時停止的斷點
- `watch <@ivar>` - 設置當當前對象的 `@ivar` 的結果發生變化時停止的斷點（這很慢）
要刪除它們，您可以使用：

- `delete`（或`del`）
  - `delete` - 刪除所有斷點
  - `delete <num>` - 刪除ID為`num`的斷點

#### `break` 命令

**在指定的行號上設置斷點 - 例如 `b 28`**

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
(rdbg) b 28    # 斷點命令
#0  BP - 行  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (line)
```

```rb
(rdbg) c    # 繼續命令
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

停在 #0  BP - 行  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (line)
```

在指定的方法調用上設置斷點 - 例如 `b @post.save`。

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
(rdbg) b @post.save    # 斷點命令
#0  BP - 方法  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43

```

```rb
(rdbg) c    # 繼續命令
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

停在 #0  BP - 方法  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43
```

#### `catch` 命令

當引發異常時停止 - 例如 `catch ActiveRecord::RecordInvalid`。

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
(rdbg) catch ActiveRecord::RecordInvalid    # 命令
#1  BP - Catch  "ActiveRecord::RecordInvalid"
```

```rb
(rdbg) c    # 繼續命令
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

停在 #1  BP - Catch  "ActiveRecord::RecordInvalid"
#### `watch` 命令

當實例變數改變時停止 - 例如 `watch @_response_body`。

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
(rdbg) watch @_response_body    # 命令
#0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =
```

```rb
(rdbg) c    # 繼續執行命令
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
=>#0    ActionController::Metal#response_body=(body=["<html><body>You are being <a href=\"ht...) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb:178 #=> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
  #1    ActionController::Redirecting#redirect_to(options=#<Post id: 13, title: "qweqwe", content:..., response_options={:allow_other_host=>false}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/redirecting.rb:74
  # and 82 frames (use `bt' command for all frames)

停在 #0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =  -> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
(rdbg)
```

#### 斷點選項

除了不同類型的斷點外，您還可以指定選項以實現更高級的調試工作流程。目前，調試器支持 4 個選項：

- `do: <cmd or expr>` - 當觸發斷點時，執行給定的命令/表達式並繼續執行程序：
  - `break Foo#bar do: bt` - 當調用 `Foo#bar` 時，打印堆棧幀
- `pre: <cmd or expr>` - 當觸發斷點時，在停止之前執行給定的命令/表達式：
  - `break Foo#bar pre: info` - 當調用 `Foo#bar` 時，在停止之前打印其周圍變量。
- `if: <expr>` - 斷點只在 `<expr>` 的結果為 true 時停止：
  - `break Post#save if: params[:debug]` - 如果 `params[:debug]` 也為 true，則在 `Post#save` 停止
- `path: <path_regexp>` - 斷點只在觸發它的事件（例如方法調用）發生在給定的路徑時停止：
  - `break Post#save if: app/services/a_service` - 如果方法調用發生在與 Ruby 正則表達式 `/app\/services\/a_service/` 匹配的方法上，則在 `Post#save` 停止。

還請注意，前三個選項：`do:`、`pre:` 和 `if:` 也適用於我們之前提到的調試語句。例如：

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
#### 程式化您的除錯工作流程

有了這些選項，您可以像這樣在一行中編寫您的除錯工作流程：

```rb
def create
  debugger(do: "catch ActiveRecord::RecordInvalid do: bt 10")
  # ...
end
```

然後調試器將運行腳本化的命令並插入捕獲斷點

```rb
(rdbg:binding.break) catch ActiveRecord::RecordInvalid do: bt 10
#0  BP - 捕獲  "ActiveRecord::RecordInvalid"
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
  # 和 88 個框架 (使用 `bt' 命令查看所有框架)
```

一旦觸發捕獲斷點，它將打印堆棧幀

```rb
Stop by #0  BP - 捕獲  "ActiveRecord::RecordInvalid"

(rdbg:catch) bt 10
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  #2    block in save! at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/transactions.rb:302
```

這種技術可以節省您重複輸入的時間，使除錯體驗更加順暢。

您可以從其[文檔](https://github.com/ruby/debug)中找到更多命令和配置選項。

使用 `web-console` Gem 進行除錯
------------------------------------

Web Console 有點像 `debug`，但它在瀏覽器中運行。您可以在任何頁面的視圖或控制器上請求一個控制台。控制台將呈現在您的 HTML 內容旁邊。

### 控制台

在任何控制器操作或視圖中，您可以通過調用 `console` 方法來調用控制台。

例如，在控制器中：

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

或在視圖中：

```html+erb
<% console %>

<h2>New Post</h2>
```

這將在您的視圖中呈現一個控制台。您不需要關心 `console` 調用的位置；它不會在其調用的位置呈現，而是在您的 HTML 內容旁邊呈現。

控制台執行純 Ruby 代碼：您可以定義和實例化自定義類，創建新模型並檢查變量。

注意：每個請求只能呈現一個控制台。否則，`web-console` 將在第二個 `console` 調用上引發錯誤。

### 檢查變量

您可以調用 `instance_variables` 列出上下文中可用的所有實例變量。如果要列出所有局部變量，可以使用 `local_variables`。

### 設置

* `config.web_console.allowed_ips`：授權的 IPv4 或 IPv6 地址和網絡列表（默認值：`127.0.0.1/8, ::1`）。
* `config.web_console.whiny_requests`：當阻止控制台呈現時記錄一條消息（默認值：`true`）。

由於 `web-console` 在服務器上遠程評估純 Ruby 代碼，請勿在生產環境中使用它。

除錯記憶體洩漏
----------------------

Ruby 應用程序（無論是 Rails 還是其他）可能會洩漏記憶體 - 在 Ruby 代碼或 C 代碼層面。

在本節中，您將學習如何使用工具（如 Valgrind）找到和修復此類洩漏。

### Valgrind

[Valgrind](http://valgrind.org/) 是一個用於檢測基於 C 的內存洩漏和競爭條件的應用程序。

Valgrind 工具可以自動檢測許多內存管理和線程錯誤，並詳細分析您的程序。例如，如果解釋器中的 C 擴展調用 `malloc()`，但未正確調用 `free()`，則該內存在應用程序終止之前將不可用。
有關如何安裝Valgrind並與Ruby一起使用的更多信息，請參考Evan Weaver的[Valgrind and Ruby](https://blog.evanweaver.com/2008/02/05/valgrind-and-ruby/)。

### 尋找記憶體洩漏

在Derailed上有一篇關於檢測和修復記憶體洩漏的優秀文章，[您可以在這裡閱讀](https://github.com/schneems/derailed_benchmarks#is-my-app-leaking-memory)。

用於調試的插件
----------------

有一些Rails插件可以幫助您查找錯誤並調試應用程序。以下是一些有用的調試插件列表：

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master) 將查詢的來源追蹤添加到日誌中。
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master) 提供一個郵件對象和一組默認模板，用於在Rails應用程序中發生錯誤時發送郵件通知。
* [Better Errors](https://github.com/charliesome/better_errors) 用一個包含更多上下文信息（如源代碼和變量檢查）的新錯誤頁面替換標準的Rails錯誤頁面。
* [RailsPanel](https://github.com/dejan/rails_panel) 用於Rails開發的Chrome擴展，將結束對development.log的追蹤。在瀏覽器的開發者工具面板中提供有關Rails應用程序請求的所有信息，包括數據庫/渲染/總時間、參數列表、渲染的視圖等。
* [Pry](https://github.com/pry/pry) 一個IRB替代品和運行時開發者控制台。

參考資料
----------

* [web-console 主頁](https://github.com/rails/web-console)
* [debug 主頁](https://github.com/ruby/debug)
