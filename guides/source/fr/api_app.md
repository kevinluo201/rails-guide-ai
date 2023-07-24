**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fe858c0828e87f595c5d8c23c4b6326e
Utilisation de Rails pour les applications API-only
====================================================

Dans ce guide, vous apprendrez :

* Ce que Rails offre pour les applications API-only
* Comment configurer Rails pour démarrer sans fonctionnalités de navigateur
* Comment décider des middlewares que vous souhaitez inclure
* Comment décider des modules à utiliser dans votre contrôleur

--------------------------------------------------------------------------------

Qu'est-ce qu'une application API ?
----------------------------------

Traditionnellement, lorsque les gens disaient qu'ils utilisaient Rails comme une "API", ils voulaient dire qu'ils fournissaient une API accessible de manière programmable aux côtés de leur application web. Par exemple, GitHub fournit [une API](https://developer.github.com) que vous pouvez utiliser depuis vos propres clients personnalisés.

Avec l'avènement des frameworks côté client, de plus en plus de développeurs utilisent Rails pour construire un backend partagé entre leur application web et d'autres applications natives.

Par exemple, Twitter utilise son [API publique](https://developer.twitter.com/) dans son application web, qui est construite comme un site statique consommant des ressources JSON.

Au lieu d'utiliser Rails pour générer du HTML qui communique avec le serveur via des formulaires et des liens, de nombreux développeurs traitent leur application web comme un simple client API livré en HTML avec JavaScript qui consomme une API JSON.

Ce guide couvre la construction d'une application Rails qui sert des ressources JSON à un client API, y compris les frameworks côté client.

Pourquoi utiliser Rails pour les API JSON ?
-------------------------------------------

La première question que beaucoup de gens se posent lorsqu'ils envisagent de construire une API JSON en utilisant Rails est : "n'est-ce pas exagéré d'utiliser Rails pour générer du JSON ? Ne devrais-je pas simplement utiliser quelque chose comme Sinatra ?".

Pour les API très simples, cela peut être vrai. Cependant, même dans les applications très axées sur HTML, la plupart de la logique d'une application se trouve en dehors de la couche de vue.

La raison pour laquelle la plupart des gens utilisent Rails est qu'il fournit un ensemble de valeurs par défaut qui permet aux développeurs de démarrer rapidement, sans avoir à prendre beaucoup de décisions triviales.

Jetons un coup d'œil à certaines des fonctionnalités que Rails offre par défaut et qui sont toujours applicables aux applications API.

Gérées au niveau des middlewares :

- Rechargement : les applications Rails prennent en charge le rechargement transparent. Cela fonctionne même si votre application devient volumineuse et que le redémarrage du serveur pour chaque requête devient non viable.
- Mode développement : les applications Rails disposent de valeurs par défaut intelligentes pour le développement, ce qui rend le développement agréable sans compromettre les performances en production.
- Mode test : idem pour le mode développement.
- Journalisation : les applications Rails journalisent chaque requête, avec un niveau de verbosité adapté au mode actuel. Les journaux Rails en développement incluent des informations sur l'environnement de la requête, les requêtes de base de données et des informations de performance de base.
- Sécurité : Rails détecte et contrecarre les [attaques de spoofing IP](https://en.wikipedia.org/wiki/IP_address_spoofing) et gère les signatures cryptographiques de manière consciente des [attaques par synchronisation](https://en.wikipedia.org/wiki/Timing_attack). Vous ne savez pas ce qu'est une attaque de spoofing IP ou une attaque par synchronisation ? Exactement.
- Analyse des paramètres : vous souhaitez spécifier vos paramètres sous forme de JSON plutôt que sous forme de chaîne encodée d'URL ? Pas de problème. Rails décodera le JSON pour vous et le rendra disponible dans `params`. Vous souhaitez utiliser des paramètres imbriqués encodés d'URL ? Cela fonctionne également.
- GET conditionnels : Rails gère les en-têtes de requête de traitement conditionnel `GET` (`ETag` et `Last-Modified`) et renvoie les en-têtes et le code d'état de réponse corrects. Tout ce que vous avez à faire est d'utiliser la méthode [`stale?`](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F) dans votre contrôleur, et Rails gérera tous les détails HTTP pour vous.
- Requêtes HEAD : Rails convertira de manière transparente les requêtes `HEAD` en requêtes `GET` et ne renverra que les en-têtes. Cela permet de garantir le bon fonctionnement de `HEAD` dans toutes les API Rails.

Bien sûr, vous pourriez construire tout cela à partir de middlewares Rack existants, mais cette liste démontre que la pile de middlewares par défaut de Rails offre beaucoup de valeur, même si vous "générez simplement du JSON".

Gérées au niveau de la couche Action Pack :

- Routage basé sur les ressources : si vous construisez une API JSON RESTful, vous voulez utiliser le routeur Rails. Une correspondance propre et conventionnelle de HTTP vers les contrôleurs signifie ne pas avoir à passer du temps à réfléchir à la modélisation de votre API en termes de HTTP.
- Génération d'URL : le revers du routage est la génération d'URL. Une bonne API basée sur HTTP inclut des URL (voir [l'API GitHub Gist](https://docs.github.com/en/rest/reference/gists) pour un exemple).
- Réponses d'en-tête et de redirection : `head :no_content` et `redirect_to user_url(current_user)` sont pratiques. Bien sûr, vous pourriez ajouter manuellement les en-têtes de réponse, mais pourquoi ?
- Mise en cache : Rails fournit une mise en cache de page, d'action et de fragment. La mise en cache de fragment est particulièrement utile lors de la construction d'un objet JSON imbriqué.
- Authentification de base, Digest et par jeton : Rails prend en charge par défaut trois types d'authentification HTTP.
- Instrumentation : Rails dispose d'une API d'instrumentation qui déclenche des gestionnaires enregistrés pour une variété d'événements, tels que le traitement d'une action, l'envoi d'un fichier ou de données, la redirection et les requêtes de base de données. La charge utile de chaque événement est accompagnée d'informations pertinentes (pour l'événement de traitement d'action, la charge utile inclut le contrôleur, l'action, les paramètres, le format de la requête, la méthode de la requête et le chemin complet de la requête).
- Générateurs : il est souvent pratique de générer une ressource et d'obtenir votre modèle, votre contrôleur, vos stubs de test et vos routes créés pour vous en une seule commande pour des ajustements ultérieurs. Idem pour les migrations et autres.
- Plugins : de nombreuses bibliothèques tierces sont livrées avec le support de Rails qui réduisent ou éliminent le coût de la configuration et de l'assemblage de la bibliothèque et du framework web. Cela inclut des choses comme la substitution des générateurs par défaut, l'ajout de tâches Rake et le respect des choix de Rails (comme le journal et le cache).
Bien sûr, le processus de démarrage de Rails assemble également tous les composants enregistrés.
Par exemple, le processus de démarrage de Rails utilise votre fichier `config/database.yml`
lors de la configuration d'Active Record.

**La version courte est**: vous n'avez peut-être pas pensé aux parties de Rails
qui restent applicables même si vous supprimez la couche de vue, mais la réponse s'avère
être la plupart d'entre elles.

La configuration de base
-----------------------

Si vous construisez une application Rails qui sera d'abord et avant tout un serveur API, vous pouvez commencer avec un sous-ensemble plus limité de Rails et ajouter des fonctionnalités au besoin.

### Création d'une nouvelle application

Vous pouvez générer une nouvelle application Rails api :

```bash
$ rails new my_api --api
```

Cela fera trois choses principales pour vous :

- Configurer votre application pour commencer avec un ensemble plus limité de middleware
  que d'habitude. En particulier, il n'inclura pas par défaut de middleware principalement utiles
  pour les applications de navigateur (comme la prise en charge des cookies).
- Faire en sorte que `ApplicationController` hérite de `ActionController::API` au lieu de
  `ActionController::Base`. Comme pour le middleware, cela exclura tous les modules Action
  Controller qui fournissent des fonctionnalités principalement utilisées par les applications de navigateur.
- Configurer les générateurs pour sauter la génération de vues, d'aides et de ressources lors
  de la génération d'une nouvelle ressource.

### Génération d'une nouvelle ressource

Pour voir comment notre API nouvellement créée gère la génération d'une nouvelle ressource, créons
une nouvelle ressource Group. Chaque groupe aura un nom.

```bash
$ bin/rails g scaffold Group name:string
```

Avant de pouvoir utiliser notre code scaffoldé, nous devons mettre à jour notre schéma de base de données.

```bash
$ bin/rails db:migrate
```

Maintenant, si nous ouvrons notre `GroupsController`, nous devrions remarquer qu'avec une application Rails
API, nous ne rendons que des données JSON. Dans l'action index, nous interrogeons `Group.all`
et l'assignons à une variable d'instance appelée `@groups`. En le passant à `render` avec l'option
`:json`, les groupes seront automatiquement rendus en JSON.

```ruby
# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show update destroy ]

  # GET /groups
  def index
    @groups = Group.all

    render json: @groups
  end

  # GET /groups/1
  def show
    render json: @group
  end

  # POST /groups
  def create
    @group = Group.new(group_params)

    if @group.save
      render json: @group, status: :created, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name)
    end
end
```

Enfin, nous pouvons ajouter quelques groupes à notre base de données depuis la console Rails :

```irb
irb> Group.create(name: "Rails Founders")
irb> Group.create(name: "Rails Contributors")
```

Avec des données dans l'application, nous pouvons démarrer le serveur et visiter <http://localhost:3000/groups.json> pour voir nos données JSON.

```json
[
{"id":1, "name":"Rails Founders", "created_at": ...},
{"id":2, "name":"Rails Contributors", "created_at": ...}
]
```

### Modification d'une application existante

Si vous souhaitez prendre une application existante et en faire une application API, lisez les étapes suivantes.

Dans `config/application.rb`, ajoutez la ligne suivante en haut de la définition de la classe `Application` :

```ruby
config.api_only = true
```

Dans `config/environments/development.rb`, définissez [`config.debug_exception_response_format`][]
pour configurer le format utilisé dans les réponses en cas d'erreurs en mode développement.

Pour rendre une page HTML avec des informations de débogage, utilisez la valeur `:default`.

```ruby
config.debug_exception_response_format = :default
```

Pour rendre des informations de débogage en préservant le format de réponse, utilisez la valeur `:api`.

```ruby
config.debug_exception_response_format = :api
```

Par défaut, `config.debug_exception_response_format` est défini sur `:api`, lorsque `config.api_only` est défini sur true.

Enfin, à l'intérieur de `app/controllers/application_controller.rb`, au lieu de :

```ruby
class ApplicationController < ActionController::Base
end
```

faites :

```ruby
class ApplicationController < ActionController::API
end
```


Choix du middleware
--------------------

Une application API est livrée avec le middleware suivant par défaut :

- `ActionDispatch::HostAuthorization`
- `Rack::Sendfile`
- `ActionDispatch::Static`
- `ActionDispatch::Executor`
- `ActionDispatch::ServerTiming`
- `ActiveSupport::Cache::Strategy::LocalCache::Middleware`
- `Rack::Runtime`
- `ActionDispatch::RequestId`
- `ActionDispatch::RemoteIp`
- `Rails::Rack::Logger`
- `ActionDispatch::ShowExceptions`
- `ActionDispatch::DebugExceptions`
- `ActionDispatch::ActionableExceptions`
- `ActionDispatch::Reloader`
- `ActionDispatch::Callbacks`
- `ActiveRecord::Migration::CheckPending`
- `Rack::Head`
- `Rack::ConditionalGet`
- `Rack::ETag`

Consultez la section [middleware interne](rails_on_rack.html#internal-middleware-stack)
du guide Rack pour plus d'informations à leur sujet.

D'autres plugins, y compris Active Record, peuvent ajouter des middleware supplémentaires. En
général, ces middleware sont indépendants du type d'application que vous construisez et ont du sens dans une application Rails uniquement API.
Vous pouvez obtenir une liste de tous les middleware de votre application via :

```bash
$ bin/rails middleware
```

### Utilisation de Rack::Cache

Lorsqu'il est utilisé avec Rails, `Rack::Cache` utilise le cache de Rails pour ses
entités et ses métadonnées. Cela signifie que si vous utilisez memcache pour votre
application Rails, par exemple, le cache HTTP intégré utilisera memcache.

Pour utiliser `Rack::Cache`, vous devez d'abord ajouter la gemme `rack-cache`
à votre `Gemfile`, et définir `config.action_dispatch.rack_cache` sur `true`.
Pour activer sa fonctionnalité, vous voudrez utiliser `stale?` dans votre
contrôleur. Voici un exemple d'utilisation de `stale?`.

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

L'appel à `stale?` comparera l'en-tête `If-Modified-Since` de la requête
avec `@post.updated_at`. Si l'en-tête est plus récent que la dernière modification, cette
action renverra une réponse "304 Not Modified". Sinon, elle rendra la
réponse et inclura une en-tête `Last-Modified` dedans.

Normalement, ce mécanisme est utilisé pour chaque client. `Rack::Cache`
nous permet de partager ce mécanisme de mise en cache entre les clients. Nous pouvons activer
la mise en cache entre clients dans l'appel à `stale?` :

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end
end
```

Cela signifie que `Rack::Cache` stockera la valeur `Last-Modified`
pour une URL dans le cache de Rails, et ajoutera une en-tête `If-Modified-Since` à toute
requête entrante ultérieure pour la même URL.

Pensez-y comme à une mise en cache de page utilisant des sémantiques HTTP.

### Utilisation de Rack::Sendfile

Lorsque vous utilisez la méthode `send_file` à l'intérieur d'un contrôleur Rails, elle définit l'en-tête
`X-Sendfile`. `Rack::Sendfile` est responsable de l'envoi réel du fichier.

Si votre serveur frontal prend en charge l'envoi accéléré de fichiers, `Rack::Sendfile`
déléguera le travail d'envoi réel du fichier au serveur frontal.

Vous pouvez configurer le nom de l'en-tête que votre serveur frontal utilise à cette fin en utilisant [`config.action_dispatch.x_sendfile_header`][] dans le fichier de configuration de l'environnement approprié.

Vous pouvez en savoir plus sur l'utilisation de `Rack::Sendfile` avec des
serveurs frontal populaires dans [la documentation de Rack::Sendfile](https://www.rubydoc.info/gems/rack/Rack/Sendfile).

Voici quelques valeurs pour cet en-tête pour certains serveurs populaires, une fois que ces serveurs sont configurés pour prendre en charge
l'envoi accéléré de fichiers :

```ruby
# Apache et lighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

Assurez-vous de configurer votre serveur pour prendre en charge ces options en suivant les
instructions de la documentation de `Rack::Sendfile`.


### Utilisation de ActionDispatch::Request

`ActionDispatch::Request#params` récupère les paramètres du client au format JSON
et les rend disponibles dans votre contrôleur via `params`.

Pour utiliser cela, votre client devra effectuer une requête avec des paramètres encodés en JSON
et spécifier le `Content-Type` comme `application/json`.

Voici un exemple avec jQuery :

```js
jQuery.ajax({
  type: 'POST',
  url: '/people',
  dataType: 'json',
  contentType: 'application/json',
  data: JSON.stringify({ person: { firstName: "Yehuda", lastName: "Katz" } }),
  success: function(json) { }
});
```

`ActionDispatch::Request` détectera le `Content-Type` et vos paramètres
seront :

```ruby
{ person: { firstName: "Yehuda", lastName: "Katz" } }
```

### Utilisation des middlewares de session

Les middlewares suivants, utilisés pour la gestion des sessions, sont exclus des applications API car ils n'ont généralement pas besoin de sessions. Si l'un de vos clients API est un navigateur, vous voudrez peut-être en ajouter un de nouveau :

- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

La difficulté pour les ajouter à nouveau est que, par défaut, ils reçoivent `session_options`
lorsqu'ils sont ajoutés (y compris la clé de session), vous ne pouvez donc pas simplement ajouter un initialiseur `session_store.rb`, ajouter
`use ActionDispatch::Session::CookieStore` et avoir des sessions qui fonctionnent normalement. (Pour être clair : les sessions
peuvent fonctionner, mais vos options de session seront ignorées, c'est-à-dire que la clé de session sera définie par défaut sur `_session_id`)

Au lieu de l'initialiseur, vous devrez définir les options pertinentes quelque part avant la construction de votre middleware (comme `config/application.rb`) et les passer à votre middleware préféré, comme ceci :

```ruby
# Cela configure également session_options pour une utilisation ultérieure
config.session_store :cookie_store, key: '_interslice_session'

# Requis pour toutes les gestions de session (indépendamment de session_store)
config.middleware.use ActionDispatch::Cookies

config.middleware.use config.session_store, config.session_options
```

### Autres middlewares

Rails est livré avec plusieurs autres middlewares que vous voudrez peut-être utiliser dans une
application API, surtout si l'un de vos clients API est le navigateur :

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`

Vous pouvez ajouter l'un de ces middlewares via :

```ruby
config.middleware.use Rack::MethodOverride
```

### Suppression de middlewares

Si vous ne souhaitez pas utiliser un middleware inclus par défaut dans l'ensemble des middlewares de l'API,
vous pouvez le supprimer avec :
```ruby
config.middleware.delete ::Rack::Sendfile
```

Gardez à l'esprit que la suppression de ces middlewares supprimera la prise en charge de certaines fonctionnalités dans Action Controller.

Choisir les modules de contrôleur
--------------------------------

Une application API (utilisant `ActionController::API`) est livrée avec les modules de contrôleur suivants par défaut :

|   |   |
|---|---|
| `ActionController::UrlFor` | Rend `url_for` et des helpers similaires disponibles. |
| `ActionController::Redirecting` | Prise en charge de `redirect_to`. |
| `AbstractController::Rendering` et `ActionController::ApiRendering` | Prise en charge de base pour le rendu. |
| `ActionController::Renderers::All` | Prise en charge de `render :json` et des amis. |
| `ActionController::ConditionalGet` | Prise en charge de `stale?`. |
| `ActionController::BasicImplicitRender` | S'assure de renvoyer une réponse vide s'il n'y en a pas de explicite. |
| `ActionController::StrongParameters` | Prise en charge du filtrage des paramètres en combinaison avec l'assignation de masse Active Model. |
| `ActionController::DataStreaming` | Prise en charge de `send_file` et `send_data`. |
| `AbstractController::Callbacks` | Prise en charge de `before_action` et des helpers similaires. |
| `ActionController::Rescue` | Prise en charge de `rescue_from`. |
| `ActionController::Instrumentation` | Prise en charge des hooks d'instrumentation définis par Action Controller (voir [le guide d'instrumentation](active_support_instrumentation.html#action-controller) pour plus d'informations à ce sujet). |
| `ActionController::ParamsWrapper` | Enveloppe le hachage de paramètres dans un hachage imbriqué, de sorte que vous n'ayez pas à spécifier les éléments racine lors de l'envoi de requêtes POST par exemple.
| `ActionController::Head` | Prise en charge du renvoi d'une réponse sans contenu, uniquement des en-têtes. |

D'autres plugins peuvent ajouter des modules supplémentaires. Vous pouvez obtenir une liste de tous les modules inclus dans `ActionController::API` dans la console Rails :

```irb
irb> ActionController::API.ancestors - ActionController::Metal.ancestors
=> [ActionController::API,
    ActiveRecord::Railties::ControllerRuntime,
    ActionDispatch::Routing::RouteSet::MountedHelpers,
    ActionController::ParamsWrapper,
    ... ,
    AbstractController::Rendering,
    ActionView::ViewPaths]
```

### Ajout d'autres modules

Tous les modules d'Action Controller connaissent leurs modules dépendants, vous pouvez donc inclure librement n'importe quel module dans vos contrôleurs, et toutes les dépendances seront incluses et configurées également.

Voici quelques modules courants que vous voudrez peut-être ajouter :

- `AbstractController::Translation` : Prise en charge des méthodes de localisation et de traduction `l` et `t`.
- Prise en charge de l'authentification HTTP de base, digest ou par jeton :
  * `ActionController::HttpAuthentication::Basic::ControllerMethods`
  * `ActionController::HttpAuthentication::Digest::ControllerMethods`
  * `ActionController::HttpAuthentication::Token::ControllerMethods`
- `ActionView::Layouts` : Prise en charge des mises en page lors du rendu.
- `ActionController::MimeResponds` : Prise en charge de `respond_to`.
- `ActionController::Cookies` : Prise en charge de `cookies`, qui inclut la prise en charge des cookies signés et chiffrés. Cela nécessite le middleware des cookies.
- `ActionController::Caching` : Prise en charge de la mise en cache de la vue pour le contrôleur API. Veuillez noter que vous devrez spécifier manuellement le magasin de cache à l'intérieur du contrôleur comme ceci :

    ```ruby
    class ApplicationController < ActionController::API
      include ::ActionController::Caching
      self.cache_store = :mem_cache_store
    end
    ```

    Rails ne transmet pas cette configuration automatiquement.

Le meilleur endroit pour ajouter un module est dans votre `ApplicationController`, mais vous pouvez également ajouter des modules à des contrôleurs individuels.
[`config.debug_exception_response_format`]: configuring.html#config-debug-exception-response-format
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
