**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: d3947b8dd1115e8f8e4279581ff626f6
Modèles d'application Rails
===========================

Les modèles d'application sont de simples fichiers Ruby contenant un DSL pour ajouter des gems, des initializers, etc. à votre projet Rails fraîchement créé ou à un projet Rails existant.

Après avoir lu ce guide, vous saurez :

* Comment utiliser les modèles pour générer/personnaliser des applications Rails.
* Comment écrire vos propres modèles d'application réutilisables en utilisant l'API de modèle Rails.

--------------------------------------------------------------------------------

Utilisation
-----------

Pour appliquer un modèle, vous devez fournir au générateur Rails l'emplacement du modèle que vous souhaitez appliquer en utilisant l'option `-m`. Il peut s'agir soit d'un chemin vers un fichier, soit d'une URL.

```bash
$ rails new blog -m ~/template.rb
$ rails new blog -m http://example.com/template.rb
```

Vous pouvez utiliser la commande `app:template` de Rails pour appliquer des modèles à une application Rails existante. L'emplacement du modèle doit être passé via la variable d'environnement LOCATION. Encore une fois, il peut s'agir soit d'un chemin vers un fichier, soit d'une URL.

```bash
$ bin/rails app:template LOCATION=~/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

API de modèle
-------------

L'API de modèles Rails est facile à comprendre. Voici un exemple d'un modèle Rails typique :

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rails_command("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

Les sections suivantes décrivent les principales méthodes fournies par l'API :

### gem(*args)

Ajoute une entrée `gem` pour la gem fournie au `Gemfile` de l'application générée.

Par exemple, si votre application dépend des gems `bj` et `nokogiri` :

```ruby
gem "bj"
gem "nokogiri"
```

Notez que cette méthode ajoute uniquement la gem au `Gemfile` ; elle n'installe pas la gem.

### gem_group(*names, &block)

Enveloppe les entrées de gem dans un groupe.

Par exemple, si vous voulez charger `rspec-rails` uniquement dans les groupes `development` et `test` :

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### add_source(source, options={}, &block)

Ajoute la source donnée au `Gemfile` de l'application générée.

Par exemple, si vous avez besoin de sourcer une gem depuis `"http://gems.github.com"` :

```ruby
add_source "http://gems.github.com"
```

Si un bloc est donné, les entrées de gem dans le bloc sont enveloppées dans le groupe de source.

```ruby
add_source "http://gems.github.com/" do
  gem "rspec-rails"
end
```

### environment/application(data=nil, options={}, &block)

Ajoute une ligne à l'intérieur de la classe `Application` pour `config/application.rb`.

Si `options[:env]` est spécifié, la ligne est ajoutée au fichier correspondant dans `config/environments`.

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
```

Un bloc peut être utilisé à la place de l'argument `data`.

### vendor/lib/file/initializer(filename, data = nil, &block)

Ajoute un initializer au répertoire `config/initializers` de l'application générée.

Disons que vous aimez utiliser `Object#not_nil?` et `Object#not_blank?` :

```ruby
initializer 'bloatlol.rb', <<-CODE
  class Object
    def not_nil?
      !nil?
    end

    def not_blank?
      !blank?
    end
  end
CODE
```

De même, `lib()` crée un fichier dans le répertoire `lib/` et `vendor()` crée un fichier dans le répertoire `vendor/`.

Il y a même `file()`, qui accepte un chemin relatif à partir de `Rails.root` et crée tous les répertoires/fichiers nécessaires :

```ruby
file 'app/components/foo.rb', <<-CODE
  class Foo
  end
CODE
```

Cela créera le répertoire `app/components` et y placera `foo.rb`.

### rakefile(filename, data = nil, &block)

Crée un nouveau fichier rake sous `lib/tasks` avec les tâches fournies :

```ruby
rakefile("bootstrap.rake") do
  <<-TASK
    namespace :boot do
      task :strap do
        puts "i like boots!"
      end
    end
  TASK
end
```

Le code ci-dessus crée `lib/tasks/bootstrap.rake` avec une tâche rake `boot:strap`.

### generate(what, *args)

Exécute le générateur Rails fourni avec les arguments donnés.

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### run(command)

Exécute une commande arbitraire. Tout comme les backticks. Disons que vous voulez supprimer le fichier `README.rdoc` :

```ruby
run "rm README.rdoc"
```

### rails_command(command, options = {})

Exécute la commande fournie dans l'application Rails. Disons que vous voulez migrer la base de données :

```ruby
rails_command "db:migrate"
```

Vous pouvez également exécuter des commandes avec un environnement Rails différent :

```ruby
rails_command "db:migrate", env: 'production'
```

Vous pouvez également exécuter des commandes en tant que super-utilisateur :

```ruby
rails_command "log:clear", sudo: true
```

Vous pouvez également exécuter des commandes qui doivent interrompre la génération de l'application en cas d'échec :

```ruby
rails_command "db:migrate", abort_on_failure: true
```

### route(routing_code)

Ajoute une entrée de routage au fichier `config/routes.rb`. Dans les étapes ci-dessus, nous avons généré un scaffold pour une personne et supprimé `README.rdoc`. Maintenant, pour faire de `PeopleController#index` la page par défaut de l'application :

```ruby
route "root to: 'person#index'"
```

### inside(dir)

Vous permet d'exécuter une commande depuis le répertoire donné. Par exemple, si vous avez une copie de Rails edge que vous souhaitez lier symboliquement à partir de vos nouvelles applications, vous pouvez faire ceci :
```ruby
inside('vendor') do
  run "ln -s ~/commit-rails/rails rails"
end
```

### ask(question)

`ask()` vous donne la possibilité d'obtenir des commentaires de l'utilisateur et de les utiliser dans vos modèles. Disons que vous voulez que l'utilisateur donne un nom à la nouvelle bibliothèque brillante que vous ajoutez :

```ruby
lib_name = ask("Comment voulez-vous appeler la nouvelle bibliothèque brillante ?")
lib_name << ".rb" unless lib_name.index(".rb")

lib lib_name, <<-CODE
  class Shiny
  end
CODE
```

### yes?(question) ou no?(question)

Ces méthodes vous permettent de poser des questions à partir de modèles et de décider du flux en fonction de la réponse de l'utilisateur. Disons que vous voulez demander à l'utilisateur d'exécuter des migrations :

```ruby
rails_command("db:migrate") if yes?("Exécuter les migrations de la base de données ?")
# no?(question) agit exactement à l'opposé.
```

### git(:command)

Les modèles Rails vous permettent d'exécuter n'importe quelle commande git :

```ruby
git :init
git add: "."
git commit: "-a -m 'Commit initial'"
```

### after_bundle(&block)

Enregistre un rappel à exécuter après que les gemmes aient été regroupées et que les binstubs aient été générés. Utile pour ajouter des fichiers générés au contrôle de version :

```ruby
after_bundle do
  git :init
  git add: '.'
  git commit: "-a -m 'Commit initial'"
end
```

Les rappels sont exécutés même si `--skip-bundle` a été passé.

Utilisation avancée
--------------

Le modèle d'application est évalué dans le contexte d'une instance de `Rails::Generators::AppGenerator`. Il utilise l'action [`apply`](https://www.rubydoc.info/gems/thor/Thor/Actions#apply-instance_method) fournie par Thor.

Cela signifie que vous pouvez étendre et modifier l'instance pour répondre à vos besoins.

Par exemple, en écrivant la méthode `source_paths` pour contenir l'emplacement de votre modèle. Maintenant, des méthodes comme `copy_file` accepteront des chemins relatifs à l'emplacement de votre modèle.

```ruby
def source_paths
  [__dir__]
end
```
