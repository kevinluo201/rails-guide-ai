**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 884491931bd3d9e6c8896768960f0475
Railsの初期化プロセス
=======================

このガイドでは、Railsの初期化プロセスの内部について説明します。
これは非常に詳細なガイドであり、上級のRails開発者におすすめです。

このガイドを読み終えると、以下のことがわかります。

* `bin/rails server`の使い方
* Railsの初期化シーケンスのタイムライン
* ブートシーケンスで異なるファイルがどこで必要とされているか
* Rails::Serverインターフェースの定義と使用方法

--------------------------------------------------------------------------------

このガイドでは、デフォルトのRailsアプリケーションを起動するために必要な
すべてのメソッド呼び出しを詳細に説明します。このガイドでは、`bin/rails server`
を実行した場合に何が起こるかに焦点を当てます。

注意：このガイドのパスは、それ以外が指定されていない限り、RailsまたはRailsアプリケーションに対して相対的です。

ヒント：Railsの[ソースコード](https://github.com/rails/rails)をブラウズしながら進む場合は、GitHub内でファイルファインダーを開くために`t`キーのバインディングを使用することをおすすめします。

起動！
-------

アプリを起動して初期化するためには、通常`bin/rails console`または`bin/rails server`を実行します。

### `bin/rails`

このファイルは次のようになっています：

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative "../config/boot"
require "rails/commands"
```

`APP_PATH`定数は後で`rails/commands`で使用されます。ここで参照されている`config/boot`ファイルは、アプリケーションの`config/boot.rb`ファイルであり、Bundlerの読み込みと設定を行う責任があります。

### `config/boot.rb`

`config/boot.rb`には次の内容が含まれています：

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
```

標準のRailsアプリケーションでは、`Gemfile`にアプリケーションのすべての依存関係が宣言されています。`config/boot.rb`は`ENV['BUNDLE_GEMFILE']`をこのファイルの場所に設定します。`Gemfile`が存在する場合、`bundler/setup`が必要とされます。このrequireは、BundlerがGemfileの依存関係のためのロードパスを設定するために使用されます。

### `rails/commands.rb`

`config/boot.rb`が完了した後、次に必要なファイルは`rails/commands`です。このファイルはエイリアスの展開を支援します。現在の場合、`ARGV`配列には単に`server`が含まれています：

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

もし`server`の代わりに`s`を使用した場合、Railsはここで定義されたエイリアスを使用して一致するコマンドを見つけます。

### `rails/command.rb`

Railsコマンドを入力すると、`invoke`は指定された名前空間のコマンドを検索し、見つかった場合はコマンドを実行しようとします。

もしRailsがコマンドを認識しない場合、同じ名前のタスクを実行するためにRakeに制御を渡します。

表示されるように、`Rails::Command`は`namespace`が空の場合に自動的にヘルプ出力を表示します。

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

`server`コマンドを使用する場合、Railsはさらに次のコードを実行します：

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

このファイルはRailsのルートディレクトリに変更します（`APP_PATH`は`config/application.rb`を指し示す2つ上のディレクトリのパスです）、ただし`config.ru`ファイルが見つからない場合のみです。その後、`Rails::Server`クラスを起動します。

### `actionpack/lib/action_dispatch.rb`

Action DispatchはRailsフレームワークのルーティングコンポーネントです。
ルーティング、セッション、共通ミドルウェアなどの機能を追加します。

### `rails/commands/server/server_command.rb`

`Rails::Server`クラスは、`Rack::Server`を継承してこのファイルで定義されています。`Rails::Server.new`が呼び出されると、`rails/commands/server/server_command.rb`の`initialize`メソッドが呼び出されます：

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
まず、`super`が呼び出され、`Rack::Server`の`initialize`メソッドが呼び出されます。

### Rack: `lib/rack/server.rb`

`Rack::Server`は、すべてのRackベースのアプリケーションに共通のサーバーインターフェースを提供する責任を持っており、Railsもその一部です。

`Rack::Server`の`initialize`メソッドは、単純にいくつかの変数を設定します。

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

この場合、`Rails::Command::ServerCommand#server_options`の戻り値が`options`に割り当てられます。
if文内の行が評価されると、いくつかのインスタンス変数が設定されます。

`Rails::Command::ServerCommand`の`server_options`メソッドは次のように定義されています。

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

その値はインスタンス変数`@options`に割り当てられます。

`Rack::Server`の`super`が終了した後、`rails/commands/server/server_command.rb`に戻ります。この時点で、`set_environment`が`Rails::Server`オブジェクトのコンテキスト内で呼び出されます。

```ruby
module Rails
  module Server
    def set_environment
      ENV["RAILS_ENV"] ||= options[:environment]
    end
  end
end
```

`initialize`が終了した後、サーバーコマンドに戻り、`APP_PATH`（前に設定された）が必要とされます。

### `config/application`

`require APP_PATH`が実行されると、`config/application.rb`がロードされます（`APP_PATH`は`bin/rails`で定義されていることを思い出してください）。このファイルはアプリケーションに存在し、必要に応じて変更することができます。

### `Rails::Server#start`

`config/application`がロードされた後、`server.start`が呼び出されます。このメソッドは次のように定義されています。

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

このメソッドは`INT`シグナルのトラップを作成し、サーバーを`CTRL-C`で終了するとプロセスが終了します。
ここで、`tmp/cache`、`tmp/pids`、`tmp/sockets`ディレクトリを作成します。また、`bin/rails server`が`--dev-caching`オプションで呼び出された場合、開発環境でキャッシュを有効にします。最後に、Rackアプリを作成し、`ActiveSupport::Logger`のインスタンスを作成および割り当てます。

`super`メソッドは`Rack::Server.start`を呼び出し、次のように定義されます。

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

Railsアプリにとって興味深い部分は、最後の行の`server.run`です。ここで、再び`wrapped_app`メソッドに遭遇しますが、今度はもう少し探索します（すでに実行されており、そのためすでにメモ化されています）。

```ruby
module Rack
  class Server
    def wrapped_app
      @wrapped_app ||= build_app app
    end
  end
end
```

ここでの`app`メソッドは次のように定義されています。

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

`options[:config]`の値はデフォルトで`config.ru`になります。このファイルには次のコードが含まれています。

```ruby
# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
```

ここでの`Rack::Builder.parse_file`メソッドは、この`config.ru`ファイルの内容を取得し、次のコードを使用して解析します。

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
`Rack::Builder`の`initialize`メソッドは、ここでブロックを受け取り、それを`Rack::Builder`のインスタンス内で実行します。
ここがRailsの初期化プロセスの大部分が行われる場所です。
`config.ru`の`config/environment.rb`の`require`行が最初に実行されます：

```ruby
require_relative "config/environment"
```

### `config/environment.rb`

このファイルは、`config.ru`（`bin/rails server`）とPassengerで必要とされる共通のファイルです。ここで、これらの2つのサーバーの実行方法が結合されます。このポイントまでのすべては、RackとRailsのセットアップです。

このファイルは、`config/application.rb`を要求して始まります：

```ruby
require_relative "application"
```

### `config/application.rb`

このファイルは、`config/boot.rb`を要求しています：

```ruby
require_relative "boot"
```

ただし、`bin/rails server`の場合は要求されていない場合に限りますが、Passengerの場合は要求されていません。

そして、楽しいことが始まります！

Railsの読み込み
-------------

`config/application.rb`の次の行は次のようになります：

```ruby
require "rails/all"
```

### `railties/lib/rails/all.rb`

このファイルは、Railsのすべての個々のフレームワークを要求する責任があります：

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

ここで、すべてのRailsフレームワークがロードされ、アプリケーションで利用できるようになります。それぞれのフレームワークの内部で何が起こっているかについては詳細には触れませんが、自分で探索してみることをお勧めします。

今のところ、Railsエンジン、I18n、およびRailsの設定などの共通の機能がここで定義されていることを覚えておいてください。

### `config/environment.rb`に戻る

`config/application.rb`の残りの部分では、アプリケーションが完全に初期化された後に使用される`Rails::Application`の設定が定義されます。`config/application.rb`がRailsをロードし、アプリケーションの名前空間を定義した後、`config/environment.rb`に戻ります。ここで、アプリケーションは`Rails.application.initialize!`で初期化されます。これは`rails/application.rb`で定義されています。

### `railties/lib/rails/application.rb`

`initialize!`メソッドは次のようになります：

```ruby
def initialize!(group = :default) # :nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

アプリケーションは一度しか初期化できません。`run_initializers`メソッドを介してRailtieの初期化子が実行されます。このメソッドは`railties/lib/rails/initializable.rb`で定義されています：

```ruby
def run_initializers(group = :default, *args)
  return if instance_variable_defined?(:@ran)
  initializers.tsort_each do |initializer|
    initializer.run(*args) if initializer.belongs_to?(group)
  end
  @ran = true
end
```

`run_initializers`メソッド自体はややトリッキーです。Railsがここで行っているのは、すべてのクラスの祖先をトラバースして、`initializers`メソッドに応答するクラスを探すことです。それから祖先を名前でソートし、実行します。たとえば、`Engine`クラスは、`initializers`メソッドを提供することですべてのエンジンを利用できるようにします。

`Rails::Application`クラスは、`railties/lib/rails/application.rb`で定義されているように、`bootstrap`、`railtie`、および`finisher`の初期化子を定義しています。`bootstrap`の初期化子はアプリケーションを準備します（ロガーの初期化など）、`finisher`の初期化子は最後に実行されます（ミドルウェアスタックの構築など）。`railtie`の初期化子は、`Rails::Application`自体で定義されている初期化子であり、`bootstrap`と`finisher`の間で実行されます。

注意：`railties/lib/rails/application.rb`で定義されている`load_config_initializers`初期化子インスタンス全体と、それに関連する`config/initializers`の設定初期化子とは異なることに注意してください。

これが終わったら、`Rack::Server`に戻ります。

### Rack: lib/rack/server.rb

前回は、`app`メソッドが定義されているところで終わりました：

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

この時点で、`app`はRailsアプリケーション自体（ミドルウェア）です。次に、Rackは提供されたすべてのミドルウェアを呼び出します：

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

ここで、`build_app`は（`wrapped_app`によって）`Rack::Server#start`の最後の行で呼び出されました。前回の状態では次のようになっていました：

```ruby
server.run wrapped_app, options, &blk
```

この時点で、`server.run`の実装は使用しているサーバーによって異なります。たとえば、Pumaを使用している場合、`run`メソッドは次のようになります：

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
サーバーの設定自体には立ち入りませんが、これがRailsの初期化プロセスの最後の部分です。

この高レベルの概要は、コードがいつ、どのように実行されるかを理解し、全体的に優れたRails開発者になるのに役立ちます。さらに詳しく知りたい場合は、おそらくRailsのソースコード自体が最適な参照先です。
