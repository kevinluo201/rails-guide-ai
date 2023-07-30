**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 95d91c83726e012162afc60c78688099
เอกสารปล่อยตัวของ Ruby on Rails 4.1
===============================

จุดเด่นใน Rails 4.1:

* Spring application preloader
* `config/secrets.yml`
* Action Pack variants
* Action Mailer previews

เอกสารปล่อยตัวนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่ changelogs หรือตรวจสอบ [รายการคอมมิต](https://github.com/rails/rails/commits/4-1-stable) ในเก็บรักษาของ Rails ที่หลักบน GitHub

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 4.1
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 4.0 ก่อนหากคุณยังไม่ได้ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 4.1 มีรายการสิ่งที่ควรระวังเมื่ออัปเกรดใน
[การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1)
คู่มือ

คุณสมบัติหลัก
--------------

### Spring Application Preloader

Spring เป็นตัวโหลดล่วงหน้าของแอปพลิเคชัน Rails มันช่วยเร่งความเร็วในการพัฒนาโดยการเก็บแอปพลิเคชันของคุณทำงานในพื้นหลังเพื่อให้คุณไม่ต้องบูตแอปพลิเคชันทุกครั้งที่คุณเรียกใช้การทดสอบ งาน rake หรือการย้ายข้อมูล

แอปพลิเคชัน Rails 4.1 ใหม่จะมี "springified" binstubs ในการจัดส่ง นั่นหมายความว่า `bin/rails` และ `bin/rake` จะใช้ประโยชน์จากการโหลดล่วงหน้าแวดล้อม spring โดยอัตโนมัติ

**การเรียกใช้งานงาน rake:**

```bash
$ bin/rake test:models
```

**การเรียกใช้คำสั่ง Rails:**

```bash
$ bin/rails console
```

**การตรวจสอบ Spring:**

```bash
$ bin/spring status
Spring is running:

 1182 spring server | my_app | started 29 mins ago
 3656 spring app    | my_app | started 23 secs ago | test mode
 3746 spring app    | my_app | started 10 secs ago | development mode
```

ดูที่ [Spring README](https://github.com/rails/spring/blob/master/README.md) เพื่อดูคุณสมบัติที่มีอยู่ทั้งหมด

ดูที่ [การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#spring)
คู่มือเพื่อดูวิธีการย้ายแอปพลิเคชันที่มีอยู่ให้ใช้คุณสมบัตินี้

### `config/secrets.yml`

Rails 4.1 สร้างไฟล์ `secrets.yml` ใหม่ในโฟลเดอร์ `config` โดยค่าเริ่มต้นไฟล์นี้จะมี `secret_key_base` ของแอปพลิเคชัน แต่ยังสามารถใช้เก็บความลับอื่นๆ เช่น คีย์การเข้าถึงสำหรับ API ภายนอกได้
ความลับที่เพิ่มเข้าไปในไฟล์นี้สามารถเข้าถึงได้ผ่าน `Rails.application.secrets` 
ตัวอย่างเช่น ด้วย `config/secrets.yml` ต่อไปนี้:

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

`Rails.application.secrets.some_api_key` จะคืนค่า `SOMEKEY` ในสภาพแวดล้อมการพัฒนา

ดูเอกสาร [Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#config-secrets-yml)
เพื่อดูวิธีการย้ายแอปพลิเคชันที่มีอยู่เพื่อใช้คุณสมบัตินี้

### Action Pack Variants

เราต้องการแสดงเทมเพลต HTML/JSON/XML ที่แตกต่างกันสำหรับโทรศัพท์มือถือ
แท็บเล็ต และเบราว์เซอร์เดสก์ท็อป การใช้ Variant จะทำให้ง่ายขึ้น

Variant ของคำขอเป็นการพิเศษของรูปแบบคำขอ เช่น `:tablet`, `:phone`, หรือ `:desktop`

คุณสามารถตั้งค่า Variant ใน `before_action`:

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

ตอบสนองต่อ Variant ในแอคชันเหมือนตอบสนองต่อรูปแบบ:

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # แสดง app/views/projects/show.html+tablet.erb
    html.phone { extra_setup; render ... }
  end
end
```

ให้เตรียมเทมเพลตแยกต่างหากสำหรับแต่ละรูปแบบและ Variant:

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

คุณยังสามารถทำให้การกำหนด Variant ง่ายขึ้นได้โดยใช้ไวยากรณ์แบบอินไลน์:

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```

### Action Mailer Previews

Action Mailer previews ให้วิธีการดูว่าอีเมลดูยังไงโดยการเข้าชม URL พิเศษที่แสดงอีเมล

คุณสร้างคลาส preview ซึ่งเมธอดของมันจะคืนค่าออบเจกต์เมลที่คุณต้องการตรวจสอบ:

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

Preview สามารถใช้ได้ที่ http://localhost:3000/rails/mailers/notifier/welcome,
และรายการทั้งหมดที่ http://localhost:3000/rails/mailers

ตามค่าเริ่มต้น คลาส preview จะอยู่ใน `test/mailers/previews`
สามารถกำหนดค่าได้โดยใช้ตัวเลือก `preview_path`

ดูเอกสาร
[นี้](https://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails)
สำหรับข้อมูลเพิ่มเติม

### Active Record enums

ประกาศแอตทริบิวต์ enum ที่ค่าที่เก็บในฐานข้อมูลเป็นจำนวนเต็ม แต่สามารถค้นหาด้วยชื่อได้

```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => Relation สำหรับ Conversations ทั้งหมดที่ถูกเก็บเป็น archived

Conversation.statuses # => { "active" => 0, "archived" => 1 }
```
ดูเอกสารที่ [นี่](https://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html) เพื่อข้อมูลเพิ่มเติม

### Message Verifiers

Message verifiers สามารถใช้สร้างและตรวจสอบข้อความที่ถูกลงลายมือได้ สิ่งนี้มีประโยชน์ในการขนส่งข้อมูลที่เป็นข้อมูลที่สำคัญเช่นโทเค็น remember-me และเพื่อน

เมธอด `Rails.application.message_verifier` จะส่งคืนตัวตรวจสอบข้อความใหม่ที่ลงลายมือข้อความด้วยคีย์ที่ได้มาจาก secret_key_base และชื่อตัวตรวจสอบข้อความที่กำหนด:

```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# raises ActiveSupport::MessageVerifier::InvalidSignature
```

### Module#concerning

วิธีที่เป็นธรรมชาติและไม่ซับซ้อนในการแยกความรับผิดชอบภายในคลาส:

```ruby
class Todo < ActiveRecord::Base
  concerning :EventTracking do
    included do
      has_many :events
    end

    def latest_event
      # ...
    end

    private
      def some_internal_method
        # ...
      end
  end
end
```

ตัวอย่างนี้เทียบเท่ากับการกำหนดโมดูล `EventTracking` ในบรรทัดเดียวกัน แล้วขยายมันด้วย `ActiveSupport::Concern` และผสมมันเข้ากับคลาส `Todo`

ดูเอกสารที่ [นี่](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html) เพื่อข้อมูลเพิ่มเติมและวิธีการใช้งานที่ตั้งใจ

### การป้องกัน CSRF จากแท็ก `<script>` จากระยะไกล

การป้องกันการโจมตี CSRF ตอนนี้รองรับการร้องขอ GET ที่มีการตอบกลับด้วย JavaScript เช่นกัน นั่นหมายความว่าเว็บไซต์บุคคลที่สามจะไม่สามารถอ้างอิง URL ของ JavaScript ของคุณและพยายามเรียกใช้เพื่อดึงข้อมูลที่สำคัญได้

นี่หมายความว่าการทดสอบใด ๆ ที่เรียกใช้ URL `.js` ของคุณจะล้มเหลวการป้องกัน CSRF ยกเว้นว่าจะใช้ `xhr` อัพเกรดการทดสอบของคุณให้ชัดเจนเกี่ยวกับการคาดหวัง XmlHttpRequests แทนการใช้ `post :create, format: :js` ให้เปลี่ยนเป็น `xhr :post, :create, format: :js`

Railties
--------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

* ลบงาน rake `update:application_controller`

* ลบ `Rails.application.railties.engines` ที่ถูกยกเลิก

* ลบ `threadsafe!` ที่ถูกยกเลิกจาก Rails Config

* ลบ `ActiveRecord::Generators::ActiveModel#update_attributes` ที่ถูกยกเลิกแล้วแทนด้วย `ActiveRecord::Generators::ActiveModel#update`

* ลบตัวเลือก `config.whiny_nils` ที่ถูกยกเลิก

* ลบงาน rake ที่ถูกยกเลิกสำหรับการเรียกใช้ทดสอบ: `rake test:uncommitted` และ `rake test:recent`

### การเปลี่ยนแปลงที่สำคัญ

* [Spring application preloader](https://github.com/rails/spring) ติดตั้งโดยค่าเริ่มต้นสำหรับแอปพลิเคชันใหม่ มันใช้กลุ่มการพัฒนาของ `Gemfile` ดังนั้นจะไม่ถูกติดตั้งในโหมดการใช้งานจริง ([Pull Request](https://github.com/rails/rails/pull/12958))
* `BACKTRACE` ตัวแปรสภาพแวดล้อมเพื่อแสดง backtrace ที่ไม่ได้กรองสำหรับการล้มเหลวในการทดสอบ ([Commit](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553))

* เปิดเผย `MiddlewareStack#unshift` เพื่อกำหนดค่าสภาพแวดล้อม ([Pull Request](https://github.com/rails/rails/pull/12479))

* เพิ่มเมธอด `Application#message_verifier` เพื่อคืนตัวตรวจสอบข้อความ ([Pull Request](https://github.com/rails/rails/pull/12995))

* ไฟล์ `test_help.rb` ที่ต้องการโดยค่าเริ่มต้นของเครื่องมือช่วยทดสอบที่สร้างขึ้นจะอัปเดตฐานข้อมูลทดสอบของคุณให้เป็นปัจจุบันกับ `db/schema.rb` (หรือ `db/structure.sql`) โดยการเรียกใช้งานซ้ำโครงสร้าง หากการโหลดซ้ำของโครงสร้างไม่สามารถแก้ไขปัญหาการเคลื่อนย้ายที่รอดำเนินการได้ จะเกิดข้อผิดพลาดขึ้น สามารถปิดการใช้งานได้ด้วย `config.active_record.maintain_test_schema = false` ([Pull Request](https://github.com/rails/rails/pull/13528))

* นำเข้า `Rails.gem_version` เป็นเมธอดที่สะดวกในการคืนค่า `Gem::Version.new(Rails.version)` เพื่อแนะนำวิธีการเปรียบเทียบเวอร์ชันที่เป็นที่เชื่อถือได้มากขึ้น ([Pull Request](https://github.com/rails/rails/pull/14103))


Action Pack
-----------

โปรดอ้างอิงที่
[Changelog](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md)
สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

* ลบการสำรองที่ตกลงไว้สำหรับการทดสอบการรวมกันของแอปพลิเคชัน Rails ที่ถูกยกเลิก แทนที่ให้ตั้งค่า `ActionDispatch.test_app`

* ลบการกำหนดค่า `page_cache_extension` ที่ถูกยกเลิกไว้

* ลบค่าคงที่ที่ถูกยกเลิกจาก Action Controller:

| ถูกลบ                           | ผู้สืบทอด                       |
|:-----------------------------------|:--------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### การเปลี่ยนแปลงที่สำคัญ

* `protect_from_forgery` ยังป้องกันแท็ก `<script>` ข้ามต้นทางด้วย อัปเดตการทดสอบของคุณให้ใช้ `xhr :get, :foo, format: :js` แทน `get :foo, format: :js` ([Pull Request](https://github.com/rails/rails/pull/13345))

* `#url_for` รับแอร์เรย์ที่มีตัวเลือกภายใน ([Pull Request](https://github.com/rails/rails/pull/9599))

* เพิ่มเมธอด `session#fetch` ที่ทำงานเช่นเดียวกับ [Hash#fetch](https://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch) แต่ค่าที่คืนค่าจะถูกบันทึกไว้ในเซสชันเสมอ ([Pull Request](https://github.com/rails/rails/pull/12692))

* แยก Action View ออกจาก Action Pack อย่างสมบูรณ์ ([Pull Request](https://github.com/rails/rails/pull/11032))

* บันทึกคีย์ที่ได้รับผลกระทบจาก deep munge ([Pull Request](https://github.com/rails/rails/pull/13813))

* ตัวเลือกการกำหนดค่าใหม่ `config.action_dispatch.perform_deep_munge` เพื่อไม่ใช้ "deep munging" ของพารามิเตอร์ที่ใช้แก้ไขช่องโหว่ความปลอดภัย CVE-2013-0155 ([Pull Request](https://github.com/rails/rails/pull/13188))

* ตัวเลือกการกำหนดค่าใหม่ `config.action_dispatch.cookies_serializer` เพื่อระบุตัวแปรที่ใช้สำหรับการลงลายมือและเข้ารหัสคุกกี้ (Pull Requests
  [1](https://github.com/rails/rails/pull/13692),
  [2](https://github.com/rails/rails/pull/13945) /
  [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#cookies-serializer))
* เพิ่ม `render :plain`, `render :html` และ `render :body` ([Pull Request](https://github.com/rails/rails/pull/14062) / [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#rendering-content-from-string))

Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

* เพิ่มฟีเจอร์การแสดงตัวอย่างเมลล์ (mailer previews) โดยใช้ gem จาก 37 Signals mail_view ([Commit](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261))

* เพิ่มการตรวจวัดการสร้างข้อความใน Action Mailer โดยเขียนเวลาที่ใช้ในการสร้างข้อความลงใน log ([Pull Request](https://github.com/rails/rails/pull/12556))

Active Record
-------------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบออก

* ลบการใช้ nil-passing ที่ถูกยกเลิกไปจากเมธอด `SchemaCache` ต่อไปนี้: `primary_keys`, `tables`, `columns` และ `columns_hash`

* ลบการใช้ block filter ที่ถูกยกเลิกไปจาก `ActiveRecord::Migrator#migrate`

* ลบการใช้ String constructor ที่ถูกยกเลิกไปจาก `ActiveRecord::Migrator`

* ลบการใช้ `scope` ที่ถูกยกเลิกไปโดยไม่ส่ง callable object

* ลบการใช้ `transaction_joinable=` ที่ถูกยกเลิกไปและใช้ `begin_transaction` พร้อมกับตัวเลือก `:joinable` แทน

* ลบการใช้ `decrement_open_transactions` ที่ถูกยกเลิกไป

* ลบการใช้ `increment_open_transactions` ที่ถูกยกเลิกไป

* ลบเมธอด `PostgreSQLAdapter#outside_transaction?` ที่ถูกยกเลิกไป คุณสามารถใช้ `#transaction_open?` แทน

* ลบ `ActiveRecord::Fixtures.find_table_name` ที่ถูกยกเลิกไปและใช้ `ActiveRecord::Fixtures.default_fixture_model_name` แทน

* ลบ `columns_for_remove` ที่ถูกยกเลิกไปจาก `SchemaStatements`

* ลบ `SchemaStatements#distinct` ที่ถูกยกเลิกไป

* ย้าย `ActiveRecord::TestCase` ที่ถูกยกเลิกไปเข้าไปในชุดทดสอบของ Rails คลาสนี้ไม่ได้เป็นสาธารณะและใช้เฉพาะสำหรับการทดสอบภายใน Rails เท่านั้น

* ลบการสนับสนุนตัวเลือก `:restrict` ที่ถูกยกเลิกไปสำหรับ `:dependent` ในการเชื่อมโยง

* ลบการสนับสนุน `:delete_sql`, `:insert_sql`, `:finder_sql` และ `:counter_sql` ที่ถูกยกเลิกไปสำหรับตัวเลือกในการเชื่อมโยง

* ลบเมธอด `type_cast_code` ที่ถูกยกเลิกไปจาก Column

* ลบเมธอด `ActiveRecord::Base#connection` ที่ถูกยกเลิกไป โปรดตรวจสอบการเข้าถึงผ่านคลาส

* ลบคำเตือนการถูกยกเลิกสำหรับ `auto_explain_threshold_in_seconds`

* ลบตัวเลือก `:distinct` ที่ถูกยกเลิกไปจาก `Relation#count`

* ลบเมธอดที่ถูกยกเลิกไป `partial_updates`, `partial_updates?` และ `partial_updates=`

* ลบเมธอดที่ถูกยกเลิกไป `scoped`

* ลบเมธอดที่ถูกยกเลิกไป `default_scopes?`

* ลบการอ้างอิงการเชื่อมต่อแบบอัตโนมัติที่ถูกยกเลิกไปในเวอร์ชัน 4.0

* ลบ `activerecord-deprecated_finders` เป็น dependency โปรดดู [README ของ gem](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders) สำหรับข้อมูลเพิ่มเติม

* ลบการใช้ `implicit_readonly` โปรดใช้เมธอด `readonly` โดยชัดเจนเพื่อทำเครื่องหมายว่าเร็คคอร์ดเป็น `readonly` ([Pull Request](https://github.com/rails/rails/pull/10769))
### การเลิกใช้งาน

* เลิกใช้งานเมธอด `quoted_locking_column` ที่ไม่ได้ใช้ที่ใดที่นั่น

* เลิกใช้งาน `ConnectionAdapters::SchemaStatements#distinct` เนื่องจากไม่ได้ใช้ในภายในอีกต่อไป ([Pull Request](https://github.com/rails/rails/pull/10556))

* เลิกใช้งานงาน `rake db:test:*` เนื่องจากฐานข้อมูลทดสอบถูกบำรุงรักษาโดยอัตโนมัติแล้ว ดูรายละเอียดเพิ่มเติมในเอกสารปล่อย railties ([Pull Request](https://github.com/rails/rails/pull/13528))

* เลิกใช้งาน `ActiveRecord::Base.symbolized_base_class` และ `ActiveRecord::Base.symbolized_sti_name` ที่ไม่ได้ใช้งานและไม่มีการแทนที่ [Commit](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)

### การเปลี่ยนแปลงที่สำคัญ

* สคอปเริ่มต้นไม่ได้ถูกแทนที่โดยเงื่อนไขที่เชื่อมต่อ

  ก่อนการเปลี่ยนแปลงนี้เมื่อคุณกำหนด `default_scope` ในโมเดล มันจะถูกแทนที่โดยเงื่อนไขที่เชื่อมต่อในฟิลด์เดียวกัน ตอนนี้มันถูกผสมเข้ากับสคอปอื่น ๆ เช่นเดียวกับสคอปอื่น ๆ [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-on-default-scopes)

* เพิ่ม `ActiveRecord::Base.to_param` เพื่อให้สามารถใช้งาน URL ที่สวยงามได้ที่ได้รับมาจากแอตทริบิวต์หรือเมธอดของโมเดล ([Pull Request](https://github.com/rails/rails/pull/12891))

* เพิ่ม `ActiveRecord::Base.no_touching` ซึ่งช่วยให้สามารถละเว้นการสัมผัสบนโมเดลได้ ([Pull Request](https://github.com/rails/rails/pull/12772))

* รวมการแปลงชนิดของบูลีนสำหรับ `MysqlAdapter` และ `Mysql2Adapter` เมธอด `type_cast` จะคืนค่า `1` สำหรับ `true` และ `0` สำหรับ `false` ([Pull Request](https://github.com/rails/rails/pull/12425))

* `.unscope` ตอนนี้จะลบเงื่อนไขที่ระบุใน `default_scope` ([Commit](https://github.com/rails/rails/commit/94924dc32baf78f13e289172534c2e71c9c8cade))

* เพิ่ม `ActiveRecord::QueryMethods#rewhere` ซึ่งจะเขียนทับเงื่อนไข where ที่มีอยู่แล้ว โดยระบุชื่อ ([Commit](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2))

* ขยาย `ActiveRecord::Base#cache_key` เพื่อรับค่าแอตทริบิวต์เวลาแบบไม่บังคับที่สูงสุด ([Commit](https://github.com/rails/rails/commit/e94e97ca796c0759d8fcb8f946a3bbc60252d329))

* เพิ่ม `ActiveRecord::Base#enum` เพื่อประกาศแอตทริบิวต์ enum ที่ค่าที่ได้จากฐานข้อมูลเป็นจำนวนเต็ม แต่สามารถค้นหาตามชื่อได้ ([Commit](https://github.com/rails/rails/commit/db41eb8a6ea88b854bf5cd11070ea4245e1639c5))

* แปลงชนิดค่า JSON เมื่อเขียน เพื่อให้ค่าสอดคล้องกับการอ่านจากฐานข้อมูล ([Pull Request](https://github.com/rails/rails/pull/12643))

* แปลงชนิดค่า hstore เมื่อเขียน เพื่อให้ค่าสอดคล้องกับการอ่านจากฐานข้อมูล ([Commit](https://github.com/rails/rails/commit/5ac2341fab689344991b2a4817bd2bc8b3edac9d))

* ทำให้ `next_migration_number` เข้าถึงได้สำหรับตัวสร้างจากบุคคลที่สาม ([Pull Request](https://github.com/rails/rails/pull/12407))

* เรียกใช้ `update_attributes` จะส่ง `ArgumentError` เมื่อได้รับอาร์กิวเมนต์ `nil` โดยเฉพาะอย่างยิ่ง จะส่งข้อผิดพลาดถ้าอาร์กิวเมนต์ที่ได้รับไม่ตอบสนองกับ `stringify_keys` ([Pull Request](https://github.com/rails/rails/pull/9860))

* `CollectionAssociation#first`/`#last` (เช่น `has_many`) ใช้คิวรีที่ถูกจำกัดเพื่อดึงผลลัพธ์แทนที่จะโหลดคอลเลกชันทั้งหมด ([Pull Request](https://github.com/rails/rails/pull/12137))
* `inspect` ในคลาส Active Record model จะไม่เริ่มการเชื่อมต่อใหม่ นั่นหมายความว่าการเรียกใช้ `inspect` เมื่อไม่มีฐานข้อมูลจะไม่เกิดข้อผิดพลาด ([Pull Request](https://github.com/rails/rails/pull/11014))

* ลบข้อจำกัดของคอลัมน์สำหรับ `count` ให้ฐานข้อมูลเกิดข้อผิดพลาดหาก SQL ไม่ถูกต้อง ([Pull Request](https://github.com/rails/rails/pull/10710))

* Rails ตอนนี้สามารถตรวจหาสมาชิกที่เกี่ยวข้องกันได้อัตโนมัติแล้ว หากคุณไม่ตั้งค่า `:inverse_of` ในการเชื่อมโยง  Active Record จะคาดเดาสมาชิกที่เกี่ยวข้องกันโดยใช้เทคนิคการคาดเดา ([Pull Request](https://github.com/rails/rails/pull/10886))

* จัดการกับแอลิเอสแอลิเอสที่ถูกตั้งชื่อใหม่ใน ActiveRecord::Relation  เมื่อใช้คีย์แบบสัญลักษณ์  ActiveRecord จะแปลงชื่อแอลิเอสที่ถูกตั้งชื่อใหม่เป็นชื่อคอลัมน์จริงที่ใช้ในฐานข้อมูล ([Pull Request](https://github.com/rails/rails/pull/7839))

* ERB ในไฟล์ fixture จะไม่ถูกประเมินในบริบทของอ็อบเจ็กต์หลักอีกต่อไป  เมธอดช่วยเหลือที่ใช้ใน fixture หลายรูปแบบควรถูกกำหนดในโมดูลที่รวมอยู่ใน `ActiveRecord::FixtureSet.context_class` ([Pull Request](https://github.com/rails/rails/pull/13022))

* ไม่สร้างหรือลบฐานข้อมูลทดสอบหาก RAILS_ENV ถูกระบุโดยชัดเจน ([Pull Request](https://github.com/rails/rails/pull/13629))

* `Relation` ไม่มีเมธอด mutator เช่น `#map!` และ `#delete_if` แปลงเป็น `Array` โดยเรียกใช้ `#to_a` ก่อนใช้เมธอดเหล่านี้ ([Pull Request](https://github.com/rails/rails/pull/13314))

* `find_in_batches`, `find_each`, `Result#each` และ `Enumerable#index_by` ตอนนี้ส่งคืน `Enumerator` ที่สามารถคำนวณขนาดได้ ([Pull Request](https://github.com/rails/rails/pull/13938))

* `scope`, `enum` และ Associations ตอนนี้เกิดข้อขัดแย้งเมื่อมีชื่อที่ขัดแย้งกันที่เรียกว่า "อันตราย" ([Pull Request](https://github.com/rails/rails/pull/13450), [Pull Request](https://github.com/rails/rails/pull/13896))

* เมธอด `second` ถึง `fifth` ทำหน้าที่เหมือนกับตัวค้นหา `first` ([Pull Request](https://github.com/rails/rails/pull/13757))

* ทำให้ `touch` เรียกใช้ `after_commit` และ `after_rollback` callbacks ([Pull Request](https://github.com/rails/rails/pull/12031))

* เปิดใช้งานดัชนีบางส่วนสำหรับ `sqlite >= 3.8.0` ([Pull Request](https://github.com/rails/rails/pull/13350))

* ทำให้ `change_column_null` สามารถย้อนกลับได้ ([Commit](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96))

* เพิ่มตัวแปรเพื่อปิดการสร้าง schema หลังจากการโยกย้าย ค่าเริ่มต้นในสภาพแวดล้อมการใช้งานจริงสำหรับแอปพลิเคชันใหม่จะถูกตั้งค่าเป็น `false` ([Pull Request](https://github.com/rails/rails/pull/13948))

Active Model
------------

โปรดอ้างอิงที่
[Changelog](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md)
สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเลิกใช้

* เลิกใช้ `Validator#setup` ควรทำเองในคอนสตรักเตอร์ของ validator ([Commit](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a))
### การเปลี่ยนแปลงที่สำคัญ

* เพิ่มเมธอด API ใหม่ `reset_changes` และ `changes_applied` ใน `ActiveModel::Dirty` ที่ควบคุมสถานะการเปลี่ยนแปลง

* สามารถระบุ context หลายรายการเมื่อกำหนดการตรวจสอบความถูกต้อง ([Pull Request](https://github.com/rails/rails/pull/13754))

* `attribute_changed?` ตอนนี้ยอมรับแฮชเพื่อตรวจสอบว่ามีการเปลี่ยนแปลงของ attribute `:from` และ/หรือ `:to` ค่าที่กำหนด ([Pull Request](https://github.com/rails/rails/pull/13131))


Active Support
--------------

โปรดอ้างอิงที่
[Changelog](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md)
สำหรับรายละเอียดการเปลี่ยนแปลง


### การลบ

* ลบความขึ้นอยู่กับ `MultiJSON` ที่เกี่ยวข้อง ด้วยผลที่ `ActiveSupport::JSON.decode`
  ไม่ยอมรับตัวเลือกแฮชสำหรับ `MultiJSON` อีกต่อไป ([Pull Request](https://github.com/rails/rails/pull/10576) / [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))

* ลบการสนับสนุนสำหรับการเข้ารหัส `encode_json` ที่ใช้สำหรับการเข้ารหัสวัตถุที่กำหนดเองเป็น
  JSON คุณลักษณะนี้ถูกแยกออกเป็น [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder)
  gem
  ([Pull Request ที่เกี่ยวข้อง](https://github.com/rails/rails/pull/12183) /
  [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))

* ลบ `ActiveSupport::JSON::Variable` ที่ถูกยกเลิกโดยไม่มีการแทนที่

* ลบการขยายความสามารถที่ถูกยกเลิก `String#encoding_aware?` (`core_ext/string/encoding`)

* ลบการขยายความสามารถที่ถูกยกเลิก `Module#local_constant_names` เพื่อใช้ `Module#local_constants` แทน

* ลบการขยายความสามารถที่ถูกยกเลิก `DateTime.local_offset` เพื่อใช้ `DateTime.civil_from_format` แทน

* ลบการขยายความสามารถที่ถูกยกเลิก `Logger` (`core_ext/logger.rb`)

* ลบการขยายความสามารถที่ถูกยกเลิก `Time#time_with_datetime_fallback`, `Time#utc_time` และ
  `Time#local_time` เพื่อใช้ `Time#utc` และ `Time#local` แทน

* ลบการขยายความสามารถที่ถูกยกเลิก `Hash#diff` โดยไม่มีการแทนที่

* ลบการขยายความสามารถที่ถูกยกเลิก `Date#to_time_in_current_zone` เพื่อใช้ `Date#in_time_zone` แทน

* ลบการขยายความสามารถที่ถูกยกเลิก `Proc#bind` โดยไม่มีการแทนที่

* ลบการขยายความสามารถที่ถูกยกเลิก `Array#uniq_by` และ `Array#uniq_by!` ใช้ `Array#uniq` และ `Array#uniq!` แทน

* ลบ `ActiveSupport::BasicObject` ที่ถูกยกเลิกใช้
  `ActiveSupport::ProxyObject` แทน

* ลบ `BufferedLogger` ที่ถูกยกเลิกใช้ `ActiveSupport::Logger` แทน

* ลบเมธอด `assert_present` และ `assert_blank` ใช้ `assert
  object.blank?` และ `assert object.present?` แทน

* ลบเมธอด `#filter` สำหรับวัตถุตัวกรอง ใช้เมธอดที่เกี่ยวข้องแทน (เช่น `#before` สำหรับตัวกรองก่อน)

* ลบการเปลี่ยนแปลง 'cow' => 'kine' ที่ไม่เป็นไปตามกฎเกณฑ์จากค่าเริ่มต้น
  inflections. ([Commit](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9))

### การเลิกใช้

* เลิกใช้ `Numeric#{ago,until,since,from_now}` ผู้ใช้ควร
  แปลงค่าเป็น AS::Duration โดยชัดเจน เช่น `5.ago` => `5.seconds.ago`
  ([Pull Request](https://github.com/rails/rails/pull/12389))

* เลิกใช้เส้นทางการต้องการ `active_support/core_ext/object/to_json` ให้ต้องการ
  `active_support/core_ext/object/json` แทน ([Pull Request](https://github.com/rails/rails/pull/12203))

* เลิกใช้ `ActiveSupport::JSON::Encoding::CircularReferenceError` คุณลักษณะนี้
  ถูกแยกออกเป็น [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder)
  gem
  ([Pull Request](https://github.com/rails/rails/pull/12785) /
  [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))
* ตัวเลือก `ActiveSupport.encode_big_decimal_as_string` ที่ถูกยกเลิก คุณลักษณะนี้ได้ถูกแยกออกมาเป็นแพ็คเกจ [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem.
  ([Pull Request](https://github.com/rails/rails/pull/13060) /
  [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))

* ยกเลิกการใช้งาน `BigDecimal` ที่กำหนดเองในการแปลงข้อมูล. ([Pull Request](https://github.com/rails/rails/pull/13911))

### การเปลี่ยนแปลงที่สำคัญ

* ได้เขียนใหม่ JSON encoder ของ `ActiveSupport` เพื่อใช้ประโยชน์จาก JSON gem แทนที่จะทำการเข้ารหัสเองในรูปแบบ pure-Ruby.
  ([Pull Request](https://github.com/rails/rails/pull/12183) /
  [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))

* ปรับปรุงความเข้ากันได้กับ JSON gem.
  ([Pull Request](https://github.com/rails/rails/pull/12862) /
  [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))

* เพิ่ม `ActiveSupport::Testing::TimeHelpers#travel` และ `#travel_to`. เมธอดเหล่านี้เปลี่ยนเวลาปัจจุบันเป็นเวลาหรือระยะเวลาที่กำหนดโดยการสแต็บ `Time.now` และ `Date.today`.

* เพิ่ม `ActiveSupport::Testing::TimeHelpers#travel_back`. เมธอดนี้จะคืนค่าเวลาปัจจุบันกลับสู่สถานะเดิมโดยการลบสแต็บที่เพิ่มโดย `travel` และ `travel_to`. ([Pull Request](https://github.com/rails/rails/pull/13884))

* เพิ่ม `Numeric#in_milliseconds`, เช่น `1.hour.in_milliseconds`, เพื่อให้สามารถนำไปใช้กับฟังก์ชัน JavaScript เช่น `getTime()` ได้. ([Commit](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643))

* เพิ่ม `Date#middle_of_day`, `DateTime#middle_of_day` และ `Time#middle_of_day` เป็นเมธอด และเพิ่ม `midday`, `noon`, `at_midday`, `at_noon` และ `at_middle_of_day` เป็นตัวย่อ.
  ([Pull Request](https://github.com/rails/rails/pull/10879))

* เพิ่ม `Date#all_week/month/quarter/year` เพื่อสร้างช่วงวันที่. ([Pull Request](https://github.com/rails/rails/pull/9685))

* เพิ่ม `Time.zone.yesterday` และ `Time.zone.tomorrow`. ([Pull Request](https://github.com/rails/rails/pull/12822))

* เพิ่ม `String#remove(pattern)` เป็นการย่อหน้าสั้น ๆ สำหรับรูปแบบที่พบบ่อยของ `String#gsub(pattern,'')`. ([Commit](https://github.com/rails/rails/commit/5da23a3f921f0a4a3139495d2779ab0d3bd4cb5f))

* เพิ่ม `Hash#compact` และ `Hash#compact!` เพื่อลบรายการที่มีค่าเป็น nil ออกจาก hash. ([Pull Request](https://github.com/rails/rails/pull/13632))

* `blank?` และ `present?` จะคืนค่าเป็น singletons. ([Commit](https://github.com/rails/rails/commit/126dc47665c65cd129967cbd8a5926dddd0aa514))

* ตั้งค่า `I18n.enforce_available_locales` ใหม่เป็น `true` ที่เป็นค่าเริ่มต้น ซึ่งหมายความว่า `I18n` จะตรวจสอบให้แน่ใจว่าทุกโลเคลที่ส่งผ่านไปยังมันต้องถูกประกาศในรายการ `available_locales`.
  ([Pull Request](https://github.com/rails/rails/pull/13341))

* เพิ่ม `Module#concerning`: วิธีที่เป็นธรรมชาติและไม่ซับซ้อนในการแยกความรับผิดชอบภายในคลาส. ([Commit](https://github.com/rails/rails/commit/1eee0ca6de975b42524105a59e0521d18b38ab81))

* เพิ่ม `Object#presence_in` เพื่อให้ง่ายต่อการเพิ่มค่าในรายการที่อนุญาต. ([Commit](https://github.com/rails/rails/commit/4edca106daacc5a159289eae255207d160f22396))


เครดิต
-------

ดูรายชื่อเต็มของผู้มีส่วนร่วมใน Rails ได้ที่
[รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](https://contributors.rubyonrails.org/) สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์คที่เสถียรและทนทาน ยินดีด้วยทุกคน.
