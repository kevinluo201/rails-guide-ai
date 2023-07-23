**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: df23e2b31bd56973a30f38f5a1c29b52
Ruby on Rails 5.0 發行說明
===============================

Rails 5.0 的亮點：

* Action Cable
* Rails API
* Active Record 屬性 API
* 測試運行器
* 僅使用 `rails` CLI 而非 Rake
* Sprockets 3
* Turbolinks 5
* 需要 Ruby 2.2.2+

這些發行說明僅涵蓋主要更改。要了解各種錯誤修復和更改，請參閱變更日誌或查看 GitHub 上主要 Rails 存儲庫中的[提交列表](https://github.com/rails/rails/commits/5-0-stable)。

--------------------------------------------------------------------------------

升級到 Rails 5.0
----------------------

如果您正在升級現有應用程序，建議在進行升級之前進行良好的測試覆蓋。如果您尚未進行升級，請先升級到 Rails 4.2，並確保應用程序運行正常，然後再嘗試升級到 Rails 5.0。在升級時要注意的事項列表可在[升級 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0)指南中找到。

主要功能
--------------

### Action Cable

Action Cable 是 Rails 5 中的新框架。它將 [WebSockets](https://en.wikipedia.org/wiki/WebSocket) 與您的 Rails 應用程序的其他部分無縫集成。

Action Cable 允許使用 Ruby 以與您的 Rails 應用程序的其他部分相同的風格和形式編寫實時功能，同時保持高效和可擴展性。它是一個全棧解決方案，提供了客戶端 JavaScript 框架和服務器端 Ruby 框架。您可以訪問使用 Active Record 或您選擇的 ORM 編寫的完整域模型。

有關更多信息，請參閱[Action Cable 概述](action_cable_overview.html)指南。

### API 應用程序

Rails 現在可以用於創建精簡的僅限 API 應用程序。這對於創建和提供類似於 [Twitter](https://dev.twitter.com) 或 [GitHub](https://developer.github.com) API 的公共面向和自定義應用程序非常有用。

您可以使用以下命令生成新的 API Rails 應用程序：

```bash
$ rails new my_api --api
```

這將執行三個主要操作：

- 配置應用程序以使用比正常情況下更有限的中間件集。具體而言，默認情況下，它不會包含任何主要用於瀏覽器應用程序（例如 cookie 支持）的中間件。
- 使 `ApplicationController` 繼承自 `ActionController::API` 而不是 `ActionController::Base`。與中間件一樣，這將省略任何主要用於瀏覽器應用程序的 Action Controller 模塊。
- 配置生成器，在生成新資源時跳過生成視圖、幫助程序和資源。

該應用程序提供了一個用於 API 的基礎，然後可以根據應用程序的需求[配置以引入功能](api_app.html)。
請參閱[僅使用Rails進行API應用程式](api_app.html)指南以獲取更多資訊。

### Active Record屬性API

在模型上定義具有類型的屬性。如果需要，它將覆蓋現有屬性的類型。
這允許控制在分配給模型時如何將值轉換為SQL以及從SQL轉換為值。
它還改變了傳遞給`ActiveRecord::Base.where`的值的行為，這讓我們可以在Active Record的大部分中使用我們的領域對象，而不必依賴於實現細節或猴子補丁。

以下是一些您可以通過這種方式實現的功能：

- 可以覆蓋Active Record檢測到的類型。
- 也可以提供默認值。
- 屬性不需要有資料庫列支持。

```ruby
# db/schema.rb
create_table :store_listings, force: true do |t|
  t.decimal :price_in_cents
  t.string :my_string, default: "original default"
end
```

```ruby
# app/models/store_listing.rb
class StoreListing < ActiveRecord::Base
end
```

```ruby
store_listing = StoreListing.new(price_in_cents: '10.1')

# before
store_listing.price_in_cents # => BigDecimal.new(10.1)
StoreListing.new.my_string # => "original default"

class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer # 自訂類型
  attribute :my_string, :string, default: "new default" # 默認值
  attribute :my_default_proc, :datetime, default: -> { Time.now } # 默認值
  attribute :field_without_db_column, :integer, array: true
end

# after
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes # => {field_without_db_column: [1, 2, 3]}
```

**創建自定義類型：**

您可以定義自己的自定義類型，只要它們響應於值類型上定義的方法。方法`deserialize`或`cast`將在您的類型物件上調用，並使用來自資料庫或控制器的原始輸入。這在進行自定義轉換（例如貨幣數據）時非常有用。

**查詢：**

當調用`ActiveRecord::Base.where`時，它將使用模型類定義的類型將值轉換為SQL，並在您的類型物件上調用`serialize`。

這使得對象能夠指定在執行SQL查詢時如何轉換值。

**Dirty Tracking：**

屬性的類型允許更改骯髒跟踪的方式。

請參閱其[文檔](https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html)進行詳細說明。


### 測試運行器

引入了一個新的測試運行器來增強從Rails運行測試的功能。
要使用此測試運行器，只需輸入`bin/rails test`。

測試運行器受到`RSpec`、`minitest-reporters`、`maxitest`和其他工具的啟發。
它包括以下一些值得注意的改進：

- 使用測試的行號運行單個測試。
- 使用測試的行號運行多個測試。
- 改進的失敗消息，還可以輕鬆重新運行失敗的測試。
- 使用`-f`選項快速失敗，即在發生失敗時立即停止測試，而不是等待套件完成。
- 使用`-d`選項將測試輸出推遲到完整測試運行的結束。
- 使用`-b`選項完整的異常回溯輸出。
- 與minitest集成，允許選項如`-s`用於測試種子數據，`-n`用於按名稱運行特定測試，`-v`用於更好的詳細輸出等等。
- 彩色測試輸出。
Railties
--------

請參考[更新日誌][railties]以獲取詳細的變更內容。

### 刪除項目

*   刪除了除錯器支援，請改用byebug。Ruby 2.2不支援`debugger`。
    ([commit](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))

*   刪除了已棄用的`test:all`和`test:all:db`任務。
    ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   刪除了已棄用的`Rails::Rack::LogTailer`。
    ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   刪除了已棄用的`RAILS_CACHE`常數。
    ([commit](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   刪除了已棄用的`serve_static_assets`設定。
    ([commit](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   刪除了文件任務`doc:app`、`doc:rails`和`doc:guides`。
    ([commit](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   從預設堆疊中刪除了`Rack::ContentLength`中介軟體。
    ([Commit](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### 已棄用項目

*   已棄用`config.static_cache_control`，改用`config.public_file_server.headers`。
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   已棄用`config.serve_static_files`，改用`config.public_file_server.enabled`。
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*   已棄用`rails`任務命名空間中的任務，改用`app`命名空間。
    （例如，`rails:update`和`rails:template`任務改名為`app:update`和`app:template`。）
    ([Pull Request](https://github.com/rails/rails/pull/23439))

### 重要變更

*   新增了Rails測試運行器`bin/rails test`。
    ([Pull Request](https://github.com/rails/rails/pull/19216))

*   新生成的應用程式和插件在Markdown中獲得了一個`README.md`。
    ([commit](https://github.com/rails/rails/commit/89a12c931b1f00b90e74afffcdc2fc21f14ca663),
     [Pull Request](https://github.com/rails/rails/pull/22068))

*   新增了`bin/rails restart`任務，通過觸發`tmp/restart.txt`來重新啟動Rails應用程式。
    ([Pull Request](https://github.com/rails/rails/pull/18965))

*   新增了`bin/rails initializers`任務，按照Rails調用它們的順序列印出所有已定義的初始化器。
    ([Pull Request](https://github.com/rails/rails/pull/19323))

*   新增了`bin/rails dev:cache`，用於在開發模式下啟用或禁用快取。
    ([Pull Request](https://github.com/rails/rails/pull/20961))

*   新增了`bin/update`腳本，用於自動更新開發環境。
    ([Pull Request](https://github.com/rails/rails/pull/20972))

*   通過`bin/rails`代理Rake任務。
    ([Pull Request](https://github.com/rails/rails/pull/22457),
     [Pull Request](https://github.com/rails/rails/pull/22288))

*   在Linux和macOS上啟用了新生成的應用程式的事件驅動文件系統監視器。可以通過在生成器中傳遞`--skip-listen`來選擇不使用此功能。
    ([commit](https://github.com/rails/rails/commit/de6ad5665d2679944a9ee9407826ba88395a1003),
    [commit](https://github.com/rails/rails/commit/94dbc48887bf39c241ee2ce1741ee680d773f202))

*   生成的應用程式可以選擇使用環境變數`RAILS_LOG_TO_STDOUT`在生產環境中將日誌輸出到STDOUT。
    ([Pull Request](https://github.com/rails/rails/pull/23734))

*   為新生成的應用程式啟用了具有IncludeSubdomains標頭的HSTS。
    ([Pull Request](https://github.com/rails/rails/pull/23852))

*   應用程式生成器寫入了一個新文件`config/spring.rb`，告訴Spring監視其他常見文件。
    ([commit](https://github.com/rails/rails/commit/b04d07337fd7bc17e88500e9d6bcd361885a45f8))

*   在生成新應用程式時，新增了`--skip-action-mailer`選項，用於跳過Action Mailer。
    ([Pull Request](https://github.com/rails/rails/pull/18288))

*   刪除了`tmp/sessions`目錄及相關的清理Rake任務。
    ([Pull Request](https://github.com/rails/rails/pull/18314))

*   修改了由脚手架生成的`_form.html.erb`，使用本地變數。
    ([Pull Request](https://github.com/rails/rails/pull/13434))

*   在生產環境中禁用了類的自動載入。
    ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

Action Pack
-----------

請參考[更新日誌][action-pack]以獲取詳細的變更內容。

### 刪除項目

*   刪除了`ActionDispatch::Request::Utils.deep_munge`。
    ([commit](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   刪除了`ActionController::HideActions`。
    ([Pull Request](https://github.com/rails/rails/pull/18371))

*   刪除了`respond_to`和`respond_with`的占位方法，此功能已提取到[responders](https://github.com/plataformatec/responders) gem中。
    ([commit](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   刪除了已棄用的斷言文件。
    ([commit](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   刪除了URL輔助方法中使用字符串鍵的已棄用用法。
    ([commit](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   刪除了`*_path`輔助方法中已棄用的`only_path`選項。
    ([commit](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))
*   移除了已棄用的`NamedRouteCollection#helpers`。
    ([commit](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*   移除了不再支援使用不包含`#`的`to`選項定義路由的功能。
    ([commit](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   移除了已棄用的`ActionDispatch::Response#to_ary`。
    ([commit](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   移除了已棄用的`ActionDispatch::Request#deep_munge`。
    ([commit](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   移除了已棄用的`ActionDispatch::Http::Parameters#symbolized_path_parameters`。
    ([commit](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   移除了控制器測試中已棄用的`use_route`選項。
    ([commit](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   移除了`assigns`和`assert_template`。這兩個方法已經被提取到[rails-controller-testing](https://github.com/rails/rails-controller-testing) gem中。
    ([Pull Request](https://github.com/rails/rails/pull/20138))

### 已棄用功能

*   已棄用所有`*_filter`回調，改用`*_action`回調。
    ([Pull Request](https://github.com/rails/rails/pull/18410))

*   已棄用`*_via_redirect`整合測試方法。在請求調用後手動使用`follow_redirect!`達到相同效果。
    ([Pull Request](https://github.com/rails/rails/pull/18693))

*   已棄用`AbstractController#skip_action_callback`，改用個別的skip_callback方法。
    ([Pull Request](https://github.com/rails/rails/pull/19060))

*   已棄用`render`方法的`:nothing`選項。
    ([Pull Request](https://github.com/rails/rails/pull/20336))

*   已棄用將第一個參數作為`Hash`和`head`方法的預設狀態碼的功能。
    ([Pull Request](https://github.com/rails/rails/pull/20407))

*   已棄用使用字符串或符號作為中介軟體類名的功能。請改用類名。
    ([commit](https://github.com/rails/rails/commit/83b767ce))

*   已棄用通過常量（例如`Mime::HTML`）訪問MIME類型的功能。請改用使用符號的下標運算符（例如`Mime[:html]`）。
    ([Pull Request](https://github.com/rails/rails/pull/21869))

*   已棄用`redirect_to :back`，改用`redirect_back`，該方法接受必需的`fallback_location`參數，從而消除了`RedirectBackError`的可能性。
    ([Pull Request](https://github.com/rails/rails/pull/22506))

*   `ActionDispatch::IntegrationTest`和`ActionController::TestCase`已棄用位置參數，改用關鍵字參數。
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   已棄用`controller`和`action`路徑參數。
    ([Pull Request](https://github.com/rails/rails/pull/23980))

*   已棄用控制器實例上的`env`方法。
    ([commit](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   `ActionDispatch::ParamsParser`已棄用並從中介軟體堆棧中移除。要配置參數解析器，請使用`ActionDispatch::Request.parameter_parsers=`。
    ([commit](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1),
    [commit](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))

### 重要變更

*   添加了`ActionController::Renderer`，用於在控制器動作之外渲染任意模板。
    ([Pull Request](https://github.com/rails/rails/pull/18546))

*   在`ActionController::TestCase`和`ActionDispatch::Integration`的HTTP請求方法中遷移為關鍵字參數語法。
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   添加了`http_cache_forever`到Action Controller，以便可以緩存永不過期的響應。
    ([Pull Request](https://github.com/rails/rails/pull/18394))

*   提供更友好的訪問請求變體的方式。
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   對於沒有對應模板的動作，渲染`head :no_content`而不是拋出錯誤。
    ([Pull Request](https://github.com/rails/rails/pull/19377))

*   添加了在控制器中覆蓋默認表單生成器的能力。
    ([Pull Request](https://github.com/rails/rails/pull/19736))

*   添加了對僅API應用的支援。`ActionController::API`被添加作為這種應用的`ActionController::Base`的替代品。
    ([Pull Request](https://github.com/rails/rails/pull/19832))

*   `ActionController::Parameters`不再繼承自`HashWithIndifferentAccess`，使其更容易使用。
    ([Pull Request](https://github.com/rails/rails/pull/20868))

*   通過使其更安全且更容易禁用，使得更容易選擇啟用`config.force_ssl`和`config.ssl_options`。
    ([Pull Request](https://github.com/rails/rails/pull/21520))

*   添加了將任意標頭返回給`ActionDispatch::Static`的能力。
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   將`protect_from_forgery`的預設prepend改為`false`。
    ([commit](https://github.com/rails/rails/commit/39794037817703575c35a75f1961b01b83791191))
*   `ActionController::TestCase` 在 Rails 5.1 中將被移至自己的 gem 中。請改用 `ActionDispatch::IntegrationTest`。
    ([commit](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d))

*   Rails 默認生成弱 ETags。
    ([Pull Request](https://github.com/rails/rails/pull/17573))

*   控制器動作如果沒有顯式的 `render` 調用且沒有對應的模板，將隱式地渲染 `head :no_content` 而不是拋出錯誤。
    (Pull Request [1](https://github.com/rails/rails/pull/19377),
    [2](https://github.com/rails/rails/pull/23827))

*   增加了每個表單的 CSRF token 選項。
    ([Pull Request](https://github.com/rails/rails/pull/22275))

*   在集成測試中增加了請求編碼和響應解析。
    ([Pull Request](https://github.com/rails/rails/pull/21671))

*   添加 `ActionController#helpers` 以在控制器層級獲取視圖上下文。
    ([Pull Request](https://github.com/rails/rails/pull/24866))

*   棄用的 flash 訊息在存入 session 前被刪除。
    ([Pull Request](https://github.com/rails/rails/pull/18721))

*   支持將記錄集合傳遞給 `fresh_when` 和 `stale?`。
    ([Pull Request](https://github.com/rails/rails/pull/18374))

*   `ActionController::Live` 變成了 `ActiveSupport::Concern`。這意味著它不能只被包含在其他模塊中，而不擴展它們使用 `ActiveSupport::Concern` 或 `ActionController::Live`，否則在生產環境中 `ActionController::Live` 將不會生效。有些人可能還使用另一個模塊來包含一些特殊的 `Warden`/`Devise` 認證失敗處理代碼，因為中間件無法捕獲由使用 `ActionController::Live` 時生成的線程拋出的 `:warden`。
    ([更多詳情請參見此問題](https://github.com/rails/rails/issues/25581))

*   引入了 `Response#strong_etag=` 和 `#weak_etag=`，以及 `fresh_when` 和 `stale?` 的相應選項。
    ([Pull Request](https://github.com/rails/rails/pull/24387))

Action View
-------------

詳細更改請參見 [Changelog][action-view]。

### 刪除

*   刪除了棄用的 `AbstractController::Base::parent_prefixes`。
    ([commit](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

*   刪除了 `ActionView::Helpers::RecordTagHelper`，此功能已提取到
    [record_tag_helper](https://github.com/rails/record_tag_helper) gem 中。
    ([Pull Request](https://github.com/rails/rails/pull/18411))

*   刪除了 `:rescue_format` 選項的 `translate` 輔助方法，因為它不再被 I18n 支持。
    ([Pull Request](https://github.com/rails/rails/pull/20019))

### 重要更改

*   將默認模板處理程序從 `ERB` 改為 `Raw`。
    ([commit](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

*   集合渲染可以緩存並一次獲取多個局部模板。
    ([Pull Request](https://github.com/rails/rails/pull/18948),
    [commit](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

*   對於明確的依賴項，添加了通配符匹配。
    ([Pull Request](https://github.com/rails/rails/pull/20904))

*   將 `disable_with` 設置為提交標籤的默認行為。在提交時禁用按鈕以防止重複提交。
    ([Pull Request](https://github.com/rails/rails/pull/21135))

*   局部模板名稱不再需要是有效的 Ruby 識別符。
    ([commit](https://github.com/rails/rails/commit/da9038e))

*   `datetime_tag` 輔助方法現在生成一個類型為 `datetime-local` 的輸入標籤。
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   在使用 `render partial:` 輔助方法時允許使用區塊。
    ([Pull Request](https://github.com/rails/rails/pull/17974))

Action Mailer
-------------

詳細更改請參見 [Changelog][action-mailer]。

### 刪除

*   刪除了在電子郵件視圖中的棄用的 `*_path` 輔助方法。
    ([commit](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

*   刪除了棄用的 `deliver` 和 `deliver!` 方法。
    ([commit](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### 重要更改

*   模板查找現在尊重默認語言和 I18n 回退。
    ([commit](https://github.com/rails/rails/commit/ecb1981b))

*   通過生成器創建的郵件發送器現在在名稱上添加 `_mailer` 後綴，遵循與控制器和作業相同的命名慣例。
    ([Pull Request](https://github.com/rails/rails/pull/18074))

[action-view]: https://github.com/rails/rails/blob/master/actionview/CHANGELOG.md
[action-mailer]: https://github.com/rails/rails/blob/master/actionmailer/CHANGELOG.md
*   新增了 `assert_enqueued_emails` 和 `assert_no_enqueued_emails` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/18403))

*   新增了 `config.action_mailer.deliver_later_queue_name` 配置，用於設置郵件發送隊列的名稱。
    ([Pull Request](https://github.com/rails/rails/pull/18587))

*   在 Action Mailer 視圖中新增了對片段緩存的支持。
    新增了新的配置選項 `config.action_mailer.perform_caching`，用於確定模板是否應該進行緩存。
    ([Pull Request](https://github.com/rails/rails/pull/22825))


Active Record
-------------

詳細的變更請參考 [Changelog][active-record]。

### 刪除

*   刪除了允許嵌套數組作為查詢值的已棄用行為。
    ([Pull Request](https://github.com/rails/rails/pull/17919))

*   刪除了已棄用的 `ActiveRecord::Tasks::DatabaseTasks#load_schema` 方法。
    這個方法已被 `ActiveRecord::Tasks::DatabaseTasks#load_schema_for` 方法取代。
    ([commit](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))

*   刪除了已棄用的 `serialized_attributes` 方法。
    ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*   刪除了已棄用的 `has_many :through` 上的自動計數緩存。
    ([commit](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

*   刪除了已棄用的 `sanitize_sql_hash_for_conditions` 方法。
    ([commit](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

*   刪除了已棄用的 `Reflection#source_macro` 方法。
    ([commit](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

*   刪除了已棄用的 `symbolized_base_class` 和 `symbolized_sti_name` 方法。
    ([commit](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

*   刪除了已棄用的 `ActiveRecord::Base.disable_implicit_join_references=` 方法。
    ([commit](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

*   刪除了使用字符串訪問器訪問連接配置的已棄用支持。
    ([commit](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

*   刪除了預加載實例相關聯的已棄用支持。
    ([commit](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

*   刪除了對於具有獨占下界的 PostgreSQL 範圍的已棄用支持。
    ([commit](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

*   刪除了使用緩存的 Arel 修改關聯的已棄用支持。
    現在會引發 `ImmutableRelation` 錯誤。
    ([commit](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

*   從核心中刪除了 `ActiveRecord::Serialization::XmlSerializer`。這個功能已經被提取到
    [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml)
    gem 中。
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   從核心中刪除了對於舊版 `mysql` 數據庫適配器的支持。大多數用戶應該可以使用 `mysql2`。
    當我們找到有人維護它時，它將被轉換為一個獨立的 gem。
    ([Pull Request 1](https://github.com/rails/rails/pull/22642),
    [Pull Request 2](https://github.com/rails/rails/pull/22715))

*   刪除了對於 `protected_attributes` gem 的支持。
    ([commit](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

*   刪除了對於低於 9.1 版本的 PostgreSQL 的支持。
    ([Pull Request](https://github.com/rails/rails/pull/23434))

*   刪除了對於 `activerecord-deprecated_finders` gem 的支持。
    ([commit](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

*   刪除了 `ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES` 常量。
    ([commit](https://github.com/rails/rails/commit/a502703c3d2151d4d3b421b29fefdac5ad05df61))

### 已棄用

*   已棄用將類作為查詢值的方式。用戶應該使用字符串代替。
    ([Pull Request](https://github.com/rails/rails/pull/17916))

*   已棄用將 `false` 作為停止 Active Record 回調鏈的方式。推薦的方式是使用 `throw(:abort)`。
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   已棄用 `ActiveRecord::Base.errors_in_transactional_callbacks=`。
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

*   已棄用 `Relation#uniq`，請改用 `Relation#distinct`。
    ([commit](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

*   已棄用 PostgreSQL 的 `:point` 類型，改用一個新的類型，將返回 `Point` 對象而不是 `Array`
    ([Pull Request](https://github.com/rails/rails/pull/20448))

*   已棄用通過將真值參數傳遞給關聯方法來強制重新加載關聯。
    ([Pull Request](https://github.com/rails/rails/pull/20888))

*   已棄用關聯 `restrict_dependent_destroy` 錯誤的鍵名，改用新的鍵名。
    ([Pull Request](https://github.com/rails/rails/pull/20668))

*   同步 `#tables` 的行為。
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   已棄用 `SchemaCache#tables`、`SchemaCache#table_exists?` 和
    `SchemaCache#clear_table_cache!`，改用它們的新數據源對應方法。
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   已棄用 SQLite3 和 MySQL 适配器上的 `connection.tables`。
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   已棄用將參數傳遞給 `#tables` - 一些适配器（mysql2、sqlite3）的 `#tables` 方法會返回表和視圖，
    而其他适配器（postgresql）只返回表。為了使它們的行為一致，`#tables` 將來只返回表。
    ([Pull Request](https://github.com/rails/rails/pull/21601))
*   廢棄 `table_exists?` - `#table_exists?` 方法將同時檢查表格和視圖。為了使其行為與 `#tables` 一致，`#table_exists?` 在未來將僅檢查表格。
    ([拉取請求](https://github.com/rails/rails/pull/21601))

*   廢棄將 `offset` 參數傳遞給 `find_nth`。請改用關聯上的 `offset` 方法。
    ([拉取請求](https://github.com/rails/rails/pull/22053))

*   廢棄 `DatabaseStatements` 中的 `{insert|update|delete}_sql`。請改用相應的公共方法 `{insert|update|delete}`。
    ([拉取請求](https://github.com/rails/rails/pull/23086))

*   廢棄 `use_transactional_fixtures`，建議改用 `use_transactional_tests` 以增加清晰度。
    ([拉取請求](https://github.com/rails/rails/pull/19282))

*   廢棄將列傳遞給 `ActiveRecord::Connection#quote`。
    ([提交](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

*   在 `find_in_batches` 中新增了一個 `end` 選項，用於指定批次處理的結束位置。
    ([拉取請求](https://github.com/rails/rails/pull/12257))


### 重要變更

*   在創建表格時，`references` 新增了一個 `foreign_key` 選項。
    ([提交](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

*   新增了屬性 API。
    ([提交](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

*   在 `enum` 定義中新增了 `:_prefix`/`:_suffix` 選項。
    ([拉取請求](https://github.com/rails/rails/pull/19813),
     [拉取請求](https://github.com/rails/rails/pull/20999))

*   在 `ActiveRecord::Relation` 中新增了 `#cache_key` 方法。
    ([拉取請求](https://github.com/rails/rails/pull/20884))

*   將 `timestamps` 的預設 `null` 值更改為 `false`。
    ([提交](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

*   新增了 `ActiveRecord::SecureToken`，用於封裝使用 `SecureRandom` 在模型中生成唯一標記的功能。
    ([拉取請求](https://github.com/rails/rails/pull/18217))

*   為 `drop_table` 新增了 `:if_exists` 選項。
    ([拉取請求](https://github.com/rails/rails/pull/18597))

*   新增了 `ActiveRecord::Base#accessed_fields`，可用於快速查找從模型讀取的字段，以便只選擇所需的數據。
    ([提交](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

*   在 `ActiveRecord::Relation` 上新增了 `#or` 方法，允許使用 OR 運算符組合 WHERE 或 HAVING 子句。
    ([提交](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

*   新增了 `ActiveRecord::Base.suppress`，用於在給定的區塊中阻止接收器被保存。
    ([拉取請求](https://github.com/rails/rails/pull/18910))

*   `belongs_to` 現在默認情況下，如果關聯不存在，將觸發驗證錯誤。您可以使用 `optional: true` 在每個關聯上關閉此功能。同時廢棄 `required` 選項，建議改用 `optional`。
    ([拉取請求](https://github.com/rails/rails/pull/18937))

*   新增了 `config.active_record.dump_schemas` 以配置 `db:structure:dump` 的行為。
    ([拉取請求](https://github.com/rails/rails/pull/19347))

*   新增了 `config.active_record.warn_on_records_fetched_greater_than` 選項。
    ([拉取請求](https://github.com/rails/rails/pull/18846))

*   在 MySQL 中新增了對原生 JSON 數據類型的支持。
    ([拉取請求](https://github.com/rails/rails/pull/21110))

*   在 PostgreSQL 中新增了同時刪除索引的支持。
    ([拉取請求](https://github.com/rails/rails/pull/21317))

*   在連接適配器上新增了 `#views` 和 `#view_exists?` 方法。
    ([拉取請求](https://github.com/rails/rails/pull/21609))

*   新增了 `ActiveRecord::Base.ignored_columns`，用於使某些列在 Active Record 中不可見。
    ([拉取請求](https://github.com/rails/rails/pull/21720))

*   新增了 `connection.data_sources` 和 `connection.data_source_exists?`。這些方法確定可以用於支持 Active Record 模型的關聯（通常是表格和視圖）。
    ([拉取請求](https://github.com/rails/rails/pull/21715))

*   允許夾具文件在 YAML 文件本身中設置模型類。
    ([拉取請求](https://github.com/rails/rails/pull/20574))

*   在生成數據庫遷移時，新增了默認使用 `uuid` 作為主鍵的能力。
    ([拉取請求](https://github.com/rails/rails/pull/21762))
*   新增了 `ActiveRecord::Relation#left_joins` 和 `ActiveRecord::Relation#left_outer_joins` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/12071))

*   新增了 `after_{create,update,delete}_commit` 回調函數。
    ([Pull Request](https://github.com/rails/rails/pull/22516))

*   對遷移類別呈現的 API 進行版本控制，這樣我們就可以更改參數默認值而不會破壞現有的遷移，也不會強制通過棄用週期來重寫它們。
    ([Pull Request](https://github.com/rails/rails/pull/21538))

*   `ApplicationRecord` 是所有應用模型的新超類，類似於應用控制器繼承 `ApplicationController` 而不是 `ActionController::Base`。這為應用程序提供了一個單一的地方來配置應用程序範圍的模型行為。
    ([Pull Request](https://github.com/rails/rails/pull/22567))

*   新增了 ActiveRecord 的 `#second_to_last` 和 `#third_to_last` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   為 PostgreSQL 和 MySQL 新增了對數據庫對象（表、列、索引）的註釋功能，註釋存儲在數據庫元數據中。
    ([Pull Request](https://github.com/rails/rails/pull/22911))

*   為 `mysql2` 适配器添加了預編譯語句支持，適用於 mysql2 0.4.4+，之前僅支持已棄用的 `mysql` 遺留适配器。要啟用此功能，請在 `config/database.yml` 中設置 `prepared_statements: true`。
    ([Pull Request](https://github.com/rails/rails/pull/23461))

*   新增了對關聯對象調用 `ActionRecord::Relation#update` 的能力，這將在關聯中的所有對象上運行驗證和回調。
    ([Pull Request](https://github.com/rails/rails/pull/11898))

*   為 `save` 方法添加了 `:touch` 選項，以便可以在保存記錄時不更新時間戳。
    ([Pull Request](https://github.com/rails/rails/pull/18225))

*   為 PostgreSQL 添加了表達式索引和運算符類支持。
    ([commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))

*   為嵌套屬性的錯誤添加了 `:index_errors` 選項。
    ([Pull Request](https://github.com/rails/rails/pull/19686))

*   支持雙向銷毀依賴。
    ([Pull Request](https://github.com/rails/rails/pull/18548))

*   在事務測試中添加了對 `after_commit` 回調的支持。
    ([Pull Request](https://github.com/rails/rails/pull/18458))

*   添加了 `foreign_key_exists?` 方法，用於查看表上是否存在外鍵。
    ([Pull Request](https://github.com/rails/rails/pull/18662))

*   為 `touch` 方法添加了 `:time` 選項，以便可以使用不同的時間觸發記錄的觸發。
    ([Pull Request](https://github.com/rails/rails/pull/18956))

*   更改事務回調，不再吞噬錯誤。在此更改之前，事務回調中引發的任何錯誤都會被捕獲並打印在日誌中，除非使用（新棄用的）`raise_in_transactional_callbacks = true` 選項。

    現在這些錯誤不再被捕獲，而是直接上升，與其他回調的行為一致。
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

Active Model
------------

詳細更改請參閱 [Changelog][active-model]。

### 刪除

*   刪除了已棄用的 `ActiveModel::Dirty#reset_#{attribute}` 和 `ActiveModel::Dirty#reset_changes` 方法。
    ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

*   刪除了 XML 序列化功能。此功能已提取到 [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) gem 中。
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   刪除了 `ActionController::ModelNaming` 模塊。
    ([Pull Request](https://github.com/rails/rails/pull/18194))

### 棄用

*   棄用了將 `false` 作為停止 Active Model 和 `ActiveModel::Validations` 回調鏈的方法。建議使用 `throw(:abort)`。
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   棄用了具有不一致行為的 `ActiveModel::Errors#get`、`ActiveModel::Errors#set` 和 `ActiveModel::Errors#[]=` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/18634))

*   棄用了 `validates_length_of` 的 `:tokenizer` 選項，改用純 Ruby。
    ([Pull Request](https://github.com/rails/rails/pull/19585))
*   停用了`ActiveModel::Errors#add_on_empty`和`ActiveModel::Errors#add_on_blank`，没有替代方法。
    ([Pull Request](https://github.com/rails/rails/pull/18996))

### 重要更改

*   添加了`ActiveModel::Errors#details`以确定哪个验证器失败。
    ([Pull Request](https://github.com/rails/rails/pull/18322))

*   将`ActiveRecord::AttributeAssignment`提取到`ActiveModel::AttributeAssignment`中，允许将其作为可包含模块用于任何对象。
    ([Pull Request](https://github.com/rails/rails/pull/10776))

*   添加了`ActiveModel::Dirty#[attr_name]_previously_changed?`和`ActiveModel::Dirty#[attr_name]_previous_change`，以改进在模型保存后访问记录的更改。
    ([Pull Request](https://github.com/rails/rails/pull/19847))

*   在`valid?`和`invalid?`上同时验证多个上下文。
    ([Pull Request](https://github.com/rails/rails/pull/21069))

*   将`validates_acceptance_of`的默认值从`1`更改为接受`true`。
    ([Pull Request](https://github.com/rails/rails/pull/18439))

Active Job
-----------

请参考[Changelog][active-job]以获取详细更改信息。

### 重要更改

*   `ActiveJob::Base.deserialize`委托给作业类。这允许作业在序列化时附加任意元数据，并在执行时读取回来。
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*   添加了按作业基础配置队列适配器的能力，而不会相互影响。
    ([Pull Request](https://github.com/rails/rails/pull/16992))

*   生成的作业现在默认继承自`app/jobs/application_job.rb`。
    ([Pull Request](https://github.com/rails/rails/pull/19034))

*   允许`DelayedJob`、`Sidekiq`、`qu`、`que`和`queue_classic`将作业ID作为`provider_job_id`返回给`ActiveJob::Base`。
    ([Pull Request](https://github.com/rails/rails/pull/20064),
     [Pull Request](https://github.com/rails/rails/pull/20056),
     [commit](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

*   实现了一个简单的`AsyncJob`处理器和相关的`AsyncAdapter`，将作业排队到`concurrent-ruby`线程池中。
    ([Pull Request](https://github.com/rails/rails/pull/21257))

*   将默认适配器从内联更改为异步。这是一个更好的默认值，因为测试将不会错误地依赖于同步发生的行为。
    ([commit](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))

Active Support
--------------

请参考[Changelog][active-support]以获取详细更改信息。

### 移除

*   移除了已弃用的`ActiveSupport::JSON::Encoding::CircularReferenceError`。
    ([commit](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

*   移除了已弃用的方法`ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=`和`ActiveSupport::JSON::Encoding.encode_big_decimal_as_string`。
    ([commit](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

*   移除了已弃用的`ActiveSupport::SafeBuffer#prepend`。
    ([commit](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

*   移除了`Kernel`中的已弃用方法。使用`silence_stderr`、`silence_stream`、`capture`和`quietly`。
    ([commit](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

*   移除了已弃用的`active_support/core_ext/big_decimal/yaml_conversions`文件。
    ([commit](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

*   移除了已弃用的方法`ActiveSupport::Cache::Store.instrument`和`ActiveSupport::Cache::Store.instrument=`。
    ([commit](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

*   移除了已弃用的`Class#superclass_delegating_accessor`。使用`Class#class_attribute`代替。
    ([Pull Request](https://github.com/rails/rails/pull/16938))

*   移除了已弃用的`ThreadSafe::Cache`。使用`Concurrent::Map`代替。
    ([Pull Request](https://github.com/rails/rails/pull/21679))

*   移除了`Object#itself`，因为它在Ruby 2.2中已实现。
    ([Pull Request](https://github.com/rails/rails/pull/18244))

### 弃用

*   弃用`MissingSourceFile`，使用`LoadError`代替。
    ([commit](https://github.com/rails/rails/commit/734d97d2))

*   弃用`alias_method_chain`，使用Ruby 2.0引入的`Module#prepend`代替。
    ([Pull Request](https://github.com/rails/rails/pull/19434))

*   弃用`ActiveSupport::Concurrency::Latch`，使用来自concurrent-ruby的`Concurrent::CountDownLatch`。
    ([Pull Request](https://github.com/rails/rails/pull/20866))

*   弃用`number_to_human_size`的`prefix`选项，没有替代方法。
    ([Pull Request](https://github.com/rails/rails/pull/21191))

*   弃用`Module#qualified_const_`，使用内置的`Module#const_`方法。
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*   弃用传递字符串来定义回调。
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*   弃用`ActiveSupport::Cache::Store#namespaced_key`、`ActiveSupport::Cache::MemCachedStore#escape_key`和`ActiveSupport::Cache::FileStore#key_file_path`。使用`normalize_key`代替。
    ([Pull Request](https://github.com/rails/rails/pull/22215),
     [commit](https://github.com/rails/rails/commit/a8f773b0))

*   弃用`ActiveSupport::Cache::LocaleCache#set_cache_value`，使用`write_cache_value`。
    ([Pull Request](https://github.com/rails/rails/pull/22215))
*   不推薦將參數傳遞給 `assert_nothing_raised`。
    ([Pull Request](https://github.com/rails/rails/pull/23789))

*   不推薦使用 `Module.local_constants`，建議改用 `Module.constants(false)`。
    ([Pull Request](https://github.com/rails/rails/pull/23936))


### 重要變更

*   在 `ActiveSupport::MessageVerifier` 中新增了 `#verified` 和 `#valid_message?` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/17727))

*   改變了回呼鏈的停止方式。從現在開始，停止回呼鏈的首選方法是明確地使用 `throw(:abort)`。
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   新增了配置選項 `config.active_support.halt_callback_chains_on_return_false`，用於指定是否可以通過在 'before' 回呼中返回 `false` 來停止 ActiveRecord、ActiveModel 和 ActiveModel::Validations 的回呼鏈。
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   將預設的測試順序從 `:sorted` 改為 `:random`。
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

*   在 `Date`、`Time` 和 `DateTime` 中新增了 `#on_weekend?`、`#on_weekday?`、`#next_weekday` 和 `#prev_weekday` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/18335),
     [Pull Request](https://github.com/rails/rails/pull/23687))

*   在 `Date`、`Time` 和 `DateTime` 中的 `#next_week` 和 `#prev_week` 新增了 `same_time` 選項。
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   在 `Date`、`Time` 和 `DateTime` 中新增了 `#prev_day` 和 `#next_day` 方法，作為 `#yesterday` 和 `#tomorrow` 的對應方法。
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   新增了 `SecureRandom.base58`，用於生成隨機的 base58 字串。
    ([commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b))

*   在 `ActiveSupport::TestCase` 中新增了 `file_fixture`。它提供了一個簡單的機制，在測試案例中訪問樣本文件。
    ([Pull Request](https://github.com/rails/rails/pull/18658))

*   在 `Enumerable` 和 `Array` 上新增了 `#without` 方法，用於返回不包含指定元素的可枚舉對象的副本。
    ([Pull Request](https://github.com/rails/rails/pull/19157))

*   新增了 `ActiveSupport::ArrayInquirer` 和 `Array#inquiry`。
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   新增了 `ActiveSupport::TimeZone#strptime`，允許按照指定時區解析時間。
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

*   在 `Integer` 中新增了 `#positive?` 和 `#negative?` 查詢方法，類似於 `#zero?`。
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

*   在 `ActiveSupport::OrderedOptions` 的 get 方法中新增了驚嘆號版本，如果值為 `.blank?`，則會引發 `KeyError`。
    ([Pull Request](https://github.com/rails/rails/pull/20208))

*   新增了 `Time.days_in_year`，返回指定年份的天數，如果沒有提供參數，則返回當前年份的天數。
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

*   新增了一個事件驅動的文件監視器，用於異步檢測應用程式源代碼、路由、本地化等的變化。
    ([Pull Request](https://github.com/rails/rails/pull/22254))

*   為聲明每個線程獨立的類和模塊變量，新增了 `thread_m/cattr_accessor/reader/writer` 一系列方法。
    ([Pull Request](https://github.com/rails/rails/pull/22630))

*   在 `Array` 中新增了 `#second_to_last` 和 `#third_to_last` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   公開了 `ActiveSupport::Executor` 和 `ActiveSupport::Reloader` 的 API，允許組件和庫管理和參與應用程式代碼的執行和應用程式重新加載過程。
    ([Pull Request](https://github.com/rails/rails/pull/23807))

*   `ActiveSupport::Duration` 現在支援 ISO8601 格式化和解析。
    ([Pull Request](https://github.com/rails/rails/pull/16917))

*   當啟用 `parse_json_times` 時，`ActiveSupport::JSON.decode` 現在支援解析 ISO8601 本地時間。
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   `ActiveSupport::JSON.decode` 現在會返回 `Date` 對象，而不是日期字符串。
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   在 `TaggedLogging` 中新增了能夠多次實例化記錄器的功能，以便它們不共享標籤。
    ([Pull Request](https://github.com/rails/rails/pull/9065))
貢獻者
-------

請參閱[Rails的完整貢獻者清單](https://contributors.rubyonrails.org/)，感謝所有花費許多時間打造Rails這個穩定且強大框架的人們。向他們致敬。

[railties]:       https://github.com/rails/rails/blob/5-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-0-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
