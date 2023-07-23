**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b1c2c8ad5c4bacb2e3b92aa320c4da3d
Ruby on Rails 6.0 發行說明
===============================

Rails 6.0 的亮點：

* Action Mailbox
* Action Text
* 平行測試
* Action Cable 測試

這些發行說明僅涵蓋主要更改。要了解各種錯誤修復和更改，請參閱變更日誌或查看 GitHub 上主要 Rails 存儲庫中的[提交列表](https://github.com/rails/rails/commits/6-0-stable)。

--------------------------------------------------------------------------------

升級到 Rails 6.0
----------------------

如果您正在升級現有應用程序，建議在進行升級之前先進行良好的測試覆蓋。如果您尚未進行升級，請先升級到 Rails 5.2，並確保應用程序在預期的情況下運行正常，然後再嘗試升級到 Rails 6.0。在升級時要注意的事項列表可在[升級 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-2-to-rails-6-0)指南中找到。

主要功能
--------------

### Action Mailbox

[拉取請求](https://github.com/rails/rails/pull/34786)

[Action Mailbox](https://github.com/rails/rails/tree/6-0-stable/actionmailbox) 允許您將傳入的電子郵件路由到類似控制器的郵箱。您可以在[Action Mailbox 基礎知識](action_mailbox_basics.html)指南中了解更多關於 Action Mailbox 的資訊。

### Action Text

[拉取請求](https://github.com/rails/rails/pull/34873)

[Action Text](https://github.com/rails/rails/tree/6-0-stable/actiontext) 將豐富的文字內容和編輯功能引入 Rails。它包括 [Trix 編輯器](https://trix-editor.org)，該編輯器可以處理格式設定、連結、引用、列表、嵌入圖片和圖庫等所有內容。Trix 編輯器生成的豐富文字內容保存在自己的 RichText 模型中，該模型與應用程序中的任何現有 Active Record 模型相關聯。任何嵌入的圖片（或其他附件）都會使用 Active Storage 自動存儲並與包含的 RichText 模型相關聯。

您可以在[Action Text 概述](action_text_overview.html)指南中了解更多關於 Action Text 的資訊。

### 平行測試

[拉取請求](https://github.com/rails/rails/pull/31900)

[平行測試](testing.html#parallel-testing) 允許您將測試套件進行平行化。雖然分叉進程是默認方法，但也支持線程。平行運行測試可以減少整個測試套件運行所需的時間。

### Action Cable 測試

[拉取請求](https://github.com/rails/rails/pull/33659)

[Action Cable 測試工具](testing.html#testing-action-cable) 允許您在任何級別測試 Action Cable 功能：連接、通道、廣播。

Railties
--------

詳細更改請參閱[變更日誌][railties]。

### 刪除

*   刪除插件模板中已棄用的 `after_bundle` 輔助方法。
    ([提交](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

*   刪除使用應用程序類作為 `run` 方法參數的已棄用 `config.ru` 支援。
    ([提交](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))

*   刪除 rails 命令中已棄用的 `environment` 參數。
    ([提交](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

*   刪除生成器和模板中已棄用的 `capify!` 方法。
    ([提交](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

*   刪除已棄用的 `config.secret_token`。
    ([提交](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### 已棄用

*   將 Rack 伺服器名稱作為常規參數傳遞給 `rails server` 已棄用。
    ([拉取請求](https://github.com/rails/rails/pull/32058))
*   停止支援使用`HOST`環境變數來指定伺服器IP。
    ([拉取請求](https://github.com/rails/rails/pull/32540))

*   停止使用非符號鍵訪問`config_for`返回的哈希。
    ([拉取請求](https://github.com/rails/rails/pull/35198))

### 重要變更

*   為`rails server`命令添加一個明確的選項`--using`或`-u`來指定伺服器。
    ([拉取請求](https://github.com/rails/rails/pull/32058))

*   添加查看`rails routes`輸出的擴展格式的功能。
    ([拉取請求](https://github.com/rails/rails/pull/32130))

*   使用內聯Active Job adapter運行種子資料庫任務。
    ([拉取請求](https://github.com/rails/rails/pull/34953))

*   添加一個命令`rails db:system:change`來更改應用程序的資料庫。
    ([拉取請求](https://github.com/rails/rails/pull/34832))

*   添加`rails test:channels`命令，僅測試Action Cable通道。
    ([拉取請求](https://github.com/rails/rails/pull/34947))

*   引入防止DNS重綁定攻擊的保護。
    ([拉取請求](https://github.com/rails/rails/pull/33145))

*   添加在生成器命令運行失敗時中止的功能。
    ([拉取請求](https://github.com/rails/rails/pull/34420))

*   將Webpacker設置為Rails 6的默認JavaScript編譯器。
    ([拉取請求](https://github.com/rails/rails/pull/33079))

*   為`rails db:migrate:status`命令添加對多個資料庫的支援。
    ([拉取請求](https://github.com/rails/rails/pull/34137))

*   在生成器中添加使用多個資料庫的不同遷移路徑的支援。
    ([拉取請求](https://github.com/rails/rails/pull/34021))

*   添加對多環境憑證的支援。
    ([拉取請求](https://github.com/rails/rails/pull/33521))

*   在測試環境中將`null_store`設置為默認的緩存存儲。
    ([拉取請求](https://github.com/rails/rails/pull/33773))

Action Cable
------------

詳細變更請參閱[變更日誌][action-cable]。

### 刪除

*   將`ActionCable.startDebugging()`和`ActionCable.stopDebugging()`替換為`ActionCable.logger.enabled`。
    ([拉取請求](https://github.com/rails/rails/pull/34370))

### 停用

*   Rails 6.0中的Action Cable沒有停用項目。

### 重要變更

*   在`cable.yml`中為PostgreSQL訂閱適配器添加`channel_prefix`選項的支援。
    ([拉取請求](https://github.com/rails/rails/pull/35276))

*   允許將自定義配置傳遞給`ActionCable::Server::Base`。
    ([拉取請求](https://github.com/rails/rails/pull/34714))

*   添加`：action_cable_connection`和`：action_cable_channel`加載鉤子。
    ([拉取請求](https://github.com/rails/rails/pull/35094))

*   添加`Channel::Base#broadcast_to`和`Channel::Base.broadcasting_for`。
    ([拉取請求](https://github.com/rails/rails/pull/35021))

*   在從`ActionCable::Connection`調用`reject_unauthorized_connection`時關閉連接。
    ([拉取請求](https://github.com/rails/rails/pull/34194))

*   將Action Cable JavaScript包從CoffeeScript轉換為ES2015並在npm發布源代碼。
    ([拉取請求](https://github.com/rails/rails/pull/34370))

*   將WebSocket適配器和日誌適配器的配置從`ActionCable`的屬性移至`ActionCable.adapters`。
    ([拉取請求](https://github.com/rails/rails/pull/34370))

*   為Redis適配器添加`id`選項以區分Action Cable的Redis連接。
    ([拉取請求](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

詳細變更請參閱[變更日誌][action-pack]。

### 刪除

*   刪除已棄用的`fragment_cache_key`輔助方法，改用`combined_fragment_cache_key`。
    ([提交](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

*   刪除`ActionDispatch::TestResponse`中的已棄用方法：
    `#success?`改用`#successful?`，`#missing?`改用`#not_found?`，
    `#error?`改用`#server_error?`。
    ([提交](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### 停用

*   將`ActionDispatch::Http::ParameterFilter`停用，改用`ActiveSupport::ParameterFilter`。
    ([拉取請求](https://github.com/rails/rails/pull/34039))

*   停用控制器級別的`force_ssl`，改用`config.force_ssl`。
    ([拉取請求](https://github.com/rails/rails/pull/32277))

[action-cable]: https://github.com/rails/rails/blob/master/actioncable/CHANGELOG.md
[action-pack]: https://github.com/rails/rails/blob/master/actionpack/CHANGELOG.md
### 重要變更

*   更改 `ActionDispatch::Response#content_type` 返回 Content-Type
    標頭。
    ([拉取請求](https://github.com/rails/rails/pull/36034))

*   如果資源參數包含冒號，則引發 `ArgumentError`。
    ([拉取請求](https://github.com/rails/rails/pull/35236))

*   允許使用塊來定義特定瀏覽器功能的 `ActionDispatch::SystemTestCase.driven_by`。
    ([拉取請求](https://github.com/rails/rails/pull/35081))

*   添加防止 DNS 重綁定攻擊的 `ActionDispatch::HostAuthorization` 中間件。
    ([拉取請求](https://github.com/rails/rails/pull/33145))

*   允許在 `ActionController::TestCase` 中使用 `parsed_body`。
    ([拉取請求](https://github.com/rails/rails/pull/34717))

*   當同一上下文中存在多個根路由而沒有 `as:` 命名規範時，引發 `ArgumentError`。
    ([拉取請求](https://github.com/rails/rails/pull/34494))

*   允許使用 `#rescue_from` 處理參數解析錯誤。
    ([拉取請求](https://github.com/rails/rails/pull/34341))

*   添加 `ActionController::Parameters#each_value` 以遍歷參數。
    ([拉取請求](https://github.com/rails/rails/pull/33979))

*   在 `send_data` 和 `send_file` 中對 Content-Disposition 檔名進行編碼。
    ([拉取請求](https://github.com/rails/rails/pull/33829))

*   公開 `ActionController::Parameters#each_key`。
    ([拉取請求](https://github.com/rails/rails/pull/33758))

*   在簽名/加密 cookie 中添加目的和過期元數據，以防止將 cookie 的值複製到其他 cookie 中。
    ([拉取請求](https://github.com/rails/rails/pull/32937))

*   對於冲突的 `respond_to` 調用，引發 `ActionController::RespondToMismatchError`。
    ([拉取請求](https://github.com/rails/rails/pull/33446))

*   為請求格式缺少模板時添加顯示缺少模板的明確錯誤頁面。
    ([拉取請求](https://github.com/rails/rails/pull/29286))

*   引入 `ActionDispatch::DebugExceptions.register_interceptor`，一種在渲染之前處理異常的方式。
    ([拉取請求](https://github.com/rails/rails/pull/23868))

*   每個請求只輸出一個 Content-Security-Policy nonce 標頭值。
    ([拉取請求](https://github.com/rails/rails/pull/32602))

*   添加一個專門用於 Rails 默認標頭配置的模塊，可以明確地包含在控制器中。
    ([拉取請求](https://github.com/rails/rails/pull/32484))

*   在 `ActionDispatch::Request::Session` 中添加 `#dig`。
    ([拉取請求](https://github.com/rails/rails/pull/32446))

Action View
-----------

詳細變更請參閱[變更日誌][action-view]。

### 刪除項目

*   刪除已棄用的 `image_alt` 輔助方法。
    ([提交](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f))

*   從已將功能移至 `record_tag_helper` gem 的空的 `RecordTagHelper` 模塊中刪除。
    ([提交](https://github.com/rails/rails/commit/5c5ddd69b1e06fb6b2bcbb021e9b8dae17e7cb31))

### 廢棄項目

*   廢棄 `ActionView::Template.finalize_compiled_template_methods`，無替代方案。
    ([拉取請求](https://github.com/rails/rails/pull/35036))

*   廢棄 `config.action_view.finalize_compiled_template_methods`，無替代方案。
    ([拉取請求](https://github.com/rails/rails/pull/35036))

*   廢棄從 `options_from_collection_for_select` 視圖輔助方法中調用私有模型方法。
    ([拉取請求](https://github.com/rails/rails/pull/33547))

### 重要變更

*   在開發模式下僅在文件更改時清除 Action View 快取，加快開發速度。
    ([拉取請求](https://github.com/rails/rails/pull/35629))

*   將所有 Rails npm 套件移至 `@rails` 範圍。
    ([拉取請求](https://github.com/rails/rails/pull/34905))

*   只接受已註冊 MIME 類型的格式。
    ([拉取請求](https://github.com/rails/rails/pull/35604), [拉取請求](https://github.com/rails/rails/pull/35753))

*   在模板和局部渲染服務器輸出中添加分配。
    ([拉取請求](https://github.com/rails/rails/pull/34136))

*   為 `date_select` 標籤添加 `year_format` 選項，使年份名稱可自定義。
    ([拉取請求](https://github.com/rails/rails/pull/32190))

*   為 `javascript_include_tag` 輔助方法添加 `nonce: true` 選項，以支持自動生成 Content Security Policy 的 nonce。
    ([拉取請求](https://github.com/rails/rails/pull/32607))

*   添加 `action_view.finalize_compiled_template_methods` 配置以禁用或啟用 `ActionView::Template` 的最終器。
    ([拉取請求](https://github.com/rails/rails/pull/32418))
*   將JavaScript的`confirm`調用提取到`rails_ujs`中的自定義方法中，可以進行覆蓋。
    ([Pull Request](https://github.com/rails/rails/pull/32404))

*   添加`action_controller.default_enforce_utf8`配置選項來處理強制使用UTF-8編碼。默認值為`false`。
    ([Pull Request](https://github.com/rails/rails/pull/32125))

*   為locale keys的submit tags添加I18n key樣式支持。
    ([Pull Request](https://github.com/rails/rails/pull/26799))

Action Mailer
-------------

詳細更改請參閱[Changelog][action-mailer]。

### 刪除項目

### 廢棄項目

*   廢棄`ActionMailer::Base.receive`，改用Action Mailbox。
    ([Commit](https://github.com/rails/rails/commit/e3f832a7433a291a51c5df397dc3dd654c1858cb))

*   廢棄`DeliveryJob`和`Parameterized::DeliveryJob`，改用`MailDeliveryJob`。
    ([Pull Request](https://github.com/rails/rails/pull/34591))

### 重要更改

*   添加`MailDeliveryJob`，用於發送常規和帶參數的郵件。
    ([Pull Request](https://github.com/rails/rails/pull/34591))

*   允許自定義的郵件發送作業與Action Mailer測試斷言一起使用。
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   允許使用塊指定多部分郵件的模板名稱，而不僅僅使用操作名稱。
    ([Pull Request](https://github.com/rails/rails/pull/22534))

*   在`deliver.action_mailer`通知的payload中添加`perform_deliveries`。
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   改進日誌消息，當`perform_deliveries`為false時，指示郵件發送被跳過。
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   允許在沒有塊的情況下調用`assert_enqueued_email_with`。
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   在`assert_emails`塊中執行排隊的郵件發送作業。
    ([Pull Request](https://github.com/rails/rails/pull/32231))

*   允許`ActionMailer::Base`取消註冊觀察者和攔截器。
    ([Pull Request](https://github.com/rails/rails/pull/32207))

Active Record
-------------

詳細更改請參閱[Changelog][active-record]。

### 刪除項目

*   從事務對象中刪除已棄用的`#set_state`。
    ([Commit](https://github.com/rails/rails/commit/6c745b0c5152a4437163a67707e02f4464493983))

*   從數據庫適配器中刪除已棄用的`#supports_statement_cache?`。
    ([Commit](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553))

*   從數據庫適配器中刪除已棄用的`#insert_fixtures`。
    ([Commit](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece))

*   刪除已棄用的`ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?`。
    ([Commit](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf))

*   刪除在傳遞塊時將列名傳遞給`sum`的支持。
    ([Commit](https://github.com/rails/rails/commit/91ddb30083430622188d76eb9f29b78131df67f9))

*   刪除在傳遞塊時將列名傳遞給`count`的支持。
    ([Commit](https://github.com/rails/rails/commit/67356f2034ab41305af7218f7c8b2fee2d614129))

*   刪除在關聯中將缺失方法委託給Arel的支持。
    ([Commit](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0))

*   刪除在關聯中將缺失方法委託給類的私有方法的支持。
    ([Commit](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d))

*   刪除為`#cache_key`指定時間戳名稱的支持。
    ([Commit](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea))

*   刪除已棄用的`ActiveRecord::Migrator.migrations_path=`。
    ([Commit](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d))

*   刪除已棄用的`expand_hash_conditions_for_aggregates`。
    ([Commit](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e))


### 廢棄項目

*   對於唯一性驗證器，廢棄不匹配大小寫敏感排序比較。
    ([Commit](https://github.com/rails/rails/commit/9def05385f1cfa41924bb93daa187615e88c95b9))

*   如果接收器範圍已泄漏，廢棄使用類級查詢方法。
    ([Pull Request](https://github.com/rails/rails/pull/35280))

*   廢棄`config.active_record.sqlite3.represent_boolean_as_integer`。
    ([Commit](https://github.com/rails/rails/commit/f59b08119bc0c01a00561d38279b124abc82561b))

*   廢棄將`migrations_paths`傳遞給`connection.assume_migrated_upto_version`。
    ([Commit](https://github.com/rails/rails/commit/c1b14aded27e063ead32fa911aa53163d7cfc21a))

*   廢棄`ActiveRecord::Result#to_hash`，改用`ActiveRecord::Result#to_a`。
    ([Commit](https://github.com/rails/rails/commit/16510d609c601aa7d466809f3073ec3313e08937))

*   廢棄`DatabaseLimits`中的方法：`column_name_length`、`table_name_length`、
    `columns_per_table`、`indexes_per_table`、`columns_per_multicolumn_index`、
    `sql_query_length`和`joins_per_query`。
    ([Commit](https://github.com/rails/rails/commit/e0a1235f7df0fa193c7e299a5adee88db246b44f))

*   廢棄`update_attributes`/`!`，改用`update`/`!`。
    ([Commit](https://github.com/rails/rails/commit/5645149d3a27054450bd1130ff5715504638a5f5))

### 重要更改

*   將`sqlite3` gem的最低版本提升到1.4。
    ([Pull Request](https://github.com/rails/rails/pull/35844))


[action-mailer]: https://github.com/rails/rails/blob/main/actionmailer/CHANGELOG.md
[active-record]: https://github.com/rails/rails/blob/main/activerecord/CHANGELOG.md
*   新增 `rails db:prepare` 命令，用於在不存在時創建數據庫並運行遷移。
    ([Pull Request](https://github.com/rails/rails/pull/35768))

*   新增 `after_save_commit` 回調作為 `after_commit :hook, on: [ :create, :update ]` 的快捷方式。
    ([Pull Request](https://github.com/rails/rails/pull/35804))

*   新增 `ActiveRecord::Relation#extract_associated` 方法，用於從關聯中提取相關記錄。
    ([Pull Request](https://github.com/rails/rails/pull/35784))

*   新增 `ActiveRecord::Relation#annotate` 方法，用於對 ActiveRecord::Relation 查詢添加 SQL 註釋。
    ([Pull Request](https://github.com/rails/rails/pull/35617))

*   新增對數據庫設置優化提示的支持。
    ([Pull Request](https://github.com/rails/rails/pull/35615))

*   新增 `insert_all`/`insert_all!`/`upsert_all` 方法，用於批量插入數據。
    ([Pull Request](https://github.com/rails/rails/pull/35631))

*   新增 `rails db:seed:replant` 命令，用於清空當前環境下每個數據庫的表並加載種子數據。
    ([Pull Request](https://github.com/rails/rails/pull/34779))

*   新增 `reselect` 方法，它是 `unscope(:select).select(fields)` 的簡寫形式。
    ([Pull Request](https://github.com/rails/rails/pull/33611))

*   對所有枚舉值新增負面範圍。
    ([Pull Request](https://github.com/rails/rails/pull/35381))

*   新增 `#destroy_by` 和 `#delete_by` 方法，用於條件刪除。
    ([Pull Request](https://github.com/rails/rails/pull/35316))

*   新增自動切換數據庫連接的功能。
    ([Pull Request](https://github.com/rails/rails/pull/35073))

*   新增在區塊執行期間禁止對數據庫進行寫操作的功能。
    ([Pull Request](https://github.com/rails/rails/pull/34505))

*   新增用於支持多個數據庫的連接切換 API。
    ([Pull Request](https://github.com/rails/rails/pull/34052))

*   將具有精度的時間戳設置為遷移的默認值。
    ([Pull Request](https://github.com/rails/rails/pull/34970))

*   支持在 MySQL 中通過 `:size` 選項更改文本和 blob 的大小。
    ([Pull Request](https://github.com/rails/rails/pull/35071))

*   對於 `dependent: :nullify` 策略下的多態關聯，將外鍵和外部類型列都設置為 NULL。
    ([Pull Request](https://github.com/rails/rails/pull/28078))

*   允許將 `ActionController::Parameters` 的允許實例作為參數傳遞給 `ActiveRecord::Relation#exists?`。
    ([Pull Request](https://github.com/rails/rails/pull/34891))

*   在 `#where` 中新增對 Ruby 2.6 中引入的無限範圍的支持。
    ([Pull Request](https://github.com/rails/rails/pull/34906))

*   將 `ROW_FORMAT=DYNAMIC` 設置為 MySQL 創建表的默認選項。
    ([Pull Request](https://github.com/rails/rails/pull/34742))

*   新增禁用 `ActiveRecord.enum` 生成的作用域的能力。
    ([Pull Request](https://github.com/rails/rails/pull/34605))

*   對於某一列，使隱式排序可配置。
    ([Pull Request](https://github.com/rails/rails/pull/34480))

*   將最低 PostgreSQL 版本提升到 9.3，不再支持 9.1 和 9.2。
    ([Pull Request](https://github.com/rails/rails/pull/34520))

*   將枚舉的值設置為不可修改，嘗試修改時引發錯誤。
    ([Pull Request](https://github.com/rails/rails/pull/34517))

*   將 `ActiveRecord::StatementInvalid` 錯誤的 SQL 設置為自己的錯誤屬性，
    並將 SQL 綁定作為單獨的錯誤屬性包含在內。
    ([Pull Request](https://github.com/rails/rails/pull/34468))

*   在 `create_table` 中新增 `:if_not_exists` 選項。
    ([Pull Request](https://github.com/rails/rails/pull/31382))

*   將對 `rails db:schema:cache:dump` 和 `rails db:schema:cache:clear` 的支持擴展到多個數據庫。
    ([Pull Request](https://github.com/rails/rails/pull/34181))

*   在 `ActiveRecord::Base.connected_to` 的數據庫哈希中新增對哈希和 URL 配置的支持。
    ([Pull Request](https://github.com/rails/rails/pull/34196))

*   在 MySQL 中新增對默認表達式和表達式索引的支持。
    ([Pull Request](https://github.com/rails/rails/pull/34307))

*   在 `change_table` 遷移助手中新增 `index` 選項。
    ([Pull Request](https://github.com/rails/rails/pull/23593))
* 修正遷移中的`transaction`回滾問題。之前，在回滾的遷移中，事務內的命令會以未回滾的方式運行。這次更改修正了這個問題。
    ([拉取請求](https://github.com/rails/rails/pull/31604))

* 允許使用符號化哈希來設置`ActiveRecord::Base.configurations=`
    ([拉取請求](https://github.com/rails/rails/pull/33968))

* 修正計數緩存只有在記錄實際保存時才更新的問題。
    ([拉取請求](https://github.com/rails/rails/pull/33913))

* 為SQLite adapter添加表達式索引支持。
    ([拉取請求](https://github.com/rails/rails/pull/33874))

* 允許子類重新定義關聯記錄的自動保存回調。
    ([拉取請求](https://github.com/rails/rails/pull/33378))

* 將最低MySQL版本提升至5.5.8。
    ([拉取請求](https://github.com/rails/rails/pull/33853))

* 在MySQL中默認使用utf8mb4字符集。
    ([拉取請求](https://github.com/rails/rails/pull/33608))

* 添加在`#inspect`中過濾敏感數據的能力。
    ([拉取請求](https://github.com/rails/rails/pull/33756), [拉取請求](https://github.com/rails/rails/pull/34208))

* 將`ActiveRecord::Base.configurations`更改為返回對象而不是哈希。
    ([拉取請求](https://github.com/rails/rails/pull/33637))

* 添加數據庫配置以禁用咨詢鎖。
    ([拉取請求](https://github.com/rails/rails/pull/33691))

* 更新SQLite3 adapter的`alter_table`方法以恢復外鍵。
    ([拉取請求](https://github.com/rails/rails/pull/33585))

* 允許`remove_foreign_key`的`to_table`選項可逆。
    ([拉取請求](https://github.com/rails/rails/pull/33530))

* 修正MySQL時間類型的默認值問題。
    ([拉取請求](https://github.com/rails/rails/pull/33280))

* 修正`touch`選項與`Persistence#touch`方法的一致性問題。
    ([拉取請求](https://github.com/rails/rails/pull/33107))

* 對於遷移中的重複列定義，引發異常。
    ([拉取請求](https://github.com/rails/rails/pull/33029))

* 將最低SQLite版本提升至3.8。
    ([拉取請求](https://github.com/rails/rails/pull/32923))

* 確保父記錄不會與重複的子記錄一起保存。
    ([拉取請求](https://github.com/rails/rails/pull/32952))

* 如果存在，`Associations::CollectionAssociation#size`和`Associations::CollectionAssociation#empty?`使用已加載的關聯ID。
    ([拉取請求](https://github.com/rails/rails/pull/32617))

* 在不是所有記錄都具有所需關聯的情況下，添加預加載多態關聯的支持。
    ([提交](https://github.com/rails/rails/commit/75ef18c67c29b1b51314b6c8a963cee53394080b))

* 在`ActiveRecord::Relation`中添加`touch_all`方法。
    ([拉取請求](https://github.com/rails/rails/pull/31513))

* 添加`ActiveRecord::Base.base_class?`預測方法。
    ([拉取請求](https://github.com/rails/rails/pull/32417))

* 在`ActiveRecord::Store.store_accessor`中添加自定義前綴/後綴選項。
    ([拉取請求](https://github.com/rails/rails/pull/32306))

* 添加`ActiveRecord::Base.create_or_find_by`/`!`以處理`ActiveRecord::Base.find_or_create_by`/`!`中的SELECT/INSERT競爭條件，依賴數據庫中的唯一約束。
    ([拉取請求](https://github.com/rails/rails/pull/31989))

* 添加`Relation#pick`作為單值pluck的簡寫。
    ([拉取請求](https://github.com/rails/rails/pull/31941))

Active Storage
--------------

詳細更改請參閱[更新日誌][active-storage]。

### 刪除

### 廢棄

* 將`config.active_storage.queue`廢棄，改用`config.active_storage.queues.analysis`和`config.active_storage.queues.purge`。
    ([拉取請求](https://github.com/rails/rails/pull/34838))

* 將`ActiveStorage::Downloading`廢棄，改用`ActiveStorage::Blob#open`。
    ([提交](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

* 將直接使用`mini_magick`生成圖像變體的方法廢棄，改用`image_processing`。
    ([提交](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

* 廢棄Active Storage的ImageProcessing轉換器中的`:combine_options`選項，無替代方案。
    ([提交](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

### 重要更改

* 添加生成BMP圖像變體的支持。
    ([拉取請求](https://github.com/rails/rails/pull/36051))

* 添加生成TIFF圖像變體的支持。
    ([拉取請求](https://github.com/rails/rails/pull/34824))

* 添加生成漸進式JPEG圖像變體的支持。
    ([拉取請求](https://github.com/rails/rails/pull/34455))

[active-storage]: https://github.com/rails/rails/blob/master/activestorage/CHANGELOG.md
*   新增 `ActiveStorage.routes_prefix` 用於配置 Active Storage 生成的路由。
    ([Pull Request](https://github.com/rails/rails/pull/33883))

*   當從磁碟服務中請求的文件不存在時，在 `ActiveStorage::DiskController#show` 上生成 404 Not Found 響應。
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   當從 `ActiveStorage::Blob#download` 和 `ActiveStorage::Blob#open` 請求的文件不存在時，引發 `ActiveStorage::FileNotFoundError`。
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   新增一個通用的 `ActiveStorage::Error` 類，Active Storage 的異常都繼承自該類。
    ([Commit](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))

*   在保存記錄時，將分配給記錄的上傳文件持久化到存儲中，而不是立即執行。
    ([Pull Request](https://github.com/rails/rails/pull/33303))

*   當分配給附件集合時（例如 `@user.update!(images: [ … ])`），可選地替換現有文件而不是添加到它們中。使用 `config.active_storage.replace_on_assign_to_many` 來控制此行為。
    ([Pull Request](https://github.com/rails/rails/pull/33303),
     [Pull Request](https://github.com/rails/rails/pull/36716))

*   添加使用現有的 Active Record 反射機制來反射已定義的附件的能力。
    ([Pull Request](https://github.com/rails/rails/pull/33018))

*   添加 `ActiveStorage::Blob#open` 方法，該方法將文件下載到磁碟上的臨時文件並返回該臨時文件。
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   支持從 Google Cloud Storage 進行流式下載。需要 `google-cloud-storage` gem 的 1.11+ 版本。
    ([Pull Request](https://github.com/rails/rails/pull/32788))

*   使用 `image_processing` gem 來處理 Active Storage 的變體。這取代了直接使用 `mini_magick`。
    ([Pull Request](https://github.com/rails/rails/pull/32471))

Active Model
------------

詳細更改請參閱 [Changelog][active-model]。

### 刪除項目

### 廢棄項目

### 重要更改

*   添加一個配置選項，用於自定義 `ActiveModel::Errors#full_message` 的格式。
    ([Pull Request](https://github.com/rails/rails/pull/32956))

*   添加支持配置 `has_secure_password` 的屬性名稱。
    ([Pull Request](https://github.com/rails/rails/pull/26764))

*   在 `ActiveModel::Errors` 中添加 `#slice!` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/34489))

*   添加 `ActiveModel::Errors#of_kind?` 方法，用於檢查特定錯誤是否存在。
    ([Pull Request](https://github.com/rails/rails/pull/34866))

*   修正 `ActiveModel::Serializers::JSON#as_json` 方法處理時間戳的問題。
    ([Pull Request](https://github.com/rails/rails/pull/31503))

*   修正數值驗證器在除了 Active Record 之外仍然使用類型轉換之前的值的問題。
    ([Pull Request](https://github.com/rails/rails/pull/33654))

*   修正 `BigDecimal` 和 `Float` 的數值相等驗證，通過在驗證的兩端都將其轉換為 `BigDecimal`。
    ([Pull Request](https://github.com/rails/rails/pull/32852))

*   修正在轉換多參數時間哈希時的年份值。
    ([Pull Request](https://github.com/rails/rails/pull/34990))

*   在布爾屬性上，將假的布爾符號轉換為 false。
    ([Pull Request](https://github.com/rails/rails/pull/35794))

*   在 `ActiveModel::Type::Date` 的 `value_from_multiparameter_assignment` 中，正確返回轉換後的日期。
    ([Pull Request](https://github.com/rails/rails/pull/29651))

*   在獲取錯誤翻譯時，先回退到父語言環境，然後再回退到 `:errors` 命名空間。
    ([Pull Request](https://github.com/rails/rails/pull/35424))

Active Support
--------------

詳細更改請參閱 [Changelog][active-support]。

### 刪除項目

*   刪除 `Inflections` 中已棄用的 `#acronym_regex` 方法。
    ([Commit](https://github.com/rails/rails/commit/0ce67d3cd6d1b7b9576b07fecae3dd5b422a5689))

*   刪除已棄用的 `Module#reachable?` 方法。
    ([Commit](https://github.com/rails/rails/commit/6eb1d56a333fd2015610d31793ed6281acd66551))

*   刪除沒有任何替代的 `` Kernel#` ``。
    ([Pull Request](https://github.com/rails/rails/pull/31253))

### 廢棄項目

*   廢棄使用負整數參數的 `String#first` 和 `String#last`。
    ([Pull Request](https://github.com/rails/rails/pull/33058))

*   廢棄 `ActiveSupport::Multibyte::Unicode#downcase/upcase/swapcase`，改用 `String#downcase/upcase/swapcase`。
    ([Pull Request](https://github.com/rails/rails/pull/34123))
*   廢棄 `ActiveSupport::Multibyte::Unicode#normalize` 和 `ActiveSupport::Multibyte::Chars#normalize`，改用 `String#unicode_normalize`。
    ([拉取請求](https://github.com/rails/rails/pull/34202))

*   廢棄 `ActiveSupport::Multibyte::Chars.consumes?`，改用 `String#is_utf8?`。
    ([拉取請求](https://github.com/rails/rails/pull/34215))

*   廢棄 `ActiveSupport::Multibyte::Unicode#pack_graphemes(array)` 和 `ActiveSupport::Multibyte::Unicode#unpack_graphemes(string)`，改用 `array.flatten.pack("U*")` 和 `string.scan(/\X/).map(&:codepoints)`。
    ([拉取請求](https://github.com/rails/rails/pull/34254))

### 重要變更

*   增加對並行測試的支援。
    ([拉取請求](https://github.com/rails/rails/pull/31900))

*   確保 `String#strip_heredoc` 保留字符串的凍結狀態。
    ([拉取請求](https://github.com/rails/rails/pull/32037))

*   增加 `String#truncate_bytes` 方法，用於將字符串截斷為指定的字節大小，同時不破壞多字節字符或字形簇。
    ([拉取請求](https://github.com/rails/rails/pull/27319))

*   在 `delegate` 方法中添加 `private` 選項，以便委派給私有方法。該選項接受 `true/false` 作為值。
    ([拉取請求](https://github.com/rails/rails/pull/31944))

*   為 `ActiveSupport::Inflector#ordinal` 和 `ActiveSupport::Inflector#ordinalize` 添加通過 I18n 進行翻譯的支援。
    ([拉取請求](https://github.com/rails/rails/pull/32168))

*   在 `Date`、`DateTime`、`Time` 和 `TimeWithZone` 中添加 `before?` 和 `after?` 方法。
    ([拉取請求](https://github.com/rails/rails/pull/32185))

*   修復 `URI.unescape` 在混合使用 Unicode/轉義字符輸入時失敗的錯誤。
    ([拉取請求](https://github.com/rails/rails/pull/32183))

*   修復啟用壓縮時 `ActiveSupport::Cache` 存儲大小大幅膨脹的錯誤。
    ([拉取請求](https://github.com/rails/rails/pull/32539))

*   Redis 緩存存儲：`delete_matched` 不再阻塞 Redis 服務器。
    ([拉取請求](https://github.com/rails/rails/pull/32614))

*   修復 `ActiveSupport::TimeZone.all` 在任何時區定義於 `ActiveSupport::TimeZone::MAPPING` 中的 tzinfo 數據缺失時失敗的錯誤。
    ([拉取請求](https://github.com/rails/rails/pull/32613))

*   添加 `Enumerable#index_with`，允許從可枚舉對象中創建一個哈希，該哈希的值來自於傳遞的塊或默認參數。
    ([拉取請求](https://github.com/rails/rails/pull/32523))

*   允許 `Range#===` 和 `Range#cover?` 方法與 `Range` 參數一起使用。
    ([拉取請求](https://github.com/rails/rails/pull/32938))

*   在 RedisCacheStore 的 `increment/decrement` 操作中支援鍵的過期。
    ([拉取請求](https://github.com/rails/rails/pull/33254))

*   在日誌訂閱事件中添加 CPU 時間、閒置時間和分配記憶體的功能。
    ([拉取請求](https://github.com/rails/rails/pull/33449))

*   在 Active Support 通知系統中添加對事件對象的支援。
    ([拉取請求](https://github.com/rails/rails/pull/33451))

*   通過引入新選項 `skip_nil`，為 `ActiveSupport::Cache#fetch` 添加不緩存 `nil` 条目的支援。
    ([拉取請求](https://github.com/rails/rails/pull/25437))

*   添加 `Array#extract!` 方法，該方法刪除並返回塊返回 true 值的元素。
    ([拉取請求](https://github.com/rails/rails/pull/33137))

*   在切片後保持 HTML 安全字符串的 HTML 安全性。
    ([拉取請求](https://github.com/rails/rails/pull/33808))

*   通過日誌記錄來追蹤常量自動加載。
    ([提交](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   將 `unfreeze_time` 定義為 `travel_back` 的別名。
    ([拉取請求](https://github.com/rails/rails/pull/33813))

*   將 `ActiveSupport::TaggedLogging.new` 更改為返回新的日誌記錄器實例，而不是修改接收到的實例。
    ([拉取請求](https://github.com/rails/rails/pull/27792))

*   將 `#delete_prefix`、`#delete_suffix` 和 `#unicode_normalize` 方法視為非 HTML 安全方法。
    ([拉取請求](https://github.com/rails/rails/pull/33990))

*   修復 `ActiveSupport::HashWithIndifferentAccess` 的 `#without` 在使用符號參數時失敗的錯誤。
    ([拉取請求](https://github.com/rails/rails/pull/34012))

*   將 `Module#parent`、`Module#parents` 和 `Module#parent_name` 重命名為 `module_parent`、`module_parents` 和 `module_parent_name`。
    ([拉取請求](https://github.com/rails/rails/pull/34051))

*   添加 `ActiveSupport::ParameterFilter`。
    ([拉取請求](https://github.com/rails/rails/pull/34039))

*   修復在將浮點數添加到持續時間時，將持續時間四捨五入為整秒的問題。
    ([拉取請求](https://github.com/rails/rails/pull/34135))
*   在`ActiveSupport::HashWithIndifferentAccess`中，將`#to_options`設置為`#symbolize_keys`的別名。
    ([拉取請求](https://github.com/rails/rails/pull/34360))

*   如果同一個塊被多次包含在一個Concern中，不再引發異常。
    ([拉取請求](https://github.com/rails/rails/pull/34553))

*   保留傳遞給`ActiveSupport::CacheStore#fetch_multi`的鍵的順序。
    ([拉取請求](https://github.com/rails/rails/pull/34700))

*   修復`String#safe_constantize`，不再為錯誤大小寫的常量引用引發`LoadError`。
    ([拉取請求](https://github.com/rails/rails/pull/34892))

*   添加`Hash#deep_transform_values`和`Hash#deep_transform_values!`。
    ([提交](https://github.com/rails/rails/commit/b8dc06b8fdc16874160f61dcf58743fcc10e57db))

*   添加`ActiveSupport::HashWithIndifferentAccess#assoc`。
    ([拉取請求](https://github.com/rails/rails/pull/35080))

*   在`CurrentAttributes`中添加`before_reset`回調，並將`after_reset`定義為`resets`的別名，以實現對稱性。
    ([拉取請求](https://github.com/rails/rails/pull/35063))

*   修改`ActiveSupport::Notifications.unsubscribe`，以正確處理正則表達式或其他多模式訂閱者。
    ([拉取請求](https://github.com/rails/rails/pull/32861))

*   使用Zeitwerk添加新的自動加載機制。
    ([提交](https://github.com/rails/rails/commit/e53430fa9af239e21e11548499d814f540d421e5))

*   添加`Array#including`和`Enumerable#including`，以便方便地擴大集合。
    ([提交](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   將`Array#without`和`Enumerable#without`重命名為`Array#excluding`和`Enumerable#excluding`。保留舊的方法名作為別名。
    ([提交](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   添加對於`transliterate`和`parameterize`提供`locale`的支持。
    ([拉取請求](https://github.com/rails/rails/pull/35571))

*   修復`Time#advance`在1001-03-07之前的日期無法正常工作的問題。
    ([拉取請求](https://github.com/rails/rails/pull/35659))

*   更新`ActiveSupport::Notifications::Instrumenter#instrument`，允許不傳遞塊。
    ([拉取請求](https://github.com/rails/rails/pull/35705))

*   在後代跟踪器中使用弱引用，以允許匿名子類被垃圾回收。
    ([拉取請求](https://github.com/rails/rails/pull/31442))

*   使用`with_info_handler`方法調用測試方法，以使minitest-hooks插件正常工作。
    ([提交](https://github.com/rails/rails/commit/758ba117a008b6ea2d3b92c53b6a7a8d7ccbca69))

*   在`ActiveSupport::SafeBuffer#*`上保留`html_safe?`狀態。
    ([拉取請求](https://github.com/rails/rails/pull/36012))

Active Job
----------

詳細更改請參閱[Changelog][active-job]。

### 刪除

*   刪除對Qu gem的支持。
    ([拉取請求](https://github.com/rails/rails/pull/32300))

### 廢棄

### 重要更改

*   添加對於Active Job參數的自定義序列化器的支持。
    ([拉取請求](https://github.com/rails/rails/pull/30941))

*   添加對於在排隊時使用的時區執行Active Jobs的支持。
    ([拉取請求](https://github.com/rails/rails/pull/32085))

*   允許將多個異常傳遞給`retry_on`/`discard_on`。
    ([提交](https://github.com/rails/rails/commit/3110caecbebdad7300daaf26bfdff39efda99e25))

*   允許在不使用塊的情況下調用`assert_enqueued_with`和`assert_enqueued_email_with`。
    ([拉取請求](https://github.com/rails/rails/pull/33258))

*   將`enqueue`和`enqueue_at`的通知包裝在`around_enqueue`回調中，而不是`after_enqueue`回調中。
    ([拉取請求](https://github.com/rails/rails/pull/33171))

*   允許在不使用塊的情況下調用`perform_enqueued_jobs`。
    ([拉取請求](https://github.com/rails/rails/pull/33626))

*   允許在不使用塊的情況下調用`assert_performed_with`。
    ([拉取請求](https://github.com/rails/rails/pull/33635))

*   對於作業斷言和輔助方法添加`：queue`選項。
    ([拉取請求](https://github.com/rails/rails/pull/33635))

*   在Active Job重試和丟棄周圍添加鉤子。
    ([拉取請求](https://github.com/rails/rails/pull/33751))

*   添加一種方法來測試執行作業時的參數子集。
    ([拉取請求](https://github.com/rails/rails/pull/33995))

*   在Active Job測試輔助方法返回的作業中包含反序列化的參數。
    ([拉取請求](https://github.com/rails/rails/pull/34204))

*   允許Active Job斷言輔助方法接受`only`關鍵字的Proc。
    ([拉取請求](https://github.com/rails/rails/pull/34339))

*   在斷言輔助方法中從作業參數中刪除微秒和納秒。
    ([拉取請求](https://github.com/rails/rails/pull/35713))

Ruby on Rails指南
----------------

詳細更改請參閱[Changelog][guides]。
### 重要變更

*   新增了使用Active Record的多個資料庫指南。
    ([拉取請求](https://github.com/rails/rails/pull/36389))

*   新增了有關自動載入常數故障排除的章節。
    ([提交](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   新增了Action Mailbox基礎指南。
    ([拉取請求](https://github.com/rails/rails/pull/34812))

*   新增了Action Text概述指南。
    ([拉取請求](https://github.com/rails/rails/pull/34878))

貢獻者
-------

請參閱
[Rails的完整貢獻者列表](https://contributors.rubyonrails.org/)
感謝所有花費了許多時間使Rails成為穩定且強大的框架的人們。向他們致敬。

[railties]:       https://github.com/rails/rails/blob/6-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-0-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-0-stable/activesupport/CHANGELOG.md
