**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 884491931bd3d9e6c8896768960f0475
O Processo de Inicialização do Rails
================================

Este guia explica os detalhes do processo de inicialização no Rails.
É um guia extremamente detalhado e recomendado para desenvolvedores avançados do Rails.

Após ler este guia, você saberá:

* Como usar `bin/rails server`.
* A sequência de inicialização do Rails.
* Onde diferentes arquivos são requeridos pela sequência de inicialização.
* Como a interface Rails::Server é definida e usada.

--------------------------------------------------------------------------------

Este guia passa por cada chamada de método que é
necessária para inicializar a pilha Ruby on Rails para uma aplicação Rails padrão, explicando cada parte detalhadamente ao longo do caminho. Para este
guia, estaremos focando no que acontece quando você executa `bin/rails server`
para inicializar seu aplicativo.

NOTA: Os caminhos neste guia são relativos ao Rails ou a uma aplicação Rails, a menos que especificado de outra forma.

DICA: Se você quiser acompanhar enquanto navega pelo código-fonte do Rails [source
code](https://github.com/rails/rails), recomendamos que você use a tecla `t`
para abrir o localizador de arquivos dentro do GitHub e encontrar arquivos
rapidamente.

Vamos começar a inicializar o aplicativo. Uma aplicação Rails geralmente é
iniciada executando `bin/rails console` ou `bin/rails server`.

### `bin/rails`

Este arquivo é o seguinte:

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative "../config/boot"
require "rails/commands"
```

A constante `APP_PATH` será usada posteriormente em `rails/commands`. O arquivo `config/boot` referenciado aqui é o arquivo `config/boot.rb` em nossa aplicação, que é responsável por carregar o Bundler e configurá-lo.

### `config/boot.rb`

`config/boot.rb` contém:

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Configura as gemas listadas no Gemfile.
```

Em uma aplicação Rails padrão, há um `Gemfile` que declara todas
as dependências da aplicação. `config/boot.rb` define
`ENV['BUNDLE_GEMFILE']` como a localização deste arquivo. Se o `Gemfile`
existir, então `bundler/setup` é requerido. O require é usado pelo Bundler para
configurar o caminho de carregamento das dependências do seu Gemfile.

### `rails/commands.rb`

Depois que `config/boot.rb` termina, o próximo arquivo que é requerido é
`rails/commands`, que ajuda a expandir os aliases. No caso atual, o
array `ARGV` contém apenas `server`, que será passado adiante:

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

Se tivéssemos usado `s` em vez de `server`, o Rails teria usado os `aliases`
definidos aqui para encontrar o comando correspondente.

### `rails/command.rb`

Quando se digita um comando do Rails, o `invoke` tenta localizar um comando para o namespace fornecido e executa o comando se encontrado.

Se o Rails não reconhecer o comando, ele passa o controle para o Rake
para executar uma tarefa com o mesmo nome.

Como mostrado, `Rails::Command` exibe a saída de ajuda automaticamente se o `namespace`
estiver vazio.

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

Com o comando `server`, o Rails executará o seguinte código:

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

Este arquivo mudará para o diretório raiz do Rails (um caminho dois diretórios acima
de `APP_PATH` que aponta para `config/application.rb`), mas apenas se o
arquivo `config.ru` não for encontrado. Em seguida, ele inicializa a classe `Rails::Server`.

### `actionpack/lib/action_dispatch.rb`

Action Dispatch é o componente de roteamento do framework Rails.
Ele adiciona funcionalidades como roteamento, sessão e middlewares comuns.

### `rails/commands/server/server_command.rb`

A classe `Rails::Server` é definida neste arquivo herdando de
`Rack::Server`. Quando `Rails::Server.new` é chamado, isso chama o método `initialize` em `rails/commands/server/server_command.rb`:

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
Primeiramente, `super` é chamado, o que chama o método `initialize` em `Rack::Server`.

### Rack: `lib/rack/server.rb`

`Rack::Server` é responsável por fornecer uma interface de servidor comum para todas as aplicações baseadas em Rack, das quais o Rails agora faz parte.

O método `initialize` em `Rack::Server` simplesmente define várias variáveis:

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

Neste caso, o valor de retorno de `Rails::Command::ServerCommand#server_options` será atribuído a `options`.
Quando as linhas dentro da declaração if são avaliadas, algumas variáveis de instância serão definidas.

O método `server_options` em `Rails::Command::ServerCommand` é definido da seguinte forma:

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

O valor será atribuído à variável de instância `@options`.

Depois que `super` termina em `Rack::Server`, voltamos para
`rails/commands/server/server_command.rb`. Neste ponto, `set_environment`
é chamado no contexto do objeto `Rails::Server`.

```ruby
module Rails
  module Server
    def set_environment
      ENV["RAILS_ENV"] ||= options[:environment]
    end
  end
end
```

Depois que `initialize` termina, voltamos para o comando do servidor
onde `APP_PATH` (que foi definido anteriormente) é requerido.

### `config/application`

Quando `require APP_PATH` é executado, `config/application.rb` é carregado (lembre-se
que `APP_PATH` é definido em `bin/rails`). Este arquivo existe em sua aplicação
e você pode alterá-lo de acordo com suas necessidades.

### `Rails::Server#start`

Depois que `config/application` é carregado, `server.start` é chamado. Este método é
definido assim:

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

Este método cria uma armadilha para sinais `INT`, então se você pressionar `CTRL-C` no servidor, ele irá encerrar o processo.
Como podemos ver no código aqui, ele criará os diretórios `tmp/cache`,
`tmp/pids` e `tmp/sockets`. Em seguida, ele habilita o cache no desenvolvimento
se `bin/rails server` for chamado com `--dev-caching`. Por fim, ele chama `wrapped_app`, que é
responsável por criar o aplicativo Rack, antes de criar e atribuir uma instância
de `ActiveSupport::Logger`.

O método `super` chamará `Rack::Server.start`, que começa sua definição da seguinte forma:

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

A parte interessante para um aplicativo Rails é a última linha, `server.run`. Aqui encontramos o método `wrapped_app` novamente, que desta vez
vamos explorar mais (mesmo que tenha sido executado antes e
portanto já tenha sido memorizado).

```ruby
module Rack
  class Server
    def wrapped_app
      @wrapped_app ||= build_app app
    end
  end
end
```

O método `app` aqui é definido assim:

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

O valor de `options[:config]` tem como padrão `config.ru`, que contém isso:

```ruby
# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
```


O método `Rack::Builder.parse_file` aqui pega o conteúdo deste arquivo `config.ru` e o analisa usando este código:

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
O método `initialize` de `Rack::Builder` irá pegar o bloco aqui e executá-lo dentro de uma instância de `Rack::Builder`.
É aqui que a maioria do processo de inicialização do Rails acontece.
A linha `require` para `config/environment.rb` em `config.ru` é a primeira a ser executada:

```ruby
require_relative "config/environment"
```

### `config/environment.rb`

Este arquivo é o arquivo comum exigido por `config.ru` (`bin/rails server`) e Passenger. É aqui que essas duas maneiras de executar o servidor se encontram; tudo antes deste ponto foi a configuração do Rack e do Rails.

Este arquivo começa exigindo `config/application.rb`:

```ruby
require_relative "application"
```

### `config/application.rb`

Este arquivo exige `config/boot.rb`:

```ruby
require_relative "boot"
```

Mas somente se não tiver sido exigido antes, o que seria o caso em `bin/rails server`
mas **não** seria o caso com o Passenger.

Então a diversão começa!

Carregando o Rails
-------------

A próxima linha em `config/application.rb` é:

```ruby
require "rails/all"
```

### `railties/lib/rails/all.rb`

Este arquivo é responsável por exigir todos os frameworks individuais do Rails:

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

Aqui é onde todos os frameworks do Rails são carregados e, portanto, disponibilizados para a aplicação. Não vamos entrar em detalhes sobre o que acontece dentro de cada um desses frameworks, mas você é encorajado a explorá-los por conta própria.

Por enquanto, apenas tenha em mente que funcionalidades comuns como engines do Rails,
I18n e configuração do Rails estão sendo definidas aqui.

### Voltando para `config/environment.rb`

O restante de `config/application.rb` define a configuração para o
`Rails::Application` que será usado uma vez que a aplicação esteja totalmente
inicializada. Quando `config/application.rb` termina de carregar o Rails e define
o namespace da aplicação, voltamos para `config/environment.rb`. Aqui, a
aplicação é inicializada com `Rails.application.initialize!`, que é
definido em `rails/application.rb`.

### `railties/lib/rails/application.rb`

O método `initialize!` se parece com isso:

```ruby
def initialize!(group = :default) # :nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

Você só pode inicializar um aplicativo uma vez. Os [initializers](configuring.html#initializers) do Railtie são executados através do método `run_initializers`, que é definido em `railties/lib/rails/initializable.rb`:

```ruby
def run_initializers(group = :default, *args)
  return if instance_variable_defined?(:@ran)
  initializers.tsort_each do |initializer|
    initializer.run(*args) if initializer.belongs_to?(group)
  end
  @ran = true
end
```

O código `run_initializers` em si é complicado. O que o Rails está fazendo aqui é
percorrer todos os ancestrais da classe em busca daqueles que respondem a um
método `initializers`. Em seguida, ele ordena os ancestrais por nome e os executa.
Por exemplo, a classe `Engine` tornará todas as engines disponíveis ao
fornecer um método `initializers` nelas.

A classe `Rails::Application`, conforme definida em `railties/lib/rails/application.rb`,
define os initializers `bootstrap`, `railtie` e `finisher`. Os initializers `bootstrap`
preparam a aplicação (como inicializar o logger), enquanto os initializers `finisher`
(como construir a pilha de middlewares) são executados por último. Os initializers `railtie`
são os initializers que foram definidos no próprio `Rails::Application`
e são executados entre os `bootstrap` e `finishers`.

NOTA: Não confunda os initializers do Railtie em geral com o [load_config_initializers](configuring.html#using-initializer-files)
instância do initializer ou seus initializers de configuração associados em `config/initializers`.

Depois disso, voltamos para `Rack::Server`.

### Rack: lib/rack/server.rb

Da última vez, paramos quando o método `app` estava sendo definido:

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

Neste ponto, `app` é o próprio aplicativo Rails (um middleware), e o
que acontece em seguida é que o Rack chamará todos os middlewares fornecidos:

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

Lembre-se, `build_app` foi chamado (por `wrapped_app`) na última linha de `Rack::Server#start`.
Aqui está como parecia quando paramos:

```ruby
server.run wrapped_app, options, &blk
```

Neste ponto, a implementação de `server.run` dependerá do
servidor que você está usando. Por exemplo, se você estivesse usando o Puma, aqui está como
o método `run` ficaria:

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
Não vamos nos aprofundar na configuração do servidor em si, mas esta é a última parte de nossa jornada no processo de inicialização do Rails.

Esta visão geral de alto nível ajudará você a entender quando e como seu código é executado e, em geral, se tornar um melhor desenvolvedor Rails. Se você ainda quiser saber mais, o próprio código-fonte do Rails é provavelmente o melhor lugar para ir em seguida.
