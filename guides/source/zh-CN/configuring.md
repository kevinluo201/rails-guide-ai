**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bba7dd6e311e7abd59e434f12dbebd0e
配置Rails应用程序
==============================

本指南介绍了Rails应用程序可用的配置和初始化功能。

阅读本指南后，您将了解：

* 如何调整Rails应用程序的行为。
* 如何在应用程序启动时添加额外的代码运行。

--------------------------------------------------------------------------------

初始化代码的位置
---------------------------------

Rails提供了四个标准位置来放置初始化代码：

* `config/application.rb`
* 环境特定的配置文件
* 初始化器
* 后初始化器

在Rails之前运行代码
-------------------------

在极少数情况下，如果您的应用程序需要在Rails本身加载之前运行一些代码，请将其放在`config/application.rb`中`require "rails/all"`的调用之前。

配置Rails组件
----------------------------

一般来说，配置Rails的工作意味着配置Rails的组件，以及配置Rails本身。配置文件`config/application.rb`和环境特定的配置文件（如`config/environments/production.rb`）允许您指定要传递给所有组件的各种设置。

例如，您可以将以下设置添加到`config/application.rb`文件中：

```ruby
config.time_zone = 'Central Time (US & Canada)'
```

这是Rails本身的设置。如果您想将设置传递给单个Rails组件，可以通过`config/application.rb`中的相同`config`对象来实现：

```ruby
config.active_record.schema_format = :ruby
```

Rails将使用该特定设置来配置Active Record。

警告：使用公共配置方法而不是直接调用相关类。例如，使用`Rails.application.config.action_mailer.options`而不是`ActionMailer::Base.options`。

注意：如果您需要直接将配置应用于类，请在初始化器中使用[延迟加载钩子](https://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html)，以避免在初始化完成之前自动加载类。这样做会导致错误，因为在应用程序重新加载时无法安全地重复自动加载。

### 版本化的默认值

[`config.load_defaults`]加载目标版本和所有先前版本的默认配置值。例如，`config.load_defaults 6.1`将为所有版本，包括版本6.1及之前的版本加载默认值。


以下是与每个目标版本关联的默认值。在冲突值的情况下，新版本优先于旧版本。

#### 目标版本7.1的默认值

- [`config.action_controller.allow_deprecated_parameters_hash_equality`](#config-action-controller-allow-deprecated-parameters-hash-equality): `false`
- [`config.action_dispatch.debug_exception_log_level`](#config-action-dispatch-debug-exception-log-level): `:error`
- [`config.action_dispatch.default_headers`](#config-action-dispatch-default-headers): `{ "X-Frame-Options" => "SAMEORIGIN", "X-XSS-Protection" => "0", "X-Content-Type-Options" => "nosniff", "X-Permitted-Cross-Domain-Policies" => "none", "Referrer-Policy" => "strict-origin-when-cross-origin" }`
- [`config.action_text.sanitizer_vendor`](#config-action-text-sanitizer-vendor): `Rails::HTML::Sanitizer.best_supported_vendor`
- [`config.action_view.sanitizer_vendor`](#config-action-view-sanitizer-vendor): `Rails::HTML::Sanitizer.best_supported_vendor`
- [`config.active_job.use_big_decimal_serializer`](#config-active-job-use-big-decimal-serializer): `true`
- [`config.active_record.allow_deprecated_singular_associations_name`](#config-active-record-allow-deprecated-singular-associations-name): `false`
- [`config.active_record.before_committed_on_all_records`](#config-active-record-before-committed-on-all-records): `true`
- [`config.active_record.belongs_to_required_validates_foreign_key`](#config-active-record-belongs-to-required-validates-foreign-key): `false`
- [`config.active_record.default_column_serializer`](#config-active-record-default-column-serializer): `nil`
- [`config.active_record.encryption.hash_digest_class`](#config-active-record-encryption-hash-digest-class): `OpenSSL::Digest::SHA256`
- [`config.active_record.encryption.support_sha1_for_non_deterministic_encryption`](#config-active-record-encryption-support-sha1-for-non-deterministic-encryption): `false`
- [`config.active_record.marshalling_format_version`](#config-active-record-marshalling-format-version): `7.1`
- [`config.active_record.query_log_tags_format`](#config-active-record-query-log-tags-format): `:sqlcommenter`
- [`config.active_record.raise_on_assign_to_attr_readonly`](#config-active-record-raise-on-assign-to-attr-readonly): `true`
- [`config.active_record.run_after_transaction_callbacks_in_order_defined`](#config-active-record-run-after-transaction-callbacks-in-order-defined): `true`
- [`config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`](#config-active-record-run-commit-callbacks-on-first-saved-instances-in-transaction): `false`
- [`config.active_record.sqlite3_adapter_strict_strings_by_default`](#config-active-record-sqlite3-adapter-strict-strings-by-default): `true`
- [`config.active_support.cache_format_version`](#config-active-support-cache-format-version): `7.1`
- [`config.active_support.message_serializer`](#config-active-support-message-serializer): `:json_allow_marshal`
- [`config.active_support.raise_on_invalid_cache_expiration_time`](#config-active-support-raise-on-invalid-cache-expiration-time): `true`
- [`config.active_support.use_message_serializer_for_metadata`](#config-active-support-use-message-serializer-for-metadata): `true`
- [`config.add_autoload_paths_to_load_path`](#config-add-autoload-paths-to-load-path): `false`
- [`config.log_file_size`](#config-log-file-size): `100 * 1024 * 1024`
- [`config.precompile_filter_parameters`](#config-precompile-filter-parameters): `true`

#### 目标版本7.0的默认值

- [`config.action_controller.raise_on_open_redirects`](#config-action-controller-raise-on-open-redirects): `true`
- [`config.action_controller.wrap_parameters_by_default`](#config-action-controller-wrap-parameters-by-default): `true`
- [`config.action_dispatch.cookies_serializer`](#config-action-dispatch-cookies-serializer): `:json`
- [`config.action_dispatch.default_headers`](#config-action-dispatch-default-headers): `{ "X-Frame-Options" => "SAMEORIGIN", "X-XSS-Protection" => "0", "X-Content-Type-Options" => "nosniff", "X-Download-Options" => "noopen", "X-Permitted-Cross-Domain-Policies" => "none", "Referrer-Policy" => "strict-origin-when-cross-origin" }`
- [`config.action_mailer.smtp_timeout`](#config-action-mailer-smtp-timeout): `5`
- [`config.action_view.apply_stylesheet_media_default`](#config-action-view-apply-stylesheet-media-default): `false`
- [`config.action_view.button_to_generates_button_tag`](#config-action-view-button-to-generates-button-tag): `true`
- [`config.active_record.automatic_scope_inversing`](#config-active-record-automatic-scope-inversing): `true`
- [`config.active_record.partial_inserts`](#config-active-record-partial-inserts): `false`
- [`config.active_record.verify_foreign_keys_for_fixtures`](#config-active-record-verify-foreign-keys-for-fixtures): `true`
- [`config.active_storage.multiple_file_field_include_hidden`](#config-active-storage-multiple-file-field-include-hidden): `true`
- [`config.active_storage.variant_processor`](#config-active-storage-variant-processor): `:vips`
- [`config.active_storage.video_preview_arguments`](#config-active-storage-video-preview-arguments): `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015),loop=loop=-1:size=2,trim=start_frame=1' -frames:v 1 -f image2"`
- [`config.active_support.cache_format_version`](#config-active-support-cache-format-version): `7.0`
- [`config.active_support.executor_around_test_case`](#config-active-support-executor-around-test-case): `true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA256`
- [`config.active_support.isolation_level`](#config-active-support-isolation-level): `:thread`
- [`config.active_support.key_generator_hash_digest_class`](#config-active-support-key-generator-hash-digest-class): `OpenSSL::Digest::SHA256`
#### 目标版本6.1的默认值

- [`ActiveSupport.utc_to_local_returns_utc_offset_times`](#activesupport-utc-to-local-returns-utc-offset-times): `true`
- [`config.action_dispatch.cookies_same_site_protection`](#config-action-dispatch-cookies-same-site-protection): `:lax`
- [`config.action_dispatch.ssl_default_redirect_status`](#config-action-dispatch-ssl-default-redirect-status): `308`
- [`config.action_mailbox.queues.incineration`](#config-action-mailbox-queues-incineration): `nil`
- [`config.action_mailbox.queues.routing`](#config-action-mailbox-queues-routing): `nil`
- [`config.action_mailer.deliver_later_queue_name`](#config-action-mailer-deliver-later-queue-name): `nil`
- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `false`
- [`config.action_view.preload_links_header`](#config-action-view-preload-links-header): `true`
- [`config.active_job.retry_jitter`](#config-active-job-retry-jitter): `0.15`
- [`config.active_record.has_many_inversing`](#config-active-record-has-many-inversing): `true`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `nil`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `nil`
- [`config.active_storage.track_variants`](#config-active-storage-track-variants): `true`

#### 目标版本6.0的默认值

- [`config.action_dispatch.use_cookies_with_metadata`](#config-action-dispatch-use-cookies-with-metadata): `true`
- [`config.action_mailer.delivery_job`](#config-action-mailer-delivery-job): `"ActionMailer::MailDeliveryJob"`
- [`config.action_view.default_enforce_utf8`](#config-action-view-default-enforce-utf8): `false`
- [`config.active_record.collection_cache_versioning`](#config-active-record-collection-cache-versioning): `true`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `:active_storage_analysis`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `:active_storage_purge`

#### 目标版本5.2的默认值

- [`config.action_controller.default_protect_from_forgery`](#config-action-controller-default-protect-from-forgery): `true`
- [`config.action_dispatch.use_authenticated_cookie_encryption`](#config-action-dispatch-use-authenticated-cookie-encryption): `true`
- [`config.action_view.form_with_generates_ids`](#config-action-view-form-with-generates-ids): `true`
- [`config.active_record.cache_versioning`](#config-active-record-cache-versioning): `true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA1`
- [`config.active_support.use_authenticated_message_encryption`](#config-active-support-use-authenticated-message-encryption): `true`

#### 目标版本5.1的默认值

- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `true`
- [`config.assets.unknown_asset_fallback`](#config-assets-unknown-asset-fallback): `false`

#### 目标版本5.0的默认值

- [`ActiveSupport.to_time_preserves_timezone`](#activesupport-to-time-preserves-timezone): `true`
- [`config.action_controller.forgery_protection_origin_check`](#config-action-controller-forgery-protection-origin-check): `true`
- [`config.action_controller.per_form_csrf_tokens`](#config-action-controller-per-form-csrf-tokens): `true`
- [`config.active_record.belongs_to_required_by_default`](#config-active-record-belongs-to-required-by-default): `true`
- [`config.ssl_options`](#config-ssl-options): `{ hsts: { subdomains: true } }`

### Rails通用配置

以下配置方法应在`Rails::Railtie`对象上调用，例如`Rails::Engine`或`Rails::Application`的子类。

#### `config.add_autoload_paths_to_load_path`

指定是否将自动加载路径添加到`$LOAD_PATH`中。建议在`config/application.rb`中的`:zeitwerk`模式下尽早将其设置为`false`。Zeitwerk在内部使用绝对路径，而在`:zeitwerk`模式下运行的应用程序不需要`require_dependency`，因此模型、控制器、作业等不需要在`$LOAD_PATH`中。将其设置为`false`可以节省Ruby在解析具有相对路径的`require`调用时检查这些目录的时间，并节省Bootsnap的工作和RAM，因为它不需要为它们构建索引。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `true` |
| 7.1      | `false`|

`lib`目录不受此标志影响，它始终会被添加到`$LOAD_PATH`中。

#### `config.after_initialize`

接受一个块，在Rails完成初始化应用程序后运行。这包括框架本身、引擎和`config/initializers`中的所有应用程序初始化器的初始化。请注意，此块将在运行rake任务时运行。用于配置其他初始化器设置的值非常有用：

```ruby
config.after_initialize do
  ActionView::Base.sanitized_allowed_tags.delete 'div'
end
```

#### `config.after_routes_loaded`

接受一个块，在Rails完成加载应用程序路由后运行。每当重新加载路由时，都会运行此块。

```ruby
config.after_routes_loaded do
  # 处理Rails.application.routes的代码
end
```

#### `config.allow_concurrency`

控制是否应并发处理请求。只有当应用程序代码不是线程安全时，才应将其设置为`false`。默认值为`true`。

#### `config.asset_host`

设置资源的主机。当使用CDN托管资源或者希望通过使用不同的域别名绕过浏览器中内置的并发限制时，这很有用。是`config.action_controller.asset_host`的简化版本。

#### `config.assume_ssl`

使应用程序相信所有请求都是通过SSL到达的。当通过终止SSL的负载均衡器进行代理时，转发的请求将会出现在应用程序中，就好像它是HTTP而不是HTTPS。这使得重定向和cookie安全的目标是HTTP而不是HTTPS。此中间件使服务器假设代理已经终止了SSL，并且请求确实是HTTPS的。


#### `config.autoflush_log`

启用立即写入日志文件输出，而不是缓冲。默认为`true`。

#### `config.autoload_once_paths`

接受一个路径数组，Rails将从中自动加载常量，这些常量不会在每个请求中被清除。如果启用了重新加载（默认情况下在`development`环境中启用），则相关。否则，所有自动加载只发生一次。此数组的所有元素也必须在`autoload_paths`中。默认为空数组。

#### `config.autoload_paths`

接受一个路径数组，Rails将从中自动加载常量。默认为空数组。自[Rails 6](upgrading_ruby_on_rails.html#autoloading)以来，不建议调整此设置。请参阅[自动加载和重新加载常量](autoloading_and_reloading_constants.html#autoload-paths)。

#### `config.autoload_lib(ignore:)`

此方法将`lib`添加到`config.autoload_paths`和`config.eager_load_paths`中。

通常，`lib`目录有一些子目录不应该被自动加载或急切加载。请在所需的`ignore`关键字参数中传递它们相对于`lib`的名称。例如，

```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

请参阅[自动加载指南](autoloading_and_reloading_constants.html)了解更多详细信息。

#### `config.autoload_lib_once(ignore:)`

`config.autoload_lib_once`方法与`config.autoload_lib`类似，只是它将`lib`添加到`config.autoload_once_paths`中。

通过调用`config.autoload_lib_once`，可以自动加载`lib`中的类和模块，即使是从应用程序初始化程序中，但不会重新加载。

#### `config.beginning_of_week`

设置应用程序的默认一周的开始。接受一个有效的星期几作为符号（例如`:monday`）。

#### `config.cache_classes`

旧设置等效于`!config.enable_reloading`。为了向后兼容而支持。

#### `config.cache_store`

配置用于Rails缓存的缓存存储。选项包括以下符号之一：`:memory_store`、`:file_store`、`:mem_cache_store`、`:null_store`、`:redis_cache_store`，或实现缓存API的对象。默认为`:file_store`。有关每个存储配置选项，请参阅[缓存存储](caching_with_rails.html#cache-stores)。

#### `config.colorize_logging`

指定在记录信息时是否使用ANSI颜色代码。默认为`true`。

#### `config.consider_all_requests_local`

是一个标志。如果为`true`，则任何错误都会导致在HTTP响应中转储详细的调试信息，并且`Rails::Info`控制器将在`/rails/info/properties`中显示应用程序运行时上下文。在开发和测试环境中默认为`true`，在生产环境中为`false`。为了更精细地控制，将其设置为`false`并在控制器中实现`show_detailed_exceptions?`以指定哪些请求应在错误时提供调试信息。

#### `config.console`

允许您设置在运行`bin/rails console`时将用作控制台的类。最好在`console`块中运行它：

```ruby
console do
  # 仅在运行控制台时调用此块，
  # 所以我们可以在这里安全地要求pry
  require "pry"
  config.console = Pry
end
```

#### `config.content_security_policy_nonce_directives`

请参阅安全指南中的[添加Nonce](security.html#adding-a-nonce)。

#### `config.content_security_policy_nonce_generator`

请参阅安全指南中的[添加Nonce](security.html#adding-a-nonce)。

#### `config.content_security_policy_report_only`

请参阅安全指南中的[报告违规行为](security.html#reporting-violations)。

#### `config.credentials.content_path`

加密凭据文件的路径。

如果存在，则默认为`config/credentials/#{Rails.env}.yml.enc`，否则为`config/credentials.yml.enc`。

注意：为了使`bin/rails credentials`命令识别此值，必须在`config/application.rb`或`config/environments/#{Rails.env}.rb`中设置它。

#### `config.credentials.key_path`

加密凭据密钥文件的路径。

如果存在，则默认为`config/credentials/#{Rails.env}.key`，否则为`config/master.key`。

注意：为了使`bin/rails credentials`命令识别此值，必须在`config/application.rb`或`config/environments/#{Rails.env}.rb`中设置它。
#### `config.debug_exception_response_format`

设置在开发环境中发生错误时响应的格式。对于仅限API的应用程序，默认为`:api`，对于普通应用程序，默认为`:default`。

#### `config.disable_sandbox`

控制是否允许在沙盒模式下启动控制台。这有助于避免长时间运行的沙盒控制台会导致数据库服务器内存耗尽。默认为`false`。

#### `config.eager_load`

当为`true`时，会急切加载所有注册的`config.eager_load_namespaces`。这包括您的应用程序、引擎、Rails框架和任何其他注册的命名空间。

#### `config.eager_load_namespaces`

在`config.eager_load`设置为`true`时注册需要急切加载的命名空间。列表中的所有命名空间都必须响应`eager_load!`方法。

#### `config.eager_load_paths`

如果`config.eager_load`为true，则接受一个路径数组，Rails将在启动时急切加载。默认为应用程序的`app`目录中的每个文件夹。

#### `config.enable_reloading`

如果`config.enable_reloading`为true，则在网络请求之间重新加载应用程序的类和模块（如果有更改）。在`development`环境中默认为`true`，在`production`环境中默认为`false`。

还定义了谓词`config.reloading_enabled?`。

#### `config.encoding`

设置应用程序的全局编码。默认为UTF-8。

#### `config.exceptions_app`

设置`ShowException`中间件在发生异常时调用的异常应用程序。默认为`ActionDispatch::PublicExceptions.new(Rails.public_path)`。

异常应用程序需要处理`ActionDispatch::Http::MimeNegotiation::InvalidType`错误，当客户端发送无效的`Accept`或`Content-Type`头时会引发此错误。
默认的`ActionDispatch::PublicExceptions`应用程序会自动处理此错误，将`Content-Type`设置为`text/html`并返回`406 Not Acceptable`状态。
未能处理此错误将导致`500 Internal Server Error`。

使用`Rails.application.routes` `RouteSet`作为异常应用程序还需要进行特殊处理。
可能看起来像这样：

```ruby
# config/application.rb
config.exceptions_app = CustomExceptionsAppWrapper.new(exceptions_app: routes)

# lib/custom_exceptions_app_wrapper.rb
class CustomExceptionsAppWrapper
  def initialize(exceptions_app:)
    @exceptions_app = exceptions_app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    fallback_to_html_format_if_invalid_mime_type(request)

    @exceptions_app.call(env)
  end

  private
    def fallback_to_html_format_if_invalid_mime_type(request)
      request.formats
    rescue ActionDispatch::Http::MimeNegotiation::InvalidType
      request.set_header "CONTENT_TYPE", "text/html"
    end
end
```

#### `config.file_watcher`

用于在文件系统中检测文件更新的类，当`config.reload_classes_only_on_change`为`true`时使用。Rails默认使用`ActiveSupport::FileUpdateChecker`，还有`ActiveSupport::EventedFileUpdateChecker`（这个依赖于[listen](https://github.com/guard/listen) gem）。自定义类必须符合`ActiveSupport::FileUpdateChecker` API。

#### `config.filter_parameters`

用于过滤在日志中不想显示的参数，例如密码或信用卡号码。当调用Active Record对象的`#inspect`方法时，它还会过滤数据库列的敏感值。默认情况下，Rails通过在`config/initializers/filter_parameter_logging.rb`中添加以下过滤器来过滤密码。

```ruby
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

参数过滤器通过部分匹配正则表达式来工作。

#### `config.filter_redirect`

用于从应用程序日志中过滤重定向URL。

```ruby
Rails.application.config.filter_redirect += ['s3.amazonaws.com', /private-match/]
```

重定向过滤器通过测试URL是否包含字符串或匹配正则表达式来工作。

#### `config.force_ssl`

强制所有请求通过HTTPS进行服务，并将 "https://" 设置为生成URL时的默认协议。HTTPS的执行由`ActionDispatch::SSL`中间件处理，可以通过`config.ssl_options`进行配置。

#### `config.helpers_paths`
定义了一个用于加载视图助手的附加路径数组。

#### `config.host_authorization`

接受一个选项哈希来配置[HostAuthorization中间件](#actiondispatch-hostauthorization)。

#### `config.hosts`

一个字符串、正则表达式或`IPAddr`的数组，用于验证`Host`头。由[HostAuthorization中间件](#actiondispatch-hostauthorization)用于帮助防止DNS重绑定攻击。

#### `config.javascript_path`

设置应用程序的JavaScript相对于`app`目录的路径。默认值为`javascript`，由[webpacker](https://github.com/rails/webpacker)使用。应用程序配置的`javascript_path`将从`autoload_paths`中排除。

#### `config.log_file_size`

定义Rails日志文件的最大大小（以字节为单位）。在开发和测试环境中，默认值为`104_857_600`（100 MiB），在其他所有环境中为无限制。

#### `config.log_formatter`

定义Rails日志记录器的格式化程序。此选项默认为`ActiveSupport::Logger::SimpleFormatter`的实例，适用于所有环境。如果您为`config.logger`设置了一个值，您必须在将其包装在`ActiveSupport::TaggedLogging`实例中之前手动将格式化程序的值传递给日志记录器，Rails不会为您执行此操作。

#### `config.log_level`

定义Rails日志记录器的详细程度。此选项默认为所有环境的`:debug`，在生产环境中默认为`:info`。可用的日志级别有：`:debug`、`:info`、`:warn`、`:error`、`:fatal`和`:unknown`。

#### `config.log_tags`

接受一个`request`对象响应的方法列表、接受`request`对象的`Proc`，或者响应`to_s`的内容。这使得可以轻松地使用调试信息（如子域和请求ID）标记日志行，这在调试多用户生产应用程序时非常有帮助。

#### `config.logger`

用于`Rails.logger`和任何相关的Rails日志记录（如`ActiveRecord::Base.logger`）的日志记录器。默认为`ActiveSupport::TaggedLogging`的实例，它包装了一个输出日志到`log/`目录的`ActiveSupport::Logger`实例。您可以提供一个自定义的日志记录器，为了获得完全兼容性，您必须遵循以下准则：

* 要支持格式化程序，您必须手动将`config.log_formatter`的值分配给日志记录器。
* 要支持标记日志，日志实例必须使用`ActiveSupport::TaggedLogging`进行包装。
* 要支持静音，日志记录器必须包括`ActiveSupport::LoggerSilence`模块。`ActiveSupport::Logger`类已经包括了这些模块。

```ruby
class MyLogger < ::Logger
  include ActiveSupport::LoggerSilence
end

mylogger           = MyLogger.new(STDOUT)
mylogger.formatter = config.log_formatter
config.logger      = ActiveSupport::TaggedLogging.new(mylogger)
```

#### `config.middleware`

允许您配置应用程序的中间件。这在下面的[配置中间件](#configuring-middleware)部分中有详细介绍。

#### `config.precompile_filter_parameters`

当为`true`时，将使用[`ActiveSupport::ParameterFilter.precompile_filters`][]预编译[`config.filter_parameters`](#config-filter-parameters)。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.1      | `true`  |

#### `config.public_file_server.enabled`

配置Rails从public目录中提供静态文件。此选项默认为`true`，但在生产环境中设置为`false`，因为用于运行应用程序的服务器软件（如NGINX或Apache）应该提供静态文件。如果您在生产环境中使用WEBrick运行或测试应用程序（不建议在生产环境中使用WEBrick），请将该选项设置为`true`。否则，您将无法使用页面缓存和请求存在于public目录下的文件。
#### `config.railties_order`

允许手动指定加载Railties/Engines的顺序。默认值为`[:all]`。

```ruby
config.railties_order = [Blog::Engine, :main_app, :all]
```

#### `config.rake_eager_load`

当为`true`时，在运行Rake任务时急切加载应用程序。默认为`false`。

#### `config.read_encrypted_secrets`

*已弃用*：您应该使用[credentials](https://guides.rubyonrails.org/security.html#custom-credentials)代替加密的secrets。

当为`true`时，将尝试从`config/secrets.yml.enc`读取加密的secrets。

#### `config.relative_url_root`

可用于告诉Rails您正在[部署到子目录](configuring.html#deploy-to-a-subdirectory-relative-url-root)。默认值为`ENV['RAILS_RELATIVE_URL_ROOT']`。

#### `config.reload_classes_only_on_change`

启用或禁用仅在跟踪的文件更改时重新加载类。默认情况下，跟踪自动加载路径上的所有内容，并设置为`true`。如果`config.enable_reloading`为`false`，则忽略此选项。

#### `config.require_master_key`

如果通过`ENV["RAILS_MASTER_KEY"]`或`config/master.key`文件未提供主密钥，则导致应用程序无法启动。

#### `config.secret_key_base`

指定应用程序密钥生成器的输入密钥的后备。建议不设置此项，而是在`config/credentials.yml.enc`中指定`secret_key_base`。有关更多信息和替代配置方法，请参阅[`secret_key_base` API文档](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-secret_key_base)。

#### `config.server_timing`

当为`true`时，将[ServerTiming中间件](#actiondispatch-servertiming)添加到中间件堆栈中。

#### `config.session_options`

传递给`config.session_store`的附加选项。您应该使用`config.session_store`来设置它，而不是自己修改它。

```ruby
config.session_store :cookie_store, key: "_your_app_session"
config.session_options # => {key: "_your_app_session"}
```

#### `config.session_store`

指定用于存储会话的类。可能的值为`:cache_store`、`:cookie_store`、`:mem_cache_store`、自定义存储或`:disabled`。`:disabled`告诉Rails不处理会话。

此设置通过常规方法调用进行配置，而不是使用setter。这允许传递其他选项：

```ruby
config.session_store :cookie_store, key: "_your_app_session"
```

如果指定了一个自定义存储作为符号，则会解析为`ActionDispatch::Session`命名空间：

```ruby
# 使用ActionDispatch::Session::MyCustomStore作为会话存储
config.session_store :my_custom_store
```

默认存储是一个带有应用程序名称作为会话键的cookie存储。

#### `config.ssl_options`

[`ActionDispatch::SSL`](https://api.rubyonrails.org/classes/ActionDispatch/SSL.html)中间件的配置选项。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `{}`   |
| 5.0      | `{ hsts: { subdomains: true } }` |

#### `config.time_zone`

设置应用程序的默认时区，并为Active Record启用时区意识。

#### `config.x`

用于将嵌套的自定义配置轻松添加到应用程序配置对象中。

```ruby
config.x.payment_processing.schedule = :daily
Rails.configuration.x.payment_processing.schedule # => :daily
```

请参阅[自定义配置](#custom-configuration)

### 配置资产

#### `config.assets.css_compressor`

定义要使用的CSS压缩器。默认情况下由`sass-rails`设置。目前唯一的备选值是`:yui`，它使用`yui-compressor` gem。

#### `config.assets.js_compressor`

定义要使用的JavaScript压缩器。可能的值为`:terser`、`:closure`、`:uglifier`和`:yui`，分别需要使用`terser`、`closure-compiler`、`uglifier`或`yui-compressor` gem。

#### `config.assets.gzip`

一个标志，用于启用编译资产的gzip版本的创建，以及非gzip版本的资产。默认为`true`。

#### `config.assets.paths`

包含用于查找资产的路径。将路径附加到此配置选项将导致在搜索资产时使用这些路径。
#### `config.assets.precompile`

允许您指定在运行`bin/rails assets:precompile`时要预编译的其他资产（而不仅限于`application.css`和`application.js`）。

#### `config.assets.unknown_asset_fallback`

允许您修改当资产不在管道中时资产管道的行为，如果您使用的是sprockets-rails 3.2.0或更新版本。

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值 |
| ---------- | ------ |
| (原始)     | `true` |
| 5.1        | `false`|

#### `config.assets.prefix`

定义资产的前缀，从中提供资产。默认为`/assets`。

#### `config.assets.manifest`

定义要用于资产预编译器清单文件的完整路径。默认为公共文件夹中`config.assets.prefix`目录中名为`manifest-<random>.json`的文件。

#### `config.assets.digest`

启用在资产名称中使用SHA256指纹。默认为`true`。

#### `config.assets.debug`

禁用资产的合并和压缩。在`development.rb`中默认为`true`。

#### `config.assets.version`

是一个选项字符串，用于SHA256哈希生成。可以更改此选项以强制重新编译所有文件。

#### `config.assets.compile`

是一个布尔值，可用于在生产环境中启用实时Sprockets编译。

#### `config.assets.logger`

接受符合Log4r或默认Ruby `Logger`类接口的记录器。默认与`config.logger`配置相同。将`config.assets.logger`设置为`false`将关闭已提供资产的日志记录。

#### `config.assets.quiet`

禁用资产请求的日志记录。在`development.rb`中默认为`true`。

### 配置生成器

Rails允许您使用`config.generators`方法更改使用的生成器。此方法接受一个块：

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

可以在此块中使用的完整方法集如下：

* `force_plural`允许使用复数形式的模型名称。默认为`false`。
* `helper`定义是否生成辅助程序。默认为`true`。
* `integration_tool`定义要使用的集成工具来生成集成测试。默认为`:test_unit`。
* `system_tests`定义要使用的集成工具来生成系统测试。默认为`:test_unit`。
* `orm`定义要使用的ORM。默认为`false`，默认情况下使用Active Record。
* `resource_controller`定义在使用`bin/rails generate resource`时生成控制器的生成器。默认为`:controller`。
* `resource_route`定义是否生成资源路由定义。默认为`true`。
* `scaffold_controller`与`resource_controller`不同，定义在使用`bin/rails generate scaffold`时生成的脚手架控制器的生成器。默认为`:scaffold_controller`。
* `test_framework`定义要使用的测试框架。默认为`false`，默认情况下使用minitest。
* `template_engine`定义要使用的模板引擎，例如ERB或Haml。默认为`:erb`。

### 配置中间件

每个Rails应用程序都带有一组标准的中间件，它在开发环境中按照以下顺序使用：

#### `ActionDispatch::HostAuthorization`

防止DNS重新绑定和其他`Host`头攻击。默认情况下，它在开发环境中包含以下配置：

```ruby
Rails.application.config.hosts = [
  IPAddr.new("0.0.0.0/0"),        # 所有IPv4地址。
  IPAddr.new("::/0"),             # 所有IPv6地址。
  "localhost",                    # 保留的本地主机域。
  ENV["RAILS_DEVELOPMENT_HOSTS"]  # 用于开发的其他逗号分隔的主机。
]
```
在其他环境中，`Rails.application.config.hosts`为空，不会进行`Host`头检查。如果你想在生产环境中防范头攻击，你需要手动允许允许的主机：

```ruby
Rails.application.config.hosts << "product.com"
```

请求的主机将通过`hosts`条目与`case`操作符(`#===`)进行检查，这使得`hosts`支持`Regexp`、`Proc`和`IPAddr`等类型的条目。下面是一个使用正则表达式的示例。

```ruby
# 允许来自子域名如`www.product.com`和`beta1.product.com`的请求。
Rails.application.config.hosts << /.*\.product\.com/
```

提供的正则表达式将被包裹在两个锚点(`\A`和`\z`)中，因此它必须完全匹配主机名。例如，`/product.com/`一旦被锚定，将无法匹配`www.product.com`。

还支持一种特殊情况，允许你允许所有子域名：

```ruby
# 允许来自子域名如`www.product.com`和`beta1.product.com`的请求。
Rails.application.config.hosts << ".product.com"
```

你可以通过设置`config.host_authorization.exclude`来排除某些请求的主机授权检查：

```ruby
# 排除对/healthcheck/路径的主机检查
Rails.application.config.host_authorization = {
  exclude: ->(request) { request.path.include?('healthcheck') }
}
```

当一个请求到达未经授权的主机时，将运行一个默认的Rack应用程序，并响应`403 Forbidden`。你可以通过设置`config.host_authorization.response_app`来自定义它。例如：

```ruby
Rails.application.config.host_authorization = {
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

#### `ActionDispatch::ServerTiming`

在浏览器的开发工具中添加指标到`Server-Timing`头中进行查看。

#### `ActionDispatch::SSL`

强制使用HTTPS来提供每个请求。如果`config.force_ssl`设置为`true`，则启用。可以通过设置`config.ssl_options`来配置传递给它的选项。

#### `ActionDispatch::Static`

用于提供静态资源。如果`config.public_file_server.enabled`为`false`，则禁用。如果需要提供一个名为`index`的静态目录索引文件而不是`index.html`，请设置`config.public_file_server.index_name`。例如，要为目录请求提供`main.html`而不是`index.html`，请将`config.public_file_server.index_name`设置为`"main"`。

#### `ActionDispatch::Executor`

允许线程安全的代码重载。如果`config.allow_concurrency`为`false`，将禁用它，这将导致加载`Rack::Lock`。`Rack::Lock`在互斥锁中包装应用程序，因此只能由一个线程调用。

#### `ActiveSupport::Cache::Strategy::LocalCache`

作为一个基本的内存缓存。此缓存不是线程安全的，仅用于为单个线程提供临时内存缓存。

#### `Rack::Runtime`

设置一个包含执行请求所花费时间（以秒为单位）的`X-Runtime`头。

#### `Rails::Rack::Logger`

通知日志请求已开始。请求完成后，刷新所有日志。

#### `ActionDispatch::ShowExceptions`

捕获应用程序返回的任何异常，并在请求是本地的或`config.consider_all_requests_local`设置为`true`时，呈现漂亮的异常页面。如果`config.action_dispatch.show_exceptions`设置为`:none`，则无论如何都会引发异常。

#### `ActionDispatch::RequestId`

使唯一的X-Request-Id头在响应中可用，并启用`ActionDispatch::Request#uuid`方法。可以通过`config.action_dispatch.request_id_header`进行配置。

#### `ActionDispatch::RemoteIp`

检查IP欺骗攻击，并从请求头中获取有效的`client_ip`。可以通过`config.action_dispatch.ip_spoofing_check`和`config.action_dispatch.trusted_proxies`选项进行配置。

#### `Rack::Sendfile`

拦截从文件中提供响应体的响应，并用服务器特定的X-Sendfile头替换它。可以通过`config.action_dispatch.x_sendfile_header`进行配置。
#### `ActionDispatch::Callbacks`

在提供请求之前运行准备回调。

#### `ActionDispatch::Cookies`

为请求设置cookie。

#### `ActionDispatch::Session::CookieStore`

负责将会话存储在cookie中。可以通过更改[`config.session_store`](#config-session-store)来使用其他中间件。

#### `ActionDispatch::Flash`

设置`flash`键。仅当[`config.session_store`](#config-session-store)设置为某个值时才可用。

#### `Rack::MethodOverride`

如果设置了`params[:_method]`，则允许覆盖方法。这是支持PATCH、PUT和DELETE HTTP方法类型的中间件。

#### `Rack::Head`

将HEAD请求转换为GET请求并进行服务。

#### 添加自定义中间件

除了这些常规中间件外，您还可以使用`config.middleware.use`方法添加自己的中间件：

```ruby
config.middleware.use Magical::Unicorns
```

这将把`Magical::Unicorns`中间件放在堆栈的末尾。如果希望在其他中间件之前添加中间件，可以使用`insert_before`。

```ruby
config.middleware.insert_before Rack::Head, Magical::Unicorns
```

或者，您可以使用索引将中间件插入到确切的位置。例如，如果要将`Magical::Unicorns`中间件插入到堆栈顶部，可以这样做：

```ruby
config.middleware.insert_before 0, Magical::Unicorns
```

还有`insert_after`，它将在另一个中间件之后插入一个中间件：

```ruby
config.middleware.insert_after Rack::Head, Magical::Unicorns
```

中间件还可以完全替换为其他中间件：

```ruby
config.middleware.swap ActionController::Failsafe, Lifo::Failsafe
```

中间件可以从一个位置移动到另一个位置：

```ruby
config.middleware.move_before ActionDispatch::Flash, Magical::Unicorns
```

这将在`ActionDispatch::Flash`之前移动`Magical::Unicorns`中间件。您也可以在之后移动它：

```ruby
config.middleware.move_after ActionDispatch::Flash, Magical::Unicorns
```

它们也可以从堆栈中完全删除：

```ruby
config.middleware.delete Rack::MethodOverride
```

### 配置i18n

所有这些配置选项都委托给`I18n`库。

#### `config.i18n.available_locales`

定义应用程序允许的可用区域设置。默认为在区域设置文件中找到的所有区域键，通常在新应用程序上只有`:en`。

#### `config.i18n.default_locale`

设置用于i18n的应用程序的默认区域设置。默认为`:en`。

#### `config.i18n.enforce_available_locales`

确保通过i18n传递的所有区域设置必须在`available_locales`列表中声明，当设置不可用的区域设置时引发`I18n::InvalidLocale`异常。默认为`true`。除非强烈要求，否则建议不要禁用此选项，因为它作为防止从用户输入设置任何无效区域设置的安全措施。

#### `config.i18n.load_path`

设置Rails用于查找区域设置文件的路径。默认为`config/locales/**/*.{yml,rb}`。

#### `config.i18n.raise_on_missing_translations`

确定是否应为缺少的翻译引发错误。默认为`false`。

#### `config.i18n.fallbacks`

设置缺少翻译的回退行为。以下是此选项的3个用法示例：

  * 您可以将选项设置为`true`，以使用默认区域设置作为回退，如下所示：

    ```ruby
    config.i18n.fallbacks = true
    ```

  * 或者，您可以将区域设置数组设置为回退，如下所示：

    ```ruby
    config.i18n.fallbacks = [:tr, :en]
    ```

  * 或者，您可以为各个区域设置单独设置回退。例如，如果要将`:tr`用作`:az`和`:de`的回退，将`:en`用作`:da`的回退，可以这样做：

    ```ruby
    config.i18n.fallbacks = { az: :tr, da: [:de, :en] }
    #或
    config.i18n.fallbacks.map = { az: :tr, da: [:de, :en] }
    ```
### 配置Active Model

#### `config.active_model.i18n_customize_full_message`

控制是否可以在i18n语言环境文件中覆盖[`Error#full_message`][ActiveModel::Error#full_message]的格式。默认为`false`。

当设置为`true`时，`full_message`将在语言环境文件的属性和模型级别上查找格式。默认格式为`"%{attribute} %{message}"`，其中`attribute`是属性的名称，`message`是特定验证的消息。以下示例覆盖了所有`Person`属性的格式，以及特定`Person`属性（`age`）的格式。

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :age

  validates :name, :age, presence: true
end
```

```yml
en:
  activemodel: # or activerecord:
    errors:
      models:
        person:
          # 覆盖所有Person属性的格式：
          format: "无效的%{attribute}（%{message}）"
          attributes:
            age:
              # 覆盖age属性的格式：
              format: "%{message}"
              blank: "请填写您的%{attribute}"
```

```irb
irb> person = Person.new.tap(&:valid?)

irb> person.errors.full_messages
=> [
  "无效的Name（不能为空）",
  "请填写您的Age"
]

irb> person.errors.messages
=> {
  :name => ["不能为空"],
  :age  => ["请填写您的Age"]
}
```


### 配置Active Record

`config.active_record` 包含了各种配置选项：

#### `config.active_record.logger`

接受一个符合Log4r接口或默认的Ruby Logger类的记录器，然后传递给任何新建立的数据库连接。您可以通过在Active Record模型类或Active Record模型实例上调用`logger`来检索此记录器。设置为`nil`以禁用日志记录。

#### `config.active_record.primary_key_prefix_type`

允许您调整主键列的命名方式。默认情况下，Rails假设主键列的名称为`id`（不需要设置此配置选项）。还有其他两个选择：

* `:table_name` 会使Customer类的主键为`customerid`。
* `:table_name_with_underscore` 会使Customer类的主键为`customer_id`。

#### `config.active_record.table_name_prefix`

允许您设置一个全局字符串作为表名的前缀。如果将其设置为`northwest_`，那么Customer类将在`northwest_customers`表中查找数据。默认为空字符串。

#### `config.active_record.table_name_suffix`

允许您设置一个全局字符串作为表名的后缀。如果将其设置为`_northwest`，那么Customer类将在`customers_northwest`表中查找数据。默认为空字符串。

#### `config.active_record.schema_migrations_table_name`

允许您设置一个字符串作为模式迁移表的名称。

#### `config.active_record.internal_metadata_table_name`

允许您设置一个字符串作为内部元数据表的名称。

#### `config.active_record.protected_environments`

允许您设置一个环境名称数组，其中禁止执行破坏性操作。

#### `config.active_record.pluralize_table_names`

指定Rails在数据库中查找单数还是复数表名。如果设置为`true`（默认值），那么Customer类将使用`customers`表。如果设置为`false`，那么Customer类将使用`customer`表。

#### `config.active_record.default_timezone`

确定从数据库中获取日期和时间时是否使用`Time.local`（如果设置为`:local`）或`Time.utc`（如果设置为`:utc`）。默认为`:utc`。
#### `config.active_record.schema_format`

控制将数据库模式转储到文件的格式。选项为`:ruby`（默认）表示依赖于迁移的与数据库无关的版本，或者`:sql`表示一组（可能与数据库相关的）SQL语句。

#### `config.active_record.error_on_ignored_order`

指定在批量查询期间忽略查询顺序时是否引发错误。选项为`true`（引发错误）或`false`（警告）。默认值为`false`。

#### `config.active_record.timestamped_migrations`

控制迁移是否使用序列整数或时间戳进行编号。默认值为`true`，使用时间戳进行编号，如果有多个开发人员在同一应用程序上工作，则优先使用时间戳。

#### `config.active_record.db_warnings_action`

控制当SQL查询产生警告时要采取的操作。可用的选项有：

  * `:ignore` - 忽略数据库警告。这是默认值。

  * `:log` - 通过`ActiveRecord.logger`以`：warn`级别记录数据库警告。

  * `:raise` - 将数据库警告作为`ActiveRecord::SQLWarning`引发。

  * `:report` - 将数据库警告报告给Rails错误报告器的订阅者。

  * 自定义proc - 可以提供自定义proc。它应该接受一个`SQLWarning`错误对象。

    例如：

    ```ruby
    config.active_record.db_warnings_action = ->(warning) do
      # 报告给自定义异常报告服务
      Bugsnag.notify(warning.message) do |notification|
        notification.add_metadata(:warning_code, warning.code)
        notification.add_metadata(:warning_level, warning.level)
      end
    end
    ```

#### `config.active_record.db_warnings_ignore`

指定要忽略的警告代码和消息的允许列表，无论配置的`db_warnings_action`如何。默认行为是报告所有警告。要忽略的警告可以指定为字符串或正则表达式。例如：

  ```ruby
  config.active_record.db_warnings_action = :raise
  # 不会引发以下警告
  config.active_record.db_warnings_ignore = [
    /Invalid utf8mb4 character string/,
    "An exact warning message",
    "1062", # MySQL Error 1062: Duplicate entry
  ]
  ```

#### `config.active_record.migration_strategy`

控制在迁移中执行模式语句方法的策略类。默认类委托给连接适配器。自定义策略应该继承自`ActiveRecord::Migration::ExecutionStrategy`，或者可以继承自`DefaultStrategy`，它将保留未实现方法的默认行为：

```ruby
class CustomMigrationStrategy < ActiveRecord::Migration::DefaultStrategy
  def drop_table(*)
    raise "Dropping tables is not supported!"
  end
end

config.active_record.migration_strategy = CustomMigrationStrategy
```

#### `config.active_record.lock_optimistically`

控制Active Record是否使用乐观锁定，默认值为`true`。

#### `config.active_record.cache_timestamp_format`

控制缓存键中时间戳值的格式。默认值为`:usec`。

#### `config.active_record.record_timestamps`

是一个布尔值，控制是否对模型上的`create`和`update`操作进行时间戳记录。默认值为`true`。

#### `config.active_record.partial_inserts`

是一个布尔值，控制在创建新记录时是否使用部分写入（即仅设置与默认值不同的属性）。默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| （原始） | `true` |
| 7.0      | `false`|

#### `config.active_record.partial_updates`

是一个布尔值，控制在更新现有记录时是否使用部分写入（即仅设置脏属性）。请注意，当使用部分更新时，应该同时使用乐观锁定`config.active_record.lock_optimistically`，因为并发更新可能会基于可能过时的读取状态写入属性。默认值为`true`。
#### `config.active_record.maintain_test_schema`

是一个布尔值，用于控制在运行测试时，Active Record是否应尝试将测试数据库模式与`db/schema.rb`（或`db/structure.sql`）保持同步。默认值为`true`。

#### `config.active_record.dump_schema_after_migration`

是一个标志，用于控制在运行迁移时是否进行模式转储（`db/schema.rb`或`db/structure.sql`）。在由Rails生成的`config/environments/production.rb`中设置为`false`。如果未设置此配置，则默认值为`true`。

#### `config.active_record.dump_schemas`

控制在调用`db:schema:dump`时要转储的数据库模式。选项有`：schema_search_path`（默认值），它会转储`schema_search_path`中列出的任何模式，`:all`始终转储所有模式，而不考虑`schema_search_path`，或者以逗号分隔的模式字符串。

#### `config.active_record.before_committed_on_all_records`

在事务中的所有已注册记录上启用before_committed！回调。以前的行为是，如果事务中有多个相同的记录副本，则仅在第一个副本上运行回调。

| 版本开始 | 默认值 |
| -------- | ------ |
| （原始） | `false` |
| 7.1      | `true`  |

#### `config.active_record.belongs_to_required_by_default`

是一个布尔值，用于控制如果`belongs_to`关联不存在，则记录是否失败验证。

默认值取决于`config.load_defaults`目标版本：

| 版本开始 | 默认值 |
| -------- | ------ |
| （原始） | `nil`  |
| 5.0      | `true` |

#### `config.active_record.belongs_to_required_validates_foreign_key`

在父记录是必需的情况下，仅验证与父记录相关的列是否存在。以前的行为是验证父记录的存在，这会在每次更新子记录时执行额外的查询，即使父记录没有更改。

| 版本开始 | 默认值 |
| -------- | ------ |
| （原始） | `true` |
| 7.1      | `false` |

#### `config.active_record.marshalling_format_version`

当设置为`7.1`时，启用使用`Marshal.dump`更高效的Active Record实例序列化。

这会更改序列化格式，因此使用此方式序列化的模型无法被旧版本（<7.1）的Rails读取。但是，仍然可以读取使用旧格式的消息，无论是否启用了此优化。

| 版本开始 | 默认值 |
| -------- | ------ |
| （原始） | `6.1`  |
| 7.1      | `7.1`  |

#### `config.active_record.action_on_strict_loading_violation`

如果在关联上设置了strict_loading，则启用引发或记录异常。在所有环境中，默认值为`:raise`。可以将其更改为`:log`，以将违规情况发送到日志记录器而不是引发异常。

#### `config.active_record.strict_loading_by_default`

是一个布尔值，用于默认启用或禁用strict_loading模式。默认为`false`。

#### `config.active_record.warn_on_records_fetched_greater_than`

允许设置查询结果大小的警告阈值。如果查询返回的记录数超过阈值，则会记录警告。这可用于识别可能导致内存膨胀的查询。

#### `config.active_record.index_nested_attribute_errors`

允许在嵌套的`has_many`关系中显示带有索引的错误。默认为`false`。
#### `config.active_record.use_schema_cache_dump`

启用从 `db/schema_cache.yml` 中获取模式缓存信息（由 `bin/rails db:schema:cache:dump` 生成），而不是必须向数据库发送查询以获取此信息。默认为 `true`。

#### `config.active_record.cache_versioning`

指示是否使用伴随 `#cache_version` 方法中的变化版本的稳定 `#cache_key` 方法。

默认值取决于 `config.load_defaults` 目标版本：

| 从版本开始 | 默认值 |
| ---------- | ------ |
| (原始)     | `false` |
| 5.2        | `true`  |

#### `config.active_record.collection_cache_versioning`

当被缓存的对象类型为 `ActiveRecord::Relation` 且发生更改时，通过将关系的缓存键的易变信息（最大更新时间和计数）移入缓存版本来支持重用缓存键。

默认值取决于 `config.load_defaults` 目标版本：

| 从版本开始 | 默认值 |
| ---------- | ------ |
| (原始)     | `false` |
| 6.0        | `true`  |

#### `config.active_record.has_many_inversing`

在遍历 `belongs_to` 到 `has_many` 关联时，启用设置反向记录。

默认值取决于 `config.load_defaults` 目标版本：

| 从版本开始 | 默认值 |
| ---------- | ------ |
| (原始)     | `false` |
| 6.1        | `true`  |

#### `config.active_record.automatic_scope_inversing`

启用自动推断具有作用域的关联的 `inverse_of`。

默认值取决于 `config.load_defaults` 目标版本：

| 从版本开始 | 默认值 |
| ---------- | ------ |
| (原始)     | `false` |
| 7.0        | `true`  |

#### `config.active_record.destroy_association_async_job`

允许指定在后台销毁关联记录时将使用的作业。默认为 `ActiveRecord::DestroyAssociationAsyncJob`。

#### `config.active_record.destroy_association_async_batch_size`

允许指定在 `dependent: :destroy_async` 关联选项中通过后台作业销毁的最大记录数。其他条件相同，较小的批处理大小将会排队更多、运行时间较短的后台作业，而较大的批处理大小将会排队较少、运行时间较长的后台作业。此选项默认为 `nil`，这将导致给定关联的所有相关记录在同一个后台作业中被销毁。

#### `config.active_record.queues.destroy`

允许指定用于销毁作业的 Active Job 队列。当此选项为 `nil` 时，清除作业将被发送到默认的 Active Job 队列（参见 `config.active_job.default_queue_name`）。默认为 `nil`。

#### `config.active_record.enumerate_columns_in_select_statements`

当为 `true` 时，将始终在 `SELECT` 语句中包含列名，并避免使用通配符 `SELECT * FROM ...` 查询。这样可以避免在向 PostgreSQL 数据库添加列时出现准备好的语句缓存错误。默认为 `false`。

#### `config.active_record.verify_foreign_keys_for_fixtures`

在测试中加载 fixture 后，确保所有外键约束有效。仅支持 PostgreSQL 和 SQLite。

默认值取决于 `config.load_defaults` 目标版本：

| 从版本开始 | 默认值 |
| ---------- | ------ |
| (原始)     | `false` |
| 7.0        | `true`  |

#### `config.active_record.raise_on_assign_to_attr_readonly`

启用对 attr_readonly 属性赋值时引发错误。先前的行为允许赋值，但不会将更改持久化到数据库中。

| 从版本开始 | 默认值 |
| ---------- | ------ |
| (原始)     | `false` |
| 7.1        | `true`  |
#### `config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`

当多个Active Record实例在事务中更改同一条记录时，Rails只会对其中一个实例运行`after_commit`或`after_rollback`回调。此选项指定Rails如何选择接收回调的实例。

当为`true`时，事务回调将在第一个保存的实例上运行，即使其实例状态可能已过时。

当为`false`时，事务回调将在具有最新实例状态的实例上运行。选择这些实例的规则如下：

- 通常情况下，在事务中最后一个保存给定记录的实例上运行事务回调。
- 有两个例外情况：
    - 如果记录在事务中创建，然后由另一个实例更新，则`after_create_commit`回调将在第二个实例上运行。这是根据该实例的状态而运行的`after_update_commit`回调的替代方法。
    - 如果记录在事务中被销毁，则`after_destroy_commit`回调将在最后一个被销毁的实例上触发，即使之后的过时实例执行了更新（这将影响0行）。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `true` |
| 7.1      | `false`|

#### `config.active_record.default_column_serializer`

如果没有为给定列显式指定序列化器，则使用的序列化器实现。

历史上，`serialize`和`store`虽然允许使用替代的序列化器实现，默认情况下使用`YAML`，但这不是一个非常高效的格式，如果不小心使用可能会导致安全漏洞。

因此，建议优先选择更严格、更有限的格式进行数据库序列化。

不幸的是，Ruby标准库中没有真正合适的默认值。`JSON`可以作为一种格式，但是`json`宝石会将不支持的类型转换为字符串，这可能会导致错误。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `YAML` |
| 7.1      | `nil`  |

#### `config.active_record.run_after_transaction_callbacks_in_order_defined`

如果为`true`，则按照模型中定义的顺序执行`after_commit`回调。如果为`false`，则按相反的顺序执行。

所有其他回调始终按照模型中定义的顺序执行（除非使用`prepend: true`）。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.1      | `true`  |

#### `config.active_record.query_log_tags_enabled`

指定是否启用适配器级别的查询注释。默认为`false`。

注意：当设置为`true`时，数据库预处理语句将自动禁用。

#### `config.active_record.query_log_tags`

定义一个`Array`，指定要插入到SQL注释中的键/值标签。默认为`[:application]`，一个预定义的标签，返回应用程序名称。

#### `config.active_record.query_log_tags_format`

指定用于标签的格式化程序的`Symbol`。有效值为`:sqlcommenter`和`:legacy`。

默认值取决于`config.load_defaults`目标版本：
| 版本开始 | 默认值 |
| -------- | ------ |
| (原始)   | `:legacy` |
| 7.1      | `:sqlcommenter` |

#### `config.active_record.cache_query_log_tags`

指定是否启用查询日志标签的缓存。对于有大量查询的应用程序，在请求或作业执行的生命周期内上下文不发生变化时，缓存查询日志标签可以提供性能优势。默认值为 `false`。

#### `config.active_record.schema_cache_ignored_tables`

定义在生成模式缓存时应忽略的表的列表。它接受一个字符串数组，表示表名或正则表达式。

#### `config.active_record.verbose_query_logs`

指定是否在相关查询下方记录调用数据库查询的方法的源位置。默认情况下，在开发环境中为 `true`，在其他所有环境中为 `false`。

#### `config.active_record.sqlite3_adapter_strict_strings_by_default`

指定是否默认使用 SQLite3Adapter 的严格字符串模式。使用严格字符串模式会禁用双引号括起来的字符串文字。

SQLite 在处理双引号括起来的字符串文字时存在一些特殊情况。它首先尝试将双引号字符串视为标识符名称，但如果它们不存在，则将其视为字符串文字。因此，拼写错误可能会悄悄地被忽略。例如，可以为不存在的列创建索引。有关更多详细信息，请参阅 [SQLite 文档](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted)。

默认值取决于 `config.load_defaults` 的目标版本：

| 版本开始 | 默认值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.1      | `true`  |

#### `config.active_record.async_query_executor`

指定异步查询如何进行池化。

默认值为 `nil`，表示禁用 `load_async`，而是直接在前台执行查询。
要实际异步执行查询，必须将其设置为 `:global_thread_pool` 或 `:multi_thread_pool`。

`:global_thread_pool` 将为应用程序连接的所有数据库使用单个池。这是仅有一个数据库的应用程序或每次只查询一个数据库分片的应用程序的首选配置。

`:multi_thread_pool` 将为每个数据库使用一个池，并且可以在 `database.yml` 中通过 `max_threads` 和 `min_thread` 属性单独配置每个池的大小。这对于定期查询多个数据库并且需要更精确地定义最大并发性的应用程序非常有用。

#### `config.active_record.global_executor_concurrency`

与 `config.active_record.async_query_executor = :global_thread_pool` 结合使用，定义可以同时执行多少个异步查询。

默认值为 `4`。

这个数字必须与在 `database.yml` 中配置的数据库连接池大小相一致。连接池应足够大，以容纳前台线程（例如 Web 服务器或作业工作线程）和后台线程。

#### `config.active_record.allow_deprecated_singular_associations_name`

启用已弃用行为，其中可以在 `where` 子句中使用复数名称引用单数关联。将其设置为 `false` 可提高性能。

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end

Comment.where(post: post_id).count  # => 5

# 当 `allow_deprecated_singular_associations_name` 为 true 时：
Comment.where(posts: post_id).count # => 5（弃用警告）

# 当 `allow_deprecated_singular_associations_name` 为 false 时：
Comment.where(posts: post_id).count # => 错误
```

默认值取决于 `config.load_defaults` 的目标版本：
| 从版本开始 | 默认值为 |
| --------------------- | -------------------- |
| (原始)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.yaml_column_permitted_classes`

默认为`[Symbol]`。允许应用程序在`ActiveRecord::Coders::YAMLColumn`的`safe_load()`上包含其他允许的类。

#### `config.active_record.use_yaml_unsafe_load`

默认为`false`。允许应用程序选择在`ActiveRecord::Coders::YAMLColumn`上使用`unsafe_load`。

#### `config.active_record.raise_int_wider_than_64bit`

默认为`true`。确定当PostgreSQL适配器提供比有符号64位表示更宽的整数时是否引发异常。

#### `ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans`和`ActiveRecord::ConnectionAdapters::TrilogyAdapter.emulate_booleans`

控制Active Record MySQL适配器是否将所有`tinyint(1)`列视为布尔值。默认为`true`。

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.create_unlogged_tables`

控制PostgreSQL创建的数据库表是否为“unlogged”，这可以提高性能，但如果数据库崩溃会增加数据丢失的风险。强烈建议您不要在生产环境中启用此功能。在所有环境中默认为`false`。

要在测试中启用此功能：

```ruby
# config/environments/test.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.create_unlogged_tables = true
end
```

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type`

控制Active Record PostgreSQL适配器在迁移或模式中调用`datetime`时应使用的本机类型。它接受一个符号，必须对应于配置的`NATIVE_DATABASE_TYPES`之一。默认值为`:timestamp`，意味着迁移中的`t.datetime`将创建一个“没有时区的时间戳”列。

要使用“带时区的时间戳”：

```ruby
# config/application.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.datetime_type = :timestamptz
end
```

如果更改了此设置，应运行`bin/rails db:migrate`以重建您的schema.rb。

#### `ActiveRecord::SchemaDumper.ignore_tables`

接受一个表的数组，这些表不应包含在任何生成的模式文件中。

#### `ActiveRecord::SchemaDumper.fk_ignore_pattern`

允许设置一个不同的正则表达式，用于决定是否将外键的名称转储到db/schema.rb。默认情况下，以`fk_rails_`开头的外键名称不会导出到数据库模式转储中。默认为`/^fk_rails_[0-9a-f]{10}$/`。

#### `config.active_record.encryption.hash_digest_class`

设置Active Record Encryption使用的摘要算法。

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值为      |
|-----------------------|---------------------------|
| (原始)            | `OpenSSL::Digest::SHA1`   |
| 7.1                   | `OpenSSL::Digest::SHA256` |

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

启用对使用SHA-1摘要类加密的现有数据的支持。当为`false`时，它只支持在`config.active_record.encryption.hash_digest_class`中配置的摘要。

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值为 |
|-----------------------|----------------------|
| (原始)            | `true`               |
| 7.1                   | `false`              |

### 配置Action Controller

`config.action_controller`包括一些配置设置：

#### `config.action_controller.asset_host`

设置资源的主机。当使用CDN来托管资源而不是应用程序服务器本身时很有用。只有在Action Mailer有不同的配置时才应使用此选项，否则请使用`config.asset_host`。

#### `config.action_controller.perform_caching`

配置应用程序是否应执行Action Controller组件提供的缓存功能。在开发环境中设置为`false`，在生产环境中设置为`true`。如果未指定，则默认值为`true`。

#### `config.action_controller.default_static_extension`

配置用于缓存页面的扩展名。默认为`.html`。
#### `config.action_controller.include_all_helpers`

配置是否在任何地方都可以使用所有视图帮助方法，还是仅限于相应的控制器。如果设置为`false`，则`UsersHelper`方法仅在作为`UsersController`的一部分呈现的视图中可用。如果设置为`true`，则`UsersHelper`方法在任何地方都可用。默认配置行为（当此选项未明确设置为`true`或`false`时）是所有视图帮助方法对每个控制器都可用。

#### `config.action_controller.logger`

接受符合Log4r接口或默认的Ruby Logger类的日志记录器，用于记录Action Controller的信息。设置为`nil`以禁用日志记录。

#### `config.action_controller.request_forgery_protection_token`

设置RequestForgery的令牌参数名称。调用`protect_from_forgery`默认将其设置为`:authenticity_token`。

#### `config.action_controller.allow_forgery_protection`

启用或禁用CSRF保护。默认情况下，在测试环境中为`false`，在其他所有环境中为`true`。

#### `config.action_controller.forgery_protection_origin_check`

配置是否应检查HTTP `Origin`头与站点的来源是否匹配，作为额外的CSRF防御。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)   | `false` |
| 5.0     | `true`  |

#### `config.action_controller.per_form_csrf_tokens`

配置CSRF令牌是否仅对生成它们的方法/操作有效。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)   | `false` |
| 5.0     | `true`  |

#### `config.action_controller.default_protect_from_forgery`

确定是否在`ActionController::Base`上添加伪造保护。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)   | `false` |
| 5.2     | `true`  |

#### `config.action_controller.relative_url_root`

可用于告诉Rails您正在[部署到子目录](configuring.html#deploy-to-a-subdirectory-relative-url-root)。默认值为[`config.relative_url_root`](#config-relative-url-root)。

#### `config.action_controller.permit_all_parameters`

默认允许所有参数进行批量赋值。默认值为`false`。

#### `config.action_controller.action_on_unpermitted_parameters`

控制在发现未明确允许的参数时的行为。默认值在测试和开发环境中为`:log`，否则为`false`。可能的值为：

* `false`表示不采取任何操作
* `:log`表示在`unpermitted_parameters.action_controller`主题上发出`ActiveSupport::Notifications.instrument`事件并以DEBUG级别记录
* `:raise`表示引发`ActionController::UnpermittedParameters`异常

#### `config.action_controller.always_permitted_parameters`

设置默认情况下允许的参数列表。默认值为`['controller', 'action']`。

#### `config.action_controller.enable_fragment_cache_logging`

确定是否以详细格式记录片段缓存的读取和写入，如下所示：

```
Read fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/d0bdf2974e1ef6d31685c3b392ad0b74 (0.6ms)
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Write fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/3b4e249ac9d168c617e32e84b99218b5 (1.1ms)
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

默认情况下，它设置为`false`，结果如下所示：

```
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

#### `config.action_controller.raise_on_open_redirects`

当发生未经许可的开放重定向时，引发`ActionController::Redirecting::UnsafeRedirectError`。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)   | `false` |
| 7.0     | `true`  |
#### `config.action_controller.log_query_tags_around_actions`

确定是否通过`around_filter`自动更新查询标签的控制器上下文。默认值为`true`。

#### `config.action_controller.wrap_parameters_by_default`

配置[`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)以默认包装json请求。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.0      | `true`  |

#### `ActionController::Base.wrap_parameters`

配置[`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)。可以在顶层或单个控制器上调用。

#### `config.action_controller.allow_deprecated_parameters_hash_equality`

控制`ActionController::Parameters#==`与`Hash`参数的行为。设置的值决定了一个`ActionController::Parameters`实例是否等于一个等效的`Hash`。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `true` |
| 7.1      | `false` |

### 配置Action Dispatch

#### `config.action_dispatch.cookies_serializer`

指定用于cookies的序列化器。接受与[`config.active_support.message_serializer`](#config-active-support-message-serializer)相同的值，以及`：hybrid`，它是`：json_allow_marshal`的别名。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值   |
| -------- | -------- |
| (原始)   | `:marshal` |
| 7.0      | `:json`    |

#### `config.action_dispatch.debug_exception_log_level`

配置DebugExceptions中间件在记录请求期间的未捕获异常时使用的日志级别。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值   |
| -------- | -------- |
| (原始)   | `:fatal` |
| 7.1      | `:error` |

#### `config.action_dispatch.default_headers`

是一个包含每个响应中默认设置的HTTP头的哈希。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "1; mode=block",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.0      | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.1      | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |

#### `config.action_dispatch.default_charset`

指定所有渲染的默认字符集。默认为`nil`。

#### `config.action_dispatch.tld_length`

设置应用程序的顶级域名（TLD）长度。默认为`1`。

#### `config.action_dispatch.ignore_accept_header`

用于确定是否忽略请求的接受头。默认为`false`。

#### `config.action_dispatch.x_sendfile_header`

指定服务器特定的X-Sendfile头。这对于从服务器加速文件发送很有用。例如，可以将其设置为Apache的'X-Sendfile'。

#### `config.action_dispatch.http_auth_salt`

设置HTTP Auth盐值。默认为`'http authentication'`。

#### `config.action_dispatch.signed_cookie_salt`

设置签名cookie的盐值。默认为`'signed cookie'`。

#### `config.action_dispatch.encrypted_cookie_salt`

设置加密cookie的盐值。默认为`'encrypted cookie'`。

#### `config.action_dispatch.encrypted_signed_cookie_salt`

设置签名加密cookie的盐值。默认为`'signed encrypted cookie'`。

#### `config.action_dispatch.authenticated_encrypted_cookie_salt`

设置经过身份验证的加密cookie的盐值。默认为`'authenticated encrypted cookie'`。

#### `config.action_dispatch.encrypted_cookie_cipher`

设置用于加密cookie的密码。默认为`"aes-256-gcm"`。
#### `config.action_dispatch.signed_cookie_digest`

设置用于签名 cookie 的摘要算法，默认为 `"SHA1"`。

#### `config.action_dispatch.cookies_rotations`

允许对加密和签名的 cookie 进行密钥、密码和摘要的轮换。

#### `config.action_dispatch.use_authenticated_cookie_encryption`

控制签名和加密的 cookie 是否使用 AES-256-GCM 密码算法或较旧的 AES-256-CBC 密码算法。

默认值取决于 `config.load_defaults` 的目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)  | `false` |
| 5.2     | `true`  |

#### `config.action_dispatch.use_cookies_with_metadata`

启用在 cookie 中嵌入目的元数据。

默认值取决于 `config.load_defaults` 的目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)  | `false` |
| 6.0     | `true`  |

#### `config.action_dispatch.perform_deep_munge`

配置是否对参数执行 `deep_munge` 方法。有关更多信息，请参见[安全指南](security.html#unsafe-query-generation)。默认值为 `true`。

#### `config.action_dispatch.rescue_responses`

配置将哪些异常分配给 HTTP 状态码。它接受一个哈希，您可以指定异常/状态码的对。默认情况下，配置如下：

```ruby
config.action_dispatch.rescue_responses = {
  'ActionController::RoutingError'
    => :not_found,
  'AbstractController::ActionNotFound'
    => :not_found,
  'ActionController::MethodNotAllowed'
    => :method_not_allowed,
  'ActionController::UnknownHttpMethod'
    => :method_not_allowed,
  'ActionController::NotImplemented'
    => :not_implemented,
  'ActionController::UnknownFormat'
    => :not_acceptable,
  'ActionController::InvalidAuthenticityToken'
    => :unprocessable_entity,
  'ActionController::InvalidCrossOriginRequest'
    => :unprocessable_entity,
  'ActionDispatch::Http::Parameters::ParseError'
    => :bad_request,
  'ActionController::BadRequest'
    => :bad_request,
  'ActionController::ParameterMissing'
    => :bad_request,
  'Rack::QueryParser::ParameterTypeError'
    => :bad_request,
  'Rack::QueryParser::InvalidParameterError'
    => :bad_request,
  'ActiveRecord::RecordNotFound'
    => :not_found,
  'ActiveRecord::StaleObjectError'
    => :conflict,
  'ActiveRecord::RecordInvalid'
    => :unprocessable_entity,
  'ActiveRecord::RecordNotSaved'
    => :unprocessable_entity
}
```

未配置的任何异常将映射到 500 Internal Server Error。

#### `config.action_dispatch.cookies_same_site_protection`

配置在设置 cookie 时 `SameSite` 属性的默认值。当设置为 `nil` 时，不会添加 `SameSite` 属性。要根据请求动态配置 `SameSite` 属性的值，可以指定一个 proc。例如：

```ruby
config.action_dispatch.cookies_same_site_protection = ->(request) do
  :strict unless request.user_agent == "TestAgent"
end
```

默认值取决于 `config.load_defaults` 的目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)  | `nil`  |
| 6.1     | `:lax` |

#### `config.action_dispatch.ssl_default_redirect_status`

配置在 `ActionDispatch::SSL` 中间件将非 GET/HEAD 请求从 HTTP 重定向到 HTTPS 时使用的默认 HTTP 状态码。

默认值取决于 `config.load_defaults` 的目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)  | `307`  |
| 6.1     | `308`  |

#### `config.action_dispatch.log_rescued_responses`

启用记录在 `rescue_responses` 中配置的未处理异常。默认为 `true`。

#### `ActionDispatch::Callbacks.before`

在请求之前运行一段代码块。

#### `ActionDispatch::Callbacks.after`

在请求之后运行一段代码块。

### 配置 Action View

`config.action_view` 包含一小部分配置设置：

#### `config.action_view.cache_template_loading`

控制是否在每个请求上重新加载模板。默认为 `!config.enable_reloading`。

#### `config.action_view.field_error_proc`

为显示来自 Active Model 的错误提供一个 HTML 生成器。该块在 Action View 模板的上下文中评估。默认为

```ruby
Proc.new { |html_tag, instance| content_tag :div, html_tag, class: "field_with_errors" }
```

#### `config.action_view.default_form_builder`

告诉 Rails 默认使用哪个表单构建器。默认为 `ActionView::Helpers::FormBuilder`。如果希望在初始化后加载表单构建器类（以便在开发环境中每个请求都重新加载），可以将其作为字符串传递。
#### `config.action_view.logger`

接受符合 Log4r 或默认的 Ruby Logger 类接口的日志记录器，用于记录 Action View 的信息。设置为 `nil` 以禁用日志记录。

#### `config.action_view.erb_trim_mode`

指定 ERB 使用的修剪模式。默认为 `'-'`，当使用 `<%= -%>` 或 `<%= =%>` 时，会修剪尾部的空格和换行符。更多信息请参阅 [Erubis 文档](http://www.kuwata-lab.com/erubis/users-guide.06.html#topics-trimspaces)。

#### `config.action_view.frozen_string_literal`

使用 `# frozen_string_literal: true` 魔术注释编译 ERB 模板，使所有字符串字面量都是冻结的，从而节省内存分配。设置为 `true` 以在所有视图中启用该功能。

#### `config.action_view.embed_authenticity_token_in_remote_forms`

允许您设置 `remote: true` 表单中 `authenticity_token` 的默认行为。默认情况下，它设置为 `false`，这意味着远程表单不会包含 `authenticity_token`，这在对表单进行片段缓存时很有帮助。远程表单从 `meta` 标签获取真实性，因此嵌入是不必要的，除非您支持没有 JavaScript 的浏览器。在这种情况下，您可以将 `authenticity_token: true` 作为表单选项传递，或者将此配置设置为 `true`。

#### `config.action_view.prefix_partial_path_with_controller_namespace`

确定是否从命名空间控制器渲染的模板中的子目录中查找局部视图。例如，考虑一个名为 `Admin::ArticlesController` 的控制器，它渲染以下模板：

```erb
<%= render @article %>
```

默认设置为 `true`，将使用位于 `/admin/articles/_article.erb` 的局部视图。将值设置为 `false` 将渲染 `/articles/_article.erb`，这与从非命名空间控制器（如 `ArticlesController`）渲染的行为相同。

#### `config.action_view.automatically_disable_submit_tag`

确定是否在点击时自动禁用 `submit_tag`，默认为 `true`。

#### `config.action_view.debug_missing_translation`

确定是否将缺失的翻译键包装在 `<span>` 标签中。默认为 `true`。

#### `config.action_view.form_with_generates_remote_forms`

确定 `form_with` 是否生成远程表单。

默认值取决于 `config.load_defaults` 的目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| 5.1     | `true` |
| 6.1     | `false`|

#### `config.action_view.form_with_generates_ids`

确定 `form_with` 是否在输入元素上生成 id。

默认值取决于 `config.load_defaults` 的目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)   | `false` |
| 5.2     | `true` |

#### `config.action_view.default_enforce_utf8`

确定是否在生成的表单中使用隐藏标签来强制旧版本的 Internet Explorer 提交以 UTF-8 编码的表单。

默认值取决于 `config.load_defaults` 的目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)   | `true` |
| 6.0     | `false` |

#### `config.action_view.image_loading`

为 `image_tag` 辅助方法渲染的 `<img>` 标签的 `loading` 属性指定默认值。例如，当设置为 `"lazy"` 时，由 `image_tag` 渲染的 `<img>` 标签将包含 `loading="lazy"`，这会[指示浏览器在图像接近视口时加载它](https://html.spec.whatwg.org/#lazy-loading-attributes)。（仍然可以通过向 `image_tag` 传递 `loading: "eager"` 等参数来覆盖每个图像的值。）默认为 `nil`。

#### `config.action_view.image_decoding`

为 `image_tag` 辅助方法渲染的 `<img>` 标签的 `decoding` 属性指定默认值。默认为 `nil`。
#### `config.action_view.annotate_rendered_view_with_filenames`

确定是否在渲染的视图中注释模板文件名。默认为`false`。

#### `config.action_view.preload_links_header`

确定`javascript_include_tag`和`stylesheet_link_tag`是否会生成预加载资源的`Link`头。

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值 |
| --------------------- | -------------------- |
| (原始)            | `nil`                |
| 6.1                   | `true`               |

#### `config.action_view.button_to_generates_button_tag`

确定`button_to`是否会渲染`<button>`元素，无论内容是作为第一个参数还是作为块传递。

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值 |
| --------------------- | -------------------- |
| (原始)            | `false`              |
| 7.0                   | `true`               |

#### `config.action_view.apply_stylesheet_media_default`

确定`stylesheet_link_tag`在未提供`media`属性时是否将`screen`作为默认值渲染。

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值 |
| --------------------- | -------------------- |
| (原始)            | `true`               |
| 7.0                   | `false`              |

#### `config.action_view.prepend_content_exfiltration_prevention`

确定`form_tag`和`button_to`助手是否会生成以浏览器安全（但在技术上无效）的HTML为前缀的HTML标签，以确保其内容不能被任何前面未关闭的标签捕获。默认值为`false`。

#### `config.action_view.sanitizer_vendor`

通过设置`ActionView::Helpers::SanitizeHelper.sanitizer_vendor`配置Action View使用的HTML清理器集。默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值                 | 解析标记的方式 |
|-----------------------|--------------------------------------|------------------------|
| (原始)            | `Rails::HTML4::Sanitizer`            | HTML4                  |
| 7.1                   | `Rails::HTML5::Sanitizer` (见注释) | HTML5                  |

注释：`Rails::HTML5::Sanitizer`不支持JRuby，因此在JRuby平台上，Rails将回退到使用`Rails::HTML4::Sanitizer`。

### 配置Action Mailbox

`config.action_mailbox`提供以下配置选项：

#### `config.action_mailbox.logger`

包含Action Mailbox使用的日志记录器。它接受符合Log4r接口或默认的Ruby Logger类的日志记录器。默认值为`Rails.logger`。

```ruby
config.action_mailbox.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.action_mailbox.incinerate_after`

接受一个`ActiveSupport::Duration`，指示在处理`ActionMailbox::InboundEmail`记录后多长时间应销毁它们。默认为`30.days`。

```ruby
# 在处理后的14天内销毁传入的电子邮件。
config.action_mailbox.incinerate_after = 14.days
```

#### `config.action_mailbox.queues.incineration`

接受一个表示用于销毁作业的Active Job队列的符号。当此选项为`nil`时，销毁作业将发送到默认的Active Job队列（参见`config.active_job.default_queue_name`）。

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值 |
| --------------------- | -------------------- |
| (原始)            | `:action_mailbox_incineration` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.queues.routing`

接受一个表示用于路由作业的Active Job队列的符号。当此选项为`nil`时，路由作业将发送到默认的Active Job队列（参见`config.active_job.default_queue_name`）。

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值 |
| --------------------- | -------------------- |
| (原始)            | `:action_mailbox_routing` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.storage_service`
接受一个符号，指示用于上传电子邮件的Active Storage服务。当此选项为`nil`时，电子邮件将上传到默认的Active Storage服务（参见`config.active_storage.service`）。

### 配置Action Mailer

在`config.action_mailer`上有一些可用的设置：

#### `config.action_mailer.asset_host`

设置资产的主机。当使用CDN来托管资产而不是应用服务器本身时很有用。只有在Action Controller有不同的配置时才应使用此选项，否则请使用`config.asset_host`。

#### `config.action_mailer.logger`

接受符合Log4r或默认的Ruby Logger类接口的记录器，用于记录Action Mailer的信息。设置为`nil`以禁用日志记录。

#### `config.action_mailer.smtp_settings`

允许对`:smtp`传递方法进行详细配置。它接受一个选项哈希，可以包含以下任意选项：

* `:address` - 允许您使用远程邮件服务器。只需将其从默认的“localhost”设置更改即可。
* `:port` - 如果您的邮件服务器不在25号端口上运行，您可以更改它。
* `:domain` - 如果您需要指定一个HELO域，可以在此处进行设置。
* `:user_name` - 如果您的邮件服务器需要身份验证，请在此设置中设置用户名。
* `:password` - 如果您的邮件服务器需要身份验证，请在此设置中设置密码。
* `:authentication` - 如果您的邮件服务器需要身份验证，您需要在此处指定身份验证类型。这是一个符号，可以是`:plain`、`:login`、`:cram_md5`之一。
* `:enable_starttls` - 在连接到SMTP服务器时使用STARTTLS，并在不支持时失败。默认为`false`。
* `:enable_starttls_auto` - 检测SMTP服务器中是否启用了STARTTLS，并开始使用它。默认为`true`。
* `:openssl_verify_mode` - 在使用TLS时，您可以设置OpenSSL如何检查证书。如果您需要验证自签名和/或通配符证书，这将非常有用。可以是OpenSSL验证常量之一，`:none`或`:peer`，或者直接的常量`OpenSSL::SSL::VERIFY_NONE`或`OpenSSL::SSL::VERIFY_PEER`。
* `:ssl/:tls` - 启用SMTP连接使用SMTP/TLS（SMTPS：SMTP通过直接TLS连接）。
* `:open_timeout` - 尝试打开连接时等待的秒数。
* `:read_timeout` - 等待超时的秒数，直到超时读取（2）调用。

此外，还可以传递任何[Mail::SMTP所支持的配置选项](https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/smtp.rb)。

#### `config.action_mailer.smtp_timeout`

允许配置`:smtp`传递方法的`:open_timeout`和`:read_timeout`值。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `nil`  |
| 7.0      | `5`    |

#### `config.action_mailer.sendmail_settings`

允许对`sendmail`传递方法进行详细配置。它接受一个选项哈希，可以包含以下任意选项：

* `:location` - sendmail可执行文件的位置。默认为`/usr/sbin/sendmail`。
* `:arguments` - 命令行参数。默认为`%w[ -i ]`。

#### `config.action_mailer.raise_delivery_errors`

指定是否在无法完成电子邮件传递时引发错误。默认为`true`。
#### `config.action_mailer.delivery_method`

定义邮件发送方式，默认为 `:smtp`。详见 [Action Mailer 指南中的配置部分](action_mailer_basics.html#action-mailer-configuration)。

#### `config.action_mailer.perform_deliveries`

指定是否实际发送邮件，默认为 `true`。在测试时将其设置为 `false` 可以很方便地进行测试。

#### `config.action_mailer.default_options`

配置 Action Mailer 的默认选项。可以用于为每个邮件设置 `from` 或 `reply_to` 等选项。默认值为：

```ruby
mime_version:  "1.0",
charset:       "UTF-8",
content_type: "text/plain",
parts_order:  ["text/plain", "text/enriched", "text/html"]
```

可以分配一个哈希来设置其他选项：

```ruby
config.action_mailer.default_options = {
  from: "noreply@example.com"
}
```

#### `config.action_mailer.observers`

注册在邮件发送时将被通知的观察者。

```ruby
config.action_mailer.observers = ["MailObserver"]
```

#### `config.action_mailer.interceptors`

注册在发送邮件之前将被调用的拦截器。

```ruby
config.action_mailer.interceptors = ["MailInterceptor"]
```

#### `config.action_mailer.preview_interceptors`

注册在预览邮件之前将被调用的拦截器。

```ruby
config.action_mailer.preview_interceptors = ["MyPreviewMailInterceptor"]
```

#### `config.action_mailer.preview_paths`

指定邮件预览的位置。将路径附加到此配置选项将导致在搜索邮件预览时使用这些路径。

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

#### `config.action_mailer.show_previews`

启用或禁用邮件预览。在开发环境中，默认值为 `true`。

```ruby
config.action_mailer.show_previews = false
```

#### `config.action_mailer.perform_caching`

指定邮件模板是否应执行片段缓存。如果未指定，默认值为 `true`。

#### `config.action_mailer.deliver_later_queue_name`

指定用于默认发送作业的 Active Job 队列（参见 `config.action_mailer.delivery_job`）。当此选项设置为 `nil` 时，发送作业将发送到默认的 Active Job 队列（参见 `config.active_job.default_queue_name`）。

邮件类可以覆盖此选项以使用不同的队列。请注意，这仅适用于使用默认发送作业的情况。如果您的邮件类使用自定义作业，则将使用其队列。

请确保您的 Active Job 适配器也配置为处理指定的队列，否则发送作业可能会被静默忽略。

默认值取决于 `config.load_defaults` 目标版本：

| 起始版本 | 默认值 |
| --------------------- | -------------------- |
| (原始)            | `:mailers`           |
| 6.1                   | `nil`                |

#### `config.action_mailer.delivery_job`

指定邮件的发送作业。

默认值取决于 `config.load_defaults` 目标版本：

| 起始版本 | 默认值 |
| --------------------- | -------------------- |
| (原始)            | `ActionMailer::MailDeliveryJob` |
| 6.0                   | `"ActionMailer::MailDeliveryJob"` |

### 配置 Active Support

Active Support 提供了一些配置选项：

#### `config.active_support.bare`

启用或禁用在启动 Rails 时加载 `active_support/all`。默认为 `nil`，表示加载 `active_support/all`。

#### `config.active_support.test_order`

设置测试用例执行的顺序。可能的值为 `:random` 和 `:sorted`。默认为 `:random`。

#### `config.active_support.escape_html_entities_in_json`

启用或禁用在 JSON 序列化中转义 HTML 实体。默认为 `true`。

#### `config.active_support.use_standard_json_time_format`

启用或禁用将日期序列化为 ISO 8601 格式。默认为 `true`。

#### `config.active_support.time_precision`

设置 JSON 编码的时间值的精度。默认为 `3`。

#### `config.active_support.hash_digest_class`

允许配置用于生成非敏感摘要（例如 ETag 标头）的摘要类。

默认值取决于 `config.load_defaults` 目标版本：
| 从版本开始 | 默认值为 |
| --------------------- | -------------------- |
| (原始)            | `OpenSSL::Digest::MD5` |
| 5.2                   | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.key_generator_hash_digest_class`

允许配置用于从配置的密钥基础派生密钥的摘要类，例如用于加密的cookie。

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值为 |
| --------------------- | -------------------- |
| (原始)            | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.use_authenticated_message_encryption`

指定是否使用AES-256-GCM认证加密作为默认的加密算法来加密消息，而不是AES-256-CBC。

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值为 |
| --------------------- | -------------------- |
| (原始)            | `false`              |
| 5.2                   | `true`               |

#### `config.active_support.message_serializer`

指定[`ActiveSupport::MessageEncryptor`][]和[`ActiveSupport::MessageVerifier`][]实例使用的默认序列化器。为了更容易迁移不同的序列化器，提供的序列化器包括回退机制以支持多个反序列化格式：

| 序列化器 | 序列化和反序列化 | 回退反序列化 |
| ---------- | ------------------------- | -------------------- |
| `:marshal` | `Marshal` | `ActiveSupport::JSON`，`ActiveSupport::MessagePack` |
| `:json` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack` |
| `:json_allow_marshal` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack`，`Marshal` |
| `:message_pack` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON` |
| `:message_pack_allow_marshal` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON`，`Marshal` |

警告：在消息签名密钥泄露的情况下，`Marshal`可能成为反序列化攻击的潜在向量。_如果可能，请选择不支持`Marshal`的序列化器。_

信息：`:message_pack`和`:message_pack_allow_marshal`序列化器支持一些Ruby类型的往返，这些类型不受JSON支持，例如`Symbol`。它们还可以提供更好的性能和较小的有效载荷大小。但是，它们需要[`msgpack` gem](https://rubygems.org/gems/msgpack)。

上述每个序列化器在回退到备用反序列化格式时会发出[`message_serializer_fallback.active_support`][]事件通知，以便您可以跟踪此类回退发生的频率。

或者，您可以指定任何响应`dump`和`load`方法的序列化器对象。例如：

```ruby
config.active_job.message_serializer = YAML
```

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值为 |
| --------------------- | -------------------- |
| (原始)            | `:marshal`           |
| 7.1                   | `:json_allow_marshal` |


#### `config.active_support.use_message_serializer_for_metadata`

当为`true`时，启用性能优化，将消息数据和元数据一起序列化。这会更改消息格式，因此以这种方式序列化的消息无法被旧版本（<7.1）的Rails读取。但是，使用旧格式的消息仍然可以被读取，无论是否启用了此优化。

默认值取决于`config.load_defaults`目标版本：

| 从版本开始 | 默认值为 |
| --------------------- | -------------------- |
| (原始)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_support.cache_format_version`

指定用于缓存的序列化格式。可能的值为`6.1`，`7.0`和`7.1`。

`6.1`，`7.0`和`7.1`格式都使用`Marshal`作为默认编码器，但`7.0`使用更高效的表示形式来表示缓存条目，而`7.1`则包括了对裸字符串值（如视图片段）的额外优化。
所有格式都是向前和向后兼容的，这意味着在使用另一种格式时可以读取以一种格式写入的缓存条目。这种行为使得在不使整个缓存失效的情况下轻松迁移格式成为可能。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `6.1`  |
| 7.0      | `7.0`  |
| 7.1      | `7.1`  |

#### `config.active_support.deprecation`

配置废弃警告的行为。选项包括`:raise`、`:stderr`、`:log`、`:notify`和`:silence`。

在默认生成的`config/environments`文件中，开发环境设置为`:log`，测试环境设置为`:stderr`，生产环境中省略此配置，而使用[`config.active_support.report_deprecations`](#config-active-support-report-deprecations)。

#### `config.active_support.disallowed_deprecation`

配置不允许的废弃警告的行为。选项包括`:raise`、`:stderr`、`:log`、`:notify`和`:silence`。

在默认生成的`config/environments`文件中，开发环境和测试环境都设置为`:raise`，生产环境中省略此配置，而使用[`config.active_support.report_deprecations`](#config-active-support-report-deprecations)。

#### `config.active_support.disallowed_deprecation_warnings`

配置应用程序认为是不允许的废弃警告。这允许将特定的废弃警告视为严重错误。

#### `config.active_support.report_deprecations`

当为`false`时，禁用所有废弃警告，包括不允许的废弃警告，来自[应用程序的废弃器](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators)。这包括来自Rails和其他可能将其废弃器添加到废弃器集合中的宝石的所有废弃警告，但可能无法阻止从ActiveSupport::Deprecation发出的所有废弃警告。

在默认生成的`config/environments`文件中，生产环境中设置为`false`。

#### `config.active_support.isolation_level`

配置大多数Rails内部状态的局部性。如果使用基于fiber的服务器或作业处理器（例如`falcon`），应将其设置为`:fiber`。否则最好使用`:thread`局部性。默认为`:thread`。

#### `config.active_support.executor_around_test_case`

配置测试套件在测试用例周围调用`Rails.application.executor.wrap`。这使得测试用例的行为更接近实际请求或作业。在测试中通常禁用的几个功能，如Active Record查询缓存和异步查询，将被启用。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `false`  |
| 7.0      | `true`   |

#### `ActiveSupport::Logger.silencer`

设置为`false`以禁用在块中静音日志的能力。默认值为`true`。

#### `ActiveSupport::Cache::Store.logger`

指定在缓存存储操作中使用的日志记录器。

#### `ActiveSupport.to_time_preserves_timezone`

指定`to_time`方法是否保留其接收者的UTC偏移量。如果为`false`，`to_time`方法将转换为本地系统的UTC偏移量。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `false`  |
| 5.0      | `true`   |

#### `ActiveSupport.utc_to_local_returns_utc_offset_times`

配置`ActiveSupport::TimeZone.utc_to_local`返回带有UTC偏移量而不是包含该偏移量的UTC时间。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `false`  |
| 6.1      | `true`   |
#### `config.active_support.raise_on_invalid_cache_expiration_time`

指定是否在给定无效的`expires_at`或`expires_in`时间时引发`ArgumentError`。当`Rails.cache`的`fetch`或`write`方法给定无效的`expires_at`或`expires_in`时间时，可以选择`true`或`false`。如果选择`false`，则异常将被视为`handled`并记录。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.1      | `true` |

### 配置Active Job

`config.active_job`提供以下配置选项：

#### `config.active_job.queue_adapter`

设置队列后端的适配器。默认适配器是`:async`。有关内置适配器的最新列表，请参阅[ActiveJob::QueueAdapters API文档](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html)。

```ruby
# 确保在Gemfile中有适配器的gem
# 并按照适配器的特定安装和部署说明进行操作
config.active_job.queue_adapter = :sidekiq
```

#### `config.active_job.default_queue_name`

可用于更改默认队列名称。默认为`"default"`。

```ruby
config.active_job.default_queue_name = :medium_priority
```

#### `config.active_job.queue_name_prefix`

允许为所有作业设置一个可选的非空队列名称前缀。默认为空白且未使用。

以下配置将在生产环境中将给定作业排队到`production_high_priority`队列：

```ruby
config.active_job.queue_name_prefix = Rails.env
```

```ruby
class GuestsCleanupJob < ActiveJob::Base
  queue_as :high_priority
  #....
end
```

#### `config.active_job.queue_name_delimiter`

默认值为`'_'`。如果设置了`queue_name_prefix`，则`queue_name_delimiter`将连接前缀和非前缀队列名称。

以下配置将在`video_server.low_priority`队列上排队提供的作业：

```ruby
# 必须设置前缀才能使用分隔符
config.active_job.queue_name_prefix = 'video_server'
config.active_job.queue_name_delimiter = '.'
```

```ruby
class EncoderJob < ActiveJob::Base
  queue_as :low_priority
  #....
end
```

#### `config.active_job.logger`

接受符合Log4r接口或默认的Ruby Logger类的日志记录器，用于记录Active Job的信息。可以通过在Active Job类或Active Job实例上调用`logger`来检索此日志记录器。设置为`nil`以禁用日志记录。

#### `config.active_job.custom_serializers`

允许设置自定义参数序列化器。默认为`[]`。

#### `config.active_job.log_arguments`

控制是否记录作业的参数。默认为`true`。

#### `config.active_job.verbose_enqueue_logs`

指定是否在开发环境下记录将后台作业加入队列的方法的源位置。默认情况下，在开发环境中该标志为`true`，在其他所有环境中为`false`。

#### `config.active_job.retry_jitter`

控制在重试失败的作业时应用的延迟时间的“抖动”（随机变化）量。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `0.0`  |
| 6.1      | `0.15` |

#### `config.active_job.log_query_tags_around_perform`

确定是否通过`around_perform`自动更新查询标签的作业上下文。默认值为`true`。

#### `config.active_job.use_big_decimal_serializer`

启用新的`BigDecimal`参数序列化器，可保证往返。如果没有此序列化器，某些队列适配器可能将`BigDecimal`参数序列化为简单（不可往返）的字符串。

警告：在部署具有多个副本的应用程序时，旧的（Rails 7.1之前的）副本将无法从此序列化器反序列化`BigDecimal`参数。因此，只有在所有副本成功升级到Rails 7.1之后才应启用此设置。
默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.1      | `true`  |

### 配置 Action Cable

#### `config.action_cable.url`

接受一个字符串，用于指定托管 Action Cable 服务器的 URL。如果您运行的 Action Cable 服务器与主应用程序分开，则可以使用此选项。

#### `config.action_cable.mount_path`

接受一个字符串，用于指定 Action Cable 的挂载路径，作为主服务器进程的一部分。默认为 `/cable`。您可以将其设置为 nil，以便不将 Action Cable 挂载为常规 Rails 服务器的一部分。

您可以在[Action Cable 概述](action_cable_overview.html#configuration)中找到更详细的配置选项。

#### `config.action_cable.precompile_assets`

确定是否将 Action Cable 资源添加到资产管道的预编译中。如果未使用 Sprockets，则此选项无效。默认值为 `true`。

### 配置 Active Storage

`config.active_storage` 提供以下配置选项：

#### `config.active_storage.variant_processor`

接受一个符号 `:mini_magick` 或 `:vips`，指定是否使用 MiniMagick 或 ruby-vips 执行变体转换和 blob 分析。

默认值取决于 `config.load_defaults` 目标版本：

| 起始版本 | 默认值       |
| -------- | ------------ |
| (原始)   | `:mini_magick` |
| 7.0      | `:vips`        |

#### `config.active_storage.analyzers`

接受一个类数组，指示 Active Storage blobs 可用的分析器。默认情况下，定义如下：

```ruby
config.active_storage.analyzers = [ActiveStorage::Analyzer::ImageAnalyzer::Vips, ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick, ActiveStorage::Analyzer::VideoAnalyzer, ActiveStorage::Analyzer::AudioAnalyzer]
```

图像分析器可以提取图像 blob 的宽度和高度；视频分析器可以提取视频 blob 的宽度、高度、持续时间、角度、宽高比以及视频/音频通道的存在/缺失；音频分析器可以提取音频 blob 的持续时间和比特率。

#### `config.active_storage.previewers`

接受一个类数组，指示 Active Storage blobs 中可用的图像预览器。默认情况下，定义如下：

```ruby
config.active_storage.previewers = [ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer]
```

`PopplerPDFPreviewer` 和 `MuPDFPreviewer` 可以从 PDF blob 的第一页生成缩略图；`VideoPreviewer` 可以从视频 blob 的相关帧生成缩略图。

#### `config.active_storage.paths`

接受一个选项哈希，指示预览器/分析器命令的位置。默认值为 `{}`，表示命令将在默认路径中查找。可以包括以下任意选项：

* `:ffprobe` - ffprobe 可执行文件的位置。
* `:mutool` - mutool 可执行文件的位置。
* `:ffmpeg` - ffmpeg 可执行文件的位置。

```ruby
config.active_storage.paths[:ffprobe] = '/usr/local/bin/ffprobe'
```

#### `config.active_storage.variable_content_types`

接受一个字符串数组，指示 Active Storage 可以通过变体处理器转换的内容类型。默认情况下，定义如下：

```ruby
config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/bmp image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)
```

#### `config.active_storage.web_image_content_types`

接受一个字符串数组，表示在其中可以处理变体而无需转换为回退的 PNG 格式的 Web 图像内容类型。如果您想在应用程序中使用 `WebP` 或 `AVIF` 变体，可以将 `image/webp` 或 `image/avif` 添加到此数组中。

默认情况下，定义如下：
```ruby
config.active_storage.web_image_content_types = %w(image/png image/jpeg image/gif)
```

#### `config.active_storage.content_types_to_serve_as_binary`

接受一个字符串数组，指示Active Storage始终将其作为附件而不是内联方式提供的内容类型。默认情况下，定义如下：

```ruby
config.active_storage.content_types_to_serve_as_binary = %w(text/html image/svg+xml application/postscript application/x-shockwave-flash text/xml application/xml application/xhtml+xml application/mathml+xml text/cache-manifest)
```

#### `config.active_storage.content_types_allowed_inline`

接受一个字符串数组，指示Active Storage允许作为内联方式提供的内容类型。默认情况下，定义如下：

```ruby
config.active_storage.content_types_allowed_inline` = %w(image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon application/pdf)
```

#### `config.active_storage.queues.analysis`

接受一个符号，指示用于分析作业的Active Job队列。当此选项为`nil`时，分析作业将发送到默认的Active Job队列（参见`config.active_job.default_queue_name`）。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| 6.0     | `:active_storage_analysis` |
| 6.1     | `nil`  |

#### `config.active_storage.queues.purge`

接受一个符号，指示用于清除作业的Active Job队列。当此选项为`nil`时，清除作业将发送到默认的Active Job队列（参见`config.active_job.default_queue_name`）。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| 6.0     | `:active_storage_purge` |
| 6.1     | `nil`  |

#### `config.active_storage.queues.mirror`

接受一个符号，指示用于直接上传镜像作业的Active Job队列。当此选项为`nil`时，镜像作业将发送到默认的Active Job队列（参见`config.active_job.default_queue_name`）。默认值为`nil`。

#### `config.active_storage.logger`

可用于设置Active Storage使用的日志记录器。接受符合Log4r或默认Ruby Logger类接口的日志记录器。

```ruby
config.active_storage.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.active_storage.service_urls_expire_in`

确定由以下生成的URL的默认到期时间：

* `ActiveStorage::Blob#url`
* `ActiveStorage::Blob#service_url_for_direct_upload`
* `ActiveStorage::Variant#url`

默认值为5分钟。

#### `config.active_storage.urls_expire_in`

确定由Active Storage在Rails应用程序中生成的URL的默认到期时间。默认值为`nil`。

#### `config.active_storage.routes_prefix`

可用于设置Active Storage提供的路由的路由前缀。接受一个字符串，将在生成的路由之前添加。

```ruby
config.active_storage.routes_prefix = '/files'
```

默认值为`/rails/active_storage`。

#### `config.active_storage.track_variants`

确定是否在数据库中记录变体。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)   | `false` |
| 6.1     | `true`  |

#### `config.active_storage.draw_routes`

可用于切换Active Storage路由生成。默认值为`true`。

#### `config.active_storage.resolve_model_to_route`

可用于全局更改Active Storage文件的传递方式。

允许的值为：

* `:rails_storage_redirect`：重定向到签名的、短期的服务URL。
* `:rails_storage_proxy`：通过下载代理文件。

默认值为`:rails_storage_redirect`。

#### `config.active_storage.video_preview_arguments`

可用于更改ffmpeg生成视频预览图像的方式。

默认值取决于`config.load_defaults`目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)   | `"-y -vframes 1 -f image2"` |
| 7.0     | `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015)"`<sup><mark><strong><em>1</em></strong></mark></sup> <br> `+ ",loop=loop=-1:size=2,trim=start_frame=1'"`<sup><mark><strong><em>2</em></strong></mark></sup><br> `+ " -frames:v 1 -f image2"` <br><br> <ol><li>选择第一个视频帧，加上关键帧，加上满足场景变化阈值的帧。</li> <li>当没有其他帧满足条件时，使用第一个视频帧作为回退，通过循环选择的第一个（或两个）帧，然后丢弃第一个循环的帧。</li></ol> |
#### `config.active_storage.multiple_file_field_include_hidden`

在 Rails 7.1 及更高版本中，Active Storage 的 `has_many_attached` 关联将默认为 _替换_ 当前集合而不是 _追加_ 到它。因此，为了支持提交一个 _空_ 集合，当 `multiple_file_field_include_hidden` 为 `true` 时，[`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) 辅助方法将渲染一个辅助隐藏字段，类似于 [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) 辅助方法渲染的辅助字段。

默认值取决于 `config.load_defaults` 目标版本：

| 起始版本 | 默认值 |
| ------- | ------ |
| (原始)  | `false` |
| 7.0     | `true`  |

#### `config.active_storage.precompile_assets`

确定是否将 Active Storage 资源添加到资产管道预编译中。如果不使用 Sprockets，则不起作用。默认值为 `true`。

### 配置 Action Text

#### `config.action_text.attachment_tag_name`

接受一个字符串作为用于包装附件的 HTML 标签。默认为 `"action-text-attachment"`。

#### `config.action_text.sanitizer_vendor`

通过将 `ActionText::ContentHelper.sanitizer` 设置为从供应商的 `.safe_list_sanitizer` 方法返回的类的实例来配置 Action Text 使用的 HTML 清理器。默认值取决于 `config.load_defaults` 目标版本：

| 起始版本 | 默认值 | 解析标记为 |
|---------|--------|-----------|
| (原始)  | `Rails::HTML4::Sanitizer` | HTML4 |
| 7.1     | `Rails::HTML5::Sanitizer` (见注释) | HTML5 |

注释：`Rails::HTML5::Sanitizer` 在 JRuby 上不受支持，因此在 JRuby 平台上，Rails 将回退到使用 `Rails::HTML4::Sanitizer`。

### 配置数据库

几乎每个 Rails 应用都会与数据库交互。您可以通过设置环境变量 `ENV['DATABASE_URL']` 或使用名为 `config/database.yml` 的配置文件来连接到数据库。

使用 `config/database.yml` 文件，您可以指定访问数据库所需的所有信息：

```yaml
development:
  adapter: postgresql
  database: blog_development
  pool: 5
```

这将使用 `postgresql` 适配器连接到名为 `blog_development` 的数据库。相同的信息可以存储在 URL 中，并通过环境变量提供，如下所示：

```ruby
ENV['DATABASE_URL'] # => "postgresql://localhost/blog_development?pool=5"
```

`config/database.yml` 文件默认包含三个不同环境的部分，Rails 可以在其中运行：

* `development` 环境用于在您手动与应用程序交互时在开发/本地计算机上使用。
* `test` 环境用于运行自动化测试。
* `production` 环境用于在部署应用程序供全世界使用时使用。

如果希望，可以在 `config/database.yml` 中手动指定 URL：

```yaml
development:
  url: postgresql://localhost/blog_development?pool=5
```

`config/database.yml` 文件可以包含 ERB 标签 `<%= %>`。标签中的任何内容都将作为 Ruby 代码进行评估。您可以使用此功能从环境变量中提取数据，或执行计算以生成所需的连接信息。

提示：您不必手动更新数据库配置。如果查看应用程序生成器的选项，您将看到其中一个选项名为 `--database`。此选项允许您从最常用的关系数据库列表中选择适配器。甚至可以重复运行生成器：`cd .. && rails new blog --database=mysql`。当确认覆盖 `config/database.yml` 文件时，您的应用程序将配置为使用 MySQL 而不是 SQLite。下面是常见数据库连接的详细示例。
### 连接偏好

由于有两种配置连接的方式（使用 `config/database.yml` 或使用环境变量），了解它们如何交互是很重要的。

如果 `config/database.yml` 文件为空，但 `ENV['DATABASE_URL']` 存在，则 Rails 将通过环境变量连接到数据库：

```bash
$ cat config/database.yml

$ echo $DATABASE_URL
postgresql://localhost/my_database
```

如果有 `config/database.yml`，但没有 `ENV['DATABASE_URL']`，则将使用该文件连接到数据库：

```bash
$ cat config/database.yml
development:
  adapter: postgresql
  database: my_database
  host: localhost

$ echo $DATABASE_URL
```

如果同时设置了 `config/database.yml` 和 `ENV['DATABASE_URL']`，则 Rails 将合并这些配置。为了更好地理解这一点，我们需要看一些示例。

当提供了重复的连接信息时，环境变量将优先：

```bash
$ cat config/database.yml
development:
  adapter: sqlite3
  database: NOT_my_database
  host: localhost

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ bin/rails runner 'puts ActiveRecord::Base.configurations'
#<ActiveRecord::DatabaseConfigurations:0x00007fd50e209a28>

$ bin/rails runner 'puts ActiveRecord::Base.configurations.inspect'
#<ActiveRecord::DatabaseConfigurations:0x00007fc8eab02880 @configurations=[
  #<ActiveRecord::DatabaseConfigurations::UrlConfig:0x00007fc8eab020b0
    @env_name="development", @spec_name="primary",
    @config={"adapter"=>"postgresql", "database"=>"my_database", "host"=>"localhost"}
    @url="postgresql://localhost/my_database">
  ]
```

这里的适配器（adapter）、主机（host）和数据库（database）与 `ENV['DATABASE_URL']` 中的信息匹配。

如果提供了非重复的信息，则会得到所有唯一的值，但在冲突的情况下，环境变量仍然优先。

```bash
$ cat config/database.yml
development:
  adapter: sqlite3
  pool: 5

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ bin/rails runner 'puts ActiveRecord::Base.configurations'
#<ActiveRecord::DatabaseConfigurations:0x00007fd50e209a28>

$ bin/rails runner 'puts ActiveRecord::Base.configurations.inspect'
#<ActiveRecord::DatabaseConfigurations:0x00007fc8eab02880 @configurations=[
  #<ActiveRecord::DatabaseConfigurations::UrlConfig:0x00007fc8eab020b0
    @env_name="development", @spec_name="primary",
    @config={"adapter"=>"postgresql", "database"=>"my_database", "host"=>"localhost", "pool"=>5}
    @url="postgresql://localhost/my_database">
  ]
```

由于池（pool）不在提供的 `ENV['DATABASE_URL']` 连接信息中，所以它的信息被合并进来。由于适配器是重复的，`ENV['DATABASE_URL']` 的连接信息胜出。

唯一明确不使用 `ENV['DATABASE_URL']` 中的连接信息的方法是使用 `"url"` 子键指定一个显式的 URL 连接：

```bash
$ cat config/database.yml
development:
  url: sqlite3:NOT_my_database

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ bin/rails runner 'puts ActiveRecord::Base.configurations'
#<ActiveRecord::DatabaseConfigurations:0x00007fd50e209a28>

$ bin/rails runner 'puts ActiveRecord::Base.configurations.inspect'
#<ActiveRecord::DatabaseConfigurations:0x00007fc8eab02880 @configurations=[
  #<ActiveRecord::DatabaseConfigurations::UrlConfig:0x00007fc8eab020b0
    @env_name="development", @spec_name="primary",
    @config={"adapter"=>"sqlite3", "database"=>"NOT_my_database"}
    @url="sqlite3:NOT_my_database">
  ]
```

这里忽略了 `ENV['DATABASE_URL']` 中的连接信息，请注意适配器和数据库名称的不同。

由于可以在 `config/database.yml` 中嵌入 ERB，最佳实践是明确显示使用 `ENV['DATABASE_URL']` 来连接数据库。这在生产环境中特别有用，因为您不应该将诸如数据库密码之类的机密信息提交到源代码控制（如 Git）中。

```bash
$ cat config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

现在行为是清晰的，我们只使用 `ENV['DATABASE_URL']` 中的连接信息。

#### 配置 SQLite3 数据库

Rails 内置支持 [SQLite3](http://www.sqlite.org)，它是一个轻量级的无服务器数据库应用程序。虽然繁忙的生产环境可能会过载 SQLite，但它在开发和测试中表现良好。Rails 在创建新项目时默认使用 SQLite 数据库，但您始终可以稍后更改它。

这是默认配置文件 (`config/database.yml`) 中用于开发环境的连接信息部分：

```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

注意：Rails 默认使用 SQLite3 数据库进行数据存储，因为它是一个零配置的数据库，可以直接使用。Rails 还支持 MySQL（包括 MariaDB）和 PostgreSQL，并为许多数据库系统提供插件。如果您在生产环境中使用数据库，Rails 很可能有适配器可用。
#### 配置MySQL或MariaDB数据库

如果您选择使用MySQL或MariaDB而不是预装的SQLite3数据库，则您的`config/database.yml`将有所不同。这是开发部分的配置：

```yaml
development:
  adapter: mysql2
  encoding: utf8mb4
  database: blog_development
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock
```

如果您的开发数据库具有空密码的root用户，则此配置应适用于您。否则，请根据需要更改`development`部分中的用户名和密码。

注意：如果您的MySQL版本为5.5或5.6，并且希望默认使用`utf8mb4`字符集，请通过启用`innodb_large_prefix`系统变量来配置MySQL服务器以支持更长的键前缀。

MySQL默认启用了Advisory Locks，并用于使数据库迁移并发安全。您可以通过将`advisory_locks`设置为`false`来禁用Advisory Locks：

```yaml
production:
  adapter: mysql2
  advisory_locks: false
```

#### 配置PostgreSQL数据库

如果您选择使用PostgreSQL，则您的`config/database.yml`将被定制为使用PostgreSQL数据库：

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: blog_development
  pool: 5
```

默认情况下，Active Record使用诸如预编译语句和Advisory Locks之类的数据库特性。如果您使用外部连接池程序（如PgBouncer），您可能需要禁用这些功能：

```yaml
production:
  adapter: postgresql
  prepared_statements: false
  advisory_locks: false
```

如果启用，Active Record默认每个数据库连接创建多达`1000`个预编译语句。要修改此行为，可以将`statement_limit`设置为其他值：

```yaml
production:
  adapter: postgresql
  statement_limit: 200
```

使用的预编译语句越多，数据库所需的内存就越多。如果您的PostgreSQL数据库达到内存限制，请尝试降低`statement_limit`或禁用预编译语句。

#### 为JRuby平台配置SQLite3数据库

如果您选择使用SQLite3并且正在使用JRuby，则您的`config/database.yml`将有所不同。这是开发部分的配置：

```yaml
development:
  adapter: jdbcsqlite3
  database: storage/development.sqlite3
```

#### 为JRuby平台配置MySQL或MariaDB数据库

如果您选择使用MySQL或MariaDB并且正在使用JRuby，则您的`config/database.yml`将有所不同。这是开发部分的配置：

```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```

#### 为JRuby平台配置PostgreSQL数据库

如果您选择使用PostgreSQL并且正在使用JRuby，则您的`config/database.yml`将有所不同。这是开发部分的配置：

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

根据需要更改`development`部分中的用户名和密码。

#### 配置元数据存储

默认情况下，Rails将在名为`ar_internal_metadata`的内部表中存储有关Rails环境和模式的信息。

要在每个连接中关闭此功能，请在数据库配置中设置`use_metadata_table`。当使用共享数据库和/或无法创建表的数据库用户时，这很有用。

```yaml
development:
  adapter: postgresql
  use_metadata_table: false
```

#### 配置重试行为

默认情况下，如果出现问题，Rails将自动重新连接到数据库服务器并重试某些查询。只有安全重试（幂等）的查询将被重试。可以通过数据库配置中的`connection_retries`指定重试次数，或通过将该值设置为0来禁用重试。默认的重试次数为1。
```yaml
development:
  adapter: mysql2
  connection_retries: 3
```

数据库配置还允许配置`retry_deadline`。如果配置了`retry_deadline`，则在查询首次尝试时，如果经过了指定的时间，即使查询是可重试的且还有`connection_retries`次重试机会，也不会再次尝试查询。例如，`retry_deadline`为5秒意味着如果查询首次尝试后已经过了5秒，即使查询是幂等的且还有`connection_retries`次重试机会，我们也不会再次尝试查询。

该值默认为nil，意味着所有可重试的查询都会在经过的时间无论多长都会重试。该配置的值应该以秒为单位进行指定。

```yaml
development:
  adapter: mysql2
  retry_deadline: 5 # 在5秒后停止重试查询
```

#### 配置查询缓存

默认情况下，Rails会自动缓存查询返回的结果集。如果在同一请求或作业中再次遇到相同的查询，Rails将使用缓存的结果集而不是再次对数据库运行查询。

查询缓存存储在内存中，为了避免使用过多的内存，当达到阈值时，它会自动删除最近最少使用的查询。默认情况下，阈值为`100`，但可以在`database.yml`中进行配置。

```yaml
development:
  adapter: mysql2
  query_cache: 200
```

要完全禁用查询缓存，可以将其设置为`false`

```yaml
development:
  adapter: mysql2
  query_cache: false
```

### 创建Rails环境

默认情况下，Rails提供了三个环境："development"、"test"和"production"。虽然这些对大多数用例已经足够了，但在某些情况下，您可能需要更多的环境。

假设您有一个服务器，它与生产环境镜像，但仅用于测试。这样的服务器通常被称为"staging server"。要为此服务器定义一个名为"staging"的环境，只需创建一个名为`config/environments/staging.rb`的文件。由于这是一个类似生产环境的环境，您可以将`config/environments/production.rb`的内容复制为起点，并进行必要的更改。还可以像这样要求和扩展其他环境配置：

```ruby
# config/environments/staging.rb
require_relative "production"

Rails.application.configure do
  # Staging overrides
end
```

该环境与默认环境没有任何区别，可以使用`bin/rails server -e staging`启动服务器，使用`bin/rails console -e staging`启动控制台，`Rails.env.staging?`也可以工作，等等。

### 部署到子目录（相对URL根）

默认情况下，Rails期望您的应用程序在根目录（例如`/`）运行。本节解释了如何在目录中运行应用程序。

假设我们想将应用程序部署到"/app1"。Rails需要知道这个目录以生成适当的路由：

```ruby
config.relative_url_root = "/app1"
```

或者您可以设置`RAILS_RELATIVE_URL_ROOT`环境变量。

现在，Rails在生成链接时将在前面添加"/app1"。

#### 使用Passenger

Passenger使在子目录中运行应用程序变得容易。您可以在[Passenger手册](https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/#deploying-an-app-to-a-sub-uri-or-subdirectory)中找到相关的配置信息。

#### 使用反向代理

使用反向代理部署应用程序与传统部署相比具有明显的优势。它们允许您通过分层应用程序所需的组件来更好地控制服务器。
许多现代Web服务器可以用作代理服务器，用于平衡缓存服务器或应用服务器等第三方元素。

其中一个可以使用的应用服务器是[Unicorn](https://bogomips.org/unicorn/)，可以在反向代理后面运行。

在这种情况下，您需要配置代理服务器（NGINX、Apache等）以接受来自应用服务器（Unicorn）的连接。默认情况下，Unicorn将在端口8080上监听TCP连接，但您可以更改端口或配置为使用套接字。

您可以在[Unicorn自述文件](https://bogomips.org/unicorn/README.html)中找到更多信息，并了解其背后的[哲学](https://bogomips.org/unicorn/PHILOSOPHY.html)。

配置应用服务器后，您必须通过适当配置您的Web服务器来代理请求。例如，您的NGINX配置可能包括：

```nginx
upstream application_server {
  server 0.0.0.0:8080;
}

server {
  listen 80;
  server_name localhost;

  root /root/path/to/your_app/public;

  try_files $uri/index.html $uri.html @app;

  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://application_server;
  }

  # some other configuration
}
```

请务必阅读[NGINX文档](https://nginx.org/en/docs/)以获取最新信息。


Rails环境设置
--------------------------

Rails的某些部分也可以通过提供环境变量来进行外部配置。各个部分的Rails都会识别以下环境变量：

* `ENV["RAILS_ENV"]`定义了Rails将在其下运行的Rails环境（生产、开发、测试等）。

* `ENV["RAILS_RELATIVE_URL_ROOT"]`用于路由代码在[将应用程序部署到子目录](configuring.html#deploy-to-a-subdirectory-relative-url-root)时识别URL。

* `ENV["RAILS_CACHE_ID"]`和`ENV["RAILS_APP_VERSION"]`用于在Rails的缓存代码中生成扩展缓存键。这允许您从同一个应用程序中拥有多个独立的缓存。


使用初始化文件
-----------------------

在加载应用程序中的框架和任何gem之后，Rails会加载初始化器。初始化器是存储在应用程序的`config/initializers`目录下的任何Ruby文件。您可以使用初始化器来保存在所有框架和gems加载之后应进行的配置设置，例如用于配置这些部分的选项。

`config/initializers`目录中的文件（以及`config/initializers`的任何子目录）会按顺序进行排序和加载，作为`load_config_initializers`初始化器的一部分。

如果一个初始化器的代码依赖于另一个初始化器中的代码，您可以将它们合并为一个单独的初始化器。这样可以使依赖关系更加明确，并有助于在应用程序中展示新的概念。Rails还支持初始化器文件名的编号，但这可能导致文件名的频繁更改。不建议使用`require`显式加载初始化器，因为这会导致初始化器加载两次。

注意：不能保证您的初始化器将在所有gem初始化器之后运行，因此任何依赖于给定gem已初始化的初始化代码应放在`config.after_initialize`块中。

初始化事件
---------------------

Rails有5个初始化事件可以挂钩（按运行顺序列出）：

* `before_configuration`：在应用程序常量继承自`Rails::Application`时立即运行。在此之前，将评估`config`调用。

* `before_initialize`：在Rails初始化过程的开始阶段，即在应用程序的初始化过程之前直接运行，与`：bootstrap_hook`初始化器一起运行。
* `to_prepare`: 在所有Railties（包括应用程序本身）的初始化程序运行之后，但在急切加载和中间件堆栈构建之前运行。更重要的是，在`development`中的每次代码重新加载时运行，但在`production`和`test`中只运行一次（在启动时）。

* `before_eager_load`: 在急切加载之前直接运行，这是`production`环境的默认行为，而不是`development`环境的默认行为。

* `after_initialize`: 在应用程序初始化之后直接运行，在`config/initializers`中的应用程序初始化程序运行之后。

要为这些钩子定义一个事件，请在`Rails::Application`、`Rails::Railtie`或`Rails::Engine`子类中使用块语法：

```ruby
module YourApp
  class Application < Rails::Application
    config.before_initialize do
      # initialization code goes here
    end
  end
end
```

或者，您也可以通过`Rails.application`对象上的`config`方法来完成：

```ruby
Rails.application.config.before_initialize do
  # initialization code goes here
end
```

警告：在调用`after_initialize`块的时候，应用程序的某些部分，特别是路由，尚未设置好。

### `Rails::Railtie#initializer`

Rails有几个在启动时运行的初始化程序，它们都是使用`Rails::Railtie`的`initializer`方法定义的。下面是Action Controller中`set_helpers_path`初始化程序的示例：

```ruby
initializer "action_controller.set_helpers_path" do |app|
  ActionController::Helpers.helpers_path = app.helpers_paths
end
```

`initializer`方法接受三个参数，第一个是初始化程序的名称，第二个是选项哈希（此处未显示），第三个是块。选项哈希中的`:before`键可以指定此新初始化程序必须在哪个初始化程序之前运行，而`:after`键将指定在运行此初始化程序之后运行哪个初始化程序。

使用`initializer`方法定义的初始化程序将按照它们定义的顺序运行，但使用`：before`或`：after`方法的初始化程序除外。

警告：您可以将初始化程序放在链中的任何其他初始化程序之前或之后，只要它是合乎逻辑的。假设您有4个名为“one”到“four”的初始化程序（按照该顺序定义），并且您定义“four”在“two”之前但在“three”之后运行，这是不合逻辑的，Rails将无法确定您的初始化程序顺序。

`initializer`方法的块参数是应用程序本身的实例，因此我们可以通过使用示例中的`config`方法访问其上的配置。

因为`Rails::Application`间接继承自`Rails::Railtie`，所以可以在`config/application.rb`中使用`initializer`方法为应用程序定义初始化程序。

### 初始化程序

以下是按照定义顺序（除非另有说明）在Rails中找到的所有初始化程序的全面列表。

* `load_environment_hook`：作为一个占位符，以便可以定义`：load_environment_config`在其之前运行。

* `load_active_support`：需要`active_support/dependencies`，它设置了Active Support的基础。如果`config.active_support.bare`不为真，则可选择需要`active_support/all`，这是默认值。

* `initialize_logger`：为应用程序初始化日志记录器（一个`ActiveSupport::Logger`对象），并使其在`Rails.logger`中可访问，前提是在此之前没有插入定义`Rails.logger`的初始化程序。
* `initialize_cache`：如果尚未设置`Rails.cache`，则通过引用`config.cache_store`中的值来初始化缓存，并将结果存储为`Rails.cache`。如果此对象响应`middleware`方法，则将其中间件插入到中间件堆栈中的`Rack::Runtime`之前。

* `set_clear_dependencies_hook`：此初始化程序（仅在`config.enable_reloading`设置为`true`时运行）使用`ActionDispatch::Callbacks.after`来从对象空间中删除在请求期间引用的常量，以便它们将在下一个请求期间重新加载。

* `bootstrap_hook`：运行所有配置的`before_initialize`块。

* `i18n.callbacks`：在开发环境中，设置一个`to_prepare`回调，如果任何区域设置自上次请求以来发生了更改，则调用`I18n.reload!`。在生产环境中，此回调仅在第一个请求上运行。

* `active_support.deprecation_behavior`：根据[`config.active_support.report_deprecations`](#config-active-support-report-deprecations)、[`config.active_support.deprecation`](#config-active-support-deprecation)、[`config.active_support.disallowed_deprecation`](#config-active-support-disallowed-deprecation)和[`config.active_support.disallowed_deprecation_warnings`](#config-active-support-disallowed-deprecation-warnings)为[`Rails.application.deprecators`][]设置废弃报告行为。

* `active_support.initialize_time_zone`：根据`config.time_zone`设置（默认为"UTC"）设置应用程序的默认时区。

* `active_support.initialize_beginning_of_week`：根据`config.beginning_of_week`设置（默认为`:monday`）设置应用程序的默认一周开始日期。

* `active_support.set_configs`：通过将方法名作为setter发送给`ActiveSupport`并通过传递值来使用`config.active_support`中的设置来设置Active Support。

* `action_dispatch.configure`：将`ActionDispatch::Http::URL.tld_length`配置为`config.action_dispatch.tld_length`的值。

* `action_view.set_configs`：通过将方法名作为setter发送给`ActionView::Base`并通过传递值来使用`config.action_view`中的设置来设置Action View。

* `action_controller.assets_config`：如果未明确配置，则将`config.action_controller.assets_dir`初始化为应用程序的公共目录。

* `action_controller.set_helpers_path`：将Action Controller的`helpers_path`设置为应用程序的`helpers_path`。

* `action_controller.parameters_config`：为`ActionController::Parameters`配置强参数选项。

* `action_controller.set_configs`：通过将方法名作为setter发送给`ActionController::Base`并通过传递值来使用`config.action_controller`中的设置来设置Action Controller。

* `action_controller.compile_config_methods`：初始化指定的配置设置的方法，以便更快地访问它们。

* `active_record.initialize_timezone`：将`ActiveRecord::Base.time_zone_aware_attributes`设置为`true`，并将`ActiveRecord::Base.default_timezone`设置为UTC。从数据库读取属性时，它们将被转换为`Time.zone`指定的时区。

* `active_record.logger`：将`ActiveRecord::Base.logger`设置为`Rails.logger`（如果尚未设置）。

* `active_record.migration_error`：配置中间件以检查待处理的迁移。

* `active_record.check_schema_cache_dump`：如果配置并可用，则加载模式缓存转储。

* `active_record.warn_on_records_fetched_greater_than`：在查询返回大量记录时启用警告。

* `active_record.set_configs`：通过将方法名作为setter发送给`ActiveRecord::Base`并通过传递值来使用`config.active_record`中的设置来设置Active Record。

* `active_record.initialize_database`：从`config/database.yml`默认加载数据库配置，并为当前环境建立连接。

* `active_record.log_runtime`：包括`ActiveRecord::Railties::ControllerRuntime`和`ActiveRecord::Railties::JobRuntime`，它们负责将Active Record调用所花费的时间报告回记录器。

* `active_record.set_reloader_hooks`：如果`config.enable_reloading`设置为`true`，则重置所有可重新加载的数据库连接。

* `active_record.add_watchable_files`：将`schema.rb`和`structure.sql`文件添加到可监视的文件列表中。

* `active_job.logger`：将`ActiveJob::Base.logger`设置为`Rails.logger`（如果尚未设置）。
* `active_job.set_configs`：通过将方法名作为setter发送给`ActiveJob::Base`并通过传递值来使用`config.active_job`中的设置来设置Active Job。

* `action_mailer.logger`：将`ActionMailer::Base.logger`设置为`Rails.logger`（如果尚未设置）。

* `action_mailer.set_configs`：通过将方法名作为setter发送给`ActionMailer::Base`并通过传递值来使用`config.action_mailer`中的设置来设置Action Mailer。

* `action_mailer.compile_config_methods`：初始化指定的配置设置的方法，以便更快地访问它们。

* `set_load_path`：此初始化程序在`bootstrap_hook`之前运行。将`config.load_paths`指定的路径和所有自动加载路径添加到`$LOAD_PATH`中。

* `set_autoload_paths`：此初始化程序在`bootstrap_hook`之前运行。将`app`的所有子目录以及`config.autoload_paths`、`config.eager_load_paths`和`config.autoload_once_paths`指定的路径添加到`ActiveSupport::Dependencies.autoload_paths`中。

* `add_routing_paths`：加载（默认情况下）应用程序和railties（包括引擎）中的所有`config/routes.rb`文件，并为应用程序设置路由。

* `add_locales`：将`config/locales`中的文件（来自应用程序、railties和引擎）添加到`I18n.load_path`中，使这些文件中的翻译可用。

* `add_view_paths`：将应用程序、railties和引擎中的`app/views`目录添加到应用程序的视图文件查找路径中。

* `add_mailer_preview_paths`：将应用程序、railties和引擎中的`test/mailers/previews`目录添加到应用程序的邮件预览文件查找路径中。

* `load_environment_config`：此初始化程序在`load_environment_hook`之前运行。加载当前环境的`config/environments`文件。

* `prepend_helpers_path`：将应用程序、railties和引擎中的`app/helpers`目录添加到应用程序的帮助程序查找路径中。

* `load_config_initializers`：加载应用程序、railties和引擎中的`config/initializers`中的所有Ruby文件。此目录中的文件可用于保存在加载所有框架之后应进行的配置设置。

* `engines_blank_point`：提供一个初始化点，用于在加载引擎之前执行任何操作。在此点之后，将运行所有railtie和引擎初始化程序。

* `add_generator_templates`：在应用程序、railties和引擎的`lib/templates`中查找生成器模板，并将其添加到`config.generators.templates`设置中，这将使所有生成器都可以引用这些模板。

* `ensure_autoload_once_paths_as_subset`：确保`config.autoload_once_paths`仅包含`config.autoload_paths`中的路径。如果包含额外的路径，则会引发异常。

* `add_to_prepare_blocks`：将应用程序、railtie或引擎中每个`config.to_prepare`调用的块添加到Action Dispatch的`to_prepare`回调中，在开发中每个请求之前或在生产中第一个请求之前运行。

* `add_builtin_route`：如果应用程序在开发环境下运行，则会将`rails/info/properties`的路由附加到应用程序路由中。此路由在默认的Rails应用程序的`public/index.html`中提供详细信息，如Rails和Ruby版本。

* `build_middleware_stack`：构建应用程序的中间件堆栈，返回一个具有`call`方法的对象，该方法接受一个Rack环境对象作为请求。

* `eager_load!`：如果`config.eager_load`为`true`，则运行`config.before_eager_load`钩子，然后调用`eager_load!`，它将加载所有`config.eager_load_namespaces`。

* `finisher_hook`：提供一个钩子，用于在应用程序的初始化过程完成后运行`config.after_initialize`块，以及运行railties和引擎的`config.after_initialize`块。
* `set_routes_reloader_hook`: 配置Action Dispatch，使用`ActiveSupport::Callbacks.to_run`重新加载路由文件。

* `disable_dependency_loading`: 如果`config.eager_load`设置为`true`，禁用自动依赖加载。

数据库连接池
----------------

Active Record数据库连接由`ActiveRecord::ConnectionAdapters::ConnectionPool`管理，它确保连接池同步访问有限数量的数据库连接的线程数量。默认限制为5，可以在`database.yml`中进行配置。

```ruby
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

由于连接池默认由Active Record处理，所有应用服务器（Thin、Puma、Unicorn等）应该具有相同的行为。数据库连接池最初为空。随着对连接的需求增加，它会创建连接，直到达到连接池限制。

任何一个请求在首次需要访问数据库时都会检出一个连接。在请求结束时，它会将连接检入。这意味着额外的连接槽将再次可用于队列中的下一个请求。

如果尝试使用的连接数超过可用连接数，Active Record将阻塞您并等待从连接池获取连接。如果无法获取连接，将抛出类似下面给出的超时错误。

```ruby
ActiveRecord::ConnectionTimeoutError - 在5.000秒内无法获取数据库连接（等待了5.000秒）
```

如果出现上述错误，您可能需要通过增加`database.yml`中的`pool`选项来增加连接池的大小。

注意：如果在多线程环境中运行，可能存在多个线程同时访问多个连接的情况。因此，根据当前请求负载的不同，可能会有多个线程争夺有限数量的连接。

自定义配置
--------------------

您可以通过Rails配置对象在`config.x`命名空间或直接在`config`下配置自己的代码。这两者之间的关键区别在于，如果您定义了嵌套配置（例如`config.x.nested.hi`），应该使用`config.x`，而对于单层配置（例如`config.hello`），则使用`config`。

```ruby
config.x.payment_processing.schedule = :daily
config.x.payment_processing.retries  = 3
config.super_debugger = true
```

然后，可以通过配置对象访问这些配置点：

```ruby
Rails.configuration.x.payment_processing.schedule # => :daily
Rails.configuration.x.payment_processing.retries  # => 3
Rails.configuration.x.payment_processing.not_set  # => nil
Rails.configuration.super_debugger                # => true
```

您还可以使用`Rails::Application.config_for`加载整个配置文件：

```yaml
# config/payment.yml
production:
  environment: production
  merchant_id: production_merchant_id
  public_key:  production_public_key
  private_key: production_private_key

development:
  environment: sandbox
  merchant_id: development_merchant_id
  public_key:  development_public_key
  private_key: development_private_key
```

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    config.payment = config_for(:payment)
  end
end
```

```ruby
Rails.configuration.payment['merchant_id'] # => production_merchant_id或development_merchant_id
```

`Rails::Application.config_for`支持`shared`配置，以分组常见配置。共享配置将合并到环境配置中。

```yaml
# config/example.yml
shared:
  foo:
    bar:
      baz: 1

development:
  foo:
    bar:
      qux: 2
```

```ruby
# development环境
Rails.application.config_for(:example)[:foo][:bar] #=> { baz: 1, qux: 2 }
```

搜索引擎索引
-----------------------

有时，您可能希望阻止应用程序的某些页面在Google、Bing、Yahoo或Duck Duck Go等搜索网站上可见。索引这些站点的机器人将首先分析`http://your-site.com/robots.txt`文件，以了解它被允许索引的页面。
Rails会在`/public`文件夹中为您创建此文件。默认情况下，它允许搜索引擎索引应用程序的所有页面。如果您想阻止应用程序的所有页面被索引，请使用以下内容：

```
User-agent: *
Disallow: /
```

如果要阻止特定页面的索引，需要使用更复杂的语法。请在[官方文档](https://www.robotstxt.org/robotstxt.html)中了解更多信息。

事件驱动的文件系统监视器
---------------------------

如果加载了[listen gem](https://github.com/guard/listen)，Rails将使用事件驱动的文件系统监视器在启用重新加载时检测更改：

```ruby
group :development do
  gem 'listen', '~> 3.3'
end
```

否则，在每个请求中，Rails都会遍历应用程序树以检查是否有任何更改。

在Linux和macOS上不需要额外的gem，但是一些gem是必需的，[用于*BSD](https://github.com/guard/listen#on-bsd)和[用于Windows](https://github.com/guard/listen#on-windows)。

请注意，[某些设置不受支持](https://github.com/guard/listen#issues--limitations)。
[`config.load_defaults`]: https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults
[`ActiveSupport::ParameterFilter.precompile_filters`]: https://api.rubyonrails.org/classes/ActiveSupport/ParameterFilter.html#method-c-precompile_filters
[ActiveModel::Error#full_message]: https://api.rubyonrails.org/classes/ActiveModel/Error.html#method-i-full_message
[`ActiveSupport::MessageEncryptor`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html
[`ActiveSupport::MessageVerifier`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html
[`message_serializer_fallback.active_support`]: active_support_instrumentation.html#message-serializer-fallback-active-support
[`Rails.application.deprecators`]: https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators
