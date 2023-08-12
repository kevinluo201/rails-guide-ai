**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 884491931bd3d9e6c8896768960f0475
레일즈 초기화 프로세스
=======================

이 가이드는 레일즈의 초기화 프로세스에 대한 내부 동작을 설명합니다.
이 가이드는 매우 깊이 있는 가이드이며 고급 레일즈 개발자를 위해 권장됩니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* `bin/rails server`를 사용하는 방법.
* 레일즈 초기화 순서의 타임라인.
* 부트 순서에서 다른 파일이 필요한 위치.
* Rails::Server 인터페이스가 어떻게 정의되고 사용되는지.

--------------------------------------------------------------------------------

이 가이드는 기본 레일즈 애플리케이션의 루비 온 레일즈 스택을 부팅하기 위해 필요한 모든 메소드 호출을 따라가며 각 부분을 자세히 설명합니다. 이 가이드에서는 앱을 부팅하기 위해 `bin/rails server`를 실행했을 때 무슨 일이 일어나는지에 초점을 맞출 것입니다.

참고: 이 가이드에서의 경로는 레일즈나 레일즈 애플리케이션을 기준으로 상대적인 경로입니다.

파일을 실행해 봅시다!
---------------------

앱을 부팅하고 초기화하기 위해 시작해 봅시다. 레일즈 애플리케이션은 일반적으로 `bin/rails console` 또는 `bin/rails server`를 실행하여 시작됩니다.

### `bin/rails`

이 파일은 다음과 같습니다:

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative "../config/boot"
require "rails/commands"
```

`APP_PATH` 상수는 나중에 `rails/commands`에서 사용될 것입니다. 여기서 참조된 `config/boot` 파일은 애플리케이션의 `config/boot.rb` 파일로, Bundler를 로드하고 설정하는 역할을 합니다.

### `config/boot.rb`

`config/boot.rb`에는 다음이 포함되어 있습니다:

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
```

표준 레일즈 애플리케이션에서는 `Gemfile`에 애플리케이션의 모든 종속성을 선언합니다. `config/boot.rb`은 `ENV['BUNDLE_GEMFILE']`을 이 파일의 위치로 설정합니다. `Gemfile`이 존재하는 경우 `bundler/setup`이 필요합니다. 이 require는 Bundler가 Gemfile의 종속성에 대한 로드 경로를 구성하기 위해 사용됩니다.

### `rails/commands.rb`

`config/boot.rb`이 완료되면 다음으로 필요한 파일은 `rails/commands`입니다. 이 파일은 별칭을 확장하는 데 도움을 줍니다. 현재 경우에는 `ARGV` 배열에는 단순히 `server`가 포함되어 있습니다:

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

`server` 대신 `s`를 사용했다면, 레일즈는 여기에서 정의된 별칭을 사용하여 일치하는 명령을 찾았을 것입니다.

### `rails/command.rb`

레일즈 명령을 입력하면 `invoke`가 주어진 네임스페이스에 대한 명령을 찾아 실행하려고 시도합니다.

레일즈가 명령을 인식하지 못하면 같은 이름의 태스크를 실행하기 위해 Rake에게 통제를 넘깁니다.

위의 코드에서 보여주는대로, `Rails::Command`는 `namespace`가 비어있는 경우 자동으로 도움말 출력을 표시합니다.

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

`server` 명령을 사용하면 레일즈는 다음 코드를 실행합니다:

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

이 파일은 레일즈 루트 디렉토리로 변경됩니다(`APP_PATH`는 `config/application.rb`를 가리키는 두 디렉토리 위의 경로), 그러나 `config.ru` 파일이 발견되지 않은 경우에만 변경됩니다. 그런 다음 `Rails::Server` 클래스를 시작합니다.

### `actionpack/lib/action_dispatch.rb`

Action Dispatch는 레일즈 프레임워크의 라우팅 구성 요소입니다.
라우팅, 세션 및 공통 미들웨어와 같은 기능을 추가합니다.

### `rails/commands/server/server_command.rb`

`Rails::Server` 클래스는 이 파일에서 `Rack::Server`를 상속하여 정의됩니다. `Rails::Server.new`가 호출되면 `rails/commands/server/server_command.rb`의 `initialize` 메소드가 호출됩니다:

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
먼저, `super`는 `Rack::Server`의 `initialize` 메소드를 호출합니다.

### Rack: `lib/rack/server.rb`

`Rack::Server`는 모든 Rack 기반 애플리케이션에 대한 공통 서버 인터페이스를 제공하는 역할을 합니다. 이제 Rails도 그 일부로 포함됩니다.

`Rack::Server`의 `initialize` 메소드는 간단히 여러 변수를 설정합니다:

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

이 경우, `Rails::Command::ServerCommand#server_options`의 반환 값이 `options`에 할당됩니다.
if 문 내부의 라인이 평가될 때, 몇 가지 인스턴스 변수가 설정됩니다.

`Rails::Command::ServerCommand`의 `server_options` 메소드는 다음과 같이 정의됩니다:

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

값은 인스턴스 변수 `@options`에 할당됩니다.

`super`가 `Rack::Server`에서 완료되면 다시 `rails/commands/server/server_command.rb`로 돌아갑니다. 이 시점에서 `Rails::Server` 객체의 문맥에서 `set_environment`가 호출됩니다.

```ruby
module Rails
  module Server
    def set_environment
      ENV["RAILS_ENV"] ||= options[:environment]
    end
  end
end
```

`initialize`가 완료되면 서버 명령어로 돌아가서 이전에 설정한 `APP_PATH`가 필요합니다.

### `config/application`

`require APP_PATH`가 실행되면 `config/application.rb`이 로드됩니다 (`APP_PATH`는 `bin/rails`에서 정의되었음을 상기하세요). 이 파일은 애플리케이션에 따라 변경할 수 있는 파일입니다.

### `Rails::Server#start`

`config/application`이 로드된 후에 `server.start`가 호출됩니다. 이 메소드는 다음과 같이 정의됩니다:

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

이 메소드는 `INT` 신호에 대한 트랩을 생성하여 서버를 `CTRL-C`로 종료할 수 있도록 합니다.
여기서 코드를 보면 `tmp/cache`, `tmp/pids`, `tmp/sockets` 디렉토리를 생성합니다. 그런 다음, 개발 환경에서 캐싱을 활성화합니다.
마지막으로, Rack 앱을 생성하고 할당하기 전에 `wrapped_app`을 호출하여 `ActiveSupport::Logger`의 인스턴스를 생성합니다.

`super` 메소드는 `Rack::Server.start`를 호출하며, 다음과 같이 정의됩니다:

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

Rails 앱에 대한 흥미로운 부분은 마지막 라인인 `server.run`입니다. 여기서 우리는 이전에 실행되었고
이제 메모이즈된 `wrapped_app` 메소드를 다시 탐색하게 됩니다.

```ruby
module Rack
  class Server
    def wrapped_app
      @wrapped_app ||= build_app app
    end
  end
end
```

여기서 `app` 메소드는 다음과 같이 정의됩니다:

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

`options[:config]` 값은 기본적으로 `config.ru`로 설정되어 있으며, 다음 내용을 포함합니다:

```ruby
# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
```

여기서 `Rack::Builder.parse_file` 메소드는 `config.ru` 파일의 내용을 가져와서 다음 코드를 사용하여 구문 분석합니다:

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
`Rack::Builder`의 `initialize` 메소드는 여기에 있는 블록을 가져와 `Rack::Builder`의 인스턴스 내에서 실행합니다.
이곳에서 Rails의 대부분의 초기화 과정이 진행됩니다.
`config.ru`의 `config/environment.rb`에 대한 `require` 라인이 가장 먼저 실행됩니다:

```ruby
require_relative "config/environment"
```

### `config/environment.rb`

이 파일은 `config.ru` (`bin/rails server`)와 Passenger에서 필요한 공통 파일입니다. 이는 서버를 실행하는 두 가지 방법이 만나는 곳입니다. 이 지점 이전에는 Rack과 Rails 설정이 이루어져 왔습니다.

이 파일은 `config/application.rb`를 요구하는 것으로 시작합니다:

```ruby
require_relative "application"
```

### `config/application.rb`

이 파일은 `config/boot.rb`를 요구합니다:

```ruby
require_relative "boot"
```

하지만 `bin/rails server`에서는 이미 요구되었을 것이므로 이 경우에는 해당되지 않습니다. 그러나 Passenger에서는 해당됩니다.

그럼 이제 재미있는 부분이 시작됩니다!

Rails 로딩
-------------

`config/application.rb`의 다음 라인은 다음과 같습니다:

```ruby
require "rails/all"
```

### `railties/lib/rails/all.rb`

이 파일은 Rails의 모든 개별 프레임워크를 요구하는 역할을 합니다:

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

이곳에서 모든 Rails 프레임워크가 로드되고 애플리케이션에서 사용할 수 있게 됩니다. 각 프레임워크 내부에서 무슨 일이 일어나는지 자세히 설명하지는 않겠지만, 직접 탐색해보는 것을 권장합니다.

지금은 일반적인 기능인 Rails 엔진, I18n 및 Rails 설정이 여기에서 정의된다는 것만 기억하세요.

### 다시 `config/environment.rb`로 돌아가서

`config/application.rb`의 나머지 부분은 애플리케이션이 완전히 초기화된 후에 사용될 `Rails::Application`의 설정을 정의합니다. `config/application.rb`가 Rails를 로드하고 애플리케이션 네임스페이스를 정의한 후에는 다시 `config/environment.rb`로 돌아갑니다. 여기에서 애플리케이션은 `Rails.application.initialize!`로 초기화되며, 이는 `rails/application.rb`에서 정의됩니다.

### `railties/lib/rails/application.rb`

`initialize!` 메소드는 다음과 같이 구현되어 있습니다:

```ruby
def initialize!(group = :default) # :nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

애플리케이션은 한 번만 초기화할 수 있습니다. Railtie [initializers](configuring.html#initializers)는 `run_initializers` 메소드를 통해 실행됩니다. 이 메소드는 `railties/lib/rails/initializable.rb`에서 정의됩니다:

```ruby
def run_initializers(group = :default, *args)
  return if instance_variable_defined?(:@ran)
  initializers.tsort_each do |initializer|
    initializer.run(*args) if initializer.belongs_to?(group)
  end
  @ran = true
end
```

`run_initializers` 코드 자체는 까다롭습니다. Rails가 여기에서 하는 일은 `initializers` 메소드에 응답하는 클래스 조상을 모두 탐색하는 것입니다. 그런 다음 조상을 이름별로 정렬하고 실행합니다. 예를 들어, `Engine` 클래스는 엔진을 사용할 수 있게 하기 위해 `initializers` 메소드를 제공합니다.

`Rails::Application` 클래스는 `railties/lib/rails/application.rb`에서 정의되며 `bootstrap`, `railtie` 및 `finisher` 초기화를 정의합니다. `bootstrap` 초기화는 애플리케이션을 준비하는 작업 (예: 로거 초기화)을 수행하고, `finisher` 초기화는 마지막에 실행되는 작업 (예: 미들웨어 스택 빌드)을 수행합니다. `railtie` 초기화는 `Rails::Application` 자체에 정의된 초기화로 `bootstrap`과 `finisher` 사이에 실행됩니다.

참고: 전반적으로 Railtie 초기화와 [load_config_initializers](configuring.html#using-initializer-files) 초기화 인스턴스 또는 `config/initializers`의 관련된 설정 초기화와는 혼동하지 마세요.

이 작업이 완료되면 `Rack::Server`로 돌아갑니다.

### Rack: lib/rack/server.rb

마지막으로 `app` 메소드가 정의되는 시점에서 멈추었습니다:

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

이 시점에서 `app`은 Rails 앱 자체인 미들웨어이며, 그 다음 Rack은 제공된 모든 미들웨어를 호출합니다:

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

기억하세요, `build_app`은 `Rack::Server#start`의 마지막 줄에서 호출되었습니다. 우리가 멈춘 곳은 다음과 같았습니다:

```ruby
server.run wrapped_app, options, &blk
```

이 시점에서 `server.run`의 구현은 사용하는 서버에 따라 다릅니다. 예를 들어, Puma를 사용하는 경우 `run` 메소드는 다음과 같이 보일 것입니다:

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
서버 구성 자체에 대해 자세히 다루지는 않겠지만, 이것은 Rails 초기화 과정에서 마지막 단계입니다.

이 고수준 개요는 코드가 실행되는 시기와 방법을 이해하고, 전반적으로 더 나은 Rails 개발자가 되는 데 도움이 될 것입니다. 더 알고 싶다면, Rails 소스 코드 자체가 아마도 가장 좋은 참고 자료일 것입니다.
