**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bba7dd6e311e7abd59e434f12dbebd0e
Configuración de aplicaciones Rails
====================================

Esta guía cubre las características de configuración e inicialización disponibles para las aplicaciones Rails.

Después de leer esta guía, sabrás:

* Cómo ajustar el comportamiento de tus aplicaciones Rails.
* Cómo agregar código adicional para que se ejecute al iniciar la aplicación.

--------------------------------------------------------------------------------

Ubicaciones para el código de inicialización
-------------------------------------------

Rails ofrece cuatro lugares estándar para colocar el código de inicialización:

* `config/application.rb`
* Archivos de configuración específicos del entorno
* Inicializadores
* Después de los inicializadores

Ejecutar código antes de Rails
-----------------------------

En el raro caso de que tu aplicación necesite ejecutar algún código antes de que se cargue Rails en sí, colócalo antes de la llamada a `require "rails/all"` en `config/application.rb`.

Configuración de los componentes de Rails
-----------------------------------------

En general, el trabajo de configurar Rails implica configurar los componentes de Rails, así como configurar Rails en sí. El archivo de configuración `config/application.rb` y los archivos de configuración específicos del entorno (como `config/environments/production.rb`) te permiten especificar las diferentes configuraciones que deseas pasar a todos los componentes.

Por ejemplo, podrías agregar esta configuración al archivo `config/application.rb`:

```ruby
config.time_zone = 'Central Time (US & Canada)'
```

Esta es una configuración para Rails en sí. Si deseas pasar configuraciones a componentes individuales de Rails, puedes hacerlo a través del mismo objeto `config` en `config/application.rb`:

```ruby
config.active_record.schema_format = :ruby
```

Rails utilizará esa configuración en particular para configurar Active Record.

ADVERTENCIA: Utiliza los métodos de configuración públicos en lugar de llamar directamente a la clase asociada. Por ejemplo, utiliza `Rails.application.config.action_mailer.options` en lugar de `ActionMailer::Base.options`.

NOTA: Si necesitas aplicar configuración directamente a una clase, utiliza un [gancho de carga diferida](https://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html) en un inicializador para evitar la carga automática de la clase antes de que se haya completado la inicialización. Esto fallará porque la carga automática durante la inicialización no se puede repetir de manera segura cuando la aplicación se recarga.

### Valores predeterminados versionados

[`config.load_defaults`] carga los valores de configuración predeterminados para una versión objetivo y todas las versiones anteriores. Por ejemplo, `config.load_defaults 6.1` cargará los valores predeterminados para todas las versiones hasta e incluyendo la versión 6.1.

A continuación se muestran los valores predeterminados asociados con cada versión objetivo. En casos de valores conflictivos, las versiones más nuevas tienen prioridad sobre las versiones más antiguas.

#### Valores predeterminados para la versión objetivo 7.1

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

#### Valores predeterminados para la versión objetivo 7.0

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
#### Valores predeterminados para la versión objetivo 6.1

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

#### Valores predeterminados para la versión objetivo 6.0

- [`config.action_dispatch.use_cookies_with_metadata`](#config-action-dispatch-use-cookies-with-metadata): `true`
- [`config.action_mailer.delivery_job`](#config-action-mailer-delivery-job): `"ActionMailer::MailDeliveryJob"`
- [`config.action_view.default_enforce_utf8`](#config-action-view-default-enforce-utf8): `false`
- [`config.active_record.collection_cache_versioning`](#config-active-record-collection-cache-versioning): `true`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `:active_storage_analysis`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `:active_storage_purge`

#### Valores predeterminados para la versión objetivo 5.2

- [`config.action_controller.default_protect_from_forgery`](#config-action-controller-default-protect-from-forgery): `true`
- [`config.action_dispatch.use_authenticated_cookie_encryption`](#config-action-dispatch-use-authenticated-cookie-encryption): `true`
- [`config.action_view.form_with_generates_ids`](#config-action-view-form-with-generates-ids): `true`
- [`config.active_record.cache_versioning`](#config-active-record-cache-versioning): `true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA1`
- [`config.active_support.use_authenticated_message_encryption`](#config-active-support-use-authenticated-message-encryption): `true`

#### Valores predeterminados para la versión objetivo 5.1

- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `true`
- [`config.assets.unknown_asset_fallback`](#config-assets-unknown-asset-fallback): `false`

#### Valores predeterminados para la versión objetivo 5.0

- [`ActiveSupport.to_time_preserves_timezone`](#activesupport-to-time-preserves-timezone): `true`
- [`config.action_controller.forgery_protection_origin_check`](#config-action-controller-forgery-protection-origin-check): `true`
- [`config.action_controller.per_form_csrf_tokens`](#config-action-controller-per-form-csrf-tokens): `true`
- [`config.active_record.belongs_to_required_by_default`](#config-active-record-belongs-to-required-by-default): `true`
- [`config.ssl_options`](#config-ssl-options): `{ hsts: { subdomains: true } }`

### Configuración general de Rails

Los siguientes métodos de configuración deben ser llamados en un objeto `Rails::Railtie`, como una subclase de `Rails::Engine` o `Rails::Application`.

#### `config.add_autoload_paths_to_load_path`

Indica si las rutas de carga automática deben agregarse a `$LOAD_PATH`. Se recomienda establecerlo en `false` en el modo `:zeitwerk` temprano, en `config/application.rb`. Zeitwerk utiliza rutas absolutas internamente y las aplicaciones que se ejecutan en modo `:zeitwerk` no necesitan `require_dependency`, por lo que los modelos, controladores, trabajos, etc. no necesitan estar en `$LOAD_PATH`. Establecer esto en `false` ahorra a Ruby tener que verificar estos directorios al resolver llamadas `require` con rutas relativas, y ahorra trabajo y RAM a Bootsnap, ya que no necesita construir un índice para ellos.

El valor predeterminado depende de la versión objetivo `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `true`                    |
| 7.1                   | `false`                   |

El directorio `lib` no se ve afectado por esta bandera, siempre se agrega a `$LOAD_PATH`.

#### `config.after_initialize`

Toma un bloque que se ejecutará _después_ de que Rails haya terminado de inicializar la aplicación. Esto incluye la inicialización del propio framework, los motores y todos los inicializadores de la aplicación en `config/initializers`. Tenga en cuenta que este bloque se ejecutará para las tareas de rake. Útil para configurar valores establecidos por otros inicializadores:

```ruby
config.after_initialize do
  ActionView::Base.sanitized_allowed_tags.delete 'div'
end
```

#### `config.after_routes_loaded`

Toma un bloque que se ejecutará después de que Rails haya terminado de cargar las rutas de la aplicación. Este bloque también se ejecutará cada vez que se recarguen las rutas.

```ruby
config.after_routes_loaded do
  # Código que hace algo con Rails.application.routes
end
```

#### `config.allow_concurrency`

Controla si las solicitudes deben manejarse de forma concurrente. Esto solo debe establecerse en `false` si el código de la aplicación no es seguro para subprocesos. El valor predeterminado es `true`.

#### `config.asset_host`

Establece el host para los activos. Útil cuando se utilizan CDNs para alojar activos, o cuando se desea evitar las limitaciones de concurrencia incorporadas en los navegadores mediante el uso de alias de dominio diferentes. Versión abreviada de `config.action_controller.asset_host`.

#### `config.assume_ssl`

Hace que la aplicación crea que todas las solicitudes llegan a través de SSL. Esto es útil cuando se utiliza un equilibrador de carga que termina SSL, la solicitud reenviada aparecerá como si fuera HTTP en lugar de HTTPS para la aplicación. Esto hace que las redirecciones y la seguridad de las cookies apunten a HTTP en lugar de HTTPS. Este middleware hace que el servidor asuma que el proxy ya terminó SSL y que la solicitud realmente es HTTPS.
#### `config.autoflush_log`

Permite escribir inmediatamente la salida del archivo de registro en lugar de almacenar en búfer. El valor predeterminado es `true`.

#### `config.autoload_once_paths`

Acepta una matriz de rutas desde las cuales Rails cargará constantes que no se eliminarán por solicitud. Es relevante si la recarga está habilitada, lo cual es el valor predeterminado en el entorno `development`. De lo contrario, la carga automática ocurre solo una vez. Todos los elementos de esta matriz también deben estar en `autoload_paths`. El valor predeterminado es una matriz vacía.

#### `config.autoload_paths`

Acepta una matriz de rutas desde las cuales Rails cargará constantes. El valor predeterminado es una matriz vacía. Desde [Rails 6](upgrading_ruby_on_rails.html#autoloading), no se recomienda ajustar esto. Consulta [Carga automática y recarga de constantes](autoloading_and_reloading_constants.html#autoload-paths).

#### `config.autoload_lib(ignore:)`

Este método agrega `lib` a `config.autoload_paths` y `config.eager_load_paths`.

Normalmente, el directorio `lib` tiene subdirectorios que no deben cargarse automáticamente o cargarse de forma ansiosa. Por favor, pasa su nombre relativo a `lib` en el argumento de palabra clave `ignore` requerido. Por ejemplo,

```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

Consulta más detalles en la [guía de carga automática](autoloading_and_reloading_constants.html).

#### `config.autoload_lib_once(ignore:)`

El método `config.autoload_lib_once` es similar a `config.autoload_lib`, excepto que agrega `lib` a `config.autoload_once_paths` en su lugar.

Al llamar a `config.autoload_lib_once`, las clases y módulos en `lib` se pueden cargar automáticamente, incluso desde inicializadores de la aplicación, pero no se volverán a cargar.

#### `config.beginning_of_week`

Establece el inicio de la semana predeterminado para la aplicación. Acepta un día de la semana válido como un símbolo (por ejemplo, `:monday`).

#### `config.cache_classes`

Configuración antigua equivalente a `!config.enable_reloading`. Compatible con la compatibilidad con versiones anteriores.

#### `config.cache_store`

Configura qué almacén de caché usar para el almacenamiento en caché de Rails. Las opciones incluyen uno de los símbolos `:memory_store`, `:file_store`, `:mem_cache_store`, `:null_store`, `:redis_cache_store`, o un objeto que implementa la API de caché. El valor predeterminado es `:file_store`. Consulta [Almacenes de caché](caching_with_rails.html#cache-stores) para opciones de configuración por almacén.

#### `config.colorize_logging`

Especifica si usar o no códigos de color ANSI al registrar información. El valor predeterminado es `true`.

#### `config.consider_all_requests_local`

Es una bandera. Si es `true`, cualquier error causará que se muestre información detallada de depuración en la respuesta HTTP, y el controlador `Rails::Info` mostrará el contexto de tiempo de ejecución de la aplicación en `/rails/info/properties`. Es `true` de forma predeterminada en los entornos de desarrollo y prueba, y `false` en producción. Para un control más detallado, establece esto en `false` e implementa `show_detailed_exceptions?` en los controladores para especificar qué solicitudes deben proporcionar información de depuración en caso de errores.

#### `config.console`

Te permite establecer la clase que se utilizará como consola cuando ejecutes `bin/rails console`. Es mejor ejecutarlo en el bloque `console`:

```ruby
console do
  # este bloque se llama solo cuando se ejecuta la consola,
  # por lo que podemos requerir con seguridad pry aquí
  require "pry"
  config.console = Pry
end
```

#### `config.content_security_policy_nonce_directives`

Consulta [Agregar un Nonce](security.html#adding-a-nonce) en la Guía de Seguridad.

#### `config.content_security_policy_nonce_generator`

Consulta [Agregar un Nonce](security.html#adding-a-nonce) en la Guía de Seguridad.

#### `config.content_security_policy_report_only`

Consulta [Informar Violaciones](security.html#reporting-violations) en la Guía de Seguridad.

#### `config.credentials.content_path`

La ruta del archivo de credenciales encriptadas.

El valor predeterminado es `config/credentials/#{Rails.env}.yml.enc` si existe, o `config/credentials.yml.enc` en caso contrario.

NOTA: Para que los comandos `bin/rails credentials` reconozcan este valor, debe establecerse en `config/application.rb` o `config/environments/#{Rails.env}.rb`.

#### `config.credentials.key_path`

La ruta del archivo de clave de credenciales encriptadas.

El valor predeterminado es `config/credentials/#{Rails.env}.key` si existe, o `config/master.key` en caso contrario.

NOTA: Para que los comandos `bin/rails credentials` reconozcan este valor, debe establecerse en `config/application.rb` o `config/environments/#{Rails.env}.rb`.
#### `config.debug_exception_response_format`

Establece el formato utilizado en las respuestas cuando ocurren errores en el entorno de desarrollo. Por defecto, es `:api` para aplicaciones solo de API y `:default` para aplicaciones normales.

#### `config.disable_sandbox`

Controla si alguien puede iniciar una consola en modo sandbox o no. Esto es útil para evitar una sesión de consola sandbox que se ejecute durante mucho tiempo y pueda hacer que el servidor de la base de datos se quede sin memoria. Por defecto, es `false`.

#### `config.eager_load`

Cuando es `true`, carga de forma anticipada todos los `config.eager_load_namespaces` registrados. Esto incluye tu aplicación, motores, frameworks de Rails y cualquier otro namespace registrado.

#### `config.eager_load_namespaces`

Registra los namespaces que se cargan de forma anticipada cuando `config.eager_load` está configurado como `true`. Todos los namespaces en la lista deben responder al método `eager_load!`.

#### `config.eager_load_paths`

Acepta una matriz de rutas desde las cuales Rails cargará de forma anticipada al iniciar si `config.eager_load` es `true`. Por defecto, incluye todas las carpetas en el directorio `app` de la aplicación.

#### `config.enable_reloading`

Si `config.enable_reloading` es `true`, las clases y módulos de la aplicación se recargan entre las solicitudes web si cambian. Por defecto, es `true` en el entorno de `development` y `false` en el entorno de `production`.

También se define el predicado `config.reloading_enabled?`.

#### `config.encoding`

Configura la codificación de toda la aplicación. Por defecto, es UTF-8.

#### `config.exceptions_app`

Establece la aplicación de excepciones invocada por el middleware `ShowException` cuando ocurre una excepción. Por defecto, es `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

Las aplicaciones de excepciones deben manejar errores de `ActionDispatch::Http::MimeNegotiation::InvalidType`, que se generan cuando un cliente envía un encabezado `Accept` o `Content-Type` inválido.
La aplicación `ActionDispatch::PublicExceptions` por defecto hace esto automáticamente, estableciendo `Content-Type` en `text/html` y devolviendo un estado `406 Not Acceptable`.
Si no se maneja este error, se generará un error `500 Internal Server Error`.

Usar el `RouteSet` de `Rails.application.routes` como aplicación de excepciones también requiere este manejo especial.
Podría verse algo así:

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

Es la clase utilizada para detectar actualizaciones de archivos en el sistema de archivos cuando `config.reload_classes_only_on_change` es `true`. Rails incluye `ActiveSupport::FileUpdateChecker` de forma predeterminada, y `ActiveSupport::EventedFileUpdateChecker` (este último depende de la gema [listen](https://github.com/guard/listen)). Las clases personalizadas deben cumplir con la API de `ActiveSupport::FileUpdateChecker`.

#### `config.filter_parameters`

Se utiliza para filtrar los parámetros que no se desean mostrar en los registros, como contraseñas o números de tarjetas de crédito. También filtra los valores sensibles de las columnas de la base de datos al llamar a `#inspect` en un objeto Active Record. Por defecto, Rails filtra las contraseñas agregando los siguientes filtros en `config/initializers/filter_parameter_logging.rb`.

```ruby
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

El filtro de parámetros funciona mediante coincidencia parcial con expresiones regulares.

#### `config.filter_redirect`

Se utiliza para filtrar las URL de redireccionamiento de los registros de la aplicación.

```ruby
Rails.application.config.filter_redirect += ['s3.amazonaws.com', /private-match/]
```

El filtro de redireccionamiento funciona probando que las URL incluyan cadenas o coincidan con expresiones regulares.

#### `config.force_ssl`

Fuerza que todas las solicitudes se sirvan a través de HTTPS y establece "https://" como el protocolo predeterminado al generar URLs. La aplicación de HTTPS se maneja mediante el middleware `ActionDispatch::SSL`, que se puede configurar a través de `config.ssl_options`.

#### `config.helpers_paths`
Define una matriz de rutas adicionales para cargar ayudantes de vista.

#### `config.host_authorization`

Acepta un hash de opciones para configurar el middleware [HostAuthorization](#actiondispatch-hostauthorization).

#### `config.hosts`

Una matriz de cadenas, expresiones regulares o `IPAddr` utilizadas para validar el encabezado `Host`. Utilizado por el middleware [HostAuthorization](#actiondispatch-hostauthorization) para ayudar a prevenir ataques de reenvío DNS.

#### `config.javascript_path`

Establece la ruta donde se encuentra el JavaScript de tu aplicación en relación al directorio `app`. El valor predeterminado es `javascript`, utilizado por [webpacker](https://github.com/rails/webpacker). La ruta de JavaScript configurada en la aplicación se excluye de `autoload_paths`.

#### `config.log_file_size`

Define el tamaño máximo del archivo de registro de Rails en bytes. Por defecto, es `104_857_600` (100 MiB) en desarrollo y prueba, y sin límite en todos los demás entornos.

#### `config.log_formatter`

Define el formateador del registrador de Rails. Esta opción tiene como valor predeterminado una instancia de `ActiveSupport::Logger::SimpleFormatter` para todos los entornos. Si estás configurando un valor para `config.logger`, debes pasar manualmente el valor de tu formateador a tu registrador antes de que se envuelva en una instancia de `ActiveSupport::TaggedLogging`, Rails no lo hará por ti.

#### `config.log_level`

Define la verbosidad del registrador de Rails. Esta opción tiene como valor predeterminado `:debug` para todos los entornos excepto producción, donde tiene como valor predeterminado `:info`. Los niveles de registro disponibles son: `:debug`, `:info`, `:warn`, `:error`, `:fatal` y `:unknown`.

#### `config.log_tags`

Acepta una lista de métodos a los que responde el objeto `request`, un `Proc` que acepta el objeto `request`, o algo que responda a `to_s`. Esto facilita la etiquetación de líneas de registro con información de depuración como el subdominio y el ID de solicitud, ambos muy útiles en la depuración de aplicaciones de producción con múltiples usuarios.

#### `config.logger`

Es el registrador que se utilizará para `Rails.logger` y cualquier registro relacionado de Rails, como `ActiveRecord::Base.logger`. Por defecto, es una instancia de `ActiveSupport::TaggedLogging` que envuelve una instancia de `ActiveSupport::Logger` que genera un registro en el directorio `log/`. Puedes proporcionar un registrador personalizado, para obtener compatibilidad total debes seguir estas pautas:

* Para admitir un formateador, debes asignar manualmente un formateador del valor `config.log_formatter` al registrador.
* Para admitir registros etiquetados, la instancia de registro debe envolverse con `ActiveSupport::TaggedLogging`.
* Para admitir el silenciamiento, el registrador debe incluir el módulo `ActiveSupport::LoggerSilence`. La clase `ActiveSupport::Logger` ya incluye estos módulos.

```ruby
class MyLogger < ::Logger
  include ActiveSupport::LoggerSilence
end

mylogger           = MyLogger.new(STDOUT)
mylogger.formatter = config.log_formatter
config.logger      = ActiveSupport::TaggedLogging.new(mylogger)
```

#### `config.middleware`

Te permite configurar el middleware de la aplicación. Esto se cubre en profundidad en la sección [Configuración de Middleware](#configuring-middleware) a continuación.

#### `config.precompile_filter_parameters`

Cuando es `true`, precompilará [`config.filter_parameters`](#config-filter-parameters) utilizando [`ActiveSupport::ParameterFilter.precompile_filters`][].

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `false`                   |
| 7.1                   | `true`                    |


#### `config.public_file_server.enabled`

Configura Rails para servir archivos estáticos desde el directorio `public`. Esta opción tiene como valor predeterminado `true`, pero en el entorno de producción se establece en `false` porque el software del servidor (por ejemplo, NGINX o Apache) utilizado para ejecutar la aplicación debe servir archivos estáticos en su lugar. Si estás ejecutando o probando tu aplicación en producción utilizando WEBrick (no se recomienda utilizar WEBrick en producción), establece la opción en `true`. De lo contrario, no podrás utilizar el almacenamiento en caché de páginas y solicitar archivos que existan en el directorio `public`.
#### `config.railties_order`

Permite especificar manualmente el orden en que se cargan las Railties/Engines. El valor predeterminado es `[:all]`.

```ruby
config.railties_order = [Blog::Engine, :main_app, :all]
```

#### `config.rake_eager_load`

Cuando es `true`, carga la aplicación de forma anticipada al ejecutar tareas de Rake. El valor predeterminado es `false`.

#### `config.read_encrypted_secrets`

*DEPRECIADO*: Deberías usar [credentials](https://guides.rubyonrails.org/security.html#custom-credentials) en lugar de secretos encriptados.

Cuando es `true`, intentará leer secretos encriptados desde `config/secrets.yml.enc`.

#### `config.relative_url_root`

Se puede utilizar para indicarle a Rails que se está [implementando en un subdirectorio](configuring.html#deploy-to-a-subdirectory-relative-url-root). El valor predeterminado es `ENV['RAILS_RELATIVE_URL_ROOT']`.

#### `config.reload_classes_only_on_change`

Habilita o deshabilita la recarga de clases solo cuando cambian los archivos rastreados. De forma predeterminada, rastrea todo en las rutas de carga automática y se establece en `true`. Si `config.enable_reloading` es `false`, esta opción se ignora.

#### `config.require_master_key`

Hace que la aplicación no se inicie si no se ha proporcionado una clave maestra a través de `ENV["RAILS_MASTER_KEY"]` o el archivo `config/master.key`.

#### `config.secret_key_base`

El valor de respaldo para especificar la clave de entrada para el generador de claves de una aplicación. Se recomienda dejar esto sin configurar y, en su lugar, especificar una `secret_key_base` en `config/credentials.yml.enc`. Consulta la documentación de la API [`secret_key_base`](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-secret_key_base) para obtener más información y métodos de configuración alternativos.

#### `config.server_timing`

Cuando es `true`, agrega el middleware [ServerTiming](#actiondispatch-servertiming) a la pila de middlewares.

#### `config.session_options`

Opciones adicionales pasadas a `config.session_store`. Debes usar `config.session_store` para establecer esto en lugar de modificarlo tú mismo.

```ruby
config.session_store :cookie_store, key: "_your_app_session"
config.session_options # => {key: "_your_app_session"}
```

#### `config.session_store`

Especifica qué clase utilizar para almacenar la sesión. Los valores posibles son `:cache_store`, `:cookie_store`, `:mem_cache_store`, un almacenamiento personalizado o `:disabled`. `:disabled` indica a Rails que no maneje las sesiones.

Esta configuración se realiza mediante una llamada a un método regular, en lugar de un setter. Esto permite pasar opciones adicionales:

```ruby
config.session_store :cookie_store, key: "_your_app_session"
```

Si se especifica un almacenamiento personalizado como un símbolo, se resolverá en el espacio de nombres `ActionDispatch::Session`:

```ruby
# utiliza ActionDispatch::Session::MyCustomStore como almacenamiento de sesión
config.session_store :my_custom_store
```

El almacenamiento predeterminado es un almacenamiento de cookies con el nombre de la aplicación como clave de sesión.

#### `config.ssl_options`

Opciones de configuración para el middleware [`ActionDispatch::SSL`](https://api.rubyonrails.org/classes/ActionDispatch/SSL.html).

El valor predeterminado depende de la versión de destino de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `{}`                      |
| 5.0                   | `{ hsts: { subdomains: true } }` |

#### `config.time_zone`

Establece la zona horaria predeterminada para la aplicación y habilita la conciencia de la zona horaria para Active Record.

#### `config.x`

Se utiliza para agregar fácilmente una configuración personalizada anidada al objeto de configuración de la aplicación.

  ```ruby
  config.x.payment_processing.schedule = :daily
  Rails.configuration.x.payment_processing.schedule # => :daily
  ```

Consulta [Configuración personalizada](#custom-configuration).

### Configuración de activos

#### `config.assets.css_compressor`

Define el compresor CSS a utilizar. Se establece de forma predeterminada por `sass-rails`. El único valor alternativo en este momento es `:yui`, que utiliza la gema `yui-compressor`.

#### `config.assets.js_compressor`

Define el compresor de JavaScript a utilizar. Los valores posibles son `:terser`, `:closure`, `:uglifier` y `:yui`, que requieren el uso de las gemas `terser`, `closure-compiler`, `uglifier` o `yui-compressor`, respectivamente.

#### `config.assets.gzip`

Una bandera que habilita la creación de una versión comprimida con gzip de los activos compilados, junto con los activos no comprimidos. Se establece en `true` de forma predeterminada.

#### `config.assets.paths`

Contiene las rutas que se utilizan para buscar activos. Agregar rutas a esta opción de configuración hará que se utilicen esas rutas en la búsqueda de activos.
#### `config.assets.precompile`

Permite especificar activos adicionales (que no sean `application.css` y `application.js`) que se deben precompilar cuando se ejecuta `bin/rails assets:precompile`.

#### `config.assets.unknown_asset_fallback`

Permite modificar el comportamiento del pipeline de activos cuando un activo no está en el pipeline, si se utiliza sprockets-rails 3.2.0 o una versión más reciente.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `true`                    |
| 5.1                   | `false`                   |

#### `config.assets.prefix`

Define el prefijo desde donde se sirven los activos. Por defecto es `/assets`.

#### `config.assets.manifest`

Define la ruta completa que se utilizará para el archivo de manifiesto del precompilador de activos. Por defecto es un archivo llamado `manifest-<random>.json` en el directorio `config.assets.prefix` dentro de la carpeta pública.

#### `config.assets.digest`

Permite el uso de huellas digitales SHA256 en los nombres de los activos. Está activado por defecto (`true`).

#### `config.assets.debug`

Deshabilita la concatenación y compresión de activos. Está activado por defecto en `development.rb` (`true`).

#### `config.assets.version`

Es una cadena de opción que se utiliza en la generación de hash SHA256. Esto se puede cambiar para forzar la recompilación de todos los archivos.

#### `config.assets.compile`

Es un booleano que se puede utilizar para activar la compilación en vivo de Sprockets en producción.

#### `config.assets.logger`

Acepta un registrador que cumple con la interfaz de Log4r o la clase `Logger` predeterminada de Ruby. Por defecto es el mismo configurado en `config.logger`. Establecer `config.assets.logger` en `false` desactivará el registro de los activos servidos.

#### `config.assets.quiet`

Deshabilita el registro de las solicitudes de activos. Está activado por defecto en `development.rb` (`true`).

### Configuración de Generadores

Rails te permite modificar qué generadores se utilizan con el método `config.generators`. Este método toma un bloque:

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

El conjunto completo de métodos que se pueden utilizar en este bloque son los siguientes:

* `force_plural` permite nombres de modelos en plural. Por defecto es `false`.
* `helper` define si se generan o no helpers. Por defecto es `true`.
* `integration_tool` define qué herramienta de integración se utiliza para generar pruebas de integración. Por defecto es `:test_unit`.
* `system_tests` define qué herramienta de integración se utiliza para generar pruebas de sistema. Por defecto es `:test_unit`.
* `orm` define qué ORM se utiliza. Por defecto es `false` y utilizará Active Record por defecto.
* `resource_controller` define qué generador se utiliza para generar un controlador al utilizar `bin/rails generate resource`. Por defecto es `:controller`.
* `resource_route` define si se debe generar o no una definición de ruta de recurso. Por defecto es `true`.
* `scaffold_controller` a diferencia de `resource_controller`, define qué generador se utiliza para generar un controlador _scaffolded_ al utilizar `bin/rails generate scaffold`. Por defecto es `:scaffold_controller`.
* `test_framework` define qué framework de pruebas se utiliza. Por defecto es `false` y utilizará minitest por defecto.
* `template_engine` define qué motor de plantillas se utiliza, como ERB o Haml. Por defecto es `:erb`.

### Configuración de Middleware

Cada aplicación de Rails viene con un conjunto estándar de middleware que se utiliza en este orden en el entorno de desarrollo:

#### `ActionDispatch::HostAuthorization`

Protege contra ataques de rebinding DNS y otros ataques de encabezado `Host`.
Se incluye en el entorno de desarrollo de forma predeterminada con la siguiente configuración:

```ruby
Rails.application.config.hosts = [
  IPAddr.new("0.0.0.0/0"),        # Todas las direcciones IPv4.
  IPAddr.new("::/0"),             # Todas las direcciones IPv6.
  "localhost",                    # El dominio reservado localhost.
  ENV["RAILS_DEVELOPMENT_HOSTS"]  # Hosts adicionales separados por comas para desarrollo.
]
```
En otros entornos, `Rails.application.config.hosts` está vacío y no se realizarán comprobaciones de encabezado `Host`. Si desea protegerse contra ataques de encabezado en producción, debe permitir manualmente los hosts permitidos con:

```ruby
Rails.application.config.hosts << "product.com"
```

El host de una solicitud se verifica con las entradas de `hosts` utilizando el operador de caso (`#===`), lo que permite que `hosts` admita entradas de tipo `Regexp`, `Proc` e `IPAddr`, entre otros. Aquí hay un ejemplo con una expresión regular.

```ruby
# Permitir solicitudes desde subdominios como `www.product.com` y
# `beta1.product.com`.
Rails.application.config.hosts << /.*\.product\.com/
```

La expresión regular proporcionada se envolverá con ambos anclajes (`\A` y `\z`), por lo que debe coincidir con todo el nombre de host. `/product.com/`, por ejemplo, una vez anclado, no coincidiría con `www.product.com`.

Se admite un caso especial que le permite permitir todos los subdominios:

```ruby
# Permitir solicitudes desde subdominios como `www.product.com` y
# `beta1.product.com`.
Rails.application.config.hosts << ".product.com"
```

Puede excluir ciertas solicitudes de las comprobaciones de autorización de host configurando `config.host_authorization.exclude`:

```ruby
# Excluir solicitudes para la ruta /healthcheck/ de la comprobación de host
Rails.application.config.host_authorization = {
  exclude: ->(request) { request.path.include?('healthcheck') }
}
```

Cuando una solicitud llega a un host no autorizado, se ejecutará una aplicación Rack predeterminada y responderá con `403 Forbidden`. Esto se puede personalizar configurando `config.host_authorization.response_app`. Por ejemplo:

```ruby
Rails.application.config.host_authorization = {
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

#### `ActionDispatch::ServerTiming`

Agrega métricas al encabezado `Server-Timing` para verlas en las herramientas de desarrollo de un navegador.

#### `ActionDispatch::SSL`

Obliga a que cada solicitud se sirva utilizando HTTPS. Se habilita si `config.force_ssl` está configurado como `true`. Las opciones pasadas a esto se pueden configurar estableciendo `config.ssl_options`.

#### `ActionDispatch::Static`

Se utiliza para servir activos estáticos. Deshabilitado si `config.public_file_server.enabled` es `false`. Establezca `config.public_file_server.index_name` si necesita servir un archivo de índice de directorio estático que no se llame `index`. Por ejemplo, para servir `main.html` en lugar de `index.html` para solicitudes de directorio, establezca `config.public_file_server.index_name` en `"main"`.

#### `ActionDispatch::Executor`

Permite la recarga de código segura para subprocesos. Deshabilitado si `config.allow_concurrency` es `false`, lo que hace que se cargue `Rack::Lock`. `Rack::Lock` envuelve la aplicación en un mutex para que solo pueda ser llamada por un solo hilo a la vez.

#### `ActiveSupport::Cache::Strategy::LocalCache`

Sirve como una caché básica respaldada en memoria. Esta caché no es segura para subprocesos y está destinada únicamente a servir como una caché de memoria temporal para un solo hilo.

#### `Rack::Runtime`

Establece un encabezado `X-Runtime` que contiene el tiempo (en segundos) que tarda en ejecutarse la solicitud.

#### `Rails::Rack::Logger`

Notifica a los registros que la solicitud ha comenzado. Después de que se completa la solicitud, se vacían todos los registros.

#### `ActionDispatch::ShowExceptions`

Rescata cualquier excepción devuelta por la aplicación y muestra páginas de excepción agradables si la solicitud es local o si `config.consider_all_requests_local` está configurado como `true`. Si `config.action_dispatch.show_exceptions` se establece en `:none`, las excepciones se generarán de todos modos.

#### `ActionDispatch::RequestId`

Hace que un encabezado X-Request-Id único esté disponible en la respuesta y habilita el método `ActionDispatch::Request#uuid`. Configurable con `config.action_dispatch.request_id_header`.

#### `ActionDispatch::RemoteIp`

Verifica ataques de suplantación de IP y obtiene la `client_ip` válida de los encabezados de la solicitud. Configurable con las opciones `config.action_dispatch.ip_spoofing_check` y `config.action_dispatch.trusted_proxies`.

#### `Rack::Sendfile`

Intercepta las respuestas cuyo cuerpo se sirve desde un archivo y lo reemplaza con un encabezado X-Sendfile específico del servidor. Configurable con `config.action_dispatch.x_sendfile_header`.
#### `ActionDispatch::Callbacks`

Ejecuta los callbacks de preparación antes de servir la solicitud.

#### `ActionDispatch::Cookies`

Establece cookies para la solicitud.

#### `ActionDispatch::Session::CookieStore`

Es responsable de almacenar la sesión en cookies. Se puede utilizar un middleware alternativo para esto cambiando [`config.session_store`](#config-session-store).

#### `ActionDispatch::Flash`

Configura las claves `flash`. Solo está disponible si [`config.session_store`](#config-session-store) se establece en un valor.

#### `Rack::MethodOverride`

Permite que el método se anule si `params[:_method]` está configurado. Este es el middleware que admite los tipos de método HTTP PATCH, PUT y DELETE.

#### `Rack::Head`

Convierte las solicitudes HEAD en solicitudes GET y las sirve como tal.

#### Agregar middleware personalizado

Además de estos middlewares habituales, puedes agregar los tuyos propios utilizando el método `config.middleware.use`:

```ruby
config.middleware.use Magical::Unicorns
```

Esto colocará el middleware `Magical::Unicorns` al final de la pila. Puedes usar `insert_before` si deseas agregar un middleware antes de otro.

```ruby
config.middleware.insert_before Rack::Head, Magical::Unicorns
```

O puedes insertar un middleware en una posición exacta utilizando índices. Por ejemplo, si deseas insertar el middleware `Magical::Unicorns` en la parte superior de la pila, puedes hacerlo de la siguiente manera:

```ruby
config.middleware.insert_before 0, Magical::Unicorns
```

También existe `insert_after`, que insertará un middleware después de otro:

```ruby
config.middleware.insert_after Rack::Head, Magical::Unicorns
```

Los middlewares también se pueden reemplazar por completo con otros:

```ruby
config.middleware.swap ActionController::Failsafe, Lifo::Failsafe
```

Los middlewares se pueden mover de un lugar a otro:

```ruby
config.middleware.move_before ActionDispatch::Flash, Magical::Unicorns
```

Esto moverá el middleware `Magical::Unicorns` antes de `ActionDispatch::Flash`. También puedes moverlo después:

```ruby
config.middleware.move_after ActionDispatch::Flash, Magical::Unicorns
```

También se pueden eliminar por completo de la pila:

```ruby
config.middleware.delete Rack::MethodOverride
```

### Configuración de i18n

Todas estas opciones de configuración se delegan a la biblioteca `I18n`.

#### `config.i18n.available_locales`

Define los locales disponibles permitidos para la aplicación. Por defecto, incluye todas las claves de locales encontradas en los archivos de locales, generalmente solo `:en` en una nueva aplicación.

#### `config.i18n.default_locale`

Establece el locale predeterminado de una aplicación utilizado para i18n. Por defecto, es `:en`.

#### `config.i18n.enforce_available_locales`

Asegura que todos los locales pasados a través de i18n deben declararse en la lista `available_locales`, generando una excepción `I18n::InvalidLocale` al establecer un locale no disponible. Por defecto, es `true`. Se recomienda no deshabilitar esta opción a menos que sea estrictamente necesario, ya que funciona como una medida de seguridad contra la configuración de cualquier locale no válido desde la entrada del usuario.

#### `config.i18n.load_path`

Establece la ruta que Rails utiliza para buscar archivos de locales. Por defecto, es `config/locales/**/*.{yml,rb}`.

#### `config.i18n.raise_on_missing_translations`

Determina si se debe generar un error por las traducciones faltantes. Por defecto, esto es `false`.

#### `config.i18n.fallbacks`

Establece el comportamiento de fallback para las traducciones faltantes. Aquí hay 3 ejemplos de uso para esta opción:

  * Puedes configurar la opción en `true` para usar el locale predeterminado como fallback, de la siguiente manera:

    ```ruby
    config.i18n.fallbacks = true
    ```

  * O puedes configurar un array de locales como fallback, de la siguiente manera:

    ```ruby
    config.i18n.fallbacks = [:tr, :en]
    ```

  * O puedes configurar diferentes fallbacks para los locales individualmente. Por ejemplo, si deseas usar `:tr` como fallback para `:az` y `:de`, y `:en` para `:da`, puedes hacerlo de la siguiente manera:

    ```ruby
    config.i18n.fallbacks = { az: :tr, da: [:de, :en] }
    #o
    config.i18n.fallbacks.map = { az: :tr, da: [:de, :en] }
    ```
### Configurando Active Model

#### `config.active_model.i18n_customize_full_message`

Controla si se puede sobrescribir el formato [`Error#full_message`][ActiveModel::Error#full_message] en un archivo de localización i18n. El valor predeterminado es `false`.

Cuando se establece en `true`, `full_message` buscará un formato en el atributo y en el nivel del modelo de los archivos de localización. El formato predeterminado es `"%{attribute} %{message}"`, donde `attribute` es el nombre del atributo y `message` es el mensaje específico de validación. El siguiente ejemplo sobrescribe el formato para todos los atributos de `Person`, así como el formato para un atributo específico de `Person` (`age`).

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :age

  validates :name, :age, presence: true
end
```

```yml
en:
  activemodel: # o activerecord:
    errors:
      models:
        person:
          # Sobrescribe el formato para todos los atributos de Person:
          format: "Invalid %{attribute} (%{message})"
          attributes:
            age:
              # Sobrescribe el formato para el atributo age:
              format: "%{message}"
              blank: "Por favor complete su %{attribute}"
```

```irb
irb> person = Person.new.tap(&:valid?)

irb> person.errors.full_messages
=> [
  "Invalid Name (no puede estar en blanco)",
  "Por favor complete su Age"
]

irb> person.errors.messages
=> {
  :name => ["no puede estar en blanco"],
  :age  => ["Por favor complete su Age"]
}
```


### Configurando Active Record

`config.active_record` incluye una variedad de opciones de configuración:

#### `config.active_record.logger`

Acepta un registrador que cumple con la interfaz de Log4r o la clase de registro predeterminada de Ruby, que luego se pasa a cualquier nueva conexión de base de datos realizada. Puede recuperar este registrador llamando a `logger` en una clase de modelo de Active Record o en una instancia de modelo de Active Record. Establezca en `nil` para deshabilitar el registro.

#### `config.active_record.primary_key_prefix_type`

Le permite ajustar la nomenclatura de las columnas de clave primaria. De forma predeterminada, Rails asume que las columnas de clave primaria se llaman `id` (y esta opción de configuración no necesita establecerse). Hay otras dos opciones:

* `:table_name` haría que la clave primaria para la clase Customer sea `customerid`.
* `:table_name_with_underscore` haría que la clave primaria para la clase Customer sea `customer_id`.

#### `config.active_record.table_name_prefix`

Le permite establecer una cadena global que se antepondrá a los nombres de tabla. Si establece esto en `northwest_`, entonces la clase Customer buscará `northwest_customers` como su tabla. El valor predeterminado es una cadena vacía.

#### `config.active_record.table_name_suffix`

Le permite establecer una cadena global que se agregará a los nombres de tabla. Si establece esto en `_northwest`, entonces la clase Customer buscará `customers_northwest` como su tabla. El valor predeterminado es una cadena vacía.

#### `config.active_record.schema_migrations_table_name`

Le permite establecer una cadena que se utilizará como el nombre de la tabla de migraciones de esquema.

#### `config.active_record.internal_metadata_table_name`

Le permite establecer una cadena que se utilizará como el nombre de la tabla de metadatos internos.

#### `config.active_record.protected_environments`

Le permite establecer una matriz de nombres de entornos donde se deben prohibir las acciones destructivas.

#### `config.active_record.pluralize_table_names`

Especifica si Rails buscará nombres de tabla en singular o en plural en la base de datos. Si se establece en `true` (el valor predeterminado), entonces la clase Customer utilizará la tabla `customers`. Si se establece en `false`, entonces la clase Customer utilizará la tabla `customer`.

#### `config.active_record.default_timezone`

Determina si se utilizará `Time.local` (si se establece en `:local`) o `Time.utc` (si se establece en `:utc`) al extraer fechas y horas de la base de datos. El valor predeterminado es `:utc`.
#### `config.active_record.schema_format`

Controla el formato para volcar el esquema de la base de datos a un archivo. Las opciones son `:ruby` (el valor predeterminado) para una versión independiente de la base de datos que depende de las migraciones, o `:sql` para un conjunto de declaraciones SQL (potencialmente dependientes de la base de datos).

#### `config.active_record.error_on_ignored_order`

Especifica si se debe generar un error si se ignora el orden de una consulta durante una consulta por lotes. Las opciones son `true` (generar error) o `false` (advertir). El valor predeterminado es `false`.

#### `config.active_record.timestamped_migrations`

Controla si las migraciones se numeran con enteros seriales o con marcas de tiempo. El valor predeterminado es `true`, para usar marcas de tiempo, que son preferibles si hay varios desarrolladores trabajando en la misma aplicación.

#### `config.active_record.db_warnings_action`

Controla la acción a tomar cuando una consulta SQL produce una advertencia. Las siguientes opciones están disponibles:

  * `:ignore` - Las advertencias de la base de datos se ignorarán. Este es el valor predeterminado.

  * `:log` - Las advertencias de la base de datos se registrarán a través de `ActiveRecord.logger` en el nivel `:warn`.

  * `:raise` - Las advertencias de la base de datos se generarán como `ActiveRecord::SQLWarning`.

  * `:report` - Las advertencias de la base de datos se informarán a los suscriptores del informe de errores de Rails.

  * Proc personalizado - Se puede proporcionar un proc personalizado. Debe aceptar un objeto de error `SQLWarning`.

    Por ejemplo:

    ```ruby
    config.active_record.db_warnings_action = ->(warning) do
      # Informar a un servicio personalizado de informe de excepciones
      Bugsnag.notify(warning.message) do |notification|
        notification.add_metadata(:warning_code, warning.code)
        notification.add_metadata(:warning_level, warning.level)
      end
    end
    ```

#### `config.active_record.db_warnings_ignore`

Especifica una lista blanca de códigos y mensajes de advertencia que se ignorarán, independientemente de la `db_warnings_action` configurada. El comportamiento predeterminado es informar todas las advertencias. Las advertencias a ignorar se pueden especificar como cadenas o expresiones regulares. Por ejemplo:

  ```ruby
  config.active_record.db_warnings_action = :raise
  # Las siguientes advertencias no se generarán
  config.active_record.db_warnings_ignore = [
    /Invalid utf8mb4 character string/,
    "Un mensaje de advertencia exacto",
    "1062", # Error 1062 de MySQL: entrada duplicada
  ]
  ```

#### `config.active_record.migration_strategy`

Controla la clase de estrategia utilizada para realizar métodos de declaración de esquema en una migración. La clase predeterminada
delega en el adaptador de conexión. Las estrategias personalizadas deben heredar de `ActiveRecord::Migration::ExecutionStrategy`,
o pueden heredar de `DefaultStrategy`, que conservará el comportamiento predeterminado para los métodos que no están implementados:

```ruby
class CustomMigrationStrategy < ActiveRecord::Migration::DefaultStrategy
  def drop_table(*)
    raise "¡No se admite eliminar tablas!"
  end
end

config.active_record.migration_strategy = CustomMigrationStrategy
```

#### `config.active_record.lock_optimistically`

Controla si Active Record utilizará bloqueo optimista y es `true` de forma predeterminada.

#### `config.active_record.cache_timestamp_format`

Controla el formato del valor de marca de tiempo en la clave de caché. El valor predeterminado es `:usec`.

#### `config.active_record.record_timestamps`

Es un valor booleano que controla si se realizan o no marcas de tiempo en las operaciones de `create` y `update` en un modelo. El valor predeterminado es `true`.

#### `config.active_record.partial_inserts`

Es un valor booleano y controla si se utilizan o no escrituras parciales al crear nuevos registros (es decir, si las inserciones solo establecen atributos que son diferentes al valor predeterminado).

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `true`                    |
| 7.0                   | `false`                   |

#### `config.active_record.partial_updates`

Es un valor booleano y controla si se utilizan o no escrituras parciales al actualizar registros existentes (es decir, si las actualizaciones solo establecen atributos que están sucios). Tenga en cuenta que al utilizar actualizaciones parciales, también debe utilizar bloqueo optimista `config.active_record.lock_optimistically`, ya que las actualizaciones concurrentes pueden escribir atributos basados en un estado de lectura posiblemente obsoleto. El valor predeterminado es `true`.
#### `config.active_record.maintain_test_schema`

Es un valor booleano que controla si Active Record debe intentar mantener actualizado el esquema de la base de datos de pruebas con `db/schema.rb` (o `db/structure.sql`) cuando se ejecutan las pruebas. El valor predeterminado es `true`.

#### `config.active_record.dump_schema_after_migration`

Es una bandera que controla si se debe realizar un volcado del esquema (`db/schema.rb` o `db/structure.sql`) cuando se ejecutan las migraciones. Esto se establece en `false` en `config/environments/production.rb` que es generado por Rails. El valor predeterminado es `true` si esta configuración no está establecida.

#### `config.active_record.dump_schemas`

Controla qué esquemas de base de datos se volcarán al llamar a `db:schema:dump`. Las opciones son `:schema_search_path` (el valor predeterminado) que vuelca cualquier esquema listado en `schema_search_path`, `:all` que siempre vuelca todos los esquemas independientemente de `schema_search_path`, o una cadena de esquemas separados por comas.

#### `config.active_record.before_committed_on_all_records`

Habilita los callbacks before_committed! en todos los registros inscritos en una transacción. El comportamiento anterior era ejecutar los callbacks solo en la primera copia de un registro si había múltiples copias del mismo registro inscritas en la transacción.

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.belongs_to_required_by_default`

Es un valor booleano que controla si un registro falla en la validación si la asociación `belongs_to` no está presente.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `nil`                |
| 5.0                   | `true`               |

#### `config.active_record.belongs_to_required_validates_foreign_key`

Habilita la validación solo de las columnas relacionadas con el padre para verificar su presencia cuando el padre es obligatorio. El comportamiento anterior era validar la presencia del registro padre, lo que realizaba una consulta adicional para obtener el padre cada vez que se actualizaba el registro hijo, incluso cuando el padre no había cambiado.

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.marshalling_format_version`

Cuando se establece en `7.1`, habilita una serialización más eficiente de una instancia de Active Record con `Marshal.dump`.

Esto cambia el formato de serialización, por lo que los modelos serializados de esta manera no pueden ser leídos por versiones anteriores (< 7.1) de Rails. Sin embargo, los mensajes que utilizan el formato antiguo aún se pueden leer, independientemente de si se habilita esta optimización.

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `6.1`                |
| 7.1                   | `7.1`                |

#### `config.active_record.action_on_strict_loading_violation`

Permite lanzar o registrar una excepción si se establece strict_loading en una asociación. El valor predeterminado es `:raise` en todos los entornos. Se puede cambiar a `:log` para enviar las violaciones al registro en lugar de lanzar una excepción.

#### `config.active_record.strict_loading_by_default`

Es un valor booleano que habilita o deshabilita el modo strict_loading de forma predeterminada. El valor predeterminado es `false`.

#### `config.active_record.warn_on_records_fetched_greater_than`

Permite establecer un umbral de advertencia para el tamaño del resultado de una consulta. Si el número de registros devueltos por una consulta supera el umbral, se registra una advertencia. Esto se puede utilizar para identificar consultas que podrían estar causando un aumento de memoria.

#### `config.active_record.index_nested_attribute_errors`

Permite mostrar errores para relaciones `has_many` anidadas con un índice además del error. El valor predeterminado es `false`.
#### `config.active_record.use_schema_cache_dump`

Permite a los usuarios obtener información de la caché del esquema desde `db/schema_cache.yml` (generado por `bin/rails db:schema:cache:dump`), en lugar de tener que enviar una consulta a la base de datos para obtener esta información. El valor predeterminado es `true`.

#### `config.active_record.cache_versioning`

Indica si se debe utilizar un método `#cache_key` estable que esté acompañado por una versión cambiante en el método `#cache_version`.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 5.2                   | `true`               |

#### `config.active_record.collection_cache_versioning`

Permite reutilizar la misma clave de caché cuando el objeto que se está almacenando en caché de tipo `ActiveRecord::Relation` cambia moviendo la información volátil (máximo actualizado y recuento) de la clave de caché de la relación hacia la versión de caché para admitir la reutilización de la clave de caché.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 6.0                   | `true`               |

#### `config.active_record.has_many_inversing`

Permite establecer el registro inverso al atravesar las asociaciones de `belongs_to` a `has_many`.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 6.1                   | `true`               |

#### `config.active_record.automatic_scope_inversing`

Permite inferir automáticamente `inverse_of` para las asociaciones con un ámbito.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.0                   | `true`               |

#### `config.active_record.destroy_association_async_job`

Permite especificar el trabajo que se utilizará para destruir los registros asociados en segundo plano. El valor predeterminado es `ActiveRecord::DestroyAssociationAsyncJob`.

#### `config.active_record.destroy_association_async_batch_size`

Permite especificar el número máximo de registros que se destruirán en un trabajo en segundo plano mediante la opción de asociación `dependent: :destroy_async`. Si todo lo demás es igual, un tamaño de lote más bajo encolará más trabajos en segundo plano de menor duración, mientras que un tamaño de lote más alto encolará menos trabajos en segundo plano de mayor duración. Este opción tiene un valor predeterminado de `nil`, lo que hará que todos los registros dependientes de una asociación determinada se destruyan en el mismo trabajo en segundo plano.

#### `config.active_record.queues.destroy`

Permite especificar la cola de Active Job que se utilizará para los trabajos de destrucción. Cuando esta opción es `nil`, los trabajos de purga se envían a la cola de Active Job predeterminada (consulte `config.active_job.default_queue_name`). El valor predeterminado es `nil`.

#### `config.active_record.enumerate_columns_in_select_statements`

Cuando es `true`, siempre se incluirán los nombres de las columnas en las declaraciones `SELECT` y se evitarán las consultas de tipo `SELECT * FROM ...`. Esto evita errores en la caché de declaraciones preparadas al agregar columnas a una base de datos PostgreSQL, por ejemplo. El valor predeterminado es `false`.

#### `config.active_record.verify_foreign_keys_for_fixtures`

Asegura que todas las restricciones de clave externa sean válidas después de cargar los fixtures en las pruebas. Compatible solo con PostgreSQL y SQLite.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.0                   | `true`               |

#### `config.active_record.raise_on_assign_to_attr_readonly`

Permite generar una excepción al asignar atributos `attr_readonly`. El comportamiento anterior permitía la asignación pero no persistía los cambios en la base de datos.

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.1                   | `true`               |
#### `config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`

Cuando varias instancias de Active Record cambian el mismo registro dentro de una transacción, Rails ejecuta los callbacks `after_commit` o `after_rollback` solo para una de ellas. Esta opción especifica cómo Rails elige qué instancia recibe los callbacks.

Cuando es `true`, los callbacks transaccionales se ejecutan en la primera instancia que se guarda, aunque su estado de instancia pueda estar desactualizado.

Cuando es `false`, los callbacks transaccionales se ejecutan en las instancias con el estado de instancia más actualizado. Estas instancias se eligen de la siguiente manera:

- En general, se ejecutan los callbacks transaccionales en la última instancia que guarda un registro dado dentro de la transacción.
- Hay dos excepciones:
    - Si el registro se crea dentro de la transacción y luego se actualiza por otra instancia, los callbacks `after_create_commit` se ejecutarán en la segunda instancia. Esto es en lugar de los callbacks `after_update_commit` que se ejecutarían ingenuamente según el estado de esa instancia.
    - Si el registro se destruye dentro de la transacción, los callbacks `after_destroy_commit` se ejecutarán en la última instancia destruida, incluso si una instancia desactualizada realiza posteriormente una actualización (que no habrá afectado a ninguna fila).

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `true`                    |
| 7.1                   | `false`                   |

#### `config.active_record.default_column_serializer`

La implementación del serializador que se utilizará si no se especifica explícitamente para una columna determinada.

Históricamente, `serialize` y `store`, aunque permiten el uso de implementaciones de serializador alternativas, utilizarían `YAML` de forma predeterminada, pero no es un formato muy eficiente y puede ser fuente de vulnerabilidades de seguridad si no se utiliza con cuidado.

Por lo tanto, se recomienda preferir formatos más estrictos y limitados para la serialización de bases de datos.

Desafortunadamente, no hay realmente ninguna opción predeterminada adecuada disponible en la biblioteca estándar de Ruby. `JSON` podría funcionar como formato, pero las gemas `json` convertirán los tipos no admitidos en cadenas, lo que puede provocar errores.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `YAML`                    |
| 7.1                   | `nil`                     |

#### `config.active_record.run_after_transaction_callbacks_in_order_defined`

Si es `true`, los callbacks `after_commit` se ejecutan en el orden en que se definen en un modelo. Si es `false`, se ejecutan en orden inverso.

Todos los demás callbacks siempre se ejecutan en el orden en que se definen en un modelo (a menos que se use `prepend: true`).

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `false`                   |
| 7.1                   | `true`                    |

#### `config.active_record.query_log_tags_enabled`

Especifica si habilitar o no los comentarios de consulta a nivel de adaptador. El valor predeterminado es `false`.

NOTA: Cuando se establece en `true`, las sentencias preparadas de la base de datos se desactivarán automáticamente.

#### `config.active_record.query_log_tags`

Define una `Array` que especifica las etiquetas clave/valor que se insertarán en un comentario SQL. El valor predeterminado es `[ :application ]`, una etiqueta predefinida que devuelve el nombre de la aplicación.

#### `config.active_record.query_log_tags_format`

Un `Symbol` que especifica el formateador a utilizar para las etiquetas. Los valores válidos son `:sqlcommenter` y `:legacy`.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:
| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `:legacy`            |
| 7.1                   | `:sqlcommenter`      |

#### `config.active_record.cache_query_log_tags`

Especifica si se debe habilitar o no el almacenamiento en caché de las etiquetas de registro de consultas. Para aplicaciones que tienen un gran número de consultas, el almacenamiento en caché de las etiquetas de registro de consultas puede proporcionar un beneficio de rendimiento cuando el contexto no cambia durante la vida útil de la solicitud o la ejecución del trabajo. El valor predeterminado es `false`.

#### `config.active_record.schema_cache_ignored_tables`

Define la lista de tablas que se deben ignorar al generar la caché del esquema. Acepta una `Array` de cadenas que representan los nombres de las tablas o expresiones regulares.

#### `config.active_record.verbose_query_logs`

Especifica si se deben registrar las ubicaciones de origen de los métodos que llaman a consultas de base de datos debajo de las consultas relevantes. De forma predeterminada, el indicador es `true` en desarrollo y `false` en todos los demás entornos.

#### `config.active_record.sqlite3_adapter_strict_strings_by_default`

Especifica si se debe utilizar el adaptador SQLite3 en un modo de cadenas estrictas. El uso de un modo de cadenas estrictas deshabilita las literales de cadena entre comillas dobles.

SQLite tiene algunas peculiaridades en torno a las literales de cadena entre comillas dobles. Primero intenta considerar las cadenas entre comillas dobles como nombres de identificadores, pero si no existen, entonces las considera como literales de cadena. Debido a esto, los errores tipográficos pueden pasar desapercibidos. Por ejemplo, es posible crear un índice para una columna que no existe. Consulte la [documentación de SQLite](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted) para obtener más detalles.

El valor predeterminado depende de la versión objetivo `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.async_query_executor`

Especifica cómo se agrupan las consultas asíncronas.

De forma predeterminada, es `nil`, lo que significa que `load_async` está deshabilitado y, en su lugar, las consultas se ejecutan directamente en primer plano. Para que las consultas se realicen de forma asíncrona, debe establecerse en `:global_thread_pool` o `:multi_thread_pool`.

`:global_thread_pool` utilizará un único grupo para todas las bases de datos a las que se conecta la aplicación. Esta es la configuración preferida para aplicaciones con una sola base de datos o aplicaciones que solo consultan una sola fragmentación de base de datos a la vez.

`:multi_thread_pool` utilizará un grupo por base de datos, y el tamaño de cada grupo se puede configurar individualmente en `database.yml` a través de las propiedades `max_threads` y `min_thread`. Esto puede ser útil para aplicaciones que consultan regularmente múltiples bases de datos al mismo tiempo y que necesitan definir de manera más precisa la concurrencia máxima.

#### `config.active_record.global_executor_concurrency`

Se utiliza en conjunto con `config.active_record.async_query_executor = :global_thread_pool` y define cuántas consultas asíncronas se pueden ejecutar simultáneamente.

El valor predeterminado es `4`.

Este número debe considerarse en relación con el tamaño del grupo de conexiones configurado en `database.yml`. El grupo de conexiones debe ser lo suficientemente grande como para acomodar tanto los hilos en primer plano (por ejemplo, hilos del servidor web o del trabajador de tareas) como los hilos en segundo plano.

#### `config.active_record.allow_deprecated_singular_associations_name`

Esto habilita el comportamiento obsoleto en el que las asociaciones singulares se pueden referir por su nombre en plural en las cláusulas `where`. Establecer esto en `false` es más eficiente.

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end

Comment.where(post: post_id).count  # => 5

# Cuando `allow_deprecated_singular_associations_name` es true:
Comment.where(posts: post_id).count # => 5 (advertencia de obsolescencia)

# Cuando `allow_deprecated_singular_associations_name` es false:
Comment.where(posts: post_id).count # => error
```

El valor predeterminado depende de la versión objetivo `config.load_defaults`:
| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.yaml_column_permitted_classes`

El valor predeterminado es `[Symbol]`. Permite a las aplicaciones incluir clases permitidas adicionales en `safe_load()` en `ActiveRecord::Coders::YAMLColumn`.

#### `config.active_record.use_yaml_unsafe_load`

El valor predeterminado es `false`. Permite a las aplicaciones optar por utilizar `unsafe_load` en `ActiveRecord::Coders::YAMLColumn`.

#### `config.active_record.raise_int_wider_than_64bit`

El valor predeterminado es `true`. Determina si se debe generar una excepción o no cuando el adaptador de PostgreSQL recibe un entero más ancho que la representación de 64 bits con signo.

#### `ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans` y `ActiveRecord::ConnectionAdapters::TrilogyAdapter.emulate_booleans`

Controla si el adaptador de MySQL de Active Record considerará todas las columnas `tinyint(1)` como booleanas. El valor predeterminado es `true`.

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.create_unlogged_tables`

Controla si las tablas de la base de datos creadas por PostgreSQL deben ser "sin registro", lo que puede acelerar el rendimiento pero aumenta el riesgo de pérdida de datos si la base de datos se bloquea. Se recomienda encarecidamente no habilitar esto en un entorno de producción. El valor predeterminado es `false` en todos los entornos.

Para habilitarlo en las pruebas:

```ruby
# config/environments/test.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.create_unlogged_tables = true
end
```

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type`

Controla qué tipo nativo debe usar el adaptador de PostgreSQL de Active Record cuando se llama a `datetime` en una migración o esquema. Toma un símbolo que debe corresponder a uno de los `NATIVE_DATABASE_TYPES` configurados. El valor predeterminado es `:timestamp`, lo que significa que `t.datetime` en una migración creará una columna "timestamp without time zone".

Para usar "timestamp with time zone":

```ruby
# config/application.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.datetime_type = :timestamptz
end
```

Debes ejecutar `bin/rails db:migrate` para reconstruir tu schema.rb si cambias esto.

#### `ActiveRecord::SchemaDumper.ignore_tables`

Acepta una matriz de tablas que _no_ deben incluirse en ningún archivo de esquema generado.

#### `ActiveRecord::SchemaDumper.fk_ignore_pattern`

Permite establecer una expresión regular diferente que se utilizará para decidir si el nombre de una clave externa debe incluirse o no en db/schema.rb. De forma predeterminada, los nombres de las claves externas que comienzan con `fk_rails_` no se exportan al volcado del esquema de la base de datos. El valor predeterminado es `/^fk_rails_[0-9a-f]{10}$/`.

#### `config.active_record.encryption.hash_digest_class`

Establece el algoritmo de resumen utilizado por Active Record Encryption.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es      |
|-----------------------|---------------------------|
| (original)            | `OpenSSL::Digest::SHA1`   |
| 7.1                   | `OpenSSL::Digest::SHA256` |

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

Permite admitir el descifrado de datos existentes cifrados utilizando una clase de resumen SHA-1. Cuando es `false`, solo admitirá el resumen configurado en `config.active_record.encryption.hash_digest_class`.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
|-----------------------|----------------------|
| (original)            | `true`               |
| 7.1                   | `false`              |

### Configurando Action Controller

`config.action_controller` incluye varias configuraciones:

#### `config.action_controller.asset_host`

Establece el host para los activos. Útil cuando se utilizan CDN para alojar activos en lugar del propio servidor de la aplicación. Solo debes usar esto si tienes una configuración diferente para Action Mailer, de lo contrario usa `config.asset_host`.

#### `config.action_controller.perform_caching`

Configura si la aplicación debe realizar las funciones de almacenamiento en caché proporcionadas por el componente Action Controller o no. Establecido en `false` en el entorno de desarrollo, `true` en producción. Si no se especifica, el valor predeterminado será `true`.

#### `config.action_controller.default_static_extension`

Configura la extensión utilizada para las páginas en caché. El valor predeterminado es `.html`.
#### `config.action_controller.include_all_helpers`

Configura si todos los ayudantes de vista están disponibles en todas partes o están limitados al controlador correspondiente. Si se establece en `false`, los métodos de `UsersHelper` solo están disponibles para las vistas renderizadas como parte de `UsersController`. Si es `true`, los métodos de `UsersHelper` están disponibles en todas partes. El comportamiento de configuración predeterminado (cuando esta opción no se establece explícitamente en `true` o `false`) es que todos los ayudantes de vista están disponibles para cada controlador.

#### `config.action_controller.logger`

Acepta un registrador que cumple con la interfaz de Log4r o la clase de registro predeterminada de Ruby, que luego se utiliza para registrar información desde Action Controller. Establecer en `nil` para deshabilitar el registro.

#### `config.action_controller.request_forgery_protection_token`

Establece el nombre del parámetro de token para RequestForgery. Llamar a `protect_from_forgery` lo establece en `:authenticity_token` de forma predeterminada.

#### `config.action_controller.allow_forgery_protection`

Habilita o deshabilita la protección CSRF. De forma predeterminada, esto es `false` en el entorno de prueba y `true` en todos los demás entornos.

#### `config.action_controller.forgery_protection_origin_check`

Configura si se debe verificar el encabezado HTTP `Origin` contra el origen del sitio como una defensa CSRF adicional.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 5.0                   | `true`               |

#### `config.action_controller.per_form_csrf_tokens`

Configura si los tokens CSRF solo son válidos para el método/acción para el que se generaron.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 5.0                   | `true`               |

#### `config.action_controller.default_protect_from_forgery`

Determina si se agrega protección contra falsificación en `ActionController::Base`.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 5.2                   | `true`               |

#### `config.action_controller.relative_url_root`

Se puede usar para indicar a Rails que se está [implementando en un subdirectorio](
configuring.html#deploy-to-a-subdirectory-relative-url-root). El valor predeterminado es
[`config.relative_url_root`](#config-relative-url-root).

#### `config.action_controller.permit_all_parameters`

Establece que todos los parámetros para la asignación masiva están permitidos de forma predeterminada. El valor predeterminado es `false`.

#### `config.action_controller.action_on_unpermitted_parameters`

Controla el comportamiento cuando se encuentran parámetros que no están permitidos explícitamente. El valor predeterminado es `:log` en los entornos de prueba y desarrollo, `false` en otros casos. Los valores pueden ser:

* `false` para no tomar ninguna acción
* `:log` para emitir un evento `ActiveSupport::Notifications.instrument` en el tema `unpermitted_parameters.action_controller` y registrar en el nivel DEBUG
* `:raise` para generar una excepción `ActionController::UnpermittedParameters`

#### `config.action_controller.always_permitted_parameters`

Establece una lista de parámetros permitidos que están permitidos de forma predeterminada. Los valores predeterminados son `['controller', 'action']`.

#### `config.action_controller.enable_fragment_cache_logging`

Determina si se registran las lecturas y escrituras de la caché de fragmentos en formato detallado de la siguiente manera:

```
Read fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/d0bdf2974e1ef6d31685c3b392ad0b74 (0.6ms)
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Write fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/3b4e249ac9d168c617e32e84b99218b5 (1.1ms)
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

De forma predeterminada, está configurado en `false`, lo que da como resultado la siguiente salida:

```
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

#### `config.action_controller.raise_on_open_redirects`

Genera un `ActionController::Redirecting::UnsafeRedirectError` cuando se produce una redirección abierta no permitida.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.0                   | `true`               |
#### `config.action_controller.log_query_tags_around_actions`

Determina si el contexto del controlador para las etiquetas de consulta se actualizará automáticamente a través de un `around_filter`. El valor predeterminado es `true`.

#### `config.action_controller.wrap_parameters_by_default`

Configura el [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html) para envolver las solicitudes json de forma predeterminada.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.0                   | `true`               |

#### `ActionController::Base.wrap_parameters`

Configura el [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html). Esto se puede llamar a nivel superior o en controladores individuales.

#### `config.action_controller.allow_deprecated_parameters_hash_equality`

Controla el comportamiento de `ActionController::Parameters#==` con argumentos `Hash`. El valor de la configuración determina si una instancia de `ActionController::Parameters` es igual a un `Hash` equivalente.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `true`               |
| 7.1                   | `false`              |

### Configuración de Action Dispatch

#### `config.action_dispatch.cookies_serializer`

Especifica qué serializador usar para las cookies. Acepta los mismos valores que [`config.active_support.message_serializer`](#config-active-support-message-serializer), más `:hybrid` que es un alias para `:json_allow_marshal`.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `:marshal`           |
| 7.0                   | `:json`              |

#### `config.action_dispatch.debug_exception_log_level`

Configura el nivel de registro utilizado por el middleware DebugExceptions al registrar excepciones no capturadas durante las solicitudes.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `:fatal`             |
| 7.1                   | `:error`             |

#### `config.action_dispatch.default_headers`

Es un hash con encabezados HTTP que se establecen de forma predeterminada en cada respuesta.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "1; mode=block",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.0                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.1                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |

#### `config.action_dispatch.default_charset`

Especifica el conjunto de caracteres predeterminado para todas las representaciones. Por defecto es `nil`.

#### `config.action_dispatch.tld_length`

Establece la longitud del dominio de nivel superior (TLD, por sus siglas en inglés) para la aplicación. Por defecto es `1`.

#### `config.action_dispatch.ignore_accept_header`

Se utiliza para determinar si se deben ignorar los encabezados de aceptación de una solicitud. Por defecto es `false`.

#### `config.action_dispatch.x_sendfile_header`

Especifica el encabezado X-Sendfile específico del servidor. Esto es útil para enviar archivos acelerados desde el servidor. Por ejemplo, se puede establecer en 'X-Sendfile' para Apache.

#### `config.action_dispatch.http_auth_salt`

Establece el valor de sal de autenticación HTTP. Por defecto es `'http authentication'`.

#### `config.action_dispatch.signed_cookie_salt`

Establece el valor de sal de las cookies firmadas. Por defecto es `'signed cookie'`.

#### `config.action_dispatch.encrypted_cookie_salt`

Establece el valor de sal de las cookies cifradas. Por defecto es `'encrypted cookie'`.

#### `config.action_dispatch.encrypted_signed_cookie_salt`

Establece el valor de sal de las cookies firmadas y cifradas. Por defecto es `'signed encrypted cookie'`.

#### `config.action_dispatch.authenticated_encrypted_cookie_salt`

Establece la sal de las cookies cifradas autenticadas. Por defecto es `'authenticated encrypted cookie'`.

#### `config.action_dispatch.encrypted_cookie_cipher`

Establece el cifrado que se utilizará para las cookies cifradas. Esto es por defecto `"aes-256-gcm"`.
#### `config.action_dispatch.signed_cookie_digest`

Establece el algoritmo de resumen que se utilizará para las cookies firmadas. Esto tiene un valor predeterminado de `"SHA1"`.

#### `config.action_dispatch.cookies_rotations`

Permite rotar secretos, cifrados y resúmenes para cookies encriptadas y firmadas.

#### `config.action_dispatch.use_authenticated_cookie_encryption`

Controla si las cookies firmadas y encriptadas utilizan el cifrado AES-256-GCM o el cifrado AES-256-CBC más antiguo.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `false`                   |
| 5.2                   | `true`                    |

#### `config.action_dispatch.use_cookies_with_metadata`

Permite escribir cookies con metadatos incrustados.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `false`                   |
| 6.0                   | `true`                    |

#### `config.action_dispatch.perform_deep_munge`

Configura si el método `deep_munge` debe realizarse en los parámetros. Consulta la [Guía de seguridad](security.html#unsafe-query-generation) para obtener más información. El valor predeterminado es `true`.

#### `config.action_dispatch.rescue_responses`

Configura qué excepciones se asignan a un código de estado HTTP. Acepta un hash y puedes especificar pares de excepción/estado. Por defecto, se define de la siguiente manera:

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

Cualquier excepción que no esté configurada se asignará a un error interno del servidor 500.

#### `config.action_dispatch.cookies_same_site_protection`

Configura el valor predeterminado del atributo `SameSite` al establecer cookies. Cuando se establece en `nil`, el atributo `SameSite` no se agrega. Para permitir que el valor del atributo `SameSite` se configure dinámicamente según la solicitud, se puede especificar un proc. Por ejemplo:

```ruby
config.action_dispatch.cookies_same_site_protection = ->(request) do
  :strict unless request.user_agent == "TestAgent"
end
```

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `nil`                     |
| 6.1                   | `:lax`                    |

#### `config.action_dispatch.ssl_default_redirect_status`

Configura el código de estado HTTP predeterminado utilizado al redirigir solicitudes no GET/HEAD de HTTP a HTTPS en el middleware `ActionDispatch::SSL`.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `307`                     |
| 6.1                   | `308`                     |

#### `config.action_dispatch.log_rescued_responses`

Permite registrar las excepciones no controladas configuradas en `rescue_responses`. El valor predeterminado es `true`.

#### `ActionDispatch::Callbacks.before`

Toma un bloque de código para ejecutar antes de la solicitud.

#### `ActionDispatch::Callbacks.after`

Toma un bloque de código para ejecutar después de la solicitud.

### Configurando Action View

`config.action_view` incluye un pequeño número de configuraciones:

#### `config.action_view.cache_template_loading`

Controla si las plantillas deben recargarse en cada solicitud o no. El valor predeterminado es `!config.enable_reloading`.

#### `config.action_view.field_error_proc`

Proporciona un generador HTML para mostrar errores que provienen de Active Model. El bloque se evalúa dentro del contexto de una plantilla de Action View. El valor predeterminado es

```ruby
Proc.new { |html_tag, instance| content_tag :div, html_tag, class: "field_with_errors" }
```

#### `config.action_view.default_form_builder`

Indica a Rails qué constructor de formularios utilizar de forma predeterminada. El valor predeterminado es `ActionView::Helpers::FormBuilder`. Si deseas que tu clase de constructor de formularios se cargue después de la inicialización (para que se recargue en cada solicitud en desarrollo), puedes pasarla como una `String`.
#### `config.action_view.logger`

Acepta un registrador que cumpla con la interfaz de Log4r o la clase de registro predeterminada de Ruby, que luego se utiliza para registrar información de Action View. Establecer en `nil` para desactivar el registro.

#### `config.action_view.erb_trim_mode`

Indica el modo de recorte que se utilizará en ERB. Por defecto, es `'-'`, lo que activa el recorte de espacios finales y saltos de línea al usar `<%= -%>` o `<%= =%>`. Consulte la [documentación de Erubis](http://www.kuwata-lab.com/erubis/users-guide.06.html#topics-trimspaces) para obtener más información.

#### `config.action_view.frozen_string_literal`

Compila la plantilla ERB con el comentario mágico `# frozen_string_literal: true`, lo que hace que todas las literales de cadena estén congeladas y ahorra asignaciones. Establecer en `true` para habilitarlo en todas las vistas.

#### `config.action_view.embed_authenticity_token_in_remote_forms`

Permite establecer el comportamiento predeterminado para `authenticity_token` en formularios con `remote: true`. De forma predeterminada, está establecido en `false`, lo que significa que los formularios remotos no incluirán `authenticity_token`, lo cual es útil cuando se está fragmentando en caché el formulario. Los formularios remotos obtienen la autenticidad de la etiqueta `meta`, por lo que la incrustación es innecesaria a menos que se admitan navegadores sin JavaScript. En ese caso, puede pasar `authenticity_token: true` como opción de formulario o establecer esta configuración en `true`.

#### `config.action_view.prefix_partial_path_with_controller_namespace`

Determina si las parciales se buscan en un subdirectorio en las plantillas renderizadas desde controladores con espacios de nombres. Por ejemplo, considere un controlador llamado `Admin::ArticlesController` que renderiza esta plantilla:

```erb
<%= render @article %>
```

La configuración predeterminada es `true`, lo que utiliza la parcial en `/admin/articles/_article.erb`. Establecer el valor en `false` renderizaría `/articles/_article.erb`, que es el mismo comportamiento que renderizar desde un controlador sin espacios de nombres como `ArticlesController`.

#### `config.action_view.automatically_disable_submit_tag`

Determina si `submit_tag` se debe desactivar automáticamente al hacer clic, esto es `true` de forma predeterminada.

#### `config.action_view.debug_missing_translation`

Determina si se debe envolver la clave de traducción faltante en una etiqueta `<span>` o no. Esto es `true` de forma predeterminada.

#### `config.action_view.form_with_generates_remote_forms`

Determina si `form_with` genera formularios remotos o no.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| 5.1                   | `true`               |
| 6.1                   | `false`              |

#### `config.action_view.form_with_generates_ids`

Determina si `form_with` genera ids en los campos de entrada.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 5.2                   | `true`               |

#### `config.action_view.default_enforce_utf8`

Determina si se generan formularios con una etiqueta oculta que obliga a las versiones antiguas de Internet Explorer a enviar formularios codificados en UTF-8.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `true`               |
| 6.0                   | `false`              |

#### `config.action_view.image_loading`

Especifica un valor predeterminado para el atributo `loading` de las etiquetas `<img>` generadas por el ayudante `image_tag`. Por ejemplo, cuando se establece en `"lazy"`, las etiquetas `<img>` generadas por `image_tag` incluirán `loading="lazy"`, lo que [indica al navegador que espere hasta que una imagen esté cerca del área visible para cargarla](https://html.spec.whatwg.org/#lazy-loading-attributes). (Este valor aún se puede anular por imagen pasando, por ejemplo, `loading: "eager"` a `image_tag`.) El valor predeterminado es `nil`.

#### `config.action_view.image_decoding`

Especifica un valor predeterminado para el atributo `decoding` de las etiquetas `<img>` generadas por el ayudante `image_tag`. El valor predeterminado es `nil`.
#### `config.action_view.annotate_rendered_view_with_filenames`

Determina si se debe anotar la vista renderizada con los nombres de archivo de la plantilla. Esto se establece en `false` por defecto.

#### `config.action_view.preload_links_header`

Determina si `javascript_include_tag` y `stylesheet_link_tag` generarán una cabecera `Link` que precargue los activos.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `nil`                |
| 6.1                   | `true`               |

#### `config.action_view.button_to_generates_button_tag`

Determina si `button_to` renderizará el elemento `<button>`, independientemente de si el contenido se pasa como primer argumento o como un bloque.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.0                   | `true`               |

#### `config.action_view.apply_stylesheet_media_default`

Determina si `stylesheet_link_tag` renderizará `screen` como el valor predeterminado para el atributo `media` cuando no se proporcione.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `true`               |
| 7.0                   | `false`              |

#### `config.action_view.prepend_content_exfiltration_prevention`

Determina si los ayudantes `form_tag` y `button_to` generarán etiquetas HTML con un HTML seguro para el navegador (pero técnicamente inválido) que garantiza que su contenido no pueda ser capturado por ninguna etiqueta sin cerrar previa. El valor predeterminado es `false`.

#### `config.action_view.sanitizer_vendor`

Configura el conjunto de sanitizadores HTML utilizados por Action View estableciendo `ActionView::Helpers::SanitizeHelper.sanitizer_vendor`. El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es                 | Que analiza el marcado como |
|-----------------------|--------------------------------------|------------------------|
| (original)            | `Rails::HTML4::Sanitizer`            | HTML4                  |
| 7.1                   | `Rails::HTML5::Sanitizer` (ver NOTA) | HTML5                  |

NOTA: `Rails::HTML5::Sanitizer` no es compatible con JRuby, por lo que en plataformas JRuby Rails utilizará `Rails::HTML4::Sanitizer`.

### Configuración de Action Mailbox

`config.action_mailbox` proporciona las siguientes opciones de configuración:

#### `config.action_mailbox.logger`

Contiene el registrador utilizado por Action Mailbox. Acepta un registrador que cumpla con la interfaz de Log4r o la clase de registro predeterminada de Ruby. El valor predeterminado es `Rails.logger`.

```ruby
config.action_mailbox.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.action_mailbox.incinerate_after`

Acepta una `ActiveSupport::Duration` que indica cuánto tiempo después de procesar los registros de `ActionMailbox::InboundEmail` deben ser destruidos. El valor predeterminado es `30.days`.

```ruby
# Destruir los correos electrónicos entrantes 14 días después de procesarlos.
config.action_mailbox.incinerate_after = 14.days
```

#### `config.action_mailbox.queues.incineration`

Acepta un símbolo que indica la cola de Active Job que se utilizará para los trabajos de incineración. Cuando esta opción es `nil`, los trabajos de incineración se envían a la cola de Active Job predeterminada (ver `config.active_job.default_queue_name`).

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `:action_mailbox_incineration` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.queues.routing`

Acepta un símbolo que indica la cola de Active Job que se utilizará para los trabajos de enrutamiento. Cuando esta opción es `nil`, los trabajos de enrutamiento se envían a la cola de Active Job predeterminada (ver `config.active_job.default_queue_name`).

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `:action_mailbox_routing` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.storage_service`
Acepta un símbolo que indica el servicio de Active Storage que se utilizará para cargar correos electrónicos. Cuando esta opción es `nil`, los correos electrónicos se cargan en el servicio de Active Storage predeterminado (ver `config.active_storage.service`).

### Configuración de Action Mailer

Hay varias configuraciones disponibles en `config.action_mailer`:

#### `config.action_mailer.asset_host`

Establece el host para los activos. Útil cuando se utilizan CDN para alojar activos en lugar del propio servidor de la aplicación. Solo debes usar esto si tienes una configuración diferente para Action Controller, de lo contrario usa `config.asset_host`.

#### `config.action_mailer.logger`

Acepta un registrador que cumple con la interfaz de Log4r o la clase de registro predeterminada de Ruby, que luego se utiliza para registrar información de Action Mailer. Establecer en `nil` para desactivar el registro.

#### `config.action_mailer.smtp_settings`

Permite una configuración detallada para el método de entrega `:smtp`. Acepta un hash de opciones, que pueden incluir cualquiera de estas opciones:

* `:address` - Te permite usar un servidor de correo remoto. Simplemente cámbialo desde su configuración predeterminada "localhost".
* `:port` - En caso de que tu servidor de correo no se ejecute en el puerto 25, puedes cambiarlo.
* `:domain` - Si necesitas especificar un dominio HELO, puedes hacerlo aquí.
* `:user_name` - Si tu servidor de correo requiere autenticación, establece el nombre de usuario en esta configuración.
* `:password` - Si tu servidor de correo requiere autenticación, establece la contraseña en esta configuración.
* `:authentication` - Si tu servidor de correo requiere autenticación, debes especificar el tipo de autenticación aquí. Esto es un símbolo y puede ser `:plain`, `:login`, `:cram_md5`.
* `:enable_starttls` - Usa STARTTLS al conectarte a tu servidor SMTP y falla si no es compatible. Por defecto es `false`.
* `:enable_starttls_auto` - Detecta si STARTTLS está habilitado en tu servidor SMTP y comienza a usarlo. Por defecto es `true`.
* `:openssl_verify_mode` - Cuando se utiliza TLS, puedes establecer cómo OpenSSL verifica el certificado. Esto es útil si necesitas validar un certificado autofirmado y/o un certificado comodín. Puede ser una de las constantes de verificación de OpenSSL, `:none` o `:peer` -- o la constante directamente `OpenSSL::SSL::VERIFY_NONE` o `OpenSSL::SSL::VERIFY_PEER`, respectivamente.
* `:ssl/:tls` - Habilita la conexión SMTP para usar SMTP/TLS (SMTPS: conexión SMTP sobre TLS directa).
* `:open_timeout` - Número de segundos para esperar al intentar abrir una conexión.
* `:read_timeout` - Número de segundos para esperar hasta que se agote el tiempo de espera de una llamada a read(2).

Además, es posible pasar cualquier [opción de configuración que respete `Mail::SMTP`](https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/smtp.rb).

#### `config.action_mailer.smtp_timeout`

Permite configurar los valores `:open_timeout` y `:read_timeout` para el método de entrega `:smtp`.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `nil`                     |
| 7.0                   | `5`                       |

#### `config.action_mailer.sendmail_settings`

Permite una configuración detallada para el método de entrega `sendmail`. Acepta un hash de opciones, que pueden incluir cualquiera de estas opciones:

* `:location` - La ubicación del ejecutable de sendmail. Por defecto es `/usr/sbin/sendmail`.
* `:arguments` - Los argumentos de la línea de comandos. Por defecto es `%w[ -i ]`.

#### `config.action_mailer.raise_delivery_errors`

Especifica si se debe generar un error si no se puede completar la entrega del correo electrónico. Por defecto es `true`.
#### `config.action_mailer.delivery_method`

Define el método de entrega y por defecto es `:smtp`. Consulta la [sección de configuración en la guía de Action Mailer](action_mailer_basics.html#action-mailer-configuration) para obtener más información.

#### `config.action_mailer.perform_deliveries`

Especifica si el correo electrónico se entregará realmente y por defecto es `true`. Puede ser conveniente establecerlo en `false` para pruebas.

#### `config.action_mailer.default_options`

Configura las opciones predeterminadas de Action Mailer. Úsalo para establecer opciones como `from` o `reply_to` para cada mailer. Estas opciones predeterminan a:

```ruby
mime_version:  "1.0",
charset:       "UTF-8",
content_type: "text/plain",
parts_order:  ["text/plain", "text/enriched", "text/html"]
```

Asigna un hash para establecer opciones adicionales:

```ruby
config.action_mailer.default_options = {
  from: "noreply@example.com"
}
```

#### `config.action_mailer.observers`

Registra observadores que serán notificados cuando se entregue el correo.

```ruby
config.action_mailer.observers = ["MailObserver"]
```

#### `config.action_mailer.interceptors`

Registra interceptores que se llamarán antes de enviar el correo.

```ruby
config.action_mailer.interceptors = ["MailInterceptor"]
```

#### `config.action_mailer.preview_interceptors`

Registra interceptores que se llamarán antes de previsualizar el correo.

```ruby
config.action_mailer.preview_interceptors = ["MyPreviewMailInterceptor"]
```

#### `config.action_mailer.preview_paths`

Especifica las ubicaciones de las previsualizaciones de mailer. Agregar rutas a esta opción de configuración hará que se utilicen esas rutas en la búsqueda de previsualizaciones de mailer.

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

#### `config.action_mailer.show_previews`

Habilita o deshabilita las previsualizaciones de mailer. Por defecto, esto es `true` en desarrollo.

```ruby
config.action_mailer.show_previews = false
```

#### `config.action_mailer.perform_caching`

Especifica si las plantillas de mailer deben realizar el almacenamiento en caché de fragmentos o no. Si no se especifica, el valor predeterminado será `true`.

#### `config.action_mailer.deliver_later_queue_name`

Especifica la cola de Active Job que se utilizará para el trabajo de entrega predeterminado (ver `config.action_mailer.delivery_job`). Cuando esta opción se establece en `nil`, los trabajos de entrega se envían a la cola de Active Job predeterminada (ver `config.active_job.default_queue_name`).

Las clases de mailer pueden anular esto para usar una cola diferente. Ten en cuenta que esto solo se aplica cuando se utiliza el trabajo de entrega predeterminado. Si tu mailer utiliza un trabajo personalizado, se utilizará su cola.

Asegúrate de que tu adaptador de Active Job también esté configurado para procesar la cola especificada, de lo contrario, los trabajos de entrega pueden ser ignorados silenciosamente.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `:mailers`           |
| 6.1                   | `nil`                |

#### `config.action_mailer.delivery_job`

Especifica el trabajo de entrega para el correo.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `ActionMailer::MailDeliveryJob` |
| 6.0                   | `"ActionMailer::MailDeliveryJob"` |

### Configurando Active Support

Hay algunas opciones de configuración disponibles en Active Support:

#### `config.active_support.bare`

Habilita o deshabilita la carga de `active_support/all` al iniciar Rails. Por defecto es `nil`, lo que significa que se carga `active_support/all`.

#### `config.active_support.test_order`

Establece el orden en que se ejecutan los casos de prueba. Los valores posibles son `:random` y `:sorted`. Por defecto es `:random`.

#### `config.active_support.escape_html_entities_in_json`

Habilita o deshabilita el escape de entidades HTML en la serialización JSON. Por defecto es `true`.

#### `config.active_support.use_standard_json_time_format`

Habilita o deshabilita la serialización de fechas en formato ISO 8601. Por defecto es `true`.

#### `config.active_support.time_precision`

Establece la precisión de los valores de tiempo codificados en JSON. Por defecto es `3`.

#### `config.active_support.hash_digest_class`

Permite configurar la clase de resumen que se utilizará para generar resúmenes no sensibles, como el encabezado ETag.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:
| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `OpenSSL::Digest::MD5` |
| 5.2                   | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.key_generator_hash_digest_class`

Permite configurar la clase de resumen que se utilizará para derivar secretos de la base de secretos configurada, como para las cookies encriptadas.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.use_authenticated_message_encryption`

Especifica si se debe utilizar el cifrado de autenticación AES-256-GCM como el cifrado predeterminado para encriptar mensajes en lugar de AES-256-CBC.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 5.2                   | `true`               |

#### `config.active_support.message_serializer`

Especifica el serializador predeterminado utilizado por las instancias de [`ActiveSupport::MessageEncryptor`][]
y [`ActiveSupport::MessageVerifier`][]. Para facilitar la migración entre
serializadores, los serializadores proporcionados incluyen un mecanismo de fallback para
soportar múltiples formatos de deserialización:

| Serializador | Serializar y deserializar | Deserialización de fallback |
| ---------- | ------------------------- | -------------------- |
| `:marshal` | `Marshal` | `ActiveSupport::JSON`, `ActiveSupport::MessagePack` |
| `:json` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack` |
| `:json_allow_marshal` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack`, `Marshal` |
| `:message_pack` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON` |
| `:message_pack_allow_marshal` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON`, `Marshal` |

ADVERTENCIA: `Marshal` es un vector potencial para ataques de deserialización en casos
donde se ha filtrado un secreto de firma de mensajes. _Si es posible, elija un
serializador que no admita `Marshal`._

INFO: Los serializadores `:message_pack` y `:message_pack_allow_marshal` admiten
la ida y vuelta de algunos tipos de Ruby que no son admitidos por JSON, como `Symbol`.
También pueden proporcionar un rendimiento mejorado y tamaños de carga útil más pequeños. Sin embargo,
requieren la gema [`msgpack`](https://rubygems.org/gems/msgpack).

Cada uno de los serializadores anteriores emitirá una notificación de evento [`message_serializer_fallback.active_support`][]
cuando se recurra a un formato de deserialización alternativo,
lo que le permite realizar un seguimiento de la frecuencia con la que ocurren dichos fallbacks.

Alternativamente, puede especificar cualquier objeto serializador que responda a los métodos `dump` y
`load`. Por ejemplo:

```ruby
config.active_job.message_serializer = YAML
```

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `:marshal`           |
| 7.1                   | `:json_allow_marshal` |


#### `config.active_support.use_message_serializer_for_metadata`

Cuando es `true`, habilita una optimización de rendimiento que serializa datos de mensajes y
metadatos juntos. Esto cambia el formato del mensaje, por lo que los mensajes serializados de esta
manera no pueden ser leídos por versiones anteriores (< 7.1) de Rails. Sin embargo, los mensajes que
utilizan el formato antiguo aún se pueden leer, independientemente de si se habilita esta optimización o no.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_support.cache_format_version`

Especifica qué formato de serialización utilizar para la caché. Los valores posibles son
`6.1`, `7.0` y `7.1`.

Los formatos `6.1`, `7.0` y `7.1` utilizan `Marshal` como codificador predeterminado, pero
`7.0` utiliza una representación más eficiente para las entradas de caché y `7.1` incluye
una optimización adicional para valores de cadena sin formato, como fragmentos de vista.
Todos los formatos son compatibles hacia atrás y hacia adelante, lo que significa que las entradas de caché escritas en un formato se pueden leer cuando se utiliza otro formato. Este comportamiento facilita la migración entre formatos sin invalidar toda la caché.

El valor predeterminado depende de la versión objetivo `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `6.1`                     |
| 7.0                   | `7.0`                     |
| 7.1                   | `7.1`                     |

#### `config.active_support.deprecation`

Configura el comportamiento de las advertencias de deprecación. Las opciones son `:raise`, `:stderr`, `:log`, `:notify` y `:silence`.

En los archivos `config/environments` generados por defecto, esto se establece en `:log` para desarrollo y `:stderr` para prueba, y se omite para producción a favor de [`config.active_support.report_deprecations`](#config-active-support-report-deprecations).

#### `config.active_support.disallowed_deprecation`

Configura el comportamiento de las advertencias de deprecación no permitidas. Las opciones son `:raise`, `:stderr`, `:log`, `:notify` y `:silence`.

En los archivos `config/environments` generados por defecto, esto se establece en `:raise` tanto para desarrollo como para prueba, y se omite para producción a favor de [`config.active_support.report_deprecations`](#config-active-support-report-deprecations).

#### `config.active_support.disallowed_deprecation_warnings`

Configura las advertencias de deprecación que la aplicación considera no permitidas. Esto permite, por ejemplo, tratar ciertas deprecaciones como fallas graves.

#### `config.active_support.report_deprecations`

Cuando es `false`, desactiva todas las advertencias de deprecación, incluidas las deprecaciones no permitidas, de los [deprecadores de la aplicación](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators). Esto incluye todas las deprecaciones de Rails y otras gemas que pueden agregar su deprecador a la colección de deprecadores, pero puede que no evite todas las advertencias de deprecación emitidas por ActiveSupport::Deprecation.

En los archivos `config/environments` generados por defecto, esto se establece en `false` para producción.

#### `config.active_support.isolation_level`

Configura la localidad de la mayoría del estado interno de Rails. Si utiliza un servidor o procesador de trabajos basado en fibras (por ejemplo, `falcon`), debe establecerlo en `:fiber`. De lo contrario, es mejor utilizar la localidad `:thread`. El valor predeterminado es `:thread`.

#### `config.active_support.executor_around_test_case`

Configura el conjunto de pruebas para llamar a `Rails.application.executor.wrap` alrededor de los casos de prueba. Esto hace que los casos de prueba se comporten más cerca de una solicitud o trabajo real. Varias características que normalmente están deshabilitadas en las pruebas, como la caché de consultas de Active Record y las consultas asíncronas, se habilitarán.

El valor predeterminado depende de la versión objetivo `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `false`                   |
| 7.0                   | `true`                    |

#### `ActiveSupport::Logger.silencer`

Se establece en `false` para desactivar la capacidad de silenciar el registro en un bloque. El valor predeterminado es `true`.

#### `ActiveSupport::Cache::Store.logger`

Especifica el registro a utilizar en las operaciones de almacenamiento en caché.

#### `ActiveSupport.to_time_preserves_timezone`

Especifica si los métodos `to_time` conservan el desplazamiento de tiempo UTC de sus receptores. Si es `false`, los métodos `to_time` convertirán al desplazamiento de tiempo UTC del sistema local en su lugar.

El valor predeterminado depende de la versión objetivo `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `false`                   |
| 5.0                   | `true`                    |

#### `ActiveSupport.utc_to_local_returns_utc_offset_times`

Configura `ActiveSupport::TimeZone.utc_to_local` para devolver una hora con un desplazamiento UTC en lugar de una hora UTC que incorpora ese desplazamiento.

El valor predeterminado depende de la versión objetivo `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `false`                   |
| 6.1                   | `true`                    |
#### `config.active_support.raise_on_invalid_cache_expiration_time`

Especifica si se debe generar un `ArgumentError` si `Rails.cache` `fetch` o `write` reciben un tiempo de `expires_at` o `expires_in` inválido.

Las opciones son `true` y `false`. Si es `false`, la excepción se informará como `manejada` y se registrará en los registros.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `false`                   |
| 7.1                   | `true`                    |

### Configuración de Active Job

`config.active_job` proporciona las siguientes opciones de configuración:

#### `config.active_job.queue_adapter`

Establece el adaptador para el backend de encolamiento. El adaptador predeterminado es `:async`. Para obtener una lista actualizada de adaptadores integrados, consulte la documentación de la API de [ActiveJob::QueueAdapters](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html).

```ruby
# Asegúrese de tener la gema del adaptador en su Gemfile
# y siga las instrucciones de instalación y despliegue específicas del adaptador.
config.active_job.queue_adapter = :sidekiq
```

#### `config.active_job.default_queue_name`

Se puede utilizar para cambiar el nombre de la cola predeterminada. Por defecto, esto es `"default"`.

```ruby
config.active_job.default_queue_name = :medium_priority
```

#### `config.active_job.queue_name_prefix`

Le permite establecer un prefijo de nombre de cola opcional y no vacío para todos los trabajos. Por defecto, está en blanco y no se utiliza.

La siguiente configuración encolaría el trabajo dado en la cola `production_high_priority` cuando se ejecute en producción:

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

Tiene un valor predeterminado de `'_'`. Si se establece `queue_name_prefix`, entonces `queue_name_delimiter` une el prefijo y el nombre de la cola sin prefijo.

La siguiente configuración encolaría el trabajo proporcionado en la cola `video_server.low_priority`:

```ruby
# el prefijo debe establecerse para que se utilice el delimitador
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

Acepta un registrador que cumple con la interfaz de Log4r o la clase de registro predeterminada de Ruby, que luego se utiliza para registrar información de Active Job. Puede obtener este registrador llamando a `logger` en una clase o instancia de Active Job. Establezca en `nil` para deshabilitar el registro.

#### `config.active_job.custom_serializers`

Permite establecer serializadores de argumentos personalizados. El valor predeterminado es `[]`.

#### `config.active_job.log_arguments`

Controla si se registran los argumentos de un trabajo. El valor predeterminado es `true`.

#### `config.active_job.verbose_enqueue_logs`

Especifica si se deben registrar las ubicaciones de origen de los métodos que encolan trabajos en segundo plano debajo de las líneas de registro de encolamiento relevantes. De forma predeterminada, la bandera es `true` en desarrollo y `false` en todos los demás entornos.

#### `config.active_job.retry_jitter`

Controla la cantidad de "jitter" (variación aleatoria) aplicada al tiempo de retraso calculado al reintentar trabajos fallidos.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `0.0`                     |
| 6.1                   | `0.15`                    |

#### `config.active_job.log_query_tags_around_perform`

Determina si el contexto de trabajo para las etiquetas de consulta se actualizará automáticamente a través de un `around_perform`. El valor predeterminado es `true`.

#### `config.active_job.use_big_decimal_serializer`

Habilita el nuevo serializador de argumentos `BigDecimal`, que garantiza la reversibilidad. Sin este serializador, algunos adaptadores de cola pueden serializar los argumentos `BigDecimal` como cadenas simples (no reversibles).

ADVERTENCIA: Al implementar una aplicación con múltiples réplicas, las réplicas antiguas (anteriores a Rails 7.1) no podrán deserializar los argumentos `BigDecimal` de este serializador. Por lo tanto, esta configuración solo debe habilitarse después de que todas las réplicas se hayan actualizado correctamente a Rails 7.1.
El valor predeterminado depende de la versión objetivo `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `false`                   |
| 7.1                   | `true`                    |

### Configuración de Action Cable

#### `config.action_cable.url`

Acepta una cadena para la URL donde se encuentra alojado el servidor de Action Cable. Usarías esta opción si estás ejecutando servidores de Action Cable separados de tu aplicación principal.

#### `config.action_cable.mount_path`

Acepta una cadena para indicar dónde montar Action Cable como parte del proceso del servidor principal. El valor predeterminado es `/cable`. Puedes establecer esto como `nil` para no montar Action Cable como parte de tu servidor normal de Rails.

Puedes encontrar más opciones de configuración detalladas en la [Descripción general de Action Cable](action_cable_overview.html#configuration).

#### `config.action_cable.precompile_assets`

Determina si los activos de Action Cable deben agregarse a la precompilación del pipeline de activos. No tiene efecto si no se utiliza Sprockets. El valor predeterminado es `true`.

### Configuración de Active Storage

`config.active_storage` proporciona las siguientes opciones de configuración:

#### `config.active_storage.variant_processor`

Acepta un símbolo `:mini_magick` o `:vips`, especificando si las transformaciones de variantes y el análisis de blobs se realizarán con MiniMagick o ruby-vips.

El valor predeterminado depende de la versión objetivo `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `:mini_magick`            |
| 7.0                   | `:vips`                   |

#### `config.active_storage.analyzers`

Acepta una matriz de clases que indican los analizadores disponibles para los blobs de Active Storage. Por defecto, se define como:

```ruby
config.active_storage.analyzers = [ActiveStorage::Analyzer::ImageAnalyzer::Vips, ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick, ActiveStorage::Analyzer::VideoAnalyzer, ActiveStorage::Analyzer::AudioAnalyzer]
```

Los analizadores de imágenes pueden extraer el ancho y la altura de un blob de imagen; el analizador de video puede extraer el ancho, la altura, la duración, el ángulo, la relación de aspecto y la presencia/ausencia de canales de video/audio de un blob de video; el analizador de audio puede extraer la duración y la velocidad de bits de un blob de audio.

#### `config.active_storage.previewers`

Acepta una matriz de clases que indican los previsualizadores de imágenes disponibles en los blobs de Active Storage. Por defecto, se define como:

```ruby
config.active_storage.previewers = [ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer]
```

`PopplerPDFPreviewer` y `MuPDFPreviewer` pueden generar una miniatura a partir de la primera página de un blob de PDF; `VideoPreviewer` a partir del fotograma relevante de un blob de video.

#### `config.active_storage.paths`

Acepta un hash de opciones que indican las ubicaciones de los comandos de previsualización/analizador. El valor predeterminado es `{}`, lo que significa que los comandos se buscarán en la ruta predeterminada. Puede incluir cualquiera de estas opciones:

* `:ffprobe` - La ubicación del ejecutable ffprobe.
* `:mutool` - La ubicación del ejecutable mutool.
* `:ffmpeg` - La ubicación del ejecutable ffmpeg.

```ruby
config.active_storage.paths[:ffprobe] = '/usr/local/bin/ffprobe'
```

#### `config.active_storage.variable_content_types`

Acepta una matriz de cadenas que indican los tipos de contenido que Active Storage puede transformar a través del procesador de variantes. Por defecto, se define como:

```ruby
config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/bmp image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)
```

#### `config.active_storage.web_image_content_types`

Acepta una matriz de cadenas consideradas como tipos de contenido de imágenes web en los que se pueden procesar variantes sin convertirlos al formato PNG de respaldo. Si deseas utilizar variantes `WebP` o `AVIF` en tu aplicación, puedes agregar `image/webp` o `image/avif` a esta matriz. Por defecto, se define como:
```ruby
config.active_storage.web_image_content_types = %w(image/png image/jpeg image/gif)
```

#### `config.active_storage.content_types_to_serve_as_binary`

Acepta un array de strings que indica los tipos de contenido que Active Storage siempre servirá como un archivo adjunto, en lugar de en línea.
Por defecto, esto está definido como:

```ruby
config.active_storage.content_types_to_serve_as_binary = %w(text/html image/svg+xml application/postscript application/x-shockwave-flash text/xml application/xml application/xhtml+xml application/mathml+xml text/cache-manifest)
```

#### `config.active_storage.content_types_allowed_inline`

Acepta un array de strings que indica los tipos de contenido que Active Storage permite servir en línea.
Por defecto, esto está definido como:

```ruby
config.active_storage.content_types_allowed_inline` = %w(image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon application/pdf)
```

#### `config.active_storage.queues.analysis`

Acepta un símbolo que indica la cola de Active Job que se utilizará para los trabajos de análisis. Cuando esta opción es `nil`, los trabajos de análisis se envían a la cola de Active Job predeterminada (ver `config.active_job.default_queue_name`).

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| 6.0                   | `:active_storage_analysis` |
| 6.1                   | `nil`                |

#### `config.active_storage.queues.purge`

Acepta un símbolo que indica la cola de Active Job que se utilizará para los trabajos de purga. Cuando esta opción es `nil`, los trabajos de purga se envían a la cola de Active Job predeterminada (ver `config.active_job.default_queue_name`).

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| 6.0                   | `:active_storage_purge` |
| 6.1                   | `nil`                |

#### `config.active_storage.queues.mirror`

Acepta un símbolo que indica la cola de Active Job que se utilizará para los trabajos de espejo de carga directa. Cuando esta opción es `nil`, los trabajos de espejo se envían a la cola de Active Job predeterminada (ver `config.active_job.default_queue_name`). El valor predeterminado es `nil`.

#### `config.active_storage.logger`

Se puede utilizar para establecer el registrador utilizado por Active Storage. Acepta un registrador que cumple con la interfaz de Log4r o la clase de registro predeterminada de Ruby.

```ruby
config.active_storage.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.active_storage.service_urls_expire_in`

Determina la expiración predeterminada de las URL generadas por:

* `ActiveStorage::Blob#url`
* `ActiveStorage::Blob#service_url_for_direct_upload`
* `ActiveStorage::Variant#url`

El valor predeterminado es de 5 minutos.

#### `config.active_storage.urls_expire_in`

Determina la expiración predeterminada de las URL generadas por Active Storage en la aplicación de Rails. El valor predeterminado es `nil`.

#### `config.active_storage.routes_prefix`

Se puede utilizar para establecer el prefijo de ruta para las rutas servidas por Active Storage. Acepta una cadena que se agregará al principio de las rutas generadas.

```ruby
config.active_storage.routes_prefix = '/files'
```

El valor predeterminado es `/rails/active_storage`.

#### `config.active_storage.track_variants`

Determina si se registran las variantes en la base de datos.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 6.1                   | `true`               |

#### `config.active_storage.draw_routes`

Se puede utilizar para activar o desactivar la generación de rutas de Active Storage. El valor predeterminado es `true`.

#### `config.active_storage.resolve_model_to_route`

Se puede utilizar para cambiar globalmente la forma en que se entregan los archivos de Active Storage.

Los valores permitidos son:

* `:rails_storage_redirect`: Redirigir a URL de servicio firmadas y de corta duración.
* `:rails_storage_proxy`: Proxy de archivos descargándolos.

El valor predeterminado es `:rails_storage_redirect`.

#### `config.active_storage.video_preview_arguments`

Se puede utilizar para alterar la forma en que ffmpeg genera imágenes de vista previa de video.

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | -------------------- |
| (original)            | `"-y -vframes 1 -f image2"` |
| 7.0                   | `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015)"`<sup><mark><strong><em>1</em></strong></mark></sup> <br> `+ ",loop=loop=-1:size=2,trim=start_frame=1'"`<sup><mark><strong><em>2</em></strong></mark></sup><br> `+ " -frames:v 1 -f image2"` <br><br> <ol><li>Selecciona el primer fotograma de video, más los fotogramas clave, más los fotogramas que cumplen con el umbral de cambio de escena.</li> <li>Utiliza el primer fotograma de video como alternativa cuando ningún otro fotograma cumple con los criterios repitiendo el primer fotograma seleccionado (uno o) dos veces, luego eliminando el primer fotograma repetido.</li></ol> |
#### `config.active_storage.multiple_file_field_include_hidden`

En Rails 7.1 en adelante, las relaciones `has_many_attached` de Active Storage
por defecto _reemplazarán_ la colección actual en lugar de _añadir_ a ella. Por lo tanto,
para admitir el envío de una colección _vacía_, cuando `multiple_file_field_include_hidden`
es `true`, el ayudante [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field)
renderizará un campo oculto auxiliar, similar al campo auxiliar
renderizado por el ayudante [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box).

El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `false`                   |
| 7.0                   | `true`                    |

#### `config.active_storage.precompile_assets`

Determina si los activos de Active Storage deben agregarse a la precompilación de la canalización de activos. No
tiene efecto si no se utiliza Sprockets. El valor predeterminado es `true`.

### Configurando Action Text

#### `config.action_text.attachment_tag_name`

Acepta una cadena para la etiqueta HTML utilizada para envolver los adjuntos. El valor predeterminado es `"action-text-attachment"`.

#### `config.action_text.sanitizer_vendor`

Configura el sanitizador HTML utilizado por Action Text estableciendo `ActionText::ContentHelper.sanitizer` en una instancia de la clase devuelta por el método `.safe_list_sanitizer` del proveedor. El valor predeterminado depende de la versión objetivo de `config.load_defaults`:

| A partir de la versión | El valor predeterminado es                 | Que analiza la marca |
|-----------------------|--------------------------------------------|----------------------|
| (original)            | `Rails::HTML4::Sanitizer`                   | HTML4                |
| 7.1                   | `Rails::HTML5::Sanitizer` (ver NOTA)         | HTML5                |

NOTA: `Rails::HTML5::Sanitizer` no es compatible con JRuby, por lo que en plataformas JRuby, Rails utilizará `Rails::HTML4::Sanitizer`.

### Configurando una base de datos

Casi todas las aplicaciones de Rails interactuarán con una base de datos. Puede conectarse a la base de datos configurando una variable de entorno `ENV['DATABASE_URL']` o utilizando un archivo de configuración llamado `config/database.yml`.

Usando el archivo `config/database.yml`, puede especificar toda la información necesaria para acceder a su base de datos:

```yaml
development:
  adapter: postgresql
  database: blog_development
  pool: 5
```

Esto se conectará a la base de datos llamada `blog_development` utilizando el adaptador `postgresql`. Esta misma información se puede almacenar en una URL y proporcionarse a través de una variable de entorno de esta manera:

```ruby
ENV['DATABASE_URL'] # => "postgresql://localhost/blog_development?pool=5"
```

El archivo `config/database.yml` contiene secciones para tres entornos diferentes en los que Rails puede ejecutarse de forma predeterminada:

* El entorno `development` se utiliza en su computadora de desarrollo/local mientras interactúa manualmente con la aplicación.
* El entorno `test` se utiliza al ejecutar pruebas automatizadas.
* El entorno `production` se utiliza cuando implementa su aplicación para que el mundo la use.

Si lo desea, puede especificar manualmente una URL dentro de su `config/database.yml`

```yaml
development:
  url: postgresql://localhost/blog_development?pool=5
```

El archivo `config/database.yml` puede contener etiquetas ERB `<%= %>`. Todo lo que esté dentro de las etiquetas se evaluará como código Ruby. Puede usar esto para extraer datos de una variable de entorno o para realizar cálculos para generar la información de conexión necesaria.


CONSEJO: No es necesario actualizar las configuraciones de la base de datos manualmente. Si observa las opciones del generador de aplicaciones, verá que una de las opciones se llama `--database`. Esta opción le permite elegir un adaptador de una lista de las bases de datos relacionales más utilizadas. Incluso puede ejecutar el generador repetidamente: `cd .. && rails new blog --database=mysql`. Cuando confirme la sobrescritura del archivo `config/database.yml`, su aplicación se configurará para MySQL en lugar de SQLite. A continuación se muestran ejemplos detallados de las conexiones de bases de datos comunes.
### Preferencia de conexión

Dado que hay dos formas de configurar tu conexión (usando `config/database.yml` o usando una variable de entorno), es importante entender cómo pueden interactuar.

Si tienes un archivo `config/database.yml` vacío pero tu `ENV['DATABASE_URL']` está presente, entonces Rails se conectará a la base de datos a través de tu variable de entorno:

```bash
$ cat config/database.yml

$ echo $DATABASE_URL
postgresql://localhost/my_database
```

Si tienes un archivo `config/database.yml` pero no tienes `ENV['DATABASE_URL']`, entonces se utilizará este archivo para conectarse a tu base de datos:

```bash
$ cat config/database.yml
development:
  adapter: postgresql
  database: my_database
  host: localhost

$ echo $DATABASE_URL
```

Si tienes tanto `config/database.yml` como `ENV['DATABASE_URL']` configurados, entonces Rails fusionará la configuración. Para entender esto mejor, debemos ver algunos ejemplos.

Cuando se proporciona información de conexión duplicada, la variable de entorno tiene prioridad:

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

Aquí el adaptador, el host y la base de datos coinciden con la información en `ENV['DATABASE_URL']`.

Si se proporciona información no duplicada, obtendrás todos los valores únicos, la variable de entorno aún tiene prioridad en caso de conflictos.

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

Dado que el pool no está en la información de conexión proporcionada por `ENV['DATABASE_URL']`, su información se fusiona. Dado que el adaptador es duplicado, la información de conexión de `ENV['DATABASE_URL']` tiene prioridad.

La única forma de no utilizar explícitamente la información de conexión en `ENV['DATABASE_URL']` es especificar una conexión de URL explícita usando la subclave `"url"`:

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

Aquí se ignora la información de conexión en `ENV['DATABASE_URL']`, nota el adaptador y el nombre de la base de datos diferentes.

Dado que es posible incrustar ERB en tu `config/database.yml`, es una buena práctica mostrar explícitamente que estás utilizando `ENV['DATABASE_URL']` para conectarte a tu base de datos. Esto es especialmente útil en producción, ya que no debes comprometer secretos como la contraseña de tu base de datos en tu control de código fuente (como Git).

```bash
$ cat config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

Ahora el comportamiento es claro, solo estamos utilizando la información de conexión en `ENV['DATABASE_URL']`.

#### Configuración de una base de datos SQLite3

Rails viene con soporte incorporado para [SQLite3](http://www.sqlite.org), que es una aplicación de base de datos liviana y sin servidor. Si bien un entorno de producción ocupado puede sobrecargar SQLite, funciona bien para desarrollo y pruebas. Rails utiliza una base de datos SQLite de forma predeterminada al crear un nuevo proyecto, pero siempre puedes cambiarlo más tarde.

Aquí está la sección del archivo de configuración predeterminado (`config/database.yml`) con información de conexión para el entorno de desarrollo:

```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

NOTA: Rails utiliza una base de datos SQLite3 para el almacenamiento de datos de forma predeterminada porque es una base de datos de configuración cero que simplemente funciona. Rails también admite MySQL (incluido MariaDB) y PostgreSQL "listo para usar" y tiene complementos para muchos sistemas de bases de datos. Si estás utilizando una base de datos en un entorno de producción, es muy probable que Rails tenga un adaptador para ella.
#### Configuración de una base de datos MySQL o MariaDB

Si elige utilizar MySQL o MariaDB en lugar de la base de datos SQLite3 incluida, su `config/database.yml` se verá un poco diferente. Aquí está la sección de desarrollo:

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

Si su base de datos de desarrollo tiene un usuario root con una contraseña vacía, esta configuración debería funcionar para usted. De lo contrario, cambie el nombre de usuario y la contraseña en la sección `development` según corresponda.

NOTA: Si su versión de MySQL es 5.5 o 5.6 y desea utilizar el conjunto de caracteres `utf8mb4` de forma predeterminada, configure su servidor MySQL para admitir el prefijo de clave más largo habilitando la variable del sistema `innodb_large_prefix`.

Las cerraduras de asesoramiento están habilitadas de forma predeterminada en MySQL y se utilizan para hacer que las migraciones de la base de datos sean seguras de forma concurrente. Puede deshabilitar las cerraduras de asesoramiento configurando `advisory_locks` en `false`:

```yaml
production:
  adapter: mysql2
  advisory_locks: false
```

#### Configuración de una base de datos PostgreSQL

Si elige utilizar PostgreSQL, su `config/database.yml` se personalizará para utilizar bases de datos PostgreSQL:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: blog_development
  pool: 5
```

De forma predeterminada, Active Record utiliza características de la base de datos como declaraciones preparadas y cerraduras de asesoramiento. Es posible que deba deshabilitar esas características si está utilizando un agrupador de conexiones externo como PgBouncer:

```yaml
production:
  adapter: postgresql
  prepared_statements: false
  advisory_locks: false
```

Si está habilitado, Active Record creará hasta `1000` declaraciones preparadas por conexión de base de datos de forma predeterminada. Para modificar este comportamiento, puede establecer `statement_limit` en un valor diferente:

```yaml
production:
  adapter: postgresql
  statement_limit: 200
```

Cuantas más declaraciones preparadas se utilicen, más memoria requerirá su base de datos. Si su base de datos PostgreSQL está alcanzando los límites de memoria, intente reducir `statement_limit` o deshabilitar las declaraciones preparadas.

#### Configuración de una base de datos SQLite3 para la plataforma JRuby

Si elige utilizar SQLite3 y está utilizando JRuby, su `config/database.yml` se verá un poco diferente. Aquí está la sección de desarrollo:

```yaml
development:
  adapter: jdbcsqlite3
  database: storage/development.sqlite3
```

#### Configuración de una base de datos MySQL o MariaDB para la plataforma JRuby

Si elige utilizar MySQL o MariaDB y está utilizando JRuby, su `config/database.yml` se verá un poco diferente. Aquí está la sección de desarrollo:

```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```

#### Configuración de una base de datos PostgreSQL para la plataforma JRuby

Si elige utilizar PostgreSQL y está utilizando JRuby, su `config/database.yml` se verá un poco diferente. Aquí está la sección de desarrollo:

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

Cambie el nombre de usuario y la contraseña en la sección `development` según corresponda.

#### Configuración del almacenamiento de metadatos

De forma predeterminada, Rails almacenará información sobre su entorno y esquema de Rails en una tabla interna llamada `ar_internal_metadata`.

Para desactivar esto por conexión, configure `use_metadata_table` en su configuración de base de datos. Esto es útil cuando se trabaja con una base de datos compartida y/o un usuario de base de datos que no puede crear tablas.

```yaml
development:
  adapter: postgresql
  use_metadata_table: false
```

#### Configuración del comportamiento de reintento

De forma predeterminada, Rails se reconectará automáticamente al servidor de la base de datos y volverá a intentar ciertas consultas si algo sale mal. Solo se volverán a intentar las consultas seguras para volver a intentar (idempotentes). El número de reintentos se puede especificar en la configuración de la base de datos a través de `connection_retries`, o se puede desactivar estableciendo el valor en 0. El número predeterminado de reintentos es 1.
```yaml
development:
  adapter: mysql2
  connection_retries: 3
```

La configuración de la base de datos también permite configurar un `retry_deadline`. Si se configura un `retry_deadline`,
una consulta que de otra manera sería reintentable _no_ se volverá a intentar si ha transcurrido el tiempo especificado mientras la consulta se
intentó por primera vez. Por ejemplo, un `retry_deadline` de 5 segundos significa que si han pasado 5 segundos desde que se intentó una consulta
por primera vez, no volveremos a intentar la consulta, incluso si es idempotente y quedan `connection_retries`.

Este valor tiene un valor predeterminado de nil, lo que significa que todas las consultas reintentables se vuelven a intentar independientemente del tiempo transcurrido.
El valor para esta configuración debe especificarse en segundos.

```yaml
development:
  adapter: mysql2
  retry_deadline: 5 # Dejar de reintentar consultas después de 5 segundos
```

#### Configuración de la caché de consultas

Por defecto, Rails almacena en caché automáticamente los conjuntos de resultados devueltos por las consultas. Si Rails encuentra la misma consulta
nuevamente para esa solicitud o trabajo, utilizará el conjunto de resultados en caché en lugar de ejecutar la consulta nuevamente en
la base de datos.

La caché de consultas se almacena en memoria y, para evitar utilizar demasiada memoria, se eliminan automáticamente las consultas menos utilizadas
cuando se alcanza un umbral. Por defecto, el umbral es `100`, pero se puede configurar en el `database.yml`.

```yaml
development:
  adapter: mysql2
  query_cache: 200
```

Para desactivar por completo la caché de consultas, se puede establecer en `false`

```yaml
development:
  adapter: mysql2
  query_cache: false
```

### Creación de entornos de Rails

Por defecto, Rails se envía con tres entornos: "development", "test" y "production". Si bien estos son suficientes para la mayoría de los casos de uso, hay circunstancias en las que se desean más entornos.

Imaginemos que tenemos un servidor que refleja el entorno de producción pero que solo se utiliza para pruebas. Comúnmente, a este tipo de servidor se le llama "servidor de preparación". Para definir un entorno llamado "preparación" para este servidor, simplemente crea un archivo llamado `config/environments/staging.rb`. Dado que este es un entorno similar a producción, se pueden copiar los contenidos de `config/environments/production.rb` como punto de partida y realizar los cambios necesarios desde allí. También es posible requerir y extender otras configuraciones de entorno de esta manera:

```ruby
# config/environments/staging.rb
require_relative "production"

Rails.application.configure do
  # Anulaciones de preparación
end
```

Ese entorno no es diferente de los predeterminados, se puede iniciar un servidor con `bin/rails server -e staging`, una consola con `bin/rails console -e staging`, `Rails.env.staging?` funciona, etc.

### Implementación en un subdirectorio (raíz de URL relativa)

Por defecto, Rails espera que tu aplicación se ejecute en la raíz
(por ejemplo, `/`). Esta sección explica cómo ejecutar tu aplicación dentro de un directorio.

Supongamos que queremos implementar nuestra aplicación en "/app1". Rails necesita saber
este directorio para generar las rutas apropiadas:

```ruby
config.relative_url_root = "/app1"
```

alternativamente, se puede establecer la variable de entorno `RAILS_RELATIVE_URL_ROOT`.

Rails ahora agregará "/app1" al generar enlaces.

#### Usando Passenger

Passenger facilita la ejecución de tu aplicación en un subdirectorio. Puedes encontrar la configuración relevante en el [manual de Passenger](https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/#deploying-an-app-to-a-sub-uri-or-subdirectory).

#### Usando un proxy inverso

Implementar tu aplicación utilizando un proxy inverso tiene ventajas definidas sobre las implementaciones tradicionales. Te permiten tener más control sobre tu servidor al superponer los componentes requeridos por tu aplicación.
Muchos servidores web modernos se pueden utilizar como servidores proxy para equilibrar elementos de terceros como servidores de caché o servidores de aplicaciones.

Uno de estos servidores de aplicaciones que se puede utilizar es [Unicorn](https://bogomips.org/unicorn/) para ejecutarse detrás de un servidor proxy inverso.

En este caso, tendrías que configurar el servidor proxy (NGINX, Apache, etc.) para aceptar conexiones de tu servidor de aplicaciones (Unicorn). Por defecto, Unicorn escuchará conexiones TCP en el puerto 8080, pero puedes cambiar el puerto o configurarlo para que use sockets en su lugar.

Puedes encontrar más información en el [readme de Unicorn](https://bogomips.org/unicorn/README.html) y entender la [filosofía](https://bogomips.org/unicorn/PHILOSOPHY.html) detrás de él.

Una vez que hayas configurado el servidor de aplicaciones, debes redirigir las solicitudes a él configurando adecuadamente tu servidor web. Por ejemplo, tu configuración de NGINX puede incluir lo siguiente:

```nginx
upstream application_server {
  server 0.0.0.0:8080;
}

server {
  listen 80;
  server_name localhost;

  root /ruta/a/tu_app/public;

  try_files $uri/index.html $uri.html @app;

  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://application_server;
  }

  # alguna otra configuración
}
```

Asegúrate de leer la [documentación de NGINX](https://nginx.org/en/docs/) para obtener la información más actualizada.

Configuración del entorno de Rails
----------------------------------

Algunas partes de Rails también se pueden configurar externamente mediante variables de entorno. Las siguientes variables de entorno son reconocidas por varias partes de Rails:

* `ENV["RAILS_ENV"]` define el entorno de Rails (producción, desarrollo, prueba, etc.) en el que se ejecutará Rails.

* `ENV["RAILS_RELATIVE_URL_ROOT"]` se utiliza en el código de enrutamiento para reconocer las URL cuando [implementas tu aplicación en un subdirectorio](configuring.html#deploy-to-a-subdirectory-relative-url-root).

* `ENV["RAILS_CACHE_ID"]` y `ENV["RAILS_APP_VERSION"]` se utilizan para generar claves de caché expandidas en el código de caché de Rails. Esto te permite tener múltiples cachés separadas de la misma aplicación.

Uso de archivos de inicialización
---------------------------------

Después de cargar el framework y cualquier gema en tu aplicación, Rails procede a cargar los inicializadores. Un inicializador es cualquier archivo Ruby almacenado en `config/initializers` en tu aplicación. Puedes utilizar inicializadores para almacenar configuraciones que deben realizarse después de cargar todos los frameworks y gemas, como opciones para configurar estas partes.

Los archivos en `config/initializers` (y en cualquier subdirectorio de `config/initializers`) se ordenan y se cargan uno por uno como parte del inicializador `load_config_initializers`.

Si un inicializador tiene código que depende de otro inicializador, puedes combinarlos en un solo inicializador. Esto hace que las dependencias sean más explícitas y puede ayudar a mostrar nuevos conceptos dentro de tu aplicación. Rails también admite la numeración de los nombres de los archivos de inicialización, pero esto puede generar cambios frecuentes en los nombres de los archivos. No se recomienda cargar explícitamente los inicializadores con `require`, ya que esto hará que el inicializador se cargue dos veces.

NOTA: No hay garantía de que tus inicializadores se ejecuten después de todos los inicializadores de las gemas, por lo que cualquier código de inicialización que dependa de que una determinada gema se haya inicializado debe ir en un bloque `config.after_initialize`.

Eventos de inicialización
-------------------------

Rails tiene 5 eventos de inicialización a los que se puede acceder (enumerados en el orden en que se ejecutan):

* `before_configuration`: Se ejecuta tan pronto como la constante de la aplicación hereda de `Rails::Application`. Las llamadas a `config` se evalúan antes de que esto suceda.

* `before_initialize`: Se ejecuta justo antes de que ocurra el proceso de inicialización de la aplicación con el inicializador `:bootstrap_hook` cerca del comienzo del proceso de inicialización de Rails.
* `to_prepare`: Se ejecuta después de que se ejecuten los inicializadores de todas las Railties (incluida la aplicación en sí), pero antes de la carga ansiosa y la construcción de la pila de middleware. Más importante aún, se ejecutará en cada recarga de código en `development`, pero solo una vez (durante el inicio) en `production` y `test`.

* `before_eager_load`: Se ejecuta directamente antes de que ocurra la carga ansiosa, que es el comportamiento predeterminado para el entorno `production` y no para el entorno `development`.

* `after_initialize`: Se ejecuta directamente después de la inicialización de la aplicación, después de que se ejecuten los inicializadores de la aplicación en `config/initializers`.

Para definir un evento para estos ganchos, use la sintaxis de bloque dentro de una subclase de `Rails::Application`, `Rails::Railtie` o `Rails::Engine`:

```ruby
module YourApp
  class Application < Rails::Application
    config.before_initialize do
      # código de inicialización aquí
    end
  end
end
```

Alternativamente, también puedes hacerlo a través del método `config` en el objeto `Rails.application`:

```ruby
Rails.application.config.before_initialize do
  # código de inicialización aquí
end
```

ADVERTENCIA: Algunas partes de tu aplicación, especialmente el enrutamiento, aún no están configuradas en el punto donde se llama al bloque `after_initialize`.

### `Rails::Railtie#initializer`

Rails tiene varios inicializadores que se ejecutan al iniciar y que se definen utilizando el método `initializer` de `Rails::Railtie`. Aquí hay un ejemplo del inicializador `set_helpers_path` de Action Controller:

```ruby
initializer "action_controller.set_helpers_path" do |app|
  ActionController::Helpers.helpers_path = app.helpers_paths
end
```

El método `initializer` toma tres argumentos, siendo el primero el nombre del inicializador, el segundo un hash de opciones (no mostrado aquí) y el tercero un bloque. La clave `:before` en el hash de opciones se puede especificar para indicar qué inicializador debe ejecutarse antes de este nuevo inicializador, y la clave `:after` especificará qué inicializador ejecutar después de este inicializador.

Los inicializadores definidos utilizando el método `initializer` se ejecutarán en el orden en que se definen, con la excepción de aquellos que utilizan los métodos `:before` o `:after`.

ADVERTENCIA: Puedes colocar tu inicializador antes o después de cualquier otro inicializador en la cadena, siempre y cuando sea lógico. Digamos que tienes 4 inicializadores llamados "one" a través de "four" (definidos en ese orden) y defines que "four" vaya _antes_ de "two" pero _después_ de "three", eso simplemente no es lógico y Rails no podrá determinar el orden de tus inicializadores.

El argumento de bloque del método `initializer` es la instancia de la aplicación en sí, por lo que podemos acceder a la configuración utilizando el método `config` como se hace en el ejemplo.

Debido a que `Rails::Application` hereda de `Rails::Railtie` (indirectamente), puedes usar el método `initializer` en `config/application.rb` para definir inicializadores para la aplicación.

### Inicializadores

A continuación se muestra una lista completa de todos los inicializadores que se encuentran en Rails en el orden en que se definen (y, por lo tanto, se ejecutan, a menos que se indique lo contrario).

* `load_environment_hook`: Sirve como marcador para que se pueda definir `:load_environment_config` para que se ejecute antes.

* `load_active_support`: Requiere `active_support/dependencies`, que establece la base para Active Support. Opcionalmente requiere `active_support/all` si `config.active_support.bare` no es verdadero, que es el valor predeterminado.

* `initialize_logger`: Inicializa el registrador (un objeto `ActiveSupport::Logger`) para la aplicación y lo hace accesible en `Rails.logger`, siempre que ningún inicializador insertado antes de este punto haya definido `Rails.logger`.
* `initialize_cache`: Si `Rails.cache` aún no está configurado, inicializa la caché haciendo referencia al valor en `config.cache_store` y guarda el resultado como `Rails.cache`. Si este objeto responde al método `middleware`, su middleware se inserta antes de `Rack::Runtime` en la pila de middleware.

* `set_clear_dependencies_hook`: Este inicializador, que se ejecuta solo si `config.enable_reloading` está configurado como `true`, utiliza `ActionDispatch::Callbacks.after` para eliminar las constantes que se han referenciado durante la solicitud del espacio de objetos para que se vuelvan a cargar durante la siguiente solicitud.

* `bootstrap_hook`: Ejecuta todos los bloques configurados en `before_initialize`.

* `i18n.callbacks`: En el entorno de desarrollo, configura un callback `to_prepare` que llamará a `I18n.reload!` si alguna de las configuraciones regionales ha cambiado desde la última solicitud. En producción, este callback solo se ejecutará en la primera solicitud.

* `active_support.deprecation_behavior`: Configura el comportamiento de informe de obsolescencia para [`Rails.application.deprecators`][] basado en [`config.active_support.report_deprecations`](#config-active-support-report-deprecations), [`config.active_support.deprecation`](#config-active-support-deprecation), [`config.active_support.disallowed_deprecation`](#config-active-support-disallowed-deprecation) y [`config.active_support.disallowed_deprecation_warnings`](#config-active-support-disallowed-deprecation-warnings).

* `active_support.initialize_time_zone`: Establece la zona horaria predeterminada para la aplicación en función de la configuración `config.time_zone`, que es "UTC" de forma predeterminada.

* `active_support.initialize_beginning_of_week`: Establece el comienzo de la semana predeterminado para la aplicación en función de la configuración `config.beginning_of_week`, que es `:monday` de forma predeterminada.

* `active_support.set_configs`: Configura Active Support utilizando las configuraciones en `config.active_support` enviando los nombres de los métodos como setters a `ActiveSupport` y pasando los valores correspondientes.

* `action_dispatch.configure`: Configura `ActionDispatch::Http::URL.tld_length` para que tenga el valor de `config.action_dispatch.tld_length`.

* `action_view.set_configs`: Configura Action View utilizando las configuraciones en `config.action_view` enviando los nombres de los métodos como setters a `ActionView::Base` y pasando los valores correspondientes.

* `action_controller.assets_config`: Inicializa `config.action_controller.assets_dir` en el directorio público de la aplicación si no está configurado explícitamente.

* `action_controller.set_helpers_path`: Establece `helpers_path` de Action Controller en el `helpers_path` de la aplicación.

* `action_controller.parameters_config`: Configura las opciones de strong parameters para `ActionController::Parameters`.

* `action_controller.set_configs`: Configura Action Controller utilizando las configuraciones en `config.action_controller` enviando los nombres de los métodos como setters a `ActionController::Base` y pasando los valores correspondientes.

* `action_controller.compile_config_methods`: Inicializa los métodos para las configuraciones especificadas para que sean más rápidos de acceder.

* `active_record.initialize_timezone`: Establece `ActiveRecord::Base.time_zone_aware_attributes` en `true`, y también establece `ActiveRecord::Base.default_timezone` en UTC. Cuando se leen los atributos de la base de datos, se convertirán a la zona horaria especificada por `Time.zone`.

* `active_record.logger`: Establece `ActiveRecord::Base.logger` - si aún no está configurado - en `Rails.logger`.

* `active_record.migration_error`: Configura el middleware para verificar las migraciones pendientes.

* `active_record.check_schema_cache_dump`: Carga el volcado de la caché del esquema si está configurado y disponible.

* `active_record.warn_on_records_fetched_greater_than`: Habilita las advertencias cuando las consultas devuelven grandes cantidades de registros.

* `active_record.set_configs`: Configura Active Record utilizando las configuraciones en `config.active_record` enviando los nombres de los métodos como setters a `ActiveRecord::Base` y pasando los valores correspondientes.

* `active_record.initialize_database`: Carga la configuración de la base de datos (por defecto) desde `config/database.yml` y establece una conexión para el entorno actual.

* `active_record.log_runtime`: Incluye `ActiveRecord::Railties::ControllerRuntime` y `ActiveRecord::Railties::JobRuntime`, que son responsables de informar al registrador sobre el tiempo que llevan las llamadas de Active Record para la solicitud.

* `active_record.set_reloader_hooks`: Restablece todas las conexiones recargables a la base de datos si `config.enable_reloading` está configurado como `true`.

* `active_record.add_watchable_files`: Agrega los archivos `schema.rb` y `structure.sql` a los archivos observables.

* `active_job.logger`: Establece `ActiveJob::Base.logger` - si aún no está configurado - en `Rails.logger`.
* `active_job.set_configs`: Configura Active Job utilizando los ajustes en `config.active_job` enviando los nombres de los métodos como setters a `ActiveJob::Base` y pasando los valores correspondientes.

* `action_mailer.logger`: Configura `ActionMailer::Base.logger` - si aún no está configurado - a `Rails.logger`.

* `action_mailer.set_configs`: Configura Action Mailer utilizando los ajustes en `config.action_mailer` enviando los nombres de los métodos como setters a `ActionMailer::Base` y pasando los valores correspondientes.

* `action_mailer.compile_config_methods`: Inicializa los métodos para las configuraciones especificadas para que sean más rápidos de acceder.

* `set_load_path`: Este inicializador se ejecuta antes de `bootstrap_hook`. Agrega las rutas especificadas en `config.load_paths` y todas las rutas de carga automática a `$LOAD_PATH`.

* `set_autoload_paths`: Este inicializador se ejecuta antes de `bootstrap_hook`. Agrega todos los subdirectorios de `app` y las rutas especificadas en `config.autoload_paths`, `config.eager_load_paths` y `config.autoload_once_paths` a `ActiveSupport::Dependencies.autoload_paths`.

* `add_routing_paths`: Carga (por defecto) todos los archivos `config/routes.rb` (en la aplicación y en los railties, incluyendo los motores) y configura las rutas para la aplicación.

* `add_locales`: Agrega los archivos en `config/locales` (de la aplicación, los railties y los motores) a `I18n.load_path`, haciendo disponibles las traducciones en estos archivos.

* `add_view_paths`: Agrega el directorio `app/views` de la aplicación, los railties y los motores a la ruta de búsqueda de archivos de vista para la aplicación.

* `add_mailer_preview_paths`: Agrega el directorio `test/mailers/previews` de la aplicación, los railties y los motores a la ruta de búsqueda de archivos de vista previa de correos para la aplicación.

* `load_environment_config`: Este inicializador se ejecuta antes de `load_environment_hook`. Carga el archivo `config/environments` correspondiente al entorno actual.

* `prepend_helpers_path`: Agrega el directorio `app/helpers` de la aplicación, los railties y los motores a la ruta de búsqueda de helpers para la aplicación.

* `load_config_initializers`: Carga todos los archivos Ruby de `config/initializers` en la aplicación, los railties y los motores. Los archivos en este directorio se pueden utilizar para almacenar configuraciones que deben realizarse después de que se carguen todos los frameworks.

* `engines_blank_point`: Proporciona un punto de inicialización para conectarse si se desea hacer algo antes de que se carguen los motores. Después de este punto, se ejecutan todos los inicializadores de railtie y motor.

* `add_generator_templates`: Encuentra las plantillas para los generadores en `lib/templates` de la aplicación, los railties y los motores, y las agrega a la configuración `config.generators.templates`, lo que permitirá que las plantillas estén disponibles para todos los generadores.

* `ensure_autoload_once_paths_as_subset`: Asegura que `config.autoload_once_paths` solo contenga rutas de `config.autoload_paths`. Si contiene rutas adicionales, se generará una excepción.

* `add_to_prepare_blocks`: Agrega el bloque para cada llamada a `config.to_prepare` en la aplicación, un railtie o un motor a los callbacks `to_prepare` de Action Dispatch, que se ejecutarán por solicitud en desarrollo o antes de la primera solicitud en producción.

* `add_builtin_route`: Si la aplicación se está ejecutando en el entorno de desarrollo, esto agregará la ruta para `rails/info/properties` a las rutas de la aplicación. Esta ruta proporciona información detallada como la versión de Rails y Ruby para `public/index.html` en una aplicación Rails por defecto.

* `build_middleware_stack`: Construye la pila de middleware para la aplicación, devolviendo un objeto que tiene un método `call` que recibe un objeto de entorno Rack para la solicitud.

* `eager_load!`: Si `config.eager_load` es `true`, ejecuta los hooks `config.before_eager_load` y luego llama a `eager_load!`, que cargará todos los `config.eager_load_namespaces`.

* `finisher_hook`: Proporciona un hook después de que se haya completado el proceso de inicialización de la aplicación, así como ejecutar todos los bloques `config.after_initialize` de la aplicación, los railties y los motores.
* `set_routes_reloader_hook`: Configura Action Dispatch para recargar el archivo de rutas utilizando `ActiveSupport::Callbacks.to_run`.

* `disable_dependency_loading`: Desactiva la carga automática de dependencias si `config.eager_load` está configurado como `true`.


Agrupación de la base de datos
----------------

Las conexiones de base de datos de Active Record son gestionadas por `ActiveRecord::ConnectionAdapters::ConnectionPool`, que garantiza que un grupo de conexiones de base de datos limite la cantidad de acceso de hilos. Este límite tiene un valor predeterminado de 5 y se puede configurar en `database.yml`.

```ruby
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

Dado que la agrupación de conexiones se maneja dentro de Active Record de forma predeterminada, todos los servidores de aplicaciones (Thin, Puma, Unicorn, etc.) deberían comportarse de la misma manera. El grupo de conexiones de base de datos está inicialmente vacío. A medida que aumenta la demanda de conexiones, se crearán nuevas conexiones hasta alcanzar el límite del grupo de conexiones.

Cada solicitud tomará una conexión la primera vez que requiera acceso a la base de datos. Al final de la solicitud, devolverá la conexión. Esto significa que la ranura de conexión adicional estará disponible nuevamente para la siguiente solicitud en la cola.

Si intentas utilizar más conexiones de las disponibles, Active Record te bloqueará y esperará una conexión del grupo. Si no puede obtener una conexión, se lanzará un error de tiempo de espera similar al siguiente:

```ruby
ActiveRecord::ConnectionTimeoutError - no se pudo obtener una conexión de base de datos en 5.000 segundos (esperó 5.000 segundos)
```

Si obtienes el error anterior, es posible que desees aumentar el tamaño del grupo de conexiones incrementando la opción `pool` en `database.yml`.

NOTA. Si estás ejecutando en un entorno multihilo, puede haber varias posibilidades de que varios hilos accedan a múltiples conexiones simultáneamente. Por lo tanto, dependiendo de la carga actual de solicitudes, es posible que varios hilos compitan por un número limitado de conexiones.


Configuración personalizada
--------------------

Puedes configurar tu propio código a través del objeto de configuración de Rails con configuraciones personalizadas en el espacio de nombres `config.x` o directamente en `config`. La diferencia clave entre estos dos es que debes usar `config.x` si estás definiendo una configuración _anidada_ (por ejemplo, `config.x.nested.hi`) y solo `config` para una configuración de _un solo nivel_ (por ejemplo, `config.hello`).

```ruby
config.x.payment_processing.schedule = :daily
config.x.payment_processing.retries  = 3
config.super_debugger = true
```

Estos puntos de configuración están disponibles a través del objeto de configuración:

```ruby
Rails.configuration.x.payment_processing.schedule # => :daily
Rails.configuration.x.payment_processing.retries  # => 3
Rails.configuration.x.payment_processing.not_set  # => nil
Rails.configuration.super_debugger                # => true
```

También puedes usar `Rails::Application.config_for` para cargar archivos de configuración completos:

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
Rails.configuration.payment['merchant_id'] # => production_merchant_id o development_merchant_id
```

`Rails::Application.config_for` admite una configuración `shared` para agrupar configuraciones comunes. La configuración compartida se fusionará con la configuración del entorno.

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
# entorno de desarrollo
Rails.application.config_for(:example)[:foo][:bar] #=> { baz: 1, qux: 2 }
```

Indexación de motores de búsqueda
-----------------------

A veces, es posible que desees evitar que algunas páginas de tu aplicación sean visibles en sitios de búsqueda como Google, Bing, Yahoo o Duck Duck Go. Los robots que indexan estos sitios primero analizarán el archivo `http://tu-sitio.com/robots.txt` para saber qué páginas se les permite indexar.
Rails crea este archivo para ti dentro de la carpeta `/public`. Por defecto, permite que los motores de búsqueda indexen todas las páginas de tu aplicación. Si quieres bloquear la indexación en todas las páginas de tu aplicación, utiliza esto:

```
User-agent: *
Disallow: /
```

Para bloquear solo páginas específicas, es necesario utilizar una sintaxis más compleja. Aprende más en la [documentación oficial](https://www.robotstxt.org/robotstxt.html).

Monitor de sistema de archivos con eventos
------------------------------------------

Si se carga la gema [listen](https://github.com/guard/listen), Rails utiliza un monitor de sistema de archivos con eventos para detectar cambios cuando la recarga está habilitada:

```ruby
group :development do
  gem 'listen', '~> 3.3'
end
```

De lo contrario, en cada solicitud, Rails recorre el árbol de la aplicación para verificar si algo ha cambiado.

En Linux y macOS no se necesitan gemas adicionales, pero se requieren algunas [para *BSD](https://github.com/guard/listen#on-bsd) y [para Windows](https://github.com/guard/listen#on-windows).

Ten en cuenta que [algunas configuraciones no son compatibles](https://github.com/guard/listen#issues--limitations).
[`config.load_defaults`]: https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults
[`ActiveSupport::ParameterFilter.precompile_filters`]: https://api.rubyonrails.org/classes/ActiveSupport/ParameterFilter.html#method-c-precompile_filters
[ActiveModel::Error#full_message]: https://api.rubyonrails.org/classes/ActiveModel/Error.html#method-i-full_message
[`ActiveSupport::MessageEncryptor`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html
[`ActiveSupport::MessageVerifier`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html
[`message_serializer_fallback.active_support`]: active_support_instrumentation.html#message-serializer-fallback-active-support
[`Rails.application.deprecators`]: https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators
