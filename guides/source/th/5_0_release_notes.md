**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: df23e2b31bd56973a30f38f5a1c29b52
เรื่องสำคัญใน Rails 5.0:
==============

* Action Cable
* Rails API
* Active Record Attributes API
* Test Runner
* ใช้ `rails` CLI เป็นเครื่องมือหลักแทน Rake
* Sprockets 3
* Turbolinks 5
* ต้องใช้ Ruby 2.2.2+ เป็นขั้นต่ำ

เอกสารเวอร์ชันนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการทราบข้อมูลเพิ่มเติมเกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่าง ๆ โปรดอ้างอิงที่เอกสารเปลี่ยนแปลงหรือตรวจสอบ [รายการคอมมิต](https://github.com/rails/rails/commits/5-0-stable) ในเรพอสิทอรีหลักของ Rails บน GitHub.

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 5.0
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 4.2 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 5.0 มีรายการสิ่งที่ควรระวังเมื่ออัปเกรดในเอกสาร [การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0).

คุณสมบัติหลัก
--------------

### Action Cable

Action Cable เป็นเฟรมเวิร์กใหม่ใน Rails 5.0 มันรวม [WebSockets](https://en.wikipedia.org/wiki/WebSocket) ได้อย่างราบรื่นกับแอปพลิเคชัน Rails ของคุณ

Action Cable ช่วยให้คุณสามารถเขียนคุณสมบัติแบบเรียลไทม์ในภาษา Ruby ในรูปแบบและรูปแบบเดียวกับส่วนอื่น ๆ ของแอปพลิเคชัน Rails ของคุณ ในขณะเดียวกันยังมีประสิทธิภาพและมีความสามารถในการขยายขนาด มันเป็นเฟรมเวิร์กแบบ full-stack ที่ให้บริการทั้งเฟรมเวิร์กฝั่งไคลเอนต์และเฟรมเวิร์กฝั่งเซิร์ฟเวอร์ในภาษา Ruby คุณสามารถเข้าถึงโมเดลโดเมนทั้งหมดของคุณที่เขียนด้วย Active Record หรือ ORM ที่คุณเลือก

ดูเอกสาร [Action Cable Overview](action_cable_overview.html) สำหรับข้อมูลเพิ่มเติม

### แอปพลิเคชัน API

Rails สามารถใช้สร้างแอปพลิเคชัน API ที่มีขนาดเล็กลงได้แล้ว สิ่งนี้เป็นประโยชน์ในการสร้างและให้บริการ API ที่คล้ายกับ [Twitter](https://dev.twitter.com) หรือ [GitHub](https://developer.github.com) API ซึ่งสามารถใช้ในการให้บริการสู่สาธารณะและสำหรับแอปพลิเคชันที่กำหนดเองได้

คุณสามารถสร้างแอป Rails แบบ api ใหม่โดยใช้คำสั่ง:

```bash
$ rails new my_api --api
```
สิ่งที่จะทำ:

- กำหนดค่าให้แอปพลิเคชันเริ่มต้นด้วยเซ็ตของมิดเดิลแวร์ที่จำกัดมากกว่าปกติ โดยเฉพาะอย่างยิ่งจะไม่รวมมิดเดิลแวร์ที่มีประโยชน์สำหรับแอปพลิเคชันเบราว์เซอร์ (เช่นการสนับสนุนคุกกี้) โดยค่าเริ่มต้น
- ทำให้ `ApplicationController` สืบทอดจาก `ActionController::API` แทนที่จะสืบทอดจาก `ActionController::Base` เช่นเดียวกับมิดเดิลแวร์ นี้จะไม่รวมโมดูล Action Controller ที่ให้ฟังก์ชันที่ใช้งานโดยเฉพาะสำหรับแอปพลิเคชันเบราว์เซอร์
- กำหนดค่าเจเนอเรเตอร์ให้ข้ามการสร้างวิว เฮลเปอร์ และแอสเซ็ตเมื่อคุณสร้างทรัพยากรใหม่

แอปพลิเคชันจะให้ฐานสำหรับ API ซึ่งจากนั้นสามารถ [กำหนดค่าให้ดึงฟังก์ชัน](api_app.html) เมื่อเหมาะสมสำหรับความต้องการของแอปพลิเคชัน

ดูเพิ่มเติมในเอกสาร [การใช้ Rails สำหรับแอปพลิเคชัน API เท่านั้น](api_app.html)

### Active Record attributes API

กำหนดค่าแอตทริบิวต์ที่มีประเภทบนโมเดล จะแทนที่ประเภทของแอตทริบิวต์ที่มีอยู่ถ้าจำเป็น
สิ่งนี้ช่วยควบคุมวิธีการแปลงค่าเป็นและจาก SQL เมื่อกำหนดให้กับโมเดล
นอกจากนี้ยังเปลี่ยนพฤติกรรมของค่าที่ส่งผ่านไปยัง `ActiveRecord::Base.where` ซึ่งให้เราใช้วัตถุโดเมนของเราได้ในหลายส่วนของ Active Record โดยไม่ต้องพึ่งพารายละเอียดการดำเนินการหรือการแก้ไขโค้ด

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

# หลัง
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes # => {field_without_db_column: [1, 2, 3]}
```
**สร้างประเภทที่กำหนดเอง:**

คุณสามารถกำหนดประเภทที่กำหนดเองได้ตามที่คุณต้องการ โดยให้ตอบสนองกับเมธอดที่กำหนดไว้ในประเภทของค่า มีการเรียกใช้เมธอด `deserialize` หรือ `cast` บนออบเจ็กต์ประเภทของคุณ ด้วยข้อมูลเข้ารหัสจากฐานข้อมูลหรือจากคอนโทรลเลอร์ของคุณ นี่เป็นประโยชน์ เช่น เมื่อทำการแปลงแบบกำหนดเอง เช่น ข้อมูลเงิน

**การค้นหา:**

เมื่อเรียกใช้ `ActiveRecord::Base.where` จะใช้ประเภทที่กำหนดโดยคลาสโมเดลในการแปลงค่าเป็น SQL โดยเรียกใช้ `serialize` บนออบเจ็กต์ประเภทของคุณ

สิ่งนี้ช่วยให้วัตถุสามารถระบุวิธีการแปลงค่าเมื่อทำการค้นหา SQL

**การตรวจสอบการเปลี่ยนแปลง:**

ประเภทของแอตทริบิวต์สามารถเปลี่ยนวิธีการตรวจสอบการติดตามการเปลี่ยนแปลงได้

ดู
[เอกสาร](https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html)
สำหรับรายละเอียดเพิ่มเติม


### เครื่องมือทดสอบ

เครื่องมือทดสอบใหม่ถูกนำเสนอเพื่อเพิ่มความสามารถในการเรียกใช้งานทดสอบจาก Rails
ในการใช้เครื่องมือทดสอบนี้เพียงพิมพ์ `bin/rails test`.

เครื่องมือทดสอบนี้ได้รับแรงบันดาลใจมาจาก `RSpec`, `minitest-reporters`, `maxitest` และอื่น ๆ
มีการพัฒนาขึ้นมาดังนี้:

- รันเทสเดียวโดยใช้หมายเลขบรรทัดของเทส
- รันเทสหลายๆ เทสโดยระบุหมายเลขบรรทัดของเทส
- ข้อความผิดพลาดที่ปรับปรุง ซึ่งยังช่วยให้รันเทสที่ล้มเหลวอีกครั้งได้ง่ายขึ้น
- ระบบหยุดการทดสอบทันทีเมื่อเกิดข้อผิดพลาด โดยใช้ตัวเลือก `-f` เพื่อหยุดการทดสอบทันทีเมื่อเกิดข้อผิดพลาด แทนที่จะรอให้ชุดทดสอบเสร็จสมบูรณ์
- เลื่อนการแสดงผลของการทดสอบไปยังท้ายของการรันทดสอบเต็ม โดยใช้ตัวเลือก `-d`
- แสดงผลการแสดงข้อผิดพลาดทั้งหมด โดยใช้ตัวเลือก `-b`
- การผสานร่วมกับ minitest เพื่ออนุญาตให้ใช้ตัวเลือกเช่น `-s` สำหรับข้อมูลเมล็ดพันธุ์ทดสอบ `-n` เพื่อรันเทสที่ระบุชื่อ -v เพื่อแสดงผลการทดสอบอย่างละเอียดและอื่น ๆ
- การแสดงผลการทดสอบที่มีสี

Railties
--------

โปรดอ้างอิงที่ [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการสนับสนุนตัวแก้บัก ใช้ byebug แทน  `debugger` ไม่รองรับโดย
    Ruby
    2.2. ([commit](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))
*   ลบงาน `test:all` และ `test:all:db` ที่ถูกยกเลิกไป
    ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   ลบ `Rails::Rack::LogTailer` ที่ถูกยกเลิกไป
    ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   ลบค่าคงที่ `RAILS_CACHE` ที่ถูกยกเลิกไป
    ([commit](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   ลบการกำหนดค่า `serve_static_assets` ที่ถูกยกเลิกไป
    ([commit](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   ลบงานเอกสาร `doc:app`, `doc:rails`, และ `doc:guides` ที่ถูกยกเลิกไป
    ([commit](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   ลบ `Rack::ContentLength` middleware ออกจาก stack ค่าเริ่มต้น
    ([Commit](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### การเลิกใช้งาน

*   เลิกใช้งาน `config.static_cache_control` และใช้ `config.public_file_server.headers` แทน
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   เลิกใช้งาน `config.serve_static_files` และใช้ `config.public_file_server.enabled` แทน
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*   เลิกใช้งานงานในเนมสเปซ `rails` และใช้งานในเนมสเปซ `app` แทน
    (เช่น `rails:update` และ `rails:template` ถูกเปลี่ยนชื่อเป็น `app:update` และ `app:template`)
    ([Pull Request](https://github.com/rails/rails/pull/23439))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม Rails test runner `bin/rails test`
    ([Pull Request](https://github.com/rails/rails/pull/19216))

*   แอปพลิเคชันและปลั๊กอินที่สร้างใหม่จะได้รับ `README.md` ในรูปแบบ Markdown
    ([commit](https://github.com/rails/rails/commit/89a12c931b1f00b90e74afffcdc2fc21f14ca663),
     [Pull Request](https://github.com/rails/rails/pull/22068))

*   เพิ่มงาน `bin/rails restart` เพื่อรีสตาร์ทแอปพลิเคชัน Rails โดยสัมผัส `tmp/restart.txt`
    ([Pull Request](https://github.com/rails/rails/pull/18965))

*   เพิ่มงาน `bin/rails initializers` เพื่อพิมพ์อินิเชียไลเซอร์ที่กำหนดไว้ทั้งหมดในลำดับที่ถูกเรียกใช้โดย Rails
    ([Pull Request](https://github.com/rails/rails/pull/19323))

*   เพิ่มงาน `bin/rails dev:cache` เพื่อเปิดหรือปิดใช้งานแคชในโหมดการพัฒนา
    ([Pull Request](https://github.com/rails/rails/pull/20961))

*   เพิ่มสคริปต์ `bin/update` เพื่ออัปเดตสภาพแวดล้อมการพัฒนาโดยอัตโนมัติ
    ([Pull Request](https://github.com/rails/rails/pull/20972))

*   ส่ง Rake tasks ผ่าน `bin/rails`
    ([Pull Request](https://github.com/rails/rails/pull/22457),
     [Pull Request](https://github.com/rails/rails/pull/22288))

*   แอปพลิเคชันใหม่ถูกสร้างขึ้นด้วยตัวตรวจสอบไฟล์ระบบที่ใช้เหตุการณ์เป็นตัวควบคุมบน Linux และ macOS คุณสามารถเลือกไม่ใช้คุณลักษณะนี้ได้โดยผ่าน `--skip-listen` ไปยังตัวสร้าง
    ([commit](https://github.com/rails/rails/commit/de6ad5665d2679944a9ee9407826ba88395a1003),
    [commit](https://github.com/rails/rails/commit/94dbc48887bf39c241ee2ce1741ee680d773f202))

*   สร้างแอปพลิเคชันพร้อมตัวเลือกในการเขียนบันทึกไปยัง STDOUT ในโหมดการใช้งานจริงโดยใช้ตัวแปรสภาพแวดล้อม `RAILS_LOG_TO_STDOUT`
    ([Pull Request](https://github.com/rails/rails/pull/23734))

*   เปิดใช้งาน HSTS พร้อมส่วนหัว IncludeSubdomains สำหรับแอปพลิเคชันใหม่
    ([Pull Request](https://github.com/rails/rails/pull/23852))

*   ตัวสร้างแอปพลิเคชันเขียนไฟล์ใหม่ `config/spring.rb` ซึ่งบอก Spring ให้ดูไฟล์ทั่วไปเพิ่มเติม
    ([commit](https://github.com/rails/rails/commit/b04d07337fd7bc17e88500e9d6bcd361885a45f8))

*   เพิ่มตัวเลือก `--skip-action-mailer` เพื่อข้าม Action Mailer เมื่อสร้างแอปพลิเคชันใหม่
    ([Pull Request](https://github.com/rails/rails/pull/18288))

*   ลบไดเรกทอรี `tmp/sessions` และงาน rake ที่เกี่ยวข้อง
    ([Pull Request](https://github.com/rails/rails/pull/18314))

*   เปลี่ยน `_form.html.erb` ที่ถูกสร้างขึ้นโดยตัวสร้าง scaffold เพื่อใช้ตัวแปรท้องถิ่น
    ([Pull Request](https://github.com/rails/rails/pull/13434))
*   ปิดการโหลดคลาสอัตโนมัติในสภาพแวดล้อมการใช้งานจริง
    ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

Action Pack
-----------

โปรดอ้างอิงที่ [Changelog][action-pack] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `ActionDispatch::Request::Utils.deep_munge`
    ([commit](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   ลบ `ActionController::HideActions`
    ([Pull Request](https://github.com/rails/rails/pull/18371))

*   ลบ `respond_to` และ `respond_with` ฟังก์ชันตัวอย่างที่ถูกนำออกแล้ว ฟังก์ชันนี้
    ถูกแยกออกเป็น
    [responders](https://github.com/plataformatec/responders) gem
    ([commit](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   ลบไฟล์การยืนยันที่ถูกเลิกใช้งาน
    ([commit](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   ลบการใช้งานที่ถูกเลิกใช้งานของคีย์สตริงใน URL helpers
    ([commit](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   ลบตัวเลือก `only_path` ที่ถูกเลิกใช้งานใน `*_path` helpers
    ([commit](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))

*   ลบการสนับสนุนที่ถูกเลิกใช้งานของ `NamedRouteCollection#helpers`
    ([commit](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*   ลบการสนับสนุนที่ถูกเลิกใช้งานในการกำหนดเส้นทางด้วยตัวเลือก `:to` ที่ไม่มี `#`
    ([commit](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   ลบ `ActionDispatch::Response#to_ary` ที่ถูกเลิกใช้งาน
    ([commit](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   ลบ `ActionDispatch::Request#deep_munge` ที่ถูกเลิกใช้งาน
    ([commit](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   ลบ `ActionDispatch::Http::Parameters#symbolized_path_parameters` ที่ถูกเลิกใช้งาน
    ([commit](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   ลบตัวเลือก `use_route` ที่ถูกเลิกใช้งานในการทดสอบคอนโทรลเลอร์
    ([commit](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   ลบ `assigns` และ `assert_template` ทั้งสองฟังก์ชันถูกแยกออกเป็น
    [rails-controller-testing](https://github.com/rails/rails-controller-testing)
    gem
    ([Pull Request](https://github.com/rails/rails/pull/20138))

### การเลิกใช้งาน

*   เลิกใช้งานทั้งหมดของ `*_filter` callbacks และใช้ `*_action` callbacks แทน
    ([Pull Request](https://github.com/rails/rails/pull/18410))

*   เลิกใช้งาน `*_via_redirect` integration test methods ใช้ `follow_redirect!`
    ด้วยตนเองหลังจากการเรียกคำขอเพื่อให้เกิดพฤติกรรมเดียวกัน
    ([Pull Request](https://github.com/rails/rails/pull/18693))

*   เลิกใช้งาน `AbstractController#skip_action_callback` และใช้ skip_callback methods
    แต่ละตัวแทน
    ([Pull Request](https://github.com/rails/rails/pull/19060))

*   เลิกใช้งานตัวเลือก `:nothing` สำหรับเมธอด `render`
    ([Pull Request](https://github.com/rails/rails/pull/20336))

*   เลิกใช้งานการส่งพารามิเตอร์แรกเป็น `Hash` และสถานะเริ่มต้นสำหรับเมธอด `head`
    ([Pull Request](https://github.com/rails/rails/pull/20407))

*   เลิกใช้งานการใช้ชื่อคลาสของ middleware เป็นสตริงหรือสัญลักษณ์ ใช้ชื่อคลาสแทน
    ([commit](https://github.com/rails/rails/commit/83b767ce))

*   เลิกใช้งานการเข้าถึง MIME types ผ่านค่าคงที่ (เช่น `Mime::HTML`) ใช้ตัวดัชนีด้วยสัญลักษณ์แทน (เช่น `Mime[:html]`)
    ([Pull Request](https://github.com/rails/rails/pull/21869))

*   เลิกใช้งาน `redirect_to :back` และใช้ `redirect_back` ซึ่งยอมรับอาร์กิวเมนต์ `fallback_location` ที่ต้องการ ทำให้ไม่มีโอกาสเกิด `RedirectBackError`
    ([Pull Request](https://github.com/rails/rails/pull/22506))

*   `ActionDispatch::IntegrationTest` และ `ActionController::TestCase` เลิกใช้งานอาร์กิวเมนต์ตำแหน่งในของ keyword arguments
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   เลิกใช้งานพารามิเตอร์เส้นทาง `:controller` และ `:action`
    ([Pull Request](https://github.com/rails/rails/pull/23980))

*   เลิกใช้งานเมธอด env บนอินสแตนซ์ของคอนโทรลเลอร์
    ([commit](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   `ActionDispatch::ParamsParser` เลิกใช้งานและถูกนำออกจาก middleware stack เพื่อกำหนดค่า parameter parsers ให้ใช้
    `ActionDispatch::Request.parameter_parsers=`
    ([commit](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1),
    [commit](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))
### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม `ActionController::Renderer` เพื่อเรียกใช้เทมเพลตที่ไม่ได้อยู่ในการกระทำของคอนโทรลเลอร์
    ([Pull Request](https://github.com/rails/rails/pull/18546))

*   ย้ายไปใช้รูปแบบอาร์กิวเมนต์แบบคีย์เวิร์ดใน `ActionController::TestCase` และ
    `ActionDispatch::Integration` วิธีการร้องขอ HTTP
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   เพิ่ม `http_cache_forever` เข้าไปใน Action Controller เพื่อให้เราสามารถเก็บแคชการตอบสนองที่ไม่หมดอายุได้
    ([Pull Request](https://github.com/rails/rails/pull/18394))

*   ให้การเข้าถึง request variants ที่เป็นมิตรมากขึ้น
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   สำหรับการกระทำที่ไม่มีเทมเพลตที่เกี่ยวข้อง ให้แสดงผล `head :no_content`
    แทนที่จะเกิดข้อผิดพลาด
    ([Pull Request](https://github.com/rails/rails/pull/19377))

*   เพิ่มความสามารถในการแทนที่ฟอร์มบิลเดอร์เริ่มต้นสำหรับคอนโทรลเลอร์
    ([Pull Request](https://github.com/rails/rails/pull/19736))

*   เพิ่มการสนับสนุนสำหรับแอป API-only
    `ActionController::API` ถูกเพิ่มเป็นตัวแทนของ
    `ActionController::Base` สำหรับแอปพลิเคชันประเภทนี้
    ([Pull Request](https://github.com/rails/rails/pull/19832))

*   ทำให้ `ActionController::Parameters` ไม่สืบทอดจาก
    `HashWithIndifferentAccess` อีกต่อไป
    ([Pull Request](https://github.com/rails/rails/pull/20868))

*   ทำให้ง่ายต่อการเปิดใช้งาน `config.force_ssl` และ `config.ssl_options` โดยทำให้ไม่เสี่ยงต่อความเสี่ยงและง่ายต่อการปิดใช้งาน
    ([Pull Request](https://github.com/rails/rails/pull/21520))

*   เพิ่มความสามารถในการส่งคืนเฮดเดอร์อะไรก็ได้ให้กับ `ActionDispatch::Static`
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   เปลี่ยนค่าเริ่มต้นของ `protect_from_forgery` ให้เป็น `false`
    ([commit](https://github.com/rails/rails/commit/39794037817703575c35a75f1961b01b83791191))

*   `ActionController::TestCase` จะถูกย้ายไปเป็น gem เองใน Rails 5.1 ใช้
    `ActionDispatch::IntegrationTest` แทน
    ([commit](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d))

*   Rails สร้าง ETags ที่อ่อนแอตามค่าเริ่มต้น
    ([Pull Request](https://github.com/rails/rails/pull/17573))

*   การกระทำของคอนโทรลเลอร์ที่ไม่มีการเรียกใช้ `render` และไม่มีเทมเพลตที่เกี่ยวข้องจะแสดงผล `head :no_content` โดยอัตโนมัติแทนที่จะเกิดข้อผิดพลาด
    (Pull Request [1](https://github.com/rails/rails/pull/19377),
    [2](https://github.com/rails/rails/pull/23827))

*   เพิ่มตัวเลือกสำหรับ CSRF tokens ต่อฟอร์ม
    ([Pull Request](https://github.com/rails/rails/pull/22275))

*   เพิ่มการเข้ารหัสคำขอและการแยกวิเคราะห์การตอบสนองในการทดสอบการรวมกัน
    ([Pull Request](https://github.com/rails/rails/pull/21671))

*   เพิ่ม `ActionController#helpers` เพื่อให้เราสามารถเข้าถึงบริบทของวิวที่ระดับคอนโทรลเลอร์ได้
    ([Pull Request](https://github.com/rails/rails/pull/24866))

*   ข้อความ flash ที่ถูกละทิ้งจะถูกลบออกก่อนจัดเก็บลงในเซสชัน
    ([Pull Request](https://github.com/rails/rails/pull/18721))

*   เพิ่มการสนับสนุนในการส่งคอลเลกชันของเร็คคอร์ดไปยัง `fresh_when` และ
    `stale?`
    ([Pull Request](https://github.com/rails/rails/pull/18374))

*   `ActionController::Live` เป็น `ActiveSupport::Concern` แล้ว ซึ่ง
    หมายความว่าไม่สามารถรวมมันเข้ากับโมดูลอื่นๆ โดยเพียงแค่รวมมันเข้ากับ
    `ActiveSupport::Concern` หรือ `ActionController::Live`
    จะไม่มีผลในการใช้งานจริง บางคนอาจใช้โมดูลอื่นเพื่อรวมรหัสการจัดการข้อผิดพลาดของการตรวจสอบความถูกต้องของ `Warden`/`Devise` ด้วยเนื่องจากมิดเวร์ไม่สามารถจับ `:warden` ที่ถูกส่งออกโดยเธรดที่ถูกสร้างขึ้นได้ซึ่งเป็นกรณีเมื่อใช้ `ActionController::Live`
    ([รายละเอียดเพิ่มเติมในปัญหานี้](https://github.com/rails/rails/issues/25581))
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

*   การเรียกใช้งาน collection rendering สามารถแคชและดึง partials หลายๆ อันพร้อมกันได้
    ([Pull Request](https://github.com/rails/rails/pull/18948),
    [commit](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

*   เพิ่มการจับคู่ wildcard ใน explicit dependencies
    ([Pull Request](https://github.com/rails/rails/pull/20904))

*   ทำให้ `disable_with` เป็นพฤติกรรมเริ่มต้นสำหรับ submit tags ปิดใช้งานปุ่มเมื่อส่งฟอร์มเพื่อป้องกันการส่งซ้ำ
    ([Pull Request](https://github.com/rails/rails/pull/21135))

*   ชื่อ partial template ไม่จำเป็นต้องเป็นตัวระบุ Ruby ที่ถูกต้องอีกต่อไป
    ([commit](https://github.com/rails/rails/commit/da9038e))

*   `datetime_tag` helper ตอนนี้สร้างแท็ก input ด้วยประเภท `datetime-local`
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   อนุญาตให้ใช้งาน blocks ในขณะที่ render ด้วย `render partial:` helper
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

*   การค้นหา template ตอนนี้เคารพ default locale และ I18n fallbacks
    ([commit](https://github.com/rails/rails/commit/ecb1981b))

*   เพิ่ม `_mailer` suffix ให้กับ mailers ที่สร้างผ่าน generator ตามหลักการตั้งชื่อเดียวกับ controllers และ jobs
    ([Pull Request](https://github.com/rails/rails/pull/18074))

*   เพิ่ม `assert_enqueued_emails` และ `assert_no_enqueued_emails`
    ([Pull Request](https://github.com/rails/rails/pull/18403))

*   เพิ่มการกำหนดค่า `config.action_mailer.deliver_later_queue_name` เพื่อตั้งค่าชื่อคิวของ mailer
    ([Pull Request](https://github.com/rails/rails/pull/18587))

*   เพิ่มการสนับสนุน fragment caching ใน Action Mailer views
    เพิ่มตัวเลือกการกำหนดค่าใหม่ `config.action_mailer.perform_caching` เพื่อกำหนดว่า template ของคุณควรทำ caching หรือไม่
    ([Pull Request](https://github.com/rails/rails/pull/22825))


Active Record
-------------

โปรดอ้างอิงที่ [Changelog][active-record] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบพฤติกรรมที่ถูกยกเลิกที่อนุญาตให้ส่งผ่าน nested arrays เป็นค่า query
    ([Pull Request](https://github.com/rails/rails/pull/17919))

*   ลบ `ActiveRecord::Tasks::DatabaseTasks#load_schema` ที่ถูกยกเลิกแล้ว วิธีนี้ถูกแทนที่ด้วย `ActiveRecord::Tasks::DatabaseTasks#load_schema_for`
    ([commit](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))
*   ลบ `serialized_attributes` ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*   ลบการนับแบบอัตโนมัติที่ถูกยกเลิกแล้วใน `has_many :through`
    ([commit](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

*   ลบ `sanitize_sql_hash_for_conditions` ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

*   ลบ `Reflection#source_macro` ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

*   ลบ `symbolized_base_class` และ `symbolized_sti_name` ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

*   ลบ `ActiveRecord::Base.disable_implicit_join_references=` ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

*   ลบการเข้าถึงการกำหนดค่าการเชื่อมต่อด้วยตัวเข้าถึงสตริงที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

*   ลบการสนับสนุนการโหลดล่วงหน้าของการเชื่อมโยงที่ขึ้นอยู่กับอินสแตนซ์ที่ถูกยกเลิกแล้ว
    ([commit](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

*   ลบการสนับสนุนระดับเดียวกันสำหรับ PostgreSQL ranges ที่มีขอบเขตล่างที่เป็นแบบเฉพาะ
    ([commit](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

*   ลบการเตือนเมื่อแก้ไขความสัมพันธ์ด้วย Arel ที่มีการแคช
    นี่จะเรียกข้อผิดพลาด `ImmutableRelation` แทน
    ([commit](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

*   ลบ `ActiveRecord::Serialization::XmlSerializer` ออกจากคอร์
    คุณลักษณะนี้ถูกแยกออกเป็น
    [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml)
    gem. ([Pull Request](https://github.com/rails/rails/pull/21161))

*   ลบการสนับสนุนสำหรับแอดาปเตอร์ฐานข้อมูล `mysql` เวอร์ชันเก่าออกจากคอร์
    ผู้ใช้ส่วนใหญ่ควรใช้ `mysql2` แทน จะถูกแปลงเป็น gem แยกเมื่อเราพบคนที่จะดูแลรักษา
    ([Pull Request 1](https://github.com/rails/rails/pull/22642),
    [Pull Request 2](https://github.com/rails/rails/pull/22715))

*   ลบการสนับสนุนสำหรับแพ็กเกจ `protected_attributes`
    ([commit](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

*   ลบการสนับสนุนสำหรับเวอร์ชัน PostgreSQL ต่ำกว่า 9.1
    ([Pull Request](https://github.com/rails/rails/pull/23434))

*   ลบการสนับสนุนสำหรับแพ็กเกจ `activerecord-deprecated_finders`
    ([commit](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

*   ลบค่าคงที่ `ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES`
    ([commit](https://github.com/rails/rails/commit/a502703c3d2151d4d3b421b29fefdac5ad05df61))

### การเตือนเกี่ยวกับการใช้งานที่ถูกยกเลิก

*   เตือนการส่งคลาสเป็นค่าในคิวรี ผู้ใช้ควรส่งสตริงแทน
    ([Pull Request](https://github.com/rails/rails/pull/17916))

*   เตือนการส่งค่า `false` เพื่อหยุดการทำงานของ Active Record callback
    วิธีที่แนะนำคือให้ `throw(:abort)` แทน
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   เตือน `ActiveRecord::Base.errors_in_transactional_callbacks=`
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

*   เตือนการใช้ `Relation#uniq` ให้ใช้ `Relation#distinct` แทน
    ([commit](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

*   เตือนประเภท `:point` ของ PostgreSQL ให้ใช้ประเภทใหม่ที่จะคืนค่าเป็น `Point` แทน `Array`
    ([Pull Request](https://github.com/rails/rails/pull/20448))

*   เตือนการโหลดข้อมูลใหม่ของสมาชิกด้วยการส่งอาร์กิวเมนต์ที่เป็นจริงให้กับเมธอดการเชื่อมโยง
    ([Pull Request](https://github.com/rails/rails/pull/20888))

*   เตือนการใช้ชื่อคีย์สำหรับข้อผิดพลาดของ `restrict_dependent_destroy` ให้ใช้ชื่อคีย์ใหม่แทน
    ([Pull Request](https://github.com/rails/rails/pull/20668))

*   ปรับปรุงพฤติกรรมของ `#tables`
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   เตือนให้ใช้ `SchemaCache#tables`, `SchemaCache#table_exists?` และ
    `SchemaCache#clear_table_cache!` ในแหล่งข้อมูลใหม่ของพวกเขา
    ([Pull Request](https://github.com/rails/rails/pull/21715))
*   ยกเลิกการใช้งาน `connection.tables` ใน SQLite3 และ MySQL adapters.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   ยกเลิกการส่งอาร์กิวเมนต์ไปยัง `#tables` - เมธอด `#tables` ของ adapters บางตัว (mysql2, sqlite3) จะส่งคืนทั้งตารางและวิว ในขณะที่ adapters อื่น (postgresql) จะส่งคืนเฉพาะตารางเท่านั้น ในอนาคต `#tables` จะส่งคืนเฉพาะตารางเท่านั้นเพื่อให้พฤติกรรมของมันสอดคล้องกัน
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   ยกเลิกการใช้งาน `table_exists?` - เมธอด `#table_exists?` จะตรวจสอบทั้งตารางและวิว ในอนาคต `#table_exists?` จะตรวจสอบเฉพาะตารางเท่านั้นเพื่อให้พฤติกรรมของมันสอดคล้องกันกับ `#tables`
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   ยกเลิกการส่งอาร์กิวเมนต์ `offset` ไปยัง `find_nth` โปรดใช้เมธอด `offset` บน relation แทน
    ([Pull Request](https://github.com/rails/rails/pull/22053))

*   ยกเลิก `{insert|update|delete}_sql` ใน `DatabaseStatements` ใช้เมธอด `{insert|update|delete}` สาธารณะแทน
    ([Pull Request](https://github.com/rails/rails/pull/23086))

*   ยกเลิกการใช้งาน `use_transactional_fixtures` เพื่อเปลี่ยนเป็น `use_transactional_tests` เพื่อความชัดเจนมากขึ้น
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

*   เพิ่ม `ActiveRecord::Base#accessed_fields` ซึ่งสามารถใช้ค้นพบฟิลด์ที่ถูกอ่านจากโมเดลได้อย่างรวดเร็วเมื่อคุณต้องการเลือกข้อมูลที่คุณต้องการจากฐานข้อมูล
    ([commit](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

*   เพิ่มเมธอด `#or` ให้กับ `ActiveRecord::Relation` เพื่ออนุญาตให้ใช้ตัวดำเนินการ OR เพื่อรวม WHERE หรือ HAVING clauses
    ([commit](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

*   เพิ่ม `ActiveRecord::Base.suppress` เพื่อป้องกันการบันทึก receiver ในระหว่างการทำงานของบล็อกที่กำหนด
    ([Pull Request](https://github.com/rails/rails/pull/18910))

*   `belongs_to` จะเริ่มทำให้เกิดข้อผิดพลาดการตรวจสอบโดยค่าเริ่มต้นหากไม่มีการเชื่อมโยง คุณสามารถปิดการใช้งานนี้ได้ตามการเชื่อมโยงแต่ละตัวด้วย `optional: true` ยังยกเลิกการใช้งานตัวเลือก `required` เพื่อเปลี่ยนเป็น `optional` สำหรับ `belongs_to`
    ([Pull Request](https://github.com/rails/rails/pull/18937))
*   เพิ่ม `config.active_record.dump_schemas` เพื่อกำหนดพฤติกรรมของ `db:structure:dump`.
    ([Pull Request](https://github.com/rails/rails/pull/19347))

*   เพิ่มตัวเลือก `config.active_record.warn_on_records_fetched_greater_than`.
    ([Pull Request](https://github.com/rails/rails/pull/18846))

*   เพิ่มการสนับสนุนชนิดข้อมูล JSON ใน MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/21110))

*   เพิ่มการสนับสนุนการลบดัชนีพร้อมกันใน PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/21317))

*   เพิ่มเมธอด `#views` และ `#view_exists?` ในตัวอักษรเชื่อมต่อ.
    ([Pull Request](https://github.com/rails/rails/pull/21609))

*   เพิ่ม `ActiveRecord::Base.ignored_columns` เพื่อทำให้คอลัมน์บางคอลัมน์
    สามารถถูกซ่อนจาก Active Record ได้.
    ([Pull Request](https://github.com/rails/rails/pull/21720))

*   เพิ่ม `connection.data_sources` และ `connection.data_source_exists?`.
    เมธอดเหล่านี้กำหนดว่าความสัมพันธ์ใดสามารถใช้เป็นฐานสำหรับ Active Record
    โมเดล (โดย通常จะเป็นตารางและมุมมอง).
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   อนุญาตให้ไฟล์ค่าเริ่มต้นตั้งค่าคลาสโมเดลในไฟล์ YAML เอง.
    ([Pull Request](https://github.com/rails/rails/pull/20574))

*   เพิ่มความสามารถในการตั้งค่าเป็น `uuid` เป็นคีย์หลักเมื่อสร้างการเปลี่ยนแปลงฐานข้อมูล
    ([Pull Request](https://github.com/rails/rails/pull/21762))

*   เพิ่ม `ActiveRecord::Relation#left_joins` และ
    `ActiveRecord::Relation#left_outer_joins`.
    ([Pull Request](https://github.com/rails/rails/pull/12071))

*   เพิ่ม `after_{create,update,delete}_commit` callbacks.
    ([Pull Request](https://github.com/rails/rails/pull/22516))

*   เวอร์ชัน API ที่นำเสนอให้กับคลาสการเรียกใช้งานเพื่อให้เราสามารถเปลี่ยนค่าเริ่มต้นของพารามิเตอร์ได้
    โดยไม่ทำให้การเปลี่ยนแปลงฉบับเก่าเสียหาย หรือบังคับให้เขียนใหม่ผ่านรอบการเลิกใช้งาน
    ([Pull Request](https://github.com/rails/rails/pull/21538))

*   `ApplicationRecord` เป็นคลาสแม่ใหม่สำหรับโมเดลแอป คล้ายกับการสืบทอดคลาสควบคุมแอป
    ที่สืบทอดจาก `ApplicationController` แทนที่จะสืบทอดจาก `ActionController::Base`
    สิ่งนี้ช่วยให้แอปมีจุดเดียวสำหรับกำหนดพฤติกรรมของโมเดลทั่วไปในแอป
    ([Pull Request](https://github.com/rails/rails/pull/22567))

*   เพิ่มเมธอด `ActiveRecord` `#second_to_last` และ `#third_to_last`.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   เพิ่มความสามารถในการเพิ่มคำอธิบายให้กับวัตถุฐานข้อมูล (ตาราง คอลัมน์ ดัชนี)
    ด้วยความคิดเห็นที่เก็บไว้ในข้อมูลเมตาดาต้าเบสสำหรับ PostgreSQL และ MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/22911))

*   เพิ่มการสนับสนุนคำสั่งเตรียมใช้งานในตัวเลือก `mysql2` adapter, สำหรับ mysql2 0.4.4+
    ก่อนหน้านี้เฉพาะ adapter `mysql` ที่ถูกยกเลิกเท่านั้นที่รองรับ
    เพื่อเปิดใช้งาน ตั้งค่า `prepared_statements: true` ใน `config/database.yml`.
    ([Pull Request](https://github.com/rails/rails/pull/23461))

*   เพิ่มความสามารถในการเรียกใช้งาน `ActionRecord::Relation#update` บนวัตถุความสัมพันธ์
    ซึ่งจะเรียกใช้งานการตรวจสอบความถูกต้องใน callback บนวัตถุทั้งหมดในความสัมพันธ์
    ([Pull Request](https://github.com/rails/rails/pull/11898))

*   เพิ่มตัวเลือก `:touch` ในเมธอด `save` เพื่อบันทึกบันทึกโดยไม่ต้องอัปเดตเวลา.
    ([Pull Request](https://github.com/rails/rails/pull/18225))

*   เพิ่มการสนับสนุนดัชนีแสดงออกและคลาสตัวดำเนินการสำหรับ PostgreSQL.
    ([commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))
*   เพิ่ม `:index_errors` option เพื่อเพิ่มดัชนีให้กับข้อผิดพลาดของแอตทริบิวต์ที่ซ้อนกัน
    ([Pull Request](https://github.com/rails/rails/pull/19686))

*   เพิ่มการสนับสนุนสำหรับการลบข้อมูลที่เกี่ยวข้องกันทั้งสองทิศทาง
    ([Pull Request](https://github.com/rails/rails/pull/18548))

*   เพิ่มการสนับสนุนสำหรับ `after_commit` callbacks ในการทดสอบที่มีการทำธุรกรรม
    ([Pull Request](https://github.com/rails/rails/pull/18458))

*   เพิ่มเมธอด `foreign_key_exists?` เพื่อตรวจสอบว่ามี foreign key อยู่ในตารางหรือไม่
    ([Pull Request](https://github.com/rails/rails/pull/18662))

*   เพิ่ม `:time` option ให้กับเมธอด `touch` เพื่อทำการ touch บันทึกที่มีเวลาต่างจากเวลาปัจจุบัน
    ([Pull Request](https://github.com/rails/rails/pull/18956))

*   เปลี่ยน transaction callbacks เพื่อไม่ให้กลืนข้อผิดพลาด
    ก่อนการเปลี่ยนแปลงนี้ ข้อผิดพลาดใด ๆ ที่เกิดขึ้นภายใน transaction callback
    จะถูกบันทึกและแสดงในบันทึก ยกเว้นถ้าคุณใช้
    ตัวเลือก `raise_in_transactional_callbacks = true` (ที่ถูกเพิกเฉยแล้ว)

    ตอนนี้ข้อผิดพลาดเหล่านี้จะไม่ถูกบันทึกและเพียงแค่แผ่ขึ้นมาเท่านั้น ทำให้เหมือนกับพฤติกรรมของ callback อื่น ๆ
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `ActiveModel::Dirty#reset_#{attribute}` และ
    `ActiveModel::Dirty#reset_changes` ที่ถูกเลิกใช้งาน
    ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

*   ลบการซีเรียลไซเซชัน XML คุณลักษณะนี้ถูกแยกออกเป็น
    [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) gem
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   ลบโมดูล `ActionController::ModelNaming`
    ([Pull Request](https://github.com/rails/rails/pull/18194))

### การเลิกใช้งาน

*   เลิกใช้การส่งคืน `false` เป็นวิธีหยุด Active Model และ
    โฟลว์ของ callback ของ `ActiveModel::Validations` วิธีที่แนะนำคือ
    `throw(:abort)` ([Pull Request](https://github.com/rails/rails/pull/17227))

*   เลิกใช้ `ActiveModel::Errors#get`, `ActiveModel::Errors#set` และ
    `ActiveModel::Errors#[]=` เมธอดที่มีพฤติกรรมที่ไม่สม่ำเสมอ
    ([Pull Request](https://github.com/rails/rails/pull/18634))

*   เลิกใช้ตัวเลือก `:tokenizer` สำหรับ `validates_length_of`, เพื่อใช้ Ruby ธรรมดาแทน
    ([Pull Request](https://github.com/rails/rails/pull/19585))

*   เลิกใช้ `ActiveModel::Errors#add_on_empty` และ `ActiveModel::Errors#add_on_blank`
    โดยไม่มีการแทนที่
    ([Pull Request](https://github.com/rails/rails/pull/18996))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม `ActiveModel::Errors#details` เพื่อกำหนดว่า validator ไหนที่ล้มเหลว
    ([Pull Request](https://github.com/rails/rails/pull/18322))

*   แยก `ActiveRecord::AttributeAssignment` เป็น `ActiveModel::AttributeAssignment`
    ที่อนุญาตให้ใช้สำหรับวัตถุใด ๆ เป็นโมดูลที่สามารถรวมได้
    ([Pull Request](https://github.com/rails/rails/pull/10776))

*   เพิ่ม `ActiveModel::Dirty#[attr_name]_previously_changed?` และ
    `ActiveModel::Dirty#[attr_name]_previous_change` เพื่อเพิ่มการเข้าถึง
    การเปลี่ยนแปลงที่บันทึกไว้หลังจากบันทึกโมเดลแล้ว
    ([Pull Request](https://github.com/rails/rails/pull/19847))

*   ตรวจสอบ multiple contexts ใน `valid?` และ `invalid?` พร้อมกัน
    ([Pull Request](https://github.com/rails/rails/pull/21069))

*   เปลี่ยน `validates_acceptance_of` เพื่อยอมรับค่าเริ่มต้นเป็น `true`
    นอกเหนือจาก `1`
    ([Pull Request](https://github.com/rails/rails/pull/18439))
Active Job
-----------

โปรดอ้างอิง [Changelog][active-job] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

*   `ActiveJob::Base.deserialize` ส่งงานไปยังคลาสงาน ซึ่งทำให้งานสามารถแนบข้อมูลเพิ่มเติมได้เมื่อถูกซีเรียลไลซ์และอ่านกลับเมื่อถูกดำเนินการ
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*   เพิ่มความสามารถในการกำหนดค่าแอดาปเตอร์คิวบนพื้นฐานของงานแต่ละงานโดยไม่มีผลต่องานอื่น ๆ
    ([Pull Request](https://github.com/rails/rails/pull/16992))

*   งานที่สร้างขึ้นตอนนี้จะสืบทอดจาก `app/jobs/application_job.rb` โดยค่าเริ่มต้น
    ([Pull Request](https://github.com/rails/rails/pull/19034))

*   อนุญาตให้ `DelayedJob`, `Sidekiq`, `qu`, `que`, และ `queue_classic` รายงานรหัสงานกลับไปยัง `ActiveJob::Base` เป็น `provider_job_id`
    ([Pull Request](https://github.com/rails/rails/pull/20064),
     [Pull Request](https://github.com/rails/rails/pull/20056),
     [commit](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

*   สร้าง `AsyncJob` processor ที่เรียกใช้งาน `AsyncAdapter` ที่เก็บงานไว้ใน `concurrent-ruby` thread pool
    ([Pull Request](https://github.com/rails/rails/pull/21257))

*   เปลี่ยนแปลงแอดาปเตอร์เริ่มต้นจาก inline เป็น async ซึ่งเป็นค่าเริ่มต้นที่ดีกว่าเนื่องจากการทดสอบจะไม่พลาดการทำงานที่เกิดขึ้นแบบเสมอ
    ([commit](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))

Active Support
--------------

โปรดอ้างอิง [Changelog][active-support] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `ActiveSupport::JSON::Encoding::CircularReferenceError` ที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

*   ลบเมธอดที่ถูกยกเลิก `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=`
    และ `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string`
    ([commit](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

*   ลบ `ActiveSupport::SafeBuffer#prepend` ที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

*   ลบเมธอดที่ถูกยกเลิกจาก `Kernel` คือ `silence_stderr`, `silence_stream`,
    `capture` และ `quietly`
    ([commit](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

*   ลบไฟล์ `active_support/core_ext/big_decimal/yaml_conversions` ที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

*   ลบเมธอดที่ถูกยกเลิก `ActiveSupport::Cache::Store.instrument` และ
    `ActiveSupport::Cache::Store.instrument=`
    ([commit](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

*   ลบ `Class#superclass_delegating_accessor` ที่ถูกยกเลิก
    ใช้ `Class#class_attribute` แทน
    ([Pull Request](https://github.com/rails/rails/pull/16938))

*   ลบ `ThreadSafe::Cache` ใช้ `Concurrent::Map` แทน
    ([Pull Request](https://github.com/rails/rails/pull/21679))

*   ลบ `Object#itself` เนื่องจากมีการนำมาใช้ใน Ruby 2.2
    ([Pull Request](https://github.com/rails/rails/pull/18244))

### การเลิกใช้

*   เลิกใช้ `MissingSourceFile` และใช้ `LoadError` แทน
    ([commit](https://github.com/rails/rails/commit/734d97d2))

*   เลิกใช้ `alias_method_chain` และใช้ `Module#prepend` ที่ถูกนำเสนอใน Ruby 2.0 แทน
    ([Pull Request](https://github.com/rails/rails/pull/19434))

*   เลิกใช้ `ActiveSupport::Concurrency::Latch` และใช้
    `Concurrent::CountDownLatch` จาก concurrent-ruby แทน
    ([Pull Request](https://github.com/rails/rails/pull/20866))

*   เลิกใช้ตัวเลือก `:prefix` ของ `number_to_human_size` โดยไม่มีตัวแทน
    ([Pull Request](https://github.com/rails/rails/pull/21191))

*   เลิกใช้ `Module#qualified_const_` และใช้เมธอด `Module#const_` ที่มีอยู่แทน
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*   เลิกใช้การส่งสตริงเพื่อกำหนดค่า callback
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*   เลิกใช้ `ActiveSupport::Cache::Store#namespaced_key`,
    `ActiveSupport::Cache::MemCachedStore#escape_key`, และ
    `ActiveSupport::Cache::FileStore#key_file_path`
    ใช้ `normalize_key` แทน
    ([Pull Request](https://github.com/rails/rails/pull/22215),
     [commit](https://github.com/rails/rails/commit/a8f773b0))
*   ปรับใช้ `write_cache_value` แทน `ActiveSupport::Cache::LocaleCache#set_cache_value` ที่ถูกยกเลิกแล้ว
    ([Pull Request](https://github.com/rails/rails/pull/22215))

*   ปรับใช้ไม่ส่งอาร์กิวเมนต์ให้กับ `assert_nothing_raised` ที่ถูกยกเลิกแล้ว
    ([Pull Request](https://github.com/rails/rails/pull/23789))

*   ปรับใช้ `Module.constants(false)` แทน `Module.local_constants` ที่ถูกยกเลิกแล้ว
    ([Pull Request](https://github.com/rails/rails/pull/23936))


### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มเมธอด `#verified` และ `#valid_message?` ใน `ActiveSupport::MessageVerifier`
    ([Pull Request](https://github.com/rails/rails/pull/17727))

*   เปลี่ยนวิธีหยุดการทำงานของ callback chains โดยวิธีที่แนะนำในการหยุด callback chain ตอนนี้คือการใช้ `throw(:abort)` โดยชัดเจน
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   เพิ่มตัวเลือกการกำหนดค่าใหม่ `config.active_support.halt_callback_chains_on_return_false` เพื่อระบุว่า ActiveRecord, ActiveModel, และ ActiveModel::Validations callback chains สามารถหยุดได้โดยการส่งค่า `false` ใน 'before' callback
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   เปลี่ยนการเรียงลำดับทดสอบเริ่มต้นจาก `:sorted` เป็น `:random`
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

*   เพิ่มเมธอด `#on_weekend?`, `#on_weekday?`, `#next_weekday`, `#prev_weekday` ใน `Date`,
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

*   เพิ่ม `file_fixture` ใน `ActiveSupport::TestCase` เพื่อให้สามารถเข้าถึงไฟล์ตัวอย่างในกรณีทดสอบได้ง่าย
    ([Pull Request](https://github.com/rails/rails/pull/18658))

*   เพิ่ม `#without` ใน `Enumerable` และ `Array` เพื่อคืนค่าสำเนาของ enumerable โดยไม่รวมสมาชิกที่ระบุ
    ([Pull Request](https://github.com/rails/rails/pull/19157))

*   เพิ่ม `ActiveSupport::ArrayInquirer` และ `Array#inquiry`
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   เพิ่ม `ActiveSupport::TimeZone#strptime` เพื่อให้สามารถแปลงเวลาเป็นตามเขตเวลาที่กำหนดได้
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

*   เพิ่มเมธอดค้นหา `Integer#positive?` และ `Integer#negative?`
    ในลักษณะเดียวกับ `Integer#zero?`
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

*   เพิ่มเวอร์ชัน bang ในเมธอด get ของ `ActiveSupport::OrderedOptions` ซึ่งจะเกิดข้อผิดพลาด `KeyError` หากค่าเป็น `.blank?`
    ([Pull Request](https://github.com/rails/rails/pull/20208))

*   เพิ่ม `Time.days_in_year` เพื่อคืนค่าจำนวนวันในปีที่กำหนดหรือปีปัจจุบันหากไม่มีอาร์กิวเมนต์
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

*   เพิ่มตัวตรวจสอบไฟล์แบบ evented เพื่อตรวจหาการเปลี่ยนแปลงในรหัสต้นฉบับของแอปพลิเคชัน เส้นทาง ภาษาท้องถิ่น เป็นต้น
    ([Pull Request](https://github.com/rails/rails/pull/22254))

*   เพิ่มชุดเมธอด thread_m/cattr_accessor/reader/writer เพื่อประกาศตัวแปรคลาสและโมดูลที่อยู่ในแต่ละเธรด
    ([Pull Request](https://github.com/rails/rails/pull/22630))
*   เพิ่ม `Array#second_to_last` และ `Array#third_to_last` methods.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   เผยแพร่ `ActiveSupport::Executor` และ `ActiveSupport::Reloader` APIs เพื่ออนุญาตให้คอมโพเนนต์และไลบรารีสามารถจัดการและมีส่วนร่วมในกระบวนการประมวลผลของโค้ดแอปพลิเคชันและกระบวนการโหลดแอปพลิเคชันใหม่
    ([Pull Request](https://github.com/rails/rails/pull/23807))

*   `ActiveSupport::Duration` ตอนนี้สนับสนุนการจัดรูปแบบและการแปลงข้อมูลตามมาตรฐาน ISO8601
    ([Pull Request](https://github.com/rails/rails/pull/16917))

*   `ActiveSupport::JSON.decode` ตอนนี้สนับสนุนการแปลงข้อมูลเวลาท้องถิ่น ISO8601 เมื่อเปิดใช้งาน `parse_json_times`
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   `ActiveSupport::JSON.decode` ตอนนี้ส่งคืนออบเจ็กต์ `Date` สำหรับสตริงวันที่
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   เพิ่มความสามารถให้กับ `TaggedLogging` เพื่ออนุญาตให้สร้างตัวเรกคอร์เดอร์ได้หลายครั้งเพื่อให้ไม่แชร์แท็กกับกัน
    ([Pull Request](https://github.com/rails/rails/pull/9065))

เครดิต
-------

ดู
[รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](https://contributors.rubyonrails.org/) สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและแข็งแกร่ง ยินดีด้วยทุกคน

[railties]:       https://github.com/rails/rails/blob/5-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-0-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
