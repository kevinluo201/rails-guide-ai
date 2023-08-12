**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bba7dd6e311e7abd59e434f12dbebd0e
Railsアプリケーションの設定
==============================

このガイドでは、Railsアプリケーションで利用可能な設定と初期化機能について説明します。

このガイドを読み終えると、以下のことがわかるようになります。

* Railsアプリケーションの動作を調整する方法。
* アプリケーションの起動時に実行する追加のコードを追加する方法。

--------------------------------------------------------------------------------

初期化コードの配置場所
---------------------------------

Railsでは、初期化コードを配置するための4つの標準的な場所が提供されています。

* `config/application.rb`
* 環境固有の設定ファイル
* イニシャライザ
* イニシャライザの後

Railsの前にコードを実行する
-------------------------

アプリケーションがRails自体がロードされる前にコードを実行する必要がある場合は、`config/application.rb`の`require "rails/all"`の前に配置してください。

Railsコンポーネントの設定
----------------------------

一般的に、Railsの設定作業は、Railsのコンポーネントの設定とRails自体の設定を行うことを意味します。`config/application.rb`ファイルや環境固有の設定ファイル（例：`config/environments/production.rb`）では、すべてのコンポーネントに渡すためのさまざまな設定を指定できます。

たとえば、次の設定を`config/application.rb`ファイルに追加できます。

```ruby
config.time_zone = 'Central Time (US & Canada)'
```

これはRails自体の設定です。個々のRailsコンポーネントに設定を渡す場合は、`config/application.rb`の同じ`config`オブジェクトを使用して行うことができます。

```ruby
config.active_record.schema_format = :ruby
```

Railsはその特定の設定を使用してActive Recordを設定します。

警告: 関連するクラスに直接呼び出す代わりに、公開されている設定メソッドを使用してください。たとえば、`ActionMailer::Base.options`の代わりに`Rails.application.config.action_mailer.options`を使用します。

注意: クラスに直接設定を適用する必要がある場合は、初期化子で[遅延ロードフック](https://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html)を使用して、初期化が完了する前にクラスを自動ロードしないようにします。これは、アプリケーションが再読み込みされるときに安全に繰り返し実行できないためです。

### バージョン付きのデフォルト値

[`config.load_defaults`]は、対象バージョンとそれ以前のすべてのバージョンに対するデフォルトの設定値を読み込みます。たとえば、`config.load_defaults 6.1`は、バージョン6.1までのすべてのバージョンのデフォルトを読み込みます。


以下は、各対象バージョンに関連付けられたデフォルト値です。競合する値の場合、新しいバージョンが古いバージョンより優先されます。

#### 対象バージョン7.1のデフォルト値

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
#### ターゲットバージョン7.0のデフォルト値

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

#### ターゲットバージョン6.1のデフォルト値

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

#### ターゲットバージョン6.0のデフォルト値

- [`config.action_dispatch.use_cookies_with_metadata`](#config-action-dispatch-use-cookies-with-metadata): `true`
- [`config.action_mailer.delivery_job`](#config-action-mailer-delivery-job): `"ActionMailer::MailDeliveryJob"`
- [`config.action_view.default_enforce_utf8`](#config-action-view-default-enforce-utf8): `false`
- [`config.active_record.collection_cache_versioning`](#config-active-record-collection-cache-versioning): `true`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `:active_storage_analysis`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `:active_storage_purge`

#### ターゲットバージョン5.2のデフォルト値

- [`config.action_controller.default_protect_from_forgery`](#config-action-controller-default-protect-from-forgery): `true`
- [`config.action_dispatch.use_authenticated_cookie_encryption`](#config-action-dispatch-use-authenticated-cookie-encryption): `true`
- [`config.action_view.form_with_generates_ids`](#config-action-view-form-with-generates-ids): `true`
- [`config.active_record.cache_versioning`](#config-active-record-cache-versioning): `true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA1`
- [`config.active_support.use_authenticated_message_encryption`](#config-active-support-use-authenticated-message-encryption): `true`

#### ターゲットバージョン5.1のデフォルト値

- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `true`
- [`config.assets.unknown_asset_fallback`](#config-assets-unknown-asset-fallback): `false`

#### ターゲットバージョン5.0のデフォルト値

- [`ActiveSupport.to_time_preserves_timezone`](#activesupport-to-time-preserves-timezone): `true`
- [`config.action_controller.forgery_protection_origin_check`](#config-action-controller-forgery-protection-origin-check): `true`
- [`config.action_controller.per_form_csrf_tokens`](#config-action-controller-per-form-csrf-tokens): `true`
- [`config.active_record.belongs_to_required_by_default`](#config-active-record-belongs-to-required-by-default): `true`
- [`config.ssl_options`](#config-ssl-options): `{ hsts: { subdomains: true } }`

### Rails一般の設定

以下の設定メソッドは、`Rails::Engine`や`Rails::Application`のサブクラスなどの`Rails::Railtie`オブジェクトで呼び出す必要があります。

#### `config.add_autoload_paths_to_load_path`

autoloadパスを`$LOAD_PATH`に追加するかどうかを指定します。`:zeitwerk`モードでは、`config/application.rb`で早期に`false`に設定することが推奨されています。Zeitwerkは内部的に絶対パスを使用し、`:zeitwerk`モードで実行されるアプリケーションでは`require_dependency`が必要ないため、モデル、コントローラ、ジョブなどは`$LOAD_PATH`に含める必要はありません。この設定を`false`にすることで、Rubyは相対パスでの`require`呼び出しの解決時にこれらのディレクトリをチェックする必要がなくなり、Bootsnapの作業とRAMを節約することができます。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `true`       |
| 7.1        | `false`      |

`lib`ディレクトリはこのフラグの影響を受けません。常に`$LOAD_PATH`に追加されます。

#### `config.after_initialize`

アプリケーションの初期化が完了した後に実行されるブロックを受け取ります。これには、フレームワーク自体、エンジン、および`config/initializers`内のすべての初期化子の初期化が含まれます。このブロックはrakeタスクでも実行されます。他の初期化子によって設定された値を構成するために便利です。
```ruby
config.after_initialize do
  ActionView::Base.sanitized_allowed_tags.delete 'div'
end
```

#### `config.after_routes_loaded`

アプリケーションのルートが読み込まれた後に実行されるブロックを受け取ります。このブロックは、ルートが再読み込みされるたびに実行されます。

```ruby
config.after_routes_loaded do
  # Rails.application.routes を使用して何かを行うコード
end
```

#### `config.allow_concurrency`

リクエストを並行して処理するかどうかを制御します。アプリケーションのコードがスレッドセーフでない場合にのみ `false` に設定する必要があります。デフォルトは `true` です。

#### `config.asset_host`

アセットのホストを設定します。アセットのホスティングにCDNを使用する場合や、異なるドメインエイリアスを使用してブラウザの並行制約を回避する場合に便利です。`config.action_controller.asset_host` の短縮バージョンです。

#### `config.assume_ssl`

すべてのリクエストがSSL経由で到着しているとアプリケーションに信じさせます。これは、SSLを終端するロードバランサを経由してプロキシする場合に便利です。転送されたリクエストは、アプリケーションに対してHTTPではなくHTTPSであるかのように表示されます。これにより、リダイレクトやクッキーセキュリティはHTTPSではなくHTTPを対象とします。このミドルウェアは、サーバーがプロキシが既にSSLを終了し、リクエストが実際にHTTPSであると仮定するものです。

#### `config.autoflush_log`

ログファイルの出力をバッファリングせずにすぐに行うようにします。デフォルトは `true` です。

#### `config.autoload_once_paths`

リクエストごとにクリアされない定数をRailsが自動読み込みするパスの配列を受け入れます。これは、`development` 環境ではデフォルトで有効になっているリロードが有効な場合に関連します。それ以外の場合、すべての自動読み込みは1回だけ行われます。この配列のすべての要素は `autoload_paths` にも含まれている必要があります。デフォルトは空の配列です。

#### `config.autoload_paths`

Railsが定数を自動読み込みするパスの配列を受け入れます。デフォルトは空の配列です。[Rails 6](upgrading_ruby_on_rails.html#autoloading)以降、これを調整することは推奨されていません。[Autoloading and Reloading Constants](autoloading_and_reloading_constants.html#autoload-paths)を参照してください。

#### `config.autoload_lib(ignore:)`

このメソッドは `lib` を `config.autoload_paths` および `config.eager_load_paths` に追加します。

通常、`lib` ディレクトリには自動読み込みやイーガーロードを行うべきではないサブディレクトリがあります。必要な `ignore` キーワード引数には、`lib` に対する相対的な名前を渡してください。例えば、

```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

詳細については、[autoloading guide](autoloading_and_reloading_constants.html)を参照してください。

#### `config.autoload_lib_once(ignore:)`

`config.autoload_lib_once` メソッドは `config.autoload_lib` と似ていますが、代わりに `lib` を `config.autoload_once_paths` に追加します。

`config.autoload_lib_once` を呼び出すことで、`lib` 内のクラスやモジュールが自動読み込みされ、アプリケーションのイニシャライザからもリロードされなくなります。

#### `config.beginning_of_week`

アプリケーションのデフォルトの週の開始日を設定します。有効な曜日のシンボル（例： `:monday`）を受け入れます。

#### `config.cache_classes`

`!config.enable_reloading` と同等の古い設定です。後方互換性のためにサポートされています。
#### `config.cache_store`

Railsのキャッシュに使用するキャッシュストアを設定します。オプションには、`:memory_store`、`:file_store`、`:mem_cache_store`、`:null_store`、`:redis_cache_store`のいずれかのシンボル、またはキャッシュAPIを実装したオブジェクトがあります。デフォルトは`:file_store`です。パーストアの設定オプションについては、[キャッシュストア](caching_with_rails.html#cache-stores)を参照してください。

#### `config.colorize_logging`

ログ情報を出力する際にANSIカラーコードを使用するかどうかを指定します。デフォルトは`true`です。

#### `config.consider_all_requests_local`

フラグです。`true`の場合、エラーが発生すると詳細なデバッグ情報がHTTPレスポンスにダンプされ、`Rails::Info`コントローラーは`/rails/info/properties`でアプリケーションのランタイムコンテキストを表示します。開発環境とテスト環境ではデフォルトで`true`になり、本番環境では`false`になります。より細かい制御のために、これを`false`に設定し、コントローラーで`show_detailed_exceptions?`を実装して、どのリクエストがエラー時にデバッグ情報を提供するかを指定します。

#### `config.console`

`bin/rails console`を実行する際に使用されるコンソールクラスを設定することができます。以下のように`console`ブロック内で実行するのがベストです。

```ruby
console do
  # このブロックはコンソールを実行する場合にのみ呼び出されるため、ここで安全にpryをrequireできます
  require "pry"
  config.console = Pry
end
```

#### `config.content_security_policy_nonce_directives`

セキュリティガイドの[Nonceの追加](security.html#adding-a-nonce)を参照してください。

#### `config.content_security_policy_nonce_generator`

セキュリティガイドの[Nonceの追加](security.html#adding-a-nonce)を参照してください。

#### `config.content_security_policy_report_only`

セキュリティガイドの[違反の報告](security.html#reporting-violations)を参照してください。

#### `config.credentials.content_path`

暗号化された認証情報ファイルのパスです。

存在する場合はデフォルトで`config/credentials/#{Rails.env}.yml.enc`、存在しない場合は`config/credentials.yml.enc`です。

注意: `bin/rails credentials`コマンドがこの値を認識するためには、`config/application.rb`または`config/environments/#{Rails.env}.rb`で設定する必要があります。

#### `config.credentials.key_path`

暗号化された認証情報キーファイルのパスです。

存在する場合はデフォルトで`config/credentials/#{Rails.env}.key`、存在しない場合は`config/master.key`です。

注意: `bin/rails credentials`コマンドがこの値を認識するためには、`config/application.rb`または`config/environments/#{Rails.env}.rb`で設定する必要があります。

#### `config.debug_exception_response_format`

開発環境でエラーが発生した場合のレスポンスで使用されるフォーマットを設定します。API専用アプリの場合はデフォルトで`:api`、通常のアプリの場合は`:default`です。

#### `config.disable_sandbox`

サンドボックスモードでコンソールを起動できるかどうかを制御します。これにより、データベースサーバーがメモリ不足になる可能性のある長時間実行されるサンドボックスコンソールセッションを回避するのに役立ちます。デフォルトは`false`です。

#### `config.eager_load`

`true`の場合、登録されたすべての`config.eager_load_namespaces`を一括読み込みします。これにはアプリケーション、エンジン、Railsフレームワーク、およびその他の登録された名前空間が含まれます。

#### `config.eager_load_namespaces`

`config.eager_load`が`true`に設定されている場合に一括読み込みされる名前空間を登録します。リスト内のすべての名前空間は、`eager_load!`メソッドに応答する必要があります。

#### `config.eager_load_paths`
`config.eager_load`が`true`の場合、Railsは起動時に読み込むパスの配列を受け入れます。デフォルトでは、アプリケーションの`app`ディレクトリ内のすべてのフォルダが対象です。

#### `config.enable_reloading`

`config.enable_reloading`が`true`の場合、アプリケーションのクラスとモジュールはリクエスト間に再読み込みされます。デフォルトでは、`development`環境では`true`、`production`環境では`false`です。

述語`config.reloading_enabled?`も定義されています。

#### `config.encoding`

アプリケーション全体のエンコーディングを設定します。デフォルトではUTF-8です。

#### `config.exceptions_app`

例外が発生した場合に`ShowException`ミドルウェアによって呼び出される例外アプリケーションを設定します。
デフォルトでは`ActionDispatch::PublicExceptions.new(Rails.public_path)`です。

例外アプリケーションは、クライアントが無効な`Accept`または`Content-Type`ヘッダを送信した場合に発生する`ActionDispatch::Http::MimeNegotiation::InvalidType`エラーを処理する必要があります。
デフォルトの`ActionDispatch::PublicExceptions`アプリケーションは、これを自動的に処理し、`Content-Type`を`text/html`に設定し、`406 Not Acceptable`ステータスを返します。
このエラーを処理しないと、`500 Internal Server Error`が発生します。

例外アプリケーションとして`Rails.application.routes`の`RouteSet`を使用する場合も、この特殊な処理が必要です。
次のようなものになるかもしれません。

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

`config.reload_classes_only_on_change`が`true`の場合、ファイルシステムでファイルの更新を検出するために使用されるクラスです。Railsにはデフォルトで`ActiveSupport::FileUpdateChecker`が付属しており、`ActiveSupport::EventedFileUpdateChecker`（これは[listen](https://github.com/guard/listen) gemに依存します）も利用できます。カスタムクラスは`ActiveSupport::FileUpdateChecker`のAPIに準拠する必要があります。

#### `config.filter_parameters`

ログに表示したくないパラメータをフィルタリングするために使用されます。パスワードやクレジットカード番号などの機密情報を非表示にするために使用されます。また、Active Recordオブジェクトの`#inspect`を呼び出す際に、データベースの列の機密情報もフィルタリングされます。デフォルトでは、Railsは`config/initializers/filter_parameter_logging.rb`に以下のフィルタを追加してパスワードをフィルタリングします。

```ruby
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

パラメータフィルタは、正規表現の部分一致によって動作します。

#### `config.filter_redirect`

アプリケーションのログからリダイレクトURLをフィルタリングするために使用されます。

```ruby
Rails.application.config.filter_redirect += ['s3.amazonaws.com', /private-match/]
```

リダイレクトフィルタは、URLが文字列を含むか正規表現に一致するかをテストして動作します。

#### `config.force_ssl`

すべてのリクエストをHTTPSで提供するように強制し、URLを生成する際にデフォルトのプロトコルとして「https://」を設定します。HTTPSの強制は、`ActionDispatch::SSL`ミドルウェアによって処理され、`config.ssl_options`を介して設定できます。

#### `config.helpers_paths`

ビューヘルパーを読み込むための追加のパスの配列を定義します。

#### `config.host_authorization`

[HostAuthorizationミドルウェア](#actiondispatch-hostauthorization)を設定するためのオプションのハッシュを受け入れます。
#### `config.hosts`

`Host`ヘッダーを検証するために使用される、文字列、正規表現、または`IPAddr`の配列です。[HostAuthorizationミドルウェア](#actiondispatch-hostauthorization)によって、DNSリバインディング攻撃を防止するために使用されます。

#### `config.javascript_path`

`app`ディレクトリに対して、アプリケーションのJavaScriptが存在するパスを設定します。デフォルトは`javascript`で、[webpacker](https://github.com/rails/webpacker)で使用されます。設定された`javascript_path`は`autoload_paths`から除外されます。

#### `config.log_file_size`

Railsログファイルの最大サイズをバイト単位で定義します。デフォルトは開発環境とテスト環境では`104_857_600`（100 MiB）、その他のすべての環境では無制限です。

#### `config.log_formatter`

Railsロガーのフォーマッタを定義します。このオプションは、すべての環境でデフォルトで`ActiveSupport::Logger::SimpleFormatter`のインスタンスになります。`config.logger`に値を設定している場合は、ラッパーされる前にフォーマッタの値を手動でロガーに渡す必要があります。Railsはその処理を自動的に行いません。

#### `config.log_level`

Railsロガーの詳細度を定義します。このオプションは、本番環境を除くすべての環境でデフォルトで`:debug`になります。使用可能なログレベルは、`:debug`、`:info`、`:warn`、`:error`、`:fatal`、`:unknown`です。

#### `config.log_tags`

`request`オブジェクトが応答するメソッドのリスト、`request`オブジェクトを受け入れる`Proc`、または`to_s`に応答するものを受け入れます。これにより、サブドメインやリクエストIDなどのデバッグ情報をログ行にタグ付けすることが容易になります。これは、マルチユーザープロダクションアプリケーションのデバッグに非常に役立ちます。

#### `config.logger`

`Rails.logger`や`ActiveRecord::Base.logger`などの関連するRailsログに使用されるロガーです。デフォルトは、`log/`ディレクトリにログを出力する`ActiveSupport::Logger`のインスタンスをラップする`ActiveSupport::TaggedLogging`のインスタンスです。カスタムロガーを提供することもできますが、完全な互換性を得るためには以下のガイドラインに従う必要があります。

* フォーマッタをサポートするには、`config.log_formatter`の値からロガーにフォーマッタを手動で割り当てる必要があります。
* タグ付きログをサポートするには、ログインスタンスを`ActiveSupport::TaggedLogging`でラップする必要があります。
* サイレンスをサポートするには、ロガーに`ActiveSupport::LoggerSilence`モジュールを含める必要があります。`ActiveSupport::Logger`クラスはこれらのモジュールをすでに含んでいます。

```ruby
class MyLogger < ::Logger
  include ActiveSupport::LoggerSilence
end

mylogger           = MyLogger.new(STDOUT)
mylogger.formatter = config.log_formatter
config.logger      = ActiveSupport::TaggedLogging.new(mylogger)
```

#### `config.middleware`

アプリケーションのミドルウェアを設定することができます。詳細は、以下の[Configuring Middleware](#configuring-middleware)セクションで説明されています。

#### `config.precompile_filter_parameters`

`true`の場合、[`config.filter_parameters`](#config-filter-parameters)を[`ActiveSupport::ParameterFilter.precompile_filters`][]を使用して事前コンパイルします。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 7.1        | `true`       |
#### `config.public_file_server.enabled`

Railsを設定して、パブリックディレクトリから静的ファイルを提供するかどうかを設定します。このオプションのデフォルト値は`true`ですが、本番環境では`false`に設定されます。なぜなら、アプリケーションを実行するために使用されるサーバーソフトウェア（例：NGINXやApache）が静的ファイルを提供するべきだからです。もしWEBrickを使用して本番環境でアプリケーションを実行またはテストしている場合（本番環境でWEBrickを使用することは推奨されません）、このオプションを`true`に設定してください。そうしないと、ページキャッシュを使用したり、パブリックディレクトリ内に存在するファイルのリクエストを行うことができません。

#### `config.railties_order`

Railties/Enginesの読み込み順序を手動で指定することができます。デフォルト値は`[:all]`です。

```ruby
config.railties_order = [Blog::Engine, :main_app, :all]
```

#### `config.rake_eager_load`

`true`の場合、Rakeタスクを実行する際にアプリケーションを即時に読み込みます。デフォルト値は`false`です。

#### `config.read_encrypted_secrets`

*非推奨*: 暗号化されたシークレットの代わりに[credentials](https://guides.rubyonrails.org/security.html#custom-credentials)を使用するべきです。

`true`の場合、`config/secrets.yml.enc`から暗号化されたシークレットを読み取ろうとします。

#### `config.relative_url_root`

Railsにサブディレクトリにデプロイしていることを伝えるために使用できます（[サブディレクトリにデプロイする方法](configuring.html#deploy-to-a-subdirectory-relative-url-root)を参照）。デフォルト値は`ENV['RAILS_RELATIVE_URL_ROOT']`です。

#### `config.reload_classes_only_on_change`

トラッキングされたファイルが変更された場合にのみクラスのリロードを有効または無効にします。デフォルトではautoloadパス上のすべてをトラッキングし、`true`に設定されています。`config.enable_reloading`が`false`の場合、このオプションは無視されます。

#### `config.require_master_key`

`ENV["RAILS_MASTER_KEY"]`または`config/master.key`ファイルを介してマスターキーが利用可能でない場合、アプリケーションの起動を防ぎます。

#### `config.secret_key_base`

アプリケーションのキージェネレーターの入力シークレットの指定のフォールバックです。これを設定せずに、代わりに`config/credentials.yml.enc`で`secret_key_base`を指定することを推奨します。詳細な情報や代替の設定方法については、[`secret_key_base`のAPIドキュメント](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-secret_key_base)を参照してください。

#### `config.server_timing`

`true`の場合、[ServerTimingミドルウェア](#actiondispatch-servertiming)をミドルウェアスタックに追加します。

#### `config.session_options`

`config.session_store`に渡される追加のオプションです。自分で変更する代わりに、`config.session_store`を使用して設定するべきです。

```ruby
config.session_store :cookie_store, key: "_your_app_session"
config.session_options # => {key: "_your_app_session"}
```

#### `config.session_store`

セッションを保存するために使用するクラスを指定します。可能な値は`:cache_store`、`:cookie_store`、`:mem_cache_store`、カスタムストア、または`:disabled`です。`:disabled`はセッションを処理しないようにRailsに指示します。

この設定は、セッターではなく通常のメソッド呼び出しで行われます。これにより、追加のオプションを渡すことができます。

```ruby
config.session_store :cookie_store, key: "_your_app_session"
```

カスタムストアがシンボルで指定されている場合、`ActionDispatch::Session`の名前空間に解決されます。

```ruby
# ActionDispatch::Session::MyCustomStoreをセッションストアとして使用する
config.session_store :my_custom_store
```

デフォルトのストアは、アプリケーション名をセッションキーとするクッキーストアです。
#### `config.ssl_options`

[`ActionDispatch::SSL`](https://api.rubyonrails.org/classes/ActionDispatch/SSL.html) ミドルウェアの設定オプションです。

デフォルト値は `config.load_defaults` のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `{}`         |
| 5.0        | `{ hsts: { subdomains: true } }` |

#### `config.time_zone`

アプリケーションのデフォルトのタイムゾーンを設定し、Active Record のタイムゾーンの認識を有効にします。

#### `config.x`

アプリケーションの設定オブジェクトにネストされたカスタム設定を簡単に追加するために使用されます。

  ```ruby
  config.x.payment_processing.schedule = :daily
  Rails.configuration.x.payment_processing.schedule # => :daily
  ```

詳細は [カスタム設定](#custom-configuration) を参照してください。

### アセットの設定

#### `config.assets.css_compressor`

使用する CSS コンプレッサを定義します。デフォルトでは `sass-rails` によって設定されます。現時点で唯一の代替値は `:yui` で、`yui-compressor` ジェムを使用します。

#### `config.assets.js_compressor`

使用する JavaScript コンプレッサを定義します。可能な値は `:terser`、`:closure`、`:uglifier`、`:yui` で、それぞれ `terser`、`closure-compiler`、`uglifier`、`yui-compressor` ジェムの使用を必要とします。

#### `config.assets.gzip`

コンパイルされたアセットの gzip バージョンの作成を有効にするフラグです。デフォルトでは `true` に設定されています。

#### `config.assets.paths`

アセットの検索に使用されるパスが含まれています。この設定オプションにパスを追加すると、それらのパスがアセットの検索に使用されます。

#### `config.assets.precompile`

`bin/rails assets:precompile` を実行する際に、`application.css` と `application.js` 以外の追加のアセットを指定することができます。

#### `config.assets.unknown_asset_fallback`

asset pipeline でアセットがパイプラインにない場合の動作を変更することができます。sprockets-rails 3.2.0 以降を使用している場合にのみ有効です。

デフォルト値は `config.load_defaults` のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `true`       |
| 5.1        | `false`      |

#### `config.assets.prefix`

アセットが提供されるプレフィックスを定義します。デフォルトは `/assets` です。

#### `config.assets.manifest`

アセットプリコンパイラのマニフェストファイルに使用される完全なパスを定義します。デフォルトでは、パブリックフォルダ内の `config.assets.prefix` ディレクトリに `manifest-<random>.json` という名前のファイルが使用されます。

#### `config.assets.digest`

アセット名に SHA256 フィンガープリントの使用を有効にします。デフォルトでは `true` に設定されています。

#### `config.assets.debug`

アセットの連結と圧縮を無効にします。`development.rb` ではデフォルトで `true` に設定されています。

#### `config.assets.version`

SHA256 ハッシュ生成に使用されるオプション文字列です。すべてのファイルを再コンパイルするために変更することができます。

#### `config.assets.compile`

本番環境でのライブ Sprockets コンパイルを有効にするために使用できるブール値です。
#### `config.assets.logger`

`config.assets.logger`は、Log4rまたはデフォルトのRuby `Logger`クラスに準拠するロガーを受け入れます。`config.logger`で設定されたものと同じにデフォルトで設定されています。`config.assets.logger`を`false`に設定すると、提供されるアセットのログ記録が無効になります。

#### `config.assets.quiet`

アセットのリクエストのログ記録を無効にします。`development.rb`ではデフォルトで`true`に設定されています。

### ジェネレータの設定

Railsでは、`config.generators`メソッドを使用して使用するジェネレータを変更することができます。このメソッドはブロックを受け取ります。

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

このブロックで使用できるメソッドの完全なセットは次のとおりです。

* `force_plural`は複数形のモデル名を許可します。デフォルトは`false`です。
* `helper`はヘルパーを生成するかどうかを定義します。デフォルトは`true`です。
* `integration_tool`は統合テストを生成するために使用する統合ツールを定義します。デフォルトは`:test_unit`です。
* `system_tests`はシステムテストを生成するために使用する統合ツールを定義します。デフォルトは`:test_unit`です。
* `orm`は使用するORMを定義します。デフォルトは`false`で、デフォルトではActive Recordが使用されます。
* `resource_controller`は`bin/rails generate resource`を使用してコントローラを生成するために使用するジェネレータを定義します。デフォルトは`:controller`です。
* `resource_route`はリソースのルート定義を生成するかどうかを定義します。デフォルトは`true`です。
* `scaffold_controller`は`resource_controller`とは異なり、`bin/rails generate scaffold`を使用してスキャフォールドされたコントローラを生成するために使用するジェネレータを定義します。デフォルトは`:scaffold_controller`です。
* `test_framework`は使用するテストフレームワークを定義します。デフォルトは`false`で、デフォルトではminitestが使用されます。
* `template_engine`はERBやHamlなどの使用するテンプレートエンジンを定義します。デフォルトは`:erb`です。

### ミドルウェアの設定

すべてのRailsアプリケーションには、開発環境で以下の順序で使用される標準のミドルウェアが付属しています。

#### `ActionDispatch::HostAuthorization`

DNSリバインディングやその他の`Host`ヘッダ攻撃に対する保護を行います。
デフォルトでは、以下の設定で開発環境に含まれています。

```ruby
Rails.application.config.hosts = [
  IPAddr.new("0.0.0.0/0"),        # すべてのIPv4アドレス。
  IPAddr.new("::/0"),             # すべてのIPv6アドレス。
  "localhost",                    # ローカルホストの予約済みドメイン。
  ENV["RAILS_DEVELOPMENT_HOSTS"]  # 開発用の追加のカンマ区切りホスト。
]
```

他の環境では、`Rails.application.config.hosts`は空であり、`Host`ヘッダのチェックは行われません。本番環境でヘッダ攻撃に対して保護する場合は、許可するホストを手動で追加する必要があります。

```ruby
Rails.application.config.hosts << "product.com"
```

リクエストのホストは、ケース演算子（`#===`）を使用して`hosts`エントリと照合されます。これにより、`hosts`は`Regexp`、`Proc`、`IPAddr`などのタイプのエントリをサポートできます。以下は正規表現を使用した例です。
```ruby
# `www.product.com` や `beta1.product.com` のようなサブドメインからのリクエストを許可します。
Rails.application.config.hosts << /.*\.product\.com/
```

提供された正規表現は、アンカー（`\A` と `\z`）で囲まれるため、ホスト名全体と一致する必要があります。例えば `/product.com/` は、アンカーが付いた場合に `www.product.com` と一致しなくなります。

すべてのサブドメインを許可する特別なケースもサポートされています。

```ruby
# `www.product.com` や `beta1.product.com` のようなサブドメインからのリクエストを許可します。
Rails.application.config.hosts << ".product.com"
```

`config.host_authorization.exclude` を設定することで、ホスト認証のチェックから特定のリクエストを除外することができます。

```ruby
# `/healthcheck/` パスのリクエストをホストのチェックから除外します。
Rails.application.config.host_authorization = {
  exclude: ->(request) { request.path.include?('healthcheck') }
}
```

認可されていないホストにリクエストが来た場合、デフォルトの Rack アプリケーションが実行され、`403 Forbidden` で応答します。これは `config.host_authorization.response_app` を設定することでカスタマイズすることができます。

```ruby
Rails.application.config.host_authorization = {
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

#### `ActionDispatch::ServerTiming`

`Server-Timing` ヘッダーにメトリクスを追加し、ブラウザの開発ツールで表示する機能を提供します。

#### `ActionDispatch::SSL`

すべてのリクエストを HTTPS を使用して提供するように強制します。`config.force_ssl` が `true` に設定されている場合に有効になります。このオプションには `config.ssl_options` を設定することで構成できます。

#### `ActionDispatch::Static`

静的アセットを提供するために使用されます。`config.public_file_server.enabled` が `false` の場合は無効になります。ディレクトリリクエストに対して `index` という名前の静的ディレクトリインデックスファイルではなく、`main.html` のような別のファイルを提供する場合は、`config.public_file_server.index_name` を設定します。例えば、`config.public_file_server.index_name` を `"main"` に設定すると、ディレクトリリクエストに対して `index.html` の代わりに `main.html` を提供します。

#### `ActionDispatch::Executor`

スレッドセーフなコードのリロードを許可します。`config.allow_concurrency` が `false` の場合は無効になり、`Rack::Lock` が読み込まれます。`Rack::Lock` はアプリをミューテックスでラップし、一度に1つのスレッドからのみ呼び出すことができるようにします。

#### `ActiveSupport::Cache::Strategy::LocalCache`

基本的なメモリバックキャッシュとして機能します。このキャッシュはスレッドセーフではなく、単一のスレッドの一時的なメモリキャッシュとしてのみ使用することが意図されています。

#### `Rack::Runtime`

リクエストの実行にかかった時間（秒単位）を含む `X-Runtime` ヘッダーを設定します。

#### `Rails::Rack::Logger`

リクエストが開始したことをログに通知します。リクエストが完了した後、すべてのログをフラッシュします。

#### `ActionDispatch::ShowExceptions`

アプリケーションが返した例外をキャッチし、リクエストがローカルであるか、`config.consider_all_requests_local` が `true` に設定されている場合は、見やすい例外ページを表示します。`config.action_dispatch.show_exceptions` が `:none` に設定されている場合、例外は常に発生します。

#### `ActionDispatch::RequestId`

一意の X-Request-Id ヘッダーをレスポンスで利用できるようにし、`ActionDispatch::Request#uuid` メソッドを有効にします。`config.action_dispatch.request_id_header` で設定可能です。

#### `ActionDispatch::RemoteIp`

IPスーフィング攻撃をチェックし、リクエストヘッダーから有効な `client_ip` を取得します。`config.action_dispatch.ip_spoofing_check` と `config.action_dispatch.trusted_proxies` オプションで設定可能です。
#### `Rack::Sendfile`

ファイルから提供されるレスポンスのボディをインターセプトし、サーバー固有のX-Sendfileヘッダーに置き換えます。`config.action_dispatch.x_sendfile_header`で設定可能です。

#### `ActionDispatch::Callbacks`

リクエストを処理する前に、準備コールバックを実行します。

#### `ActionDispatch::Cookies`

リクエストにクッキーを設定します。

#### `ActionDispatch::Session::CookieStore`

セッションをクッキーに保存する責任を持ちます。[`config.session_store`](#config-session-store)を変更することで、代替のミドルウェアを使用することもできます。

#### `ActionDispatch::Flash`

`flash`キーを設定します。[`config.session_store`](#config-session-store)が設定されている場合にのみ利用可能です。

#### `Rack::MethodOverride`

`params[:_method]`が設定されている場合、メソッドを上書きすることを許可します。これは、PATCH、PUT、DELETEのHTTPメソッドタイプをサポートするミドルウェアです。

#### `Rack::Head`

HEADリクエストをGETリクエストに変換し、それとして提供します。

#### カスタムミドルウェアの追加

これらの通常のミドルウェア以外にも、`config.middleware.use`メソッドを使用して独自のミドルウェアを追加することができます。

```ruby
config.middleware.use Magical::Unicorns
```

これにより、`Magical::Unicorns`ミドルウェアがスタックの最後に配置されます。他のミドルウェアの前にミドルウェアを追加したい場合は、`insert_before`を使用することもできます。

```ruby
config.middleware.insert_before Rack::Head, Magical::Unicorns
```

また、インデックスを使用してミドルウェアを特定の位置に挿入することもできます。たとえば、スタックの一番上に`Magical::Unicorns`ミドルウェアを挿入したい場合は、次のようにします。

```ruby
config.middleware.insert_before 0, Magical::Unicorns
```

`insert_after`を使用すると、別のミドルウェアの後にミドルウェアを挿入できます。

```ruby
config.middleware.insert_after Rack::Head, Magical::Unicorns
```

ミドルウェアは完全に入れ替えて他のミドルウェアと置き換えることもできます。

```ruby
config.middleware.swap ActionController::Failsafe, Lifo::Failsafe
```

ミドルウェアを別の場所に移動することもできます。

```ruby
config.middleware.move_before ActionDispatch::Flash, Magical::Unicorns
```

これにより、`Magical::Unicorns`ミドルウェアが`ActionDispatch::Flash`の前に移動します。また、後ろに移動することもできます。

```ruby
config.middleware.move_after ActionDispatch::Flash, Magical::Unicorns
```

ミドルウェアをスタックから完全に削除することもできます。

```ruby
config.middleware.delete Rack::MethodOverride
```

### i18nの設定

これらの設定オプションはすべて`I18n`ライブラリに委譲されます。

#### `config.i18n.available_locales`

アプリケーションで許可される利用可能なロケールを定義します。通常、新しいアプリケーションではロケールファイルで見つかるすべてのロケールキー、通常は`：en`のみがデフォルトです。

#### `config.i18n.default_locale`

i18nで使用されるアプリケーションのデフォルトロケールを設定します。デフォルトは`：en`です。

#### `config.i18n.enforce_available_locales`

i18nを介して渡されるすべてのロケールが`available_locales`リストに宣言されている必要があることを保証し、利用できないロケールを設定すると`I18n::InvalidLocale`例外が発生するようにします。デフォルトは`true`です。ユーザーの入力からの無効なロケールの設定を防ぐセキュリティ対策として、このオプションを無効にしないことをお勧めします。

#### `config.i18n.load_path`

Railsがロケールファイルを検索するために使用するパスを設定します。デフォルトは`config/locales/**/*.{yml,rb}`です。
#### `config.i18n.raise_on_missing_translations`

翻訳が見つからない場合にエラーを発生させるかどうかを決定します。デフォルトは`false`です。

#### `config.i18n.fallbacks`

翻訳が見つからない場合のフォールバックの動作を設定します。このオプションの使用例を3つ示します。

  * デフォルトのロケールをフォールバックとして使用するために、オプションを`true`に設定できます。以下のように設定します。

    ```ruby
    config.i18n.fallbacks = true
    ```

  * フォールバックとしてロケールの配列を設定することもできます。以下のように設定します。

    ```ruby
    config.i18n.fallbacks = [:tr, :en]
    ```

  * 個々のロケールに対して異なるフォールバックを設定することもできます。たとえば、`:az`と`:de`には`:tr`を、`:da`には`:en`をフォールバックとして使用したい場合、以下のように設定できます。

    ```ruby
    config.i18n.fallbacks = { az: :tr, da: [:de, :en] }
    #または
    config.i18n.fallbacks.map = { az: :tr, da: [:de, :en] }
    ```

### Active Modelの設定

#### `config.active_model.i18n_customize_full_message`

i18nロケールファイルで[`Error#full_message`][ActiveModel::Error#full_message]のフォーマットを上書きできるかどうかを制御します。デフォルトは`false`です。

`true`に設定すると、`full_message`はロケールファイルの属性およびモデルレベルでフォーマットを探します。デフォルトのフォーマットは`"%{attribute} %{message}"`で、`attribute`は属性の名前、`message`はバリデーション固有のメッセージです。以下の例では、`Person`のすべての属性と特定の属性（`age`）のフォーマットを上書きしています。

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
          # すべてのPersonの属性のフォーマットを上書きします:
          format: "Invalid %{attribute} (%{message})"
          attributes:
            age:
              # age属性のフォーマットを上書きします:
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


### Active Recordの設定

`config.active_record`にはさまざまな設定オプションが含まれています。

#### `config.active_record.logger`

Log4rのインターフェースに準拠するロガーまたはデフォルトのRuby Loggerクラスを受け入れます。これは新しいデータベース接続に渡されます。Active RecordモデルクラスまたはActive Recordモデルインスタンスの`logger`を呼び出すことでこのロガーを取得できます。ログを無効にするには`nil`に設定します。

#### `config.active_record.primary_key_prefix_type`

プライマリキーカラムの命名を調整することができます。デフォルトでは、Railsはプライマリキーカラムを`id`と仮定します（この設定オプションは設定する必要はありません）。他に2つの選択肢があります。
* `:table_name` は、Customer クラスの主キーを `customerid` にします。
* `:table_name_with_underscore` は、Customer クラスの主キーを `customer_id` にします。

#### `config.active_record.table_name_prefix`

テーブル名の前に追加するグローバルな文字列を設定します。これを `northwest_` に設定すると、Customer クラスは `northwest_customers` をテーブルとして使用します。デフォルトは空の文字列です。

#### `config.active_record.table_name_suffix`

テーブル名の後に追加するグローバルな文字列を設定します。これを `_northwest` に設定すると、Customer クラスは `customers_northwest` をテーブルとして使用します。デフォルトは空の文字列です。

#### `config.active_record.schema_migrations_table_name`

スキーママイグレーションテーブルの名前として使用する文字列を設定します。

#### `config.active_record.internal_metadata_table_name`

内部メタデータテーブルの名前として使用する文字列を設定します。

#### `config.active_record.protected_environments`

破壊的なアクションが禁止される環境の名前の配列を設定します。

#### `config.active_record.pluralize_table_names`

Rails がデータベース内の単数形または複数形のテーブル名を探すかを指定します。`true` に設定すると（デフォルト）、Customer クラスは `customers` テーブルを使用します。`false` に設定すると、Customer クラスは `customer` テーブルを使用します。

#### `config.active_record.default_timezone`

データベースから日付と時刻を取得する際に `Time.local`（`:local` に設定されている場合）または `Time.utc`（`:utc` に設定されている場合）を使用するかを決定します。デフォルトは `:utc` です。

#### `config.active_record.schema_format`

データベースのスキーマをファイルにダンプするためのフォーマットを制御します。オプションは、マイグレーションに依存するデータベース非依存のバージョンである `:ruby`（デフォルト）または（データベースに依存する可能性のある）SQL ステートメントのセットである `:sql` です。

#### `config.active_record.error_on_ignored_order`

バッチクエリの実行中にクエリの順序が無視された場合にエラーを発生させるかどうかを指定します。オプションは `true`（エラーを発生させる）または `false`（警告を表示する）です。デフォルトは `false` です。

#### `config.active_record.timestamped_migrations`

マイグレーションの番号付けに連続した整数またはタイムスタンプを使用するかどうかを制御します。デフォルトは `true` で、複数の開発者が同じアプリケーションで作業している場合はタイムスタンプが推奨されます。

#### `config.active_record.db_warnings_action`

SQL クエリが警告を生成した場合に実行するアクションを制御します。次のオプションが利用可能です：

  * `:ignore` - データベースの警告は無視されます。これがデフォルトです。

  * `:log` - データベースの警告は `ActiveRecord.logger` で `:warn` レベルでログに記録されます。

  * `:raise` - データベースの警告は `ActiveRecord::SQLWarning` として発生します。

  * `:report` - データベースの警告は Rails のエラーレポーターのサブスクライバに報告されます。

  * カスタムな proc - カスタムな proc を指定できます。`SQLWarning` エラーオブジェクトを受け入れる必要があります。
例えば：

```ruby
config.active_record.db_warnings_action = ->(warning) do
  # カスタムの例外報告サービスに報告する
  Bugsnag.notify(warning.message) do |notification|
    notification.add_metadata(:warning_code, warning.code)
    notification.add_metadata(:warning_level, warning.level)
  end
end
```

#### `config.active_record.db_warnings_ignore`

設定された`db_warnings_action`に関係なく、無視されるべき警告コードとメッセージのホワイトリストを指定します。
デフォルトの動作はすべての警告を報告することです。無視する警告は文字列または正規表現で指定できます。例えば：

```ruby
config.active_record.db_warnings_action = :raise
# 以下の警告は発生しません
config.active_record.db_warnings_ignore = [
  /Invalid utf8mb4 character string/,
  "An exact warning message",
  "1062", # MySQL Error 1062: Duplicate entry
]
```

#### `config.active_record.migration_strategy`

マイグレーションでスキーマステートメントメソッドを実行するために使用されるストラテジークラスを制御します。デフォルトのクラスは
接続アダプタに委譲します。カスタムのストラテジーは`ActiveRecord::Migration::ExecutionStrategy`を継承するか、
実装されていないメソッドのデフォルトの動作を保持するために`DefaultStrategy`を継承することができます：

```ruby
class CustomMigrationStrategy < ActiveRecord::Migration::DefaultStrategy
  def drop_table(*)
    raise "Dropping tables is not supported!"
  end
end

config.active_record.migration_strategy = CustomMigrationStrategy
```

#### `config.active_record.lock_optimistically`

Active Recordが楽観的ロックを使用するかどうかを制御し、デフォルトでは`true`です。

#### `config.active_record.cache_timestamp_format`

キャッシュキーのタイムスタンプ値のフォーマットを制御します。デフォルトは`:usec`です。

#### `config.active_record.record_timestamps`

モデルの`create`および`update`操作のタイムスタンプの記録が行われるかどうかを制御するブール値です。デフォルト値は`true`です。

#### `config.active_record.partial_inserts`

新しいレコードを作成する際に部分的な書き込みが使用されるかどうかを制御するブール値です（つまり、デフォルトと異なる属性のみが設定されるかどうか）。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します：

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元々の値) | `true`       |
| 7.0        | `false`      |

#### `config.active_record.partial_updates`

既存のレコードを更新する際に部分的な書き込みが使用されるかどうかを制御するブール値です（つまり、変更された属性のみが設定されるかどうか）。部分的な更新を使用する場合は、可能性のある古い読み取り状態に基づいて属性を書き込むため、楽観的ロック`config.active_record.lock_optimistically`も使用する必要があります。デフォルト値は`true`です。

#### `config.active_record.maintain_test_schema`

テストデータベースのスキーマを`db/schema.rb`（または`db/structure.sql`）と最新の状態に保つかどうかを制御するブール値です。デフォルトは`true`です。

#### `config.active_record.dump_schema_after_migration`

マイグレーションを実行する際にスキーマダンプ（`db/schema.rb`または`db/structure.sql`）を行うかどうかを制御するフラグです。これはRailsによって生成される`config/environments/production.rb`では`false`に設定されています。この設定がされていない場合、デフォルト値は`true`です。
#### `config.active_record.dump_schemas`

`db:schema:dump`を呼び出した際にダンプされるデータベーススキーマを制御します。
オプションは`:schema_search_path`（デフォルト）で、`schema_search_path`にリストされているスキーマをダンプします。
`:all`は`schema_search_path`に関係なくすべてのスキーマを常にダンプします。
または、カンマで区切られたスキーマの文字列です。

#### `config.active_record.before_committed_on_all_records`

トランザクションに登録されたすべてのレコードに対してbefore_committed!コールバックを有効にします。
以前の動作では、同じレコードの複数のコピーがトランザクションに登録されている場合、最初のコピーのみコールバックが実行されました。

| バージョンから開始 | デフォルト値は |
| ----------------- | ------------ |
| （元の値）         | `false`        |
| 7.1               | `true`         |

#### `config.active_record.belongs_to_required_by_default`

ブール値で、`belongs_to`関連付けが存在しない場合にレコードがバリデーションに失敗するかどうかを制御します。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョンから開始 | デフォルト値は |
| ----------------- | ------------ |
| （元の値）         | `nil`        |
| 5.0               | `true`       |

#### `config.active_record.belongs_to_required_validates_foreign_key`

親が必須の場合に、親に関連する列の存在のみを検証するようにします。
以前の動作では、親レコードの存在を検証し、子レコードが更新されるたびに親を取得するため、親が変更されていない場合でも余分なクエリが実行されました。

| バージョンから開始 | デフォルト値は |
| ----------------- | ------------ |
| （元の値）         | `true`       |
| 7.1               | `false`      |

#### `config.active_record.marshalling_format_version`

`7.1`に設定すると、Active Recordインスタンスのシリアル化に`Marshal.dump`を使用した効率的な方法が有効になります。

これにより、シリアル化形式が変更されるため、この方法でシリアル化されたモデルは古い（< 7.1）バージョンのRailsでは読み取ることができません。ただし、この最適化が有効になっているかどうかに関係なく、古い形式を使用するメッセージは引き続き読み取ることができます。

| バージョンから開始 | デフォルト値は |
| ----------------- | ------------ |
| （元の値）         | `6.1`        |
| 7.1               | `7.1`        |

#### `config.active_record.action_on_strict_loading_violation`

関連付けにstrict_loadingが設定されている場合に例外を発生させるか、ログに記録するかを制御します。デフォルト値はすべての環境で`:raise`です。例外を発生させる代わりに違反をロガーに送信するために`:log`に変更することもできます。

#### `config.active_record.strict_loading_by_default`

ブール値で、strict_loadingモードをデフォルトで有効または無効にします。デフォルトは`false`です。

#### `config.active_record.warn_on_records_fetched_greater_than`

クエリの結果のサイズに対する警告の閾値を設定できます。クエリによって返されるレコードの数が閾値を超える場合、警告がログに記録されます。これにより、メモリの膨張を引き起こす可能性のあるクエリを特定することができます。
#### `config.active_record.index_nested_attribute_errors`

`has_many`のネストした関係のエラーをインデックスとともに表示することができます。デフォルトは`false`です。

#### `config.active_record.use_schema_cache_dump`

データベースへのクエリを送信せずに、`db/schema_cache.yml`からスキーマキャッシュ情報を取得できるようにします（`bin/rails db:schema:cache:dump`によって生成されます）。デフォルトは`true`です。

#### `config.active_record.cache_versioning`

`#cache_version`メソッドで変化するバージョンと共に安定した`#cache_key`メソッドを使用するかどうかを示します。

デフォルト値は、`config.load_defaults`のターゲットバージョンによって異なります。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 5.2        | `true`       |

#### `config.active_record.collection_cache_versioning`

キャッシュされるオブジェクトのタイプが`ActiveRecord::Relation`である場合、リレーションのキャッシュキーのボラティル情報（最大更新日時とカウント）をキャッシュバージョンに移動して、同じキャッシュキーを再利用できるようにします。

デフォルト値は、`config.load_defaults`のターゲットバージョンによって異なります。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 6.0        | `true`       |

#### `config.active_record.has_many_inversing`

`belongs_to`から`has_many`への関連付けをトラバースする際に、逆のレコードを設定できるようにします。

デフォルト値は、`config.load_defaults`のターゲットバージョンによって異なります。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 6.1        | `true`       |

#### `config.active_record.automatic_scope_inversing`

スコープを持つ関連付けに対して`inverse_of`を自動的に推測できるようにします。

デフォルト値は、`config.load_defaults`のターゲットバージョンによって異なります。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 7.0        | `true`       |

#### `config.active_record.destroy_association_async_job`

関連するレコードをバックグラウンドで破棄するために使用されるジョブを指定できます。デフォルトは`ActiveRecord::DestroyAssociationAsyncJob`です。

#### `config.active_record.destroy_association_async_batch_size`

`dependent: :destroy_async`関連オプションによってバックグラウンドジョブで破棄される最大レコード数を指定できます。他の条件が同じ場合、バッチサイズが小さいほど、より多くの短時間実行のバックグラウンドジョブがエンキューされます。一方、バッチサイズが大きいほど、より少ない長時間実行のバックグラウンドジョブがエンキューされます。このオプションのデフォルト値は`nil`で、同じ関連の依存レコードが同じバックグラウンドジョブで破棄されます。

#### `config.active_record.queues.destroy`

破棄ジョブに使用するActive Jobキューを指定できます。このオプションが`nil`の場合、パージジョブはデフォルトのActive Jobキューに送信されます（`config.active_job.default_queue_name`を参照）。デフォルトは`nil`です。
#### `config.active_record.enumerate_columns_in_select_statements`

`true`の場合、常に`SELECT`文にカラム名を含め、ワイルドカードの`SELECT * FROM ...`クエリを避けます。これにより、PostgreSQLデータベースにカラムを追加する際のプリペアドステートメントキャッシュエラーを回避できます。デフォルトは`false`です。

#### `config.active_record.verify_foreign_keys_for_fixtures`

テストでフィクスチャがロードされた後にすべての外部キー制約が有効であることを確認します。PostgreSQLとSQLiteのみでサポートされています。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 7.0        | `true`       |

#### `config.active_record.raise_on_assign_to_attr_readonly`

`attr_readonly`属性への代入時に例外を発生させるようにします。以前の動作では、代入は許可されますが、データベースへの変更は黙って保存されませんでした。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 7.1        | `true`       |

#### `config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`

複数のActive Recordインスタンスがトランザクション内で同じレコードを変更する場合、Railsは`after_commit`または`after_rollback`コールバックを1つのインスタンスのみに実行します。このオプションは、Railsがどのインスタンスにコールバックを送信するかを指定します。

`true`の場合、トランザクションのコミットコールバックは最初に保存されたインスタンスで実行されますが、そのインスタンスの状態が古くなっている可能性があります。

`false`の場合、トランザクションのコミットコールバックは最新のインスタンス状態を持つインスタンスで実行されます。これらのインスタンスは次のように選択されます。

- 一般的には、トランザクション内で特定のレコードを保存する最後のインスタンスでトランザクションのコミットコールバックを実行します。
- ただし、2つの例外があります。
    - レコードがトランザクション内で作成され、別のインスタンスによって更新された場合、`after_create_commit`コールバックは2番目のインスタンスで実行されます。これは、そのインスタンスの状態に基づいて単純に実行されるはずの`after_update_commit`コールバックの代わりです。
    - レコードがトランザクション内で削除され、その後に古いインスタンスが更新を実行した場合、`after_destroy_commit`コールバックは最後に削除されたインスタンスで実行されます（これにより、0行に影響を与えた更新が行われた可能性があります）。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `true`       |
| 7.1        | `false`      |

#### `config.active_record.default_column_serializer`

指定されていない場合に使用するシリアライザの実装です。指定されていない場合、`serialize`および`store`は、デフォルトで`YAML`を使用していましたが、これは効率的なフォーマットではなく、注意深く使用しないとセキュリティの脆弱性の原因になる可能性があります。

そのため、データベースのシリアル化にはより厳密で制限されたフォーマットを使用することを推奨します。
残念ながら、Rubyの標準ライブラリには適切なデフォルトはありません。`JSON`はフォーマットとして機能するかもしれませんが、`json`のgemはサポートされていない型を文字列に変換するため、バグが発生する可能性があります。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョンから始まる | デフォルト値は |
| --------------------- | -------------------- |
| (元の)            | `YAML`               |
| 7.1                   | `nil`                |

#### `config.active_record.run_after_transaction_callbacks_in_order_defined`

trueの場合、`after_commit`コールバックはモデルで定義された順序で実行されます。falseの場合、逆の順序で実行されます。

他のすべてのコールバックは、モデルで定義された順序で常に実行されます（`prepend: true`を使用しない限り）。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョンから始まる | デフォルト値は |
| --------------------- | -------------------- |
| (元の)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.query_log_tags_enabled`

アダプターレベルのクエリコメントを有効にするかどうかを指定します。デフォルトは`false`です。

注意：これを`true`に設定すると、データベースのプリペアドステートメントが自動的に無効になります。

#### `config.active_record.query_log_tags`

SQLコメントに挿入されるキー/値タグを指定する`Array`を定義します。デフォルトは`[ :application ]`で、アプリケーション名を返す事前定義のタグです。

#### `config.active_record.query_log_tags_format`

タグのフォーマッターを指定する`Symbol`です。有効な値は`:sqlcommenter`と`:legacy`です。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョンから始まる | デフォルト値は |
| --------------------- | -------------------- |
| (元の)            | `:legacy`            |
| 7.1                   | `:sqlcommenter`      |

#### `config.active_record.cache_query_log_tags`

クエリログタグのキャッシュを有効にするかどうかを指定します。大量のクエリを持つアプリケーションでは、クエリログタグのキャッシュは、リクエストやジョブの実行の寿命中にコンテキストが変わらない場合にパフォーマンスの利点を提供することができます。デフォルトは`false`です。

#### `config.active_record.schema_cache_ignored_tables`

スキーマキャッシュの生成時に無視するテーブルのリストを定義します。テーブル名を表す文字列または正規表現の`Array`を受け入れます。

#### `config.active_record.verbose_query_logs`

データベースクエリを呼び出すメソッドのソース位置を関連するクエリの下にログに記録するかどうかを指定します。デフォルトでは、開発環境ではフラグが`true`になり、他のすべての環境では`false`になります。

#### `config.active_record.sqlite3_adapter_strict_strings_by_default`

SQLite3Adapterを厳密な文字列モードで使用するかどうかを指定します。厳密な文字列モードの使用は、二重引用符で囲まれた文字列リテラルを無効にします。

SQLiteには二重引用符で囲まれた文字列リテラルに関するいくつかの特異点があります。
まず、二重引用符で囲まれた文字列を識別子として考慮しようとしますが、存在しない場合は文字列リテラルとして考慮します。そのため、タイプミスが静かに見落とされる可能性があります。
たとえば、存在しない列にインデックスを作成することができます。
詳細については、[SQLiteのドキュメント](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted)を参照してください。
デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します：

| バージョン | デフォルト値 |
| --------------------- | -------------------- |
| (元の値)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.async_query_executor`

非同期クエリのプール方法を指定します。

デフォルトは`nil`で、`load_async`が無効になり、代わりにクエリを直接フォアグラウンドで実行します。
クエリを実際に非同期に実行するには、`config.active_record.async_query_executor`を`:global_thread_pool`または`:multi_thread_pool`に設定する必要があります。

`:global_thread_pool`は、アプリケーションが接続するすべてのデータベースに対して単一のプールを使用します。これは、単一のデータベースを持つアプリケーションや、常に1つのデータベースシャードのみをクエリするアプリケーションに適した構成です。

`:multi_thread_pool`は、データベースごとに1つのプールを使用し、各プールのサイズは`database.yml`で`max_threads`と`min_thread`プロパティを介して個別に設定できます。これは、複数のデータベースを定期的にクエリし、最大同時実行数をより正確に定義する必要があるアプリケーションに役立ちます。

#### `config.active_record.global_executor_concurrency`

`config.active_record.async_query_executor = :global_thread_pool`と共に使用され、同時に実行できる非同期クエリの数を定義します。

デフォルトは`4`です。

この数は、`database.yml`で設定されたデータベースプールのサイズと合わせて考慮する必要があります。接続プールは、フォアグラウンドスレッド（例：Webサーバーまたはジョブワーカースレッド）とバックグラウンドスレッドの両方を収容するのに十分な大きさである必要があります。

#### `config.active_record.allow_deprecated_singular_associations_name`

これにより、`where`句で単数の関連を複数形の名前で参照できる非推奨の動作が有効になります。これを`false`に設定すると、パフォーマンスが向上します。

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end

Comment.where(post: post_id).count  # => 5

# `allow_deprecated_singular_associations_name`がtrueの場合：
Comment.where(posts: post_id).count # => 5 (非推奨の警告)

# `allow_deprecated_singular_associations_name`がfalseの場合：
Comment.where(posts: post_id).count # => エラー
```

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します：

| バージョン | デフォルト値 |
| --------------------- | -------------------- |
| (元の値)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.yaml_column_permitted_classes`

デフォルトは`[Symbol]`です。アプリケーションが`ActiveRecord::Coders::YAMLColumn`の`safe_load()`に追加の許可されたクラスを含めることを許可します。

#### `config.active_record.use_yaml_unsafe_load`

デフォルトは`false`です。アプリケーションが`ActiveRecord::Coders::YAMLColumn`の`unsafe_load`を使用することを選択できるようにします。

#### `config.active_record.raise_int_wider_than_64bit`

デフォルトは`true`です。PostgreSQLアダプタに64ビット符号付き表現よりも広い整数が提供された場合に例外を発生させるかどうかを決定します。

#### `ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans`および`ActiveRecord::ConnectionAdapters::TrilogyAdapter.emulate_booleans`

Active Record MySQLアダプタがすべての`tinyint(1)`列をブール値として扱うかどうかを制御します。デフォルトは`true`です。

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.create_unlogged_tables`

PostgreSQLによって作成されたデータベーステーブルが「unlogged」になるかどうかを制御します。これによりパフォーマンスが向上しますが、データベースがクラッシュした場合のデータの損失のリスクが増加します。本番環境ではこれを有効にしないことを強くお勧めします。すべての環境でデフォルトは`false`です。
テストのためにこれを有効にするには：

```ruby
# config/environments/test.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.create_unlogged_tables = true
end
```

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type`

Active Record PostgreSQLアダプターがマイグレーションやスキーマで`datetime`を呼び出したときに使用するネイティブタイプを制御します。設定された`NATIVE_DATABASE_TYPES`のいずれかに対応するシンボルを取ります。デフォルトは`:timestamp`で、マイグレーションの`t.datetime`は「タイムゾーンなしのタイムスタンプ」カラムを作成します。

「タイムゾーンありのタイムスタンプ」を使用するには：

```ruby
# config/application.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.datetime_type = :timestamptz
end
```

これを変更した場合は、`bin/rails db:migrate`を実行してschema.rbを再構築する必要があります。

#### `ActiveRecord::SchemaDumper.ignore_tables`

生成されるスキーマファイルに含まれないテーブルの配列を受け入れます。

#### `ActiveRecord::SchemaDumper.fk_ignore_pattern`

外部キーの名前がdb/schema.rbにダンプされるかどうかを決定するために使用される異なる正規表現を設定できます。デフォルトでは、`fk_rails_`で始まる外部キー名はデータベーススキーマダンプにエクスポートされません。デフォルトは`/^fk_rails_[0-9a-f]{10}$/`です。

#### `config.active_record.encryption.hash_digest_class`

Active Record Encryptionで使用されるダイジェストアルゴリズムを設定します。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します：

| バージョンから開始 | デフォルト値 |
|-----------------------|----------------------|
| (元の値)            | `OpenSSL::Digest::SHA1`   |
| 7.1                   | `OpenSSL::Digest::SHA256` |

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

SHA-1ダイジェストクラスを使用して暗号化された既存のデータの復号をサポートするかどうかを有効にします。`false`の場合、`config.active_record.encryption.hash_digest_class`で設定されたダイジェストのみをサポートします。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します：

| バージョンから開始 | デフォルト値 |
|-----------------------|----------------------|
| (元の値)            | `true`               |
| 7.1                   | `false`              |

### Action Controllerの設定

`config.action_controller`には、いくつかの設定が含まれています：

#### `config.action_controller.asset_host`

アセットのホストを設定します。アプリケーションサーバー自体ではなく、CDNがアセットをホストする場合に便利です。これはAction Mailerの設定と異なる場合にのみ使用する必要があります。そうでなければ、`config.asset_host`を使用してください。

#### `config.action_controller.perform_caching`

アプリケーションがAction Controllerコンポーネントが提供するキャッシュ機能を使用するかどうかを設定します。開発環境では`false`に設定し、本番環境では`true`に設定します。指定されていない場合、デフォルトは`true`になります。

#### `config.action_controller.default_static_extension`

キャッシュされたページに使用される拡張子を設定します。デフォルトは`.html`です。

#### `config.action_controller.include_all_helpers`

すべてのビューヘルパーがどこでも使用可能か、対応するコントローラーにスコープがあるかを設定します。`false`に設定すると、`UsersHelper`メソッドは`UsersController`の一部としてレンダリングされるビューでのみ使用できます。`true`の場合、`UsersHelper`メソッドはどこでも使用できます。このオプションが明示的に`true`または`false`に設定されていない場合のデフォルトの設定動作は、すべてのビューヘルパーが各コントローラーで使用できることです。
#### `config.action_controller.logger`

Log4rまたはデフォルトのRuby Loggerクラスに準拠するロガーを受け入れ、それを使用してAction Controllerから情報をログに記録します。ログを無効にするには`nil`に設定します。

#### `config.action_controller.request_forgery_protection_token`

RequestForgeryのトークンパラメータ名を設定します。`protect_from_forgery`を呼び出すと、デフォルトで`:authenticity_token`に設定されます。

#### `config.action_controller.allow_forgery_protection`

CSRF保護を有効または無効にします。デフォルトでは、テスト環境では`false`、その他のすべての環境では`true`です。

#### `config.action_controller.forgery_protection_origin_check`

HTTPの`Origin`ヘッダーがサイトのオリジンと一致するかどうかをチェックするかどうかを設定します。デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元のバージョン) | `false` |
| 5.0 | `true` |

#### `config.action_controller.per_form_csrf_tokens`

CSRFトークンが生成されたメソッド/アクションにのみ有効かどうかを設定します。デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元のバージョン) | `false` |
| 5.0 | `true` |

#### `config.action_controller.default_protect_from_forgery`

`ActionController::Base`に対してForgery保護が追加されるかどうかを決定します。デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元のバージョン) | `false` |
| 5.2 | `true` |

#### `config.action_controller.relative_url_root`

Railsが[サブディレクトリにデプロイされていることを伝えるために使用できます](
configuring.html#deploy-to-a-subdirectory-relative-url-root)。デフォルトは
[`config.relative_url_root`](#config-relative-url-root)です。

#### `config.action_controller.permit_all_parameters`

デフォルトで、マスアサインメントのためにすべてのパラメータが許可されます。デフォルト値は`false`です。

#### `config.action_controller.action_on_unpermitted_parameters`

明示的に許可されていないパラメータが見つかった場合の動作を制御します。デフォルト値はテスト環境と開発環境では`:log`、それ以外では`false`です。値は次のとおりです。

* `false`：何も行動しない
* `:log`：`unpermitted_parameters.action_controller`トピックで`ActiveSupport::Notifications.instrument`イベントを発行し、DEBUGレベルでログを出力する
* `:raise`：`ActionController::UnpermittedParameters`例外を発生させる

#### `config.action_controller.always_permitted_parameters`

デフォルトで許可されている許可されたパラメータのリストを設定します。デフォルト値は`['controller', 'action']`です。

#### `config.action_controller.enable_fragment_cache_logging`

フラグメントキャッシュの読み取りと書き込みを詳細な形式でログに記録するかどうかを決定します。デフォルトでは次のように設定されています。

```
Read fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/d0bdf2974e1ef6d31685c3b392ad0b74 (0.6ms)
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Write fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/3b4e249ac9d168c617e32e84b99218b5 (1.1ms)
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

デフォルトでは`false`に設定されており、次の出力が生成されます。

```
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```
#### `config.action_controller.raise_on_open_redirects`

許可されていないオープンリダイレクトが発生した場合に、`ActionController::Redirecting::UnsafeRedirectError`を発生させます。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します：

| バージョンから | デフォルト値 |
| --------------------- | -------------------- |
| (元のバージョン)            | `false`              |
| 7.0                   | `true`               |

#### `config.action_controller.log_query_tags_around_actions`

クエリタグのコントローラコンテキストが`around_filter`を介して自動的に更新されるかどうかを決定します。デフォルト値は`true`です。

#### `config.action_controller.wrap_parameters_by_default`

[`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)をデフォルトでJSONリクエストをラップするように設定します。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します：

| バージョンから | デフォルト値 |
| --------------------- | -------------------- |
| (元のバージョン)            | `false`              |
| 7.0                   | `true`               |

#### `ActionController::Base.wrap_parameters`

[`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)を設定します。これはトップレベルで呼び出すことも、個々のコントローラで呼び出すこともできます。

#### `config.action_controller.allow_deprecated_parameters_hash_equality`

`ActionController::Parameters#==`の`Hash`引数との振る舞いを制御します。設定の値によって、`ActionController::Parameters`インスタンスが等しいかどうかが決まります。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します：

| バージョンから | デフォルト値 |
| --------------------- | -------------------- |
| (元のバージョン)            | `true`               |
| 7.1                   | `false`              |

### Action Dispatchの設定

#### `config.action_dispatch.cookies_serializer`

クッキーに使用するシリアライザを指定します。[`config.active_support.message_serializer`](#config-active-support-message-serializer)と同じ値を受け入れます。また、`:hybrid`は`json_allow_marshal`のエイリアスです。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します：

| バージョンから | デフォルト値 |
| --------------------- | -------------------- |
| (元のバージョン)            | `:marshal`           |
| 7.0                   | `:json`              |

#### `config.action_dispatch.debug_exception_log_level`

リクエスト中に未処理の例外が発生した場合に、DebugExceptionsミドルウェアが使用するログレベルを設定します。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します：

| バージョンから | デフォルト値 |
| --------------------- | -------------------- |
| (元のバージョン)            | `:fatal`             |
| 7.1                   | `:error`             |

#### `config.action_dispatch.default_headers`

各レスポンスでデフォルトで設定されるHTTPヘッダーのハッシュです。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します：

| バージョンから | デフォルト値 |
| --------------------- | -------------------- |
| (元のバージョン)            | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "1; mode=block",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.0                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.1                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
#### `config.action_dispatch.default_charset`

すべてのレンダリングのデフォルトの文字セットを指定します。デフォルトは`nil`です。

#### `config.action_dispatch.tld_length`

アプリケーションのトップレベルドメイン（TLD）の長さを設定します。デフォルトは`1`です。

#### `config.action_dispatch.ignore_accept_header`

リクエストからAcceptヘッダーを無視するかどうかを決定するために使用されます。デフォルトは`false`です。

#### `config.action_dispatch.x_sendfile_header`

サーバー固有のX-Sendfileヘッダーを指定します。これはサーバーからの高速なファイル送信に役立ちます。たとえば、Apacheの場合は'X-Sendfile'に設定できます。

#### `config.action_dispatch.http_auth_salt`

HTTP Authのsalt値を設定します。デフォルトは`'http authentication'`です。

#### `config.action_dispatch.signed_cookie_salt`

署名付きクッキーのsalt値を設定します。デフォルトは`'signed cookie'`です。

#### `config.action_dispatch.encrypted_cookie_salt`

暗号化されたクッキーのsalt値を設定します。デフォルトは`'encrypted cookie'`です。

#### `config.action_dispatch.encrypted_signed_cookie_salt`

署名付き暗号化クッキーのsalt値を設定します。デフォルトは`'signed encrypted cookie'`です。

#### `config.action_dispatch.authenticated_encrypted_cookie_salt`

認証付き暗号化クッキーのsalt値を設定します。デフォルトは`'authenticated encrypted cookie'`です。

#### `config.action_dispatch.encrypted_cookie_cipher`

暗号化クッキーに使用する暗号方式を設定します。デフォルトは`"aes-256-gcm"`です。

#### `config.action_dispatch.signed_cookie_digest`

署名付きクッキーに使用するダイジェストを設定します。デフォルトは`"SHA1"`です。

#### `config.action_dispatch.cookies_rotations`

暗号化および署名付きクッキーの秘密、暗号方式、およびダイジェストをローテーションすることを許可します。

#### `config.action_dispatch.use_authenticated_cookie_encryption`

署名付きおよび暗号化クッキーがAES-256-GCM暗号または古いAES-256-CBC暗号を使用するかどうかを制御します。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 5.2        | `true`       |

#### `config.action_dispatch.use_cookies_with_metadata`

目的のメタデータを埋め込んだクッキーの書き込みを有効にします。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 6.0        | `true`       |

#### `config.action_dispatch.perform_deep_munge`

パラメータに対して`deep_munge`メソッドを実行するかどうかを設定します。
詳細については、[セキュリティガイド](security.html#unsafe-query-generation)を参照してください。デフォルトは`true`です。

#### `config.action_dispatch.rescue_responses`

HTTPステータスに割り当てられる例外を設定します。ハッシュを受け入れ、例外/ステータスのペアを指定できます。デフォルトでは次のように定義されています。

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

設定されていない例外はすべて500 Internal Server Errorにマッピングされます。

#### `config.action_dispatch.cookies_same_site_protection`

クッキーを設定する際の`SameSite`属性のデフォルト値を設定します。
`nil`に設定すると、`SameSite`属性は追加されません。リクエストに基づいて`SameSite`属性の値を動的に設定するには、procを指定できます。例えば:
```ruby
config.action_dispatch.cookies_same_site_protection = ->(request) do
  :strict unless request.user_agent == "TestAgent"
end
```

デフォルト値は `config.load_defaults` のターゲットバージョンに依存します：

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `nil`        |
| 6.1        | `:lax`       |

#### `config.action_dispatch.ssl_default_redirect_status`

`ActionDispatch::SSL` ミドルウェアで、HTTP から HTTPS へのリダイレクト時に非 GET/HEAD リクエストに使用されるデフォルトの HTTP ステータスコードを設定します。

デフォルト値は `config.load_defaults` のターゲットバージョンに依存します：

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `307`        |
| 6.1        | `308`        |

#### `config.action_dispatch.log_rescued_responses`

`rescue_responses` で設定された未処理の例外をログに記録するかどうかを設定します。デフォルトは `true` です。

#### `ActionDispatch::Callbacks.before`

リクエストの前に実行するコードのブロックを受け取ります。

#### `ActionDispatch::Callbacks.after`

リクエストの後に実行するコードのブロックを受け取ります。

### Action View の設定

`config.action_view` には、いくつかの設定が含まれています：

#### `config.action_view.cache_template_loading`

テンプレートを各リクエストごとに再読み込みするかどうかを制御します。デフォルトは `!config.enable_reloading` です。

#### `config.action_view.field_error_proc`

Active Model からのエラーを表示するための HTML ジェネレータを提供します。ブロックは Action View テンプレートのコンテキストで評価されます。デフォルトは以下の通りです。

```ruby
Proc.new { |html_tag, instance| content_tag :div, html_tag, class: "field_with_errors" }
```

#### `config.action_view.default_form_builder`

Rails にデフォルトで使用するフォームビルダを指定します。デフォルトは `ActionView::Helpers::FormBuilder` です。フォームビルダクラスを初期化後にロードするようにしたい場合（開発環境では各リクエストで再読み込みされるため）、`String` として渡すことができます。

#### `config.action_view.logger`

Log4r のインターフェースに準拠するロガーまたはデフォルトの Ruby Logger クラスを受け入れ、Action View からの情報をログに記録します。ログを無効にするには `nil` を設定します。

#### `config.action_view.erb_trim_mode`

ERB で使用するトリムモードを指定します。デフォルトは `'-'` で、`<%= -%>` や `<%= =%>` を使用すると末尾のスペースと改行をトリミングします。詳細は [Erubis のドキュメント](http://www.kuwata-lab.com/erubis/users-guide.06.html#topics-trimspaces) を参照してください。

#### `config.action_view.frozen_string_literal`

ERB テンプレートを `# frozen_string_literal: true` のマジックコメントでコンパイルし、すべての文字列リテラルを凍結して割り当てを節約します。すべてのビューで有効にするには `true` を設定します。

#### `config.action_view.embed_authenticity_token_in_remote_forms`

`remote: true` を持つフォームの `authenticity_token` のデフォルト動作を設定します。デフォルトでは `false` に設定されており、リモートフォームには `authenticity_token` が含まれません。これはフォームをフラグメントキャッシュしている場合に便利です。リモートフォームは `meta` タグから認証情報を取得するため、埋め込みは JavaScript がサポートされていないブラウザでない限りは不要です。その場合、フォームオプションとして `authenticity_token: true` を渡すか、この設定を `true` に設定することができます。
#### `config.action_view.prefix_partial_path_with_controller_namespace`

名前空間付きコントローラからレンダリングされるテンプレートのサブディレクトリからパーシャルを検索するかどうかを決定します。例えば、`Admin::ArticlesController`という名前のコントローラが次のテンプレートをレンダリングする場合を考えてみましょう。

```erb
<%= render @article %>
```

デフォルトの設定は`true`で、`/admin/articles/_article.erb`のパーシャルが使用されます。値を`false`に設定すると、`/articles/_article.erb`がレンダリングされ、これは`ArticlesController`のような名前空間のないコントローラからレンダリングする場合と同じ動作です。

#### `config.action_view.automatically_disable_submit_tag`

`submit_tag`がクリック時に自動的に無効になるかどうかを決定します。デフォルトは`true`です。

#### `config.action_view.debug_missing_translation`

欠落している翻訳キーを`<span>`タグで囲むかどうかを決定します。デフォルトは`true`です。

#### `config.action_view.form_with_generates_remote_forms`

`form_with`がリモートフォームを生成するかどうかを決定します。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| 5.1        | `true`       |
| 6.1        | `false`      |

#### `config.action_view.form_with_generates_ids`

`form_with`が入力要素にIDを生成するかどうかを決定します。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元々)     | `false`      |
| 5.2        | `true`       |

#### `config.action_view.default_enforce_utf8`

フォームがUTF-8でエンコードされた状態で古いバージョンのInternet Explorerに送信されるようにするための隠しタグが生成されるかどうかを決定します。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元々)     | `true`       |
| 6.0        | `false`      |

#### `config.action_view.image_loading`

`image_tag`ヘルパーによってレンダリングされる`<img>`タグの`loading`属性のデフォルト値を指定します。例えば、`"lazy"`に設定すると、`image_tag`によってレンダリングされる`<img>`タグに`loading="lazy"`が含まれ、[ブラウザに画像がビューポートの近くになるまで読み込まないように指示します](https://html.spec.whatwg.org/#lazy-loading-attributes)。（この値は`image_tag`に`loading: "eager"`などを渡すことで個別の画像ごとにオーバーライドすることもできます。）デフォルトは`nil`です。

#### `config.action_view.image_decoding`

`image_tag`ヘルパーによってレンダリングされる`<img>`タグの`decoding`属性のデフォルト値を指定します。デフォルトは`nil`です。

#### `config.action_view.annotate_rendered_view_with_filenames`

レンダリングされたビューにテンプレートファイル名を注釈付けするかどうかを決定します。デフォルトは`false`です。

#### `config.action_view.preload_links_header`

`javascript_include_tag`と`stylesheet_link_tag`がアセットをプリロードする`Link`ヘッダを生成するかどうかを決定します。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元々)     | `nil`        |
| 6.1        | `true`       |

#### `config.action_view.button_to_generates_button_tag`
`button_to`が`<button>`要素をレンダリングするかどうかを判断します。コンテンツが最初の引数として渡されるかブロックとして渡されるかに関係なく、デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元のバージョン) | `false` |
| 7.0 | `true` |

#### `config.action_view.apply_stylesheet_media_default`

`stylesheet_link_tag`が`media`属性のデフォルト値として`screen`をレンダリングするかどうかを決定します。デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元のバージョン) | `true` |
| 7.0 | `false` |

#### `config.action_view.prepend_content_exfiltration_prevention`

`form_tag`と`button_to`ヘルパーが、その内容が前の閉じられていないタグによってキャプチャされることがないようにするために、ブラウザセーフ（しかし技術的には無効な）HTMLでプレフィックスされたHTMLタグを生成するかどうかを決定します。デフォルト値は`false`です。

#### `config.action_view.sanitizer_vendor`

`Action View`で使用されるHTMLサニタイザのセットを`ActionView::Helpers::SanitizeHelper.sanitizer_vendor`を設定することで構成します。デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 | マークアップの解析方法 |
| ---------- | ------------ | --------------------- |
| (元のバージョン) | `Rails::HTML4::Sanitizer` | HTML4 |
| 7.1 | `Rails::HTML5::Sanitizer`（注：JRubyではサポートされていません） | HTML5 |

注：JRubyでは`Rails::HTML5::Sanitizer`はサポートされていないため、JRubyプラットフォームでは`Rails::HTML4::Sanitizer`が使用されます。

### Action Mailboxの設定

`config.action_mailbox`は以下の設定オプションを提供します。

#### `config.action_mailbox.logger`

Action Mailboxで使用されるロガーを含みます。Log4rのインターフェースに準拠するロガーまたはデフォルトのRuby Loggerクラスを受け入れます。デフォルトは`Rails.logger`です。

```ruby
config.action_mailbox.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.action_mailbox.incinerate_after`

`ActionMailbox::InboundEmail`レコードの処理後に削除されるまでの期間を示す`ActiveSupport::Duration`を受け入れます。デフォルトは`30.days`です。

```ruby
# 処理後14日で受信メールを削除する。
config.action_mailbox.incinerate_after = 14.days
```

#### `config.action_mailbox.queues.incineration`

インシネレーションジョブに使用するActive Jobキューを示すシンボルを受け入れます。このオプションが`nil`の場合、インシネレーションジョブはデフォルトのActive Jobキューに送信されます（`config.active_job.default_queue_name`を参照）。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元のバージョン) | `:action_mailbox_incineration` |
| 6.1 | `nil` |

#### `config.action_mailbox.queues.routing`

ルーティングジョブに使用するActive Jobキューを示すシンボルを受け入れます。このオプションが`nil`の場合、ルーティングジョブはデフォルトのActive Jobキューに送信されます（`config.active_job.default_queue_name`を参照）。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。
| バージョンから開始 | デフォルト値 |
| --------------------- | -------------------- |
| (元の値)            | `:action_mailbox_routing` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.storage_service`

メールのアップロードに使用するActive Storageサービスを示すシンボルを受け入れます。このオプションが`nil`の場合、メールはデフォルトのActive Storageサービスにアップロードされます（`config.active_storage.service`を参照）。

### Action Mailerの設定

`config.action_mailer`で利用可能な設定がいくつかあります：

#### `config.action_mailer.asset_host`

アセットのホストを設定します。アプリケーションサーバー自体ではなく、CDNがアセットをホストする場合に便利です。これはAction Controllerの設定と異なる場合にのみ使用する必要があります。そうでなければ、`config.asset_host`を使用してください。

#### `config.action_mailer.logger`

Log4rのインターフェースに準拠するロガーまたはデフォルトのRuby Loggerクラスを受け入れます。これはAction Mailerからの情報をログに記録するために使用されます。ログを無効にするには、`nil`に設定します。

#### `config.action_mailer.smtp_settings`

`:smtp`配信方法の詳細な設定を許可します。オプションのハッシュを受け入れ、次のオプションのいずれかを含めることができます：

* `:address` - リモートメールサーバーを使用することができます。デフォルトの「localhost」設定から変更してください。
* `:port` - メールサーバーがポート25ではない場合に変更できます。
* `:domain` - HELOドメインを指定する必要がある場合は、ここで指定できます。
* `:user_name` - メールサーバーが認証を必要とする場合、この設定でユーザー名を設定します。
* `:password` - メールサーバーが認証を必要とする場合、この設定でパスワードを設定します。
* `:authentication` - メールサーバーが認証を必要とする場合、認証タイプをここで指定する必要があります。これはシンボルであり、`:plain`、`:login`、`:cram_md5`のいずれかです。
* `:enable_starttls` - SMTPサーバーへの接続時にSTARTTLSを使用し、サポートされていない場合は失敗します。デフォルトは`false`です。
* `:enable_starttls_auto` - SMTPサーバーでSTARTTLSが有効になっているかどうかを検出し、使用を開始します。デフォルトは`true`です。
* `:openssl_verify_mode` - TLSを使用する場合、OpenSSLが証明書をどのようにチェックするかを設定できます。これは自己署名および/またはワイルドカード証明書を検証する必要がある場合に便利です。これはOpenSSLの検証定数、`:none`または`:peer`のいずれか、またはそれぞれ`OpenSSL::SSL::VERIFY_NONE`または`OpenSSL::SSL::VERIFY_PEER`の定数です。
* `:ssl/:tls` - SMTP接続がSMTP/TLS（SMTPS：直接TLS接続上のSMTP）を使用するようにします。
* `:open_timeout` - 接続を開こうとする間に待機する秒数です。
* `:read_timeout` - read（2）呼び出しのタイムアウトまで待機する秒数です。
さらに、[構成オプション `Mail::SMTP` が受け入れる](https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/smtp.rb) 任意の設定オプションを渡すことができます。

#### `config.action_mailer.smtp_timeout`

`:smtp` 配信方法の `:open_timeout` と `:read_timeout` の値を設定することができます。

デフォルト値は `config.load_defaults` のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `nil`        |
| 7.0        | `5`          |

#### `config.action_mailer.sendmail_settings`

`sendmail` 配信方法の詳細な設定を行うことができます。オプションのハッシュを受け入れます。以下のオプションを含めることができます。

* `:location` - sendmail 実行ファイルの場所。デフォルトは `/usr/sbin/sendmail` です。
* `:arguments` - コマンドライン引数。デフォルトは `%w[ -i ]` です。

#### `config.action_mailer.raise_delivery_errors`

メールの配信が完了しない場合にエラーを発生させるかどうかを指定します。デフォルトは `true` です。

#### `config.action_mailer.delivery_method`

配信方法を定義し、デフォルトは `:smtp` です。詳細については、[Action Mailer ガイドの構成セクション](action_mailer_basics.html#action-mailer-configuration) を参照してください。

#### `config.action_mailer.perform_deliveries`

メールが実際に配信されるかどうかを指定し、デフォルトは `true` です。テストのために `false` に設定すると便利です。

#### `config.action_mailer.default_options`

Action Mailer のデフォルトを設定します。`from` や `reply_to` のようなオプションをすべてのメーラーに対して設定するために使用します。デフォルトは以下のようになります。

```ruby
mime_version:  "1.0",
charset:       "UTF-8",
content_type: "text/plain",
parts_order:  ["text/plain", "text/enriched", "text/html"]
```

ハッシュを割り当てて追加のオプションを設定することもできます。

```ruby
config.action_mailer.default_options = {
  from: "noreply@example.com"
}
```

#### `config.action_mailer.observers`

メールが配信されたときに通知されるオブザーバーを登録します。

```ruby
config.action_mailer.observers = ["MailObserver"]
```

#### `config.action_mailer.interceptors`

メールが送信される前に呼び出されるインターセプターを登録します。

```ruby
config.action_mailer.interceptors = ["MailInterceptor"]
```

#### `config.action_mailer.preview_interceptors`

メールがプレビューされる前に呼び出されるインターセプターを登録します。

```ruby
config.action_mailer.preview_interceptors = ["MyPreviewMailInterceptor"]
```

#### `config.action_mailer.preview_paths`

メーラープレビューの場所を指定します。この設定オプションにパスを追加すると、それらのパスがメーラープレビューの検索に使用されます。

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

#### `config.action_mailer.show_previews`

メーラープレビューを有効または無効にします。デフォルトでは開発環境では `true` です。

```ruby
config.action_mailer.show_previews = false
```

#### `config.action_mailer.perform_caching`

メーラーテンプレートがフラグメントキャッシュを実行するかどうかを指定します。指定されていない場合、デフォルトは `true` になります。

#### `config.action_mailer.deliver_later_queue_name`

デフォルトの配信ジョブに使用する Active Job キューを指定します（`config.action_mailer.delivery_job` を参照）。このオプションを `nil` に設定すると、配信ジョブはデフォルトの Active Job キューに送信されます（`config.active_job.default_queue_name` を参照）。

メーラークラスはこれをオーバーライドして異なるキューを使用することができます。ただし、これはデフォルトの配信ジョブを使用している場合にのみ適用されます。メーラーがカスタムジョブを使用している場合は、そのキューが使用されます。
指定されたキューを処理するようにActive Jobアダプターも設定されていることを確認してください。そうでない場合、配信ジョブは黙って無視される可能性があります。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョンから開始 | デフォルト値 |
| ----------------- | ------------ |
| (元の値)          | `:mailers`   |
| 6.1               | `nil`        |

#### `config.action_mailer.delivery_job`

メールの配信ジョブを指定します。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョンから開始 | デフォルト値 |
| ----------------- | ------------ |
| (元の値)          | `ActionMailer::MailDeliveryJob` |
| 6.0               | `"ActionMailer::MailDeliveryJob"` |

### Active Supportの設定

Active Supportにはいくつかの設定オプションがあります。

#### `config.active_support.bare`

Railsの起動時に`active_support/all`の読み込みを有効または無効にします。デフォルトは`nil`で、`active_support/all`が読み込まれます。

#### `config.active_support.test_order`

テストケースの実行順序を設定します。可能な値は`:random`と`:sorted`です。デフォルトは`:random`です。

#### `config.active_support.escape_html_entities_in_json`

JSONシリアル化時にHTMLエンティティのエスケープを有効または無効にします。デフォルトは`true`です。

#### `config.active_support.use_standard_json_time_format`

日付をISO 8601形式でシリアル化するかどうかを設定します。デフォルトは`true`です。

#### `config.active_support.time_precision`

JSONエンコードされた時間値の精度を設定します。デフォルトは`3`です。

#### `config.active_support.hash_digest_class`

ETagヘッダなどの非機密ダイジェストを生成するために使用するダイジェストクラスを設定できます。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョンから開始 | デフォルト値 |
| ----------------- | ------------ |
| (元の値)          | `OpenSSL::Digest::MD5` |
| 5.2               | `OpenSSL::Digest::SHA1` |
| 7.0               | `OpenSSL::Digest::SHA256` |

#### `config.active_support.key_generator_hash_digest_class`

設定されたシークレットベースからシークレットを派生させるために使用するダイジェストクラスを設定できます。これは、暗号化されたクッキーなどのためです。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョンから開始 | デフォルト値 |
| ----------------- | ------------ |
| (元の値)          | `OpenSSL::Digest::SHA1` |
| 7.0               | `OpenSSL::Digest::SHA256` |

#### `config.active_support.use_authenticated_message_encryption`

メッセージの暗号化にAES-256-CBCの代わりにAES-256-GCM認証付き暗号をデフォルトの暗号方式として使用するかどうかを指定します。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョンから開始 | デフォルト値 |
| ----------------- | ------------ |
| (元の値)          | `false`      |
| 5.2               | `true`       |

#### `config.active_support.message_serializer`

[`ActiveSupport::MessageEncryptor`][]および[`ActiveSupport::MessageVerifier`][]インスタンスで使用されるデフォルトのシリアライザを指定します。シリアライザの移行を容易にするため、提供されるシリアライザには複数の逆シリアライズ形式をサポートするフォールバックメカニズムが含まれています。

| シリアライザ | シリアライズとデシリアライズ | フォールバックのデシリアライズ |
| ---------- | ------------------------- | -------------------- |
| `:marshal` | `Marshal` | `ActiveSupport::JSON`、`ActiveSupport::MessagePack` |
| `:json` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack` |
| `:json_allow_marshal` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack`、`Marshal` |
| `:message_pack` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON` |
| `:message_pack_allow_marshal` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON`、`Marshal` |
警告：`Marshal`は、メッセージ署名の秘密が漏洩した場合に、逆シリアル化攻撃の可能性があるベクトルです。_可能であれば、`Marshal`をサポートしないシリアライザを選択してください。_

情報：`:message_pack`および`:message_pack_allow_marshal`シリアライザは、`Symbol`などのJSONでサポートされていない一部のRubyの型のラウンドトリップをサポートします。また、パフォーマンスの向上とペイロードサイズの縮小が可能です。ただし、[`msgpack` gem](https://rubygems.org/gems/msgpack)が必要です。

上記の各シリアライザは、代替の逆シリアル化形式にフォールバックする際に[`message_serializer_fallback.active_support`][]イベント通知を出力します。これにより、そのようなフォールバックがどれくらい頻繁に発生するかを追跡できます。

また、`dump`メソッドと`load`メソッドに応答する任意のシリアライザオブジェクトを指定することもできます。例：

```ruby
config.active_job.message_serializer = YAML
```

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します：

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `:marshal`   |
| 7.1        | `:json_allow_marshal` |

#### `config.active_support.use_message_serializer_for_metadata`

`true`の場合、メッセージデータとメタデータを一緒にシリアライズするパフォーマンス最適化が有効になります。これにより、メッセージの形式が変わるため、古い（<7.1）バージョンのRailsではこの方法でシリアライズされたメッセージを読むことはできません。ただし、古い形式を使用するメッセージは、この最適化が有効であるかどうかに関係なく読むことができます。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します：

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 7.1        | `true`       |

#### `config.active_support.cache_format_version`

キャッシュに使用するシリアライズ形式を指定します。可能な値は`6.1`、`7.0`、`7.1`です。

`6.1`、`7.0`、`7.1`の形式はすべてデフォルトのコーダーとして`Marshal`を使用しますが、`7.0`はキャッシュエントリの効率的な表現を使用し、`7.1`はビューフラグメントなどのベアストリング値に対する追加の最適化を含んでいます。

すべての形式は前方互換性と後方互換性があり、1つの形式で書かれたキャッシュエントリは、別の形式を使用して読むことができます。この動作により、キャッシュ全体を無効にすることなく形式間を移行することが容易になります。

デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します：

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `6.1`        |
| 7.0        | `7.0`        |
| 7.1        | `7.1`        |

#### `config.active_support.deprecation`

非推奨の警告の動作を設定します。オプションは、`:raise`、`:stderr`、`:log`、`:notify`、`:silence`です。

デフォルトの生成された`config/environments`ファイルでは、開発環境では`：log`、テスト環境では`：stderr`に設定され、本番環境では[`config.active_support.report_deprecations`](#config-active-support-report-deprecations)に優先します。
#### `config.active_support.disallowed_deprecation`

`disallowed_deprecation`の警告の振る舞いを設定します。オプションは`:raise`、`:stderr`、`:log`、`:notify`、`:silence`です。

デフォルトで生成される`config/environments`ファイルでは、開発とテストの両方に対して`raise`に設定され、本番では[`config.active_support.report_deprecations`](#config-active-support-report-deprecations)を優先するために省略されます。

#### `config.active_support.disallowed_deprecation_warnings`

アプリケーションが許容しない非推奨の警告を設定します。これにより、特定の非推奨を厳密なエラーとして扱うことができます。

#### `config.active_support.report_deprecations`

`false`に設定すると、[アプリケーションの非推奨機能](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators)からの非推奨警告をすべて無効にします。これにはRailsや他のジェムからの非推奨機能も含まれますが、ActiveSupport::Deprecationから発生するすべての非推奨警告を防ぐわけではありません。

デフォルトで生成される`config/environments`ファイルでは、本番では`false`に設定されます。

#### `config.active_support.isolation_level`

Railsのほとんどの内部状態の局所性を設定します。ファイバーベースのサーバーやジョブプロセッサ（例：`falcon`）を使用している場合は、`:fiber`に設定する必要があります。それ以外の場合は、`:thread`の局所性を使用するのが最適です。デフォルトは`:thread`です。

#### `config.active_support.executor_around_test_case`

テストスイートがテストケースの周りで`Rails.application.executor.wrap`を呼び出すように設定します。
これにより、テストケースは実際のリクエストやジョブに近い振る舞いをします。
通常テストでは無効になっているActive Recordクエリキャッシュや非同期クエリなどのいくつかの機能が有効になります。

デフォルトの値は`config.load_defaults`のターゲットバージョンに依存します：

| バージョン | デフォルトの値 |
| ---------- | -------------- |
| (元の値)   | `false`        |
| 7.0        | `true`         |

#### `ActiveSupport::Logger.silencer`

ブロック内でのログの無効化機能を無効にするために`false`に設定されます。デフォルトは`true`です。

#### `ActiveSupport::Cache::Store.logger`

キャッシュストアの操作で使用するロガーを指定します。

#### `ActiveSupport.to_time_preserves_timezone`

`to_time`メソッドが受け取ったオブジェクトのUTCオフセットを保持するかどうかを指定します。`false`の場合、`to_time`メソッドはローカルシステムのUTCオフセットに変換されます。

デフォルトの値は`config.load_defaults`のターゲットバージョンに依存します：

| バージョン | デフォルトの値 |
| ---------- | -------------- |
| (元の値)   | `false`        |
| 5.0        | `true`         |

#### `ActiveSupport.utc_to_local_returns_utc_offset_times`

`ActiveSupport::TimeZone.utc_to_local`がUTCの時間ではなくUTCオフセットを持つ時間を返すように設定します。

デフォルトの値は`config.load_defaults`のターゲットバージョンに依存します：

| バージョン | デフォルトの値 |
| ---------- | -------------- |
| (元の値)   | `false`        |
| 6.1        | `true`         |

#### `config.active_support.raise_on_invalid_cache_expiration_time`

`Rails.cache`の`fetch`または`write`に無効な`expires_at`または`expires_in`の時間が指定された場合に`ArgumentError`を発生させるかどうかを指定します。
オプションは`true`と`false`です。`false`の場合、例外は`handled`として報告され、ログに記録されます。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します：

| バージョンから開始 | デフォルト値 |
| ----------------- | ------------ |
| (元のバージョン)   | `false`      |
| 7.1               | `true`       |

### Active Jobの設定

`config.active_job`は、次の設定オプションを提供します：

#### `config.active_job.queue_adapter`

キューのバックエンドに対するアダプタを設定します。デフォルトのアダプタは`:async`です。組み込みのアダプタの最新のリストについては、[ActiveJob::QueueAdapters APIドキュメント](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html)を参照してください。

```ruby
# アダプタのgemがGemfileに含まれていることを確認してください
# また、アダプタ固有のインストールおよび展開手順に従ってください。
config.active_job.queue_adapter = :sidekiq
```

#### `config.active_job.default_queue_name`

デフォルトのキュー名を変更するために使用できます。デフォルトでは、これは`"default"`です。

```ruby
config.active_job.default_queue_name = :medium_priority
```

#### `config.active_job.queue_name_prefix`

すべてのジョブに対してオプションの空でないキュー名の接頭辞を設定することができます。デフォルトでは空で使用されません。

次の設定は、本番環境で実行される場合に、指定されたジョブを`production_high_priority`キューにキューイングします：

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

デフォルト値は`'_'`です。`queue_name_prefix`が設定されている場合、`queue_name_delimiter`は接頭辞と接頭辞のないキュー名を結合します。

次の設定は、指定されたジョブを`video_server.low_priority`キューにキューイングします：

```ruby
# デリミタを使用するためには接頭辞を設定する必要があります
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

Log4rのインターフェースに準拠するロガーまたはデフォルトのRuby Loggerクラスを受け入れます。これはActive Jobからの情報をログに記録するために使用されます。Active JobクラスまたはActive Jobインスタンスのいずれかで`logger`を呼び出すことでこのロガーを取得できます。ログを無効にするには`nil`に設定します。

#### `config.active_job.custom_serializers`

カスタムの引数シリアライザを設定することができます。デフォルトは`[]`です。

#### `config.active_job.log_arguments`

ジョブの引数をログに記録するかどうかを制御します。デフォルトは`true`です。

#### `config.active_job.verbose_enqueue_logs`

バックグラウンドジョブをエンキューするメソッドのソース位置が関連するエンキューログ行の下に記録されるかどうかを指定します。デフォルトでは、開発環境ではフラグが`true`であり、他のすべての環境では`false`です。

#### `config.active_job.retry_jitter`

失敗したジョブをリトライする際に計算される遅延時間に適用される「ジッター」（ランダムな変動）の量を制御します。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します：

| バージョンから開始 | デフォルト値 |
| ----------------- | ------------ |
| (元のバージョン)   | `0.0`        |
| 6.1               | `0.15`       |
#### `config.active_job.log_query_tags_around_perform`

`around_perform`を介して自動的にクエリタグのジョブコンテキストが更新されるかどうかを決定します。デフォルト値は`true`です。

#### `config.active_job.use_big_decimal_serializer`

`BigDecimal`引数のシリアライザを有効にします。このシリアライザを使用すると、いくつかのキューアダプタは`BigDecimal`引数を単純な（ラウンドトリップできない）文字列としてシリアライズすることがありません。

警告: 複数のレプリカを持つアプリケーションをデプロイする場合、古い（Rails 7.1以前の）レプリカはこのシリアライザから`BigDecimal`引数をデシリアライズすることができません。したがって、この設定は、すべてのレプリカが正常にRails 7.1にアップグレードされた後にのみ有効にする必要があります。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 7.1        | `true`       |

### Action Cableの設定

#### `config.action_cable.url`

Action CableサーバーをホストしているURLの文字列を受け入れます。メインのアプリケーションから分離されたAction Cableサーバーを実行している場合にこのオプションを使用します。

#### `config.action_cable.mount_path`

Action Cableをメインのサーバープロセスの一部としてマウントする場所の文字列を受け入れます。デフォルトは`/cable`です。通常のRailsサーバーにAction Cableをマウントしない場合は、これをnilに設定できます。

詳細な設定オプションについては、[Action Cableの概要](action_cable_overview.html#configuration)を参照してください。

#### `config.action_cable.precompile_assets`

Action Cableのアセットをアセットパイプラインのプリコンパイルに追加するかどうかを決定します。Sprocketsが使用されていない場合は効果がありません。デフォルト値は`true`です。

### Active Storageの設定

`config.active_storage`は以下の設定オプションを提供します。

#### `config.active_storage.variant_processor`

MiniMagickまたはruby-vipsを使用してバリアントの変換とブロブの解析を実行するかどうかを指定する`:mini_magick`または`:vips`のシンボルを受け入れます。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `:mini_magick` |
| 7.0        | `:vips`       |

#### `config.active_storage.analyzers`

Active Storageブロブで使用可能な解析器を示すクラスの配列を受け入れます。デフォルトでは、次のように定義されています。

```ruby
config.active_storage.analyzers = [ActiveStorage::Analyzer::ImageAnalyzer::Vips, ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick, ActiveStorage::Analyzer::VideoAnalyzer, ActiveStorage::Analyzer::AudioAnalyzer]
```

画像解析器は画像ブロブの幅と高さを抽出できます。ビデオ解析器はビデオブロブの幅、高さ、再生時間、角度、アスペクト比、ビデオ/オーディオチャンネルの有無を抽出できます。オーディオ解析器はオーディオブロブの再生時間とビットレートを抽出できます。

#### `config.active_storage.previewers`

Active Storageブロブで使用可能な画像プレビューアのクラスの配列を受け入れます。デフォルトでは、次のように定義されています。
```ruby
config.active_storage.previewers = [ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer]
```

`PopplerPDFPreviewer`と`MuPDFPreviewer`は、PDFのブロブの最初のページからサムネイルを生成することができます。`VideoPreviewer`はビデオのブロブから関連するフレームを生成します。

#### `config.active_storage.paths`

プレビューア/アナライザのコマンドの場所を示すオプションのハッシュを受け入れます。デフォルトは`{}`で、コマンドはデフォルトのパスで検索されます。次のオプションを含めることができます：

* `:ffprobe` - ffprobeの実行可能ファイルの場所。
* `:mutool` - mutoolの実行可能ファイルの場所。
* `:ffmpeg` - ffmpegの実行可能ファイルの場所。

```ruby
config.active_storage.paths[:ffprobe] = '/usr/local/bin/ffprobe'
```

#### `config.active_storage.variable_content_types`

Active Storageが変換できるコンテンツタイプを示す文字列の配列を受け入れます。デフォルトでは、次のように定義されています：

```ruby
config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/bmp image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)
```

#### `config.active_storage.web_image_content_types`

フォールバックのPNG形式に変換せずに処理できるWebイメージコンテンツタイプとして扱われる文字列の配列を受け入れます。`WebP`や`AVIF`のバリアントをアプリケーションで使用したい場合は、この配列に`image/webp`または`image/avif`を追加できます。デフォルトでは、次のように定義されています：

```ruby
config.active_storage.web_image_content_types = %w(image/png image/jpeg image/gif)
```

#### `config.active_storage.content_types_to_serve_as_binary`

Active Storageが常にインラインではなく、添付ファイルとして提供するコンテンツタイプを示す文字列の配列を受け入れます。デフォルトでは、次のように定義されています：

```ruby
config.active_storage.content_types_to_serve_as_binary = %w(text/html image/svg+xml application/postscript application/x-shockwave-flash text/xml application/xml application/xhtml+xml application/mathml+xml text/cache-manifest)
```

#### `config.active_storage.content_types_allowed_inline`

Active Storageがインラインで提供を許可するコンテンツタイプを示す文字列の配列を受け入れます。デフォルトでは、次のように定義されています：

```ruby
config.active_storage.content_types_allowed_inline` = %w(image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon application/pdf)
```

#### `config.active_storage.queues.analysis`

解析ジョブに使用するActive Jobキューを示すシンボルを受け入れます。このオプションが`nil`の場合、解析ジョブはデフォルトのActive Jobキューに送信されます（`config.active_job.default_queue_name`を参照）。

デフォルト値は、`config.load_defaults`のターゲットバージョンによって異なります：

| バージョン | デフォルト値 |
| ---------- | ------------ |
| 6.0        | `:active_storage_analysis` |
| 6.1        | `nil`        |

#### `config.active_storage.queues.purge`

パージジョブに使用するActive Jobキューを示すシンボルを受け入れます。このオプションが`nil`の場合、パージジョブはデフォルトのActive Jobキューに送信されます（`config.active_job.default_queue_name`を参照）。

デフォルト値は、`config.load_defaults`のターゲットバージョンによって異なります：

| バージョン | デフォルト値 |
| ---------- | ------------ |
| 6.0        | `:active_storage_purge` |
| 6.1        | `nil`        |
#### `config.active_storage.queues.mirror`

`config.active_storage.queues.mirror`は、直接アップロードのミラーリングジョブに使用するActive Jobキューを示すシンボルを受け入れます。このオプションが`nil`の場合、ミラーリングジョブはデフォルトのActive Jobキューに送信されます（`config.active_job.default_queue_name`を参照）。デフォルトは`nil`です。

#### `config.active_storage.logger`

Active Storageが使用するロガーを設定するために使用できます。Log4rのインターフェースに準拠するロガーまたはデフォルトのRuby Loggerクラスを受け入れます。

```ruby
config.active_storage.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.active_storage.service_urls_expire_in`

次のURLのデフォルトの有効期限を決定します。

* `ActiveStorage::Blob#url`
* `ActiveStorage::Blob#service_url_for_direct_upload`
* `ActiveStorage::Variant#url`

デフォルトは5分です。

#### `config.active_storage.urls_expire_in`

Active Storageによって生成されるRailsアプリケーションのURLのデフォルトの有効期限を決定します。デフォルトは`nil`です。

#### `config.active_storage.routes_prefix`

Active Storageが提供するルートのルートプレフィックスを設定するために使用できます。生成されるルートの前に追加される文字列を受け入れます。

```ruby
config.active_storage.routes_prefix = '/files'
```

デフォルトは`/rails/active_storage`です。

#### `config.active_storage.track_variants`

バリアントがデータベースに記録されるかどうかを決定します。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 6.1        | `true`       |

#### `config.active_storage.draw_routes`

Active Storageのルート生成を切り替えるために使用できます。デフォルトは`true`です。

#### `config.active_storage.resolve_model_to_route`

Active Storageファイルの配信方法をグローバルに変更するために使用できます。

許可される値は次のとおりです。

* `:rails_storage_redirect`：署名付きの短期間のサービスURLにリダイレクトします。
* `:rails_storage_proxy`：ファイルをダウンロードしてプロキシします。

デフォルトは`:rails_storage_redirect`です。

#### `config.active_storage.video_preview_arguments`

ffmpegがビデオプレビュー画像を生成する方法を変更するために使用できます。

デフォルト値は`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `"-y -vframes 1 -f image2"` |
| 7.0        | `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015)"`<sup><mark><strong><em>1</em></strong></mark></sup> <br> `+ ",loop=loop=-1:size=2,trim=start_frame=1'"`<sup><mark><strong><em>2</em></strong></mark></sup><br> `+ " -frames:v 1 -f image2"` <br><br> <ol><li>最初のビデオフレーム、キーフレーム、シーン変更の閾値を満たすフレームを選択します。</li> <li>他のフレームが基準を満たさない場合にフォールバックとして最初のビデオフレームを使用し、最初の（1つまたは）2つの選択されたフレームをループし、最初のループフレームを削除します。</li></ol> |

#### `config.active_storage.multiple_file_field_include_hidden`

Rails 7.1以降、Active Storageの`has_many_attached`関連は、現在のコレクションを_追加_するのではなく、_置換_するようにデフォルトで設定されます。したがって、_空の_コレクションを送信するために、`multiple_file_field_include_hidden`が`true`の場合、[`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field)ヘルパーは、[`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box)ヘルパーと同様に補助的な隠しフィールドをレンダリングします。
デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `false`      |
| 7.0        | `true`       |

#### `config.active_storage.precompile_assets`

Active Storageのアセットをアセットパイプラインの事前コンパイルに追加するかどうかを決定します。Sprocketsが使用されていない場合は、効果はありません。デフォルト値は`true`です。

### Action Textの設定

#### `config.action_text.attachment_tag_name`

添付ファイルを囲むために使用されるHTMLタグの文字列を受け入れます。デフォルト値は`"action-text-attachment"`です。

#### `config.action_text.sanitizer_vendor`

`Action Text`が使用するHTMLサニタイザを設定するために、`ActionText::ContentHelper.sanitizer`をベンダーの`.safe_list_sanitizer`メソッドから返されるクラスのインスタンスに設定します。デフォルト値は、`config.load_defaults`のターゲットバージョンに依存します。

| バージョン | デフォルト値 | マークアップの解析方法 |
| ---------- | ------------ | ---------------------- |
| (元の値)   | `Rails::HTML4::Sanitizer` | HTML4 |
| 7.1        | `Rails::HTML5::Sanitizer`（注を参照） | HTML5 |

注：`Rails::HTML5::Sanitizer`はJRubyではサポートされていないため、JRubyプラットフォームではRailsは`Rails::HTML4::Sanitizer`を使用するようにフォールバックします。

### データベースの設定

ほとんどのRailsアプリケーションはデータベースとやり取りします。データベースに接続するには、環境変数`ENV['DATABASE_URL']`を設定するか、`config/database.yml`という設定ファイルを使用することができます。

`config/database.yml`ファイルを使用すると、データベースにアクセスするために必要なすべての情報を指定できます。

```yaml
development:
  adapter: postgresql
  database: blog_development
  pool: 5
```

これは、`postgresql`アダプタを使用して`blog_development`という名前のデータベースに接続します。同じ情報をURLとして保存し、次のように環境変数を介して提供することもできます。

```ruby
ENV['DATABASE_URL'] # => "postgresql://localhost/blog_development?pool=5"
```

`config/database.yml`ファイルには、Railsがデフォルトで実行できる3つの異なる環境用のセクションが含まれています。

* `development`環境は、アプリケーションと手動で対話するために開発/ローカルコンピュータで使用されます。
* `test`環境は、自動化されたテストを実行するときに使用されます。
* `production`環境は、アプリケーションを世界に展開するときに使用されます。

必要に応じて、`config/database.yml`内にURLを手動で指定することもできます。

```yaml
development:
  url: postgresql://localhost/blog_development?pool=5
```

`config/database.yml`ファイルにはERBタグ`<%= %>`を含めることができます。タグ内のすべてはRubyコードとして評価されます。これを使用して環境変数からデータを取り出したり、必要な接続情報を生成するために計算を実行したりすることができます。


TIP: データベースの設定を手動で更新する必要はありません。アプリケーションジェネレータのオプションを確認すると、`--database`というオプションがあることがわかります。このオプションを使用すると、最も一般的に使用されるリレーショナルデータベースのリストからアダプタを選択できます。ジェネレータを繰り返し実行することもできます。`cd .. && rails new blog --database=mysql`と入力すると、`config/database.yml`ファイルの上書きを確認すると、アプリケーションはSQLiteではなくMySQL用に設定されます。一般的なデータベース接続の詳細な例は以下に示します。
### 接続設定の優先順位

接続を設定する方法は2つあります（`config/database.yml`を使用するか、環境変数を使用するか）。これらがどのように相互作用するかを理解することが重要です。

`config/database.yml`ファイルが空であるが、`ENV['DATABASE_URL']`が存在する場合、Railsは環境変数を介してデータベースに接続します。

```bash
$ cat config/database.yml

$ echo $DATABASE_URL
postgresql://localhost/my_database
```

`config/database.yml`が存在するが、`ENV['DATABASE_URL']`が存在しない場合、このファイルがデータベースに接続するために使用されます。

```bash
$ cat config/database.yml
development:
  adapter: postgresql
  database: my_database
  host: localhost

$ echo $DATABASE_URL
```

`config/database.yml`と`ENV['DATABASE_URL']`の両方が設定されている場合、Railsは設定を結合します。これをより良く理解するために、いくつかの例を見てみましょう。

重複する接続情報が提供された場合、環境変数が優先されます。

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

ここでは、アダプター、ホスト、データベースが`ENV['DATABASE_URL']`の情報と一致しています。

重複しない情報が提供されると、すべての一意の値が取得されますが、競合がある場合は環境変数が優先されます。

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

`pool`は`ENV['DATABASE_URL']`の提供された接続情報に含まれていないため、その情報がマージされます。`adapter`は重複しているため、`ENV['DATABASE_URL']`の接続情報が優先されます。

`ENV['DATABASE_URL']`の接続情報を使用しない明示的なURL接続を指定するには、`"url"`サブキーを使用する方法しかありません。

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

ここでは、`ENV['DATABASE_URL']`の接続情報は無視され、アダプターとデータベース名が異なることに注意してください。

`config/database.yml`にERBを埋め込むことができるため、データベースに接続するために`ENV['DATABASE_URL']`を使用していることを明示的に示すことがベストプラクティスです。特に、データベースのパスワードなどの機密情報をソースコントロール（Gitなど）にコミットしないようにするため、これは本番環境で特に便利です。

```bash
$ cat config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

これで、`ENV['DATABASE_URL']`の接続情報のみを使用していることが明確になりました。
#### SQLite3データベースの設定

Railsには、軽量なサーバーレスのデータベースアプリケーションである[SQLite3](http://www.sqlite.org)の組み込みサポートが付属しています。繁忙な本番環境ではSQLiteが過負荷になる可能性がありますが、開発やテストには適しています。新しいプロジェクトを作成する際、RailsはデフォルトでSQLiteデータベースを使用しますが、後で変更することもできます。

以下は、開発環境の接続情報を含むデフォルトの設定ファイル（`config/database.yml`）のセクションです。

```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

注意：RailsはデータストレージにデフォルトでSQLite3データベースを使用するため、設定なしで使用できます。Railsはまた、MySQL（MariaDBを含む）やPostgreSQLを「そのまま」サポートしており、多くのデータベースシステム用のプラグインも提供しています。本番環境でデータベースを使用している場合、Railsにはおそらくそれに対応するアダプタがあります。

#### MySQLまたはMariaDBデータベースの設定

組み込みのSQLite3データベースの代わりにMySQLまたはMariaDBを使用する場合、`config/database.yml`は少し異なる見た目になります。以下は開発セクションの例です。

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

開発用のデータベースにrootユーザーと空のパスワードがある場合、この設定が適用されるはずです。それ以外の場合は、`development`セクションのユーザー名とパスワードを適切に変更してください。

注意：MySQLのバージョンが5.5または5.6で、デフォルトで`utf8mb4`文字セットを使用したい場合は、`innodb_large_prefix`システム変数を有効にして、より長いキープレフィックスをサポートするようにMySQLサーバーを設定してください。

アドバイザリーロックはMySQLではデフォルトで有効になっており、データベースマイグレーションを同時に安全に行うために使用されます。`advisory_locks`を`false`に設定することで、アドバイザリーロックを無効にすることができます。

```yaml
production:
  adapter: mysql2
  advisory_locks: false
```

#### PostgreSQLデータベースの設定

PostgreSQLを使用する場合、`config/database.yml`はPostgreSQLデータベースを使用するようにカスタマイズされます。

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: blog_development
  pool: 5
```

デフォルトでは、Active Recordはプリペアドステートメントやアドバイザリーロックなどのデータベース機能を使用します。PgBouncerのような外部の接続プーラーを使用している場合、これらの機能を無効にする必要があるかもしれません。

```yaml
production:
  adapter: postgresql
  prepared_statements: false
  advisory_locks: false
```

有効になっている場合、Active Recordはデフォルトで1つのデータベース接続あたり最大で`1000`個のプリペアドステートメントを作成します。この動作を変更するには、`statement_limit`を別の値に設定できます。

```yaml
production:
  adapter: postgresql
  statement_limit: 200
```

使用されるプリペアドステートメントが多いほど、データベースが必要とするメモリも増えます。PostgreSQLデータベースがメモリ制限に達している場合は、`statement_limit`を下げるか、プリペアドステートメントを無効にしてみてください。
#### JRubyプラットフォーム用にSQLite3データベースを設定する

SQLite3を使用し、JRubyを使用する場合、`config/database.yml`は少し異なる見た目になります。以下は開発セクションの例です。

```yaml
development:
  adapter: jdbcsqlite3
  database: storage/development.sqlite3
```

#### JRubyプラットフォーム用にMySQLまたはMariaDBデータベースを設定する

MySQLまたはMariaDBを使用し、JRubyを使用する場合、`config/database.yml`は少し異なる見た目になります。以下は開発セクションの例です。

```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```

#### JRubyプラットフォーム用にPostgreSQLデータベースを設定する

PostgreSQLを使用し、JRubyを使用する場合、`config/database.yml`は少し異なる見た目になります。以下は開発セクションの例です。

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

必要に応じて`development`セクションのユーザー名とパスワードを変更してください。

#### メタデータストレージの設定

デフォルトでは、RailsはRails環境とスキーマに関する情報を`ar_internal_metadata`という内部テーブルに保存します。

接続ごとにこれを無効にするには、データベースの設定で`use_metadata_table`を設定します。これは、テーブルを作成できない共有データベースやデータベースユーザーで作業する場合に便利です。

```yaml
development:
  adapter: postgresql
  use_metadata_table: false
```

#### リトライ動作の設定

デフォルトでは、Railsは何か問題が発生した場合に自動的にデータベースサーバーに再接続し、特定のクエリをリトライします。安全にリトライできる（冪等性のある）クエリのみがリトライされます。リトライの回数はデータベースの設定で`connection_retries`を指定するか、値を0に設定することで無効にすることができます。デフォルトのリトライ回数は1です。

```yaml
development:
  adapter: mysql2
  connection_retries: 3
```

データベースの設定では、`retry_deadline`も設定できます。`retry_deadline`が設定されている場合、リトライ可能なクエリは、最初の試行時に指定された時間が経過した場合にはリトライされません。たとえば、`retry_deadline`が5秒の場合、クエリの最初の試行から5秒が経過した場合、クエリはリトライされません。冪等性があり、`connection_retries`が残っていても、クエリはリトライされません。

この値はデフォルトでnilになっており、経過時間に関係なくすべてのリトライ可能なクエリがリトライされます。この設定の値は秒単位で指定する必要があります。

```yaml
development:
  adapter: mysql2
  retry_deadline: 5 # 5秒後にクエリのリトライを停止する
```

#### クエリキャッシュの設定

デフォルトでは、Railsはクエリの結果セットを自動的にキャッシュします。同じクエリがリクエストまたはジョブのために再度発生した場合、データベースに再度クエリを実行する代わりに、キャッシュされた結果セットを使用します。
クエリキャッシュはメモリに格納され、メモリを過剰に使用しないようにするため、しきい値に達すると最も最近使用されていないクエリを自動的に削除します。デフォルトではしきい値は `100` ですが、`database.yml` で設定することができます。

```yaml
development:
  adapter: mysql2
  query_cache: 200
```

クエリキャッシュを完全に無効にするには、`false` に設定することができます。

```yaml
development:
  adapter: mysql2
  query_cache: false
```

### Railsの環境の作成

デフォルトでは、Railsには「development」、「test」、「production」という3つの環境が付属しています。これらはほとんどのユースケースには十分ですが、より多くの環境が必要な場合もあります。

例えば、本番環境と同様のサーバーでテストに使用するサーバーがあるとします。このようなサーバーは一般的に「ステージングサーバー」と呼ばれます。このサーバーのために「staging」という環境を定義するには、単に`config/environments/staging.rb`というファイルを作成します。これは本番環境のような環境なので、`config/environments/production.rb`の内容をコピーして開始点とし、そこから必要な変更を行います。また、次のように他の環境設定を要求して拡張することも可能です。

```ruby
# config/environments/staging.rb
require_relative "production"

Rails.application.configure do
  # ステージングのオーバーライド
end
```

この環境はデフォルトの環境と変わりありません。`bin/rails server -e staging`でサーバーを起動し、`bin/rails console -e staging`でコンソールを起動し、`Rails.env.staging?`が機能します。

### サブディレクトリへのデプロイ（相対URLルート）

デフォルトでは、Railsはアプリケーションがルート（例：`/`）で実行されていることを想定しています。このセクションでは、ディレクトリ内でアプリケーションを実行する方法について説明します。

例えば、アプリケーションを "/app1" にデプロイしたいとします。Railsは適切なルートを生成するためにこのディレクトリを知る必要があります。

```ruby
config.relative_url_root = "/app1"
```

または、`RAILS_RELATIVE_URL_ROOT` 環境変数を設定することもできます。

Railsはリンクを生成する際に "/app1" を先頭に追加します。

#### Passengerの使用

Passengerを使用すると、サブディレクトリでアプリケーションを実行することが簡単になります。詳細な設定については、[Passengerのマニュアル](https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/#deploying-an-app-to-a-sub-uri-or-subdirectory)を参照してください。

#### リバースプロキシの使用

リバースプロキシを使用してアプリケーションをデプロイすると、従来のデプロイよりも明確な利点があります。これにより、アプリケーションに必要なコンポーネントをレイヤー化することで、サーバーをより制御できるようになります。

多くの現代のWebサーバーは、キャッシュサーバーやアプリケーションサーバーなどのサードパーティの要素をバランスするためにプロキシサーバーとして使用することができます。

そのようなアプリケーションサーバーの1つとして、[Unicorn](https://bogomips.org/unicorn/)をリバースプロキシの背後で実行することができます。

この場合、プロキシサーバー（NGINX、Apacheなど）を設定して、アプリケーションサーバー（Unicorn）からの接続を受け入れる必要があります。デフォルトでは、Unicornはポート8080でTCP接続を待ち受けますが、ポートを変更したり、ソケットを使用するように設定することもできます。
詳細な情報は、[Unicorn readme](https://bogomips.org/unicorn/README.html)を参照し、それに関連する[哲学](https://bogomips.org/unicorn/PHILOSOPHY.html)を理解してください。

アプリケーションサーバーを設定した後、ウェブサーバーを適切に設定してリクエストをプロキシする必要があります。たとえば、NGINXの設定には次のようなものが含まれる場合があります。

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

最新の情報については、[NGINXのドキュメント](https://nginx.org/en/docs/)を参照してください。

Railsの環境設定
--------------------------

Railsの一部は環境変数を指定することで外部から設定することもできます。以下の環境変数は、Railsのさまざまな部分で認識されます。

* `ENV["RAILS_ENV"]`は、Railsが実行されるRailsの環境（production、development、testなど）を定義します。

* `ENV["RAILS_RELATIVE_URL_ROOT"]`は、[アプリケーションをサブディレクトリにデプロイする](configuring.html#deploy-to-a-subdirectory-relative-url-root)際に、ルーティングコードがURLを認識するために使用されます。

* `ENV["RAILS_CACHE_ID"]`と`ENV["RAILS_APP_VERSION"]`は、Railsのキャッシュコードで拡張キャッシュキーを生成するために使用されます。これにより、同じアプリケーションから複数の別々のキャッシュを持つことができます。


イニシャライザファイルの使用
-----------------------

フレームワークとアプリケーション内のgemをロードした後、Railsはイニシャライザのロードに移ります。イニシャライザは、アプリケーションの`config/initializers`ディレクトリに格納された任意のRubyファイルです。イニシャライザを使用して、フレームワークやgemのロード後に行う必要のある設定を保持することができます。

`config/initializers`ディレクトリ（および`config/initializers`のサブディレクトリ）のファイルは、`load_config_initializers`イニシャライザの一部として1つずつ順番にソートされてロードされます。

イニシャライザには、他のイニシャライザのコードに依存するコードがある場合、それらを1つのイニシャライザに組み合わせることもできます。これにより、依存関係が明示的になり、アプリケーション内の新しい概念が浮かび上がるのに役立ちます。Railsはイニシャライザファイル名の番号付けもサポートしていますが、ファイル名の変更が頻繁に発生する可能性があります。`require`を使用してイニシャライザを明示的にロードすることは推奨されません。なぜなら、イニシャライザが2回ロードされるためです。

注意：イニシャライザがすべてのgemのイニシャライザの後に実行されることは保証されていませんので、特定のgemが初期化された後に依存する初期化コードは、`config.after_initialize`ブロックに配置する必要があります。

初期化イベント
---------------------

Railsには、フックできる初期化イベントが5つあります（実行される順にリストアップされています）：

* `before_configuration`：このイベントは、アプリケーション定数が`Rails::Application`を継承するとすぐに実行されます。`config`の呼び出しは、これが行われる前に評価されます。
* `before_initialize`: これは、Railsの初期化プロセスの開始時点で、`:bootstrap_hook`イニシャライザの直前に直接実行されます。

* `to_prepare`: すべてのRailties（アプリケーション自体を含む）のイニシャライザが実行された後、イーガーローディングとミドルウェアスタックの構築の前に実行されます。重要なのは、`development`ではコードの再読み込みごとに実行されますが、`production`と`test`では起動時に1回だけ実行されます。

* `before_eager_load`: これは、イーガーローディングが実行される直前に実行されます。これは`production`環境のデフォルトの動作であり、`development`環境では実行されません。

* `after_initialize`: アプリケーションの初期化直後に実行されます。`config/initializers`内のアプリケーションイニシャライザが実行された後に実行されます。

これらのフックのイベントを定義するには、`Rails::Application`、`Rails::Railtie`、または`Rails::Engine`のサブクラス内でブロック構文を使用します。

```ruby
module YourApp
  class Application < Rails::Application
    config.before_initialize do
      # 初期化コードをここに記述します
    end
  end
end
```

または、`Rails.application`オブジェクトの`config`メソッドを使用して行うこともできます。

```ruby
Rails.application.config.before_initialize do
  # 初期化コードをここに記述します
end
```

警告: `after_initialize`ブロックが呼び出される時点では、ルーティングなどのアプリケーションの一部がまだ設定されていません。

### `Rails::Railtie#initializer`

Railsには、起動時に実行されるいくつかのイニシャライザがあり、これらはすべて`Rails::Railtie`の`initializer`メソッドを使用して定義されます。以下は、Action Controllerの`set_helpers_path`イニシャライザの例です。

```ruby
initializer "action_controller.set_helpers_path" do |app|
  ActionController::Helpers.helpers_path = app.helpers_paths
end
```

`initializer`メソッドは3つの引数を取ります。最初の引数はイニシャライザの名前で、2番目の引数はオプションのハッシュ（ここでは省略しています）、3番目の引数はブロックです。オプションハッシュの`before`キーを指定することで、新しいイニシャライザがどのイニシャライザよりも前に実行されるかを指定することができます。また、`after`キーを使用して、このイニシャライザがどのイニシャライザの後に実行されるかを指定することもできます。

`initializer`メソッドで定義されたイニシャライザは、定義された順に実行されますが、`before`または`after`メソッドを使用するイニシャライザを除いては、実行順序は保証されません。

警告: イニシャライザをチェーン内の他のイニシャライザの前後に配置することは、論理的である限り可能です。たとえば、"one"から"four"までの4つのイニシャライザがあるとします（この順序で定義されています）。そして、"four"を"two"の前に、"three"の後に配置するというのは論理的ではないため、Railsはイニシャライザの順序を決定できません。

`initializer`メソッドのブロック引数はアプリケーション自体のインスタンスであり、例のように`config`メソッドを使用してその設定にアクセスすることができます。
`Rails::Application`は`Rails::Railtie`を継承しているため、`config/application.rb`内の`initializer`メソッドを使用してアプリケーションの初期化子を定義することができます。

### 初期化子

以下は、Railsで定義されているすべての初期化子の包括的なリストです（それに従って実行される順序で表示されます）。

* `load_environment_hook`：`:load_environment_config`がそれより前に実行されるように定義できるようにするためのプレースホルダーとして機能します。

* `load_active_support`：Active Supportの基盤を設定する`active_support/dependencies`を要求します。`config.active_support.bare`が真でない場合（デフォルト）、`active_support/all`をオプションで要求します。

* `initialize_logger`：アプリケーションのロガー（`ActiveSupport::Logger`オブジェクト）を初期化し、`Rails.logger`でアクセスできるようにします。ただし、このポイントより前に挿入された初期化子で`Rails.logger`が定義されていない場合に限ります。

* `initialize_cache`：`Rails.cache`がまだ設定されていない場合、`config.cache_store`の値を参照してキャッシュを初期化し、結果を`Rails.cache`として保存します。このオブジェクトが`middleware`メソッドに応答する場合、そのミドルウェアはミドルウェアスタックの`Rack::Runtime`の前に挿入されます。

* `set_clear_dependencies_hook`：この初期化子は、`config.enable_reloading`が`true`に設定されている場合にのみ実行され、リクエスト中に参照された定数をオブジェクトスペースから削除し、次のリクエストで再読み込みされるようにするために`ActionDispatch::Callbacks.after`を使用します。

* `bootstrap_hook`：設定されたすべての`before_initialize`ブロックを実行します。

* `i18n.callbacks`：開発環境では、最後のリクエスト以降にロケールが変更された場合に`I18n.reload!`を呼び出す`to_prepare`コールバックを設定します。本番環境では、このコールバックは最初のリクエスト時にのみ実行されます。

* `active_support.deprecation_behavior`：[`config.active_support.report_deprecations`](#config-active-support-report-deprecations)、[`config.active_support.deprecation`](#config-active-support-deprecation)、[`config.active_support.disallowed_deprecation`](#config-active-support-disallowed-deprecation)、[`config.active_support.disallowed_deprecation_warnings`](#config-active-support-disallowed-deprecation-warnings)に基づいて[`Rails.application.deprecators`][]の非推奨報告動作を設定します。

* `active_support.initialize_time_zone`：`config.time_zone`設定に基づいてアプリケーションのデフォルトタイムゾーンを設定します。デフォルトは「UTC」です。

* `active_support.initialize_beginning_of_week`：`config.beginning_of_week`設定に基づいてアプリケーションのデフォルト週の開始日を設定します。デフォルトは`:monday`です。

* `active_support.set_configs`：`config.active_support`の設定を使用してActive Supportを設定します。メソッド名を`ActiveSupport`のセッターとして`send`し、値を渡します。

* `action_dispatch.configure`：`config.action_dispatch.tld_length`の値を`ActionDispatch::Http::URL.tld_length`に設定します。

* `action_view.set_configs`：`config.action_view`の設定を使用してAction Viewを設定します。メソッド名を`ActionView::Base`のセッターとして`send`し、値を渡します。

* `action_controller.assets_config`：明示的に設定されていない場合、`config.action_controller.assets_dir`をアプリケーションのパブリックディレクトリに初期化します。

* `action_controller.set_helpers_path`：Action Controllerの`helpers_path`をアプリケーションの`helpers_path`に設定します。

* `action_controller.parameters_config`：`ActionController::Parameters`の強力なパラメータオプションを設定します。

* `action_controller.set_configs`：`config.action_controller`の設定を使用してAction Controllerを設定します。メソッド名を`ActionController::Base`のセッターとして`send`し、値を渡します。
* `action_controller.compile_config_methods`: 指定された設定のメソッドを初期化し、アクセスが高速化されるようにします。

* `active_record.initialize_timezone`: `ActiveRecord::Base.time_zone_aware_attributes`を`true`に設定し、`ActiveRecord::Base.default_timezone`をUTCに設定します。データベースから属性が読み取られる際には、`Time.zone`で指定されたタイムゾーンに変換されます。

* `active_record.logger`: `ActiveRecord::Base.logger`を設定します。既に設定されていない場合は、`Rails.logger`を使用します。

* `active_record.migration_error`: 未実行のマイグレーションをチェックするためのミドルウェアを設定します。

* `active_record.check_schema_cache_dump`: 設定されている場合、スキーマキャッシュダンプをロードします。

* `active_record.warn_on_records_fetched_greater_than`: クエリが大量のレコードを返す場合に警告を有効にします。

* `active_record.set_configs`: `config.active_record`の設定を使用してActive Recordをセットアップします。メソッド名を`send`して`ActiveRecord::Base`のセッターとして使用し、値を渡します。

* `active_record.initialize_database`: データベースの設定（デフォルトでは`config/database.yml`から）をロードし、現在の環境に接続を確立します。

* `active_record.log_runtime`: `ActiveRecord::Railties::ControllerRuntime`と`ActiveRecord::Railties::JobRuntime`を含み、リクエストのためのActive Record呼び出しにかかった時間をロガーに報告する役割を担います。

* `active_record.set_reloader_hooks`: `config.enable_reloading`が`true`に設定されている場合、リロード可能なすべてのデータベース接続をリセットします。

* `active_record.add_watchable_files`: `schema.rb`と`structure.sql`ファイルを監視対象ファイルに追加します。

* `active_job.logger`: `ActiveJob::Base.logger`を設定します。既に設定されていない場合は、`Rails.logger`を使用します。

* `active_job.set_configs`: `config.active_job`の設定を使用してActive Jobをセットアップします。メソッド名を`send`して`ActiveJob::Base`のセッターとして使用し、値を渡します。

* `action_mailer.logger`: `ActionMailer::Base.logger`を設定します。既に設定されていない場合は、`Rails.logger`を使用します。

* `action_mailer.set_configs`: `config.action_mailer`の設定を使用してAction Mailerをセットアップします。メソッド名を`send`して`ActionMailer::Base`のセッターとして使用し、値を渡します。

* `action_mailer.compile_config_methods`: 指定された設定のメソッドを初期化し、アクセスが高速化されるようにします。

* `set_load_path`: この初期化子は`bootstrap_hook`の前に実行されます。`config.load_paths`で指定されたパスとすべての自動読み込みパスを`$LOAD_PATH`に追加します。

* `set_autoload_paths`: この初期化子は`bootstrap_hook`の前に実行されます。`app`のすべてのサブディレクトリと`config.autoload_paths`、`config.eager_load_paths`、`config.autoload_once_paths`で指定されたパスを`ActiveSupport::Dependencies.autoload_paths`に追加します。

* `add_routing_paths`: アプリケーションとレイルティ、エンジンを含むすべての`config/routes.rb`ファイルを（デフォルトで）ロードし、アプリケーションのルートを設定します。

* `add_locales`: アプリケーション、レイルティ、エンジンの`config/locales`にあるファイルを`I18n.load_path`に追加し、これらのファイルの翻訳を利用できるようにします。

* `add_view_paths`: アプリケーション、レイルティ、エンジンの`app/views`ディレクトリをビューファイルの検索パスに追加します。

* `add_mailer_preview_paths`: アプリケーション、レイルティ、エンジンの`test/mailers/previews`ディレクトリをメーラープレビューファイルの検索パスに追加します。
* `load_environment_config`: このイニシャライザは`load_environment_hook`の前に実行されます。現在の環境の`config/environments`ファイルを読み込みます。

* `prepend_helpers_path`: アプリケーション、railties、エンジンから`app/helpers`ディレクトリをヘルパーの検索パスに追加します。

* `load_config_initializers`: アプリケーション、railties、エンジンから`config/initializers`のすべてのRubyファイルを読み込みます。このディレクトリのファイルは、すべてのフレームワークが読み込まれた後に行われるべき設定を保持するために使用されます。

* `engines_blank_point`: エンジンがロードされる前に何かを行いたい場合にフックするための初期化ポイントを提供します。このポイント以降、すべてのrailtieおよびエンジンのイニシャライザが実行されます。

* `add_generator_templates`: アプリケーション、railties、エンジンの`lib/templates`でジェネレータのテンプレートを検索し、これらを`config.generators.templates`設定に追加します。これにより、すべてのジェネレータが参照できるようになります。

* `ensure_autoload_once_paths_as_subset`: `config.autoload_once_paths`が`config.autoload_paths`のパスのみを含むようにします。余分なパスが含まれている場合は例外が発生します。

* `add_to_prepare_blocks`: アプリケーション、railtie、またはエンジンのすべての`config.to_prepare`呼び出しのブロックは、開発時にリクエストごとに実行されるか、本番環境で最初のリクエストの前に実行されるAction Dispatchの`to_prepare`コールバックに追加されます。

* `add_builtin_route`: アプリケーションが開発環境で実行されている場合、これにより`rails/info/properties`のルートがアプリケーションのルートに追加されます。このルートは、デフォルトのRailsアプリケーションの`public/index.html`にRailsおよびRubyのバージョンなどの詳細情報を提供します。

* `build_middleware_stack`: アプリケーションのミドルウェアスタックを構築し、リクエストのためのRack環境オブジェクトを受け取る`call`メソッドを持つオブジェクトを返します。

* `eager_load!`: `config.eager_load`が`true`の場合、`config.before_eager_load`フックを実行し、すべての`config.eager_load_namespaces`をロードする`eager_load!`を呼び出します。

* `finisher_hook`: アプリケーションの初期化プロセスが完了した後のフックを提供し、アプリケーション、railties、エンジンのすべての`config.after_initialize`ブロックを実行します。

* `set_routes_reloader_hook`: Action Dispatchを設定して、`ActiveSupport::Callbacks.to_run`を使用してルートファイルをリロードします。

* `disable_dependency_loading`: `config.eager_load`が`true`に設定されている場合、自動的な依存関係のロードを無効にします。


データベースプーリング
----------------

Active Recordのデータベース接続は、`ActiveRecord::ConnectionAdapters::ConnectionPool`によって管理されます。これにより、データベース接続のスレッドアクセスの数を制限するための接続プールが同期されます。この制限はデフォルトで5に設定されており、`database.yml`で設定することができます。

```ruby
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

接続プーリングはデフォルトでActive Record内部で処理されるため、すべてのアプリケーションサーバー（Thin、Puma、Unicornなど）は同じように動作するはずです。データベース接続プールは最初は空です。接続の需要が増えると、接続プールの制限に達するまで接続を作成します。
任意のリクエストは、データベースへのアクセスが必要な場合は最初に接続を確認します。リクエストの最後には、接続をチェックアウトします。これにより、追加の接続スロットはキュー内の次のリクエストに再度利用可能になります。

利用可能な接続数を超えて接続を使用しようとすると、Active Recordはブロックされ、プールからの接続を待機します。接続を取得できない場合、以下のようなタイムアウトエラーがスローされます。

```ruby
ActiveRecord::ConnectionTimeoutError - could not obtain a database connection within 5.000 seconds (waited 5.000 seconds)
```

上記のエラーが発生した場合は、`database.yml`の`pool`オプションを増やすことで接続プールのサイズを増やすことを検討する必要があります。

注意：マルチスレッド環境で実行している場合、複数のスレッドが同時に複数の接続にアクセスする可能性があります。したがって、現在のリクエストの負荷に応じて、限られた数の接続を競合する複数のスレッドを持つことがあります。


カスタム設定
--------------------

Railsの設定オブジェクトを使用して、独自のコードを設定することができます。独自の設定は、`config.x`名前空間または直接`config`の下に配置することができます。これら2つの違いは、ネストされた設定（例：`config.x.nested.hi`）を定義している場合は`config.x`を使用し、単一レベルの設定（例：`config.hello`）には`config`を使用する必要があるということです。

```ruby
config.x.payment_processing.schedule = :daily
config.x.payment_processing.retries  = 3
config.super_debugger = true
```

これらの設定ポイントは、設定オブジェクトを介して利用できます。

```ruby
Rails.configuration.x.payment_processing.schedule # => :daily
Rails.configuration.x.payment_processing.retries  # => 3
Rails.configuration.x.payment_processing.not_set  # => nil
Rails.configuration.super_debugger                # => true
```

また、`Rails::Application.config_for`を使用して設定ファイル全体をロードすることもできます。

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
Rails.configuration.payment['merchant_id'] # => production_merchant_idまたはdevelopment_merchant_id
```

`Rails::Application.config_for`は、共有設定を使用して共通の設定をグループ化することもサポートしています。共有設定は環境設定にマージされます。

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
# development environment
Rails.application.config_for(:example)[:foo][:bar] #=> { baz: 1, qux: 2 }
```

検索エンジンのインデックス作成
-----------------------

時には、Google、Bing、Yahoo、Duck Duck Goなどの検索サイトでアプリケーションの一部のページを表示したくない場合があります。これらのサイトをインデックスするロボットは、最初に`http://your-site.com/robots.txt`ファイルを分析して、インデックスを許可されるページを知ることになります。
Railsは、`/public`フォルダ内にこのファイルを作成します。デフォルトでは、検索エンジンがアプリケーションのすべてのページをインデックス化することが許可されています。アプリケーションのすべてのページでインデックス化をブロックしたい場合は、次のようにします。

```
User-agent: *
Disallow: /
```

特定のページのみをブロックする場合は、より複雑な構文を使用する必要があります。公式ドキュメントで学ぶことができます（https://www.robotstxt.org/robotstxt.html）。

イベント駆動型ファイルシステムモニター
---------------------------

[listen gem](https://github.com/guard/listen)がロードされている場合、Railsはリロードが有効になっている場合に変更を検出するためにイベント駆動型のファイルシステムモニターを使用します。

```ruby
group :development do
  gem 'listen', '~> 3.3'
end
```

それ以外の場合、すべてのリクエストでRailsはアプリケーションツリーを辿って変更があるかどうかを確認します。

LinuxとmacOSでは追加のgemは必要ありませんが、一部のgemが必要です（[for *BSD](https://github.com/guard/listen#on-bsd)および[for Windows](https://github.com/guard/listen#on-windows)）。

なお、[一部のセットアップはサポートされていません](https://github.com/guard/listen#issues--limitations)。
[`config.load_defaults`]: https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults
[`ActiveSupport::ParameterFilter.precompile_filters`]: https://api.rubyonrails.org/classes/ActiveSupport/ParameterFilter.html#method-c-precompile_filters
[ActiveModel::Error#full_message]: https://api.rubyonrails.org/classes/ActiveModel/Error.html#method-i-full_message
[`ActiveSupport::MessageEncryptor`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html
[`ActiveSupport::MessageVerifier`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html
[`message_serializer_fallback.active_support`]: active_support_instrumentation.html#message-serializer-fallback-active-support
[`Rails.application.deprecators`]: https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators
