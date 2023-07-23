**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 30550ed8fa3c0983f3d99a0e91571a98
Ruby on Rails 3.2 發行說明
===============================

Rails 3.2 的亮點：

* 更快的開發模式
* 新的路由引擎
* 自動查詢解釋
* 標籤記錄

這些發行說明僅涵蓋主要更改。要了解各種錯誤修復和更改，請參閱更改日誌或查看 GitHub 上主要 Rails 存儲庫中的[提交列表](https://github.com/rails/rails/commits/3-2-stable)。

--------------------------------------------------------------------------------

升級到 Rails 3.2
----------------------

如果您正在升級現有應用程序，建議在進行升級之前進行良好的測試覆蓋。如果您尚未升級到 Rails 3.1，請先升級到該版本，並確保您的應用程序運行正常，然後再嘗試升級到 Rails 3.2。然後請注意以下更改：

### Rails 3.2 需要至少 Ruby 1.8.7

Rails 3.2 需要 Ruby 1.8.7 或更高版本。官方已正式停止支援之前的所有 Ruby 版本，您應盡早升級。Rails 3.2 也與 Ruby 1.9.2 兼容。

提示：請注意，Ruby 1.8.7 p248 和 p249 存在序列化錯誤，會導致 Rails 崩潰。Ruby Enterprise Edition 自 1.8.7-2010.02 版本以來已修復了這些問題。至於 1.9 版本，Ruby 1.9.1 無法使用，因為它會直接崩潰，所以如果您想使用 1.9.x，請轉用 1.9.2 或 1.9.3 版本以確保順利運行。

### 應用程序中需要更新的內容

* 更新您的 `Gemfile`，依賴於以下版本：
    * `rails = 3.2.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

* Rails 3.2 不再支援 `vendor/plugins`，Rails 4.0 將完全刪除這些插件。您可以將這些插件提取為 gems，並將它們添加到您的 `Gemfile` 中以替換它們。如果您選擇不將它們作為 gems 使用，您可以將它們移動到 `lib/my_plugin/*`，並在 `config/initializers/my_plugin.rb` 中添加適當的初始化程式。

* 在 `config/environments/development.rb` 中需要添加幾個新的配置更改：

    ```ruby
    # 對 Active Record 模型的批量賦值保護引發異常
    config.active_record.mass_assignment_sanitizer = :strict

    # 對於執行時間超過此閾值的查詢記錄查詢計劃（適用於 SQLite、MySQL 和 PostgreSQL）
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    `mass_assignment_sanitizer` 配置也需要在 `config/environments/test.rb` 中添加：

    ```ruby
    # 對 Active Record 模型的批量賦值保護引發異常
    config.active_record.mass_assignment_sanitizer = :strict
    ```

### 引擎中需要更新的內容

將 `script/rails` 中註釋下方的代碼替換為以下內容：

```ruby
ENGINE_ROOT = File.expand_path('../..', __FILE__)
ENGINE_PATH = File.expand_path('../../lib/your_engine_name/engine', __FILE__)

require "rails/all"
require "rails/engine/commands"
```
建立一個 Rails 3.2 應用程式
--------------------------------

```bash
# 您應該已經安裝了 'rails' RubyGem
$ rails new myapp
$ cd myapp
```

### 管理 Gems

Rails 現在使用位於應用程式根目錄下的 `Gemfile` 來確定您的應用程式所需的 Gems。這個 `Gemfile` 會被 [Bundler](https://github.com/carlhuda/bundler) gem 處理，然後安裝所有相依的 Gems。它甚至可以將所有相依的 Gems 安裝到您的應用程式本地，這樣就不會依賴於系統的 Gems。

更多資訊：[Bundler 首頁](https://bundler.io/)

### 沿用最新版本

`Bundler` 和 `Gemfile` 讓您的 Rails 應用程式凍結變得非常容易，只需使用新的專用 `bundle` 命令即可。如果您想直接從 Git 倉庫捆綁，可以使用 `--edge` 參數：

```bash
$ rails new myapp --edge
```

如果您有一個本地的 Rails 倉庫並且想要使用它來生成應用程式，可以使用 `--dev` 參數：

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

主要功能
--------------

### 更快的開發模式和路由

Rails 3.2 提供了一個明顯更快的開發模式。受到 [Active Reload](https://github.com/paneq/active_reload) 的啟發，Rails 只在文件實際更改時重新載入類別。在較大的應用程式上，性能提升非常明顯。由於新的 [Journey](https://github.com/rails/journey) 引擎，路由識別速度也大幅提升。

### 自動查詢解釋

Rails 3.2 提供了一個很好的功能，通過在 `ActiveRecord::Relation` 中定義一個 `explain` 方法，解釋 Arel 生成的查詢。例如，您可以運行像 `puts Person.active.limit(5).explain` 這樣的命令，並解釋 Arel 生成的查詢。這可以用於檢查正確的索引和進一步的優化。

在開發模式下，運行時間超過半秒的查詢會自動進行解釋。當然，這個閾值可以更改。

### 標記日誌

在運行多用戶、多帳戶的應用程式時，能夠按照誰做了什麼來過濾日誌是非常有幫助的。Active Support 中的 TaggedLogging 正好可以通過在日誌行上標記子域名、請求 ID 和其他任何有助於調試此類應用程式的內容來實現。

文件
-------------

從 Rails 3.2 開始，Rails 指南可在 Kindle 上使用，並且可在 iPad、iPhone、Mac、Android 等設備上使用免費的 Kindle 閱讀應用程式。

Railties
--------

* 通過僅在相依文件更改時重新載入類別，加快開發速度。可以通過將 `config.reload_classes_only_on_change` 設置為 false 來關閉此功能。

* 新的應用程式在環境配置文件中獲得了一個 `config.active_record.auto_explain_threshold_in_seconds` 標誌。在 `development.rb` 中設置為 `0.5`，在 `production.rb` 中註釋掉。在 `test.rb` 中沒有提及。
* 新增了`config.exceptions_app`，用於設置當發生異常時`ShowException`中間件調用的異常應用程序。默認為`ActionDispatch::PublicExceptions.new(Rails.public_path)`。

* 新增了`DebugExceptions`中間件，其中包含從`ShowExceptions`中間件中提取的功能。

* 在`rake routes`中顯示已掛載引擎的路由。

* 允許使用`config.railties_order`更改railties的加載順序，例如：

    ```ruby
    config.railties_order = [Blog::Engine, :main_app, :all]
    ```

* 對於沒有內容的API請求，Scaffold返回204 No Content。這使得Scaffold可以直接與jQuery配合使用。

* 更新`Rails::Rack::Logger`中間件，將`config.log_tags`中設置的任何標籤應用於`ActiveSupport::TaggedLogging`。這使得可以輕鬆地將日誌行標記為調試信息，例如子域和請求ID，這在調試多用戶生產應用程序時非常有用。

* 可以在`~/.railsrc`中設置`rails new`的默認選項。您可以在家目錄中的`.railsrc`配置文件中指定要在每次運行`rails new`時使用的額外命令行參數。

* 為`destroy`添加了別名`d`。這對於引擎也有效。

* Scaffold和model生成器的屬性默認為字符串。這允許以下操作：`bin/rails g scaffold Post title body:text author`

* 允許scaffold/model/migration生成器接受“index”和“uniq”修飾符。例如，

    ```bash
    bin/rails g scaffold Post title:string:index author:uniq price:decimal{7,2}
    ```

    將為`title`和`author`創建索引，後者將是唯一索引。某些類型（如decimal）接受自定義選項。在示例中，`price`將是一個decimal列，其精度和縮放分別設置為7和2。

* 將gem從默認的`Gemfile`中刪除。

* 刪除了舊的插件生成器`rails generate plugin`，改用`rails plugin new`命令。

* 刪除了舊的`config.paths.app.controller` API，改用`config.paths["app/controller"]`。

### 廢棄

* `Rails::Plugin`已被廢棄，將在Rails 4.0中刪除。請使用gems或bundler與路徑或git依賴項代替將插件添加到`vendor/plugins`中。

Action Mailer
-------------

* 將`mail`版本升級到2.4.0。

* 刪除了自Rails 3.0起被廢棄的舊Action Mailer API。

Action Pack
-----------

### Action Controller

* 將`ActiveSupport::Benchmarkable`設置為`ActionController::Base`的默認模塊，因此`#benchmark`方法再次在控制器上下文中可用，就像以前一樣。

* 將`gzip`選項添加到`caches_page`。可以使用`page_cache_compression`在全局配置默認選項。

* 當您使用`：only`和`：except`條件指定佈局並且這些條件失敗時，Rails現在將使用您的默認佈局（例如“layouts/application”）。
```ruby
class CarsController
  layout 'single_car', :only => :show
end
```

當請求進入 `:show` 動作時，Rails 將使用 `layouts/single_car` 作為佈局，當請求進入其他動作時，將使用 `layouts/application`（或者如果存在的話，使用 `layouts/cars`）作為佈局。

* 如果提供了 `:as` 選項，`form_for` 將使用 `#{action}_#{as}` 作為 CSS 類和 id。較早版本使用 `#{as}_#{action}`。

* 在 Active Record 模型上，`ActionController::ParamsWrapper` 現在只包裝已設置的 `attr_accessible` 屬性。如果沒有設置，只會包裝 `attribute_names` 類方法返回的屬性。這修復了通過將它們添加到 `attr_accessible` 來包裝嵌套屬性的問題。

* 每次 before 回調停止時，日誌都會記錄 "Filter chain halted as CALLBACKNAME rendered or redirected"。

* `ActionDispatch::ShowExceptions` 進行了重構。控制器負責選擇是否顯示異常。可以在控制器中重寫 `show_detailed_exceptions?` 以指定哪些請求應該提供錯誤的調試信息。

* Responders 現在對於沒有響應主體的 API 請求返回 204 No Content（與新的腳手架一樣）。

* `ActionController::TestCase` 的 cookies 進行了重構。現在，測試用例中分配 cookies 應該使用 `cookies[]`。

```ruby
cookies[:email] = 'user@example.com'
get :index
assert_equal 'user@example.com', cookies[:email]
```

要清除 cookies，使用 `clear`。

```ruby
cookies.clear
get :index
assert_nil cookies[:email]
```

我們現在不再寫出 HTTP_COOKIE，cookie jar 在請求之間是持久的，因此如果您需要操作測試的環境，您需要在 cookie jar 創建之前進行操作。

* 如果未提供 `:type`，`send_file` 現在將從文件擴展名猜測 MIME 類型。

* 添加了 PDF、ZIP 和其他格式的 MIME 類型條目。

* 允許 `fresh_when/stale?` 接受記錄而不是選項哈希。

* 將缺少 CSRF token 的警告日誌級別從 `:debug` 更改為 `:warn`。

* 資源應該默認使用請求協議，如果沒有請求可用，則默認為相對協議。

#### 廢棄

* 在父控制器設置了顯式佈局的控制器中，已廢棄隱含的佈局查找：

```ruby
class ApplicationController
  layout "application"
end

class PostsController < ApplicationController
end
```

在上面的示例中，`PostsController` 將不再自動查找 posts 佈局。如果需要此功能，可以從 `ApplicationController` 中刪除 `layout "application"`，或者在 `PostsController` 中明確將其設置為 `nil`。

* 已廢棄 `ActionController::UnknownAction`，改用 `AbstractController::ActionNotFound`。

* 已廢棄 `ActionController::DoubleRenderError`，改用 `AbstractController::DoubleRenderError`。

* 已廢棄 `method_missing`，改用 `action_missing` 來處理缺少的動作。

* 已廢棄 `ActionController#rescue_action`、`ActionController#initialize_template_class` 和 `ActionController#assign_shortcuts`。
### Action Dispatch

* 新增 `config.action_dispatch.default_charset` 用於配置 `ActionDispatch::Response` 的預設字符集。

* 新增 `ActionDispatch::RequestId` 中間件，可將唯一的 X-Request-Id 標頭提供給回應，並啟用 `ActionDispatch::Request#uuid` 方法。這使得在堆疊中輕鬆追蹤請求的端到端，並在混合日誌（如 Syslog）中識別個別請求。

* `ShowExceptions` 中間件現在接受一個異常應用程序，該應用程序負責在應用程序失敗時呈現異常。應用程序使用 `env["action_dispatch.exception"]` 中的異常副本和重寫狀態碼的 `PATH_INFO` 調用。

* 允許通過 railtie 配置救援響應，如 `config.action_dispatch.rescue_responses`。

#### 廢棄功能

* 廢棄在控制器層級設置預設字符集的能力，請改用新的 `config.action_dispatch.default_charset`。

### Action View

* 在 `ActionView::Helpers::FormBuilder` 中新增對 `button_tag` 的支援。此支援模仿 `submit_tag` 的默認行為。

    ```erb
    <%= form_for @post do |f| %>
      <%= f.button %>
    <% end %>
    ```

* 日期輔助方法接受一個新選項 `:use_two_digit_numbers => true`，該選項在顯示月份和日期的選擇框時添加前導零，而不更改相應的值。例如，這對於顯示 ISO 8601 格式的日期（如 '2011-08-01'）非常有用。

* 您可以為表單提供一個命名空間，以確保表單元素的 id 屬性的唯一性。生成的 HTML id 將在命名空間屬性前加上底線。

    ```erb
    <%= form_for(@offer, :namespace => 'namespace') do |f| %>
      <%= f.label :version, '版本' %>：
      <%= f.text_field :version %>
    <% end %>
    ```

* 將 `select_year` 的選項數量限制為 1000。傳遞 `:max_years_allowed` 選項以設置自己的限制。

* `content_tag_for` 和 `div_for` 現在可以接受一個記錄集合。如果在區塊中設置了接收參數，它還會將記錄作為第一個參數傳遞。因此，不需要再這樣做：

    ```ruby
    @items.each do |item|
      content_tag_for(:li, item) do
        Title: <%= item.title %>
      end
    end
    ```

    可以這樣做：

    ```ruby
    content_tag_for(:li, @items) do |item|
      Title: <%= item.title %>
    end
    ```

* 新增 `font_path` 助手方法，用於計算 `public/fonts` 中字體資源的路徑。

#### 廢棄功能

* 廢棄將格式或處理程序傳遞給 `render :template` 等的能力，請改為直接提供 `:handlers` 和 `:formats` 作為選項：`render :template => "foo", :formats => [:html, :js], :handlers => :erb`。

### Sprockets

* 添加配置選項 `config.assets.logger` 以控制 Sprockets 的日誌記錄。將其設置為 `false` 可關閉日誌記錄，設置為 `nil` 則默認使用 `Rails.logger`。
Active Record
-------------

* 布林欄位的'on'和'ON'值會被轉換為true。

* 當`timestamps`方法創建`created_at`和`updated_at`欄位時，默認將它們設置為非空。

* 實現了`ActiveRecord::Relation#explain`。

* 實現了`ActiveRecord::Base.silence_auto_explain`，允許用戶在區塊內選擇性禁用自動EXPLAIN。

* 對於慢查詢，實現了自動EXPLAIN日誌記錄。一個新的配置參數`config.active_record.auto_explain_threshold_in_seconds`決定了什麼被視為慢查詢。將其設置為nil將禁用此功能。默認值在開發模式下為0.5，在測試和生產模式下為nil。Rails 3.2在SQLite、MySQL（mysql2 adapter）和PostgreSQL中支持此功能。

* 添加了`ActiveRecord::Base.store`，用於聲明簡單的單列鍵值存儲。

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [ :color, :homepage ]
    end

    u = User.new(color: 'black', homepage: '37signals.com')
    u.color                          # 存儲的屬性訪問器
    u.settings[:country] = 'Denmark' # 任何屬性，即使沒有指定訪問器
    ```

* 添加了僅適用於特定範圍的遷移的選項，這允許僅運行來自一個引擎的遷移（例如，撤銷需要被刪除的引擎的更改）。

    ```
    rake db:migrate SCOPE=blog
    ```

* 從引擎複製的遷移現在帶有引擎名稱的範圍，例如`01_create_posts.blog.rb`。

* 實現了`ActiveRecord::Relation#pluck`方法，該方法直接從底層表格返回一個列值的數組。這也適用於序列化的屬性。

    ```ruby
    Client.where(:active => true).pluck(:id)
    # SELECT id from clients where active = 1
    ```

* 生成的關聯方法被創建在一個單獨的模塊中，以允許重寫和組合。對於名為MyModel的類，該模塊名為`MyModel::GeneratedFeatureMethods`。它被立即包含到模型類中，在Active Model中定義的`generated_attributes_methods`模塊之後，因此關聯方法將覆蓋相同名稱的屬性方法。

* 添加了`ActiveRecord::Relation#uniq`以生成唯一的查詢。

    ```ruby
    Client.select('DISTINCT name')
    ```

    ..可以寫成:

    ```ruby
    Client.select(:name).uniq
    ```

    這也允許您在關聯中取消唯一性:

    ```ruby
    Client.select(:name).uniq.uniq(false)
    ```

* 在SQLite、MySQL和PostgreSQL适配器中支持索引排序。

* 允許關聯的`:class_name`選項接受符號，除了字符串。這是為了避免混淆新手，並與其他選項（如`:foreign_key`）一致，它們已經允許使用符號或字符串。

    ```ruby
    has_many :clients, :class_name => :Client # 注意符號需要大寫
    ```

* 在開發模式下，`db:drop`也會刪除測試數據庫，以與`db:create`對稱。
* 在MySQL中，不區分大小寫的唯一性驗證在列已經使用不區分大小寫排序時，避免了調用LOWER。

* 事務性固定裝置列舉所有活動的數據庫連接。您可以在不禁用事務性固定裝置的情況下在不同的連接上測試模型。

* 在Active Record中添加了`first_or_create`、`first_or_create!`和`first_or_initialize`方法。這比舊的`find_or_create_by`動態方法更好，因為它更清楚地指出了用於查找記錄的參數和用於創建記錄的參數。

    ```ruby
    User.where(:first_name => "Scarlett").first_or_create!(:last_name => "Johansson")
    ```

* 在Active Record對象中添加了`with_lock`方法，該方法開始一個事務，對對象進行鎖定（悲觀鎖定）並且將控制權傳遞給塊。該方法接受一個（可選的）參數並將其傳遞給`lock!`。

    這使得可以這樣編寫代碼：

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        transaction do
          lock!
          # ... 取消邏輯
        end
      end
    end
    ```

    等價於：

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        with_lock do
          # ... 取消邏輯
        end
      end
    end
    ```

### 廢棄

* 在線程中自動關閉連接已被廢棄。例如，以下代碼已被廢棄：

    ```ruby
    Thread.new { Post.find(1) }.join
    ```

    應該在線程結束時關閉數據庫連接：

    ```ruby
    Thread.new {
      Post.find(1)
      Post.connection.close
    }.join
    ```

    只有在應用程序代碼中生成線程的人需要關注此更改。

* `set_table_name`、`set_inheritance_column`、`set_sequence_name`、`set_primary_key`、`set_locking_column`方法已被廢棄。請改用賦值方法。例如，使用`self.table_name=`代替`set_table_name`。

    ```ruby
    class Project < ActiveRecord::Base
      self.table_name = "project"
    end
    ```

    或者定義自己的`self.table_name`方法：

    ```ruby
    class Post < ActiveRecord::Base
      def self.table_name
        "special_" + super
      end
    end

    Post.table_name # => "special_posts"
    ```

Active Model
------------

* 添加了`ActiveModel::Errors#added?`方法，用於檢查是否已添加特定的錯誤。

* 添加了使用`strict => true`定義嚴格驗證的能力，當驗證失敗時始終引發異常。

* 提供了`mass_assignment_sanitizer`作為一個簡單的API來替換清潔器行為。同時支持`logger`（默認）和`strict`清潔器行為。

### 廢棄

* 在`ActiveModel::AttributeMethods`中廢棄了`define_attr_method`，因為它只存在於支持Active Record中的`set_table_name`等方法，而這些方法本身已被廢棄。

* 在`ActiveModel::Naming`中廢棄了`Model.model_name.partial_path`，改用`model.to_partial_path`。

Active Resource
---------------

* 重定向響應：303 See Other和307 Temporary Redirect現在的行為與301 Moved Permanently和302 Found相同。

Active Support
--------------

* 添加了`ActiveSupport:TaggedLogging`，可以將任何標準的`Logger`類包裝起來，提供標記功能。

    ```ruby
    Logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    Logger.tagged("BCX") { Logger.info "Stuff" }
    # 輸出日誌 "[BCX] Stuff"

    Logger.tagged("BCX", "Jason") { Logger.info "Stuff" }
    # 輸出日誌 "[BCX] [Jason] Stuff"

    Logger.tagged("BCX") { Logger.tagged("Jason") { Logger.info "Stuff" } }
    # 輸出日誌 "[BCX] [Jason] Stuff"
    ```
* `Date`、`Time`和`DateTime`中的`beginning_of_week`方法接受一个可选参数，表示假设一周从哪一天开始。

* `ActiveSupport::Notifications.subscribed`提供了在块运行时订阅事件的功能。

* 定义了新的方法`Module#qualified_const_defined?`、`Module#qualified_const_get`和`Module#qualified_const_set`，它们类似于标准API中的相应方法，但接受限定的常量名称。

* 添加了`#deconstantize`，它与inflections中的`#demodulize`相对应。它从限定的常量名称中移除最右边的部分。

* 添加了`safe_constantize`，它将一个字符串转换为常量，但如果常量（或其中的一部分）不存在，则返回`nil`而不是引发异常。

* 当使用`Array#extract_options!`时，现在将`ActiveSupport::OrderedHash`标记为可提取。

* 添加了`Array#prepend`作为`Array#unshift`的别名，以及`Array#append`作为`Array#<<`的别名。

* 对于Ruby 1.9，空字符串的定义已扩展到Unicode空白字符。此外，在Ruby 1.8中，表意空格U+3000被视为空白字符。

* inflector理解首字母缩略词。

* 添加了`Time#all_day`、`Time#all_week`、`Time#all_quarter`和`Time#all_year`作为生成范围的一种方式。

    ```ruby
    Event.where(:created_at => Time.now.all_week)
    Event.where(:created_at => Time.now.all_day)
    ```

* 添加了`instance_accessor: false`作为`Class#cattr_accessor`和相关方法的选项。

* 当给定一个接受参数的块时，`ActiveSupport::OrderedHash`的`#each`和`#each_pair`现在具有不同的行为。

* 添加了`ActiveSupport::Cache::NullStore`，用于开发和测试。

* 删除了`ActiveSupport::SecureRandom`，改用标准库中的`SecureRandom`。

### 弃用

* 弃用了`ActiveSupport::Base64`，改用`::Base64`。

* 弃用了`ActiveSupport::Memoizable`，改用Ruby的记忆化模式。

* 弃用了`Module#synchronize`，没有替代方法。请使用Ruby标准库中的monitor。

* 弃用了`ActiveSupport::MessageEncryptor#encrypt`和`ActiveSupport::MessageEncryptor#decrypt`。

* 弃用了`ActiveSupport::BufferedLogger#silence`。如果要在某个块中禁止日志记录，请更改该块的日志级别。

* 弃用了`ActiveSupport::BufferedLogger#open_log`。这个方法本来就不应该是公开的。

* 弃用了`ActiveSupport::BufferedLogger`自动创建日志文件目录的行为。请确保在实例化之前创建日志文件的目录。

* 弃用了`ActiveSupport::BufferedLogger#auto_flushing`。请设置底层文件句柄的同步级别，或调整文件系统。现在刷新由文件系统缓存控制。

    ```ruby
    f = File.open('foo.log', 'w')
    f.sync = true
    ActiveSupport::BufferedLogger.new f
    ```

* 弃用了`ActiveSupport::BufferedLogger#flush`。请在文件句柄上设置同步，或调整文件系统。

致谢
-------

请参阅[Rails的完整贡献者列表](http://contributors.rubyonrails.org/)，感谢那些花费了许多时间使Rails成为稳定和强大的框架的人。向他们致敬。
Rails 3.2 發行說明是由 [Vijay Dev](https://github.com/vijaydev) 編譯的。
