**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 48f8290cbf9190673c32a3eb9777acba
Rails sur Rack
=============

Ce guide couvre l'intégration de Rails avec Rack et l'interface avec d'autres composants Rack.

Après avoir lu ce guide, vous saurez :

* Comment utiliser les middlewares Rack dans vos applications Rails.
* La pile de middlewares interne d'Action Pack.
* Comment définir une pile de middlewares personnalisée.

--------------------------------------------------------------------------------

AVERTISSEMENT : Ce guide suppose une connaissance pratique du protocole Rack et des concepts Rack tels que les middlewares, les cartes d'URL et `Rack::Builder`.

Introduction à Rack
--------------------

Rack fournit une interface minimale, modulaire et adaptable pour développer des applications web en Ruby. En enveloppant les requêtes et les réponses HTTP de la manière la plus simple possible, il unifie et condense l'API des serveurs web, des frameworks web et des logiciels intermédiaires (les middlewares) en un seul appel de méthode.

Expliquer comment fonctionne Rack n'est pas vraiment dans le cadre de ce guide. Si vous n'êtes pas familier avec les bases de Rack, vous devriez consulter la section [Ressources](#resources) ci-dessous.

Rails sur Rack
-------------

### Objet Rack de l'application Rails

`Rails.application` est l'objet principal d'application Rack d'une application Rails. Tout serveur web compatible Rack devrait utiliser l'objet `Rails.application` pour servir une application Rails.

### `bin/rails server`

`bin/rails server` se charge de créer un objet `Rack::Server` et de démarrer le serveur web.

Voici comment `bin/rails server` crée une instance de `Rack::Server` :

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

Le `Rails::Server` hérite de `Rack::Server` et appelle la méthode `Rack::Server#start` de cette manière :

```ruby
class Server < ::Rack::Server
  def start
    # ...
    super
  end
end
```

### `rackup`

Pour utiliser `rackup` au lieu de `bin/rails server` de Rails, vous pouvez mettre le code suivant dans `config.ru` du répertoire racine de votre application Rails :

```ruby
# Rails.root/config.ru
require_relative "config/environment"
run Rails.application
```

Et démarrer le serveur :

```bash
$ rackup config.ru
```

Pour en savoir plus sur les différentes options de `rackup`, vous pouvez exécuter :

```bash
$ rackup --help
```

### Développement et rechargement automatique

Les middlewares sont chargés une fois et ne sont pas surveillés pour les modifications. Vous devrez redémarrer le serveur pour que les modifications soient prises en compte dans l'application en cours d'exécution.

Pile de middlewares d'Action Dispatcher
----------------------------------

De nombreux composants internes d'Action Dispatcher sont implémentés sous forme de middlewares Rack. `Rails::Application` utilise `ActionDispatch::MiddlewareStack` pour combiner divers middlewares internes et externes afin de former une application Rails Rack complète.

REMARQUE : `ActionDispatch::MiddlewareStack` est l'équivalent de Rails de `Rack::Builder`, mais il est conçu pour offrir une meilleure flexibilité et plus de fonctionnalités pour répondre aux besoins de Rails.

### Inspection de la pile de middlewares

Rails dispose d'une commande pratique pour inspecter la pile de middlewares utilisée :

```bash
$ bin/rails middleware
```

Pour une application Rails fraîchement générée, cela pourrait produire quelque chose comme :

```ruby
use ActionDispatch::HostAuthorization
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
use ActionDispatch::ServerTiming
use ActiveSupport::Cache::Strategy::LocalCache::Middleware
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use ActionDispatch::RemoteIp
use Sprockets::Rails::QuietAssets
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use WebConsole::Middleware
use ActionDispatch::DebugExceptions
use ActionDispatch::ActionableExceptions
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::Migration::CheckPending
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ContentSecurityPolicy::Middleware
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
use Rack::TempfileReaper
run MyApp::Application.routes
```

Les middlewares par défaut affichés ici (et quelques autres) sont résumés dans la section [Middlewares internes](#internal-middleware-stack) ci-dessous.

### Configuration de la pile de middlewares

Rails fournit une interface de configuration simple [`config.middleware`][] pour ajouter, supprimer et modifier les middlewares dans la pile de middlewares via `application.rb` ou le fichier de configuration spécifique à l'environnement `environments/<environment>.rb`.


#### Ajout d'un middleware

Vous pouvez ajouter un nouveau middleware à la pile de middlewares en utilisant l'une des méthodes suivantes :

* `config.middleware.use(new_middleware, args)` - Ajoute le nouveau middleware au bas de la pile de middlewares.

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - Ajoute le nouveau middleware avant le middleware existant spécifié dans la pile de middlewares.

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - Ajoute le nouveau middleware après le middleware existant spécifié dans la pile de middlewares.

```ruby
# config/application.rb

# Ajouter Rack::BounceFavicon en bas
config.middleware.use Rack::BounceFavicon

# Ajouter Lifo::Cache après ActionDispatch::Executor.
# Passez l'argument { page_cache: false } à Lifo::Cache.
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### Remplacement d'un middleware

Vous pouvez remplacer un middleware existant dans la pile de middlewares en utilisant `config.middleware.swap`.

```ruby
# config/application.rb

# Remplacer ActionDispatch::ShowExceptions par Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### Déplacement d'un middleware

Vous pouvez déplacer un middleware existant dans la pile de middlewares en utilisant `config.middleware.move_before` et `config.middleware.move_after`.

```ruby
# config/application.rb

# Déplacer ActionDispatch::ShowExceptions avant Lifo::ShowExceptions
config.middleware.move_before Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

```ruby
# config/application.rb

# Déplacer ActionDispatch::ShowExceptions après Lifo::ShowExceptions
config.middleware.move_after Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

#### Suppression d'un middleware
Ajoutez les lignes suivantes à la configuration de votre application :

```ruby
# config/application.rb
config.middleware.delete Rack::Runtime
```

Maintenant, si vous inspectez la pile de middleware, vous constaterez que `Rack::Runtime` n'en fait plus partie.

```bash
$ bin/rails middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
...
run Rails.application.routes
```

Si vous souhaitez supprimer les middlewares liés à la session, faites ce qui suit :

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash
```

Et pour supprimer les middlewares liés au navigateur,

```ruby
# config/application.rb
config.middleware.delete Rack::MethodOverride
```

Si vous souhaitez qu'une erreur soit générée lorsque vous essayez de supprimer un élément inexistant, utilisez `delete!` à la place.

```ruby
# config/application.rb
config.middleware.delete! ActionDispatch::Executor
```

### Pile de middleware interne

Une grande partie de la fonctionnalité de Action Controller est implémentée sous forme de middlewares. La liste suivante explique le but de chacun d'entre eux :

**`ActionDispatch::HostAuthorization`**

* Protège contre les attaques de rebinding DNS en autorisant explicitement les hôtes vers lesquels une requête peut être envoyée. Consultez le [guide de configuration](configuring.html#actiondispatch-hostauthorization) pour les instructions de configuration.

**`Rack::Sendfile`**

* Définit l'en-tête X-Sendfile spécifique au serveur. Configurez cela via l'option [`config.action_dispatch.x_sendfile_header`][].

**`ActionDispatch::Static`**

* Utilisé pour servir les fichiers statiques du répertoire public. Désactivé si [`config.public_file_server.enabled`][] est `false`.

**`Rack::Lock`**

* Définit le drapeau `env["rack.multithread"]` sur `false` et enveloppe l'application dans un Mutex.

**`ActionDispatch::Executor`**

* Utilisé pour le rechargement du code en toute sécurité lors du développement.

**`ActionDispatch::ServerTiming`**

* Définit un en-tête [`Server-Timing`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server-Timing) contenant des mesures de performance pour la requête.

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* Utilisé pour le cache en mémoire. Ce cache n'est pas thread-safe.

**`Rack::Runtime`**

* Définit un en-tête X-Runtime contenant le temps (en secondes) nécessaire pour exécuter la requête.

**`Rack::MethodOverride`**

* Permet de substituer la méthode si `params[:_method]` est défini. Il s'agit du middleware qui prend en charge les types de méthode HTTP PUT et DELETE.

**`ActionDispatch::RequestId`**

* Rend un en-tête `X-Request-Id` unique disponible pour la réponse et active la méthode `ActionDispatch::Request#request_id`.

**`ActionDispatch::RemoteIp`**

* Vérifie les attaques de spoofing IP.

**`Sprockets::Rails::QuietAssets`**

* Supprime la sortie du journal pour les requêtes d'assets.

**`Rails::Rack::Logger`**

* Notifie les journaux que la requête a commencé. Après la fin de la requête, tous les journaux sont vidés.

**`ActionDispatch::ShowExceptions`**

* Récupère toute exception renvoyée par l'application et appelle une application d'exceptions qui l'encapsulera dans un format adapté à l'utilisateur final.

**`ActionDispatch::DebugExceptions`**

* Responsable de la journalisation des exceptions et de l'affichage d'une page de débogage en cas de requête locale.

**`ActionDispatch::ActionableExceptions`**

* Fournit un moyen de déclencher des actions à partir des pages d'erreur de Rails.

**`ActionDispatch::Reloader`**

* Fournit des rappels de préparation et de nettoyage, destinés à faciliter le rechargement du code pendant le développement.

**`ActionDispatch::Callbacks`**

* Fournit des rappels à exécuter avant et après la distribution de la requête.

**`ActiveRecord::Migration::CheckPending`**

* Vérifie les migrations en attente et génère une erreur `ActiveRecord::PendingMigrationError` si des migrations sont en attente.

**`ActionDispatch::Cookies`**

* Définit les cookies pour la requête.

**`ActionDispatch::Session::CookieStore`**

* Responsable du stockage de la session dans les cookies.

**`ActionDispatch::Flash`**

* Configure les clés flash. Disponible uniquement si [`config.session_store`][] est défini sur une valeur.

**`ActionDispatch::ContentSecurityPolicy::Middleware`**

* Fournit un DSL pour configurer un en-tête Content-Security-Policy.

**`Rack::Head`**

* Convertit les requêtes HEAD en requêtes `GET` et les sert en tant que telles.

**`Rack::ConditionalGet`**

* Ajoute la prise en charge des "Conditional `GET`" afin que le serveur ne réponde rien si la page n'a pas été modifiée.

**`Rack::ETag`**

* Ajoute l'en-tête ETag à tous les corps de chaîne. Les ETags sont utilisés pour valider le cache.

**`Rack::TempfileReaper`**

* Nettoie les fichiers temporaires utilisés pour mettre en mémoire tampon les requêtes multipart.

CONSEIL : Il est possible d'utiliser l'un des middlewares ci-dessus dans votre pile Rack personnalisée.

Ressources
---------

### Apprendre Rack

* [Site officiel de Rack](https://rack.github.io)
* [Présentation de Rack](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### Comprendre les middlewares

* [Railscast sur les middlewares Rack](http://railscasts.com/episodes/151-rack-middleware)
[`config.middleware`]: configuring.html#config-middleware
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.session_store`]: configuring.html#config-session-store
