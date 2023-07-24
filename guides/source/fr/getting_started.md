**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2cf37358fedc8b51ed3ab7f408ecfc76
Commencer avec Rails
==========================

Ce guide explique comment démarrer avec Ruby on Rails.

Après avoir lu ce guide, vous saurez :

* Comment installer Rails, créer une nouvelle application Rails et connecter votre
  application à une base de données.
* La structure générale d'une application Rails.
* Les principes de base du modèle MVC (Modèle, Vue, Contrôleur) et de la conception RESTful.
* Comment générer rapidement les éléments de départ d'une application Rails.

--------------------------------------------------------------------------------

Prérequis du guide
-----------------

Ce guide est conçu pour les débutants qui souhaitent commencer à créer une application Rails
à partir de zéro. Il ne suppose aucune expérience préalable
avec Rails.

Rails est un framework d'application web fonctionnant sur le langage de programmation Ruby.
Si vous n'avez aucune expérience préalable avec Ruby, vous trouverez une courbe d'apprentissage très raide
en plongeant directement dans Rails. Il existe plusieurs listes de ressources en ligne sélectionnées
pour apprendre Ruby :

* [Site officiel du langage de programmation Ruby](https://www.ruby-lang.org/en/documentation/)
* [Liste de livres de programmation gratuits](https://github.com/EbookFoundation/free-programming-books/blob/master/books/free-programming-books-langs.md#ruby)

Sachez que certaines ressources, bien qu'excellentes, couvrent des versions plus anciennes de
Ruby et peuvent ne pas inclure certaines syntaxes que vous verrez dans le développement quotidien
avec Rails.

Qu'est-ce que Rails ?
--------------

Rails est un framework de développement d'applications web écrit dans le langage de programmation Ruby.
Il est conçu pour faciliter la programmation d'applications web en faisant des hypothèses
sur ce dont chaque développeur a besoin pour commencer. Il vous permet d'écrire moins
de code tout en accomplissant plus de choses que de nombreux autres langages et frameworks.
Les développeurs Rails expérimentés rapportent également que cela rend le développement d'applications web
plus amusant.

Rails est un logiciel orienté. Il suppose qu'il existe une "meilleure"
façon de faire les choses, et il est conçu pour encourager cette façon - et dans certains cas pour
décourager les alternatives. Si vous apprenez "La manière Rails", vous découvrirez probablement une
augmentation considérable de la productivité. Si vous persistez à apporter de vieilles habitudes
d'autres langages à votre développement Rails et à essayer d'utiliser des modèles que vous
avez appris ailleurs, vous pourriez avoir une expérience moins agréable.

La philosophie de Rails comprend deux principes directeurs majeurs :

* **Ne vous répétez pas (DRY) :** DRY est un principe de développement logiciel qui
  stipule que "chaque connaissance doit avoir une représentation unique, non ambiguë, autoritaire
  au sein d'un système". En n'écrivant pas les mêmes informations encore et encore,
  notre code est plus maintenable, plus extensible et moins bogué.
* **Convention plutôt que configuration :** Rails a des opinions sur la meilleure façon de faire de nombreuses
  choses dans une application web et utilise par défaut cet ensemble de conventions, plutôt que
  vous obliger à spécifier des détails minutieux à travers d'innombrables fichiers de configuration.

Créer un nouveau projet Rails
----------------------------

La meilleure façon de lire ce guide est de le suivre étape par étape. Toutes les étapes sont
essentielles pour exécuter cette application exemple et aucun code ou étape supplémentaire n'est
nécessaire.

En suivant ce guide, vous allez créer un projet Rails appelé
`blog`, un blog (très) simple. Avant de pouvoir commencer à construire l'application,
vous devez vous assurer d'avoir Rails lui-même installé.

NOTE : Les exemples ci-dessous utilisent le symbole `$` pour représenter l'invite de terminal dans un système d'exploitation de type UNIX,
bien qu'il puisse avoir été personnalisé pour apparaître différemment. Si vous utilisez Windows,
votre invite ressemblera à quelque chose comme `C:\source_code>`.

### Installation de Rails

Avant d'installer Rails, vous devez vérifier que votre système dispose des
prérequis nécessaires. Ceux-ci comprennent :

* Ruby
* SQLite3

#### Installation de Ruby

Ouvrez une invite de commande. Sur macOS, ouvrez Terminal.app ; sur Windows, choisissez
"Exécuter" dans votre menu Démarrer et tapez `cmd.exe`. Toutes les commandes précédées d'un
signe dollar `$` doivent être exécutées dans la ligne de commande. Vérifiez que vous avez une
version récente de Ruby installée :

```bash
$ ruby --version
ruby 2.7.0
```

Rails nécessite la version 2.7.0 ou ultérieure de Ruby. Il est préférable d'utiliser la dernière version de Ruby.
Si le numéro de version retourné est inférieur à ce nombre (comme 2.3.7 ou 1.8.7),
vous devrez installer une nouvelle copie de Ruby.

Pour installer Rails sur Windows, vous devrez d'abord installer [Ruby Installer](https://rubyinstaller.org/).

Pour plus de méthodes d'installation pour la plupart des systèmes d'exploitation, consultez
[ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/).

#### Installation de SQLite3

Vous aurez également besoin d'une installation de la base de données SQLite3. 
De nombreux systèmes d'exploitation de type UNIX incluent une version acceptable de SQLite3.
D'autres peuvent trouver des instructions d'installation sur le site web de [SQLite3](https://www.sqlite.org).
Vérifiez qu'il est correctement installé et dans votre `PATH` de chargement :

```bash
$ sqlite3 --version
```

Le programme devrait afficher sa version.

#### Installation de Rails

Pour installer Rails, utilisez la commande `gem install` fournie par RubyGems :

```bash
$ gem install rails
```

Pour vérifier que vous avez tout installé correctement, vous devriez pouvoir
exécuter la commande suivante dans un nouveau terminal :

```bash
$ rails --version
```

Si cela affiche quelque chose comme "Rails 7.0.0", vous êtes prêt à continuer.

### Création de l'application Blog

Rails est livré avec un certain nombre de scripts appelés générateurs qui sont conçus pour faciliter votre vie de développeur en créant tout ce qui est nécessaire pour commencer à travailler sur une tâche particulière. L'un d'entre eux est le générateur de nouvelle application, qui vous fournira les bases d'une nouvelle application Rails afin que vous n'ayez pas à l'écrire vous-même.

Pour utiliser ce générateur, ouvrez un terminal, naviguez jusqu'à un répertoire où vous avez le droit de créer des fichiers, et exécutez :

```bash
$ rails new blog
```

Cela créera une application Rails appelée Blog dans un répertoire `blog` et
installera les dépendances des gemmes qui sont déjà mentionnées dans `Gemfile` en utilisant `bundle install`.

CONSEIL : Vous pouvez voir toutes les options de ligne de commande acceptées par le générateur d'application Rails en exécutant `rails new --help`.

Après avoir créé l'application de blog, passez dans son dossier :

```bash
$ cd blog
```

Le répertoire `blog` contiendra un certain nombre de fichiers et de dossiers générés qui constituent la structure d'une application Rails. La plupart du travail dans ce tutoriel se fera dans le dossier `app`, mais voici un aperçu basique de la fonction de chacun des fichiers et dossiers que Rails crée par défaut :

| Fichier/Dossier | But |
| ----------- | ------- |
|app/|Contient les contrôleurs, les modèles, les vues, les helpers, les mailers, les channels, les jobs et les assets de votre application. Vous vous concentrerez sur ce dossier pour le reste de ce guide.|
|bin/|Contient le script `rails` qui lance votre application et peut contenir d'autres scripts que vous utilisez pour configurer, mettre à jour, déployer ou exécuter votre application.|
|config/|Contient la configuration des routes, de la base de données et plus encore pour votre application. Cela est expliqué en détail dans [Configuration des applications Rails](configuring.html).|
|config.ru|Configuration Rack pour les serveurs basés sur Rack utilisés pour démarrer l'application. Pour plus d'informations sur Rack, consultez le [site web de Rack](https://rack.github.io/).|
|db/|Contient le schéma de votre base de données actuelle, ainsi que les migrations de la base de données.|
|Gemfile<br>Gemfile.lock|Ces fichiers vous permettent de spécifier les dépendances des gemmes nécessaires à votre application Rails. Ces fichiers sont utilisés par la gemme Bundler. Pour plus d'informations sur Bundler, consultez le [site web de Bundler](https://bundler.io).|
|lib/|Modules étendus pour votre application.|
|log/|Fichiers journaux de l'application.|
|public/|Contient les fichiers statiques et les assets compilés. Lorsque votre application est en cours d'exécution, ce répertoire sera exposé tel quel.|
|Rakefile|Ce fichier localise et charge les tâches qui peuvent être exécutées depuis la ligne de commande. Les définitions des tâches sont définies dans les composants de Rails. Au lieu de modifier `Rakefile`, vous devriez ajouter vos propres tâches en ajoutant des fichiers au répertoire `lib/tasks` de votre application.|
|README.md|Il s'agit d'un bref manuel d'instruction pour votre application. Vous devriez éditer ce fichier pour indiquer aux autres ce que fait votre application, comment la configurer, etc.|
|storage/|Fichiers Active Storage pour le service Disk. Cela est expliqué dans [Présentation d'Active Storage](active_storage_overview.html).|
|test/|Tests unitaires, fixtures et autres appareils de test. Cela est expliqué dans [Tests des applications Rails](testing.html).|
|tmp/|Fichiers temporaires (comme le cache et les fichiers pid).|
|vendor/|Un emplacement pour tout le code tiers. Dans une application Rails typique, cela inclut les gemmes vendues.|
|.gitattributes|Ce fichier définit les métadonnées pour des chemins spécifiques dans un dépôt git. Ces métadonnées peuvent être utilisées par git et d'autres outils pour améliorer leur comportement. Consultez la [documentation de gitattributes](https://git-scm.com/docs/gitattributes) pour plus d'informations.|
|.gitignore|Ce fichier indique à git quels fichiers (ou motifs) il doit ignorer. Consultez [GitHub - Ignorer des fichiers](https://help.github.com/articles/ignoring-files) pour plus d'informations sur l'ignorance des fichiers.|
|.ruby-version|Ce fichier contient la version Ruby par défaut.|

Bonjour, Rails !
-------------

Pour commencer, affichons rapidement du texte à l'écran. Pour cela, vous devez
démarrer le serveur d'application Rails.

### Démarrage du serveur web

Vous avez déjà une application Rails fonctionnelle. Pour la voir, vous devez
démarrer un serveur web sur votre machine de développement. Vous pouvez le faire en exécutant la commande suivante dans le répertoire `blog` :

```bash
$ bin/rails server
```
CONSEIL : Si vous utilisez Windows, vous devez passer les scripts du dossier `bin` directement à l'interpréteur Ruby, par exemple `ruby bin\rails server`.

CONSEIL : La compression des ressources JavaScript nécessite un moteur d'exécution JavaScript disponible sur votre système. En l'absence d'un moteur d'exécution, vous verrez une erreur `execjs` lors de la compression des ressources. Généralement, macOS et Windows sont livrés avec un moteur d'exécution JavaScript installé. `therubyrhino` est le moteur d'exécution recommandé pour les utilisateurs de JRuby et est ajouté par défaut au `Gemfile` des applications générées sous JRuby. Vous pouvez explorer tous les moteurs d'exécution pris en charge sur [ExecJS](https://github.com/rails/execjs#readme).

Cela lancera Puma, un serveur web distribué avec Rails par défaut. Pour voir votre application en action, ouvrez une fenêtre de navigateur et accédez à l'adresse <http://localhost:3000>. Vous devriez voir la page d'information par défaut de Rails :

![Capture d'écran de la page de démarrage de Rails](images/getting_started/rails_welcome.png)

Lorsque vous souhaitez arrêter le serveur web, appuyez sur Ctrl+C dans la fenêtre du terminal où il s'exécute. En environnement de développement, Rails n'a généralement pas besoin d'être redémarré ; les modifications que vous apportez aux fichiers seront automatiquement prises en compte par le serveur.

La page de démarrage de Rails est le _test de fumée_ pour une nouvelle application Rails : elle vérifie que votre logiciel est correctement configuré pour servir une page.

### Dire "Bonjour", Rails

Pour que Rails dise "Bonjour", vous devez créer au minimum une *route*, un *contrôleur* avec une *action*, et une *vue*. Une route mappe une requête vers une action du contrôleur. Une action du contrôleur effectue le travail nécessaire pour traiter la requête et prépare les données éventuelles pour la vue. Une vue affiche les données dans un format souhaité.

En termes d'implémentation : les routes sont des règles écrites dans un [DSL (Domain-Specific Language)](https://en.wikipedia.org/wiki/Domain-specific_language) Ruby. Les contrôleurs sont des classes Ruby, et leurs méthodes publiques sont des actions. Et les vues sont des templates, généralement écrits dans un mélange de HTML et de Ruby.

Commençons par ajouter une route à notre fichier de routes, `config/routes.rb`, en haut du bloc `Rails.application.routes.draw` :

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # Pour plus de détails sur le DSL disponible dans ce fichier, consultez https://guides.rubyonrails.org/routing.html
end
```

La route ci-dessus déclare que les requêtes `GET /articles` sont mappées à l'action `index` du contrôleur `ArticlesController`.

Pour créer `ArticlesController` et son action `index`, nous allons exécuter le générateur de contrôleurs (avec l'option `--skip-routes` car nous avons déjà une route appropriée) :

```bash
$ bin/rails generate controller Articles index --skip-routes
```

Rails créera plusieurs fichiers pour vous :

```
create  app/controllers/articles_controller.rb
invoke  erb
create    app/views/articles
create    app/views/articles/index.html.erb
invoke  test_unit
create    test/controllers/articles_controller_test.rb
invoke  helper
create    app/helpers/articles_helper.rb
invoke    test_unit
```

Le plus important de ces fichiers est le fichier de contrôleur, `app/controllers/articles_controller.rb`. Jetons-y un coup d'œil :

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```

L'action `index` est vide. Lorsqu'une action ne rend pas explicitement une vue (ou ne déclenche pas une réponse HTTP), Rails rendra automatiquement une vue qui correspond au nom du contrôleur et de l'action. Convention Over Configuration ! Les vues se trouvent dans le répertoire `app/views`. Ainsi, l'action `index` rendra par défaut `app/views/articles/index.html.erb`.

Ouvrons `app/views/articles/index.html.erb` et remplaçons son contenu par :

```html
<h1>Bonjour, Rails !</h1>
```

Si vous avez précédemment arrêté le serveur web pour exécuter le générateur de contrôleurs, redémarrez-le avec `bin/rails server`. Maintenant, visitez <http://localhost:3000/articles> et vous verrez notre texte affiché !

### Définir la page d'accueil de l'application

Pour l'instant, <http://localhost:3000> affiche toujours une page avec le logo Ruby on Rails. Affichons également notre texte "Bonjour, Rails !" à l'adresse <http://localhost:3000>. Pour ce faire, nous allons ajouter une route qui mappe le *chemin racine* de notre application vers le contrôleur et l'action appropriés.

Ouvrons `config/routes.rb` et ajoutons la route `root` suivante en haut du bloc `Rails.application.routes.draw` :

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

Maintenant, nous pouvons voir notre texte "Bonjour, Rails !" lorsque nous visitons <http://localhost:3000>, confirmant que la route `root` est également mappée vers l'action `index` de `ArticlesController`.

CONSEIL : Pour en savoir plus sur le routage, consultez [Rails Routing from the Outside In](routing.html).

Chargement automatique
-----------

Les applications Rails **n'utilisent pas** `require` pour charger le code de l'application.

Vous avez peut-être remarqué que `ArticlesController` hérite de `ApplicationController`, mais que `app/controllers/articles_controller.rb` ne contient rien comme

```ruby
require "application_controller" # NE FAITES PAS ÇA.
```

Les classes et modules de l'application sont disponibles partout, vous n'avez pas besoin et **ne devez pas** charger quoi que ce soit sous `app` avec `require`. Cette fonctionnalité s'appelle le _chargement automatique_ et vous pouvez en apprendre plus à ce sujet dans [_Autoloading and Reloading Constants_](autoloading_and_reloading_constants.html).
Vous n'avez besoin que d'appels `require` pour deux cas d'utilisation :

* Pour charger des fichiers sous le répertoire `lib`.
* Pour charger les dépendances des gemmes qui ont `require: false` dans le `Gemfile`.

MVC et Vous
-----------

Jusqu'à présent, nous avons discuté des routes, des contrôleurs, des actions et des vues. Tous ces éléments sont des éléments typiques d'une application web qui suit le modèle [MVC (Modèle-Vue-Contrôleur)](https://fr.wikipedia.org/wiki/Mod%C3%A8le-vue-contr%C3%B4leur). MVC est un modèle de conception qui divise les responsabilités d'une application pour la rendre plus facile à comprendre. Rails suit ce modèle de conception par convention.

Étant donné que nous avons un contrôleur et une vue avec lesquels travailler, générons la prochaine pièce : un modèle.

### Génération d'un modèle

Un *modèle* est une classe Ruby utilisée pour représenter des données. De plus, les modèles peuvent interagir avec la base de données de l'application grâce à une fonctionnalité de Rails appelée *Active Record*.

Pour définir un modèle, nous utiliserons le générateur de modèles :

```bash
$ bin/rails generate model Article title:string body:text
```

NOTE : Les noms de modèles sont **au singulier**, car un modèle instancié représente un seul enregistrement de données. Pour vous aider à vous souvenir de cette convention, pensez à la façon dont vous appelleriez le constructeur du modèle : nous voulons écrire `Article.new(...)`, **pas** `Articles.new(...)`.

Cela créera plusieurs fichiers :

```
invoke  active_record
create    db/migrate/<timestamp>_create_articles.rb
create    app/models/article.rb
invoke    test_unit
create      test/models/article_test.rb
create      test/fixtures/articles.yml
```

Les deux fichiers sur lesquels nous allons nous concentrer sont le fichier de migration (`db/migrate/<timestamp>_create_articles.rb`) et le fichier de modèle (`app/models/article.rb`).

### Migrations de base de données

Les *migrations* sont utilisées pour modifier la structure de la base de données d'une application. Dans les applications Rails, les migrations sont écrites en Ruby afin d'être indépendantes de la base de données.

Jetons un coup d'œil au contenu de notre nouveau fichier de migration :

```ruby
class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

L'appel à `create_table` spécifie comment la table `articles` doit être construite. Par défaut, la méthode `create_table` ajoute une colonne `id` en tant que clé primaire auto-incrémentée. Ainsi, le premier enregistrement de la table aura un `id` de 1, le prochain enregistrement aura un `id` de 2, et ainsi de suite.

À l'intérieur du bloc de `create_table`, deux colonnes sont définies : `title` et `body`. Elles ont été ajoutées par le générateur car nous les avons incluses dans notre commande de génération (`bin/rails generate model Article title:string body:text`).

À la dernière ligne du bloc se trouve un appel à `t.timestamps`. Cette méthode définit deux colonnes supplémentaires nommées `created_at` et `updated_at`. Comme nous le verrons, Rails les gérera pour nous en définissant les valeurs lorsque nous créons ou mettons à jour un objet de modèle.

Exécutons notre migration avec la commande suivante :

```bash
$ bin/rails db:migrate
```

La commande affichera une sortie indiquant que la table a été créée :

```
==  CreateArticles: migrating ===================================
-- create_table(:articles)
   -> 0.0018s
==  CreateArticles: migrated (0.0018s) ==========================
```

CONSEIL : Pour en savoir plus sur les migrations, consultez la documentation sur les [migrations d'Active Record](https://guides.rubyonrails.org/active_record_migrations.html).

Maintenant, nous pouvons interagir avec la table en utilisant notre modèle.

### Utilisation d'un modèle pour interagir avec la base de données

Pour jouer un peu avec notre modèle, nous allons utiliser une fonctionnalité de Rails appelée la *console*. La console est un environnement de codage interactif comme `irb`, mais elle charge également automatiquement Rails et le code de notre application.

Lançons la console avec la commande suivante :

```bash
$ bin/rails console
```

Vous devriez voir un invite `irb` comme ceci :

```irb
Loading development environment (Rails 7.0.0)
irb(main):001:0>
```

À cette invite, nous pouvons initialiser un nouvel objet `Article` :

```irb
irb> article = Article.new(title: "Hello Rails", body: "I am on Rails!")
```

Il est important de noter que nous avons seulement *initialisé* cet objet. Cet objet n'est pas du tout enregistré dans la base de données. Il est uniquement disponible dans la console pour le moment. Pour enregistrer l'objet dans la base de données, nous devons appeler la méthode [`save`](https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save) :

```irb
irb> article.save
(0.1ms)  begin transaction
Article Create (0.4ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "Hello Rails"], ["body", "I am on Rails!"], ["created_at", "2020-01-18 23:47:30.734416"], ["updated_at", "2020-01-18 23:47:30.734416"]]
(0.9ms)  commit transaction
=> true
```

La sortie ci-dessus montre une requête de base de données `INSERT INTO "articles" ...`. Cela indique que l'article a été inséré dans notre table. Et si nous examinons à nouveau l'objet `article`, nous constatons qu'il s'est passé quelque chose d'intéressant :

```irb
irb> article
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```
Les attributs `id`, `created_at` et `updated_at` de l'objet sont maintenant définis. Rails l'a fait pour nous lorsque nous avons enregistré l'objet.

Lorsque nous voulons récupérer cet article depuis la base de données, nous pouvons appeler [`find`] (https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find) sur le modèle et passer l'`id` en argument:

```irb
irb> Article.find(1)
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

Et lorsque nous voulons récupérer tous les articles de la base de données, nous pouvons appeler [`all`] (https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all) sur le modèle:

```irb
irb> Article.all
=> #<ActiveRecord::Relation [#<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">]>
```

Cette méthode renvoie un objet [`ActiveRecord::Relation`] (https://api.rubyonrails.org/classes/ActiveRecord/Relation.html), que vous pouvez considérer comme un tableau surpuissant.

CONSEIL: Pour en savoir plus sur les modèles, consultez [Active Record Basics] (active_record_basics.html) et [Active Record Query Interface] (active_record_querying.html).

Les modèles sont la dernière pièce du puzzle MVC. Ensuite, nous allons connecter toutes les pièces ensemble.

### Affichage d'une liste d'articles

Revenons à notre contrôleur dans `app/controllers/articles_controller.rb`, et modifions l'action `index` pour récupérer tous les articles de la base de données:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

Les variables d'instance du contrôleur peuvent être accessibles par la vue. Cela signifie que nous pouvons faire référence à `@articles` dans `app/views/articles/index.html.erb`. Ouvrons ce fichier et remplaçons son contenu par:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

Le code ci-dessus est un mélange de HTML et d'ERB. ERB est un système de modèles qui évalue le code Ruby intégré dans un document. Ici, nous pouvons voir deux types de balises ERB: `<% %>` et `<%= %>`. La balise `<% %>` signifie "évaluer le code Ruby contenu". La balise `<%= %>` signifie "évaluer le code Ruby contenu et afficher la valeur qu'il retourne". Tout ce que vous pouvez écrire dans un programme Ruby normal peut être placé à l'intérieur de ces balises ERB, bien qu'il soit généralement préférable de garder le contenu des balises ERB court, pour des raisons de lisibilité.

Comme nous ne voulons pas afficher la valeur retournée par `@articles.each`, nous avons encapsulé ce code dans `<% %>`. Mais, comme nous voulons afficher la valeur retournée par `article.title` (pour chaque article), nous avons encapsulé ce code dans `<%= %>`.

Nous pouvons voir le résultat final en visitant <http://localhost:3000>. (N'oubliez pas que `bin/rails server` doit être en cours d'exécution!) Voici ce qui se passe lorsque nous le faisons:

1. Le navigateur envoie une requête: `GET http://localhost:3000`.
2. Notre application Rails reçoit cette requête.
3. Le routeur Rails mappe la route racine vers l'action `index` de `ArticlesController`.
4. L'action `index` utilise le modèle `Article` pour récupérer tous les articles de la base de données.
5. Rails rend automatiquement la vue `app/views/articles/index.html.erb`.
6. Le code ERB dans la vue est évalué pour générer du HTML.
7. Le serveur envoie une réponse contenant le HTML au navigateur.

Nous avons connecté toutes les pièces du MVC ensemble, et nous avons notre première action de contrôleur! Ensuite, nous passerons à la deuxième action.

CRUDit Where CRUDit Is Due
--------------------------

Presque toutes les applications web impliquent des opérations CRUD (Create, Read, Update et Delete). Vous constaterez peut-être même que la majorité du travail effectué par votre application est du CRUD. Rails reconnaît cela et fournit de nombreuses fonctionnalités pour simplifier le code effectuant des opérations CRUD.

Commençons à explorer ces fonctionnalités en ajoutant plus de fonctionnalités à notre application.

### Affichage d'un seul article

Nous avons actuellement une vue qui répertorie tous les articles de notre base de données. Ajoutons une nouvelle vue qui affiche le titre et le corps d'un seul article.

Nous commençons par ajouter une nouvelle route qui mappe vers une nouvelle action de contrôleur (que nous ajouterons ensuite). Ouvrez `config/routes.rb` et insérez la dernière route indiquée ici:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

La nouvelle route est une autre route `get`, mais elle a quelque chose en plus dans son chemin: `:id`. Cela désigne un *paramètre de route*. Un paramètre de route capture un segment du chemin de la requête et place cette valeur dans le `params` Hash, qui est accessible par l'action du contrôleur. Par exemple, lors du traitement d'une requête comme `GET http://localhost:3000/articles/1`, `1` serait capturé comme valeur pour `:id`, qui serait ensuite accessible en tant que `params[:id]` dans l'action `show` de `ArticlesController`.
Ajoutons maintenant l'action `show`, en dessous de l'action `index` dans `app/controllers/articles_controller.rb` :

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

L'action `show` appelle `Article.find` (mentionné précédemment) avec l'ID capturé par le paramètre de la route. L'article retourné est stocké dans la variable d'instance `@article`, ce qui permet d'y accéder depuis la vue. Par défaut, l'action `show` rendra `app/views/articles/show.html.erb`.

Créons maintenant `app/views/articles/show.html.erb`, avec le contenu suivant :

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

Maintenant, nous pouvons voir l'article lorsque nous visitons <http://localhost:3000/articles/1> !

Pour terminer, ajoutons un moyen pratique d'accéder à la page d'un article. Nous allons lier le titre de chaque article dans `app/views/articles/index.html.erb` à sa page :

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

### Routage des ressources

Jusqu'à présent, nous avons couvert la partie "R" (Read) de CRUD. Nous aborderons ultérieurement les parties "C" (Create), "U" (Update) et "D" (Delete). Comme vous l'avez peut-être deviné, nous le ferons en ajoutant de nouvelles routes, actions de contrôleur et vues. Chaque fois que nous avons une combinaison de routes, d'actions de contrôleur et de vues qui fonctionnent ensemble pour effectuer des opérations CRUD sur une entité, nous appelons cette entité une *ressource*. Par exemple, dans notre application, nous dirions qu'un article est une ressource.

Rails fournit une méthode de routage appelée [`resources`](https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources) qui mappe toutes les routes conventionnelles pour une collection de ressources, comme les articles. Avant de passer aux sections "C", "U" et "D", remplaçons les deux routes `get` dans `config/routes.rb` par `resources` :

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

Nous pouvons vérifier quelles routes sont mappées en exécutant la commande `bin/rails routes` :

```bash
$ bin/rails routes
      Prefix Verb   URI Pattern                  Controller#Action
        root GET    /                            articles#index
    articles GET    /articles(.:format)          articles#index
 new_article GET    /articles/new(.:format)      articles#new
     article GET    /articles/:id(.:format)      articles#show
             POST   /articles(.:format)          articles#create
edit_article GET    /articles/:id/edit(.:format) articles#edit
             PATCH  /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
```

La méthode `resources` configure également des méthodes d'aide pour les URL et les chemins que nous pouvons utiliser pour éviter que notre code ne dépende d'une configuration de route spécifique. Les valeurs de la colonne "Prefix" ci-dessus, plus un suffixe `_url` ou `_path`, forment les noms de ces méthodes d'aide. Par exemple, l'aide `article_path` renvoie `"/articles/#{article.id}"` lorsqu'un article est donné. Nous pouvons l'utiliser pour simplifier nos liens dans `app/views/articles/index.html.erb` :

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

Cependant, nous allons aller encore plus loin en utilisant l'aide [`link_to`](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to). L'aide `link_to` génère un lien avec son premier argument comme texte du lien et son deuxième argument comme destination du lien. Si nous passons un objet modèle comme deuxième argument, `link_to` appellera la méthode d'aide de chemin appropriée pour convertir l'objet en un chemin. Par exemple, si nous passons un article, `link_to` appellera `article_path`. Ainsi, `app/views/articles/index.html.erb` devient :

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

Super !

CONSEIL : Pour en savoir plus sur le routage, consultez [Rails Routing from the Outside In](routing.html).

### Création d'un nouvel article

Passons maintenant à la partie "C" (Create) de CRUD. En général, dans les applications web, la création d'une nouvelle ressource est un processus en plusieurs étapes. Tout d'abord, l'utilisateur demande un formulaire à remplir. Ensuite, l'utilisateur soumet le formulaire. S'il n'y a pas d'erreurs, la ressource est créée et une confirmation est affichée. Sinon, le formulaire est réaffiché avec des messages d'erreur, et le processus est répété.

Dans une application Rails, ces étapes sont généralement gérées par les actions `new` et `create` d'un contrôleur. Ajoutons une implémentation typique de ces actions à `app/controllers/articles_controller.rb`, en dessous de l'action `show` :

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

L'action `new` instancie un nouvel article, mais ne l'enregistre pas. Cet article sera utilisé dans la vue lors de la construction du formulaire. Par défaut, l'action `new` rendra `app/views/articles/new.html.erb`, que nous créerons ensuite.
L'action `create` instancie un nouvel article avec des valeurs pour le titre et le corps, puis tente de le sauvegarder. Si l'article est sauvegardé avec succès, l'action redirige le navigateur vers la page de l'article à l'adresse `"http://localhost:3000/articles/#{@article.id}"`.
Sinon, l'action réaffiche le formulaire en rendant `app/views/articles/new.html.erb` avec le code d'état [422 Unprocessable Entity](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/422).
Le titre et le corps ici sont des valeurs fictives. Après avoir créé le formulaire, nous reviendrons et modifierons ces valeurs.

NOTE: [`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to)
fera en sorte que le navigateur effectue une nouvelle requête,
tandis que [`render`](https://api.rubyonrails.org/classes/AbstractController/Rendering.html#method-i-render)
rend la vue spécifiée pour la requête en cours.
Il est important d'utiliser `redirect_to` après avoir modifié la base de données ou l'état de l'application.
Sinon, si l'utilisateur actualise la page, le navigateur effectuera la même requête et la mutation sera répétée.

#### Utilisation d'un constructeur de formulaire

Nous utiliserons une fonctionnalité de Rails appelée *constructeur de formulaire* pour créer notre formulaire. En utilisant un constructeur de formulaire, nous pouvons écrire un minimum de code pour générer un formulaire entièrement configuré qui suit les conventions de Rails.

Créons `app/views/articles/new.html.erb` avec le contenu suivant :

```html+erb
<h1>Nouvel article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

La méthode d'aide [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)
instancie un constructeur de formulaire. Dans le bloc `form_with`, nous appelons
des méthodes comme [`label`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-label)
et [`text_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_field)
sur le constructeur de formulaire pour générer les éléments de formulaire appropriés.

Le résultat de notre appel à `form_with` ressemblera à ceci :

```html
<form action="/articles" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="...">

  <div>
    <label for="article_title">Titre</label><br>
    <input type="text" name="article[title]" id="article_title">
  </div>

  <div>
    <label for="article_body">Corps</label><br>
    <textarea name="article[body]" id="article_body"></textarea>
  </div>

  <div>
    <input type="submit" name="commit" value="Créer l'article" data-disable-with="Créer l'article">
  </div>
</form>
```

CONSEIL : Pour en savoir plus sur les constructeurs de formulaire, consultez [Action View Form Helpers](
form_helpers.html).

#### Utilisation de Strong Parameters

Les données du formulaire soumises sont placées dans le Hash `params`, aux côtés des paramètres de route capturés. Ainsi, l'action `create` peut accéder au titre soumis via `params[:article][:title]` et au corps soumis via `params[:article][:body]`.
Nous pourrions passer ces valeurs individuellement à `Article.new`, mais cela serait verbeux et potentiellement sujet aux erreurs. Et cela deviendrait pire à mesure que nous ajoutons plus de champs.

Au lieu de cela, nous passerons un seul Hash contenant les valeurs. Cependant, nous devons toujours spécifier quelles valeurs sont autorisées dans ce Hash. Sinon, un utilisateur malveillant pourrait potentiellement soumettre des champs de formulaire supplémentaires et écraser des données privées. En fait, si nous passons directement le Hash `params[:article]` non filtré à `Article.new`, Rails lèvera une `ForbiddenAttributesError` pour nous alerter du problème. Nous utiliserons donc une fonctionnalité de Rails appelée *Strong Parameters* pour filtrer `params`. Pensez-y comme à une [forte typisation](https://en.wikipedia.org/wiki/Strong_and_weak_typing)
pour `params`.

Ajoutons une méthode privée en bas de `app/controllers/articles_controller.rb`
nommée `article_params` qui filtre `params`. Et modifions `create` pour l'utiliser :

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

CONSEIL : Pour en savoir plus sur les Strong Parameters, consultez [Action Controller Overview §
Strong Parameters](action_controller_overview.html#strong-parameters).

#### Validation et affichage des messages d'erreur

Comme nous l'avons vu, la création d'une ressource est un processus en plusieurs étapes. Gérer une saisie utilisateur invalide est une autre étape de ce processus. Rails propose une fonctionnalité appelée *validations* pour nous aider à traiter une saisie utilisateur invalide. Les validations sont des règles qui sont vérifiées avant qu'un objet modèle ne soit sauvegardé. Si l'une des vérifications échoue, la sauvegarde sera annulée et des messages d'erreur appropriés seront ajoutés à l'attribut `errors` de l'objet modèle.

Ajoutons quelques validations à notre modèle dans `app/models/article.rb` :

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

La première validation déclare qu'une valeur de `title` doit être présente. Comme
`title` est une chaîne de caractères, cela signifie que la valeur de `title` doit contenir au moins un
caractère autre qu'un espace.

La deuxième validation déclare qu'une valeur de `body` doit également être présente.
De plus, elle déclare que la valeur de `body` doit comporter au moins 10 caractères.

NOTE : Vous vous demandez peut-être où sont définis les attributs `title` et `body`.
Active Record définit automatiquement les attributs du modèle pour chaque colonne de la table, vous n'avez donc pas besoin de déclarer ces attributs dans votre fichier de modèle.
Avec nos validations en place, modifions `app/views/articles/new.html.erb` pour afficher les messages d'erreur pour `title` et `body` :

```html+erb
<h1>Nouvel article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

La méthode [`full_messages_for`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_messages_for)
renvoie un tableau de messages d'erreur conviviaux pour un attribut spécifié. Si aucun erreur n'est présente pour cet attribut, le tableau sera vide.

Pour comprendre comment tout cela fonctionne ensemble, examinons à nouveau les actions du contrôleur `new` et `create` :

```ruby
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
```

Lorsque nous visitons <http://localhost:3000/articles/new>, la requête `GET /articles/new`
est mappée à l'action `new`. L'action `new` ne tente pas de sauvegarder `@article`. Par conséquent, les validations ne sont pas vérifiées et il n'y aura pas de messages d'erreur.

Lorsque nous soumettons le formulaire, la requête `POST /articles` est mappée à l'action `create`. L'action `create` *tente* de sauvegarder `@article`. Par conséquent, les validations *sont* vérifiées. Si une validation échoue, `@article` ne sera pas sauvegardé et `app/views/articles/new.html.erb` sera rendu avec les messages d'erreur.

CONSEIL : Pour en savoir plus sur les validations, consultez [Active Record Validations](
active_record_validations.html). Pour en savoir plus sur les messages d'erreur de validation, consultez [Active Record Validations § Travailler avec les erreurs de validation](
active_record_validations.html#working-with-validation-errors).

#### Conclusion

Nous pouvons maintenant créer un article en visitant <http://localhost:3000/articles/new>.
Pour terminer, ajoutons un lien vers cette page en bas de `app/views/articles/index.html.erb` :

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "Nouvel article", new_article_path %>
```

### Mise à jour d'un article

Nous avons couvert le "CR" de CRUD. Passons maintenant au "U" (Mise à jour). La mise à jour d'une ressource est très similaire à la création d'une ressource. Ce sont toutes deux des processus en plusieurs étapes. Tout d'abord, l'utilisateur demande un formulaire pour modifier les données. Ensuite, l'utilisateur soumet le formulaire. S'il n'y a pas d'erreurs, la ressource est mise à jour. Sinon, le formulaire est réaffiché avec des messages d'erreur et le processus est répété.

Ces étapes sont conventionnellement gérées par les actions `edit` et `update` d'un contrôleur. Ajoutons une implémentation typique de ces actions à `app/controllers/articles_controller.rb`, en dessous de l'action `create` :

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

Remarquez comment les actions `edit` et `update` ressemblent aux actions `new` et `create`.

L'action `edit` récupère l'article depuis la base de données et le stocke dans `@article` afin de pouvoir l'utiliser lors de la construction du formulaire. Par défaut, l'action `edit` rendra `app/views/articles/edit.html.erb`.

L'action `update` récupère (de nouveau) l'article depuis la base de données et tente de le mettre à jour avec les données du formulaire soumis filtrées par `article_params`. Si aucune validation ne échoue et que la mise à jour réussit, l'action redirige le navigateur vers la page de l'article. Sinon, l'action réaffiche le formulaire - avec des messages d'erreur - en rendant `app/views/articles/edit.html.erb`.

#### Utilisation de partials pour partager du code de vue

Notre formulaire `edit` ressemblera au formulaire `new`. Même le code sera le même, grâce au constructeur de formulaire Rails et au routage resourceful. Le constructeur de formulaire configure automatiquement le formulaire pour effectuer le type de requête approprié, en fonction de la sauvegarde préalable ou non de l'objet modèle.

Comme le code sera le même, nous allons le factoriser dans une vue partagée appelée *partial*. Créons `app/views/articles/_form.html.erb` avec le contenu suivant :

```html+erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```
Le code ci-dessus est identique à notre formulaire dans `app/views/articles/new.html.erb`,
à l'exception de toutes les occurrences de `@article` qui ont été remplacées par `article`.
Étant donné que les partiels sont du code partagé, il est préférable qu'ils ne dépendent pas
de variables d'instance spécifiques définies par une action du contrôleur. Au lieu de cela, nous passerons
l'article au partiel en tant que variable locale.

Mettons à jour `app/views/articles/new.html.erb` pour utiliser le partiel via [`render`](
https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render):

```html+erb
<h1>Nouvel article</h1>

<%= render "form", article: @article %>
```

NOTE : Le nom de fichier d'un partiel doit être précédé **d'un** tiret bas, par exemple
`_form.html.erb`. Mais lors du rendu, il est référencé **sans** le
tiret bas, par exemple `render "form"`.

Et maintenant, créons un fichier `app/views/articles/edit.html.erb` très similaire :

```html+erb
<h1>Modifier l'article</h1>

<%= render "form", article: @article %>
```

ASTUCE : Pour en savoir plus sur les partiels, consultez [Layouts and Rendering in Rails § Using
Partials](layouts_and_rendering.html#using-partials).

#### Finir

Nous pouvons maintenant mettre à jour un article en visitant sa page de modification, par exemple
<http://localhost:3000/articles/1/edit>. Pour finir, ajoutons un lien vers la page de modification en bas de `app/views/articles/show.html.erb` :

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Modifier", edit_article_path(@article) %></li>
</ul>
```

### Supprimer un article

Enfin, nous arrivons à la partie "D" (Delete) de CRUD. Supprimer une ressource est un processus plus simple
que la création ou la mise à jour. Cela ne nécessite qu'une route et une action de contrôleur.
Et notre routage ressource (`resources :articles`) fournit déjà la
route, qui mappe les requêtes `DELETE /articles/:id` à l'action `destroy` de
`ArticlesController`.

Alors, ajoutons une action `destroy` typique à `app/controllers/articles_controller.rb`,
sous l'action `update` :

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

L'action `destroy` récupère l'article depuis la base de données et appelle [`destroy`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy)
dessus. Ensuite, elle redirige le navigateur vers le chemin racine avec le code d'état
[303 See Other](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/303).

Nous avons choisi de rediriger vers le chemin racine car c'est notre principal point d'accès
pour les articles. Mais dans d'autres circonstances, vous pourriez choisir de rediriger vers
par exemple `articles_path`.

Maintenant, ajoutons un lien en bas de `app/views/articles/show.html.erb` pour pouvoir
supprimer un article depuis sa propre page :

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Modifier", edit_article_path(@article) %></li>
  <li><%= link_to "Supprimer", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Êtes-vous sûr ?"
                  } %></li>
</ul>
```

Dans le code ci-dessus, nous utilisons l'option `data` pour définir les attributs HTML `data-turbo-method` et
`data-turbo-confirm` du lien "Supprimer". Les deux
attributs sont liés à [Turbo](https://turbo.hotwired.dev/), qui est inclus par
défaut dans les nouvelles applications Rails. `data-turbo-method="delete"` fera en sorte que
le lien fasse une requête `DELETE` au lieu d'une requête `GET`.
`data-turbo-confirm="Êtes-vous sûr ?"` fera apparaître une boîte de dialogue de confirmation
lorsque le lien est cliqué. Si l'utilisateur annule la boîte de dialogue, la requête sera
annulée.

Et voilà ! Nous pouvons maintenant lister, afficher, créer, mettre à jour et supprimer des articles !
InCRUDable !

Ajout d'un deuxième modèle
--------------------------

Il est temps d'ajouter un deuxième modèle à l'application. Le deuxième modèle gérera
les commentaires sur les articles.

### Génération d'un modèle

Nous allons utiliser le même générateur que celui que nous avons utilisé précédemment pour créer
le modèle `Article`. Cette fois-ci, nous allons créer un modèle `Comment` pour contenir une
référence à un article. Exécutez cette commande dans votre terminal :

```bash
$ bin/rails generate model Comment commenter:string body:text article:references
```

Cette commande générera quatre fichiers :

| Fichier                                      | Objectif                                                                                               |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| db/migrate/20140120201010_create_comments.rb | Migration pour créer la table des commentaires dans votre base de données (votre nom inclura un horodatage différent) |
| app/models/comment.rb                        | Le modèle Comment                                                                                      |
| test/models/comment_test.rb                  | Harnais de test pour le modèle Comment                                                                 |
| test/fixtures/comments.yml                   | Commentaires d'exemple pour une utilisation dans les tests                                              |

Tout d'abord, jetez un coup d'œil à `app/models/comment.rb` :

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

C'est très similaire au modèle `Article` que vous avez vu précédemment. La différence
est la ligne `belongs_to :article`, qui configure une _association_ Active Record.
Vous en apprendrez un peu plus sur les associations dans la prochaine section de ce guide.
Le mot-clé (`:references`) utilisé dans la commande shell est un type de données spécial pour les modèles.
Il crée une nouvelle colonne dans votre table de base de données avec le nom du modèle fourni suivi de `_id`
qui peut contenir des valeurs entières. Pour mieux comprendre, analysez le fichier `db/schema.rb` après avoir exécuté la migration.

En plus du modèle, Rails a également créé une migration pour créer la
table de base de données correspondante :

```ruby
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

La ligne `t.references` crée une colonne entière appelée `article_id`, un index
pour celle-ci, et une contrainte de clé étrangère qui pointe vers la colonne `id` de la table `articles`.
Allez-y et exécutez la migration :

```bash
$ bin/rails db:migrate
```

Rails est suffisamment intelligent pour n'exécuter que les migrations qui n'ont pas déjà été
exécutées sur la base de données actuelle, donc dans ce cas, vous verrez simplement :

```
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```

### Association de modèles

Les associations Active Record vous permettent de déclarer facilement la relation entre deux
modèles. Dans le cas des commentaires et des articles, vous pourriez écrire les
relations de cette manière :

* Chaque commentaire appartient à un article.
* Un article peut avoir plusieurs commentaires.

En fait, c'est très proche de la syntaxe que Rails utilise pour déclarer cette
association. Vous avez déjà vu la ligne de code à l'intérieur du modèle `Comment`
(app/models/comment.rb) qui fait en sorte que chaque commentaire appartienne à un Article :

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

Vous devrez modifier `app/models/article.rb` pour ajouter l'autre côté de la
association :

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Ces deux déclarations permettent un bon nombre de comportements automatiques. Par exemple, si
vous avez une variable d'instance `@article` contenant un article, vous pouvez récupérer
tous les commentaires appartenant à cet article sous forme de tableau en utilisant
`@article.comments`.

CONSEIL : Pour plus d'informations sur les associations Active Record, consultez le guide [Associations Active Record](association_basics.html).

### Ajout d'une route pour les commentaires

Comme pour le contrôleur `articles`, nous devrons ajouter une route pour que Rails
sache où nous voulons naviguer pour voir les `comments`. Ouvrez à nouveau le fichier
`config/routes.rb` et modifiez-le comme suit :

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

Cela crée `comments` en tant que _resource imbriquée_ dans `articles`. C'est
une autre partie de la capture de la relation hiérarchique qui existe entre
les articles et les commentaires.

CONSEIL : Pour plus d'informations sur le routage, consultez le guide [Routage Rails](routing.html).

### Génération d'un contrôleur

Avec le modèle en main, vous pouvez vous concentrer sur la création d'un contrôleur correspondant.
Encore une fois, nous utiliserons le même générateur que précédemment :

```bash
$ bin/rails generate controller Comments
```

Cela crée trois fichiers et un répertoire vide :

| Fichier/Répertoire                          | Objectif                                 |
| -------------------------------------------- | ---------------------------------------- |
| app/controllers/comments_controller.rb       | Le contrôleur Comments                    |
| app/views/comments/                          | Les vues du contrôleur sont stockées ici  |
| test/controllers/comments_controller_test.rb | Le test pour le contrôleur                |
| app/helpers/comments_helper.rb               | Un fichier d'aide à la vue                |

Comme pour n'importe quel blog, nos lecteurs créeront leurs commentaires directement après
avoir lu l'article, et une fois qu'ils auront ajouté leur commentaire, ils seront renvoyés
à la page de visualisation de l'article pour voir leur commentaire maintenant répertorié. En raison de cela, notre
`CommentsController` est là pour fournir une méthode pour créer des commentaires et supprimer
les commentaires indésirables lorsqu'ils arrivent.

Donc d'abord, nous allons connecter le modèle d'affichage de l'article
(`app/views/articles/show.html.erb`) pour nous permettre de créer un nouveau commentaire :

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Cela ajoute un formulaire sur la page de visualisation de l'article qui crée un nouveau commentaire en
appelant l'action `create` du `CommentsController`. L'appel `form_with` utilise ici
un tableau, qui construira une route imbriquée, telle que `/articles/1/comments`.
Connectons le `create` dans `app/controllers/comments_controller.rb` :

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

Vous verrez un peu plus de complexité ici que dans le contrôleur pour les articles. C'est un effet secondaire de l'imbrication que vous avez mise en place. Chaque demande de commentaire doit suivre l'article auquel le commentaire est attaché, d'où l'appel initial à la méthode `find` du modèle `Article` pour obtenir l'article en question.

De plus, le code profite de certaines des méthodes disponibles pour une association. Nous utilisons la méthode `create` sur `@article.comments` pour créer et enregistrer le commentaire. Cela liera automatiquement le commentaire de sorte qu'il appartienne à cet article particulier.

Une fois que nous avons créé le nouveau commentaire, nous renvoyons l'utilisateur à l'article d'origine en utilisant l'aide `article_path(@article)`. Comme nous l'avons déjà vu, cela appelle l'action `show` du `ArticlesController` qui rend ensuite le modèle `show.html.erb`. C'est là que nous voulons que le commentaire s'affiche, donc ajoutons cela à `app/views/articles/show.html.erb`.

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Modifier", edit_article_path(@article) %></li>
  <li><%= link_to "Supprimer", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Êtes-vous sûr ?"
                  } %></li>
</ul>

<h2>Commentaires</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>Commentateur :</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Commentaire :</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>Ajouter un commentaire :</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Maintenant, vous pouvez ajouter des articles et des commentaires à votre blog et les voir apparaître aux bons endroits.

![Article avec commentaires](images/getting_started/article_with_comments.png)

Refactoring
-----------

Maintenant que nous avons des articles et des commentaires fonctionnels, examinons le modèle `app/views/articles/show.html.erb`. Il devient long et maladroit. Nous pouvons utiliser des partiels pour le nettoyer.

### Rendre des collections partielles

Tout d'abord, nous allons créer un partiel pour les commentaires afin d'extraire l'affichage de tous les commentaires pour l'article. Créez le fichier `app/views/comments/_comment.html.erb` et ajoutez-y le contenu suivant :

```html+erb
<p>
  <strong>Commentateur :</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Commentaire :</strong>
  <%= comment.body %>
</p>
```

Ensuite, vous pouvez modifier `app/views/articles/show.html.erb` pour qu'il ressemble à ceci :

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Modifier", edit_article_path(@article) %></li>
  <li><%= link_to "Supprimer", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Êtes-vous sûr ?"
                  } %></li>
</ul>

<h2>Commentaires</h2>
<%= render @article.comments %>

<h2>Ajouter un commentaire :</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Cela va maintenant afficher le partiel `app/views/comments/_comment.html.erb` une fois pour chaque commentaire présent dans la collection `@article.comments`. Lorsque la méthode `render` itère sur la collection `@article.comments`, elle assigne chaque commentaire à une variable locale portant le même nom que le partiel, dans ce cas `comment`, qui est ensuite disponible dans le partiel pour l'affichage.

### Rendre un formulaire partiel

Nous allons également déplacer cette section de nouveau commentaire dans son propre partiel. Encore une fois, vous créez un fichier `app/views/comments/_form.html.erb` contenant :

```html+erb
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Ensuite, vous modifiez `app/views/articles/show.html.erb` pour qu'il ressemble à ceci :

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Modifier", edit_article_path(@article) %></li>
  <li><%= link_to "Supprimer", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Êtes-vous sûr ?"
                  } %></li>
</ul>

<h2>Commentaires</h2>
<%= render @article.comments %>

<h2>Ajouter un commentaire :</h2>
<%= render 'comments/form' %>
```

Le deuxième rendu définit simplement le modèle partiel que nous voulons afficher, `comments/form`. Rails est suffisamment intelligent pour repérer le slash dans cette chaîne et comprendre que vous voulez rendre le fichier `_form.html.erb` dans le répertoire `app/views/comments`.

L'objet `@article` est disponible pour tous les partiels rendus dans la vue car nous l'avons défini en tant que variable d'instance.

### Utilisation des Concerns

Les Concerns sont une façon de rendre les contrôleurs ou les modèles volumineux plus faciles à comprendre et à gérer. Cela présente également l'avantage de la réutilisabilité lorsque plusieurs modèles (ou contrôleurs) partagent les mêmes préoccupations. Les Concerns sont implémentés à l'aide de modules qui contiennent des méthodes représentant une fonctionnalité bien définie dont un modèle ou un contrôleur est responsable. Dans d'autres langages, les modules sont souvent appelés mixins.
Vous pouvez utiliser des "concerns" dans votre contrôleur ou modèle de la même manière que vous utiliseriez n'importe quel module. Lorsque vous avez créé votre application avec `rails new blog`, deux dossiers ont été créés dans `app/` avec le reste :

```
app/controllers/concerns
app/models/concerns
```

Dans l'exemple ci-dessous, nous implémenterons une nouvelle fonctionnalité pour notre blog qui bénéficierait de l'utilisation d'un "concern". Ensuite, nous créerons un "concern" et refactoriserons le code pour l'utiliser, rendant ainsi le code plus DRY et maintenable.

Un article de blog peut avoir différents statuts - par exemple, il peut être visible par tout le monde (c'est-à-dire "public"), ou seulement visible par l'auteur (c'est-à-dire "private"). Il peut également être caché pour tous mais toujours récupérable (c'est-à-dire "archived"). Les commentaires peuvent également être cachés ou visibles. Cela pourrait être représenté en utilisant une colonne "status" dans chaque modèle.

Tout d'abord, exécutons les migrations suivantes pour ajouter "status" aux "Articles" et "Comments" :

```bash
$ bin/rails generate migration AddStatusToArticles status:string
$ bin/rails generate migration AddStatusToComments status:string
```

Et ensuite, mettons à jour la base de données avec les migrations générées :

```bash
$ bin/rails db:migrate
```

Pour choisir le statut des articles et des commentaires existants, vous pouvez ajouter une valeur par défaut aux fichiers de migration générés en ajoutant l'option `default: "public"` et lancer à nouveau les migrations. Vous pouvez également appeler dans une console Rails `Article.update_all(status: "public")` et `Comment.update_all(status: "public")`.


CONSEIL : Pour en savoir plus sur les migrations, consultez [Active Record Migrations](active_record_migrations.html).

Nous devons également autoriser la clé `:status` en tant que partie du paramètre fort, dans `app/controllers/articles_controller.rb` :

```ruby

  private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
```

et dans `app/controllers/comments_controller.rb` :

```ruby

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

Dans le modèle `article`, après avoir exécuté une migration pour ajouter une colonne `status` en utilisant la commande `bin/rails db:migrate`, vous ajouteriez :

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

et dans le modèle `Comment` :

```ruby
class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

Ensuite, dans notre template d'action `index` (`app/views/articles/index.html.erb`), nous utiliserions la méthode `archived?` pour éviter d'afficher tout article archivé :

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

De même, dans notre vue partielle de commentaire (`app/views/comments/_comment.html.erb`), nous utiliserions la méthode `archived?` pour éviter d'afficher tout commentaire archivé :

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Commenter :</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Commentaire :</strong>
    <%= comment.body %>
  </p>
<% end %>
```

Cependant, si vous regardez à nouveau nos modèles maintenant, vous pouvez voir que la logique est dupliquée. Si à l'avenir nous augmentons les fonctionnalités de notre blog - pour inclure par exemple des messages privés - nous pourrions nous retrouver à nouveau à dupliquer la logique. C'est là que les "concerns" sont utiles.

Un "concern" est responsable uniquement d'un sous-ensemble ciblé de la responsabilité du modèle ; les méthodes dans notre "concern" seront toutes liées à la visibilité d'un modèle. Appelons notre nouveau "concern" (module) `Visible`. Nous pouvons créer un nouveau fichier à l'intérieur de `app/models/concerns` appelé `visible.rb` et y stocker toutes les méthodes de statut qui ont été dupliquées dans les modèles.

`app/models/concerns/visible.rb`

```ruby
module Visible
  def archived?
    status == 'archived'
  end
end
```

Nous pouvons ajouter notre validation de statut au "concern", mais cela est légèrement plus complexe car les validations sont des méthodes appelées au niveau de la classe. Le `ActiveSupport::Concern` ([Guide de l'API](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)) nous donne une manière plus simple de les inclure :

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  def archived?
    status == 'archived'
  end
end
```

Maintenant, nous pouvons supprimer la logique dupliquée de chaque modèle et inclure plutôt notre nouveau module `Visible` :

Dans `app/models/article.rb` :

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

et dans `app/models/comment.rb` :

```ruby
class Comment < ApplicationRecord
  include Visible

  belongs_to :article
end
```
Les méthodes de classe peuvent également être ajoutées aux préoccupations. Si nous voulons afficher le nombre d'articles publics ou de commentaires sur notre page principale, nous pouvons ajouter une méthode de classe à Visible comme suit:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      where(status: 'public').count
    end
  end

  def archived?
    status == 'archived'
  end
end
```

Ensuite, dans la vue, vous pouvez l'appeler comme n'importe quelle méthode de classe:

```html+erb
<h1>Articles</h1>

Notre blog compte <%= Article.public_count %> articles et en augmentation !

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "Nouvel article", new_article_path %>
```

Pour finir, nous allons ajouter une boîte de sélection aux formulaires et permettre à l'utilisateur de sélectionner le statut lorsqu'il crée un nouvel article ou publie un nouveau commentaire. Nous pouvons également spécifier le statut par défaut comme étant "public". Dans `app/views/articles/_form.html.erb`, nous pouvons ajouter:

```html+erb
<div>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</div>
```

et dans `app/views/comments/_form.html.erb`:

```html+erb
<p>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</p>
```

Suppression des commentaires
-----------------

Une autre fonctionnalité importante d'un blog est la possibilité de supprimer les commentaires indésirables. Pour cela, nous devons implémenter un lien quelconque dans la vue et une action "destroy" dans le contrôleur "CommentsController".

Tout d'abord, ajoutons le lien de suppression dans la partial `app/views/comments/_comment.html.erb`:

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Commentateur :</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Commentaire :</strong>
    <%= comment.body %>
  </p>

  <p>
    <%= link_to "Supprimer le commentaire", [comment.article, comment], data: {
                  turbo_method: :delete,
                  turbo_confirm: "Êtes-vous sûr ?"
                } %>
  </p>
<% end %>
```

En cliquant sur ce nouveau lien "Supprimer le commentaire", une requête `DELETE /articles/:article_id/comments/:id` sera envoyée à notre contrôleur "CommentsController", qui pourra ensuite utiliser cette information pour trouver le commentaire que nous voulons supprimer. Ajoutons donc une action "destroy" à notre contrôleur (`app/controllers/comments_controller.rb`):

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), status: :see_other
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
end
```

L'action "destroy" trouvera l'article que nous regardons, localisera le commentaire dans la collection `@article.comments`, puis le supprimera de la base de données et nous renverra à l'action "show" de l'article.

### Suppression des objets associés

Si vous supprimez un article, ses commentaires associés doivent également être supprimés, sinon ils occuperaient simplement de l'espace dans la base de données. Rails vous permet d'utiliser l'option "dependent" d'une association pour y parvenir. Modifiez le modèle Article, `app/models/article.rb`, comme suit:

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Sécurité
--------

### Authentification de base

Si vous publiez votre blog en ligne, n'importe qui pourrait ajouter, modifier et supprimer des articles ou supprimer des commentaires.

Rails fournit un système d'authentification HTTP qui fonctionnera bien dans cette situation.

Dans le contrôleur "ArticlesController", nous devons avoir un moyen de bloquer l'accès aux différentes actions si la personne n'est pas authentifiée. Nous pouvons utiliser la méthode Rails `http_basic_authenticate_with`, qui permet l'accès à l'action demandée si cette méthode l'autorise.

Pour utiliser le système d'authentification, nous le spécifions en haut de notre "ArticlesController" dans `app/controllers/articles_controller.rb`. Dans notre cas, nous voulons que l'utilisateur soit authentifié sur chaque action sauf `index` et `show`, nous écrivons donc cela :

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # extrait pour plus de concision
```

Nous voulons également autoriser uniquement les utilisateurs authentifiés à supprimer des commentaires, donc dans le contrôleur "CommentsController" (`app/controllers/comments_controller.rb`) nous écrivons :

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # extrait pour plus de concision
```

Maintenant, si vous essayez de créer un nouvel article, vous serez accueilli par un défi d'authentification HTTP de base :

![Défi d'authentification HTTP de base](images/getting_started/challenge.png)

Après avoir saisi le nom d'utilisateur et le mot de passe corrects, vous resterez authentifié jusqu'à ce qu'un nom d'utilisateur et un mot de passe différents soient requis ou que le navigateur soit fermé.
D'autres méthodes d'authentification sont disponibles pour les applications Rails. Deux add-ons populaires pour l'authentification dans Rails sont le moteur Rails [Devise](https://github.com/plataformatec/devise) et la gemme [Authlogic](https://github.com/binarylogic/authlogic), ainsi que plusieurs autres.

### Autres considérations de sécurité

La sécurité, en particulier dans les applications web, est un domaine vaste et détaillé. La sécurité dans votre application Rails est abordée plus en détail dans le [Guide de sécurité Ruby on Rails](security.html).


Et maintenant ?
------------

Maintenant que vous avez vu votre première application Rails, vous pouvez la mettre à jour et expérimenter par vous-même.

N'oubliez pas que vous n'avez pas à tout faire sans aide. Si vous avez besoin d'aide pour démarrer avec Rails, n'hésitez pas à consulter ces ressources de support :

* Les [Guides Ruby on Rails](index.html)
* La [liste de diffusion Ruby on Rails](https://discuss.rubyonrails.org/c/rubyonrails-talk)


Problèmes de configuration
---------------------

La manière la plus simple de travailler avec Rails est de stocker toutes les données externes en UTF-8. Si ce n'est pas le cas, les bibliothèques Ruby et Rails pourront souvent convertir vos données natives en UTF-8, mais cela ne fonctionne pas toujours de manière fiable, il est donc préférable de s'assurer que toutes les données externes sont en UTF-8.

Si vous avez commis une erreur dans ce domaine, le symptôme le plus courant est l'apparition d'un losange noir avec un point d'interrogation à l'intérieur dans le navigateur. Un autre symptôme courant est l'apparition de caractères comme "Ã¼" au lieu de "ü". Rails prend plusieurs mesures internes pour atténuer les causes courantes de ces problèmes qui peuvent être automatiquement détectées et corrigées. Cependant, si vous avez des données externes qui ne sont pas stockées en UTF-8, cela peut parfois entraîner ce genre de problèmes qui ne peuvent pas être automatiquement détectés et corrigés par Rails.

Deux sources de données très courantes qui ne sont pas en UTF-8 :

* Votre éditeur de texte : La plupart des éditeurs de texte (comme TextMate) sont configurés par défaut pour enregistrer les fichiers en UTF-8. Si votre éditeur de texte ne le fait pas, cela peut entraîner l'apparition de caractères spéciaux que vous saisissez dans vos modèles (comme é) sous la forme d'un losange avec un point d'interrogation à l'intérieur dans le navigateur. Cela s'applique également à vos fichiers de traduction i18n. La plupart des éditeurs qui ne sont pas déjà configurés par défaut en UTF-8 (comme certaines versions de Dreamweaver) offrent un moyen de modifier cette configuration par défaut en UTF-8. Faites-le.
* Votre base de données : Rails convertit par défaut les données de votre base de données en UTF-8 à la frontière. Cependant, si votre base de données n'utilise pas UTF-8 en interne, elle peut ne pas être en mesure de stocker tous les caractères que vos utilisateurs saisissent. Par exemple, si votre base de données utilise Latin-1 en interne et que votre utilisateur saisit un caractère russe, hébreu ou japonais, les données seront perdues à jamais une fois qu'elles entrent dans la base de données. Si possible, utilisez UTF-8 comme stockage interne de votre base de données.
