**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b1c2c8ad5c4bacb2e3b92aa320c4da3d

เรื่องเด่นใน Rails 6.0:
============

* Action Mailbox
* Action Text
* Parallel Testing
* Action Cable Testing

เอกสารเวอร์ชันนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่าง ๆ โปรดอ้างอิงที่เอกสารเปลี่ยนแปลงหรือตรวจสอบ [รายการของการเปลี่ยนแปลง](https://github.com/rails/rails/commits/6-0-stable) ในเก็บข้อมูลหลักของ Rails ใน GitHub

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
คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับ Action Mailbox ในคู่มือ [Action Mailbox Basics](action_mailbox_basics.html)

### Action Text

[Pull Request](https://github.com/rails/rails/pull/34873)

[Action Text](https://github.com/rails/rails/tree/6-0-stable/actiontext)
นำเนื้อหาและการแก้ไขข้อความที่มีรูปแบบสู่ Rails มาให้ มันรวม
[ตัวแก้ไข Trix](https://trix-editor.org) ที่จัดการทุกอย่างตั้งแต่การจัดรูปแบบ
ไปยังการเชื่อมโยงไปยังการอ้างอิงไปยังรายการไปยังรูปภาพและแกลเลอรี่ที่ฝังอยู่
เนื้อหาข้อความที่มีรูปแบบที่สร้างขึ้นโดยตัวแก้ไข Trix จะถูกบันทึกในตัวของตัวเอง
โมเดล RichText ที่เชื่อมโยงกับแอปพลิเคชัน Active Record ที่มีอยู่
รูปภาพที่ฝังอยู่ (หรือไฟล์แนบอื่น ๆ) จะถูกเก็บอัตโนมัติโดยใช้
Active Storage และเชื่อมโยงกับตัวแก้ไข RichText ที่รวมอยู่

คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับ Action Text ในคู่มือ [Action Text Overview](action_text_overview.html)

### Parallel Testing

[Pull Request](https://github.com/rails/rails/pull/31900)

[การทดสอบแบบขนาน](testing.html#parallel-testing) ช่วยให้คุณสามารถทดสอบแบบขนานได้
ชุดทดสอบของคุณ ในขณะที่การสร้างกระบวนการคือวิธีเริ่มต้น การใช้เธรดเป็นวิธีที่สนับสนุนด้วย การเรียกใช้การทดสอบแบบขนานลดเวลาที่ใช้
ชุดทดสอบทั้งหมดของคุณในการทดสอบ

### Action Cable Testing
[Pull Request](https://github.com/rails/rails/pull/33659)

เครื่องมือทดสอบ Action Cable
--------

เครื่องมือทดสอบ [Action Cable](testing.html#testing-action-cable) ช่วยให้คุณสามารถทดสอบฟังก์ชัน Action Cable ของคุณได้ที่ระดับใดก็ได้: การเชื่อมต่อ (connections), ช่อง (channels), การกระจาย (broadcasts).

Railties
--------

โปรดอ้างอิงที่ [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด.

### การลบ

*   ลบ `after_bundle` helper ที่ถูกเลิกใช้ภายในเทมเพลตของปลั๊กอิน
    ([Commit](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

*   ลบการสนับสนุนที่ถูกเลิกใช้สำหรับ `config.ru` ที่ใช้คลาสแอปพลิเคชันเป็นอาร์กิวเมนต์ของ `run`
    ([Commit](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))

*   ลบอาร์กิวเมนต์ `environment` ที่ถูกเลิกใช้จากคำสั่ง rails
    ([Commit](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

*   ลบเมธอด `capify!` ที่ถูกเลิกใช้ใน generators และเทมเพลต
    ([Commit](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

*   ลบ `config.secret_token` ที่ถูกเลิกใช้
    ([Commit](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### การเลิกใช้

*   เลิกใช้การส่งชื่อเซิร์ฟเวอร์ Rack เป็นอาร์กิวเมนต์ปกติให้กับ `rails server`
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   เลิกใช้การสนับสนุนในการใช้ `HOST` environment เพื่อระบุ IP เซิร์ฟเวอร์
    ([Pull Request](https://github.com/rails/rails/pull/32540))

*   เลิกใช้การเข้าถึง hashes ที่ส่งกลับจาก `config_for` ด้วยคีย์ที่ไม่ใช่สัญลักษณ์
    ([Pull Request](https://github.com/rails/rails/pull/35198))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มตัวเลือกชื่อ `--using` หรือ `-u` เพื่อระบุเซิร์ฟเวอร์สำหรับคำสั่ง `rails server`
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   เพิ่มความสามารถในการดูผลลัพธ์ของ `rails routes` ในรูปแบบที่ขยายออก
    ([Pull Request](https://github.com/rails/rails/pull/32130))

*   รันงานฐานข้อมูล seed โดยใช้ inline Active Job adapter
    ([Pull Request](https://github.com/rails/rails/pull/34953))

*   เพิ่มคำสั่ง `rails db:system:change` เพื่อเปลี่ยนฐานข้อมูลของแอปพลิเคชัน
    ([Pull Request](https://github.com/rails/rails/pull/34832))

*   เพิ่มคำสั่ง `rails test:channels` เพื่อทดสอบเฉพาะช่อง Action Cable เท่านั้น
    ([Pull Request](https://github.com/rails/rails/pull/34947))

*   นำเสนอการป้องกันการโจมตี DNS rebinding
    ([Pull Request](https://github.com/rails/rails/pull/33145))

*   เพิ่มความสามารถในการยกเลิกเมื่อเกิดข้อผิดพลาดในขณะที่รันคำสั่ง generator
    ([Pull Request](https://github.com/rails/rails/pull/34420))

*   ทำให้ Webpacker เป็นคอมไพเลอร์ JavaScript เริ่มต้นสำหรับ Rails 6
    ([Pull Request](https://github.com/rails/rails/pull/33079))

*   เพิ่มการสนับสนุนฐานข้อมูลหลายระบบสำหรับคำสั่ง `rails db:migrate:status`
    ([Pull Request](https://github.com/rails/rails/pull/34137))

*   เพิ่มความสามารถในการใช้เส้นทางการโยกย้ายที่แตกต่างกันจากฐานข้อมูลหลายระบบใน generators
    ([Pull Request](https://github.com/rails/rails/pull/34021))

*   เพิ่มการสนับสนุนสำหรับข้อมูลรับรองแบบหลายสภาพแวดล้อม
    ([Pull Request](https://github.com/rails/rails/pull/33521))

*   กำหนด `null_store` เป็นค่าเริ่มต้นของร้านค้าแคชในสภาพแวดล้อมการทดสอบ
    ([Pull Request](https://github.com/rails/rails/pull/33773))

Action Cable
------------

โปรดอ้างอิงที่ [Changelog][action-cable] สำหรับการเปลี่ยนแปลงที่ละเอียด.

### การลบ

*   แทนที่ `ActionCable.startDebugging()` และ `ActionCable.stopDebugging()` ด้วย `ActionCable.logger.enabled`
    ([Pull Request](https://github.com/rails/rails/pull/34370))
### การเลิกใช้งาน

* ไม่มีการเลิกใช้งานสำหรับ Action Cable ใน Rails 6.0

### การเปลี่ยนแปลงที่สำคัญ

* เพิ่มการสนับสนุนตัวเลือก `channel_prefix` สำหรับ PostgreSQL subscription adapters ใน `cable.yml`
    ([Pull Request](https://github.com/rails/rails/pull/35276))

* อนุญาตให้ส่งค่าการกำหนดค่าที่กำหนดเองไปยัง `ActionCable::Server::Base`
    ([Pull Request](https://github.com/rails/rails/pull/34714))

* เพิ่ม `:action_cable_connection` และ `:action_cable_channel` load hooks
    ([Pull Request](https://github.com/rails/rails/pull/35094))

* เพิ่ม `Channel::Base#broadcast_to` และ `Channel::Base.broadcasting_for`
    ([Pull Request](https://github.com/rails/rails/pull/35021))

* ปิดการเชื่อมต่อเมื่อเรียกใช้ `reject_unauthorized_connection` จาก `ActionCable::Connection`
    ([Pull Request](https://github.com/rails/rails/pull/34194))

* แปลงแพ็คเกจ Action Cable JavaScript จาก CoffeeScript เป็น ES2015 และเผยแพร่รหัสต้นฉบับในการกระจายของ npm
    ([Pull Request](https://github.com/rails/rails/pull/34370))

* ย้ายการกำหนดค่าของ WebSocket adapter และ logger adapter จากคุณสมบัติของ `ActionCable` เป็น `ActionCable.adapters`
    ([Pull Request](https://github.com/rails/rails/pull/34370))

* เพิ่มตัวเลือก `id` ให้กับ Redis adapter เพื่อแยกการเชื่อมต่อ Redis ของ Action Cable
    ([Pull Request](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

โปรดอ้างอิงที่ [Changelog][action-pack] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

* เอา `fragment_cache_key` helper ที่เลิกใช้งานออกและใช้ `combined_fragment_cache_key` แทน
    ([Commit](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

* เอาเมธอดที่เลิกใช้งานใน `ActionDispatch::TestResponse` ออก:
    `#success?` แทนด้วย `#successful?`, `#missing?` แทนด้วย `#not_found?`,
    `#error?` แทนด้วย `#server_error?`
    ([Commit](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### การเลิกใช้งาน

* เลิกใช้งาน `ActionDispatch::Http::ParameterFilter` และใช้ `ActiveSupport::ParameterFilter` แทน
    ([Pull Request](https://github.com/rails/rails/pull/34039))

* เลิกใช้งาน `force_ssl` ระดับคอนโทรลเลอร์และใช้ `config.force_ssl` แทน
    ([Pull Request](https://github.com/rails/rails/pull/32277))

### การเปลี่ยนแปลงที่สำคัญ

* เปลี่ยน `ActionDispatch::Response#content_type` ให้ส่งค่าเฮดเดอร์ Content-Type ตามที่กำหนด
    ([Pull Request](https://github.com/rails/rails/pull/36034))

* สร้าง `ArgumentError` หากพารามิเตอร์ของทรัพยากรมีเครื่องหมายโคลอน
    ([Pull Request](https://github.com/rails/rails/pull/35236))

* อนุญาตให้เรียกใช้ `ActionDispatch::SystemTestCase.driven_by` พร้อมกับบล็อกเพื่อกำหนดความสามารถของเบราว์เซอร์เฉพาะ
    ([Pull Request](https://github.com/rails/rails/pull/35081))

* เพิ่ม middleware `ActionDispatch::HostAuthorization` เพื่อป้องกันการโจมตี DNS rebinding
    ([Pull Request](https://github.com/rails/rails/pull/33145))

* อนุญาตให้ใช้ `parsed_body` ใน `ActionController::TestCase`
    ([Pull Request](https://github.com/rails/rails/pull/34717))

* สร้าง `ArgumentError` เมื่อมีเส้นทางรูทหลายเส้นในบริบทเดียวโดยไม่ระบุชื่อ `as:`
    ([Pull Request](https://github.com/rails/rails/pull/34494))

* อนุญาตให้ใช้ `#rescue_from` ในการจัดการข้อผิดพลาดการแยกวิเคราะห์พารามิเตอร์
    ([Pull Request](https://github.com/rails/rails/pull/34341))

* เพิ่ม `ActionController::Parameters#each_value` เพื่อทำการวนซ้ำผ่านพารามิเตอร์
    ([Pull Request](https://github.com/rails/rails/pull/33979))

* เข้ารหัสชื่อไฟล์ Content-Disposition ใน `send_data` และ `send_file`
    ([Pull Request](https://github.com/rails/rails/pull/33829))
*   เปิดเผย `ActionController::Parameters#each_key`.
    ([Pull Request](https://github.com/rails/rails/pull/33758))

*   เพิ่มข้อมูลเชิงวัตถุและวันหมดอายุในคุกกี้ที่เข้ารหัสเพื่อป้องกันการคัดลอกค่าของคุกกี้ไปยังคุกกี้อื่น
    ([Pull Request](https://github.com/rails/rails/pull/32937))

*   เรียก `ActionController::RespondToMismatchError` เมื่อมีการเรียกใช้ `respond_to` ที่ขัดแย้งกัน
    ([Pull Request](https://github.com/rails/rails/pull/33446))

*   เพิ่มหน้าข้อผิดพลาดเฉพาะสำหรับกรณีที่ไม่มีเทมเพลตสำหรับรูปแบบคำขอ
    ([Pull Request](https://github.com/rails/rails/pull/29286))

*   นำเข้า `ActionDispatch::DebugExceptions.register_interceptor` เป็นวิธีการเชื่อมต่อกับ DebugExceptions และประมวลผลข้อยกเว้นก่อนที่จะถูกแสดง
    ([Pull Request](https://github.com/rails/rails/pull/23868))

*   แสดงเฉพาะหนึ่งค่าของหัวข้อ Content-Security-Policy nonce ต่อคำขอ
    ([Pull Request](https://github.com/rails/rails/pull/32602))

*   เพิ่มโมดูลเฉพาะสำหรับการกำหนดค่าส่วนหัวเริ่มต้นของ Rails ที่สามารถรวมเข้ากับคอนโทรลเลอร์ได้อย่างชัดเจน
    ([Pull Request](https://github.com/rails/rails/pull/32484))

*   เพิ่ม `#dig` ใน `ActionDispatch::Request::Session`.
    ([Pull Request](https://github.com/rails/rails/pull/32446))

Action View
-----------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบตัวช่วย `image_alt` ที่ถูกยกเลิก
    ([Commit](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f))

*   ลบโมดูล `RecordTagHelper` ที่ว่างเปล่าซึ่งฟังก์ชันการทำงาน
    ถูกย้ายไปยังแพ็กเกจ `record_tag_helper` แล้ว
    ([Commit](https://github.com/rails/rails/commit/5c5ddd69b1e06fb6b2bcbb021e9b8dae17e7cb31))

### การเลิกใช้

*   เลิกใช้ `ActionView::Template.finalize_compiled_template_methods` โดยไม่มีการแทนที่
    ([Pull Request](https://github.com/rails/rails/pull/35036))

*   เลิกใช้ `config.action_view.finalize_compiled_template_methods` โดยไม่มีการแทนที่
    ([Pull Request](https://github.com/rails/rails/pull/35036))

*   เลิกใช้การเรียกเมธอดของโมเดลที่เป็นส่วนตัวจากตัวช่วยการแสดงผล `options_from_collection_for_select`
    ([Pull Request](https://github.com/rails/rails/pull/33547))

### การเปลี่ยนแปลงที่สำคัญ

*   เคลียร์แคช Action View เฉพาะในโหมดการพัฒนาเมื่อมีการเปลี่ยนแปลงในไฟล์ เพื่อเพิ่มความเร็วในโหมดการพัฒนา
    ([Pull Request](https://github.com/rails/rails/pull/35629))

*   ย้ายแพ็กเกจทั้งหมดของ Rails npm เข้าไปในขอบเขต `@rails`
    ([Pull Request](https://github.com/rails/rails/pull/34905))

*   ยอมรับเฉพาะรูปแบบจากชนิด MIME ที่ลงทะเบียนเท่านั้น
    ([Pull Request](https://github.com/rails/rails/pull/35604), [Pull Request](https://github.com/rails/rails/pull/35753))

*   เพิ่มการจัดสรรในการแสดงเทมเพลตและพาร์ทเชียลในเซิร์ฟเวอร์
    ([Pull Request](https://github.com/rails/rails/pull/34136))

*   เพิ่มตัวเลือก `year_format` ในแท็ก `date_select` เพื่อปรับแต่งชื่อปี
    ([Pull Request](https://github.com/rails/rails/pull/32190))

*   เพิ่มตัวเลือก `nonce: true` สำหรับตัวช่วย `javascript_include_tag` เพื่อรองรับการสร้าง nonce อัตโนมัติสำหรับ Content Security Policy
    ([Pull Request](https://github.com/rails/rails/pull/32607))

*   เพิ่มการกำหนดค่า `action_view.finalize_compiled_template_methods` เพื่อปิดหรือเปิดใช้งาน finalizer ของ `ActionView::Template`
    ([Pull Request](https://github.com/rails/rails/pull/32418))

*   แยกการเรียก `confirm` ของ JavaScript เป็นเมธอดที่สามารถแก้ไขได้เองใน `rails_ujs`
    ([Pull Request](https://github.com/rails/rails/pull/32404))
*   เพิ่มตัวเลือกการกำหนดค่า `action_controller.default_enforce_utf8` เพื่อใช้ในการบังคับให้ใช้การเข้ารหัส UTF-8 ค่าเริ่มต้นคือ `false`
    ([Pull Request](https://github.com/rails/rails/pull/32125))

*   เพิ่มการสนับสนุนรูปแบบคีย์ I18n สำหรับคีย์ locale ในแท็ก submit
    ([Pull Request](https://github.com/rails/rails/pull/26799))

Action Mailer
-------------

โปรดอ้างอิง [Changelog][action-mailer] สำหรับรายละเอียดการเปลี่ยนแปลง

### การลบ

### การเลิกใช้

*   เลิกใช้ `ActionMailer::Base.receive` และแนะนำให้ใช้ Action Mailbox แทน
    ([Commit](https://github.com/rails/rails/commit/e3f832a7433a291a51c5df397dc3dd654c1858cb))

*   เลิกใช้ `DeliveryJob` และ `Parameterized::DeliveryJob` และแนะนำให้ใช้
    `MailDeliveryJob` แทน
    ([Pull Request](https://github.com/rails/rails/pull/34591))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม `MailDeliveryJob` เพื่อใช้ในการส่งอีเมลทั้งแบบธรรมดาและแบบพารามิเตอร์
    ([Pull Request](https://github.com/rails/rails/pull/34591))

*   อนุญาตให้งานส่งอีเมลที่กำหนดเองสามารถทำงานร่วมกับการตรวจสอบข้อกำหนดของ Action Mailer
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   อนุญาตให้ระบุชื่อเทมเพลตสำหรับอีเมลแบบหลายส่วนด้วยบล็อกแทนการใช้เพียงชื่อแอ็กชันเท่านั้น
    ([Pull Request](https://github.com/rails/rails/pull/22534))

*   เพิ่ม `perform_deliveries` เข้าไปใน payload ของการแจ้งเตือน `deliver.action_mailer`
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   ปรับปรุงข้อความบันทึกเมื่อ `perform_deliveries` เป็น false เพื่อแสดงว่าการส่งอีเมลถูกข้ามไป
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   อนุญาตให้เรียกใช้ `assert_enqueued_email_with` โดยไม่ต้องใช้บล็อก
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   ดำเนินการส่งงานส่งอีเมลที่อยู่ในคิวในบล็อก `assert_emails`
    ([Pull Request](https://github.com/rails/rails/pull/32231))

*   อนุญาตให้ `ActionMailer::Base` ยกเลิกการลงทะเบียน observers และ interceptors
    ([Pull Request](https://github.com/rails/rails/pull/32207))

Active Record
-------------

โปรดอ้างอิง [Changelog][active-record] สำหรับรายละเอียดการเปลี่ยนแปลง

### การลบ

*   ลบ `#set_state` ที่ถูกเลิกใช้จากออบเจกต์ transaction
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

*   ลบการสนับสนุนในการเลือกวิธีที่ขาดหายไปในความสัมพันธ์ไปยัง Arel
    ([Commit](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0))

*   ลบการสนับสนุนในการเลือกวิธีที่ขาดหายไปในความสัมพันธ์ไปยังเมธอดเอกสารส่วนตัวของคลาส
    ([Commit](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d))

*   ลบการสนับสนุนในการระบุชื่อ timestamp สำหรับ `#cache_key`
    ([Commit](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea))

*   ลบ `ActiveRecord::Migrator.migrations_path=` ที่ถูกเลิกใช้
    ([Commit](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d))
*   ลบ `expand_hash_conditions_for_aggregates` ที่ถูกยกเลิกแล้ว
    ([Commit](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e))


### การยกเลิก

*   ยกเลิกการใช้เปรียบเทียบการจัดเรียงตามตัวอักษรที่ไม่ตรงกันสำหรับตัวตรวจสอบความเอกลักษณ์
    ([Commit](https://github.com/rails/rails/commit/9def05385f1cfa41924bb93daa187615e88c95b9))

*   ยกเลิกการใช้เมธอดการค้นหาระดับคลาสหากขอบเขตของผู้รับมีการรั่วไหล
    ([Pull Request](https://github.com/rails/rails/pull/35280))

*   ยกเลิก `config.active_record.sqlite3.represent_boolean_as_integer`
    ([Commit](https://github.com/rails/rails/commit/f59b08119bc0c01a00561d38279b124abc82561b))

*   ยกเลิกการส่ง `migrations_paths` ไปยัง `connection.assume_migrated_upto_version`
    ([Commit](https://github.com/rails/rails/commit/c1b14aded27e063ead32fa911aa53163d7cfc21a))

*   ยกเลิก `ActiveRecord::Result#to_hash` เพื่อใช้แทน `ActiveRecord::Result#to_a`
    ([Commit](https://github.com/rails/rails/commit/16510d609c601aa7d466809f3073ec3313e08937))

*   ยกเลิกเมธอดใน `DatabaseLimits`: `column_name_length`, `table_name_length`,
    `columns_per_table`, `indexes_per_table`, `columns_per_multicolumn_index`,
    `sql_query_length`, และ `joins_per_query`
    ([Commit](https://github.com/rails/rails/commit/e0a1235f7df0fa193c7e299a5adee88db246b44f))

*   ยกเลิก `update_attributes`/`!` เพื่อใช้แทน `update`/`!`
    ([Commit](https://github.com/rails/rails/commit/5645149d3a27054450bd1130ff5715504638a5f5))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มเวอร์ชันขั้นต่ำของแพ็กเกจ `sqlite3` เป็น 1.4
    ([Pull Request](https://github.com/rails/rails/pull/35844))

*   เพิ่ม `rails db:prepare` เพื่อสร้างฐานข้อมูลหากยังไม่มี และเรียกใช้งานการเคลื่อนย้ายของมัน
    ([Pull Request](https://github.com/rails/rails/pull/35768))

*   เพิ่ม `after_save_commit` callback เป็นทางเลือกสำหรับ `after_commit :hook, on: [ :create, :update ]`
    ([Pull Request](https://github.com/rails/rails/pull/35804))

*   เพิ่ม `ActiveRecord::Relation#extract_associated` เพื่อแยกบันทึกที่เกี่ยวข้องจากความสัมพันธ์
    ([Pull Request](https://github.com/rails/rails/pull/35784))

*   เพิ่ม `ActiveRecord::Relation#annotate` เพื่อเพิ่มความคิดเห็น SQL ในการค้นหา ActiveRecord::Relation
    ([Pull Request](https://github.com/rails/rails/pull/35617))

*   เพิ่มการสนับสนุนในการตั้งค่า Optimizer Hints บนฐานข้อมูล
    ([Pull Request](https://github.com/rails/rails/pull/35615))

*   เพิ่มเมธอด `insert_all`/`insert_all!`/`upsert_all` เพื่อทำการแทรกข้อมูลเป็นกลุ่ม
    ([Pull Request](https://github.com/rails/rails/pull/35631))

*   เพิ่ม `rails db:seed:replant` ที่ตัดตารางของแต่ละฐานข้อมูล
    สำหรับสภาพแวดล้อมปัจจุบันและโหลด seed
    ([Pull Request](https://github.com/rails/rails/pull/34779))

*   เพิ่มเมธอด `reselect` ซึ่งเป็นตัวย่อสำหรับ `unscope(:select).select(fields)`
    ([Pull Request](https://github.com/rails/rails/pull/33611))

*   เพิ่มขอบเขตลบสำหรับค่า enum ทั้งหมด
    ([Pull Request](https://github.com/rails/rails/pull/35381))

*   เพิ่ม `#destroy_by` และ `#delete_by` เพื่อลบเงื่อนไข
    ([Pull Request](https://github.com/rails/rails/pull/35316))

*   เพิ่มความสามารถในการเปลี่ยนการเชื่อมต่อฐานข้อมูลโดยอัตโนมัติ
    ([Pull Request](https://github.com/rails/rails/pull/35073))

*   เพิ่มความสามารถในการป้องกันการเขียนข้อมูลไปยังฐานข้อมูลในระหว่างการทำงานของบล็อก
    ([Pull Request](https://github.com/rails/rails/pull/34505))

*   เพิ่ม API เพื่อเปลี่ยนการเชื่อมต่อเพื่อสนับสนุนฐานข้อมูลหลายรายการ
    ([Pull Request](https://github.com/rails/rails/pull/34052))

*   ทำให้ timestamps พร้อมกับความแม่นยำเป็นค่าเริ่มต้นสำหรับการเคลื่อนย้าย
    ([Pull Request](https://github.com/rails/rails/pull/34970))

*   สนับสนุนตัวเลือก `:size` เพื่อเปลี่ยนขนาดของข้อความและ blob ใน MySQL
    ([Pull Request](https://github.com/rails/rails/pull/35071))

*   ตั้งค่าคอลัมน์ foreign key และ foreign type เป็น NULL สำหรับความสัมพันธ์หลายรูปแบบใน `dependent: :nullify`
    ([Pull Request](https://github.com/rails/rails/pull/28078))
*   อนุญาตให้ `ActionController::Parameters` ที่ได้รับอนุญาตเป็นตัวแปรส่งผ่านไปยัง `ActiveRecord::Relation#exists?`
    ([Pull Request](https://github.com/rails/rails/pull/34891))

*   เพิ่มการสนับสนุนใน `#where` สำหรับช่วงที่ไม่มีที่สิ้นสุดที่เพิ่มเข้ามาใน Ruby 2.6
    ([Pull Request](https://github.com/rails/rails/pull/34906))

*   ทำให้ `ROW_FORMAT=DYNAMIC` เป็นตัวเลือกการสร้างตารางเริ่มต้นสำหรับ MySQL
    ([Pull Request](https://github.com/rails/rails/pull/34742))

*   เพิ่มความสามารถในการปิดใช้งานขอบเขตที่สร้างขึ้นโดย `ActiveRecord.enum`
    ([Pull Request](https://github.com/rails/rails/pull/34605))

*   ทำให้การเรียงลำดับอัตโนมัติสามารถกำหนดค่าได้สำหรับคอลัมน์
    ([Pull Request](https://github.com/rails/rails/pull/34480))

*   เพิ่มรุ่นขั้นต่ำของ PostgreSQL เป็นเวอร์ชัน 9.3 โดยลดการสนับสนุนสำหรับเวอร์ชัน 9.1 และ 9.2
    ([Pull Request](https://github.com/rails/rails/pull/34520))

*   ทำให้ค่าของ enum เป็นแบบแช่แข็ง และเกิดข้อผิดพลาดเมื่อพยายามแก้ไขค่าเหล่านั้น
    ([Pull Request](https://github.com/rails/rails/pull/34517))

*   ทำให้ SQL ของข้อผิดพลาด `ActiveRecord::StatementInvalid` เป็นคุณสมบัติของข้อผิดพลาดที่แยกออกมาเป็นของตัวเอง
    และรวม SQL binds เป็นคุณสมบัติข้อผิดพลาดที่แยกออกมาเป็นของตัวเอง
    ([Pull Request](https://github.com/rails/rails/pull/34468))

*   เพิ่มตัวเลือก `:if_not_exists` ใน `create_table`
    ([Pull Request](https://github.com/rails/rails/pull/31382))

*   เพิ่มการสนับสนุนฐานข้อมูลหลายรายการใน `rails db:schema:cache:dump`
    และ `rails db:schema:cache:clear`
    ([Pull Request](https://github.com/rails/rails/pull/34181))

*   เพิ่มการสนับสนุนการกำหนดค่าแบบแฮชและ URL ในฐานข้อมูลแฮชของ `ActiveRecord::Base.connected_to`
    ([Pull Request](https://github.com/rails/rails/pull/34196))

*   เพิ่มการสนับสนุนสูตรเริ่มต้นและดัชนีสูตรสำหรับ MySQL
    ([Pull Request](https://github.com/rails/rails/pull/34307))

*   เพิ่มตัวเลือก `index` สำหรับช่วยในการเปลี่ยนแปลงตาราง
    ([Pull Request](https://github.com/rails/rails/pull/23593))

*   แก้ไขการย้อนกลับของ `transaction` สำหรับการเรียกใช้งาน
    ที่อยู่ภายใน `transaction` ในการย้อนกลับของการเรียกใช้งาน
    ([Pull Request](https://github.com/rails/rails/pull/31604))

*   อนุญาตให้ `ActiveRecord::Base.configurations=` สามารถตั้งค่าด้วยแฮชที่มีสัญลักษณ์
    ([Pull Request](https://github.com/rails/rails/pull/33968))

*   แก้ไขการนับจำนวนเพื่ออัปเดตเฉพาะเมื่อบันทึกเร็คคอร์ดจริงๆ
    ([Pull Request](https://github.com/rails/rails/pull/33913))

*   เพิ่มการสนับสนุนดัชนีแสดงออกสำหรับ SQLite adapter
    ([Pull Request](https://github.com/rails/rails/pull/33874))

*   อนุญาตให้คลาสย่อยนิยามการเรียกใช้งานอัตโนมัติสำหรับบันทึกที่เกี่ยวข้อง
    ([Pull Request](https://github.com/rails/rails/pull/33378))

*   เพิ่มรุ่นขั้นต่ำของ MySQL เป็นเวอร์ชัน 5.5.8
    ([Pull Request](https://github.com/rails/rails/pull/33853))

*   ใช้ชุดตัวอักษร utf8mb4 เป็นค่าเริ่มต้นใน MySQL
    ([Pull Request](https://github.com/rails/rails/pull/33608))

*   เพิ่มความสามารถในการกรองข้อมูลที่เป็นข้อมูลที่อ่อนไหวใน `#inspect`
    ([Pull Request](https://github.com/rails/rails/pull/33756), [Pull Request](https://github.com/rails/rails/pull/34208))

*   เปลี่ยน `ActiveRecord::Base.configurations` เพื่อให้ส่งคืนวัตถุแทนแฮช
    ([Pull Request](https://github.com/rails/rails/pull/33637))
*   เพิ่มการกำหนดค่าฐานข้อมูลเพื่อปิดการใช้งาน advisory locks
    ([Pull Request](https://github.com/rails/rails/pull/33691))

*   อัปเดต SQLite3 adapter `alter_table` เพื่อกู้คืน foreign keys
    ([Pull Request](https://github.com/rails/rails/pull/33585))

*   อนุญาตให้ `:to_table` option ของ `remove_foreign_key` เป็นสถานะที่สามารถกลับได้
    ([Pull Request](https://github.com/rails/rails/pull/33530))

*   แก้ไขค่าเริ่มต้นสำหรับ MySQL time types ที่ระบุความแม่นยำ
    ([Pull Request](https://github.com/rails/rails/pull/33280))

*   แก้ไข `touch` option เพื่อให้ทำงานได้สอดคล้องกับ `Persistence#touch` method อย่างสม่ำเสมอ
    ([Pull Request](https://github.com/rails/rails/pull/33107))

*   สร้างข้อยกเว้นสำหรับการกำหนดคอลัมน์ซ้ำใน Migrations
    ([Pull Request](https://github.com/rails/rails/pull/33029))

*   เพิ่มรุ่นขั้นต่ำของ SQLite เป็นเวอร์ชัน 3.8
    ([Pull Request](https://github.com/rails/rails/pull/32923))

*   แก้ไขบันทึกหลักไม่ให้บันทึกพร้อมกับบันทึกลูกซ้ำ
    ([Pull Request](https://github.com/rails/rails/pull/32952))

*   ตรวจสอบให้แน่ใจว่า `Associations::CollectionAssociation#size` และ `Associations::CollectionAssociation#empty?`
    ใช้ loaded association ids ถ้ามีอยู่
    ([Pull Request](https://github.com/rails/rails/pull/32617))

*   เพิ่มการสนับสนุนในการโหลด associations ของ polymorphic associations เมื่อไม่มีรายการทั้งหมดที่มี associations ที่ร้องขอ
    ([Commit](https://github.com/rails/rails/commit/75ef18c67c29b1b51314b6c8a963cee53394080b))

*   เพิ่มเมธอด `touch_all` ใน `ActiveRecord::Relation`
    ([Pull Request](https://github.com/rails/rails/pull/31513))

*   เพิ่ม `ActiveRecord::Base.base_class?` predicate
    ([Pull Request](https://github.com/rails/rails/pull/32417))

*   เพิ่มตัวเลือก prefix/suffix ที่กำหนดเองใน `ActiveRecord::Store.store_accessor`
    ([Pull Request](https://github.com/rails/rails/pull/32306))

*   เพิ่ม `ActiveRecord::Base.create_or_find_by`/`!` เพื่อจัดการกับสถานการณ์ SELECT/INSERT race condition ใน
    `ActiveRecord::Base.find_or_create_by`/`!` โดยใช้ unique constraints ในฐานข้อมูล
    ([Pull Request](https://github.com/rails/rails/pull/31989))

*   เพิ่ม `Relation#pick` เป็นตัวย่อสำหรับ single-value plucks
    ([Pull Request](https://github.com/rails/rails/pull/31941))

Active Storage
--------------

โปรดอ้างอิงที่ [Changelog][active-storage] สำหรับรายละเอียดการเปลี่ยนแปลง

### การลบ

### การเลิกใช้

*   เลิกใช้ `config.active_storage.queue` และใช้ `config.active_storage.queues.analysis`
    และ `config.active_storage.queues.purge` แทน
    ([Pull Request](https://github.com/rails/rails/pull/34838))

*   เลิกใช้ `ActiveStorage::Downloading` และใช้ `ActiveStorage::Blob#open` แทน
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   เลิกใช้ `mini_magick` โดยตรงสำหรับการสร้าง image variants และใช้
    `image_processing` แทน
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

*   เลิกใช้ `:combine_options` ใน Active Storage's ImageProcessing transformer
    โดยไม่มีตัวแทน
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มการสนับสนุนในการสร้าง BMP image variants
    ([Pull Request](https://github.com/rails/rails/pull/36051))

*   เพิ่มการสนับสนุนในการสร้าง TIFF image variants
    ([Pull Request](https://github.com/rails/rails/pull/34824))

*   เพิ่มการสนับสนุนในการสร้าง progressive JPEG image variants
    ([Pull Request](https://github.com/rails/rails/pull/34455))

*   เพิ่ม `ActiveStorage.routes_prefix` เพื่อกำหนดค่าเส้นทางที่สร้างขึ้นโดย Active Storage
    ([Pull Request](https://github.com/rails/rails/pull/33883))

*   สร้างการตอบสนอง 404 Not Found ใน `ActiveStorage::DiskController#show` เมื่อ
    ไฟล์ที่ร้องขอหายไปจาก disk service
    ([Pull Request](https://github.com/rails/rails/pull/33666))
* เพิ่ม `ActiveStorage::FileNotFoundError` เมื่อไฟล์ที่ร้องขอหายไปสำหรับ `ActiveStorage::Blob#download` และ `ActiveStorage::Blob#open` ([Pull Request](https://github.com/rails/rails/pull/33666))

* เพิ่มคลาส `ActiveStorage::Error` ที่เป็นคลาสทั่วไปที่ข้อยกเว้นของ Active Storage สืบทอดมาจาก ([Commit](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))

* บันทึกไฟล์ที่อัปโหลดที่กำหนดให้กับบันทึกไปยังที่เก็บเมื่อบันทึกบันทึกแทนที่ทันที ([Pull Request](https://github.com/rails/rails/pull/33303))

* ตัวเลือกที่จะแทนที่ไฟล์ที่มีอยู่แทนที่การเพิ่มไฟล์เมื่อกำหนดให้กับคอลเลกชันของการแนบ (เช่น `@user.update!(images: [ … ])`) ใช้ `config.active_storage.replace_on_assign_to_many` เพื่อควบคุมพฤติกรรมนี้ ([Pull Request](https://github.com/rails/rails/pull/33303), [Pull Request](https://github.com/rails/rails/pull/36716))

* เพิ่มความสามารถในการสะท้อนกลับไปที่การแนบที่กำหนดไว้โดยใช้กลไกการสะท้อน Active Record ที่มีอยู่ ([Pull Request](https://github.com/rails/rails/pull/33018))

* เพิ่ม `ActiveStorage::Blob#open` ซึ่งดาวน์โหลด blob ไปยัง tempfile บนดิสก์และให้ tempfile ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

* รองรับการดาวน์โหลดแบบสตรีมจาก Google Cloud Storage ต้องใช้เวอร์ชัน 1.11+ ของ `google-cloud-storage` gem ([Pull Request](https://github.com/rails/rails/pull/32788))

* ใช้ `image_processing` gem สำหรับตัวแปร Active Storage แทนการใช้ `mini_magick` โดยตรง ([Pull Request](https://github.com/rails/rails/pull/32471))

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

* เพิ่มตัวเลือกการกำหนดรูปแบบของ `ActiveModel::Errors#full_message` ([Pull Request](https://github.com/rails/rails/pull/32956))

* เพิ่มการสนับสนุนในการกำหนดค่าชื่อแอตทริบิวต์สำหรับ `has_secure_password` ([Pull Request](https://github.com/rails/rails/pull/26764))

* เพิ่มเมธอด `#slice!` ให้กับ `ActiveModel::Errors` ([Pull Request](https://github.com/rails/rails/pull/34489))

* เพิ่ม `ActiveModel::Errors#of_kind?` เพื่อตรวจสอบความเป็นมาของข้อผิดพลาดที่เฉพาะเจาะจง ([Pull Request](https://github.com/rails/rails/pull/34866))

* แก้ไขเมธอด `ActiveModel::Serializers::JSON#as_json` สำหรับ timestamp ([Pull Request](https://github.com/rails/rails/pull/31503))

* แก้ไขตัวตรวจสอบ numericality เพื่อใช้ค่าก่อนแปลงชนิดยกเว้น Active Record ([Pull Request](https://github.com/rails/rails/pull/33654))

* แก้ไขการตรวจสอบความเท่าเทียมของ numericality ของ `BigDecimal` และ `Float` โดยแปลงเป็น `BigDecimal` ทั้งสองด้านของการตรวจสอบ ([Pull Request](https://github.com/rails/rails/pull/32852))

* แก้ไขค่าปีเมื่อแปลง multiparameter time hash ([Pull Request](https://github.com/rails/rails/pull/34990))

* แปลงค่าตัวแปร boolean ที่เป็นสัญลักษณ์เท็จเป็น false บนแอตทริบิวต์ boolean ([Pull Request](https://github.com/rails/rails/pull/35794))

* ส่งคืนวันที่ที่ถูกต้องในขณะแปลงพารามิเตอร์ใน `value_from_multiparameter_assignment` สำหรับ `ActiveModel::Type::Date` ([Pull Request](https://github.com/rails/rails/pull/29651))

* ย้อนกลับไปที่ลักษณะที่เกี่ยวข้องก่อนจะย้อนกลับไปที่เนมสเปซ `:errors` เมื่อดึงการแปลผิดพลาด ([Pull Request](https://github.com/rails/rails/pull/35424))
Active Support
--------------

โปรดอ้างอิงที่ [Changelog][active-support] เพื่อดูการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบเมธอด `#acronym_regex` ที่ถูกยกเลิกจาก `Inflections`
    ([Commit](https://github.com/rails/rails/commit/0ce67d3cd6d1b7b9576b07fecae3dd5b422a5689))

*   ลบเมธอด `Module#reachable?` ที่ถูกยกเลิก
    ([Commit](https://github.com/rails/rails/commit/6eb1d56a333fd2015610d31793ed6281acd66551))

*   ลบ `` Kernel#` `` โดยไม่มีการแทนที่ใด ๆ
    ([Pull Request](https://github.com/rails/rails/pull/31253))

### การเลิกใช้

*   เลิกใช้การใช้ตัวเลขลบเป็นอาร์กิวเมนต์สำหรับ `String#first` และ `String#last`
    ([Pull Request](https://github.com/rails/rails/pull/33058))

*   เลิกใช้ `ActiveSupport::Multibyte::Unicode#downcase/upcase/swapcase`
    และใช้ `String#downcase/upcase/swapcase` แทน
    ([Pull Request](https://github.com/rails/rails/pull/34123))

*   เลิกใช้ `ActiveSupport::Multibyte::Unicode#normalize`
    และ `ActiveSupport::Multibyte::Chars#normalize` และใช้ `String#unicode_normalize` แทน
    ([Pull Request](https://github.com/rails/rails/pull/34202))

*   เลิกใช้ `ActiveSupport::Multibyte::Chars.consumes?` และใช้ `String#is_utf8?` แทน
    ([Pull Request](https://github.com/rails/rails/pull/34215))

*   เลิกใช้ `ActiveSupport::Multibyte::Unicode#pack_graphemes(array)`
    และ `ActiveSupport::Multibyte::Unicode#unpack_graphemes(string)`
    และใช้ `array.flatten.pack("U*")` และ `string.scan(/\X/).map(&:codepoints)` ตามลำดับ
    ([Pull Request](https://github.com/rails/rails/pull/34254))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มการสนับสนุนการทดสอบแบบพร้อมกัน
    ([Pull Request](https://github.com/rails/rails/pull/31900))

*   ตรวจสอบให้แน่ใจว่า `String#strip_heredoc` รักษาความแข็งแรงของสตริงที่แช่แข็งไว้
    ([Pull Request](https://github.com/rails/rails/pull/32037))

*   เพิ่ม `String#truncate_bytes` เพื่อตัดสตริงให้มีขนาดไบต์สูงสุดโดยไม่ทำให้ตัวอักษรหลายไบต์หรือกลุ่มกราฟีมแตก
    ([Pull Request](https://github.com/rails/rails/pull/27319))

*   เพิ่มตัวเลือก `private` ในเมธอด `delegate` เพื่อเลือกใช้เมธอดเอกชน ตัวเลือกนี้ยอมรับค่า `true/false`
    ([Pull Request](https://github.com/rails/rails/pull/31944))

*   เพิ่มการสนับสนุนการแปลผ่าน I18n สำหรับ `ActiveSupport::Inflector#ordinal`
    และ `ActiveSupport::Inflector#ordinalize`
    ([Pull Request](https://github.com/rails/rails/pull/32168))

*   เพิ่มเมธอด `before?` และ `after?` ใน `Date`, `DateTime`,
    `Time`, และ `TimeWithZone`
    ([Pull Request](https://github.com/rails/rails/pull/32185))

*   แก้ไขข้อบกพร่องที่ `URI.unescape` จะล้มเหลวเมื่อมีอินพุตที่ผสมระหว่างตัวอักษรยูนิโคดและตัวอักษรที่หลบหนี้
    ([Pull Request](https://github.com/rails/rails/pull/32183))

*   แก้ไขข้อบกพร่องที่ `ActiveSupport::Cache` จะทำให้ขนาดการเก็บข้อมูลขยายอย่างมากเมื่อเปิดใช้งานการบีบอัด
    ([Pull Request](https://github.com/rails/rails/pull/32539))

*   Redis cache store: `delete_matched` ไม่บล็อกเซิร์ฟเวอร์ Redis อีกต่อไป
    ([Pull Request](https://github.com/rails/rails/pull/32614))

*   แก้ไขข้อบกพร่องที่ `ActiveSupport::TimeZone.all` จะล้มเหลวเมื่อข้อมูล tzinfo สำหรับเขตเวลาใด ๆ ที่กำหนดไว้ใน `ActiveSupport::TimeZone::MAPPING` หายไป
    ([Pull Request](https://github.com/rails/rails/pull/32613))

*   เพิ่ม `Enumerable#index_with` ซึ่งช่วยให้สร้างแฮชจาก enumerable ด้วยค่าจากบล็อกที่ผ่านมาหรืออาร์กิวเมนต์เริ่มต้น
    ([Pull Request](https://github.com/rails/rails/pull/32523))

*   อนุญาตให้ `Range#===` และ `Range#cover?` ทำงานกับอาร์กิวเมนต์ชนิด `Range`
    ([Pull Request](https://github.com/rails/rails/pull/32938))

*   สนับสนุนการหมดอายุของคีย์ในการดำเนินการ `increment/decrement` ของ RedisCacheStore
    ([Pull Request](https://github.com/rails/rails/pull/33254))

*   เพิ่มคุณสมบัติเวลา CPU, เวลาว่างเปล่า และการจัดสรรทรัพยากรในเหตุการณ์ผู้สมัครใช้งานบันทึก
    ([Pull Request](https://github.com/rails/rails/pull/33449))
*   เพิ่มการสนับสนุนสำหรับอ็อบเจกต์เหตุการณ์ในระบบการแจ้งเตือน Active Support
    ([Pull Request](https://github.com/rails/rails/pull/33451))

*   เพิ่มการสนับสนุนให้ไม่แคชรายการ `nil` โดยการเพิ่มตัวเลือกใหม่ `skip_nil`
    สำหรับ `ActiveSupport::Cache#fetch`
    ([Pull Request](https://github.com/rails/rails/pull/25437))

*   เพิ่มเมธอด `Array#extract!` ซึ่งจะลบและส่งคืนองค์ประกอบที่ฟังก์ชันคืนค่าเป็นจริง
    ([Pull Request](https://github.com/rails/rails/pull/33137))

*   รักษาสตริงที่ปลอดภัยสำหรับ HTML หลังจากที่ตัดออก
    ([Pull Request](https://github.com/rails/rails/pull/33808))

*   เพิ่มการสนับสนุนในการติดตามการโหลดอัตโนมัติของค่าคงที่ผ่านการบันทึก
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   กำหนด `unfreeze_time` เป็นชื่อย่อของ `travel_back`
    ([Pull Request](https://github.com/rails/rails/pull/33813))

*   เปลี่ยน `ActiveSupport::TaggedLogging.new` เพื่อให้ส่งคืนตัวอย่างเครื่องมือเขียนบันทึกใหม่แทนการเปลี่ยนแปลงตัวแปรที่ได้รับเป็นอาร์กิวเมนต์
    ([Pull Request](https://github.com/rails/rails/pull/27792))

*   จัดการ `#delete_prefix`, `#delete_suffix` และ `#unicode_normalize` เป็นเมธอดที่ไม่ปลอดภัยสำหรับ HTML
    ([Pull Request](https://github.com/rails/rails/pull/33990))

*   แก้ไขข้อบกพร่องที่ `#without` สำหรับ `ActiveSupport::HashWithIndifferentAccess`
    จะล้มเหลวเมื่อมีอาร์กิวเมนต์เป็นสัญลักษณ์
    ([Pull Request](https://github.com/rails/rails/pull/34012))

*   เปลี่ยนชื่อ `Module#parent`, `Module#parents`, และ `Module#parent_name` เป็น
    `module_parent`, `module_parents`, และ `module_parent_name`
    ([Pull Request](https://github.com/rails/rails/pull/34051))

*   เพิ่ม `ActiveSupport::ParameterFilter`
    ([Pull Request](https://github.com/rails/rails/pull/34039))

*   แก้ไขปัญหาที่ระยะเวลาถูกปัดเป็นวินาทีเต็มเมื่อมีจำนวนทศนิยม
    ถูกเพิ่มเข้าไปในระยะเวลา
    ([Pull Request](https://github.com/rails/rails/pull/34135))

*   ทำให้ `#to_options` เป็นชื่อย่อของ `#symbolize_keys` ใน
    `ActiveSupport::HashWithIndifferentAccess`
    ([Pull Request](https://github.com/rails/rails/pull/34360))

*   ไม่ยกเว้นข้อยกเว้นอีกต่อไปหากบล็อกเดียวกันถูกรวมเข้าไปหลายครั้ง
    สำหรับ Concern
    ([Pull Request](https://github.com/rails/rails/pull/34553))

*   รักษาลำดับคีย์ที่ถูกส่งผ่านไปยัง `ActiveSupport::CacheStore#fetch_multi`
    ([Pull Request](https://github.com/rails/rails/pull/34700))

*   แก้ไข `String#safe_constantize` เพื่อไม่ส่งคืน `LoadError` สำหรับการอ้างอิงค่าคงที่ที่เขียนผิดตัวอักษร
    ([Pull Request](https://github.com/rails/rails/pull/34892))

*   เพิ่ม `Hash#deep_transform_values` และ `Hash#deep_transform_values!`
    ([Commit](https://github.com/rails/rails/commit/b8dc06b8fdc16874160f61dcf58743fcc10e57db))

*   เพิ่ม `ActiveSupport::HashWithIndifferentAccess#assoc`
    ([Pull Request](https://github.com/rails/rails/pull/35080))

*   เพิ่ม `before_reset` callback ให้กับ `CurrentAttributes` และกำหนด
    `after_reset` เป็นชื่อย่อของ `resets` เพื่อความสมมาตร
    ([Pull Request](https://github.com/rails/rails/pull/35063))

*   แก้ไข `ActiveSupport::Notifications.unsubscribe` เพื่อจัดการถูกต้อง
    กับผู้สมัครที่เป็น Regex หรือผู้สมัครที่มีรูปแบบหลายรูปแบบอื่น ๆ
    ([Pull Request](https://github.com/rails/rails/pull/32861))

*   เพิ่มกลไกการโหลดอัตโนมัติใหม่โดยใช้ Zeitwerk
    ([Commit](https://github.com/rails/rails/commit/e53430fa9af239e21e11548499d814f540d421e5))

*   เพิ่ม `Array#including` และ `Enumerable#including` เพื่อขยายคอลเลกชันได้อย่างสะดวก
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   เปลี่ยนชื่อ `Array#without` และ `Enumerable#without` เป็น `Array#excluding`
    และ `Enumerable#excluding` ชื่อเดิมของเมธอดถูกเก็บไว้เป็นชื่อย่อ
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   เพิ่มการสนับสนุนในการระบุ `locale` ให้กับ `transliterate` และ `parameterize`
    ([Pull Request](https://github.com/rails/rails/pull/35571))
*   แก้ไข `Time#advance` เพื่อให้ทำงานกับวันที่ก่อน 1001-03-07
    ([Pull Request](https://github.com/rails/rails/pull/35659))

*   อัปเดต `ActiveSupport::Notifications::Instrumenter#instrument` เพื่ออนุญาตให้ไม่ต้องส่งพารามิเตอร์ block
    ([Pull Request](https://github.com/rails/rails/pull/35705))

*   ใช้ weak references ในตัวติดตามลูกสายเพื่อให้สามารถกำจัดลูกสายที่ไม่มีชื่อได้
    ([Pull Request](https://github.com/rails/rails/pull/31442))

*   เรียกใช้เมธอดทดสอบด้วย `with_info_handler` เพื่อให้ปลั๊กอิน minitest-hooks ทำงาน
    ([Commit](https://github.com/rails/rails/commit/758ba117a008b6ea2d3b92c53b6a7a8d7ccbca69))

*   รักษาสถานะ `html_safe?` ใน `ActiveSupport::SafeBuffer#*`
    ([Pull Request](https://github.com/rails/rails/pull/36012))

Active Job
----------

โปรดอ้างอิงที่ [Changelog][active-job] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการสนับสนุน Qu gem
    ([Pull Request](https://github.com/rails/rails/pull/32300))

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มการสนับสนุนตัวแปรลงความสามารถที่กำหนดเองสำหรับอาร์กิวเมนต์ของ Active Job
    ([Pull Request](https://github.com/rails/rails/pull/30941))

*   เพิ่มการสนับสนุนในการดำเนินงาน Active Jobs ในโซนเวลาที่เรียกคิว
    ([Pull Request](https://github.com/rails/rails/pull/32085))

*   อนุญาตให้ส่งพารามิเตอร์ของข้อกำหนด `retry_on`/`discard_on` หลายรายการ
    ([Commit](https://github.com/rails/rails/commit/3110caecbebdad7300daaf26bfdff39efda99e25))

*   อนุญาตให้เรียกใช้ `assert_enqueued_with` และ `assert_enqueued_email_with` โดยไม่ต้องใช้ block
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   ห่อการแจ้งเตือนสำหรับ `enqueue` และ `enqueue_at` ใน callback `around_enqueue` แทน callback `after_enqueue`
    ([Pull Request](https://github.com/rails/rails/pull/33171))

*   อนุญาตให้เรียกใช้ `perform_enqueued_jobs` โดยไม่ต้องใช้ block
    ([Pull Request](https://github.com/rails/rails/pull/33626))

*   อนุญาตให้เรียกใช้ `assert_performed_with` โดยไม่ต้องใช้ block
    ([Pull Request](https://github.com/rails/rails/pull/33635))

*   เพิ่มตัวเลือก `:queue` ในการตรวจสอบงานและช่วยเหลือ
    ([Pull Request](https://github.com/rails/rails/pull/33635))

*   เพิ่ม hooks ใน Active Job รอบการลองใหม่และการละทิ้ง
    ([Pull Request](https://github.com/rails/rails/pull/33751))

*   เพิ่มวิธีการทดสอบสำหรับเซตของอาร์กิวเมนต์เมื่อดำเนินงานงาน
    ([Pull Request](https://github.com/rails/rails/pull/33995))

*   รวมอาร์กิวเมนต์ที่ถอดรหัสในงานที่ส่งกลับโดยเครื่องมือช่วยทดสอบ Active Job
    ([Pull Request](https://github.com/rails/rails/pull/34204))

*   อนุญาตให้เครื่องมือช่วยการยืนยัน Active Job รับ Proc สำหรับคีย์เวิร์ด `only`
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   ลดไมโครวินาทีและนาโนวินาทีจากอาร์กิวเมนต์งานในเครื่องมือช่วยการยืนยัน
    ([Pull Request](https://github.com/rails/rails/pull/35713))

Ruby on Rails Guides
--------------------

โปรดอ้างอิงที่ [Changelog][guides] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มเอกสาร Multiple Databases with Active Record
    ([Pull Request](https://github.com/rails/rails/pull/36389))

*   เพิ่มส่วนเกี่ยวกับการแก้ปัญหาการโหลดค่าคงที่อัตโนมัติ
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   เพิ่มเอกสาร Action Mailbox Basics
    ([Pull Request](https://github.com/rails/rails/pull/34812))

*   เพิ่มเอกสาร Action Text Overview
    ([Pull Request](https://github.com/rails/rails/pull/34878))
เครดิต
-------

ดูรายชื่อเต็มของผู้มีส่วนร่วมใน Rails ได้ที่
[รายชื่อผู้มีส่วนร่วมใน Rails](https://contributors.rubyonrails.org/)
สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและทนทาน ขอแสดงความยินดีแก่ทุกคน

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
