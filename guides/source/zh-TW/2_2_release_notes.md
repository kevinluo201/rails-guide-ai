**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 29fda46e32914456eb8369ab3f2cb7d6
Ruby on Rails 2.2 發行說明
===============================

Rails 2.2 提供了幾個新功能和改進功能。這個清單涵蓋了主要的升級，但不包括每一個小的錯誤修復和更改。如果你想看到所有的內容，請查看 GitHub 上主要的 Rails 存儲庫中的 [提交清單](https://github.com/rails/rails/commits/2-2-stable)。

除了 Rails，2.2 還標誌著 [Ruby on Rails Guides](https://guides.rubyonrails.org/) 的推出，這是持續進行中的 [Rails Guides hackfest](http://hackfest.rubyonrails.org/guide) 的第一個成果。這個網站將提供高質量的 Rails 主要功能文檔。

--------------------------------------------------------------------------------

基礎設施
--------------

Rails 2.2 對保持 Rails 順暢運行並與世界其他部分連接的基礎設施來說是一個重要的版本。

### 國際化

Rails 2.2 提供了一個簡單的國際化系統（或者對於那些厭倦了打字的人來說，叫做 i18n）。

* 主要貢獻者：Rails i18 團隊
* 更多信息：
    * [官方 Rails i18n 網站](http://rails-i18n.org)
    * [終於，Ruby on Rails 實現了國際化](https://web.archive.org/web/20140407075019/http://www.artweb-design.de/2008/7/18/finally-ruby-on-rails-gets-internationalized)
    * [本地化 Rails：演示應用程序](https://github.com/clemens/i18n_demo_app)

### 與 Ruby 1.9 和 JRuby 的兼容性

除了線程安全性外，還做了很多工作，使得 Rails 能夠與 JRuby 和即將推出的 Ruby 1.9 配合良好。由於 Ruby 1.9 是一個不斷變動的目標，運行最新版的 Rails 在最新版的 Ruby 上仍然是一個不確定的問題，但是 Rails 已經準備好在 Ruby 1.9 發布時過渡到該版本。

文檔
-------------

Rails 的內部文檔，以代碼註釋的形式，在許多地方進行了改進。此外，[Ruby on Rails Guides](https://guides.rubyonrails.org/) 項目是關於主要 Rails 組件的信息的權威來源。在它的第一個正式版本中，Guides 頁面包括：

* [Rails 入門](getting_started.html)
* [Rails 數據庫遷移](active_record_migrations.html)
* [Active Record 關聯](association_basics.html)
* [Active Record 查詢接口](active_record_querying.html)
* [Rails 中的佈局和渲染](layouts_and_rendering.html)
* [Action View 表單輔助方法](form_helpers.html)
* [從外部開始的 Rails 路由](routing.html)
* [Action Controller 概述](action_controller_overview.html)
* [Rails 緩存](caching_with_rails.html)
* [Rails 應用程序測試指南](testing.html)
* [保護 Rails 應用程序](security.html)
* [調試 Rails 應用程序](debugging_rails_applications.html)
* [創建 Rails 插件的基礎知識](plugins.html)

總的來說，這些指南為初學者和中級 Rails 開發人員提供了數以萬計的指導性文字。

如果你想在你的應用程序內部生成這些指南：

```bash
$ rake doc:guides
```

這將把指南放在 `Rails.root/doc/guides` 中，你可以通過在你喜歡的瀏覽器中打開 `Rails.root/doc/guides/index.html` 來開始瀏覽。

* 主要貢獻者：[Xavier Noria](http://advogato.org/person/fxn/diary.html) 和 [Hongli Lai](http://izumi.plan99.net/blog/)。
* 更多信息：
    * [Rails Guides hackfest](http://hackfest.rubyonrails.org/guide)
    * [在 Git 分支上幫助改進 Rails 文檔](https://weblog.rubyonrails.org/2008/5/2/help-improve-rails-documentation-on-git-branch)
更好的與HTTP整合：內建ETag支援
----------------------------------------------------------

支援在HTTP標頭中使用ETag和最後修改時間戳記意味著Rails現在可以在收到對尚未最近修改的資源的請求時返回一個空的回應。這使您可以檢查是否需要發送回應。

```ruby
class ArticlesController < ApplicationController
  def show_with_respond_to_block
    @article = Article.find(params[:id])

    # 如果請求的標頭與stale?方法提供的選項不同，則請求確實是過期的，並且觸發respond_to區塊（並且將stale?方法的選項設置在回應上）。
    #
    # 如果請求標頭匹配，則請求是新鮮的，並且不會觸發respond_to區塊。相反，將發生默認的渲染，它將檢查last-modified和etag標頭，並得出只需發送“304 Not Modified”而不是渲染模板。
    if stale?(:last_modified => @article.published_at.utc, :etag => @article)
      respond_to do |wants|
        # 正常的回應處理
      end
    end
  end

  def show_with_implied_render
    @article = Article.find(params[:id])

    # 設置回應標頭並將其與請求進行比對，如果請求是過期的（即etag或last-modified都不匹配），則默認的渲染模板將發生。
    # 如果請求是新鮮的，則默認的渲染將返回“304 Not Modified”而不是渲染模板。
    fresh_when(:last_modified => @article.published_at.utc, :etag => @article)
  end
end
```

執行緒安全性
-------------

使Rails具有執行緒安全性的工作正在Rails 2.2中推出。根據您的Web服務器基礎架構，這意味著您可以使用更少的Rails副本處理更多的請求，從而提高服務器性能並更好地利用多核心。

要在應用程式的生產模式中啟用多執行緒調度，請在`config/environments/production.rb`中添加以下行：

```ruby
config.threadsafe!
```

* 更多資訊：
    * [Thread safety for your Rails](http://m.onkey.org/2008/10/23/thread-safety-for-your-rails)
    * [Thread safety project announcement](https://weblog.rubyonrails.org/2008/8/16/josh-peek-officially-joins-the-rails-core)
    * [Q/A: What Thread-safe Rails Means](http://blog.headius.com/2008/08/qa-what-thread-safe-rails-means.html)

Active Record
-------------

這裡有兩個重要的新增功能：事務性遷移和資料庫連接池事務。還有一個新的（更簡潔）的連接表條件語法，以及一些較小的改進。

### 事務性遷移

在過去，多步驟的Rails遷移一直是一個麻煩的來源。如果在遷移過程中出現問題，錯誤之前的所有更改都會變更資料庫，而錯誤之後的所有更改都不會應用。此外，遷移版本被存儲為已執行，這意味著在修復問題後無法簡單地通過`rake db:migrate:redo`重新執行。事務性遷移通過將遷移步驟包裝在DDL事務中來改變這一點，因此如果其中任何一個失敗，整個遷移都將被撤銷。在Rails 2.2中，事務性遷移在PostgreSQL上得到了支援。代碼可擴展到未來支援其他數據庫類型，IBM已經擴展它以支援DB2適配器。
* 主要貢獻者：[Adam Wiggins](http://about.adamwiggins.com/)
* 更多資訊：
    * [DDL 交易](http://adam.heroku.com/past/2008/9/3/ddl_transactions/)
    * [DB2 on Rails 的重要里程碑](http://db2onrails.com/2008/11/08/a-major-milestone-for-db2-on-rails/)

### 連線池

連線池讓 Rails 可以將資料庫請求分散到一個連線池中，這個連線池的大小會增長到最大值（預設為 5，但你可以在 `database.yml` 中加入 `pool` 鍵來調整）。這有助於消除支援許多並行使用者的應用程式中的瓶頸。還有一個 `wait_timeout`，預設為 5 秒，表示在放棄之前等待的時間。如果需要，`ActiveRecord::Base.connection_pool` 可以直接存取連線池。

```yaml
development:
  adapter: mysql
  username: root
  database: sample_development
  pool: 10
  wait_timeout: 10
```

* 主要貢獻者：[Nick Sieger](http://blog.nicksieger.com/)
* 更多資訊：
    * [Edge Rails 的新功能：連線池](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-connection-pools)

### 使用 Hashes 進行連結表條件

現在可以使用 Hashes 在連結表上指定條件。如果需要在複雜的連結上進行查詢，這將非常有幫助。

```ruby
class Photo < ActiveRecord::Base
  belongs_to :product
end

class Product < ActiveRecord::Base
  has_many :photos
end

# 取得所有具有無版權照片的產品：
Product.all(:joins => :photos, :conditions => { :photos => { :copyright => false }})
```

* 更多資訊：
    * [Edge Rails 的新功能：簡單的連結表條件](http://archives.ryandaigle.com/articles/2008/7/7/what-s-new-in-edge-rails-easy-join-table-conditions)

### 新的動態查詢方法

Active Record 的動態查詢家族新增了兩組新的方法。

#### `find_last_by_attribute`

`find_last_by_attribute` 方法等同於 `Model.last(:conditions => {:attribute => value})`

```ruby
# 取得最後一位從倫敦註冊的使用者
User.find_last_by_city('London')
```

* 主要貢獻者：[Emilio Tagua](http://www.workingwithrails.com/person/9147-emilio-tagua)

#### `find_by_attribute!`

`find_by_attribute!` 的新版本（加上驚嘆號）等同於 `Model.first(:conditions => {:attribute => value}) || raise ActiveRecord::RecordNotFound`。這個方法在找不到符合條件的記錄時，不會返回 `nil`，而是會拋出異常。

```ruby
# 如果 'Moby' 還沒有註冊，則拋出 ActiveRecord::RecordNotFound 異常！
User.find_by_name!('Moby')
```

* 主要貢獻者：[Josh Susser](http://blog.hasmanythrough.com)

### 關聯尊重私有/受保護範圍

Active Record 關聯代理現在尊重代理對象上的方法範圍。之前（假設 User 有一個 has_one :account 關聯），`@user.account.private_method` 會調用關聯的 Account 物件上的私有方法。在 Rails 2.2 中，這將失敗；如果需要此功能，應該使用 `@user.account.send(:private_method)`（或將方法從私有或受保護改為公開）。請注意，如果覆寫了 `method_missing`，應該同時覆寫 `respond_to` 以匹配行為，以使關聯正常運作。

* 主要貢獻者：Adam Milligan
* 更多資訊：
    * [Rails 2.2 變更：關聯代理上的私有方法是私有的](http://afreshcup.com/2008/10/24/rails-22-change-private-methods-on-association-proxies-are-private/)
### 其他Active Record更改

* `rake db:migrate:redo` 現在接受一個可選的VERSION來重新執行特定的遷移
* 設置 `config.active_record.timestamped_migrations = false` 以使用數字前綴而不是UTC時間戳記來進行遷移。
* 不再需要將計數緩存列（對於使用 `:counter_cache => true` 声明的關聯）初始化為零。
* `ActiveRecord::Base.human_name` 用於對模型名稱進行國際化友好的翻譯

Action Controller
-----------------

在控制器方面，有幾個更改將有助於整理您的路由。路由引擎中還有一些內部更改，以降低複雜應用程序的內存使用。

### 淺層路由嵌套

淺層路由嵌套提供了一種解決使用深度嵌套資源的已知困難的方法。使用淺層嵌套，您只需要提供足夠的信息來唯一識別要使用的資源。

```ruby
map.resources :publishers, :shallow => true do |publisher|
  publisher.resources :magazines do |magazine|
    magazine.resources :photos
  end
end
```

這將使得以下路由能夠被識別：

```
/publishers/1           ==> publisher_path(1)
/publishers/1/magazines ==> publisher_magazines_path(1)
/magazines/2            ==> magazine_path(2)
/magazines/2/photos     ==> magazines_photos_path(2)
/photos/3               ==> photo_path(3)
```

* 主要貢獻者：[S. Brent Faulkner](http://www.unwwwired.net/)
* 更多信息：
    * [Rails Routing from the Outside In](routing.html#nested-resources)
    * [What's New in Edge Rails: Shallow Routes](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-shallow-routes)

### 成員或集合路由的方法陣列

現在，您可以為新的成員或集合路由提供一個方法陣列。這樣可以解決當您需要處理多個動詞時，不得不將路由定義為接受任何動詞的麻煩。在Rails 2.2中，這是一個合法的路由聲明：

```ruby
map.resources :photos, :collection => { :search => [:get, :post] }
```

* 主要貢獻者：[Brennan Dunn](http://brennandunn.com/)

### 具有特定操作的資源

默認情況下，當您使用 `map.resources` 創建一個路由時，Rails會為七個默認操作（index、show、create、new、edit、update和destroy）生成路由。但是，每個路由在應用程序中佔用內存，並導致Rails生成額外的路由邏輯。現在，您可以使用 `:only` 和 `:except` 選項來微調Rails為資源生成的路由。您可以提供單個操作、操作陣列或特殊的 `:all` 或 `:none` 選項。這些選項會被嵌套資源繼承。

```ruby
map.resources :photos, :only => [:index, :show]
map.resources :products, :except => :destroy
```

* 主要貢獻者：[Tom Stuart](http://experthuman.com/)

### 其他Action Controller更改

* 現在可以輕鬆地為路由請求引發的異常顯示[自定義錯誤頁面](http://m.onkey.org/2008/7/20/rescue-from-dispatching)。
* 默認情況下，HTTP Accept標頭已禁用。您應該優先使用格式化的URL（例如 `/customers/1.xml`）來指示您想要的格式。如果需要Accept標頭，可以使用 `config.action_controller.use_accept_header = true` 將其打開。
* 基準測試數字現在以毫秒為單位報告，而不是秒的小數部分。
* Rails現在支持僅HTTP的Cookie（並將其用於會話），這有助於在新版本的瀏覽器中減輕一些跨站腳本風險。
* `redirect_to` 現在完全支持URI方案（因此，例如，您可以重定向到svn`ssh: URI）。
* `render` 現在支持 `:js` 選項，以使用正確的MIME類型呈現純粹的JavaScript。
* 請求偽造保護已經加強，僅適用於HTML格式的內容請求。
* 如果傳遞的參數為nil，多態URL將更合理地處理。例如，使用nil日期調用 `polymorphic_path([@project, @date, @area])` 將為您提供 `project_area_path`。
Action View
-----------

* `javascript_include_tag` 和 `stylesheet_link_tag` 支援新的 `:recursive` 選項，可以與 `:all` 一起使用，這樣你就可以用一行程式碼載入整個樹狀結構的檔案。
* 內建的 Prototype JavaScript 函式庫已升級至版本 1.6.0.3。
* `RJS#page.reload` 可以透過 JavaScript 重新載入瀏覽器的目前位置。
* `atom_feed` 輔助方法現在接受 `:instruct` 選項，讓你可以插入 XML 處理指令。

Action Mailer
-------------

Action Mailer 現在支援郵件佈局。你可以通過提供相應名稱的佈局（例如，`CustomerMailer` 類預期使用 `layouts/customer_mailer.html.erb`）使你的 HTML 郵件和瀏覽器中的視圖一樣漂亮。

* 更多資訊：
    * [Edge Rails 的新功能：Mailer 佈局](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-mailer-layouts)

Action Mailer 現在內建支援 GMail 的 SMTP 伺服器，自動啟用 STARTTLS。這需要安裝 Ruby 1.8.7。

Active Support
--------------

Active Support 現在為 Rails 應用程式提供內建的記憶化支援、`each_with_object` 方法、委派的前綴支援和其他各種新的實用方法。

### 記憶化

記憶化是一種將方法初始化一次並將其值存儲起來以供重複使用的模式。你可能在自己的應用程式中使用過這種模式：

```ruby
def full_name
  @full_name ||= "#{first_name} #{last_name}"
end
```

記憶化讓你以聲明式的方式處理這個任務：

```ruby
extend ActiveSupport::Memoizable

def full_name
  "#{first_name} #{last_name}"
end
memoize :full_name
```

記憶化的其他功能包括 `unmemoize`、`unmemoize_all` 和 `memoize_all` 用於開啟或關閉記憶化。

* 主要貢獻者：[Josh Peek](http://joshpeek.com/)
* 更多資訊：
    * [Edge Rails 的新功能：簡單的記憶化](http://archives.ryandaigle.com/articles/2008/7/16/what-s-new-in-edge-rails-memoization)
    * [什麼是記憶化？一個記憶化指南](http://www.railway.at/articles/2008/09/20/a-guide-to-memoization)

### each_with_object

`each_with_object` 方法提供了一種替代 `inject` 的方法，使用了從 Ruby 1.9 回溯的方法。它遍歷集合，將當前元素和記憶體傳遞給區塊。

```ruby
%w(foo bar).each_with_object({}) { |str, hsh| hsh[str] = str.upcase } # => {'foo' => 'FOO', 'bar' => 'BAR'}
```

主要貢獻者：[Adam Keys](http://therealadam.com/)

### 帶前綴的委派

如果你從一個類委派行為到另一個類，現在你可以指定一個前綴，用於識別被委派的方法。例如：

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => true
end
```

這將產生被委派的方法 `vendor#account_email` 和 `vendor#account_password`。你也可以指定自定義的前綴：

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => :owner
end
```

這將產生被委派的方法 `vendor#owner_email` 和 `vendor#owner_password`。
主要貢獻者：[Daniel Schierbeck](http://workingwithrails.com/person/5830-daniel-schierbeck)

### 其他Active Support變更

* 對`ActiveSupport::Multibyte`進行了大量更新，包括Ruby 1.9相容性修正。
* 新增了`ActiveSupport::Rescuable`，允許任何類別使用`rescue_from`語法。
* 為`Date`和`Time`類別新增了`past?`、`today?`和`future?`，以便進行日期/時間比較。
* `Array#second`到`Array#fifth`作為`Array#[1]`到`Array#[4]`的別名。
* `Enumerable#many?`封裝了`collection.size > 1`。
* `Inflector#parameterize`產生URL可用的版本，供`to_param`使用。
* `Time#advance`支援小數天和週，例如`1.7.weeks.ago`、`1.5.hours.since`等。
* 包含的TzInfo庫已升級至0.3.12版本。
* `ActiveSupport::StringInquirer`提供了一種漂亮的方式來測試字串的相等性：`ActiveSupport::StringInquirer.new("abc").abc? => true`

Railties
--------

在Railties（Rails核心代碼）中，最大的變更是在`config.gems`機制中。

### config.gems

為了避免部署問題並使Rails應用更加自包含，可以將Rails應用所需的所有gem副本放在`/vendor/gems`中。這個功能首次出現在Rails 2.1中，但在Rails 2.2中更加靈活和強大，可以處理gem之間的複雜依賴關係。Rails中的gem管理包括以下命令：

* 在`config/environment.rb`文件中使用`config.gem _gem_name_`
* 使用`rake gems`列出所有配置的gem，以及它們（和它們的依賴）是否已安裝、凍結或框架（框架gem是在執行gem依賴代碼之前由Rails加載的gem；這些gem無法凍結）
* 使用`rake gems:install`將缺少的gem安裝到計算機上
* 使用`rake gems:unpack`將所需的gem副本放入`/vendor/gems`
* 使用`rake gems:unpack:dependencies`將所需的gem及其依賴關係的副本放入`/vendor/gems`
* 使用`rake gems:build`構建任何缺少的原生擴展
* 使用`rake gems:refresh_specs`將使用Rails 2.1創建的vendored gem與Rails 2.2的存儲方式保持一致

可以通過在命令行上指定`GEM=_gem_name_`來解壓縮或安裝單個gem。

* 主要貢獻者：[Matt Jones](https://github.com/al2o3cr)
* 更多資訊：
    * [Edge Rails的新功能：Gem依賴關係](http://archives.ryandaigle.com/articles/2008/4/1/what-s-new-in-edge-rails-gem-dependencies)
    * [Rails 2.1.2和2.2RC1：更新你的RubyGems](https://afreshcup.com/home/2008/10/25/rails-212-and-22rc1-update-your-rubygems)
    * [Lighthouse上的詳細討論](http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1128)

### 其他Railties變更

* 如果你是[Thin](http://code.macournoyer.com/thin/)網頁伺服器的粉絲，你會很高興知道`script/server`現在直接支援Thin。
* `script/plugin install &lt;plugin&gt; -r &lt;revision&gt;`現在可以用於基於git和svn的插件。
* `script/console`現在支援`--debugger`選項。
* 在Rails源碼中包含了建立連續集成伺服器來構建Rails本身的指示。
* `rake notes:custom ANNOTATION=MYFLAG`允許列出自定義註釋。
* 將`Rails.env`封裝在`StringInquirer`中，這樣你就可以使用`Rails.env.development?`。
* 為了消除廢棄警告並正確處理gem依賴關係，Rails現在需要rubygems 1.3.1或更高版本。
已棄用
----------

在此版本中，有一些舊代碼已被棄用：

* `Rails::SecretKeyGenerator` 已被 `ActiveSupport::SecureRandom` 取代
* `render_component` 已被棄用。如果需要此功能，可以使用 [render_components 插件](https://github.com/rails/render_component/tree/master)。
* 在渲染局部視圖時，隱式本地變量賦值已被棄用。

    ```ruby
    def partial_with_implicit_local_assignment
      @customer = Customer.new("Marcel")
      render :partial => "customer"
    end
    ```

    以前，上述代碼在局部視圖 'customer' 內提供了一個名為 `customer` 的本地變量。現在，您應該通過 `:locals` 散列明確傳遞所有變量。

* `country_select` 已被移除。請參閱 [棄用頁面](http://www.rubyonrails.org/deprecation/list-of-countries) 以獲取更多信息和插件替代方案。
* `ActiveRecord::Base.allow_concurrency` 不再起作用。
* `ActiveRecord::Errors.default_error_messages` 已被棄用，建議使用 `I18n.translate('activerecord.errors.messages')`。
* 插值國際化的 `%s` 和 `%d` 語法已被棄用。
* `String#chars` 已被 `String#mb_chars` 取代。
* 帶有小數月份或小數年份的持續時間已被棄用。請改用 Ruby 的核心 `Date` 和 `Time` 類算術。
* `Request#relative_url_root` 已被棄用。請改用 `ActionController::Base.relative_url_root`。

貢獻者
-------

發行說明由 [Mike Gunderloy](http://afreshcup.com) 編寫。
