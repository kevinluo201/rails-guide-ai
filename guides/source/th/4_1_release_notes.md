**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 95d91c83726e012162afc60c78688099
เรื่องเด่นใน Rails 4.1:

* Spring application preloader
* `config/secrets.yml`
* Action Pack variants
* Action Mailer previews

บทความนี้เน้นเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่ changelogs หรือตรวจสอบ [รายการของการ commit](https://github.com/rails/rails/commits/4-1-stable) ในเครื่องมือ Rails หลักใน GitHub.

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 4.1
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 4.0 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 4.1 มีรายการสิ่งที่ควรระวังเมื่ออัปเกรดใน
[การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1)
คู่มือ.


คุณสมบัติหลัก
--------------

### Spring Application Preloader

Spring เป็นตัวโหลดล่วงหน้าของแอปพลิเคชัน Rails มันช่วยเร่งความเร็วในการพัฒนาโดยการเก็บแอปพลิเคชันของคุณทำงานในพื้นหลังเพื่อให้คุณไม่ต้องบูตแอปพลิเคชันทุกครั้งที่คุณเรียกใช้การทดสอบ งาน rake หรือการเมือง.

แอปพลิเคชัน Rails 4.1 ใหม่จะมาพร้อมกับ "springified" binstubs ซึ่งหมายความว่า `bin/rails` และ `bin/rake` จะใช้ประโยชน์จากการโหลดล่วงหน้าสภาพแวดล้อม spring อัตโนมัติ.

**การเรียกใช้งาน rake tasks:**

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

ดูคู่มือ [Spring README](https://github.com/rails/spring/blob/master/README.md) เพื่อดูคุณสมบัติที่มีอยู่ทั้งหมด.

ดูคู่มือ [การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#spring)
เพื่อดูวิธีการย้ายแอปพลิเคชันที่มีอยู่เพื่อใช้คุณสมบัตินี้.

### `config/secrets.yml`

Rails 4.1 สร้างไฟล์ `secrets.yml` ใหม่ในโฟลเดอร์ `config` โดยค่าเริ่มต้นไฟล์นี้จะมี `secret_key_base` ของแอปพลิเคชัน แต่ยังสามารถใช้เก็บความลับอื่นๆ เช่น คีย์การเข้าถึงสำหรับ API ภายนอกได้.

ค่าลับที่เพิ่มในไฟล์นี้สามารถเข้าถึงได้ผ่าน `Rails.application.secrets` เช่น ด้วย `config/secrets.yml` ต่อไปนี้:

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

`Rails.application.secrets.some_api_key` จะคืนค่า `SOMEKEY` ในสภาพแวดล้อมการพัฒนา.

ดูคู่มือ [การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#config-secrets-yml)
เพื่อดูวิธีการย้ายแอปพลิเคชันที่มีอยู่เพื่อใช้คุณสมบัตินี้.

### Action Pack Variants

เรามักต้องการแสดงเทมเพลต HTML/JSON/XML ที่แตกต่างกันสำหรับโทรศัพท์มือถือ เครื่องแท็บเล็ต และเบราว์เซอร์เดสก์ท็อป ตัวแปรแบบ Variants ทำให้ง่าย.

Variant ของคำขอเป็นการพิเศษของรูปแบบคำขอ เช่น `:tablet`, `:phone`, หรือ `:desktop`.

คุณสามารถตั้งค่า variant ใน `before_action`:

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

ตอบสนองต่อ variant ใน action เหมือนตอบสนองต่อรูปแบบ:

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # แสดง app/views/projects/show.html+tablet.erb
    html.phone { extra_setup; render ... }
  end
end
```

ให้เทมเพลตแยกต่างหากสำหรับแต่ละรูปแบบและ variant:

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

คุณยังสามารถทำให้การกำหนด variant ง่ายขึ้นได้โดยใช้ไวยากรณ์แบบอินไลน์:

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```

### Action Mailer Previews

Action Mailer previews ให้วิธีการดูว่าอีเมลดูยังไงโดยการเข้าชม URL พิเศษที่แสดงอีเมล.

คุณสร้างคลาส preview ซึ่งเมธอดของมันจะคืนออบเจกต์อีเมลที่คุณต้องการตรวจสอบ:

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

การแสดงตัวอย่างสามารถเข้าถึงได้ที่ http://localhost:3000/rails/mailers/notifier/welcome,
และรายการของตัวอย่างทั้งหมดที่ http://localhost:3000/rails/mailers.

ตามค่าเริ่มต้น คลาสตัวอย่างเหล่านี้อยู่ใน `test/mailers/previews`.
สามารถกำหนดค่านี้ได้โดยใช้ตัวเลือก `preview_path`.

ดูคู่มือ
[เอกสาร](https://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails)
สำหรับข้อมูลเพิ่มเติม.

### Active Record enums

ประกาศแอตทริบิวต์ enum ที่ค่าที่เก็บในฐานข้อมูลเป็นจำนวนเต็ม แต่สามารถค้นหาด้วยชื่อได้.
```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => ความสัมพันธ์สำหรับ Conversations ที่ถูกเก็บถาวรทั้งหมด

Conversation.statuses # => { "active" => 0, "archived" => 1 }
```

ดูเอกสารเพิ่มเติมได้ที่
[documentation](https://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html)

### Message Verifiers

Message verifiers สามารถใช้สร้างและตรวจสอบข้อความที่ถูกลงลายมือได้อย่างปลอดภัย สามารถใช้ส่งข้อมูลที่เป็นความลับเช่นตัวระบุการจำไว้และเพื่อน

เมธอด `Rails.application.message_verifier` จะส่งคืน message verifier ใหม่ที่ลงลายมือข้อความด้วยคีย์ที่ได้มาจาก secret_key_base และชื่อ message verifier ที่กำหนด:

```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# ยกเว้น ActiveSupport::MessageVerifier::InvalidSignature
```

### Module#concerning

วิธีที่เป็นธรรมชาติและไม่ซับซ้อนในการแยกหน้าที่ภายในคลาส:

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

ตัวอย่างนี้เทียบเท่ากับการกำหนด `EventTracking` module ในบรรทัดเดียวกัน แล้วขยายมันด้วย `ActiveSupport::Concern` แล้วผสมมันเข้ากับคลาส `Todo`

ดูเอกสารเพิ่มเติมได้ที่
[documentation](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html)

### การป้องกัน CSRF จากแท็ก `<script>` ระยะไกล

การป้องกันการโจมตีแบบของข้อมูลร้องขอข้ามไซต์ (CSRF) ตอนนี้รวมถึงการร้องขอ GET ที่มีการตอบสนองด้วย JavaScript ด้วย นั่นหมายความว่าเว็บไซต์ที่เป็นบุคคลที่สามจะไม่สามารถอ้างอิง URL ของ JavaScript ของคุณและพยายามเรียกใช้เพื่อดึงข้อมูลที่เป็นความลับได้

นี่หมายความว่าทดสอบของคุณที่เรียกใช้ URL ที่มีนามสกุล `.js` จะล้มเหลวการป้องกัน CSRF ยกเว้นว่าจะใช้ `xhr` อัพเกรดการทดสอบของคุณให้ชัดเจนเกี่ยวกับการคาดหวัง XmlHttpRequests แทน แทนที่จะใช้ `post :create, format: :js` เปลี่ยนเป็น `xhr :post, :create, format: :js`


Railties
--------

โปรดอ้างอิง
[Changelog](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md)
สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

* ลบงาน rake `update:application_controller`

* ลบ `Rails.application.railties.engines` ที่ถูกยกเลิก

* ลบ `threadsafe!` ที่ถูกยกเลิกจาก Rails Config

* ลบ `ActiveRecord::Generators::ActiveModel#update_attributes` ที่ถูกยกเลิกแล้วแทนด้วย `ActiveRecord::Generators::ActiveModel#update`

* ลบตัวเลือก `config.whiny_nils` ที่ถูกยกเลิก

* ลบงาน rake ที่ถูกยกเลิกสำหรับการเรียกใช้ทดสอบ: `rake test:uncommitted` และ `rake test:recent`

### การเปลี่ยนแปลงที่สำคัญ

* [Spring application
  preloader](https://github.com/rails/spring) ติดตั้งโดยค่าเริ่มต้นสำหรับแอปพลิเคชันใหม่ มันใช้กลุ่มการพัฒนาของ `Gemfile` ดังนั้นจะไม่ถูกติดตั้งในโหมดการใช้งานจริง ([Pull Request](https://github.com/rails/rails/pull/12958))

* ตัวแปร `BACKTRACE` ในสภาพแวดล้อมเพื่อแสดง backtraces ที่ไม่ได้กรองสำหรับความล้มเหลวของการทดสอบ ([Commit](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553))

* เปิดเผย `MiddlewareStack#unshift` เพื่อกำหนดค่าสภาพแวดล้อม ([Pull Request](https://github.com/rails/rails/pull/12479))

* เพิ่มเมธอด `Application#message_verifier` เพื่อส่งคืน message verifier ([Pull Request](https://github.com/rails/rails/pull/12995))

* ไฟล์ `test_help.rb` ที่ต้องการโดย test helper ที่สร้างขึ้นโดยค่าเริ่มต้นจะอัปเดตฐานข้อมูลทดสอบของคุณให้เป็นปัจจุบันกับ `db/schema.rb` (หรือ `db/structure.sql`) มันจะเรียกข้อผิดพลาดถ้าการโหลดฐานข้อมูลไม่สามารถแก้ไขปัญหาการเคลื่อนย้ายที่ค้างอยู่ได้ ปิดการใช้งานด้วย `config.active_record.maintain_test_schema = false` ([Pull Request](https://github.com/rails/rails/pull/13528))

* เพิ่ม `Rails.gem_version` เป็นเมธอดที่สะดวกในการส่งคืน `Gem::Version.new(Rails.version)` เสนอวิธีการเปรียบเทียบเวอร์ชันที่เป็นที่น่าเชื่อถือมากขึ้น ([Pull Request](https://github.com/rails/rails/pull/14103))


Action Pack
-----------

โปรดอ้างอิง
[Changelog](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md)
สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

* ลบการสำรองที่ถูกยกเลิกของแอปพลิเคชัน Rails สำหรับการทดสอบการรวมกัน ตั้งค่า `ActionDispatch.test_app` แทน

* ลบการกำหนดค่า `page_cache_extension` ที่ถูกยกเลิก

* ลบค่าคงที่ที่ถูกยกเลิกจาก Action Controller:

| ถูกลบ                            | ผู้สืบทอด                       |
|:-----------------------------------|:--------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### การเปลี่ยนแปลงที่สำคัญ

* `protect_from_forgery` ยังป้องกันแท็ก `<script>` ข้ามเขตด้วย อัพเกรดการทดสอบของคุณให้ใช้ `xhr :get, :foo, format: :js` แทน `get :foo, format: :js` ([Pull Request](https://github.com/rails/rails/pull/13345))

* `#url_for` รับแอเรย์ที่มีตัวเลือกภายในเป็นแฮช ([Pull Request](https://github.com/rails/rails/pull/9599))

* เพิ่มเมธอด `session#fetch` ซึ่งทำงานเช่นเดียวกับ [Hash#fetch](https://www.ruby-doc.org/core-1.9
* แยก Action View ออกจาก Action Pack อย่างสมบูรณ์ ([Pull Request](https://github.com/rails/rails/pull/11032))

* บันทึกคีย์ที่ได้รับผลกระทบจาก deep munge ([Pull Request](https://github.com/rails/rails/pull/13813))

* ตัวเลือกการกำหนดค่าใหม่ `config.action_dispatch.perform_deep_munge` เพื่อไม่ใช้ params "deep munging" ที่ใช้เพื่อแก้ไขช่องโหว่ด้านความปลอดภัย CVE-2013-0155 ([Pull Request](https://github.com/rails/rails/pull/13188))

* ตัวเลือกการกำหนดค่าใหม่ `config.action_dispatch.cookies_serializer` เพื่อระบุตัวแปรสำหรับ signed และ encrypted cookie jars (Pull Requests [1](https://github.com/rails/rails/pull/13692), [2](https://github.com/rails/rails/pull/13945) / [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#cookies-serializer))

* เพิ่ม `render :plain`, `render :html` และ `render :body` ([Pull Request](https://github.com/rails/rails/pull/14062) / [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#rendering-content-from-string))


Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

* เพิ่มฟีเจอร์ mailer previews ที่อ้างอิงจาก gem 37 Signals mail_view ([Commit](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261))

* เพิ่มการตรวจวัดการสร้างข้อความ Action Mailer เวลาที่ใช้ในการสร้างข้อความจะถูกบันทึกใน log ([Pull Request](https://github.com/rails/rails/pull/12556))


Active Record
-------------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

* ลบเมธอด `primary_keys`, `tables`, `columns` และ `columns_hash` ใน `SchemaCache` ที่ถูกยกเลิก

* ลบการใช้งานบล็อกฟิลเตอร์ที่ถูกยกเลิกจาก `ActiveRecord::Migrator#migrate`

* ลบเมธอด String constructor ที่ถูกยกเลิกจาก `ActiveRecord::Migrator`

* ลบการใช้งาน `scope` ที่ถูกยกเลิกโดยไม่ส่ง callable object

* ลบการใช้งาน `transaction_joinable=` ที่ถูกยกเลิกและใช้ `begin_transaction` พร้อม `:joinable` option แทน

* ลบเมธอด `decrement_open_transactions` ที่ถูกยกเลิก

* ลบเมธอด `increment_open_transactions` ที่ถูกยกเลิก

* ลบเมธอด `PostgreSQLAdapter#outside_transaction?` ที่ถูกยกเลิก สามารถใช้ `#transaction_open?` แทน

* ลบเมธอด `ActiveRecord::Fixtures.find_table_name` ที่ถูกยกเลิกและใช้ `ActiveRecord::Fixtures.default_fixture_model_name` แทน

* ลบเมธอด `columns_for_remove` จาก `SchemaStatements` ที่ถูกยกเลิก

* ลบเมธอด `SchemaStatements#distinct` ที่ถูกยกเลิก

* ย้าย `ActiveRecord::TestCase` ที่ถูกยกเลิกเข้าไปในชุดทดสอบของ Rails คลาสไม่เป็นสาธารณะและใช้เฉพาะในการทดสอบภายใน Rails เท่านั้น

* ลบการสนับสนุนตัวเลือกที่ถูกยกเลิก `:restrict` สำหรับ `:dependent` ในการเชื่อมโยง

* ลบการสนับสนุน `:delete_sql`, `:insert_sql`, `:finder_sql` และ `:counter_sql` ที่ถูกยกเลิกสำหรับการเชื่อมโยง

* ลบเมธอด `type_cast_code` ที่ถูกยกเลิกจาก Column

* ลบเมธอด `ActiveRecord::Base#connection` ที่ถูกยกเลิก ตรวจสอบการเข้าถึงผ่านคลาส

* ลบคำเตือนการถอดรหัสอัตโนมัติสำหรับ `auto_explain_threshold_in_seconds`

* ลบตัวเลือก `:distinct` ที่ถูกยกเลิกจาก `Relation#count`

* ลบเมธอดที่ถูกยกเลิก `partial_updates`, `partial_updates?` และ `partial_updates=`

* ลบเมธอดที่ถูกยกเลิก `scoped`

* ลบเมธอดที่ถูกยกเลิก `default_scopes?`

* ลบการอ้างอิงการเชื่อมต่อที่ถูกยกเลิกที่ไม่ได้ระบุใน 4.0

* ลบ `activerecord-deprecated_finders` เป็น dependency โปรดดู [README ของ gem](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders) สำหรับข้อมูลเพิ่มเติม

* ลบการใช้งาน `implicit_readonly` โปรดใช้เมธอด `readonly` โดยชัดเจนเพื่อทำเครื่องหมายว่าเร็คคอร์ดเป็น `readonly` ([Pull Request](https://github.com/rails/rails/pull/10769))

### การเลิกใช้งาน

* เลิกใช้งานเมธอด `quoted_locking_column` ที่ไม่ได้ใช้ที่ไหน

* เลิกใช้งาน `ConnectionAdapters::SchemaStatements#distinct` เนื่องจากไม่ได้ใช้ในส่วนใน ([Pull Request](https://github.com/rails/rails/pull/10556))

* เลิกใช้งานงาน `rake db:test:*` เนื่องจากฐานข้อมูลทดสอบถูกบำรุงรักษาโดยอัตโนมัติแล้ว โปรดดู release notes ของ railties ([Pull Request](https://github.com/rails/rails/pull/13528))

* เลิกใช้งาน `ActiveRecord::Base.symbolized_base_class` และ `ActiveRecord::Base.symbolized_sti_name` ที่ไม่ได้ใช้งานและไม่มีการแทนที่ [Commit](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)

### การเปลี่ยนแปลงที่สำคัญ

* Default scopes ไม่ถูกแทนที่โดยเงื่อนไขที่เชื่อมต่อ

  ก่อนการเปลี่ยนแปลงนี้เมื่อคุณกำหนด `default_scope` ในโมเดล มันถูกแทนที่โดยเงื่อนไขที่เชื่อมต่อในฟิลด์เดียวกัน ตอนนี้มันถูกผสมรวมเหมือนสเก็ต
* ทำให้ `next_migration_number` เข้าถึงได้สำหรับ generators จากภายนอก ([Pull Request](https://github.com/rails/rails/pull/12407))

* เรียกใช้ `update_attributes` จะเกิด `ArgumentError` เมื่อได้รับอาร์กิวเมนต์ที่เป็น `nil` โดยเฉพาะ โดยจะเกิดข้อผิดพลาดถ้าอาร์กิวเมนต์ที่ได้รับไม่สามารถตอบสนองกับ `stringify_keys` ([Pull Request](https://github.com/rails/rails/pull/9860))

* `CollectionAssociation#first`/`#last` (เช่น `has_many`) ใช้คำสั่ง `LIMIT` เพื่อเรียกดูผลลัพธ์แทนที่จะโหลดคอลเลกชันทั้งหมด ([Pull Request](https://github.com/rails/rails/pull/12137))

* `inspect` ในคลาส Active Record model จะไม่เริ่มการเชื่อมต่อใหม่ นั่นหมายความว่าการเรียกใช้ `inspect` เมื่อไม่มีฐานข้อมูลจะไม่เกิดข้อผิดพลาด ([Pull Request](https://github.com/rails/rails/pull/11014))

* ลบข้อจำกัดคอลัมน์สำหรับ `count` ให้ฐานข้อมูลเกิดข้อผิดพลาดหาก SQL ไม่ถูกต้อง ([Pull Request](https://github.com/rails/rails/pull/10710))

* Rails ตอนนี้สามารถตรวจหา inverse associations ได้โดยอัตโนมัติ หากคุณไม่ตั้งค่า `:inverse_of` ในการเชื่อมโยง แล้ว Active Record จะเดา inverse association จากการทำนาย ([Pull Request](https://github.com/rails/rails/pull/10886))

* จัดการกับ attribute ที่ตั้งชื่อใหม่ใน ActiveRecord::Relation โดยเมื่อใช้ symbol keys ActiveRecord จะแปลงชื่อ attribute ที่ตั้งชื่อใหม่เป็นชื่อคอลัมน์จริงที่ใช้ในฐานข้อมูล ([Pull Request](https://github.com/rails/rails/pull/7839))

* ERB ในไฟล์ fixture จะไม่ถูกประเมินในบริบทของอ็อบเจกต์หลักแล้ว ฟังก์ชันช่วยเหลือที่ใช้ใน fixture หลายรูปแบบควรถูกกำหนดในโมดูลที่รวมอยู่ใน `ActiveRecord::FixtureSet.context_class` ([Pull Request](https://github.com/rails/rails/pull/13022))

* ไม่สร้างหรือลบฐานข้อมูลทดสอบหาก RAILS_ENV ถูกระบุโดยชัดเจน ([Pull Request](https://github.com/rails/rails/pull/13629))

* `Relation` ไม่มีเมธอด mutator เช่น `#map!` และ `#delete_if` แปลงเป็น `Array` โดยเรียกใช้ `#to_a` ก่อนใช้เมธอดเหล่านี้ ([Pull Request](https://github.com/rails/rails/pull/13314))

* `find_in_batches`, `find_each`, `Result#each` และ `Enumerable#index_by` ตอนนี้ส่งคืน `Enumerator` ที่สามารถคำนวณขนาดได้ ([Pull Request](https://github.com/rails/rails/pull/13938))

* `scope`, `enum` และ Associations ตอนนี้เกิดข้อผิดพลาดเมื่อมีความขัดแย้งในชื่อที่ถือว่า "อันตราย" ([Pull Request](https://github.com/rails/rails/pull/13450), [Pull Request](https://github.com/rails/rails/pull/13896))

* เมธอด `second` ถึง `fifth` ทำงานเหมือนกับเมธอด `first` ([Pull Request](https://github.com/rails/rails/pull/13757))

* ทำให้ `touch` เรียกใช้ `after_commit` และ `after_rollback` callbacks ([Pull Request](https://github.com/rails/rails/pull/12031))

* เปิดใช้งาน partial indexes สำหรับ `sqlite >= 3.8.0` ([Pull Request](https://github.com/rails/rails/pull/13350))

* ทำให้ `change_column_null` เปลี่ยนกลับได้ ([Commit](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96))

* เพิ่มตัวแปรเพื่อปิดการสร้าง schema หลังจาก migration นี้ ค่าเริ่มต้นในสภาพแวดล้อมการใช้งานจริงสำหรับแอปพลิเคชันใหม่คือ `false` ([Pull Request](https://github.com/rails/rails/pull/13948))

Active Model
------------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเลิกใช้งาน

* เลิกใช้งาน `Validator#setup` ควรทำเองในคอนสตรักเตอร์ของ validator ([Commit](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a))

### การเปลี่ยนแปลงที่สำคัญ

* เพิ่มเมธอด API ใหม่ `reset_changes` และ `changes_applied` ใน `ActiveModel::Dirty` ที่ควบคุมสถานะการเปลี่ยนแปลง

* สามารถระบุ context หลายรูปแบบเมื่อกำหนด validation ([Pull Request](https://github.com/rails/rails/pull/13754))

* `attribute_changed?` ตอนนี้ยอมรับ hash เพื่อตรวจสอบว่า attribute มีการเปลี่ยนแปลง `:from` และ/หรือ `:to` ค่าที่กำหนด ([Pull Request](https://github.com/rails/rails/pull/13131))


Active Support
--------------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

* เอาออก `MultiJSON` dependency ซึ่งทำให้ `ActiveSupport::JSON.decode` ไม่รับ options hash สำหรับ `MultiJSON` อีกต่อไป ([Pull Request](https://github.com/rails/rails/pull/10576) / [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))

* เอาออกการสนับสนุนสำหรับ `encode_json` hook ที่ใช้สำหรับการเข้ารหัสอ็อบเจกต์ที่กำหนดเองเป็น JSON คุณลักษณะนี้ถูกแยกออกเป็น [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem ([Related Pull Request](https://github.com/rails/rails/pull/12183) / [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))

* เอาออก `ActiveSupport::JSON::Variable` ที่ถูกเลิกใช้งานโดยไม่มีทางเปลี่ยนแทน

* เอาออก core extensions `String#encoding_aware?` (`core_ext/string/encoding`) ที่ถูกเลิกใช้งาน

* เอาออก `Module#local_constant_names` ที่ถูกเลิกใช้งานเพื่อใช้ `Module#local_constants` แทน

* เอาออก `DateTime.local_offset` ที่ถูกเลิก
* ลบการเอา 'cow' => 'kine' ออกจากการผันคำที่ไม่เป็นปกติของค่าเริ่มต้น ([Commit](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9))

### การเลิกใช้งาน

* เลิกใช้งาน `Numeric#{ago,until,since,from_now}` และคาดว่าผู้ใช้จะแปลงค่าเป็น AS::Duration โดยชัดเจน เช่น `5.ago` => `5.seconds.ago` ([Pull Request](https://github.com/rails/rails/pull/12389))

* เลิกใช้งานเส้นทางการต้องการ `active_support/core_ext/object/to_json` และต้องการ `active_support/core_ext/object/json` แทน ([Pull Request](https://github.com/rails/rails/pull/12203))

* เลิกใช้งาน `ActiveSupport::JSON::Encoding::CircularReferenceError` คุณลักษณะนี้ถูกแยกออกเป็น gem [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) ([Pull Request](https://github.com/rails/rails/pull/12785) / [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))

* เลิกใช้งานตัวเลือก `ActiveSupport.encode_big_decimal_as_string` คุณลักษณะนี้ถูกแยกออกเป็น gem [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) ([Pull Request](https://github.com/rails/rails/pull/13060) / [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))

* เลิกใช้งานการตั้งค่า `BigDecimal` ที่กำหนดเอง ([Pull Request](https://github.com/rails/rails/pull/13911))

### การเปลี่ยนแปลงที่สำคัญ

* ได้เขียนรหัสเข้ารหัส JSON ของ `ActiveSupport` ใหม่ให้ใช้ประโยชน์จาก gem JSON แทนที่จะใช้การเข้ารหัสที่กำหนดเองในรูปแบบของ pure-Ruby ([Pull Request](https://github.com/rails/rails/pull/12183) / [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))

* ปรับปรุงความเข้ากันได้กับ gem JSON ([Pull Request](https://github.com/rails/rails/pull/12862) / [รายละเอียดเพิ่มเติม](upgrading_ruby_on_rails.html#changes-in-json-handling))

* เพิ่ม `ActiveSupport::Testing::TimeHelpers#travel` และ `#travel_to` วิธีนี้จะเปลี่ยนเวลาปัจจุบันเป็นเวลาหรือระยะเวลาที่กำหนดโดยการ stub `Time.now` และ `Date.today`

* เพิ่ม `ActiveSupport::Testing::TimeHelpers#travel_back` วิธีนี้จะคืนเวลาปัจจุบันกลับสู่สถานะเดิมโดยการลบ stub ที่เพิ่มโดย `travel` และ `travel_to` ([Pull Request](https://github.com/rails/rails/pull/13884))

* เพิ่ม `Numeric#in_milliseconds` เช่น `1.hour.in_milliseconds` เพื่อให้สามารถใช้งานกับฟังก์ชัน JavaScript เช่น `getTime()` ได้ ([Commit](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643))

* เพิ่ม `Date#middle_of_day`, `DateTime#middle_of_day` และ `Time#middle_of_day` และเพิ่ม `midday`, `noon`, `at_midday`, `at_noon` และ `at_middle_of_day` เป็นตัวย่อ ([Pull Request](https://github.com/rails/rails/pull/10879))

* เพิ่ม `Date#all_week/month/quarter/year` เพื่อสร้างช่วงวันที่ ([Pull Request](https://github.com/rails/rails/pull/9685))

* เพิ่ม `Time.zone.yesterday` และ `Time.zone.tomorrow` ([Pull Request](https://github.com/rails/rails/pull/12822))

* เพิ่ม `String#remove(pattern)` เป็นรูปแบบสั้นๆ สำหรับรูปแบบที่พบบ่อยของ `String#gsub(pattern,'')` ([Commit](https://github.com/rails/rails/commit/5da23a3f921f0a4a3139495d2779ab0d3bd4cb5f))

* เพิ่ม `Hash#compact` และ `Hash#compact!` เพื่อลบรายการที่มีค่าเป็น nil ออกจาก hash ([Pull Request](https://github.com/rails/rails/pull/13632))

* `blank?` และ `present?` จะคืนค่าเป็น singletons ([Commit](https://github.com/rails/rails/commit/126dc47665c65cd129967cbd8a5926dddd0aa514))

* ตั้งค่า `I18n.enforce_available_locales` ใหม่เป็น `true` ซึ่งหมายความว่า `I18n` จะตรวจสอบให้แน่ใจว่าทุกโลเคลที่ส่งให้กับมันต้องถูกประกาศในรายการ `available_locales` ([Pull Request](https://github.com/rails/rails/pull/13341))

* เพิ่ม `Module#concerning` เป็นวิธีที่เป็นธรรมชาติและไม่ซับซ้อนในการแยกความรับผิดชอบภายในคลาส ([Commit](https://github.com/rails/rails/commit/1eee0ca6de975b42524105a59e0521d18b38ab81))

* เพิ่ม `Object#presence_in` เพื่อให้ง่ายต่อการเพิ่มค่าในรายการที่อนุญาต ([Commit](https://github.com/rails/rails/commit/4edca106daacc5a159289eae255207d160f22396))


เครดิต
-------

ดูรายชื่อเต็มของผู้มีส่วนร่วมใน Rails ได้ที่ [full list of contributors to Rails](https://contributors.rubyonrails.org/) สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและทนทาน ยินดีด้วยทุกคน
