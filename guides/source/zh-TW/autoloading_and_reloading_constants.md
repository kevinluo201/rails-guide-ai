**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f53b3a12c263256fbbe154cfc8b2f4d
自動加載和重新加載常量
=======================

本指南介紹了在`zeitwerk`模式下自動加載和重新加載的工作原理。

閱讀本指南後，您將了解：

* 相關的Rails配置
* 項目結構
* 自動加載、重新加載和急切加載
* 單表繼承
* 以及更多

--------------------------------------------------------------------------------

介紹
----

INFO. 本指南介紹了Rails應用程序中的自動加載、重新加載和急切加載。

在普通的Ruby程序中，您需要明確加載定義類和模塊的文件以供使用。例如，以下控制器引用了`ApplicationController`和`Post`，您通常會為它們發出`require`調用：

```ruby
# 請勿這樣做。
require "application_controller"
require "post"
# 請勿這樣做。

class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

而在Rails應用程序中，應用程序的類和模塊無需`require`調用即可在任何地方使用：

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Rails會自動為您加載它們。這得益於Rails為您設置的幾個[Zeitwerk](https://github.com/fxn/zeitwerk)加載器，它們提供了自動加載、重新加載和急切加載的功能。

另一方面，這些加載器不管理其他任何內容。特別是，它們不管理Ruby標準庫、gem依賴、Rails組件本身，甚至（默認情況下）應用程序的`lib`目錄。這些代碼必須像往常一樣加載。

項目結構
--------

在Rails應用程序中，文件名必須與它們定義的常量匹配，目錄則充當命名空間。

例如，文件`app/helpers/users_helper.rb`應該定義`UsersHelper`，文件`app/controllers/admin/payments_controller.rb`應該定義`Admin::PaymentsController`。

默認情況下，Rails配置了Zeitwerk使用`String#camelize`對文件名進行轉換。例如，它期望`app/controllers/users_controller.rb`定義常量`UsersController`，因為`"users_controller".camelize`返回的就是這個。

下面的_自定義轉換_部分介紹了覆蓋此默認行為的方法。

請參閱[Zeitwerk文檔](https://github.com/fxn/zeitwerk#file-structure)以獲取更多詳細信息。

config.autoload_paths
---------------------

我們將應用程序目錄的列表稱為要自動加載和（可選）重新加載的目錄為_自動加載路徑_。例如，`app/models`。這些目錄代表根命名空間：`Object`。

INFO. Zeitwerk文檔中將自動加載路徑稱為_根目錄_，但在本指南中我們將使用"自動加載路徑"這個術語。

在自動加載路徑中，文件名必須與它們定義的常量匹配，詳情請參閱[這裡](https://github.com/fxn/zeitwerk#file-structure)。

默認情況下，應用程序的自動加載路徑包括在應用程序啟動時存在的`app`的所有子目錄 ---除了`assets`、`javascript`和`views`--- 以及它可能依賴的引擎的自動加載路徑。

例如，如果`UsersHelper`在`app/helpers/users_helper.rb`中實現，該模塊是可自動加載的，您不需要（也不應該）為它編寫`require`調用：

```bash
$ bin/rails runner 'p UsersHelper'
UsersHelper
```

Rails會自動將`app`下的自定義目錄添加到自動加載路徑中。例如，如果您的應用程序有`app/presenters`，您無需進行任何配置即可自動加載presenters；它可以直接使用。

默認自動加載路徑的數組可以通過在`config/application.rb`或`config/environments/*.rb`中添加到`config.autoload_paths`來擴展。例如：

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_paths << "#{root}/extras"
  end
end
```

同樣，引擎可以在引擎類的主體和它們自己的`config/environments/*.rb`中添加。

WARNING. 請不要修改`ActiveSupport::Dependencies.autoload_paths`；更改自動加載路徑的公共接口是`config.autoload_paths`。

WARNING: 應用程序啟動時無法自動加載自動加載路徑中的代碼。特別是在`config/initializers/*.rb`中。請參閱下面的[_應用程序啟動時的自動加載_](#autoloading-when-the-application-boots)以了解有效的方法。

自動加載路徑由`Rails.autoloaders.main`自動加載器管理。

config.autoload_lib(ignore:)
----------------------------

默認情況下，`lib`目錄不屬於應用程序或引擎的自動加載路徑。

配置方法`config.autoload_lib`將`lib`目錄添加到`config.autoload_paths`和`config.eager_load_paths`中。它必須在`config/application.rb`或`config/environments/*.rb`中調用，並且對於引擎不可用。

通常，`lib`目錄下有一些子目錄不應由自動加載器管理。請在`ignore`關鍵字參數中傳遞相對於`lib`的名稱。例如：

```ruby
config.autoload_lib(ignore: %w(assets tasks))
```

為什麼？雖然`assets`和`tasks`與常規代碼共享`lib`目錄，但它們的內容不應該被自動加載或急切加載。在那裡，`Assets`和`Tasks`不是Ruby命名空間。如果有生成器，也是一樣的：
```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

在7.1之前，`config.autoload_lib`是不可用的，但只要應用程式使用Zeitwerk，您仍然可以模擬它：

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.main.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

config.autoload_once_paths
--------------------------

您可能希望能夠自動載入類別和模組，而無需重新載入它們。`autoload_once_paths` 配置存儲可以自動載入但不會重新載入的程式碼。

默認情況下，此集合為空，但您可以通過將其推送到 `config.autoload_once_paths` 來擴展它。您可以在 `config/application.rb` 或 `config/environments/*.rb` 中這樣做。例如：

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_once_paths << "#{root}/app/serializers"
  end
end
```

同樣，引擎可以在引擎類別的主體和它們自己的 `config/environments/*.rb` 中推送。

INFO. 如果將 `app/serializers` 推送到 `config.autoload_once_paths`，Rails 將不再將其視為自動載入路徑，儘管它是 `app` 下的自定義目錄。此設置覆蓋了該規則。

這對於在重新載入後仍然存在的位置緩存的類別和模組非常重要，例如 Rails 框架本身。

例如，Active Job 的序列化器存儲在 Active Job 內：

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

而 Active Job 本身在重新載入時不會重新載入，只有應用程式和引擎代碼在自動載入路徑中的程式碼會重新載入。

使 `MoneySerializer` 可重新載入會很困惑，因為重新載入編輯過的版本對於存儲在 Active Job 中的類別物件沒有影響。實際上，如果 `MoneySerializer` 是可重新載入的，從 Rails 7 開始，此初始化程式將引發 `NameError`。

另一個用例是引擎裝飾框架類別：

```ruby
initializer "decorate ActionController::Base" do
  ActiveSupport.on_load(:action_controller_base) do
    include MyDecoration
  end
end
```

在這裡，初始化程式運行時 `MyDecoration` 中存儲的模組物件成為 `ActionController::Base` 的祖先，重新載入 `MyDecoration` 是沒有意義的，它不會影響該祖先鏈。

可以在 `config/initializers` 中自動載入一次路徑中的類別和模組。因此，使用該配置，以下程式碼可以正常運作：

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

INFO：從技術上講，您可以在 `:bootstrap_hook` 之後運行的任何初始化程式中自動載入由 `once` 自動載入器管理的類別和模組。

自動載入一次的路徑由 `Rails.autoloaders.once` 管理。

config.autoload_lib_once(ignore:)
---------------------------------

`config.autoload_lib_once` 方法與 `config.autoload_lib` 類似，只是將 `lib` 添加到 `config.autoload_once_paths` 中。它必須從 `config/application.rb` 或 `config/environments/*.rb` 中調用，並且對於引擎不可用。

通過調用 `config.autoload_lib_once`，可以自動載入 `lib` 中的類別和模組，即使是從應用程式初始化程式，但不會重新載入。

在7.1之前，您仍然可以模擬 `config.autoload_lib_once`，只要應用程式使用Zeitwerk：

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_once_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.once.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

$LOAD_PATH{#load_path}
----------

默認情況下，自動載入路徑會添加到 `$LOAD_PATH` 中。但是，Zeitwerk 在內部使用絕對檔案名稱，並且您的應用程式不應該為可自動載入的檔案發出 `require` 呼叫，因此這些目錄實際上不需要在那裡。您可以使用此標誌退出：

```ruby
config.add_autoload_paths_to_load_path = false
```

這可能會加快合法的 `require` 呼叫，因為查找次數較少。此外，如果您的應用程式使用 [Bootsnap](https://github.com/Shopify/bootsnap)，這可以節省該庫建立不必要索引的時間，從而降低記憶體使用量。

此標誌不會影響 `lib` 目錄，它始終會添加到 `$LOAD_PATH` 中。

重新載入
---------

如果自動載入路徑中的應用程式檔案發生變化，Rails 會自動重新載入類別和模組。

更具體地說，如果網頁伺服器正在運行且應用程式檔案已被修改，Rails 會在處理下一個請求之前卸載 `main` 自動載入器管理的所有自動載入的常數。這樣，在該請求期間使用的應用程式類別或模組將再次自動載入，從而從檔案系統中獲取其當前實現。

可以啟用或禁用重新載入。控制此行為的設置是 [`config.enable_reloading`][]，在 `development` 模式下默認為 `true`，在 `production` 模式下默認為 `false`。為了向後兼容，Rails 還支持 `config.cache_classes`，它等效於 `!config.enable_reloading`。

Rails 默認使用事件驅動的檔案監視器來檢測檔案變更。可以配置它來通過遍歷自動載入路徑來檢測檔案變更。這由 [`config.file_watcher`][] 設置控制。

在 Rails 控制台中，無論 `config.enable_reloading` 的值如何，都不會啟用檔案監視器。這是因為通常在控制台會話中重新載入程式碼會令人困惑。與單個請求類似，通常希望控制台會話由一組一致且不變的應用程式類別和模組提供服務。
然而，您可以在控制台中执行`reload!`来强制重新加载：

```irb
irb(main):001:0> User.object_id
=> 70136277390120
irb(main):002:0> reload!
Reloading...
=> true
irb(main):003:0> User.object_id
=> 70136284426020
```

如您所见，在重新加载后，存储在`User`常量中的类对象是不同的。


### 重新加载和过时对象

非常重要的一点是，Ruby没有一种真正重新加载内存中的类和模块，并在它们已经使用的所有地方都反映出来的方法。从技术上讲，“卸载”`User`类意味着通过`Object.send(:remove_const, "User")`删除`User`常量。

例如，看看这个Rails控制台会话：

```irb
irb> joe = User.new
irb> reload!
irb> alice = User.new
irb> joe.class == alice.class
=> false
```

`joe`是原始`User`类的一个实例。当重新加载时，`User`常量将评估为一个不同的、重新加载的类。`alice`是新加载的`User`的一个实例，但`joe`不是——他的类是过时的。您可以重新定义`joe`，启动一个IRB子会话，或者只需启动一个新的控制台，而不是调用`reload!`。

您可能会在未重新加载的地方子类化可重新加载的类时遇到这个陷阱的另一种情况：

```ruby
# lib/vip_user.rb
class VipUser < User
end
```

如果重新加载了`User`，由于`VipUser`没有重新加载，`VipUser`的超类将是原始的过时类对象。

底线是：**不要缓存可重新加载的类或模块**。

## 应用程序启动时的自动加载

在启动时，应用程序可以从`autoload_once_paths`中自动加载，这些路径由`once`自动加载器管理。请参阅上面的[`config.autoload_once_paths`](#config-autoload-once-paths)部分。

但是，您不能从`autoload_paths`中自动加载，这些路径由`main`自动加载器管理。这适用于`config/initializers`中的代码以及应用程序或引擎的初始化器。

为什么？初始化器只在应用程序启动时运行一次。它们不会在重新加载时再次运行。如果初始化器使用了可重新加载的类或模块，对它们的编辑将不会反映在初始代码中，从而变得过时。因此，在初始化期间引用可重新加载的常量是不允许的。

让我们看看应该做什么。

### 情况1：在启动时加载可重新加载的代码

#### 在启动和每次重新加载时自动加载

假设`ApiGateway`是一个可重新加载的类，您需要在应用程序启动时配置其端点：

```ruby
# config/initializers/api_gateway_setup.rb
ApiGateway.endpoint = "https://example.com" # NameError
```

初始化器不能引用可重新加载的常量，您需要将其包装在`to_prepare`块中，在启动时和每次重新加载后运行：

```ruby
# config/initializers/api_gateway_setup.rb
Rails.application.config.to_prepare do
  ApiGateway.endpoint = "https://example.com" # CORRECT
end
```

注意：出于历史原因，此回调可能运行两次。它执行的代码必须是幂等的。

#### 仅在启动时自动加载

可重新加载的类和模块也可以在`after_initialize`块中自动加载。这些块在启动时运行，但在重新加载时不会再次运行。在某些特殊情况下，这可能是您想要的。

预检查是这种情况的一个用例：

```ruby
# config/initializers/check_admin_presence.rb
Rails.application.config.after_initialize do
  unless Role.where(name: "admin").exists?
    abort "The admin role is not present, please seed the database."
  end
end
```

### 情况2：在启动时加载保持缓存的代码

某些配置接受类或模块对象，并将其存储在不重新加载的位置。重要的是，这些不能重新加载，因为对它们的编辑不会反映在这些缓存的过时对象中。

一个例子是中间件：

```ruby
config.middleware.use MyApp::Middleware::Foo
```

当您重新加载时，中间件堆栈不受影响，所以`MyApp::Middleware::Foo`是可重新加载的将会令人困惑。对其实现的更改不会产生任何效果。

另一个例子是Active Job序列化器：

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

在初始化期间，`MoneySerializer`所评估的内容被推送到自定义序列化器中，并且在重新加载时保留在那里。

还有一个例子是railties或引擎通过包含模块来装饰框架类。例如，[`turbo-rails`](https://github.com/hotwired/turbo-rails)通过以下方式装饰`ActiveRecord::Base`：

```ruby
initializer "turbo.broadcastable" do
  ActiveSupport.on_load(:active_record) do
    include Turbo::Broadcastable
  end
end
```

这将在`ActiveRecord::Base`的祖先链中添加一个模块对象。如果重新加载，对`Turbo::Broadcastable`的更改将不会产生任何效果，祖先链仍将具有原始的模块对象。

推论：这些类或模块**不能重新加载**。

在启动时引用这些类或模块的最简单方法是将它们定义在不属于自动加载路径的目录中。例如，`lib`是一个惯用的选择。它默认不属于自动加载路径，但它属于`$LOAD_PATH`。只需执行常规的`require`来加载它。
如上所述，另一個選項是在autoload一次的路徑和autoload中定義它們的目錄。詳細信息請參閱[config.autoload_once_paths](#config-autoload-once-paths)部分。

### 使用案例3：為引擎配置應用程序類

假設一個引擎使用可重新加載的應用程序類來建模用戶，並為其配置了一個配置點：

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = User # NameError
end
```

為了與可重新加載的應用程序代碼良好配合，引擎需要應用程序配置該類的“名稱”：

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = "User" # OK
end
```

然後，在運行時，`config.user_model.constantize`將給出當前的類對象。

急切加載
-------------

在類似生產環境的環境中，通常最好在應用程序啟動時加載所有應用程序代碼。急切加載將所有內容放入內存中，準備立即處理請求，並且它還支持[CoW](https://en.wikipedia.org/wiki/Copy-on-write)。

急切加載由標誌[`config.eager_load`]控制，默認情況下在除`production`以外的所有環境中都禁用。當執行Rake任務時，`config.eager_load`被[`config.rake_eager_load`]覆蓋，默認值為`false`。因此，默認情況下，在生產環境中，Rake任務不會急切加載應用程序。

文件的急切加載順序未定義。

在急切加載期間，Rails調用`Zeitwerk::Loader.eager_load_all`。這確保了由Zeitwerk管理的所有gem依賴項也被急切加載。

單表繼承
------------------------

單表繼承與延遲加載不兼容：Active Record必須了解STI層次結構才能正確工作，但是在延遲加載時，類只在需要時才被準確加載！

為了解決這個基本不匹配，我們需要預先加載STI。有幾種不同的選項可以實現這一點。讓我們看看它們。

### 選項1：啟用急切加載

預先加載STI的最簡單方法是通過設置：

```ruby
config.eager_load = true
```

在`config/environments/development.rb`和`config/environments/test.rb`中。

這很簡單，但可能代價高昂，因為它會在啟動時和每次重新加載時都急切加載整個應用程序。然而，對於小型應用程序來說，這種折衷可能是值得的。

### 選項2：預先加載折疊的目錄

將定義層次結構的文件存儲在一個專用目錄中，這在概念上也是有意義的。該目錄不是用來表示命名空間的，它的唯一目的是將STI分組：

```
app/models/shapes/shape.rb
app/models/shapes/circle.rb
app/models/shapes/square.rb
app/models/shapes/triangle.rb
```

在這個例子中，我們仍然希望`app/models/shapes/circle.rb`定義`Circle`，而不是`Shapes::Circle`。這可能是您個人偏好的簡單保持事情簡單的方式，也避免了現有代碼庫中的重構。Zeitwerk的[折疊](https://github.com/fxn/zeitwerk#collapsing-directories)功能允許我們這樣做：

```ruby
# config/initializers/preload_stis.rb

shapes = "#{Rails.root}/app/models/shapes"
Rails.autoloaders.main.collapse(shapes) # 不是命名空間。

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir(shapes)
  end
end
```

在此選項中，我們在啟動時急切加載這些少量文件，即使未使用STI也會重新加載。但是，除非您的應用程序有很多STI，否則這不會有任何可衡量的影響。

INFO：`Zeitwerk::Loader#eager_load_dir`方法在Zeitwerk 2.6.2中添加。對於舊版本，仍然可以列出`app/models/shapes`目錄並在其內容上調用`require_dependency`。

警告：如果從STI中添加、修改或刪除模型，重新加載將按預期工作。但是，如果在應用程序中添加了一個新的獨立STI層次結構，您需要編輯初始化程序並重新啟動服務器。

### 選項3：預先加載常規目錄

與前一個選項類似，但該目錄被視為命名空間。也就是說，`app/models/shapes/circle.rb`預計定義`Shapes::Circle`。

對於這個選項，初始化程序相同，只是不配置折疊：

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/shapes")
  end
end
```

相同的折衷。

### 選項4：從數據庫預先加載類型

在此選項中，我們不需要以任何方式組織文件，但需要訪問數據庫：

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    types = Shape.unscoped.select(:type).distinct.pluck(:type)
    types.compact.each(&:constantize)
  end
end
```

警告：即使表中沒有所有類型，STI也能正常工作，但是`subclasses`或`descendants`等方法將不返回缺少的類型。

警告：如果從STI中添加、修改或刪除模型，重新加載將按預期工作。但是，如果在應用程序中添加了一個新的獨立STI層次結構，您需要編輯初始化程序並重新啟動服務器。
自定義詞形變化
-----------------------

預設情況下，Rails使用`String#camelize`來確定給定檔案或目錄名應該定義哪個常數。例如，`posts_controller.rb`應該定義`PostsController`，因為這是`"posts_controller".camelize`返回的結果。

有時候，某些特定的檔案或目錄名可能無法按照您的要求進行詞形變化。例如，預設情況下，`html_parser.rb`應該定義`HtmlParser`。但如果您更喜歡將類別命名為`HTMLParser`呢？有幾種方法可以自定義這個行為。

最簡單的方法是定義首字母縮寫：

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "HTML"
  inflect.acronym "SSL"
end
```

這樣做會全局影響Active Support的詞形變化。這在某些應用中可能沒問題，但您也可以通過將一組覆蓋傳遞給默認詞形變化器，從而獨立於Active Support自定義如何將單個基本名進行詞形變化：

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

儘管如此，這種技術仍然依賴於`String#camelize`，因為這是默認詞形變化器使用的後備方法。如果您不想依賴Active Support的詞形變化，並且對詞形變化有絕對控制，可以將詞形變化器配置為`Zeitwerk::Inflector`的實例：

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector = Zeitwerk::Inflector.new
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

沒有全局配置可以影響這些實例；它們是確定性的。

您甚至可以定義一個自定義詞形變化器以實現完全靈活性。請參閱[Zeitwerk文檔](https://github.com/fxn/zeitwerk#custom-inflector)了解更多詳細信息。

### 詞形變化自定義應放在哪裡？

如果應用程序不使用`once`自動加載器，則上述代碼片段可以放在`config/initializers`目錄中。例如，對於Active Support的用法，可以放在`config/initializers/inflections.rb`中，對於其他情況，可以放在`config/initializers/zeitwerk.rb`中。

使用`once`自動加載器的應用程序必須將此配置從`config/application.rb`文件的應用程序類主體中移動或加載，因為`once`自動加載器在引導過程的早期階段使用詞形變化器。

自定義命名空間
-----------------

如上所述，自動加載路徑表示頂層命名空間：`Object`。

以`app/services`為例。預設情況下，此目錄不會被自動生成，但如果存在，Rails會自動將其添加到自動加載路徑中。

預設情況下，文件`app/services/users/signup.rb`應該定義`Users::Signup`，但如果您希望整個子樹位於`Services`命名空間下，該怎麼辦呢？根據默認設置，可以通過創建一個子目錄`app/services/services`來實現。

但是，根據您的喜好，這可能不符合您的期望。您可能更喜歡`app/services/users/signup.rb`僅定義`Services::Users::Signup`。

Zeitwerk支持[自定義根命名空間](https://github.com/fxn/zeitwerk#custom-root-namespaces)來解決這個問題，您可以自定義`main`自動加載器來實現：

```ruby
# config/initializers/autoloading.rb

# 命名空間必須存在。
#
# 在此示例中，我們在此處定義模塊。也可以在其他地方創建並在此處加載其定義。
# 無論如何，`push_dir`需要一個類或模塊對象。
module Services; end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/services", namespace: Services)
```

Rails < 7.1不支持此功能，但您仍然可以將此額外代碼添加到同一個文件中並使其正常工作：

```ruby
# 適用於運行在Rails < 7.1上的應用程序的額外代碼。
app_services_dir = "#{Rails.root}/app/services" # 必須是字符串
ActiveSupport::Dependencies.autoload_paths.delete(app_services_dir)
Rails.application.config.watchable_dirs[app_services_dir] = [:rb]
```

自定義命名空間也適用於`once`自動加載器。但是，由於`once`自動加載器在引導過程的早期階段設置，因此無法在應用程序初始化器中進行配置。請將其放在`config/application.rb`中。

自動加載和引擎
-----------------------

引擎在父應用程序的上下文中運行，其代碼由父應用程序自動加載、重新加載和急切加載。如果應用程序運行在`zeitwerk`模式下，則引擎代碼由`zeitwerk`模式加載。如果應用程序運行在`classic`模式下，則引擎代碼由`classic`模式加載。

當Rails啟動時，引擎目錄會被添加到自動加載路徑中，對於自動加載器來說，這沒有區別。自動加載器的主要輸入是自動加載路徑，它們是應用程序源代碼樹還是某個引擎源代碼樹的成員對於自動加載器來說是無關緊要的。

例如，此應用程序使用[Devise](https://github.com/heartcombo/devise)：

```
% bin/rails runner 'pp ActiveSupport::Dependencies.autoload_paths'
[".../app/controllers",
 ".../app/controllers/concerns",
 ".../app/helpers",
 ".../app/models",
 ".../app/models/concerns",
 ".../gems/devise-4.8.0/app/controllers",
 ".../gems/devise-4.8.0/app/helpers",
 ".../gems/devise-4.8.0/app/mailers"]
 ```

如果引擎控制其父應用程序的自動加載模式，則可以像平常一樣編寫引擎。
然而，如果一個引擎支援Rails 6或Rails 6.1並且不控制其父應用程式，則必須準備在`classic`或`zeitwerk`模式下運行。需要考慮的事項如下：

1. 如果`classic`模式需要`require_dependency`調用以確保某個常量在某個時刻被加載，請編寫它。雖然`zeitwerk`不需要它，但它不會有害，它也可以在`zeitwerk`模式下工作。

2. `classic`模式下使用底線分隔常量名（"User" -> "user.rb"），而`zeitwerk`模式下使用駝峰命名法（"user.rb" -> "User"）。它們在大多數情況下是一致的，但如果有連續的大寫字母序列，如"HTMLParser"，則不一致。確保兼容的最簡單方法是避免使用這樣的名稱。在這種情況下，選擇"HtmlParser"。

3. 在`classic`模式下，文件`app/model/concerns/foo.rb`可以定義`Foo`和`Concerns::Foo`。在`zeitwerk`模式下，只有一個選項：它必須定義`Foo`。為了確保兼容，請定義`Foo`。

測試
-------

### 手動測試

任務`zeitwerk:check`檢查項目結構是否符合預期的命名規範，對於手動檢查非常方便。例如，如果你正在從`classic`模式遷移到`zeitwerk`模式，或者如果你正在修復一些問題：

```
% bin/rails zeitwerk:check
請稍等，我正在急於加載應用程式。
一切正常！
```

根據應用程式配置，可能會有其他輸出，但最後的 "一切正常！" 是你要尋找的。

### 自動化測試

在測試套件中驗證項目是否正確地進行急於加載是一個好習慣。

這涵蓋了Zeitwerk命名規範的遵從以及其他可能的錯誤條件。請參閱[_Testing Rails Applications_](testing.html)指南中的[有關測試急於加載的部分](testing.html#testing-eager-loading)。

疑難排解
---------------

跟踪加載器的活動的最佳方法是檢查它們的活動。

最簡單的方法是在`config/application.rb`中加載框架默認值之後，包含以下代碼：

```ruby
Rails.autoloaders.log!
```

這將在標準輸出中打印跟踪信息。

如果你更喜歡將日誌記錄到文件中，請配置以下代碼：

```ruby
Rails.autoloaders.logger = Logger.new("#{Rails.root}/log/autoloading.log")
```

當`config/application.rb`執行時，Rails日誌記錄器尚不可用。如果你更喜歡使用Rails日誌記錄器，請在初始化程序中配置以下設置：

```ruby
# config/initializers/log_autoloaders.rb
Rails.autoloaders.logger = Rails.logger
```

Rails.autoloaders
-----------------

管理應用程式的Zeitwerk實例可在以下位置找到：

```ruby
Rails.autoloaders.main
Rails.autoloaders.once
```

斷言

```ruby
Rails.autoloaders.zeitwerk_enabled?
```

在Rails 7應用程式中仍然可用，並返回`true`。
[`config.enable_reloading`]: configuring.html#config-enable-reloading
[`config.file_watcher`]: configuring.html#config-file-watcher
[`config.eager_load`]: configuring.html#config-eager-load
[`config.rake_eager_load`]: configuring.html#config-rake-eager-load
