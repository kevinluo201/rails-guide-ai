**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e9aa14ccbfd8f02fea6c1b061215332c
เอกสารปล่อยตัวของ Ruby on Rails 7.0
===============================

จุดเด่นใน Rails 7.0:

* ต้องใช้ Ruby 2.7.0+ ขึ้นไป, แนะนำให้ใช้ Ruby 3.0+ 

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 7.0
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 6.1 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานได้ตามที่คาดหวังก่อนที่จะพยายามอัปเดตไปยัง Rails 7.0 มีรายการสิ่งที่ควรระวังเมื่ออัปเกรดใน
[การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0)
คู่มือ

คุณสมบัติหลัก
--------------

Railties
--------

โปรดอ้างอิงที่ [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `config` ที่ถูกยกเลิกใน `dbconsole`.

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

*   Sprockets เป็นความลับที่เลือกได้

    แพ็กเกจ `rails` ไม่ได้ขึ้นอยู่กับ `sprockets-rails` อีกต่อไป หากแอปพลิเคชันของคุณยังต้องการใช้ Sprockets
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

*   ลบ `ActionDispatch::Response.return_only_media_type_on_content_type` ที่ถูกยกเลิก.

*   ลบ `Rails.config.action_dispatch.hosts_response_app` ที่ถูกยกเลิก.

*   ลบ `ActionDispatch::SystemTestCase#host!` ที่ถูกยกเลิก.

*   ลบการสนับสนุนที่ถูกยกเลิกในการส่ง `fixture_file_upload` ที่เกี่ยวข้องกับ `fixture_path`.

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Action View
-----------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `Rails.config.action_view.raise_on_missing_translations` ที่ถูกยกเลิก.

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

*  `button_to` สร้าง HTTP verb [method] จากออบเจกต์ Active Record หากใช้ออบเจกต์ในการสร้าง URL

    ```ruby
    button_to("Do a POST", [:do_post_action, Workshop.find(1)])
    # ก่อนหน้านี้
    #=>   <input type="hidden" name="_method" value="post" autocomplete="off" />
    # หลังจากนี้
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

*   ลบ `database` kwarg จาก `connected_to` ที่ถูกยกเลิก.

*   ลบ `ActiveRecord::Base.allow_unsafe_raw_sql` ที่ถูกยกเลิก.

*   ลบตัวเลือก `:spec_name` ที่ถูกยกเลิกในเมธอด `configs_for`.

*   ลบการสนับสนุนที่ถูกยกเลิกในการโหลด YAML `ActiveRecord::Base` instance ในรูปแบบของ Rails 4.2 และ 4.1.

*   ลบการเตือนที่ถูกยกเลิกเมื่อใช้คอลัมน์ `:interval` ในฐานข้อมูล PostgreSQL.

    ตอนนี้คอลัมน์ interval จะส่งกลับเป็นออบเจกต์ `ActiveSupport::Duration` แทนสตริง

    เพื่อให้รักษาพฤติกรรมเดิม คุณสามารถเพิ่มบรรทัดนี้ในโมเดลของคุณ:

    ```ruby
    attribute :column, :string
    ```

*   ลบการสนับสนุนที่ถูกยกเลิกในการแก้ไขการเชื่อมต่อโดยใช้ `"primary"` เป็นชื่อการกำหนดการเชื่อมต่อ.

*   ลบการสนับสนุนที่ถูกยกเลิกในการเความ `ActiveRecord::Base` objects.

*   ลบการสนับสนุนที่ถูกยกเลิกในการแปลงชนิดของค่าฐานข้อมูล `ActiveRecord::Base` objects.

*   ลบการสนับสนุนที่ถูกยกเลิกในการส่งคอลัมน์ไปยัง `type_cast`.

*   ลบเมธอด `DatabaseConfig#config` ที่ถูกยกเลิก.

*   ลบงาน rake ที่ถูกยกเลิก:

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

*   ลบการสนับสนุนที่ถูกยกเลิกในการค้นหาโดยใช้ `Model.reorder(nil).first` ด้วยการเรียงลำดับที่ไม่แน่นอน.

*   ลบอาร์กิวเมนต์ `environment` และ `name` จาก `Tasks::DatabaseTasks.schema_up_to_date?` ที่ถูกยกเลิก.

*   ลบ `Tasks::DatabaseTasks.dump_filename` ที่ถูกยกเลิก.

*   ลบ `Tasks::DatabaseTasks.schema_file` ที่ถูกยกเลิก.

*   ลบ `Tasks::DatabaseTasks.spec` ที่ถูกยกเลิก.

*   ลบ `Tasks::DatabaseTasks.current_config` ที่ถูกยกเลิก.

*   ลบ `ActiveRecord::Connection#allowed_index_name_length` ที่ถูกยกเลิก.

*   ลบ `ActiveRecord::Connection#in_clause_length` ที่ถูกยกเลิก.

*   ลบ `ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name` ที่ถูกยกเลิก.

*   ลบ `ActiveRecord::Base.connection_config` ที่ถูกยกเลิก.

*   ลบ `ActiveRecord::Base.arel_attribute` ที่ถูกยกเลิก.

*   ลบ `ActiveRecord::Base.configurations.default_hash` ที่ถูกยกเลิก.

*   ลบ `ActiveRecord::Base.configurations.to_h` ที่ถูกยกเลิก.

*   ลบ `ActiveRecord::Result#map!` และ `ActiveRecord::Result#collect!` ที่ถูกยกเลิก.

*   ลบ `ActiveRecord::Base#remove_connection` ที่ถูกยกเลิก.

### การเลิกใช้

*   เลิกใช้ `Tasks::DatabaseTasks.schema_file_type`.

### การเปลี่ยนแปลงที่สำคัญ

*   ยกเลิกการทำธุรกร
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

โปรดอ้างอิงที่ [Changelog][active-storage] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการเลิกใช้การแจงองค์ประกอบของ `ActiveModel::Errors` เป็น Hash

*   ลบการเลิกใช้ `ActiveModel::Errors#to_h`

*   ลบการเลิกใช้ `ActiveModel::Errors#slice!`

*   ลบการเลิกใช้ `ActiveModel::Errors#values`

*   ลบการเลิกใช้ `ActiveModel::Errors#keys`

*   ลบการเลิกใช้ `ActiveModel::Errors#to_xml`

*   ลบการสนับสนุนการเชื่อมต่อข้อผิดพลาดไปยัง `ActiveModel::Errors#messages`

*   ลบการสนับสนุนการ `clear` ข้อผิดพลาดจาก `ActiveModel::Errors#messages`

*   ลบการสนับสนุนการ `delete` ข้อผิดพลาดจาก `ActiveModel::Errors#messages`

*   ลบการสนับสนุนการใช้ `[]=` ใน `ActiveModel::Errors#messages`

*   ลบการสนับสนุนการโหลดรูปแบบข้อผิดพลาดของ Rails 5.x ด้วย Marshal และ YAML

*   ลบการสนับสนุนการโหลดรูปแบบของ Rails 5.x `ActiveModel::AttributeSet` ด้วย Marshal

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Active Support
--------------

โปรดอ้างอิงที่ [Changelog][active-support] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการเลิกใช้ `config.active_support.use_sha1_digests`

*   ลบการเลิกใช้ `URI.parser`

*   ลบการสนับสนุนการใช้ `Range#include?` เพื่อตรวจสอบการรวมของค่าในช่วงวันที่และเวลาที่ถูกเลิกใช้

*   ลบการเลิกใช้ `ActiveSupport::Multibyte::Unicode.default_normalization_form`

### การเลิกใช้

*   เลิกใช้การส่งรูปแบบไปยัง `#to_s` และใช้ `#to_fs` ใน `Array`, `Range`, `Date`, `DateTime`, `Time`,
    `BigDecimal`, `Float` และ `Integer`

    การเลิกใช้นี้เพื่อให้แอปพลิเคชัน Rails สามารถใช้ประโยชน์จากการปรับปรุงของ Ruby 3.1
    [optimization](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44) ที่ทำให้
    การตัดต่อของบางประเภทของวัตถุเร็วขึ้น

    แอปพลิเคชันใหม่จะไม่มีการแทนที่เมธอด `#to_s` ในคลาสเหล่านั้น แอปพลิเคชันที่มีอยู่สามารถใช้
    `config.active_support.disable_to_s_conversion` ได้

### การเปลี่ยนแปลงที่สำคัญ

Active Job
----------

โปรดอ้างอิงที่ [Changelog][active-job] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบพฤติกรรมที่เลิกใช้ที่ไม่หยุด `after_enqueue`/`after_perform` ตอนที่มีการหยุดพฤติกรรมก่อนหน้านี้ด้วย `throw :abort`

*   ลบตัวเลือก `:return_false_on_aborted_enqueue` ที่เลิกใช้

### การเลิกใช้

*   เลิกใช้ `Rails.config.active_job.skip_after_callbacks_if_terminated`

### การเปลี่ยนแปลงที่สำคัญ

Action Text
----------

โปรดอ้างอิงที่ [Changelog][action-text] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การลบ

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Action Mailbox
----------

โปรดอ้างอิงที่ [Changelog][action-mailbox] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการเลิกใช้ `Rails.application.credentials.action_mailbox.mailgun_api_key`

*   ลบตัวแปรสภาพแวดล้อมที่เลิกใช้ `MAILGUN_INGRESS_API_KEY`

### การเลิกใช้

### การเปลี่ยนแปลงที่สำคัญ

Ruby on Rails Guides
--------------------

โปรดอ้างอิงที่ [Changelog][guides] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

Credits
-------

ดู
[รายชื่อเต็มของผู้มีส่วนร่วมใน Rails](https://contributors.rubyonrails.org/)
สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการทำให้ Rails เป็นเฟรมเวิร์กที่เสถียรและทนทาน ยินดีด้วยทุกคน
[active-storage]: https://github.com/rails/rails/blob/7-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/7-0-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/7-0-stable/actionmailbox/CHANGELOG.md
