**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bba7dd6e311e7abd59e434f12dbebd0e
Configurando Aplicações Rails
==============================

Este guia aborda as configurações e recursos de inicialização disponíveis para aplicações Rails.

Após ler este guia, você saberá:

* Como ajustar o comportamento das suas aplicações Rails.
* Como adicionar código adicional para ser executado no momento de inicialização da aplicação.

--------------------------------------------------------------------------------

Locais para Código de Inicialização
----------------------------------

O Rails oferece quatro locais padrão para colocar código de inicialização:

* `config/application.rb`
* Arquivos de configuração específicos do ambiente
* Inicializadores
* Pós-inicializadores

Executando Código Antes do Rails
-------------------------------

No caso raro de sua aplicação precisar executar algum código antes do próprio Rails ser carregado, coloque-o acima da chamada para `require "rails/all"` no arquivo `config/application.rb`.

Configurando Componentes do Rails
--------------------------------

Em geral, o trabalho de configuração do Rails significa configurar os componentes do Rails, bem como configurar o próprio Rails. O arquivo de configuração `config/application.rb` e os arquivos de configuração específicos do ambiente (como `config/environments/production.rb`) permitem que você especifique as várias configurações que deseja passar para todos os componentes.

Por exemplo, você pode adicionar esta configuração ao arquivo `config/application.rb`:

```ruby
config.time_zone = 'Central Time (US & Canada)'
```

Esta é uma configuração para o próprio Rails. Se você deseja passar configurações para componentes individuais do Rails, pode fazer isso por meio do mesmo objeto `config` em `config/application.rb`:

```ruby
config.active_record.schema_format = :ruby
```

O Rails usará essa configuração específica para configurar o Active Record.

AVISO: Use os métodos de configuração públicos em vez de chamar diretamente a classe associada. Por exemplo, use `Rails.application.config.action_mailer.options` em vez de `ActionMailer::Base.options`.

NOTA: Se você precisar aplicar configuração diretamente a uma classe, use um [gancho de carregamento preguiçoso](https://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html) em um inicializador para evitar o carregamento automático da classe antes que a inicialização seja concluída. Isso irá quebrar porque o carregamento automático durante a inicialização não pode ser repetido com segurança quando a aplicação é recarregada.

### Valores Padrão Versionados

[`config.load_defaults`] carrega valores padrão de configuração para uma versão de destino e todas as versões anteriores. Por exemplo, `config.load_defaults 6.1` carregará os padrões para todas as versões até e incluindo a versão 6.1.


Abaixo estão os valores padrão associados a cada versão de destino. Em casos de valores conflitantes, as versões mais recentes têm precedência sobre as versões mais antigas.

#### Valores Padrão para a Versão de Destino 7.1

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

#### Valores Padrão para a Versão de Destino 7.0

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
#### Valores Padrão para a Versão de Destino 6.1

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

#### Valores Padrão para a Versão de Destino 6.0

- [`config.action_dispatch.use_cookies_with_metadata`](#config-action-dispatch-use-cookies-with-metadata): `true`
- [`config.action_mailer.delivery_job`](#config-action-mailer-delivery-job): `"ActionMailer::MailDeliveryJob"`
- [`config.action_view.default_enforce_utf8`](#config-action-view-default-enforce-utf8): `false`
- [`config.active_record.collection_cache_versioning`](#config-active-record-collection-cache-versioning): `true`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `:active_storage_analysis`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `:active_storage_purge`

#### Valores Padrão para a Versão de Destino 5.2

- [`config.action_controller.default_protect_from_forgery`](#config-action-controller-default-protect-from-forgery): `true`
- [`config.action_dispatch.use_authenticated_cookie_encryption`](#config-action-dispatch-use-authenticated-cookie-encryption): `true`
- [`config.action_view.form_with_generates_ids`](#config-action-view-form-with-generates-ids): `true`
- [`config.active_record.cache_versioning`](#config-active-record-cache-versioning): `true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA1`
- [`config.active_support.use_authenticated_message_encryption`](#config-active-support-use-authenticated-message-encryption): `true`

#### Valores Padrão para a Versão de Destino 5.1

- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `true`
- [`config.assets.unknown_asset_fallback`](#config-assets-unknown-asset-fallback): `false`

#### Valores Padrão para a Versão de Destino 5.0

- [`ActiveSupport.to_time_preserves_timezone`](#activesupport-to-time-preserves-timezone): `true`
- [`config.action_controller.forgery_protection_origin_check`](#config-action-controller-forgery-protection-origin-check): `true`
- [`config.action_controller.per_form_csrf_tokens`](#config-action-controller-per-form-csrf-tokens): `true`
- [`config.active_record.belongs_to_required_by_default`](#config-active-record-belongs-to-required-by-default): `true`
- [`config.ssl_options`](#config-ssl-options): `{ hsts: { subdomains: true } }`

### Configuração Geral do Rails

Os seguintes métodos de configuração devem ser chamados em um objeto `Rails::Railtie`, como uma subclasse de `Rails::Engine` ou `Rails::Application`.

#### `config.add_autoload_paths_to_load_path`

Indica se os caminhos de autoload devem ser adicionados ao `$LOAD_PATH`. É recomendado definir como `false` no modo `:zeitwerk` cedo, no arquivo `config/application.rb`. O Zeitwerk usa caminhos absolutos internamente e aplicações em modo `:zeitwerk` não precisam de `require_dependency`, então modelos, controladores, jobs, etc. não precisam estar em `$LOAD_PATH`. Definir isso como `false` economiza tempo de verificação desses diretórios pelo Ruby ao resolver chamadas de `require` com caminhos relativos, além de economizar trabalho e RAM do Bootsnap, já que ele não precisa construir um índice para eles.

O valor padrão depende da versão de destino definida em `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `true`           |
| 7.1                | `false`          |

O diretório `lib` não é afetado por essa configuração, ele é sempre adicionado ao `$LOAD_PATH`.

#### `config.after_initialize`

Aceita um bloco que será executado _após_ o Rails terminar de inicializar a aplicação. Isso inclui a inicialização do próprio framework, engines e todos os inicializadores da aplicação em `config/initializers`. Note que esse bloco _será_ executado para tarefas do rake. Útil para configurar valores definidos por outros inicializadores:

```ruby
config.after_initialize do
  ActionView::Base.sanitized_allowed_tags.delete 'div'
end
```

#### `config.after_routes_loaded`

Aceita um bloco que será executado após o Rails terminar de carregar as rotas da aplicação. Esse bloco também será executado sempre que as rotas forem recarregadas.

```ruby
config.after_routes_loaded do
  # Código que faz algo com Rails.application.routes
end
```

#### `config.allow_concurrency`

Controla se as requisições devem ser tratadas de forma concorrente. Isso só deve ser definido como `false` se o código da aplicação não for thread-safe. O valor padrão é `true`.

#### `config.asset_host`

Define o host para os assets. Útil quando CDNs são usadas para hospedar os assets, ou quando você deseja contornar as restrições de concorrência incorporadas nos navegadores usando aliases de domínio diferentes. Versão abreviada de `config.action_controller.asset_host`.

#### `config.assume_ssl`

Faz a aplicação acreditar que todas as requisições estão chegando por SSL. Isso é útil quando há um proxy que termina o SSL e a requisição encaminhada parece ser HTTP em vez de HTTPS para a aplicação. Isso faz com que redirecionamentos e segurança de cookies sejam direcionados para HTTP em vez de HTTPS. Esse middleware faz com que o servidor assuma que o proxy já terminou o SSL e que a requisição realmente é HTTPS.
#### `config.autoflush_log`

Habilita a gravação imediata do arquivo de log em vez de fazer buffering. O padrão é `true`.

#### `config.autoload_once_paths`

Aceita um array de caminhos dos quais o Rails carregará constantes que não serão apagadas por requisição. É relevante se a recarga estiver habilitada, o que é o padrão no ambiente `development`. Caso contrário, o carregamento automático acontece apenas uma vez. Todos os elementos deste array também devem estar em `autoload_paths`. O padrão é um array vazio.

#### `config.autoload_paths`

Aceita um array de caminhos dos quais o Rails carregará constantes. O padrão é um array vazio. Desde o [Rails 6](upgrading_ruby_on_rails.html#autoloading), não é recomendado ajustar isso. Veja [Carregamento Automático e Recarga de Constantes](autoloading_and_reloading_constants.html#autoload-paths).

#### `config.autoload_lib(ignore:)`

Este método adiciona `lib` a `config.autoload_paths` e `config.eager_load_paths`.

Normalmente, o diretório `lib` possui subdiretórios que não devem ser carregados automaticamente ou carregados imediatamente. Por favor, passe o nome deles em relação a `lib` no argumento de palavra-chave `ignore` necessário. Por exemplo,

```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

Por favor, veja mais detalhes no [guia de carregamento automático](autoloading_and_reloading_constants.html).

#### `config.autoload_lib_once(ignore:)`

O método `config.autoload_lib_once` é similar ao `config.autoload_lib`, exceto que ele adiciona `lib` a `config.autoload_once_paths` em vez disso.

Ao chamar `config.autoload_lib_once`, classes e módulos em `lib` podem ser carregados automaticamente, mesmo a partir de inicializadores de aplicação, mas não serão recarregados.

#### `config.beginning_of_week`

Define o início padrão da semana para a aplicação. Aceita um dia válido da semana como um símbolo (por exemplo, `:monday`).

#### `config.cache_classes`

Configuração antiga equivalente a `!config.enable_reloading`. Suportada por compatibilidade com versões anteriores.

#### `config.cache_store`

Configura qual cache store usar para o cache do Rails. As opções incluem um dos símbolos `:memory_store`, `:file_store`, `:mem_cache_store`, `:null_store`, `:redis_cache_store`, ou um objeto que implementa a API de cache. O padrão é `:file_store`. Veja [Cache Stores](caching_with_rails.html#cache-stores) para opções de configuração por store.

#### `config.colorize_logging`

Especifica se deve ou não usar códigos de cor ANSI ao registrar informações. O padrão é `true`.

#### `config.consider_all_requests_local`

É uma flag. Se for `true`, qualquer erro causará a exibição de informações detalhadas de depuração na resposta HTTP, e o controlador `Rails::Info` mostrará o contexto de execução da aplicação em `/rails/info/properties`. Por padrão, é `true` nos ambientes de desenvolvimento e teste, e `false` em produção. Para um controle mais refinado, defina isso como `false` e implemente `show_detailed_exceptions?` nos controladores para especificar quais requisições devem fornecer informações de depuração em caso de erros.

#### `config.console`

Permite definir a classe que será usada como console quando você executar `bin/rails console`. É melhor executá-lo no bloco `console`:

```ruby
console do
  # este bloco é chamado apenas ao executar o console,
  # então podemos exigir com segurança o pry aqui
  require "pry"
  config.console = Pry
end
```

#### `config.content_security_policy_nonce_directives`

Veja [Adicionando um Nonce](security.html#adding-a-nonce) no Guia de Segurança

#### `config.content_security_policy_nonce_generator`

Veja [Adicionando um Nonce](security.html#adding-a-nonce) no Guia de Segurança

#### `config.content_security_policy_report_only`

Veja [Relatando Violações](security.html#reporting-violations) no Guia de Segurança

#### `config.credentials.content_path`

O caminho do arquivo de credenciais criptografado.

O padrão é `config/credentials/#{Rails.env}.yml.enc` se existir, ou
`config/credentials.yml.enc` caso contrário.

NOTA: Para que os comandos `bin/rails credentials` reconheçam esse valor,
ele deve ser definido em `config/application.rb` ou `config/environments/#{Rails.env}.rb`.

#### `config.credentials.key_path`

O caminho do arquivo de chave de credenciais criptografado.

O padrão é `config/credentials/#{Rails.env}.key` se existir, ou
`config/master.key` caso contrário.

NOTA: Para que os comandos `bin/rails credentials` reconheçam esse valor,
ele deve ser definido em `config/application.rb` ou `config/environments/#{Rails.env}.rb`.
#### `config.debug_exception_response_format`

Define o formato usado nas respostas quando ocorrem erros no ambiente de desenvolvimento. O padrão é `:api` para aplicativos apenas de API e `:default` para aplicativos normais.

#### `config.disable_sandbox`

Controla se alguém pode ou não iniciar um console no modo sandbox. Isso é útil para evitar uma sessão de console sandbox em execução por muito tempo, o que poderia levar um servidor de banco de dados a ficar sem memória. O padrão é `false`.

#### `config.eager_load`

Quando `true`, carrega antecipadamente todos os `config.eager_load_namespaces` registrados. Isso inclui sua aplicação, engines, frameworks do Rails e qualquer outro namespace registrado.

#### `config.eager_load_namespaces`

Registra namespaces que são carregados antecipadamente quando `config.eager_load` é definido como `true`. Todos os namespaces na lista devem responder ao método `eager_load!`.

#### `config.eager_load_paths`

Aceita uma matriz de caminhos dos quais o Rails carregará antecipadamente na inicialização se `config.eager_load` for verdadeiro. O padrão é todas as pastas no diretório `app` da aplicação.

#### `config.enable_reloading`

Se `config.enable_reloading` for verdadeiro, as classes e módulos da aplicação são recarregados entre as solicitações da web se houver alterações. O padrão é `true` no ambiente `development` e `false` no ambiente `production`.

O predicado `config.reloading_enabled?` também é definido.

#### `config.encoding`

Configura a codificação em toda a aplicação. O padrão é UTF-8.

#### `config.exceptions_app`

Define a aplicação de exceções invocada pelo middleware `ShowException` quando ocorre uma exceção. O padrão é `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

As aplicações de exceções precisam lidar com erros `ActionDispatch::Http::MimeNegotiation::InvalidType`, que são gerados quando um cliente envia um cabeçalho `Accept` ou `Content-Type` inválido.
A aplicação padrão `ActionDispatch::PublicExceptions` faz isso automaticamente, definindo `Content-Type` como `text/html` e retornando um status `406 Not Acceptable`.
Falha em lidar com esse erro resultará em um `500 Internal Server Error`.

Usar o `Rails.application.routes` `RouteSet` como aplicação de exceções também requer esse tratamento especial.
Pode ser algo parecido com isso:

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

É a classe usada para detectar atualizações de arquivos no sistema de arquivos quando `config.reload_classes_only_on_change` é `true`. O Rails vem com `ActiveSupport::FileUpdateChecker`, o padrão, e `ActiveSupport::EventedFileUpdateChecker` (este depende da gem [listen](https://github.com/guard/listen)). Classes personalizadas devem seguir a API `ActiveSupport::FileUpdateChecker`.

#### `config.filter_parameters`

Usado para filtrar os parâmetros que você não deseja mostrar nos logs, como senhas ou números de cartão de crédito. Também filtra valores sensíveis de colunas do banco de dados ao chamar `#inspect` em um objeto Active Record. Por padrão, o Rails filtra senhas adicionando os seguintes filtros em `config/initializers/filter_parameter_logging.rb`.

```ruby
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

O filtro de parâmetros funciona por correspondência parcial de expressões regulares.

#### `config.filter_redirect`

Usado para filtrar URLs de redirecionamento nos logs da aplicação.

```ruby
Rails.application.config.filter_redirect += ['s3.amazonaws.com', /private-match/]
```

O filtro de redirecionamento funciona testando se as URLs incluem strings ou correspondem a expressões regulares.

#### `config.force_ssl`

Força todas as solicitações a serem servidas por HTTPS e define "https://" como o protocolo padrão ao gerar URLs. A aplicação do HTTPS é tratada pelo middleware `ActionDispatch::SSL`, que pode ser configurado por meio de `config.ssl_options`.

#### `config.helpers_paths`
Define um array de caminhos adicionais para carregar ajudantes de visualização.

#### `config.host_authorization`

Aceita um hash de opções para configurar o middleware [HostAuthorization](#actiondispatch-hostauthorization).

#### `config.hosts`

Um array de strings, expressões regulares ou `IPAddr` usados para validar o cabeçalho `Host`. Usado pelo middleware [HostAuthorization](#actiondispatch-hostauthorization) para ajudar a prevenir ataques de rebinding DNS.

#### `config.javascript_path`

Define o caminho onde o JavaScript do seu aplicativo está localizado em relação ao diretório `app`. O padrão é `javascript`, usado pelo [webpacker](https://github.com/rails/webpacker). O `javascript_path` configurado de um aplicativo será excluído dos `autoload_paths`.

#### `config.log_file_size`

Define o tamanho máximo do arquivo de log do Rails em bytes. O padrão é `104_857_600` (100 MiB) em desenvolvimento e teste, e ilimitado em todos os outros ambientes.

#### `config.log_formatter`

Define o formatador do logger do Rails. Esta opção tem como padrão uma instância de `ActiveSupport::Logger::SimpleFormatter` para todos os ambientes. Se você estiver definindo um valor para `config.logger`, você deve passar manualmente o valor do seu formatador para o seu logger antes que ele seja envolvido em uma instância de `ActiveSupport::TaggedLogging`, o Rails não fará isso por você.

#### `config.log_level`

Define a verbosidade do logger do Rails. Esta opção tem como padrão `:debug` para todos os ambientes, exceto produção, onde tem como padrão `:info`. Os níveis de log disponíveis são: `:debug`, `:info`, `:warn`, `:error`, `:fatal` e `:unknown`.

#### `config.log_tags`

Aceita uma lista de métodos aos quais o objeto `request` responde, um `Proc` que aceita o objeto `request` ou algo que responda a `to_s`. Isso facilita a marcação de linhas de log com informações de depuração, como subdomínio e ID de solicitação - ambos muito úteis na depuração de aplicativos de produção multiusuário.

#### `config.logger`

É o logger que será usado para `Rails.logger` e qualquer outro log relacionado ao Rails, como `ActiveRecord::Base.logger`. O padrão é uma instância de `ActiveSupport::TaggedLogging` que envolve uma instância de `ActiveSupport::Logger` que gera um log para o diretório `log/`. Você pode fornecer um logger personalizado, para obter compatibilidade total, você deve seguir estas diretrizes:

* Para suportar um formatador, você deve atribuir manualmente um formatador do valor `config.log_formatter` ao logger.
* Para suportar logs marcados, a instância de log deve ser envolvida com `ActiveSupport::TaggedLogging`.
* Para suportar o silenciamento, o logger deve incluir o módulo `ActiveSupport::LoggerSilence`. A classe `ActiveSupport::Logger` já inclui esses módulos.

```ruby
class MyLogger < ::Logger
  include ActiveSupport::LoggerSilence
end

mylogger           = MyLogger.new(STDOUT)
mylogger.formatter = config.log_formatter
config.logger      = ActiveSupport::TaggedLogging.new(mylogger)
```

#### `config.middleware`

Permite configurar o middleware da aplicação. Isso é abordado em detalhes na seção [Configurando o Middleware](#configuring-middleware) abaixo.

#### `config.precompile_filter_parameters`

Quando `true`, irá pré-compilar [`config.filter_parameters`](#config-filter-parameters) usando [`ActiveSupport::ParameterFilter.precompile_filters`][].

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.1                | `true`           |


#### `config.public_file_server.enabled`

Configura o Rails para servir arquivos estáticos do diretório `public`. Esta opção tem como padrão `true`, mas no ambiente de produção é definida como `false`, porque o software do servidor (por exemplo, NGINX ou Apache) usado para executar a aplicação deve servir arquivos estáticos. Se você estiver executando ou testando seu aplicativo em produção usando o WEBrick (não é recomendado usar o WEBrick em produção), defina a opção como `true`. Caso contrário, você não poderá usar o cache de página e solicitar arquivos que existem no diretório `public`.
#### `config.railties_order`

Permite especificar manualmente a ordem em que as Railties/Engines são carregadas. O valor padrão é `[:all]`.

```ruby
config.railties_order = [Blog::Engine, :main_app, :all]
```

#### `config.rake_eager_load`

Quando `true`, carrega antecipadamente a aplicação ao executar tarefas Rake. O valor padrão é `false`.

#### `config.read_encrypted_secrets`

*DEPRECIADO*: Você deve usar
[credentials](https://guides.rubyonrails.org/security.html#custom-credentials)
em vez de secrets criptografados.

Quando `true`, tentará ler secrets criptografados de `config/secrets.yml.enc`

#### `config.relative_url_root`

Pode ser usado para informar ao Rails que você está [implantando em um subdiretório](
configuring.html#deploy-to-a-subdirectory-relative-url-root). O valor padrão é `ENV['RAILS_RELATIVE_URL_ROOT']`.

#### `config.reload_classes_only_on_change`

Habilita ou desabilita o recarregamento de classes apenas quando arquivos rastreados são alterados. Por padrão, rastreia tudo nos caminhos de autoload e é definido como `true`. Se `config.enable_reloading` for `false`, essa opção é ignorada.

#### `config.require_master_key`

Faz com que a aplicação não inicialize se uma chave mestra não estiver disponível por meio de `ENV["RAILS_MASTER_KEY"]` ou do arquivo `config/master.key`.

#### `config.secret_key_base`

A alternativa para especificar a chave de entrada para o gerador de chave de uma aplicação.
Recomenda-se deixar isso não definido e, em vez disso, especificar um `secret_key_base`
em `config/credentials.yml.enc`. Consulte a documentação da API [`secret_key_base`](
https://api.rubyonrails.org/classes/Rails/Application.html#method-i-secret_key_base)
para obter mais informações e métodos de configuração alternativos.

#### `config.server_timing`

Quando `true`, adiciona o [middleware ServerTiming](#actiondispatch-servertiming)
à pilha de middlewares.

#### `config.session_options`

Opções adicionais passadas para `config.session_store`. Você deve usar
`config.session_store` para definir isso em vez de modificá-lo manualmente.

```ruby
config.session_store :cookie_store, key: "_your_app_session"
config.session_options # => {key: "_your_app_session"}
```

#### `config.session_store`

Especifica qual classe usar para armazenar a sessão. Os valores possíveis são `:cache_store`, `:cookie_store`, `:mem_cache_store`, um armazenamento personalizado ou `:disabled`. `:disabled` informa ao Rails para não lidar com sessões.

Essa configuração é feita por meio de uma chamada de método regular, em vez de um setter. Isso permite que opções adicionais sejam passadas:

```ruby
config.session_store :cookie_store, key: "_your_app_session"
```

Se um armazenamento personalizado for especificado como um símbolo, ele será resolvido para o namespace `ActionDispatch::Session`:

```ruby
# use ActionDispatch::Session::MyCustomStore como armazenamento de sessão
config.session_store :my_custom_store
```

O armazenamento padrão é um armazenamento de cookie com o nome da aplicação como chave de sessão.

#### `config.ssl_options`

Opções de configuração para o middleware [`ActionDispatch::SSL`](https://api.rubyonrails.org/classes/ActionDispatch/SSL.html).

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `{}`             |
| 5.0                | `{ hsts: { subdomains: true } }` |

#### `config.time_zone`

Define o fuso horário padrão para a aplicação e habilita a conscientização do fuso horário para o Active Record.

#### `config.x`

Usado para adicionar facilmente uma configuração personalizada aninhada ao objeto de configuração da aplicação.

  ```ruby
  config.x.payment_processing.schedule = :daily
  Rails.configuration.x.payment_processing.schedule # => :daily
  ```

Consulte [Configuração Personalizada](#custom-configuration)

### Configurando Ativos

#### `config.assets.css_compressor`

Define o compressor CSS a ser usado. É definido por padrão pelo `sass-rails`. O único valor alternativo no momento é `:yui`, que usa a gem `yui-compressor`.

#### `config.assets.js_compressor`

Define o compressor JavaScript a ser usado. Os valores possíveis são `:terser`, `:closure`, `:uglifier` e `:yui`, que requerem o uso das gems `terser`, `closure-compiler`, `uglifier` ou `yui-compressor`, respectivamente.

#### `config.assets.gzip`

Uma flag que habilita a criação de uma versão compactada dos ativos compilados, juntamente com os ativos não compactados. Definido como `true` por padrão.

#### `config.assets.paths`

Contém os caminhos que são usados para procurar ativos. Adicionar caminhos a essa opção de configuração fará com que esses caminhos sejam usados na busca por ativos.
#### `config.assets.precompile`

Permite especificar ativos adicionais (além de `application.css` e `application.js`) que devem ser pré-compilados quando `bin/rails assets:precompile` é executado.

#### `config.assets.unknown_asset_fallback`

Permite modificar o comportamento do pipeline de ativos quando um ativo não está no pipeline, se você estiver usando sprockets-rails 3.2.0 ou mais recente.

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `true`           |
| 5.1                | `false`          |

#### `config.assets.prefix`

Define o prefixo de onde os ativos são servidos. Padrão é `/assets`.

#### `config.assets.manifest`

Define o caminho completo a ser usado para o arquivo de manifesto do pré-compilador de ativos. Padrão é um arquivo chamado `manifest-<random>.json` no diretório `config.assets.prefix` dentro da pasta public.

#### `config.assets.digest`

Habilita o uso de impressões digitais SHA256 nos nomes dos ativos. Padrão é `true`.

#### `config.assets.debug`

Desabilita a concatenação e compressão de ativos. Padrão é `true` em `development.rb`.

#### `config.assets.version`

É uma string de opção que é usada na geração de hash SHA256. Isso pode ser alterado para forçar a recompilação de todos os arquivos.

#### `config.assets.compile`

É um booleano que pode ser usado para ativar a compilação ao vivo do Sprockets em produção.

#### `config.assets.logger`

Aceita um logger que segue a interface do Log4r ou a classe Ruby `Logger` padrão. Padrão é o mesmo configurado em `config.logger`. Definir `config.assets.logger` como `false` desativará o registro de ativos servidos.

#### `config.assets.quiet`

Desabilita o registro de solicitações de ativos. Padrão é `true` em `development.rb`.

### Configurando Geradores

O Rails permite alterar quais geradores são usados com o método `config.generators`. Este método recebe um bloco:

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

O conjunto completo de métodos que podem ser usados neste bloco são os seguintes:

* `force_plural` permite nomes de modelos no plural. Padrão é `false`.
* `helper` define se deve gerar helpers ou não. Padrão é `true`.
* `integration_tool` define qual ferramenta de integração usar para gerar testes de integração. Padrão é `:test_unit`.
* `system_tests` define qual ferramenta de integração usar para gerar testes de sistema. Padrão é `:test_unit`.
* `orm` define qual ORM usar. Padrão é `false` e usará o Active Record por padrão.
* `resource_controller` define qual gerador usar para gerar um controlador ao usar `bin/rails generate resource`. Padrão é `:controller`.
* `resource_route` define se uma definição de rota de recurso deve ser gerada ou não. Padrão é `true`.
* `scaffold_controller` diferente de `resource_controller`, define qual gerador usar para gerar um controlador _scaffolded_ ao usar `bin/rails generate scaffold`. Padrão é `:scaffold_controller`.
* `test_framework` define qual framework de teste usar. Padrão é `false` e usará o minitest por padrão.
* `template_engine` define qual mecanismo de template usar, como ERB ou Haml. Padrão é `:erb`.

### Configurando Middleware

Toda aplicação Rails vem com um conjunto padrão de middleware que é usado nesta ordem no ambiente de desenvolvimento:

#### `ActionDispatch::HostAuthorization`

Previne ataques de rebinding DNS e outros ataques de cabeçalho `Host`.
Ele é incluído no ambiente de desenvolvimento por padrão com a seguinte configuração:

```ruby
Rails.application.config.hosts = [
  IPAddr.new("0.0.0.0/0"),        # Todos os endereços IPv4.
  IPAddr.new("::/0"),             # Todos os endereços IPv6.
  "localhost",                    # O domínio reservado localhost.
  ENV["RAILS_DEVELOPMENT_HOSTS"]  # Hosts adicionais separados por vírgula para desenvolvimento.
]
```
Em outros ambientes, `Rails.application.config.hosts` está vazio e nenhuma verificação de cabeçalho `Host` será feita. Se você deseja se proteger contra ataques de cabeçalho em produção, você precisa permitir manualmente os hosts permitidos com:

```ruby
Rails.application.config.hosts << "product.com"
```

O host de uma solicitação é verificado em relação às entradas de `hosts` com o operador de caso (`#===`), que permite que `hosts` suporte entradas do tipo `Regexp`, `Proc` e `IPAddr`, entre outros. Aqui está um exemplo com uma expressão regular.

```ruby
# Permitir solicitações de subdomínios como `www.product.com` e
# `beta1.product.com`.
Rails.application.config.hosts << /.*\.product\.com/
```

A expressão regular fornecida será envolvida com âncoras (`\A` e `\z`) para que corresponda ao nome do host inteiro. `/product.com/`, por exemplo, uma vez ancorado, não corresponderia a `www.product.com`.

Um caso especial é suportado que permite permitir todos os subdomínios:

```ruby
# Permitir solicitações de subdomínios como `www.product.com` e
# `beta1.product.com`.
Rails.application.config.hosts << ".product.com"
```

Você pode excluir determinadas solicitações das verificações de Autorização de Host definindo `config.host_authorization.exclude`:

```ruby
# Excluir solicitações para o caminho /healthcheck/ da verificação de host
Rails.application.config.host_authorization = {
  exclude: ->(request) { request.path.include?('healthcheck') }
}
```

Quando uma solicitação é feita a um host não autorizado, uma aplicação Rack padrão será executada e responderá com `403 Forbidden`. Isso pode ser personalizado definindo `config.host_authorization.response_app`. Por exemplo:

```ruby
Rails.application.config.host_authorization = {
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

#### `ActionDispatch::ServerTiming`

Adiciona métricas ao cabeçalho `Server-Timing` para serem visualizadas nas ferramentas de desenvolvimento de um navegador.

#### `ActionDispatch::SSL`

Força todas as solicitações a serem servidas usando HTTPS. Habilitado se `config.force_ssl` estiver definido como `true`. As opções passadas para isso podem ser configuradas definindo `config.ssl_options`.

#### `ActionDispatch::Static`

É usado para servir ativos estáticos. Desativado se `config.public_file_server.enabled` for `false`. Defina `config.public_file_server.index_name` se você precisar servir um arquivo de índice de diretório estático que não tenha o nome `index`. Por exemplo, para servir `main.html` em vez de `index.html` para solicitações de diretório, defina `config.public_file_server.index_name` como `"main"`.

#### `ActionDispatch::Executor`

Permite a recarga de código segura por thread. Desativado se `config.allow_concurrency` for `false`, o que faz com que `Rack::Lock` seja carregado. `Rack::Lock` envolve o aplicativo em um mutex para que possa ser chamado apenas por uma única thread de cada vez.

#### `ActiveSupport::Cache::Strategy::LocalCache`

Serve como um cache básico em memória. Este cache não é seguro para threads e destina-se apenas a servir como um cache temporário em memória para uma única thread.

#### `Rack::Runtime`

Define um cabeçalho `X-Runtime`, contendo o tempo (em segundos) necessário para executar a solicitação.

#### `Rails::Rack::Logger`

Registra nos logs que a solicitação foi iniciada. Após a conclusão da solicitação, todos os logs são liberados.

#### `ActionDispatch::ShowExceptions`

Resgata qualquer exceção retornada pela aplicação e renderiza páginas de exceção agradáveis se a solicitação for local ou se `config.consider_all_requests_local` estiver definido como `true`. Se `config.action_dispatch.show_exceptions` estiver definido como `:none`, as exceções serão lançadas independentemente.

#### `ActionDispatch::RequestId`

Disponibiliza um cabeçalho X-Request-Id exclusivo para a resposta e habilita o método `ActionDispatch::Request#uuid`. Configurável com `config.action_dispatch.request_id_header`.

#### `ActionDispatch::RemoteIp`

Verifica ataques de falsificação de IP e obtém o `client_ip` válido dos cabeçalhos da solicitação. Configurável com as opções `config.action_dispatch.ip_spoofing_check` e `config.action_dispatch.trusted_proxies`.

#### `Rack::Sendfile`

Intercepta respostas cujo corpo está sendo servido a partir de um arquivo e substitui-o por um cabeçalho X-Sendfile específico do servidor. Configurável com `config.action_dispatch.x_sendfile_header`.
#### `ActionDispatch::Callbacks`

Executa os callbacks de preparação antes de atender à solicitação.

#### `ActionDispatch::Cookies`

Define cookies para a solicitação.

#### `ActionDispatch::Session::CookieStore`

É responsável por armazenar a sessão em cookies. Um middleware alternativo pode ser usado para isso alterando [`config.session_store`](#config-session-store).

#### `ActionDispatch::Flash`

Configura as chaves `flash`. Disponível apenas se [`config.session_store`](#config-session-store) estiver definido com um valor.

#### `Rack::MethodOverride`

Permite que o método seja substituído se `params[:_method]` estiver definido. Este é o middleware que suporta os tipos de método HTTP PATCH, PUT e DELETE.

#### `Rack::Head`

Converte solicitações HEAD em solicitações GET e as atende como tal.

#### Adicionando Middleware Personalizado

Além desses middlewares usuais, você pode adicionar os seus próprios usando o método `config.middleware.use`:

```ruby
config.middleware.use Magical::Unicorns
```

Isso colocará o middleware `Magical::Unicorns` no final da pilha. Você pode usar `insert_before` se desejar adicionar um middleware antes de outro.

```ruby
config.middleware.insert_before Rack::Head, Magical::Unicorns
```

Ou você pode inserir um middleware em uma posição exata usando índices. Por exemplo, se você deseja inserir o middleware `Magical::Unicorns` no topo da pilha, você pode fazer isso, assim:

```ruby
config.middleware.insert_before 0, Magical::Unicorns
```

Também existe o `insert_after`, que irá inserir um middleware após outro:

```ruby
config.middleware.insert_after Rack::Head, Magical::Unicorns
```

Os middlewares também podem ser completamente substituídos por outros:

```ruby
config.middleware.swap ActionController::Failsafe, Lifo::Failsafe
```

Os middlewares podem ser movidos de um lugar para outro:

```ruby
config.middleware.move_before ActionDispatch::Flash, Magical::Unicorns
```

Isso moverá o middleware `Magical::Unicorns` antes do `ActionDispatch::Flash`. Você também pode movê-lo depois:

```ruby
config.middleware.move_after ActionDispatch::Flash, Magical::Unicorns
```

Eles também podem ser removidos completamente da pilha:

```ruby
config.middleware.delete Rack::MethodOverride
```

### Configurando i18n

Todas essas opções de configuração são delegadas para a biblioteca `I18n`.

#### `config.i18n.available_locales`

Define os locais disponíveis permitidos para o aplicativo. O padrão são todas as chaves de local encontradas nos arquivos de localização, geralmente apenas `:en` em um novo aplicativo.

#### `config.i18n.default_locale`

Define o local padrão de um aplicativo usado para i18n. O padrão é `:en`.

#### `config.i18n.enforce_available_locales`

Garante que todos os locais passados pelo i18n devem ser declarados na lista `available_locales`, gerando uma exceção `I18n::InvalidLocale` ao definir um local indisponível. O padrão é `true`. É recomendado não desativar essa opção, a menos que seja estritamente necessário, pois isso funciona como uma medida de segurança contra a definição de qualquer local inválido a partir da entrada do usuário.

#### `config.i18n.load_path`

Define o caminho que o Rails usa para procurar arquivos de localização. O padrão é `config/locales/**/*.{yml,rb}`.

#### `config.i18n.raise_on_missing_translations`

Determina se um erro deve ser gerado para traduções ausentes. O padrão é `false`.

#### `config.i18n.fallbacks`

Define o comportamento de fallback para traduções ausentes. Aqui estão 3 exemplos de uso para essa opção:

  * Você pode definir a opção como `true` para usar o local padrão como fallback, assim:

    ```ruby
    config.i18n.fallbacks = true
    ```

  * Ou você pode definir um array de locais como fallback, assim:

    ```ruby
    config.i18n.fallbacks = [:tr, :en]
    ```

  * Ou você pode definir fallbacks diferentes para locais individualmente. Por exemplo, se você deseja usar `:tr` para `:az` e `:de`, `:en` para `:da` como fallbacks, você pode fazer assim:

    ```ruby
    config.i18n.fallbacks = { az: :tr, da: [:de, :en] }
    #ou
    config.i18n.fallbacks.map = { az: :tr, da: [:de, :en] }
    ```
### Configurando Active Model

#### `config.active_model.i18n_customize_full_message`

Controla se o formato [`Error#full_message`][ActiveModel::Error#full_message] pode ser substituído em um arquivo de localização i18n. O valor padrão é `false`.

Quando definido como `true`, `full_message` procurará um formato nos arquivos de localização do atributo e do modelo. O formato padrão é `"%{attribute} %{message}"`, onde `attribute` é o nome do atributo e `message` é a mensagem específica de validação. O exemplo a seguir substitui o formato para todos os atributos de `Person`, bem como o formato para um atributo específico de `Person` (`age`).

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
          # Substitui o formato para todos os atributos de Person:
          format: "Inválido %{attribute} (%{message})"
          attributes:
            age:
              # Substitui o formato para o atributo age:
              format: "%{message}"
              blank: "Por favor, preencha o seu %{attribute}"
```

```irb
irb> person = Person.new.tap(&:valid?)

irb> person.errors.full_messages
=> [
  "Inválido Nome (não pode ficar em branco)",
  "Por favor, preencha o seu Age"
]

irb> person.errors.messages
=> {
  :name => ["não pode ficar em branco"],
  :age  => ["Por favor, preencha o seu Age"]
}
```


### Configurando Active Record

`config.active_record` inclui uma variedade de opções de configuração:

#### `config.active_record.logger`

Aceita um logger que segue a interface do Log4r ou a classe padrão de logger do Ruby, que é então passado para quaisquer novas conexões de banco de dados feitas. Você pode recuperar esse logger chamando `logger` em uma classe de modelo Active Record ou em uma instância de modelo Active Record. Defina como `nil` para desativar o registro.

#### `config.active_record.primary_key_prefix_type`

Permite ajustar a nomenclatura das colunas de chave primária. Por padrão, o Rails assume que as colunas de chave primária são nomeadas `id` (e essa opção de configuração não precisa ser definida). Existem outras duas opções:

* `:table_name` faria com que a chave primária para a classe Customer seja `customerid`.
* `:table_name_with_underscore` faria com que a chave primária para a classe Customer seja `customer_id`.

#### `config.active_record.table_name_prefix`

Permite definir uma string global a ser prefixada nos nomes das tabelas. Se você definir isso como `northwest_`, então a classe Customer procurará por `northwest_customers` como sua tabela. O padrão é uma string vazia.

#### `config.active_record.table_name_suffix`

Permite definir uma string global a ser anexada aos nomes das tabelas. Se você definir isso como `_northwest`, então a classe Customer procurará por `customers_northwest` como sua tabela. O padrão é uma string vazia.

#### `config.active_record.schema_migrations_table_name`

Permite definir uma string a ser usada como o nome da tabela de migrações de esquema.

#### `config.active_record.internal_metadata_table_name`

Permite definir uma string a ser usada como o nome da tabela de metadados internos.

#### `config.active_record.protected_environments`

Permite definir uma matriz de nomes de ambientes onde ações destrutivas devem ser proibidas.

#### `config.active_record.pluralize_table_names`

Especifica se o Rails procurará nomes de tabelas no banco de dados no singular ou no plural. Se definido como `true` (o padrão), então a classe Customer usará a tabela `customers`. Se definido como `false`, então a classe Customer usará a tabela `customer`.

#### `config.active_record.default_timezone`

Determina se deve usar `Time.local` (se definido como `:local`) ou `Time.utc` (se definido como `:utc`) ao buscar datas e horários do banco de dados. O padrão é `:utc`.
#### `config.active_record.schema_format`

Controla o formato para despejar o esquema do banco de dados para um arquivo. As opções são `:ruby` (o padrão) para uma versão independente do banco de dados que depende de migrações, ou `:sql` para um conjunto de declarações SQL (potencialmente dependentes do banco de dados).

#### `config.active_record.error_on_ignored_order`

Especifica se um erro deve ser lançado se a ordem de uma consulta for ignorada durante uma consulta em lote. As opções são `true` (lançar erro) ou `false` (avisar). O padrão é `false`.

#### `config.active_record.timestamped_migrations`

Controla se as migrações são numeradas com inteiros sequenciais ou com timestamps. O padrão é `true`, para usar timestamps, que são preferidos se houver vários desenvolvedores trabalhando na mesma aplicação.

#### `config.active_record.db_warnings_action`

Controla a ação a ser tomada quando uma consulta SQL produz um aviso. As seguintes opções estão disponíveis:

  * `:ignore` - Os avisos do banco de dados serão ignorados. Este é o padrão.

  * `:log` - Os avisos do banco de dados serão registrados via `ActiveRecord.logger` no nível `:warn`.

  * `:raise` - Os avisos do banco de dados serão lançados como `ActiveRecord::SQLWarning`.

  * `:report` - Os avisos do banco de dados serão reportados aos assinantes do relatório de erros do Rails.

  * Proc personalizado - Um proc personalizado pode ser fornecido. Ele deve aceitar um objeto de erro `SQLWarning`.

    Por exemplo:

    ```ruby
    config.active_record.db_warnings_action = ->(warning) do
      # Reportar para um serviço personalizado de relatório de exceções
      Bugsnag.notify(warning.message) do |notification|
        notification.add_metadata(:warning_code, warning.code)
        notification.add_metadata(:warning_level, warning.level)
      end
    end
    ```

#### `config.active_record.db_warnings_ignore`

Especifica uma lista de permissões de códigos e mensagens de aviso que serão ignorados, independentemente da `db_warnings_action` configurada. O comportamento padrão é reportar todos os avisos. Os avisos a serem ignorados podem ser especificados como Strings ou Regexps. Por exemplo:

  ```ruby
  config.active_record.db_warnings_action = :raise
  # Os seguintes avisos não serão lançados
  config.active_record.db_warnings_ignore = [
    /Invalid utf8mb4 character string/,
    "Uma mensagem de aviso exata",
    "1062", # Erro 1062 do MySQL: Entrada duplicada
  ]
  ```

#### `config.active_record.migration_strategy`

Controla a classe de estratégia usada para executar métodos de declaração de esquema em uma migração. A classe padrão
delega para o adaptador de conexão. Estratégias personalizadas devem herdar de `ActiveRecord::Migration::ExecutionStrategy`,
ou podem herdar de `DefaultStrategy`, que preservará o comportamento padrão para métodos que não são implementados:

```ruby
class CustomMigrationStrategy < ActiveRecord::Migration::DefaultStrategy
  def drop_table(*)
    raise "A exclusão de tabelas não é suportada!"
  end
end

config.active_record.migration_strategy = CustomMigrationStrategy
```

#### `config.active_record.lock_optimistically`

Controla se o Active Record usará bloqueio otimista e é `true` por padrão.

#### `config.active_record.cache_timestamp_format`

Controla o formato do valor de timestamp na chave de cache. O padrão é `:usec`.

#### `config.active_record.record_timestamps`

É um valor booleano que controla se a marcação de tempo das operações `create` e `update` em um modelo ocorre. O valor padrão é `true`.

#### `config.active_record.partial_inserts`

É um valor booleano e controla se gravações parciais são usadas ao criar novos registros (ou seja, se as inserções apenas definem atributos diferentes do padrão).

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `true`           |
| 7.0                | `false`          |

#### `config.active_record.partial_updates`

É um valor booleano e controla se gravações parciais são usadas ao atualizar registros existentes (ou seja, se as atualizações apenas definem atributos que estão sujos). Observe que ao usar atualizações parciais, você também deve usar bloqueio otimista `config.active_record.lock_optimistically`, pois atualizações concorrentes podem gravar atributos com base em um estado de leitura possivelmente desatualizado. O valor padrão é `true`.
#### `config.active_record.maintain_test_schema`

É um valor booleano que controla se o Active Record deve tentar manter o esquema do banco de dados de teste atualizado com `db/schema.rb` (ou `db/structure.sql`) quando você executa seus testes. O valor padrão é `true`.

#### `config.active_record.dump_schema_after_migration`

É uma flag que controla se o dump do esquema deve acontecer (`db/schema.rb` ou `db/structure.sql`) quando você executa as migrações. Isso é definido como `false` em `config/environments/production.rb`, que é gerado pelo Rails. O valor padrão é `true` se essa configuração não estiver definida.

#### `config.active_record.dump_schemas`

Controla quais esquemas de banco de dados serão dumpados ao chamar `db:schema:dump`. As opções são `:schema_search_path` (o padrão), que faz o dump de todos os esquemas listados em `schema_search_path`, `:all`, que sempre faz o dump de todos os esquemas, independentemente do `schema_search_path`, ou uma string de esquemas separados por vírgula.

#### `config.active_record.before_committed_on_all_records`

Habilita os callbacks before_committed! em todos os registros inscritos em uma transação. O comportamento anterior era executar os callbacks apenas na primeira cópia de um registro se houvesse várias cópias do mesmo registro inscritas na transação.

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.1                | `true`           |

#### `config.active_record.belongs_to_required_by_default`

É um valor booleano que controla se um registro falha na validação se a associação `belongs_to` não estiver presente.

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `nil`            |
| 5.0                | `true`           |

#### `config.active_record.belongs_to_required_validates_foreign_key`

Habilita a validação apenas das colunas relacionadas ao pai para presença quando o pai é obrigatório. O comportamento anterior era validar a presença do registro pai, o que realizava uma consulta extra para obter o pai toda vez que o registro filho era atualizado, mesmo quando o pai não havia sido alterado.

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `true`           |
| 7.1                | `false`          |

#### `config.active_record.marshalling_format_version`

Quando definido como `7.1`, permite uma serialização mais eficiente da instância do Active Record com `Marshal.dump`.

Isso altera o formato de serialização, então modelos serializados dessa maneira não podem ser lidos por versões mais antigas (< 7.1) do Rails. No entanto, mensagens que usam o formato antigo ainda podem ser lidas, independentemente de essa otimização estar habilitada.

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `6.1`            |
| 7.1                | `7.1`            |

#### `config.active_record.action_on_strict_loading_violation`

Habilita o lançamento ou o registro de uma exceção se o strict_loading for definido em uma associação. O valor padrão é `:raise` em todos os ambientes. Pode ser alterado para `:log` para enviar violações para o logger em vez de lançar uma exceção.

#### `config.active_record.strict_loading_by_default`

É um valor booleano que habilita ou desabilita o modo strict_loading por padrão. O padrão é `false`.

#### `config.active_record.warn_on_records_fetched_greater_than`

Permite definir um limite de aviso para o tamanho do resultado de uma consulta. Se o número de registros retornados por uma consulta exceder o limite, um aviso é registrado. Isso pode ser usado para identificar consultas que podem estar causando um consumo excessivo de memória.

#### `config.active_record.index_nested_attribute_errors`

Permite que erros para relacionamentos `has_many` aninhados sejam exibidos com um índice, além do erro em si. O padrão é `false`.
#### `config.active_record.use_schema_cache_dump`

Permite que os usuários obtenham informações de cache de esquema do `db/schema_cache.yml` (gerado pelo `bin/rails db:schema:cache:dump`), em vez de ter que enviar uma consulta ao banco de dados para obter essas informações. O valor padrão é `true`.

#### `config.active_record.cache_versioning`

Indica se deve ser usado um método `#cache_key` estável que é acompanhado por uma versão em mudança no método `#cache_version`.

O valor padrão depende da versão de destino do `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 5.2                | `true`           |

#### `config.active_record.collection_cache_versioning`

Permite que a mesma chave de cache seja reutilizada quando o objeto sendo armazenado em cache do tipo `ActiveRecord::Relation` é alterado, movendo as informações voláteis (máximo atualizado em e contagem) da chave de cache da relação para a versão de cache para suportar a reciclagem da chave de cache.

O valor padrão depende da versão de destino do `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 6.0                | `true`           |

#### `config.active_record.has_many_inversing`

Permite definir o registro inverso ao percorrer associações de `belongs_to` para `has_many`.

O valor padrão depende da versão de destino do `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 6.1                | `true`           |

#### `config.active_record.automatic_scope_inversing`

Permite inferir automaticamente o `inverse_of` para associações com um escopo.

O valor padrão depende da versão de destino do `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.0                | `true`           |

#### `config.active_record.destroy_association_async_job`

Permite especificar o job que será usado para destruir os registros associados em segundo plano. O valor padrão é `ActiveRecord::DestroyAssociationAsyncJob`.

#### `config.active_record.destroy_association_async_batch_size`

Permite especificar o número máximo de registros que serão destruídos em um job em segundo plano pela opção de associação `dependent: :destroy_async`. Tudo igual, um tamanho de lote menor enfileirará mais jobs em segundo plano de curta duração, enquanto um tamanho de lote maior enfileirará menos jobs em segundo plano de longa duração. Este opção tem o valor padrão `nil`, o que fará com que todos os registros dependentes de uma determinada associação sejam destruídos no mesmo job em segundo plano.

#### `config.active_record.queues.destroy`

Permite especificar a fila do Active Job a ser usada para jobs de destruição. Quando esta opção é `nil`, os jobs de purga são enviados para a fila padrão do Active Job (veja `config.active_job.default_queue_name`). O valor padrão é `nil`.

#### `config.active_record.enumerate_columns_in_select_statements`

Quando `true`, sempre incluirá os nomes das colunas em declarações `SELECT` e evitará consultas de `SELECT * FROM ...` com asterisco. Isso evita erros de cache de declaração preparada ao adicionar colunas a um banco de dados PostgreSQL, por exemplo. O valor padrão é `false`.

#### `config.active_record.verify_foreign_keys_for_fixtures`

Garante que todas as restrições de chave estrangeira sejam válidas após a carga dos fixtures nos testes. Suportado apenas pelo PostgreSQL e SQLite.

O valor padrão depende da versão de destino do `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.0                | `true`           |

#### `config.active_record.raise_on_assign_to_attr_readonly`

Permite lançar um erro ao atribuir valores a atributos `attr_readonly`. O comportamento anterior permitia a atribuição, mas silenciosamente não persistia as alterações no banco de dados.

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.1                | `true`           |
#### `config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`

Quando várias instâncias do Active Record alteram o mesmo registro dentro de uma transação, o Rails executa os callbacks `after_commit` ou `after_rollback` apenas em uma delas. Essa opção especifica como o Rails escolhe qual instância receberá os callbacks.

Quando `true`, os callbacks transacionais são executados na primeira instância a ser salva, mesmo que seu estado de instância possa estar desatualizado.

Quando `false`, os callbacks transacionais são executados nas instâncias com o estado de instância mais recente. Essas instâncias são escolhidas da seguinte forma:

- Em geral, execute os callbacks transacionais na última instância a salvar um determinado registro dentro da transação.
- Existem duas exceções:
    - Se o registro for criado dentro da transação e, em seguida, atualizado por outra instância, os callbacks `after_create_commit` serão executados na segunda instância. Isso ocorre em vez dos callbacks `after_update_commit` que seriam executados com base no estado dessa instância.
    - Se o registro for excluído dentro da transação, os callbacks `after_destroy_commit` serão disparados na última instância excluída, mesmo que uma instância desatualizada posteriormente tenha realizado uma atualização (que não terá afetado nenhuma linha).

O valor padrão depende da versão de destino do `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `true`           |
| 7.1                | `false`          |

#### `config.active_record.default_column_serializer`

A implementação do serializador a ser usada se nenhum for especificado explicitamente para uma determinada coluna.

Historicamente, `serialize` e `store`, embora permitam o uso de implementações alternativas de serializador, usariam `YAML` por padrão, mas não é um formato muito eficiente e pode ser a fonte de vulnerabilidades de segurança se não for usado com cuidado.

Portanto, é recomendável preferir formatos mais restritos e limitados para a serialização de banco de dados.

Infelizmente, não há realmente nenhuma opção padrão adequada disponível na biblioteca padrão do Ruby. `JSON` poderia funcionar como um formato, mas as gemas `json` converterão tipos não suportados em strings, o que pode levar a bugs.

O valor padrão depende da versão de destino do `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `YAML`           |
| 7.1                | `nil`            |

#### `config.active_record.run_after_transaction_callbacks_in_order_defined`

Se verdadeiro, os callbacks `after_commit` são executados na ordem em que são definidos em um modelo. Se falso, eles são executados na ordem inversa.

Todos os outros callbacks são sempre executados na ordem em que são definidos em um modelo (a menos que você use `prepend: true`).

O valor padrão depende da versão de destino do `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.1                | `true`           |

#### `config.active_record.query_log_tags_enabled`

Especifica se habilitar ou não comentários de consulta em nível de adaptador. O padrão é `false`.

NOTA: Quando isso é definido como `true`, as declarações preparadas do banco de dados serão desabilitadas automaticamente.

#### `config.active_record.query_log_tags`

Define um `Array` especificando as tags chave/valor a serem inseridas em um comentário SQL. O padrão é `[ :application ]`, uma tag predefinida que retorna o nome da aplicação.

#### `config.active_record.query_log_tags_format`

Um `Symbol` especificando o formatador a ser usado para as tags. Os valores válidos são `:sqlcommenter` e `:legacy`.

O valor padrão depende da versão de destino do `config.load_defaults`:
| A partir da versão | O valor padrão é |
| --------------------- | -------------------- |
| (original)            | `:legacy`            |
| 7.1                   | `:sqlcommenter`      |

#### `config.active_record.cache_query_log_tags`

Especifica se deve ou não habilitar o cache das tags de log de consulta. Para aplicativos que possuem um grande número de consultas, o cache das tags de log de consulta pode fornecer um benefício de desempenho quando o contexto não muda durante a vida útil da solicitação ou execução do trabalho. O valor padrão é `false`.

#### `config.active_record.schema_cache_ignored_tables`

Define a lista de tabelas que devem ser ignoradas ao gerar o cache do esquema. Aceita um `Array` de strings, representando os nomes das tabelas, ou expressões regulares.

#### `config.active_record.verbose_query_logs`

Especifica se os locais de origem dos métodos que chamam consultas ao banco de dados devem ser registrados abaixo das consultas relevantes. Por padrão, a sinalização é `true` no ambiente de desenvolvimento e `false` em todos os outros ambientes.

#### `config.active_record.sqlite3_adapter_strict_strings_by_default`

Especifica se o SQLite3Adapter deve ser usado em um modo de strings estritas. O uso de um modo de strings estritas desativa literais de string entre aspas duplas.

O SQLite possui algumas peculiaridades em relação a literais de string entre aspas duplas. Primeiro, ele tenta considerar as strings entre aspas duplas como nomes de identificadores, mas se eles não existirem, então as considera como literais de string. Por causa disso, erros de digitação podem passar despercebidos. Por exemplo, é possível criar um índice para uma coluna que não existe. Consulte a [documentação do SQLite](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted) para obter mais detalhes.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.async_query_executor`

Especifica como as consultas assíncronas são agrupadas.

O valor padrão é `nil`, o que significa que `load_async` está desativado e, em vez disso, as consultas são executadas diretamente em primeiro plano. Para que as consultas sejam realmente executadas de forma assíncrona, ele deve ser definido como `:global_thread_pool` ou `:multi_thread_pool`.

`:global_thread_pool` usará um único pool para todos os bancos de dados aos quais o aplicativo se conecta. Essa é a configuração preferida para aplicativos com apenas um banco de dados ou aplicativos que consultam apenas um fragmento de banco de dados de cada vez.

`:multi_thread_pool` usará um pool por banco de dados, e o tamanho de cada pool pode ser configurado individualmente em `database.yml` por meio das propriedades `max_threads` e `min_thread`. Isso pode ser útil para aplicativos que consultam regularmente vários bancos de dados ao mesmo tempo e que precisam definir com mais precisão a concorrência máxima.

#### `config.active_record.global_executor_concurrency`

Usado em conjunto com `config.active_record.async_query_executor = :global_thread_pool`, define quantas consultas assíncronas podem ser executadas simultaneamente.

O valor padrão é `4`.

Este número deve ser considerado em conjunto com o tamanho do pool de conexões configurado em `database.yml`. O pool de conexões deve ser grande o suficiente para acomodar tanto as threads em primeiro plano (por exemplo, threads do servidor da web ou do trabalhador de tarefas) quanto as threads em segundo plano.

#### `config.active_record.allow_deprecated_singular_associations_name`

Isso permite o comportamento obsoleto em que associações singulares podem ser referenciadas pelo nome no plural em cláusulas `where`. Definir isso como `false` é mais eficiente em termos de desempenho.

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end

Comment.where(post: post_id).count  # => 5

# Quando `allow_deprecated_singular_associations_name` é true:
Comment.where(posts: post_id).count # => 5 (aviso de obsolescência)

# Quando `allow_deprecated_singular_associations_name` é false:
Comment.where(posts: post_id).count # => erro
```

O valor padrão depende da versão de destino `config.load_defaults`:
| A partir da versão | O valor padrão é |
| --------------------- | -------------------- |
| (original)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.yaml_column_permitted_classes`

O valor padrão é `[Symbol]`. Permite que as aplicações incluam classes permitidas adicionais para `safe_load()` no `ActiveRecord::Coders::YAMLColumn`.

#### `config.active_record.use_yaml_unsafe_load`

O valor padrão é `false`. Permite que as aplicações optem por usar `unsafe_load` no `ActiveRecord::Coders::YAMLColumn`.

#### `config.active_record.raise_int_wider_than_64bit`

O valor padrão é `true`. Determina se deve lançar uma exceção ou não quando o adaptador PostgreSQL recebe um número inteiro que é maior do que a representação de 64 bits com sinal.

#### `ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans` e `ActiveRecord::ConnectionAdapters::TrilogyAdapter.emulate_booleans`

Controla se o adaptador MySQL do Active Record considerará todas as colunas `tinyint(1)` como booleanas. O valor padrão é `true`.

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.create_unlogged_tables`

Controla se as tabelas do banco de dados criadas pelo PostgreSQL devem ser "unlogged", o que pode aumentar o desempenho, mas adiciona o risco de perda de dados se o banco de dados falhar. É altamente recomendado que você não habilite isso em um ambiente de produção. O valor padrão é `false` em todos os ambientes.

Para habilitar isso nos testes:

```ruby
# config/environments/test.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.create_unlogged_tables = true
end
```

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type`

Controla qual tipo nativo o adaptador PostgreSQL do Active Record deve usar quando você chama `datetime` em uma migração ou esquema. Ele recebe um símbolo que deve corresponder a um dos `NATIVE_DATABASE_TYPES` configurados. O valor padrão é `:timestamp`, o que significa que `t.datetime` em uma migração criará uma coluna "timestamp without time zone".

Para usar "timestamp with time zone":

```ruby
# config/application.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.datetime_type = :timestamptz
end
```

Você deve executar `bin/rails db:migrate` para reconstruir seu schema.rb se você alterar isso.

#### `ActiveRecord::SchemaDumper.ignore_tables`

Aceita um array de tabelas que _não_ devem ser incluídas em nenhum arquivo de esquema gerado.

#### `ActiveRecord::SchemaDumper.fk_ignore_pattern`

Permite definir uma expressão regular diferente que será usada para decidir se o nome de uma chave estrangeira deve ser incluído no db/schema.rb ou não. Por padrão, os nomes de chaves estrangeiras que começam com `fk_rails_` não são exportados para o dump do esquema do banco de dados. O valor padrão é `/^fk_rails_[0-9a-f]{10}$/`.

#### `config.active_record.encryption.hash_digest_class`

Define o algoritmo de digest usado pelo Active Record Encryption.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é      |
|-----------------------|---------------------------|
| (original)            | `OpenSSL::Digest::SHA1`   |
| 7.1                   | `OpenSSL::Digest::SHA256` |

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

Habilita o suporte para descriptografar dados existentes criptografados usando uma classe de digest SHA-1. Quando `false`, ele só suportará o digest configurado em `config.active_record.encryption.hash_digest_class`.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
|-----------------------|----------------------|
| (original)            | `true`               |
| 7.1                   | `false`              |

### Configurando o Action Controller

`config.action_controller` inclui várias configurações:

#### `config.action_controller.asset_host`

Define o host para os assets. Útil quando CDNs são usados para hospedar os assets em vez do próprio servidor da aplicação. Você só deve usar isso se tiver uma configuração diferente para o Action Mailer, caso contrário, use `config.asset_host`.

#### `config.action_controller.perform_caching`

Configura se a aplicação deve executar os recursos de cache fornecidos pelo componente Action Controller ou não. Defina como `false` no ambiente de desenvolvimento e `true` na produção. Se não for especificado, o valor padrão será `true`.

#### `config.action_controller.default_static_extension`

Configura a extensão usada para páginas em cache. O valor padrão é `.html`.
#### `config.action_controller.include_all_helpers`

Configura se todos os helpers de visualização estão disponíveis em todos os lugares ou estão limitados ao controlador correspondente. Se definido como `false`, os métodos do `UsersHelper` estão disponíveis apenas para visualizações renderizadas como parte do `UsersController`. Se `true`, os métodos do `UsersHelper` estão disponíveis em todos os lugares. O comportamento de configuração padrão (quando essa opção não é definida explicitamente como `true` ou `false`) é que todos os helpers de visualização estão disponíveis para cada controlador.

#### `config.action_controller.logger`

Aceita um logger que esteja em conformidade com a interface do Log4r ou a classe de logger padrão do Ruby, que é então usado para registrar informações do Action Controller. Defina como `nil` para desativar o registro.

#### `config.action_controller.request_forgery_protection_token`

Define o nome do parâmetro de token para RequestForgery. Chamando `protect_from_forgery` define-o como `:authenticity_token` por padrão.

#### `config.action_controller.allow_forgery_protection`

Ativa ou desativa a proteção CSRF. Por padrão, isso é `false` no ambiente de teste e `true` em todos os outros ambientes.

#### `config.action_controller.forgery_protection_origin_check`

Configura se o cabeçalho HTTP `Origin` deve ser verificado em relação à origem do site como uma defesa CSRF adicional.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 5.0                | `true`           |

#### `config.action_controller.per_form_csrf_tokens`

Configura se os tokens CSRF são válidos apenas para o método/ação em que foram gerados.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 5.0                | `true`           |

#### `config.action_controller.default_protect_from_forgery`

Determina se a proteção contra falsificação é adicionada em `ActionController::Base`.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 5.2                | `true`           |

#### `config.action_controller.relative_url_root`

Pode ser usado para informar ao Rails que você está [implantando em um subdiretório](
configuring.html#deploy-to-a-subdirectory-relative-url-root). O padrão é
[`config.relative_url_root`](#config-relative-url-root).

#### `config.action_controller.permit_all_parameters`

Define que todos os parâmetros para atribuição em massa são permitidos por padrão. O valor padrão é `false`.

#### `config.action_controller.action_on_unpermitted_parameters`

Controla o comportamento quando são encontrados parâmetros que não são explicitamente permitidos. O valor padrão é `:log` nos ambientes de teste e desenvolvimento, `false` caso contrário. Os valores podem ser:

* `false` para não tomar nenhuma ação
* `:log` para emitir um evento `ActiveSupport::Notifications.instrument` no tópico `unpermitted_parameters.action_controller` e registrar no nível DEBUG
* `:raise` para lançar uma exceção `ActionController::UnpermittedParameters`

#### `config.action_controller.always_permitted_parameters`

Define uma lista de parâmetros permitidos que são permitidos por padrão. Os valores padrão são `['controller', 'action']`.

#### `config.action_controller.enable_fragment_cache_logging`

Determina se deve registrar leituras e gravações de cache de fragmentos em formato detalhado da seguinte forma:

```
Read fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/d0bdf2974e1ef6d31685c3b392ad0b74 (0.6ms)
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Write fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/3b4e249ac9d168c617e32e84b99218b5 (1.1ms)
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

Por padrão, está definido como `false`, o que resulta na seguinte saída:

```
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

#### `config.action_controller.raise_on_open_redirects`

Gera um `ActionController::Redirecting::UnsafeRedirectError` quando ocorre um redirecionamento aberto não permitido.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.0                | `true`           |
#### `config.action_controller.log_query_tags_around_actions`

Determina se o contexto do controlador para tags de consulta será atualizado automaticamente por meio de um `around_filter`. O valor padrão é `true`.

#### `config.action_controller.wrap_parameters_by_default`

Configura o [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html) para envolver solicitações json por padrão.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ----------------- |
| (original)         | `false`           |
| 7.0                | `true`            |

#### `ActionController::Base.wrap_parameters`

Configura o [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html). Isso pode ser chamado no nível superior ou em controladores individuais.

#### `config.action_controller.allow_deprecated_parameters_hash_equality`

Controla o comportamento de `ActionController::Parameters#==` com argumentos `Hash`. O valor da configuração determina se uma instância de `ActionController::Parameters` é igual a um `Hash` equivalente.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ----------------- |
| (original)         | `true`            |
| 7.1                | `false`           |

### Configurando o Action Dispatch

#### `config.action_dispatch.cookies_serializer`

Especifica qual serializador usar para cookies. Aceita os mesmos valores que [`config.active_support.message_serializer`](#config-active-support-message-serializer), além de `:hybrid`, que é um alias para `:json_allow_marshal`.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ----------------- |
| (original)         | `:marshal`        |
| 7.0                | `:json`           |

#### `config.action_dispatch.debug_exception_log_level`

Configura o nível de log usado pelo middleware DebugExceptions ao registrar exceções não capturadas durante as solicitações.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ----------------- |
| (original)         | `:fatal`          |
| 7.1                | `:error`          |

#### `config.action_dispatch.default_headers`

É um hash com cabeçalhos HTTP que são definidos por padrão em cada resposta.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ----------------- |
| (original)         | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "1; mode=block",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.0                | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.1                | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |

#### `config.action_dispatch.default_charset`

Especifica o conjunto de caracteres padrão para todas as renderizações. O padrão é `nil`.

#### `config.action_dispatch.tld_length`

Define o comprimento do TLD (domínio de nível superior) para a aplicação. O padrão é `1`.

#### `config.action_dispatch.ignore_accept_header`

É usado para determinar se deve ignorar os cabeçalhos de aceitação de uma solicitação. O padrão é `false`.

#### `config.action_dispatch.x_sendfile_header`

Especifica o cabeçalho X-Sendfile específico do servidor. Isso é útil para o envio acelerado de arquivos pelo servidor. Por exemplo, pode ser definido como 'X-Sendfile' para o Apache.

#### `config.action_dispatch.http_auth_salt`

Define o valor do salt de autenticação HTTP. O padrão é `'http authentication'`.

#### `config.action_dispatch.signed_cookie_salt`

Define o valor do salt de cookies assinados. O padrão é `'signed cookie'`.

#### `config.action_dispatch.encrypted_cookie_salt`

Define o valor do salt de cookies criptografados. O padrão é `'encrypted cookie'`.

#### `config.action_dispatch.encrypted_signed_cookie_salt`

Define o valor do salt de cookies assinados e criptografados. O padrão é `'signed encrypted cookie'`.

#### `config.action_dispatch.authenticated_encrypted_cookie_salt`

Define o salt do cookie criptografado autenticado. O padrão é `'authenticated encrypted cookie'`.

#### `config.action_dispatch.encrypted_cookie_cipher`

Define o cifrador a ser usado para cookies criptografados. O padrão é `"aes-256-gcm"`.
#### `config.action_dispatch.signed_cookie_digest`

Define o algoritmo de digest usado para cookies assinados. O valor padrão é `"SHA1"`.

#### `config.action_dispatch.cookies_rotations`

Permite a rotação de segredos, cifras e digests para cookies criptografados e assinados.

#### `config.action_dispatch.use_authenticated_cookie_encryption`

Controla se os cookies assinados e criptografados usam a cifra AES-256-GCM ou a cifra mais antiga AES-256-CBC.

O valor padrão depende da versão alvo `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 5.2                | `true`           |

#### `config.action_dispatch.use_cookies_with_metadata`

Habilita a gravação de cookies com metadados incorporados.

O valor padrão depende da versão alvo `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 6.0                | `true`           |

#### `config.action_dispatch.perform_deep_munge`

Configura se o método `deep_munge` deve ser executado nos parâmetros.
Consulte o [Guia de Segurança](security.html#unsafe-query-generation) para mais informações.
O valor padrão é `true`.

#### `config.action_dispatch.rescue_responses`

Configura quais exceções são atribuídas a um status HTTP. Aceita um hash e você pode especificar pares de exceção/status. Por padrão, isso é definido como:

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

Quaisquer exceções que não forem configuradas serão mapeadas para o status 500 Internal Server Error.

#### `config.action_dispatch.cookies_same_site_protection`

Configura o valor padrão do atributo `SameSite` ao definir cookies.
Quando definido como `nil`, o atributo `SameSite` não é adicionado. Para permitir que o valor do atributo `SameSite` seja configurado dinamicamente com base na solicitação, um proc pode ser especificado. Por exemplo:

```ruby
config.action_dispatch.cookies_same_site_protection = ->(request) do
  :strict unless request.user_agent == "TestAgent"
end
```

O valor padrão depende da versão alvo `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `nil`            |
| 6.1                | `:lax`           |

#### `config.action_dispatch.ssl_default_redirect_status`

Configura o código de status HTTP padrão usado ao redirecionar solicitações diferentes de GET/HEAD de HTTP para HTTPS no middleware `ActionDispatch::SSL`.

O valor padrão depende da versão alvo `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `307`            |
| 6.1                | `308`            |

#### `config.action_dispatch.log_rescued_responses`

Habilita o registro de exceções não tratadas configuradas em `rescue_responses`. O valor padrão é `true`.

#### `ActionDispatch::Callbacks.before`

Recebe um bloco de código para ser executado antes da solicitação.

#### `ActionDispatch::Callbacks.after`

Recebe um bloco de código para ser executado após a solicitação.

### Configurando Action View

`config.action_view` inclui um pequeno número de configurações:

#### `config.action_view.cache_template_loading`

Controla se os templates devem ser recarregados a cada solicitação. O valor padrão é `!config.enable_reloading`.

#### `config.action_view.field_error_proc`

Fornece um gerador HTML para exibir erros provenientes do Active Model. O bloco é avaliado no contexto de um template Action View. O valor padrão é

```ruby
Proc.new { |html_tag, instance| content_tag :div, html_tag, class: "field_with_errors" }
```

#### `config.action_view.default_form_builder`

Informa ao Rails qual construtor de formulário usar por padrão. O valor padrão é
`ActionView::Helpers::FormBuilder`. Se você deseja que sua classe de construtor de formulário seja
carregada após a inicialização (para que seja recarregada a cada solicitação no desenvolvimento),
você pode passá-la como uma `String`.
#### `config.action_view.logger`

Aceita um logger que esteja em conformidade com a interface do Log4r ou a classe de logger padrão do Ruby, que é então usado para registrar informações do Action View. Defina como `nil` para desativar o registro.

#### `config.action_view.erb_trim_mode`

Define o modo de corte a ser usado pelo ERB. O valor padrão é `'-'`, que ativa o corte de espaços finais e quebras de linha ao usar `<%= -%>` ou `<%= =%>`. Consulte a [documentação do Erubis](http://www.kuwata-lab.com/erubis/users-guide.06.html#topics-trimspaces) para obter mais informações.

#### `config.action_view.frozen_string_literal`

Compila o template ERB com o comentário mágico `# frozen_string_literal: true`, tornando todas as literais de string congeladas e economizando alocações. Defina como `true` para ativá-lo em todas as visualizações.

#### `config.action_view.embed_authenticity_token_in_remote_forms`

Permite definir o comportamento padrão para `authenticity_token` em formulários com `remote: true`. Por padrão, está definido como `false`, o que significa que os formulários remotos não incluirão `authenticity_token`, o que é útil quando você está fragmentando em cache o formulário. Os formulários remotos obtêm a autenticidade da tag `meta`, portanto, a incorporação é desnecessária, a menos que você dê suporte a navegadores sem JavaScript. Nesse caso, você pode passar `authenticity_token: true` como uma opção de formulário ou definir essa configuração como `true`.

#### `config.action_view.prefix_partial_path_with_controller_namespace`

Determina se os parciais são procurados em um subdiretório em modelos renderizados a partir de controladores com namespace. Por exemplo, considere um controlador chamado `Admin::ArticlesController` que renderiza este modelo:

```erb
<%= render @article %>
```

A configuração padrão é `true`, o que usa o parcial em `/admin/articles/_article.erb`. Definir o valor como `false` renderia `/articles/_article.erb`, que é o mesmo comportamento de renderização de um controlador sem namespace, como `ArticlesController`.

#### `config.action_view.automatically_disable_submit_tag`

Determina se `submit_tag` deve ser desativado automaticamente ao ser clicado, o padrão é `true`.

#### `config.action_view.debug_missing_translation`

Determina se a chave de tradução ausente deve ser envolvida em uma tag `<span>` ou não. O padrão é `true`.

#### `config.action_view.form_with_generates_remote_forms`

Determina se `form_with` gera formulários remotos ou não.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| 5.1                | `true`           |
| 6.1                | `false`          |

#### `config.action_view.form_with_generates_ids`

Determina se `form_with` gera ids nos inputs.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 5.2                | `true`           |

#### `config.action_view.default_enforce_utf8`

Determina se os formulários são gerados com uma tag oculta que força versões mais antigas do Internet Explorer a enviar formulários codificados em UTF-8.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `true`           |
| 6.0                | `false`          |

#### `config.action_view.image_loading`

Especifica um valor padrão para o atributo `loading` das tags `<img>` renderizadas pelo helper `image_tag`. Por exemplo, quando definido como `"lazy"`, as tags `<img>` renderizadas por `image_tag` incluirão `loading="lazy"`, o que [instrui o navegador a esperar até que uma imagem esteja próxima da viewport para carregá-la](https://html.spec.whatwg.org/#lazy-loading-attributes). (Esse valor ainda pode ser substituído por imagem, passando, por exemplo, `loading: "eager"` para `image_tag`.) O padrão é `nil`.

#### `config.action_view.image_decoding`

Especifica um valor padrão para o atributo `decoding` das tags `<img>` renderizadas pelo helper `image_tag`. O padrão é `nil`.
#### `config.action_view.annotate_rendered_view_with_filenames`

Determina se os nomes dos arquivos de modelo serão anotados nas visualizações renderizadas. O valor padrão é `false`.

#### `config.action_view.preload_links_header`

Determina se `javascript_include_tag` e `stylesheet_link_tag` irão gerar um cabeçalho `Link` que pré-carrega os ativos.

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `nil`            |
| 6.1                | `true`           |

#### `config.action_view.button_to_generates_button_tag`

Determina se `button_to` irá renderizar o elemento `<button>`, independentemente de o conteúdo ser passado como primeiro argumento ou como um bloco.

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.0                | `true`           |

#### `config.action_view.apply_stylesheet_media_default`

Determina se `stylesheet_link_tag` irá renderizar `screen` como o valor padrão para o atributo `media` quando não for fornecido.

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `true`           |
| 7.0                | `false`          |

#### `config.action_view.prepend_content_exfiltration_prevention`

Determina se os ajudantes `form_tag` e `button_to` irão produzir tags HTML com prefixo seguro para o navegador (mas tecnicamente inválido) que garante que seu conteúdo não possa ser capturado por nenhuma tag não fechada anterior. O valor padrão é `false`.

#### `config.action_view.sanitizer_vendor`

Configura o conjunto de sanitizadores HTML usados pelo Action View, definindo `ActionView::Helpers::SanitizeHelper.sanitizer_vendor`. O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é                 | Que analisa a marcação como |
|------------------- |---------------------------------|-----------------------------|
| (original)         | `Rails::HTML4::Sanitizer`        | HTML4                       |
| 7.1                | `Rails::HTML5::Sanitizer` (ver NOTA) | HTML5                       |

NOTA: `Rails::HTML5::Sanitizer` não é suportado no JRuby, então em plataformas JRuby o Rails usará `Rails::HTML4::Sanitizer`.

### Configurando o Action Mailbox

`config.action_mailbox` fornece as seguintes opções de configuração:

#### `config.action_mailbox.logger`

Contém o logger usado pelo Action Mailbox. Aceita um logger que segue a interface do Log4r ou a classe de logger padrão do Ruby. O padrão é `Rails.logger`.

```ruby
config.action_mailbox.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.action_mailbox.incinerate_after`

Aceita uma `ActiveSupport::Duration` indicando quanto tempo após o processamento os registros `ActionMailbox::InboundEmail` devem ser destruídos. O padrão é `30.days`.

```ruby
# Destruir os emails recebidos 14 dias após o processamento.
config.action_mailbox.incinerate_after = 14.days
```

#### `config.action_mailbox.queues.incineration`

Aceita um símbolo indicando a fila do Active Job a ser usada para os trabalhos de incineração. Quando esta opção é `nil`, os trabalhos de incineração são enviados para a fila padrão do Active Job (veja `config.active_job.default_queue_name`).

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `:action_mailbox_incineration` |
| 6.1                | `nil`            |

#### `config.action_mailbox.queues.routing`

Aceita um símbolo indicando a fila do Active Job a ser usada para os trabalhos de roteamento. Quando esta opção é `nil`, os trabalhos de roteamento são enviados para a fila padrão do Active Job (veja `config.active_job.default_queue_name`).

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `:action_mailbox_routing` |
| 6.1                | `nil`            |

#### `config.action_mailbox.storage_service`
Aceita um símbolo que indica o serviço Active Storage a ser usado para fazer upload de emails. Quando essa opção é `nil`, os emails são enviados para o serviço Active Storage padrão (veja `config.active_storage.service`).

### Configurando o Action Mailer

Existem várias configurações disponíveis em `config.action_mailer`:

#### `config.action_mailer.asset_host`

Define o host para os assets. Útil quando CDNs são usados para hospedar os assets em vez do próprio servidor de aplicativos. Você só deve usar isso se tiver uma configuração diferente para o Action Controller, caso contrário, use `config.asset_host`.

#### `config.action_mailer.logger`

Aceita um logger que segue a interface do Log4r ou a classe de logger padrão do Ruby, que é usado para registrar informações do Action Mailer. Defina como `nil` para desativar o registro.

#### `config.action_mailer.smtp_settings`

Permite configuração detalhada para o método de entrega `:smtp`. Aceita um hash de opções, que podem incluir qualquer uma dessas opções:

* `:address` - Permite que você use um servidor de email remoto. Basta alterá-lo de sua configuração padrão "localhost".
* `:port` - Caso o seu servidor de email não esteja em execução na porta 25, você pode alterá-la.
* `:domain` - Se você precisar especificar um domínio HELO, pode fazê-lo aqui.
* `:user_name` - Se o seu servidor de email exigir autenticação, defina o nome de usuário nesta configuração.
* `:password` - Se o seu servidor de email exigir autenticação, defina a senha nesta configuração.
* `:authentication` - Se o seu servidor de email exigir autenticação, você precisa especificar o tipo de autenticação aqui. Isso é um símbolo e pode ser `:plain`, `:login` ou `:cram_md5`.
* `:enable_starttls` - Use STARTTLS ao se conectar ao seu servidor SMTP e falhe se não for suportado. O valor padrão é `false`.
* `:enable_starttls_auto` - Detecta se o STARTTLS está habilitado em seu servidor SMTP e começa a usá-lo. O valor padrão é `true`.
* `:openssl_verify_mode` - Ao usar TLS, você pode definir como o OpenSSL verifica o certificado. Isso é útil se você precisar validar um certificado autoassinado e/ou um certificado curinga. Isso pode ser uma das constantes de verificação do OpenSSL, `:none` ou `:peer` -- ou a constante diretamente `OpenSSL::SSL::VERIFY_NONE` ou `OpenSSL::SSL::VERIFY_PEER`, respectivamente.
* `:ssl/:tls` - Habilita a conexão SMTP para usar SMTP/TLS (SMTPS: conexão SMTP sobre TLS direto).
* `:open_timeout` - Número de segundos para aguardar ao tentar abrir uma conexão.
* `:read_timeout` - Número de segundos para aguardar até que uma chamada de leitura (read(2)) seja encerrada.

Além disso, é possível passar qualquer [opção de configuração que o `Mail::SMTP` respeita](https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/smtp.rb).

#### `config.action_mailer.smtp_timeout`

Permite configurar os valores `:open_timeout` e `:read_timeout` para o método de entrega `:smtp`.

O valor padrão depende da versão de destino de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `nil`            |
| 7.0                | `5`              |

#### `config.action_mailer.sendmail_settings`

Permite configuração detalhada para o método de entrega `sendmail`. Aceita um hash de opções, que podem incluir qualquer uma dessas opções:

* `:location` - A localização do executável sendmail. O padrão é `/usr/sbin/sendmail`.
* `:arguments` - Os argumentos da linha de comando. O padrão é `%w[ -i ]`.

#### `config.action_mailer.raise_delivery_errors`

Especifica se deve gerar um erro se a entrega do email não puder ser concluída. O padrão é `true`.
#### `config.action_mailer.delivery_method`

Define o método de entrega e o padrão é `:smtp`. Consulte a [seção de configuração no guia do Action Mailer](action_mailer_basics.html#action-mailer-configuration) para mais informações.

#### `config.action_mailer.perform_deliveries`

Especifica se o email será realmente entregue e é `true` por padrão. Pode ser conveniente definir como `false` para testes.

#### `config.action_mailer.default_options`

Configura as opções padrão do Action Mailer. Use para definir opções como `from` ou `reply_to` para cada mailer. Por padrão, são:

```ruby
mime_version:  "1.0",
charset:       "UTF-8",
content_type: "text/plain",
parts_order:  ["text/plain", "text/enriched", "text/html"]
```

Atribua um hash para definir opções adicionais:

```ruby
config.action_mailer.default_options = {
  from: "noreply@example.com"
}
```

#### `config.action_mailer.observers`

Registra observadores que serão notificados quando o email for entregue.

```ruby
config.action_mailer.observers = ["MailObserver"]
```

#### `config.action_mailer.interceptors`

Registra interceptadores que serão chamados antes do envio do email.

```ruby
config.action_mailer.interceptors = ["MailInterceptor"]
```

#### `config.action_mailer.preview_interceptors`

Registra interceptadores que serão chamados antes da visualização do email.

```ruby
config.action_mailer.preview_interceptors = ["MyPreviewMailInterceptor"]
```

#### `config.action_mailer.preview_paths`

Especifica os locais das visualizações dos mailers. Adicionar caminhos a essa opção de configuração fará com que esses caminhos sejam usados na busca por visualizações dos mailers.

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

#### `config.action_mailer.show_previews`

Ativa ou desativa as visualizações dos mailers. Por padrão, isso é `true` no ambiente de desenvolvimento.

```ruby
config.action_mailer.show_previews = false
```

#### `config.action_mailer.perform_caching`

Especifica se os templates dos mailers devem realizar o cache de fragmentos ou não. Se não for especificado, o padrão será `true`.

#### `config.action_mailer.deliver_later_queue_name`

Especifica a fila do Active Job a ser usada para o job de entrega padrão (veja `config.action_mailer.delivery_job`). Quando essa opção é definida como `nil`, os jobs de entrega são enviados para a fila padrão do Active Job (veja `config.active_job.default_queue_name`).

As classes de mailer podem substituir isso para usar uma fila diferente. Observe que isso só se aplica ao usar o job de entrega padrão. Se o mailer estiver usando um job personalizado, sua fila será usada.

Certifique-se de que o adaptador do Active Job também esteja configurado para processar a fila especificada, caso contrário, os jobs de entrega podem ser ignorados silenciosamente.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `:mailers`       |
| 6.1                | `nil`            |

#### `config.action_mailer.delivery_job`

Especifica o job de entrega para o mailer.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `ActionMailer::MailDeliveryJob` |
| 6.0                | `"ActionMailer::MailDeliveryJob"` |

### Configurando o Active Support

Existem algumas opções de configuração disponíveis no Active Support:

#### `config.active_support.bare`

Ativa ou desativa o carregamento de `active_support/all` ao inicializar o Rails. O padrão é `nil`, o que significa que `active_support/all` é carregado.

#### `config.active_support.test_order`

Define a ordem em que os casos de teste são executados. Os valores possíveis são `:random` e `:sorted`. O padrão é `:random`.

#### `config.active_support.escape_html_entities_in_json`

Ativa ou desativa a escapagem de entidades HTML na serialização JSON. O padrão é `true`.

#### `config.active_support.use_standard_json_time_format`

Ativa ou desativa a serialização de datas no formato ISO 8601. O padrão é `true`.

#### `config.active_support.time_precision`

Define a precisão dos valores de tempo codificados em JSON. O padrão é `3`.

#### `config.active_support.hash_digest_class`

Permite configurar a classe de digest para gerar digests não sensíveis, como o cabeçalho ETag.

O valor padrão depende da versão de destino `config.load_defaults`:
| A partir da versão | O valor padrão é |
| --------------------- | -------------------- |
| (original)            | `OpenSSL::Digest::MD5` |
| 5.2                   | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.key_generator_hash_digest_class`

Permite configurar a classe de digest para derivar segredos da base de segredos configurada, como para cookies criptografados.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| --------------------- | -------------------- |
| (original)            | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.use_authenticated_message_encryption`

Especifica se deve usar a criptografia autenticada AES-256-GCM como o cifrador padrão para criptografar mensagens em vez de AES-256-CBC.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 5.2                   | `true`               |

#### `config.active_support.message_serializer`

Especifica o serializador padrão usado pelas instâncias [`ActiveSupport::MessageEncryptor`][]
e [`ActiveSupport::MessageVerifier`][]. Para facilitar a migração entre
serializadores, os serializadores fornecidos incluem um mecanismo de fallback para
suportar vários formatos de deserialização:

| Serializador | Serializar e deserializar | Deserialização de fallback |
| ---------- | ------------------------- | -------------------- |
| `:marshal` | `Marshal` | `ActiveSupport::JSON`, `ActiveSupport::MessagePack` |
| `:json` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack` |
| `:json_allow_marshal` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack`, `Marshal` |
| `:message_pack` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON` |
| `:message_pack_allow_marshal` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON`, `Marshal` |

AVISO: `Marshal` é um vetor potencial para ataques de deserialização em casos
em que um segredo de assinatura de mensagem tenha sido vazado. _Se possível, escolha um
serializador que não suporte `Marshal`._

INFO: Os serializadores `:message_pack` e `:message_pack_allow_marshal` suportam
a ida e volta de alguns tipos Ruby que não são suportados por JSON, como `Symbol`.
Eles também podem fornecer melhor desempenho e tamanhos menores de carga útil. No entanto,
eles requerem a gem [`msgpack`](https://rubygems.org/gems/msgpack).

Cada um dos serializadores acima emitirá uma notificação de evento [`message_serializer_fallback.active_support`][]
quando eles recorrerem a um formato de deserialização alternativo,
permitindo que você acompanhe com que frequência ocorrem esses fallbacks.

Alternativamente, você pode especificar qualquer objeto serializador que responda aos métodos `dump` e
`load`. Por exemplo:

```ruby
config.active_job.message_serializer = YAML
```

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| --------------------- | -------------------- |
| (original)            | `:marshal`           |
| 7.1                   | `:json_allow_marshal` |


#### `config.active_support.use_message_serializer_for_metadata`

Quando `true`, permite uma otimização de desempenho que serializa dados de mensagem e
metadados juntos. Isso altera o formato da mensagem, portanto, mensagens serializadas desta
forma não podem ser lidas por versões mais antigas (< 7.1) do Rails. No entanto, mensagens que
usam o formato antigo ainda podem ser lidas, independentemente de essa otimização estar
habilitada.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_support.cache_format_version`

Especifica qual formato de serialização usar para o cache. Os valores possíveis são
`6.1`, `7.0` e `7.1`.

Os formatos `6.1`, `7.0` e `7.1` usam todos `Marshal` para o codificador padrão, mas
`7.0` usa uma representação mais eficiente para entradas de cache e `7.1` inclui
uma otimização adicional para valores de string simples, como fragmentos de visualização.
Todos os formatos são compatíveis com versões anteriores e posteriores, o que significa que as entradas de cache escritas em um formato podem ser lidas ao usar outro formato. Esse comportamento facilita a migração entre formatos sem invalidar todo o cache.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `6.1`            |
| 7.0                | `7.0`            |
| 7.1                | `7.1`            |

#### `config.active_support.deprecation`

Configura o comportamento das mensagens de depreciação. As opções são `:raise`, `:stderr`, `:log`, `:notify` e `:silence`.

Nos arquivos `config/environments` gerados por padrão, isso é definido como `:log` para desenvolvimento e `:stderr` para teste, e é omitido para produção em favor de [`config.active_support.report_deprecations`](#config-active-support-report-deprecations).

#### `config.active_support.disallowed_deprecation`

Configura o comportamento das mensagens de depreciação não permitidas. As opções são `:raise`, `:stderr`, `:log`, `:notify` e `:silence`.

Nos arquivos `config/environments` gerados por padrão, isso é definido como `:raise` tanto para desenvolvimento quanto para teste, e é omitido para produção em favor de [`config.active_support.report_deprecations`](#config-active-support-report-deprecations).

#### `config.active_support.disallowed_deprecation_warnings`

Configura as mensagens de depreciação que a aplicação considera não permitidas. Isso permite, por exemplo, que depreciações específicas sejam tratadas como falhas graves.

#### `config.active_support.report_deprecations`

Quando `false`, desativa todas as mensagens de depreciação, incluindo as depreciações não permitidas, dos [deprecators da aplicação](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators). Isso inclui todas as depreciações do Rails e de outras gems que podem adicionar seu deprecator à coleção de deprecators, mas pode não impedir todas as mensagens de depreciação emitidas por ActiveSupport::Deprecation.

Nos arquivos `config/environments` gerados por padrão, isso é definido como `false` para produção.

#### `config.active_support.isolation_level`

Configura a localidade da maioria do estado interno do Rails. Se você usar um servidor ou processador de tarefas baseado em fibers (por exemplo, `falcon`), você deve definir como `:fiber`. Caso contrário, é melhor usar a localidade `:thread`. O valor padrão é `:thread`.

#### `config.active_support.executor_around_test_case`

Configura o conjunto de testes para chamar `Rails.application.executor.wrap` ao redor dos casos de teste. Isso faz com que os casos de teste se comportem mais próximos de uma solicitação ou tarefa real. Várias funcionalidades que normalmente são desabilitadas nos testes, como o cache de consultas do Active Record e consultas assíncronas, serão habilitadas.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.0                | `true`           |

#### `ActiveSupport::Logger.silencer`

É definido como `false` para desabilitar a capacidade de silenciar o registro em um bloco. O valor padrão é `true`.

#### `ActiveSupport::Cache::Store.logger`

Especifica o logger a ser usado nas operações de cache store.

#### `ActiveSupport.to_time_preserves_timezone`

Especifica se os métodos `to_time` preservam o deslocamento UTC de seus receptores. Se `false`, os métodos `to_time` converterão para o deslocamento UTC do sistema local.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 5.0                | `true`           |

#### `ActiveSupport.utc_to_local_returns_utc_offset_times`

Configura `ActiveSupport::TimeZone.utc_to_local` para retornar um horário com um deslocamento UTC em vez de um horário UTC incorporando esse deslocamento.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 6.1                | `true`           |
#### `config.active_support.raise_on_invalid_cache_expiration_time`

Especifica se um `ArgumentError` deve ser lançado se `Rails.cache` `fetch` ou `write` receberem um tempo de `expires_at` ou `expires_in` inválido.

As opções são `true` e `false`. Se for `false`, a exceção será relatada como `tratada` e registrada.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.1                | `true`           |

### Configurando o Active Job

`config.active_job` fornece as seguintes opções de configuração:

#### `config.active_job.queue_adapter`

Define o adaptador para o backend de fila. O adaptador padrão é `:async`. Para obter uma lista atualizada de adaptadores integrados, consulte a [documentação da API ActiveJob::QueueAdapters](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html).

```ruby
# Certifique-se de ter o gem do adaptador em seu Gemfile
# e siga as instruções específicas de instalação
# e implantação do adaptador.
config.active_job.queue_adapter = :sidekiq
```

#### `config.active_job.default_queue_name`

Pode ser usado para alterar o nome da fila padrão. Por padrão, é `"default"`.

```ruby
config.active_job.default_queue_name = :medium_priority
```

#### `config.active_job.queue_name_prefix`

Permite definir um prefixo de nome de fila opcional e não vazio para todos os jobs. Por padrão, está vazio e não é usado.

A seguinte configuração colocaria o job fornecido na fila `production_high_priority` quando executado em produção:

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

Tem um valor padrão de `'_'`. Se `queue_name_prefix` for definido, então `queue_name_delimiter` junta o prefixo e o nome da fila sem prefixo.

A seguinte configuração colocaria o job fornecido na fila `video_server.low_priority`:

```ruby
# o prefixo deve ser definido para que o delimitador seja usado
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

Aceita um logger que segue a interface do Log4r ou a classe padrão de logger do Ruby, que é então usado para registrar informações do Active Job. Você pode obter esse logger chamando `logger` em uma classe Active Job ou em uma instância Active Job. Defina como `nil` para desativar o registro.

#### `config.active_job.custom_serializers`

Permite definir serializadores de argumento personalizados. O valor padrão é `[]`.

#### `config.active_job.log_arguments`

Controla se os argumentos de um job são registrados. O valor padrão é `true`.

#### `config.active_job.verbose_enqueue_logs`

Especifica se as localizações de origem dos métodos que enfileiram jobs em segundo plano devem ser registradas abaixo das linhas de registro relevantes. Por padrão, a flag é `true` no ambiente de desenvolvimento e `false` em todos os outros ambientes.

#### `config.active_job.retry_jitter`

Controla a quantidade de "jitter" (variação aleatória) aplicada ao tempo de atraso calculado ao reexecutar jobs falhados.

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `0.0`            |
| 6.1                | `0.15`           |

#### `config.active_job.log_query_tags_around_perform`

Determina se o contexto do job para tags de consulta será atualizado automaticamente via um `around_perform`. O valor padrão é `true`.

#### `config.active_job.use_big_decimal_serializer`

Ativa o novo serializador de argumento `BigDecimal`, que garante a preservação dos dados. Sem esse serializador, alguns adaptadores de fila podem serializar argumentos `BigDecimal` como strings simples (não preserváveis).

AVISO: Ao implantar um aplicativo com várias réplicas, réplicas antigas (anteriores ao Rails 7.1) não poderão desserializar argumentos `BigDecimal` deste serializador. Portanto, essa configuração só deve ser ativada após todas as réplicas terem sido atualizadas com sucesso para o Rails 7.1.
O valor padrão depende da versão alvo `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.1                | `true`           |

### Configurando o Action Cable

#### `config.action_cable.url`

Aceita uma string para a URL onde você está hospedando seu servidor Action Cable. Você usaria essa opção se estiver executando servidores Action Cable separados de sua aplicação principal.

#### `config.action_cable.mount_path`

Aceita uma string para onde montar o Action Cable, como parte do processo do servidor principal. O padrão é `/cable`. Você pode definir isso como nulo para não montar o Action Cable como parte do seu servidor Rails normal.

Você pode encontrar mais opções de configuração detalhadas na [Visão geral do Action Cable](action_cable_overview.html#configuration).

#### `config.action_cable.precompile_assets`

Determina se os ativos do Action Cable devem ser adicionados à pré-compilação do pipeline de ativos. Isso não tem efeito se o Sprockets não for usado. O valor padrão é `true`.

### Configurando o Active Storage

`config.active_storage` fornece as seguintes opções de configuração:

#### `config.active_storage.variant_processor`

Aceita um símbolo `:mini_magick` ou `:vips`, especificando se as transformações de variantes e análises de blob serão realizadas com o MiniMagick ou o ruby-vips.

O valor padrão depende da versão alvo `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `:mini_magick`   |
| 7.0                | `:vips`          |

#### `config.active_storage.analyzers`

Aceita uma matriz de classes indicando os analisadores disponíveis para os blobs do Active Storage. Por padrão, isso é definido como:

```ruby
config.active_storage.analyzers = [ActiveStorage::Analyzer::ImageAnalyzer::Vips, ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick, ActiveStorage::Analyzer::VideoAnalyzer, ActiveStorage::Analyzer::AudioAnalyzer]
```

Os analisadores de imagem podem extrair largura e altura de um blob de imagem; o analisador de vídeo pode extrair largura, altura, duração, ângulo, proporção de aspecto e presença/ausência de canais de vídeo/áudio de um blob de vídeo; o analisador de áudio pode extrair duração e taxa de bits de um blob de áudio.

#### `config.active_storage.previewers`

Aceita uma matriz de classes indicando os visualizadores de imagem disponíveis nos blobs do Active Storage. Por padrão, isso é definido como:

```ruby
config.active_storage.previewers = [ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer]
```

`PopplerPDFPreviewer` e `MuPDFPreviewer` podem gerar uma miniatura da primeira página de um blob PDF; `VideoPreviewer` do quadro relevante de um blob de vídeo.

#### `config.active_storage.paths`

Aceita um hash de opções indicando os locais dos comandos do visualizador/analisador. O padrão é `{}`, o que significa que os comandos serão procurados no caminho padrão. Pode incluir qualquer uma dessas opções:

* `:ffprobe` - O local do executável ffprobe.
* `:mutool` - O local do executável mutool.
* `:ffmpeg` - O local do executável ffmpeg.

```ruby
config.active_storage.paths[:ffprobe] = '/usr/local/bin/ffprobe'
```

#### `config.active_storage.variable_content_types`

Aceita uma matriz de strings indicando os tipos de conteúdo que o Active Storage pode transformar por meio do processador de variantes. Por padrão, isso é definido como:

```ruby
config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/bmp image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)
```

#### `config.active_storage.web_image_content_types`

Aceita uma matriz de strings consideradas como tipos de conteúdo de imagem da web nos quais as variantes podem ser processadas sem serem convertidas para o formato PNG de fallback. Se você quiser usar variantes `WebP` ou `AVIF` em sua aplicação, pode adicionar `image/webp` ou `image/avif` a esta matriz. Por padrão, isso é definido como:
```ruby
config.active_storage.web_image_content_types = %w(image/png image/jpeg image/gif)
```

#### `config.active_storage.content_types_to_serve_as_binary`

Aceita um array de strings indicando os tipos de conteúdo que o Active Storage sempre servirá como um anexo, em vez de inline.
Por padrão, isso é definido como:

```ruby
config.active_storage.content_types_to_serve_as_binary = %w(text/html image/svg+xml application/postscript application/x-shockwave-flash text/xml application/xml application/xhtml+xml application/mathml+xml text/cache-manifest)
```

#### `config.active_storage.content_types_allowed_inline`

Aceita um array de strings indicando os tipos de conteúdo que o Active Storage permite servir como inline.
Por padrão, isso é definido como:

```ruby
config.active_storage.content_types_allowed_inline` = %w(image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon application/pdf)
```

#### `config.active_storage.queues.analysis`

Aceita um símbolo indicando a fila do Active Job a ser usada para jobs de análise. Quando essa opção é `nil`, os jobs de análise são enviados para a fila padrão do Active Job (veja `config.active_job.default_queue_name`).

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| 6.0                | `:active_storage_analysis` |
| 6.1                | `nil`            |

#### `config.active_storage.queues.purge`

Aceita um símbolo indicando a fila do Active Job a ser usada para jobs de purga. Quando essa opção é `nil`, os jobs de purga são enviados para a fila padrão do Active Job (veja `config.active_job.default_queue_name`).

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| 6.0                | `:active_storage_purge` |
| 6.1                | `nil`            |

#### `config.active_storage.queues.mirror`

Aceita um símbolo indicando a fila do Active Job a ser usada para jobs de espelhamento de upload direto. Quando essa opção é `nil`, os jobs de espelhamento são enviados para a fila padrão do Active Job (veja `config.active_job.default_queue_name`). O padrão é `nil`.

#### `config.active_storage.logger`

Pode ser usado para definir o logger usado pelo Active Storage. Aceita um logger que segue a interface do Log4r ou a classe padrão Ruby Logger.

```ruby
config.active_storage.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.active_storage.service_urls_expire_in`

Determina a expiração padrão das URLs geradas por:

* `ActiveStorage::Blob#url`
* `ActiveStorage::Blob#service_url_for_direct_upload`
* `ActiveStorage::Variant#url`

O padrão é de 5 minutos.

#### `config.active_storage.urls_expire_in`

Determina a expiração padrão das URLs na aplicação Rails geradas pelo Active Storage. O padrão é `nil`.

#### `config.active_storage.routes_prefix`

Pode ser usado para definir o prefixo de rota para as rotas servidas pelo Active Storage. Aceita uma string que será adicionada ao início das rotas geradas.

```ruby
config.active_storage.routes_prefix = '/files'
```

O padrão é `/rails/active_storage`.

#### `config.active_storage.track_variants`

Determina se as variantes são registradas no banco de dados.

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 6.1                | `true`           |

#### `config.active_storage.draw_routes`

Pode ser usado para ativar ou desativar a geração de rotas do Active Storage. O padrão é `true`.

#### `config.active_storage.resolve_model_to_route`

Pode ser usado para alterar globalmente como os arquivos do Active Storage são entregues.

Os valores permitidos são:

* `:rails_storage_redirect`: Redireciona para URLs de serviço assinadas e de curta duração.
* `:rails_storage_proxy`: Proxy de arquivos fazendo download deles.

O padrão é `:rails_storage_redirect`.

#### `config.active_storage.video_preview_arguments`

Pode ser usado para alterar a forma como o ffmpeg gera imagens de pré-visualização de vídeo.

O valor padrão depende da versão alvo de `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `"-y -vframes 1 -f image2"` |
| 7.0                | `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015)"`<sup><mark><strong><em>1</em></strong></mark></sup> <br> `+ ",loop=loop=-1:size=2,trim=start_frame=1'"`<sup><mark><strong><em>2</em></strong></mark></sup><br> `+ " -frames:v 1 -f image2"` <br><br> <ol><li>Seleciona o primeiro quadro de vídeo, além de keyframes e quadros que atendem ao limite de mudança de cena.</li> <li>Usa o primeiro quadro de vídeo como fallback quando nenhum outro quadro atende aos critérios, fazendo um loop do primeiro (um ou) dois quadros selecionados e, em seguida, descartando o primeiro quadro em loop.</li></ol> |
#### `config.active_storage.multiple_file_field_include_hidden`

No Rails 7.1 em diante, os relacionamentos `has_many_attached` do Active Storage serão substituídos pela coleção atual em vez de serem adicionados a ela. Assim, para suportar o envio de uma coleção _vazia_, quando `multiple_file_field_include_hidden` for `true`, o helper [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) renderizará um campo oculto auxiliar, semelhante ao campo auxiliar renderizado pelo helper [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box).

O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `false`          |
| 7.0                | `true`           |

#### `config.active_storage.precompile_assets`

Determina se os assets do Active Storage devem ser adicionados à pré-compilação do pipeline de assets. Isso não tem efeito se o Sprockets não for usado. O valor padrão é `true`.

### Configurando o Action Text

#### `config.action_text.attachment_tag_name`

Aceita uma string para a tag HTML usada para envolver os anexos. O valor padrão é `"action-text-attachment"`.

#### `config.action_text.sanitizer_vendor`

Configura o sanitizador HTML usado pelo Action Text definindo `ActionText::ContentHelper.sanitizer` como uma instância da classe retornada pelo método `.safe_list_sanitizer` do fornecedor. O valor padrão depende da versão de destino `config.load_defaults`:

| A partir da versão | O valor padrão é                 | Que analisa a marcação como |
|------------------- |---------------------------------|-------------------------------|
| (original)         | `Rails::HTML4::Sanitizer`        | HTML4                         |
| 7.1                | `Rails::HTML5::Sanitizer` (ver NOTA) | HTML5                         |

NOTA: `Rails::HTML5::Sanitizer` não é suportado no JRuby, então em plataformas JRuby o Rails usará `Rails::HTML4::Sanitizer`.

### Configurando um Banco de Dados

Praticamente toda aplicação Rails irá interagir com um banco de dados. Você pode se conectar ao banco de dados definindo uma variável de ambiente `ENV['DATABASE_URL']` ou usando um arquivo de configuração chamado `config/database.yml`.

Usando o arquivo `config/database.yml`, você pode especificar todas as informações necessárias para acessar o seu banco de dados:

```yaml
development:
  adapter: postgresql
  database: blog_development
  pool: 5
```

Isso irá se conectar ao banco de dados chamado `blog_development` usando o adaptador `postgresql`. Essas mesmas informações podem ser armazenadas em uma URL e fornecidas por meio de uma variável de ambiente, como:

```ruby
ENV['DATABASE_URL'] # => "postgresql://localhost/blog_development?pool=5"
```

O arquivo `config/database.yml` contém seções para três ambientes diferentes nos quais o Rails pode ser executado por padrão:

* O ambiente `development` é usado em seu computador de desenvolvimento/local, enquanto você interage manualmente com a aplicação.
* O ambiente `test` é usado ao executar testes automatizados.
* O ambiente `production` é usado ao implantar a aplicação para o mundo usar.

Se desejar, você pode especificar manualmente uma URL dentro do seu `config/database.yml`

```yaml
development:
  url: postgresql://localhost/blog_development?pool=5
```

O arquivo `config/database.yml` pode conter tags ERB `<%= %>`. Qualquer coisa dentro das tags será avaliada como código Ruby. Você pode usar isso para extrair dados de uma variável de ambiente ou para realizar cálculos para gerar as informações de conexão necessárias.

DICA: Você não precisa atualizar as configurações do banco de dados manualmente. Se você olhar as opções do gerador de aplicativos, verá que uma das opções é chamada `--database`. Essa opção permite que você escolha um adaptador de uma lista dos bancos de dados relacionais mais usados. Você pode até executar o gerador repetidamente: `cd .. && rails new blog --database=mysql`. Quando você confirmar a substituição do arquivo `config/database.yml`, sua aplicação será configurada para o MySQL em vez do SQLite. Exemplos detalhados das conexões comuns de banco de dados estão abaixo.
### Preferência de Conexão

Como existem duas maneiras de configurar sua conexão (usando `config/database.yml` ou usando uma variável de ambiente), é importante entender como elas podem interagir.

Se você tiver um arquivo `config/database.yml` vazio, mas sua `ENV['DATABASE_URL']` estiver presente, o Rails se conectará ao banco de dados por meio da sua variável de ambiente:

```bash
$ cat config/database.yml

$ echo $DATABASE_URL
postgresql://localhost/my_database
```

Se você tiver um `config/database.yml`, mas não tiver `ENV['DATABASE_URL']`, então esse arquivo será usado para se conectar ao seu banco de dados:

```bash
$ cat config/database.yml
development:
  adapter: postgresql
  database: my_database
  host: localhost

$ echo $DATABASE_URL
```

Se você tiver tanto `config/database.yml` quanto `ENV['DATABASE_URL']` definidos, o Rails mesclará as configurações. Para entender melhor isso, devemos ver alguns exemplos.

Quando informações de conexão duplicadas são fornecidas, a variável de ambiente tem prioridade:

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

Aqui, o adaptador, host e banco de dados correspondem às informações em `ENV['DATABASE_URL']`.

Se informações não duplicadas forem fornecidas, você obterá todos os valores exclusivos, sendo que a variável de ambiente ainda tem prioridade em caso de conflitos.

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

Como o pool não está presente nas informações de conexão fornecidas em `ENV['DATABASE_URL']`, suas informações são mescladas. Como o adaptador é duplicado, as informações de conexão em `ENV['DATABASE_URL']` prevalecem.

A única maneira de explicitamente não usar as informações de conexão em `ENV['DATABASE_URL']` é especificar uma conexão URL explícita usando a subchave `"url"`:

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

Aqui, as informações de conexão em `ENV['DATABASE_URL']` são ignoradas, observe o adaptador e o nome do banco de dados diferentes.

Como é possível incorporar ERB em seu `config/database.yml`, é uma boa prática mostrar explicitamente que você está usando `ENV['DATABASE_URL']` para se conectar ao seu banco de dados. Isso é especialmente útil em produção, pois você não deve incluir segredos, como a senha do banco de dados, no controle de versão (como o Git).

```bash
$ cat config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

Agora o comportamento está claro, estamos usando apenas as informações de conexão em `ENV['DATABASE_URL']`.

#### Configurando um Banco de Dados SQLite3

O Rails vem com suporte integrado ao [SQLite3](http://www.sqlite.org), que é um aplicativo de banco de dados leve e sem servidor. Embora um ambiente de produção movimentado possa sobrecarregar o SQLite, ele funciona bem para desenvolvimento e testes. O Rails usa um banco de dados SQLite como padrão ao criar um novo projeto, mas você sempre pode alterá-lo posteriormente.

Aqui está a seção do arquivo de configuração padrão (`config/database.yml`) com informações de conexão para o ambiente de desenvolvimento:

```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

NOTA: O Rails usa um banco de dados SQLite3 para armazenamento de dados por padrão porque é um banco de dados de configuração zero que funciona perfeitamente. O Rails também oferece suporte ao MySQL (incluindo o MariaDB) e ao PostgreSQL "pronto para uso" e possui plugins para muitos sistemas de banco de dados. Se você estiver usando um banco de dados em um ambiente de produção, é muito provável que o Rails tenha um adaptador para ele.
#### Configurando um Banco de Dados MySQL ou MariaDB

Se você optar por usar o MySQL ou MariaDB em vez do banco de dados SQLite3 fornecido, seu `config/database.yml` ficará um pouco diferente. Aqui está a seção de desenvolvimento:

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

Se o seu banco de dados de desenvolvimento tiver um usuário root com uma senha vazia, essa configuração deve funcionar para você. Caso contrário, altere o nome de usuário e a senha na seção `development` conforme apropriado.

NOTA: Se a sua versão do MySQL for 5.5 ou 5.6 e você desejar usar o conjunto de caracteres `utf8mb4` por padrão, configure o seu servidor MySQL para suportar o prefixo de chave mais longo, ativando a variável de sistema `innodb_large_prefix`.

As travas de assessoria estão habilitadas por padrão no MySQL e são usadas para tornar as migrações de banco de dados seguras em paralelo. Você pode desabilitar as travas de assessoria definindo `advisory_locks` como `false`:

```yaml
production:
  adapter: mysql2
  advisory_locks: false
```

#### Configurando um Banco de Dados PostgreSQL

Se você optar por usar o PostgreSQL, seu `config/database.yml` será personalizado para usar bancos de dados PostgreSQL:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: blog_development
  pool: 5
```

Por padrão, o Active Record usa recursos do banco de dados, como declarações preparadas e travas de assessoria. Você pode precisar desabilitar esses recursos se estiver usando um pool de conexões externo, como o PgBouncer:

```yaml
production:
  adapter: postgresql
  prepared_statements: false
  advisory_locks: false
```

Se ativado, o Active Record criará até `1000` declarações preparadas por conexão de banco de dados por padrão. Para modificar esse comportamento, você pode definir `statement_limit` para um valor diferente:

```yaml
production:
  adapter: postgresql
  statement_limit: 200
```

Quanto mais declarações preparadas em uso, mais memória seu banco de dados exigirá. Se o seu banco de dados PostgreSQL estiver atingindo limites de memória, tente reduzir `statement_limit` ou desabilitar as declarações preparadas.

#### Configurando um Banco de Dados SQLite3 para a Plataforma JRuby

Se você optar por usar o SQLite3 e estiver usando o JRuby, seu `config/database.yml` ficará um pouco diferente. Aqui está a seção de desenvolvimento:

```yaml
development:
  adapter: jdbcsqlite3
  database: storage/development.sqlite3
```

#### Configurando um Banco de Dados MySQL ou MariaDB para a Plataforma JRuby

Se você optar por usar o MySQL ou MariaDB e estiver usando o JRuby, seu `config/database.yml` ficará um pouco diferente. Aqui está a seção de desenvolvimento:

```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```

#### Configurando um Banco de Dados PostgreSQL para a Plataforma JRuby

Se você optar por usar o PostgreSQL e estiver usando o JRuby, seu `config/database.yml` ficará um pouco diferente. Aqui está a seção de desenvolvimento:

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

Altere o nome de usuário e a senha na seção `development` conforme apropriado.

#### Configurando o Armazenamento de Metadados

Por padrão, o Rails armazenará informações sobre o ambiente do Rails e o esquema em uma tabela interna chamada `ar_internal_metadata`.

Para desativar isso por conexão, defina `use_metadata_table` em sua configuração de banco de dados. Isso é útil ao trabalhar com um banco de dados compartilhado e/ou usuário de banco de dados que não pode criar tabelas.

```yaml
development:
  adapter: postgresql
  use_metadata_table: false
```

#### Configurando o Comportamento de Retentativa

Por padrão, o Rails reconectará automaticamente ao servidor do banco de dados e tentará novamente determinadas consultas se algo der errado. Somente consultas seguramente retentáveis (idempotentes) serão refeitas. O número de retentativas pode ser especificado na configuração do banco de dados por meio de `connection_retries`, ou desativado definindo o valor como 0. O número padrão de retentativas é 1.
```yaml
development:
  adapter: mysql2
  connection_retries: 3
```

A configuração do banco de dados também permite configurar um `retry_deadline`. Se um `retry_deadline` for configurado,
uma consulta que seria retratável não será refeita se o tempo especificado tiver passado desde a primeira tentativa da consulta.
Por exemplo, um `retry_deadline` de 5 segundos significa que se 5 segundos se passaram desde a primeira tentativa de uma consulta,
a consulta não será refeita, mesmo que seja idempotente e ainda haja `connection_retries` restantes.

O valor padrão para essa configuração é nulo, o que significa que todas as consultas retratáveis são refeitas independentemente do tempo decorrido.
O valor para essa configuração deve ser especificado em segundos.

```yaml
development:
  adapter: mysql2
  retry_deadline: 5 # Parar de refazer consultas após 5 segundos
```

#### Configurando o Cache de Consultas

Por padrão, o Rails armazena em cache automaticamente os conjuntos de resultados retornados pelas consultas. Se o Rails encontrar a mesma consulta
novamente para a mesma solicitação ou tarefa, ele usará o conjunto de resultados em cache em vez de executar a consulta novamente no
banco de dados.

O cache de consultas é armazenado na memória e, para evitar o uso excessivo de memória, ele remove automaticamente as consultas menos recentemente
usadas ao atingir um limite. Por padrão, o limite é `100`, mas pode ser configurado no `database.yml`.

```yaml
development:
  adapter: mysql2
  query_cache: 200
```

Para desativar completamente o cache de consultas, ele pode ser definido como `false`

```yaml
development:
  adapter: mysql2
  query_cache: false
```

### Criando Ambientes no Rails

Por padrão, o Rails vem com três ambientes: "development", "test" e "production". Embora esses sejam suficientes para a maioria dos casos de uso, há circunstâncias em que você deseja ter mais ambientes.

Imagine que você tenha um servidor que espelha o ambiente de produção, mas é usado apenas para testes. Esse servidor é comumente chamado de "servidor de staging". Para definir um ambiente chamado "staging" para esse servidor, basta criar um arquivo chamado `config/environments/staging.rb`. Como esse é um ambiente semelhante ao de produção, você pode copiar o conteúdo de `config/environments/production.rb` como ponto de partida e fazer as alterações necessárias a partir daí. Também é possível requerer e estender outras configurações de ambiente dessa maneira:

```ruby
# config/environments/staging.rb
require_relative "production"

Rails.application.configure do
  # Sobrescritas de staging
end
```

Esse ambiente não é diferente dos ambientes padrão, inicie um servidor com `bin/rails server -e staging`, um console com `bin/rails console -e staging`, `Rails.env.staging?` funciona, etc.

### Implantação em um Subdiretório (root URL relativo)

Por padrão, o Rails espera que sua aplicação esteja sendo executada na raiz
(por exemplo, `/`). Esta seção explica como executar sua aplicação dentro de um diretório.

Vamos supor que queremos implantar nossa aplicação em "/app1". O Rails precisa saber
esse diretório para gerar as rotas apropriadas:

```ruby
config.relative_url_root = "/app1"
```

alternativamente, você pode definir a variável de ambiente `RAILS_RELATIVE_URL_ROOT`.

Agora o Rails irá adicionar "/app1" ao gerar links.

#### Usando o Passenger

O Passenger facilita a execução de sua aplicação em um subdiretório. Você pode encontrar a configuração relevante no [manual do Passenger](https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/#deploying-an-app-to-a-sub-uri-or-subdirectory).

#### Usando um Proxy Reverso

Implantar sua aplicação usando um proxy reverso tem vantagens definitivas em relação às implantações tradicionais. Eles permitem que você tenha mais controle sobre seu servidor, sobrepondo os componentes necessários para sua aplicação.
Muitos servidores web modernos podem ser usados como um servidor proxy para balancear elementos de terceiros, como servidores de cache ou servidores de aplicativos.

Um servidor de aplicativos que você pode usar é o [Unicorn](https://bogomips.org/unicorn/) para rodar atrás de um proxy reverso.

Nesse caso, você precisaria configurar o servidor proxy (NGINX, Apache, etc) para aceitar conexões do seu servidor de aplicativos (Unicorn). Por padrão, o Unicorn irá ouvir conexões TCP na porta 8080, mas você pode alterar a porta ou configurá-lo para usar sockets.

Você pode encontrar mais informações no [readme do Unicorn](https://bogomips.org/unicorn/README.html) e entender a [filosofia](https://bogomips.org/unicorn/PHILOSOPHY.html) por trás dele.

Depois de configurar o servidor de aplicativos, você deve redirecionar as solicitações para ele configurando corretamente o seu servidor web. Por exemplo, a configuração do NGINX pode incluir:

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

  # alguma outra configuração
}
```

Certifique-se de ler a [documentação do NGINX](https://nginx.org/en/docs/) para obter as informações mais atualizadas.


Configurações do Ambiente Rails
--------------------------

Algumas partes do Rails também podem ser configuradas externamente fornecendo variáveis de ambiente. As seguintes variáveis de ambiente são reconhecidas por várias partes do Rails:

* `ENV["RAILS_ENV"]` define o ambiente Rails (produção, desenvolvimento, teste, etc.) no qual o Rails será executado.

* `ENV["RAILS_RELATIVE_URL_ROOT"]` é usado pelo código de roteamento para reconhecer URLs quando você [implanta sua aplicação em um subdiretório](configuring.html#deploy-to-a-subdirectory-relative-url-root).

* `ENV["RAILS_CACHE_ID"]` e `ENV["RAILS_APP_VERSION"]` são usados para gerar chaves de cache expandidas no código de cache do Rails. Isso permite que você tenha vários caches separados da mesma aplicação.


Usando Arquivos de Inicialização
-----------------------

Após carregar o framework e quaisquer gems em sua aplicação, o Rails passa a carregar os inicializadores. Um inicializador é qualquer arquivo Ruby armazenado em `config/initializers` em sua aplicação. Você pode usar inicializadores para armazenar configurações que devem ser feitas após o carregamento de todos os frameworks e gems, como opções para configurar essas partes.

Os arquivos em `config/initializers` (e quaisquer subdiretórios de `config/initializers`) são ordenados e carregados um por um como parte do inicializador `load_config_initializers`.

Se um inicializador tiver código que dependa de código em outro inicializador, você pode combiná-los em um único inicializador. Isso torna as dependências mais explícitas e pode ajudar a destacar novos conceitos dentro da sua aplicação. O Rails também suporta a numeração dos nomes dos arquivos de inicialização, mas isso pode levar a uma grande quantidade de alterações nos nomes dos arquivos. Carregar explicitamente inicializadores com `require` não é recomendado, pois isso fará com que o inicializador seja carregado duas vezes.

NOTA: Não há garantia de que seus inicializadores serão executados após todos os inicializadores de gems, portanto, qualquer código de inicialização que dependa de uma determinada gem ter sido inicializada deve ser colocado em um bloco `config.after_initialize`.

Eventos de Inicialização
---------------------

O Rails possui 5 eventos de inicialização nos quais você pode se conectar (listados na ordem em que são executados):

* `before_configuration`: Isso é executado assim que a constante de aplicação herda de `Rails::Application`. As chamadas `config` são avaliadas antes disso acontecer.

* `before_initialize`: Isso é executado imediatamente antes do processo de inicialização da aplicação ocorrer com o inicializador `:bootstrap_hook` perto do início do processo de inicialização do Rails.
* `to_prepare`: Executa após a execução dos inicializadores de todas as Railties (incluindo a própria aplicação), mas antes do carregamento antecipado e da construção da pilha de middlewares. Mais importante, será executado a cada recarregamento de código em `development`, mas apenas uma vez (durante a inicialização) em `production` e `test`.

* `before_eager_load`: Isso é executado diretamente antes do carregamento antecipado ocorrer, que é o comportamento padrão para o ambiente `production` e não para o ambiente `development`.

* `after_initialize`: Executa diretamente após a inicialização da aplicação, após a execução dos inicializadores da aplicação em `config/initializers`.

Para definir um evento para esses hooks, use a sintaxe de bloco dentro de uma subclasse `Rails::Application`, `Rails::Railtie` ou `Rails::Engine`:

```ruby
module YourApp
  class Application < Rails::Application
    config.before_initialize do
      # código de inicialização vai aqui
    end
  end
end
```

Alternativamente, você também pode fazer isso através do método `config` no objeto `Rails.application`:

```ruby
Rails.application.config.before_initialize do
  # código de inicialização vai aqui
end
```

AVISO: Algumas partes da sua aplicação, especialmente o roteamento, ainda não estão configuradas no ponto em que o bloco `after_initialize` é chamado.

### `Rails::Railtie#initializer`

O Rails possui vários inicializadores que são executados no início e são todos definidos usando o método `initializer` de `Rails::Railtie`. Aqui está um exemplo do inicializador `set_helpers_path` do Action Controller:

```ruby
initializer "action_controller.set_helpers_path" do |app|
  ActionController::Helpers.helpers_path = app.helpers_paths
end
```

O método `initializer` recebe três argumentos, sendo o primeiro o nome do inicializador, o segundo um hash de opções (não mostrado aqui) e o terceiro um bloco. A chave `:before` no hash de opções pode ser especificada para especificar qual inicializador este novo inicializador deve ser executado antes, e a chave `:after` especificará qual inicializador executar este inicializador _depois_.

Inicializadores definidos usando o método `initializer` serão executados na ordem em que são definidos, com exceção daqueles que usam os métodos `:before` ou `:after`.

AVISO: Você pode colocar seu inicializador antes ou depois de qualquer outro inicializador na cadeia, desde que seja lógico. Digamos que você tenha 4 inicializadores chamados "one" a "four" (definidos nessa ordem) e você define "four" para ir _antes_ de "two" mas _depois_ de "three", isso simplesmente não é lógico e o Rails não será capaz de determinar a ordem dos inicializadores.

O argumento de bloco do método `initializer` é a instância da própria aplicação, e assim podemos acessar a configuração usando o método `config` como feito no exemplo.

Como `Rails::Application` herda de `Rails::Railtie` (indiretamente), você pode usar o método `initializer` em `config/application.rb` para definir inicializadores para a aplicação.

### Inicializadores

Abaixo está uma lista abrangente de todos os inicializadores encontrados no Rails na ordem em que são definidos (e, portanto, executados, a menos que seja especificado de outra forma).

* `load_environment_hook`: Serve como um marcador para que `:load_environment_config` possa ser definido para ser executado antes dele.

* `load_active_support`: Requer `active_support/dependencies`, que configura a base para o Active Support. Opcionalmente, requer `active_support/all` se `config.active_support.bare` não for verdadeiro, que é o padrão.

* `initialize_logger`: Inicializa o logger (um objeto `ActiveSupport::Logger`) para a aplicação e o torna acessível em `Rails.logger`, desde que nenhum inicializador inserido antes desse ponto tenha definido `Rails.logger`.
* `initialize_cache`: Se `Rails.cache` ainda não estiver definido, inicializa o cache referenciando o valor em `config.cache_store` e armazena o resultado como `Rails.cache`. Se esse objeto responder ao método `middleware`, seu middleware é inserido antes de `Rack::Runtime` na pilha de middlewares.

* `set_clear_dependencies_hook`: Este inicializador - que é executado apenas se `config.enable_reloading` estiver definido como `true` - usa `ActionDispatch::Callbacks.after` para remover as constantes que foram referenciadas durante a solicitação do espaço de objetos, para que sejam recarregadas durante a solicitação seguinte.

* `bootstrap_hook`: Executa todos os blocos configurados em `before_initialize`.

* `i18n.callbacks`: No ambiente de desenvolvimento, configura um retorno de chamada `to_prepare` que chamará `I18n.reload!` se alguma das localidades tiverem sido alteradas desde a última solicitação. Na produção, esse retorno de chamada será executado apenas na primeira solicitação.

* `active_support.deprecation_behavior`: Configura o comportamento de relatório de obsolescência para [`Rails.application.deprecators`][] com base em [`config.active_support.report_deprecations`](#config-active-support-report-deprecations), [`config.active_support.deprecation`](#config-active-support-deprecation), [`config.active_support.disallowed_deprecation`](#config-active-support-disallowed-deprecation) e [`config.active_support.disallowed_deprecation_warnings`](#config-active-support-disallowed-deprecation-warnings).

* `active_support.initialize_time_zone`: Define o fuso horário padrão para a aplicação com base na configuração `config.time_zone`, que é "UTC" por padrão.

* `active_support.initialize_beginning_of_week`: Define o início da semana padrão para a aplicação com base na configuração `config.beginning_of_week`, que é `:monday` por padrão.

* `active_support.set_configs`: Configura o Active Support usando as configurações em `config.active_support`, enviando os nomes dos métodos como setters para `ActiveSupport` e passando os valores.

* `action_dispatch.configure`: Configura `ActionDispatch::Http::URL.tld_length` para o valor de `config.action_dispatch.tld_length`.

* `action_view.set_configs`: Configura o Action View usando as configurações em `config.action_view`, enviando os nomes dos métodos como setters para `ActionView::Base` e passando os valores.

* `action_controller.assets_config`: Inicializa `config.action_controller.assets_dir` para o diretório público do aplicativo, se não estiver configurado explicitamente.

* `action_controller.set_helpers_path`: Define o `helpers_path` do Action Controller para o `helpers_path` do aplicativo.

* `action_controller.parameters_config`: Configura as opções de parâmetros fortes para `ActionController::Parameters`.

* `action_controller.set_configs`: Configura o Action Controller usando as configurações em `config.action_controller`, enviando os nomes dos métodos como setters para `ActionController::Base` e passando os valores.

* `action_controller.compile_config_methods`: Inicializa os métodos para as configurações especificadas para que sejam mais rápidos de acessar.

* `active_record.initialize_timezone`: Define `ActiveRecord::Base.time_zone_aware_attributes` como `true` e também define `ActiveRecord::Base.default_timezone` como UTC. Quando os atributos são lidos do banco de dados, eles serão convertidos para o fuso horário especificado por `Time.zone`.

* `active_record.logger`: Define `ActiveRecord::Base.logger` - se ainda não estiver definido - como `Rails.logger`.

* `active_record.migration_error`: Configura o middleware para verificar se há migrações pendentes.

* `active_record.check_schema_cache_dump`: Carrega o cache de esquema se estiver configurado e disponível.

* `active_record.warn_on_records_fetched_greater_than`: Ativa avisos quando as consultas retornam um grande número de registros.

* `active_record.set_configs`: Configura o Active Record usando as configurações em `config.active_record`, enviando os nomes dos métodos como setters para `ActiveRecord::Base` e passando os valores.

* `active_record.initialize_database`: Carrega a configuração do banco de dados (por padrão) de `config/database.yml` e estabelece uma conexão para o ambiente atual.

* `active_record.log_runtime`: Inclui `ActiveRecord::Railties::ControllerRuntime` e `ActiveRecord::Railties::JobRuntime`, que são responsáveis por relatar o tempo gasto pelas chamadas do Active Record para o logger.

* `active_record.set_reloader_hooks`: Redefine todas as conexões recarregáveis para o banco de dados se `config.enable_reloading` estiver definido como `true`.

* `active_record.add_watchable_files`: Adiciona os arquivos `schema.rb` e `structure.sql` aos arquivos a serem observados.

* `active_job.logger`: Define `ActiveJob::Base.logger` - se ainda não estiver definido - como `Rails.logger`.
* `active_job.set_configs`: Configura o Active Job usando as configurações em `config.active_job`, enviando os nomes dos métodos como setters para `ActiveJob::Base` e passando os valores através deles.

* `action_mailer.logger`: Define `ActionMailer::Base.logger` - se ainda não estiver definido - como `Rails.logger`.

* `action_mailer.set_configs`: Configura o Action Mailer usando as configurações em `config.action_mailer`, enviando os nomes dos métodos como setters para `ActionMailer::Base` e passando os valores através deles.

* `action_mailer.compile_config_methods`: Inicializa os métodos para as configurações especificadas, para que sejam acessados mais rapidamente.

* `set_load_path`: Este inicializador é executado antes de `bootstrap_hook`. Adiciona os caminhos especificados por `config.load_paths` e todos os caminhos de carregamento automático em `$LOAD_PATH`.

* `set_autoload_paths`: Este inicializador é executado antes de `bootstrap_hook`. Adiciona todos os subdiretórios de `app` e os caminhos especificados por `config.autoload_paths`, `config.eager_load_paths` e `config.autoload_once_paths` em `ActiveSupport::Dependencies.autoload_paths`.

* `add_routing_paths`: Carrega (por padrão) todos os arquivos `config/routes.rb` (na aplicação e nas railties, incluindo engines) e configura as rotas para a aplicação.

* `add_locales`: Adiciona os arquivos em `config/locales` (da aplicação, railties e engines) em `I18n.load_path`, tornando as traduções nesses arquivos disponíveis.

* `add_view_paths`: Adiciona o diretório `app/views` da aplicação, railties e engines ao caminho de busca para arquivos de visualização da aplicação.

* `add_mailer_preview_paths`: Adiciona o diretório `test/mailers/previews` da aplicação, railties e engines ao caminho de busca para arquivos de visualização de emails da aplicação.

* `load_environment_config`: Este inicializador é executado antes de `load_environment_hook`. Carrega o arquivo `config/environments` para o ambiente atual.

* `prepend_helpers_path`: Adiciona o diretório `app/helpers` da aplicação, railties e engines ao caminho de busca para helpers da aplicação.

* `load_config_initializers`: Carrega todos os arquivos Ruby de `config/initializers` na aplicação, railties e engines. Os arquivos neste diretório podem ser usados para armazenar configurações que devem ser feitas após o carregamento de todos os frameworks.

* `engines_blank_point`: Fornece um ponto de inicialização para se conectar se você deseja fazer algo antes que as engines sejam carregadas. Após este ponto, todos os inicializadores de railtie e engine são executados.

* `add_generator_templates`: Localiza os modelos para geradores em `lib/templates` para a aplicação, railties e engines, e adiciona-os à configuração `config.generators.templates`, que tornará os modelos disponíveis para todos os geradores referenciarem.

* `ensure_autoload_once_paths_as_subset`: Garante que `config.autoload_once_paths` contenha apenas os caminhos de `config.autoload_paths`. Se contiver caminhos extras, uma exceção será lançada.

* `add_to_prepare_blocks`: O bloco para cada chamada `config.to_prepare` na aplicação, railtie ou engine é adicionado aos callbacks `to_prepare` para Action Dispatch, que serão executados por solicitação no desenvolvimento ou antes da primeira solicitação na produção.

* `add_builtin_route`: Se a aplicação estiver sendo executada no ambiente de desenvolvimento, isso adicionará a rota para `rails/info/properties` às rotas da aplicação. Essa rota fornece informações detalhadas, como a versão do Rails e do Ruby, para `public/index.html` em uma aplicação Rails padrão.

* `build_middleware_stack`: Constrói a pilha de middlewares para a aplicação, retornando um objeto que possui um método `call` que recebe um objeto de ambiente Rack para a solicitação.

* `eager_load!`: Se `config.eager_load` for `true`, executa os hooks `config.before_eager_load` e, em seguida, chama `eager_load!`, que carregará todos os `config.eager_load_namespaces`.

* `finisher_hook`: Fornece um gancho para depois que o processo de inicialização da aplicação estiver completo, além de executar todos os blocos `config.after_initialize` para a aplicação, railties e engines.
* `set_routes_reloader_hook`: Configura o Action Dispatch para recarregar o arquivo de rotas usando `ActiveSupport::Callbacks.to_run`.

* `disable_dependency_loading`: Desativa o carregamento automático de dependências se `config.eager_load` estiver definido como `true`.


Pooling de Banco de Dados
----------------

As conexões de banco de dados do Active Record são gerenciadas por `ActiveRecord::ConnectionAdapters::ConnectionPool`, que garante que um pool de conexões sincronize a quantidade de acesso de threads a um número limitado de conexões de banco de dados. Esse limite padrão é 5 e pode ser configurado em `database.yml`.

```ruby
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

Como o pooling de conexões é tratado dentro do Active Record por padrão, todos os servidores de aplicativos (Thin, Puma, Unicorn, etc.) devem se comportar da mesma maneira. O pool de conexões de banco de dados está inicialmente vazio. À medida que a demanda por conexões aumenta, ele as cria até atingir o limite do pool de conexões.

Qualquer solicitação verificará uma conexão na primeira vez que precisar acessar o banco de dados. No final da solicitação, ela verificará a conexão novamente. Isso significa que o slot de conexão adicional estará disponível novamente para a próxima solicitação na fila.

Se você tentar usar mais conexões do que as disponíveis, o Active Record bloqueará você e aguardará uma conexão do pool. Se não conseguir obter uma conexão, será lançado um erro de tempo limite semelhante ao mostrado abaixo.

```ruby
ActiveRecord::ConnectionTimeoutError - não foi possível obter uma conexão de banco de dados em 5.000 segundos (esperou 5.000 segundos)
```

Se você receber o erro acima, talvez queira aumentar o tamanho do pool de conexões incrementando a opção `pool` em `database.yml`.

NOTA. Se você estiver executando em um ambiente com várias threads, pode haver a chance de várias threads acessarem várias conexões simultaneamente. Portanto, dependendo da carga atual da solicitação, você pode ter várias threads competindo por um número limitado de conexões.


Configuração Personalizada
--------------------

Você pode configurar seu próprio código por meio do objeto de configuração do Rails com configuração personalizada no namespace `config.x` ou diretamente em `config`. A diferença fundamental entre esses dois é que você deve usar `config.x` se estiver definindo uma configuração _aninhada_ (por exemplo, `config.x.nested.hi`), e apenas `config` para configuração em _um único nível_ (por exemplo, `config.hello`).

```ruby
config.x.payment_processing.schedule = :daily
config.x.payment_processing.retries  = 3
config.super_debugger = true
```

Esses pontos de configuração estão disponíveis por meio do objeto de configuração:

```ruby
Rails.configuration.x.payment_processing.schedule # => :daily
Rails.configuration.x.payment_processing.retries  # => 3
Rails.configuration.x.payment_processing.not_set  # => nil
Rails.configuration.super_debugger                # => true
```

Você também pode usar `Rails::Application.config_for` para carregar arquivos de configuração inteiros:

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
Rails.configuration.payment['merchant_id'] # => production_merchant_id ou development_merchant_id
```

`Rails::Application.config_for` suporta uma configuração `shared` para agrupar configurações comuns. A configuração compartilhada será mesclada na configuração do ambiente.

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
# ambiente de desenvolvimento
Rails.application.config_for(:example)[:foo][:bar] #=> { baz: 1, qux: 2 }
```

Indexação de Mecanismos de Busca
-----------------------

Às vezes, você pode querer impedir que algumas páginas de sua aplicação sejam visíveis em sites de busca como Google, Bing, Yahoo ou Duck Duck Go. Os robôs que indexam esses sites primeiro analisarão o arquivo `http://seu-site.com/robots.txt` para saber quais páginas eles têm permissão para indexar.
O Rails cria este arquivo para você dentro da pasta `/public`. Por padrão, ele permite que os mecanismos de busca indexem todas as páginas da sua aplicação. Se você deseja bloquear a indexação em todas as páginas da sua aplicação, use o seguinte:

```
User-agent: *
Disallow: /
```

Para bloquear apenas páginas específicas, é necessário usar uma sintaxe mais complexa. Saiba mais na [documentação oficial](https://www.robotstxt.org/robotstxt.html).

Monitor de Sistema de Arquivos com Eventos
------------------------------------------

Se a gem [listen](https://github.com/guard/listen) estiver carregada, o Rails usa um monitor de sistema de arquivos com eventos para detectar alterações quando a recarga está habilitada:

```ruby
group :development do
  gem 'listen', '~> 3.3'
end
```

Caso contrário, em cada solicitação, o Rails percorre a árvore da aplicação para verificar se algo foi alterado.

No Linux e macOS, não são necessárias gemas adicionais, mas algumas são necessárias [para *BSD](https://github.com/guard/listen#on-bsd) e [para Windows](https://github.com/guard/listen#on-windows).

Observe que [algumas configurações não são suportadas](https://github.com/guard/listen#issues--limitations).
[`config.load_defaults`]: https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults
[`ActiveSupport::ParameterFilter.precompile_filters`]: https://api.rubyonrails.org/classes/ActiveSupport/ParameterFilter.html#method-c-precompile_filters
[ActiveModel::Error#full_message]: https://api.rubyonrails.org/classes/ActiveModel/Error.html#method-i-full_message
[`ActiveSupport::MessageEncryptor`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html
[`ActiveSupport::MessageVerifier`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html
[`message_serializer_fallback.active_support`]: active_support_instrumentation.html#message-serializer-fallback-active-support
[`Rails.application.deprecators`]: https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators
