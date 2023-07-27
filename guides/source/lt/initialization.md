**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 884491931bd3d9e6c8896768960f0475
Rails Inicializacijos Procesas
================================

Šis vadovas paaiškina Rails inicializacijos proceso vidinius veiksmus.
Tai yra labai išsamus vadovas, rekomenduojamas patyrusiems Rails programuotojams.

Po šio vadovo perskaitymo, žinosite:

* Kaip naudoti `bin/rails server`.
* Rails inicializacijos seka.
* Kuriose failuose yra reikalingas paleidimo seka.
* Kaip apibrėžiama ir naudojama Rails::Server sąsaja.

--------------------------------------------------------------------------------

Šis vadovas eina per kiekvieną metodo iškvietimą,
reikalingą paleisti Ruby on Rails paketą numatytame Rails
programoje, išsamiai paaiškindamas kiekvieną dalį kelyje. Šiam
vadovui mes sutelksime dėmesį į tai, kas vyksta, kai vykdote `bin/rails server`
komandą, kad paleistumėte savo programą.

Pastaba: Šiame vadove keliose yra nuorodos į Rails arba Rails programą, nebent kitaip nurodyta.

Patarimas: Jei norite sekti kartu naršydami Rails [šaltinio kodą](https://github.com/rails/rails), rekomenduojame naudoti `t` klavišo junginį, kad atidarytumėte failų paieškos langą GitHub ir greitai rastumėte failus.

Paleidimas!
-----------

Pradėkime paleisti ir inicializuoti programą. Rails programa paprastai
paleidžiama vykdant `bin/rails console` arba `bin/rails server`.

### `bin/rails`

Šis failas yra toks:

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative "../config/boot"
require "rails/commands"
```

`APP_PATH` konstanta bus naudojama vėliau `rails/commands`. Čia pateikiamas nuoroda į `config/boot.rb` failą mūsų programoje, kuris atsakingas už Bundler įkėlimą ir jo konfigūraciją.

### `config/boot.rb`

`config/boot.rb` yra toks:

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Nustatyti Gemfile nurodytus paketus.
```

Standartinėje Rails programoje yra `Gemfile`, kuriame nurodomos visos
programos priklausomybės. `config/boot.rb` nustato
`ENV['BUNDLE_GEMFILE']` reikšmę į šio failo vietą. Jei yra `Gemfile`,
tada reikalingas `bundler/setup`. Šis reikalavimas naudojamas, kad Bundler konfigūruotų paketų įkėlimo kelią.

### `rails/commands.rb`

Kai `config/boot.rb` baigia darbą, sekančias reikalingas failas yra
`rails/commands`, kuris padeda išplėsti pseudonimus. Šiuo atveju
`ARGV` masyve tiesiog yra `server`, kuris bus perduotas:

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

Jei būtume naudoję `s` vietoje `server`, Rails būtų naudojęs čia apibrėžtus `aliases`
norėdamas rasti atitinkamą komandą.

### `rails/command.rb`

Kai įvedama Rails komanda, `invoke` bando rasti komandą pagal nurodytą
vietą ir vykdo komandą, jei ji yra rasta.

Jei Rails nepripažįsta komandos, ji perduoda valdymą Rake
komandai su tuo pačiu pavadinimu.

Kaip matyti, `Rails::Command` automatiškai rodo pagalbos išvestį, jei `namespace`
yra tuščias.

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

Su `server` komanda, Rails toliau vykdo šį kodą:

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

Šis failas pakeis į Rails šakninį katalogą (kelias du katalogus aukštyn
nuo `APP_PATH`, kuris rodo į `config/application.rb`), bet tik jei
`config.ru` failas nerastas. Tada paleidžiama `Rails::Server` klasė.

### `actionpack/lib/action_dispatch.rb`

Action Dispatch yra Rails karkaso maršrutizavimo komponentas.
Jis prideda funkcionalumą, tokią kaip maršrutizavimas, sesija ir bendrosios tarpinės programinės įrangos.

### `rails/commands/server/server_command.rb`

`Rails::Server` klasė yra apibrėžiama šiame faile paveldinti iš
`Rack::Server`. Kai yra iškviesta `Rails::Server.new`, tai iškviečia `initialize`
metodą `rails/commands/server/server_command.rb` faile:

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
Pirma, iškviečiamas `super`, kuris iškviečia `initialize` metodą `Rack::Server` klasėje.

### Rack: `lib/rack/server.rb`

`Rack::Server` klasė atsakinga už bendrą serverio sąsają visoms Rack pagrindinėms aplikacijoms, kurios dabar yra dalis iš Rails.

`initialize` metodas `Rack::Server` klasėje tiesiog nustato keletą kintamųjų:

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

Šiuo atveju, `Rails::Command::ServerCommand#server_options` metodo grąžinimo reikšmė bus priskirta `options` kintamajam.
Kai vykdomos eilutės if sąlygoje, bus nustatyti keletas objekto kintamieji.

`server_options` metodas `Rails::Command::ServerCommand` klasėje apibrėžtas taip:

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

Reikšmė bus priskirta objekto kintamajam `@options`.

Baigus `super` vykdymą `Rack::Server` klasėje, grįžtama į `rails/commands/server/server_command.rb` failą. Šiuo metu, `set_environment` metodas yra iškviestas `Rails::Server` objekto kontekste.

```ruby
module Rails
  module Server
    def set_environment
      ENV["RAILS_ENV"] ||= options[:environment]
    end
  end
end
```

Baigus `initialize` vykdymą, grįžtama į serverio komandą, kurioje yra reikalaujamas `APP_PATH` (kuris buvo nustatytas anksčiau).

### `config/application`

Kai vykdoma `require APP_PATH`, įkeliamas `config/application.rb` failas (atminkite, kad `APP_PATH` yra apibrėžtas `bin/rails` faile). Šis failas yra jūsų aplikacijoje ir jį galite keisti pagal savo poreikius.

### `Rails::Server#start`

Baigus `config/application` įkėlimą, iškviečiamas `server.start` metodas. Šis metodas apibrėžtas taip:

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

Šis metodas sukuria `INT` signalų gaudyklą, todėl jei nutraukiate serverį naudodami `CTRL-C`, procesas bus baigtas.
Kaip matome iš kodo čia, jis sukuria `tmp/cache`, `tmp/pids` ir `tmp/sockets` direktorijas. Tada, jei `bin/rails server` yra iškviestas su `--dev-caching` parametru, įjungiamas kešavimas vystymosi aplinkoje. Galiausiai, jis iškviečia `wrapped_app` metodą, kuris yra atsakingas už Rack aplikacijos kūrimą, prieš sukurdamas ir priskirdamas `ActiveSupport::Logger` objektą.

`super` metodas iškviečia `Rack::Server.start`, kuris pradeda savo apibrėžimą taip:

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

Įdomus dalykas Rails aplikacijai yra paskutinė eilutė, `server.run`. Čia vėl susiduriame su `wrapped_app` metodu, kurį šį kartą išnagrinėsime išsamiau (nors jis jau buvo vykdytas anksčiau ir tuo pačiu metu buvo memoized).

```ruby
module Rack
  class Server
    def wrapped_app
      @wrapped_app ||= build_app app
    end
  end
end
```

`app` metodas čia yra apibrėžtas taip:

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

`options[:config]` reikšmė pagal nutylėjimą yra `config.ru`, kuriame yra šis kodas:

```ruby
# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
```

`Rack::Builder.parse_file` metodas čia ima šio `config.ru` failo turinį ir jį analizuoja naudodamas šį kodą:

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
`Rack::Builder` klasės `initialize` metodas priims bloką ir jį vykdys `Rack::Builder` objekte.
Tai yra vieta, kurioje dauguma Rails inicializavimo procesų vyksta.
Pirmiausia vykdoma `require` eilutė `config.ru` faile, skirta `config/environment.rb` failui:

```ruby
require_relative "config/environment"
```

### `config/environment.rb`

Šis failas yra bendras failas, kurį reikalauja `config.ru` (`bin/rails server`) ir Passenger. Čia susitinka šie du būdai paleisti serverį; viskas iki šios vietos buvo susiję su Rack ir Rails paruošimu.

Šis failas prasideda nuo `config/application.rb` failo reikalavimo:

```ruby
require_relative "application"
```

### `config/application.rb`

Šis failas reikalauja `config/boot.rb` failo:

```ruby
require_relative "boot"
```

Tačiau tik jei jis dar nebuvo reikalaujamas anksčiau, kas būtų atvejis `bin/rails server`,
bet **nebūtų** atvejis su Passenger.

Tada prasideda smagumas!

Įkeliant Rails
-------------

Kitas `config/application.rb` eilutė yra:

```ruby
require "rails/all"
```

### `railties/lib/rails/all.rb`

Šis failas atsakingas už visų atskirų Rails karkasų reikalavimą:

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

Čia įkeliami visi Rails karkasai ir taip padaromi
prieinami aplikacijai. Mes nesigilinsime į tai, kas vyksta
kiekvienoje iš tų karkasų, bet jūsų raginama tai išbandyti ir
tyrinėti patiems.

Šiuo metu tiesiog turėkite omenyje, kad bendros funkcijos, pvz., Rails varikliai,
I18n ir Rails konfigūracija, čia yra apibrėžiami.

### Grįžtame prie `config/environment.rb`

Likusi `config/application.rb` dalis apibrėžia konfigūraciją
`Rails::Application`, kuri bus naudojama, kai aplikacija bus visiškai
inicializuota. Kai `config/application.rb` baigia įkelti Rails ir apibrėžia
aplikacijos vardų erdvę, grįžtame prie `config/environment.rb`. Čia
aplikacija yra inicializuojama su `Rails.application.initialize!`, kas yra
apibrėžta `rails/application.rb` faile.

### `railties/lib/rails/application.rb`

`initialize!` metodas atrodo taip:

```ruby
def initialize!(group = :default) # :nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

Aplikaciją galite inicializuoti tik vieną kartą. Railtie [inicializatoriai](configuring.html#initializers)
yra vykdomi per `run_initializers` metodą, kuris yra apibrėžtas
`railties/lib/rails/initializable.rb` faile:

```ruby
def run_initializers(group = :default, *args)
  return if instance_variable_defined?(:@ran)
  initializers.tsort_each do |initializer|
    initializer.run(*args) if initializer.belongs_to?(group)
  end
  @ran = true
end
```

Pats `run_initializers` kodas yra sudėtingas. Tai, ką Rails čia daro, yra
peržiūri visus klasės paveldėjimus, ieškodamas tokių, kurie atsako į
`initializers` metodą. Tada jie yra rūšiuojami pagal pavadinimą ir vykdomi.
Pavyzdžiui, `Engine` klasė padaro visus variklius prieinamus,
teikdama jiems `initializers` metodą.

`Rails::Application` klasė, kaip apibrėžta `railties/lib/rails/application.rb`
faile, apibrėžia `bootstrap`, `railtie` ir `finisher` inicializatorius. `bootstrap` inicializatoriai
paruošia aplikaciją (pvz., inicializuoja žurnalo įrašyklę), o `finisher`
inicializatoriai (pvz., sukuria tarpinės programinės įrangos paketą) yra vykdomi paskutiniai. `railtie`
inicializatoriai yra inicializatoriai, kurie buvo apibrėžti `Rails::Application`
paties ir yra vykdomi tarp `bootstrap` ir `finishers`.

PASTABA: Nesusipainiokite bendrų Railtie inicializatorių su [load_config_initializers](configuring.html#using-initializer-files)
inicializatoriaus atveju arba su tuo susijusiais konfigūracijos inicializatoriais `config/initializers` aplanke.

Tai padarius, grįžtame prie `Rack::Server`.

### Rack: lib/rack/server.rb

Paskutinį kartą palikome, kai buvo apibrėžiamas `app` metodas:

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

Šiuo metu `app` yra pats Rails aplikacija (tarpinė programinė įranga), ir kas
vyksta toliau, tai yra, kad Rack iškvies visus pateiktus tarpinius programinės įrangos paketus:

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

Atminkite, kad `build_app` buvo iškviestas (naudojant `wrapped_app`) paskutinėje `Rack::Server#start` eilutėje.
Taip tai atrodė, kai palikome:

```ruby
server.run wrapped_app, options, &blk
```

Šiuo metu `server.run` įgyvendinimas priklausys nuo
naudojamo serverio. Pavyzdžiui, jei naudojate Puma, čia yra,
kaip atrodytų `run` metodas:

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
Mes neįsijungsime į serverio konfigūraciją patį, bet tai yra paskutinis mūsų kelionės per Rails inicializavimo procesą gabalas.

Šis aukšto lygio apžvalga padės jums suprasti, kada ir kaip vykdomas jūsų kodas ir apskritai tapti geresniu Rails programuotoju. Jei vis tiek norite sužinoti daugiau, Rails šaltinio kodas pats tikriausiai yra geriausias kitas žingsnis.
