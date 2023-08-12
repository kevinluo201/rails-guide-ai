**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b093936da01fde14532f4cead51234e1
Active Support Instrumentation
==============================

Active Support는 Ruby 언어 확장 기능, 유틸리티 및 기타 기능을 제공하는 Rails의 핵심 부분입니다. 그 중 하나는 애플리케이션 내에서 발생하는 특정 동작을 측정하기 위해 사용할 수 있는 instrumentation API를 포함하고 있습니다. 이는 Rails 애플리케이션이나 프레임워크 내부의 Ruby 코드와 같은 곳에서 발생하는 동작을 측정하는 데 사용할 수 있습니다. 그러나 Rails에만 국한되지 않고 원하는 경우 다른 Ruby 스크립트에서도 독립적으로 사용할 수 있습니다.

이 가이드에서는 Active Support의 instrumentation API를 사용하여 Rails 및 다른 Ruby 코드 내에서 이벤트를 측정하는 방법을 알아보겠습니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* Instrumentation이 제공하는 기능
* 후크에 구독자를 추가하는 방법
* 브라우저에서 instrumentation의 타이밍을 확인하는 방법
* Rails 프레임워크 내의 instrumentation을 위한 후크
* 사용자 정의 instrumentation 구현 방법

--------------------------------------------------------------------------------

Instrumentation 소개
-------------------

Active Support에서 제공하는 instrumentation API를 사용하면 개발자가 다른 개발자가 후크를 사용할 수 있는 후크를 제공할 수 있습니다. Rails 프레임워크 내에는 [여러 개](#rails-framework-hooks)의 후크가 있습니다. 이 API를 사용하면 개발자는 자신의 애플리케이션이나 다른 Ruby 코드 내에서 특정 이벤트가 발생할 때 알림을 받을 수 있습니다.

예를 들어, Active Record 내에서 제공되는 [후크](#sql-active-record)는 Active Record가 데이터베이스에서 SQL 쿼리를 사용할 때마다 호출됩니다. 이 후크는 **구독**할 수 있으며, 특정 동작 중에 발생하는 쿼리 수를 추적하는 데 사용할 수 있습니다. 또 다른 후크는 [컨트롤러의 동작 처리](#process-action-action-controller) 주변에 있습니다. 이는 특정 동작이 얼마나 오래 걸렸는지 추적하는 데 사용할 수 있습니다.

또한 나중에 구독할 수 있는 애플리케이션 내에서 [사용자 정의 이벤트](#creating-custom-events)를 생성할 수도 있습니다.

이벤트에 구독하기
-----------------------

이벤트에 구독하는 것은 간단합니다. [`ActiveSupport::Notifications.subscribe`][]를 사용하여 알림을 수신하기 위해 블록을 사용하면 됩니다.

블록은 다음 인수를 받습니다:

* 이벤트의 이름
* 시작 시간
* 종료 시간
* 이벤트를 발생시킨 instrumenter의 고유 ID
* 이벤트의 페이로드

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # 사용자 정의 코드
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 2019-05-05 13:43:57 -0800, finished: 2019-05-05 13:43:58 -0800)
end
```

`started`와 `finished`의 정확성에 대해 걱정된다면 [`ActiveSupport::Notifications.monotonic_subscribe`][]를 사용하세요. 주어진 블록은 위와 동일한 인수를 받지만, `started`와 `finished`는 월-클록 시간 대신 정확한 단조 시간 값을 갖습니다.

```ruby
ActiveSupport::Notifications.monotonic_subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # 사용자 정의 코드
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 1560978.425334, finished: 1560979.429234)
end
```

매번 블록 인수를 정의하는 것은 번거로울 수 있습니다. 다음과 같이 블록 인수에서 [`ActiveSupport::Notifications::Event`][]를 쉽게 생성할 수 있습니다:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (밀리초 단위)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

인수가 하나뿐인 블록을 전달할 수도 있으며, 이 경우 이벤트 객체가 전달됩니다:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |event|
  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (밀리초 단위)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```

정규 표현식과 일치하는 이벤트에도 구독할 수 있습니다. 이를 통해 한 번에 여러 이벤트에 구독할 수 있습니다. `ActionController`에서 모든 것을 구독하는 방법은 다음과 같습니다:

```ruby
ActiveSupport::Notifications.subscribe(/action_controller/) do |*args|
  # 모든 ActionController 이벤트를 검사
end
```


브라우저에서 Instrumentation의 타이밍 확인하기
-------------------------------------------------

Rails는 [Server Timing](https://www.w3.org/TR/server-timing/) 표준을 구현하여 타이밍 정보를 웹 브라우저에서 사용할 수 있게 합니다. 활성화하려면 환경 설정(일반적으로 `development.rb`가 가장 많이 사용됨)을 편집하여 다음을 포함하면 됩니다:

```ruby
  config.server_timing = true
```

설정을 완료한 후(서버를 다시 시작 포함), 브라우저의 개발자 도구 창으로 이동한 다음 Network를 선택하고 페이지를 다시로드합니다. 그런 다음 Rails 서버로의 요청 중 하나를 선택하면 타이밍 탭에서 서버 타이밍을 볼 수 있습니다. 이에 대한 예는 [Firefox 문서](https://firefox-source-docs.mozilla.org/devtools-user/network_monitor/request_details/index.html#server-timing)를 참조하십시오.

Rails 프레임워크 후크
---------------------

Ruby on Rails 프레임워크 내에서는 일반적인 이벤트에 대한 여러 후크가 제공됩니다. 이러한 이벤트와 해당 페이로드에 대한 자세한 내용은 아래에서 확인할 수 있습니다.
### 액션 컨트롤러

#### `start_processing.action_controller`

| 키           | 값                                                       |
| ------------- | --------------------------------------------------------- |
| `:controller` | 컨트롤러 이름                                           |
| `:action`     | 액션                                                     |
| `:params`     | 필터링된 매개변수 없이 요청 매개변수의 해시               |
| `:headers`    | 요청 헤더                                                |
| `:format`     | html/js/json/xml 등                                      |
| `:method`     | HTTP 요청 동사                                           |
| `:path`       | 요청 경로                                                |

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

| 키             | 값                                                       |
| --------------- | --------------------------------------------------------- |
| `:controller`   | 컨트롤러 이름                                           |
| `:action`       | 액션                                                     |
| `:params`       | 필터링된 매개변수 없이 요청 매개변수의 해시               |
| `:headers`      | 요청 헤더                                                |
| `:format`       | html/js/json/xml 등                                      |
| `:method`       | HTTP 요청 동사                                           |
| `:path`         | 요청 경로                                                |
| `:request`      | [`ActionDispatch::Request`][] 객체                        |
| `:response`     | [`ActionDispatch::Response`][] 객체                       |
| `:status`       | HTTP 상태 코드                                           |
| `:view_runtime` | 뷰에서 소요된 시간 (밀리초)                              |
| `:db_runtime`   | 데이터베이스 쿼리 실행에 소요된 시간 (밀리초)             |

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

| 키     | 값                             |
| ------- | ----------------------------- |
| `:path` | 파일의 전체 경로              |

호출자에 의해 추가 키가 추가될 수 있습니다.

#### `send_data.action_controller`

`ActionController`는 페이로드에 특정 정보를 추가하지 않습니다. 모든 옵션은 페이로드로 전달됩니다.

#### `redirect_to.action_controller`

| 키         | 값                                    |
| ----------- | ---------------------------------------- |
| `:status`   | HTTP 응답 코드                       |
| `:location` | 리디렉션할 URL                       |
| `:request`  | [`ActionDispatch::Request`][] 객체 |

```ruby
{
  status: 302,
  location: "http://localhost:3000/posts/new",
  request: <ActionDispatch::Request:0x00007ff1cb9bd7b8>
}
```

#### `halted_callback.action_controller`

| 키       | 값                         |
| --------- | ----------------------------- |
| `:filter` | 액션을 중단시킨 필터 |

```ruby
{
  filter: ":halting_filter"
}
```

#### `unpermitted_parameters.action_controller`

| 키           | 값                                                                         |
| ------------- | ----------------------------------------------------------------------------- |
| `:keys`       | 허용되지 않은 키                                                          |
| `:context`    | 다음 키를 가진 해시: `:controller`, `:action`, `:params`, `:request` |

### 액션 컨트롤러 — 캐싱

#### `write_fragment.action_controller`

| 키    | 값            |
| ------ | ---------------- |
| `:key` | 전체 키 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `read_fragment.action_controller`

| 키    | 값            |
| ------ | ---------------- |
| `:key` | 전체 키 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `expire_fragment.action_controller`

| 키    | 값            |
| ------ | ---------------- |
| `:key` | 전체 키 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `exist_fragment?.action_controller`

| 키    | 값            |
| ------ | ---------------- |
| `:key` | 전체 키 |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### 액션 디스패치

#### `process_middleware.action_dispatch`

| 키           | 값                  |
| ------------- | ---------------------- |
| `:middleware` | 미들웨어의 이름 |

#### `redirect.action_dispatch`

| 키         | 값                                    |
| ----------- | ---------------------------------------- |
| `:status`   | HTTP 응답 코드                       |
| `:location` | 리디렉션할 URL                       |
| `:request`  | [`ActionDispatch::Request`][] 객체 |

#### `request.action_dispatch`

| 키         | 값                                    |
| ----------- | ---------------------------------------- |
| `:request`  | [`ActionDispatch::Request`][] 객체 |

### 액션 뷰

#### `render_template.action_view`

| 키           | 값                              |
| ------------- | ---------------------------------- |
| `:identifier` | 템플릿의 전체 경로              |
| `:layout`     | 적용 가능한 레이아웃                  |
| `:locals`     | 템플릿에 전달된 로컬 변수 |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/index.html.erb",
  layout: "layouts/application",
  locals: { foo: "bar" }
}
```

#### `render_partial.action_view`

| 키           | 값                              |
| ------------- | ---------------------------------- |
| `:identifier` | 템플릿의 전체 경로              |
| `:locals`     | 템플릿에 전달된 로컬 변수 |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_form.html.erb",
  locals: { foo: "bar" }
}
```

#### `render_collection.action_view`

| 키           | 값                                 |
| ------------- | ------------------------------------- |
| `:identifier` | 템플릿의 전체 경로                 |
| `:count`      | 컬렉션의 크기                    |
| `:cache_hits` | 캐시에서 가져온 부분의 수 |

`:cache_hits` 키는 컬렉션이 `cached: true`로 렌더링된 경우에만 포함됩니다.
```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_post.html.erb",
  count: 3,
  cache_hits: 0
}
```

#### `render_layout.action_view`

| 키           | 값                     |
| ------------- | --------------------- |
| `:identifier` | 템플릿의 전체 경로     |


```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/layouts/application.html.erb"
}
```


### Active Record

#### `sql.active_record`

| 키                  | 값                                        |
| -------------------- | ---------------------------------------- |
| `:sql`               | SQL 문장                                 |
| `:name`              | 작업의 이름                              |
| `:connection`        | 연결 객체                                |
| `:binds`             | 바인드 매개변수                           |
| `:type_casted_binds` | 형변환된 바인드 매개변수                  |
| `:statement_name`    | SQL 문장의 이름                          |
| `:cached`            | 캐시된 쿼리를 사용할 때 `true`가 추가됨 |

어댑터는 자체 데이터를 추가할 수도 있습니다.

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

이 이벤트는 [`config.active_record.action_on_strict_loading_violation`][]이 `:log`로 설정된 경우에만 발생합니다.

| 키           | 값                                            |
| ------------- | ------------------------------------------------ |
| `:owner`      | `strict_loading`이 활성화된 모델                 |
| `:reflection` | 로드를 시도한 연관관계의 리플렉션                 |


#### `instantiation.active_record`

| 키              | 값                                     |
| ---------------- | ----------------------------------------- |
| `:record_count`  | 인스턴스화된 레코드의 수                 |
| `:class_name`    | 레코드의 클래스                         |

```ruby
{
  record_count: 1,
  class_name: "User"
}
```

### Action Mailer

#### `deliver.action_mailer`

| 키                   | 값                                                |
| --------------------- | ---------------------------------------------------- |
| `:mailer`             | 메일러 클래스의 이름                                |
| `:message_id`         | Mail 젬에 의해 생성된 메시지의 ID                    |
| `:subject`            | 메일의 제목                                        |
| `:to`                 | 메일의 수신자 주소                                 |
| `:from`               | 메일의 발신자 주소                                 |
| `:bcc`                | 메일의 숨은 참조 주소                              |
| `:cc`                 | 메일의 참조 주소                                   |
| `:date`               | 메일의 날짜                                        |
| `:mail`               | 메일의 인코딩된 형태                               |
| `:perform_deliveries` | 이 메시지의 전송이 수행되는지 여부                  |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails Guides",
  to: ["users@rails.com", "dhh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "...", # 생략
  perform_deliveries: true
}
```

#### `process.action_mailer`

| 키           | 값                     |
| ------------- | ------------------------ |
| `:mailer`     | 메일러 클래스의 이름 |
| `:action`     | 액션의 이름               |
| `:args`       | 인수                      |

```ruby
{
  mailer: "Notification",
  action: "welcome_email",
  args: []
}
```

### Active Support — Caching

#### `cache_read.active_support`

| 키                | 값                   |
| ------------------ | ----------------------- |
| `:key`             | 스토어에서 사용된 키   |
| `:store`           | 스토어 클래스의 이름 |
| `:hit`             | 이 읽기가 캐시 히트인지 여부 |
| `:super_operation` | [`fetch`][ActiveSupport::Cache::Store#fetch]로 읽기가 수행된 경우 `:fetch` |

#### `cache_read_multi.active_support`

| 키                | 값                   |
| ------------------ | ----------------------- |
| `:key`             | 스토어에서 사용된 키들 |
| `:store`           | 스토어 클래스의 이름 |
| `:hits`            | 캐시 히트된 키들      |
| `:super_operation` | [`fetch_multi`][ActiveSupport::Cache::Store#fetch_multi]로 읽기가 수행된 경우 `:fetch_multi` |

#### `cache_generate.active_support`

이 이벤트는 블록이 있는 [`fetch`][ActiveSupport::Cache::Store#fetch] 호출시에만 발생합니다.

| 키      | 값                   |
| -------- | ----------------------- |
| `:key`   | 스토어에서 사용된 키   |
| `:store` | 스토어 클래스의 이름 |

`fetch`에 전달된 옵션은 스토어에 쓸 때 페이로드와 병합됩니다.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_fetch_hit.active_support`

이 이벤트는 블록이 있는 [`fetch`][ActiveSupport::Cache::Store#fetch] 호출시에만 발생합니다.

| 키      | 값                   |
| -------- | ----------------------- |
| `:key`   | 스토어에서 사용된 키   |
| `:store` | 스토어 클래스의 이름 |

`fetch`에 전달된 옵션은 페이로드와 병합됩니다.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write.active_support`

| 키      | 값                   |
| -------- | ----------------------- |
| `:key`   | 스토어에서 사용된 키   |
| `:store` | 스토어 클래스의 이름 |

캐시 스토어는 자체 데이터를 추가할 수도 있습니다.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write_multi.active_support`

| 키      | 값                                |
| -------- | ------------------------------------ |
| `:key`   | 스토어에 쓰여진 키와 값              |
| `:store` | 스토어 클래스의 이름              |
#### `cache_increment.active_support`

이 이벤트는 [`MemCacheStore`][ActiveSupport::Cache::MemCacheStore] 또는 [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore]를 사용할 때만 발생합니다.

| 키        | 값                     |
| --------- | ----------------------- |
| `:key`    | 스토어에서 사용된 키   |
| `:store`  | 스토어 클래스의 이름   |
| `:amount` | 증가량                 |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 99
}
```

#### `cache_decrement.active_support`

이 이벤트는 Memcached 또는 Redis 캐시 스토어를 사용할 때만 발생합니다.

| 키        | 값                     |
| --------- | ----------------------- |
| `:key`    | 스토어에서 사용된 키   |
| `:store`  | 스토어 클래스의 이름   |
| `:amount` | 감소량                 |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 1
}
```

#### `cache_delete.active_support`

| 키       | 값                     |
| -------- | ----------------------- |
| `:key`   | 스토어에서 사용된 키   |
| `:store` | 스토어 클래스의 이름   |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_delete_multi.active_support`

| 키       | 값                     |
| -------- | ----------------------- |
| `:key`   | 스토어에서 사용된 키들 |
| `:store` | 스토어 클래스의 이름   |

#### `cache_delete_matched.active_support`

이 이벤트는 [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore], [`FileStore`][ActiveSupport::Cache::FileStore], 또는 [`MemoryStore`][ActiveSupport::Cache::MemoryStore]를 사용할 때만 발생합니다.

| 키       | 값                     |
| -------- | ----------------------- |
| `:key`   | 사용된 키 패턴        |
| `:store` | 스토어 클래스의 이름   |

```ruby
{
  key: "posts/*",
  store: "ActiveSupport::Cache::RedisCacheStore"
}
```

#### `cache_cleanup.active_support`

이 이벤트는 [`MemoryStore`][ActiveSupport::Cache::MemoryStore]를 사용할 때만 발생합니다.

| 키       | 값                                         |
| -------- | --------------------------------------------- |
| `:store` | 스토어 클래스의 이름                       |
| `:size`  | 정리 전 캐시의 항목 수 |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  size: 9001
}
```

#### `cache_prune.active_support`

이 이벤트는 [`MemoryStore`][ActiveSupport::Cache::MemoryStore]를 사용할 때만 발생합니다.

| 키       | 값                                         |
| -------- | --------------------------------------------- |
| `:store` | 스토어 클래스의 이름                       |
| `:key`   | 캐시의 대상 크기 (바이트)          |
| `:from`  | 정리 전 캐시의 크기 (바이트)     |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  key: 5000,
  from: 9001
}
```

#### `cache_exist?.active_support`

| 키       | 값                     |
| -------- | ----------------------- |
| `:key`   | 스토어에서 사용된 키   |
| `:store` | 스토어 클래스의 이름   |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```


### Active Support — Messages

#### `message_serializer_fallback.active_support`

| 키             | 값                         |
| --------------- | ----------------------------- |
| `:serializer`   | 주요 (원래 의도된) 직렬화기 |
| `:fallback`     | 대체 (실제) 직렬화기  |
| `:serialized`   | 직렬화된 문자열             |
| `:deserialized` | 역직렬화된 값            |

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

| 키          | 값                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | 작업을 처리하는 QueueAdapter 객체 |
| `:job`       | 작업 객체                             |

#### `enqueue.active_job`

| 키          | 값                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | 작업을 처리하는 QueueAdapter 객체 |
| `:job`       | 작업 객체                             |

#### `enqueue_retry.active_job`

| 키          | 값                                  |
| ------------ | -------------------------------------- |
| `:job`       | 작업 객체                             |
| `:adapter`   | 작업을 처리하는 QueueAdapter 객체 |
| `:error`     | 재시도를 발생시킨 오류        |
| `:wait`      | 재시도의 지연 시간                 |

#### `enqueue_all.active_job`

| 키          | 값                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | 작업을 처리하는 QueueAdapter 객체 |
| `:jobs`      | 작업 객체의 배열                |

#### `perform_start.active_job`

| 키          | 값                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | 작업을 처리하는 QueueAdapter 객체 |
| `:job`       | 작업 객체                             |

#### `perform.active_job`

| 키           | 값                                         |
| ------------- | --------------------------------------------- |
| `:adapter`    | 작업을 처리하는 QueueAdapter 객체        |
| `:job`        | 작업 객체                                    |
| `:db_runtime` | 데이터베이스 쿼리 실행에 소요된 시간 (밀리초) |

#### `retry_stopped.active_job`

| 키          | 값                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | 작업을 처리하는 QueueAdapter 객체 |
| `:job`       | 작업 객체                             |
| `:error`     | 재시도를 발생시킨 오류        |

#### `discard.active_job`

| 키          | 값                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | 작업을 처리하는 QueueAdapter 객체 |
| `:job`       | 작업 객체                             |
| `:error`     | 폐기를 발생시킨 오류      |
### 액션 케이블

#### `perform_action.action_cable`

| 키               | 값                        |
| ---------------- | ------------------------- |
| `:channel_class` | 채널 클래스의 이름        |
| `:action`        | 액션                      |
| `:data`          | 데이터의 해시             |

#### `transmit.action_cable`

| 키               | 값                        |
| ---------------- | ------------------------- |
| `:channel_class` | 채널 클래스의 이름        |
| `:data`          | 데이터의 해시             |
| `:via`           | 경로                      |

#### `transmit_subscription_confirmation.action_cable`

| 키               | 값                        |
| ---------------- | ------------------------- |
| `:channel_class` | 채널 클래스의 이름        |

#### `transmit_subscription_rejection.action_cable`

| 키               | 값                        |
| ---------------- | ------------------------- |
| `:channel_class` | 채널 클래스의 이름        |

#### `broadcast.action_cable`

| 키              | 값                   |
| --------------- | ------------------- |
| `:broadcasting` | 이름이 지정된 브로드캐스팅 |
| `:message`      | 메시지의 해시       |
| `:coder`        | 코더                |

### 액티브 스토리지

#### `preview.active_storage`

| 키          | 값                |
| ------------ | ------------------- |
| `:key`       | 보안 토큰        |

#### `transform.active_storage`

#### `analyze.active_storage`

| 키          | 값                          |
| ------------ | ------------------------------ |
| `:analyzer`  | 분석기의 이름, 예: ffprobe |

### 액티브 스토리지 - 스토리지 서비스

#### `service_upload.active_storage`

| 키          | 값                        |
| ------------ | ---------------------------- |
| `:key`       | 보안 토큰                 |
| `:service`   | 서비스의 이름              |
| `:checksum`  | 무결성을 보장하기 위한 체크섬 |

#### `service_streaming_download.active_storage`

| 키          | 값                |
| ------------ | ------------------- |
| `:key`       | 보안 토큰        |
| `:service`   | 서비스의 이름     |

#### `service_download_chunk.active_storage`

| 키          | 값                           |
| ------------ | ------------------------------- |
| `:key`       | 보안 토큰                    |
| `:service`   | 서비스의 이름                 |
| `:range`     | 읽으려고 시도한 바이트 범위    |

#### `service_download.active_storage`

| 키          | 값                |
| ------------ | ------------------- |
| `:key`       | 보안 토큰        |
| `:service`   | 서비스의 이름     |

#### `service_delete.active_storage`

| 키          | 값                |
| ------------ | ------------------- |
| `:key`       | 보안 토큰        |
| `:service`   | 서비스의 이름     |

#### `service_delete_prefixed.active_storage`

| 키          | 값                |
| ------------ | ------------------- |
| `:prefix`    | 키의 접두사       |
| `:service`   | 서비스의 이름     |

#### `service_exist.active_storage`

| 키          | 값                        |
| ------------ | --------------------------- |
| `:key`       | 보안 토큰                 |
| `:service`   | 서비스의 이름              |
| `:exist`     | 파일 또는 블롭이 존재하는지 여부 |

#### `service_url.active_storage`

| 키          | 값                |
| ------------ | ------------------- |
| `:key`       | 보안 토큰        |
| `:service`   | 서비스의 이름     |
| `:url`       | 생성된 URL        |

#### `service_update_metadata.active_storage`

이 이벤트는 Google Cloud Storage 서비스를 사용할 때만 발생합니다.

| 키             | 값                            |
| --------------- | -------------------------------- |
| `:key`          | 보안 토큰                     |
| `:service`      | 서비스의 이름                  |
| `:content_type` | HTTP `Content-Type` 필드        |
| `:disposition`  | HTTP `Content-Disposition` 필드 |

### 액션 메일박스

#### `process.action_mailbox`

| 키              | 값                                                  |
| -----------------| ------------------------------------------------------ |
| `:mailbox`       | [`ActionMailbox::Base`][]를 상속하는 메일박스 클래스의 인스턴스 |
| `:inbound_email` | 처리 중인 인바운드 이메일에 대한 데이터를 포함한 해시 |

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

| 키            | 값                                               |
| -------------- | --------------------------------------------------- |
| `:initializer` | `config/initializers`에서 로드된 초기화 파일의 경로 |

### Rails

#### `deprecation.rails`

| 키                    | 값                                                 |
| ---------------------- | ------------------------------------------------------|
| `:message`             | 폐기 경고 메시지                                   |
| `:callstack`           | 폐기 경고가 발생한 위치                             |
| `:gem_name`            | 폐기 경고를 보고하는 젬의 이름                      |
| `:deprecation_horizon` | 폐기될 동작이 제거될 버전                           |

예외
----------

계측 중에 예외가 발생하면 페이로드에 관련 정보가 포함됩니다.

| 키                 | 값                                                          |
| ------------------- | -------------------------------------------------------------- |
| `:exception`        | 예외 클래스 이름과 메시지로 구성된 두 개의 요소로 이루어진 배열 |
| `:exception_object` | 예외 객체                                                   |

사용자 정의 이벤트 생성
----------------------

사용자 정의 이벤트를 추가하는 것도 매우 쉽습니다. Active Support가 모든 번거로운 작업을 처리해줍니다. `name`, `payload` 및 블록을 사용하여 [`ActiveSupport::Notifications.instrument`][]를 호출하기만 하면 됩니다. 블록이 반환된 후에 알림이 전송됩니다. Active Support가 시작 및 종료 시간을 생성하고 계측기의 고유 ID를 추가합니다. `instrument` 호출에 전달된 모든 데이터가 페이로드로 전달됩니다.
다음은 예시입니다:

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data do
  # 여기에 사용자 정의 작업을 수행하세요
end
```

이제 다음과 같이 이벤트를 수신할 수 있습니다:

```ruby
ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

블록을 전달하지 않고도 `instrument`를 호출할 수도 있습니다. 이를 통해 다른 메시징 용도에도 기구를 활용할 수 있습니다.

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data

ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

사용자 정의 이벤트를 정의할 때는 Rails 규칙을 따라야 합니다. 형식은 `event.library`입니다. 예를 들어 애플리케이션이 트윗을 보내는 경우 `tweet.twitter`라는 이벤트를 생성해야 합니다.
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
