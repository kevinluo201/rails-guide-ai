**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 77b47af4826df984dead9f6263cfd135
Ruby on Rails 2.3 發行說明
===============================

Rails 2.3 提供了各種新功能和改進功能，包括全面的 Rack 整合、更新的 Rails Engines 支援、Active Record 的巢狀交易、動態和預設範圍、統一的渲染、更高效的路由、應用程式模板和靜音回溯。這份清單涵蓋了主要的升級，但不包括每一個小的錯誤修復和更改。如果你想看到所有的內容，請查看 GitHub 上主要的 Rails 儲存庫中的 [提交清單](https://github.com/rails/rails/commits/2-3-stable) 或檢查各個 Rails 元件的 `CHANGELOG` 檔案。

--------------------------------------------------------------------------------

應用程式架構
------------------------

Rails 應用程式的架構有兩個主要變化：完全整合了 [Rack](https://rack.github.io/) 模組化的網頁伺服器介面，以及對 Rails Engines 的重新支援。

### Rack 整合

Rails 現在已經與其 CGI 過去分道揚鑣，並且在各處使用 Rack。這需要並導致了大量的內部變更（但如果你使用 CGI，不用擔心；Rails 現在通過代理介面支援 CGI）。儘管如此，這是對 Rails 內部的重大變更。升級到 2.3 版後，你應該在本地環境和生產環境上進行測試。一些需要測試的事項包括：

* 會話（Sessions）
* Cookie
* 檔案上傳
* JSON/XML API

以下是與 Rack 相關的變更摘要：

* `script/server` 已經切換為使用 Rack，這意味著它支援任何 Rack 相容的伺服器。`script/server` 也會在存在 rackup 配置檔案時使用它。預設情況下，它會尋找 `config.ru` 檔案，但你可以使用 `-c` 選項覆蓋此設定。
* FCGI 處理程序通過 Rack 進行處理。
* `ActionController::Dispatcher` 維護自己的預設中介軟體堆疊。中介軟體可以注入、重新排序和移除。堆疊在啟動時編譯成鏈條。你可以在 `environment.rb` 中配置中介軟體堆疊。
* 新增了 `rake middleware` 任務以檢查中介軟體堆疊。這對於調試中介軟體堆疊的順序非常有用。
* 整合測試運行器已修改為執行整個中介軟體和應用程式堆疊。這使得整合測試非常適合測試 Rack 中介軟體。
* `ActionController::CGIHandler` 是一個向後相容的 CGI 包裝器，用於 Rack。`CGIHandler` 旨在接收舊的 CGI 物件並將其環境資訊轉換為 Rack 相容形式。
* `CgiRequest` 和 `CgiResponse` 已被移除。
* 會話存儲現在是延遲加載的。如果在請求期間從未訪問過會話物件，它將永遠不會嘗試加載會話數據（解析 cookie、從 memcache 加載數據或查找 Active Record 物件）。
* 在測試中設置 cookie 值時，你不再需要使用 `CGI::Cookie.new`。將 `String` 值分配給 `request.cookies["foo"]` 現在會按預期設置 cookie。
* `CGI::Session::CookieStore` 已被替換為 `ActionController::Session::CookieStore`。
* `CGI::Session::MemCacheStore` 已被替換為 `ActionController::Session::MemCacheStore`。
* `CGI::Session::ActiveRecordStore` 已被替換為 `ActiveRecord::SessionStore`。
* 你仍然可以使用 `ActionController::Base.session_store = :active_record_store` 更改會話存儲。
* 預設會話選項仍然使用 `ActionController::Base.session = { :key => "..." }` 設定。然而，`:session_domain` 選項已更名為 `:domain`。
* 通常包裹整個請求的互斥鎖已經移入中介軟體 `ActionController::Lock`。
* `ActionController::AbstractRequest` 和 `ActionController::Request` 已合併。新的 `ActionController::Request` 繼承自 `Rack::Request`。這會影響對測試請求中的 `response.headers['type']` 的訪問。請改用 `response.content_type`。
* 如果已加載 `ActiveRecord`，`ActiveRecord::QueryCache` 中介軟體會自動插入中介軟體堆疊。此中介軟體設置並刷新每個請求的 Active Record 查詢快取。
* Rails 路由器和控制器類遵循 Rack 規範。你可以使用 `SomeController.call(env)` 直接調用控制器。路由器將路由參數存儲在 `rack.routing_args` 中。
* `ActionController::Request` 繼承自 `Rack::Request`。
* 不再使用 `config.action_controller.session = { :session_key => 'foo', ...`，改用 `config.action_controller.session = { :key => 'foo', ...`。
* 使用 `ParamsParser` 中介軟體預處理任何 XML、JSON 或 YAML 請求，以便在任何 `Rack::Request` 物件之後正常讀取。
### 更新對於Rails引擎的支援

在經過一些版本的升級後，Rails 2.3為Rails引擎（可以嵌入其他應用程序的Rails應用程序）提供了一些新功能。首先，引擎中的路由文件現在會自動加載和重新加載，就像你的`routes.rb`文件一樣（這也適用於其他插件中的路由文件）。其次，如果你的插件有一個app文件夾，那麼app/[models|controllers|helpers]將自動添加到Rails的加載路徑中。引擎現在還支援添加視圖路徑，Action Mailer和Action View將使用引擎和其他插件中的視圖。

文檔
-------------

[Ruby on Rails指南](https://guides.rubyonrails.org/)項目已經為Rails 2.3發布了幾個額外的指南。此外，[另一個網站](https://edgeguides.rubyonrails.org/)維護了Edge Rails指南的更新副本。其他文檔工作包括重新啟動[Rails wiki](http://newwiki.rubyonrails.org/)和早期計劃的Rails書籍。

* 更多信息：[Rails文檔項目](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)

Ruby 1.9.1支援
------------------

Rails 2.3應該能夠通過自己的所有測試，無論你是在運行Ruby 1.8還是現在發布的Ruby 1.9.1。但是，你應該知道，轉移到1.9.1需要檢查所有數據適配器、插件和其他你依賴的代碼是否與Ruby 1.9.1兼容，以及Rails核心。

Active Record
-------------

Rails 2.3中的Active Record獲得了許多新功能和錯誤修復。亮點包括嵌套屬性、嵌套事務、動態和默認作用域以及批處理。

### 嵌套屬性

Active Record現在可以直接更新嵌套模型上的屬性，只要你告訴它這樣做：

```ruby
class Book < ActiveRecord::Base
  has_one :author
  has_many :pages

  accepts_nested_attributes_for :author, :pages
end
```

打開嵌套屬性功能可以實現以下幾點：自動（並且原子性）保存記錄及其關聯的子記錄、支持子記錄驗證以及支持嵌套表單（稍後討論）。

你還可以使用`:reject_if`選項為通過嵌套屬性添加的任何新記錄指定要求：

```ruby
accepts_nested_attributes_for :author,
  :reject_if => proc { |attributes| attributes['name'].blank? }
```

* 主要貢獻者：[Eloy Duran](http://superalloy.nl/)
* 更多信息：[嵌套模型表單](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)

### 嵌套事務

Active Record現在支持嵌套事務，這是一個廣受歡迎的功能。現在你可以這樣編寫代碼：

```ruby
User.transaction do
  User.create(:username => 'Admin')
  User.transaction(:requires_new => true) do
    User.create(:username => 'Regular')
    raise ActiveRecord::Rollback
  end
end

User.find(:all)  # => 只返回Admin
```

嵌套事務允許你在不影響外部事務狀態的情況下回滾內部事務。如果你想要一個事務是嵌套的，你必須明確添加`:requires_new`選項；否則，嵌套事務只是成為父事務的一部分（就像在Rails 2.2上目前的情況一樣）。在內部，嵌套事務使用[保存點](http://rails.lighthouseapp.com/projects/8994/tickets/383)，因此它們甚至在沒有真正嵌套事務的數據庫上也是受支援的。在測試期間，這些事務與事務性固定裝置的相互作用也有一些魔法處理。

* 主要貢獻者：[Jonathan Viney](http://www.workingwithrails.com/person/4985-jonathan-viney) 和 [Hongli Lai](http://izumi.plan99.net/blog/)
### 動態範圍

您已經了解了在Rails中的動態查找器（允許您即時創建像`find_by_color_and_flavor`這樣的方法）和命名範圍（允許您將可重複使用的查詢條件封裝為友好的名稱，例如`currently_active`）。現在，您可以擁有動態範圍方法。這個想法是組合語法，允許即時篩選和方法鏈接。例如：

```ruby
Order.scoped_by_customer_id(12)
Order.scoped_by_customer_id(12).find(:all,
  :conditions => "status = 'open'")
Order.scoped_by_customer_id(12).scoped_by_status("open")
```

使用動態範圍不需要定義：它們只是工作。

* 主要貢獻者：[Yaroslav Markin](http://evilmartians.com/)
* 更多資訊：[Edge Rails的新功能：動態範圍方法](http://archives.ryandaigle.com/articles/2008/12/29/what-s-new-in-edge-rails-dynamic-scope-methods)

### 預設範圍

Rails 2.3將引入與命名範圍類似的_預設範圍_概念，但適用於模型內的所有命名範圍或查詢方法。例如，您可以編寫`default_scope :order => 'name ASC'`，每次從該模型檢索記錄時，它們都會按照名稱排序（除非您覆蓋該選項）。

* 主要貢獻者：Paweł Kondzior
* 更多資訊：[Edge Rails的新功能：預設範圍](http://archives.ryandaigle.com/articles/2008/11/18/what-s-new-in-edge-rails-default-scoping)

### 批次處理

現在，您可以使用`find_in_batches`從Active Record模型中處理大量記錄，並減少對內存的壓力：

```ruby
Customer.find_in_batches(:conditions => {:active => true}) do |customer_group|
  customer_group.each { |customer| customer.update_account_balance! }
end
```

您可以將大多數`find`選項傳遞給`find_in_batches`。但是，您無法指定記錄返回的順序（它們始終按照主鍵的升序返回，主鍵必須是整數），也無法使用`：limit`選項。相反，使用`：batch_size`選項，默認為1000，設置每個批次返回的記錄數。

新的`find_each`方法提供了`find_in_batches`的包裝器，返回單個記錄，查找本身是以批次（默認為1000）進行的：

```ruby
Customer.find_each do |customer|
  customer.update_account_balance!
end
```

請注意，您應該僅將此方法用於批處理：對於少量記錄（少於1000），應該使用常規的查找方法和自己的循環。

* 更多資訊（當時方便的方法只被稱為`each`）：
    * [Rails 2.3：批量查找](http://afreshcup.com/2009/02/23/rails-23-batch-finding/)
    * [Edge Rails的新功能：批量查找](http://archives.ryandaigle.com/articles/2009/2/23/what-s-new-in-edge-rails-batched-find)

### 回調的多個條件

在使用Active Record回調時，您現在可以在同一個回調上結合`：if`和`：unless`選項，並以數組形式提供多個條件：
```ruby
before_save :update_credit_rating, :if => :active,
  :unless => [:admin, :cash_only]
```
* 主要貢獻者：L. Caviola

### 使用 having 查詢

Rails 現在在查詢中（以及 `has_many` 和 `has_and_belongs_to_many` 關聯中）有了 `:having` 選項，用於在分組查詢中過濾記錄。對於具有豐富 SQL 背景的人來說，這允許基於分組結果進行過濾：

```ruby
developers = Developer.find(:all, :group => "salary",
  :having => "sum(salary) > 10000", :select => "salary")
```

* 主要貢獻者：[Emilio Tagua](https://github.com/miloops)

### 重新連接 MySQL 連接

MySQL 支持在連接中設置重新連接標誌 - 如果設置為 true，則在連接丟失的情況下，客戶端將在放棄之前嘗試重新連接到服務器。現在，您可以在 Rails 應用程序的 `database.yml` 中為 MySQL 連接設置 `reconnect = true`，以獲得此行為。默認值為 `false`，因此現有應用程序的行為不會改變。

* 主要貢獻者：[Dov Murik](http://twitter.com/dubek)
* 更多信息：
    * [控制自動重新連接行為](http://dev.mysql.com/doc/refman/5.6/en/auto-reconnect.html)
    * [重新討論 MySQL 自動重新連接](http://groups.google.com/group/rubyonrails-core/browse_thread/thread/49d2a7e9c96cb9f4)

### 其他 Active Record 變更

* 從 `has_and_belongs_to_many` 預加載生成的 SQL 中刪除了多餘的 `AS`，使其在某些數據庫中更好地工作。
* 當遇到現有記錄時，`ActiveRecord::Base#new_record?` 現在返回 `false` 而不是 `nil`。
* 修復了某些 `has_many :through` 關聯中引用表名的錯誤。
* 現在可以為 `updated_at` 時間戳指定特定的時間：`cust = Customer.create(:name => "ABC Industries", :updated_at => 1.day.ago)`
* 在 `find_by_attribute!` 調用失敗時提供更好的錯誤消息。
* 通過添加 `:camelize` 選項，Active Record 的 `to_xml` 支持變得更加靈活。
* 修復了從 `before_update` 或 `before_create` 取消回調的錯誤。
* 添加了通過 JDBC 測試數據庫的 Rake 任務。
* `validates_length_of` 現在將使用 `:in` 或 `:within` 選項（如果提供）的自定義錯誤消息。
* 範圍選擇上的計數現在正常工作，因此您可以執行像 `Account.scoped(:select => "DISTINCT credit_limit").count` 這樣的操作。
* `ActiveRecord::Base#invalid?` 現在與 `ActiveRecord::Base#valid?` 的相反作用。

Action Controller
-----------------

在此版本中，Action Controller 在渲染、路由和其他方面進行了一些重大變更和改進。

### 統一渲染

`ActionController::Base#render` 現在在決定要渲染的內容方面更加智能。現在，您只需告訴它要渲染什麼，並期望得到正確的結果。在較舊的 Rails 版本中，您通常需要提供顯式信息來進行渲染：

```ruby
render :file => '/tmp/random_file.erb'
render :template => 'other_controller/action'
render :action => 'show'
```
現在在Rails 2.3中，您只需提供要渲染的內容：

```ruby
render '/tmp/random_file.erb'
render 'other_controller/action'
render 'show'
render :show
```

Rails根據要渲染的內容是否有前斜線、嵌入斜線或根本沒有斜線來選擇文件、模板或動作。請注意，當渲染動作時，您還可以使用符號而不是字符串。其他渲染樣式（`:inline`、`:text`、`:update`、`:nothing`、`:json`、`:xml`、`:js`）仍需要明確的選項。

### 應用程式控制器更名

如果您是一直對`application.rb`的特殊命名感到困擾的人，那麼請高興一下！在Rails 2.3中，它已經重新命名為`application_controller.rb`。此外，還有一個新的rake任務`rake rails:update:application_controller`可以自動為您執行此操作-並且它將作為正常的`rake rails:update`過程的一部分運行。

* 更多資訊：
    * [The Death of Application.rb](https://afreshcup.com/home/2008/11/17/rails-2x-the-death-of-applicationrb)
    * [What's New in Edge Rails: Application.rb Duality is no More](http://archives.ryandaigle.com/articles/2008/11/19/what-s-new-in-edge-rails-application-rb-duality-is-no-more)

### HTTP摘要驗證支援

Rails現在內建支援HTTP摘要驗證。要使用它，您可以調用`authenticate_or_request_with_http_digest`，並傳入一個返回用戶密碼的區塊（然後將其哈希化並與傳輸的憑據進行比較）：

```ruby
class PostsController < ApplicationController
  Users = {"dhh" => "secret"}
  before_filter :authenticate

  def secret
    render :text => "Password Required!"
  end

  private
  def authenticate
    realm = "Application"
    authenticate_or_request_with_http_digest(realm) do |name|
      Users[name]
    end
  end
end
```

* 主要貢獻者：[Gregg Kellogg](http://www.kellogg-assoc.com/)
* 更多資訊：[What's New in Edge Rails: HTTP Digest Authentication](http://archives.ryandaigle.com/articles/2009/1/30/what-s-new-in-edge-rails-http-digest-authentication)

### 更高效的路由

Rails 2.3中有幾個重要的路由變更。`formatted_`路由輔助方法已經被刪除，而是直接將`:format`作為選項傳入。這對於任何資源來說，可以將路由生成過程減少50％，並且可以節省大量內存（對於大型應用程序可達100MB）。如果您的代碼使用了`formatted_`輔助方法，它目前仍然可以工作-但該行為已被棄用，如果您使用新的標準重寫這些路由，您的應用程序將更高效。另一個重大變化是，Rails現在支援多個路由文件，不僅僅是`routes.rb`。您可以使用`RouteSet#add_configuration_file`隨時引入更多路由-而無需清除當前加載的路由。雖然此變更最有用於引擎，但您可以在任何需要批次加載路由的應用程序中使用它。

* 主要貢獻者：[Aaron Batalion](http://blog.hungrymachine.com/)
### 基於Rack的懶加載會話

一個重大的改變將Action Controller會話存儲的基礎下移到了Rack級別。這需要在代碼中進行大量的工作，但對於你的Rails應用程序來說應該是完全透明的（作為一個額外的好處，一些關於舊的CGI會話處理程序的麻煩補丁被刪除了）。然而，這仍然是一個重要的改變，因為非Rails Rack應用程序可以訪問與你的Rails應用程序相同的會話存儲處理程序（因此也可以訪問相同的會話）。此外，會話現在是懶加載的（與框架的其他加載改進一致）。這意味著如果你不想使用會話，你不再需要明確地禁用它們；只需不引用它們，它們就不會加載。

### MIME類型處理的更改

在Rails中處理MIME類型的代碼有一些變化。首先，`MIME::Type`現在實現了`=~`運算符，這使得在需要檢查是否存在具有同義詞的類型時更加清晰：

```ruby
if content_type && Mime::JS =~ content_type
  # 做一些很酷的事情
end

Mime::JS =~ "text/javascript"        => true
Mime::JS =~ "application/javascript" => true
```

另一個變化是，框架現在在各個地方檢查JavaScript時使用`Mime::JS`，使其能夠清晰地處理這些替代選項。

* 主要貢獻者：[Seth Fitzsimmons](http://www.workingwithrails.com/person/5510-seth-fitzsimmons)

### `respond_to`的優化

在Rails-Merb團隊合併的一些首批成果中，Rails 2.3包括了一些針對`respond_to`方法的優化。`respond_to`方法在許多Rails應用程序中被廣泛使用，用於根據請求的MIME類型以不同的格式呈現結果。通過消除對`method_missing`的調用以及一些性能分析和調整，我們看到使用一個在三種格式之間切換的簡單`respond_to`的每秒請求數提高了8％。最好的部分是，你的應用程序的代碼完全不需要任何更改就可以利用這個加速。

### 改進的緩存性能

Rails現在在每個請求中保留了一個本地緩存，從遠程緩存存儲中讀取，減少了不必要的讀取，提高了網站的性能。雖然這項工作最初僅限於`MemCacheStore`，但它對於任何實現所需方法的遠程存儲都是可用的。

* 主要貢獻者：[Nahum Wild](http://www.motionstandingstill.com/)

### 本地化視圖

Rails現在可以根據你設置的語言環境提供本地化視圖。例如，假設你有一個`Posts`控制器，其中包含一個`show`動作。默認情況下，它將渲染`app/views/posts/show.html.erb`。但是，如果你設置了`I18n.locale = :da`，它將渲染`app/views/posts/show.da.html.erb`。如果本地化模板不存在，將使用未修飾的版本。Rails還包括`I18n#available_locales`和`I18n::SimpleBackend#available_locales`，它們返回當前Rails項目中可用的翻譯數組。
此外，您可以使用相同的方案在公共目錄中本地化救援文件：例如`public/500.da.html`或`public/404.en.html`。

### 部分範圍的翻譯

對翻譯 API 的更改使得在局部中編寫關鍵翻譯更加簡單和不重複。如果您在`people/index.html.erb`模板中調用`translate(".foo")`，實際上您將調用`I18n.translate("people.index.foo")`。如果您不在關鍵字前加上句點，則 API 不會進行範圍限定，就像以前一樣。

### 其他 Action Controller 的更改

* ETag 的處理已經進行了一些清理：當回應沒有主體或使用`send_file`發送文件時，Rails 現在會跳過發送 ETag 標頭。
* Rails 檢查 IP 欺騙的事實對於與手機進行大量流量的網站可能會造成困擾，因為它們的代理通常無法正確設置。如果您是這樣的情況，您現在可以設置`ActionController::Base.ip_spoofing_check = false`來完全禁用檢查。
* `ActionController::Dispatcher`現在實現了自己的中間件堆棧，您可以通過運行`rake middleware`來查看。
* Cookie 會話現在具有持久會話標識符，與服務器端存儲兼容的 API。
* 現在可以在`send_file`和`send_data`的`:type`選項中使用符號，例如：`send_file("fabulous.png", :type => :png)`。
* `map.resources`的`:only`和`:except`選項不再被嵌套資源繼承。
* 捆綁的 memcached 客戶端已更新到版本1.6.4.99。
* `expires_in`、`stale?`和`fresh_when`方法現在接受`:public`選項，以便與代理緩存良好配合使用。
* `:requirements`選項現在與其他 RESTful 成員路由正常工作。
* 淺層路由現在正確地尊重命名空間。
* `polymorphic_url`在處理具有不規則複數名稱的對象時更加出色。

Action View
-----------

Rails 2.3 中的 Action View 支持嵌套模型表單、改進的`render`、更靈活的日期選擇助手提示以及資產緩存加速等功能。

### 嵌套對象表單

如果父模型接受子對象的嵌套屬性（如在 Active Record 部分中討論的那樣），您可以使用`form_for`和`field_for`創建嵌套表單。這些表單可以任意嵌套，允許您在單個視圖上編輯複雜的對象層次結構而不需要過多的代碼。例如，給定以下模型：

```ruby
class Customer < ActiveRecord::Base
  has_many :orders

  accepts_nested_attributes_for :orders, :allow_destroy => true
end
```

您可以在 Rails 2.3 中編寫以下視圖：

```html+erb
<% form_for @customer do |customer_form| %>
  <div>
    <%= customer_form.label :name, 'Customer Name:' %>
    <%= customer_form.text_field :name %>
  </div>

  <!-- 在 customer_form builder 實例上調用 fields_for。
   每個 orders 集合成員都會調用該塊。 -->
  <% customer_form.fields_for :orders do |order_form| %>
    <p>
      <div>
        <%= order_form.label :number, 'Order Number:' %>
        <%= order_form.text_field :number %>
      </div>

  <!-- 模型中的 allow_destroy 選項允許刪除子記錄。 -->
      <% unless order_form.object.new_record? %>
        <div>
          <%= order_form.label :_delete, 'Remove:' %>
          <%= order_form.check_box :_delete %>
        </div>
      <% end %>
    </p>
  <% end %>

  <%= customer_form.submit %>
<% end %>
```
* 主要貢獻者：[Eloy Duran](http://superalloy.nl/)
* 更多資訊：
    * [巢狀模型表單](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)
    * [complex-form-examples](https://github.com/alloy/complex-form-examples)
    * [Edge Rails 的新功能：巢狀物件表單](http://archives.ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes)

### 部分樣板的智慧渲染

render 方法在過去幾年中變得越來越聰明，現在更聰明了。如果你有一個物件或集合以及一個適當的部分樣板，並且命名相符，你現在可以直接渲染該物件，一切都會正常運作。例如，在 Rails 2.3 中，以下的 render 呼叫將在你的視圖中運作（假設命名合理）：

```ruby
# 等同於 render :partial => 'articles/_article',
# :object => @article
render @article

# 等同於 render :partial => 'articles/_article',
# :collection => @articles
render @articles
```

* 更多資訊：[Edge Rails 的新功能：render 不再需要維護](http://archives.ryandaigle.com/articles/2008/11/20/what-s-new-in-edge-rails-render-stops-being-high-maintenance)

### 日期選擇輔助程式的提示

在 Rails 2.3 中，你可以為各種日期選擇輔助程式（`date_select`、`time_select` 和 `datetime_select`）提供自訂的提示，就像你可以為集合選擇輔助程式提供一樣。你可以提供一個提示字串或一個包含各個元件提示字串的雜湊。你也可以將 `:prompt` 設為 `true` 以使用自訂的通用提示：

```ruby
select_datetime(DateTime.now, :prompt => true)

select_datetime(DateTime.now, :prompt => "選擇日期和時間")

select_datetime(DateTime.now, :prompt =>
  {:day => '選擇日期', :month => '選擇月份',
   :year => '選擇年份', :hour => '選擇小時',
   :minute => '選擇分鐘'})
```

* 主要貢獻者：[Sam Oliver](http://samoliver.com/)

### 資源標籤的時間戳快取

你可能熟悉 Rails 在靜態資源路徑中添加時間戳作為「快取破壞器」的做法。這有助於確保當你在伺服器上更改這些資源時，不會從使用者的瀏覽器快取中提供過期的圖像和樣式表。現在，你可以通過 Action View 的 `cache_asset_timestamps` 配置選項修改此行為。如果啟用快取，則 Rails 將在首次提供資源時計算時間戳並保存該值。這意味著提供靜態資源時會減少（昂貴的）檔案系統呼叫，但也意味著在伺服器運行時無法修改任何資源並期望客戶端能夠接收到更改。

### 資源主機作為物件

在 Edge Rails 中，資源主機變得更加靈活，可以將資源主機聲明為一個特定的物件，該物件會回應一個呼叫。這使你能夠在資源主機中實現任何複雜的邏輯。

* 更多資訊：[具有最小 SSL 的資源主機](https://github.com/dhh/asset-hosting-with-minimum-ssl/tree/master)
### grouped_options_for_select 輔助方法

Action View 已經有很多輔助方法來生成選擇控制項，現在又多了一個：`grouped_options_for_select`。這個方法接受一個字串的陣列或哈希，並將它們轉換為一個包含 `optgroup` 標籤的 `option` 標籤的字串。例如：

```ruby
grouped_options_for_select([["帽子", ["棒球帽","牛仔帽"]]],
  "牛仔帽", "請選擇一個產品...")
```

返回：

```html
<option value="">請選擇一個產品...</option>
<optgroup label="帽子">
  <option value="棒球帽">棒球帽</option>
  <option selected="selected" value="牛仔帽">牛仔帽</option>
</optgroup>
```

### 表單選擇輔助方法的禁用選項標籤

表單選擇輔助方法（例如 `select` 和 `options_for_select`）現在支持 `:disabled` 選項，可以接受一個值或一個值的陣列，在生成的標籤中禁用這些值：

```ruby
select(:post, :category, Post::CATEGORIES, :disabled => 'private')
```

返回：

```html
<select name="post[category]">
<option>story</option>
<option>joke</option>
<option>poem</option>
<option disabled="disabled">private</option>
</select>
```

您還可以使用匿名函數來在運行時確定哪些來自集合的選項將被選擇和/或禁用：

```ruby
options_from_collection_for_select(@product.sizes, :name, :id, :disabled => lambda{|size| size.out_of_stock?})
```

* 主要貢獻者：[Tekin Suleyman](http://tekin.co.uk/)
* 更多資訊：[Rails 2.3 中的新功能 - 禁用選項標籤和使用匿名函數從集合中選擇和禁用選項](https://tekin.co.uk/2009/03/new-in-rails-23-disabled-option-tags-and-lambdas-for-selecting-and-disabling-options-from-collections)

### 關於模板加載的注意事項

Rails 2.3 包含了在任何特定環境中啟用或禁用緩存模板的功能。緩存模板可以提高速度，因為它們在渲染時不會檢查新的模板文件，但這也意味著您無法在不重新啟動服務器的情況下即時替換模板。

在大多數情況下，您希望在生產環境中開啟模板緩存，您可以在 `production.rb` 文件中進行設置：

```ruby
config.action_view.cache_template_loading = true
```

這行代碼在新的 Rails 2.3 應用程序中默認生成。如果您從較舊的版本升級，Rails 將默認在生產和測試中緩存模板，但在開發中不緩存。

### 其他 Action View 更改

* CSRF 保護的令牌生成已經簡化；現在 Rails 使用由 `ActiveSupport::SecureRandom` 生成的簡單隨機字串，而不是處理會話 ID。
* `auto_link` 現在正確地應用選項（例如 `:target` 和 `:class`）到生成的電子郵件鏈接。
* `autolink` 輔助方法已經重構，使其更加清晰和直觀。
* 即使 URL 中有多個查詢參數，`current_page?` 現在也能正確工作。

Active Support
--------------

Active Support 有一些有趣的更改，包括引入了 `Object#try` 方法。
### Object#try

很多人已經開始使用try()這個方法來嘗試對象進行操作。在視圖中，你可以通過寫代碼`<%= @person.try(:name) %>`來避免nil檢查。現在，這個方法已經內置在Rails中。在Rails中的實現中，如果對象為nil，則返回nil；如果對象的方法是私有的，則會引發NoMethodError異常。

* 更多信息：[try()](http://ozmm.org/posts/try.html)

### Object#tap Backport

`Object#tap`是Ruby 1.9和1.8.7的一個新增方法，類似於Rails已經有一段時間的`returning`方法：它會將對象傳遞給一個塊，然後返回傳遞的對象。現在，Rails已經包含了在舊版本的Ruby中使用這個方法的代碼。

### 可替換的XMLmini解析器

Active Support中對XML解析的支持變得更加靈活，允許您替換不同的解析器。默認情況下，它使用標準的REXML實現，但是您可以輕鬆地為自己的應用程序指定更快的LibXML或Nokogiri實現，前提是您已經安裝了相應的gem：

```ruby
XmlMini.backend = 'LibXML'
```

* 主要貢獻者：[Bart ten Brinke](http://www.movesonrails.com/)
* 主要貢獻者：[Aaron Patterson](http://tenderlovemaking.com/)

### TimeWithZone的小數秒

`Time`和`TimeWithZone`類包含一個`xmlschema`方法，用於以XML友好的字符串形式返回時間。從Rails 2.3開始，`TimeWithZone`支持與`Time`相同的參數，用於指定返回字符串的小數秒部分的位數：

```ruby
Time.zone.now.xmlschema(6) # => "2009-01-16T13:00:06.13653Z"
```

* 主要貢獻者：[Nicholas Dainty](http://www.workingwithrails.com/person/13536-nicholas-dainty)

### JSON鍵的引用

如果您查看“json.org”網站上的規範，您會發現JSON結構中的所有鍵都必須是字符串，並且必須用雙引號引起來。從Rails 2.3開始，我們在這方面做得很好，即使是數字鍵也是如此。

### 其他Active Support的變更

* 您可以使用`Enumerable#none?`來檢查沒有元素與提供的塊匹配。
* 如果您使用Active Support的[委託](https://afreshcup.com/home/2008/10/19/coming-in-rails-22-delegate-prefixes)，新的`:allow_nil`選項允許您在目標對象為nil時返回nil，而不是引發異常。
* `ActiveSupport::OrderedHash`：現在實現了`each_key`和`each_value`方法。
* `ActiveSupport::MessageEncryptor`提供了一種簡單的方法來將信息加密存儲在不受信任的位置（例如cookies）。
* Active Support的`from_xml`不再依賴於XmlSimple。相反，Rails現在包含了自己的XmlMini實現，僅包含所需的功能。這使得Rails可以放棄一直攜帶的XmlSimple的捆綁副本。
* 如果您對一個私有方法進行了記憶化，結果將保持私有。
* `String#parameterize`方法接受一個可選的分隔符：`"Quick Brown Fox".parameterize('_') => "quick_brown_fox"`。
* `number_to_phone`現在可以接受7位數的電話號碼。
* `ActiveSupport::Json.decode`現在可以處理`\u0000`風格的轉義序列。
Railties
--------

除了上面提到的Rack更改之外，Railties（Rails本身的核心代碼）還有一些重大的更改，包括Rails Metal、應用程序模板和安靜的回溯。

### Rails Metal

Rails Metal是一種在Rails應用程序內部提供超快速端點的新機制。Metal類繞過路由和Action Controller，以提供原始速度（當然也會帶來Action Controller中的所有功能的成本）。這是在最近的基礎工作的基礎上構建的，使Rails成為一個具有公開中間件堆棧的Rack應用程序。Metal端點可以從應用程序或插件中加載。

* 更多信息：
    * [介紹Rails Metal](https://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal)
    * [Rails Metal：具有Rails功能的微框架](http://soylentfoo.jnewland.com/articles/2008/12/16/rails-metal-a-micro-framework-with-the-power-of-rails-m)
    * [Metal：在Rails應用程序內部提供超快速端點](http://www.railsinside.com/deployment/180-metal-super-fast-endpoints-within-your-rails-apps.html)
    * [Edge Rails的新功能：Rails Metal](http://archives.ryandaigle.com/articles/2008/12/18/what-s-new-in-edge-rails-rails-metal)

### 應用程序模板

Rails 2.3包含了Jeremy McAnally的[rg](https://github.com/jm/rg)應用程序生成器。這意味著我們現在在Rails中內建了基於模板的應用程序生成；如果您在每個應用程序中都包含一組插件（以及其他許多用例），您只需設置一次模板，然後在運行`rails`命令時可以一遍又一遍地使用它。還有一個rake任務可以將模板應用於現有應用程序：

```bash
$ rake rails:template LOCATION=~/template.rb
```

這將在現有代碼的基礎上添加模板的更改。

* 主要貢獻者：[Jeremy McAnally](http://www.jeremymcanally.com/)
* 更多信息：[Rails模板](http://m.onkey.org/2008/12/4/rails-templates)

### 更安靜的回溯

在thoughtbot的[Quiet Backtrace](https://github.com/thoughtbot/quietbacktrace)插件的基礎上，該插件允許您有選擇性地從`Test::Unit`回溯中刪除行，Rails 2.3在核心中實現了`ActiveSupport::BacktraceCleaner`和`Rails::BacktraceCleaner`。這支持過濾器（對回溯行執行基於正則表達式的替換）和靜音器（完全刪除回溯行）。Rails自動添加靜音器以消除新應用程序中最常見的噪音，並建立一個`config/backtrace_silencers.rb`文件以保存您自己的添加。此功能還可以從回溯中的任何gem中進行更漂亮的打印。

### 在開發模式下使用延遲加載/自動加載加快啟動時間

為了確保只在實際需要時將Rails（及其依賴項）的部分加載到內存中，進行了相當多的工作。核心框架 - Active Support、Active Record、Action Controller、Action Mailer和Action View - 現在使用`autoload`來延遲加載它們的各個類。這項工作應該有助於保持內存佔用量並改善整體的Rails性能。
您還可以通過使用新的 `preload_frameworks` 選項來指定核心庫是否應在啟動時自動加載。默認情況下，這個選項為 `false`，這樣Rails會逐個加載自己，但在某些情況下，您仍然需要一次性加載所有內容 - Passenger和JRuby都希望一次性加載所有的Rails。

### rake gem 任務重寫

各種 <code>rake gem</code> 任務的內部結構已經大幅修改，以使系統在各種情況下更好地工作。現在的gem系統知道開發和運行時依賴的區別，具有更強大的解壓系統，在查詢gems狀態時提供更好的信息，並且在從頭開始時不容易出現“雞和蛋”依賴問題。還修復了在JRuby下使用gem命令和嘗試引入已經被供應的gems的外部副本的依賴問題。

* 主要貢獻者：[David Dollar](http://www.workingwithrails.com/person/12240-david-dollar)

### 其他Railties變更

* 更新並擴展了將CI服務器更新為構建Rails的說明。
* 內部的Rails測試已從`Test::Unit::TestCase`切換到`ActiveSupport::TestCase`，Rails核心需要Mocha進行測試。
* 默認的`environment.rb`文件已經簡化。
* dbconsole腳本現在可以使用全數字密碼而不會崩潰。
* `Rails.root`現在返回一個`Pathname`對象，這意味著您可以直接使用`join`方法來[整理現有代碼](https://afreshcup.wordpress.com/2008/12/05/a-little-rails_root-tidiness/)中使用的`File.join`。
* 默認情況下，不再在每個Rails應用程序中生成處理CGI和FCGI調度的/public文件（如果需要，仍然可以通過在運行`rails`命令時添加`--with-dispatchers`，或者使用`rake rails:update:generate_dispatchers`稍後添加）。
* Rails指南已從AsciiDoc轉換為Textile標記。
* Scaffolded的視圖和控制器進行了一些清理。
* `script/server`現在接受`--path`參數，以從特定路徑掛載Rails應用程序。
* 如果缺少任何配置的gems，gem rake任務將跳過加載環境的大部分。這應該解決許多“雞和蛋”問題，因為rake gems:install無法運行，因為缺少gems。
* Gems現在只解壓縮一次。這修復了gems（例如hoe）的問題，這些gems在文件上具有只讀權限。

已棄用
----------

在此版本中，一些較舊的代碼已被棄用：
* 如果你是一位（相對較少見的）使用檢查器（inspector）、重啟器（reaper）和生成器（spawner）腳本進行部署的Rails開發人員，你需要知道這些腳本不再包含在核心Rails中。如果你需要它們，你可以通過[irs_process_scripts](https://github.com/rails/irs_process_scripts)插件獲取拷貝。
* `render_component`在Rails 2.3中從「已棄用」變為「不存在」。如果你仍然需要它，你可以安裝[render_component插件](https://github.com/rails/render_component/tree/master)。
* 支援Rails組件的功能已被移除。
* 如果你是那些習慣運行`script/performance/request`來查看基於集成測試的性能的人之一，你需要學習一個新技巧：該腳本現在已從核心Rails中刪除。現在有一個新的request_profiler插件，你可以安裝它以獲取完全相同的功能。
* `ActionController::Base#session_enabled?`已被棄用，因為現在會延遲加載會話。
* `protect_from_forgery`的`：digest`和`：secret`選項已被棄用並且不起作用。
* 一些集成測試輔助工具已被移除。`response.headers["Status"]`和`headers["Status"]`將不再返回任何內容。Rack不允許在返回標頭中使用「Status」。但是，你仍然可以使用`status`和`status_message`輔助工具。`response.headers["cookie"]`和`headers["cookie"]`將不再返回任何CGI cookie。你可以檢查`headers["Set-Cookie"]`以查看原始cookie標頭，或使用`cookies`輔助工具獲取發送到客戶端的cookie的哈希。
* `formatted_polymorphic_url`已被棄用。請改用帶有`:format`的`polymorphic_url`。
* `ActionController::Response#set_cookie`中的`：http_only`選項已更名為`：httponly`。
* `to_sentence`的`：connector`和`：skip_last_comma`選項已被`：words_connector`、`：two_words_connector`和`：last_word_connector`選項取代。
* 提交一個帶有空的`file_field`控件的多部分表單以前會將一個空字符串提交給控制器。現在，由於Rack的多部分解析器和舊的Rails解析器之間的差異，它會提交一個nil。

致謝
-------

發行說明由[Mike Gunderloy](http://afreshcup.com)編寫。這個版本的Rails 2.3發行說明是基於Rails 2.3的RC2編譯的。
