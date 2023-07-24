**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2aedcd7fcf6f0b83538e8a8220d38afd
Commencer avec les moteurs
============================

Dans ce guide, vous apprendrez à propos des moteurs et comment ils peuvent être utilisés pour fournir des fonctionnalités supplémentaires à leurs applications hôtes grâce à une interface propre et très facile à utiliser.

Après avoir lu ce guide, vous saurez :

* Ce qui fait un moteur.
* Comment générer un moteur.
* Comment construire des fonctionnalités pour le moteur.
* Comment intégrer le moteur dans une application.
* Comment remplacer la fonctionnalité du moteur dans l'application.
* Comment éviter de charger les frameworks Rails avec les hooks de chargement et de configuration.

--------------------------------------------------------------------------------

Qu'est-ce qu'un moteur ?
------------------------

Les moteurs peuvent être considérés comme des applications miniatures qui fournissent des fonctionnalités à leurs applications hôtes. Une application Rails est en réalité juste un moteur "surpuissant", avec la classe `Rails::Application` héritant une grande partie de son comportement de `Rails::Engine`.

Par conséquent, les moteurs et les applications peuvent être considérés comme presque la même chose, avec des différences subtiles, comme vous le verrez tout au long de ce guide. Les moteurs et les applications partagent également une structure commune.

Les moteurs sont également étroitement liés aux plugins. Les deux partagent une structure de répertoire `lib` commune et sont tous deux générés à l'aide du générateur `rails plugin new`. La différence est qu'un moteur est considéré comme un "plugin complet" par Rails (comme indiqué par l'option `--full` passée à la commande du générateur). Nous utiliserons en fait l'option `--mountable` ici, qui inclut toutes les fonctionnalités de `--full`, et même plus. Ce guide se référera à ces "plugins complets" simplement comme des "moteurs". Un moteur **peut** être un plugin, et un plugin **peut** être un moteur.

Le moteur qui sera créé dans ce guide s'appellera "blorgh". Ce moteur fournira des fonctionnalités de blog à ses applications hôtes, permettant la création de nouveaux articles et commentaires. Au début de ce guide, vous travaillerez uniquement dans le moteur lui-même, mais dans les sections suivantes, vous verrez comment l'intégrer dans une application.

Les moteurs peuvent également être isolés de leurs applications hôtes. Cela signifie qu'une application peut avoir un chemin fourni par un helper de routage tel que `articles_path` et utiliser un moteur qui fournit également un chemin appelé `articles_path`, et les deux ne se chevaucheraient pas. En plus de cela, les contrôleurs, les modèles et les noms de table sont également mis en namespace. Vous verrez comment faire cela plus tard dans ce guide.

Il est important de garder à l'esprit en tout temps que l'application devrait **toujours** avoir la priorité sur ses moteurs. Une application est l'objet qui a le dernier mot sur ce qui se passe dans son environnement. Le moteur ne devrait que l'améliorer, plutôt que de le changer radicalement.

Pour voir des démonstrations d'autres moteurs, consultez [Devise](https://github.com/plataformatec/devise), un moteur qui fournit une authentification pour ses applications parent, ou [Thredded](https://github.com/thredded/thredded), un moteur qui fournit des fonctionnalités de forum. Il y a aussi [Spree](https://github.com/spree/spree) qui fournit une plateforme de commerce électronique, et [Refinery CMS](https://github.com/refinery/refinerycms), un moteur de CMS.

Enfin, les moteurs n'auraient pas été possibles sans le travail de James Adam, Piotr Sarnacki, l'équipe principale de Rails et un certain nombre d'autres personnes. Si vous les rencontrez un jour, n'oubliez pas de les remercier !

Générer un moteur
-----------------

Pour générer un moteur, vous devrez exécuter le générateur de plugin et lui passer les options appropriées selon les besoins. Pour l'exemple "blorgh", vous devrez créer un moteur "mountable", en exécutant cette commande dans un terminal :

```bash
$ rails plugin new blorgh --mountable
```

La liste complète des options pour le générateur de plugin peut être consultée en tapant :

```bash
$ rails plugin --help
```

L'option `--mountable` indique au générateur que vous souhaitez créer un moteur "mountable" et isolé par namespace. Ce générateur fournira la même structure squelette que l'option `--full`. L'option `--full` indique au générateur que vous souhaitez créer un moteur, y compris une structure squelette qui fournit ce qui suit :

  * Une arborescence de répertoires `app`
  * Un fichier `config/routes.rb` :

    ```ruby
    Rails.application.routes.draw do
    end
    ```

  * Un fichier à `lib/blorgh/engine.rb`, qui est identique en fonction à un fichier `config/application.rb` standard d'une application Rails :

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
      end
    end
    ```

L'option `--mountable` ajoutera à l'option `--full` :

  * Des fichiers de manifeste des assets (`blorgh_manifest.js` et `application.css`)
  * Un modèle de stub `ApplicationController` mis en namespace
  * Un modèle de stub `ApplicationHelper` mis en namespace
  * Un modèle de vue de mise en page pour le moteur
  * L'isolation par namespace dans `config/routes.rb` :
```ruby
Blorgh::Engine.routes.draw do
end
```

* Isolation de l'espace de noms dans `lib/blorgh/engine.rb` :

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

De plus, l'option `--mountable` indique au générateur de monter le moteur à l'intérieur de l'application de test fictive située dans `test/dummy` en ajoutant le code suivant au fichier de routes de l'application fictive situé dans `test/dummy/config/routes.rb` :

```ruby
mount Blorgh::Engine => "/blorgh"
```

### À l'intérieur d'un moteur

#### Fichiers critiques

À la racine du répertoire de ce tout nouveau moteur se trouve un fichier `blorgh.gemspec`. Lorsque vous incluez le moteur dans une application ultérieurement, vous le ferez avec cette ligne dans le fichier `Gemfile` de l'application Rails :

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

N'oubliez pas d'exécuter `bundle install` comme d'habitude. En le spécifiant comme une gemme dans le `Gemfile`, Bundler le chargera en tant que tel, en analysant ce fichier `blorgh.gemspec` et en exigeant un fichier dans le répertoire `lib` appelé `lib/blorgh.rb`. Ce fichier exige le fichier `blorgh/engine.rb` (situé dans `lib/blorgh/engine.rb`) et définit un module de base appelé `Blorgh`.

```ruby
require "blorgh/engine"

module Blorgh
end
```

CONSEIL : Certains moteurs choisissent d'utiliser ce fichier pour mettre des options de configuration globales pour leur moteur. C'est une assez bonne idée, donc si vous voulez offrir des options de configuration, le fichier où le `module` de votre moteur est défini est parfait pour cela. Placez les méthodes à l'intérieur du module et vous serez prêt à partir.

À l'intérieur de `lib/blorgh/engine.rb` se trouve la classe de base du moteur :

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

En héritant de la classe `Rails::Engine`, cette gemme notifie à Rails qu'il y a un moteur au chemin spécifié et montera correctement le moteur à l'intérieur de l'application, effectuant des tâches telles que l'ajout du répertoire `app` du moteur au chemin de chargement des modèles, des mailers, des contrôleurs et des vues.

La méthode `isolate_namespace` mérite une attention particulière. Cet appel est responsable de l'isolation des contrôleurs, des modèles, des routes et d'autres éléments dans leur propre espace de noms, à l'écart des composants similaires à l'intérieur de l'application. Sans cela, il est possible que les composants du moteur puissent "fuiter" dans l'application, provoquant des perturbations indésirables, ou que des composants importants du moteur puissent être remplacés par des éléments de même nom à l'intérieur de l'application. L'un des exemples de ces conflits est les helpers. Sans appeler `isolate_namespace`, les helpers du moteur seraient inclus dans les contrôleurs d'une application.

REMARQUE : Il est **vivement** recommandé de laisser la ligne `isolate_namespace` à l'intérieur de la définition de la classe `Engine`. Sans cela, les classes générées dans un moteur **peuvent** entrer en conflit avec une application.

Ce que signifie cette isolation de l'espace de noms, c'est qu'un modèle généré par un appel à `bin/rails generate model`, tel que `bin/rails generate model article`, ne sera pas appelé `Article`, mais sera plutôt mis dans un espace de noms et appelé `Blorgh::Article`. De plus, la table pour le modèle est mise dans un espace de noms, devenant `blorgh_articles`, plutôt que simplement `articles`. De même pour l'espace de noms des contrôleurs, un contrôleur appelé `ArticlesController` devient `Blorgh::ArticlesController` et les vues pour ce contrôleur ne se trouvent pas dans `app/views/articles`, mais plutôt dans `app/views/blorgh/articles`. Les mailers, les jobs et les helpers sont également mis dans un espace de noms.

Enfin, les routes seront également isolées à l'intérieur du moteur. C'est l'une des parties les plus importantes de l'isolation des espaces de noms, et elle est discutée plus en détail dans la section [Routes](#routes) de ce guide.

#### Répertoire `app`

À l'intérieur du répertoire `app`, on trouve les répertoires standard `assets`, `controllers`, `helpers`, `jobs`, `mailers`, `models` et `views` que vous devriez connaître d'une application. Nous examinerons plus en détail les modèles dans une section ultérieure, lorsque nous écrirons le moteur.

Dans le répertoire `app/assets`, on trouve les répertoires `images` et `stylesheets` qui, là encore, devraient vous être familiers en raison de leur similitude avec une application. Une différence ici, cependant, est que chaque répertoire contient un sous-répertoire avec le nom du moteur. Étant donné que ce moteur va être mis en espace de noms, ses assets devraient l'être aussi.

Dans le répertoire `app/controllers`, il y a un répertoire `blorgh` qui contient un fichier appelé `application_controller.rb`. Ce fichier fournira toute fonctionnalité commune pour les contrôleurs du moteur. Le répertoire `blorgh` est l'endroit où les autres contrôleurs du moteur iront. En les plaçant dans ce répertoire mis en espace de noms, vous évitez qu'ils entrent en conflit avec des contrôleurs portant le même nom dans d'autres moteurs ou même dans l'application.

REMARQUE : La classe `ApplicationController` à l'intérieur d'un moteur est nommée exactement comme une application Rails afin de faciliter la conversion de vos applications en moteurs.
NOTE : Si l'application parente s'exécute en mode "classic", vous pouvez rencontrer une situation où votre contrôleur de moteur hérite du contrôleur de l'application principale et non du contrôleur de l'application de votre moteur. La meilleure façon d'éviter cela est de passer en mode "zeitwerk" dans l'application parente. Sinon, utilisez "require_dependency" pour vous assurer que le contrôleur de l'application du moteur est chargé. Par exemple :

```ruby
# NÉCESSAIRE UNIQUEMENT EN MODE "classic".
require_dependency "blorgh/application_controller"

module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

AVERTISSEMENT : N'utilisez pas "require" car cela rompra le rechargement automatique des classes dans l'environnement de développement - en utilisant "require_dependency", vous vous assurez que les classes sont chargées et déchargées correctement.

Tout comme pour "app/controllers", vous trouverez un sous-répertoire "blorgh" dans les répertoires "app/helpers", "app/jobs", "app/mailers" et "app/models" contenant le fichier "application_*.rb" associé pour regrouper les fonctionnalités communes. En plaçant vos fichiers dans ce sous-répertoire et en utilisant des espaces de noms pour vos objets, vous évitez qu'ils entrent en conflit avec des éléments portant le même nom dans d'autres moteurs ou même dans l'application.

Enfin, le répertoire "app/views" contient un dossier "layouts", qui contient un fichier "blorgh/application.html.erb". Ce fichier vous permet de spécifier une mise en page pour le moteur. Si ce moteur doit être utilisé comme un moteur autonome, vous ajouterez toute personnalisation à sa mise en page dans ce fichier, plutôt que dans le fichier "app/views/layouts/application.html.erb" de l'application.

Si vous ne souhaitez pas imposer une mise en page aux utilisateurs du moteur, vous pouvez supprimer ce fichier et référencer une mise en page différente dans les contrôleurs de votre moteur.

#### Répertoire "bin"

Ce répertoire contient un fichier, "bin/rails", qui vous permet d'utiliser les sous-commandes et les générateurs de Rails comme vous le feriez dans une application. Cela signifie que vous pourrez générer très facilement de nouveaux contrôleurs et modèles pour ce moteur en exécutant des commandes comme celle-ci :

```bash
$ bin/rails generate model
```

Gardez à l'esprit, bien sûr, que tout ce qui est généré avec ces commandes à l'intérieur d'un moteur qui a "isolate_namespace" dans la classe "Engine" sera mis en espace de noms.

#### Répertoire "test"

Le répertoire "test" est l'endroit où se trouvent les tests pour le moteur. Pour tester le moteur, il y a une version simplifiée d'une application Rails intégrée à l'intérieur, dans "test/dummy". Cette application montera le moteur dans le fichier "test/dummy/config/routes.rb" :

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

Cette ligne monte le moteur sur le chemin "/blorgh", ce qui le rend accessible uniquement à cet endroit dans l'application.

À l'intérieur du répertoire de test, il y a le répertoire "test/integration", où les tests d'intégration pour le moteur doivent être placés. D'autres répertoires peuvent également être créés dans le répertoire "test". Par exemple, vous pouvez créer un répertoire "test/models" pour vos tests de modèle.

Fournir des fonctionnalités de moteur
-------------------------------------

Le moteur couvert par ce guide fournit des fonctionnalités de soumission d'articles et de commentaires, et suit un fil similaire au [Guide de démarrage](getting_started.html), avec quelques nouveautés.

NOTE : Pour cette section, assurez-vous d'exécuter les commandes à la racine du répertoire du moteur "blorgh".

### Générer une ressource d'article

La première chose à générer pour un moteur de blog est le modèle "Article" et le contrôleur associé. Pour générer rapidement cela, vous pouvez utiliser le générateur de squelette Rails.

```bash
$ bin/rails generate scaffold article title:string text:text
```

Cette commande affichera ces informations :

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_articles.rb
create    app/models/blorgh/article.rb
invoke    test_unit
create      test/models/blorgh/article_test.rb
create      test/fixtures/blorgh/articles.yml
invoke  resource_route
 route    resources :articles
invoke  scaffold_controller
create    app/controllers/blorgh/articles_controller.rb
invoke    erb
create      app/views/blorgh/articles
create      app/views/blorgh/articles/index.html.erb
create      app/views/blorgh/articles/edit.html.erb
create      app/views/blorgh/articles/show.html.erb
create      app/views/blorgh/articles/new.html.erb
create      app/views/blorgh/articles/_form.html.erb
invoke    test_unit
create      test/controllers/blorgh/articles_controller_test.rb
create      test/system/blorgh/articles_test.rb
invoke    helper
create      app/helpers/blorgh/articles_helper.rb
invoke      test_unit
```

La première chose que fait le générateur de squelette est d'appeler le générateur "active_record", qui génère une migration et un modèle pour la ressource. Notez ici, cependant, que la migration s'appelle "create_blorgh_articles" au lieu de "create_articles" habituel. Cela est dû à l'appel de la méthode "isolate_namespace" dans la définition de la classe "Blorgh::Engine". Le modèle ici est également mis en espace de noms, étant placé dans "app/models/blorgh/article.rb" au lieu de "app/models/article.rb" en raison de l'appel à "isolate_namespace" dans la classe "Engine".

Ensuite, le générateur "test_unit" est appelé pour ce modèle, générant un test de modèle à "test/models/blorgh/article_test.rb" (au lieu de "test/models/article_test.rb") et une fixture à "test/fixtures/blorgh/articles.yml" (au lieu de "test/fixtures/articles.yml").

Ensuite, une ligne pour la ressource est insérée dans le fichier "config/routes.rb" du moteur. Cette ligne est simplement "resources :articles", transformant le fichier "config/routes.rb" du moteur en ceci :
```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

Notez ici que les routes sont dessinées sur l'objet `Blorgh::Engine` plutôt que sur la classe `YourApp::Application`. Cela permet de confiner les routes du moteur au moteur lui-même et de les monter à un point spécifique comme indiqué dans la section [répertoire de test](#test-directory). Cela permet également d'isoler les routes du moteur de celles qui se trouvent dans l'application. La section [Routes](#routes) de ce guide en décrit les détails.

Ensuite, le générateur `scaffold_controller` est invoqué, générant un contrôleur appelé `Blorgh::ArticlesController` (à `app/controllers/blorgh/articles_controller.rb`) et ses vues associées à `app/views/blorgh/articles`. Ce générateur génère également des tests pour le contrôleur (`test/controllers/blorgh/articles_controller_test.rb` et `test/system/blorgh/articles_test.rb`) et un helper (`app/helpers/blorgh/articles_helper.rb`).

Tout ce que ce générateur a créé est soigneusement mis en namespace. La classe du contrôleur est définie dans le module `Blorgh` :

```ruby
module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

NOTE : La classe `ArticlesController` hérite de `Blorgh::ApplicationController`, et non de `ApplicationController` de l'application.

Le helper dans `app/helpers/blorgh/articles_helper.rb` est également mis en namespace :

```ruby
module Blorgh
  module ArticlesHelper
    # ...
  end
end
```

Cela permet d'éviter les conflits avec tout autre moteur ou application qui pourrait également avoir une ressource d'article.

Vous pouvez voir ce que le moteur a jusqu'à présent en exécutant `bin/rails db:migrate` à la racine de notre moteur pour exécuter la migration générée par le générateur de scaffold, puis en exécutant `bin/rails server` dans `test/dummy`. Lorsque vous ouvrez `http://localhost:3000/blorgh/articles`, vous verrez le scaffold par défaut qui a été généré. Cliquez autour ! Vous venez de générer les premières fonctions de votre premier moteur.

Si vous préférez jouer dans la console, `bin/rails console` fonctionnera également comme une application Rails. N'oubliez pas : le modèle `Article` est mis en namespace, donc pour le référencer, vous devez l'appeler `Blorgh::Article`.

```irb
irb> Blorgh::Article.find(1)
=> #<Blorgh::Article id: 1 ...>
```

Une dernière chose est que la ressource `articles` de ce moteur devrait être la racine du moteur. Chaque fois que quelqu'un accède au chemin racine où le moteur est monté, il devrait voir une liste d'articles. Cela peut être réalisé en insérant cette ligne dans le fichier `config/routes.rb` à l'intérieur du moteur :

```ruby
root to: "articles#index"
```

Maintenant, les gens n'auront besoin d'aller qu'à la racine du moteur pour voir tous les articles, plutôt que de visiter `/articles`. Cela signifie qu'au lieu de `http://localhost:3000/blorgh/articles`, vous n'avez maintenant qu'à aller à `http://localhost:3000/blorgh`.

### Génération d'une ressource de commentaires

Maintenant que le moteur peut créer de nouveaux articles, il est logique d'ajouter également une fonctionnalité de commentaires. Pour cela, vous devrez générer un modèle de commentaire, un contrôleur de commentaire, puis modifier le scaffold des articles pour afficher les commentaires et permettre aux utilisateurs d'en créer de nouveaux.

Depuis la racine du moteur, exécutez le générateur de modèle. Indiquez-lui de générer un modèle `Comment`, avec la table associée ayant deux colonnes : un entier `article_id` et une colonne de texte `text`.

```bash
$ bin/rails generate model Comment article_id:integer text:text
```

Cela produira la sortie suivante :

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_comments.rb
create    app/models/blorgh/comment.rb
invoke    test_unit
create      test/models/blorgh/comment_test.rb
create      test/fixtures/blorgh/comments.yml
```

Cet appel au générateur générera uniquement les fichiers de modèle nécessaires, en les mettant en namespace sous un répertoire `blorgh` et en créant une classe de modèle appelée `Blorgh::Comment`. Exécutez maintenant la migration pour créer notre table `blorgh_comments` :

```bash
$ bin/rails db:migrate
```

Pour afficher les commentaires sur un article, modifiez `app/views/blorgh/articles/show.html.erb` et ajoutez cette ligne avant le lien "Edit" :

```html+erb
<h3>Comments</h3>
<%= render @article.comments %>
```

Cette ligne nécessitera qu'une association `has_many` pour les commentaires soit définie sur le modèle `Blorgh::Article`, ce qui n'est pas le cas pour le moment. Pour en définir une, ouvrez `app/models/blorgh/article.rb` et ajoutez cette ligne dans le modèle :

```ruby
has_many :comments
```

Le modèle devient alors :

```ruby
module Blorgh
  class Article < ApplicationRecord
    has_many :comments
  end
end
```

NOTE : Comme `has_many` est défini à l'intérieur d'une classe qui se trouve dans le module `Blorgh`, Rails saura que vous voulez utiliser le modèle `Blorgh::Comment` pour ces objets, il n'est donc pas nécessaire de le spécifier en utilisant l'option `:class_name` ici.

Ensuite, il faut un formulaire pour que les commentaires puissent être créés sur un article. Pour ajouter cela, placez cette ligne sous l'appel à `render @article.comments` dans `app/views/blorgh/articles/show.html.erb` :

```erb
<%= render "blorgh/comments/form" %>
```

Ensuite, le partial que cette ligne va rendre doit exister. Créez un nouveau répertoire à `app/views/blorgh/comments` et créez-y un nouveau fichier appelé `_form.html.erb` qui contient ce contenu pour créer le partial requis :
```html+erb
<h3>Nouveau commentaire</h3>
<%= form_with model: [@article, @article.comments.build] do |form| %>
  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>
  <%= form.submit %>
<% end %>
```

Lorsque ce formulaire est soumis, il va tenter d'effectuer une requête `POST` vers une route `/articles/:article_id/comments` à l'intérieur du moteur. Cette route n'existe pas pour le moment, mais peut être créée en modifiant la ligne `resources :articles` dans `config/routes.rb` par ces lignes :

```ruby
resources :articles do
  resources :comments
end
```

Cela crée une route imbriquée pour les commentaires, ce dont le formulaire a besoin.

La route existe maintenant, mais le contrôleur vers lequel cette route va n'existe pas. Pour le créer, exécutez cette commande à partir de la racine du moteur :

```bash
$ bin/rails generate controller comments
```

Cela générera les éléments suivants :

```
create  app/controllers/blorgh/comments_controller.rb
invoke  erb
 exist    app/views/blorgh/comments
invoke  test_unit
create    test/controllers/blorgh/comments_controller_test.rb
invoke  helper
create    app/helpers/blorgh/comments_helper.rb
invoke    test_unit
```

Le formulaire va effectuer une requête `POST` vers `/articles/:article_id/comments`, qui correspondra à l'action `create` dans `Blorgh::CommentsController`. Cette action doit être créée, ce qui peut être fait en ajoutant les lignes suivantes à la définition de classe dans `app/controllers/blorgh/comments_controller.rb` :

```ruby
def create
  @article = Article.find(params[:article_id])
  @comment = @article.comments.create(comment_params)
  flash[:notice] = "Le commentaire a été créé !"
  redirect_to articles_path
end

private
  def comment_params
    params.require(:comment).permit(:text)
  end
```

C'est la dernière étape nécessaire pour faire fonctionner le formulaire de nouveau commentaire. Cependant, l'affichage des commentaires n'est pas encore tout à fait correct. Si vous créez un commentaire maintenant, vous verrez cette erreur :

```
Missing partial blorgh/comments/_comment with {:handlers=>[:erb, :builder],
:formats=>[:html], :locale=>[:en, :en]}. Searched in:   *
"/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"   *
"/Users/ryan/Sites/side_projects/blorgh/app/views"
```

Le moteur ne parvient pas à trouver la partial requise pour afficher les commentaires. Rails recherche d'abord dans le répertoire `app/views` de l'application (`test/dummy`) puis dans le répertoire `app/views` du moteur. Lorsqu'il ne la trouve pas, il génère cette erreur. Le moteur sait qu'il doit chercher `blorgh/comments/_comment` car l'objet modèle qu'il reçoit provient de la classe `Blorgh::Comment`.

Cette partial sera responsable de l'affichage uniquement du texte du commentaire, pour l'instant. Créez un nouveau fichier à `app/views/blorgh/comments/_comment.html.erb` et ajoutez cette ligne à l'intérieur :

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

La variable locale `comment_counter` nous est donnée par l'appel `<%= render @article.comments %>`, qui la définit automatiquement et incrémente le compteur à mesure qu'il itère à travers chaque commentaire. Elle est utilisée dans cet exemple pour afficher un petit numéro à côté de chaque commentaire lorsqu'il est créé.

Cela complète la fonction de commentaire du moteur de blog. Maintenant, il est temps de l'utiliser dans une application.

Intégration dans une application
-------------------------------

Utiliser un moteur dans une application est très facile. Cette section explique comment monter le moteur dans une application et la configuration initiale requise, ainsi que la liaison du moteur à une classe `User` fournie par l'application pour fournir la propriété des articles et des commentaires dans le moteur.

### Monter le moteur

Tout d'abord, le moteur doit être spécifié dans le `Gemfile` de l'application. S'il n'y a pas d'application disponible pour tester cela, en générer une en utilisant la commande `rails new` en dehors du répertoire du moteur comme ceci :

```bash
$ rails new unicorn
```

Généralement, spécifier le moteur dans le `Gemfile` se ferait en le spécifiant comme une gemme normale et quotidienne.

```ruby
gem 'devise'
```

Cependant, parce que vous développez le moteur `blorgh` sur votre machine locale, vous devrez spécifier l'option `:path` dans votre `Gemfile` :

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

Ensuite, exécutez `bundle` pour installer la gemme.

Comme décrit précédemment, en plaçant la gemme dans le `Gemfile`, elle sera chargée lorsque Rails sera chargé. Elle requerra d'abord `lib/blorgh.rb` du moteur, puis `lib/blorgh/engine.rb`, qui est le fichier qui définit les principales fonctionnalités du moteur.

Pour rendre la fonctionnalité du moteur accessible depuis une application, il doit être monté dans le fichier `config/routes.rb` de cette application :

```ruby
mount Blorgh::Engine, at: "/blog"
```

Cette ligne montera le moteur à `/blog` dans l'application. Il sera accessible à `http://localhost:3000/blog` lorsque l'application sera exécutée avec `bin/rails server`.

NOTE : D'autres moteurs, comme Devise, gèrent cela un peu différemment en vous obligeant à spécifier des helpers personnalisés (comme `devise_for`) dans les routes. Ces helpers font exactement la même chose, ils montent des parties de la fonctionnalité du moteur à un chemin prédéfini qui peut être personnalisé.
### Configuration du moteur

Le moteur contient des migrations pour les tables `blorgh_articles` et `blorgh_comments` qui doivent être créées dans la base de données de l'application afin que les modèles du moteur puissent les interroger correctement. Pour copier ces migrations dans l'application, exécutez la commande suivante à partir de la racine de l'application :

```bash
$ bin/rails blorgh:install:migrations
```

Si vous avez plusieurs moteurs qui ont besoin de migrations copiées, utilisez `railties:install:migrations` à la place :

```bash
$ bin/rails railties:install:migrations
```

Vous pouvez spécifier un chemin personnalisé dans le moteur source pour les migrations en spécifiant MIGRATIONS_PATH.

```bash
$ bin/rails railties:install:migrations MIGRATIONS_PATH=db_blourgh
```

Si vous avez plusieurs bases de données, vous pouvez également spécifier la base de données cible en spécifiant DATABASE.

```bash
$ bin/rails railties:install:migrations DATABASE=animals
```

Cette commande, lorsqu'elle est exécutée pour la première fois, copiera toutes les migrations du moteur. Lorsqu'elle est exécutée la fois suivante, elle ne copiera que les migrations qui n'ont pas encore été copiées. La première exécution de cette commande affichera quelque chose comme ceci :

```
Copied migration [timestamp_1]_create_blorgh_articles.blorgh.rb from blorgh
Copied migration [timestamp_2]_create_blorgh_comments.blorgh.rb from blorgh
```

Le premier timestamp (`[timestamp_1]`) sera l'heure actuelle, et le deuxième timestamp (`[timestamp_2]`) sera l'heure actuelle plus une seconde. La raison de cela est que les migrations du moteur sont exécutées après toutes les migrations existantes dans l'application.

Pour exécuter ces migrations dans le contexte de l'application, exécutez simplement `bin/rails db:migrate`. Lorsque vous accédez au moteur via `http://localhost:3000/blog`, les articles seront vides. Cela est dû au fait que la table créée dans l'application est différente de celle créée dans le moteur. Allez-y, jouez avec le moteur nouvellement monté. Vous constaterez que c'est le même que lorsqu'il était seulement un moteur.

Si vous souhaitez exécuter les migrations uniquement à partir d'un seul moteur, vous pouvez le faire en spécifiant `SCOPE` :

```bash
$ bin/rails db:migrate SCOPE=blorgh
```

Cela peut être utile si vous souhaitez revenir en arrière sur les migrations du moteur avant de le supprimer. Pour revenir en arrière sur toutes les migrations du moteur blorgh, vous pouvez exécuter du code tel que :

```bash
$ bin/rails db:migrate SCOPE=blorgh VERSION=0
```

### Utilisation d'une classe fournie par l'application

#### Utilisation d'un modèle fourni par l'application

Lorsqu'un moteur est créé, il peut vouloir utiliser des classes spécifiques d'une application pour établir des liens entre les éléments du moteur et les éléments de l'application. Dans le cas du moteur `blorgh`, il serait logique que les articles et les commentaires aient des auteurs.

Une application typique pourrait avoir une classe `User` qui serait utilisée pour représenter les auteurs d'un article ou d'un commentaire. Mais il pourrait y avoir un cas où l'application appelle cette classe différemment, par exemple `Person`. Pour cette raison, le moteur ne doit pas coder en dur des associations spécifiques pour une classe `User`.

Pour simplifier les choses dans ce cas, l'application aura une classe appelée `User` qui représente les utilisateurs de l'application (nous verrons comment rendre cela configurable plus loin). Elle peut être générée en utilisant cette commande à l'intérieur de l'application :

```bash
$ bin/rails generate model user name:string
```

La commande `bin/rails db:migrate` doit être exécutée ici pour s'assurer que notre application dispose de la table `users` pour une utilisation future.

De plus, pour simplifier les choses, le formulaire des articles aura un nouveau champ de texte appelé `author_name`, où les utilisateurs peuvent choisir d'indiquer leur nom. Le moteur prendra ensuite ce nom et créera soit un nouvel objet `User` à partir de celui-ci, soit en trouvera un qui a déjà ce nom. Le moteur associera ensuite l'article à l'objet `User` trouvé ou créé.

Tout d'abord, le champ de texte `author_name` doit être ajouté à la partial `app/views/blorgh/articles/_form.html.erb` à l'intérieur du moteur. Cela peut être ajouté au-dessus du champ `title` avec ce code :

```html+erb
<div class="field">
  <%= form.label :author_name %><br>
  <%= form.text_field :author_name %>
</div>
```

Ensuite, nous devons mettre à jour notre méthode `Blorgh::ArticlesController#article_params` pour autoriser le nouveau paramètre du formulaire :

```ruby
def article_params
  params.require(:article).permit(:title, :text, :author_name)
end
```

Le modèle `Blorgh::Article` devrait ensuite contenir du code pour convertir le champ `author_name` en un véritable objet `User` et l'associer en tant qu'auteur de cet article avant que l'article ne soit enregistré. Il devra également avoir un `attr_accessor` configuré pour ce champ, afin que les méthodes setter et getter soient définies pour celui-ci.

Pour faire tout cela, vous devrez ajouter l'`attr_accessor` pour `author_name`, l'association pour l'auteur et l'appel `before_validation` dans `app/models/blorgh/article.rb`. L'association `author` sera codée en dur pour la classe `User` pour le moment.
```ruby
mattr_accessor :author_class

def self.author_class
  @@author_class.constantize
end
```

This way, whenever `Blorgh.author_class` is called, it will automatically call `constantize` on the saved value.

#### Configuring the Engine in the Application

To configure the engine in the application, create an initializer file in the application's `config/initializers` directory. For example, create a file called `blorgh.rb` and add the following code:

```ruby
Blorgh.author_class = "User"
```

This sets the `author_class` configuration setting to `"User"`. Replace `"User"` with the appropriate class name if needed.

#### Overriding Engine Views

To override the engine's views with custom views in the application, create a directory called `blorgh` inside the application's `app/views` directory. Then, create the same directory structure as the engine's views inside the `blorgh` directory. For example, to override the `show.html.erb` view, create the file `app/views/blorgh/articles/show.html.erb` and add the desired custom code.

#### Overriding Engine Controllers

To override the engine's controllers with custom controllers in the application, create a directory called `blorgh` inside the application's `app/controllers` directory. Then, create the same directory structure as the engine's controllers inside the `blorgh` directory. For example, to override the `ArticlesController`, create the file `app/controllers/blorgh/articles_controller.rb` and define the custom controller code.

#### Overriding Engine Models

To override the engine's models with custom models in the application, create a directory called `blorgh` inside the application's `app/models` directory. Then, create the same directory structure as the engine's models inside the `blorgh` directory. For example, to override the `Article` model, create the file `app/models/blorgh/article.rb` and define the custom model code.

#### Overriding Engine Routes

To override the engine's routes with custom routes in the application, create a file called `blorgh.rb` inside the application's `config/routes` directory. In this file, define the custom routes using the `draw` method. For example:

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine, at: "/blog"
  get "/articles", to: "custom_articles#index"
end
```

This mounts the engine at the `/blog` path and adds a custom route for the `/articles` path.

#### Overriding Engine Migrations

To override the engine's migrations with custom migrations in the application, create a directory called `blorgh` inside the application's `db/migrate` directory. Then, copy the desired engine migration files into the `blorgh` directory. You can modify the copied migration files as needed.

#### Running Engine Migrations

To run the engine's migrations in the application, use the following command:

```bash
$ bin/rails db:migrate
```

This will run all pending migrations, including the engine's migrations.

#### Running Engine Tests

To run the engine's tests in the application, use the following command:

```bash
$ bin/rails test
```

This will run all tests, including the engine's tests.

#### Running Engine Generators

To run the engine's generators in the application, use the following command:

```bash
$ bin/rails generate blorgh:generator_name
```

Replace `generator_name` with the name of the desired generator.

#### Running Engine Tasks

To run the engine's tasks in the application, use the following command:

```bash
$ bin/rails blorgh:task_name
```

Replace `task_name` with the name of the desired task.

#### Running Engine Rake Tasks

To run the engine's Rake tasks in the application, use the following command:

```bash
$ bin/rake blorgh:task_name
```

Replace `task_name` with the name of the desired task.

#### Running Engine Console

To access the engine's console in the application, use the following command:

```bash
$ bin/rails console
```

This will open the Rails console with access to the engine's models and functionality.
```ruby
def self.author_class
  @@author_class.constantize
end
```

Cela transforme ensuite le code ci-dessus pour `set_author` en ceci :

```ruby
self.author = Blorgh.author_class.find_or_create_by(name: author_name)
```

Résultant en quelque chose de plus court et plus implicite dans son comportement. La méthode `author_class` doit toujours renvoyer un objet `Class`.

Puisque nous avons modifié la méthode `author_class` pour renvoyer une `Class` au lieu d'une `String`, nous devons également modifier notre définition `belongs_to` dans le modèle `Blorgh::Article` :

```ruby
belongs_to :author, class_name: Blorgh.author_class.to_s
```

Pour définir ce paramètre de configuration dans l'application, un initialiseur doit être utilisé. En utilisant un initialiseur, la configuration sera mise en place avant le démarrage de l'application et appelle les modèles du moteur, qui peuvent dépendre de l'existence de ce paramètre de configuration.

Créez un nouvel initialiseur dans `config/initializers/blorgh.rb` à l'intérieur de l'application où le moteur `blorgh` est installé et mettez-y ce contenu :

```ruby
Blorgh.author_class = "User"
```

ATTENTION : Il est très important ici d'utiliser la version `String` de la classe, plutôt que la classe elle-même. Si vous utilisiez la classe, Rails tenterait de charger cette classe puis de référencer la table associée. Cela pourrait poser des problèmes si la table n'existait pas déjà. Par conséquent, une `String` doit être utilisée, puis convertie en classe en utilisant `constantize` dans le moteur plus tard.

Allez-y et essayez de créer un nouvel article. Vous verrez que cela fonctionne exactement de la même manière qu'auparavant, sauf que cette fois-ci, le moteur utilise le paramètre de configuration dans `config/initializers/blorgh.rb` pour savoir quelle est la classe.

Il n'y a maintenant aucune dépendance stricte sur la classe, seulement sur l'API de la classe. Le moteur demande simplement à cette classe de définir une méthode `find_or_create_by` qui renvoie un objet de cette classe, à associer à un article lors de sa création. Cet objet, bien sûr, doit avoir une sorte d'identifiant par lequel il peut être référencé.

#### Configuration générale du moteur

Dans un moteur, il peut arriver un moment où vous souhaitez utiliser des choses telles que des initialiseurs, l'internationalisation ou d'autres options de configuration. La bonne nouvelle, c'est que ces choses sont tout à fait possibles, car un moteur Rails partage en grande partie la même fonctionnalité qu'une application Rails. En fait, la fonctionnalité d'une application Rails est en réalité un sur-ensemble de ce que fournissent les moteurs !

Si vous souhaitez utiliser un initialiseur - du code qui doit s'exécuter avant le chargement du moteur - l'endroit pour le faire est le dossier `config/initializers`. La fonctionnalité de ce répertoire est expliquée dans la section [Initializers](configuring.html#initializers) du guide de configuration, et fonctionne exactement de la même manière que le répertoire `config/initializers` à l'intérieur d'une application. Il en va de même si vous souhaitez utiliser un initialiseur standard.

Pour les localisations, placez simplement les fichiers de localisation dans le répertoire `config/locales`, comme vous le feriez dans une application.

Tester un moteur
-----------------

Lorsqu'un moteur est généré, une plus petite application fictive est créée à l'intérieur de celui-ci à `test/dummy`. Cette application est utilisée comme point de montage pour le moteur, afin de rendre les tests du moteur extrêmement simples. Vous pouvez étendre cette application en générant des contrôleurs, des modèles ou des vues depuis le répertoire, puis les utiliser pour tester votre moteur.

Le répertoire `test` doit être traité comme un environnement de test Rails classique, permettant les tests unitaires, fonctionnels et d'intégration.

### Tests fonctionnels

Un point à prendre en considération lors de l'écriture de tests fonctionnels est que les tests vont s'exécuter sur une application - l'application `test/dummy` - plutôt que sur votre moteur. Cela est dû à la configuration de l'environnement de test ; un moteur a besoin d'une application comme hôte pour tester sa fonctionnalité principale, en particulier les contrôleurs. Cela signifie que si vous deviez faire un `GET` typique vers un contrôleur dans un test fonctionnel du contrôleur comme ceci :

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def test_index
      get foos_url
      # ...
    end
  end
end
```

Cela peut ne pas fonctionner correctement. C'est parce que l'application ne sait pas comment router ces requêtes vers le moteur à moins que vous ne lui disiez **comment**. Pour ce faire, vous devez définir la variable d'instance `@routes` sur l'ensemble de routes du moteur dans votre code de configuration :

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_index
      get foos_url
      # ...
    end
  end
end
```
Cela indique à l'application que vous souhaitez toujours effectuer une requête `GET` vers l'action `index` de ce contrôleur, mais vous souhaitez utiliser la route du moteur pour y accéder, plutôt que celle de l'application.

Cela garantit également que les assistants d'URL du moteur fonctionneront comme prévu dans vos tests.

Amélioration de la fonctionnalité du moteur
------------------------------------------

Cette section explique comment ajouter et/ou remplacer la fonctionnalité MVC du moteur dans l'application principale de Rails.

### Remplacement des modèles et des contrôleurs

Les modèles et les contrôleurs du moteur peuvent être réouverts par l'application parente pour les étendre ou les décorer.

Les remplacements peuvent être organisés dans un répertoire dédié `app/overrides`, ignoré par l'autoloader, et préchargés dans un rappel `to_prepare` :

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        load override
      end
    end
  end
end
```

#### Réouverture des classes existantes à l'aide de `class_eval`

Par exemple, pour remplacer le modèle du moteur

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    # ...
  end
end
```

vous créez simplement un fichier qui _réouvre_ cette classe :

```ruby
# MyApp/app/overrides/models/blorgh/article_override.rb
Blorgh::Article.class_eval do
  # ...
end
```

Il est très important que le remplacement _réouvre_ la classe ou le module. Utiliser les mots-clés `class` ou `module` les définirait s'ils n'étaient pas déjà en mémoire, ce qui serait incorrect car la définition se trouve dans le moteur. En utilisant `class_eval` comme indiqué ci-dessus, vous vous assurez de les réouvrir.

#### Réouverture des classes existantes à l'aide de ActiveSupport::Concern

Utiliser `Class#class_eval` est idéal pour les ajustements simples, mais pour des modifications de classe plus complexes, vous voudrez peut-être envisager d'utiliser [`ActiveSupport::Concern`](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html). ActiveSupport::Concern gère l'ordre de chargement des modules et des classes dépendantes interconnectées au moment de l'exécution, ce qui vous permet de moduler considérablement votre code.

**Ajout** de `Article#time_since_created` et **remplacement** de `Article#summary` :

```ruby
# MyApp/app/models/blorgh/article.rb

class Blorgh::Article < ApplicationRecord
  include Blorgh::Concerns::Models::Article

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    include Blorgh::Concerns::Models::Article
  end
end
```

```ruby
# Blorgh/lib/concerns/models/article.rb

module Blorgh::Concerns::Models::Article
  extend ActiveSupport::Concern

  # `included do` permet d'évaluer le bloc dans le contexte
  # dans lequel le module est inclus (c'est-à-dire Blorgh::Article),
  # plutôt que dans le module lui-même.
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_validation :set_author

    private
      def set_author
        self.author = User.find_or_create_by(name: author_name)
      end
  end

  def summary
    "#{title}"
  end

  module ClassMethods
    def some_class_method
      'some class method string'
    end
  end
end
```

### Autoloading et moteurs

Veuillez consulter le guide [Autoloading and Reloading Constants](autoloading_and_reloading_constants.html#autoloading-and-engines) pour plus d'informations sur l'autoloading et les moteurs.


### Remplacement des vues

Lorsque Rails recherche une vue à rendre, il recherche d'abord dans le répertoire `app/views` de l'application. S'il ne la trouve pas là, il vérifie dans les répertoires `app/views` de tous les moteurs qui ont ce répertoire.

Lorsque l'application est invitée à rendre la vue pour l'action `index` du contrôleur `Blorgh::ArticlesController`, elle recherche d'abord le chemin `app/views/blorgh/articles/index.html.erb` dans l'application. Si elle ne le trouve pas, elle le recherche dans le moteur.

Vous pouvez remplacer cette vue dans l'application en créant simplement un nouveau fichier à `app/views/blorgh/articles/index.html.erb`. Ensuite, vous pouvez modifier complètement ce que cette vue produirait normalement.

Essayez maintenant en créant un nouveau fichier à `app/views/blorgh/articles/index.html.erb` et en y mettant ce contenu :

```html+erb
<h1>Articles</h1>
<%= link_to "New Article", new_article_path %>
<% @articles.each do |article| %>
  <h2><%= article.title %></h2>
  <small>By <%= article.author %></small>
  <%= simple_format(article.text) %>
  <hr>
<% end %>
```

### Routes

Les routes à l'intérieur d'un moteur sont isolées de l'application par défaut. Cela est réalisé par l'appel à `isolate_namespace` à l'intérieur de la classe `Engine`. Cela signifie essentiellement que l'application et ses moteurs peuvent avoir des routes portant le même nom et qu'elles ne se chevaucheront pas.

Les routes à l'intérieur d'un moteur sont définies sur la classe `Engine` dans `config/routes.rb`, comme ceci :

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

En ayant des routes isolées comme celles-ci, si vous souhaitez créer un lien vers une zone d'un moteur à partir de l'application, vous devrez utiliser la méthode de proxy de routage du moteur. Les appels aux méthodes de routage normales telles que `articles_path` peuvent finir par aller à des emplacements indésirables si l'application et le moteur ont tous deux une telle aide définie.

Par exemple, l'exemple suivant irait vers `articles_path` de l'application si ce modèle était rendu à partir de l'application, ou vers `articles_path` du moteur s'il était rendu à partir du moteur :
```erb
<%= link_to "Articles de blog", articles_path %>
```

Pour que cette route utilise toujours la méthode d'aide de routage `articles_path` du moteur,
nous devons appeler la méthode sur la méthode proxy de routage qui porte le même nom que
le moteur.

```erb
<%= link_to "Articles de blog", blorgh.articles_path %>
```

Si vous souhaitez faire référence à l'application à l'intérieur du moteur de manière similaire, utilisez
l'aide `main_app` :

```erb
<%= link_to "Accueil", main_app.root_path %>
```

Si vous utilisez cela à l'intérieur d'un moteur, cela ira **toujours** à la
racine de l'application. Si vous omettez l'appel à la méthode proxy de routage `main_app`,
cela pourrait éventuellement aller à la racine du moteur ou de l'application,
selon l'endroit où il a été appelé.

Si un modèle rendu à partir d'un moteur tente d'utiliser l'une des
méthodes d'aide de routage de l'application, cela peut entraîner un appel à une méthode non définie.
Si vous rencontrez un tel problème, assurez-vous de ne pas essayer d'appeler les
méthodes de routage de l'application sans le préfixe `main_app` à partir du
moteur.

### Ressources

Les ressources à l'intérieur d'un moteur fonctionnent de la même manière que dans une application complète. Parce que
la classe du moteur hérite de `Rails::Engine`, l'application saura
rechercher les ressources dans les répertoires `app/assets` et `lib/assets` du moteur.

Comme tous les autres composants d'un moteur, les ressources doivent être regroupées.
Cela signifie que si vous avez une ressource appelée `style.css`, elle doit être placée dans
`app/assets/stylesheets/[nom du moteur]/style.css`, plutôt que
`app/assets/stylesheets/style.css`. Si cette ressource n'est pas regroupée, il y a
une possibilité que l'application hôte ait une ressource portant le même nom, auquel cas la ressource de l'application
prendrait le dessus et celle du moteur serait ignorée.

Imaginez que vous ayez une ressource située à
`app/assets/stylesheets/blorgh/style.css`. Pour inclure cette ressource dans une
application, utilisez simplement `stylesheet_link_tag` et référencez la ressource comme si elle
était à l'intérieur du moteur :

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

Vous pouvez également spécifier ces ressources en tant que dépendances d'autres ressources en utilisant des déclarations de dépendance de l'Asset Pipeline dans les fichiers traités :

```css
/*
 *= require blorgh/style
 */
```

INFO. N'oubliez pas qu'en utilisant des langages comme Sass ou CoffeeScript, vous
devriez ajouter la bibliothèque correspondante au fichier `.gemspec` de votre moteur.

### Séparation des ressources et précompilation

Il y a des situations où les ressources de votre moteur ne sont pas nécessaires pour
l'application hôte. Par exemple, supposons que vous ayez créé une fonctionnalité d'administration
qui n'existe que pour votre moteur. Dans ce cas, l'application hôte n'a pas besoin de
demander `admin.css` ou `admin.js`. Seul le modèle d'administration du gemme a besoin
de ces ressources. Il n'a pas de sens pour l'application hôte d'inclure
`"blorgh/admin.css"` dans ses feuilles de style. Dans cette situation, vous devriez
définir explicitement ces ressources pour la précompilation. Cela indique à Sprockets d'ajouter
les ressources de votre moteur lorsque `bin/rails assets:precompile` est déclenché.

Vous pouvez définir les ressources pour la précompilation dans `engine.rb` :

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile += %w( admin.js admin.css )
end
```

Pour plus d'informations, consultez le [guide de l'Asset Pipeline](asset_pipeline.html).

### Autres dépendances de gemmes

Les dépendances de gemmes à l'intérieur d'un moteur doivent être spécifiées dans le fichier `.gemspec`
à la racine du moteur. La raison en est que le moteur peut être installé en tant que
gemme. Si les dépendances étaient spécifiées dans le `Gemfile`, elles ne seraient pas
reconnues par une installation de gemme traditionnelle et ne seraient donc pas installées,
ce qui provoquerait un dysfonctionnement du moteur.

Pour spécifier une dépendance qui doit être installée avec le moteur lors d'une
installation de gemme traditionnelle, spécifiez-la à l'intérieur du bloc `Gem::Specification`
dans le fichier `.gemspec` du moteur :

```ruby
s.add_dependency "moo"
```

Pour spécifier une dépendance qui ne doit être installée qu'en tant que
dépendance de développement de l'application, spécifiez-la comme ceci :

```ruby
s.add_development_dependency "moo"
```

Les deux types de dépendances seront installés lorsque `bundle install` est exécuté à l'intérieur
de l'application. Les dépendances de développement pour le gemme ne seront utilisées
que lorsque le développement et les tests du moteur sont en cours d'exécution.

Notez que si vous souhaitez exiger immédiatement des dépendances lorsque le moteur est
requis, vous devez les exiger avant l'initialisation du moteur. Par exemple :

```ruby
require "other_engine/engine"
require "yet_another_engine/engine"

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```

Hooks de chargement et de configuration
----------------------------

Le code Rails peut souvent être référencé lors du chargement d'une application. Rails est responsable de l'ordre de chargement de ces frameworks, donc lorsque vous chargez des frameworks, tels que `ActiveRecord::Base`, prématurément, vous violez un contrat implicite que votre application a avec Rails. De plus, en chargeant du code tel que `ActiveRecord::Base` au démarrage de votre application, vous chargez des frameworks entiers qui peuvent ralentir le temps de démarrage et causer des conflits avec l'ordre de chargement et le démarrage de votre application.
Les hooks de chargement et de configuration sont l'API qui vous permet de vous brancher sur ce processus d'initialisation sans violer le contrat de chargement avec Rails. Cela permet également de réduire la dégradation des performances de démarrage et d'éviter les conflits.

### Éviter le chargement des frameworks Rails

Étant donné que Ruby est un langage dynamique, certains codes entraîneront le chargement de différents frameworks Rails. Prenons par exemple ce fragment de code :

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

Ce fragment signifie que lorsque ce fichier est chargé, il rencontrera `ActiveRecord::Base`. Cette rencontre amène Ruby à rechercher la définition de cette constante et à la charger. Cela entraîne le chargement complet du framework Active Record au démarrage.

`ActiveSupport.on_load` est un mécanisme qui peut être utilisé pour différer le chargement du code jusqu'à ce qu'il soit réellement nécessaire. Le fragment ci-dessus peut être modifié comme suit :

```ruby
ActiveSupport.on_load(:active_record) do
  include MyActiveRecordHelper
end
```

Ce nouveau fragment inclura uniquement `MyActiveRecordHelper` lorsque `ActiveRecord::Base` sera chargé.

### Quand les hooks sont-ils appelés ?

Dans le framework Rails, ces hooks sont appelés lorsqu'une bibliothèque spécifique est chargée. Par exemple, lorsque `ActionController::Base` est chargé, le hook `:action_controller_base` est appelé. Cela signifie que tous les appels `ActiveSupport.on_load` avec des hooks `:action_controller_base` seront appelés dans le contexte de `ActionController::Base` (ce qui signifie que `self` sera un `ActionController::Base`).

### Modification du code pour utiliser les hooks de chargement

La modification du code est généralement simple. Si vous avez une ligne de code qui fait référence à un framework Rails tel que `ActiveRecord::Base`, vous pouvez envelopper ce code dans un hook de chargement.

**Modification des appels à `include`**

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

devient

```ruby
ActiveSupport.on_load(:active_record) do
  # self fait référence à ActiveRecord::Base ici,
  # nous pouvons donc appeler .include
  include MyActiveRecordHelper
end
```

**Modification des appels à `prepend`**

```ruby
ActionController::Base.prepend(MyActionControllerHelper)
```

devient

```ruby
ActiveSupport.on_load(:action_controller_base) do
  # self fait référence à ActionController::Base ici,
  # nous pouvons donc appeler .prepend
  prepend MyActionControllerHelper
end
```

**Modification des appels aux méthodes de classe**

```ruby
ActiveRecord::Base.include_root_in_json = true
```

devient

```ruby
ActiveSupport.on_load(:active_record) do
  # self fait référence à ActiveRecord::Base ici
  self.include_root_in_json = true
end
```

### Hooks de chargement disponibles

Voici les hooks de chargement que vous pouvez utiliser dans votre propre code. Pour vous brancher sur le processus d'initialisation de l'une des classes suivantes, utilisez le hook disponible.

| Classe                                | Hook                                 |
| -------------------------------------| ------------------------------------ |
| `ActionCable`                        | `action_cable`                       |
| `ActionCable::Channel::Base`         | `action_cable_channel`               |
| `ActionCable::Connection::Base`      | `action_cable_connection`            |
| `ActionCable::Connection::TestCase`  | `action_cable_connection_test_case`  |
| `ActionController::API`              | `action_controller_api`              |
| `ActionController::API`              | `action_controller`                  |
| `ActionController::Base`             | `action_controller_base`             |
| `ActionController::Base`             | `action_controller`                  |
| `ActionController::TestCase`         | `action_controller_test_case`        |
| `ActionDispatch::IntegrationTest`    | `action_dispatch_integration_test`   |
| `ActionDispatch::Response`           | `action_dispatch_response`           |
| `ActionDispatch::Request`            | `action_dispatch_request`            |
| `ActionDispatch::SystemTestCase`     | `action_dispatch_system_test_case`   |
| `ActionMailbox::Base`                | `action_mailbox`                     |
| `ActionMailbox::InboundEmail`        | `action_mailbox_inbound_email`       |
| `ActionMailbox::Record`              | `action_mailbox_record`              |
| `ActionMailbox::TestCase`            | `action_mailbox_test_case`           |
| `ActionMailer::Base`                 | `action_mailer`                      |
| `ActionMailer::TestCase`             | `action_mailer_test_case`            |
| `ActionText::Content`                | `action_text_content`                |
| `ActionText::Record`                 | `action_text_record`                 |
| `ActionText::RichText`               | `action_text_rich_text`              |
| `ActionText::EncryptedRichText`      | `action_text_encrypted_rich_text`    |
| `ActionView::Base`                   | `action_view`                        |
| `ActionView::TestCase`               | `action_view_test_case`              |
| `ActiveJob::Base`                    | `active_job`                         |
| `ActiveJob::TestCase`                | `active_job_test_case`               |
| `ActiveRecord::Base`                 | `active_record`                      |
| `ActiveRecord::TestFixtures`         | `active_record_fixtures`             |
| `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter`    | `active_record_postgresqladapter`    |
| `ActiveRecord::ConnectionAdapters::Mysql2Adapter`        | `active_record_mysql2adapter`        |
| `ActiveRecord::ConnectionAdapters::TrilogyAdapter`       | `active_record_trilogyadapter`       |
| `ActiveRecord::ConnectionAdapters::SQLite3Adapter`       | `active_record_sqlite3adapter`       |
| `ActiveStorage::Attachment`          | `active_storage_attachment`          |
| `ActiveStorage::VariantRecord`       | `active_storage_variant_record`      |
| `ActiveStorage::Blob`                | `active_storage_blob`                |
| `ActiveStorage::Record`              | `active_storage_record`              |
| `ActiveSupport::TestCase`            | `active_support_test_case`           |
| `i18n`                               | `i18n`                               |

### Hooks de configuration disponibles

Les hooks de configuration ne se branchent sur aucun framework en particulier, mais s'exécutent plutôt dans le contexte de l'application entière.

| Hook                   | Cas d'utilisation                                                                 |
| ---------------------- | -------------------------------------------------------------------------------- |
| `before_configuration` | Premier bloc configurable à exécuter. Appelé avant l'exécution de tout initialisateur. |
| `before_initialize`    | Deuxième bloc configurable à exécuter. Appelé avant l'initialisation des frameworks. |
| `before_eager_load`    | Troisième bloc configurable à exécuter. Ne s'exécute pas si [`config.eager_load`][] est défini sur false. |
| `after_initialize`     | Dernier bloc configurable à exécuter. Appelé après l'initialisation des frameworks. |

Les hooks de configuration peuvent être appelés dans la classe Engine.

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    config.before_configuration do
      puts 'Je suis appelé avant tout initialisateur'
    end
  end
end
```
[`config.eager_load`]: configuring.html#config-eager-load
