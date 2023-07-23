**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 95d91c83726e012162afc60c78688099
Ruby on Rails 4.1 發布說明
===============================

Rails 4.1 的亮點：

* Spring 應用程式預加載器
* `config/secrets.yml`
* Action Pack 變體
* Action Mailer 預覽

這些發布說明僅涵蓋主要更改。要了解各種錯誤修復和更改，請參閱變更日誌或查看 GitHub 上主要 Rails 存儲庫中的[提交列表](https://github.com/rails/rails/commits/4-1-stable)。

--------------------------------------------------------------------------------

升級到 Rails 4.1
----------------------

如果您正在升級現有應用程式，建議在進行之前進行良好的測試覆蓋率。您還應該先升級到 Rails 4.0（如果尚未升級），並確保應用程式在預期的情況下運行正常，然後再嘗試升級到 Rails 4.1。在升級時要注意的事項列表可在[升級 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1)指南中找到。

主要功能
--------------

### Spring 應用程式預加載器

Spring 是一個 Rails 應用程式預加載器。它通過在後台保持應用程式運行，加快了開發速度，因此您無需每次運行測試、rake 任務或遷移時都需要啟動它。

新的 Rails 4.1 應用程式將附帶“springified” binstubs。這意味著 `bin/rails` 和 `bin/rake` 將自動利用預加載的 spring 環境。

**執行 rake 任務：**

```bash
$ bin/rake test:models
```

**執行 Rails 命令：**

```bash
$ bin/rails console
```

**Spring 檢查：**

```bash
$ bin/spring status
Spring is running:

 1182 spring server | my_app | started 29 mins ago
 3656 spring app    | my_app | started 23 secs ago | test mode
 3746 spring app    | my_app | started 10 secs ago | development mode
```

請參閱 [Spring README](https://github.com/rails/spring/blob/master/README.md) 以查看所有可用功能。

有關如何將現有應用程式遷移到使用此功能的方法，請參閱[升級 Ruby on Rails](upgrading_ruby_on_rails.html#spring)指南。

### `config/secrets.yml`

Rails 4.1 在 `config` 文件夾中生成一個新的 `secrets.yml` 文件。默認情況下，此文件包含應用程式的 `secret_key_base`，但也可以用於存儲其他秘密，例如外部 API 的訪問金鑰。

添加到此文件中的秘密可以通過 `Rails.application.secrets` 訪問。例如，使用以下 `config/secrets.yml`：

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

在開發環境中，`Rails.application.secrets.some_api_key` 返回 `SOMEKEY`。

有關如何將現有應用程式遷移到使用此功能的方法，請參閱[升級 Ruby on Rails](upgrading_ruby_on_rails.html#config-secrets-yml)指南。

### Action Pack 變體

我們經常希望為手機、平板電腦和桌面瀏覽器渲染不同的 HTML/JSON/XML 模板。變體使這變得容易。

請求變體是請求格式的特殊化，例如 `:tablet`、`:phone` 或 `:desktop`。
你可以在 `before_action` 中設置變體：

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

在動作中回應變體就像回應格式一樣：

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # 渲染 app/views/projects/show.html+tablet.erb
    html.phone { extra_setup; render ... }
  end
end
```

為每個格式和變體提供單獨的模板：

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

你也可以使用內聯語法簡化變體定義：

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```

### Action Mailer 預覽

Action Mailer 預覽提供了一種通過訪問特殊 URL 來查看電子郵件外觀的方法。

你可以實現一個預覽類，其方法返回你想要檢查的郵件對象：

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

預覽可在 http://localhost:3000/rails/mailers/notifier/welcome 中訪問，
並在 http://localhost:3000/rails/mailers 中列出。

默認情況下，這些預覽類位於 `test/mailers/previews`。
可以使用 `preview_path` 選項進行配置。

請參閱其
[文檔](https://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails)
以獲取詳細的說明。

### Active Record 枚舉

聲明一個枚舉屬性，其中的值在數據庫中映射為整數，但可以按名稱查詢。

```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => 所有已存檔對話的關聯

Conversation.statuses # => { "active" => 0, "archived" => 1 }
```

請參閱其
[文檔](https://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html)
以獲取詳細的說明。

### 消息驗證器

消息驗證器可用於生成和驗證簽名消息。這對於安全地傳輸像記住我令牌和好友等敏感數據非常有用。

方法 `Rails.application.message_verifier` 返回一個新的消息驗證器，
該驗證器使用從 secret_key_base 和給定的消息驗證器名稱派生的密鑰對消息進行簽名：

```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# raises ActiveSupport::MessageVerifier::InvalidSignature
```

### Module#concerning

在類內部分離責任的一種自然、低儀式的方式：

```ruby
class Todo < ActiveRecord::Base
  concerning :EventTracking do
    included do
      has_many :events
    end

    def latest_event
      # ...
    end

    private
      def some_internal_method
        # ...
      end
  end
end
```

此示例等同於在內聯定義一個 `EventTracking` 模塊，將其擴展為 `ActiveSupport::Concern`，然後混入到 `Todo` 類中。

請參閱其
[文檔](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html)
以獲取詳細的說明和預期的用例。

### 遠程 `<script>` 標籤的 CSRF 保護

跨站請求偽造（CSRF）保護現在也適用於帶有 JavaScript 響應的 GET 請求。這可以防止第三方網站引用你的 JavaScript URL 並嘗試運行它以提取敏感數據。
這意味著，除非使用`xhr`，否則任何命中`.js` URL的測試都將無法通過CSRF保護。請升級您的測試，明確指定期望的XmlHttpRequests。將`post :create, format: :js`改為明確的`xhr :post, :create, format: :js`。

Railties
--------

詳細更改請參閱[變更日誌](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md)。

### 刪除項目

* 刪除了`update:application_controller` rake任務。

* 刪除了已棄用的`Rails.application.railties.engines`。

* 刪除了Rails Config中已棄用的`threadsafe!`。

* 刪除了已棄用的`ActiveRecord::Generators::ActiveModel#update_attributes`，改用`ActiveRecord::Generators::ActiveModel#update`。

* 刪除了已棄用的`config.whiny_nils`選項。

* 刪除了運行測試的已棄用rake任務：`rake test:uncommitted`和`rake test:recent`。

### 重要更改

* 新應用程式默認安裝[Spring應用程式預加載器](https://github.com/rails/spring)。它使用`Gemfile`的開發組，因此不會安裝在生產環境中。([拉取請求](https://github.com/rails/rails/pull/12958))

* `BACKTRACE`環境變量用於顯示測試失敗的未過濾回溯。([提交](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553))

* 將`MiddlewareStack#unshift`暴露給環境配置。([拉取請求](https://github.com/rails/rails/pull/12479))

* 添加`Application#message_verifier`方法以返回消息驗證器。([拉取請求](https://github.com/rails/rails/pull/12995))

* 默認生成的測試輔助文件`test_help.rb`將自動使用`db/schema.rb`（或`db/structure.sql`）保持測試數據庫的最新狀態。如果重新加載模式未解決所有待定的遷移，它將引發錯誤。通過`config.active_record.maintain_test_schema = false`來取消設置。([拉取請求](https://github.com/rails/rails/pull/13528))

* 引入`Rails.gem_version`作為一個方便的方法，返回`Gem::Version.new(Rails.version)`，建議使用更可靠的方式進行版本比較。([拉取請求](https://github.com/rails/rails/pull/14103))


Action Pack
-----------

詳細更改請參閱[變更日誌](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md)。

### 刪除項目

* 刪除了集成測試的Rails應用程式回退，改為設置`ActionDispatch.test_app`。

* 刪除了已棄用的`page_cache_extension`配置。

* 刪除了Action Controller中的已棄用常量，使用`ActionView::RecordIdentifier`代替`ActionController::RecordIdentifier`。

* 從Action Controller中刪除了已棄用的常量：

| 刪除項目                            | 後繼者                       |
|:-----------------------------------|:--------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### 重要更改

* `protect_from_forgery`還防止跨域`<script>`標籤。更新您的測試，使用`xhr :get, :foo, format: :js`代替`get :foo, format: :js`。([拉取請求](https://github.com/rails/rails/pull/13345))

* `#url_for`接受包含選項的哈希在數組中。([拉取請求](https://github.com/rails/rails/pull/9599))

* 添加了`session#fetch`方法，該方法的行為類似於[Hash#fetch](https://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch)，唯一的區別是返回的值始終保存在會話中。([拉取請求](https://github.com/rails/rails/pull/12692))

* 將Action View完全從Action Pack中分離。([拉取請求](https://github.com/rails/rails/pull/11032))

* 記錄哪些鍵受到深度修改的影響。([拉取請求](https://github.com/rails/rails/pull/13813))

* 新的配置選項`config.action_dispatch.perform_deep_munge`，用於取消參數的“深度修改”，該修改用於解決安全漏洞CVE-2013-0155。([拉取請求](https://github.com/rails/rails/pull/13188))
* 新的配置選項 `config.action_dispatch.cookies_serializer` 用於指定簽名和加密 cookie 存儲的序列化器。 (拉取請求 [1](https://github.com/rails/rails/pull/13692), [2](https://github.com/rails/rails/pull/13945) / [更多詳情](upgrading_ruby_on_rails.html#cookies-serializer))

* 添加了 `render :plain`, `render :html` 和 `render :body`。 (拉取請求 [1](https://github.com/rails/rails/pull/14062) / [更多詳情](upgrading_ruby_on_rails.html#rendering-content-from-string))


Action Mailer
-------------

詳細更改請參考 [Changelog](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md)。

### 重要更改

* 基於 37 Signals mail_view gem 添加了郵件預覽功能。 ([提交](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261))

* 對 Action Mailer 消息生成進行儀表盤記錄。生成消息所需的時間將被記錄到日誌中。 ([拉取請求](https://github.com/rails/rails/pull/12556))


Active Record
-------------

詳細更改請參考 [Changelog](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md)。

### 刪除項目

* 刪除了對以下 `SchemaCache` 方法傳遞空值的過時支援：`primary_keys`、`tables`、`columns` 和 `columns_hash`。

* 刪除了 `ActiveRecord::Migrator#migrate` 中的過時塊過濾器。

* 刪除了 `ActiveRecord::Migrator` 中的過時字符串構造函數。

* 刪除了在不傳遞可調用對象的情況下使用 `scope` 的過時用法。

* 刪除了 `transaction_joinable=` 的過時用法，改用帶有 `:joinable` 選項的 `begin_transaction`。

* 刪除了 `decrement_open_transactions` 的過時用法。

* 刪除了 `increment_open_transactions` 的過時用法。

* 刪除了 `PostgreSQLAdapter#outside_transaction?` 方法的過時支援。現在可以使用 `#transaction_open?` 代替。

* 刪除了 `ActiveRecord::Fixtures.find_table_name` 的過時用法，改用 `ActiveRecord::Fixtures.default_fixture_model_name`。

* 刪除了 `SchemaStatements` 中的 `columns_for_remove` 的過時用法。

* 刪除了 `SchemaStatements#distinct` 的過時用法。

* 將過時的 `ActiveRecord::TestCase` 移至 Rails 測試套件中。該類別不再是公開的，僅用於內部 Rails 測試。

* 刪除了關聯中過時的 `:dependent` 選項中的過時 `:restrict` 選項支援。

* 刪除了關聯中過時的 `:delete_sql`、`:insert_sql`、`:finder_sql` 和 `:counter_sql` 選項支援。

* 刪除了 Column 中的過時 `type_cast_code` 方法。

* 刪除了 `ActiveRecord::Base#connection` 的過時方法。請確保通過類別訪問它。

* 刪除了 `auto_explain_threshold_in_seconds` 的過時警告。

* 刪除了 `Relation#count` 中的過時 `:distinct` 選項。

* 刪除了過時的方法 `partial_updates`、`partial_updates?` 和 `partial_updates=`。

* 刪除了過時的方法 `scoped`。

* 刪除了過時的方法 `default_scopes?`。

* 刪除了在 4.0 中過時的隱式連接引用。

* 刪除了 `activerecord-deprecated_finders` 的依賴。詳情請參閱 [gem README](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders)。

* 刪除了對 `implicit_readonly` 的使用。請明確使用 `readonly` 方法將記錄標記為 `readonly`。 ([拉取請求](https://github.com/rails/rails/pull/10769))

### 過時項目

* 過時的 `quoted_locking_column` 方法，未在任何地方使用。

* 過時的 `ConnectionAdapters::SchemaStatements#distinct`，因為內部不再使用。 ([拉取請求](https://github.com/rails/rails/pull/10556))

* 過時的 `rake db:test:*` 任務，因為測試數據庫現在會自動維護。請參閱 railties 發行說明。 ([拉取請求](https://github.com/rails/rails/pull/13528))

* 過時的未使用 `ActiveRecord::Base.symbolized_base_class` 和 `ActiveRecord::Base.symbolized_sti_name`，無替代方案。[提交](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)

### 重要更改

* 默認作用域不再被同一字段的鏈式條件覆蓋。

  在此更改之前，當您在模型中定義了 `default_scope` 時，它會被同一字段的鏈式條件覆蓋。現在它會像其他作用域一樣合併。[更多詳情](upgrading_ruby_on_rails.html#changes-on-default-scopes)。
* 新增 `ActiveRecord::Base.to_param`，用於方便地從模型的屬性或方法中獲取「漂亮」的URL。 ([Pull Request](https://github.com/rails/rails/pull/12891))

* 新增 `ActiveRecord::Base.no_touching`，允許忽略對模型的觸發。 ([Pull Request](https://github.com/rails/rails/pull/12772))

* 統一 `MysqlAdapter` 和 `Mysql2Adapter` 的布林型轉換。`type_cast` 將返回 `true` 的 `1` 和 `false` 的 `0`。 ([Pull Request](https://github.com/rails/rails/pull/12425))

* `.unscope` 現在會刪除 `default_scope` 中指定的條件。 ([Commit](https://github.com/rails/rails/commit/94924dc32baf78f13e289172534c2e71c9c8cade))

* 新增 `ActiveRecord::QueryMethods#rewhere`，它將覆蓋現有的命名 where 條件。 ([Commit](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2))

* 擴展 `ActiveRecord::Base#cache_key`，可以接受一個可選的時間戳屬性列表，其中最高的屬性將被使用。 ([Commit](https://github.com/rails/rails/commit/e94e97ca796c0759d8fcb8f946a3bbc60252d329))

* 新增 `ActiveRecord::Base#enum`，用於聲明枚舉屬性，其中的值在數據庫中映射為整數，但可以按名稱進行查詢。 ([Commit](https://github.com/rails/rails/commit/db41eb8a6ea88b854bf5cd11070ea4245e1639c5))

* 在寫入時對 JSON 值進行類型轉換，以使值與從數據庫讀取的值一致。 ([Pull Request](https://github.com/rails/rails/pull/12643))

* 在寫入時對 hstore 值進行類型轉換，以使值與從數據庫讀取的值一致。 ([Commit](https://github.com/rails/rails/commit/5ac2341fab689344991b2a4817bd2bc8b3edac9d))

* 使 `next_migration_number` 可以被第三方生成器訪問。 ([Pull Request](https://github.com/rails/rails/pull/12407))

* 當調用 `update_attributes` 時，如果參數為 `nil`，將拋出 `ArgumentError`。具體來說，如果傳遞的參數不響應 `stringify_keys`，則會拋出錯誤。 ([Pull Request](https://github.com/rails/rails/pull/9860))

* `CollectionAssociation#first`/`#last`（例如 `has_many`）使用 `LIMIT` 查詢來獲取結果，而不是加載整個集合。 ([Pull Request](https://github.com/rails/rails/pull/12137))

* 在 Active Record 模型類的 `inspect` 中不會初始化新的連接。這意味著在缺少數據庫時調用 `inspect` 將不再引發異常。 ([Pull Request](https://github.com/rails/rails/pull/11014))

* 刪除 `count` 的列限制，如果 SQL 無效，則由數據庫引發異常。 ([Pull Request](https://github.com/rails/rails/pull/10710))

* Rails 現在可以自動檢測逆向關聯。如果在關聯上未設置 `:inverse_of` 選項，Active Record 將根據啟發法猜測逆向關聯。 ([Pull Request](https://github.com/rails/rails/pull/10886))

* 在 ActiveRecord::Relation 中處理別名屬性。使用符號鍵時，ActiveRecord 現在會將別名屬性名稱轉換為數據庫中使用的實際列名。 ([Pull Request](https://github.com/rails/rails/pull/7839))

* 現在在夾具文件中的 ERB 不再在主對象的上下文中評估。多個夾具使用的輔助方法應該定義在包含在 `ActiveRecord::FixtureSet.context_class` 中的模塊中。 ([Pull Request](https://github.com/rails/rails/pull/13022))

* 如果明確指定了 RAILS_ENV，則不創建或刪除測試數據庫。 ([Pull Request](https://github.com/rails/rails/pull/13629))

* `Relation` 不再具有像 `#map!` 和 `#delete_if` 這樣的變異方法。在使用這些方法之前，請調用 `#to_a` 將其轉換為 `Array`。 ([Pull Request](https://github.com/rails/rails/pull/13314))

* `find_in_batches`、`find_each`、`Result#each` 和 `Enumerable#index_by` 現在返回一個可以計算其大小的 `Enumerator`。 ([Pull Request](https://github.com/rails/rails/pull/13938))
* `scope`、`enum`和關聯現在會引發「危險」名稱衝突的錯誤。([拉取請求](https://github.com/rails/rails/pull/13450)、[拉取請求](https://github.com/rails/rails/pull/13896))

* `second`到`fifth`方法的作用與`first`查詢器相同。([拉取請求](https://github.com/rails/rails/pull/13757))

* 讓`touch`觸發`after_commit`和`after_rollback`回調。([拉取請求](https://github.com/rails/rails/pull/12031))

* 對於`sqlite >= 3.8.0`啟用部分索引。([拉取請求](https://github.com/rails/rails/pull/13350))

* 讓`change_column_null`可逆轉。([提交](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96))

* 增加了一個標誌以在遷移後禁用模式傾印。對於新應用程序的生產環境，默認設置為`false`。([拉取請求](https://github.com/rails/rails/pull/13948))

Active Model
------------

詳細更改請參閱[變更日誌](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md)。

### 廢棄

* 廢棄`Validator#setup`。現在應在驗證器的構造函數中手動完成此操作。([提交](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a))

### 重要更改

* 在`ActiveModel::Dirty`中添加了新的API方法`reset_changes`和`changes_applied`，用於控制更改狀態。

* 在定義驗證時能夠指定多個上下文。([拉取請求](https://github.com/rails/rails/pull/13754))

* `attribute_changed?`現在接受一個哈希來檢查屬性是否已更改為給定的`:from`和/或`:to`值。([拉取請求](https://github.com/rails/rails/pull/13131))


Active Support
--------------

詳細更改請參閱[變更日誌](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md)。


### 刪除

* 刪除了`MultiJSON`依賴。因此，`ActiveSupport::JSON.decode`不再接受`MultiJSON`的選項哈希。([拉取請求](https://github.com/rails/rails/pull/10576) / [更多詳情](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 刪除了將自定義對象編碼為JSON的`encode_json`鉤子的支持。此功能已提取到[activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem中。([相關拉取請求](https://github.com/rails/rails/pull/12183) / [更多詳情](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 刪除了已棄用的`ActiveSupport::JSON::Variable`，沒有替代品。

* 刪除了已棄用的`String#encoding_aware?`核心擴展（`core_ext/string/encoding`）。

* 刪除了已棄用的`Module#local_constant_names`，改用`Module#local_constants`。

* 刪除了已棄用的`DateTime.local_offset`，改用`DateTime.civil_from_format`。

* 刪除了已棄用的`Logger`核心擴展（`core_ext/logger.rb`）。

* 刪除了已棄用的`Time#time_with_datetime_fallback`、`Time#utc_time`和`Time#local_time`，改用`Time#utc`和`Time#local`。

* 刪除了已棄用的`Hash#diff`，沒有替代品。

* 刪除了已棄用的`Date#to_time_in_current_zone`，改用`Date#in_time_zone`。

* 刪除了已棄用的`Proc#bind`，沒有替代品。

* 刪除了已棄用的`Array#uniq_by`和`Array#uniq_by!`，改用原生的`Array#uniq`和`Array#uniq!`。

* 刪除了已棄用的`ActiveSupport::BasicObject`，改用`ActiveSupport::ProxyObject`。

* 刪除了已棄用的`BufferedLogger`，改用`ActiveSupport::Logger`。

* 刪除了已棄用的`assert_present`和`assert_blank`方法，改用`assert object.blank?`和`assert object.present?`。

* 刪除了過濾器對象的已棄用的`#filter`方法，改用相應的方法（例如，`#before`用於前置過濾器）。

* 從默認的變形中刪除了'cow' => 'kine'的不規則變形。([提交](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9))

### 廢棄

* 廢棄了`Numeric#{ago,until,since,from_now}`，用戶應該將值明確轉換為AS::Duration，即`5.ago` => `5.seconds.ago`。([拉取請求](https://github.com/rails/rails/pull/12389))

* 廢棄了`active_support/core_ext/object/to_json`的require路徑。請改為使用`active_support/core_ext/object/json`。([拉取請求](https://github.com/rails/rails/pull/12203))

* 廢棄了`ActiveSupport::JSON::Encoding::CircularReferenceError`。此功能已提取到[activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem中。([拉取請求](https://github.com/rails/rails/pull/12785) / [更多詳情](upgrading_ruby_on_rails.html#changes-in-json-handling))
* 已棄用 `ActiveSupport.encode_big_decimal_as_string` 選項。此功能已被提取到 [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem 中。
  ([Pull Request](https://github.com/rails/rails/pull/13060) /
  [更多詳細資訊](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 廢棄自訂的 `BigDecimal` 序列化。([Pull Request](https://github.com/rails/rails/pull/13911))

### 重要變更

* `ActiveSupport` 的 JSON 編碼器已被重寫，以利用 JSON gem 而不是在純 Ruby 中進行自訂編碼。
  ([Pull Request](https://github.com/rails/rails/pull/12183) /
  [更多詳細資訊](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 改善與 JSON gem 的相容性。
  ([Pull Request](https://github.com/rails/rails/pull/12862) /
  [更多詳細資訊](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 新增 `ActiveSupport::Testing::TimeHelpers#travel` 和 `#travel_to`。這些方法通過存根 `Time.now` 和 `Date.today`，將當前時間更改為指定的時間或持續時間。

* 新增 `ActiveSupport::Testing::TimeHelpers#travel_back`。此方法通過刪除 `travel` 和 `travel_to` 添加的存根，將當前時間返回到原始狀態。([Pull Request](https://github.com/rails/rails/pull/13884))

* 新增 `Numeric#in_milliseconds`，例如 `1.hour.in_milliseconds`，以便將它們傳遞給 JavaScript 函數，如 `getTime()`。([Commit](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643))

* 新增 `Date#middle_of_day`、`DateTime#middle_of_day` 和 `Time#middle_of_day` 方法。還新增了 `midday`、`noon`、`at_midday`、`at_noon` 和 `at_middle_of_day` 作為別名。([Pull Request](https://github.com/rails/rails/pull/10879))

* 新增 `Date#all_week/month/quarter/year` 用於生成日期範圍。([Pull Request](https://github.com/rails/rails/pull/9685))

* 新增 `Time.zone.yesterday` 和 `Time.zone.tomorrow`。([Pull Request](https://github.com/rails/rails/pull/12822))

* 新增 `String#remove(pattern)` 作為常見模式 `String#gsub(pattern,'')` 的簡寫。([Commit](https://github.com/rails/rails/commit/5da23a3f921f0a4a3139495d2779ab0d3bd4cb5f))

* 新增 `Hash#compact` 和 `Hash#compact!` 用於從哈希中刪除值為 nil 的項目。([Pull Request](https://github.com/rails/rails/pull/13632))

* `blank?` 和 `present?` 現在返回單例值。([Commit](https://github.com/rails/rails/commit/126dc47665c65cd129967cbd8a5926dddd0aa514))

* 將新的 `I18n.enforce_available_locales` 配置默認為 `true`，這意味著 `I18n` 將確保所有傳遞給它的區域必須在 `available_locales` 列表中聲明。([Pull Request](https://github.com/rails/rails/pull/13341))

* 引入 `Module#concerning`：一種自然、低儀式的方式來在類中分離責任。([Commit](https://github.com/rails/rails/commit/1eee0ca6de975b42524105a59e0521d18b38ab81))

* 新增 `Object#presence_in`，以簡化將值添加到允許列表的操作。([Commit](https://github.com/rails/rails/commit/4edca106daacc5a159289eae255207d160f22396))


貢獻者
-------

請參閱 [Rails 的完整貢獻者列表](https://contributors.rubyonrails.org/)，感謝那些花了很多時間使 Rails 成為穩定且強大的框架的人。向他們致敬。
