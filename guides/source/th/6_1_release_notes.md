**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 1d652e6ccda9c901ca3f6a003c95f83e
เอกสารปล่อยตัวของ Ruby on Rails 6.1
===============================

จุดเด่นใน Rails 6.1:

* การสลับการเชื่อมต่อตามฐานข้อมูล
* การแบ่งแยกแนวนอน
* การโหลดการเชื่อมต่อแบบเข้มงวด
* ประเภทที่ได้รับการมอบหมาย
* การทำลายการเชื่อมต่อแบบ Async

เอกสารปล่อยตัวนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่าง ๆ โปรดอ้างอิงที่เอกสารเปลี่ยนแปลงหรือตรวจสอบ [รายการของการเปลี่ยนแปลง](https://github.com/rails/rails/commits/6-1-stable) ในเก็บรวบรวม Rails หลักบน GitHub

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 6.1
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 6.0 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 6.1 มีรายการสิ่งที่ควรระมัดระวังเมื่ออัปเกรดใน [การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-0-to-rails-6-1) ไกด์

คุณสมบัติหลัก
--------------

### การสลับการเชื่อมต่อตามฐานข้อมูล

Rails 6.1 จะให้คุณสามารถ [สลับการเชื่อมต่อตามฐานข้อมูลได้ตามฐานข้อมูล](https://github.com/rails/rails/pull/40370) ในรุ่น 6.0 หากคุณสลับไปยังบทบาท "การอ่าน" แล้วการเชื่อมต่อฐานข้อมูลทั้งหมดก็จะสลับไปยังบทบาทการอ่าน ตอนนี้ในรุ่น 6.1 หากคุณตั้งค่า `legacy_connection_handling` เป็น `false` ในการกำหนดค่าของคุณ  Rails จะอนุญาตให้คุณสลับการเชื่อมต่อสำหรับฐานข้อมูลเดียวโดยเรียกใช้ `connected_to` บนคลาสแบบนามธรรมที่เกี่ยวข้อง

### การแบ่งแยกแนวนอน

Rails 6.0 มีความสามารถในการแบ่งแยกฟังก์ชัน (พาร์ติชันหลาย ๆ รูปแบบแตกต่างกัน) ในฐานข้อมูลของคุณ แต่ไม่สามารถรองรับการแบ่งแยกแนวนอน (รูปแบบเดียวกัน พาร์ติชันหลาย ๆ รูปแบบ) ได้ Rails ไม่สามารถรองรับการแบ่งแยกแนวนอนได้เนื่องจากโมเดลใน Active Record สามารถมีการเชื่อมต่อเพียงหนึ่งต่อบทบาทต่อคลาสเท่านั้น ปัญหานี้ได้รับการแก้ไขและ [การแบ่งแยกแนวนอน](https://github.com/rails/rails/pull/38531) กับ Rails พร้อมใช้งาน

### การโหลดการเชื่อมต่อแบบเข้มงวด

[การโหลดการเชื่อมต่อแบบเข้มงวด](https://github.com/rails/rails/pull/37400) ช่วยให้คุณสามารถให้แน่ใจได้ว่าการเชื่อมต่อทั้งหมดของคุณถูกโหลดล่วงหน้าและหยุด N+1 ก่อนที่จะเกิดขึ้น

### ประเภทที่ได้รับการมอบหมาย

[ประเภทที่ได้รับการมอบหมาย](https://github.com/rails/rails/pull/39341) เป็นทางเลือกสำหรับการสืบทอดแบบตารางเดียว สิ่งนี้ช่วยให้สามารถแสดงชั้นสูงให้เป็นคลาสที่เป็นรูปแบบที่เป็นตัวเองที่ถูกแทนด้วยตารางของตัวเอง แต่ลูกคลาสแต่ละคลาสมีตารางของตัวเองสำหรับแอตทริบิวต์เพิ่มเติม

### การทำลายการเชื่อมต่อแบบ Async

[การทำลายการเชื่อมต่อแบบ Async](https://github.com/rails/rails/pull/40157) เพิ่มความสามารถให้แอปพลิเคชันสามารถ `ทำลาย` การเชื่อมต่อในงานพื้นหลังได้ สิ่งนี้ช่วยให้คุณหลีกเลี่ยงการหมดเวลาและปัญหาประสิทธิภาพอื่น ๆ ในแอปพลิเคชันของคุณเมื่อทำลายข้อมูล

Railties
--------

โปรดอ้างอิงที่ [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบงานที่ถูกยกเลิก `rake notes`.

*   ลบตัวเลือก `connection` ที่ถูกยกเลิกในคำสั่ง `rails dbconsole`.

*   ลบการสนับสนุนตัวแปรสภาพแวดล้อม `SOURCE_ANNOTATION_DIRECTORIES` ที่ถูกยกเลิกจาก `rails notes`.

*   ลบอาร์กิวเมนต์ `server` ที่ถูกยกเลิกจากคำสั่ง rails server.

*   ลบการสนับสนุนที่ถูกยกเลิกในการใช้ตัวแปรสภาพแวดล้อม `HOST` เพื่อระบุ IP เซิร์ฟเวอร์.

*   ลบงานที่ถูกยกเลิก `rake dev:cache`.

*   ลบงานที่ถูกยกเลิก `rake routes`.

*   ลบงานที่ถูกยกเลิก `rake initializers`.

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

*   ลบ `ActionDispatch::Http::ParameterFilter` ที่ถูกยกเลิก

*   ลบ `force_ssl` ที่ระดับคอนโทรลเลอร์ที่ถูกยกเลิก

### การเลิกใช้

*   เลิกใช้ `config.action_dispatch.return_only_media_type_on_content_type`.

### การเปลี่ยนแปลงที่สำคัญ

*   เปลี่ยน `ActionDispatch::Response#content_type` เพื่อให้ส่งคืนเฮดเดอร์ Content-Type ทั้งหมด

Action View
-----------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `escape_whitelist` จาก `ActionView::Template::Handlers::ERB`.

*   ลบ `find_all_anywhere` จาก `ActionView::Resolver`.

*   ลบ `formats` จาก `ActionView::Template::HTML`.

*   ลบ `formats` จาก `ActionView::Template::RawFile`.

*   ลบ `formats` จาก `ActionView::Template::Text`.

*   ลบ `find_file` จาก `ActionView::PathSet`.

*   ลบ `rendered_format` จาก `ActionView::LookupContext`.

*   ลบ `find_file` จาก `
*   ลบ `ActionView::Template#formats` ที่ถูกยกเลิกแล้ว

*   ลบ `ActionView::Template#virtual_path=` ที่ถูกยกเลิกแล้ว

*   ลบ `ActionView::Template#updated_at` ที่ถูกยกเลิกแล้ว

*   ลบ `updated_at` argument ที่ต้องการใน `ActionView::Template#initialize` ที่ถูกยกเลิกแล้ว

*   ลบ `ActionView::Template.finalize_compiled_template_methods` ที่ถูกยกเลิกแล้ว

*   ลบ `config.action_view.finalize_compiled_template_methods` ที่ถูกยกเลิกแล้ว

*   ลบการสนับสนุนที่ถูกยกเลิกในการเรียกใช้ `ActionView::ViewPaths#with_fallback` ด้วยบล็อก

*   ลบการสนับสนุนที่ถูกยกเลิกในการส่งพาธแบบสัมพันธ์ไปยัง `render template:`

*   ลบการสนับสนุนที่ถูกยกเลิกในการส่งพาธที่สัมพันธ์ไปยัง `render file:`

*   ลบการสนับสนุนในการใช้งาน template handlers ที่ไม่ยอมรับอาร์กิวเมนต์สองตัว

*   ลบการสนับสนุนที่ถูกยกเลิกในการใช้งาน pattern argument ใน `ActionView::Template::PathResolver`

*   ลบการสนับสนุนที่ถูกยกเลิกในการเรียกใช้งานเมธอดเป็นส่วนตัวจากอ็อบเจ็กต์ในเฮลเปอร์บายวิวบางอย่าง

### การเลิกใช้งาน

### การเปลี่ยนแปลงที่สำคัญ

*   กำหนดให้คลาส `ActionView::Base` ที่สืบทอดมาต้องประมวลผล `#compiled_method_container`

*   ทำให้ `locals` argument เป็นสิ่งที่จำเป็นใน `ActionView::Template#initialize`

*   เครื่องมือช่วยทรัพยากร `javascript_include_tag` และ `stylesheet_link_tag` สร้าง `Link` header ที่ให้คำแนะนำให้เบราว์เซอร์รุ่นใหม่เกี่ยวกับการโหลดทรัพยากรได้ สามารถปิดการใช้งานได้โดยตั้งค่า `config.action_view.preload_links_header` เป็น `false`

Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog][action-mailer] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเอาออก

*   ลบ `ActionMailer::Base.receive` ที่ถูกยกเลิกแล้วและใช้ [Action Mailbox](https://github.com/rails/rails/tree/6-1-stable/actionmailbox) แทน

### การเลิกใช้งาน

### การเปลี่ยนแปลงที่สำคัญ

Active Record
-------------

โปรดอ้างอิงที่ [Changelog][active-record] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเอาออก

*   ลบเมธอดที่ถูกยกเลิกจาก `ActiveRecord::ConnectionAdapters::DatabaseLimits`

    `column_name_length`
    `table_name_length`
    `columns_per_table`
    `indexes_per_table`
    `columns_per_multicolumn_index`
    `sql_query_length`
    `joins_per_query`

*   ลบ `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_multi_insert?` ที่ถูกยกเลิกแล้ว

*   ลบ `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_foreign_keys_in_create?` ที่ถูกยกเลิกแล้ว

*   ลบ `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_ranges?` ที่ถูกยกเลิกแล้ว

*   ลบ `ActiveRecord::Base#update_attributes` และ `ActiveRecord::Base#update_attributes!` ที่ถูกยกเลิกแล้ว

*   ลบอาร์กิวเมนต์ `migrations_path` ที่ถูกยกเลิกใน `ActiveRecord::ConnectionAdapter::SchemaStatements#assume_migrated_upto_version`

*   ลบ `config.active_record.sqlite3.represent_boolean_as_integer` ที่ถูกยกเลิกแล้ว

*   ลบเมธอดที่ถูกยกเลิกจาก `ActiveRecord::DatabaseConfigurations`

    `fetch`
    `each`
    `first`
    `values`
    `[]=`

*   ลบเมธอด `ActiveRecord::Result#to_hash` ที่ถูกยกเลิกแล้ว

*   ลบการสนับสนุนที่ถูกยกเลิกในการใช้งาน SQL แบบ raw ที่ไม่ปลอดภัยในเมธอดของ `ActiveRecord::Relation`

### การเลิกใช้งาน

*   เลิกใช้งาน `ActiveRecord::Base.allow_unsafe_raw_sql`

*   เลิกใช้งาน `database` kwarg ใน `connected_to`

*   เลิกใช้งาน `connection_handlers` เมื่อตั้งค่า `legacy_connection_handling` เป็น false

### การเปลี่ยนแปลงที่สำคัญ

*   MySQL: ตัวตรวจสอบความเอกลักษณ์ไม่ซ้ำกันสามารถใช้งานกับการเปรียบเทียบตัวเริ่มต้นของฐานข้อมูลได้แล้ว ไม่ต้องบังคับการเปรียบเทียบที่ตรงตามตัวอักษรเริ่มต้น

*   `relation.create` ไม่ได้รั่วไหลขอบเขตของขอบเขตการสอบถามระดับคลาสไปยังเมธอดการสอบถามระดับคลาสในบล็อกการเริ่มต้นและการเรียกใช้งาน

    ก่อนหน้า:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => nil
    end
    ```

    หลังจาก:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => #<User name: "David", ...>
    end
    ```

*   การเชื่อมโยงชื่อที่ตั้งชื่อไม่ได้รั่วไหลขอบเขตของขอบเขตการสอบถามระดับคลาส

    ```ruby
    class User < ActiveRecord::Base
      scope :david, -> { User.where(name: "David") }
    end
    ```

    ก่อนหน้า:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'John' AND name = 'David'
    ```

    หลังจาก:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'David'
    ```

*   `where.not` ตอนนี้สร้างเงื่อนไข NAND แทนที่ NOR

    ก่อนหน้า:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE name != 'Jon' AND role != 'admin'
    ```

    หลังจาก:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE NOT (name = 'Jon' AND role = 'admin')
    ```

*   เพื่อใช้การจัดการเชื่อมต่อฐานข้อมูลตามแต่ละฐานข้อมูลใหม่ แอปพลิเคชันต้องเปลี่ยน `legacy_connection_handling` เป็น false และลบ accessors ที่ถูกยกเลิกออกจาก `connection_handlers`  เมธอดสาธารณะสำหรับ `connects_to` และ `connected_to` ไม่ต้องเปลี่ยนแปลง

Active Storage
--------------

โปรดอ้างอิงที่ [Changelog][active-storage] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเอาออก

*   ลบการสนับสนุนที่ถูกยกเลิกในการส่ง `:combine_options` operations ไปยัง `ActiveStorage::Transformers::ImageProcessing`

*   ลบ `ActiveStorage::Transformers::MiniMagickTransformer` ที่ถูกยกเลิกแล้ว

*   ลบ `config.active_storage.queue` ที่
Active Support
--------------

โปรดอ้างอิงที่ [Changelog][active-support] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการใช้งานที่ถูกยกเลิก fallback ไปยัง `I18n.default_locale` เมื่อ `config.i18n.fallbacks` ว่างเปล่า

*   ลบค่าคงที่ `LoggerSilence` ที่ถูกยกเลิก

*   ลบ `ActiveSupport::LoggerThreadSafeLevel#after_initialize` ที่ถูกยกเลิก

*   ลบ `Module#parent_name`, `Module#parent` และ `Module#parents` ที่ถูกยกเลิก

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/module/reachable`

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/numeric/inquiry`

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/array/prepend_and_append`

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/hash/compact`

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/hash/transform_values`

*   ลบไฟล์ที่ถูกยกเลิก `active_support/core_ext/range/include_range`

*   ลบ `ActiveSupport::Multibyte::Chars#consumes?` และ `ActiveSupport::Multibyte::Chars#normalize` ที่ถูกยกเลิก

*   ลบ `ActiveSupport::Multibyte::Unicode.pack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.unpack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.normalize`,
    `ActiveSupport::Multibyte::Unicode.downcase`,
    `ActiveSupport::Multibyte::Unicode.upcase` และ `ActiveSupport::Multibyte::Unicode.swapcase` ที่ถูกยกเลิก

*   ลบ `ActiveSupport::Notifications::Instrumenter#end=` ที่ถูกยกเลิก

### การเลิกใช้งาน

*   เลิกใช้งาน `ActiveSupport::Multibyte::Unicode.default_normalization_form`

### การเปลี่ยนแปลงที่สำคัญ

Active Job
----------

โปรดอ้างอิงที่ [Changelog][active-job] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้งาน

*   เลิกใช้งาน `config.active_job.return_false_on_aborted_enqueue`

### การเปลี่ยนแปลงที่สำคัญ

*   คืนค่า `false` เมื่อการเพิ่มงานในคิวถูกยกเลิก

Action Text
----------

โปรดอ้างอิงที่ [Changelog][action-text] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้งาน

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มเมธอดเพื่อยืนยันการมีเนื้อหา rich text โดยการเพิ่ม `?` หลังจากชื่อแอตทริบิวต์ rich text
    ([Pull Request](https://github.com/rails/rails/pull/37951))

*   เพิ่ม `fill_in_rich_text_area` เป็นตัวช่วยในการทดสอบระบบเพื่อค้นหาตัวแก้ไข trix และเติมเนื้อหา HTML ที่กำหนดให้
    ([Pull Request](https://github.com/rails/rails/pull/35885))

*   เพิ่ม `ActionText::FixtureSet.attachment` เพื่อสร้างองค์ประกอบ `<action-text-attachment>` ใน fixture ของฐานข้อมูล
    ([Pull Request](https://github.com/rails/rails/pull/40289))

Action Mailbox
----------

โปรดอ้างอิงที่ [Changelog][action-mailbox] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้งาน

*   เลิกใช้งาน `Rails.application.credentials.action_mailbox.api_key` และ `MAILGUN_INGRESS_API_KEY` ในการสนับสนุน `Rails.application.credentials.action_mailbox.signing_key` และ `MAILGUN_INGRESS_SIGNING_KEY`

### การเปลี่ยนแปลงที่สำคัญ

Ruby on Rails Guides
--------------------

โปรดอ้างอิงที่ [Changelog][guides] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

เครดิต
-------

ดูรายชื่อเต็มของผู้มีส่วนร่วมใน Rails ได้ที่
[รายชื่อผู้มีส่วนร่วมใน Rails](https://contributors.rubyonrails.org/)
สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและทนทาน ยินดีด้วยทุกคน

[railties]:       https://github.com/rails/rails/blob/6-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-1-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/6-1-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-1-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-1-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-1-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/6-1-stable/actionmailbox/CHANGELOG.md
