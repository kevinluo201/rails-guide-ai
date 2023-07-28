**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b093936da01fde14532f4cead51234e1
Active Support仪表盘
==================

Active Support是Rails核心的一部分，提供了Ruby语言扩展、实用工具和其他功能。其中之一就是仪表盘API，可以在应用程序内部测量发生在Ruby代码中的某些操作，例如Rails应用程序或框架本身内部的操作。然而，它不仅限于Rails，如果需要的话，也可以在其他Ruby脚本中独立使用。

在本指南中，您将学习如何使用Active Support的仪表盘API来测量Rails和其他Ruby代码中的事件。

阅读完本指南后，您将了解：

* 仪表盘可以提供什么。
* 如何向钩子添加订阅者。
* 如何在浏览器中查看仪表盘的时间。
* Rails框架中用于仪表盘的钩子。
* 如何构建自定义的仪表盘实现。

--------------------------------------------------------------------------------

仪表盘简介
------------

Active Support提供的仪表盘API允许开发人员提供其他开发人员可以连接的钩子。在Rails框架中有[几个](#rails-framework-hooks)这样的钩子。使用该API，开发人员可以选择在其应用程序或其他Ruby代码内部发生某些事件时得到通知。

例如，Active Record中提供了一个钩子，每当Active Record在数据库上使用SQL查询时都会调用它。可以[订阅](#sql-active-record)该钩子，并用它来跟踪某个操作期间的查询次数。还有[另一个钩子](#process-action-action-controller)，用于处理控制器的操作。例如，可以使用它来跟踪特定操作所花费的时间。

您甚至可以在应用程序内部[创建自己的事件](#creating-custom-events)，然后稍后订阅它们。

订阅事件
--------

订阅事件很简单。使用[`ActiveSupport::Notifications.subscribe`][]和一个块来监听任何通知。

该块接收以下参数：

* 事件的名称
* 开始时间
* 结束时间
* 触发事件的仪表盘的唯一ID
* 事件的有效负载

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # 自定义内容
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 2019-05-05 13:43:57 -0800, finished: 2019-05-05 13:43:58 -0800)
end
```

如果您关心`started`和`finished`的准确性以计算精确的经过时间，则可以使用[`ActiveSupport::Notifications.monotonic_subscribe`][]。给定的块将接收与上述相同的参数，但`started`和`finished`将具有准确的单调时间值，而不是挂钟时间。

```ruby
ActiveSupport::Notifications.monotonic_subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # 自定义内容
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 1560978.425334, finished: 1560979.429234)
end
```

每次定义所有这些块参数可能会很繁琐。您可以轻松地从块参数创建一个[`ActiveSupport::Notifications::Event`][]，如下所示：

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  event.name      # => "process_action.action_controller"
  event.duration  # => 10（以毫秒为单位）
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

您还可以传递一个只接受一个参数的块，它将接收一个事件对象：

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |event|
  event.name      # => "process_action.action_controller"
  event.duration  # => 10（以毫秒为单位）
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

您还可以订阅与正则表达式匹配的事件。这使您可以同时订阅多个事件。以下是如何订阅来自`ActionController`的所有事件：

```ruby
ActiveSupport::Notifications.subscribe(/action_controller/) do |*args|
  # 检查所有ActionController事件
end
```


在浏览器中查看仪表盘的时间
---------------------------

Rails实现了[服务器计时](https://www.w3.org/TR/server-timing/)标准，以使时间信息在Web浏览器中可用。要启用此功能，请编辑您的环境配置（通常是`development.rb`，因为它在开发中使用最多），并包含以下内容：

```ruby
  config.server_timing = true
```

配置完成后（包括重新启动服务器），您可以转到浏览器的开发者工具窗格，然后选择网络并重新加载页面。然后，您可以选择Rails服务器的任何请求，在计时选项卡中查看服务器计时。有关此操作的示例，请参阅[Firefox文档](https://firefox-source-docs.mozilla.org/devtools-user/network_monitor/request_details/index.html#server-timing)。

Rails框架钩子
-------------

在Ruby on Rails框架中，提供了许多用于常见事件的钩子。以下是这些事件及其有效负载的详细信息。
### Action Controller

#### `start_processing.action_controller`

| 键           | 值                                                       |
| ------------- | --------------------------------------------------------- |
| `:controller` | 控制器名称                                               |
| `:action`     | 动作                                                     |
| `:params`     | 不包含任何过滤参数的请求参数哈希                         |
| `:headers`    | 请求头                                                   |
| `:format`     | html/js/json/xml等                                        |
| `:method`     | HTTP请求动词                                             |
| `:path`       | 请求路径                                                 |

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

| 键             | 值                                                       |
| --------------- | --------------------------------------------------------- |
| `:controller`   | 控制器名称                                               |
| `:action`       | 动作                                                     |
| `:params`       | 不包含任何过滤参数的请求参数哈希                         |
| `:headers`      | 请求头                                                   |
| `:format`       | html/js/json/xml等                                        |
| `:method`       | HTTP请求动词                                             |
| `:path`         | 请求路径                                                 |
| `:request`      | [`ActionDispatch::Request`][] 对象                        |
| `:response`     | [`ActionDispatch::Response`][] 对象                       |
| `:status`       | HTTP状态码                                               |
| `:view_runtime` | 视图执行时间（以毫秒为单位）                             |
| `:db_runtime`   | 数据库查询执行时间（以毫秒为单位）                         |

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

| 键     | 值                           |
| ------- | ------------------------- |
| `:path` | 文件的完整路径 |

调用者可能会添加其他键。

#### `send_data.action_controller`

`ActionController` 不会向有效负载添加任何特定信息。所有选项都会传递到有效负载。

#### `redirect_to.action_controller`

| 键         | 值                                    |
| ----------- | ---------------------------------------- |
| `:status`   | HTTP响应码                       |
| `:location` | 重定向的URL                       |
| `:request`  | [`ActionDispatch::Request`][] 对象 |

```ruby
{
  status: 302,
  location: "http://localhost:3000/posts/new",
  request: <ActionDispatch::Request:0x00007ff1cb9bd7b8>
}
```

#### `halted_callback.action_controller`

| 键       | 值                         |
| --------- | ----------------------------- |
| `:filter` | 终止动作的过滤器 |

```ruby
{
  filter: ":halting_filter"
}
```

#### `unpermitted_parameters.action_controller`

| 键           | 值                                                                         |
| ------------- | ----------------------------------------------------------------------------- |
| `:keys`       | 未允许的键                                                          |
| `:context`    | 包含以下键的哈希：`:controller`、`:action`、`:params`、`:request` |

### Action Controller — 缓存

#### `write_fragment.action_controller`

| 键    | 值            |
| ------ | ---------------- |
| `:key` | 完整的键 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `read_fragment.action_controller`

| 键    | 值            |
| ------ | ---------------- |
| `:key` | 完整的键 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `expire_fragment.action_controller`

| 键    | 值            |
| ------ | ---------------- |
| `:key` | 完整的键 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `exist_fragment?.action_controller`

| 键    | 值            |
| ------ | ---------------- |
| `:key` | 完整的键 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### Action Dispatch

#### `process_middleware.action_dispatch`

| 键           | 值                  |
| ------------- | ---------------------- |
| `:middleware` | 中间件的名称 |

#### `redirect.action_dispatch`

| 键         | 值                                    |
| ----------- | ---------------------------------------- |
| `:status`   | HTTP响应码                       |
| `:location` | 重定向的URL                       |
| `:request`  | [`ActionDispatch::Request`][] 对象 |

#### `request.action_dispatch`

| 键         | 值                                    |
| ----------- | ---------------------------------------- |
| `:request`  | [`ActionDispatch::Request`][] 对象 |

### Action View

#### `render_template.action_view`

| 键           | 值                              |
| ------------- | ---------------------------------- |
| `:identifier` | 模板的完整路径              |
| `:layout`     | 应用的布局                  |
| `:locals`     | 传递给模板的局部变量 |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/index.html.erb",
  layout: "layouts/application",
  locals: { foo: "bar" }
}
```

#### `render_partial.action_view`

| 键           | 值                              |
| ------------- | ---------------------------------- |
| `:identifier` | 模板的完整路径              |
| `:locals`     | 传递给模板的局部变量 |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_form.html.erb",
  locals: { foo: "bar" }
}
```

#### `render_collection.action_view`

| 键           | 值                                 |
| ------------- | ------------------------------------- |
| `:identifier` | 模板的完整路径                 |
| `:count`      | 集合的大小                    |
| `:cache_hits` | 从缓存中获取的部分的数量 |

只有在使用`cached: true`渲染集合时，才会包含`:cache_hits`键。
```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_post.html.erb",
  count: 3,
  cache_hits: 0
}
```

#### `render_layout.action_view`

| 键           | 值                     |
| ------------- | --------------------- |
| `:identifier` | 模板的完整路径         |


```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/layouts/application.html.erb"
}
```


### Active Record

#### `sql.active_record`

| 键                  | 值                                      |
| -------------------- | ---------------------------------------- |
| `:sql`               | SQL语句                                 |
| `:name`              | 操作的名称                              |
| `:connection`        | 连接对象                                |
| `:binds`             | 绑定参数                                |
| `:type_casted_binds` | 类型转换后的绑定参数                    |
| `:statement_name`    | SQL语句的名称                           |
| `:cached`            | 当使用缓存查询时，添加`true`             |

适配器也可以添加自己的数据。

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

只有当[`config.active_record.action_on_strict_loading_violation`][]设置为`:log`时才会触发此事件。

| 键           | 值                                            |
| ------------- | ------------------------------------------------ |
| `:owner`      | 启用了`strict_loading`的模型                     |
| `:reflection` | 尝试加载的关联的反射                            |


#### `instantiation.active_record`

| 键              | 值                                        |
| ---------------- | ----------------------------------------- |
| `:record_count`  | 实例化的记录数                            |
| `:class_name`    | 记录的类名                                |

```ruby
{
  record_count: 1,
  class_name: "User"
}
```

### Action Mailer

#### `deliver.action_mailer`

| 键                   | 值                                                |
| --------------------- | ---------------------------------------------------- |
| `:mailer`             | 邮件类的名称                                       |
| `:message_id`         | 由Mail gem生成的消息ID                              |
| `:subject`            | 邮件的主题                                         |
| `:to`                 | 邮件的收件人地址                                   |
| `:from`               | 邮件的发件人地址                                   |
| `:bcc`                | 邮件的密送地址                                     |
| `:cc`                 | 邮件的抄送地址                                     |
| `:date`               | 邮件的日期                                         |
| `:mail`               | 邮件的编码形式                                     |
| `:perform_deliveries` | 是否执行此消息的传递                               |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails Guides",
  to: ["users@rails.com", "dhh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "...", # 省略以保持简洁
  perform_deliveries: true
}
```

#### `process.action_mailer`

| 键           | 值                     |
| ------------- | ------------------------ |
| `:mailer`     | 邮件类的名称 |
| `:action`     | 操作的名称               |
| `:args`       | 参数                     |

```ruby
{
  mailer: "Notification",
  action: "welcome_email",
  args: []
}
```

### Active Support — Caching

#### `cache_read.active_support`

| 键                | 值                   |
| ------------------ | ----------------------- |
| `:key`             | 存储中使用的键         |
| `:store`           | 存储类的名称           |
| `:hit`             | 如果此读取是命中的话   |
| `:super_operation` | 如果使用[`fetch`][ActiveSupport::Cache::Store#fetch]进行读取，则为`:fetch` |

#### `cache_read_multi.active_support`

| 键                | 值                   |
| ------------------ | ----------------------- |
| `:key`             | 存储中使用的键         |
| `:store`           | 存储类的名称           |
| `:hits`            | 命中的缓存键           |
| `:super_operation` | 如果使用[`fetch_multi`][ActiveSupport::Cache::Store#fetch_multi]进行读取，则为`:fetch_multi` |

#### `cache_generate.active_support`

只有在使用块调用[`fetch`][ActiveSupport::Cache::Store#fetch]时才会触发此事件。

| 键      | 值                   |
| -------- | ----------------------- |
| `:key`   | 存储中使用的键         |
| `:store` | 存储类的名称           |

在写入存储时，`fetch`传递的选项将与负载合并。

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_fetch_hit.active_support`

只有在使用块调用[`fetch`][ActiveSupport::Cache::Store#fetch]时才会触发此事件。

| 键      | 值                   |
| -------- | ----------------------- |
| `:key`   | 存储中使用的键         |
| `:store` | 存储类的名称           |

`fetch`传递的选项将与负载合并。

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write.active_support`

| 键      | 值                   |
| -------- | ----------------------- |
| `:key`   | 存储中使用的键         |
| `:store` | 存储类的名称           |

缓存存储也可以添加自己的数据。

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write_multi.active_support`

| 键      | 值                                |
| -------- | ------------------------------------ |
| `:key`   | 写入存储的键和值                    |
| `:store` | 存储类的名称                        |
#### `cache_increment.active_support`

仅在使用[`MemCacheStore`][ActiveSupport::Cache::MemCacheStore]或[`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore]时触发此事件。

| 键        | 值                       |
| --------- | ----------------------- |
| `:key`    | 存储中使用的键           |
| `:store`  | 存储类的名称             |
| `:amount` | 增加的数量               |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 99
}
```

#### `cache_decrement.active_support`

仅在使用Memcached或Redis缓存存储时触发此事件。

| 键        | 值                       |
| --------- | ----------------------- |
| `:key`    | 存储中使用的键           |
| `:store`  | 存储类的名称             |
| `:amount` | 减少的数量               |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 1
}
```

#### `cache_delete.active_support`

| 键       | 值                       |
| -------- | ----------------------- |
| `:key`   | 存储中使用的键           |
| `:store` | 存储类的名称             |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_delete_multi.active_support`

| 键       | 值                       |
| -------- | ----------------------- |
| `:key`   | 存储中使用的键           |
| `:store` | 存储类的名称             |

#### `cache_delete_matched.active_support`

仅在使用[`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore]、[`FileStore`][ActiveSupport::Cache::FileStore]或[`MemoryStore`][ActiveSupport::Cache::MemoryStore]时触发此事件。

| 键       | 值                       |
| -------- | ----------------------- |
| `:key`   | 使用的键模式             |
| `:store` | 存储类的名称             |

```ruby
{
  key: "posts/*",
  store: "ActiveSupport::Cache::RedisCacheStore"
}
```

#### `cache_cleanup.active_support`

仅在使用[`MemoryStore`][ActiveSupport::Cache::MemoryStore]时触发此事件。

| 键       | 值                                         |
| -------- | ----------------------------------------- |
| `:store` | 存储类的名称                               |
| `:size`  | 清理前缓存中的条目数量                     |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  size: 9001
}
```

#### `cache_prune.active_support`

仅在使用[`MemoryStore`][ActiveSupport::Cache::MemoryStore]时触发此事件。

| 键       | 值                                         |
| -------- | ----------------------------------------- |
| `:store` | 存储类的名称                               |
| `:key`   | 缓存的目标大小（以字节为单位）             |
| `:from`  | 清理前缓存的大小（以字节为单位）           |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  key: 5000,
  from: 9001
}
```

#### `cache_exist?.active_support`

| 键       | 值                       |
| -------- | ----------------------- |
| `:key`   | 存储中使用的键           |
| `:store` | 存储类的名称             |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```


### Active Support — Messages

#### `message_serializer_fallback.active_support`

| 键             | 值                                 |
| --------------- | --------------------------------- |
| `:serializer`   | 主要（预期）序列化器               |
| `:fallback`     | 回退（实际）序列化器               |
| `:serialized`   | 序列化后的字符串                   |
| `:deserialized` | 反序列化后的值                     |

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

| 键          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 处理作业的QueueAdapter对象              |
| `:job`       | 作业对象                                |

#### `enqueue.active_job`

| 键          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 处理作业的QueueAdapter对象              |
| `:job`       | 作业对象                                |

#### `enqueue_retry.active_job`

| 键          | 值                                      |
| ------------ | -------------------------------------- |
| `:job`       | 作业对象                                |
| `:adapter`   | 处理作业的QueueAdapter对象              |
| `:error`     | 导致重试的错误                         |
| `:wait`      | 重试的延迟时间                         |

#### `enqueue_all.active_job`

| 键          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 处理作业的QueueAdapter对象              |
| `:jobs`      | 作业对象的数组                          |

#### `perform_start.active_job`

| 键          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 处理作业的QueueAdapter对象              |
| `:job`       | 作业对象                                |

#### `perform.active_job`

| 键           | 值                                              |
| ------------- | ---------------------------------------------- |
| `:adapter`    | 处理作业的QueueAdapter对象                      |
| `:job`        | 作业对象                                        |
| `:db_runtime` | 执行数据库查询所花费的时间（以毫秒为单位）       |

#### `retry_stopped.active_job`

| 键          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 处理作业的QueueAdapter对象              |
| `:job`       | 作业对象                                |
| `:error`     | 导致重试的错误                         |

#### `discard.active_job`

| 键          | 值                                      |
| ------------ | -------------------------------------- |
| `:adapter`   | 处理作业的QueueAdapter对象              |
| `:job`       | 作业对象                                |
| `:error`     | 导致丢弃的错误                         |
### Action Cable

#### `perform_action.action_cable`

| 键               | 值                        |
| ---------------- | ------------------------- |
| `:channel_class` | 频道类的名称              |
| `:action`        | 动作                      |
| `:data`          | 数据的哈希表              |

#### `transmit.action_cable`

| 键               | 值                        |
| ---------------- | ------------------------- |
| `:channel_class` | 频道类的名称              |
| `:data`          | 数据的哈希表              |
| `:via`           | 通过                      |

#### `transmit_subscription_confirmation.action_cable`

| 键               | 值                        |
| ---------------- | ------------------------- |
| `:channel_class` | 频道类的名称              |

#### `transmit_subscription_rejection.action_cable`

| 键               | 值                        |
| ---------------- | ------------------------- |
| `:channel_class` | 频道类的名称              |

#### `broadcast.action_cable`

| 键              | 值                   |
| --------------- | -------------------- |
| `:broadcasting` | 命名的广播           |
| `:message`      | 消息的哈希表         |
| `:coder`        | 编码器               |

### Active Storage

#### `preview.active_storage`

| 键          | 值               |
| ------------ | ------------------- |
| `:key`       | 安全令牌        |

#### `transform.active_storage`

#### `analyze.active_storage`

| 键          | 值                          |
| ------------ | ------------------------------ |
| `:analyzer`  | 分析器的名称，例如 ffprobe |

### Active Storage — 存储服务

#### `service_upload.active_storage`

| 键          | 值                        |
| ------------ | ---------------------------- |
| `:key`       | 安全令牌                 |
| `:service`   | 服务的名称                |
| `:checksum`  | 用于确保完整性的校验和     |

#### `service_streaming_download.active_storage`

| 键          | 值               |
| ------------ | ------------------- |
| `:key`       | 安全令牌        |
| `:service`   | 服务的名称     |

#### `service_download_chunk.active_storage`

| 键          | 值                           |
| ------------ | ------------------------------- |
| `:key`       | 安全令牌                        |
| `:service`   | 服务的名称                     |
| `:range`     | 尝试读取的字节范围             |

#### `service_download.active_storage`

| 键          | 值               |
| ------------ | ------------------- |
| `:key`       | 安全令牌        |
| `:service`   | 服务的名称     |

#### `service_delete.active_storage`

| 键          | 值               |
| ------------ | ------------------- |
| `:key`       | 安全令牌        |
| `:service`   | 服务的名称     |

#### `service_delete_prefixed.active_storage`

| 键          | 值               |
| ------------ | ------------------- |
| `:prefix`    | 键的前缀          |
| `:service`   | 服务的名称     |

#### `service_exist.active_storage`

| 键          | 值                       |
| ------------ | --------------------------- |
| `:key`       | 安全令牌                |
| `:service`   | 服务的名称             |
| `:exist`     | 文件或 Blob 是否存在    |

#### `service_url.active_storage`

| 键          | 值               |
| ------------ | ------------------- |
| `:key`       | 安全令牌        |
| `:service`   | 服务的名称     |
| `:url`       | 生成的 URL       |

#### `service_update_metadata.active_storage`

仅在使用 Google Cloud Storage 服务时会触发此事件。

| 键             | 值                            |
| --------------- | -------------------------------- |
| `:key`          | 安全令牌                     |
| `:service`      | 服务的名称                   |
| `:content_type` | HTTP `Content-Type` 字段     |
| `:disposition`  | HTTP `Content-Disposition` 字段 |

### Action Mailbox

#### `process.action_mailbox`

| 键              | 值                                                  |
| -----------------| ------------------------------------------------------ |
| `:mailbox`       | 继承自 [`ActionMailbox::Base`][] 的 Mailbox 类的实例 |
| `:inbound_email` | 包含有关正在处理的入站电子邮件的数据的哈希表 |

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

| 键            | 值                                               |
| -------------- | --------------------------------------------------- |
| `:initializer` | `config/initializers` 中加载的初始化器的路径 |

### Rails

#### `deprecation.rails`

| 键                    | 值                                                 |
| ---------------------- | ------------------------------------------------------|
| `:message`             | 弃用警告                                           |
| `:callstack`           | 弃用警告的来源                                     |
| `:gem_name`            | 报告弃用警告的 gem 的名称                           |
| `:deprecation_horizon` | 弃用行为将被移除的版本                             |

异常
----------

如果在任何仪表化过程中发生异常，负载将包含有关异常的信息。

| 键                 | 值                                                          |
| ------------------- | -------------------------------------------------------------- |
| `:exception`        | 一个包含两个元素的数组。异常类名和消息                         |
| `:exception_object` | 异常对象                                                    |

创建自定义事件
----------------------

添加自己的事件也很容易。Active Support 将为您处理所有繁重的工作。只需调用 [`ActiveSupport::Notifications.instrument`][]，并提供一个 `name`、`payload` 和一个块。通知将在块返回后发送。Active Support 将生成开始和结束时间，并添加仪表化器的唯一 ID。所有传递给 `instrument` 调用的数据都将包含在负载中。
这是一个例子：

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data do
  # 在这里执行自定义操作
end
```

现在你可以通过以下方式监听这个事件：

```ruby
ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

你也可以调用`instrument`而不传递一个块。这样可以利用基础设施进行其他消息传递。

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data

ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

在定义自己的事件时，应遵循Rails的约定。格式为：`event.library`。如果你的应用程序发送推文，应创建一个名为`tweet.twitter`的事件。
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
