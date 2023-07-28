**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: df23e2b31bd56973a30f38f5a1c29b52
Ruby on Rails 5.0 发布说明
===============================

Rails 5.0 的亮点：

* Action Cable
* Rails API
* Active Record 属性 API
* 测试运行器
* 仅使用 `rails` CLI 而不是 Rake
* Sprockets 3
* Turbolinks 5
* 需要 Ruby 2.2.2+

这些发布说明仅涵盖了主要更改。要了解各种错误修复和更改，请参阅更改日志或查看 GitHub 上主要 Rails 存储库中的[提交列表](https://github.com/rails/rails/commits/5-0-stable)。

--------------------------------------------------------------------------------

升级到 Rails 5.0
----------------------

如果您正在升级现有应用程序，建议在开始之前进行充分的测试覆盖。您还应该首先升级到 Rails 4.2（如果尚未升级），并确保您的应用程序在尝试更新到 Rails 5.0 之前仍然按预期运行。在升级时需要注意的事项列表可在[升级 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0)指南中找到。


主要功能
--------------

### Action Cable

Action Cable 是 Rails 5 中的一个新框架。它将 [WebSockets](https://en.wikipedia.org/wiki/WebSocket) 与您的 Rails 应用程序无缝集成。

Action Cable 允许您以与您的 Rails 应用程序的其余部分相同的风格和形式编写实时功能，同时保持高性能和可扩展性。它是一个全栈解决方案，提供了客户端 JavaScript 框架和服务器端 Ruby 框架。您可以访问使用 Active Record 或您选择的 ORM 编写的完整域模型。

有关更多信息，请参阅[Action Cable 概述](action_cable_overview.html)指南。

### API 应用程序

Rails 现在可以用于创建精简的仅限 API 的应用程序。这对于创建和提供类似于 [Twitter](https://dev.twitter.com) 或 [GitHub](https://developer.github.com) API 的公共面向和自定义应用程序非常有用。

您可以使用以下命令生成一个新的 api Rails 应用程序：

```bash
$ rails new my_api --api
```
这将完成三件主要的事情：

- 配置应用程序以使用比正常情况下更有限的中间件集。具体来说，默认情况下不包括任何主要用于浏览器应用程序的中间件（如cookie支持）。
- 使`ApplicationController`继承自`ActionController::API`而不是`ActionController::Base`。与中间件一样，这将省略任何主要用于浏览器应用程序的Action Controller模块提供的功能。
- 配置生成器，在生成新资源时跳过生成视图、帮助程序和资产。

该应用程序提供了一个API的基础，可以根据应用程序的需求[配置以引入功能](api_app.html)。

有关更多信息，请参见[使用Rails进行API应用程序](api_app.html)指南。

### Active Record属性API

在模型上定义具有类型的属性。如果需要，它将覆盖现有属性的类型。这允许控制在分配给模型时如何将值转换为SQL以及从SQL转换回来的方式。它还改变了传递给`ActiveRecord::Base.where`的值的行为，这样我们就可以在Active Record的大部分功能中使用我们的领域对象，而不必依赖于实现细节或猴子补丁。

您可以通过这种方式实现一些目标：

- 可以覆盖Active Record检测到的类型。
- 还可以提供默认值。
- 属性不需要由数据库列支持。

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
  attribute :price_in_cents, :integer # 自定义类型
  attribute :my_string, :string, default: "new default" # 默认值
  attribute :my_default_proc, :datetime, default: -> { Time.now } # 默认值
  attribute :field_without_db_column, :integer, array: true
end

# after
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes # => {field_without_db_column: [1, 2, 3]}
```
**创建自定义类型：**

您可以定义自己的自定义类型，只要它们响应于值类型上定义的方法。方法`deserialize`或`cast`将在您的类型对象上调用，使用来自数据库或控制器的原始输入。这在进行自定义转换时非常有用，比如货币数据。

**查询：**

当调用`ActiveRecord::Base.where`时，它将使用模型类定义的类型将值转换为SQL，调用您的类型对象上的`serialize`方法。

这使得对象能够在执行SQL查询时指定如何转换值。

**脏数据跟踪：**

属性的类型可以更改脏数据跟踪的执行方式。

请参阅其[文档](https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html)以获取详细信息。


### 测试运行器

引入了一个新的测试运行器来增强从Rails运行测试的能力。
要使用这个测试运行器，只需输入`bin/rails test`。

测试运行器的灵感来自于`RSpec`、`minitest-reporters`、`maxitest`等。
它包括以下一些显著的改进：

- 使用测试的行号运行单个测试。
- 使用测试的行号运行多个测试。
- 改进的失败消息，还可以轻松重新运行失败的测试。
- 使用`-f`选项快速失败，即在发生失败时立即停止测试，而不是等待套件完成。
- 使用`-d`选项将测试输出推迟到完整测试运行的末尾。
- 使用`-b`选项完整的异常回溯输出。
- 与minitest集成，允许使用`-s`选项设置测试种子数据，使用`-n`选项按名称运行特定的测试，使用`-v`选项获得更好的详细输出等。
- 彩色测试输出。

Railties
--------

请参阅[更改日志][railties]以获取详细的更改信息。

### 移除

*   移除了调试器支持，请使用byebug代替。`debugger`在Ruby 2.2中不受支持。
    ([提交记录](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))
*   移除了已弃用的 `test:all` 和 `test:all:db` 任务。
    ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   移除了已弃用的 `Rails::Rack::LogTailer`。
    ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   移除了已弃用的 `RAILS_CACHE` 常量。
    ([commit](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   移除了已弃用的 `serve_static_assets` 配置。
    ([commit](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   移除了文档任务 `doc:app`、`doc:rails` 和 `doc:guides`。
    ([commit](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   从默认堆栈中移除了 `Rack::ContentLength` 中间件。
    ([Commit](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### 弃用

*   弃用了 `config.static_cache_control`，使用 `config.public_file_server.headers` 替代。
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   弃用了 `config.serve_static_files`，使用 `config.public_file_server.enabled` 替代。
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*   弃用了 `rails` 任务命名空间中的任务，使用 `app` 命名空间替代。
    （例如，`rails:update` 和 `rails:template` 任务被重命名为 `app:update` 和 `app:template`。）
    ([Pull Request](https://github.com/rails/rails/pull/23439))

### 显著变化

*   添加了 Rails 测试运行器 `bin/rails test`。
    ([Pull Request](https://github.com/rails/rails/pull/19216))

*   新生成的应用程序和插件在 Markdown 中获取一个 `README.md` 文件。
    ([commit](https://github.com/rails/rails/commit/89a12c931b1f00b90e74afffcdc2fc21f14ca663),
     [Pull Request](https://github.com/rails/rails/pull/22068))

*   添加了 `bin/rails restart` 任务，通过触发 `tmp/restart.txt` 来重新启动 Rails 应用程序。
    ([Pull Request](https://github.com/rails/rails/pull/18965))

*   添加了 `bin/rails initializers` 任务，按照 Rails 调用它们的顺序打印出所有定义的初始化器。
    ([Pull Request](https://github.com/rails/rails/pull/19323))

*   添加了 `bin/rails dev:cache`，用于在开发模式下启用或禁用缓存。
    ([Pull Request](https://github.com/rails/rails/pull/20961))

*   添加了 `bin/update` 脚本，用于自动更新开发环境。
    ([Pull Request](https://github.com/rails/rails/pull/20972))

*   通过 `bin/rails` 代理 Rake 任务。
    ([Pull Request](https://github.com/rails/rails/pull/22457),
     [Pull Request](https://github.com/rails/rails/pull/22288))

*   在 Linux 和 macOS 上启用了新应用程序的事件驱动文件系统监视器。可以通过在生成器中传递 `--skip-listen` 来选择不使用该功能。
    ([commit](https://github.com/rails/rails/commit/de6ad5665d2679944a9ee9407826ba88395a1003),
    [commit](https://github.com/rails/rails/commit/94dbc48887bf39c241ee2ce1741ee680d773f202))

*   生成的应用程序可以选择使用环境变量 `RAILS_LOG_TO_STDOUT` 在生产环境中将日志记录到 STDOUT。
    ([Pull Request](https://github.com/rails/rails/pull/23734))

*   为新应用程序启用了带有 IncludeSubdomains 头的 HSTS。
    ([Pull Request](https://github.com/rails/rails/pull/23852))

*   应用程序生成器写入了一个新文件 `config/spring.rb`，告诉 Spring 监视其他常见文件。
    ([commit](https://github.com/rails/rails/commit/b04d07337fd7bc17e88500e9d6bcd361885a45f8))

*   在生成新应用程序时添加了 `--skip-action-mailer` 选项，以跳过 Action Mailer。
    ([Pull Request](https://github.com/rails/rails/pull/18288))

*   移除了 `tmp/sessions` 目录及其关联的清理 rake 任务。
    ([Pull Request](https://github.com/rails/rails/pull/18314))

*   将由脚手架生成的 `_form.html.erb` 更改为使用局部变量。
    ([Pull Request](https://github.com/rails/rails/pull/13434))
*   在生产环境中禁用类的自动加载。
    ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

Action Pack
-----------

请参阅[更新日志][action-pack]以获取详细的更改信息。

### 移除

*   移除了`ActionDispatch::Request::Utils.deep_munge`。
    ([commit](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   移除了`ActionController::HideActions`。
    ([Pull Request](https://github.com/rails/rails/pull/18371))

*   移除了`respond_to`和`respond_with`占位方法，此功能已提取到
    [responders](https://github.com/plataformatec/responders) gem中。
    ([commit](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   移除了已弃用的断言文件。
    ([commit](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   移除了在URL助手中使用字符串键的已弃用用法。
    ([commit](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   移除了在`*_path`助手中已弃用的`only_path`选项。
    ([commit](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))

*   移除了已弃用的`NamedRouteCollection#helpers`。
    ([commit](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*   移除了使用不包含`#`的`to`选项定义路由的已弃用支持。
    ([commit](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   移除了已弃用的`ActionDispatch::Response#to_ary`。
    ([commit](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   移除了已弃用的`ActionDispatch::Request#deep_munge`。
    ([commit](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   移除了已弃用的
    `ActionDispatch::Http::Parameters#symbolized_path_parameters`。
    ([commit](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   移除了控制器测试中已弃用的`use_route`选项。
    ([commit](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   移除了`assigns`和`assert_template`。这两个方法已被提取到
    [rails-controller-testing](https://github.com/rails/rails-controller-testing)
    gem中。
    ([Pull Request](https://github.com/rails/rails/pull/20138))

### 弃用

*   弃用了所有`*_filter`回调，改用`*_action`回调。
    ([Pull Request](https://github.com/rails/rails/pull/18410))

*   弃用了`*_via_redirect`集成测试方法。在请求调用后手动使用`follow_redirect!`
    来实现相同的行为。
    ([Pull Request](https://github.com/rails/rails/pull/18693))

*   弃用了`AbstractController#skip_action_callback`，改用单独的
    skip_callback 方法。
    ([Pull Request](https://github.com/rails/rails/pull/19060))

*   弃用了`render`方法的`:nothing`选项。
    ([Pull Request](https://github.com/rails/rails/pull/20336))

*   弃用了将第一个参数作为`Hash`和默认状态码传递给`head`方法。
    ([Pull Request](https://github.com/rails/rails/pull/20407))

*   弃用了使用字符串或符号作为中间件类名的方式。改用类名。
    ([commit](https://github.com/rails/rails/commit/83b767ce))

*   弃用了通过常量访问MIME类型（例如`Mime::HTML`）。改用使用符号的下标操作符（例如`Mime[:html]`）。
    ([Pull Request](https://github.com/rails/rails/pull/21869))

*   弃用了`redirect_to :back`，改用接受必需的`fallback_location`参数的`redirect_back`，从而消除了`RedirectBackError`的可能性。
    ([Pull Request](https://github.com/rails/rails/pull/22506))

*   `ActionDispatch::IntegrationTest`和`ActionController::TestCase`弃用了位置参数，改用关键字参数。
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   弃用了`controller`和`action`路径参数。
    ([Pull Request](https://github.com/rails/rails/pull/23980))

*   弃用了控制器实例上的env方法。
    ([commit](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   `ActionDispatch::ParamsParser`已弃用并从中间件堆栈中移除。要配置参数解析器，请使用
    `ActionDispatch::Request.parameter_parsers=`。
    ([commit](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1),
    [commit](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))
### 重要更改

*   添加了`ActionController::Renderer`，用于在控制器操作之外渲染任意模板。
    ([拉取请求](https://github.com/rails/rails/pull/18546))

*   在`ActionController::TestCase`和`ActionDispatch::Integration`的HTTP请求方法中迁移到关键字参数语法。
    ([拉取请求](https://github.com/rails/rails/pull/18323))

*   在Action Controller中添加了`http_cache_forever`，以便我们可以缓存永不过期的响应。
    ([拉取请求](https://github.com/rails/rails/pull/18394))

*   提供更友好的请求变体访问方式。
    ([拉取请求](https://github.com/rails/rails/pull/18939))

*   对于没有对应模板的操作，渲染`head :no_content`而不是引发错误。
    ([拉取请求](https://github.com/rails/rails/pull/19377))

*   添加了在控制器中覆盖默认表单构建器的功能。
    ([拉取请求](https://github.com/rails/rails/pull/19736))

*   添加了对API-only应用程序的支持。
    `ActionController::API`被添加为这种类型应用程序的`ActionController::Base`替代品。
    ([拉取请求](https://github.com/rails/rails/pull/19832))

*   `ActionController::Parameters`不再继承自`HashWithIndifferentAccess`。
    ([拉取请求](https://github.com/rails/rails/pull/20868))

*   通过使`config.force_ssl`和`config.ssl_options`更安全且更容易禁用，更容易选择启用它们。
    ([拉取请求](https://github.com/rails/rails/pull/21520))

*   向`ActionDispatch::Static`添加了返回任意头信息的能力。
    ([拉取请求](https://github.com/rails/rails/pull/19135))

*   将`protect_from_forgery`的默认prepend更改为`false`。
    ([提交](https://github.com/rails/rails/commit/39794037817703575c35a75f1961b01b83791191))

*   `ActionController::TestCase`将在Rails 5.1中移至自己的gem。请改用`ActionDispatch::IntegrationTest`。
    ([提交](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d))

*   Rails默认生成弱ETags。
    ([拉取请求](https://github.com/rails/rails/pull/17573))

*   没有显式`render`调用且没有对应模板的控制器操作将隐式渲染`head :no_content`而不是引发错误。
    (拉取请求 [1](https://github.com/rails/rails/pull/19377),
    [2](https://github.com/rails/rails/pull/23827))

*   添加了每个表单CSRF令牌的选项。
    ([拉取请求](https://github.com/rails/rails/pull/22275))

*   在集成测试中添加了请求编码和响应解析。
    ([拉取请求](https://github.com/rails/rails/pull/21671))

*   添加了`ActionController#helpers`以在控制器级别访问视图上下文。
    ([拉取请求](https://github.com/rails/rails/pull/24866))

*   丢弃的flash消息在存储到会话之前被删除。
    ([拉取请求](https://github.com/rails/rails/pull/18721))

*   添加了对将记录集传递给`fresh_when`和`stale?`的支持。
    ([拉取请求](https://github.com/rails/rails/pull/18374))

*   `ActionController::Live`成为了`ActiveSupport::Concern`。这意味着它不能只被包含在其他模块中，而不扩展它们为`ActiveSupport::Concern`或`ActionController::Live`在生产环境中将不起作用。一些人可能还使用另一个模块来包含一些特殊的`Warden`/`Devise`身份验证失败处理代码，因为中间件无法捕获由生成的线程抛出的`:warden`，而在使用`ActionController::Live`时正是这种情况。
    ([在此问题中了解更多详情](https://github.com/rails/rails/issues/25581))
*   引入`Response#strong_etag=`和`#weak_etag=`以及`fresh_when`和`stale?`的类似选项。
    ([拉取请求](https://github.com/rails/rails/pull/24387))

Action View
-------------

详细更改请参阅[更新日志][action-view]。

### 删除

*   删除了已弃用的`AbstractController::Base::parent_prefixes`。
    ([提交](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

*   删除了`ActionView::Helpers::RecordTagHelper`，此功能已提取到
    [record_tag_helper](https://github.com/rails/record_tag_helper) gem中。
    ([拉取请求](https://github.com/rails/rails/pull/18411))

*   删除了`translate`助手的`:rescue_format`选项，因为它不再受I18n支持。
    ([拉取请求](https://github.com/rails/rails/pull/20019))

### 显著更改

*   将默认模板处理程序从`ERB`更改为`Raw`。
    ([提交](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

*   集合渲染可以缓存并一次获取多个局部模板。
    ([拉取请求](https://github.com/rails/rails/pull/18948),
    [提交](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

*   添加了通配符匹配到显式依赖项。
    ([拉取请求](https://github.com/rails/rails/pull/20904))

*   将`disable_with`设置为提交标签的默认行为。在提交时禁用按钮以防止重复提交。
    ([拉取请求](https://github.com/rails/rails/pull/21135))

*   局部模板名称不再必须是有效的Ruby标识符。
    ([提交](https://github.com/rails/rails/commit/da9038e))

*   `datetime_tag`助手现在生成带有类型为`datetime-local`的输入标签。
    ([拉取请求](https://github.com/rails/rails/pull/25469))

*   在使用`render partial:`助手进行渲染时允许使用块。
    ([拉取请求](https://github.com/rails/rails/pull/17974))

Action Mailer
-------------

详细更改请参阅[更新日志][action-mailer]。

### 删除

*   删除了电子邮件视图中已弃用的`*_path`助手。
    ([提交](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

*   删除了已弃用的`deliver`和`deliver!`方法。
    ([提交](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### 显著更改

*   模板查找现在遵循默认语言环境和I18n回退。
    ([提交](https://github.com/rails/rails/commit/ecb1981b))

*   通过生成器创建的邮件程序现在添加了`_mailer`后缀，遵循控制器和作业中使用的相同命名约定。
    ([拉取请求](https://github.com/rails/rails/pull/18074))

*   添加了`assert_enqueued_emails`和`assert_no_enqueued_emails`。
    ([拉取请求](https://github.com/rails/rails/pull/18403))

*   添加了`config.action_mailer.deliver_later_queue_name`配置，用于设置邮件程序队列名称。
    ([拉取请求](https://github.com/rails/rails/pull/18587))

*   在Action Mailer视图中添加了对片段缓存的支持。
    添加了新的配置选项`config.action_mailer.perform_caching`来确定模板是否应该执行缓存。
    ([拉取请求](https://github.com/rails/rails/pull/22825))


Active Record
-------------

详细更改请参阅[更新日志][active-record]。

### 删除

*   删除了允许传递嵌套数组作为查询值的已弃用行为。
    ([拉取请求](https://github.com/rails/rails/pull/17919))

*   删除了已弃用的`ActiveRecord::Tasks::DatabaseTasks#load_schema`。此方法已被`ActiveRecord::Tasks::DatabaseTasks#load_schema_for`替代。
    ([提交](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))
*   移除了已弃用的`serialized_attributes`。
    ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*   移除了已弃用的`has_many :through`上的自动计数缓存。
    ([commit](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

*   移除了已弃用的`sanitize_sql_hash_for_conditions`。
    ([commit](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

*   移除了已弃用的`Reflection#source_macro`。
    ([commit](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

*   移除了已弃用的`symbolized_base_class`和`symbolized_sti_name`。
    ([commit](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

*   移除了已弃用的`ActiveRecord::Base.disable_implicit_join_references=`。
    ([commit](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

*   移除了通过字符串访问器访问连接规范的已弃用支持。
    ([commit](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

*   移除了预加载实例相关联的已弃用支持。
    ([commit](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

*   移除了对具有排他性下界的PostgreSQL范围的已弃用支持。
    ([commit](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

*   移除了使用缓存的Arel修改关系时的已弃用警告。
    现在会引发`ImmutableRelation`错误。
    ([commit](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

*   从核心中移除了`ActiveRecord::Serialization::XmlSerializer`。此功能已提取到
    [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml)
    gem中。 ([Pull Request](https://github.com/rails/rails/pull/21161))

*   从核心中移除了对旧版`mysql`数据库适配器的支持。大多数用户应该能够使用`mysql2`。当我们找到维护者时，它将被转换为一个单独的gem。
    ([Pull Request 1](https://github.com/rails/rails/pull/22642),
    [Pull Request 2](https://github.com/rails/rails/pull/22715))

*   移除了对`protected_attributes` gem的支持。
    ([commit](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

*   移除了对低于9.1版本的PostgreSQL的支持。
    ([Pull Request](https://github.com/rails/rails/pull/23434))

*   移除了对`activerecord-deprecated_finders` gem的支持。
    ([commit](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

*   移除了`ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES`常量。
    ([commit](https://github.com/rails/rails/commit/a502703c3d2151d4d3b421b29fefdac5ad05df61))

### 弃用

*   弃用在查询中将类作为值传递。用户应该传递字符串而不是类。
    ([Pull Request](https://github.com/rails/rails/pull/17916))

*   弃用将`false`作为终止Active Record回调链的方式。推荐的方式是使用`throw(:abort)`。
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   弃用`ActiveRecord::Base.errors_in_transactional_callbacks=`。
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

*   弃用`Relation#uniq`，使用`Relation#distinct`代替。
    ([commit](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

*   弃用PostgreSQL的`:point`类型，改用返回`Point`对象而不是`Array`的新类型。
    ([Pull Request](https://github.com/rails/rails/pull/20448))

*   弃用通过传递真值参数给关联方法来强制重新加载关联。
    ([Pull Request](https://github.com/rails/rails/pull/20888))

*   弃用关联`restrict_dependent_destroy`错误的键，改用新的键名。
    ([Pull Request](https://github.com/rails/rails/pull/20668))

*   同步`#tables`的行为。
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   弃用`SchemaCache#tables`，`SchemaCache#table_exists?`和`SchemaCache#clear_table_cache!`，改用它们的新数据源对应方法。
    ([Pull Request](https://github.com/rails/rails/pull/21715))
* 在SQLite3和MySQL适配器上弃用了`connection.tables`。
    ([Pull Request](https://github.com/rails/rails/pull/21601))

* 弃用了向`#tables`传递参数的功能 - 一些适配器（mysql2，sqlite3）的`#tables`方法会返回表和视图，而其他适配器（postgresql）只返回表。为了使它们的行为一致，`#tables`将来只返回表。
    ([Pull Request](https://github.com/rails/rails/pull/21601))

* 弃用了`table_exists?`方法 - `#table_exists?`方法会检查表和视图。为了使其与`#tables`的行为一致，`#table_exists?`将来只检查表。
    ([Pull Request](https://github.com/rails/rails/pull/21601))

* 弃用了向`find_nth`发送`offset`参数的功能。请改用关系上的`offset`方法。
    ([Pull Request](https://github.com/rails/rails/pull/22053))

* 在`DatabaseStatements`中弃用了`{insert|update|delete}_sql`。请改用相应的公共方法`{insert|update|delete}`。
    ([Pull Request](https://github.com/rails/rails/pull/23086))

* 弃用了`use_transactional_fixtures`，建议使用更明确的`use_transactional_tests`。
    ([Pull Request](https://github.com/rails/rails/pull/19282))

* 弃用了向`ActiveRecord::Connection#quote`传递列的功能。
    ([commit](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

* 在`find_in_batches`中添加了一个`end`选项，用于补充`start`参数，指定批处理的结束位置。
    ([Pull Request](https://github.com/rails/rails/pull/12257))


### 显著变化

* 在创建表时，为`references`添加了一个`foreign_key`选项。
    ([commit](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

* 新增了属性API。
    ([commit](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

* 在`enum`定义中添加了`:_prefix`/`:_suffix`选项。
    ([Pull Request](https://github.com/rails/rails/pull/19813),
     [Pull Request](https://github.com/rails/rails/pull/20999))

* 在`ActiveRecord::Relation`中添加了`#cache_key`方法。
    ([Pull Request](https://github.com/rails/rails/pull/20884))

* 将`timestamps`的默认`null`值更改为`false`。
    ([commit](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

* 添加了`ActiveRecord::SecureToken`，用于封装使用`SecureRandom`为模型中的属性生成唯一令牌。
    ([Pull Request](https://github.com/rails/rails/pull/18217))

* 为`drop_table`添加了`if_exists`选项。
    ([Pull Request](https://github.com/rails/rails/pull/18597))

* 添加了`ActiveRecord::Base#accessed_fields`，用于快速发现从模型中读取了哪些字段，以便只选择所需的数据。
    ([commit](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

* 在`ActiveRecord::Relation`上添加了`#or`方法，允许使用OR运算符组合WHERE或HAVING子句。
    ([commit](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

* 添加了`ActiveRecord::Base.suppress`，用于在给定的块中阻止接收器被保存。
    ([Pull Request](https://github.com/rails/rails/pull/18910))

* `belongs_to`现在默认情况下会触发验证错误，如果关联不存在。可以通过`optional: true`在每个关联上关闭此功能。同时弃用`required`选项，建议使用`optional`选项替代`belongs_to`。
    ([Pull Request](https://github.com/rails/rails/pull/18937))
*   添加了`config.active_record.dump_schemas`配置项，用于配置`db:structure:dump`的行为。
    ([Pull Request](https://github.com/rails/rails/pull/19347))

*   添加了`config.active_record.warn_on_records_fetched_greater_than`选项。
    ([Pull Request](https://github.com/rails/rails/pull/18846))

*   在MySQL中添加了对原生JSON数据类型的支持。
    ([Pull Request](https://github.com/rails/rails/pull/21110))

*   在PostgreSQL中添加了并发删除索引的支持。
    ([Pull Request](https://github.com/rails/rails/pull/21317))

*   在连接适配器上添加了`#views`和`#view_exists?`方法。
    ([Pull Request](https://github.com/rails/rails/pull/21609))

*   添加了`ActiveRecord::Base.ignored_columns`，用于使某些列在Active Record中不可见。
    ([Pull Request](https://github.com/rails/rails/pull/21720))

*   添加了`connection.data_sources`和`connection.data_source_exists?`方法。
    这些方法确定可以用于支持Active Record模型的关系（通常是表和视图）。
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   允许夹具文件在YAML文件本身中设置模型类。
    ([Pull Request](https://github.com/rails/rails/pull/20574))

*   添加了在生成数据库迁移时默认使用`uuid`作为主键的能力。
    ([Pull Request](https://github.com/rails/rails/pull/21762))

*   添加了`ActiveRecord::Relation#left_joins`和`ActiveRecord::Relation#left_outer_joins`。
    ([Pull Request](https://github.com/rails/rails/pull/12071))

*   添加了`after_{create,update,delete}_commit`回调。
    ([Pull Request](https://github.com/rails/rails/pull/22516))

*   对迁移类呈现的API进行了版本化，以便我们可以更改参数默认值而不会破坏现有的迁移，
    或者迫使它们通过废弃周期进行重写。
    ([Pull Request](https://github.com/rails/rails/pull/21538))

*   `ApplicationRecord`是所有应用程序模型的新超类，类似于应用程序控制器继承`ApplicationController`而不是`ActionController::Base`。
    这为应用程序提供了一个单一的位置来配置应用程序范围的模型行为。
    ([Pull Request](https://github.com/rails/rails/pull/22567))

*   添加了ActiveRecord的`#second_to_last`和`#third_to_last`方法。
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   在PostgreSQL和MySQL中添加了对数据库对象（表、列、索引）的注释支持，这些注释存储在数据库元数据中。
    ([Pull Request](https://github.com/rails/rails/pull/22911))

*   在`mysql2`适配器中添加了对预编译语句的支持，适用于mysql2 0.4.4+，之前只支持已弃用的`mysql`传统适配器。
    要启用此功能，请在`config/database.yml`中设置`prepared_statements: true`。
    ([Pull Request](https://github.com/rails/rails/pull/23461))

*   添加了在关系对象上调用`ActionRecord::Relation#update`的能力，这将在关系中的所有对象上运行验证和回调。
    ([Pull Request](https://github.com/rails/rails/pull/11898))

*   在`save`方法中添加了`：touch`选项，以便可以保存记录而不更新时间戳。
    ([Pull Request](https://github.com/rails/rails/pull/18225))

*   为PostgreSQL添加了表达式索引和操作符类支持。
    ([commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))
*   添加了 `:index_errors` 选项，用于在嵌套属性的错误中添加索引。
    ([Pull Request](https://github.com/rails/rails/pull/19686))

*   添加了双向销毁依赖的支持。
    ([Pull Request](https://github.com/rails/rails/pull/18548))

*   在事务测试中添加了对 `after_commit` 回调的支持。
    ([Pull Request](https://github.com/rails/rails/pull/18458))

*   添加了 `foreign_key_exists?` 方法，用于查看表上是否存在外键。
    ([Pull Request](https://github.com/rails/rails/pull/18662))

*   在 `touch` 方法中添加了 `:time` 选项，用于触发具有不同时间的记录
    ([Pull Request](https://github.com/rails/rails/pull/18956))

*   更改事务回调以不再吞噬错误。
    在此更改之前，事务回调中引发的任何错误都会被捕获并打印在日志中，除非您使用
    （新弃用的）`raise_in_transactional_callbacks = true` 选项。

    现在，这些错误不再被捕获，而是冒泡上升，与其他回调的行为相匹配。
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

Active Model
------------

详细更改请参阅[更新日志][active-model]。

### 删除

*   删除了已弃用的 `ActiveModel::Dirty#reset_#{attribute}` 和
    `ActiveModel::Dirty#reset_changes`。
    ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

*   删除了 XML 序列化功能。此功能已提取到
    [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) gem 中。
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   删除了 `ActionController::ModelNaming` 模块。
    ([Pull Request](https://github.com/rails/rails/pull/18194))

### 弃用

*   弃用了将 `false` 作为阻止 Active Model 和 `ActiveModel::Validations` 回调链的方式。推荐的方式是使用 `throw(:abort)`。
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   弃用了具有不一致行为的 `ActiveModel::Errors#get`、`ActiveModel::Errors#set` 和 `ActiveModel::Errors#[]=` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/18634))

*   弃用了 `validates_length_of` 的 `:tokenizer` 选项，改用纯 Ruby。
    ([Pull Request](https://github.com/rails/rails/pull/19585))

*   弃用了 `ActiveModel::Errors#add_on_empty` 和 `ActiveModel::Errors#add_on_blank`，没有替代方法。
    ([Pull Request](https://github.com/rails/rails/pull/18996))

### 重要更改

*   添加了 `ActiveModel::Errors#details` 方法，用于确定验证器失败的原因。
    ([Pull Request](https://github.com/rails/rails/pull/18322))

*   将 `ActiveRecord::AttributeAssignment` 提取到 `ActiveModel::AttributeAssignment` 中，允许将其作为可包含模块用于任何对象。
    ([Pull Request](https://github.com/rails/rails/pull/10776))

*   添加了 `ActiveModel::Dirty#[attr_name]_previously_changed?` 和 `ActiveModel::Dirty#[attr_name]_previous_change`，以改进在模型保存后访问记录的更改。
    ([Pull Request](https://github.com/rails/rails/pull/19847))

*   在 `valid?` 和 `invalid?` 中同时验证多个上下文。
    ([Pull Request](https://github.com/rails/rails/pull/21069))

*   更改 `validates_acceptance_of`，除了 `1` 之外，还接受 `true` 作为默认值。
    ([Pull Request](https://github.com/rails/rails/pull/18439))
Active Job
-----------

请参考[Changelog][active-job]以获取详细的更改信息。

### 主要更改

*   `ActiveJob::Base.deserialize` 委托给作业类。这允许作业在序列化时附加任意元数据，并在执行时读取回来。
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*   添加能够在每个作业上配置队列适配器的能力，而不会相互影响。
    ([Pull Request](https://github.com/rails/rails/pull/16992))

*   生成的作业现在默认继承自 `app/jobs/application_job.rb`。
    ([Pull Request](https://github.com/rails/rails/pull/19034))

*   允许 `DelayedJob`、`Sidekiq`、`qu`、`que` 和 `queue_classic` 将作业 ID 作为 `provider_job_id` 返回给 `ActiveJob::Base`。
    ([Pull Request](https://github.com/rails/rails/pull/20064),
     [Pull Request](https://github.com/rails/rails/pull/20056),
     [commit](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

*   实现一个简单的 `AsyncJob` 处理器和相关的 `AsyncAdapter`，将作业排队到 `concurrent-ruby` 线程池。
    ([Pull Request](https://github.com/rails/rails/pull/21257))

*   将默认适配器从内联更改为异步。这是一个更好的默认值，因为测试将不会错误地依赖于同步发生的行为。
    ([commit](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))

Active Support
--------------

请参考[Changelog][active-support]以获取详细的更改信息。

### 移除

*   移除了已弃用的 `ActiveSupport::JSON::Encoding::CircularReferenceError`。
    ([commit](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

*   移除了已弃用的方法 `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=`
    和 `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string`。
    ([commit](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

*   移除了已弃用的 `ActiveSupport::SafeBuffer#prepend`。
    ([commit](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

*   移除了 `Kernel` 中的已弃用方法。使用 `silence_stderr`、`silence_stream`、`capture` 和 `quietly`。
    ([commit](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

*   移除了已弃用的 `active_support/core_ext/big_decimal/yaml_conversions` 文件。
    ([commit](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

*   移除了已弃用的方法 `ActiveSupport::Cache::Store.instrument` 和
    `ActiveSupport::Cache::Store.instrument=`。
    ([commit](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

*   移除了已弃用的 `Class#superclass_delegating_accessor`。
    使用 `Class#class_attribute` 替代。
    ([Pull Request](https://github.com/rails/rails/pull/16938))

*   移除了已弃用的 `ThreadSafe::Cache`。使用 `Concurrent::Map` 替代。
    ([Pull Request](https://github.com/rails/rails/pull/21679))

*   移除了 `Object#itself`，因为它在 Ruby 2.2 中已实现。
    ([Pull Request](https://github.com/rails/rails/pull/18244))

### 弃用

*   弃用 `MissingSourceFile`，改用 `LoadError`。
    ([commit](https://github.com/rails/rails/commit/734d97d2))

*   弃用 `alias_method_chain`，改用 Ruby 2.0 中引入的 `Module#prepend`。
    ([Pull Request](https://github.com/rails/rails/pull/19434))

*   弃用 `ActiveSupport::Concurrency::Latch`，改用 concurrent-ruby 的 `Concurrent::CountDownLatch`。
    ([Pull Request](https://github.com/rails/rails/pull/20866))

*   弃用 `number_to_human_size` 的 `:prefix` 选项，没有替代方案。
    ([Pull Request](https://github.com/rails/rails/pull/21191))

*   弃用 `Module#qualified_const_`，改用内置的 `Module#const_` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*   弃用传递字符串来定义回调。
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*   弃用 `ActiveSupport::Cache::Store#namespaced_key`、
    `ActiveSupport::Cache::MemCachedStore#escape_key` 和
    `ActiveSupport::Cache::FileStore#key_file_path`。
    使用 `normalize_key` 替代。
    ([Pull Request](https://github.com/rails/rails/pull/22215),
     [commit](https://github.com/rails/rails/commit/a8f773b0))
*   弃用`ActiveSupport::Cache::LocaleCache#set_cache_value`，改用`write_cache_value`。（[Pull Request](https://github.com/rails/rails/pull/22215)）

*   弃用向`assert_nothing_raised`传递参数的方式。（[Pull Request](https://github.com/rails/rails/pull/23789)）

*   弃用`Module.local_constants`，改用`Module.constants(false)`。（[Pull Request](https://github.com/rails/rails/pull/23936)）


### 重要变更

*   在`ActiveSupport::MessageVerifier`中添加了`#verified`和`#valid_message?`方法。（[Pull Request](https://github.com/rails/rails/pull/17727)）

*   改变了回调链的中止方式。现在，中止回调链的首选方法是显式地使用`throw(:abort)`。（[Pull Request](https://github.com/rails/rails/pull/17227)）

*   新增配置选项`config.active_support.halt_callback_chains_on_return_false`，用于指定是否可以通过在“before”回调中返回`false`来中止ActiveRecord、ActiveModel和ActiveModel::Validations的回调链。（[Pull Request](https://github.com/rails/rails/pull/17227)）

*   将默认的测试顺序从`:sorted`改为`:random`。（[commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d)）

*   在`Date`、`Time`和`DateTime`中添加了`#on_weekend?`、`#on_weekday?`、`#next_weekday`和`#prev_weekday`方法。（[Pull Request](https://github.com/rails/rails/pull/18335)、[Pull Request](https://github.com/rails/rails/pull/23687)）

*   在`Date`、`Time`和`DateTime`的`#next_week`和`#prev_week`中添加了`same_time`选项。（[Pull Request](https://github.com/rails/rails/pull/18335)）

*   在`Date`、`Time`和`DateTime`中添加了`#prev_day`和`#next_day`方法，作为`#yesterday`和`#tomorrow`的对应方法。（[Pull Request](https://github.com/rails/rails/pull/18335)）

*   添加了`SecureRandom.base58`用于生成随机的base58字符串。（[commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b)）

*   在`ActiveSupport::TestCase`中添加了`file_fixture`。它提供了一种在测试用例中访问示例文件的简单机制。（[Pull Request](https://github.com/rails/rails/pull/18658)）

*   在`Enumerable`和`Array`上添加了`#without`方法，用于返回不包含指定元素的可枚举对象的副本。（[Pull Request](https://github.com/rails/rails/pull/19157)）

*   添加了`ActiveSupport::ArrayInquirer`和`Array#inquiry`。（[Pull Request](https://github.com/rails/rails/pull/18939)）

*   添加了`ActiveSupport::TimeZone#strptime`，允许按照给定时区解析时间。（[commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6)）

*   添加了`Integer#positive?`和`Integer#negative?`查询方法，类似于`Integer#zero?`。（[commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa)）

*   在`ActiveSupport::OrderedOptions`的get方法中添加了一个感叹号版本，如果值为`.blank?`，则会引发`KeyError`异常。（[Pull Request](https://github.com/rails/rails/pull/20208)）

*   添加了`Time.days_in_year`，用于返回给定年份的天数，如果没有提供参数，则返回当前年份。（[commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa)）

*   添加了一个事件驱动的文件监视器，用于异步检测应用程序源代码、路由、本地化等的更改。（[Pull Request](https://github.com/rails/rails/pull/22254)）

*   添加了一组方法`thread_m/cattr_accessor/reader/writer`，用于声明每个线程独立的类和模块变量。（[Pull Request](https://github.com/rails/rails/pull/22630)）
*   添加了`Array#second_to_last`和`Array#third_to_last`方法。
    ([拉取请求](https://github.com/rails/rails/pull/23583))

*   发布了`ActiveSupport::Executor`和`ActiveSupport::Reloader`的API，允许组件和库管理和参与应用程序代码的执行和应用程序重新加载过程。
    ([拉取请求](https://github.com/rails/rails/pull/23807))

*   `ActiveSupport::Duration`现在支持ISO8601格式化和解析。
    ([拉取请求](https://github.com/rails/rails/pull/16917))

*   当启用`parse_json_times`时，`ActiveSupport::JSON.decode`现在支持解析ISO8601本地时间。
    ([拉取请求](https://github.com/rails/rails/pull/23011))

*   `ActiveSupport::JSON.decode`现在返回日期字符串的`Date`对象。
    ([拉取请求](https://github.com/rails/rails/pull/23011))

*   添加了`TaggedLogging`的功能，允许多次实例化日志记录器，以便它们不共享标签。
    ([拉取请求](https://github.com/rails/rails/pull/9065))

致谢
-------

请参阅[Rails的完整贡献者列表](https://contributors.rubyonrails.org/)，感谢所有花费了许多时间使Rails成为稳定和强大的框架的人们。向他们致敬。

[railties]:       https://github.com/rails/rails/blob/5-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-0-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
