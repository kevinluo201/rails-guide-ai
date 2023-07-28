**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4d8311a1435138a81e26a7e8f537dbde
Ruby on Rails 4.2 发布说明
===============================

Rails 4.2 的亮点：

* Active Job
* 异步邮件
* Adequate Record
* Web Console
* 外键支持

这些发布说明仅涵盖了主要更改。要了解其他功能、错误修复和更改，请参考变更日志或查看 GitHub 上主要 Rails 仓库的[提交列表](https://github.com/rails/rails/commits/4-2-stable)。

--------------------------------------------------------------------------------

升级到 Rails 4.2
----------------------

如果您要升级现有应用程序，在进行升级之前最好有良好的测试覆盖率。您还应该先升级到 Rails 4.1（如果尚未升级），并确保您的应用程序在升级到 Rails 4.2 之前仍然按预期运行。在升级时需要注意的事项列表可在[升级 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2)指南中找到。

主要功能
--------------

### Active Job

Active Job 是 Rails 4.2 中的一个新框架。它是在诸如 [Resque](https://github.com/resque/resque)、[Delayed Job](https://github.com/collectiveidea/delayed_job)、[Sidekiq](https://github.com/mperham/sidekiq) 等排队系统之上的一个通用接口。

使用 Active Job API 编写的作业可以在任何受支持的队列上运行，这要归功于它们各自的适配器。Active Job 预先配置了一个内联运行器，可以立即执行作业。

作业通常需要将 Active Record 对象作为参数。Active Job 通过使用 URI（统一资源标识符）而不是序列化对象本身来传递对象引用。新的 [Global ID](https://github.com/rails/globalid) 库构建 URI 并查找它们引用的对象。通过在内部使用 Global ID，将 Active Record 对象作为作业参数传递非常简单。

例如，如果 `trashable` 是一个 Active Record 对象，那么下面的作业可以正常运行，而无需进行序列化：

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

有关更多信息，请参阅[Active Job 基础知识](active_job_basics.html)指南。

### 异步邮件

在 Active Job 的基础上，Action Mailer 现在提供了一个 `deliver_later` 方法，通过队列发送邮件，这样就不会阻塞控制器或模型（如果队列是异步的话，默认的内联队列会阻塞）。

仍然可以使用 `deliver_now` 立即发送邮件。

### Adequate Record

Adequate Record 是 Active Record 中的一组性能改进，可以使常见的 `find` 和 `find_by` 调用以及一些关联查询速度提高最多 2 倍。

它通过将常见的 SQL 查询缓存为预编译语句并在类似的调用上重用它们，跳过大部分查询生成工作。有关更多详细信息，请参阅 [Aaron Patterson 的博客文章](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html)。

Active Record 将自动在支持的操作中利用此功能，无需用户参与或更改代码。以下是一些受支持操作的示例：

```ruby
Post.find(1)  # 第一次调用生成并缓存预编译语句
Post.find(2)  # 后续调用重用缓存的预编译语句

Post.find_by_title('first post')
Post.find_by_title('second post')

Post.find_by(title: 'first post')
Post.find_by(title: 'second post')

post.comments
post.comments(true)
```

需要强调的是，如上面的示例所示，预编译语句不会缓存方法调用中传递的值；而是为它们提供占位符。

以下情况不使用缓存：
- 该模型具有默认范围
- 该模型使用单表继承
- 使用id列表进行`find`，例如：

    ```ruby
    # 不使用缓存
    Post.find(1, 2, 3)
    Post.find([1,2])
    ```

- 使用SQL片段进行`find_by`：

    ```ruby
    Post.find_by('published_at < ?', 2.weeks.ago)
    ```

### Web控制台

使用Rails 4.2生成的新应用程序现在默认带有[Web
Console](https://github.com/rails/web-console) gem。Web Console在每个错误页面上添加了一个交互式Ruby控制台，并提供了一个`console`视图和控制器助手。

错误页面上的交互式控制台允许您在异常发生的地方执行代码。如果在视图或控制器的任何位置调用`console`助手，则在渲染完成后会启动一个带有最终上下文的交互式控制台。

### 外键支持

迁移DSL现在支持添加和删除外键。它们也会被转储到`schema.rb`中。目前，只有`mysql`，`mysql2`和`postgresql`适配器支持外键。

```ruby
# 添加一个外键到`articles.author_id`，引用`authors.id`
add_foreign_key :articles, :authors

# 添加一个外键到`articles.author_id`，引用`users.lng_id`
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# 删除`accounts.branch_id`上的外键
remove_foreign_key :accounts, :branches

# 删除`accounts.owner_id`上的外键
remove_foreign_key :accounts, column: :owner_id
```

请参阅API文档中的[add_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)
和[remove_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)
以获取完整的描述。

不兼容性
-----------------

之前已弃用的功能已被删除。请参考各个组件以了解此版本中的新弃用功能。

以下更改可能需要立即采取行动。

### 使用字符串参数的`render`

以前，在控制器操作中调用`render "foo/bar"`等同于`render file: "foo/bar"`。在Rails 4.2中，这已更改为表示`render template: "foo/bar"`。如果您需要渲染文件，请将代码更改为使用显式形式（`render file: "foo/bar"`）。

### `respond_with` / 类级别的`respond_to`

`respond_with`和相应的类级别的`respond_to`已移至[responders](https://github.com/plataformatec/responders) gem。在您的`Gemfile`中添加`gem 'responders', '~> 2.0'`以使用它：

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

实例级别的`respond_to`不受影响：

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

### `rails server`的默认主机

由于Rack的更改，`rails server`现在默认监听`localhost`而不是`0.0.0.0`。这对标准开发工作流程的影响应该很小，因为 http://127.0.0.1:3000 和 http://localhost:3000 在您自己的机器上仍然像以前一样工作。

但是，由于此更改，您将无法从其他计算机访问Rails服务器，例如，如果您的开发环境在虚拟机中，并且您希望从主机机器访问它。在这种情况下，请使用`rails server -b 0.0.0.0`启动服务器以恢复旧的行为。

如果这样做，请确保正确配置防火墙，以便只有您网络上的受信任的计算机可以访问您的开发服务器。
### 更改了 `render` 方法的状态选项符号

由于 Rack 的更改，`render` 方法接受的 `:status` 选项的符号已经发生了变化：

- 306: `:reserved` 已被移除。
- 413: `:request_entity_too_large` 已被重命名为 `:payload_too_large`。
- 414: `:request_uri_too_long` 已被重命名为 `:uri_too_long`。
- 416: `:requested_range_not_satisfiable` 已被重命名为 `:range_not_satisfiable`。

请注意，如果使用未知的符号调用 `render` 方法，响应状态将默认为 500。

### HTML 清理器

HTML 清理器已被一个基于 [Loofah](https://github.com/flavorjones/loofah) 和 [Nokogiri](https://github.com/sparklemotion/nokogiri) 的新实现所取代。新的清理器更安全，其清理功能更强大和灵活。

由于新算法的使用，对于某些特殊输入，清理后的输出可能会有所不同。

如果您对旧清理器的确切输出有特殊需求，可以将 [rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer) gem 添加到 `Gemfile` 中，以获得旧的行为。该 gem 不会发出弃用警告，因为它是可选择的。

`rails-deprecated_sanitizer` 仅支持 Rails 4.2；不会为 Rails 5.0 进行维护。

有关新清理器的更多详细信息，请参阅[此博文](https://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/)。

### `assert_select`

`assert_select` 现在基于 [Nokogiri](https://github.com/sparklemotion/nokogiri)。因此，一些先前有效的选择器现在不再受支持。如果您的应用程序使用了这些拼写，请务必更新它们：

*   如果属性选择器中的值包含非字母数字字符，则可能需要对其进行引用。

    ```ruby
    # 之前
    a[href=/]
    a[href$=/]

    # 现在
    a[href="/"]
    a[href$="/"]
    ```

*   从包含有不正确嵌套元素的 HTML 源构建的 DOM 可能会有所不同。

    例如：

    ```ruby
    # 内容： <div><i><p></i></div>

    # 之前：
    assert_select('div > i')  # => true
    assert_select('div > p')  # => false
    assert_select('i > p')    # => true

    # 现在：
    assert_select('div > i')  # => true
    assert_select('div > p')  # => true
    assert_select('i > p')    # => false
    ```

*   如果所选数据包含实体，则用于比较的值之前是原始的（例如 `AT&amp;T`），现在是经过评估的（例如 `AT&T`）。

    ```ruby
    # 内容： <p>AT&amp;T</p>

    # 之前：
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # 现在：
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

此外，替换语法也发生了变化。

现在您需要使用 `:match` 类似于 CSS 的选择器：

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

此外，当断言失败时，正则表达式的替换语法也有所不同。注意这里的 `/hello/`：

```ruby
assert_select(":match('id', ?)", /hello/)
```

变成了 `"(?-mix:hello)"`：

```
Expected at least 1 element matching "div:match('id', "(?-mix:hello)")", found 0..
Expected 0 to be >= 1.
```

有关 `assert_select` 的更多信息，请参阅 [Rails Dom Testing](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b) 文档。

Railties
--------

有关详细更改，请参阅[更改日志][railties]。

### 删除

*   应用程序生成器中的 `--skip-action-view` 选项已被删除。([Pull Request](https://github.com/rails/rails/pull/17042))

*   `rails application` 命令已被删除，没有替代品。([Pull Request](https://github.com/rails/rails/pull/11616))

### 弃用

*   弃用了生产环境中缺失的 `config.log_level`。([Pull Request](https://github.com/rails/rails/pull/16622))

*   弃用了 `rake test:all`，改用 `rake test`，因为它现在运行 `test` 文件夹中的所有测试。([Pull Request](https://github.com/rails/rails/pull/17348))
*   弃用`rake test:all:db`，改用`rake test:db`。
    ([Pull Request](https://github.com/rails/rails/pull/17348))

*   弃用`Rails::Rack::LogTailer`，没有替代品。
    ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### 重要更改

*   在默认应用程序`Gemfile`中引入了`web-console`。
    ([Pull Request](https://github.com/rails/rails/pull/11667))

*   为模型生成器添加了一个`required`选项，用于关联。
    ([Pull Request](https://github.com/rails/rails/pull/16062))

*   引入了`x`命名空间，用于定义自定义配置选项：

    ```ruby
    # config/environments/production.rb
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries  = 3
    config.x.super_debugger              = true
    ```

    然后可以通过配置对象访问这些选项：

    ```ruby
    Rails.configuration.x.payment_processing.schedule # => :daily
    Rails.configuration.x.payment_processing.retries  # => 3
    Rails.configuration.x.super_debugger              # => true
    ```

    ([Commit](https://github.com/rails/rails/commit/611849772dd66c2e4d005dcfe153f7ce79a8a7db))

*   引入了`Rails::Application.config_for`，用于加载当前环境的配置。

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

    ([Pull Request](https://github.com/rails/rails/pull/16129))

*   在应用程序生成器中引入了一个`--skip-turbolinks`选项，用于不生成turbolinks集成。
    ([Commit](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

*   引入了一个`bin/setup`脚本，作为自动设置应用程序的约定。
    ([Pull Request](https://github.com/rails/rails/pull/15189))

*   在开发环境中，将`config.assets.digest`的默认值更改为`true`。
    ([Pull Request](https://github.com/rails/rails/pull/15155))

*   引入了一个API，用于注册`rake notes`的新扩展。
    ([Pull Request](https://github.com/rails/rails/pull/14379))

*   引入了一个`after_bundle`回调，用于Rails模板中的使用。
    ([Pull Request](https://github.com/rails/rails/pull/16359))

*   引入了`Rails.gem_version`作为一个方便的方法，返回`Gem::Version.new(Rails.version)`。
    ([Pull Request](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

详细更改请参阅[Changelog][action-pack]。

### 移除

*   从Rails中移除了`respond_with`和类级别的`respond_to`，并将其移到`responders` gem（版本2.0）中。在`Gemfile`中添加`gem 'responders', '~> 2.0'`以继续使用这些功能。
    ([Pull Request](https://github.com/rails/rails/pull/16526),
     [更多详情](https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders))

*   移除了已弃用的`AbstractController::Helpers::ClassMethods::MissingHelperError`，改用`AbstractController::Helpers::MissingHelperError`。
    ([Commit](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### 弃用

*   弃用了`*_path`助手中的`only_path`选项。
    ([Commit](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9))

*   弃用了`assert_tag`、`assert_no_tag`、`find_tag`和`find_all_tag`，改用`assert_select`。
    ([Commit](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

*   弃用了将路由器的`:to`选项设置为符号或不包含`"#"字符的字符串的支持：

    ```ruby
    get '/posts', to: MyRackApp    => (无需更改)
    get '/posts', to: 'post#index' => (无需更改)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```

    ([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

*   弃用了URL助手中的字符串键的支持：

    ```ruby
    # 错误
    root_path('controller' => 'posts', 'action' => 'index')

    # 正确
    root_path(controller: 'posts', action: 'index')
    ```

    ([Pull Request](https://github.com/rails/rails/pull/17743))

### 重要更改

*   从文档中删除了`*_filter`系列方法。建议使用`*_action`系列方法代替：

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

    如果您的应用程序当前依赖于这些方法，应改用替代的`*_action`方法。这些方法将在将来被弃用，并最终从Rails中删除。

    (Commit [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de),
    [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4))

*   `render nothing: true`或渲染`nil`的响应体不再在响应体中添加单个空格填充。
    ([Pull Request](https://github.com/rails/rails/pull/14883))
* Rails现在自动在ETags中包含模板的摘要。
    ([Pull Request](https://github.com/rails/rails/pull/16527))

* 传递给URL助手的片段现在会自动转义。
    ([Commit](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

* 引入了`always_permitted_parameters`选项来配置全局允许的参数。该配置的默认值是`['controller', 'action']`。
    ([Pull Request](https://github.com/rails/rails/pull/15933))

* 从[RFC 4791](https://tools.ietf.org/html/rfc4791)中添加了HTTP方法`MKCALENDAR`。
    ([Pull Request](https://github.com/rails/rails/pull/15121))

* `*_fragment.action_controller`通知现在在有效负载中包含控制器和动作名称。
    ([Pull Request](https://github.com/rails/rails/pull/14137))

* 通过模糊匹配改进了路由错误页面的路由搜索。
    ([Pull Request](https://github.com/rails/rails/pull/14619))

* 添加了一个选项来禁用CSRF失败的日志记录。
    ([Pull Request](https://github.com/rails/rails/pull/14280))

* 当Rails服务器设置为提供静态资源时，如果客户端支持并且磁盘上有预生成的gzip文件（`.gz`），则会提供gzip资源。默认情况下，资源管道为所有可压缩的资源生成`.gz`文件。提供gzip文件可以减少数据传输并加速资源请求。在生产环境中，如果从Rails服务器提供资源，请始终使用[CDN](https://guides.rubyonrails.org/v4.2/asset_pipeline.html#cdns)。
    ([Pull Request](https://github.com/rails/rails/pull/16466))

* 在集成测试中调用`process`助手时，路径需要有一个前导斜杠。以前可以省略它，但那是实现的副产品，而不是有意的功能，例如：

    ```ruby
    test "list all posts" do
      get "/posts"
      assert_response :success
    end
    ```

Action View
-----------

有关详细更改，请参阅[Changelog][action-view]。

### 弃用

* 弃用了`AbstractController::Base.parent_prefixes`。
    当您想要更改查找视图的位置时，请覆盖`AbstractController::Base.local_prefixes`。
    ([Pull Request](https://github.com/rails/rails/pull/15026))

* 弃用了`ActionView::Digestor#digest(name, format, finder, options = {})`。
    参数应该以哈希的形式传递。
    ([Pull Request](https://github.com/rails/rails/pull/14243))

### 显着更改

* `render "foo/bar"`现在扩展为`render template: "foo/bar"`，而不是`render file: "foo/bar"`。
    ([Pull Request](https://github.com/rails/rails/pull/16888))

* 表单助手不再在隐藏字段周围生成带有内联CSS的`<div>`元素。
    ([Pull Request](https://github.com/rails/rails/pull/14738))

* 引入了`#{partial_name}_iteration`特殊局部变量，用于与使用集合渲染的局部视图一起使用。它通过`index`、`size`、`first?`和`last?`方法提供对迭代状态的访问。
    ([Pull Request](https://github.com/rails/rails/pull/7698))

* 占位符I18n遵循与`label` I18n相同的约定。
    ([Pull Request](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

有关详细更改，请参阅[Changelog][action-mailer]。

### 弃用

* 弃用了邮件中的`*_path`助手。始终使用`*_url`助手。
    ([Pull Request](https://github.com/rails/rails/pull/15840))

* 弃用了`deliver` / `deliver!`，改用`deliver_now` / `deliver_now!`。
    ([Pull Request](https://github.com/rails/rails/pull/16582))

### 显着更改

* `link_to`和`url_for`在模板中默认生成绝对URL，不再需要传递`only_path: false`。
    ([Commit](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

* 引入了`deliver_later`，它会将一个作业加入应用程序的队列，以异步发送电子邮件。
    ([Pull Request](https://github.com/rails/rails/pull/16485))

* 添加了`show_previews`配置选项，用于在开发环境之外启用邮件预览。
    ([Pull Request](https://github.com/rails/rails/pull/15970))


Active Record
-------------

有关详细更改，请参阅[Changelog][active-record]。

### 删除

* 删除了`cache_attributes`和相关内容。所有属性都会被缓存。
    ([Pull Request](https://github.com/rails/rails/pull/15429))

* 删除了弃用的方法`ActiveRecord::Base.quoted_locking_column`。
    ([Pull Request](https://github.com/rails/rails/pull/15612))

* 删除了弃用的`ActiveRecord::Migrator.proper_table_name`。改用`ActiveRecord::Migration`的`proper_table_name`实例方法。
    ([Pull Request](https://github.com/rails/rails/pull/15512))

* 删除了未使用的`:timestamp`类型。在所有情况下，将其透明地别名为`:datetime`。修复了在列类型发送到Active Record之外时的不一致性，例如用于XML序列化。
    ([Pull Request](https://github.com/rails/rails/pull/15184))
### 弃用

*   弃用在 `after_commit` 和 `after_rollback` 中吞噬错误的功能。
    ([Pull Request](https://github.com/rails/rails/pull/16537))

*   弃用对 `has_many :through` 关联自动检测计数缓存的支持。您应该手动在 `has_many` 和 `belongs_to` 关联上指定计数缓存，以用于通过记录。
    ([Pull Request](https://github.com/rails/rails/pull/15754))

*   弃用将 Active Record 对象传递给 `.find` 或 `.exists?`。请先在对象上调用 `id`。
    (Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
    [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   弃用对 PostgreSQL 范围值的不完全支持，其中排除开始值。我们目前将 PostgreSQL 范围映射到 Ruby 范围。这种转换是不完全可能的，因为 Ruby 范围不支持排除开始值。

    当前的解决方案是递增开始值，这是不正确的，并且现在已被弃用。对于我们不知道如何递增的子类型（例如 `succ` 未定义），对于具有排除开始值的范围，它将引发 `ArgumentError`。
    ([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   弃用在没有连接的情况下调用 `DatabaseTasks.load_schema`。请改用 `DatabaseTasks.load_schema_current`。
    ([Commit](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   弃用 `sanitize_sql_hash_for_conditions`，没有替代方法。使用 `Relation` 执行查询和更新是首选的 API。
    ([Commit](https://github.com/rails/rails/commit/d5902c9e))

*   弃用不传递 `:null` 选项的 `add_timestamps` 和 `t.timestamps`。在 Rails 5 中，默认值 `null: true` 将更改为 `null: false`。
    ([Pull Request](https://github.com/rails/rails/pull/16481))

*   弃用不再需要的 `Reflection#source_macro`，没有替代方法。
    ([Pull Request](https://github.com/rails/rails/pull/16373))

*   弃用 `serialized_attributes`，没有替代方法。
    ([Pull Request](https://github.com/rails/rails/pull/15704))

*   弃用在没有列存在时从 `column_for_attribute` 返回 `nil`。在 Rails 5.0 中，它将返回一个空对象。
    ([Pull Request](https://github.com/rails/rails/pull/15878))

*   弃用在依赖于实例状态的关联（即使用接受参数的作用域定义的关联）中使用 `.joins`、`.preload` 和 `.eager_load`，没有替代方法。
    ([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### 显著变化

*   `SchemaDumper` 在 `create_table` 上使用 `force: :cascade`。这使得在外键存在时重新加载模式成为可能。

*   在单数关联中添加了 `:required` 选项，该选项在关联上定义了存在性验证。
    ([Pull Request](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty` 现在可以检测到对可变值的原地更改。在 Active Record 模型上的序列化属性在未更改时不再保存。这也适用于其他类型，如 PostgreSQL 上的字符串列和 json 列。
    (Pull Requests [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))

*   引入了 `db:purge` Rake 任务，以清空当前环境的数据库。
    ([Commit](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

*   引入了 `ActiveRecord::Base#validate!`，如果记录无效，则引发 `ActiveRecord::RecordInvalid`。
    ([Pull Request](https://github.com/rails/rails/pull/8639))

*   引入了 `validate` 作为 `valid?` 的别名。
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   `touch` 现在可以同时接受多个要触发的属性。
    ([Pull Request](https://github.com/rails/rails/pull/14423))

*   PostgreSQL 适配器现在支持 PostgreSQL 9.4+ 中的 `jsonb` 数据类型。
    ([Pull Request](https://github.com/rails/rails/pull/16220))

*   PostgreSQL 和 SQLite 适配器不再在字符串列上添加默认长度为 255 个字符的限制。
    ([Pull Request](https://github.com/rails/rails/pull/14579))

*   在 PostgreSQL 适配器中添加了对 `citext` 列类型的支持。
    ([Pull Request](https://github.com/rails/rails/pull/12523))

*   在 PostgreSQL 适配器中添加了对用户创建的范围类型的支持。
    ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

*   `sqlite3:///some/path` 现在解析为绝对系统路径 `/some/path`。对于相对路径，请改用 `sqlite3:some/path`。
    （以前，`sqlite3:///some/path` 解析为相对路径 `some/path`。此行为在 Rails 4.1 中已弃用）。
    ([Pull Request](https://github.com/rails/rails/pull/14569))

*   在 MySQL 5.6 及以上版本中添加了对分数秒的支持。
    (Pull Request [1](https://github.com/rails/rails/pull/8240),
    [2](https://github.com/rails/rails/pull/14359))
*   添加了`ActiveRecord::Base#pretty_print`来美化打印模型。
    ([拉取请求](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload`现在的行为与`m = Model.find(m.id)`相同，
    这意味着它不再保留来自自定义`SELECT`的额外属性。
    ([拉取请求](https://github.com/rails/rails/pull/15866))

*   `ActiveRecord::Base#reflections`现在返回一个带有字符串键而不是符号键的哈希。
    ([拉取请求](https://github.com/rails/rails/pull/17718))

*   迁移中的`references`方法现在支持`type`选项，用于指定外键的类型（例如`:uuid`）。
    ([拉取请求](https://github.com/rails/rails/pull/16231))

Active Model
------------

详细更改请参阅[更新日志][active-model]。

### 移除

*   移除了已弃用的`Validator#setup`，没有替代方法。
    ([拉取请求](https://github.com/rails/rails/pull/10716))

### 弃用

*   弃用了`reset_#{attribute}`，推荐使用`restore_#{attribute}`。
    ([拉取请求](https://github.com/rails/rails/pull/16180))

*   弃用了`ActiveModel::Dirty#reset_changes`，推荐使用`clear_changes_information`。
    ([拉取请求](https://github.com/rails/rails/pull/16180))

### 显著更改

*   引入了`validate`作为`valid?`的别名。
    ([拉取请求](https://github.com/rails/rails/pull/14456))

*   在`ActiveModel::Dirty`中引入了`restore_attributes`方法，用于恢复已更改（脏）的属性为其先前的值。
    (拉取请求 [1](https://github.com/rails/rails/pull/14861),
    [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password`现在默认情况下不再禁止空密码（即只包含空格的密码）。
    ([拉取请求](https://github.com/rails/rails/pull/16412))

*   如果启用了验证，`has_secure_password`现在会验证给定的密码是否少于72个字符。
    ([拉取请求](https://github.com/rails/rails/pull/15708))

Active Support
--------------

详细更改请参阅[更新日志][active-support]。

### 移除

*   移除了已弃用的`Numeric#ago`、`Numeric#until`、`Numeric#since`、`Numeric#from_now`。
    ([提交](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   移除了`ActiveSupport::Callbacks`中基于字符串的终止符的弃用。
    ([拉取请求](https://github.com/rails/rails/pull/15100))

### 弃用

*   弃用了`Kernel#silence_stderr`、`Kernel#capture`和`Kernel#quietly`，没有替代方法。
    ([拉取请求](https://github.com/rails/rails/pull/13392))

*   弃用了`Class#superclass_delegating_accessor`，请使用`Class#class_attribute`。
    ([拉取请求](https://github.com/rails/rails/pull/14271))

*   弃用了`ActiveSupport::SafeBuffer#prepend!`，因为`ActiveSupport::SafeBuffer#prepend`现在具有相同的功能。
    ([拉取请求](https://github.com/rails/rails/pull/14529))

### 显著更改

*   引入了一个新的配置选项`active_support.test_order`，用于指定测试用例的执行顺序。该选项当前默认为`:sorted`，但在Rails 5.0中将更改为`:random`。
    ([提交](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   `Object#try`和`Object#try!`现在可以在块中不使用显式接收者。
    ([提交](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830),
    [拉取请求](https://github.com/rails/rails/pull/17361))

*   `travel_to`测试助手现在将`usec`组件截断为0。
    ([提交](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   引入了`Object#itself`作为一个恒等函数。
    (提交 [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810),
    [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   `Object#with_options`现在可以在块中不使用显式接收者。
    ([拉取请求](https://github.com/rails/rails/pull/16339))

*   引入了`String#truncate_words`，用于按单词数截断字符串。
    ([拉取请求](https://github.com/rails/rails/pull/16190))

*   添加了`Hash#transform_values`和`Hash#transform_values!`，以简化一个常见模式，其中哈希的值必须更改，但键保持不变。
    ([拉取请求](https://github.com/rails/rails/pull/15819))

*   `humanize`词形变换助手现在会去除任何前导下划线。
    ([提交](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   引入了`Concern#class_methods`作为`module ClassMethods`的替代方法，以及`Kernel#concern`来避免`module Foo; extend ActiveSupport::Concern; end`的样板代码。
    ([提交](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   新的[指南](autoloading_and_reloading_constants_classic_mode.html)，介绍了常量自动加载和重新加载。

贡献者
-------

请参阅[Rails的完整贡献者列表](https://contributors.rubyonrails.org/)，感谢所有为Rails付出了大量时间的人，使其成为一个稳定和强大的框架。向他们致敬。

[railties]:       https://github.com/rails/rails/blob/4-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/4-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/4-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/4-2-stable/actionmailer/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/4-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/4-2-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
