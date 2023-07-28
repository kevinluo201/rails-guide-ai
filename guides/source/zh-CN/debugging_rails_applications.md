**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3cf93e3667cdacd242332d2d352d53fa
调试Rails应用程序
============================

本指南介绍了调试Ruby on Rails应用程序的技术。

阅读本指南后，您将了解到：

* 调试的目的。
* 如何追踪应用程序中测试未能识别的问题和错误。
* 调试的不同方式。
* 如何分析堆栈跟踪。

--------------------------------------------------------------------------------

用于调试的视图助手
--------------------------

一个常见的任务是检查变量的内容。Rails提供了三种不同的方法来实现这一点：

* `debug`
* `to_yaml`
* `inspect`

### `debug`

`debug`助手将返回一个使用YAML格式呈现对象的`<pre>`标签。这将从任何对象生成可读的数据。例如，如果您在视图中有以下代码：

```html+erb
<%= debug @article %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

您将看到类似于以下内容：

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

或者，对任何对象调用`to_yaml`将其转换为YAML。您可以将此转换后的对象传递给`simple_format`助手方法以格式化输出。这就是`debug`的魔力所在。

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

上述代码将呈现类似于以下内容：

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

显示对象值的另一个有用方法是`inspect`，特别是在使用数组或哈希时。这将将对象值打印为字符串。例如：

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

将呈现：

```
[1, 2, 3, 4, 5]

Title: Rails debugging guide
```

日志记录器
----------

在运行时将信息保存到日志文件中也可能很有用。Rails为每个运行时环境维护一个单独的日志文件。

### 什么是日志记录器？

Rails使用`ActiveSupport::Logger`类来写入日志信息。其他日志记录器，如`Log4r`，也可以替代。

您可以在`config/application.rb`或任何其他环境文件中指定替代日志记录器，例如：

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

或者在`Initializer`部分，添加以下任意一个

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

提示：默认情况下，每个日志都在`Rails.root/log/`下创建，并且日志文件的名称与应用程序运行的环境相同。

### 日志级别

当记录某些内容时，如果消息的日志级别等于或高于配置的日志级别，则将其打印到相应的日志中。如果您想知道当前的日志级别，可以调用`Rails.logger.level`方法。

可用的日志级别有：`:debug`、`:info`、`:warn`、`:error`、`:fatal`和`:unknown`，分别对应日志级别从0到5的数字。要更改默认日志级别，请使用
```ruby
config.log_level = :warn # 在任何环境初始化文件中，或者
Rails.logger.level = 0 # 在任何时候

当你想要在开发或者暂存环境下记录日志，而不会在生产日志中记录不必要的信息时，这是非常有用的。

提示：默认的Rails日志级别是`:debug`。然而，在默认生成的`config/environments/production.rb`文件中，它被设置为`:info`。

### 发送消息

要在当前日志中写入内容，可以在控制器、模型或者邮件中使用`logger.(debug|info|warn|error|fatal|unknown)`方法：

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
logger.info "Processing the request..."
logger.fatal "Terminating application, raised unrecoverable error!!!"
```

下面是一个带有额外日志记录的方法示例：

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

当执行这个控制器动作时，下面是生成的日志示例：

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

像这样添加额外的日志记录，可以方便地搜索日志中的意外或异常行为。如果添加额外的日志记录，请确保合理使用日志级别，以避免在生产日志中填充无用的琐事。

### 冗长的查询日志

当在日志中查看数据库查询输出时，可能不会立即清楚为什么在调用单个方法时会触发多个数据库查询：

```
irb(main):001:0> Article.pamplemousse
  Article Load (0.4ms)  SELECT "articles".* FROM "articles"
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

在`bin/rails console`会话中运行`ActiveRecord.verbose_query_logs = true`以启用冗长的查询日志，并再次运行该方法后，就会明显看到是哪一行代码生成了所有这些离散的数据库调用：

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
在每个数据库语句下面，您可以看到指向导致数据库调用的方法的特定源文件名（和行号）的箭头。这可以帮助您识别和解决由N+1查询引起的性能问题：生成多个额外查询的单个数据库查询。

在Rails 5.2之后，默认情况下在开发环境日志中启用了详细查询日志。

警告：我们建议不要在生产环境中使用此设置。它依赖于Ruby的`Kernel#caller`方法，该方法倾向于分配大量内存以生成方法调用的堆栈跟踪。请改用查询日志标签（见下文）。

### 详细排队日志

与上面的“详细查询日志”类似，允许打印排队后台作业的方法的源位置。

在开发环境中默认启用。要在其他环境中启用，请在`application.rb`或任何环境初始化器中添加：

```rb
config.active_job.verbose_enqueue_logs = true
```

与详细查询日志一样，不建议在生产环境中使用。

SQL查询注释
------------------

SQL语句可以使用包含运行时信息的标签进行注释，例如控制器或作业的名称，以将问题查询追溯到生成这些语句的应用程序区域。当您记录慢查询（例如[MySQL](https://dev.mysql.com/doc/refman/en/slow-query-log.html)、[PostgreSQL](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT)）时，这非常有用，查看当前运行的查询，或用于端到端跟踪工具。

要启用，请在`application.rb`或任何环境初始化器中添加：

```rb
config.active_record.query_log_tags_enabled = true
```

默认情况下，记录应用程序的名称、控制器的名称和操作，或作业的名称。默认格式为[SQLCommenter](https://open-telemetry.github.io/opentelemetry-sqlcommenter/)。例如：

```
Article Load (0.2ms)  SELECT "articles".* FROM "articles" /*application='Blog',controller='articles',action='index'*/

Article Update (0.3ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ? WHERE "posts"."id" = ? /*application='Blog',job='ImproveTitleJob'*/  [["title", "Improved Rails debugging guide"], ["updated_at", "2022-10-16 20:25:40.091371"], ["id", 1]]
```

[`ActiveRecord::QueryLogs`](https://api.rubyonrails.org/classes/ActiveRecord/QueryLogs.html)的行为可以修改，以包括任何有助于连接SQL查询的信息，例如请求和作业ID用于应用程序日志、帐户和租户标识等。

### 标记日志

在运行多用户、多账户应用程序时，使用一些自定义规则过滤日志通常很有用。Active Support中的`TaggedLogging`正是通过为日志行添加子域、请求ID和其他任何有助于调试此类应用程序的内容来帮助您实现这一点。

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # 记录 "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # 记录 "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # 记录 "[BCX] [Jason] Stuff"
```

### 日志对性能的影响

日志记录对您的Rails应用程序的性能总是会有一些影响，特别是在将日志记录到磁盘时。此外，还有一些细微之处：

使用`：debug`级别的性能损失比`：fatal`级别更大，因为要评估和写入日志输出（例如磁盘）的字符串数量更多。

另一个潜在的陷阱是在代码中对`Logger`进行过多的调用：

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

在上面的示例中，即使允许的输出级别不包括调试，也会有性能影响。原因是Ruby必须评估这些字符串，其中包括实例化相对较重的`String`对象和插入变量。
因此，建议将块传递给日志记录器方法，因为只有在输出级别与允许的级别相同或包含在允许的级别中时，才会对其进行评估（即延迟加载）。重写的相同代码将是：

```ruby
logger.debug { "Person attributes hash: #{@person.attributes.inspect}" }
```

块的内容，因此字符串插值，只有在启用调试时才会进行评估。这种性能节省只有在大量日志记录时才能真正注意到，但这是一种良好的实践。

INFO：本节由[Jon Cairns在Stack Overflow的回答](https://stackoverflow.com/questions/16546730/logging-in-rails-is-there-any-performance-hit/16546935#16546935)撰写，并根据[cc by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/)许可。

使用`debug` Gem进行调试
------------------------------

当您的代码表现出意外行为时，您可以尝试打印到日志或控制台以诊断问题。不幸的是，有时这种错误跟踪在找到问题的根本原因方面并不有效。当您实际需要进入正在运行的源代码时，调试器是您最好的伙伴。

如果您想了解Rails源代码但不知道从何开始，调试器也可以帮助您。只需调试应用程序的任何请求，并使用本指南学习如何从您编写的代码进入底层的Rails代码。

Rails 7在由CRuby生成的新应用程序的`Gemfile`中包含了`debug` gem。默认情况下，它在`development`和`test`环境中可用。请查阅其[文档](https://github.com/ruby/debug)以了解用法。

### 进入调试会话

默认情况下，在需要时会启动调试会话，这发生在应用程序启动时引入`debug`库。但不用担心，该会话不会干扰您的应用程序。

要进入调试会话，您可以使用`binding.break`及其别名：`binding.b`和`debugger`。以下示例将使用`debugger`：

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

一旦您的应用程序评估调试语句，它将进入调试会话：

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

您可以随时退出调试会话，并使用`continue`（或`c`）命令继续执行应用程序。或者，要退出调试会话和应用程序，请使用`quit`（或`q`）命令。

### 上下文

进入调试会话后，您可以像在Rails控制台或IRB中一样输入Ruby代码。

```rb
(rdbg) @posts    # ruby
[]
(rdbg) self
#<PostsController:0x0000000000aeb0>
(rdbg)
```

您还可以使用`p`或`pp`命令评估Ruby表达式，当变量名与调试器命令冲突时，这很有用。
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

除了直接评估之外，调试器还可以通过不同的命令帮助您收集丰富的信息，例如：

- `info`（或 `i`）- 当前帧的信息。
- `backtrace`（或 `bt`）- 回溯（附加信息）。
- `outline`（或 `o`，`ls`）- 当前作用域中可用的方法、常量、局部变量和实例变量。

#### `info` 命令

`info` 提供了从当前帧可见的局部变量和实例变量的值的概述。

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

当不带任何选项使用 `backtrace` 时，它会列出堆栈上的所有帧：

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

每个帧都带有：

- 帧标识符
- 调用位置
- 附加信息（例如块或方法参数）

这将让您对应用程序中正在发生的情况有很好的了解。但是，您可能会注意到：

- 帧太多（通常在 Rails 应用程序中超过 50 个）。
- 大多数帧来自于您使用的 Rails 或其他库。

`backtrace` 命令提供了 2 个选项，以帮助您过滤帧：

- `backtrace [num]` - 仅显示 `num` 个帧，例如 `backtrace 10`。
- `backtrace /pattern/` - 仅显示标识符或位置与模式匹配的帧，例如 `backtrace /MyModel/`。

也可以同时使用这些选项：`backtrace [num] /pattern/`。

#### `outline` 命令

`outline` 类似于 `pry` 和 `irb` 的 `ls` 命令。它会显示当前作用域中可访问的内容，包括：

- 局部变量
- 实例变量
- 类变量
- 方法及其源代码

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

### 断点

有许多方法可以在调试器中插入和触发断点。除了直接在代码中添加调试语句（例如 `debugger`）之外，还可以使用以下命令插入断点：

- `break`（或 `b`）
  - `break` - 列出所有断点
  - `break <num>` - 在当前文件的第 `num` 行设置断点
  - `break <file:num>` - 在 `file` 的第 `num` 行设置断点
  - `break <Class#method>` 或 `break <Class.method>` - 在 `Class#method` 或 `Class.method` 上设置断点
  - `break <expr>.<method>` - 在 `<expr>` 结果的 `<method>` 方法上设置断点。
- `catch <Exception>` - 设置一个断点，当引发 `Exception` 时停止
- `watch <@ivar>` - 设置一个断点，当当前对象的 `@ivar` 的结果发生变化时停止（这很慢）
要删除它们，您可以使用：

- `delete`（或 `del`）
  - `delete` - 删除所有断点
  - `delete <num>` - 删除具有id为`num`的断点

#### `break` 命令

**在指定的行号上设置断点 - 例如 `b 28`**

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
(rdbg) b 28    # 断点命令
#0  BP - 行  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (line)
```

```rb
(rdbg) c    # 继续命令
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

在给定的方法调用上设置断点 - 例如 `b @post.save`。

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
(rdbg) b @post.save    # 断点命令
#0  BP - 方法  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43

```

```rb
(rdbg) c    # 继续命令
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

当引发异常时停止 - 例如 `catch ActiveRecord::RecordInvalid`。

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
(rdbg) c    # 继续命令
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

当实例变量发生变化时停止 - 例如 `watch @_response_body`。

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
  # 还有 72 个帧（使用 `bt` 命令查看所有帧）
(rdbg) watch @_response_body    # 命令
#0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =
```

```rb
(rdbg) c    # 继续命令
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
  # 还有 82 个帧（使用 `bt` 命令查看所有帧）

通过 #0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =  停止 -> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
(rdbg)
```

#### 断点选项

除了不同类型的断点之外，您还可以指定选项以实现更高级的调试工作流程。目前，调试器支持 4 个选项：

- `do: <cmd or expr>` - 当断点触发时，执行给定的命令/表达式并继续程序：
  - `break Foo#bar do: bt` - 当调用 `Foo#bar` 时，打印堆栈帧
- `pre: <cmd or expr>` - 当断点触发时，在停止之前执行给定的命令/表达式：
  - `break Foo#bar pre: info` - 当调用 `Foo#bar` 时，在停止之前打印其周围的变量。
- `if: <expr>` - 仅当 `<expr>` 的结果为 true 时，断点才会停止：
  - `break Post#save if: params[:debug]` - 仅当 `params[:debug]` 也为 true 时，在 `Post#save` 处停止
- `path: <path_regexp>` - 仅当触发它的事件（例如方法调用）发生在给定路径时，断点才会停止：
  - `break Post#save if: app/services/a_service` - 仅当方法调用发生在与 Ruby 正则表达式 `/app\/services\/a_service/` 匹配的方法处时，在 `Post#save` 处停止。

还请注意，前三个选项：`do:`、`pre:` 和 `if:` 也适用于我们之前提到的调试语句。例如：

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
  # 还有 72 个帧（使用 `bt` 命令查看所有帧）
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
#### 程序调试工作流程

通过这些选项，您可以在一行中编写调试工作流程的脚本，如下所示：

```rb
def create
  debugger(do: "catch ActiveRecord::RecordInvalid do: bt 10")
  # ...
end
```

然后调试器将运行脚本命令并插入catch断点

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
  # and 88 frames (use `bt' command for all frames)
```

一旦触发catch断点，它将打印堆栈帧

```rb
Stop by #0  BP - Catch  "ActiveRecord::RecordInvalid"

(rdbg:catch) bt 10
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  #2    block in save! at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/transactions.rb:302
```

这种技术可以节省重复的手动输入，并使调试体验更加顺畅。

您可以从其[文档](https://github.com/ruby/debug)中找到更多的命令和配置选项。

使用`web-console` Gem进行调试
------------------------------------

Web Console有点像`debug`，但它在浏览器中运行。您可以在任何页面的视图或控制器上请求一个控制台。控制台将呈现在您的HTML内容旁边。

### 控制台

在任何控制器操作或视图中，您可以通过调用`console`方法来调用控制台。

例如，在控制器中：

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

或在视图中：

```html+erb
<% console %>

<h2>New Post</h2>
```

这将在您的视图中呈现一个控制台。您不需要关心`console`调用的位置；它不会在其调用的位置呈现，而是在您的HTML内容旁边呈现。

控制台执行纯Ruby代码：您可以定义和实例化自定义类，创建新模型并检查变量。

注意：每个请求只能呈现一个控制台。否则，`web-console`将在第二次`console`调用时引发错误。

### 检查变量

您可以调用`instance_variables`列出上下文中可用的所有实例变量。如果要列出所有局部变量，可以使用`local_variables`。

### 设置

* `config.web_console.allowed_ips`：授权的IPv4或IPv6地址和网络列表（默认值：`127.0.0.1/8, ::1`）。
* `config.web_console.whiny_requests`：当阻止控制台呈现时记录消息（默认值：`true`）。

由于`web-console`在服务器上远程评估纯Ruby代码，请勿尝试在生产环境中使用它。

调试内存泄漏
----------------------

Ruby应用程序（无论是Rails还是其他）可能会泄漏内存 - 无论是在Ruby代码中还是在C代码层面。

在本节中，您将学习如何使用诸如Valgrind之类的工具来查找和修复此类泄漏。

### Valgrind

[Valgrind](http://valgrind.org/)是一款用于检测基于C的内存泄漏和竞争条件的应用程序。

Valgrind工具可以自动检测许多内存管理和线程错误，并详细分析您的程序。例如，如果解释器中的C扩展调用`malloc()`但没有正确调用`free()`，则该内存在应用程序终止之前将不可用。
有关如何安装Valgrind并与Ruby一起使用的更多信息，请参考Evan Weaver的[Valgrind and Ruby](https://blog.evanweaver.com/2008/02/05/valgrind-and-ruby/)。

### 查找内存泄漏

在Derailed上有一篇关于检测和修复内存泄漏的优秀文章，[您可以在此处阅读](https://github.com/schneems/derailed_benchmarks#is-my-app-leaking-memory)。

调试插件
---------------------

有一些Rails插件可以帮助您查找错误并调试应用程序。以下是一些有用的调试插件列表：

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master) 添加查询来源跟踪到日志中。
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master) 提供一个邮件对象和一组默认模板，用于在Rails应用程序中发生错误时发送电子邮件通知。
* [Better Errors](https://github.com/charliesome/better_errors) 用包含更多上下文信息（如源代码和变量检查）的新错误页面替换标准的Rails错误页面。
* [RailsPanel](https://github.com/dejan/rails_panel) 用于Rails开发的Chrome扩展，可以结束对development.log的追踪。在浏览器的开发者工具面板中提供有关Rails应用程序请求的所有信息，包括数据库/渲染/总时间、参数列表、渲染视图等。
* [Pry](https://github.com/pry/pry) 一种IRB替代品和运行时开发者控制台。

参考资料
----------

* [web-console主页](https://github.com/rails/web-console)
* [debug主页](https://github.com/ruby/debug)
