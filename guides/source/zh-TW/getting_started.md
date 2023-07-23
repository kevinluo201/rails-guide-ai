**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2cf37358fedc8b51ed3ab7f408ecfc76
Rails 入門指南
==========================

本指南介紹了如何使用 Ruby on Rails 開始並運行。

閱讀完本指南後，您將了解：

* 如何安裝 Rails，創建新的 Rails 應用程序，並將應用程序連接到數據庫。
* Rails 應用程序的一般佈局。
* MVC（模型、視圖、控制器）和 RESTful 設計的基本原則。
* 如何快速生成 Rails 應用程序的起始部分。

--------------------------------------------------------------------------------

指南假設
-----------------

本指南針對想要從頭開始創建 Rails 應用程序的初學者設計。它不假設您具有任何有關 Rails 的先前經驗。

Rails 是一個運行在 Ruby 編程語言上的 Web 應用程序框架。如果您之前沒有使用過 Ruby，直接學習 Rails 將會有一個非常陡峭的學習曲線。有幾個精選的在線資源列表可供學習 Ruby：

* [官方 Ruby 編程語言網站](https://www.ruby-lang.org/en/documentation/)
* [免費編程書籍列表](https://github.com/EbookFoundation/free-programming-books/blob/master/books/free-programming-books-langs.md#ruby)

請注意，一些資源雖然仍然很好，但涵蓋的是舊版本的 Ruby，可能不包括您在日常 Rails 開發中會看到的某些語法。

什麼是 Rails？
--------------

Rails 是一個用 Ruby 編程語言編寫的 Web 應用程序開發框架。它旨在通過對每個開發人員需要的東西做出假設，使編寫 Web 應用程序變得更加容易。它允許您寫更少的代碼，同時完成比其他語言和框架更多的工作。經驗豐富的 Rails 開發人員還報告說，它使 Web 應用程序開發更有趣。

Rails 是一個有主見的軟件。它假設有一個“最佳”的方法來做事情，並且設計成鼓勵這種方式 - 在某些情況下還會阻止其他選擇。如果您學習“Rails 的方式”，您可能會發現生產力大大提高。如果您堅持將其他語言的舊習慣帶到 Rails 開發中，並嘗試使用在其他地方學到的模式，您可能會有一個不太愉快的經歷。

Rails 的理念包括兩個主要指導原則：

* **不要重複自己（DRY）：** DRY 是軟件開發的一個原則，它認為“系統中的每個知識片段必須具有單一、明確、權威的表示”。通過不反覆編寫相同的信息，我們的代碼更易於維護、擴展和減少錯誤。
* **約定優於配置（Convention Over Configuration）：** Rails 對於 Web 應用程序中的許多事情有自己的看法，並且默認使用這組約定，而不是要求您通過無盡的配置文件來指定細節。

創建新的 Rails 項目
----------------------------

閱讀本指南的最佳方法是按步驟進行。所有步驟都是運行此示例應用程序所必需的，不需要額外的代碼或步驟。

按照本指南的步驟，您將創建一個名為 `blog` 的 Rails 項目，這是一個（非常）簡單的網誌。在開始構建應用程序之前，您需要確保已經安裝了 Rails 本身。

注意：以下示例在 UNIX-like 的操作系統中使用 `$` 來表示終端提示符，但可能已經自定義為不同的外觀。如果您使用的是 Windows，您的提示符將類似於 `C:\source_code>`。

### 安裝 Rails

在安裝 Rails 之前，您應該檢查系統是否已安裝了所需的先決條件。這些包括：

* Ruby
* SQLite3

#### 安裝 Ruby

打開命令行提示符。在 macOS 上打開 Terminal.app；在 Windows 上選擇“運行”菜單，然後輸入 `cmd.exe`。任何以美元符號 `$` 開頭的命令都應該在命令行中運行。驗證您是否安裝了當前版本的 Ruby：

```bash
$ ruby --version
ruby 2.7.0
```

Rails 需要 Ruby 版本 2.7.0 或更高。最好使用最新的 Ruby 版本。如果返回的版本號小於該數字（例如 2.3.7 或 1.8.7），您需要安裝一個新的 Ruby 副本。

要在 Windows 上安裝 Rails，您首先需要安裝 [Ruby Installer](https://rubyinstaller.org/)。

有關大多數操作系統的更多安裝方法，請參閱 [ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/)。

#### 安裝 SQLite3

您還需要安裝 SQLite3 數據庫。許多流行的 UNIX-like 操作系統都附帶了一個可接受的版本的 SQLite3。其他人可以在 [SQLite3 網站](https://www.sqlite.org) 上找到安裝說明。
驗證是否已正確安裝並在您的載入 `PATH` 中：

```bash
$ sqlite3 --version
```

程式應該會報告其版本。

#### 安裝 Rails

要安裝 Rails，使用 RubyGems 提供的 `gem install` 命令：

```bash
$ gem install rails
```

要驗證是否已正確安裝所有必要的元件，您應該能夠在新的終端機中執行以下命令：

```bash
$ rails --version
```

如果顯示類似 "Rails 7.0.0" 的訊息，表示您已準備好繼續。

### 建立部落格應用程式

Rails 提供了一些稱為生成器的腳本，旨在通過創建開始特定任務所需的一切，使您的開發更輕鬆。其中之一是新應用程式生成器，它將為您提供一個全新的 Rails 應用程式的基礎，以免您自己編寫。

要使用此生成器，打開終端機，切換到您有權限創建文件的目錄，然後執行以下命令：

```bash
$ rails new blog
```

這將在 `blog` 目錄中創建一個名為 Blog 的 Rails 應用程式，並使用 `bundle install` 安裝已在 `Gemfile` 中提到的 gem 依賴。

提示：您可以執行 `rails new --help` 來查看 Rails 應用程式生成器接受的所有命令行選項。

創建部落格應用程式後，切換到其資料夾：

```bash
$ cd blog
```

`blog` 目錄將包含一些生成的文件和資料夾，這些文件和資料夾組成了一個 Rails 應用程式的結構。本教程中的大部分工作將在 `app` 資料夾中進行，但以下是 Rails 默認創建的每個文件和資料夾的基本功能概述：

| 文件/資料夾 | 功能 |
| ----------- | ------- |
|app/|包含應用程式的控制器、模型、視圖、幫助程式、郵件程式、通道、工作和資產。您將在本指南的其餘部分專注於此資料夾。|
|bin/|包含啟動應用程式的 `rails` 腳本，並可包含其他用於設置、更新、部署或運行應用程式的腳本。|
|config/|包含應用程式的路由、資料庫等配置。詳細內容請參閱[配置 Rails 應用程式](configuring.html)。|
|config.ru|用於啟動應用程式的基於 Rack 的伺服器的 Rack 配置。有關 Rack 的更多信息，請參閱[Rack 網站](https://rack.github.io/)。|
|db/|包含當前的資料庫架構以及資料庫遷移。|
|Gemfile<br>Gemfile.lock|這些文件允許您指定 Rails 應用程式所需的 gem 依賴。這些文件由 Bundler gem 使用。有關 Bundler 的更多信息，請參閱[Bundler 網站](https://bundler.io)。|
|lib/|應用程式的擴展模組。|
|log/|應用程式的日誌文件。|
|public/|包含靜態文件和編譯後的資產。在應用程式運行時，此目錄將原樣公開。|
|Rakefile|此文件定位並加載可從命令行運行的任務。任務定義在 Rails 的各個組件中定義。您應該通過將文件添加到應用程式的 `lib/tasks` 目錄來添加自己的任務，而不是更改 `Rakefile`。|
|README.md|這是您的應用程式的簡要說明手冊。您應該編輯此文件以告訴其他人您的應用程式的功能、如何設置它等等。|
|storage/|Disk Service 的 Active Storage 檔案。詳細內容請參閱[Active Storage 概述](active_storage_overview.html)。|
|test/|單元測試、固定資料和其他測試工具。詳細內容請參閱[測試 Rails 應用程式](testing.html)。|
|tmp/|臨時文件（如快取和 pid 文件）。|
|vendor/|所有第三方代碼的位置。在典型的 Rails 應用程式中，這包括供應的 gem。|
|.gitattributes|此文件定義了 git 存儲庫中特定路徑的元數據。這些元數據可供 git 和其他工具使用，以增強其行為。有關詳細信息，請參閱[gitattributes 文件](https://git-scm.com/docs/gitattributes)。|
|.gitignore|此文件告訴 git 應該忽略哪些文件（或模式）。有關忽略文件的更多信息，請參閱[GitHub - 忽略文件](https://help.github.com/articles/ignoring-files)。|
|.ruby-version|此文件包含默認的 Ruby 版本。|

Hello, Rails!
-------------

首先，讓我們快速在螢幕上顯示一些文字。為此，您需要啟動 Rails 應用程式伺服器。

### 啟動網頁伺服器

您實際上已經有一個可運作的 Rails 應用程式。要查看它，您需要在開發機器上啟動一個網頁伺服器。您可以在 `blog` 目錄中執行以下命令來完成：

```bash
$ bin/rails server
```
提示：如果您使用的是Windows，您必須直接將位於`bin`文件夾下的腳本傳遞給Ruby解釋器，例如`ruby bin\rails server`。

提示：JavaScript資源壓縮需要在系統上可用的JavaScript運行時，如果沒有運行時，資源壓縮過程中會出現`execjs`錯誤。通常macOS和Windows都已經安裝了JavaScript運行時。`therubyrhino`是JRuby用戶的推薦運行時，並且在JRuby生成的應用程序的`Gemfile`中默認添加了該運行時。您可以在[ExecJS](https://github.com/rails/execjs#readme)中查看所有支持的運行時。

這將啟動Puma，這是Rails默認分發的Web服務器。要查看應用程序的運行情況，打開瀏覽器窗口並導航到<http://localhost:3000>。您應該會看到Rails的默認信息頁面：

![Rails啟動頁面截圖](images/getting_started/rails_welcome.png)

當您想要停止Web服務器時，在運行它的終端窗口中按下Ctrl+C。在開發環境中，Rails通常不需要重新啟動服務器；您對文件所做的更改將自動被服務器接收。

Rails的啟動頁面是對新的Rails應用程序的“煙霧測試”：它確保您已經正確配置了軟件以提供頁面。

### 跟Rails打個招呼

要讓Rails說“Hello”，您至少需要創建一個*路由*、一個*控制器*和一個*視圖*。路由將請求映射到控制器的操作。控制器操作執行處理請求所需的工作，並為視圖準備任何數據。視圖以所需的格式顯示數據。

在實現方面：路由是用Ruby [DSL（特定領域語言）](https://en.wikipedia.org/wiki/Domain-specific_language)編寫的規則。控制器是Ruby類，它們的公共方法是操作。視圖是模板，通常由HTML和Ruby混合編寫。

讓我們從在`config/routes.rb`文件的`Rails.application.routes.draw`塊的頂部添加一個路由開始：

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # 有關此文件中可用的DSL的詳細信息，請參閱https://guides.rubyonrails.org/routing.html
end
```

上面的路由聲明了將`GET /articles`請求映射到`ArticlesController`的`index`操作。

要創建`ArticlesController`及其`index`操作，我們將運行控制器生成器（使用`--skip-routes`選項，因為我們已經有了適當的路由）：

```bash
$ bin/rails generate controller Articles index --skip-routes
```

Rails將為您創建幾個文件：

```
create  app/controllers/articles_controller.rb
invoke  erb
create    app/views/articles
create    app/views/articles/index.html.erb
invoke  test_unit
create    test/controllers/articles_controller_test.rb
invoke  helper
create    app/helpers/articles_helper.rb
invoke    test_unit
```

其中最重要的是控制器文件`app/controllers/articles_controller.rb`。讓我們來看一下它：

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```

`index`操作是空的。當操作沒有顯式地呈現視圖（或以其他方式觸發HTTP響應）時，Rails將自動呈現與控制器和操作名稱匹配的視圖。約定優於配置！視圖位於`app/views`目錄中。因此，`index`操作將默認呈現`app/views/articles/index.html.erb`。

讓我們打開`app/views/articles/index.html.erb`，並將其內容替換為：

```html
<h1>Hello, Rails!</h1>
```

如果您之前停止了Web服務器以運行控制器生成器，請使用`bin/rails server`重新啟動它。現在訪問<http://localhost:3000/articles>，並查看我們的文本顯示！

### 設置應用程序首頁

目前，<http://localhost:3000>仍然顯示帶有Ruby on Rails標誌的頁面。讓我們也在<http://localhost:3000>上顯示我們的“Hello, Rails!”文本。為此，我們將添加一個路由，將我們應用程序的*根路徑*映射到相應的控制器和操作。

讓我們打開`config/routes.rb`，並在`Rails.application.routes.draw`塊的頂部添加以下`root`路由：

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

現在，當我們訪問<http://localhost:3000>時，可以看到我們的“Hello, Rails!”文本，這證明`root`路由也映射到`ArticlesController`的`index`操作。

提示：要了解更多關於路由的信息，請參閱[Rails從外到內的路由](routing.html)。

自動加載
-----------

Rails應用程序**不使用**`require`來加載應用程序代碼。

您可能已經注意到`ArticlesController`繼承自`ApplicationController`，但是`app/controllers/articles_controller.rb`沒有類似以下的代碼：

```ruby
require "application_controller" # 不要這樣做。
```

應用程序的類和模塊在任何地方都可用，您不需要並且**不應該**使用`require`來加載`app`下的任何文件。這個功能被稱為_自動加載_，您可以在[_自動加載和重新加載常量_](autoloading_and_reloading_constants.html)中了解更多相關信息。
只需要使用`require`語句來處理兩種情況：

* 加載`lib`目錄下的文件。
* 加載在`Gemfile`中設置了`require: false`的gem依賴項。

MVC和您
-----------

到目前為止，我們已經討論了路由、控制器、操作和視圖。所有這些都是遵循[MVC（模型-視圖-控制器）](
https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)模式的Web應用程序的典型組件。MVC是一種將應用程序的責任劃分為更容易理解的設計模式。Rails通過約定遵循這種設計模式。

由於我們有一個控制器和一個視圖可以使用，讓我們生成下一個組件：模型。

### 生成模型

*模型*是一個用於表示數據的Ruby類。此外，模型可以通過Rails的*Active Record*功能與應用程序的數據庫進行交互。

要定義一個模型，我們將使用模型生成器：

```bash
$ bin/rails generate model Article title:string body:text
```

注意：模型名稱是**單數**的，因為實例化的模型表示單個數據記錄。為了幫助記住這種約定，想想如何調用模型的構造函數：我們希望寫`Article.new(...)`，而不是`Articles.new(...)`。

這將創建幾個文件：

```
invoke  active_record
create    db/migrate/<timestamp>_create_articles.rb
create    app/models/article.rb
invoke    test_unit
create      test/models/article_test.rb
create      test/fixtures/articles.yml
```

我們將關注兩個文件：遷移文件（`db/migrate/<timestamp>_create_articles.rb`）和模型文件（`app/models/article.rb`）。

### 數據庫遷移

*遷移*用於更改應用程序的數據庫結構。在Rails應用程序中，遷移是用Ruby編寫的，以便它們可以與數據庫無關。

讓我們看一下新遷移文件的內容：

```ruby
class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

對`create_table`的調用指定了如何構建`articles`表。默認情況下，`create_table`方法添加一個`id`列作為自動增量主鍵。因此，表中的第一條記錄的`id`為1，下一條記錄的`id`為2，依此類推。

在`create_table`的塊內部，定義了兩個列：`title`和`body`。這些列是由生成器添加的，因為我們在生成命令中包含了它們（`bin/rails generate model Article title:string body:text`）。

在塊的最後一行是對`t.timestamps`的調用。這個方法定義了兩個額外的列，名為`created_at`和`updated_at`。正如我們將看到的，Rails將為我們管理這些列，在創建或更新模型對象時設置值。

讓我們運行以下命令遷移：

```bash
$ bin/rails db:migrate
```

該命令將顯示顯示表已創建的輸出：

```
==  CreateArticles: migrating ===================================
-- create_table(:articles)
   -> 0.0018s
==  CreateArticles: migrated (0.0018s) ==========================
```

提示：要了解有關遷移的更多信息，請參閱[Active Record遷移](
active_record_migrations.html)。

現在，我們可以使用我們的模型與表進行交互。

### 使用模型與數據庫進行交互

為了玩弄我們的模型，我們將使用Rails的一個功能，稱為*控制台*。控制台是一個交互式編碼環境，就像`irb`一樣，但它還會自動加載Rails和我們的應用程序代碼。

讓我們使用以下命令啟動控制台：

```bash
$ bin/rails console
```

您應該看到一個類似`irb`的提示符：

```irb
Loading development environment (Rails 7.0.0)
irb(main):001:0>
```

在這個提示符下，我們可以初始化一個新的`Article`對象：

```irb
irb> article = Article.new(title: "Hello Rails", body: "I am on Rails!")
```

重要的是要注意，我們只是*初始化*了這個對象。這個對象根本沒有保存到數據庫中。它只在控制台中當前可用。要將對象保存到數據庫中，我們必須調用[`save`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save)：

```irb
irb> article.save
(0.1ms)  begin transaction
Article Create (0.4ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "Hello Rails"], ["body", "I am on Rails!"], ["created_at", "2020-01-18 23:47:30.734416"], ["updated_at", "2020-01-18 23:47:30.734416"]]
(0.9ms)  commit transaction
=> true
```

上面的輸出顯示了一個`INSERT INTO "articles" ...`的數據庫查詢。這表明文章已經插入到我們的表中。如果我們再次查看`article`對象，我們會發現有一些有趣的事情發生了：

```irb
irb> article
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```
物件的 `id`、`created_at` 和 `updated_at` 屬性現在已經設定好了。
當我們儲存物件時，Rails 會自動幫我們設定這些屬性。

當我們想要從資料庫中取得這篇文章時，我們可以在模型上呼叫 [`find`](
https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find)
並傳入 `id` 作為參數：

```irb
irb> Article.find(1)
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

而當我們想要從資料庫中取得所有文章時，我們可以在模型上呼叫 [`all`](
https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all)
：

```irb
irb> Article.all
=> #<ActiveRecord::Relation [#<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">]>
```

這個方法會回傳一個 [`ActiveRecord::Relation`](
https://api.rubyonrails.org/classes/ActiveRecord/Relation.html) 物件，你可以把它想像成一個功能強大的陣列。

提示：要了解更多關於模型的資訊，請參考 [Active Record Basics](
active_record_basics.html) 和 [Active Record Query Interface](
active_record_querying.html)。

模型是 MVC 架構中的最後一塊拼圖。接下來，我們將把所有的拼圖連接在一起。

### 顯示文章清單

讓我們回到位於 `app/controllers/articles_controller.rb` 的控制器，並將 `index` 動作修改為從資料庫中取得所有文章：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

控制器的實例變數可以在視圖中存取。這意味著我們可以在 `app/views/articles/index.html.erb` 中參考 `@articles`。讓我們打開該檔案，並將其內容替換為：

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

上面的程式碼是 HTML 和 *ERB* 的混合。ERB 是一個模板系統，可以評估嵌入在文件中的 Ruby 程式碼。在這裡，我們可以看到兩種類型的 ERB 標籤：`<% %>` 和 `<%= %>`。`<% %>` 標籤表示「評估所包含的 Ruby 程式碼」。`<%= %>` 標籤表示「評估所包含的 Ruby 程式碼，並輸出其返回的值」。任何你可以在一般的 Ruby 程式中寫的內容都可以放在這些 ERB 標籤中，但通常最好保持 ERB 標籤內容的簡潔，以增加可讀性。

由於我們不想輸出 `@articles.each` 返回的值，所以我們將該程式碼放在 `<% %>` 中。但是，由於我們想要輸出 `article.title` 返回的值（對於每篇文章），所以我們將該程式碼放在 `<%= %>` 中。

我們可以透過訪問 <http://localhost:3000> 來查看最終結果。（請記得要執行 `bin/rails server`！）當我們這樣做時，會發生以下事情：

1. 瀏覽器發出請求：`GET http://localhost:3000`。
2. 我們的 Rails 應用程式接收到這個請求。
3. Rails 路由器將根路由對應到 `ArticlesController` 的 `index` 動作。
4. `index` 動作使用 `Article` 模型從資料庫中取得所有文章。
5. Rails 自動渲染 `app/views/articles/index.html.erb` 視圖。
6. 視圖中的 ERB 程式碼被評估以輸出 HTML。
7. 伺服器將包含 HTML 的回應傳送回瀏覽器。

我們已經將所有的 MVC 拼圖連接在一起，並且有了我們的第一個控制器動作！接下來，我們將繼續進行第二個動作。

CRUDit Where CRUDit Is Due
--------------------------

幾乎所有的網路應用程式都涉及到 [CRUD (Create, Read, Update, and Delete)](
https://en.wikipedia.org/wiki/Create,_read,_update,_and_delete) 操作。你甚至可能會發現，你的應用程式大部分的工作都是 CRUD。Rails 知道這一點，並提供了許多功能來簡化 CRUD 相關的程式碼。

讓我們開始探索這些功能，並為我們的應用程式添加更多功能。

### 顯示單篇文章

我們目前有一個視圖，列出了資料庫中的所有文章。現在，我們要新增一個視圖，顯示單篇文章的標題和內容。

首先，我們需要新增一個路由，將其對應到一個新的控制器動作（我們接下來會新增）。打開 `config/routes.rb`，並在最後插入以下路由：

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

這個新的路由是另一個 `get` 路由，但在路徑中多了一個特殊的部分：`:id`。這代表一個路由參數。路由參數會捕捉請求路徑的一個片段，並將該值放入 `params` 哈希中，可以在控制器動作中存取。例如，當處理像 `GET http://localhost:3000/articles/1` 這樣的請求時，`1` 將被捕捉為 `:id` 的值，然後可以在 `ArticlesController` 的 `show` 動作中以 `params[:id]` 的方式存取。
現在讓我們在`app/controllers/articles_controller.rb`中的`index`動作下方，添加`show`動作：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

`show`動作使用`Article.find`（前面提到過）來查找由路由參數捕獲的ID。返回的文章存儲在`@article`實例變量中，因此可以在視圖中訪問。默認情況下，`show`動作將呈現`app/views/articles/show.html.erb`。

現在我們可以在訪問<http://localhost:3000/articles/1>時看到文章了！

最後，讓我們添加一種方便的方式來訪問文章的頁面。我們將在`app/views/articles/index.html.erb`中將每篇文章的標題鏈接到其頁面：

```html+erb
<h1>文章</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

### 資源路由

到目前為止，我們已經涵蓋了CRUD中的“R”（讀取）。我們最終將涵蓋“C”（創建），“U”（更新）和“D”（刪除）。正如你可能猜到的那樣，我們將通過添加新的路由、控制器動作和視圖來實現這一點。每當我們有這樣一組路由、控制器動作和視圖一起工作以在實體上執行CRUD操作時，我們稱該實體為*資源*。例如，在我們的應用程序中，我們會說一篇文章是一個資源。

Rails提供了一個名為[`resources`](https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources)的路由方法，用於映射一組資源（例如文章）的所有常規路由。因此，在我們繼續進入“C”，“U”和“D”部分之前，讓我們用`resources`替換`config/routes.rb`中的兩個`get`路由：

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

我們可以運行`bin/rails routes`命令來檢查映射了哪些路由：

```bash
$ bin/rails routes
      Prefix Verb   URI Pattern                  Controller#Action
        root GET    /                            articles#index
    articles GET    /articles(.:format)          articles#index
 new_article GET    /articles/new(.:format)      articles#new
     article GET    /articles/:id(.:format)      articles#show
             POST   /articles(.:format)          articles#create
edit_article GET    /articles/:id/edit(.:format) articles#edit
             PATCH  /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
```

`resources`方法還設置了URL和路徑輔助方法，我們可以使用這些方法使我們的代碼不依賴於特定的路由配置。上面“Prefix”列中的值加上`_url`或`_path`後綴形成這些輔助方法的名稱。例如，上面的`article_path`輔助方法在給定一篇文章時返回`"/articles/#{article.id}"`。我們可以使用它來整理`app/views/articles/index.html.erb`中的鏈接：

```html+erb
<h1>文章</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

然而，我們將進一步使用[`link_to`](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)輔助方法。`link_to`輔助方法使用其第一個參數作為鏈接的文本，第二個參數作為鏈接的目標。如果我們將模型對象作為第二個參數傳遞給`link_to`，它將調用相應的路徑輔助方法將對象轉換為路徑。例如，如果我們傳遞一篇文章，`link_to`將調用`article_path`。因此，`app/views/articles/index.html.erb`變為：

```html+erb
<h1>文章</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

很好！

提示：要了解更多關於路由的信息，請參閱[Rails從外到內的路由](routing.html)。

### 創建新文章

現在我們進入CRUD中的“C”（創建）。通常，在Web應用程序中，創建新資源是一個多步驟的過程。首先，用戶請求一個要填寫的表單。然後，用戶提交表單。如果沒有錯誤，則創建資源並顯示某種確認。否則，重新顯示表單並顯示錯誤消息，然後重複這個過程。

在Rails應用程序中，這些步驟通常由控制器的`new`和`create`動作處理。讓我們在`app/controllers/articles_controller.rb`中的`show`動作下方添加這些動作的典型實現：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

`new`動作實例化一個新的文章，但不保存它。這篇文章將在視圖中用於構建表單。默認情況下，`new`動作將呈現`app/views/articles/new.html.erb`，我們將在下一步創建。


`create` 動作會使用標題和內容的值實例化一個新的文章，並嘗試保存它。如果文章成功保存，該動作會將瀏覽器重定向到文章頁面，位於 `"http://localhost:3000/articles/#{@article.id}"`。
否則，該動作會通過渲染 `app/views/articles/new.html.erb` 重新顯示表單，並返回 [422 Unprocessable Entity](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/422) 狀態碼。
這裡的標題和內容是虛擬值。在創建表單後，我們將回來更改這些值。

注意：[`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to) 會導致瀏覽器發起新的請求，而 [`render`](https://api.rubyonrails.org/classes/AbstractController/Rendering.html#method-i-render) 會在當前請求中渲染指定的視圖。
在修改數據庫或應用程序狀態後，使用 `redirect_to` 是很重要的。否則，如果用戶刷新頁面，瀏覽器將發起相同的請求，並重複執行修改。

#### 使用表單生成器

我們將使用 Rails 的一個功能，稱為 *表單生成器* 來創建我們的表單。使用表單生成器，我們可以只寫少量的代碼來輸出一個完全配置且符合 Rails 慣例的表單。

讓我們創建 `app/views/articles/new.html.erb`，內容如下：

```html+erb
<h1>新文章</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

[`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with) 輔助方法實例化一個表單生成器。在 `form_with` 區塊中，我們調用表單生成器的 [`label`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-label) 和 [`text_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_field) 等方法來輸出適當的表單元素。

`form_with` 調用的結果將如下所示：

```html
<form action="/articles" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="...">

  <div>
    <label for="article_title">標題</label><br>
    <input type="text" name="article[title]" id="article_title">
  </div>

  <div>
    <label for="article_body">內容</label><br>
    <textarea name="article[body]" id="article_body"></textarea>
  </div>

  <div>
    <input type="submit" name="commit" value="創建文章" data-disable-with="創建文章">
  </div>
</form>
```

提示：要了解更多關於表單生成器的信息，請參閱 [Action View 表單輔助方法](form_helpers.html)。

#### 使用 Strong Parameters

提交的表單數據會放入 `params` 哈希中，與捕獲的路由參數一起。因此，`create` 動作可以通過 `params[:article][:title]` 獲取提交的標題，通過 `params[:article][:body]` 獲取提交的內容。
我們可以將這些值個別傳遞給 `Article.new`，但這樣會冗長且可能出錯。而且隨著添加更多字段，情況會變得更糟。

相反，我們將傳遞一個包含這些值的單個哈希。但是，我們仍然必須指定該哈希中允許的值。否則，惡意用戶可能提交額外的表單字段並覆蓋私有數據。實際上，如果我們直接將未過濾的 `params[:article]` 哈希傳遞給 `Article.new`，Rails 將引發 `ForbiddenAttributesError` 以警告我們問題。
因此，我們將使用 Rails 的一個功能，稱為 *Strong Parameters* 來過濾 `params`。可以將其視為 `params` 的 [強類型](https://en.wikipedia.org/wiki/Strong_and_weak_typing)。

讓我們在 `app/controllers/articles_controller.rb` 的底部添加一個名為 `article_params` 的私有方法來過濾 `params`。並且讓 `create` 使用它：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

提示：要了解更多關於 Strong Parameters 的信息，請參閱 [Action Controller 概述 § Strong Parameters](action_controller_overview.html#strong-parameters)。

#### 驗證和顯示錯誤信息

正如我們所見，創建資源是一個多步驟的過程。處理無效的用戶輸入是該過程的另一步。Rails 提供了一個名為 *驗證* 的功能來幫助我們處理無效的用戶輸入。驗證是在保存模型對象之前檢查的規則。如果任何檢查失敗，保存將被中止，並將適當的錯誤信息添加到模型對象的 `errors` 屬性中。

讓我們在 `app/models/article.rb` 中的模型中添加一些驗證：

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

第一個驗證聲明了 `title` 值必須存在。因為 `title` 是一個字符串，這意味著 `title` 值必須包含至少一個非空白字符。

第二個驗證聲明了 `body` 值也必須存在。此外，它聲明了 `body` 值必須至少為 10 個字符長。

注意：你可能想知道 `title` 和 `body` 屬性是在哪裡定義的。Active Record 會自動為每個表列定義模型屬性，因此你不需要在模型文件中聲明這些屬性。
在我們設置驗證後，讓我們修改 `app/views/articles/new.html.erb` 來顯示 `title` 和 `body` 的任何錯誤訊息：

```html+erb
<h1>新增文章</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

[`full_messages_for`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_messages_for)
方法會返回指定屬性的用戶友好的錯誤訊息陣列。如果該屬性沒有錯誤，則陣列將為空。

為了了解所有這些如何一起運作，讓我們再次看一下 `new` 和 `create` 控制器動作：

```ruby
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
```

當我們訪問 <http://localhost:3000/articles/new> 時，`GET /articles/new` 請求將映射到 `new` 動作。`new` 動作不會嘗試保存 `@article`。因此，驗證不會被檢查，並且不會有錯誤訊息。

當我們提交表單時，`POST /articles` 請求將映射到 `create` 動作。`create` 動作*會*嘗試保存 `@article`。因此，驗證*會*被檢查。如果任何驗證失敗，`@article` 將不會被保存，並且 `app/views/articles/new.html.erb` 將被渲染並顯示錯誤訊息。

提示：要了解更多關於驗證的資訊，請參閱 [Active Record 驗證](active_record_validations.html)。要了解更多關於驗證錯誤訊息的資訊，請參閱 [Active Record 驗證 § 處理驗證錯誤](active_record_validations.html#working-with-validation-errors)。

#### 完成

現在我們可以通過訪問 <http://localhost:3000/articles/new> 來創建一篇文章。最後，讓我們在 `app/views/articles/index.html.erb` 的底部添加一個連結到該頁面：

```html+erb
<h1>文章</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "新增文章", new_article_path %>
```

### 更新文章

我們已經涵蓋了 CRUD 中的 "CR"。現在讓我們繼續進行 "U"（更新）。更新資源與創建資源非常相似。它們都是多步驟的過程。首先，用戶請求編輯數據的表單。然後，用戶提交表單。如果沒有錯誤，則資源會被更新。否則，表單將重新顯示並帶有錯誤訊息，並且過程將重複。

這些步驟通常由控制器的 `edit` 和 `update` 動作處理。讓我們在 `app/controllers/articles_controller.rb` 中的 `create` 動作下方添加這些動作的典型實現：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

注意 `edit` 和 `update` 動作與 `new` 和 `create` 動作的相似之處。

`edit` 動作從數據庫中獲取文章，並將其存儲在 `@article` 中，以便在構建表單時使用。默認情況下，`edit` 動作將渲染 `app/views/articles/edit.html.erb`。

`update` 動作重新從數據庫中獲取文章，並嘗試使用由 `article_params` 過濾的提交表單數據來更新它。如果沒有驗證失敗且更新成功，該動作將重定向瀏覽器到文章的頁面。否則，該動作將重新顯示表單（帶有錯誤訊息），並渲染 `app/views/articles/edit.html.erb`。

#### 使用局部視圖共享代碼

我們的 `edit` 表單將與 `new` 表單相同。甚至代碼也將相同，這要歸功於 Rails 表單生成器和資源路由。表單生成器會根據模型對象是否已保存來自動配置表單以進行適當類型的請求。

由於代碼將相同，我們將其提取到一個名為 *局部視圖* 的共享視圖中。讓我們創建 `app/views/articles/_form.html.erb`，內容如下：

```html+erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```
上述的代碼與我們在`app/views/articles/new.html.erb`中的表單相同，只是將所有的`@article`都替換為`article`。由於局部視圖是共享代碼，最佳實踐是它們不依賴於控制器操作設置的特定實例變量。相反，我們將把文章作為局部變量傳遞給局部視圖。

讓我們更新`app/views/articles/new.html.erb`，通過[`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render)使用局部視圖：

```html+erb
<h1>新文章</h1>

<%= render "form", article: @article %>
```

注意：局部視圖的文件名必須以下劃線開頭，例如`_form.html.erb`。但在渲染時，它的引用不包含下劃線，例如`render "form"`。

現在，讓我們創建一個非常相似的`app/views/articles/edit.html.erb`：

```html+erb
<h1>編輯文章</h1>

<%= render "form", article: @article %>
```

提示：要了解有關局部視圖的更多信息，請參閱[Layouts and Rendering in Rails § Using Partials](layouts_and_rendering.html#using-partials)。

#### 完成

現在，我們可以通過訪問編輯頁面來更新文章，例如<http://localhost:3000/articles/1/edit>。最後，讓我們在`app/views/articles/show.html.erb`的底部添加一個鏈接，以便從該頁面刪除文章：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "編輯", edit_article_path(@article) %></li>
</ul>
```

### 刪除文章

最後，我們來到了CRUD的“D”（刪除）部分。刪除資源比創建或更新資源更簡單。它只需要一個路由和一個控制器操作。而我們的資源路由（`resources :articles`）已經提供了路由，將`DELETE /articles/:id`請求映射到`ArticlesController`的`destroy`操作。

因此，讓我們在`app/controllers/articles_controller.rb`中添加一個典型的`destroy`操作，放在`update`操作之後：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

`destroy`操作從數據庫中獲取文章，並在其上調用[`destroy`](https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy)。然後，它將瀏覽器重定向到根路徑，並使用狀態碼[303 See Other](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/303)。

我們選擇重定向到根路徑，因為那是我們文章的主要訪問點。但在其他情況下，您可能選擇重定向到例如`articles_path`。

現在，讓我們在`app/views/articles/show.html.erb`的底部添加一個鏈接，以便我們可以從該頁面刪除一篇文章：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "編輯", edit_article_path(@article) %></li>
  <li><%= link_to "刪除", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "確定要刪除嗎？"
                  } %></li>
</ul>
```

在上面的代碼中，我們使用`data`選項來設置“刪除”鏈接的`data-turbo-method`和`data-turbo-confirm` HTML屬性。這兩個屬性都與默認情況下包含在新的Rails應用程序中的[Turbo](https://turbo.hotwired.dev/)相關聯。`data-turbo-method="delete"`將使鏈接發送`DELETE`請求而不是`GET`請求。`data-turbo-confirm="確定要刪除嗎？"`將在單擊鏈接時顯示確認對話框。如果用戶取消對話框，請求將被中止。

就是這樣！我們現在可以列出、顯示、創建、更新和刪除文章了！CRUD完成！

添加第二個模型
---------------------

現在是時候向應用程序添加第二個模型了。第二個模型將處理對文章的評論。

### 生成模型

我們將使用與之前創建`Article`模型時相同的生成器。這次我們將創建一個`Comment`模型來保存對文章的引用。在終端中運行以下命令：

```bash
$ bin/rails generate model Comment commenter:string body:text article:references
```

此命令將生成四個文件：

| 文件                                         | 目的                                                                                                  |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| db/migrate/20140120201010_create_comments.rb | 在數據庫中創建comments表的遷移（您的名稱將包含不同的時間戳）                                           |
| app/models/comment.rb                        | Comment模型                                                                                           |
| test/models/comment_test.rb                  | Comment模型的測試框架                                                                                  |
| test/fixtures/comments.yml                   | 用於測試的示例評論                                                                                     |

首先，看一下`app/models/comment.rb`：

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

這與之前看到的`Article`模型非常相似。不同之處在於`belongs_to :article`這一行，它設置了一個Active Record _關聯_。您將在本指南的下一部分中了解一些關聯的知識。
在shell命令中使用的(`:references`)關鍵字是一種特殊的模型數據類型。
它在數據庫表上創建一個新的列，該列的名稱是提供的模型名稱後面加上`_id`，可以存儲整數值。為了更好地理解，可以在運行遷移後分析`db/schema.rb`文件。

除了模型之外，Rails還創建了一個遷移來創建相應的數據庫表：

```ruby
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

`t.references`行創建了一個名為`article_id`的整數列，以及一個指向`articles`表的`id`列的索引和外鍵約束。現在運行遷移：

```bash
$ bin/rails db:migrate
```

Rails足夠智能，只會執行尚未對當前數據庫運行的遷移，所以在這種情況下，你只會看到：

```
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```

### 關聯模型

Active Record關聯允許您輕鬆聲明兩個模型之間的關係。
對於評論和文章，您可以這樣描述關係：

* 每個評論屬於一篇文章。
* 一篇文章可以有多個評論。

實際上，這非常接近Rails用於聲明此關聯的語法。您已經在`Comment`模型（app/models/comment.rb）中看到了使每個評論屬於一篇文章的代碼行：

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

您需要編輯`app/models/article.rb`以添加關聯的另一側：

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

這兩個聲明使許多自動行為成為可能。例如，如果您有一個包含文章的實例變量`@article`，您可以使用`@article.comments`將屬於該文章的所有評論檢索為數組。

提示：有關Active Record關聯的更多信息，請參閱[Active Record關聯](association_basics.html)指南。

### 添加評論的路由

與`articles`控制器一樣，我們需要添加一個路由，以便Rails知道我們要導航到哪裡查看`comments`。再次打開`config/routes.rb`文件，並將其編輯如下：

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

這將`comments`創建為`articles`的嵌套資源。這是捕獲文章和評論之間層次結構關係的另一部分。

提示：有關路由的更多信息，請參閱[Rails路由](routing.html)指南。

### 生成控制器

有了模型，您可以開始創建相應的控制器。同樣，我們將使用之前使用的生成器：

```bash
$ bin/rails generate controller Comments
```

這將創建三個文件和一個空目錄：

| 文件/目錄                                      | 用途                                      |
| -------------------------------------------- | ---------------------------------------- |
| app/controllers/comments_controller.rb       | Comments控制器                           |
| app/views/comments/                          | 控制器的視圖存儲在這裡                   |
| test/controllers/comments_controller_test.rb | 控制器的測試                             |
| app/helpers/comments_helper.rb               | 視圖助手文件                             |

與任何博客一樣，讀者在閱讀文章後將直接創建評論，一旦添加了評論，將返回文章展示頁面以查看他們的評論。因此，我們的`CommentsController`用於提供創建評論和在垃圾評論到達時刪除評論的方法。

首先，我們將連接Article展示模板（`app/views/articles/show.html.erb`），以便讓我們添加新的評論：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

這在`Article`展示頁面上添加了一個表單，通過調用`CommentsController`的`create`操作來創建新的評論。這裡的`form_with`調用使用了一個數組，將創建一個嵌套路由，例如`/articles/1/comments`。
讓我們在 `app/controllers/comments_controller.rb` 中連接 `create` 方法：

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

在這裡，你會看到比文章控制器中更複雜的程式碼。這是因為你設定了巢狀結構的關係。每個評論的請求都需要追蹤該評論所屬的文章，因此需要使用 `Article` 模型的 `find` 方法來取得相關的文章。

此外，程式碼還利用了一些關聯的方法。我們使用 `@article.comments.create` 方法來創建並保存評論。這將自動將評論與特定的文章關聯起來。

當我們創建了新的評論後，我們使用 `article_path(@article)` 輔助方法將使用者重定向回原始文章。正如我們已經看到的，這會調用 `ArticlesController` 的 `show` 方法，該方法會渲染 `show.html.erb` 模板。這就是我們希望顯示評論的地方，所以讓我們將其添加到 `app/views/articles/show.html.erb` 中。

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "編輯", edit_article_path(@article) %></li>
  <li><%= link_to "刪除", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "你確定嗎？"
                  } %></li>
</ul>

<h2>評論</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>評論者：</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>評論內容：</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>新增評論：</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

現在，您可以在您的部落格中添加文章和評論，並將它們顯示在正確的位置。

![帶有評論的文章](images/getting_started/article_with_comments.png)

重構
-----------

現在，我們已經讓文章和評論正常運作了，讓我們來看看 `app/views/articles/show.html.erb` 模板。它變得又長又笨重。我們可以使用 partials 來整理它。

### 渲染部分集合

首先，我們將創建一個評論的 partial，用於顯示所有與文章相關的評論。創建文件 `app/views/comments/_comment.html.erb`，並將以下內容放入其中：

```html+erb
<p>
  <strong>評論者：</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>評論內容：</strong>
  <%= comment.body %>
</p>
```

然後，您可以將 `app/views/articles/show.html.erb` 修改為以下內容：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "編輯", edit_article_path(@article) %></li>
  <li><%= link_to "刪除", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "你確定嗎？"
                  } %></li>
</ul>

<h2>評論</h2>
<%= render @article.comments %>

<h2>新增評論：</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

這將使用 `app/views/comments/_comment.html.erb` 中的 partial 模板一次為 `@article.comments` 集合中的每個評論渲染一次。`render` 方法在迭代 `@article.comments` 集合時，將每個評論分配給一個名為 partial 的局部變量，此例中為 `comment`，該變量在 partial 中可供我們使用。

### 渲染部分表單

讓我們也將新增評論的部分移出到自己的 partial 中。同樣地，您可以創建一個文件 `app/views/comments/_form.html.erb`，其中包含以下內容：

```html+erb
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

然後，您可以將 `app/views/articles/show.html.erb` 修改為以下內容：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "編輯", edit_article_path(@article) %></li>
  <li><%= link_to "刪除", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "你確定嗎？"
                  } %></li>
</ul>

<h2>評論</h2>
<%= render @article.comments %>

<h2>新增評論：</h2>
<%= render 'comments/form' %>
```

第二個 `render` 只是定義了我們要渲染的 partial 模板，即 `comments/form`。Rails 足夠聰明，能夠識別字符串中的斜線，並意識到您要渲染 `app/views/comments` 目錄中的 `_form.html.erb` 文件。

`@article` 對象對於在視圖中渲染的任何 partial 都是可用的，因為我們將其定義為實例變量。

### 使用 Concerns

Concerns 是一種使大型控制器或模型更易於理解和管理的方法。這也具有當多個模型（或控制器）共享相同的關注點時可重用的優點。Concerns 使用包含表示模型或控制器負責的功能的明確切片的方法的模塊來實現。在其他語言中，模塊通常被稱為 mixin。
您可以像使用任何模組一樣在控制器或模型中使用concerns。當您使用`rails new blog`創建應用程序時，除了其他文件夾之外，`app/`下還創建了兩個文件夾：

```
app/controllers/concerns
app/models/concerns
```

在下面的示例中，我們將為我們的博客實現一個新功能，該功能將受益於使用concern。然後，我們將創建一個concern，並重構代碼以使用它，使代碼更加DRY和可維護。

博客文章可能具有各種狀態-例如，它可能對所有人可見（即`public`），或者只對作者可見（即`private`）。它也可能對所有人都是隱藏的，但仍然可檢索（即`archived`）。評論也可能是隱藏的或可見的。這可以使用每個模型中的`status`列來表示。

首先，讓我們運行以下遷移以將`status`添加到`Articles`和`Comments`：

```bash
$ bin/rails generate migration AddStatusToArticles status:string
$ bin/rails generate migration AddStatusToComments status:string
```

然後，讓我們使用生成的遷移更新數據庫：

```bash
$ bin/rails db:migrate
```

要為現有文章和評論選擇狀態，您可以通過添加`default: "public"`選項將默認值添加到生成的遷移文件中，然後再次運行遷移。您還可以在rails控制台中調用`Article.update_all(status: "public")`和`Comment.update_all(status: "public")`。

提示：要了解有關遷移的更多信息，請參閱[Active Record遷移](active_record_migrations.html)。

我們還必須將`：status`鍵許可為強參數的一部分，在`app/controllers/articles_controller.rb`中：

```ruby

  private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
```

以及在`app/controllers/comments_controller.rb`中：

```ruby

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

在`article`模型中，在運行使用`bin/rails db:migrate`命令添加`status`列的遷移之後，您可以添加：

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

以及在`Comment`模型中：

```ruby
class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

然後，在我們的`index`操作模板（`app/views/articles/index.html.erb`）中，我們將使用`archived?`方法來避免顯示任何已存檔的文章：

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

同樣，在我們的評論局部視圖（`app/views/comments/_comment.html.erb`）中，我們將使用`archived?`方法來避免顯示任何已存檔的評論：

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>
```

然而，如果您再次查看我們的模型，您會發現邏輯是重複的。如果在將來我們增加博客的功能-例如包括私人消息-我們可能會再次重複邏輯。這就是concerns派上用場的地方。

concerns只負責模型責任的一個專注子集；我們concern中的方法都與模型的可見性有關。讓我們稱這個新的concern（模組）為`Visible`。我們可以在`app/models/concerns`中創建一個名為`visible.rb`的新文件，並將所有在模型中重複的狀態方法存儲在其中。

`app/models/concerns/visible.rb`

```ruby
module Visible
  def archived?
    status == 'archived'
  end
end
```

我們可以將狀態驗證添加到concern中，但這稍微複雜一些，因為驗證是在類級別調用的方法。`ActiveSupport::Concern`（[API指南](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)）提供了一種更簡單的方式來包含它們：

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  def archived?
    status == 'archived'
  end
end
```

現在，我們可以從每個模型中刪除重複的邏輯，並包含我們的新`Visible`模組：

在`app/models/article.rb`中：

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

以及在`app/models/comment.rb`中：

```ruby
class Comment < ApplicationRecord
  include Visible

  belongs_to :article
end
```
類方法也可以添加到concerns中。如果我們想在主頁上顯示公開文章或評論的數量，可以像下面這樣在Visible模組中添加一個類方法：

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      where(status: 'public').count
    end
  end

  def archived?
    status == 'archived'
  end
end
```

然後在視圖中，可以像調用任何類方法一樣調用它：

```html+erb
<h1>文章</h1>

我們的博客有 <%= Article.public_count %> 篇文章，並且還在增加中！

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "新文章", new_article_path %>
```

接下來，我們將在表單中添加一個下拉框，讓用戶在創建新文章或發布新評論時選擇狀態。我們還可以將默認狀態設置為“public”。在`app/views/articles/_form.html.erb`中，我們可以添加：

```html+erb
<div>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</div>
```

在`app/views/comments/_form.html.erb`中添加：

```html+erb
<p>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</p>
```

刪除評論
----------

博客的另一個重要功能是能夠刪除垃圾評論。為此，我們需要在視圖中實現某種鏈接，並在`CommentsController`中實現一個`destroy`操作。

首先，在`app/views/comments/_comment.html.erb`局部視圖中添加刪除鏈接：

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>評論者：</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>評論：</strong>
    <%= comment.body %>
  </p>

  <p>
    <%= link_to "刪除評論", [comment.article, comment], data: {
                  turbo_method: :delete,
                  turbo_confirm: "確定要刪除嗎？"
                } %>
  </p>
<% end %>
```

點擊這個新的“刪除評論”鏈接將觸發一個`DELETE /articles/:article_id/comments/:id`請求到我們的`CommentsController`，然後可以使用這個請求找到要刪除的評論，因此讓我們在控制器中添加一個`destroy`操作（`app/controllers/comments_controller.rb`）：

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), status: :see_other
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
end
```

`destroy`操作將查找我們正在查看的文章，從`@article.comments`集合中找到評論，然後從數據庫中刪除它並將我們重定向到文章的show操作。

### 刪除相關對象

如果刪除一篇文章，相關的評論也需要被刪除，否則它們將佔據數據庫中的空間。Rails允許您使用關聯的`dependent`選項來實現這一點。修改Article模型（`app/models/article.rb`）如下：

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

安全性
--------

### 基本身份驗證

如果您將博客發布在網上，任何人都可以添加、編輯和刪除文章或刪除評論。

Rails提供了一個HTTP身份驗證系統，可以很好地應對這種情況。

在`ArticlesController`中，我們需要一種方法來阻止未經身份驗證的人訪問各種操作。在這裡，我們可以使用Rails的`http_basic_authenticate_with`方法，如果該方法允許訪問，則允許訪問所請求的操作。

要使用身份驗證系統，在我們的`ArticlesController`中的頂部指定它（`app/controllers/articles_controller.rb`）。在我們的情況下，我們希望在每個操作上都要求用戶進行身份驗證，除了`index`和`show`之外，所以我們寫下：

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # 省略部分代碼
```

我們還希望只允許經過身份驗證的用戶刪除評論，所以在`CommentsController`（`app/controllers/comments_controller.rb`）中寫下：

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # 省略部分代碼
```

現在，如果您嘗試創建一篇新文章，您將收到一個基本的HTTP身份驗證挑戰：

![Basic HTTP Authentication Challenge](images/getting_started/challenge.png)

在輸入正確的用戶名和密碼後，您將保持身份驗證，直到需要不同的用戶名和密碼或關閉瀏覽器。
Rails應用程序還提供其他身份驗證方法。Rails的兩個流行的身份驗證插件是[Devise](https://github.com/plataformatec/devise)引擎和[Authlogic](https://github.com/binarylogic/authlogic) gem，還有其他一些選項。

### 其他安全考慮事項

安全性，尤其是在Web應用程序中，是一個廣泛而詳細的領域。有關Rails應用程序的安全性更深入的內容可以在[Ruby on Rails安全指南](security.html)中找到。

接下來做什麼？
------------

既然您已經看到了第一個Rails應用程序，您可以隨意更新它並進行自己的實驗。

請記住，您不必一切都自己完成。當您需要幫助開始使用Rails時，可以請教以下支援資源：

* [Ruby on Rails指南](index.html)
* [Ruby on Rails郵件列表](https://discuss.rubyonrails.org/c/rubyonrails-talk)


配置注意事項
---------------------

使用Rails的最簡單方法是將所有外部數據存儲為UTF-8。如果不這樣做，Ruby庫和Rails通常能夠將您的本地數據轉換為UTF-8，但這並不總是可靠的，所以最好確保所有外部數據都是UTF-8。

如果在這方面犯了錯誤，最常見的症狀是在瀏覽器中出現一個帶有問號的黑色菱形。另一個常見的症狀是出現"Ã¼"這樣的字符，而不是"ü"。Rails採取了一些內部步驟來緩解這些問題的常見原因，可以自動檢測和修正。然而，如果您的外部數據不是以UTF-8存儲，偶爾可能會導致這些問題，Rails無法自動檢測和修正。

兩個非UTF-8的常見數據來源：

* 文本編輯器：大多數文本編輯器（如TextMate）默認將文件保存為UTF-8。如果您的文本編輯器不是這樣，這可能導致您在模板中輸入的特殊字符（如é）在瀏覽器中顯示為帶有問號的菱形。這也適用於i18n的翻譯文件。大多數不默認為UTF-8的編輯器（如某些版本的Dreamweaver）提供了更改默認為UTF-8的方法。請進行更改。
* 數據庫：Rails默認將數據庫中的數據轉換為UTF-8。但是，如果您的數據庫內部不使用UTF-8，則可能無法存儲用戶輸入的所有字符。例如，如果您的數據庫內部使用Latin-1，而用戶輸入俄語、希伯來語或日語字符，則一旦進入數據庫，數據將永遠丟失。如果可能，請使用UTF-8作為數據庫的內部存儲格式。
