**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bba7dd6e311e7abd59e434f12dbebd0e
레일즈 애플리케이션 구성
==============================

이 가이드는 레일즈 애플리케이션에서 사용할 수 있는 구성 및 초기화 기능을 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* 레일즈 애플리케이션의 동작을 조정하는 방법.
* 애플리케이션 시작 시 실행될 추가 코드를 추가하는 방법.

--------------------------------------------------------------------------------

초기화 코드의 위치
---------------------------------

레일즈는 초기화 코드를 넣을 수 있는 네 가지 표준 위치를 제공합니다:

* `config/application.rb`
* 환경별 구성 파일
* 초기화 파일
* 초기화 이후 파일

레일즈 이전에 코드 실행하기
-------------------------

애플리케이션이 레일즈 자체가 로드되기 전에 코드를 실행해야 하는 경우, `config/application.rb`의 `require "rails/all"` 호출 위에 해당 코드를 넣으십시오.

레일즈 구성 요소 구성하기
----------------------------

일반적으로 레일즈 구성 작업은 레일즈의 구성 요소와 레일즈 자체를 구성하는 작업을 의미합니다. `config/application.rb` 구성 파일과 환경별 구성 파일(예: `config/environments/production.rb`)을 사용하여 모든 구성 요소에 전달할 다양한 설정을 지정할 수 있습니다.

예를 들어, 다음 설정을 `config/application.rb` 파일에 추가할 수 있습니다:

```ruby
config.time_zone = 'Central Time (US & Canada)'
```

이것은 레일즈 자체의 설정입니다. 개별 레일즈 구성 요소에 설정을 전달하려면, `config/application.rb`의 동일한 `config` 객체를 사용하여 설정할 수 있습니다:

```ruby
config.active_record.schema_format = :ruby
```

레일즈는 해당 설정을 사용하여 Active Record를 구성합니다.

경고: 관련된 클래스에 직접 호출하는 대신 공개 구성 메서드를 사용하십시오. 예를 들어 `ActionMailer::Base.options` 대신 `Rails.application.config.action_mailer.options`를 사용하십시오.

참고: 클래스에 직접 구성을 적용해야 하는 경우, 초기화 파일에서 [지연 로드 후크](https://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html)를 사용하여 초기화가 완료되기 전에 클래스를 자동로드하지 않도록 해야 합니다. 애플리케이션이 다시로드될 때 초기화 중에 자동로드를 안전하게 반복할 수 없기 때문에 이 작업은 실패합니다.

### 버전별 기본값

[`config.load_defaults`]는 대상 버전 및 해당 버전 이전의 모든 버전에 대한 기본 구성 값을 로드합니다. 예를 들어, `config.load_defaults 6.1`은 버전 6.1까지의 모든 버전에 대한 기본값을 로드합니다.


아래는 각 대상 버전에 연결된 기본값입니다. 충돌하는 값의 경우, 최신 버전이 이전 버전보다 우선합니다.

#### 대상 버전 7.1의 기본값

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

#### 대상 버전 7.0의 기본값

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
#### Target Version 6.1의 기본값

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

#### Target Version 6.0의 기본값

- [`config.action_dispatch.use_cookies_with_metadata`](#config-action-dispatch-use-cookies-with-metadata): `true`
- [`config.action_mailer.delivery_job`](#config-action-mailer-delivery-job): `"ActionMailer::MailDeliveryJob"`
- [`config.action_view.default_enforce_utf8`](#config-action-view-default-enforce-utf8): `false`
- [`config.active_record.collection_cache_versioning`](#config-active-record-collection-cache-versioning): `true`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `:active_storage_analysis`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `:active_storage_purge`

#### Target Version 5.2의 기본값

- [`config.action_controller.default_protect_from_forgery`](#config-action-controller-default-protect-from-forgery): `true`
- [`config.action_dispatch.use_authenticated_cookie_encryption`](#config-action-dispatch-use-authenticated-cookie-encryption): `true`
- [`config.action_view.form_with_generates_ids`](#config-action-view-form-with-generates-ids): `true`
- [`config.active_record.cache_versioning`](#config-active-record-cache-versioning): `true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA1`
- [`config.active_support.use_authenticated_message_encryption`](#config-active-support-use-authenticated-message-encryption): `true`

#### Target Version 5.1의 기본값

- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `true`
- [`config.assets.unknown_asset_fallback`](#config-assets-unknown-asset-fallback): `false`

#### Target Version 5.0의 기본값

- [`ActiveSupport.to_time_preserves_timezone`](#activesupport-to-time-preserves-timezone): `true`
- [`config.action_controller.forgery_protection_origin_check`](#config-action-controller-forgery-protection-origin-check): `true`
- [`config.action_controller.per_form_csrf_tokens`](#config-action-controller-per-form-csrf-tokens): `true`
- [`config.active_record.belongs_to_required_by_default`](#config-active-record-belongs-to-required-by-default): `true`
- [`config.ssl_options`](#config-ssl-options): `{ hsts: { subdomains: true } }`

### Rails 일반 구성

다음 구성 메서드는 `Rails::Engine` 또는 `Rails::Application`의 하위 클래스와 같은 `Rails::Railtie` 객체에서 호출해야 합니다.

#### `config.add_autoload_paths_to_load_path`

autoload 경로를 `$LOAD_PATH`에 추가해야 하는지 여부를 나타냅니다. `:zeitwerk` 모드에서는 `config/application.rb`에서 초기에 `false`로 설정하는 것이 권장됩니다. Zeitwerk은 내부적으로 절대 경로를 사용하며, `:zeitwerk` 모드에서 실행되는 애플리케이션은 `require_dependency`가 필요하지 않으므로 모델, 컨트롤러, 작업 등이 `$LOAD_PATH`에 있을 필요가 없습니다. 이 값을 `false`로 설정하면 상대 경로로 `require` 호출을 해결할 때 루비가 이러한 디렉토리를 확인하는 시간과 Bootsnap 작업 및 RAM을 절약할 수 있습니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| ---- | ------ |
| (원래) | `true` |
| 7.1 | `false` |

`lib` 디렉토리는 이 플래그에 영향을 받지 않으며 항상 `$LOAD_PATH`에 추가됩니다.

#### `config.after_initialize`

응용 프로그램 초기화가 완료된 후에 실행될 블록을 가져옵니다. 이는 프레임워크 자체, 엔진 및 `config/initializers`의 모든 초기화기를 초기화하는 것을 포함합니다. 이 블록은 rake 작업에 대해서도 실행됩니다. 다른 초기화기에서 설정한 값을 구성하는 데 유용합니다.

```ruby
config.after_initialize do
  ActionView::Base.sanitized_allowed_tags.delete 'div'
end
```

#### `config.after_routes_loaded`

응용 프로그램 라우트를 로드한 후에 실행될 블록을 가져옵니다. 이 블록은 라우트를 다시로드할 때마다 실행됩니다.

```ruby
config.after_routes_loaded do
  # Rails.application.routes를 사용하여 작업하는 코드
end
```

#### `config.allow_concurrency`

요청을 동시에 처리해야 하는지 여부를 제어합니다. 응용 프로그램 코드가 스레드로부터 안전하지 않은 경우에만 `false`로 설정해야 합니다. 기본값은 `true`입니다.

#### `config.asset_host`

자산의 호스트를 설정합니다. 자산을 호스팅하기 위해 CDN을 사용하거나 다른 도메인 별칭을 사용하여 브라우저의 동시성 제약 조건을 해결하려는 경우 유용합니다. `config.action_controller.asset_host`의 간단한 버전입니다.

#### `config.assume_ssl`

응용 프로그램이 모든 요청이 SSL을 통해 도착하는 것으로 간주하도록 설정합니다. 이는 SSL을 종료하는 로드 밸런서를 통해 프록시하는 경우 유용합니다. 전달된 요청은 응용 프로그램에 대해 HTTPS가 아닌 HTTP로 표시됩니다. 이 미들웨어는 서버가 프록시가 이미 SSL을 종료했고 요청이 실제로 HTTPS임을 가정합니다. 이를 통해 리디렉션 및 쿠키 보안이 HTTPS가 아닌 HTTP를 대상으로 하게 됩니다.
#### `config.autoflush_log`

버퍼링 대신 로그 파일 출력을 즉시 활성화합니다. 기본값은 `true`입니다.

#### `config.autoload_once_paths`

요청마다 초기화되지 않는 상수를 자동으로 로드할 경로의 배열을 받습니다. 기본적으로 `development` 환경에서는 재로딩이 활성화되므로 관련이 있습니다. 그렇지 않으면 모든 자동로딩은 한 번만 발생합니다. 이 배열의 모든 요소는 `autoload_paths`에도 포함되어야 합니다. 기본값은 빈 배열입니다.

#### `config.autoload_paths`

상수를 자동으로 로드할 경로의 배열을 받습니다. 기본값은 빈 배열입니다. [Rails 6](upgrading_ruby_on_rails.html#autoloading)부터는 이를 조정하는 것이 권장되지 않습니다. [자동로딩 및 상수 재로딩](autoloading_and_reloading_constants.html#autoload-paths)을 참조하세요.

#### `config.autoload_lib(ignore:)`

이 메서드는 `lib`를 `config.autoload_paths`와 `config.eager_load_paths`에 추가합니다.

일반적으로 `lib` 디렉토리에는 자동로딩되거나 이저로딩되지 않아야 하는 하위 디렉토리가 있습니다. `ignore` 키워드 인수에 `lib`에 상대적인 이름을 전달하세요. 예를 들어,

```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

자세한 내용은 [자동로딩 가이드](autoloading_and_reloading_constants.html)를 참조하세요.

#### `config.autoload_lib_once(ignore:)`

`config.autoload_lib_once` 메서드는 `config.autoload_lib`와 유사하지만 `lib`를 `config.autoload_once_paths`에 추가합니다.

`config.autoload_lib_once`를 호출하면 `lib`의 클래스와 모듈이 애플리케이션 초기화기에서도 자동로딩되지만 다시 로딩되지 않습니다.

#### `config.beginning_of_week`

애플리케이션의 기본 주의 시작을 설정합니다. 유효한 요일을 심볼로 받습니다(예: `:monday`).

#### `config.cache_classes`

`!config.enable_reloading`과 동일한 설정입니다. 하위 호환성을 위해 지원됩니다.

#### `config.cache_store`

Rails 캐싱에 사용할 캐시 스토어를 구성합니다. 옵션으로는 `:memory_store`, `:file_store`, `:mem_cache_store`, `:null_store`, `:redis_cache_store` 중 하나의 심볼 또는 캐시 API를 구현한 객체가 있습니다. 기본값은 `:file_store`입니다. 각 스토어 구성 옵션에 대해서는 [캐시 스토어](caching_with_rails.html#cache-stores)를 참조하세요.

#### `config.colorize_logging`

로그 정보를 기록할 때 ANSI 색상 코드를 사용할지 여부를 지정합니다. 기본값은 `true`입니다.

#### `config.consider_all_requests_local`

플래그입니다. `true`이면 모든 오류가 HTTP 응답에 자세한 디버깅 정보를 덤프하고 `/rails/info/properties`의 `Rails::Info` 컨트롤러에서 애플리케이션 런타임 컨텍스트를 표시합니다. 개발 및 테스트 환경에서는 기본적으로 `true`이고 프로덕션 환경에서는 `false`입니다. 더 세밀한 제어를 위해 이 값을 `false`로 설정하고 컨트롤러에서 `show_detailed_exceptions?`를 구현하여 어떤 요청이 오류에 대한 디버깅 정보를 제공해야 하는지 지정할 수 있습니다.

#### `config.console`

`bin/rails console`를 실행할 때 콘솔로 사용할 클래스를 설정할 수 있습니다. `console` 블록에서 실행하는 것이 가장 좋습니다:

```ruby
console do
  # 이 블록은 콘솔을 실행할 때만 호출되므로
  # 여기서 안전하게 pry를 요구할 수 있습니다.
  require "pry"
  config.console = Pry
end
```

#### `config.content_security_policy_nonce_directives`

보안 가이드의 [Nonce 추가](security.html#adding-a-nonce)를 참조하세요.

#### `config.content_security_policy_nonce_generator`

보안 가이드의 [Nonce 추가](security.html#adding-a-nonce)를 참조하세요.

#### `config.content_security_policy_report_only`

보안 가이드의 [위반 보고](security.html#reporting-violations)를 참조하세요.

#### `config.credentials.content_path`

암호화된 자격 증명 파일의 경로입니다.

기본값은 해당 파일이 존재하는 경우 `config/credentials/#{Rails.env}.yml.enc`이거나 그렇지 않으면 `config/credentials.yml.enc`입니다.

참고: `bin/rails credentials` 명령이 이 값을 인식하려면 `config/application.rb` 또는 `config/environments/#{Rails.env}.rb`에 설정되어야 합니다.

#### `config.credentials.key_path`

암호화된 자격 증명 키 파일의 경로입니다.

기본값은 해당 파일이 존재하는 경우 `config/credentials/#{Rails.env}.key`이거나 그렇지 않으면 `config/master.key`입니다.

참고: `bin/rails credentials` 명령이 이 값을 인식하려면 `config/application.rb` 또는 `config/environments/#{Rails.env}.rb`에 설정되어야 합니다.
#### `config.debug_exception_response_format`

개발 환경에서 오류가 발생할 때 응답에 사용되는 형식을 설정합니다. API 전용 앱의 경우 기본값은 `:api`이고 일반 앱의 경우 기본값은 `:default`입니다.

#### `config.disable_sandbox`

샌드박스 모드에서 콘솔을 시작할 수 있는지 여부를 제어합니다. 이는 데이터베이스 서버가 메모리를 고갈시킬 수 있는 장기간 실행되는 샌드박스 콘솔 세션을 피하는 데 도움이 됩니다. 기본값은 `false`입니다.

#### `config.eager_load`

`true`로 설정되면 등록된 모든 `config.eager_load_namespaces`를 즉시 로드합니다. 이에는 애플리케이션, 엔진, Rails 프레임워크 및 기타 등록된 네임스페이스가 포함됩니다.

#### `config.eager_load_namespaces`

`config.eager_load`가 `true`로 설정된 경우 즉시 로드되는 네임스페이스를 등록합니다. 목록에 있는 모든 네임스페이스는 `eager_load!` 메서드에 응답해야 합니다.

#### `config.eager_load_paths`

`config.eager_load`가 true인 경우 Rails가 부팅 시 즉시 로드할 경로의 배열을 허용합니다. 기본값은 애플리케이션의 `app` 디렉토리의 모든 폴더입니다.

#### `config.enable_reloading`

`config.enable_reloading`이 true인 경우 웹 요청 사이에 애플리케이션 클래스와 모듈이 변경되면 다시로드됩니다. 기본값은 개발 환경에서는 `true`이고 프로덕션 환경에서는 `false`입니다.

`config.reloading_enabled?` 예측자도 정의됩니다.

#### `config.encoding`

응용 프로그램 전체의 인코딩을 설정합니다. 기본값은 UTF-8입니다.

#### `config.exceptions_app`

예외가 발생할 때 `ShowException` 미들웨어에 의해 호출되는 예외 애플리케이션을 설정합니다.
기본값은 `ActionDispatch::PublicExceptions.new(Rails.public_path)`입니다.

예외 애플리케이션은 클라이언트가 잘못된 `Accept` 또는 `Content-Type` 헤더를 보낼 때 발생하는 `ActionDispatch::Http::MimeNegotiation::InvalidType` 오류를 처리해야 합니다.
기본 `ActionDispatch::PublicExceptions` 애플리케이션은 이를 자동으로 처리하며 `Content-Type`을 `text/html`로 설정하고 `406 Not Acceptable` 상태를 반환합니다.
이 오류를 처리하지 않으면 `500 Internal Server Error`가 발생합니다.

예외 애플리케이션으로 `Rails.application.routes` `RouteSet`을 사용하려면 이 특별한 처리가 필요합니다.
다음과 같이 보일 수 있습니다.

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

`config.reload_classes_only_on_change`가 `true`인 경우 파일 시스템에서 파일 업데이트를 감지하는 데 사용되는 클래스입니다. Rails는 `ActiveSupport::FileUpdateChecker` (기본값)와 `ActiveSupport::EventedFileUpdateChecker` (이는 [listen](https://github.com/guard/listen) 젬에 의존합니다)와 함께 제공됩니다. 사용자 정의 클래스는 `ActiveSupport::FileUpdateChecker` API를 준수해야 합니다.

#### `config.filter_parameters`

로그에 표시하지 않으려는 매개변수를 필터링하는 데 사용됩니다.
예를 들어, 비밀번호나 신용 카드 번호와 같은 것들입니다. 또한 Active Record 객체의 `#inspect`를 호출할 때 데이터베이스 열의 민감한 값도 필터링합니다. 기본적으로 Rails는 다음과 같은 필터를 추가하여 비밀번호를 필터링합니다. `config/initializers/filter_parameter_logging.rb`에 다음과 같이 추가합니다.

```ruby
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

매개변수 필터는 정규식을 부분 일치시켜 작동합니다.

#### `config.filter_redirect`

응용 프로그램 로그에서 리디렉션 URL을 필터링하는 데 사용됩니다.

```ruby
Rails.application.config.filter_redirect += ['s3.amazonaws.com', /private-match/]
```

리디렉션 필터는 URL에 문자열이 포함되거나 정규식과 일치하는지 테스트하여 작동합니다.

#### `config.force_ssl`

모든 요청을 HTTPS로 제공하도록 강제하고 URL을 생성할 때 기본 프로토콜로 "https://"를 설정합니다. HTTPS의 강제 적용은 `ActionDispatch::SSL` 미들웨어에 의해 처리되며 `config.ssl_options`를 통해 구성할 수 있습니다.

#### `config.helpers_paths`
보조 경로의 배열을 정의하여 뷰 헬퍼를 로드합니다.

#### `config.host_authorization`

[HostAuthorization 미들웨어](#actiondispatch-hostauthorization)를 구성하기 위한 옵션 해시를 허용합니다.

#### `config.hosts`

`Host` 헤더를 유효성 검사하는 데 사용되는 문자열, 정규식 또는 `IPAddr`의 배열입니다. [HostAuthorization 미들웨어](#actiondispatch-hostauthorization)에서 DNS 리바인딩 공격을 방지하는 데 사용됩니다.

#### `config.javascript_path`

앱의 JavaScript가 `app` 디렉토리와 상대적인 위치를 설정합니다. 기본값은 [webpacker](https://github.com/rails/webpacker)에서 사용하는 `javascript`입니다. 구성된 `javascript_path`는 `autoload_paths`에서 제외됩니다.

#### `config.log_file_size`

개발 및 테스트 환경에서는 기본값으로 `104_857_600`바이트(100 MiB)이며, 다른 모든 환경에서는 무제한입니다.

#### `config.log_formatter`

Rails 로거의 포매터를 정의합니다. 이 옵션은 모든 환경에 대해 기본적으로 `ActiveSupport::Logger::SimpleFormatter`의 인스턴스로 설정됩니다. `config.logger`에 값을 설정하는 경우에는 `ActiveSupport::TaggedLogging` 인스턴스로 래핑되기 전에 로거에 포매터 값을 수동으로 전달해야 합니다. Rails는 이 작업을 대신하지 않습니다.

#### `config.log_level`

Rails 로거의 상세도를 정의합니다. 이 옵션은 기본적으로 모든 환경에 대해 `:debug`로 설정되며, 프로덕션 환경에서는 `:info`로 설정됩니다. 사용 가능한 로그 레벨은 `:debug`, `:info`, `:warn`, `:error`, `:fatal`, `:unknown`입니다.

#### `config.log_tags`

`request` 객체가 응답하는 메서드 목록, `request` 객체를 받아들이는 `Proc` 또는 `to_s`에 응답하는 것을 허용합니다. 이를 통해 서브도메인 및 요청 ID와 같은 디버그 정보를 로그 라인에 태그하는 것이 쉬워집니다. 이는 다중 사용자 프로덕션 애플리케이션의 디버깅에 매우 유용합니다.

#### `config.logger`

`Rails.logger` 및 `ActiveRecord::Base.logger`와 같은 관련된 Rails 로깅에 사용될 로거입니다. 이는 `log/` 디렉토리에 로그를 출력하는 `ActiveSupport::Logger`의 인스턴스를 래핑하는 `ActiveSupport::TaggedLogging`의 인스턴스로 기본적으로 설정됩니다. 사용자 정의 로거를 제공할 수 있으며, 완전한 호환성을 위해 다음 지침을 따라야 합니다.

* 포매터를 지원하려면 `config.log_formatter` 값에서 로거에 포매터를 수동으로 할당해야 합니다.
* 태그된 로그를 지원하려면 로그 인스턴스를 `ActiveSupport::TaggedLogging`으로 래핑해야 합니다.
* 음소거를 지원하려면 로거에 `ActiveSupport::LoggerSilence` 모듈을 포함해야 합니다. `ActiveSupport::Logger` 클래스는 이미 이러한 모듈을 포함하고 있습니다.

```ruby
class MyLogger < ::Logger
  include ActiveSupport::LoggerSilence
end

mylogger           = MyLogger.new(STDOUT)
mylogger.formatter = config.log_formatter
config.logger      = ActiveSupport::TaggedLogging.new(mylogger)
```

#### `config.middleware`

애플리케이션의 미들웨어를 구성할 수 있습니다. 이에 대한 자세한 내용은 아래의 [미들웨어 구성](#configuring-middleware) 섹션에서 다룹니다.

#### `config.precompile_filter_parameters`

`true`로 설정하면 [`config.filter_parameters`](#config-filter-parameters)를 [`ActiveSupport::ParameterFilter.precompile_filters`][]를 사용하여 사전 컴파일합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다.

| 버전 | 기본값 |
| ---- | ------ |
| (원본) | `false` |
| 7.1 | `true` |

#### `config.public_file_server.enabled`

Rails를 통해 정적 파일을 public 디렉토리에서 제공하도록 구성합니다. 이 옵션은 기본적으로 `true`로 설정되지만, 프로덕션 환경에서는 애플리케이션을 실행하는 서버 소프트웨어(예: NGINX 또는 Apache)가 정적 파일을 제공하도록 `false`로 설정됩니다. WEBrick를 사용하여 프로덕션에서 앱을 실행하거나 테스트하는 경우(WEBrick를 사용하는 것은 권장되지 않습니다), 옵션을 `true`로 설정하세요. 그렇지 않으면 public 디렉토리에 있는 파일에 대한 페이지 캐싱과 요청을 사용할 수 없습니다.
#### `config.railties_order`

Railties/Engines가 로드되는 순서를 수동으로 지정할 수 있습니다. 기본값은 `[:all]`입니다.

```ruby
config.railties_order = [Blog::Engine, :main_app, :all]
```

#### `config.rake_eager_load`

`true`로 설정하면 Rake 작업을 실행할 때 애플리케이션을 즉시 로드합니다. 기본값은 `false`입니다.

#### `config.read_encrypted_secrets`

*DEPRECATED*: 암호화된 비밀 정보 대신 [credentials](https://guides.rubyonrails.org/security.html#custom-credentials)를 사용해야 합니다.

`true`로 설정하면 `config/secrets.yml.enc`에서 암호화된 비밀 정보를 읽으려고 시도합니다.

#### `config.relative_url_root`

Rails가 [하위 디렉토리에 배포](configuring.html#deploy-to-a-subdirectory-relative-url-root)하는 것을 알리기 위해 사용될 수 있습니다. 기본값은 `ENV['RAILS_RELATIVE_URL_ROOT']`입니다.

#### `config.reload_classes_only_on_change`

추적된 파일이 변경될 때만 클래스를 다시 로드하도록 활성화 또는 비활성화합니다. 기본적으로 autoload 경로의 모든 파일을 추적하며 `true`로 설정됩니다. `config.enable_reloading`이 `false`인 경우 이 옵션은 무시됩니다.

#### `config.require_master_key`

`ENV["RAILS_MASTER_KEY"]` 또는 `config/master.key` 파일을 통해 마스터 키를 사용할 수 없는 경우 앱을 부팅하지 않도록 합니다.

#### `config.secret_key_base`

응용 프로그램의 키 생성기에 대한 입력 비밀을 지정하는 대체 옵션입니다. 이 값을 설정하지 않고 대신 `config/credentials.yml.enc`에서 `secret_key_base`를 지정하는 것이 권장됩니다. 자세한 내용 및 대체 구성 방법은 [`secret_key_base` API 문서](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-secret_key_base)를 참조하십시오.

#### `config.server_timing`

`true`로 설정하면 [ServerTiming 미들웨어](#actiondispatch-servertiming)를 미들웨어 스택에 추가합니다.

#### `config.session_options`

`config.session_store`에 전달되는 추가 옵션입니다. 직접 수정하는 대신 `config.session_store`를 사용해야 합니다.

```ruby
config.session_store :cookie_store, key: "_your_app_session"
config.session_options # => {key: "_your_app_session"}
```

#### `config.session_store`

세션을 저장하는 데 사용할 클래스를 지정합니다. 가능한 값은 `:cache_store`, `:cookie_store`, `:mem_cache_store`, 사용자 정의 저장소 또는 `:disabled`입니다. `:disabled`는 Rails가 세션을 처리하지 않도록 지정합니다.

이 설정은 setter가 아닌 일반 메서드 호출을 통해 구성됩니다. 이를 통해 추가 옵션을 전달할 수 있습니다.

```ruby
config.session_store :cookie_store, key: "_your_app_session"
```

사용자 정의 저장소가 심볼로 지정된 경우 `ActionDispatch::Session` 네임스페이스로 해결됩니다.

```ruby
# 세션 저장소로 ActionDispatch::Session::MyCustomStore를 사용합니다.
config.session_store :my_custom_store
```

기본 저장소는 응용 프로그램 이름을 세션 키로 사용하는 쿠키 저장소입니다.

#### `config.ssl_options`

[`ActionDispatch::SSL`](https://api.rubyonrails.org/classes/ActionDispatch/SSL.html) 미들웨어의 구성 옵션입니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| ---- | ------ |
| (원본) | `{}` |
| 5.0 | `{ hsts: { subdomains: true } }` |

#### `config.time_zone`

응용 프로그램의 기본 시간대를 설정하고 Active Record의 시간대 인식을 활성화합니다.

#### `config.x`

응용 프로그램 구성 객체에 중첩된 사용자 정의 구성을 쉽게 추가하는 데 사용됩니다.

  ```ruby
  config.x.payment_processing.schedule = :daily
  Rails.configuration.x.payment_processing.schedule # => :daily
  ```

[사용자 정의 구성](#custom-configuration)을 참조하십시오.

### 자산 구성

#### `config.assets.css_compressor`

사용할 CSS 압축기를 정의합니다. 기본적으로 `sass-rails`에 의해 설정됩니다. 현재 유일한 대체 값은 `:yui`이며 `yui-compressor` 젬을 사용합니다.

#### `config.assets.js_compressor`

사용할 JavaScript 압축기를 정의합니다. 가능한 값은 `:terser`, `:closure`, `:uglifier`, `:yui`이며 각각 `terser`, `closure-compiler`, `uglifier`, `yui-compressor` 젬을 사용해야 합니다.

#### `config.assets.gzip`

컴파일된 자산의 압축 버전과 비압축 자산을 생성하는 플래그입니다. 기본값은 `true`입니다.

#### `config.assets.paths`

자산을 찾기 위해 사용되는 경로를 포함합니다. 이 구성 옵션에 경로를 추가하면 해당 경로가 자산 검색에 사용됩니다.
#### `config.assets.precompile`

`bin/rails assets:precompile`이 실행될 때 `application.css`와 `application.js` 이외의 추가 에셋을 지정할 수 있습니다.

#### `config.assets.unknown_asset_fallback`

sprockets-rails 3.2.0 이상을 사용하는 경우, 에셋 파이프라인에서 에셋이 파이프라인에 없을 때 동작을 수정할 수 있습니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| ---- | ------ |
| (원본) | `true` |
| 5.1 | `false` |

#### `config.assets.prefix`

에셋이 제공되는 접두사를 정의합니다. 기본값은 `/assets`입니다.

#### `config.assets.manifest`

에셋 프리컴파일러의 매니페스트 파일에 사용할 전체 경로를 정의합니다. 기본값은 public 폴더 내의 `config.assets.prefix` 디렉토리에 `manifest-<random>.json`이라는 이름의 파일입니다.

#### `config.assets.digest`

에셋 이름에 SHA256 지문을 사용할 수 있게 합니다. 기본값은 `true`입니다.

#### `config.assets.debug`

에셋의 연결 및 압축을 비활성화합니다. `development.rb`에서 기본값은 `true`입니다.

#### `config.assets.version`

SHA256 해시 생성에 사용되는 옵션 문자열입니다. 모든 파일을 다시 컴파일하도록 변경할 수 있습니다.

#### `config.assets.compile`

생산 환경에서 실시간 Sprockets 컴파일을 활성화할 수 있는 부울입니다.

#### `config.assets.logger`

Log4r 또는 기본 Ruby `Logger` 클래스와 같은 인터페이스를 준수하는 로거를 허용합니다. 기본값은 `config.logger`에서 구성한 것과 동일합니다. `config.assets.logger`를 `false`로 설정하면 제공된 에셋 로깅이 비활성화됩니다.

#### `config.assets.quiet`

에셋 요청의 로깅을 비활성화합니다. `development.rb`에서 기본값은 `true`입니다.

### 생성기 구성

Rails는 `config.generators` 메서드를 사용하여 사용할 생성기를 변경할 수 있도록 합니다. 이 메서드는 블록을 사용합니다:

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

이 블록에서 사용할 수 있는 전체 메서드 집합은 다음과 같습니다:

* `force_plural`은 복수형 모델 이름을 허용합니다. 기본값은 `false`입니다.
* `helper`는 헬퍼를 생성할지 여부를 정의합니다. 기본값은 `true`입니다.
* `integration_tool`은 통합 테스트를 생성하는 데 사용할 통합 도구를 정의합니다. 기본값은 `:test_unit`입니다.
* `system_tests`은 시스템 테스트를 생성하는 데 사용할 통합 도구를 정의합니다. 기본값은 `:test_unit`입니다.
* `orm`은 사용할 ORM을 정의합니다. 기본값은 `false`이며 기본적으로 Active Record를 사용합니다.
* `resource_controller`는 `bin/rails generate resource`를 사용하여 컨트롤러를 생성할 때 사용할 생성기를 정의합니다. 기본값은 `:controller`입니다.
* `resource_route`는 리소스 라우트 정의를 생성할지 여부를 정의합니다. 기본값은 `true`입니다.
* `scaffold_controller`는 `bin/rails generate scaffold`를 사용하여 _스캐폴드_된 컨트롤러를 생성할 때 사용할 생성기를 정의합니다. 기본값은 `:scaffold_controller`입니다.
* `test_framework`은 사용할 테스트 프레임워크를 정의합니다. 기본값은 `false`이며 기본적으로 minitest를 사용합니다.
* `template_engine`은 ERB 또는 Haml과 같은 템플릿 엔진을 정의합니다. 기본값은 `:erb`입니다.

### 미들웨어 구성

모든 Rails 애플리케이션에는 개발 환경에서 다음과 같은 표준 미들웨어 세트가 있습니다:

#### `ActionDispatch::HostAuthorization`

DNS 리바인딩 및 기타 `Host` 헤더 공격에 대비합니다.
다음 구성으로 개발 환경에 기본적으로 포함됩니다:

```ruby
Rails.application.config.hosts = [
  IPAddr.new("0.0.0.0/0"),        # 모든 IPv4 주소.
  IPAddr.new("::/0"),             # 모든 IPv6 주소.
  "localhost",                    # 로컬호스트 예약 도메인.
  ENV["RAILS_DEVELOPMENT_HOSTS"]  # 추가 쉼표로 구분된 개발용 호스트.
]
```
다른 환경에서는 `Rails.application.config.hosts`가 비어 있으며 `Host` 헤더 확인이 수행되지 않습니다. 프로덕션에서 헤더 공격에 대비하려면 허용된 호스트를 수동으로 허용해야 합니다.

```ruby
Rails.application.config.hosts << "product.com"
```

요청의 호스트는 `hosts` 항목과 `#===` 케이스 연산자를 사용하여 확인되며, 이를 통해 `hosts`는 `Regexp`, `Proc`, `IPAddr`와 같은 유형의 항목을 지원할 수 있습니다. 다음은 정규식을 사용한 예제입니다.

```ruby
# `www.product.com` 및 `beta1.product.com`과 같은 하위 도메인에서의 요청 허용
Rails.application.config.hosts << /.*\.product\.com/
```

제공된 정규식은 앵커 (`\A` 및 `\z`)로 래핑되므로 전체 호스트 이름과 일치해야 합니다. 예를 들어 `/product.com/`은 앵커가 적용된 경우 `www.product.com`과 일치하지 않습니다.

모든 하위 도메인을 허용하는 특수한 경우를 지원합니다.

```ruby
# `www.product.com` 및 `beta1.product.com`과 같은 하위 도메인에서의 요청 허용
Rails.application.config.hosts << ".product.com"
```

`config.host_authorization.exclude`를 설정하여 호스트 인증 확인에서 특정 요청을 제외할 수 있습니다.

```ruby
# /healthcheck/ 경로에 대한 요청을 호스트 확인에서 제외
Rails.application.config.host_authorization = {
  exclude: ->(request) { request.path.include?('healthcheck') }
}
```

허가되지 않은 호스트로 요청이 전송되면 기본 Rack 애플리케이션이 실행되고 `403 Forbidden`으로 응답합니다. 이는 `config.host_authorization.response_app`을 설정하여 사용자 정의할 수 있습니다. 예를 들어:

```ruby
Rails.application.config.host_authorization = {
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

#### `ActionDispatch::ServerTiming`

`Server-Timing` 헤더에 메트릭을 추가하여 브라우저의 개발 도구에서 볼 수 있도록 합니다.

#### `ActionDispatch::SSL`

모든 요청을 HTTPS를 사용하여 제공하도록 강제합니다. `config.force_ssl`이 `true`로 설정된 경우 활성화됩니다. 이에 대한 옵션은 `config.ssl_options`를 설정하여 구성할 수 있습니다.

#### `ActionDispatch::Static`

정적 자산을 제공하는 데 사용됩니다. `config.public_file_server.enabled`가 `false`로 설정된 경우 비활성화됩니다. 디렉토리 요청에 `index`로 명명되지 않은 정적 디렉토리 인덱스 파일을 제공해야 하는 경우 `config.public_file_server.index_name`을 설정하세요. 예를 들어, 디렉토리 요청에 `index.html` 대신 `main.html`을 제공하려면 `config.public_file_server.index_name`을 `"main"`으로 설정하세요.

#### `ActionDispatch::Executor`

스레드 안전한 코드 다시로드를 허용합니다. `config.allow_concurrency`가 `false`로 설정된 경우 `Rack::Lock`이 로드되어 비활성화됩니다. `Rack::Lock`은 앱을 뮤텍스로 래핑하여 한 번에 하나의 스레드만 호출할 수 있도록 합니다.

#### `ActiveSupport::Cache::Strategy::LocalCache`

기본 메모리 기반 캐시로 사용됩니다. 이 캐시는 스레드 안전하지 않으며 단일 스레드의 임시 메모리 캐시로만 사용되도록 되어 있습니다.

#### `Rack::Runtime`

요청 실행에 걸린 시간 (초 단위)을 포함하는 `X-Runtime` 헤더를 설정합니다.

#### `Rails::Rack::Logger`

요청이 시작되었음을 로그에 알립니다. 요청이 완료되면 모든 로그를 플러시합니다.

#### `ActionDispatch::ShowExceptions`

응용 프로그램에서 반환된 예외를 잡아서 요청이 로컬인 경우나 `config.consider_all_requests_local`이 `true`로 설정된 경우 예외 페이지를 렌더링합니다. `config.action_dispatch.show_exceptions`가 `:none`으로 설정된 경우 예외가 발생합니다.

#### `ActionDispatch::RequestId`

고유한 X-Request-Id 헤더를 응답에서 사용할 수 있게 하며 `ActionDispatch::Request#uuid` 메서드를 활성화합니다. `config.action_dispatch.request_id_header`로 구성할 수 있습니다.

#### `ActionDispatch::RemoteIp`

IP 스푸핑 공격을 확인하고 요청 헤더에서 유효한 `client_ip`를 가져옵니다. `config.action_dispatch.ip_spoofing_check` 및 `config.action_dispatch.trusted_proxies` 옵션으로 구성할 수 있습니다.

#### `Rack::Sendfile`

파일에서 제공되는 응답의 본문을 가로채고 서버별 X-Sendfile 헤더로 대체합니다. `config.action_dispatch.x_sendfile_header`로 구성할 수 있습니다.
#### `ActionDispatch::Callbacks`

요청을 처리하기 전에 준비 콜백을 실행합니다.

#### `ActionDispatch::Cookies`

요청에 대한 쿠키를 설정합니다.

#### `ActionDispatch::Session::CookieStore`

세션을 쿠키에 저장하는 역할을 합니다. [`config.session_store`](#config-session-store)를 변경하여 대체 미들웨어를 사용할 수 있습니다.

#### `ActionDispatch::Flash`

`flash` 키를 설정합니다. [`config.session_store`](#config-session-store)가 값으로 설정된 경우에만 사용할 수 있습니다.

#### `Rack::MethodOverride`

`params[:_method]`가 설정된 경우에 메서드를 재정의할 수 있도록 합니다. 이 미들웨어는 PATCH, PUT 및 DELETE HTTP 메서드 유형을 지원합니다.

#### `Rack::Head`

HEAD 요청을 GET 요청으로 변환하여 제공합니다.

#### 사용자 정의 미들웨어 추가

이 외에도 `config.middleware.use` 메서드를 사용하여 직접 미들웨어를 추가할 수 있습니다:

```ruby
config.middleware.use Magical::Unicorns
```

이렇게 하면 `Magical::Unicorns` 미들웨어가 스택의 끝에 추가됩니다. 다른 미들웨어 앞에 미들웨어를 추가하려면 `insert_before`를 사용할 수 있습니다.

```ruby
config.middleware.insert_before Rack::Head, Magical::Unicorns
```

또는 인덱스를 사용하여 미들웨어를 정확한 위치에 삽입할 수도 있습니다. 예를 들어, 스택의 맨 위에 `Magical::Unicorns` 미들웨어를 삽입하려면 다음과 같이 할 수 있습니다:

```ruby
config.middleware.insert_before 0, Magical::Unicorns
```

`insert_after`를 사용하면 다른 미들웨어 뒤에 미들웨어를 삽입할 수도 있습니다:

```ruby
config.middleware.insert_after Rack::Head, Magical::Unicorns
```

미들웨어는 완전히 교체하여 다른 미들웨어로 대체할 수도 있습니다:

```ruby
config.middleware.swap ActionController::Failsafe, Lifo::Failsafe
```

미들웨어를 한 곳에서 다른 곳으로 이동할 수도 있습니다:

```ruby
config.middleware.move_before ActionDispatch::Flash, Magical::Unicorns
```

이렇게 하면 `Magical::Unicorns` 미들웨어가 `ActionDispatch::Flash` 앞으로 이동합니다. 뒤로 이동할 수도 있습니다:

```ruby
config.middleware.move_after ActionDispatch::Flash, Magical::Unicorns
```

미들웨어를 스택에서 완전히 제거할 수도 있습니다:

```ruby
config.middleware.delete Rack::MethodOverride
```

### i18n 구성

이러한 구성 옵션은 모두 `I18n` 라이브러리로 위임됩니다.

#### `config.i18n.available_locales`

앱에서 허용되는 사용 가능한 로케일을 정의합니다. 일반적으로 새로운 애플리케이션에서는 로케일 파일에서 찾은 모든 로케일 키(일반적으로 `:en`만)로 기본 설정됩니다.

#### `config.i18n.default_locale`

i18n에 사용되는 애플리케이션의 기본 로케일을 설정합니다. 기본값은 `:en`입니다.

#### `config.i18n.enforce_available_locales`

i18n을 통해 전달되는 모든 로케일이 `available_locales` 목록에 선언되어야 함을 보장하며, 사용할 수 없는 로케일을 설정할 때 `I18n::InvalidLocale` 예외를 발생시킵니다. 기본값은 `true`입니다. 사용자 입력에서 잘못된 로케일을 설정하는 것에 대한 보안 조치로 작동하기 때문에 이 옵션을 비활성화하지 않는 것이 좋습니다.

#### `config.i18n.load_path`

Rails가 로케일 파일을 찾는 데 사용하는 경로를 설정합니다. 기본값은 `config/locales/**/*.{yml,rb}`입니다.

#### `config.i18n.raise_on_missing_translations`

누락된 번역에 대해 오류를 발생시킬지 여부를 결정합니다. 기본값은 `false`입니다.

#### `config.i18n.fallbacks`

누락된 번역에 대한 대체 동작을 설정합니다. 이 옵션에 대한 3가지 사용 예는 다음과 같습니다:

  * 기본 로케일을 대체로 사용하려면 옵션을 `true`로 설정할 수 있습니다:

    ```ruby
    config.i18n.fallbacks = true
    ```

  * 또는 대체로 사용할 로케일의 배열을 설정할 수 있습니다:

    ```ruby
    config.i18n.fallbacks = [:tr, :en]
    ```

  * 또는 로케일별로 다른 대체를 설정할 수도 있습니다. 예를 들어, `:az`에 대해 `:tr`을 사용하고 `:da`에 대해 `:de`와 `:en`을 사용하려면 다음과 같이 할 수 있습니다:

    ```ruby
    config.i18n.fallbacks = { az: :tr, da: [:de, :en] }
    #또는
    config.i18n.fallbacks.map = { az: :tr, da: [:de, :en] }
    ```
### Active Model 구성

#### `config.active_model.i18n_customize_full_message`

[`Error#full_message`][ActiveModel::Error#full_message] 형식을 i18n 로케일 파일에서 재정의할 수 있는지를 제어합니다. 기본값은 `false`입니다.

`true`로 설정하면 `full_message`는 로케일 파일의 속성과 모델 수준에서 형식을 찾습니다. 기본 형식은 `"%{attribute} %{message}"`이며, `attribute`는 속성의 이름이고 `message`는 유효성 검사에 특정한 메시지입니다. 다음 예제는 모든 `Person` 속성과 특정 `Person` 속성(`age`)에 대한 형식을 재정의합니다.

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :age

  validates :name, :age, presence: true
end
```

```yml
en:
  activemodel: # 또는 activerecord:
    errors:
      models:
        person:
          # 모든 Person 속성에 대한 형식 재정의:
          format: "Invalid %{attribute} (%{message})"
          attributes:
            age:
              # age 속성에 대한 형식 재정의:
              format: "%{message}"
              blank: "Please fill in your %{attribute}"
```

```irb
irb> person = Person.new.tap(&:valid?)

irb> person.errors.full_messages
=> [
  "Invalid Name (can’t be blank)",
  "Please fill in your Age"
]

irb> person.errors.messages
=> {
  :name => ["can’t be blank"],
  :age  => ["Please fill in your Age"]
}
```


### Active Record 구성

`config.active_record`에는 다양한 구성 옵션이 포함되어 있습니다.

#### `config.active_record.logger`

Log4r 또는 기본 Ruby Logger 클래스와 같은 인터페이스를 준수하는 로거를 허용합니다. 이 로거는 새로운 데이터베이스 연결에 전달됩니다. Active Record 모델 클래스 또는 Active Record 모델 인스턴스에서 `logger`를 호출하여 이 로거를 검색할 수 있습니다. 로깅을 비활성화하려면 `nil`로 설정합니다.

#### `config.active_record.primary_key_prefix_type`

기본 키 열의 이름을 조정할 수 있습니다. 기본적으로 Rails는 기본 키 열의 이름이 `id`라고 가정합니다(이 구성 옵션을 설정할 필요가 없습니다). 다른 두 가지 선택지가 있습니다.

* `:table_name`은 Customer 클래스의 기본 키를 `customerid`로 만듭니다.
* `:table_name_with_underscore`는 Customer 클래스의 기본 키를 `customer_id`로 만듭니다.

#### `config.active_record.table_name_prefix`

테이블 이름 앞에 추가할 전역 문자열을 설정할 수 있습니다. 이를 `northwest_`로 설정하면 Customer 클래스는 테이블로 `northwest_customers`를 찾습니다. 기본값은 빈 문자열입니다.

#### `config.active_record.table_name_suffix`

테이블 이름 뒤에 추가할 전역 문자열을 설정할 수 있습니다. 이를 `_northwest`로 설정하면 Customer 클래스는 테이블로 `customers_northwest`를 찾습니다. 기본값은 빈 문자열입니다.

#### `config.active_record.schema_migrations_table_name`

스키마 마이그레이션 테이블의 이름으로 사용할 문자열을 설정할 수 있습니다.

#### `config.active_record.internal_metadata_table_name`

내부 메타데이터 테이블의 이름으로 사용할 문자열을 설정할 수 있습니다.

#### `config.active_record.protected_environments`

파괴적인 작업이 금지되어야 하는 환경의 이름 배열을 설정할 수 있습니다.

#### `config.active_record.pluralize_table_names`

데이터베이스에서 단수 또는 복수형 테이블 이름을 찾을지를 지정합니다. `true`로 설정하면(기본값) Customer 클래스는 `customers` 테이블을 사용합니다. `false`로 설정하면 Customer 클래스는 `customer` 테이블을 사용합니다.

#### `config.active_record.default_timezone`

데이터베이스에서 날짜와 시간을 가져올 때 `Time.local`(설정이 `:local`로 설정된 경우) 또는 `Time.utc`(설정이 `:utc`로 설정된 경우)를 사용할지를 결정합니다. 기본값은 `:utc`입니다.
#### `config.active_record.schema_format`

데이터베이스 스키마를 파일로 덤프하는 형식을 제어합니다. 옵션은 마이그레이션에 의존하는 데이터베이스 독립적 버전인 `:ruby` (기본값) 또는 (잠재적으로 데이터베이스 종속적인) SQL 문의 집합인 `:sql`입니다.

#### `config.active_record.error_on_ignored_order`

배치 쿼리 중에 쿼리의 순서가 무시되었을 때 오류를 발생시킬지 여부를 지정합니다. 옵션은 `true` (오류 발생) 또는 `false` (경고)입니다. 기본값은 `false`입니다.

#### `config.active_record.timestamped_migrations`

마이그레이션을 일련 번호가 아닌 타임스탬프와 함께 번호를 매길지 여부를 제어합니다. 기본값은 `true`로, 동일한 애플리케이션에서 여러 개발자가 작업하는 경우 선호되는 타임스탬프를 사용합니다.

#### `config.active_record.db_warnings_action`

SQL 쿼리가 경고를 생성할 때 수행할 작업을 제어합니다. 다음 옵션을 사용할 수 있습니다:

  * `:ignore` - 데이터베이스 경고를 무시합니다. 이것이 기본값입니다.

  * `:log` - 데이터베이스 경고가 `ActiveRecord.logger`의 `:warn` 수준으로 기록됩니다.

  * `:raise` - 데이터베이스 경고가 `ActiveRecord::SQLWarning`으로 발생합니다.

  * `:report` - 데이터베이스 경고가 Rails의 오류 보고기 구독자에게 보고됩니다.

  * 사용자 정의 proc - 사용자 정의 proc를 제공할 수 있습니다. `SQLWarning` 오류 객체를 인수로 받아야 합니다.

    예를 들어:

    ```ruby
    config.active_record.db_warnings_action = ->(warning) do
      # 사용자 정의 예외 보고 서비스에 보고
      Bugsnag.notify(warning.message) do |notification|
        notification.add_metadata(:warning_code, warning.code)
        notification.add_metadata(:warning_level, warning.level)
      end
    end
    ```

#### `config.active_record.db_warnings_ignore`

구성된 `db_warnings_action`과 관계없이 무시될 경고 코드와 메시지의 allowlist를 지정합니다. 기본 동작은 모든 경고를 보고하는 것입니다. 무시할 경고는 문자열 또는 정규식으로 지정할 수 있습니다. 예를 들어:

  ```ruby
  config.active_record.db_warnings_action = :raise
  # 다음 경고는 발생하지 않습니다
  config.active_record.db_warnings_ignore = [
    /Invalid utf8mb4 character string/,
    "An exact warning message",
    "1062", # MySQL Error 1062: Duplicate entry
  ]
  ```

#### `config.active_record.migration_strategy`

마이그레이션에서 스키마 문장 메서드를 수행하는 데 사용되는 전략 클래스를 제어합니다. 기본 클래스는 연결 어댑터로 위임합니다. 사용자 정의 전략은 `ActiveRecord::Migration::ExecutionStrategy`를 상속해야 하며, 구현되지 않은 메서드에 대해서는 기본 동작을 유지하는 `DefaultStrategy`에서 상속할 수도 있습니다:

```ruby
class CustomMigrationStrategy < ActiveRecord::Migration::DefaultStrategy
  def drop_table(*)
    raise "Dropping tables is not supported!"
  end
end

config.active_record.migration_strategy = CustomMigrationStrategy
```

#### `config.active_record.lock_optimistically`

Active Record가 낙관적 락을 사용할지 여부를 제어하며, 기본값은 `true`입니다.

#### `config.active_record.cache_timestamp_format`

캐시 키의 타임스탬프 값의 형식을 제어합니다. 기본값은 `:usec`입니다.

#### `config.active_record.record_timestamps`

모델에서 `create` 및 `update` 작업의 타임스탬프 기록 여부를 제어하는 부울 값입니다. 기본값은 `true`입니다.

#### `config.active_record.partial_inserts`

새 레코드를 생성할 때 부분 쓰기를 사용할지 여부를 제어하는 부울 값입니다 (즉, 기본값과 다른 속성만 설정하는지 여부). 기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 시작 | 기본값 |
| ---------- | ------- |
| (원래)     | `true`  |
| 7.0        | `false` |

#### `config.active_record.partial_updates`

기존 레코드를 업데이트할 때 부분 쓰기를 사용할지 여부를 제어하는 부울 값입니다 (즉, 변경된 속성만 설정하는지 여부). 부분 업데이트를 사용할 때는 동시 업데이트가 가능하기 때문에 낙관적 락 `config.active_record.lock_optimistically`도 사용해야 합니다. 기본값은 `true`입니다.
#### `config.active_record.maintain_test_schema`

`config.active_record.maintain_test_schema`는 Active Record가 테스트를 실행할 때 `db/schema.rb` (또는 `db/structure.sql`)와 테스트 데이터베이스 스키마를 최신 상태로 유지하려는지를 제어하는 부울 값입니다. 기본값은 `true`입니다.

#### `config.active_record.dump_schema_after_migration`

`config.active_record.dump_schema_after_migration`은 마이그레이션을 실행할 때 스키마 덤프(`db/schema.rb` 또는 `db/structure.sql`)가 발생해야 하는지를 제어하는 플래그입니다. 이 값은 Rails에 의해 생성된 `config/environments/production.rb`에서 `false`로 설정됩니다. 이 구성이 설정되지 않은 경우 기본값은 `true`입니다.

#### `config.active_record.dump_schemas`

`db:schema:dump`를 호출할 때 덤프할 데이터베이스 스키마를 제어합니다. 옵션은 `:schema_search_path` (기본값)로 `schema_search_path`에 나열된 스키마를 덤프하고, `:all`로 `schema_search_path`와 상관없이 모든 스키마를 항상 덤프하며, 쉼표로 구분된 스키마의 문자열입니다.

#### `config.active_record.before_committed_on_all_records`

트랜잭션에 등록된 모든 레코드에서 before_committed! 콜백을 활성화합니다. 이전 동작은 동일한 레코드의 여러 복사본이 트랜잭션에 등록된 경우 첫 번째 복사본에만 콜백을 실행하는 것이었습니다.

| 버전부터 | 기본값은 |
| -------- | -------- |
| (원본)   | `false`  |
| 7.1      | `true`   |

#### `config.active_record.belongs_to_required_by_default`

`config.active_record.belongs_to_required_by_default`는 `belongs_to` 연관 관계가 존재하지 않으면 레코드가 유효성 검사에 실패하는지를 제어하는 부울 값입니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값은 |
| -------- | -------- |
| (원본)   | `nil`    |
| 5.0      | `true`   |

#### `config.active_record.belongs_to_required_validates_foreign_key`

부모가 필수인 경우 부모와 관련된 열만 존재 여부를 유효성 검사하도록 설정합니다. 이전 동작은 부모 레코드의 존재 여부를 유효성 검사하고, 이는 자식 레코드가 업데이트될 때마다 부모를 가져오기 위해 추가 쿼리를 수행했습니다. 부모가 변경되지 않은 경우에도 이 작업이 수행되었습니다.

| 버전부터 | 기본값은 |
| -------- | -------- |
| (원본)   | `true`   |
| 7.1      | `false`  |

#### `config.active_record.marshalling_format_version`

`config.active_record.marshalling_format_version`이 `7.1`로 설정되면 `Marshal.dump`를 사용하여 Active Record 인스턴스를 더 효율적으로 직렬화할 수 있습니다.

이렇게 하면 직렬화 형식이 변경되므로 이 방식으로 직렬화된 모델은 이전(< 7.1) 버전의 Rails에서 읽을 수 없습니다. 그러나 이 최적화가 활성화되었는지 여부에 관계없이 이전 형식을 사용하는 메시지는 여전히 읽을 수 있습니다.

| 버전부터 | 기본값은 |
| -------- | -------- |
| (원본)   | `6.1`    |
| 7.1      | `7.1`    |

#### `config.active_record.action_on_strict_loading_violation`

연관 관계에 strict_loading이 설정된 경우 예외를 발생시키거나 로깅하는지를 제어합니다. 기본값은 모든 환경에서 `:raise`입니다. 예외를 발생시키는 대신 로거로 위반 사항을 보내려면 `:log`로 변경할 수 있습니다.

#### `config.active_record.strict_loading_by_default`

`config.active_record.strict_loading_by_default`는 strict_loading 모드를 기본적으로 활성화하거나 비활성화하는 부울 값입니다. 기본값은 `false`입니다.

#### `config.active_record.warn_on_records_fetched_greater_than`

쿼리 결과 크기에 대한 경고 임계값을 설정할 수 있습니다. 쿼리로 반환된 레코드 수가 임계값을 초과하는 경우 경고가 로그에 기록됩니다. 이를 통해 메모리 공간을 낭비하는 쿼리를 식별할 수 있습니다.

#### `config.active_record.index_nested_attribute_errors`

중첩된 `has_many` 관계의 오류를 인덱스와 함께 표시할지 여부를 설정할 수 있습니다. 기본값은 `false`입니다.
#### `config.active_record.use_schema_cache_dump`

`db/schema_cache.yml`에서 스키마 캐시 정보를 가져올 수 있도록 사용자에게 허용합니다 (`bin/rails db:schema:cache:dump`에 의해 생성됨). 이 정보를 얻기 위해 데이터베이스에 쿼리를 보내지 않아도 됩니다. 기본값은 `true`입니다.

#### `config.active_record.cache_versioning`

`#cache_key` 메서드와 함께 변경되는 버전을 가진 안정적인 `#cache_key` 메서드를 사용할지 여부를 나타냅니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원래)            | `false`              |
| 5.2                   | `true`               |

#### `config.active_record.collection_cache_versioning`

캐시되는 객체의 유형이 `ActiveRecord::Relation`인 경우 해당 객체가 변경될 때 동일한 캐시 키를 재사용할 수 있도록 관련 캐시 키의 변동성 정보 (최대 업데이트 및 개수)를 캐시 버전으로 이동시켜 캐시 키 재활용을 지원합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원래)            | `false`              |
| 6.0                   | `true`               |

#### `config.active_record.has_many_inversing`

`belongs_to`에서 `has_many`로 연결되는 경우 역 관계 레코드를 설정할 수 있도록 합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원래)            | `false`              |
| 6.1                   | `true`               |

#### `config.active_record.automatic_scope_inversing`

스코프가 있는 연관 관계의 `inverse_of`를 자동으로 추론할 수 있도록 합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원래)            | `false`              |
| 7.0                   | `true`               |

#### `config.active_record.destroy_association_async_job`

백그라운드에서 연관된 레코드를 삭제하는 데 사용될 작업을 지정할 수 있습니다. 기본값은 `ActiveRecord::DestroyAssociationAsyncJob`입니다.

#### `config.active_record.destroy_association_async_batch_size`

`dependent: :destroy_async` 연관 옵션에 의해 백그라운드 작업에서 삭제될 최대 레코드 수를 지정할 수 있습니다. 모든 것이 동일한 경우, 작은 배치 크기는 더 많은 짧은 실행 시간의 백그라운드 작업을 대기열에 넣고, 큰 배치 크기는 더 적은 긴 실행 시간의 백그라운드 작업을 대기열에 넣습니다. 이 옵션의 기본값은 `nil`이며, 이는 특정 연관에 대한 모든 종속 레코드가 동일한 백그라운드 작업에서 삭제되도록 합니다.

#### `config.active_record.queues.destroy`

삭제 작업에 사용할 Active Job 대기열을 지정할 수 있습니다. 이 옵션이 `nil`인 경우, 퍼지 작업은 기본 Active Job 대기열로 전송됩니다 (`config.active_job.default_queue_name` 참조). 기본값은 `nil`입니다.

#### `config.active_record.enumerate_columns_in_select_statements`

`true`인 경우 `SELECT` 문에 항상 열 이름을 포함하고 와일드카드 `SELECT * FROM ...` 쿼리를 피합니다. 이는 예를 들어 PostgreSQL 데이터베이스에 열을 추가할 때 준비된 문 캐시 오류를 피하기 위한 것입니다. 기본값은 `false`입니다.

#### `config.active_record.verify_foreign_keys_for_fixtures`

테스트에서 픽스처를 로드한 후 모든 외래 키 제약 조건이 유효한지 확인합니다. PostgreSQL 및 SQLite에서만 지원됩니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원래)            | `false`              |
| 7.0                   | `true`               |

#### `config.active_record.raise_on_assign_to_attr_readonly`

`attr_readonly` 속성에 할당 시 예외를 발생시키도록 합니다. 이전 동작은 할당을 허용하지만 변경 사항을 데이터베이스에 저장하지 않았습니다.

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원래)            | `false`              |
| 7.1                   | `true`               |
#### `config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`

여러 개의 Active Record 인스턴스가 트랜잭션 내에서 동일한 레코드를 변경할 때, Rails는 `after_commit` 또는 `after_rollback` 콜백을 한 인스턴스에만 실행합니다. 이 옵션은 Rails가 어떤 인스턴스가 콜백을 받을지 선택하는 방법을 지정합니다.

`true`로 설정하면, 트랜잭션 콜백은 첫 번째로 저장하는 인스턴스에서 실행됩니다. 이 인스턴스의 상태가 오래된 상태일 수 있습니다.

`false`로 설정하면, 트랜잭션 콜백은 가장 최신 상태를 가진 인스턴스에서 실행됩니다. 다음과 같은 방식으로 인스턴스가 선택됩니다:

- 일반적으로, 트랜잭션 내에서 주어진 레코드를 마지막으로 저장하는 인스턴스에서 트랜잭션 콜백을 실행합니다.
- 두 가지 예외가 있습니다:
    - 레코드가 트랜잭션 내에서 생성되고 다른 인스턴스에서 업데이트된 경우, `after_create_commit` 콜백은 두 번째 인스턴스에서 실행됩니다. 이는 해당 인스턴스의 상태에 기반하여 단순히 실행될 `after_update_commit` 콜백 대신입니다.
    - 레코드가 트랜잭션 내에서 삭제되고, 그 후에 오래된 인스턴스가 업데이트를 수행한 경우, `after_destroy_commit` 콜백은 마지막으로 삭제된 인스턴스에서 실행됩니다. 이는 0개의 행에 영향을 미친 업데이트가 수행된 후에도 오래된 인스턴스에서 실행됩니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 시작 | 기본값 |
| ---------- | -------- |
| (원본)     | `true`   |
| 7.1        | `false`  |

#### `config.active_record.default_column_serializer`

주어진 열에 명시적으로 지정된 것이 없는 경우 사용할 직렬화 구현입니다.

과거에는 `serialize`와 `store`는 대체 직렬화 구현을 사용할 수 있도록 허용했지만, 기본적으로 `YAML`을 사용했지만, 이는 효율적인 형식이 아니며, 신중하게 사용하지 않으면 보안 취약점의 원인이 될 수 있습니다.

따라서 데이터베이스 직렬화에는 보다 엄격하고 제한된 형식을 선호하는 것이 좋습니다.

불행히도 Ruby의 표준 라이브러리에는 적합한 기본값이 실제로 없습니다. `JSON`은 형식으로 작동할 수 있지만, `json` 젬은 지원되지 않는 유형을 문자열로 변환하기 때문에 버그가 발생할 수 있습니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 시작 | 기본값 |
| ---------- | -------- |
| (원본)     | `YAML`   |
| 7.1        | `nil`    |

#### `config.active_record.run_after_transaction_callbacks_in_order_defined`

참일 경우, `after_commit` 콜백은 모델에서 정의된 순서대로 실행됩니다. 거짓일 경우, 역순으로 실행됩니다.

다른 모든 콜백은 항상 모델에서 정의된 순서대로 실행됩니다 (`prepend: true`를 사용하지 않는 한).

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 시작 | 기본값 |
| ---------- | -------- |
| (원본)     | `false`  |
| 7.1        | `true`   |

#### `config.active_record.query_log_tags_enabled`

어댑터 수준의 쿼리 주석을 활성화할지 여부를 지정합니다. 기본값은 `false`입니다.

참고: 이 값을 `true`로 설정하면 데이터베이스 준비된 문이 자동으로 비활성화됩니다.

#### `config.active_record.query_log_tags`

SQL 주석에 삽입될 키/값 태그를 지정하는 `Array`를 정의합니다. 기본값은 `[ :application ]`으로, 애플리케이션 이름을 반환하는 미리 정의된 태그입니다.

#### `config.active_record.query_log_tags_format`

태그에 사용할 포매터를 지정하는 `Symbol`입니다. 유효한 값은 `:sqlcommenter`와 `:legacy`입니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:
| 버전별 시작 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `:legacy`            |
| 7.1                   | `:sqlcommenter`      |

#### `config.active_record.cache_query_log_tags`

쿼리 로그 태그의 캐싱을 활성화할지 여부를 지정합니다. 많은 수의 쿼리를 가진 애플리케이션에서는 쿼리 로그 태그의 캐싱이 요청 또는 작업 실행의 수명 동안 컨텍스트가 변경되지 않을 때 성능 이점을 제공할 수 있습니다. 기본값은 `false`입니다.

#### `config.active_record.schema_cache_ignored_tables`

스키마 캐시를 생성할 때 무시해야 할 테이블의 목록을 정의합니다. 테이블 이름을 나타내는 문자열 또는 정규 표현식의 `Array`를 허용합니다.

#### `config.active_record.verbose_query_logs`

데이터베이스 쿼리를 호출하는 메서드의 소스 위치가 관련 쿼리 아래에 기록되어야 하는지 여부를 지정합니다. 기본적으로 개발 환경에서는 `true`이고 다른 모든 환경에서는 `false`입니다.

#### `config.active_record.sqlite3_adapter_strict_strings_by_default`

SQLite3Adapter가 엄격한 문자열 모드로 사용되어야 하는지 여부를 지정합니다. 엄격한 문자열 모드 사용은 이중 인용부호로 묶인 문자열 리터럴을 비활성화합니다.

SQLite는 이중 인용부호로 묶인 문자열 리터럴에 대해 몇 가지 특이한 동작을 가지고 있습니다.
먼저 이중 인용부호로 묶인 문자열을 식별자 이름으로 간주하려고 시도하지만
존재하지 않으면 문자열 리터럴로 간주합니다. 이로 인해 오타가 무시되어 알지 못한 채로 지나갈 수 있습니다.
예를 들어, 존재하지 않는 열에 대한 인덱스를 생성할 수 있습니다.
자세한 내용은 [SQLite 문서](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted)를 참조하십시오.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전별 시작 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.async_query_executor`

비동기 쿼리가 풀링되는 방식을 지정합니다.

기본값은 `nil`이며, `load_async`가 비활성화되고 대신 쿼리를 직접 전경에서 실행합니다.
쿼리를 실제로 비동기로 수행하려면 `:global_thread_pool` 또는 `:multi_thread_pool`로 설정해야 합니다.

`:global_thread_pool`은 애플리케이션이 연결하는 모든 데이터베이스에 대해 단일 풀을 사용합니다. 이는 단일 데이터베이스를 가진 애플리케이션이나 한 번에 하나의 데이터베이스 샤드만 쿼리하는 애플리케이션에 대한 우선적인 구성입니다.

`:multi_thread_pool`은 각 데이터베이스마다 하나의 풀을 사용하며, 각 풀의 크기는 `database.yml`에서 `max_threads` 및 `min_thread` 속성을 통해 개별적으로 구성할 수 있습니다. 이는 정기적으로 여러 데이터베이스를 동시에 쿼리하고 최대 동시성을 더 정확하게 정의해야 하는 애플리케이션에 유용할 수 있습니다.

#### `config.active_record.global_executor_concurrency`

`config.active_record.async_query_executor = :global_thread_pool`과 함께 사용되며, 동시에 실행할 수 있는 비동기 쿼리 수를 정의합니다.

기본값은 `4`입니다.

이 숫자는 `database.yml`에서 구성된 데이터베이스 풀 크기와 함께 고려해야 합니다. 연결 풀은
전경 스레드(예: 웹 서버 또는 작업자 스레드)와 백그라운드 스레드 모두를 수용할 수 있을만큼 충분히 커야 합니다.

#### `config.active_record.allow_deprecated_singular_associations_name`

`where` 절에서 단수 관계를 복수 이름으로 참조할 수 있는 비권장 동작을 활성화합니다. 이를 `false`로 설정하면 성능이 향상됩니다.

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end

Comment.where(post: post_id).count  # => 5

# `allow_deprecated_singular_associations_name`이 true인 경우:
Comment.where(posts: post_id).count # => 5 (비권장 경고)

# `allow_deprecated_singular_associations_name`이 false인 경우:
Comment.where(posts: post_id).count # => 오류
```

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:
| 버전별로 시작 | 기본값은 |
| --------------------- | -------------------- |
| (원본)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.yaml_column_permitted_classes`

기본값은 `[Symbol]`입니다. 애플리케이션에서 `ActiveRecord::Coders::YAMLColumn`의 `safe_load()`에 추가 허용 클래스를 포함할 수 있도록 합니다.

#### `config.active_record.use_yaml_unsafe_load`

기본값은 `false`입니다. 애플리케이션에서 `ActiveRecord::Coders::YAMLColumn`의 `unsafe_load`를 사용할 수 있도록 합니다.

#### `config.active_record.raise_int_wider_than_64bit`

기본값은 `true`입니다. PostgreSQL 어댑터에 64비트 부호 있는 정수보다 넓은 정수가 제공되었을 때 예외를 발생시킬지 여부를 결정합니다.

#### `ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans` 및 `ActiveRecord::ConnectionAdapters::TrilogyAdapter.emulate_booleans`

Active Record MySQL 어댑터가 모든 `tinyint(1)` 열을 부울로 간주할지 여부를 제어합니다. 기본값은 `true`입니다.

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.create_unlogged_tables`

PostgreSQL에 의해 생성된 데이터베이스 테이블이 "unlogged"되어야 하는지 여부를 제어합니다. 이는 성능을 향상시킬 수 있지만 데이터베이스가 충돌할 경우 데이터 손실의 위험을 추가합니다. 프로덕션 환경에서는 이를 활성화하지 않는 것이 매우 권장됩니다. 모든 환경에서 기본값은 `false`입니다.

테스트를 위해 이를 활성화하려면:

```ruby
# config/environments/test.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.create_unlogged_tables = true
end
```

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type`

Active Record PostgreSQL 어댑터가 마이그레이션이나 스키마에서 `datetime`을 호출할 때 사용할 네이티브 유형을 제어합니다. 구성된 `NATIVE_DATABASE_TYPES` 중 하나와 일치하는 심볼을 사용해야 합니다. 기본값은 `:timestamp`이며, 이는 마이그레이션에서 `t.datetime`이 "timestamp without time zone" 열을 생성합니다.

"timestamp with time zone"을 사용하려면:

```ruby
# config/application.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.datetime_type = :timestamptz
end
```

이를 변경한 경우 `bin/rails db:migrate`를 실행하여 스키마.rb를 다시 빌드해야 합니다.

#### `ActiveRecord::SchemaDumper.ignore_tables`

생성된 스키마 파일에 포함되지 않아야 하는 테이블의 배열을 허용합니다.

#### `ActiveRecord::SchemaDumper.fk_ignore_pattern`

외래 키의 이름이 db/schema.rb에 덤프되어야 하는지 여부를 결정하는 다른 정규식을 설정할 수 있습니다. 기본적으로 `fk_rails_`로 시작하는 외래 키 이름은 데이터베이스 스키마 덤프에 내보내지지 않습니다. 기본값은 `/^fk_rails_[0-9a-f]{10}$/`입니다.

#### `config.active_record.encryption.hash_digest_class`

Active Record Encryption에서 사용하는 다이제스트 알고리즘을 설정합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 시작 버전 | 기본값      |
|-----------------------|---------------------------|
| (원본)            | `OpenSSL::Digest::SHA1`   |
| 7.1                   | `OpenSSL::Digest::SHA256` |

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

SHA-1 다이제스트 클래스를 사용하여 암호화된 기존 데이터를 복호화하는 지원을 활성화합니다. `false`인 경우 `config.active_record.encryption.hash_digest_class`에서 구성된 다이제스트만 지원합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 시작 버전 | 기본값은 |
|-----------------------|----------------------|
| (원본)            | `true`               |
| 7.1                   | `false`              |

### 액션 컨트롤러 구성

`config.action_controller`에는 여러 구성 설정이 포함됩니다:

#### `config.action_controller.asset_host`

자산에 대한 호스트를 설정합니다. 애플리케이션 서버 자체가 아닌 CDNs를 사용하여 자산을 호스팅하는 경우 유용합니다. Action Mailer에 대해 다른 구성이 있는 경우에만 사용해야 합니다. 그렇지 않으면 `config.asset_host`를 사용하세요.

#### `config.action_controller.perform_caching`

애플리케이션이 Action Controller 구성 요소에서 제공하는 캐싱 기능을 수행해야 하는지 여부를 구성합니다. 개발 환경에서는 `false`로, 프로덕션에서는 `true`로 설정합니다. 지정되지 않은 경우 기본값은 `true`입니다.

#### `config.action_controller.default_static_extension`

캐시된 페이지에 사용되는 확장자를 구성합니다. 기본값은 `.html`입니다.
#### `config.action_controller.include_all_helpers`

모든 뷰 헬퍼가 모든 곳에서 사용 가능한지 또는 해당 컨트롤러에 대해 범위가 지정되는지를 구성합니다. `false`로 설정하면 `UsersController`의 일부로 렌더링된 뷰에서만 `UsersHelper` 메서드를 사용할 수 있습니다. `true`로 설정하면 `UsersHelper` 메서드가 모든 곳에서 사용할 수 있습니다. 이 옵션을 `true` 또는 `false`로 명시적으로 설정하지 않은 경우 기본 구성 동작은 모든 뷰 헬퍼가 각 컨트롤러에 대해 사용 가능하도록하는 것입니다.

#### `config.action_controller.logger`

Log4r 또는 기본 Ruby Logger 클래스와 같은 로거를 받아들여 Action Controller에서 정보를 기록하는 데 사용됩니다. 로깅을 비활성화하려면 `nil`로 설정하십시오.

#### `config.action_controller.request_forgery_protection_token`

RequestForgery에 대한 토큰 매개변수 이름을 설정합니다. `protect_from_forgery`를 호출하면 기본적으로 `:authenticity_token`으로 설정됩니다.

#### `config.action_controller.allow_forgery_protection`

CSRF 보호를 활성화 또는 비활성화합니다. 기본적으로 테스트 환경에서는 `false`이고 다른 모든 환경에서는 `true`입니다.

#### `config.action_controller.forgery_protection_origin_check`

HTTP `Origin` 헤더를 사이트의 원본과 비교하여 추가적인 CSRF 방어를 확인할지 여부를 구성합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다.

| 버전에서 시작 | 기본값은 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 5.0                   | `true`               |

#### `config.action_controller.per_form_csrf_tokens`

CSRF 토큰이 생성된 방법/동작에 대해서만 유효한지 구성합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다.

| 버전에서 시작 | 기본값은 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 5.0                   | `true`               |

#### `config.action_controller.default_protect_from_forgery`

`ActionController::Base`에 대한 위조 방지가 추가되는지 여부를 결정합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다.

| 버전에서 시작 | 기본값은 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 5.2                   | `true`               |

#### `config.action_controller.relative_url_root`

Rails가 [하위 디렉토리에 배포](configuring.html#deploy-to-a-subdirectory-relative-url-root)하는 것을 알리기 위해 사용될 수 있습니다. 기본값은 [`config.relative_url_root`](#config-relative-url-root)입니다.

#### `config.action_controller.permit_all_parameters`

대량 할당에 대한 모든 매개변수를 기본적으로 허용하도록 설정합니다. 기본값은 `false`입니다.

#### `config.action_controller.action_on_unpermitted_parameters`

명시적으로 허용되지 않은 매개변수가 발견될 때 동작을 제어합니다. 기본값은 테스트 및 개발 환경에서는 `:log`이고 그 외에는 `false`입니다. 값은 다음과 같습니다.

* 동작을 취하지 않으려면 `false`
* `ActiveSupport::Notifications.instrument` 이벤트를 `unpermitted_parameters.action_controller` 주제로 발생시키고 DEBUG 수준에서 로그를 기록하려면 `:log`
* `ActionController::UnpermittedParameters` 예외를 발생시키려면 `:raise`

#### `config.action_controller.always_permitted_parameters`

기본적으로 허용되는 허용된 매개변수 목록을 설정합니다. 기본값은 `['controller', 'action']`입니다.

#### `config.action_controller.enable_fragment_cache_logging`

다음과 같은 상세한 형식으로 프래그먼트 캐시 읽기 및 쓰기를 로그에 기록할지 여부를 결정합니다.

```
Read fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/d0bdf2974e1ef6d31685c3b392ad0b74 (0.6ms)
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Write fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/3b4e249ac9d168c617e32e84b99218b5 (1.1ms)
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

기본값은 `false`로 설정되어 다음 출력을 생성합니다.

```
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

#### `config.action_controller.raise_on_open_redirects`

허용되지 않은 개방형 리디렉션 발생 시 `ActionController::Redirecting::UnsafeRedirectError`를 발생시킵니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다.

| 버전에서 시작 | 기본값은 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 7.0                   | `true`               |
#### `config.action_controller.log_query_tags_around_actions`

쿼리 태그에 대한 컨트롤러 컨텍스트가 `around_filter`를 통해 자동으로 업데이트되는지 여부를 결정합니다. 기본값은 `true`입니다.

#### `config.action_controller.wrap_parameters_by_default`

[`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)를 기본적으로 json 요청을 래핑하도록 구성합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 7.0                   | `true`               |

#### `ActionController::Base.wrap_parameters`

[`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)를 구성합니다. 이는 최상위 수준이나 개별 컨트롤러에서 호출할 수 있습니다.

#### `config.action_controller.allow_deprecated_parameters_hash_equality`

`ActionController::Parameters#==`의 동작을 `Hash` 인수와 함께 제어합니다. 설정 값은 동등한 `Hash`와 동등한 `ActionController::Parameters` 인스턴스인지 여부를 결정합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `true`               |
| 7.1                   | `false`              |

### Action Dispatch 구성

#### `config.action_dispatch.cookies_serializer`

쿠키에 사용할 직렬화기를 지정합니다. [`config.active_support.message_serializer`](#config-active-support-message-serializer)와 동일한 값을 허용하며, `:hybrid`은 `:json_allow_marshal`의 별칭입니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `:marshal`           |
| 7.0                   | `:json`              |

#### `config.action_dispatch.debug_exception_log_level`

요청 중에 발생한 예외를 로깅할 때 DebugExceptions 미들웨어에서 사용할 로그 레벨을 구성합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `:fatal`             |
| 7.1                   | `:error`             |

#### `config.action_dispatch.default_headers`

각 응답에 기본적으로 설정되는 HTTP 헤더의 해시입니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "1; mode=block",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.0                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.1                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |

#### `config.action_dispatch.default_charset`

모든 렌더에 대한 기본 문자 집합을 지정합니다. 기본값은 `nil`입니다.

#### `config.action_dispatch.tld_length`

응용 프로그램의 최상위 도메인(TLD) 길이를 설정합니다. 기본값은 `1`입니다.

#### `config.action_dispatch.ignore_accept_header`

요청의 accept 헤더를 무시할지 여부를 결정하는 데 사용됩니다. 기본값은 `false`입니다.

#### `config.action_dispatch.x_sendfile_header`

서버별로 사용할 X-Sendfile 헤더를 지정합니다. 이는 서버에서 가속화된 파일 전송에 유용합니다. 예를 들어 Apache의 경우 'X-Sendfile'로 설정할 수 있습니다.

#### `config.action_dispatch.http_auth_salt`

HTTP 인증 salt 값을 설정합니다. 기본값은 `'http authentication'`입니다.

#### `config.action_dispatch.signed_cookie_salt`

서명된 쿠키 salt 값을 설정합니다. 기본값은 `'signed cookie'`입니다.

#### `config.action_dispatch.encrypted_cookie_salt`

암호화된 쿠키 salt 값을 설정합니다. 기본값은 `'encrypted cookie'`입니다.

#### `config.action_dispatch.encrypted_signed_cookie_salt`

서명된 암호화된 쿠키 salt 값을 설정합니다. 기본값은 `'signed encrypted cookie'`입니다.

#### `config.action_dispatch.authenticated_encrypted_cookie_salt`

인증된 암호화된 쿠키 salt 값을 설정합니다. 기본값은 `'authenticated encrypted cookie'`입니다.

#### `config.action_dispatch.encrypted_cookie_cipher`

암호화된 쿠키에 사용할 암호화 방식을 설정합니다. 기본값은 `"aes-256-gcm"`입니다.
#### `config.action_dispatch.signed_cookie_digest`

서명된 쿠키에 사용할 다이제스트를 설정합니다. 기본값은 `"SHA1"`입니다.

#### `config.action_dispatch.cookies_rotations`

암호화된 및 서명된 쿠키에 대해 비밀, 암호화 알고리즘 및 다이제스트를 회전할 수 있도록 합니다.

#### `config.action_dispatch.use_authenticated_cookie_encryption`

서명된 및 암호화된 쿠키가 AES-256-GCM 암호 또는 이전의 AES-256-CBC 암호를 사용하는지를 제어합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| ---- | ------ |
| (원래) | `false` |
| 5.2 | `true` |

#### `config.action_dispatch.use_cookies_with_metadata`

목적 메타데이터가 포함된 쿠키를 작성할 수 있도록 합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| ---- | ------ |
| (원래) | `false` |
| 6.0 | `true` |

#### `config.action_dispatch.perform_deep_munge`

매개변수에 대해 `deep_munge` 메서드를 수행해야하는지를 구성합니다.
자세한 내용은 [보안 가이드](security.html#unsafe-query-generation)를 참조하십시오.
기본값은 `true`입니다.

#### `config.action_dispatch.rescue_responses`

HTTP 상태에 할당되는 예외를 구성합니다. 해시를 허용하며 예외/상태 쌍을 지정할 수 있습니다. 기본적으로 다음과 같이 정의됩니다:

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

구성되지 않은 예외는 500 Internal Server Error로 매핑됩니다.

#### `config.action_dispatch.cookies_same_site_protection`

쿠키를 설정할 때 `SameSite` 속성의 기본값을 구성합니다.
`nil`로 설정하면 `SameSite` 속성이 추가되지 않습니다. 요청에 따라 `SameSite` 속성의 값을 동적으로 구성하려면 proc를 지정할 수 있습니다. 예를 들어:

```ruby
config.action_dispatch.cookies_same_site_protection = ->(request) do
  :strict unless request.user_agent == "TestAgent"
end
```

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| ---- | ------ |
| (원래) | `nil` |
| 6.1 | `:lax` |

#### `config.action_dispatch.ssl_default_redirect_status`

`ActionDispatch::SSL` 미들웨어에서 HTTP에서 HTTPS로의 비-GET/HEAD 요청을 리디렉션할 때 사용되는 기본 HTTP 상태 코드를 구성합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| ---- | ------ |
| (원래) | `307` |
| 6.1 | `308` |

#### `config.action_dispatch.log_rescued_responses`

`rescue_responses`에서 구성된 처리되지 않은 예외를 로깅할 수 있도록 합니다.
기본값은 `true`입니다.

#### `ActionDispatch::Callbacks.before`

요청 전에 실행할 코드 블록을 가져옵니다.

#### `ActionDispatch::Callbacks.after`

요청 후에 실행할 코드 블록을 가져옵니다.

### Action View 구성

`config.action_view`에는 일부 구성 설정이 포함됩니다:

#### `config.action_view.cache_template_loading`

각 요청마다 템플릿을 다시로드해야하는지 여부를 제어합니다. 기본값은 `!config.enable_reloading`입니다.

#### `config.action_view.field_error_proc`

Active Model에서 발생하는 오류를 표시하기 위한 HTML 생성기를 제공합니다. 블록은 Action View 템플릿의 컨텍스트에서 평가됩니다. 기본값은 다음과 같습니다.

```ruby
Proc.new { |html_tag, instance| content_tag :div, html_tag, class: "field_with_errors" }
```

#### `config.action_view.default_form_builder`

Rails에게 기본적으로 사용할 폼 빌더를 알려줍니다. 기본값은
`ActionView::Helpers::FormBuilder`입니다. 초기화 후에 폼 빌더 클래스를 로드하려면 (개발 중에 각 요청마다 다시로드되도록) `String`으로 전달할 수 있습니다.
#### `config.action_view.logger`

Log4r 또는 기본 Ruby Logger 클래스와 일치하는 로거를 허용합니다. 이 로거는 Action View에서 정보를 기록하는 데 사용됩니다. 로깅을 비활성화하려면 `nil`로 설정하십시오.

#### `config.action_view.erb_trim_mode`

ERB에서 사용할 trim 모드를 지정합니다. 기본값은 `'-'`로, `<%= -%>` 또는 `<%= =%>`를 사용할 때 꼬리 공백과 개행을 자르는 기능을 활성화합니다. 자세한 내용은 [Erubis 문서](http://www.kuwata-lab.com/erubis/users-guide.06.html#topics-trimspaces)를 참조하십시오.

#### `config.action_view.frozen_string_literal`

ERB 템플릿을 `# frozen_string_literal: true` 매직 코멘트와 함께 컴파일하여 모든 문자열 리터럴을 고정하고 할당을 절약합니다. 모든 뷰에 대해 이를 활성화하려면 `true`로 설정하십시오.

#### `config.action_view.embed_authenticity_token_in_remote_forms`

`remote: true`를 사용하는 폼에서 `authenticity_token`의 기본 동작을 설정할 수 있습니다. 기본값은 `false`로, 원격 폼에 `authenticity_token`이 포함되지 않습니다. 이는 폼을 프래그먼트 캐싱하는 경우 유용합니다. 원격 폼은 `meta` 태그에서 인증 정보를 가져오므로 자바스크립트를 지원하지 않는 브라우저에서는 포함할 필요가 없습니다. 이 경우 폼 옵션으로 `authenticity_token: true`를 전달하거나 이 구성 설정을 `true`로 설정할 수 있습니다.

#### `config.action_view.prefix_partial_path_with_controller_namespace`

네임스페이스가 있는 컨트롤러에서 렌더링된 템플릿에서 부분 템플릿을 서브디렉토리에서 찾을지 여부를 결정합니다. 예를 들어, `Admin::ArticlesController`라는 컨트롤러가 다음 템플릿을 렌더링하는 경우:

```erb
<%= render @article %>
```

기본 설정은 `true`로, `/admin/articles/_article.erb`의 부분 템플릿을 사용합니다. 값을 `false`로 설정하면 `/articles/_article.erb`가 렌더링되며, 이는 `ArticlesController`와 같은 네임스페이스가 없는 컨트롤러에서 렌더링하는 동작과 동일합니다.

#### `config.action_view.automatically_disable_submit_tag`

`submit_tag`을 클릭할 때 자동으로 비활성화할지 여부를 결정합니다. 기본값은 `true`입니다.

#### `config.action_view.debug_missing_translation`

누락된 번역 키를 `<span>` 태그로 래핑할지 여부를 결정합니다. 기본값은 `true`입니다.

#### `config.action_view.form_with_generates_remote_forms`

`form_with`가 원격 폼을 생성할지 여부를 결정합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 시작 | 기본값 |
| ---------- | ------- |
| 5.1        | `true`  |
| 6.1        | `false` |

#### `config.action_view.form_with_generates_ids`

`form_with`가 입력 요소에 ID를 생성할지 여부를 결정합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 시작 | 기본값 |
| ---------- | ------- |
| (원래)    | `false` |
| 5.2        | `true`  |

#### `config.action_view.default_enforce_utf8`

폼이 UTF-8로 인코딩된 상태로 이전 버전의 인터넷 익스플로러에서 제출되도록 강제하는 숨겨진 태그가 있는 폼을 생성할지 여부를 결정합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 시작 | 기본값 |
| ---------- | ------- |
| (원래)    | `true`  |
| 6.0        | `false` |

#### `config.action_view.image_loading`

`image_tag` 도우미에 의해 렌더링된 `<img>` 태그의 `loading` 속성에 대한 기본값을 지정합니다. 예를 들어, `"lazy"`로 설정하면 `image_tag`에 의해 렌더링된 `<img>` 태그에 `loading="lazy"`가 포함됩니다. 이는 [브라우저가 이미지를 로드하기 위해 뷰포트 근처에 이미지가 나타날 때까지 기다리도록 지시](https://html.spec.whatwg.org/#lazy-loading-attributes)합니다. (이 값을 `image_tag`에 `loading: "eager"`와 같이 전달하여 이미지별로 재정의할 수 있습니다.) 기본값은 `nil`입니다.

#### `config.action_view.image_decoding`

`image_tag` 도우미에 의해 렌더링된 `<img>` 태그의 `decoding` 속성에 대한 기본값을 지정합니다. 기본값은 `nil`입니다.
#### `config.action_view.annotate_rendered_view_with_filenames`

렌더링된 뷰에 템플릿 파일 이름을 주석으로 추가할지 여부를 결정합니다. 기본값은 `false`입니다.

#### `config.action_view.preload_links_header`

`javascript_include_tag` 및 `stylesheet_link_tag`이 자산을 사전로드하는 `Link` 헤더를 생성할지 여부를 결정합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `nil`                |
| 6.1                   | `true`               |

#### `config.action_view.button_to_generates_button_tag`

`button_to`가 첫 번째 인수로 내용이 전달되었는지 또는 블록으로 전달되었는지에 관계없이 `<button>` 요소를 렌더링할지 여부를 결정합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 7.0                   | `true`               |

#### `config.action_view.apply_stylesheet_media_default`

`stylesheet_link_tag`이 `media` 속성의 기본값으로 `screen`을 렌더링할지 여부를 결정합니다. 속성이 제공되지 않은 경우 기본값은 다릅니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `true`               |
| 7.0                   | `false`              |

#### `config.action_view.prepend_content_exfiltration_prevention`

`form_tag` 및 `button_to` 도우미가 브라우저에 안전하지만 기술적으로 잘못된 HTML로 시작하는 HTML 태그를 생성하여 이전에 닫히지 않은 태그로부터 캡처할 수 없는 내용을 보장할지 여부를 결정합니다. 기본값은 `false`입니다.

#### `config.action_view.sanitizer_vendor`

`Action View`에서 사용하는 HTML 살균기 세트를 `ActionView::Helpers::SanitizeHelper.sanitizer_vendor`를 설정하여 구성합니다. 기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 | 구문 분석 마크업 |
|-----------------------|--------------------------------------|------------------------|
| (원본)            | `Rails::HTML4::Sanitizer`            | HTML4                  |
| 7.1                   | `Rails::HTML5::Sanitizer` (참고) | HTML5                  |

참고: `Rails::HTML5::Sanitizer`는 JRuby에서 지원되지 않으므로 JRuby 플랫폼에서 Rails는 `Rails::HTML4::Sanitizer`를 사용하도록 되돌립니다.

### Action Mailbox 구성

`config.action_mailbox`는 다음 구성 옵션을 제공합니다:

#### `config.action_mailbox.logger`

Action Mailbox에서 사용하는 로거를 포함합니다. Log4r 인터페이스 또는 기본 Ruby Logger 클래스와 일치하는 로거를 허용합니다. 기본값은 `Rails.logger`입니다.

```ruby
config.action_mailbox.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.action_mailbox.incinerate_after`

`ActionMailbox::InboundEmail` 레코드 처리 후 얼마나 오래 지속되어야 하는지를 나타내는 `ActiveSupport::Duration`을 허용합니다. 기본값은 `30.days`입니다.

```ruby
# 처리 후 14일 이내에 수신 이메일을 삭제합니다.
config.action_mailbox.incinerate_after = 14.days
```

#### `config.action_mailbox.queues.incineration`

소각 작업에 사용할 Active Job 큐를 나타내는 기호를 허용합니다. 이 옵션이 `nil`인 경우 소각 작업은 기본 Active Job 큐로 전송됩니다 (`config.active_job.default_queue_name` 참조).

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `:action_mailbox_incineration` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.queues.routing`

라우팅 작업에 사용할 Active Job 큐를 나타내는 기호를 허용합니다. 이 옵션이 `nil`인 경우 라우팅 작업은 기본 Active Job 큐로 전송됩니다 (`config.active_job.default_queue_name` 참조).

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `:action_mailbox_routing` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.storage_service`
이메일 업로드에 사용할 Active Storage 서비스를 나타내는 심볼을 받습니다. 이 옵션이 `nil`인 경우, 이메일은 기본 Active Storage 서비스에 업로드됩니다 (`config.active_storage.service` 참조).

### Action Mailer 구성

`config.action_mailer`에는 다음과 같은 설정이 있습니다:

#### `config.action_mailer.asset_host`

자산의 호스트를 설정합니다. 응용 프로그램 서버 자체가 아닌 CDN을 사용하여 자산을 호스팅하는 경우 유용합니다. 이 설정은 Action Controller에 대해 다른 구성이 있는 경우에만 사용해야 합니다. 그렇지 않으면 `config.asset_host`를 사용하세요.

#### `config.action_mailer.logger`

Log4r 인터페이스를 준수하는 로거 또는 기본 Ruby Logger 클래스를 받아 Action Mailer에서 정보를 기록하는 데 사용됩니다. 기록을 비활성화하려면 `nil`로 설정하세요.

#### `config.action_mailer.smtp_settings`

`:smtp` 전달 방법에 대한 자세한 구성을 허용합니다. 옵션의 해시를 받으며, 다음 옵션 중 하나를 포함할 수 있습니다:

* `:address` - 원격 메일 서버를 사용할 수 있도록 합니다. 기본 "localhost" 설정에서 변경하세요.
* `:port` - 메일 서버가 25번 포트에서 실행되지 않는 경우 변경할 수 있습니다.
* `:domain` - HELO 도메인을 지정해야 하는 경우 여기에서 설정하세요.
* `:user_name` - 메일 서버가 인증을 요구하는 경우 이 설정에 사용자 이름을 설정하세요.
* `:password` - 메일 서버가 인증을 요구하는 경우 이 설정에 암호를 설정하세요.
* `:authentication` - 메일 서버가 인증을 요구하는 경우 여기에 인증 유형을 지정해야 합니다. 이는 `:plain`, `:login`, `:cram_md5` 중 하나의 심볼입니다.
* `:enable_starttls` - SMTP 서버에 연결할 때 STARTTLS를 사용하고 지원되지 않으면 실패합니다. 기본값은 `false`입니다.
* `:enable_starttls_auto` - SMTP 서버에서 STARTTLS가 활성화되어 있는지 감지하고 사용을 시작합니다. 기본값은 `true`입니다.
* `:openssl_verify_mode` - TLS를 사용할 때 OpenSSL이 인증서를 확인하는 방법을 설정할 수 있습니다. 자체 서명 및/또는 와일드카드 인증서를 유효성 검사해야 하는 경우 유용합니다. OpenSSL 검증 상수 `:none` 또는 `:peer` 또는 상수 직접 `OpenSSL::SSL::VERIFY_NONE` 또는 `OpenSSL::SSL::VERIFY_PEER` 중 하나일 수 있습니다.
* `:ssl/:tls` - SMTP 연결이 SMTP/TLS (SMTPS: 직접 TLS 연결을 통한 SMTP)를 사용하도록 설정합니다.
* `:open_timeout` - 연결을 열려고 시도하는 동안 기다리는 시간(초)입니다.
* `:read_timeout` - 읽기(2) 호출을 타임아웃하는 데 기다리는 시간(초)입니다.

또한 [Mail::SMTP가 존중하는 구성 옵션](https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/smtp.rb)을 전달할 수 있습니다.

#### `config.action_mailer.smtp_timeout`

`:smtp` 전달 방법에 대한 `:open_timeout` 및 `:read_timeout` 값을 구성하는 데 사용됩니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| ---- | ------ |
| (원본) | `nil` |
| 7.0 | `5` |

#### `config.action_mailer.sendmail_settings`

`sendmail` 전달 방법에 대한 자세한 구성을 허용합니다. 옵션의 해시를 받으며, 다음 옵션 중 하나를 포함할 수 있습니다:

* `:location` - sendmail 실행 파일의 위치입니다. 기본값은 `/usr/sbin/sendmail`입니다.
* `:arguments` - 명령줄 인수입니다. 기본값은 `%w[ -i ]`입니다.

#### `config.action_mailer.raise_delivery_errors`

이메일 전송이 완료되지 않을 경우 오류를 발생시킬지 여부를 지정합니다. 기본값은 `true`입니다.
#### `config.action_mailer.delivery_method`

배송 방법을 정의하며 기본값은 `:smtp`입니다. 자세한 내용은 [Action Mailer 가이드의 구성 섹션](action_mailer_basics.html#action-mailer-configuration)을 참조하십시오.

#### `config.action_mailer.perform_deliveries`

메일을 실제로 전달할지 여부를 지정하며 기본값은 `true`입니다. 테스트를 위해 `false`로 설정하는 것이 편리할 수 있습니다.

#### `config.action_mailer.default_options`

Action Mailer 기본값을 구성합니다. 모든 메일러에 대해 `from` 또는 `reply_to`와 같은 옵션을 설정하는 데 사용합니다. 이들은 기본값으로 설정됩니다:

```ruby
mime_version:  "1.0",
charset:       "UTF-8",
content_type: "text/plain",
parts_order:  ["text/plain", "text/enriched", "text/html"]
```

해시를 할당하여 추가 옵션을 설정할 수 있습니다:

```ruby
config.action_mailer.default_options = {
  from: "noreply@example.com"
}
```

#### `config.action_mailer.observers`

메일이 전달될 때 알림을 받을 옵저버를 등록합니다.

```ruby
config.action_mailer.observers = ["MailObserver"]
```

#### `config.action_mailer.interceptors`

메일이 전송되기 전에 호출될 인터셉터를 등록합니다.

```ruby
config.action_mailer.interceptors = ["MailInterceptor"]
```

#### `config.action_mailer.preview_interceptors`

메일이 미리보기되기 전에 호출될 인터셉터를 등록합니다.

```ruby
config.action_mailer.preview_interceptors = ["MyPreviewMailInterceptor"]
```

#### `config.action_mailer.preview_paths`

메일러 미리보기의 위치를 지정합니다. 이 구성 옵션에 경로를 추가하면 해당 경로가 메일러 미리보기를 검색하는 데 사용됩니다.

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

#### `config.action_mailer.show_previews`

메일러 미리보기를 활성화 또는 비활성화합니다. 기본적으로 개발 환경에서는 `true`입니다.

```ruby
config.action_mailer.show_previews = false
```

#### `config.action_mailer.perform_caching`

메일러 템플릿이 조각 캐싱을 수행할지 여부를 지정합니다. 지정되지 않으면 기본값은 `true`입니다.

#### `config.action_mailer.deliver_later_queue_name`

기본 전달 작업에 사용할 Active Job 큐를 지정합니다 (`config.action_mailer.delivery_job` 참조). 이 옵션이 `nil`로 설정되면 전달 작업은 기본 Active Job 큐로 전송됩니다 (`config.active_job.default_queue_name` 참조).

메일러 클래스는 다른 큐를 사용하도록 이를 재정의할 수 있습니다. 이는 기본 전달 작업을 사용할 때만 적용됩니다. 메일러가 사용자 정의 작업을 사용하는 경우 해당 작업의 큐가 사용됩니다.

지정된 큐를 처리하기 위해 Active Job 어댑터가 구성되어 있는지 확인하십시오. 그렇지 않으면 전달 작업이 무시될 수 있습니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `:mailers`           |
| 6.1                   | `nil`                |

#### `config.action_mailer.delivery_job`

메일 전송을 위한 전달 작업을 지정합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `ActionMailer::MailDeliveryJob` |
| 6.0                   | `"ActionMailer::MailDeliveryJob"` |

### Active Support 구성

Active Support에서 사용할 수 있는 몇 가지 구성 옵션이 있습니다:

#### `config.active_support.bare`

Rails 부팅 시 `active_support/all`의 로딩을 활성화 또는 비활성화합니다. 기본값은 `nil`이며, 이는 `active_support/all`이 로드됨을 의미합니다.

#### `config.active_support.test_order`

테스트 케이스의 실행 순서를 설정합니다. 가능한 값은 `:random`과 `:sorted`입니다. 기본값은 `:random`입니다.

#### `config.active_support.escape_html_entities_in_json`

JSON 직렬화에서 HTML 엔티티의 이스케이프를 활성화 또는 비활성화합니다. 기본값은 `true`입니다.

#### `config.active_support.use_standard_json_time_format`

날짜를 ISO 8601 형식으로 직렬화하는 것을 활성화 또는 비활성화합니다. 기본값은 `true`입니다.

#### `config.active_support.time_precision`

JSON 인코딩된 시간 값의 정밀도를 설정합니다. 기본값은 `3`입니다.

#### `config.active_support.hash_digest_class`

ETag 헤더와 같은 민감하지 않은 다이제스트를 생성하는 데 사용할 다이제스트 클래스를 구성할 수 있습니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:
| 버전별 시작 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `OpenSSL::Digest::MD5` |
| 5.2                   | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.key_generator_hash_digest_class`

설정된 비밀 기반으로부터 비밀을 유도하기 위해 사용할 다이제스트 클래스를 구성할 수 있습니다. 예를 들어 암호화된 쿠키에 사용됩니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전별 시작 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.use_authenticated_message_encryption`

메시지를 암호화하는 데 사용되는 기본 암호 방식으로 AES-256-CBC 대신 AES-256-GCM 인증 암호를 사용할지 여부를 지정합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전별 시작 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 5.2                   | `true`               |

#### `config.active_support.message_serializer`

[`ActiveSupport::MessageEncryptor`][] 및 [`ActiveSupport::MessageVerifier`][] 인스턴스에서 사용되는 기본 직렬화기를 지정합니다. 직렬화기 간의 마이그레이션을 쉽게하기 위해 제공된 직렬화기에는 여러 역직렬화 형식을 지원하기 위한 대체 메커니즘이 포함되어 있습니다:

| 직렬화기 | 직렬화 및 역직렬화 | 대체 역직렬화 |
| ---------- | ------------------------- | -------------------- |
| `:marshal` | `Marshal` | `ActiveSupport::JSON`, `ActiveSupport::MessagePack` |
| `:json` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack` |
| `:json_allow_marshal` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack`, `Marshal` |
| `:message_pack` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON` |
| `:message_pack_allow_marshal` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON`, `Marshal` |

경고: `Marshal`은 메시지 서명 비밀이 유출된 경우 역직렬화 공격의 잠재적인 벡터입니다. _가능하면 `Marshal`를 지원하지 않는 직렬화기를 선택하십시오._

정보: `:message_pack` 및 `:message_pack_allow_marshal` 직렬화기는 `Symbol`과 같은 JSON에서 지원되지 않는 일부 Ruby 유형의 왕복 여행을 지원할 수 있습니다. 또한 성능 향상과 더 작은 페이로드 크기를 제공할 수 있습니다. 그러나 [`msgpack` gem](https://rubygems.org/gems/msgpack)이 필요합니다.

위의 각 직렬화기는 대체 역직렬화 형식으로 되돌아갈 때 [`message_serializer_fallback.active_support`][] 이벤트 알림을 발생시킵니다. 이를 통해 이러한 대체가 얼마나 자주 발생하는지 추적할 수 있습니다.

또는 `dump` 및 `load` 메서드에 응답하는 임의의 직렬화기 객체를 지정할 수 있습니다. 예를 들어:

```ruby
config.active_job.message_serializer = YAML
```

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전별 시작 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `:marshal`           |
| 7.1                   | `:json_allow_marshal` |


#### `config.active_support.use_message_serializer_for_metadata`

`true`로 설정하면 메시지 데이터와 메타데이터를 함께 직렬화하는 성능 최적화가 활성화됩니다. 이렇게 하면 메시지 형식이 변경되므로 이 최적화가 활성화되었는지 여부에 관계없이 이전 (< 7.1) 버전의 Rails에서는 이 방식으로 직렬화된 메시지를 읽을 수 없습니다. 그러나 이전 형식을 사용하는 메시지는 여전히 읽을 수 있습니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전별 시작 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_support.cache_format_version`

캐시에 사용할 직렬화 형식을 지정합니다. 가능한 값은 `6.1`, `7.0` 및 `7.1`입니다.

`6.1`, `7.0` 및 `7.1` 형식은 모두 기본 코더로 `Marshal`을 사용하지만, `7.0`은 캐시 항목에 대해 더 효율적인 표현을 사용하고, `7.1`은 뷰 프래그먼트와 같은 베어 문자열 값에 대한 추가적인 최적화를 포함합니다.
모든 형식은 역방향 및 순방향 호환성을 가지며, 즉 한 형식으로 작성된 캐시 항목은 다른 형식을 사용할 때 읽을 수 있습니다. 이 동작은 전체 캐시를 무효화하지 않고 형식 간 이동을 쉽게 만듭니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값은 |
| --------------------- | -------------------- |
| (원본)            | `6.1`                |
| 7.0                   | `7.0`                |
| 7.1                   | `7.1`                |

#### `config.active_support.deprecation`

폐기 경고의 동작을 구성합니다. 옵션은 `:raise`, `:stderr`, `:log`, `:notify`, `:silence`입니다.

기본 생성된 `config/environments` 파일에서 개발 환경에는 `:log`로 설정되고 테스트에는 `:stderr`로 설정되며, 프로덕션에서는 [`config.active_support.report_deprecations`](#config-active-support-report-deprecations)를 선호하여 생략됩니다.

#### `config.active_support.disallowed_deprecation`

허용되지 않는 폐기 경고의 동작을 구성합니다. 옵션은 `:raise`, `:stderr`, `:log`, `:notify`, `:silence`입니다.

기본 생성된 `config/environments` 파일에서 개발 및 테스트에는 `:raise`로 설정되며, 프로덕션에서는 [`config.active_support.report_deprecations`](#config-active-support-report-deprecations)를 선호하여 생략됩니다.

#### `config.active_support.disallowed_deprecation_warnings`

응용 프로그램에서 허용되지 않는 폐기 경고를 구성합니다. 이를 통해 특정 폐기 항목을 강제 실패로 처리할 수 있습니다.

#### `config.active_support.report_deprecations`

`false`로 설정하면 [응용 프로그램의 폐기 경고](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators)에서 허용되지 않는 폐기 경고를 포함하여 모든 폐기 경고가 비활성화됩니다. 이는 Rails 및 기타 젬에서 deprecator를 deprecators 컬렉션에 추가할 수 있지만 ActiveSupport::Deprecation에서 발생하는 모든 폐기 경고를 방지하지 않을 수 있습니다.

기본 생성된 `config/environments` 파일에서 프로덕션에 대해 `false`로 설정됩니다.

#### `config.active_support.isolation_level`

Rails 내부 상태의 지역성을 구성합니다. 펄스 기반 서버 또는 작업 프로세서 (예: `falcon`)를 사용하는 경우 `:fiber`로 설정해야 합니다. 그렇지 않으면 `:thread` 지역성을 사용하는 것이 가장 좋습니다. 기본값은 `:thread`입니다.

#### `config.active_support.executor_around_test_case`

테스트 스위트가 테스트 케이스 주위에 `Rails.application.executor.wrap`을 호출하도록 구성합니다.
이렇게 하면 테스트 케이스가 실제 요청이나 작업과 유사하게 동작합니다.
일반적으로 테스트에서 비활성화된 여러 기능, 예를 들어 Active Record 쿼리 캐시
및 비동기 쿼리가 활성화됩니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값은 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 7.0                   | `true`               |

#### `ActiveSupport::Logger.silencer`

블록에서 로깅을 음소거하는 기능을 비활성화하기 위해 `false`로 설정됩니다. 기본값은 `true`입니다.

#### `ActiveSupport::Cache::Store.logger`

캐시 저장소 작업 내에서 사용할 로거를 지정합니다.

#### `ActiveSupport.to_time_preserves_timezone`

`to_time` 메서드가 수신자의 UTC 오프셋을 보존하는지 여부를 지정합니다. `false`인 경우 `to_time` 메서드는 로컬 시스템 UTC 오프셋으로 변환됩니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값은 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 5.0                   | `true`               |

#### `ActiveSupport.utc_to_local_returns_utc_offset_times`

`ActiveSupport::TimeZone.utc_to_local`을 UTC 시간이 아닌 UTC 오프셋을 포함한 시간으로 반환하도록 구성합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전부터 | 기본값은 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 6.1                   | `true`               |
#### `config.active_support.raise_on_invalid_cache_expiration_time`

`Rails.cache`의 `fetch` 또는 `write`에 유효하지 않은 `expires_at` 또는 `expires_in` 시간이 제공되면 `ArgumentError`를 발생시킬지 여부를 지정합니다.

옵션은 `true`와 `false`입니다. `false`인 경우 예외는 `handled`로 보고되고 로그에 기록됩니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 7.1                   | `true`               |

### Active Job 구성

`config.active_job`은 다음 구성 옵션을 제공합니다:

#### `config.active_job.queue_adapter`

큐 백엔드에 대한 어댑터를 설정합니다. 기본 어댑터는 `:async`입니다. 내장된 어댑터의 최신 목록은 [ActiveJob::QueueAdapters API 문서](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html)를 참조하십시오.

```ruby
# 어댑터의 gem이 Gemfile에 포함되어 있는지 확인하고
# 어댑터의 특정 설치 및 배포 지침을 따르십시오.
config.active_job.queue_adapter = :sidekiq
```

#### `config.active_job.default_queue_name`

기본 큐 이름을 변경하는 데 사용할 수 있습니다. 기본값은 `"default"`입니다.

```ruby
config.active_job.default_queue_name = :medium_priority
```

#### `config.active_job.queue_name_prefix`

모든 작업에 대한 선택적이고 비어 있지 않은 큐 이름 접두사를 설정할 수 있습니다. 기본값은 비어 있고 사용되지 않습니다.

다음 구성은 프로덕션에서 실행될 때 주어진 작업을 `production_high_priority` 큐에 대기시킵니다:

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

기본값은 `'_'`입니다. `queue_name_prefix`가 설정된 경우 `queue_name_delimiter`는 접두사와 접두사가 없는 큐 이름을 결합합니다.

다음 구성은 주어진 작업을 `video_server.low_priority` 큐에 대기시킵니다:

```ruby
# delimiter를 사용하려면 prefix를 설정해야 합니다.
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

Active Job에서 정보를 기록하는 데 사용되는 Log4r 또는 기본 Ruby Logger 클래스와 일치하는 로거를 받아들입니다. Active Job 클래스 또는 Active Job 인스턴스에서 `logger`를 호출하여 이 로거를 검색할 수 있습니다. 로깅을 비활성화하려면 `nil`로 설정하십시오.

#### `config.active_job.custom_serializers`

사용자 정의 인수 직렬화기를 설정할 수 있습니다. 기본값은 `[]`입니다.

#### `config.active_job.log_arguments`

작업의 인수를 로그에 기록할지 여부를 제어합니다. 기본값은 `true`입니다.

#### `config.active_job.verbose_enqueue_logs`

백그라운드 작업을 예약하는 메서드의 소스 위치가 관련 예약 로그 라인 아래에 기록되어야 하는지 여부를 지정합니다. 기본적으로 개발 환경에서는 `true`이고 다른 모든 환경에서는 `false`입니다.

#### `config.active_job.retry_jitter`

실패한 작업을 재시도할 때 계산된 지연 시간에 적용되는 "jitter" (랜덤 변동)의 양을 제어합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `0.0`                |
| 6.1                   | `0.15`               |

#### `config.active_job.log_query_tags_around_perform`

쿼리 태그에 대한 작업 컨텍스트가 자동으로 `around_perform`를 통해 업데이트되는지 여부를 결정합니다. 기본값은 `true`입니다.

#### `config.active_job.use_big_decimal_serializer`

라운드트립을 보장하는 새로운 `BigDecimal` 인수 직렬화기를 활성화합니다. 이 직렬화기가 없으면 일부 큐 어댑터는 `BigDecimal` 인수를 단순한 (라운드트립이 아닌) 문자열로 직렬화할 수 있습니다.

경고: 여러 복제본을 가진 응용 프로그램을 배포할 때 이 설정을 사용하면 이전 (Rails 7.1 이전) 복제본은 `BigDecimal` 인수를 이 직렬화기에서 역직렬화할 수 없습니다. 따라서 이 설정은 모든 복제본이 성공적으로 Rails 7.1로 업그레이드된 후에만 활성화해야 합니다.
기본값은 `config.load_defaults` 대상 버전에 따라 달라집니다:

| 버전별 시작 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 7.1                   | `true`               |

### Action Cable 구성

#### `config.action_cable.url`

Action Cable 서버를 호스팅하는 URL에 대한 문자열을 허용합니다. 주요 응용 프로그램과 분리된 Action Cable 서버를 실행하는 경우 이 옵션을 사용합니다.

#### `config.action_cable.mount_path`

Action Cable을 마운트할 위치에 대한 문자열을 허용합니다. 기본값은 `/cable`입니다. 일반적인 Rails 서버에 Action Cable을 마운트하지 않으려면 이 값을 nil로 설정할 수 있습니다.

자세한 구성 옵션은 [Action Cable 개요](action_cable_overview.html#configuration)에서 찾을 수 있습니다.

#### `config.action_cable.precompile_assets`

Action Cable 자산이 자산 파이프라인 사전 컴파일에 추가되어야 하는지 여부를 결정합니다. Sprockets를 사용하지 않는 경우 영향을 미치지 않습니다. 기본값은 `true`입니다.

### Active Storage 구성

`config.active_storage`은 다음 구성 옵션을 제공합니다:

#### `config.active_storage.variant_processor`

MiniMagick 또는 ruby-vips를 사용하여 변형 및 blob 분석을 수행할지 여부를 지정하는 `:mini_magick` 또는 `:vips` 심볼을 허용합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 달라집니다:

| 버전별 시작 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `:mini_magick`       |
| 7.0                   | `:vips`              |

#### `config.active_storage.analyzers`

Active Storage blobs에 대해 사용 가능한 분석기를 나타내는 클래스 배열을 허용합니다.
기본적으로 다음과 같이 정의됩니다:

```ruby
config.active_storage.analyzers = [ActiveStorage::Analyzer::ImageAnalyzer::Vips, ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick, ActiveStorage::Analyzer::VideoAnalyzer, ActiveStorage::Analyzer::AudioAnalyzer]
```

이미지 분석기는 이미지 blob의 너비와 높이를 추출할 수 있으며, 비디오 분석기는 비디오 blob의 너비, 높이, 지속 시간, 각도, 종횡비, 비디오/오디오 채널의 존재/부재를 추출할 수 있으며, 오디오 분석기는 오디오 blob의 지속 시간과 비트 전송률을 추출할 수 있습니다.

#### `config.active_storage.previewers`

Active Storage blobs에서 사용 가능한 이미지 미리보기기를 나타내는 클래스 배열을 허용합니다.
기본적으로 다음과 같이 정의됩니다:

```ruby
config.active_storage.previewers = [ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer]
```

`PopplerPDFPreviewer`와 `MuPDFPreviewer`는 PDF blob의 첫 번째 페이지에서 썸네일을 생성할 수 있으며, `VideoPreviewer`는 비디오 blob의 관련 프레임에서 썸네일을 생성할 수 있습니다.

#### `config.active_storage.paths`

미리보기기/분석기 명령의 위치를 나타내는 옵션 해시를 허용합니다. 기본값은 `{}`이며, 이는 명령이 기본 경로에서 찾아질 것을 의미합니다. 다음 옵션 중 하나를 포함할 수 있습니다:

* `:ffprobe` - ffprobe 실행 파일의 위치.
* `:mutool` - mutool 실행 파일의 위치.
* `:ffmpeg` - ffmpeg 실행 파일의 위치.

```ruby
config.active_storage.paths[:ffprobe] = '/usr/local/bin/ffprobe'
```

#### `config.active_storage.variable_content_types`

Active Storage가 변형 프로세서를 통해 변환할 수 있는 콘텐츠 유형을 나타내는 문자열 배열을 허용합니다.
기본적으로 다음과 같이 정의됩니다:

```ruby
config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/bmp image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)
```

#### `config.active_storage.web_image_content_types`

변형을 PNG 형식으로 변환하지 않고 처리할 수 있는 웹 이미지 콘텐츠 유형으로 간주되는 문자열 배열을 허용합니다.
`WebP` 또는 `AVIF` 변형을 응용 프로그램에서 사용하려면 이 배열에 `image/webp` 또는 `image/avif`를 추가할 수 있습니다.
기본적으로 다음과 같이 정의됩니다:
```ruby
config.active_storage.web_image_content_types = %w(image/png image/jpeg image/gif)
```

#### `config.active_storage.content_types_to_serve_as_binary`

Active Storage가 인라인이 아닌 첨부 파일로 항상 제공할 콘텐츠 유형을 나타내는 문자열 배열을 허용합니다.
기본적으로 다음과 같이 정의됩니다:

```ruby
config.active_storage.content_types_to_serve_as_binary = %w(text/html image/svg+xml application/postscript application/x-shockwave-flash text/xml application/xml application/xhtml+xml application/mathml+xml text/cache-manifest)
```

#### `config.active_storage.content_types_allowed_inline`

Active Storage가 인라인으로 제공하는 콘텐츠 유형을 나타내는 문자열 배열을 허용합니다.
기본적으로 다음과 같이 정의됩니다:

```ruby
config.active_storage.content_types_allowed_inline` = %w(image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon application/pdf)
```

#### `config.active_storage.queues.analysis`

분석 작업에 사용할 Active Job 큐를 나타내는 심볼을 허용합니다. 이 옵션이 `nil`인 경우, 분석 작업은 기본 Active Job 큐로 전송됩니다 (`config.active_job.default_queue_name` 참조).

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 시작 | 기본값 |
| --------------------- | -------------------- |
| 6.0                   | `:active_storage_analysis` |
| 6.1                   | `nil`                |

#### `config.active_storage.queues.purge`

삭제 작업에 사용할 Active Job 큐를 나타내는 심볼을 허용합니다. 이 옵션이 `nil`인 경우, 삭제 작업은 기본 Active Job 큐로 전송됩니다 (`config.active_job.default_queue_name` 참조).

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 시작 | 기본값 |
| --------------------- | -------------------- |
| 6.0                   | `:active_storage_purge` |
| 6.1                   | `nil`                |

#### `config.active_storage.queues.mirror`

직접 업로드 미러링 작업에 사용할 Active Job 큐를 나타내는 심볼을 허용합니다. 이 옵션이 `nil`인 경우, 미러링 작업은 기본 Active Job 큐로 전송됩니다 (`config.active_job.default_queue_name` 참조). 기본값은 `nil`입니다.

#### `config.active_storage.logger`

Active Storage에서 사용할 로거를 설정하는 데 사용할 수 있습니다. Log4r 인터페이스 또는 기본 Ruby Logger 클래스를 준수하는 로거를 허용합니다.

```ruby
config.active_storage.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.active_storage.service_urls_expire_in`

다음에서 생성된 URL의 기본 만료 시간을 결정합니다:

* `ActiveStorage::Blob#url`
* `ActiveStorage::Blob#service_url_for_direct_upload`
* `ActiveStorage::Variant#url`

기본값은 5분입니다.

#### `config.active_storage.urls_expire_in`

Active Storage에서 생성된 Rails 애플리케이션의 URL의 기본 만료 시간을 결정합니다. 기본값은 `nil`입니다.

#### `config.active_storage.routes_prefix`

Active Storage가 제공하는 라우트의 라우트 접두사를 설정하는 데 사용할 수 있습니다. 생성된 라우트 앞에 추가 될 문자열을 허용합니다.

```ruby
config.active_storage.routes_prefix = '/files'
```

기본값은 `/rails/active_storage`입니다.

#### `config.active_storage.track_variants`

변형이 데이터베이스에 기록되는지 여부를 결정합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 시작 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `false`              |
| 6.1                   | `true`               |

#### `config.active_storage.draw_routes`

Active Storage 라우트 생성을 토글하는 데 사용할 수 있습니다. 기본값은 `true`입니다.

#### `config.active_storage.resolve_model_to_route`

Active Storage 파일이 전달되는 방식을 전역적으로 변경하는 데 사용할 수 있습니다.

허용되는 값은 다음과 같습니다:

* `:rails_storage_redirect`: 서명 된 단기 서비스 URL로 리디렉션합니다.
* `:rails_storage_proxy`: 파일을 다운로드하여 프록시합니다.

기본값은 `:rails_storage_redirect`입니다.

#### `config.active_storage.video_preview_arguments`

ffmpeg이 비디오 미리보기 이미지를 생성하는 방식을 변경하는 데 사용할 수 있습니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다:

| 버전 시작 | 기본값 |
| --------------------- | -------------------- |
| (원본)            | `"-y -vframes 1 -f image2"` |
| 7.0                   | `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015)"`<sup><mark><strong><em>1</em></strong></mark></sup> <br> `+ ",loop=loop=-1:size=2,trim=start_frame=1'"`<sup><mark><strong><em>2</em></strong></mark></sup><br> `+ " -frames:v 1 -f image2"` <br><br> <ol><li>첫 번째 비디오 프레임, 키 프레임 및 장면 변경 임계값을 충족하는 프레임을 선택합니다.</li> <li>기준을 충족하는 다른 프레임이 없을 때 첫 번째 (하나 또는) 두 개의 선택한 프레임을 루프하고 첫 번째 루프된 프레임을 삭제하여 첫 번째 비디오 프레임을 대체합니다.</li></ol> |
#### `config.active_storage.multiple_file_field_include_hidden`

Rails 7.1 이상에서는 Active Storage의 `has_many_attached` 관계가 현재 컬렉션을 _추가_하는 대신 _대체_하도록 기본 설정됩니다. 따라서 _빈_ 컬렉션을 제출하기 위해 `multiple_file_field_include_hidden`이 `true`인 경우 [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) 헬퍼는 [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) 헬퍼가 렌더링하는 보조 필드와 유사한 보조 숨은 필드를 렌더링합니다.

기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다.

| 시작 버전 | 기본값 |
| --------- | ------ |
| (원래)    | `false` |
| 7.0       | `true`  |

#### `config.active_storage.precompile_assets`

Active Storage 자산이 자산 파이프라인 사전 컴파일에 추가되어야 하는지 여부를 결정합니다. Sprockets를 사용하지 않는 경우에는 영향을 주지 않습니다. 기본값은 `true`입니다.

### Action Text 구성

#### `config.action_text.attachment_tag_name`

첨부 파일을 래핑하는 데 사용되는 HTML 태그에 대한 문자열을 허용합니다. 기본값은 `"action-text-attachment"`입니다.

#### `config.action_text.sanitizer_vendor`

`Action Text`에서 사용하는 HTML 샌디타이저를 구성하기 위해 `ActionText::ContentHelper.sanitizer`를 공급 업체의 `.safe_list_sanitizer` 메서드에서 반환된 클래스의 인스턴스로 설정합니다. 기본값은 `config.load_defaults` 대상 버전에 따라 다릅니다.

| 시작 버전 | 기본값 | 구문 분석 마크업 |
| --------- | ------ | ---------------- |
| (원래)    | `Rails::HTML4::Sanitizer` | HTML4 |
| 7.1       | `Rails::HTML5::Sanitizer` (참고) | HTML5 |

참고: `Rails::HTML5::Sanitizer`는 JRuby에서 지원되지 않으므로 JRuby 플랫폼에서는 Rails가 `Rails::HTML4::Sanitizer`를 사용하도록 대체됩니다.

### 데이터베이스 구성

거의 모든 Rails 애플리케이션은 데이터베이스와 상호 작용합니다. 데이터베이스에 연결하려면 환경 변수 `ENV['DATABASE_URL']`을 설정하거나 `config/database.yml`이라는 구성 파일을 사용할 수 있습니다.

`config/database.yml` 파일을 사용하여 데이터베이스에 액세스하는 데 필요한 모든 정보를 지정할 수 있습니다.

```yaml
development:
  adapter: postgresql
  database: blog_development
  pool: 5
```

이는 `postgresql` 어댑터를 사용하여 `blog_development`라는 이름의 데이터베이스에 연결합니다. 이와 동일한 정보를 URL로 저장하고 다음과 같이 환경 변수를 통해 제공할 수도 있습니다.

```ruby
ENV['DATABASE_URL'] # => "postgresql://localhost/blog_development?pool=5"
```

`config/database.yml` 파일에는 Rails가 기본적으로 실행할 수 있는 세 가지 다른 환경을 위한 섹션이 있습니다.

* `development` 환경은 애플리케이션과 수동으로 상호 작용하는 개발/로컬 컴퓨터에서 사용됩니다.
* `test` 환경은 자동화된 테스트를 실행할 때 사용됩니다.
* `production` 환경은 애플리케이션을 세상에 배포할 때 사용됩니다.

원한다면 `config/database.yml` 내부에 URL을 수동으로 지정할 수 있습니다.

```yaml
development:
  url: postgresql://localhost/blog_development?pool=5
```

`config/database.yml` 파일에는 ERB 태그 `<%= %>`를 포함할 수 있습니다. 태그 내의 모든 내용은 Ruby 코드로 평가됩니다. 이를 사용하여 환경 변수에서 데이터를 가져오거나 필요한 연결 정보를 생성하기 위해 계산을 수행할 수 있습니다.


팁: 데이터베이스 구성을 수동으로 업데이트할 필요는 없습니다. 애플리케이션 생성기의 옵션을 살펴보면 `--database`라는 옵션이 있는 것을 알 수 있습니다. 이 옵션을 사용하면 가장 많이 사용되는 관계형 데이터베이스 목록에서 어댑터를 선택할 수 있습니다. 심지어 생성기를 반복해서 실행할 수도 있습니다. `cd .. && rails new blog --database=mysql`을 실행하면 `config/database.yml` 파일을 덮어쓸 것인지 확인할 때 애플리케이션이 SQLite 대신 MySQL로 구성됩니다. 일반적인 데이터베이스 연결의 자세한 예제는 아래에 나와 있습니다.
### 연결 우선순위

`config/database.yml`을 사용하거나 환경 변수를 사용하여 연결을 구성하는 두 가지 방법이 있기 때문에 상호작용하는 방법을 이해하는 것이 중요합니다.

`config/database.yml` 파일이 비어 있지만 `ENV['DATABASE_URL']`이 존재하는 경우 Rails는 환경 변수를 통해 데이터베이스에 연결합니다:

```bash
$ cat config/database.yml

$ echo $DATABASE_URL
postgresql://localhost/my_database
```

`config/database.yml`이 있지만 `ENV['DATABASE_URL']`이 없는 경우 이 파일을 사용하여 데이터베이스에 연결합니다:

```bash
$ cat config/database.yml
development:
  adapter: postgresql
  database: my_database
  host: localhost

$ echo $DATABASE_URL
```

`config/database.yml`과 `ENV['DATABASE_URL']`이 모두 설정된 경우 Rails는 구성을 병합합니다. 이를 이해하기 위해 몇 가지 예제를 살펴보아야 합니다.

중복 연결 정보가 제공되는 경우 환경 변수가 우선합니다:

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

여기서 adapter, host, database는 `ENV['DATABASE_URL']`의 정보와 일치합니다.

중복되지 않는 정보가 제공되는 경우 모든 고유한 값이 반환되며, 충돌이 있는 경우에도 환경 변수가 우선합니다.

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

pool은 `ENV['DATABASE_URL']`에서 제공된 연결 정보에 포함되어 있지 않으므로 병합됩니다. adapter가 중복되므로 `ENV['DATABASE_URL']`의 연결 정보가 우선합니다.

`ENV['DATABASE_URL']`의 연결 정보를 사용하지 않으려면 `"url"` 하위 키를 사용하여 명시적인 URL 연결을 지정해야 합니다:

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

여기서 `ENV['DATABASE_URL']`의 연결 정보는 무시되며, 어댑터와 데이터베이스 이름이 다른 것을 알 수 있습니다.

`config/database.yml`에 ERB를 포함시킬 수 있으므로 데이터베이스에 연결하기 위해 `ENV['DATABASE_URL']`을 사용하는 것을 명시적으로 보여주는 것이 좋은 방법입니다. 특히 Git과 같은 소스 제어에 데이터베이스 비밀번호와 같은 비밀을 커밋하지 않아야 하는 프로덕션 환경에서 유용합니다.

```bash
$ cat config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

이제 동작이 명확하게 되었으며, `ENV['DATABASE_URL']`의 연결 정보만 사용한다는 것을 알 수 있습니다.

#### SQLite3 데이터베이스 구성

Rails는 경량 서버리스 데이터베이스 애플리케이션인 [SQLite3](http://www.sqlite.org)를 내장 지원합니다. 활발한 프로덕션 환경에서는 SQLite를 과부하시킬 수 있지만, 개발 및 테스트에는 잘 작동합니다. Rails는 새 프로젝트를 생성할 때 기본적으로 SQLite 데이터베이스를 사용하지만 나중에 언제든지 변경할 수 있습니다.

다음은 개발 환경에 대한 연결 정보가 있는 기본 구성 파일 (`config/database.yml`)의 섹션입니다:

```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

참고: Rails는 기본적으로 데이터 저장을 위해 SQLite3 데이터베이스를 사용합니다. SQLite는 구성이 필요 없는 데이터베이스로, 그냥 작동합니다. Rails는 또한 MySQL (MariaDB 포함) 및 PostgreSQL을 "기본적으로" 지원하며, 많은 데이터베이스 시스템에 대한 플러그인이 있습니다. 프로덕션 환경에서 데이터베이스를 사용하는 경우 Rails에는 대부분의 어댑터가 있을 것입니다.
#### MySQL 또는 MariaDB 데이터베이스 구성

SQLite3 데이터베이스 대신 MySQL 또는 MariaDB를 사용하는 경우 `config/database.yml` 파일이 약간 다를 것입니다. 다음은 개발 섹션입니다:

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

개발 데이터베이스에 루트 사용자가 비어있는 암호로 설정되어 있는 경우, 이 구성이 작동할 것입니다. 그렇지 않은 경우, `development` 섹션에서 사용자 이름과 암호를 적절하게 변경하십시오.

참고: MySQL 버전이 5.5 또는 5.6이고 기본적으로 `utf8mb4` 문자 세트를 사용하려는 경우, `innodb_large_prefix` 시스템 변수를 활성화하여 더 긴 키 접두사를 지원하도록 MySQL 서버를 구성해야 합니다.

MySQL에서는 Advisory Locks가 기본적으로 활성화되어 있으며 데이터베이스 마이그레이션을 동시에 안전하게 만들기 위해 사용됩니다. `advisory_locks`를 `false`로 설정하여 Advisory Locks를 비활성화할 수 있습니다:

```yaml
production:
  adapter: mysql2
  advisory_locks: false
```

#### PostgreSQL 데이터베이스 구성

PostgreSQL을 사용하려는 경우, `config/database.yml` 파일을 PostgreSQL 데이터베이스를 사용하도록 사용자 정의해야 합니다:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: blog_development
  pool: 5
```

기본적으로 Active Record는 준비된 문장(prepared statements)과 Advisory Locks와 같은 데이터베이스 기능을 사용합니다. PgBouncer와 같은 외부 연결 풀러를 사용하는 경우 이러한 기능을 비활성화해야 할 수도 있습니다:

```yaml
production:
  adapter: postgresql
  prepared_statements: false
  advisory_locks: false
```

활성화된 경우, Active Record는 기본적으로 데이터베이스 연결당 최대 `1000`개의 준비된 문장을 생성합니다. 이 동작을 수정하려면 `statement_limit`를 다른 값으로 설정할 수 있습니다:

```yaml
production:
  adapter: postgresql
  statement_limit: 200
```

사용 중인 준비된 문장이 많을수록 데이터베이스에 더 많은 메모리가 필요합니다. PostgreSQL 데이터베이스가 메모리 제한에 도달하는 경우, `statement_limit`를 낮추거나 준비된 문장을 비활성화해 보십시오.

#### JRuby 플랫폼을 위한 SQLite3 데이터베이스 구성

SQLite3를 사용하고 JRuby를 사용하는 경우, `config/database.yml` 파일이 약간 다를 것입니다. 다음은 개발 섹션입니다:

```yaml
development:
  adapter: jdbcsqlite3
  database: storage/development.sqlite3
```

#### JRuby 플랫폼을 위한 MySQL 또는 MariaDB 데이터베이스 구성

JRuby를 사용하고 MySQL 또는 MariaDB를 사용하려는 경우, `config/database.yml` 파일이 약간 다를 것입니다. 다음은 개발 섹션입니다:

```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```

#### JRuby 플랫폼을 위한 PostgreSQL 데이터베이스 구성

JRuby를 사용하고 PostgreSQL을 사용하려는 경우, `config/database.yml` 파일이 약간 다를 것입니다. 다음은 개발 섹션입니다:

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

`development` 섹션에서 사용자 이름과 암호를 적절하게 변경하십시오.

#### 메타데이터 저장소 구성

기본적으로 Rails는 내부 테이블인 `ar_internal_metadata`에 Rails 환경 및 스키마에 대한 정보를 저장합니다.

이를 비활성화하려면 데이터베이스 구성에서 `use_metadata_table`을 설정하십시오. 이는 테이블을 생성할 수 없는 공유 데이터베이스 및/또는 데이터베이스 사용자와 작업할 때 유용합니다.

```yaml
development:
  adapter: postgresql
  use_metadata_table: false
```

#### 재시도 동작 구성

기본적으로 Rails는 데이터베이스 서버에 자동으로 재연결하고 특정 쿼리를 재시도합니다. 안전하게 재시도할 수 있는 (멱등성을 가진) 쿼리만 재시도됩니다. 재시도 횟수는 데이터베이스 구성에서 `connection_retries`를 통해 지정하거나 값을 0으로 설정하여 비활성화할 수 있습니다. 기본 재시도 횟수는 1입니다.
```yaml
development:
  adapter: mysql2
  connection_retries: 3
```

데이터베이스 구성은 `retry_deadline`도 구성할 수 있습니다. `retry_deadline`이 구성된 경우,
지정된 시간이 경과한 경우에는 처음 시도한 쿼리라도 다시 시도되지 않습니다.
예를 들어, 5초의 `retry_deadline`은 쿼리가 처음 시도된 이후 5초가 경과한 경우에는
쿼리를 다시 시도하지 않습니다. 이때 쿼리가 동일하고 `connection_retries`가 남아있는 경우에도 마찬가지입니다.

이 값은 기본적으로 nil로 설정되어 있으며, 경과한 시간에 관계없이 모든 다시 시도 가능한 쿼리가 다시 시도됩니다.
이 구성의 값은 초 단위로 지정해야 합니다.

```yaml
development:
  adapter: mysql2
  retry_deadline: 5 # 5초 후에 쿼리 다시 시도 중지
```

#### 쿼리 캐시 구성

기본적으로 Rails는 쿼리에서 반환된 결과 세트를 자동으로 캐시합니다. Rails는 동일한 쿼리를
요청이나 작업에 다시 만나면 데이터베이스에 대한 쿼리를 다시 실행하는 대신 캐시된 결과 세트를 사용합니다.

쿼리 캐시는 메모리에 저장되며, 너무 많은 메모리를 사용하지 않기 위해 가장 최근에 사용되지 않은 쿼리를 자동으로 삭제합니다.
기본적으로 임계값은 `100`이지만 `database.yml`에서 구성할 수 있습니다.

```yaml
development:
  adapter: mysql2
  query_cache: 200
```

쿼리 캐싱을 완전히 비활성화하려면 `false`로 설정할 수 있습니다.

```yaml
development:
  adapter: mysql2
  query_cache: false
```

### Rails 환경 생성

기본적으로 Rails는 "development", "test", "production" 세 가지 환경으로 제공됩니다. 대부분의 경우 이러한 환경으로 충분하지만, 더 많은 환경이 필요한 경우도 있습니다.

예를 들어, 프로덕션 환경과 동일하지만 테스트에만 사용되는 서버가 있는 경우가 있습니다. 이러한 서버는 일반적으로 "스테이징 서버"라고 합니다. 이 서버에 "스테이징"이라는 환경을 정의하려면 `config/environments/staging.rb`라는 파일을 만들기만 하면 됩니다. 이는 프로덕션과 유사한 환경이므로 `config/environments/production.rb`의 내용을 복사하여 시작점으로 사용하고 필요한 변경 사항을 가할 수 있습니다. 또한 다음과 같이 다른 환경 구성을 요구하고 확장할 수도 있습니다.

```ruby
# config/environments/staging.rb
require_relative "production"

Rails.application.configure do
  # 스테이징 환경 설정
end
```

이 환경은 기본 환경과 다를 바 없으며, `bin/rails server -e staging`으로 서버를 시작하거나 `bin/rails console -e staging`으로 콘솔을 시작하고, `Rails.env.staging?`도 작동합니다.

### 하위 디렉토리로 배포하기 (상대 URL 루트)

기본적으로 Rails는 애플리케이션이 루트(e.g. `/`)에서 실행되는 것으로 예상합니다.
이 섹션에서는 디렉토리 내에서 애플리케이션을 실행하는 방법에 대해 설명합니다.

예를 들어, 애플리케이션을 "/app1"에 배포하려고 합니다. Rails는 적절한 라우트를 생성하기 위해
이 디렉토리를 알아야 합니다.

```ruby
config.relative_url_root = "/app1"
```

또는 `RAILS_RELATIVE_URL_ROOT` 환경 변수를 설정할 수도 있습니다.

Rails는 이제 링크를 생성할 때 "/app1"을 앞에 붙입니다.

#### Passenger 사용하기

Passenger를 사용하면 하위 디렉토리에서 애플리케이션을 실행하기 쉽습니다. 관련된 구성은 [Passenger 매뉴얼](https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/#deploying-an-app-to-a-sub-uri-or-subdirectory)에서 찾을 수 있습니다.

#### Reverse Proxy 사용하기

Reverse Proxy를 사용하여 애플리케이션을 배포하는 것은 기존의 배포 방식보다 명확한 장점이 있습니다. 애플리케이션에 필요한 구성 요소를 계층화하여 서버를 더욱 효율적으로 제어할 수 있습니다.
많은 현대 웹 서버는 캐싱 서버나 애플리케이션 서버와 같은 타사 요소를 균형있게 조정하기 위해 프록시 서버로 사용될 수 있습니다.

그러한 애플리케이션 서버 중 하나는 [Unicorn](https://bogomips.org/unicorn/)입니다. 이를 위해 역방향 프록시 뒤에서 실행할 수 있습니다.

이 경우, 프록시 서버 (NGINX, Apache 등)를 구성하여 애플리케이션 서버 (Unicorn)에서의 연결을 수락하도록 설정해야 합니다. 기본적으로 Unicorn은 TCP 연결을 8080 포트에서 수신 대기하지만, 포트를 변경하거나 소켓을 사용하도록 구성할 수 있습니다.

[Unicorn readme](https://bogomips.org/unicorn/README.html)에서 더 많은 정보를 찾을 수 있으며, [Unicorn의 철학](https://bogomips.org/unicorn/PHILOSOPHY.html)을 이해할 수 있습니다.

애플리케이션 서버를 구성한 후에는 웹 서버를 적절하게 구성하여 해당 서버로 요청을 프록시해야 합니다. 예를 들어, NGINX 구성에는 다음과 같은 내용이 포함될 수 있습니다:

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

가장 최신 정보를 확인하려면 [NGINX 문서](https://nginx.org/en/docs/)를 읽어보세요.


Rails 환경 설정
--------------------------

Rails의 일부는 환경 변수를 제공하여 외부에서 구성할 수도 있습니다. 다음 환경 변수는 Rails의 여러 부분에서 인식됩니다:

* `ENV["RAILS_ENV"]`는 Rails가 실행될 환경 (production, development, test 등)을 정의합니다.

* `ENV["RAILS_RELATIVE_URL_ROOT"]`는 라우팅 코드에서 URL을 인식하는 데 사용됩니다. [애플리케이션을 하위 디렉토리에 배포](configuring.html#deploy-to-a-subdirectory-relative-url-root)할 때 사용됩니다.

* `ENV["RAILS_CACHE_ID"]`와 `ENV["RAILS_APP_VERSION"]`은 Rails의 캐싱 코드에서 확장된 캐시 키를 생성하는 데 사용됩니다. 이를 통해 동일한 애플리케이션에서 여러 개의 별도 캐시를 사용할 수 있습니다.


초기화 파일 사용
-----------------------

Rails는 애플리케이션의 프레임워크와 젬을 로드한 후 초기화 파일을 로드합니다. 초기화 파일은 애플리케이션의 `config/initializers` 디렉토리에 저장된 Ruby 파일입니다. 초기화 파일을 사용하여 모든 프레임워크와 젬이 로드된 후에 이루어져야 하는 설정을 보관할 수 있습니다.

`config/initializers` 디렉토리의 파일들 (및 `config/initializers`의 하위 디렉토리들)은 `load_config_initializers` 초기화 파일의 일부로 하나씩 정렬되어 로드됩니다.

한 초기화 파일이 다른 초기화 파일의 코드에 의존하는 경우, 이를 하나의 초기화 파일로 결합할 수도 있습니다. 이렇게 하면 의존성이 더 명시적으로 드러나며, 애플리케이션 내에서 새로운 개념을 도출하는 데 도움이 될 수 있습니다. Rails는 초기화 파일 이름에 번호를 매길 수도 있지만, 이는 파일 이름 변경을 유발할 수 있습니다. `require`를 사용하여 초기화 파일을 명시적으로 로드하는 것은 권장되지 않습니다. 왜냐하면 이렇게 하면 초기화 파일이 두 번 로드되기 때문입니다.

참고: 초기화 파일이 모든 젬 초기화 파일보다 나중에 실행될 것임을 보장할 수는 없으므로, 특정 젬이 초기화되었다고 가정하는 초기화 코드는 `config.after_initialize` 블록에 넣어야 합니다.

초기화 이벤트
---------------------

Rails에는 연결할 수 있는 5가지 초기화 이벤트가 있습니다 (실행되는 순서대로 나열됨):

* `before_configuration`: 이는 애플리케이션 상수가 `Rails::Application`을 상속하는 즉시 실행됩니다. 이전에 `config` 호출이 평가됩니다.

* `before_initialize`: 이는 Rails 초기화 프로세스의 시작 부분에 가까운 `:bootstrap_hook` 초기화 파일과 함께 애플리케이션 초기화 프로세스 직전에 직접 실행됩니다.
* `to_prepare`: 모든 Railties(응용 프로그램 자체를 포함하여)의 초기화가 완료된 후에 실행되지만, eager loading과 미들웨어 스택이 구축되기 전에 실행됩니다. 더 중요한 것은 `development`에서는 코드 재로드마다 실행되지만, `production` 및 `test`에서는 한 번만(부팅 중에) 실행됩니다.

* `before_eager_load`: eager loading이 발생하기 바로 직전에 실행되며, 이는 `production` 환경의 기본 동작이지만 `development` 환경에서는 기본 동작이 아닙니다.

* `after_initialize`: 응용 프로그램 초기화 직후에 실행되며, `config/initializers`에 있는 응용 프로그램 초기화기가 실행된 후에 실행됩니다.

이러한 훅에 대한 이벤트를 정의하려면 `Rails::Application`, `Rails::Railtie` 또는 `Rails::Engine` 하위 클래스 내에서 블록 구문을 사용하십시오.

```ruby
module YourApp
  class Application < Rails::Application
    config.before_initialize do
      # 초기화 코드를 여기에 작성합니다.
    end
  end
end
```

또는 `Rails.application` 객체의 `config` 메서드를 사용하여 수행할 수도 있습니다.

```ruby
Rails.application.config.before_initialize do
  # 초기화 코드를 여기에 작성합니다.
end
```

경고: `after_initialize` 블록이 호출되는 시점에서 라우팅과 같은 응용 프로그램의 일부는 아직 설정되지 않았습니다.

### `Rails::Railtie#initializer`

Rails에는 `Rails::Railtie`의 `initializer` 메서드를 사용하여 정의된 시작 시 실행되는 여러 초기화기가 있습니다. 다음은 Action Controller의 `set_helpers_path` 초기화기의 예입니다.

```ruby
initializer "action_controller.set_helpers_path" do |app|
  ActionController::Helpers.helpers_path = app.helpers_paths
end
```

`initializer` 메서드는 세 개의 인수를 사용하며, 첫 번째는 초기화기의 이름이고 두 번째는 옵션 해시(여기에 표시되지 않음)이고 세 번째는 블록입니다. 옵션 해시의 `:before` 키를 지정하여 이 새로운 초기화기가 어떤 초기화기보다 먼저 실행되어야 하는지 지정할 수 있으며, `:after` 키는 이 초기화기가 어떤 초기화기보다 _후에_ 실행되어야 하는지 지정합니다.

`initializer` 메서드를 사용하여 정의된 초기화기는 정의된 순서대로 실행되며, `:before` 또는 `:after` 메서드를 사용하는 초기화기를 제외하고 실행됩니다.

경고: 초기화기를 체인의 다른 초기화기 앞이나 뒤에 놓을 수 있지만, 논리적이어야 합니다. "one"부터 "four"까지 4개의 초기화기가 있다고 가정해 보겠습니다(해당 순서로 정의됨). "four"를 "two"보다 _앞에_, "three"보다 _뒤에_ 정의하려고 하면 이는 논리적이지 않으며 Rails는 초기화기 순서를 결정할 수 없습니다.

`initializer` 메서드의 블록 인수는 응용 프로그램 자체의 인스턴스이므로, 예제에서와 같이 `config` 메서드를 사용하여 구성에 액세스할 수 있습니다.

`Rails::Application`은 `Rails::Railtie`에서 상속받기 때문에 `config/application.rb`에서 응용 프로그램의 초기화기를 정의하는 데 `initializer` 메서드를 사용할 수 있습니다.

### 초기화기

다음은 Rails에서 정의된 모든 초기화기의 종합적인 목록입니다. 이 목록은 정의된 순서대로 실행됩니다(그렇지 않은 경우에는 명시되어 있음).

* `load_environment_hook`: `:load_environment_config`가 그 앞에서 실행될 수 있도록 플레이스홀더 역할을 합니다.

* `load_active_support`: Active Support의 기초를 설정하는 `active_support/dependencies`를 요구합니다. `config.active_support.bare`가 거짓이 아닌 경우에는 선택적으로 `active_support/all`을 요구합니다(기본값).

* `initialize_logger`: 응용 프로그램의 로거(`ActiveSupport::Logger` 객체)를 초기화하고, 이를 `Rails.logger`에서 접근할 수 있도록 합니다. 이 지점 이전에 삽입된 초기화기가 `Rails.logger`를 정의하지 않은 경우에만 제공됩니다.
* `initialize_cache`: `Rails.cache`가 아직 설정되지 않은 경우, `config.cache_store`의 값을 참조하여 캐시를 초기화하고 결과를 `Rails.cache`에 저장합니다. 이 객체가 `middleware` 메소드에 응답하는 경우, 해당 미들웨어는 미들웨어 스택에서 `Rack::Runtime` 이전에 삽입됩니다.

* `set_clear_dependencies_hook`: 이 초기화기는 `config.enable_reloading`이 `true`로 설정된 경우에만 실행되며, `ActionDispatch::Callbacks.after`를 사용하여 요청 중에 참조된 상수를 객체 공간에서 제거하여 다음 요청 중에 다시 로드되도록 합니다.

* `bootstrap_hook`: 모든 구성된 `before_initialize` 블록을 실행합니다.

* `i18n.callbacks`: 개발 환경에서는 `to_prepare` 콜백을 설정하여 마지막 요청 이후로 로케일이 변경된 경우 `I18n.reload!`을 호출합니다. 프로덕션 환경에서는 이 콜백은 첫 번째 요청에서만 실행됩니다.

* `active_support.deprecation_behavior`: [`config.active_support.report_deprecations`](#config-active-support-report-deprecations), [`config.active_support.deprecation`](#config-active-support-deprecation), [`config.active_support.disallowed_deprecation`](#config-active-support-disallowed-deprecation), [`config.active_support.disallowed_deprecation_warnings`](#config-active-support-disallowed-deprecation-warnings)를 기반으로 [`Rails.application.deprecators`][]에 대한 폐기 보고 동작을 설정합니다.

* `active_support.initialize_time_zone`: `config.time_zone` 설정을 기반으로 애플리케이션의 기본 시간대를 설정합니다. 기본값은 "UTC"입니다.

* `active_support.initialize_beginning_of_week`: `config.beginning_of_week` 설정을 기반으로 애플리케이션의 기본 주의 시작을 설정합니다. 기본값은 `:monday`입니다.

* `active_support.set_configs`: `config.active_support`의 설정을 사용하여 Active Support를 설정합니다. 메소드 이름을 `ActiveSupport`의 세터로 `send`하여 값을 전달합니다.

* `action_dispatch.configure`: `ActionDispatch::Http::URL.tld_length`를 `config.action_dispatch.tld_length`의 값으로 설정합니다.

* `action_view.set_configs`: `config.action_view`의 설정을 사용하여 Action View를 설정합니다. 메소드 이름을 `ActionView::Base`의 세터로 `send`하여 값을 전달합니다.

* `action_controller.assets_config`: 명시적으로 구성되지 않은 경우 앱의 공개 디렉토리로 `config.action_controller.assets_dir`를 초기화합니다.

* `action_controller.set_helpers_path`: Action Controller의 `helpers_path`를 애플리케이션의 `helpers_path`로 설정합니다.

* `action_controller.parameters_config`: `ActionController::Parameters`에 대한 강력한 매개변수 옵션을 구성합니다.

* `action_controller.set_configs`: `config.action_controller`의 설정을 사용하여 Action Controller를 설정합니다. 메소드 이름을 `ActionController::Base`의 세터로 `send`하여 값을 전달합니다.

* `action_controller.compile_config_methods`: 지정된 구성 설정에 대한 메소드를 초기화하여 더 빠르게 액세스할 수 있도록 합니다.

* `active_record.initialize_timezone`: `ActiveRecord::Base.time_zone_aware_attributes`를 `true`로 설정하고, `ActiveRecord::Base.default_timezone`를 UTC로 설정합니다. 데이터베이스에서 속성을 읽을 때 `Time.zone`으로 지정된 시간대로 변환됩니다.

* `active_record.logger`: `ActiveRecord::Base.logger`를 `Rails.logger`로 설정합니다. 이미 설정되어 있는 경우는 설정하지 않습니다.

* `active_record.migration_error`: 보류 중인 마이그레이션을 확인하기 위해 미들웨어를 구성합니다.

* `active_record.check_schema_cache_dump`: 구성되어 있고 사용 가능한 경우 스키마 캐시 덤프를 로드합니다.

* `active_record.warn_on_records_fetched_greater_than`: 쿼리가 많은 레코드를 반환할 때 경고를 활성화합니다.

* `active_record.set_configs`: `config.active_record`의 설정을 사용하여 Active Record를 설정합니다. 메소드 이름을 `ActiveRecord::Base`의 세터로 `send`하여 값을 전달합니다.

* `active_record.initialize_database`: `config/database.yml`에서 (기본적으로) 데이터베이스 구성을 로드하고 현재 환경에 대한 연결을 설정합니다.

* `active_record.log_runtime`: Active Record 호출에 소요된 시간을 로거로 다시 보고하는 `ActiveRecord::Railties::ControllerRuntime` 및 `ActiveRecord::Railties::JobRuntime`을 포함합니다.

* `active_record.set_reloader_hooks`: `config.enable_reloading`이 `true`로 설정된 경우 모든 다시 로드 가능한 연결을 데이터베이스로 재설정합니다.

* `active_record.add_watchable_files`: `schema.rb` 및 `structure.sql` 파일을 감시 가능한 파일로 추가합니다.

* `active_job.logger`: `ActiveJob::Base.logger`를 `Rails.logger`로 설정합니다. 이미 설정되어 있는 경우는 설정하지 않습니다.
* `active_job.set_configs`: `config.active_job`의 설정을 사용하여 Active Job을 설정합니다. 값을 `ActiveJob::Base`의 setter 메서드로 `send`하여 전달합니다.

* `action_mailer.logger`: `ActionMailer::Base.logger`를 설정합니다. 이미 설정되어 있지 않은 경우에만 `Rails.logger`로 설정합니다.

* `action_mailer.set_configs`: `config.action_mailer`의 설정을 사용하여 Action Mailer를 설정합니다. 값을 `ActionMailer::Base`의 setter 메서드로 `send`하여 전달합니다.

* `action_mailer.compile_config_methods`: 지정된 구성 설정에 대한 메서드를 초기화하여 빠르게 액세스할 수 있도록 합니다.

* `set_load_path`: 이 초기화기는 `bootstrap_hook` 이전에 실행됩니다. `config.load_paths`로 지정된 경로와 모든 autoload 경로를 `$LOAD_PATH`에 추가합니다.

* `set_autoload_paths`: 이 초기화기는 `bootstrap_hook` 이전에 실행됩니다. `app`의 모든 하위 디렉토리와 `config.autoload_paths`, `config.eager_load_paths`, `config.autoload_once_paths`로 지정된 경로를 `ActiveSupport::Dependencies.autoload_paths`에 추가합니다.

* `add_routing_paths`: (기본적으로) 응용 프로그램 및 레일티, 엔진을 포함한 모든 `config/routes.rb` 파일을 로드하고 응용 프로그램의 라우트를 설정합니다.

* `add_locales`: 응용 프로그램, 레일티, 엔진의 `config/locales`에 있는 파일을 `I18n.load_path`에 추가하여 이 파일의 번역을 사용할 수 있게 합니다.

* `add_view_paths`: 응용 프로그램, 레일티, 엔진의 `app/views` 디렉토리를 응용 프로그램의 뷰 파일 조회 경로에 추가합니다.

* `add_mailer_preview_paths`: 응용 프로그램, 레일티, 엔진의 `test/mailers/previews` 디렉토리를 응용 프로그램의 메일러 미리보기 파일 조회 경로에 추가합니다.

* `load_environment_config`: 이 초기화기는 `load_environment_hook` 이전에 실행됩니다. 현재 환경에 대한 `config/environments` 파일을 로드합니다.

* `prepend_helpers_path`: 응용 프로그램, 레일티, 엔진의 `app/helpers` 디렉토리를 응용 프로그램의 헬퍼 조회 경로에 추가합니다.

* `load_config_initializers`: 응용 프로그램, 레일티, 엔진의 `config/initializers`에서 모든 Ruby 파일을 로드합니다. 이 디렉토리의 파일은 모든 프레임워크가 로드된 후에 수행되어야 하는 구성 설정을 보관하는 데 사용될 수 있습니다.

* `engines_blank_point`: 엔진이 로드되기 전에 수행할 작업을 훅으로 제공합니다. 이 지점 이후에는 모든 railtie 및 엔진 초기화기가 실행됩니다.

* `add_generator_templates`: 응용 프로그램, 레일티, 엔진의 `lib/templates`에서 생성기 템플릿을 찾아 `config.generators.templates` 설정에 추가합니다. 이렇게 하면 모든 생성기에서 템플릿을 참조할 수 있게 됩니다.

* `ensure_autoload_once_paths_as_subset`: `config.autoload_once_paths`에는 `config.autoload_paths`의 경로만 포함되도록 보장합니다. 추가 경로가 포함되어 있는 경우 예외가 발생합니다.

* `add_to_prepare_blocks`: 응용 프로그램, 레일티 또는 엔진의 각 `config.to_prepare` 호출에 대한 블록은 개발 환경에서 요청마다 실행되거나 프로덕션 환경에서 첫 번째 요청 이전에 실행될 Action Dispatch의 `to_prepare` 콜백에 추가됩니다.

* `add_builtin_route`: 응용 프로그램이 개발 환경에서 실행 중인 경우 `rails/info/properties` 경로를 응용 프로그램 라우트에 추가합니다. 이 경로는 기본 Rails 응용 프로그램의 `public/index.html`에 대한 Rails 및 Ruby 버전과 같은 자세한 정보를 제공합니다.

* `build_middleware_stack`: 응용 프로그램의 미들웨어 스택을 빌드하고 요청에 대한 Rack 환경 객체를 받는 `call` 메서드를 가진 객체를 반환합니다.

* `eager_load!`: `config.eager_load`가 `true`인 경우 `config.before_eager_load` 훅을 실행한 다음 모든 `config.eager_load_namespaces`를 로드하는 `eager_load!`를 호출합니다.

* `finisher_hook`: 응용 프로그램의 초기화 프로세스가 완료된 후에 후크를 제공하며, 응용 프로그램, 레일티, 엔진의 모든 `config.after_initialize` 블록을 실행합니다.
* `set_routes_reloader_hook`: Action Dispatch를 설정하여 `ActiveSupport::Callbacks.to_run`을 사용하여 라우트 파일을 다시로드합니다.

* `disable_dependency_loading`: `config.eager_load`가 `true`로 설정된 경우 자동 종속성 로딩을 비활성화합니다.


데이터베이스 풀링
----------------

Active Record 데이터베이스 연결은 `ActiveRecord::ConnectionAdapters::ConnectionPool`에 의해 관리됩니다. 이는 연결 풀이 제한된 수의 데이터베이스 연결에 대한 스레드 액세스 양을 동기화합니다. 이 제한은 기본적으로 5로 설정되며 `database.yml`에서 구성할 수 있습니다.

```ruby
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

연결 풀링은 기본적으로 Active Record 내부에서 처리되므로 모든 애플리케이션 서버 (Thin, Puma, Unicorn 등)는 동일하게 동작해야 합니다. 데이터베이스 연결 풀은 초기에 비어 있습니다. 연결에 대한 수요가 증가하면 연결 풀 제한에 도달할 때까지 연결을 생성합니다.

한 요청은 데이터베이스에 액세스해야 할 때 처음으로 연결을 가져옵니다. 요청이 끝나면 연결을 다시 확인합니다. 이는 추가 연결 슬롯이 대기열의 다음 요청을 위해 다시 사용 가능하다는 것을 의미합니다.

사용 가능한 연결보다 더 많은 연결을 사용하려고 하면 Active Record가 차단되고 연결 풀에서 연결을 기다립니다. 연결을 가져올 수 없는 경우 아래와 유사한 시간 초과 오류가 발생합니다.

```ruby
ActiveRecord::ConnectionTimeoutError - could not obtain a database connection within 5.000 seconds (waited 5.000 seconds)
```

위의 오류가 발생하는 경우 `database.yml`의 `pool` 옵션을 증가시켜 연결 풀의 크기를 늘릴 수 있습니다.

참고. 멀티 스레드 환경에서 여러 스레드가 동시에 여러 연결에 액세스할 수 있는 가능성이 있습니다. 따라서 현재 요청 부하에 따라 제한된 수의 연결을 경합하는 여러 스레드가 있을 수 있습니다.


사용자 정의 구성
--------------------

Rails 구성 객체를 사용하여 사용자 정의 구성을 `config.x` 네임스페이스 또는 `config` 직접 아래에 정의할 수 있습니다. 이 두 가지 사이의 주요 차이점은 _중첩_ 구성 (예: `config.x.nested.hi`)을 정의하는 경우 `config.x`를 사용해야 하고, _단일 레벨_ 구성 (예: `config.hello`)의 경우 `config`를 사용해야 한다는 것입니다.

```ruby
config.x.payment_processing.schedule = :daily
config.x.payment_processing.retries  = 3
config.super_debugger = true
```

이러한 구성 포인트는 구성 객체를 통해 사용할 수 있습니다.

```ruby
Rails.configuration.x.payment_processing.schedule # => :daily
Rails.configuration.x.payment_processing.retries  # => 3
Rails.configuration.x.payment_processing.not_set  # => nil
Rails.configuration.super_debugger                # => true
```

또한 `Rails::Application.config_for`를 사용하여 전체 구성 파일을 로드할 수도 있습니다.

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
Rails.configuration.payment['merchant_id'] # => production_merchant_id 또는 development_merchant_id
```

`Rails::Application.config_for`는 공통 구성을 그룹화하는 `shared` 구성을 지원합니다. 공유 구성은 환경 구성에 병합됩니다.

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
# 개발 환경
Rails.application.config_for(:example)[:foo][:bar] #=> { baz: 1, qux: 2 }
```

검색 엔진 인덱싱
-----------------------

때로는 Google, Bing, Yahoo, Duck Duck Go와 같은 검색 사이트에서 애플리케이션의 일부 페이지가 보이지 않도록 하고 싶을 수 있습니다. 이러한 사이트를 인덱싱하는 로봇은 인덱싱할 수 있는 페이지를 알기 위해 먼저 `http://your-site.com/robots.txt` 파일을 분석합니다.
레일즈는 `/public` 폴더 내에 이 파일을 생성합니다. 기본적으로, 이 파일은 검색 엔진이 애플리케이션의 모든 페이지를 색인할 수 있도록 허용합니다. 애플리케이션의 모든 페이지에서 색인을 차단하려면 다음을 사용하십시오:

```
User-agent: *
Disallow: /
```

특정 페이지만 차단하려면 더 복잡한 구문을 사용해야 합니다. [공식 문서](https://www.robotstxt.org/robotstxt.html)에서 자세히 알아보십시오.

이벤트 기반 파일 시스템 모니터
---------------------------

[listen gem](https://github.com/guard/listen)이 로드되면 레일즈는 다시로드가 활성화되었을 때 변경 사항을 감지하기 위해 이벤트 기반 파일 시스템 모니터를 사용합니다:

```ruby
group :development do
  gem 'listen', '~> 3.3'
end
```

그렇지 않으면, 모든 요청에서 레일즈는 애플리케이션 트리를 확인하여 변경 사항이 있는지 확인합니다.

Linux와 macOS에서는 추가적인 젬이 필요하지 않지만, [BSD](https://github.com/guard/listen#on-bsd)와 [Windows](https://github.com/guard/listen#on-windows)에서는 일부 젬이 필요합니다.

일부 설정은 [지원되지 않습니다](https://github.com/guard/listen#issues--limitations).
[`config.load_defaults`]: https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults
[`ActiveSupport::ParameterFilter.precompile_filters`]: https://api.rubyonrails.org/classes/ActiveSupport/ParameterFilter.html#method-c-precompile_filters
[ActiveModel::Error#full_message]: https://api.rubyonrails.org/classes/ActiveModel/Error.html#method-i-full_message
[`ActiveSupport::MessageEncryptor`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html
[`ActiveSupport::MessageVerifier`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html
[`message_serializer_fallback.active_support`]: active_support_instrumentation.html#message-serializer-fallback-active-support
[`Rails.application.deprecators`]: https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators
