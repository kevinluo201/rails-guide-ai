**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9c6201fd526077579ef792e0c4e2150d
Guide classique vers Zeitwerk HOWTO
=========================

Ce guide documente comment migrer les applications Rails du mode "classique" au mode "zeitwerk".

Après avoir lu ce guide, vous saurez :

* Quels sont les modes "classique" et "zeitwerk"
* Pourquoi passer du mode "classique" au mode "zeitwerk"
* Comment activer le mode "zeitwerk"
* Comment vérifier que votre application fonctionne en mode "zeitwerk"
* Comment vérifier que votre projet se charge correctement en ligne de commande
* Comment vérifier que votre projet se charge correctement dans la suite de tests
* Comment résoudre d'éventuels problèmes spécifiques
* Les nouvelles fonctionnalités de Zeitwerk que vous pouvez exploiter

--------------------------------------------------------------------------------

Quels sont les modes "classique" et "zeitwerk" ?
--------------------------------------------------------

Depuis le début et jusqu'à Rails 5, Rails utilisait un chargeur automatique implémenté dans Active Support. Ce chargeur automatique est connu sous le nom de "classique" et est toujours disponible dans Rails 6.x. Rails 7 ne comprend plus ce chargeur automatique.

À partir de Rails 6, Rails est livré avec une nouvelle et meilleure façon de charger automatiquement, qui délègue au gem [Zeitwerk](https://github.com/fxn/zeitwerk). C'est le mode "zeitwerk". Par défaut, les applications chargées avec les paramètres par défaut des frameworks 6.0 et 6.1 s'exécutent en mode "zeitwerk", et c'est le seul mode disponible dans Rails 7.


Pourquoi passer du mode "classique" au mode "zeitwerk" ?
----------------------------------------

Le chargeur automatique "classique" a été extrêmement utile, mais il présentait un certain nombre de [problèmes](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#common-gotchas) qui rendaient le chargement automatique un peu délicat et confus parfois. Zeitwerk a été développé pour résoudre cela, entre autres [motivations](https://github.com/fxn/zeitwerk#motivation).

Lors de la mise à niveau vers Rails 6.x, il est fortement recommandé de passer en mode "zeitwerk" car c'est un meilleur chargeur automatique, le mode "classique" est déprécié.

Rails 7 met fin à la période de transition et ne comprend pas le mode "classique".

Je suis effrayé
-----------

Ne le soyez pas :).

Zeitwerk a été conçu pour être aussi compatible que possible avec le chargeur automatique classique. Si vous avez une application fonctionnant correctement avec le chargement automatique aujourd'hui, il y a de fortes chances que le passage se fasse facilement. De nombreux projets, grands et petits, ont signalé des transitions très fluides.

Ce guide vous aidera à changer de chargeur automatique en toute confiance.

Si, pour une raison quelconque, vous rencontrez une situation que vous ne savez pas comment résoudre, n'hésitez pas à [ouvrir un problème dans `rails/rails`](https://github.com/rails/rails/issues/new) et à taguer [`@fxn`](https://github.com/fxn).


Comment activer le mode "zeitwerk" ?
-------------------------------

### Applications exécutant Rails 5.x ou moins

Dans les applications exécutant une version de Rails antérieure à 6.0, le mode "zeitwerk" n'est pas disponible. Vous devez être au moins en Rails 6.0.

### Applications exécutant Rails 6.x

Dans les applications exécutant Rails 6.x, il existe deux scénarios.

Si l'application charge les paramètres par défaut du framework de Rails 6.0 ou 6.1 et s'exécute en mode "classique", elle doit être désactivée manuellement. Vous devez avoir quelque chose de similaire à ceci :

```ruby
# config/application.rb
config.load_defaults 6.0
config.autoloader = :classic # SUPPRIMEZ CETTE LIGNE
```

Comme indiqué, supprimez simplement la substitution, le mode "zeitwerk" est le mode par défaut.

D'autre part, si l'application charge d'anciens paramètres par défaut du framework, vous devez activer explicitement le mode "zeitwerk" :

```ruby
# config/application.rb
config.load_defaults 5.2
config.autoloader = :zeitwerk
```

### Applications exécutant Rails 7

Dans Rails 7, il n'y a que le mode "zeitwerk", vous n'avez rien à faire pour l'activer.

En effet, dans Rails 7, le setter `config.autoloader=` n'existe même pas. Si `config/application.rb` l'utilise, veuillez supprimer la ligne.


Comment vérifier que l'application s'exécute en mode "zeitwerk" ?
------------------------------------------------------

Pour vérifier que l'application s'exécute en mode "zeitwerk", exécutez la commande suivante :

```
bin/rails runner 'p Rails.autoloaders.zeitwerk_enabled?'
```

Si cela affiche `true`, le mode "zeitwerk" est activé.


Mon application est-elle conforme aux conventions de Zeitwerk ?
-----------------------------------------------------

### config.eager_load_paths

Le test de conformité ne s'applique qu'aux fichiers chargés de manière anticipée. Par conséquent, afin de vérifier la conformité de Zeitwerk, il est recommandé d'avoir tous les chemins de chargement automatique dans les chemins de chargement anticipé.

C'est déjà le cas par défaut, mais si le projet a des chemins de chargement automatique personnalisés configurés comme ceci :

```ruby
config.autoload_paths << "#{Rails.root}/extras"
```

ceux-ci ne sont pas chargés de manière anticipée et ne seront pas vérifiés. Les ajouter aux chemins de chargement anticipé est facile :

```ruby
config.autoload_paths << "#{Rails.root}/extras"
config.eager_load_paths << "#{Rails.root}/extras"
```

### zeitwerk:check

Une fois le mode "zeitwerk" activé et la configuration des chemins de chargement anticipé vérifiée, veuillez exécuter :

```
bin/rails zeitwerk:check
```

Un test réussi ressemble à ceci :

```
% bin/rails zeitwerk:check
Attendez, je charge l'application de manière anticipée.
Tout va bien !
```

Il peut y avoir une sortie supplémentaire en fonction de la configuration de l'application, mais le dernier "Tout va bien !" est ce que vous recherchez.
Si la double vérification expliquée dans la section précédente a déterminé qu'il doit effectivement y avoir des chemins d'autoload personnalisés en dehors des chemins de chargement anticipé, la tâche les détectera et vous avertira à leur sujet. Cependant, si la suite de tests charge ces fichiers avec succès, tout va bien.

Maintenant, si un fichier ne définit pas la constante attendue, la tâche vous le signalera. Elle le fait un fichier à la fois, car si elle passait à autre chose, l'échec de chargement d'un fichier pourrait entraîner d'autres échecs sans rapport avec la vérification que nous voulons effectuer et le rapport d'erreur serait confus.

S'il y a une constante signalée, corrigez celle-ci en particulier et exécutez à nouveau la tâche. Répétez jusqu'à obtenir "Tout va bien !".

Prenons par exemple :

```
% bin/rails zeitwerk:check
Attendez, je charge l'application avec impatience.
Le fichier app/models/vat.rb était censé définir la constante Vat
```

La TVA est une taxe européenne. Le fichier `app/models/vat.rb` définit `VAT`, mais le chargeur automatique s'attend à `Vat`, pourquoi ?

### Acronymes

Il s'agit du type de divergence le plus courant que vous pouvez rencontrer, cela concerne les acronymes. Commençons par comprendre pourquoi nous obtenons ce message d'erreur.

Le chargeur automatique classique est capable de charger automatiquement `VAT` car son entrée est le nom de la constante manquante, `VAT`, il invoque `underscore` sur celui-ci, ce qui donne `vat`, et recherche un fichier appelé `vat.rb`. Cela fonctionne.

L'entrée du nouveau chargeur automatique est le système de fichiers. Étant donné le fichier `vat.rb`, Zeitwerk invoque `camelize` sur `vat`, ce qui donne `Vat`, et s'attend à ce que le fichier définisse la constante `Vat`. C'est ce que dit le message d'erreur.

La correction est facile, il vous suffit d'indiquer à l'inflecteur cet acronyme :

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "VAT"
end
```

Cela affecte la façon dont Active Support inflecte globalement. Cela peut être bien, mais si vous préférez, vous pouvez également passer des remplacements aux inflecteurs utilisés par les chargeurs automatiques :

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.inflector.inflect("vat" => "VAT")
```

Avec cette option, vous avez plus de contrôle, car seuls les fichiers appelés exactement `vat.rb` ou les répertoires appelés exactement `vat` seront inflectés en tant que `VAT`. Un fichier appelé `vat_rules.rb` n'est pas affecté par cela et peut très bien définir `VatRules`. Cela peut être pratique si le projet présente ce genre d'incohérences de dénomination.

Avec cela en place, la vérification réussit !

```
% bin/rails zeitwerk:check
Attendez, je charge l'application avec impatience.
Tout va bien !
```

Une fois que tout va bien, il est recommandé de continuer à valider le projet dans la suite de tests. La section [_Vérifier la conformité de Zeitwerk dans la suite de tests_](#check-zeitwerk-compliance-in-the-test-suite) explique comment faire cela.

### Concerns

Vous pouvez charger automatiquement et charger avec impatience à partir d'une structure standard avec des sous-répertoires `concerns` comme

```
app/models
app/models/concerns
```

Par défaut, `app/models/concerns` appartient aux chemins d'autoload et il est donc supposé être un répertoire racine. Ainsi, par défaut, `app/models/concerns/foo.rb` doit définir `Foo`, et non `Concerns::Foo`.

Si votre application utilise `Concerns` comme espace de noms, vous avez deux options :

1. Supprimez l'espace de noms `Concerns` de ces classes et modules et mettez à jour le code client.
2. Laissez les choses telles quelles en supprimant `app/models/concerns` des chemins d'autoload :

  ```ruby
  # config/initializers/zeitwerk.rb
  ActiveSupport::Dependencies.
    autoload_paths.
    delete("#{Rails.root}/app/models/concerns")
  ```

### Présence de `app` dans les chemins d'autoload

Certains projets veulent que quelque chose comme `app/api/base.rb` définisse `API::Base`, et ajoutent `app` aux chemins d'autoload pour y parvenir.

Étant donné que Rails ajoute automatiquement tous les sous-répertoires de `app` aux chemins d'autoload (avec quelques exceptions), nous avons une autre situation dans laquelle il y a des répertoires racines imbriqués, similaire à ce qui se passe avec `app/models/concerns`. Cette configuration ne fonctionne plus telle quelle.

Cependant, vous pouvez conserver cette structure, il vous suffit de supprimer `app/api` des chemins d'autoload dans un initialiseur :

```ruby
# config/initializers/zeitwerk.rb
ActiveSupport::Dependencies.
  autoload_paths.
  delete("#{Rails.root}/app/api")
```

Attention aux sous-répertoires qui n'ont pas de fichiers à charger avec impatience. Par exemple, si l'application a `app/admin` avec des ressources pour [ActiveAdmin](https://activeadmin.info/), vous devez les ignorer. De même pour `assets` et ses amis :

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.ignore(
  "app/admin",
  "app/assets",
  "app/javascripts",
  "app/views"
)
```

Sans cette configuration, l'application chargerait ces arbres avec impatience. Elle échouerait sur `app/admin` car ses fichiers ne définissent pas de constantes, et elle définirait un module `Views`, par exemple, en tant qu'effet secondaire indésirable.

Comme vous pouvez le voir, avoir `app` dans les chemins d'autoload est techniquement possible, mais un peu délicat.

### Constantes chargées automatiquement et espaces de noms explicites

Si un espace de noms est défini dans un fichier, comme `Hotel` ici :
```
app/models/hotel.rb         # Définit Hotel.
app/models/hotel/pricing.rb # Définit Hotel::Pricing.
```

la constante `Hotel` doit être définie à l'aide des mots-clés `class` ou `module`. Par exemple :

```ruby
class Hotel
end
```

est correct.

Des alternatives comme

```ruby
Hotel = Class.new
```

ou

```ruby
Hotel = Struct.new
```

ne fonctionneront pas, les objets enfants comme `Hotel::Pricing` ne seront pas trouvés.

Cette restriction s'applique uniquement aux espaces de noms explicites. Les classes et modules qui ne définissent pas d'espace de noms peuvent être définis en utilisant ces idiomes.

### Un fichier, une constante (au même niveau supérieur)

En mode `classic`, vous pouvez techniquement définir plusieurs constantes au même niveau supérieur et les recharger toutes. Par exemple, étant donné

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

alors que `Bar` ne pourrait pas être chargé automatiquement, le chargement automatique de `Foo` marquerait également `Bar` comme chargé automatiquement.

Ce n'est pas le cas en mode `zeitwerk`, vous devez déplacer `Bar` dans son propre fichier `bar.rb`. Un fichier, une constante de niveau supérieur.

Cela ne concerne que les constantes au même niveau supérieur que dans l'exemple ci-dessus. Les classes et modules internes sont corrects. Par exemple, considérez

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

Si l'application recharge `Foo`, elle rechargera également `Foo::InnerClass`.

### Globs dans `config.autoload_paths`

Attention aux configurations qui utilisent des caractères génériques comme

```ruby
config.autoload_paths += Dir["#{config.root}/extras/**/"]
```

Chaque élément de `config.autoload_paths` doit représenter l'espace de noms de niveau supérieur (`Object`). Cela ne fonctionnera pas.

Pour corriger cela, supprimez simplement les caractères génériques :

```ruby
config.autoload_paths << "#{config.root}/extras"
```

### Décoration de classes et modules provenant de moteurs

Si votre application décore des classes ou des modules provenant d'un moteur, il est probable qu'elle fasse quelque chose comme ceci quelque part :

```ruby
config.to_prepare do
  Dir.glob("#{Rails.root}/app/overrides/**/*_override.rb").sort.each do |override|
    require_dependency override
  end
end
```

Cela doit être mis à jour : vous devez indiquer au chargeur automatique `main` d'ignorer le répertoire des remplacements, et vous devez les charger avec `load` à la place. Quelque chose comme ceci :

```ruby
overrides = "#{Rails.root}/app/overrides"
Rails.autoloaders.main.ignore(overrides)
config.to_prepare do
  Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
    load override
  end
end
```

### `before_remove_const`

Rails 3.1 a ajouté la prise en charge d'un rappel appelé `before_remove_const` qui était invoqué si une classe ou un module répondait à cette méthode et allait être rechargé. Ce rappel est resté autrement non documenté et il est peu probable que votre code l'utilise.

Cependant, au cas où il le ferait, vous pouvez réécrire quelque chose comme

```ruby
class Country < ActiveRecord::Base
  def self.before_remove_const
    expire_redis_cache
  end
end
```

comme

```ruby
# config/initializers/country.rb
if Rails.application.config.reloading_enabled?
  Rails.autoloaders.main.on_unload("Country") do |klass, _abspath|
    klass.expire_redis_cache
  end
end
```

### Spring et l'environnement `test`

Spring recharge le code de l'application si quelque chose change. Dans l'environnement `test`, vous devez activer le rechargement pour que cela fonctionne :

```ruby
# config/environments/test.rb
config.cache_classes = false
```

ou, depuis Rails 7.1 :

```ruby
# config/environments/test.rb
config.enable_reloading = true
```

Sinon, vous obtiendrez :

```
reloading is disabled because config.cache_classes is true
```

ou

```
reloading is disabled because config.enable_reloading is false
```

Cela n'a pas d'impact sur les performances.

### Bootsnap

Assurez-vous de dépendre au moins de Bootsnap 1.4.4.


Vérifier la conformité de Zeitwerk dans la suite de tests
-------------------------------------------------------

La tâche `zeitwerk:check` est pratique lors de la migration. Une fois que le projet est conforme, il est recommandé d'automatiser cette vérification. Pour ce faire, il suffit de charger l'application de manière anticipée, ce que fait précisément `zeitwerk:check`.

### Intégration continue

Si votre projet dispose d'une intégration continue, il est conseillé de charger l'application de manière anticipée lorsque la suite s'exécute. Si l'application ne peut pas être chargée de manière anticipée pour une raison quelconque, vous voulez le savoir en CI, mieux qu'en production, n'est-ce pas ?

Les CI définissent généralement une variable d'environnement pour indiquer que la suite de tests s'exécute là-bas. Par exemple, cela pourrait être `CI` :

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

À partir de Rails 7, les applications nouvellement générées sont configurées de cette manière par défaut.

### Suites de tests minimales

Si votre projet n'a pas d'intégration continue, vous pouvez toujours charger de manière anticipée dans la suite de tests en appelant `Rails.application.eager_load!` :

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "eager loads all files without errors" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk compliance" do
  it "eager loads all files without errors" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

Supprimez tous les appels `require`
-----------------------------------

Dans mon expérience, les projets ne le font généralement pas. Mais j'en ai vu quelques-uns, et j'en ai entendu parler pour quelques autres.
Dans une application Rails, vous utilisez `require` exclusivement pour charger du code depuis `lib` ou depuis des dépendances tierces telles que des gems ou la bibliothèque standard. **Ne chargez jamais de code d'application pouvant être chargé automatiquement avec `require`**. Vous pouvez voir pourquoi c'était une mauvaise idée dans le mode `classic` [ici](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#autoloading-and-require).

```ruby
require "nokogiri" # BIEN
require "net/http" # BIEN
require "user"     # MAUVAIS, SUPPRIMEZ CELA (en supposant que app/models/user.rb existe)
```

Veuillez supprimer tous les appels `require` de ce type.

Nouvelles fonctionnalités que vous pouvez exploiter
--------------------------------------------------

### Supprimez les appels à `require_dependency`

Tous les cas d'utilisation connus de `require_dependency` ont été éliminés avec Zeitwerk. Vous devriez rechercher ces appels dans le projet et les supprimer.

Si votre application utilise l'héritage de table unique, veuillez consulter la section [Héritage de table unique](autoloading_and_reloading_constants.html#single-table-inheritance) du guide Autoloading and Reloading Constants (Zeitwerk Mode).

### Les noms qualifiés dans les définitions de classes et de modules sont maintenant possibles

Vous pouvez maintenant utiliser de manière robuste des chemins de constantes dans les définitions de classes et de modules :

```ruby
# Le chargement automatique dans le corps de cette classe correspond maintenant à la sémantique de Ruby.
class Admin::UsersController < ApplicationController
  # ...
end
```

Un point à noter est que, selon l'ordre d'exécution, le chargeur automatique classique pouvait parfois charger automatiquement `Foo::Wadus` dans :

```ruby
class Foo::Bar
  Wadus
end
```

Cela ne correspond pas à la sémantique de Ruby car `Foo` n'est pas dans l'imbrication, et cela ne fonctionnera pas du tout en mode `zeitwerk`. Si vous rencontrez un tel cas particulier, vous pouvez utiliser le nom qualifié `Foo::Wadus` :

```ruby
class Foo::Bar
  Foo::Wadus
end
```

ou ajouter `Foo` à l'imbrication :

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

### La sécurité des threads partout

En mode `classic`, le chargement automatique des constantes n'est pas sûr pour les threads, bien que Rails dispose de verrous pour rendre par exemple les requêtes web sûres pour les threads.

Le chargement automatique des constantes est sûr pour les threads en mode `zeitwerk`. Par exemple, vous pouvez maintenant charger automatiquement dans des scripts multi-thread exécutés par la commande `runner`.

### Le chargement anticipé et le chargement automatique sont cohérents

En mode `classic`, si `app/models/foo.rb` définit `Bar`, vous ne pourrez pas charger automatiquement ce fichier, mais le chargement anticipé fonctionnera car il charge les fichiers de manière récursive sans discernement. Cela peut être une source d'erreurs si vous testez d'abord le chargement anticipé, l'exécution peut échouer plus tard lors du chargement automatique.

En mode `zeitwerk`, les deux modes de chargement sont cohérents, ils échouent et génèrent des erreurs dans les mêmes fichiers.
