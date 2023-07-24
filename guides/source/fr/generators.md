**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0651830a9dc9cbd4e8a1fddab047c719
Création et personnalisation des générateurs et des modèles Rails
===============================================================

Les générateurs Rails sont un outil essentiel pour améliorer votre flux de travail. Avec ce guide, vous apprendrez comment créer des générateurs et personnaliser ceux existants.

Après avoir lu ce guide, vous saurez :

* Comment voir quels générateurs sont disponibles dans votre application.
* Comment créer un générateur en utilisant des modèles.
* Comment Rails recherche les générateurs avant de les invoquer.
* Comment personnaliser votre échafaudage en remplaçant les modèles de générateur.
* Comment personnaliser votre échafaudage en remplaçant les générateurs.
* Comment utiliser des solutions de repli pour éviter de remplacer un ensemble important de générateurs.
* Comment créer un modèle d'application.

--------------------------------------------------------------------------------

Premier contact
---------------

Lorsque vous créez une application en utilisant la commande `rails`, vous utilisez en réalité un générateur Rails. Ensuite, vous pouvez obtenir une liste de tous les générateurs disponibles en invoquant `bin/rails generate` :

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

NOTE : Pour créer une application Rails, nous utilisons la commande globale `rails` qui utilise la version de Rails installée via `gem install rails`. Lorsque vous êtes dans le répertoire de votre application, nous utilisons la commande `bin/rails` qui utilise la version de Rails fournie avec l'application.

Vous obtiendrez une liste de tous les générateurs fournis avec Rails. Pour voir une description détaillée d'un générateur particulier, invoquez le générateur avec l'option `--help`. Par exemple :

```bash
$ bin/rails generate scaffold --help
```

Création de votre premier générateur
-----------------------------------

Les générateurs sont construits sur [Thor](https://github.com/rails/thor), qui offre de puissantes options pour l'analyse et une excellente API pour la manipulation des fichiers.

Créons un générateur qui crée un fichier d'initialisation nommé `initializer.rb` dans `config/initializers`. La première étape consiste à créer un fichier à `lib/generators/initializer_generator.rb` avec le contenu suivant :

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Ajoutez ici le contenu de l'initialisation
    RUBY
  end
end
```

Notre nouveau générateur est assez simple : il hérite de [`Rails::Generators::Base`][] et a une définition de méthode. Lorsqu'un générateur est invoqué, chaque méthode publique du générateur est exécutée séquentiellement dans l'ordre où elle est définie. Notre méthode invoque [`create_file`][], qui créera un fichier à la destination donnée avec le contenu donné.

Pour invoquer notre nouveau générateur, nous exécutons :

```bash
$ bin/rails generate initializer
```

Avant de continuer, voyons la description de notre nouveau générateur :

```bash
$ bin/rails generate initializer --help
```

Rails est généralement capable de dériver une bonne description si un générateur est regroupé, comme `ActiveRecord::Generators::ModelGenerator`, mais pas dans ce cas. Nous pouvons résoudre ce problème de deux manières. La première façon d'ajouter une description est d'appeler [`desc`][] à l'intérieur de notre générateur :

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "Ce générateur crée un fichier d'initialisation dans config/initializers"
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Ajoutez ici le contenu de l'initialisation
    RUBY
  end
end
```

Maintenant, nous pouvons voir la nouvelle description en invoquant `--help` sur le nouveau générateur.

La deuxième façon d'ajouter une description est de créer un fichier nommé `USAGE` dans le même répertoire que notre générateur. Nous allons le faire à l'étape suivante.


Création de générateurs avec des générateurs
-------------------------------------------

Les générateurs eux-mêmes ont un générateur. Supprimons notre `InitializerGenerator` et utilisons `bin/rails generate generator` pour en générer un nouveau :

```bash
$ rm lib/generators/initializer_generator.rb

$ bin/rails generate generator initializer
      create  lib/generators/initializer
      create  lib/generators/initializer/initializer_generator.rb
      create  lib/generators/initializer/USAGE
      create  lib/generators/initializer/templates
      invoke  test_unit
      create    test/lib/generators/initializer_generator_test.rb
```

Voici le générateur qui vient d'être créé :

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
end
```

Tout d'abord, remarquez que le générateur hérite de [`Rails::Generators::NamedBase`][] au lieu de `Rails::Generators::Base`. Cela signifie que notre générateur attend au moins un argument, qui sera le nom de l'initialiseur et sera disponible dans notre code via `name`.

Nous pouvons le voir en vérifiant la description du nouveau générateur :

```bash
$ bin/rails generate initializer --help
Usage:
  bin/rails generate initializer NAME [options]
```

Remarquez également que le générateur a une méthode de classe appelée [`source_root`][]. Cette méthode indique l'emplacement de nos modèles, le cas échéant. Par défaut, elle pointe vers le répertoire `lib/generators/initializer/templates` qui vient d'être créé.

Pour comprendre comment fonctionnent les modèles de générateur, créons le fichier `lib/generators/initializer/templates/initializer.rb` avec le contenu suivant :

```ruby
# Ajoutez ici le contenu de l'initialisation
```

Et modifions le générateur pour copier ce modèle lorsqu'il est invoqué :
```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

Maintenant, exécutons notre générateur :

```bash
$ bin/rails generate initializer core_extensions
      create  config/initializers/core_extensions.rb

$ cat config/initializers/core_extensions.rb
# Ajoutez ici le contenu d'initialisation
```

Nous voyons que [`copy_file`][] a créé `config/initializers/core_extensions.rb`
avec le contenu de notre modèle. (La méthode `file_name` utilisée dans le
chemin de destination est héritée de `Rails::Generators::NamedBase`.)


Options de ligne de commande du générateur
------------------------------------------

Les générateurs peuvent prendre en charge des options de ligne de commande en utilisant [`class_option`][]. Par exemple :

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  class_option :scope, type: :string, default: "app"
end
```

Maintenant, notre générateur peut être invoqué avec l'option `--scope` :

```bash
$ bin/rails generate initializer theme --scope dashboard
```

Les valeurs des options sont accessibles dans les méthodes du générateur via [`options`][] :

```ruby
def copy_initializer_file
  @scope = options["scope"]
end
```


Résolution du générateur
-----------------------

Lors de la résolution du nom d'un générateur, Rails recherche le générateur en utilisant plusieurs noms de fichiers. Par exemple, lorsque vous exécutez `bin/rails generate initializer core_extensions`, Rails essaie de charger chacun des fichiers suivants, dans l'ordre, jusqu'à ce qu'un fichier soit trouvé :

* `rails/generators/initializer/initializer_generator.rb`
* `generators/initializer/initializer_generator.rb`
* `rails/generators/initializer_generator.rb`
* `generators/initializer_generator.rb`

Si aucun de ces fichiers n'est trouvé, une erreur est levée.

Nous avons placé notre générateur dans le répertoire `lib/` de l'application car ce répertoire est dans `$LOAD_PATH`, ce qui permet à Rails de trouver et de charger le fichier.

Remplacement des modèles de générateur de Rails
-----------------------------------------------

Rails recherche également dans plusieurs endroits lors de la résolution des fichiers de modèle de générateur. L'un de ces endroits est le répertoire `lib/templates/` de l'application. Ce comportement nous permet de remplacer les modèles utilisés par les générateurs intégrés de Rails. Par exemple, nous pourrions remplacer le modèle de contrôleur de [scaffold][] ou les modèles de vue de [scaffold][].

Pour voir cela en action, créons un fichier `lib/templates/erb/scaffold/index.html.erb.tt` avec le contenu suivant :

```erb
<%% @<%= plural_table_name %>.count %> <%= human_name.pluralize %>
```

Notez que le modèle est un modèle ERB qui rend un autre modèle ERB. Ainsi, tout `<%` qui doit apparaître dans le modèle _résultant_ doit être échappé en tant que `<%%` dans le modèle _générateur_.

Maintenant, exécutons le générateur de scaffold intégré de Rails :

```bash
$ bin/rails generate scaffold Post title:string
      ...
      create      app/views/posts/index.html.erb
      ...
```

Le contenu de `app/views/posts/index.html.erb` est :

```erb
<% @posts.count %> Posts
```

[scaffold]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt
[scaffold]: https://github.com/rails/rails/tree/main/railties/lib/rails/generators/erb/scaffold/templates

Remplacement des générateurs de Rails
-------------------------------------

Les générateurs intégrés de Rails peuvent être configurés via [`config.generators`][], y compris le remplacement de certains générateurs entièrement.

Tout d'abord, examinons de plus près le fonctionnement du générateur de scaffold.

```bash
$ bin/rails generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20230518000000_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      invoke  resource_route
       route    resources :users
      invoke  scaffold_controller
      create    app/controllers/users_controller.rb
      invoke    erb
      create      app/views/users
      create      app/views/users/index.html.erb
      create      app/views/users/edit.html.erb
      create      app/views/users/show.html.erb
      create      app/views/users/new.html.erb
      create      app/views/users/_form.html.erb
      create      app/views/users/_user.html.erb
      invoke    resource_route
      invoke    test_unit
      create      test/controllers/users_controller_test.rb
      create      test/system/users_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke      test_unit
      invoke    jbuilder
      create      app/views/users/index.json.jbuilder
      create      app/views/users/show.json.jbuilder
```

À partir de la sortie, nous pouvons voir que le générateur de scaffold invoque d'autres générateurs, tels que le générateur `scaffold_controller`. Et certains de ces générateurs invoquent également d'autres générateurs. En particulier, le générateur `scaffold_controller` invoque plusieurs autres générateurs, y compris le générateur `helper`.

Remplaçons le générateur intégré `helper` par un nouveau générateur. Nous nommerons le générateur `my_helper` :

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/rails/my_helper_generator_test.rb
```

Et dans `lib/generators/rails/my_helper/my_helper_generator.rb`, nous définirons le générateur comme suit :

```ruby
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<~RUBY
      module #{class_name}Helper
        # Je suis utile !
      end
    RUBY
  end
end
```

Enfin, nous devons indiquer à Rails d'utiliser le générateur `my_helper` à la place du générateur intégré `helper`. Pour cela, nous utilisons `config.generators`. Dans `config/application.rb`, ajoutons :

```ruby
config.generators do |g|
  g.helper :my_helper
end
```

Maintenant, si nous exécutons à nouveau le générateur de scaffold, nous voyons le générateur `my_helper` en action :

```bash
$ bin/rails generate scaffold Article body:text
      ...
      invoke  scaffold_controller
      ...
      invoke    my_helper
      create      app/helpers/articles_helper.rb
      ...
```

REMARQUE : Vous remarquerez peut-être que la sortie pour le générateur intégré `helper` inclut "invoke test_unit", tandis que la sortie pour `my_helper` ne le fait pas. Bien que le générateur `helper` ne génère pas de tests par défaut, il fournit un crochet pour le faire en utilisant [`hook_for`][]. Nous pouvons faire de même en incluant `hook_for :test_framework, as: :helper` dans la classe `MyHelperGenerator`. Consultez la documentation de `hook_for` pour plus d'informations.


### Résolutions de générateurs

Une autre façon de remplacer des générateurs spécifiques est d'utiliser des _fallbacks_. Un fallback permet à un espace de noms de générateur de déléguer à un autre espace de noms de générateur.
Par exemple, supposons que nous voulons remplacer le générateur `test_unit:model` par notre propre générateur `my_test_unit:model`, mais nous ne voulons pas remplacer tous les autres générateurs `test_unit:*` tels que `test_unit:controller`.

Tout d'abord, nous créons le générateur `my_test_unit:model` dans `lib/generators/my_test_unit/model/model_generator.rb` :

```ruby
module MyTestUnit
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def do_different_stuff
      say "Doing different stuff..."
    end
  end
end
```

Ensuite, nous utilisons `config.generators` pour configurer le générateur `test_framework` en tant que `my_test_unit`, mais nous configurons également une solution de repli de sorte que tous les générateurs `my_test_unit:*` manquants se résolvent en `test_unit:*` :

```ruby
config.generators do |g|
  g.test_framework :my_test_unit, fixture: false
  g.fallbacks[:my_test_unit] = :test_unit
end
```

Maintenant, lorsque nous exécutons le générateur de scaffold, nous constatons que `my_test_unit` a remplacé `test_unit`, mais seuls les tests de modèle ont été affectés :

```bash
$ bin/rails generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20230518000000_create_comments.rb
      create    app/models/comment.rb
      invoke    my_test_unit
    Doing different stuff...
      invoke  resource_route
       route    resources :comments
      invoke  scaffold_controller
      create    app/controllers/comments_controller.rb
      invoke    erb
      create      app/views/comments
      create      app/views/comments/index.html.erb
      create      app/views/comments/edit.html.erb
      create      app/views/comments/show.html.erb
      create      app/views/comments/new.html.erb
      create      app/views/comments/_form.html.erb
      create      app/views/comments/_comment.html.erb
      invoke    resource_route
      invoke    my_test_unit
      create      test/controllers/comments_controller_test.rb
      create      test/system/comments_test.rb
      invoke    helper
      create      app/helpers/comments_helper.rb
      invoke      my_test_unit
      invoke    jbuilder
      create      app/views/comments/index.json.jbuilder
      create      app/views/comments/show.json.jbuilder
```

Modèles d'application
---------------------

Les modèles d'application sont un type spécial de générateur. Ils peuvent utiliser toutes les [méthodes d'aide au générateur](#méthodes-d'aide-au-générateur), mais sont écrits sous forme de script Ruby plutôt que sous forme de classe Ruby. Voici un exemple :

```ruby
# template.rb

if yes?("Voulez-vous installer Devise ?")
  gem "devise"
  devise_model = ask("Comment souhaitez-vous appeler le modèle utilisateur ?", default: "User")
end

after_bundle do
  if devise_model
    generate "devise:install"
    generate "devise", devise_model
    rails_command "db:migrate"
  end

  git add: ".", commit: %(-m 'Commit initial')
end
```

Tout d'abord, le modèle demande à l'utilisateur s'il souhaite installer Devise. Si l'utilisateur répond "oui" (ou "o"), le modèle ajoute Devise au `Gemfile` et demande à l'utilisateur le nom du modèle utilisateur Devise (par défaut `User`). Plus tard, après l'exécution de `bundle install`, le modèle exécutera les générateurs Devise et `rails db:migrate` si un modèle Devise a été spécifié. Enfin, le modèle effectuera un `git add` et un `git commit` de l'ensemble du répertoire de l'application.

Nous pouvons exécuter notre modèle lors de la génération d'une nouvelle application Rails en passant l'option `-m` à la commande `rails new` :

```bash
$ rails new my_cool_app -m path/to/template.rb
```

Alternativement, nous pouvons exécuter notre modèle dans une application existante avec `bin/rails app:template` :

```bash
$ bin/rails app:template LOCATION=path/to/template.rb
```

Les modèles n'ont pas besoin d'être stockés localement - vous pouvez spécifier une URL à la place d'un chemin :

```bash
$ rails new my_cool_app -m http://example.com/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

Méthodes d'aide au générateur
----------------------------

Thor fournit de nombreuses méthodes d'aide au générateur via [`Thor::Actions`][], telles que :

* [`copy_file`][]
* [`create_file`][]
* [`gsub_file`][]
* [`insert_into_file`][]
* [`inside`][]

En plus de celles-ci, Rails fournit également de nombreuses méthodes d'aide via [`Rails::Generators::Actions`][], telles que :

* [`environment`][]
* [`gem`][]
* [`generate`][]
* [`git`][]
* [`initializer`][]
* [`lib`][]
* [`rails_command`][]
* [`rake`][]
* [`route`][]
[`Rails::Generators::Base`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html
[`Thor::Actions`]: https://www.rubydoc.info/gems/thor/Thor/Actions
[`create_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#create_file-instance_method
[`desc`]: https://www.rubydoc.info/gems/thor/Thor#desc-class_method
[`Rails::Generators::NamedBase`]: https://api.rubyonrails.org/classes/Rails/Generators/NamedBase.html
[`copy_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#copy_file-instance_method
[`source_root`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-source_root
[`class_option`]: https://www.rubydoc.info/gems/thor/Thor/Base/ClassMethods#class_option-instance_method
[`options`]: https://www.rubydoc.info/gems/thor/Thor/Base#options-instance_method
[`config.generators`]: configuring.html#configuring-generators
[`hook_for`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-hook_for
[`Rails::Generators::Actions`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html
[`environment`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-environment
[`gem`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-gem
[`generate`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-generate
[`git`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-git
[`gsub_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#gsub_file-instance_method
[`initializer`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-initializer
[`insert_into_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#insert_into_file-instance_method
[`inside`]: https://www.rubydoc.info/gems/thor/Thor/Actions#inside-instance_method
[`lib`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-lib
[`rails_command`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rails_command
[`rake`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rake
[`route`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-route
