**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b1c2c8ad5c4bacb2e3b92aa320c4da3d
เอกสารปล่อยตัวของ Ruby on Rails 6.0
===============================

จุดเด่นใน Rails 6.0:

* Action Mailbox
* Action Text
* Parallel Testing
* Action Cable Testing

เอกสารปล่อยตัวนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่ changelogs หรือตรวจสอบ [รายการของ commits](https://github.com/rails/rails/commits/6-0-stable) ในเก็บรวบรวมของ Rails ที่ GitHub

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 6.0
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 5.2 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 6.0 มีรายการสิ่งที่ควรระมัดระวังเมื่ออัปเกรดใน
[การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-2-to-rails-6-0)
คู่มือ

คุณสมบัติหลัก
--------------

### Action Mailbox

[Pull Request](https://github.com/rails/rails/pull/34786)

[Action Mailbox](https://github.com/rails/rails/tree/6-0-stable/actionmailbox) ช่วยให้คุณสามารถเส้นทางอีเมลที่เข้ามาไปยังกล่องจดหมายที่คล้ายกับคอนโทรลเลอร์ได้
คุณสามารถอ่านเพิ่มเติมเกี่ยวกับ Action Mailbox ในคู่มือ [Action Mailbox Basics](action_mailbox_basics.html)

### Action Text

[Pull Request](https://github.com/rails/rails/pull/34873)

[Action Text](https://github.com/rails/rails/tree/6-0-stable/actiontext)
นำเนื้อหาและการแก้ไขข้อความที่มีรูปแบบมาให้กับ Rails มันรวม
[ตัวแก้ไข Trix](https://trix-editor.org) ที่จัดการทุกอย่างตั้งแต่การจัดรูปแบบ
ไปยังการเชื่อมโยงไปยังการอ้างอิงไปยังรายการไปยังการแทรกภาพและแกลเลอรี
เนื้อหาข้อความที่มีรูปแบบที่สร้างขึ้นโดยตัวแก้ไข Trix จะถูกบันทึกไว้ในตัวแบบ RichText ของตัวเอง
โมเดลที่เกี่ยวข้องกับแอปพลิเคชัน Active Record ที่มีอยู่ในแอปพลิเคชัน
ภาพถ่ายภาพภายใน (หรือไฟล์แนบอื่น ๆ) จะถูกเก็บไว้โดยอัตโนมัติโดยใช้
Active Storage และเชื่อมโยงกับตัวแบบ RichText ที่รวมอยู่

คุณสามารถอ่านเพิ่มเติมเกี่ยวกับ Action Text ในคู่มือ [Action Text Overview](action_text_overview.html)

### Parallel Testing

[Pull Request](https://github.com/rails/rails/pull/31900)

[การทดสอบแบบขนาน](testing.html#parallel-testing) ช่วยให้คุณสามารถแบ่งกระบวนการทดสอบของคุณเป็นส่วนย่อย ในขณะที่การคัดลอกกระบวนการเป็นวิธีที่ใช้งานได้ การใช้เธรดก็สามารถทำได้ การรันการทดสอบแบบขนานลดเวลาที่ใช้
ในการรันชุดทดสอบทั้งหมดของคุณ

### Action Cable Testing

[Pull Request](https://github.com/rails/rails/pull/33659)

[เครื่องมือการทดสอบ Action Cable](testing.html#testing-action-cable) ช่วยให้คุณสามารถทดสอบความสามารถของ Action Cable ของคุณได้ทุกระดับ: การเชื่อมต่อ, ช่อง, การแพร่กระจาย

Railties
--------

โปรดอ้างอิงที่ [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบตัวช่วย `after_bundle` ที่ถูกยกเลิกภายในเทมเพลตของปลั๊กอิน
    ([Commit](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

*   ลบการสนับสนุนที่ถูกยกเลิกไปยัง `config.ru` ที่ใช้คลาสแอปพลิเคชัน
    เป็นอาร์กิวเมนต์ของ `run`
    ([Commit](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))

*   ลบอาร์กิวเมนต์ `environment` ที่ถูกยกเลิกจากคำสั่ง rails
    ([Commit](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

*   ลบเมธอด `capify!` ที่ถูกยกเลิกในตัวสร้างและเทมเพลต
    ([Commit](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

*   ลบ `config.secret_token` ที่ถูกยกเลิก
    ([Commit](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### การเลิกใช้

*   เลิกใช้การส่งชื่อเซิร์ฟเวอร์ Rack เป็นอาร์กิวเมนต์ปกติใน `rails server`
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   เลิกใช้การสนับสนุนในการใช้ `HOST` environment เพื่อระบุ IP เซิร์ฟเวอร์
    ([Pull Request](https://github.com/rails/rails/pull/32540))

*   เลิกใช้การเข้าถึงแฮชที่ส่งกลับจาก `config_for` โดยใช้คีย์ที่ไม่ใช่สัญลักษณ์
    ([Pull Request](https://github.com/rails/rails/pull/35198))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มตัวเลือกชัดเจน `--using` หรือ `-u` เพื่อระบุเซิร์ฟเวอร์สำหรับ
    คำสั่ง `rails server`
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   เพิ่มความสามารถในการดูผลลัพธ์ของ `rails routes` ในรูปแบบที่ขยายออก
    ([Pull Request](https://github.com/rails/rails/pull/32130))

*   รันงานฐานข้อมูลเมล็ดด้วยอินไลน์ Active Job adapter
    ([Pull Request](https://github.com/rails/r
### การเลิกใช้งาน

* ไม่มีการเลิกใช้งานสำหรับ Action Cable ใน Rails 6.0

### การเปลี่ยนแปลงที่สำคัญ

* เพิ่มการสนับสนุนตัวเลือก `channel_prefix` สำหรับอะแดปเตอร์การสมัครสมาชิก PostgreSQL ใน `cable.yml` 
    ([Pull Request](https://github.com/rails/rails/pull/35276))

* อนุญาตให้ส่งค่าการกำหนดค่าที่กำหนดเองไปยัง `ActionCable::Server::Base`
    ([Pull Request](https://github.com/rails/rails/pull/34714))

* เพิ่ม `:action_cable_connection` และ `:action_cable_channel` load hooks
    ([Pull Request](https://github.com/rails/rails/pull/35094))

* เพิ่ม `Channel::Base#broadcast_to` และ `Channel::Base.broadcasting_for`
    ([Pull Request](https://github.com/rails/rails/pull/35021))

* ปิดการเชื่อมต่อเมื่อเรียกใช้ `reject_unauthorized_connection` จาก `ActionCable::Connection`
    ([Pull Request](https://github.com/rails/rails/pull/34194))

* แปลงแพ็คเกจ Action Cable จาก CoffeeScript เป็น ES2015 และเผยแพร่รหัสต้นฉบับในการกระจาย npm
    ([Pull Request](https://github.com/rails/rails/pull/34370))

* ย้ายการกำหนดค่าของอะแดปเตอร์ WebSocket และอะแดปเตอร์ logger จากคุณสมบัติของ `ActionCable` เป็น `ActionCable.adapters`
    ([Pull Request](https://github.com/rails/rails/pull/34370))

* เพิ่มตัวเลือก `id` ให้กับอะแดปเตอร์ Redis เพื่อแยกการเชื่อมต่อ Redis ของ Action Cable
    ([Pull Request](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

โปรดอ้างอิงที่ [Changelog][action-pack] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

* เอา `fragment_cache_key` helper ที่ถูกเลิกใช้งานออกและใช้ `combined_fragment_cache_key` แทน
    ([Commit](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

* เอาเมธอดที่ถูกเลิกใช้งานใน `ActionDispatch::TestResponse` ออก:
    `#success?` แทนด้วย `#successful?`, `#missing?` แทนด้วย `#not_found?`,
    `#error?` แทนด้วย `#server_error?`
    ([Commit](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### การเลิกใช้งาน

* เลิกใช้งาน `ActionDispatch::Http::ParameterFilter` และใช้ `ActiveSupport::ParameterFilter` แทน
    ([Pull Request](https://github.com/rails/rails/pull/34039))

* เลิกใช้งาน `force_ssl` ระดับคอนโทรลเลอร์และใช้ `config.force_ssl` แทน
    ([Pull Request](https://github.com/rails/rails/pull/32277))

### การเปลี่ยนแปลงที่สำคัญ

* เปลี่ยน `ActionDispatch::Response#content_type` ให้ส่งค่าเฮดเดอร์ Content-Type ได้เลย
    ([Pull Request](https://github.com/rails/rails/pull/36034))

* สร้าง `ArgumentError` หากพารามิเตอร์ของทรัพยากรมีเครื่องหมายโคลอน
    ([Pull Request](https://github.com/rails/rails/pull/35236))

* อนุญาตให้ `ActionDispatch::SystemTestCase.driven_by` ถูกเรียกด้วยบล็อกเพื่อกำหนดความสามารถของเบราว์เซอร์เฉพาะ
    ([Pull Request](https://github.com/rails/rails/pull/35081))

* เพิ่ม middleware `ActionDispatch::HostAuthorization` เพื่อป้องกันการโจมตี DNS rebinding
    ([Pull Request](https://github.com/rails/rails/pull/33145))

* อนุญาตให้ใช้ `parsed_body` ใน `ActionController::TestCase`
    ([Pull Request](https://github.com/rails/rails/pull/34717))

* สร้าง `ArgumentError` เมื่อมีเส้นทางรูทหลายเส้นในบริบทเดียวโดยไม่มีการระบุชื่อ `as:`
    ([Pull Request](https://github.com/rails/rails/pull/34494))

* อนุญาตให้ใช้ `#rescue_from` ในการจัดการข้อผิดพลาดของการแยกวิเคราะห์พารามิเตอร์
    ([Pull Request](https://github.com/rails/rails/pull/34341))

* เพิ่ม `ActionController::Parameters#each_value` เพื่อวนลูปผ่านพารามิเตอร์
    ([Pull Request](https://github.com/rails/rails/pull/33979))

* เข้ารหัสชื่อไฟล์ Content-Disposition ใน `send_data` และ `send_file`
    ([Pull Request](https://github.com/rails/rails/pull/33829))

* เปิดเผย `ActionController::Parameters#each_key`
    ([Pull Request](https://github.com/rails/rails/pull/33758))

* เพิ่มข้อมูลเพื่อวัตถุประสงค์และการหมดอายุในคุกกี้ที่เข้ารหัสลับเพื่อป้องกันการคัดลอกค่าของคุกกี้ไปยังคุกกี้อื่น
    ([Pull Request](https://github.com/rails/rails/pull/32937))

* สร้าง `ActionController::RespondToMismatchError` สำหรับการเรียกใช้ `respond_to` ที่ขัดแย้งกัน
    ([Pull Request](https://github.com/rails/rails/pull/33446))

* เพิ่มหน้าข้อผิดพลาดเฉพาะสำหรับเมื่อไม่พบเทมเพลตสำหรับรูปแบบคำขอ
    ([Pull Request](https://github.com/rails/rails/pull/29286))

* นำเข้า `ActionDispatch::DebugExceptions.register_interceptor` เป็นวิธีการเชื่อมต่อกับ DebugExceptions และประมวลผลข้อผิดพลาดก่อนที่จะถูกแสดง
    ([Pull Request](https://github.com/rails/rails/pull/23868))

* แสดงเฉพาะหนึ่งค่าของเฮดเดอร์ Content-Security-Policy nonce ต่อคำขอ
    ([Pull Request](https://github.com/rails/rails/pull/32602))

* เพิ่มโมดูลที่เฉพาะเจาะจงสำหร
*   เพิ่มตัวเลือกการกำหนดค่า `action_controller.default_enforce_utf8` เพื่อใช้ในการบังคับให้ใช้รหัส UTF-8 โดยค่าเริ่มต้นคือ `false` 
    ([Pull Request](https://github.com/rails/rails/pull/32125))

*   เพิ่มการสนับสนุนรูปแบบคีย์ I18n สำหรับคีย์ภาษาในแท็ก submit
    ([Pull Request](https://github.com/rails/rails/pull/26799))

Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog][action-mailer] สำหรับรายละเอียดการเปลี่ยนแปลง

### การลบ

### การเลิกใช้

*   เลิกใช้ `ActionMailer::Base.receive` และใช้ Action Mailbox แทน
    ([Commit](https://github.com/rails/rails/commit/e3f832a7433a291a51c5df397dc3dd654c1858cb))

*   เลิกใช้ `DeliveryJob` และ `Parameterized::DeliveryJob` และใช้ `MailDeliveryJob` แทน
    ([Pull Request](https://github.com/rails/rails/pull/34591))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม `MailDeliveryJob` เพื่อใช้ในการส่งอีเมลทั้งแบบธรรมดาและแบบพารามิเตอร์
    ([Pull Request](https://github.com/rails/rails/pull/34591))

*   อนุญาตให้งานส่งอีเมลที่กำหนดเองสามารถทำงานร่วมกับการตรวจสอบข้อกำหนดของการทดสอบ Action Mailer
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   อนุญาตให้ระบุชื่อเทมเพลตสำหรับอีเมลแบบหลายส่วนด้วยบล็อกแทนการใช้ชื่อแอ็กชันเท่านั้น
    ([Pull Request](https://github.com/rails/rails/pull/22534))

*   เพิ่ม `perform_deliveries` ในเปลี่ยนแปลงของการแจ้งเตือน `deliver.action_mailer`
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   ปรับปรุงข้อความบันทึกเมื่อ `perform_deliveries` เป็นเท็จเพื่อแสดงว่าการส่งอีเมลถูกข้ามไป
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   อนุญาตให้เรียกใช้ `assert_enqueued_email_with` โดยไม่ต้องใช้บล็อก
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   ดำเนินการงานส่งอีเมลที่อยู่ในคิวในบล็อก `assert_emails`
    ([Pull Request](https://github.com/rails/rails/pull/32231))

*   อนุญาตให้ `ActionMailer::Base` ยกเลิกการลงทะเบียนตัวสังเกตการณ์และตัวกระทำกลาง
    ([Pull Request](https://github.com/rails/rails/pull/32207))

Active Record
-------------

โปรดอ้างอิงที่ [Changelog][active-record] สำหรับรายละเอียดการเปลี่ยนแปลง

### การลบ

*   ลบ `#set_state` ที่ถูกเลิกใช้จากออบเจกต์การทำธุรกรรม
    ([Commit](https://github.com/rails/rails/commit/6c745b0c5152a4437163a67707e02f4464493983))

*   ลบ `#supports_statement_cache?` ที่ถูกเลิกใช้จากอะแดปเตอร์ฐานข้อมูล
    ([Commit](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553))

*   ลบ `#insert_fixtures` ที่ถูกเลิกใช้จากอะแดปเตอร์ฐานข้อมูล
    ([Commit](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece))

*   ลบ `ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?` ที่ถูกเลิกใช้
    ([Commit](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf))

*   ลบการสนับสนุนในการส่งชื่อคอลัมน์ไปยัง `sum` เมื่อมีการส่งบล็อก
    ([Commit](https://github.com/rails/rails/commit/91ddb30083430622188d76eb9f29b78131df67f9))

*   ลบการสนับสนุนในการส่งชื่อคอลัมน์ไปยัง `count` เมื่อมีการส่งบล็อก
    ([Commit](https://github.com/rails/rails/commit/67356f2034ab41305af7218f7c8b2fee2d614129))

*   ลบการสนับสนุนในการส่งเมธอดที่หายไปในความสัมพันธ์ไปยัง Arel
    ([Commit](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0))

*   ลบการสนับสนุนในการส่งเมธอดที่หายไปในความสัมพันธ์ไปยังเมธอดส่วนตัวของคลาส
    ([Commit](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d))

*   ลบการสนับสนุนในการระบุชื่อแทมป์ส
*   อนุญาตให้ `ActionController::Parameters` ที่ได้รับอนุญาตผ่านเป็นอาร์กิวเมนต์ใน `ActiveRecord::Relation#exists?` 
    ([Pull Request](https://github.com/rails/rails/pull/34891))

*   เพิ่มการสนับสนุนใน `#where` สำหรับช่วงที่ไม่มีที่สิ้นสุดที่เพิ่มเข้ามาใน Ruby 2.6 
    ([Pull Request](https://github.com/rails/rails/pull/34906))

*   ทำให้ `ROW_FORMAT=DYNAMIC` เป็นตัวเลือกการสร้างตารางเริ่มต้นสำหรับ MySQL 
    ([Pull Request](https://github.com/rails/rails/pull/34742))

*   เพิ่มความสามารถในการปิดการใช้งานของ scopes ที่ถูกสร้างขึ้นโดย `ActiveRecord.enum` 
    ([Pull Request](https://github.com/rails/rails/pull/34605))

*   ทำให้การเรียงลำดับแบบไม่ชัดเจนสามารถกำหนดค่าได้สำหรับคอลัมน์ 
    ([Pull Request](https://github.com/rails/rails/pull/34480))

*   เพิ่มรุ่นขั้นต่ำของ PostgreSQL เป็นเวอร์ชัน 9.3 โดยลดการสนับสนุนสำหรับเวอร์ชัน 9.1 และ 9.2 
    ([Pull Request](https://github.com/rails/rails/pull/34520))

*   ทำให้ค่าของ enum เป็นค่าที่ถูกแช่แข็ง และเกิดข้อผิดพลาดเมื่อพยายามแก้ไขค่าเหล่านั้น 
    ([Pull Request](https://github.com/rails/rails/pull/34517))

*   ทำให้ SQL ของข้อผิดพลาด `ActiveRecord::StatementInvalid` เป็นคุณสมบัติของข้อผิดพลาดที่แยกต่างหากและรวม SQL binds เป็นคุณสมบัติข้อผิดพลาดที่แยกต่างหาก 
    ([Pull Request](https://github.com/rails/rails/pull/34468))

*   เพิ่มตัวเลือก `:if_not_exists` ใน `create_table` 
    ([Pull Request](https://github.com/rails/rails/pull/31382))

*   เพิ่มการสนับสนุนฐานข้อมูลหลายรายการใน `rails db:schema:cache:dump` และ `rails db:schema:cache:clear` 
    ([Pull Request](https://github.com/rails/rails/pull/34181))

*   เพิ่มการสนับสนุนการกำหนดค่าแบบ hash และ url ในฐานข้อมูลของ `ActiveRecord::Base.connected_to` 
    ([Pull Request](https://github.com/rails/rails/pull/34196))

*   เพิ่มการสนับสนุนสูตรเริ่มต้นและดัชนีสูตรสำหรับ MySQL 
    ([Pull Request](https://github.com/rails/rails/pull/34307))

*   เพิ่มตัวเลือก `index` สำหรับช่วยในการเปลี่ยนตาราง 
    ([Pull Request](https://github.com/rails/rails/pull/23593))

*   แก้ไขการย้อนกลับของ `transaction` สำหรับการเรียกใช้งาน ก่อนหน้านี้ คำสั่งภายใน `transaction` ในการย้อนกลับของการเรียกใช้งานทำงานโดยไม่ถูกย้อนกลับ การเปลี่ยนแปลงนี้จะแก้ไขปัญหานั้น 
    ([Pull Request](https://github.com/rails/rails/pull/31604))

*   อนุญาตให้ `ActiveRecord::Base.configurations=` สามารถตั้งค่าด้วย hash ที่มีสัญลักษณ์เป็นตัวแปร 
    ([Pull Request](https://github.com/rails/rails/pull/33968))

*   แก้ไขการนับจำนวนครั้งที่อัปเดต counter เพื่อให้อัปเดตเฉพาะเมื่อบันทึกเรียบร้อยแล้วเท่านั้น 
    ([Pull Request](https://github.com/rails/rails/pull/33913))

*   เพิ่มการสนับสนุนดัชนีแบบนิพจน์สำหรับ SQLite adapter 
    ([Pull Request](https://github.com/rails/rails/pull/33874))

*   อนุญาตให้คลาสย่อยสร้าง callback การบันทึกอัตโนมัติใหม่สำหรับบันทึกที่เกี่ยวข้อง 
    ([Pull Request](https://github.com/rails/rails/pull/33378))

*   เพิ่มรุ่นขั้นต่ำของ MySQL เป็นเวอร์ชัน 5.5.8 
    ([Pull Request](https://github.com/rails/rails/pull/33853))

*   ใช้ชุดตัวอักษร utf8mb4 เป็นค่าเริ่มต้นใน MySQL 
    ([Pull Request](https://github.com/rails/rails/pull/33608))

*   เพิ่มความสามารถในการกรองข้อมูลที่เป็นข้อมูลที่ละเอียดอ่อนใน `#inspect` 
    ([Pull Request](https://github.com/rails/rails/pull/33756), [Pull Request](https://github.com/rails/rails/pull/34208))

*   เปลี่ยน `ActiveRecord::Base.configurations` เพื่อให้ส่งคืนออบเจกต์แทนที่เป็นแฮช 
    ([Pull Request](https://github.com/rails/rails/pull/33637))

*   เพิ่มการกำหนดค่าฐานข้อมูลเพื่อปิดการใช้งาน advisory locks 
    ([Pull Request](https://github.com/rails/rails/pull/33691))

*   อัปเดตวิธีการแก้ไข `alter_table` ของ SQLite3 adapter เพื่อเรียกคืน foreign keys 
    ([Pull Request](https://github.com/rails/rails/pull/33585))

*   อนุญาตให้ตัวเลือก `:to_table` ของ `remove_foreign_key` เป็นค่าที่สามารถกลับได้ 
    ([Pull Request](https://github.com/rails/rails/pull/33530))

*   แก้ไขค่าเริ่มต้นสำหรับชนิดเวลาของ MySQL ที่ระบุความแม่นยำ 
    ([Pull Request](https://github.com/rails/rails/pull/33280))

*   แก้ไขตัวเลือก `touch` เพื่อทำงานอย่างสอดคล้องกับเมธอด `Persistence#touch` 
    ([Pull Request](https://github.com/rails/rails/pull/33107))

*   สร้างข้อยกเว้นสำหรับการกำหนดคอลัมน์ซ้ำใน Migrations 

* เพิ่ม `ActiveStorage::FileNotFoundError` เมื่อไฟล์ที่ร้องขอหายไปสำหรับ `ActiveStorage::Blob#download` และ `ActiveStorage::Blob#open` ([Pull Request](https://github.com/rails/rails/pull/33666))
* เพิ่มคลาส `ActiveStorage::Error` ที่เป็นคลาสทั่วไปที่ข้อยกเว้นของ Active Storage สืบทอดมาจาก ([Commit](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))
* บันทึกไฟล์ที่อัปโหลดที่กำหนดให้กับบันทึกไว้ในการเก็บรักษาเมื่อบันทึกบันทึกแทนที่ทันที ([Pull Request](https://github.com/rails/rails/pull/33303))
* ตัวเลือกที่เพิ่มเข้ามาในการแทนที่ไฟล์ที่มีอยู่แทนที่การเพิ่มไฟล์เมื่อกำหนดให้กับคอลเลกชันของการแนบ (เช่น `@user.update!(images: [ … ])`) ใช้ `config.active_storage.replace_on_assign_to_many` เพื่อควบคุมพฤติกรรมนี้ ([Pull Request](https://github.com/rails/rails/pull/33303), [Pull Request](https://github.com/rails/rails/pull/36716))
* เพิ่มความสามารถในการสะท้อนกลับไปที่การแนบที่กำหนดไว้โดยใช้กลไกการสะท้อนของ Active Record ที่มีอยู่ ([Pull Request](https://github.com/rails/rails/pull/33018))
* เพิ่ม `ActiveStorage::Blob#open` ซึ่งดาวน์โหลด blob ไปยัง tempfile บนดิสก์และให้ tempfile  ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))
* สนับสนุนการดาวน์โหลดแบบสตรีมจาก Google Cloud Storage ต้องใช้เวอร์ชัน 1.11+ ของ `google-cloud-storage` gem ([Pull Request](https://github.com/rails/rails/pull/32788))
* ใช้ `image_processing` gem สำหรับตัวแปร Active Storage แทนการใช้ `mini_magick` โดยตรง ([Pull Request](https://github.com/rails/rails/pull/32471))

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

* เพิ่มตัวเลือกการกำหนดรูปแบบของ `ActiveModel::Errors#full_message` ([Pull Request](https://github.com/rails/rails/pull/32956))
* เพิ่มการสนับสนุนในการกำหนดค่าชื่อแอตทริบิวต์สำหรับ `has_secure_password` ([Pull Request](https://github.com/rails/rails/pull/26764))
* เพิ่มเมธอด `#slice!` ใน `ActiveModel::Errors` ([Pull Request](https://github.com/rails/rails/pull/34489))
* เพิ่ม `ActiveModel::Errors#of_kind?` เพื่อตรวจสอบความเป็นมาของข้อผิดพลาดที่เฉพาะเจาะจง ([Pull Request](https://github.com/rails/rails/pull/34866))
* แก้ไขเมธอด `ActiveModel::Serializers::JSON#as_json` สำหรับ timestamp ([Pull Request](https://github.com/rails/rails/pull/31503))
* แก้ไขตัวตรวจสอบ numericality เพื่อใช้ค่าก่อนการแปลงชนิดยกเว้น Active Record ([Pull Request](https://github.com/rails/rails/pull/33654))
* แก้ไขการตรวจสอบความเท่ากันของ numericality ของ `BigDecimal` และ `Float` โดยแปลงเป็น `BigDecimal` ทั้งสองด้านของการตรวจสอบ ([Pull Request](https://github.com/rails/rails/pull/32852))
* แก้ไขค่าปีเมื่อแปลง multiparameter time hash ([Pull Request](https://github.com/rails/rails/pull/34990))
* แปลงค่า boolean symbols เท็จเป็น false ในแอตทริบิวต์ boolean ([Pull Request](https://github.com/rails/rails/pull/35794))
* คืนค่าวันที่ที่ถูกต้องในขณะแปลงพารามิเตอร์ใน `value_from_multiparameter_assignment` สำหรับ `ActiveModel::Type::Date` ([Pull Request](https://github.com/rails/rails/pull/29651))
* ย้อนกลับไปที่ locale หลักก่อนที่จะย้อนกลับไปที่ `:errors` namespace ขณะดึงข้อผิดพลาดแปลง ([Pull Request](https://github.com/rails/rails/pull/35424))

Active Support
--------------

โปรดอ้างอิงที่ [Changelog][active-support] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

* ลบเมธอด `#acronym_regex` ที่ถูกเลิกใช้จาก `Inflections` ([Commit](https://github.com/rails/rails/commit/0ce67d3cd6d1b7b9576b07fecae3dd5b422a5689))
* ลบเมธอด `Module#reachable?` ที่ถูกเลิกใช้ ([Commit](https://github.com/rails/rails/commit/6eb1d56a333fd2015610d31793ed6281acd66551))
* ลบ `` Kernel#` `` โดยไม่มีการแทนที่ใด ๆ ([Pull Request](https://github.com/rails/rails/pull/31253))

### การเลิกใช้

* เลิกใช้การใช้พารามิเตอร์เชิงลบสำหรับ `String#first` และ `String#last` ([Pull Request](https://github.com/rails/rails/pull/33058))
* เลิกใช้ `ActiveSupport::Multibyte::Unicode#downcase/upcase/swapcase` และใช้ `String#downcase/upcase/swapcase` แทน ([Pull Request](https://github.com/rails/rails/pull/34123))
* เลิกใช้ `ActiveSupport::Multibyte::Unicode#normalize` และ `ActiveSupport::Multibyte::Chars#normalize` และใช้ `String#unicode_normalize` แทน ([Pull Request](https://github.com/rails/rails/pull/34202))
* เลิกใช้ `ActiveSupport::Multibyte::Chars.consumes?` และใช้ `String#is_utf8?` แทน ([Pull Request](https://github.com/rails/rails/pull/34215))
* เลิกใช้ `ActiveSupport::Multibyte::Unicode#pack_graphemes(array)` และ `ActiveSupport::Mult
* เพิ่มคุณสมบัติเวลา CPU, เวลาไม่ทำงาน และการจัดสรรให้กับการบันทึกเหตุการณ์ผู้สมัครสมาชิก
    ([Pull Request](https://github.com/rails/rails/pull/33449))

* เพิ่มการสนับสนุนสำหรับวัตถุเหตุการณ์ในระบบการแจ้งเตือน Active Support
    ([Pull Request](https://github.com/rails/rails/pull/33451))

* เพิ่มการสนับสนุนให้ไม่เก็บแคชรายการ `nil` โดยการเพิ่มตัวเลือกใหม่ `skip_nil` สำหรับ `ActiveSupport::Cache#fetch`
    ([Pull Request](https://github.com/rails/rails/pull/25437))

* เพิ่มเมธอด `Array#extract!` ซึ่งจะลบและส่งคืนองค์ประกอบที่ฟังก์ชันส่งคืนค่าเป็นจริง
    ([Pull Request](https://github.com/rails/rails/pull/33137))

* รักษาสตริงที่ปลอดภัยสำหรับ HTML หลังจากที่ทำการตัด
    ([Pull Request](https://github.com/rails/rails/pull/33808))

* เพิ่มการสนับสนุนให้ติดตามการโหลดอัตโนมัติคงที่ผ่านการบันทึก
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

* กำหนด `unfreeze_time` เป็นชื่อย่อของ `travel_back`
    ([Pull Request](https://github.com/rails/rails/pull/33813))

* เปลี่ยน `ActiveSupport::TaggedLogging.new` เพื่อให้ส่งคืนตัวอย่างเครื่องมือเขียนบันทึกใหม่แทนที่จะเปลี่ยนแปลงตัวอย่างที่ได้รับเป็นอาร์กิวเมนต์
    ([Pull Request](https://github.com/rails/rails/pull/27792))

* จัดการ `#delete_prefix`, `#delete_suffix` และ `#unicode_normalize` เป็นเมธอดที่ไม่ปลอดภัยสำหรับ HTML
    ([Pull Request](https://github.com/rails/rails/pull/33990))

* แก้ไขข้อบกพร่องที่ `#without` สำหรับ `ActiveSupport::HashWithIndifferentAccess` จะล้มเหลวเมื่อมีอาร์กิวเมนต์เป็นสัญลักษณ์
    ([Pull Request](https://github.com/rails/rails/pull/34012))

* เปลี่ยนชื่อ `Module#parent`, `Module#parents`, และ `Module#parent_name` เป็น `module_parent`, `module_parents`, และ `module_parent_name`
    ([Pull Request](https://github.com/rails/rails/pull/34051))

* เพิ่ม `ActiveSupport::ParameterFilter`
    ([Pull Request](https://github.com/rails/rails/pull/34039))

* แก้ไขปัญหาที่ระยะเวลาถูกปัดเป็นวินาทีเต็มเมื่อมีจำนวนทศนิยมถูกเพิ่มเข้าไปในระยะเวลา
    ([Pull Request](https://github.com/rails/rails/pull/34135))

* ทำให้ `#to_options` เป็นชื่อย่อของ `#symbolize_keys` ใน `ActiveSupport::HashWithIndifferentAccess`
    ([Pull Request](https://github.com/rails/rails/pull/34360))

* ไม่เรียกใช้ข้อยกเว้นอีกต่อไปหากบล็อกเดียวกันถูกรวมอยู่หลายครั้งสำหรับ Concern
    ([Pull Request](https://github.com/rails/rails/pull/34553))

* รักษาลำดับคีย์ที่ถูกส่งผ่านไปยัง `ActiveSupport::CacheStore#fetch_multi`
    ([Pull Request](https://github.com/rails/rails/pull/34700))

* แก้ไข `String#safe_constantize` เพื่อไม่สร้างข้อผิดพลาด `LoadError` สำหรับการอ้างอิงค่าคงที่ที่เขียนผิดตัวอักษร
    ([Pull Request](https://github.com/rails/rails/pull/34892))

* เพิ่ม `Hash#deep_transform_values` และ `Hash#deep_transform_values!`
    ([Commit](https://github.com/rails/rails/commit/b8dc06b8fdc16874160f61dcf58743fcc10e57db))

* เพิ่ม `ActiveSupport::HashWithIndifferentAccess#assoc`
    ([Pull Request](https://github.com/rails/rails/pull/35080))

* เพิ่ม `before_reset` callback ให้กับ `CurrentAttributes` และกำหนด `after_reset` เป็นชื่อย่อของ `resets` เพื่อความสมมาตร
    ([Pull Request](https://github.com/rails/rails/pull/35063))

* ปรับปรุง `ActiveSupport::Notifications.unsubscribe` เพื่อจัดการกับ Regex หรือผู้สมัครที่มีรูปแบบหลายรูปแบบอื่น ๆ ได้ถูกต้อง
    ([Pull Request](https://github.com/rails/rails/pull/32861))

* เพิ่มกลไกการโหลดอัตโนมัติใหม่โดยใช้ Zeitwerk
    ([Commit](https://github.com/rails/rails/commit/e53430fa9af239e21e11548499d814f540d421e5))

* เพิ่ม `Array#including` และ `Enumerable#including` เพื่อขยายคอลเลกชันได้อย่างสะดวก
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

* เปลี่ยนชื่อ `Array#without` และ `Enumerable#without` เป็น `Array#excluding` และ `Enumerable#excluding` ชื่อเดิมของเมธอดถูกเก็บไว้เป็นชื่อย่อ
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

* เพิ่มการสนับสนุนให้สามารถระบุ `locale` ให้กับ `transliterate` และ `parameterize`
    ([Pull Request](https://github.com/rails/rails/pull/35571))

* แก้ไข `Time#advance` เพื่อให้ทำงานกับวันที่ก่อน 1001-03-07
    ([Pull Request](https://github.com/rails/rails/pull/35659))

* อัปเดต `ActiveSupport::Notifications::Instrumenter#instrument` เพื่ออนุญาตให้ไม่ต้องส่งบล็อก
    ([Pull Request](https://github.com/rails/rails/pull/35705
*   เพิ่มส่วนเกี่ยวกับการแก้ปัญหาในการโหลดค่าคงที่อัตโนมัติ
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   เพิ่มเอกสารเบื้องต้นเกี่ยวกับ Action Mailbox
    ([Pull Request](https://github.com/rails/rails/pull/34812))

*   เพิ่มเอกสารภาพรวมเกี่ยวกับ Action Text
    ([Pull Request](https://github.com/rails/rails/pull/34878))

เครดิต
-------

ดูรายชื่อเต็มของผู้มีส่วนร่วมใน Rails ได้ที่
[รายชื่อผู้มีส่วนร่วมใน Rails](https://contributors.rubyonrails.org/)
สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและทนทาน ยินดีด้วยทุกคน.

[railties]:       https://github.com/rails/rails/blob/6-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-0-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-0-stable/activesupport/CHANGELOG.md
