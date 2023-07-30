**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e9aa14ccbfd8f02fea6c1b061215332c
เอกสารปล่อยตัวของ Ruby on Rails 7.0
===============================

จุดเด่นใน Rails 7.0:

* ต้องใช้ Ruby 2.7.0+ ขึ้นไป, และแนะนำให้ใช้ Ruby 3.0+ 

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 7.0
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่แล้ว ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดไปยัง Rails 6.1 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานได้ตามที่คาดหวังก่อนที่จะพยายามอัปเดตไปยัง Rails 7.0 มีรายการสิ่งที่ควรระวังเมื่ออัปเกรดใน
[การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0)
คู่มือ

คุณลักษณะหลัก
--------------

Railties
--------

โปรดอ้างอิงที่ [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `config` ที่ถูกเลิกใช้ใน `dbconsole`.

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

*   Sprockets เป็นลักษณะที่เลือกได้แล้ว

    เจม `rails` ไม่ได้ขึ้นอยู่กับ `sprockets-rails` อีกต่อไป หากแอปพลิเคชันของคุณยังต้องการใช้ Sprockets
    ตรวจสอบให้แน่ใจว่าเพิ่ม `sprockets-rails` เข้าไปใน Gemfile ของคุณ

    ```
    gem "sprockets-rails"
    ```

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

*   ลบ `ActionDispatch::Response.return_only_media_type_on_content_type` ที่ถูกเลิกใช้.

*   ลบ `Rails.config.action_dispatch.hosts_response_app` ที่ถูกเลิกใช้.

*   ลบ `ActionDispatch::SystemTestCase#host!` ที่ถูกเลิกใช้.

*   ลบการสนับสนุนที่ถูกเลิกใช้ในการส่ง `fixture_file_upload` ที่เกี่ยวข้องกับ `fixture_path`.

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Action View
-----------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `Rails.config.action_view.raise_on_missing_translations` ที่ถูกเลิกใช้.

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

*  `button_to` สร้าง HTTP verb [method] จากออบเจกต์ Active Record หากใช้ออบเจกต์เพื่อสร้าง URL

    ```ruby
    button_to("Do a POST", [:do_post_action, Workshop.find(1)])
    # ก่อนหน้านี้
    #=>   <input type="hidden" name="_method" value="post" autocomplete="off" />
    # ต่อมา
    #=>   <input type="hidden" name="_method" value="patch" autocomplete="off" />
    ```

Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog][action-mailer] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `ActionMailer::DeliveryJob` และ `ActionMailer::Parameterized::DeliveryJob`
    เพื่อใช้แทน `ActionMailer::MailDeliveryJob`.

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Active Record
-------------

โปรดอ้างอิงที่ [Changelog][active-record] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `database` kwarg จาก `connected_to`.

*   ลบ `ActiveRecord::Base.allow_unsafe_raw_sql` ที่ถูกเลิกใช้.

*   ลบตัวเลือก `:spec_name` ที่ถูกเลิกใช้ในเมธอด `configs_for`.

*   ลบการสนับสนุนที่ถูกเลิกใช้ในการโหลด YAML `ActiveRecord::Base` instance ในรูปแบบ Rails 4.2 และ 4.1.

*   ลบการเตือนที่ถูกเลิกใช้เมื่อใช้คอลัมน์ `:interval` ในฐานข้อมูล PostgreSQL.

    ตอนนี้คอลัมน์ interval จะส่งกลับเป็นออบเจกต์ `ActiveSupport::Duration` แทนสตริง

    หากต้องการเก็บพฤติกรรมเดิม คุณสามารถเพิ่มบรรทัดนี้ในโมเดลของคุณ:

    ```ruby
    attribute :column, :string
    ```

*   ลบการสนับสนุนที่ถูกเลิกใช้ในการแก้ไขการเชื่อมต่อโดยใช้ `"primary"` เป็นชื่อการกำหนดการเชื่อมต่อ.

*   ลบการสนับสนุนที่ถูกเลิกใช้ในการคำนวณค่าให้กับออบเจกต์ `ActiveRecord::Base`.

*   ลบการสนับสนุนที่ถูกเลิกใช้ในการแปลงชนิดของออบเจกต์ `ActiveRecord::Base` เป็นค่าในฐานข้อมูล.

*   ลบการสนับสนุนที่ถูกเลิกใช้ในการส่งคอลัมน์ไปยัง `type_cast`.

*   ลบเมธอด `DatabaseConfig#config` ที่ถูกเลิกใช้.

*   ลบ rake tasks ที่ถูกเลิกใช้:

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

*   ลบการสนับสนุนที่ถูกเลิกใช้ในการค้นหาโดยใช้ `Model.reorder(nil).first` โดยใช้ลำดับที่ไม่แน่นอน.

*   ลบอาร์กิวเมนต์ `environment` และ `name` จาก `Tasks::DatabaseTasks.schema_up_to_date?` ที่ถูกเลิกใช้.

*   ลบ `Tasks::DatabaseTasks.dump_filename` ที่ถูกเลิกใช้.

*   ลบ `Tasks::DatabaseTasks.schema_file` ที่ถูกเลิกใช้.

*   ลบ `Tasks::DatabaseTasks.spec` ที่ถูกเลิกใช้.

*   ลบ `Tasks::DatabaseTasks.current_config` ที่ถูกเลิกใช้.

*   ลบ `ActiveRecord::Connection#allowed_index_name_length` ที่ถูกเลิกใช้.
*   ลบ `ActiveRecord::Connection#in_clause_length` ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name` ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveRecord::Base.connection_config` ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveRecord::Base.arel_attribute` ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveRecord::Base.configurations.default_hash` ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveRecord::Base.configurations.to_h` ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveRecord::Result#map!` และ `ActiveRecord::Result#collect!` ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveRecord::Base#remove_connection` ที่ถูกยกเลิกไปแล้ว

### การเลิกใช้

*   เลิกใช้ `Tasks::DatabaseTasks.schema_file_type` 

### การเปลี่ยนแปลงที่สำคัญ

*   ยกเลิกการทำธุรกรรมเมื่อบล็อกส่งคืนก่อนที่คาดไว้

    ก่อนการเปลี่ยนแปลงนี้เมื่อบล็อกธุรกรรมส่งคืนก่อนเวลาที่คาดไว้ ธุรกรรมจะถูกยืนยัน

    ปัญหาคือเมื่อเกิดเวลาหมดอายุภายในบล็อกธุรกรรม ธุรกรรมที่ไม่สมบูรณ์จะถูกยืนยัน ดังนั้นเพื่อหลีกเลี่ยงข้อผิดพลาดนี้ บล็อกธุรกรรมจะถูกย้อนกลับ

*   การผสานเงื่อนไขในคอลัมน์เดียวกันไม่ได้รักษาทั้งสองเงื่อนไขและจะถูกแทนที่ด้วยเงื่อนไขที่หลัง

    ```ruby
    # Rails 6.1 (IN clause is replaced by merger side equality condition)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    # Rails 6.1 (both conflict conditions exists, deprecated)
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => []
    # Rails 6.1 with rewhere to migrate to Rails 7.0's behavior
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob), rewhere: true) # => [bob]
    # Rails 7.0 (same behavior with IN clause, mergee side condition is consistently replaced)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => [bob]
    ```

Active Storage
--------------

โปรดอ้างอิงที่ [Changelog][active-storage] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการเลือก `ActiveModel::Errors` instances เป็น Hash ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveModel::Errors#to_h` ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveModel::Errors#slice!` ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveModel::Errors#values` ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveModel::Errors#keys` ที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveModel::Errors#to_xml` ที่ถูกยกเลิกไปแล้ว

*   ลบการรวมข้อผิดพลาดไปยัง `ActiveModel::Errors#messages` ที่ถูกยกเลิกไปแล้ว

*   ลบการรองรับการ `clear` ข้อผิดพลาดจาก `ActiveModel::Errors#messages` ที่ถูกยกเลิกไปแล้ว

*   ลบการรองรับการ `delete` ข้อผิดพลาดจาก `ActiveModel::Errors#messages` ที่ถูกยกเลิกไปแล้ว

*   ลบการรองรับการใช้ `[]=` ใน `ActiveModel::Errors#messages` ที่ถูกยกเลิกไปแล้ว

*   ลบการรองรับการ Marshal และ YAML load รูปแบบข้อผิดพลาดของ Rails 5.x

*   ลบการรองรับการ Marshal load รูปแบบ `ActiveModel::AttributeSet` ของ Rails 5.x

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Active Support
--------------

โปรดอ้างอิงที่ [Changelog][active-support] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `config.active_support.use_sha1_digests` ที่ถูกยกเลิกไปแล้ว

*   ลบ `URI.parser` ที่ถูกยกเลิกไปแล้ว

*   ลบการรองรับการใช้ `Range#include?` เพื่อตรวจสอบการรวมของค่าในช่วงวันที่และเวลาที่ถูกยกเลิกไปแล้ว

*   ลบ `ActiveSupport::Multibyte::Unicode.default_normalization_form` ที่ถูกยกเลิกไปแล้ว

### การเลิกใช้

*   เลิกใช้การส่งรูปแบบไปยัง `#to_s` ในการใช้งาน `Array`, `Range`, `Date`, `DateTime`, `Time`,
    `BigDecimal`, `Float` และ `Integer` และใช้ `#to_fs` แทน

    การเลิกใช้นี้เพื่อให้แอปพลิเคชัน Rails ใช้ประโยชน์จากการปรับปรุงใน Ruby 3.1
    [การปรับปรุง](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44) ที่ทำให้
    การตัดต่อของบางประเภทของวัตถุเร็วขึ้น

    แอปพลิเคชันใหม่จะไม่มีการแทนที่เมธอด `#to_s` ในคลาสเหล่านั้น แอปพลิเคชันที่มีอยู่สามารถใช้
    `config.active_support.disable_to_s_conversion` ได้

### การเปลี่ยนแปลงที่สำคัญ

Active Job
----------

โปรดอ้างอิงที่ [Changelog][active-job] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบพฤติกรรมที่ถูกยกเลิกไปแล้วที่ไม่ได้หยุด `after_enqueue`/`after_perform` callbacks เมื่อ
    การเรียก callback ก่อนหน้านั้นถูกหยุดด้วย `throw :abort`

*   ลบ `:return_false_on_aborted_enqueue` option ที่ถูกยกเลิกไปแล้ว

### การเลิกใช้

*   เลิกใช้ `Rails.config.active_job.skip_after_callbacks_if_terminated` 

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

การลบ

- ลบ `Rails.application.credentials.action_mailbox.mailgun_api_key` ที่ถูกยกเลิกไปแล้ว
- ลบตัวแปรสภาพแวดล้อมที่ถูกยกเลิกไปแล้ว `MAILGUN_INGRESS_API_KEY`

การเลิกใช้

การเปลี่ยนแปลงที่สำคัญ

Ruby on Rails Guides
--------------------

โปรดอ้างอิงที่ [Changelog][guides] สำหรับการเปลี่ยนแปลงที่ละเอียด

การเปลี่ยนแปลงที่สำคัญ

เครดิต

ดูรายชื่อเต็มของผู้มีส่วนร่วมใน Rails ได้ที่
[รายชื่อผู้มีส่วนร่วมใน Rails](https://contributors.rubyonrails.org/)
สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์คที่เสถียรและทนทาน ยินดีด้วยทุกคน

[railties]:       https://github.com/rails/rails/blob/7-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/7-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/7-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/7-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/7-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/7-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/7-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/7-0-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/7-0-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/7-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/7-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/7-0-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/7-0-stable/actionmailbox/CHANGELOG.md
