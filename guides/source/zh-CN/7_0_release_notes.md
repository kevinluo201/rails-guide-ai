**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e9aa14ccbfd8f02fea6c1b061215332c
Ruby on Rails 7.0 发布说明
===============================

Rails 7.0 的亮点：

* 需要 Ruby 2.7.0+，推荐使用 Ruby 3.0+

--------------------------------------------------------------------------------

升级到 Rails 7.0
----------------------

如果您正在升级现有应用程序，在进行升级之前，最好有良好的测试覆盖率。您还应该先升级到 Rails 6.1（如果尚未升级），并确保您的应用程序在升级到 Rails 7.0 之前仍然按预期运行。在升级时需要注意的事项列表可在
[升级 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0)
指南中找到。

主要功能
--------------

Railties
--------

详细更改请参阅[更新日志][railties]。

### 移除

*   移除 `dbconsole` 中已弃用的 `config`。

### 弃用

### 重要更改

*   Sprockets 现在是可选依赖项

    gem `rails` 不再依赖于 `sprockets-rails`。如果您的应用程序仍然需要使用 Sprockets，
    请确保将 `sprockets-rails` 添加到您的 Gemfile 中。

    ```
    gem "sprockets-rails"
    ```

Action Cable
------------

详细更改请参阅[更新日志][action-cable]。

### 移除

### 弃用

### 重要更改

Action Pack
-----------

详细更改请参阅[更新日志][action-pack]。

### 移除

*   移除已弃用的 `ActionDispatch::Response.return_only_media_type_on_content_type`。

*   移除已弃用的 `Rails.config.action_dispatch.hosts_response_app`。

*   移除已弃用的 `ActionDispatch::SystemTestCase#host!`。

*   移除对将 `fixture_file_upload` 的路径传递给 `fixture_path` 的支持。

### 弃用

### 重要更改

Action View
-----------

详细更改请参阅[更新日志][action-view]。

### 移除

*   移除已弃用的 `Rails.config.action_view.raise_on_missing_translations`。

### 弃用

### 重要更改

*  `button_to` 从 Active Record 对象中推断出 HTTP 动词 [method]，如果使用对象构建 URL

    ```ruby
    button_to("执行 POST", [:do_post_action, Workshop.find(1)])
    # 之前
    #=>   <input type="hidden" name="_method" value="post" autocomplete="off" />
    # 现在
    #=>   <input type="hidden" name="_method" value="patch" autocomplete="off" />
    ```

Action Mailer
-------------

详细更改请参阅[更新日志][action-mailer]。

### 移除

*   移除已弃用的 `ActionMailer::DeliveryJob` 和 `ActionMailer::Parameterized::DeliveryJob`，
    改用 `ActionMailer::MailDeliveryJob`。

### 弃用

### 重要更改

Active Record
-------------

详细更改请参阅[更新日志][active-record]。

### 移除

*   移除从 `connected_to` 中弃用的 `database` kwarg。

*   移除已弃用的 `ActiveRecord::Base.allow_unsafe_raw_sql`。

*   移除 `configs_for` 方法中 `:spec_name` 选项的已弃用支持。

*   移除在 Rails 4.2 和 4.1 格式中使用 YAML 加载 `ActiveRecord::Base` 实例的已弃用支持。

*   移除在 PostgreSQL 数据库中使用 `:interval` 列时的弃用警告。

    现在，interval 列将返回 `ActiveSupport::Duration` 对象而不是字符串。

    要保持旧行为，您可以在模型中添加以下行：

    ```ruby
    attribute :column, :string
    ```

*   移除使用 `"primary"` 作为连接规范名称解析连接的已弃用支持。

*   移除引用 `ActiveRecord::Base` 对象的已弃用支持。

*   移除将数据库值强制转换为 `ActiveRecord::Base` 对象的已弃用支持。

*   移除将列传递给 `type_cast` 的已弃用支持。

*   移除已弃用的 `DatabaseConfig#config` 方法。

*   移除已弃用的 rake 任务：

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

*   移除使用非确定性顺序搜索的已弃用支持 `Model.reorder(nil).first`。

*   移除 `Tasks::DatabaseTasks.schema_up_to_date?` 中的 `environment` 和 `name` 参数的已弃用支持。

*   移除已弃用的 `Tasks::DatabaseTasks.dump_filename`。

*   移除已弃用的 `Tasks::DatabaseTasks.schema_file`。

*   移除已弃用的 `Tasks::DatabaseTasks.spec`。

*   移除已弃用的 `Tasks::DatabaseTasks.current_config`。

*   移除已弃用的 `ActiveRecord::Connection#allowed_index_name_length`。

*   移除已弃用的 `ActiveRecord::Connection#in_clause_length`。

*   移除已弃用的 `ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name`。

*   移除已弃用的 `ActiveRecord::Base.connection_config`。

*   移除已弃用的 `ActiveRecord::Base.arel_attribute`。

*   移除已弃用的 `ActiveRecord::Base.configurations.default_hash`。

*   移除已弃用的 `ActiveRecord::Base.configurations.to_h`。

*   移除已弃用的 `ActiveRecord::Result#map!` 和 `ActiveRecord::Result#collect!`。

*   移除已弃用的 `ActiveRecord::Base#remove_connection`。

### 弃用

*   弃用 `Tasks::DatabaseTasks.schema_file_type`。

### 重要更改

*   当块提前返回时回滚事务。

    在此更改之前，当事务块提前返回时，事务将被提交。

    问题在于事务块内部触发的超时也会导致未完成的事务被提交，为了避免这个错误，事务块将被回滚。

*   合并相同列上的条件不再保留两个条件，并将始终被后一个条件替换。

    ```ruby
    # Rails 6.1（IN 子句被合并方的等式条件替换）
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    # Rails 6.1（两个冲突条件都存在，已弃用）
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => []
    # Rails 6.1 使用 rewhere 迁移到 Rails 7.0 的行为
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob), rewhere: true) # => [bob]
    # Rails 7.0（与 IN 子句相同的行为，合并方条件始终被替换）
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => [bob]
    ```
Active Storage
--------------

请参考[Changelog][active-storage]以获取详细的更改信息。

### 移除

### 废弃

### 重要更改

Active Model
------------

请参考[Changelog][active-model]以获取详细的更改信息。

### 移除

*   移除将`ActiveModel::Errors`实例枚举为哈希的废弃用法。

*   移除废弃的`ActiveModel::Errors#to_h`。

*   移除废弃的`ActiveModel::Errors#slice!`。

*   移除废弃的`ActiveModel::Errors#values`。

*   移除废弃的`ActiveModel::Errors#keys`。

*   移除废弃的`ActiveModel::Errors#to_xml`。

*   移除将错误连接到`ActiveModel::Errors#messages`的废弃用法。

*   移除从`ActiveModel::Errors#messages`中清除错误的废弃用法。

*   移除从`ActiveModel::Errors#messages`中删除错误的废弃用法。

*   移除在`ActiveModel::Errors#messages`中使用`[]=`的支持。

*   移除对Rails 5.x错误格式的Marshal和YAML加载支持。

*   移除对Rails 5.x `ActiveModel::AttributeSet`格式的Marshal加载支持。

### 废弃

### 重要更改

Active Support
--------------

请参考[Changelog][active-support]以获取详细的更改信息。

### 移除

*   移除废弃的`config.active_support.use_sha1_digests`。

*   移除废弃的`URI.parser`。

*   移除使用`Range#include?`检查日期时间范围中值的包含性的废弃用法。

*   移除废弃的`ActiveSupport::Multibyte::Unicode.default_normalization_form`。

### 废弃

*   废弃在`Array`、`Range`、`Date`、`DateTime`、`Time`、`BigDecimal`、`Float`和`Integer`中将格式传递给`#to_s`，而推荐使用`#to_fs`。

    此废弃用法是为了让Rails应用程序能够利用Ruby 3.1的[优化](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44)，从而加快某些类型对象的插值速度。

    新的应用程序将不会在这些类上覆盖`#to_s`方法，现有的应用程序可以使用`config.active_support.disable_to_s_conversion`。

### 重要更改

Active Job
----------

请参考[Changelog][active-job]以获取详细的更改信息。

### 移除

*   移除当先一个回调使用`throw :abort`终止时，不会停止`after_enqueue`/`after_perform`回调的废弃行为。

*   移除废弃的`:return_false_on_aborted_enqueue`选项。

### 废弃

*   废弃`Rails.config.active_job.skip_after_callbacks_if_terminated`。

### 重要更改

Action Text
----------

请参考[Changelog][action-text]以获取详细的更改信息。

### 移除

### 废弃

### 重要更改

Action Mailbox
----------

请参考[Changelog][action-mailbox]以获取详细的更改信息。

### 移除

*   移除废弃的`Rails.application.credentials.action_mailbox.mailgun_api_key`。

*   移除废弃的环境变量`MAILGUN_INGRESS_API_KEY`。

### 废弃

### 重要更改

Ruby on Rails Guides
--------------------

请参考[Changelog][guides]以获取详细的更改信息。

### 重要更改

Credits
-------

请参阅[Rails的完整贡献者列表](https://contributors.rubyonrails.org/)，感谢那些花费了许多时间使Rails成为稳定而强大的框架的众多人员。向他们致敬。

[railties]:       https://github.com/rails/rails/blob/7-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/7-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/7-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/7-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/7-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/7-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/7-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/7-0-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/7-0-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/7-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/7-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/7-0-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/7-0-stable/actionmailbox/CHANGELOG.md
