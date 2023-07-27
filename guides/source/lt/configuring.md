**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bba7dd6e311e7abd59e434f12dbebd0e
Konfigūruojant „Rails“ aplikacijas
===================================

Šiame vadove aprašomos konfigūracijos ir inicijavimo funkcijos, skirtos „Rails“ aplikacijoms.

Po šio vadovo perskaitymo žinosite:

* Kaip keisti savo „Rails“ aplikacijų veikimą.
* Kaip pridėti papildomą kodą, kuris bus vykdomas paleidžiant aplikaciją.

--------------------------------------------------------------------------------

Inicijavimo kodo vietos
-----------------------

„Rails“ siūlo keturias standartines vietas, kuriose galima įdėti inicijavimo kodą:

* `config/application.rb`
* Aplinkos specifiniai konfigūracijos failai
* Inicijuojantys objektai
* Po inicijavimo objektai

Kodas, vykdomas prieš „Rails“ paleidimą
----------------------------------------

Retais atvejais, kai jūsų aplikacijai reikia paleisti kodą prieš pat „Rails“ įkrovimą, įdėkite jį virš „require "rails/all"“ iškvietimo „config/application.rb“ faile.

Konfigūruojant „Rails“ komponentus
----------------------------------

Bendrai konfigūruojant „Rails“, reikia konfigūruoti „Rails“ komponentus ir patį „Rails“. Konfigūracijos failas „config/application.rb“ ir aplinkos specifiniai konfigūracijos failai (pvz., „config/environments/production.rb“) leidžia nurodyti įvairius nustatymus, kuriuos norite perduoti visiems komponentams.

Pavyzdžiui, galite pridėti šį nustatymą į „config/application.rb“ failą:

```ruby
config.time_zone = 'Central Time (US & Canada)'
```

Tai yra nustatymas paties „Rails“. Jei norite perduoti nustatymus atskiriems „Rails“ komponentams, galite tai padaryti per tą patį „config“ objektą „config/application.rb“ faile:

```ruby
config.active_record.schema_format = :ruby
```

„Rails“ naudos tą konkretų nustatymą, kad sukonfigūruotų „Active Record“.

ĮSPĖJIMAS: Naudokite viešuosius konfigūracijos metodus, o ne tiesiogiai kreipkitės į susijusią klasę. Pvz., naudokite `Rails.application.config.action_mailer.options` vietoje `ActionMailer::Base.options`.

PASTABA: Jei reikia taikyti konfigūraciją tiesiogiai klasėje, naudokite [vėlinio įkėlimo kabliuką](https://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html) inicijuojančiame faile, kad išvengtumėte klasės įkėlimo prieš inicijavimą. Tai suges, nes klasės įkėlimas inicijavimo metu negali būti saugiai kartojamas, kai programa perkraunama.

### Versijų numatytieji nustatymai

[`config.load_defaults`] įkelia numatytuosius konfigūracijos nustatymus tikslinės versijos ir visų ankstesnių versijų atžvilgiu. Pavyzdžiui, `config.load_defaults 6.1` įkelia numatytuosius nustatymus visoms versijoms iki ir įskaitant 6.1 versiją.


Žemiau pateikiami numatytieji nustatymai, susiję su kiekviena tikslinė versija. Konfliktinių nustatymų atveju naujesnės versijos pirmenybę teikia senesnėms versijoms.

#### Numatytieji nustatymai tikslinės versijos 7.1 atveju

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
#### Numatytosios vertės 7.0 versijai

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

#### Numatytosios vertės 6.1 versijai

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

#### Numatytosios vertės 6.0 versijai

- [`config.action_dispatch.use_cookies_with_metadata`](#config-action-dispatch-use-cookies-with-metadata): `true`
- [`config.action_mailer.delivery_job`](#config-action-mailer-delivery-job): `"ActionMailer::MailDeliveryJob"`
- [`config.action_view.default_enforce_utf8`](#config-action-view-default-enforce-utf8): `false`
- [`config.active_record.collection_cache_versioning`](#config-active-record-collection-cache-versioning): `true`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `:active_storage_analysis`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `:active_storage_purge`

#### Numatytosios vertės 5.2 versijai

- [`config.action_controller.default_protect_from_forgery`](#config-action-controller-default-protect-from-forgery): `true`
- [`config.action_dispatch.use_authenticated_cookie_encryption`](#config-action-dispatch-use-authenticated-cookie-encryption): `true`
- [`config.action_view.form_with_generates_ids`](#config-action-view-form-with-generates-ids): `true`
- [`config.active_record.cache_versioning`](#config-active-record-cache-versioning): `true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA1`
- [`config.active_support.use_authenticated_message_encryption`](#config-active-support-use-authenticated-message-encryption): `true`

#### Numatytosios vertės 5.1 versijai

- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `true`
- [`config.assets.unknown_asset_fallback`](#config-assets-unknown-asset-fallback): `false`

#### Numatytosios vertės 5.0 versijai

- [`ActiveSupport.to_time_preserves_timezone`](#activesupport-to-time-preserves-timezone): `true`
- [`config.action_controller.forgery_protection_origin_check`](#config-action-controller-forgery-protection-origin-check): `true`
- [`config.action_controller.per_form_csrf_tokens`](#config-action-controller-per-form-csrf-tokens): `true`
- [`config.active_record.belongs_to_required_by_default`](#config-active-record-belongs-to-required-by-default): `true`
- [`config.ssl_options`](#config-ssl-options): `{ hsts: { subdomains: true } }`

### Bendra Rails konfigūracija

Šie konfigūracijos metodai turėtų būti iškviesti `Rails::Railtie` objekte, pvz., `Rails::Engine` arba `Rails::Application` paveldėjime.

#### `config.add_autoload_paths_to_load_path`

Nurodo, ar autoload kelio reikia pridėti prie `$LOAD_PATH`. Rekomenduojama nustatyti `false` `:zeitwerk` režimu anksti, `config/application.rb`. Zeitwerk viduje naudoja absoliučius kelius, o programos, veikiančios `:zeitwerk` režimu, nereikia `require_dependency`, todėl modeliai, kontroleriai, darbai ir kt. nereikia būti `$LOAD_PATH`. Nustatant tai kaip `false`, Ruby nereikia tikrinti šių katalogų, kai išsprendžiami `require` kvietimai su santykiniais keliais, ir tai taupo Bootsnap darbą ir RAM, nes nereikia jiems sukurti indekso.

Numatytasis vertė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis vertė yra |
| --------------------- | -------------------- |
| (pradinis)            | `true`               |
| 7.1                   | `false`              |

`lib` katalogas nepaveikiamas šios vėliavos, jis visada pridedamas prie `$LOAD_PATH`.

#### `config.after_initialize`

Priima bloką, kuris bus vykdomas _po_ to, kai „Rails“ baigs inicializuoti programą. Tai apima pagrindo, variklių ir visų programos inicializatorių `config/initializers` inicializavimą. Atkreipkite dėmesį, kad šis blokas bus vykdomas ir rake užduotims. Tai naudinga konfigūruojant kitų inicializatorių nustatytas reikšmes:
```ruby
config.after_initialize do
  ActionView::Base.sanitized_allowed_tags.delete 'div'
end
```

#### `config.after_routes_loaded`

Priima bloką, kuris bus vykdomas po to, kai "Rails" baigs įkelti programos maršrutus. Šis blokas taip pat bus vykdomas kiekvieną kartą, kai maršrutai yra perkraunami.

```ruby
config.after_routes_loaded do
  # Kodas, kuris kažką daro su Rails.application.routes
end
```

#### `config.allow_concurrency`

Valdo, ar užklausos turėtų būti tvarkomos vienu metu. Tai turėtų būti nustatyta tikrai `false`, jei programos kodas nėra gijų saugus. Numatytoji reikšmė yra `true`.

#### `config.asset_host`

Nustato turinio šaltinio (asset) prievadą. Tai naudinga, kai turinys talpinamas naudojant CDN arba kai norite apeiti naršyklėse įdiegtas konkurencijos apribojimus, naudojant skirtingus domeno aliasus. Trumpesnė versija `config.action_controller.asset_host`.

#### `config.assume_ssl`

Padaro, kad programa manytų, jog visos užklausos ateina per SSL. Tai naudinga, kai per tarpininkinį serverį, kuris baigia SSL, perduodama užklausa atrodo taip, tarsi ji būtų HTTP, o ne HTTPS programai. Tai padaro, kad peradresavimai ir slapukų sauga būtų nukreipta į HTTP, o ne HTTPS. Šis vidinės programinės įrangos sluoksnis daro serveriui prielaidą, kad tarpininkinė jau baigė SSL ir kad užklausa iš tikrųjų yra HTTPS.

#### `config.autoflush_log`

Įjungia iš karto rašyti į žurnalo failą, o ne talpinti duomenis buferiuose. Numatytoji reikšmė yra `true`.

#### `config.autoload_once_paths`

Priima masyvą kelių, iš kurių "Rails" automatiškai įkelia konstantas, kurios nebus išvalomos per kiekvieną užklausą. Tai aktualu, jei perkrovimas yra įjungtas, kas numatyta "development" aplinkoje. Kitu atveju, visi automatiniai įkėlimai vyksta tik vieną kartą. Visi šio masyvo elementai taip pat turi būti "autoload_paths" masyve. Numatytoji reikšmė yra tuščias masyvas.

#### `config.autoload_paths`

Priima masyvą kelių, iš kurių "Rails" automatiškai įkelia konstantas. Numatytoji reikšmė yra tuščias masyvas. Nuo [Rails 6](upgrading_ruby_on_rails.html#autoloading) versijos, nerekomenduojama keisti šios reikšmės. Žr. [Konstantų automatinis įkėlimas ir perkrovimas](autoloading_and_reloading_constants.html#autoload-paths).

#### `config.autoload_lib(ignore:)`

Šis metodas prideda `lib` prie `config.autoload_paths` ir `config.eager_load_paths`.

Įprastai, `lib` direktorijoje yra subdirektorijos, kurios neturėtų būti automatiškai įkeliamos arba įkeliamos iš karto. Prašome, perduoti jų pavadinimus, atsižvelgiant į `lib` direktoriją, naudojant `ignore` raktažodį. Pavyzdžiui,

```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

Daugiau informacijos rasite [automatinio įkėlimo vadove](autoloading_and_reloading_constants.html).

#### `config.autoload_lib_once(ignore:)`

`config.autoload_lib_once` metodas yra panašus į `config.autoload_lib`, tik jis prideda `lib` prie `config.autoload_once_paths` vietoje.

Iškvietus `config.autoload_lib_once`, klasės ir moduliai `lib` gali būti automatiškai įkeliami, net iš programos inicializatorių, bet nebus perkraunami.

#### `config.beginning_of_week`

Nustato numatytąją savaitės pradžią programai. Priima galiojančią savaitės dieną simboliu (pvz., `:monday`).

#### `config.cache_classes`

Senas nustatymas, ekvivalentiškas `!config.enable_reloading`. Palaikomas dėl suderinamumo atgal.
#### `config.cache_store`

Konfigūruoja, kurį kešo saugyklą naudoti „Rails“ kešavimui. Galimi variantai: vienas iš simbolių `:memory_store`, `:file_store`, `:mem_cache_store`, `:null_store`, `:redis_cache_store` arba objektas, kuris įgyvendina kešo API. Numatytasis variantas yra `:file_store`. Daugiau informacijos rasite [Kešo saugyklos](caching_with_rails.html#cache-stores) puslapyje.

#### `config.colorize_logging`

Nurodo, ar naudoti ANSI spalvų kodus žurnalo informacijai. Numatytasis variantas yra `true`.

#### `config.consider_all_requests_local`

Tai vėliava. Jei `true`, tai bet koks klaidos pranešimas sukels išsamią derinimo informaciją, kuri bus išspausdinta HTTP atsakyme, o `Rails::Info` valdiklis rodo aplikacijos vykdymo kontekstą `/rails/info/properties` puslapyje. Numatytasis variantas yra `true` vystymo ir testavimo aplinkose, o produkcijoje - `false`. Norint gauti smulkesnį valdymą, nustatykite šią reikšmę kaip `false` ir valdikliuose įgyvendinkite `show_detailed_exceptions?` metodą, kad nurodytumėte, kurie užklausos turėtų pateikti derinimo informaciją apie klaidas.

#### `config.console`

Leidžia nustatyti klasę, kuri bus naudojama kaip konsolė, kai paleidžiate `bin/rails console`. Geriausia tai padaryti `console` bloke:

```ruby
console do
  # šis blokas bus iškviestas tik paleidus konsolę,
  # todėl saugiai galime čia įtraukti pry
  require "pry"
  config.console = Pry
end
```

#### `config.content_security_policy_nonce_directives`

Žr. [Nonce pridėjimas](security.html#adding-a-nonce) saugumo gaireje

#### `config.content_security_policy_nonce_generator`

Žr. [Nonce pridėjimas](security.html#adding-a-nonce) saugumo gaireje

#### `config.content_security_policy_report_only`

Žr. [Pažeidimų pranešimas](security.html#reporting-violations) saugumo gaireje

#### `config.credentials.content_path`

Užšifruotų kredencialų failo kelias.

Numatytasis variantas yra `config/credentials/#{Rails.env}.yml.enc`, jei jis egzistuoja, arba `config/credentials.yml.enc` kitu atveju.

PASTABA: Kad `bin/rails credentials` komandos atpažintų šią reikšmę, ji turi būti nustatyta `config/application.rb` arba `config/environments/#{Rails.env}.rb` faile.

#### `config.credentials.key_path`

Užšifruotų kredencialų rakto failo kelias.

Numatytasis variantas yra `config/credentials/#{Rails.env}.key`, jei jis egzistuoja, arba `config/master.key` kitu atveju.

PASTABA: Kad `bin/rails credentials` komandos atpažintų šią reikšmę, ji turi būti nustatyta `config/application.rb` arba `config/environments/#{Rails.env}.rb` faile.

#### `config.debug_exception_response_format`

Nustato atsakymo formatą, naudojamą klaidų atveju vystymo aplinkoje. Numatytasis variantas yra `:api` tik API programoms ir `:default` įprastoms programoms.

#### `config.disable_sandbox`

Valdo, ar galima paleisti konsolę smėlio dėžės režimu. Tai padeda išvengti ilgo smėlio dėžės konsolės seanso, kuris gali išsemti duomenų bazės serverio atmintį. Numatytasis variantas yra `false`.

#### `config.eager_load`

Kai `true`, visi registruoti `config.eager_load_namespaces` bus įkraunami iš anksto. Tai apima jūsų aplikaciją, variklius, „Rails“ karkasus ir bet kokį kitą registruotą vardų sritį.

#### `config.eager_load_namespaces`

Registruoja vardų sritis, kurios bus įkraunamos iš anksto, kai `config.eager_load` nustatoma kaip `true`. Visos sąraše esančios vardų sritys turi atsakyti į `eager_load!` metodą.

#### `config.eager_load_paths`
Priima takų masyvą, iš kurio "Rails" įkels į atmintį paleidus, jei `config.eager_load` yra tiesa. Pagal nutylėjimą įkeliami visi katalogai aplikacijos `app` direktorijoje.

#### `config.enable_reloading`

Jei `config.enable_reloading` yra tiesa, aplikacijos klasės ir moduliai yra įkeliami iš naujo tarp interneto užklausų, jei jie pasikeičia. Pagal nutylėjimą `development` aplinkoje tai yra tiesa, o `production` aplinkoje - netiesa.

Taip pat apibrėžiamas predikatas `config.reloading_enabled?`.

#### `config.encoding`

Nustato visoje aplikacijoje naudojamą koduotę. Pagal nutylėjimą tai yra UTF-8.

#### `config.exceptions_app`

Nustato išimčių programa, kurią kviečia `ShowException` tarpinė programinė įranga, kai įvyksta išimtis.
Pagal nutylėjimą tai yra `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

Išimčių programoms reikia tvarkyti `ActionDispatch::Http::MimeNegotiation::InvalidType` klaidas, kurios iškyla, kai klientas siunčia netinkamą `Accept` arba `Content-Type` antraštę.
Numatytoji `ActionDispatch::PublicExceptions` programa tai daro automatiškai, nustatydama `Content-Type` į `text/html` ir grąžindama `406 Not Acceptable` būseną.
Nepavykus tvarkyti šios klaidos, gausime `500 Internal Server Error` klaidą.

Naudojant `Rails.application.routes` maršrutų rinkinį kaip išimčių programą, taip pat reikalingas šis specialus tvarkymas.
Tai gali atrodyti kaip šis pavyzdys:

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

Tai klasė, naudojama aptikti failų atnaujinimus failų sistemoje, kai `config.reload_classes_only_on_change` yra tiesa. "Rails" pristato `ActiveSupport::FileUpdateChecker`, kuris yra numatytasis, ir `ActiveSupport::EventedFileUpdateChecker` (šis priklauso nuo [listen](https://github.com/guard/listen) gembės). Pasirinktos klasės turi atitikti `ActiveSupport::FileUpdateChecker` API.

#### `config.filter_parameters`

Naudojama filtruoti parametrus, kurių nenorite rodyti žurnale,
tokius kaip slaptažodžiai arba kreditinės kortelės numeriai. Taip pat filtruojami jautrūs duomenų bazės stulpelių vertimai, kai kviečiamas `#inspect` metodas `Active Record` objekte. Pagal nutylėjimą "Rails" filtruoja slaptažodžius pridedant šiuos filtrus į `config/initializers/filter_parameter_logging.rb`.

```ruby
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

Parametrų filtravimas veikia dalinio atitikimo reguliariąja išraiška.

#### `config.filter_redirect`

Naudojama filtruoti peradresavimo URL iš aplikacijos žurnalų.

```ruby
Rails.application.config.filter_redirect += ['s3.amazonaws.com', /private-match/]
```

Peradresavimo filtras veikia tikrinant, ar URL yra įtrauktas į eilutes arba atitinka reguliariąją išraišką.

#### `config.force_ssl`

Verčia visus užklausimus aptarnauti per HTTPS ir nustato "https://" kaip numatytąjį protokolą generuojant URL. HTTPS priverstinis taikymas vykdomas per `ActionDispatch::SSL` tarpinę programinę įrangą, kurią galima konfigūruoti per `config.ssl_options`.

#### `config.helpers_paths`

Apibrėžia papildomų kelių masyvą, kuriuose įkeliami vaizdo pagalbininkai.

#### `config.host_authorization`

Priima raktų rinkinį, skirtą konfigūruoti [HostAuthorization
tarpinei programinei įrangai](#actiondispatch-hostauthorization)
#### `config.hosts`

Masyvas, kuriame yra eilučių, reguliariųjų išraiškų arba `IPAddr`, naudojamų tikrinti `Host` antraštės teisingumą. Naudojama [HostAuthorization middleware](#actiondispatch-hostauthorization) išvengti DNS rebind atakų.

#### `config.javascript_path`

Nustato kelią, kuriame jūsų programos JavaScript yra atžvilgiu `app` katalogui. Numatytasis yra `javascript`, naudojamas [webpacker](https://github.com/rails/webpacker). Programos sukonfigūruotas `javascript_path` bus pašalintas iš `autoload_paths`.

#### `config.log_file_size`

Apibrėžia didžiausią Rails žurnalo failo dydį baitais. Numatytasis yra `104_857_600` (100 MiB) vystymo ir testavimo aplinkose ir neribotas visose kitose aplinkose.

#### `config.log_formatter`

Apibrėžia Rails žurnalo formuotoją. Ši parinktis numatytuoju atveju yra `ActiveSupport::Logger::SimpleFormatter` pavyzdys visoms aplinkoms. Jei nustatote reikšmę `config.logger`, turite rankiniu būdu perduoti savo formuotojo reikšmę žurnalui prieš jį supakuojant į `ActiveSupport::TaggedLogging` pavyzdį, Rails to nepadarys už jus.

#### `config.log_level`

Apibrėžia Rails žurnalo išsamumą. Ši parinktis numatytuoju atveju yra `:debug` visoms aplinkoms, išskyrus gamybą, kur ji numatyta kaip `:info`. Galimi žurnalo išsamumo lygiai yra: `:debug`, `:info`, `:warn`, `:error`, `:fatal` ir `:unknown`.

#### `config.log_tags`

Priima sąrašą metodų, į kuriuos `request` objektas atsako, `Proc`, kuris priima `request` objektą, arba kažką, kas atsako į `to_s`. Tai leidžia lengvai pažymėti žurnalo eilutes su derinimo informacija, pvz., subdomenu ir užklausos ID - abu labai naudingi derinant daugelio vartotojų gamybos programas.

#### `config.logger`

Tai žurnalo įrašyklė, kuri bus naudojama `Rails.logger` ir bet kokia susijusi Rails žurnalo įrašymo, pvz., `ActiveRecord::Base.logger`. Numatytuoju atveju tai yra `ActiveSupport::TaggedLogging` pavyzdys, kuris supakuoja `ActiveSupport::Logger` pavyzdį, kuris išveda žurnalą į `log/` katalogą. Galite pateikti pasirinktinę įrašyklę, norėdami gauti visišką suderinamumą, turite laikytis šių nurodymų:

* Norėdami palaikyti formuotoją, turite rankiniu būdu priskirti formuotoją iš `config.log_formatter` reikšmės įrašyklėje.
* Norėdami palaikyti pažymėtus žurnalus, žurnalo pavyzdys turi būti supakuotas su `ActiveSupport::TaggedLogging`.
* Norėdami palaikyti nutildymą, įrašyklėje turi būti įtrauktas `ActiveSupport::LoggerSilence` modulis. `ActiveSupport::Logger` klasė jau įtraukia šiuos modulius.

```ruby
class MyLogger < ::Logger
  include ActiveSupport::LoggerSilence
end

mylogger           = MyLogger.new(STDOUT)
mylogger.formatter = config.log_formatter
config.logger      = ActiveSupport::TaggedLogging.new(mylogger)
```

#### `config.middleware`

Leidžia konfigūruoti programos tarpinį programinį įrangą. Apie tai išsamiai kalbama [Konfigūruojant tarpinį programinį įrangą](#configuring-middleware) skyriuje žemiau.

#### `config.precompile_filter_parameters`

Kai `true`, išankstinio kompiliavimo metu bus išankstinio kompiliavimo [`config.filter_parameters`](#config-filter-parameters) naudojant [`ActiveSupport::ParameterFilter.precompile_filters`][].

Numatytąją reikšmę lemia `config.load_defaults` tikslinė versija:

| Pradedant nuo versijos | Numatytasis yra |
| --------------------- | --------------- |
| (originalus)          | `false`         |
| 7.1                   | `true`          |
#### `config.public_file_server.enabled`

Konfigūruoja Rails, kad jis aptarnautų statinius failus iš viešojo katalogo. Ši parinktis pagal nutylėjimą yra nustatyta kaip `true`, tačiau produkcinėje aplinkoje ji nustatoma kaip `false`, nes serverio programa (pvz., NGINX arba Apache), naudojama paleisti programą, turėtų aptarnauti statinius failus. Jei paleidžiate arba testuojate savo programą produkcinėje aplinkoje naudodami WEBrick (nerekomenduojama naudoti WEBrick produkcinėje aplinkoje), nustatykite parinktį kaip `true`. Kitu atveju, negalėsite naudoti puslapių talpinimo ir užklausų failams, esantiems viešajame kataloge.

#### `config.railties_order`

Leidžia rankiniu būdu nurodyti Railties/Engines pakrovimo tvarką. Numatytasis reikšmė yra `[:all]`.

```ruby
config.railties_order = [Blog::Engine, :main_app, :all]
```

#### `config.rake_eager_load`

Kai `true`, programą įkelia iš anksto paleidžiant Rake užduotis. Numatytasis nustatymas yra `false`.

#### `config.read_encrypted_secrets`

*PASIDUODA*: Turėtumėte naudoti [credentials](https://guides.rubyonrails.org/security.html#custom-credentials) vietoj užšifruotų paslapčių.

Kai `true`, bandys nuskaityti užšifruotas paslaptis iš `config/secrets.yml.enc`

#### `config.relative_url_root`

Gali būti naudojama pranešti Rails, kad jūs [diegiate į subkatalogą](configuring.html#deploy-to-a-subdirectory-relative-url-root). Numatytoji reikšmė yra `ENV['RAILS_RELATIVE_URL_ROOT']`.

#### `config.reload_classes_only_on_change`

Įjungia arba išjungia klasės perkrovimą tik tada, kai keičiamos stebimos bylos. Pagal nutylėjimą stebima viskas, kas yra įkėlimo takuose, ir nustatyta kaip `true`. Jei `config.enable_reloading` yra `false`, ši parinktis yra ignoruojama.

#### `config.require_master_key`

Sukelia programos neįkėlimą, jei pagrindinis raktas nėra prieinamas per `ENV["RAILS_MASTER_KEY"]` arba `config/master.key` failą.

#### `config.secret_key_base`

Atsarginė reikšmė, skirta nurodyti įvesties paslaptį programos raktų generatoriui. Rekomenduojama ją palikti nenustatytą ir vietoj to nurodyti `secret_key_base` `config/credentials.yml.enc`. Daugiau informacijos ir alternatyvių konfigūracijos metodų rasite [`secret_key_base` API dokumentacijoje](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-secret_key_base).

#### `config.server_timing`

Kai `true`, prideda [ServerTiming middleware](#actiondispatch-servertiming) į middleware grandinę.

#### `config.session_options`

Papildomos parinktys, perduodamos `config.session_store`. Turėtumėte naudoti `config.session_store`, kad tai nustatytumėte, vietoj to, kad modifikuotumėte tai patys.

```ruby
config.session_store :cookie_store, key: "_your_app_session"
config.session_options # => {key: "_your_app_session"}
```

#### `config.session_store`

Nurodo, kokią klasę naudoti saugoti sesiją. Galimos reikšmės yra `:cache_store`, `:cookie_store`, `:mem_cache_store`, pasirinktinė saugykla arba `:disabled`. `:disabled` nurodo Rails, kad nereikia tvarkyti sesijų.

Šis nustatymas konfigūruojamas per įprastą metodo iškvietimą, o ne per nustatymo metodą. Tai leidžia perduoti papildomas parinktis:

```ruby
config.session_store :cookie_store, key: "_your_app_session"
```

Jei pasirinkta pasirinktinė saugykla yra nurodyta kaip simbolis, ji bus išspręsta į `ActionDispatch::Session` vardų erdvę:

```ruby
# naudokite ActionDispatch::Session::MyCustomStore kaip sesijos saugyklą
config.session_store :my_custom_store
```

Numatytoji saugykla yra slapukų saugykla su programos pavadinimu kaip sesijos raktu.
#### `config.ssl_options`

Konfigūracijos parinktys [`ActionDispatch::SSL`](https://api.rubyonrails.org/classes/ActionDispatch/SSL.html) tarpinės programinės įrangos.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (originalus)          | `{}`                   |
| 5.0                   | `{ hsts: { subdomains: true } }` |

#### `config.time_zone`

Nustato numatytąją laiko juostą programai ir įgalina laiko juostos sąmoningumą veikiančiam įrašui.

#### `config.x`

Naudojama lengvai pridėti įdėtą pasirinktinę konfigūraciją prie programos konfigūracijos objekto

  ```ruby
  config.x.payment_processing.schedule = :daily
  Rails.configuration.x.payment_processing.schedule # => :daily
  ```

Žr. [Pasirinktinė konfigūracija](#pasirinktinė-konfigūracija)

### Turinio konfigūravimas

#### `config.assets.css_compressor`

Apibrėžia naudojamą CSS suspaudiklį. Numatytąją reikšmę nustato `sass-rails`. Vienintelis alternatyvus variantas šiuo metu yra `:yui`, kuris naudoja `yui-compressor` grotelę.

#### `config.assets.js_compressor`

Apibrėžia naudojamą JavaScript suspaudiklį. Galimos reikšmės yra `:terser`, `:closure`, `:uglifier` ir `:yui`, kurios reikalauja atitinkamai `terser`, `closure-compiler`, `uglifier` ar `yui-compressor` grotelių naudojimo.

#### `config.assets.gzip`

Vėliava, kuri įgalina sukompiliuotų turinio versijų su suspaudimu kūrimą, kartu su nesuspaudžiamais turinio versijomis. Numatytoji reikšmė yra `true`.

#### `config.assets.paths`

Apima kelius, kurie naudojami ieškant turinio. Pridėjus kelius prie šios konfigūracijos parinkties, šie keliai bus naudojami ieškant turinio.

#### `config.assets.precompile`

Leidžia nurodyti papildomą turinį (ne `application.css` ir `application.js`), kuris turi būti sukompiliuotas paleidus `bin/rails assets:precompile`.

#### `config.assets.unknown_asset_fallback`

Leidžia keisti turinio eilutės elgesį, kai turinys nėra eilutėje, jei naudojate sprockets-rails 3.2.0 ar naujesnę versiją.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (originalus)          | `true`                 |
| 5.1                   | `false`                |

#### `config.assets.prefix`

Apibrėžia priešdėlį, iš kurio bus aptarnaujamas turinys. Numatytasis reikšmė yra `/assets`.

#### `config.assets.manifest`

Apibrėžia visą kelią, kuris bus naudojamas turinio kompiliatoriaus manifestui. Numatytasis reikšmė yra failas, pavadinimu `manifest-<random>.json`, esantis `config.assets.prefix` kataloge viešajame aplanke.

#### `config.assets.digest`

Įgalina SHA256 pirštų atspaudų naudojimą turinio pavadinimuose. Numatytoji reikšmė yra `true`.

#### `config.assets.debug`

Išjungia turinio sujungimą ir suspaudimą. Numatytoji reikšmė yra `true` `development.rb` faile.

#### `config.assets.version`

Yra parinktinė eilutė, kuri naudojama SHA256 maišos generavimui. Tai gali būti pakeista, kad būtų priversti visi failai iš naujo sukompiliuoti.

#### `config.assets.compile`

Yra boolean tipo reikšmė, kurią galima naudoti, norint įjungti gyvą Sprockets kompiliaciją produkcijoje.
#### `config.assets.logger`

Priima žurnalo objektą, kuris atitinka Log4r sąsają arba numatytąjį Ruby `Logger` klasę. Numatytasis nustatymas yra tas pats, kuris nustatytas `config.logger`. Nustatant `config.assets.logger` į `false`, bus išjungtas paslaugomis teikiamų išteklių žurnalavimas.

#### `config.assets.quiet`

Išjungia išteklių užklausų žurnalavimą. Numatytasis nustatymas `development.rb` faile yra `true`.

### Generatorių konfigūravimas

Rails leidžia keisti, kokius generatorius naudoti naudojant `config.generators` metodą. Šis metodas priima bloką:

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

Šiame bloke galima naudoti šiuos metodus:

* `force_plural` leidžia daugiskaitinius modelių pavadinimus. Numatytasis nustatymas yra `false`.
* `helper` apibrėžia, ar generuoti pagalbines funkcijas. Numatytasis nustatymas yra `true`.
* `integration_tool` apibrėžia, kurį integracijos įrankį naudoti generuojant integracijos testus. Numatytasis nustatymas yra `:test_unit`.
* `system_tests` apibrėžia, kurį integracijos įrankį naudoti generuojant sistemos testus. Numatytasis nustatymas yra `:test_unit`.
* `orm` apibrėžia, kurį ORM naudoti. Numatytasis nustatymas yra `false` ir pagal numatytuosius nustatymus naudojamas Active Record.
* `resource_controller` apibrėžia, kurį generatorių naudoti generuojant valdiklį naudojant `bin/rails generate resource`. Numatytasis nustatymas yra `:controller`.
* `resource_route` apibrėžia, ar turėtų būti generuojama resursų maršruto apibrėžtis ar ne. Numatytasis nustatymas yra `true`.
* `scaffold_controller` skiriasi nuo `resource_controller` ir apibrėžia, kurį generatorių naudoti generuojant _scaffolded_ valdiklį naudojant `bin/rails generate scaffold`. Numatytasis nustatymas yra `:scaffold_controller`.
* `test_framework` apibrėžia, kurį testavimo pagrindą naudoti. Numatytasis nustatymas yra `false` ir pagal numatytuosius nustatymus naudojamas minitest.
* `template_engine` apibrėžia, kurį šablonų variklį naudoti, pvz., ERB arba Haml. Numatytasis nustatymas yra `:erb`.

### Middleware konfigūravimas

Kiekvienas Rails aplikacijos ateina su standartiniu middleware rinkiniu, kurį ji naudoja šiuo tvarka vystymo aplinkoje:

#### `ActionDispatch::HostAuthorization`

Apsaugo nuo DNS peradresavimo ir kitų `Host` antrašte pagrįstų atakų.
Numatytasis konfigūravimas įtraukiamas į vystymo aplinką pagal šią konfigūraciją:

```ruby
Rails.application.config.hosts = [
  IPAddr.new("0.0.0.0/0"),        # Visi IPv4 adresai.
  IPAddr.new("::/0"),             # Visi IPv6 adresai.
  "localhost",                    # Rezervuota vietovardžio sritis.
  ENV["RAILS_DEVELOPMENT_HOSTS"]  # Papildomi per kablelį atskirti vietovardžiai vystymui.
]
```

Kitose aplinkose `Rails.application.config.hosts` yra tuščias ir nevykdomos jokios
`Host` antraštės tikrinimo patikros. Jei norite apsaugoti nuo antraščių
atakų produkcijoje, turite rankiniu būdu leisti leistinus vietovardžius
su:

```ruby
Rails.application.config.hosts << "product.com"
```

Užklausos vietovardis yra tikrinamas su `hosts` įrašais naudojant atitikties
operatorių (`#===`), kuris leidžia `hosts` palaikyti įrašus, tokius kaip `Regexp`,
`Proc` ir `IPAddr`, pavyzdžiui. Čia yra pavyzdys su reguliariąja išraiška.
```ruby
# Leidžia užklausas iš subdomenų, pvz., `www.product.com` ir
# `beta1.product.com`.
Rails.application.config.hosts << /.*\.product\.com/
```

Pateiktas reguliariasis išraiškos objektas bus apgaubtas abiem kotiruotėmis (`\A` ir `\z`), todėl jis turi atitikti visą priimančiojo kompiuterio vardą. Pavyzdžiui, `/product.com/`, kai jis yra apgaubtas kotiruotėmis, nepavyks atitikti `www.product.com`.

Yra palaikoma speciali sąlyga, leidžianti leisti visus subdomenus:

```ruby
# Leidžia užklausas iš subdomenų, pvz., `www.product.com` ir
# `beta1.product.com`.
Rails.application.config.hosts << ".product.com"
```

Galite neįtraukti tam tikrų užklausų iš priimančiojo kompiuterio patikrinimo, nustatydami `config.host_authorization.exclude`:

```ruby
# Neįtraukti užklausų į /healthcheck/ kelią iš priimančiojo kompiuterio patikrinimo
Rails.application.config.host_authorization = {
  exclude: ->(request) { request.path.include?('healthcheck') }
}
```

Kai užklausa patenka į nepatvirtintą priimančiojo kompiuterio patikrinimą, bus paleista numatytoji Rack programa ir bus atsakyta `403 Forbidden`. Tai galima pritaikyti, nustatant `config.host_authorization.response_app`. Pavyzdžiui:

```ruby
Rails.application.config.host_authorization = {
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

#### `ActionDispatch::ServerTiming`

Prideda metrikas į `Server-Timing` antraštę, kurias galima peržiūrėti naršyklės kūrėjo įrankiuose.

#### `ActionDispatch::SSL`

Priverčia kiekvieną užklausą būti aptarnaujamą naudojant HTTPS. Įjungta, jei `config.force_ssl` yra nustatyta kaip `true`. Parametrai, perduodami šiam, gali būti konfigūruojami, nustatant `config.ssl_options`.

#### `ActionDispatch::Static`

Naudojamas aptarnauti statinius išteklius. Išjungta, jei `config.public_file_server.enabled` yra `false`. Nustatykite `config.public_file_server.index_name`, jei norite aptarnauti statinį katalogo indekso failą, kuris nėra pavadinimu `index`. Pavyzdžiui, norint aptarnauti `main.html` vietoj `index.html` užklausoms į katalogą, nustatykite `config.public_file_server.index_name` kaip `"main"`.

#### `ActionDispatch::Executor`

Leidžia atnaujinti gijų saugų kodą. Išjungta, jei `config.allow_concurrency` yra `false`, dėl ko įkeliamas `Rack::Lock`. `Rack::Lock` apgaubia programą užraktu, todėl ją gali iškviesti tik viena gija vienu metu.

#### `ActiveSupport::Cache::Strategy::LocalCache`

Veikia kaip pagrindinė atmintimi paremta talpykla. Ši talpykla nėra gijų saugi ir skirta tik laikinai atminties talpyklai vienai gijai.

#### `Rack::Runtime`

Nustato `X-Runtime` antraštę, kurioje yra laikas (sekundėmis), kurį užtrunka vykdyti užklausą.

#### `Rails::Rack::Logger`

Praneša žurnalams, kad užklausa prasidėjo. Baigus užklausą, išvalo visus žurnalus.

#### `ActionDispatch::ShowExceptions`

Išgelbsti bet kokią išimtį, grąžintą programos, ir jei užklausa yra vietinė arba jei `config.consider_all_requests_local` yra nustatytas kaip `true`, rodo gražias išimčių puslapius. Jei `config.action_dispatch.show_exceptions` yra nustatytas kaip `:none`, išimtys bus iškeliamos nepriklausomai nuo to.

#### `ActionDispatch::RequestId`

Prieinamas unikalus X-Request-Id antraštė atsakymui ir įgalina `ActionDispatch::Request#uuid` metodą. Galima konfigūruoti, nustatant `config.action_dispatch.request_id_header`.

#### `ActionDispatch::RemoteIp`

Tikrina IP sukčiavimo atakas ir gauna teisingą `client_ip` iš užklausos antraščių. Galima konfigūruoti, naudojant `config.action_dispatch.ip_spoofing_check` ir `config.action_dispatch.trusted_proxies` parametrus.
#### `Rack::Sendfile`

Interceptuoja atsakymus, kurių kūnas yra siunčiamas iš failo, ir pakeičia jį serverio specifiniu X-Sendfile antrašte. Konfigūruojama naudojant `config.action_dispatch.x_sendfile_header`.

#### `ActionDispatch::Callbacks`

Paleidžia pasiruošimo atgalinį iškvietimą prieš aptarnaujant užklausą.

#### `ActionDispatch::Cookies`

Nustato slapukus užklausai.

#### `ActionDispatch::Session::CookieStore`

Atsakingas už sesijos saugojimą slapukuose. Alternatyvus middleware gali būti naudojamas keičiant [`config.session_store`](#config-session-store).

#### `ActionDispatch::Flash`

Nustato `flash` raktus. Prieinama tik jei [`config.session_store`](#config-session-store) yra nustatytas į tam tikrą reikšmę.

#### `Rack::MethodOverride`

Leidžia pakeisti metodą, jei nustatytas `params[:_method]`. Tai yra middleware, kuris palaiko PATCH, PUT ir DELETE HTTP metodo tipus.

#### `Rack::Head`

Konvertuoja HEAD užklausas į GET užklausas ir aptarnauja jas kaip tokias.

#### Pridėti pasirinktinį middleware

Be šių įprastų middleware, galite pridėti savo middleware naudodami `config.middleware.use` metodą:

```ruby
config.middleware.use Magical::Unicorns
```

Tai įdės `Magical::Unicorns` middleware į pabaigą. Jei norite pridėti middleware prieš kitą, galite naudoti `insert_before`.

```ruby
config.middleware.insert_before Rack::Head, Magical::Unicorns
```

Arba galite įterpti middleware į tikslų padėtį naudodami indeksus. Pavyzdžiui, jei norite įterpti `Magical::Unicorns` middleware viršuje, galite tai padaryti taip:

```ruby
config.middleware.insert_before 0, Magical::Unicorns
```

Yra ir `insert_after`, kuris įterps middleware po kito:

```ruby
config.middleware.insert_after Rack::Head, Magical::Unicorns
```

Middleware taip pat gali būti visiškai pakeistas kitais:

```ruby
config.middleware.swap ActionController::Failsafe, Lifo::Failsafe
```

Middleware gali būti perkeltas iš vienos vietos į kitą:

```ruby
config.middleware.move_before ActionDispatch::Flash, Magical::Unicorns
```

Tai perkels `Magical::Unicorns` middleware prieš `ActionDispatch::Flash`. Taip pat galite jį perkelti po:

```ruby
config.middleware.move_after ActionDispatch::Flash, Magical::Unicorns
```

Jie taip pat gali būti visiškai pašalinti iš eilės:

```ruby
config.middleware.delete Rack::MethodOverride
```

### Konfigūruojant i18n

Visos šios konfigūracijos parinktys yra perduodamos `I18n` bibliotekai.

#### `config.i18n.available_locales`

Apibrėžia leistinas galimas lokalizacijas programai. Pagal numatytuosius nustatymus tai yra visos lokalės raktai, rasti lokalės failuose, paprastai tik `:en` naujoje programoje.

#### `config.i18n.default_locale`

Nustato programos numatytąją lokalę, naudojamą i18n. Pagal numatytuosius nustatymus tai yra `:en`.

#### `config.i18n.enforce_available_locales`

Užtikrina, kad visos perduodamos lokalės per i18n turi būti deklaruotos `available_locales` sąraše, iškeliant `I18n::InvalidLocale` išimtį, kai nustatoma neprieinama lokalė. Pagal numatytuosius nustatymus tai yra `true`. Rekomenduojama neišjungti šios parinkties, nebent tai būtų labai reikalinga, nes tai veikia kaip saugumo priemonė prieš bet kokios netinkamos lokalės nustatymą iš vartotojo įvesties.

#### `config.i18n.load_path`

Nustato kelią, kuriuo „Rails“ ieško lokalės failų. Pagal numatytuosius nustatymus tai yra `config/locales/**/*.{yml,rb}`.
#### `config.i18n.raise_on_missing_translations`

Nustato, ar turėtų būti iškeltas klaidos pranešimas dėl trūkstamų vertimų. Pagal nutylėjimą tai nustatoma kaip `false`.

#### `config.i18n.fallbacks`

Nustato atsarginį elgesį trūkstamiems vertimams. Čia yra 3 pavyzdžiai, kaip naudoti šią parinktį:

  * Galite nustatyti parinktį kaip `true`, kad naudotumėte numatytąjį lokalės kaip atsarginę, pavyzdžiui:

    ```ruby
    config.i18n.fallbacks = true
    ```

  * Arba galite nustatyti lokalės masyvą kaip atsarginę, pavyzdžiui:

    ```ruby
    config.i18n.fallbacks = [:tr, :en]
    ```

  * Arba galite nustatyti skirtingas atsargines vertes kiekvienai lokalėi atskirai. Pavyzdžiui, jei norite naudoti `:tr` kaip atsarginę `:az` ir `:de`, `:en` kaip atsarginę `:da`, galite tai padaryti, pavyzdžiui:

    ```ruby
    config.i18n.fallbacks = { az: :tr, da: [:de, :en] }
    #arba
    config.i18n.fallbacks.map = { az: :tr, da: [:de, :en] }
    ```

### Konfigūruojant Active Model

#### `config.active_model.i18n_customize_full_message`

Valdo, ar [`Error#full_message`][ActiveModel::Error#full_message] formatą galima pakeisti i18n lokalės faile. Pagal nutylėjimą tai nustatoma kaip `false`.

Kai nustatoma kaip `true`, `full_message` ieškos formato atributo ir modelio lygiu lokalės failuose. Numatytasis formatas yra `"%{attribute} %{message}"`, kur `attribute` yra atributo pavadinimas, o `message` yra validacijos specifinis pranešimas. Šis pavyzdys pakeičia formatą visiems `Person` atributams, taip pat formatą tam tikram `Person` atributui (`age`).

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :age

  validates :name, :age, presence: true
end
```

```yml
en:
  activemodel: # arba activerecord:
    errors:
      models:
        person:
          # Pakeičia formatą visiems Person atributams:
          format: "Neteisingas %{attribute} (%{message})"
          attributes:
            age:
              # Pakeičia formatą age atributui:
              format: "%{message}"
              blank: "Prašome užpildyti savo %{attribute}"
```

```irb
irb> person = Person.new.tap(&:valid?)

irb> person.errors.full_messages
=> [
  "Neteisingas Vardas (negali būti tuščias)",
  "Prašome užpildyti savo Amžius"
]

irb> person.errors.messages
=> {
  :name => ["negali būti tuščias"],
  :age  => ["Prašome užpildyti savo Amžius"]
}
```


### Konfigūruojant Active Record

`config.active_record` įtraukia įvairias konfigūracijos parinktis:

#### `config.active_record.logger`

Priima žurnalą, atitinkantį Log4r sąsają arba numatytąjį Ruby Logger klasės žurnalą, kuris tada perduodamas visiems naujiems duomenų bazės ryšiams. Šį žurnalą galite gauti, iškviesdami `logger` arba ant Active Record modelio klasės, arba ant Active Record modelio pavyzdžio. Nustatykite kaip `nil`, jei norite išjungti žurnalavimą.

#### `config.active_record.primary_key_prefix_type`

Leidžia keisti pirminio rakto stulpelių pavadinimo nustatymą. Pagal nutylėjimą Rails priima, kad pirminio rakto stulpeliai yra pavadinti `id` (ir ši konfigūracijos parinktis nereikia nustatyti). Yra dar du pasirinkimai:
* `:table_name` nustatytų pagrindinį raktą `customerid` Customer klasėje.
* `:table_name_with_underscore` nustatytų pagrindinį raktą `customer_id` Customer klasėje.

#### `config.active_record.table_name_prefix`

Leidžia nustatyti globalų tekstą, kuris bus pridėtas prie lentelės pavadinimų pradžioje. Jei nustatysite tai kaip `northwest_`, tada Customer klasė ieškos `northwest_customers` kaip savo lentelės. Numatytasis yra tuščias tekstas.

#### `config.active_record.table_name_suffix`

Leidžia nustatyti globalų tekstą, kuris bus pridėtas prie lentelės pavadinimų pabaigoje. Jei nustatysite tai kaip `_northwest`, tada Customer klasė ieškos `customers_northwest` kaip savo lentelės. Numatytasis yra tuščias tekstas.

#### `config.active_record.schema_migrations_table_name`

Leidžia nustatyti tekstą, kuris bus naudojamas kaip schemos migracijų lentelės pavadinimas.

#### `config.active_record.internal_metadata_table_name`

Leidžia nustatyti tekstą, kuris bus naudojamas kaip vidinės metaduomenų lentelės pavadinimas.

#### `config.active_record.protected_environments`

Leidžia nustatyti aplinkų pavadinimų masyvą, kuriose draudžiama atlikti destruktyvius veiksmus.

#### `config.active_record.pluralize_table_names`

Nurodo, ar Rails ieškos vienaskaitos ar daugiskaitos lentelės pavadinimų duomenų bazėje. Jei nustatytas kaip `true` (numatytasis), tada Customer klasė naudos `customers` lentelę. Jei nustatytas kaip `false`, tada Customer klasė naudos `customer` lentelę.

#### `config.active_record.default_timezone`

Nustato, ar naudoti `Time.local` (jei nustatytas kaip `:local`) ar `Time.utc` (jei nustatytas kaip `:utc`) kai gaunami datos ir laikai iš duomenų bazės. Numatytasis yra `:utc`.

#### `config.active_record.schema_format`

Valdo duomenų bazės schemos iškėlimo į failą formatą. Galimi variantai yra `:ruby` (numatytasis) - nepriklausomas nuo duomenų bazės versijos, priklausantis nuo migracijų, arba `:sql` - rinkinys (potencialiai priklausomų nuo duomenų bazės) SQL teiginių.

#### `config.active_record.error_on_ignored_order`

Nurodo, ar turėtų būti išmetama klaida, jei užklausos tvarka yra ignoruojama vykdant partijinę užklausą. Galimi variantai yra `true` (išmesti klaidą) arba `false` (įspėti). Numatytasis yra `false`.

#### `config.active_record.timestamped_migrations`

Valdo, ar migracijos numeruojamos serijiniais sveikais skaičiais arba laiko žymėmis. Numatytasis yra `true`, naudoti laiko žymes, kurios yra pageidaujamos, jei daugiau nei vienas programuotojas dirba su ta pačia programa.

#### `config.active_record.db_warnings_action`

Valdo veiksmą, kuris bus atliktas, kai SQL užklausa sukelia įspėjimą. Galimi variantai yra:

  * `:ignore` - Duomenų bazės įspėjimai bus ignoruojami. Tai yra numatytasis.

  * `:log` - Duomenų bazės įspėjimai bus įrašomi per `ActiveRecord.logger` su `:warn` lygiu.

  * `:raise` - Duomenų bazės įspėjimai bus iškeliami kaip `ActiveRecord::SQLWarning`.

  * `:report` - Duomenų bazės įspėjimai bus pranešami apie Rails klaidų pranešėjų prenumeratoriams.

  * Custom proc - Galima pateikti pasirinktinį proc. Jis turėtų priimti `SQLWarning` klaidos objektą.
Pavyzdžiui:

```ruby
config.active_record.db_warnings_action = ->(įspėjimas) do
  # Pranešimas pasirinktai išimčių pranešimų aptarnavimo paslaugai
  Bugsnag.notify(įspėjimas.message) do |pranešimas|
    pranešimas.add_metadata(:įspėjimo_kodas, įspėjimas.code)
    pranešimas.add_metadata(:įspėjimo_lygis, įspėjimas.level)
  end
end
```

#### `config.active_record.db_warnings_ignore`

Nurodo leidžiamų įspėjimų kodų ir pranešimų sąrašą, kurie bus ignoruojami, nepriklausomai nuo konfigūruoto `db_warnings_action`.
Numatytasis elgesys yra pranešti apie visus įspėjimus. Ignoruoti įspėjimai gali būti nurodyti kaip eilutės arba reguliariosios išraiškos. Pavyzdžiui:

```ruby
config.active_record.db_warnings_action = :raise
# Šie įspėjimai nebus iškelti
config.active_record.db_warnings_ignore = [
  /Netinkamas utf8mb4 simbolių eilutės formatas/,
  "Tikslus įspėjimo pranešimas",
  "1062", # MySQL klaida 1062: Dublikuotas įrašas
]
```

#### `config.active_record.migration_strategy`

Valdo strategijos klasę, naudojamą vykdyti schemos sakinio metodus migracijoje. Numatytoji klasė
deleguoja prisijungimo adapteriui. Pasirinktinės strategijos turėtų paveldėti iš `ActiveRecord::Migration::ExecutionStrategy`,
arba gali paveldėti iš `DefaultStrategy`, kuris išlaikys numatytąjį elgesį neatliktiems metodams:

```ruby
class CustomMigrationStrategy < ActiveRecord::Migration::DefaultStrategy
  def drop_table(*)
    raise "Lentelių išmetimas nepalaikomas!"
  end
end

config.active_record.migration_strategy = CustomMigrationStrategy
```

#### `config.active_record.lock_optimistically`

Valdo, ar Active Record naudos optimistinį užrakinimą, pagal numatytuosius nustatymus tai yra `true`.

#### `config.active_record.cache_timestamp_format`

Valdo laiko žymos formato reikšmę talpyklos raktui. Numatytasis yra `:usec`.

#### `config.active_record.record_timestamps`

Yra boolean tipo reikšmė, kuri valdo, ar įrašų laiko žymėjimas `create` ir `update` operacijose vyksta modelyje. Numatytasis nustatymas yra `true`.

#### `config.active_record.partial_inserts`

Yra boolean tipo reikšmė, kuri valdo, ar kuriant naujus įrašus naudojami daliniai įrašai (t. y. ar įterpiami tik atributai, kurie skiriasi nuo numatytųjų).

Numatytasis nustatymas priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis nustatymas yra |
| --------------------- | ------------------------- |
| (pradinis)            | `true`                    |
| 7.0                   | `false`                   |

#### `config.active_record.partial_updates`

Yra boolean tipo reikšmė, kuri valdo, ar atnaujinant esamus įrašus naudojami daliniai įrašai (t. y. ar atnaujinimai nustato tik tuos atributus, kurie yra nešvarūs). Atkreipkite dėmesį, kad naudojant dalinius atnaujinimus, taip pat turėtumėte naudoti optimistinį užrakinimą `config.active_record.lock_optimistically`, nes konkurentiniai atnaujinimai gali rašyti atributus pagal galimai pasenusią skaitymo būseną. Numatytasis nustatymas yra `true`.

#### `config.active_record.maintain_test_schema`

Yra boolean tipo reikšmė, kuri valdo, ar Active Record turėtų bandyti laikyti jūsų testų duomenų bazės schemą atnaujintą su `db/schema.rb` (arba `db/structure.sql`), kai vykdote savo testus. Numatytasis yra `true`.

#### `config.active_record.dump_schema_after_migration`

Yra vėliavėlė, kuri valdo, ar turėtų įvykti schemos iškėlimas
(`db/schema.rb` arba `db/structure.sql`), kai vykdomos migracijos. Tai nustatoma
`false` `config/environments/production.rb`, kuris yra sugeneruotas Rails. Numatytasis nustatymas yra `true`, jei šis konfigūracijos parametras nėra nustatytas.
#### `config.active_record.dump_schemas`

Valdo, kurios duomenų bazės schemos bus išsaugotos, kai iškviečiamas `db:schema:dump`.
Galimi variantai yra `:schema_search_path` (numatytasis), kuris išsaugo visas schemos, nurodytas `schema_search_path`,
`:all`, kuris visada išsaugo visas schemas, nepriklausomai nuo `schema_search_path`,
arba eilutė, kurioje yra per kablelį atskirtos schemos.

#### `config.active_record.before_committed_on_all_records`

Įjungia `before_committed!` atgalinius kvietimus visiems įtrauktiems į transakciją įrašams.
Ankstesnis veikimas buvo vykdyti atgalinius kvietimus tik pirmajam įrašo kopijai,
jei transakcijoje buvo įtraukta kelios tos pačios įrašo kopijos.

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (pradinis)            | `false`                |
| 7.1                   | `true`                 |

#### `config.active_record.belongs_to_required_by_default`

Yra boolean tipo reikšmė ir valdo, ar įrašas nepavyks patikrinimo, jei
`belongs_to` asociacija nėra pateikiama.

Numatytosios reikšmės priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (pradinis)            | `nil`                  |
| 5.0                   | `true`                 |

#### `config.active_record.belongs_to_required_validates_foreign_key`

Įjungia tik tėvui susijusius stulpelius tikrinant, ar jie yra pateikti, kai tėvas yra privalomas.
Ankstesnis veikimas buvo tikrinti tėvo įrašo buvimą, kas kartą atnaujinant vaiko įrašą, net jei tėvas nepasikeitė,
atlikdavo papildomą užklausą, kad gautų tėvą.

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (pradinis)            | `true`                 |
| 7.1                   | `false`                |

#### `config.active_record.marshalling_format_version`

Kai nustatoma reikšmė `7.1`, įjungiamas efektyvesnis Active Record objekto serijinimas su `Marshal.dump`.

Tai keičia serijinimo formatą, todėl modeliai, serijinami šiuo
būdu, negali būti skaityti senesnėmis (< 7.1) Rails versijomis. Tačiau pranešimai,
naudojant senąjį formatą, vis tiek gali būti skaityti, nepriklausomai nuo šios optimizacijos
įjungimo.

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (pradinis)            | `6.1`                  |
| 7.1                   | `7.1`                  |

#### `config.active_record.action_on_strict_loading_violation`

Leidžia iškelti išimtį arba įrašyti į žurnalą, jei asociacijai nustatytas `strict_loading`.
Numatytasis reikšmė visuose aplinkose yra `:raise`. Ji gali būti
pakeista į `:log`, kad pažeidimai būtų siunčiami į žurnalą, o ne iškelti išimtį.

#### `config.active_record.strict_loading_by_default`

Yra boolean tipo reikšmė, kuri pagal numatytąją reikšmę įjungia arba išjungia `strict_loading` režimą.
Numatytasis režimas yra `false`.

#### `config.active_record.warn_on_records_fetched_greater_than`

Leidžia nustatyti įspėjimo ribą užklausos rezultato dydžiui. Jei užklausos grąžinamų įrašų skaičius viršija ribą, įspėjimas yra įrašomas į žurnalą. Tai
gali būti naudojama identifikuoti užklausas, kurios gali sukelti atminties padidėjimą.
#### `config.active_record.index_nested_attribute_errors`

Leidžia rodyti klaidas, susijusias su įdėtomis `has_many` ryšiais, su indeksu ir klaida. Numatytasis nustatymas yra `false`.

#### `config.active_record.use_schema_cache_dump`

Leidžia naudotojams gauti schemos talpyklos informaciją iš `db/schema_cache.yml` (sugeneruota naudojant `bin/rails db:schema:cache:dump`), vietoj to, kad reikėtų siųsti užklausą į duomenų bazę, kad gautumėte šią informaciją. Numatytasis nustatymas yra `true`.

#### `config.active_record.cache_versioning`

Nurodo, ar naudoti stabilų `#cache_key` metodą, kurį lydi kintantis versijos `#cache_version` metodas.

Numatytasis nustatymas priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis nustatymas yra |
| --------------------- | ------------------------ |
| (pradinis)            | `false`                  |
| 5.2                   | `true`                   |

#### `config.active_record.collection_cache_versioning`

Leidžia panaudoti tą patį talpyklos raktą, kai keičiasi `ActiveRecord::Relation` tipo talpinamo objekto, perkeldami sąryšio talpyklos rakto nestabilią informaciją (didžiausią atnaujinimo laiką ir skaičių) į talpyklos versiją, kad būtų galima pernaudoti talpyklos raktą.

Numatytasis nustatymas priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis nustatymas yra |
| --------------------- | ------------------------ |
| (pradinis)            | `false`                  |
| 6.0                   | `true`                   |

#### `config.active_record.has_many_inversing`

Leidžia nustatyti atvirkštinį įrašą, kai perkeliamas ryšys nuo `belongs_to` iki `has_many` asociacijų.

Numatytasis nustatymas priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis nustatymas yra |
| --------------------- | ------------------------ |
| (pradinis)            | `false`                  |
| 6.1                   | `true`                   |

#### `config.active_record.automatic_scope_inversing`

Leidžia automatiškai nustatyti `inverse_of` asociacijoms su apimtimi.

Numatytasis nustatymas priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis nustatymas yra |
| --------------------- | ------------------------ |
| (pradinis)            | `false`                  |
| 7.0                   | `true`                   |

#### `config.active_record.destroy_association_async_job`

Leidžia nurodyti darbą, kuris bus naudojamas sunaikinti susijusius įrašus fone. Numatytasis nustatymas yra `ActiveRecord::DestroyAssociationAsyncJob`.

#### `config.active_record.destroy_association_async_batch_size`

Leidžia nurodyti maksimalų įrašų skaičių, kuris bus sunaikintas fono darbe naudojant `dependent: :destroy_async` asociacijos parinktį. Visi kiti veiksniai būnant vienodiems, mažesnis partijos dydis įtrauks daugiau, trumpesnius fono darbus, o didesnis partijos dydis įtrauks mažiau, ilgesnius fono darbus. Šis nustatymas numatytasis yra `nil`, dėl ko visi priklausomi įrašai tam tikrai asociacijai bus sunaikinti tame pačiame fono darbe.

#### `config.active_record.queues.destroy`

Leidžia nurodyti Active Job eilę, kuri bus naudojama sunaikinimo darbams. Kai šis nustatymas yra `nil`, valymo darbai siunčiami į numatytąją Active Job eilę (žr. `config.active_job.default_queue_name`). Numatytasis nustatymas yra `nil`.
#### `config.active_record.enumerate_columns_in_select_statements`

Kai `true`, visada įtraukia stulpelių pavadinimus į `SELECT` užklausas ir vengia wildcard `SELECT * FROM ...` užklausų. Tai išvengia paruoštų užklausų kešo klaidų, pavyzdžiui, pridedant stulpelius prie PostgreSQL duomenų bazės. Numatytoji reikšmė yra `false`.

#### `config.active_record.verify_foreign_keys_for_fixtures`

Užtikrina, kad po testuose įkeltų fiktyvių duomenų, visi užsienio raktų apribojimai būtų galiojantys. Palaikoma tik PostgreSQL ir SQLite.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `false`              |
| 7.0                   | `true`               |

#### `config.active_record.raise_on_assign_to_attr_readonly`

Įgalina klaidų generavimą priskiriant reikšmes `attr_readonly` atributams. Ankstesnis veikimas leido priskirti reikšmes, bet tylomis nepersistuodavo pakeitimų duomenų bazėje.

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`

Kai kelios Active Record instancijos keičia tą patį įrašą transakcijoje, „Rails“ vykdo `after_commit` arba `after_rollback` atgalinio iškvietimo funkcijas tik vienai iš jų. Ši parinktis nurodo, kaip „Rails“ pasirenka, kuri instancija gauna atgalinio iškvietimo funkcijas.

Kai `true`, transakcijos atgalinio iškvietimo funkcijos vykdomos pirmajai išsaugotai instancijai, net jei jos būsena gali būti pasenusi.

Kai `false`, transakcijos atgalinio iškvietimo funkcijos vykdomos instancijoms su naujausia būsena. Šios instancijos yra pasirenkamos taip:

- Bendrai, transakcijos atgalinio iškvietimo funkcijos vykdomos paskutinei instancijai, kuri išsaugo duotą įrašą transakcijoje.
- Yra dvi išimtys:
    - Jei įrašas yra sukurtas transakcijoje, o tada atnaujintas kitos instancijos, `after_create_commit` atgalinio iškvietimo funkcijos bus vykdomos antroje instancijoje. Tai yra vietoj `after_update_commit` atgalinio iškvietimo funkcijų, kurios būtų naiviai vykdomos pagal tos instancijos būseną.
    - Jei įrašas yra sunaikintas transakcijoje, tada `after_destroy_commit` atgalinio iškvietimo funkcijos bus vykdomos paskutinėje sunaikintoje instancijoje, net jei pasenusi instancija vėliau atliko atnaujinimą (kuris paveiks 0 eilučių).

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.default_column_serializer`

Serializer įgyvendinimas, kurį naudoti, jei nėra aiškiai nurodytas tam tikram stulpeliui.

Istoriniu požiūriu `serialize` ir `store`, leidžiantys naudoti alternatyvius serializer įgyvendinimus, pagal numatytuosius naudojo `YAML`, bet tai nėra labai efektyvus formatas ir gali būti saugumo pažeidimų šaltinis, jei nesąžiningai naudojamas.

Dėl šios priežasties rekomenduojama rinktis griežtesnius, ribotus formatus duomenų bazės serializavimui.
Deja, Ruby standartinėje bibliotekoje nėra tinkamų numatytųjų reikšmių. `JSON` gali veikti kaip formatas, tačiau `json` paketai konvertuos nepalaikomas tipos į eilutes, kas gali sukelti klaidas.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | --------------------- |
| (pradinė)             | `YAML`                |
| 7.1                   | `nil`                 |

#### `config.active_record.run_after_transaction_callbacks_in_order_defined`

Jei `true`, `after_commit` atgaliniai iškvietimai vykdomi ta tvarka, kurioje jie apibrėžti modelyje. Jei `false`, jie vykdomi atvirkštine tvarka.

Visi kiti atgaliniai iškvietimai visada vykdomi ta tvarka, kurioje jie apibrėžti modelyje (jei nenaudojate `prepend: true`).

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | --------------------- |
| (pradinė)             | `false`               |
| 7.1                   | `true`                |

#### `config.active_record.query_log_tags_enabled`

Nurodo, ar įjungti adapterio lygio užklausos komentarus. Numatytoji reikšmė yra `false`.

PASTABA: Kai tai nustatoma kaip `true`, duomenų bazės paruoštosios instrukcijos automatiškai bus išjungtos.

#### `config.active_record.query_log_tags`

Apibrėžia `Array`, nurodantį raktų/vertės žymes, kurios bus įterptos SQL komentare. Numatytoji reikšmė yra `[ :application ]`, iš anksto apibrėžta žymė, grąžinanti programos pavadinimą.

#### `config.active_record.query_log_tags_format`

Nurodo `Symbol`, nurodantį naudotiną formatuotoją žymėms. Galimos reikšmės yra `:sqlcommenter` ir `:legacy`.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | --------------------- |
| (pradinė)             | `:legacy`             |
| 7.1                   | `:sqlcommenter`       |

#### `config.active_record.cache_query_log_tags`

Nurodo, ar įjungti užklausos žymių kešavimą. Programoms, kuriose yra daug užklausų, užklausos žymių kešavimas gali suteikti našumo pranašumą, kai kontekstas nepasikeičia užklausos gyvavimo metu. Numatytoji reikšmė yra `false`.

#### `config.active_record.schema_cache_ignored_tables`

Apibrėžia sąrašą lentelių, kurios turėtų būti ignoruojamos generuojant schemos kešą. Priima `Array` eilučių, kurios atitinka lentelių pavadinimus, arba reguliariuosius išraiškas.

#### `config.active_record.verbose_query_logs`

Nurodo, ar žurnalizuoti metodų, kurie iškviečia duomenų bazės užklausas, šaltinių vietas žemiau atitinkamų užklausų. Pagal numatytuosius nustatymus, vėliavėlė yra `true` vystymoje ir `false` visose kitose aplinkose.

#### `config.active_record.sqlite3_adapter_strict_strings_by_default`

Nurodo, ar turėtų būti naudojamas SQLite3Adapter griežtas eilučių režimas. Griežto eilučių režimo naudojimas išjungia dvigubai cituojamas eilučių literas.

SQLite turi keletą ypatumų, susijusių su dvigubai cituojamomis eilučių literomis.
Jis pirmiausia bando laikyti dvigubai cituojamas eilutes kaip identifikatorių pavadinimus, bet jei jie neegzistuoja,
tada jas laiko eilučių literomis. Dėl šios priežasties klaidos gali būti nepastebėtos.
Pavyzdžiui, galima sukurti indeksą neegzistuojančiam stulpeliui.
Daugiau informacijos žr. [SQLite dokumentacijoje](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted).
Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.async_query_executor`

Nurodo, kaip yra sujungiami asinchroniniai užklausos.

Numatytoji reikšmė yra `nil`, kas reiškia, kad `load_async` yra išjungtas ir užklausos yra vykdomos tiesiogiai.
Kad užklausos būtų vykdomos asinchroniškai, reikia nustatyti `:global_thread_pool` arba `:multi_thread_pool`.

`:global_thread_pool` naudos vieną bendrą resursų baseiną visoms duomenų bazėms, prie kurių prisijungia programa. Tai yra pageidautina konfigūracija
programoms, kurios naudoja tik vieną duomenų bazę arba kurios vienu metu tikrina tik vieną duomenų bazės dalį.

`:multi_thread_pool` naudos po vieną resursų baseiną kiekvienai duomenų bazei, ir kiekvienam baseinui galima konfigūruoti dydį `database.yml` failo
per `max_threads` ir `min_thread` savybes. Tai gali būti naudinga programoms, kurios reguliariai tikrina kelias duomenų bazes vienu metu ir kurios turi tiksliai apibrėžti didžiausią konkurenciją.

#### `config.active_record.global_executor_concurrency`

Naudojama kartu su `config.active_record.async_query_executor = :global_thread_pool`, nustato, kiek asinchroninių
užklausų gali būti vykdoma vienu metu.

Numatytoji reikšmė yra `4`.

Šį skaičių reikia apsvarstyti atsižvelgiant į duomenų bazės resursų baseino dydį, kuris yra konfigūruotas `database.yml` faile. Prisijungimų baseinui
turėtų būti pakankamai didelis, kad tilptų tiek pagrindiniai gijos (pvz., interneto serverio ar darbo gijos), tiek ir fono gijos.

#### `config.active_record.allow_deprecated_singular_associations_name`

Tai įgalina pasenusią elgseną, kurioje vienaskaitos asociacijos gali būti paminėtos pagal daugiskaitos pavadinimą `where` sąlygose. Nustatant šią reikšmę į `false`, veikimas tampa efektyvesnis.

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end

Comment.where(post: post_id).count  # => 5

# Kai `allow_deprecated_singular_associations_name` yra true:
Comment.where(posts: post_id).count # => 5 (deprecijavimo įspėjimas)

# Kai `allow_deprecated_singular_associations_name` yra false:
Comment.where(posts: post_id).count # => klaida
```

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.yaml_column_permitted_classes`

Numatytoji reikšmė yra `[Symbol]`. Leidžia programoms įtraukti papildomus leistinus klases `safe_load()` funkcijai `ActiveRecord::Coders::YAMLColumn`.

#### `config.active_record.use_yaml_unsafe_load`

Numatytoji reikšmė yra `false`. Leidžia programoms pasirinkti naudoti `unsafe_load` funkciją `ActiveRecord::Coders::YAMLColumn`.

#### `config.active_record.raise_int_wider_than_64bit`

Numatytoji reikšmė yra `true`. Nustato, ar iškelti išimtį, kai PostgreSQL adapteriui perduodamas skaičius, kuris yra platesnis nei 64 bitų ženklas.

#### `ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans` ir `ActiveRecord::ConnectionAdapters::TrilogyAdapter.emulate_booleans`

Valdo tai, ar Active Record MySQL adapteris laikys visas `tinyint(1)` stulpelius kaip boolean tipo. Numatytoji reikšmė yra `true`.

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.create_unlogged_tables`

Valdo tai, ar PostgreSQL sukurtos duomenų bazės lentelės turėtų būti "unlogged", kas gali pagreitinti veikimą, bet padidina duomenų praradimo riziką, jei duomenų bazė sugriūna. Labai rekomenduojama tai neįjungti produkcinėje aplinkoje.
Numatytoji reikšmė visose aplinkose yra `false`.
Norint tai įjungti testams:

```ruby
# config/environments/test.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.create_unlogged_tables = true
end
```

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type`

Valdo, kokį natūralųjį tipą naudos Active Record PostgreSQL adapteris, kai iškviečiate `datetime` migracijoje ar schemoje. Priima simbolį, kuris turi atitikti vieną iš sukonfigūruotų `NATIVE_DATABASE_TYPES`. Numatytasis yra `:timestamp`, tai reiškia, kad migracijoje `t.datetime` sukurs stulpelį "timestamp without time zone".

Norint naudoti "timestamp with time zone":

```ruby
# config/application.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.datetime_type = :timestamptz
end
```

Jei pakeisite šį nustatymą, turėtumėte paleisti `bin/rails db:migrate`, kad atnaujintumėte savo schema.rb.

#### `ActiveRecord::SchemaDumper.ignore_tables`

Priima masyvą lentelių, kurios _neturėtų_ būti įtrauktos į jokį sugeneruotą schemos failą.

#### `ActiveRecord::SchemaDumper.fk_ignore_pattern`

Leidžia nustatyti kitą reguliariąją išraišką, kuri bus naudojama nuspręsti, ar užsienio rakto pavadinimas turėtų būti išsaugotas db/schema.rb ar ne. Pagal numatytuosius nustatymus, užsienio rakto pavadinimai, prasidedantys `fk_rails_`, nėra eksportuojami į duomenų bazės schemos atvaizdą. Numatytasis nustatymas yra `/^fk_rails_[0-9a-f]{10}$/`.

#### `config.active_record.encryption.hash_digest_class`

Nustato naudojamą skaitmeninio parašo algoritmą, kurį naudoja Active Record Encryption.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
|-----------------------|---------------------------|
| (pradinis)            | `OpenSSL::Digest::SHA1`   |
| 7.1                   | `OpenSSL::Digest::SHA256` |

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

Įjungia palaikymą iššifruoti esamus duomenis, užšifruotus naudojant SHA-1 skaitmeninio parašo klasę. Kai `false`, bus palaikomas tik konfigūruotas skaitmeninio parašo algoritmas `config.active_record.encryption.hash_digest_class`.

Numatytasis nustatymas priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
|-----------------------|----------------------|
| (pradinis)            | `true`               |
| 7.1                   | `false`              |

### Konfigūruojant Action Controller

`config.action_controller` apima keletą konfigūracijos nustatymų:

#### `config.action_controller.asset_host`

Nustato turinio šaltinio (asset) serverio adresą. Naudinga, kai turinio šaltiniai talpinami naudojant CDN, o ne patį aplikacijos serverį. Šį nustatymą turėtumėte naudoti tik tada, jei turite skirtingą konfigūraciją Action Mailer, kitu atveju naudokite `config.asset_host`.

#### `config.action_controller.perform_caching`

Konfigūruoja, ar aplikacija turėtų naudoti kešavimo funkcijas, kurias teikia Action Controller komponentas, ar ne. Nustatykite į `false` vystymo aplinkoje ir į `true` produkcijoje. Jei nenurodyta, numatytasis nustatymas bus `true`.

#### `config.action_controller.default_static_extension`

Konfigūruoja plėtinį, naudojamą kaupiamoms puslapiams. Numatytasis yra `.html`.

#### `config.action_controller.include_all_helpers`

Konfigūruoja, ar visi vaizdo pagalbininkai yra prieinami visur arba apriboti atitinkamojo valdiklio kontekstui. Jei nustatoma į `false`, `UsersHelper` metodai yra prieinami tik vaizdams, kurie yra rodomi kaip `UsersController` dalis. Jei nustatoma į `true`, `UsersHelper` metodai yra prieinami visur. Numatytasis konfigūracijos elgesys (kai šis nustatymas nėra aiškiai nustatytas į `true` ar `false`) yra tas, kad visi vaizdo pagalbininkai yra prieinami kiekvienam valdikliui.
#### `config.action_controller.logger`

Priima žurnalą, kuris atitinka Log4r sąsają arba numatytąjį Ruby žurnalo klasę, kuri tada naudojama žurnaluioti informaciją iš Action Controller. Nustatykite į `nil`, jei norite išjungti žurnalavimą.

#### `config.action_controller.request_forgery_protection_token`

Nustato užklausos suklastojimo žetoną (RequestForgery) parametrų pavadinimą. Iškvietus `protect_from_forgery`, pagal numatytuosius nustatymus jis nustatomas į `:authenticity_token`.

#### `config.action_controller.allow_forgery_protection`

Įjungia arba išjungia CSRF apsaugą. Numatytuoju atveju tai yra `false` testavimo aplinkoje ir `true` visose kitose aplinkose.

#### `config.action_controller.forgery_protection_origin_check`

Konfigūruoja, ar HTTP `Origin` antraštė turėtų būti patikrinama prieš svetainės kilmę kaip papildoma CSRF gynyba.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (originalus)          | `false`                |
| 5.0                   | `true`                 |

#### `config.action_controller.per_form_csrf_tokens`

Konfigūruoja, ar CSRF žetonai yra galiojantys tik tam metodui/veiksmui, kuris juos sukūrė.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (originalus)          | `false`                |
| 5.0                   | `true`                 |

#### `config.action_controller.default_protect_from_forgery`

Nustato, ar suklastojimo apsauga yra pridedama prie `ActionController::Base`.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (originalus)          | `false`                |
| 5.2                   | `true`                 |

#### `config.action_controller.relative_url_root`

Gali būti naudojama pranešti Rails, kad jūs [diegiate į subkatalogą](
configuring.html#deploy-to-a-subdirectory-relative-url-root). Numatytasis yra
[`config.relative_url_root`](#config-relative-url-root).

#### `config.action_controller.permit_all_parameters`

Leidžia visus parametrus masiniam priskyrimui pagal numatytuosius nustatymus. Numatytasis yra `false`.

#### `config.action_controller.action_on_unpermitted_parameters`

Valdo elgesį, kai rasti parametrai, kurie nėra išreiškčiai leidžiami. Numatytasis yra `:log` testavimo ir plėtojimo aplinkose, kitu atveju `false`. Galimos reikšmės:

* `false` - nieko nedaryti
* `:log` - išleisti `ActiveSupport::Notifications.instrument` įvykį `unpermitted_parameters.action_controller` temoje ir žurnaluose DEBUG lygmeniu
* `:raise` - iškelti `ActionController::UnpermittedParameters` išimtį

#### `config.action_controller.always_permitted_parameters`

Nustato sąrašą leidžiamų parametrų, kurie pagal numatytuosius nustatymus yra leidžiami. Numatytosios reikšmės yra `['controller', 'action']`.

#### `config.action_controller.enable_fragment_cache_logging`

Nustato, ar žurnalizuoti fragmento kešo skaitymus ir rašymus išsamiai, kaip parodyta žemiau:

```
Read fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/d0bdf2974e1ef6d31685c3b392ad0b74 (0.6ms)
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Write fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/3b4e249ac9d168c617e32e84b99218b5 (1.1ms)
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

Numatytuoju atveju tai nustatoma į `false`, dėl ko gaunama ši išvestis:

```
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```
#### `config.action_controller.raise_on_open_redirects`

Iškelia `ActionController::Redirecting::UnsafeRedirectError` klaidą, kai įvyksta nepageidaujamas atviro peradresavimo atvejis.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `false`              |
| 7.0                   | `true`               |

#### `config.action_controller.log_query_tags_around_actions`

Nustato, ar užklausos žymės kontrolerio kontekstas bus automatiškai atnaujinamas per `around_filter`. Numatytoji reikšmė yra `true`.

#### `config.action_controller.wrap_parameters_by_default`

Konfigūruoja [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html) numatytąjį apvyniojimą JSON užklausoms.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `false`              |
| 7.0                   | `true`               |

#### `ActionController::Base.wrap_parameters`

Konfigūruoja [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html). Tai gali būti iškviesta viršutiniame lygyje arba atskiruose kontroleriuose.

#### `config.action_controller.allow_deprecated_parameters_hash_equality`

Valdo `ActionController::Parameters#==` elgesį su `Hash` argumentais. Nustatymo reikšmė nusako, ar `ActionController::Parameters` objektas yra lygus atitinkamam `Hash` objektui.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `true`               |
| 7.1                   | `false`              |

### Konfigūruojant Action Dispatch

#### `config.action_dispatch.cookies_serializer`

Nurodo, kurį serijalizatorių naudoti slapukams. Priima tas pačias reikšmes kaip ir [`config.active_support.message_serializer`](#config-active-support-message-serializer), taip pat `:hybrid`, kuris yra sinonimas `:json_allow_marshal`.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `:marshal`           |
| 7.0                   | `:json`              |

#### `config.action_dispatch.debug_exception_log_level`

Konfigūruoja žurnalo lygį, kurį naudoja `DebugExceptions` tarpinė programinė įranga, kai registruoja neatrastas išimtis vykdant užklausas.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `:fatal`             |
| 7.1                   | `:error`             |

#### `config.action_dispatch.default_headers`

Yra raktų ir reikšmių rinkinys, kuris numatytai nustatomas kiekvienoje atsako žinutėje.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "1; mode=block",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.0                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.1                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
#### `config.action_dispatch.default_charset`

Nurodo numatytąjį simbolių rinkinį visiems atvaizdavimams. Numatytoji reikšmė yra `nil`.

#### `config.action_dispatch.tld_length`

Nustato programos domeno viršutinio lygio domeno (TLD) ilgį. Numatytoji reikšmė yra `1`.

#### `config.action_dispatch.ignore_accept_header`

Nurodo, ar ignoruoti užklausos priėmimo antraštės. Numatytoji reikšmė yra `false`.

#### `config.action_dispatch.x_sendfile_header`

Nurodo serverio specifinę X-Sendfile antraštę. Tai naudinga pagreitintam failų siuntimui iš serverio. Pavyzdžiui, ji gali būti nustatyta kaip 'X-Sendfile' Apache serveryje.

#### `config.action_dispatch.http_auth_salt`

Nustato HTTP autentifikacijos druskos reikšmę. Numatytoji reikšmė yra `'http authentication'`.

#### `config.action_dispatch.signed_cookie_salt`

Nustato pasirašytų slapukų druskos reikšmę. Numatytoji reikšmė yra `'signed cookie'`.

#### `config.action_dispatch.encrypted_cookie_salt`

Nustato užšifruotų slapukų druskos reikšmę. Numatytoji reikšmė yra `'encrypted cookie'`.

#### `config.action_dispatch.encrypted_signed_cookie_salt`

Nustato pasirašytų užšifruotų slapukų druskos reikšmę. Numatytoji reikšmė yra `'signed encrypted cookie'`.

#### `config.action_dispatch.authenticated_encrypted_cookie_salt`

Nustato autentifikuotų užšifruotų slapukų druskos reikšmę. Numatytoji reikšmė yra `'authenticated encrypted cookie'`.

#### `config.action_dispatch.encrypted_cookie_cipher`

Nustato šifravimui naudojamą šifravimo algoritmą užšifruotiems slapukams. Numatytoji reikšmė yra `"aes-256-gcm"`.

#### `config.action_dispatch.signed_cookie_digest`

Nustato pasirašymui naudojamą maišos funkciją pasirašytiems slapukams. Numatytoji reikšmė yra `"SHA1"`.

#### `config.action_dispatch.cookies_rotations`

Leidžia keisti paslaptis, šifravimo algoritmus ir maišos funkcijas užšifruotiems ir pasirašytiems slapukams.

#### `config.action_dispatch.use_authenticated_cookie_encryption`

Valdo, ar pasirašyti ir užšifruoti slapukai naudoja AES-256-GCM šifravimo algoritmą arba senesnį AES-256-CBC šifravimo algoritmą.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `false`              |
| 5.2                   | `true`               |

#### `config.action_dispatch.use_cookies_with_metadata`

Įjungia slapukų rašymą su įterpta paskirties metaduomenimis.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `false`              |
| 6.0                   | `true`               |

#### `config.action_dispatch.perform_deep_munge`

Konfigūruoja, ar `deep_munge` metodas turėtų būti vykdomas su parametrais. Daugiau informacijos rasite [Saugumo vadove](security.html#unsafe-query-generation). Numatytoji reikšmė yra `true`.

#### `config.action_dispatch.rescue_responses`

Konfigūruoja, kurie išimtys priskiriamos HTTP būsenai. Priima hash'ą, kuriame galima nurodyti išimtis/būseną poromis. Numatytoji reikšmė yra:

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

Visos nekonfigūruotos išimtys bus priskirtos 500 Vidinės serverio klaidos būsenai.

#### `config.action_dispatch.cookies_same_site_protection`

Konfigūruoja numatytąją `SameSite` atributo reikšmę nustatant slapukus. Kai nustatoma kaip `nil`, `SameSite` atributas nėra pridedamas. Norint leisti `SameSite` atributo reikšmę konfigūruoti dinamiškai pagal užklausą, galima nurodyti proc. Pavyzdžiui:
```ruby
config.action_dispatch.cookies_same_site_protection = ->(request) do
  :strict unless request.user_agent == "TestAgent"
end
```

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (originalus)          | `nil`                  |
| 6.1                   | `:lax`                 |

#### `config.action_dispatch.ssl_default_redirect_status`

Konfigūruoja numatytąjį HTTP būsenos kodą, naudojamą peradresuojant ne-GET/HEAD užklausas iš HTTP į HTTPS `ActionDispatch::SSL` tarpinėje.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (originalus)          | `307`                  |
| 6.1                   | `308`                  |

#### `config.action_dispatch.log_rescued_responses`

Įjungia tuos neapdorotus išimtis, sukonfigūruotas `rescue_responses`, žurnalo įrašymą. Numatytasis yra `true`.

#### `ActionDispatch::Callbacks.before`

Priima kodo bloką, kuris bus vykdomas prieš užklausą.

#### `ActionDispatch::Callbacks.after`

Priima kodo bloką, kuris bus vykdomas po užklausos.

### Action View konfigūravimas

`config.action_view` apima nedidelį konfigūracijos nustatymų skaičių:

#### `config.action_view.cache_template_loading`

Valdo ar šablonai turėtų būti perkraunami kiekvieno užklausos metu. Numatytasis yra `!config.enable_reloading`.

#### `config.action_view.field_error_proc`

Pateikia HTML generatorių klaidų rodymui, kurios kyla iš Active Model. Blokas yra įvertinamas Action View šablono kontekste. Numatytasis yra

```ruby
Proc.new { |html_tag, instance| content_tag :div, html_tag, class: "field_with_errors" }
```

#### `config.action_view.default_form_builder`

Praneša Rails, kurį formos kūrėją naudoti pagal numatytuosius nustatymus. Numatytasis yra
`ActionView::Helpers::FormBuilder`. Jei norite, kad jūsų formos kūrėjo klasė būtų
įkeliama po inicializacijos (taip, kad ji būtų perkraunama kiekvieno užklausos metu vystymo metu),
galite perduoti jį kaip `String`.

#### `config.action_view.logger`

Priima žurnalo įrašymui, atitinkančiam Log4r sąsają arba numatytajai Ruby Logger klasės, priimamai informacijai iš Action View. Nustatykite `nil`, jei norite išjungti žurnalo įrašymą.

#### `config.action_view.erb_trim_mode`

Nurodo ERB naudojamą pjovimo režimą. Numatytasis yra `'-'`, kas įjungia pjovimą užpakalinėse tarpų vietose ir naujos eilutės, naudojant `<%= -%>` arba `<%= =%>`. Daugiau informacijos rasite [Erubis dokumentacijoje](http://www.kuwata-lab.com/erubis/users-guide.06.html#topics-trimspaces).

#### `config.action_view.frozen_string_literal`

Kompiliuoja ERB šabloną su `# frozen_string_literal: true` magišku komentaru, padarant visus eilučių literalus užšaldytus ir taupant išteklius. Nustatykite `true`, jei norite įjungti jį visiems rodiniams.

#### `config.action_view.embed_authenticity_token_in_remote_forms`

Leidžia nustatyti numatytąjį elgesį `authenticity_token` formose su
`remote: true`. Numatytasis yra `false`, kas reiškia, kad nuotolinės formos
neįtrauks `authenticity_token`, kas yra naudinga, kai
fragmentų kešavimą formoje. Nuotolinės formos gauna autentiškumą iš `meta`
žymos, todėl įterpimas nereikalingas, nebent palaikote naršykles be
JavaScript. Tokiu atveju galite perduoti `authenticity_token: true` kaip
formos parinktį arba nustatyti šią konfigūracijos nustatymą į `true`.
#### `config.action_view.prefix_partial_path_with_controller_namespace`

Nustato, ar daliniai ieškomi išpakavimo aplanko šablonuose, kurie yra renderinami iš pavadinimo erdvinės kontrolerio. Pavyzdžiui, pagalvokite apie kontrolerį, kurio pavadinimas yra `Admin::ArticlesController`, kuris renderina šį šabloną:

```erb
<%= render @article %>
```

Numatytoji nuostata yra `true`, tai naudoja dalinį šabloną `/admin/articles/_article.erb`. Nustatant reikšmę į `false`, būtų renderinamas `/articles/_article.erb`, kas yra tas pats elgesys kaip ir renderinant iš neerdvinio kontrolerio, pvz., `ArticlesController`.

#### `config.action_view.automatically_disable_submit_tag`

Nustato, ar `submit_tag` automatiškai išjungiamas paspaudus, pagal numatytąją nuostatą tai yra `true`.

#### `config.action_view.debug_missing_translation`

Nustato, ar praleistų vertimų raktas yra apgaubtas `<span>` žyma ar ne. Pagal numatytąją nuostatą tai yra `true`.

#### `config.action_view.form_with_generates_remote_forms`

Nustato, ar `form_with` generuoja nuotolinės formos ar ne.

Numatytosios reikšmės priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| 5.1                   | `true`               |
| 6.1                   | `false`              |

#### `config.action_view.form_with_generates_ids`

Nustato, ar `form_with` generuoja id reikšmes įvestyse.

Numatytosios reikšmės priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (originali)           | `false`              |
| 5.2                   | `true`               |

#### `config.action_view.default_enforce_utf8`

Nustato, ar formos yra generuojamos su paslėpta žyme, kuri verčia senesnes Internet Explorer versijas pateikti formos koduotę UTF-8.

Numatytosios reikšmės priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (originali)           | `true`               |
| 6.0                   | `false`              |

#### `config.action_view.image_loading`

Nurodo numatytąją reikšmę `<img>` žymos `loading` atributui, kuris yra sugeneruojamas naudojant `image_tag` pagalbininką. Pavyzdžiui, nustatant jį į `"lazy"`, `<img>` žymos, sugeneruotos naudojant `image_tag`, bus įtrauktas `loading="lazy"`, kas [nurodo naršyklei palaukti, kol nuotrauka bus arti vaizdo ekrano, kad ją įkeltų](https://html.spec.whatwg.org/#lazy-loading-attributes). (Šią reikšmę vis tiek galima pakeisti kiekvienai nuotraukai, perduodant pvz. `loading: "eager"` į `image_tag`.) Numatytoji reikšmė yra `nil`.

#### `config.action_view.image_decoding`

Nurodo numatytąją reikšmę `<img>` žymos `decoding` atributui, kuris yra sugeneruojamas naudojant `image_tag` pagalbininką. Numatytoji reikšmė yra `nil`.

#### `config.action_view.annotate_rendered_view_with_filenames`

Nustato, ar sugeneruotas vaizdas yra anotuojamas šablono failo pavadinimais. Pagal numatytąją nuostatą tai yra `false`.

#### `config.action_view.preload_links_header`

Nustato, ar `javascript_include_tag` ir `stylesheet_link_tag` generuos `Link` antraštę, kuri išankstinai įkelia išteklius.

Numatytosios reikšmės priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (originali)           | `nil`                |
| 6.1                   | `true`               |

#### `config.action_view.button_to_generates_button_tag`
Nustato, ar `button_to` atvaizduos `<button>` elementą, nepriklausomai nuo to, ar turinys perduodamas kaip pirmasis argumentas arba kaip blokas.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `false`              |
| 7.0                   | `true`               |

#### `config.action_view.apply_stylesheet_media_default`

Nustato, ar `stylesheet_link_tag` atvaizduos `screen` kaip numatytąją reikšmę atributui `media`, kai ji nenurodyta.

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `true`               |
| 7.0                   | `false`              |

#### `config.action_view.prepend_content_exfiltration_prevention`

Nustato, ar `form_tag` ir `button_to` pagalbininkai sukurs HTML žymes, pradėtas naršyklės saugumo (bet techniškai neteisingo) HTML, kuris garantuoja, kad jų turinys negali būti užfiksuotas jokių ankstesnių neuždarytų žymių. Numatytoji reikšmė yra `false`.

#### `config.action_view.sanitizer_vendor`

Konfigūruoja HTML sanitarus, naudojamus veiksmo peržiūroje, nustatant `ActionView::Helpers::SanitizeHelper.sanitizer_vendor`. Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra                 | Kuri analizuoja žymėjimą kaip |
|-----------------------|--------------------------------------|------------------------|
| (pradinė)            | `Rails::HTML4::Sanitizer`            | HTML4                  |
| 7.1                   | `Rails::HTML5::Sanitizer` (žr. PASTABA) | HTML5                  |

PASTABA: `Rails::HTML5::Sanitizer` nepalaikomas JRuby, todėl JRuby platformose Rails naudos `Rails::HTML4::Sanitizer`.

### Veiksmų pašto konfigūravimas

`config.action_mailbox` teikia šias konfigūracijos parinktis:

#### `config.action_mailbox.logger`

Yra veiksmų pašto naudojamas žurnalas. Jis priima žurnalą, atitinkantį Log4r sąsają arba numatytąją Ruby žurnalo klasę. Numatytasis yra `Rails.logger`.

```ruby
config.action_mailbox.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.action_mailbox.incinerate_after`

Priima `ActiveSupport::Duration`, nurodantį, kiek laiko po `ActionMailbox::InboundEmail` įrašų apdorojimo jie turėtų būti sunaikinti. Numatytasis yra `30.days`.

```ruby
# Sunaikinti gautus laiškus po 14 dienų apdorojimo.
config.action_mailbox.incinerate_after = 14.days
```

#### `config.action_mailbox.queues.incineration`

Priima simbolį, nurodantį veiksmų darbo eilę, skirtą sunaikinimo darbams. Kai ši parinktis yra `nil`, sunaikinimo darbai siunčiami į numatytąją veiksmų darbo eilę (žr. `config.active_job.default_queue_name`).

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)            | `:action_mailbox_incineration` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.queues.routing`

Priima simbolį, nurodantį veiksmų darbo eilę, skirtą maršrutizavimo darbams. Kai ši parinktis yra `nil`, maršrutizavimo darbai siunčiami į numatytąją veiksmų darbo eilę (žr. `config.active_job.default_queue_name`).

Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:
| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (original)            | `:action_mailbox_routing` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.storage_service`

Priima simbolį, nurodantį naudoti Active Storage paslaugą, skirtą el. laiškų įkėlimui. Kai ši parinktis yra `nil`, el. laiškai įkeliami į numatytąją Active Storage paslaugą (žr. `config.active_storage.service`).

### Konfigūruojant Action Mailer

Yra keletas nustatymų, kurie yra prieinami `config.action_mailer`:

#### `config.action_mailer.asset_host`

Nustato turinio šaltinio (asset) serverio adresą. Tai naudinga, kai turinio šaltiniai talpinami ne programos serverio, o CDN. Šį nustatymą turėtumėte naudoti tik tada, jei turite skirtingą konfigūraciją Action Controller, kitu atveju naudokite `config.asset_host`.

#### `config.action_mailer.logger`

Priima žurnalo įrašyklę, atitinkančią Log4r sąsają arba numatytąją Ruby Logger klasę, kuri tada naudojama žurnalo informacijai iš Action Mailer. Nustatykite į `nil`, jei norite išjungti žurnalo įrašymą.

#### `config.action_mailer.smtp_settings`

Leidžia išsamiai konfigūruoti `:smtp` pristatymo būdą. Priima raktų rinkinį, kuriame gali būti bet kurie iš šių raktų:

* `:address` - Leidžia naudoti nuotolinį pašto serverį. Tiesiog pakeiskite jį nuo numatytosios "localhost" reikšmės.
* `:port` - Jei jūsų pašto serveris neveikia 25-ojoje prievadoje, galite tai pakeisti.
* `:domain` - Jei reikia nurodyti HELO domeną, tai galite padaryti čia.
* `:user_name` - Jei jūsų pašto serveris reikalauja autentifikacijos, nustatykite vartotojo vardą šiame nustatyme.
* `:password` - Jei jūsų pašto serveris reikalauja autentifikacijos, nustatykite slaptažodį šiame nustatyme.
* `:authentication` - Jei jūsų pašto serveris reikalauja autentifikacijos, čia turite nurodyti autentifikacijos tipą. Tai yra simbolis ir vienas iš `:plain`, `:login`, `:cram_md5`.
* `:enable_starttls` - Naudokite STARTTLS, kai jungiatės prie savo SMTP serverio ir nesėkmingai, jei nepalaikoma. Numatytoji reikšmė yra `false`.
* `:enable_starttls_auto` - Aptinka, ar jūsų SMTP serveris palaiko STARTTLS ir pradeda jį naudoti. Numatytoji reikšmė yra `true`.
* `:openssl_verify_mode` - Naudojant TLS, galite nustatyti, kaip OpenSSL tikrina sertifikatą. Tai naudinga, jei reikia patvirtinti savarankiškai pasirašytą ir/arba universalųjį sertifikatą. Tai gali būti vienas iš OpenSSL tikrinimo konstantų, `:none` arba `:peer` -- arba konstanta tiesiogiai `OpenSSL::SSL::VERIFY_NONE` arba `OpenSSL::SSL::VERIFY_PEER`, atitinkamai.
* `:ssl/:tls` - Leidžia SMTP ryšiui naudoti SMTP/TLS (SMTPS: SMTP per tiesioginį TLS ryšį).
* `:open_timeout` - Sekundžių skaičius, laukiant jungiantis.
* `:read_timeout` - Sekundžių skaičius, laukiant, kol vyks laiko limito viršijimas skaitant(2) kvietimą.
Be to, galima perduoti bet kokią [konfigūracijos parinktį, kurią `Mail::SMTP` gerbia](https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/smtp.rb).

#### `config.action_mailer.smtp_timeout`

Leidžia konfigūruoti `:open_timeout` ir `:read_timeout` reikšmes `:smtp` pristatymo metodui.

Numatytasis vertė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis vertė yra |
| --------------------- | -------------------- |
| (originalus)          | `nil`                |
| 7.0                   | `5`                  |

#### `config.action_mailer.sendmail_settings`

Leidžia išsamiai konfigūruoti `sendmail` pristatymo metodą. Priima raktų rinkinį, kuriame gali būti bet kuri iš šių parinkčių:

* `:location` - sendmail vykdomojo failo vieta. Numatytasis yra `/usr/sbin/sendmail`.
* `:arguments` - komandų eilutės argumentai. Numatytasis yra `%w[ -i ]`.

#### `config.action_mailer.raise_delivery_errors`

Nurodo, ar kiltų klaida, jei el. laiško pristatymas negali būti atliktas. Numatytasis yra `true`.

#### `config.action_mailer.delivery_method`

Apibrėžia pristatymo metodą ir numatytasis yra `:smtp`. Daugiau informacijos rasite [konfigūracijos skyriuje Action Mailer vadove](action_mailer_basics.html#action-mailer-configuration).

#### `config.action_mailer.perform_deliveries`

Nurodo, ar laiškas iš tikrųjų bus pristatomas ir numatytasis yra `true`. Gali būti patogu nustatyti jį kaip `false` testavimui.

#### `config.action_mailer.default_options`

Konfigūruoja Action Mailer numatytąsias reikšmes. Naudokite, norėdami nustatyti pasirinktis, pvz., `from` arba `reply_to`, visiems laiškų siuntėjams. Numatytasis yra:

```ruby
mime_version:  "1.0",
charset:       "UTF-8",
content_type: "text/plain",
parts_order:  ["text/plain", "text/enriched", "text/html"]
```

Priskirkite raktų rinkinį, norėdami nustatyti papildomas parinktis:

```ruby
config.action_mailer.default_options = {
  from: "noreply@example.com"
}
```

#### `config.action_mailer.observers`

Registruoja stebėtojus, kurie bus pranešti, kai laiškas bus pristatomas.

```ruby
config.action_mailer.observers = ["MailObserver"]
```

#### `config.action_mailer.interceptors`

Registruoja perceptorius, kurie bus iškviesti prieš siunčiant laišką.

```ruby
config.action_mailer.interceptors = ["MailInterceptor"]
```

#### `config.action_mailer.preview_interceptors`

Registruoja perceptorius, kurie bus iškviesti prieš peržiūrimą laišką.

```ruby
config.action_mailer.preview_interceptors = ["MyPreviewMailInterceptor"]
```

#### `config.action_mailer.preview_paths`

Nurodo laiškų peržiūros vietoves. Pridedant kelius prie šios konfigūracijos parinkties, šie keliai bus naudojami ieškant laiškų peržiūrų.

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

#### `config.action_mailer.show_previews`

Įjungia arba išjungia laiškų peržiūras. Numatytasis yra `true` vystyme.

```ruby
config.action_mailer.show_previews = false
```

#### `config.action_mailer.perform_caching`

Nurodo, ar laiškų šablonai turėtų atlikti fragmentų kešavimą ar ne. Jei nenurodyta, numatytasis bus `true`.

#### `config.action_mailer.deliver_later_queue_name`

Nurodo naudoti numatytąjį pristatymo darbo (žr. `config.action_mailer.delivery_job`) Active Job eilę. Kai ši parinktis nustatoma kaip `nil`, pristatymo darbai siunčiami į numatytąją Active Job eilę (žr. `config.active_job.default_queue_name`).

Siuntėjo klasės gali perrašyti tai, kad naudotų kitą eilę. Atkreipkite dėmesį, kad tai taikoma tik naudojant numatytąjį pristatymo darbą. Jei jūsų siuntėjas naudoja pasirinktinį darbą, bus naudojama jo eilė.
Įsitikinkite, kad jūsų aktyviojo darbo adapteris taip pat sukonfigūruotas apdoroti nurodytą eilę, kitaip pristatymo darbai gali būti tyliai ignoruojami.

Numatytoji vertė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji vertė yra |
| --------------------- | -------------------- |
| (originali)           | `:mailers`           |
| 6.1                   | `nil`                |

#### `config.action_mailer.delivery_job`

Nurodo pristatymo darbą pašte.

Numatytoji vertė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji vertė yra |
| --------------------- | -------------------- |
| (originali)           | `ActionMailer::MailDeliveryJob` |
| 6.0                   | `"ActionMailer::MailDeliveryJob"` |

### Aktyvaus palaikymo konfigūravimas

Aktyviame palaikyme yra keletas konfigūracijos parinkčių:

#### `config.active_support.bare`

Įjungia arba išjungia `active_support/all` įkėlimą paleidus „Rails“. Numatytoji vertė yra `nil`, kas reiškia, kad įkeliamas `active_support/all`.

#### `config.active_support.test_order`

Nustato testų atvejų vykdymo tvarką. Galimos reikšmės yra `:random` ir `:sorted`. Numatytoji vertė yra `:random`.

#### `config.active_support.escape_html_entities_in_json`

Įjungia arba išjungia HTML entitetų eskapavimą JSON serializacijoje. Numatytoji vertė yra `true`.

#### `config.active_support.use_standard_json_time_format`

Įjungia arba išjungia datos serializavimą į ISO 8601 formatą. Numatytoji vertė yra `true`.

#### `config.active_support.time_precision`

Nustato JSON koduotų laiko reikšmių tikslumą. Numatytoji vertė yra `3`.

#### `config.active_support.hash_digest_class`

Leidžia konfigūruoti maišos funkcijos klasę, kurią naudoti generuojant neskonfidencialius maišos rezultatus, pvz., ETag antraštėje.

Numatytoji vertė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji vertė yra |
| --------------------- | -------------------- |
| (originali)           | `OpenSSL::Digest::MD5` |
| 5.2                   | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.key_generator_hash_digest_class`

Leidžia konfigūruoti maišos funkcijos klasę, kurią naudoti išvesti paslaptis iš konfigūruoto paslapties pagrindo, pvz., šifruotoms slapukoms.

Numatytoji vertė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji vertė yra |
| --------------------- | -------------------- |
| (originali)           | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.use_authenticated_message_encryption`

Nurodo, ar naudoti AES-256-GCM autentifikuotą šifravimą kaip numatytąjį šifravimą pranešimams užuot naudojus AES-256-CBC.

Numatytoji vertė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji vertė yra |
| --------------------- | -------------------- |
| (originali)           | `false`              |
| 5.2                   | `true`               |

#### `config.active_support.message_serializer`

Nurodo numatytąjį serializatorių, naudojamą [`ActiveSupport::MessageEncryptor`][] ir [`ActiveSupport::MessageVerifier`][] egzemplioriams. Norint palengvinti migravimą tarp serializatorių, pateikti serializatoriai įtraukia atsarginį mechanizmą, skirtą palaikyti kelis deserializavimo formatus:

| Serializatorius | Serializuoti ir deserializuoti | Atsarginis deserializuoti |
| --------------- | ----------------------------- | ------------------------ |
| `:marshal`      | `Marshal`                     | `ActiveSupport::JSON`, `ActiveSupport::MessagePack` |
| `:json`         | `ActiveSupport::JSON`         | `ActiveSupport::MessagePack` |
| `:json_allow_marshal` | `ActiveSupport::JSON`      | `ActiveSupport::MessagePack`, `Marshal` |
| `:message_pack` | `ActiveSupport::MessagePack`   | `ActiveSupport::JSON` |
| `:message_pack_allow_marshal` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON`, `Marshal` |
ĮSPĖJIMAS: `Marshal` yra potencialus deserializacijos atakų vektorius atveju, kai pranešimo pasirašymo slaptas raktas buvo nutekintas. _Jei įmanoma, pasirinkite serializatorių, kuris nepalaiko `Marshal`._

INFORMACIJA: `:message_pack` ir `:message_pack_allow_marshal` serializatoriai palaiko tam tikrus Ruby tipo objektus, kuriuos JSON nepalaiko, pvz., `Symbol`. Jie taip pat gali suteikti geresnį našumą ir mažesnį pranešimo dydį. Tačiau jie reikalauja [`msgpack` gem](https://rubygems.org/gems/msgpack).

Kiekvienas iš aukščiau minėtų serializatorių išleis [`message_serializer_fallback.active_support`][] įvykio pranešimą, kai jie grįš prie alternatyvaus deserializacijos formato, leisdami jums stebėti, kaip dažnai tokie grįžimai įvyksta.

Alternatyviai, galite nurodyti bet kokį serializatorių objektą, kuris atsako į `dump` ir `load` metodus. Pavyzdžiui:

```ruby
config.active_job.message_serializer = YAML
```

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (originalus)          | `:marshal`              |
| 7.1                   | `:json_allow_marshal`   |


#### `config.active_support.use_message_serializer_for_metadata`

Kai `true`, įjungia našumo optimizaciją, kuri serializuoja pranešimo duomenis ir metaduomenis kartu. Tai keičia pranešimo formatą, todėl senesnės (< 7.1) Rails versijos negali skaityti šiuo būdu serializuotų pranešimų. Tačiau pranešimus, kurie naudoja senąjį formatą, vis tiek galima skaityti, nepriklausomai nuo to, ar ši optimizacija yra įjungta.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (originalus)          | `false`                |
| 7.1                   | `true`                 |

#### `config.active_support.cache_format_version`

Nurodo, kurį serializacijos formatą naudoti kešui. Galimos reikšmės yra `6.1`, `7.0` ir `7.1`.

`6.1`, `7.0` ir `7.1` formatuose visi naudoja `Marshal` kaip numatytąjį koduotoją, tačiau `7.0` naudoja efektyvesnį atstovavimą kešo įrašams, o `7.1` įtraukia papildomą optimizaciją tuščioms eilutėms, tokoms kaip rodinio fragmentai.

Visi formatai yra suderinami atgal ir į priekį, tai reiškia, kad kešo įrašai, įrašyti viename formate, gali būti skaityti naudojant kitą formatą. Šis elgesys palengvina migraciją tarp formatų, nes nereikia invaliduoti viso kešo.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (originalus)          | `6.1`                  |
| 7.0                   | `7.0`                  |
| 7.1                   | `7.1`                  |

#### `config.active_support.deprecation`

Konfigūruoja pasenusių pranešimų elgesį. Galimos parinktys yra `:raise`, `:stderr`, `:log`, `:notify` ir `:silence`.

Numatytasis sugeneruotų `config/environments` failų nustatymas yra `:log` vystymui ir `:stderr` testavimui, o produkcinėje aplinkoje jis yra praleistas naudai [`config.active_support.report_deprecations`](#config-active-support-report-deprecations).
#### `config.active_support.disallowed_deprecation`

Konfigūruoja nepageidaujamų pasenusių pranešimų elgesį. Galimi variantai yra `:raise`, `:stderr`, `:log`, `:notify` ir `:silence`.

Numatytieji sugeneruoti `config/environments` failai nustato `:raise` tiek vystymui, tiek testavimui, o produkcijai jis yra praleidžiamas naudai [`config.active_support.report_deprecations`](#config-active-support-report-deprecations).

#### `config.active_support.disallowed_deprecation_warnings`

Konfigūruoja pasenusius pranešimus, kuriuos programa laiko nepageidaujamais. Tai leidžia, pavyzdžiui, tam tikriems pasenusiems pranešimams būti traktuojami kaip griežti nesėkmės.

#### `config.active_support.report_deprecations`

Kai `false`, išjungia visus pasenusius pranešimus, įskaitant nepageidaujamus pasenusius pranešimus, iš [programos pasenusių pranešimų](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators). Tai apima visus pasenusius pranešimus iš „Rails“ ir kitų juvelyrinių akmenų, kurie gali pridėti savo pasenusių pranešimų rinkinį, bet gali neleisti visiems pasenusiems pranešimams, išskleistam iš `ActiveSupport::Deprecation`.

Numatytieji sugeneruoti `config/environments` failai nustato `false` produkcijai.

#### `config.active_support.isolation_level`

Konfigūruoja daugumos „Rails“ vidinės būsenos vietovę. Jei naudojate pluošto pagrindo serverį arba darbo procesorių (pvz., `falcon`), turėtumėte nustatyti jį kaip `:fiber`. Kitu atveju geriausia naudoti `:thread` vietovę. Numatytasis yra `:thread`.

#### `config.active_support.executor_around_test_case`

Konfigūruoja testų rinkinį, kad jis kvietė `Rails.application.executor.wrap` aplink testo atvejus.
Tai leidžia testo atvejams elgtis panašiau į tikrą užklausą ar darbą.
Kai kurios funkcijos, kurios įprastai yra išjungtos teste, pvz., „Active Record“ užklausų talpykla
ir asinchroninės užklausos, tada bus įjungtos.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis yra |
| --------------------- | -------------------- |
| (originalus)            | `false`              |
| 7.0                   | `true`               |

#### `ActiveSupport::Logger.silencer`

Nustatoma kaip `false`, kad būtų išjungta galimybė nutildyti žurnalavimą bloke. Numatytasis yra `true`.

#### `ActiveSupport::Cache::Store.logger`

Nurodo žurnalą, kurį naudoti talpyklos operacijose.

#### `ActiveSupport.to_time_preserves_timezone`

Nurodo, ar `to_time` metodai išlaiko savo gavėjų UTC poslinkį. Jei `false`, `to_time` metodai konvertuos į vietinės sistemos UTC poslinkį.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis yra |
| --------------------- | -------------------- |
| (originalus)            | `false`              |
| 5.0                   | `true`               |

#### `ActiveSupport.utc_to_local_returns_utc_offset_times`

Konfigūruoja `ActiveSupport::TimeZone.utc_to_local` grąžinti laiką su UTC
poslinkiu, o ne UTC laiką, įtraukiantį tą poslinkį.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis yra |
| --------------------- | -------------------- |
| (originalus)            | `false`              |
| 6.1                   | `true`               |

#### `config.active_support.raise_on_invalid_cache_expiration_time`

Nurodo, ar turėtų būti iškeltas `ArgumentError`, jei `Rails.cache` `fetch` arba
`write` gauna netinkamą `expires_at` arba `expires_in` laiką.
Galimi variantai yra `true` ir `false`. Jei `false`, išimtis bus pranešta kaip `aptarnauta` ir užregistruota.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (pradinis)            | `false`                |
| 7.1                   | `true`                 |

### Konfigūruojant aktyvią darbą

`config.active_job` suteikia šias konfigūracijos galimybes:

#### `config.active_job.queue_adapter`

Nustato eilės pagrindo adapterį. Numatytasis adapteris yra `:async`. Norint gauti naujausią įdiegtų adapterių sąrašą, žr. [ActiveJob::QueueAdapters API dokumentaciją](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html).

```ruby
# Įsitikinkite, kad adapterio juostelė yra jūsų Gemfile
# ir sekite adapterio konkretaus diegimo
# ir diegimo instrukcijas.
config.active_job.queue_adapter = :sidekiq
```

#### `config.active_job.default_queue_name`

Gali būti naudojamas norint pakeisti numatytąją eilės pavadinimą. Numatytasis pavadinimas yra `"default"`.

```ruby
config.active_job.default_queue_name = :medium_priority
```

#### `config.active_job.queue_name_prefix`

Leidžia nustatyti pasirinktinį, ne tuščią, eilės pavadinimo priešdėlį visiems darbams. Numatytasis yra tuščias ir nenaudojamas.

Ši konfigūracija užduotų duotą darbą eilėje `production_high_priority`, kai vykdoma gamyba:

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

Turi numatytąją reikšmę `'_'`. Jei nustatytas `queue_name_prefix`, tada `queue_name_delimiter` sujungia priešdėlį ir nepriešdėlinį eilės pavadinimą.

Ši konfigūracija užduotų duotą darbą eilėje `video_server.low_priority`:

```ruby
# priešdėlis turi būti nustatytas, kad būtų naudojamas skirtukas
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

Priima žurnalizatorių, atitinkantį Log4r sąsają arba numatytąjį Ruby žurnalizatoriaus klasę, kuris tada naudojamas žurnalizuoti informaciją iš aktyvaus darbo. Šį žurnalizatorių galite gauti iškviesdami `logger` tiek iš aktyvaus darbo klasės, tiek iš aktyvaus darbo pavyzdžio. Nustatykite į `nil`, jei norite išjungti žurnalizavimą.

#### `config.active_job.custom_serializers`

Leidžia nustatyti pasirinktinius argumentų serializatorius. Numatytasis yra `[]`.

#### `config.active_job.log_arguments`

Valdo, ar darbo argumentai yra žurnalizuojami. Numatytasis yra `true`.

#### `config.active_job.verbose_enqueue_logs`

Nurodo, ar turėtų būti žurnalizuojami foninio darbo užduoties įtraukimo logų eilutėse esančių metodų šaltinių vietos. Numatytasis yra `true` vystymoje ir `false` visose kitose aplinkose.

#### `config.active_job.retry_jitter`

Valdo "jitter" (atsitiktinės variacijos) kiekį, taikomą vėl bandant vykdyti nepavykusias užduotis.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | ---------------------- |
| (pradinis)            | `0.0`                  |
| 6.1                   | `0.15`                 |
#### `config.active_job.log_query_tags_around_perform`

Nustato, ar užklausos žymės darbo kontekstas automatiškai bus atnaujinamas per `around_perform`. Numatytasis reikšmė yra `true`.

#### `config.active_job.use_big_decimal_serializer`

Įgalina naują `BigDecimal` argumento serializatorių, kuris garantuoja apvalinimą. Be šio serializatoriaus, kai kurie eilės adapteriai gali serializuoti `BigDecimal` argumentus kaip paprastus (neapvalinamus) tekstus.

ĮSPĖJIMAS: Paleidžiant programą su keliais replikais, seni (ne-Rails 7.1) replikai negalės deserializuoti `BigDecimal` argumentų iš šio serializatoriaus. Todėl šis nustatymas turėtų būti įjungtas tik po to, kai visi replikai sėkmingai atnaujinti iki Rails 7.1.

Numatytosios reikšmės priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytosios reikšmės yra |
| --------------------- | ------------------------ |
| (pradinis)            | `false`                  |
| 7.1                   | `true`                   |

### Action Cable konfigūravimas

#### `config.action_cable.url`

Priima eilutę URL, kurioje talpinamas jūsų Action Cable serveris. Šią parinktį naudotumėte, jei paleidžiate Action Cable serverius, kurie yra atskirti nuo pagrindinės jūsų programos.

#### `config.action_cable.mount_path`

Priima eilutę, kur montuoti Action Cable, kaip pagrindinio serverio proceso dalį. Numatytoji reikšmė yra `/cable`. Galite nustatyti tai kaip `nil`, jei nenorite montuoti Action Cable kaip įprastą Rails serverį.

Išsamesnę konfigūracijos parinkčių informaciją rasite [Action Cable apžvalgoje](action_cable_overview.html#configuration).

#### `config.action_cable.precompile_assets`

Nustato, ar Action Cable turinys turėtų būti pridėtas prie turinio kompiliavimo. Tai neturi jokio poveikio, jei nenaudojamas Sprockets. Numatytosios reikšmės yra `true`.

### Active Storage konfigūravimas

`config.active_storage` teikia šias konfigūracijos parinktis:

#### `config.active_storage.variant_processor`

Priima simbolį `:mini_magick` arba `:vips`, nurodydamas, ar varianto transformacijos ir blob analizė bus atliekamos su MiniMagick arba ruby-vips.

Numatytosios reikšmės priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytosios reikšmės yra |
| --------------------- | ------------------------ |
| (pradinis)            | `:mini_magick`           |
| 7.0                   | `:vips`                  |

#### `config.active_storage.analyzers`

Priima klasės masyvą, nurodantį galimus analizatorius Active Storage blobams. Numatytosios reikšmės yra:

```ruby
config.active_storage.analyzers = [ActiveStorage::Analyzer::ImageAnalyzer::Vips, ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick, ActiveStorage::Analyzer::VideoAnalyzer, ActiveStorage::Analyzer::AudioAnalyzer]
```

Vaizdo analizatoriai gali išgauti vaizdo blobo plotį ir aukštį; vaizdo analizatorius gali išgauti vaizdo blobo plotį, aukštį, trukmę, kampą, kraštinių santykį ir vaizdo/garsų kanalų buvimą/ar nebuvimą; garso analizatorius gali išgauti garso blobo trukmę ir bitų greitį.

#### `config.active_storage.previewers`

Priima klasės masyvą, nurodantį galimus vaizdo peržiūros įrankius Active Storage blobams. Numatytosios reikšmės yra:
```ruby
config.active_storage.previewers = [ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer]
```

`PopplerPDFPreviewer` ir `MuPDFPreviewer` gali generuoti miniatiūrą iš PDF blob pirmosios puslapio; `VideoPreviewer` - iš atitinkamo kadro iš vaizdo blob.

#### `config.active_storage.paths`

Priima hash parinkčių, nurodančių peržiūros/analizės komandų vietas. Numatytasis yra `{}`, tai reiškia, kad komandos bus ieškomos numatytame kelyje. Galima įtraukti šias parinktis:

* `:ffprobe` - ffprobe vykdomojo failo vieta.
* `:mutool` - mutool vykdomojo failo vieta.
* `:ffmpeg` - ffmpeg vykdomojo failo vieta.

```ruby
config.active_storage.paths[:ffprobe] = '/usr/local/bin/ffprobe'
```

#### `config.active_storage.variable_content_types`

Priima eilučių masyvą, nurodantį turinio tipus, kuriuos Active Storage gali transformuoti per variantų procesorių.
Numatytasis yra apibrėžtas taip:

```ruby
config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/bmp image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)
```

#### `config.active_storage.web_image_content_types`

Priima eilučių masyvą, laikomą tinklo vaizdo turinio tipais, kuriuose variantai gali būti apdorojami be konvertavimo į atsarginį PNG formatą.
Jei norite naudoti `WebP` ar `AVIF` variantus savo programoje, galite pridėti `image/webp` ar `image/avif` į šį masyvą.
Numatytasis yra apibrėžtas taip:

```ruby
config.active_storage.web_image_content_types = %w(image/png image/jpeg image/gif)
```

#### `config.active_storage.content_types_to_serve_as_binary`

Priima eilučių masyvą, nurodantį turinio tipus, kuriuos Active Storage visada teiks kaip priedą, o ne įterptinį.
Numatytasis yra apibrėžtas taip:

```ruby
config.active_storage.content_types_to_serve_as_binary = %w(text/html image/svg+xml application/postscript application/x-shockwave-flash text/xml application/xml application/xhtml+xml application/mathml+xml text/cache-manifest)
```

#### `config.active_storage.content_types_allowed_inline`

Priima eilučių masyvą, nurodantį turinio tipus, kuriuos Active Storage leidžia teikti kaip įterptinius.
Numatytasis yra apibrėžtas taip:

```ruby
config.active_storage.content_types_allowed_inline` = %w(image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon application/pdf)
```

#### `config.active_storage.queues.analysis`

Priima simbolį, nurodantį naudoti Active Job eilę analizės darbams. Kai ši parinktis yra `nil`, analizės darbai siunčiami į numatytąją Active Job eilę (žr. `config.active_job.default_queue_name`).

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | -------------------- |
| 6.0                   | `:active_storage_analysis` |
| 6.1                   | `nil`                |

#### `config.active_storage.queues.purge`

Priima simbolį, nurodantį naudoti Active Job eilę šalinimo darbams. Kai ši parinktis yra `nil`, šalinimo darbai siunčiami į numatytąją Active Job eilę (žr. `config.active_job.default_queue_name`).

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | -------------------- |
| 6.0                   | `:active_storage_purge` |
| 6.1                   | `nil`                |
#### `config.active_storage.queues.mirror`

Priima simbolį, nurodantį naudoti Active Job eilę tiesioginiam įkėlimo kopijavimo darbams. Kai ši parinktis yra `nil`, kopijavimo darbai siunčiami į numatytąją Active Job eilę (žr. `config.active_job.default_queue_name`). Numatytasis yra `nil`.

#### `config.active_storage.logger`

Gali būti naudojamas nustatyti Active Storage naudojamą žurnalą. Priima žurnalą, atitinkantį Log4r sąsają arba numatytąjį Ruby Logger klasę.

```ruby
config.active_storage.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.active_storage.service_urls_expire_in`

Nustato numatytąją URL, kurie generuojami naudojant:

* `ActiveStorage::Blob#url`
* `ActiveStorage::Blob#service_url_for_direct_upload`
* `ActiveStorage::Variant#url`

Numatytasis yra 5 minutės.

#### `config.active_storage.urls_expire_in`

Nustato numatytąją URL galiojimo laiką, kuris generuojamas Rails aplikacijoje naudojant Active Storage. Numatytasis yra `nil`.

#### `config.active_storage.routes_prefix`

Gali būti naudojamas nustatyti maršruto priešdėlį, kuris bus pridėtas prie generuojamų maršrutų. Priima eilutę, kuri bus pridėta prie generuojamų maršrutų.

```ruby
config.active_storage.routes_prefix = '/files'
```

Numatytasis yra `/rails/active_storage`.

#### `config.active_storage.track_variants`

Nustato, ar variantai yra įrašomi į duomenų bazę.

Numatytasis reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | -------------------- |
| (pradinis)            | `false`              |
| 6.1                   | `true`               |

#### `config.active_storage.draw_routes`

Gali būti naudojamas perjungti Active Storage maršrutų generavimą. Numatytasis yra `true`.

#### `config.active_storage.resolve_model_to_route`

Gali būti naudojamas visuotinai pakeisti, kaip Active Storage failai yra pristatomi.

Leidžiamos reikšmės yra:

* `:rails_storage_redirect`: Nukreipia į pasirašytus, trumpam galiojančius paslaugos URL.
* `:rails_storage_proxy`: Perleidžia failus, juos atsisiunčiant.

Numatytasis yra `:rails_storage_redirect`.

#### `config.active_storage.video_preview_arguments`

Gali būti naudojamas pakeisti būdą, kaip ffmpeg generuoja vaizdo peržiūros vaizdus.

Numatytosios reikšmės priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytasis reikšmė yra |
| --------------------- | -------------------- |
| (pradinis)            | `"-y -vframes 1 -f image2"` |
| 7.0                   | `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015)"`<sup><mark><strong><em>1</em></strong></mark></sup> <br> `+ ",loop=loop=-1:size=2,trim=start_frame=1'"`<sup><mark><strong><em>2</em></strong></mark></sup><br> `+ " -frames:v 1 -f image2"` <br><br> <ol><li>Pasirenka pirmą vaizdo kadrą, taip pat raktinius kadrus ir kadrus, kurie atitinka scenos pokyčio slenkstį.</li> <li>Naudokite pirmą vaizdo kadrą kaip atsarginę, kai nėra kitų kadro, atitinkančių kriterijus, pasirinkdami pirmą (vieną arba) du pasirinktus kadrus, tada išmetant pirmą kartotinai pasikartojantį kadro.</li></ol> |

#### `config.active_storage.multiple_file_field_include_hidden`

Nuo Rails 7.1 ir vėlesnių versijų, Active Storage `has_many_attached` ryšiai pagal numatymą pakeis esamą kolekciją, o ne pridės prie jos. Taigi, norint palaikyti pateikti _tuščią_ kolekciją, kai `multiple_file_field_include_hidden` yra `true`, [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) pagalbinės funkcijos pagalba bus sugeneruotas paslėptas laukas, panašus į [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) pagalbinį lauką.
Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | -------------------- |
| (pradinė)             | `false`              |
| 7.0                   | `true`               |

#### `config.active_storage.precompile_assets`

Nustato, ar Active Storage turinio turtai turėtų būti pridėti prie turinio turtų kompiliavimo. Tai neturi jokio poveikio, jei nenaudojamas Sprockets. Numatytoji reikšmė yra `true`.

### Action Text konfigūravimas

#### `config.action_text.attachment_tag_name`

Priima eilutę HTML žymės, kuri naudojama apgaubti priedus. Numatytoji reikšmė yra `"action-text-attachment"`.

#### `config.action_text.sanitizer_vendor`

Konfigūruoja HTML sanitarą, kurį naudoja Action Text, nustatant `ActionText::ContentHelper.sanitizer` į klasės, grąžintos iš tiekėjo `.safe_list_sanitizer` metodo, egzempliorių. Numatytoji reikšmė priklauso nuo `config.load_defaults` tikslinės versijos:

| Pradedant nuo versijos | Numatytoji reikšmė yra                 | Kuri analizuoja žymėjimą kaip |
|-----------------------|--------------------------------------|------------------------|
| (pradinė)             | `Rails::HTML4::Sanitizer`            | HTML4                  |
| 7.1                   | `Rails::HTML5::Sanitizer` (žr. PASTABA) | HTML5                  |

PASTABA: `Rails::HTML5::Sanitizer` nepalaikomas JRuby, todėl JRuby platformose Rails naudos `Rails::HTML4::Sanitizer`.

### Duomenų bazės konfigūravimas

Beveik kiekviena Rails programa sąveikauja su duomenų baze. Galite prisijungti prie duomenų bazės nustatydami aplinkos kintamąjį `ENV['DATABASE_URL']` arba naudodami konfigūracinį failą, vadinamą `config/database.yml`.

Naudodami `config/database.yml` failą, galite nurodyti visą informaciją, reikalingą prisijungti prie duomenų bazės:

```yaml
development:
  adapter: postgresql
  database: blog_development
  pool: 5
```

Tai prisijungs prie duomenų bazės, pavadinimu `blog_development`, naudojant `postgresql` adapterį. Šią pačią informaciją galima saugoti URL formatu ir perduoti per aplinkos kintamąjį taip:

```ruby
ENV['DATABASE_URL'] # => "postgresql://localhost/blog_development?pool=5"
```

`config/database.yml` failas pagal numatytuosius nustatymus turi skirsnius trim skirtingoms aplinkoms, kuriose gali veikti Rails:

* `development` aplinka naudojama jūsų vystymo/vietiniam kompiuteriui, kai sąveikaujate su programa rankiniu būdu.
* `test` aplinka naudojama vykdant automatizuotus testus.
* `production` aplinka naudojama, kai diegiate savo programą, kad ją naudotų visuomenė.

Jei norite, galite rankiniu būdu nurodyti URL savo `config/database.yml` faile:

```yaml
development:
  url: postgresql://localhost/blog_development?pool=5
```

`config/database.yml` faile gali būti naudojami ERB žymės `<%= %>`. Visa, kas yra žymėse, bus įvertinta kaip Ruby kodas. Galite tai naudoti, kad ištrauktumėte duomenis iš aplinkos kintamojo arba atliktumėte skaičiavimus, kad generuotumėte reikiamą prisijungimo informaciją.


PATARIMAS: Jums nereikia rankiniu būdu atnaujinti duomenų bazės konfigūracijos. Jei pažvelgsite į aplikacijos generatoriaus parinktis, pamatysite, kad viena iš parinkčių yra vadinama `--database`. Ši parinktis leidžia jums pasirinkti adapterį iš dažniausiai naudojamų reliacinės duomenų bazės sąrašo. Netgi galite paleisti generatorių pakartotinai: `cd .. && rails new blog --database=mysql`. Patvirtinus `config/database.yml` failo perrašymą, jūsų programa bus sukonfigūruota naudoti MySQL vietoj SQLite. Išsamūs pavyzdžiai bendrų duomenų bazės prisijungimų yra žemiau.
### Ryšio nustatymo prioritetas

Kadangi yra du būdai konfigūruoti ryšį (naudojant `config/database.yml` arba naudojant aplinkos kintamąjį), svarbu suprasti, kaip jie gali sąveikauti.

Jei `config/database.yml` failas yra tuščias, bet yra nustatytas `ENV['DATABASE_URL']`, tuomet „Rails“ prisijungs prie duomenų bazės per jūsų aplinkos kintamąjį:

```bash
$ cat config/database.yml

$ echo $DATABASE_URL
postgresql://localhost/my_database
```

Jei yra `config/database.yml`, bet nėra `ENV['DATABASE_URL']`, tuomet šis failas bus naudojamas prisijungti prie jūsų duomenų bazės:

```bash
$ cat config/database.yml
development:
  adapter: postgresql
  database: my_database
  host: localhost

$ echo $DATABASE_URL
```

Jei yra tiek `config/database.yml`, tiek `ENV['DATABASE_URL']`, „Rails“ sujungs konfigūraciją kartu. Norėdami tai geriau suprasti, turime pamatyti keletą pavyzdžių.

Kai pateikiama dublikuota prisijungimo informacija, aplinkos kintamasis turės pirmenybę:

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

Čia adapteris, serveris ir duomenų bazė atitinka informaciją `ENV['DATABASE_URL']`.

Jei pateikiama nesidubliuojanti informacija, gausite visus unikalius reikšmes, tačiau aplinkos kintamasis vis tiek turės pirmenybę konfliktų atveju.

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

Kadangi baseinas nėra `ENV['DATABASE_URL']` pateikto prisijungimo informacijoje, jo informacija yra sujungta. Kadangi adapteris yra dublikatas, laimi prisijungimo informacija iš `ENV['DATABASE_URL']`.

Vienintelis būdas išreikšti nenorą naudoti prisijungimo informaciją `ENV['DATABASE_URL']` yra nurodyti aiškų URL prisijungimą naudojant „url“ požymį:

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

Čia prisijungimo informacija `ENV['DATABASE_URL']` yra ignoruojama, pastebėkite skirtingą adapterį ir duomenų bazės pavadinimą.

Kadangi į `config/database.yml` galima įterpti ERB, geriausia praktika aiškiai parodyti, kad naudojate `ENV['DATABASE_URL']` prisijungti prie savo duomenų bazės. Tai ypač naudinga gamyboje, nes negalima įtraukti slaptų duomenų, pvz., duomenų bazės slaptažodžio, į šaltinio kontrolę (pvz., „Git“).

```bash
$ cat config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

Dabar elgesys yra aiškus, kad naudojame tik prisijungimo informaciją `ENV['DATABASE_URL']`.
#### SQLite3 duomenų bazės konfigūravimas

Rails turi įdiegtą palaikymą [SQLite3](http://www.sqlite.org), tai yra lengva, be serverio duomenų bazės programa. Nors užimtas gamybos aplinkas gali perkrauti SQLite, ji gerai veikia vystymui ir testavimui. Rails pagal nutylėjimą naudoja SQLite duomenų bazę kuriant naują projektą, tačiau ją visada galite pakeisti vėliau.

Čia yra numatytos konfigūracijos failo (`config/database.yml`) dalis su prisijungimo informacija vystymo aplinkai:

```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

PASTABA: Rails pagal nutylėjimą naudoja SQLite3 duomenų bazę duomenų saugojimui, nes tai yra nulėmimo konfigūracijos duomenų bazė, kuri tiesiog veikia. Rails taip pat palaiko MySQL (įskaitant MariaDB) ir PostgreSQL "iš pakuotės" ir turi įskiepius daugeliui duomenų bazės sistemų. Jei naudojate duomenų bazę gamybos aplinkoje, Rails tikriausiai turi adapterį tam.

#### MySQL arba MariaDB duomenų bazės konfigūravimas

Jei pasirenkate naudoti MySQL arba MariaDB vietoj pristatytos SQLite3 duomenų bazės, jūsų `config/database.yml` failas atrodys šiek tiek kitaip. Čia yra vystymo aplinkos dalis:

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

Jei jūsų vystymo duomenų bazėje yra root naudotojas su tuščiu slaptažodžiu, ši konfigūracija turėtų veikti jums. Kitu atveju, pakeiskite vartotojo vardą ir slaptažodį `development` dalyje pagal poreikį.

PASTABA: Jei jūsų MySQL versija yra 5.5 arba 5.6 ir norite naudoti `utf8mb4` simbolių rinkinį pagal nutylėjimą, prašome sukonfigūruoti savo MySQL serverį, kad palaikytų ilgesnį rakto prefiksą, įjungiant `innodb_large_prefix` sistemos kintamąjį.

Patarimai užrakinimai pagal nutylėjimą yra įjungti MySQL ir naudojami, kad duomenų bazės migracijos būtų saugios. Galite išjungti patarimus užrakinti nustatydami `advisory_locks` į `false`:

```yaml
production:
  adapter: mysql2
  advisory_locks: false
```

#### PostgreSQL duomenų bazės konfigūravimas

Jei pasirenkate naudoti PostgreSQL, jūsų `config/database.yml` bus pritaikytas naudoti PostgreSQL duomenų bazes:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: blog_development
  pool: 5
```

Pagal nutylėjimą Active Record naudoja duomenų bazės funkcijas, pvz., paruoštus teiginius ir patarimus užrakinti. Jei naudojate išorinį prisijungimo valdiklį, pvz., PgBouncer, gali prireikti išjungti šias funkcijas:

```yaml
production:
  adapter: postgresql
  prepared_statements: false
  advisory_locks: false
```

Jei įjungta, Active Record pagal nutylėjimą sukuria iki `1000` paruoštų teiginių vienam duomenų bazės prisijungimui. Norėdami pakeisti šį elgesį, galite nustatyti `statement_limit` į kitą reikšmę:

```yaml
production:
  adapter: postgresql
  statement_limit: 200
```

Kuo daugiau paruoštų teiginių naudojama: tuo daugiau atminties reikės jūsų duomenų bazei. Jei jūsų PostgreSQL duomenų bazė pasiekia atminties ribas, bandykite sumažinti `statement_limit` arba išjungti paruoštus teiginius.
#### SQLite3 duomenų bazės konfigūravimas JRuby platformai

Jei pasirenkate naudoti SQLite3 ir naudojate JRuby, jūsų `config/database.yml` failas atrodys šiek tiek kitaip. Čia yra vystymosi skyrius:

```yaml
development:
  adapter: jdbcsqlite3
  database: storage/development.sqlite3
```

#### MySQL arba MariaDB duomenų bazės konfigūravimas JRuby platformai

Jei pasirenkate naudoti MySQL arba MariaDB ir naudojate JRuby, jūsų `config/database.yml` failas atrodys šiek tiek kitaip. Čia yra vystymosi skyrius:

```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```

#### PostgreSQL duomenų bazės konfigūravimas JRuby platformai

Jei pasirenkate naudoti PostgreSQL ir naudojate JRuby, jūsų `config/database.yml` failas atrodys šiek tiek kitaip. Čia yra vystymosi skyrius:

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

Pakeiskite `development` skyriuje esantį naudotojo vardą ir slaptažodį pagal poreikį.

#### Metaduomenų saugojimo konfigūravimas

Pagal numatytuosius nustatymus Rails saugos informaciją apie jūsų Rails aplinką ir schemą
vidinėje lentelėje, pavadinimu `ar_internal_metadata`.

Norėdami tai išjungti per ryšį, nustatykite `use_metadata_table` savo duomenų bazės
konfigūracijoje. Tai naudinga, kai dirbate su bendra duomenų baze ir/arba
duomenų bazės vartotoju, kuris negali kurti lentelių.

```yaml
development:
  adapter: postgresql
  use_metadata_table: false
```

#### Bandyti iš naujo konfigūravimas

Pagal numatytuosius nustatymus, Rails automatiškai prisijungs prie duomenų bazės serverio ir bandys iš naujo vykdyti tam tikrus užklausas,
jei kažkas nutiks negerai. Bandyti iš naujo bus tik saugios (idempotent) užklausos. Bandyti iš naujo galima nurodyti duomenų bazės konfigūracijoje per `connection_retries` arba išjungti
nustatant reikšmę į 0. Numatytasis bandymų skaičius yra 1.

```yaml
development:
  adapter: mysql2
  connection_retries: 3
```

Duomenų bazės konfigūracija taip pat leidžia konfigūruoti `retry_deadline`. Jei yra konfigūruota `retry_deadline`,
užklausa, kurią kitaip galima būtų bandyti iš naujo, nebus bandyta iš naujo, jei nurodytas laikas praėjo nuo pirmojo užklausos bandymo.
Pavyzdžiui, `retry_deadline` 5 sekundės reiškia, kad jei praėjo 5 sekundės nuo užklausos pirmojo bandymo, mes nebandysime iš naujo užklausos, net jei ji yra idempotentinė ir yra likę `connection_retries`.

Ši reikšmė pagal numatytuosius nustatymus yra `nil`, tai reiškia, kad visos bandymo vertos užklausos bus bandytos iš naujo, nepriklausomai nuo praėjusio laiko.
Šios konfigūracijos reikšmė turėtų būti nurodyta sekundėmis.

```yaml
development:
  adapter: mysql2
  retry_deadline: 5 # Nebandyti iš naujo užklausų po 5 sekundžių
```

#### Užklausų talpyklos konfigūravimas

Pagal numatytuosius nustatymus, Rails automatiškai talpina užklausų grąžinamus rezultatų rinkinius. Jei Rails vėl susiduria su ta pačia užklausa
toje pačioje užklausos ar darbo metu, jis naudos talpinamą rezultatų rinkinį, o ne vykdys užklausos iš naujo prieš
duomenų bazę.
Užklausų talpykla saugoma atmintyje, ir norint išvengti per didelio atminties naudojimo, ji automatiškai pašalina mažiausiai naudojamas užklausas, pasiekus slenkstį. Pagal numatytuosius nustatymus slenkstis yra `100`, bet jis gali būti konfigūruojamas `database.yml` faile.

```yaml
development:
  adapter: mysql2
  query_cache: 200
```

Norint visiškai išjungti užklausų talpyklą, ją galima nustatyti kaip `false`

```yaml
development:
  adapter: mysql2
  query_cache: false
```

### Kūrimo aplinkos kūrimas

Pagal numatytuosius nustatymus, Rails turi tris aplinkas: "development", "test" ir "production". Nors tai pakanka daugumai atvejų, yra situacijų, kai jums reikia daugiau aplinkų.

Įsivaizduokite, kad turite serverį, kuris atitinka gamybos aplinką, bet naudojamas tik testavimui. Tokį serverį paprastai vadiname "staging serveriu". Norėdami apibrėžti "staging" aplinką šiam serveriui, tiesiog sukurkite failą `config/environments/staging.rb`. Kadangi tai yra panaši į gamybos aplinką, galite nukopijuoti `config/environments/production.rb` turinį kaip pradžios tašką ir atlikti reikiamus pakeitimus. Taip pat galima reikalauti ir išplėsti kitas aplinkos konfigūracijas taip:

```ruby
# config/environments/staging.rb
require_relative "production"

Rails.application.configure do
  # Staging overrides
end
```

Ši aplinka nesiskiria nuo numatytųjų, galite paleisti serverį su `bin/rails server -e staging`, konsolę su `bin/rails console -e staging`, `Rails.env.staging?` veikia ir t.t.

### Diegimas į subdirektoriją (nuorodos URL šaknies atžvilgiu)

Pagal numatytuosius nustatymus, Rails tikisi, kad jūsų programa veiks šakniniame kataloge (pvz., `/`). Šiame skyriuje paaiškinama, kaip paleisti programą kataloge.

Tarkime, norime diegti programą į "/app1". Rails turi žinoti šį katalogą, kad galėtų generuoti tinkamus maršrutus:

```ruby
config.relative_url_root = "/app1"
```

alternatyviai galite nustatyti `RAILS_RELATIVE_URL_ROOT` aplinkos kintamąjį.

Dabar Rails pridės "/app1" prie generuojamų nuorodų.

#### Naudojant Passenger

Passenger leidžia lengvai paleisti programą subdirektorijoje. Reikiamą konfigūraciją galite rasti [Passenger vadove](https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/#deploying-an-app-to-a-sub-uri-or-subdirectory).

#### Naudojant atvirkštinį tarpininką

Programos diegimas naudojant atvirkštinį tarpininką turi tam tikrų privalumų palyginti su tradiciniais diegimais. Jie leidžia jums turėti daugiau kontrolės per serverio komponentus, reikalingus jūsų programai.

Daugelis šiuolaikinių interneto serverių gali būti naudojami kaip tarpininko serveriai, skirti balansuoti trečiųjų šalių elementus, tokius kaip talpyklos serveriai arba programų serveriai.

Vienas iš tokių programų serverių, kuriuos galite naudoti, yra [Unicorn](https://bogomips.org/unicorn/), kad veiktų už atvirkštinio tarpininko.

Šiuo atveju turėtumėte sukonfigūruoti tarpininko serverį (NGINX, Apache ir t.t.), kad jis priimtų ryšius iš jūsų programos serverio (Unicorn). Pagal numatytuosius nustatymus Unicorn klausysis TCP ryšių 8080 prievade, bet galite pakeisti prievadą arba sukonfigūruoti jį naudoti lizdus.
Daugiau informacijos galite rasti [Unicorn readme](https://bogomips.org/unicorn/README.html) ir suprasti [filosofiją](https://bogomips.org/unicorn/PHILOSOPHY.html), kuri ją palaiko.

Kai jūs sukonfigūruosite taikomosios programos serverį, turite nukreipti užklausas į jį, tinkamai sukonfigūravę savo interneto serverį. Pavyzdžiui, jūsų NGINX konfigūracija gali apimti:

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

Būkite tikri, kad perskaitėte [NGINX dokumentaciją](https://nginx.org/en/docs/) su naujausia informacija.


Rails aplinkos nustatymai
--------------------------

Kai kurios Rails dalys taip pat gali būti konfigūruojamos išorėje, pateikiant aplinkos kintamuosius. Įvairios Rails dalys pripažįsta šiuos aplinkos kintamuosius:

* `ENV["RAILS_ENV"]` apibrėžia Rails aplinką (produkcija, vystymas, testavimas ir t.t.), kurioje veiks Rails.

* `ENV["RAILS_RELATIVE_URL_ROOT"]` naudojamas maršrutizavimo kode, kad būtų galima atpažinti URL, kai [diegiate savo taikomąją programą į subkatalogą](configuring.html#deploy-to-a-subdirectory-relative-url-root).

* `ENV["RAILS_CACHE_ID"]` ir `ENV["RAILS_APP_VERSION"]` naudojami generuojant išplėstus Rails kešavimo kodus. Tai leidžia turėti kelis atskirus kešus iš tos pačios programos.


Naudodami inicializavimo failus
-----------------------

Po karkaso ir jūsų taikomojoje programoje naudojamų juvelyrinių akmenų įkėlimo, Rails kreipiasi į inicializavimo failus. Inicializavimo failas yra bet koks Ruby failas, saugomas jūsų taikomosios programos `config/initializers` aplanke. Inicializavimo failuose galite naudoti konfigūracijos nustatymus, kurie turėtų būti atlikti po visų karkasų ir juvelyrinių akmenų įkėlimo, pvz., nustatymų konfigūravimo galimybėms.

Failai `config/initializers` (ir bet kokie `config/initializers` poaplankiai) yra rūšiuojami ir įkeliami vienas po kito kaip dalis `load_config_initializers` inicializatoriaus.

Jei inicializavimo faile yra kodas, kuris priklauso nuo kito inicializavimo faile esančio kodo, galite juos sujungti į vieną inicializavimo failą. Tai padaro priklausomybes aiškesnes ir gali padėti atskleisti naujus sąvokas jūsų taikomojoje programoje. Rails taip pat palaiko inicializavimo failų pavadinimų numeravimą, tačiau tai gali sukelti failo pavadinimo keitimą. Nerekomenduojama aktyviai įkeliant inicializavimo failus naudoti `require` funkciją, nes tai gali lemti dvigubą inicializavimo failo įkėlimą.

PASTABA: Nėra garantijos, kad jūsų inicializavimo failai bus įkelti po visų juvelyrinių akmenų inicializavimo failų, todėl bet koks inicializavimo kodo, priklausantis nuo tam tikro juvelyrinių akmenų inicializavimo, turėtų būti įtrauktas į `config.after_initialize` bloką.

Inicializavimo įvykiai
---------------------

Rails turi 5 inicializavimo įvykius, į kuriuos galima įsikišti (pateikiami vykdymo tvarka):

* `before_configuration`: Tai vykdoma tuoj pat, kai taikomosios programos konstanta paveldi iš `Rails::Application`. `config` iškvietimai yra vertinami prieš tai.
* `before_initialize`: Tai vykdoma tiesiogiai prieš aplikacijos inicializavimo procesą su `:bootstrap_hook` inicializatoriumi, esančiu Rails inicializavimo proceso pradžioje.

* `to_prepare`: Vykdoma po visų Railties (įskaitant patį aplikaciją) inicializatorių vykdymo, bet prieš eager loading ir middleware stack'o sukūrimą. Svarbiausia, vykdoma kiekvieną kartą, kai kodas yra perkraunamas `development` režime, bet tik vieną kartą (paleidimo metu) `production` ir `test` režimuose.

* `before_eager_load`: Tai vykdoma tiesiogiai prieš eager loading, kuris yra numatytasis elgesys `production` aplinkoje, bet ne `development` aplinkoje.

* `after_initialize`: Vykdoma tiesiogiai po aplikacijos inicializavimo, po aplikacijos inicializatorių vykdymo `config/initializers` direktorijoje.

Norint apibrėžti įvykį šiems "hooks", naudokite bloko sintaksę `Rails::Application`, `Rails::Railtie` ar `Rails::Engine` klasės viduje:

```ruby
module YourApp
  class Application < Rails::Application
    config.before_initialize do
      # inicializavimo kodas
    end
  end
end
```

Alternatyviai, tai taip pat galima padaryti per `config` metodą `Rails.application` objekte:

```ruby
Rails.application.config.before_initialize do
  # inicializavimo kodas
end
```

ĮSPĖJIMAS: Kai `after_initialize` blokas yra kviečiamas, kai kurios jūsų aplikacijos dalys, ypač maršrutizavimas, dar nėra sukonfigūruotos.

### `Rails::Railtie#initializer`

Rails turi keletą inicializatorių, kurie vykdomi paleidus programą ir kurie yra apibrėžti naudojant `initializer` metodą iš `Rails::Railtie`. Štai pavyzdys iš Action Controller, `set_helpers_path` inicializatoriaus:

```ruby
initializer "action_controller.set_helpers_path" do |app|
  ActionController::Helpers.helpers_path = app.helpers_paths
end
```

`initializer` metodas priima tris argumentus, pirmasis yra inicializatoriaus pavadinimas, antrasis yra parinkčių hash'as (čia nerodomas) ir trečiasis yra blokas. `:before` raktas parinkčių hash'e gali būti nurodytas, norint nurodyti, prieš kurį inicializatorių šis naujas inicializatorius turi būti vykdomas, o `:after` raktas nurodys, kurį inicializatorių vykdyti po šio inicializatoriaus.

Inicializatoriai, apibrėžti naudojant `initializer` metodą, bus vykdomi pagal jų apibrėžimo tvarką, išskyrus tuos, kurie naudoja `:before` ar `:after` metodus.

ĮSPĖJIMAS: Galite įdėti savo inicializatorių prieš ar po bet kurio kito inicializatoriaus grandinėje, kol tai yra logiška. Tarkime, turite 4 inicializatorius, vadinamus "one" iki "four" (apibrėžtus tokiu tvarka) ir apibrėžiate "four" eiti _prieš_ "two", bet _po_ "three", tai tiesiog nėra logiška ir Rails negalės nustatyti jūsų inicializatorių tvarkos.

`initializer` metodo bloko argumentas yra pats aplikacijos objektas, todėl galime pasiekti jo konfigūraciją naudodami `config` metodą, kaip parodyta pavyzdyje.
Kadangi `Rails::Application` paveldi iš `Rails::Railtie` (netiesiogiai), galite naudoti `initializer` metodą `config/application.rb` failo, kad apibrėžtumėte inicializatorius programai.

### Inicializatoriai

Žemiau pateikiamas išsami sąrašas visų inicializatorių, rasti Rails, pagal jų apibrėžimo tvarką (ir todėl vykdomi, nebent kitaip nenurodyta).

* `load_environment_hook`: Veikia kaip laikinas vietos, kad būtų galima apibrėžti `:load_environment_config`, kuris bus vykdomas prieš jį.

* `load_active_support`: Reikalauja `active_support/dependencies`, kuris nustato pagrindą Active Support. Galimai reikalauja `active_support/all`, jei `config.active_support.bare` yra netiesa, kas yra numatyta.

* `initialize_logger`: Inicializuoja žurnalą (objektą `ActiveSupport::Logger`) programai ir prieinamą per `Rails.logger`, jei iki šios vietos įterptas inicializatorius nenurodo `Rails.logger`.

* `initialize_cache`: Jei `Rails.cache` dar nėra nustatytas, inicializuoja talpyklą, nurodydamas reikšmę `config.cache_store` ir rezultatą saugo kaip `Rails.cache`. Jei šis objektas atsako į `middleware` metodą, jo middleware įterpiamas prieš `Rack::Runtime` middleware eilėje.

* `set_clear_dependencies_hook`: Šis inicializatorius - kuris vykdomas tik jei `config.enable_reloading` nustatytas kaip `true` - naudoja `ActionDispatch::Callbacks.after` pašalinti konstantas, kurios buvo naudojamos užklausos metu, iš objekto erdvės, kad jos būtų perkrautos sekančioje užklausoje.

* `bootstrap_hook`: Vykdo visus sukonfigūruotus `before_initialize` blokus.

* `i18n.callbacks`: Vystymo aplinkoje nustato `to_prepare` atgalinį kvietimą, kuris iškviestų `I18n.reload!`, jei bet kurios iš vietinių nustatymų pasikeitė nuo paskutinės užklausos. Produkcijoje šis atgalinis kvietimas bus vykdomas tik pirmoje užklausoje.

* `active_support.deprecation_behavior`: Nustato pasenusių funkcijų pranešimų elgesį [`Rails.application.deprecators`][] pagal [`config.active_support.report_deprecations`](#config-active-support-report-deprecations), [`config.active_support.deprecation`](#config-active-support-deprecation), [`config.active_support.disallowed_deprecation`](#config-active-support-disallowed-deprecation) ir [`config.active_support.disallowed_deprecation_warnings`](#config-active-support-disallowed-deprecation-warnings).

* `active_support.initialize_time_zone`: Nustato numatytąją laiko juostą programai pagal `config.time_zone` nustatymą, kuris pagal nutylėjimą yra "UTC".

* `active_support.initialize_beginning_of_week`: Nustato numatytąją savaitės pradžią programai pagal `config.beginning_of_week` nustatymą, kuris pagal nutylėjimą yra `:monday`.

* `active_support.set_configs`: Nustato Active Support, naudodamas `config.active_support` nustatymus, išsiunčiant metodų pavadinimus kaip setterius į `ActiveSupport` ir perduodant reikšmes.

* `action_dispatch.configure`: Konfigūruoja `ActionDispatch::Http::URL.tld_length` būti nustatytą į `config.action_dispatch.tld_length` reikšmę.

* `action_view.set_configs`: Nustato Action View, naudodamas `config.action_view` nustatymus, išsiunčiant metodų pavadinimus kaip setterius į `ActionView::Base` ir perduodant reikšmes.

* `action_controller.assets_config`: Inicializuoja `config.action_controller.assets_dir` į programos viešąjį katalogą, jei nėra aiškiai sukonfigūruotas.

* `action_controller.set_helpers_path`: Nustato Action Controller `helpers_path` į programos `helpers_path`.

* `action_controller.parameters_config`: Konfigūruoja stiprių parametrų parinktis `ActionController::Parameters`.

* `action_controller.set_configs`: Nustato Action Controller, naudodamas `config.action_controller` nustatymus, išsiunčiant metodų pavadinimus kaip setterius į `ActionController::Base` ir perduodant reikšmes.
* `action_controller.compile_config_methods`: Inicializuoja metodų konfigūraciją, kad jie būtų greičiau pasiekiami.

* `active_record.initialize_timezone`: Nustato `ActiveRecord::Base.time_zone_aware_attributes` reikšmę į `true`, taip pat nustato `ActiveRecord::Base.default_timezone` į UTC. Kai atributai yra nuskaitomi iš duomenų bazės, jie bus konvertuojami į laiko juostą, nurodytą `Time.zone`.

* `active_record.logger`: Nustato `ActiveRecord::Base.logger` - jei jis dar nebuvo nustatytas - į `Rails.logger`.

* `active_record.migration_error`: Konfigūruoja tarpinį programinės įrangos sluoksnį, kuris patikrina, ar yra laukiančių migracijų.

* `active_record.check_schema_cache_dump`: Įkelia schemos kešo iškrovimą, jei jis yra konfigūruotas ir prieinamas.

* `active_record.warn_on_records_fetched_greater_than`: Įjungia įspėjimus, kai užklausos grąžina didelį įrašų skaičių.

* `active_record.set_configs`: Nustato Active Record, naudodamas nustatymus `config.active_record`, išsiunčiant metodų pavadinimus kaip nustatytuvus į `ActiveRecord::Base` ir perduodant reikšmes.

* `active_record.initialize_database`: Įkelia duomenų bazės konfigūraciją (pagal numatytuosius nustatymus) iš `config/database.yml` ir nustato ryšį su dabartine aplinka.

* `active_record.log_runtime`: Įtraukia `ActiveRecord::Railties::ControllerRuntime` ir `ActiveRecord::Railties::JobRuntime`, kurie atsakingi už laiko, kurį užima Active Record užklausos, pranešimą apie užklausą į žurnalą.

* `active_record.set_reloader_hooks`: Jei `config.enable_reloading` nustatytas į `true`, atstatomi visi galimi duomenų bazės prisijungimai.

* `active_record.add_watchable_files`: Prideda `schema.rb` ir `structure.sql` failus į stebimus failus.

* `active_job.logger`: Nustato `ActiveJob::Base.logger` - jei jis dar nebuvo nustatytas - į `Rails.logger`.

* `active_job.set_configs`: Nustato Active Job, naudodamas nustatymus `config.active_job`, išsiunčiant metodų pavadinimus kaip nustatytuvus į `ActiveJob::Base` ir perduodant reikšmes.

* `action_mailer.logger`: Nustato `ActionMailer::Base.logger` - jei jis dar nebuvo nustatytas - į `Rails.logger`.

* `action_mailer.set_configs`: Nustato Action Mailer, naudodamas nustatymus `config.action_mailer`, išsiunčiant metodų pavadinimus kaip nustatytuvus į `ActionMailer::Base` ir perduodant reikšmes.

* `action_mailer.compile_config_methods`: Inicializuoja metodų konfigūraciją, kad jie būtų greičiau pasiekiami.

* `set_load_path`: Šis inicializatorius vykdomas prieš `bootstrap_hook`. Prideda kelius, nurodytus `config.load_paths`, ir visus automatinio įkėlimo kelius į `$LOAD_PATH`.

* `set_autoload_paths`: Šis inicializatorius vykdomas prieš `bootstrap_hook`. Prideda visus `app` aplanko subaplinkes ir kelius, nurodytus `config.autoload_paths`, `config.eager_load_paths` ir `config.autoload_once_paths`, į `ActiveSupport::Dependencies.autoload_paths`.

* `add_routing_paths`: Įkelia (pagal numatytuosius nustatymus) visus `config/routes.rb` failus (aplikacijoje ir railties, įskaitant variklius) ir nustato maršrutus aplikacijai.

* `add_locales`: Prideda failus iš `config/locales` (iš aplikacijos, railties ir variklių) į `I18n.load_path`, padarant šių failų vertimus prieinamus.

* `add_view_paths`: Prideda `app/views` aplanką iš aplikacijos, railties ir variklių į paieškos taką aplikacijos rodinių failams.

* `add_mailer_preview_paths`: Prideda `test/mailers/previews` aplanką iš aplikacijos, railties ir variklių į paieškos taką aplikacijos pašto peržiūros failams.
* `load_environment_config`: Šis inicializatorius paleidžiamas prieš `load_environment_hook`. Įkelia `config/environments` failą esamam aplinkos nustatymui.

* `prepend_helpers_path`: Prideda `app/helpers` katalogą iš aplikacijos, railties ir variklių į pagalbininkų paieškos kelią aplikacijai.

* `load_config_initializers`: Įkelia visus Ruby failus iš `config/initializers` aplikacijoje, railties ir varikliuose. Šiame kataloge esantys failai gali būti naudojami konfigūracijos nustatymams, kurie turėtų būti atlikti po visų karkasų įkėlimo.

* `engines_blank_point`: Suteikia inicializavimo tašką, į kurį galima įsikišti, jei norite ką nors padaryti prieš įkeliant variklius. Po šio taško visi railtie ir variklio inicializatoriai yra paleidžiami.

* `add_generator_templates`: Ieško generatorių šablonų `lib/templates` aplikacijoje, railties ir varikliuose ir prideda juos į `config.generators.templates` nustatymą, kuris padarys šablonus prieinamus visiems generatoriams.

* `ensure_autoload_once_paths_as_subset`: Užtikrina, kad `config.autoload_once_paths` turėtų tik kelią iš `config.autoload_paths`. Jei jis turi papildomų kelių, bus iškelta išimtis.

* `add_to_prepare_blocks`: Kiekvieno `config.to_prepare` kvietimo blokas aplikacijoje, railtie ar variklyje yra pridedamas prie `to_prepare` atgalinių iškvietimų Action Dispatch, kurie bus vykdomi užklausai kiekvieno užklausos metu vystymo metu arba prieš pirmąją užklausą gamyboje.

* `add_builtin_route`: Jei aplikacija veikia vystymo aplinkoje, tai pridės maršrutą `rails/info/properties` prie aplikacijos maršrutų. Šis maršrutas pateikia išsamią informaciją, tokia kaip Rails ir Ruby versija, `public/index.html` faile pagal nutylėjimą esančioje Rails aplikacijoje.

* `build_middleware_stack`: Sukuria tarpinio programinės įrangos paketą aplikacijai ir grąžina objektą, kuris turi `call` metodą, kuris priima Rack aplinkos objektą užklausai.

* `eager_load!`: Jei `config.eager_load` yra `true`, paleidžia `config.before_eager_load` kodus ir tada iškviečia `eager_load!`, kuris įkelia visus `config.eager_load_namespaces`.

* `finisher_hook`: Suteikia užkabinimo tašką po aplikacijos inicializavimo proceso baigimo ir taip pat paleidžia visus `config.after_initialize` blokus aplikacijai, railties ir varikliams.

* `set_routes_reloader_hook`: Konfigūruoja Action Dispatch, kad atnaujintų maršrutų failą naudojant `ActiveSupport::Callbacks.to_run`.

* `disable_dependency_loading`: Išjungia automatinį priklausomybių įkėlimą, jei `config.eager_load` nustatytas kaip `true`.


Duomenų bazės jungimas
----------------------

Aktyvaus įrašo duomenų bazės ryšiai valdomi per `ActiveRecord::ConnectionAdapters::ConnectionPool`, kuris užtikrina, kad ryšių baseinas sinchronizuoja ribotą skaičių gijų prieigą prie duomenų bazės ryšių. Ši riba pagal nutylėjimą yra 5 ir gali būti konfigūruojama `database.yml` faile.

```ruby
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

Kadangi ryšių baseinas pagal nutylėjimą yra valdomas viduje Aktyvaus įrašo, visi aplikacijos serveriai (Thin, Puma, Unicorn ir kt.) turėtų elgtis vienodai. Duomenų bazės ryšių baseinas pradžioje yra tuščias. Didėjant ryšių poreikiui, jis juos sukuria iki pasiekiamos ryšių baseino ribos.
Bet kuris užklausimas pirmą kartą patikrins ryšį, kai jis reikalaus prieigos prie duomenų bazės. Užklausos pabaigoje jis vėl patikrins ryšį. Tai reiškia, kad papildoma ryšio vieta bus vėl prieinama kitai užklausai eilėje.

Jei bandysite naudoti daugiau ryšių nei yra prieinama, Active Record jūsų blokuos ir lauks ryšio iš šaltinio. Jei negalima gauti ryšio, bus išmetama laukimo klaida, panaši į žemiau pateiktą.

```ruby
ActiveRecord::ConnectionTimeoutError - nepavyko gauti duomenų bazės ryšio per 5,000 sekundžių (laukta 5,000 sekundžių)
```

Jei gaunate aukščiau pateiktą klaidą, galbūt norėsite padidinti ryšių baseino dydį padidinant `pool` parinktį `database.yml` faile.

PASTABA. Jei naudojate daugiausiai gijų aplinkoje, gali būti galimybė, kad kelios gijos gali tuo pačiu metu naudoti kelis ryšius. Taigi, priklausomai nuo dabartinio užklausų krūvio, gali būti kelios gijos, konkuruojančios dėl riboto ryšių skaičiaus.


Papildoma konfigūracija
--------------------

Galite konfigūruoti savo kodą per "Rails" konfigūracijos objektą su savo konfigūracija, esančia arba `config.x` vardų erdvėje, arba tiesiogiai `config`. Pagrindinis skirtumas tarp šių dviejų yra tas, kad turėtumėte naudoti `config.x`, jei apibrėžiate _sugnested_ konfigūraciją (pvz., `config.x.nested.hi`), ir tiesiog `config` vienalyčiai konfigūracijai (pvz., `config.hello`).

```ruby
config.x.payment_processing.schedule = :daily
config.x.payment_processing.retries  = 3
config.super_debugger = true
```

Šios konfigūracijos taškai tada yra prieinami per konfigūracijos objektą:

```ruby
Rails.configuration.x.payment_processing.schedule # => :daily
Rails.configuration.x.payment_processing.retries  # => 3
Rails.configuration.x.payment_processing.not_set  # => nil
Rails.configuration.super_debugger                # => true
```

Taip pat galite naudoti `Rails::Application.config_for` visų konfigūracijos failų įkėlimui:

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
Rails.configuration.payment['merchant_id'] # => production_merchant_id arba development_merchant_id
```

`Rails::Application.config_for` palaiko `shared` konfigūraciją, skirtą bendroms konfigūracijoms grupuoti. Bendra konfigūracija bus sujungta su aplinkos konfigūracija.

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
# development aplinka
Rails.application.config_for(:example)[:foo][:bar] #=> { baz: 1, qux: 2 }
```

Paieškos variklių indeksavimas
-----------------------

Kartais norite užkirsti kelią tam, kad kai kurios jūsų programos puslapiai būtų matomi paieškos svetainėse, tokiose kaip Google, Bing, Yahoo ar Duck Duck Go. Indeksuojančios šių svetainių robotai pirmiausia analizuos `http://your-site.com/robots.txt` failą, kad žinotų, kurie puslapiai gali būti indeksuojami.
Rails sukurs šį failą už jus `/public` aplanke. Pagal numatytuosius nustatymus, jis leidžia paieškos sistemoms indeksuoti visus jūsų aplikacijos puslapius. Jei norite užblokuoti indeksavimą visuose aplikacijos puslapiuose, naudokite šį kodą:

```
User-agent: *
Disallow: /
```

Norint užblokuoti tik tam tikrus puslapius, reikia naudoti sudėtingesnę sintaksę. Sužinokite daugiau apie tai [oficialioje dokumentacijoje](https://www.robotstxt.org/robotstxt.html).

Įvykių pagrindžiamas failų sistemos stebėjimas
---------------------------------------------

Jei įkeltas [listen gem](https://github.com/guard/listen), Rails naudoja įvykių pagrindžiamą failų sistemos stebėjimą, kad aptiktų pakeitimus, kai įgalinta perkrovimas:

```ruby
group :development do
  gem 'listen', '~> 3.3'
end
```

Kitu atveju, kiekvieno užklausos metu Rails patikrina aplikacijos medį, ar kažkas pasikeitė.

Linux ir macOS sistemose nereikia papildomų gem'ų, tačiau [reikalingi kai kurie *BSD sistemoms](https://github.com/guard/listen#on-bsd) ir [Windows sistemoms](https://github.com/guard/listen#on-windows).

Atkreipkite dėmesį, kad [kai kurios konfigūracijos nepalaikomos](https://github.com/guard/listen#issues--limitations).
[`config.load_defaults`]: https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults
[`ActiveSupport::ParameterFilter.precompile_filters`]: https://api.rubyonrails.org/classes/ActiveSupport/ParameterFilter.html#method-c-precompile_filters
[ActiveModel::Error#full_message]: https://api.rubyonrails.org/classes/ActiveModel/Error.html#method-i-full_message
[`ActiveSupport::MessageEncryptor`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html
[`ActiveSupport::MessageVerifier`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html
[`message_serializer_fallback.active_support`]: active_support_instrumentation.html#message-serializer-fallback-active-support
[`Rails.application.deprecators`]: https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators
