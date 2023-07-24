**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 884491931bd3d9e6c8896768960f0475
Le processus d'initialisation de Rails
=======================================

Ce guide explique les détails du processus d'initialisation dans Rails.
Il s'agit d'un guide extrêmement détaillé et recommandé pour les développeurs Rails avancés.

Après avoir lu ce guide, vous saurez :

* Comment utiliser `bin/rails server`.
* La chronologie de la séquence d'initialisation de Rails.
* Où les différents fichiers sont requis par la séquence de démarrage.
* Comment l'interface Rails::Server est définie et utilisée.

--------------------------------------------------------------------------------

Ce guide passe en revue chaque appel de méthode nécessaire pour démarrer la pile Ruby on Rails pour une application Rails par défaut, expliquant chaque partie en détail tout au long du processus. Pour ce guide, nous nous concentrerons sur ce qui se passe lorsque vous exécutez `bin/rails server` pour démarrer votre application.

NOTE : Les chemins dans ce guide sont relatifs à Rails ou à une application Rails, sauf indication contraire.

CONSEIL : Si vous souhaitez suivre en même temps que vous parcourez le [code source de Rails](https://github.com/rails/rails), nous vous recommandons d'utiliser la touche `t` pour ouvrir le chercheur de fichiers à l'intérieur de GitHub et trouver rapidement les fichiers.

C'est parti !
-------------

Commençons par démarrer et initialiser l'application. Une application Rails est généralement lancée en exécutant `bin/rails console` ou `bin/rails server`.

### `bin/rails`

Ce fichier est le suivant :

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative "../config/boot"
require "rails/commands"
```

La constante `APP_PATH` sera utilisée ultérieurement dans `rails/commands`. Le fichier `config/boot` référencé ici est le fichier `config/boot.rb` de notre application, qui est responsable du chargement de Bundler et de sa configuration.

### `config/boot.rb`

`config/boot.rb` contient :

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Configure les gems répertoriées dans le Gemfile.
```

Dans une application Rails standard, il y a un `Gemfile` qui déclare toutes les dépendances de l'application. `config/boot.rb` définit `ENV['BUNDLE_GEMFILE']` sur l'emplacement de ce fichier. Si le `Gemfile` existe, alors `bundler/setup` est requis. Le require est utilisé par Bundler pour configurer le chemin de chargement des dépendances de votre Gemfile.

### `rails/commands.rb`

Une fois que `config/boot.rb` est terminé, le fichier suivant requis est `rails/commands`, qui aide à étendre les alias. Dans le cas actuel, le tableau `ARGV` contient simplement `server` qui sera transmis :

```ruby
require "rails/command"

aliases = {
  "g"  => "generate",
  "d"  => "destroy",
  "c"  => "console",
  "s"  => "server",
  "db" => "dbconsole",
  "r"  => "runner",
  "t"  => "test"
}

command = ARGV.shift
command = aliases[command] || command

Rails::Command.invoke command, ARGV
```

Si nous avions utilisé `s` au lieu de `server`, Rails aurait utilisé les `aliases` définis ici pour trouver la commande correspondante.

### `rails/command.rb`

Lorsqu'on tape une commande Rails, `invoke` essaie de rechercher une commande pour l'espace de noms donné et exécute la commande si elle est trouvée.

Si Rails ne reconnaît pas la commande, il passe les rênes à Rake pour exécuter une tâche du même nom.

Comme indiqué, `Rails::Command` affiche automatiquement la sortie d'aide si l'espace de noms est vide.

```ruby
module Rails
  module Command
    class << self
      def invoke(full_namespace, args = [], **config)
        namespace = full_namespace = full_namespace.to_s

        if char = namespace =~ /:(\w+)$/
          command_name, namespace = $1, namespace.slice(0, char)
        else
          command_name = namespace
        end

        command_name, namespace = "help", "help" if command_name.blank? || HELP_MAPPINGS.include?(command_name)
        command_name, namespace = "version", "version" if %w( -v --version ).include?(command_name)

        command = find_by_namespace(namespace, command_name)
        if command && command.all_commands[command_name]
          command.perform(command_name, args, config)
        else
          find_by_namespace("rake").perform(full_namespace, args, config)
        end
      end
    end
  end
end
```

Avec la commande `server`, Rails exécutera ensuite le code suivant :

```ruby
module Rails
  module Command
    class ServerCommand < Base # :nodoc:
      def perform
        extract_environment_option_from_argument
        set_application_directory!
        prepare_restart

        Rails::Server.new(server_options).tap do |server|
          # Require application after server sets environment to propagate
          # the --environment option.
          require APP_PATH
          Dir.chdir(Rails.application.root)

          if server.serveable?
            print_boot_information(server.server, server.served_url)
            after_stop_callback = -> { say "Exiting" unless options[:daemon] }
            server.start(after_stop_callback)
          else
            say rack_server_suggestion(using)
          end
        end
      end
    end
  end
end
```

Ce fichier se déplacera vers le répertoire racine de Rails (un chemin deux répertoires au-dessus de `APP_PATH` qui pointe vers `config/application.rb`), mais seulement si le fichier `config.ru` n'est pas trouvé. Cela démarre ensuite la classe `Rails::Server`.

### `actionpack/lib/action_dispatch.rb`

Action Dispatch est le composant de routage du framework Rails.
Il ajoute des fonctionnalités telles que le routage, la session et les middlewares communs.

### `rails/commands/server/server_command.rb`

La classe `Rails::Server` est définie dans ce fichier en héritant de `Rack::Server`. Lorsque `Rails::Server.new` est appelé, cela appelle la méthode `initialize` dans `rails/commands/server/server_command.rb` :

```ruby
module Rails
  class Server < ::Rack::Server
    def initialize(options = nil)
      @default_options = options || {}
      super(@default_options)
      set_environment
    end
  end
end
```
Tout d'abord, `super` est appelé, ce qui appelle la méthode `initialize` sur `Rack::Server`.

### Rack: `lib/rack/server.rb`

`Rack::Server` est responsable de fournir une interface de serveur commune pour toutes les applications basées sur Rack, dont Rails fait maintenant partie.

La méthode `initialize` dans `Rack::Server` définit simplement plusieurs variables :

```ruby
module Rack
  class Server
    def initialize(options = nil)
      @ignore_options = []

      if options
        @use_default_options = false
        @options = options
        @app = options[:app] if options[:app]
      else
        argv = defined?(SPEC_ARGV) ? SPEC_ARGV : ARGV
        @use_default_options = true
        @options = parse_options(argv)
      end
    end
  end
end
```

Dans ce cas, la valeur de retour de `Rails::Command::ServerCommand#server_options` sera assignée à `options`.
Lorsque les lignes à l'intérieur de l'instruction if sont évaluées, plusieurs variables d'instance seront définies.

La méthode `server_options` dans `Rails::Command::ServerCommand` est définie comme suit :

```ruby
module Rails
  module Command
    class ServerCommand
      no_commands do
        def server_options
          {
            user_supplied_options: user_supplied_options,
            server:                using,
            log_stdout:            log_to_stdout?,
            Port:                  port,
            Host:                  host,
            DoNotReverseLookup:    true,
            config:                options[:config],
            environment:           environment,
            daemonize:             options[:daemon],
            pid:                   pid,
            caching:               options[:dev_caching],
            restart_cmd:           restart_command,
            early_hints:           early_hints
          }
        end
      end
    end
  end
end
```

La valeur sera assignée à la variable d'instance `@options`.

Après que `super` ait terminé dans `Rack::Server`, nous revenons à `rails/commands/server/server_command.rb`. À ce stade, `set_environment` est appelé dans le contexte de l'objet `Rails::Server`.

```ruby
module Rails
  module Server
    def set_environment
      ENV["RAILS_ENV"] ||= options[:environment]
    end
  end
end
```

Après que `initialize` ait terminé, nous revenons à la commande du serveur
où `APP_PATH` (qui a été défini précédemment) est requis.

### `config/application`

Lorsque `require APP_PATH` est exécuté, `config/application.rb` est chargé (rappelez-vous
que `APP_PATH` est défini dans `bin/rails`). Ce fichier existe dans votre application
et vous êtes libre de le modifier en fonction de vos besoins.

### `Rails::Server#start`

Après le chargement de `config/application`, `server.start` est appelé. Cette méthode est
définie comme ceci :

```ruby
module Rails
  class Server < ::Rack::Server
    def start(after_stop_callback = nil)
      trap(:INT) { exit }
      create_tmp_directories
      setup_dev_caching
      log_to_stdout if options[:log_stdout]

      super()
      # ...
    end

    private
      def setup_dev_caching
        if options[:environment] == "development"
          Rails::DevCaching.enable_by_argument(options[:caching])
        end
      end

      def create_tmp_directories
        %w(cache pids sockets).each do |dir_to_make|
          FileUtils.mkdir_p(File.join(Rails.root, "tmp", dir_to_make))
        end
      end

      def log_to_stdout
        wrapped_app # touch the app so the logger is set up

        console = ActiveSupport::Logger.new(STDOUT)
        console.formatter = Rails.logger.formatter
        console.level = Rails.logger.level

        unless ActiveSupport::Logger.logger_outputs_to?(Rails.logger, STDOUT)
          Rails.logger.extend(ActiveSupport::Logger.broadcast(console))
        end
      end
  end
end
```

Cette méthode crée un piège pour les signaux `INT`, donc si vous appuyez sur `CTRL-C` sur le serveur, il quittera le processus.
Comme nous pouvons le voir à partir du code ici, il créera les répertoires `tmp/cache`,
`tmp/pids` et `tmp/sockets`. Il active ensuite le caching en développement
si `bin/rails server` est appelé avec `--dev-caching`. Enfin, il appelle `wrapped_app` qui est
responsable de la création de l'application Rack, avant de créer et d'assigner une instance
de `ActiveSupport::Logger`.

La méthode `super` appellera `Rack::Server.start` qui commence sa définition comme suit :

```ruby
module Rack
  class Server
    def start(&blk)
      if options[:warn]
        $-w = true
      end

      if includes = options[:include]
        $LOAD_PATH.unshift(*includes)
      end

      if library = options[:require]
        require library
      end

      if options[:debug]
        $DEBUG = true
        require "pp"
        p options[:server]
        pp wrapped_app
        pp app
      end

      check_pid! if options[:pid]

      # Touch the wrapped app, so that the config.ru is loaded before
      # daemonization (i.e. before chdir, etc).
      handle_profiling(options[:heapfile], options[:profile_mode], options[:profile_file]) do
        wrapped_app
      end

      daemonize_app if options[:daemonize]

      write_pid if options[:pid]

      trap(:INT) do
        if server.respond_to?(:shutdown)
          server.shutdown
        else
          exit
        end
      end

      server.run wrapped_app, options, &blk
    end
  end
end
```

La partie intéressante pour une application Rails est la dernière ligne, `server.run`. Ici, nous rencontrons à nouveau la méthode `wrapped_app`, que nous allons explorer plus en détail cette fois-ci (même si elle a été exécutée auparavant et
donc mémorisée à présent).

```ruby
module Rack
  class Server
    def wrapped_app
      @wrapped_app ||= build_app app
    end
  end
end
```

La méthode `app` ici est définie comme ceci :

```ruby
module Rack
  class Server
    def app
      @app ||= options[:builder] ? build_app_from_string : build_app_and_options_from_config
    end

    # ...

    private
      def build_app_and_options_from_config
        if !::File.exist? options[:config]
          abort "configuration #{options[:config]} not found"
        end

        app, options = Rack::Builder.parse_file(self.options[:config], opt_parser)
        @options.merge!(options) { |key, old, new| old }
        app
      end

      def build_app_from_string
        Rack::Builder.new_from_string(self.options[:builder])
      end
  end
end
```

La valeur de `options[:config]` est par défaut `config.ru` qui contient ceci :

```ruby
# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
```


La méthode `Rack::Builder.parse_file` ici prend le contenu de ce fichier `config.ru` et le parse en utilisant ce code :

```ruby
module Rack
  class Builder
    def self.load_file(path, opts = Server::Options.new)
      # ...
      app = new_from_string cfgfile, config
      # ...
    end

    # ...

    def self.new_from_string(builder_script, file = "(rackup)")
      eval "Rack::Builder.new {\n" + builder_script + "\n}.to_app",
        TOPLEVEL_BINDING, file, 0
    end
  end
end
```
La méthode `initialize` de `Rack::Builder` prendra le bloc ici et l'exécutera dans une instance de `Rack::Builder`.
C'est là que se déroule la majeure partie du processus d'initialisation de Rails.
La ligne `require` pour `config/environment.rb` dans `config.ru` est la première à s'exécuter :

```ruby
require_relative "config/environment"
```

### `config/environment.rb`

Ce fichier est le fichier commun requis par `config.ru` (`bin/rails server`) et Passenger. C'est là que ces deux façons d'exécuter le serveur se rencontrent ; tout ce qui précède ce point a été la configuration de Rack et Rails.

Ce fichier commence par exiger `config/application.rb` :

```ruby
require_relative "application"
```

### `config/application.rb`

Ce fichier exige `config/boot.rb` :

```ruby
require_relative "boot"
```

Mais seulement s'il n'a pas été requis auparavant, ce qui serait le cas dans `bin/rails server`
mais **ne serait pas** le cas avec Passenger.

Ensuite, le plaisir commence !

Chargement de Rails
-------------------

La ligne suivante dans `config/application.rb` est :

```ruby
require "rails/all"
```

### `railties/lib/rails/all.rb`

Ce fichier est responsable de l'exigence de tous les frameworks individuels de Rails :

```ruby
require "rails"

%w(
  active_record/railtie
  active_storage/engine
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_cable/engine
  action_mailbox/engine
  action_text/engine
  rails/test_unit/railtie
).each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end
```

C'est là que tous les frameworks de Rails sont chargés et donc rendus
disponibles pour l'application. Nous n'entrerons pas dans les détails de ce qui se passe
à l'intérieur de chacun de ces frameworks, mais vous êtes encouragé à essayer et
à les explorer par vous-même.

Pour l'instant, gardez simplement à l'esprit que des fonctionnalités communes comme les moteurs Rails,
I18n et la configuration Rails sont toutes définies ici.

### Retour à `config/environment.rb`

Le reste de `config/application.rb` définit la configuration pour
`Rails::Application` qui sera utilisée une fois que l'application sera entièrement
initialisée. Lorsque `config/application.rb` a terminé de charger Rails et a défini
l'espace de noms de l'application, nous revenons à `config/environment.rb`. Ici, l'
application est initialisée avec `Rails.application.initialize!`, qui est
défini dans `rails/application.rb`.

### `railties/lib/rails/application.rb`

La méthode `initialize!` ressemble à ceci :

```ruby
def initialize!(group = :default) # :nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

Vous ne pouvez initialiser une application qu'une seule fois. Les [initialiseurs](configuring.html#initializers) de Railtie sont exécutés à l'aide de la méthode `run_initializers` qui est définie dans `railties/lib/rails/initializable.rb` :

```ruby
def run_initializers(group = :default, *args)
  return if instance_variable_defined?(:@ran)
  initializers.tsort_each do |initializer|
    initializer.run(*args) if initializer.belongs_to?(group)
  end
  @ran = true
end
```

Le code `run_initializers` lui-même est délicat. Ce que fait Rails ici, c'est
parcourir tous les ancêtres de classe à la recherche de ceux qui répondent à une
méthode `initializers`. Il trie ensuite les ancêtres par nom et les exécute.
Par exemple, la classe `Engine` rendra tous les moteurs disponibles en
fournissant une méthode `initializers` sur eux.

La classe `Rails::Application`, telle que définie dans `railties/lib/rails/application.rb`,
définit les initialiseurs `bootstrap`, `railtie` et `finisher`. Les initialiseurs `bootstrap`
préparent l'application (comme l'initialisation du journal) tandis que les initialiseurs `finisher`
(comme la construction de la pile de middleware) sont exécutés en dernier. Les initialiseurs `railtie`
sont les initialiseurs qui ont été définis sur `Rails::Application`
lui-même et sont exécutés entre les initialiseurs `bootstrap` et `finishers`.

NOTE : Ne confondez pas les initialiseurs de Railtie en général avec l'initialiseur [load_config_initializers](configuring.html#using-initializer-files)
ou ses initialiseurs de configuration associés dans `config/initializers`.

Une fois cela fait, nous revenons à `Rack::Server`.

### Rack: lib/rack/server.rb

La dernière fois, nous avons laissé la méthode `app` en cours de définition :

```ruby
module Rack
  class Server
    def app
      @app ||= options[:builder] ? build_app_from_string : build_app_and_options_from_config
    end

    # ...

    private
      def build_app_and_options_from_config
        if !::File.exist? options[:config]
          abort "configuration #{options[:config]} not found"
        end

        app, options = Rack::Builder.parse_file(self.options[:config], opt_parser)
        @options.merge!(options) { |key, old, new| old }
        app
      end

      def build_app_from_string
        Rack::Builder.new_from_string(self.options[:builder])
      end
  end
end
```

À ce stade, `app` est l'application Rails elle-même (un middleware), et ce
qui se passe ensuite, c'est que Rack appellera tous les middlewares fournis :

```ruby
module Rack
  class Server
    private
      def build_app(app)
        middleware[options[:environment]].reverse_each do |middleware|
          middleware = middleware.call(self) if middleware.respond_to?(:call)
          next unless middleware
          klass, *args = middleware
          app = klass.new(app, *args)
        end
        app
      end
  end
end
```

Rappelez-vous, `build_app` a été appelé (par `wrapped_app`) à la dernière ligne de `Rack::Server#start`.
Voici à quoi cela ressemblait lorsque nous avons quitté :

```ruby
server.run wrapped_app, options, &blk
```

À ce stade, la mise en œuvre de `server.run` dépendra du
serveur que vous utilisez. Par exemple, si vous utilisez Puma, voici à quoi
ressemblerait la méthode `run` :

```ruby
module Rack
  module Handler
    module Puma
      # ...
      def self.run(app, options = {})
        conf   = self.config(app, options)

        events = options.delete(:Silent) ? ::Puma::Events.strings : ::Puma::Events.stdio

        launcher = ::Puma::Launcher.new(conf, events: events)

        yield launcher if block_given?
        begin
          launcher.run
        rescue Interrupt
          puts "* Gracefully stopping, waiting for requests to finish"
          launcher.stop
          puts "* Goodbye!"
        end
      end
      # ...
    end
  end
end
```
Nous n'allons pas nous plonger dans la configuration du serveur lui-même, mais ceci est la dernière étape de notre parcours dans le processus d'initialisation de Rails.

Cette vue d'ensemble vous aidera à comprendre quand votre code est exécuté et comment, et en général à devenir un meilleur développeur Rails. Si vous voulez en savoir plus, le code source de Rails lui-même est probablement le meilleur endroit où aller ensuite.
