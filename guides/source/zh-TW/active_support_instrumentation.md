**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b093936da01fde14532f4cead51234e1
主動支援儀器
==============================

主動支援是核心Rails的一部分，提供Ruby語言擴展、實用工具和其他功能。其中之一就是儀器API，可以在應用程序內部用於測量Ruby代碼中發生的某些操作，例如Rails應用程序內部或框架本身的操作。然而，它不僅限於Rails，如果需要，也可以在其他Ruby腳本中獨立使用。

在本指南中，您將學習如何使用主動支援的儀器API來測量Rails和其他Ruby代碼內部的事件。

閱讀本指南後，您將了解：

* 儀器可以提供什麼。
* 如何將訂閱者添加到鉤子。
* 如何在瀏覽器中查看儀器的時間。
* Rails框架中用於儀器的鉤子。
* 如何構建自定義的儀器實現。

--------------------------------------------------------------------------------

儀器簡介
-------------------------------

Active Support提供的儀器API允許開發人員提供其他開發人員可以鉤入的鉤子。在Rails框架中有[幾個](#rails-framework-hooks)這樣的鉤子。使用此API，開發人員可以選擇在其應用程序或其他Ruby代碼內部的某些事件發生時收到通知。

例如，Active Record內部提供了一個鉤子，每次Active Record在數據庫上使用SQL查詢時都會調用該鉤子。可以訂閱此鉤子，並用於跟踪某個操作期間的查詢數量。還有另一個鉤子，用於處理控制器的操作。例如，可以使用此鉤子來跟踪特定操作所花費的時間。

您甚至可以在應用程序內部[創建自己的事件](#creating-custom-events)，然後稍後訂閱它們。

訂閱事件
-----------------------

訂閱事件很容易。使用[`ActiveSupport::Notifications.subscribe`][]和一個塊來聽取任何通知。

該塊接收以下參數：

* 事件的名稱
* 開始時間
* 結束時間
* 觸發事件的儀器的唯一ID
* 事件的有效載荷

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # your own custom stuff
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 2019-05-05 13:43:57 -0800, finished: 2019-05-05 13:43:58 -0800)
end
```

如果您關心`started`和`finished`的準確性以計算精確的經過時間，則使用[`ActiveSupport::Notifications.monotonic_subscribe`][]。給定的塊將接收與上述相同的參數，但`started`和`finished`將具有準確的單調時間值，而不是壁掛時鐘時間。

```ruby
ActiveSupport::Notifications.monotonic_subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # your own custom stuff
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 1560978.425334, finished: 1560979.429234)
end
```

每次定義所有這些塊參數可能很繁瑣。您可以輕鬆地從塊參數創建一個[`ActiveSupport::Notifications::Event`][]，如下所示：

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  event.name      # => "process_action.action_controller"
  event.duration  # => 10（毫秒）
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

您還可以傳遞一個只接受一個參數的塊，它將接收一個事件對象：

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |event|
  event.name      # => "process_action.action_controller"
  event.duration  # => 10（毫秒）
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

您還可以訂閱與正則表達式匹配的事件。這使您可以同時訂閱多個事件。以下是如何訂閱來自`ActionController`的所有事件：

```ruby
ActiveSupport::Notifications.subscribe(/action_controller/) do |*args|
  # inspect all ActionController events
end
```


在瀏覽器中查看儀器的時間
-------------------------------------------------

Rails實現了[Server Timing](https://www.w3.org/TR/server-timing/)標準，以在Web瀏覽器中提供時間信息。要啟用，編輯您的環境配置（通常是`development.rb`，因為它在開發中使用最多），包括以下內容：

```ruby
  config.server_timing = true
```

配置完成後（包括重新啟動服務器），您可以轉到瀏覽器的開發者工具窗格，然後選擇網絡並重新加載頁面。然後，您可以選擇Rails服務器的任何請求，在時間選項卡中查看服務器時間。有關此操作的示例，請參閱[Firefox文檔](https://firefox-source-docs.mozilla.org/devtools-user/network_monitor/request_details/index.html#server-timing)。

Rails框架鉤子
---------------------

在Ruby on Rails框架內部，提供了一些常見事件的鉤子。以下詳細介紹了這些事件及其載荷。
### 行動控制器

#### `start_processing.action_controller`

| 鍵           | 值                                                         |
| ------------- | --------------------------------------------------------- |
| `:controller` | 控制器名稱                                                 |
| `:action`     | 動作                                                       |
| `:params`     | 不包含任何過濾參數的請求參數哈希                           |
| `:headers`    | 請求標頭                                                   |
| `:format`     | html/js/json/xml 等                                        |
| `:method`     | HTTP 請求動詞                                              |
| `:path`       | 請求路徑                                                   |

```ruby
{
  controller: "PostsController",
  action: "new",
  params: { "action" => "new", "controller" => "posts" },
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts/new"
}
```

#### `process_action.action_controller`

| 鍵             | 值                                                         |
| --------------- | --------------------------------------------------------- |
| `:controller`   | 控制器名稱                                                 |
| `:action`       | 動作                                                       |
| `:params`       | 不包含任何過濾參數的請求參數哈希                           |
| `:headers`      | 請求標頭                                                   |
| `:format`       | html/js/json/xml 等                                        |
| `:method`       | HTTP 請求動詞                                              |
| `:path`         | 請求路徑                                                   |
| `:request`      | [`ActionDispatch::Request`][] 物件                          |
| `:response`     | [`ActionDispatch::Response`][] 物件                         |
| `:status`       | HTTP 狀態碼                                                |
| `:view_runtime` | 視圖執行時間（以毫秒為單位）                               |
| `:db_runtime`   | 資料庫查詢執行時間（以毫秒為單位）                         |

```ruby
{
  controller: "PostsController",
  action: "index",
  params: {"action" => "index", "controller" => "posts"},
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts",
  request: #<ActionDispatch::Request:0x00007ff1cb9bd7b8>,
  response: #<ActionDispatch::Response:0x00007f8521841ec8>,
  status: 200,
  view_runtime: 46.848,
  db_runtime: 0.157
}
```

#### `send_file.action_controller`

| 鍵     | 值                             |
| ------- | ----------------------------- |
| `:path` | 檔案的完整路徑                 |

呼叫者可能會新增其他鍵。

#### `send_data.action_controller`

`ActionController` 不會對有效負載新增任何特定資訊。所有選項都會傳遞到有效負載。

#### `redirect_to.action_controller`

| 鍵         | 值                                    |
| ----------- | ---------------------------------------- |
| `:status`   | HTTP 回應碼                       |
| `:location` | 要重新導向的 URL                       |
| `:request`  | [`ActionDispatch::Request`][] 物件 |

```ruby
{
  status: 302,
  location: "http://localhost:3000/posts/new",
  request: <ActionDispatch::Request:0x00007ff1cb9bd7b8>
}
```

#### `halted_callback.action_controller`

| 鍵       | 值                         |
| --------- | ----------------------------- |
| `:filter` | 停止動作的過濾器 |

```ruby
{
  filter: ":halting_filter"
}
```

#### `unpermitted_parameters.action_controller`

| 鍵           | 值                                                                         |
| ------------- | ----------------------------------------------------------------------------- |
| `:keys`       | 不允許的鍵                                                          |
| `:context`    | 包含以下鍵的哈希: `:controller`, `:action`, `:params`, `:request` |

### 行動控制器 — 快取

#### `write_fragment.action_controller`

| 鍵    | 值            |
| ------ | ---------------- |
| `:key` | 完整的鍵 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `read_fragment.action_controller`

| 鍵    | 值            |
| ------ | ---------------- |
| `:key` | 完整的鍵 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `expire_fragment.action_controller`

| 鍵    | 值            |
| ------ | ---------------- |
| `:key` | 完整的鍵 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `exist_fragment?.action_controller`

| 鍵    | 值            |
| ------ | ---------------- |
| `:key` | 完整的鍵 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### 行動調度

#### `process_middleware.action_dispatch`

| 鍵           | 值                  |
| ------------- | ---------------------- |
| `:middleware` | 中介軟體的名稱 |

#### `redirect.action_dispatch`

| 鍵         | 值                                    |
| ----------- | ---------------------------------------- |
| `:status`   | HTTP 回應碼                       |
| `:location` | 要重新導向的 URL                       |
| `:request`  | [`ActionDispatch::Request`][] 物件 |

#### `request.action_dispatch`

| 鍵         | 值                                    |
| ----------- | ---------------------------------------- |
| `:request`  | [`ActionDispatch::Request`][] 物件 |

### 行動視圖

#### `render_template.action_view`

| 鍵           | 值                              |
| ------------- | ---------------------------------- |
| `:identifier` | 模板的完整路徑              |
| `:layout`     | 適用的版面配置                  |
| `:locals`     | 傳遞給模板的區域變數 |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/index.html.erb",
  layout: "layouts/application",
  locals: { foo: "bar" }
}
```

#### `render_partial.action_view`

| 鍵           | 值                              |
| ------------- | ---------------------------------- |
| `:identifier` | 模板的完整路徑              |
| `:locals`     | 傳遞給模板的區域變數 |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_form.html.erb",
  locals: { foo: "bar" }
}
```

#### `render_collection.action_view`

| 鍵           | 值                                 |
| ------------- | ------------------------------------- |
| `:identifier` | 模板的完整路徑                 |
| `:count`      | 集合的大小                    |
| `:cache_hits` | 從快取中擷取的部分數量 |

只有在使用 `cached: true` 渲染集合時，才會包含 `:cache_hits` 鍵。
```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_post.html.erb",
  count: 3,
  cache_hits: 0
}
```

#### `render_layout.action_view`

| 鍵           | 值                     |
| ------------- | --------------------- |
| `:identifier` | 模板的完整路徑         |


```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/layouts/application.html.erb"
}
```


### Active Record

#### `sql.active_record`

| 鍵                  | 值                                        |
| -------------------- | ---------------------------------------- |
| `:sql`               | SQL 語句                                  |
| `:name`              | 操作的名稱                                |
| `:connection`        | 連接對象                                  |
| `:binds`             | 綁定的參數                                |
| `:type_casted_binds` | 類型轉換後的綁定參數                      |
| `:statement_name`    | SQL 語句的名稱                            |
| `:cached`            | 使用緩存查詢時添加 `true`                  |

適配器也可以添加自己的數據。

```ruby
{
  sql: "SELECT \"posts\".* FROM \"posts\" ",
  name: "Post Load",
  connection: <ActiveRecord::ConnectionAdapters::SQLite3Adapter:0x00007f9f7a838850>,
  binds: [<ActiveModel::Attribute::WithCastValue:0x00007fe19d15dc00>],
  type_casted_binds: [11],
  statement_name: nil
}
```

#### `strict_loading_violation.active_record`

只有在 [`config.active_record.action_on_strict_loading_violation`][] 設置為 `:log` 時才會觸發此事件。

| 鍵           | 值                                            |
| ------------- | ------------------------------------------------ |
| `:owner`      | 啟用了 `strict_loading` 的模型                     |
| `:reflection` | 嘗試加載的關聯的反射                            |


#### `instantiation.active_record`

| 鍵              | 值                                     |
| ---------------- | ----------------------------------------- |
| `:record_count`  | 實例化的記錄數目                         |
| `:class_name`    | 記錄的類名                               |

```ruby
{
  record_count: 1,
  class_name: "User"
}
```

### Action Mailer

#### `deliver.action_mailer`

| 鍵                   | 值                                                |
| --------------------- | ---------------------------------------------------- |
| `:mailer`             | 郵件類的名稱                                       |
| `:message_id`         | 郵件的 ID，由 Mail gem 生成                         |
| `:subject`            | 郵件的主題                                         |
| `:to`                 | 郵件的收件地址                                     |
| `:from`               | 郵件的寄件地址                                     |
| `:bcc`                | 郵件的密送地址                                     |
| `:cc`                 | 郵件的抄送地址                                     |
| `:date`               | 郵件的日期                                         |
| `:mail`               | 郵件的編碼形式                                     |
| `:perform_deliveries` | 是否執行此郵件的傳送                               |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails Guides",
  to: ["users@rails.com", "dhh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "...", # 為了簡潔起見省略
  perform_deliveries: true
}
```

#### `process.action_mailer`

| 鍵           | 值                     |
| ------------- | ------------------------ |
| `:mailer`     | 郵件類的名稱 |
| `:action`     | 操作的名稱               |
| `:args`       | 參數                     |

```ruby
{
  mailer: "Notification",
  action: "welcome_email",
  args: []
}
```

### Active Support — Caching

#### `cache_read.active_support`

| 鍵                | 值                   |
| ------------------ | ----------------------- |
| `:key`             | 存儲中使用的鍵         |
| `:store`           | 存儲類的名稱           |
| `:hit`             | 如果這次讀取是命中的話 |
| `:super_operation` | 如果使用 [`fetch`][ActiveSupport::Cache::Store#fetch] 進行讀取，則為 `:fetch` |

#### `cache_read_multi.active_support`

| 鍵                | 值                   |
| ------------------ | ----------------------- |
| `:key`             | 存儲中使用的鍵         |
| `:store`           | 存儲類的名稱           |
| `:hits`            | 命中的緩存鍵           |
| `:super_operation` | 如果使用 [`fetch_multi`][ActiveSupport::Cache::Store#fetch_multi] 進行讀取，則為 `:fetch_multi` |

#### `cache_generate.active_support`

只有在使用 [`fetch`][ActiveSupport::Cache::Store#fetch] 並帶有塊的情況下才會觸發此事件。

| 鍵      | 值                   |
| -------- | ----------------------- |
| `:key`   | 存儲中使用的鍵         |
| `:store` | 存儲類的名稱           |

寫入存儲時，`fetch` 傳遞的選項將與載荷合併。

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_fetch_hit.active_support`

只有在使用 [`fetch`][ActiveSupport::Cache::Store#fetch] 並帶有塊的情況下才會觸發此事件。

| 鍵      | 值                   |
| -------- | ----------------------- |
| `:key`   | 存儲中使用的鍵         |
| `:store` | 存儲類的名稱           |

`fetch` 傳遞的選項將與載荷合併。

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write.active_support`

| 鍵      | 值                   |
| -------- | ----------------------- |
| `:key`   | 存儲中使用的鍵         |
| `:store` | 存儲類的名稱           |

緩存存儲也可以添加自己的數據。

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write_multi.active_support`

| 鍵      | 值                                |
| -------- | ------------------------------------ |
| `:key`   | 寫入存儲的鍵和值                     |
| `:store` | 存儲類的名稱                        |
#### `cache_increment.active_support`

只有在使用[`MemCacheStore`][ActiveSupport::Cache::MemCacheStore]或[`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore]時才會觸發此事件。

| 鍵         | 值                       |
| --------- | ----------------------- |
| `:key`    | 存儲中使用的鍵           |
| `:store`  | 存儲類別的名稱           |
| `:amount` | 增加的數量               |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 99
}
```

#### `cache_decrement.active_support`

只有在使用Memcached或Redis緩存存儲時才會觸發此事件。

| 鍵         | 值                       |
| --------- | ----------------------- |
| `:key`    | 存儲中使用的鍵           |
| `:store`  | 存儲類別的名稱           |
| `:amount` | 減少的數量               |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 1
}
```

#### `cache_delete.active_support`

| 鍵        | 值                       |
| -------- | ----------------------- |
| `:key`   | 存儲中使用的鍵           |
| `:store` | 存儲類別的名稱           |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_delete_multi.active_support`

| 鍵        | 值                       |
| -------- | ----------------------- |
| `:key`   | 存儲中使用的鍵           |
| `:store` | 存儲類別的名稱           |

#### `cache_delete_matched.active_support`

只有在使用[`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore]、[`FileStore`][ActiveSupport::Cache::FileStore]或[`MemoryStore`][ActiveSupport::Cache::MemoryStore]時才會觸發此事件。

| 鍵        | 值                       |
| -------- | ----------------------- |
| `:key`   | 使用的鍵模式             |
| `:store` | 存儲類別的名稱           |

```ruby
{
  key: "posts/*",
  store: "ActiveSupport::Cache::RedisCacheStore"
}
```

#### `cache_cleanup.active_support`

只有在使用[`MemoryStore`][ActiveSupport::Cache::MemoryStore]時才會觸發此事件。

| 鍵        | 值                                         |
| -------- | ----------------------------------------- |
| `:store` | 存儲類別的名稱                             |
| `:size`  | 清理前緩存中的項目數量                     |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  size: 9001
}
```

#### `cache_prune.active_support`

只有在使用[`MemoryStore`][ActiveSupport::Cache::MemoryStore]時才會觸發此事件。

| 鍵        | 值                                         |
| -------- | ----------------------------------------- |
| `:store` | 存儲類別的名稱                             |
| `:key`   | 緩存的目標大小（以字節為單位）             |
| `:from`  | 清理前緩存的大小（以字節為單位）           |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  key: 5000,
  from: 9001
}
```

#### `cache_exist?.active_support`

| 鍵        | 值                       |
| -------- | ----------------------- |
| `:key`   | 存儲中使用的鍵           |
| `:store` | 存儲類別的名稱           |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```


### Active Support — 訊息

#### `message_serializer_fallback.active_support`

| 鍵             | 值                             |
| --------------- | ----------------------------- |
| `:serializer`   | 主要（預期）的序列化器         |
| `:fallback`     | 備用（實際）的序列化器         |
| `:serialized`   | 序列化後的字串               |
| `:deserialized` | 反序列化後的值               |

```ruby
{
  serializer: :json_allow_marshal,
  fallback: :marshal,
  serialized: "\x04\b{\x06I\"\nHello\x06:\x06ETI\"\nWorld\x06;\x00T",
  deserialized: { "Hello" => "World" },
}
```

### Active Job

#### `enqueue_at.active_job`

| 鍵          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 處理作業的QueueAdapter物件              |
| `:job`       | 作業物件                                |

#### `enqueue.active_job`

| 鍵          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 處理作業的QueueAdapter物件              |
| `:job`       | 作業物件                                |

#### `enqueue_retry.active_job`

| 鍵          | 值                                      |
| ------------ | -------------------------------------- |
| `:job`       | 作業物件                                |
| `:adapter`   | 處理作業的QueueAdapter物件              |
| `:error`     | 導致重試的錯誤                         |
| `:wait`      | 重試的延遲時間                          |

#### `enqueue_all.active_job`

| 鍵          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 處理作業的QueueAdapter物件              |
| `:jobs`      | 作業物件的陣列                          |

#### `perform_start.active_job`

| 鍵          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 處理作業的QueueAdapter物件              |
| `:job`       | 作業物件                                |

#### `perform.active_job`

| 鍵           | 值                                         |
| ------------- | --------------------------------------------- |
| `:adapter`    | 處理作業的QueueAdapter物件                    |
| `:job`        | 作業物件                                      |
| `:db_runtime` | 執行數據庫查詢所花費的時間（以毫秒為單位）    |

#### `retry_stopped.active_job`

| 鍵          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 處理作業的QueueAdapter物件              |
| `:job`       | 作業物件                                |
| `:error`     | 導致重試的錯誤                         |

#### `discard.active_job`

| 鍵          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 處理作業的QueueAdapter物件              |
| `:job`       | 作業物件                                |
| `:error`     | 導致丟棄的錯誤                         |
### Action Cable

#### `perform_action.action_cable`

| 鍵               | 值                        |
| ---------------- | ------------------------- |
| `:channel_class` | 頻道類別名稱              |
| `:action`        | 動作                      |
| `:data`          | 資料的雜湊                |

#### `transmit.action_cable`

| 鍵               | 值                        |
| ---------------- | ------------------------- |
| `:channel_class` | 頻道類別名稱              |
| `:data`          | 資料的雜湊                |
| `:via`           | 透過                       |

#### `transmit_subscription_confirmation.action_cable`

| 鍵               | 值                        |
| ---------------- | ------------------------- |
| `:channel_class` | 頻道類別名稱              |

#### `transmit_subscription_rejection.action_cable`

| 鍵               | 值                        |
| ---------------- | ------------------------- |
| `:channel_class` | 頻道類別名稱              |

#### `broadcast.action_cable`

| 鍵             | 值                        |
| --------------- | ------------------------- |
| `:broadcasting` | 命名的廣播                |
| `:message`      | 訊息的雜湊                |
| `:coder`        | 編碼器                    |

### Active Storage

#### `preview.active_storage`

| 鍵          | 值                        |
| ------------ | ------------------------- |
| `:key`       | 安全令牌                  |

#### `transform.active_storage`

#### `analyze.active_storage`

| 鍵          | 值                          |
| ------------ | ------------------------------ |
| `:analyzer`  | 分析器的名稱，例如 ffprobe |

### Active Storage — 儲存服務

#### `service_upload.active_storage`

| 鍵          | 值                        |
| ------------ | ---------------------------- |
| `:key`       | 安全令牌                  |
| `:service`   | 服務的名稱                |
| `:checksum`  | 校驗和確保完整性的校驗和碼 |

#### `service_streaming_download.active_storage`

| 鍵          | 值                        |
| ------------ | ---------------------------- |
| `:key`       | 安全令牌                  |
| `:service`   | 服務的名稱                |

#### `service_download_chunk.active_storage`

| 鍵          | 值                           |
| ------------ | ------------------------------- |
| `:key`       | 安全令牌                     |
| `:service`   | 服務的名稱                   |
| `:range`     | 嘗試讀取的位元組範圍          |

#### `service_download.active_storage`

| 鍵          | 值                        |
| ------------ | ---------------------------- |
| `:key`       | 安全令牌                  |
| `:service`   | 服務的名稱                |

#### `service_delete.active_storage`

| 鍵          | 值                        |
| ------------ | ---------------------------- |
| `:key`       | 安全令牌                  |
| `:service`   | 服務的名稱                |

#### `service_delete_prefixed.active_storage`

| 鍵          | 值                        |
| ------------ | ---------------------------- |
| `:prefix`    | 鍵的前綴                  |
| `:service`   | 服務的名稱                |

#### `service_exist.active_storage`

| 鍵          | 值                        |
| ------------ | ---------------------------- |
| `:key`       | 安全令牌                  |
| `:service`   | 服務的名稱                |
| `:exist`     | 檔案或 blob 是否存在       |

#### `service_url.active_storage`

| 鍵          | 值                        |
| ------------ | ---------------------------- |
| `:key`       | 安全令牌                  |
| `:service`   | 服務的名稱                |
| `:url`       | 生成的 URL                |

#### `service_update_metadata.active_storage`

只有在使用 Google Cloud Storage 服務時才會觸發此事件。

| 鍵             | 值                            |
| --------------- | -------------------------------- |
| `:key`          | 安全令牌                       |
| `:service`      | 服務的名稱                     |
| `:content_type` | HTTP `Content-Type` 欄位        |
| `:disposition`  | HTTP `Content-Disposition` 欄位 |

### Action Mailbox

#### `process.action_mailbox`

| 鍵              | 值                                                  |
| -----------------| ------------------------------------------------------ |
| `:mailbox`       | 繼承自 [`ActionMailbox::Base`][] 的 Mailbox 類別的實例 |
| `:inbound_email` | 有關正在處理的入站郵件的資料的雜湊                       |

```ruby
{
  mailbox: #<RepliesMailbox:0x00007f9f7a8388>,
  inbound_email: {
    id: 1,
    message_id: "0CB459E0-0336-41DA-BC88-E6E28C697DDB@37signals.com",
    status: "processing"
  }
}
```


### Railties

#### `load_config_initializer.railties`

| 鍵            | 值                                               |
| -------------- | --------------------------------------------------- |
| `:initializer` | 在 `config/initializers` 中載入的初始化程式的路徑 |

### Rails

#### `deprecation.rails`

| 鍵                    | 值                                                 |
| ---------------------- | ------------------------------------------------------|
| `:message`             | 廢棄警告訊息                                       |
| `:callstack`           | 廢棄警告的來源                                     |
| `:gem_name`            | 報告廢棄警告的 gem 的名稱                           |
| `:deprecation_horizon` | 廢棄行為將被移除的版本                               |

例外
----------

如果在任何儀器儀表板中發生例外，載荷將包含有關它的資訊。

| 鍵                 | 值                                                          |
| ------------------- | -------------------------------------------------------------- |
| `:exception`        | 一個包含兩個元素的陣列。例外類別名稱和訊息                      |
| `:exception_object` | 例外物件                                                    |

建立自訂事件
----------------------

添加自己的事件也很容易。Active Support 將為您處理所有繁重的工作。只需使用 `name`、`payload` 和區塊調用 [`ActiveSupport::Notifications.instrument`][]。通知將在區塊返回後發送。Active Support 將生成開始和結束時間，並添加儀器的唯一 ID。所有傳遞到 `instrument` 調用中的資料都將出現在載荷中。
以下是一個例子：

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data do
  # 在這裡執行你的自訂程式碼
end
```

現在你可以使用以下方式監聽這個事件：

```ruby
ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

你也可以在不傳遞區塊的情況下呼叫`instrument`。這讓你可以利用儀器基礎架構進行其他訊息傳遞。

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data

ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

在定義自己的事件時，應該遵循 Rails 的慣例。格式為：`event.library`。如果你的應用程式正在發送推文，你應該創建一個名為`tweet.twitter`的事件。
[`ActiveSupport::Notifications::Event`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications/Event.html
[`ActiveSupport::Notifications.monotonic_subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-monotonic_subscribe
[`ActiveSupport::Notifications.subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-subscribe
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`ActionDispatch::Response`]: https://api.rubyonrails.org/classes/ActionDispatch/Response.html
[`config.active_record.action_on_strict_loading_violation`]: configuring.html#config-active-record-action-on-strict-loading-violation
[ActiveSupport::Cache::FileStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[ActiveSupport::Cache::MemCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemoryStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[ActiveSupport::Cache::RedisCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#fetch_multi]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch_multi
[`ActionMailbox::Base`]: https://api.rubyonrails.org/classes/ActionMailbox/Base.html
[`ActiveSupport::Notifications.instrument`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-instrument
