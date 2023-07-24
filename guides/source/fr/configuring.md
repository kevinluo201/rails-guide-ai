**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bba7dd6e311e7abd59e434f12dbebd0e
Configuration des applications Rails
=====================================

Ce guide couvre les fonctionnalités de configuration et d'initialisation disponibles pour les applications Rails.

Après avoir lu ce guide, vous saurez :

* Comment ajuster le comportement de vos applications Rails.
* Comment ajouter du code supplémentaire à exécuter au démarrage de l'application.

--------------------------------------------------------------------------------

Emplacements pour le code d'initialisation
-----------------------------------------

Rails propose quatre emplacements standard pour placer le code d'initialisation :

* `config/application.rb`
* Fichiers de configuration spécifiques à l'environnement
* Initialisateurs
* Après-initialisateurs

Exécution du code avant Rails
----------------------------

Dans le cas rare où votre application doit exécuter du code avant le chargement de Rails lui-même, placez-le au-dessus de l'appel à `require "rails/all"` dans `config/application.rb`.

Configuration des composants Rails
----------------------------------

En général, la configuration de Rails signifie la configuration des composants de Rails, ainsi que la configuration de Rails lui-même. Le fichier de configuration `config/application.rb` et les fichiers de configuration spécifiques à l'environnement (comme `config/environments/production.rb`) vous permettent de spécifier les différents paramètres que vous souhaitez transmettre à tous les composants.

Par exemple, vous pouvez ajouter ce paramètre au fichier `config/application.rb` :

```ruby
config.time_zone = 'Central Time (US & Canada)'
```

Il s'agit d'un paramètre pour Rails lui-même. Si vous souhaitez transmettre des paramètres à des composants Rails individuels, vous pouvez le faire via le même objet `config` dans `config/application.rb` :

```ruby
config.active_record.schema_format = :ruby
```

Rails utilisera ce paramètre particulier pour configurer Active Record.

AVERTISSEMENT : Utilisez les méthodes de configuration publiques plutôt que d'appeler directement la classe associée. Par exemple, utilisez `Rails.application.config.action_mailer.options` au lieu de `ActionMailer::Base.options`.

NOTE : Si vous avez besoin d'appliquer une configuration directement à une classe, utilisez un [hook de chargement différé](https://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html) dans un initialisateur pour éviter le chargement automatique de la classe avant que l'initialisation ne soit terminée. Cela ne fonctionnera pas car le chargement automatique pendant l'initialisation ne peut pas être répété en toute sécurité lorsque l'application est rechargée.

### Valeurs par défaut versionnées

[`config.load_defaults`] charge les valeurs de configuration par défaut pour une version cible et toutes les versions antérieures. Par exemple, `config.load_defaults 6.1` chargera les valeurs par défaut pour toutes les versions jusqu'à la version 6.1.


Voici les valeurs par défaut associées à chaque version cible. En cas de valeurs conflictuelles, les versions plus récentes ont la priorité sur les versions plus anciennes.

#### Valeurs par défaut pour la version cible 7.1

- [`config.action_controller.allow_deprecated_parameters_hash_equality`](#config-action-controller-allow-deprecated-parameters-hash-equality) : `false`
- [`config.action_dispatch.debug_exception_log_level`](#config-action-dispatch-debug-exception-log-level) : `:error`
- [`config.action_dispatch.default_headers`](#config-action-dispatch-default-headers) : `{ "X-Frame-Options" => "SAMEORIGIN", "X-XSS-Protection" => "0", "X-Content-Type-Options" => "nosniff", "X-Permitted-Cross-Domain-Policies" => "none", "Referrer-Policy" => "strict-origin-when-cross-origin" }`
- [`config.action_text.sanitizer_vendor`](#config-action-text-sanitizer-vendor) : `Rails::HTML::Sanitizer.best_supported_vendor`
- [`config.action_view.sanitizer_vendor`](#config-action-view-sanitizer-vendor) : `Rails::HTML::Sanitizer.best_supported_vendor`
- [`config.active_job.use_big_decimal_serializer`](#config-active-job-use-big-decimal-serializer) : `true`
- [`config.active_record.allow_deprecated_singular_associations_name`](#config-active-record-allow-deprecated-singular-associations-name) : `false`
- [`config.active_record.before_committed_on_all_records`](#config-active-record-before-committed-on-all-records) : `true`
- [`config.active_record.belongs_to_required_validates_foreign_key`](#config-active-record-belongs-to-required-validates-foreign-key) : `false`
- [`config.active_record.default_column_serializer`](#config-active-record-default-column-serializer) : `nil`
- [`config.active_record.encryption.hash_digest_class`](#config-active-record-encryption-hash-digest-class) : `OpenSSL::Digest::SHA256`
- [`config.active_record.encryption.support_sha1_for_non_deterministic_encryption`](#config-active-record-encryption-support-sha1-for-non-deterministic-encryption) : `false`
- [`config.active_record.marshalling_format_version`](#config-active-record-marshalling-format-version) : `7.1`
- [`config.active_record.query_log_tags_format`](#config-active-record-query-log-tags-format) : `:sqlcommenter`
- [`config.active_record.raise_on_assign_to_attr_readonly`](#config-active-record-raise-on-assign-to-attr-readonly) : `true`
- [`config.active_record.run_after_transaction_callbacks_in_order_defined`](#config-active-record-run-after-transaction-callbacks
La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| ---------------------- | ----------------------- |
| (originale)            | `true`                  |
| 7.1                    | `false`                 |

Le répertoire `lib` n'est pas affecté par ce drapeau, il est toujours ajouté à `$LOAD_PATH`.

#### `config.after_initialize`

Prend un bloc qui sera exécuté _après_ que Rails ait terminé l'initialisation de l'application. Cela inclut l'initialisation du framework lui-même, des moteurs et de tous les initialiseurs de l'application dans `config/initializers`. Notez que ce bloc sera exécuté pour les tâches rake. Utile pour configurer des valeurs configurées par d'autres initialiseurs :

```ruby
config.after_initialize do
  ActionView::Base.sanitized_allowed_tags.delete 'div'
end
```

#### `config.after_routes_loaded`

Prend un bloc qui sera exécuté après que Rails ait terminé le chargement des routes de l'application. Ce bloc sera également exécuté chaque fois que les routes sont rechargées.

```ruby
config.after_routes_loaded do
  # Code qui fait quelque chose avec Rails.application.routes
end
```

#### `config.allow_concurrency`

Contrôle si les requêtes doivent être traitées de manière concurrente. Cela ne doit être défini sur `false` que si le code de l'application n'est pas thread-safe. Par défaut, la valeur est `true`.

#### `config.asset_host`

Définit l'hôte pour les ressources. Utile lorsque des CDN sont utilisés pour héberger les ressources, ou lorsque vous souhaitez contourner les contraintes de concurrence intégrées dans les navigateurs en utilisant des alias de domaine différents. Version abrégée de `config.action_controller.asset_host`.

#### `config.assume_ssl`

Fait croire à l'application que toutes les requêtes arrivent via SSL. Cela est utile lors de la mise en proxy via un équilibreur de charge qui termine SSL, la requête transmise apparaîtra comme étant HTTP au lieu de HTTPS pour l'application. Cela permet de cibler HTTP au lieu de HTTPS pour les redirections et la sécurité des cookies. Ce middleware fait en sorte que le serveur suppose que le proxy a déjà terminé SSL et que la requête est réellement HTTPS.

#### `config.autoflush_log`

Active l'écriture immédiate des fichiers journaux au lieu de les mettre en mémoire tampon. Par défaut, la valeur est `true`.

#### `config.autoload_once_paths`

Accepte un tableau de chemins à partir desquels Rails chargera automatiquement les constantes qui ne seront pas effacées par requête. Cela est pertinent si le rechargement est activé, ce qui est le cas par défaut dans l'environnement `development`. Sinon, le chargement automatique se produit une seule fois. Tous les éléments de ce tableau doivent également être présents dans `autoload_paths`. La valeur par défaut est un tableau vide.

#### `config.autoload_paths`

Accepte un tableau de chemins à partir desquels Rails chargera automatiquement les constantes. La valeur par défaut est un tableau vide. Depuis [Rails 6](upgrading_ruby_on_rails.html#autoloading), il n'est pas recommandé de modifier cela. Voir [Chargement automatique et rechargement des constantes](autoloading_and_reloading_constants.html#autoload-paths).

#### `config.autoload_lib(ignore:)`

Cette méthode ajoute `lib` à `config.autoload_paths` et `config.eager_load_paths`.

Normalement, le répertoire `lib` contient des sous-répertoires qui ne doivent pas être chargés automatiquement ou chargés immédiatement. Veuillez passer leur nom relatif à `lib` dans l'argument facultatif `ignore` requis. Par exemple,

```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

Veuillez consulter plus de détails dans le [guide de chargement automatique](autoloading_and_reloading_constants.html).

#### `config.autoload_lib_once(ignore:)`

La méthode `config.autoload_lib_once` est similaire à `config.autoload_lib`, sauf qu'elle ajoute `lib` à `config.autoload_once_paths` à la place.

En appelant `config.autoload_lib_once`, les classes et modules dans `lib` peuvent être chargés automatiquement, même à partir des initialiseurs de l'application, mais ne seront pas rechargés.

#### `config.beginning_of_week`

Définit le début de la semaine par défaut pour l'application. Accepte un jour de la semaine valide sous forme de symbole (par exemple `:lundi`).

#### `config.cache_classes`

Ancien paramètre équivalent à `!config.enable_reloading`. Pris en charge pour la compatibilité ascendante.

#### `config.cache_store`

Configure le magasin de cache à utiliser pour le cache de Rails. Les options comprennent l'un des symboles `:memory_store`, `:file_store`, `:mem_cache_store`, `:null_store`, `:redis_cache_store`, ou un objet qui implémente l'API de cache. Par défaut, la valeur est `:file_store`. Voir [Magasins de cache](caching_with_rails.html#cache-stores) pour les options de configuration spécifiques à chaque magasin.

#### `config.colorize_logging`

Indique si oui ou non utiliser des codes de couleur ANSI lors de la journalisation des informations. Par défaut, la valeur est `true`.

#### `config.consider_all_requests_local`

Est un drapeau. Si `true`, alors toute erreur entraînera l'affichage d'informations de débogage détaillées dans la réponse HTTP, et le contrôleur `Rails::Info` affichera le contexte d'exécution de l'application dans `/rails/info/properties`. Par défaut, la valeur est `true` dans les environnements de développement et de test, et `false` en production. Pour un contrôle plus précis, définissez cette valeur sur `false` et implémentez `show_detailed_exceptions?` dans les contrôleurs pour spécifier quelles requêtes doivent fournir des informations de débogage en cas d'erreurs.

#### `config.console`

Vous permet de définir la classe qui sera utilisée comme console lorsque vous exécutez `bin/rails console`. Il est préférable de l'exécuter dans le bloc `console` :

```ruby
console do
  # ce bloc est appelé uniquement lors de l'exécution de la console,
  # donc nous pouvons en toute sécurité exiger pry ici
  require "pry"
  config.console = Pry
end
```

#### `config.content_security_policy_nonce_directives`

Voir [Ajout d'un nonce](security.html#adding-a-nonce) dans le guide de sécurité.

#### `config.content_security_policy_nonce_generator`

Voir [Ajout d'un nonce](security.html#adding-a-nonce) dans le guide de sécurité.
#### `config.content_security_policy_report_only`

Voir [Signalement des violations](security.html#reporting-violations) dans le Guide de sécurité.

#### `config.credentials.content_path`

Le chemin du fichier de crédentials chiffré.

Par défaut, `config/credentials/#{Rails.env}.yml.enc` s'il existe, sinon `config/credentials.yml.enc`.

REMARQUE : Pour que les commandes `bin/rails credentials` reconnaissent cette valeur, elle doit être définie dans `config/application.rb` ou `config/environments/#{Rails.env}.rb`.

#### `config.credentials.key_path`

Le chemin du fichier de clé de crédentials chiffré.

Par défaut, `config/credentials/#{Rails.env}.key` s'il existe, sinon `config/master.key`.

REMARQUE : Pour que les commandes `bin/rails credentials` reconnaissent cette valeur, elle doit être définie dans `config/application.rb` ou `config/environments/#{Rails.env}.rb`.

#### `config.debug_exception_response_format`

Définit le format utilisé dans les réponses en cas d'erreurs dans l'environnement de développement. Par défaut, `:api` pour les applications uniquement API et `:default` pour les applications normales.

#### `config.disable_sandbox`

Contrôle si quelqu'un peut ou non démarrer une console en mode sandbox. Cela permet d'éviter une session de console sandbox qui s'exécute pendant une longue période et qui pourrait épuiser la mémoire du serveur de base de données. Par défaut, `false`.

#### `config.eager_load`

Lorsque `true`, charge en avance tous les espaces de noms `config.eager_load_namespaces` enregistrés. Cela inclut votre application, les moteurs, les frameworks Rails et tout autre espace de noms enregistré.

#### `config.eager_load_namespaces`

Enregistre les espaces de noms qui sont chargés en avance lorsque `config.eager_load` est défini sur `true`. Tous les espaces de noms de la liste doivent répondre à la méthode `eager_load!`.

#### `config.eager_load_paths`

Accepte un tableau de chemins à partir desquels Rails chargera en avance au démarrage si `config.eager_load` est défini sur `true`. Par défaut, tous les dossiers du répertoire `app` de l'application.

#### `config.enable_reloading`

Si `config.enable_reloading` est défini sur `true`, les classes et modules de l'application sont rechargés entre les requêtes web s'ils changent. Par défaut, `true` dans l'environnement `development` et `false` dans l'environnement `production`.

Le prédicat `config.reloading_enabled?` est également défini.

#### `config.encoding`

Configure l'encodage de l'application. Par défaut, UTF-8.

#### `config.exceptions_app`

Définit l'application d'exceptions invoquée par le middleware `ShowException` lorsqu'une exception se produit.
Par défaut, `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

Les applications d'exceptions doivent gérer les erreurs `ActionDispatch::Http::MimeNegotiation::InvalidType`, qui sont levées lorsqu'un client envoie un en-tête `Accept` ou `Content-Type` invalide.
L'application `ActionDispatch::PublicExceptions` par défaut le fait automatiquement, en définissant `Content-Type` sur `text/html` et en renvoyant un statut `406 Not Acceptable`.
Si cette erreur n'est pas gérée, une erreur `500 Internal Server Error` se produira.

Utiliser `Rails.application.routes` `RouteSet` en tant qu'application d'exceptions nécessite également cette gestion spéciale.
Cela pourrait ressembler à ceci :

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

Est la classe utilisée pour détecter les mises à jour de fichiers dans le système de fichiers lorsque `config.reload_classes_only_on_change` est `true`. Rails est livré avec `ActiveSupport::FileUpdateChecker`, la valeur par défaut, et `ActiveSupport::EventedFileUpdateChecker` (celui-ci dépend de la gem [listen](https://github.com/guard/listen)). Les classes personnalisées doivent se conformer à l'API `ActiveSupport::FileUpdateChecker`.

#### `config.filter_parameters`

Utilisé pour filtrer les paramètres que vous ne souhaitez pas afficher dans les journaux, tels que les mots de passe ou les numéros de carte de crédit. Il filtre également les valeurs sensibles des colonnes de la base de données lors de l'appel de `#inspect` sur un objet Active Record. Par défaut, Rails filtre les mots de passe en ajoutant les filtres suivants dans `config/initializers/filter_parameter_logging.rb`.

```ruby
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

Le filtre des paramètres fonctionne par correspondance partielle avec une expression régulière.

#### `config.filter_redirect`

Utilisé pour filtrer les URL de redirection des journaux de l'application.

```ruby
Rails.application.config.filter_redirect += ['s3.amazonaws.com', /private-match/]
```

Le filtre de redirection fonctionne en testant si les URL incluent des chaînes ou correspondent à des expressions régulières.

#### `config.force_ssl`

Force toutes les requêtes à être servies via HTTPS et définit "https://" comme protocole par défaut lors de la génération des URL. L'application de HTTPS est gérée par le middleware `ActionDispatch::SSL`, qui peut être configuré via `config.ssl_options`.

#### `config.helpers_paths`

Définit un tableau de chemins supplémentaires pour charger les aides de vue.

#### `config.host_authorization`

Accepte un hash d'options pour configurer le middleware [HostAuthorization](#actiondispatch-hostauthorization).

#### `config.hosts`

Un tableau de chaînes, d'expressions régulières ou d'`IPAddr` utilisé pour valider l'en-tête `Host`. Utilisé par le middleware [HostAuthorization](#actiondispatch-hostauthorization) pour aider à prévenir les attaques de rebinding DNS.

#### `config.javascript_path`

Définit le chemin où se trouve le JavaScript de votre application par rapport au répertoire `app`. Par défaut, `javascript`, utilisé par [webpacker](https://github.com/rails/webpacker). Le `javascript_path` configuré d'une application sera exclu des `autoload_paths`.

#### `config.log_file_size`

Définit la taille maximale du fichier journal Rails en octets. Par défaut, `104_857_600` (100 MiB) en développement et en test, et illimité dans tous les autres environnements.

#### `config.log_formatter`

Définit le formateur du journal Rails. Cette option est par défaut une instance de `ActiveSupport::Logger::SimpleFormatter` pour tous les environnements. Si vous définissez une valeur pour `config.logger`, vous devez passer manuellement la valeur de votre formateur à votre journal avant qu'il ne soit enveloppé dans une instance `ActiveSupport::TaggedLogging`, Rails ne le fera pas pour vous.
#### `config.log_level`

Définit le niveau de verbosité du journalisateur Rails. Cette option est par défaut `:debug` pour tous les environnements sauf la production, où elle est par défaut `:info`. Les niveaux de journalisation disponibles sont : `:debug`, `:info`, `:warn`, `:error`, `:fatal` et `:unknown`.

#### `config.log_tags`

Accepte une liste de méthodes auxquelles l'objet `request` répond, un `Proc` qui accepte l'objet `request`, ou quelque chose qui répond à `to_s`. Cela permet de marquer les lignes de journal avec des informations de débogage telles que le sous-domaine et l'identifiant de la requête - très utiles pour le débogage des applications de production multi-utilisateurs.

#### `config.logger`

Est le journalisateur qui sera utilisé pour `Rails.logger` et tout autre journalisation Rails associée, telle que `ActiveRecord::Base.logger`. Il est par défaut une instance de `ActiveSupport::TaggedLogging` qui enveloppe une instance de `ActiveSupport::Logger` qui enregistre un journal dans le répertoire `log/`. Vous pouvez fournir un journalisateur personnalisé, pour une compatibilité totale, vous devez suivre ces directives :

* Pour prendre en charge un formateur, vous devez assigner manuellement un formateur à partir de la valeur `config.log_formatter` au journalisateur.
* Pour prendre en charge les journaux marqués, l'instance de journal doit être enveloppée avec `ActiveSupport::TaggedLogging`.
* Pour prendre en charge le silence, le journalisateur doit inclure le module `ActiveSupport::LoggerSilence`. La classe `ActiveSupport::Logger` inclut déjà ces modules.

```ruby
class MyLogger < ::Logger
  include ActiveSupport::LoggerSilence
end

mylogger           = MyLogger.new(STDOUT)
mylogger.formatter = config.log_formatter
config.logger      = ActiveSupport::TaggedLogging.new(mylogger)
```

#### `config.middleware`

Vous permet de configurer les middleware de l'application. Cela est expliqué en détail dans la section [Configuration des middleware](#configuring-middleware) ci-dessous.

#### `config.precompile_filter_parameters`

Lorsque `true`, précompile [`config.filter_parameters`](#config-filter-parameters) en utilisant [`ActiveSupport::ParameterFilter.precompile_filters`][].

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 7.1                   | `true`               |


#### `config.public_file_server.enabled`

Configure Rails pour servir les fichiers statiques à partir du répertoire public. Cette option est par défaut `true`, mais dans l'environnement de production, elle est définie sur `false` car le logiciel du serveur (par exemple NGINX ou Apache) utilisé pour exécuter l'application doit servir les fichiers statiques à la place. Si vous exécutez ou testez votre application en production en utilisant WEBrick (il n'est pas recommandé d'utiliser WEBrick en production), définissez l'option sur `true`. Sinon, vous ne pourrez pas utiliser le cache de page et demander des fichiers qui existent dans le répertoire public.

#### `config.railties_order`

Permet de spécifier manuellement l'ordre de chargement des Railties/Engines. La valeur par défaut est `[:all]`.

```ruby
config.railties_order = [Blog::Engine, :main_app, :all]
```

#### `config.rake_eager_load`

Lorsque `true`, charge l'application de manière anticipée lors de l'exécution des tâches Rake. Par défaut, c'est `false`.

#### `config.read_encrypted_secrets`

*OBSOLÈTE* : Vous devriez utiliser les [credentials](https://guides.rubyonrails.org/security.html#custom-credentials) à la place des secrets chiffrés.

Lorsque `true`, essaie de lire les secrets chiffrés à partir de `config/secrets.yml.enc`

#### `config.relative_url_root`

Peut être utilisé pour indiquer à Rails que vous déployez dans un sous-répertoire (configuring.html#deploy-to-a-subdirectory-relative-url-root). La valeur par défaut est `ENV['RAILS_RELATIVE_URL_ROOT']`.

#### `config.reload_classes_only_on_change`

Active ou désactive le rechargement des classes uniquement lorsque les fichiers suivis changent. Par défaut, suit tout sur les chemins de chargement automatique et est défini sur `true`. Si `config.enable_reloading` est `false`, cette option est ignorée.

#### `config.require_master_key`

Empêche l'application de démarrer si une clé principale n'est pas disponible via `ENV["RAILS_MASTER_KEY"]` ou le fichier `config/master.key`.

#### `config.secret_key_base`

La valeur de repli pour spécifier la clé secrète d'un générateur de clés d'application. Il est recommandé de ne pas le définir et de spécifier plutôt une `secret_key_base` dans `config/credentials.yml.enc`. Consultez la documentation de l'API [`secret_key_base`](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-secret_key_base) pour plus d'informations et d'autres méthodes de configuration alternatives.

#### `config.server_timing`

Lorsque `true`, ajoute le middleware [ServerTiming](#actiondispatch-servertiming) à la pile des middleware.

#### `config.session_options`

Options supplémentaires transmises à `config.session_store`. Vous devriez utiliser `config.session_store` pour le définir au lieu de le modifier vous-même.

```ruby
config.session_store :cookie_store, key: "_your_app_session"
config.session_options # => {key: "_your_app_session"}
```

#### `config.session_store`

Spécifie quelle classe utiliser pour stocker la session. Les valeurs possibles sont `:cache_store`, `:cookie_store`, `:mem_cache_store`, un magasin personnalisé ou `:disabled`. `:disabled` indique à Rails de ne pas gérer les sessions.

Ce paramètre est configuré via un appel de méthode régulier, plutôt qu'un setter. Cela permet de passer des options supplémentaires :

```ruby
config.session_store :cookie_store, key: "_your_app_session"
```

Si un magasin personnalisé est spécifié sous forme de symbole, il sera résolu dans l'espace de noms `ActionDispatch::Session` :

```ruby
# utilise ActionDispatch::Session::MyCustomStore comme magasin de session
config.session_store :my_custom_store
```

Le magasin par défaut est un magasin de cookies avec le nom de l'application comme clé de session.

#### `config.ssl_options`

Options de configuration pour le middleware [`ActionDispatch::SSL`](https://api.rubyonrails.org/classes/ActionDispatch/SSL.html).

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `{}`                 |
| 5.0                   | `{ hsts: { subdomains: true } }` |
#### `config.time_zone`

Définit le fuseau horaire par défaut de l'application et active la prise en compte des fuseaux horaires pour Active Record.

#### `config.x`

Utilisé pour ajouter facilement une configuration personnalisée imbriquée à l'objet de configuration de l'application

  ```ruby
  config.x.payment_processing.schedule = :daily
  Rails.configuration.x.payment_processing.schedule # => :daily
  ```

Voir [Configuration personnalisée](#custom-configuration)

### Configuration des ressources

#### `config.assets.css_compressor`

Définit le compresseur CSS à utiliser. Il est défini par défaut par `sass-rails`. La seule valeur alternative pour le moment est `:yui`, qui utilise la gem `yui-compressor`.

#### `config.assets.js_compressor`

Définit le compresseur JavaScript à utiliser. Les valeurs possibles sont `:terser`, `:closure`, `:uglifier` et `:yui`, qui nécessitent l'utilisation des gems `terser`, `closure-compiler`, `uglifier` ou `yui-compressor` respectivement.

#### `config.assets.gzip`

Un indicateur qui active la création d'une version compressée en gzip des ressources compilées, ainsi que des ressources non compressées. Défini par défaut sur `true`.

#### `config.assets.paths`

Contient les chemins utilisés pour rechercher les ressources. L'ajout de chemins à cette option de configuration entraînera l'utilisation de ces chemins dans la recherche des ressources.

#### `config.assets.precompile`

Vous permet de spécifier des ressources supplémentaires (autres que `application.css` et `application.js`) qui doivent être précompilées lorsque `bin/rails assets:precompile` est exécuté.

#### `config.assets.unknown_asset_fallback`

Vous permet de modifier le comportement du pipeline des ressources lorsque une ressource n'est pas dans le pipeline, si vous utilisez sprockets-rails 3.2.0 ou une version ultérieure.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `true`               |
| 5.1                   | `false`              |

#### `config.assets.prefix`

Définit le préfixe à partir duquel les ressources sont servies. Par défaut, `/assets`.

#### `config.assets.manifest`

Définit le chemin complet à utiliser pour le fichier de manifeste du précompilateur de ressources. Par défaut, un fichier nommé `manifest-<aléatoire>.json` dans le répertoire `config.assets.prefix` du dossier public.

#### `config.assets.digest`

Active l'utilisation des empreintes digitales SHA256 dans les noms des ressources. Défini par défaut sur `true`.

#### `config.assets.debug`

Désactive la concaténation et la compression des ressources. Défini par défaut sur `true` dans `development.rb`.

#### `config.assets.version`

Est une chaîne d'option utilisée dans la génération de hachage SHA256. Cela peut être modifié pour forcer la recompilation de tous les fichiers.

#### `config.assets.compile`

Est un booléen qui peut être utilisé pour activer la compilation en direct de Sprockets en production.

#### `config.assets.logger`

Accepte un journal conforme à l'interface de Log4r ou de la classe Ruby `Logger` par défaut. Par défaut, il est configuré de la même manière que `config.logger`. Définir `config.assets.logger` sur `false` désactivera l'enregistrement des ressources servies.

#### `config.assets.quiet`

Désactive l'enregistrement des demandes de ressources. Défini par défaut sur `true` dans `development.rb`.

### Configuration des générateurs

Rails vous permet de modifier les générateurs utilisés avec la méthode `config.generators`. Cette méthode prend un bloc :

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

L'ensemble complet des méthodes pouvant être utilisées dans ce bloc est le suivant :

* `force_plural` permet des noms de modèles au pluriel. Par défaut, `false`.
* `helper` définit s'il faut générer ou non des helpers. Par défaut, `true`.
* `integration_tool` définit l'outil d'intégration à utiliser pour générer des tests d'intégration. Par défaut, `:test_unit`.
* `system_tests` définit l'outil d'intégration à utiliser pour générer des tests système. Par défaut, `:test_unit`.
* `orm` définit l'ORM à utiliser. Par défaut, `false` et utilisera Active Record par défaut.
* `resource_controller` définit le générateur à utiliser pour générer un contrôleur lors de l'utilisation de `bin/rails generate resource`. Par défaut, `:controller`.
* `resource_route` définit si une définition de route de ressource doit être générée ou non. Par défaut, `true`.
* `scaffold_controller` différent de `resource_controller`, définit le générateur à utiliser pour générer un contrôleur _scaffolded_ lors de l'utilisation de `bin/rails generate scaffold`. Par défaut, `:scaffold_controller`.
* `test_framework` définit le framework de test à utiliser. Par défaut, `false` et utilisera minitest par défaut.
* `template_engine` définit le moteur de template à utiliser, comme ERB ou Haml. Par défaut, `:erb`.

### Configuration des middleware

Chaque application Rails est livrée avec un ensemble standard de middleware qu'elle utilise dans cet ordre dans l'environnement de développement :

#### `ActionDispatch::HostAuthorization`

Protège contre les attaques de rebinding DNS et autres attaques d'en-tête `Host`.
Il est inclus dans l'environnement de développement par défaut avec la configuration suivante :

```ruby
Rails.application.config.hosts = [
  IPAddr.new("0.0.0.0/0"),        # Toutes les adresses IPv4.
  IPAddr.new("::/0"),             # Toutes les adresses IPv6.
  "localhost",                    # Le domaine réservé localhost.
  ENV["RAILS_DEVELOPMENT_HOSTS"]  # Hôtes supplémentaires séparés par des virgules pour le développement.
]
```

Dans les autres environnements, `Rails.application.config.hosts` est vide et aucune vérification d'en-tête `Host` n'est effectuée. Si vous souhaitez vous protéger contre les attaques d'en-tête en production, vous devez autoriser manuellement les hôtes autorisés avec :
```ruby
Rails.application.config.hosts << "product.com"
```

L'hôte d'une requête est vérifié par rapport aux entrées de `hosts` avec l'opérateur de cas (`#===`), ce qui permet à `hosts` de prendre en charge des entrées de type `Regexp`, `Proc` et `IPAddr`, pour n'en citer que quelques-unes. Voici un exemple avec une expression régulière.

```ruby
# Autoriser les requêtes à partir de sous-domaines comme `www.product.com` et
# `beta1.product.com`.
Rails.application.config.hosts << /.*\.product\.com/
```

L'expression régulière fournie sera enveloppée avec les deux ancres (`\A` et `\z`) afin qu'elle corresponde à l'ensemble du nom d'hôte. Par exemple, `/product.com/`, une fois ancré, ne correspondrait pas à `www.product.com`.

Un cas spécial est pris en charge, qui vous permet d'autoriser tous les sous-domaines :

```ruby
# Autoriser les requêtes à partir de sous-domaines comme `www.product.com` et
# `beta1.product.com`.
Rails.application.config.hosts << ".product.com"
```

Vous pouvez exclure certaines requêtes des vérifications d'autorisation d'hôte en définissant `config.host_authorization.exclude` :

```ruby
# Exclure les requêtes pour le chemin /healthcheck/ de la vérification de l'hôte
Rails.application.config.host_authorization = {
  exclude: ->(request) { request.path.include?('healthcheck') }
}
```

Lorsqu'une requête arrive sur un hôte non autorisé, une application Rack par défaut s'exécute et répond avec `403 Forbidden`. Cela peut être personnalisé en définissant `config.host_authorization.response_app`. Par exemple :

```ruby
Rails.application.config.host_authorization = {
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

#### `ActionDispatch::ServerTiming`

Ajoute des métriques à l'en-tête `Server-Timing` pour être visualisées dans les outils de développement d'un navigateur.

#### `ActionDispatch::SSL`

Force chaque requête à être servie en utilisant HTTPS. Activé si `config.force_ssl` est défini sur `true`. Les options transmises à cela peuvent être configurées en définissant `config.ssl_options`.

#### `ActionDispatch::Static`

Est utilisé pour servir les ressources statiques. Désactivé si `config.public_file_server.enabled` est `false`. Définissez `config.public_file_server.index_name` si vous avez besoin de servir un fichier d'index de répertoire statique qui n'est pas nommé `index`. Par exemple, pour servir `main.html` au lieu de `index.html` pour les requêtes de répertoire, définissez `config.public_file_server.index_name` sur `"main"`.

#### `ActionDispatch::Executor`

Permet le rechargement du code en toute sécurité. Désactivé si `config.allow_concurrency` est `false`, ce qui provoque le chargement de `Rack::Lock`. `Rack::Lock` enveloppe l'application dans un mutex afin qu'elle ne puisse être appelée que par un seul thread à la fois.

#### `ActiveSupport::Cache::Strategy::LocalCache`

Sert de cache de base en mémoire. Ce cache n'est pas thread-safe et est destiné uniquement à servir de cache mémoire temporaire pour un seul thread.

#### `Rack::Runtime`

Définit un en-tête `X-Runtime`, contenant le temps (en secondes) nécessaire pour exécuter la requête.

#### `Rails::Rack::Logger`

Informe les journaux que la requête a commencé. Une fois la requête terminée, tous les journaux sont vidés.

#### `ActionDispatch::ShowExceptions`

Récupère toute exception renvoyée par l'application et affiche de belles pages d'exception si la requête est locale ou si `config.consider_all_requests_local` est défini sur `true`. Si `config.action_dispatch.show_exceptions` est défini sur `:none`, les exceptions seront levées quoi qu'il arrive.

#### `ActionDispatch::RequestId`

Rend un en-tête X-Request-Id unique disponible dans la réponse et active la méthode `ActionDispatch::Request#uuid`. Configurable avec `config.action_dispatch.request_id_header`.

#### `ActionDispatch::RemoteIp`

Vérifie les attaques de falsification d'adresse IP et obtient une `client_ip` valide à partir des en-têtes de la requête. Configurable avec les options `config.action_dispatch.ip_spoofing_check` et `config.action_dispatch.trusted_proxies`.

#### `Rack::Sendfile`

Intercepte les réponses dont le corps est servi à partir d'un fichier et le remplace par un en-tête X-Sendfile spécifique au serveur. Configurable avec `config.action_dispatch.x_sendfile_header`.

#### `ActionDispatch::Callbacks`

Exécute les rappels de préparation avant de servir la requête.

#### `ActionDispatch::Cookies`

Définit les cookies pour la requête.

#### `ActionDispatch::Session::CookieStore`

Est responsable de la conservation de la session dans les cookies. Un middleware alternatif peut être utilisé pour cela en modifiant [`config.session_store`](#config-session-store).

#### `ActionDispatch::Flash`

Configure les clés `flash`. Disponible uniquement si [`config.session_store`](#config-session-store) est défini sur une valeur.

#### `Rack::MethodOverride`

Permet de remplacer la méthode si `params[:_method]` est défini. Il s'agit du middleware qui prend en charge les types de méthode HTTP PATCH, PUT et DELETE.

#### `Rack::Head`

Convertit les requêtes HEAD en requêtes GET et les sert en conséquence.

#### Ajout de middleware personnalisé

En plus de ces middlewares habituels, vous pouvez ajouter les vôtres en utilisant la méthode `config.middleware.use` :

```ruby
config.middleware.use Magical::Unicorns
```

Cela placera le middleware `Magical::Unicorns` à la fin de la pile. Vous pouvez utiliser `insert_before` si vous souhaitez ajouter un middleware avant un autre.

```ruby
config.middleware.insert_before Rack::Head, Magical::Unicorns
```

Ou vous pouvez insérer un middleware à une position exacte en utilisant des index. Par exemple, si vous souhaitez insérer le middleware `Magical::Unicorns` en haut de la pile, vous pouvez le faire ainsi :

```ruby
config.middleware.insert_before 0, Magical::Unicorns
```

Il y a aussi `insert_after` qui insérera un middleware après un autre :

```ruby
config.middleware.insert_after Rack::Head, Magical::Unicorns
```

Les middlewares peuvent également être entièrement remplacés par d'autres :

```ruby
config.middleware.swap ActionController::Failsafe, Lifo::Failsafe
```

Les middlewares peuvent être déplacés d'un endroit à un autre :
```ruby
config.middleware.move_before ActionDispatch::Flash, Magical::Unicorns
```

Cela déplacera le middleware `Magical::Unicorns` avant
`ActionDispatch::Flash`. Vous pouvez également le déplacer après :

```ruby
config.middleware.move_after ActionDispatch::Flash, Magical::Unicorns
```

Ils peuvent également être supprimés complètement de la pile :

```ruby
config.middleware.delete Rack::MethodOverride
```

### Configuration de i18n

Toutes ces options de configuration sont déléguées à la bibliothèque `I18n`.

#### `config.i18n.available_locales`

Définit les locales disponibles autorisées pour l'application. Par défaut, toutes les clés de locale trouvées dans les fichiers de locale, généralement uniquement `:en` dans une nouvelle application.

#### `config.i18n.default_locale`

Définit la locale par défaut d'une application utilisée pour i18n. Par défaut, `:en`.

#### `config.i18n.enforce_available_locales`

Veille à ce que toutes les locales passées par i18n doivent être déclarées dans la liste `available_locales`, en levant une exception `I18n::InvalidLocale` lors de la définition d'une locale non disponible. Par défaut, `true`. Il est recommandé de ne pas désactiver cette option sauf si cela est vraiment nécessaire, car cela fonctionne comme une mesure de sécurité contre la définition de n'importe quelle locale invalide à partir de l'entrée utilisateur.

#### `config.i18n.load_path`

Définit le chemin que Rails utilise pour rechercher les fichiers de locale. Par défaut, `config/locales/**/*.{yml,rb}`.

#### `config.i18n.raise_on_missing_translations`

Détermine si une erreur doit être levée pour les traductions manquantes. Par défaut, `false`.

#### `config.i18n.fallbacks`

Définit le comportement de repli pour les traductions manquantes. Voici 3 exemples d'utilisation de cette option :

  * Vous pouvez définir l'option sur `true` pour utiliser la locale par défaut comme repli, comme ceci :

    ```ruby
    config.i18n.fallbacks = true
    ```

  * Ou vous pouvez définir un tableau de locales comme repli, comme ceci :

    ```ruby
    config.i18n.fallbacks = [:tr, :en]
    ```

  * Ou vous pouvez définir des replis différents pour chaque locale individuellement. Par exemple, si vous voulez utiliser `:tr` pour `:az` et `:de`, `:en` pour `:da` comme replis, vous pouvez le faire, comme ceci :

    ```ruby
    config.i18n.fallbacks = { az: :tr, da: [:de, :en] }
    #ou
    config.i18n.fallbacks.map = { az: :tr, da: [:de, :en] }
    ```

### Configuration de Active Model

#### `config.active_model.i18n_customize_full_message`

Contrôle si le format [`Error#full_message`][ActiveModel::Error#full_message] peut être remplacé dans un fichier de locale i18n. Par défaut, `false`.

Lorsqu'il est défini sur `true`, `full_message` recherchera un format au niveau de l'attribut et du modèle des fichiers de locale. Le format par défaut est `"%{attribute} %{message}"`, où `attribute` est le nom de l'attribut et `message` est le message spécifique à la validation. L'exemple suivant remplace le format pour tous les attributs de `Person`, ainsi que le format pour un attribut spécifique de `Person` (`age`).

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
          # Remplace le format pour tous les attributs de Person :
          format: "Invalid %{attribute} (%{message})"
          attributes:
            age:
              # Remplace le format pour l'attribut age :
              format: "%{message}"
              blank: "Veuillez remplir votre %{attribute}"
```

```irb
irb> person = Person.new.tap(&:valid?)

irb> person.errors.full_messages
=> [
  "Invalid Name (can’t be blank)",
  "Veuillez remplir votre Age"
]

irb> person.errors.messages
=> {
  :name => ["can’t be blank"],
  :age  => ["Veuillez remplir votre Age"]
}
```


### Configuration de Active Record

`config.active_record` inclut une variété d'options de configuration :

#### `config.active_record.logger`

Accepte un journal conforme à l'interface de Log4r ou de la classe de journalisation Ruby par défaut, qui est ensuite transmis à toutes les nouvelles connexions à la base de données. Vous pouvez récupérer ce journal en appelant `logger` sur une classe de modèle Active Record ou sur une instance de modèle Active Record. Définissez-le sur `nil` pour désactiver la journalisation.

#### `config.active_record.primary_key_prefix_type`

Vous permet d'ajuster la dénomination des colonnes de clé primaire. Par défaut, Rails suppose que les colonnes de clé primaire sont nommées `id` (et cette option de configuration n'a pas besoin d'être définie). Il existe deux autres choix :

* `:table_name` ferait de la clé primaire de la classe Customer `customerid`.
* `:table_name_with_underscore` ferait de la clé primaire de la classe Customer `customer_id`.

#### `config.active_record.table_name_prefix`

Vous permet de définir une chaîne globale à préfixer aux noms de table. Si vous définissez cela sur `northwest_`, alors la classe Customer recherchera `northwest_customers` comme sa table. Par défaut, c'est une chaîne vide.

#### `config.active_record.table_name_suffix`

Vous permet de définir une chaîne globale à ajouter aux noms de table. Si vous définissez cela sur `_northwest`, alors la classe Customer recherchera `customers_northwest` comme sa table. Par défaut, c'est une chaîne vide.

#### `config.active_record.schema_migrations_table_name`

Vous permet de définir une chaîne à utiliser comme nom de la table des migrations de schéma.

#### `config.active_record.internal_metadata_table_name`

Vous permet de définir une chaîne à utiliser comme nom de la table des métadonnées internes.

#### `config.active_record.protected_environments`

Vous permet de définir un tableau de noms d'environnements où les actions destructrices doivent être interdites.
#### `config.active_record.pluralize_table_names`

Spécifie si Rails recherchera des noms de tables au singulier ou au pluriel dans la base de données. Si défini sur `true` (par défaut), alors la classe Customer utilisera la table `customers`. Si défini sur `false`, alors la classe Customer utilisera la table `customer`.

#### `config.active_record.default_timezone`

Détermine s'il faut utiliser `Time.local` (si défini sur `:local`) ou `Time.utc` (si défini sur `:utc`) lors de la récupération des dates et heures depuis la base de données. La valeur par défaut est `:utc`.

#### `config.active_record.schema_format`

Contrôle le format pour la sauvegarde du schéma de la base de données dans un fichier. Les options sont `:ruby` (par défaut) pour une version indépendante de la base de données qui dépend des migrations, ou `:sql` pour un ensemble de déclarations SQL (potentiellement dépendantes de la base de données).

#### `config.active_record.error_on_ignored_order`

Spécifie si une erreur doit être levée si l'ordre d'une requête est ignoré lors d'une requête en lot. Les options sont `true` (lever une erreur) ou `false` (avertir). La valeur par défaut est `false`.

#### `config.active_record.timestamped_migrations`

Contrôle si les migrations sont numérotées avec des entiers séquentiels ou avec des horodatages. La valeur par défaut est `true`, pour utiliser les horodatages, qui sont préférés s'il y a plusieurs développeurs travaillant sur la même application.

#### `config.active_record.db_warnings_action`

Contrôle l'action à effectuer lorsqu'une requête SQL produit un avertissement. Les options suivantes sont disponibles :

  * `:ignore` - Les avertissements de la base de données seront ignorés. C'est la valeur par défaut.

  * `:log` - Les avertissements de la base de données seront enregistrés via `ActiveRecord.logger` au niveau `:warn`.

  * `:raise` - Les avertissements de la base de données seront levés en tant que `ActiveRecord::SQLWarning`.

  * `:report` - Les avertissements de la base de données seront signalés aux abonnés du rapporteur d'erreurs de Rails.

  * Proc personnalisé - Un proc personnalisé peut être fourni. Il doit accepter un objet d'erreur `SQLWarning`.

    Par exemple :

    ```ruby
    config.active_record.db_warnings_action = ->(warning) do
      # Signaler à un service de rapport d'erreurs personnalisé
      Bugsnag.notify(warning.message) do |notification|
        notification.add_metadata(:warning_code, warning.code)
        notification.add_metadata(:warning_level, warning.level)
      end
    end
    ```

#### `config.active_record.db_warnings_ignore`

Spécifie une liste blanche de codes et de messages d'avertissement qui seront ignorés, quelle que soit l'action `db_warnings_action` configurée. Le comportement par défaut est de signaler tous les avertissements. Les avertissements à ignorer peuvent être spécifiés sous forme de chaînes de caractères ou d'expressions régulières. Par exemple :

  ```ruby
  config.active_record.db_warnings_action = :raise
  # Les avertissements suivants ne seront pas levés
  config.active_record.db_warnings_ignore = [
    /Invalid utf8mb4 character string/,
    "Un message d'avertissement exact",
    "1062", # Erreur MySQL 1062 : Entrée en double
  ]
  ```

#### `config.active_record.migration_strategy`

Contrôle la classe de stratégie utilisée pour exécuter les méthodes de déclaration de schéma dans une migration. La classe par défaut délègue à l'adaptateur de connexion. Les stratégies personnalisées doivent hériter de `ActiveRecord::Migration::ExecutionStrategy`,
ou peuvent hériter de `DefaultStrategy`, qui préservera le comportement par défaut pour les méthodes qui ne sont pas implémentées :

```ruby
class CustomMigrationStrategy < ActiveRecord::Migration::DefaultStrategy
  def drop_table(*)
    raise "La suppression de tables n'est pas prise en charge !"
  end
end

config.active_record.migration_strategy = CustomMigrationStrategy
```

#### `config.active_record.lock_optimistically`

Contrôle si Active Record utilisera le verrouillage optimiste et est défini sur `true` par défaut.

#### `config.active_record.cache_timestamp_format`

Contrôle le format de la valeur de l'horodatage dans la clé de cache. La valeur par défaut est `:usec`.

#### `config.active_record.record_timestamps`

Est une valeur booléenne qui contrôle si le marquage temporel des opérations `create` et `update` sur un modèle se produit ou non. La valeur par défaut est `true`.

#### `config.active_record.partial_inserts`

Est une valeur booléenne et contrôle si des écritures partielles sont utilisées lors de la création de nouveaux enregistrements (c'est-à-dire si les insertions ne définissent que les attributs différents de la valeur par défaut).

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `true`               |
| 7.0                   | `false`              |

#### `config.active_record.partial_updates`

Est une valeur booléenne et contrôle si des écritures partielles sont utilisées lors de la mise à jour d'enregistrements existants (c'est-à-dire si les mises à jour ne définissent que les attributs modifiés). Notez que lors de l'utilisation de mises à jour partielles, vous devez également utiliser le verrouillage optimiste `config.active_record.lock_optimistically`, car des mises à jour concurrentes peuvent écrire des attributs basés sur un état de lecture potentiellement obsolète. La valeur par défaut est `true`.

#### `config.active_record.maintain_test_schema`

Est une valeur booléenne qui contrôle si Active Record doit essayer de maintenir le schéma de votre base de données de test à jour avec `db/schema.rb` (ou `db/structure.sql`) lorsque vous exécutez vos tests. La valeur par défaut est `true`.

#### `config.active_record.dump_schema_after_migration`

Est un indicateur qui contrôle si la sauvegarde du schéma doit être effectuée (`db/schema.rb` ou `db/structure.sql`) lorsque vous exécutez des migrations. Cela est défini sur `false` dans `config/environments/production.rb` qui est généré par Rails. La valeur par défaut est `true` si cette configuration n'est pas définie.

#### `config.active_record.dump_schemas`

Contrôle les schémas de base de données qui seront sauvegardés lors de l'appel à `db:schema:dump`.
Les options sont `:schema_search_path` (par défaut) qui sauvegarde tous les schémas répertoriés dans `schema_search_path`,
`:all` qui sauvegarde toujours tous les schémas indépendamment de `schema_search_path`,
ou une chaîne de schémas séparés par des virgules.
#### `config.active_record.before_committed_on_all_records`

Activez les rappels before_committed! sur tous les enregistrements inscrits dans une transaction.
Le comportement précédent était d'exécuter les rappels uniquement sur la première copie d'un enregistrement
s'il y avait plusieurs copies du même enregistrement inscrites dans la transaction.

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.belongs_to_required_by_default`

Est une valeur booléenne et contrôle si un enregistrement échoue à la validation si
l'association `belongs_to` n'est pas présente.

La valeur par défaut dépend de la version cible de `config.load_defaults`:

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `nil`                |
| 5.0                   | `true`               |

#### `config.active_record.belongs_to_required_validates_foreign_key`

Active la validation uniquement des colonnes liées au parent pour la présence lorsque le parent est obligatoire.
Le comportement précédent était de valider la présence de l'enregistrement parent, ce qui effectuait une requête supplémentaire
pour obtenir le parent à chaque fois que l'enregistrement enfant était mis à jour, même lorsque le parent n'avait pas changé.

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.marshalling_format_version`

Lorsqu'il est défini sur `7.1`, permet une sérialisation plus efficace de l'instance Active Record avec `Marshal.dump`.

Cela modifie le format de sérialisation, donc les modèles sérialisés de cette
manière ne peuvent pas être lus par les anciennes versions de Rails (< 7.1). Cependant, les messages qui
utilisent l'ancien format peuvent toujours être lus, indépendamment de l'activation ou non de cette optimisation.

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `6.1`                |
| 7.1                   | `7.1`                |

#### `config.active_record.action_on_strict_loading_violation`

Active le déclenchement ou l'enregistrement d'une exception si strict_loading est défini sur une
association. La valeur par défaut est `:raise` dans tous les environnements. Elle peut être
modifiée en `:log` pour envoyer les violations au journal au lieu de les déclencher.

#### `config.active_record.strict_loading_by_default`

Est une valeur booléenne qui active ou désactive le mode strict_loading par
défaut. Par défaut, il est défini sur `false`.

#### `config.active_record.warn_on_records_fetched_greater_than`

Permet de définir un seuil d'avertissement pour la taille du résultat de la requête. Si le nombre de
enregistrements retournés par une requête dépasse le seuil, un avertissement est enregistré. Cela
peut être utilisé pour identifier les requêtes qui pourraient causer une surcharge mémoire.

#### `config.active_record.index_nested_attribute_errors`

Permet d'afficher les erreurs pour les relations `has_many` imbriquées avec un index
ainsi que l'erreur. Par défaut, cette option est définie sur `false`.

#### `config.active_record.use_schema_cache_dump`

Permet aux utilisateurs d'obtenir les informations du cache de schéma à partir de `db/schema_cache.yml`
(généré par `bin/rails db:schema:cache:dump`), au lieu d'envoyer une
requête à la base de données pour obtenir ces informations. Par défaut, cette option est définie sur `true`.

#### `config.active_record.cache_versioning`

Indique s'il faut utiliser une méthode `#cache_key` stable accompagnée d'une
version changeante dans la méthode `#cache_version`.

La valeur par défaut dépend de la version cible de `config.load_defaults`:

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 5.2                   | `true`               |

#### `config.active_record.collection_cache_versioning`

Permet de réutiliser la même clé de cache lorsque l'objet de type
`ActiveRecord::Relation` qui est mis en cache change en déplaçant les informations volatiles (mise à jour maximale
et comptage) de la clé de cache de la relation dans la version du cache pour
prendre en charge le recyclage de la clé de cache.

La valeur par défaut dépend de la version cible de `config.load_defaults`:

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 6.0                   | `true`               |

#### `config.active_record.has_many_inversing`

Permet de définir l'enregistrement inverse lors du parcours des associations `belongs_to` vers `has_many`.

La valeur par défaut dépend de la version cible de `config.load_defaults`:

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 6.1                   | `true`               |

#### `config.active_record.automatic_scope_inversing`

Permet de déduire automatiquement `inverse_of` pour les associations avec une portée.

La valeur par défaut dépend de la version cible de `config.load_defaults`:

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.0                   | `true`               |

#### `config.active_record.destroy_association_async_job`

Permet de spécifier le job qui sera utilisé pour détruire les enregistrements associés en arrière-plan. Par défaut, il est défini sur `ActiveRecord::DestroyAssociationAsyncJob`.

#### `config.active_record.destroy_association_async_batch_size`

Permet de spécifier le nombre maximum d'enregistrements qui seront détruits dans un job en arrière-plan par l'option d'association `dependent: :destroy_async`. Tout le reste étant égal, une taille de lot plus petite permettra d'ajouter plus de jobs en file d'attente, de durée plus courte, tandis qu'une taille de lot plus grande permettra d'ajouter moins de jobs, de durée plus longue. Cette option est définie par défaut sur `nil`, ce qui entraînera la destruction de tous les enregistrements dépendants pour une association donnée dans le même job en arrière-plan.
#### `config.active_record.queues.destroy`

Permet de spécifier la file d'attente Active Job à utiliser pour les jobs de destruction. Lorsque cette option est `nil`, les jobs de purge sont envoyés à la file d'attente Active Job par défaut (voir `config.active_job.default_queue_name`). La valeur par défaut est `nil`.

#### `config.active_record.enumerate_columns_in_select_statements`

Lorsque cette option est `true`, les noms de colonnes sont toujours inclus dans les instructions `SELECT`, évitant ainsi les requêtes `SELECT * FROM ...` avec un joker. Cela permet d'éviter les erreurs de cache des instructions préparées lors de l'ajout de colonnes à une base de données PostgreSQL, par exemple. La valeur par défaut est `false`.

#### `config.active_record.verify_foreign_keys_for_fixtures`

Vérifie que toutes les contraintes de clé étrangère sont valides après le chargement des fixtures dans les tests. Pris en charge uniquement par PostgreSQL et SQLite.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 7.0                   | `true`               |

#### `config.active_record.raise_on_assign_to_attr_readonly`

Active le déclenchement d'une exception lors de l'assignation à des attributs en lecture seule (`attr_readonly`). Le comportement précédent permettait l'assignation mais ne persistait pas les modifications dans la base de données.

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`

Lorsque plusieurs instances Active Record modifient le même enregistrement dans une transaction, Rails exécute les rappels `after_commit` ou `after_rollback` pour une seule d'entre elles. Cette option spécifie comment Rails choisit quelle instance reçoit les rappels.

Lorsque cette option est `true`, les rappels transactionnels sont exécutés sur la première instance à être enregistrée, même si son état d'instance peut être obsolète.

Lorsque cette option est `false`, les rappels transactionnels sont exécutés sur les instances ayant l'état d'instance le plus récent. Ces instances sont choisies comme suit :

- En général, les rappels transactionnels sont exécutés sur la dernière instance à enregistrer un enregistrement donné dans la transaction.
- Il existe deux exceptions :
    - Si l'enregistrement est créé dans la transaction, puis mis à jour par une autre instance, les rappels `after_create_commit` seront exécutés sur la deuxième instance. Cela remplace les rappels `after_update_commit` qui seraient naïvement exécutés en fonction de l'état de cette instance.
    - Si l'enregistrement est détruit dans la transaction, les rappels `after_destroy_commit` seront déclenchés sur la dernière instance détruite, même si une instance obsolète effectue ultérieurement une mise à jour (qui n'aura affecté aucun enregistrement).

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.default_column_serializer`

L'implémentation du sérialiseur à utiliser si aucune n'est spécifiée explicitement pour une colonne donnée.

Historiquement, lors de l'utilisation de `serialize` et `store`, une implémentation alternative du sérialiseur pouvait être utilisée, mais par défaut, c'était `YAML`, qui n'est pas un format très efficace et peut être source de vulnérabilités de sécurité s'il n'est pas utilisé avec précaution.

Il est donc recommandé de préférer des formats plus stricts et plus limités pour la sérialisation en base de données.

Malheureusement, il n'y a pas vraiment de valeurs par défaut adaptées disponibles dans la bibliothèque standard de Ruby. `JSON` pourrait fonctionner comme format, mais les gemmes `json` convertissent les types non pris en charge en chaînes, ce qui peut entraîner des bugs.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `YAML`               |
| 7.1                   | `nil`                |

#### `config.active_record.run_after_transaction_callbacks_in_order_defined`

Si cette option est `true`, les rappels `after_commit` sont exécutés dans l'ordre dans lequel ils sont définis dans un modèle. Si elle est `false`, ils sont exécutés dans l'ordre inverse.

Tous les autres rappels sont toujours exécutés dans l'ordre dans lequel ils sont définis dans un modèle (sauf si vous utilisez `prepend: true`).

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.query_log_tags_enabled`

Indique si les commentaires de requête au niveau de l'adaptateur doivent être activés ou non. La valeur par défaut est `false`.

REMARQUE : Lorsque cette option est définie sur `true`, les instructions préparées de la base de données seront automatiquement désactivées.

#### `config.active_record.query_log_tags`

Définit un `Array` spécifiant les balises clé/valeur à insérer dans un commentaire SQL. La valeur par défaut est `[ :application ]`, une balise prédéfinie renvoyant le nom de l'application.

#### `config.active_record.query_log_tags_format`

Un `Symbol` spécifiant le formatteur à utiliser pour les balises. Les valeurs valides sont `:sqlcommenter` et `:legacy`.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `:legacy`            |
| 7.1                   | `:sqlcommenter`      |
#### `config.active_record.cache_query_log_tags`

Spécifie si la mise en cache des balises de journal de requête doit être activée ou non. Pour les applications qui effectuent un grand nombre de requêtes, la mise en cache des balises de journal de requête peut offrir un avantage en termes de performances lorsque le contexte ne change pas pendant la durée de la requête ou de l'exécution de la tâche. Par défaut, la valeur est `false`.

#### `config.active_record.schema_cache_ignored_tables`

Définit la liste des tables qui doivent être ignorées lors de la génération du cache de schéma. Elle accepte un `Array` de chaînes de caractères représentant les noms des tables, ou des expressions régulières.

#### `config.active_record.verbose_query_logs`

Spécifie si les emplacements sources des méthodes appelant des requêtes à la base de données doivent être journalisés sous les requêtes pertinentes. Par défaut, le drapeau est `true` en développement et `false` dans tous les autres environnements.

#### `config.active_record.sqlite3_adapter_strict_strings_by_default`

Spécifie si l'adaptateur SQLite3 doit être utilisé en mode strict pour les chaînes de caractères. L'utilisation d'un mode strict pour les chaînes de caractères désactive les littéraux de chaînes de caractères entre guillemets doubles.

SQLite a quelques particularités concernant les littéraux de chaînes de caractères entre guillemets doubles. Il essaie d'abord de considérer les chaînes de caractères entre guillemets doubles comme des noms d'identifiants, mais s'ils n'existent pas, il les considère alors comme des littéraux de chaînes de caractères. En raison de cela, les erreurs de frappe peuvent passer inaperçues. Par exemple, il est possible de créer un index pour une colonne qui n'existe pas. Consultez la [documentation SQLite](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted) pour plus de détails.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.async_query_executor`

Spécifie comment les requêtes asynchrones sont regroupées.

La valeur par défaut est `nil`, ce qui signifie que `load_async` est désactivé et que les requêtes sont exécutées directement en premier plan.
Pour que les requêtes soient réellement exécutées de manière asynchrone, il doit être défini sur `:global_thread_pool` ou `:multi_thread_pool`.

`:global_thread_pool` utilisera un seul pool pour toutes les bases de données auxquelles l'application se connecte. C'est la configuration recommandée pour les applications n'ayant qu'une seule base de données, ou les applications qui ne consultent qu'un seul fragment de base de données à la fois.

`:multi_thread_pool` utilisera un pool par base de données, et chaque taille de pool peut être configurée individuellement dans `database.yml` via les propriétés `max_threads` et `min_thread`. Cela peut être utile pour les applications qui consultent régulièrement plusieurs bases de données en même temps et qui ont besoin de définir plus précisément la concurrence maximale.

#### `config.active_record.global_executor_concurrency`

Utilisé en conjonction avec `config.active_record.async_query_executor = :global_thread_pool`, définit combien de requêtes asynchrones peuvent être exécutées simultanément.

La valeur par défaut est `4`.

Ce nombre doit être pris en compte en fonction de la taille du pool de connexions configuré dans `database.yml`. Le pool de connexions doit être suffisamment grand pour accueillir à la fois les threads en premier plan (par exemple, les threads du serveur web ou du travailleur de tâches) et les threads en arrière-plan.

#### `config.active_record.allow_deprecated_singular_associations_name`

Cela active le comportement déprécié selon lequel les associations singulières peuvent être référencées par leur nom pluriel dans les clauses `where`. Le paramètre `false` améliore les performances.

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end

Comment.where(post: post_id).count  # => 5

# Lorsque `allow_deprecated_singular_associations_name` est true :
Comment.where(posts: post_id).count # => 5 (avertissement de dépréciation)

# Lorsque `allow_deprecated_singular_associations_name` est false :
Comment.where(posts: post_id).count # => erreur
```

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.yaml_column_permitted_classes`

La valeur par défaut est `[Symbol]`. Permet aux applications d'inclure des classes supplémentaires autorisées pour `safe_load()` sur `ActiveRecord::Coders::YAMLColumn`.

#### `config.active_record.use_yaml_unsafe_load`

La valeur par défaut est `false`. Permet aux applications d'opter pour l'utilisation de `unsafe_load` sur `ActiveRecord::Coders::YAMLColumn`.

#### `config.active_record.raise_int_wider_than_64bit`

La valeur par défaut est `true`. Détermine s'il faut lever une exception ou non lorsque l'adaptateur PostgreSQL reçoit un entier plus large que la représentation signée sur 64 bits.

#### `ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans` et `ActiveRecord::ConnectionAdapters::TrilogyAdapter.emulate_booleans`

Contrôle si l'adaptateur MySQL d'Active Record considère toutes les colonnes `tinyint(1)` comme des booléens. La valeur par défaut est `true`.

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.create_unlogged_tables`

Contrôle si les tables de base de données créées par PostgreSQL doivent être "non journalisées", ce qui peut accélérer les performances mais augmente le risque de perte de données en cas de panne de la base de données. Il est fortement recommandé de ne pas activer cette option en environnement de production. La valeur par défaut est `false` dans tous les environnements.

Pour activer cela pour les tests :

```ruby
# config/environments/test.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.create_unlogged_tables = true
end
```

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type`

Contrôle le type natif que l'adaptateur PostgreSQL d'Active Record doit utiliser lorsque vous appelez `datetime` dans une migration ou un schéma. Il prend un symbole qui doit correspondre à l'un des `NATIVE_DATABASE_TYPES` configurés. La valeur par défaut est `:timestamp`, ce qui signifie que `t.datetime` dans une migration créera une colonne "timestamp without time zone".
Pour utiliser "timestamp with time zone":

```ruby
# config/application.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.datetime_type = :timestamptz
end
```

Vous devez exécuter `bin/rails db:migrate` pour reconstruire votre schema.rb si vous modifiez cela.

#### `ActiveRecord::SchemaDumper.ignore_tables`

Accepte un tableau de tables qui ne doivent _pas_ être incluses dans un fichier de schéma généré.

#### `ActiveRecord::SchemaDumper.fk_ignore_pattern`

Permet de définir une expression régulière différente qui sera utilisée pour décider si le nom d'une clé étrangère doit être exporté vers db/schema.rb ou non. Par défaut, les noms de clés étrangères commençant par `fk_rails_` ne sont pas exportés vers le schéma de la base de données. Par défaut, `/^fk_rails_[0-9a-f]{10}$/`.

#### `config.active_record.encryption.hash_digest_class`

Définit l'algorithme de hachage utilisé par Active Record Encryption.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

 | À partir de la version | La valeur par défaut est |
 |-----------------------|---------------------------|
 | (originale)            | `OpenSSL::Digest::SHA1`   |
 | 7.1                   | `OpenSSL::Digest::SHA256` |

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

Active la prise en charge du déchiffrement des données existantes chiffrées à l'aide d'une classe de hachage SHA-1. Lorsque `false`,
il ne prendra en charge que le hachage configuré dans `config.active_record.encryption.hash_digest_class`.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

 | À partir de la version | La valeur par défaut est |
 |-----------------------|----------------------|
 | (originale)            | `true`               |
 | 7.1                   | `false`              |

### Configuration de Action Controller

`config.action_controller` inclut un certain nombre de paramètres de configuration :

#### `config.action_controller.asset_host`

Définit l'hôte pour les ressources. Utile lorsque des CDN sont utilisés pour héberger les ressources plutôt que le serveur d'application lui-même. Vous ne devriez utiliser cela que si vous avez une configuration différente pour Action Mailer, sinon utilisez `config.asset_host`.

#### `config.action_controller.perform_caching`

Configure si l'application doit utiliser les fonctionnalités de mise en cache fournies par le composant Action Controller ou non. Défini sur `false` dans l'environnement de développement, `true` en production. Si ce n'est pas spécifié, la valeur par défaut sera `true`.

#### `config.action_controller.default_static_extension`

Configure l'extension utilisée pour les pages mises en cache. Par défaut, `.html`.

#### `config.action_controller.include_all_helpers`

Configure si tous les helpers de vue sont disponibles partout ou sont limités au contrôleur correspondant. Si défini sur `false`, les méthodes de `UsersHelper` ne sont disponibles que pour les vues rendues dans le cadre de `UsersController`. Si `true`, les méthodes de `UsersHelper` sont disponibles partout. Le comportement de configuration par défaut (lorsque cette option n'est pas explicitement définie sur `true` ou `false`) est que tous les helpers de vue sont disponibles pour chaque contrôleur.

#### `config.action_controller.logger`

Accepte un logger conforme à l'interface de Log4r ou à la classe de journalisation Ruby par défaut, qui est ensuite utilisé pour enregistrer des informations depuis Action Controller. Défini sur `nil` pour désactiver l'enregistrement.

#### `config.action_controller.request_forgery_protection_token`

Définit le nom du paramètre de jeton pour RequestForgery. L'appel à `protect_from_forgery` le définit par défaut sur `:authenticity_token`.

#### `config.action_controller.allow_forgery_protection`

Active ou désactive la protection CSRF. Par défaut, cela est `false` dans l'environnement de test et `true` dans tous les autres environnements.

#### `config.action_controller.forgery_protection_origin_check`

Configure si l'en-tête HTTP `Origin` doit être vérifié par rapport à l'origine du site en tant que défense CSRF supplémentaire.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 5.0                   | `true`               |

#### `config.action_controller.per_form_csrf_tokens`

Configure si les jetons CSRF ne sont valides que pour la méthode/action pour laquelle ils ont été générés.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 5.0                   | `true`               |

#### `config.action_controller.default_protect_from_forgery`

Détermine si la protection contre les falsifications est ajoutée sur `ActionController::Base`.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 5.2                   | `true`               |

#### `config.action_controller.relative_url_root`

Peut être utilisé pour indiquer à Rails que vous déployez dans un sous-répertoire (
configuring.html#deploy-to-a-subdirectory-relative-url-root). La valeur par défaut est
[`config.relative_url_root`](#config-relative-url-root).

#### `config.action_controller.permit_all_parameters`

Définit tous les paramètres pour l'attribution en masse comme étant autorisés par défaut. La valeur par défaut est `false`.

#### `config.action_controller.action_on_unpermitted_parameters`

Contrôle le comportement lorsque des paramètres qui ne sont pas explicitement autorisés sont trouvés. La valeur par défaut est `:log` dans les environnements de test et de développement, `false` sinon. Les valeurs possibles sont :

* `false` pour ne prendre aucune action
* `:log` pour émettre un événement `ActiveSupport::Notifications.instrument` sur le sujet `unpermitted_parameters.action_controller` et enregistrer au niveau DEBUG
* `:raise` pour lever une exception `ActionController::UnpermittedParameters`

#### `config.action_controller.always_permitted_parameters`

Définit une liste de paramètres autorisés par défaut. Les valeurs par défaut sont `['controller', 'action']`.

#### `config.action_controller.enable_fragment_cache_logging`

Détermine si les lectures et écritures de cache fragment doivent être journalisées de manière détaillée, comme suit :
```
Lire le fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/d0bdf2974e1ef6d31685c3b392ad0b74 (0.6ms)
Rendu messages/_message.html.erb en 1.2 ms [cache hit]
Écrire le fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/3b4e249ac9d168c617e32e84b99218b5 (1.1ms)
Rendu recordings/threads/_thread.html.erb en 1.5 ms [cache miss]
```

Par défaut, il est réglé sur `false`, ce qui donne la sortie suivante :

```
Rendu messages/_message.html.erb en 1.2 ms [cache hit]
Rendu recordings/threads/_thread.html.erb en 1.5 ms [cache miss]
```

#### `config.action_controller.raise_on_open_redirects`

Lève une `ActionController::Redirecting::UnsafeRedirectError` lorsqu'une redirection ouverte non autorisée se produit.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.0                   | `true`               |

#### `config.action_controller.log_query_tags_around_actions`

Détermine si le contexte du contrôleur pour les balises de requête sera automatiquement mis à jour via un `around_filter`. La valeur par défaut est `true`.

#### `config.action_controller.wrap_parameters_by_default`

Configure le [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html) pour envelopper par défaut les requêtes json.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 7.0                   | `true`               |

#### `ActionController::Base.wrap_parameters`

Configure le [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html). Cela peut être appelé au niveau supérieur ou sur des contrôleurs individuels.

#### `config.action_controller.allow_deprecated_parameters_hash_equality`

Contrôle le comportement de `ActionController::Parameters#==` avec des arguments `Hash`. La valeur du paramètre détermine si une instance de `ActionController::Parameters` est égale à un `Hash` équivalent.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `true`               |
| 7.1                   | `false`              |

### Configuration de Action Dispatch

#### `config.action_dispatch.cookies_serializer`

Spécifie quel sérialiseur utiliser pour les cookies. Accepte les mêmes valeurs que [`config.active_support.message_serializer`](#config-active-support-message-serializer), plus `:hybrid` qui est un alias pour `:json_allow_marshal`.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `:marshal`           |
| 7.0                   | `:json`              |

#### `config.action_dispatch.debug_exception_log_level`

Configure le niveau de journalisation utilisé par le middleware DebugExceptions lors de la journalisation des exceptions non capturées pendant les requêtes.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `:fatal`             |
| 7.1                   | `:error`             |

#### `config.action_dispatch.default_headers`

Est un hash avec les en-têtes HTTP qui sont définis par défaut dans chaque réponse.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "1; mode=block",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.0                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.1                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |

#### `config.action_dispatch.default_charset`

Spécifie l'ensemble de caractères par défaut pour tous les rendus. Par défaut, il est défini sur `nil`.

#### `config.action_dispatch.tld_length`

Définit la longueur du domaine de premier niveau (TLD) pour l'application. Par défaut, il est défini sur `1`.

#### `config.action_dispatch.ignore_accept_header`

Est utilisé pour déterminer s'il faut ignorer les en-têtes accept de la requête. Par défaut, il est défini sur `false`.

#### `config.action_dispatch.x_sendfile_header`

Spécifie l'en-tête X-Sendfile spécifique au serveur. Cela est utile pour l'envoi de fichiers accéléré à partir du serveur. Par exemple, il peut être défini sur 'X-Sendfile' pour Apache.

#### `config.action_dispatch.http_auth_salt`

Définit la valeur du sel d'authentification HTTP. Par défaut, il est défini sur `'http authentication'`.

#### `config.action_dispatch.signed_cookie_salt`

Définit la valeur du sel des cookies signés. Par défaut, il est défini sur `'signed cookie'`.

#### `config.action_dispatch.encrypted_cookie_salt`

Définit la valeur du sel des cookies chiffrés. Par défaut, il est défini sur `'encrypted cookie'`.

#### `config.action_dispatch.encrypted_signed_cookie_salt`

Définit la valeur du sel des cookies signés et chiffrés. Par défaut, il est défini sur `'signed encrypted cookie'`.

#### `config.action_dispatch.authenticated_encrypted_cookie_salt`

Définit le sel des cookies chiffrés et authentifiés. Par défaut, il est défini sur `'authenticated encrypted cookie'`.

#### `config.action_dispatch.encrypted_cookie_cipher`

Définit le chiffre à utiliser pour les cookies chiffrés. Par défaut, il est défini sur `"aes-256-gcm"`.

#### `config.action_dispatch.signed_cookie_digest`

Définit le hachage à utiliser pour les cookies signés. Par défaut, il est défini sur `"SHA1"`.

#### `config.action_dispatch.cookies_rotations`

Permet de faire tourner les secrets, les chiffres et les hachages pour les cookies chiffrés et signés.

#### `config.action_dispatch.use_authenticated_cookie_encryption`

Contrôle si les cookies signés et chiffrés utilisent le chiffre AES-256-GCM ou l'ancien chiffre AES-256-CBC.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 5.2                   | `true`               |

#### `config.action_dispatch.use_cookies_with_metadata`

Permet d'écrire des cookies avec les métadonnées de but intégrées.

La valeur par défaut dépend de la version cible de `config.load_defaults` :
| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 6.0                   | `true`               |

#### `config.action_dispatch.perform_deep_munge`

Configure si la méthode `deep_munge` doit être exécutée sur les paramètres.
Voir [Guide de sécurité](security.html#unsafe-query-generation) pour plus
d'informations. La valeur par défaut est `true`.

#### `config.action_dispatch.rescue_responses`

Configure les exceptions assignées à un statut HTTP. Il accepte un hash et vous pouvez spécifier des paires exception/statut. Par défaut, cela est défini comme suit:

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

Toutes les exceptions qui ne sont pas configurées seront mappées sur l'erreur interne du serveur 500.

#### `config.action_dispatch.cookies_same_site_protection`

Configure la valeur par défaut de l'attribut `SameSite` lors de la définition des cookies.
Lorsqu'il est défini sur `nil`, l'attribut `SameSite` n'est pas ajouté. Pour permettre à la valeur de l'attribut `SameSite` d'être configurée dynamiquement en fonction de la requête, une procédure peut être spécifiée. Par exemple:

```ruby
config.action_dispatch.cookies_same_site_protection = ->(request) do
  :strict unless request.user_agent == "TestAgent"
end
```

La valeur par défaut dépend de la version cible de `config.load_defaults`:

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `nil`                |
| 6.1                   | `:lax`               |

#### `config.action_dispatch.ssl_default_redirect_status`

Configure le code de statut HTTP par défaut utilisé lors de la redirection des requêtes non-GET/HEAD de HTTP vers HTTPS dans le middleware `ActionDispatch::SSL`.

La valeur par défaut dépend de la version cible de `config.load_defaults`:

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `307`                |
| 6.1                   | `308`                |

#### `config.action_dispatch.log_rescued_responses`

Active la journalisation des exceptions non gérées configurées dans `rescue_responses`. La valeur par défaut est `true`.

#### `ActionDispatch::Callbacks.before`

Prend un bloc de code à exécuter avant la requête.

#### `ActionDispatch::Callbacks.after`

Prend un bloc de code à exécuter après la requête.

### Configuration de Action View

`config.action_view` inclut un petit nombre de paramètres de configuration:

#### `config.action_view.cache_template_loading`

Contrôle si les modèles doivent être rechargés à chaque requête ou non. Par défaut, c'est `!config.enable_reloading`.

#### `config.action_view.field_error_proc`

Fournit un générateur HTML pour afficher les erreurs provenant d'Active Model. Le bloc est évalué dans le contexte d'un modèle Action View. La valeur par défaut est

```ruby
Proc.new { |html_tag, instance| content_tag :div, html_tag, class: "field_with_errors" }
```

#### `config.action_view.default_form_builder`

Indique à Rails quel constructeur de formulaire utiliser par défaut. La valeur par défaut est
`ActionView::Helpers::FormBuilder`. Si vous souhaitez que votre classe de constructeur de formulaire soit
chargée après l'initialisation (afin qu'elle soit rechargée à chaque requête en développement),
vous pouvez la passer en tant que `String`.

#### `config.action_view.logger`

Accepte un journal conforme à l'interface de Log4r ou de la classe de journalisation Ruby par défaut, qui est ensuite utilisé pour enregistrer des informations depuis Action View. Définissez-le sur `nil` pour désactiver la journalisation.

#### `config.action_view.erb_trim_mode`

Donne le mode de suppression à utiliser par ERB. Par défaut, il est `'-'`, ce qui active la suppression des espaces de fin et des sauts de ligne lors de l'utilisation de `<%= -%>` ou `<%= =%>`. Voir la [documentation Erubis](http://www.kuwata-lab.com/erubis/users-guide.06.html#topics-trimspaces) pour plus d'informations.

#### `config.action_view.frozen_string_literal`

Compile le modèle ERB avec le commentaire magique `# frozen_string_literal: true`, rendant toutes les chaînes de caractères gelées et économisant les allocations. Définissez-le sur `true` pour l'activer pour toutes les vues.

#### `config.action_view.embed_authenticity_token_in_remote_forms`

Vous permet de définir le comportement par défaut de `authenticity_token` dans les formulaires avec
`remote: true`. Par défaut, il est défini sur `false`, ce qui signifie que les formulaires distants
n'incluront pas `authenticity_token`, ce qui est utile lorsque vous mettez en cache fragment le formulaire. Les formulaires distants obtiennent l'authenticité à partir de la balise `meta`,
donc l'incorporation est inutile à moins que vous ne preniez en charge les navigateurs sans
JavaScript. Dans ce cas, vous pouvez soit passer `authenticity_token: true` en tant que
option de formulaire, soit définir ce paramètre de configuration sur `true`.

#### `config.action_view.prefix_partial_path_with_controller_namespace`

Détermine si les partiels sont recherchés dans un sous-répertoire des modèles rendus à partir de contrôleurs avec des espaces de noms. Par exemple, considérez un contrôleur nommé `Admin::ArticlesController` qui rend ce modèle:

```erb
<%= render @article %>
```

Le paramètre par défaut est `true`, ce qui utilise le partiel à `/admin/articles/_article.erb`. Si la valeur est définie sur `false`, cela rendrait `/articles/_article.erb`, ce qui est le même comportement que le rendu à partir d'un contrôleur sans espace de noms tel que `ArticlesController`.

#### `config.action_view.automatically_disable_submit_tag`

Détermine si `submit_tag` doit être automatiquement désactivé lors du clic, cela
par défaut à `true`.
#### `config.action_view.debug_missing_translation`

Détermine s'il faut envelopper la clé des traductions manquantes dans une balise `<span>` ou non. La valeur par défaut est `true`.

#### `config.action_view.form_with_generates_remote_forms`

Détermine si `form_with` génère des formulaires distants ou non.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| 5.1                   | `true`               |
| 6.1                   | `false`              |

#### `config.action_view.form_with_generates_ids`

Détermine si `form_with` génère des identifiants sur les champs de saisie.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 5.2                   | `true`               |

#### `config.action_view.default_enforce_utf8`

Détermine si les formulaires sont générés avec une balise cachée qui force les anciennes versions d'Internet Explorer à soumettre des formulaires encodés en UTF-8.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `true`               |
| 6.0                   | `false`              |

#### `config.action_view.image_loading`

Spécifie une valeur par défaut pour l'attribut `loading` des balises `<img>` rendues par l'aide `image_tag`. Par exemple, lorsque cette valeur est définie sur `"lazy"`, les balises `<img>` rendues par `image_tag` incluront `loading="lazy"`, ce qui [indique au navigateur d'attendre que l'image soit proche du viewport pour la charger](https://html.spec.whatwg.org/#lazy-loading-attributes). (Cette valeur peut toujours être remplacée par image en passant par exemple `loading: "eager"` à `image_tag`.) La valeur par défaut est `nil`.

#### `config.action_view.image_decoding`

Spécifie une valeur par défaut pour l'attribut `decoding` des balises `<img>` rendues par l'aide `image_tag`. La valeur par défaut est `nil`.

#### `config.action_view.annotate_rendered_view_with_filenames`

Détermine s'il faut annoter la vue rendue avec les noms de fichiers de modèle. La valeur par défaut est `false`.

#### `config.action_view.preload_links_header`

Détermine si `javascript_include_tag` et `stylesheet_link_tag` généreront un en-tête `Link` qui précharge les ressources.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `nil`                |
| 6.1                   | `true`               |

#### `config.action_view.button_to_generates_button_tag`

Détermine si `button_to` rendra un élément `<button>`, indépendamment du fait que le contenu soit passé en tant que premier argument ou en tant que bloc.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 7.0                   | `true`               |

#### `config.action_view.apply_stylesheet_media_default`

Détermine si `stylesheet_link_tag` rendra `screen` comme valeur par défaut pour l'attribut `media` lorsqu'il n'est pas fourni.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `true`               |
| 7.0                   | `false`              |

#### `config.action_view.prepend_content_exfiltration_prevention`

Détermine si les aides `form_tag` et `button_to` produiront des balises HTML précédées de HTML sécurisé pour le navigateur (mais techniquement invalide) qui garantit que leur contenu ne peut pas être capturé par des balises non fermées précédentes. La valeur par défaut est `false`.

#### `config.action_view.sanitizer_vendor`

Configure l'ensemble des sanitizers HTML utilisés par Action View en définissant `ActionView::Helpers::SanitizeHelper.sanitizer_vendor`. La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est                 | Qui analyse le balisage comme |
|-----------------------|--------------------------------------|------------------------|
| (originale)            | `Rails::HTML4::Sanitizer`            | HTML4                  |
| 7.1                   | `Rails::HTML5::Sanitizer` (voir NOTE) | HTML5                  |

NOTE : `Rails::HTML5::Sanitizer` n'est pas pris en charge sur JRuby, donc sur les plates-formes JRuby, Rails utilisera `Rails::HTML4::Sanitizer` en tant que solution de repli.

### Configuration d'Action Mailbox

`config.action_mailbox` propose les options de configuration suivantes :

#### `config.action_mailbox.logger`

Contient le journal utilisé par Action Mailbox. Il accepte un journal conforme à l'interface de Log4r ou à la classe de journalisation Ruby par défaut. La valeur par défaut est `Rails.logger`.

```ruby
config.action_mailbox.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.action_mailbox.incinerate_after`

Accepte une `ActiveSupport::Duration` indiquant combien de temps après le traitement les enregistrements `ActionMailbox::InboundEmail` doivent être détruits. La valeur par défaut est `30.days`.

```ruby
# Détruire les e-mails entrants 14 jours après le traitement.
config.action_mailbox.incinerate_after = 14.days
```

#### `config.action_mailbox.queues.incineration`

Accepte un symbole indiquant la file d'attente Active Job à utiliser pour les travaux d'incinération. Lorsque cette option est `nil`, les travaux d'incinération sont envoyés à la file d'attente Active Job par défaut (voir `config.active_job.default_queue_name`).

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `:action_mailbox_incineration` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.queues.routing`

Accepte un symbole indiquant la file d'attente Active Job à utiliser pour les travaux de routage. Lorsque cette option est `nil`, les travaux de routage sont envoyés à la file d'attente Active Job par défaut (voir `config.active_job.default_queue_name`).
La valeur par défaut dépend de la version cible `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `:action_mailbox_routing` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.storage_service`

Accepte un symbole indiquant le service Active Storage à utiliser pour télécharger les e-mails. Lorsque cette option est `nil`, les e-mails sont téléchargés vers le service Active Storage par défaut (voir `config.active_storage.service`).

### Configuration d'Action Mailer

Il existe plusieurs paramètres disponibles sur `config.action_mailer` :

#### `config.action_mailer.asset_host`

Définit l'hôte pour les ressources. Utile lorsque des CDN sont utilisés pour héberger les ressources plutôt que le serveur d'application lui-même. Vous ne devriez utiliser cela que si vous avez une configuration différente pour Action Controller, sinon utilisez `config.asset_host`.

#### `config.action_mailer.logger`

Accepte un journal conforme à l'interface de Log4r ou à la classe de journalisation Ruby par défaut, qui est ensuite utilisé pour enregistrer des informations provenant d'Action Mailer. Définissez-le sur `nil` pour désactiver l'enregistrement.

#### `config.action_mailer.smtp_settings`

Permet une configuration détaillée pour la méthode de livraison `:smtp`. Il accepte un hash d'options, qui peut inclure l'une de ces options :

* `:address` - Vous permet d'utiliser un serveur de messagerie distant. Modifiez simplement sa valeur par défaut "localhost".
* `:port` - Au cas où votre serveur de messagerie ne fonctionnerait pas sur le port 25, vous pouvez le modifier.
* `:domain` - Si vous devez spécifier un domaine HELO, vous pouvez le faire ici.
* `:user_name` - Si votre serveur de messagerie nécessite une authentification, définissez le nom d'utilisateur dans ce paramètre.
* `:password` - Si votre serveur de messagerie nécessite une authentification, définissez le mot de passe dans ce paramètre.
* `:authentication` - Si votre serveur de messagerie nécessite une authentification, vous devez spécifier le type d'authentification ici. Il s'agit d'un symbole et l'un des `:plain`, `:login`, `:cram_md5`.
* `:enable_starttls` - Utilise STARTTLS lors de la connexion à votre serveur SMTP et échoue si non pris en charge. Par défaut, il est défini sur `false`.
* `:enable_starttls_auto` - Détecte si STARTTLS est activé sur votre serveur SMTP et commence à l'utiliser. Par défaut, il est défini sur `true`.
* `:openssl_verify_mode` - Lors de l'utilisation de TLS, vous pouvez définir comment OpenSSL vérifie le certificat. Cela est utile si vous devez valider un certificat auto-signé et/ou un certificat générique. Il peut s'agir de l'une des constantes de vérification OpenSSL, `:none` ou `:peer` -- ou directement de la constante `OpenSSL::SSL::VERIFY_NONE` ou `OpenSSL::SSL::VERIFY_PEER`, respectivement.
* `:ssl/:tls` - Active la connexion SMTP pour utiliser SMTP/TLS (SMTPS : connexion SMTP sur TLS directe).
* `:open_timeout` - Nombre de secondes à attendre lors de la tentative d'ouverture d'une connexion.
* `:read_timeout` - Nombre de secondes à attendre jusqu'à l'expiration d'un appel à read(2).

De plus, il est possible de passer n'importe quelle [option de configuration que `Mail::SMTP` respecte](https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/smtp.rb).

#### `config.action_mailer.smtp_timeout`

Permet de configurer à la fois les valeurs `:open_timeout` et `:read_timeout` pour la méthode de livraison `:smtp`.

La valeur par défaut dépend de la version cible `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `nil`                |
| 7.0                   | `5`                  |

#### `config.action_mailer.sendmail_settings`

Permet une configuration détaillée pour la méthode de livraison `sendmail`. Il accepte un hash d'options, qui peut inclure l'une de ces options :

* `:location` - L'emplacement de l'exécutable sendmail. Par défaut, `/usr/sbin/sendmail`.
* `:arguments` - Les arguments de la ligne de commande. Par défaut, `%w[ -i ]`.

#### `config.action_mailer.raise_delivery_errors`

Spécifie s'il faut générer une erreur si la livraison de l'e-mail ne peut pas être effectuée. Par défaut, il est défini sur `true`.

#### `config.action_mailer.delivery_method`

Définit la méthode de livraison et est par défaut `:smtp`. Consultez la [section de configuration dans le guide Action Mailer](action_mailer_basics.html#action-mailer-configuration) pour plus d'informations.

#### `config.action_mailer.perform_deliveries`

Spécifie si le courrier sera réellement livré et est `true` par défaut. Il peut être pratique de le définir sur `false` pour les tests.

#### `config.action_mailer.default_options`

Configure les options par défaut d'Action Mailer. Utilisez-le pour définir des options telles que `from` ou `reply_to` pour chaque mailer. Par défaut :

```ruby
mime_version:  "1.0",
charset:       "UTF-8",
content_type: "text/plain",
parts_order:  ["text/plain", "text/enriched", "text/html"]
```

Attribuez un hash pour définir des options supplémentaires :

```ruby
config.action_mailer.default_options = {
  from: "noreply@example.com"
}
```

#### `config.action_mailer.observers`

Enregistre les observateurs qui seront notifiés lorsque le courrier est livré.

```ruby
config.action_mailer.observers = ["MailObserver"]
```

#### `config.action_mailer.interceptors`

Enregistre les intercepteurs qui seront appelés avant l'envoi du courrier.

```ruby
config.action_mailer.interceptors = ["MailInterceptor"]
```

#### `config.action_mailer.preview_interceptors`

Enregistre les intercepteurs qui seront appelés avant la prévisualisation du courrier.

```ruby
config.action_mailer.preview_interceptors = ["MyPreviewMailInterceptor"]
```

#### `config.action_mailer.preview_paths`

Spécifie les emplacements des prévisualisations des mailers. L'ajout de chemins à cette option de configuration entraînera l'utilisation de ces chemins dans la recherche des prévisualisations des mailers.
```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

#### `config.action_mailer.show_previews`

Activer ou désactiver les aperçus des mailers. Par défaut, cela est `true` en développement.

```ruby
config.action_mailer.show_previews = false
```

#### `config.action_mailer.perform_caching`

Spécifie si les templates des mailers doivent effectuer un cache fragment ou non. Si cela n'est pas spécifié, la valeur par défaut sera `true`.

#### `config.action_mailer.deliver_later_queue_name`

Spécifie la file d'attente Active Job à utiliser pour le job de livraison par défaut (voir `config.action_mailer.delivery_job`). Lorsque cette option est définie sur `nil`, les jobs de livraison sont envoyés à la file d'attente Active Job par défaut (voir `config.active_job.default_queue_name`).

Les classes de mailer peuvent remplacer cette valeur pour utiliser une file d'attente différente. Notez que cela s'applique uniquement lorsque le job de livraison par défaut est utilisé. Si votre mailer utilise un job personnalisé, sa file d'attente sera utilisée.

Assurez-vous que votre adaptateur Active Job est également configuré pour traiter la file d'attente spécifiée, sinon les jobs de livraison peuvent être ignorés silencieusement.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `:mailers`           |
| 6.1                   | `nil`                |

#### `config.action_mailer.delivery_job`

Spécifie le job de livraison pour les mails.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `ActionMailer::MailDeliveryJob` |
| 6.0                   | `"ActionMailer::MailDeliveryJob"` |

### Configuration d'Active Support

Il existe quelques options de configuration disponibles dans Active Support :

#### `config.active_support.bare`

Active ou désactive le chargement de `active_support/all` lors du démarrage de Rails. Par défaut, cela est `nil`, ce qui signifie que `active_support/all` est chargé.

#### `config.active_support.test_order`

Définit l'ordre dans lequel les cas de test sont exécutés. Les valeurs possibles sont `:random` et `:sorted`. Par défaut, cela est `:random`.

#### `config.active_support.escape_html_entities_in_json`

Active ou désactive l'échappement des entités HTML lors de la sérialisation JSON. Par défaut, cela est `true`.

#### `config.active_support.use_standard_json_time_format`

Active ou désactive la sérialisation des dates au format ISO 8601. Par défaut, cela est `true`.

#### `config.active_support.time_precision`

Définit la précision des valeurs de temps encodées en JSON. Par défaut, cela est `3`.

#### `config.active_support.hash_digest_class`

Permet de configurer la classe de hachage à utiliser pour générer des hachages non sensibles, tels que l'en-tête ETag.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `OpenSSL::Digest::MD5` |
| 5.2                   | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.key_generator_hash_digest_class`

Permet de configurer la classe de hachage à utiliser pour dériver des secrets à partir de la base secrète configurée, tels que pour les cookies chiffrés.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.use_authenticated_message_encryption`

Spécifie si le chiffrement authentifié AES-256-GCM doit être utilisé comme chiffre par défaut pour chiffrer les messages au lieu de AES-256-CBC.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 5.2                   | `true`               |

#### `config.active_support.message_serializer`

Spécifie le sérialiseur par défaut utilisé par les instances [`ActiveSupport::MessageEncryptor`][]
et [`ActiveSupport::MessageVerifier`][]. Pour faciliter la migration entre
les sérialiseurs, les sérialiseurs fournis incluent un mécanisme de secours pour
prendre en charge plusieurs formats de désérialisation :

| Sérialiseur | Sérialiser et désérialiser | Désérialisation de secours |
| ---------- | ------------------------- | -------------------- |
| `:marshal` | `Marshal` | `ActiveSupport::JSON`, `ActiveSupport::MessagePack` |
| `:json` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack` |
| `:json_allow_marshal` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack`, `Marshal` |
| `:message_pack` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON` |
| `:message_pack_allow_marshal` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON`, `Marshal` |

AVERTISSEMENT : `Marshal` est un vecteur potentiel pour les attaques de désérialisation dans les cas
où un secret de signature de message a été divulgué. _Si possible, choisissez un
sérialiseur qui ne prend pas en charge `Marshal`._

INFO : Les sérialiseurs `:message_pack` et `:message_pack_allow_marshal` prennent en charge
le roundtripping de certains types Ruby qui ne sont pas pris en charge par JSON, tels que `Symbol`.
Ils peuvent également offrir des performances améliorées et des tailles de charge utile plus petites. Cependant,
ils nécessitent la gem [`msgpack`](https://rubygems.org/gems/msgpack).

Chacun des sérialiseurs ci-dessus émettra une notification d'événement [`message_serializer_fallback.active_support`][]
lorsqu'ils basculent vers un format de désérialisation alternatif,
ce qui vous permet de suivre la fréquence de ces basculements.

Alternativement, vous pouvez spécifier n'importe quel objet sérialiseur qui répond aux méthodes `dump` et
`load`. Par exemple :

```ruby
config.active_job.message_serializer = YAML
```

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `:marshal`           |
| 7.1                   | `:json_allow_marshal` |
```
#### `config.active_support.use_message_serializer_for_metadata`

Lorsque cette option est définie sur `true`, elle active une optimisation de performance qui sérialise les données des messages et les métadonnées ensemble. Cela modifie le format des messages, de sorte que les anciennes versions de Rails (< 7.1) ne peuvent pas lire les messages sérialisés de cette manière. Cependant, les messages utilisant l'ancien format peuvent toujours être lus, indépendamment de l'activation de cette optimisation.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | ----------------------- |
| (originale)           | `false`                 |
| 7.1                   | `true`                  |

#### `config.active_support.cache_format_version`

Spécifie le format de sérialisation à utiliser pour le cache. Les valeurs possibles sont `6.1`, `7.0` et `7.1`.

Les formats `6.1`, `7.0` et `7.1` utilisent tous `Marshal` comme codeur par défaut, mais le format `7.0` utilise une représentation plus efficace pour les entrées de cache, et le format `7.1` inclut une optimisation supplémentaire pour les valeurs de chaîne brute telles que les fragments de vue.

Tous les formats sont compatibles en arrière et en avant, ce qui signifie que les entrées de cache écrites dans un format peuvent être lues lors de l'utilisation d'un autre format. Ce comportement facilite la migration entre les formats sans invalider l'ensemble du cache.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | ----------------------- |
| (originale)           | `6.1`                   |
| 7.0                   | `7.0`                   |
| 7.1                   | `7.1`                   |

#### `config.active_support.deprecation`

Configure le comportement des avertissements de dépréciation. Les options sont `:raise`, `:stderr`, `:log`, `:notify` et `:silence`.

Dans les fichiers `config/environments` générés par défaut, cette option est définie sur `:log` pour le développement et `:stderr` pour les tests, et elle est omise pour la production en faveur de [`config.active_support.report_deprecations`](#config-active-support-report-deprecations).

#### `config.active_support.disallowed_deprecation`

Configure le comportement des avertissements de dépréciation interdits. Les options sont `:raise`, `:stderr`, `:log`, `:notify` et `:silence`.

Dans les fichiers `config/environments` générés par défaut, cette option est définie sur `:raise` pour le développement et les tests, et elle est omise pour la production en faveur de [`config.active_support.report_deprecations`](#config-active-support-report-deprecations).

#### `config.active_support.disallowed_deprecation_warnings`

Configure les avertissements de dépréciation que l'application considère comme interdits. Cela permet, par exemple, de traiter certains avertissements de dépréciation comme des erreurs graves.

#### `config.active_support.report_deprecations`

Lorsque cette option est définie sur `false`, désactive tous les avertissements de dépréciation, y compris les dépréciations interdites, provenant des [dépréciateurs de l'application](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators). Cela inclut toutes les dépréciations de Rails et d'autres gemmes qui peuvent ajouter leur dépréciateur à la collection de dépréciateurs, mais cela peut ne pas empêcher tous les avertissements de dépréciation émis par ActiveSupport::Deprecation.

Dans les fichiers `config/environments` générés par défaut, cette option est définie sur `false` pour la production.

#### `config.active_support.isolation_level`

Configure la localité de la plupart des états internes de Rails. Si vous utilisez un serveur ou un processeur de tâches basé sur les fibres (par exemple, `falcon`), vous devez le définir sur `:fiber`. Sinon, il est préférable d'utiliser la localité `:thread`. La valeur par défaut est `:thread`.

#### `config.active_support.executor_around_test_case`

Configure la suite de tests pour appeler `Rails.application.executor.wrap` autour des cas de test. Cela permet aux cas de test de se comporter de manière plus proche d'une requête ou d'une tâche réelle. Plusieurs fonctionnalités normalement désactivées en test, telles que le cache de requêtes Active Record et les requêtes asynchrones, seront alors activées.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | ----------------------- |
| (originale)           | `false`                 |
| 7.0                   | `true`                  |

#### `ActiveSupport::Logger.silencer`

Est défini sur `false` pour désactiver la possibilité de désactiver les journaux dans un bloc. La valeur par défaut est `true`.

#### `ActiveSupport::Cache::Store.logger`

Spécifie le journal à utiliser dans les opérations de stockage du cache.

#### `ActiveSupport.to_time_preserves_timezone`

Spécifie si les méthodes `to_time` préservent le décalage UTC de leurs objets. Si la valeur est `false`, les méthodes `to_time` convertiront en utilisant le décalage UTC du système local.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | ----------------------- |
| (originale)           | `false`                 |
| 5.0                   | `true`                  |

#### `ActiveSupport.utc_to_local_returns_utc_offset_times`

Configure `ActiveSupport::TimeZone.utc_to_local` pour renvoyer une heure avec un décalage UTC au lieu d'une heure UTC incorporant ce décalage.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | ----------------------- |
| (originale)           | `false`                 |
| 6.1                   | `true`                  |

#### `config.active_support.raise_on_invalid_cache_expiration_time`

Spécifie si une `ArgumentError` doit être levée si `Rails.cache` `fetch` ou `write` reçoivent une heure d'expiration `expires_at` ou `expires_in` invalide.

Les options sont `true` et `false`. Si la valeur est `false`, l'exception sera signalée comme `handled` et enregistrée.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | ----------------------- |
| (originale)           | `false`                 |
| 7.1                   | `true`                  |
### Configuration d'Active Job

`config.active_job` offre les options de configuration suivantes :

#### `config.active_job.queue_adapter`

Définit l'adaptateur pour le backend de mise en file d'attente. L'adaptateur par défaut est `:async`. Pour obtenir une liste à jour des adaptateurs intégrés, consultez la [documentation de l'API ActiveJob::QueueAdapters](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html).

```ruby
# Assurez-vous d'avoir le gem de l'adaptateur dans votre Gemfile
# et suivez les instructions d'installation et de déploiement spécifiques à l'adaptateur.
config.active_job.queue_adapter = :sidekiq
```

#### `config.active_job.default_queue_name`

Peut être utilisé pour changer le nom de la file d'attente par défaut. Par défaut, il s'agit de `"default"`.

```ruby
config.active_job.default_queue_name = :medium_priority
```

#### `config.active_job.queue_name_prefix`

Vous permet de définir un préfixe de nom de file d'attente facultatif et non vide pour tous les jobs. Par défaut, il est vide et n'est pas utilisé.

La configuration suivante placerait le job donné dans la file d'attente `production_high_priority` lorsqu'il est exécuté en production :

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

A une valeur par défaut de `'_'`. Si `queue_name_prefix` est défini, alors `queue_name_delimiter` joint le préfixe et le nom de file d'attente sans préfixe.

La configuration suivante placerait le job fourni dans la file d'attente `video_server.low_priority` :

```ruby
# le préfixe doit être défini pour que le délimiteur soit utilisé
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

Accepte un logger conforme à l'interface de Log4r ou à la classe de logger Ruby par défaut, qui est ensuite utilisé pour enregistrer des informations depuis Active Job. Vous pouvez récupérer ce logger en appelant `logger` sur une classe Active Job ou une instance Active Job. Définissez-le sur `nil` pour désactiver l'enregistrement.

#### `config.active_job.custom_serializers`

Permet de définir des sérialiseurs d'arguments personnalisés. Par défaut, il est défini sur `[]`.

#### `config.active_job.log_arguments`

Contrôle si les arguments d'un job sont enregistrés. Par défaut, il est défini sur `true`.

#### `config.active_job.verbose_enqueue_logs`

Spécifie si les emplacements sources des méthodes qui mettent en file d'attente des jobs en arrière-plan doivent être enregistrés en dessous des lignes de journalisation de mise en file d'attente pertinentes. Par défaut, le drapeau est `true` en développement et `false` dans tous les autres environnements.

#### `config.active_job.retry_jitter`

Contrôle la quantité de "jitter" (variation aléatoire) appliquée au temps de retard calculé lors de la répétition des jobs échoués.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `0.0`                |
| 6.1                   | `0.15`               |

#### `config.active_job.log_query_tags_around_perform`

Détermine si le contexte du job pour les balises de requête sera automatiquement mis à jour via un `around_perform`. La valeur par défaut est `true`.

#### `config.active_job.use_big_decimal_serializer`

Active le nouveau sérialiseur d'arguments `BigDecimal`, qui garantit la réversibilité. Sans ce sérialiseur, certains adaptateurs de file d'attente peuvent sérialiser les arguments `BigDecimal` sous forme de chaînes simples (non réversibles).

AVERTISSEMENT : Lors du déploiement d'une application avec plusieurs répliques, les anciennes répliques (avant Rails 7.1) ne pourront pas désérialiser les arguments `BigDecimal` de ce sérialiseur. Par conséquent, ce paramètre ne doit être activé qu'après la mise à niveau réussie de toutes les répliques vers Rails 7.1.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 7.1                   | `true`               |

### Configuration d'Action Cable

#### `config.action_cable.url`

Accepte une chaîne de caractères pour l'URL où vous hébergez votre serveur Action Cable. Vous utiliseriez cette option si vous exécutez des serveurs Action Cable séparés de votre application principale.

#### `config.action_cable.mount_path`

Accepte une chaîne de caractères pour monter Action Cable, en tant que partie du processus du serveur principal. Par défaut, il est défini sur `/cable`. Vous pouvez le définir sur `nil` pour ne pas monter Action Cable en tant que partie de votre serveur Rails normal.

Vous pouvez trouver plus d'options de configuration détaillées dans la [présentation d'Action Cable](action_cable_overview.html#configuration).

#### `config.action_cable.precompile_assets`

Détermine si les assets d'Action Cable doivent être ajoutés à la précompilation des assets. Cela n'a aucun effet si Sprockets n'est pas utilisé. La valeur par défaut est `true`.

### Configuration d'Active Storage

`config.active_storage` offre les options de configuration suivantes :

#### `config.active_storage.variant_processor`

Accepte un symbole `:mini_magick` ou `:vips`, spécifiant si les transformations de variantes et l'analyse des blobs seront effectuées avec MiniMagick ou ruby-vips.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `:mini_magick`       |
| 7.0                   | `:vips`              |

#### `config.active_storage.analyzers`

Accepte un tableau de classes indiquant les analyseurs disponibles pour les blobs Active Storage.
Par défaut, cela est défini comme suit :

```ruby
config.active_storage.analyzers = [ActiveStorage::Analyzer::ImageAnalyzer::Vips, ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick, ActiveStorage::Analyzer::VideoAnalyzer, ActiveStorage::Analyzer::AudioAnalyzer]
```

Les analyseurs d'images peuvent extraire la largeur et la hauteur d'un blob d'image ; l'analyseur vidéo peut extraire la largeur, la hauteur, la durée, l'angle, le rapport d'aspect et la présence/absence des canaux vidéo/audio d'un blob vidéo ; l'analyseur audio peut extraire la durée et le débit binaire d'un blob audio.
#### `config.active_storage.previewers`

Accepte un tableau de classes indiquant les visualiseurs d'images disponibles dans les blobs Active Storage.
Par défaut, cela est défini comme suit:

```ruby
config.active_storage.previewers = [ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer]
```

`PopplerPDFPreviewer` et `MuPDFPreviewer` peuvent générer une miniature à partir de la première page d'un blob PDF ; `VideoPreviewer` à partir de l'image pertinente d'un blob vidéo.

#### `config.active_storage.paths`

Accepte un hash d'options indiquant les emplacements des commandes de visualisation/analyse. Par défaut, cela est `{}`, ce qui signifie que les commandes seront recherchées dans le chemin par défaut. Peut inclure l'une de ces options :

* `:ffprobe` - L'emplacement de l'exécutable ffprobe.
* `:mutool` - L'emplacement de l'exécutable mutool.
* `:ffmpeg` - L'emplacement de l'exécutable ffmpeg.

```ruby
config.active_storage.paths[:ffprobe] = '/usr/local/bin/ffprobe'
```

#### `config.active_storage.variable_content_types`

Accepte un tableau de chaînes indiquant les types de contenu que Active Storage peut transformer grâce au processeur de variantes.
Par défaut, cela est défini comme suit:

```ruby
config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/bmp image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)
```

#### `config.active_storage.web_image_content_types`

Accepte un tableau de chaînes considérées comme des types de contenu d'images Web dans lesquels les variantes peuvent être traitées sans être converties au format PNG de secours.
Si vous souhaitez utiliser des variantes `WebP` ou `AVIF` dans votre application, vous pouvez ajouter `image/webp` ou `image/avif` à ce tableau.
Par défaut, cela est défini comme suit:

```ruby
config.active_storage.web_image_content_types = %w(image/png image/jpeg image/gif)
```

#### `config.active_storage.content_types_to_serve_as_binary`

Accepte un tableau de chaînes indiquant les types de contenu que Active Storage servira toujours en tant que pièce jointe, plutôt qu'en ligne.
Par défaut, cela est défini comme suit:

```ruby
config.active_storage.content_types_to_serve_as_binary = %w(text/html image/svg+xml application/postscript application/x-shockwave-flash text/xml application/xml application/xhtml+xml application/mathml+xml text/cache-manifest)
```

#### `config.active_storage.content_types_allowed_inline`

Accepte un tableau de chaînes indiquant les types de contenu que Active Storage autorise à servir en ligne.
Par défaut, cela est défini comme suit:

```ruby
config.active_storage.content_types_allowed_inline` = %w(image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon application/pdf)
```

#### `config.active_storage.queues.analysis`

Accepte un symbole indiquant la file d'attente Active Job à utiliser pour les tâches d'analyse. Lorsque cette option est `nil`, les tâches d'analyse sont envoyées à la file d'attente Active Job par défaut (voir `config.active_job.default_queue_name`).

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| 6.0                   | `:active_storage_analysis` |
| 6.1                   | `nil`                |

#### `config.active_storage.queues.purge`

Accepte un symbole indiquant la file d'attente Active Job à utiliser pour les tâches de suppression. Lorsque cette option est `nil`, les tâches de suppression sont envoyées à la file d'attente Active Job par défaut (voir `config.active_job.default_queue_name`).

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| 6.0                   | `:active_storage_purge` |
| 6.1                   | `nil`                |

#### `config.active_storage.queues.mirror`

Accepte un symbole indiquant la file d'attente Active Job à utiliser pour les tâches de duplication de téléchargement direct. Lorsque cette option est `nil`, les tâches de duplication sont envoyées à la file d'attente Active Job par défaut (voir `config.active_job.default_queue_name`). La valeur par défaut est `nil`.

#### `config.active_storage.logger`

Peut être utilisé pour définir le journal utilisé par Active Storage. Accepte un journal conforme à l'interface de Log4r ou à la classe de journalisation Ruby par défaut.

```ruby
config.active_storage.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.active_storage.service_urls_expire_in`

Détermine l'expiration par défaut des URL générées par :

* `ActiveStorage::Blob#url`
* `ActiveStorage::Blob#service_url_for_direct_upload`
* `ActiveStorage::Variant#url`

La valeur par défaut est de 5 minutes.

#### `config.active_storage.urls_expire_in`

Détermine l'expiration par défaut des URL dans l'application Rails générées par Active Storage. La valeur par défaut est `nil`.

#### `config.active_storage.routes_prefix`

Peut être utilisé pour définir le préfixe de route pour les routes servies par Active Storage. Accepte une chaîne qui sera préfixée aux routes générées.

```ruby
config.active_storage.routes_prefix = '/files'
```

La valeur par défaut est `/rails/active_storage`.

#### `config.active_storage.track_variants`

Détermine si les variantes sont enregistrées dans la base de données.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `false`              |
| 6.1                   | `true`               |

#### `config.active_storage.draw_routes`

Peut être utilisé pour activer ou désactiver la génération des routes Active Storage. La valeur par défaut est `true`.

#### `config.active_storage.resolve_model_to_route`

Peut être utilisé pour modifier globalement la façon dont les fichiers Active Storage sont livrés.

Les valeurs autorisées sont :

* `:rails_storage_redirect` : Rediriger vers des URL de service signées et de courte durée.
* `:rails_storage_proxy` : Proxy des fichiers en les téléchargeant.

La valeur par défaut est `:rails_storage_redirect`.

#### `config.active_storage.video_preview_arguments`

Peut être utilisé pour modifier la façon dont ffmpeg génère des images de prévisualisation vidéo.

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (original)            | `"-y -vframes 1 -f image2"` |
| 7.0                   | `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015)"`<sup><mark><strong><em>1</em></strong></mark></sup> <br> `+ ",loop=loop=-1:size=2,trim=start_frame=1'"`<sup><mark><strong><em>2</em></strong></mark></sup><br> `+ " -frames:v 1 -f image2"` <br><br> <ol><li>Sélectionne la première image de la vidéo, ainsi que les images clés et les images qui dépassent le seuil de changement de scène.</li> <li>Utilise la première image de la vidéo comme solution de secours lorsque aucune autre image ne répond aux critères en bouclant la première (une ou) deux images sélectionnées, puis en supprimant la première image bouclée.</li></ol> |
#### `config.active_storage.multiple_file_field_include_hidden`

À partir de Rails 7.1 et au-delà, les relations `has_many_attached` d'Active Storage
seront par défaut _remplacées_ par la collection actuelle au lieu de lui être _ajoutées_. Ainsi,
pour prendre en charge la soumission d'une collection _vide_, lorsque `multiple_file_field_include_hidden`
est `true`, l'aide [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field)
rendra un champ caché auxiliaire, similaire au champ auxiliaire
rendu par l'aide [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box).

La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est |
| --------------------- | -------------------- |
| (originale)            | `false`              |
| 7.0                   | `true`               |

#### `config.active_storage.precompile_assets`

Détermine si les ressources d'Active Storage doivent être ajoutées à la précompilation des ressources de l'application. Cela
n'a aucun effet si Sprockets n'est pas utilisé. La valeur par défaut est `true`.

### Configuration d'Action Text

#### `config.action_text.attachment_tag_name`

Accepte une chaîne de caractères pour la balise HTML utilisée pour envelopper les pièces jointes. Par défaut, c'est `"action-text-attachment"`.

#### `config.action_text.sanitizer_vendor`

Configure le sanitizeur HTML utilisé par Action Text en définissant `ActionText::ContentHelper.sanitizer` sur une instance de la classe retournée par la méthode `.safe_list_sanitizer` du fournisseur. La valeur par défaut dépend de la version cible de `config.load_defaults` :

| À partir de la version | La valeur par défaut est                 | Qui analyse le balisage en tant que |
|-----------------------|--------------------------------------|------------------------|
| (originale)            | `Rails::HTML4::Sanitizer`            | HTML4                  |
| 7.1                   | `Rails::HTML5::Sanitizer` (voir NOTE) | HTML5                  |

NOTE : `Rails::HTML5::Sanitizer` n'est pas pris en charge sur JRuby, donc sur les plates-formes JRuby, Rails utilisera `Rails::HTML4::Sanitizer` par défaut.

### Configuration d'une base de données

Presque toutes les applications Rails interagiront avec une base de données. Vous pouvez vous connecter à la base de données en définissant une variable d'environnement `ENV['DATABASE_URL']` ou en utilisant un fichier de configuration appelé `config/database.yml`.

En utilisant le fichier `config/database.yml`, vous pouvez spécifier toutes les informations nécessaires pour accéder à votre base de données :

```yaml
development:
  adapter: postgresql
  database: blog_development
  pool: 5
```

Cela se connectera à la base de données nommée `blog_development` en utilisant l'adaptateur `postgresql`. Ces mêmes informations peuvent être stockées dans une URL et fournies via une variable d'environnement comme ceci :

```ruby
ENV['DATABASE_URL'] # => "postgresql://localhost/blog_development?pool=5"
```

Le fichier `config/database.yml` contient des sections pour trois environnements différents dans lesquels Rails peut s'exécuter par défaut :

* L'environnement `development` est utilisé sur votre ordinateur de développement/local lorsque vous interagissez manuellement avec l'application.
* L'environnement `test` est utilisé lors de l'exécution de tests automatisés.
* L'environnement `production` est utilisé lorsque vous déployez votre application pour que le monde entier l'utilise.

Si vous le souhaitez, vous pouvez spécifier manuellement une URL à l'intérieur de votre `config/database.yml` :

```yaml
development:
  url: postgresql://localhost/blog_development?pool=5
```

Le fichier `config/database.yml` peut contenir des balises ERB `<%= %>`. Tout ce qui se trouve entre les balises sera évalué en tant que code Ruby. Vous pouvez l'utiliser pour extraire des données d'une variable d'environnement ou pour effectuer des calculs afin de générer les informations de connexion nécessaires.


CONSEIL : Vous n'avez pas besoin de mettre à jour manuellement les configurations de la base de données. Si vous regardez les options du générateur d'applications, vous verrez qu'une des options s'appelle `--database`. Cette option vous permet de choisir un adaptateur parmi une liste des bases de données relationnelles les plus utilisées. Vous pouvez même exécuter le générateur plusieurs fois : `cd .. && rails new blog --database=mysql`. Lorsque vous confirmez la substitution du fichier `config/database.yml`, votre application sera configurée pour MySQL au lieu de SQLite. Des exemples détaillés des connexions de bases de données courantes sont donnés ci-dessous.

### Préférence de connexion

Étant donné qu'il existe deux façons de configurer votre connexion (en utilisant `config/database.yml` ou en utilisant une variable d'environnement), il est important de comprendre comment elles peuvent interagir.

Si vous avez un fichier `config/database.yml` vide mais que votre `ENV['DATABASE_URL']` est présent, alors Rails se connectera à la base de données via votre variable d'environnement :

```bash
$ cat config/database.yml

$ echo $DATABASE_URL
postgresql://localhost/my_database
```

Si vous avez un `config/database.yml` mais pas de `ENV['DATABASE_URL']`, alors ce fichier sera utilisé pour se connecter à votre base de données :

```bash
$ cat config/database.yml
development:
  adapter: postgresql
  database: my_database
  host: localhost

$ echo $DATABASE_URL
```

Si vous avez à la fois `config/database.yml` et `ENV['DATABASE_URL']` définis, alors Rails fusionnera les configurations. Pour mieux comprendre cela, nous devons voir quelques exemples.

Lorsque des informations de connexion en double sont fournies, la variable d'environnement prendra le pas :

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

Ici, l'adaptateur, l'hôte et la base de données correspondent aux informations de `ENV['DATABASE_URL']`.

Si des informations non dupliquées sont fournies, vous obtiendrez toutes les valeurs uniques, la variable d'environnement prend toujours le pas en cas de conflits.
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

Étant donné que le pool n'est pas dans les informations de connexion fournies par `ENV['DATABASE_URL']`, ses informations sont fusionnées. Étant donné que l'adaptateur est en double, les informations de connexion de `ENV['DATABASE_URL']` l'emportent.

La seule façon de ne pas utiliser explicitement les informations de connexion dans `ENV['DATABASE_URL']` est de spécifier une connexion URL explicite en utilisant la sous-clé `"url"` :

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

Ici, les informations de connexion dans `ENV['DATABASE_URL']` sont ignorées, notez l'adaptateur différent et le nom de la base de données.

Étant donné qu'il est possible d'intégrer ERB dans votre `config/database.yml`, il est préférable de montrer explicitement que vous utilisez `ENV['DATABASE_URL']` pour vous connecter à votre base de données. Cela est particulièrement utile en production, car vous ne devez pas commettre de secrets tels que votre mot de passe de base de données dans votre contrôle de source (comme Git).

```bash
$ cat config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

Maintenant, le comportement est clair, nous utilisons uniquement les informations de connexion dans `ENV['DATABASE_URL']`.

#### Configuration d'une base de données SQLite3

Rails est livré avec une prise en charge intégrée de [SQLite3](http://www.sqlite.org), qui est une application de base de données légère sans serveur. Bien qu'un environnement de production chargé puisse surcharger SQLite, il fonctionne bien pour le développement et les tests. Rails utilise par défaut une base de données SQLite lors de la création d'un nouveau projet, mais vous pouvez toujours la modifier ultérieurement.

Voici la section du fichier de configuration par défaut (`config/database.yml`) avec les informations de connexion pour l'environnement de développement :

```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

REMARQUE : Rails utilise une base de données SQLite3 pour le stockage des données par défaut car c'est une base de données sans configuration qui fonctionne simplement. Rails prend également en charge MySQL (y compris MariaDB) et PostgreSQL "prêt à l'emploi" et dispose de plugins pour de nombreux systèmes de bases de données. Si vous utilisez une base de données dans un environnement de production, Rails a très probablement un adaptateur pour celle-ci.

#### Configuration d'une base de données MySQL ou MariaDB

Si vous choisissez d'utiliser MySQL ou MariaDB au lieu de la base de données SQLite3 fournie, votre `config/database.yml` sera un peu différent. Voici la section de développement :

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

Si votre base de données de développement a un utilisateur root avec un mot de passe vide, cette configuration devrait fonctionner pour vous. Sinon, modifiez le nom d'utilisateur et le mot de passe dans la section `development` selon les besoins.

REMARQUE : Si votre version de MySQL est 5.5 ou 5.6 et que vous souhaitez utiliser l'ensemble de caractères `utf8mb4` par défaut, veuillez configurer votre serveur MySQL pour prendre en charge le préfixe de clé plus long en activant la variable système `innodb_large_prefix`.

Les verrous consultatifs sont activés par défaut sur MySQL et sont utilisés pour rendre les migrations de base de données sûres en mode concurrent. Vous pouvez désactiver les verrous consultatifs en définissant `advisory_locks` sur `false` :

```yaml
production:
  adapter: mysql2
  advisory_locks: false
```

#### Configuration d'une base de données PostgreSQL

Si vous choisissez d'utiliser PostgreSQL, votre `config/database.yml` sera personnalisé pour utiliser les bases de données PostgreSQL :

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: blog_development
  pool: 5
```

Par défaut, Active Record utilise des fonctionnalités de base de données telles que les instructions préparées et les verrous consultatifs. Vous devrez peut-être désactiver ces fonctionnalités si vous utilisez un pool de connexions externe tel que PgBouncer :

```yaml
production:
  adapter: postgresql
  prepared_statements: false
  advisory_locks: false
```

S'ils sont activés, Active Record créera jusqu'à `1000` instructions préparées par connexion à la base de données par défaut. Pour modifier ce comportement, vous pouvez définir `statement_limit` sur une valeur différente :

```yaml
production:
  adapter: postgresql
  statement_limit: 200
```

Plus il y a d'instructions préparées en cours d'utilisation : plus votre base de données aura besoin de mémoire. Si votre base de données PostgreSQL atteint les limites de mémoire, essayez de réduire `statement_limit` ou de désactiver les instructions préparées.

#### Configuration d'une base de données SQLite3 pour la plateforme JRuby

Si vous choisissez d'utiliser SQLite3 et que vous utilisez JRuby, votre `config/database.yml` sera un peu différent. Voici la section de développement :

```yaml
development:
  adapter: jdbcsqlite3
  database: storage/development.sqlite3
```

#### Configuration d'une base de données MySQL ou MariaDB pour la plateforme JRuby

Si vous choisissez d'utiliser MySQL ou MariaDB et que vous utilisez JRuby, votre `config/database.yml` sera un peu différent. Voici la section de développement :

```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```
#### Configuration d'une base de données PostgreSQL pour la plateforme JRuby

Si vous choisissez d'utiliser PostgreSQL et que vous utilisez JRuby, votre `config/database.yml` sera un peu différent. Voici la section développement :

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

Modifiez le nom d'utilisateur et le mot de passe dans la section `development` selon vos besoins.

#### Configuration du stockage des métadonnées

Par défaut, Rails stockera les informations sur votre environnement Rails et votre schéma dans une table interne appelée `ar_internal_metadata`.

Pour désactiver cela par connexion, définissez `use_metadata_table` dans votre configuration de base de données. Cela est utile lorsque vous travaillez avec une base de données partagée et/ou un utilisateur de base de données qui ne peut pas créer de tables.

```yaml
development:
  adapter: postgresql
  use_metadata_table: false
```

#### Configuration du comportement de réessai

Par défaut, Rails se reconnectera automatiquement au serveur de base de données et réessayera certaines requêtes en cas de problème. Seules les requêtes sûres à réessayer (idempotentes) seront réessayées. Le nombre de réessais peut être spécifié dans votre configuration de base de données via `connection_retries`, ou désactivé en définissant la valeur à 0. Le nombre de réessais par défaut est de 1.

```yaml
development:
  adapter: mysql2
  connection_retries: 3
```

La configuration de la base de données permet également de configurer une `retry_deadline`. Si une `retry_deadline` est configurée, une requête par ailleurs réessayable ne sera _pas_ réessayée si le délai spécifié s'est écoulé depuis la première tentative de requête. Par exemple, une `retry_deadline` de 5 secondes signifie que si 5 secondes se sont écoulées depuis la première tentative d'une requête, nous ne réessayerons pas la requête, même si elle est idempotente et qu'il reste des `connection_retries`.

Cette valeur est par défaut à nil, ce qui signifie que toutes les requêtes réessayables sont réessayées quel que soit le temps écoulé. La valeur de cette configuration doit être spécifiée en secondes.

```yaml
development:
  adapter: mysql2
  retry_deadline: 5 # Arrêter de réessayer les requêtes après 5 secondes
```

#### Configuration du cache de requêtes

Par défaut, Rails met automatiquement en cache les ensembles de résultats renvoyés par les requêtes. Si Rails rencontre la même requête à nouveau pour cette demande ou ce travail, il utilisera l'ensemble de résultats mis en cache au lieu d'exécuter à nouveau la requête contre la base de données.

Le cache de requêtes est stocké en mémoire et, pour éviter d'utiliser trop de mémoire, il évacue automatiquement les requêtes les moins récemment utilisées lorsqu'il atteint un seuil. Par défaut, le seuil est de `100`, mais il peut être configuré dans le `database.yml`.

```yaml
development:
  adapter: mysql2
  query_cache: 200
```

Pour désactiver complètement le cache de requêtes, il peut être défini sur `false`

```yaml
development:
  adapter: mysql2
  query_cache: false
```

### Création d'environnements Rails

Par défaut, Rails est livré avec trois environnements : "development", "test" et "production". Bien que cela soit suffisant pour la plupart des cas d'utilisation, il y a des circonstances où vous voulez plus d'environnements.

Imaginez que vous avez un serveur qui reproduit l'environnement de production mais qui est uniquement utilisé pour les tests. Un tel serveur est communément appelé un "serveur de staging". Pour définir un environnement appelé "staging" pour ce serveur, créez simplement un fichier appelé `config/environments/staging.rb`. Comme il s'agit d'un environnement similaire à la production, vous pouvez copier le contenu de `config/environments/production.rb` comme point de départ et apporter les modifications nécessaires à partir de là. Il est également possible de requérir et d'étendre d'autres configurations d'environnement de cette manière :

```ruby
# config/environments/staging.rb
require_relative "production"

Rails.application.configure do
  # Staging overrides
end
```

Cet environnement n'est pas différent des environnements par défaut, démarrez un serveur avec `bin/rails server -e staging`, une console avec `bin/rails console -e staging`, `Rails.env.staging?` fonctionne, etc.

### Déploiement dans un sous-répertoire (racine d'URL relative)

Par défaut, Rails s'attend à ce que votre application s'exécute à la racine (par exemple, `/`). Cette section explique comment exécuter votre application à l'intérieur d'un répertoire.

Supposons que nous voulions déployer notre application dans "/app1". Rails doit connaître ce répertoire pour générer les routes appropriées :

```ruby
config.relative_url_root = "/app1"
```

alternativement, vous pouvez définir la variable d'environnement `RAILS_RELATIVE_URL_ROOT`.

Rails ajoutera maintenant "/app1" lors de la génération des liens.

#### Utilisation de Passenger

Passenger facilite l'exécution de votre application dans un sous-répertoire. Vous pouvez trouver la configuration pertinente dans le [manuel de Passenger](https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/#deploying-an-app-to-a-sub-uri-or-subdirectory).

#### Utilisation d'un proxy inverse

Le déploiement de votre application à l'aide d'un proxy inverse présente des avantages certains par rapport aux déploiements traditionnels. Ils vous permettent d'avoir plus de contrôle sur votre serveur en superposant les composants requis par votre application.

De nombreux serveurs web modernes peuvent être utilisés comme serveur proxy pour équilibrer des éléments tiers tels que des serveurs de cache ou des serveurs d'application.

Un tel serveur d'application que vous pouvez utiliser est [Unicorn](https://bogomips.org/unicorn/) pour s'exécuter derrière un proxy inverse.
Dans ce cas, vous devriez configurer le serveur proxy (NGINX, Apache, etc.) pour accepter les connexions de votre serveur d'application (Unicorn). Par défaut, Unicorn écoutera les connexions TCP sur le port 8080, mais vous pouvez changer le port ou le configurer pour utiliser des sockets à la place.

Vous pouvez trouver plus d'informations dans le [lisez-moi d'Unicorn](https://bogomips.org/unicorn/README.html) et comprendre la [philosophie](https://bogomips.org/unicorn/PHILOSOPHY.html) derrière celle-ci.

Une fois que vous avez configuré le serveur d'application, vous devez rediriger les requêtes vers celui-ci en configurant votre serveur web de manière appropriée. Par exemple, votre configuration NGINX peut inclure :

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

Assurez-vous de lire la [documentation NGINX](https://nginx.org/en/docs/) pour obtenir les informations les plus à jour.

Paramètres de l'environnement Rails
----------------------------------

Certaines parties de Rails peuvent également être configurées de manière externe en fournissant des variables d'environnement. Les variables d'environnement suivantes sont reconnues par différentes parties de Rails :

* `ENV["RAILS_ENV"]` définit l'environnement Rails (production, développement, test, etc.) sous lequel Rails s'exécutera.

* `ENV["RAILS_RELATIVE_URL_ROOT"]` est utilisé par le code de routage pour reconnaître les URL lorsque vous [déployez votre application dans un sous-répertoire](configuring.html#deploy-to-a-subdirectory-relative-url-root).

* `ENV["RAILS_CACHE_ID"]` et `ENV["RAILS_APP_VERSION"]` sont utilisés pour générer des clés de cache étendues dans le code de mise en cache de Rails. Cela vous permet d'avoir plusieurs caches distincts à partir de la même application.

Utilisation des fichiers d'initialisation
----------------------------------------

Après avoir chargé le framework et toutes les gemmes de votre application, Rails se tourne vers le chargement des initializers. Un initializer est n'importe quel fichier Ruby stocké sous `config/initializers` dans votre application. Vous pouvez utiliser des initializers pour stocker des paramètres de configuration qui doivent être définis après le chargement de tous les frameworks et gemmes, tels que des options pour configurer ces parties.

Les fichiers dans `config/initializers` (et tous les sous-répertoires de `config/initializers`) sont triés et chargés un par un dans le cadre de l'initializer `load_config_initializers`.

Si un initializer contient du code qui dépend du code dans un autre initializer, vous pouvez les combiner en un seul initializer. Cela rend les dépendances plus explicites et peut aider à mettre en évidence de nouveaux concepts au sein de votre application. Rails prend également en charge la numérotation des noms de fichiers d'initializers, mais cela peut entraîner des changements de noms de fichiers. Il n'est pas recommandé de charger explicitement les initializers avec `require`, car cela entraînera le chargement de l'initializer deux fois.

REMARQUE : Il n'y a aucune garantie que vos initializers s'exécuteront après tous les initializers des gemmes, donc tout code d'initialisation qui dépend d'une gemme donnée ayant été initialisée doit être placé dans un bloc `config.after_initialize`.

Événements d'initialisation
--------------------------

Rails dispose de 5 événements d'initialisation auxquels vous pouvez vous connecter (listés dans l'ordre où ils sont exécutés) :

* `before_configuration` : Cela s'exécute dès que la constante d'application hérite de `Rails::Application`. Les appels `config` sont évalués avant cela.

* `before_initialize` : Cela s'exécute juste avant le processus d'initialisation de l'application avec l'initializer `:bootstrap_hook` près du début du processus d'initialisation de Rails.

* `to_prepare` : S'exécute après l'exécution des initializers pour toutes les Railties (y compris l'application elle-même), mais avant le chargement anticipé et la construction de la pile de middleware. Plus important encore, il s'exécutera à chaque rechargement de code en `development`, mais une seule fois (au démarrage) en `production` et `test`.

* `before_eager_load` : Cela s'exécute juste avant le chargement anticipé, qui est le comportement par défaut pour l'environnement `production` et non pour l'environnement `development`.

* `after_initialize` : S'exécute directement après l'initialisation de l'application, après l'exécution des initializers d'application dans `config/initializers`.

Pour définir un événement pour ces hooks, utilisez la syntaxe de bloc dans une sous-classe `Rails::Application`, `Rails::Railtie` ou `Rails::Engine` :

```ruby
module YourApp
  class Application < Rails::Application
    config.before_initialize do
      # le code d'initialisation va ici
    end
  end
end
```

Alternativement, vous pouvez également le faire via la méthode `config` sur l'objet `Rails.application` :

```ruby
Rails.application.config.before_initialize do
  # le code d'initialisation va ici
end
```

AVERTISSEMENT : Certaines parties de votre application, notamment le routage, ne sont pas encore configurées au moment où le bloc `after_initialize` est appelé.

### `Rails::Railtie#initializer`

Rails dispose de plusieurs initializers qui s'exécutent au démarrage et qui sont tous définis en utilisant la méthode `initializer` de `Rails::Railtie`. Voici un exemple de l'initializer `set_helpers_path` d'Action Controller :

```ruby
initializer "action_controller.set_helpers_path" do |app|
  ActionController::Helpers.helpers_path = app.helpers_paths
end
```

La méthode `initializer` prend trois arguments, le premier étant le nom de l'initializer, le deuxième étant un hash d'options (non montré ici) et le troisième étant un bloc. La clé `:before` dans le hash d'options peut être spécifiée pour indiquer quel initializer doit être exécuté avant ce nouvel initializer, et la clé `:after` spécifiera quel initializer exécuter cet initializer _après_.
Les initialiseurs définis à l'aide de la méthode `initializer` seront exécutés dans l'ordre où ils sont définis, à l'exception de ceux qui utilisent les méthodes `:before` ou `:after`.

AVERTISSEMENT : Vous pouvez placer votre initialiseur avant ou après n'importe quel autre initialiseur dans la chaîne, tant que cela est logique. Supposons que vous ayez 4 initialiseurs appelés "one" à "four" (définis dans cet ordre) et que vous définissiez "four" pour aller _avant_ "two" mais _après_ "three", cela n'est tout simplement pas logique et Rails ne pourra pas déterminer l'ordre de vos initialiseurs.

L'argument de bloc de la méthode `initializer` est l'instance de l'application elle-même, et nous pouvons donc accéder à la configuration en utilisant la méthode `config` comme dans l'exemple.

Étant donné que `Rails::Application` hérite de `Rails::Railtie` (indirectement), vous pouvez utiliser la méthode `initializer` dans `config/application.rb` pour définir des initialiseurs pour l'application.

### Initialiseurs

Voici une liste complète de tous les initialiseurs trouvés dans Rails dans l'ordre où ils sont définis (et donc exécutés, sauf indication contraire).

* `load_environment_hook` : Sert de marqueur afin que `:load_environment_config` puisse être défini pour s'exécuter avant lui.

* `load_active_support` : Requiert `active_support/dependencies` qui met en place la base pour Active Support. Requiert éventuellement `active_support/all` si `config.active_support.bare` n'est pas vrai, ce qui est la valeur par défaut.

* `initialize_logger` : Initialise le journal (un objet `ActiveSupport::Logger`) pour l'application et le rend accessible via `Rails.logger`, à condition qu'aucun initialiseur inséré avant ce point n'ait défini `Rails.logger`.

* `initialize_cache` : Si `Rails.cache` n'est pas encore défini, initialise le cache en faisant référence à la valeur dans `config.cache_store` et stocke le résultat en tant que `Rails.cache`. Si cet objet répond à la méthode `middleware`, son middleware est inséré avant `Rack::Runtime` dans la pile de middleware.

* `set_clear_dependencies_hook` : Cet initialiseur - qui s'exécute uniquement si `config.enable_reloading` est défini sur `true` - utilise `ActionDispatch::Callbacks.after` pour supprimer les constantes qui ont été référencées pendant la requête de l'espace d'objets afin qu'elles soient rechargées lors de la requête suivante.

* `bootstrap_hook` : Exécute tous les blocs `before_initialize` configurés.

* `i18n.callbacks` : Dans l'environnement de développement, configure un rappel `to_prepare` qui appellera `I18n.reload!` si l'une des locales a changé depuis la dernière requête. En production, ce rappel ne s'exécute que lors de la première requête.

* `active_support.deprecation_behavior` : Configure le comportement de signalement des dépréciations pour [`Rails.application.deprecators`][] en fonction de [`config.active_support.report_deprecations`](#config-active-support-report-deprecations), [`config.active_support.deprecation`](#config-active-support-deprecation), [`config.active_support.disallowed_deprecation`](#config-active-support-disallowed-deprecation) et [`config.active_support.disallowed_deprecation_warnings`](#config-active-support-disallowed-deprecation-warnings).

* `active_support.initialize_time_zone` : Définit le fuseau horaire par défaut pour l'application en fonction du paramètre `config.time_zone`, qui est par défaut "UTC".

* `active_support.initialize_beginning_of_week` : Définit le début de la semaine par défaut pour l'application en fonction du paramètre `config.beginning_of_week`, qui est par défaut `:monday`.

* `active_support.set_configs` : Configure Active Support en utilisant les paramètres de `config.active_support` en utilisant la méthode `send` pour appeler les noms de méthode en tant que setters sur `ActiveSupport` et en passant les valeurs.

* `action_dispatch.configure` : Configure `ActionDispatch::Http::URL.tld_length` pour qu'il soit défini sur la valeur de `config.action_dispatch.tld_length`.

* `action_view.set_configs` : Configure Action View en utilisant les paramètres de `config.action_view` en utilisant la méthode `send` pour appeler les noms de méthode en tant que setters sur `ActionView::Base` et en passant les valeurs.

* `action_controller.assets_config` : Initialise `config.action_controller.assets_dir` sur le répertoire public de l'application s'il n'est pas configuré explicitement.

* `action_controller.set_helpers_path` : Définit `helpers_path` de Action Controller sur `helpers_path` de l'application.

* `action_controller.parameters_config` : Configure les options des paramètres forts pour `ActionController::Parameters`.

* `action_controller.set_configs` : Configure Action Controller en utilisant les paramètres de `config.action_controller` en utilisant la méthode `send` pour appeler les noms de méthode en tant que setters sur `ActionController::Base` et en passant les valeurs.

* `action_controller.compile_config_methods` : Initialise les méthodes pour les paramètres de configuration spécifiés afin qu'ils soient plus rapides à accéder.

* `active_record.initialize_timezone` : Définit `ActiveRecord::Base.time_zone_aware_attributes` sur `true`, ainsi que `ActiveRecord::Base.default_timezone` sur UTC. Lorsque les attributs sont lus depuis la base de données, ils seront convertis dans le fuseau horaire spécifié par `Time.zone`.

* `active_record.logger` : Définit `ActiveRecord::Base.logger` - s'il n'est pas déjà défini - sur `Rails.logger`.

* `active_record.migration_error` : Configure le middleware pour vérifier les migrations en attente.

* `active_record.check_schema_cache_dump` : Charge le cache de schéma si configuré et disponible.

* `active_record.warn_on_records_fetched_greater_than` : Active les avertissements lorsque les requêtes renvoient un grand nombre d'enregistrements.

* `active_record.set_configs` : Configure Active Record en utilisant les paramètres de `config.active_record` en utilisant la méthode `send` pour appeler les noms de méthode en tant que setters sur `ActiveRecord::Base` et en passant les valeurs.

* `active_record.initialize_database` : Charge la configuration de la base de données (par défaut) à partir de `config/database.yml` et établit une connexion pour l'environnement actuel.

* `active_record.log_runtime` : Inclut `ActiveRecord::Railties::ControllerRuntime` et `ActiveRecord::Railties::JobRuntime` qui sont responsables de la mesure du temps pris par les appels Active Record pour la requête et de son signalement dans le journal.

* `active_record.set_reloader_hooks` : Réinitialise toutes les connexions rechargées vers la base de données si `config.enable_reloading` est défini sur `true`.
* `active_record.add_watchable_files`: Ajoute les fichiers `schema.rb` et `structure.sql` aux fichiers surveillés.

* `active_job.logger`: Définit `ActiveJob::Base.logger` - s'il n'est pas déjà défini - sur `Rails.logger`.

* `active_job.set_configs`: Configure Active Job en utilisant les paramètres de `config.active_job` en envoyant les noms des méthodes en tant que setters à `ActiveJob::Base` et en passant les valeurs correspondantes.

* `action_mailer.logger`: Définit `ActionMailer::Base.logger` - s'il n'est pas déjà défini - sur `Rails.logger`.

* `action_mailer.set_configs`: Configure Action Mailer en utilisant les paramètres de `config.action_mailer` en envoyant les noms des méthodes en tant que setters à `ActionMailer::Base` et en passant les valeurs correspondantes.

* `action_mailer.compile_config_methods`: Initialise les méthodes pour les paramètres de configuration spécifiés afin de les rendre plus rapidement accessibles.

* `set_load_path`: Cet initialiseur s'exécute avant `bootstrap_hook`. Ajoute les chemins spécifiés par `config.load_paths` et tous les chemins d'autochargement à `$LOAD_PATH`.

* `set_autoload_paths`: Cet initialiseur s'exécute avant `bootstrap_hook`. Ajoute tous les sous-répertoires de `app` et les chemins spécifiés par `config.autoload_paths`, `config.eager_load_paths` et `config.autoload_once_paths` à `ActiveSupport::Dependencies.autoload_paths`.

* `add_routing_paths`: Charge (par défaut) tous les fichiers `config/routes.rb` (dans l'application et les railties, y compris les moteurs) et configure les routes pour l'application.

* `add_locales`: Ajoute les fichiers de `config/locales` (de l'application, des railties et des moteurs) à `I18n.load_path`, rendant les traductions disponibles.

* `add_view_paths`: Ajoute le répertoire `app/views` de l'application, des railties et des moteurs au chemin de recherche des fichiers de vue pour l'application.

* `add_mailer_preview_paths`: Ajoute le répertoire `test/mailers/previews` de l'application, des railties et des moteurs au chemin de recherche des fichiers de prévisualisation des mailers pour l'application.

* `load_environment_config`: Cet initialiseur s'exécute avant `load_environment_hook`. Charge le fichier `config/environments` pour l'environnement actuel.

* `prepend_helpers_path`: Ajoute le répertoire `app/helpers` de l'application, des railties et des moteurs au chemin de recherche des helpers pour l'application.

* `load_config_initializers`: Charge tous les fichiers Ruby de `config/initializers` dans l'application, les railties et les moteurs. Les fichiers de ce répertoire peuvent être utilisés pour contenir des paramètres de configuration qui doivent être définis après le chargement de tous les frameworks.

* `engines_blank_point`: Fournit un point d'initialisation pour se connecter si vous souhaitez effectuer des actions avant le chargement des moteurs. Après ce point, tous les initialiseurs des railties et des moteurs sont exécutés.

* `add_generator_templates`: Recherche les templates pour les générateurs dans `lib/templates` de l'application, des railties et des moteurs, et les ajoute au paramètre `config.generators.templates`, ce qui les rend disponibles pour tous les générateurs.

* `ensure_autoload_once_paths_as_subset`: Vérifie que `config.autoload_once_paths` ne contient que des chemins provenant de `config.autoload_paths`. Si des chemins supplémentaires sont présents, une exception sera levée.

* `add_to_prepare_blocks`: Le bloc pour chaque appel `config.to_prepare` dans l'application, une railtie ou un moteur est ajouté aux rappels `to_prepare` pour Action Dispatch, qui seront exécutés par requête en développement, ou avant la première requête en production.

* `add_builtin_route`: Si l'application s'exécute sous l'environnement de développement, cela ajoutera la route pour `rails/info/properties` aux routes de l'application. Cette route fournit des informations détaillées telles que la version de Rails et de Ruby pour `public/index.html` dans une application Rails par défaut.

* `build_middleware_stack`: Construit la pile de middleware pour l'application, renvoyant un objet qui a une méthode `call` qui prend un objet d'environnement Rack pour la requête.

* `eager_load!`: Si `config.eager_load` est `true`, exécute les hooks `config.before_eager_load` puis appelle `eager_load!` qui chargera tous les espaces de noms `config.eager_load_namespaces`.

* `finisher_hook`: Fournit un hook après la fin du processus d'initialisation de l'application, ainsi que l'exécution de tous les blocs `config.after_initialize` pour l'application, les railties et les moteurs.

* `set_routes_reloader_hook`: Configure Action Dispatch pour recharger le fichier de routes en utilisant `ActiveSupport::Callbacks.to_run`.

* `disable_dependency_loading`: Désactive le chargement automatique des dépendances si `config.eager_load` est défini sur `true`.


Pooling de base de données
--------------------------

Les connexions à la base de données d'Active Record sont gérées par `ActiveRecord::ConnectionAdapters::ConnectionPool`, qui garantit qu'un pool de connexions synchronise la quantité d'accès par thread à un nombre limité de connexions à la base de données. Cette limite est par défaut de 5 et peut être configurée dans `database.yml`.

```ruby
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

Étant donné que le pooling de connexions est géré à l'intérieur d'Active Record par défaut, tous les serveurs d'application (Thin, Puma, Unicorn, etc.) devraient se comporter de la même manière. Le pool de connexions à la base de données est initialement vide. À mesure que la demande de connexions augmente, il en créera jusqu'à atteindre la limite du pool de connexions.

Une requête quelconque vérifiera une connexion la première fois qu'elle nécessite un accès à la base de données. À la fin de la requête, elle vérifiera la connexion. Cela signifie que l'emplacement de connexion supplémentaire sera à nouveau disponible pour la prochaine requête dans la file d'attente.
Si vous essayez d'utiliser plus de connexions que celles disponibles, Active Record vous bloquera et attendra une connexion provenant du pool. Si elle ne peut pas obtenir une connexion, une erreur de délai d'attente similaire à celle ci-dessous sera renvoyée.

```ruby
ActiveRecord::ConnectionTimeoutError - could not obtain a database connection within 5.000 seconds (waited 5.000 seconds)
```

Si vous obtenez cette erreur, vous voudrez peut-être augmenter la taille du pool de connexions en incrémentant l'option `pool` dans `database.yml`.

NOTE. Si vous exécutez dans un environnement multi-thread, il se peut que plusieurs threads accèdent simultanément à plusieurs connexions. Donc, en fonction de votre charge de requêtes actuelle, vous pourriez très bien avoir plusieurs threads en concurrence pour un nombre limité de connexions.


Configuration personnalisée
--------------------

Vous pouvez configurer votre propre code via l'objet de configuration Rails avec une configuration personnalisée sous l'espace de noms `config.x` ou directement `config`. La principale différence entre les deux est que vous devriez utiliser `config.x` si vous définissez une configuration _imbriquée_ (ex: `config.x.nested.hi`), et simplement `config` pour une configuration _à un seul niveau_ (ex: `config.hello`).

```ruby
config.x.payment_processing.schedule = :daily
config.x.payment_processing.retries  = 3
config.super_debugger = true
```

Ces points de configuration sont ensuite disponibles via l'objet de configuration :

```ruby
Rails.configuration.x.payment_processing.schedule # => :daily
Rails.configuration.x.payment_processing.retries  # => 3
Rails.configuration.x.payment_processing.not_set  # => nil
Rails.configuration.super_debugger                # => true
```

Vous pouvez également utiliser `Rails::Application.config_for` pour charger des fichiers de configuration entiers :

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

`Rails::Application.config_for` prend en charge une configuration `shared` pour regrouper des configurations communes. La configuration partagée sera fusionnée dans la configuration de l'environnement.

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
# environnement de développement
Rails.application.config_for(:example)[:foo][:bar] #=> { baz: 1, qux: 2 }
```

Indexation des moteurs de recherche
-----------------------

Parfois, vous souhaiterez empêcher certaines pages de votre application d'être visibles sur des sites de recherche tels que Google, Bing, Yahoo ou Duck Duck Go. Les robots qui indexent ces sites analyseront d'abord le fichier `http://votre-site.com/robots.txt` pour savoir quelles pages ils sont autorisés à indexer.

Rails crée ce fichier pour vous à l'intérieur du dossier `/public`. Par défaut, il autorise les moteurs de recherche à indexer toutes les pages de votre application. Si vous souhaitez bloquer l'indexation sur toutes les pages de votre application, utilisez ceci :

```
User-agent: *
Disallow: /
```

Pour bloquer uniquement des pages spécifiques, il est nécessaire d'utiliser une syntaxe plus complexe. Apprenez-la dans la [documentation officielle](https://www.robotstxt.org/robotstxt.html).

Surveillance du système de fichiers événementiel
---------------------------

Si la gemme [listen](https://github.com/guard/listen) est chargée, Rails utilise un moniteur de système de fichiers événementiel pour détecter les modifications lorsque le rechargement est activé :

```ruby
group :development do
  gem 'listen', '~> 3.3'
end
```

Sinon, à chaque requête, Rails parcourt l'arborescence de l'application pour vérifier si quelque chose a changé.

Sur Linux et macOS, aucune gemme supplémentaire n'est nécessaire, mais certaines sont requises [pour *BSD](https://github.com/guard/listen#on-bsd) et [pour Windows](https://github.com/guard/listen#on-windows).

Notez que [certains configurations ne sont pas prises en charge](https://github.com/guard/listen#issues--limitations).
[`config.load_defaults`]: https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults
[`ActiveSupport::ParameterFilter.precompile_filters`]: https://api.rubyonrails.org/classes/ActiveSupport/ParameterFilter.html#method-c-precompile_filters
[ActiveModel::Error#full_message]: https://api.rubyonrails.org/classes/ActiveModel/Error.html#method-i-full_message
[`ActiveSupport::MessageEncryptor`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html
[`ActiveSupport::MessageVerifier`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html
[`message_serializer_fallback.active_support`]: active_support_instrumentation.html#message-serializer-fallback-active-support
[`Rails.application.deprecators`]: https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators
