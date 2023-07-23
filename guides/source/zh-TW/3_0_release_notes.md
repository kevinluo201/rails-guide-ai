**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: dd2584972aa8eae419ed5d55a287e27d
Ruby on Rails 3.0 發行說明
===============================

Rails 3.0 是小馬和彩虹！它會為你煮晚餐和摺衣服。你會想知道在它到來之前生活是如何可能的。這是我們所做過的最好的 Rails 版本！

但現在說真的，這真的是很棒的東西。從 Merb 團隊加入並帶來對框架不可知性、更簡潔和更快速的內部結構以及一些美味的 API 的好點子都被帶了過來。如果你從 Merb 1.x 轉到 Rails 3.0，你應該會認出很多東西。如果你從 Rails 2.x 轉過來，你也會喜歡它的。

即使你對我們的內部清理一點興趣也沒有，Rails 3.0 也會讓你愉快。我們有一堆新功能和改進的 API。現在是成為 Rails 開發者的最佳時機。以下是一些亮點：

* 全新的路由器，強調 RESTful 宣告
* 新的 Action Mailer API，模仿 Action Controller（現在不再有發送多部分訊息的痛苦！）
* 基於關聯代數的全新 Active Record 可鏈式查詢語言
* 不顯眼的 JavaScript 輔助工具，支援 Prototype、jQuery 等驅動程式（結束內聯 JS）
* 使用 Bundler 進行明確的依賴管理

除此之外，我們已經盡力對舊的 API 進行了棄用警告。這意味著你可以將現有的應用程式轉移到 Rails 3，而不需要立即將所有舊的程式碼重寫為最新的最佳實踐。

這些發行說明涵蓋了主要的升級內容，但不包括每個小的錯誤修復和更改。Rails 3.0 包含了由 250 多位作者進行的近 4,000 次提交！如果你想看到所有的內容，請查看 GitHub 上主要的 Rails 存儲庫中的[提交列表](https://github.com/rails/rails/commits/3-0-stable)。

--------------------------------------------------------------------------------

安裝 Rails 3：

```bash
# 如果你的設置需要，使用 sudo
$ gem install rails
```


升級到 Rails 3
--------------------

如果你正在升級現有的應用程式，在進行之前最好有良好的測試覆蓋率。你應該先升級到 Rails 2.3.5，並確保你的應用程式仍然按預期運行，然後再嘗試更新到 Rails 3。然後請注意以下更改：

### Rails 3 需要至少 Ruby 1.8.7

Rails 3.0 需要 Ruby 1.8.7 或更高版本。官方已正式停止對所有先前的 Ruby 版本的支援，你應該儘早升級。Rails 3.0 也與 Ruby 1.9.2 兼容。
提示：请注意，Ruby 1.8.7 p248和p249存在序列化错误，会导致Rails 3.0崩溃。然而，Ruby Enterprise Edition自发布1.8.7-2010.02版本以来已经修复了这些问题。至于1.9版本，Ruby 1.9.1无法使用，因为在Rails 3.0上会直接导致段错误，所以如果你想使用1.9.x版本的Rails 3，请直接使用1.9.2版本以确保顺利运行。

### Rails应用对象

为了支持在同一进程中运行多个Rails应用程序，Rails 3引入了应用对象的概念。应用对象保存了所有特定于应用程序的配置，与之前版本的Rails中的`config/environment.rb`非常相似。

现在每个Rails应用程序都必须有一个对应的应用对象。应用对象定义在`config/application.rb`中。如果你要将现有应用程序升级到Rails 3，你必须添加这个文件，并将适当的配置从`config/environment.rb`移动到`config/application.rb`中。

### script/*被script/rails取代

新的`script/rails`取代了以前在`script`目录中的所有脚本。但你不直接运行`script/rails`，而是使用`rails`命令来检测它是否在Rails应用程序的根目录中被调用，并为你运行脚本。使用方法如下：

```bash
$ rails console                      # 替代了script/console
$ rails g scaffold post title:string # 替代了script/generate scaffold post title:string
```

运行`rails --help`可以查看所有选项的列表。

### 依赖和config.gem

`config.gem`方法已经被取消，取而代之的是使用`bundler`和`Gemfile`，请参见下面的[Vendoring Gems](#vendoring-gems)。

### 升级过程

为了帮助升级过程，创建了一个名为[Rails Upgrade](https://github.com/rails/rails_upgrade)的插件来自动化部分工作。

只需安装该插件，然后运行`rake rails:upgrade:check`来检查你的应用程序是否需要更新（并提供了更新信息的链接）。它还提供了一个任务，可以根据当前的`config.gem`调用生成一个`Gemfile`，以及根据当前的路由文件生成一个新的路由文件的任务。只需运行以下命令即可获取该插件：

```bash
$ ruby script/plugin install git://github.com/rails/rails_upgrade.git
```

你可以在[Rails Upgrade is now an Official Plugin](http://omgbloglol.com/post/364624593/rails-upgrade-is-now-an-official-plugin)中看到它的示例。

除了Rails Upgrade工具之外，如果你需要更多帮助，可以在IRC和[rubyonrails-talk](https://discuss.rubyonrails.org/c/rubyonrails-talk)上找到正在进行相同操作的人，他们可能遇到相同的问题。确保在升级过程中记录自己的经验，以便其他人可以从你的知识中受益！
創建一個Rails 3.0應用程序
--------------------------------

```bash
# 您應該已經安裝了 'rails' RubyGem
$ rails new myapp
$ cd myapp
```

### 嵌入Gems

Rails現在在應用程序根目錄中使用`Gemfile`來確定您的應用程序啟動所需的gems。這個`Gemfile`由[Bundler](https://github.com/bundler/bundler)處理，然後安裝所有的依賴項。它甚至可以將所有的依賴項安裝到應用程序的本地，這樣它就不依賴於系統的gems。

更多信息：- [bundler主頁](https://bundler.io/)

### 生活在邊緣

`Bundler`和`Gemfile`使得凍結您的Rails應用程序變得非常容易，只需使用新的專用`bundle`命令，所以`rake freeze`不再相關且已被刪除。

如果您想直接從Git存儲庫捆綁，可以使用`--edge`標誌：

```bash
$ rails new myapp --edge
```

如果您有一個Rails存儲庫的本地檢查，並且想要使用它來生成應用程序，可以使用`--dev`標誌：

```bash
$ ruby /path/to/rails/bin/rails new myapp --dev
```

Rails架構變更
---------------------------

Rails的架構有六個重大變化。

### Railties重構

Railties已經更新，為整個Rails框架提供了一個一致的插件API，以及對生成器和Rails綁定的完全重寫，結果是開發人員現在可以以一致、明確的方式鉤入生成器和應用程序框架的任何重要階段。

### 所有Rails核心組件解耦

在合併Merb和Rails時，一個重要的工作是消除Rails核心組件之間的緊密耦合。現在已經實現了這一點，所有的Rails核心組件現在都使用相同的API，您可以使用這個API來開發插件。這意味著您製作的任何插件，或者任何核心組件替換（如DataMapper或Sequel），都可以訪問Rails核心組件所擁有的所有功能，並且可以自由擴展和增強。

更多信息：- [The Great Decoupling](http://yehudakatz.com/2009/07/19/rails-3-the-great-decoupling/)


### Active Model抽象

解耦核心組件的一部分是從Action Pack中提取所有與Active Record的關聯。這已經完成。所有新的ORM插件現在只需要實現Active Model接口，就可以與Action Pack無縫配合。

更多信息：- [Make Any Ruby Object Feel Like ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### 控制器抽象

解耦核心組件的另一個重要部分是創建一個與HTTP概念分離的基礎超類，以處理視圖的渲染等。這個`AbstractController`的創建使得`ActionController`和`ActionMailer`可以大大簡化，從所有這些庫中刪除共同代碼並放入Abstract Controller中。
更多資訊：- [Rails Edge 架構](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Arel 整合

[Arel](https://github.com/brynary/arel)（或稱為 Active Relation）已成為 Active Record 的基礎並且現在在 Rails 中是必需的。Arel 提供了一個簡化 Active Record 的 SQL 抽象，並為 Active Record 中的關聯功能提供基礎。

更多資訊：- [為什麼我寫了 Arel](https://web.archive.org/web/20120718093140/http://magicscalingsprinkles.wordpress.com/2010/01/28/why-i-wrote-arel/)


### 郵件提取

Action Mailer 從一開始就有猴子補丁、預解析器，甚至是傳送和接收代理，除了在源代碼樹中有 TMail。版本 3 改變了這一點，將所有與電子郵件相關的功能抽象到 [Mail](https://github.com/mikel/mail) gem 中。這再次減少了代碼重複，並有助於在 Action Mailer 和郵件解析器之間建立可定義的邊界。

更多資訊：- [Rails 3 中的新 Action Mailer API](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)


文件
-------------

Rails 樹中的文件正在更新以反映所有 API 更改，此外，[Rails Edge Guides](https://edgeguides.rubyonrails.org/) 正在逐一更新以反映 Rails 3.0 的變化。然而，在 [guides.rubyonrails.org](https://guides.rubyonrails.org/) 的指南將繼續只包含穩定版本的 Rails（目前為 2.3.5 版本，直到 3.0 發布為止）。

更多資訊：- [Rails 文件專案](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)


國際化
--------------------

在 Rails 3 中，對於 I18n 支援進行了大量的工作，包括最新的 [I18n](https://github.com/svenfuchs/i18n) gem 提供了許多速度改進。

* I18n 可以添加到任何對象中 - 通過包含 `ActiveModel::Translation` 和 `ActiveModel::Validations`，可以將 I18n 行為添加到任何對象中。還有一個 `errors.messages` 的回退翻譯。
* 屬性可以有預設翻譯。
* 表單提交標籤根據對象狀態自動提取正確的狀態（創建或更新），並提取正確的翻譯。
* 使用 I18n 的標籤現在只需傳遞屬性名稱即可正常工作。

更多資訊：- [Rails 3 I18n 變更](http://blog.plataformatec.com.br/2010/02/rails-3-i18n-changes/)


Railties
--------

隨著主要 Rails 框架的解耦，Railties 經歷了巨大的改進，以使框架、引擎或插件的連接變得更加簡單和可擴展：

* 每個應用現在都有自己的命名空間，例如使用 `YourAppName.boot` 開始應用，這樣可以更輕鬆地與其他應用進行交互。
* 現在將 `Rails.root/app` 下的任何內容都添加到載入路徑中，因此您可以創建 `app/observers/user_observer.rb`，Rails 將在不需要任何修改的情況下加載它。
* Rails 3.0 現在提供了一個 `Rails.config` 對象，它提供了所有種類的 Rails 全局配置選項的中央存儲庫。

    應用程式生成增加了額外的標誌，允許您跳過安裝 test-unit、Active Record、Prototype 和 Git。還新增了一個 `--dev` 標誌，它將應用程序設置為使用 `Gemfile` 指向您的 Rails 檢查出的位置（由 `rails` 執行檔的路徑確定）。有關更多信息，請參閱 `rails --help`。
在Rails 3.0中，Railties生成器受到了很大的关注，主要有以下几点：

* 生成器完全重写，不兼容以前的版本。
* Rails模板API和生成器API合并为同一个API。
* 生成器不再从特定路径加载，而是在Ruby加载路径中查找，因此调用`rails generate foo`将查找`generators/foo_generator`。
* 新的生成器提供了钩子，因此任何模板引擎、ORM、测试框架都可以轻松地进行钩入。
* 新的生成器允许您通过将副本放置在`Rails.root/lib/templates`中来覆盖模板。
* 还提供了`Rails::Generators::TestCase`，因此您可以创建自己的生成器并对其进行测试。

此外，Railties生成器生成的视图也进行了一些改进：

* 视图现在使用`div`标签而不是`p`标签。
* 生成的脚手架现在使用`_form`局部视图，而不是在编辑和新建视图中重复的代码。
* 脚手架表单现在使用`f.submit`，根据传入的对象的状态返回"Create ModelName"或"Update ModelName"。

最后，rake任务也进行了一些增强：

* 添加了`rake db:forward`，允许您逐个或按组向前滚动迁移。
* 添加了`rake routes CONTROLLER=x`，允许您只查看一个控制器的路由。

Railties现在已经弃用了以下内容：

* `RAILS_ROOT`，推荐使用`Rails.root`，
* `RAILS_ENV`，推荐使用`Rails.env`，
* `RAILS_DEFAULT_LOGGER`，推荐使用`Rails.logger`。

`PLUGIN/rails/tasks`和`PLUGIN/tasks`不再加载，现在所有任务都必须在`PLUGIN/lib/tasks`中。

更多信息：

* [探索Rails 3生成器](http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators)
* [Rails模块（在Rails 3中）](http://quaran.to/blog/2010/02/03/the-rails-module/)

Action Pack
-----------

在Action Pack中发生了重大的内部和外部变化。


### 抽象控制器

抽象控制器将Action Controller的通用部分提取出来，形成一个可重用的模块，任何库都可以使用该模块来渲染模板、渲染局部视图、辅助方法、翻译、日志记录以及请求响应周期的任何部分。这种抽象使得`ActionMailer::Base`现在只需继承自`AbstractController`，并将Rails DSL包装到Mail gem上。

这也为整理Action Controller提供了机会，将可以简化代码的部分抽象出来。

但请注意，抽象控制器不是面向用户的API，在日常使用Rails时不会遇到它。

更多信息：- [Rails Edge架构](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Action Controller

* `application_controller.rb`现在默认启用`protect_from_forgery`。
* `cookie_verifier_secret`已被弃用，现在通过`Rails.application.config.cookie_secret`进行赋值，并移动到自己的文件中：`config/initializers/cookie_verification_secret.rb`。
* `session_store`配置在`ActionController::Base.session`中，现在移动到`Rails.application.config.session_store`。默认设置在`config/initializers/session_store.rb`中。
* `cookies.secure`允许您在cookie中设置加密值，例如`cookie.secure[:key] => value`。
* `cookies.permanent`允许您在cookie哈希中设置永久值，例如`cookie.permanent[:key] => value`，如果签名值验证失败，则会引发异常。
* 现在可以在`respond_to`块内的`format`调用中传递`：notice => 'This is a flash message'`或`：alert => 'Something went wrong'`。`flash[]`哈希仍然像以前一样工作。
* 添加了`respond_with`方法到您的控制器中，简化了古老的`format`块。
* 添加了`ActionController::Responder`，允许您灵活地生成响应。
廢棄項目：

* `filter_parameter_logging`已被廢棄，建議使用`config.filter_parameters << :password`。

更多資訊：

* [Rails 3中的渲染選項](https://blog.engineyard.com/2010/render-options-in-rails-3)
* [愛上ActionController::Responder的三個理由](https://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder)


### Action Dispatch

Action Dispatch是Rails 3.0中的新功能，提供了一個更乾淨的路由實現方式。

* 清理並重寫了路由器，Rails路由器現在是`rack_mount`，在其上面有一個Rails DSL，它是一個獨立的軟件。
* 每個應用程序定義的路由現在在你的Application模塊中進行命名空間分隔，例如：

    ```ruby
    # 舊寫法：

    ActionController::Routing::Routes.draw do |map|
      map.resources :posts
    end

    # 新寫法：

    AppName::Application.routes do
      resources :posts
    end
    ```

* 在路由器中添加了`match`方法，你還可以將任何Rack應用程序傳遞給匹配的路由。
* 在路由器中添加了`constraints`方法，允許你使用定義的約束來保護路由器。
* 在路由器中添加了`scope`方法，允許你為不同的語言或不同的操作命名空間路由，例如：

    ```ruby
    scope 'es' do
      resources :projects, :path_names => { :edit => 'cambiar' }, :path => 'proyecto'
    end

    # 給你的編輯操作是/es/proyecto/1/cambiar
    ```

* 在路由器中添加了`root`方法，作為`match '/', :to => path`的快捷方式。
* 你可以將可選段傳遞給匹配，例如`match "/:controller(/:action(/:id))(.:format)"`，每個帶括號的段都是可選的。
* 路由可以通過塊來表示，例如你可以調用`controller :home { match '/:action' }`。

注意：舊的`map`命令仍然像以前一樣工作，有一個向後兼容層，但這將在3.1版本中被刪除。

廢棄項目：

* 非REST應用程序的捕獲所有路由(`/:controller/:action/:id`)現在被註釋掉了。
* 路由的`path_prefix`不再存在，`name_prefix`現在會自動在給定值的末尾添加"_"。

更多資訊：
* [Rails 3路由器：Rack它起來](http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/)
* [Rails 3中的重構路由](https://medium.com/fusion-of-thoughts/revamped-routes-in-rails-3-b6d00654e5b0)
* [Rails 3中的通用操作](http://yehudakatz.com/2009/12/20/generic-actions-in-rails-3/)


### Action View

#### 非侵入式JavaScript

在Action View助手中進行了重大重寫，實現了非侵入式JavaScript（UJS）鉤子，並刪除了舊的內聯AJAX命令。這使得Rails可以使用任何符合UJS標準的驅動程序來實現助手中的UJS鉤子。

這意味著所有以前的`remote_<method>`助手已從Rails核心中刪除，並放入了[Prototype Legacy Helper](https://github.com/rails/prototype_legacy_helper)中。要將UJS鉤子添加到你的HTML中，現在可以傳遞`:remote => true`。例如：

```ruby
form_for @post, :remote => true
```
產生：

```html
<form action="http://host.com" id="create-post" method="post" data-remote="true">
```

#### 使用區塊的輔助函數

像是 `form_for` 或 `div_for` 這樣插入區塊內容的輔助函數現在使用 `<%=`：

```html+erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

你自己的這類輔助函數預期會返回一個字串，而不是手動附加到輸出緩衝區。

像是 `cache` 或 `content_for` 這樣做其他事情的輔助函數不受此更改的影響，它們仍然需要使用 `&lt;%`。

#### 其他更改

* 你不再需要調用 `h(string)` 來轉義 HTML 輸出，它在所有視圖模板中都是默認開啟的。如果你想要未轉義的字串，請調用 `raw(string)`。
* 輔助函數現在默認輸出 HTML5。
* 表單標籤輔助函數現在使用單個值從 I18n 中獲取值，所以 `f.label :name` 將獲取 `:name` 的翻譯。
* I18n 選擇標籤現在應該是 `:en.helpers.select` 而不是 `:en.support.select`。
* 你不再需要在 ERB 模板中的 Ruby 插值的末尾加上減號，以刪除 HTML 輸出中的尾部換行符。
* 在 Action View 中添加了 `grouped_collection_select` 輔助函數。
* 添加了 `content_for?`，允許你在渲染之前檢查視圖中是否存在內容。
* 將 `:value => nil` 傳遞給表單輔助函數將將字段的 `value` 屬性設置為 `nil`，而不是使用默認值。
* 將 `:id => nil` 傳遞給表單輔助函數將導致這些字段渲染時不帶有 `id` 屬性。
* 將 `:alt => nil` 傳遞給 `image_tag` 將導致 `img` 標籤渲染時不帶有 `alt` 屬性。

Active Model
------------

Active Model 是 Rails 3.0 中的新功能。它提供了一個抽象層，供任何 ORM 庫使用以與 Rails 交互，通過實現 Active Model 接口。

### ORM 抽象和 Action Pack 接口

解耦核心組件的一部分是從 Action Pack 中提取出所有與 Active Record 相關的內容。這個工作現在已經完成。所有新的 ORM 插件現在只需要實現 Active Model 接口，就可以與 Action Pack 無縫配合使用。

更多資訊：- [讓任何 Ruby 對象感覺像 ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)

### 驗證

驗證從 Active Record 移到了 Active Model，提供了一個在 Rails 3 中跨 ORM 庫工作的驗證接口。

* 現在有一個 `validates :attribute, options_hash` 的快捷方法，允許你對所有驗證類方法傳遞選項，你可以對驗證方法傳遞多個選項。
* `validates` 方法有以下選項：
    * `:acceptance => Boolean`。
    * `:confirmation => Boolean`。
    * `:exclusion => { :in => Enumerable }`。
    * `:inclusion => { :in => Enumerable }`。
    * `:format => { :with => Regexp, :on => :create }`。
    * `:length => { :maximum => Fixnum }`。
    * `:numericality => Boolean`。
    * `:presence => Boolean`。
    * `:uniqueness => Boolean`。
注意：在Rails 3.0中，仍然支持所有Rails版本2.3的風格驗證方法，新的validates方法設計為模型驗證的附加輔助，而不是現有API的替代品。

您還可以傳入一個驗證器對象，然後在使用Active Model的對象之間重複使用：

```ruby
class TitleValidator < ActiveModel::EachValidator
  Titles = ['先生', '夫人', '博士']
  def validate_each(record, attribute, value)
    unless Titles.include?(value)
      record.errors[attribute] << '必須是有效的稱號'
    end
  end
end
```

```ruby
class Person
  include ActiveModel::Validations
  attr_accessor :title
  validates :title, :presence => true, :title => true
end

# 或者對於Active Record

class Person < ActiveRecord::Base
  validates :title, :presence => true, :title => true
end
```

還支持自省：

```ruby
User.validators
User.validators_on(:login)
```

更多信息：

* [Rails 3中的驗證](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)
* [解釋Rails 3中的驗證](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)


Active Record
-------------

Active Record在Rails 3.0中受到了很多關注，包括將其抽象為Active Model，使用Arel對查詢接口進行全面更新，驗證更新以及許多增強和修復。所有Rails 2.x的API都可以通過兼容層使用，該兼容層將在3.1版本之前得到支持。

### 查詢接口

Active Record現在通過使用Arel，在其核心方法上返回關聯。Rails 2.3.x中的現有API仍然受到支持，並且直到Rails 3.1才會被棄用，直到Rails 3.2才會被刪除，但是新的API提供了以下新方法，所有這些方法都返回關聯，可以將它們鏈接在一起：

* `where` - 在關聯上提供條件，決定返回什麼。
* `select` - 選擇要從數據庫返回的模型的哪些屬性。
* `group` - 將關聯按提供的屬性分組。
* `having` - 提供限制組關聯的表達式（GROUP BY約束）。
* `joins` - 將關聯與另一個表聯接。
* `clause` - 提供限制聯接關聯的表達式（JOIN約束）。
* `includes` - 預先加載其他關聯。
* `order` - 根據提供的表達式對關聯進行排序。
* `limit` - 將關聯限制為指定的記錄數。
* `lock` - 鎖定從表返回的記錄。
* `readonly` - 返回數據的只讀副本。
* `from` - 提供從多個表中選擇關係的方法。
* `scope` - （之前是`named_scope`）返回關係，可以與其他關聯方法鏈接在一起。
* `with_scope` - 和`with_exclusive_scope`現在也返回關聯，因此可以鏈接。
* `default_scope` - 也適用於關聯。
更多資訊：

* [Active Record 查詢介面](http://m.onkey.org/2010/1/22/active-record-query-interface)
* [讓你的 SQL 在 Rails 3 中咆哮](http://hasmanyquestions.wordpress.com/2010/01/17/let-your-sql-growl-in-rails-3/)


### 增強功能

* 在 Active Record 物件中新增了 `:destroyed?`。
* 在 Active Record 關聯中新增了 `:inverse_of`，允許你在不需要查詢資料庫的情況下取得已載入關聯的實例。


### 修補和廢棄

此外，在 Active Record 分支中進行了許多修補：

* 放棄了對 SQLite 2 的支援，改為支援 SQLite 3。
* 增加了 MySQL 對於欄位順序的支援。
* 修正了 PostgreSQL adapter 的 `TIME ZONE` 支援，不再插入錯誤的值。
* 支援 PostgreSQL 表格名稱中的多個 schema。
* 支援 PostgreSQL 的 XML 資料類型欄位。
* 現在會快取 `table_name`。
* 在 Oracle adapter 上進行了大量的工作，修正了許多錯誤。

還有以下的廢棄功能：

* 在 Active Record 類別中，`named_scope` 已被廢棄並更名為 `scope`。
* 在 `scope` 方法中，應該改用關聯方法，而不是 `:conditions => {}` 的查詢方法，例如 `scope :since, lambda {|time| where("created_at > ?", time) }`。
* `save(false)` 已被廢棄，應改用 `save(:validate => false)`。
* Active Record 的 I18n 錯誤訊息應從 `:en.activerecord.errors.template` 改為 `:en.errors.template`。
* `model.errors.on` 已被廢棄，應改用 `model.errors[]`。
* `validates_presence_of` => `validates... :presence => true`
* `ActiveRecord::Base.colorize_logging` 和 `config.active_record.colorize_logging` 已被廢棄，應改用 `Rails::LogSubscriber.colorize_logging` 或 `config.colorize_logging`

注意：雖然狀態機的實作已經在 Active Record 的開發版本中存在了數個月，但它已從 Rails 3.0 版本中移除。


Active Resource
---------------

Active Resource 也被提取到 Active Model 中，使你可以無縫地在 Action Pack 中使用 Active Resource 物件。

* 透過 Active Model 新增了驗證功能。
* 新增了觀察鉤子。
* 支援 HTTP 代理。
* 新增了摘要驗證的支援。
* 將模型命名移入 Active Model。
* 將 Active Resource 屬性改為具有無差別存取的 Hash。
* 為等效的查詢範圍新增了 `first`、`last` 和 `all` 的別名。
* 如果沒有返回任何結果，`find_every` 現在不會返回 `ResourceNotFound` 錯誤。
* 新增了 `save!`，除非物件是 `valid?`，否則會引發 `ResourceInvalid` 錯誤。
* 在 Active Resource 模型中新增了 `update_attribute` 和 `update_attributes`。
* 新增了 `exists?`。
* 將 `SchemaDefinition` 改名為 `Schema`，並將 `define_schema` 改為 `schema`。
* 使用 Active Resources 的 `format` 而不是遠端錯誤的 `content-type` 來載入錯誤。
* 使用 `instance_eval` 進行 schema 區塊。
* 修正了當 `@response` 不回應 #code 或 #message 時，`ActiveResource::ConnectionError#to_s` 的問題，處理 Ruby 1.9 的相容性。
* 增加了對 JSON 格式錯誤的支援。
* 確保 `load` 與數值陣列一起運作。
* 將遠端資源的 410 回應視為資源已被刪除。
* 在 Active Resource 連線中新增了設置 SSL 選項的能力。
* 設置連線逾時也會影響 `Net::HTTP` 的 `open_timeout`。
廢棄功能：

* `save(false)` 已被廢棄，改用 `save(:validate => false)`。
* Ruby 1.9.2：`URI.parse` 和 `.decode` 已被廢棄並不再在庫中使用。

Active Support
--------------

在 Active Support 中進行了大量的努力，使其可以進行選擇性引用，也就是說，您不再需要引用整個 Active Support 库來獲取其中的部分功能。這使得 Rails 的各個核心組件可以運行得更加精簡。

以下是 Active Support 的主要變更：

* 清理了庫中的大量未使用方法。
* Active Support 不再提供 TZInfo、Memcache Client 和 Builder 的內部版本。這些都作為依賴項包含在內並通過 `bundle install` 命令安裝。
* 在 `ActiveSupport::SafeBuffer` 中實現了安全緩衝區。
* 添加了 `Array.uniq_by` 和 `Array.uniq_by!`。
* 移除了 `Array#rand`，並從 Ruby 1.9 中回溯了 `Array#sample`。
* 修正了 `TimeZone.seconds_to_utc_offset` 返回錯誤值的錯誤。
* 添加了 `ActiveSupport::Notifications` 中間件。
* `ActiveSupport.use_standard_json_time_format` 現在默認為 true。
* `ActiveSupport.escape_html_entities_in_json` 現在默認為 false。
* `Integer#multiple_of?` 接受零作為參數，除非接收者為零，否則返回 false。
* `string.chars` 的名稱已更改為 `string.mb_chars`。
* `ActiveSupport::OrderedHash` 現在可以通過 YAML 反序列化。
* 使用 LibXML 和 Nokogiri 添加了基於 SAX 的 XmlMini 解析器。
* 添加了 `Object#presence`，如果對象是 `#present?`，則返回該對象，否則返回 `nil`。
* 添加了 `String#exclude?` 核心擴展，返回 `#include?` 的相反值。
* 在 `ActiveSupport` 中為 `DateTime` 添加了 `to_i`，以便在具有 `DateTime` 屬性的模型上正確使用 `to_yaml`。
* 添加了 `Enumerable#exclude?`，以實現與 `Enumerable#include?` 的相等性並避免使用 `!x.include?`。
* 將 Rails 的 XSS 轉義設置為默認開啟。
* 在 `ActiveSupport::HashWithIndifferentAccess` 中支持深度合併。
* `Enumerable#sum` 現在適用於所有可枚舉對象，即使它們不響應 `:size`。
* 長度為零的持續時間的 `inspect` 返回 '0 seconds' 而不是空字符串。
* 在 `ModelName` 中添加了 `element` 和 `collection`。
* `String#to_time` 和 `String#to_datetime` 處理小數秒。
* 為新的回調添加了對於在 before 和 after 回調中使用 `:before` 和 `:after` 的 around 過濾對象的支持。
* `ActiveSupport::OrderedHash#to_a` 方法返回一組有序的數組。與 Ruby 1.9 的 `Hash#to_a` 匹配。
* `MissingSourceFile` 現在作為常量存在，但它只是等於 `LoadError`。
* 添加了 `Class#class_attribute`，以便能夠聲明一個具有可繼承且可被子類覆寫的類級屬性。
* 最終移除了 `ActiveRecord::Associations` 中的 `DeprecatedCallbacks`。
* `Object#metaclass` 現在是 `Kernel#singleton_class`，以與 Ruby 匹配。

以下方法已被移除，因為它們現在在 Ruby 1.8.7 和 1.9 中可用。
* `Integer#even?` 和 `Integer#odd?`
* `String#each_char`
* `String#start_with?` 和 `String#end_with?` (保留第三人稱的別名)
* `String#bytesize`
* `Object#tap`
* `Symbol#to_proc`
* `Object#instance_variable_defined?`
* `Enumerable#none?`

REXML的安全補丁仍然保留在Active Support中，因為Ruby 1.8.7的早期修補版本仍然需要它。Active Support知道是否需要應用此補丁。

以下方法已被刪除，因為它們在框架中不再使用：

* `Kernel#daemonize`
* `Object#remove_subclasses_of` `Object#extend_with_included_modules_from`, `Object#extended_by`
* `Class#remove_class`
* `Regexp#number_of_captures`, `Regexp.unoptionalize`, `Regexp.optionalize`, `Regexp#number_of_captures`


Action Mailer
-------------

Action Mailer使用新的API，將TMail替換為新的[Mail](https://github.com/mikel/mail)作為郵件庫。Action Mailer本身經歷了幾乎完全的重寫，幾乎每一行代碼都有所改動。結果是Action Mailer現在只是繼承自Abstract Controller，並在Rails DSL中封裝Mail gem。這大大減少了Action Mailer中的代碼量和其他庫的重複。

* 所有郵件發送器現在默認放在`app/mailers`中。
* 現在可以使用新的API發送郵件，有三種方法：`attachments`、`headers`和`mail`。
* Action Mailer現在原生支持使用`attachments.inline`方法進行內聯附件。
* Action Mailer的郵件發送方法現在返回`Mail::Message`對象，可以使用`deliver`消息來發送郵件。
* 所有發送方法現在都抽象到Mail gem中。
* 郵件發送方法可以接受一個包含所有有效郵件標頭字段及其值對的哈希。
* `mail`發送方法的行為類似於Action Controller的`respond_to`，可以顯式或隱式地渲染模板。Action Mailer會根據需要將郵件轉換為多部分郵件。
* 可以將proc傳遞給郵件塊中的`format.mime_type`調用，明確地渲染特定類型的文本，或添加佈局或不同的模板。proc內部的`render`調用來自Abstract Controller，支持相同的選項。
* 原本的郵件單元測試已經移動到功能測試中。
* Action Mailer現在將所有標頭字段和正文的自動編碼委託給Mail Gem。
* Action Mailer將自動為您編碼郵件正文和標頭。

已棄用：

* `:charset`、`:content_type`、`:mime_version`、`:implicit_parts_order`都已棄用，建議使用`ActionMailer.default :key => value`樣式的聲明。
* 郵件動態`create_method_name`和`deliver_method_name`已棄用，只需調用`method_name`，它現在返回一個`Mail::Message`對象。
* `ActionMailer.deliver(message)`已棄用，只需調用`message.deliver`。
* `template_root`已棄用，將選項傳遞給`mail`生成塊內部的`format.mime_type`方法中的渲染調用。
* 使用`app/models`中的郵件已棄用，改用`app/mailers`。
更多資訊：

* [Rails 3 中的新 Action Mailer API](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)
* [Ruby 的新 Mail Gem](http://lindsaar.net/2010/1/23/mail-gem-version-2-released)


貢獻者
-------

請參閱 [Rails 的完整貢獻者名單](https://contributors.rubyonrails.org/)，感謝所有花費許多時間製作 Rails 3 的人們。

Rails 3.0 發行說明由 [Mikel Lindsaar](http://lindsaar.net) 編輯。
