**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 884491931bd3d9e6c8896768960f0475
กระบวนการเริ่มต้น Rails
================================

เอกสารนี้อธิบายเกี่ยวกับกระบวนการเริ่มต้นใน Rails ซึ่งเป็นเอกสารที่ลึกซึ้งมากและแนะนำสำหรับนักพัฒนา Rails ระดับสูง

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีใช้ `bin/rails server`
* ลำดับของกระบวนการเริ่มต้นใน Rails
* ที่ไฟล์ต่าง ๆ ถูกต้องโหลดในกระบวนการเริ่มต้น
* วิธีการกำหนดและใช้งานอินเตอร์เฟซของ Rails::Server

--------------------------------------------------------------------------------

เอกสารนี้จะอธิบายเกี่ยวกับการเรียกใช้เมธอดที่จำเป็นทุกครั้งในกระบวนการเริ่มต้น Ruby on Rails สำหรับแอปพลิเคชัน Rails ที่มีค่าเริ่มต้น โดยอธิบายแต่ละส่วนอย่างละเอียดในขณะที่เดินทาง สำหรับเอกสารนี้ เราจะให้ความสนใจกับสิ่งที่เกิดขึ้นเมื่อคุณเรียกใช้ `bin/rails server` เพื่อเริ่มต้นแอปของคุณ

หมายเหตุ: พาธในเอกสารนี้เป็นพาธที่เกี่ยวข้องกับ Rails หรือแอปพลิเคชัน Rails ยกเว้นที่ระบุไว้เป็นอย่างอื่น

เคล็ดลับ: หากคุณต้องการติดตามข้อมูลในขณะที่เรียกดู [source code](https://github.com/rails/rails) ของ Rails เราขอแนะนำให้ใช้การผูกคีย์ `t` เพื่อเปิดตัวค้นหาไฟล์ภายใน GitHub และค้นหาไฟล์ได้อย่างรวดเร็ว

เริ่มต้น!
-------

เรามาเริ่มต้นและเริ่มต้นแอปกันเถอะ แอปพลิเคชัน Rails มักจะเริ่มต้นโดยการเรียกใช้ `bin/rails console` หรือ `bin/rails server`

### `bin/rails`

ไฟล์นี้มีโค้ดดังนี้:

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative "../config/boot"
require "rails/commands"
```

ค่าคงที่ `APP_PATH` จะถูกใช้ในภายหลังใน `rails/commands` ไฟล์ ไฟล์ `config/boot` ที่อ้างถึงที่นี่คือไฟล์ `config/boot.rb` ในแอปพลิเคชันของเราซึ่งรับผิดชอบในการโหลด Bundler และตั้งค่า

### `config/boot.rb`

`config/boot.rb` ประกอบด้วย:

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
```

ในแอปพลิเคชัน Rails มาตรฐาน จะมี `Gemfile` ที่ระบุความขึ้นอยู่กับแอปพลิเคชัน ไฟล์ `config/boot.rb` จะตั้งค่า `ENV['BUNDLE_GEMFILE']` เพื่อชี้ไปยังตำแหน่งของไฟล์นี้ หากมี `Gemfile` อยู่ จะต้องระบุ `bundler/setup` ไว้ คำสั่ง require นี้จะถูกใช้โดย Bundler เพื่อกำหนดค่าเส้นทางการโหลดสำหรับ dependencies ใน Gemfile ของคุณ

### `rails/commands.rb`

หลังจากที่ `config/boot.rb` เสร็จสิ้น ไฟล์ถัดไปที่ต้องการคือ `rails/commands` ซึ่งช่วยในการขยายตัวย่อ ในกรณีปัจจุบัน `ARGV` อาร์เรย์มีเพียง `server` เท่านั้นที่จะถูกส่งผ่าน:

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

หากเราใช้ `s` แทน `server` Rails จะใช้ `aliases` ที่กำหนดไว้ที่นี่เพื่อค้นหาคำสั่งที่ตรงกัน

### `rails/command.rb`

เมื่อพิมพ์คำสั่ง Rails `invoke` จะพยายามค้นหาคำสั่งสำหรับเนมสเปซที่กำหนดและดำเนินการคำสั่งหากพบ

หาก Rails ไม่รู้จักคำสั่ง จะส่งการควบคุมไปยัง Rake เพื่อเรียกใช้งานงานที่มีชื่อเดียวกัน

ตามที่แสดง  `Rails::Command` จะแสดงผลเองอัตโนมัติหาก `namespace` ว่างเปล่า

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
ด้วยคำสั่ง `server` Rails จะเรียกใช้โค้ดต่อไปนี้:

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

ไฟล์นี้จะเปลี่ยนเป็นไดเรกทอรีรูทของ Rails (เส้นทางสองระดับขึ้นจาก `APP_PATH` ซึ่งชี้ไปที่ `config/application.rb`) แต่เฉพาะกรณีที่ไม่พบไฟล์ `config.ru` จากนั้นจะเริ่มต้นคลาส `Rails::Server` 

### `actionpack/lib/action_dispatch.rb`

Action Dispatch เป็นส่วนของการเชื่อมต่อเส้นทางในกรอบการทำงานของ Rails มันเพิ่มฟังก์ชันเช่นการเชื่อมต่อเส้นทาง การเก็บเซสชัน และมิดเดิลแวร์ทั่วไป

### `rails/commands/server/server_command.rb`

คลาส `Rails::Server` ถูกกำหนดในไฟล์นี้โดยสืบทอดมาจาก `Rack::Server` เมื่อเรียกใช้ `Rails::Server.new` จะเรียกใช้เมธอด `initialize` ใน `rails/commands/server/server_command.rb`:

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

ก่อนอื่น `super` จะถูกเรียกซึ่งจะเรียกใช้เมธอด `initialize` ใน `Rack::Server`

### Rack: `lib/rack/server.rb`

`Rack::Server` รับผิดชอบในการให้เซิร์ฟเวอร์อินเตอร์เฟซทั่วไปสำหรับแอปพลิเคชันทั้งหมดที่ใช้ Rack ซึ่งเป็นส่วนหนึ่งของ Rails ตอนนี้

เมื่อเรียกใช้เมธอด `initialize` ใน `Rack::Server` จะตั้งค่าตัวแปรหลายตัวดังนี้:

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

ในกรณีนี้ ค่าที่ส่งคืนจาก `Rails::Command::ServerCommand#server_options` จะถูกกำหนดให้กับ `options` ของ `Rack::Server`
เมื่อคำสั่งใน if statement ถูกประเมิน ตัวแปรอินสแตนซ์หลายตัวจะถูกตั้งค่า

เมธอด `server_options` ใน `Rails::Command::ServerCommand` ถูกกำหนดดังนี้:

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

ค่าที่ได้จะถูกกำหนดให้กับตัวแปรอินสแตนซ์ `@options`

หลังจากที่ `super` สิ้นสุดลงใน `Rack::Server` เรากลับมาที่ `rails/commands/server/server_command.rb` ที่นี่ `set_environment` ถูกเรียกในบริบทของออบเจ็กต์ `Rails::Server`

```ruby
module Rails
  module Server
    def set_environment
      ENV["RAILS_ENV"] ||= options[:environment]
    end
  end
end
```

หลังจากที่ `initialize` สิ้นสุดลง เรากลับมาที่คำสั่ง server ที่ `APP_PATH` (ที่ถูกตั้งค่าไว้ก่อนหน้านี้) ถูกต้อง

### `config/application`

เมื่อ `require APP_PATH` ถูกเรียกใช้งาน `config/application.rb` จะถูกโหลด (จำไว้ว่า `APP_PATH` ถูกกำหนดค่าใน `bin/rails`) ไฟล์นี้อยู่ในแอปพลิเคชันของคุณและคุณสามารถเปลี่ยนแปลงได้ตามความต้องการของคุณ

### `Rails::Server#start`

หลังจากที่ `config/application` ถูกโหลด `server.start` ถูกเรียกใช้งาน เมธอดนี้ถูกกำหนดดังนี้:

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
วิธีนี้สร้างกับ `INT` สัญญาณ ดังนั้นหากคุณ `CTRL-C` เซิร์ฟเวอร์ มันจะออกจากกระบวนการ
เราสามารถเห็นจากโค้ดที่นี่ว่า มันจะสร้าง `tmp/cache`,
`tmp/pids`, และ `tmp/sockets` ไดเรกทอรี่ จากนั้นเราจะเปิดใช้งานการเก็บแคชในการพัฒนา
หากเรียกใช้ `bin/rails server` ด้วย `--dev-caching` ในที่สุดมันจะเรียกใช้ `wrapped_app` ซึ่งเป็น
ผู้รับผิดชอบในการสร้างแอป Rack ก่อนที่จะสร้างและกำหนดค่าอินสแตนซ์
ของ `ActiveSupport::Logger`.

เมธอด `super` จะเรียกใช้ `Rack::Server.start` ซึ่งเริ่มต้นการกำหนดดังนี้:

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

ส่วนที่น่าสนใจสำหรับแอป Rails คือบรรทัดสุดท้าย `server.run` ที่นี่เราพบกับเมธอด `wrapped_app` อีกครั้ง ซึ่งครั้งนี้
เรากำลังจะสำรวจเพิ่มเติม (แม้ว่าจะถูกดำเนินการก่อนหน้านี้แล้ว และ
ดังนั้นจึงถูกจำไว้ในขณะนี้).

```ruby
module Rack
  class Server
    def wrapped_app
      @wrapped_app ||= build_app app
    end
  end
end
```

เมธอด `app` ที่นี่ถูกกำหนดดังนี้:

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

ค่า `options[:config]` จะเริ่มต้นด้วย `config.ru` ซึ่งมีเนื้อหาดังนี้:

```ruby
# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
```


เมธอด `Rack::Builder.parse_file` ที่นี่จะนำเนื้อหาจากไฟล์ `config.ru` และแยกวิเคราะห์ด้วยโค้ดนี้:

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

เมธอด `initialize` ของ `Rack::Builder` จะใช้บล็อกนี้และดำเนินการด้วยตัวอย่างของ `Rack::Builder`.
นี่คือส่วนสำคัญส่วนใหญ่ของกระบวนการเตรียมการของ Rails
บรรทัด `require` สำหรับ `config/environment.rb` ใน `config.ru` เป็นบรรทัดแรกที่รัน:

```ruby
require_relative "config/environment"
```

### `config/environment.rb`

ไฟล์นี้เป็นไฟล์ที่ต้องการโดย `config.ru` (`bin/rails server`) และ Passenger. นี่คือสถานที่ที่วิธีสองวิธีเหล่านี้ในการเรียกใช้เซิร์ฟเวอร์พบกัน ทุกอย่างก่อนจุดนี้เป็นการตั้งค่า Rack และ Rails

ไฟล์นี้เริ่มต้นด้วยการต้องการ `config/application.rb`:

```ruby
require_relative "application"
```

### `config/application.rb`

ไฟล์นี้ต้องการ `config/boot.rb`:

```ruby
require_relative "boot"
```

แต่เฉพาะกรณีที่ไม่ได้ต้องการมาก่อนหน้านี้ ซึ่งจะเป็นกรณีของ `bin/rails server`
แต่ **ไม่** จะเป็นกรณีของ Passenger.

แล้วความสนุกเริ่มต้น!

โหลด Rails
-------------

บรรทัดถัดไปใน `config/application.rb` คือ:
```ruby
app = self.app
```

Now, `app` is passed to `build_app` and all the middlewares are called on it.
```ruby
server.run wrapped_app, options, &blk
```

ณ จุดนี้การดำเนินการของ `server.run` จะขึ้นอยู่กับเซิร์ฟเวอร์ที่คุณกำลังใช้ ตัวอย่างเช่น หากคุณกำลังใช้ Puma นี่คือวิธีการดำเนินการของเมธอด `run`:

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

เราจะไม่ลงรายละเอียดในการกำหนดค่าเซิร์ฟเวอร์เอง แต่นี่คือส่วนสุดท้ายของการเริ่มต้น Rails

ภาพรวมระดับสูงนี้จะช่วยให้คุณเข้าใจเมื่อโค้ดของคุณถูกเรียกใช้และวิธีการทำงานโดยรวม และทำให้คุณเป็นนักพัฒนา Rails ที่ดีขึ้น หากคุณยังต้องการทราบข้อมูลเพิ่มเติม รหัสต้นฉบับของ Rails เองเป็นที่ดีที่สุดที่คุณควรไปต่อ
