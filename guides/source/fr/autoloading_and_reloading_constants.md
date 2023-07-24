**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f53b3a12c263256fbbe154cfc8b2f4d
Chargement automatique et rechargement des constantes
=====================================================

Ce guide documente le fonctionnement du chargement automatique et du rechargement en mode `zeitwerk`.

Après avoir lu ce guide, vous saurez :

* Configuration Rails associée
* Structure du projet
* Chargement automatique, rechargement et chargement anticipé
* Héritage de table unique
* Et plus encore

--------------------------------------------------------------------------------

Introduction
------------

INFO. Ce guide documente le chargement automatique, le rechargement et le chargement anticipé dans les applications Rails.

Dans un programme Ruby ordinaire, vous chargez explicitement les fichiers qui définissent les classes et modules que vous souhaitez utiliser. Par exemple, le contrôleur suivant fait référence à `ApplicationController` et `Post`, et vous émettriez normalement des appels `require` pour eux :

```ruby
# NE FAITES PAS CECI.
require "application_controller"
require "post"
# NE FAITES PAS CECI.

class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Ce n'est pas le cas dans les applications Rails, où les classes et modules de l'application sont simplement disponibles partout sans appels `require` :

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Rails les _charge automatiquement_ pour vous si nécessaire. Cela est possible grâce à quelques chargeurs [Zeitwerk](https://github.com/fxn/zeitwerk) que Rails configure pour vous, qui fournissent le chargement automatique, le rechargement et le chargement anticipé.

D'autre part, ces chargeurs ne gèrent rien d'autre. En particulier, ils ne gèrent pas la bibliothèque standard Ruby, les dépendances des gemmes, les composants Rails eux-mêmes, ou même (par défaut) le répertoire `lib` de l'application. Ce code doit être chargé comme d'habitude.


Structure du projet
-------------------

Dans une application Rails, les noms de fichiers doivent correspondre aux constantes qu'ils définissent, les répertoires agissant comme des espaces de noms.

Par exemple, le fichier `app/helpers/users_helper.rb` doit définir `UsersHelper` et le fichier `app/controllers/admin/payments_controller.rb` doit définir `Admin::PaymentsController`.

Par défaut, Rails configure Zeitwerk pour inférer les noms de fichiers avec `String#camelize`. Par exemple, il s'attend à ce que `app/controllers/users_controller.rb` définisse la constante `UsersController` car c'est ce que renvoie `"users_controller".camelize`.

La section _Personnalisation des inflexions_ ci-dessous documente les moyens de remplacer cette valeur par défaut.

Veuillez consulter la [documentation de Zeitwerk](https://github.com/fxn/zeitwerk#file-structure) pour plus de détails.

config.autoload_paths
---------------------

Nous faisons référence à la liste des répertoires de l'application dont le contenu doit être chargé automatiquement et (éventuellement) rechargé en tant que _chemins de chargement automatique_. Par exemple, `app/models`. Ces répertoires représentent l'espace de noms racine : `Object`.

INFO. Les chemins de chargement automatique sont appelés _répertoires racines_ dans la documentation de Zeitwerk, mais nous utiliserons "chemin de chargement automatique" dans ce guide.

À l'intérieur d'un chemin de chargement automatique, les noms de fichiers doivent correspondre aux constantes qu'ils définissent, comme documenté [ici](https://github.com/fxn/zeitwerk#file-structure).

Par défaut, les chemins de chargement automatique d'une application sont constitués de tous les sous-répertoires de `app` qui existent lorsque l'application démarre --- à l'exception de `assets`, `javascript` et `views` --- plus les chemins de chargement automatique des moteurs sur lesquels elle pourrait dépendre.

Par exemple, si `UsersHelper` est implémenté dans `app/helpers/users_helper.rb`, le module est chargé automatiquement, vous n'avez pas besoin (et ne devez pas écrire) un appel `require` pour cela :

```bash
$ bin/rails runner 'p UsersHelper'
UsersHelper
```

Rails ajoute automatiquement des répertoires personnalisés sous `app` aux chemins de chargement automatique. Par exemple, si votre application a `app/presenters`, vous n'avez pas besoin de configurer quoi que ce soit pour charger automatiquement les présentateurs ; cela fonctionne directement.

Le tableau des chemins de chargement automatique par défaut peut être étendu en ajoutant à `config.autoload_paths`, dans `config/application.rb` ou `config/environments/*.rb`. Par exemple :

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_paths << "#{root}/extras"
  end
end
```

De plus, les moteurs peuvent ajouter dans le corps de la classe du moteur et dans leurs propres `config/environments/*.rb`.

AVERTISSEMENT. Veuillez ne pas modifier `ActiveSupport::Dependencies.autoload_paths` ; l'interface publique pour modifier les chemins de chargement automatique est `config.autoload_paths`.

AVERTISSEMENT : Vous ne pouvez pas charger automatiquement du code dans les chemins de chargement automatique pendant le démarrage de l'application. En particulier, directement dans `config/initializers/*.rb`. Veuillez consulter [_Chargement automatique au démarrage de l'application_](#chargement-automatique-au-démarrage-de-l'application) ci-dessous pour connaître les méthodes valides pour le faire.

Les chemins de chargement automatique sont gérés par le chargeur automatique `Rails.autoloaders.main`.

config.autoload_lib(ignore:)
----------------------------

Par défaut, le répertoire `lib` ne fait pas partie des chemins de chargement automatique des applications ou des moteurs.

La méthode de configuration `config.autoload_lib` ajoute le répertoire `lib` à `config.autoload_paths` et `config.eager_load_paths`. Elle doit être appelée depuis `config/application.rb` ou `config/environments/*.rb`, et elle n'est pas disponible pour les moteurs.

Normalement, `lib` a des sous-répertoires qui ne doivent pas être gérés par les chargeurs automatiques. Veuillez passer leur nom relatif à `lib` dans l'argument de mot-clé `ignore` requis. Par exemple :

```ruby
config.autoload_lib(ignore: %w(assets tasks))
```

Pourquoi ? Alors que `assets` et `tasks` partagent le répertoire `lib` avec le code régulier, leur contenu n'est pas destiné à être chargé automatiquement ou chargé en avance. `Assets` et `Tasks` ne sont pas des espaces de noms Ruby là-bas. Il en va de même avec les générateurs si vous en avez.
```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

`config.autoload_lib` n'est pas disponible avant la version 7.1, mais vous pouvez toujours l'émuler tant que l'application utilise Zeitwerk :

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.main.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

config.autoload_once_paths
--------------------------

Vous pouvez vouloir être en mesure de charger automatiquement des classes et des modules sans les recharger. La configuration `autoload_once_paths` stocke du code qui peut être chargé automatiquement, mais qui ne sera pas rechargé.

Par défaut, cette collection est vide, mais vous pouvez l'étendre en ajoutant à `config.autoload_once_paths`. Vous pouvez le faire dans `config/application.rb` ou `config/environments/*.rb`. Par exemple :

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_once_paths << "#{root}/app/serializers"
  end
end
```

Les moteurs peuvent également ajouter du code dans le corps de la classe du moteur et dans leurs propres `config/environments/*.rb`.

INFO. Si `app/serializers` est ajouté à `config.autoload_once_paths`, Rails ne considère plus cela comme un chemin de chargement automatique, bien que ce soit un répertoire personnalisé sous `app`. Ce paramètre remplace cette règle.

Cela est essentiel pour les classes et les modules qui sont mis en cache dans des emplacements qui survivent aux rechargements, comme le framework Rails lui-même.

Par exemple, les sérialiseurs Active Job sont stockés à l'intérieur de Active Job :

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

et Active Job lui-même n'est pas rechargé lorsqu'il y a un rechargement, seul le code de l'application et des moteurs dans les chemins de chargement automatique l'est.

Rendre `MoneySerializer` rechargable serait déroutant, car recharger une version modifiée n'aurait aucun effet sur cet objet de classe stocké dans Active Job. En effet, si `MoneySerializer` était rechargable, à partir de Rails 7, un tel initialiseur lèverait une `NameError`.

Un autre cas d'utilisation est lorsque les moteurs décorent des classes du framework :

```ruby
initializer "decorate ActionController::Base" do
  ActiveSupport.on_load(:action_controller_base) do
    include MyDecoration
  end
end
```

Là, l'objet de module stocké dans `MyDecoration` au moment où l'initialiseur s'exécute devient un ancêtre de `ActionController::Base`, et recharger `MyDecoration` est inutile, cela n'affectera pas cette chaîne d'ancêtres.

Les classes et les modules des chemins de chargement automatique une fois peuvent être chargés automatiquement dans `config/initializers`. Ainsi, avec cette configuration, cela fonctionne :

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

INFO : Techniquement, vous pouvez charger automatiquement des classes et des modules gérés par le chargeur automatique `once` dans n'importe quel initialiseur qui s'exécute après `:bootstrap_hook`.

Les chemins de chargement automatique une fois sont gérés par `Rails.autoloaders.once`.

config.autoload_lib_once(ignore:)
---------------------------------

La méthode `config.autoload_lib_once` est similaire à `config.autoload_lib`, à la différence qu'elle ajoute `lib` à `config.autoload_once_paths` à la place. Elle doit être appelée depuis `config/application.rb` ou `config/environments/*.rb`, et elle n'est pas disponible pour les moteurs.

En appelant `config.autoload_lib_once`, les classes et les modules dans `lib` peuvent être chargés automatiquement, même à partir des initialiseurs de l'application, mais ne seront pas rechargés.

`config.autoload_lib_once` n'est pas disponible avant la version 7.1, mais vous pouvez toujours l'émuler tant que l'application utilise Zeitwerk :

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_once_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.once.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

$LOAD_PATH{#load_path}
----------

Les chemins de chargement automatique sont ajoutés à `$LOAD_PATH` par défaut. Cependant, Zeitwerk utilise des noms de fichiers absolus en interne, et votre application ne doit pas émettre d'appels `require` pour les fichiers pouvant être chargés automatiquement, donc ces répertoires ne sont en réalité pas nécessaires là-bas. Vous pouvez désactiver cela avec ce paramètre :

```ruby
config.add_autoload_paths_to_load_path = false
```

Cela peut accélérer un peu les appels `require` légitimes, car il y a moins de recherches. De plus, si votre application utilise [Bootsnap](https://github.com/Shopify/bootsnap), cela évite à la bibliothèque de construire des index inutiles, ce qui réduit la consommation de mémoire.

Le répertoire `lib` n'est pas affecté par ce paramètre, il est toujours ajouté à `$LOAD_PATH`.

Rechargement
---------

Rails recharge automatiquement les classes et les modules si les fichiers de l'application dans les chemins de chargement automatique changent.

Plus précisément, si le serveur web est en cours d'exécution et que les fichiers de l'application ont été modifiés, Rails décharge toutes les constantes chargées automatiquement gérées par le chargeur automatique `main` juste avant que la requête suivante ne soit traitée. Ainsi, les classes ou modules de l'application utilisés pendant cette requête seront à nouveau chargés automatiquement, ce qui leur permet de prendre en compte leur implémentation actuelle dans le système de fichiers.

Le rechargement peut être activé ou désactivé. Le paramètre qui contrôle ce comportement est [`config.enable_reloading`][], qui est `true` par défaut en mode `development`, et `false` par défaut en mode `production`. Pour des raisons de compatibilité ascendante, Rails prend également en charge `config.cache_classes`, qui est équivalent à `!config.enable_reloading`.

Rails utilise un moniteur de fichiers événementiel pour détecter les modifications de fichiers par défaut. Il peut également être configuré pour détecter les modifications de fichiers en parcourant les chemins de chargement automatique. Cela est contrôlé par le paramètre [`config.file_watcher`][].

Dans une console Rails, aucun moniteur de fichiers n'est actif, quelle que soit la valeur de `config.enable_reloading`. Cela est dû au fait qu'il serait normalement déroutant de recharger du code en plein milieu d'une session console. Tout comme une requête individuelle, vous voulez généralement qu'une session console soit servie par un ensemble cohérent et non modifié de classes et de modules d'application.
Cependant, vous pouvez forcer un rechargement dans la console en exécutant `reload!` :

```irb
irb(main):001:0> User.object_id
=> 70136277390120
irb(main):002:0> reload!
Rechargement...
=> true
irb(main):003:0> User.object_id
=> 70136284426020
```

Comme vous pouvez le voir, l'objet de classe stocké dans la constante `User` est différent après le rechargement.


### Rechargement et objets obsolètes

Il est très important de comprendre que Ruby n'a pas de moyen de recharger véritablement les classes et modules en mémoire et de refléter cela partout où ils sont déjà utilisés. Techniquement, "décharger" la classe `User` signifie supprimer la constante `User` via `Object.send(:remove_const, "User")`.

Par exemple, regardez cette session de console Rails :

```irb
irb> joe = User.new
irb> reload!
irb> alice = User.new
irb> joe.class == alice.class
=> false
```

`joe` est une instance de la classe `User` d'origine. Lorsqu'il y a un rechargement, la constante `User` est alors évaluée comme une classe différente rechargée. `alice` est une instance de la nouvelle classe `User` chargée, mais `joe` ne l'est pas - sa classe est obsolète. Vous pouvez redéfinir `joe`, démarrer une sous-session IRB ou simplement lancer une nouvelle console au lieu d'appeler `reload!`.

Une autre situation dans laquelle vous pouvez rencontrer cette difficulté est la sous-classe de classes rechargeables dans un endroit qui n'est pas rechargé :

```ruby
# lib/vip_user.rb
class VipUser < User
end
```

si `User` est rechargé, puisque `VipUser` ne l'est pas, la superclasse de `VipUser` est l'objet de classe original obsolète.

En résumé : **ne mettez pas en cache les classes ou modules rechargeables**.

## Chargement automatique lors du démarrage de l'application

Lors du démarrage, les applications peuvent être chargées automatiquement à partir des chemins de chargement automatique une fois, qui sont gérés par le chargeur automatique `once`. Veuillez consulter la section [`config.autoload_once_paths`](#config-autoload-once-paths) ci-dessus.

Cependant, vous ne pouvez pas charger automatiquement à partir des chemins de chargement automatique, qui sont gérés par le chargeur automatique `main`. Cela s'applique au code dans `config/initializers` ainsi qu'aux initialiseurs d'application ou de moteurs.

Pourquoi ? Les initialiseurs ne s'exécutent qu'une seule fois, au démarrage de l'application. Ils ne s'exécutent pas à nouveau lors des rechargements. Si un initialiseur utilisait une classe ou un module rechargeable, les modifications qui leur sont apportées ne seraient pas reflétées dans ce code initial, devenant ainsi obsolètes. Par conséquent, il est interdit de faire référence à des constantes rechargeables pendant l'initialisation.

Voyons ce qu'il faut faire à la place.

### Cas d'utilisation 1 : Pendant le démarrage, charger du code rechargeable

#### Chargement automatique au démarrage et à chaque rechargement

Imaginons que `ApiGateway` soit une classe rechargeable et que vous ayez besoin de configurer son point de terminaison pendant le démarrage de l'application :

```ruby
# config/initializers/api_gateway_setup.rb
ApiGateway.endpoint = "https://example.com" # NameError
```

Les initialiseurs ne peuvent pas faire référence à des constantes rechargeables, vous devez encapsuler cela dans un bloc `to_prepare`, qui s'exécute au démarrage et après chaque rechargement :

```ruby
# config/initializers/api_gateway_setup.rb
Rails.application.config.to_prepare do
  ApiGateway.endpoint = "https://example.com" # CORRECT
end
```

REMARQUE : Pour des raisons historiques, ce rappel peut s'exécuter deux fois. Le code qu'il exécute doit être idempotent.

#### Chargement automatique au démarrage uniquement

Les classes et modules rechargeables peuvent également être chargés automatiquement dans des blocs `after_initialize`. Ceux-ci s'exécutent au démarrage, mais ne s'exécutent pas à nouveau lors des rechargements. Dans certains cas exceptionnels, cela peut être ce que vous voulez.

Les vérifications préliminaires en sont un exemple d'utilisation :

```ruby
# config/initializers/check_admin_presence.rb
Rails.application.config.after_initialize do
  unless Role.where(name: "admin").exists?
    abort "Le rôle d'administrateur n'est pas présent, veuillez initialiser la base de données."
  end
end
```

### Cas d'utilisation 2 : Pendant le démarrage, charger du code qui reste mis en cache

Certaines configurations prennent un objet de classe ou de module et le stockent dans un endroit qui n'est pas rechargé. Il est important que ceux-ci ne soient pas rechargeables, car les modifications ne seraient pas reflétées dans ces objets mis en cache obsolètes.

Un exemple est le middleware :

```ruby
config.middleware.use MyApp::Middleware::Foo
```

Lorsque vous rechargez, la pile de middleware n'est pas affectée, il serait donc déroutant que `MyApp::Middleware::Foo` soit rechargeable. Les modifications de sa mise en œuvre n'auraient aucun effet.

Un autre exemple concerne les sérialiseurs Active Job :

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

Quoi que `MoneySerializer` évalue lors de l'initialisation, il est ajouté aux sérialiseurs personnalisés, et cet objet reste là lors des rechargements.

Un autre exemple concerne les railties ou les moteurs qui décorent les classes du framework en incluant des modules. Par exemple, [`turbo-rails`](https://github.com/hotwired/turbo-rails) décore `ActiveRecord::Base` de cette manière :

```ruby
initializer "turbo.broadcastable" do
  ActiveSupport.on_load(:active_record) do
    include Turbo::Broadcastable
  end
end
```

Cela ajoute un objet de module à la chaîne des ancêtres de `ActiveRecord::Base`. Les modifications apportées à `Turbo::Broadcastable` n'auraient aucun effet si elles étaient rechargées, la chaîne des ancêtres aurait toujours l'originale.

Corollaire : Ces classes ou modules **ne peuvent pas être rechargeables**.

La manière la plus simple de faire référence à ces classes ou modules pendant le démarrage est de les définir dans un répertoire qui n'appartient pas aux chemins de chargement automatique. Par exemple, `lib` est un choix idiomatique. Il n'appartient pas aux chemins de chargement automatique par défaut, mais il appartient à `$LOAD_PATH`. Il suffit d'effectuer un `require` normal pour le charger.
Comme indiqué ci-dessus, une autre option consiste à avoir le répertoire qui les définit dans l'autoload une fois les chemins et l'autoload. Veuillez consulter la [section sur config.autoload_once_paths](#config-autoload-once-paths) pour plus de détails.

### Cas d'utilisation 3 : Configuration des classes d'application pour les moteurs

Supposons qu'un moteur fonctionne avec la classe d'application rechargeable qui modélise les utilisateurs et dispose d'un point de configuration pour cela :

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = User # NameError
end
```

Pour bien fonctionner avec le code d'application rechargeable, le moteur a besoin que les applications configurent le _nom_ de cette classe :

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = "User" # OK
end
```

Ensuite, au moment de l'exécution, `config.user_model.constantize` vous donne l'objet de classe actuel.

Chargement anticipé
-------------------

Dans des environnements similaires à la production, il est généralement préférable de charger tout le code de l'application lorsque celle-ci démarre. Le chargement anticipé met tout en mémoire, prêt à répondre immédiatement aux demandes, et est également compatible avec [CoW](https://en.wikipedia.org/wiki/Copy-on-write).

Le chargement anticipé est contrôlé par le drapeau [`config.eager_load`][], qui est désactivé par défaut dans tous les environnements sauf `production`. Lorsqu'une tâche Rake est exécutée, `config.eager_load` est remplacé par [`config.rake_eager_load`][], qui est `false` par défaut. Ainsi, par défaut, dans les environnements de production, les tâches Rake ne chargent pas l'application de manière anticipée.

L'ordre dans lequel les fichiers sont chargés de manière anticipée n'est pas défini.

Lors du chargement anticipé, Rails invoque `Zeitwerk::Loader.eager_load_all`. Cela garantit que toutes les dépendances de gemmes gérées par Zeitwerk sont également chargées de manière anticipée.



Héritage de table unique
------------------------

L'héritage de table unique ne fonctionne pas bien avec le chargement paresseux : Active Record doit être conscient des hiérarchies STI pour fonctionner correctement, mais lors du chargement paresseux, les classes sont précisément chargées uniquement sur demande !

Pour résoudre cette incompatibilité fondamentale, nous devons précharger les STI. Il existe quelques options pour y parvenir, avec différents compromis. Voyons-les.

### Option 1 : Activer le chargement anticipé

La manière la plus simple de précharger les STI est d'activer le chargement anticipé en définissant :

```ruby
config.eager_load = true
```

dans `config/environments/development.rb` et `config/environments/test.rb`.

C'est simple, mais cela peut être coûteux car cela charge de manière anticipée l'ensemble de l'application au démarrage et à chaque rechargement. Le compromis peut en valoir la peine pour les petites applications, cependant.

### Option 2 : Précharger un répertoire regroupé

Stockez les fichiers qui définissent la hiérarchie dans un répertoire dédié, ce qui a également du sens conceptuellement. Le répertoire n'est pas destiné à représenter un espace de noms, il a pour seul but de regrouper les STI :

```
app/models/shapes/shape.rb
app/models/shapes/circle.rb
app/models/shapes/square.rb
app/models/shapes/triangle.rb
```

Dans cet exemple, nous voulons toujours que `app/models/shapes/circle.rb` définisse `Circle`, et non `Shapes::Circle`. Cela peut être une préférence personnelle pour simplifier les choses et éviter également les refontes dans les bases de code existantes. La fonctionnalité de [regroupement](https://github.com/fxn/zeitwerk#collapsing-directories) de Zeitwerk nous permet de le faire :

```ruby
# config/initializers/preload_stis.rb

shapes = "#{Rails.root}/app/models/shapes"
Rails.autoloaders.main.collapse(shapes) # Pas un espace de noms.

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir(shapes)
  end
end
```

Dans cette option, nous chargeons de manière anticipée ces quelques fichiers au démarrage et les rechargeons même si le STI n'est pas utilisé. Cependant, à moins que votre application n'ait beaucoup de STI, cela n'aura aucun impact mesurable.

INFO : La méthode `Zeitwerk::Loader#eager_load_dir` a été ajoutée dans Zeitwerk 2.6.2. Pour les anciennes versions, vous pouvez toujours répertorier le répertoire `app/models/shapes` et appeler `require_dependency` sur son contenu.

AVERTISSEMENT : Si des modèles sont ajoutés, modifiés ou supprimés de la STI, le rechargement fonctionne comme prévu. Cependant, si une nouvelle hiérarchie STI séparée est ajoutée à l'application, vous devrez modifier l'initialiseur et redémarrer le serveur.

### Option 3 : Précharger un répertoire régulier

Similaire à la précédente, mais le répertoire est destiné à être un espace de noms. C'est-à-dire que `app/models/shapes/circle.rb` est censé définir `Shapes::Circle`.

Pour celle-ci, l'initialiseur est le même, sauf qu'aucun regroupement n'est configuré :

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/shapes")
  end
end
```

Mêmes compromis.

### Option 4 : Précharger les types depuis la base de données

Dans cette option, nous n'avons pas besoin d'organiser les fichiers d'une manière quelconque, mais nous interrogeons la base de données :

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    types = Shape.unscoped.select(:type).distinct.pluck(:type)
    types.compact.each(&:constantize)
  end
end
```

AVERTISSEMENT : La STI fonctionnera correctement même si la table ne contient pas tous les types, mais les méthodes telles que `subclasses` ou `descendants` ne renverront pas les types manquants.

AVERTISSEMENT : Si des modèles sont ajoutés, modifiés ou supprimés de la STI, le rechargement fonctionne comme prévu. Cependant, si une nouvelle hiérarchie STI séparée est ajoutée à l'application, vous devrez modifier l'initialiseur et redémarrer le serveur.
Personnalisation des inflexions
-----------------------

Par défaut, Rails utilise `String#camelize` pour savoir quelle constante un fichier ou un nom de répertoire donné doit définir. Par exemple, `posts_controller.rb` doit définir `PostsController` car c'est ce que renvoie `"posts_controller".camelize`.

Il se peut que certains noms de fichiers ou de répertoires ne soient pas inflexionnés comme vous le souhaitez. Par exemple, `html_parser.rb` est censé définir `HtmlParser` par défaut. Et si vous préférez que la classe soit `HTMLParser` ? Il existe plusieurs façons de personnaliser cela.

La façon la plus simple est de définir des acronymes :

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "HTML"
  inflect.acronym "SSL"
end
```

Cela affecte la façon dont Active Support inflexe globalement. Cela peut être bien dans certaines applications, mais vous pouvez également personnaliser la façon de cameliser les noms de fichiers individuels indépendamment d'Active Support en passant une collection de remplacements aux inflecteurs par défaut :

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

Cette technique dépend toujours de `String#camelize`, car c'est ce que les inflecteurs par défaut utilisent en dernier recours. Si vous préférez ne pas du tout dépendre des inflexions d'Active Support et avoir un contrôle absolu sur les inflexions, configurez les inflecteurs comme des instances de `Zeitwerk::Inflector` :

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector = Zeitwerk::Inflector.new
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

Il n'y a pas de configuration globale qui puisse affecter ces instances ; elles sont déterministes.

Vous pouvez même définir un inflecteur personnalisé pour une flexibilité totale. Veuillez consulter la [documentation de Zeitwerk](https://github.com/fxn/zeitwerk#custom-inflector) pour plus de détails.

### Où placer la personnalisation des inflexions ?

Si une application n'utilise pas le chargeur `once`, les extraits de code ci-dessus peuvent être placés dans `config/initializers`. Par exemple, `config/initializers/inflections.rb` pour le cas d'utilisation d'Active Support, ou `config/initializers/zeitwerk.rb` pour les autres cas.

Les applications utilisant le chargeur `once` doivent déplacer ou charger cette configuration à partir du corps de la classe d'application dans `config/application.rb`, car le chargeur `once` utilise l'inflecteur tôt dans le processus de démarrage.

Espaces de noms personnalisés
-----------------

Comme nous l'avons vu précédemment, les chemins de chargement automatique représentent l'espace de noms de premier niveau : `Object`.

Prenons par exemple `app/services`. Ce répertoire n'est pas généré par défaut, mais s'il existe, Rails l'ajoute automatiquement aux chemins de chargement automatique.

Par défaut, le fichier `app/services/users/signup.rb` est censé définir `Users::Signup`, mais que faire si vous préférez que tout ce sous-arbre soit sous un espace de noms `Services` ? Eh bien, avec les paramètres par défaut, cela peut être réalisé en créant un sous-répertoire : `app/services/services`.

Cependant, selon vos préférences, cela peut ne pas vous sembler correct. Vous préféreriez peut-être que `app/services/users/signup.rb` définisse simplement `Services::Users::Signup`.

Zeitwerk prend en charge les [espaces de noms racine personnalisés](https://github.com/fxn/zeitwerk#custom-root-namespaces) pour résoudre ce cas d'utilisation, et vous pouvez personnaliser le chargeur `main` pour y parvenir :

```ruby
# config/initializers/autoloading.rb

# L'espace de noms doit exister.
#
# Dans cet exemple, nous définissons le module sur place. Il pourrait également être créé
# ailleurs et sa définition chargée ici avec un simple `require`. Dans
# tous les cas, `push_dir` attend un objet de classe ou de module.
module Services; end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/services", namespace: Services)
```

Rails < 7.1 ne prend pas en charge cette fonctionnalité, mais vous pouvez toujours ajouter ce code supplémentaire dans le même fichier et le faire fonctionner :

```ruby
# Code supplémentaire pour les applications exécutées sur Rails < 7.1.
app_services_dir = "#{Rails.root}/app/services" # doit être une chaîne de caractères
ActiveSupport::Dependencies.autoload_paths.delete(app_services_dir)
Rails.application.config.watchable_dirs[app_services_dir] = [:rb]
```

Les espaces de noms personnalisés sont également pris en charge pour le chargeur `once`. Cependant, comme celui-ci est configuré plus tôt dans le processus de démarrage, la configuration ne peut pas être effectuée dans un initialiseur d'application. Au lieu de cela, veuillez le placer dans `config/application.rb`, par exemple.

Chargement automatique et moteurs
-----------------------

Les moteurs s'exécutent dans le contexte d'une application parente, et leur code est chargé automatiquement, rechargé et chargé de manière anticipée par l'application parente. Si l'application s'exécute en mode `zeitwerk`, le code du moteur est chargé en mode `zeitwerk`. Si l'application s'exécute en mode `classic`, le code du moteur est chargé en mode `classic`.

Lorsque Rails démarre, les répertoires des moteurs sont ajoutés aux chemins de chargement automatique, et du point de vue du chargeur automatique, il n'y a pas de différence. Les principales entrées des chargeurs automatiques sont les chemins de chargement automatique, et qu'ils appartiennent à l'arborescence source de l'application ou à l'arborescence source d'un moteur est sans importance.

Par exemple, cette application utilise [Devise](https://github.com/heartcombo/devise) :

```
% bin/rails runner 'pp ActiveSupport::Dependencies.autoload_paths'
[".../app/controllers",
 ".../app/controllers/concerns",
 ".../app/helpers",
 ".../app/models",
 ".../app/models/concerns",
 ".../gems/devise-4.8.0/app/controllers",
 ".../gems/devise-4.8.0/app/helpers",
 ".../gems/devise-4.8.0/app/mailers"]
 ```

Si le moteur contrôle le mode de chargement automatique de son application parente, le moteur peut être écrit comme d'habitude.
Cependant, si un moteur prend en charge Rails 6 ou Rails 6.1 et ne contrôle pas ses applications parentes, il doit être prêt à s'exécuter en mode `classic` ou en mode `zeitwerk`. Voici quelques points à prendre en compte :

1. Si le mode `classic` nécessite un appel `require_dependency` pour garantir le chargement d'une constante à un moment donné, écrivez-le. Bien que `zeitwerk` n'en ait pas besoin, cela ne fera pas de mal, cela fonctionnera également en mode `zeitwerk`.

2. Le mode `classic` utilise des noms de constantes en minuscules avec des traits de soulignement ("User" -> "user.rb"), tandis que le mode `zeitwerk` utilise des noms de fichiers en camel case ("user.rb" -> "User"). Ils coïncident dans la plupart des cas, mais pas lorsque des séries de lettres majuscules consécutives sont présentes, comme dans "HTMLParser". La manière la plus simple d'être compatible est d'éviter de tels noms. Dans ce cas, choisissez "HtmlParser".

3. En mode `classic`, le fichier `app/model/concerns/foo.rb` peut définir à la fois `Foo` et `Concerns::Foo`. En mode `zeitwerk`, il n'y a qu'une seule option : il doit définir `Foo`. Pour être compatible, définissez `Foo`.

Test
-------

### Test manuel

La tâche `zeitwerk:check` vérifie si l'arborescence du projet respecte les conventions de nommage attendues et est pratique pour les vérifications manuelles. Par exemple, si vous migrez du mode `classic` au mode `zeitwerk`, ou si vous corrigez quelque chose :

```
% bin/rails zeitwerk:check
Attendez, je charge l'application.
Tout est bon !
```

Il peut y avoir une sortie supplémentaire en fonction de la configuration de l'application, mais le dernier "Tout est bon !" est ce que vous recherchez.

### Test automatisé

Il est bon de vérifier dans la suite de tests que le projet se charge correctement.

Cela couvre la conformité du nommage Zeitwerk et d'autres conditions d'erreur possibles. Veuillez consulter la [section sur les tests de chargement anticipé](testing.html#testing-eager-loading) dans le guide [_Testing Rails Applications_](testing.html).

Dépannage
---------------

La meilleure façon de suivre ce que font les chargeurs est d'inspecter leur activité.

La manière la plus simple de le faire est d'inclure

```ruby
Rails.autoloaders.log!
```

dans `config/application.rb` après le chargement des paramètres par défaut du framework. Cela affichera des traces sur la sortie standard.

Si vous préférez les enregistrer dans un fichier, configurez plutôt ceci :

```ruby
Rails.autoloaders.logger = Logger.new("#{Rails.root}/log/autoloading.log")
```

Le journal de Rails n'est pas encore disponible lorsque `config/application.rb` s'exécute. Si vous préférez utiliser le journal de Rails, configurez ce paramètre dans un initialiseur à la place :

```ruby
# config/initializers/log_autoloaders.rb
Rails.autoloaders.logger = Rails.logger
```

Rails.autoloaders
-----------------

Les instances Zeitwerk qui gèrent votre application sont disponibles à l'adresse suivante :

```ruby
Rails.autoloaders.main
Rails.autoloaders.once
```

Le prédicat

```ruby
Rails.autoloaders.zeitwerk_enabled?
```

est toujours disponible dans les applications Rails 7 et renvoie `true`.
[`config.enable_reloading`]: configuring.html#config-enable-reloading
[`config.file_watcher`]: configuring.html#config-file-watcher
[`config.eager_load`]: configuring.html#config-eager-load
[`config.rake_eager_load`]: configuring.html#config-rake-eager-load
