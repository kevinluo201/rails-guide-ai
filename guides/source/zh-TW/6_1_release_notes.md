**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 1d652e6ccda9c901ca3f6a003c95f83e
Ruby on Rails 6.1 發行說明
===============================

Rails 6.1 的亮點：

* 每個資料庫連線切換
* 水平分片
* 嚴格載入關聯
* 委派類型
* 非同步刪除關聯

這些發行說明僅涵蓋主要更改。要了解各種錯誤修復和更改，請參閱變更日誌或查看 GitHub 上主要 Rails 存儲庫中的[提交清單](https://github.com/rails/rails/commits/6-1-stable)。

--------------------------------------------------------------------------------

升級到 Rails 6.1
----------------------

如果您正在升級現有應用程式，建議在進行升級之前先進行良好的測試覆蓋率。如果尚未升級到 Rails 6.0，請先升級到該版本，並確保應用程式運行正常，然後再嘗試升級到 Rails 6.1。在升級時需要注意的事項清單可在[升級 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-0-to-rails-6-1)指南中找到。

主要功能
--------------

### 每個資料庫連線切換

Rails 6.1 提供了[每個資料庫連線切換](https://github.com/rails/rails/pull/40370)的功能。在 6.0 中，如果您切換到 `reading` 角色，則所有資料庫連線也會切換到讀取角色。現在在 6.1 中，如果您在配置中將 `legacy_connection_handling` 設置為 `false`，Rails 將允許您通過在相應的抽象類上調用 `connected_to` 來切換單個資料庫的連線。

### 水平分片

Rails 6.0 提供了對資料庫進行功能性分割（多個分割，不同的架構）的能力，但無法支援水平分片（相同的架構，多個分割）。Rails 無法支援水平分片，因為 Active Record 中的模型每個角色每個類只能有一個連線。現在這個問題已經修復，Rails 支援[水平分片](https://github.com/rails/rails/pull/38531)。

### 嚴格載入關聯

[嚴格載入關聯](https://github.com/rails/rails/pull/37400)允許您確保所有關聯都被急切載入，並在發生 N+1 問題之前停止它們。

### 委派類型

[委派類型](https://github.com/rails/rails/pull/39341)是單表繼承的一種替代方案。它有助於表示類層次結構，允許超類成為具體類，並由自己的表來表示。每個子類都有自己的表用於額外的屬性。

### 非同步刪除關聯

[非同步刪除關聯](https://github.com/rails/rails/pull/40157)增加了應用程式在後台作業中刪除關聯的能力。這有助於在刪除數據時避免超時和其他性能問題。

Railties
--------

詳細更改請參閱[變更日誌][railties]。

### 刪除

*   刪除已棄用的 `rake notes` 任務。

*   刪除 `rails dbconsole` 命令中已棄用的 `connection` 選項。

*   刪除 `rails notes` 中對 `SOURCE_ANNOTATION_DIRECTORIES` 環境變數的支援。

*   刪除 `rails server` 命令中已棄用的 `server` 參數。

[railties]: https://github.com/rails/rails/blob/6-1-stable/railties/CHANGELOG.md
*   移除對使用`HOST`環境變數來指定伺服器IP的支援。

*   移除已棄用的`rake dev:cache`任務。

*   移除已棄用的`rake routes`任務。

*   移除已棄用的`rake initializers`任務。

### 已棄用功能

### 重要變更

Action Cable
------------

詳細變更請參閱[變更日誌][action-cable]。

### 移除功能

### 已棄用功能

### 重要變更

Action Pack
-----------

詳細變更請參閱[變更日誌][action-pack]。

### 移除功能

*   移除已棄用的`ActionDispatch::Http::ParameterFilter`。

*   移除已棄用的控制器層級`force_ssl`。

### 已棄用功能

*   已棄用`config.action_dispatch.return_only_media_type_on_content_type`。

### 重要變更

*   將`ActionDispatch::Response#content_type`變更為返回完整的Content-Type標頭。

Action View
-----------

詳細變更請參閱[變更日誌][action-view]。

### 移除功能

*   移除`ActionView::Template::Handlers::ERB`中的已棄用`escape_whitelist`。

*   移除`ActionView::Resolver`中的已棄用`find_all_anywhere`。

*   移除`ActionView::Template::HTML`中的已棄用`formats`。

*   移除`ActionView::Template::RawFile`中的已棄用`formats`。

*   移除`ActionView::Template::Text`中的已棄用`formats`。

*   移除`ActionView::PathSet`中的已棄用`find_file`。

*   移除`ActionView::LookupContext`中的已棄用`rendered_format`。

*   移除`ActionView::ViewPaths`中的已棄用`find_file`。

*   移除在`ActionView::Base#initialize`的第一個參數中傳遞非`ActionView::LookupContext`對象的支援。

*   移除`ActionView::Base#initialize`中的已棄用`format`參數。

*   移除已棄用的`ActionView::Template#refresh`。

*   移除已棄用的`ActionView::Template#original_encoding`。

*   移除已棄用的`ActionView::Template#variants`。

*   移除已棄用的`ActionView::Template#formats`。

*   移除已棄用的`ActionView::Template#virtual_path=`。

*   移除已棄用的`ActionView::Template#updated_at`。

*   移除`ActionView::Template#initialize`中需要的已棄用`updated_at`參數。

*   移除已棄用的`ActionView::Template.finalize_compiled_template_methods`。

*   移除已棄用的`config.action_view.finalize_compiled_template_methods`。

*   移除對使用塊調用`ActionView::ViewPaths#with_fallback`的支援。

*   移除對將絕對路徑傳遞給`render template:`的支援。

*   移除對將相對路徑傳遞給`render file:`的支援。

*   移除不接受兩個參數的模板處理程序支援。

*   移除`ActionView::Template::PathResolver`中的已棄用模式參數。

*   移除在某些視圖幫助程序中從對象調用私有方法的支援。

### 已棄用功能

### 重要變更

*   要求`ActionView::Base`的子類實現`#compiled_method_container`。

*   在`ActionView::Template#initialize`中要求`locals`參數。

*   `javascript_include_tag`和`stylesheet_link_tag`資源輔助程序生成了一個`Link`標頭，向現代瀏覽器提供有關預加載資源的提示。可以通過將`config.action_view.preload_links_header`設置為`false`來禁用此功能。

Action Mailer
-------------

詳細變更請參閱[變更日誌][action-mailer]。

### 移除功能

*   移除`ActionMailer::Base.receive`，改用[Action Mailbox](https://github.com/rails/rails/tree/6-1-stable/actionmailbox)。

### 已棄用功能

### 重要變更

Active Record
-------------

詳細變更請參閱[變更日誌][active-record]。

### 移除功能

*   從`ActiveRecord::ConnectionAdapters::DatabaseLimits`中移除已棄用的方法。

    `column_name_length`
    `table_name_length`
    `columns_per_table`
    `indexes_per_table`
    `columns_per_multicolumn_index`
    `sql_query_length`
    `joins_per_query`

*   移除`ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_multi_insert?`的已棄用。

*   移除`ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_foreign_keys_in_create?`的已棄用。

*   移除`ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_ranges?`的已棄用。
*   移除已棄用的 `ActiveRecord::Base#update_attributes` 和 `ActiveRecord::Base#update_attributes!`。

*   移除 `ActiveRecord::ConnectionAdapter::SchemaStatements#assume_migrated_upto_version` 中已棄用的 `migrations_path` 參數。

*   移除已棄用的 `config.active_record.sqlite3.represent_boolean_as_integer`。

*   從 `ActiveRecord::DatabaseConfigurations` 中移除已棄用的方法。

    `fetch`
    `each`
    `first`
    `values`
    `[]=`

*   移除已棄用的 `ActiveRecord::Result#to_hash` 方法。

*   移除在 `ActiveRecord::Relation` 方法中使用不安全的原始 SQL 的已棄用支援。

### 已棄用功能

*   已棄用 `ActiveRecord::Base.allow_unsafe_raw_sql`。

*   已棄用 `connected_to` 上的 `database` 參數。

*   當 `legacy_connection_handling` 設為 false 時，已棄用 `connection_handlers`。

### 重要變更

*   MySQL：唯一性驗證器現在尊重預設的資料庫排序規則，不再預設強制區分大小寫的比較。

*   `relation.create` 在初始化區塊和回呼中不再洩漏範圍給類級別的查詢方法。

    之前：

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => nil
    end
    ```

    之後：

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => #<User name: "David", ...>
    end
    ```

*   命名範圍鏈不再洩漏範圍給類級別的查詢方法。

    ```ruby
    class User < ActiveRecord::Base
      scope :david, -> { User.where(name: "David") }
    end
    ```

    之前：

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'John' AND name = 'David'
    ```

    之後：

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'David'
    ```

*   `where.not` 現在生成 NAND 謂詞，而不是 NOR。

    之前：

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE name != 'Jon' AND role != 'admin'
    ```

    之後：

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE NOT (name = 'Jon' AND role = 'admin')
    ```

*   要使用新的每個資料庫連線處理方式，應將 `legacy_connection_handling` 設為 false，並移除 `connection_handlers` 上的已棄用存取器。`connects_to` 和 `connected_to` 的公開方法不需要更改。

Active Storage
--------------

詳細變更請參閱 [Changelog][active-storage]。

### 移除功能

*   移除將 `:combine_options` 操作傳遞給 `ActiveStorage::Transformers::ImageProcessing` 的已棄用支援。

*   移除已棄用的 `ActiveStorage::Transformers::MiniMagickTransformer`。

*   移除已棄用的 `config.active_storage.queue`。

*   移除已棄用的 `ActiveStorage::Downloading`。

### 已棄用功能

*   已棄用 `Blob.create_after_upload`，改用 `Blob.create_and_upload`。
    ([Pull Request](https://github.com/rails/rails/pull/34827))

### 重要變更

*   新增 `Blob.create_and_upload`，用於創建新的 blob 並將給定的 `io` 上傳到服務器。
    ([Pull Request](https://github.com/rails/rails/pull/34827))
*   新增 `ActiveStorage::Blob#service_name` 欄位。升級後需要運行遷移。運行 `bin/rails app:update` 以生成該遷移。

Active Model
------------

詳細變更請參閱 [Changelog][active-model]。

### 移除功能

### 已棄用功能

### 重要變更

*   Active Model 的錯誤現在是具有介面的物件，允許應用程式更輕鬆地處理和交互模型拋出的錯誤。
    [此功能](https://github.com/rails/rails/pull/32313) 包括查詢介面、更精確的測試和訪問錯誤詳細資訊。
主動支援
--------------

詳細更改請參閱[變更日誌][active-support]。

### 刪除

*   刪除當`config.i18n.fallbacks`為空時，不再回退到`I18n.default_locale`的過時回退。

*   刪除過時的`LoggerSilence`常數。

*   刪除過時的`ActiveSupport::LoggerThreadSafeLevel#after_initialize`。

*   刪除過時的`Module#parent_name`、`Module#parent`和`Module#parents`。

*   刪除過時的文件`active_support/core_ext/module/reachable`。

*   刪除過時的文件`active_support/core_ext/numeric/inquiry`。

*   刪除過時的文件`active_support/core_ext/array/prepend_and_append`。

*   刪除過時的文件`active_support/core_ext/hash/compact`。

*   刪除過時的文件`active_support/core_ext/hash/transform_values`。

*   刪除過時的文件`active_support/core_ext/range/include_range`。

*   刪除過時的`ActiveSupport::Multibyte::Chars#consumes?`和`ActiveSupport::Multibyte::Chars#normalize`。

*   刪除過時的`ActiveSupport::Multibyte::Unicode.pack_graphemes`、
    `ActiveSupport::Multibyte::Unicode.unpack_graphemes`、
    `ActiveSupport::Multibyte::Unicode.normalize`、
    `ActiveSupport::Multibyte::Unicode.downcase`、
    `ActiveSupport::Multibyte::Unicode.upcase`和`ActiveSupport::Multibyte::Unicode.swapcase`。

*   刪除過時的`ActiveSupport::Notifications::Instrumenter#end=`。

### 過時

*   過時的`ActiveSupport::Multibyte::Unicode.default_normalization_form`。

### 重要更改

主動工作
----------

詳細更改請參閱[變更日誌][active-job]。

### 刪除

### 過時

*   過時的`config.active_job.return_false_on_aborted_enqueue`。

### 重要更改

*   當排程工作被中止時，返回`false`。

動作文字
----------

詳細更改請參閱[變更日誌][action-text]。

### 刪除

### 過時

### 重要更改

*   通過在豐富文字屬性名稱後添加`?`來確認豐富文字內容是否存在的方法。
    （[拉取請求](https://github.com/rails/rails/pull/37951)）

*   添加`fill_in_rich_text_area`系統測試案例輔助方法，以查找trix編輯器並填充指定的HTML內容。
    （[拉取請求](https://github.com/rails/rails/pull/35885)）

*   添加`ActionText::FixtureSet.attachment`以在數據庫固定裝置中生成`<action-text-attachment>`元素。
    （[拉取請求](https://github.com/rails/rails/pull/40289)）

動作郵件箱
----------

詳細更改請參閱[變更日誌][action-mailbox]。

### 刪除

### 過時

*   過時的`Rails.application.credentials.action_mailbox.api_key`和`MAILGUN_INGRESS_API_KEY`，改用`Rails.application.credentials.action_mailbox.signing_key`和`MAILGUN_INGRESS_SIGNING_KEY`。

### 重要更改

Ruby on Rails 指南
--------------------

詳細更改請參閱[變更日誌][guides]。

### 重要更改

貢獻者
-------

請參閱[完整的 Rails 貢獻者列表](https://contributors.rubyonrails.org/)，感謝所有花費許多時間使 Rails 成為穩定且強大的框架的人們。向他們致敬。

[railties]:       https://github.com/rails/rails/blob/6-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-1-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/6-1-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-1-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-1-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-1-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/6-1-stable/actionmailbox/CHANGELOG.md
