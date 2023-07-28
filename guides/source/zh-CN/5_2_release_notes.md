**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c7252bf18650c5a9a85fc144305c4615
Ruby on Rails 5.2 发布说明
===============================

Rails 5.2 的亮点：

* Active Storage
* Redis Cache Store
* HTTP/2 Early Hints
* Credentials
* Content Security Policy

这些发布说明仅涵盖了主要更改。要了解各种错误修复和更改，请参阅更改日志或查看 GitHub 上 Rails 主存储库中的[提交列表](https://github.com/rails/rails/commits/5-2-stable)。

--------------------------------------------------------------------------------

升级到 Rails 5.2
----------------------

如果您正在升级现有应用程序，在进行升级之前，最好有良好的测试覆盖率。您还应该先升级到 Rails 5.1（如果尚未升级），并确保您的应用程序在尝试更新到 Rails 5.2 之前仍然按预期运行。在升级时要注意的事项列表可在[升级 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2)指南中找到。

主要特性
--------------

### Active Storage

[Pull Request](https://github.com/rails/rails/pull/30020)

[Active Storage](https://github.com/rails/rails/tree/5-2-stable/activestorage) 用于将文件上传到云存储服务，如 Amazon S3、Google Cloud Storage 或 Microsoft Azure Storage，并将这些文件附加到 Active Record 对象。它配备了一个基于本地磁盘的服务，用于开发和测试，并支持将文件镜像到从属服务以进行备份和迁移。您可以在[Active Storage 概述](active_storage_overview.html)指南中了解更多关于 Active Storage 的信息。

### Redis Cache Store

[Pull Request](https://github.com/rails/rails/pull/31134)

Rails 5.2 预装了内置的 Redis 缓存存储。您可以在[Caching with Rails: An Overview](caching_with_rails.html#activesupport-cache-rediscachestore)指南中了解更多信息。

### HTTP/2 Early Hints

[Pull Request](https://github.com/rails/rails/pull/30744)

Rails 5.2 支持 [HTTP/2 Early Hints](https://tools.ietf.org/html/rfc8297)。要启用 Early Hints，可以在 `bin/rails server` 中传递 `--early-hints`。

### Credentials

[Pull Request](https://github.com/rails/rails/pull/30067)

添加了 `config/credentials.yml.enc` 文件来存储生产应用程序的秘密。它允许直接在存储库中使用 `config/master.key` 文件或 `RAILS_MASTER_KEY` 环境变量加密的密钥保存任何第三方服务的身份验证凭据。这将最终取代 `Rails.application.secrets` 和 Rails 5.1 中引入的加密秘密。此外，Rails 5.2 还[开放了底层 Credentials 的 API](https://github.com/rails/rails/pull/30940)，因此您可以轻松处理其他加密配置、密钥和文件。您可以在[Securing Rails Applications](security.html#custom-credentials)指南中了解更多信息。
### 内容安全策略

[Rails 5.2的拉取请求](https://github.com/rails/rails/pull/31162)

Rails 5.2引入了一个新的DSL，允许您为应用程序配置[内容安全策略](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)。您可以配置一个全局默认策略，然后根据每个资源进行覆盖，并且甚至可以使用lambda函数将每个请求的值注入到标头中，例如在多租户应用程序中的帐户子域。您可以在[Securing Rails Applications](security.html#content-security-policy)指南中了解更多信息。

Railties
--------

请参考[更改日志][railties]以获取详细的更改信息。

### 废弃功能

*   废弃生成器和模板中的`capify!`方法。
    ([拉取请求](https://github.com/rails/rails/pull/29493))

*   将环境名称作为常规参数传递给`rails dbconsole`和`rails console`命令已被废弃。应改用`-e`选项。
    ([提交](https://github.com/rails/rails/commit/48b249927375465a7102acc71c2dfb8d49af8309))

*   废弃使用`Rails::Application`的子类来启动Rails服务器。
    ([拉取请求](https://github.com/rails/rails/pull/30127))

*   废弃Rails插件模板中的`after_bundle`回调。
    ([拉取请求](https://github.com/rails/rails/pull/29446))

### 显著更改

*   在`config/database.yml`中添加一个共享部分，将加载到所有环境中。
    ([拉取请求](https://github.com/rails/rails/pull/28896))

*   将`railtie.rb`添加到插件生成器中。
    ([拉取请求](https://github.com/rails/rails/pull/29576))

*   在`tmp:clear`任务中清除截图文件。
    ([拉取请求](https://github.com/rails/rails/pull/29534))

*   运行`bin/rails app:update`时跳过未使用的组件。如果初始应用程序生成跳过了Action Cable、Active Record等，则更新任务也会遵循这些跳过。
    ([拉取请求](https://github.com/rails/rails/pull/29645))

*   在使用3级数据库配置时，允许在`rails dbconsole`命令中传递自定义连接名称。例如：`bin/rails dbconsole -c replica`。
    ([提交](https://github.com/rails/rails/commit/1acd9a6464668d4d54ab30d016829f60b70dbbeb))

*   正确扩展运行`console`和`dbconsole`命令时环境名称的快捷方式。
    ([提交](https://github.com/rails/rails/commit/3777701f1380f3814bd5313b225586dec64d4104))

*   在默认的`Gemfile`中添加`bootsnap`。
    ([拉取请求](https://github.com/rails/rails/pull/29313))

*   使用`rails runner`支持`-`作为从stdin运行脚本的平台无关方式。
    ([拉取请求](https://github.com/rails/rails/pull/26343))

*   在创建新的Rails应用程序时，将`ruby x.x.x`版本添加到`Gemfile`并创建包含当前Ruby版本的`.ruby-version`根文件。
    ([拉取请求](https://github.com/rails/rails/pull/30016))

*   在插件生成器中添加`--skip-action-cable`选项。
    ([拉取请求](https://github.com/rails/rails/pull/30164))
*   在插件生成器的`Gemfile`中添加`git_source`。
    ([Pull Request](https://github.com/rails/rails/pull/30110))

*   在运行Rails插件的`bin/rails`时跳过未使用的组件。
    ([Commit](https://github.com/rails/rails/commit/62499cb6e088c3bc32a9396322c7473a17a28640))

*   优化生成器操作的缩进。
    ([Pull Request](https://github.com/rails/rails/pull/30166))

*   优化路由的缩进。
    ([Pull Request](https://github.com/rails/rails/pull/30241))

*   在插件生成器中添加`--skip-yarn`选项。
    ([Pull Request](https://github.com/rails/rails/pull/30238))

*   为生成器的`gem`方法支持多个版本参数。
    ([Pull Request](https://github.com/rails/rails/pull/30323))

*   在开发和测试环境中根据应用程序名称派生`secret_key_base`。
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   将`mini_magick`作为注释添加到默认的`Gemfile`中。
    ([Pull Request](https://github.com/rails/rails/pull/30633))

*   `rails new`和`rails plugin new`默认获取`Active Storage`。
    添加使用`--skip-active-storage`跳过`Active Storage`的功能，并在使用`--skip-active-record`时自动跳过。
    ([Pull Request](https://github.com/rails/rails/pull/30101))

Action Cable
------------

详细更改请参考[Changelog][action-cable]。

### 移除

*   移除已弃用的事件驱动的Redis适配器。
    ([Commit](https://github.com/rails/rails/commit/48766e32d31651606b9f68a16015ad05c3b0de2c))

### 重要更改

*   在cable.yml中添加对`host`、`port`、`db`和`password`选项的支持。
    ([Pull Request](https://github.com/rails/rails/pull/29528))

*   在使用PostgreSQL适配器时对长流标识进行哈希处理。
    ([Pull Request](https://github.com/rails/rails/pull/29297))

Action Pack
-----------

详细更改请参考[Changelog][action-pack]。

### 移除

*   移除已弃用的`ActionController::ParamsParser::ParseError`。
    ([Commit](https://github.com/rails/rails/commit/e16c765ac6dcff068ff2e5554d69ff345c003de1))

### 弃用

*   弃用`ActionDispatch::TestResponse`的`#success?`、`#missing?`和`#error?`别名。
    ([Pull Request](https://github.com/rails/rails/pull/30104))

### 重要更改

*   使用片段缓存支持可回收的缓存键。
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   更改片段的缓存键格式，以便更容易调试键的变化。
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   使用GCM进行AEAD加密的Cookie和会话。
    ([Pull Request](https://github.com/rails/rails/pull/28132))

*   默认启用防止伪造。
    ([Pull Request](https://github.com/rails/rails/pull/29742))

*   在服务器端强制签名/加密Cookie的过期时间。
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   Cookies的`:expires`选项支持`ActiveSupport::Duration`对象。
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   使用Capybara注册的`:puma`服务器配置。
    ([Pull Request](https://github.com/rails/rails/pull/30638))

*   简化带有密钥轮换支持的Cookies中间件。
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   添加启用HTTP/2的Early Hints功能。
    ([Pull Request](https://github.com/rails/rails/pull/30744))

*   在系统测试中添加无头Chrome支持。
    ([Pull Request](https://github.com/rails/rails/pull/30876))

*   在`redirect_back`方法中添加`:allow_other_host`选项。
    ([Pull Request](https://github.com/rails/rails/pull/30850))
*   使`assert_recognizes`能够遍历已挂载的引擎。
    ([Pull Request](https://github.com/rails/rails/pull/22435))

*   添加用于配置Content-Security-Policy头的DSL。
    ([Pull Request](https://github.com/rails/rails/pull/31162),
    [Commit](https://github.com/rails/rails/commit/619b1b6353a65e1635d10b8f8c6630723a5a6f1a),
    [Commit](https://github.com/rails/rails/commit/4ec8bf68ff92f35e79232fbd605012ce1f4e1e6e))

*   注册现代浏览器支持的最流行的音频/视频/字体MIME类型。
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   将默认系统测试截图输出从`inline`更改为`simple`。
    ([Commit](https://github.com/rails/rails/commit/9d6e288ee96d6241f864dbf90211c37b14a57632))

*   为系统测试添加无头Firefox支持。
    ([Pull Request](https://github.com/rails/rails/pull/31365))

*   将安全的`X-Download-Options`和`X-Permitted-Cross-Domain-Policies`添加到默认头集合中。
    ([Commit](https://github.com/rails/rails/commit/5d7b70f4336d42eabfc403e9f6efceb88b3eff44))

*   当用户没有手动指定其他服务器时，将系统测试更改为仅将Puma设置为默认服务器。
    ([Pull Request](https://github.com/rails/rails/pull/31384))

*   将`Referrer-Policy`头添加到默认头集合中。
    ([Commit](https://github.com/rails/rails/commit/428939be9f954d39b0c41bc53d85d0d106b9d1a1))

*   在`ActionController::Parameters#each`中匹配`Hash#each`的行为。
    ([Pull Request](https://github.com/rails/rails/pull/27790))

*   为Rails UJS添加自动生成nonce的支持。
    ([Commit](https://github.com/rails/rails/commit/b2f0a8945956cd92dec71ec4e44715d764990a49))

*   将默认的HSTS max-age值更新为31536000秒（1年），以满足https://hstspreload.org/的最小max-age要求。
    ([Commit](https://github.com/rails/rails/commit/30b5f469a1d30c60d1fb0605e84c50568ff7ed37))

*   为`cookies`添加别名方法`to_hash`。
    为`session`添加别名方法`to_h`。
    ([Commit](https://github.com/rails/rails/commit/50a62499e41dfffc2903d468e8b47acebaf9b500))

Action View
-----------

请参阅[Changelog][action-view]以获取详细更改信息。

### 删除

*   删除已弃用的Erubis ERB处理程序。
    ([Commit](https://github.com/rails/rails/commit/7de7f12fd140a60134defe7dc55b5a20b2372d06))

### 弃用

*   弃用`image_alt`助手，该助手用于为`image_tag`生成的图像添加默认的alt文本。
    ([Pull Request](https://github.com/rails/rails/pull/30213))

### 显著更改

*   将`auto_discovery_link_tag`添加`:json`类型，以支持[JSON Feeds](https://jsonfeed.org/version/1)。
    ([Pull Request](https://github.com/rails/rails/pull/29158))

*   为`image_tag`助手添加`srcset`选项。
    ([Pull Request](https://github.com/rails/rails/pull/29349))

*   修复`field_error_proc`包装`optgroup`和选择分隔符`option`的问题。
    ([Pull Request](https://github.com/rails/rails/pull/31088))

*   将`form_with`更改为默认生成id。
    ([Commit](https://github.com/rails/rails/commit/260d6f112a0ffdbe03e6f5051504cb441c1e94cd))

*   添加`preload_link_tag`助手。
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   允许使用可调用对象作为分组选择器的组方法。
    ([Pull Request](https://github.com/rails/rails/pull/31578))

Action Mailer
-------------

请参阅[Changelog][action-mailer]以获取详细更改信息。

### 显著更改

*   允许Action Mailer类配置其传递作业。
    ([Pull Request](https://github.com/rails/rails/pull/29457))

*   添加`assert_enqueued_email_with`测试助手。
    ([Pull Request](https://github.com/rails/rails/pull/30695))

Active Record
-------------
请参考[Changelog][active-record]以获取详细的更改信息。

### 移除

*   移除已弃用的`#migration_keys`。
    ([Pull Request](https://github.com/rails/rails/pull/30337))

*   移除在类型转换Active Record对象时已弃用的对`quoted_id`的支持。
    ([Commit](https://github.com/rails/rails/commit/82472b3922bda2f337a79cef961b4760d04f9689))

*   移除`index_name_exists?`中已弃用的`default`参数。
    ([Commit](https://github.com/rails/rails/commit/8f5b34df81175e30f68879479243fbce966122d7))

*   移除在关联中传递类到`:class_name`时已弃用的支持。
    ([Commit](https://github.com/rails/rails/commit/e65aff70696be52b46ebe57207ebd8bb2cfcdbb6))

*   移除已弃用的方法`initialize_schema_migrations_table`和`initialize_internal_metadata_table`。
    ([Commit](https://github.com/rails/rails/commit/c9660b5777707658c414b430753029cd9bc39934))

*   移除已弃用的方法`supports_migrations?`。
    ([Commit](https://github.com/rails/rails/commit/9438c144b1893f2a59ec0924afe4d46bd8d5ffdd))

*   移除已弃用的方法`supports_primary_key?`。
    ([Commit](https://github.com/rails/rails/commit/c56ff22fc6e97df4656ddc22909d9bf8b0c2cbb1))

*   移除已弃用的方法`ActiveRecord::Migrator.schema_migrations_table_name`。
    ([Commit](https://github.com/rails/rails/commit/7df6e3f3cbdea9a0460ddbab445c81fbb1cfd012))

*   移除`#indexes`中已弃用的参数`name`。
    ([Commit](https://github.com/rails/rails/commit/d6b779ecebe57f6629352c34bfd6c442ac8fba0e))

*   移除`#verify!`中已弃用的参数。
    ([Commit](https://github.com/rails/rails/commit/9c6ee1bed0292fc32c23dc1c68951ae64fc510be))

*   移除已弃用的配置`.error_on_ignored_order_or_limit`。
    ([Commit](https://github.com/rails/rails/commit/e1066f450d1a99c9a0b4d786b202e2ca82a4c3b3))

*   移除已弃用的方法`#scope_chain`。
    ([Commit](https://github.com/rails/rails/commit/ef7784752c5c5efbe23f62d2bbcc62d4fd8aacab))

*   移除已弃用的方法`#sanitize_conditions`。
    ([Commit](https://github.com/rails/rails/commit/8f5413b896099f80ef46a97819fe47a820417bc2))

### 弃用

*   弃用`supports_statement_cache?`。
    ([Pull Request](https://github.com/rails/rails/pull/28938))

*   弃用同时传递参数和块到`ActiveRecord::Calculations`中的`count`和`sum`。
    ([Pull Request](https://github.com/rails/rails/pull/29262))

*   弃用在`Relation`中委托给`arel`。
    ([Pull Request](https://github.com/rails/rails/pull/29619))

*   弃用`TransactionState`中的`set_state`方法。
    ([Commit](https://github.com/rails/rails/commit/608ebccf8f6314c945444b400a37c2d07f21b253))

*   弃用`expand_hash_conditions_for_aggregates`，没有替代方法。
    ([Commit](https://github.com/rails/rails/commit/7ae26885d96daee3809d0bd50b1a440c2f5ffb69))

### 显著更改

*   当调用动态fixture访问器方法时没有参数，现在返回该类型的所有fixtures。之前该方法总是返回一个空数组。
    ([Pull Request](https://github.com/rails/rails/pull/28692))

*   修复在覆盖Active Record属性读取器时的更改属性的不一致性。
    ([Pull Request](https://github.com/rails/rails/pull/28661))

*   支持MySQL的降序索引。
    ([Pull Request](https://github.com/rails/rails/pull/28773))

*   修复`bin/rails db:forward`的第一个迁移。
    ([Commit](https://github.com/rails/rails/commit/b77d2aa0c336492ba33cbfade4964ba0eda3ef84))

*   当当前迁移不存在时，在迁移的移动上引发`UnknownMigrationVersionError`错误。
    ([Commit](https://github.com/rails/rails/commit/bb9d6eb094f29bb94ef1f26aa44f145f17b973fe))

*   在数据库结构转储的rake任务中，遵循`SchemaDumper.ignore_tables`。
    ([Pull Request](https://github.com/rails/rails/pull/29077))

*   添加`ActiveRecord::Base#cache_version`以支持通过`ActiveSupport::Cache`中的新版本化条目的可回收缓存键。这也意味着`ActiveRecord::Base#cache_key`现在将返回一个稳定的键，不再包含时间戳。
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   如果转换后的值为nil，则防止创建绑定参数。
    ([Pull Request](https://github.com/rails/rails/pull/29282))

*   使用批量INSERT来插入fixtures以提高性能。
    ([Pull Request](https://github.com/rails/rails/pull/29504))
* 合并表示嵌套连接的两个关系不再将合并后的关系的连接转换为左外连接。
    ([拉取请求](https://github.com/rails/rails/pull/27063))

* 修复事务以将状态应用于子事务。
    以前，如果您有一个嵌套事务并且外部事务被回滚，内部事务的记录仍将被标记为已持久化。通过在父事务回滚时将父事务的状态应用于子事务来修复此问题。这将正确地将内部事务的记录标记为未持久化。
    ([提交](https://github.com/rails/rails/commit/0237da287eb4c507d10a0c6d94150093acc52b03))

* 修复使用包括连接的范围进行急切加载/预加载关联。
    ([拉取请求](https://github.com/rails/rails/pull/29413))

* 防止由`sql.active_record`通知订阅者引发的错误转换为`ActiveRecord::StatementInvalid`异常。
    ([拉取请求](https://github.com/rails/rails/pull/29692))

* 在处理记录的批量操作（`find_each`，`find_in_batches`，`in_batches`）时跳过查询缓存。
    ([提交](https://github.com/rails/rails/commit/b83852e6eed5789b23b13bac40228e87e8822b4d))

* 将sqlite3的布尔序列化更改为使用1和0。
    SQLite本地识别1和0作为true和false，但以前序列化时不本地识别't'和'f'。
    ([拉取请求](https://github.com/rails/rails/pull/29699))

* 使用多参数赋值构造的值现在将使用后类型转换值在单字段表单输入中呈现。
    ([提交](https://github.com/rails/rails/commit/1519e976b224871c7f7dd476351930d5d0d7faf6))

* 在生成模型时不再生成`ApplicationRecord`。如果需要生成它，可以使用`rails g application_record`创建。
    ([拉取请求](https://github.com/rails/rails/pull/29916))

* `Relation#or`现在接受两个关系，这两个关系的`references`值不同，因为`references`可以由`where`隐式调用。
    ([提交](https://github.com/rails/rails/commit/ea6139101ccaf8be03b536b1293a9f36bc12f2f7))

* 在使用`Relation#or`时，提取公共条件并将其放置在OR条件之前。
    ([拉取请求](https://github.com/rails/rails/pull/29950))

* 添加`binary`夹具辅助方法。
    ([拉取请求](https://github.com/rails/rails/pull/30073))

* 自动猜测STI的逆关联。
    ([拉取请求](https://github.com/rails/rails/pull/23425))

* 添加新的错误类`LockWaitTimeout`，当锁等待超时时将引发该错误。
    ([拉取请求](https://github.com/rails/rails/pull/30360))

* 更新`sql.active_record`仪表化的有效负载名称以更具描述性。
    ([拉取请求](https://github.com/rails/rails/pull/30619))

* 在从数据库中删除索引时使用给定的算法。
    ([拉取请求](https://github.com/rails/rails/pull/24199))
* 将`Set`传递给`Relation#where`的行为与传递数组相同。
    ([提交记录](https://github.com/rails/rails/commit/9cf7e3494f5bd34f1382c1ff4ea3d811a4972ae2))

* PostgreSQL的`tsrange`现在保留了亚秒精度。
    ([拉取请求](https://github.com/rails/rails/pull/30725))

* 在脏记录中调用`lock!`时会引发异常。
    ([提交记录](https://github.com/rails/rails/commit/63cf15877bae859ff7b4ebaf05186f3ca79c1863))

* 修复了使用SQLite适配器时索引的列顺序未写入`db/schema.rb`的错误。
    ([拉取请求](https://github.com/rails/rails/pull/30970))

* 修复了使用指定的`VERSION`运行`bin/rails db:migrate`的问题。
    使用空的`VERSION`运行`bin/rails db:migrate`的行为与不使用`VERSION`相同。
    检查`VERSION`的格式：允许迁移版本号或迁移文件的名称。如果`VERSION`的格式无效，则引发错误。
    如果目标迁移不存在，则引发错误。
    ([拉取请求](https://github.com/rails/rails/pull/30714))

* 添加新的错误类`StatementTimeout`，当超过语句超时时将引发该错误。
    ([拉取请求](https://github.com/rails/rails/pull/31129))

* `update_all`现在在将值传递给`Type#serialize`之前会将其传递给`Type#cast`。这意味着`update_all(foo: 'true')`将正确地持久化布尔值。
    ([提交记录](https://github.com/rails/rails/commit/68fe6b08ee72cc47263e0d2c9ff07f75c4b42761))

* 在关系查询方法中使用原始SQL片段时需要明确标记。
    ([提交记录](https://github.com/rails/rails/commit/a1ee43d2170dd6adf5a9f390df2b1dde45018a48),
    [提交记录](https://github.com/rails/rails/commit/e4a921a75f8702a7dbaf41e31130fe884dea93f9))

* 为仅在迁移上时相关的代码添加`#up_only`到数据库迁移中，例如填充新列。
    ([拉取请求](https://github.com/rails/rails/pull/31082))

* 添加新的错误类`QueryCanceled`，当取消语句由于用户请求时将引发该错误。
    ([拉取请求](https://github.com/rails/rails/pull/31235))

* 不允许定义与`Relation`上的实例方法冲突的作用域。
    ([拉取请求](https://github.com/rails/rails/pull/31179))

* 为`add_index`添加对PostgreSQL操作符类的支持。
    ([拉取请求](https://github.com/rails/rails/pull/19090))

* 记录数据库查询的调用者。
    ([拉取请求](https://github.com/rails/rails/pull/26815),
    [拉取请求](https://github.com/rails/rails/pull/31519),
    [拉取请求](https://github.com/rails/rails/pull/31690))

* 在重置列信息时，取消定义后代的属性方法。
    ([拉取请求](https://github.com/rails/rails/pull/31475))

* 使用子查询进行带有`limit`或`offset`的`delete_all`。
    ([提交记录](https://github.com/rails/rails/commit/9e7260da1bdc0770cf4ac547120c85ab93ff3d48))

* 修复了在与`limit()`一起使用时`first(n)`的不一致性。
    `first(n)`查找器现在尊重`limit()`，使其与`relation.to_a.first(n)`的行为一致，也与`last(n)`的行为一致。
    ([拉取请求](https://github.com/rails/rails/pull/27597))

* 修复了在未持久化的父实例上使用嵌套的`has_many :through`关联的问题。
    ([提交记录](https://github.com/rails/rails/commit/027f865fc8b262d9ba3ee51da3483e94a5489b66))
* 在删除记录时考虑关联条件。
    ([提交记录](https://github.com/rails/rails/commit/ae48c65e411e01c1045056562319666384bb1b63))

* 在调用`save`或`save!`后不允许修改已销毁的对象。
    ([提交记录](https://github.com/rails/rails/commit/562dd0494a90d9d47849f052e8913f0050f3e494))

* 修复`left_outer_joins`中的关联合并问题。
    ([拉取请求](https://github.com/rails/rails/pull/27860))

* 支持PostgreSQL外部表。
    ([拉取请求](https://github.com/rails/rails/pull/31549))

* 当复制一个Active Record对象时清除事务状态。
    ([拉取请求](https://github.com/rails/rails/pull/31751))

* 修复使用`composed_of`列将Array对象作为参数传递给where方法时未展开的问题。
    ([拉取请求](https://github.com/rails/rails/pull/31724))

* 当`polymorphic?`未被误用时，使`reflection.klass`抛出异常。
    ([提交记录](https://github.com/rails/rails/commit/63fc1100ce054e3e11c04a547cdb9387cd79571a))

* 修复MySQL和PostgreSQL的`#columns_for_distinct`，使`ActiveRecord::FinderMethods#limited_ids_for`在`ORDER BY`列包含其他表的主键时使用正确的主键值。
    ([提交记录](https://github.com/rails/rails/commit/851618c15750979a75635530200665b543561a44))

* 修复has_one/belongs_to关系中`dependent: :destroy`的问题，当子对象未被删除时父对象被删除。
    ([提交记录](https://github.com/rails/rails/commit/b0fc04aa3af338d5a90608bf37248668d59fc881))

* 空闲的数据库连接（之前只是孤立的连接）现在会被连接池清理器定期清理。
    ([提交记录](https://github.com/rails/rails/pull/31221/commits/9027fafff6da932e6e64ddb828665f4b01fc8902))

Active Model
------------

详细更改请参阅[Changelog][active-model]。

### 显著更改

* 修复`ActiveModel::Errors`中的`#keys`和`#values`方法。将`#keys`改为仅返回没有空消息的键。将`#values`改为仅返回非空值。
    ([拉取请求](https://github.com/rails/rails/pull/28584))

* 为`ActiveModel::Errors`添加`#merge!`方法。
    ([拉取请求](https://github.com/rails/rails/pull/29714))

* 允许将Proc或Symbol传递给长度验证器选项。
    ([拉取请求](https://github.com/rails/rails/pull/30674))

* 当`_confirmation`的值为`false`时执行`ConfirmationValidator`验证。
    ([拉取请求](https://github.com/rails/rails/pull/31058))

* 使用带有proc默认值的属性API的模型现在可以被序列化。
    ([提交记录](https://github.com/rails/rails/commit/0af36c62a5710e023402e37b019ad9982e69de4b))

* 在序列化中不丢失所有带有选项的多个`:includes`。
    ([提交记录](https://github.com/rails/rails/commit/853054bcc7a043eea78c97e7705a46abb603cc44))

Active Support
--------------

详细更改请参阅[Changelog][active-support]。

### 移除

* 移除已弃用的回调的`:if`和`:unless`字符串过滤器。
    ([提交记录](https://github.com/rails/rails/commit/c792354adcbf8c966f274915c605c6713b840548))

* 移除已弃用的`halt_callback_chains_on_return_false`选项。
    ([提交记录](https://github.com/rails/rails/commit/19fbbebb1665e482d76cae30166b46e74ceafe29))

### 弃用

* 弃用`Module#reachable?`方法。
    ([拉取请求](https://github.com/rails/rails/pull/30624))

* 弃用`secrets.secret_token`。
    ([提交记录](https://github.com/rails/rails/commit/fbcc4bfe9a211e219da5d0bb01d894fcdaef0a0e))

### 显著更改

* 为`HashWithIndifferentAccess`添加`fetch_values`方法。
    ([拉取请求](https://github.com/rails/rails/pull/28316))
*   为`Time#change`添加对`:offset`的支持。
    ([提交记录](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   为`ActiveSupport::TimeWithZone#change`添加对`:offset`和`:zone`的支持。
    ([提交记录](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   将gem名称和弃用期限传递给弃用通知。
    ([拉取请求](https://github.com/rails/rails/pull/28800))

*   为版本化缓存条目添加支持。这使得缓存存储可以重复使用缓存键，在频繁变动的情况下大大节省存储空间。与Active Record中的`#cache_key`和`#cache_version`的分离以及其在Action Pack的片段缓存中的使用一起工作。
    ([拉取请求](https://github.com/rails/rails/pull/29092))

*   添加`ActiveSupport::CurrentAttributes`以提供线程隔离的属性单例。主要用例是使所有每个请求的属性在整个系统中容易访问。
    ([拉取请求](https://github.com/rails/rails/pull/29180))

*   `#singularize`和`#pluralize`现在会尊重指定区域设置的不可数名词。
    ([提交记录](https://github.com/rails/rails/commit/352865d0f835c24daa9a2e9863dcc9dde9e5371a))

*   为`class_attribute`添加默认选项。
    ([拉取请求](https://github.com/rails/rails/pull/29270))

*   添加`Date#prev_occurring`和`Date#next_occurring`以返回指定的下一个/上一个星期几。
    ([拉取请求](https://github.com/rails/rails/pull/26600))

*   为模块和类属性访问器添加默认选项。
    ([拉取请求](https://github.com/rails/rails/pull/29294))

*   缓存：`write_multi`。
    ([拉取请求](https://github.com/rails/rails/pull/29366))

*   默认使用AES 256 GCM加密的`ActiveSupport::MessageEncryptor`。
    ([拉取请求](https://github.com/rails/rails/pull/29263))

*   添加`freeze_time`助手，在测试中将时间冻结为`Time.now`。
    ([拉取请求](https://github.com/rails/rails/pull/29681))

*   使`Hash#reverse_merge!`的顺序与`HashWithIndifferentAccess`一致。
    ([拉取请求](https://github.com/rails/rails/pull/28077))

*   为`ActiveSupport::MessageVerifier`和`ActiveSupport::MessageEncryptor`添加目的和过期支持。
    ([拉取请求](https://github.com/rails/rails/pull/29892))

*   更新`String#camelize`以在传递错误选项时提供反馈。
    ([拉取请求](https://github.com/rails/rails/pull/30039))

*   如果目标为nil，`Module#delegate_missing_to`现在会像`Module#delegate`一样引发`DelegationError`。
    ([拉取请求](https://github.com/rails/rails/pull/30191))

*   添加`ActiveSupport::EncryptedFile`和`ActiveSupport::EncryptedConfiguration`。
    ([拉取请求](https://github.com/rails/rails/pull/30067))

*   添加`config/credentials.yml.enc`以存储生产应用程序的秘密。
    ([拉取请求](https://github.com/rails/rails/pull/30067))

*   为`MessageEncryptor`和`MessageVerifier`添加密钥轮换支持。
    ([拉取请求](https://github.com/rails/rails/pull/29716))

*   从`HashWithIndifferentAccess#transform_keys`返回`HashWithIndifferentAccess`的实例。
    ([拉取请求](https://github.com/rails/rails/pull/30728))

*   如果定义了，`Hash#slice`现在会回退到Ruby 2.5+的内置定义。
    ([提交记录](https://github.com/rails/rails/commit/01ae39660243bc5f0a986e20f9c9bff312b1b5f8))

*   `IO#to_json`现在返回`to_s`的表示形式，而不是尝试转换为数组。这修复了在调用不可读对象的`IO#to_json`时引发`IOError`的错误。
    ([拉取请求](https://github.com/rails/rails/pull/30953))
* 根据`Date#prev_day`和`Date#next_day`的要求，为`Time#prev_day`和`Time#next_day`添加相同的方法签名。允许传递参数给`Time#prev_day`和`Time#next_day`。
    ([提交记录](https://github.com/rails/rails/commit/61ac2167eff741bffb44aec231f4ea13d004134e))

* 根据`Date#prev_month`和`Date#next_month`的要求，为`Time#prev_month`和`Time#next_month`添加相同的方法签名。允许传递参数给`Time#prev_month`和`Time#next_month`。
    ([提交记录](https://github.com/rails/rails/commit/f2c1e3a793570584d9708aaee387214bc3543530))

* 根据`Date#prev_year`和`Date#next_year`的要求，为`Time#prev_year`和`Time#next_year`添加相同的方法签名。允许传递参数给`Time#prev_year`和`Time#next_year`。
    ([提交记录](https://github.com/rails/rails/commit/ee9d81837b5eba9d5ec869ae7601d7ffce763e3e))

* 修复`humanize`中的首字母缩略词支持。
    ([提交记录](https://github.com/rails/rails/commit/0ddde0a8fca6a0ca3158e3329713959acd65605d))

* 在TWZ范围上允许使用`Range#include?`。
    ([拉取请求](https://github.com/rails/rails/pull/31081))

* 默认情况下启用缓存压缩，对于大于1kB的值。
    ([拉取请求](https://github.com/rails/rails/pull/31147))

* Redis缓存存储。
    ([拉取请求](https://github.com/rails/rails/pull/31134),
    [拉取请求](https://github.com/rails/rails/pull/31866))

* 处理`TZInfo::AmbiguousTime`错误。
    ([拉取请求](https://github.com/rails/rails/pull/31128))

* MemCacheStore：支持过期计数器。
    ([提交记录](https://github.com/rails/rails/commit/b22ee64b5b30c6d5039c292235e10b24b1057f6d))

* 使`ActiveSupport::TimeZone.all`仅返回在`ActiveSupport::TimeZone::MAPPING`中的时区。
    ([拉取请求](https://github.com/rails/rails/pull/31176))

* 更改`ActiveSupport::SecurityUtils.secure_compare`的默认行为，使其即使对于可变长度的字符串也不泄漏长度信息。将旧的`ActiveSupport::SecurityUtils.secure_compare`重命名为`fixed_length_secure_compare`，并开始在传递的字符串长度不匹配时引发`ArgumentError`。
    ([拉取请求](https://github.com/rails/rails/pull/24510))

* 使用SHA-1生成非敏感摘要，例如ETag头。
    ([拉取请求](https://github.com/rails/rails/pull/31289),
    [拉取请求](https://github.com/rails/rails/pull/31651))

* `assert_changes`将始终断言表达式发生变化，而不管`from:`和`to:`参数的组合如何。
    ([拉取请求](https://github.com/rails/rails/pull/31011))

* 在`ActiveSupport::Cache::Store`中为`read_multi`添加缺失的仪表板。
    ([拉取请求](https://github.com/rails/rails/pull/30268))

* 在`assert_difference`中支持哈希作为第一个参数。这允许在同一断言中指定多个数值差异。
    ([拉取请求](https://github.com/rails/rails/pull/31600))

* 缓存：MemCache和Redis的`read_multi`和`fetch_multi`加速。在查询后端之前从本地内存缓存读取。
    ([提交记录](https://github.com/rails/rails/commit/a2b97e4ffef971607a1be8fc7909f099b6840f36))

Active Job
----------

请参阅[更新日志][active-job]以获取详细更改信息。

### 显著更改

* 允许将块传递给`ActiveJob::Base.discard_on`，以允许自定义处理丢弃的作业。
    ([拉取请求](https://github.com/rails/rails/pull/30622))

Ruby on Rails指南
--------------------

请参阅[更新日志][guides]以获取详细更改信息。

### 显著更改

* 添加[在Rails中的线程和代码执行](threading_and_code_execution.html)指南。
    ([拉取请求](https://github.com/rails/rails/pull/27494))

[active-job]: https://github.com/rails/rails/blob/master/activejob/CHANGELOG.md
[guides]: https://github.com/rails/rails/blob/master/guides/source/CHANGELOG.md
*   添加[Active Storage概述](active_storage_overview.html)指南。
    ([拉取请求](https://github.com/rails/rails/pull/31037))

致谢
-------

请查看[Rails的完整贡献者列表](https://contributors.rubyonrails.org/)，感谢所有为Rails付出了大量时间的人，使其成为一个稳定而强大的框架。

[railties]:       https://github.com/rails/rails/blob/5-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-2-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-2-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-2-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-2-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/5-2-stable/guides/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-2-stable/activesupport/CHANGELOG.md
