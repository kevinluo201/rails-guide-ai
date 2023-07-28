**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 95d91c83726e012162afc60c78688099
Ruby on Rails 4.1 发布说明
===============================

Rails 4.1 的亮点：

* Spring 应用程序预加载器
* `config/secrets.yml`
* Action Pack 变体
* Action Mailer 预览

这些发布说明仅涵盖了主要更改。要了解各种错误修复和更改，请参阅更改日志或查看 GitHub 上主要 Rails 存储库中的[提交列表](https://github.com/rails/rails/commits/4-1-stable)。

--------------------------------------------------------------------------------

升级到 Rails 4.1
----------------------

如果您正在升级现有应用程序，在进行升级之前，最好先进行充分的测试覆盖。如果您尚未升级到 Rails 4.0，请先升级到 Rails 4.0，并确保您的应用程序在升级到 Rails 4.1 之前仍然按预期运行。在[升级 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1)指南中提供了一份升级时需要注意的事项清单。


主要功能
--------------

### Spring 应用程序预加载器

Spring 是一个 Rails 应用程序预加载器。它通过在后台保持应用程序运行，加快了开发速度，这样您就不需要每次运行测试、rake 任务或迁移时都启动它。

新的 Rails 4.1 应用程序将附带“springified” binstubs。这意味着 `bin/rails` 和 `bin/rake` 将自动利用预加载的 spring 环境。

**运行 rake 任务：**

```bash
$ bin/rake test:models
```

**运行 Rails 命令：**

```bash
$ bin/rails console
```

**Spring 检查：**

```bash
$ bin/spring status
Spring is running:

 1182 spring server | my_app | started 29 mins ago
 3656 spring app    | my_app | started 23 secs ago | test mode
 3746 spring app    | my_app | started 10 secs ago | development mode
```

请查看[Spring README](https://github.com/rails/spring/blob/master/README.md)以查看所有可用功能。

请参阅[升级 Ruby on Rails](upgrading_ruby_on_rails.html#spring)指南，了解如何将现有应用程序迁移到使用此功能。

### `config/secrets.yml`

Rails 4.1 在 `config` 文件夹中生成一个新的 `secrets.yml` 文件。默认情况下，此文件包含应用程序的 `secret_key_base`，但也可以用于存储其他秘密，如外部 API 的访问密钥。

添加到此文件中的秘密可以通过 `Rails.application.secrets` 访问。例如，使用以下 `config/secrets.yml`：

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

在开发环境中，`Rails.application.secrets.some_api_key` 返回 `SOMEKEY`。

请参阅[升级 Ruby on Rails](upgrading_ruby_on_rails.html#config-secrets-yml)指南，了解如何将现有应用程序迁移到使用此功能。

### Action Pack 变体

我们经常希望为手机、平板电脑和桌面浏览器呈现不同的 HTML/JSON/XML 模板。变体使这变得容易。

请求变体是请求格式的特殊化，如 `:tablet`、`:phone` 或 `:desktop`。

您可以在 `before_action` 中设置变体：

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

在操作中响应变体，就像响应格式一样：

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # 渲染 app/views/projects/show.html+tablet.erb
    html.phone { extra_setup; render ... }
  end
end
```

为每个格式和变体提供单独的模板：

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

您还可以使用内联语法简化变体定义：

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```

### Action Mailer 预览

Action Mailer 预览提供了一种通过访问特殊 URL 来查看电子邮件外观的方法。

您可以实现一个预览类，其方法返回您想要检查的邮件对象：

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

预览可在 http://localhost:3000/rails/mailers/notifier/welcome 中访问，并且列表可在 http://localhost:3000/rails/mailers 中查看。

默认情况下，这些预览类位于 `test/mailers/previews` 中。可以使用 `preview_path` 选项进行配置。

请参阅其[文档](https://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails)以获取详细的说明。

### Active Record 枚举

声明一个枚举属性，其中的值映射到数据库中的整数，但可以通过名称进行查询。

```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => 所有已归档的 Conversation 的关系

Conversation.statuses # => { "active" => 0, "archived" => 1 }
```

请参阅其[文档](https://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html)以获取详细的说明。

### 消息验证器

消息验证器可用于生成和验证已签名的消息。这对于安全地传输敏感数据（如记住我令牌和好友）非常有用。

方法 `Rails.application.message_verifier` 返回一个新的消息验证器，该验证器使用从 secret_key_base 和给定的消息验证器名称派生的密钥对消息进行签名：
```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# raises ActiveSupport::MessageVerifier::InvalidSignature
```

### Module#concerning

在类中分离责任的一种自然、低仪式的方式：

```ruby
class Todo < ActiveRecord::Base
  concerning :EventTracking do
    included do
      has_many :events
    end

    def latest_event
      # ...
    end

    private
      def some_internal_method
        # ...
      end
  end
end
```

这个例子等同于内联定义一个 `EventTracking` 模块，然后用 `ActiveSupport::Concern` 扩展它，并将其混入到 `Todo` 类中。

详细的写作和预期用例，请参阅其[文档](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html)。

### 从远程 `<script>` 标签中保护 CSRF

跨站请求伪造（CSRF）保护现在也覆盖了带有 JavaScript 响应的 GET 请求。这样可以防止第三方站点引用您的 JavaScript URL，并尝试运行它以提取敏感数据。

这意味着任何访问 `.js` URL 的测试现在都会失败 CSRF 保护，除非它们使用 `xhr`。请将您的测试明确地指定为期望 XmlHttpRequests，而不是 `post :create, format: :js`，请切换到明确的 `xhr :post, :create, format: :js`。


Railties
--------

请参阅[更改日志](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md)以获取详细的更改信息。

### 删除

* 删除了 `update:application_controller` rake 任务。

* 删除了已弃用的 `Rails.application.railties.engines`。

* 从 Rails 配置中删除了已弃用的 `threadsafe!`。

* 从 ActiveRecord::Generators::ActiveModel 中删除了已弃用的 `update_attributes`，改用 `update`。

* 删除了已弃用的 `config.whiny_nils` 选项。

* 删除了运行测试的已弃用的 rake 任务：`rake test:uncommitted` 和 `rake test:recent`。

### 显著更改

* 默认情况下，新应用程序安装了 [Spring 应用程序预加载器](https://github.com/rails/spring)。它使用 `Gemfile` 的开发组，因此不会在生产环境中安装。([拉取请求](https://github.com/rails/rails/pull/12958))

* `BACKTRACE` 环境变量用于显示测试失败的未过滤回溯。([提交](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553))

* 将 `MiddlewareStack#unshift` 暴露给环境配置。([拉取请求](https://github.com/rails/rails/pull/12479))

* 添加了 `Application#message_verifier` 方法以返回消息验证器。([拉取请求](https://github.com/rails/rails/pull/12995))

* 默认生成的测试帮助器文件 `test_help.rb` 将自动使用 `db/schema.rb`（或 `db/structure.sql`）来保持测试数据库的最新状态。如果重新加载模式未解决所有待处理的迁移，则会引发错误。通过 `config.active_record.maintain_test_schema = false` 可以退出。([拉取请求](https://github.com/rails/rails/pull/13528))

* 引入 `Rails.gem_version` 作为一个方便的方法，返回 `Gem::Version.new(Rails.version)`，建议使用更可靠的方法进行版本比较。([拉取请求](https://github.com/rails/rails/pull/14103))


Action Pack
-----------

请参阅[更改日志](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md)以获取详细的更改信息。

### 删除

* 删除了集成测试的已弃用的 Rails 应用程序回退，改为设置 `ActionDispatch.test_app`。

* 删除了已弃用的 `page_cache_extension` 配置。

* 删除了 Action Controller 中的已弃用的常量，使用 `ActionView::RecordIdentifier` 替代。

| 已删除项                            | 后继者                       |
|:-----------------------------------|:--------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### 显著更改

* `protect_from_forgery` 也会阻止跨域 `<script>` 标签。更新您的测试，使用 `xhr :get, :foo, format: :js` 替代 `get :foo, format: :js`。([拉取请求](https://github.com/rails/rails/pull/13345))

* `#url_for` 接受一个包含选项的哈希，放在一个数组中。([拉取请求](https://github.com/rails/rails/pull/9599))

* 添加了 `session#fetch` 方法，它的行为类似于 [Hash#fetch](https://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch)，但返回的值总是保存到会话中。([拉取请求](https://github.com/rails/rails/pull/12692))

* 完全将 Action View 与 Action Pack 分离。([拉取请求](https://github.com/rails/rails/pull/11032))

* 记录受深度修改影响的键。([拉取请求](https://github.com/rails/rails/pull/13813))

* 新的配置选项 `config.action_dispatch.perform_deep_munge`，用于退出用于解决安全漏洞 CVE-2013-0155 的参数 "deep munging"。([拉取请求](https://github.com/rails/rails/pull/13188))

* 新的配置选项 `config.action_dispatch.cookies_serializer`，用于指定签名和加密 cookie 存储的序列化器。([拉取请求](https://github.com/rails/rails/pull/13692), [2](https://github.com/rails/rails/pull/13945) / [更多详情](upgrading_ruby_on_rails.html#cookies-serializer))

* 添加了 `render :plain`、`render :html` 和 `render :body`。([拉取请求](https://github.com/rails/rails/pull/14062) / [更多详情](upgrading_ruby_on_rails.html#rendering-content-from-string))


Action Mailer
-------------

请参阅[更改日志](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md)以获取详细的更改信息。

### 显著更改

* 基于 37 Signals 的 mail_view gem，添加了邮件预览功能。([提交](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261))

* 对 Action Mailer 消息生成进行仪器化。将生成消息所需的时间写入日志。([拉取请求](https://github.com/rails/rails/pull/12556))


Active Record
-------------

请参阅[更改日志](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md)以获取详细的更改信息。

### 删除

* 从 `SchemaCache` 方法中删除了向 nil 传递的已弃用参数：`primary_keys`、`tables`、`columns` 和 `columns_hash`。

* 从 `ActiveRecord::Migrator#migrate` 中删除了已弃用的块过滤器。

* 从 `ActiveRecord::Migrator` 中删除了已弃用的 String 构造函数。

* 从 `scope` 中删除了使用未传递可调用对象的已弃用用法。

* 删除了已弃用的 `transaction_joinable=`，改用带有 `:joinable` 选项的 `begin_transaction`。

* 删除了已弃用的 `decrement_open_transactions`。

* 删除了已弃用的 `increment_open_transactions`。
* 移除了已弃用的`PostgreSQLAdapter#outside_transaction?`方法。您可以使用`#transaction_open?`代替。

* 移除了已弃用的`ActiveRecord::Fixtures.find_table_name`，改用`ActiveRecord::Fixtures.default_fixture_model_name`。

* 从`SchemaStatements`中移除了已弃用的`columns_for_remove`。

* 移除了已弃用的`SchemaStatements#distinct`。

* 将已弃用的`ActiveRecord::TestCase`移动到Rails测试套件中。该类不再是公共类，只用于内部Rails测试。

* 移除了关联中已弃用的选项`:restrict`的支持。

* 移除了关联中已弃用的选项`:delete_sql`、`:insert_sql`、`:finder_sql`和`:counter_sql`。

* 从Column中移除了已弃用的方法`type_cast_code`。

* 移除了已弃用的`ActiveRecord::Base#connection`方法。请确保通过类来访问它。

* 移除了`auto_explain_threshold_in_seconds`的弃用警告。

* 从`Relation#count`中移除了已弃用的选项`:distinct`。

* 移除了已弃用的方法`partial_updates`、`partial_updates?`和`partial_updates=`。

* 移除了已弃用的方法`scoped`。

* 移除了已弃用的方法`default_scopes?`。

* 移除了在4.0中已弃用的隐式连接引用。

* 将`activerecord-deprecated_finders`作为依赖项移除。请参阅[宝石自述文件](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders)了解更多信息。

* 不再使用`implicit_readonly`。请使用`readonly`方法显式地将记录标记为`readonly`。([拉取请求](https://github.com/rails/rails/pull/10769))

### 弃用

* 弃用了未使用的`quoted_locking_column`方法。

* 弃用了`ConnectionAdapters::SchemaStatements#distinct`，因为它不再被内部使用。([拉取请求](https://github.com/rails/rails/pull/10556))

* 弃用了`rake db:test:*`任务，因为测试数据库现在会自动维护。请参阅railties发布说明。([拉取请求](https://github.com/rails/rails/pull/13528))

* 弃用了未使用的`ActiveRecord::Base.symbolized_base_class`和`ActiveRecord::Base.symbolized_sti_name`，没有替代方法。[提交](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)

### 显著变化

* 默认作用域不再被链式条件覆盖。

  在此更改之前，当您在模型中定义了`default_scope`时，它会被相同字段的链式条件覆盖。现在它像任何其他作用域一样合并。[更多详情](upgrading_ruby_on_rails.html#changes-on-default-scopes)。

* 添加了`ActiveRecord::Base.to_param`，用于从模型的属性或方法派生方便的“漂亮”URL。([拉取请求](https://github.com/rails/rails/pull/12891))

* 添加了`ActiveRecord::Base.no_touching`，允许忽略模型上的触发。([拉取请求](https://github.com/rails/rails/pull/12772))

* 统一`MysqlAdapter`和`Mysql2Adapter`的布尔类型转换。`type_cast`将返回`true`的`1`和`false`的`0`。([拉取请求](https://github.com/rails/rails/pull/12425))

* `.unscope`现在会删除`default_scope`中指定的条件。([提交](https://github.com/rails/rails/commit/94924dc32baf78f13e289172534c2e71c9c8cade))

* 添加了`ActiveRecord::QueryMethods#rewhere`，它将覆盖现有的命名where条件。([提交](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2))

* 扩展了`ActiveRecord::Base#cache_key`，可以接受一个可选的时间戳属性列表，其中最高的属性将被使用。([提交](https://github.com/rails/rails/commit/e94e97ca796c0759d8fcb8f946a3bbc60252d329))

* 添加了`ActiveRecord::Base#enum`，用于声明枚举属性，其中值在数据库中映射为整数，但可以通过名称查询。([提交](https://github.com/rails/rails/commit/db41eb8a6ea88b854bf5cd11070ea4245e1639c5))

* 在写入时对JSON值进行类型转换，以使值与从数据库读取的值一致。([拉取请求](https://github.com/rails/rails/pull/12643))

* 在写入时对hstore值进行类型转换，以使值与从数据库读取的值一致。([提交](https://github.com/rails/rails/commit/5ac2341fab689344991b2a4817bd2bc8b3edac9d))

* 使`next_migration_number`对第三方生成器可访问。([拉取请求](https://github.com/rails/rails/pull/12407))

* 调用`update_attributes`现在会在接收到`nil`参数时抛出`ArgumentError`。更具体地说，如果传递给它的参数不响应`stringify_keys`，则会抛出错误。([拉取请求](https://github.com/rails/rails/pull/9860))

* `CollectionAssociation#first`/`#last`（例如`has_many`）使用`LIMIT`查询来获取结果，而不是加载整个集合。([拉取请求](https://github.com/rails/rails/pull/12137))

* 在Active Record模型类上调用`inspect`不会初始化新的连接。这意味着在数据库缺失时调用`inspect`将不再引发异常。([拉取请求](https://github.com/rails/rails/pull/11014))

* 删除了`count`的列限制，如果SQL无效，让数据库引发异常。([拉取请求](https://github.com/rails/rails/pull/10710))

* Rails现在自动检测逆向关联。如果您没有在关联上设置`:inverse_of`选项，那么Active Record将根据启发法猜测逆向关联。([拉取请求](https://github.com/rails/rails/pull/10886))

* 在ActiveRecord::Relation中处理别名属性。当使用符号键时，ActiveRecord现在将别名属性名称转换为数据库中使用的实际列名。([拉取请求](https://github.com/rails/rails/pull/7839))

* 不再在fixture文件中的ERB中评估主对象的上下文。多个fixture使用的辅助方法应该在包含在`ActiveRecord::FixtureSet.context_class`中的模块中定义。([拉取请求](https://github.com/rails/rails/pull/13022))

* 如果明确指定了RAILS_ENV，则不会创建或删除测试数据库。([拉取请求](https://github.com/rails/rails/pull/13629))

* `Relation`不再具有`#map!`和`#delete_if`等改变器方法。在使用这些方法之前，通过调用`#to_a`将其转换为`Array`。([拉取请求](https://github.com/rails/rails/pull/13314))

* `find_in_batches`、`find_each`、`Result#each`和`Enumerable#index_by`现在返回一个可以计算其大小的`Enumerator`。([拉取请求](https://github.com/rails/rails/pull/13938))

* `scope`、`enum`和关联现在在“危险”的名称冲突时引发异常。([拉取请求](https://github.com/rails/rails/pull/13450)，[拉取请求](https://github.com/rails/rails/pull/13896))

* `second`到`fifth`方法的行为类似于`first`查找器。([拉取请求](https://github.com/rails/rails/pull/13757))

* 使`touch`触发`after_commit`和`after_rollback`回调。([拉取请求](https://github.com/rails/rails/pull/12031))
* 为`sqlite >= 3.8.0`启用部分索引。
  ([拉取请求](https://github.com/rails/rails/pull/13350))

* 使`change_column_null`可逆。([提交](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96))

* 添加了一个标志，在迁移后禁用模式转储。在新应用程序的生产环境中，默认设置为`false`。
  ([拉取请求](https://github.com/rails/rails/pull/13948))

Active Model
------------

请参阅[更改日志](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md)以获取详细更改信息。

### 弃用

* 弃用`Validator#setup`。现在应该在验证器的构造函数中手动完成此操作。([提交](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a))

### 显著更改

* 在`ActiveModel::Dirty`中添加了新的API方法`reset_changes`和`changes_applied`，用于控制更改状态。

* 在定义验证时能够指定多个上下文。([拉取请求](https://github.com/rails/rails/pull/13754))

* `attribute_changed?`现在接受一个哈希来检查属性是否已更改为给定的`from`和/或`to`值。([拉取请求](https://github.com/rails/rails/pull/13131))


Active Support
--------------

请参阅[更改日志](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md)以获取详细更改信息。


### 移除

* 移除了`MultiJSON`依赖。因此，`ActiveSupport::JSON.decode`不再接受`MultiJSON`的选项哈希。([拉取请求](https://github.com/rails/rails/pull/10576) / [更多详细信息](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 移除了用于将自定义对象编码为JSON的`encode_json`钩子的支持。此功能已提取到[activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem中。([相关拉取请求](https://github.com/rails/rails/pull/12183) / [更多详细信息](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 移除了不带替代的已弃用的`ActiveSupport::JSON::Variable`。

* 移除了已弃用的`String#encoding_aware?`核心扩展(`core_ext/string/encoding`)。

* 移除了已弃用的`Module#local_constant_names`，改用`Module#local_constants`。

* 移除了已弃用的`DateTime.local_offset`，改用`DateTime.civil_from_format`。

* 移除了已弃用的`Logger`核心扩展(`core_ext/logger.rb`)。

* 移除了已弃用的`Time#time_with_datetime_fallback`、`Time#utc_time`和`Time#local_time`，改用`Time#utc`和`Time#local`。

* 移除了已弃用的`Hash#diff`，没有替代方法。

* 移除了已弃用的`Date#to_time_in_current_zone`，改用`Date#in_time_zone`。

* 移除了已弃用的`Proc#bind`，没有替代方法。

* 移除了已弃用的`Array#uniq_by`和`Array#uniq_by!`，改用原生的`Array#uniq`和`Array#uniq!`。

* 移除了已弃用的`ActiveSupport::BasicObject`，改用`ActiveSupport::ProxyObject`。

* 移除了已弃用的`BufferedLogger`，改用`ActiveSupport::Logger`。

* 移除了已弃用的`assert_present`和`assert_blank`方法，改用`assert object.blank?`和`assert object.present?`。

* 移除了过滤器对象的已弃用的`#filter`方法，改用相应的方法（例如，`#before`用于前置过滤器）。

* 从默认的不规则变形中移除了'cow' => 'kine'。([提交](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9))

### 弃用

* 弃用`Numeric#{ago,until,since,from_now}`，用户应该将值显式转换为AS::Duration，例如`5.ago` => `5.seconds.ago`。([拉取请求](https://github.com/rails/rails/pull/12389))

* 弃用了`active_support/core_ext/object/to_json`的require路径。请改为使用`active_support/core_ext/object/json`。([拉取请求](https://github.com/rails/rails/pull/12203))

* 弃用了`ActiveSupport::JSON::Encoding::CircularReferenceError`。此功能已提取到[activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem中。([拉取请求](https://github.com/rails/rails/pull/12785) / [更多详细信息](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 弃用了`ActiveSupport.encode_big_decimal_as_string`选项。此功能已提取到[activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem中。([拉取请求](https://github.com/rails/rails/pull/13060) / [更多详细信息](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 弃用自定义的`BigDecimal`序列化。([拉取请求](https://github.com/rails/rails/pull/13911))

### 显著更改

* 重写了`ActiveSupport`的JSON编码器，利用了JSON gem而不是在纯Ruby中进行自定义编码。([拉取请求](https://github.com/rails/rails/pull/12183) / [更多详细信息](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 改进了与JSON gem的兼容性。([拉取请求](https://github.com/rails/rails/pull/12862) / [更多详细信息](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 添加了`ActiveSupport::Testing::TimeHelpers#travel`和`#travel_to`。这些方法通过存根`Time.now`和`Date.today`来将当前时间更改为给定的时间或持续时间。

* 添加了`ActiveSupport::Testing::TimeHelpers#travel_back`。此方法通过删除`travel`和`travel_to`添加的存根，将当前时间返回到原始状态。([拉取请求](https://github.com/rails/rails/pull/13884))

* 添加了`Numeric#in_milliseconds`，例如`1.hour.in_milliseconds`，以便我们可以将它们传递给JavaScript函数，如`getTime()`。([提交](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643))

* 添加了`Date#middle_of_day`、`DateTime#middle_of_day`和`Time#middle_of_day`方法。还添加了`midday`、`noon`、`at_midday`、`at_noon`和`at_middle_of_day`作为别名。([拉取请求](https://github.com/rails/rails/pull/10879))

* 添加了用于生成日期范围的`Date#all_week/month/quarter/year`。([拉取请求](https://github.com/rails/rails/pull/9685))

* 添加了`Time.zone.yesterday`和`Time.zone.tomorrow`。([拉取请求](https://github.com/rails/rails/pull/12822))


