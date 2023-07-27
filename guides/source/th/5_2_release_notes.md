**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c7252bf18650c5a9a85fc144305c4615
เอกสารปล่อยตัวของ Ruby on Rails 5.2
===============================

จุดเด่นใน Rails 5.2:

* Active Storage
* Redis Cache Store
* HTTP/2 Early Hints
* Credentials
* Content Security Policy

เอกสารปล่อยตัวนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่เอกสารเปลี่ยนแปลงหรือตรวจสอบ [รายการของการเปลี่ยนแปลง](https://github.com/rails/rails/commits/5-2-stable) ในเก็บข้อมูลหลักของ Rails ใน GitHub

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 5.2
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 5.1 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 5.2 มีรายการสิ่งที่ควรระมัดระวังเมื่ออัปเกรดใน [คู่มือการอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2)

คุณสมบัติหลัก
--------------

### Active Storage

[Pull Request](https://github.com/rails/rails/pull/30020)

[Active Storage](https://github.com/rails/rails/tree/5-2-stable/activestorage)
ช่วยให้สามารถอัปโหลดไฟล์ไปยังบริการจัดเก็บข้อมูลในคลาวด์ เช่น
Amazon S3, Google Cloud Storage หรือ Microsoft Azure Storage และแนบไฟล์เหล่านั้นกับอ็อบเจ็กต์ Active Record มันมาพร้อมกับบริการที่อยู่ในดิสก์ในเครื่องพัฒนาและทดสอบ และรองรับการสำรองข้อมูลและการย้ายไฟล์ไปยังบริการย่อย ๆ
คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับ Active Storage ในเอกสาร [ภาพรวมของ Active Storage](active_storage_overview.html)

### Redis Cache Store

[Pull Request](https://github.com/rails/rails/pull/31134)

Rails 5.2 มาพร้อมกับ Redis cache store ที่มีอยู่แล้ว
คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับนี้ในเอกสาร [การใช้งานแคชด้วย Rails: ภาพรวม](caching_with_rails.html#activesupport-cache-rediscachestore)

### HTTP/2 Early Hints

[Pull Request](https://github.com/rails/rails/pull/30744)

Rails 5.2 รองรับ [HTTP/2 Early Hints](https://tools.ietf.org/html/rfc8297)
ในการเริ่มต้นเซิร์ฟเวอร์ด้วย Early Hints ให้ส่ง `--early-hints`
ไปยัง `bin/rails server`

### Credentials

[Pull Request](https://github.com/rails/rails/pull/30067)

เพิ่มไฟล์ `config/credentials.yml.enc` เพื่อเก็บความลับของแอปพลิเคชันในระดับการใช้งานจริง
มันช่วยให้คุณสามารถบันทึกข้อมูลการรับรองความถูกต้องสำหรับบริการของบุคคลที่สามโดยตรงในเก็บข้อมูลที่เข้ารหัสด้วยคีย์ในไฟล์ `config/master.key` หรือตัวแปรสภาพแวดล้อม `RAILS_MASTER_KEY`
สิ่งนี้ในที่สุดจะแทนที่ `Rails.application.secrets` และเคล็ดลับที่เข้ารหัสที่เพิ่มเข้ามาใน Rails 5.1
นอกจากนี้ Rails 5.2 ยังเปิด API ใน Credentials ให้คุณใช้งานง่ายกับการกำหนดค่าที่เข้ารหัสอื่น ๆ ไฟล์และคีย์
คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับนี้ในเอกสาร [การรักษาความปลอดภัยของแอปพลิเคชัน Rails](security.html#custom-credentials)

### Content Security Policy

[Pull Request](https://github.com/rails/rails/pull/31162)

Rails 5.2 มาพร้อมกับ DSL ใหม่ที่ช่วยให้คุณสามารถกำหนดค่า
[Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)
สำหรับแอปพลิเคชันของคุณ คุณสามารถกำหนดค่าเริ่มต้นทั่วไปแล้วแทนที่ได้บนพื้นฐานของแต่ละทรัพยากรและใช้ lambda เพื่อฉีกข้อมูลตามคำขอลงในส่วนหัว เช่น โดเมนย่อยของบัญชีในแอปพลิเคชันหลายๆ ร้านค้า
คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับนี้ในเอกสาร [การรักษาความปลอดภัยของแอปพลิเคชัน Rails](security.html#content-security-policy)

Railties
--------

โปรดอ้างอิงที่ [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเลิกใช้งาน

*   เลิกใช้งานเมธอด `capify!` ใน generators และ templates
    ([Pull Request](https://github.com/rails/rails/pull/29493))

*   เลิกใช้การส่งชื่อสภาพแวดล้อมเป็นอาร์กิวเมนต์ปกติในคำสั่ง `rails dbconsole` และ `rails console` แทน ควรใช้ตัวเลือก `-e` แทน
    ([Commit](https://github.com/rails/rails/commit/48b249927375465a7102acc71c2dfb8d49af8309))

*   เลิกใช้งานการใช้คลาสย่อยของ `Rails::Application` เพื่อเริ่มเซิร์ฟเวอร์ Rails
    ([Pull Request](https://github.com/rails/rails/pull/30127))

*   เลิกใช้งาน `after_bundle` callback ใน Rails plugin templates
    ([Pull Request](https://github.com/rails/rails/pull/29446))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มส่วนที่แชร์ใน `config/database.yml` ที่จะโหลดสำหรับทุกสภาพแวดล้อม
    ([Pull Request](https://github.com/rails/rails/pull/28896))

*   เพิ่ม `railtie.rb` ใน generator ของ plugin
    ([Pull Request](https://github.com/rails/rails/pull/29576))

*   ล้างไฟล์ภาพหน้าจอในงาน `tmp:clear`
    ([Pull Request](https://github.com/rails/rails/pull/29534))

*   ข้ามคอมโพเนนต์ที่ไม่ได้ใช้เมื่อเรียกใช้งาน `bin/rails app:update`
    หากการสร้างแอปเริ่มต้นข้าม Action Cable, Active Record ฯลฯ งานอัปเดตจะใช้งานการข้ามเหล่านั้นด้วย
    ([Pull Request](https://github.com/rails/rails/pull/29645))

*   อนุญาตให้ระบุชื่อการเชื่อมต่อที่กำหน
*   เพิ่มเวอร์ชัน `ruby x.x.x` ใน `Gemfile` และสร้างไฟล์ `.ruby-version` ที่เก็บเวอร์ชัน Ruby ปัจจุบันเมื่อสร้างแอปพลิเคชัน Rails ใหม่
    ([Pull Request](https://github.com/rails/rails/pull/30016))

*   เพิ่มตัวเลือก `--skip-action-cable` ในเจเนอเรเตอร์ของปลั๊กอิน
    ([Pull Request](https://github.com/rails/rails/pull/30164))

*   เพิ่ม `git_source` ใน `Gemfile` สำหรับเจเนอเรเตอร์ของปลั๊กอิน
    ([Pull Request](https://github.com/rails/rails/pull/30110))

*   ข้ามคอมโพเนนต์ที่ไม่ได้ใช้งานเมื่อรัน `bin/rails` ในปลั๊กอิน Rails
    ([Commit](https://github.com/rails/rails/commit/62499cb6e088c3bc32a9396322c7473a17a28640))

*   ปรับปรุงการเยื้องบรรทัดสำหรับการกระทำของเจเนอเรเตอร์
    ([Pull Request](https://github.com/rails/rails/pull/30166))

*   ปรับปรุงการเยื้องบรรทัดของเส้นทาง
    ([Pull Request](https://github.com/rails/rails/pull/30241))

*   เพิ่มตัวเลือก `--skip-yarn` ในเจเนอเรเตอร์ของปลั๊กอิน
    ([Pull Request](https://github.com/rails/rails/pull/30238))

*   รองรับอาร์กิวเมนต์เวอร์ชันหลายรุ่นสำหรับเมธอด `gem` ของเจเนอเรเตอร์
    ([Pull Request](https://github.com/rails/rails/pull/30323))

*   สร้าง `secret_key_base` จากชื่อแอปในสภาพแวดล้อมการพัฒนาและทดสอบ
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   เพิ่ม `mini_magick` เป็นคอมเมนต์ใน `Gemfile` เริ่มต้น
    ([Pull Request](https://github.com/rails/rails/pull/30633))

*   `rails new` และ `rails plugin new` ได้รับ `Active Storage` โดยค่าเริ่มต้น
    เพิ่มความสามารถในการข้าม `Active Storage` ด้วย `--skip-active-storage`
    และทำเช่นนั้นโดยอัตโนมัติเมื่อใช้ `--skip-active-record`
    ([Pull Request](https://github.com/rails/rails/pull/30101))

Action Cable
------------

โปรดดู [Changelog][action-cable] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบแอดเพลต Redis ที่ถูกยกเลิกแล้ว
    ([Commit](https://github.com/rails/rails/commit/48766e32d31651606b9f68a16015ad05c3b0de2c))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มการสนับสนุนตัวเลือก `host`, `port`, `db` และ `password` ใน cable.yml
    ([Pull Request](https://github.com/rails/rails/pull/29528))

*   แฮชตัวระบุสตรีมยาวเมื่อใช้แอดเพลต PostgreSQL
    ([Pull Request](https://github.com/rails/rails/pull/29297))

Action Pack
-----------

โปรดดู [Changelog][action-pack] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `ActionController::ParamsParser::ParseError` ที่ถูกยกเลิกแล้ว
    ([Commit](https://github.com/rails/rails/commit/e16c765ac6dcff068ff2e5554d69ff345c003de1))

### การเลิกใช้

*   เลิกใช้ตัวย่อ `#success?`, `#missing?` และ `#error?` ของ `ActionDispatch::TestResponse`
    ([Pull Request](https://github.com/rails/rails/pull/30104))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มการสนับสนุนการใช้งานแคชคีย์ที่สามารถนำกลับมาใช้ใหม่ได้ด้วยการแยกชิ้นส่วน
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   เปลี่ยนรูปแบบคีย์แคชสำหรับชิ้นส่วนเพื่อทำให้ง่ายต่อการตรวจสอบคีย์ที่เปลี่ยนแปลง
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   คุกกี้และเซสชันที่เข้ารหัสด้วย AEAD ด้วย GCM
    ([Pull Request](https://github.com/rails/rails/pull/28132))

*   ป้องกันการปลอมแปลงโดยค่าเริ่มต้น
    ([Pull Request](https://github.com/rails/rails/pull/29742))

*   บังคับให้คุกกี้ที่เข้ารหัสลับ/เข้ารหัสลับหมดอายุที่เซิร์ฟเวอร์
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   ตัวเลือก `:expires` ของคุกกี้รองรับอ็อบเจกต์ `ActiveSupport::Duration`
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   ใช้การตั้งค่าเซิร์ฟเวอร์ `:puma` ที่ลงทะเบียนใน Capybara
    ([Pull Request](https://github.com/rails/rails/pull/30638))

*   Vereinfachen Sie das Cookies-Middleware mit Unterstützung für Schlüsselrotation.
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   เพิ่มความสามารถในการเปิดใช้งาน
Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog][action-mailer] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

*   อนุญาตให้คลาส Action Mailer กำหนดค่างานส่งของตนเองได้
    ([Pull Request](https://github.com/rails/rails/pull/29457))

*   เพิ่มเครื่องมือช่วยทดสอบ `assert_enqueued_email_with`
    ([Pull Request](https://github.com/rails/rails/pull/30695))

Active Record
-------------

โปรดอ้างอิงที่ [Changelog][active-record] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `#migration_keys` ที่ถูกยกเลิก
    ([Pull Request](https://github.com/rails/rails/pull/30337))

*   ลบการสนับสนุนที่ถูกยกเลิกใน `quoted_id` เมื่อทำการแปลงประเภท
    อ็อบเจ็กต์ Active Record
    ([Commit](https://github.com/rails/rails/commit/82472b3922bda2f337a79cef961b4760d04f9689))

*   ลบอาร์กิวเมนต์ที่ถูกยกเลิกใน `default` จาก `index_name_exists?`
    ([Commit](https://github.com/rails/rails/commit/8f5b34df81175e30f68879479243fbce966122d7))

*   ลบการสนับสนุนที่ถูกยกเลิกในการส่งคลาสไปยัง `:class_name`
    ในการเชื่อมโยง
    ([Commit](https://github.com/rails/rails/commit/e65aff70696be52b46ebe57207ebd8bb2cfcdbb6))

*   ลบเมธอดที่ถูกยกเลิก `initialize_schema_migrations_table` และ
    `initialize_internal_metadata_table`
    ([Commit](https://github.com/rails/rails/commit/c9660b5777707658c414b430753029cd9bc39934))

*   ลบเมธอดที่ถูกยกเลิก `supports_migrations?`
    ([Commit](https://github.com/rails/rails/commit/9438c144b1893f2a59ec0924afe4d46bd8d5ffdd))

*   ลบเมธอดที่ถูกยกเลิก `supports_primary_key?`
    ([Commit](https://github.com/rails/rails/commit/c56ff22fc6e97df4656ddc22909d9bf8b0c2cbb1))

*   ลบเมธอดที่ถูกยกเลิก
    `ActiveRecord::Migrator.schema_migrations_table_name`
    ([Commit](https://github.com/rails/rails/commit/7df6e3f3cbdea9a0460ddbab445c81fbb1cfd012))

*   ลบอาร์กิวเมนต์ที่ถูกยกเลิก `name` จาก `#indexes`
    ([Commit](https://github.com/rails/rails/commit/d6b779ecebe57f6629352c34bfd6c442ac8fba0e))

*   ลบอาร์กิวเมนต์ที่ถูกยกเลิกจาก `#verify!`
    ([Commit](https://github.com/rails/rails/commit/9c6ee1bed0292fc32c23dc1c68951ae64fc510be))

*   ลบการกำหนดค่าที่ถูกยกเลิก `.error_on_ignored_order_or_limit`
    ([Commit](https://github.com/rails/rails/commit/e1066f450d1a99c9a0b4d786b202e2ca82a4c3b3))

*   ลบเมธอดที่ถูกยกเลิก `#scope_chain`
    ([Commit](https://github.com/rails/rails/commit/ef7784752c5c5efbe23f62d2bbcc62d4fd8aacab))

*   ลบเมธอดที่ถูกยกเลิก `#sanitize_conditions`
    ([Commit](https://github.com/rails/rails/commit/8f5413b896099f80ef46a97819fe47a820417bc2))

### การเลิกใช้

*   เลิกใช้ `supports_statement_cache?`
    ([Pull Request](https://github.com/rails/rails/pull/28938))

*   เลิกใช้การส่งอาร์กิวเมนต์และบล็อกพร้อมกันใน `count` และ `sum`
    ใน `ActiveRecord::Calculations`
    ([Pull Request](https://github.com/rails/rails/pull/29262))

*   เลิกใช้การจัดส่งไปยัง `arel` ใน `Relation`
    ([Pull Request](https://github.com/rails/rails/pull/29619))

*   เลิกใช้เมธอด `set_state` ใน `TransactionState`
    ([Commit](https://github.com/rails/rails/commit/608ebccf8f6314c945444b400a37c2d07f21b253))

*   เลิกใช้ `expand_hash_conditions_for_aggregates` โดยไม่มีการแทนที่
    ([Commit](https://github.com/rails/rails/commit/7ae26885d96daee3809d0bd50b1a440c2f5ffb69))

### การเปลี่ยนแปลงที่สำคัญ

*   เมื่อเรียกใช้เมธอด dynamic fixture accessor โดยไม่มีอาร์กิวเมนต์
    ตอนนี้จะคืนค่า fixtures ทั้งหมดของประเภทนี้ ก่อนหน้านี้
    เมธอดนี้เสมอคืนค่าอาร์เรย์ที่ว่างเปล่า
    ([Pull Request](https://github.com/rails/rails/pull/28692))

*   แก้ไขความไม่สมดุลของแอตทริบิวต์ที่เปลี่ยนแปลงเมื่อโอเวอร์ไรด์
    Active Record attribute reader
    ([Pull Request](https://github.com/rails/rails/pull/28661))

*   สนับสนุน Descending Indexes สำหรับ MySQL
    ([Pull Request](https://github.com/rails/rails/pull/28773))

*   แก้ไข `bin/rails db:forward` การทำงานครั้งแรกของการเรียกใช้ migration
    ([Commit](https://github.com/rails/rails/commit/b77d2aa0c336492ba33cbfade4964ba0eda3ef84))

*   สร้างข้อผิดพลาด `UnknownMigrationVersionError` เมื่อย้าย migration
    แล้วไม่มี migration ปัจจุบันอยู่
    ([Commit
* เพิ่มคลาสข้อผิดพลาดใหม่ `LockWaitTimeout` ซึ่งจะถูกเรียกขึ้นเมื่อเกินเวลาที่รอล็อก ([Pull Request](https://github.com/rails/rails/pull/30360))

* อัปเดตชื่อ payload สำหรับการตรวจวัด `sql.active_record` เพื่อให้มีคำอธิบายที่เป็นคำอธิบายมากขึ้น ([Pull Request](https://github.com/rails/rails/pull/30619))

* ใช้อัลกอริทึมที่กำหนดให้ในขณะที่ลบดัชนีจากฐานข้อมูล ([Pull Request](https://github.com/rails/rails/pull/24199))

* การส่ง `Set` ไปยัง `Relation#where` ตอนนี้จะมีพฤติกรรมเดียวกับการส่งอาร์เรย์ ([Commit](https://github.com/rails/rails/commit/9cf7e3494f5bd34f1382c1ff4ea3d811a4972ae2))

* PostgreSQL `tsrange` ตอนนี้จะเก็บรักษาความแม่นยำในระดับเศษวินาที ([Pull Request](https://github.com/rails/rails/pull/30725))

* เรียกขึ้นเมื่อเรียกใช้ `lock!` ในระเบียนที่มีการเปลี่ยนแปลง ([Commit](https://github.com/rails/rails/commit/63cf15877bae859ff7b4ebaf05186f3ca79c1863))

* แก้ไขข้อบกพร่องที่เรียงลำดับคอลัมน์สำหรับดัชนีไม่ถูกเขียนลงใน `db/schema.rb` เมื่อใช้แอดเปอร์ SQLite ([Pull Request](https://github.com/rails/rails/pull/30970))

* แก้ไข `bin/rails db:migrate` ด้วย `VERSION` ที่ระบุ  `bin/rails db:migrate` โดยไม่ระบุ `VERSION` จะมีพฤติกรรมเหมือนกับการไม่ระบุ `VERSION` ตรวจสอบรูปแบบของ `VERSION` : อนุญาตให้ใช้หมายเลขเวอร์ชันของการเมืองหรือชื่อของไฟล์การเมือง สร้างข้อผิดพลาดหากรูปแบบของ `VERSION` ไม่ถูกต้อง สร้างข้อผิดพลาดหากไม่มีการเมืองเป้าหมาย ([Pull Request](https://github.com/rails/rails/pull/30714))

* เพิ่มคลาสข้อผิดพลาดใหม่ `StatementTimeout` ซึ่งจะถูกเรียกขึ้นเมื่อเกินเวลาคำสั่ง ([Pull Request](https://github.com/rails/rails/pull/31129))

* `update_all` ตอนนี้จะส่งค่าของมันไปยัง `Type#cast` ก่อนที่จะส่งไปยัง `Type#serialize` นั่นหมายความว่า `update_all(foo: 'true')` จะเก็บค่า boolean ได้อย่างถูกต้อง ([Commit](https://github.com/rails/rails/commit/68fe6b08ee72cc47263e0d2c9ff07f75c4b42761))

* ต้องการชิ้นส่วน SQL ให้ระบุไว้โดยชัดเจนเมื่อใช้ในเมธอดการสอบถามความสัมพันธ์ ([Commit](https://github.com/rails/rails/commit/a1ee43d2170dd6adf5a9f390df2b1dde45018a48), [Commit](https://github.com/rails/rails/commit/e4a921a75f8702a7dbaf41e31130fe884dea93f9))

* เพิ่ม `#up_only` ในการเมืองฐานข้อมูลสำหรับรหัสที่เกี่ยวข้องเฉพาะเมื่อเริ่มการเมืองขึ้น เช่น เติมคอลัมน์ใหม่ ([Pull Request](https://github.com/rails/rails/pull/31082))

* เพิ่มคลาสข้อผิดพลาดใหม่ `QueryCanceled` ซึ่งจะถูกเรียกขึ้นเมื่อยกเลิกคำสั่งเนื่องจากคำขอของผู้ใช้ ([Pull Request](https://github.com/rails/rails/pull/31235))

* ไม่อนุญาตให้กำหนดขอบเขตที่ขัดแย้งกับเมธอดของอินสแตนซ์บน `Relation` ([Pull Request](https://github.com/rails/rails/pull/31179))

* เพิ่มการสนับสนุนสำหรับคลาสตัวดำเนินการ PostgreSQL ไปยัง `add_index` ([Pull Request](https://github.com/rails/rails/pull/19090))

* บันทึกผู้เรียกคำสั่งฐานข้อมูล ([Pull Request](https://github.com/rails/rails/pull/26815), [Pull Request](https://github.com/rails/rails/pull/31519), [Pull Request](https://github.com/rails/rails/pull/31690))

* ยกเลิกการกำหนดเมธอดแอตทริบิวต์ในลูกสายเมื่อรีเซ็ตข้อมูลคอลัมน์ ([Pull Request](https://github.com/rails/rails/pull/31475))

* ใช้ subselect สำหรับ `delete_all` ด้วย `limit` หรือ `offset` ([Commit](https://github.com/rails/rails/commit/9e7260da1bdc0770cf4ac547120c85ab93ff3d48))

* แก้ไขความไม่สอดคล้องกันของ `first(n)` เมื่อใช้กับ `limit()` ตัวค้นหา `first(n)` ตอนนี้จะใช้ `limit()` อย่างถูกต้อง ทำให้สอดคล้องกับ `relation.to_a.first(n)` และก็กับพฤติกรรมของ `last(n)` ([Pull Request](https://github.com/rails/rails/pull/27597))

* แก้ไขปัญหา `has_many :through` ที่ซ้อนกันบนตัวอย่างที่ยังไม่ได้ถูกบันทึก ([Commit](https://github.com/rails/rails/commit/027f865fc8b262d9ba3ee51da3483e94a5489b66))

* พิจารณาเงื่อนไขความสัมพันธ์เมื่อลบผ่านบันทึก ([Commit](https://github.com/rails/rails/commit/ae48c65e411e01c1045056562319666384bb1b63))

* ไม่อนุญาตให้วัตถุที่ถูกทำลายเปลี่ยนแปลงหลังจากเรียกใช้
โปรดอ้างอิง [Changelog][active-support] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

การลบ

- ลบตัวกรองสตริง `:if` และ `:unless` ที่ถูกยกเลิกสำหรับ callback
    ([Commit](https://github.com/rails/rails/commit/c792354adcbf8c966f274915c605c6713b840548))

- ลบตัวเลือก `halt_callback_chains_on_return_false` ที่ถูกยกเลิก
    ([Commit](https://github.com/rails/rails/commit/19fbbebb1665e482d76cae30166b46e74ceafe29))

การเลิกใช้

- เลิกใช้เมธอด `Module#reachable?`
    ([Pull Request](https://github.com/rails/rails/pull/30624))

- เลิกใช้ `secrets.secret_token`
    ([Commit](https://github.com/rails/rails/commit/fbcc4bfe9a211e219da5d0bb01d894fcdaef0a0e))

การเปลี่ยนแปลงที่สำคัญ

- เพิ่ม `fetch_values` สำหรับ `HashWithIndifferentAccess`
    ([Pull Request](https://github.com/rails/rails/pull/28316))

- เพิ่มการสนับสนุน `:offset` ให้กับ `Time#change`
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

- เพิ่มการสนับสนุน `:offset` และ `:zone` ให้กับ `ActiveSupport::TimeWithZone#change`
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

- ส่งชื่อ gem และระยะเวลาการเลิกใช้ไปยังการแจ้งเตือนการเลิกใช้
    ([Pull Request](https://github.com/rails/rails/pull/28800))

- เพิ่มการสนับสนุนสำหรับรายการแคชที่มีเวอร์ชัน ซึ่งช่วยให้ร้านค้าแคชสามารถนำกลับมาใช้ใหม่ได้ ลดการใช้พื้นที่จัดเก็บได้อย่างมากในกรณีที่มีการเปลี่ยนแปลงบ่อยครั้ง ทำงานร่วมกับการแยก `#cache_key` และ `#cache_version` ใน Active Record และใช้ในการแคชของ Action Pack's fragment
    ([Pull Request](https://github.com/rails/rails/pull/29092))

- เพิ่ม `ActiveSupport::CurrentAttributes` เพื่อให้สามารถเก็บค่าแอตทริบิวต์ในเธรดได้ ใช้งานหลักคือการทำให้แอตทริบิวต์ที่เกี่ยวข้องกับคำขอทั้งหมดสามารถใช้งานได้ง่ายในระบบทั้งหมด
    ([Pull Request](https://github.com/rails/rails/pull/29180))

- `#singularize` และ `#pluralize` ตอนนี้จะใช้คำที่ไม่นับได้สำหรับภาษาที่ระบุ
    ([Commit](https://github.com/rails/rails/commit/352865d0f835c24daa9a2e9863dcc9dde9e5371a))

- เพิ่มตัวเลือกเริ่มต้นให้กับ `class_attribute`
    ([Pull Request](https://github.com/rails/rails/pull/29270))

- เพิ่ม `Date#prev_occurring` และ `Date#next_occurring` เพื่อคืนค่าวันที่เกิดขึ้นถัดไป/ก่อนหน้าที่ระบุ
    ([Pull Request](https://github.com/rails/rails/pull/26600))

- เพิ่มตัวเลือกเริ่มต้นให้กับเข้าถึงแอตทริบิวต์ของโมดูลและคลาส
    ([Pull Request](https://github.com/rails/rails/pull/29294))

- แคช: `write_multi`
    ([Pull Request](https://github.com/rails/rails/pull/29366))

- ตั้งค่าเริ่มต้น `ActiveSupport::MessageEncryptor` ให้ใช้การเข้ารหัส AES 256 GCM
    ([Pull Request](https://github.com/rails/rails/pull/29263))

- เพิ่ม `freeze_time` helper ซึ่งจะแช่เวลาไว้ที่ `Time.now` ในการทดสอบ
    ([Pull Request](https://github.com/rails/rails/pull/29681))

- ทำให้ลำดับของ `Hash#reverse_merge!` สอดคล้องกับ `HashWithIndifferentAccess`
    ([Pull Request](https://github.com/rails/rails/pull/28077))

- เพิ่มการสนับสนุนวัตถุประสงค์และการหมดอายุให้กับ `ActiveSupport::MessageVerifier` และ `ActiveSupport::MessageEncryptor`
    ([Pull Request](https://github.com/rails/rails/pull/29892))

- อัปเดต `String#camelize` เพื่อให้ให้ข้อเสนอแนะเมื่อมีการส่งตัวเลือกที่ไม่ถูกต้อง
    ([Pull Request](https://github.com/rails/rails/pull/30039))

- `Module#delegate_missing_to` ตอนนี้จะเรียก `DelegationError` ถ้าเป้าหมายเป็นค่าว่างเหมือนกับ `Module#delegate`
    ([Pull Request](https://github.com/rails/rails/pull/30191))

- เพิ่ม `ActiveSupport::EncryptedFile` และ `ActiveSupport::EncryptedConfiguration`
    ([Pull Request](https://github.com/rails/rails/pull/30067))

- เพิ่ม `config/credentials.yml.enc` เพื่อเก็บความลับของแอปพลิเคชันในโหมดการใช้งานจริง
    ([Pull Request](https://github.com/rails/rails/pull/30067))

- เพิ่มการสนับสนุนการหมุนเวียนคีย์ให้กับ `Message
Active Job
----------

โปรดอ้างอิงที่ [Changelog][active-job] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

*   อนุญาตให้ส่งบล็อกไปยัง `ActiveJob::Base.discard_on` เพื่ออนุญาตให้ปรับแต่งการจัดการงานที่ถูกละทิ้ง
    ([Pull Request](https://github.com/rails/rails/pull/30622))

Ruby on Rails Guides
--------------------

โปรดอ้างอิงที่ [Changelog][guides] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม [Threading and Code Execution in Rails](threading_and_code_execution.html) Guide
    ([Pull Request](https://github.com/rails/rails/pull/27494))

*   เพิ่ม [Active Storage Overview](active_storage_overview.html) Guide
    ([Pull Request](https://github.com/rails/rails/pull/31037))

เครดิต
-------

ดูรายชื่อเต็มของผู้มีส่วนร่วมใน Rails ได้ที่
[full list of contributors to Rails](https://contributors.rubyonrails.org/)
สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและทนทาน ยินดีด้วยทุกคน

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
