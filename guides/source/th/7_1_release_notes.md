**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 82080185bf1d0c30f22fa131b42e4187
เอกสารปล่อยตัวของ Ruby on Rails 7.1
===============================

เนื้อหาสำคัญใน Rails 7.1:

--------------------------------------------------------------------------------

การอัพเกรดไปยัง Rails 7.1
----------------------

หากคุณกำลังอัพเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัพเกรดเป็น Rails 7.0 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัพเดตไปยัง Rails 7.1 มีรายการสิ่งที่ควรระมัดระวังเมื่ออัพเกรดใน
[การอัพเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-7-0-to-rails-7-1)
คู่มือ

คุณสมบัติหลัก
--------------

Railties
--------

โปรดอ้างอิงที่ [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Action Cable
------------

โปรดอ้างอิงที่ [Changelog][action-cable] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Action Pack
-----------

โปรดอ้างอิงที่ [Changelog][action-pack] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบพฤติกรรมที่ถูกยกเลิกบน `Request#content_type`

*   ลบความสามารถที่ถูกยกเลิกในการกำหนดค่าค่าเดียวให้กับ `config.action_dispatch.trusted_proxies`.

*   ลบการลงทะเบียนของ `poltergeist` และ `webkit` (capybara-webkit) driver สำหรับการทดสอบระบบ

### การเลิกใช้

*   เลิกใช้ `config.action_dispatch.return_only_request_media_type_on_content_type`.

*   เลิกใช้ `AbstractController::Helpers::MissingHelperError`

*   เลิกใช้ `ActionDispatch::IllegalStateError`.

### การเปลี่ยนแปลงที่สำคัญ

Action View
-----------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบค่าคงที่ที่ถูกยกเลิก `ActionView::Path`.

*   ลบการสนับสนุนที่ถูกยกเลิกในการส่งตัวแปรอินสแตนซ์เป็นตัวแปรท้องถิ่นไปยังพาร์ทช่วย.

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog][action-mailer] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Active Record
-------------

โปรดอ้างอิงที่ [Changelog][active-record] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการสนับสนุนสำหรับ `ActiveRecord.legacy_connection_handling`.

*   ลบการเข้าถึงค่าการกำหนดค่าของ `ActiveRecord::Base`

*   ลบการสนับสนุนสำหรับ `:include_replicas` ใน `configs_for`. ใช้ `:include_hidden` แทน

*   ลบการกำหนดค่าที่ถูกยกเลิก `config.active_record.partial_writes`.

*   ลบการกำหนดค่าที่ถูกยกเลิก `Tasks::DatabaseTasks.schema_file_type`.

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Active Storage
--------------

โปรดอ้างอิงที่ [Changelog][active-storage] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบประเภทเนื้อหาเริ่มต้นที่ไม่ถูกต้องในการกำหนดค่า Active Storage.

*   ลบเมธอด `ActiveStorage::Current#host` และ `ActiveStorage::Current#host=` ที่ถูกยกเลิก.

*   ลบพฤติกรรมที่ถูกยกเลิกเมื่อกำหนดค่าให้กับคอลเลกชันของ attachment แทนที่จะเพิ่มไปยังคอลเลกชัน
    คอลเลกชันจะถูกแทนที่

*   ลบเมธอด `purge` และ `purge_later` จากความสัมพันธ์ของ attachment.

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Active Support
--------------

โปรดอ้างอิงที่ [Changelog][active-support] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการเขียนทับที่ถูกยกเลิกของ `Enumerable#sum`.

*   ลบ `ActiveSupport::PerThreadRegistry` ที่ถูกยกเลิก.

*   ลบตัวเลือกที่ถูกยกเลิกในการส่งรูปแบบไปยัง `#to_s` ใน `Array`, `Range`, `Date`, `DateTime`, `Time`,
    `BigDecimal`, `Float` และ `Integer`.

*   ลบการเขียนทับที่ถูกยกเลิกของ `ActiveSupport::TimeWithZone.name`.

*   ลบไฟล์ `active_support/core_ext/uri` ที่ถูกยกเลิก.

*   ลบไฟล์ `active_support/core_ext/range/include_time_with_zone` ที่ถูกยกเลิก.

*   ลบการแปลงอัตโนมัติของออบเจ็กต์เป็น `String` โดย `ActiveSupport::SafeBuffer`.

*   ลบการสนับสนุนที่ถูกยกเลิกในการสร้าง UUID RFC 4122 ไม่ถูกต้องเมื่อให้รหัสเนมสเปซที่ไม่ใช่หนึ่งใน
    ค่าคงที่ที่กำหนดไว้ใน `Digest::UUID`.

### การเลิกใช้

*   เลิกใช้ `config.active_support.disable_to_s_conversion`.

*   เลิกใช้ `config.active_support.remove_deprecated_time_with_zone_name`.

*   เลิกใช้ `config.active_support.use_rfc4122_namespaced_uuids`.

### การเปลี่ยนแปลงที่สำคัญ

Active Job
----------

โปรดอ้างอิงที่ [Changelog][active-job] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Action Text
----------

โปรดอ้างอิงที่ [Changelog][action-text] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Action Mailbox
----------

โปรดอ้างอิงที่ [Changelog][action-mailbox] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

คู่มือ Ruby on Rails
--------------------

โปรดอ้างอิงที่ [Changelog][guides] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

เครดิต
-------

ดูรายชื่อ
[active-storage]: https://github.com/rails/rails/blob/main/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/main/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/main/actionmailbox/CHANGELOG.md
