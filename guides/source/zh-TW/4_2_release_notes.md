**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4d8311a1435138a81e26a7e8f537dbde
Ruby on Rails 4.2 發行說明
===============================

Rails 4.2 的亮點：

* Active Job
* 非同步郵件
* Adequate Record
* Web Console
* 外鍵支援

這些發行說明僅涵蓋主要更改。要了解其他功能、錯誤修復和更改，請參閱變更日誌或檢查 GitHub 上主要 Rails 存儲庫的 [提交列表](https://github.com/rails/rails/commits/4-2-stable)。

--------------------------------------------------------------------------------

升級到 Rails 4.2
----------------------

如果您正在升級現有應用程式，建議在進行升級之前先進行良好的測試覆蓋。如果尚未升級到 Rails 4.1，請先升級到該版本，然後確保應用程式運行正常，然後再嘗試升級到 Rails 4.2。在升級時要注意的事項列表可在指南 [升級 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2) 中找到。

主要功能
--------------

### Active Job

Active Job 是 Rails 4.2 中的新框架。它是在排程系統（如 [Resque](https://github.com/resque/resque)、[Delayed Job](https://github.com/collectiveidea/delayed_job)、[Sidekiq](https://github.com/mperham/sidekiq) 等）之上的通用介面。

使用 Active Job API 編寫的作業可以在任何支援的排程系統上運行，這要歸功於它們各自的適配器。Active Job 預先配置了一個內聯運行器，可以立即執行作業。

作業通常需要將 Active Record 物件作為參數。Active Job 通過將物件引用作為統一資源標識符（URI）傳遞，而不是對象本身進行序列化。新的 [Global ID](https://github.com/rails/globalid) 函式庫建立 URI 並查找它們引用的對象。通過在內部使用 Global ID，將 Active Record 物件作為作業參數傳遞是可行的。

例如，如果 `trashable` 是一個 Active Record 物件，那麼這個作業可以正常運行，而無需進行序列化：

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

有關更多信息，請參閱 [Active Job Basics](active_job_basics.html) 指南。

### 非同步郵件

在 Active Job 的基礎上，Action Mailer 現在提供了一個 `deliver_later` 方法，通過排程系統發送郵件，這樣即使排程系統是非同步的（默認的內聯排程系統是同步的），也不會阻塞控制器或模型。

仍然可以使用 `deliver_now` 立即發送郵件。

### Adequate Record

Adequate Record 是 Active Record 中的一組性能改進，可以使常見的 `find` 和 `find_by` 調用以及某些關聯查詢速度提高最多 2 倍。

它通過將常見的 SQL 查詢緩存為預備語句並在類似調用上重複使用，跳過大部分的查詢生成工作。有關詳細信息，請參閱 [Aaron Patterson 的博客文章](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html)。
Active Record會在支援的操作中自動利用這個功能，而不需要使用者參與或更改程式碼。以下是一些支援的操作範例：

```ruby
Post.find(1)  # 第一次呼叫會生成並緩存預備語句
Post.find(2)  # 後續呼叫會重複使用緩存的預備語句

Post.find_by_title('first post')
Post.find_by_title('second post')

Post.find_by(title: 'first post')
Post.find_by(title: 'second post')

post.comments
post.comments(true)
```

需要強調的是，如上述範例所示，預備語句不會緩存方法呼叫中傳遞的值，而是為它們準備了佔位符。

以下情況不使用快取：

- 模型有預設範圍
- 模型使用單一表繼承
- 使用id列表的`find`，例如：

    ```ruby
    # 不會被快取
    Post.find(1, 2, 3)
    Post.find([1,2])
    ```

- 使用SQL片段的`find_by`：

    ```ruby
    Post.find_by('published_at < ?', 2.weeks.ago)
    ```

### Web Console

使用Rails 4.2生成的新應用程式現在預設附帶[Web Console](https://github.com/rails/web-console) gem。Web Console在每個錯誤頁面上添加了一個互動式Ruby控制台，並提供了`console`視圖和控制器幫助程式。

錯誤頁面上的互動式控制台允許您在異常發生的地方執行代碼。如果在視圖或控制器中的任何位置調用`console`幫助程式，則在渲染完成後，將啟動具有最終上下文的互動式控制台。

### 外鍵支援

遷移DSL現在支援添加和刪除外鍵。它們也會被儲存到`schema.rb`中。目前，只有`mysql`，`mysql2`和`postgresql`適配器支援外鍵。

```ruby
# 添加一個外鍵到`articles.author_id`，參照`authors.id`
add_foreign_key :articles, :authors

# 添加一個外鍵到`articles.author_id`，參照`users.lng_id`
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# 刪除`accounts.branch_id`上的外鍵
remove_foreign_key :accounts, :branches

# 刪除`accounts.owner_id`上的外鍵
remove_foreign_key :accounts, column: :owner_id
```

請參閱API文件中的[add_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)和[remove_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)以獲得詳細描述。

不相容性
-----------------

之前已棄用的功能已被移除。請參考各個組件以獲取此版本中的新棄用功能。

以下更改可能需要立即採取行動：

### 使用字串參數的`render`

以前，在控制器動作中調用`render "foo/bar"`等同於`render file: "foo/bar"`。在Rails 4.2中，這已更改為表示`render template: "foo/bar"`。如果需要渲染文件，請將代碼更改為使用明確形式（`render file: "foo/bar"`）。

### `respond_with` / 類級`respond_to`
`respond_with`和相對應的類級`respond_to`已經移至[responders](https://github.com/plataformatec/responders) gem。在你的`Gemfile`中添加`gem 'responders', '~> 2.0'`以使用它：

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

實例級的`respond_to`不受影響：

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

### `rails server`的預設主機

由於[Rack的更改](https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc)，`rails server`現在預設在`localhost`上監聽，而不是`0.0.0.0`。這對於標準的開發工作流程應該只有很小的影響，因為在您自己的機器上，http://127.0.0.1:3000和http://localhost:3000仍然像以前一樣工作。

然而，由於這個更改，您將無法從其他機器訪問Rails服務器，例如，如果您的開發環境在虛擬機器中，並且您想從主機機器訪問它。在這種情況下，請使用`rails server -b 0.0.0.0`來恢復舊的行為。

如果這樣做，請確保適當地配置您的防火牆，以便只有您網絡上的可信任機器可以訪問您的開發服務器。

### `render`的狀態選項符號已更改

由於[Rack的更改](https://github.com/rack/rack/commit/be28c6a2ac152fe4adfbef71f3db9f4200df89e8)，`render`方法接受的`:status`選項的符號已更改：

- 306：`：reserved`已被刪除。
- 413：`：request_entity_too_large`已更名為`：payload_too_large`。
- 414：`：request_uri_too_long`已更名為`：uri_too_long`。
- 416：`：requested_range_not_satisfiable`已更名為`：range_not_satisfiable`。

請記住，如果使用未知的符號調用`render`，響應狀態將默認為500。

### HTML淨化器

HTML淨化器已經被一個基於[Loofah](https://github.com/flavorjones/loofah)和[Nokogiri](https://github.com/sparklemotion/nokogiri)的新的、更強大、更靈活的實現所取代。新的淨化器更安全，其淨化功能更強大和靈活。

由於新的算法，對於某些極端輸入，淨化後的輸出可能會有所不同。

如果您對舊淨化器的精確輸出有特殊需求，可以將[rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer) gem添加到`Gemfile`中，以獲得舊的行為。該gem不會發出棄用警告，因為它是選擇性的。

`rails-deprecated_sanitizer`只支持Rails 4.2；對於Rails 5.0，將不再維護。

有關新淨化器的更多詳細信息，請參閱[此博客文章](https://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/)。

### `assert_select`

`assert_select`現在基於[Nokogiri](https://github.com/sparklemotion/nokogiri)。因此，一些以前有效的選擇器現在不再受支持。如果您的應用程序使用了這些拼寫，您需要對它們進行更新：
*   如果屬性選擇器中的值包含非字母數字字符，則可能需要對其進行引號引用。

    ```ruby
    # 之前
    a[href=/]
    a[href$=/]

    # 現在
    a[href="/"]
    a[href$="/"]
    ```

*   從包含無效HTML和不正確嵌套元素的HTML源代碼構建的DOM可能會有所不同。

    例如：

    ```ruby
    # 內容： <div><i><p></i></div>

    # 之前：
    assert_select('div > i')  # => true
    assert_select('div > p')  # => false
    assert_select('i > p')    # => true

    # 現在：
    assert_select('div > i')  # => true
    assert_select('div > p')  # => true
    assert_select('i > p')    # => false
    ```

*   如果所選數據包含實體，則用於比較的選擇值以前是原始的（例如`AT&amp;T`），現在是評估的（例如`AT&T`）。

    ```ruby
    # 內容： <p>AT&amp;T</p>

    # 之前：
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # 現在：
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

此外，替換的語法已更改。

現在您必須使用`:match`類似CSS的選擇器：

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

此外，當斷言失敗時，正則表達式替換的外觀不同。請注意，這裡的`/hello/`：

```ruby
assert_select(":match('id', ?)", /hello/)
```

變成了`"(?-mix:hello)"`：

```
預期至少有1個匹配的元素 "div:match('id', "(?-mix:hello)")"，但找到0個。
預期0大於等於1。
```

有關`assert_select`的更多信息，請參見[Rails Dom Testing](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b)文檔。


Railties
--------

詳細更改請參閱[Changelog][railties]。

### 刪除

*   應用程序生成器中的`--skip-action-view`選項已被刪除。 ([Pull Request](https://github.com/rails/rails/pull/17042))

*   `rails application`命令已被刪除，沒有替代品。 ([Pull Request](https://github.com/rails/rails/pull/11616))

### 廢棄

*   對於生產環境，已廢棄缺失的`config.log_level`。 ([Pull Request](https://github.com/rails/rails/pull/16622))

*   廢棄`rake test:all`，改用`rake test`，因為它現在運行`test`文件夾中的所有測試。 ([Pull Request](https://github.com/rails/rails/pull/17348))

*   廢棄`rake test:all:db`，改用`rake test:db`。 ([Pull Request](https://github.com/rails/rails/pull/17348))

*   廢棄`Rails::Rack::LogTailer`，沒有替代品。 ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### 重要更改

*   在默認應用程序`Gemfile`中引入了`web-console`。 ([Pull Request](https://github.com/rails/rails/pull/11667))

*   為關聯引入了模型生成器的`required`選項。 ([Pull Request](https://github.com/rails/rails/pull/16062))

*   引入了`x`命名空間，用於定義自定義配置選項：

    ```ruby
    # config/environments/production.rb
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries  = 3
    config.x.super_debugger              = true
    ```

    然後可以通過配置對象訪問這些選項：

    ```ruby
    Rails.configuration.x.payment_processing.schedule # => :daily
    Rails.configuration.x.payment_processing.retries  # => 3
    Rails.configuration.x.super_debugger              # => true
    ```

    ([Commit](https://github.com/rails/rails/commit/611849772dd66c2e4d005dcfe153f7ce79a8a7db))

*   引入了`Rails::Application.config_for`，用於加載當前環境的配置。

    ```yaml
    # config/exception_notification.yml
    production:
      url: http://127.0.0.1:8080
      namespace: my_app_production
    development:
      url: http://localhost:3001
      namespace: my_app_development
    ```

    ```ruby
    # config/environments/production.rb
    Rails.application.configure do
      config.middleware.use ExceptionNotifier, config_for(:exception_notification)
    end
    ```
（[拉取請求](https://github.com/rails/rails/pull/16129)）

*   在應用程式生成器中引入了 `--skip-turbolinks` 選項，以不生成 turbolinks 整合。
    （[提交](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d)）

*   引入了 `bin/setup` 腳本作為自動設置代碼的慣例，用於引導應用程式。
    （[拉取請求](https://github.com/rails/rails/pull/15189)）

*   在開發中將 `config.assets.digest` 的默認值更改為 `true`。
    （[拉取請求](https://github.com/rails/rails/pull/15155)）

*   引入了一個 API 來註冊 `rake notes` 的新擴展。
    （[拉取請求](https://github.com/rails/rails/pull/14379)）

*   引入了 `after_bundle` 回調，用於 Rails 模板中使用。
    （[拉取請求](https://github.com/rails/rails/pull/16359)）

*   引入了 `Rails.gem_version` 作為一個方便的方法，返回 `Gem::Version.new(Rails.version)`。
    （[拉取請求](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

詳細更改請參閱[變更日誌][action-pack]。

### 刪除項目

*   從 Rails 中刪除了 `respond_with` 和類級 `respond_to`，並將其移至 `responders` gem（版本2.0）。在你的 `Gemfile` 中添加 `gem 'responders', '~> 2.0'` 以繼續使用這些功能。
    （[拉取請求](https://github.com/rails/rails/pull/16526)，
     [更多詳細資訊](https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders)）

*   刪除了已棄用的 `AbstractController::Helpers::ClassMethods::MissingHelperError`，改用 `AbstractController::Helpers::MissingHelperError`。
    （[提交](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8)）

### 廢棄項目

*   廢棄了 `*_path` 助手函數的 `only_path` 選項。
    （[提交](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9)）

*   廢棄了 `assert_tag`、`assert_no_tag`、`find_tag` 和 `find_all_tag`，改用 `assert_select`。
    （[提交](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750)）

*   廢棄了將路由器的 `:to` 選項設置為符號或不包含 `#` 字符的字符串的支援：

    ```ruby
    get '/posts', to: MyRackApp    => (無需更改)
    get '/posts', to: 'post#index' => (無需更改)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```

    （[提交](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9)）

*   廢棄了在 URL 助手函數中使用字符串鍵的支援：

    ```ruby
    # 不好的寫法
    root_path('controller' => 'posts', 'action' => 'index')

    # 好的寫法
    root_path(controller: 'posts', action: 'index')
    ```

    （[拉取請求](https://github.com/rails/rails/pull/17743)）

### 重要更改

*   從文件中刪除了 `*_filter` 方法族。建議使用 `*_action` 方法族來替代它們：

    ```
    after_filter          => after_action
    append_after_filter   => append_after_action
    append_around_filter  => append_around_action
    append_before_filter  => append_before_action
    around_filter         => around_action
    before_filter         => before_action
    prepend_after_filter  => prepend_after_action
    prepend_around_filter => prepend_around_action
    prepend_before_filter => prepend_before_action
    skip_after_filter     => skip_after_action
    skip_around_filter    => skip_around_action
    skip_before_filter    => skip_before_action
    skip_filter           => skip_action_callback
    ```

    如果你的應用程式目前依賴於這些方法，應改用替代的 `*_action` 方法。這些方法將來會被廢棄並最終從 Rails 中刪除。

    （提交 [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de)，
    [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4)）

*   `render nothing: true` 或渲染 `nil` 內容不再在響應內容中添加單個空格填充。
    （[拉取請求](https://github.com/rails/rails/pull/14883)）

*   Rails 現在自動在 ETags 中包含模板的摘要。
    （[拉取請求](https://github.com/rails/rails/pull/16527)）

*   傳遞給 URL 助手函數的片段現在會自動進行轉義。
    （[提交](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))
*   引入了`always_permitted_parameters`選項，用於配置全局允許的參數。該配置的默認值為`['controller', 'action']`。
    ([拉取請求](https://github.com/rails/rails/pull/15933))

*   從[RFC 4791](https://tools.ietf.org/html/rfc4791)中添加了HTTP方法`MKCALENDAR`。
    ([拉取請求](https://github.com/rails/rails/pull/15121))

*   `*_fragment.action_controller`通知現在在有效負載中包含控制器和操作名稱。
    ([拉取請求](https://github.com/rails/rails/pull/14137))

*   通過模糊匹配改進了路由錯誤頁面的路由搜索。
    ([拉取請求](https://github.com/rails/rails/pull/14619))

*   添加了一個選項來禁用CSRF失敗的日誌記錄。
    ([拉取請求](https://github.com/rails/rails/pull/14280))

*   當Rails服務器設置為提供靜態資源時，如果客戶端支持並且磁盤上存在預生成的gzip文件（`.gz`），則將提供gzip資源。默認情況下，資源管道為所有可壓縮的資源生成`.gz`文件。提供gzip文件可以減少數據傳輸並加快資源請求速度。如果您在生產環境中從Rails服務器提供資源，請始終[使用CDN](https://guides.rubyonrails.org/v4.2/asset_pipeline.html#cdns)。
    ([拉取請求](https://github.com/rails/rails/pull/16466))

*   在集成測試中調用`process`輔助方法時，路徑需要有前斜杠。以前可以省略它，但那是實現的副產品，而不是有意的功能，例如：

    ```ruby
    test "list all posts" do
      get "/posts"
      assert_response :success
    end
    ```

Action View
-----------

詳細更改請參閱[更新日誌][action-view]。

### 廢棄

*   廢棄了`AbstractController::Base.parent_prefixes`。當您想要更改查找視圖的位置時，請覆蓋`AbstractController::Base.local_prefixes`。
    ([拉取請求](https://github.com/rails/rails/pull/15026))

*   廢棄了`ActionView::Digestor#digest(name, format, finder, options = {})`。應該將參數作為哈希傳遞。
    ([拉取請求](https://github.com/rails/rails/pull/14243))

### 重要更改

*   `render "foo/bar"`現在會展開為`render template: "foo/bar"`，而不是`render file: "foo/bar"`。
    ([拉取請求](https://github.com/rails/rails/pull/16888))

*   表單輔助方法不再在隱藏字段周圍生成帶有內聯CSS的`<div>`元素。
    ([拉取請求](https://github.com/rails/rails/pull/14738))

*   引入了`#{partial_name}_iteration`特殊局部變量，用於與使用集合呈現的局部模板一起使用。它通過`index`、`size`、`first?`和`last?`方法提供對迭代的當前狀態的訪問。
    ([拉取請求](https://github.com/rails/rails/pull/7698))

*   Placeholder I18n遵循與`label` I18n相同的慣例。
    ([拉取請求](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

詳細更改請參閱[更新日誌][action-mailer]。

### 廢棄

*   在郵件中廢棄了`*_path`輔助方法。請始終使用`*_url`輔助方法。
    ([拉取請求](https://github.com/rails/rails/pull/15840))

*   廢棄了`deliver` / `deliver!`，改用`deliver_now` / `deliver_now!`。
    ([拉取請求](https://github.com/rails/rails/pull/16582))

### 重要更改

*   在模板中，`link_to`和`url_for`默認生成絕對URL，無需傳遞`only_path: false`。
    ([提交](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

*   引入了`deliver_later`，它將一個作業排入應用程序的隊列，以異步方式發送電子郵件。
    ([拉取請求](https://github.com/rails/rails/pull/16485))
*   新增了`show_previews`配置選項，用於在開發環境之外啟用郵件預覽功能。
    ([拉取請求](https://github.com/rails/rails/pull/15970))


Active Record
-------------

詳細更改請參閱[變更日誌][active-record]。

### 刪除項目

*   刪除了`cache_attributes`及其相關功能。現在所有屬性都會被緩存。
    ([拉取請求](https://github.com/rails/rails/pull/15429))

*   刪除了已棄用的方法`ActiveRecord::Base.quoted_locking_column`。
    ([拉取請求](https://github.com/rails/rails/pull/15612))

*   刪除了已棄用的`ActiveRecord::Migrator.proper_table_name`。請改用
    `ActiveRecord::Migration`的`proper_table_name`實例方法。
    ([拉取請求](https://github.com/rails/rails/pull/15512))

*   刪除了未使用的`:timestamp`類型。在所有情況下，將其透明地別名為`:datetime`。
    修正了在將列類型傳送到Active Record之外（例如XML序列化）時的不一致性。
    ([拉取請求](https://github.com/rails/rails/pull/15184))

### 廢棄項目

*   廢棄了在`after_commit`和`after_rollback`中吞噬錯誤的功能。
    ([拉取請求](https://github.com/rails/rails/pull/16537))

*   廢棄了對`has_many :through`關聯自動檢測計數緩存的支援。現在應該手動在
    通過記錄的`has_many`和`belongs_to`關聯上指定計數緩存。
    ([拉取請求](https://github.com/rails/rails/pull/15754))

*   廢棄了將Active Record對象傳遞給`.find`或`.exists?`的功能。請先調用對象的`id`方法。
    (提交 [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
    [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   廢棄了對於排除開始的PostgreSQL範圍值的支援。我們目前將PostgreSQL範圍映射為Ruby範圍。
    這種轉換不完全可能，因為Ruby範圍不支援排除開始。

    目前的解決方案是增加開始值，但這是不正確的，現在已被廢棄。對於我們不知道如何增加的子類型
    （例如`succ`未定義）的範圍，將為具有排除開始的範圍引發`ArgumentError`。
    ([提交](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   廢棄了在沒有連接的情況下調用`DatabaseTasks.load_schema`的功能。請改用
    `DatabaseTasks.load_schema_current`。
    ([提交](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   廢棄了`sanitize_sql_hash_for_conditions`而沒有替代方法。使用`Relation`執行查詢和更新是首選的API。
    ([提交](https://github.com/rails/rails/commit/d5902c9e))

*   廢棄了不傳遞`null`選項的`add_timestamps`和`t.timestamps`。在Rails 5中，默認值`null: true`
    將更改為`null: false`。
    ([拉取請求](https://github.com/rails/rails/pull/16481))

*   廢棄了不再需要的`Reflection#source_macro`方法，因為在Active Record中不再需要。
    ([拉取請求](https://github.com/rails/rails/pull/16373))

*   廢棄了`serialized_attributes`而沒有替代方法。
    ([拉取請求](https://github.com/rails/rails/pull/15704))

*   廢棄了在沒有列存在時從`column_for_attribute`返回`nil`的功能。在Rails 5.0中，將返回一個空對象。
    ([拉取請求](https://github.com/rails/rails/pull/15878))

*   廢棄了在關聯依賴於實例狀態的情況下（即使用接受參數的作用域定義的關聯）使用`.joins`、`.preload`
    和`.eager_load`的功能，而沒有替代方法。
    ([提交](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### 重要更改

*   `SchemaDumper`在`create_table`上使用了`force: :cascade`。這使得在存在外鍵的情況下重新加載模式成為可能。

*   為單數關聯添加了一個`required`選項，該選項在關聯上定義了存在驗證。
    ([拉取請求](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty`現在可以檢測到對可變值的原地更改。當未更改時，不再保存Active Record模型上的序列化屬性。
    這也適用於其他類型，例如PostgreSQL上的字符串列和json列。
    (拉取請求 [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))
*   引入了 `db:purge` Rake 任務，用於清空當前環境的數據庫。
    ([Commit](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

*   引入了 `ActiveRecord::Base#validate!` 方法，如果記錄無效，則引發 `ActiveRecord::RecordInvalid` 異常。
    ([Pull Request](https://github.com/rails/rails/pull/8639))

*   引入了 `validate` 作為 `valid?` 的別名。
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   `touch` 現在可以同時觸發多個屬性。
    ([Pull Request](https://github.com/rails/rails/pull/14423))

*   PostgreSQL 适配器現在支持 PostgreSQL 9.4+ 中的 `jsonb` 數據類型。
    ([Pull Request](https://github.com/rails/rails/pull/16220))

*   PostgreSQL 和 SQLite 适配器不再對字符串列添加默認長度限制為 255 個字符。
    ([Pull Request](https://github.com/rails/rails/pull/14579))

*   在 PostgreSQL 适配器中添加了對 `citext` 列類型的支持。
    ([Pull Request](https://github.com/rails/rails/pull/12523))

*   在 PostgreSQL 适配器中添加了對用戶創建的範圍類型的支持。
    ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

*   `sqlite3:///some/path` 現在解析為絕對系統路徑 `/some/path`。對於相對路徑，請改用 `sqlite3:some/path`。
    （以前，`sqlite3:///some/path` 解析為相對路徑 `some/path`。此行為在 Rails 4.1 中已被棄用）。
    ([Pull Request](https://github.com/rails/rails/pull/14569))

*   為 MySQL 5.6 及以上版本添加了對於小數秒的支持。
    （Pull Request [1](https://github.com/rails/rails/pull/8240),
    [2](https://github.com/rails/rails/pull/14359))

*   添加了 `ActiveRecord::Base#pretty_print` 方法，用於美化打印模型。
    ([Pull Request](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload` 現在的行為與 `m = Model.find(m.id)` 相同，即不再保留自定義 `SELECT` 的額外屬性。
    ([Pull Request](https://github.com/rails/rails/pull/15866))

*   `ActiveRecord::Base#reflections` 現在返回一個帶有字符串鍵的哈希，而不是符號鍵。
    ([Pull Request](https://github.com/rails/rails/pull/17718))

*   迁移中的 `references` 方法現在支持 `type` 選項，用於指定外鍵的類型（例如 `:uuid`）。
    ([Pull Request](https://github.com/rails/rails/pull/16231))

Active Model
------------

詳細更改請參閱 [Changelog][active-model]。

### 刪除

*   刪除了已棄用的 `Validator#setup` 方法，無替代方法。
    ([Pull Request](https://github.com/rails/rails/pull/10716))

### 棄用

*   棄用 `reset_#{attribute}`，改用 `restore_#{attribute}`。
    ([Pull Request](https://github.com/rails/rails/pull/16180))

*   棄用 `ActiveModel::Dirty#reset_changes`，改用 `clear_changes_information`。
    ([Pull Request](https://github.com/rails/rails/pull/16180))

### 重要更改

*   引入了 `validate` 作為 `valid?` 的別名。
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   在 `ActiveModel::Dirty` 中引入了 `restore_attributes` 方法，用於恢復已更改（dirty）的屬性到其先前的值。
    （Pull Request [1](https://github.com/rails/rails/pull/14861),
    [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password` 現在不再默認禁止空白密碼（即只包含空格的密碼）。
    ([Pull Request](https://github.com/rails/rails/pull/16412))

*   如果啟用驗證，`has_secure_password` 現在會驗證給定的密碼是否少於 72 個字符。
    ([Pull Request](https://github.com/rails/rails/pull/15708))

Active Support
--------------

詳細更改請參閱 [Changelog][active-support]。

### 刪除

*   刪除了已棄用的 `Numeric#ago`、`Numeric#until`、`Numeric#since`、`Numeric#from_now` 方法。
    ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   刪除了 `ActiveSupport::Callbacks` 的基於字符串的終止符的已棄用方法。
    ([Pull Request](https://github.com/rails/rails/pull/15100))

### 棄用

*   棄用 `Kernel#silence_stderr`、`Kernel#capture` 和 `Kernel#quietly` 方法，無替代方法。
    ([Pull Request](https://github.com/rails/rails/pull/13392))

*   棄用 `Class#superclass_delegating_accessor`，改用 `Class#class_attribute`。
    ([Pull Request](https://github.com/rails/rails/pull/14271))

*   棄用 `ActiveSupport::SafeBuffer#prepend!`，因為 `ActiveSupport::SafeBuffer#prepend` 現在具有相同的功能。
    ([Pull Request](https://github.com/rails/rails/pull/14529))
### 重要變更

*   引入了一個新的配置選項 `active_support.test_order`，用於指定測試案例的執行順序。該選項目前的默認值為 `:sorted`，但在 Rails 5.0 中將更改為 `:random`。
    ([提交](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   `Object#try` 和 `Object#try!` 現在可以在區塊中不使用顯式接收器來使用。
    ([提交](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830),
    [拉取請求](https://github.com/rails/rails/pull/17361))

*   `travel_to` 測試輔助方法現在將 `usec` 組件截斷為 0。
    ([提交](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   引入了 `Object#itself` 作為一個身份函數。
    (提交 [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810),
    [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   `Object#with_options` 現在可以在區塊中不使用顯式接收器來使用。
    ([拉取請求](https://github.com/rails/rails/pull/16339))

*   引入了 `String#truncate_words` 來按單詞數截斷字符串。
    ([拉取請求](https://github.com/rails/rails/pull/16190))

*   添加了 `Hash#transform_values` 和 `Hash#transform_values!`，以簡化一個常見模式，其中哈希的值必須更改，但鍵保持不變。
    ([拉取請求](https://github.com/rails/rails/pull/15819))

*   `humanize` 轉換器輔助方法現在會去除任何前導下劃線。
    ([提交](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   引入了 `Concern#class_methods` 作為 `module ClassMethods` 的替代方案，以及 `Kernel#concern` 來避免 `module Foo; extend ActiveSupport::Concern; end` 的樣板代碼。
    ([提交](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   新增了關於常量自動加載和重新加載的[指南](autoloading_and_reloading_constants_classic_mode.html)。

貢獻者
-------

請參閱[完整的 Rails 貢獻者列表](https://contributors.rubyonrails.org/)，感謝那些花了許多時間使 Rails 成為穩定且強大的框架的人。向他們致敬。
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
