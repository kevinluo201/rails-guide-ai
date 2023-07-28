**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 82080185bf1d0c30f22fa131b42e4187
Ruby on Rails 7.1 发布说明
===============================

Rails 7.1 的亮点：

--------------------------------------------------------------------------------

升级到 Rails 7.1
----------------------

如果您正在升级现有应用程序，在进行升级之前，最好先进行充分的测试覆盖。您还应该先升级到 Rails 7.0（如果尚未升级），并确保您的应用程序在升级到 Rails 7.1 之前仍能正常运行。有关升级时需要注意的事项，请参阅
[升级 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-7-0-to-rails-7-1)
指南。

主要功能
--------------

Railties
--------

详细更改请参阅 [Changelog][railties]。

### 移除

### 弃用

### 显著更改

Action Cable
------------

详细更改请参阅 [Changelog][action-cable]。

### 移除

### 弃用

### 显著更改

Action Pack
-----------

详细更改请参阅 [Changelog][action-pack]。

### 移除

*   移除 `Request#content_type` 上的弃用行为

*   移除对 `config.action_dispatch.trusted_proxies` 分配单个值的弃用能力。

*   移除系统测试中 `poltergeist` 和 `webkit`（capybara-webkit）驱动程序的弃用注册。

### 弃用

*   弃用 `config.action_dispatch.return_only_request_media_type_on_content_type`。

*   弃用 `AbstractController::Helpers::MissingHelperError`。

*   弃用 `ActionDispatch::IllegalStateError`。

### 显著更改

Action View
-----------

详细更改请参阅 [Changelog][action-view]。

### 移除

*   移除 `ActionView::Path` 上的弃用常量。

*   移除将实例变量作为局部变量传递给局部视图的弃用支持。

### 弃用

### 显著更改

Action Mailer
-------------

详细更改请参阅 [Changelog][action-mailer]。

### 移除

### 弃用

### 显著更改

Active Record
-------------

详细更改请参阅 [Changelog][active-record]。

### 移除

*   移除对 `ActiveRecord.legacy_connection_handling` 的支持。

*   移除弃用的 `ActiveRecord::Base` 配置访问器。

*   移除 `configs_for` 上的 `:include_replicas` 支持。请改用 `:include_hidden`。

*   移除弃用的 `config.active_record.partial_writes`。

*   移除弃用的 `Tasks::DatabaseTasks.schema_file_type`。

### 弃用

### 显著更改

Active Storage
--------------

详细更改请参阅 [Changelog][active-storage]。

### 移除

*   移除 Active Storage 配置中无效的默认内容类型。

*   移除 `ActiveStorage::Current#host` 和 `ActiveStorage::Current#host=` 方法的弃用行为。

*   移除分配到附件集合时的弃用行为。现在，附件集合不再追加，而是替换。

*   移除附件关联中的 `purge` 和 `purge_later` 方法的弃用行为。

### 弃用

### 显著更改

Active Model
------------

详细更改请参阅 [Changelog][active-model]。

### 移除

### 弃用

### 显著更改

Active Support
--------------

详细更改请参阅 [Changelog][active-support]。

### 移除

*   移除对 `Enumerable#sum` 的弃用覆盖。

*   移除 `ActiveSupport::PerThreadRegistry`。

*   移除在 `Array`、`Range`、`Date`、`DateTime`、`Time`、`BigDecimal`、`Float` 和 `Integer` 中将格式传递给 `#to_s` 的弃用选项。

*   移除对 `ActiveSupport::TimeWithZone.name` 的弃用覆盖。

*   移除 `active_support/core_ext/uri` 文件。

*   移除 `active_support/core_ext/range/include_time_with_zone` 文件。

*   移除 `ActiveSupport::SafeBuffer` 中将对象隐式转换为 `String` 的弃用支持。

*   当提供的命名空间 ID 不是 `Digest::UUID` 上定义的常量之一时，移除生成不正确的 RFC 4122 UUID 的弃用支持。

### 弃用

*   弃用 `config.active_support.disable_to_s_conversion`。

*   弃用 `config.active_support.remove_deprecated_time_with_zone_name`。

*   弃用 `config.active_support.use_rfc4122_namespaced_uuids`。

### 显著更改

Active Job
----------

详细更改请参阅 [Changelog][active-job]。

### 移除

### 弃用

### 显著更改

Action Text
----------

详细更改请参阅 [Changelog][action-text]。

### 移除

### 弃用

### 显著更改

Action Mailbox
----------

详细更改请参阅 [Changelog][action-mailbox]。

### 移除

### 弃用

### 显著更改

Ruby on Rails 指南
--------------------

详细更改请参阅 [Changelog][guides]。

### 显著更改

贡献者
-------

请参阅
[Rails 的完整贡献者列表](https://contributors.rubyonrails.org/)
感谢所有为 Rails 付出了许多时间的人，使其成为一个稳定而强大的框架。向他们致敬。

[railties]:       https://github.com/rails/rails/blob/main/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/main/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/main/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/main/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/main/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/main/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/main/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/main/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/main/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/main/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/main/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/main/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/main/actionmailbox/CHANGELOG.md
