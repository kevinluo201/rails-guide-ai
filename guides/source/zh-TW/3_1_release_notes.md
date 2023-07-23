**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: da25f37b5b3eddff86c5b5b2cd24007f
Ruby on Rails 3.1 發行說明
===============================

Rails 3.1 的亮點：

* Streaming（串流）
* 可逆遷移
* 資源管道
* jQuery 作為預設的 JavaScript 函式庫

這些發行說明僅涵蓋主要更改。要了解各種錯誤修復和更改，請參閱變更日誌或檢查 GitHub 上主要 Rails 存儲庫中的[提交列表](https://github.com/rails/rails/commits/3-1-stable)。

--------------------------------------------------------------------------------

升級到 Rails 3.1
----------------------

如果您正在升級現有應用程式，建議在進行升級之前先進行良好的測試覆蓋。如果您尚未升級到 Rails 3，請先升級並確保您的應用程式仍然按預期運行，然後請注意以下更改：

### Rails 3.1 需要至少 Ruby 1.8.7

Rails 3.1 需要 Ruby 1.8.7 或更高版本。官方已正式停止支援所有先前的 Ruby 版本，您應該盡早升級。Rails 3.1 也與 Ruby 1.9.2 兼容。

提示：請注意，Ruby 1.8.7 p248 和 p249 存在會使 Rails 崩潰的序列化錯誤。Ruby Enterprise Edition 自 1.8.7-2010.02 版本起已修復了這些錯誤。至於 1.9 版本，Ruby 1.9.1 由於直接崩潰而無法使用，因此如果您想使用 1.9.x，請選擇 1.9.2 版本以確保順利運行。

### 應用程式中需要更新的內容

以下更改適用於將您的應用程式升級到 Rails 3.1.3，即 Rails 的最新 3.1.x 版本。

#### Gemfile

對您的 `Gemfile` 進行以下更改。

```ruby
gem 'rails', '= 3.1.3'
gem 'mysql2'

# 新資源管道所需
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# jQuery 是 Rails 3.1 的預設 JavaScript 函式庫
gem 'jquery-rails'
```

#### config/application.rb

* 資源管道需要以下新增設定：

    ```ruby
    config.assets.enabled = true
    config.assets.version = '1.0'
    ```

* 如果您的應用程式使用 "/assets" 路由來存取資源，您可能需要更改用於資源的前綴以避免衝突：

    ```ruby
    # 預設為 '/assets'
    config.assets.prefix = '/asset-files'
    ```

#### config/environments/development.rb

* 刪除 RJS 設定 `config.action_view.debug_rjs = true`。

* 如果啟用資源管道，請新增以下設定。

    ```ruby
    # 不壓縮資源
    config.assets.compress = false

    # 展開載入資源的行
    config.assets.debug = true
    ```

#### config/environments/production.rb

* 再次提醒，以下大部分更改是針對資源管道的。您可以在[資源管道](asset_pipeline.html)指南中了解更多相關資訊。
```ruby
# 壓縮 JavaScript 和 CSS
config.assets.compress = true

# 如果預編譯的資源遺失，不要回退到資源管道
config.assets.compile = false

# 生成資源 URL 的摘要
config.assets.digest = true

# 預設為 Rails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# 預編譯其他資源（application.js、application.css 和所有非 JS/CSS 的資源已經被加入）
# config.assets.precompile `= %w( admin.js admin.css )


# 強制使用 SSL，使用 Strict-Transport-Security，並使用安全的 cookies。
# config.force_ssl = true
```

#### config/environments/test.rb

```ruby
# 為測試配置靜態資源伺服器，以提高效能的快取控制
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

#### config/initializers/wrap_parameters.rb

* 如果您希望將參數封裝成巢狀哈希，請添加此文件並包含以下內容。這在新應用程式中默認啟用。

    ```ruby
    # 當您修改此文件時，請確定重新啟動伺服器。
    # 此文件包含 ActionController::ParamsWrapper 的設定，默認情況下啟用。

    # 啟用 JSON 的參數封裝。您可以通過將 :format 設置為空陣列來禁用此功能。
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters :format => [:json]
    end

    # 默認情況下禁用 JSON 中的根元素。
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
    ```

#### 在視圖中的資源輔助程式參考中刪除 :cache 和 :concat 選項

* 使用資源管道後，不再使用 :cache 和 :concat 選項，從視圖中刪除這些選項。

創建 Rails 3.1 應用程式
------------------------

```bash
# 您應該已經安裝了 'rails' RubyGem
$ rails new myapp
$ cd myapp
```

### 嵌入 Gems

Rails 現在使用應用程式根目錄中的 `Gemfile` 來確定您應用程式啟動所需的 Gems。這個 `Gemfile` 由 [Bundler](https://github.com/carlhuda/bundler) Gem 處理，然後安裝所有依賴項。它甚至可以將所有依賴項本地安裝到您的應用程式中，以便它不依賴於系統 Gems。

更多資訊：- [bundler 首頁](https://bundler.io/)

### 活在邊緣

`Bundler` 和 `Gemfile` 使得凍結 Rails 應用程式變得非常容易，只需使用新的專用 `bundle` 命令即可。如果您想直接從 Git 存儲庫進行捆綁，可以使用 `--edge` 標誌：

```bash
$ rails new myapp --edge
```

如果您有一個本地的 Rails 存儲庫並且想要使用它來生成應用程式，可以使用 `--dev` 標誌：

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

Rails 架構變更
--------------

### 資源管道

Rails 3.1 中的主要變更是資源管道。它使得 CSS 和 JavaScript 成為一等公民的程式碼，並實現了適當的組織，包括在插件和引擎中使用。
資產管道由[Sprockets](https://github.com/rails/sprockets)提供支援，並在[Asset Pipeline](asset_pipeline.html)指南中有詳細介紹。

### HTTP串流

HTTP串流是Rails 3.1中的另一個新功能。它允許瀏覽器在伺服器仍在生成回應時下載樣式表和JavaScript檔案。這需要Ruby 1.9.2，需要手動啟用，並且還需要網頁伺服器的支援，但目前流行的NGINX和Unicorn組合已經準備好支援這個功能。

### 預設的JS函式庫為jQuery

jQuery是Rails 3.1附帶的預設JavaScript函式庫。但如果你使用Prototype，切換到Prototype也很簡單。

```bash
$ rails new myapp -j prototype
```

### 身份對應

Rails 3.1中的Active Record具有身份對應功能。身份對應會保留先前實例化的記錄，並在再次存取時返回與該記錄相關聯的物件。身份對應是在每個請求的基礎上建立的，並在請求完成時清除。

Rails 3.1預設關閉身份對應功能。

Railties
--------

* jQuery是新的預設JavaScript函式庫。

* jQuery和Prototype不再是內建的函式庫，現在由`jquery-rails`和`prototype-rails`這兩個gem提供。

* 應用程式產生器接受一個`-j`選項，可以是任意字串。如果傳入"foo"，則會在`Gemfile`中添加"foo-rails"這個gem，並且應用程式的JavaScript清單會引入"foo"和"foo_ujs"。目前只有"prototype-rails"和"jquery-rails"這兩個gem存在，並且透過資產管道提供這些檔案。

* 產生應用程式或插件時，會自動執行`bundle install`，除非指定了`--skip-gemfile`或`--skip-bundle`選項。

* 控制器和資源產生器現在會自動產生資產的樣板（可以使用`--skip-assets`選項關閉此功能）。如果可用，這些樣板將使用CoffeeScript和Sass。

* Scaffold和app產生器在Ruby 1.9上運行時，會使用Ruby 1.9風格的Hash。如果要生成舊風格的Hash，可以傳遞`--old-style-hash`選項。

* Scaffold控制器產生器會為JSON創建格式區塊，而不是XML。

* Active Record的日誌輸出被重定向到STDOUT並在控制台中顯示。

* 新增了`config.force_ssl`配置，它會載入`Rack::SSL`中介軟體，並強制所有請求使用HTTPS協議。

* 新增了`rails plugin new`命令，用於生成帶有gemspec、測試和用於測試的虛擬應用程式的Rails插件。

* 在預設的中介軟體堆疊中新增了`Rack::Etag`和`Rack::ConditionalGet`。

* 在預設的中介軟體堆疊中新增了`Rack::Cache`。

* 引擎進行了重大更新-您可以將它們掛載在任何路徑上，啟用資產，運行產生器等。
動作套件
-----------

### 動作控制器

* 如果無法驗證 CSRF token 的真實性，將發出警告。

* 在控制器中指定 `force_ssl`，以強制瀏覽器通過 HTTPS 協議傳輸數據。可以使用 `:only` 或 `:except` 來限制特定操作。

* 在日誌中，從請求路徑中過濾掉在 `config.filter_parameters` 中指定的敏感查詢字符串參數。

* 從查詢字符串中刪除返回 `nil` 的 URL 參數。

* 添加了 `ActionController::ParamsWrapper`，將參數封裝成嵌套的哈希，並且在新應用程序的 JSON 請求中默認啟用。可以在 `config/initializers/wrap_parameters.rb` 中自定義此功能。

* 添加了 `config.action_controller.include_all_helpers`。默認情況下，在 `ActionController::Base` 中執行 `helper :all`，默認包含所有助手。將 `include_all_helpers` 設置為 `false` 將只包含 application_helper 和與控制器對應的助手（例如 foo_controller 的 foo_helper）。

* `url_for` 和命名的 URL 助手現在接受 `:subdomain` 和 `:domain` 作為選項。

* 添加了 `Base.http_basic_authenticate_with`，通過單個類方法調用進行簡單的 HTTP 基本身份驗證。

    ```ruby
    class PostsController < ApplicationController
      USER_NAME, PASSWORD = "dhh", "secret"

      before_filter :authenticate, :except => [ :index ]

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end

      private
        def authenticate
          authenticate_or_request_with_http_basic do |user_name, password|
            user_name == USER_NAME && password == PASSWORD
          end
        end
    end
    ```

    ..現在可以簡化為

    ```ruby
    class PostsController < ApplicationController
      http_basic_authenticate_with :name => "dhh", :password => "secret", :except => :index

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end
    end
    ```

* 添加了流式傳輸支持，可以通過以下方式啟用：

    ```ruby
    class PostsController < ActionController::Base
      stream
    end
    ```

    可以使用 `:only` 或 `:except` 將其限制在某些操作上。請閱讀 [`ActionController::Streaming`](https://api.rubyonrails.org/v3.1.0/classes/ActionController/Streaming.html) 中的文檔以獲取更多信息。

* 重定向路由方法現在還接受選項的哈希，該哈希僅會更改相關 URL 的部分，或者接受一個可調用的對象，從而實現重用重定向。

### 動作調度

* `config.action_dispatch.x_sendfile_header` 現在默認為 `nil`，`config/environments/production.rb` 不設置任何特定值。這允許服務器通過 `X-Sendfile-Type` 設置它。

* `ActionDispatch::MiddlewareStack` 現在使用組合而不是繼承，不再是一個數組。

* 添加了 `ActionDispatch::Request.ignore_accept_header`，以忽略 accept headers。
* 將`Rack::Cache`添加到默認堆棧中。

* 將etag的責任從`ActionDispatch::Response`移至中間件堆棧。

* 依賴於`Rack::Session`存儲API，以實現在Ruby世界中更好的兼容性。這是不向後兼容的，因為`Rack::Session`期望`#get_session`接受四個參數，並且需要`#destroy_session`而不僅僅是`#destroy`。

* 模板查找現在在繼承鏈中向上搜索更遠的位置。

### Action View

* 在`form_tag`中添加了一個`:authenticity_token`選項，用於自定義處理或通過傳遞`:authenticity_token => false`來省略令牌。

* 創建了`ActionView::Renderer`並為`ActionView::Context`指定了API。

* 在Rails 3.1中禁止了原地`SafeBuffer`的變異。

* 添加了HTML5的`button_tag`幫助程序。

* `file_field`自動將`multipart => true`添加到封裝表單中。

* 添加了一個方便的習慣用法，用於從`data`選項的哈希中生成HTML5的data-*屬性的標籤幫助程序：

    ```ruby
    tag("div", :data => {:name => 'Stephen', :city_state => %w(Chicago IL)})
    # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
    ```

鍵是使用破折號分隔的。值是JSON編碼的，除了字符串和符號。

* `csrf_meta_tag`被重命名為`csrf_meta_tags`，並為向後兼容性別名為`csrf_meta_tag`。

* 舊的模板處理程序API已被棄用，新的API只需要模板處理程序響應`call`方法。

* rhtml和rxml最終被刪除作為模板處理程序。

* `config.action_view.cache_template_loading`被重新引入，允許決定是否應該緩存模板。

* 提交表單幫助程序不再生成id為"object_name_id"的id。

* 允許`FormHelper#form_for`直接通過選項指定`method`，而不是通過`html`哈希。例如，`form_for(@post, remote: true, method: :delete)`代替`form_for(@post, remote: true, html: { method: :delete })`。

* 提供了`JavaScriptHelper#j()`作為`JavaScriptHelper#escape_javascript()`的別名。這取代了JSON gem在使用JavaScriptHelper的模板中添加的`Object#j()`方法。

* 允許在日期時間選擇器中使用AM/PM格式。

* `auto_link`已從Rails中刪除並提取到[rails_autolink gem](https://github.com/tenderlove/rails_autolink)

Active Record
-------------

* 添加了一個類方法`pluralize_table_names`，用於單獨模型的單數/複數表名。以前，這只能通過`ActiveRecord::Base.pluralize_table_names`全局設置所有模型。

    ```ruby
    class User < ActiveRecord::Base
      self.pluralize_table_names = false
    end
    ```

* 添加了對單數關聯的屬性的塊設置。該塊將在實例初始化後調用。

    ```ruby
    class User < ActiveRecord::Base
      has_one :account
    end

    user.build_account{ |a| a.credit_limit = 100.0 }
    ```

* 添加了`ActiveRecord::Base.attribute_names`，以返回屬性名稱列表。如果模型是抽象的或表不存在，則返回空數組。
* CSV固定格式已被廢棄，並將在Rails 3.2.0中移除支援。

* `ActiveRecord#new`、`ActiveRecord#create`和`ActiveRecord#update_attributes`都接受第二個哈希作為選項，允許您在指定屬性時指定要考慮的角色。這是建立在Active Model的新質量分配功能之上的：

    ```ruby
    class Post < ActiveRecord::Base
      attr_accessible :title
      attr_accessible :title, :published_at, :as => :admin
    end

    Post.new(params[:post], :as => :admin)
    ```

* `default_scope`現在可以接受區塊、lambda或任何其他對象，該對象對於惰性評估是可響應的。

* 默認範圍現在在最後可能的時刻進行評估，以避免出現範圍將隱含包含默認範圍的問題，這樣將無法通過Model.unscoped來消除。

* PostgreSQL適配器僅支持8.2版本及更高版本的PostgreSQL。

* `ConnectionManagement`中間件已更改為在rack body刷新後清理連接池。

* 在Active Record上添加了一個`update_column`方法。此新方法更新對象上的給定屬性，跳過驗證和回調。建議使用`update_attributes`或`update_attribute`，除非您確定不想執行任何回調，包括修改`updated_at`列。不應在新記錄上調用它。

* 具有`：through`選項的關聯現在可以使用任何關聯作為通過或源關聯，包括具有`：through`選項和`has_and_belongs_to_many`關聯的其他關聯。

* 當前數據庫連接的配置現在可以通過`ActiveRecord::Base.connection_config`訪問。

* 除非兩者都提供，否則從COUNT查詢中刪除限制和偏移。

    ```ruby
    People.limit(1).count           # => 'SELECT COUNT(*) FROM people'
    People.offset(1).count          # => 'SELECT COUNT(*) FROM people'
    People.limit(1).offset(1).count # => 'SELECT COUNT(*) FROM people LIMIT 1 OFFSET 1'
    ```

* `ActiveRecord::Associations::AssociationProxy`已被拆分。現在有一個負責操作關聯的`Association`類（和子類），然後是一個單獨的、薄包裝的`CollectionProxy`，用於代理集合關聯。這樣可以防止命名空間污染，分離關注點，並允許進一步的重構。

* 單數關聯（`has_one`、`belongs_to`）不再有代理，只需返回相關記錄或`nil`。這意味著您不應該使用未記錄的方法，如`bob.mother.create` - 而應該使用`bob.create_mother`。

* 支持在`has_many :through`關聯上使用`：dependent`選項。出於歷史和實際原因，`association.delete(*records)`的默認刪除策略是`：delete_all`，儘管對於常規的has_many，默認策略是`：nullify`。此外，這僅在源反射是belongs_to的情況下才有效。對於其他情況，您應直接修改通過關聯。
* `association.destroy` 在 `has_and_belongs_to_many` 和 `has_many :through` 的行為已經改變。從現在開始，'destroy' 或 'delete' 會被解釋為 '移除連結'，而不是（必然） '移除相關的記錄'。

* 以前，`has_and_belongs_to_many.destroy(*records)` 會銷毀這些記錄本身。它不會刪除連結表中的任何記錄。現在，它會刪除連結表中的記錄。

* 以前，`has_many_through.destroy(*records)` 會銷毀這些記錄本身，以及連結表中的記錄。[註：這並不是一直如此；Rails 的先前版本只會刪除這些記錄本身。] 現在，它只會銷毀連結表中的記錄。

* 請注意，這個改變在某種程度上是不相容的，但不幸的是在改變之前沒有辦法 '棄用' 它。這個改變是為了在不同類型的關聯中保持 'destroy' 或 'delete' 的意義一致。如果你想要銷毀這些記錄本身，你可以使用 `records.association.each(&:destroy)`。

* 在 `change_table` 中添加 `:bulk => true` 選項，以便使用單個 ALTER 語句定義的所有模式更改。

    ```ruby
    change_table(:users, :bulk => true) do |t|
      t.string :company_name
      t.change :birthdate, :datetime
    end
    ```

* 不再支援在 `has_and_belongs_to_many` 連結表上訪問屬性。應該使用 `has_many :through`。

* 為 `has_one` 和 `belongs_to` 關聯添加了 `create_association!` 方法。

* 遷移現在是可逆的，這意味著 Rails 將找出如何反轉你的遷移。要使用可逆遷移，只需定義 `change` 方法。

    ```ruby
    class MyMigration < ActiveRecord::Migration
      def change
        create_table(:horses) do |t|
          t.column :content, :text
          t.column :remind_at, :datetime
        end
      end
    end
    ```

* 有些事情無法自動反轉。如果你知道如何反轉這些事情，應該在遷移中定義 `up` 和 `down`。如果在 `change` 中定義了無法反轉的內容，則在向下遷移時會引發 `IrreversibleMigration` 異常。

* 遷移現在使用實例方法而不是類方法：

    ```ruby
    class FooMigration < ActiveRecord::Migration
      def up # 不是 self.up
        # ...
      end
    end
    ```

* 從模型和構造遷移生成的遷移文件（例如，add_name_to_users）使用可逆遷移的 `change` 方法，而不是普通的 `up` 和 `down` 方法。

* 不再支援在關聯上使用插值字符串 SQL 條件。應該使用 proc。

    ```ruby
    has_many :things, :conditions => 'foo = #{bar}'          # 之前
    has_many :things, :conditions => proc { "foo = #{bar}" } # 之後
    ```
在proc內部，`self`是擁有關聯的物件，除非你正在急於加載關聯，此時`self`是關聯所在的類別。

你可以在proc內部設置任何“正常”的條件，所以以下也是有效的：

```ruby
has_many :things, :conditions => proc { ["foo = ?", bar] }
```

* 之前，在`has_and_belongs_to_many`關聯上的`:insert_sql`和`:delete_sql`允許你調用'record'來獲取正在插入或刪除的記錄。現在這作為一個參數傳遞給proc。

* 添加了`ActiveRecord::Base#has_secure_password`（通過`ActiveModel::SecurePassword`）來封裝使用BCrypt加密和鹽的簡單密碼使用方式。

```ruby
# Schema: User(name:string, password_digest:string, password_salt:string)
class User < ActiveRecord::Base
  has_secure_password
end
```

* 當生成模型時，默認為`belongs_to`或`references`列添加了`add_index`。

* 設置`belongs_to`對象的id將更新對該對象的引用。

* `ActiveRecord::Base#dup`和`ActiveRecord::Base#clone`的語義已更改，以更接近普通的Ruby dup和clone語義。

* 調用`ActiveRecord::Base#clone`將導致記錄的淺層拷貝，包括拷貝凍結狀態。不會調用任何回調。

* 調用`ActiveRecord::Base#dup`將複製該記錄，包括調用after initialize鉤子。不會複製凍結狀態，並且所有關聯將被清除。複製的記錄將返回`true`作為`new_record?`，具有`nil`的id字段，並且可以保存。

* 查詢緩存現在與預備語句一起工作。應用程序不需要進行任何更改。

Active Model
------------

* `attr_accessible`接受一個選項`:as`來指定角色。

* `InclusionValidator`、`ExclusionValidator`和`FormatValidator`現在接受一個選項，可以是一個proc、lambda或任何回應`call`的對象。此選項將以當前記錄作為參數調用，並返回一個對象，該對象對於`InclusionValidator`和`ExclusionValidator`需要回應`include?`，對於`FormatValidator`需要返回一個正則表達式對象。

* 添加了`ActiveModel::SecurePassword`，以封裝使用BCrypt加密和鹽的簡單密碼使用方式。

* `ActiveModel::AttributeMethods`允許按需定義屬性。

* 添加了對選擇性啟用和禁用觀察者的支持。

* 不再支持替代的`I18n`命名空間查找。

Active Resource
---------------

* 所有請求的默認格式已更改為JSON。如果你想繼續使用XML，你需要在類別中設置`self.format = :xml`。例如，

```ruby
class User < ActiveResource::Base
  self.format = :xml
end
```

Active Support
--------------
* `ActiveSupport::Dependencies` 現在在 `load_missing_constant` 中如果找到現有的常數會拋出 `NameError`。

* 新增了一個新的報告方法 `Kernel#quietly`，可以同時將 `STDOUT` 和 `STDERR` 靜音。

* 新增了 `String#inquiry` 作為一個方便的方法，將一個字串轉換為 `StringInquirer` 物件。

* 新增了 `Object#in?` 用於測試一個物件是否包含在另一個物件中。

* `LocalCache` 策略現在是一個真正的中介軟體類，不再是匿名類。

* 引入了 `ActiveSupport::Dependencies::ClassCache` 類，用於保存可重新載入的類的引用。

* 重構了 `ActiveSupport::Dependencies::Reference`，直接利用新的 `ClassCache`。

* 在 Ruby 1.8 中，將 `Range#cover?` 回溯為 `Range#include?` 的別名。

* 在 Date/DateTime/Time 中新增了 `weeks_ago` 和 `prev_week`。

* 在 `ActiveSupport::Dependencies.remove_unloadable_constants!` 中新增了 `before_remove_const` 回調。

已棄用：

* `ActiveSupport::SecureRandom` 已棄用，建議使用 Ruby 標準庫中的 `SecureRandom`。

感謝
-------

請參閱 [Rails 的完整貢獻者列表](https://contributors.rubyonrails.org/)，感謝那些花了許多時間使 Rails 成為穩定和強大的框架的人。向他們致敬。

Rails 3.1 發行說明由 [Vijay Dev](https://github.com/vijaydev) 編譯。
