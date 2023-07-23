**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 884491931bd3d9e6c8896768960f0475
Rails 初始化過程
================

本指南解釋了 Rails 的初始化過程的內部工作原理。
這是一個非常深入的指南，建議給有經驗的 Rails 開發人員閱讀。

閱讀完本指南後，您將了解：

* 如何使用 `bin/rails server`。
* Rails 初始化序列的時間軸。
* 引導序列中不同文件的引用位置。
* 如何定義和使用 Rails::Server 接口。

--------------------------------------------------------------------------------

本指南將逐一介紹啟動默認 Rails 應用程序的 Ruby on Rails 堆棧所需的每個方法調用，並詳細解釋每個部分。在本指南中，我們將重點介紹當您執行 `bin/rails server` 启动應用程序時發生的情況。

注意：本指南中的路徑是相對於 Rails 或 Rails 應用程序的，除非另有說明。

提示：如果您想在瀏覽 Rails [源代碼](https://github.com/rails/rails)時跟著進行，我們建議您使用 `t` 鍵綁定在 GitHub 內打開文件查找器，以快速找到文件。

開始！
------

讓我們開始啟動和初始化應用程序。Rails 應用程序通常是通過運行 `bin/rails console` 或 `bin/rails server` 來啟動的。

### `bin/rails`

此文件如下所示：

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative "../config/boot"
require "rails/commands"
```

`APP_PATH` 常量稍後將在 `rails/commands` 中使用。此處引用的 `config/boot` 文件是我們應用程序中的 `config/boot.rb` 文件，負責加載 Bundler 並設置它。

### `config/boot.rb`

`config/boot.rb` 包含以下內容：

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # 設置 Gemfile 中列出的 gems。
```

在標準的 Rails 應用程序中，有一個 `Gemfile` 文件，它聲明了應用程序的所有依賴項。`config/boot.rb` 將 `ENV['BUNDLE_GEMFILE']` 設置為此文件的位置。如果存在 `Gemfile`，則需要 `bundler/setup`。此 require 用於由 Bundler 配置 Gemfile 的依賴項的加載路徑。

### `rails/commands.rb`

完成 `config/boot.rb` 後，下一個需要引用的文件是 `rails/commands`，它有助於擴展別名。在當前情況下，`ARGV` 數組只包含 `server`，將被傳遞：

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

如果我們使用的是 `s` 而不是 `server`，Rails 將使用此處定義的 `aliases` 找到匹配的命令。

### `rails/command.rb`

當輸入一個 Rails 命令時，`invoke` 方法會嘗試查找給定命名空間的命令並執行該命令。

如果 Rails 不認識該命令，它會將控制權交給 Rake 執行相同名稱的任務。

如上所示，`Rails::Command` 會在 `namespace` 為空時自動顯示幫助輸出。

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

對於 `server` 命令，Rails 還會運行以下代碼：

```ruby
module Rails
  module Command
    class ServerCommand < Base # :nodoc:
      def perform
        extract_environment_option_from_argument
        set_application_directory!
        prepare_restart

        Rails::Server.new(server_options).tap do |server|
          # 在 server 設置環境後，要求應用程序以傳播 --environment 選項。
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

此文件將切換到 Rails 根目錄（一個路徑，距離 `APP_PATH` 兩個目錄），但僅在找不到 `config.ru` 文件時才這樣做。然後，它啟動 `Rails::Server` 類。

### `actionpack/lib/action_dispatch.rb`

Action Dispatch 是 Rails 框架的路由組件。
它添加了路由、會話和常用中間件等功能。

### `rails/commands/server/server_command.rb`

在此文件中，通過繼承 `Rack::Server` 來定義 `Rails::Server` 類。當調用 `Rails::Server.new` 時，會調用 `rails/commands/server/server_command.rb` 中的 `initialize` 方法：

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
首先，`super` 被調用，它調用了 `Rack::Server` 上的 `initialize` 方法。

### Rack: `lib/rack/server.rb`

`Rack::Server` 負責為所有基於 Rack 的應用程序提供一個共同的服務器接口，而 Rails 現在是其中的一部分。

`Rack::Server` 中的 `initialize` 方法只是設置了幾個變量：

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

在這種情況下，`Rails::Command::ServerCommand#server_options` 的返回值將被賦值給 `options`。
當 if 語句內的行被評估時，將設置一些實例變量。

`Rails::Command::ServerCommand` 中的 `server_options` 方法定義如下：

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

該值將被賦值給實例變量 `@options`。

在 `Rack::Server` 中的 `super` 完成後，我們跳回到 `rails/commands/server/server_command.rb`。
此時，在 `Rails::Server` 對象的上下文中調用了 `set_environment`。

```ruby
module Rails
  module Server
    def set_environment
      ENV["RAILS_ENV"] ||= options[:environment]
    end
  end
end
```

在 `initialize` 完成後，我們跳回到服務器命令中，此時需要引入 `APP_PATH`（之前已經設置）。

### `config/application`

當執行 `require APP_PATH` 時，將加載 `config/application.rb`（請記住，`APP_PATH` 在 `bin/rails` 中定義）。
此文件存在於您的應用程序中，您可以根據需要自由更改。

### `Rails::Server#start`

在加載 `config/application` 後，將調用 `server.start`。該方法定義如下：

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

此方法為 `INT` 信號創建了一個陷阱，因此如果您使用 `CTRL-C` 關閉服務器，它將退出進程。
從這裡的代碼中可以看出，它將創建 `tmp/cache`、`tmp/pids` 和 `tmp/sockets` 目錄。
然後，如果使用 `--dev-caching` 參數調用 `bin/rails server`，它會在開發環境中啟用緩存。
最後，它調用了 `wrapped_app` 方法，該方法負責創建 Rack 應用程序，然後創建並分配一個 `ActiveSupport::Logger` 的實例。

`super` 方法將調用 `Rack::Server.start`，該方法的開始部分如下所示：

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

對於 Rails 應用程序來說，最有趣的部分是最後一行的 `server.run`。在這裡，我們再次遇到了 `wrapped_app` 方法，這次我們將更深入地探索它（即使它之前已經被執行並且已經被記憶化）。

```ruby
module Rack
  class Server
    def wrapped_app
      @wrapped_app ||= build_app app
    end
  end
end
```

這裡的 `app` 方法定義如下：

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

`options[:config]` 的值默認為 `config.ru`，其中包含以下內容：

```ruby
# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
```

這裡的 `Rack::Builder.parse_file` 方法將使用此 `config.ru` 文件的內容並使用以下代碼進行解析：

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
`Rack::Builder` 的 `initialize` 方法會接收這個區塊並在 `Rack::Builder` 的實例中執行它。
這是 Rails 大部分初始化過程發生的地方。
在 `config.ru` 中，`config/environment.rb` 的 `require` 行是第一個運行的：

```ruby
require_relative "config/environment"
```

### `config/environment.rb`

這個檔案是 `config.ru` (`bin/rails server`) 和 Passenger 都需要的共同檔案。這是兩種運行伺服器的方式相遇的地方；在這之前的一切都是 Rack 和 Rails 的設定。

這個檔案開始時會 `require` `config/application.rb`：

```ruby
require_relative "application"
```

### `config/application.rb`

這個檔案會 `require` `config/boot.rb`：

```ruby
require_relative "boot"
```

但只有在之前沒有被 `require` 過的情況下才會這樣，這在 `bin/rails server` 中是成立的，
但在 Passenger 中則**不成立**。

然後就開始有趣的事情了！

載入 Rails
-------------

`config/application.rb` 中的下一行是：

```ruby
require "rails/all"
```

### `railties/lib/rails/all.rb`

這個檔案負責 `require` Rails 的所有個別框架：

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

這是載入所有 Rails 框架的地方，並使其對應的應用程式可用。我們不會詳細介紹每個框架內部發生了什麼，但鼓勵你自己去探索。

現在，只需要記住這裡定義了常見功能，如 Rails 引擎、I18n 和 Rails 設定。

### 回到 `config/environment.rb`

`config/application.rb` 的其餘部分定義了完全初始化應用程式後將使用的 `Rails::Application` 的設定。當 `config/application.rb` 完成載入 Rails 並定義應用程式命名空間後，我們回到 `config/environment.rb`。在這裡，應用程式使用 `Rails.application.initialize!` 進行初始化，這在 `rails/application.rb` 中定義。

### `railties/lib/rails/application.rb`

`initialize!` 方法如下所示：

```ruby
def initialize!(group = :default) # :nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

一個應用程式只能初始化一次。Railtie [initializers](configuring.html#initializers) 會通過 `run_initializers` 方法運行，該方法在 `railties/lib/rails/initializable.rb` 中定義：

```ruby
def run_initializers(group = :default, *args)
  return if instance_variable_defined?(:@ran)
  initializers.tsort_each do |initializer|
    initializer.run(*args) if initializer.belongs_to?(group)
  end
  @ran = true
end
```

`run_initializers` 本身的程式碼有些複雜。Rails 在這裡遍歷所有類的祖先，尋找那些回應 `initializers` 方法的類。然後按名稱對祖先進行排序並運行它們。例如，`Engine` 類將通過在其上提供 `initializers` 方法使所有引擎可用。

`Rails::Application` 類在 `railties/lib/rails/application.rb` 中定義，它定義了 `bootstrap`、`railtie` 和 `finisher` 初始器。`bootstrap` 初始器準備應用程式（例如初始化記錄器），而 `finisher` 初始器（例如構建中介軟體堆疊）最後運行。`railtie` 初始器是在 `Rails::Application` 自身上定義的初始器，它們在 `bootstrap` 和 `finishers` 之間運行。

注意：不要將 Railtie 初始器整體與 [load_config_initializers](configuring.html#using-initializer-files) 初始器實例或其相關的 `config/initializers` 中的設定初始器混淆。

完成後，我們回到 `Rack::Server`。

### Rack: lib/rack/server.rb

上次我們離開時，正在定義 `app` 方法：

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

此時，`app` 就是 Rails 應用程式本身（一個中介軟體），接下來 Rack 會呼叫所有提供的中介軟體：

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

記住，`build_app` 是在 `Rack::Server#start` 的最後一行被呼叫的（由 `wrapped_app` 呼叫）。
當我們離開時，它看起來是這樣的：

```ruby
server.run wrapped_app, options, &blk
```

此時，`server.run` 的實現將取決於你使用的伺服器。例如，如果你使用 Puma，`run` 方法會如下所示：

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
我們不會深入探討伺服器配置本身，但這是我們在Rails初始化過程中的最後一個部分。

這個高層次的概述將幫助您了解代碼何時以及如何執行，並成為一個更好的Rails開發人員。如果您仍然想要了解更多，Rails源代碼本身可能是下一步最好的去處。
