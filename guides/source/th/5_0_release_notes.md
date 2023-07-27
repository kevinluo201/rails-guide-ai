**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: df23e2b31bd56973a30f38f5a1c29b52
บันทึกการเปลี่ยนแปลงใน Rails 5.0
===============================

จุดเด่นใน Rails 5.0:

* Action Cable
* Rails API
* Active Record Attributes API
* Test Runner
* ใช้เฉพาะ `rails` CLI แทน Rake
* Sprockets 3
* Turbolinks 5
* ต้องใช้ Ruby 2.2.2+ เป็นขั้นต่ำ

บันทึกการเปลี่ยนแปลงเหล่านี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่าง ๆ โปรดอ้างอิงที่ changelogs หรือตรวจสอบ [รายการของ commits](https://github.com/rails/rails/commits/5-0-stable) ในเครื่องมือ Rails หลักใน GitHub.

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 5.0
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 4.2 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 5.0 มีรายการสิ่งที่ควรระมัดระวังเมื่ออัปเกรดใน
[การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0)
คู่มือ


คุณสมบัติหลัก
--------------

### Action Cable

Action Cable เป็นเฟรมเวิร์กใหม่ใน Rails 5.0 มันรวม [WebSockets](https://en.wikipedia.org/wiki/WebSocket) ไปกับแอปพลิเคชัน Rails ของคุณอย่างไม่มีช่องว่าง

Action Cable ช่วยให้สามารถเขียนคุณสมบัติแบบ real-time ในภาษา Ruby ในรูปแบบและรูปแบบเดียวกับส่วนอื่น ๆ ของแอปพลิเคชัน Rails ของคุณ ในขณะที่ยังคงมีประสิทธิภาพและมีความสามารถในการขยายขนาด มันเป็นเฟรมเวิร์กแบบ full-stack ที่ให้เฟรมเวิร์ก JavaScript ด้านไคลเอนต์และเฟรมเวิร์ก Ruby ด้านเซิร์ฟเวอร์ คุณสามารถเข้าถึงโมเดลโดเมนทั้งหมดของคุณที่เขียนด้วย Active Record หรือ ORM ที่คุณเลือก

ดูเพิ่มเติมที่ [Action Cable Overview](action_cable_overview.html) คู่มือสำหรับข้อมูลเพิ่มเติม

### แอปพลิเคชัน API

Rails สามารถใช้สร้างแอปพลิเคชัน API ที่มีขนาดเล็กลงได้แล้ว นี่เป็นประโยชน์ในการสร้างและให้บริการ API ที่คล้ายกับ [Twitter](https://dev.twitter.com) หรือ [GitHub](https://developer.github.com) API ซึ่งสามารถใช้บริการสำหรับสาธารณะและสำหรับแอปพลิเคชันที่กำหนดเองได้

คุณสามารถสร้างแอป Rails แบบ api ใหม่โดยใช้คำสั่ง:

```bash
$ rails new my_api --api
```

สิ่งที่คำสั่งนี้ทำคือสามสิ่งหลัก:

- กำหนดค่าแอปพลิเคชันของคุณให้เริ่มต้นด้วยชุด middleware ที่จำกัดมากกว่าปกติ โดยเฉพาะอย่างยิ่ง มันจะไม่รวม middleware ที่มีประโยชน์โดยส่วนใหญ่สำหรับแอปพลิเคชันเบราว์เซอร์ (เช่นการสนับสนุนคุกกี้) เป็นค่าเริ่มต้น
- ทำให้ `ApplicationController` สืบทอดจาก `ActionController::API` แทนที่จะสืบทอดจาก `ActionController::Base` อย่างเดียว อย่างเช่นกับ middleware นี้จะไม่รวม Action Controller modules ที่ให้ความสามารถที่ใช้โดยส่วนใหญ่สำหรับแอปพลิเคชันเบราว์เซอร์
- กำหนดค่า generators เพื่อข้ามการสร้าง views, helpers, และ assets เมื่อคุณสร้างทรัพยากรใหม่

แอปพลิเคชันจะให้ฐานสำหรับ API ซึ่งจากนั้นสามารถ [กำหนดค่าให้ดึงฟังก์ชัน](api_app.html) ตามความเหมาะสมกับความต้องการของแอปพลิเคชัน

ดูเพิ่มเติมที่ [Using Rails for API-only Applications](api_app.html) คู่มือสำหรับข้อมูลเพิ่มเติม

### Active Record attributes API

กำหนดคุณสมบัติที่มีประเภทบนโมเดล จะแทนที่ประเภทของแอตทริบิวต์ที่มีอยู่หากจำเป็น
สิ่งนี้ช่วยควบคุมวิธีการแปลงค่าเป็นและจาก SQL เมื่อกำหนดให้กับโมเดล
มันยังเปลี่ยนพฤติกรรมของค่าที่ส่งผ่านไปยัง `ActiveRecord::Base.where` ซึ่งช่วยให้เราใช้วัตถุโดเมนของเราได้ใน Active Record ได้มากขึ้นโดยไม่ต้องพึ่งพารายละเอียดของการดำเนินการหรือการแก้ไขโค้ด

บางสิ่งที่คุณสามารถทำได้ด้วยสิ่งนี้:

- สามารถแทนที่ประเภทที่ Active Record ตรวจพบได้
- สามารถกำหนดค่าเริ่มต้นได้เช่นกัน
- แอตทริบิวต์ไม่จำเป็นต้องมีคอลัมน์ในฐานข้อมูล

```ruby
# db/schema.rb
create_table :store_listings, force: true do |t|
  t.decimal :price_in_cents
  t.string :my_string, default: "original default"
end
```

```ruby
# app/models/store_listing.rb
class StoreListing < ActiveRecord::Base
end
```

```ruby
store_listing = StoreListing.new(price_in_cents: '10.1')

# ก่อน
store_listing.price_in_cents # => BigDecimal.new(10.1)
StoreListing.new.my_string # => "original default"

class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer # ประเภทที่กำหนดเอง
  attribute :my_string, :string, default: "new default" # ค่าเริ่มต้น
  attribute :my_default_proc, :datetime, default: -> { Time.now } # ค่าเริ่มต้น
  attribute :field_without_db_column, :integer, array: true
end

# หลังจาก
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes # => {field_without_db_column: [1, 2, 3]}
```
**การสร้างประเภทที่กำหนดเอง:**

คุณสามารถกำหนดประเภทที่กำหนดเองได้ตามที่ต้องการ โดยที่ประเภทเหล่านั้นต้องตอบสนองต่อเมธอดที่กำหนดไว้ในประเภทของค่า มีการเรียกใช้เมธอด `deserialize` หรือ `cast` บนออบเจกต์ประเภทของคุณ โดยมีข้อมูลเข้ารหัสจากฐานข้อมูลหรือจากคอนโทรลเลอร์ของคุณ นี่เป็นประโยชน์ เช่น เมื่อทำการแปลงแบบกำหนดเอง เช่น ข้อมูลเงิน

**การค้นหา:**

เมื่อเรียกใช้ `ActiveRecord::Base.where` จะใช้ประเภทที่กำหนดโดยคลาสโมเดลในการแปลงค่าเป็น SQL โดยเรียกใช้เมธอด `serialize` บนออบเจกต์ประเภทของคุณ

นี้จะให้วัตถุสามารถระบุได้ว่าจะแปลงค่าอย่างไรเมื่อทำการค้นหา SQL

**การตรวจสอบการเปลี่ยนแปลง:**

ประเภทของแอตทริบิวต์สามารถเปลี่ยนวิธีการตรวจสอบการติดตามการเปลี่ยนแปลงได้

ดูเอกสารเพิ่มเติมได้ที่
[เอกสาร](https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html)
สำหรับข้อมูลเพิ่มเติม


### เครื่องมือการทดสอบ

มีการเพิ่มเครื่องมือการทดสอบใหม่เพื่อเพิ่มความสามารถในการเรียกใช้งานการทดสอบจาก Rails
ในการใช้เครื่องมือการทดสอบนี้เพียงพิมพ์ `bin/rails test` เท่านั้น

เครื่องมือการทดสอบนี้ได้รับแรงบันดาลใจมาจาก `RSpec`, `minitest-reporters`, `maxitest` และอื่น ๆ
มีการพัฒนาขึ้นมาเพื่อให้ได้รับประโยชน์จากสิ่งเหล่านี้:

- รันเทสเดียวโดยใช้หมายเลขบรรทัดของเทส
- รันเทสหลายๆ เทสโดยระบุหมายเลขบรรทัดของเทส
- ข้อความแสดงข้อผิดพลาดที่ดีขึ้น ซึ่งยังช่วยให้รันเทสที่ล้มเหลวอีกครั้งได้ง่ายขึ้น
- ระบบหยุดการทดสอบทันทีเมื่อเกิดข้อผิดพลาด โดยใช้ตัวเลือก `-f` เพื่อหยุดการทดสอบทันทีเมื่อเกิดข้อผิดพลาด
แทนที่จะรอให้ชุดทดสอบเสร็จสมบูรณ์
- การเลื่อนการแสดงผลของเทสจนกว่าการรันเทสทั้งหมดจะเสร็จสมบูรณ์โดยใช้ตัวเลือก `-d`
- การแสดงผลข้อผิดพลาดทั้งหมดของข้อยกเว้นโดยใช้ตัวเลือก `-b`
- การผสานร่วมกับ minitest เพื่อให้สามารถใช้ตัวเลือกเช่น `-s` เพื่อให้ได้ข้อมูลเมล็ดพันธุ์ทดสอบ
`-n` เพื่อรันเทสที่ระบุชื่อ  `-v` เพื่อแสดงผลลัพธ์อย่างละเอียดมากขึ้น และอื่น ๆ
- การแสดงผลของเทสที่มีสี

Railties
--------

โปรดอ้างอิงที่ [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการสนับสนุนตัวตรวจสอบข้อผิดพลาด ให้ใช้ byebug แทน  `debugger` ไม่รองรับโดย
    Ruby
    2.2. ([commit](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))

*   ลบงาน `test:all` และ `test:all:db` ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   ลบ `Rails::Rack::LogTailer` ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   ลบค่าคงที่ `RAILS_CACHE` ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   ลบการกำหนดค่า `serve_static_assets` ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   ลบงานเอกสาร `doc:app`, `doc:rails`, และ `doc:guides` ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   ลบ middleware `Rack::ContentLength` ออกจากสแต็กเริ่มต้น
    ([Commit](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### การเลิกใช้งาน

*   เลิกใช้งาน `config.static_cache_control` และใช้ `config.public_file_server.headers` แทน
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   เลิกใช้งาน `config.serve_static_files` และใช้ `config.public_file_server.enabled` แทน
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*   เลิกใช้งานงานในเนมสเปซงาน `rails` และใช้งานเนมสเปซงาน `app` แทน
    (เช่น `rails:update` และ `rails:template` ถูกเปลี่ยนชื่อเป็น `app:update` และ `app:template`)
    ([Pull Request](https://github.com/rails/rails/pull/23439))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มเครื่องมือการทดสอบ Rails `bin/rails test`
    ([Pull Request](https://github.com/rails/rails/pull/19216))

*   แอปพลิเคชันและปลั๊กอินท
*   ปิดการโหลดคลาสอัตโนมัติในสภาพแวดล้อมการใช้งานจริง
    ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

Action Pack
-----------

โปรดอ้างอิง [Changelog][action-pack] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `ActionDispatch::Request::Utils.deep_munge`.
    ([commit](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   ลบ `ActionController::HideActions`.
    ([Pull Request](https://github.com/rails/rails/pull/18371))

*   ลบเมธอดตัวอย่าง `respond_to` และ `respond_with`, ฟังก์ชันนี้ถูกแยกออกเป็น
    [responders](https://github.com/plataformatec/responders) gem.
    ([commit](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   ลบไฟล์การตรวจสอบที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   ลบการใช้งานที่ถูกยกเลิกของคีย์สตริงใน URL helpers
    ([commit](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   ลบตัวเลือก `only_path` ที่ถูกยกเลิกใน `*_path` helpers
    ([commit](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))

*   ลบ `NamedRouteCollection#helpers` ที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*   ลบการสนับสนุนที่ถูกยกเลิกในการกำหนดเส้นทางด้วยตัวเลือก `:to` ที่ไม่มี `#`
    ([commit](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   ลบ `ActionDispatch::Response#to_ary` ที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   ลบ `ActionDispatch::Request#deep_munge` ที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   ลบ `ActionDispatch::Http::Parameters#symbolized_path_parameters` ที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   ลบตัวเลือก `use_route` ที่ถูกยกเลิกในการทดสอบคอนโทรลเลอร์
    ([commit](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   ลบ `assigns` และ `assert_template` ทั้งสองเมธอดถูกแยกออกเป็น
    [rails-controller-testing](https://github.com/rails/rails-controller-testing)
    gem.
    ([Pull Request](https://github.com/rails/rails/pull/20138))

### การเลิกใช้

*   เลิกใช้งานทั้งหมดของ `*_filter` callbacks และใช้งานแทนด้วย `*_action` callbacks
    ([Pull Request](https://github.com/rails/rails/pull/18410))

*   เลิกใช้งานเมธอด `*_via_redirect` ในการทดสอบการผสานรวม ใช้ `follow_redirect!`
    ด้วยตนเองหลังจากการเรียกของคำขอเพื่อให้ได้ผลลัพธ์เดียวกัน
    ([Pull Request](https://github.com/rails/rails/pull/18693))

*   เลิกใช้งาน `AbstractController#skip_action_callback` และใช้งานแทนด้วย
    skip_callback methods แต่ละตัว
    ([Pull Request](https://github.com/rails/rails/pull/19060))

*   เลิกใช้งานตัวเลือก `:nothing` สำหรับเมธอด `render`
    ([Pull Request](https://github.com/rails/rails/pull/20336))

*   เลิกใช้งานการส่งพารามิเตอร์แบบ `Hash` และสถานะเริ่มต้นสำหรับเมธอด `head`
    ([Pull Request](https://github.com/rails/rails/pull/20407))

*   เลิกใช้งานการใช้ชื่อคลาส middleware ด้วยสตริงหรือสัญลักษณ์ ใช้ชื่อคลาสแทน
    ([commit](https://github.com/rails/rails/commit/83b767ce))

*   เลิกใช้งานการเข้าถึงชนิด MIME ผ่านค่าคงที่ (เช่น `Mime::HTML`) ใช้ตัวดัชนีด้วยสัญลักษณ์แทน (เช่น `Mime[:html]`)
    ([Pull Request](https://github.com/rails/rails/p
*   แนะนำ `Response#strong_etag=` และ `#weak_etag=` และตัวเลือกที่คล้ายกันสำหรับ `fresh_when` และ `stale?`.
    ([Pull Request](https://github.com/rails/rails/pull/24387))

Action View
-------------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `AbstractController::Base::parent_prefixes` ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

*   ลบ `ActionView::Helpers::RecordTagHelper` ฟังก์ชันนี้ถูกแยกออกเป็น
    [record_tag_helper](https://github.com/rails/record_tag_helper) gem
    ([Pull Request](https://github.com/rails/rails/pull/18411))

*   ลบตัวเลือก `:rescue_format` สำหรับ `translate` helper เนื่องจากไม่ได้รับการสนับสนุนจาก I18n อีกต่อไป
    ([Pull Request](https://github.com/rails/rails/pull/20019))

### การเปลี่ยนแปลงที่สำคัญ

*   เปลี่ยน template handler เริ่มต้นจาก `ERB` เป็น `Raw`
    ([commit](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

*   การเรียกใช้ partial สามารถแคชและเรียก partial หลายๆ ตัวพร้อมกันได้
    ([Pull Request](https://github.com/rails/rails/pull/18948),
    [commit](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

*   เพิ่มการจับคู่ wildcard ใน dependencies ที่ระบุโดยชัดแจ้ง
    ([Pull Request](https://github.com/rails/rails/pull/20904))

*   ทำให้ `disable_with` เป็นพฤติกรรมเริ่มต้นสำหรับ submit tags ปิดใช้งานปุ่มเมื่อส่งฟอร์มเพื่อป้องกันการส่งซ้ำ
    ([Pull Request](https://github.com/rails/rails/pull/21135))

*   ชื่อ partial template ไม่จำเป็นต้องเป็นตัวระบุ Ruby ที่ถูกต้องอีกต่อไป
    ([commit](https://github.com/rails/rails/commit/da9038e))

*   `datetime_tag` helper ตอนนี้สร้าง input tag ด้วย type เป็น `datetime-local`
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   อนุญาตให้ใช้ blocks ในขณะที่ render ด้วย `render partial:` helper
    ([Pull Request](https://github.com/rails/rails/pull/17974))

Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog][action-mailer] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `*_path` helpers ที่ถูกยกเลิกใน email views
    ([commit](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

*   ลบ `deliver` และ `deliver!` methods ที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### การเปลี่ยนแปลงที่สำคัญ

*   Template lookup ตอนนี้ใช้ default locale และ I18n fallbacks
    ([commit](https://github.com/rails/rails/commit/ecb1981b))

*   เพิ่ม `_mailer` suffix ให้กับ mailers ที่สร้างผ่าน generator ตามหลักการตั้งชื่อเดียวกับ controllers และ jobs
    ([Pull Request](https://github.com/rails/rails/pull/18074))

*   เพิ่ม `assert_enqueued_emails` และ `assert_no_enqueued_emails`
    ([Pull Request](https://github.com/rails/rails/pull/18403))

*   เพิ่มการกำหนดค่า `config.action_mailer.deliver_later_queue_name` เพื่อตั้งค่าชื่อคิวของ mailer
    ([Pull Request](https://github.com/rails/rails/pull/18587))

*   เพิ่มการสนับสนุน fragment caching ใน Action Mailer views
    เพิ่มตัวเลือกการกำหนดค่าใหม่ `config.action_mailer.perform_caching` เพื่อกำหนดว่า template ควรทำ caching หรือไม่
    ([Pull Request](https://github.com/rails/rails/pull/22825))


Active Record
-------------

โปรดอ้างอิงที่ [Changelog][active-record] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบพฤติกรรมที่ถูกยกเลิกในการอนุญาตให้ nested arrays ถูกส่งผ่านเป็น query values
    ([Pull Request](https://github.com/rails/rails/pull/17919))

*   ลบ `ActiveRecord::Tasks::DatabaseTasks#load_schema` ที่ถูกยกเลิกแล้ว วิธีนี้ถูกแทนที่ด้วย `ActiveRecord::Tasks::DatabaseTasks#load_schema_for`
    ([commit](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))

*   ลบ `serialized_attributes` ที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*  
*   ยกเลิกการใช้งาน `connection.tables` บน SQLite3 และ MySQL adapters.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   ยกเลิกการส่งอาร์กิวเมนต์ไปยัง `#tables` - เมธอด `#tables` บางตัวของ adapters (mysql2, sqlite3) จะส่งคืนตารางและวิวในขณะที่อื่น ๆ (postgresql) จะส่งคืนเฉพาะตารางเท่านั้น ในอนาคต `#tables` จะส่งคืนเฉพาะตารางเท่านั้นเพื่อให้พฤติกรรมของพวกเขาสอดคล้องกัน
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   ยกเลิกการใช้งาน `table_exists?` - เมธอด `#table_exists?` จะตรวจสอบทั้งตารางและวิว ในอนาคต `#table_exists?` จะตรวจสอบเฉพาะตารางเท่านั้นเพื่อให้พฤติกรรมของพวกเขาสอดคล้องกันกับ `#tables`
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   ยกเลิกการส่งอาร์กิวเมนต์ `offset` ไปยัง `find_nth` โปรดใช้เมธอด `offset` บน relation แทน
    ([Pull Request](https://github.com/rails/rails/pull/22053))

*   ยกเลิก `{insert|update|delete}_sql` ใน `DatabaseStatements` โปรดใช้เมธอด `{insert|update|delete}` สาธารณะแทน
    ([Pull Request](https://github.com/rails/rails/pull/23086))

*   ยกเลิก `use_transactional_fixtures` เพื่อเปลี่ยนเป็น `use_transactional_tests` เพื่อความชัดเจนมากขึ้น
    ([Pull Request](https://github.com/rails/rails/pull/19282))

*   ยกเลิกการส่งคอลัมน์ไปยัง `ActiveRecord::Connection#quote`
    ([commit](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

*   เพิ่มตัวเลือก `end` ให้กับ `find_in_batches` เพื่อระบุที่จะหยุดการประมวลผลแบทช์
    ([Pull Request](https://github.com/rails/rails/pull/12257))


### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มตัวเลือก `foreign_key` ให้กับ `references` เมื่อสร้างตาราง
    ([commit](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

*   เพิ่ม attributes API
    ([commit](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

*   เพิ่มตัวเลือก `:_prefix`/`:_suffix` ให้กับการกำหนด `enum`
    ([Pull Request](https://github.com/rails/rails/pull/19813),
     [Pull Request](https://github.com/rails/rails/pull/20999))

*   เพิ่ม `#cache_key` ให้กับ `ActiveRecord::Relation`
    ([Pull Request](https://github.com/rails/rails/pull/20884))

*   เปลี่ยนค่า `null` เริ่มต้นของ `timestamps` เป็น `false`
    ([commit](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

*   เพิ่ม `ActiveRecord::SecureToken` เพื่อแยกการสร้างโทเค็นที่ไม่ซ้ำกันสำหรับแอตทริบิวต์ในโมเดลโดยใช้ `SecureRandom`
    ([Pull Request](https://github.com/rails/rails/pull/18217))

*   เพิ่มตัวเลือก `:if_exists` ให้กับ `drop_table`
    ([Pull Request](https://github.com/rails/rails/pull/18597))

*   เพิ่ม `ActiveRecord::Base#accessed_fields` ซึ่งสามารถใช้ค้นพบฟิลด์ที่ถูกอ่านจากโมเดลเมื่อคุณต้องการเลือกข้อมูลที่คุณต้องการจากฐานข้อมูล
    ([commit](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

*   เพิ่มเมธอด `#or` ใน `ActiveRecord::Relation` เพื่ออนุญาตให้ใช้ตัวดำเนินการ OR เพื่อรวม WHERE หรือ HAVING clauses
    ([commit](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

*   เพิ่ม `ActiveRecord::Base.suppress` เพื่อป้องกันการบันทึกผู้รับรองในระหว่างการทำงานของบล็อกที่กำหนด
    ([Pull Request](https://github.com/rails/rails/pull/18910))

*   `belongs_to` ตอนนี้จะเรียกใช้ข้อผิดพลาดการตรวจสอบตามค่าเริ่มต้นหากไม่มีการเชื่อมโยง คุณสามารถปิดการใช้งานนี้ได้ตามการเชื่อมโยงแต่ละตัวด้วย `optional: true` ยังยกเลิก `required` option เพื่อใช้ `optional` แทนสำหรับ `belongs_to`
    ([Pull Request](https://github.com/rails/rails/pull/18937))

*   เพิ่ม `config.active_record.dump_schemas` เพื่อกำหนดพฤติกรรมของ `db:structure:dump`
    ([Pull Request](https://github.com/rails/rails/pull/19347))

*   เพิ่มตัวเลือก `config.active_record.warn_on_records_fetched_greater_than`
    ([Pull Request](https://github.com/rails/rails/pull/18846))

*   เพิ่มการสนับสนุนชนิดข้อมูล JSON ใน MySQL
    ([Pull Request](https://github.com/rails/rails/pull/21110))

*   เพิ่มการสนับสนุนการลบดัชนีพร้อมกันใน PostgreSQL
    ([Pull Request](https://github.com/rails/rails/pull/21317))

*   เพิ่มเมธอด `#views` และ `#view_exists?` ใน connection adapters
    ([Pull Request](https://github.com/rails/rails/pull/21609))

*   เพิ่ม `ActiveRecord::Base.ignored_columns` เพื่อทำให้บางคอลัมน์มองไม่เห็นจาก Active Record
    ([Pull Request](https://github.com/rails/rails/pull/21720))

*   เพิ่ม `connection.data_sources` และ `connection.data_source_exists?` เมธอดเหล่านี้จะกำหนดว่าสามารถใช้ relation ใดในการสร้าง Active Record models (โดย通常จะเป็นตารางและวิว)
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   อนุญา
* เพิ่ม `:touch` option ในเมธอด `save` เพื่อให้สามารถบันทึกเรคคอร์ดโดยไม่ต้องอัปเดต timestamp
    ([Pull Request](https://github.com/rails/rails/pull/18225))

* เพิ่มการสนับสนุน expression indexes และ operator classes สำหรับ PostgreSQL
    ([commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))

* เพิ่ม `:index_errors` option เพื่อเพิ่มดัชนีในข้อผิดพลาดของ nested attributes
    ([Pull Request](https://github.com/rails/rails/pull/19686))

* เพิ่มการสนับสนุนการลบทิศทางสองทิศทาง
    ([Pull Request](https://github.com/rails/rails/pull/18548))

* เพิ่มการสนับสนุน `after_commit` callbacks ในการทดสอบที่มีการทำธุรกรรม
    ([Pull Request](https://github.com/rails/rails/pull/18458))

* เพิ่มเมธอด `foreign_key_exists?` เพื่อตรวจสอบว่ามี foreign key อยู่ในตารางหรือไม่
    ([Pull Request](https://github.com/rails/rails/pull/18662))

* เพิ่ม `:time` option ในเมธอด `touch` เพื่อสัมผัสเรคคอร์ดด้วยเวลาที่แตกต่างจากเวลาปัจจุบัน
    ([Pull Request](https://github.com/rails/rails/pull/18956))

* เปลี่ยน transaction callbacks เพื่อไม่จับข้อผิดพลาด
    ก่อนการเปลี่ยนแปลงนี้ ข้อผิดพลาดใด ๆ ที่เกิดขึ้นภายใน transaction callback
    จะถูกบันทึกและแสดงในบันทึก ยกเว้นถ้าคุณใช้
    `raise_in_transactional_callbacks = true` option (ที่ถูกยกเลิกใช้งานใหม่)
    
    ตอนนี้ข้อผิดพลาดเหล่านี้จะไม่ถูกบันทึกและเพียงแค่แผ่ขึ้นเหมือนกับ callback อื่น ๆ
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

* ลบ `ActiveModel::Dirty#reset_#{attribute}` และ `ActiveModel::Dirty#reset_changes` ที่ถูกยกเลิกใช้งาน
    ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

* ลบการซีเรียลไซซ์ XML คุณลักษณะนี้ถูกแยกออกเป็น
    [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) gem
    ([Pull Request](https://github.com/rails/rails/pull/21161))

* ลบโมดูล `ActionController::ModelNaming`
    ([Pull Request](https://github.com/rails/rails/pull/18194))

### การเลิกใช้งาน

* เลิกใช้การส่งคืน `false` เป็นวิธีหยุด Active Model และ `ActiveModel::Validations` callback chains แนะนำให้ใช้ `throw(:abort)` แทน
    ([Pull Request](https://github.com/rails/rails/pull/17227))

* เลิกใช้ `ActiveModel::Errors#get`, `ActiveModel::Errors#set` และ `ActiveModel::Errors#[]=` methods ที่มีพฤติกรรมไม่สม่ำเสมอ
    ([Pull Request](https://github.com/rails/rails/pull/18634))

* เลิกใช้ `:tokenizer` option สำหรับ `validates_length_of` เพื่อใช้ Ruby ธรรมดาแทน
    ([Pull Request](https://github.com/rails/rails/pull/19585))

* เลิกใช้ `ActiveModel::Errors#add_on_empty` และ `ActiveModel::Errors#add_on_blank` โดยไม่มีการแทนที่
    ([Pull Request](https://github.com/rails/rails/pull/18996))

### การเปลี่ยนแปลงที่สำคัญ

* เพิ่ม `ActiveModel::Errors#details` เพื่อกำหนดว่า validator ไหนที่ล้มเหลว
    ([Pull Request](https://github.com/rails/rails/pull/18322))

* แยก `ActiveRecord::AttributeAssignment` เป็น `ActiveModel::AttributeAssignment`
    อนุญาตให้ใช้สำหรับวัตถุใด ๆ เป็นโมดูลที่สามารถรวมได้
    ([Pull Request](https://github.com/rails/rails/pull/10776))

* เพิ่ม `ActiveModel::Dirty#[attr_name]_previously_changed?` และ
    `ActiveModel::Dirty#[attr_name]_previous_change` เพื่อเข้าถึงการเปลี่ยนแปลงที่บันทึกไว้หลังจากบันทึกโมเดลแล้ว
    ([Pull Request](https://github.com/rails/rails/pull/19847))

* ตรวจสอบ multiple contexts ใน `valid?` และ `invalid?` พร้อมกัน
    ([Pull Request](https://github.com/rails/rails/pull/21069))

* เปลี่ยน `validates_acceptance_of` เพื่อยอมรับค่าเริ่มต้นเป็น `true` นอกเหนือจาก `1`
    ([Pull Request](https://github.com/rails/rails/pull/18439))

Active Job
-----------

โปรดอ้างอิงที่ [Changelog][active-job] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

* `ActiveJob::Base.deserialize` ส่งงานไปยังคลาสงาน นี้ช่วยให้งานสามารถแนบ metadata อย่างอิสระเมื่อถูกซีเรียลไซซ์และอ่านกลับเมื่อถูกดำเนินการ
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*
*   ยกเลิกการใช้งาน `Module#qualified_const_` และใช้ `Module#const_` แทน
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*   ยกเลิกการส่งสตริงในการกำหนด callback
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*   ยกเลิกการใช้งาน `ActiveSupport::Cache::Store#namespaced_key`,
    `ActiveSupport::Cache::MemCachedStore#escape_key`, และ
    `ActiveSupport::Cache::FileStore#key_file_path`
    ใช้ `normalize_key` แทน
    ([Pull Request](https://github.com/rails/rails/pull/22215),
     [commit](https://github.com/rails/rails/commit/a8f773b0))

*   ยกเลิกการใช้งาน `ActiveSupport::Cache::LocaleCache#set_cache_value` และใช้ `write_cache_value` แทน
    ([Pull Request](https://github.com/rails/rails/pull/22215))

*   ยกเลิกการส่งอาร์กิวเมนต์ให้กับ `assert_nothing_raised`
    ([Pull Request](https://github.com/rails/rails/pull/23789))

*   ยกเลิกการใช้งาน `Module.local_constants` และใช้ `Module.constants(false)` แทน
    ([Pull Request](https://github.com/rails/rails/pull/23936))


### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม `#verified` และ `#valid_message?` methods ใน `ActiveSupport::MessageVerifier`
    ([Pull Request](https://github.com/rails/rails/pull/17727))

*   เปลี่ยนวิธีการหยุด callback chains โดยการใช้ `throw(:abort)` แทน
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   เพิ่มตัวเลือกใหม่ `config.active_support.halt_callback_chains_on_return_false` เพื่อระบุว่า
    ActiveRecord, ActiveModel, และ ActiveModel::Validations callback chains
    สามารถหยุดได้โดยการ return `false` ใน 'before' callback
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   เปลี่ยนการเรียงลำดับทดสอบเริ่มต้นจาก `:sorted` เป็น `:random`
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

*   เพิ่ม `#on_weekend?`, `#on_weekday?`, `#next_weekday`, `#prev_weekday` methods ใน `Date`,
    `Time`, และ `DateTime`
    ([Pull Request](https://github.com/rails/rails/pull/18335),
     [Pull Request](https://github.com/rails/rails/pull/23687))

*   เพิ่มตัวเลือก `same_time` ใน `#next_week` และ `#prev_week` สำหรับ `Date`, `Time`,
    และ `DateTime`
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   เพิ่ม `#prev_day` และ `#next_day` เป็นคู่กับ `#yesterday` และ
    `#tomorrow` สำหรับ `Date`, `Time`, และ `DateTime`
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   เพิ่ม `SecureRandom.base58` เพื่อสร้างสตริง base58 แบบสุ่ม
    ([commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b))

*   เพิ่ม `file_fixture` ใน `ActiveSupport::TestCase`
    เพื่อให้สามารถเข้าถึงไฟล์ตัวอย่างในกรณีทดสอบได้ง่าย
    ([Pull Request](https://github.com/rails/rails/pull/18658))

*   เพิ่ม `#without` ใน `Enumerable` และ `Array` เพื่อคืนค่าสำเนาของ enumerable โดยไม่รวมสมาชิกที่ระบุ
    ([Pull Request](https://github.com/rails/rails/pull/19157))

*   เพิ่ม `ActiveSupport::ArrayInquirer` และ `Array#inquiry`
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   เพิ่ม `ActiveSupport::TimeZone#strptime` เพื่อให้สามารถแปลงเวลาเป็นตามเขตเวลาที่กำหนดได้
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

*   เพิ่ม `Integer#positive?` และ `Integer#negative?` เป็นเมธอดสอบถาม
    คล้ายกับ `Integer#zero?`
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

*   เพิ่มเวอร์ชัน bang ในเมธอด get ของ `ActiveSupport::OrderedOptions` ซึ่งจะเรียกใช้ `KeyError` ถ้าค่าเป็น `.blank?`
    ([Pull Request](https://github.com/rails/rails/pull/20208))

*   เพิ่ม `Time.days_in_year` เพื่อคืนค่าจำนวนวันในปีที่กำหนดหรือปีปัจจุบันถ้าไม่มีอาร์กิวเมนต์
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

*   เพิ่มตัวตรวจสอบไฟล์แบบ evented เพื่อตรวจหาการเปลี่ยนแปลงในรหัสแอปพลิเคชัน พาธเส้นทาง ภาษาท้องถิ่น เป็นต้น
    ([Pull Request](https://github.com/rails/rails/pull/22254))

*   เพิ่มชุดเมธอด thread_m/cattr_accessor/reader/writer เพื่อประกาศตัวแปรคลาสและโมดูลที่อยู่ในแต่ละเธรด
    ([Pull Request](https://github.com/rails/rails/pull/22630))

*   เพิ่ม `Array#second_to_last` และ `Array#third_to_last` methods
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   เผยแพร่ `ActiveSupport::Executor` และ `ActiveSupport::Reloader` APIs เพื่อให้ส่วนประกอบและไลบรารีสามารถจัดการและเข้าร่วมในกระบวนการทำงานของโค้ดแอปพลิเคชันและกระบวนการโหลดแอปพลิเคชันได้อย่างไม่เกิดข้อผิดพลาด
    ([Pull Request](https://github.com/rails/rails/pull/23807))

*   `ActiveSupport::Duration` ตอนนี้รองรับการจัดรูปแบบและการแปลง ISO8601
    ([Pull Request](https://github.com/rails/rails/pull/16917))

*   `ActiveSupport::JSON.decode` ตอนนี้รองรับการแปลงเวลาท้องถิ่น ISO8601 เมื่อเปิดใช้งาน `parse_json_times`
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   `ActiveSupport::JSON.decode` ตอนนี้คืนค่าออบเจ็กต์ `Date` สำหรับสตริงวันที่
    ([Pull Request](https://github.com/r
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
