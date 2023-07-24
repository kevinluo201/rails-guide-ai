**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 7dbd0564d604e07d111b2a827bef559f
La ligne de commande Rails
==========================

Après avoir lu ce guide, vous saurez :

* Comment créer une application Rails.
* Comment générer des modèles, des contrôleurs, des migrations de base de données et des tests unitaires.
* Comment démarrer un serveur de développement.
* Comment expérimenter avec des objets via un shell interactif.

--------------------------------------------------------------------------------

NOTE : Ce tutoriel suppose que vous avez des connaissances de base en Rails en lisant le [Guide de démarrage avec Rails](getting_started.html).

Créer une application Rails
---------------------------

Tout d'abord, créons une application Rails simple en utilisant la commande `rails new`.

Nous utiliserons cette application pour jouer et découvrir toutes les commandes décrites dans ce guide.

INFO : Vous pouvez installer le gem Rails en tapant `gem install rails`, si vous ne l'avez pas déjà.

### `rails new`

Le premier argument que nous passerons à la commande `rails new` est le nom de l'application.

```bash
$ rails new my_app
     create
     create  README.md
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

Rails met en place ce qui semble être une énorme quantité de choses pour une si petite commande ! Nous avons maintenant toute la structure de répertoire Rails avec tout le code dont nous avons besoin pour exécuter notre application simple dès le départ.

Si vous souhaitez ignorer certains fichiers générés ou ignorer certaines bibliothèques, vous pouvez ajouter l'un des arguments suivants à votre commande `rails new` :

| Argument                | Description                                                 |
| ----------------------- | ----------------------------------------------------------- |
| `--skip-git`            | Ignorer git init, .gitignore et .gitattributes              |
| `--skip-docker`         | Ignorer Dockerfile, .dockerignore et bin/docker-entrypoint   |
| `--skip-keeps`          | Ignorer les fichiers .keep de contrôle de source            |
| `--skip-action-mailer`  | Ignorer les fichiers Action Mailer                          |
| `--skip-action-mailbox` | Ignorer la gem Action Mailbox                               |
| `--skip-action-text`    | Ignorer la gem Action Text                                  |
| `--skip-active-record`  | Ignorer les fichiers Active Record                          |
| `--skip-active-job`     | Ignorer Active Job                                          |
| `--skip-active-storage` | Ignorer les fichiers Active Storage                         |
| `--skip-action-cable`   | Ignorer les fichiers Action Cable                           |
| `--skip-asset-pipeline` | Ignorer l'Asset Pipeline                                    |
| `--skip-javascript`     | Ignorer les fichiers JavaScript                             |
| `--skip-hotwire`        | Ignorer l'intégration Hotwire                               |
| `--skip-jbuilder`       | Ignorer la gem jbuilder                                     |
| `--skip-test`           | Ignorer les fichiers de test                                |
| `--skip-system-test`    | Ignorer les fichiers de test système                        |
| `--skip-bootsnap`       | Ignorer la gem bootsnap                                     |

Ce ne sont que quelques-unes des options acceptées par `rails new`. Pour une liste complète des options, tapez `rails new --help`.

### Préconfigurer une base de données différente

Lors de la création d'une nouvelle application Rails, vous avez la possibilité de spécifier le type de base de données que votre application va utiliser. Cela vous fera gagner quelques minutes et certainement beaucoup de frappes.

Voyons ce que l'option `--database=postgresql` fera pour nous :

```bash
$ rails new petstore --database=postgresql
      create
      create  app/controllers
      create  app/helpers
...
```

Voyons ce qu'il a mis dans notre `config/database.yml` :

```yaml
# PostgreSQL. Versions 9.3 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On macOS with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On Windows:
#   gem install pg
#       Choose the win32 build.
#       Install PostgreSQL and put its /bin directory on your path.
#
# Configure Using Gemfile
# gem "pg"
#
default: &default
  adapter: postgresql
  encoding: unicode

  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: petstore_development
...
```

Il a généré une configuration de base de données correspondant à notre choix de PostgreSQL.

Principes de base de la ligne de commande
----------------------------------------

Il existe quelques commandes absolument essentielles pour une utilisation quotidienne de Rails. Dans l'ordre d'utilisation probable, ce sont :

* `bin/rails console`
* `bin/rails server`
* `bin/rails test`
* `bin/rails generate`
* `bin/rails db:migrate`
* `bin/rails db:create`
* `bin/rails routes`
* `bin/rails dbconsole`
* `rails new app_name`

Vous pouvez obtenir une liste des commandes Rails disponibles, qui dépendront souvent de votre répertoire actuel, en tapant `rails --help`. Chaque commande a une description et devrait vous aider à trouver ce dont vous avez besoin.

```bash
$ rails --help
Usage:
  bin/rails COMMAND [options]

You must specify a command. The most common commands are:

  generate     Generate new code (short-cut alias: "g")
  console      Start the Rails console (short-cut alias: "c")
  server       Start the Rails server (short-cut alias: "s")
  ...

All commands can be run with -h (or --help) for more information.

In addition to those commands, there are:
about                               List versions of all Rails ...
assets:clean[keep]                  Remove old compiled assets
assets:clobber                      Remove compiled assets
assets:environment                  Load asset compile environment
assets:precompile                   Compile all the assets ...
...
db:fixtures:load                    Load fixtures into the ...
db:migrate                          Migrate the database ...
db:migrate:status                   Display status of migrations
db:rollback                         Roll the schema back to ...
db:schema:cache:clear               Clears a db/schema_cache.yml file
db:schema:cache:dump                Create a db/schema_cache.yml file
db:schema:dump                      Create a database schema file (either db/schema.rb or db/structure.sql ...
db:schema:load                      Load a database schema file (either db/schema.rb or db/structure.sql ...
db:seed                             Load the seed data ...
db:version                          Retrieve the current schema ...
...
restart                             Restart app by touching ...
tmp:create                          Create tmp directories ...
```
### `bin/rails server`

La commande `bin/rails server` lance un serveur web nommé Puma qui est inclus avec Rails. Vous l'utiliserez chaque fois que vous voudrez accéder à votre application via un navigateur web.

Sans autre travail, `bin/rails server` exécutera notre nouvelle application Rails :

```bash
$ cd my_app
$ bin/rails server
=> Démarrage de Puma
=> Démarrage de l'application Rails 7.0.0 en mode développement
=> Exécutez `bin/rails server --help` pour plus d'options de démarrage
Puma démarre en mode unique...
* Version 3.12.1 (ruby 2.5.7-p206), nom de code : Llamas in Pajamas
* Threads minimaux : 5, threads maximaux : 5
* Environnement : développement
* Écoute sur tcp://localhost:3000
Utilisez Ctrl-C pour arrêter
```

Avec seulement trois commandes, nous avons créé un serveur Rails écoutant sur le port 3000. Allez dans votre navigateur et ouvrez [http://localhost:3000](http://localhost:3000), vous verrez une application Rails de base en cours d'exécution.

INFO : Vous pouvez également utiliser l'alias "s" pour démarrer le serveur : `bin/rails s`.

Le serveur peut être exécuté sur un port différent en utilisant l'option `-p`. L'environnement de développement par défaut peut être modifié en utilisant l'option `-e`.

```bash
$ bin/rails server -e production -p 4000
```

L'option `-b` lie Rails à l'adresse IP spécifiée, par défaut c'est localhost. Vous pouvez exécuter un serveur en tant que démon en passant l'option `-d`.

### `bin/rails generate`

La commande `bin/rails generate` utilise des modèles pour créer de nombreuses choses. En exécutant `bin/rails generate` seul, vous obtenez une liste des générateurs disponibles :

INFO : Vous pouvez également utiliser l'alias "g" pour invoquer la commande de génération : `bin/rails g`.

```bash
$ bin/rails generate
Utilisation :
  bin/rails generate GENERATOR [args] [options]

...
...

Veuillez choisir un générateur ci-dessous.

Rails :
  assets
  channel
  controller
  generator
  ...
  ...
```

NOTE : Vous pouvez installer d'autres générateurs via des gemmes de générateur, des parties de plugins que vous installerez sans aucun doute, et vous pouvez même créer les vôtres !

L'utilisation de générateurs vous fera gagner beaucoup de temps en écrivant du **code de base**, du code nécessaire au bon fonctionnement de l'application.

Créons notre propre contrôleur avec le générateur de contrôleurs. Mais quelle commande devons-nous utiliser ? Demandons au générateur :

INFO : Toutes les utilitaires de la console Rails ont un texte d'aide. Comme la plupart des utilitaires *nix, vous pouvez essayer d'ajouter `--help` ou `-h` à la fin, par exemple `bin/rails server --help`.

```bash
$ bin/rails generate controller
Utilisation :
  bin/rails generate controller NAME [action action] [options]

...
...

Description :
    ...

    Pour créer un contrôleur dans un module, spécifiez le nom du contrôleur comme un chemin tel que 'parent_module/nom_du_contrôleur'.

    ...

Exemple :
    `bin/rails generate controller CreditCards open debit credit close`

    Contrôleur de carte de crédit avec des URL comme /credit_cards/debit.
        Contrôleur : app/controllers/credit_cards_controller.rb
        Test :       test/controllers/credit_cards_controller_test.rb
        Vues :       app/views/credit_cards/debit.html.erb [...]
        Aide :       app/helpers/credit_cards_helper.rb
```

Le générateur de contrôleurs attend des paramètres sous la forme `generate controller NomDuContrôleur action1 action2`. Créons un contrôleur `Greetings` avec une action **hello**, qui nous dira quelque chose de gentil.

```bash
$ bin/rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get 'greetings/hello'
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke    test_unit
```

Qu'a généré tout cela ? Cela a veillé à ce qu'un tas de répertoires soient présents dans notre application, et a créé un fichier de contrôleur, un fichier de vue, un fichier de test fonctionnel, un assistant pour la vue, un fichier JavaScript et un fichier de feuille de style.

Consultez le contrôleur et modifiez-le un peu (dans `app/controllers/greetings_controller.rb`) :

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Bonjour, comment ça va aujourd'hui ?"
  end
end
```

Ensuite, la vue, pour afficher notre message (dans `app/views/greetings/hello.html.erb`) :

```erb
<h1>Un salut pour vous !</h1>
<p><%= @message %></p>
```

Lancez votre serveur en utilisant `bin/rails server`.

```bash
$ bin/rails server
=> Démarrage de Puma...
```

L'URL sera [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello).

INFO : Avec une application Rails normale, vos URL suivront généralement le modèle http://(hôte)/(contrôleur)/(action), et une URL comme http://(hôte)/(contrôleur) exécutera l'action **index** de ce contrôleur.

Rails est livré avec un générateur pour les modèles de données également.

```bash
$ bin/rails generate model
Utilisation :
  bin/rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

...

Options ActiveRecord :
      [--migration], [--no-migration]        # Indique quand générer une migration
                                             # Par défaut : true

...

Description :
    Génère un nouveau modèle. Passez le nom du modèle, en CamelCase ou en underscore, et une liste facultative de paires d'attributs en tant qu'arguments.

...
```

NOTE : Pour obtenir une liste des types de champ disponibles pour le paramètre `type`, consultez la [documentation de l'API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column) pour la méthode `add_column` du module `SchemaStatements`. Le paramètre `index` génère un index correspondant pour la colonne.
Mais au lieu de générer directement un modèle (ce que nous ferons plus tard), configurons une échafaudage. Un **échafaudage** dans Rails est un ensemble complet de modèle, de migration de base de données pour ce modèle, de contrôleur pour le manipuler, de vues pour afficher et manipuler les données, et d'un ensemble de tests pour chacun des éléments précédents.

Nous allons configurer une ressource simple appelée "HighScore" qui suivra notre meilleur score sur les jeux vidéo auxquels nous jouons.

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20190416145729_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    create      test/system/high_scores_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke      test_unit
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    create      app/views/high_scores/_high_score.json.jbuilder
```

Le générateur crée le modèle, les vues, le contrôleur, la route **resource** et la migration de base de données (qui crée la table `high_scores`) pour HighScore. Et il ajoute des tests pour ceux-ci.

La migration nécessite que nous **migrions**, c'est-à-dire que nous exécutions du code Ruby (le fichier `20190416145729_create_high_scores.rb` à partir de la sortie ci-dessus) pour modifier le schéma de notre base de données. Quelle base de données ? La base de données SQLite3 que Rails créera pour nous lorsque nous exécuterons la commande `bin/rails db:migrate`. Nous en parlerons plus en détail ci-dessous.

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: Parlons des tests unitaires. Les tests unitaires sont du code qui teste et fait des assertions sur du code. En test unitaire, nous prenons une petite partie de code, disons une méthode d'un modèle, et testons ses entrées et sorties. Les tests unitaires sont vos amis. Plus tôt vous acceptez le fait que votre qualité de vie augmentera considérablement lorsque vous testerez unitairement votre code, mieux ce sera. Sérieusement. Veuillez consulter [le guide de test](testing.html) pour un aperçu détaillé des tests unitaires.

Voyons l'interface que Rails a créée pour nous.

```bash
$ bin/rails server
```

Allez dans votre navigateur et ouvrez [http://localhost:3000/high_scores](http://localhost:3000/high_scores), maintenant nous pouvons créer de nouveaux meilleurs scores (55,160 sur Space Invaders !)

### `bin/rails console`

La commande `console` vous permet d'interagir avec votre application Rails depuis la ligne de commande. En dessous, `bin/rails console` utilise IRB, donc si vous l'avez déjà utilisé, vous serez à l'aise. Cela est utile pour tester rapidement des idées avec du code et modifier les données côté serveur sans toucher au site web.

INFO: Vous pouvez également utiliser l'alias "c" pour invoquer la console : `bin/rails c`.

Vous pouvez spécifier l'environnement dans lequel la commande `console` doit fonctionner.

```bash
$ bin/rails console -e staging
```

Si vous souhaitez tester du code sans modifier de données, vous pouvez le faire en invoquant `bin/rails console --sandbox`.

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 7.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### Les objets `app` et `helper`

Dans la `bin/rails console`, vous avez accès aux instances `app` et `helper`.

Avec la méthode `app`, vous pouvez accéder aux assistants de routage nommés, ainsi qu'effectuer des requêtes.

```irb
irb> app.root_path
=> "/"

irb> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

Avec la méthode `helper`, il est possible d'accéder aux assistants de Rails et de votre application.

```irb
irb> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

irb> helper.my_custom_helper
=> "my custom helper"
```

### `bin/rails dbconsole`

`bin/rails dbconsole` détermine quelle base de données vous utilisez et vous place dans l'interface en ligne de commande que vous utiliseriez avec celle-ci (et détermine également les paramètres de ligne de commande à lui donner !). Il prend en charge MySQL (y compris MariaDB), PostgreSQL et SQLite3.

INFO: Vous pouvez également utiliser l'alias "db" pour invoquer la dbconsole : `bin/rails db`.

Si vous utilisez plusieurs bases de données, `bin/rails dbconsole` se connectera à la base de données principale par défaut. Vous pouvez spécifier à quelle base de données vous connecter en utilisant `--database` ou `--db` :

```bash
$ bin/rails dbconsole --database=animals
```

### `bin/rails runner`

`runner` exécute du code Ruby dans le contexte de Rails de manière non interactive. Par exemple :

```bash
$ bin/rails runner "Model.long_running_method"
```

INFO: Vous pouvez également utiliser l'alias "r" pour invoquer le runner : `bin/rails r`.

Vous pouvez spécifier l'environnement dans lequel la commande `runner` doit fonctionner en utilisant l'option `-e`.

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```

Vous pouvez même exécuter du code Ruby écrit dans un fichier avec le runner.

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `bin/rails destroy`

Pensez à `destroy` comme l'opposé de `generate`. Il va comprendre ce que `generate` a fait et l'annuler.

INFO: Vous pouvez également utiliser l'alias "d" pour invoquer la commande destroy : `bin/rails d`.

```bash
$ bin/rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```

```bash
$ bin/rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

### `bin/rails about`

`bin/rails about` donne des informations sur les numéros de version de Ruby, RubyGems, Rails, les sous-composants de Rails, le dossier de votre application, le nom de l'environnement Rails actuel, l'adaptateur de base de données de votre application et la version du schéma. C'est utile lorsque vous avez besoin de demander de l'aide, de vérifier si un correctif de sécurité peut vous affecter ou lorsque vous avez besoin de statistiques pour une installation Rails existante.

```bash
$ bin/rails about
About your application's environment
Rails version             7.0.0
Ruby version              2.7.0 (x86_64-linux)
RubyGems version          2.7.3
Rack version              2.0.4
JavaScript Runtime        Node.js (V8)
Middleware:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Application root          /home/foobar/my_app
Environment               development
Database adapter          sqlite3
Database schema version   20180205173523
```

### `bin/rails assets:`

Vous pouvez précompiler les assets dans `app/assets` en utilisant `bin/rails assets:precompile` et supprimer les anciens assets compilés en utilisant `bin/rails assets:clean`. La commande `assets:clean` permet des déploiements progressifs qui peuvent encore être liés à un ancien asset pendant que les nouveaux assets sont en cours de construction.

Si vous souhaitez effacer complètement `public/assets`, vous pouvez utiliser `bin/rails assets:clobber`.

### `bin/rails db:`

Les commandes les plus courantes de l'espace de noms `db:` de Rails sont `migrate` et `create`, et il est intéressant d'essayer toutes les commandes de migration Rails (`up`, `down`, `redo`, `reset`). `bin/rails db:version` est utile lors du dépannage, il vous indique la version actuelle de la base de données.

Plus d'informations sur les migrations peuvent être trouvées dans le guide [Migrations](active_record_migrations.html).

### `bin/rails notes`

`bin/rails notes` recherche dans votre code les commentaires commençant par un mot-clé spécifique. Vous pouvez vous référer à `bin/rails notes --help` pour obtenir des informations sur l'utilisation.

Par défaut, il recherchera dans les répertoires `app`, `config`, `db`, `lib` et `test` les annotations FIXME, OPTIMIZE et TODO dans les fichiers avec les extensions `.builder`, `.rb`, `.rake`, `.yml`, `.yaml`, `.ruby`, `.css`, `.js` et `.erb`.

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

#### Annotations

Vous pouvez passer des annotations spécifiques en utilisant l'argument `--annotations`. Par défaut, il recherchera les annotations FIXME, OPTIMIZE et TODO.
Notez que les annotations sont sensibles à la casse.

```bash
$ bin/rails notes --annotations FIXME RELEASE
app/controllers/admin/users_controller.rb:
  * [101] [RELEASE] We need to look at this before next release
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 17] [FIXME]
```

#### Tags

Vous pouvez ajouter plus de tags par défaut à rechercher en utilisant `config.annotations.register_tags`. Il reçoit une liste de tags.

```ruby
config.annotations.register_tags("DEPRECATEME", "TESTME")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] do A/B testing on this
  * [ 42] [TESTME] this needs more functional tests
  * [132] [DEPRECATEME] ensure this method is deprecated in next release
```

#### Répertoires

Vous pouvez ajouter plus de répertoires par défaut à rechercher en utilisant `config.annotations.register_directories`. Il reçoit une liste de noms de répertoires.

```ruby
config.annotations.register_directories("spec", "vendor")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```

#### Extensions

Vous pouvez ajouter plus d'extensions de fichiers par défaut à rechercher en utilisant `config.annotations.register_extensions`. Il reçoit une liste d'extensions avec sa regex correspondante pour les associer.

```ruby
config.annotations.register_extensions("scss", "sass") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/assets/stylesheets/application.css.sass:
  * [ 34] [TODO] Use pseudo element for this class

app/assets/stylesheets/application.css.scss:
  * [  1] [TODO] Split into multiple components

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```
### `bin/rails routes`

`bin/rails routes` affiche toutes les routes définies, ce qui est utile pour résoudre les problèmes de routage dans votre application ou pour avoir une bonne vue d'ensemble des URL dans une application que vous essayez de comprendre.

### `bin/rails test`

INFO: Une bonne description des tests unitaires dans Rails est donnée dans [Un guide pour tester les applications Rails](testing.html)

Rails est livré avec un framework de test appelé minitest. Rails doit sa stabilité à l'utilisation de tests. Les commandes disponibles dans l'espace de noms `test:` aident à exécuter les différents tests que vous écrirez, espérons-le.

### `bin/rails tmp:`

Le répertoire `Rails.root/tmp` est, comme le répertoire /tmp de *nix, l'endroit où sont stockés les fichiers temporaires tels que les fichiers d'identifiant de processus et les actions mises en cache.

Les commandes avec l'espace de noms `tmp:` vous aideront à effacer et à créer le répertoire `Rails.root/tmp` :

* `bin/rails tmp:cache:clear` efface `tmp/cache`.
* `bin/rails tmp:sockets:clear` efface `tmp/sockets`.
* `bin/rails tmp:screenshots:clear` efface `tmp/screenshots`.
* `bin/rails tmp:clear` efface tous les fichiers de cache, de sockets et de captures d'écran.
* `bin/rails tmp:create` crée les répertoires tmp pour le cache, les sockets et les pids.

### Divers

* `bin/rails initializers` affiche tous les initializers définis dans l'ordre où ils sont invoqués par Rails.
* `bin/rails middleware` liste la pile de middleware Rack activée pour votre application.
* `bin/rails stats` est idéal pour consulter les statistiques sur votre code, affichant des choses comme les KLOCs (milliers de lignes de code) et le ratio de code à tester.
* `bin/rails secret` vous donnera une clé pseudo-aléatoire à utiliser pour votre secret de session.
* `bin/rails time:zones:all` liste tous les fuseaux horaires connus de Rails.

### Tâches Rake personnalisées

Les tâches Rake personnalisées ont une extension `.rake` et sont placées dans `Rails.root/lib/tasks`. Vous pouvez créer ces tâches Rake personnalisées avec la commande `bin/rails generate task`.

```ruby
desc "Je suis une description courte mais complète pour ma super tâche"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # Tout votre code magique ici
  # Tout code Ruby valide est autorisé
end
```

Pour passer des arguments à votre tâche Rake personnalisée :

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

Vous pouvez regrouper les tâches en les plaçant dans des espaces de noms :

```ruby
namespace :db do
  desc "Cette tâche ne fait rien"
  task :nothing do
    # Sérieusement, rien
  end
end
```

L'invocation des tâches ressemblera à ceci :

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # l'ensemble de la chaîne d'arguments doit être entre guillemets
$ bin/rails "task_name[value 1,value2,value3]" # séparez les arguments multiples par une virgule
$ bin/rails db:nothing
```

Si vous avez besoin d'interagir avec les modèles de votre application, d'effectuer des requêtes sur la base de données, etc., votre tâche doit dépendre de la tâche `environment`, qui chargera le code de votre application.

```ruby
task task_that_requires_app_code: [:environment] do
  User.create!
end
```
