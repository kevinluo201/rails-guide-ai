**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c7252bf18650c5a9a85fc144305c4615
Ruby on Rails 5.2 發行說明
===============================

Rails 5.2 的亮點：

* Active Storage
* Redis Cache Store
* HTTP/2 Early Hints
* Credentials
* Content Security Policy

這些發行說明僅涵蓋主要更改。若要了解各種錯誤修復和更改，請參閱變更日誌或查看 GitHub 上主要 Rails 存儲庫中的[提交清單](https://github.com/rails/rails/commits/5-2-stable)。

--------------------------------------------------------------------------------

升級到 Rails 5.2
----------------------

如果您正在升級現有應用程式，建議在進行升級之前先進行良好的測試覆蓋。同時，請確保您的應用程式在升級到 Rails 5.2 之前，已先升級到 Rails 5.1 並確保應用程式運行正常。在升級時請注意的事項清單，可在[升級 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2)指南中找到。

主要功能
--------------

### Active Storage

[拉取請求](https://github.com/rails/rails/pull/30020)

[Active Storage](https://github.com/rails/rails/tree/5-2-stable/activestorage)可協助上傳文件到雲端儲存服務，例如 Amazon S3、Google Cloud Storage 或 Microsoft Azure Storage，並將這些文件附加到 Active Record 物件上。它提供了一個基於本地磁碟的服務，供開發和測試使用，並支援將文件鏡像到從屬服務進行備份和遷移。您可以在[Active Storage 概述](active_storage_overview.html)指南中了解更多。

### Redis Cache Store

[拉取請求](https://github.com/rails/rails/pull/31134)

Rails 5.2 內建了 Redis 快取存儲。您可以在[Caching with Rails: An Overview](caching_with_rails.html#activesupport-cache-rediscachestore)指南中了解更多。

### HTTP/2 Early Hints

[拉取請求](https://github.com/rails/rails/pull/30744)

Rails 5.2 支援 [HTTP/2 Early Hints](https://tools.ietf.org/html/rfc8297)。要啟用 Early Hints，請在 `bin/rails server` 中傳遞 `--early-hints`。

### Credentials

[拉取請求](https://github.com/rails/rails/pull/30067)

新增 `config/credentials.yml.enc` 檔案以存儲生產應用程式的機密。它允許將任何第三方服務的驗證憑證直接加密保存在存儲庫中，並使用 `config/master.key` 檔案或 `RAILS_MASTER_KEY` 環境變數中的金鑰進行加密。這將最終取代 `Rails.application.secrets` 和 Rails 5.1 中引入的加密機密。此外，Rails 5.2 還[開放了底層 Credentials 的 API](https://github.com/rails/rails/pull/30940)，因此您可以輕鬆處理其他加密配置、金鑰和檔案。您可以在[保護 Rails 應用程式](security.html#custom-credentials)指南中了解更多。

### Content Security Policy

[拉取請求](https://github.com/rails/rails/pull/31162)

Rails 5.2 內建了一個新的 DSL，允許您為應用程式配置[內容安全策略](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)。您可以配置全域預設策略，然後在每個資源上覆蓋它，甚至使用 lambda 在標頭中注入每個請求的值，例如多租戶應用程式中的帳戶子域。您可以在[保護 Rails 應用程式](security.html#content-security-policy)指南中了解更多。
Railties
--------

請參考[變更日誌][railties]以獲得詳細的變更內容。

### 廢棄功能

*   在生成器和模板中廢棄`capify!`方法。
    ([拉取請求](https://github.com/rails/rails/pull/29493))

*   將環境名稱作為常規參數傳遞給`rails dbconsole`和`rails console`命令已被廢棄。
    應改用`-e`選項。
    ([提交](https://github.com/rails/rails/commit/48b249927375465a7102acc71c2dfb8d49af8309))

*   廢棄使用`Rails::Application`的子類來啟動Rails服務器。
    ([拉取請求](https://github.com/rails/rails/pull/30127))

*   在Rails插件模板中廢棄`after_bundle`回調。
    ([拉取請求](https://github.com/rails/rails/pull/29446))

### 重要變更

*   在`config/database.yml`中新增一個共享部分，將在所有環境中加載。
    ([拉取請求](https://github.com/rails/rails/pull/28896))

*   將`railtie.rb`添加到插件生成器中。
    ([拉取請求](https://github.com/rails/rails/pull/29576))

*   在`tmp:clear`任務中清除截圖文件。
    ([拉取請求](https://github.com/rails/rails/pull/29534))

*   在運行`bin/rails app:update`時跳過未使用的組件。
    如果初始應用程序生成時跳過了Action Cable、Active Record等，更新任務也會遵循這些跳過。
    ([拉取請求](https://github.com/rails/rails/pull/29645))

*   在使用3層數據庫配置時，允許在`rails dbconsole`命令中傳遞自定義連接名稱。
    例如：`bin/rails dbconsole -c replica`。
    ([提交](https://github.com/rails/rails/commit/1acd9a6464668d4d54ab30d016829f60b70dbbeb))

*   正確展開運行`console`和`dbconsole`命令時環境名稱的快捷方式。
    ([提交](https://github.com/rails/rails/commit/3777701f1380f3814bd5313b225586dec64d4104))

*   在默認的`Gemfile`中添加`bootsnap`。
    ([拉取請求](https://github.com/rails/rails/pull/29313))

*   通過`rails runner`支持使用`-`作為從stdin運行腳本的跨平台方式。
    ([拉取請求](https://github.com/rails/rails/pull/26343))

*   在創建新的Rails應用程序時，在`Gemfile`中添加`ruby x.x.x`版本並創建包含當前Ruby版本的`.ruby-version`根文件。
    ([拉取請求](https://github.com/rails/rails/pull/30016))

*   在插件生成器中添加`--skip-action-cable`選項。
    ([拉取請求](https://github.com/rails/rails/pull/30164))

*   在插件生成器的`Gemfile`中添加`git_source`。
    ([拉取請求](https://github.com/rails/rails/pull/30110))

*   在Rails插件中運行`bin/rails`時跳過未使用的組件。
    ([提交](https://github.com/rails/rails/commit/62499cb6e088c3bc32a9396322c7473a17a28640))

*   優化生成器操作的縮進。
    ([拉取請求](https://github.com/rails/rails/pull/30166))

*   優化路由的縮進。
    ([拉取請求](https://github.com/rails/rails/pull/30241))

*   在插件生成器中添加`--skip-yarn`選項。
    ([拉取請求](https://github.com/rails/rails/pull/30238))

*   為生成器的`gem`方法支持多個版本參數。
    ([拉取請求](https://github.com/rails/rails/pull/30323))

*   在開發和測試環境中，從應用程序名稱派生`secret_key_base`。
    ([拉取請求](https://github.com/rails/rails/pull/30067))

*   在默認的`Gemfile`中以註釋形式添加`mini_magick`。
    ([拉取請求](https://github.com/rails/rails/pull/30633))

*   `rails new`和`rails plugin new`默認包含`Active Storage`。
    添加使用`--skip-active-storage`跳過`Active Storage`的功能，並在使用`--skip-active-record`時自動跳過。
    ([拉取請求](https://github.com/rails/rails/pull/30101))

Action Cable
------------

請參考[變更日誌][action-cable]以獲得詳細的變更內容。

### 刪除功能

*   刪除已廢棄的事件驅動Redis適配器。
    ([提交](https://github.com/rails/rails/commit/48766e32d31651606b9f68a16015ad05c3b0de2c))

### 重要變更

*   在cable.yml中添加對`host`、`port`、`db`和`password`選項的支持。
    ([拉取請求](https://github.com/rails/rails/pull/29528))

*   在使用PostgreSQL適配器時，對長流識別符進行哈希。
    ([拉取請求](https://github.com/rails/rails/pull/29297))

Action Pack
-----------

請參考[變更日誌][action-pack]以獲得詳細的變更內容。

[railties]: https://github.com/rails/rails/blob/master/railties/CHANGELOG.md
[action-cable]: https://github.com/rails/rails/blob/master/actioncable/CHANGELOG.md
[action-pack]: https://github.com/rails/rails/blob/master/actionpack/CHANGELOG.md
### 刪除項目

*   刪除已棄用的 `ActionController::ParamsParser::ParseError`。
    ([Commit](https://github.com/rails/rails/commit/e16c765ac6dcff068ff2e5554d69ff345c003de1))

### 廢棄項目

*   廢棄 `ActionDispatch::TestResponse` 的 `#success?`、`#missing?` 和 `#error?` 別名。
    ([Pull Request](https://github.com/rails/rails/pull/30104))

### 重要變更

*   新增對片段緩存使用可回收快取鍵的支援。
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   更改片段的快取鍵格式，以便更容易調試鍵的變動。
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   使用GCM對AEAD加密的Cookie和Session進行加密。
    ([Pull Request](https://github.com/rails/rails/pull/28132))

*   默認保護免受偽造攻擊。
    ([Pull Request](https://github.com/rails/rails/pull/29742))

*   在服務器端強制執行已簽名/已加密的Cookie到期。
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   Cookies的 `:expires` 選項支援 `ActiveSupport::Duration` 對象。
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   使用Capybara註冊的 `:puma` 服務器配置。
    ([Pull Request](https://github.com/rails/rails/pull/30638))

*   簡化帶有密鑰輪換支援的Cookies中間件。
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   添加啟用HTTP/2的Early Hints功能。
    ([Pull Request](https://github.com/rails/rails/pull/30744))

*   在系統測試中添加對無頭Chrome的支援。
    ([Pull Request](https://github.com/rails/rails/pull/30876))

*   在 `redirect_back` 方法中添加 `:allow_other_host` 選項。
    ([Pull Request](https://github.com/rails/rails/pull/30850))

*   使 `assert_recognizes` 能夠遍歷已掛載的引擎。
    ([Pull Request](https://github.com/rails/rails/pull/22435))

*   添加用於配置Content-Security-Policy標頭的DSL。
    ([Pull Request](https://github.com/rails/rails/pull/31162),
    [Commit](https://github.com/rails/rails/commit/619b1b6353a65e1635d10b8f8c6630723a5a6f1a),
    [Commit](https://github.com/rails/rails/commit/4ec8bf68ff92f35e79232fbd605012ce1f4e1e6e))

*   註冊現代瀏覽器支援的最流行的音頻/視頻/字體MIME類型。
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   將系統測試的默認截圖輸出從 `inline` 更改為 `simple`。
    ([Commit](https://github.com/rails/rails/commit/9d6e288ee96d6241f864dbf90211c37b14a57632))

*   在系統測試中添加對無頭Firefox的支援。
    ([Pull Request](https://github.com/rails/rails/pull/31365))

*   在默認標頭集中添加安全的 `X-Download-Options` 和 `X-Permitted-Cross-Domain-Policies`。
    ([Commit](https://github.com/rails/rails/commit/5d7b70f4336d42eabfc403e9f6efceb88b3eff44))

*   當用戶未手動指定其他服務器時，將系統測試設置為默認使用Puma服務器。
    ([Pull Request](https://github.com/rails/rails/pull/31384))

*   在默認標頭集中添加 `Referrer-Policy` 標頭。
    ([Commit](https://github.com/rails/rails/commit/428939be9f954d39b0c41bc53d85d0d106b9d1a1))

*   在 `ActionController::Parameters#each` 中匹配 `Hash#each` 的行為。
    ([Pull Request](https://github.com/rails/rails/pull/27790))

*   為Rails UJS添加自動生成nonce的支援。
    ([Commit](https://github.com/rails/rails/commit/b2f0a8945956cd92dec71ec4e44715d764990a49))

*   更新默認的HSTS max-age值為31536000秒（1年），以滿足https://hstspreload.org/的最小max-age要求。
    ([Commit](https://github.com/rails/rails/commit/30b5f469a1d30c60d1fb0605e84c50568ff7ed37))

*   為 `cookies` 添加 `to_hash` 的別名方法。
    為 `session` 添加 `to_h` 的別名方法。
    ([Commit](https://github.com/rails/rails/commit/50a62499e41dfffc2903d468e8b47acebaf9b500))

Action View
-----------

詳細變更請參閱[變更日誌][action-view]。

### 刪除項目

*   刪除已棄用的Erubis ERB處理程序。
    ([Commit](https://github.com/rails/rails/commit/7de7f12fd140a60134defe7dc55b5a20b2372d06))

### 廢棄項目

*   廢棄 `image_tag` 生成的圖像的默認alt文本的 `image_alt` 輔助方法。
    ([Pull Request](https://github.com/rails/rails/pull/30213))

### 重要變更

*   將 `auto_discovery_link_tag` 添加 `:json` 類型，以支援[JSON Feeds](https://jsonfeed.org/version/1)。
    ([Pull Request](https://github.com/rails/rails/pull/29158))

*   將 `image_tag` 輔助方法添加 `srcset` 選項。
    ([Pull Request](https://github.com/rails/rails/pull/29349))

*   修復 `field_error_proc` 包裝 `optgroup` 和選擇分隔符 `option` 的問題。
    ([Pull Request](https://github.com/rails/rails/pull/31088))

*   更改 `form_with` 默認生成ID。
    ([Commit](https://github.com/rails/rails/commit/260d6f112a0ffdbe03e6f5051504cb441c1e94cd))

*   添加 `preload_link_tag` 輔助方法。
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   允許使用可調用對象作為分組選擇的分組方法。
    ([Pull Request](https://github.com/rails/rails/pull/31578))
Action Mailer
-------------

請參考[變更日誌][action-mailer]以獲取詳細的變更內容。

### 重要變更

*   允許 Action Mailer 類別配置其傳送工作。
    ([拉取請求](https://github.com/rails/rails/pull/29457))

*   新增 `assert_enqueued_email_with` 測試輔助方法。
    ([拉取請求](https://github.com/rails/rails/pull/30695))

Active Record
-------------

請參考[變更日誌][active-record]以獲取詳細的變更內容。

### 刪除項目

*   移除已棄用的 `#migration_keys`。
    ([拉取請求](https://github.com/rails/rails/pull/30337))

*   移除對於 Active Record 物件進行類型轉換時已棄用的 `quoted_id` 支援。
    ([提交](https://github.com/rails/rails/commit/82472b3922bda2f337a79cef961b4760d04f9689))

*   移除對於 `index_name_exists?` 的已棄用參數 `default`。
    ([提交](https://github.com/rails/rails/commit/8f5b34df81175e30f68879479243fbce966122d7))

*   移除對於關聯中的 `:class_name` 傳遞類別的已棄用支援。
    ([提交](https://github.com/rails/rails/commit/e65aff70696be52b46ebe57207ebd8bb2cfcdbb6))

*   移除已棄用的方法 `initialize_schema_migrations_table` 和
    `initialize_internal_metadata_table`。
    ([提交](https://github.com/rails/rails/commit/c9660b5777707658c414b430753029cd9bc39934))

*   移除已棄用的方法 `supports_migrations?`。
    ([提交](https://github.com/rails/rails/commit/9438c144b1893f2a59ec0924afe4d46bd8d5ffdd))

*   移除已棄用的方法 `supports_primary_key?`。
    ([提交](https://github.com/rails/rails/commit/c56ff22fc6e97df4656ddc22909d9bf8b0c2cbb1))

*   移除已棄用的方法
    `ActiveRecord::Migrator.schema_migrations_table_name`。
    ([提交](https://github.com/rails/rails/commit/7df6e3f3cbdea9a0460ddbab445c81fbb1cfd012))

*   移除 `#indexes` 的已棄用參數 `name`。
    ([提交](https://github.com/rails/rails/commit/d6b779ecebe57f6629352c34bfd6c442ac8fba0e))

*   移除 `#verify!` 的已棄用參數。
    ([提交](https://github.com/rails/rails/commit/9c6ee1bed0292fc32c23dc1c68951ae64fc510be))

*   移除已棄用的配置 `.error_on_ignored_order_or_limit`。
    ([提交](https://github.com/rails/rails/commit/e1066f450d1a99c9a0b4d786b202e2ca82a4c3b3))

*   移除已棄用的方法 `#scope_chain`。
    ([提交](https://github.com/rails/rails/commit/ef7784752c5c5efbe23f62d2bbcc62d4fd8aacab))

*   移除已棄用的方法 `#sanitize_conditions`。
    ([提交](https://github.com/rails/rails/commit/8f5413b896099f80ef46a97819fe47a820417bc2))

### 已棄用項目

*   已棄用 `supports_statement_cache?`。
    ([拉取請求](https://github.com/rails/rails/pull/28938))

*   已棄用同時對 `ActiveRecord::Calculations` 中的 `count` 和 `sum` 傳遞參數和區塊。
    ([拉取請求](https://github.com/rails/rails/pull/29262))

*   已棄用在 `Relation` 中委派給 `arel`。
    ([拉取請求](https://github.com/rails/rails/pull/29619))

*   已棄用 `TransactionState` 中的 `set_state` 方法。
    ([提交](https://github.com/rails/rails/commit/608ebccf8f6314c945444b400a37c2d07f21b253))

*   已棄用 `expand_hash_conditions_for_aggregates`，無替代方案。
    ([提交](https://github.com/rails/rails/commit/7ae26885d96daee3809d0bd50b1a440c2f5ffb69))

### 重要變更

*   當不帶參數呼叫動態固定裝置存取方法時，現在會返回該類型的所有固定裝置。先前此方法總是返回空陣列。
    ([拉取請求](https://github.com/rails/rails/pull/28692))

*   修正覆寫 Active Record 屬性讀取器時的屬性變更不一致性。
    ([拉取請求](https://github.com/rails/rails/pull/28661))

*   支援 MySQL 的降序索引。
    ([拉取請求](https://github.com/rails/rails/pull/28773))

*   修正 `bin/rails db:forward` 的第一個遷移。
    ([提交](https://github.com/rails/rails/commit/b77d2aa0c336492ba33cbfade4964ba0eda3ef84))

*   在遷移不存在時，在遷移移動時引發 `UnknownMigrationVersionError` 錯誤。
    ([提交](https://github.com/rails/rails/commit/bb9d6eb094f29bb94ef1f26aa44f145f17b973fe))

*   在資料庫結構備份的 rake 任務中尊重 `SchemaDumper.ignore_tables`。
    ([拉取請求](https://github.com/rails/rails/pull/29077))

*   新增 `ActiveRecord::Base#cache_version` 以支援透過 `ActiveSupport::Cache` 中的新版本項目的可回收快取鍵。這也意味著 `ActiveRecord::Base#cache_key` 現在會返回一個不再包含時間戳記的穩定鍵。
    ([拉取請求](https://github.com/rails/rails/pull/29092))

*   如果轉換後的值為 nil，則防止創建綁定參數。
    ([拉取請求](https://github.com/rails/rails/pull/29282))

*   使用批量 INSERT 插入固定裝置以提高性能。
    ([拉取請求](https://github.com/rails/rails/pull/29504))

*   合併表示嵌套連接的兩個關聯不再將合併後關聯的連接轉換為 LEFT OUTER JOIN。
    ([拉取請求](https://github.com/rails/rails/pull/27063))

*   修正事務以將狀態應用於子事務。先前，如果有一個嵌套事務並且外部事務被回滾，內部事務的記錄仍然會被標記為已持久化。通過在父事務回滾時將父事務的狀態應用於子事務，此問題已被修正。這將正確地將內部事務的記錄標記為未持久化。
    ([提交](https://github.com/rails/rails/commit/0237da287eb4c507d10a0c6d94150093acc52b03))

[action-mailer]: https://github.com/rails/rails/blob/master/actionmailer/CHANGELOG.md
[active-record]: https://github.com/rails/rails/blob/master/activerecord/CHANGELOG.md
*   修正使用包含連接的範圍時的急切加載/預加載關聯。
    ([拉取請求](https://github.com/rails/rails/pull/29413))

*   防止由`sql.active_record`通知訂閱者引發的錯誤轉換為`ActiveRecord::StatementInvalid`異常。
    ([拉取請求](https://github.com/rails/rails/pull/29692))

*   在處理記錄批次（`find_each`，`find_in_batches`，`in_batches`）時跳過查詢緩存。
    ([提交](https://github.com/rails/rails/commit/b83852e6eed5789b23b13bac40228e87e8822b4d))

*   將sqlite3的布林序列化更改為使用1和0。
    SQLite本地識別1和0為true和false，但以前序列化時不識別't'和'f'。
    ([拉取請求](https://github.com/rails/rails/pull/29699))

*   使用多參數賦值構造的值現在將使用後類型轉換值在單字段表單輸入中呈現。
    ([提交](https://github.com/rails/rails/commit/1519e976b224871c7f7dd476351930d5d0d7faf6))

*   在生成模型時不再生成`ApplicationRecord`。如果需要生成它，可以使用`rails g application_record`創建。
    ([拉取請求](https://github.com/rails/rails/pull/29916))

*   `Relation#or`現在接受兩個僅具有不同`references`值的關聯，因為`references`可以被`where`隱式調用。
    ([提交](https://github.com/rails/rails/commit/ea6139101ccaf8be03b536b1293a9f36bc12f2f7))

*   在使用`Relation#or`時，提取公共條件並將它們放在OR條件之前。
    ([拉取請求](https://github.com/rails/rails/pull/29950))

*   添加`binary`夾具輔助方法。
    ([拉取請求](https://github.com/rails/rails/pull/30073))

*   自動猜測STI的反向關聯。
    ([拉取請求](https://github.com/rails/rails/pull/23425))

*   添加新的錯誤類`LockWaitTimeout`，當鎖等待超時時將引發該錯誤。
    ([拉取請求](https://github.com/rails/rails/pull/30360))

*   更新`sql.active_record`儀器的有效負載名稱以更具描述性。
    ([拉取請求](https://github.com/rails/rails/pull/30619))

*   在從數據庫中刪除索引時使用給定的算法。
    ([拉取請求](https://github.com/rails/rails/pull/24199))

*   將`Set`傳遞給`Relation#where`現在的行為與傳遞數組相同。
    ([提交](https://github.com/rails/rails/commit/9cf7e3494f5bd34f1382c1ff4ea3d811a4972ae2))

*   PostgreSQL的`tsrange`現在保留次秒精度。
    ([拉取請求](https://github.com/rails/rails/pull/30725))

*   在髒記錄中調用`lock!`時引發異常。
    ([提交](https://github.com/rails/rails/commit/63cf15877bae859ff7b4ebaf05186f3ca79c1863))

*   修復使用SQLite適配器時，索引的列順序未寫入`db/schema.rb`的錯誤。
    ([拉取請求](https://github.com/rails/rails/pull/30970))

*   修復使用指定`VERSION`的`bin/rails db:migrate`命令。
    使用空的`VERSION`執行`bin/rails db:migrate`的行為與不使用`VERSION`相同。
    檢查`VERSION`的格式：允許遷移版本號或遷移文件的名稱。如果`VERSION`的格式無效，則引發錯誤。
    如果目標遷移不存在，則引發錯誤。
    ([拉取請求](https://github.com/rails/rails/pull/30714))

*   添加新的錯誤類`StatementTimeout`，當語句超時時將引發該錯誤。
    ([拉取請求](https://github.com/rails/rails/pull/31129))

*   `update_all`現在將其值傳遞給`Type#cast`之前將其傳遞給`Type#serialize`。這意味著`update_all(foo: 'true')`將正確地持久化布林值。
    ([提交](https://github.com/rails/rails/commit/68fe6b08ee72cc47263e0d2c9ff07f75c4b42761))

*   在關聯查詢方法中使用原始SQL片段時需要明確標記。
    ([提交](https://github.com/rails/rails/commit/a1ee43d2170dd6adf5a9f390df2b1dde45018a48),
    [提交](https://github.com/rails/rails/commit/e4a921a75f8702a7dbaf41e31130fe884dea93f9))

*   在數據庫遷移中添加`#up_only`，用於僅在遷移上時相關的代碼，例如填充新列。
    ([拉取請求](https://github.com/rails/rails/pull/31082))
*   新增錯誤類別 `QueryCanceled`，當取消語句時由於使用者請求而引發。
    ([拉取請求](https://github.com/rails/rails/pull/31235))

*   不允許定義與 `Relation` 上的實例方法衝突的作用域。
    ([拉取請求](https://github.com/rails/rails/pull/31179))

*   將對 PostgreSQL 運算子類別的支援添加到 `add_index` 中。
    ([拉取請求](https://github.com/rails/rails/pull/19090))

*   記錄資料庫查詢的呼叫者。
    ([拉取請求](https://github.com/rails/rails/pull/26815),
    [拉取請求](https://github.com/rails/rails/pull/31519),
    [拉取請求](https://github.com/rails/rails/pull/31690))

*   在重置欄位資訊時，取消子類別的屬性方法定義。
    ([拉取請求](https://github.com/rails/rails/pull/31475))

*   使用子選擇子進行帶有 `limit` 或 `offset` 的 `delete_all`。
    ([提交](https://github.com/rails/rails/commit/9e7260da1bdc0770cf4ac547120c85ab93ff3d48))

*   修正 `first(n)` 與 `limit()` 一起使用時的不一致問題。
    `first(n)` 現在尊重 `limit()`，使其與 `relation.to_a.first(n)` 的行為一致，也與 `last(n)` 的行為一致。
    ([拉取請求](https://github.com/rails/rails/pull/27597))

*   修正未持久化父實例上的嵌套 `has_many :through` 關聯。
    ([提交](https://github.com/rails/rails/commit/027f865fc8b262d9ba3ee51da3483e94a5489b66))

*   在刪除通過記錄時考慮關聯條件。
    ([提交](https://github.com/rails/rails/commit/ae48c65e411e01c1045056562319666384bb1b63))

*   在調用 `save` 或 `save!` 後不允許已銷毀的物件變異。
    ([提交](https://github.com/rails/rails/commit/562dd0494a90d9d47849f052e8913f0050f3e494))

*   修正 `left_outer_joins` 中的關聯合併問題。
    ([拉取請求](https://github.com/rails/rails/pull/27860))

*   支援 PostgreSQL 外部表。
    ([拉取請求](https://github.com/rails/rails/pull/31549))

*   在複製 Active Record 物件時清除事務狀態。
    ([拉取請求](https://github.com/rails/rails/pull/31751))

*   修正使用 `composed_of` 欄位將 Array 物件作為參數傳遞給 where 方法時未展開的問題。
    ([拉取請求](https://github.com/rails/rails/pull/31724))

*   如果 `polymorphic?` 不正確使用，則使 `reflection.klass` 引發異常。
    ([提交](https://github.com/rails/rails/commit/63fc1100ce054e3e11c04a547cdb9387cd79571a))

*   修正 MySQL 和 PostgreSQL 的 `#columns_for_distinct`，使 `ActiveRecord::FinderMethods#limited_ids_for` 使用正確的主鍵值，即使 `ORDER BY` 列包含其他表的主鍵。
    ([提交](https://github.com/rails/rails/commit/851618c15750979a75635530200665b543561a44))

*   修正 has_one/belongs_to 關聯中 `dependent: :destroy` 的問題，當子類別未被刪除時，父類別被刪除。
    ([提交](https://github.com/rails/rails/commit/b0fc04aa3af338d5a90608bf37248668d59fc881))

*   空閒的資料庫連線（以前僅為孤立的連線）現在由連線池清理程序定期清除。
    ([提交](https://github.com/rails/rails/pull/31221/commits/9027fafff6da932e6e64ddb828665f4b01fc8902))

Active Model
------------

詳細變更請參閱[變更日誌][active-model]。

### 重要變更

*   修正 `ActiveModel::Errors` 中的 `#keys`、`#values` 方法。
    將 `#keys` 修改為僅返回沒有空訊息的鍵。
    將 `#values` 修改為僅返回非空值。
    ([拉取請求](https://github.com/rails/rails/pull/28584))

*   為 `ActiveModel::Errors` 添加 `#merge!` 方法。
    ([拉取請求](https://github.com/rails/rails/pull/29714))

*   允許將 Proc 或 Symbol 傳遞給長度驗證器選項。
    ([拉取請求](https://github.com/rails/rails/pull/30674))

*   當 `_confirmation` 的值為 `false` 時執行 `ConfirmationValidator` 驗證。
    ([拉取請求](https://github.com/rails/rails/pull/31058))

*   使用具有 proc 預設值的屬性 API 的模型現在可以被序列化。
    ([提交](https://github.com/rails/rails/commit/0af36c62a5710e023402e37b019ad9982e69de4b))

*   在序列化中不會丟失所有具有選項的多個 `:includes`。
    ([提交](https://github.com/rails/rails/commit/853054bcc7a043eea78c97e7705a46abb603cc44))

Active Support
--------------

詳細變更請參閱[變更日誌][active-support]。

### 刪除項目

*   刪除已棄用的回調的 `:if` 和 `:unless` 字符串過濾器。
    ([提交](https://github.com/rails/rails/commit/c792354adcbf8c966f274915c605c6713b840548))

*   刪除已棄用的 `halt_callback_chains_on_return_false` 選項。
    ([提交](https://github.com/rails/rails/commit/19fbbebb1665e482d76cae30166b46e74ceafe29))

[active-model]: https://github.com/rails/rails/blob/master/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/master/activesupport/CHANGELOG.md
### 廢棄功能

*   廢棄 `Module#reachable?` 方法。
    ([拉取請求](https://github.com/rails/rails/pull/30624))

*   廢棄 `secrets.secret_token`。
    ([提交](https://github.com/rails/rails/commit/fbcc4bfe9a211e219da5d0bb01d894fcdaef0a0e))

### 重要更改

*   為 `HashWithIndifferentAccess` 添加 `fetch_values`。
    ([拉取請求](https://github.com/rails/rails/pull/28316))

*   為 `Time#change` 添加對 `:offset` 的支援。
    ([提交](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   為 `ActiveSupport::TimeWithZone#change` 添加對 `:offset` 和 `:zone` 的支援。
    ([提交](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   將 gem 名稱和廢棄期限傳遞給廢棄通知。
    ([拉取請求](https://github.com/rails/rails/pull/28800))

*   添加對版本化快取條目的支援。這使得快取存儲可以重複使用快取鍵，在頻繁變動的情況下大大節省存儲空間。與 Active Record 中 `#cache_key` 和 `#cache_version` 的分離以及其在 Action Pack 的片段快取中的使用一起使用。
    ([拉取請求](https://github.com/rails/rails/pull/29092))

*   添加 `ActiveSupport::CurrentAttributes` 以提供線程隔離的屬性單例。主要用例是使所有每個請求的屬性對整個系統易於使用。
    ([拉取請求](https://github.com/rails/rails/pull/29180))

*   `#singularize` 和 `#pluralize` 現在尊重指定語言環境的不可數名詞。
    ([提交](https://github.com/rails/rails/commit/352865d0f835c24daa9a2e9863dcc9dde9e5371a))

*   為 `class_attribute` 添加默認選項。
    ([拉取請求](https://github.com/rails/rails/pull/29270))

*   添加 `Date#prev_occurring` 和 `Date#next_occurring` 以返回指定的下一個/上一個星期幾。
    ([拉取請求](https://github.com/rails/rails/pull/26600))

*   為模組和類別屬性訪問器添加默認選項。
    ([拉取請求](https://github.com/rails/rails/pull/29294))

*   快取：`write_multi`。
    ([拉取請求](https://github.com/rails/rails/pull/29366))

*   將 `ActiveSupport::MessageEncryptor` 的默認加密方式設置為 AES 256 GCM 加密。
    ([拉取請求](https://github.com/rails/rails/pull/29263))

*   添加 `freeze_time` 助手，在測試中將時間凍結為 `Time.now`。
    ([拉取請求](https://github.com/rails/rails/pull/29681))

*   使 `Hash#reverse_merge!` 的順序與 `HashWithIndifferentAccess` 一致。
    ([拉取請求](https://github.com/rails/rails/pull/28077))

*   為 `ActiveSupport::MessageVerifier` 和 `ActiveSupport::MessageEncryptor` 添加目的和過期支援。
    ([拉取請求](https://github.com/rails/rails/pull/29892))

*   更新 `String#camelize`，在傳遞錯誤選項時提供反饋。
    ([拉取請求](https://github.com/rails/rails/pull/30039))

*   如果目標為 nil，`Module#delegate_missing_to` 現在會像 `Module#delegate` 一樣引發 `DelegationError`。
    ([拉取請求](https://github.com/rails/rails/pull/30191))

*   添加 `ActiveSupport::EncryptedFile` 和 `ActiveSupport::EncryptedConfiguration`。
    ([拉取請求](https://github.com/rails/rails/pull/30067))

*   添加 `config/credentials.yml.enc` 以存儲生產應用程式的密鑰。
    ([拉取請求](https://github.com/rails/rails/pull/30067))

*   對 `MessageEncryptor` 和 `MessageVerifier` 添加密鑰輪換支援。
    ([拉取請求](https://github.com/rails/rails/pull/29716))

*   從 `HashWithIndifferentAccess#transform_keys` 返回 `HashWithIndifferentAccess` 的實例。
    ([拉取請求](https://github.com/rails/rails/pull/30728))

*   如果已定義，`Hash#slice` 現在會回退到 Ruby 2.5+ 內建的定義。
    ([提交](https://github.com/rails/rails/commit/01ae39660243bc5f0a986e20f9c9bff312b1b5f8))

*   `IO#to_json` 現在返回 `to_s` 的表示形式，而不是嘗試轉換為數組。這修復了在對不可讀對象調用 `IO#to_json` 時引發 `IOError` 的錯誤。
    ([拉取請求](https://github.com/rails/rails/pull/30953))

*   為 `Time#prev_day` 和 `Time#next_day` 添加與 `Date#prev_day` 和 `Date#next_day` 一致的方法簽名。允許為 `Time#prev_day` 和 `Time#next_day` 傳遞參數。
    ([提交](https://github.com/rails/rails/commit/61ac2167eff741bffb44aec231f4ea13d004134e))

*   為 `Time#prev_month` 和 `Time#next_month` 添加與 `Date#prev_month` 和 `Date#next_month` 一致的方法簽名。允許為 `Time#prev_month` 和 `Time#next_month` 傳遞參數。
    ([提交](https://github.com/rails/rails/commit/f2c1e3a793570584d9708aaee387214bc3543530))

*   為 `Time#prev_year` 和 `Time#next_year` 添加與 `Date#prev_year` 和 `Date#next_year` 一致的方法簽名。允許為 `Time#prev_year` 和 `Time#next_year` 傳遞參數。
    ([提交](https://github.com/rails/rails/commit/ee9d81837b5eba9d5ec869ae7601d7ffce763e3e))
* 修復 `humanize` 中的縮寫支援。
    ([Commit](https://github.com/rails/rails/commit/0ddde0a8fca6a0ca3158e3329713959acd65605d))

* 允許在 TWZ 範圍上使用 `Range#include?`。
    ([Pull Request](https://github.com/rails/rails/pull/31081))

* 快取：對於大於 1kB 的值，默認啟用壓縮。
    ([Pull Request](https://github.com/rails/rails/pull/31147))

* Redis 快取存儲。
    ([Pull Request](https://github.com/rails/rails/pull/31134),
    [Pull Request](https://github.com/rails/rails/pull/31866))

* 處理 `TZInfo::AmbiguousTime` 錯誤。
    ([Pull Request](https://github.com/rails/rails/pull/31128))

* MemCacheStore：支援過期計數器。
    ([Commit](https://github.com/rails/rails/commit/b22ee64b5b30c6d5039c292235e10b24b1057f6d))

* 使 `ActiveSupport::TimeZone.all` 只返回在 `ActiveSupport::TimeZone::MAPPING` 中的時區。
    ([Pull Request](https://github.com/rails/rails/pull/31176))

* 更改 `ActiveSupport::SecurityUtils.secure_compare` 的默認行為，使其即使對於變長的字符串也不會洩漏長度信息。
    將舊的 `ActiveSupport::SecurityUtils.secure_compare` 重命名為 `fixed_length_secure_compare`，並在傳遞的字符串長度不匹配時開始引發 `ArgumentError`。
    ([Pull Request](https://github.com/rails/rails/pull/24510))

* 使用 SHA-1 生成非敏感摘要，例如 ETag 標頭。
    ([Pull Request](https://github.com/rails/rails/pull/31289),
    [Pull Request](https://github.com/rails/rails/pull/31651))

* `assert_changes` 將始終斷言表達式發生變化，不論 `from:` 和 `to:` 參數組合如何。
    ([Pull Request](https://github.com/rails/rails/pull/31011))

* 在 `ActiveSupport::Cache::Store` 中為 `read_multi` 添加缺失的儀器。
    ([Pull Request](https://github.com/rails/rails/pull/30268))

* 在 `assert_difference` 中支援以哈希作為第一個參數。
    這允許在同一斷言中指定多個數值差異。
    ([Pull Request](https://github.com/rails/rails/pull/31600))

* 快取：MemCache 和 Redis 的 `read_multi` 和 `fetch_multi` 加速。
    在查詢後端之前從本地內存快取中讀取。
    ([Commit](https://github.com/rails/rails/commit/a2b97e4ffef971607a1be8fc7909f099b6840f36))

Active Job
----------

詳細更改請參閱 [Changelog][active-job]。

### 重要更改

* 允許將區塊傳遞給 `ActiveJob::Base.discard_on`，以允許自定義處理丟棄的工作。
    ([Pull Request](https://github.com/rails/rails/pull/30622))

Ruby on Rails Guides
--------------------

詳細更改請參閱 [Changelog][guides]。

### 重要更改

* 添加 [Rails 中的線程和代碼執行](threading_and_code_execution.html) 指南。
    ([Pull Request](https://github.com/rails/rails/pull/27494))

* 添加 [Active Storage 概述](active_storage_overview.html) 指南。
    ([Pull Request](https://github.com/rails/rails/pull/31037))

貢獻者
-------

請參閱 [Rails 的完整貢獻者列表](https://contributors.rubyonrails.org/)，感謝所有花費大量時間使 Rails 成為穩定且強大的框架的人。向他們致敬。

[railties]:       https://github.com/rails/rails/blob/5-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-2-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-2-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-2-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-2-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/5-2-stable/guides/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-2-stable/activesupport/CHANGELOG.md
