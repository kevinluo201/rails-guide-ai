**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bba7dd6e311e7abd59e434f12dbebd0e
配置Rails應用程序
==================

本指南介紹了Rails應用程序可用的配置和初始化功能。

閱讀本指南後，您將了解：

* 如何調整Rails應用程序的行為。
* 如何在應用程序啟動時添加其他代碼。

--------------------------------------------------------------------------------

初始化代碼的位置
----------------

Rails提供了四個標準位置來放置初始化代碼：

* `config/application.rb`
* 環境特定的配置文件
* 初始化器
* 在初始化器之後運行的代碼

在Rails之前運行代碼
------------------

如果您的應用程序需要在Rails本身加載之前運行一些代碼，請將其放在`config/application.rb`中`require "rails/all"`的調用之上。

配置Rails組件
--------------

一般來說，配置Rails意味著配置Rails的組件，以及配置Rails本身。配置文件`config/application.rb`和環境特定的配置文件（例如`config/environments/production.rb`）允許您指定要傳遞給所有組件的各種設置。

例如，您可以將以下設置添加到`config/application.rb`文件中：

```ruby
config.time_zone = 'Central Time (US & Canada)'
```

這是Rails本身的設置。如果您想將設置傳遞給個別的Rails組件，可以通過`config/application.rb`中的相同`config`對象進行設置：

```ruby
config.active_record.schema_format = :ruby
```

Rails將使用該特定設置來配置Active Record。

警告：使用公共配置方法而不是直接調用相關類。例如，使用`Rails.application.config.action_mailer.options`而不是`ActionMailer::Base.options`。

注意：如果您需要直接對類應用配置，請在初始化器中使用[延遲加載鉤子](https://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html)，以避免在初始化完成之前自動加載類。這將會中斷，因為在應用程序重新加載時無法安全地重複自動加載。

### 版本化的默認值

[`config.load_defaults`]加載目標版本和所有之前版本的默認配置值。例如，`config.load_defaults 6.1`將加載所有版本，包括版本6.1的默認值。


以下是與每個目標版本關聯的默認值。在存在衝突值的情況下，新版本優先於舊版本。

#### 目標版本7.1的默認值

- [`config.action_controller.allow_deprecated_parameters_hash_equality`](#config-action-controller-allow-deprecated-parameters-hash-equality)：`false`
- [`config.action_dispatch.debug_exception_log_level`](#config-action-dispatch-debug-exception-log-level)：`:error`
- [`config.action_dispatch.default_headers`](#config-action-dispatch-default-headers)：`{ "X-Frame-Options" => "SAMEORIGIN", "X-XSS-Protection" => "0", "X-Content-Type-Options" => "nosniff", "X-Permitted-Cross-Domain-Policies" => "none", "Referrer-Policy" => "strict-origin-when-cross-origin" }`
- [`config.action_text.sanitizer_vendor`](#config-action-text-sanitizer-vendor)：`Rails::HTML::Sanitizer.best_supported_vendor`
- [`config.action_view.sanitizer_vendor`](#config-action-view-sanitizer-vendor)：`Rails::HTML::Sanitizer.best_supported_vendor`
- [`config.active_job.use_big_decimal_serializer`](#config-active-job-use-big-decimal-serializer)：`true`
- [`config.active_record.allow_deprecated_singular_associations_name`](#config-active-record-allow-deprecated-singular-associations-name)：`false`
- [`config.active_record.before_committed_on_all_records`](#config-active-record-before-committed-on-all-records)：`true`
- [`config.active_record.belongs_to_required_validates_foreign_key`](#config-active-record-belongs-to-required-validates-foreign-key)：`false`
- [`config.active_record.default_column_serializer`](#config-active-record-default-column-serializer)：`nil`
- [`config.active_record.encryption.hash_digest_class`](#config-active-record-encryption-hash-digest-class)：`OpenSSL::Digest::SHA256`
- [`config.active_record.encryption.support_sha1_for_non_deterministic_encryption`](#config-active-record-encryption-support-sha1-for-non-deterministic-encryption)：`false`
- [`config.active_record.marshalling_format_version`](#config-active-record-marshalling-format-version)：`7.1`
- [`config.active_record.query_log_tags_format`](#config-active-record-query-log-tags-format)：`:sqlcommenter`
- [`config.active_record.raise_on_assign_to_attr_readonly`](#config-active-record-raise-on-assign-to-attr-readonly)：`true`
- [`config.active_record.run_after_transaction_callbacks_in_order_defined`](#config-active-record-run-after-transaction-callbacks-in-order-defined)：`true`
- [`config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`](#config-active-record-run-commit-callbacks-on-first-saved-instances-in-transaction)：`false`
- [`config.active_record.sqlite3_adapter_strict_strings_by_default`](#config-active-record-sqlite3-adapter-strict-strings-by-default)：`true`
- [`config.active_support.cache_format_version`](#config-active-support-cache-format-version)：`7.1`
- [`config.active_support.message_serializer`](#config-active-support-message-serializer)：`:json_allow_marshal`
- [`config.active_support.raise_on_invalid_cache_expiration_time`](#config-active-support-raise-on-invalid-cache-expiration-time)：`true`
- [`config.active_support.use_message_serializer_for_metadata`](#config-active-support-use-message-serializer-for-metadata)：`true`
- [`config.add_autoload_paths_to_load_path`](#config-add-autoload-paths-to-load-path)：`false`
- [`config.log_file_size`](#config-log-file-size)：`100 * 1024 * 1024`
- [`config.precompile_filter_parameters`](#config-precompile-filter-parameters)：`true`

#### 目標版本7.0的默認值

- [`config.action_controller.raise_on_open_redirects`](#config-action-controller-raise-on-open-redirects)：`true`
- [`config.action_controller.wrap_parameters_by_default`](#config-action-controller-wrap-parameters-by-default)：`true`
- [`config.action_dispatch.cookies_serializer`](#config-action-dispatch-cookies-serializer)：`:json`
- [`config.action_dispatch.default_headers`](#config-action-dispatch-default-headers)：`{ "X-Frame-Options" => "SAMEORIGIN", "X-XSS-Protection" => "0", "X-Content-Type-Options" => "nosniff", "X-Download-Options" => "noopen", "X-Permitted-Cross-Domain-Policies" => "none", "Referrer-Policy" => "strict-origin-when-cross-origin" }`
- [`config.action_mailer.smtp_timeout`](#config-action-mailer-smtp-timeout)：`5`
- [`config.action_view.apply_stylesheet_media_default`](#config-action-view-apply-stylesheet-media-default)：`false`
- [`config.action_view.button_to_generates_button_tag`](#config-action-view-button-to-generates-button-tag)：`true`
- [`config.active_record.automatic_scope_inversing`](#config-active-record-automatic-scope-inversing)：`true`
- [`config.active_record.partial_inserts`](#config-active-record-partial-inserts)：`false`
- [`config.active_record.verify_foreign_keys_for_fixtures`](#config-active-record-verify-foreign-keys-for-fixtures)：`true`
- [`config.active_storage.multiple_file_field_include_hidden`](#config-active-storage-multiple-file-field-include-hidden)：`true`
- [`config.active_storage.variant_processor`](#config-active-storage-variant-processor)：`:vips`
- [`config.active_storage.video_preview_arguments`](#config-active-storage-video-preview-arguments)：`"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015),loop=loop=-1:size=2,trim=start_frame=1' -frames:v 1 -f image2"`
- [`config.active_support.cache_format_version`](#config-active-support-cache-format-version)：`7.0`
- [`config.active_support.executor_around_test_case`](#config-active-support-executor-around-test-case)：`true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class)：`OpenSSL::Digest::SHA256`
- [`config.active_support.isolation_level`](#config-active-support-isolation-level)：`:thread`
- [`config.active_support.key_generator_hash_digest_class`](#config-active-support-key-generator-hash-digest-class)：`OpenSSL::Digest::SHA256`
#### 目標版本 6.1 的預設值

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

#### 目標版本 6.0 的預設值

- [`config.action_dispatch.use_cookies_with_metadata`](#config-action-dispatch-use-cookies-with-metadata): `true`
- [`config.action_mailer.delivery_job`](#config-action-mailer-delivery-job): `"ActionMailer::MailDeliveryJob"`
- [`config.action_view.default_enforce_utf8`](#config-action-view-default-enforce-utf8): `false`
- [`config.active_record.collection_cache_versioning`](#config-active-record-collection-cache-versioning): `true`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `:active_storage_analysis`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `:active_storage_purge`

#### 目標版本 5.2 的預設值

- [`config.action_controller.default_protect_from_forgery`](#config-action-controller-default-protect-from-forgery): `true`
- [`config.action_dispatch.use_authenticated_cookie_encryption`](#config-action-dispatch-use-authenticated-cookie-encryption): `true`
- [`config.action_view.form_with_generates_ids`](#config-action-view-form-with-generates-ids): `true`
- [`config.active_record.cache_versioning`](#config-active-record-cache-versioning): `true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA1`
- [`config.active_support.use_authenticated_message_encryption`](#config-active-support-use-authenticated-message-encryption): `true`

#### 目標版本 5.1 的預設值

- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `true`
- [`config.assets.unknown_asset_fallback`](#config-assets-unknown-asset-fallback): `false`

#### 目標版本 5.0 的預設值

- [`ActiveSupport.to_time_preserves_timezone`](#activesupport-to-time-preserves-timezone): `true`
- [`config.action_controller.forgery_protection_origin_check`](#config-action-controller-forgery-protection-origin-check): `true`
- [`config.action_controller.per_form_csrf_tokens`](#config-action-controller-per-form-csrf-tokens): `true`
- [`config.active_record.belongs_to_required_by_default`](#config-active-record-belongs-to-required-by-default): `true`
- [`config.ssl_options`](#config-ssl-options): `{ hsts: { subdomains: true } }`

### Rails 一般設定

以下的設定方法應該在 `Rails::Railtie` 物件上呼叫，例如 `Rails::Engine` 或 `Rails::Application` 的子類別。

#### `config.add_autoload_paths_to_load_path`

指定是否將自動載入路徑加入到 `$LOAD_PATH` 中。建議在 `:zeitwerk` 模式下的早期，在 `config/application.rb` 中將其設為 `false`。Zeitwerk 在內部使用絕對路徑，而在 `:zeitwerk` 模式下運行的應用程式不需要使用 `require_dependency`，因此模型、控制器、工作等不需要在 `$LOAD_PATH` 中。將其設為 `false` 可以節省 Ruby 在解析相對路徑的 `require` 呼叫時檢查這些目錄的時間，並且可以節省 Bootsnap 的工作和 RAM，因為它不需要為這些目錄建立索引。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| -------- | ------ |
| (原始)   | `true` |
| 7.1      | `false`|

`lib` 目錄不受此標誌的影響，它始終會被添加到 `$LOAD_PATH` 中。

#### `config.after_initialize`

接受一個區塊，在 Rails 完成初始化應用程式後運行。這包括框架本身、引擎和 `config/initializers` 中的所有應用程式初始化器的初始化。請注意，此區塊將會在 rake 任務中運行。用於配置其他初始化器設置的值非常有用：

```ruby
config.after_initialize do
  ActionView::Base.sanitized_allowed_tags.delete 'div'
end
```

#### `config.after_routes_loaded`

接受一個區塊，在 Rails 完成載入應用程式路由後運行。此區塊也將在重新載入路由時運行。

```ruby
config.after_routes_loaded do
  # 執行某些操作，使用 Rails.application.routes
end
```

#### `config.allow_concurrency`

控制是否應該並行處理請求。只有在應用程式代碼不支援多線程時，才應將其設為 `false`。預設值為 `true`。

#### `config.asset_host`

設定資源的主機。在使用 CDN 托管資源時很有用，或者當您想要繞過瀏覽器中內建的並行限制，使用不同的域別別名。這是 `config.action_controller.asset_host` 的簡短版本。

#### `config.assume_ssl`

使應用程式相信所有請求都是通過 SSL 到達的。這在通過終止 SSL 的負載平衡器進行代理時很有用，轉發的請求將顯示為 HTTP 而不是 HTTPS。這使得重定向和 cookie 安全性的目標變為 HTTP 而不是 HTTPS。此中介軟體使伺服器假設代理已經終止了 SSL，並且該請求確實是 HTTPS。
#### `config.autoflush_log`

啟用立即寫入日誌文件輸出，而不是緩存。默認值為 `true`。

#### `config.autoload_once_paths`

接受一個路徑數組，Rails將從中自動加載不會在每個請求中被清除的常量。如果重新加載已啟用（默認情況下在`development`環境中啟用），則相關。否則，所有自動加載只發生一次。此數組的所有元素也必須在`autoload_paths`中。默認為空數組。

#### `config.autoload_paths`

接受一個路徑數組，Rails將從中自動加載常量。默認為空數組。自[Rails 6](upgrading_ruby_on_rails.html#autoloading)開始，不建議調整此值。請參閱[自動加載和重新加載常量](autoloading_and_reloading_constants.html#autoload-paths)。

#### `config.autoload_lib(ignore:)`

此方法將`lib`添加到`config.autoload_paths`和`config.eager_load_paths`中。

通常，`lib`目錄有一些子目錄不應該被自動加載或急切加載。請將它們的名稱相對於`lib`傳遞給`ignore`關鍵字參數。例如，

```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

請參閱[自動加載指南](autoloading_and_reloading_constants.html)以獲取更多詳細信息。

#### `config.autoload_lib_once(ignore:)`

`config.autoload_lib_once`方法與`config.autoload_lib`類似，只是它將`lib`添加到`config.autoload_once_paths`中。

通過調用`config.autoload_lib_once`，可以自動加載`lib`中的類和模塊，即使是從應用程序初始化程序中，但不會重新加載。

#### `config.beginning_of_week`

設置應用程序的默認一周的開始。接受一個有效的星期幾作為符號（例如`：monday`）。

#### `config.cache_classes`

舊設置等效於`!config.enable_reloading`。支持向後兼容。

#### `config.cache_store`

配置Rails緩存使用的緩存存儲。選項包括符號`:memory_store`、`:file_store`、`:mem_cache_store`、`:null_store`、`:redis_cache_store`，或實現緩存API的對象。默認為`:file_store`。有關每個存儲配置選項，請參閱[緩存存儲](caching_with_rails.html#cache-stores)。

#### `config.colorize_logging`

指定在記錄信息時是否使用ANSI顏色代碼。默認為`true`。

#### `config.consider_all_requests_local`

是一個標誌。如果為`true`，則任何錯誤都會導致在HTTP響應中轉儲詳細的調試信息，並且`Rails::Info`控制器將在`/rails/info/properties`中顯示應用程序運行時上下文。在開發和測試環境中默認為`true`，在生產環境中為`false`。為了更精細地控制，將其設置為`false`並在控制器中實現`show_detailed_exceptions?`以指定哪些請求應在錯誤時提供調試信息。

#### `config.console`

允許您設置在運行`bin/rails console`時將用作控制台的類。最好在`console`塊中運行它：

```ruby
console do
  # 這個塊只在運行控制台時調用，
  # 所以我們可以在這裡安全地要求pry
  require "pry"
  config.console = Pry
end
```

#### `config.content_security_policy_nonce_directives`

參見安全指南中的[添加Nonce](security.html#adding-a-nonce)。

#### `config.content_security_policy_nonce_generator`

參見安全指南中的[添加Nonce](security.html#adding-a-nonce)。

#### `config.content_security_policy_report_only`

參見安全指南中的[報告違規](security.html#reporting-violations)。

#### `config.credentials.content_path`

加密憑據文件的路徑。

如果存在，默認為`config/credentials/#{Rails.env}.yml.enc`，否則為`config/credentials.yml.enc`。

注意：為了讓`bin/rails credentials`命令識別此值，必須在`config/application.rb`或`config/environments/#{Rails.env}.rb`中設置。

#### `config.credentials.key_path`

加密憑據密鑰文件的路徑。

如果存在，默認為`config/credentials/#{Rails.env}.key`，否則為`config/master.key`。

注意：為了讓`bin/rails credentials`命令識別此值，必須在`config/application.rb`或`config/environments/#{Rails.env}.rb`中設置。
#### `config.debug_exception_response_format`

設定在開發環境中發生錯誤時回應的格式。預設為 `:api` 用於僅有 API 的應用程式，以及 `:default` 用於一般應用程式。

#### `config.disable_sandbox`

控制是否允許在沙盒模式下啟動控制台。這有助於避免長時間運行的沙盒控制台會導致資料庫伺服器耗盡記憶體。預設為 `false`。

#### `config.eager_load`

當設為 `true` 時，會急於載入所有已註冊的 `config.eager_load_namespaces`。這包括您的應用程式、引擎、Rails 框架和任何其他已註冊的命名空間。

#### `config.eager_load_namespaces`

註冊在 `config.eager_load` 設為 `true` 時會急於載入的命名空間。清單中的所有命名空間都必須回應 `eager_load!` 方法。

#### `config.eager_load_paths`

接受一個路徑陣列，如果 `config.eager_load` 為 true，Rails 將在啟動時急於載入。預設為應用程式的 `app` 目錄中的每個資料夾。

#### `config.enable_reloading`

如果 `config.enable_reloading` 為 true，應用程式的類別和模組在網路請求之間發生變更時會重新載入。在 `development` 環境中預設為 `true`，在 `production` 環境中預設為 `false`。

還定義了 `config.reloading_enabled?` 斷言。

#### `config.encoding`

設定應用程式的全域編碼。預設為 UTF-8。

#### `config.exceptions_app`

設定當發生例外情況時 `ShowException` 中介軟體所呼叫的例外應用程式。
預設為 `ActionDispatch::PublicExceptions.new(Rails.public_path)`。

例外應用程式需要處理 `ActionDispatch::Http::MimeNegotiation::InvalidType` 錯誤，當客戶端發送無效的 `Accept` 或 `Content-Type` 標頭時會引發此錯誤。
預設的 `ActionDispatch::PublicExceptions` 應用程式會自動處理此錯誤，將 `Content-Type` 設為 `text/html`，並返回 `406 Not Acceptable` 狀態。
未能處理此錯誤將導致 `500 Internal Server Error`。

使用 `Rails.application.routes` `RouteSet` 作為例外應用程式也需要進行特殊處理。
可能看起來像這樣：

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

當 `config.reload_classes_only_on_change` 設為 `true` 時，用於偵測檔案系統中的檔案更新的類別。Rails 預設提供 `ActiveSupport::FileUpdateChecker`，以及 `ActiveSupport::EventedFileUpdateChecker`（這個取決於 [listen](https://github.com/guard/listen) gem）。自訂類別必須符合 `ActiveSupport::FileUpdateChecker` API。

#### `config.filter_parameters`

用於過濾在日誌中不想顯示的參數，例如密碼或信用卡號碼。當在 Active Record 物件上呼叫 `#inspect` 時，它也會過濾敏感的資料庫欄位的值。預設情況下，Rails 通過在 `config/initializers/filter_parameter_logging.rb` 中添加以下過濾器來過濾密碼。

```ruby
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

參數過濾器通過部分匹配正則表達式來工作。

#### `config.filter_redirect`

用於從應用程式日誌中過濾重定向 URL。

```ruby
Rails.application.config.filter_redirect += ['s3.amazonaws.com', /private-match/]
```

重定向過濾器通過測試 URL 是否包含字串或匹配正則表達式來工作。

#### `config.force_ssl`

強制所有請求使用 HTTPS 進行服務，並在生成 URL 時將 "https://" 設為預設協議。HTTPS 的執行由 `ActionDispatch::SSL` 中介軟體處理，可以通過 `config.ssl_options` 進行配置。

#### `config.helpers_paths`
定義了一個陣列，用於加載視圖幫助程序的其他路徑。

#### `config.host_authorization`

接受一個選項的哈希，用於配置[HostAuthorization中間件](#actiondispatch-hostauthorization)。

#### `config.hosts`

一個包含字符串、正則表達式或`IPAddr`的陣列，用於驗證`Host`標頭。由[HostAuthorization中間件](#actiondispatch-hostauthorization)用於防止DNS重綁定攻擊。

#### `config.javascript_path`

設置應用程式的JavaScript相對於`app`目錄的路徑。默認值為`javascript`，由[webpacker](https://github.com/rails/webpacker)使用。應用程式配置的`javascript_path`將從`autoload_paths`中排除。

#### `config.log_file_size`

定義Rails日誌文件的最大大小（以字節為單位）。在開發和測試環境中默認為`104_857_600`（100 MiB），在其他所有環境中為無限制。

#### `config.log_formatter`

定義Rails日誌記錄器的格式化程序。此選項默認為`ActiveSupport::Logger::SimpleFormatter`的實例，適用於所有環境。如果您為`config.logger`設置了值，您必須在將其包裝在`ActiveSupport::TaggedLogging`實例之前手動將格式化程序的值傳遞給日誌記錄器，Rails不會自動執行此操作。

#### `config.log_level`

定義Rails日誌記錄器的詳細程度。此選項默認為`：debug`，用於除生產環境外的所有環境，生產環境默認為`：info`。可用的日誌級別有：`：debug`，`：info`，`：warn`，`：error`，`：fatal`和`：unknown`。

#### `config.log_tags`

接受一個`request`對象響應的方法列表、接受`request`對象的`Proc`，或者響應`to_s`的對象。這使得在調試多用戶生產應用程序時，可以輕鬆地使用子域和請求ID等調試信息標記日誌行。

#### `config.logger`

用於`Rails.logger`和任何相關的Rails日誌記錄（如`ActiveRecord::Base.logger`）的記錄器。默認為`ActiveSupport::TaggedLogging`的實例，該實例包裝了一個將日誌輸出到`log/`目錄的`ActiveSupport::Logger`實例。您可以提供自定義的記錄器，為了實現完全兼容，您必須遵循以下指南：

* 要支持格式化程序，您必須手動將`config.log_formatter`值的格式化程序分配給記錄器。
* 要支持標記日誌，日誌實例必須使用`ActiveSupport::TaggedLogging`進行包裝。
* 要支持靜音，記錄器必須包含`ActiveSupport::LoggerSilence`模塊。`ActiveSupport::Logger`類已經包含了這些模塊。

```ruby
class MyLogger < ::Logger
  include ActiveSupport::LoggerSilence
end

mylogger           = MyLogger.new(STDOUT)
mylogger.formatter = config.log_formatter
config.logger      = ActiveSupport::TaggedLogging.new(mylogger)
```

#### `config.middleware`

允許您配置應用程序的中間件。詳細信息請參閱下面的[配置中間件](#configuring-middleware)部分。

#### `config.precompile_filter_parameters`

當為`true`時，將使用[`ActiveSupport::ParameterFilter.precompile_filters`][]預編譯[`config.filter_parameters`](#config-filter-parameters)。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.1      | `true`  |

#### `config.public_file_server.enabled`

配置Rails從public目錄提供靜態文件。此選項默認為`true`，但在生產環境中設置為`false`，因為用於運行應用程序的服務器軟件（例如NGINX或Apache）應該提供靜態文件。如果您在生產環境中使用WEBrick運行或測試應用程序（不建議在生產環境中使用WEBrick），請將此選項設置為`true`。否則，您將無法使用頁面緩存並請求存在於public目錄下的文件。
#### `config.railties_order`

允許手動指定載入 Railties/Engines 的順序。預設值為 `[:all]`。

```ruby
config.railties_order = [Blog::Engine, :main_app, :all]
```

#### `config.rake_eager_load`

當設置為 `true` 時，在執行 Rake 任務時會預先載入應用程式。預設值為 `false`。

#### `config.read_encrypted_secrets`

*已棄用*：應該使用 [credentials](https://guides.rubyonrails.org/security.html#custom-credentials) 來替代加密的 secrets。

當設置為 `true` 時，將嘗試從 `config/secrets.yml.enc` 讀取加密的 secrets。

#### `config.relative_url_root`

可用於告訴 Rails 你正在[部署到子目錄](configuring.html#deploy-to-a-subdirectory-relative-url-root)。預設值為 `ENV['RAILS_RELATIVE_URL_ROOT']`。

#### `config.reload_classes_only_on_change`

啟用或禁用僅在跟踪的文件更改時重新載入類。預設情況下，跟踪 autoload 路徑上的所有文件，並設置為 `true`。如果 `config.enable_reloading` 為 `false`，則忽略此選項。

#### `config.require_master_key`

如果未通過 `ENV["RAILS_MASTER_KEY"]` 或 `config/master.key` 文件提供主密鑰，則導致應用程式無法啟動。

#### `config.secret_key_base`

用於指定應用程式金鑰生成器的輸入密鑰的後備。建議不要設置此值，而是在 `config/credentials.yml.enc` 中指定 `secret_key_base`。有關更多信息和替代配置方法，請參閱 [`secret_key_base` API 文件](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-secret_key_base)。

#### `config.server_timing`

當設置為 `true` 時，將在中間件堆棧中添加 [ServerTiming 中間件](#actiondispatch-servertiming)。

#### `config.session_options`

傳遞給 `config.session_store` 的額外選項。應該使用 `config.session_store` 來設置此值，而不是自行修改。

```ruby
config.session_store :cookie_store, key: "_your_app_session"
config.session_options # => {key: "_your_app_session"}
```

#### `config.session_store`

指定要用於存儲會話的類。可能的值為 `:cache_store`、`:cookie_store`、`:mem_cache_store`、自定義存儲或 `:disabled`。`:disabled` 表示 Rails 不處理會話。

此設置通過常規方法調用進行配置，而不是使用 setter。這允許傳遞其他選項：

```ruby
config.session_store :cookie_store, key: "_your_app_session"
```

如果指定了自定義存儲作為符號，它將解析為 `ActionDispatch::Session` 命名空間：

```ruby
# 使用 ActionDispatch::Session::MyCustomStore 作為會話存儲
config.session_store :my_custom_store
```

默認存儲是一個以應用程式名稱作為會話鍵的 cookie 存儲。

#### `config.ssl_options`

[`ActionDispatch::SSL`](https://api.rubyonrails.org/classes/ActionDispatch/SSL.html) 中間件的配置選項。

默認值取決於 `config.load_defaults` 目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `{}`   |
| 5.0      | `{ hsts: { subdomains: true } }` |

#### `config.time_zone`

設置應用程式的默認時區並啟用 Active Record 的時區感知。

#### `config.x`

用於輕鬆向應用程式配置對象添加嵌套自定義配置。

  ```ruby
  config.x.payment_processing.schedule = :daily
  Rails.configuration.x.payment_processing.schedule # => :daily
  ```

參見 [自定義配置](#custom-configuration)。

### 配置資源

#### `config.assets.css_compressor`

定義要使用的 CSS 壓縮器。預設由 `sass-rails` 設置。目前唯一的替代值是 `:yui`，它使用 `yui-compressor` gem。

#### `config.assets.js_compressor`

定義要使用的 JavaScript 壓縮器。可能的值為 `:terser`、`:closure`、`:uglifier` 和 `:yui`，分別需要使用 `terser`、`closure-compiler`、`uglifier` 或 `yui-compressor` gem。

#### `config.assets.gzip`

一個標誌，用於啟用編譯資源的壓縮版本和非壓縮版本的創建。預設值為 `true`。

#### `config.assets.paths`

包含用於查找資源的路徑。將路徑附加到此配置選項將導致在查找資源時使用這些路徑。
#### `config.assets.precompile`

允許您指定在運行 `bin/rails assets:precompile` 時要預編譯的其他資源（而不僅僅是 `application.css` 和 `application.js`）。

#### `config.assets.unknown_asset_fallback`

允許您修改當資源不在資源管道中時的資源管道行為，如果您使用的是 sprockets-rails 3.2.0 或更新版本。

默認值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `true` |
| 5.1      | `false`|

#### `config.assets.prefix`

定義資源服務的前綴。默認為 `/assets`。

#### `config.assets.manifest`

定義資源預編譯器清單文件的完整路徑。默認為位於公共文件夾內的 `config.assets.prefix` 目錄中名為 `manifest-<random>.json` 的文件。

#### `config.assets.digest`

啟用在資源名稱中使用 SHA256 指紋。默認為 `true`。

#### `config.assets.debug`

禁用資源的連接和壓縮。在 `development.rb` 中默認為 `true`。

#### `config.assets.version`

是一個用於 SHA256 哈希生成的選項字符串。可以更改此值以強制重新編譯所有文件。

#### `config.assets.compile`

是一個布爾值，可用於在生產環境中開啟即時的 Sprockets 編譯。

#### `config.assets.logger`

接受符合 Log4r 或默認 Ruby `Logger` 類接口的日誌記錄器。默認為與 `config.logger` 相同的配置。將 `config.assets.logger` 設置為 `false` 將關閉服務資源的日誌記錄。

#### `config.assets.quiet`

禁用資源請求的日誌記錄。在 `development.rb` 中默認為 `true`。

### 配置生成器

Rails 允許您通過 `config.generators` 方法更改使用的生成器。此方法接受一個塊：

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

此塊中可以使用的完整方法集如下：

* `force_plural` 允許使用複數形式的模型名稱。默認為 `false`。
* `helper` 定義是否生成輔助方法。默認為 `true`。
* `integration_tool` 定義用於生成集成測試的集成工具。默認為 `:test_unit`。
* `system_tests` 定義用於生成系統測試的集成工具。默認為 `:test_unit`。
* `orm` 定義要使用的 ORM。默認為 `false`，默認使用 Active Record。
* `resource_controller` 定義在使用 `bin/rails generate resource` 生成控制器時要使用的生成器。默認為 `:controller`。
* `resource_route` 定義是否生成資源路由定義。默認為 `true`。
* `scaffold_controller` 與 `resource_controller` 不同，它定義在使用 `bin/rails generate scaffold` 生成 _scaffolded_ 控制器時要使用的生成器。默認為 `:scaffold_controller`。
* `test_framework` 定義要使用的測試框架。默認為 `false`，默認使用 minitest。
* `template_engine` 定義要使用的模板引擎，例如 ERB 或 Haml。默認為 `:erb`。

### 配置中間件

每個 Rails 應用程序都帶有一組標準的中間件，它在開發環境中按照以下順序使用：

#### `ActionDispatch::HostAuthorization`

防止 DNS 重綁定和其他 `Host` 標頭攻擊。它在開發環境中默認包含以下配置：

```ruby
Rails.application.config.hosts = [
  IPAddr.new("0.0.0.0/0"),        # 所有 IPv4 地址。
  IPAddr.new("::/0"),             # 所有 IPv6 地址。
  "localhost",                    # 保留的本地主機域名。
  ENV["RAILS_DEVELOPMENT_HOSTS"]  # 用於開發的其他逗號分隔主機。
]
```
在其他環境中，`Rails.application.config.hosts` 是空的，並且不會進行 `Host` 標頭檢查。如果您想要在生產環境中防範標頭攻擊，您需要手動允許允許的主機：

```ruby
Rails.application.config.hosts << "product.com"
```

請求的主機將使用案例運算子（`#===`）與 `hosts` 的項目進行比對，這使得 `hosts` 可以支援 `Regexp`、`Proc` 和 `IPAddr` 等類型的項目。以下是一個使用正則表達式的示例：

```ruby
# 允許來自子域名如 `www.product.com` 和 `beta1.product.com` 的請求
Rails.application.config.hosts << /.*\.product\.com/
```

提供的正則表達式將被包裹在兩個錨點（`\A` 和 `\z`）中，因此它必須完全符合主機名。例如，`/product.com/` 在錨點處理後將無法匹配 `www.product.com`。

還支援一個特殊情況，允許您允許所有子域名：

```ruby
# 允許來自子域名如 `www.product.com` 和 `beta1.product.com` 的請求
Rails.application.config.hosts << ".product.com"
```

您可以通過設置 `config.host_authorization.exclude` 來排除某些請求的主機授權檢查：

```ruby
# 排除對 /healthcheck/ 路徑的請求進行主機檢查
Rails.application.config.host_authorization = {
  exclude: ->(request) { request.path.include?('healthcheck') }
}
```

當一個請求到達未經授權的主機時，將運行一個默認的 Rack 應用程序並回應 `403 Forbidden`。您可以通過設置 `config.host_authorization.response_app` 來自定義此行為。例如：

```ruby
Rails.application.config.host_authorization = {
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

#### `ActionDispatch::ServerTiming`

將指標添加到 `Server-Timing` 標頭中，以便在瀏覽器的開發工具中查看。

#### `ActionDispatch::SSL`

強制使用 HTTPS 來提供每個請求。如果 `config.force_ssl` 設置為 `true`，則啟用。可以通過設置 `config.ssl_options` 來配置傳遞給它的選項。

#### `ActionDispatch::Static`

用於提供靜態資源。如果 `config.public_file_server.enabled` 設置為 `false`，則禁用。如果您需要提供一個名稱不是 `index` 的靜態目錄索引文件，例如 `main.html` 而不是 `index.html`，請設置 `config.public_file_server.index_name`。例如，將 `config.public_file_server.index_name` 設置為 `"main"`，以便在目錄請求中提供 `main.html`。

#### `ActionDispatch::Executor`

允許線程安全的代碼重新加載。如果 `config.allow_concurrency` 設置為 `false`，將加載 `Rack::Lock`。`Rack::Lock` 將應用程序包裝在互斥鎖中，以便只能由單個線程調用。

#### `ActiveSupport::Cache::Strategy::LocalCache`

作為一個基本的內存緩存。此緩存不是線程安全的，僅用於作為單個線程的臨時內存緩存。

#### `Rack::Runtime`

設置一個包含執行請求所花費的時間（以秒為單位）的 `X-Runtime` 標頭。

#### `Rails::Rack::Logger`

通知日誌請求已開始。請求完成後，刷新所有日誌。

#### `ActionDispatch::ShowExceptions`

捕獲應用程序返回的任何異常，並在請求是本地的或者 `config.consider_all_requests_local` 設置為 `true` 時，渲染出漂亮的異常頁面。如果 `config.action_dispatch.show_exceptions` 設置為 `:none`，則無論如何都會引發異常。

#### `ActionDispatch::RequestId`

使唯一的 X-Request-Id 標頭可用於響應，並啟用 `ActionDispatch::Request#uuid` 方法。可以通過 `config.action_dispatch.request_id_header` 進行配置。

#### `ActionDispatch::RemoteIp`

檢查 IP 欺騙攻擊並從請求標頭中獲取有效的 `client_ip`。可以通過 `config.action_dispatch.ip_spoofing_check` 和 `config.action_dispatch.trusted_proxies` 選項進行配置。

#### `Rack::Sendfile`

攔截從文件中提供內容的響應，並將其替換為特定於服務器的 X-Sendfile 標頭。可以通過 `config.action_dispatch.x_sendfile_header` 進行配置。
#### `ActionDispatch::Callbacks`

在提供請求之前運行準備回調。

#### `ActionDispatch::Cookies`

為請求設置 cookie。

#### `ActionDispatch::Session::CookieStore`

負責將會話存儲在 cookie 中。可以通過更改 [`config.session_store`](#config-session-store) 來使用替代的中間件。

#### `ActionDispatch::Flash`

設置 `flash` 鍵。僅在 [`config.session_store`](#config-session-store) 設置為某個值時可用。

#### `Rack::MethodOverride`

如果設置了 `params[:_method]`，允許覆蓋方法。這是支持 PATCH、PUT 和 DELETE HTTP 方法類型的中間件。

#### `Rack::Head`

將 HEAD 請求轉換為 GET 請求並以此提供。

#### 添加自定義中間件

除了這些常用中間件外，您可以使用 `config.middleware.use` 方法添加自己的中間件：

```ruby
config.middleware.use Magical::Unicorns
```

這將在堆疊的末尾放置 `Magical::Unicorns` 中間件。如果您希望在其他中間件之前添加中間件，可以使用 `insert_before`。

```ruby
config.middleware.insert_before Rack::Head, Magical::Unicorns
```

或者，您可以使用索引將中間件插入到確切的位置。例如，如果您想將 `Magical::Unicorns` 中間件插入到堆疊的頂部，可以這樣做：

```ruby
config.middleware.insert_before 0, Magical::Unicorns
```

還有 `insert_after`，它將在另一個中間件之後插入一個中間件：

```ruby
config.middleware.insert_after Rack::Head, Magical::Unicorns
```

中間件也可以完全替換為其他中間件：

```ruby
config.middleware.swap ActionController::Failsafe, Lifo::Failsafe
```

中間件可以從一個位置移動到另一個位置：

```ruby
config.middleware.move_before ActionDispatch::Flash, Magical::Unicorns
```

這將在 `ActionDispatch::Flash` 之前移動 `Magical::Unicorns` 中間件。您也可以在之後移動它：

```ruby
config.middleware.move_after ActionDispatch::Flash, Magical::Unicorns
```

它們也可以從堆疊中完全刪除：

```ruby
config.middleware.delete Rack::MethodOverride
```

### 配置 i18n

所有這些配置選項都委託給 `I18n` 库。

#### `config.i18n.available_locales`

定義應用程序允許的可用區域設置。默認情況下，這些是在區域文件中找到的所有區域鍵，通常在新應用程序上只有 `:en`。

#### `config.i18n.default_locale`

設置用於 i18n 的應用程序的默認區域。默認為 `:en`。

#### `config.i18n.enforce_available_locales`

確保通過 i18n 傳遞的所有區域必須在 `available_locales` 列表中聲明，如果設置了不可用的區域，則引發 `I18n::InvalidLocale` 異常。默認為 `true`。除非強烈要求，否則建議不要禁用此選項，因為它作為一種安全措施防止從用戶輸入設置任何無效的區域。

#### `config.i18n.load_path`

設置 Rails 用於查找區域文件的路徑。默認為 `config/locales/**/*.{yml,rb}`。

#### `config.i18n.raise_on_missing_translations`

確定是否應該為缺少的翻譯引發錯誤。默認為 `false`。

#### `config.i18n.fallbacks`

設置缺少翻譯的回退行為。以下是此選項的 3 個用法示例：

  * 您可以將選項設置為 `true`，以使用默認區域作為回退，如下所示：

    ```ruby
    config.i18n.fallbacks = true
    ```

  * 或者，您可以將回退設置為區域的數組，如下所示：

    ```ruby
    config.i18n.fallbacks = [:tr, :en]
    ```

  * 或者，您可以為各個區域設置不同的回退。例如，如果您想將 `:tr` 用於 `:az` 和 `:de`，`:en` 用於 `:da` 作為回退，可以這樣做：

    ```ruby
    config.i18n.fallbacks = { az: :tr, da: [:de, :en] }
    #或
    config.i18n.fallbacks.map = { az: :tr, da: [:de, :en] }
    ```
### 配置 Active Model

#### `config.active_model.i18n_customize_full_message`

控制是否可以在 i18n 地區文件中覆蓋 [`Error#full_message`][ActiveModel::Error#full_message] 的格式。默認為 `false`。

當設置為 `true` 時，`full_message` 會在地區文件的屬性和模型級別上尋找格式。默認格式為 `"%{attribute} %{message}"`，其中 `attribute` 是屬性的名稱，`message` 是驗證特定的消息。以下示例覆蓋了所有 `Person` 屬性的格式，以及特定 `Person` 屬性（`age`）的格式。

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :age

  validates :name, :age, presence: true
end
```

```yml
en:
  activemodel: # 或 activerecord:
    errors:
      models:
        person:
          # 覆蓋所有 Person 屬性的格式：
          format: "無效的 %{attribute}（%{message}）"
          attributes:
            age:
              # 覆蓋 age 屬性的格式：
              format: "%{message}"
              blank: "請填寫 %{attribute}"
```

```irb
irb> person = Person.new.tap(&:valid?)

irb> person.errors.full_messages
=> [
  "無效的 Name（不能為空）",
  "請填寫 Age"
]

irb> person.errors.messages
=> {
  :name => ["不能為空"],
  :age  => ["請填寫 Age"]
}
```


### 配置 Active Record

`config.active_record` 包含多種配置選項：

#### `config.active_record.logger`

接受符合 Log4r 接口或默認的 Ruby Logger 類的日誌記錄器，然後傳遞給任何新建立的數據庫連接。您可以通過在 Active Record 模型類或 Active Record 模型實例上調用 `logger` 來檢索此日誌記錄器。設置為 `nil` 以禁用日誌記錄。

#### `config.active_record.primary_key_prefix_type`

允許您調整主鍵列的命名方式。默認情況下，Rails 假設主鍵列的名稱為 `id`（不需要設置此配置選項）。還有其他兩種選擇：

* `:table_name` 會使 Customer 類的主鍵為 `customerid`。
* `:table_name_with_underscore` 會使 Customer 類的主鍵為 `customer_id`。

#### `config.active_record.table_name_prefix`

允許您設置一個全局字符串，以在表名之前添加。如果將其設置為 `northwest_`，那麼 Customer 類將尋找 `northwest_customers` 作為其表。默認為空字符串。

#### `config.active_record.table_name_suffix`

允許您設置一個全局字符串，以附加到表名之後。如果將其設置為 `_northwest`，那麼 Customer 類將尋找 `customers_northwest` 作為其表。默認為空字符串。

#### `config.active_record.schema_migrations_table_name`

允許您設置一個字符串作為模式遷移表的名稱。

#### `config.active_record.internal_metadata_table_name`

允許您設置一個字符串作為內部元數據表的名稱。

#### `config.active_record.protected_environments`

允許您設置一個環境名稱的數組，其中禁止執行破壞性操作。

#### `config.active_record.pluralize_table_names`

指定 Rails 是否在數據庫中查找單數或複數表名。如果設置為 `true`（默認值），那麼 Customer 類將使用 `customers` 表。如果設置為 `false`，那麼 Customer 類將使用 `customer` 表。

#### `config.active_record.default_timezone`

確定在從數據庫提取日期和時間時是否使用 `Time.local`（如果設置為 `:local`）或 `Time.utc`（如果設置為 `:utc`）。默認為 `:utc`。
#### `config.active_record.schema_format`

控制將數據庫架構傾印到文件的格式。選項有`:ruby`（默認值），用於依賴於遷移的與數據庫無關的版本，或者`:sql`，用於一組（可能與數據庫相關的）SQL語句。

#### `config.active_record.error_on_ignored_order`

指定在批量查詢期間忽略查詢順序時是否應該引發錯誤。選項有`true`（引發錯誤）或`false`（警告）。默認值為`false`。

#### `config.active_record.timestamped_migrations`

控制遷移是否使用序列整數或時間戳進行編號。默認值為`true`，使用時間戳，如果有多個開發人員在同一應用程序上工作，則優先使用時間戳。

#### `config.active_record.db_warnings_action`

控制當SQL查詢產生警告時要採取的操作。可用的選項有：

  * `:ignore` - 將忽略數據庫警告。這是默認值。

  * `:log` - 將通過`ActiveRecord.logger`以`：warn`級別記錄數據庫警告。

  * `:raise` - 將數據庫警告作為`ActiveRecord::SQLWarning`引發。

  * `:report` - 將數據庫警告報告給Rails錯誤報告器的訂閱者。

  * 自定義proc - 可以提供自定義的proc。它應該接受一個`SQLWarning`錯誤對象。

    例如：

    ```ruby
    config.active_record.db_warnings_action = ->(warning) do
      # 向自定義異常報告服務報告
      Bugsnag.notify(warning.message) do |notification|
        notification.add_metadata(:warning_code, warning.code)
        notification.add_metadata(:warning_level, warning.level)
      end
    end
    ```

#### `config.active_record.db_warnings_ignore`

指定要忽略的警告代碼和消息的允許列表，無論配置的`db_warnings_action`如何。默認行為是報告所有警告。要忽略的警告可以指定為字符串或正則表達式。例如：

  ```ruby
  config.active_record.db_warnings_action = :raise
  # 將不會引發以下警告
  config.active_record.db_warnings_ignore = [
    /Invalid utf8mb4 character string/,
    "An exact warning message",
    "1062", # MySQL Error 1062: Duplicate entry
  ]
  ```

#### `config.active_record.migration_strategy`

控制在遷移中執行架構語句方法的策略類。默認類委託給連接適配器。自定義策略應該繼承自`ActiveRecord::Migration::ExecutionStrategy`，或者可以繼承自`DefaultStrategy`，它將保留未實現方法的默認行為：

```ruby
class CustomMigrationStrategy < ActiveRecord::Migration::DefaultStrategy
  def drop_table(*)
    raise "Dropping tables is not supported!"
  end
end

config.active_record.migration_strategy = CustomMigrationStrategy
```

#### `config.active_record.lock_optimistically`

控制Active Record是否使用樂觀鎖定，默認值為`true`。

#### `config.active_record.cache_timestamp_format`

控制緩存鍵中時間戳值的格式。默認值為`:usec`。

#### `config.active_record.record_timestamps`

是一個布爾值，控制模型上的`create`和`update`操作是否進行時間戳記。默認值為`true`。

#### `config.active_record.partial_inserts`

是一個布爾值，控制在創建新記錄時是否使用部分寫入（即僅設置與默認值不同的屬性）。默認值取決於`config.load_defaults`目標版本：

| 從版本開始 | 默認值為 |
| ---------- | -------- |
| （原始）   | `true`   |
| 7.0        | `false`  |

#### `config.active_record.partial_updates`

是一個布爾值，控制在更新現有記錄時是否使用部分寫入（即僅設置髒數據的屬性）。請注意，當使用部分更新時，應該同時使用樂觀鎖定`config.active_record.lock_optimistically`，因為並發更新可能基於可能過時的讀取狀態寫入屬性。默認值為`true`。
#### `config.active_record.maintain_test_schema`

這是一個布林值，用於控制當你運行測試時，Active Record是否應該嘗試將測試數據庫模式與`db/schema.rb`（或`db/structure.sql`）保持同步。默認值為`true`。

#### `config.active_record.dump_schema_after_migration`

這是一個標誌，用於控制遷移時是否應該進行模式轉儲（`db/schema.rb`或`db/structure.sql`）。在由Rails生成的`config/environments/production.rb`中設置為`false`。如果未設置此配置，默認值為`true`。

#### `config.active_record.dump_schemas`

控制在調用`db:schema:dump`時將轉儲哪些數據庫模式。選項有`：schema_search_path`（默認值），它轉儲`schema_search_path`中列出的任何模式，`：all`，它始終轉儲所有模式，而不考慮`schema_search_path`，或者逗號分隔的模式字符串。

#### `config.active_record.before_committed_on_all_records`

在事務中的所有已註冊記錄上啟用before_committed!回調。以前的行為是，如果在事務中註冊了多個相同的記錄副本，只會在第一個副本上運行回調。

| 版本開始 | 默認值 |
| ------- | ------ |
| (原始)  | `false` |
| 7.1     | `true`  |

#### `config.active_record.belongs_to_required_by_default`

這是一個布林值，用於控制是否在`belongs_to`關聯不存在時使記錄驗證失敗。

默認值取決於`config.load_defaults`的目標版本：

| 版本開始 | 默認值 |
| ------- | ------ |
| (原始)  | `nil`  |
| 5.0     | `true` |

#### `config.active_record.belongs_to_required_validates_foreign_key`

啟用只對必需的父級相關列進行存在性驗證的功能。以前的行為是驗證父級記錄的存在性，這導致在每次更新子級記錄時都要執行額外的查詢以獲取父級，即使父級未更改。

| 版本開始 | 默認值 |
| ------- | ------ |
| (原始)  | `true` |
| 7.1     | `false` |

#### `config.active_record.marshalling_format_version`

當設置為`7.1`時，啟用更高效的Active Record實例序列化，使用`Marshal.dump`。

這會更改序列化格式，因此以這種方式序列化的模型無法被舊版本（<7.1）的Rails讀取。但是，使用舊格式的消息仍然可以被讀取，無論是否啟用了此優化。

| 版本開始 | 默認值 |
| ------- | ------ |
| (原始)  | `6.1`  |
| 7.1     | `7.1`  |

#### `config.active_record.action_on_strict_loading_violation`

如果在關聯上設置了strict_loading，則啟用引發或記錄異常的功能。所有環境中的默認值都是`：raise`。可以將其更改為`：log`，以將違規情況發送到日誌記錄器而不是引發異常。

#### `config.active_record.strict_loading_by_default`

這是一個布林值，用於默認啟用或禁用strict_loading模式。默認值為`false`。

#### `config.active_record.warn_on_records_fetched_greater_than`

允許設置查詢結果大小的警告閾值。如果查詢返回的記錄數超過閾值，則會記錄一個警告。這可用於識別可能導致內存膨脹的查詢。

#### `config.active_record.index_nested_attribute_errors`

允許在嵌套的`has_many`關聯中顯示帶有索引的錯誤。默認值為`false`。
#### `config.active_record.use_schema_cache_dump`

啟用從 `db/schema_cache.yml` 中獲取架構快取資訊（由 `bin/rails db:schema:cache:dump` 生成），而不需要向資料庫發送查詢以獲取此資訊。預設值為 `true`。

#### `config.active_record.cache_versioning`

指示是否使用伴隨變化版本的穩定 `#cache_key` 方法。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| -------- | ------ |
| (原始)   | `false` |
| 5.2      | `true` |

#### `config.active_record.collection_cache_versioning`

當被緩存的物件類型為 `ActiveRecord::Relation` 且發生變化時，允許重複使用相同的快取鍵，將關聯的快取鍵的易變資訊（最大更新時間和計數）移入快取版本以支援重複使用快取鍵。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| -------- | ------ |
| (原始)   | `false` |
| 6.0      | `true` |

#### `config.active_record.has_many_inversing`

在遍歷 `belongs_to` 到 `has_many` 關聯時，啟用設置反向記錄。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| -------- | ------ |
| (原始)   | `false` |
| 6.1      | `true` |

#### `config.active_record.automatic_scope_inversing`

啟用自動推斷具有範圍的關聯的 `inverse_of`。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.0      | `true` |

#### `config.active_record.destroy_association_async_job`

允許指定在後台銷毀相關記錄時將使用的作業。預設為 `ActiveRecord::DestroyAssociationAsyncJob`。

#### `config.active_record.destroy_association_async_batch_size`

允許指定在 `dependent: :destroy_async` 關聯選項中，後台作業中將銷毀的最大記錄數。其他條件相同，較小的批次大小將排入更多、執行時間較短的後台作業，而較大的批次大小將排入較少、執行時間較長的後台作業。此選項預設為 `nil`，這將導致給定關聯的所有相關記錄在同一個後台作業中銷毀。

#### `config.active_record.queues.destroy`

允許指定用於銷毀作業的 Active Job 佇列。當此選項為 `nil` 時，清除作業將被發送到默認的 Active Job 佇列（參見 `config.active_job.default_queue_name`）。預設為 `nil`。

#### `config.active_record.enumerate_columns_in_select_statements`

當為 `true` 時，將始終在 `SELECT` 語句中包含欄位名稱，避免使用萬用字元 `SELECT * FROM ...` 查詢。這可以避免在例如向 PostgreSQL 資料庫添加欄位時出現準備好的語句快取錯誤。預設為 `false`。

#### `config.active_record.verify_foreign_keys_for_fixtures`

確保在測試中載入固定資料後，所有外鍵約束都是有效的。僅支援 PostgreSQL 和 SQLite。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.0      | `true` |

#### `config.active_record.raise_on_assign_to_attr_readonly`

啟用對 attr_readonly 屬性進行賦值時引發異常。先前的行為允許賦值，但默默地不將更改持久化到資料庫。

| 開始版本 | 預設值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.1      | `true` |
#### `config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`

當多個Active Record實例在事務中更改同一個記錄時，Rails只會對其中一個實例運行`after_commit`或`after_rollback`回調。此選項指定Rails如何選擇接收回調的實例。

當設置為`true`時，事務回調將在第一個保存的實例上運行，即使其實例狀態可能已過時。

當設置為`false`時，事務回調將在具有最新實例狀態的實例上運行。選擇這些實例的方式如下：

- 通常情況下，在事務中最後一個保存給定記錄的實例上運行事務回調。
- 有兩個例外情況：
    - 如果記錄在事務中創建，然後由另一個實例更新，則`after_create_commit`回調將在第二個實例上運行。這是根據該實例的狀態而運行的`after_update_commit`回調的替代方式。
    - 如果記錄在事務中被刪除，則`after_destroy_commit`回調將在最後被刪除的實例上觸發，即使過時的實例隨後執行了更新（這將影響0行）。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `true` |
| 7.1      | `false`|

#### `config.active_record.default_column_serializer`

如果未明確為給定列指定序列化器，則使用的序列化器實現。

在歷史上，`serialize`和`store`允許使用替代序列化器實現，但默認情況下使用的是`YAML`，但這不是一個非常高效的格式，如果使用不當可能會引起安全漏洞。

因此，建議在數據庫序列化中使用更嚴格、更有限的格式。

不幸的是，在Ruby的標準庫中沒有真正適合的默認值。`JSON`可以作為一種格式，但`json` gem將不支持的類型轉換為字符串，這可能會導致錯誤。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `YAML` |
| 7.1      | `nil`  |

#### `config.active_record.run_after_transaction_callbacks_in_order_defined`

如果為`true`，則`after_commit`回調將按照模型中定義的順序執行。如果為`false`，則按相反的順序執行。

所有其他回調都始終按照模型中定義的順序執行（除非使用`prepend: true`）。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.1      | `true`  |

#### `config.active_record.query_log_tags_enabled`

指定是否啟用適配器級別的查詢註釋。默認為`false`。

注意：當設置為`true`時，數據庫預編譯語句將自動禁用。

#### `config.active_record.query_log_tags`

定義一個`Array`，指定要插入到SQL註釋中的鍵/值標籤。默認為`[:application]`，一個預定義的標籤，返回應用程序名稱。

#### `config.active_record.query_log_tags_format`

指定用於標籤的格式化程序的`Symbol`。有效值為`:sqlcommenter`和`:legacy`。

默認值取決於`config.load_defaults`目標版本：
| 開始版本 | 預設值 |
| ------- | ------ |
| (原始)  | `:legacy` |
| 7.1     | `:sqlcommenter` |

#### `config.active_record.cache_query_log_tags`

指定是否啟用查詢日誌標籤的快取。對於有大量查詢的應用程序，在請求或作業執行期間上下文不變的情況下，快取查詢日誌標籤可以提供性能優勢。預設為 `false`。

#### `config.active_record.schema_cache_ignored_tables`

定義在生成模式快取時應忽略的表清單。它接受一個 `Array` 字符串，表示表名或正則表達式。

#### `config.active_record.verbose_query_logs`

指定是否在相關查詢下方記錄調用數據庫查詢的方法的源位置。默認情況下，開發環境為 `true`，其他環境為 `false`。

#### `config.active_record.sqlite3_adapter_strict_strings_by_default`

指定是否默認使用 SQLite3Adapter 的嚴格字符串模式。使用嚴格字符串模式會禁用雙引號字符串文字。

SQLite 在處理雙引號字符串文字時存在一些怪異行為。它首先嘗試將雙引號字符串視為標識符名稱，但如果它們不存在，則將其視為字符串文字。因此，拼寫錯誤可能會悄悄地被忽略。例如，可以為不存在的列創建索引。有關詳細信息，請參閱 [SQLite 文檔](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted)。

默認值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| ------- | ------ |
| (原始)  | `false` |
| 7.1     | `true`  |

#### `config.active_record.async_query_executor`

指定異步查詢的池化方式。

默認為 `nil`，這意味著禁用 `load_async`，而是直接在前景中執行查詢。
要實際異步執行查詢，必須將其設置為 `:global_thread_pool` 或 `:multi_thread_pool`。

`:global_thread_pool` 將為應用程序連接的所有數據庫使用單個池。這是僅有單個數據庫的應用程序或一次只查詢一個數據庫分片的應用程序的首選配置。

`:multi_thread_pool` 將為每個數據庫使用一個池，每個池的大小可以在 `database.yml` 中通過 `max_threads` 和 `min_thread` 屬性進行個別配置。這對於定期查詢多個數據庫並需要更精確地定義最大並發性的應用程序非常有用。

#### `config.active_record.global_executor_concurrency`

與 `config.active_record.async_query_executor = :global_thread_pool` 一起使用，定義可以同時執行的異步查詢數量。

默認為 `4`。

此數字必須與 `database.yml` 中配置的數據庫池大小相一致。連接池應該足夠大，以容納前景線程（例如 Web 服務器或作業工作線程）和後台線程。

#### `config.active_record.allow_deprecated_singular_associations_name`

啟用已棄用行為，允許在 `where` 子句中使用複數名稱引用單數關聯。將其設置為 `false` 可提高性能。

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end

Comment.where(post: post_id).count  # => 5

# 當 `allow_deprecated_singular_associations_name` 為 true 時：
Comment.where(posts: post_id).count # => 5（已棄用警告）

# 當 `allow_deprecated_singular_associations_name` 為 false 時：
Comment.where(posts: post_id).count # => 錯誤
```

默認值取決於 `config.load_defaults` 的目標版本：
| 版本開始 | 預設值 |
| -------- | ------ |
| (原始)   | `true` |
| 7.1      | `false`|

#### `config.active_record.yaml_column_permitted_classes`

預設為 `[Symbol]`。允許應用程式在 `ActiveRecord::Coders::YAMLColumn` 的 `safe_load()` 中包含其他允許的類別。

#### `config.active_record.use_yaml_unsafe_load`

預設為 `false`。允許應用程式選擇在 `ActiveRecord::Coders::YAMLColumn` 上使用 `unsafe_load`。

#### `config.active_record.raise_int_wider_than_64bit`

預設為 `true`。決定當 PostgreSQL adapter 收到寬於有符號 64 位元表示的整數時，是否要拋出例外。

#### `ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans` 和 `ActiveRecord::ConnectionAdapters::TrilogyAdapter.emulate_booleans`

控制 Active Record MySQL adapter 是否將所有 `tinyint(1)` 欄位視為布林值。預設為 `true`。

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.create_unlogged_tables`

控制 PostgreSQL 創建的資料庫表是否為「未記錄」，這可以提高性能，但如果資料庫崩潰，會增加資料丟失的風險。強烈建議在生產環境中不要啟用此功能。在所有環境中預設為 `false`。

要在測試中啟用此功能：

```ruby
# config/environments/test.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.create_unlogged_tables = true
end
```

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type`

控制 Active Record PostgreSQL adapter 在遷移或架構中呼叫 `datetime` 時應使用的原生類型。它接受一個符號，必須對應到配置的 `NATIVE_DATABASE_TYPES` 之一。預設為 `:timestamp`，表示遷移中的 `t.datetime` 會建立一個「不帶時區的時間戳」欄位。

要使用「帶時區的時間戳」：

```ruby
# config/application.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.datetime_type = :timestamptz
end
```

如果更改此設定，應該執行 `bin/rails db:migrate` 重新建立 schema.rb。

#### `ActiveRecord::SchemaDumper.ignore_tables`

接受一個表格的陣列，這些表格不應包含在任何生成的 schema 檔案中。

#### `ActiveRecord::SchemaDumper.fk_ignore_pattern`

允許設定一個不同的正則表達式，用於決定是否將外鍵的名稱轉儲到 db/schema.rb。預設情況下，以 `fk_rails_` 開頭的外鍵名稱不會導出到資料庫架構轉儲中。預設為 `/^fk_rails_[0-9a-f]{10}$/`。

#### `config.active_record.encryption.hash_digest_class`

設置 Active Record Encryption 使用的摘要演算法。

預設值取決於 `config.load_defaults` 的目標版本：

| 版本開始 | 預設值                   |
| -------- | ------------------------ |
| (原始)   | `OpenSSL::Digest::SHA1`   |
| 7.1      | `OpenSSL::Digest::SHA256` |

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

啟用對使用 SHA-1 摘要類別加密的現有資料解密的支援。當設為 `false` 時，只支援在 `config.active_record.encryption.hash_digest_class` 中配置的摘要。

預設值取決於 `config.load_defaults` 的目標版本：

| 版本開始 | 預設值 |
| -------- | ------ |
| (原始)   | `true` |
| 7.1      | `false`|

### 配置 Action Controller

`config.action_controller` 包含一些配置設定：

#### `config.action_controller.asset_host`

設置資源的主機。當使用 CDN 來托管資源而不是應用伺服器本身時，這很有用。只有在 Action Mailer 有不同的配置時才應使用此設定，否則使用 `config.asset_host`。

#### `config.action_controller.perform_caching`

配置應用程式是否應該執行 Action Controller 提供的快取功能。在開發環境中設為 `false`，在生產環境中設為 `true`。如果未指定，預設值為 `true`。

#### `config.action_controller.default_static_extension`

配置用於緩存頁面的擴展名。預設為 `.html`。
#### `config.action_controller.include_all_helpers`

配置是否將所有視圖幫助程式碼在任何地方都可用，或者僅限於相應的控制器。如果設置為`false`，則`UsersHelper`方法僅在作為`UsersController`的一部分呈現的視圖中可用。如果設置為`true`，則`UsersHelper`方法在任何地方都可用。默認配置行為（當此選項未明確設置為`true`或`false`時）是所有視圖幫助程式碼對每個控制器都可用。

#### `config.action_controller.logger`

接受符合Log4r或默認的Ruby Logger類的接口的記錄器，然後用於從Action Controller記錄信息。設置為`nil`以禁用日誌記錄。

#### `config.action_controller.request_forgery_protection_token`

設置RequestForgery的令牌參數名稱。調用`protect_from_forgery`將其默認設置為`:authenticity_token`。

#### `config.action_controller.allow_forgery_protection`

啟用或禁用CSRF保護。默認情況下，在測試環境中為`false`，在其他所有環境中為`true`。

#### `config.action_controller.forgery_protection_origin_check`

配置是否應對HTTP `Origin`標頭進行檢查，以作為額外的CSRF防禦。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false` |
| 5.0      | `true` |

#### `config.action_controller.per_form_csrf_tokens`

配置CSRF令牌是否僅對生成它們的方法/操作有效。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false` |
| 5.0      | `true` |

#### `config.action_controller.default_protect_from_forgery`

確定是否在`ActionController::Base`上添加防偽保護。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false` |
| 5.2      | `true` |

#### `config.action_controller.relative_url_root`

可用於告訴Rails您正在[部署到子目錄](configuring.html#deploy-to-a-subdirectory-relative-url-root)。默認值為[`config.relative_url_root`](#config-relative-url-root)。

#### `config.action_controller.permit_all_parameters`

將所有參數設置為默認情況下允許進行批量賦值。默認值為`false`。

#### `config.action_controller.action_on_unpermitted_parameters`

控制當發現未明確允許的參數時的行為。默認值在測試和開發環境中為`:log`，否則為`false`。可選值為：

* `false`表示不採取任何操作
* `:log`表示在`unpermitted_parameters.action_controller`主題上發出`ActiveSupport::Notifications.instrument`事件並以DEBUG級別記錄
* `:raise`表示引發`ActionController::UnpermittedParameters`異常

#### `config.action_controller.always_permitted_parameters`

設置一個默認情況下允許的參數列表。默認值為`['controller', 'action']`。

#### `config.action_controller.enable_fragment_cache_logging`

確定是否以詳細格式記錄片段緩存的讀取和寫入，如下所示：

```
Read fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/d0bdf2974e1ef6d31685c3b392ad0b74 (0.6ms)
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Write fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/3b4e249ac9d168c617e32e84b99218b5 (1.1ms)
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

默認情況下，它設置為`false`，導致以下輸出：

```
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

#### `config.action_controller.raise_on_open_redirects`

當出現未明確允許的開放重定向時，引發`ActionController::Redirecting::UnsafeRedirectError`。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.0      | `true` |
#### `config.action_controller.log_query_tags_around_actions`

決定是否通過`around_filter`自動更新查詢標籤的控制器上下文。默認值為`true`。

#### `config.action_controller.wrap_parameters_by_default`

配置[`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)以默認包裝json請求。

默認值取決於`config.load_defaults`目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.0      | `true`  |

#### `ActionController::Base.wrap_parameters`

配置[`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)。可以在頂級或個別控制器上調用。

#### `config.action_controller.allow_deprecated_parameters_hash_equality`

控制`ActionController::Parameters#==`與`Hash`參數的行為。設置的值決定了`ActionController::Parameters`實例是否等於等效的`Hash`。

默認值取決於`config.load_defaults`目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `true` |
| 7.1      | `false` |

### 配置Action Dispatch

#### `config.action_dispatch.cookies_serializer`

指定用於cookies的序列化器。接受與[`config.active_support.message_serializer`](#config-active-support-message-serializer)相同的值，還有`：hybrid`，它是`：json_allow_marshal`的別名。

默認值取決於`config.load_defaults`目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `:marshal` |
| 7.0      | `:json`    |

#### `config.action_dispatch.debug_exception_log_level`

配置DebugExceptions中間件在記錄請求期間未捕獲的異常時使用的日誌級別。

默認值取決於`config.load_defaults`目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `:fatal` |
| 7.1      | `:error` |

#### `config.action_dispatch.default_headers`

是一個包含每個響應中默認設置的HTTP標頭的哈希。

默認值取決於`config.load_defaults`目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "1; mode=block",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.0      | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.1      | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |

#### `config.action_dispatch.default_charset`

指定所有渲染的默認字符集。默認為`nil`。

#### `config.action_dispatch.tld_length`

設置應用程序的頂級域名（TLD）長度。默認為`1`。

#### `config.action_dispatch.ignore_accept_header`

用於確定是否忽略請求的接受標頭。默認為`false`。

#### `config.action_dispatch.x_sendfile_header`

指定服務器特定的X-Sendfile標頭。這對於從服務器加速文件傳送很有用。例如，可以將其設置為Apache的'X-Sendfile'。

#### `config.action_dispatch.http_auth_salt`

設置HTTP Auth的salt值。默認為`'http authentication'`。

#### `config.action_dispatch.signed_cookie_salt`

設置簽名cookie的salt值。默認為`'signed cookie'`。

#### `config.action_dispatch.encrypted_cookie_salt`

設置加密cookie的salt值。默認為`'encrypted cookie'`。

#### `config.action_dispatch.encrypted_signed_cookie_salt`

設置簽名加密cookie的salt值。默認為`'signed encrypted cookie'`。

#### `config.action_dispatch.authenticated_encrypted_cookie_salt`

設置身份驗證加密cookie的salt值。默認為`'authenticated encrypted cookie'`。

#### `config.action_dispatch.encrypted_cookie_cipher`

設置用於加密cookie的加密算法。默認為`"aes-256-gcm"`。
#### `config.action_dispatch.signed_cookie_digest`

設置用於簽名 cookie 的摘要。默認值為 `"SHA1"`。

#### `config.action_dispatch.cookies_rotations`

允許旋轉加密和簽名 cookie 的密鑰、加密算法和摘要。

#### `config.action_dispatch.use_authenticated_cookie_encryption`

控制簽名和加密 cookie 是否使用 AES-256-GCM 加密算法或舊的 AES-256-CBC 加密算法。

默認值取決於 `config.load_defaults` 的目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false` |
| 5.2      | `true`  |

#### `config.action_dispatch.use_cookies_with_metadata`

啟用將目的元數據嵌入到 cookie 中。

默認值取決於 `config.load_defaults` 的目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false` |
| 6.0      | `true`  |

#### `config.action_dispatch.perform_deep_munge`

配置是否對參數執行 `deep_munge` 方法。詳情請參閱[安全指南](security.html#unsafe-query-generation)。默認值為 `true`。

#### `config.action_dispatch.rescue_responses`

配置將哪些異常分配給 HTTP 狀態碼。它接受一個哈希，您可以指定異常/狀態碼的配對。默認情況下，它定義如下：

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

未配置的任何異常都將映射到 500 內部服務器錯誤。

#### `config.action_dispatch.cookies_same_site_protection`

配置在設置 cookie 時 `SameSite` 屬性的默認值。當設置為 `nil` 時，將不添加 `SameSite` 屬性。為了根據請求動態配置 `SameSite` 屬性的值，可以指定一個 proc。例如：

```ruby
config.action_dispatch.cookies_same_site_protection = ->(request) do
  :strict unless request.user_agent == "TestAgent"
end
```

默認值取決於 `config.load_defaults` 的目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `nil`  |
| 6.1      | `:lax` |

#### `config.action_dispatch.ssl_default_redirect_status`

配置在 `ActionDispatch::SSL` 中間件將非 GET/HEAD 請求從 HTTP 重定向到 HTTPS 時使用的默認 HTTP 狀態碼。

默認值取決於 `config.load_defaults` 的目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `307`  |
| 6.1      | `308`  |

#### `config.action_dispatch.log_rescued_responses`

啟用記錄在 `rescue_responses` 中配置的未處理異常。默認值為 `true`。

#### `ActionDispatch::Callbacks.before`

在請求之前運行一段代碼塊。

#### `ActionDispatch::Callbacks.after`

在請求之後運行一段代碼塊。

### 配置 Action View

`config.action_view` 包含一小部分配置設置：

#### `config.action_view.cache_template_loading`

控制是否在每個請求上重新加載模板。默認為 `!config.enable_reloading`。

#### `config.action_view.field_error_proc`

提供用於顯示來自 Active Model 的錯誤的 HTML 生成器。該塊在 Action View 模板的上下文中評估。默認值為

```ruby
Proc.new { |html_tag, instance| content_tag :div, html_tag, class: "field_with_errors" }
```

#### `config.action_view.default_form_builder`

告訴 Rails 默認使用哪個表單生成器。默認為 `ActionView::Helpers::FormBuilder`。如果您希望在初始化之後加載表單生成器類（以便在開發中的每個請求中重新加載），可以將其作為 `String` 傳遞。
#### `config.action_view.logger`

接受符合 Log4r 或預設的 Ruby Logger 類別介面的記錄器，用於記錄 Action View 的資訊。設置為 `nil` 以禁用記錄。

#### `config.action_view.erb_trim_mode`

指定 ERB 使用的修剪模式。預設為 `'-'`，這會在使用 `<%= -%>` 或 `<%= =%>` 時修剪尾部空格和換行符號。詳細資訊請參閱 [Erubis 文件](http://www.kuwata-lab.com/erubis/users-guide.06.html#topics-trimspaces)。

#### `config.action_view.frozen_string_literal`

使用 `# frozen_string_literal: true` 魔法註解編譯 ERB 樣板，使所有字串文字都被凍結並節省記憶體配置。設置為 `true` 以在所有視圖中啟用此功能。

#### `config.action_view.embed_authenticity_token_in_remote_forms`

允許您設置 `remote: true` 表單中 `authenticity_token` 的預設行為。預設為 `false`，這意味著遠端表單不會包含 `authenticity_token`，這在片段快取表單時很有用。遠端表單從 `meta` 標籤獲取真實性，因此嵌入是不必要的，除非您支援沒有 JavaScript 的瀏覽器。在這種情況下，您可以將 `authenticity_token: true` 作為表單選項傳遞，或將此配置設置為 `true`。

#### `config.action_view.prefix_partial_path_with_controller_namespace`

決定是否從命名空間控制器渲染的模板中的子目錄查找局部樣板。例如，考慮一個名為 `Admin::ArticlesController` 的控制器，它渲染以下模板：

```erb
<%= render @article %>
```

預設設置為 `true`，這將使用 `/admin/articles/_article.erb` 中的局部樣板。將值設置為 `false` 將渲染 `/articles/_article.erb`，這與從非命名空間控制器（例如 `ArticlesController`）渲染的行為相同。

#### `config.action_view.automatically_disable_submit_tag`

決定是否在點擊時自動禁用 `submit_tag`，預設為 `true`。

#### `config.action_view.debug_missing_translation`

決定是否將缺少的翻譯鍵包裝在 `<span>` 標籤中。預設為 `true`。

#### `config.action_view.form_with_generates_remote_forms`

決定是否 `form_with` 生成遠端表單。

預設值取決於 `config.load_defaults` 的目標版本：

| 起始版本 | 預設值 |
| -------- | ------ |
| 5.1      | `true` |
| 6.1      | `false`|

#### `config.action_view.form_with_generates_ids`

決定是否 `form_with` 在輸入元素上生成 id。

預設值取決於 `config.load_defaults` 的目標版本：

| 起始版本 | 預設值 |
| -------- | ------ |
| (原始)   | `false` |
| 5.2      | `true` |

#### `config.action_view.default_enforce_utf8`

決定是否在生成的表單中使用隱藏標籤，以強制舊版的 Internet Explorer 提交以 UTF-8 編碼的表單。

預設值取決於 `config.load_defaults` 的目標版本：

| 起始版本 | 預設值 |
| -------- | ------ |
| (原始)   | `true` |
| 6.0      | `false` |

#### `config.action_view.image_loading`

指定 `<img>` 標籤的 `loading` 屬性的預設值，該屬性由 `image_tag` 助手渲染。例如，當設置為 `"lazy"` 時，由 `image_tag` 渲染的 `<img>` 標籤將包含 `loading="lazy"`，這會[指示瀏覽器等到圖像接近視口時再加載它](https://html.spec.whatwg.org/#lazy-loading-attributes)。（仍然可以通過將例如 `loading: "eager"` 傳遞給 `image_tag` 來覆蓋每個圖像的值。）預設為 `nil`。

#### `config.action_view.image_decoding`

指定 `<img>` 標籤的 `decoding` 屬性的預設值，該屬性由 `image_tag` 助手渲染。預設為 `nil`。
#### `config.action_view.annotate_rendered_view_with_filenames`

決定是否在渲染的視圖中註釋模板文件名。默認值為`false`。

#### `config.action_view.preload_links_header`

決定`javascript_include_tag`和`stylesheet_link_tag`是否生成預加載資源的`Link`標頭。

默認值取決於`config.load_defaults`的目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `nil`  |
| 6.1      | `true` |

#### `config.action_view.button_to_generates_button_tag`

決定`button_to`是否始終渲染`<button>`元素，無論內容是作為第一個參數還是作為塊傳遞。

默認值取決於`config.load_defaults`的目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.0      | `true` |

#### `config.action_view.apply_stylesheet_media_default`

決定當`stylesheet_link_tag`未提供`media`屬性時，是否將`screen`作為默認值渲染。

默認值取決於`config.load_defaults`的目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `true` |
| 7.0      | `false` |

#### `config.action_view.prepend_content_exfiltration_prevention`

決定`form_tag`和`button_to`助手是否生成以瀏覽器安全（但在技術上無效）的HTML開頭的HTML標籤，以確保它們的內容不會被任何前面未關閉的標籤捕獲。默認值為`false`。

#### `config.action_view.sanitizer_vendor`

通過設置`ActionView::Helpers::SanitizeHelper.sanitizer_vendor`來配置Action View使用的HTML淨化器集合。默認值取決於`config.load_defaults`的目標版本：

| 起始版本 | 默認值                 | 解析標記為          |
|----------|------------------------|---------------------|
| (原始)   | `Rails::HTML4::Sanitizer` | HTML4               |
| 7.1      | `Rails::HTML5::Sanitizer`（參見注意） | HTML5               |

注意：`Rails::HTML5::Sanitizer`在JRuby上不受支持，因此在JRuby平台上，Rails將回退使用`Rails::HTML4::Sanitizer`。

### 配置Action Mailbox

`config.action_mailbox`提供以下配置選項：

#### `config.action_mailbox.logger`

包含Action Mailbox使用的日誌記錄器。它接受符合Log4r接口或默認的Ruby Logger類的日誌記錄器。默認值為`Rails.logger`。

```ruby
config.action_mailbox.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.action_mailbox.incinerate_after`

接受一個`ActiveSupport::Duration`，指示在處理`ActionMailbox::InboundEmail`記錄多長時間後銷毀。默認值為`30.days`。

```ruby
# 在處理後的14天內銷毀入站郵件。
config.action_mailbox.incinerate_after = 14.days
```

#### `config.action_mailbox.queues.incineration`

接受一個符號，指示用於銷毀作業的Active Job隊列。當此選項為`nil`時，銷毀作業將發送到默認的Active Job隊列（參見`config.active_job.default_queue_name`）。

默認值取決於`config.load_defaults`的目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `:action_mailbox_incineration` |
| 6.1      | `nil`  |

#### `config.action_mailbox.queues.routing`

接受一個符號，指示用於路由作業的Active Job隊列。當此選項為`nil`時，路由作業將發送到默認的Active Job隊列（參見`config.active_job.default_queue_name`）。

默認值取決於`config.load_defaults`的目標版本：

| 起始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `:action_mailbox_routing` |
| 6.1      | `nil`  |

#### `config.action_mailbox.storage_service`
接受一個表示要使用的Active Storage服務的符號，用於上傳郵件。當此選項為`nil`時，郵件將上傳到默認的Active Storage服務（參見`config.active_storage.service`）。

### 配置Action Mailer

在`config.action_mailer`上有許多可用的設置：

#### `config.action_mailer.asset_host`

設置資源的主機。當使用CDN來托管資源而不是應用程序服務器本身時，這很有用。只有在Action Controller有不同的配置時才應使用此選項，否則使用`config.asset_host`。

#### `config.action_mailer.logger`

接受符合Log4r或默認的Ruby Logger類的接口的日誌記錄器，用於記錄Action Mailer的信息。設置為`nil`以禁用日誌記錄。

#### `config.action_mailer.smtp_settings`

允許對`:smtp`傳遞方式進行詳細配置。它接受一個選項的哈希，可以包含以下任何選項：

* `:address` - 允許您使用遠程郵件服務器。只需將其從默認的“localhost”設置更改即可。
* `:port` - 如果您的郵件服務器不運行在25端口上，您可以更改它。
* `:domain` - 如果您需要指定HELO域，可以在這裡指定。
* `:user_name` - 如果您的郵件服務器需要身份驗證，請在此設置中設置用戶名。
* `:password` - 如果您的郵件服務器需要身份驗證，請在此設置中設置密碼。
* `:authentication` - 如果您的郵件服務器需要身份驗證，您需要在這裡指定身份驗證類型。這是一個符號，可以是`:plain`、`:login`或`:cram_md5`之一。
* `:enable_starttls` - 在連接到SMTP服務器時使用STARTTLS，如果不支持則失敗。默認為`false`。
* `:enable_starttls_auto` - 檢測SMTP服務器中是否啟用了STARTTLS並開始使用它。默認為`true`。
* `:openssl_verify_mode` - 在使用TLS時，您可以設置OpenSSL如何檢查證書。如果您需要驗證自簽名和/或通配符證書，這很有用。這可以是OpenSSL驗證常量之一，`:none`或`:peer`，或分別是常量`OpenSSL::SSL::VERIFY_NONE`或`OpenSSL::SSL::VERIFY_PEER`。
* `:ssl/:tls` - 啟用SMTP連接使用SMTP/TLS（SMTPS：SMTP通過直接TLS連接）。
* `:open_timeout` - 嘗試打開連接時等待的秒數。
* `:read_timeout` - 等待超時的秒數，直到超時讀取（2）調用。

此外，還可以傳遞任何[Mail::SMTP所尊重的配置選項](https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/smtp.rb)。

#### `config.action_mailer.smtp_timeout`

允許配置`:smtp`傳遞方式的`:open_timeout`和`:read_timeout`值。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `nil`  |
| 7.0      | `5`    |

#### `config.action_mailer.sendmail_settings`

允許對`sendmail`傳遞方式進行詳細配置。它接受一個選項的哈希，可以包含以下任何選項：

* `:location` - sendmail可執行文件的位置。默認為`/usr/sbin/sendmail`。
* `:arguments` - 命令行參數。默認為`%w[ -i ]`。

#### `config.action_mailer.raise_delivery_errors`

指定是否在無法完成郵件發送時引發錯誤。默認為`true`。
#### `config.action_mailer.delivery_method`

定義郵件發送方式，默認為`:smtp`。詳情請參閱[Action Mailer指南中的配置部分](action_mailer_basics.html#action-mailer-configuration)。

#### `config.action_mailer.perform_deliveries`

指定是否實際發送郵件，默認為`true`。在測試時將其設置為`false`可能很方便。

#### `config.action_mailer.default_options`

配置Action Mailer的默認值。用於為每個郵件設置`from`或`reply_to`等選項。默認值為：

```ruby
mime_version:  "1.0",
charset:       "UTF-8",
content_type: "text/plain",
parts_order:  ["text/plain", "text/enriched", "text/html"]
```

分配一個哈希值以設置其他選項：

```ruby
config.action_mailer.default_options = {
  from: "noreply@example.com"
}
```

#### `config.action_mailer.observers`

註冊郵件發送時將通知的觀察者。

```ruby
config.action_mailer.observers = ["MailObserver"]
```

#### `config.action_mailer.interceptors`

註冊在發送郵件之前將被調用的攔截器。

```ruby
config.action_mailer.interceptors = ["MailInterceptor"]
```

#### `config.action_mailer.preview_interceptors`

註冊在預覽郵件之前將被調用的攔截器。

```ruby
config.action_mailer.preview_interceptors = ["MyPreviewMailInterceptor"]
```

#### `config.action_mailer.preview_paths`

指定郵件預覽的位置。將路徑添加到此配置選項將導致在郵件預覽搜索中使用這些路徑。

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

#### `config.action_mailer.show_previews`

啟用或禁用郵件預覽。在開發環境中，默認為`true`。

```ruby
config.action_mailer.show_previews = false
```

#### `config.action_mailer.perform_caching`

指定郵件模板是否應執行片段緩存。如果未指定，默認值將為`true`。

#### `config.action_mailer.deliver_later_queue_name`

指定用於默認發送作業的Active Job隊列（參見`config.action_mailer.delivery_job`）。當此選項設置為`nil`時，發送作業將發送到默認的Active Job隊列（參見`config.active_job.default_queue_name`）。

Mailer類可以覆蓋此選項以使用不同的隊列。請注意，這僅適用於使用默認發送作業的情況。如果您的Mailer使用自定義作業，將使用其隊列。

請確保您的Active Job適配器也配置為處理指定的隊列，否則發送作業可能會被默默忽略。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| ------- | ------ |
| (原始)  | `:mailers` |
| 6.1     | `nil`     |

#### `config.action_mailer.delivery_job`

指定郵件的發送作業。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| ------- | ------ |
| (原始)  | `ActionMailer::MailDeliveryJob` |
| 6.0     | `"ActionMailer::MailDeliveryJob"` |

### 配置Active Support

Active Support提供了一些配置選項：

#### `config.active_support.bare`

啟用或禁用在啟動Rails時加載`active_support/all`。默認為`nil`，表示加載`active_support/all`。

#### `config.active_support.test_order`

設置測試用例的執行順序。可能的值為`:random`和`:sorted`。默認為`:random`。

#### `config.active_support.escape_html_entities_in_json`

啟用或禁用在JSON序列化中對HTML實體進行轉義。默認為`true`。

#### `config.active_support.use_standard_json_time_format`

啟用或禁用將日期序列化為ISO 8601格式。默認為`true`。

#### `config.active_support.time_precision`

設置JSON編碼的時間值的精度。默認為`3`。

#### `config.active_support.hash_digest_class`

允許配置用於生成非敏感摘要（例如ETag標頭）的摘要類。

默認值取決於`config.load_defaults`目標版本：
| 開始版本 | 預設值 |
| --------------------- | -------------------- |
| (原始)            | `OpenSSL::Digest::MD5` |
| 5.2                   | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.key_generator_hash_digest_class`

允許配置用於從配置的密鑰基底中派生密鑰的摘要類，例如用於加密 cookie。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| --------------------- | -------------------- |
| (原始)            | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.use_authenticated_message_encryption`

指定是否使用 AES-256-GCM 驗證加密作為加密訊息的預設加密算法，而不是 AES-256-CBC。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| --------------------- | -------------------- |
| (原始)            | `false`              |
| 5.2                   | `true`               |

#### `config.active_support.message_serializer`

指定 [`ActiveSupport::MessageEncryptor`][] 和 [`ActiveSupport::MessageVerifier`][] 實例使用的預設序列化器。為了更容易遷移不同的序列化器，提供的序列化器包含回退機制以支援多種反序列化格式：

| 序列化器 | 序列化和反序列化 | 回退反序列化 |
| ---------- | ------------------------- | -------------------- |
| `:marshal` | `Marshal` | `ActiveSupport::JSON`, `ActiveSupport::MessagePack` |
| `:json` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack` |
| `:json_allow_marshal` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack`, `Marshal` |
| `:message_pack` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON` |
| `:message_pack_allow_marshal` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON`, `Marshal` |

警告：在消息簽名密鑰洩漏的情況下，`Marshal` 可能成為反序列化攻擊的潛在向量。_如果可能，請選擇不支援 `Marshal` 的序列化器。_

資訊：`:message_pack` 和 `:message_pack_allow_marshal` 序列化器支援一些 JSON 不支援的 Ruby 類型的往返，例如 `Symbol`。它們還可以提供更好的性能和更小的有效載荷大小。但是，它們需要 [`msgpack` gem](https://rubygems.org/gems/msgpack)。

上述每個序列化器在回退到替代的反序列化格式時會發出 [`message_serializer_fallback.active_support`][] 事件通知，讓您可以追蹤此類回退發生的頻率。

或者，您可以指定任何回應 `dump` 和 `load` 方法的序列化器物件。例如：

```ruby
config.active_job.message_serializer = YAML
```

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| --------------------- | -------------------- |
| (原始)            | `:marshal`           |
| 7.1                   | `:json_allow_marshal` |


#### `config.active_support.use_message_serializer_for_metadata`

當為 `true` 時，啟用將訊息資料和元資料一起序列化的性能優化。這會更改訊息格式，因此以此方式序列化的訊息無法被舊版（< 7.1）的 Rails 讀取。但是，使用舊格式的訊息仍然可以被讀取，無論此優化是否啟用。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| --------------------- | -------------------- |
| (原始)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_support.cache_format_version`

指定用於快取的序列化格式。可能的值為 `6.1`、`7.0` 和 `7.1`。

`6.1`、`7.0` 和 `7.1` 格式都使用 `Marshal` 作為預設編碼器，但 `7.0` 使用更高效的表示方式來表示快取項目，而 `7.1` 則包含了對於裸字符串值（例如視圖片段）的額外優化。
所有格式都是向前和向後兼容的，這意味著在使用另一個格式時，可以讀取以另一個格式寫入的快取項目。這種行為使得在不使整個快取失效的情況下輕鬆遷移格式。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `6.1`  |
| 7.0      | `7.0`  |
| 7.1      | `7.1`  |

#### `config.active_support.deprecation`

配置廢棄警告的行為。選項包括`：raise`、`：stderr`、`：log`、`：notify`和`：silence`。

在默認生成的`config/environments`文件中，開發環境設置為`：log`，測試環境設置為`：stderr`，生產環境則省略，改為使用[`config.active_support.report_deprecations`](#config-active-support-report-deprecations)。

#### `config.active_support.disallowed_deprecation`

配置不允許的廢棄警告的行為。選項包括`：raise`、`：stderr`、`：log`、`：notify`和`：silence`。

在默認生成的`config/environments`文件中，開發環境和測試環境設置為`：raise`，生產環境則省略，改為使用[`config.active_support.report_deprecations`](#config-active-support-report-deprecations)。

#### `config.active_support.disallowed_deprecation_warnings`

配置應用程序視為不允許的廢棄警告。這允許將特定的廢棄警告視為嚴重錯誤。

#### `config.active_support.report_deprecations`

當設置為`false`時，禁用所有廢棄警告，包括不允許的廢棄警告，來自[應用程序的廢棄器](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators)的所有廢棄警告都將被禁用。這包括Rails和其他寶石的所有廢棄器發出的所有廢棄警告，但可能無法阻止從ActiveSupport::Deprecation發出的所有廢棄警告。

在默認生成的`config/environments`文件中，生產環境設置為`false`。

#### `config.active_support.isolation_level`

配置大部分Rails內部狀態的局部性。如果使用基於纖維的服務器或作業處理器（例如`falcon`），應將其設置為`：fiber`。否則，最好使用`：thread`局部性。默認值為`：thread`。

#### `config.active_support.executor_around_test_case`

配置測試套件在測試用例周圍調用`Rails.application.executor.wrap`。這使得測試用例的行為更接近實際請求或作業。在測試中通常禁用的幾個功能，例如Active Record查詢緩存和異步查詢，將被啟用。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false`|
| 7.0      | `true` |

#### `ActiveSupport::Logger.silencer`

設置為`false`以禁用在區塊中靜音記錄的功能。默認值為`true`。

#### `ActiveSupport::Cache::Store.logger`

指定在緩存存儲操作中使用的記錄器。

#### `ActiveSupport.to_time_preserves_timezone`

指定`to_time`方法是否保留其接收者的UTC偏移量。如果為`false`，`to_time`方法將轉換為本地系統的UTC偏移量。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false`|
| 5.0      | `true` |

#### `ActiveSupport.utc_to_local_returns_utc_offset_times`

配置`ActiveSupport::TimeZone.utc_to_local`返回具有UTC偏移量而不是包含該偏移量的UTC時間的時間。

默認值取決於`config.load_defaults`目標版本：

| 開始版本 | 默認值 |
| -------- | ------ |
| (原始)   | `false`|
| 6.1      | `true` |
#### `config.active_support.raise_on_invalid_cache_expiration_time`

指定當`Rails.cache`的`fetch`或`write`方法給定無效的`expires_at`或`expires_in`時間時是否引發`ArgumentError`。

選項為`true`和`false`。如果為`false`，則該異常將被報告為“已處理”並記錄。

默認值取決於`config.load_defaults`的目標版本：

| 版本開始 | 默認值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.1      | `true`  |

### 配置Active Job

`config.active_job`提供以下配置選項：

#### `config.active_job.queue_adapter`

設置佇列後端的適配器。默認適配器為`:async`。有關最新的內置適配器列表，請參閱[ActiveJob::QueueAdapters API文檔](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html)。

```ruby
# 確保在Gemfile中有適配器的gem
# 並遵循適配器的特定安裝
# 和部署指示。
config.active_job.queue_adapter = :sidekiq
```

#### `config.active_job.default_queue_name`

可用於更改默認佇列名稱。默認情況下為`"default"`。

```ruby
config.active_job.default_queue_name = :medium_priority
```

#### `config.active_job.queue_name_prefix`

允許為所有作業設置可選的非空佇列名稱前綴。默認情況下為空且未使用。

以下配置將在生產環境中將給定的作業排入`production_high_priority`佇列：

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

默認值為`'_'`。如果設置了`queue_name_prefix`，則`queue_name_delimiter`將連接前綴和非前綴的佇列名稱。

以下配置將在`video_server.low_priority`佇列上排隊提供的作業：

```ruby
# 必須設置前綴才能使用分隔符
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

接受符合Log4r接口或默認的Ruby Logger類的日誌記錄器，用於記錄Active Job的信息。您可以通過在Active Job類或Active Job實例上調用`logger`來檢索此日誌記錄器。設置為`nil`以禁用日誌記錄。

#### `config.active_job.custom_serializers`

允許設置自定義的參數序列化器。默認為`[]`。

#### `config.active_job.log_arguments`

控制是否記錄作業的參數。默認為`true`。

#### `config.active_job.verbose_enqueue_logs`

指定是否在相關的排隊日誌行下方記錄排隊後台作業的方法的源位置。默認情況下，該標誌在開發環境中為`true`，在其他所有環境中為`false`。

#### `config.active_job.retry_jitter`

控制在重試失敗的作業時計算的延遲時間時應用的“抖動”（隨機變化）量。

默認值取決於`config.load_defaults`的目標版本：

| 版本開始 | 默認值 |
| -------- | ------ |
| (原始)   | `0.0`  |
| 6.1      | `0.15` |

#### `config.active_job.log_query_tags_around_perform`

確定是否通過`around_perform`自動更新查詢標籤的作業上下文。默認值為`true`。

#### `config.active_job.use_big_decimal_serializer`

啟用新的`BigDecimal`參數序列化器，可保證往返。如果沒有此序列化器，某些佇列適配器可能將`BigDecimal`參數序列化為簡單（不可往返）的字符串。

警告：在部署具有多個副本的應用程序時，舊的（Rails 7.1之前的）副本將無法從此序列化器反序列化`BigDecimal`參數。因此，應該在所有副本成功升級到Rails 7.1之後才能啟用此設置。
預設值取決於 `config.load_defaults` 的目標版本:

| 開始版本 | 預設值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.1      | `true`  |

### 設定 Action Cable

#### `config.action_cable.url`

接受一個字串，用於指定 Action Cable 伺服器的 URL。如果你運行的 Action Cable 伺服器與主應用程式分開，則可以使用此選項。

#### `config.action_cable.mount_path`

接受一個字串，用於指定 Action Cable 的掛載路徑，作為主伺服器程序的一部分。預設為 `/cable`。如果你不想將 Action Cable 掛載為常規 Rails 伺服器的一部分，可以將其設置為 nil。

你可以在 [Action Cable 概述](action_cable_overview.html#configuration) 中找到更詳細的配置選項。

#### `config.action_cable.precompile_assets`

決定是否將 Action Cable 資源添加到資源編譯流程中。如果未使用 Sprockets，則不會生效。預設值為 `true`。

### 設定 Active Storage

`config.active_storage` 提供以下配置選項:

#### `config.active_storage.variant_processor`

接受符號 `:mini_magick` 或 `:vips`，指定是否使用 MiniMagick 或 ruby-vips 進行變體轉換和 Blob 分析。

預設值取決於 `config.load_defaults` 的目標版本:

| 開始版本 | 預設值        |
| -------- | ------------- |
| (原始)   | `:mini_magick` |
| 7.0      | `:vips`        |

#### `config.active_storage.analyzers`

接受一個類別陣列，指示 Active Storage Blob 可用的分析器。預設情況下，它被定義為:

```ruby
config.active_storage.analyzers = [ActiveStorage::Analyzer::ImageAnalyzer::Vips, ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick, ActiveStorage::Analyzer::VideoAnalyzer, ActiveStorage::Analyzer::AudioAnalyzer]
```

圖像分析器可以提取圖像 Blob 的寬度和高度；視頻分析器可以提取視頻 Blob 的寬度、高度、持續時間、角度、長寬比以及視頻/音頻通道的存在/缺失；音頻分析器可以提取音頻 Blob 的持續時間和比特率。

#### `config.active_storage.previewers`

接受一個類別陣列，指示 Active Storage Blob 中可用的圖像預覽器。預設情況下，它被定義為:

```ruby
config.active_storage.previewers = [ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer]
```

`PopplerPDFPreviewer` 和 `MuPDFPreviewer` 可以從 PDF Blob 的第一頁生成縮略圖；`VideoPreviewer` 可以從視頻 Blob 的相關幀生成縮略圖。

#### `config.active_storage.paths`

接受一個選項哈希，指示預覽器/分析器命令的位置。預設為 `{}`，表示命令將在默認路徑中尋找。可以包含以下任何選項:

* `:ffprobe` - ffprobe 執行檔的位置。
* `:mutool` - mutool 執行檔的位置。
* `:ffmpeg` - ffmpeg 執行檔的位置。

```ruby
config.active_storage.paths[:ffprobe] = '/usr/local/bin/ffprobe'
```

#### `config.active_storage.variable_content_types`

接受一個字串陣列，指示 Active Storage 可以通過變體處理器轉換的內容類型。預設情況下，它被定義為:

```ruby
config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/bmp image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)
```

#### `config.active_storage.web_image_content_types`

接受一個字串陣列，表示 Web 圖像內容類型，其中變體可以在不轉換為回退的 PNG 格式的情況下進行處理。如果你想在應用程式中使用 `WebP` 或 `AVIF` 變體，可以將 `image/webp` 或 `image/avif` 添加到此陣列中。

預設情況下，它被定義為:
```ruby
config.active_storage.web_image_content_types = %w(image/png image/jpeg image/gif)
```

#### `config.active_storage.content_types_to_serve_as_binary`

接受一個字串陣列，指示 Active Storage 始終將其作為附件而不是內嵌方式提供的內容類型。
預設情況下，它被定義為：

```ruby
config.active_storage.content_types_to_serve_as_binary = %w(text/html image/svg+xml application/postscript application/x-shockwave-flash text/xml application/xml application/xhtml+xml application/mathml+xml text/cache-manifest)
```

#### `config.active_storage.content_types_allowed_inline`

接受一個字串陣列，指示 Active Storage 允許作為內嵌方式提供的內容類型。
預設情況下，它被定義為：

```ruby
config.active_storage.content_types_allowed_inline` = %w(image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon application/pdf)
```

#### `config.active_storage.queues.analysis`

接受一個符號，指示用於分析作業的 Active Job 佇列。當此選項為 `nil` 時，分析作業將被發送到預設的 Active Job 佇列（參見 `config.active_job.default_queue_name`）。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| ------- | ------ |
| 6.0     | `:active_storage_analysis` |
| 6.1     | `nil`  |

#### `config.active_storage.queues.purge`

接受一個符號，指示用於清除作業的 Active Job 佇列。當此選項為 `nil` 時，清除作業將被發送到預設的 Active Job 佇列（參見 `config.active_job.default_queue_name`）。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| ------- | ------ |
| 6.0     | `:active_storage_purge` |
| 6.1     | `nil`  |

#### `config.active_storage.queues.mirror`

接受一個符號，指示用於直接上傳鏡像作業的 Active Job 佇列。當此選項為 `nil` 時，鏡像作業將被發送到預設的 Active Job 佇列（參見 `config.active_job.default_queue_name`）。預設值為 `nil`。

#### `config.active_storage.logger`

可用於設置 Active Storage 使用的記錄器。接受符合 Log4r 或預設的 Ruby Logger 類的介面的記錄器。

```ruby
config.active_storage.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.active_storage.service_urls_expire_in`

決定由以下生成的 URL 的預設到期時間：

* `ActiveStorage::Blob#url`
* `ActiveStorage::Blob#service_url_for_direct_upload`
* `ActiveStorage::Variant#url`

預設值為 5 分鐘。

#### `config.active_storage.urls_expire_in`

決定由 Active Storage 在 Rails 應用程式中生成的 URL 的預設到期時間。預設值為 `nil`。

#### `config.active_storage.routes_prefix`

可用於設置 Active Storage 提供的路由的路由前綴。接受一個字串，將其附加到生成的路由之前。

```ruby
config.active_storage.routes_prefix = '/files'
```

預設值為 `/rails/active_storage`。

#### `config.active_storage.track_variants`

決定是否在資料庫中記錄變體。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| ------- | ------ |
| (原始)  | `false` |
| 6.1     | `true`  |

#### `config.active_storage.draw_routes`

可用於切換 Active Storage 路由生成。預設值為 `true`。

#### `config.active_storage.resolve_model_to_route`

可用於全局更改 Active Storage 傳遞檔案的方式。

允許的值有：

* `:rails_storage_redirect`：重定向到簽名的、短暫的服務 URL。
* `:rails_storage_proxy`：通過下載代理檔案。

預設值為 `:rails_storage_redirect`。

#### `config.active_storage.video_preview_arguments`

可用於更改 ffmpeg 生成視頻預覽圖像的方式。

預設值取決於 `config.load_defaults` 的目標版本：

| 開始版本 | 預設值 |
| ------- | ------ |
| (原始)  | `"-y -vframes 1 -f image2"` |
| 7.0     | `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015)"`<sup><mark><strong><em>1</em></strong></mark></sup> <br> `+ ",loop=loop=-1:size=2,trim=start_frame=1'"`<sup><mark><strong><em>2</em></strong></mark></sup><br> `+ " -frames:v 1 -f image2"` <br><br> <ol><li>選擇第一個視頻幀，加上關鍵幀，加上滿足場景變化閾值的幀。</li> <li>當沒有其他幀滿足標準時，使用第一個視頻幀作為後備，通過循環第一個（一個或兩個）選擇的幀，然後丟棄第一個循環的幀。</li></ol> |
#### `config.active_storage.multiple_file_field_include_hidden`

從 Rails 7.1 開始，Active Storage 的 `has_many_attached` 關聯將預設為 _替換_ 當前集合而不是 _附加_ 到它。因此，為了支援提交一個 _空_ 集合，當 `multiple_file_field_include_hidden` 為 `true` 時，[`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) 輔助方法將渲染一個輔助隱藏欄位，類似於 [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) 輔助方法渲染的輔助欄位。

預設值取決於 `config.load_defaults` 目標版本：

| 開始版本 | 預設值 |
| -------- | ------ |
| (原始)   | `false` |
| 7.0      | `true`  |

#### `config.active_storage.precompile_assets`

決定是否將 Active Storage 資源添加到資源管道的預編譯中。如果不使用 Sprockets，則不會產生影響。預設值為 `true`。

### 設定 Action Text

#### `config.action_text.attachment_tag_name`

接受一個用於包裹附件的 HTML 標籤的字串。預設為 `"action-text-attachment"`。

#### `config.action_text.sanitizer_vendor`

通過將 `ActionText::ContentHelper.sanitizer` 設置為從供應商的 `.safe_list_sanitizer` 方法返回的類的實例，配置 Action Text 使用的 HTML 消毒器。預設值取決於 `config.load_defaults` 目標版本：

| 開始版本 | 預設值 | 解析標記為 |
|---------|--------|-----------|
| (原始)  | `Rails::HTML4::Sanitizer` | HTML4 |
| 7.1     | `Rails::HTML5::Sanitizer` (參見注意) | HTML5 |

注意：`Rails::HTML5::Sanitizer` 在 JRuby 上不受支援，因此在 JRuby 平台上，Rails 將回退使用 `Rails::HTML4::Sanitizer`。

### 設定資料庫

幾乎每個 Rails 應用程式都會與資料庫互動。您可以通過設置環境變數 `ENV['DATABASE_URL']` 或使用名為 `config/database.yml` 的配置文件來連接到資料庫。

使用 `config/database.yml` 文件，您可以指定訪問資料庫所需的所有資訊：

```yaml
development:
  adapter: postgresql
  database: blog_development
  pool: 5
```

這將使用 `postgresql` 适配器連接到名為 `blog_development` 的資料庫。同樣的資訊可以存儲在 URL 中，並通過環境變數提供，如下所示：

```ruby
ENV['DATABASE_URL'] # => "postgresql://localhost/blog_development?pool=5"
```

`config/database.yml` 文件包含了三個不同環境的部分，Rails 可以默認運行在這些環境中：

* `development` 環境用於在您手動與應用程式進行交互時，在您的開發/本地計算機上使用。
* `test` 環境用於運行自動化測試。
* `production` 環境用於部署應用程式供全世界使用。

如果您希望，您可以在 `config/database.yml` 內手動指定 URL：

```yaml
development:
  url: postgresql://localhost/blog_development?pool=5
```

`config/database.yml` 文件可以包含 ERB 標籤 `<%= %>`。標籤內的任何內容都將被評估為 Ruby 代碼。您可以使用這個功能從環境變數中提取數據，或者執行計算以生成所需的連接資訊。

提示：您不必手動更新資料庫配置。如果查看應用程式生成器的選項，您將看到其中一個選項名為 `--database`。此選項允許您從最常用的關聯式資料庫列表中選擇一個适配器。您甚至可以重複運行生成器：`cd .. && rails new blog --database=mysql`。當您確認覆蓋 `config/database.yml` 文件時，您的應用程式將配置為使用 MySQL 而不是 SQLite。下面是常見的資料庫連接的詳細示例。
### 連線偏好設定

由於有兩種配置連線的方式（使用 `config/database.yml` 或使用環境變數），了解它們如何互動是很重要的。

如果 `config/database.yml` 檔案是空的，但 `ENV['DATABASE_URL']` 是存在的，那麼 Rails 將透過環境變數連線到資料庫：

```bash
$ cat config/database.yml

$ echo $DATABASE_URL
postgresql://localhost/my_database
```

如果有 `config/database.yml`，但沒有 `ENV['DATABASE_URL']`，則將使用該檔案來連線到資料庫：

```bash
$ cat config/database.yml
development:
  adapter: postgresql
  database: my_database
  host: localhost

$ echo $DATABASE_URL
```

如果同時設定了 `config/database.yml` 和 `ENV['DATABASE_URL']`，則 Rails 會將配置合併在一起。為了更好地理解這一點，我們必須看一些例子。

當提供了重複的連線資訊時，環境變數將優先使用：

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

這裡的 adapter、host 和 database 與 `ENV['DATABASE_URL']` 中的資訊匹配。

如果提供了非重複的資訊，則會獲得所有唯一的值，但在任何衝突的情況下，環境變數仍然優先使用。

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

由於 pool 不在提供的 `ENV['DATABASE_URL']` 連線資訊中，所以它的資訊被合併進來。由於 adapter 是重複的，`ENV['DATABASE_URL']` 的連線資訊勝出。

唯一明確不使用 `ENV['DATABASE_URL']` 中的連線資訊的方法是使用 `"url"` 子鍵指定明確的 URL 連線：

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

這裡忽略了 `ENV['DATABASE_URL']` 中的連線資訊，請注意不同的 adapter 和 database 名稱。

由於可以在 `config/database.yml` 中嵌入 ERB，最佳實踐是明確顯示您正在使用 `ENV['DATABASE_URL']` 來連線到資料庫。這在生產環境中特別有用，因為您不應該將像資料庫密碼這樣的機密信息提交到源代碼控制（如 Git）中。

```bash
$ cat config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

現在行為是清晰的，我們只使用 `ENV['DATABASE_URL']` 中的連線資訊。

#### 配置 SQLite3 資料庫

Rails 內建支援 [SQLite3](http://www.sqlite.org)，它是一個輕量級的無伺服器資料庫應用程式。在繁忙的生產環境中，SQLite 可能會超載，但在開發和測試中表現良好。Rails 在創建新專案時默認使用 SQLite 資料庫，但您隨時可以更改它。

這是預設配置檔案 (`config/database.yml`) 中開發環境的連線資訊部分：

```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

注意：Rails 默認使用 SQLite3 資料庫進行資料存儲，因為它是一個零配置的資料庫，可以直接使用。Rails 還支援 MySQL（包括 MariaDB）和 PostgreSQL，並且有許多資料庫系統的插件。如果您在生產環境中使用資料庫，Rails 很可能有適配器可用。
#### 配置 MySQL 或 MariaDB 数据库

如果您选择使用 MySQL 或 MariaDB 而不是默认的 SQLite3 数据库，您的 `config/database.yml` 文件将会有所不同。以下是开发环境的配置示例：

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

如果您的开发数据库使用 root 用户且密码为空，那么这个配置应该适用于您。否则，请根据实际情况在 `development` 部分更改用户名和密码。

注意：如果您的 MySQL 版本是 5.5 或 5.6，并且想要默认使用 `utf8mb4` 字符集，请通过启用 `innodb_large_prefix` 系统变量来配置您的 MySQL 服务器以支持更长的键前缀。

默认情况下，MySQL 上启用了 Advisory Locks，并用于使数据库迁移并发安全。您可以通过将 `advisory_locks` 设置为 `false` 来禁用 Advisory Locks：

```yaml
production:
  adapter: mysql2
  advisory_locks: false
```

#### 配置 PostgreSQL 数据库

如果您选择使用 PostgreSQL，您的 `config/database.yml` 文件将会被自定义以使用 PostgreSQL 数据库：

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: blog_development
  pool: 5
```

默认情况下，Active Record 使用诸如预编译语句和 Advisory Locks 等数据库特性。如果您正在使用外部连接池器（如 PgBouncer），您可能需要禁用这些特性：

```yaml
production:
  adapter: postgresql
  prepared_statements: false
  advisory_locks: false
```

如果启用，Active Record 默认情况下会为每个数据库连接创建最多 `1000` 个预编译语句。要修改此行为，您可以将 `statement_limit` 设置为其他值：

```yaml
production:
  adapter: postgresql
  statement_limit: 200
```

使用的预编译语句越多，您的数据库将需要更多的内存。如果您的 PostgreSQL 数据库达到了内存限制，请尝试降低 `statement_limit` 或禁用预编译语句。

#### 配置 JRuby 平台下的 SQLite3 数据库

如果您选择使用 SQLite3 并且正在使用 JRuby，您的 `config/database.yml` 文件将会有所不同。以下是开发环境的配置示例：

```yaml
development:
  adapter: jdbcsqlite3
  database: storage/development.sqlite3
```

#### 配置 JRuby 平台下的 MySQL 或 MariaDB 数据库

如果您选择使用 MySQL 或 MariaDB 并且正在使用 JRuby，您的 `config/database.yml` 文件将会有所不同。以下是开发环境的配置示例：

```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```

#### 配置 JRuby 平台下的 PostgreSQL 数据库

如果您选择使用 PostgreSQL 并且正在使用 JRuby，您的 `config/database.yml` 文件将会有所不同。以下是开发环境的配置示例：

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

请根据实际情况在 `development` 部分更改用户名和密码。

#### 配置元数据存储

默认情况下，Rails 会将有关您的 Rails 环境和模式的信息存储在名为 `ar_internal_metadata` 的内部表中。

要在每个连接中关闭此功能，请在数据库配置中设置 `use_metadata_table`。这在使用共享数据库和/或无法创建表的数据库用户时非常有用。

```yaml
development:
  adapter: postgresql
  use_metadata_table: false
```

#### 配置重试行为

默认情况下，如果出现问题，Rails 会自动重新连接到数据库服务器并重试某些查询。只有安全可重试（幂等）的查询才会被重试。您可以通过数据库配置中的 `connection_retries` 指定重试次数，或者将该值设置为 0 来禁用重试。默认的重试次数是 1。
```yaml
development:
  adapter: mysql2
  connection_retries: 3
```

數據庫配置還允許配置`retry_deadline`。如果配置了`retry_deadline`，則在首次嘗試查詢時，如果指定的時間已經過去，則不會重試本來可以重試的查詢。例如，`retry_deadline`為5秒，這意味著如果從首次嘗試查詢開始已經過去了5秒，即使該查詢是幂等的且還有`connection_retries`次重試機會，我們也不會重試該查詢。

此值默認為nil，這意味著無論經過多長時間，所有可以重試的查詢都會被重試。此配置的值應以秒為單位指定。

```yaml
development:
  adapter: mysql2
  retry_deadline: 5 # 在5秒後停止重試查詢
```

#### 配置查詢緩存

默認情況下，Rails會自動緩存查詢返回的結果集。如果在同一個請求或作業中再次遇到相同的查詢，則會使用緩存的結果集，而不是再次對數據庫運行該查詢。

查詢緩存存儲在內存中，為了避免使用過多內存，當達到閾值時，它會自動清除最近最少使用的查詢。默認情況下，閾值為`100`，但可以在`database.yml`中進行配置。

```yaml
development:
  adapter: mysql2
  query_cache: 200
```

要完全禁用查詢緩存，可以將其設置為`false`

```yaml
development:
  adapter: mysql2
  query_cache: false
```

### 創建Rails環境

默認情況下，Rails提供了三個環境："development"、"test"和"production"。雖然這些對大多數用例已經足夠，但在某些情況下，您可能需要更多的環境。

想像一下，您有一個與生產環境鏡像的服務器，但僅用於測試。這樣的服務器通常被稱為"staging server"。要為此服務器定義一個名為"staging"的環境，只需創建一個名為`config/environments/staging.rb`的文件。由於這是一個類似生產環境的環境，您可以將`config/environments/production.rb`的內容複製為起點，然後進行必要的更改。還可以像這樣要求和擴展其他環境配置：

```ruby
# config/environments/staging.rb
require_relative "production"

Rails.application.configure do
  # Staging overrides
end
```

該環境與默認環境沒有區別，可以使用`bin/rails server -e staging`啟動服務器，使用`bin/rails console -e staging`啟動控制台，`Rails.env.staging?`也可以正常工作。

### 部署到子目錄（相對URL根目錄）

默認情況下，Rails預期應用程序在根目錄（例如`/`）運行。本節將解釋如何在目錄內運行應用程序。

假設我們想要將應用程序部署到"/app1"。Rails需要知道此目錄以生成適當的路由：

```ruby
config.relative_url_root = "/app1"
```

或者您可以設置`RAILS_RELATIVE_URL_ROOT`環境變量。

Rails現在在生成鏈接時會在前面加上"/app1"。

#### 使用Passenger

Passenger使在子目錄中運行應用程序變得容易。您可以在[Passenger手冊](https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/#deploying-an-app-to-a-sub-uri-or-subdirectory)中找到相關的配置。

#### 使用反向代理

使用反向代理部署應用程序相對於傳統部署具有明顯的優勢。它們允許您通過將應用程序所需的組件分層來更好地控制服務器。
許多現代的網頁伺服器可以用作代理伺服器，用於平衡快取伺服器或應用程式伺服器等第三方元素。

其中一個您可以使用的應用程式伺服器是 [Unicorn](https://bogomips.org/unicorn/)，可在反向代理後運行。

在這種情況下，您需要配置代理伺服器（NGINX、Apache 等）以接受來自應用程式伺服器（Unicorn）的連線。預設情況下，Unicorn 將在端口 8080 上監聽 TCP 連線，但您可以更改端口或配置為使用 sockets。

您可以在 [Unicorn 自述檔](https://bogomips.org/unicorn/README.html) 中找到更多資訊，並了解其背後的 [哲學](https://bogomips.org/unicorn/PHILOSOPHY.html)。

配置完應用程式伺服器後，您必須通過適當配置您的網頁伺服器來代理請求。例如，您的 NGINX 配置可能包括：

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

  # 其他一些配置
}
```

請務必閱讀 [NGINX 文件](https://nginx.org/en/docs/) 以獲取最新資訊。


Rails 環境設定
--------------------------

Rails 的某些部分也可以通過提供環境變數來進行外部配置。各個部分的 Rails 都會識別以下環境變數：

* `ENV["RAILS_ENV"]` 定義了 Rails 將在其中運行的 Rails 環境（production、development、test 等）。

* `ENV["RAILS_RELATIVE_URL_ROOT"]` 用於路由代碼，在您將應用程式部署到子目錄時識別 URL。

* `ENV["RAILS_CACHE_ID"]` 和 `ENV["RAILS_APP_VERSION"]` 用於在 Rails 的快取程式碼中生成擴展快取鍵。這允許您從同一個應用程式中擁有多個獨立的快取。


使用初始化檔案
-----------------------

在加載應用程式中的框架和任何 gem 之後，Rails 會開始加載初始化檔案。初始化檔案是指存儲在應用程式的 `config/initializers` 目錄下的任何 Ruby 檔案。您可以使用初始化檔案來保存在所有框架和 gem 加載之後應進行的配置設定，例如用於這些部分的設定選項。

`config/initializers` 目錄中的檔案（以及 `config/initializers` 的任何子目錄）會按順序進行排序並逐個加載，作為 `load_config_initializers` 初始化檔案的一部分。

如果初始化檔案中的程式碼依賴於另一個初始化檔案中的程式碼，則可以將它們合併為單個初始化檔案。這樣可以使依賴關係更加明確，並有助於在應用程式中展示新的概念。Rails 也支援初始化檔案名稱的編號，但這可能導致檔案名稱的變動。不建議使用 `require` 明確加載初始化檔案，因為這將導致初始化檔案被加載兩次。

注意：無法保證您的初始化檔案將在所有 gem 初始化檔案之後運行，因此任何依賴於特定 gem 已初始化的初始化程式碼應放在 `config.after_initialize` 區塊中。

初始化事件
---------------------

Rails 有 5 個初始化事件可以進行鉤子處理（按照運行順序列出）：

* `before_configuration`：在應用程式常數繼承自 `Rails::Application` 之後立即運行。在此之前會評估 `config` 調用。

* `before_initialize`：在 Rails 初始化過程的開始附近，與 `:bootstrap_hook` 初始化檔案一起直接運行。
* `to_prepare`: 在所有Railties（包括應用程序本身）的初始化器運行之後運行，但在急切加載和中間件堆棧構建之前運行。在`development`模式下，每次代碼重新加載時都會運行，但在`production`和`test`模式下只運行一次（在啟動時）。

* `before_eager_load`: 在急切加載之前運行，這是`production`環境的默認行為，而不是`development`環境。

* `after_initialize`: 在應用程序初始化之後直接運行，在運行`config/initializers`中的應用程序初始化器之後運行。

要為這些鉤子定義事件，請在`Rails::Application`、`Rails::Railtie`或`Rails::Engine`子類中使用塊語法：

```ruby
module YourApp
  class Application < Rails::Application
    config.before_initialize do
      # initialization code goes here
    end
  end
end
```

或者，您也可以通過`Rails.application`對象上的`config`方法來完成：

```ruby
Rails.application.config.before_initialize do
  # initialization code goes here
end
```

警告：在調用`after_initialize`塊的時候，應用程序的某些部分，尤其是路由，尚未設置。

### `Rails::Railtie#initializer`

Rails有幾個在啟動時運行的初始化器，它們都是使用`Rails::Railtie`的`initializer`方法定義的。以下是Action Controller中的`set_helpers_path`初始化器的示例：

```ruby
initializer "action_controller.set_helpers_path" do |app|
  ActionController::Helpers.helpers_path = app.helpers_paths
end
```

`initializer`方法接受三個參數，第一個是初始化器的名稱，第二個是選項哈希（此處未顯示），第三個是塊。選項哈希中的`:before`鍵可以指定此新初始化器在哪個初始化器之前運行，`:after`鍵將指定在哪個初始化器之後運行此初始化器。

使用`initializer`方法定義的初始化器將按照它們定義的順序運行，但使用`：before`或`：after`方法的初始化器除外。

警告：您可以將初始化器放在鏈中的任何其他初始化器之前或之後，只要它是合理的。假設您有4個名為“one”到“four”的初始化器（按照該順序定義），並且您將“four”定義為在“two”之前但在“three”之後運行，這是不合理的，Rails將無法確定初始化器的順序。

`initializer`方法的塊參數是應用程序本身的實例，因此我們可以使用示例中的`config`方法來訪問其上的配置。

由於`Rails::Application`（間接地）繼承自`Rails::Railtie`，因此可以在`config/application.rb`中使用`initializer`方法為應用程序定義初始化器。

### 初始化器

以下是按照定義的順序（除非另有說明）在Rails中找到的所有初始化器的全面列表。

* `load_environment_hook`：作為佔位符，以便可以定義`：load_environment_config`在其之前運行。

* `load_active_support`：需要`active_support/dependencies`，它設置了Active Support的基礎。如果`config.active_support.bare`不為真，則可選地需要`active_support/all`，這是默認值。

* `initialize_logger`：為應用程序初始化日誌記錄器（一個`ActiveSupport::Logger`對象），並使其在`Rails.logger`中可訪問，前提是在此點之前沒有插入定義`Rails.logger`的初始化器。
* `initialize_cache`: 如果尚未設置`Rails.cache`，則通過引用`config.cache_store`中的值來初始化緩存，並將結果存儲為`Rails.cache`。如果此對象響應`middleware`方法，則將其中間件插入到中間件堆棧中的`Rack::Runtime`之前。

* `set_clear_dependencies_hook`: 此初始化程序僅在`config.enable_reloading`設置為`true`時運行，使用`ActionDispatch::Callbacks.after`來從對象空間中刪除在請求期間被引用的常量，以便在下一個請求期間重新加載它們。

* `bootstrap_hook`: 運行所有配置的`before_initialize`塊。

* `i18n.callbacks`: 在開發環境中，設置一個`to_prepare`回調，如果任何區域設置自上次請求以來發生了變化，則調用`I18n.reload!`。在生產環境中，此回調僅在第一個請求時運行。

* `active_support.deprecation_behavior`: 根據[`config.active_support.report_deprecations`](#config-active-support-report-deprecations)、[`config.active_support.deprecation`](#config-active-support-deprecation)、[`config.active_support.disallowed_deprecation`](#config-active-support-disallowed-deprecation)和[`config.active_support.disallowed_deprecation_warnings`](#config-active-support-disallowed-deprecation-warnings)為[`Rails.application.deprecators`][]設置廢棄報告行為。

* `active_support.initialize_time_zone`: 根據`config.time_zone`設置，將應用程序的默認時區設置為"UTC"。

* `active_support.initialize_beginning_of_week`: 根據`config.beginning_of_week`設置，將應用程序的默認一周的開始設置為`:monday`。

* `active_support.set_configs`: 通過將方法名作為setter使用`config.active_support`中的設置來設置Active Support，並通過傳遞值來完成設置。

* `action_dispatch.configure`: 將`ActionDispatch::Http::URL.tld_length`配置為`config.action_dispatch.tld_length`的值。

* `action_view.set_configs`: 通過將方法名作為setter使用`config.action_view`中的設置來設置Action View，並通過傳遞值來完成設置。

* `action_controller.assets_config`: 如果未明確配置，則將`config.action_controller.assets_dir`初始化為應用程序的公共目錄。

* `action_controller.set_helpers_path`: 將Action Controller的`helpers_path`設置為應用程序的`helpers_path`。

* `action_controller.parameters_config`: 為`ActionController::Parameters`配置強參數選項。

* `action_controller.set_configs`: 通過將方法名作為setter使用`config.action_controller`中的設置來設置Action Controller，並通過傳遞值來完成設置。

* `action_controller.compile_config_methods`: 初始化指定的配置設置的方法，以便更快地訪問它們。

* `active_record.initialize_timezone`: 將`ActiveRecord::Base.time_zone_aware_attributes`設置為`true`，並將`ActiveRecord::Base.default_timezone`設置為UTC。從數據庫讀取屬性時，它們將轉換為`Time.zone`指定的時區。

* `active_record.logger`: 將`ActiveRecord::Base.logger`（如果尚未設置）設置為`Rails.logger`。

* `active_record.migration_error`: 配置中間件以檢查待處理的遷移。

* `active_record.check_schema_cache_dump`: 如果配置且可用，則加載模式緩存轉儲。

* `active_record.warn_on_records_fetched_greater_than`: 在查詢返回大量記錄時啟用警告。

* `active_record.set_configs`: 通過將方法名作為setter使用`config.active_record`中的設置來設置Active Record，並通過傳遞值來完成設置。

* `active_record.initialize_database`: 從`config/database.yml`中（默認情況下）加載數據庫配置並為當前環境建立連接。

* `active_record.log_runtime`: 包括`ActiveRecord::Railties::ControllerRuntime`和`ActiveRecord::Railties::JobRuntime`，它們負責將Active Record調用所花費的時間報告給日誌記錄器。

* `active_record.set_reloader_hooks`: 如果`config.enable_reloading`設置為`true`，則重置所有可重新加載的數據庫連接。

* `active_record.add_watchable_files`: 將`schema.rb`和`structure.sql`文件添加到可監視的文件列表中。

* `active_job.logger`: 將`ActiveJob::Base.logger`（如果尚未設置）設置為`Rails.logger`。
* `active_job.set_configs`: 透過將方法名稱作為設置器傳遞給 `ActiveJob::Base`，並通過 `config.active_job` 中的設置來設置 Active Job。

* `action_mailer.logger`: 如果尚未設置，則將 `ActionMailer::Base.logger` 設置為 `Rails.logger`。

* `action_mailer.set_configs`: 透過將方法名稱作為設置器傳遞給 `ActionMailer::Base`，並通過 `config.action_mailer` 中的設置來設置 Action Mailer。

* `action_mailer.compile_config_methods`: 初始化指定的配置設置方法，以便更快地訪問它們。

* `set_load_path`: 此初始化程序在 `bootstrap_hook` 之前運行。將 `config.load_paths` 中指定的路徑和所有自動加載路徑添加到 `$LOAD_PATH`。

* `set_autoload_paths`: 此初始化程序在 `bootstrap_hook` 之前運行。將 `app` 的所有子目錄和 `config.autoload_paths`、`config.eager_load_paths` 和 `config.autoload_once_paths` 中指定的路徑添加到 `ActiveSupport::Dependencies.autoload_paths`。

* `add_routing_paths`: 加載（默認情況下）應用程序、railties（包括引擎）中的所有 `config/routes.rb` 文件，並為應用程序設置路由。

* `add_locales`: 將 `config/locales` 中的文件（來自應用程序、railties 和引擎）添加到 `I18n.load_path`，從而使這些文件中的翻譯可用。

* `add_view_paths`: 將應用程序、railties 和引擎中的 `app/views` 目錄添加到應用程序的視圖文件查找路徑。

* `add_mailer_preview_paths`: 將應用程序、railties 和引擎中的 `test/mailers/previews` 目錄添加到應用程序的郵件預覽文件查找路徑。

* `load_environment_config`: 此初始化程序在 `load_environment_hook` 之前運行。加載當前環境的 `config/environments` 文件。

* `prepend_helpers_path`: 將應用程序、railties 和引擎中的 `app/helpers` 目錄添加到應用程序的幫助程序查找路徑。

* `load_config_initializers`: 加載應用程序、railties 和引擎中的 `config/initializers` 中的所有 Ruby 文件。此目錄中的文件可用於保存在所有框架加載之後應進行的配置設置。

* `engines_blank_point`: 提供一個初始化點，用於在引擎加載之前執行任何操作。在此點之後，將運行所有 railtie 和引擎的初始化程序。

* `add_generator_templates`: 在應用程序、railties 和引擎中查找 `lib/templates` 中的生成器模板，並將其添加到 `config.generators.templates` 設置中，從而使這些模板可供所有生成器引用。

* `ensure_autoload_once_paths_as_subset`: 確保 `config.autoload_once_paths` 只包含 `config.autoload_paths` 中的路徑。如果包含了額外的路徑，則會引發異常。

* `add_to_prepare_blocks`: 將應用程序、railties 或引擎中每個 `config.to_prepare` 調用的塊添加到 Action Dispatch 的 `to_prepare` 回調中，這些回調將在開發中的每個請求之前或在生產中的第一個請求之前運行。

* `add_builtin_route`: 如果應用程序在開發環境下運行，則將 `rails/info/properties` 的路由附加到應用程序的路由中。此路由在默認的 Rails 應用程序的 `public/index.html` 中提供詳細信息，例如 Rails 和 Ruby 版本。

* `build_middleware_stack`: 構建應用程序的中間件堆棧，返回一個具有 `call` 方法的對象，該方法接受一個 Rack 環境對象作為請求。

* `eager_load!`: 如果 `config.eager_load` 為 `true`，則運行 `config.before_eager_load` 鉤子，然後調用 `eager_load!`，該方法將加載所有 `config.eager_load_namespaces`。

* `finisher_hook`: 提供一個鉤子，用於在應用程序的初始化過程完成後執行，以及運行應用程序、railties 和引擎的所有 `config.after_initialize` 塊。
* `set_routes_reloader_hook`: 配置Action Dispatch使用`ActiveSupport::Callbacks.to_run`重新加载路由文件。

* `disable_dependency_loading`: 如果`config.eager_load`设置为`true`，禁用自动依赖加载。

数据库连接池
----------------

Active Record数据库连接由`ActiveRecord::ConnectionAdapters::ConnectionPool`管理，它确保连接池同步访问有限数量的数据库连接。此限制默认为5，并可以在`database.yml`中进行配置。

```ruby
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

由于连接池默认由Active Record处理，所有应用服务器（Thin，Puma，Unicorn等）应该具有相同的行为。数据库连接池最初为空。随着对连接的需求增加，它会创建连接，直到达到连接池限制。

任何一个请求在首次需要访问数据库时都会检出一个连接。在请求结束时，它会将连接检入。这意味着额外的连接槽将再次可用于队列中的下一个请求。

如果尝试使用的连接数超过可用连接数，Active Record将阻塞您并等待从连接池获取连接。如果无法获取连接，将抛出类似于下面给出的超时错误。

```ruby
ActiveRecord::ConnectionTimeoutError - 在5.000秒内无法获取数据库连接（等待了5.000秒）
```

如果出现上述错误，您可能需要通过增加`database.yml`中的`pool`选项来增加连接池的大小。

注意：如果在多线程环境中运行，可能存在多个线程同时访问多个连接的情况。因此，根据当前请求负载的不同，可能会有多个线程争夺有限数量的连接。

自定义配置
--------------------

您可以通过Rails配置对象配置自己的代码，可以在`config.x`命名空间或直接在`config`下进行自定义配置。这两者之间的关键区别是，如果您定义了嵌套配置（例如`config.x.nested.hi`），则应使用`config.x`，而对于单层配置（例如`config.hello`），则使用`config`。

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

`Rails::Application.config_for`支持`shared`配置以分组常见配置。共享配置将合并到环境配置中。

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

有时，您可能希望阻止应用程序的某些页面在Google、Bing、Yahoo或Duck Duck Go等搜索站点上可见。索引这些站点的机器人将首先分析`http://your-site.com/robots.txt`文件，以了解它被允许索引的页面。
Rails會在`/public`資料夾內為您建立這個檔案。預設情況下，它允許搜尋引擎索引應用程式的所有頁面。如果您想要封鎖應用程式的所有頁面的索引，請使用以下內容：

```
User-agent: *
Disallow: /
```

如果只想封鎖特定頁面，需要使用更複雜的語法。請參考[官方文件](https://www.robotstxt.org/robotstxt.html)。

事件驅動的檔案系統監視器
---------------------------

如果載入了[listen gem](https://github.com/guard/listen)，Rails會使用事件驅動的檔案系統監視器在重新載入時偵測變更：

```ruby
group :development do
  gem 'listen', '~> 3.3'
end
```

否則，在每個請求中，Rails會遍歷應用程式樹來檢查是否有任何變更。

在Linux和macOS上不需要額外的gem，但在[BSD上需要一些](https://github.com/guard/listen#on-bsd)，並且在[Windows上需要一些](https://github.com/guard/listen#on-windows)。

請注意，[某些設定不受支援](https://github.com/guard/listen#issues--limitations)。
[`config.load_defaults`]: https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults
[`ActiveSupport::ParameterFilter.precompile_filters`]: https://api.rubyonrails.org/classes/ActiveSupport/ParameterFilter.html#method-c-precompile_filters
[ActiveModel::Error#full_message]: https://api.rubyonrails.org/classes/ActiveModel/Error.html#method-i-full_message
[`ActiveSupport::MessageEncryptor`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html
[`ActiveSupport::MessageVerifier`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html
[`message_serializer_fallback.active_support`]: active_support_instrumentation.html#message-serializer-fallback-active-support
[`Rails.application.deprecators`]: https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators
