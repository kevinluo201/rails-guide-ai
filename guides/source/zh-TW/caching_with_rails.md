**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bef23603f5d822054701f5cbf2578d95
Rails中的緩存：概述
=================

本指南是關於使用緩存來加速Rails應用程序的介紹。

緩存意味著在請求-響應週期中存儲生成的內容，並在響應類似請求時重用它。

緩存通常是提高應用程序性能的最有效方法。通過緩存，運行在單個服務器上並使用單個數據庫的網站可以承受數千個並發用戶的負載。

Rails提供了一套開箱即用的緩存功能。本指南將教你每個功能的範圍和目的。掌握這些技術，你的Rails應用程序可以在不需要過高的響應時間或服務器費用的情況下提供數百萬次的查看。

閱讀完本指南後，你將了解：

* 片段緩存和俄羅斯套娃緩存。
* 如何管理緩存依賴關係。
* 替代緩存存儲。
* 條件GET支持。

--------------------------------------------------------------------------------

基本緩存
-------------

這是三種緩存技術（頁面、操作和片段緩存）的介紹。默認情況下，Rails提供片段緩存。要使用頁面和操作緩存，你需要在`Gemfile`中添加`actionpack-page_caching`和`actionpack-action_caching`。

默認情況下，只有在生產環境中啟用緩存。你可以通過運行`rails dev:cache`或在`config/environments/development.rb`中將[`config.action_controller.perform_caching`][]設置為`true`來在本地測試緩存。

注意：更改`config.action_controller.perform_caching`的值只會影響Action Controller提供的緩存。例如，它不會影響我們在下面提到的低級緩存。

### 頁面緩存

頁面緩存是一種Rails機制，它允許由Web服務器（如Apache或NGINX）滿足對生成的頁面的請求，而無需經過整個Rails堆棧。儘管這非常快速，但不能應用於每種情況（例如需要身份驗證的頁面）。此外，由於Web服務器直接從文件系統提供文件，所以你需要實現緩存過期。

信息：頁面緩存已從Rails 4中刪除。請參閱[actionpack-page_caching gem](https://github.com/rails/actionpack-page_caching)。

### 操作緩存

無法對具有前置過濾器的操作使用頁面緩存，例如需要身份驗證的頁面。這就是操作緩存的用途。操作緩存的工作方式與頁面緩存相似，只是傳入的Web請求會命中Rails堆棧，以便在緩存提供之前可以對其運行前置過濾器。這允許在仍然提供緩存副本的輸出結果時運行身份驗證和其他限制。

信息：操作緩存已從Rails 4中刪除。請參閱[actionpack-action_caching gem](https://github.com/rails/actionpack-action_caching)。請參閱[DHH的基於鍵的緩存過期概述](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)以了解新的首選方法。

### 片段緩存

動態Web應用程序通常使用各種組件構建頁面，這些組件的緩存特性並不相同。當需要獨立緩存和過期不同部分的頁面時，可以使用片段緩存。

片段緩存允許將視圖邏輯的片段包裝在緩存區塊中，在下一個請求進來時從緩存存儲中提供。

例如，如果你想要對頁面上的每個產品進行緩存，你可以使用以下代碼：

```html+erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

當你的應用程序收到對此頁面的第一個請求時，Rails將使用一個唯一的鍵寫入新的緩存條目。鍵看起來像這樣：

```
views/products/index:bea67108094918eeba42cd4a6e786901/products/1
```

中間的字符串是模板樹摘要。它是根據你正在緩存的視圖片段的內容計算的哈希摘要。如果你更改視圖片段（例如，HTML更改），摘要將更改，從而使現有文件過期。

緩存條目中存儲了從產品記錄派生的緩存版本。當產品被觸摸時，緩存版本會更改，並且將忽略包含先前版本的任何緩存片段。

提示：像Memcached這樣的緩存存儲將自動刪除舊的緩存文件。

如果你想在特定條件下緩存片段，你可以使用`cache_if`或`cache_unless`：

```erb
<% cache_if admin?, product do %>
  <%= render product %>
<% end %>
```

#### 集合緩存

`render`助手還可以緩存為集合渲染的個別模板。它甚至可以通過在渲染集合時傳遞`cached: true`一次性讀取所有緩存模板，而不是逐個讀取。
```html+erb
<%= render partial: 'products/product', collection: @products, cached: true %>
```

所有之前渲染的快取模板將一次性地被提取，速度更快。此外，尚未被快取的模板將被寫入快取並在下一次渲染時一起提取。

### 俄羅斯套娃快取

您可能希望將快取片段嵌套在其他快取片段中。這稱為俄羅斯套娃快取。

俄羅斯套娃快取的優點是，如果單個產品被更新，重新生成外部片段時可以重複使用所有其他內部片段。

如前一節所述，如果快取文件直接依賴的記錄的`updated_at`值發生變化，則快取文件將過期。但是，這不會使嵌套在其中的任何快取片段過期。

例如，考慮以下視圖：

```erb
<% cache product do %>
  <%= render product.games %>
<% end %>
```

這將再次渲染以下視圖：

```erb
<% cache game do %>
  <%= render game %>
<% end %>
```

如果更改了game的任何屬性，`updated_at`值將設置為當前時間，從而使快取過期。但是，由於產品對象的`updated_at`不會更改，因此該快取不會過期，您的應用程序將提供陳舊的數據。為了解決這個問題，我們使用`touch`方法將模型關聯在一起：

```ruby
class Product < ApplicationRecord
  has_many :games
end

class Game < ApplicationRecord
  belongs_to :product, touch: true
end
```

將`touch`設置為`true`，任何更改遊戲記錄的`updated_at`的操作也會更改相關聯的產品的`updated_at`，從而使快取過期。

### 共享部分快取

可以在具有不同MIME類型的文件之間共享部分和相關的快取。例如，共享部分快取允許模板編寫者在HTML和JavaScript文件之間共享部分。當模板被收集到模板解析器文件路徑中時，它們只包括模板語言擴展名，而不包括MIME類型。因此，模板可以用於多個MIME類型。HTML和JavaScript請求都將響應以下代碼：

```ruby
render(partial: 'hotels/hotel', collection: @hotels, cached: true)
```

將加載名為`hotels/hotel.erb`的文件。

另一個選項是包含要渲染的部分的完整文件名。

```ruby
render(partial: 'hotels/hotel.html.erb', collection: @hotels, cached: true)
```

將在任何文件MIME類型中加載名為`hotels/hotel.html.erb`的文件，例如您可以在JavaScript文件中包含此部分。

### 管理依賴關係

為了正確地使快取失效，您需要正確地定義快取依賴關係。Rails足夠聰明，可以處理常見情況，因此您不需要指定任何內容。但是，有時候，例如當您處理自定義幫助程序時，您需要明確定義它們。

#### 隱式依賴關係

大多數模板依賴關係可以從模板本身中的`render`調用中推斷出來。以下是`ActionView::Digestor`知道如何解碼的一些示例：

```ruby
render partial: "comments/comment", collection: commentable.comments
render "comments/comments"
render 'comments/comments'
render('comments/comments')

render "header" 轉換為 render("comments/header")

render(@topic)         轉換為 render("topics/topic")
render(topics)         轉換為 render("topics/topic")
render(message.topics) 轉換為 render("topics/topic")
```

另一方面，有些調用需要更改以使快取正常工作。例如，如果您傳遞了自定義集合，您需要更改：

```ruby
render @project.documents.where(published: true)
```

為：

```ruby
render partial: "documents/document", collection: @project.documents.where(published: true)
```

#### 明確依賴關係

有時您可能有無法推斷的模板依賴關係。這通常是在幫助程序中進行渲染時的情況。以下是一個示例：

```html+erb
<%= render_sortable_todolists @project.todolists %>
```

您需要使用特殊的註釋格式來調用它們：

```html+erb
<%# Template Dependency: todolists/todolist %>
<%= render_sortable_todolists @project.todolists %>
```

在某些情況下，例如單表繼承設置，您可能有一堆明確的依賴關係。您可以使用通配符來匹配目錄中的任何模板，而不是將每個模板都寫出來：

```html+erb
<%# Template Dependency: events/* %>
<%= render_categorizable_events @person.events %>
```

對於集合快取，如果部分模板不以乾淨的快取調用開頭，您仍然可以通過在模板中的任何位置添加特殊的註釋格式來受益於集合快取，例如：

```html+erb
<%# Template Collection: notification %>
<% my_helper_that_calls_cache(some_arg, notification) do %>
  <%= notification.name %>
<% end %>
```
#### 外部依賴

如果您在快取區塊內使用輔助方法，然後更新該輔助方法，您必須同時更新快取。您可以以任何方式進行更新，但模板檔案的 MD5 必須更改。建議的方法是在註解中明確指出，例如：

```html+erb
<%# Helper Dependency Updated: Jul 28, 2015 at 7pm %>
<%= some_helper_method(person) %>
```

### 低階快取

有時候，您需要快取特定的值或查詢結果，而不是快取視圖片段。Rails 的快取機制非常適合存儲任何可序列化的資訊。

實現低階快取的最有效方法是使用 `Rails.cache.fetch` 方法。此方法同時進行讀取和寫入快取。當只傳遞單個參數時，會擷取鍵並返回快取中的值。如果傳遞了一個區塊，則在快取未命中時將執行該區塊。區塊的返回值將被寫入快取中的指定快取鍵下，並返回該返回值。如果快取命中，則將返回快取的值，而不執行該區塊。

考慮以下示例。應用程序具有 `Product` 模型，該模型具有一個實例方法，該方法在競爭網站上查找產品的價格。此方法返回的數據非常適合低階快取：

```ruby
class Product < ApplicationRecord
  def competing_price
    Rails.cache.fetch("#{cache_key_with_version}/competing_price", expires_in: 12.hours) do
      Competitor::API.find_price(id)
    end
  end
end
```

注意：請注意，在此示例中，我們使用了 `cache_key_with_version` 方法，因此生成的快取鍵將類似於 `products/233-20140225082222765838000/competing_price`。`cache_key_with_version` 基於模型的類名、`id` 和 `updated_at` 屬性生成一個字符串。這是一個常見的慣例，並且具有在產品更新時使快取失效的好處。通常情況下，當您使用低階快取時，需要生成一個快取鍵。

#### 避免快取 Active Record 物件的實例

考慮以下示例，該示例將代表超級使用者的 Active Record 物件列表存儲在快取中：

```ruby
# super_admins 是一個昂貴的 SQL 查詢，所以不要頻繁運行它
Rails.cache.fetch("super_admin_users", expires_in: 12.hours) do
  User.super_admins.to_a
end
```

您應該__避免__這種模式。為什麼？因為實例可能會更改。在生產環境中，其屬性可能不同，或者記錄可能已被刪除。在開發環境中，它與在進行更改時重新加載代碼的快取存儲不可靠。

相反，快取 ID 或其他原始數據類型。例如：

```ruby
# super_admins 是一個昂貴的 SQL 查詢，所以不要頻繁運行它
ids = Rails.cache.fetch("super_admin_user_ids", expires_in: 12.hours) do
  User.super_admins.pluck(:id)
end
User.where(id: ids).to_a
```

### SQL 快取

查詢快取是 Rails 的一個功能，它快取每個查詢返回的結果集。如果對於該請求，Rails 再次遇到相同的查詢，它將使用快取的結果集而不是再次運行該查詢。

例如：

```ruby
class ProductsController < ApplicationController
  def index
    # 執行查詢
    @products = Product.all

    # ...

    # 再次執行相同的查詢
    @products = Product.all
  end
end
```

第二次對數據庫運行相同的查詢時，實際上不會再次訪問數據庫。第一次從查詢返回結果時，它會存儲在查詢快取（在內存中），第二次從內存中提取。

然而，重要的是要注意，查詢快取是在操作開始時創建的，在操作結束時銷毀的，因此只在操作的持續時間內存在。如果您希望以更持久的方式存儲查詢結果，可以使用低階快取。

快取存儲
------------

Rails 提供了不同的存儲方式來存儲快取數據（除了 SQL 和頁面快取）。

### 配置

您可以通過設置 `config.cache_store` 配置選項來設置應用程序的默認快取存儲。其他參數可以作為快取存儲的構造函數的參數傳遞：

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

或者，您可以在配置塊之外設置 `ActionController::Base.cache_store`。

您可以通過調用 `Rails.cache` 來訪問快取。

#### 連接池選項

默認情況下，[`:mem_cache_store`](#activesupport-cache-memcachestore) 和 [`:redis_cache_store`](#activesupport-cache-rediscachestore) 配置為使用連接池。這意味著如果您使用 Puma 或其他多線程服務器，您可以同時有多個線程對快取存儲執行查詢。
如果您想禁用連接池，請在配置緩存存儲時將`:pool`選項設置為`false`：

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

您還可以通過向`:pool`選項提供個別選項來覆蓋默認的連接池設置：

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: { size: 32, timeout: 1 }
```

* `:size` - 此選項設置每個進程的連接數（默認為5）。

* `:timeout` - 此選項設置等待連接的秒數（默認為5）。如果在超時內沒有可用的連接，將引發`Timeout::Error`。

### `ActiveSupport::Cache::Store`

[`ActiveSupport::Cache::Store`][]提供了在Rails中與緩存交互的基礎。這是一個抽象類，您不能單獨使用它。相反，您必須使用與存儲引擎相關聯的具體實現類。Rails附帶了幾個實現，下面有文檔記錄。

主要的API方法是[`read`][ActiveSupport::Cache::Store#read]、[`write`][ActiveSupport::Cache::Store#write]、[`delete`][ActiveSupport::Cache::Store#delete]、[`exist?`][ActiveSupport::Cache::Store#exist?]和[`fetch`][ActiveSupport::Cache::Store#fetch]。

傳遞給緩存存儲的構造函數的選項將被視為適用於相應API方法的默認選項。


### `ActiveSupport::Cache::MemoryStore`

[`ActiveSupport::Cache::MemoryStore`][]將條目保存在內存中的同一個Ruby進程中。緩存存儲通過將`size`選項發送到初始化程序來指定有界大小（默認為32Mb）。當緩存超過分配的大小時，將進行清理並刪除最近未使用的條目。

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

如果您運行多個Ruby on Rails服務器進程（如果使用Phusion Passenger或puma集群模式），則您的Rails服務器進程實例將無法共享緩存數據。此緩存存儲對於大型應用程序部署不適用。但是，對於僅有幾個服務器進程的小型低流量站點以及開發和測試環境，它可以很好地工作。

新的Rails項目在開發環境中默認配置為使用此實現。

注意：由於使用`:memory_store`時進程將不共享緩存數據，因此無法通過Rails控制台手動讀取、寫入或過期緩存。


### `ActiveSupport::Cache::FileStore`

[`ActiveSupport::Cache::FileStore`][]使用文件系統存儲條目。在初始化緩存時，必須指定存儲文件的目錄路徑。

```ruby
config.cache_store = :file_store, "/path/to/cache/directory"
```

使用此緩存存儲，同一主機上的多個服務器進程可以共享緩存。此緩存存儲適用於僅有一個或兩個主機提供服務的低到中等流量站點。在不同主機上運行的服務器進程可以通過使用共享文件系統來共享緩存，但不建議這種設置。

由於緩存將增長到磁盤已滿，建議定期清除舊條目。

如果未提供明確的`config.cache_store`，則此為默認的緩存存儲實現（位於`"#{root}/tmp/cache/"`）。


### `ActiveSupport::Cache::MemCacheStore`

[`ActiveSupport::Cache::MemCacheStore`][]使用Danga的`memcached`服務器為應用程序提供集中式緩存。Rails默認使用捆綁的`dalli` gem。這是目前用於生產網站的最受歡迎的緩存存儲。它可以用於提供具有非常高性能和冗余的單一共享緩存集群。

在初始化緩存時，應指定集群中所有memcached服務器的地址，或確保已正確設置了`MEMCACHE_SERVERS`環境變量。

```ruby
config.cache_store = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
```

如果都沒有指定，它將假定memcached在默認端口（`127.0.0.1:11211`）上運行，但這對於較大的站點來說並不是理想的設置。

```ruby
config.cache_store = :mem_cache_store # 將回退到$MEMCACHE_SERVERS，然後是127.0.0.1:11211
```

有關支持的地址類型，請參閱[`Dalli::Client`文檔](https://www.rubydoc.info/gems/dalli/Dalli/Client#initialize-instance_method)。

此緩存上的[`write`][ActiveSupport::Cache::MemCacheStore#write]（和`fetch`）方法接受利用memcached特定功能的其他選項。


### `ActiveSupport::Cache::RedisCacheStore`

[`ActiveSupport::Cache::RedisCacheStore`][]利用Redis在達到最大內存時自動進行清除，使其能夠像Memcached緩存服務器一樣運作。

部署注意事項：Redis默認不會過期鍵，因此請注意使用專用的Redis緩存服務器。不要用易失性緩存數據填滿持久性Redis服務器！詳細閱讀[Redis緩存服務器設置指南](https://redis.io/topics/lru-cache)。

對於僅用於緩存的Redis服務器，將`maxmemory-policy`設置為`allkeys`的變體之一。Redis 4+支持最不常用的淘汰（`allkeys-lfu`），這是一個很好的默認選擇。Redis 3及更早版本應使用最近最少使用的淘汰（`allkeys-lru`）。
將快取的讀寫超時設置得相對較低。重新生成快取值通常比等待超過一秒鐘來檢索它要快。讀取和寫入超時默認為1秒，但如果您的網絡延遲一直很低，可以將其設置得更低。

默認情況下，如果在請求期間連接失敗，快取存儲將不會嘗試重新連接到Redis。如果您經常斷開連接，可以啟用重新連接嘗試。

快取的讀取和寫入永遠不會引發異常；它們只會返回`nil`，表現得好像快取中沒有任何內容。為了判斷您的快取是否遇到異常，您可以提供一個`error_handler`來報告給異常收集服務。它必須接受三個關鍵字參數：`method`，最初調用的快取存儲方法；`returning`，通常為返回給用戶的值，通常為`nil`；以及`exception`，被捕獲的異常。

要開始使用，將redis gem添加到您的Gemfile中：

```ruby
gem 'redis'
```

最後，在相關的`config/environments/*.rb`文件中添加配置：

```ruby
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
```

一個更複雜的生產環境Redis快取存儲可能如下所示：

```ruby
cache_servers = %w(redis://cache-01:6379/0 redis://cache-02:6379/0)
config.cache_store = :redis_cache_store, { url: cache_servers,

  connect_timeout:    30,  # 默認為20秒
  read_timeout:       0.2, # 默認為1秒
  write_timeout:      0.2, # 默認為1秒
  reconnect_attempts: 1,   # 默認為0

  error_handler: -> (method:, returning:, exception:) {
    # 將錯誤報告給Sentry作為警告
    Sentry.capture_exception exception, level: 'warning',
      tags: { method: method, returning: returning }
  }
}
```


### `ActiveSupport::Cache::NullStore`

[`ActiveSupport::Cache::NullStore`][]是每個網絡請求的作用域，並在請求結束時清除存儲的值。它適用於開發和測試環境。當您的代碼直接與`Rails.cache`交互，但快取干擾了查看代碼更改的結果時，它非常有用。

```ruby
config.cache_store = :null_store
```


### 自定義快取存儲

您可以通過簡單地擴展`ActiveSupport::Cache::Store`並實現相應的方法來創建自己的自定義快取存儲。這樣，您可以將任意數量的快取技術換入您的Rails應用程序中。

要使用自定義的快取存儲，只需將快取存儲設置為您自定義類的新實例。

```ruby
config.cache_store = MyCacheStore.new
```

快取鍵
----------

在快取中使用的鍵可以是任何響應`cache_key`或`to_param`的對象。如果需要生成自定義鍵，您可以在您的類上實現`cache_key`方法。Active Record將根據類名和記錄ID生成鍵。

您可以使用哈希和值的數組作為快取鍵。

```ruby
# 這是一個合法的快取鍵
Rails.cache.read(site: "mysite", owners: [owner_1, owner_2])
```

您在`Rails.cache`上使用的鍵將與實際上在存儲引擎中使用的鍵不同。它們可能會被修改為帶有命名空間或符合技術後端的限制。這意味著，例如，您不能使用`Rails.cache`保存值，然後嘗試使用`dalli` gem將其取出。但是，您也不需要擔心超過memcached大小限制或違反語法規則。

條件GET支持
-----------------------

條件GET是HTTP規範的一個功能，它提供了一種方式，讓Web服務器告訴瀏覽器，GET請求的響應自上次請求以來沒有更改，可以安全地從瀏覽器緩存中提取。

它們通過使用`HTTP_IF_NONE_MATCH`和`HTTP_IF_MODIFIED_SINCE`標頭來來回傳遞唯一的內容標識符和內容上次更改的時間戳。如果瀏覽器發出的請求中的內容標識符（ETag）或上次修改自時間戳與服務器的版本匹配，則服務器只需返回一個空響應和未修改的狀態。

查找上次修改的時間戳和if-none-match標頭，並確定是否發送完整響應是服務器（即我們）的責任。在Rails中支持條件GET是一個相當簡單的任務：

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    # 如果根據給定的時間戳和etag值（即需要重新處理）請求是陳舊的，則執行此塊
    if stale?(last_modified: @product.updated_at.utc, etag: @product.cache_key_with_version)
      respond_to do |wants|
        # ... 正常的響應處理
      end
    end

    # 如果請求是新鮮的（即未修改），則您不需要做任何事情。默認渲染使用先前調用stale?的參數檢查這一點，並自動發送:not_modified。所以這就是它，您完成了。
  end
end
```
除了選項哈希之外，您也可以直接傳遞一個模型。Rails將使用`updated_at`和`cache_key_with_version`方法來設置`last_modified`和`etag`：

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    if stale?(@product)
      respond_to do |wants|
        # ... 正常的回應處理
      end
    end
  end
end
```

如果您沒有任何特殊的回應處理，並且使用默認的渲染機制（即不使用`respond_to`或自己調用render），則可以使用`fresh_when`這個簡單的幫助方法：

```ruby
class ProductsController < ApplicationController
  # 如果請求是新鮮的，這將自動返回 :not_modified，
  # 如果請求是陳舊的，則渲染默認模板（product.*）。

  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, etag: @product
  end
end
```

有時我們希望緩存回應，例如一個永遠不會過期的靜態頁面。為了實現這一點，我們可以使用`http_cache_forever`幫助方法，這樣瀏覽器和代理就可以無限期地緩存它。

默認情況下，緩存的回應將是私有的，僅在用戶的瀏覽器上緩存。要允許代理緩存回應，請將`public: true`設置為指示它們可以將緩存的回應提供給所有用戶。

使用這個幫助方法，`last_modified`標頭被設置為`Time.new(2011, 1, 1).utc`，`expires`標頭被設置為100年。

警告：請謹慎使用此方法，因為除非強制清除瀏覽器緩存，否則瀏覽器/代理將無法使緩存的回應失效。

```ruby
class HomeController < ApplicationController
  def index
    http_cache_forever(public: true) do
      render
    end
  end
end
```

### 強 ETag 與弱 ETag

Rails默認生成弱ETag。弱ETag允許在內容不完全匹配的情況下，具有相同ETag的語義等效回應。這在我們不希望因回應主體的微小變化而重新生成頁面時很有用。

弱ETag以`W/`開頭，以區分它們與強ETag。

```
W/"618bbc92e2d35ea1945008b42799b0e7" → 弱ETag
"618bbc92e2d35ea1945008b42799b0e7" → 強ETag
```

與弱ETag不同，強ETag意味著回應應該完全相同，逐字節相同。在對大型視頻或PDF文件進行範圍請求時很有用。一些CDN僅支持強ETag，例如Akamai。如果您絕對需要生成強ETag，可以按如下方式進行。

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, strong_etag: @product
  end
end
```

您還可以直接在回應上設置強ETag。

```ruby
response.strong_etag = response.body # => "618bbc92e2d35ea1945008b42799b0e7"
```

在開發中進行緩存
------------------

在開發模式下，通常希望測試應用程序的緩存策略。Rails提供了`dev:cache`命令來輕鬆切換緩存的開啟/關閉。

```bash
$ bin/rails dev:cache
Development mode is now being cached.
$ bin/rails dev:cache
Development mode is no longer being cached.
```

默認情況下，當開發模式緩存為*關閉*時，Rails使用[`:null_store`](#activesupport-cache-nullstore)。

參考資料
----------

* [DHH的關於基於鍵的過期的文章](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
* [Ryan Bates的關於緩存摘要的Railscast](http://railscasts.com/episodes/387-cache-digests)
[`config.action_controller.perform_caching`]: configuring.html#config-action-controller-perform-caching
[`ActiveSupport::Cache::Store`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
[ActiveSupport::Cache::Store#delete]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-delete
[ActiveSupport::Cache::Store#exist?]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-exist-3F
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#read]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-read
[ActiveSupport::Cache::Store#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-write
[`ActiveSupport::Cache::MemoryStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[`ActiveSupport::Cache::FileStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[`ActiveSupport::Cache::MemCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemCacheStore#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html#method-i-write
[`ActiveSupport::Cache::RedisCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[`ActiveSupport::Cache::NullStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/NullStore.html
