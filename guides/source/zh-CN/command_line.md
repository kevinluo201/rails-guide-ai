**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 7dbd0564d604e07d111b2a827bef559f
Rails命令行
======================

阅读本指南后，您将了解以下内容：

* 如何创建Rails应用程序。
* 如何生成模型、控制器、数据库迁移和单元测试。
* 如何启动开发服务器。
* 如何通过交互式shell实验对象。

--------------------------------------------------------------------------------

注意：本教程假设您已经通过阅读[开始使用Rails指南](getting_started.html)掌握了基本的Rails知识。

创建Rails应用程序
--------------------

首先，让我们使用`rails new`命令创建一个简单的Rails应用程序。

我们将使用这个应用程序来玩耍和发现本指南中描述的所有命令。

信息：如果您还没有安装rails gem，请键入`gem install rails`进行安装。

### `rails new`

我们将传递给`rails new`命令的第一个参数是应用程序名称。

```bash
$ rails new my_app
     create
     create  README.md
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

Rails将为这样一个微小的命令设置大量的东西！现在我们拥有了整个Rails目录结构，其中包含我们运行简单应用程序所需的所有代码。

如果您希望跳过某些要生成的文件或跳过某些库，可以将以下任何参数附加到您的`rails new`命令：

| 参数                    | 描述                                                 |
| ----------------------- | ----------------------------------------------------------- |
| `--skip-git`            | 跳过git init、.gitignore和.gitattributes               |
| `--skip-docker`         | 跳过Dockerfile、.dockerignore和bin/docker-entrypoint    |
| `--skip-keeps`          | 跳过源代码控制的.keep文件                             |
| `--skip-action-mailer`  | 跳过Action Mailer文件                                    |
| `--skip-action-mailbox` | 跳过Action Mailbox gem                                     |
| `--skip-action-text`    | 跳过Action Text gem                                        |
| `--skip-active-record`  | 跳过Active Record文件                                    |
| `--skip-active-job`     | 跳过Active Job                                             |
| `--skip-active-storage` | 跳过Active Storage文件                                   |
| `--skip-action-cable`   | 跳过Action Cable文件                                     |
| `--skip-asset-pipeline` | 跳过Asset Pipeline                                         |
| `--skip-javascript`     | 跳过JavaScript文件                                       |
| `--skip-hotwire`        | 跳过Hotwire集成                                    |
| `--skip-jbuilder`       | 跳过jbuilder gem                                           |
| `--skip-test`           | 跳过测试文件                                             |
| `--skip-system-test`    | 跳过系统测试文件                                      |
| `--skip-bootsnap`       | 跳过bootsnap gem                                           |

这些只是`rails new`接受的一些选项。要获取完整的选项列表，请键入`rails new --help`。

### 预配置不同的数据库

在创建新的Rails应用程序时，您可以选择指定应用程序将使用的数据库类型。这将为您节省几分钟的时间，当然也会减少许多按键。

让我们看看`--database=postgresql`选项对我们有什么影响：

```bash
$ rails new petstore --database=postgresql
      create
      create  app/controllers
      create  app/helpers
...
```

让我们看看它在我们的`config/database.yml`中放了什么：

```yaml
# PostgreSQL. Versions 9.3 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On macOS with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On Windows:
#   gem install pg
#       Choose the win32 build.
#       Install PostgreSQL and put its /bin directory on your path.
#
# Configure Using Gemfile
# gem "pg"
#
default: &default
  adapter: postgresql
  encoding: unicode

  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: petstore_development
...
```

它生成了一个与我们选择的PostgreSQL相对应的数据库配置。

命令行基础知识
-------------------

有一些命令对于您日常使用Rails非常重要。按照您可能使用它们的顺序，它们是：

* `bin/rails console`
* `bin/rails server`
* `bin/rails test`
* `bin/rails generate`
* `bin/rails db:migrate`
* `bin/rails db:create`
* `bin/rails routes`
* `bin/rails dbconsole`
* `rails new app_name`

您可以通过键入`rails --help`获取可用的rails命令列表，这通常取决于您当前的目录。每个命令都有一个描述，应该可以帮助您找到所需的内容。

```bash
$ rails --help
Usage:
  bin/rails COMMAND [options]

You must specify a command. The most common commands are:

  generate     Generate new code (short-cut alias: "g")
  console      Start the Rails console (short-cut alias: "c")
  server       Start the Rails server (short-cut alias: "s")
  ...

All commands can be run with -h (or --help) for more information.

In addition to those commands, there are:
about                               List versions of all Rails ...
assets:clean[keep]                  Remove old compiled assets
assets:clobber                      Remove compiled assets
assets:environment                  Load asset compile environment
assets:precompile                   Compile all the assets ...
...
db:fixtures:load                    Load fixtures into the ...
db:migrate                          Migrate the database ...
db:migrate:status                   Display status of migrations
db:rollback                         Roll the schema back to ...
db:schema:cache:clear               Clears a db/schema_cache.yml file
db:schema:cache:dump                Create a db/schema_cache.yml file
db:schema:dump                      Create a database schema file (either db/schema.rb or db/structure.sql ...
db:schema:load                      Load a database schema file (either db/schema.rb or db/structure.sql ...
db:seed                             Load the seed data ...
db:version                          Retrieve the current schema ...
...
restart                             Restart app by touching ...
tmp:create                          Create tmp directories ...
```
### `bin/rails server`

`bin/rails server`命令启动一个名为Puma的Web服务器，它与Rails捆绑在一起。每当您想通过Web浏览器访问应用程序时，都会使用它。

只需运行`bin/rails server`，我们就可以运行我们的新的Rails应用程序：

```bash
$ cd my_app
$ bin/rails server
=> Booting Puma
=> Rails 7.0.0 application starting in development
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Version 3.12.1 (ruby 2.5.7-p206), codename: Llamas in Pajamas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
```

只需三个命令，我们就可以在3000端口上启动一个监听的Rails服务器。打开您的浏览器并访问[http://localhost:3000](http://localhost:3000)，您将看到一个基本的运行中的Rails应用程序。

INFO: 您还可以使用别名"s"来启动服务器：`bin/rails s`。

可以使用`-p`选项在不同的端口上运行服务器。可以使用`-e`选项更改默认的开发环境。

```bash
$ bin/rails server -e production -p 4000
```

`-b`选项将Rails绑定到指定的IP，默认为localhost。通过传递`-d`选项，可以将服务器作为守护进程运行。

### `bin/rails generate`

`bin/rails generate`命令使用模板创建许多东西。运行`bin/rails generate`命令本身会列出可用的生成器列表：

INFO: 您还可以使用别名"g"来调用生成器命令：`bin/rails g`。

```bash
$ bin/rails generate
Usage:
  bin/rails generate GENERATOR [args] [options]

...
...

Please choose a generator below.

Rails:
  assets
  channel
  controller
  generator
  ...
  ...
```

注意：您可以通过生成器gem、插件的部分以及自己创建的方式安装更多的生成器！

使用生成器将通过编写**样板代码**（为应用程序工作所必需的代码）节省大量时间。

让我们使用控制器生成器创建自己的控制器。但是我们应该使用什么命令？让我们询问生成器：

INFO：所有Rails控制台实用程序都有帮助文本。与大多数*nix实用程序一样，您可以尝试在末尾添加`--help`或`-h`，例如`bin/rails server --help`。

```bash
$ bin/rails generate controller
Usage:
  bin/rails generate controller NAME [action action] [options]

...
...

Description:
    ...

    要在模块中创建控制器，请将控制器名称指定为路径，例如'parent_module/controller_name'。

    ...

Example:
    `bin/rails generate controller CreditCards open debit credit close`

    具有URL（如/credit_cards/debit）的信用卡控制器。
        控制器：app/controllers/credit_cards_controller.rb
        测试：test/controllers/credit_cards_controller_test.rb
        视图：app/views/credit_cards/debit.html.erb [...]
        助手：app/helpers/credit_cards_helper.rb
```

控制器生成器期望以`generate controller ControllerName action1 action2`的形式传递参数。让我们创建一个名为**Greetings**的控制器，其中包含一个名为**hello**的动作，它会对我们说一些好话。

```bash
$ bin/rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get 'greetings/hello'
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke    test_unit
```

这个生成器生成了什么？它确保我们的应用程序中有一堆目录，并创建了一个控制器文件、一个视图文件、一个功能测试文件、一个视图的帮助程序、一个JavaScript文件和一个样式表文件。

查看控制器并稍作修改（在`app/controllers/greetings_controller.rb`中）：

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Hello, how are you today?"
  end
end
```

然后修改视图，以显示我们的消息（在`app/views/greetings/hello.html.erb`中）：

```erb
<h1>A Greeting for You!</h1>
<p><%= @message %></p>
```

使用`bin/rails server`启动服务器。

```bash
$ bin/rails server
=> Booting Puma...
```

URL将为[http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello)。

INFO：对于普通的Rails应用程序，您的URL通常会遵循http://(host)/(controller)/(action)的模式，而像http://(host)/(controller)这样的URL将命中该控制器的**index**动作。

Rails还提供了用于数据模型的生成器。

```bash
$ bin/rails generate model
Usage:
  bin/rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

...

ActiveRecord options:
      [--migration], [--no-migration]        # 指示何时生成迁移
                                             # 默认值：true

...

Description:
    生成一个新的模型。将模型名称（CamelCased或under_scored）和可选的属性对列表作为参数传递。

...
```

注意：有关`type`参数可用字段类型的列表，请参阅`SchemaStatements`模块的`add_column`方法的[API文档](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column)。`index`参数为该列生成相应的索引。
但是，我们不直接生成一个模型（我们稍后会这样做），而是先设置一个脚手架。在Rails中，**脚手架**是一个完整的模型集合，包括用于该模型的数据库迁移、用于操作它的控制器、用于查看和操作数据的视图，以及每个上述部分的测试套件。

我们将设置一个名为“HighScore”的简单资源，用于跟踪我们玩的视频游戏的最高分。

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20190416145729_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    create      test/system/high_scores_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke      test_unit
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    create      app/views/high_scores/_high_score.json.jbuilder
```

生成器为HighScore创建了模型、视图、控制器、**资源**路由和数据库迁移（创建了`high_scores`表），并为它们添加了测试。

迁移要求我们进行**迁移**，即运行一些Ruby代码（来自上面输出的`20190416145729_create_high_scores.rb`文件）来修改数据库的模式。哪个数据库呢？当我们运行`bin/rails db:migrate`命令时，Rails将为我们创建的SQLite3数据库。我们将在下面详细讨论该命令。

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

信息：让我们谈谈单元测试。单元测试是测试和断言代码的代码。在单元测试中，我们取一小部分代码，比如一个模型的方法，测试其输入和输出。单元测试是你的朋友。当你意识到当你对代码进行单元测试时，你的生活质量将大大提高时，你会感到更好。真的。请访问[测试指南](testing.html)以深入了解单元测试。

让我们看看Rails为我们创建的界面。

```bash
$ bin/rails server
```

在浏览器中打开[http://localhost:3000/high_scores](http://localhost:3000/high_scores)，现在我们可以创建新的最高分（Space Invaders上的55,160分！）

### `bin/rails console`

`console`命令允许您从命令行与Rails应用程序进行交互。在底层，`bin/rails console`使用IRB，所以如果您以前使用过它，您会感到非常熟悉。这对于使用代码测试快速想法和在不触及网站的情况下在服务器端更改数据非常有用。

信息：您还可以使用别名“c”调用控制台：`bin/rails c`。

您可以指定`console`命令应该在哪个环境中运行。

```bash
$ bin/rails console -e staging
```

如果您希望在不更改任何数据的情况下测试一些代码，可以通过调用`bin/rails console --sandbox`来实现。

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 7.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### `app`和`helper`对象

在`bin/rails console`中，您可以访问`app`和`helper`实例。

使用`app`方法，您可以访问命名路由助手，并进行请求。

```irb
irb> app.root_path
=> "/"

irb> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

使用`helper`方法，可以访问Rails和应用程序的辅助方法。

```irb
irb> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

irb> helper.my_custom_helper
=> "my custom helper"
```

### `bin/rails dbconsole`

`bin/rails dbconsole`会确定您正在使用的数据库，并将您带入该数据库所使用的命令行界面（还会确定要给它的命令行参数）。它支持MySQL（包括MariaDB）、PostgreSQL和SQLite3。

信息：您还可以使用别名“db”调用dbconsole：`bin/rails db`。

如果您使用多个数据库，默认情况下，`bin/rails dbconsole`将连接到主数据库。您可以使用`--database`或`--db`指定要连接的数据库：

```bash
$ bin/rails dbconsole --database=animals
```

### `bin/rails runner`

`runner`以非交互方式在Rails上下文中运行Ruby代码。例如：

```bash
$ bin/rails runner "Model.long_running_method"
```

信息：您还可以使用别名“r”调用runner：`bin/rails r`。

您可以使用`-e`开关指定`runner`命令应该在哪个环境中运行。

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```
您甚至可以使用runner执行文件中编写的Ruby代码。

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `bin/rails destroy`

将`destroy`视为`generate`的相反操作。它会找出generate所做的操作并撤销它。

INFO: 您还可以使用别名"d"来调用destroy命令：`bin/rails d`。

```bash
$ bin/rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```

```bash
$ bin/rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

### `bin/rails about`

`bin/rails about`提供有关Ruby、RubyGems、Rails、Rails子组件、应用程序文件夹、当前Rails环境名称、应用程序数据库适配器和模式版本的版本号信息。当您需要寻求帮助、检查安全补丁是否会影响您，或者需要一些现有Rails安装的统计信息时，它非常有用。

```bash
$ bin/rails about
关于您的应用程序环境
Rails版本             7.0.0
Ruby版本              2.7.0 (x86_64-linux)
RubyGems版本          2.7.3
Rack版本              2.0.4
JavaScript运行时       Node.js (V8)
中间件:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
应用程序根目录          /home/foobar/my_app
环境               development
数据库适配器          sqlite3
数据库模式版本   20180205173523
```

### `bin/rails assets:`

您可以使用`bin/rails assets:precompile`预编译`app/assets`中的资源，并使用`bin/rails assets:clean`删除旧的编译资源。`assets:clean`命令允许在新资源构建时仍然链接到旧资源的滚动部署。

如果您想完全清除`public/assets`，可以使用`bin/rails assets:clobber`。

### `bin/rails db:`

`db:`命名空间中最常用的命令是`migrate`和`create`，尝试所有迁移rails命令（`up`、`down`、`redo`、`reset`）将会很有回报。`bin/rails db:version`在故障排除时非常有用，它会告诉您数据库的当前版本。

有关迁移的更多信息，请参阅[Migrations](active_record_migrations.html)指南。

### `bin/rails notes`

`bin/rails notes`会搜索您的代码，查找以特定关键字开头的注释。您可以参考`bin/rails notes --help`以获取有关用法的信息。

默认情况下，它会在`app`、`config`、`db`、`lib`和`test`目录中搜索扩展名为`.builder`、`.rb`、`.rake`、`.yml`、`.yaml`、`.ruby`、`.css`、`.js`和`.erb`的文件中的FIXME、OPTIMIZE和TODO注释。

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

#### 注释

您可以使用`--annotations`参数传递特定的注释。默认情况下，它会搜索FIXME、OPTIMIZE和TODO。
请注意，注释区分大小写。

```bash
$ bin/rails notes --annotations FIXME RELEASE
app/controllers/admin/users_controller.rb:
  * [101] [RELEASE] We need to look at this before next release
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 17] [FIXME]
```

#### 标签

您可以通过使用`config.annotations.register_tags`添加更多默认标签来搜索。它接收一个标签列表。

```ruby
config.annotations.register_tags("DEPRECATEME", "TESTME")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] do A/B testing on this
  * [ 42] [TESTME] this needs more functional tests
  * [132] [DEPRECATEME] ensure this method is deprecated in next release
```

#### 目录

您可以通过使用`config.annotations.register_directories`添加更多默认搜索目录。它接收一个目录名称列表。

```ruby
config.annotations.register_directories("spec", "vendor")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```

#### 扩展名

您可以通过使用`config.annotations.register_extensions`添加更多默认搜索的文件扩展名。它接收一个扩展名列表，以及与之匹配的正则表达式。

```ruby
config.annotations.register_extensions("scss", "sass") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/assets/stylesheets/application.css.sass:
  * [ 34] [TODO] Use pseudo element for this class

app/assets/stylesheets/application.css.scss:
  * [  1] [TODO] Split into multiple components

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```
### `bin/rails routes`

`bin/rails routes` 将列出所有已定义的路由，这对于跟踪应用程序中的路由问题或者对你尝试熟悉的应用程序的 URL 进行概览非常有用。

### `bin/rails test`

INFO: 有关在 Rails 中进行单元测试的详细描述，请参见 [A Guide to Testing Rails Applications](testing.html)

Rails 自带一个名为 minitest 的测试框架。Rails 的稳定性归功于测试的使用。`test:` 命名空间中可用的命令有助于运行您希望编写的不同测试。

### `bin/rails tmp:`

`Rails.root/tmp` 目录类似于 *nix 的 /tmp 目录，用于存放临时文件，如进程 ID 文件和缓存操作。

`tmp:` 命名空间中的命令将帮助您清除和创建 `Rails.root/tmp` 目录：

* `bin/rails tmp:cache:clear` 清除 `tmp/cache`。
* `bin/rails tmp:sockets:clear` 清除 `tmp/sockets`。
* `bin/rails tmp:screenshots:clear` 清除 `tmp/screenshots`。
* `bin/rails tmp:clear` 清除所有缓存、套接字和截图文件。
* `bin/rails tmp:create` 创建用于缓存、套接字和进程 ID 的临时目录。

### 杂项

* `bin/rails initializers` 按照 Rails 调用它们的顺序打印出所有已定义的初始化器。
* `bin/rails middleware` 列出为您的应用启用的 Rack 中间件堆栈。
* `bin/rails stats` 用于查看代码统计信息，显示诸如 KLOC（千行代码）和代码与测试比例等内容。
* `bin/rails secret` 将为您提供一个伪随机密钥，用于会话密钥。
* `bin/rails time:zones:all` 列出 Rails 知道的所有时区。

### 自定义 Rake 任务

自定义的 Rake 任务具有 `.rake` 扩展名，并放置在 `Rails.root/lib/tasks` 目录中。您可以使用 `bin/rails generate task` 命令创建这些自定义 Rake 任务。

```ruby
desc "我是一个简短但全面的描述，用于我的酷炫任务"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # 在这里编写你的魔法
  # 允许任何有效的 Ruby 代码
end
```

要向自定义 Rake 任务传递参数：

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

您可以通过将它们放置在命名空间中来对任务进行分组：

```ruby
namespace :db do
  desc "这个任务什么也不做"
  task :nothing do
    # 真的，什么也不做
  end
end
```

任务的调用方式如下：

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # 整个参数字符串应该用引号括起来
$ bin/rails "task_name[value 1,value2,value3]" # 用逗号分隔多个参数
$ bin/rails db:nothing
```

如果您需要与应用程序模型进行交互、执行数据库查询等操作，您的任务应该依赖于 `environment` 任务，该任务将加载您的应用程序代码。

```ruby
task task_that_requires_app_code: [:environment] do
  User.create!
end
```
