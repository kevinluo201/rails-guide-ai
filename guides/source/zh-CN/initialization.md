**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 884491931bd3d9e6c8896768960f0475
Rails 初始化过程
==================

本指南解释了 Rails 初始化过程的内部工作原理。这是一份非常深入的指南，建议给有经验的 Rails 开发者阅读。

阅读完本指南后，您将了解到：

* 如何使用 `bin/rails server`。
* Rails 初始化序列的时间线。
* 引导序列中不同文件的引入位置。
* 如何定义和使用 Rails::Server 接口。

--------------------------------------------------------------------------------

本指南详细介绍了启动默认 Rails 应用程序的 Ruby on Rails 栈所需的每个方法调用，并逐步详细解释了每个部分。在本指南中，我们将重点关注当您执行 `bin/rails server` 启动应用程序时发生的情况。

注意：本指南中的路径是相对于 Rails 或 Rails 应用程序的，除非另有说明。

提示：如果您想在浏览 Rails [源代码](https://github.com/rails/rails) 的同时跟随阅读，我们建议您使用 `t` 键绑定在 GitHub 内打开文件查找器，以便快速查找文件。

启动！
------

让我们开始启动和初始化应用程序。Rails 应用程序通常通过运行 `bin/rails console` 或 `bin/rails server` 来启动。

### `bin/rails`

该文件内容如下：

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative "../config/boot"
require "rails/commands"
```

`APP_PATH` 常量将在 `rails/commands` 中使用。此处引用的 `config/boot` 文件是我们应用程序中的 `config/boot.rb` 文件，负责加载 Bundler 并进行设置。

### `config/boot.rb`

`config/boot.rb` 包含以下内容：

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # 设置 Gemfile 中列出的 gem。
```

在标准的 Rails 应用程序中，有一个 `Gemfile` 文件，声明了应用程序的所有依赖项。`config/boot.rb` 将 `ENV['BUNDLE_GEMFILE']` 设置为该文件的位置。如果存在 `Gemfile`，则需要 `bundler/setup`。此 require 用于由 Bundler 配置 Gemfile 依赖项的加载路径。

### `rails/commands.rb`

`config/boot.rb` 完成后，下一个被引入的文件是 `rails/commands`，它有助于扩展别名。在当前情况下，`ARGV` 数组只包含 `server`，将被传递过去：

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

如果我们使用的是 `s` 而不是 `server`，Rails 将使用此处定义的 `aliases` 来查找匹配的命令。

### `rails/command.rb`

当输入 Rails 命令时，`invoke` 方法尝试查找给定命名空间的命令，并在找到命令时执行该命令。

如果 Rails 无法识别命令，则将控制权移交给 Rake 来运行同名的任务。

如上所示，如果 `namespace` 为空，`Rails::Command` 会自动显示帮助输出。

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

对于 `server` 命令，Rails 还会运行以下代码：

```ruby
module Rails
  module Command
    class ServerCommand < Base # :nodoc:
      def perform
        extract_environment_option_from_argument
        set_application_directory!
        prepare_restart

        Rails::Server.new(server_options).tap do |server|
          # 在服务器设置环境后，要求应用程序进行加载以传播 --environment 选项。
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

该文件将切换到 Rails 根目录（即 `APP_PATH` 所指向的 `config/application.rb` 的两个目录上级路径），但仅当找不到 `config.ru` 文件时才会这样做。然后启动 `Rails::Server` 类。

### `actionpack/lib/action_dispatch.rb`

Action Dispatch 是 Rails 框架的路由组件。它添加了路由、会话和常见中间件等功能。

### `rails/commands/server/server_command.rb`

`Rails::Server` 类在此文件中定义，继承自 `Rack::Server`。当调用 `Rails::Server.new` 时，会调用 `rails/commands/server/server_command.rb` 中的 `initialize` 方法：

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
首先，调用`super`，它会调用`Rack::Server`上的`initialize`方法。

### Rack: `lib/rack/server.rb`

`Rack::Server`负责为所有基于Rack的应用程序提供一个通用的服务器接口，其中Rails现在是其中的一部分。

`Rack::Server`中的`initialize`方法只是简单地设置了几个变量：

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

在这种情况下，`Rails::Command::ServerCommand#server_options`的返回值将被赋给`options`。
当if语句内的行被评估时，将设置一些实例变量。

`Rails::Command::ServerCommand`中的`server_options`方法定义如下：

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

该值将被赋给实例变量`@options`。

在`Rack::Server`的`super`完成后，我们跳回到`rails/commands/server/server_command.rb`。此时，在`Rails::Server`对象的上下文中调用`set_environment`。

```ruby
module Rails
  module Server
    def set_environment
      ENV["RAILS_ENV"] ||= options[:environment]
    end
  end
end
```

在`initialize`完成后，我们跳回到服务器命令中，其中需要`APP_PATH`（之前设置过）。

### `config/application`

当执行`require APP_PATH`时，将加载`config/application.rb`（请记住，`APP_PATH`在`bin/rails`中定义）。此文件存在于您的应用程序中，您可以根据需要自由更改。

### `Rails::Server#start`

在加载`config/application`之后，调用`server.start`。该方法定义如下：

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

该方法为`INT`信号创建了一个陷阱，因此如果您按下`CTRL-C`终止服务器，它将退出进程。
从这里的代码中可以看出，它会创建`tmp/cache`、`tmp/pids`和`tmp/sockets`目录。然后，如果使用`--dev-caching`调用`bin/rails server`，它会在开发环境中启用缓存。最后，它调用`wrapped_app`来创建并分配一个`ActiveSupport::Logger`的实例。

`super`方法将调用`Rack::Server.start`，它的定义如下：

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

对于Rails应用程序来说，最有趣的部分是最后一行的`server.run`。在这里，我们再次遇到了`wrapped_app`方法，这次我们将更详细地探索它（尽管它之前已经执行过，因此现在已经被记忆化）。

```ruby
module Rack
  class Server
    def wrapped_app
      @wrapped_app ||= build_app app
    end
  end
end
```

这里的`app`方法定义如下：

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

`options[:config]`的默认值为`config.ru`，其中包含以下内容：

```ruby
# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
```


这里的`Rack::Builder.parse_file`方法使用这个`config.ru`文件的内容，并使用以下代码进行解析：

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
`Rack::Builder`的`initialize`方法将接受此处的块并在`Rack::Builder`的实例中执行它。
这是Rails的大部分初始化过程发生的地方。
在`config.ru`中，`config/environment.rb`的`require`行是第一个运行的：

```ruby
require_relative "config/environment"
```

### `config/environment.rb`

这个文件是`config.ru`（`bin/rails server`）和Passenger所需的公共文件。这是运行服务器的这两种方式相遇的地方；在此之前的一切都是Rack和Rails的设置。

这个文件开始时要求`config/application.rb`：

```ruby
require_relative "application"
```

### `config/application.rb`

这个文件要求`config/boot.rb`：

```ruby
require_relative "boot"
```

但只有在之前没有要求过的情况下才会这样，这在`bin/rails server`中是这样的，
但在Passenger中则不是这样。

然后开始有趣的部分！

加载Rails
-------------

`config/application.rb`中的下一行是：

```ruby
require "rails/all"
```

### `railties/lib/rails/all.rb`

这个文件负责要求Rails的所有单独的框架：

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

这是加载所有Rails框架的地方，从而使其可用于应用程序。我们不会详细介绍每个框架内部发生的事情，但鼓励您自己尝试并探索它们。

现在，只需记住常见的功能，如Rails引擎、I18n和Rails配置都在这里定义。

### 回到`config/environment.rb`

`config/application.rb`的其余部分定义了`Rails::Application`的配置，一旦应用程序完全初始化，就会使用它。当`config/application.rb`完成加载Rails并定义应用程序命名空间后，我们回到`config/environment.rb`。在这里，使用`Rails.application.initialize!`初始化应用程序，该方法在`rails/application.rb`中定义。

### `railties/lib/rails/application.rb`

`initialize!`方法如下所示：

```ruby
def initialize!(group = :default) # :nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

您只能初始化一次应用程序。Railtie [initializers](configuring.html#initializers)通过`run_initializers`方法运行，该方法在`railties/lib/rails/initializable.rb`中定义：

```ruby
def run_initializers(group = :default, *args)
  return if instance_variable_defined?(:@ran)
  initializers.tsort_each do |initializer|
    initializer.run(*args) if initializer.belongs_to?(group)
  end
  @ran = true
end
```

`run_initializers`代码本身很棘手。Rails在这里做的是遍历所有类祖先，寻找那些响应`initializers`方法的类。然后按名称对祖先进行排序，并运行它们。例如，`Engine`类将通过在其上提供`initializers`方法使所有引擎可用。

`Rails::Application`类在`railties/lib/rails/application.rb`中定义了`bootstrap`、`railtie`和`finisher`初始化器。`bootstrap`初始化器准备应用程序（如初始化日志记录器），而`finisher`初始化器（如构建中间件堆栈）最后运行。`railtie`初始化器是在`Rails::Application`本身上定义的初始化器，在`bootstrap`和`finishers`之间运行。

注意：不要将整体的Railtie初始化器与[load_config_initializers](configuring.html#using-initializer-files)初始化器实例或其关联的`config/initializers`中的配置初始化器混淆。

完成后，我们回到`Rack::Server`。

### Rack: lib/rack/server.rb

上次我们离开时，正在定义`app`方法：

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

此时，`app`就是Rails应用程序本身（一个中间件），接下来Rack将调用所有提供的中间件：

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

记住，`build_app`被调用（由`wrapped_app`）在`Rack::Server#start`的最后一行。当时它看起来是这样的：

```ruby
server.run wrapped_app, options, &blk
```

此时，`server.run`的实现将取决于您使用的服务器。例如，如果您使用的是Puma，`run`方法将如下所示：

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
我们不会深入研究服务器配置本身，但这是我们在Rails初始化过程中的最后一部分。

这个高级概述将帮助您了解代码何时以及如何执行，并成为一个更好的Rails开发者。如果您仍然想了解更多，Rails源代码本身可能是下一步最好的去处。
