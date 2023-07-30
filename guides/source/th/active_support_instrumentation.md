**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b093936da01fde14532f4cead51234e1
Active Support Instrumentation
==============================

Active Support เป็นส่วนหนึ่งของ Rails ที่ให้การขยายภาษา Ruby, โปรแกรมเสริม และสิ่งอื่น ๆ ให้บริการ ส่วนหนึ่งที่มีอยู่ใน Active Support คือ API สำหรับการตรวจสอบที่สามารถใช้ภายในแอปพลิเคชันเพื่อวัดการกระทำบางอย่างที่เกิดขึ้นภายในรหัส Ruby เช่นในแอปพลิเคชัน Rails หรือเฟรมเวิร์กเอง แต่ไม่จำกัดเฉพาะ Rails เท่านั้น สามารถใช้งานแยกต่างหากในสคริปต์ Ruby อื่น ๆ ได้ตามต้องการ

ในคู่มือนี้คุณจะเรียนรู้วิธีใช้ Active Support's instrumentation API เพื่อวัดเหตุการณ์ภายใน Rails และรหัส Ruby อื่น ๆ

หลังจากอ่านคู่มือนี้คุณจะรู้:

* ว่า instrumentation สามารถให้บริการอะไรได้บ้าง
* วิธีเพิ่มผู้สมัครในตัวเก้าอี้
* วิธีดูเวลาจาก instrumentation ในเบราว์เซอร์ของคุณ
* ตัวเก้าอี้ภายในเฟรมเวิร์ก Rails สำหรับ instrumentation
* วิธีสร้างการดำเนินการ instrumentation ที่กำหนดเอง

--------------------------------------------------------------------------------

แนะนำการใช้งาน Instrumentation
-------------------------------

API สำหรับ instrumentation ที่ Active Support ให้เป็นการให้นักพัฒนาสามารถให้ตัวเก้าอี้ที่นักพัฒนาคนอื่นสามารถเชื่อมต่อได้ มี [หลายอย่าง](#rails-framework-hooks) ในเฟรมเวิร์ก Rails ด้วย ด้วย API นี้นักพัฒนาสามารถเลือกที่จะได้รับการแจ้งเตือนเมื่อเหตุการณ์บางอย่างเกิดขึ้นภายในแอปพลิเคชันของพวกเขาหรือรหัส Ruby อื่น ๆ

ตัวอย่างเช่น มี [ตัวเก้าอี้](#sql-active-record) ที่ให้ใน Active Record ที่เรียกใช้ทุกครั้งที่ Active Record ใช้คำสั่ง SQL ในฐานข้อมูล ตัวเก้าอี้นี้สามารถ **สมัครใช้** และใช้เพื่อติดตามจำนวนคำสั่งที่ใช้ในการกระทำบางอย่างได้ เช่น มี [ตัวเก้าอี้อื่น](#process-action-action-controller) รอบการประมวลผลของการกระทำของคอนโทรลเลอร์ สามารถใช้เพื่อติดตามเวลาที่การกระทำเฉพาะนั้นใช้เวลานานเท่าไหร่

คุณยังสามารถ [สร้างเหตุการณ์ที่กำหนดเอง](#creating-custom-events) ภายในแอปพลิเคชันของคุณซึ่งคุณสามารถสมัครใช้งานได้ในภายหลัง

การสมัครใช้งานกับเหตุการณ์
-----------------------

การสมัครใช้งานกับเหตุการณ์เป็นเรื่องง่าย ใช้ [`ActiveSupport::Notifications.subscribe`][] พร้อมกับบล็อกเพื่อฟังการแจ้งเตือนใด ๆ

บล็อกจะได้รับอาร์กิวเมนต์ต่อไปนี้:

* ชื่อเหตุการณ์
* เวลาที่เริ่มต้น
* เวลาที่สิ้นสุด
* รหัสประจำตัวที่ไม่ซ้ำกันสำหรับตัวเครื่องมือที่เปิดเหตุการณ์
* ข้อมูลสำหรับเหตุการณ์

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # สิ่งที่คุณกำหนดเอง
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 2019-05-05 13:43:57 -0800, finished: 2019-05-05 13:43:58 -0800)
end
```

หากคุณกังวลเกี่ยวกับความแม่นยำของ `started` และ `finished` เพื่อคำนวณเวลาที่ใช้ได้อย่างแม่นยำ ให้ใช้ [`ActiveSupport::Notifications.monotonic_subscribe`][] บล็อกที่กำหนดจะได้รับอาร์กิวเมนต์เดียวกันกับข้างต้น แต่ `started` และ `finished` จะมีค่าที่แม่นยำเป็นเวลาโมโนโทนิกแทนเวลานาฬิกาตามผนวก

```ruby
ActiveSupport::Notifications.monotonic_subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # สิ่งที่คุณกำหนดเอง
  Rails.logger.info "#{name} Received! (started: #{started}, finished: #{finished})" # process_action.action_controller Received (started: 1560978.425334, finished: 1560979.429234)
end
```

การกำหนดอาร์กิวเมนต์บล็อกเหล่านั้นทุกครั้งอาจเป็นเรื่องน่าเบื่อ คุณสามารถสร้าง [`ActiveSupport::Notifications::Event`][] จากอาร์กิวเมนต์บล็อกได้อย่างง่ายดายเช่นนี้:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (ในหน่วยมิลลิวินาที)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Received!"
end
```
คุณยังสามารถส่งบล็อกที่ยอมรับอาร์กิวเมนต์เพียงอย่างเดียวและจะได้รับออบเจกต์เหตุการณ์:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |event|
  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (ในหน่วยมิลลิวินาที)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} ได้รับแล้ว!"
end
```

คุณยังสามารถสมัครสมาชิกกับเหตุการณ์ที่ตรงกันกับ regular expression นี้ได้ เพื่อให้คุณสามารถสมัครสมาชิกกับเหตุการณ์หลายอย่างในครั้งเดียว นี่คือวิธีการสมัครสมาชิกกับทุกอย่างจาก `ActionController`:

```ruby
ActiveSupport::Notifications.subscribe(/action_controller/) do |*args|
  # ตรวจสอบเหตุการณ์ ActionController ทั้งหมด
end
```


ดูเวลาการทำงานจากการใช้เครื่องมือในเบราว์เซอร์ของคุณ
-------------------------------------------------

Rails นำเสนอมาตรฐาน [Server Timing](https://www.w3.org/TR/server-timing/) เพื่อทำให้ข้อมูลเวลาทำงานสามารถใช้ได้ในเบราว์เซอร์เว็บ ในการเปิดใช้งาน คุณสามารถแก้ไขการกำหนดค่าสภาพแวดล้อม (โดยปกติคือ `development.rb` เนื่องจากมักจะใช้ในการพัฒนามากที่สุด) เพื่อรวมการกำหนดค่าต่อไปนี้:

```ruby
  config.server_timing = true
```

เมื่อกำหนดค่าแล้ว (รวมถึงการรีสตาร์ทเซิร์ฟเวอร์ของคุณ) คุณสามารถไปที่แถบ Developer Tools ของเบราว์เซอร์ของคุณ จากนั้นเลือกเครือข่ายและโหลดหน้าของคุณอีกครั้ง คุณจะสามารถเลือกคำขอใดคำขอหนึ่งไปยังเซิร์ฟเวอร์ Rails ของคุณและจะเห็นเวลาการทำงานของเซิร์ฟเวอร์ในแท็บเวลา สำหรับตัวอย่างการทำเช่นนี้ ดู[เอกสาร Firefox](https://firefox-source-docs.mozilla.org/devtools-user/network_monitor/request_details/index.html#server-timing) ได้

Hooks ของ Rails Framework
---------------------

ภายในเฟรมเวิร์ก Ruby on Rails มีการให้ hooks หลายอย่างสำหรับเหตุการณ์ที่พบบ่อย เหตุการณ์เหล่านี้และข้อมูลเพิ่มเติมสามารถดูได้ด้านล่าง

### Action Controller

#### `start_processing.action_controller`

| คีย์           | ค่า                                                     |
| ------------- | --------------------------------------------------------- |
| `:controller` | ชื่อคอนโทรลเลอร์                                       |
| `:action`     | แอ็กชัน                                                |
| `:params`     | แฮชของพารามิเตอร์ของคำขอโดยไม่มีพารามิเตอร์ที่ถูกกรอง |
| `:headers`    | ส่วนหัวของคำขอ                                           |
| `:format`     | html/js/json/xml เป็นต้น                                  |
| `:method`     | คำขอ HTTP                                               |
| `:path`       | เส้นทางของคำขอ                                              |

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

| คีย์             | ค่า                                                     |
| --------------- | --------------------------------------------------------- |
| `:controller`   | ชื่อคอนโทรลเลอร์                                       |
| `:action`       | แอ็กชัน                                                |
| `:params`       | แฮชของพารามิเตอร์ของคำขอโดยไม่มีพารามิเตอร์ที่ถูกกรอง |
| `:headers`      | ส่วนหัวของคำขอ                                           |
| `:format`       | html/js/json/xml เป็นต้น                                  |
| `:method`       | คำขอ HTTP                                               |
| `:path`         | เส้นทางของคำขอ                                              |
| `:request`      | ออบเจกต์ [`ActionDispatch::Request`][]                  |
| `:response`     | ออบเจกต์ [`ActionDispatch::Response`][]                 |
| `:status`       | รหัสสถานะ HTTP                                          |
| `:view_runtime` | เวลาที่ใช้ในการแสดงผลในหน่วยมิลลิวินาที                                |
| `:db_runtime`   | เวลาที่ใช้ในการดำเนินการคิวรีฐานข้อมูลในหน่วยมิลลิวินาที             |

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

| คีย์     | ค่า                     |
| ------- | ------------------------- |
| `:path` | เส้นทางสมบูรณ์ไปยังไฟล์ |

คีย์เพิ่มเติมอาจถูกเพิ่มโดยผู้เรียกใช้งาน

#### `send_data.action_controller`

`ActionController` ไม่เพิ่มข้อมูลเฉพาะใดๆเข้าไปใน payload ทั้งหมด ตัวเลือกทั้งหมดจะถูกส่งผ่านไปยัง payload

#### `redirect_to.action_controller`

| คีย์         | ค่า                                    |
| ----------- | ---------------------------------------- |
| `:status`   | รหัสการตอบสนอง HTTP                       |
| `:location` | URL ที่จะเปลี่ยนเส้นทางไปยัง                  |
| `:request`  | ออบเจกต์ [`ActionDispatch::Request`][] |
```ruby
{
  status: 302,
  location: "http://localhost:3000/posts/new",
  request: <ActionDispatch::Request:0x00007ff1cb9bd7b8>
}
```

#### `halted_callback.action_controller`

| คีย์       | ค่า                         |
| --------- | ----------------------------- |
| `:filter` | ตัวกรองที่หยุดการทำงาน |

```ruby
{
  filter: ":halting_filter"
}
```

#### `unpermitted_parameters.action_controller`

| คีย์           | ค่า                                                                         |
| ------------- | ----------------------------------------------------------------------------- |
| `:keys`       | คีย์ที่ไม่ได้รับอนุญาต                                                          |
| `:context`    | แฮชที่มีคีย์ต่อไปนี้: `:controller`, `:action`, `:params`, `:request` |

### Action Controller — Caching

#### `write_fragment.action_controller`

| คีย์    | ค่า            |
| ------ | ---------------- |
| `:key` | คีย์ทั้งหมด |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `read_fragment.action_controller`

| คีย์    | ค่า            |
| ------ | ---------------- |
| `:key` | คีย์ทั้งหมด |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `expire_fragment.action_controller`

| คีย์    | ค่า            |
| ------ | ---------------- |
| `:key` | คีย์ทั้งหมด |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `exist_fragment?.action_controller`

| คีย์    | ค่า            |
| ------ | ---------------- |
| `:key` | คีย์ทั้งหมด |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### Action Dispatch

#### `process_middleware.action_dispatch`

| คีย์           | ค่า                  |
| ------------- | ---------------------- |
| `:middleware` | ชื่อของ middleware |

#### `redirect.action_dispatch`

| คีย์         | ค่า                                    |
| ----------- | ---------------------------------------- |
| `:status`   | รหัสการตอบสนอง HTTP                       |
| `:location` | URL ที่จะเปลี่ยนเส้นทางไปยัง                |
| `:request`  | อ็อบเจกต์ [`ActionDispatch::Request`][] |

#### `request.action_dispatch`

| คีย์         | ค่า                                    |
| ----------- | ---------------------------------------- |
| `:request`  | อ็อบเจกต์ [`ActionDispatch::Request`][] |

### Action View

#### `render_template.action_view`

| คีย์           | ค่า                              |
| ------------- | ---------------------------------- |
| `:identifier` | เส้นทางเต็มไปยังเทมเพลต              |
| `:layout`     | เลเอาท์ที่ใช้ได้                 |
| `:locals`     | ตัวแปรท้องถิ่นที่ส่งไปยังเทมเพลต |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/index.html.erb",
  layout: "layouts/application",
  locals: { foo: "bar" }
}
```

#### `render_partial.action_view`

| คีย์           | ค่า                              |
| ------------- | ---------------------------------- |
| `:identifier` | เส้นทางเต็มไปยังเทมเพลต              |
| `:locals`     | ตัวแปรท้องถิ่นที่ส่งไปยังเทมเพลต |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_form.html.erb",
  locals: { foo: "bar" }
}
```

#### `render_collection.action_view`

| คีย์           | ค่า                                 |
| ------------- | ------------------------------------- |
| `:identifier` | เส้นทางเต็มไปยังเทมเพลต                 |
| `:count`      | ขนาดของคอลเลกชัน                       |
| `:cache_hits` | จำนวนพาร์ทเชียลที่เรียกจากแคช |

คีย์ `:cache_hits` เพิ่มเข้ามาเมื่อคอลเลกชันถูกแสดงผลด้วย `cached: true` เท่านั้น.

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_post.html.erb",
  count: 3,
  cache_hits: 0
}
```

#### `render_layout.action_view`

| คีย์           | ค่า                 |
| ------------- | --------------------- |
| `:identifier` | เส้นทางเต็มไปยังเทมเพลต |


```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/layouts/application.html.erb"
}
```


### Active Record

#### `sql.active_record`

| คีย์                  | ค่า                                    |
| -------------------- | ---------------------------------------- |
| `:sql`               | คำสั่ง SQL                              |
| `:name`              | ชื่อของการดำเนินการ                      |
| `:connection`        | อ็อบเจกต์การเชื่อมต่อ                        |
| `:binds`             | พารามิเตอร์ที่ผูก                           |
| `:type_casted_binds` | พารามิเตอร์ที่ผูกแปลงชนิด                  |
| `:statement_name`    | ชื่อคำสั่ง SQL                         |
| `:cached`            | `true` เพิ่มเข้ามาเมื่อใช้คิวรีแคช |

แอดาปเตอร์อาจเพิ่มข้อมูลของตนเองเข้าไปด้วย
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

เหตุการณ์นี้เกิดขึ้นเมื่อ [`config.active_record.action_on_strict_loading_violation`][] ถูกตั้งค่าเป็น `:log` เท่านั้น

| คีย์           | ค่า                                            |
| ------------- | ------------------------------------------------ |
| `:owner`      | โมเดลที่เปิดใช้งาน `strict_loading`              |
| `:reflection` | Reflection ของความสัมพันธ์ที่พยายามโหลดข้อมูล |


#### `instantiation.active_record`

| คีย์              | ค่า                                     |
| ---------------- | ----------------------------------------- |
| `:record_count`  | จำนวนเรคคอร์ดที่ถูกสร้างขึ้น       |
| `:class_name`    | ชื่อคลาสของเรคคอร์ด                  |

```ruby
{
  record_count: 1,
  class_name: "User"
}
```

### Action Mailer

#### `deliver.action_mailer`

| คีย์                   | ค่า                                                |
| --------------------- | ---------------------------------------------------- |
| `:mailer`             | ชื่อคลาสเมลเลอร์                                   |
| `:message_id`         | ID ของข้อความที่สร้างขึ้นโดย Mail gem             |
| `:subject`            | หัวข้อของอีเมล                                     |
| `:to`                 | ที่อยู่ผู้รับอีเมล                                   |
| `:from`               | ที่อยู่ผู้ส่งอีเมล                                   |
| `:bcc`                | ที่อยู่ผู้รับแบบลับ                                 |
| `:cc`                 | ที่อยู่ผู้รับแบบสำเนา                                 |
| `:date`               | วันที่ของอีเมล                                      |
| `:mail`               | รูปแบบของอีเมลที่ถูกเข้ารหัส                         |
| `:perform_deliveries` | บอกว่าการส่งข้อความนี้ถูกดำเนินการหรือไม่          |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails Guides",
  to: ["users@rails.com", "dhh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "...", # ถูกละเลยเพื่อความกระชับ
  perform_deliveries: true
}
```

#### `process.action_mailer`

| คีย์           | ค่า                    |
| ------------- | ------------------------ |
| `:mailer`     | ชื่อคลาสเมลเลอร์       |
| `:action`     | แอ็กชัน                |
| `:args`       | อาร์กิวเมนต์            |

```ruby
{
  mailer: "Notification",
  action: "welcome_email",
  args: []
}
```

### Active Support — Caching

#### `cache_read.active_support`

| คีย์                | ค่า                   |
| ------------------ | ----------------------- |
| `:key`             | คีย์ที่ใช้ในสโตร์     |
| `:store`           | ชื่อคลาสสโตร์         |
| `:hit`             | ถ้าการอ่านนี้เป็นการตอบรับ |
| `:super_operation` | `:fetch` ถ้าการอ่านทำกับ [`fetch`][ActiveSupport::Cache::Store#fetch] |

#### `cache_read_multi.active_support`

| คีย์                | ค่า                   |
| ------------------ | ----------------------- |
| `:key`             | คีย์ที่ใช้ในสโตร์     |
| `:store`           | ชื่อคลาสสโตร์         |
| `:hits`            | คีย์ของการอ่านที่ตอบรับ |
| `:super_operation` | `:fetch_multi` ถ้าการอ่านทำกับ [`fetch_multi`][ActiveSupport::Cache::Store#fetch_multi] |

#### `cache_generate.active_support`

เหตุการณ์นี้เกิดขึ้นเมื่อ [`fetch`][ActiveSupport::Cache::Store#fetch] ถูกเรียกใช้งานพร้อมกับบล็อก

| คีย์      | ค่า                   |
| -------- | ----------------------- |
| `:key`   | คีย์ที่ใช้ในสโตร์     |
| `:store` | ชื่อคลาสสโตร์         |

ตัวเลือกที่ถูกส่งผ่านไปยัง `fetch` จะถูกผสมกับข้อมูลเมื่อเขียนลงในสโตร์

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_fetch_hit.active_support`

เหตุการณ์นี้เกิดขึ้นเมื่อ [`fetch`][ActiveSupport::Cache::Store#fetch] ถูกเรียกใช้งานพร้อมกับบล็อก

| คีย์      | ค่า                   |
| -------- | ----------------------- |
| `:key`   | คีย์ที่ใช้ในสโตร์     |
| `:store` | ชื่อคลาสสโตร์         |

ตัวเลือกที่ถูกส่งผ่านไปยัง `fetch` จะถูกผสมกับข้อมูล
```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write.active_support`

| คีย์      | ค่า                   |
| -------- | ----------------------- |
| `:key`   | คีย์ที่ใช้ในสโตร์   |
| `:store` | ชื่อคลาสสโตร์ |

สโตร์แคชอาจเพิ่มข้อมูลของตัวเองเข้าไปด้วย

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write_multi.active_support`

| คีย์      | ค่า                                |
| -------- | ------------------------------------ |
| `:key`   | คีย์และค่าที่เขียนลงในสโตร์ |
| `:store` | ชื่อคลาสสโตร์              |


#### `cache_increment.active_support`

เหตุการณ์นี้เกิดขึ้นเฉพาะเมื่อใช้ [`MemCacheStore`][ActiveSupport::Cache::MemCacheStore]
หรือ [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore].

| คีย์       | ค่า                   |
| --------- | ----------------------- |
| `:key`    | คีย์ที่ใช้ในสโตร์   |
| `:store`  | ชื่อคลาสสโตร์ |
| `:amount` | จำนวนการเพิ่มขึ้น        |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 99
}
```

#### `cache_decrement.active_support`

เหตุการณ์นี้เกิดขึ้นเฉพาะเมื่อใช้ Memcached หรือ Redis cache stores.

| คีย์       | ค่า                   |
| --------- | ----------------------- |
| `:key`    | คีย์ที่ใช้ในสโตร์   |
| `:store`  | ชื่อคลาสสโตร์ |
| `:amount` | จำนวนการลดลง        |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 1
}
```

#### `cache_delete.active_support`

| คีย์      | ค่า                   |
| -------- | ----------------------- |
| `:key`   | คีย์ที่ใช้ในสโตร์   |
| `:store` | ชื่อคลาสสโตร์ |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_delete_multi.active_support`

| คีย์      | ค่า                   |
| -------- | ----------------------- |
| `:key`   | คีย์ที่ใช้ในสโตร์   |
| `:store` | ชื่อคลาสสโตร์ |

#### `cache_delete_matched.active_support`

เหตุการณ์นี้เกิดขึ้นเฉพาะเมื่อใช้ [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore],
[`FileStore`][ActiveSupport::Cache::FileStore], หรือ [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| คีย์      | ค่า                   |
| -------- | ----------------------- |
| `:key`   | รูปแบบคีย์ที่ใช้        |
| `:store` | ชื่อคลาสสโตร์ |

```ruby
{
  key: "posts/*",
  store: "ActiveSupport::Cache::RedisCacheStore"
}
```

#### `cache_cleanup.active_support`

เหตุการณ์นี้เกิดขึ้นเฉพาะเมื่อใช้ [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| คีย์      | ค่า                                         |
| -------- | --------------------------------------------- |
| `:store` | ชื่อคลาสสโตร์                       |
| `:size`  | จำนวนรายการในแคชก่อนทำความสะอาด |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  size: 9001
}
```

#### `cache_prune.active_support`

เหตุการณ์นี้เกิดขึ้นเฉพาะเมื่อใช้ [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| คีย์      | ค่า                                         |
| -------- | --------------------------------------------- |
| `:store` | ชื่อคลาสสโตร์                       |
| `:key`   | ขนาดเป้าหมาย (ในไบต์) สำหรับแคช          |
| `:from`  | ขนาด (ในไบต์) ของแคชก่อนการตัดทอน     |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  key: 5000,
  from: 9001
}
```

#### `cache_exist?.active_support`

| คีย์      | ค่า                   |
| -------- | ----------------------- |
| `:key`   | คีย์ที่ใช้ในสโตร์   |
| `:store` | ชื่อคลาสสโตร์ |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```


### Active Support — Messages

#### `message_serializer_fallback.active_support`

| คีย์             | ค่า                         |
| --------------- | ----------------------------- |
| `:serializer`   | ซีเรียลไรเซอร์หลัก (ที่ตั้งใจ) |
| `:fallback`     | ซีเรียลไรเซอร์สำรอง (จริง)  |
| `:serialized`   | สตริงที่ถูกซีเรียลไรซ์     |
| `:deserialized` | ค่าที่ถูกแปลงกลับให้กลับมา |
```ruby
{
  serializer: :json_allow_marshal,
  fallback: :marshal,
  serialized: "\x04\b{\x06I\"\nสวัสดี\x06:\x06ETI\"\nโลก\x06;\x00T",
  deserialized: { "สวัสดี" => "โลก" },
}
```

### Active Job

#### `enqueue_at.active_job`

| คีย์         | ค่า                                    |
| ------------ | -------------------------------------- |
| `:adapter`   | ออบเจ็กต์ QueueAdapter ที่ประมวลผลงาน |
| `:job`       | ออบเจ็กต์งาน                             |

#### `enqueue.active_job`

| คีย์         | ค่า                                    |
| ------------ | -------------------------------------- |
| `:adapter`   | ออบเจ็กต์ QueueAdapter ที่ประมวลผลงาน |
| `:job`       | ออบเจ็กต์งาน                             |

#### `enqueue_retry.active_job`

| คีย์         | ค่า                                    |
| ------------ | -------------------------------------- |
| `:job`       | ออบเจ็กต์งาน                             |
| `:adapter`   | ออบเจ็กต์ QueueAdapter ที่ประมวลผลงาน |
| `:error`     | ข้อผิดพลาดที่ทำให้ต้องลองใหม่                  |
| `:wait`      | ค่าความล่าช้าของการลองใหม่                 |

#### `enqueue_all.active_job`

| คีย์         | ค่า                                    |
| ------------ | -------------------------------------- |
| `:adapter`   | ออบเจ็กต์ QueueAdapter ที่ประมวลผลงาน |
| `:jobs`      | อาร์เรย์ของออบเจ็กต์งาน                      |

#### `perform_start.active_job`

| คีย์         | ค่า                                    |
| ------------ | -------------------------------------- |
| `:adapter`   | ออบเจ็กต์ QueueAdapter ที่ประมวลผลงาน |
| `:job`       | ออบเจ็กต์งาน                             |

#### `perform.active_job`

| คีย์           | ค่า                                         |
| ------------- | --------------------------------------------- |
| `:adapter`    | ออบเจ็กต์ QueueAdapter ที่ประมวลผลงาน        |
| `:job`        | ออบเจ็กต์งาน                             |
| `:db_runtime` | จำนวนเวลาที่ใช้ในการดำเนินการคิวรีฐานข้อมูลในหน่วยเวลา (มิลลิวินาที) |

#### `retry_stopped.active_job`

| คีย์         | ค่า                                    |
| ------------ | -------------------------------------- |
| `:adapter`   | ออบเจ็กต์ QueueAdapter ที่ประมวลผลงาน |
| `:job`       | ออบเจ็กต์งาน                             |
| `:error`     | ข้อผิดพลาดที่ทำให้ต้องลองใหม่                  |

#### `discard.active_job`

| คีย์         | ค่า                                    |
| ------------ | -------------------------------------- |
| `:adapter`   | ออบเจ็กต์ QueueAdapter ที่ประมวลผลงาน |
| `:job`       | ออบเจ็กต์งาน                             |
| `:error`     | ข้อผิดพลาดที่ทำให้ต้องละทิ้ง                  |

### Action Cable

#### `perform_action.action_cable`

| คีย์              | ค่า                     |
| ---------------- | ------------------------- |
| `:channel_class` | ชื่อคลาสช่องสื่อสาร |
| `:action`        | การกระทำ                |
| `:data`          | แฮชของข้อมูล            |

#### `transmit.action_cable`

| คีย์              | ค่า                     |
| ---------------- | ------------------------- |
| `:channel_class` | ชื่อคลาสช่องสื่อสาร |
| `:data`          | แฮชของข้อมูล            |
| `:via`           | ผ่าน                      |

#### `transmit_subscription_confirmation.action_cable`

| คีย์              | ค่า                     |
| ---------------- | ------------------------- |
| `:channel_class` | ชื่อคลาสช่องสื่อสาร |

#### `transmit_subscription_rejection.action_cable`

| คีย์              | ค่า                     |
| ---------------- | ------------------------- |
| `:channel_class` | ชื่อคลาสช่องสื่อสาร |

#### `broadcast.action_cable`

| คีย์             | ค่า                |
| --------------- | -------------------- |
| `:broadcasting` | การกระจายชื่อ      |
| `:message`      | แฮชของข้อความ       |
| `:coder`        | โคเดอร์              |

### Active Storage

#### `preview.active_storage`

| คีย์          | ค่า                |
| ------------ | ------------------- |
| `:key`       | โทเค็นความปลอดภัย |

#### `transform.active_storage`

#### `analyze.active_storage`

| คีย์          | ค่า                          |
| ------------ | ------------------------------ |
| `:analyzer`  | ชื่อตัววิเคราะห์ เช่น ffprobe |

### Active Storage — Storage Service

#### `service_upload.active_storage`

| คีย์          | ค่า                        |
| ------------ | ---------------------------- |
| `:key`       | โทเค็นความปลอดภัย             |
| `:service`   | ชื่อของบริการ              |
| `:checksum`  | เช็คซัมเพื่อให้แน่ใจว่าคงสภาพ |
#### `service_streaming_download.active_storage`

| คีย์          | ค่า               |
| ------------ | ------------------- |
| `:key`       | โทเค็นที่ปลอดภัย        |
| `:service`   | ชื่อบริการ |

#### `service_download_chunk.active_storage`

| คีย์          | ค่า                           |
| ------------ | ------------------------------- |
| `:key`       | โทเค็นที่ปลอดภัย                    |
| `:service`   | ชื่อบริการ             |
| `:range`     | ช่วงไบต์ที่พยายามอ่าน |

#### `service_download.active_storage`

| คีย์          | ค่า               |
| ------------ | ------------------- |
| `:key`       | โทเค็นที่ปลอดภัย        |
| `:service`   | ชื่อบริการ |

#### `service_delete.active_storage`

| คีย์          | ค่า               |
| ------------ | ------------------- |
| `:key`       | โทเค็นที่ปลอดภัย        |
| `:service`   | ชื่อบริการ |

#### `service_delete_prefixed.active_storage`

| คีย์          | ค่า               |
| ------------ | ------------------- |
| `:prefix`    | คำนำหน้าคีย์          |
| `:service`   | ชื่อบริการ |

#### `service_exist.active_storage`

| คีย์          | ค่า                       |
| ------------ | --------------------------- |
| `:key`       | โทเค็นที่ปลอดภัย                |
| `:service`   | ชื่อบริการ         |
| `:exist`     | ไฟล์หรือบล็อบมีหรือไม่มี |

#### `service_url.active_storage`

| คีย์          | ค่า               |
| ------------ | ------------------- |
| `:key`       | โทเค็นที่ปลอดภัย        |
| `:service`   | ชื่อบริการ |
| `:url`       | URL ที่สร้างขึ้น       |

#### `service_update_metadata.active_storage`

เหตุการณ์นี้เกิดขึ้นเฉพาะเมื่อใช้บริการ Google Cloud Storage

| คีย์             | ค่า                            |
| --------------- | -------------------------------- |
| `:key`          | โทเค็นที่ปลอดภัย                     |
| `:service`      | ชื่อบริการ              |
| `:content_type` | ฟิลด์ HTTP `Content-Type`        |
| `:disposition`  | ฟิลด์ HTTP `Content-Disposition` |

### Action Mailbox

#### `process.action_mailbox`

| คีย์              | ค่า                                                  |
| -----------------| ------------------------------------------------------ |
| `:mailbox`       | อินสแตนซ์ของคลาส Mailbox ที่สืบทอดมาจาก [`ActionMailbox::Base`][] |
| `:inbound_email` | แฮชที่มีข้อมูลเกี่ยวกับอีเมลที่เข้ารับการประมวลผล |

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

| คีย์            | ค่า                                               |
| -------------- | --------------------------------------------------- |
| `:initializer` | เส้นทางของไฟล์เริ่มต้นที่โหลดใน `config/initializers` |

### Rails

#### `deprecation.rails`

| คีย์                    | ค่า                                                 |
| ---------------------- | ------------------------------------------------------|
| `:message`             | ข้อความเตือนการเลิกใช้งาน                               |
| `:callstack`           | ตำแหน่งที่เกิดการเลิกใช้งาน                        |
| `:gem_name`            | ชื่อเจ็มที่รายงานการเลิกใช้งาน                          |
| `:deprecation_horizon` | เวอร์ชันที่พฤติกรรมที่เลิกใช้งานจะถูกลบออก |

ข้อยกเว้น
----------

หากเกิดข้อยกเว้นขึ้นในระหว่างการใช้งานเครื่องมือวัด ข้อมูลในเครื่องมือวัดจะรวมข้อมูลเกี่ยวกับข้อยกเว้นด้วย

| คีย์                 | ค่า                                                          |
| ------------------- | -------------------------------------------------------------- |
| `:exception`        | อาร์เรย์ที่มีสองสมาชิก ชื่อคลาสของข้อยกเว้นและข้อความ |
| `:exception_object` | ออบเจกต์ข้อยกเว้น                                           |

สร้างเหตุการณ์ที่กำหนดเอง
----------------------

การเพิ่มเหตุการณ์ที่กำหนดเองง่ายเช่นกัน  Active Support จะดูแลการทำงานหนักให้คุณ คุณเพียงแค่เรียกใช้ [`ActiveSupport::Notifications.instrument`][] พร้อมกับ `name`, `payload`, และบล็อก การแจ้งเตือนจะถูกส่งหลังจากที่บล็อกสิ้นสุดลง  Active Support จะสร้างเวลาเริ่มต้นและเวลาสิ้นสุด และเพิ่ม ID ของเครื่องมือวัดที่ไม่ซ้ำกัน ข้อมูลทั้งหมดที่ส่งเข้าไปในการเรียกใช้ `instrument` จะถูกส่งไปยังเครื่องมือวัด
นี่คือตัวอย่าง:

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data do
  # ทำสิ่งที่คุณต้องการทำที่นี่
end
```

ตอนนี้คุณสามารถฟังก์ชันเหตุการณ์นี้ได้ด้วย:

```ruby
ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

คุณยังสามารถเรียกใช้ `instrument` โดยไม่ต้องส่งบล็อกได้เช่นกัน ซึ่งจะช่วยให้คุณใช้โครงสร้างการใช้เครื่องมือสื่อสารอื่นได้

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data

ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

คุณควรปฏิบัติตามคำแนะนำของ Rails เมื่อกำหนดเหตุการณ์ของคุณเอง รูปแบบคือ: `event.library` ถ้าแอปพลิเคชันของคุณกำลังส่งทวีต คุณควรสร้างเหตุการณ์ที่ชื่อว่า `tweet.twitter`
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
