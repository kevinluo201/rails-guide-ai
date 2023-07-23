**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ddd82b1a207070829b1ec46e4bb40d80
Ruby on Rails 5.1 發行說明
===============================

Rails 5.1 的亮點：

* 支援 Yarn
* 可選擇支援 Webpack
* jQuery 不再是預設的相依性
* 系統測試
* 加密的秘密
* 參數化的郵件發送器
* 直接和解析的路由
* 將 form_for 和 form_tag 統一為 form_with

這些發行說明僅涵蓋主要更改。要了解各種錯誤修復和更改，請參閱變更日誌或查看 GitHub 上主要 Rails 存儲庫中的[提交清單](https://github.com/rails/rails/commits/5-1-stable)。

--------------------------------------------------------------------------------

升級到 Rails 5.1
----------------------

如果您正在升級現有應用程式，建議在進行升級之前先進行良好的測試覆蓋率。如果尚未升級到 Rails 5.0，請先升級到該版本，並確保您的應用程式在預期的情況下運行正常，然後再嘗試升級到 Rails 5.1。在升級時要注意的事項清單可在[升級 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1)指南中找到。

主要功能
--------------

### 支援 Yarn

[拉取請求](https://github.com/rails/rails/pull/26836)

Rails 5.1 允許通過 Yarn 管理 npm 的 JavaScript 相依性。這將使使用 React、VueJS 或其他 npm 世界的庫變得容易。Yarn 支援與資產管線集成，以便所有相依性都能與 Rails 5.1 應用程式無縫運作。

### 可選擇支援 Webpack

[拉取請求](https://github.com/rails/rails/pull/27288)

Rails 應用程式可以更輕鬆地與 JavaScript 資產捆綁工具 [Webpack](https://webpack.js.org/) 整合，使用新的 [Webpacker](https://github.com/rails/webpacker) 寶石。在生成新應用程式時，使用 `--webpack` 標誌啟用 Webpack 整合。

這與資產管線完全兼容，您可以繼續使用它來處理圖像、字型、音效和其他資產。您甚至可以將一些 JavaScript 代碼由資產管線管理，將其他代碼通過 Webpack 處理。所有這些都由預設啟用的 Yarn 管理。

### jQuery 不再是預設的相依性

[拉取請求](https://github.com/rails/rails/pull/27113)

在早期版本的 Rails 中，預設需要 jQuery 來提供 `data-remote`、`data-confirm` 和其他 Rails 的非侵入式 JavaScript 功能。現在不再需要，因為 UJS 已被重寫為使用純粹的 JavaScript。這段程式碼現在作為 `rails-ujs` 包含在 Action View 中。

如果需要，仍然可以使用 jQuery，但不再是預設要求。

### 系統測試

[拉取請求](https://github.com/rails/rails/pull/26703)

Rails 5.1 內建支援使用 Capybara 進行測試，形式上稱為系統測試。您不再需要擔心為此類測試配置 Capybara 和資料庫清理策略。Rails 5.1 提供了一個包裝器，用於在 Chrome 中運行測試，並提供了額外功能，如失敗截圖。
### 加密的密碼

[拉取請求](https://github.com/rails/rails/pull/28038)

Rails現在允許以安全的方式管理應用程式密碼，受到[sekrets](https://github.com/ahoward/sekrets) gem的啟發。

運行`bin/rails secrets:setup`來設置新的加密密碼檔案。這也會生成一個必須存儲在存儲庫之外的主密鑰。然後，這些密碼本身可以以加密形式安全地檢入版本控制系統。

在生產環境中，將使用存儲在`RAILS_MASTER_KEY`環境變量或密鑰文件中的密鑰來解密密碼。

### 參數化的郵件發送器

[拉取請求](https://github.com/rails/rails/pull/27825)

允許在郵件發送器類中為所有方法指定共用的參數，以便共享實例變量、標頭和其他共用設置。

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name} 邀請您加入他們的Basecamp（#{@account.name}）"
  end
end
```

```ruby
InvitationsMailer.with(inviter: person_a, invitee: person_b)
                 .account_invitation.deliver_later
```

### 直接和解析的路由

[拉取請求](https://github.com/rails/rails/pull/23138)

Rails 5.1新增了兩個新方法，`resolve`和`direct`，用於路由DSL。`resolve`方法允許自定義模型的多態映射。

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_for @basket do |form| %>
  <!-- basket form -->
<% end %>
```

這將生成單數URL `/basket`，而不是通常的 `/baskets/:id`。

`direct`方法允許創建自定義的URL助手。

```ruby
direct(:homepage) { "https://rubyonrails.org" }

homepage_url # => "https://rubyonrails.org"
```

塊的返回值必須是`url_for`方法的有效參數。因此，您可以傳遞有效的字符串URL、Hash、Array、Active Model實例或Active Model類。

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### 將form_for和form_tag統一為form_with

[拉取請求](https://github.com/rails/rails/pull/26976)

在Rails 5.1之前，處理HTML表單有兩個接口：`form_for`用於模型實例，`form_tag`用於自定義URL。

Rails 5.1使用`form_with`將這兩個接口結合起來，並且可以基於URL、作用域或模型生成表單標籤。

僅使用URL：

```erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 將生成 %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

添加作用域將輸入字段名稱加上前綴：

```erb
<%= form_with scope: :post, url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 將生成 %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```
使用模型可以推斷出URL和範圍：

```erb
<%= form_with model: Post.new do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 會生成以下內容 %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

現有的模型可以生成更新表單並填寫字段值：

```erb
<%= form_with model: Post.first do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 會生成以下內容 %>

<form action="/posts/1" method="post" data-remote="true">
  <input type="hidden" name="_method" value="patch">
  <input type="text" name="post[title]" value="<文章的標題>">
</form>
```

不相容性
-----------------

以下更改可能需要立即採取行動以進行升級。

### 使用多個連接進行事務測試

事務測試現在將所有Active Record連接包裝在數據庫事務中。

當測試生成其他線程並且這些線程獲取數據庫連接時，這些連接現在將被特殊處理：

這些線程將共享一個連接，該連接位於管理的事務內。這確保所有線程在相同的狀態下看到數據庫，忽略最外層的事務。以前，這樣的額外連接無法看到fixture行，例如。

當線程進入嵌套事務時，它將暫時獲得對連接的獨占使用，以保持隔離。

如果您的測試目前依賴於在生成的線程中獲取單獨的、不在事務中的連接，則需要切換到更明確的連接管理。

如果您的測試生成線程並且這些線程在同時使用顯式數據庫事務時進行交互，此更改可能會引入死鎖。

退出此新行為的簡單方法是在受其影響的任何測試用例上禁用事務測試。

Railties
--------

詳細更改請參閱[變更日誌][railties]。

### 刪除

*   刪除已棄用的`config.static_cache_control`。
    ([commit](https://github.com/rails/rails/commit/c861decd44198f8d7d774ee6a74194d1ac1a5a13))

*   刪除已棄用的`config.serve_static_files`。
    ([commit](https://github.com/rails/rails/commit/0129ca2eeb6d5b2ea8c6e6be38eeb770fe45f1fa))

*   刪除已棄用的文件`rails/rack/debugger`。
    ([commit](https://github.com/rails/rails/commit/7563bf7b46e6f04e160d664e284a33052f9804b8))

*   刪除已棄用的任務：`rails:update`、`rails:template`、`rails:template:copy`、
    `rails:update:configs`和`rails:update:bin`。
    ([commit](https://github.com/rails/rails/commit/f7782812f7e727178e4a743aa2874c078b722eef))

*   刪除`routes`任務的已棄用`CONTROLLER`環境變量。
    ([commit](https://github.com/rails/rails/commit/f9ed83321ac1d1902578a0aacdfe55d3db754219))

*   從`rails new`命令中刪除-j（--javascript）選項。
    ([Pull Request](https://github.com/rails/rails/pull/28546))

### 重要更改

*   在`config/secrets.yml`中添加了一個共享部分，將在所有環境中加載。
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   現在使用符號作為所有鍵將`config/secrets.yml`配置文件加載。
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   從默認堆棧中刪除jquery-rails。rails-ujs是Action View附帶的默認UJS適配器。
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   在新應用程序中添加Yarn支持，包括yarn binstub和package.json。
    ([Pull Request](https://github.com/rails/rails/pull/26836))

*   通過`--webpack`選項在新應用程序中添加Webpack支持，該選項將委派給rails/webpacker gem。
    ([Pull Request](https://github.com/rails/rails/pull/27288))
*   在生成新應用程式時，如果沒有提供 `--skip-git` 選項，則初始化 Git 儲存庫。
    ([Pull Request](https://github.com/rails/rails/pull/27632))

*   在 `config/secrets.yml.enc` 中添加加密的密鑰。
    ([Pull Request](https://github.com/rails/rails/pull/28038))

*   在 `rails initializers` 中顯示 railtie 類別名稱。
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

詳細變更請參閱 [Changelog][action-cable]。

### 重要變更

*   在 `cable.yml` 中為 Redis 和事件驅動的 Redis 适配器添加對 `channel_prefix` 的支援，以避免在使用相同的 Redis 伺服器時出現名稱衝突。
    ([Pull Request](https://github.com/rails/rails/pull/27425))

*   為廣播資料添加 `ActiveSupport::Notifications` 鉤子。
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

詳細變更請參閱 [Changelog][action-pack]。

### 刪除項目

*   移除 `ActionDispatch::IntegrationTest` 和 `ActionController::TestCase` 類別中 `#process`、`#get`、`#post`、`#patch`、`#put`、`#delete` 和 `#head` 中的非關鍵字參數支援。
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

*   移除已棄用的 `ActionDispatch::Callbacks.to_prepare` 和 `ActionDispatch::Callbacks.to_cleanup`。
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

*   移除已棄用的與控制器過濾器相關的方法。
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

*   移除在 `render` 中對 `:text` 和 `:nothing` 的支援。
    ([Commit](https://github.com/rails/rails/commit/79a5ea9eadb4d43b62afacedc0706cbe88c54496),
    [Commit](https://github.com/rails/rails/commit/57e1c99a280bdc1b324936a690350320a1cd8111))

*   移除在 `ActionController::Parameters` 上調用 `HashWithIndifferentAccess` 方法的支援。
    ([Commit](https://github.com/rails/rails/pull/26746/commits/7093ceb480ad6a0a91b511832dad4c6a86981b93))

### 已棄用項目

*   已棄用 `config.action_controller.raise_on_unfiltered_parameters`。在 Rails 5.1 中不再生效。
    ([Commit](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### 重要變更

*   在路由 DSL 中添加 `direct` 和 `resolve` 方法。
    ([Pull Request](https://github.com/rails/rails/pull/23138))

*   添加新的 `ActionDispatch::SystemTestCase` 類別，用於在應用程式中編寫系統測試。
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

詳細變更請參閱 [Changelog][action-view]。

### 刪除項目

*   移除 `ActionView::Template::Error` 中的已棄用 `#original_exception`。
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

*   從 `strip_tags` 中移除名稱錯誤的 `encode_special_chars` 選項。
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### 已棄用項目

*   已棄用 Erubis ERB 處理器，改用 Erubi。
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### 重要變更

*   Raw 樣板處理器（Rails 5 中的預設樣板處理器）現在輸出 HTML 安全字串。
    ([commit](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

*   將 `datetime_field` 和 `datetime_field_tag` 更改為生成 `datetime-local` 欄位。
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   HTML 標籤的新 Builder-style 語法（`tag.div`、`tag.br` 等）。
    ([Pull Request](https://github.com/rails/rails/pull/25543))

*   添加 `form_with` 以統一 `form_tag` 和 `form_for` 的用法。
    ([Pull Request](https://github.com/rails/rails/pull/26976))

*   在 `current_page?` 中添加 `check_parameters` 選項。
    ([Pull Request](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

詳細變更請參閱 [Changelog][action-mailer]。

### 重要變更

*   允許在包含附件並設置內容為內嵌的情況下設置自定義內容類型。
    ([Pull Request](https://github.com/rails/rails/pull/27227))

*   允許將 lambda 函式作為 `default` 方法的值。
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   添加對郵件的參數化調用支援，以在不同的郵件動作之間共享前置過濾器和默認值。
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   在 `process.action_mailer` 事件中將傳入的引數傳遞給郵件動作，並以 `args` 鍵的形式傳遞。
    ([Pull Request](https://github.com/rails/rails/pull/27900))

Active Record
-------------

詳細變更請參閱 [Changelog][active-record]。

### 刪除項目
*   移除了將參數和區塊同時傳遞給`ActiveRecord::QueryMethods#select`的支援。
    ([Commit](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

*   移除了已棄用的`activerecord.errors.messages.restrict_dependent_destroy.one`和
    `activerecord.errors.messages.restrict_dependent_destroy.many`的i18n範圍。
    ([Commit](https://github.com/rails/rails/commit/00e3973a311))

*   移除了單數和集合關聯讀取器中已棄用的force-reload參數。
    ([Commit](https://github.com/rails/rails/commit/09cac8c67af))

*   移除了將列傳遞給`#quote`的已棄用支援。
    ([Commit](https://github.com/rails/rails/commit/e646bad5b7c))

*   移除了`#tables`中的已棄用`name`參數。
    ([Commit](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

*   移除了`#tables`和`#table_exists?`的已棄用行為，僅返回表而不返回視圖。
    ([Commit](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

*   移除了`ActiveRecord::StatementInvalid#initialize`和`ActiveRecord::StatementInvalid#original_exception`中的已棄用`original_exception`參數。
    ([Commit](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

*   移除了將類別作為查詢值的已棄用支援。
    ([Commit](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

*   移除了使用逗號進行LIMIT查詢的已棄用支援。
    ([Commit](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

*   移除了`#destroy_all`中的已棄用`conditions`參數。
    ([Commit](https://github.com/rails/rails/commit/d31a6d1384cd740c8518d0bf695b550d2a3a4e9b))

*   移除了`#delete_all`中的已棄用`conditions`參數。
    ([Commit](https://github.com/rails/rails/pull/27503/commits/e7381d289e4f8751dcec9553dcb4d32153bd922b))

*   移除了`#load_schema_for`方法的已棄用支援，改用`#load_schema`。
    ([Commit](https://github.com/rails/rails/commit/419e06b56c3b0229f0c72d3e4cdf59d34d8e5545))

*   移除了`#raise_in_transactional_callbacks`配置的已棄用支援。
    ([Commit](https://github.com/rails/rails/commit/8029f779b8a1dd9848fee0b7967c2e0849bf6e07))

*   移除了`#use_transactional_fixtures`配置的已棄用支援。
    ([Commit](https://github.com/rails/rails/commit/3955218dc163f61c932ee80af525e7cd440514b3))

### 已棄用功能

*   已棄用`error_on_ignored_order_or_limit`標誌，改用`error_on_ignored_order`。
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   已棄用`sanitize_conditions`，改用`sanitize_sql`。
    ([Pull Request](https://github.com/rails/rails/pull/25999))

*   已棄用連接適配器上的`supports_migrations?`。
    ([Pull Request](https://github.com/rails/rails/pull/28172))

*   已棄用`Migrator.schema_migrations_table_name`，改用`SchemaMigration.table_name`。
    ([Pull Request](https://github.com/rails/rails/pull/28351))

*   已棄用在引用和類型轉換中使用`#quoted_id`。
    ([Pull Request](https://github.com/rails/rails/pull/27962))

*   已棄用將`default`參數傳遞給`#index_name_exists?`。
    ([Pull Request](https://github.com/rails/rails/pull/26930))

### 重要更改

*   將預設主鍵更改為BIGINT。
    ([Pull Request](https://github.com/rails/rails/pull/26266))

*   支援MySQL 5.7.5+和MariaDB 5.2.0+的虛擬/生成列。
    ([Commit](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

*   在批次處理中添加對限制的支援。
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   事務測試現在將所有Active Record連接包裝在數據庫事務中。
    ([Pull Request](https://github.com/rails/rails/pull/28726))

*   默認情況下跳過`mysqldump`命令輸出中的註釋。
    ([Pull Request](https://github.com/rails/rails/pull/23301))

*   修正`ActiveRecord::Relation#count`，當傳遞區塊作為參數時，使用Ruby的`Enumerable#count`來計算記錄，而不是默默地忽略傳遞的區塊。
    ([Pull Request](https://github.com/rails/rails/pull/24203))

*   使用`psql`命令時，傳遞`"-v ON_ERROR_STOP=1"`標誌以不抑制SQL錯誤。
    ([Pull Request](https://github.com/rails/rails/pull/24773))

*   添加`ActiveRecord::Base.connection_pool.stat`。
    ([Pull Request](https://github.com/rails/rails/pull/26988))

*   直接從`ActiveRecord::Migration`繼承將引發錯誤。指定編寫遷移所用的Rails版本。
    ([Commit](https://github.com/rails/rails/commit/249f71a22ab21c03915da5606a063d321f04d4d3))

*   當`through`關聯具有模糊的反射名稱時，將引發錯誤。
    ([Commit](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

詳細更改請參閱[更新日誌][active-model]。

### 移除

*   移除了`ActiveModel::Errors`中的已棄用方法。
    ([commit](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

*   移除了長度驗證器中已棄用的`:tokenizer`選項。
    ([commit](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

*   移除了當返回值為false時中止回調的已棄用行為。
    ([commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### 重要更改

*   不再錯誤地凍結分配給模型屬性的原始字符串。
    ([Pull Request](https://github.com/rails/rails/pull/28729))

[active-model]: https://github.com/rails/rails/blob/master/activemodel/CHANGELOG.md
主動工作
-----------

詳細更改請參閱[變更日誌][active-job]。

### 刪除

*   刪除了將適配器類傳遞給`.queue_adapter`的不推薦支持。
    ([commit](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   刪除了`ActiveJob::DeserializationError`中的不推薦`#original_exception`。
    ([commit](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### 重要更改

*   通過`ActiveJob::Base.retry_on`和`ActiveJob::Base.discard_on`添加了聲明式異常處理。
    ([Pull Request](https://github.com/rails/rails/pull/25991))

*   在重試失敗後的自定邏輯中，產生作業實例，以便您可以訪問`job.arguments`等。
    ([commit](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

主動支援
--------------

詳細更改請參閱[變更日誌][active-support]。

### 刪除

*   刪除了`ActiveSupport::Concurrency::Latch`類。
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   刪除了`halt_callback_chains_on_return_false`。
    ([Commit](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))

*   刪除了當返回值為false時停止回調的不推薦行為。
    ([Commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### 廢棄

*   頂層`HashWithIndifferentAccess`類已被輕微廢棄，優先使用`ActiveSupport::HashWithIndifferentAccess`。
    ([Pull Request](https://github.com/rails/rails/pull/28157))

*   不推薦將字符串傳遞給`set_callback`和`skip_callback`的`：if`和`：unless`條件選項。
    ([Commit](https://github.com/rails/rails/commit/0952552))

### 重要更改

*   修復了持續時間解析和旅行，使其在DST更改時保持一致。
    ([Commit](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [Pull Request](https://github.com/rails/rails/pull/26597))

*   更新了Unicode到9.0.0版本。
    ([Pull Request](https://github.com/rails/rails/pull/27822))

*   添加了Duration#before和#after作為#ago和#since的別名。
    ([Pull Request](https://github.com/rails/rails/pull/27721))

*   添加了`Module#delegate_missing_to`，將對象未定義的方法調用委託給代理對象。
    ([Pull Request](https://github.com/rails/rails/pull/23930))

*   添加了`Date#all_day`，返回表示當前日期和時間的整天的範圍。
    ([Pull Request](https://github.com/rails/rails/pull/24930))

*   引入了`assert_changes`和`assert_no_changes`方法進行測試。
    ([Pull Request](https://github.com/rails/rails/pull/25393))

*   `travel`和`travel_to`方法現在在嵌套調用時引發異常。
    ([Pull Request](https://github.com/rails/rails/pull/24890))

*   更新`DateTime#change`以支持usec和nsec。
    ([Pull Request](https://github.com/rails/rails/pull/28242))

貢獻者
-------

請參閱[完整的Rails貢獻者列表](https://contributors.rubyonrails.org/)，感謝所有花費許多時間使Rails成為穩定和強大框架的人。向他們致敬。

[railties]:       https://github.com/rails/rails/blob/5-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-1-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
