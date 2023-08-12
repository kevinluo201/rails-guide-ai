**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 884491931bd3d9e6c8896768960f0475
El Proceso de Inicialización de Rails
================================

Esta guía explica los detalles internos del proceso de inicialización en Rails.
Es una guía extremadamente detallada y recomendada para desarrolladores avanzados de Rails.

Después de leer esta guía, sabrás:

* Cómo usar `bin/rails server`.
* La secuencia de inicialización de Rails.
* Dónde se requieren diferentes archivos en la secuencia de inicio.
* Cómo se define y utiliza la interfaz de Rails::Server.

--------------------------------------------------------------------------------

Esta guía pasa por cada llamada de método que es
necesaria para iniciar la pila de Ruby on Rails para una aplicación Rails predeterminada,
explicando cada parte en detalle a lo largo del camino. Para esta
guía, nos centraremos en lo que sucede cuando ejecutas `bin/rails server`
para iniciar tu aplicación.

NOTA: Las rutas en esta guía son relativas a Rails o a una aplicación Rails a menos que se especifique lo contrario.

CONSEJO: Si quieres seguir mientras navegas por el [código fuente de Rails](https://github.com/rails/rails), recomendamos que uses la tecla `t` para abrir el buscador de archivos dentro de GitHub y encontrar archivos rápidamente.

¡Vamos!
-------

Comencemos a iniciar y inicializar la aplicación. Una aplicación Rails generalmente se inicia ejecutando `bin/rails console` o `bin/rails server`.

### `bin/rails`

Este archivo es el siguiente:

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative "../config/boot"
require "rails/commands"
```

La constante `APP_PATH` se utilizará más adelante en `rails/commands`. El archivo `config/boot` al que se hace referencia aquí es el archivo `config/boot.rb` en nuestra aplicación, que se encarga de cargar Bundler y configurarlo.

### `config/boot.rb`

`config/boot.rb` contiene:

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Configura las gemas enumeradas en el Gemfile.
```

En una aplicación Rails estándar, hay un `Gemfile` que declara todas las dependencias de la aplicación. `config/boot.rb` establece `ENV['BUNDLE_GEMFILE']` en la ubicación de este archivo. Si existe el `Gemfile`, se requiere `bundler/setup`. La instrucción require es utilizada por Bundler para configurar la ruta de carga para las dependencias de tu Gemfile.

### `rails/commands.rb`

Una vez que `config/boot.rb` ha terminado, el siguiente archivo que se requiere es `rails/commands`, que ayuda a expandir los alias. En el caso actual, la matriz `ARGV` simplemente contiene `server`, que se pasará:

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

Si hubiéramos usado `s` en lugar de `server`, Rails habría utilizado los `aliases`
definidos aquí para encontrar el comando correspondiente.

### `rails/command.rb`

Cuando se escribe un comando de Rails, `invoke` intenta buscar un comando para el espacio de nombres dado y ejecuta el comando si se encuentra.

Si Rails no reconoce el comando, le entrega el control a Rake
para ejecutar una tarea con el mismo nombre.

Como se muestra, `Rails::Command` muestra automáticamente la salida de ayuda si el `namespace`
está vacío.

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

Con el comando `server`, Rails ejecutará el siguiente código adicional:

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

Este archivo cambiará al directorio raíz de Rails (una ruta dos directorios arriba
de `APP_PATH` que apunta a `config/application.rb`), pero solo si no se encuentra el
archivo `config.ru`. Luego se inicia la clase `Rails::Server`.

### `actionpack/lib/action_dispatch.rb`

Action Dispatch es el componente de enrutamiento del framework Rails.
Agrega funcionalidades como enrutamiento, sesión y middlewares comunes.

### `rails/commands/server/server_command.rb`

La clase `Rails::Server` está definida en este archivo heredando de
`Rack::Server`. Cuando se llama a `Rails::Server.new`, esto llama al método `initialize` en `rails/commands/server/server_command.rb`:

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
En primer lugar, se llama a `super`, que llama al método `initialize` en `Rack::Server`.

### Rack: `lib/rack/server.rb`

`Rack::Server` es responsable de proporcionar una interfaz de servidor común para todas las aplicaciones basadas en Rack, de las cuales Rails ahora forma parte.

El método `initialize` en `Rack::Server` simplemente establece varias variables:

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

En este caso, el valor de retorno de `Rails::Command::ServerCommand#server_options` se asignará a `options`.
Cuando se evalúan las líneas dentro de la declaración if, se establecerán un par de variables de instancia.

El método `server_options` en `Rails::Command::ServerCommand` se define de la siguiente manera:

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

El valor se asignará a la variable de instancia `@options`.

Después de que `super` haya terminado en `Rack::Server`, volvemos a
`rails/commands/server/server_command.rb`. En este punto, se llama a `set_environment`
dentro del contexto del objeto `Rails::Server`.

```ruby
module Rails
  module Server
    def set_environment
      ENV["RAILS_ENV"] ||= options[:environment]
    end
  end
end
```

Después de que `initialize` haya terminado, volvemos al comando del servidor
donde se requiere `APP_PATH` (que se estableció anteriormente).

### `config/application`

Cuando se ejecuta `require APP_PATH`, se carga `config/application.rb` (recuerda
que `APP_PATH` se define en `bin/rails`). Este archivo existe en tu aplicación
y es libre de cambiar según tus necesidades.

### `Rails::Server#start`

Después de cargar `config/application`, se llama a `server.start`. Este método se
define de la siguiente manera:

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
        wrapped_app # toca la aplicación para configurar el registrador

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

Este método crea una trampa para las señales `INT`, por lo que si presionas `CTRL-C` en el servidor, se cerrará el proceso.
Como podemos ver en el código aquí, creará los directorios `tmp/cache`,
`tmp/pids` y `tmp/sockets`. Luego, habilitará el almacenamiento en caché en desarrollo
si se llama a `bin/rails server` con `--dev-caching`. Finalmente, llama a `wrapped_app` que es
responsable de crear la aplicación Rack, antes de crear y asignar una instancia
de `ActiveSupport::Logger`.

El método `super` llamará a `Rack::Server.start` que comienza su definición de la siguiente manera:

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

      # Toca la aplicación envuelta, para que se cargue el config.ru antes
      # de la demonización (es decir, antes de chdir, etc.).
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

La parte interesante para una aplicación Rails es la última línea, `server.run`. Aquí encontramos nuevamente el método `wrapped_app`, que esta vez
vamos a explorar más (aunque ya se haya ejecutado antes y
por lo tanto ya se haya memoizado).

```ruby
module Rack
  class Server
    def wrapped_app
      @wrapped_app ||= build_app app
    end
  end
end
```

El método `app` aquí se define de la siguiente manera:

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

El valor de `options[:config]` se establece en `config.ru`, que contiene esto:

```ruby
# Este archivo es utilizado por los servidores basados en Rack para iniciar la aplicación.

require_relative "config/environment"

run Rails.application
```


El método `Rack::Builder.parse_file` aquí toma el contenido de este archivo `config.ru` y lo analiza usando este código:

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
El método `initialize` de `Rack::Builder` tomará el bloque aquí y lo ejecutará dentro de una instancia de `Rack::Builder`. Aquí es donde ocurre la mayoría del proceso de inicialización de Rails. La línea `require` para `config/environment.rb` en `config.ru` es la primera en ejecutarse:

```ruby
require_relative "config/environment"
```

### `config/environment.rb`

Este archivo es el archivo común requerido por `config.ru` (`bin/rails server`) y Passenger. Aquí es donde se encuentran estas dos formas de ejecutar el servidor; todo antes de este punto ha sido configuración de Rack y Rails.

Este archivo comienza requiriendo `config/application.rb`:

```ruby
require_relative "application"
```

### `config/application.rb`

Este archivo requiere `config/boot.rb`:

```ruby
require_relative "boot"
```

Pero solo si no ha sido requerido antes, lo cual sería el caso en `bin/rails server`, pero **no** sería el caso con Passenger.

¡Y luego comienza la diversión!

Cargando Rails
--------------

La siguiente línea en `config/application.rb` es:

```ruby
require "rails/all"
```

### `railties/lib/rails/all.rb`

Este archivo es responsable de requerir todos los frameworks individuales de Rails:

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

Aquí es donde se cargan todos los frameworks de Rails y, por lo tanto, se ponen a disposición de la aplicación. No entraremos en detalles sobre lo que sucede dentro de cada uno de esos frameworks, pero se te anima a que los explores por tu cuenta.

Por ahora, solo ten en cuenta que la funcionalidad común como los motores de Rails, I18n y la configuración de Rails se definen aquí.

### De vuelta a `config/environment.rb`

El resto de `config/application.rb` define la configuración para la `Rails::Application` que se utilizará una vez que la aplicación esté completamente inicializada. Cuando `config/application.rb` ha terminado de cargar Rails y ha definido el espacio de nombres de la aplicación, volvemos a `config/environment.rb`. Aquí, la aplicación se inicializa con `Rails.application.initialize!`, que está definido en `rails/application.rb`.

### `railties/lib/rails/application.rb`

El método `initialize!` se ve así:

```ruby
def initialize!(group = :default) # :nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

Solo puedes inicializar una aplicación una vez. Los [inicializadores](configuring.html#initializers) de Railtie se ejecutan a través del método `run_initializers`, que está definido en `railties/lib/rails/initializable.rb`:

```ruby
def run_initializers(group = :default, *args)
  return if instance_variable_defined?(:@ran)
  initializers.tsort_each do |initializer|
    initializer.run(*args) if initializer.belongs_to?(group)
  end
  @ran = true
end
```

El código de `run_initializers` en sí es complicado. Lo que Rails está haciendo aquí es recorrer todos los ancestros de clase en busca de aquellos que respondan a un método `initializers`. Luego ordena los ancestros por nombre y los ejecuta. Por ejemplo, la clase `Engine` hará que todos los motores estén disponibles al proporcionar un método `initializers` en ellos.

La clase `Rails::Application`, como se define en `railties/lib/rails/application.rb`, define los inicializadores `bootstrap`, `railtie` y `finisher`. Los inicializadores `bootstrap` preparan la aplicación (como inicializar el registrador de eventos) mientras que los inicializadores `finisher` (como construir la pila de middleware) se ejecutan al final. Los inicializadores `railtie` son los inicializadores que se han definido en `Rails::Application` y se ejecutan entre los inicializadores `bootstrap` y `finisher`.

NOTA: No confundas los inicializadores de Railtie en general con el inicializador [load_config_initializers](configuring.html#using-initializer-files) de instancia o sus inicializadores de configuración asociados en `config/initializers`.

Después de esto, volvemos a `Rack::Server`.

### Rack: lib/rack/server.rb

La última vez que dejamos el método `app` estaba siendo definido:

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

En este punto, `app` es la propia aplicación de Rails (un middleware), y lo que sucede a continuación es que Rack llamará a todos los middlewares proporcionados:

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

Recuerda, `build_app` fue llamado (por `wrapped_app`) en la última línea de `Rack::Server#start`. Así es como se veía cuando lo dejamos:

```ruby
server.run wrapped_app, options, &blk
```

En este punto, la implementación de `server.run` dependerá del servidor que estés utilizando. Por ejemplo, si estuvieras usando Puma, así es como se vería el método `run`:

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
No nos adentraremos en la configuración del servidor en sí, pero esta es la última pieza de nuestro viaje en el proceso de inicialización de Rails.

Esta descripción general de alto nivel te ayudará a entender cuándo y cómo se ejecuta tu código, y en general te convertirá en un mejor desarrollador de Rails. Si aún quieres saber más, el código fuente de Rails en sí probablemente sea el mejor lugar para seguir.
