**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2aedcd7fcf6f0b83538e8a8220d38afd
使用引擎入門
============================

在本指南中，您將學習有關引擎的知識，以及如何通過乾淨且非常易於使用的界面為宿主應用程序提供附加功能。

閱讀本指南後，您將了解：

* 引擎的特點。
* 如何生成引擎。
* 如何為引擎構建功能。
* 如何將引擎鉤接到應用程序中。
* 如何在應用程序中覆蓋引擎功能。
* 如何使用加載和配置鉤子避免加載Rails框架。

--------------------------------------------------------------------------------

什麼是引擎？
-----------------

引擎可以被視為為宿主應用程序提供功能的迷你應用程序。Rails應用程序實際上只是一個“超級”引擎，其中`Rails::Application`類繼承了大部分行為自`Rails::Engine`。

因此，引擎和應用程序可以被視為幾乎相同的東西，只是有些微的差異，正如您在本指南中所看到的。引擎和應用程序還共享一個常見的結構。

引擎與插件也密切相關。兩者共享一個常見的`lib`目錄結構，並且都使用`rails plugin new`生成器生成。不同之處在於，引擎被Rails視為“完整插件”（由傳遞給生成器命令的`--full`選項指示）。在本指南中，我們將使用`--mountable`選項，該選項包括`--full`的所有功能，以及更多其他功能。本指南將在整個過程中將這些“完整插件”簡單地稱為“引擎”。引擎**可以**是插件，插件**可以**是引擎。

在本指南中將創建的引擎將被稱為“blorgh”。該引擎將為其宿主應用程序提供博客功能，允許創建新文章和評論。在本指南的開始，您將僅在引擎本身內工作，但在後面的部分中，您將看到如何將其鉤接到應用程序中。

引擎還可以與宿主應用程序隔離。這意味著應用程序可以使用由路由助手（例如`articles_path`）提供的路徑，並使用同樣稱為`articles_path`的引擎提供的路徑，而兩者不會衝突。除此之外，控制器、模型和表名也是有命名空間的。您將在本指南的後面看到如何實現這一點。

重要的是要時刻牢記，應用程序應始終優先於其引擎。應用程序是在其環境中最終決定發生什麼的對象。引擎只應該增強它，而不是徹底改變它。

要查看其他引擎的演示，請查看[Devise](https://github.com/plataformatec/devise)，這是一個為其父應用程序提供身份驗證的引擎，或者[Thredded](https://github.com/thredded/thredded)，這是一個提供論壇功能的引擎。還有提供電子商務平台的[Spree](https://github.com/spree/spree)，以及一個CMS引擎[Refinery CMS](https://github.com/refinery/refinerycms)。

最後，引擎的實現離不開James Adam、Piotr Sarnacki、Rails核心團隊和其他一些人的工作。如果您遇到他們，別忘了說聲謝謝！

生成一個引擎
--------------------

要生成一個引擎，您需要運行插件生成器並根據需要傳遞適當的選項。對於“blorgh”示例，您需要創建一個“mountable”引擎，在終端中運行以下命令：

```bash
$ rails plugin new blorgh --mountable
```

插件生成器的完整選項列表可以通過輸入以下命令查看：

```bash
$ rails plugin --help
```

`--mountable`選項告訴生成器您要創建一個“mountable”和命名空間隔離的引擎。此生成器將提供與`--full`選項相同的骨架結構。`--full`選項告訴生成器您要創建一個引擎，包括提供以下內容的骨架結構：

  * 一個`app`目錄樹
  * 一個`config/routes.rb`文件：

    ```ruby
    Rails.application.routes.draw do
    end
    ```

  * 一個位於`lib/blorgh/engine.rb`的文件，其功能與標準Rails應用程序的`config/application.rb`文件相同：

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
      end
    end
    ```

`--mountable`選項將添加到`--full`選項中：

  * 資源清單文件（`blorgh_manifest.js`和`application.css`）
  * 帶有命名空間的`ApplicationController`存根
  * 帶有命名空間的`ApplicationHelper`存根
  * 引擎的佈局視圖模板
  * 將命名空間隔離到`config/routes.rb`中：
```ruby
Blorgh::Engine.routes.draw do
end
```

* 將命名空間隔離到 `lib/blorgh/engine.rb`：

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

此外，`--mountable` 選項告訴生成器將引擎安裝在位於 `test/dummy` 的測試應用程式中，方法是在測試應用程式的路由文件 `test/dummy/config/routes.rb` 中添加以下內容：

```ruby
mount Blorgh::Engine => "/blorgh"
```

### 在引擎內部

#### 重要檔案

在這個全新引擎目錄的根目錄下有一個 `blorgh.gemspec` 檔案。當你稍後將引擎包含到應用程式中時，你將在 Rails 應用程式的 `Gemfile` 中使用這行：

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

不要忘記像往常一樣運行 `bundle install`。通過在 `Gemfile` 中指定它為一個 gem，Bundler 將以此方式加載它，解析 `blorgh.gemspec` 檔案並要求 `lib` 目錄中的 `lib/blorgh.rb` 檔案。這個檔案要求 `blorgh/engine.rb` 檔案（位於 `lib/blorgh/engine.rb`），並定義了一個名為 `Blorgh` 的基礎模組。

```ruby
require "blorgh/engine"

module Blorgh
end
```

提示：一些引擎選擇使用這個檔案來放置引擎的全局配置選項。這是一個相對不錯的主意，所以如果你想提供配置選項，你的引擎的 `module` 定義的檔案非常適合。將方法放在模組內部，你就可以使用它們了。

在 `lib/blorgh/engine.rb` 中是引擎的基類：

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

通過繼承 `Rails::Engine` 類，這個 gem 通知 Rails 在指定的路徑上有一個引擎，並將引擎正確地安裝在應用程式中，執行諸如將引擎的 `app` 目錄添加到模型、郵件、控制器和視圖的加載路徑等任務。

這裡的 `isolate_namespace` 方法值得特別注意。這個調用負責將控制器、模型、路由和其他東西隔離到它們自己的命名空間中，遠離應用程式中的相似組件。如果沒有這個方法，引擎的組件可能會「洩漏」到應用程式中，造成不需要的干擾，或者重要的引擎組件可能會被應用程式中同名的東西覆蓋。其中一個這種衝突的例子是幫助器。如果不調用 `isolate_namespace`，引擎的幫助器將包含在應用程式的控制器中。

注意：**強烈建議**在 `Engine` 類定義中保留 `isolate_namespace` 行。如果沒有它，引擎中生成的類可能會與應用程式發生衝突。

命名空間的隔離意味著通過 `bin/rails generate model` 生成的模型（例如 `bin/rails generate model article`）不會被稱為 `Article`，而是被命名空間化為 `Blorgh::Article`。此外，模型的表也被命名空間化，變成 `blorgh_articles`，而不僅僅是 `articles`。與模型命名空間化類似，名為 `ArticlesController` 的控制器變成 `Blorgh::ArticlesController`，該控制器的視圖不會位於 `app/views/articles`，而是位於 `app/views/blorgh/articles`。郵件、作業和幫助器也是命名空間化的。

最後，路由也將在引擎內部進行隔離。這是關於命名空間的最重要部分之一，將在本指南的 [路由](#routes) 部分中進行討論。

#### `app` 目錄

在 `app` 目錄中有標準的 `assets`、`controllers`、`helpers`、`jobs`、`mailers`、`models` 和 `views` 目錄，你應該對它們很熟悉，因為它們與應用程式非常相似。我們將在未來的一節中更深入地研究模型，當我們正在編寫引擎時。

在 `app/assets` 目錄中，有 `images` 和 `stylesheets` 目錄，你也應該對它們很熟悉，因為它們與應用程式非常相似。然而，這裡的一個不同之處是，每個目錄都包含一個帶有引擎名稱的子目錄。因為這個引擎將被命名空間化，所以它的資源也應該是如此。

在 `app/controllers` 目錄中有一個 `blorgh` 目錄，其中包含一個名為 `application_controller.rb` 的檔案。這個檔案將為引擎的控制器提供任何共用功能。`blorgh` 目錄是引擎的其他控制器的所在地。通過將它們放在這個命名空間目錄中，你可以防止它們可能與其他引擎甚至應用程式中同名的控制器發生衝突。

注意：引擎內部的 `ApplicationController` 類的命名方式與 Rails 應用程式相同，這樣你就可以更輕鬆地將應用程式轉換為引擎。
注意：如果父應用程式運行在`classic`模式下，可能會遇到引擎控制器繼承自主應用程式控制器而不是引擎的應用程式控制器的情況。防止這種情況發生的最好方法是在父應用程式中切換到`zeitwerk`模式。否則，使用`require_dependency`確保引擎的應用程式控制器被加載。例如：

```ruby
# 只在`classic`模式下需要。
require_dependency "blorgh/application_controller"

module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

警告：不要使用`require`，因為它會破壞開發環境中的類自動重新加載 - 使用`require_dependency`可以確保類以正確的方式加載和卸載。

就像`app/controllers`一樣，您會在`app/helpers`、`app/jobs`、`app/mailers`和`app/models`目錄下找到`blorgh`子目錄，其中包含用於收集常用功能的相關`application_*.rb`文件。通過將文件放在此子目錄下並對對象進行命名空間處理，可以防止它們可能與其他引擎甚至應用程式中的具有相同名稱的元素發生衝突。

最後，`app/views`目錄包含一個`layouts`文件夾，其中包含一個位於`blorgh/application.html.erb`的文件。此文件允許您為引擎指定佈局。如果此引擎將用作獨立引擎，則應在此文件中添加任何自定義佈局，而不是應用程式的`app/views/layouts/application.html.erb`文件。

如果您不想對引擎的使用者強制使用佈局，則可以刪除此文件並在引擎的控制器中引用不同的佈局。

#### `bin`目錄

此目錄包含一個文件`bin/rails`，它使您能夠像在應用程式中一樣使用`rails`子命令和生成器。這意味著您可以通過運行以下命令來輕鬆生成此引擎的新控制器和模型：

```bash
$ bin/rails generate model
```

當然，請記住，在具有`Engine`類中的`isolate_namespace`的引擎內部生成的任何內容都將被命名空間化。

#### `test`目錄

`test`目錄是用於引擎測試的地方。要測試引擎，其中嵌入了一個簡化版本的Rails應用程式，位於`test/dummy`中。此應用程式將在`test/dummy/config/routes.rb`文件中安裝引擎：

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

此行將引擎安裝在路徑`/blorgh`，這將使其僅通過應用程式在該路徑下訪問。

在測試目錄中，還有`test/integration`目錄，用於放置引擎的集成測試。也可以在`test`目錄中創建其他目錄。例如，您可能希望為模型測試創建一個`test/models`目錄。

提供引擎功能
------------------------------

本指南涵蓋的引擎提供了提交文章和評論功能，並遵循與[入門指南](getting_started.html)類似的流程，但有一些新的變化。

注意：在本節中，請確保在`blorgh`引擎目錄的根目錄中運行命令。

### 生成文章資源

為部落格引擎生成的第一個資源是`Article`模型和相關的控制器。要快速生成這個，您可以使用Rails的脚手架生成器。

```bash
$ bin/rails generate scaffold article title:string text:text
```

此命令將輸出以下信息：

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_articles.rb
create    app/models/blorgh/article.rb
invoke    test_unit
create      test/models/blorgh/article_test.rb
create      test/fixtures/blorgh/articles.yml
invoke  resource_route
 route    resources :articles
invoke  scaffold_controller
create    app/controllers/blorgh/articles_controller.rb
invoke    erb
create      app/views/blorgh/articles
create      app/views/blorgh/articles/index.html.erb
create      app/views/blorgh/articles/edit.html.erb
create      app/views/blorgh/articles/show.html.erb
create      app/views/blorgh/articles/new.html.erb
create      app/views/blorgh/articles/_form.html.erb
invoke    test_unit
create      test/controllers/blorgh/articles_controller_test.rb
create      test/system/blorgh/articles_test.rb
invoke    helper
create      app/helpers/blorgh/articles_helper.rb
invoke      test_unit
```

脚手架生成器首先調用`active_record`生成器，生成一個遷移和一個資源的模型。請注意，這裡的遷移被稱為`create_blorgh_articles`，而不是通常的`create_articles`。這是由於在`Blorgh::Engine`類的定義中調用了`isolate_namespace`方法。這裡的模型也是命名空間的，放在`app/models/blorgh/article.rb`而不是`app/models/article.rb`，這是由於`Engine`類中的`isolate_namespace`調用。

接下來，為此模型調用了`test_unit`生成器，生成了一個模型測試`test/models/blorgh/article_test.rb`（而不是`test/models/article_test.rb`）和一個fixture`test/fixtures/blorgh/articles.yml`（而不是`test/fixtures/articles.yml`）。

之後，在引擎的`config/routes.rb`文件中插入了一行資源的路由。這行代碼只是`resources :articles`，將引擎的`config/routes.rb`文件變成以下內容：
```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

注意這裡的路由是在 `Blorgh::Engine` 物件上繪製，而不是在 `YourApp::Application` 類別上。這樣做是為了將引擎的路由限制在引擎本身內，並且可以在 [測試目錄](#test-directory) 章節中指定掛載點。這也使得引擎的路由與應用程式內的路由相互隔離。本指南的 [路由](#routes) 章節會詳細描述此內容。

接下來，呼叫 `scaffold_controller` 產生器，生成一個名為 `Blorgh::ArticlesController` 的控制器（位於 `app/controllers/blorgh/articles_controller.rb`），以及相關的視圖（位於 `app/views/blorgh/articles`）。此產生器還會為控制器生成測試（`test/controllers/blorgh/articles_controller_test.rb` 和 `test/system/blorgh/articles_test.rb`）以及助手（`app/helpers/blorgh/articles_helper.rb`）。

此產生器所創建的所有內容都有良好的命名空間。控制器的類別定義在 `Blorgh` 模組內：

```ruby
module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

注意：`ArticlesController` 類別繼承自 `Blorgh::ApplicationController`，而不是應用程式的 `ApplicationController`。

`app/helpers/blorgh/articles_helper.rb` 內的助手也有命名空間：

```ruby
module Blorgh
  module ArticlesHelper
    # ...
  end
end
```

這有助於避免與其他可能也有文章資源的引擎或應用程式產生衝突。

你可以執行 `bin/rails db:migrate` 在引擎的根目錄下執行由 scaffold 產生器生成的遷移，然後在 `test/dummy` 中執行 `bin/rails server`，以查看引擎目前的狀態。當你打開 `http://localhost:3000/blorgh/articles` 時，你將看到生成的預設 scaffold。點擊一下！你剛剛生成了你的第一個引擎的第一個功能。

如果你想在控制台中進行操作，`bin/rails console` 也可以像 Rails 應用程式一樣運作。請記住：`Article` 模型有命名空間，所以要引用它，你必須使用 `Blorgh::Article`。

```irb
irb> Blorgh::Article.find(1)
=> #<Blorgh::Article id: 1 ...>
```

最後一件事是，這個引擎的 `articles` 資源應該成為引擎的根。當有人訪問引擎掛載的根路徑時，他們應該看到一個文章列表。如果在引擎的 `config/routes.rb` 檔案中插入以下行：

```ruby
root to: "articles#index"
```

現在人們只需要前往引擎的根目錄就可以看到所有的文章，而不需要訪問 `/articles`。這意味著你只需要前往 `http://localhost:3000/blorgh`，而不是 `http://localhost:3000/blorgh/articles`。

### 生成評論資源

現在引擎可以創建新文章，也有意義添加評論功能。為此，你需要生成一個評論模型、一個評論控制器，然後修改文章 scaffold 以顯示評論並允許人們創建新評論。

從引擎根目錄執行模型生成器。告訴它生成一個 `Comment` 模型，相關的資料表有兩個欄位：一個 `article_id` 整數欄位和一個 `text` 文字欄位。

```bash
$ bin/rails generate model Comment article_id:integer text:text
```

這將輸出以下內容：

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_comments.rb
create    app/models/blorgh/comment.rb
invoke    test_unit
create      test/models/blorgh/comment_test.rb
create      test/fixtures/blorgh/comments.yml
```

這個生成器呼叫將只生成所需的模型檔案，將檔案命名空間化到 `blorgh` 目錄下，並創建一個名為 `Blorgh::Comment` 的模型類別。現在執行遷移以創建我們的 `blorgh_comments` 資料表：

```bash
$ bin/rails db:migrate
```

為了在文章上顯示評論，編輯 `app/views/blorgh/articles/show.html.erb`，在 "Edit" 連結之前添加以下行：

```html+erb
<h3>Comments</h3>
<%= render @article.comments %>
```

這行需要在 `Blorgh::Article` 模型上定義一個 `has_many` 關聯的評論，目前還沒有這樣的關聯。要定義這個關聯，打開 `app/models/blorgh/article.rb`，並在模型中添加以下行：

```ruby
has_many :comments
```

將模型變成這樣：

```ruby
module Blorgh
  class Article < ApplicationRecord
    has_many :comments
  end
end
```

注意：由於 `has_many` 定義在 `Blorgh` 模組內的類別內，Rails 將知道你想要使用 `Blorgh::Comment` 模型作為這些物件的模型，因此在這裡不需要使用 `:class_name` 選項指定。

接下來，需要一個表單，以便在文章上創建評論。為了添加這個，將以下行放在 `app/views/blorgh/articles/show.html.erb` 中 `render @article.comments` 的下面：

```erb
<%= render "blorgh/comments/form" %>
```

接下來，這行將渲染的局部視圖需要存在。在 `app/views/blorgh/comments` 中創建一個新的目錄，並在其中創建一個名為 `_form.html.erb` 的新檔案，其內容如下以創建所需的局部視圖：
```html+erb
<h3>新增評論</h3>
<%= form_with model: [@article, @article.comments.build] do |form| %>
  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>
  <%= form.submit %>
<% end %>
```

當這個表單被提交時，它將嘗試執行一個 `POST` 請求到引擎內的 `/articles/:article_id/comments` 路由。目前這個路由不存在，但可以通過將 `config/routes.rb` 內的 `resources :articles` 改為以下代碼來創建：

```ruby
resources :articles do
  resources :comments
end
```

這將為評論創建一個嵌套路由，這是表單所需的。

現在路由已經存在，但是該路由指向的控制器還不存在。要創建它，請從引擎根目錄運行以下命令：

```bash
$ bin/rails generate controller comments
```

這將生成以下內容：

```
create  app/controllers/blorgh/comments_controller.rb
invoke  erb
 exist    app/views/blorgh/comments
invoke  test_unit
create    test/controllers/blorgh/comments_controller_test.rb
invoke  helper
create    app/helpers/blorgh/comments_helper.rb
invoke    test_unit
```

該表單將發送一個 `POST` 請求到 `/articles/:article_id/comments`，這將對應到 `Blorgh::CommentsController` 內的 `create` 動作。這個動作需要被創建，可以通過將以下代碼放在 `app/controllers/blorgh/comments_controller.rb` 內的類定義中來實現：

```ruby
def create
  @article = Article.find(params[:article_id])
  @comment = @article.comments.create(comment_params)
  flash[:notice] = "評論已創建！"
  redirect_to articles_path
end

private
  def comment_params
    params.require(:comment).permit(:text)
  end
```

這是使新評論表單正常工作所需的最後一步。然而，顯示評論的部分還不完整。如果現在創建一個評論，你會看到以下錯誤：

```
Missing partial blorgh/comments/_comment with {:handlers=>[:erb, :builder],
:formats=>[:html], :locale=>[:en, :en]}. Searched in:   *
"/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"   *
"/Users/ryan/Sites/side_projects/blorgh/app/views"
```

引擎無法找到用於渲染評論的部分。Rails 首先在應用程序的 (`test/dummy`) `app/views` 目錄中查找，然後在引擎的 `app/views` 目錄中查找。當找不到時，它會拋出此錯誤。引擎知道要查找 `blorgh/comments/_comment`，因為它收到的模型對象來自 `Blorgh::Comment` 類。

這個部分將負責僅渲染評論文本。在 `app/views/blorgh/comments/_comment.html.erb` 創建一個新文件，並將以下代碼放入其中：

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

`comment_counter` 本地變量是由 `<%= render @article.comments %>` 調用提供的，它將自動定義並在遍歷每個評論時遞增計數器。在這個例子中，它用於在每個評論旁邊顯示一個小數字。

這完成了博客引擎的評論功能。現在是時候在應用程序中使用它了。

將引擎集成到應用程序中
---------------------------

在應用程序中使用引擎非常簡單。本節介紹了如何將引擎掛載到應用程序中以及所需的初始設置，以及將引擎與應用程序提供的 `User` 類關聯起來，以提供對引擎內文章和評論的所有權。

### 掛載引擎

首先，需要在應用程序的 `Gemfile` 中指定引擎。如果沒有現成的應用程序可以測試，可以使用 `rails new` 命令在引擎目錄之外生成一個應用程序，如下所示：

```bash
$ rails new unicorn
```

通常，將引擎指定在 `Gemfile` 中可以像指定普通的 gem 一樣進行。

```ruby
gem 'devise'
```

然而，因為你是在本地開發 `blorgh` 引擎，所以需要在 `Gemfile` 中指定 `:path` 選項：

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

然後運行 `bundle` 命令安裝 gem。

如前所述，將 gem 放在 `Gemfile` 中，Rails 加載時會加載它。它首先從引擎中的 `lib/blorgh.rb` 加載，然後加載 `lib/blorgh/engine.rb`，這個文件定義了引擎的主要功能。

要使引擎的功能在應用程序內可用，需要在應用程序的 `config/routes.rb` 文件中將其掛載：

```ruby
mount Blorgh::Engine, at: "/blog"
```

這行代碼將引擎掛載在應用程序的 `/blog` 路徑上。當應用程序使用 `bin/rails server` 運行時，可以在 `http://localhost:3000/blog` 上訪問它。

注意：其他引擎（例如 Devise）的處理方式略有不同，它讓你在路由中指定自定義的幫助方法（例如 `devise_for`）。這些幫助方法的功能完全相同，將引擎的功能的各個部分掛載在預定義的路徑上，這些路徑可以自定義。
### 引擎設置

引擎包含了 `blorgh_articles` 和 `blorgh_comments` 表的遷移，需要在應用程序的數據庫中創建這些表，以便引擎的模型能夠正確地查詢它們。要將這些遷移複製到應用程序中，請從應用程序的根目錄運行以下命令：

```bash
$ bin/rails blorgh:install:migrations
```

如果您有多個需要複製遷移的引擎，請改用 `railties:install:migrations`：

```bash
$ bin/rails railties:install:migrations
```

您可以通過指定 MIGRATIONS_PATH 來在源引擎中指定遷移的自定義路徑。

```bash
$ bin/rails railties:install:migrations MIGRATIONS_PATH=db_blourgh
```

如果您有多個數據庫，您還可以通過指定 DATABASE 來指定目標數據庫。

```bash
$ bin/rails railties:install:migrations DATABASE=animals
```

第一次運行此命令時，將複製引擎中的所有遷移。下一次運行時，它只會複製尚未複製的遷移。第一次運行此命令時，將輸出如下內容：

```
從 blorgh 複製遷移 [timestamp_1]_create_blorgh_articles.blorgh.rb
從 blorgh 複製遷移 [timestamp_2]_create_blorgh_comments.blorgh.rb
```

第一個時間戳（`[timestamp_1]`）將是當前時間，第二個時間戳（`[timestamp_2]`）將是當前時間加一秒。這樣做的原因是，引擎的遷移將在應用程序中的任何現有遷移之後運行。

要在應用程序的上下文中運行這些遷移，只需運行 `bin/rails db:migrate`。當通過 `http://localhost:3000/blog` 訪問引擎時，文章將是空的。這是因為在應用程序內創建的表與引擎內創建的表不同。請隨意使用新安裝的引擎進行操作。您會發現它與只是一個引擎時一樣。

如果您只想運行一個引擎的遷移，可以通過指定 `SCOPE` 來實現：

```bash
$ bin/rails db:migrate SCOPE=blorgh
```

如果您想在刪除引擎之前還原引擎的所有遷移，可以運行以下代碼：

```bash
$ bin/rails db:migrate SCOPE=blorgh VERSION=0
```

### 使用應用程序提供的類

#### 使用應用程序提供的模型

當創建一個引擎時，它可能希望使用應用程序中的特定類來提供引擎的各個部分和應用程序的各個部分之間的鏈接。對於 `blorgh` 引擎來說，讓文章和評論擁有作者是很有意義的。

一個典型的應用程序可能有一個 `User` 類，用於表示文章或評論的作者。但是也可能存在一種情況，應用程序將此類稱為其他名稱，例如 `Person`。因此，引擎不應該為 `User` 類硬編碼關聯。

為了保持簡單，在這種情況下，應用程序將有一個名為 `User` 的類，用於表示應用程序的用戶（我們將在後面進一步討論如何使其可配置）。可以使用以下命令在應用程序內生成它：

```bash
$ bin/rails generate model user name:string
```

需要在這裡運行 `bin/rails db:migrate` 命令，以確保我們的應用程序具有 `users` 表供將來使用。

同樣，為了保持簡單，文章表單將添加一個名為 `author_name` 的新文本字段，用戶可以在其中填寫自己的名字。然後，引擎將使用這個名字來創建一個新的 `User` 對象，或者找到一個已經具有該名字的對象。然後，引擎將將文章與找到或創建的 `User` 對象關聯起來。

首先，需要在引擎內的 `app/views/blorgh/articles/_form.html.erb` 部分添加 `author_name` 文本字段。可以使用以下代碼在 `title` 字段上方添加它：

```html+erb
<div class="field">
  <%= form.label :author_name %><br>
  <%= form.text_field :author_name %>
</div>
```

接下來，我們需要更新 `Blorgh::ArticlesController#article_params` 方法，以允許新的表單參數：

```ruby
def article_params
  params.require(:article).permit(:title, :text, :author_name)
end
```

然後，`Blorgh::Article` 模型應該有一些代碼，將 `author_name` 字段轉換為實際的 `User` 對象，並在保存文章之前將其關聯為該文章的 `author`。它還需要為此字段設置 `attr_accessor`，以便為其定義 setter 和 getter 方法。

要做到這一點，您需要在 `app/models/blorgh/article.rb` 中添加 `author_name` 的 `attr_accessor`，作者的關聯以及 `before_validation` 調用。目前，`author` 關聯將硬編碼為 `User` 類。
```ruby
attr_accessor :author_name
belongs_to :author, class_name: "User"

before_validation :set_author

private
  def set_author
    self.author = User.find_or_create_by(name: author_name)
  end
```

透過將`author`關聯的物件表示為`User`類別，建立了引擎和應用程式之間的連結。需要一種方式將`blorgh_articles`表格中的記錄與`users`表格中的記錄關聯起來。由於關聯被稱為`author`，所以應在`blorgh_articles`表格中添加一個`author_id`欄位。

要生成這個新欄位，請在引擎內執行以下命令：

```bash
$ bin/rails generate migration add_author_id_to_blorgh_articles author_id:integer
```

注意：由於遷移的名稱和後面的欄位規範，Rails將自動知道您要向特定表格添加一個欄位並將其寫入遷移中。您不需要告訴它更多。

這個遷移需要在應用程式上執行。為此，必須使用以下命令將其複製：

```bash
$ bin/rails blorgh:install:migrations
```

請注意，這裡只複製了一個遷移。這是因為第一次執行此命令時，只複製了前兩個遷移。

```
注意 遷移 [timestamp]_create_blorgh_articles.blorgh.rb 已被跳過。已存在具有相同名稱的遷移。
注意 遷移 [timestamp]_create_blorgh_comments.blorgh.rb 已被跳過。已存在具有相同名稱的遷移。
從 blorgh 複製遷移 [timestamp]_add_author_id_to_blorgh_articles.blorgh.rb
```

使用以下命令運行遷移：

```bash
$ bin/rails db:migrate
```

現在，所有的元件都就位了，將進行一個動作，將一個作者（由`users`表格中的記錄表示）與一篇文章（由引擎的`blorgh_articles`表格表示）關聯起來。

最後，在文章的頁面上顯示作者的名稱。在`app/views/blorgh/articles/show.html.erb`中的「Title」輸出上方添加以下代碼：

```html+erb
<p>
  <b>作者：</b>
  <%= @article.author.name %>
</p>
```

#### 使用應用程式提供的控制器

由於Rails控制器通常共享身份驗證和訪問會話變數等代碼，它們默認繼承自`ApplicationController`。然而，Rails引擎被限定在獨立運行於主應用程式之外的範圍內，因此每個引擎都有一個範圍限定的`ApplicationController`。這個命名空間可以防止代碼衝突，但是引擎控制器通常需要訪問主應用程式的`ApplicationController`中的方法。提供此訪問的一種簡單方法是將引擎的範圍限定`ApplicationController`更改為繼承自主應用程式的`ApplicationController`。對於我們的Blorgh引擎，可以通過將`app/controllers/blorgh/application_controller.rb`更改為以下內容來完成：

```ruby
module Blorgh
  class ApplicationController < ::ApplicationController
  end
end
```

默認情況下，引擎的控制器繼承自`Blorgh::ApplicationController`。所以，在進行這個更改後，它們將可以訪問主應用程式的`ApplicationController`，就像它們是主應用程式的一部分一樣。

這個更改需要在具有`ApplicationController`的Rails應用程式中運行引擎。

### 配置引擎

本節介紹如何使`User`類別可配置，然後是引擎的一般配置提示。

#### 在應用程式中設置配置設定

下一步是使應用程式中表示`User`的類別可供引擎自定義。這是因為該類別可能並不總是`User`，如前面所述。為了使此設置可自定義，引擎將具有一個名為`author_class`的配置設定，用於指定在應用程式內表示使用者的類別。

要定義這個配置設定，應在引擎的`Blorgh`模組內使用`mattr_accessor`。將以下行添加到引擎內的`lib/blorgh.rb`中：

```ruby
mattr_accessor :author_class
```

這個方法的工作方式類似於它的兄弟方法`attr_accessor`和`cattr_accessor`，但是在模組上提供了一個具有指定名稱的設置器和取值器方法。要使用它，必須使用`Blorgh.author_class`來引用它。

下一步是將`Blorgh::Article`模型切換到這個新設定。將此模型（`app/models/blorgh/article.rb`）內的`belongs_to`關聯改為以下內容：

```ruby
belongs_to :author, class_name: Blorgh.author_class
```

`Blorgh::Article`模型中的`set_author`方法也應使用這個類別：

```ruby
self.author = Blorgh.author_class.constantize.find_or_create_by(name: author_name)
```

為了避免每次都在`author_class`結果上調用`constantize`，您可以在`lib/blorgh.rb`文件的`Blorgh`模組內覆蓋`author_class`取值器方法，以始終在返回結果之前對保存的值調用`constantize`：
```ruby
def self.author_class
  @@author_class.constantize
end
```

這樣，`set_author` 的程式碼就會變成這樣：

```ruby
self.author = Blorgh.author_class.find_or_create_by(name: author_name)
```

這樣的結果會更簡潔，且行為更隱含。`author_class` 方法應該總是返回一個 `Class` 物件。

由於我們將 `author_class` 方法改為返回 `Class` 而不是 `String`，我們還必須修改 `Blorgh::Article` 模型中的 `belongs_to` 定義：

```ruby
belongs_to :author, class_name: Blorgh.author_class.to_s
```

要在應用程式中設置這個配置設定，應該使用一個初始化器。通過使用初始化器，配置將在應用程式啟動之前設置好，並調用引擎的模型，這些模型可能依賴於這個配置設定的存在。

在安裝了 `blorgh` 引擎的應用程式中，創建一個新的初始化器 `config/initializers/blorgh.rb`，並將以下內容放入其中：

```ruby
Blorgh.author_class = "User"
```

警告：在這裡非常重要的是使用類的「字串」版本，而不是類本身。如果使用類本身，Rails 將嘗試加載該類，然後引用相關的表。如果表尚不存在，這可能會導致問題。因此，應該使用一個「字串」，然後在引擎中使用 `constantize` 將其轉換為類。

現在，嘗試創建一個新的文章。你會發現它的工作方式與之前完全相同，只是這次引擎使用了 `config/initializers/blorgh.rb` 中的配置設定來獲取類。

現在，對類的要求不再嚴格依賴於它是什麼，只要求它的 API 是什麼。引擎只需要這個類定義一個 `find_or_create_by` 方法，該方法返回一個該類的對象，以便在創建文章時與之關聯。當然，這個對象應該有一個可以引用它的某種標識符。

#### 通用引擎配置

在引擎中，可能會有一個時機希望使用初始化器、國際化或其他配置選項。好消息是，這些事情是完全可能的，因為 Rails 引擎與 Rails 應用程式共享了很多功能。實際上，Rails 應用程式的功能實際上是引擎提供的功能的超集！

如果你希望使用初始化器 - 在引擎加載之前運行的代碼 - 則應該將其放在 `config/initializers` 文件夾中。這個目錄的功能在配置指南的 [初始化器部分](configuring.html#initializers) 中有解釋，並且與應用程式內部的 `config/initializers` 目錄完全相同。如果你想使用標準的初始化器，也是一樣的。

對於本地化，只需將本地化文件放在 `config/locales` 目錄中，就像在應用程式中一樣。

測試引擎
-----------------

當生成引擎時，會在其中創建一個較小的虛擬應用程式，位於 `test/dummy`。這個應用程式用作引擎的掛載點，使測試引擎變得非常簡單。您可以通過在該目錄中生成控制器、模型或視圖，然後使用它們來測試引擎。

`test` 目錄應該像一個典型的 Rails 測試環境一樣對待，允許進行單元測試、功能測試和集成測試。

### 功能測試

在編寫功能測試時，值得考慮的一個問題是測試將在一個應用程式上運行 - `test/dummy` 應用程式 - 而不是你的引擎上。這是由於測試環境的設置；引擎需要一個應用程式作為主機能的測試主機，特別是控制器。這意味著，如果您在控制器的功能測試中對控制器進行典型的 `GET`，像這樣：

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def test_index
      get foos_url
      # ...
    end
  end
end
```

它可能無法正常運作。這是因為應用程式不知道如何將這些請求路由到引擎，除非您明確告訴它**如何**。為此，您必須在設置代碼中將 `@routes` 實例變量設置為引擎的路由集：

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_index
      get foos_url
      # ...
    end
  end
end
```

這告訴應用程式，您仍然希望對此控制器的`index`動作執行`GET`請求，但您希望使用引擎的路由來達到目的，而不是應用程式的路由。

這也確保引擎的URL助手在測試中按預期工作。

改進引擎功能
------------------------------

本節將解釋如何在主要的Rails應用程式中添加和/或覆蓋引擎的MVC功能。

### 覆蓋模型和控制器

父應用程式可以重新打開引擎的模型和控制器以擴展或裝飾它們。

覆蓋可以組織在專用目錄`app/overrides`中，該目錄被自動載入器忽略，並在`to_prepare`回調中預加載：

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        load override
      end
    end
  end
end
```

#### 使用`class_eval`重新打開現有類別

例如，為了覆蓋引擎模型

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    # ...
  end
end
```

您只需創建一個重新打開該類別的文件：

```ruby
# MyApp/app/overrides/models/blorgh/article_override.rb
Blorgh::Article.class_eval do
  # ...
end
```

非常重要的是，覆蓋要重新打開類別或模組。如果它們尚未在內存中，使用`class`或`module`關鍵字將定義它們，這是不正確的，因為定義位於引擎中。如上所示使用`class_eval`確保您正在重新打開。

#### 使用ActiveSupport::Concern重新打開現有類別

使用`Class#class_eval`非常適合進行簡單的調整，但對於更複雜的類別修改，您可能需要考慮使用[`ActiveSupport::Concern`](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)。ActiveSupport::Concern在運行時管理相互關聯的依賴模組和類別的加載順序，使您能夠顯著模組化代碼。

**添加**`Article#time_since_created`和**覆蓋**`Article#summary`：

```ruby
# MyApp/app/models/blorgh/article.rb

class Blorgh::Article < ApplicationRecord
  include Blorgh::Concerns::Models::Article

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    include Blorgh::Concerns::Models::Article
  end
end
```

```ruby
# Blorgh/lib/concerns/models/article.rb

module Blorgh::Concerns::Models::Article
  extend ActiveSupport::Concern

  # `included do`導致塊在模組被包含的上下文中求值（即Blorgh::Article），
  # 而不是在模組本身中求值。
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_validation :set_author

    private
      def set_author
        self.author = User.find_or_create_by(name: author_name)
      end
  end

  def summary
    "#{title}"
  end

  module ClassMethods
    def some_class_method
      'some class method string'
    end
  end
end
```

### 自動載入和引擎

有關自動載入和引擎的更多信息，請參閱[自動載入和重新加載常量](autoloading_and_reloading_constants.html#autoloading-and-engines)指南。


### 覆蓋視圖

當Rails尋找要呈現的視圖時，它首先會在應用程式的`app/views`目錄中尋找。如果在該目錄中找不到視圖，則會在所有具有此目錄的引擎的`app/views`目錄中進行檢查。

當應用程式被要求呈現`Blorgh::ArticlesController`的索引動作的視圖時，它首先會在應用程式內部尋找路徑`app/views/blorgh/articles/index.html.erb`。如果找不到，它會在引擎內部尋找。

您可以通過在應用程式中簡單地創建一個新文件`app/views/blorgh/articles/index.html.erb`來覆蓋此視圖。然後，您可以完全更改此視圖通常會輸出的內容。

現在嘗試創建一個新文件`app/views/blorgh/articles/index.html.erb`，並將以下內容放入其中：

```html+erb
<h1>Articles</h1>
<%= link_to "New Article", new_article_path %>
<% @articles.each do |article| %>
  <h2><%= article.title %></h2>
  <small>By <%= article.author %></small>
  <%= simple_format(article.text) %>
  <hr>
<% end %>
```

### 路由

引擎內部的路由默認情況下與應用程式隔離。這是在`Engine`類別內部的`isolate_namespace`調用中完成的。這基本上意味著應用程式及其引擎可以具有相同名稱的路由，而它們不會衝突。

引擎內部的路由在`config/routes.rb`中的`Engine`類別上繪製，如下所示：

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

通過具有這樣的隔離路由，如果您希望從應用程式內部鏈接到引擎的某個區域，您將需要使用引擎的路由代理方法。如果應用程式和引擎都定義了這樣的助手，對常規路由方法（如`articles_path`）的調用可能會最終轉到不希望的位置。

例如，如果從應用程式渲染該模板，以下示例將轉到應用程式的`articles_path`，如果從引擎渲染，則轉到引擎的`articles_path`：
```erb
<%= link_to "部落格文章", articles_path %>
```

為了讓這個路由總是使用引擎的 `articles_path` 路由輔助方法，我們必須在與引擎同名的路由代理方法上調用該方法。

```erb
<%= link_to "部落格文章", blorgh.articles_path %>
```

如果您希望以類似的方式引用引擎內的應用程式，請使用 `main_app` 輔助方法：

```erb
<%= link_to "首頁", main_app.root_path %>
```

如果您在引擎內的模板中使用應用程式的路由輔助方法，可能會出現未定義的方法呼叫錯誤。如果遇到此問題，請確保您在引擎內部使用 `main_app` 前綴來呼叫應用程式的路由方法。

### 資源

引擎內的資源與完整應用程式的資源工作方式相同。因為引擎類別繼承自 `Rails::Engine`，應用程式將會在引擎的 `app/assets` 和 `lib/assets` 目錄中尋找資源。

與引擎的其他組件一樣，資源應該有命名空間。這意味著如果您有一個名為 `style.css` 的資源，它應該放在 `app/assets/stylesheets/[引擎名稱]/style.css`，而不是 `app/assets/stylesheets/style.css`。如果這個資源沒有命名空間，可能會出現主應用程式有相同名稱的資源，此時主應用程式的資源會優先，引擎的資源將被忽略。

假設您的資源位於 `app/assets/stylesheets/blorgh/style.css`。要在應用程式內包含此資源，只需使用 `stylesheet_link_tag`，並像引擎內的資源一樣引用資源：

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

您也可以在處理的檔案中使用 Asset Pipeline 的 require 聲明，將這些資源指定為其他資源的相依性：

```css
/*
 *= require blorgh/style
 */
```

INFO. 請記住，為了使用 Sass 或 CoffeeScript 等語言，您應該將相關的庫添加到引擎的 `.gemspec` 中。

### 分離資源和預編譯

有些情況下，主應用程式不需要引擎的資源。例如，假設您創建了一個僅存在於引擎內的管理功能。在這種情況下，主應用程式不需要引入 `admin.css` 或 `admin.js`。只有引擎的管理佈局需要這些資源。在主應用程式的樣式表中包含 `"blorgh/admin.css"` 是沒有意義的。在這種情況下，您應該明確地為預編譯定義這些資源。這告訴 Sprockets 在觸發 `bin/rails assets:precompile` 時添加引擎的資源。

您可以在 `engine.rb` 中定義預編譯的資源：

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile += %w( admin.js admin.css )
end
```

有關更多資訊，請閱讀 [Asset Pipeline guide](asset_pipeline.html)。

### 其他 Gem 依賴

引擎內的 Gem 依賴應該在引擎根目錄的 `.gemspec` 檔案中指定。原因是引擎可能被安裝為一個 Gem。如果依賴關係在 `Gemfile` 中指定，傳統的 Gem 安裝將無法識別這些依賴關係，因此它們不會被安裝，導致引擎無法正常運作。

要在傳統的 `gem install` 過程中指定應與引擎一起安裝的依賴關係，請在引擎的 `.gemspec` 檔案中的 `Gem::Specification` 區塊內指定：

```ruby
s.add_dependency "moo"
```

要指定只應作為應用程式的開發依賴關係安裝的依賴關係，請像這樣指定：

```ruby
s.add_development_dependency "moo"
```

在執行 `bundle install` 時，這兩種依賴關係都會在應用程式內安裝。引擎的開發依賴關係只會在執行引擎的開發和測試時使用。

請注意，如果您希望在引擎被引入時立即引入依賴關係，您應該在引擎的初始化之前引入它們。例如：

```ruby
require "other_engine/engine"
require "yet_another_engine/engine"

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```

載入和配置鉤子
----------------------------

Rails 代碼通常可以在應用程式加載時引用。Rails 負責這些框架的加載順序，因此如果您在應用程式啟動時加載了像 `ActiveRecord::Base` 這樣的框架，則違反了應用程式與 Rails 之間的隱含契約。此外，通過在應用程式啟動時加載 `ActiveRecord::Base` 這樣的代碼，您將加載整個框架，這可能會降低啟動時間，並可能導致加載順序和應用程式啟動的衝突。
載入和配置鉤子是一種API，它允許您在不違反Rails的載入合約的情況下，鉤入此初始化過程。這也將減輕啟動性能下降和避免衝突。

### 避免載入Rails框架

由於Ruby是一種動態語言，某些代碼會導致不同的Rails框架載入。例如，考慮以下代碼片段：

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

這段代碼意味著當載入此文件時，將遇到`ActiveRecord::Base`。這個遇到導致Ruby尋找該常量的定義並加載它。這導致整個Active Record框架在啟動時被加載。

`ActiveSupport.on_load`是一種機制，可以延遲加載代碼，直到實際需要它。上面的代碼片段可以改為：

```ruby
ActiveSupport.on_load(:active_record) do
  include MyActiveRecordHelper
end
```

這個新的代碼片段只有在加載`ActiveRecord::Base`時才包含`MyActiveRecordHelper`。

### 何時調用鉤子？

在Rails框架中，這些鉤子在加載特定庫時調用。例如，當載入`ActionController::Base`時，將調用`:action_controller_base`鉤子。這意味著所有帶有`:action_controller_base`鉤子的`ActiveSupport.on_load`調用將在`ActionController::Base`的上下文中調用（這意味著`self`將是`ActionController::Base`）。

### 修改代碼以使用載入鉤子

修改代碼通常很簡單。如果您有一行代碼引用了像`ActiveRecord::Base`這樣的Rails框架，您可以將該代碼包裹在載入鉤子中。

**修改對`include`的調用**

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

變為

```ruby
ActiveSupport.on_load(:active_record) do
  # 這裡的self指的是ActiveRecord::Base，
  # 所以我們可以調用.include
  include MyActiveRecordHelper
end
```

**修改對`prepend`的調用**

```ruby
ActionController::Base.prepend(MyActionControllerHelper)
```

變為

```ruby
ActiveSupport.on_load(:action_controller_base) do
  # 這裡的self指的是ActionController::Base，
  # 所以我們可以調用.prepend
  prepend MyActionControllerHelper
end
```

**修改對類方法的調用**

```ruby
ActiveRecord::Base.include_root_in_json = true
```

變為

```ruby
ActiveSupport.on_load(:active_record) do
  # 這裡的self指的是ActiveRecord::Base
  self.include_root_in_json = true
end
```

### 可用的載入鉤子

以下是您可以在自己的代碼中使用的載入鉤子。使用可用的鉤子來鉤入以下類的初始化過程。

| 類別                                | 鉤子                                 |
| -------------------------------------| ------------------------------------ |
| `ActionCable`                        | `action_cable`                       |
| `ActionCable::Channel::Base`         | `action_cable_channel`               |
| `ActionCable::Connection::Base`      | `action_cable_connection`            |
| `ActionCable::Connection::TestCase`  | `action_cable_connection_test_case`  |
| `ActionController::API`              | `action_controller_api`              |
| `ActionController::API`              | `action_controller`                  |
| `ActionController::Base`             | `action_controller_base`             |
| `ActionController::Base`             | `action_controller`                  |
| `ActionController::TestCase`         | `action_controller_test_case`        |
| `ActionDispatch::IntegrationTest`    | `action_dispatch_integration_test`   |
| `ActionDispatch::Response`           | `action_dispatch_response`           |
| `ActionDispatch::Request`            | `action_dispatch_request`            |
| `ActionDispatch::SystemTestCase`     | `action_dispatch_system_test_case`   |
| `ActionMailbox::Base`                | `action_mailbox`                     |
| `ActionMailbox::InboundEmail`        | `action_mailbox_inbound_email`       |
| `ActionMailbox::Record`              | `action_mailbox_record`              |
| `ActionMailbox::TestCase`            | `action_mailbox_test_case`           |
| `ActionMailer::Base`                 | `action_mailer`                      |
| `ActionMailer::TestCase`             | `action_mailer_test_case`            |
| `ActionText::Content`                | `action_text_content`                |
| `ActionText::Record`                 | `action_text_record`                 |
| `ActionText::RichText`               | `action_text_rich_text`              |
| `ActionText::EncryptedRichText`      | `action_text_encrypted_rich_text`    |
| `ActionView::Base`                   | `action_view`                        |
| `ActionView::TestCase`               | `action_view_test_case`              |
| `ActiveJob::Base`                    | `active_job`                         |
| `ActiveJob::TestCase`                | `active_job_test_case`               |
| `ActiveRecord::Base`                 | `active_record`                      |
| `ActiveRecord::TestFixtures`         | `active_record_fixtures`             |
| `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter`    | `active_record_postgresqladapter`    |
| `ActiveRecord::ConnectionAdapters::Mysql2Adapter`        | `active_record_mysql2adapter`        |
| `ActiveRecord::ConnectionAdapters::TrilogyAdapter`       | `active_record_trilogyadapter`       |
| `ActiveRecord::ConnectionAdapters::SQLite3Adapter`       | `active_record_sqlite3adapter`       |
| `ActiveStorage::Attachment`          | `active_storage_attachment`          |
| `ActiveStorage::VariantRecord`       | `active_storage_variant_record`      |
| `ActiveStorage::Blob`                | `active_storage_blob`                |
| `ActiveStorage::Record`              | `active_storage_record`              |
| `ActiveSupport::TestCase`            | `active_support_test_case`           |
| `i18n`                               | `i18n`                               |

### 可用的配置鉤子

配置鉤子不鉤入任何特定的框架，而是在整個應用程序的上下文中運行。

| 鉤子                   | 使用情境                                                                           |
| ---------------------- | ---------------------------------------------------------------------------------- |
| `before_configuration` | 第一個可配置塊運行。在運行任何初始化程序之前調用。           |
| `before_initialize`    | 第二個可配置塊運行。在框架初始化之前調用。             |
| `before_eager_load`    | 第三個可配置塊運行。如果[`config.eager_load`][]設置為false，則不運行。 |
| `after_initialize`     | 最後一個可配置塊運行。在框架初始化之後調用。                |

配置鉤子可以在引擎類中調用。

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    config.before_configuration do
      puts '在任何初始化程序之前調用我'
    end
  end
end
```
[`config.eager_load`]: configuring.html#config-eager-load
