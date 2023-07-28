**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ddd82b1a207070829b1ec46e4bb40d80
Ruby on Rails 5.1 发布说明
===============================

Rails 5.1 的亮点：

* Yarn 支持
* 可选的 Webpack 支持
* jQuery 不再是默认依赖项
* 系统测试
* 加密的秘密
* 参数化的邮件发送器
* 直接和解析的路由
* 将 form_for 和 form_tag 统一为 form_with

这些发布说明仅涵盖了主要更改。要了解各种错误修复和更改，请参阅更改日志或查看 GitHub 上 Rails 主存储库中的[提交列表](https://github.com/rails/rails/commits/5-1-stable)。

--------------------------------------------------------------------------------

升级到 Rails 5.1
----------------------

如果您正在升级现有应用程序，最好在进行升级之前进行充分的测试覆盖。如果您还没有升级到 Rails 5.0，请先升级到 Rails 5.0，并确保您的应用程序在升级到 Rails 5.1 之前仍然正常运行。在升级时要注意的事项列表可在[升级 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1)指南中找到。


主要功能
--------------

### Yarn 支持

[拉取请求](https://github.com/rails/rails/pull/26836)

Rails 5.1 允许通过 Yarn 从 npm 管理 JavaScript 依赖项。这将使得使用 React、VueJS 或其他 npm 世界的库变得更加容易。Yarn 支持与资源管道集成，以便所有依赖项都可以与 Rails 5.1 应用程序无缝地工作。

### 可选的 Webpack 支持

[拉取请求](https://github.com/rails/rails/pull/27288)

Rails 应用程序可以更轻松地使用新的 [Webpacker](https://github.com/rails/webpacker) gem 与 [Webpack](https://webpack.js.org/)（一个 JavaScript 资源打包工具）集成。在生成新应用程序时，使用 `--webpack` 标志启用 Webpack 集成。

这与资源管道完全兼容，您可以继续使用资源管道来处理图像、字体、声音和其他资源。您甚至可以将一些 JavaScript 代码由资源管道管理，将其他代码通过 Webpack 处理。所有这些都由默认启用的 Yarn 管理。

### jQuery 不再是默认依赖项
[拉取请求](https://github.com/rails/rails/pull/27113)

在早期的Rails版本中，默认情况下需要使用jQuery来提供`data-remote`、`data-confirm`和其他Rails无侵入式JavaScript功能。现在不再需要，因为UJS已经重写为使用纯粹的JavaScript。这段代码现在作为`rails-ujs`内置在Action View中。

如果需要，仍然可以使用jQuery，但默认情况下不再需要。

### 系统测试

[拉取请求](https://github.com/rails/rails/pull/26703)

Rails 5.1内置了对Capybara测试的支持，以系统测试的形式。您不再需要担心配置Capybara和数据库清理策略。Rails 5.1提供了一个在Chrome中运行测试的包装器，还提供了其他功能，如失败截图。

### 加密的秘密

[拉取请求](https://github.com/rails/rails/pull/28038)

Rails现在允许以安全的方式管理应用程序秘密，受到[sekrets](https://github.com/ahoward/sekrets) gem的启发。

运行`bin/rails secrets:setup`来设置一个新的加密秘密文件。这也会生成一个必须存储在存储库之外的主密钥。然后可以安全地将秘密本身以加密形式提交到版本控制系统中。

在生产环境中，将使用存储在`RAILS_MASTER_KEY`环境变量或密钥文件中的密钥进行解密。

### 参数化的邮件发送器

[拉取请求](https://github.com/rails/rails/pull/27825)

允许在邮件发送器类的所有方法中指定常用参数，以便共享实例变量、头部和其他常见设置。

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end
end
```

```ruby
InvitationsMailer.with(inviter: person_a, invitee: person_b)
                 .account_invitation.deliver_later
```

### 直接和解析的路由

[拉取请求](https://github.com/rails/rails/pull/23138)

Rails 5.1在路由DSL中添加了两个新方法，`resolve`和`direct`。`resolve`方法允许自定义模型的多态映射。
```ruby
资源 :basket

解析("Basket") { [:basket] }
```

```erb
<%= form_for @basket do |form| %>
  <!-- 购物篮表单 -->
<% end %>
```

这将生成单数URL `/basket`，而不是通常的 `/baskets/:id`。

`direct` 方法允许创建自定义的URL辅助方法。

```ruby
direct(:homepage) { "https://rubyonrails.org" }

homepage_url # => "https://rubyonrails.org"
```

块的返回值必须是 `url_for` 方法的有效参数。因此，您可以传递有效的字符串URL、哈希、数组、Active Model实例或Active Model类。

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### 将 form_for 和 form_tag 统一为 form_with

[拉取请求](https://github.com/rails/rails/pull/26976)

在 Rails 5.1 之前，处理HTML表单有两个接口：`form_for` 用于模型实例，`form_tag` 用于自定义URL。

Rails 5.1 使用 `form_with` 将这两个接口结合起来，并且可以根据URL、作用域或模型生成表单标签。

仅使用URL：

```erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 将生成 %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

添加作用域会给输入字段名称添加前缀：

```erb
<%= form_with scope: :post, url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 将生成 %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

使用模型会推断出URL和作用域：

```erb
<%= form_with model: Post.new do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 将生成 %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

使用现有模型会生成更新表单并填充字段值：

```erb
<%= form_with model: Post.first do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 将生成 %>

<form action="/posts/1" method="post" data-remote="true">
  <input type="hidden" name="_method" value="patch">
  <input type="text" name="post[title]" value="<帖子的标题>">
</form>
```
不兼容性
-----------------

以下更改可能需要升级后立即采取行动。

### 使用多个连接的事务测试

事务测试现在将所有Active Record连接包装在数据库事务中。

当一个测试生成额外的线程，并且这些线程获取数据库连接时，这些连接现在会被特殊处理：

这些线程将共享一个连接，该连接位于受控事务内部。这确保所有线程在相同的数据库状态下查看数据库，忽略最外层的事务。以前，这样的额外连接无法看到fixture行，例如。

当一个线程进入嵌套事务时，它将暂时独占连接，以保持隔离。

如果您的测试当前依赖于在生成的线程中获取一个单独的、不在事务中的连接，您需要切换到更明确的连接管理。

如果您的测试生成线程并且这些线程在使用显式数据库事务时进行交互，此更改可能会引入死锁。

退出此新行为的简单方法是在受影响的测试用例上禁用事务测试。

Railties
--------

请参考[Changelog][railties]以获取详细的更改信息。

### 删除

*   删除已弃用的`config.static_cache_control`。
    ([commit](https://github.com/rails/rails/commit/c861decd44198f8d7d774ee6a74194d1ac1a5a13))

*   删除已弃用的`config.serve_static_files`。
    ([commit](https://github.com/rails/rails/commit/0129ca2eeb6d5b2ea8c6e6be38eeb770fe45f1fa))

*   删除已弃用的文件`rails/rack/debugger`。
    ([commit](https://github.com/rails/rails/commit/7563bf7b46e6f04e160d664e284a33052f9804b8))

*   删除已弃用的任务：`rails:update`，`rails:template`，`rails:template:copy`，
    `rails:update:configs`和`rails:update:bin`。
    ([commit](https://github.com/rails/rails/commit/f7782812f7e727178e4a743aa2874c078b722eef))

*   删除`routes`任务的已弃用的`CONTROLLER`环境变量。
    ([commit](https://github.com/rails/rails/commit/f9ed83321ac1d1902578a0aacdfe55d3db754219))

*   从`rails new`命令中删除了-j（--javascript）选项。
    ([Pull Request](https://github.com/rails/rails/pull/28546))

### 显著更改

*   在`config/secrets.yml`中添加了一个共享部分，将在所有环境中加载。
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   现在使用所有键作为符号加载配置文件`config/secrets.yml`。
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   从默认堆栈中删除了jquery-rails。默认的UJS适配器是随Action View一起提供的rails-ujs。
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   在新应用程序中添加了对Yarn的支持，包括yarn binstub和package.json。
    ([Pull Request](https://github.com/rails/rails/pull/26836))
* 通过 `--webpack` 选项在新应用中添加 Webpack 支持，该选项将委托给 rails/webpacker gem。
    ([Pull Request](https://github.com/rails/rails/pull/27288))

* 在生成新应用时初始化 Git 仓库，如果未提供 `--skip-git` 选项。
    ([Pull Request](https://github.com/rails/rails/pull/27632))

* 在 `config/secrets.yml.enc` 中添加加密的 secrets。
    ([Pull Request](https://github.com/rails/rails/pull/28038))

* 在 `rails initializers` 中显示 railtie 类名。
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

详细更改请参阅[Changelog][action-cable]。

### 主要更改

* 在 `cable.yml` 中为 Redis 和事件驱动的 Redis 适配器添加对 `channel_prefix` 的支持，以避免在多个应用程序中使用相同的 Redis 服务器时发生名称冲突。
    ([Pull Request](https://github.com/rails/rails/pull/27425))

* 为广播数据添加 `ActiveSupport::Notifications` 钩子。
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

详细更改请参阅[Changelog][action-pack]。

### 移除

* 在 `ActionDispatch::IntegrationTest` 和 `ActionController::TestCase` 类中移除对 `#process`、`#get`、`#post`、`#patch`、`#put`、`#delete` 和 `#head` 的非关键字参数的支持。
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

* 移除已弃用的 `ActionDispatch::Callbacks.to_prepare` 和 `ActionDispatch::Callbacks.to_cleanup`。
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

* 移除与控制器过滤器相关的已弃用方法。
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

* 移除在 `render` 中对 `:text` 和 `:nothing` 的已弃用支持。
    ([Commit](https://github.com/rails/rails/commit/79a5ea9eadb4d43b62afacedc0706cbe88c54496),
    [Commit](https://github.com/rails/rails/commit/57e1c99a280bdc1b324936a690350320a1cd8111))

* 移除在 `ActionController::Parameters` 上调用 `HashWithIndifferentAccess` 方法的已弃用支持。
    ([Commit](https://github.com/rails/rails/pull/26746/commits/7093ceb480ad6a0a91b511832dad4c6a86981b93))

### 弃用

* 弃用 `config.action_controller.raise_on_unfiltered_parameters`。在 Rails 5.1 中没有任何效果。
    ([Commit](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### 主要更改

* 在路由 DSL 中添加 `direct` 和 `resolve` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/23138))

* 添加新的 `ActionDispatch::SystemTestCase` 类，用于在应用程序中编写系统测试。
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

详细更改请参阅[Changelog][action-view]。

### 移除

* 移除在 `ActionView::Template::Error` 中的已弃用的 `#original_exception`。
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

* 从 `strip_tags` 中删除 `encode_special_chars` 选项的误导。
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### 弃用

* 弃用 Erubis ERB 处理程序，改用 Erubi。
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### 主要更改

* 原始模板处理程序（在 Rails 5 中的默认模板处理程序）现在输出 HTML 安全字符串。
    ([commit](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

* 将 `datetime_field` 和 `datetime_field_tag` 更改为生成 `datetime-local` 字段。
    ([Pull Request](https://github.com/rails/rails/pull/25469))

* HTML 标签的新 Builder 风格语法（`tag.div`、`tag.br` 等）。
    ([Pull Request](https://github.com/rails/rails/pull/25543))
*   添加`form_with`以统一`form_tag`和`form_for`的用法。
    ([Pull Request](https://github.com/rails/rails/pull/26976))

*   在`current_page?`中添加`check_parameters`选项。
    ([Pull Request](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

详细更改请参考[Changelog][action-mailer]。

### 主要更改

*   允许在包含附件并且正文设置为内联时设置自定义内容类型。
    ([Pull Request](https://github.com/rails/rails/pull/27227))

*   允许将lambda作为`default`方法的值传递。
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   添加对邮件发送器进行参数化调用的支持，以共享前置过滤器和默认值。
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   将传入的参数传递给邮件发送器动作的`process.action_mailer`事件，放在`args`键下。
    ([Pull Request](https://github.com/rails/rails/pull/27900))

Active Record
-------------

详细更改请参考[Changelog][active-record]。

### 移除

*   移除将参数和块同时传递给`ActiveRecord::QueryMethods#select`的支持。
    ([Commit](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

*   移除已弃用的`activerecord.errors.messages.restrict_dependent_destroy.one`和
    `activerecord.errors.messages.restrict_dependent_destroy.many`的i18n范围。
    ([Commit](https://github.com/rails/rails/commit/00e3973a311))

*   移除单数和集合关联读取器中已弃用的强制重新加载参数。
    ([Commit](https://github.com/rails/rails/commit/09cac8c67af))

*   移除从`#quote`中传递列的已弃用支持。
    ([Commit](https://github.com/rails/rails/commit/e646bad5b7c))

*   移除从`#tables`中的`name`参数。
    ([Commit](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

*   移除`#tables`和`#table_exists?`的已弃用行为，只返回表而不返回视图。
    ([Commit](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

*   移除`ActiveRecord::StatementInvalid#initialize`和`ActiveRecord::StatementInvalid#original_exception`中已弃用的`original_exception`参数。
    ([Commit](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

*   移除在查询中将类作为值传递的已弃用支持。
    ([Commit](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

*   移除使用逗号进行LIMIT查询的已弃用支持。
    ([Commit](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

*   移除`#destroy_all`中的`conditions`参数。
    ([Commit](https://github.com/rails/rails/commit/d31a6d1384cd740c8518d0bf695b550d2a3a4e9b))

*   移除`#delete_all`中的`conditions`参数。
    ([Commit](https://github.com/rails/rails/pull/27503/commits/e7381d289e4f8751dcec9553dcb4d32153bd922b))

*   移除`#load_schema_for`方法，改用`#load_schema`。
    ([Commit](https://github.com/rails/rails/commit/419e06b56c3b0229f0c72d3e4cdf59d34d8e5545))

*   移除`#raise_in_transactional_callbacks`配置。
    ([Commit](https://github.com/rails/rails/commit/8029f779b8a1dd9848fee0b7967c2e0849bf6e07))

*   移除`#use_transactional_fixtures`配置。
    ([Commit](https://github.com/rails/rails/commit/3955218dc163f61c932ee80af525e7cd440514b3))

### 弃用

*   弃用`error_on_ignored_order_or_limit`标志，改用`error_on_ignored_order`。
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   弃用`sanitize_conditions`，改用`sanitize_sql`。
    ([Pull Request](https://github.com/rails/rails/pull/25999))

*   弃用连接适配器上的`supports_migrations?`。
    ([Pull Request](https://github.com/rails/rails/pull/28172))

*   弃用`Migrator.schema_migrations_table_name`，改用`SchemaMigration.table_name`。
    ([Pull Request](https://github.com/rails/rails/pull/28351))

*   弃用在引号和类型转换中使用`#quoted_id`。
    ([Pull Request](https://github.com/rails/rails/pull/27962))
*   弃用将`default`参数传递给`#index_name_exists?`方法。
    ([拉取请求](https://github.com/rails/rails/pull/26930))

### 显著变化

*   将默认主键更改为BIGINT。
    ([拉取请求](https://github.com/rails/rails/pull/26266))

*   支持MySQL 5.7.5+和MariaDB 5.2.0+的虚拟/生成列。
    ([提交](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

*   在批处理中添加对限制的支持。
    ([提交](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   事务测试现在将所有Active Record连接包装在数据库事务中。
    ([拉取请求](https://github.com/rails/rails/pull/28726))

*   默认情况下跳过`mysqldump`命令输出中的注释。
    ([拉取请求](https://github.com/rails/rails/pull/23301))

*   修复`ActiveRecord::Relation#count`方法，当传递一个块作为参数时，使用Ruby的`Enumerable#count`方法进行计数，而不是静默忽略传递的块。
    ([拉取请求](https://github.com/rails/rails/pull/24203))

*   在`psql`命令中传递`"-v ON_ERROR_STOP=1"`标志，以不抑制SQL错误。
    ([拉取请求](https://github.com/rails/rails/pull/24773))

*   添加`ActiveRecord::Base.connection_pool.stat`方法。
    ([拉取请求](https://github.com/rails/rails/pull/26988))

*   直接从`ActiveRecord::Migration`继承将引发错误。指定编写迁移的Rails版本。
    ([提交](https://github.com/rails/rails/commit/249f71a22ab21c03915da5606a063d321f04d4d3))

*   当`through`关联具有模糊的反射名称时，将引发错误。
    ([提交](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

请参阅[更改日志][active-model]以获取详细的更改信息。

### 移除

*   移除了`ActiveModel::Errors`中的弃用方法。
    ([提交](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

*   移除了长度验证器中弃用的`:tokenizer`选项。
    ([提交](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

*   移除了当返回值为false时中止回调的弃用行为。
    ([提交](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### 显著变化

*   不再错误地冻结分配给模型属性的原始字符串。
    ([拉取请求](https://github.com/rails/rails/pull/28729))

Active Job
-----------

请参阅[更改日志][active-job]以获取详细的更改信息。

### 移除

*   移除了将适配器类传递给`.queue_adapter`方法的弃用支持。
    ([提交](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   移除了`ActiveJob::DeserializationError`中的弃用`#original_exception`方法。
    ([提交](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### 显著变化

*   通过`ActiveJob::Base.retry_on`和`ActiveJob::Base.discard_on`添加声明式异常处理。
    ([拉取请求](https://github.com/rails/rails/pull/25991))

*   在重试失败后的自定义逻辑中，提供作业实例以便访问诸如`job.arguments`之类的内容。
    ([提交](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

Active Support
--------------

请参阅[更改日志][active-support]以获取详细的更改信息。

### 移除

*   移除了`ActiveSupport::Concurrency::Latch`类。
    ([提交](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   移除了`halt_callback_chains_on_return_false`。
    ([提交](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))

*   移除了当返回值为false时中止回调的弃用行为。
    ([提交](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))
### 弃用

*   顶级`HashWithIndifferentAccess`类已被软弃用，推荐使用`ActiveSupport::HashWithIndifferentAccess`类。
    ([拉取请求](https://github.com/rails/rails/pull/28157))

*   弃用在`set_callback`和`skip_callback`的`:if`和`:unless`条件选项中传递字符串。
    ([提交](https://github.com/rails/rails/commit/0952552))

### 显著变化

*   修复了持续时间解析和旅行，使其在夏令时变化时保持一致。
    ([提交](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [拉取请求](https://github.com/rails/rails/pull/26597))

*   更新Unicode到版本9.0.0。
    ([拉取请求](https://github.com/rails/rails/pull/27822))

*   添加了`Duration#before`和`#after`作为`#ago`和`#since`的别名。
    ([拉取请求](https://github.com/rails/rails/pull/27721))

*   添加了`Module#delegate_missing_to`，将当前对象未定义的方法调用委托给代理对象。
    ([拉取请求](https://github.com/rails/rails/pull/23930))

*   添加了`Date#all_day`，返回表示当前日期和时间的整天范围。
    ([拉取请求](https://github.com/rails/rails/pull/24930))

*   引入了`assert_changes`和`assert_no_changes`方法用于测试。
    ([拉取请求](https://github.com/rails/rails/pull/25393))

*   `travel`和`travel_to`方法现在在嵌套调用时会引发异常。
    ([拉取请求](https://github.com/rails/rails/pull/24890))

*   更新`DateTime#change`以支持usec和nsec。
    ([拉取请求](https://github.com/rails/rails/pull/28242))

致谢
-------

请参阅[Rails的完整贡献者列表](https://contributors.rubyonrails.org/)，感谢所有为Rails付出了许多时间的人，使其成为一个稳定和强大的框架。向他们致敬。

[railties]:       https://github.com/rails/rails/blob/5-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-1-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
