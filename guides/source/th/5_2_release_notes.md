**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c7252bf18650c5a9a85fc144305c4615

เรื่องเด่นใน Rails 5.2:
===============

* Active Storage
* Redis Cache Store
* HTTP/2 Early Hints
* Credentials
* Content Security Policy

เอกสารเวอร์ชันนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่ changelogs หรือตรวจสอบ [รายการคอมมิต](https://github.com/rails/rails/commits/5-2-stable) ในเก็บรักษาของ Rails ใน GitHub

--------------------------------------------------------------------------------

การอัพเกรดไปยัง Rails 5.2
----------------------

หากคุณกำลังอัพเกรดแอปพลิเคชันที่มีอยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัพเกรดเป็น Rails 5.1 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัพเดตเป็น Rails 5.2 มีรายการสิ่งที่ควรระมัดระวังเมื่ออัพเกรดใน
[การอัพเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2)
คู่มือ

คุณสมบัติหลัก
--------------

### Active Storage

[Pull Request](https://github.com/rails/rails/pull/30020)

[Active Storage](https://github.com/rails/rails/tree/5-2-stable/activestorage)
ช่วยให้สามารถอัปโหลดไฟล์ไปยังบริการจัดเก็บในคลาวด์ เช่น
Amazon S3, Google Cloud Storage, หรือ Microsoft Azure Storage และแนบไฟล์เหล่านั้นกับอ็อบเจกต์ Active Record มีบริการเก็บข้อมูลบนดิสก์ในเครื่องสำหรับการพัฒนาและการทดสอบ และรองรับการสำรองข้อมูลและการย้ายไฟล์ไปยังบริการย่อย ๆ
คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับ Active Storage ใน
[ภาพรวม Active Storage](active_storage_overview.html) คู่มือ

### Redis Cache Store

[Pull Request](https://github.com/rails/rails/pull/31134)

Rails 5.2 มาพร้อมกับ Redis cache store ที่มีอยู่ในตัว
คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับนี้ใน
[การใช้งานแคชด้วย Rails: ภาพรวม](caching_with_rails.html#activesupport-cache-rediscachestore)
คู่มือ

### HTTP/2 Early Hints

[Pull Request](https://github.com/rails/rails/pull/30744)

Rails 5.2 รองรับ [HTTP/2 Early Hints](https://tools.ietf.org/html/rfc8297)
ในการเริ่มต้นเซิร์ฟเวอร์ด้วย Early Hints ให้ส่ง `--early-hints`
ไปยัง `bin/rails server`

### Credentials

[Pull Request](https://github.com/rails/rails/pull/30067)

เพิ่มไฟล์ `config/credentials.yml.enc` เพื่อเก็บความลับของแอปพลิเคชันในโหมดการใช้งานจริง สามารถบันทึกข้อมูลการรับรองความถูกต้องสำหรับบริการบุคคลที่สามในเก็บรักษาที่เข้ารหัสด้วยคีย์ในไฟล์ `config/master.key` หรือตัวแปรสภาพแวดล้อม `RAILS_MASTER_KEY` สิ่งนี้จะเป็นการแทนที่ `Rails.application.secrets` และข้อมูลรหัสผ่านที่เข้ารหัสใน Rails 5.1 อีกทั้ง Rails 5.2
[เปิด API ใน Credentials](https://github.com/rails/rails/pull/30940)
ดังนั้นคุณสามารถจัดการกับการกำหนดค่าที่เข้ารหัสอื่น ๆ ได้อย่างง่ายดาย รวมถึงคีย์และไฟล์ที่เข้ารหัส คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับนี้ใน
[การรักษาความปลอดภัยในแอปพลิเคชัน Rails](security.html#custom-credentials)
คู่มือ
### นโยบายความปลอดภัยของเนื้อหา

[Pull Request](https://github.com/rails/rails/pull/31162)

Rails 5.2 มาพร้อมกับ DSL ใหม่ที่ช่วยให้คุณสามารถกำหนดค่า [นโยบายความปลอดภัยของเนื้อหา](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy) สำหรับแอปพลิเคชันของคุณได้ คุณสามารถกำหนดค่านโยบายเริ่มต้นทั่วโลกแล้วแทนที่ด้วยนโยบายแยกตามทรัพยากรและใช้ lambda เพื่อซ้อนค่าตามคำขอลงในส่วนหัว เช่น โดเมนย่อยของบัญชีในแอปพลิเคชันแบบหลายผู้เช่า คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับนี้ได้ในเอกสาร [Securing Rails Applications](security.html#content-security-policy)

Railties
--------

โปรดอ้างอิง [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเลิกใช้งาน

*   เลิกใช้งานเมธอด `capify!` ใน generators และ templates
    ([Pull Request](https://github.com/rails/rails/pull/29493))

*   เลิกใช้การส่งชื่อสภาพแวดล้อมเป็นอาร์กิวเมนต์ปกติในคำสั่ง `rails dbconsole` และ `rails console` แทนที่ควรใช้ตัวเลือก `-e`
    ([Commit](https://github.com/rails/rails/commit/48b249927375465a7102acc71c2dfb8d49af8309))

*   เลิกใช้การใช้คลาสย่อยของ `Rails::Application` เพื่อเริ่มเซิร์ฟเวอร์ Rails
    ([Pull Request](https://github.com/rails/rails/pull/30127))

*   เลิกใช้งาน `after_bundle` callback ใน Rails plugin templates
    ([Pull Request](https://github.com/rails/rails/pull/29446))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มส่วนที่แชร์ใน `config/database.yml` ที่จะโหลดสำหรับทุกสภาพแวดล้อม
    ([Pull Request](https://github.com/rails/rails/pull/28896))

*   เพิ่ม `railtie.rb` ใน generator ของปลั๊กอิน
    ([Pull Request](https://github.com/rails/rails/pull/29576))

*   ล้างไฟล์สกรีนช็อตในงาน `tmp:clear`
    ([Pull Request](https://github.com/rails/rails/pull/29534))

*   ข้ามคอมโพเนนต์ที่ไม่ได้ใช้งานเมื่อเรียกใช้งาน `bin/rails app:update` หากการสร้างแอปเริ่มต้นข้าม Action Cable, Active Record เป็นต้น งานอัพเดตจะใช้งานการข้ามเหล่านั้นเช่นกัน
    ([Pull Request](https://github.com/rails/rails/pull/29645))

*   อนุญาตให้ส่งชื่อการเชื่อมต่อที่กำหนดเองให้กับคำสั่ง `rails dbconsole` เมื่อใช้การกำหนดค่าฐานข้อมูลระดับ 3 ระดับ เช่น `bin/rails dbconsole -c replica`
    ([Commit](https://github.com/rails/rails/commit/1acd9a6464668d4d54ab30d016829f60b70dbbeb))

*   ขยายตัวย่อสำหรับชื่อสภาพแวดล้อมที่เรียกใช้งานคำสั่ง `console` และ `dbconsole` อย่างถูกต้อง
    ([Commit](https://github.com/rails/rails/commit/3777701f1380f3814bd5313b225586dec64d4104))

*   เพิ่ม `bootsnap` เข้าไปใน `Gemfile` เริ่มต้น
    ([Pull Request](https://github.com/rails/rails/pull/29313))

*   สนับสนุน `-` เป็นวิธีที่เป็นแพลตฟอร์มเพื่อเรียกใช้สคริปต์จาก stdin ด้วย `rails runner`
    ([Pull Request](https://github.com/rails/rails/pull/26343))

*   เพิ่มเวอร์ชัน `ruby x.x.x` เข้าไปใน `Gemfile` และสร้างไฟล์ `.ruby-version` ที่รากที่มีเวอร์ชัน Ruby ปัจจุบันเมื่อสร้างแอปพลิเคชัน Rails ใหม่
    ([Pull Request](https://github.com/rails/rails/pull/30016))

*   เพิ่มตัวเลือก `--skip-action-cable` ใน generator ของปลั๊กอิน
    ([Pull Request](https://github.com/rails/rails/pull/30164))
*   เพิ่ม `git_source` ใน `Gemfile` สำหรับ generator ของ plugin
    ([Pull Request](https://github.com/rails/rails/pull/30110))

*   ข้าม component ที่ไม่ได้ใช้เมื่อรัน `bin/rails` ใน Rails plugin
    ([Commit](https://github.com/rails/rails/commit/62499cb6e088c3bc32a9396322c7473a17a28640))

*   ปรับปรุงการเยื้องบรรทัดสำหรับ generator actions
    ([Pull Request](https://github.com/rails/rails/pull/30166))

*   ปรับปรุงการเยื้องบรรทัดสำหรับ routes
    ([Pull Request](https://github.com/rails/rails/pull/30241))

*   เพิ่มตัวเลือก `--skip-yarn` ใน plugin generator
    ([Pull Request](https://github.com/rails/rails/pull/30238))

*   รองรับการระบุเวอร์ชันหลายรุ่นสำหรับเมธอด `gem` ใน Generators
    ([Pull Request](https://github.com/rails/rails/pull/30323))

*   สร้าง `secret_key_base` จากชื่อแอปในสภาพแวดล้อมการพัฒนาและทดสอบ
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   เพิ่ม `mini_magick` ใน `Gemfile` ดีฟอลต์เป็นคอมเมนต์
    ([Pull Request](https://github.com/rails/rails/pull/30633))

*   `rails new` และ `rails plugin new` ได้ `Active Storage` โดยค่าเริ่มต้น
    เพิ่มความสามารถในการข้าม `Active Storage` ด้วย `--skip-active-storage`
    และทำเช่นนั้นโดยอัตโนมัติเมื่อใช้ `--skip-active-record`
    ([Pull Request](https://github.com/rails/rails/pull/30101))

Action Cable
------------

โปรดอ้างอิง [Changelog][action-cable] สำหรับรายละเอียดการเปลี่ยนแปลง

### การลบ

*   ลบ evented redis adapter ที่ถูกยกเลิกแล้ว
    ([Commit](https://github.com/rails/rails/commit/48766e32d31651606b9f68a16015ad05c3b0de2c))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มการสนับสนุนตัวเลือก `host`, `port`, `db` และ `password` ใน cable.yml
    ([Pull Request](https://github.com/rails/rails/pull/29528))

*   แฮชตัวระบุสตรีมที่ยาวเมื่อใช้ PostgreSQL adapter
    ([Pull Request](https://github.com/rails/rails/pull/29297))

Action Pack
-----------

โปรดอ้างอิง [Changelog][action-pack] สำหรับรายละเอียดการเปลี่ยนแปลง

### การลบ

*   ลบ `ActionController::ParamsParser::ParseError` ที่ถูกยกเลิกแล้ว
    ([Commit](https://github.com/rails/rails/commit/e16c765ac6dcff068ff2e5554d69ff345c003de1))

### การเลิกใช้

*   เลิกใช้ `#success?`, `#missing?` และ `#error?` ใน `ActionDispatch::TestResponse`
    ([Pull Request](https://github.com/rails/rails/pull/30104))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มการสนับสนุนการใช้ cache keys ที่สามารถ reuse ได้กับ fragment caching
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   เปลี่ยนรูปแบบ cache key สำหรับ fragments เพื่อทำให้ง่ายต่อการตรวจสอบข้อผิดพลาดในการสร้าง key
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   AEAD encrypted cookies และ sessions ด้วย GCM
    ([Pull Request](https://github.com/rails/rails/pull/28132))

*   ป้องกันการปลอมแปลงข้อมูลโดยค่าเริ่มต้น
    ([Pull Request](https://github.com/rails/rails/pull/29742))

*   บังคับให้ลางของ signed/encrypted cookie ที่หมดอายุที่เซิร์ฟเวอร์
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   ตัวเลือก `:expires` ของคุกกี้รองรับ `ActiveSupport::Duration` object
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   ใช้การตั้งค่า server config `:puma` ที่ Capybara ลงทะเบียน
    ([Pull Request](https://github.com/rails/rails/pull/30638))

*   Vereinfachung des Cookies-Middleware mit Unterstützung für Schlüsselrotation
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   เพิ่มความสามารถในการเปิดใช้งาน Early Hints สำหรับ HTTP/2
    ([Pull Request](https://github.com/rails/rails/pull/30744))

*   เพิ่มการสนับสนุน headless chrome ใน System Tests
    ([Pull Request](https://github.com/rails/rails/pull/30876))

*   เพิ่มตัวเลือก `:allow_other_host` ในเมธอด `redirect_back`
    ([Pull Request](https://github.com/rails/rails/pull/30850))
*   ทำให้ `assert_recognizes` สามารถเดินทางผ่านเอ็นจินที่ติดตั้งแล้วได้
    ([Pull Request](https://github.com/rails/rails/pull/22435))

*   เพิ่ม DSL สำหรับกำหนดค่าเฮดเดอร์ Content-Security-Policy
    ([Pull Request](https://github.com/rails/rails/pull/31162),
    [Commit](https://github.com/rails/rails/commit/619b1b6353a65e1635d10b8f8c6630723a5a6f1a),
    [Commit](https://github.com/rails/rails/commit/4ec8bf68ff92f35e79232fbd605012ce1f4e1e6e))

*   ลงทะเบียน MIME types ของเสียง/วิดีโอ/ฟอนต์ที่ได้รับความสนับสนุนจากเบราว์เซอร์รุ่นใหม่
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   เปลี่ยนการตั้งค่าเริ่มต้นของรูปภาพจากการแสดงผลแบบ `inline` เป็น `simple` ในการทดสอบระบบ
    ([Commit](https://github.com/rails/rails/commit/9d6e288ee96d6241f864dbf90211c37b14a57632))

*   เพิ่มการสนับสนุน Firefox แบบ headless ในการทดสอบระบบ
    ([Pull Request](https://github.com/rails/rails/pull/31365))

*   เพิ่ม `X-Download-Options` และ `X-Permitted-Cross-Domain-Policies` ที่ปลอดภัยในการตั้งค่าเริ่มต้นของเฮดเดอร์
    ([Commit](https://github.com/rails/rails/commit/5d7b70f4336d42eabfc403e9f6efceb88b3eff44))

*   เปลี่ยนการตั้งค่าระบบทดสอบเพื่อตั้งค่า Puma เป็นเซิร์ฟเวอร์เริ่มต้นเมื่อผู้ใช้ไม่ได้ระบุเซิร์ฟเวอร์อื่นเอง
    ([Pull Request](https://github.com/rails/rails/pull/31384))

*   เพิ่มเฮดเดอร์ `Referrer-Policy` ในการตั้งค่าเริ่มต้นของเฮดเดอร์
    ([Commit](https://github.com/rails/rails/commit/428939be9f954d39b0c41bc53d85d0d106b9d1a1))

*   ปรับให้การทำงานของ `ActionController::Parameters#each` เหมือนกับ `Hash#each`
    ([Pull Request](https://github.com/rails/rails/pull/27790))

*   เพิ่มการสนับสนุนการสร้าง nonce อัตโนมัติสำหรับ Rails UJS
    ([Commit](https://github.com/rails/rails/commit/b2f0a8945956cd92dec71ec4e44715d764990a49))

*   อัปเดตค่า HSTS max-age เริ่มต้นเป็น 31536000 วินาที (1 ปี)
    เพื่อตรงตามค่า max-age ขั้นต่ำที่กำหนดใน https://hstspreload.org/
    ([Commit](https://github.com/rails/rails/commit/30b5f469a1d30c60d1fb0605e84c50568ff7ed37))

*   เพิ่มเมธอดย่อย `to_hash` สำหรับ `to_h` ใน `cookies`
    เพิ่มเมธอดย่อย `to_h` สำหรับ `to_hash` ใน `session`
    ([Commit](https://github.com/rails/rails/commit/50a62499e41dfffc2903d468e8b47acebaf9b500))

Action View
-----------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ Erubis ERB handler ที่ถูกเลิกใช้งาน
    ([Commit](https://github.com/rails/rails/commit/7de7f12fd140a60134defe7dc55b5a20b2372d06))

### การเลิกใช้งาน

*   เลิกใช้งานเมธอด `image_alt` helper ที่ใช้เพิ่มข้อความ alt ตั้งต้นให้กับรูปภาพที่สร้างขึ้นโดย `image_tag`
    ([Pull Request](https://github.com/rails/rails/pull/30213))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มประเภท `:json` ให้กับ `auto_discovery_link_tag` เพื่อสนับสนุน
    [JSON Feeds](https://jsonfeed.org/version/1)
    ([Pull Request](https://github.com/rails/rails/pull/29158))

*   เพิ่มตัวเลือก `srcset` ให้กับ `image_tag` helper
    ([Pull Request](https://github.com/rails/rails/pull/29349))

*   แก้ไขปัญหาเกี่ยวกับ `field_error_proc` ที่ครอบ `optgroup` และ `option` แบ่งกลุ่มของ select
    ([Pull Request](https://github.com/rails/rails/pull/31088))

*   เปลี่ยน `form_with` เพื่อสร้าง id โดยค่าเริ่มต้น
    ([Commit](https://github.com/rails/rails/commit/260d6f112a0ffdbe03e6f5051504cb441c1e94cd))

*   เพิ่ม `preload_link_tag` helper
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   อนุญาตให้ใช้วัตถุที่เรียกได้เป็นเมธอดกลุ่มสำหรับการเลือกที่แบ่งกลุ่ม
    ([Pull Request](https://github.com/rails/rails/pull/31578))

Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog][action-mailer] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

*   อนุญาตให้คลาส Action Mailer กำหนดค่างานส่งของตนเอง
    ([Pull Request](https://github.com/rails/rails/pull/29457))

*   เพิ่ม `assert_enqueued_email_with` test helper
    ([Pull Request](https://github.com/rails/rails/pull/30695))

Active Record
-------------
โปรดอ้างอิงที่ [Changelog][active-record] เพื่อดูการเปลี่ยนแปลงที่ละเอียด

การลบ

- ลบ `#migration_keys` ที่ถูกยกเลิก
    ([Pull Request](https://github.com/rails/rails/pull/30337))

- ลบการสนับสนุนที่ถูกยกเลิกใน `quoted_id` เมื่อทำการแปลงประเภทของอ็อบเจ็กต์ Active Record
    ([Commit](https://github.com/rails/rails/commit/82472b3922bda2f337a79cef961b4760d04f9689))

- ลบอาร์กิวเมนต์ที่ถูกยกเลิก `default` จาก `index_name_exists?`
    ([Commit](https://github.com/rails/rails/commit/8f5b34df81175e30f68879479243fbce966122d7))

- ลบการสนับสนุนที่ถูกยกเลิกในการส่งคลาสไปยัง `:class_name` ในการเชื่อมโยง
    ([Commit](https://github.com/rails/rails/commit/e65aff70696be52b46ebe57207ebd8bb2cfcdbb6))

- ลบเมธอดที่ถูกยกเลิก `initialize_schema_migrations_table` และ `initialize_internal_metadata_table`
    ([Commit](https://github.com/rails/rails/commit/c9660b5777707658c414b430753029cd9bc39934))

- ลบเมธอดที่ถูกยกเลิก `supports_migrations?`
    ([Commit](https://github.com/rails/rails/commit/9438c144b1893f2a59ec0924afe4d46bd8d5ffdd))

- ลบเมธอดที่ถูกยกเลิก `supports_primary_key?`
    ([Commit](https://github.com/rails/rails/commit/c56ff22fc6e97df4656ddc22909d9bf8b0c2cbb1))

- ลบเมธอดที่ถูกยกเลิก `ActiveRecord::Migrator.schema_migrations_table_name`
    ([Commit](https://github.com/rails/rails/commit/7df6e3f3cbdea9a0460ddbab445c81fbb1cfd012))

- ลบอาร์กิวเมนต์ที่ถูกยกเลิก `name` จาก `#indexes`
    ([Commit](https://github.com/rails/rails/commit/d6b779ecebe57f6629352c34bfd6c442ac8fba0e))

- ลบอาร์กิวเมนต์ที่ถูกยกเลิกจาก `#verify!`
    ([Commit](https://github.com/rails/rails/commit/9c6ee1bed0292fc32c23dc1c68951ae64fc510be))

- ลบการกำหนดค่าที่ถูกยกเลิก `.error_on_ignored_order_or_limit`
    ([Commit](https://github.com/rails/rails/commit/e1066f450d1a99c9a0b4d786b202e2ca82a4c3b3))

- ลบเมธอดที่ถูกยกเลิก `#scope_chain`
    ([Commit](https://github.com/rails/rails/commit/ef7784752c5c5efbe23f62d2bbcc62d4fd8aacab))

- ลบเมธอดที่ถูกยกเลิก `#sanitize_conditions`
    ([Commit](https://github.com/rails/rails/commit/8f5413b896099f80ef46a97819fe47a820417bc2))

การเลิกใช้

- เลิกใช้ `supports_statement_cache?`
    ([Pull Request](https://github.com/rails/rails/pull/28938))

- เลิกใช้การส่งอาร์กิวเมนต์และบล็อกพร้อมกันใน `count` และ `sum` ใน `ActiveRecord::Calculations`
    ([Pull Request](https://github.com/rails/rails/pull/29262))

- เลิกใช้การจ่ายหน้าที่ให้กับ `arel` ใน `Relation`
    ([Pull Request](https://github.com/rails/rails/pull/29619))

- เลิกใช้เมธอด `set_state` ใน `TransactionState`
    ([Commit](https://github.com/rails/rails/commit/608ebccf8f6314c945444b400a37c2d07f21b253))

- เลิกใช้ `expand_hash_conditions_for_aggregates` โดยไม่มีการแทนที่
    ([Commit](https://github.com/rails/rails/commit/7ae26885d96daee3809d0bd50b1a440c2f5ffb69))

การเปลี่ยนแปลงที่สำคัญ

- เมื่อเรียกใช้เมธอด dynamic fixture accessor โดยไม่มีอาร์กิวเมนต์ ตอนนี้จะคืนค่า fixtures ทั้งหมดของประเภทนี้ ก่อนหน้านี้เมธอดนี้เสมอคืนค่าอาร์เรย์ที่ว่างเปล่า
    ([Pull Request](https://github.com/rails/rails/pull/28692))

- แก้ไขความไม่สอดคล้องกันของแอตทริบิวต์ที่เปลี่ยนแปลงเมื่อการเขียนเมธอดอ่านแอตทริบิวต์ Active Record
    ([Pull Request](https://github.com/rails/rails/pull/28661))

- สนับสนุน Descending Indexes สำหรับ MySQL
    ([Pull Request](https://github.com/rails/rails/pull/28773))

- แก้ไข `bin/rails db:forward` การเริ่มต้นของ migration แรก
    ([Commit](https://github.com/rails/rails/commit/b77d2aa0c336492ba33cbfade4964ba0eda3ef84))

- สร้างข้อผิดพลาด `UnknownMigrationVersionError` เมื่อย้าย migration แล้วไม่มี migration ปัจจุบันอยู่
    ([Commit](https://github.com/rails/rails/commit/bb9d6eb094f29bb94ef1f26aa44f145f17b973fe))

- ให้เคารพ `SchemaDumper.ignore_tables` ในงาน rake สำหรับการสร้างโครงสร้างฐานข้อมูล
    ([Pull Request](https://github.com/rails/rails/pull/29077))

- เพิ่ม `ActiveRecord::Base#cache_version` เพื่อสนับสนุนคีย์แคชที่สามารถนำกลับมาใช้ซ้ำได้ผ่านรายการเวอร์ชันใหม่ใน `ActiveSupport::Cache` นี่หมายความว่า `ActiveRecord::Base#cache_key` ตอนนี้จะคืนค่าคีย์ที่เสถียรภาพและไม่รวมไทม์สแตมป์อีกต่อไป
    ([Pull Request](https://github.com/rails/rails/pull/29092))

- ป้องกันการสร้าง bind param หากค่าที่แปลงประเภทเป็น nil
    ([Pull Request](https://github.com/rails/rails/pull/29282))

- ใช้ INSERT แบบกลุ่มเพื่อแทรก fixtures เพื่อประสิทธิภาพที่ดีขึ้น
    ([Pull Request](https://github.com/rails/rails/pull/29504))
*   การผสานรวมสองความสัมพันธ์ที่แสดงการเชื่อมต่อซ้อนกันไม่ได้แปลงการเชื่อมต่อของความสัมพันธ์ที่ผสานเข้าด้วยกันเป็น LEFT OUTER JOIN อีกต่อไป
    ([Pull Request](https://github.com/rails/rails/pull/27063))

*   แก้ไขการทำงานของการทำธุรกรรมให้สามารถนำสถานะไปใช้กับธุรกรรมย่อยได้
    ก่อนหน้านี้หากคุณมีการทำธุรกรรมที่ซ้อนกันและธุรกรรมภายนอกถูกยกเลิกการทำงาน ระเบียนจากธุรกรรมภายในยังคงถูกทำเครื่องหมายว่าถูกบันทึกไว้ ได้แก้ไขโดยการนำสถานะของธุรกรรมหลักไปใช้กับธุรกรรมย่อยเมื่อธุรกรรมหลักถูกยกเลิกการทำงาน ซึ่งจะทำให้ระเบียนจากธุรกรรมภายในถูกทำเครื่องหมายว่าไม่ได้ถูกบันทึกไว้
    ([Commit](https://github.com/rails/rails/commit/0237da287eb4c507d10a0c6d94150093acc52b03))

*   แก้ไขการโหลดข้อมูลล่วงหน้า/โหลดข้อมูลล่วงหน้าพร้อมกับการรวมข้อมูลสมาชิกที่รวมการเชื่อมต่อ
    ([Pull Request](https://github.com/rails/rails/pull/29413))

*   ป้องกันข้อผิดพลาดที่เกิดขึ้นจากผู้ติดตามการแจ้งเตือน `sql.active_record` ไม่ให้เปลี่ยนเป็นข้อยกเว้น `ActiveRecord::StatementInvalid`
    ([Pull Request](https://github.com/rails/rails/pull/29692))

*   ข้ามการแคชคำสั่งเมื่อทำงานกับกลุ่มของระเบียน (`find_each`, `find_in_batches`, `in_batches`)
    ([Commit](https://github.com/rails/rails/commit/b83852e6eed5789b23b13bac40228e87e8822b4d))

*   เปลี่ยนการแปลงค่าบูลีนของ sqlite3 เพื่อใช้ 1 และ 0
    SQLite รู้จัก 1 และ 0 เป็นค่าจริงและเท็จอย่างเป็นธรรมชาติ แต่ไม่รู้จัก 't' และ 'f' เหมือนที่ถูกแปลงค่าก่อนหน้านี้
    ([Pull Request](https://github.com/rails/rails/pull/29699))

*   ค่าที่สร้างขึ้นโดยการกำหนดค่าหลายพารามิเตอร์จะใช้ค่าหลังจากการแปลงประเภทสำหรับแสดงผลในฟอร์มข้อมูลแบบฟิลด์เดียว
    ([Commit](https://github.com/rails/rails/commit/1519e976b224871c7f7dd476351930d5d0d7faf6))

*   `ApplicationRecord` ไม่ถูกสร้างขึ้นอีกต่อไปเมื่อสร้างโมเดล หากคุณต้องการสร้าง `ApplicationRecord` สามารถทำได้โดยใช้ `rails g application_record`
    ([Pull Request](https://github.com/rails/rails/pull/29916))

*   `Relation#or` ตอนนี้ยอมรับสองความสัมพันธ์ที่มีค่าต่างกันสำหรับ `references` เท่านั้น เนื่องจาก `references` อาจถูกเรียกใช้โดยอัตโนมัติจาก `where`
    ([Commit](https://github.com/rails/rails/commit/ea6139101ccaf8be03b536b1293a9f36bc12f2f7))

*   เมื่อใช้ `Relation#or` แยกเงื่อนไขที่เหมือนกันและวางไว้ก่อนเงื่อนไข OR
    ([Pull Request](https://github.com/rails/rails/pull/29950))

*   เพิ่มเมธอดช่วยในการทดสอบ `binary`
    ([Pull Request](https://github.com/rails/rails/pull/30073))

*   ทางเลือกในการคาดเดาความสัมพันธ์ที่ตรงกันสำหรับ STI
    ([Pull Request](https://github.com/rails/rails/pull/23425))

*   เพิ่มคลาสข้อผิดพลาดใหม่ `LockWaitTimeout` ซึ่งจะถูกเรียกขึ้นเมื่อเกินเวลาที่กำหนดในการรอล็อก
    ([Pull Request](https://github.com/rails/rails/pull/30360))

*   อัปเดตชื่อข้อมูลในการแจ้งเตือน `sql.active_record` เพื่อให้มีคำอธิบายที่ชัดเจนกว่าเดิม
    ([Pull Request](https://github.com/rails/rails/pull/30619))

*   ใช้อัลกอริทึมที่กำหนดในการลบดัชนีจากฐานข้อมูล
    ([Pull Request](https://github.com/rails/rails/pull/24199))
*   การส่ง `Set` ไปยัง `Relation#where` ตอนนี้มีพฤติกรรมเดียวกับการส่งอาร์เรย์
    ([Commit](https://github.com/rails/rails/commit/9cf7e3494f5bd34f1382c1ff4ea3d811a4972ae2))

*   PostgreSQL `tsrange` ตอนนี้เก็บความแม่นยำในระดับเวลาย่อยไว้
    ([Pull Request](https://github.com/rails/rails/pull/30725))

*   สร้างข้อผิดพลาดเมื่อเรียกใช้ `lock!` ในระเบียนที่มีการเปลี่ยนแปลง
    ([Commit](https://github.com/rails/rails/commit/63cf15877bae859ff7b4ebaf05186f3ca79c1863))

*   แก้ไขข้อบกพร่องที่เรียงลำดับคอลัมน์สำหรับดัชนีไม่ถูกเขียนลงใน `db/schema.rb` เมื่อใช้แอดาปเตอร์ SQLite
    ([Pull Request](https://github.com/rails/rails/pull/30970))

*   แก้ไข `bin/rails db:migrate` ด้วย `VERSION` ที่ระบุ
    `bin/rails db:migrate` โดยไม่ระบุ `VERSION` จะทำงานเหมือนกับไม่มี `VERSION`
    ตรวจสอบรูปแบบของ `VERSION`: อนุญาตให้ใช้หมายเลขเวอร์ชันของการโยกย้ายหรือชื่อไฟล์การโยกย้าย สร้างข้อผิดพลาดถ้ารูปแบบของ `VERSION` ไม่ถูกต้อง
    สร้างข้อผิดพลาดถ้าการโยกย้ายเป้าหมายไม่มีอยู่
    ([Pull Request](https://github.com/rails/rails/pull/30714))

*   เพิ่มคลาสข้อผิดพลาดใหม่ `StatementTimeout` ซึ่งจะถูกเรียกขึ้นเมื่อเกินเวลาที่กำหนดในคำสั่ง
    ([Pull Request](https://github.com/rails/rails/pull/31129))

*   `update_all` ตอนนี้จะส่งค่าไปยัง `Type#cast` ก่อนที่จะส่งไปยัง `Type#serialize` นั่นหมายความว่า `update_all(foo: 'true')` จะบันทึกค่า boolean ได้อย่างถูกต้อง
    ([Commit](https://github.com/rails/rails/commit/68fe6b08ee72cc47263e0d2c9ff07f75c4b42761))

*   ต้องระบุส่วน SQL แบบเต็มเมื่อใช้ในเมธอดคิวรีเรียน
    ([Commit](https://github.com/rails/rails/commit/a1ee43d2170dd6adf5a9f390df2b1dde45018a48),
    [Commit](https://github.com/rails/rails/commit/e4a921a75f8702a7dbaf41e31130fe884dea93f9))

*   เพิ่ม `#up_only` ในการโยกย้ายฐานข้อมูลสำหรับโค้ดที่เกี่ยวข้องเฉพาะเมื่อโยกย้ายขึ้น เช่น เติมคอลัมน์ใหม่
    ([Pull Request](https://github.com/rails/rails/pull/31082))

*   เพิ่มคลาสข้อผิดพลาดใหม่ `QueryCanceled` ซึ่งจะถูกเรียกขึ้นเมื่อยกเลิกคำสั่งเนื่องจากคำขอของผู้ใช้
    ([Pull Request](https://github.com/rails/rails/pull/31235))

*   ไม่อนุญาตให้กำหนดขอบเขตที่ขัดแย้งกับเมธอดของอินสแตนซ์ใน `Relation`
    ([Pull Request](https://github.com/rails/rails/pull/31179))

*   เพิ่มการสนับสนุนคลาสตัวดำเนินการ PostgreSQL ใน `add_index`
    ([Pull Request](https://github.com/rails/rails/pull/19090))

*   บันทึกผู้เรียกคำสั่งฐานข้อมูล
    ([Pull Request](https://github.com/rails/rails/pull/26815),
    [Pull Request](https://github.com/rails/rails/pull/31519),
    [Pull Request](https://github.com/rails/rails/pull/31690))

*   ยกเลิกเมธอดแอตทริบิวต์บนลูกสายเมื่อรีเซ็ตข้อมูลคอลัมน์
    ([Pull Request](https://github.com/rails/rails/pull/31475))

*   ใช้เซลเล็กที่สอดคล้องกับ `delete_all` ที่มี `limit` หรือ `offset`
    ([Commit](https://github.com/rails/rails/commit/9e7260da1bdc0770cf4ac547120c85ab93ff3d48))

*   แก้ไขความไม่สอดคล้องกันของ `first(n)` เมื่อใช้กับ `limit()`
    เมธอด `first(n)` ตอนนี้จะใช้ `limit()` อย่างถูกต้อง เหมือนกับ `relation.to_a.first(n)` และเหมือนกับพฤติกรรมของ `last(n)`
    ([Pull Request](https://github.com/rails/rails/pull/27597))

*   แก้ไขความไม่สอดคล้องกันของการสร้างความสัมพันธ์ `has_many :through` บนอินสแตนซ์หลักที่ยังไม่ได้ถูกบันทึก
    ([Commit](https://github.com/rails/rails/commit/027f865fc8b262d9ba3ee51da3483e94a5489b66))
*   พิจารณาเงื่อนไขการเชื่อมต่อเมื่อลบผ่านบันทึก ([Commit](https://github.com/rails/rails/commit/ae48c65e411e01c1045056562319666384bb1b63))

*   ไม่อนุญาตการเปลี่ยนแปลงวัตถุที่ถูกทำลายหลังจากที่เรียกใช้ `save` หรือ `save!` ([Commit](https://github.com/rails/rails/commit/562dd0494a90d9d47849f052e8913f0050f3e494))

*   แก้ไขปัญหาการผสานความสัมพันธ์กับ `left_outer_joins` ([Pull Request](https://github.com/rails/rails/pull/27860))

*   รองรับตารางภายนอกของ PostgreSQL ([Pull Request](https://github.com/rails/rails/pull/31549))

*   ล้างสถานะการทำธุรกรรมเมื่อวัตถุ Active Record ถูกคัดลอก ([Pull Request](https://github.com/rails/rails/pull/31751))

*   แก้ไขปัญหาที่ไม่ขยายตัวเมื่อส่งวัตถุ Array เป็นอาร์กิวเมนต์ให้กับเมธอด where โดยใช้คอลัมน์ `composed_of` ([Pull Request](https://github.com/rails/rails/pull/31724))

*   ทำให้ `reflection.klass` เกิดข้อผิดพลาดถ้า `polymorphic?` ไม่ถูกใช้งานอย่างถูกต้อง ([Commit](https://github.com/rails/rails/commit/63fc1100ce054e3e11c04a547cdb9387cd79571a))

*   แก้ไข `#columns_for_distinct` ของ MySQL และ PostgreSQL เพื่อให้ `ActiveRecord::FinderMethods#limited_ids_for` ใช้ค่า primary key ที่ถูกต้อง แม้ว่า `ORDER BY` คอลัมน์จะรวม primary key ของตารางอื่น ([Commit](https://github.com/rails/rails/commit/851618c15750979a75635530200665b543561a44))

*   แก้ไขปัญหา `dependent: :destroy` สำหรับความสัมพันธ์ has_one/belongs_to ที่คลาสหลักถูกลบเมื่อลูกไม่ถูกลบ ([Commit](https://github.com/rails/rails/commit/b0fc04aa3af338d5a90608bf37248668d59fc881))

*   การเชื่อมต่อฐานข้อมูลที่ไม่ได้ใช้งาน (ก่อนหน้านี้เป็นการเชื่อมต่อที่ถูกทิ้งไว้) ตอนนี้จะถูกลบเป็นระยะๆ โดย connection pool reaper ([Commit](https://github.com/rails/rails/pull/31221/commits/9027fafff6da932e6e64ddb828665f4b01fc8902))

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

*   แก้ไขเมธอด `#keys`, `#values` ใน `ActiveModel::Errors` แก้ไข `#keys` เพื่อให้ส่งคืนเฉพาะคีย์ที่ไม่มีข้อความว่างเปล่า และแก้ไข `#values` เพื่อให้ส่งคืนค่าที่ไม่ว่างเปล่า ([Pull Request](https://github.com/rails/rails/pull/28584))

*   เพิ่มเมธอด `#merge!` สำหรับ `ActiveModel::Errors` ([Pull Request](https://github.com/rails/rails/pull/29714))

*   อนุญาตให้ส่ง Proc หรือ Symbol เป็นตัวเลือกให้กับตัวตรวจสอบความยาว ([Pull Request](https://github.com/rails/rails/pull/30674))

*   ดำเนินการตรวจสอบความถูกต้องของ `ConfirmationValidator` เมื่อค่าของ `_confirmation` เป็น `false` ([Pull Request](https://github.com/rails/rails/pull/31058))

*   โมเดลที่ใช้ attributes API ด้วยค่าเริ่มต้นแบบ proc ตอนนี้สามารถถูก marshalled ได้ ([Commit](https://github.com/rails/rails/commit/0af36c62a5710e023402e37b019ad9982e69de4b))

*   ไม่สูญเสียการรวม `:includes` หลายๆ ครั้งที่มีตัวเลือกในการซีเรียลไลซ์ ([Commit](https://github.com/rails/rails/commit/853054bcc7a043eea78c97e7705a46abb603cc44))

Active Support
--------------

โปรดอ้างอิงที่ [Changelog][active-support] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบตัวกรองสตริง `:if` และ `:unless` ที่ถูกยกเลิกสำหรับ callback ([Commit](https://github.com/rails/rails/commit/c792354adcbf8c966f274915c605c6713b840548))

*   ลบตัวเลือก `halt_callback_chains_on_return_false` ที่ถูกยกเลิก ([Commit](https://github.com/rails/rails/commit/19fbbebb1665e482d76cae30166b46e74ceafe29))

### การเลิกใช้

*   เลิกใช้เมธอด `Module#reachable?` ([Pull Request](https://github.com/rails/rails/pull/30624))

*   เลิกใช้ `secrets.secret_token` ([Commit](https://github.com/rails/rails/commit/fbcc4bfe9a211e219da5d0bb01d894fcdaef0a0e))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม `fetch_values` สำหรับ `HashWithIndifferentAccess` ([Pull Request](https://github.com/rails/rails/pull/28316))
*   เพิ่มการสนับสนุนสำหรับ `:offset` ใน `Time#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   เพิ่มการสนับสนุนสำหรับ `:offset` และ `:zone`
    ใน `ActiveSupport::TimeWithZone#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   ส่งชื่อ gem และระยะเวลาการเลิกใช้งานไปยังการแจ้งเตือนการเลิกใช้งาน
    ([Pull Request](https://github.com/rails/rails/pull/28800))

*   เพิ่มการสนับสนุนสำหรับรายการแคชที่มีเวอร์ชัน ซึ่งช่วยให้ร้านค้าแคชสามารถนำกลับมาใช้ใหม่ได้ ลดการใช้พื้นที่จัดเก็บได้อย่างมากในกรณีที่มีการเปลี่ยนแปลงบ่อยครั้ง ทำงานร่วมกับการแยก `#cache_key` และ `#cache_version` ใน Active Record และใช้ในการแคชของ Action Pack's fragment caching
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   เพิ่ม `ActiveSupport::CurrentAttributes` เพื่อให้สามารถเก็บค่าแอตทริบิวต์ในเธรดแยกกันได้ ใช้งานหลักคือการทำให้แอตทริบิวต์ที่เกี่ยวข้องกับแต่ละคำขอสามารถเข้าถึงได้ง่ายทั้งระบบ
    ([Pull Request](https://github.com/rails/rails/pull/29180))

*   `#singularize` และ `#pluralize` ตอนนี้รับรู้ถึงคำที่ไม่นับได้สำหรับภาษาที่ระบุ
    ([Commit](https://github.com/rails/rails/commit/352865d0f835c24daa9a2e9863dcc9dde9e5371a))

*   เพิ่มตัวเลือกเริ่มต้นใน `class_attribute`
    ([Pull Request](https://github.com/rails/rails/pull/29270))

*   เพิ่ม `Date#prev_occurring` และ `Date#next_occurring` เพื่อคืนค่าวันที่เกิดขึ้นต่อไป/ก่อนหน้าที่ระบุ
    ([Pull Request](https://github.com/rails/rails/pull/26600))

*   เพิ่มตัวเลือกเริ่มต้นในการเข้าถึงแอตทริบิวต์ของโมดูลและคลาส
    ([Pull Request](https://github.com/rails/rails/pull/29294))

*   แคช: `write_multi`
    ([Pull Request](https://github.com/rails/rails/pull/29366))

*   ตั้งค่า `ActiveSupport::MessageEncryptor` เริ่มต้นใช้การเข้ารหัส AES 256 GCM
    ([Pull Request](https://github.com/rails/rails/pull/29263))

*   เพิ่ม `freeze_time` helper ซึ่งจะแช่แข็งเวลาเป็น `Time.now` ในการทดสอบ
    ([Pull Request](https://github.com/rails/rails/pull/29681))

*   ทำให้ลำดับของ `Hash#reverse_merge!` สอดคล้องกับ `HashWithIndifferentAccess`
    ([Pull Request](https://github.com/rails/rails/pull/28077))

*   เพิ่มการสนับสนุนวัตถุประสงค์และการหมดอายุใน `ActiveSupport::MessageVerifier` และ `ActiveSupport::MessageEncryptor`
    ([Pull Request](https://github.com/rails/rails/pull/29892))

*   อัปเดต `String#camelize` เพื่อให้มีการตอบกลับเมื่อมีตัวเลือกที่ไม่ถูกต้อง
    ([Pull Request](https://github.com/rails/rails/pull/30039))

*   `Module#delegate_missing_to` ตอนนี้เรียก `DelegationError` ถ้าเป้าหมายเป็น nil เหมือนกับ `Module#delegate`
    ([Pull Request](https://github.com/rails/rails/pull/30191))

*   เพิ่ม `ActiveSupport::EncryptedFile` และ `ActiveSupport::EncryptedConfiguration`
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   เพิ่ม `config/credentials.yml.enc` เพื่อเก็บค่าลับของแอปพลิเคชันในสภาพแวดล้อมการใช้งานจริง
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   เพิ่มการสนับสนุนการหมุนเวียนคีย์ใน `MessageEncryptor` และ `MessageVerifier`
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   คืนวัตถุของ `HashWithIndifferentAccess` จาก `HashWithIndifferentAccess#transform_keys`
    ([Pull Request](https://github.com/rails/rails/pull/30728))

*   `Hash#slice` ตอนนี้ใช้นิยามที่มีอยู่ใน Ruby 2.5+ ถ้าถูกกำหนดไว้
    ([Commit](https://github.com/rails/rails/commit/01ae39660243bc5f0a986e20f9c9bff312b1b5f8))

*   `IO#to_json` ตอนนี้คืนค่าเป็นการแสดงผลของ `to_s` แทนที่จะพยายามแปลงเป็นอาร์เรย์ นี้แก้ไขข้อบกพร่องที่ `IO#to_json` จะเกิดข้อผิดพลาด `IOError` เมื่อเรียกใช้กับวัตถุที่ไม่สามารถอ่านได้
    ([Pull Request](https://github.com/rails/rails/pull/30953))
*   เพิ่มลายเซ็นเมธอดเดียวกันสำหรับ `Time#prev_day` และ `Time#next_day` ให้เหมือนกับ `Date#prev_day` และ `Date#next_day` อนุญาตให้ส่งอาร์กิวเมนต์ไปยัง `Time#prev_day` และ `Time#next_day` ([Commit](https://github.com/rails/rails/commit/61ac2167eff741bffb44aec231f4ea13d004134e))

*   เพิ่มลายเซ็นเมธอดเดียวกันสำหรับ `Time#prev_month` และ `Time#next_month` ให้เหมือนกับ `Date#prev_month` และ `Date#next_month` อนุญาตให้ส่งอาร์กิวเมนต์ไปยัง `Time#prev_month` และ `Time#next_month` ([Commit](https://github.com/rails/rails/commit/f2c1e3a793570584d9708aaee387214bc3543530))

*   เพิ่มลายเซ็นเมธอดเดียวกันสำหรับ `Time#prev_year` และ `Time#next_year` ให้เหมือนกับ `Date#prev_year` และ `Date#next_year` อนุญาตให้ส่งอาร์กิวเมนต์ไปยัง `Time#prev_year` และ `Time#next_year` ([Commit](https://github.com/rails/rails/commit/ee9d81837b5eba9d5ec869ae7601d7ffce763e3e))

*   แก้ไขการสนับสนุนอะครอนิมใน `humanize` ([Commit](https://github.com/rails/rails/commit/0ddde0a8fca6a0ca3158e3329713959acd65605d))

*   อนุญาตให้ใช้ `Range#include?` ในช่วง TWZ ([Pull Request](https://github.com/rails/rails/pull/31081))

*   แคช: เปิดใช้งานการบีบอัดโดยค่าเริ่มต้นสำหรับค่าที่มีขนาดมากกว่า 1kB ([Pull Request](https://github.com/rails/rails/pull/31147))

*   Redis cache store ([Pull Request](https://github.com/rails/rails/pull/31134), [Pull Request](https://github.com/rails/rails/pull/31866))

*   จัดการข้อผิดพลาด `TZInfo::AmbiguousTime` ([Pull Request](https://github.com/rails/rails/pull/31128))

*   MemCacheStore: สนับสนุนการหมดอายุของตัวนับ ([Commit](https://github.com/rails/rails/commit/b22ee64b5b30c6d5039c292235e10b24b1057f6d))

*   ทำให้ `ActiveSupport::TimeZone.all` ส่งคืนเฉพาะเขตเวลาที่อยู่ใน `ActiveSupport::TimeZone::MAPPING` ([Pull Request](https://github.com/rails/rails/pull/31176))

*   เปลี่ยนพฤติกรรมเริ่มต้นของ `ActiveSupport::SecurityUtils.secure_compare` เพื่อไม่ให้รั่วไหลข้อมูลความยาวแม้แต่สำหรับสตริงที่มีความยาวแปรผัน แก้ชื่อ `ActiveSupport::SecurityUtils.secure_compare` เดิมเป็น `fixed_length_secure_compare` และเริ่มเรียก `ArgumentError` ในกรณีที่ความยาวของสตริงที่ส่งผ่านไม่ตรงกัน ([Pull Request](https://github.com/rails/rails/pull/24510))

*   ใช้ SHA-1 เพื่อสร้างดิจิตอลเซ็นต์ที่ไม่เป็นข้อมูลที่สำคัญ เช่น ETag header ([Pull Request](https://github.com/rails/rails/pull/31289), [Pull Request](https://github.com/rails/rails/pull/31651))

*   `assert_changes` จะตรวจสอบเสมอว่านิพจน์เปลี่ยนแปลง ไม่ว่าจะมีการระบุ `from:` และ `to:` อย่างไรก็ตาม ([Pull Request](https://github.com/rails/rails/pull/31011))

*   เพิ่มการตรวจสอบการเขียน `read_multi` ใน `ActiveSupport::Cache::Store` ([Pull Request](https://github.com/rails/rails/pull/30268))

*   สนับสนุนการใช้แฮชเป็นอาร์กิวเมนต์แรกใน `assert_difference` นี้ช่วยให้ระบุความแตกต่างทางตัวเลขหลายอย่างในการตรวจสอบเดียว ([Pull Request](https://github.com/rails/rails/pull/31600))

*   การแคช: MemCache และ Redis `read_multi` และ `fetch_multi` ทำให้เรียกจากแคชในหน่วยความจำในเครื่องก่อนที่จะเรียกจากแหล่งข้อมูลหลัง ([Commit](https://github.com/rails/rails/commit/a2b97e4ffef971607a1be8fc7909f099b6840f36))

Active Job
----------

โปรดอ้างอิงที่ [Changelog][active-job] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

*   อนุญาตให้ส่งบล็อกไปยัง `ActiveJob::Base.discard_on` เพื่ออนุญาตให้ปรับแต่งการจัดการงานที่ถูกละทิ้ง ([Pull Request](https://github.com/rails/rails/pull/30622))

Ruby on Rails Guides
--------------------

โปรดอ้างอิงที่ [Changelog][guides] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม [Threading and Code Execution in Rails](threading_and_code_execution.html) Guide ([Pull Request](https://github.com/rails/rails/pull/27494))
*   เพิ่ม [Active Storage Overview](active_storage_overview.html) Guide.
    ([Pull Request](https://github.com/rails/rails/pull/31037))

เครดิต
-------

ดู
[รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](https://contributors.rubyonrails.org/)
สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและแข็งแรง ยินดีด้วยทุกคน.

[railties]:       https://github.com/rails/rails/blob/5-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-2-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-2-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-2-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-2-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/5-2-stable/guides/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-2-stable/activesupport/CHANGELOG.md
