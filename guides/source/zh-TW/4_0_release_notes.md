**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b21dbc892c0a841f1bc1fafdf5ee0126
Ruby on Rails 4.0 發行說明
===============================

Rails 4.0 的亮點：

* 偏好 Ruby 2.0；需要 1.9.3+
* 強參數（Strong Parameters）
* Turbolinks
* 俄羅斯娃娃快取（Russian Doll Caching）

這些發行說明僅涵蓋主要更改。要了解各種錯誤修復和更改，請參閱變更日誌或查看 GitHub 上主要 Rails 存儲庫的[提交列表](https://github.com/rails/rails/commits/4-0-stable)。

--------------------------------------------------------------------------------

升級到 Rails 4.0
----------------------

如果您正在升級現有應用程序，建議在進行之前擁有良好的測試覆蓋率。您還應該先升級到 Rails 3.2（如果尚未升級），並確保您的應用程序在預期的情況下運行，然後再嘗試升級到 Rails 4.0。在[升級 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0)指南中提供了升級時需要注意的事項清單。


創建 Rails 4.0 應用程序
--------------------------------

```bash
# 您應該已經安裝了 'rails' RubyGem
$ rails new myapp
$ cd myapp
```

### 捆綁 Gems

Rails 現在使用應用程序根目錄中的 `Gemfile` 來確定您的應用程序啟動所需的 Gems。這個 `Gemfile` 由 [Bundler](https://github.com/carlhuda/bundler) gem 處理，然後安裝所有依賴項。它甚至可以將所有依賴項本地安裝到您的應用程序中，以便它不依賴於系統 Gems。

更多信息：[Bundler 主頁](https://bundler.io)

### 生活在邊緣

`Bundler` 和 `Gemfile` 使得使用新的專用 `bundle` 命令凍結您的 Rails 應用程序變得非常簡單。如果您想直接從 Git 存儲庫捆綁，可以使用 `--edge` 標誌：

```bash
$ rails new myapp --edge
```

如果您有一個本地的 Rails 存儲庫並且想要使用它生成應用程序，可以使用 `--dev` 標誌：

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

主要功能
--------------

[![Rails 4.0](images/4_0_release_notes/rails4_features.png)](https://guides.rubyonrails.org/images/4_0_release_notes/rails4_features.png)

### 升級

* **Ruby 1.9.3**（[提交](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)）- 偏好 Ruby 2.0；需要 1.9.3+
* **[新的棄用策略](https://www.youtube.com/watch?v=z6YgD6tVPQs)** - Rails 4.0 中的棄用功能是警告，將在 Rails 4.1 中刪除。
* **ActionPack 頁面和動作快取**（[提交](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)）- 頁面和動作快取被提取到單獨的 gem 中。頁面和動作快取需要太多手動干預（在底層模型對象更新時手動過期快取）。請改用俄羅斯娃娃快取。
* **ActiveRecord 觀察者**（[提交](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)）- 觀察者被提取到單獨的 gem 中。觀察者僅在頁面和動作快取中需要，並可能導致混亂的代碼。
* **ActiveRecord 會話存儲**（[提交](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)）- ActiveRecord 會話存儲被提取到單獨的 gem 中。在 SQL 中存儲會話是昂貴的。請改用 cookie 會話、memcache 會話或自定義會話存儲。
* **ActiveModel 大量賦值保護**（[提交](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)）- Rails 3 大量賦值保護已棄用。請改用強參數。
* **ActiveResource**（[提交](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)）- ActiveResource 被提取到單獨的 gem 中。ActiveResource 的使用不廣泛。
* **移除 vendor/plugins**（[提交](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)）- 使用 `Gemfile` 管理已安裝的 Gems。
### ActionPack

* **Strong parameters** ([commit](https://github.com/rails/rails/commit/a8f6d5c6450a7fe058348a7f10a908352bb6c7fc)) - 只允許允許的參數更新模型物件 (`params.permit(:title, :text)`).
* **Routing concerns** ([commit](https://github.com/rails/rails/commit/0dd24728a088fcb4ae616bb5d62734aca5276b1b)) - 在路由 DSL 中，將常見的子路由因子化 (`comments` 從 `/posts/1/comments` 和 `/videos/1/comments` 中)。
* **ActionController::Live** ([commit](https://github.com/rails/rails/commit/af0a9f9eefaee3a8120cfd8d05cbc431af376da3)) - 使用 `response.stream` 串流 JSON。
* **Declarative ETags** ([commit](https://github.com/rails/rails/commit/ed5c938fa36995f06d4917d9543ba78ed506bb8d)) - 添加控制器層級的 etag 添加，將成為動作 etag 計算的一部分。
* **[Russian doll caching](https://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)** ([commit](https://github.com/rails/rails/commit/4154bf012d2bec2aae79e4a49aa94a70d3e91d49)) - 緩存視圖的嵌套片段。每個片段根據一組依賴項（緩存鍵）過期。緩存鍵通常是模板版本號和模型物件。
* **Turbolinks** ([commit](https://github.com/rails/rails/commit/e35d8b18d0649c0ecc58f6b73df6b3c8d0c6bb74)) - 只提供一個初始的 HTML 頁面。當用戶導航到另一個頁面時，使用 pushState 更新 URL，並使用 AJAX 更新標題和內容。
* **將 ActionView 與 ActionController 解耦** ([commit](https://github.com/rails/rails/commit/78b0934dd1bb84e8f093fb8ef95ca99b297b51cd)) - ActionView 被解耦自 ActionPack，並將在 Rails 4.1 中移至獨立的 gem 中。
* **不依賴於 ActiveModel** ([commit](https://github.com/rails/rails/commit/166dbaa7526a96fdf046f093f25b0a134b277a68)) - ActionPack 不再依賴於 ActiveModel。

### General

 * **ActiveModel::Model** ([commit](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)) - `ActiveModel::Model`，一個 mixin，使普通的 Ruby 物件可以直接與 ActionPack 一起使用（例如 `form_for`）。
 * **新的 scope API** ([commit](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)) - Scopes 必須始終使用可調用對象。
 * **Schema cache dump** ([commit](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)) - 為了改善 Rails 的啟動時間，不再直接從數據庫加載模式，而是從備份文件中加載模式。
 * **支援指定事務隔離級別** ([commit](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)) - 選擇可重複讀取或改善性能（較少鎖定）哪個更重要。
 * **Dalli** ([commit](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)) - 使用 Dalli memcache 客戶端作為 memcache 存儲。
 * **通知開始和結束** ([commit](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)) - Active Support 儀表板向訂閱者報告開始和結束通知。
 * **默認線程安全** ([commit](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)) - Rails 可以在多線程應用程序服務器中運行，無需額外配置。

注意：請確認您使用的 gem 是線程安全的。

 * **PATCH 動詞** ([commit](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)) - 在 Rails 中，PATCH 取代了 PUT。PATCH 用於部分更新資源。

### Security

* **match 不再捕獲所有** ([commit](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)) - 在路由 DSL 中，match 需要指定 HTTP 動詞或動詞。
* **預設情況下對 HTML 實體進行轉義** ([commit](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)) - 在 erb 中呈現的字符串將被轉義，除非使用 `raw` 包裹或調用 `html_safe`。
* **新的安全標頭** ([commit](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)) - Rails 對每個 HTTP 請求都發送以下標頭：`X-Frame-Options`（禁止瀏覽器將頁面嵌入框架以防止點擊劫持），`X-XSS-Protection`（要求瀏覽器停止腳本注入）和 `X-Content-Type-Options`（防止瀏覽器將 jpeg 文件打開為 exe）。
將功能提取到gems中
---------------------------

在Rails 4.0中，有幾個功能已經被提取到gems中。您只需將提取的gems添加到您的`Gemfile`中，即可恢復功能。

* 基於哈希和動態查找方法（[GitHub](https://github.com/rails/activerecord-deprecated_finders)）
* 在Active Record模型中的賦值保護（[GitHub](https://github.com/rails/protected_attributes)，[Pull Request](https://github.com/rails/rails/pull/7251)）
* ActiveRecord::SessionStore（[GitHub](https://github.com/rails/activerecord-session_store)，[Pull Request](https://github.com/rails/rails/pull/7436)）
* Active Record觀察者（[GitHub](https://github.com/rails/rails-observers)，[Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2)）
* Active Resource（[GitHub](https://github.com/rails/activeresource)，[Pull Request](https://github.com/rails/rails/pull/572)，[Blog](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource)）
* Action Caching（[GitHub](https://github.com/rails/actionpack-action_caching)，[Pull Request](https://github.com/rails/rails/pull/7833)）
* Page Caching（[GitHub](https://github.com/rails/actionpack-page_caching)，[Pull Request](https://github.com/rails/rails/pull/7833)）
* Sprockets（[GitHub](https://github.com/rails/sprockets-rails)）
* 性能測試（[GitHub](https://github.com/rails/rails-perftest)，[Pull Request](https://github.com/rails/rails/pull/8876)）

文檔
-------------

* 指南以GitHub Flavored Markdown重寫。

* 指南具有響應式設計。

Railties
--------

詳細更改請參閱[Changelog](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md)。

### 重要更改

* 新的測試位置`test/models`，`test/helpers`，`test/controllers`和`test/mailers`。相應的rake任務也已添加。 （[Pull Request](https://github.com/rails/rails/pull/7878)）

* 應用程序的可執行文件現在位於`bin/`目錄中。運行`rake rails:update:bin`以獲取`bin/bundle`，`bin/rails`和`bin/rake`。

* 默認啟用線程安全

* 通過將`--builder`（或`-b`）傳遞給`rails new`來使用自定義構建器的能力已被刪除。請考慮使用應用程序模板。 （[Pull Request](https://github.com/rails/rails/pull/9401)）

### 廢棄

* `config.threadsafe!`已被廢棄，建議使用`config.eager_load`，它可以更細粒度地控制何時進行急切加載。

* `Rails::Plugin`已經被刪除。不要將插件添加到`vendor/plugins`中，請使用gems或具有路徑或git依賴關係的bundler。

Action Mailer
-------------

詳細更改請參閱[Changelog](https://github.com/rails/rails/blob/4-0-stable/actionmailer/CHANGELOG.md)。

### 重要更改

### 廢棄

Active Model
------------

詳細更改請參閱[Changelog](https://github.com/rails/rails/blob/4-0-stable/activemodel/CHANGELOG.md)。

### 重要更改

* 添加`ActiveModel::ForbiddenAttributesProtection`，一個簡單的模塊，用於在傳遞非允許的屬性時保護屬性免受大量賦值。

* 添加`ActiveModel::Model`，一個混入，使Ruby對象能夠與Action Pack無縫配合。

### 廢棄

Active Support
--------------

詳細更改請參閱[Changelog](https://github.com/rails/rails/blob/4-0-stable/activesupport/CHANGELOG.md)。

### 重要更改

* 將已棄用的`memcache-client` gem替換為`ActiveSupport::Cache::MemCacheStore`中的`dalli`。

* 優化`ActiveSupport::Cache::Entry`以減少內存和處理開銷。

* 可以根據區域設定定義變形。 `singularize`和`pluralize`接受區域作為額外參數。

* 如果接收對象未實現該方法，`Object#try`現在將返回nil而不是引發NoMethodError，但您仍然可以使用新的`Object#try!`獲得舊的行為。

* 當給定無效日期時，`String#to_date`現在引發`ArgumentError: invalid date`而不是`NoMethodError: undefined method 'div' for nil:NilClass`。它現在與`Date.parse`相同，並且接受比3.x更多的無效日期，例如：
```ruby
# ActiveSupport 3.x
"asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
"333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

# ActiveSupport 4
"asdf".to_date # => ArgumentError: invalid date
"333".to_date # => Fri, 29 Nov 2013
```

### 廢棄項目

* 廢棄 `ActiveSupport::TestCase#pending` 方法，改用 minitest 的 `skip` 方法。

* `ActiveSupport::Benchmarkable#silence` 已被廢棄，因為它缺乏線程安全性。在 Rails 4.1 中將被刪除，不會有替代方法。

* `ActiveSupport::JSON::Variable` 已被廢棄。請為自定義的 JSON 字串文字定義自己的 `#as_json` 和 `#encode_json` 方法。

* 廢棄了相容性方法 `Module#local_constant_names`，改用 `Module#local_constants`（返回符號）。

* `ActiveSupport::BufferedLogger` 已被廢棄。使用 `ActiveSupport::Logger` 或 Ruby 標準庫中的日誌記錄器。

* 廢棄 `assert_present` 和 `assert_blank`，改用 `assert object.blank?` 和 `assert object.present?`

Action Pack
-----------

詳細變更請參閱 [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md)。

### 重要變更

* 改變開發模式下異常頁面的樣式表。同時在所有異常頁面中顯示引發異常的程式碼行和片段。

### 廢棄項目


Active Record
-------------

詳細變更請參閱 [Changelog](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md)。

### 重要變更

* 改進了編寫 `change` 遷移的方式，不再需要舊的 `up` 和 `down` 方法。

    * `drop_table` 和 `remove_column` 方法現在是可逆的，只要提供必要的信息。
      `remove_column` 方法以前接受多個列名，現在改用 `remove_columns`（不可逆）。
      `change_table` 方法也是可逆的，只要其塊不調用 `remove`、`change` 或 `change_default`

    * 新的 `reversible` 方法可以指定在遷移上或下遷移時要運行的代碼。
      請參閱 [遷移指南](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#using-reversible)

    * 新的 `revert` 方法將還原整個遷移或給定的塊。
      如果向下遷移，則正常運行給定的遷移/塊。
      請參閱 [遷移指南](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#reverting-previous-migrations)

* 添加了對 PostgreSQL 陣列類型的支援。可以使用任何數據類型來創建陣列列，並提供完整的遷移和模式轉儲支援。

* 添加了 `Relation#load` 方法，用於顯式加載記錄並返回 `self`。

* `Model.all` 現在返回一個 `ActiveRecord::Relation`，而不是記錄的數組。如果真的需要數組，請使用 `Relation#to_a`。在某些特定情況下，這可能導致升級時出現問題。

* 添加了 `ActiveRecord::Migration.check_pending!`，如果有待遷移，則引發錯誤。

* 為 `ActiveRecord::Store` 添加了自定義編碼器支援。現在可以像這樣設置自定義編碼器：

        store :settings, accessors: [ :color, :homepage ], coder: JSON
* `mysql` 和 `mysql2` 的連接默認會設置 `SQL_MODE=STRICT_ALL_TABLES`，以避免靜默數據丟失。可以通過在 `database.yml` 中指定 `strict: false` 來禁用此功能。

* 刪除 IdentityMap。

* 刪除自動執行 EXPLAIN 查詢的功能。選項 `active_record.auto_explain_threshold_in_seconds` 不再使用，應該刪除。

* 添加 `ActiveRecord::NullRelation` 和 `ActiveRecord::Relation#none`，實現關聯類的空對象模式。

* 添加 `create_join_table` 遷移助手，用於創建 HABTM 關聯表。

* 允許創建 PostgreSQL hstore 記錄。

### 廢棄功能

* 廢棄了舊式的基於哈希的查詢 API。這意味著以前接受“查詢選項”的方法不再接受。

* 所有動態方法（除了 `find_by_...` 和 `find_by_...!`）都已廢棄。以下是如何重寫代碼：

      * `find_all_by_...` 可以使用 `where(...)` 重寫。
      * `find_last_by_...` 可以使用 `where(...).last` 重寫。
      * `scoped_by_...` 可以使用 `where(...)` 重寫。
      * `find_or_initialize_by_...` 可以使用 `find_or_initialize_by(...)` 重寫。
      * `find_or_create_by_...` 可以使用 `find_or_create_by(...)` 重寫。
      * `find_or_create_by_...!` 可以使用 `find_or_create_by!(...)` 重寫。

貢獻者
-------

請參閱[Rails的完整貢獻者列表](https://contributors.rubyonrails.org/)，感謝所有花費了許多時間使Rails成為穩定且強大的框架的人。向他們致敬。
