**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b95e1fead49349e056e5faed88aa5760
การอัปเกรด Ruby on Rails
=======================

เอกสารนี้ให้ขั้นตอนที่ต้องทำเมื่อคุณอัปเกรดแอปพลิเคชันของคุณไปยังเวอร์ชันใหม่ของ Ruby on Rails ขั้นตอนเหล่านี้ยังมีให้ในเอกสารการเปิดตัวแต่ละรุ่น

--------------------------------------------------------------------------------

คำแนะนำทั่วไป
--------------

ก่อนที่จะพยายามอัปเกรดแอปพลิเคชันที่มีอยู่แล้ว คุณควรแน่ใจว่าคุณมีเหตุผลที่ดีในการอัปเกรด คุณต้องดึงดูดปัจจัยหลายอย่าง: ความต้องการใช้งานคุณลักษณะใหม่ ความยากลำบากที่เพิ่มขึ้นในการค้นหาการสนับสนุนสำหรับโค้ดเก่า และเวลาและทักษะที่คุณมีอยู่ เพื่อเรียกชื่อเพียงไม่กี่อย่าง

### การทดสอบความครอบคลุม

วิธีที่ดีที่สุดในการแน่ใจว่าแอปพลิเคชันของคุณยังทำงานได้หลังจากการอัปเกรดคือการมีการทดสอบที่ดีก่อนที่คุณจะเริ่มกระบวนการ หากคุณไม่มีการทดสอบอัตโนมัติที่ใช้งานส่วนใหญ่ของแอปพลิเคชันของคุณ คุณจะต้องใช้เวลาในการทดสอบด้วยตนเองส่วนที่เปลี่ยนแปลง ในกรณีของการอัปเกรด Rails นั่นหมายความว่าทุกส่วนของฟังก์ชันในแอปพลิเคชัน ทำให้ตัวเองง่ายขึ้นและตรวจสอบให้แน่ใจว่าการทดสอบของคุณเป็นที่ดี _ก่อนที่_ คุณจะเริ่มอัปเกรด

### เวอร์ชันของ Ruby

Rails มักจะใช้เวอร์ชัน Ruby ที่เปิดตัวล่าสุดเมื่อมีการเปิดตัว:

* Rails 7 ต้องการ Ruby 2.7.0 หรือใหม่กว่า
* Rails 6 ต้องการ Ruby 2.5.0 หรือใหม่กว่า
* Rails 5 ต้องการ Ruby 2.2.2 หรือใหม่กว่า

เป็นไอเดียที่ดีที่จะอัปเกรด Ruby และ Rails แยกกัน อัปเกรดไปยัง Ruby ล่าสุดที่คุณสามารถทำได้ก่อน แล้วจึงอัปเกรด Rails

### กระบวนการอัปเกรด

เมื่อเปลี่ยนเวอร์ชันของ Rails ควรเคลื่อนไหวช้าๆ หนึ่งเวอร์ชันย่อยต่อหนึ่งเวอร์ชัน เพื่อให้ใช้ประโยชน์จากคำเตือนการเลิกใช้ได้ดี Rails หมายเลขเวอร์ชันมีรูปแบบเป็น Major.Minor.Patch รุ่น Major และ Minor อนุญาตให้ทำการเปลี่ยนแปลงกับ API สาธารณะ ซึ่งอาจทำให้เกิดข้อผิดพลาดในแอปพลิเคชันของคุณ รุ่น Patch เฉพาะรวมถึงการแก้ไขข้อบกพร่องเท่านั้นและไม่เปลี่ยนแปลง API สาธารณะใดๆ

กระบวนการควรเป็นดังนี้:

1. เขียนการทดสอบและตรวจสอบให้ผ่าน
2. เคลื่อนย้ายไปยังเวอร์ชัน Patch ล่าสุดหลังจากเวอร์ชันปัจจุบันของคุณ
3. แก้ไขการทดสอบและคุณสมบัติที่เลิกใช้
4. เคลื่อนย้ายไปยังเวอร์ชัน Patch ล่าสุดของเวอร์ชันย่อยถัดไป

ทำซ้ำกระบวนการนี้จนกว่าคุณจะได้รับเวอร์ชัน Rails ที่ต้องการ

#### เคลื่อนย้ายระหว่างเวอร์ชัน

เพื่อเคลื่อนย้ายระหว่างเวอร์ชัน:

1. เปลี่ยนหมายเลขเวอร์ชันของ Rails ใน `Gemfile` และเรียกใช้ `bundle update`
2. เปลี่ยนเวอร์ชันสำหรับแพคเกจ JavaScript ของ Rails ใน `package.json` และเรียกใช้ `yarn install` หากใช้งานบน Webpacker
3. เรียกใช้งาน [งานอัปเดต](#the-update-task)
4. เรียกใช้งานการทดสอบของคุณ
คุณสามารถค้นหารายการของ Rails gems ทั้งหมดที่ได้รับการเผยแพร่ [ที่นี่](https://rubygems.org/gems/rails/versions) 

### งานอัปเดต

Rails มีคำสั่ง `rails app:update` หลังจากอัปเดตเวอร์ชัน Rails ใน `Gemfile` ให้รันคำสั่งนี้
นี้จะช่วยให้คุณสร้างไฟล์ใหม่และเปลี่ยนแปลงไฟล์เก่าในเซสชันแบบโต้ตอบ

```bash
$ bin/rails app:update
       exist  config
    conflict  config/application.rb
Overwrite /myapp/config/application.rb? (enter "h" for help) [Ynaqdh]
       force  config/application.rb
      create  config/initializers/new_framework_defaults_7_0.rb
...
```

อย่าลืมตรวจสอบความแตกต่างเพื่อดูว่ามีการเปลี่ยนแปลงที่ไม่คาดคิดหรือไม่

### กำหนดค่าเริ่มต้นของ Framework

เวอร์ชัน Rails ใหม่อาจมีค่าเริ่มต้นของการกำหนดค่าที่แตกต่างจากเวอร์ชันก่อนหน้านี้ อย่างไรก็ตามหลังจากทำตามขั้นตอนที่อธิบายไว้ข้างต้นแล้ว แอปพลิเคชันของคุณจะยังคงทำงานด้วยค่าเริ่มต้นของการกำหนดค่าจากเวอร์ชัน Rails *ก่อนหน้านี้* นั่นเพราะค่าสำหรับ `config.load_defaults` ใน `config/application.rb` ยังไม่ได้เปลี่ยนแปลง

เพื่อให้คุณสามารถอัปเกรดเป็นค่าเริ่มต้นใหม่ได้ทีละส่วน งานอัปเดตจึงสร้างไฟล์ `config/initializers/new_framework_defaults_X.Y.rb` (ด้วยเวอร์ชัน Rails ที่ต้องการในชื่อไฟล์) คุณควรเปิดใช้งานค่าเริ่มต้นการกำหนดค่าใหม่โดยการเอาคอมเมนต์ออกในไฟล์นี้ สามารถทำได้เป็นขั้นตอนที่เกิดขึ้นหลายครั้งในการปรับปรุง หลังจากแอปพลิเคชันของคุณพร้อมที่จะทำงานด้วยค่าเริ่มต้นใหม่ คุณสามารถลบไฟล์นี้และเปลี่ยนค่า `config.load_defaults`

การอัปเกรดจาก Rails 7.0 เป็น Rails 7.1
-------------------------------------

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการเปลี่ยนแปลงที่ทำใน Rails 7.1 โปรดดู [release notes](7_1_release_notes.html).

### พาธที่โหลดอัตโนมัติไม่ได้อยู่ในเส้นทางการโหลด

เริ่มต้นจาก Rails 7.1 เส้นทางที่จัดการโดย autoloader จะไม่ถูกเพิ่มเข้าไปใน `$LOAD_PATH` อีกต่อไป
นี้หมายความว่าไม่สามารถโหลดด้วยการเรียกใช้ `require` ด้วยตนเองได้ แต่สามารถอ้างอิงคลาสหรือโมดูลได้แทน

การลดขนาดของ `$LOAD_PATH` จะเร่งความเร็วในการเรียกใช้ `require` สำหรับแอปที่ไม่ใช้ `bootsnap` และลดขนาดของแคช `bootsnap` สำหรับแอปอื่น ๆ

### `ActiveStorage::BaseController` ไม่ได้รวมความสัมพันธ์การสตรีม

คอนโทรลเลอร์แอปพลิเคชันที่สืบทอดมาจาก `ActiveStorage::BaseController` และใช้การสตรีมเพื่อดำเนินการเซิร์ฟเซอร์ไฟล์ที่กำหนดเองต้องรวมโมดูล `ActiveStorage::Streaming` โดยชัดเจน

### `MemCacheStore` และ `RedisCacheStore` ใช้การจัดการเชื่อมต่อแบบ connection pooling เป็นค่าเริ่มต้น

ได้เพิ่ม `connection_pool` เป็น dependency ของ gem `activesupport`
และ `MemCacheStore` และ `RedisCacheStore` ใช้การจัดการเชื่อมต่อแบบ connection pooling เป็นค่าเริ่มต้น

หากคุณไม่ต้องการใช้ connection pooling ให้ตั้งค่า `:pool` เป็น `false` เมื่อกำหนดค่า cache store ของคุณ:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

ดูเพิ่มเติมใน [คู่มือการใช้งานแคชกับ Rails](https://guides.rubyonrails.org/v7.1/caching_with_rails.html#connection-pool-options) สำหรับข้อมูลเพิ่มเติม

### `SQLite3Adapter` ตั้งค่าให้ใช้ในโหมดสตริงที่เข้มงวด
การใช้โหมดสตริงที่เข้มงวดจะปิดใช้งานตัวอักษรสตริงที่ใช้เครื่องหมายคำพูดคู่

SQLite มีความผิดปกติบางอย่างเกี่ยวกับตัวอักษรสตริงที่ใช้เครื่องหมายคำพูดคู่
ก่อนอื่น มันจะพยายามพิจารณาตัวอักษรสตริงที่ใช้เครื่องหมายคำพูดคู่เป็นชื่อตัวระบุ แต่หากไม่มี
จากนั้นมันจะพิจารณาเป็นตัวอักษรสตริง ด้วยเหตุนี้ การพิมพ์ผิดสามารถเกิดขึ้นได้โดยไม่เสียเสียง
ตัวอย่างเช่น สามารถสร้างดัชนีสำหรับคอลัมน์ที่ไม่มีอยู่ได้
ดูรายละเอียดเพิ่มเติมที่ [เอกสาร SQLite](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted)

หากคุณไม่ต้องการใช้ `SQLite3Adapter` ในโหมดเข้มงวด คุณสามารถปิดใช้งานพฤติกรรมนี้ได้:

```ruby
# config/application.rb
config.active_record.sqlite3_adapter_strict_strings_by_default = false
```

### สนับสนุนพาธหลายรายการสำหรับ `ActionMailer::Preview`

ตัวเลือก `config.action_mailer.preview_path` ถูกยกเลิกแล้วและใช้แทนด้วย `config.action_mailer.preview_paths` การเพิ่มพาธเข้ากับตัวเลือกการกำหนดค่านี้จะทำให้ใช้พาธเหล่านั้นในการค้นหาการแสดงตัวอย่างเมลเลอร์

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### `config.i18n.raise_on_missing_translations = true` ตอนนี้จะเกิดข้อผิดพลาดเมื่อข้อความที่แปลไม่พบ

ก่อนหน้านี้มันจะเกิดข้อผิดพลาดเมื่อเรียกใช้ในมุมมองหรือควบคุม ตอนนี้มันจะเกิดข้อผิดพลาดเมื่อ `I18n.t` ได้รับคีย์ที่ไม่รู้จัก

```ruby
# ด้วย config.i18n.raise_on_missing_translations = true

# ในมุมมองหรือควบคุม:
t("missing.key") # เกิดข้อผิดพลาดในเวอร์ชัน 7.0, เกิดข้อผิดพลาดในเวอร์ชัน 7.1
I18n.t("missing.key") # ไม่เกิดข้อผิดพลาดในเวอร์ชัน 7.0, เกิดข้อผิดพลาดในเวอร์ชัน 7.1

# ทุกที่:
I18n.t("missing.key") # ไม่เกิดข้อผิดพลาดในเวอร์ชัน 7.0, เกิดข้อผิดพลาดในเวอร์ชัน 7.1
```

หากคุณไม่ต้องการพฤติกรรมนี้ คุณสามารถตั้งค่า `config.i18n.raise_on_missing_translations = false`:

```ruby
# ด้วย config.i18n.raise_on_missing_translations = false

# ในมุมมองหรือควบคุม:
t("missing.key") # ไม่เกิดข้อผิดพลาดในเวอร์ชัน 7.0, ไม่เกิดข้อผิดพลาดในเวอร์ชัน 7.1
I18n.t("missing.key") # ไม่เกิดข้อผิดพลาดในเวอร์ชัน 7.0, ไม่เกิดข้อผิดพลาดในเวอร์ชัน 7.1

# ทุกที่:
I18n.t("missing.key") # ไม่เกิดข้อผิดพลาดในเวอร์ชัน 7.0, ไม่เกิดข้อผิดพลาดในเวอร์ชัน 7.1
```

หรือในกรณีอื่น ๆ คุณสามารถปรับแต่ง `I18n.exception_handler` ดูข้อมูลเพิ่มเติมที่ [คู่มือ i18n](https://guides.rubyonrails.org/v7.1/i18n.html#using-different-exception-handlers)

การอัปเกรดจาก Rails 6.1 เป็น Rails 7.0
-------------------------------------

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการเปลี่ยนแปลงที่ทำใน Rails 7.0 โปรดดู [บันทึกการเปิดตัว](7_0_release_notes.html)

### พฤติกรรมการใช้งานของ `ActionView::Helpers::UrlHelper#button_to` เปลี่ยนแปลง

เริ่มต้นจาก Rails 7.0 `button_to` จะแสดงแท็ก `form` ด้วย HTTP verb `patch` หากใช้วัตถุ Active Record ที่ถูกบันทึกไว้ในการสร้าง URL ของปุ่ม
หากต้องการเก็บพฤติกรรมปัจจุบัน คุณควรระบุ `method:` โดยชัดเจน:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)], method: :post)
```

หรือใช้เฮลเปอร์ในการสร้าง URL:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", my_custom_post_action_on_workshop_workshop_path(Workshop.find(1)))
```

### Spring

หากแอปพลิเคชันของคุณใช้ Spring คุณต้องอัปเกรดเป็นเวอร์ชัน 3.0.0 หรือสูงกว่า มิเช่นนั้นคุณจะได้รับ

```
undefined method `mechanism=' for ActiveSupport::Dependencies:Module
```

นอกจากนี้ ตรวจสอบให้แน่ใจว่า [`config.cache_classes`][] ถูกตั้งค่าเป็น `false` ใน `config/environments/test.rb`
### Sprockets เป็นการติดตั้งที่ไม่จำเป็นแล้ว

แพ็คเกจ `rails` ไม่ได้ขึ้นอยู่กับ `sprockets-rails` อีกต่อไป หากแอปพลิเคชันของคุณยังต้องการใช้ Sprockets โปรดตรวจสอบให้แน่ใจว่าเพิ่ม `sprockets-rails` เข้าไปใน Gemfile ของคุณ

```ruby
gem "sprockets-rails"
```

### แอปพลิเคชันต้องทำงานในโหมด `zeitwerk`

แอปพลิเคชันที่ยังทำงานในโหมด `classic` ต้องสลับไปใช้โหมด `zeitwerk` โปรดตรวจสอบคู่มือ [Classic to Zeitwerk HOWTO](https://guides.rubyonrails.org/v7.0/classic_to_zeitwerk_howto.html) เพื่อดูรายละเอียด

### ตัวกำหนด `config.autoloader=` ถูกลบออก

ใน Rails 7 ไม่มีจุดกำหนดค่าในการตั้งค่าโหมด autoloading แล้ว `config.autoloader=` ถูกลบออกแล้ว หากคุณตั้งค่าเป็น `:zeitwerk` ด้วยเหตุผลใดๆ แค่ลบออกเอง

### ได้ลบ API ส่วนตัวของ `ActiveSupport::Dependencies` ออกแล้ว

API ส่วนตัวของ `ActiveSupport::Dependencies` ถูกลบออกแล้ว รวมถึงเมธอดเช่น `hook!`, `unhook!`, `depend_on`, `require_or_load`, `mechanism` และอื่นๆ

บางส่วนที่สำคัญ:

* หากคุณใช้ `ActiveSupport::Dependencies.constantize` หรือ `ActiveSupport::Dependencies.safe_constantize` เพียงแค่เปลี่ยนมันเป็น `String#constantize` หรือ `String#safe_constantize`

  ```ruby
  ActiveSupport::Dependencies.constantize("User") # ไม่สามารถทำได้อีกต่อไป
  "User".constantize # 👍
  ```

* การใช้ `ActiveSupport::Dependencies.mechanism` ทั้งตัวอ่านและตัวเขียน ต้องถูกแทนที่ด้วยการเข้าถึง `config.cache_classes` ตามที่เหมาะสม

* หากคุณต้องการติดตามกิจกรรมของ autoloader `ActiveSupport::Dependencies.verbose=` ไม่สามารถใช้ได้อีกต่อไป แค่เพิ่ม `Rails.autoloaders.log!` ใน `config/application.rb`

คลาสหรือโมดูลภายในที่เป็นเครื่องมือย่อยก็หายไป เช่น `ActiveSupport::Dependencies::Reference`, `ActiveSupport::Dependencies::Blamable` และอื่นๆ

### Autoloading ระหว่างการเริ่มต้น

แอปพลิเคชันที่โหลดค่าคงที่ที่สามารถโหลดใหม่ได้ระหว่างการเริ่มต้นนอกบล็อก `to_prepare` จะทำให้ค่าคงที่เหล่านั้นถูกยกเลิกและมีการแจ้งเตือนนี้ตั้งแต่ Rails 6.0:

```
DEPRECATION WARNING: Initialization autoloaded the constant ....

การทำเช่นนี้ถูกยกเลิกแล้ว การโหลดใหม่ระหว่างการเริ่มต้นจะเป็นเงื่อนไขข้อผิดพลาดในเวอร์ชันที่จะมาของ Rails

...
```

หากคุณยังได้รับการเตือนนี้ในบันทึก โปรดตรวจสอบส่วนเกี่ยวกับ autoloading เมื่อแอปพลิเคชันเริ่มต้นในคู่มือ [autoloading guide](https://guides.rubyonrails.org/v7.0/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots) มิฉะนั้นคุณจะได้รับ `NameError` ใน Rails 7

### ความสามารถในการกำหนดค่า `config.autoload_once_paths`

[`config.autoload_once_paths`][] สามารถกำหนดได้ในส่วนของคลาสแอปพลิเคชันที่กำหนดไว้ใน `config/application.rb` หรือในการกำหนดค่าสำหรับ environment ใน `config/environments/*`

อย่างเดียวกัน เอนจินสามารถกำหนดค่าส่วนนั้นในส่วนของคลาสเอนจินหรือในการกำหนดค่าสำหรับ environment

หลังจากนั้น คอลเลกชันนั้นจะถูกแช่แข็งและคุณสามารถโหลดโดยใช้ autoload จากเส้นทางเหล่านั้นได้ โดยเฉพาะในขณะที่เริ่มต้น พวกเขาถูกจัดการโดย autoloader `Rails.autoloaders.once` ซึ่งไม่มีการโหลดใหม่ เพียงแค่โหลดอัตโนมัติ/โหลดเร็ว

หากคุณกำหนดค่าการตั้งค่านี้หลังจากการกำหนดค่าสภาพแวดล้อมได้รับการประมวลผลและได้รับ `FrozenError` โปรดย้ายโค้ดของคุณเท่านั้น
### `ActionDispatch::Request#content_type` ตอนนี้จะส่งค่า Content-Type header ออกมาเป็นไปตามที่กำหนด

ก่อนหน้านี้ `ActionDispatch::Request#content_type` จะส่งค่าที่ไม่รวมส่วน charset
พฤติกรรมนี้ถูกเปลี่ยนให้ส่งค่า Content-Type header ที่มีส่วน charset ออกมาเป็นไปตามที่กำหนด

หากคุณต้องการเฉพาะ MIME type เท่านั้น โปรดใช้ `ActionDispatch::Request#media_type` แทน

ก่อนหน้านี้:

```ruby
request = ActionDispatch::Request.new("CONTENT_TYPE" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv"
```

หลังจากนี้:

```ruby
request = ActionDispatch::Request.new("Content-Type" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv; header=present; charset=utf-16"
request.media_type   #=> "text/csv"
```

### การเปลี่ยนคลาส digest ของ key generator ต้องการการหมุนเวียนคุกกี้

คลาส digest เริ่มต้นสำหรับ key generator กำลังเปลี่ยนจาก SHA1 เป็น SHA256
นี้จะมีผลต่อข้อความที่ถูกเข้ารหัสที่ถูกสร้างขึ้นโดย Rails รวมถึงคุกกี้ที่ถูกเข้ารหัส

เพื่อสามารถอ่านข้อความโดยใช้คลาส digest เก่าได้ จำเป็นต้องลงทะเบียน rotator
หากละเลยขั้นตอนนี้อาจทำให้ผู้ใช้มีการยกเลิกเซสชันของพวกเขาในระหว่างการอัปเกรด

ต่อไปนี้คือตัวอย่าง rotator สำหรับคุกกี้ที่ถูกเข้ารหัสและลงลายมือ

```ruby
# config/initializers/cookie_rotator.rb
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    authenticated_encrypted_cookie_salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_cookie_salt = Rails.application.config.action_dispatch.signed_cookie_salt

    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    key_len = ActiveSupport::MessageEncryptor.key_len

    old_encrypted_secret = key_generator.generate_key(authenticated_encrypted_cookie_salt, key_len)
    old_signed_secret = key_generator.generate_key(signed_cookie_salt)

    cookies.rotate :encrypted, old_encrypted_secret
    cookies.rotate :signed, old_signed_secret
  end
end
```

### คลาส digest สำหรับ ActiveSupport::Digest เปลี่ยนเป็น SHA256

คลาส digest เริ่มต้นสำหรับ ActiveSupport::Digest กำลังเปลี่ยนจาก SHA1 เป็น SHA256
นี้จะมีผลต่อสิ่งที่เช่น Etags ที่จะเปลี่ยนและคีย์แคชด้วย
การเปลี่ยนแปลงเหล่านี้อาจมีผลต่ออัตราการโหลดแคช ดังนั้นโปรดระมัดระวังและตรวจสอบเมื่ออัปเกรดไปยังแฮชใหม่

### รูปแบบการซีเรียลไซซ์ชันใหม่ของ ActiveSupport::Cache

มีการเปลี่ยนรูปแบบการซีเรียลไซซ์ชันที่เร็วกว่าและมีขนาดเล็กลง

ในการเปิดใช้งาน คุณต้องตั้งค่า `config.active_support.cache_format_version = 7.0`:

```ruby
# config/application.rb

config.load_defaults 6.1
config.active_support.cache_format_version = 7.0
```

หรือง่ายๆ:

```ruby
# config/application.rb

config.load_defaults 7.0
```

อย่างไรก็ตาม แอปพลิเคชัน Rails 6.1 ไม่สามารถอ่านรูปแบบการซีเรียลไซซ์ชันใหม่นี้ได้
ดังนั้นเพื่อให้การอัปเกรดเป็นไปได้ด้วยราบรื่น คุณต้องเริ่มต้นการอัปเกรด Rails 7.0 ของคุณกับ
`config.active_support.cache_format_version = 6.1` และเมื่อทุกโปรเซสของ Rails ได้รับการอัปเดตแล้ว
คุณสามารถตั้งค่า `config.active_support.cache_format_version = 7.0` ได้

Rails 7.0 สามารถอ่านทั้งสองรูปแบบได้ดังนั้นแคชจะไม่ถูกยกเลิกในระหว่างการอัปเกรด

### การสร้างรูปภาพตัวอย่างการแสดงตัวอย่างวิดีโอใน Active Storage

การสร้างรูปภาพตัวอย่างการแสดงตัวอย่างวิดีโอในปัจจุบันใช้การตรวจจับการเปลี่ยนแปลงฉากของ FFmpeg เพื่อสร้างรูปภาพตัวอย่างที่มีความหมายมากขึ้น ก่อนหน้านี้จะใช้เฟรมแรกของวิดีโอ และส่งผลให้เกิดปัญหาหากวิดีโอเริ่มต้นจากสีดำ การเปลี่ยนแปลงนี้ต้องการ FFmpeg เวอร์ชัน 3.4 ขึ้นไป
### ตัวประมวลผลตัวแปรเริ่มต้นของ Active Storage ถูกเปลี่ยนเป็น `:vips`

สำหรับแอปใหม่ การแปลงภาพจะใช้ libvips แทน ImageMagick ซึ่งจะลดเวลาในการสร้างตัวแปรรูปแบบและการใช้งาน CPU และหน่วยความจำ ทำให้เวลาตอบสนองในแอปที่ใช้ Active Storage เพื่อให้บริการรูปภาพดีขึ้น

ตัวเลือก `:mini_magick` ไม่ได้ถูกยกเลิก ดังนั้นสามารถใช้ต่อได้

ในการย้ายแอปที่มีอยู่ไปยัง libvips ให้ตั้งค่า:

```ruby
Rails.application.config.active_storage.variant_processor = :vips
```

จากนั้นคุณจะต้องเปลี่ยนรหัสการแปลงภาพที่มีอยู่เป็นแมโคร `image_processing` และแทนที่ตัวเลือกของ ImageMagick ด้วยตัวเลือกของ libvips

#### แทนที่ resize ด้วย resize_to_limit

```diff
- variant(resize: "100x")
+ variant(resize_to_limit: [100, nil])
```

หากคุณไม่ทำเช่นนั้นเมื่อคุณสลับไปใช้ vips คุณจะเห็นข้อผิดพลาดนี้: `no implicit conversion to float from string`.

#### ใช้อาร์เรย์เมื่อตัดภาพ

```diff
- variant(crop: "1920x1080+0+0")
+ variant(crop: [0, 0, 1920, 1080])
```

หากคุณไม่ทำเช่นนั้นเมื่อย้ายไปใช้ vips คุณจะเห็นข้อผิดพลาดต่อไปนี้: `unable to call crop: you supplied 2 arguments, but operation needs 5`.

#### จำกัดค่าการตัดภาพของคุณ:

Vips เข้มงวดกว่า ImageMagick เมื่อเรื่องของการตัดภาพ:

1. มันจะไม่ตัดภาพหาก `x` และ/หรือ `y` เป็นค่าลบ เช่น: `[-10, -10, 100, 100]`
2. มันจะไม่ตัดภาพหากตำแหน่ง (`x` หรือ `y`) บวกกับขนาดการตัดภาพ (`ความกว้าง`, `ความสูง`) มากกว่าภาพ เช่น: ภาพขนาด 125x125 และการตัดภาพ `[50, 50, 100, 100]`

หากคุณไม่ทำเช่นนั้นเมื่อย้ายไปใช้ vips คุณจะเห็นข้อผิดพลาดต่อไปนี้: `extract_area: bad extract area`

#### ปรับสีพื้นหลังที่ใช้สำหรับ `resize_and_pad`

Vips ใช้สีดำเป็นสีพื้นหลังเริ่มต้นของ `resize_and_pad` แทนสีขาวเหมือน ImageMagick แก้ไขโดยใช้ตัวเลือก `background`:

```diff
- variant(resize_and_pad: [300, 300])
+ variant(resize_and_pad: [300, 300, background: [255]])
```

#### ลบการหมุนภาพที่ขึ้นอยู่กับ EXIF

Vips จะหมุนภาพโดยอัตโนมัติโดยใช้ค่า EXIF เมื่อประมวลผลตัวแปร หากคุณเก็บค่าการหมุนจากภาพที่อัปโหลดโดยผู้ใช้เพื่อใช้การหมุนด้วย ImageMagick คุณต้องหยุดทำเช่นนั้น:

```diff
- variant(format: :jpg, rotate: rotation_value)
+ variant(format: :jpg)
```

#### แทนที่ monochrome ด้วย colourspace

Vips ใช้ตัวเลือกที่แตกต่างกันเพื่อทำภาพขาวดำ:

```diff
- variant(monochrome: true)
+ variant(colourspace: "b-w")
```

#### เปลี่ยนไปใช้ตัวเลือกของ libvips ในการบีบอัดภาพ

JPEG

```diff
- variant(strip: true, quality: 80, interlace: "JPEG", sampling_factor: "4:2:0", colorspace: "sRGB")
+ variant(saver: { strip: true, quality: 80, interlace: true })
```
PNG

```diff
- variant(strip: true, quality: 75)
+ variant(saver: { strip: true, compression: 9 })
```

WEBP

```diff
- variant(strip: true, quality: 75, define: { webp: { lossless: false, alpha_quality: 85, thread_level: 1 } })
+ variant(saver: { strip: true, quality: 75, lossless: false, alpha_q: 85, reduction_effort: 6, smart_subsample: true })
```

GIF

```diff
- variant(layers: "Optimize")
+ variant(saver: { optimize_gif_frames: true, optimize_gif_transparency: true })
```

#### นำไปใช้งานจริง

Active Storage จะเข้ารหัสลงใน URL สำหรับรูปภาพรายการการเปลี่ยนแปลงที่ต้องทำ
หากแอปของคุณกำลังแคช URL เหล่านี้ รูปภาพของคุณจะเสียหายหลังจากคุณนำโค้ดใหม่ไปใช้งานในการดำเนินการ
เนื่องจากเหตุนี้คุณต้องยกเลิกแคชคีย์ที่ได้รับผลกระทบ

ตัวอย่างเช่น หากคุณมีอะไรแบบนี้ในมุมมอง:

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= image_tag product.cover_photo.variant(resize: "200x") %>
  <% end %>
<% end %>
```

คุณสามารถยกเลิกแคชได้โดยการแตะผลิตภัณฑ์หรือเปลี่ยนคีย์แคช:

```erb
<% @products.each do |product| %>
  <% cache ["v2", product] do %>
    <%= image_tag product.cover_photo.variant(resize_to_limit: [200, nil]) %>
  <% end %>
<% end %>
```

### เวอร์ชัน Rails รวมอยู่ในการถ่ายโอนแบบ Active Record

Rails 7.0 เปลี่ยนค่าเริ่มต้นของบางประเภทคอลัมน์ ในการอัปเกรดแอปพลิเคชันจาก 6.1 เป็น 7.0
เพื่อหลีกเลี่ยงการโหลด schema ปัจจุบันโดยใช้ค่าเริ่มต้น 7.0 Rails ตอนนี้รวมเวอร์ชันของเฟรมเวิร์กในการถ่ายโอนแบบ schema

ก่อนโหลด schema ครั้งแรกใน Rails 7.0 ตรวจสอบให้แน่ใจว่าทำการเรียกใช้ `rails app:update` เพื่อให้แน่ใจว่า
เวอร์ชันของ schema รวมอยู่ในการถ่ายโอนแบบ schema

ไฟล์ schema จะมีลักษณะดังนี้:

```ruby
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[6.1].define(version: 2022_01_28_123512) do
```
หมายเหตุ: ครั้งแรกที่คุณทำการดัมพ์สเคมาด้วย Rails 7.0 คุณจะเห็นการเปลี่ยนแปลงมากมายในไฟล์นั้น รวมถึงข้อมูลคอลัมน์บางส่วน ตรวจสอบเนื้อหาไฟล์สเคมาใหม่และทำการ commit ไปยังรีโพสิทอรีของคุณ

การอัพเกรดจาก Rails 6.0 เป็น Rails 6.1
-----------------------------------------

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการเปลี่ยนแปลงที่ทำใน Rails 6.1 โปรดดู [release notes](6_1_release_notes.html).

### ค่าที่ `Rails.application.config_for` ส่งคืนไม่รองรับการเข้าถึงด้วยคีย์แบบสตริงอีกต่อไป

กำหนดไฟล์กำหนดค่าดังนี้:

```yaml
# config/example.yml
development:
  options:
    key: value
```

```ruby
Rails.application.config_for(:example).options
```

เคยส่งคืนแฮชที่คุณสามารถเข้าถึงค่าด้วยคีย์แบบสตริงได้ แต่นั่นถูกยกเลิกในเวอร์ชัน 6.0 และตอนนี้ไม่ทำงานอีกต่อไป

คุณสามารถเรียกใช้ `with_indifferent_access` บนค่าที่ส่งคืนจาก `config_for` หากคุณยังต้องการเข้าถึงค่าด้วยคีย์แบบสตริง เช่น:

```ruby
Rails.application.config_for(:example).with_indifferent_access.dig('options', 'key')
```

### Content-Type ของ Response เมื่อใช้ `respond_to#any`

ส่วนหัว Content-Type ที่ส่งคืนในการตอบกลับอาจแตกต่างจากสิ่งที่ Rails 6.0 ส่งคืน โดยเฉพาะอย่างยิ่งหากแอปพลิเคชันของคุณใช้ `respond_to { |format| format.any }` ตอนนี้ Content-Type จะขึ้นอยู่กับบล็อกที่กำหนดแทนที่รูปแบบของคำขอ

ตัวอย่าง:

```ruby
def my_action
  respond_to do |format|
    format.any { render(json: { foo: 'bar' }) }
  end
end
```

```ruby
get('my_action.csv')
```

พฤติกรรมก่อนหน้าคือการส่งคืน Content-Type ของ `text/csv` ซึ่งไม่ถูกต้องเนื่องจากมีการแสดงผล JSON แต่พฤติกรรมปัจจุบันคืน Content-Type ของ `application/json` ที่ถูกต้อง

หากแอปพลิเคชันของคุณพึงพอใจกับพฤติกรรมที่ไม่ถูกต้องก่อนหน้านี้ คุณสามารถระบุรูปแบบที่แอคชันของคุณยอมรับได้ เช่น:

```ruby
format.any(:xml, :json) { render request.format.to_sym => @people }
```

### `ActiveSupport::Callbacks#halted_callback_hook` ตอนนี้รับอาร์กิวเมนต์ที่สอง

Active Support ช่วยให้คุณสามารถแทนที่ `halted_callback_hook` เมื่อ callback หยุดทำงานในเชน วิธีนี้ตอนนี้รับอาร์กิวเมนต์ที่สองซึ่งเป็นชื่อของ callback ที่ถูกหยุดทำงาน หากคุณมีคลาสที่แทนที่เมธอดนี้ ตรวจสอบให้แน่ใจว่ามันยอมรับอาร์กิวเมนต์สองตัว โปรดทราบว่านี่เป็นการเปลี่ยนแปลงที่ทำให้เกิดข้อผิดพลาดโดยไม่มีการเตือนล่วงหน้า (เพื่อเพิ่มประสิทธิภาพ)

ตัวอย่าง:

```ruby
class Book < ApplicationRecord
  before_save { throw(:abort) }
  before_create { throw(:abort) }

  def halted_callback_hook(filter, callback_name) # => เมธอดนี้ตอนนี้ยอมรับอาร์กิวเมนต์ 2 ตัวแทนที่ 1
    Rails.logger.info("Book couldn't be #{callback_name}d")
  end
end
```

### เมธอด `helper` ในคลาสคอนโทรลเลอร์ใช้ `String#constantize`

ในทางแนวคิดก่อนหน้า Rails 6.1

```ruby
helper "foo/bar"
```

จะได้ผลลัพธ์เป็น

```ruby
require_dependency "foo/bar_helper"
module_name = "foo/bar_helper".camelize
module_name.constantize
```

ตอนนี้มันทำอย่างนี้แทน:

```ruby
prefix = "foo/bar".camelize
"#{prefix}Helper".constantize
```

การเปลี่ยนแปลงนี้เป็นเวอร์ชันที่เข้ากันได้ย้อนกลับสำหรับส่วนใหญ่ของแอปพลิเคชัน ในกรณีนี้คุณไม่จำเป็นต้องทำอะไรเพิ่มเติม
อย่างไรก็ตาม ความควบคุมสามารถกำหนดค่า `helpers_path` เพื่อชี้ไปยังไดเรกทอรีใน `$LOAD_PATH` ที่ไม่ได้อยู่ใน autoload paths ได้ แต่กรณีการใช้งานนี้ไม่ได้รับการสนับสนุนโดยอัตโนมัติแล้ว หากโมดูลช่วยเหลือไม่สามารถโหลดอัตโนมัติได้ แอปพลิเคชันจะต้องรับผิดชอบในการโหลดโมดูลนั้นก่อนที่จะเรียกใช้ `helper` 

### การเปลี่ยนเส้นทางจาก HTTP เป็น HTTPS จะใช้รหัสสถานะ HTTP 308

รหัสสถานะ HTTP เริ่มต้นที่ใช้ใน `ActionDispatch::SSL` เมื่อเปลี่ยนเส้นทางคำขอที่ไม่ใช่ GET/HEAD จาก HTTP เป็น HTTPS ได้ถูกเปลี่ยนเป็น `308` ตามที่กำหนดใน https://tools.ietf.org/html/rfc7538

### Active Storage ต้องการ Image Processing ตอนนี้

เมื่อประมวลผลตัวแปรและ Active Storage ต้องการ [image_processing gem](https://github.com/janko/image_processing) ที่รวมมาแทนการใช้ `mini_magick` โดยตรง การปรับแต่ง Image Processing จะถูกกำหนดค่าให้ใช้ `mini_magick` ในภายใน ดังนั้นวิธีที่ง่ายที่สุดในการอัปเกรดคือการแทนที่ gem `mini_magick` ด้วย gem `image_processing` และตรวจสอบให้แน่ใจว่าลบการใช้งาน `combine_options` ที่ระบุโดยชัดเจนออกเนื่องจากไม่จำเป็นอีกต่อไป

สำหรับความอ่านง่าย คุณอาจต้องการเปลี่ยน `resize` ที่เป็นการเรียกใช้งานตรงไปยัง macros ของ `image_processing` ตัวอย่างเช่น แทนที่:

```ruby
video.preview(resize: "100x100")
video.preview(resize: "100x100>")
video.preview(resize: "100x100^")
```

คุณสามารถทำได้ดังนี้:

```ruby
video.preview(resize_to_fit: [100, 100])
video.preview(resize_to_limit: [100, 100])
video.preview(resize_to_fill: [100, 100])
```

### คลาสใหม่ `ActiveModel::Error`

ข้อผิดพลาดตอนนี้เป็นอินสแตนซ์ของคลาสใหม่ `ActiveModel::Error` โดยมีการเปลี่ยนแปลงใน API บางส่วนของการใช้งานอาจเกิดข้อผิดพลาดขึ้นขึ้นอยู่กับวิธีการจัดการข้อผิดพลาด ในขณะที่อื่นๆ จะพิมพ์คำเตือนการเลิกใช้งานเพื่อแก้ไขใน Rails 7.0

ข้อมูลเพิ่มเติมเกี่ยวกับการเปลี่ยนแปลงนี้และรายละเอียดเกี่ยวกับการเปลี่ยนแปลงใน API สามารถดูได้ที่ [PR นี้](https://github.com/rails/rails/pull/32313)

การอัปเกรดจาก Rails 5.2 เป็น Rails 6.0
-------------------------------------

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการเปลี่ยนแปลงที่ทำใน Rails 6.0 โปรดดู [release notes](6_0_release_notes.html)

### การใช้งาน Webpacker

[Webpacker](https://github.com/rails/webpacker)
เป็นคอมไพล์เลอร์ JavaScript เริ่มต้นสำหรับ Rails 6. แต่หากคุณกำลังอัปเกรดแอปพลิเคชัน มันจะไม่ถูกเปิดใช้งานโดยค่าเริ่มต้น หากคุณต้องการใช้งาน Webpacker คุณสามารถรวมมันใน Gemfile และติดตั้งได้ดังนี้:

```ruby
gem "webpacker"
```

```bash
$ bin/rails webpacker:install
```

### Force SSL

เมธอด `force_ssl` บนคอนโทรลเลอร์ได้ถูกเลิกใช้และจะถูกนำออกใน Rails 6.1 คุณสามารถเปิดใช้งาน [`config.force_ssl`][] เพื่อบังคับให้เชื่อมต่อ HTTPS ทั่วแอปพลิเคชันของคุณ หากคุณต้องการยกเว้นจุดปลายทางบางส่วนจากการเปลี่ยนเส้นทาง คุณสามารถใช้ [`config.ssl_options`][] เพื่อกำหนดค่าพฤติกรรมนั้นได้

### ข้อมูลเชิงลึกและการหมดอายุซึ่งเป็นเมตาดาต้าซึ่งอยู่ภายในคุกกี้ที่ถูกเข้ารหัสหรือเซ็นต์เพิ่มเติมเพื่อเพิ่มความปลอดภัย

เพื่อเพิ่มความปลอดภัย Rails ฝังเมตาดาต้าเช่นวัตถุประสงค์และการหมดอายุภายในค่าคุกกี้ที่ถูกเข้ารหัสหรือเซ็นต์
เรลส์สามารถป้องกันการโจมตีที่พยายามคัดลอกค่าที่เข้ารหัส/เข้ารหัสของคุกกี้และใช้ค่านั้นเป็นค่าของคุกกี้อื่นได้

ข้อมูลฝังซึ่งใหม่นี้ทำให้คุกกี้เหล่านี้ไม่สามารถใช้งานร่วมกับรุ่นของเรลส์ที่เก่ากว่า 6.0 ได้

หากคุณต้องการให้คุกกี้ของคุณถูกอ่านโดยเรลส์ 5.2 และรุ่นที่เก่ากว่า หรือคุณกำลังตรวจสอบการใช้งาน 6.0 และต้องการที่จะย้อนกลับได้ ให้ตั้งค่า `Rails.application.config.action_dispatch.use_cookies_with_metadata` เป็น `false` 

### แพคเกจทั้งหมดของ npm ถูกย้ายไปยังขอบเขต `@rails`

หากคุณเคยโหลดแพคเกจ `actioncable`, `activestorage`, หรือ `rails-ujs` ผ่าน npm/yarn มาก่อนหน้านี้ คุณต้องอัปเดตชื่อของแพคเกจเหล่านี้ก่อนที่คุณจะสามารถอัปเกรดไปเป็น `6.0.0` ได้:

```
actioncable   → @rails/actioncable
activestorage → @rails/activestorage
rails-ujs     → @rails/ujs
```

### การเปลี่ยนแปลง API ของ Action Cable JavaScript

แพคเกจ Action Cable JavaScript ได้ถูกแปลงจาก CoffeeScript เป็น ES2015 และเราตอนนี้เผยแพร่รหัสต้นฉบับในการกระจายของ npm

การเปลี่ยนแปลงในรุ่นนี้รวมถึงการเปลี่ยนแปลงที่ทำให้บางส่วนที่เป็นตัวเลือกของ Action Cable JavaScript API เสียหาย:

- การกำหนดค่าของ WebSocket adapter และ logger adapter ได้ถูกย้ายจากคุณสมบัติของ `ActionCable` เป็นคุณสมบัติของ `ActionCable.adapters` หากคุณกำลังกำหนดค่า adapter เหล่านี้ คุณจะต้องทำการเปลี่ยนแปลงเหล่านี้:

    ```diff
    -    ActionCable.WebSocket = MyWebSocket
    +    ActionCable.adapters.WebSocket = MyWebSocket
    ```

    ```diff
    -    ActionCable.logger = myLogger
    +    ActionCable.adapters.logger = myLogger
    ```

- เมธอด `ActionCable.startDebugging()` และ `ActionCable.stopDebugging()` ได้ถูกลบและถูกแทนที่ด้วยคุณสมบัติ `ActionCable.logger.enabled` หากคุณกำลังใช้เมธอดเหล่านี้ คุณจะต้องทำการเปลี่ยนแปลงเหล่านี้:

    ```diff
    -    ActionCable.startDebugging()
    +    ActionCable.logger.enabled = true
    ```

    ```diff
    -    ActionCable.stopDebugging()
    +    ActionCable.logger.enabled = false
    ```

### `ActionDispatch::Response#content_type` ตอนนี้จะส่งคืนเฮดเดอร์ Content-Type โดยไม่มีการแก้ไข

ก่อนหน้านี้ ค่าที่ส่งคืนจาก `ActionDispatch::Response#content_type` ไม่รวมส่วนของ charset พฤติกรรมนี้ได้เปลี่ยนเพื่อรวมส่วน charset ที่ถูกข้ามไว้ก่อนหน้านี้ด้วย

หากคุณต้องการเฉพาะประเภท MIME เท่านั้น โปรดใช้ `ActionDispatch::Response#media_type` แทน

ก่อน:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present"
```

หลัง:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present; charset=utf-16"
resp.media_type   #=> "text/csv"
```

### การตั้งค่า `config.hosts` ใหม่

เรลส์ตอนนี้มีการตั้งค่า `config.hosts` ใหม่เพื่อเป็นเรื่องความปลอดภัย การตั้งค่านี้จะมีค่าเริ่มต้นเป็น `localhost` ในโหมดการพัฒนา หากคุณใช้โดเมนอื่นในโหมดการพัฒนา คุณต้องอนุญาตให้ใช้งานดังนี้:

```ruby
# config/environments/development.rb

config.hosts << 'dev.myapp.com'
config.hosts << /[a-z0-9-]+\.myapp\.com/ # ตัวเลือกเพิ่มเติม สามารถใช้รูปแบบเรกเอ็กซ์ได้
```

สำหรับสภาพแวดล้อมอื่น ๆ `config.hosts` จะเป็นค่าว่างเปล่าตามค่าเริ่มต้น ซึ่งหมายความว่าเรลส์จะไม่ตรวจสอบโฮสต์เลย คุณสามารถเพิ่มโฮสต์เหล่านี้เพิ่มเติมได้ถ้าคุณต้องการตรวจสอบในโหมดการใช้งานจริง
### การโหลดอัตโนมัติ

การกำหนดค่าเริ่มต้นสำหรับ Rails 6

```ruby
# config/application.rb

config.load_defaults 6.0
```

เปิดใช้งานโหมดการโหลดอัตโนมัติ `zeitwerk` บน CRuby ในโหมดนั้น การโหลดอัตโนมัติ การโหลดใหม่ และการโหลดแบบกระตือรือร้นจะถูกจัดการโดย [Zeitwerk](https://github.com/fxn/zeitwerk) 

หากคุณกำลังใช้ค่าเริ่มต้นจากเวอร์ชัน Rails ก่อนหน้านี้ คุณสามารถเปิดใช้งาน zeitwerk ได้ดังนี้:

```ruby
# config/application.rb

config.autoloader = :zeitwerk
```

#### ส่วน API สาธารณะ

โดยทั่วไปแล้ว แอปพลิเคชันไม่จำเป็นต้องใช้ API ของ Zeitwerk โดยตรง Rails จัดการตามสัญญาที่มีอยู่: `config.autoload_paths`, `config.cache_classes`, เป็นต้น

แม้ว่าแอปพลิเคชันควรที่จะปฏิบัติตามอินเทอร์เฟซนั้น แต่ออบเจ็กต์โหลดเดียวของ Zeitwerk สามารถเข้าถึงได้ดังนี้

```ruby
Rails.autoloaders.main
```

นั่นอาจเป็นสิ่งที่มีประโยชน์หากคุณต้องการโหลดล่วงหน้าคลาส Single Table Inheritance (STI) หรือกำหนดค่า inflector ที่กำหนดเอง เป็นต้น

#### โครงสร้างโปรเจกต์

หากแอปพลิเคชันที่กำลังอัปเกรดโหลดอัตโนมัติได้อย่างถูกต้อง โครงสร้างโปรเจกต์ควรเป็นเข้ากันได้แทบทั้งหมด

อย่างไรก็ตามโหมด `classic` จะสร้างชื่อไฟล์จากชื่อค่าคงที่ที่หายไป (`underscore`) ในขณะที่โหมด `zeitwerk` จะสร้างชื่อค่าคงที่จากชื่อไฟล์ (`camelize`) ช่วยให้การใช้งานร่วมกันไม่สมบูรณ์ โดยเฉพาะเมื่อมีคำย่อเกี่ยวข้อง เช่น `"FOO".underscore` คือ `"foo"` แต่ `"foo".camelize` คือ `"Foo"` ไม่ใช่ `"FOO"`

ความเข้ากันได้สามารถตรวจสอบได้ด้วยงาน `zeitwerk:check`:

```bash
$ bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

#### require_dependency

ทุกกรณีที่รู้จักของ `require_dependency` ได้ถูกลบทิ้งแล้ว คุณควรค้นหาและลบมันในโปรเจกต์ของคุณ

หากแอปพลิเคชันของคุณใช้ Single Table Inheritance โปรดดู [ส่วน Single Table Inheritance](autoloading_and_reloading_constants.html#single-table-inheritance) ของเอกสาร Autoloading and Reloading Constants (โหมด Zeitwerk)

#### ชื่อที่มีคุณสมบัติในการกำหนดค่าคลาสและโมดูล

คุณสามารถใช้เส้นทางค่าคงที่ในการกำหนดค่าคลาสและโมดูลได้อย่างเข้มแข็ง:

```ruby
# Autoloading in this class' body matches Ruby semantics now.
class Admin::UsersController < ApplicationController
  # ...
end
```

สิ่งที่ควรระวังคือ ขึ้นอยู่กับลำดับการดำเนินการ โหลดอัตโนมัติแบบคลาสสิกอาจสามารถโหลด `Foo::Wadus` ใน

```ruby
class Foo::Bar
  Wadus
end
```

ซึ่งไม่ตรงกับเซมันติกของ Ruby เนื่องจาก `Foo` ไม่ได้อยู่ในการซ้อนกัน และจะไม่ทำงานเลยในโหมด `zeitwerk` หากคุณพบกรณีมุมมองเช่นนี้คุณสามารถใช้ชื่อที่มีคุณสมบัติ `Foo::Wadus`:

```ruby
class Foo::Bar
  Foo::Wadus
end
```

หรือเพิ่ม `Foo` เข้าไปในการซ้อนกัน:

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

#### ความสัมพันธ์

คุณสามารถโหลดอัตโนมัติและโหลดแบบกระตือรือร้นจากโครงสร้างมาตรฐานเช่น

```
app/models
app/models/concerns
```

ในกรณีนั้น `app/models/concerns` ถูกถือว่าเป็นไดเรกทอรีราก (เนื่องจากเป็นส่วนหนึ่งของเส้นทางการโหลดอัตโนมัติ) และจะถูกละเว้นเป็นเนมสเปซ ดังนั้น `app/models/concerns/foo.rb` ควรกำหนด `Foo` ไม่ใช่ `Concerns::Foo`
เนมสเปซ `Concerns::` ทำงานร่วมกับ autoloader แบบคลาสสิกเป็นผลของการดำเนินการ แต่นั่นไม่ได้เป็นพฤติกรรมที่ตั้งใจไว้จริง แอปพลิเคชันที่ใช้ `Concerns::` จำเป็นต้องเปลี่ยนชื่อคลาสและโมดูลเหล่านั้นเพื่อให้สามารถทำงานในโหมด `zeitwerk` ได้

#### การมี `app` ในเส้นทางการโหลดอัตโนมัติ

บางโครงการต้องการสิ่งที่เรียกว่า `app/api/base.rb` เพื่อกำหนด `API::Base` และเพิ่ม `app` เข้าไปในเส้นทางการโหลดอัตโนมัติเพื่อให้สามารถทำได้ในโหมด `classic` โดยเนื่องจาก Rails จะเพิ่มโฟลเดอร์ย่อยทั้งหมดของ `app` เข้าไปในเส้นทางการโหลดอัตโนมัติโดยอัตโนมัติ จึงเกิดสถานการณ์ที่มีโฟลเดอร์รากที่ซ้อนกัน ดังนั้นการตั้งค่าดังกล่าวจึงไม่สามารถทำงานได้อีกต่อไป หลักการที่คล้ายกันเราได้อธิบายไว้ด้านบนเกี่ยวกับ `concerns`

หากคุณต้องการเก็บโครงสร้างดังกล่าว คุณจะต้องลบโฟลเดอร์ย่อยออกจากเส้นทางการโหลดอัตโนมัติในตัวกำหนดค่าเริ่มต้น:

```ruby
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/api")
```

#### ค่าคงที่ที่โหลดอัตโนมัติและเนมสเปซชัดเจน

หากมีเนมสเปซที่ถูกกำหนดในไฟล์ เช่น `Hotel` ที่นี่:

```
app/models/hotel.rb         # กำหนด Hotel.
app/models/hotel/pricing.rb # กำหนด Hotel::Pricing.
```

ค่าคงที่ `Hotel` ต้องถูกตั้งค่าโดยใช้คีย์เวิร์ด `class` หรือ `module` ตัวอย่างเช่น:

```ruby
class Hotel
end
```

ถือว่าถูกต้อง

วิธีการอื่น ๆ เช่น

```ruby
Hotel = Class.new
```

หรือ

```ruby
Hotel = Struct.new
```

จะไม่ทำงาน วัตถุย่อยเช่น `Hotel::Pricing` จะไม่พบ

ข้อจำกัดนี้ใช้เฉพาะสำหรับเนมสเปซชัดเจนเท่านั้น คลาสและโมดูลที่ไม่กำหนดเนมสเปซสามารถกำหนดได้โดยใช้รูปแบบเหล่านั้น

#### ไฟล์หนึ่ง ค่าคงที่หนึ่ง (ในระดับบนเดียวกัน)

ในโหมด `classic` คุณสามารถกำหนดค่าคงที่หลายค่าในระดับบนเดียวกันและให้โหลดใหม่ทั้งหมดได้ ตัวอย่างเช่น กำหนดให้

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

ในขณะที่ `Bar` ไม่สามารถโหลดอัตโนมัติได้ การโหลดอัตโนมัติ `Foo` จะทำให้ `Bar` ถูกกำหนดให้โหลดอัตโนมัติด้วย แต่นี้ไม่ใช่กรณีในโหมด `zeitwerk` คุณจะต้องย้าย `Bar` เป็นไฟล์ของตัวเอง `bar.rb` ไฟล์หนึ่ง ค่าคงที่หนึ่ง

ข้อจำกัดนี้ใช้เฉพาะค่าคงที่ในระดับบนเดียวกันเท่านั้น เช่นในตัวอย่างด้านบน คลาสและโมดูลภายในถือว่าถูกต้อง ตัวอย่างเช่นพิจารณา

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

หากแอปพลิเคชันโหลด `Foo` จะโหลด `Foo::InnerClass` ด้วย

#### Spring และสภาพแวดล้อม `test`

Spring โหลดโค้ดแอปพลิเคชันใหม่หากมีการเปลี่ยนแปลงอะไรบางอย่าง ในสภาพแวดล้อม `test` คุณต้องเปิดใช้การโหลดใหม่เพื่อให้ทำงาน:

```ruby
# config/environments/test.rb

config.cache_classes = false
```

มิฉะนั้นคุณจะได้รับข้อผิดพลาดนี้:

```
reloading is disabled because config.cache_classes is true
```

#### Bootsnap

Bootsnap ควรเป็นเวอร์ชัน 1.4.2 หรือสูงกว่า

นอกจากนี้ Bootsnap ต้องปิดใช้งานแคช iseq เนื่องจากข้อบกพร่องในตัวแปลตัวตรวจสอบถ้าใช้ Ruby 2.5 โปรดตรวจสอบว่าขึ้นอยู่กับ Bootsnap เวอร์ชัน 1.4.4 หรือสูงกว่าในกรณีนั้น
#### `config.add_autoload_paths_to_load_path`

จุดกำหนดค่าใหม่ [`config.add_autoload_paths_to_load_path`][] เป็น `true` โดยค่าเริ่มต้นเพื่อความเข้ากันได้ย้อนหลัง แต่คุณสามารถเลือกไม่เพิ่มเส้นทางการโหลดอัตโนมัติไปยัง `$LOAD_PATH` ได้

สิ่งนี้เป็นสิ่งที่เหมาะสมในแอปพลิเคชันส่วนใหญ่ เนื่องจากคุณไม่ควรต้องการให้ไฟล์ใน `app/models` ถูกต้อง และ Zeitwerk ใช้ชื่อไฟล์แบบสมบูรณ์ภายในเท่านั้น

โดยการเลือกไม่เพิ่มเส้นทางการโหลดอัตโนมัติ คุณจะปรับปรุงการค้นหา `$LOAD_PATH` (ลดจำนวนไดเรกทอรีที่ต้องตรวจสอบ) และประหยัดการทำงานและการใช้หน่วยความจำของ Bootsnap เนื่องจากไม่จำเป็นต้องสร้างดัชนีสำหรับไดเรกทอรีเหล่านี้

#### ความปลอดภัยในเรื่องของ Thread

ในโหมดคลาสสิก การโหลดค่าคงที่ไม่ปลอดภัยในเรื่องของ Thread แต่ Rails มีการล็อกเพื่อทำให้การร้องขอเว็บปลอดภัยเมื่อเปิดใช้งานการโหลดค่าคงที่ ซึ่งเป็นสิ่งที่พบบ่อยในสภาพแวดล้อมการพัฒนา

การโหลดค่าคงที่ปลอดภัยในเรื่องของ Thread ในโหมด `zeitwerk` ตัวอย่างเช่น คุณสามารถโหลดค่าคงที่ในสคริปต์ที่มีการใช้งานหลายเธรดที่ถูกดำเนินการโดยคำสั่ง `runner`

#### การใช้งาน Globs ใน `config.autoload_paths`

ระวังการกำหนดค่าเช่นนี้

```ruby
config.autoload_paths += Dir["#{config.root}/lib/**/"]
```

ทุกส่วนของ `config.autoload_paths` ควรแทนที่เนมสเปซระดับบนสุด (`Object`) และไม่สามารถซ้อนกันได้ (ยกเว้นไดเรกทอรี `concerns` ที่อธิบายไว้ด้านบน)

ในการแก้ไขปัญหานี้ เพียงเอาเครื่องหมายดอกจันออก:

```ruby
config.autoload_paths << "#{config.root}/lib"
```

#### การโหลดแบบกระตือรือร้นและการโหลดค่าคงที่เป็นไปในทิศทางเดียวกัน

ในโหมด `classic` ถ้า `app/models/foo.rb` กำหนด `Bar` คุณจะไม่สามารถโหลดค่าคงที่ได้ แต่การโหลดแบบกระตือรือร้นจะทำงานเนื่องจากโหลดไฟล์แบบลูกศร สิ่งนี้อาจเป็นแหล่งกำเนิดของข้อผิดพลาดถ้าคุณทดสอบก่อนการโหลดแบบกระตือรือร้น การดำเนินการอาจล้มเหลวในการโหลดค่าคงที่ในภายหลัง

ในโหมด `zeitwerk` ทั้งสองโหมดการโหลดเป็นไปในทิศทางเดียวกัน พวกเขาล้มเหลวและเกิดข้อผิดพลาดในไฟล์เดียวกัน

#### วิธีการใช้งาน Classic Autoloader ใน Rails 6

แอปพลิเคชันสามารถโหลดค่าเริ่มต้นของ Rails 6 และใช้ Classic Autoloader ได้โดยการตั้งค่า `config.autoloader` ดังนี้:

```ruby
# config/application.rb

config.load_defaults 6.0
config.autoloader = :classic
```

เมื่อใช้ Classic Autoloader ในแอปพลิเคชัน Rails 6 แนะนำให้ตั้งระดับความสามารถในการประมวลผลเป็น 1 ในสภาพแวดล้อมการพัฒนาสำหรับเว็บเซิร์ฟเวอร์และตัวประมวลผลที่ทำงานเบื้องหลัง เนื่องจากปัญหาความปลอดภัยในเรื่องของ Thread

### การเปลี่ยนแปลงพฤติกรรมการกำหนดค่าใน Active Storage

ด้วยค่าเริ่มต้นของการกำหนดค่าสำหรับ Rails 5.2 การกำหนดค่าให้กับคอลเลกชันของไฟล์แนบที่ประกาศด้วย `has_many_attached` จะเพิ่มไฟล์ใหม่:

```ruby
class User < ApplicationRecord
  has_many_attached :highlights
end

user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

ด้วยค่าเริ่มต้นของการกำหนดค่าสำหรับ Rails 6.0 การกำหนดค่าให้กับคอลเลกชันของไฟล์แนบจะแทนที่ไฟล์ที่มีอยู่แทนที่จะเพิ่มเข้าไป ซึ่งเป็นการตรงกับพฤติกรรมของ Active Record เมื่อกำหนดค่าให้กับคอลเลกชันของสมาชิกของคอลเลกชัน:
```ruby
user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 1
user.highlights.first.filename # => "town.jpg"
```

`#attach` สามารถใช้เพื่อเพิ่มไฟล์แนบใหม่โดยไม่ต้องลบไฟล์แนบที่มีอยู่แล้ว:

```ruby
blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.highlights.attach(blob)

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

แอปพลิเคชันที่มีอยู่สามารถเลือกใช้พฤติกรรมใหม่นี้ได้โดยตั้งค่า [`config.active_storage.replace_on_assign_to_many`][] เป็น `true` พฤติกรรมเก่าจะถูกเลิกใช้ใน Rails 7.0 และถูกลบออกใน Rails 7.1


### แอปพลิเคชันที่มีการจัดการข้อผิดพลาดที่กำหนดเอง

ส่วนของการร้องขอ `Accept` หรือ `Content-Type` ที่ไม่ถูกต้องจะเกิดข้อผิดพลาด
ค่าเริ่มต้น [`config.exceptions_app`][] จัดการข้อผิดพลาดนั้นโดยเฉพาะและแก้ไขได้
แอปพลิเคชันข้อผิดพลาดที่กำหนดเองจะต้องจัดการข้อผิดพลาดนั้นด้วย หรือการร้องขอเช่นนั้นจะทำให้ Rails ใช้แอปพลิเคชันข้อผิดพลาดสำรองซึ่งคืนค่า `500 Internal Server Error`


การอัปเกรดจาก Rails 5.1 เป็น Rails 5.2
-------------------------------------

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการเปลี่ยนแปลงใน Rails 5.2 โปรดดู [release notes](5_2_release_notes.html).

### Bootsnap

Rails 5.2 เพิ่มแพ็กเกจ bootsnap ใน [Gemfile ของแอปที่สร้างขึ้นใหม่](https://github.com/rails/rails/pull/29313).
คำสั่ง `app:update` จะติดตั้งใน `boot.rb` หากคุณต้องการใช้งาน ให้เพิ่มใน Gemfile:

```ruby
# ลดเวลาการบูตด้วยการใช้แคช; ต้องการใน config/boot.rb
gem 'bootsnap', require: false
```

หรือเปลี่ยน `boot.rb` เพื่อไม่ใช้ bootsnap.

### การหมดอายุในคุกกี้ที่ลงชื่อหรือเข้ารหัสตอนนี้ถูกฝังอยู่ในค่าคุกกี้

เพื่อเพิ่มความปลอดภัย Rails ตอนนี้ฝังข้อมูลการหมดอายุในคุกกี้ที่เข้ารหัสหรือลงชื่อเข้าไปด้วย

ข้อมูลที่ฝังใหม่นี้ทำให้คุกกี้เหล่านั้นไม่สามารถใช้งานร่วมกับเวอร์ชันของ Rails ที่เก่ากว่า 5.2

หากคุณต้องการให้คุกกี้ของคุณถูกอ่านโดยเวอร์ชัน 5.1 และเก่ากว่า หรือคุณยังตรวจสอบการใช้งาน 5.2 และต้องการ
ให้คุณสามารถย้อนกลับได้ ให้ตั้งค่า
`Rails.application.config.action_dispatch.use_authenticated_cookie_encryption` เป็น `false`.

การอัปเกรดจาก Rails 5.0 เป็น Rails 5.1
-------------------------------------

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการเปลี่ยนแปลงใน Rails 5.1 โปรดดู [release notes](5_1_release_notes.html).

### `HashWithIndifferentAccess` ระดับสูงถูกประกาศเป็นเลิกใช้แบบอ่อน

หากแอปพลิเคชันของคุณใช้คลาส `HashWithIndifferentAccess` ระดับสูง คุณควรเริ่มย้ายโค้ดของคุณให้ใช้ `ActiveSupport::HashWithIndifferentAccess` แทน

มันถูกประกาศเป็นเลิกใช้แบบอ่อนเท่านั้น ซึ่งหมายความว่าโค้ดของคุณจะไม่เสียหายในขณะนี้และจะไม่แสดงคำเตือนเกี่ยวกับการเลิกใช้ แต่ค่าคงที่นี้จะถูกลบในอนาคต

นอกจากนี้หากคุณมีเอกสาร YAML เก่าที่มีการเก็บข้อมูลเกี่ยวกับวัตถุเหล่านี้ คุณอาจจะต้องโหลดและเก็บข้อมูลอีกครั้งเพื่อให้แน่ใจว่าพวกเขาอ้างอิงถึงค่าคงที่ที่ถูกต้องและการโหลดพวกเขาจะไม่เสียหายในอนาคต
### `application.secrets` โหลดคีย์ทั้งหมดเป็นสัญลักษณ์

หากแอปพลิเคชันของคุณเก็บการกำหนดค่าที่ซ้อนกันใน `config/secrets.yml` คีย์ทั้งหมดจะถูกโหลดเป็นสัญลักษณ์ ดังนั้นการเข้าถึงโดยใช้สตริงควรเปลี่ยนแปลง

จาก:

```ruby
Rails.application.secrets[:smtp_settings]["address"]
```

เป็น:

```ruby
Rails.application.secrets[:smtp_settings][:address]
```

### เอาความสนับสนุนที่ถูกยกเลิกออกจาก `:text` และ `:nothing` ใน `render`

หากคุณใช้ `render :text` ในคอนโทรลเลอร์ของคุณ จะไม่ทำงานอีกต่อไป วิธีใหม่ในการแสดงข้อความด้วยประเภท MIME เป็น `text/plain` คือใช้ `render :plain`

เช่นเดียวกัน `render :nothing` ก็ถูกลบออกและคุณควรใช้เมธอด `head` เพื่อส่งการตอบกลับที่มีเฉพาะส่วนหัวเท่านั้น ตัวอย่างเช่น `head :ok` ส่งการตอบกลับ 200 โดยไม่มีเนื้อหาที่จะแสดง

### เอาความสนับสนุนที่ถูกยกเลิกออกจาก `redirect_to :back`

ใน Rails 5.0 `redirect_to :back` ถูกยกเลิก และใน Rails 5.1 ถูกลบออกทั้งหมด

เป็นทางเลือกที่แทนคือใช้ `redirect_back` สำคัญที่จะระบุว่า `redirect_back` ยังรับ `fallback_location` ซึ่งจะถูกใช้ในกรณีที่ `HTTP_REFERER` หายไป

```ruby
redirect_back(fallback_location: root_path)
```

การอัพเกรดจาก Rails 4.2 เป็น Rails 5.0
-------------------------------------

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการเปลี่ยนแปลงใน Rails 5.0 โปรดดู [release notes](5_0_release_notes.html).

### ต้องใช้ Ruby 2.2.2+ 

ตั้งแต่ Rails 5.0 เป็นต้นไป รุ่น Ruby 2.2.2+ เป็นรุ่น Ruby เท่านั้นที่รองรับ ตรวจสอบให้แน่ใจว่าคุณใช้รุ่น Ruby 2.2.2 หรือสูงกว่าก่อนที่คุณจะดำเนินการต่อ

### Active Record Models สืบทอดจาก ApplicationRecord เป็นค่าเริ่มต้น

ใน Rails 4.2 โมเดล Active Record สืบทอดจาก `ActiveRecord::Base` ใน Rails 5.0 โมเดลทั้งหมดสืบทอดจาก `ApplicationRecord`

`ApplicationRecord` เป็น superclass ใหม่สำหรับโมเดลแอปพลิเคชันทั้งหมด เหมือนกับคลาสคอนโทรลเลอร์แอปพลิเคชันที่สืบทอดจาก `ApplicationController` แทนที่จะสืบทอดจาก `ActionController::Base` นี่จะทำให้แอปพลิเคชันมีจุดเดียวสำหรับกำหนดค่าพฤติกรรมโมเดลในระดับแอปพลิเคชัน

เมื่ออัพเกรดจาก Rails 4.2 เป็น Rails 5.0 คุณจำเป็นต้องสร้างไฟล์ `application_record.rb` ใน `app/models/` และเพิ่มเนื้อหาต่อไปนี้:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

แล้วตรวจสอบให้แน่ใจว่าโมเดลทั้งหมดสืบทอดจากมัน

### หยุดการทำงานของ Callback Chains ผ่าน `throw(:abort)`

ใน Rails 4.2 เมื่อ callback แบบ 'before' ส่งคืนค่า `false` ใน Active Record และ Active Model จะหยุดการทำงานของ callback chain ทั้งหมด กล่าวคือ callback แบบ 'before' ต่อไปจะไม่ถูกเรียกใช้ และการกระทำที่ถูกห่อหุ้มด้วย callback ก็ไม่ถูกเรียกใช้

ใน Rails 5.0 การส่งคืนค่า `false` ใน callback ของ Active Record หรือ Active Model จะไม่มีผลข้างเคียงในการหยุดการทำงานของ callback chain แทนที่จะต้องหยุดการทำงานของ callback chain โดยเรียกใช้ `throw(:abort)`

เมื่อคุณอัพเกรดจาก Rails 4.2 เป็น Rails 5.0 การส่งคืนค่า `false` ใน callback แบบนี้จะยังหยุดการทำงานของ callback chain แต่คุณจะได้รับคำเตือนเกี่ยวกับการเปลี่ยนแปลงที่กำลังจะเกิดขึ้นนี้
เมื่อคุณพร้อมแล้วคุณสามารถเลือกใช้พฤติกรรมใหม่และลบคำเตือนการเลิกใช้โดยเพิ่มการกำหนดค่าต่อไปนี้ใน `config/application.rb`:

```ruby
ActiveSupport.halt_callback_chains_on_return_false = false
```

โปรดทราบว่าตัวเลือกนี้จะไม่มีผลต่อการเรียกใช้งาน Active Support callbacks เนื่องจากไม่เคยหยุดการทำงานของโซ่เมื่อมีการส่งคืนค่าใด ๆ

ดู [#17227](https://github.com/rails/rails/pull/17227) สำหรับรายละเอียดเพิ่มเติม

### ActiveJob สืบทอดจาก ApplicationJob โดยค่าเริ่มต้น

ใน Rails 4.2 Active Job สืบทอดจาก `ActiveJob::Base` ใน Rails 5.0 พฤติกรรมนี้เปลี่ยนแปลงเพื่อสืบทอดจาก `ApplicationJob` แทน

เมื่ออัปเกรดจาก Rails 4.2 เป็น Rails 5.0 คุณต้องสร้างไฟล์ `application_job.rb` ใน `app/jobs/` และเพิ่มเนื้อหาต่อไปนี้:

```ruby
class ApplicationJob < ActiveJob::Base
end
```

แล้วตรวจสอบให้แน่ใจว่าคลาสงานทั้งหมดของคุณสืบทอดมาจากมัน

ดู [#19034](https://github.com/rails/rails/pull/19034) สำหรับรายละเอียดเพิ่มเติม

### การทดสอบควบคุมเรล

#### การแยกบางเมธอดช่วยใน `rails-controller-testing`

`assigns` และ `assert_template` ถูกแยกออกเป็นแพ็กเกจ `rails-controller-testing` เพื่อใช้งานต่อไปในการทดสอบควบคุมของคุณ ให้เพิ่ม `gem 'rails-controller-testing'` ใน `Gemfile` เพื่อใช้งานเมธอดเหล่านี้ต่อไป

หากคุณใช้ RSpec ในการทดสอบ โปรดดูการกำหนดค่าเพิ่มเติมที่จำเป็นในเอกสารของแพ็กเกจ

#### พฤติกรรมใหม่เมื่ออัปโหลดไฟล์

หากคุณใช้ `ActionDispatch::Http::UploadedFile` ในการทดสอบเพื่ออัปโหลดไฟล์ คุณจะต้องเปลี่ยนไปใช้คลาส `Rack::Test::UploadedFile` ที่คล้ายกันแทน

ดู [#26404](https://github.com/rails/rails/issues/26404) สำหรับรายละเอียดเพิ่มเติม

### การโหลดอัตโนมัติถูกปิดใช้งานหลังจากที่บูตในสภาพแวดล้อมการผลิต

การโหลดอัตโนมัติถูกปิดใช้งานหลังจากที่บูตในสภาพแวดล้อมการผลิตโดยค่าเริ่มต้น

การโหลดแอปพลิเคชันเป็นส่วนหนึ่งของกระบวนการบูต ดังนั้นค่าคงที่ระดับสูงสุดถูกต้องและยังโหลดอัตโนมัติ ไม่จำเป็นต้องร้องขอไฟล์ของพวกเขา

ค่าคงที่ในสถานที่ที่ลึกลงมาที่เป็นส่วนหนึ่งของการดำเนินการในเวลาที่รันเท่านั้น เช่น ร่างกายของเมธอดปกติ ก็ยังถูกต้องเพราะไฟล์ที่กำหนดค่าไว้จะถูกโหลดอัตโนมัติขณะที่บูต

สำหรับส่วนใหญ่ของแอปพลิเคชันการเปลี่ยนแปลงนี้ไม่ต้องการการดำเนินการใด ๆ แต่ในกรณีที่มีแอปพลิเคชันของคุณต้องการโหลดอัตโนมัติในขณะที่ทำงานในโหมดการผลิต ให้ตั้งค่า `Rails.application.config.enable_dependency_loading` เป็น true

### การซีเรียลไซเอชัน XML

`ActiveModel::Serializers::Xml` ถูกแยกออกจาก Rails เป็นแพ็กเกจ `activemodel-serializers-xml` เพื่อใช้งานซีเรียลไซเอชัน XML ในแอปพลิเคชันของคุณ ให้เพิ่ม `gem 'activemodel-serializers-xml'` ใน `Gemfile` 

### เอาชีวิตรอดสำหรับอะแดปเตอร์ฐานข้อมูลเก่า `mysql`

Rails 5 ลบการสนับสนุนสำหรับอะแดปเตอร์ฐานข้อมูลเก่า `mysql` ผู้ใช้ส่วนใหญ่ควรสามารถใช้ `mysql2` แทน จะถูกแปลงเป็นแพ็กเกจแยกต่างหากเมื่อเราพบคนที่จะดูแล

### เอาชีวิตรอดสำหรับ Debugger

`debugger` ไม่รองรับโดย Ruby 2.2 ซึ่งจำเป็นต้องใช้กับ Rails 5 ให้ใช้ `byebug` แทน
### ใช้ `bin/rails` เพื่อเรียกใช้งานงานและการทดสอบ

Rails 5 เพิ่มความสามารถในการเรียกใช้งานงานและการทดสอบผ่าน `bin/rails` แทน rake โดยทั่วไป
การเปลี่ยนแปลงเหล่านี้เป็นขนาดเทียบเท่ากับ rake แต่บางส่วนถูกย้ายทั้งหมด

ในการใช้งานตัวรันเทสใหม่เพียงแค่พิมพ์ `bin/rails test` เท่านั้น

`rake dev:cache` เป็น `bin/rails dev:cache` ตอนนี้

ให้เรียกใช้ `bin/rails` ภายในไดเรกทอรี่รากของแอปพลิเคชันของคุณเพื่อดูรายการคำสั่งที่มีอยู่

### `ActionController::Parameters` ไม่ได้สืบทอดจาก `HashWithIndifferentAccess` อีกต่อไป

การเรียกใช้ `params` ในแอปพลิเคชันของคุณตอนนี้จะคืนวัตถุแทนที่แทนข้อมูลแบบแฮช หากพารามิเตอร์ของคุณได้รับอนุญาตแล้ว คุณจะไม่ต้องทำการเปลี่ยนแปลงใด ๆ หากคุณกำลังใช้ `map`
และเมธอดอื่น ๆ ที่ขึ้นอยู่กับการอ่านแบบแฮชโดยไม่คำนึงถึง `permitted?` คุณจะต้องอัปเกรดแอปพลิเคชันของคุณให้เป็นการอนุญาตก่อนแล้วแปลงเป็นแบบแฮช

```ruby
params.permit([:proceed_to, :return_to]).to_h
```

### `protect_from_forgery` ตอนนี้เริ่มต้นด้วย `prepend: false`

`protect_from_forgery` มีค่าเริ่มต้นเป็น `prepend: false` ซึ่งหมายความว่ามันจะถูกแทรกเข้าไปในสายการเรียกคืนที่จุดที่คุณเรียกใช้ในแอปพลิเคชันของคุณ หากคุณต้องการให้ `protect_from_forgery` รันก่อนอื่นเสมอ คุณควรเปลี่ยนแอปพลิเคชันของคุณให้ใช้
`protect_from_forgery prepend: true` แทน

### ตัวจัดการเทมเพลตเริ่มต้นเป็น RAW ตอนนี้

ไฟล์ที่ไม่มีตัวจัดการเทมเพลตในส่วนขยายของมันจะถูกแสดงผลโดยใช้ตัวจัดการ RAW ก่อนหน้านี้ Rails จะแสดงผลไฟล์โดยใช้ตัวจัดการเทมเพลต ERB

หากคุณไม่ต้องการให้ไฟล์ของคุณถูกจัดการผ่านตัวจัดการ RAW คุณควรเพิ่มส่วนขยายให้กับไฟล์ของคุณที่สามารถแยกวิเคราะห์ได้โดยตัวจัดการเทมเพลตที่เหมาะสม

### เพิ่มการจับคู่แบบวิลด์การขึ้นอยู่กับการขึ้นอยู่ของเทมเพลต

ตอนนี้คุณสามารถใช้การจับคู่แบบวิลด์สำหรับการขึ้นอยู่ของเทมเพลตของคุณได้ ตัวอย่างเช่น หากคุณกำลังกำหนดเทมเพลตของคุณดังนี้:

```erb
<% # Template Dependency: recordings/threads/events/subscribers_changed %>
<% # Template Dependency: recordings/threads/events/completed %>
<% # Template Dependency: recordings/threads/events/uncompleted %>
```

คุณสามารถเรียกใช้การขึ้นอยู่เพียงครั้งเดียวด้วยวิลด์การขึ้นอยู่

```erb
<% # Template Dependency: recordings/threads/events/* %>
```

### `ActionView::Helpers::RecordTagHelper` ถูกย้ายไปยัง gem ภายนอก (record_tag_helper)

`content_tag_for` และ `div_for` ถูกลบแล้วและใช้ `content_tag` แทน หากต้องการใช้เมธอดเก่าต่อไป ให้เพิ่ม gem `record_tag_helper` เข้าไปใน `Gemfile` ของคุณ:

```ruby
gem 'record_tag_helper', '~> 1.0'
```

ดูเพิ่มเติมที่ [#18411](https://github.com/rails/rails/pull/18411) สำหรับรายละเอียดเพิ่มเติม

### เอาการสนับสนุนสำหรับ gem `protected_attributes` ออก

gem `protected_attributes` ไม่ได้รับการสนับสนุนใน Rails 5 อีกต่อไป

### เอาการสนับสนุนสำหรับ gem `activerecord-deprecated_finders` ออก

gem `activerecord-deprecated_finders` ไม่ได้รับการสนับสนุนใน Rails 5 อีกต่อไป

### การเรียงลำดับเริ่มต้นของ `ActiveSupport::TestCase` ตอนนี้เป็นแบบสุ่ม
เมื่อทดสอบในแอปพลิเคชันของคุณ ลำดับเริ่มต้นคือ `:random` แทนที่จะเป็น `:sorted` ใช้ตัวเลือกการกำหนดค่าต่อไปนี้เพื่อกำหนดคืนมันกลับไปเป็น `:sorted` 

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted
end
```

### `ActionController::Live` เป็น `Concern` แล้ว

หากคุณรวม `ActionController::Live` ในโมดูลอื่นที่รวมอยู่ในคอนโทรลเลอร์ของคุณ คุณควรขยายโมดูลด้วย `ActiveSupport::Concern` อีกทางเลือกคือคุณสามารถใช้ `self.included` เพื่อรวม `ActionController::Live` โดยตรงไปยังคอนโทรลเลอร์เมื่อ `StreamingSupport` ถูกรวมเข้ามา

นั่นหมายความว่าหากแอปพลิเคชันของคุณใช้โมดูลการสตรีมของตัวเอง โค้ดต่อไปนี้จะเสียชีวิตในการดำเนินงาน:

```ruby
# นี่คือการทำงานร่วมกันสำหรับตัวควบคุมที่สตรีมทำการตรวจสอบความถูกต้องด้วย Warden/Devise
# ดู https://github.com/plataformatec/devise/issues/2332
# การรับรองตัวตรวจสอบในเราเตอร์เป็นทางเลือกอีกวิธีที่แนะนำในปัญหานั้น
class StreamingSupport
  include ActionController::Live # ส่วนนี้จะไม่ทำงานในการดำเนินงานสำหรับ Rails 5
  # extend ActiveSupport::Concern # ยกเว้นว่าคุณจะยกเลิกคำสั่งนี้

  def process(name)
    super(name)
  rescue ArgumentError => e
    if e.message == 'uncaught throw :warden'
      throw :warden
    else
      raise e
    end
  end
end
```

### ค่าเริ่มต้นของเฟรมเวิร์กใหม่

#### ตัวเลือก `belongs_to` ที่ต้องการโดยค่าเริ่มต้น

`belongs_to` ตอนนี้จะเรียกใช้ข้อผิดพลาดการตรวจสอบโดยค่าเริ่มต้นหากไม่มีการเชื่อมโยง

สามารถปิดการใช้งานต่อการเชื่อมโยงแต่ละตัวด้วย `optional: true`

ค่าเริ่มต้นนี้จะถูกกำหนดค่าโดยอัตโนมัติในแอปพลิเคชันใหม่ หากแอปพลิเคชันที่มีอยู่ต้องการเพิ่มคุณสมบัตินี้ จะต้องเปิดใช้งานในตัวกำหนดค่าเริ่มต้น:

```ruby
config.active_record.belongs_to_required_by_default = true
```

การกำหนดค่านี้เป็นส่วนตัวสำหรับโมเดลทั้งหมดของคุณโดยค่าเริ่มต้น แต่คุณสามารถแทนที่ได้ในแต่ละโมเดล นี้จะช่วยให้คุณย้ายโมเดลทั้งหมดของคุณให้มีการเชื่อมโยงที่ต้องการโดยค่าเริ่มต้น

```ruby
class Book < ApplicationRecord
  # โมเดลยังไม่พร้อมที่จะต้องการการเชื่อมโยงโดยค่าเริ่มต้น

  self.belongs_to_required_by_default = false
  belongs_to(:author)
end

class Car < ApplicationRecord
  # โมเดลพร้อมที่จะต้องการการเชื่อมโยงโดยค่าเริ่มต้น

  self.belongs_to_required_by_default = true
  belongs_to(:pilot)
end
```

#### CSRF Tokens ต่อฟอร์มแต่ละรูปแบบ

Rails 5 ตอนนี้รองรับ CSRF tokens ต่อฟอร์มแต่ละรูปแบบเพื่อป้องกันการโจมตีด้วยการซ้อนโค้ดด้วยฟอร์มที่สร้างขึ้นโดย JavaScript ด้วยตัวเลือกนี้เปิดใช้งาน ฟอร์มในแอปพลิเคชันของคุณจะมี CSRF token ของตัวเองที่เฉพาะกับการดำเนินการและวิธีการสำหรับฟอร์มนั้น

```ruby
config.action_controller.per_form_csrf_tokens = true
```

#### การป้องกันการปลอมแปลงด้วยการตรวจสอบ Origin

คุณสามารถกำหนดค่าแอปพลิเคชันของคุณให้ตรวจสอบว่าส่วนหัว HTTP `Origin` ควรตรวจสอบกับต้นกำเนิดของไซต์เป็นการป้องกัน CSRF เพิ่มเติม ตั้งค่าต่อไปนี้ในการกำหนดค่าของคุณเป็นจริง:
```ruby
config.action_controller.forgery_protection_origin_check = true
```

#### อนุญาตให้กำหนดค่าการตั้งค่าชื่อคิวของ Action Mailer

ค่าเริ่มต้นของชื่อคิวของเมลเลอร์คือ `mailers` ตัวเลือกการตั้งค่านี้ช่วยให้คุณสามารถเปลี่ยนชื่อคิวได้ทั่วทั้งระบบ กำหนดค่าต่อไปนี้ในไฟล์ config:

```ruby
config.action_mailer.deliver_later_queue_name = :new_queue_name
```

#### รองรับการใช้งาน Fragment Caching ใน Action Mailer Views

กำหนด [`config.action_mailer.perform_caching`][] ในไฟล์ config เพื่อกำหนดว่า Action Mailer views ควรรองรับการใช้งาน caching หรือไม่

```ruby
config.action_mailer.perform_caching = true
```

#### กำหนดการแสดงผลของ `db:structure:dump`

หากคุณใช้ `schema_search_path` หรือส่วนขยาย PostgreSQL อื่น ๆ คุณสามารถควบคุมวิธีการ dump schema ได้ กำหนดเป็น `:all` เพื่อสร้าง dump ทั้งหมด หรือเป็น `:schema_search_path` เพื่อสร้างจาก schema search path

```ruby
config.active_record.dump_schemas = :all
```

#### กำหนด SSL Options เพื่อเปิดใช้งาน HSTS กับ Subdomains

กำหนดค่าต่อไปนี้ในไฟล์ config เพื่อเปิดใช้งาน HSTS เมื่อใช้งาน subdomains:

```ruby
config.ssl_options = { hsts: { subdomains: true } }
```

#### รักษา Timezone ของ Receiver

เมื่อใช้ Ruby 2.4 คุณสามารถรักษา Timezone ของ Receiver เมื่อเรียกใช้ `to_time` ได้

```ruby
ActiveSupport.to_time_preserves_timezone = false
```

### การเปลี่ยนแปลงในการซีรีเอต JSON/JSONB

ใน Rails 5.0 วิธีการซีรีเอตและดีซีรีเอต JSON/JSONB attributes มีการเปลี่ยนแปลง ตอนนี้หากคุณกำหนดคอลัมน์เท่ากับ `String` Active Record จะไม่แปลงสตริงนั้นเป็น `Hash` และจะคืนค่าเป็นสตริงเท่านั้น การเปลี่ยนแปลงนี้ไม่จำกัดเฉพาะการโต้ตอบกับโมเดลเท่านั้น แต่ยังมีผลต่อการตั้งค่าคอลัมน์ `:default` ใน `db/schema.rb` แนะนำให้ไม่กำหนดคอลัมน์เท่ากับ `String` แต่ให้ส่ง `Hash` ซึ่งจะถูกแปลงเป็นและจากสตริง JSON โดยอัตโนมัติ

การอัปเกรดจาก Rails 4.1 เป็น Rails 4.2
-------------------------------------

### Web Console

เพิ่ม `gem 'web-console', '~> 2.0'` เข้าไปในกลุ่ม `:development` ใน `Gemfile` และรัน `bundle install` (ไม่ได้ถูกเพิ่มเมื่อคุณอัปเกรด Rails) เมื่อติดตั้งแล้ว คุณสามารถเพิ่มการเรียกใช้งาน console helper (เช่น `<%= console %>`) ใน view ใด ๆ เพื่อเปิดใช้งาน และ console จะถูกแสดงในหน้า error ใด ๆ ที่คุณเปิดในสภาพแวดล้อมการพัฒนา

### Responders

`respond_with` และ `respond_to` ที่ระดับคลาสถูกแยกออกเป็น gem `responders` ใน Rails 4.2 ในการใช้งานคุณสามารถเพิ่ม `gem 'responders', '~> 2.0'` เข้าไปใน `Gemfile` ของคุณ การเรียกใช้งาน `respond_with` และ `respond_to` (อีกครั้งที่ระดับคลาส) จะไม่ทำงานหากคุณไม่ได้รวม gem `responders` เข้าไปใน dependencies ของคุณ:

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
การใช้ `respond_to` ระดับอินสแตนซ์ไม่ได้รับผลกระทบและไม่ต้องการเพิ่ม gem เพิ่มเติม:

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

ดูเพิ่มเติมได้ที่ [#16526](https://github.com/rails/rails/pull/16526) 

### การจัดการข้อผิดพลาดในการเรียกใช้งาน transaction callbacks

ในปัจจุบัน Active Record ยับยั้งข้อผิดพลาดที่เกิดขึ้นภายใน callback `after_rollback` หรือ `after_commit` และเพียงแค่พิมพ์ข้อผิดพลาดเหล่านั้นลงในบันทึกเท่านั้น ในเวอร์ชันถัดไปของ Active Record ข้อผิดพลาดเหล่านี้จะไม่ถูกยับยั้งอีกต่อไป แทนที่ข้อผิดพลาดจะแพร่กระจายไปตามปกติเหมือนกับ callback อื่น ๆ ของ Active Record

เมื่อคุณกำหนด callback `after_rollback` หรือ `after_commit` คุณจะได้รับคำเตือนการเลิกใช้งานเกี่ยวกับการเปลี่ยนแปลงที่กำลังจะเกิดขึ้นนี้ และเมื่อคุณพร้อมแล้วคุณสามารถเลือกใช้พฤติกรรมใหม่และลบคำเตือนการเลิกใช้งานได้โดยเพิ่มการกำหนดค่าต่อไปนี้ใน `config/application.rb`:

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

ดูเพิ่มเติมได้ที่ [#14488](https://github.com/rails/rails/pull/14488) และ [#16537](https://github.com/rails/rails/pull/16537) 

### การเรียงลำดับของ test cases

ใน Rails 5.0 test cases จะถูกดำเนินการเรียงลำดับแบบสุ่มโดยค่าเริ่มต้น ในการคาดการณ์การเปลี่ยนแปลงนี้ Rails 4.2 ได้เพิ่มตัวเลือกการกำหนดค่าใหม่ `active_support.test_order` เพื่อระบุลำดับของการทดสอบโดยชัดเจน สิ่งนี้ช่วยให้คุณสามารถล็อคพฤติกรรมปัจจุบันได้โดยกำหนดค่าตัวเลือกเป็น `:sorted` หรือเลือกใช้พฤติกรรมในอนาคตโดยกำหนดค่าตัวเลือกเป็น `:random`

หากคุณไม่ระบุค่าสำหรับตัวเลือกนี้ จะมีการแจ้งเตือนการเลิกใช้งาน หากต้องการหลีกเลี่ยงข้อผิดพลาดนี้ ให้เพิ่มบรรทัดต่อไปนี้ในสภาพแวดล้อมการทดสอบของคุณ:

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # หรือ `:random` ถ้าคุณต้องการ
end
```

### คุณสมบัติที่ถูกซีรีไลซ์

เมื่อใช้ coder ที่กำหนดเอง (เช่น `serialize :metadata, JSON`) การกำหนดค่า `nil` ให้กับคุณสมบัติที่ถูกซีรีไลซ์จะบันทึกลงในฐานข้อมูลเป็น `NULL` แทนที่จะส่งค่า `nil` ผ่าน coder (เช่น `"null"` เมื่อใช้ coder `JSON`)

### ระดับการบันทึกของ production log

ใน Rails 5 ระดับการบันทึกเริ่มต้นสำหรับสภาพแวดล้อมการผลิตจะถูกเปลี่ยนเป็น `:debug` (จาก `:info`) เพื่อรักษาค่าเริ่มต้นปัจจุบัน ให้เพิ่มบรรทัดต่อไปนี้ใน `production.rb` เพื่อรักษาค่าเริ่มต้นปัจจุบัน:

```ruby
# ตั้งค่าเป็น `:info` เพื่อให้ตรงกับค่าเริ่มต้นปัจจุบัน หรือตั้งค่าเป็น `:debug` เพื่อเลือกใช้ค่าเริ่มต้นในอนาคต
config.log_level = :info
```

### `after_bundle` ใน Rails templates

หากคุณมีเทมเพลต Rails ที่เพิ่มไฟล์ทั้งหมดในการควบคุมรุ่น การเพิ่ม binstubs ที่สร้างขึ้นล้มเหลวเนื่องจากมันถูกดำเนินการก่อน Bundler:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```
ตอนนี้คุณสามารถใช้ `git` calls ใน `after_bundle` block ได้แล้ว มันจะถูกเรียกใช้หลังจาก binstubs ถูกสร้างขึ้น

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

### Rails HTML Sanitizer

มีตัวเลือกใหม่สำหรับการทำความสะอาด HTML fragments ในแอปพลิเคชันของคุณ วิธีการ html-scanner ที่เก่าแก่ถูกประกาศเป็นเลือกใช้ทางอย่างเป็นทางการแล้วในการสนับสนุน [`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer).

นี้หมายความว่าเมธอด `sanitize`, `sanitize_css`, `strip_tags` และ `strip_links` จะถูกสนับสนุนโดยการสร้างใหม่

Sanitizer ใหม่นี้ใช้ [Loofah](https://github.com/flavorjones/loofah) ภายใน ซึ่งในลำดับต่อมาใช้ Nokogiri ซึ่งห่อหุ้ม XML parsers ที่เขียนด้วยภาษา C และ Java ดังนั้นการทำความสะอาดควรเร็วขึ้นไม่ว่าคุณจะใช้เวอร์ชันของ Ruby ใด

เวอร์ชันใหม่อัปเดต `sanitize` เพื่อให้สามารถใช้ `Loofah::Scrubber` ได้สำหรับการทำความสะอาดที่มีประสิทธิภาพ
[ดูตัวอย่างของ scrubbers ที่นี่](https://github.com/flavorjones/loofah#loofahscrubber).

ยังเพิ่ม scrubbers ใหม่อีก 2 ตัวคือ `PermitScrubber` และ `TargetScrubber`.
อ่าน [readme ของ gem](https://github.com/rails/rails-html-sanitizer) เพื่อดูข้อมูลเพิ่มเติม

เอกสารสำหรับ `PermitScrubber` และ `TargetScrubber` อธิบายวิธีการควบคุมทั้งหมดเมื่อและวิธีที่จะตัดองค์ประกอบ

หากแอปพลิเคชันของคุณต้องการใช้การทำความสะอาดเก่า รวม `rails-deprecated_sanitizer` เข้าไปใน `Gemfile` ของคุณ:

```ruby
gem 'rails-deprecated_sanitizer'
```

### Rails DOM Testing

[`TagAssertions` module](https://api.rubyonrails.org/v4.1/classes/ActionDispatch/Assertions/TagAssertions.html) (ที่มีเมธอดเช่น `assert_tag`) [ถูกประกาศเป็นเลือกใช้แล้ว](https://github.com/rails/rails/blob/6061472b8c310158a2a2e8e9a6b81a1aef6b60fe/actionpack/lib/action_dispatch/testing/assertions/dom.rb) ในการสนับสนุนเมธอด `assert_select` จาก `SelectorAssertions` module ซึ่งถูกแยกออกเป็น [rails-dom-testing gem](https://github.com/rails/rails-dom-testing).

### Masked Authenticity Tokens

เพื่อลดความเสี่ยงจากการโจมตี SSL `form_authenticity_token` ถูกเปลี่ยนให้มีการปกปิดเพื่อให้เปลี่ยนแปลงไปพร้อมกับแต่ละคำขอ ดังนั้น โทเค็นจะถูกตรวจสอบโดยการปกปิดและถอดรหัส ด้วยเหตุนี้ กลยุทธ์ใดก็ตามสำหรับการยืนยันคำขอจากแบบฟอร์มที่ไม่ใช่ของ Rails ที่พึงพอใจกับโทเค็น CSRF ของเซสชันที่คงที่จะต้องพิจารณาเรื่องนี้

### Action Mailer

ก่อนหน้านี้ เรียกใช้เมธอดของเมลเลอร์ในคลาสเมลเลอร์จะทำให้เรียกใช้เมธอดของอินสแตนซ์ที่เกี่ยวข้องโดยตรง ด้วยการเริ่มใช้งาน Active Job และ `#deliver_later` สิ่งนี้ไม่เป็นจริงอีกต่อไปใน Rails 4.2 การเรียกใช้เมธอดของอินสแตนซ์ถูกเลื่อนไปจนกว่า `deliver_now` หรือ `deliver_later` จะถูกเรียก ตัวอย่างเช่น:

```ruby
class Notifier < ActionMailer::Base
  def notify(user, ...)
    puts "Called"
    mail(to: user.email, ...)
  end
end
```

```ruby
mail = Notifier.notify(user, ...) # Notifier#notify ยังไม่ถูกเรียกในจุดนี้
mail = mail.deliver_now           # พิมพ์ "Called"
```

สิ่งนี้ไม่ควรทำให้เกิดความแตกต่างที่สังเกตเห็นได้สำหรับแอปพลิเคชันส่วนใหญ่ อย่างไรก็ตามหากคุณต้องการให้เมธอดที่ไม่ใช่เมลเลอร์ถูกเรียกโดยเดียวกันและคุณกำลังพึ่งพาการส่งทางเดียวกัน คุณควรกำหนดให้เป็นเมธอดคลาสบนคลาสเมลเลอร์โดยตรง:
```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users, ...)
    users.each { |user| Notifier.notify(user, ...) }
  end
end
```

### การสนับสนุน Foreign Key

DSL การเมืองได้ถูกขยายเพื่อสนับสนุนการกำหนดค่า Foreign Key หากคุณใช้ Foreigner gem คุณอาจต้องการพิจารณาการลบมัน โปรดทราบว่าการสนับสนุน Foreign Key ของ Rails เป็นส่วนหนึ่งของ Foreigner นั่นหมายความว่าไม่ใช่ทุกคำนิยามของ Foreigner สามารถแทนที่ได้ด้วย DSL การเมืองของ Rails

ขั้นตอนการเมืองคือดังนี้:

1. ลบ `gem "foreigner"` จาก `Gemfile`.
2. รัน `bundle install`.
3. รัน `bin/rake db:schema:dump`.
4. ตรวจสอบให้แน่ใจว่า `db/schema.rb` มีคำนิยาม Foreign Key ทุกคำนิยามที่จำเป็น

การอัปเกรดจาก Rails 4.0 เป็น Rails 4.1
-------------------------------------

### การป้องกัน CSRF จากแท็ก `<script>` ระยะไกล

หรือ "ทำไมทดสอบของฉันล้มเหลว !!!?" หรือ "วิดเจ็ต `<script>` ของฉันเสียหาย !!"

การป้องกัน Cross-site request forgery (CSRF) ตอนนี้รวมการร้องขอ GET ด้วยการตอบสนองของ JavaScript ด้วย ซึ่งป้องกันการเว็บไซต์บุคคลที่สามจากการอ้างอิง JavaScript ของคุณด้วยแท็ก `<script>` เพื่อสกัดข้อมูลที่เป็นความลับ

นั่นหมายความว่าการทดสอบฟังก์ชันและการรวมกันที่ใช้

```ruby
get :index, format: :js
```

จะเป็นการเรียกใช้การป้องกัน CSRF ตอนนี้ ให้เปลี่ยนเป็น

```ruby
xhr :get, :index, format: :js
```

เพื่อทดสอบ `XmlHttpRequest` โดยชัดเจน

หมายเหตุ: แท็ก `<script>` ของคุณเองถูกจัดการเป็น cross-origin และถูกบล็อกโดยค่าเริ่มต้นด้วย หากคุณต้องการโหลด JavaScript จากแท็ก `<script>` คุณต้องป้องกัน CSRF โดยชัดเจนในการกระทำเหล่านั้น

### Spring

หากคุณต้องการใช้ Spring เป็นตัวโหลดล่วงหน้าของแอปพลิเคชันของคุณคุณต้อง:

1. เพิ่ม `gem 'spring', group: :development` ใน `Gemfile` ของคุณ
2. ติดตั้ง spring โดยใช้ `bundle install`
3. สร้าง Spring binstub ด้วย `bundle exec spring binstub`

หมายเหตุ: งาน rake ที่กำหนดเองของผู้ใช้จะทำงานในสภาพแวดล้อม `development` โดยค่าเริ่มต้น หากคุณต้องการให้พวกเขาทำงานในสภาพแวดล้อมอื่น ๆ โปรดอ่าน [Spring README](https://github.com/rails/spring#rake)

### `config/secrets.yml`

หากคุณต้องการใช้กฎเกณฑ์ใหม่ `secrets.yml` เพื่อเก็บความลับของแอปพลิเคชันของคุณคุณต้อง:

1. สร้างไฟล์ `secrets.yml` ในโฟลเดอร์ `config` ของคุณด้วยเนื้อหาต่อไปนี้:

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. ใช้ `secret_key_base` ที่มีอยู่ในตัวกำหนด `secret_token.rb` เพื่อตั้งค่าตัวแปรสภาพแวดล้อม `SECRET_KEY_BASE` สำหรับผู้ใช้ที่กำลังเรียกใช้แอปพลิเคชัน Rails ในโหมดการผลิต หรือคุณสามารถคัดลอก `secret_key_base` ที่มีอยู่ในตัวกำหนด `secret_token.rb` เข้าไปใน `secrets.yml` ภายใต้ส่วน `production` โดยแทนที่ `<%= ENV["SECRET_KEY_BASE"] %>` 

3. ลบตัวกำหนด `secret_token.rb`

4. ใช้ `rake secret` เพื่อสร้างคีย์ใหม่สำหรับส่วน `development` และ `test`
5. รีสตาร์ทเซิร์ฟเวอร์ของคุณ

### การเปลี่ยนแปลงในเครื่องมือช่วยทดสอบ

หากเครื่องมือช่วยทดสอบของคุณมีการเรียกใช้ `ActiveRecord::Migration.check_pending!` คุณสามารถลบส่วนนี้ออกได้ การตรวจสอบจะถูกดำเนินการโดยอัตโนมัติเมื่อคุณ `require "rails/test_help"` แม้ว่าการเก็บบรรทัดนี้ไว้ในเครื่องมือช่วยทดสอบของคุณจะไม่เป็นอันตรายใดๆ

### การตั้งค่าการสร้างคุกกี้

แอปพลิเคชันที่สร้างก่อน Rails 4.1 ใช้ `Marshal` เพื่อทำการสร้างค่าคุกกี้ในลังคุกกี้ที่ถูกเซ็นต์และเข้ารหัส หากคุณต้องการใช้รูปแบบใหม่ที่ใช้ `JSON` ในแอปพลิเคชันของคุณ คุณสามารถเพิ่มไฟล์เริ่มต้นด้วยเนื้อหาต่อไปนี้:

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

นี้จะทำให้คุกกี้ที่ถูกสร้างด้วย `Marshal` ถูกย้ายไปใช้รูปแบบใหม่ที่ใช้ `JSON` ได้อัตโนมัติ

เมื่อใช้ตัวแปรแปลง `:json` หรือ `:hybrid` คุณควรระวังว่าไม่สามารถแปลงวัตถุ Ruby ทั้งหมดเป็น JSON ได้ ตัวอย่างเช่น วัตถุ `Date` และ `Time` จะถูกแปลงเป็นสตริง และ `Hash` จะมีคีย์ของตัวเองถูกแปลงเป็นสตริง

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

ควรใช้เก็บข้อมูลที่เรียบง่าย (สตริงและตัวเลข) ในคุกกี้เท่านั้น หากต้องการเก็บวัตถุที่ซับซ้อน คุณจะต้องจัดการการแปลงด้วยตนเองเมื่ออ่านค่าในคำขอถัดไป

หากคุณใช้การเก็บคุกกี้แบบเซสชัน สิ่งนี้จะใช้กับ `session` และ `flash` ด้วย

### การเปลี่ยนแปลงโครงสร้าง Flash

คีย์ข้อความ Flash ถูก [เปลี่ยนเป็นสตริง](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1) ตัวเลือกในการเข้าถึงยังคงสามารถใช้ทั้งด้วยสัญลักษณ์หรือสตริง การวนซ้ำผ่าน Flash จะเสมอให้คีย์เป็นสตริง:

```ruby
flash["string"] = "a string"
flash[:symbol] = "a symbol"

# Rails < 4.1
flash.keys # => ["string", :symbol]

# Rails >= 4.1
flash.keys # => ["string", "symbol"]
```

ตรวจสอบให้แน่ใจว่าคุณเปรียบเทียบคีย์ข้อความ Flash เป็นสตริง

### การเปลี่ยนแปลงในการจัดการ JSON

มีการเปลี่ยนแปลงหลักในการจัดการ JSON ใน Rails 4.1

#### การลบ MultiJSON

MultiJSON ได้ถึง [จุดสิ้นสุดชีวิต](https://github.com/rails/rails/pull/10576) และถูกลบออกจาก Rails

หากแอปพลิเคชันของคุณขึ้นอยู่กับ MultiJSON โดยตรง คุณมีตัวเลือกหลายอย่าง:

1. เพิ่ม 'multi_json' เข้าไปใน `Gemfile` โปรดทราบว่าสิ่งนี้อาจไม่สามารถทำงานได้อีกต่อไป

2. ย้ายออกจาก MultiJSON โดยใช้ `obj.to_json` และ `JSON.parse(str)` แทน

คำเตือน: อย่าเพียงแค่แทนที่ `MultiJson.dump` และ `MultiJson.load` ด้วย `JSON.dump` และ `JSON.load` การใช้ JSON gem APIs เหล่านี้เป็นไว้สำหรับการแปลงวัตถุ Ruby อย่างอิสระและโดยทั่วไป [ไม่ปลอดภัย](https://ruby-doc.org/stdlib-2.2.2/libdoc/json/rdoc/JSON.html#method-i-load)

#### ความเข้ากันได้ของ JSON gem

ในอดีต Rails มีปัญหาความเข้ากันไม่ได้กับ JSON gem การใช้ `JSON.generate` และ `JSON.dump` ภายในแอปพลิเคชัน Rails อาจสร้างข้อผิดพลาดที่ไม่คาดคิด
Rails 4.1 แก้ไขปัญหาเหล่านี้โดยแยกตัวเข้ารหัสของตัวเองออกจาก JSON gem  API ของ JSON gem จะทำงานเหมือนเดิม แต่จะไม่สามารถเข้าถึงคุณสมบัติที่เฉพาะเจาะจงของ Rails ได้ เช่น:

```ruby
class FooBar
  def as_json(options = nil)
    { foo: 'bar' }
  end
end
```

```irb
irb> FooBar.new.to_json
=> "{\"foo\":\"bar\"}"
irb> JSON.generate(FooBar.new, quirks_mode: true)
=> "\"#<FooBar:0x007fa80a481610>\""
```

#### ตัวเข้ารหัส JSON ใหม่

ตัวเข้ารหัส JSON ใน Rails 4.1 ได้รับการเขียนใหม่ให้ใช้ประโยชน์จาก JSON gem สำหรับแอปพลิเคชันส่วนใหญ่นี้ควรเป็นการเปลี่ยนแปลงโดยที่ไม่ต้องสนใจ อย่างไรก็ตาม ในกระบวนการเขียนใหม่นี้ คุณสมบัติต่อไปนี้ถูกลบออกจากตัวเข้ารหัส:

1. การตรวจสอบโครงสร้างข้อมูลแบบวงกลม
2. การสนับสนุนการเชื่อมโยง `encode_json`
3. ตัวเลือกในการเข้ารหัสวัตถุ `BigDecimal` เป็นตัวเลขแทนสตริง

หากแอปพลิเคชันของคุณขึ้นอยู่กับคุณสมบัติหนึ่งในเหล่านี้ คุณสามารถใช้เพิ่มเติมได้โดยเพิ่ม gem [`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder) เข้าไปใน `Gemfile` ของคุณ

#### การแสดงผล JSON ของวัตถุเวลา

`#as_json` สำหรับวัตถุที่มีส่วนของเวลา (`Time`, `DateTime`, `ActiveSupport::TimeWithZone`) ตอนนี้จะคืนค่าด้วยความแม่นยำในระดับมิลลิวินาทีโดยค่าเริ่มต้น หากคุณต้องการเก็บพฤติกรรมเดิมที่ไม่มีความแม่นยำในระดับมิลลิวินาที ให้ตั้งค่าต่อไปนี้ในไฟล์เริ่มต้น:

```ruby
ActiveSupport::JSON::Encoding.time_precision = 0
```

### การใช้ `return` ภายในบล็อก callback แบบอินไลน์

ก่อนหน้านี้ Rails อนุญาตให้บล็อก callback แบบอินไลน์ใช้ `return` ได้ดังนี้:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # ไม่ดี
end
```

พฤติกรรมนี้ไม่เคยได้รับการสนับสนุนอย่างเป็นทางการ ด้วยเหตุผลที่เปลี่ยนแปลงภายใน `ActiveSupport::Callbacks` นี้จึงไม่ได้รับอนุญาตใน Rails 4.1 การใช้คำสั่ง `return` ในบล็อก callback แบบอินไลน์จะทำให้เกิด `LocalJumpError` เมื่อทำการเรียกใช้งาน callback

บล็อก callback แบบอินไลน์ที่ใช้ `return` สามารถเปลี่ยนรูปแบบเพื่อให้คืนค่าที่ต้องการได้:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # ดี
end
```

หรือหากต้องการใช้ `return` แนะนำให้กำหนดเมธอดโดยชัดเจน:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # ดี

  private
    def before_save_callback
      false
    end
end
```

การเปลี่ยนแปลงนี้ใช้กับส่วนใหญ่ของสถานที่ใน Rails ที่ใช้งาน callback รวมถึง Active Record และ Active Model callbacks และตัวกรองใน Action Controller (เช่น `before_action`)

ดู [pull request นี้](https://github.com/rails/rails/pull/13271) เพื่อข้อมูลเพิ่มเติม

### เมธอดที่กำหนดใน Active Record fixtures

Rails 4.1 จะประเมิน ERB ของแต่ละ fixture ใน context ที่แยกต่างหาก ดังนั้นเมธอดช่วยเหลือที่กำหนดใน fixture จะไม่สามารถใช้งานได้ใน fixture อื่น

เมธอดช่วยเหลือที่ใช้ใน fixture หลายแห่งควรถูกกำหนดในโมดูลที่รวมอยู่ใน `ActiveRecord::FixtureSet.context_class` ที่มีการนำเสนอใน `test_helper.rb`
```ruby
module FixtureFileHelpers
  def file_sha(path)
    OpenSSL::Digest::SHA256.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

### I18n บังคับให้ใช้ locale ที่มีอยู่เท่านั้น

Rails 4.1 ตอนนี้เปลี่ยนค่าเริ่มต้นของ I18n option `enforce_available_locales` เป็น `true` นั่นหมายความว่ามันจะตรวจสอบให้แน่ใจว่า locale ที่ถูกส่งให้มันต้องถูกประกาศในรายการ `available_locales`

ในการปิดการใช้งาน (และอนุญาตให้ I18n ยอมรับ locale ใดๆ) เพิ่มการกำหนดค่าต่อไปนี้ในแอปพลิเคชันของคุณ:

```ruby
config.i18n.enforce_available_locales = false
```

โปรดทราบว่าตัวเลือกนี้ถูกเพิ่มเป็นมาตรการด้านความปลอดภัยเพื่อให้แน่ใจว่าข้อมูลที่ผู้ใช้ป้อนเข้ามาไม่สามารถใช้เป็นข้อมูล locale ได้เว้นแต่จะมีการรู้ล่วงหน้า ดังนั้น แนะนำให้ไม่ปิดการใช้งานตัวเลือกนี้เว้นแต่จะมีเหตุผลที่แข็งแกร่งในการทำเช่นนั้น

### เมธอด Mutator ที่เรียกใช้บน Relation

`Relation` ไม่มีเมธอด Mutator เช่น `#map!` และ `#delete_if` อีกต่อไป ให้แปลงเป็น `Array` โดยเรียกใช้ `#to_a` ก่อนใช้เมธอดเหล่านี้

มันจะป้องกันบั๊กแปลกๆ และความสับสนในโค้ดที่เรียกใช้เมธอด Mutator โดยตรงบน `Relation`

```ruby
# แทนที่
Author.where(name: 'Hank Moody').compact!

# ตอนนี้คุณต้องทำแบบนี้
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
```

### การเปลี่ยนแปลงใน Default Scopes

Default scopes ไม่ได้ถูกเขียนทับโดยเงื่อนไขที่เชื่อมต่อกันอีกต่อไป

ในเวอร์ชันก่อนหน้า เมื่อคุณกำหนด `default_scope` ในโมเดล มันจะถูกเขียนทับโดยเงื่อนไขที่เชื่อมต่อกันในฟิลด์เดียวกัน ตอนนี้มันถูกผสมเข้าด้วยกันเหมือนกับสเก็ตอื่นๆ

ก่อน:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

หลัง:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

ในการใช้พฤติกรรมก่อนหน้านี้ จำเป็นต้องลบเงื่อนไข `default_scope` โดยชัดเจนโดยใช้ `unscoped`, `unscope`, `rewhere` หรือ `except`

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { unscope(where: :state).where(state: 'active') }
  scope :inactive, -> { rewhere state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

### การแสดงเนื้อหาจากสตริง

Rails 4.1 นำเสนอตัวเลือก `:plain`, `:html`, และ `:body` ให้กับ `render` ตัวเลือกเหล่านี้เป็นวิธีที่แนะนำในการแสดงเนื้อหาที่เป็นสตริง เนื่องจากมันช่วยให้คุณสามารถระบุประเภทเนื้อหาที่คุณต้องการให้ตอบกลับได้

* `render :plain` จะตั้งค่าประเภทเนื้อหาเป็น `text/plain`
* `render :html` จะตั้งค่าประเภทเนื้อหาเป็น `text/html`
* `render :body` จะ *ไม่* ตั้งค่าส่วนหัวประเภทเนื้อหา

จากมุมมองด้านความปลอดภัย หากคุณไม่คาดหวังว่าจะมีมาร์กอัปในเนื้อหาของคำตอบ คุณควรใช้ `render :plain` เนื่องจากเบราว์เซอร์ส่วนใหญ่จะหนีการแสดงเนื้อหาที่ไม่ปลอดภัยในคำตอบให้คุณ

เราจะเลิกใช้ `render :text` ในเวอร์ชันที่จะมาในอนาคต ดังนั้นโปรดเริ่มใช้ตัวเลือก `:plain`, `:html`, และ `:body` ที่มีความแม่นยำมากขึ้นแทน การใช้ `render :text` อาจเป็นความเสี่ยงด้านความปลอดภัย เนื่องจากเนื้อหาถูกส่งเป็น `text/html`

### ประเภทข้อมูล JSON และ hstore ใน PostgreSQL

Rails 4.1 จะแมปคอลัมน์ `json` และ `hstore` เป็น `Hash` ที่มีคีย์เป็นสตริงใน Ruby ในเวอร์ชันก่อนหน้านี้ใช้ `HashWithIndifferentAccess` ซึ่งหมายความว่าการเข้าถึงด้วยสัญลักษณ์ไม่ได้รับการสนับสนุนอีกต่อไป สิ่งเดียวกันเป็นไปสำหรับ `store_accessors` ที่พื้นฐานบนคอลัมน์ `json` หรือ `hstore` โปรดใช้สตริงเป็นคีย์อย่างสม่ำเสมอ

### การใช้บล็อกแบบชัดเจนสำหรับ `ActiveSupport::Callbacks`

Rails 4.1 ต้องการให้ส่งบล็อกแบบชัดเจนเมื่อเรียกใช้ `ActiveSupport::Callbacks.set_callback` การเปลี่ยนนี้เกิดจากการเขียนใหม่ของ `ActiveSupport::Callbacks` ในเวอร์ชัน 4.1

```ruby
# ก่อนหน้านี้ใน Rails 4.0
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# ตอนนี้ใน Rails 4.1
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

การอัปเกรดจาก Rails 3.2 เป็น Rails 4.0
-------------------------------------

หากแอปพลิเคชันของคุณอยู่ในรุ่นของ Rails ที่เก่ากว่า 3.2.x คุณควรอัปเกรดเป็น Rails 3.2 ก่อนที่จะพยายามอัปเกรดเป็น Rails 4.0

การเปลี่ยนแปลงต่อไปนี้เหมาะสำหรับการอัปเกรดแอปพลิเคชันของคุณเป็น Rails 4.0

### HTTP PATCH

Rails 4 ใช้ `PATCH` เป็น HTTP verb หลักสำหรับการอัปเดตเมื่อมีการประกาศทรัพยากร RESTful ใน `config/routes.rb` การกระทำ `update` ยังคงใช้งานต่อไป และคำขอ `PUT` จะยังคงถูกนำเข้าสู่การกระทำ `update` ดังนั้นหากคุณใช้เฉพาะเส้นทาง RESTful มาตรฐาน ไม่จำเป็นต้องทำการเปลี่ยนแปลง:

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # ไม่ต้องเปลี่ยนแปลง; PATCH จะถูกเลือกไว้เป็นอันดับแรก และ PUT ยังคงทำงานได้
  end
end
```
อย่างไรก็ตาม คุณจะต้องทำการเปลี่ยนแปลงหากคุณกำลังใช้ `form_for` เพื่ออัปเดตทรัพยากรในการใช้งานร่วมกับเส้นทางที่กำหนดเองโดยใช้วิธีการ `PUT` HTTP:

```ruby
resources :users do
  put :update_name, on: :member
end
```

```erb
<%= form_for [ :update_name, @user ] do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update_name
    # ต้องทำการเปลี่ยนแปลง; form_for จะพยายามใช้เส้นทาง PATCH ที่ไม่มีอยู่จริง
  end
end
```

หากไม่ได้ใช้การกระทำใน API สาธารณะและคุณสามารถเปลี่ยนแปลงวิธีการ HTTP ได้เลย คุณสามารถอัปเดตเส้นทางของคุณเพื่อใช้ `patch` แทน `put`:

```ruby
resources :users do
  patch :update_name, on: :member
end
```

คำขอ `PUT` ไปยัง `/users/:id` ใน Rails 4 จะถูกเส้นทางไปยัง `update` เหมือนกับที่เป็นอยู่ในปัจจุบัน ดังนั้นหากคุณมี API ที่ได้รับคำขอ PUT จริง มันก็จะทำงานได้ ตัวเส้นทางยังเส้นทางคำขอ `PATCH` ไปยัง `/users/:id` ไปยังการกระทำ `update` เช่นกัน

หากการกระทำถูกใช้ใน API สาธารณะและคุณไม่สามารถเปลี่ยนแปลงวิธีการ HTTP ที่ใช้ได้ คุณสามารถอัปเดตฟอร์มของคุณเพื่อใช้วิธีการ `PUT` แทน:

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับ PATCH และเหตุผลที่ทำการเปลี่ยนแปลงนี้ โปรดดู [โพสต์นี้](https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/) ในบล็อกของ Rails

#### หมายเหตุเกี่ยวกับชนิดสื่อ

ข้อผิดพลาดสำหรับคำสั่ง `PATCH` [ระบุว่าควรใช้ชนิดสื่อ 'diff' กับ `PATCH`](http://www.rfc-editor.org/errata_search.php?rfc=5789) หนึ่งในรูปแบบคือ [JSON Patch](https://tools.ietf.org/html/rfc6902) แม้ว่า Rails จะไม่รองรับ JSON Patch อย่างเป็นธรรมชาติ แต่มันง่ายมากที่จะเพิ่มการสนับสนุน:

```ruby
# ในคอนโทรลเลอร์ของคุณ:
def update
  respond_to do |format|
    format.json do
      # ทำการอัปเดตบางส่วน
      @article.update params[:article]
    end

    format.json_patch do
      # ทำการเปลี่ยนแปลงที่ซับซ้อน
    end
  end
end
```

```ruby
# config/initializers/json_patch.rb
Mime::Type.register 'application/json-patch+json', :json_patch
```

เนื่องจาก JSON Patch เพิ่งเป็น RFC เมื่อเร็วๆ นี้ ยังไม่มีห้องสมุด Ruby ที่ดีมาก แต่ Aaron Patterson's
[hana](https://github.com/tenderlove/hana) เป็นหนึ่งใน gem ที่ดี แต่ไม่มีการสนับสนุนที่เต็มรูปแบบสำหรับการเปลี่ยนแปลงสุดท้ายในข้อกำหนด

### Gemfile

Rails 4.0 ได้ลบกลุ่ม `assets` ออกจาก `Gemfile` คุณจะต้องลบบรรทัดนั้นออกจาก `Gemfile` เมื่อคุณอัปเกรด คุณยังควรอัปเดตไฟล์แอปพลิเคชันของคุณ (ใน `config/application.rb`):

```ruby
# ต้องการ gem ที่ระบุใน Gemfile รวมถึง gem ที่
# คุณจำกัดไว้เฉพาะใน :test, :development หรือ :production
Bundler.require(*Rails.groups)
```

### vendor/plugins

Rails 4.0 ไม่รองรับการโหลดปลั๊กอินจาก `vendor/plugins` คุณต้องแทนที่ปลั๊กอินด้วยการแยกเป็น gem และเพิ่มเข้าไปใน `Gemfile` หากคุณไม่ต้องการทำให้เป็น gem คุณสามารถย้ายมันไปที่, ตัวอย่างเช่น, `lib/my_plugin/*` และเพิ่มตัวกำเนิดที่เหมาะสมใน `config/initializers/my_plugin.rb`
### Active Record

* Rails 4.0 ได้ลบ identity map ออกจาก Active Record เนื่องจากมีความไม่สอดคล้องกับ associations บางอย่าง (https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6) หากคุณเปิดใช้งานมันด้วยตัวเองในแอปพลิเคชันของคุณ คุณจะต้องลบการตั้งค่าต่อไปนี้ที่ไม่มีผลอีกต่อไป: `config.active_record.identity_map`.

* เมธอด `delete` ใน collection associations ตอนนี้สามารถรับอาร์กิวเมนต์เป็น `Integer` หรือ `String` เป็นไอดีของเรคคอร์ดได้เช่นเดียวกับเมธอด `destroy` ที่ทำได้ก่อนหน้านี้ ก่อนหน้านี้มันจะเรียก `ActiveRecord::AssociationTypeMismatch` สำหรับอาร์กิวเมนต์เช่นนั้น ตั้งแต่ Rails 4.0 เป็นต้นไป `delete` จะพยายามค้นหาเรคคอร์ดที่ตรงกับไอดีที่กำหนดก่อนที่จะลบเรคคอร์ดเหล่านั้น

* ใน Rails 4.0 เมื่อเปลี่ยนชื่อคอลัมน์หรือตาราง ดัชนีที่เกี่ยวข้องก็จะถูกเปลี่ยนชื่อด้วย หากคุณมีการเปลี่ยนชื่อดัชนีในการทำฐานข้อมูล คุณไม่จำเป็นต้องใช้มันอีกต่อไป

* Rails 4.0 ได้เปลี่ยน `serialized_attributes` และ `attr_readonly` เป็นเมธอดคลาสเท่านั้น คุณไม่ควรใช้เมธอดอินสแตนซ์เนื่องจากถูกเลิกใช้แล้ว คุณควรเปลี่ยนมันให้ใช้เมธอดคลาส เช่น `self.serialized_attributes` เป็น `self.class.serialized_attributes`.

* เมื่อใช้ coder เริ่มต้น การกำหนดค่า `nil` ให้กับ attribute ที่ถูกซีเรียลไว้จะบันทึกลงในฐานข้อมูลเป็น `NULL` แทนที่จะผ่านค่า `nil` ผ่าน YAML (`"--- \n...\n"`).

* Rails 4.0 ได้ลบคุณสมบัติ `attr_accessible` และ `attr_protected` เพื่อสนับสนุน Strong Parameters คุณสามารถใช้ [Protected Attributes gem](https://github.com/rails/protected_attributes) เพื่ออัปเกรดได้อย่างราบรื่น

* หากคุณไม่ใช้ Protected Attributes คุณสามารถลบตัวเลือกที่เกี่ยวข้องกับ gem เช่น `whitelist_attributes` หรือ `mass_assignment_sanitizer` ออกได้

* Rails 4.0 ต้องการให้ scopes ใช้วัตถุที่เรียกได้เช่น Proc หรือ lambda:

    ```ruby
      scope :active, where(active: true)

      # เปลี่ยนเป็น
      scope :active, -> { where active: true }
    ```

* Rails 4.0 ได้เลิกใช้ `ActiveRecord::Fixtures` และใช้ `ActiveRecord::FixtureSet` แทน

* Rails 4.0 ได้เลิกใช้ `ActiveRecord::TestCase` และใช้ `ActiveSupport::TestCase` แทน

* Rails 4.0 ได้เลิกใช้ API แบบเก่าที่ใช้ hash เป็นพารามิเตอร์ในการค้นหา นั่นหมายความว่าเมธอดที่กำหนด "finder options" ก่อนหน้านี้จะไม่ทำงานอีกต่อไป ตัวอย่างเช่น `Book.find(:all, conditions: { name: '1984' })` ได้ถูกเลิกใช้และใช้ `Book.where(name: '1984')` แทน

* เมื่อใช้ dynamic methods ทั้งหมดยกเว้น `find_by_...` และ `find_by_...!` ได้ถูกเลิกใช้ นี่คือวิธีการจัดการกับการเปลี่ยนแปลง:

      * `find_all_by_...`           เปลี่ยนเป็น `where(...)`.
      * `find_last_by_...`          เปลี่ยนเป็น `where(...).last`.
      * `scoped_by_...`             เปลี่ยนเป็น `where(...)`.
      * `find_or_initialize_by_...` เปลี่ยนเป็น `find_or_initialize_by(...)`.
      * `find_or_create_by_...`     เปลี่ยนเป็น `find_or_create_by(...)`.

* โปรดทราบว่า `where(...)` จะส่งคืน relation ไม่ใช่อาร์เรย์เหมือน finders เก่า หากคุณต้องการอาร์เรย์ ให้ใช้ `where(...).to_a`.

* เมทอดเหล่านี้ที่เทียบเท่าอาจไม่ execute SQL เดียวกับการประมวลผลเดิม

* เพื่อเปิดใช้งาน finders เก่า คุณสามารถใช้ [activerecord-deprecated_finders gem](https://github.com/rails/activerecord-deprecated_finders)
* Rails 4.0 ได้เปลี่ยนตารางเชื่อมโยงเริ่มต้นสำหรับความสัมพันธ์ `has_and_belongs_to_many` ให้ตัดคำนำหน้าที่ซ้ำกันออกจากชื่อตารางที่สอง ความสัมพันธ์ `has_and_belongs_to_many` ที่มีคำนำหน้าที่ซ้ำกันระหว่างโมเดลต้องระบุด้วยตัวเลือก `join_table` ตัวอย่างเช่น:

    ```ruby
    CatalogCategory < ActiveRecord::Base
      has_and_belongs_to_many :catalog_products, join_table: 'catalog_categories_catalog_products'
    end

    CatalogProduct < ActiveRecord::Base
      has_and_belongs_to_many :catalog_categories, join_table: 'catalog_categories_catalog_products'
    end
    ```

* โปรดทราบว่าคำนำหน้านี้ใช้ขอบเขตของสเกาป์เช่นกัน ดังนั้นความสัมพันธ์ระหว่าง `Catalog::Category` และ `Catalog::Product` หรือ `Catalog::Category` และ `CatalogProduct` ต้องอัปเดตในลักษณะเดียวกัน

### Active Resource

Rails 4.0 ได้แยก Active Resource ออกเป็น gem ของตัวเอง หากคุณยังต้องการคุณลักษณะนี้คุณสามารถเพิ่ม [Active Resource gem](https://github.com/rails/activeresource) ใน `Gemfile` ของคุณได้

### Active Model

* Rails 4.0 ได้เปลี่ยนวิธีการแนบข้อผิดพลาดกับ `ActiveModel::Validations::ConfirmationValidator` ตอนนี้เมื่อการตรวจสอบการยืนยันล้มเหลว ข้อผิดพลาดจะถูกแนบไปที่ `:#{attribute}_confirmation` แทนที่ `attribute`

* Rails 4.0 ได้เปลี่ยนค่าเริ่มต้นของ `ActiveModel::Serializers::JSON.include_root_in_json` เป็น `false` ตอนนี้ Active Model Serializers และออบเจ็กต์ Active Record มีพฤติกรรมเริ่มต้นเหมือนกัน นี่หมายความว่าคุณสามารถคอมเมนต์หรือลบตัวเลือกต่อไปนี้ในไฟล์ `config/initializers/wrap_parameters.rb` ได้

    ```ruby
    # Disable root element in JSON by default.
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    ```

### Action Pack

* Rails 4.0 นำเสนอ `ActiveSupport::KeyGenerator` และใช้เป็นฐานในการสร้างและตรวจสอบคุกกี้ที่ลงชื่อ (signed cookies) (รวมถึงอย่างอื่น) คุกกี้ที่ลงชื่อก่อนหน้านี้ที่สร้างด้วย Rails 3.x จะถูกอัปเกรดโดยอัตโนมัติหากคุณปล่อย `secret_token` เดิมของคุณไว้และเพิ่ม `secret_key_base` ใหม่

    ```ruby
      # config/initializers/secret_token.rb
      Myapp::Application.config.secret_token = 'existing secret token'
      Myapp::Application.config.secret_key_base = 'new secret key base'
    ```

    โปรดทราบว่าคุณควรรอการตั้งค่า `secret_key_base` จนกว่าคุณจะมีผู้ใช้ทั้งหมดของคุณใช้ Rails 4.x และมั่นใจได้ว่าคุณจะไม่ต้องย้อนกลับไปใช้ Rails 3.x เนื่องจากคุกกี้ที่ลงชื่อตาม `secret_key_base` ใหม่ใน Rails 4.x ไม่สามารถใช้งานร่วมกับ Rails 3.x ได้ คุณสามารถปล่อย `secret_token` เดิมของคุณไว้ ไม่ตั้งค่า `secret_key_base` ใหม่ และละเว้นคำเตือนเกี่ยวกับการเลิกใช้ได้จนกว่าคุณจะมั่นใจว่าการอัปเกรดของคุณเสร็จสมบูรณ์

    หากคุณพึ่งพาในความสามารถของแอปพลิเคชันภายนอกหรือ JavaScript ที่จะอ่านคุกกี้เซสชันที่ลงชื่อของแอปพลิเคชัน Rails ของคุณ (หรือคุกกี้ที่ลงชื่อทั่วไป) คุณไม่ควรตั้งค่า `secret_key_base` จนกว่าคุณจะแยกปลดล็อกปัญหาเหล่านี้

* Rails 4.0 เข้ารหัสเนื้อหาของเซสชันที่ใช้คุกกี้หาก `secret_key_base` ถูกตั้งค่าไว้ Rails 3.x ลงชื่อแต่ไม่เข้ารหัสเนื้อหาของเซสชันที่ใช้คุกกี้ คุกกี้ที่ลงชื่อมีความ "ปลอดภัย" ในที่ที่มีการตรวจสอบว่าถูกสร้างโดยแอปของคุณและป้องกันการแก้ไขได้ อย่างไรก็ตามเนื้อหาสามารถดูได้โดยผู้ใช้สิ้นสุด และการเข้ารหัสเนื้อหาจะลบข้อจำกัด/ข้อความที่เกี่ยวข้องนี้โดยไม่มีการลดประสิทธิภาพที่สำคัญ
โปรดอ่าน [Pull Request #9978](https://github.com/rails/rails/pull/9978) เพื่อดูรายละเอียดเกี่ยวกับการย้ายไปยังการใช้คุกกี้เซสชนิดเข้ารหัส

* Rails 4.0 ลบตัวเลือก `ActionController::Base.asset_path` ออกไป ให้ใช้คุณสมบัติ assets pipeline แทน

* Rails 4.0 ได้ยกเลิกการใช้ตัวเลือก `ActionController::Base.page_cache_extension` แล้ว ให้ใช้ `ActionController::Base.default_static_extension` แทน

* Rails 4.0 ได้ลบ Action และ Page caching ออกจาก Action Pack คุณจะต้องเพิ่ม `actionpack-action_caching` gem เพื่อใช้ `caches_action` และ `actionpack-page_caching` เพื่อใช้ `caches_page` ในคอนโทรลเลอร์ของคุณ

* Rails 4.0 ได้ลบ XML parameters parser ออกไป คุณจะต้องเพิ่ม `actionpack-xml_parser` gem หากคุณต้องการใช้คุณสมบัตินี้

* Rails 4.0 เปลี่ยนการค้นหา `layout` เริ่มต้นโดยใช้สัญลักษณ์หรือฟังก์ชันที่ส่งคืนค่าเป็น nil ให้ใช้ false แทน

* Rails 4.0 เปลี่ยนไคลเอ็นต์ memcached เริ่มต้นจาก `memcache-client` เป็น `dalli` ในการอัปเกรด คุณเพียงแค่เพิ่ม `gem 'dalli'` เข้าไปใน `Gemfile` ของคุณ

* Rails 4.0 ได้เลิกใช้เมธอด `dom_id` และ `dom_class` ในคอนโทรลเลอร์ (ยังคงใช้ได้ในวิว) คุณจะต้องรวมโมดูล `ActionView::RecordIdentifier` เข้าไปในคอนโทรลเลอร์ที่ต้องการใช้คุณสมบัตินี้

* Rails 4.0 ได้เลิกใช้ตัวเลือก `:confirm` สำหรับเมธอด `link_to` คุณควรพึ่งพาที่คุณสมบัติข้อมูล (data attribute) (เช่น `data: { confirm: 'คุณแน่ใจหรือไม่?' }`) การเลิกใช้นี้ยังเกี่ยวข้องกับเมธอดอื่นที่อิงอยู่บนเมธอดนี้ (เช่น `link_to_if` หรือ `link_to_unless`)

* Rails 4.0 เปลี่ยนวิธีการทำงานของ `assert_generates`, `assert_recognizes`, และ `assert_routing` ทั้งหมด ตอนนี้การตรวจสอบเหล่านี้จะเรียก `Assertion` แทน `ActionController::RoutingError`

* Rails 4.0 จะเรียก `ArgumentError` หากมีการกำหนดชื่อเส้นทางที่ซ้ำกัน สามารถเกิดขึ้นได้จากการกำหนดชื่อเส้นทางที่ระบุโดยชัดเจนหรือโดยใช้เมธอด `resources` นี่คือตัวอย่างสองอันที่ซ้ำกันกับเส้นทางที่ชื่อว่า `example_path`:

    ```ruby
    get 'one' => 'test#example', as: :example
    get 'two' => 'test#example', as: :example
    ```

    ```ruby
    resources :examples
    get 'clashing/:id' => 'test#example', as: :example
    ```

    ในกรณีแรก คุณสามารถหลีกเลี่ยงการใช้ชื่อเดียวกันสำหรับเส้นทางหลายเส้นทางได้ง่าย ในกรณีที่สอง คุณสามารถใช้ตัวเลือก `only` หรือ `except` ที่มีอยู่ในเมธอด `resources` เพื่อจำกัดเส้นทางที่สร้างตามที่ระบุใน [เอกสารเกี่ยวกับเส้นทาง](routing.html#restricting-the-routes-created)

* Rails 4.0 ยังเปลี่ยนวิธีการวาดเส้นทางของอักขระยูนิโค้ด ตอนนี้คุณสามารถวาดเส้นทางของอักขระยูนิโค้ดโดยตรง หากคุณได้วาดเส้นทางเช่นนั้นอยู่แล้ว คุณต้องเปลี่ยนแปลงเส้นทางนั้น เช่น:

    ```ruby
    get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
    ```

    เปลี่ยนเป็น

    ```ruby
    get 'こんにちは', controller: 'welcome', action: 'index'
    ```

* Rails 4.0 ต้องการให้เส้นทางที่ใช้ `match` ต้องระบุวิธีการร้องขอ ตัวอย่างเช่น:

    ```ruby
      # Rails 3.x
      match '/' => 'root#index'

      # เปลี่ยนเป็น
      match '/' => 'root#index', via: :get

      # หรือ
      get '/' => 'root#index'
    ```
* Rails 4.0 ได้ลบ `ActionDispatch::BestStandardsSupport` middleware ออกแล้ว `<!DOCTYPE html>` จะเรียกใช้โหมดมาตรฐานตาม https://msdn.microsoft.com/en-us/library/jj676915(v=vs.85).aspx และ ChromeFrame header ได้ถูกย้ายไปที่ `config.action_dispatch.default_headers` แล้ว

    โปรดจำไว้ว่าคุณต้องลบการอ้างอิงไปยัง middleware นี้ออกจากโค้ดของแอปพลิเคชันของคุณด้วย เช่น:

    ```ruby
    # เกิดข้อผิดพลาด
    config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
    ```

    โปรดตรวจสอบการตั้งค่าสภาพแวดล้อมของคุณสำหรับ `config.action_dispatch.best_standards_support` และลบออกหากมีการตั้งค่านี้อยู่

* Rails 4.0 อนุญาตให้กำหนดการตั้งค่า HTTP headers โดยการตั้งค่า `config.action_dispatch.default_headers` ค่าเริ่มต้นคือดังนี้:

    ```ruby
      config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block'
      }
    ```

    โปรดทราบว่าหากแอปพลิเคชันของคุณขึ้นอยู่กับการโหลดหน้าบางหน้าใน `<frame>` หรือ `<iframe>` คุณอาจต้องกำหนด `X-Frame-Options` เป็น `ALLOW-FROM ...` หรือ `ALLOWALL` โดยชัดเจน

* ใน Rails 4.0 การคอมไพล์ assets จะไม่คัดลอก non-JS/CSS assets จาก `vendor/assets` และ `lib/assets` อัตโนมัติแล้ว นักพัฒนาแอปพลิเคชันและเอ็นจิ้นของ Rails ควรวาง assets เหล่านี้ใน `app/assets` หรือกำหนดค่า [`config.assets.precompile`][]

* ใน Rails 4.0 `ActionController::UnknownFormat` จะถูกเรียกเมื่อแอ็กชันไม่ได้จัดการกับรูปแบบคำขอ ตามค่าเริ่มต้น ข้อยกเว้นจะถูกจัดการโดยการตอบกลับด้วย 406 Not Acceptable แต่คุณสามารถแทนที่ได้ในขณะนี้ ใน Rails 3 จะคืนค่า 406 Not Acceptable เสมอ ไม่มีการแทนที่

* ใน Rails 4.0 เมื่อ `ParamsParser` ไม่สามารถแยกวิเคราะห์ request params ได้ จะเกิดข้อผิดพลาด `ActionDispatch::ParamsParser::ParseError` ทั่วไป คุณควรจะรับข้อผิดพลาดนี้แทนที่ `MultiJson::DecodeError` ระดับต่ำ เช่น

* ใน Rails 4.0 `SCRIPT_NAME` จะถูกจัดกลุ่มอย่างถูกต้องเมื่อเอ็นจิ้นถูกติดตั้งบนแอปที่เซิร์ฟจาก URL prefix คุณไม่จำเป็นต้องตั้งค่า `default_url_options[:script_name]` เพื่อแก้ไข URL prefixes ที่ถูกเขียนทับ

* Rails 4.0 ได้เลิกใช้ `ActionController::Integration` และใช้ `ActionDispatch::Integration` แทน
* Rails 4.0 ได้เลิกใช้ `ActionController::IntegrationTest` และใช้ `ActionDispatch::IntegrationTest` แทน
* Rails 4.0 ได้เลิกใช้ `ActionController::PerformanceTest` และใช้ `ActionDispatch::PerformanceTest` แทน
* Rails 4.0 ได้เลิกใช้ `ActionController::AbstractRequest` และใช้ `ActionDispatch::Request` แทน
* Rails 4.0 ได้เลิกใช้ `ActionController::Request` และใช้ `ActionDispatch::Request` แทน
* Rails 4.0 ได้เลิกใช้ `ActionController::AbstractResponse` และใช้ `ActionDispatch::Response` แทน
* Rails 4.0 ได้เลิกใช้ `ActionController::Response` และใช้ `ActionDispatch::Response` แทน
* Rails 4.0 ได้เลิกใช้ `ActionController::Routing` และใช้ `ActionDispatch::Routing` แทน


### Active Support

Rails 4.0 ได้ลบการตั้งชื่อย่อ `j` สำหรับ `ERB::Util#json_escape` เนื่องจาก `j` ถูกใช้สำหรับ `ActionView::Helpers::JavaScriptHelper#escape_javascript` อยู่แล้ว

#### Cache

วิธีการเก็บแคชเปลี่ยนไประหว่าง Rails 3.x และ 4.0 คุณควร [เปลี่ยนชื่อเนมเนมสเปซแคช](https://guides.rubyonrails.org/v4.0/caching_with_rails.html#activesupport-cache-store) และเริ่มต้นด้วยแคชที่ยังไม่มีข้อมูล

### ลำดับการโหลด Helpers

ลำดับในการโหลด helpers จากไดเร็กทอรีมากกว่าหนึ่งไดเรกทอรีได้เปลี่ยนแปลงใน Rails 4.0 ก่อนหน้านี้ พวกเขาถูกรวบรวมและจัดเรียงตามลำดับตัวอักษร หลังจากอัปเกรดเป็น Rails 4.0 ช่วยให้ helpers จะรักษาลำดับของไดเรกทอรีที่โหลดและจัดเรียงตามลำดับตัวอักษรเฉพาะในแต่ละไดเรกทอรี เว้นแต่คุณใช้พารามิเตอร์ `helpers_path` โดยชัดเจน การเปลี่ยนแปลงนี้จะมีผลต่อการโหลด helpers จากเอ็นจิ้นเท่านั้น หากคุณพึงพอใจกับการจัดเรียงคุณสมบัติ คุณควรตรวจสอบว่าเมธอดที่ถูกต้องพร้อมใช้งานหลังจากอัปเกรด หากคุณต้องการเปลี่ยนลำดับในการโหลดเอ็นจิ้น คุณสามารถใช้เมธอด `config.railties_order=` ได้
### Active Record Observer และ Action Controller Sweeper

`ActiveRecord::Observer` และ `ActionController::Caching::Sweeper` ได้ถูกแยกออกเป็น gem `rails-observers` คุณจะต้องเพิ่ม gem `rails-observers` เข้าไปหากคุณต้องการใช้คุณสมบัติเหล่านี้

### sprockets-rails

* `assets:precompile:primary` และ `assets:precompile:all` ได้ถูกลบออก ให้ใช้ `assets:precompile` แทน
* ตัวเลือก `config.assets.compress` ควรเปลี่ยนเป็น [`config.assets.js_compressor`][] เช่น:

    ```ruby
    config.assets.js_compressor = :uglifier
    ```

### sass-rails

* `asset-url` ที่มีอาร์กิวเมนต์สองตัวถูกประกาศเป็นเลิกใช้ ตัวอย่างเช่น: `asset-url("rails.png", image)` เปลี่ยนเป็น `asset-url("rails.png")` 

การอัปเกรดจาก Rails 3.1 เป็น Rails 3.2
-------------------------------------

หากแอปพลิเคชันของคุณอยู่ในรุ่นของ Rails ที่เก่ากว่า 3.1.x คุณควรอัปเกรดเป็น Rails 3.1 ก่อนที่จะพยายามอัปเดตเป็น Rails 3.2

การเปลี่ยนแปลงต่อไปนี้เหมาะสำหรับการอัปเกรดแอปพลิเคชันของคุณเป็นรุ่นล่าสุดของ Rails 3.2.x

### Gemfile

ทำการเปลี่ยนแปลงต่อไปนี้ใน `Gemfile` ของคุณ

```ruby
gem 'rails', '3.2.21'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

มีการตั้งค่าสองอย่างใหม่ที่คุณควรเพิ่มในสภาพแวดล้อมการพัฒนาของคุณ

```ruby
# Raise exception on mass assignment protection for Active Record models
config.active_record.mass_assignment_sanitizer = :strict

# Log the query plan for queries taking more than this (works
# with SQLite, MySQL, and PostgreSQL)
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

การตั้งค่า `mass_assignment_sanitizer` ควรถูกเพิ่มใน `config/environments/test.rb` เช่นเดียวกัน

```ruby
# Raise exception on mass assignment protection for Active Record models
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

Rails 3.2 เลิกใช้ `vendor/plugins` และ Rails 4.0 จะลบออกเต็มที่ แม้ว่าจะไม่จำเป็นตามส่วนหนึ่งของการอัปเกรด Rails 3.2 คุณสามารถเริ่มแทนที่ปลั๊กอินโดยการแยกเป็น gem และเพิ่มเข้าไปใน `Gemfile` หากคุณไม่ต้องการทำให้เป็น gem คุณสามารถย้ายไปที่, ตัวอย่างเช่น, `lib/my_plugin/*` และเพิ่ม initializer ที่เหมาะสมใน `config/initializers/my_plugin.rb`

### Active Record

ตัวเลือก `:dependent => :restrict` ถูกลบออกจาก `belongs_to` หากคุณต้องการป้องกันการลบออบเจ็กต์หากมีออบเจ็กต์ที่เกี่ยวข้อง คุณสามารถตั้งค่า `:dependent => :destroy` และส่งค่า `false` หลังจากตรวจสอบการเชื่อมโยงจากการทำลายออบเจ็กต์ใดๆ ที่เกี่ยวข้อง
### Gemfile

ทำการเปลี่ยนแปลงตามรายการดังต่อไปนี้ใน `Gemfile` ของคุณ

```ruby
gem 'rails', '3.1.12'
gem 'mysql2'

# จำเป็นสำหรับ asset pipeline ใหม่
group :assets do
  gem 'sass-rails',   '~> 3.1.7'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier',     '>= 1.0.3'
end

# jQuery เป็นไลบรารี JavaScript เริ่มต้นใน Rails 3.1
gem 'jquery-rails'
```

### config/application.rb

Asset pipeline ต้องการการเพิ่มต่อไปนี้:

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

หากแอปพลิเคชันของคุณใช้เส้นทาง "/assets" สำหรับทรัพยากร คุณอาจต้องเปลี่ยนคำนำหน้าที่ใช้สำหรับทรัพยากรเพื่อหลีกเลี่ยงความขัดแย้ง:

```ruby
# ค่าเริ่มต้นคือ '/assets'
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

ลบการตั้งค่า RJS `config.action_view.debug_rjs = true`.

เพิ่มการตั้งค่าเหล่านี้หากคุณเปิดใช้งาน asset pipeline:

```ruby
# ไม่บีบอัดทรัพยากร
config.assets.compress = false

# ขยายบรรทัดที่โหลดทรัพยากร
config.assets.debug = true
```

### config/environments/production.rb

อีกครั้ง, ส่วนใหญ่ของการเปลี่ยนแปลงด้านล่างเป็นสำหรับ asset pipeline คุณสามารถอ่านเพิ่มเติมเกี่ยวกับเรื่องนี้ได้ใน[คู่มือ Asset Pipeline](asset_pipeline.html).

```ruby
# บีบอัด JavaScripts และ CSS
config.assets.compress = true

# ไม่สามารถย้อนกลับไปที่ asset pipeline หากไม่พบทรัพยากรที่ถูกคอมไพล์ล่วงหน้า
config.assets.compile = false

# สร้างเอกสารสำหรับ URL ของทรัพยากร
config.assets.digest = true

# ค่าเริ่มต้นคือ Rails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# คอมไพล์ทรัพยากรเพิ่มเติม (application.js, application.css, และทรัพยากรที่ไม่ใช่ JS/CSS ทั้งหมดถูกเพิ่มแล้ว)
# config.assets.precompile += %w( admin.js admin.css )

# บังคับให้เข้าถึงแอปผ่าน SSL, ใช้ Strict-Transport-Security, และใช้ secure cookies.
# config.force_ssl = true
```

### config/environments/test.rb

คุณสามารถช่วยทดสอบประสิทธิภาพด้วยการเพิ่มเหล่านี้ในสภาพแวดล้อมการทดสอบของคุณ:

```ruby
# กำหนดค่าเซิร์ฟเวอร์ทรัพยากรแบบสถิตสำหรับการทดสอบด้วย Cache-Control เพื่อประสิทธิภาพ
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=3600'
}
```

### config/initializers/wrap_parameters.rb

เพิ่มไฟล์นี้พร้อมเนื้อหาต่อไปนี้หากคุณต้องการแพ็คพารามิเตอร์เป็นแฮชซ้อนกัน ซึ่งเปิดใช้งานโดยค่าเริ่มต้นในแอปพลิเคชันใหม่

```ruby
# ตรวจสอบให้แน่ใจว่าคุณเริ่มเซิร์ฟเวอร์ของคุณใหม่เมื่อคุณแก้ไขไฟล์นี้
# ไฟล์นี้มีการตั้งค่าสำหรับ ActionController::ParamsWrapper ซึ่ง
# เปิดใช้งานโดยค่าเริ่มต้น

# เปิดใช้งานการแพ็คพารามิเตอร์สำหรับ JSON คุณสามารถปิดใช้งานได้โดยการตั้งค่า :format เป็นอาร์เรย์ที่ว่าง
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# ปิดใช้งานองค์ประกอบรากใน JSON โดยค่าเริ่มต้น
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

คุณต้องเปลี่ยนคีย์เซสชันของคุณเป็นสิ่งใหม่หรือลบเซสชันทั้งหมด:

```ruby
# ใน config/initializers/session_store.rb
AppName::Application.config.session_store :cookie_store, key: 'SOMETHINGNEW'
```

หรือ

```bash
$ bin/rake db:sessions:clear
```
### ลบตัวเลือก :cache และ :concat ในการอ้างอิงเฮลเปอร์ของแอสเซ็ตในวิว

* ด้วย Asset Pipeline ตัวเลือก :cache และ :concat ไม่ได้ใช้แล้ว ให้ลบตัวเลือกเหล่านี้ออกจากวิวของคุณ
[`config.cache_classes`]: configuring.html#config-cache-classes
[`config.autoload_once_paths`]: configuring.html#config-autoload-once-paths
[`config.force_ssl`]: configuring.html#config-force-ssl
[`config.ssl_options`]: configuring.html#config-ssl-options
[`config.add_autoload_paths_to_load_path`]: configuring.html#config-add-autoload-paths-to-load-path
[`config.active_storage.replace_on_assign_to_many`]: configuring.html#config-active-storage-replace-on-assign-to-many
[`config.exceptions_app`]: configuring.html#config-exceptions-app
[`config.action_mailer.perform_caching`]: configuring.html#config-action-mailer-perform-caching
[`config.assets.precompile`]: configuring.html#config-assets-precompile
[`config.assets.js_compressor`]: configuring.html#config-assets-js-compressor
