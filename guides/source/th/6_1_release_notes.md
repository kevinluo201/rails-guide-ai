**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 1d652e6ccda9c901ca3f6a003c95f83e
เอกสารปล่อยตัวของ Ruby on Rails 6.1
===============================

จุดเด่นใน Rails 6.1:

* การสลับการเชื่อมต่อตามฐานข้อมูล
* การแบ่งแยกแนวนอน
* การโหลดสมาชิกแบบเข้มงวด
* ประเภทที่ได้รับมอบหมาย
* การทำลายสมาชิกแบบ Async

เอกสารปล่อยตัวนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่เอกสารเปลี่ยนแปลงหรือตรวจสอบ [รายการของการเปลี่ยนแปลง](https://github.com/rails/rails/commits/6-1-stable) ในเก็บรวบรวมหลักของ Rails ใน GitHub

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 6.1
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเข้าไป คุณควรอัปเกรดเป็น Rails 6.0 ก่อนหากคุณยังไม่ได้และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 6.1 มีรายการสิ่งที่ควรระมัดระวังเมื่ออัปเกรดใน [การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-0-to-rails-6-1)

คุณสมบัติหลัก
--------------

### การสลับการเชื่อมต่อตามฐานข้อมูล

Rails 6.1 ให้คุณสามารถ [สลับการเชื่อมต่อตามฐานข้อมูลตามฐานข้อมูล](https://github.com/rails/rails/pull/40370) ได้ ในรุ่น 6.0 หากคุณสลับไปยังบทบาท `reading` แล้วการเชื่อมต่อฐานข้อมูลทั้งหมดก็จะสลับไปยังบทบาทการอ่าน ตอนนี้ในรุ่น 6.1 หากคุณตั้งค่า `legacy_connection_handling` เป็น `false` ในการกำหนดค่าของคุณ Rails จะอนุญาตให้คุณสลับการเชื่อมต่อสำหรับฐานข้อมูลเดียวโดยการเรียกใช้ `connected_to` บนคลาสแบบนามธรรมที่เกี่ยวข้อง

### การแบ่งแยกแนวนอน

Rails 6.0 มีความสามารถในการแบ่งแยกฟังก์ชัน (พาร์ติชันหลายพาร์ติชัน, สกีมาต่างกัน) ในฐานข้อมูลของคุณ แต่ไม่สามารถรองรับการแบ่งแยกแนวนอน (สกีมาเดียวกัน, พาร์ติชันหลายพาร์ติชัน) ได้ Rails ไม่สามารถรองรับการแบ่งแยกแนวนอนได้เนื่องจากโมเดลใน Active Record สามารถมีการเชื่อมต่อเพียงหนึ่งต่อบทบาทต่อคลาสเท่านั้น ตอนนี้ได้แก้ไขแล้วและ [การแบ่งแยกแนวนอน](https://github.com/rails/rails/pull/38531) กับ Rails สามารถใช้งานได้

### การโหลดสมาชิกแบบเข้มงวด

[การโหลดสมาชิกแบบเข้มงวด](https://github.com/rails/rails/pull/37400) ช่วยให้คุณสามารถให้แน่ใจได้ว่าสมาชิกของคุณถูกโหลดล่วงหน้าทั้งหมดและหยุด N+1 ก่อนที่จะเกิดขึ้น

### ประเภทที่ได้รับมอบหมาย

[ประเภทที่ได้รับมอบหมาย](https://github.com/rails/rails/pull/39341) เป็นทางเลือกสำหรับการสืบทอดแบบตารางเดียว สิ่งนี้ช่วยให้สามารถแสดงชั้นสูงให้เป็นคลาสที่เป็นตัวแทนที่แสดงโดยตารางของตัวเอง แต่ละคลาสย่อยมีตารางของตัวเองสำหรับแอตทริบิวต์เพิ่มเติม

### การทำลายสมาชิกแบบ Async

[การทำลายสมาชิกแบบ Async](https://github.com/rails/rails/pull/40157) เพิ่มความสามารถให้แอปพลิเคชันสามารถ `ทำลาย` สมาชิกในงานพื้นหลังได้ สิ่งนี้ช่วยให้คุณหลีกเลี่ยงการหมดเวลาและปัญหาประสิทธิภาพอื่นๆ ในแอปพลิเคชันของคุณเมื่อทำลายข้อมูล

Railties
--------

โปรดอ้างอิงที่ [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบงาน `rake notes` ที่ถูกยกเลิก

*   ลบตัวเลือก `connection` ที่ถูกยกเลิกในคำสั่ง `rails dbconsole`

*   ลบการสนับสนุนตัวแปรสภาพแวดล้อม `SOURCE_ANNOTATION_DIRECTORIES` ที่ถูกยกเลิกจาก `rails notes`

*   ลบอาร์กิวเมนต์ `server` ที่ถูกยกเลิกจากคำสั่ง rails server

*   ลบการสนับสนุนตัวแปรสภาพแวดล้อม `HOST` ที่ถูกยกเลิกสำหรับระบุ IP เซิร์ฟเวอร์

*   ลบงาน `rake dev:cache` ที่ถูกยกเลิก

*   ลบงาน `rake routes` ที่ถูกยกเลิก

*   ลบงาน `rake initializers` ที่ถูกยกเลิก

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

*   ลบคลาส `ActionDispatch::Http::ParameterFilter` ที่ถูกยกเลิก

*   ลบตัวเลือก `force_ssl` ในระดับคอนโทรลเลอร์ที่ถูกยกเลิก

### การเลิกใช้

*   เลิกใช้ `config.action_dispatch.return_only_media_type_on_content_type`

### การเปลี่ยนแปลงที่สำคัญ

*   เปลี่ยน `ActionDispatch::Response#content_type` เพื่อให้ส่งคืนส่วนหัว Content-Type ทั้งหมด
Action View
-----------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `escape_whitelist` ที่ถูกยกเลิกไปจาก `ActionView::Template::Handlers::ERB`.

*   ลบ `find_all_anywhere` ที่ถูกยกเลิกไปจาก `ActionView::Resolver`.

*   ลบ `formats` ที่ถูกยกเลิกไปจาก `ActionView::Template::HTML`.

*   ลบ `formats` ที่ถูกยกเลิกไปจาก `ActionView::Template::RawFile`.

*   ลบ `formats` ที่ถูกยกเลิกไปจาก `ActionView::Template::Text`.

*   ลบ `find_file` ที่ถูกยกเลิกไปจาก `ActionView::PathSet`.

*   ลบ `rendered_format` ที่ถูกยกเลิกไปจาก `ActionView::LookupContext`.

*   ลบ `find_file` ที่ถูกยกเลิกไปจาก `ActionView::ViewPaths`.

*   ลบการสนับสนุนที่ถูกยกเลิกไปในการส่งวัตถุที่ไม่ใช่ `ActionView::LookupContext` เป็นอาร์กิวเมนต์แรกใน `ActionView::Base#initialize`.

*   ลบอาร์กิวเมนต์ `format` ที่ถูกยกเลิกไปใน `ActionView::Base#initialize`.

*   ลบ `ActionView::Template#refresh` ที่ถูกยกเลิกไป.

*   ลบ `ActionView::Template#original_encoding` ที่ถูกยกเลิกไป.

*   ลบ `ActionView::Template#variants` ที่ถูกยกเลิกไป.

*   ลบ `ActionView::Template#formats` ที่ถูกยกเลิกไป.

*   ลบ `ActionView::Template#virtual_path=` ที่ถูกยกเลิกไป.

*   ลบ `ActionView::Template#updated_at` ที่ถูกยกเลิกไป.

*   ลบอาร์กิวเมนต์ `updated_at` ที่ต้องการใน `ActionView::Template#initialize`.

*   ลบ `ActionView::Template.finalize_compiled_template_methods` ที่ถูกยกเลิกไป.

*   ลบ `config.action_view.finalize_compiled_template_methods` ที่ถูกยกเลิกไป.

*   ลบการสนับสนุนที่ถูกยกเลิกไปในการเรียกใช้ `ActionView::ViewPaths#with_fallback` ด้วยบล็อก.

*   ลบการสนับสนุนที่ถูกยกเลิกไปในการส่งเส้นทางแบบสัมพันธ์ไปยัง `render template:`.

*   ลบการสนับสนุนที่ถูกยกเลิกไปในการส่งเส้นทางแบบสัมพันธ์ไปยัง `render file:`.

*   ลบการสนับสนุนสำหรับตัวจัดการเทมเพลตที่ไม่ยอมรับอาร์กิวเมนต์สองตัว.

*   ลบอาร์กิวเมนต์ pattern ที่ถูกยกเลิกไปใน `ActionView::Template::PathResolver`.

*   ลบการสนับสนุนที่ถูกยกเลิกไปในการเรียกใช้เมธอดเอกชนจากวัตถุในบางเฮลเปอร์ของมุมมอง.

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

*   ต้องการให้คลาส `ActionView::Base` ที่สืบทอดมาประมวลผล `#compiled_method_container`.

*   ต้องการอาร์กิวเมนต์ `locals` ใน `ActionView::Template#initialize`.

*   เครื่องมือช่วยการเรียกใช้ `javascript_include_tag` และ `stylesheet_link_tag` สร้าง `Link` header ที่ให้คำแนะนำให้เบราว์เซอร์รุ่นใหม่เกี่ยวกับการโหลดล่วงหน้าของทรัพยากร สามารถปิดการใช้งานได้โดยตั้งค่า `config.action_view.preload_links_header` เป็น `false`.

Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog][action-mailer] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `ActionMailer::Base.receive` ที่ถูกยกเลิกไปในการสนับสนุน [Action Mailbox](https://github.com/rails/rails/tree/6-1-stable/actionmailbox).

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Active Record
-------------

โปรดอ้างอิงที่ [Changelog][active-record] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบเมธอดที่ถูกยกเลิกไปจาก `ActiveRecord::ConnectionAdapters::DatabaseLimits`.

    `column_name_length`
    `table_name_length`
    `columns_per_table`
    `indexes_per_table`
    `columns_per_multicolumn_index`
    `sql_query_length`
    `joins_per_query`

*   ลบ `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_multi_insert?` ที่ถูกยกเลิกไป.

*   ลบ `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_foreign_keys_in_create?` ที่ถูกยกเลิกไป.

*   ลบ `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_ranges?` ที่ถูกยกเลิกไป.

*   ลบ `ActiveRecord::Base#update_attributes` และ `ActiveRecord::Base#update_attributes!` ที่ถูกยกเลิกไป.

*   ลบอาร์กิวเมนต์ `migrations_path` ใน `ActiveRecord::ConnectionAdapter::SchemaStatements#assume_migrated_upto_version` ที่ถูกยกเลิกไป.

*   ลบ `config.active_record.sqlite3.represent_boolean_as_integer` ที่ถูกยกเลิกไป.

*   ลบเมธอดที่ถูกยกเลิกไปจาก `ActiveRecord::DatabaseConfigurations`.

    `fetch`
    `each`
    `first`
    `values`
    `[]=`

*   ลบเมธอด `ActiveRecord::Result#to_hash` ที่ถูกยกเลิกไป.

*   ลบการสนับสนุนที่ถูกยกเลิกไปในการใช้งาน SQL แบบไม่ปลอดภัยในเมธอดของ `ActiveRecord::Relation`.

### การเลิกใช้

*   เลิกใช้ `ActiveRecord::Base.allow_unsafe_raw_sql`.

*   เลิกใช้ `database` kwarg ใน `connected_to`.

*   เลิกใช้ `connection_handlers` เมื่อตั้งค่า `legacy_connection_handling` เป็น false.

### การเปลี่ยนแปลงที่สำคัญ

*   MySQL: ตัวตรวจสอบความเอกลักษณ์ไม่ซ้ำกันสามารถใช้งานกับการเรียงลำดับฐานข้อมูลเริ่มต้นได้แล้ว ไม่ต้องบังคับการเปรียบเทียบที่ใช้ตัวพิมพ์ใหญ่เป็นค่าเริ่มต้น.

*   `relation.create` ไม่ได้รั่วไหลขอบเขตของการค้นหาไปยังเมธอดการค้นหาระดับคลาสในบล็อกการเริ่มต้นและการเรียกใช้งาน.

    ก่อน:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => nil
    end
    ```

    หลัง:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => #<User name: "David", ...>
    end
    ```

*   สเกลชุดของชื่อที่ไม่ได้รั่วไหลไปยังเมธอดการค้นหาระดับคลาส.

    ```ruby
    class User < ActiveRecord::Base
      scope :david, -> { User.where(name: "David") }
    end
    ```

    ก่อน:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'John' AND name = 'David'
    ```

    หลัง:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'David'
    ```

*   `where.not` ตอนนี้สร้างเงื่อนไข NAND แทนที่ NOR.

    ก่อน:
```ruby
User.where.not(name: "Jon", role: "admin")
# SELECT * FROM users WHERE name != 'Jon' AND role != 'admin'
```

หลังจาก:

```ruby
User.where.not(name: "Jon", role: "admin")
# SELECT * FROM users WHERE NOT (name = 'Jon' AND role = 'admin')
```

*   เพื่อใช้การจัดการการเชื่อมต่อฐานข้อมูลแบบใหม่แอปพลิเคชันจำเป็นต้องเปลี่ยน `legacy_connection_handling` เป็น false และลบ accessors ที่ถูกยกเลิกออกจาก `connection_handlers` วิธีการสาธารณะสำหรับ `connects_to` และ `connected_to` ไม่ต้องเปลี่ยนแปลง

Active Storage
--------------

โปรดอ้างอิงที่ [Changelog][active-storage] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการสนับสนุนที่ถูกยกเลิกในการส่ง `:combine_options` ไปยัง `ActiveStorage::Transformers::ImageProcessing`.

*   ลบ `ActiveStorage::Transformers::MiniMagickTransformer` ที่ถูกยกเลิก.

*   ลบ `config.active_storage.queue` ที่ถูกยกเลิก.

*   ลบ `ActiveStorage::Downloading` ที่ถูกยกเลิก.

### การเลิกใช้

*   เลิกใช้ `Blob.create_after_upload` และใช้ `Blob.create_and_upload` แทน.
    ([Pull Request](https://github.com/rails/rails/pull/34827))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม `Blob.create_and_upload` เพื่อสร้าง blob ใหม่และอัปโหลด `io` ที่กำหนดให้กับบริการ.
    ([Pull Request](https://github.com/rails/rails/pull/34827))
*   เพิ่มคอลัมน์ `service_name` ใน `ActiveStorage::Blob` จำเป็นต้องรันการเปลี่ยนแปลงหลังจากการอัปเกรด รัน `bin/rails app:update` เพื่อสร้างการเปลี่ยนแปลงนั้น

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

*   ข้อผิดพลาดของ Active Model เป็นวัตถุที่มีอินเทอร์เฟซที่ช่วยให้แอปพลิเคชันของคุณสามารถจัดการและตอบสนองกับข้อผิดพลาดที่โยนออกจากโมเดลได้อย่างง่ายดายมากขึ้น
    [คุณลักษณะ](https://github.com/rails/rails/pull/32313) รวมถึงอินเทอร์เฟซการค้นหา การทดสอบที่แม่นยำมากขึ้น และการเข้าถึงรายละเอียดข้อผิดพลาด

Active Support
--------------

โปรดอ้างอิงที่ [Changelog][active-support] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการย้อนกลับไปใช้ `I18n.default_locale` เมื่อ `config.i18n.fallbacks` ว่างเปล่า.

*   ลบค่าคงที่ `LoggerSilence` ที่ถูกยกเลิก.

*   ลบ `ActiveSupport::LoggerThreadSafeLevel#after_initialize` ที่ถูกยกเลิก.

*   ลบเมธอด `Module#parent_name`, `Module#parent` และ `Module#parents` ที่ถูกยกเลิก.

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/module/reachable`.

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/numeric/inquiry`.

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/array/prepend_and_append`.

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/hash/compact`.

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/hash/transform_values`.

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/range/include_range`.

*   ลบ `ActiveSupport::Multibyte::Chars#consumes?` และ `ActiveSupport::Multibyte::Chars#normalize` ที่ถูกยกเลิก.

*   ลบ `ActiveSupport::Multibyte::Unicode.pack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.unpack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.normalize`,
    `ActiveSupport::Multibyte::Unicode.downcase`,
    `ActiveSupport::Multibyte::Unicode.upcase` และ `ActiveSupport::Multibyte::Unicode.swapcase` ที่ถูกยกเลิก.

*   ลบ `ActiveSupport::Notifications::Instrumenter#end=` ที่ถูกยกเลิก.

### การเลิกใช้

*   เลิกใช้ `ActiveSupport::Multibyte::Unicode.default_normalization_form`.

### การเปลี่ยนแปลงที่สำคัญ

Active Job
----------

โปรดอ้างอิงที่ [Changelog][active-job] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

*   เลิกใช้ `config.active_job.return_false_on_aborted_enqueue`.

### การเปลี่ยนแปลงที่สำคัญ

*   ส่งค่า `false` เมื่อการเพิ่มงานในคิวถูกยกเลิก

Action Text
----------

โปรดอ้างอิงที่ [Changelog][action-text] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มเมธอดเพื่อยืนยันความมีอยู่ของเนื้อหา rich text โดยเพิ่ม `?` หลังจากชื่อแอตทริบิวต์ rich text.
    ([Pull Request](https://github.com/rails/rails/pull/37951))

*   เพิ่ม `fill_in_rich_text_area` เป็นตัวช่วยทดสอบระบบที่ช่วยให้ค้นหาตัวแก้ไข trix และเติมเนื้อหา HTML ที่กำหนดให้.
    ([Pull Request](https://github.com/rails/rails/pull/35885))

*   เพิ่ม `ActionText::FixtureSet.attachment` เพื่อสร้างองค์ประกอบ `<action-text-attachment>` ใน fixture ของฐานข้อมูล.
    ([Pull Request](https://github.com/rails/rails/pull/40289))

Action Mailbox
----------

โปรดอ้างอิงที่ [Changelog][action-mailbox] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

*   เลิกใช้ `Rails.application.credentials.action_mailbox.api_key` และ `MAILGUN_INGRESS_API_KEY` และใช้ `Rails.application.credentials.action_mailbox.signing_key` และ `MAILGUN_INGRESS_SIGNING_KEY` แทน.

### การเปลี่ยนแปลงที่สำคัญ

Ruby on Rails Guides
--------------------

โปรดอ้างอิงที่ [Changelog][guides] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

Credits
-------

ดู
[รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](https://contributors.rubyonrails.org/)
สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการทำให้ Rails เป็นเฟรมเวิร์กที่เสถียรและทนทาน ยินดีกับทุกคน
[active-storage]: https://github.com/rails/rails/blob/6-1-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-1-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/6-1-stable/actionmailbox/CHANGELOG.md
