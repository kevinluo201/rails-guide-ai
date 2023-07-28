**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 1d652e6ccda9c901ca3f6a003c95f83e
Ruby on Rails 6.1 发布说明
===============================

Rails 6.1 的亮点：

* 每个数据库连接的切换
* 水平分片
* 严格加载关联
* 委托类型
* 异步销毁关联

这些发布说明仅涵盖了主要更改。要了解各种错误修复和更改，请参阅更改日志或查看 GitHub 上主要 Rails 存储库中的[提交列表](https://github.com/rails/rails/commits/6-1-stable)。

--------------------------------------------------------------------------------

升级到 Rails 6.1
----------------------

如果您正在升级现有应用程序，在进行升级之前，最好有良好的测试覆盖率。如果您还没有升级到 Rails 6.0，请先升级到 Rails 6.0，并确保您的应用程序在升级到 Rails 6.1 之前仍然按预期运行。在升级时要注意的事项列表可在[升级 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-0-to-rails-6-1)指南中找到。

主要功能
--------------

### 每个数据库连接的切换

Rails 6.1 提供了[每个数据库连接的切换功能](https://github.com/rails/rails/pull/40370)。在 6.0 中，如果您切换到“读取”角色，则所有数据库连接也会切换到读取角色。现在在 6.1 中，如果您在配置中将 `legacy_connection_handling` 设置为 `false`，Rails 将允许您通过在相应的抽象类上调用 `connected_to` 来切换单个数据库的连接。

### 水平分片

Rails 6.0 提供了对数据库进行功能分区（多个分区，不同的模式）的能力，但无法支持水平分片（相同的模式，多个分区）。Rails 无法支持水平分片，因为 Active Record 中的模型每个角色每个类只能有一个连接。现在这个问题已经修复，[Rails 支持水平分片](https://github.com/rails/rails/pull/38531)。

### 严格加载关联

[严格加载关联](https://github.com/rails/rails/pull/37400)允许您确保所有关联都被急切加载，并在出现 N+1 之前停止它们。

### 委托类型

[委托类型](https://github.com/rails/rails/pull/39341)是单表继承的一种替代方案。它有助于表示类层次结构，允许超类成为由自己的表表示的具体类。每个子类都有自己的表用于额外的属性。

### 异步销毁关联

[异步销毁关联](https://github.com/rails/rails/pull/40157)增加了应用程序在后台作业中销毁关联的能力。这可以帮助您在销毁数据时避免超时和其他性能问题。

Railties
--------

详细更改请参阅[更改日志][railties]。

### 删除

*   删除了已弃用的 `rake notes` 任务。

*   删除了 `rails dbconsole` 命令中已弃用的 `connection` 选项。

*   删除了 `rails notes` 中对 `SOURCE_ANNOTATION_DIRECTORIES` 环境变量支持的已弃用。

*   删除了 `rails server` 命令中已弃用的 `server` 参数。

*   删除了使用 `HOST` 环境变量指定服务器 IP 的已弃用支持。

*   删除了已弃用的 `rake dev:cache` 任务。

*   删除了已弃用的 `rake routes` 任务。

*   删除了已弃用的 `rake initializers` 任务。

### 弃用

### 显著更改

Action Cable
------------

详细更改请参阅[更改日志][action-cable]。

### 删除

### 弃用

### 显著更改

Action Pack
-----------

详细更改请参阅[更改日志][action-pack]。

### 删除

*   删除了已弃用的 `ActionDispatch::Http::ParameterFilter`。

*   删除了控制器级别的已弃用的 `force_ssl`。

### 弃用

*   弃用了 `config.action_dispatch.return_only_media_type_on_content_type`。

### 显著更改

*   将 `ActionDispatch::Response#content_type` 更改为返回完整的 Content-Type 标头。

Action View
-----------

详细更改请参阅[更改日志][action-view]。

### 删除

*   从 `ActionView::Template::Handlers::ERB` 中删除了已弃用的 `escape_whitelist`。

*   从 `ActionView::Resolver` 中删除了已弃用的 `find_all_anywhere`。

*   从 `ActionView::Template::HTML` 中删除了已弃用的 `formats`。

*   从 `ActionView::Template::RawFile` 中删除了已弃用的 `formats`。

*   从 `ActionView::Template::Text` 中删除了已弃用的 `formats`。

*   从 `ActionView::PathSet` 中删除了已弃用的 `find_file`。

*   从 `ActionView::LookupContext` 中删除了已弃用的 `rendered_format`。

*   从 `ActionView::ViewPaths` 中删除了已弃用的 `find_file`。

*   删除了在 `ActionView::Base#initialize` 的第一个参数中传递非 `ActionView::LookupContext` 对象的已弃用支持。

*   删除了 `ActionView::Base#initialize` 的已弃用的 `format` 参数。

*   删除了已弃用的 `ActionView::Template#refresh`。

*   删除了已弃用的 `ActionView::Template#original_encoding`。

*   删除了已弃用的 `ActionView::Template#variants`。

*   删除了已弃用的 `ActionView::Template#formats`。

*   删除了已弃用的 `ActionView::Template#virtual_path=`。

*   删除了已弃用的 `ActionView::Template#updated_at`。

*   删除了 `ActionView::Template#initialize` 上需要 `updated_at` 参数。

*   删除了已弃用的 `ActionView::Template.finalize_compiled_template_methods`。

*   删除了已弃用的 `config.action_view.finalize_compiled_template_methods`。

*   删除了使用块调用 `ActionView::ViewPaths#with_fallback` 的已弃用支持。

*   删除了将绝对路径传递给 `render template:` 的已弃用支持。

*   删除了将相对路径传递给 `render file:` 的已弃用支持。

*   删除了不接受两个参数的模板处理程序的支持。

*   删除了 `ActionView::Template::PathResolver` 中的已弃用模式参数。

*   删除了某些视图助手中从对象调用私有方法的已弃用支持。

### 弃用

### 显著更改
*   要求`ActionView::Base`的子类实现`#compiled_method_container`方法。

*   在`ActionView::Template#initialize`中将`locals`参数设为必需。

*   `javascript_include_tag`和`stylesheet_link_tag`资源助手生成一个`Link`头，为现代浏览器提供有关预加载资源的提示。可以通过将`config.action_view.preload_links_header`设置为`false`来禁用此功能。

Action Mailer
-------------

详细更改请参阅[Changelog][action-mailer]。

### 移除

*   移除已弃用的`ActionMailer::Base.receive`，改用[Action Mailbox](https://github.com/rails/rails/tree/6-1-stable/actionmailbox)。

### 弃用

### 重要更改

Active Record
-------------

详细更改请参阅[Changelog][active-record]。

### 移除

*   从`ActiveRecord::ConnectionAdapters::DatabaseLimits`中移除已弃用的方法。

    `column_name_length`
    `table_name_length`
    `columns_per_table`
    `indexes_per_table`
    `columns_per_multicolumn_index`
    `sql_query_length`
    `joins_per_query`

*   移除已弃用的`ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_multi_insert?`。

*   移除已弃用的`ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_foreign_keys_in_create?`。

*   移除已弃用的`ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_ranges?`。

*   移除已弃用的`ActiveRecord::Base#update_attributes`和`ActiveRecord::Base#update_attributes!`。

*   在`ActiveRecord::ConnectionAdapter::SchemaStatements#assume_migrated_upto_version`中移除已弃用的`migrations_path`参数。

*   移除已弃用的`config.active_record.sqlite3.represent_boolean_as_integer`。

*   从`ActiveRecord::DatabaseConfigurations`中移除已弃用的方法。

    `fetch`
    `each`
    `first`
    `values`
    `[]=`

*   移除已弃用的`ActiveRecord::Result#to_hash`方法。

*   移除在`ActiveRecord::Relation`方法中使用不安全的原始SQL的已弃用支持。

### 弃用

*   弃用`ActiveRecord::Base.allow_unsafe_raw_sql`。

*   弃用`connected_to`上的`database`关键字参数。

*   当`legacy_connection_handling`设置为false时，弃用`connection_handlers`。

### 重要更改

*   MySQL：唯一性验证器现在尊重默认数据库排序规则，默认情况下不再强制区分大小写的比较。

*   `relation.create`在初始化块和回调中不再泄漏范围给类级别的查询方法。

    之前：

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => nil
    end
    ```

    现在：

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => #<User name: "David", ...>
    end
    ```

*   命名范围链不再将范围泄漏给类级别的查询方法。

    ```ruby
    class User < ActiveRecord::Base
      scope :david, -> { User.where(name: "David") }
    end
    ```

    之前：

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'John' AND name = 'David'
    ```

    现在：

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'David'
    ```

*   `where.not`现在生成NAND谓词而不是NOR。

    之前：

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE name != 'Jon' AND role != 'admin'
    ```

    现在：

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE NOT (name = 'Jon' AND role = 'admin')
    ```

*   要使用新的数据库连接处理，应用程序必须将`legacy_connection_handling`设置为false，并删除`connection_handlers`上的已弃用访问器。`connects_to`和`connected_to`的公共方法不需要更改。

Active Storage
--------------

详细更改请参阅[Changelog][active-storage]。

### 移除

*   移除向`ActiveStorage::Transformers::ImageProcessing`传递`:combine_options`操作的已弃用支持。

*   移除已弃用的`ActiveStorage::Transformers::MiniMagickTransformer`。

*   移除已弃用的`config.active_storage.queue`。

*   移除已弃用的`ActiveStorage::Downloading`。

### 弃用

*   弃用`Blob.create_after_upload`，改用`Blob.create_and_upload`。
    ([Pull Request](https://github.com/rails/rails/pull/34827))

### 重要更改

*   添加`Blob.create_and_upload`方法，用于创建新的blob并将给定的`io`上传到服务。
    ([Pull Request](https://github.com/rails/rails/pull/34827))
*   添加`ActiveStorage::Blob#service_name`列。升级后需要运行迁移。运行`bin/rails app:update`生成该迁移。

Active Model
------------

详细更改请参阅[Changelog][active-model]。

### 移除

### 弃用

### 重要更改

*   Active Model的错误现在是具有接口的对象，允许应用程序更轻松地处理和交互模型抛出的错误。
    [该功能](https://github.com/rails/rails/pull/32313)包括一个查询接口，支持更精确的测试和访问错误详细信息。

Active Support
--------------

详细更改请参阅[Changelog][active-support]。

### 移除

*   当`config.i18n.fallbacks`为空时，移除对`I18n.default_locale`的已弃用回退。

*   移除已弃用的`LoggerSilence`常量。

*   移除已弃用的`ActiveSupport::LoggerThreadSafeLevel#after_initialize`。

*   移除已弃用的`Module#parent_name`、`Module#parent`和`Module#parents`。

*   移除已弃用文件`active_support/core_ext/module/reachable`。

*   移除已弃用文件`active_support/core_ext/numeric/inquiry`。

*   移除已弃用文件`active_support/core_ext/array/prepend_and_append`。

*   移除已弃用文件`active_support/core_ext/hash/compact`。

*   移除已弃用文件`active_support/core_ext/hash/transform_values`。

*   移除已弃用文件`active_support/core_ext/range/include_range`。

*   移除已弃用的`ActiveSupport::Multibyte::Chars#consumes?`和`ActiveSupport::Multibyte::Chars#normalize`。

*   移除已弃用的`ActiveSupport::Multibyte::Unicode.pack_graphemes`、
    `ActiveSupport::Multibyte::Unicode.unpack_graphemes`、
    `ActiveSupport::Multibyte::Unicode.normalize`、
    `ActiveSupport::Multibyte::Unicode.downcase`、
    `ActiveSupport::Multibyte::Unicode.upcase`和`ActiveSupport::Multibyte::Unicode.swapcase`。

*   移除已弃用的`ActiveSupport::Notifications::Instrumenter#end=`。

### 弃用

*   弃用`ActiveSupport::Multibyte::Unicode.default_normalization_form`。

### 重要更改

Active Job
----------

详细更改请参阅[Changelog][active-job]。

### 移除

### 弃用

*   弃用`config.active_job.return_false_on_aborted_enqueue`。

### 重要更改

*   当取消排队作业时返回`false`。

Action Text
----------

详细更改请参阅[Changelog][action-text]。

### 移除

### 弃用

### 重要更改

*   添加方法，通过在富文本属性名称后添加`?`来确认富文本内容是否存在。
    ([Pull Request](https://github.com/rails/rails/pull/37951))

*   添加`fill_in_rich_text_area`系统测试用例助手，用于查找trix编辑器并用给定的HTML内容填充它。
    ([Pull Request](https://github.com/rails/rails/pull/35885))
*   添加 `ActionText::FixtureSet.attachment` 以在数据库测试数据中生成 `<action-text-attachment>` 元素。([Pull Request](https://github.com/rails/rails/pull/40289))

Action Mailbox
----------

请参考[更新日志][action-mailbox]以获取详细的更改信息。

### 移除内容

### 弃用内容

*   弃用 `Rails.application.credentials.action_mailbox.api_key` 和 `MAILGUN_INGRESS_API_KEY`，改用 `Rails.application.credentials.action_mailbox.signing_key` 和 `MAILGUN_INGRESS_SIGNING_KEY`。

### 重要更改

Ruby on Rails 指南
--------------------

请参考[更新日志][guides]以获取详细的更改信息。

### 重要更改

贡献者
-------

请查看[Rails的完整贡献者列表](https://contributors.rubyonrails.org/)，感谢所有为Rails付出了大量时间的人们。向他们致以崇高的敬意。

[railties]:       https://github.com/rails/rails/blob/6-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-1-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/6-1-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-1-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-1-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-1-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/6-1-stable/actionmailbox/CHANGELOG.md
