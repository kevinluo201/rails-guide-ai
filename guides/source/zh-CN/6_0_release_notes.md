**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b1c2c8ad5c4bacb2e3b92aa320c4da3d
Ruby on Rails 6.0 发布说明
===============================

Rails 6.0 的亮点：

* Action Mailbox
* Action Text
* 并行测试
* Action Cable 测试

这些发布说明仅涵盖了主要更改。要了解各种错误修复和更改，请参考更改日志或查看 GitHub 上 Rails 主存储库中的[提交列表](https://github.com/rails/rails/commits/6-0-stable)。

--------------------------------------------------------------------------------

升级到 Rails 6.0
----------------------

如果您正在升级现有应用程序，建议在进行升级之前进行充分的测试覆盖。如果您还没有升级到 Rails 5.2，请先升级到 Rails 5.2，并确保您的应用程序在升级到 Rails 6.0 之前仍然正常运行。在升级时需要注意的事项列表，请参考[升级 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-2-to-rails-6-0)指南。

主要功能
--------------

### Action Mailbox

[拉取请求](https://github.com/rails/rails/pull/34786)

[Action Mailbox](https://github.com/rails/rails/tree/6-0-stable/actionmailbox) 允许您将传入的电子邮件路由到类似控制器的邮箱中。
您可以在[Action Mailbox 基础知识](action_mailbox_basics.html)指南中了解更多关于 Action Mailbox 的信息。

### Action Text

[拉取请求](https://github.com/rails/rails/pull/34873)

[Action Text](https://github.com/rails/rails/tree/6-0-stable/actiontext)
为 Rails 带来了丰富的文本内容和编辑功能。它包括了[Trix 编辑器](https://trix-editor.org)，该编辑器可以处理从格式设置到链接、引用、列表、嵌入图像和图库等所有内容。Trix 编辑器生成的丰富文本内容保存在自己的 RichText 模型中，并与应用程序中的任何现有 Active Record 模型关联。任何嵌入的图像（或其他附件）都会自动使用 Active Storage 存储，并与包含的 RichText 模型关联。

您可以在[Action Text 概述](action_text_overview.html)指南中了解更多关于 Action Text 的信息。

### 并行测试

[拉取请求](https://github.com/rails/rails/pull/31900)

[并行测试](testing.html#parallel-testing)允许您并行运行测试套件。默认方法是使用进程分叉，也支持线程。并行运行测试可以减少整个测试套件运行所需的时间。

### Action Cable 测试

[拉取请求](https://github.com/rails/rails/pull/33659)

[Action Cable 测试工具](testing.html#testing-action-cable)允许您在任何级别测试 Action Cable 的功能：连接、频道、广播。

Railties
--------

详细更改请参考[更改日志][railties]。

### 删除

*   删除插件模板中已弃用的 `after_bundle` 辅助方法。
    ([提交](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

*   删除使用应用程序类作为 `run` 方法参数的 `config.ru` 的已弃用支持。
    ([提交](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))

*   删除 rails 命令中已弃用的 `environment` 参数。
    ([提交](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

*   删除生成器和模板中已弃用的 `capify!` 方法。
    ([提交](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

*   删除已弃用的 `config.secret_token`。
    ([提交](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### 弃用

*   弃用将 Rack 服务器名称作为常规参数传递给 `rails server` 的支持。
    ([拉取请求](https://github.com/rails/rails/pull/32058))

*   弃用使用 `HOST` 环境变量指定服务器 IP 的支持。
    ([拉取请求](https://github.com/rails/rails/pull/32540))

*   弃用通过非符号键访问 `config_for` 返回的哈希。
    ([拉取请求](https://github.com/rails/rails/pull/35198))

### 显著更改

*   为 `rails server` 命令添加显式选项 `--using` 或 `-u`，用于指定服务器。
    ([拉取请求](https://github.com/rails/rails/pull/32058))

*   添加查看 `rails routes` 输出的扩展格式的功能。
    ([拉取请求](https://github.com/rails/rails/pull/32130))

*   使用内联 Active Job 适配器运行种子数据库任务。
    ([拉取请求](https://github.com/rails/rails/pull/34953))

*   添加 `rails db:system:change` 命令以更改应用程序的数据库。
    ([拉取请求](https://github.com/rails/rails/pull/34832))

*   添加 `rails test:channels` 命令，仅测试 Action Cable 频道。
    ([拉取请求](https://github.com/rails/rails/pull/34947))
*   引入防止DNS重绑定攻击的保护措施。
    ([拉取请求](https://github.com/rails/rails/pull/33145))

*   在运行生成器命令时添加失败时中止的能力。
    ([拉取请求](https://github.com/rails/rails/pull/34420))

*   将Webpacker作为Rails 6的默认JavaScript编译器。
    ([拉取请求](https://github.com/rails/rails/pull/33079))

*   为`rails db:migrate:status`命令添加对多个数据库的支持。
    ([拉取请求](https://github.com/rails/rails/pull/34137))

*   在生成器中添加对多个数据库使用不同迁移路径的能力。
    ([拉取请求](https://github.com/rails/rails/pull/34021))

*   添加对多环境凭证的支持。
    ([拉取请求](https://github.com/rails/rails/pull/33521))

*   在测试环境中将`null_store`作为默认缓存存储。
    ([拉取请求](https://github.com/rails/rails/pull/33773))

Action Cable
------------

详细更改请参阅[更新日志][action-cable]。

### 移除

*   用`ActionCable.logger.enabled`替换`ActionCable.startDebugging()`和`ActionCable.stopDebugging()`。
    ([拉取请求](https://github.com/rails/rails/pull/34370))

### 弃用

*   Rails 6.0中的Action Cable没有任何弃用。

### 显著更改

*   在`cable.yml`中为PostgreSQL订阅适配器添加`channel_prefix`选项的支持。
    ([拉取请求](https://github.com/rails/rails/pull/35276))

*   允许向`ActionCable::Server::Base`传递自定义配置。
    ([拉取请求](https://github.com/rails/rails/pull/34714))

*   添加`：action_cable_connection`和`：action_cable_channel`加载钩子。
    ([拉取请求](https://github.com/rails/rails/pull/35094))

*   添加`Channel::Base#broadcast_to`和`Channel::Base.broadcasting_for`。
    ([拉取请求](https://github.com/rails/rails/pull/35021))

*   在从`ActionCable::Connection`调用`reject_unauthorized_connection`时关闭连接。
    ([拉取请求](https://github.com/rails/rails/pull/34194))

*   将Action Cable JavaScript包从CoffeeScript转换为ES2015，并在npm分发中发布源代码。
    ([拉取请求](https://github.com/rails/rails/pull/34370))

*   将WebSocket适配器和日志记录器适配器的配置从`ActionCable`的属性移动到`ActionCable.adapters`中。
    ([拉取请求](https://github.com/rails/rails/pull/34370))

*   为Redis适配器添加`id`选项以区分Action Cable的Redis连接。
    ([拉取请求](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

详细更改请参阅[更新日志][action-pack]。

### 移除

*   删除已弃用的`fragment_cache_key`辅助方法，改用`combined_fragment_cache_key`。
    ([提交](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

*   删除`ActionDispatch::TestResponse`中已弃用的方法：
    `#success?`改用`#successful?`，`#missing?`改用`#not_found?`，
    `#error?`改用`#server_error?`。
    ([提交](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### 弃用

*   弃用`ActionDispatch::Http::ParameterFilter`，改用`ActiveSupport::ParameterFilter`。
    ([拉取请求](https://github.com/rails/rails/pull/34039))

*   弃用控制器级别的`force_ssl`，改用`config.force_ssl`。
    ([拉取请求](https://github.com/rails/rails/pull/32277))

### 显著更改

*   更改`ActionDispatch::Response#content_type`返回Content-Type头。
    ([拉取请求](https://github.com/rails/rails/pull/36034))

*   如果资源参数包含冒号，则引发`ArgumentError`。
    ([拉取请求](https://github.com/rails/rails/pull/35236))

*   允许使用块来定义特定浏览器功能的`ActionDispatch::SystemTestCase.driven_by`。
    ([拉取请求](https://github.com/rails/rails/pull/35081))

*   在`ActionDispatch::HostAuthorization`中添加防止DNS重绑定攻击的中间件。
    ([拉取请求](https://github.com/rails/rails/pull/33145))

*   允许在`ActionController::TestCase`中使用`parsed_body`。
    ([拉取请求](https://github.com/rails/rails/pull/34717))

*   当在同一上下文中存在多个根路由且没有`as:`命名规范时，引发`ArgumentError`。
    ([拉取请求](https://github.com/rails/rails/pull/34494))

*   允许使用`#rescue_from`处理参数解析错误。
    ([拉取请求](https://github.com/rails/rails/pull/34341))

*   为遍历参数添加`ActionController::Parameters#each_value`。
    ([拉取请求](https://github.com/rails/rails/pull/33979))

*   在`send_data`和`send_file`中对Content-Disposition文件名进行编码。
    ([拉取请求](https://github.com/rails/rails/pull/33829))

*   公开`ActionController::Parameters#each_key`。
    ([拉取请求](https://github.com/rails/rails/pull/33758))

*   在签名/加密cookie中添加目的和过期元数据，以防止将cookie的值复制到另一个cookie中。
    ([拉取请求](https://github.com/rails/rails/pull/32937))

*   对于冲突的`respond_to`调用，引发`ActionController::RespondToMismatchError`。
    ([拉取请求](https://github.com/rails/rails/pull/33446))

*   为请求格式缺少模板添加一个显式的错误页面。
    ([拉取请求](https://github.com/rails/rails/pull/29286))

*   引入`ActionDispatch::DebugExceptions.register_interceptor`，一种在渲染之前处理异常的方法。
    ([拉取请求](https://github.com/rails/rails/pull/23868))

*   每个请求只输出一个Content-Security-Policy nonce头值。
    ([拉取请求](https://github.com/rails/rails/pull/32602))

*   添加一个专门用于Rails默认头部配置的模块，可以明确地包含在控制器中。
    ([拉取请求](https://github.com/rails/rails/pull/32484))

[action-cable]: https://github.com/rails/rails/blob/master/actioncable/CHANGELOG.md
[action-pack]: https://github.com/rails/rails/blob/master/actionpack/CHANGELOG.md
* 将`#dig`添加到`ActionDispatch::Request::Session`中。
    ([Pull Request](https://github.com/rails/rails/pull/32446))

Action View
-----------

请参考[Changelog][action-view]以获取详细的更改信息。

### 移除

* 移除已弃用的`image_alt`辅助方法。
    ([Commit](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f))

* 从`record_tag_helper` gem中移除空的`RecordTagHelper`模块。
    ([Commit](https://github.com/rails/rails/commit/5c5ddd69b1e06fb6b2bcbb021e9b8dae17e7cb31))

### 弃用

* 弃用`ActionView::Template.finalize_compiled_template_methods`，无替代方法。
    ([Pull Request](https://github.com/rails/rails/pull/35036))

* 弃用`config.action_view.finalize_compiled_template_methods`，无替代方法。
    ([Pull Request](https://github.com/rails/rails/pull/35036))

* 弃用从`options_from_collection_for_select`视图助手调用私有模型方法。
    ([Pull Request](https://github.com/rails/rails/pull/33547))

### 显著更改

* 在开发模式下，只在文件更改时清除Action View缓存，加快开发模式。
    ([Pull Request](https://github.com/rails/rails/pull/35629))

* 将所有的Rails npm包移动到`@rails`作用域下。
    ([Pull Request](https://github.com/rails/rails/pull/34905))

* 仅接受已注册MIME类型的格式。
    ([Pull Request](https://github.com/rails/rails/pull/35604), [Pull Request](https://github.com/rails/rails/pull/35753))

* 在模板和局部渲染服务器输出中添加分配。
    ([Pull Request](https://github.com/rails/rails/pull/34136))

* 为`date_select`标签添加`year_format`选项，使年份名称可自定义。
    ([Pull Request](https://github.com/rails/rails/pull/32190))

* 为`javascript_include_tag`辅助方法添加`nonce: true`选项，支持自动生成Content Security Policy的nonce。
    ([Pull Request](https://github.com/rails/rails/pull/32607))

* 添加`action_view.finalize_compiled_template_methods`配置，用于禁用或启用`ActionView::Template`的最终器。
    ([Pull Request](https://github.com/rails/rails/pull/32418))

* 将JavaScript的`confirm`调用提取到`rails_ujs`中，以便可以重写。
    ([Pull Request](https://github.com/rails/rails/pull/32404))

* 添加`action_controller.default_enforce_utf8`配置选项，用于处理强制使用UTF-8编码。默认为`false`。
    ([Pull Request](https://github.com/rails/rails/pull/32125))

* 为本地化键的提交标签添加I18n键样式支持。
    ([Pull Request](https://github.com/rails/rails/pull/26799))

Action Mailer
-------------

请参考[Changelog][action-mailer]以获取详细的更改信息。

### 移除

### 弃用

* 弃用`ActionMailer::Base.receive`，推荐使用Action Mailbox。
    ([Commit](https://github.com/rails/rails/commit/e3f832a7433a291a51c5df397dc3dd654c1858cb))

* 弃用`DeliveryJob`和`Parameterized::DeliveryJob`，推荐使用`MailDeliveryJob`。
    ([Pull Request](https://github.com/rails/rails/pull/34591))

### 显著更改

* 添加`MailDeliveryJob`，用于发送常规和参数化邮件。
    ([Pull Request](https://github.com/rails/rails/pull/34591))

* 允许自定义的电子邮件传递作业与Action Mailer测试断言一起使用。
    ([Pull Request](https://github.com/rails/rails/pull/34339))

* 允许在多部分邮件中使用块指定模板名称，而不仅仅使用动作名称。
    ([Pull Request](https://github.com/rails/rails/pull/22534))

* 在`deliver.action_mailer`通知的负载中添加`perform_deliveries`。
    ([Pull Request](https://github.com/rails/rails/pull/33824))

* 当`perform_deliveries`为false时，改进日志消息以指示跳过发送电子邮件。
    ([Pull Request](https://github.com/rails/rails/pull/33824))

* 允许在没有块的情况下调用`assert_enqueued_email_with`。
    ([Pull Request](https://github.com/rails/rails/pull/33258))

* 在`assert_emails`块中执行已入队的邮件传递作业。
    ([Pull Request](https://github.com/rails/rails/pull/32231))

* 允许`ActionMailer::Base`取消注册观察者和拦截器。
    ([Pull Request](https://github.com/rails/rails/pull/32207))

Active Record
-------------

请参考[Changelog][active-record]以获取详细的更改信息。

### 移除

* 从事务对象中移除已弃用的`#set_state`。
    ([Commit](https://github.com/rails/rails/commit/6c745b0c5152a4437163a67707e02f4464493983))

* 从数据库适配器中移除已弃用的`#supports_statement_cache?`。
    ([Commit](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553))

* 从数据库适配器中移除已弃用的`#insert_fixtures`。
    ([Commit](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece))

* 移除已弃用的`ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?`。
    ([Commit](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf))

* 当传递块时，移除对`sum`中的列名的支持。
    ([Commit](https://github.com/rails/rails/commit/91ddb30083430622188d76eb9f29b78131df67f9))

* 当传递块时，移除对`count`中的列名的支持。
    ([Commit](https://github.com/rails/rails/commit/67356f2034ab41305af7218f7c8b2fee2d614129))

* 移除将关系中的缺失方法委托给Arel的支持。
    ([Commit](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0))

* 移除将关系中的缺失方法委托给类的私有方法的支持。
    ([Commit](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d))

* 移除为`#cache_key`指定时间戳名称的支持。
    ([Commit](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea))

* 移除已弃用的`ActiveRecord::Migrator.migrations_path=`。
    ([Commit](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d))
*   移除已弃用的`expand_hash_conditions_for_aggregates`。
    ([提交记录](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e))


### 弃用

*   弃用不匹配大小写敏感性排序比较的唯一性验证器。
    ([提交记录](https://github.com/rails/rails/commit/9def05385f1cfa41924bb93daa187615e88c95b9))

*   如果接收器范围泄漏，弃用使用类级别的查询方法。
    ([拉取请求](https://github.com/rails/rails/pull/35280))

*   弃用`config.active_record.sqlite3.represent_boolean_as_integer`。
    ([提交记录](https://github.com/rails/rails/commit/f59b08119bc0c01a00561d38279b124abc82561b))

*   弃用将`migrations_paths`传递给`connection.assume_migrated_upto_version`。
    ([提交记录](https://github.com/rails/rails/commit/c1b14aded27e063ead32fa911aa53163d7cfc21a))

*   弃用`ActiveRecord::Result#to_hash`，改用`ActiveRecord::Result#to_a`。
    ([提交记录](https://github.com/rails/rails/commit/16510d609c601aa7d466809f3073ec3313e08937))

*   弃用`DatabaseLimits`中的方法：`column_name_length`、`table_name_length`、
    `columns_per_table`、`indexes_per_table`、`columns_per_multicolumn_index`、
    `sql_query_length`和`joins_per_query`。
    ([提交记录](https://github.com/rails/rails/commit/e0a1235f7df0fa193c7e299a5adee88db246b44f))

*   弃用`update_attributes`/`!`，改用`update`/`!`。
    ([提交记录](https://github.com/rails/rails/commit/5645149d3a27054450bd1130ff5715504638a5f5))

### 显著变化

*   将`sqlite3` gem的最低版本提升到1.4。
    ([拉取请求](https://github.com/rails/rails/pull/35844))

*   添加`rails db:prepare`以在数据库不存在时创建数据库并运行其迁移。
    ([拉取请求](https://github.com/rails/rails/pull/35768))

*   添加`after_save_commit`回调作为`after_commit :hook, on: [ :create, :update ]`的快捷方式。
    ([拉取请求](https://github.com/rails/rails/pull/35804))

*   添加`ActiveRecord::Relation#extract_associated`，用于从关系中提取关联记录。
    ([拉取请求](https://github.com/rails/rails/pull/35784))

*   添加`ActiveRecord::Relation#annotate`，用于向ActiveRecord::Relation查询添加SQL注释。
    ([拉取请求](https://github.com/rails/rails/pull/35617))

*   添加对数据库设置优化提示的支持。
    ([拉取请求](https://github.com/rails/rails/pull/35615))

*   添加`insert_all`/`insert_all!`/`upsert_all`方法以进行批量插入。
    ([拉取请求](https://github.com/rails/rails/pull/35631))

*   添加`rails db:seed:replant`，它会截断当前环境下每个数据库的表，并加载种子数据。
    ([拉取请求](https://github.com/rails/rails/pull/34779))

*   添加`reselect`方法，它是`unscope(:select).select(fields)`的简写形式。
    ([拉取请求](https://github.com/rails/rails/pull/33611))

*   为所有枚举值添加负面作用域。
    ([拉取请求](https://github.com/rails/rails/pull/35381))

*   添加`#destroy_by`和`#delete_by`以进行条件删除。
    ([拉取请求](https://github.com/rails/rails/pull/35316))

*   添加自动切换数据库连接的功能。
    ([拉取请求](https://github.com/rails/rails/pull/35073))

*   添加在代码块的执行期间禁止向数据库写入的功能。
    ([拉取请求](https://github.com/rails/rails/pull/34505))

*   添加支持多个数据库的连接切换API。
    ([拉取请求](https://github.com/rails/rails/pull/34052))

*   将具有精度的时间戳设置为迁移的默认值。
    ([拉取请求](https://github.com/rails/rails/pull/34970))

*   支持在MySQL中更改文本和blob大小的`:size`选项。
    ([拉取请求](https://github.com/rails/rails/pull/35071))

*   对于`dependent: :nullify`策略上的多态关联，将外键和外键类型列都设置为NULL。
    ([拉取请求](https://github.com/rails/rails/pull/28078))

*   允许将`ActionController::Parameters`的允许实例作为参数传递给`ActiveRecord::Relation#exists?`。
    ([拉取请求](https://github.com/rails/rails/pull/34891))

*   在`#where`中添加对Ruby 2.6引入的无限范围的支持。
    ([拉取请求](https://github.com/rails/rails/pull/34906))

*   将`ROW_FORMAT=DYNAMIC`设置为MySQL的默认创建表选项。
    ([拉取请求](https://github.com/rails/rails/pull/34742))

*   添加在`ActiveRecord.enum`生成的作用域中禁用作用域的能力。
    ([拉取请求](https://github.com/rails/rails/pull/34605))

*   使隐式排序可配置为某一列。
    ([拉取请求](https://github.com/rails/rails/pull/34480))

*   将最低的PostgreSQL版本提升到9.3，不再支持9.1和9.2。
    ([拉取请求](https://github.com/rails/rails/pull/34520))

*   使枚举的值为不可修改的，尝试修改时会引发错误。
    ([拉取请求](https://github.com/rails/rails/pull/34517))

*   将`ActiveRecord::StatementInvalid`错误的SQL作为自己的错误属性，
    并将SQL绑定作为单独的错误属性包含在内。
    ([拉取请求](https://github.com/rails/rails/pull/34468))

*   在`create_table`中添加`if_not_exists`选项。
    ([拉取请求](https://github.com/rails/rails/pull/31382))

*   为`rails db:schema:cache:dump`和`rails db:schema:cache:clear`添加对多个数据库的支持。
    ([拉取请求](https://github.com/rails/rails/pull/34181))

*   在`ActiveRecord::Base.connected_to`的数据库哈希中添加对哈希和URL配置的支持。
    ([拉取请求](https://github.com/rails/rails/pull/34196))

*   为MySQL添加默认表达式和表达式索引的支持。
    ([拉取请求](https://github.com/rails/rails/pull/34307))

*   为`change_table`迁移助手添加`index`选项。
    ([拉取请求](https://github.com/rails/rails/pull/23593))

*   修复迁移中`transaction`的还原。之前，在还原的迁移中的`transaction`内部运行的命令是未还原的。此更改修复了这个问题。
    ([拉取请求](https://github.com/rails/rails/pull/31604))
* 允许使用符号化哈希设置`ActiveRecord::Base.configurations=`
    ([Pull Request](https://github.com/rails/rails/pull/33968))

* 修复计数缓存只有在记录实际保存时才更新
    ([Pull Request](https://github.com/rails/rails/pull/33913))

* 为SQLite适配器添加表达式索引支持
    ([Pull Request](https://github.com/rails/rails/pull/33874))

* 允许子类重新定义关联记录的自动保存回调
    ([Pull Request](https://github.com/rails/rails/pull/33378))

* 将最低MySQL版本提升至5.5.8
    ([Pull Request](https://github.com/rails/rails/pull/33853))

* 默认在MySQL中使用utf8mb4字符集
    ([Pull Request](https://github.com/rails/rails/pull/33608))

* 添加在`#inspect`中过滤敏感数据的能力
    ([Pull Request](https://github.com/rails/rails/pull/33756), [Pull Request](https://github.com/rails/rails/pull/34208))

* 将`ActiveRecord::Base.configurations`更改为返回对象而不是哈希
    ([Pull Request](https://github.com/rails/rails/pull/33637))

* 添加数据库配置以禁用咨询锁
    ([Pull Request](https://github.com/rails/rails/pull/33691))

* 更新SQLite3适配器的`alter_table`方法以恢复外键
    ([Pull Request](https://github.com/rails/rails/pull/33585))

* 允许`remove_foreign_key`的`to_table`选项可逆
    ([Pull Request](https://github.com/rails/rails/pull/33530))

* 修复指定精度的MySQL时间类型的默认值
    ([Pull Request](https://github.com/rails/rails/pull/33280))

* 修复`touch`选项与`Persistence#touch`方法一致的行为
    ([Pull Request](https://github.com/rails/rails/pull/33107))

* 在迁移中对重复的列定义引发异常
    ([Pull Request](https://github.com/rails/rails/pull/33029))

* 将最低SQLite版本提升至3.8
    ([Pull Request](https://github.com/rails/rails/pull/32923))

* 修复父记录不会保存重复的子记录
    ([Pull Request](https://github.com/rails/rails/pull/32952))

* 如果存在加载的关联id，则确保`Associations::CollectionAssociation#size`和`Associations::CollectionAssociation#empty?`使用它们
    ([Pull Request](https://github.com/rails/rails/pull/32617))

* 添加支持在不是所有记录都具有所请求的关联时预加载多态关联的关联
    ([Commit](https://github.com/rails/rails/commit/75ef18c67c29b1b51314b6c8a963cee53394080b))

* 在`ActiveRecord::Relation`中添加`touch_all`方法
    ([Pull Request](https://github.com/rails/rails/pull/31513))

* 添加`ActiveRecord::Base.base_class?`谓词
    ([Pull Request](https://github.com/rails/rails/pull/32417))

* 为`ActiveRecord::Store.store_accessor`添加自定义前缀/后缀选项
    ([Pull Request](https://github.com/rails/rails/pull/32306))

* 添加`ActiveRecord::Base.create_or_find_by`/`!`以处理`ActiveRecord::Base.find_or_create_by`/`!`中的SELECT/INSERT竞争条件，依赖数据库中的唯一约束
    ([Pull Request](https://github.com/rails/rails/pull/31989))

* 添加`Relation#pick`作为单值pluck的简写
    ([Pull Request](https://github.com/rails/rails/pull/31941))

Active Storage
--------------

详细更改请参阅[Changelog][active-storage]。

### 移除

### 弃用

* 弃用`config.active_storage.queue`，改用`config.active_storage.queues.analysis`和`config.active_storage.queues.purge`
    ([Pull Request](https://github.com/rails/rails/pull/34838))

* 弃用`ActiveStorage::Downloading`，改用`ActiveStorage::Blob#open`
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

* 弃用直接使用`mini_magick`生成图像变体，改用`image_processing`
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

* 弃用在Active Storage的ImageProcessing转换器中使用`:combine_options`，没有替代方案
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

### 显著更改

* 添加支持生成BMP图像变体
    ([Pull Request](https://github.com/rails/rails/pull/36051))

* 添加支持生成TIFF图像变体
    ([Pull Request](https://github.com/rails/rails/pull/34824))

* 添加支持生成渐进式JPEG图像变体
    ([Pull Request](https://github.com/rails/rails/pull/34455))

* 添加`ActiveStorage.routes_prefix`用于配置Active Storage生成的路由
    ([Pull Request](https://github.com/rails/rails/pull/33883))

* 当磁盘服务中缺少请求的文件时，在`ActiveStorage::DiskController#show`上生成404 Not Found响应
    ([Pull Request](https://github.com/rails/rails/pull/33666))

* 当请求的文件对于`ActiveStorage::Blob#download`和`ActiveStorage::Blob#open`缺失时，引发`ActiveStorage::FileNotFoundError`
    ([Pull Request](https://github.com/rails/rails/pull/33666))

* 添加一个通用的`ActiveStorage::Error`类，Active Storage异常继承自该类
    ([Commit](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))

* 在保存记录时，将分配给记录的上传文件持久化到存储中，而不是立即持久化
    ([Pull Request](https://github.com/rails/rails/pull/33303))

* 在分配给附件集合时（如`@user.update!(images: [ … ])`），可选择替换现有文件而不是添加到它们中。使用`config.active_storage.replace_on_assign_to_many`来控制此行为
    ([Pull Request](https://github.com/rails/rails/pull/33303),
     [Pull Request](https://github.com/rails/rails/pull/36716))

* 添加使用现有Active Record反射机制反射已定义的附件的能力
    ([Pull Request](https://github.com/rails/rails/pull/33018))
*   添加 `ActiveStorage::Blob#open` 方法，该方法将 Blob 下载到磁盘上的临时文件并返回该临时文件。
    ([提交记录](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   支持从 Google Cloud Storage 进行流式下载。需要 `google-cloud-storage` gem 的 1.11+ 版本。
    ([拉取请求](https://github.com/rails/rails/pull/32788))

*   使用 `image_processing` gem 来处理 Active Storage 的变体。这取代了直接使用 `mini_magick`。
    ([拉取请求](https://github.com/rails/rails/pull/32471))

Active Model
------------

详细更改请参阅[更新日志][active-model]。

### 移除

### 弃用

### 重要更改

*   添加配置选项以自定义 `ActiveModel::Errors#full_message` 的格式。
    ([拉取请求](https://github.com/rails/rails/pull/32956))

*   添加支持为 `has_secure_password` 配置属性名称。
    ([拉取请求](https://github.com/rails/rails/pull/26764))

*   添加 `#slice!` 方法到 `ActiveModel::Errors`。
    ([拉取请求](https://github.com/rails/rails/pull/34489))

*   添加 `ActiveModel::Errors#of_kind?` 方法以检查特定错误是否存在。
    ([拉取请求](https://github.com/rails/rails/pull/34866))

*   修复 `ActiveModel::Serializers::JSON#as_json` 方法在处理时间戳时的问题。
    ([拉取请求](https://github.com/rails/rails/pull/31503))

*   修复 numericality 验证器在除了 Active Record 之外仍然使用类型转换之前的值的问题。
    ([拉取请求](https://github.com/rails/rails/pull/33654))

*   通过在验证的两端都将其转换为 `BigDecimal` 来修复 `BigDecimal` 和 `Float` 的 numericality 相等性验证问题。
    ([拉取请求](https://github.com/rails/rails/pull/32852))

*   修复在转换多参数时间哈希时的年份值。
    ([拉取请求](https://github.com/rails/rails/pull/34990))

*   将布尔属性上的虚假布尔符号强制转换为 false。
    ([拉取请求](https://github.com/rails/rails/pull/35794))

*   在 `value_from_multiparameter_assignment` 中转换参数时，为 `ActiveModel::Type::Date` 返回正确的日期。
    ([拉取请求](https://github.com/rails/rails/pull/29651))

*   在获取错误翻译时，先回退到父区域设置，然后再回退到 `:errors` 命名空间。
    ([拉取请求](https://github.com/rails/rails/pull/35424))

Active Support
--------------

详细更改请参阅[更新日志][active-support]。

### 移除

*   移除 `Inflections` 中已弃用的 `#acronym_regex` 方法。
    ([提交记录](https://github.com/rails/rails/commit/0ce67d3cd6d1b7b9576b07fecae3dd5b422a5689))

*   移除 `Module#reachable?` 方法。
    ([提交记录](https://github.com/rails/rails/commit/6eb1d56a333fd2015610d31793ed6281acd66551))

*   移除没有任何替代的 `` Kernel#` ``。
    ([拉取请求](https://github.com/rails/rails/pull/31253))

### 弃用

*   弃用使用负整数参数的 `String#first` 和 `String#last` 方法。
    ([拉取请求](https://github.com/rails/rails/pull/33058))

*   弃用 `ActiveSupport::Multibyte::Unicode#downcase/upcase/swapcase` 方法，改用 `String#downcase/upcase/swapcase`。
    ([拉取请求](https://github.com/rails/rails/pull/34123))

*   弃用 `ActiveSupport::Multibyte::Unicode#normalize` 和 `ActiveSupport::Multibyte::Chars#normalize` 方法，改用 `String#unicode_normalize`。
    ([拉取请求](https://github.com/rails/rails/pull/34202))

*   弃用 `ActiveSupport::Multibyte::Chars.consumes?` 方法，改用 `String#is_utf8?`。
    ([拉取请求](https://github.com/rails/rails/pull/34215))

*   弃用 `ActiveSupport::Multibyte::Unicode#pack_graphemes(array)` 和 `ActiveSupport::Multibyte::Unicode#unpack_graphemes(string)` 方法，改用 `array.flatten.pack("U*")` 和 `string.scan(/\X/).map(&:codepoints)`。
    ([拉取请求](https://github.com/rails/rails/pull/34254))

### 重要更改

*   添加对并行测试的支持。
    ([拉取请求](https://github.com/rails/rails/pull/31900))

*   确保 `String#strip_heredoc` 保留字符串的冻结状态。
    ([拉取请求](https://github.com/rails/rails/pull/32037))

*   添加 `String#truncate_bytes` 方法，用于将字符串截断为最大字节大小，而不会破坏多字节字符或图形簇。
    ([拉取请求](https://github.com/rails/rails/pull/27319))

*   在 `delegate` 方法中添加 `private` 选项，以便委托给私有方法。该选项接受 `true/false` 作为值。
    ([拉取请求](https://github.com/rails/rails/pull/31944))

*   通过 I18n 支持为 `ActiveSupport::Inflector#ordinal` 和 `ActiveSupport::Inflector#ordinalize` 进行翻译。
    ([拉取请求](https://github.com/rails/rails/pull/32168))

*   在 `Date`、`DateTime`、`Time` 和 `TimeWithZone` 中添加 `before?` 和 `after?` 方法。
    ([拉取请求](https://github.com/rails/rails/pull/32185))

*   修复 `URI.unescape` 在混合 Unicode/转义字符输入时失败的 bug。
    ([拉取请求](https://github.com/rails/rails/pull/32183))

*   修复启用压缩时 `ActiveSupport::Cache` 导致存储大小大幅膨胀的 bug。
    ([拉取请求](https://github.com/rails/rails/pull/32539))

*   Redis 缓存存储：`delete_matched` 不再阻塞 Redis 服务器。
    ([拉取请求](https://github.com/rails/rails/pull/32614))

*   修复 `ActiveSupport::TimeZone.all` 在任何时区定义在 `ActiveSupport::TimeZone::MAPPING` 中的时区缺失时失败的 bug。
    ([拉取请求](https://github.com/rails/rails/pull/32613))

*   添加 `Enumerable#index_with` 方法，允许从可枚举对象中创建一个哈希，该哈希的值来自传递的块或默认参数。
    ([拉取请求](https://github.com/rails/rails/pull/32523))

*   允许 `Range#===` 和 `Range#cover?` 方法与 `Range` 参数一起使用。
    ([拉取请求](https://github.com/rails/rails/pull/32938))
* 在RedisCacheStore的`increment/decrement`操作中支持键过期。
    ([Pull Request](https://github.com/rails/rails/pull/33254))

* 在日志订阅事件中添加CPU时间、空闲时间和分配功能。
    ([Pull Request](https://github.com/rails/rails/pull/33449))

* 在Active Support通知系统中添加对事件对象的支持。
    ([Pull Request](https://github.com/rails/rails/pull/33451))

* 通过引入`ActiveSupport::Cache#fetch`的新选项`skip_nil`来支持不缓存`nil`条目。
    ([Pull Request](https://github.com/rails/rails/pull/25437))

* 添加`Array#extract!`方法，该方法删除并返回块返回true值的元素。
    ([Pull Request](https://github.com/rails/rails/pull/33137))

* 在切片后保持HTML安全字符串的安全性。
    ([Pull Request](https://github.com/rails/rails/pull/33808))

* 通过日志记录来跟踪常量自动加载的支持。
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

* 将`unfreeze_time`定义为`travel_back`的别名。
    ([Pull Request](https://github.com/rails/rails/pull/33813))

* 将`ActiveSupport::TaggedLogging.new`更改为返回新的日志记录器实例，而不是修改接收到的实例。
    ([Pull Request](https://github.com/rails/rails/pull/27792))

* 将`#delete_prefix`、`#delete_suffix`和`#unicode_normalize`方法视为非HTML安全方法。
    ([Pull Request](https://github.com/rails/rails/pull/33990))

* 修复`ActiveSupport::HashWithIndifferentAccess`的`#without`在使用符号参数时失败的错误。
    ([Pull Request](https://github.com/rails/rails/pull/34012))

* 将`Module#parent`、`Module#parents`和`Module#parent_name`重命名为`module_parent`、`module_parents`和`module_parent_name`。
    ([Pull Request](https://github.com/rails/rails/pull/34051))

* 添加`ActiveSupport::ParameterFilter`。
    ([Pull Request](https://github.com/rails/rails/pull/34039))

* 修复将浮点数添加到持续时间时，将持续时间四舍五入为整秒的错误。
    ([Pull Request](https://github.com/rails/rails/pull/34135))

* 在`ActiveSupport::HashWithIndifferentAccess`中将`#to_options`作为`#symbolize_keys`的别名。
    ([Pull Request](https://github.com/rails/rails/pull/34360))

* 如果Concern中多次包含相同的块，则不再引发异常。
    ([Pull Request](https://github.com/rails/rails/pull/34553))

* 保留传递给`ActiveSupport::CacheStore#fetch_multi`的键顺序。
    ([Pull Request](https://github.com/rails/rails/pull/34700))

* 修复`String#safe_constantize`对于大小写不正确的常量引用不抛出`LoadError`的问题。
    ([Pull Request](https://github.com/rails/rails/pull/34892))

* 添加`Hash#deep_transform_values`和`Hash#deep_transform_values!`。
    ([Commit](https://github.com/rails/rails/commit/b8dc06b8fdc16874160f61dcf58743fcc10e57db))

* 添加`ActiveSupport::HashWithIndifferentAccess#assoc`。
    ([Pull Request](https://github.com/rails/rails/pull/35080))

* 为`CurrentAttributes`添加`before_reset`回调，并将`after_reset`定义为`resets`的别名，以实现对称性。
    ([Pull Request](https://github.com/rails/rails/pull/35063))

* 修改`ActiveSupport::Notifications.unsubscribe`以正确处理正则表达式或其他多模式订阅者。
    ([Pull Request](https://github.com/rails/rails/pull/32861))

* 使用Zeitwerk添加新的自动加载机制。
    ([Commit](https://github.com/rails/rails/commit/e53430fa9af239e21e11548499d814f540d421e5))

* 添加`Array#including`和`Enumerable#including`，以便方便地扩大集合。
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

* 将`Array#without`和`Enumerable#without`重命名为`Array#excluding`和`Enumerable#excluding`。旧的方法名保留为别名。
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

* 添加对`transliterate`和`parameterize`提供`locale`的支持。
    ([Pull Request](https://github.com/rails/rails/pull/35571))

* 修复`Time#advance`在1001-03-07之前的日期上的工作问题。
    ([Pull Request](https://github.com/rails/rails/pull/35659))

* 更新`ActiveSupport::Notifications::Instrumenter#instrument`以允许不传递块。
    ([Pull Request](https://github.com/rails/rails/pull/35705))

* 在后代跟踪器中使用弱引用，以允许匿名子类被垃圾回收。
    ([Pull Request](https://github.com/rails/rails/pull/31442))

* 使用`with_info_handler`方法调用测试方法，以使minitest-hooks插件正常工作。
    ([Commit](https://github.com/rails/rails/commit/758ba117a008b6ea2d3b92c53b6a7a8d7ccbca69))

* 在`ActiveSupport::SafeBuffer#*`上保留`html_safe?`状态。
    ([Pull Request](https://github.com/rails/rails/pull/36012))

Active Job
----------

详细更改请参阅[Changelog][active-job]。

### 删除

* 移除对Qu gem的支持。
    ([Pull Request](https://github.com/rails/rails/pull/32300))

### 弃用

### 重要更改

* 为Active Job参数添加自定义序列化器的支持。
    ([Pull Request](https://github.com/rails/rails/pull/30941))

* 添加对在排队时使用的时区执行Active Jobs的支持。
    ([Pull Request](https://github.com/rails/rails/pull/32085))

* 允许将多个异常传递给`retry_on`/`discard_on`。
    ([Commit](https://github.com/rails/rails/commit/3110caecbebdad7300daaf26bfdff39efda99e25))

* 允许在没有块的情况下调用`assert_enqueued_with`和`assert_enqueued_email_with`。
    ([Pull Request](https://github.com/rails/rails/pull/33258))

* 将`enqueue`和`enqueue_at`的通知包装在`around_enqueue`回调中，而不是`after_enqueue`回调中。
    ([Pull Request](https://github.com/rails/rails/pull/33171))

* 允许在没有块的情况下调用`perform_enqueued_jobs`。
    ([Pull Request](https://github.com/rails/rails/pull/33626))

* 允许在没有块的情况下调用`assert_performed_with`。
    ([Pull Request](https://github.com/rails/rails/pull/33635))
*   在作业断言和辅助函数中添加`:queue`选项。
    ([拉取请求](https://github.com/rails/rails/pull/33635))

*   在Active Job中添加重试和丢弃的钩子。
    ([拉取请求](https://github.com/rails/rails/pull/33751))

*   添加一种在执行作业时测试参数子集的方法。
    ([拉取请求](https://github.com/rails/rails/pull/33995))

*   在Active Job测试辅助函数返回的作业中包含反序列化的参数。
    ([拉取请求](https://github.com/rails/rails/pull/34204))

*   允许Active Job断言辅助函数接受`only`关键字的Proc。
    ([拉取请求](https://github.com/rails/rails/pull/34339))

*   在断言辅助函数中从作业参数中删除微秒和纳秒。
    ([拉取请求](https://github.com/rails/rails/pull/35713))

Ruby on Rails指南
--------------------

请参考[变更日志][guides]以获取详细的更改信息。

### 显著变更

*   添加使用Active Record的多个数据库指南。
    ([拉取请求](https://github.com/rails/rails/pull/36389))

*   添加有关自动加载常量故障排除的部分。
    ([提交](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   添加Action Mailbox基础指南。
    ([拉取请求](https://github.com/rails/rails/pull/34812))

*   添加Action Text概述指南。
    ([拉取请求](https://github.com/rails/rails/pull/34878))

贡献者
-------

请参阅[Rails的完整贡献者列表](https://contributors.rubyonrails.org/)，感谢所有为Rails付出了许多时间的人们，使其成为一个稳定和强大的框架。

[railties]:       https://github.com/rails/rails/blob/6-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-0-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-0-stable/activesupport/CHANGELOG.md
