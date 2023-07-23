**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 7dbd0564d604e07d111b2a827bef559f
Rails命令行
======================

閱讀完本指南後，您將會知道：

* 如何建立一個Rails應用程式。
* 如何生成模型、控制器、資料庫遷移和單元測試。
* 如何啟動開發伺服器。
* 如何透過互動式shell實驗物件。

--------------------------------------------------------------------------------

注意：本教程假設您已經通過閱讀[開始使用Rails指南](getting_started.html)獲得了基本的Rails知識。

建立一個Rails應用程式
--------------------

首先，讓我們使用`rails new`命令創建一個簡單的Rails應用程式。

我們將使用這個應用程式來玩耍和發現本指南中描述的所有命令。

資訊：如果您尚未安裝rails gem，可以輸入`gem install rails`來安裝。

### `rails new`

我們將傳遞給`rails new`命令的第一個參數是應用程式名稱。

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

Rails將為這麼一個微小的命令設置了大量的東西！我們現在擁有了整個Rails目錄結構，其中包含了運行我們簡單應用程式所需的所有代碼。

如果您希望跳過某些要生成的文件或跳過某些庫，可以將以下任何參數附加到您的`rails new`命令中：

| 參數                    | 描述                                                 |
| ----------------------- | ----------------------------------------------------------- |
| `--skip-git`            | 跳過git init、.gitignore和.gitattributes               |
| `--skip-docker`         | 跳過Dockerfile、.dockerignore和bin/docker-entrypoint    |
| `--skip-keeps`          | 跳過源控制的.keep文件                             |
| `--skip-action-mailer`  | 跳過Action Mailer文件                                    |
| `--skip-action-mailbox` | 跳過Action Mailbox gem                                     |
| `--skip-action-text`    | 跳過Action Text gem                                        |
| `--skip-active-record`  | 跳過Active Record文件                                    |
| `--skip-active-job`     | 跳過Active Job                                             |
| `--skip-active-storage` | 跳過Active Storage文件                                   |
| `--skip-action-cable`   | 跳過Action Cable文件                                     |
| `--skip-asset-pipeline` | 跳過Asset Pipeline                                         |
| `--skip-javascript`     | 跳過JavaScript文件                                       |
| `--skip-hotwire`        | 跳過Hotwire集成                                    |
| `--skip-jbuilder`       | 跳過jbuilder gem                                           |
| `--skip-test`           | 跳過測試文件                                             |
| `--skip-system-test`    | 跳過系統測試文件                                      |
| `--skip-bootsnap`       | 跳過bootsnap gem                                           |

這些只是`rails new`接受的一些選項。要查看完整的選項列表，輸入`rails new --help`。

### 預配置不同的資料庫

在創建新的Rails應用程式時，您可以選擇指定應用程式將使用的資料庫類型。這將為您節省幾分鐘的時間，當然也會減少許多按鍵。

讓我們看看`--database=postgresql`選項對我們的影響：

```bash
$ rails new petstore --database=postgresql
      create
      create  app/controllers
      create  app/helpers
...
```

讓我們看看它在我們的`config/database.yml`中放了什麼：

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

它生成了一個與我們選擇的PostgreSQL相對應的資料庫配置。

命令行基礎知識
-------------------

有一些命令對於您日常使用Rails是絕對至關重要的。按照您可能使用它們的順序，它們是：

* `bin/rails console`
* `bin/rails server`
* `bin/rails test`
* `bin/rails generate`
* `bin/rails db:migrate`
* `bin/rails db:create`
* `bin/rails routes`
* `bin/rails dbconsole`
* `rails new app_name`

您可以通過輸入`rails --help`來獲取可用的rails命令列表，這通常取決於您當前的目錄。每個命令都有一個描述，應該能幫助您找到所需的東西。

```bash
$ rails --help
使用方法：
  bin/rails COMMAND [options]

您必須指定一個命令。最常用的命令有：

  generate     生成新的代碼（縮寫： "g"）
  console      啟動Rails控制台（縮寫： "c"）
  server       啟動Rails伺服器（縮寫： "s"）
  ...

除了這些命令外，還有：
about                               列出所有Rails版本...
assets:clean[keep]                  刪除舊的編譯資產
assets:clobber                      刪除編譯的資產
assets:environment                  載入資產編譯環境
assets:precompile                   編譯所有資產...
...
db:fixtures:load                    將測試數據加載到...
db:migrate                          遷移資料庫...
db:migrate:status                   顯示遷移的狀態
db:rollback                         將模式回滾到...
db:schema:cache:clear               清除db/schema_cache.yml文件
db:schema:cache:dump                創建db/schema_cache.yml文件
db:schema:dump                      創建資料庫模式文件（db/schema.rb或db/structure.sql...
db:schema:load                      加載資料庫模式文件（db/schema.rb或db/structure.sql...
db:seed                             加載種子數據...
db:version                          檢索當前模式...
...
restart                             通過觸摸...
tmp:create                          創建tmp目錄...
```
### `bin/rails server`

`bin/rails server` 命令啟動一個名為 Puma 的網頁伺服器，Puma 是隨 Rails 捆綁提供的。您可以在任何時候通過網頁瀏覽器訪問應用程序時使用此命令。

只需執行 `bin/rails server`，我們就可以運行全新的 Rails 應用程序：

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

只需三個命令，我們就可以在 3000 端口上運行一個 Rails 伺服器。打開瀏覽器，訪問 [http://localhost:3000](http://localhost:3000)，您將看到一個基本的 Rails 應用程序運行。

INFO: 您也可以使用別名 "s" 來啟動伺服器：`bin/rails s`。

使用 `-p` 選項可以在不同的端口上運行伺服器。使用 `-e` 可以更改默認的開發環境。

```bash
$ bin/rails server -e production -p 4000
```

`-b` 選項將 Rails 綁定到指定的 IP，默認為 localhost。通過傳遞 `-d` 選項，可以將伺服器運行為守護進程。

### `bin/rails generate`

`bin/rails generate` 命令使用模板來創建許多東西。執行 `bin/rails generate` 命令本身將顯示可用的生成器列表：

INFO: 您也可以使用別名 "g" 來調用生成器命令：`bin/rails g`。

```bash
$ bin/rails generate
Usage:
  bin/rails generate GENERATOR [args] [options]

...
...

請從以下生成器中選擇。

Rails:
  assets
  channel
  controller
  generator
  ...
  ...
```

注意：您可以通過生成器 gem、插件的部分或自己創建生成器來安裝更多生成器！

使用生成器可以通過生成**樣板代碼**（必須的應用程序代碼）節省大量時間。

讓我們使用控制器生成器創建自己的控制器。但是應該使用哪個命令呢？讓我們問問生成器：

INFO：所有的 Rails 控制台工具都有幫助文本。與大多數 *nix 工具一樣，您可以嘗試在末尾添加 `--help` 或 `-h`，例如 `bin/rails server --help`。

```bash
$ bin/rails generate controller
Usage:
  bin/rails generate controller NAME [action action] [options]

...
...

Description:
    ...

    要在模塊內創建控制器，請將控制器名稱指定為類似 'parent_module/controller_name' 的路徑。

    ...

Example:
    `bin/rails generate controller CreditCards open debit credit close`

    帶有像 /credit_cards/debit 這樣的 URL 的信用卡控制器。
        控制器：app/controllers/credit_cards_controller.rb
        測試：test/controllers/credit_cards_controller_test.rb
        視圖：app/views/credit_cards/debit.html.erb [...]
        助手：app/helpers/credit_cards_helper.rb
```

控制器生成器期望以 `generate controller ControllerName action1 action2` 的形式提供參數。讓我們使用一個名為 **Greetings** 的控制器，並添加一個名為 **hello** 的動作，該動作將對我們說些好話。

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

這個生成器生成了什麼？它確保了我們的應用程序中有一堆目錄，並創建了一個控制器文件、一個視圖文件、一個功能測試文件、一個視圖的助手、一個 JavaScript 文件和一個樣式表文件。

檢查控制器並對其進行一些修改（在 `app/controllers/greetings_controller.rb` 中）：

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Hello, how are you today?"
  end
end
```

然後修改視圖，以顯示我們的消息（在 `app/views/greetings/hello.html.erb` 中）：

```erb
<h1>A Greeting for You!</h1>
<p><%= @message %></p>
```

使用 `bin/rails server` 啟動伺服器。

```bash
$ bin/rails server
=> Booting Puma...
```

URL 將為 [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello)。

INFO：對於一個普通的 Rails 應用程序，URL 通常遵循 http://(host)/(controller)/(action) 的模式，而像 http://(host)/(controller) 這樣的 URL 將觸發該控制器的 **index** 動作。

Rails 還提供了用於數據模型的生成器。

```bash
$ bin/rails generate model
Usage:
  bin/rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

...

ActiveRecord options:
      [--migration], [--no-migration]        # 指示何時生成遷移
                                             # 默認值：true

...

Description:
    生成一個新的模型。將模型名稱（CamelCased 或 under_scored）和一個可選的屬性對列表作為參數傳遞。

...
```

注意：有關 `type` 參數可用的字段類型列表，請參閱 `SchemaStatements` 模塊的 `add_column` 方法的 [API 文檔](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column)。`index` 參數將為該列生成相應的索引。
但是在直接生成模型之前（我们稍后会做），讓我們先設置一個脚手架。在Rails中，**脚手架**是一套完整的模型、用於該模型的數據庫遷移、用於操作它的控制器、用於查看和操作數據的視圖，以及上述每個部分的測試套件。

我們將設置一個名為“HighScore”的簡單資源，用於記錄我們在玩視頻遊戲時的最高分。

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

生成器為HighScore創建了模型、視圖、控制器、**資源**路由和數據庫遷移（創建了`high_scores`表）。並為這些部分添加了測試。

遷移要求我們進行**遷移**，也就是運行一些Ruby代碼（從上面的輸出中的`20190416145729_create_high_scores.rb`文件）來修改我們的數據庫架構。哪個數據庫？當我們運行`bin/rails db:migrate`命令時，Rails將為您創建的SQLite3數據庫。我們將在下面更詳細地討論該命令。

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

資訊：讓我們談談單元測試。單元測試是測試和斷言代碼的代碼。在單元測試中，我們對代碼的一小部分進行測試，比如模型的一個方法，並測試其輸入和輸出。單元測試是您的朋友。當您對單元測試代碼進行單元測試時，您的生活質量將大大提高。真的。請參閱[測試指南](testing.html)以深入了解單元測試。

讓我們看看Rails為我們創建的界面。

```bash
$ bin/rails server
```

在瀏覽器中打開[http://localhost:3000/high_scores](http://localhost:3000/high_scores)，現在我們可以創建新的高分（Space Invaders上的55,160分！）

### `bin/rails console`

`console`命令允許您從命令行與Rails應用程序進行交互。在底層，`bin/rails console`使用IRB，所以如果您以前使用過它，您會非常熟悉。這對於使用代碼測試快速想法並在不觸及網站的情況下在服務器端更改數據非常有用。

資訊：您還可以使用別名“c”來調用控制台：`bin/rails c`。

您可以指定`console`命令應運行的環境。

```bash
$ bin/rails console -e staging
```

如果您希望在不更改任何數據的情況下測試一些代碼，可以通過調用`bin/rails console --sandbox`來實現。

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 7.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### `app`和`helper`對象

在`bin/rails console`中，您可以訪問`app`和`helper`實例。

使用`app`方法，您可以訪問命名路由助手，並進行請求。

```irb
irb> app.root_path
=> "/"

irb> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

使用`helper`方法，可以訪問Rails和應用程序的幫助程序。

```irb
irb> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

irb> helper.my_custom_helper
=> "my custom helper"
```

### `bin/rails dbconsole`

`bin/rails dbconsole`會找出您使用的數據庫，並將您放入您將使用的命令行界面（並且還會找出要給它的命令行參數！）。它支持MySQL（包括MariaDB）、PostgreSQL和SQLite3。

資訊：您還可以使用別名“db”來調用dbconsole：`bin/rails db`。

如果您使用多個數據庫，`bin/rails dbconsole`將默認連接到主要數據庫。您可以使用`--database`或`--db`指定要連接的數據庫：

```bash
$ bin/rails dbconsole --database=animals
```

### `bin/rails runner`

`runner`以非交互方式在Rails上下文中運行Ruby代碼。例如：

```bash
$ bin/rails runner "Model.long_running_method"
```

資訊：您還可以使用別名“r”來調用runner：`bin/rails r`。

您可以使用`-e`開關指定`runner`命令應運行的環境。

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```

您甚至可以使用runner執行寫在檔案中的Ruby程式碼。

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `bin/rails destroy`

將`destroy`視為`generate`的相反操作。它會找出generate所做的事情並將其還原。

INFO: 您也可以使用別名"d"來呼叫destroy指令：`bin/rails d`。

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

`bin/rails about`提供有關Ruby、RubyGems、Rails、Rails子組件、應用程式資料夾、目前Rails環境名稱、應用程式的資料庫適配器和架構版本的版本號資訊。當您需要尋求幫助、檢查安全補丁是否會影響您，或者需要一些現有Rails安裝的統計資料時，它非常有用。

```bash
$ bin/rails about
關於您的應用程式環境
Rails 版本             7.0.0
Ruby 版本              2.7.0 (x86_64-linux)
RubyGems 版本          2.7.3
Rack 版本              2.0.4
JavaScript Runtime        Node.js (V8)
Middleware:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
應用程式根目錄          /home/foobar/my_app
環境               開發環境
資料庫適配器          sqlite3
資料庫架構版本   20180205173523
```

### `bin/rails assets:`

您可以使用`bin/rails assets:precompile`預編譯`app/assets`中的資源，並使用`bin/rails assets:clean`刪除較舊的編譯資源。`assets:clean`指令允許在新資源建立時仍連結到舊資源的滾動部署。

如果您想完全清除`public/assets`，可以使用`bin/rails assets:clobber`。

### `bin/rails db:`

`db:` Rails命名空間中最常見的命令是`migrate`和`create`，嘗試使用所有遷移Rails命令（`up`、`down`、`redo`、`reset`）將會很有價值。當排除故障時，`bin/rails db:version`非常有用，它會告訴您資料庫的當前版本。

有關遷移的更多資訊可以在[Migrations](active_record_migrations.html)指南中找到。

### `bin/rails notes`

`bin/rails notes`會搜索您的程式碼，尋找以特定關鍵字開頭的註解。您可以參考`bin/rails notes --help`以獲取有關使用方法的資訊。

默認情況下，它會在`app`、`config`、`db`、`lib`和`test`目錄中搜索擴充名為`.builder`、`.rb`、`.rake`、`.yml`、`.yaml`、`.ruby`、`.css`、`.js`和`.erb`的文件中的FIXME、OPTIMIZE和TODO註解。

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] 有其他方法可以做到這一點嗎？
  * [132] [FIXME] 下一次部署的高優先級

lib/school.rb:
  * [ 13] [OPTIMIZE] 重構此代碼以提高速度
  * [ 17] [FIXME]
```

#### 註解

您可以使用`--annotations`參數傳遞特定的註解。默認情況下，它會搜索FIXME、OPTIMIZE和TODO。

```bash
$ bin/rails notes --annotations FIXME RELEASE
app/controllers/admin/users_controller.rb:
  * [101] [RELEASE] 在下一個版本發布之前，我們需要檢查這個問題
  * [132] [FIXME] 下一次部署的高優先級

lib/school.rb:
  * [ 17] [FIXME]
```

#### 標籤

您可以使用`config.annotations.register_tags`添加更多要搜索的默認標籤。它接收一個標籤列表。

```ruby
config.annotations.register_tags("DEPRECATEME", "TESTME")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] 對此進行A/B測試
  * [ 42] [TESTME] 這需要更多的功能測試
  * [132] [DEPRECATEME] 確保此方法在下一個版本中被棄用
```

#### 目錄

您可以使用`config.annotations.register_directories`添加更多要搜索的默認目錄。它接收一個目錄名稱列表。

```ruby
config.annotations.register_directories("spec", "vendor")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] 有其他方法可以做到這一點嗎？
  * [132] [FIXME] 下一次部署的高優先級

lib/school.rb:
  * [ 13] [OPTIMIZE] 重構此代碼以提高速度
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] 驗證具有訂閱的使用者是否有效

vendor/tools.rb:
  * [ 56] [TODO] 擺脫這個依賴性
```

#### 擴展名

您可以使用`config.annotations.register_extensions`添加更多要搜索的默認檔案擴展名。它接收一個帶有相應正則表達式的擴展名列表。

```ruby
config.annotations.register_extensions("scss", "sass") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] 有其他方法可以做到這一點嗎？
  * [132] [FIXME] 下一次部署的高優先級

app/assets/stylesheets/application.css.sass:
  * [ 34] [TODO] 對這個類使用偽元素

app/assets/stylesheets/application.css.scss:
  * [  1] [TODO] 拆分為多個組件

lib/school.rb:
  * [ 13] [OPTIMIZE] 重構此代碼以提高速度
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] 驗證具有訂閱的使用者是否有效

vendor/tools.rb:
  * [ 56] [TODO] 擺脫這個依賴性
```
### `bin/rails routes`

`bin/rails routes` 會列出所有已定義的路由，這對於追蹤應用程式中的路由問題或熟悉應用程式中的 URL 提供了很好的概覽。

### `bin/rails test`

資訊：有關在 Rails 中進行單元測試的詳細說明，請參閱 [A Guide to Testing Rails Applications](testing.html)。

Rails 預設使用一個名為 minitest 的測試框架。Rails 的穩定性得益於測試的使用。`test:` 命名空間中的命令有助於執行不同的測試。

### `bin/rails tmp:`

`Rails.root/tmp` 目錄類似於 *nix 的 /tmp 目錄，用於存放暫存檔案，例如進程 ID 檔案和快取動作。

`tmp:` 命名空間中的命令將幫助您清除和建立 `Rails.root/tmp` 目錄：

* `bin/rails tmp:cache:clear` 清除 `tmp/cache`。
* `bin/rails tmp:sockets:clear` 清除 `tmp/sockets`。
* `bin/rails tmp:screenshots:clear` 清除 `tmp/screenshots`。
* `bin/rails tmp:clear` 清除所有快取、插座和螢幕截圖檔案。
* `bin/rails tmp:create` 建立用於快取、插座和進程 ID 的 tmp 目錄。

### 其他

* `bin/rails initializers` 以 Rails 調用它們的順序列印出所有已定義的初始化器。
* `bin/rails middleware` 列出應用程式啟用的 Rack 中介軟體堆疊。
* `bin/rails stats` 非常適合查看代碼統計資訊，例如 KLOC（千行代碼）和代碼與測試比例。
* `bin/rails secret` 將為您提供一個偽隨機金鑰，供您用於會話密鑰。
* `bin/rails time:zones:all` 列出 Rails 知道的所有時區。

### 自訂 Rake 任務

自訂的 Rake 任務使用 `.rake` 副檔名並放置在 `Rails.root/lib/tasks` 目錄中。您可以使用 `bin/rails generate task` 命令來創建這些自訂的 Rake 任務。

```ruby
desc "我是簡短但全面的描述我的酷炫任務"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # 在這裡進行所有的魔法
  # 允許任何有效的 Ruby 代碼
end
```

要將參數傳遞給自訂的 Rake 任務：

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

您可以通過將它們放置在命名空間中來分組任務：

```ruby
namespace :db do
  desc "此任務什麼都不做"
  task :nothing do
    # 真的什麼都不做
  end
end
```

執行任務的方式如下：

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # 整個參數字串應該用引號括起來
$ bin/rails "task_name[value 1,value2,value3]" # 使用逗號分隔多個參數
$ bin/rails db:nothing
```

如果您需要與應用程式模型互動、執行資料庫查詢等操作，您的任務應該依賴於 `environment` 任務，該任務將載入您的應用程式代碼。

```ruby
task task_that_requires_app_code: [:environment] do
  User.create!
end
```
