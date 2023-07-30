**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 77b47af4826df984dead9f6263cfd135
เอกสารปล่อยตัวของ Ruby on Rails 2.3
===============================

Rails 2.3 มอบให้คุณได้สัมผัสกับคุณลักษณะใหม่และปรับปรุงที่หลากหลาย รวมถึงการรวม Rack อย่างแพร่หลาย, การสนับสนุน Rails Engines ที่อัพเดตใหม่, การทำงานของการทำธุรกรรมซ้อนกันสำหรับ Active Record, การกำหนดเป็นค่าเริ่มต้นและสเกลไดนามิก, การเรนเดอร์อย่างสมดุลย์, เส้นทางที่มีประสิทธิภาพมากขึ้น, เทมเพลตแอปพลิเคชัน, และการแสดงผลข้อผิดพลาดอย่างเงียบ รายการนี้จะครอบคลุมการอัพเกรดที่สำคัญ แต่ไม่รวมถึงการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงทุกอย่าง หากคุณต้องการดูทุกอย่าง โปรดตรวจสอบ [รายการคอมมิต](https://github.com/rails/rails/commits/2-3-stable) ในเก็บรักษาของ Rails หลักบน GitHub หรือตรวจสอบไฟล์ `CHANGELOG` สำหรับคอมโพเนนต์ของ Rails แต่ละส่วน

--------------------------------------------------------------------------------

สถาปัตยกรรมแอปพลิเคชัน
------------------------

มีการเปลี่ยนแปลงสำคัญสองอย่างในสถาปัตยกรรมของแอปพลิเคชัน Rails: การรวมสมบูรณ์ของอินเตอร์เฟซเว็บเซิร์ฟเวอร์แบบโมดูล Rack และการสนับสนุน Rails Engines ที่อัพเดตใหม่

### การรวม Rack

Rails ตอนนี้ได้ยกเลิกการใช้ CGI และใช้ Rack ทั่วไป นี่เป็นการเปลี่ยนแปลงที่ต้องการและผลให้เกิดการเปลี่ยนแปลงภายในมากมาย (แต่หากคุณใช้ CGI ไม่ต้องกังวล เนื่องจาก Rails ตอนนี้สนับสนุน CGI ผ่านอินเตอร์เฟซโปรกซี่) แต่ยังคงเป็นการเปลี่ยนแปลงที่สำคัญสำหรับส่วนที่ด้านในของ Rails หลังจากอัพเกรดเป็นเวอร์ชัน 2.3 คุณควรทดสอบในสภาพแวดล้อมท้องถิ่นและสภาพแวดล้อมการใช้งานจริง สิ่งที่คุณควรทดสอบ:

* เซสชัน
* คุกกี้
* การอัปโหลดไฟล์
* JSON/XML APIs

นี่คือสรุปของการเปลี่ยนแปลงที่เกี่ยวข้องกับ Rack:

* `script/server` ได้ถูกเปลี่ยนให้ใช้ Rack ซึ่งหมายความว่ามันสนับสนุนเซิร์ฟเวอร์ที่เข้ากันได้กับ Rack ใดก็ได้ `script/server` ยังจะเรียกใช้ไฟล์กำหนดค่า rackup หากมีอยู่ โดยค่าเริ่มต้นจะค้นหาไฟล์ `config.ru` แต่คุณสามารถเขียนทับได้ด้วยการใช้สวิตช์ `-c`
* ตัวจัดการ FCGI ผ่าน Rack
* `ActionController::Dispatcher` รักษาสแต็กของ middleware เริ่มต้นของตัวเอง สามารถฝัง middleware เข้าไป จัดลำดับใหม่ และลบออกได้ สแต็กจะถูกคอมไพล์เป็นเชือกในขณะที่เริ่มต้น คุณสามารถกำหนดคอลเลกชันของ middleware ใน `environment.rb`
* เพิ่มงาน `rake middleware` เพื่อตรวจสอบสแต็กของ middleware นี้เป็นประโยชน์ในการแก้ปัญหาการจัดลำดับของสแต็กของ middleware
* ตัวรันการทดสอบการรวมกับ middleware และสแต็กแอปพลิเคชันทั้งหมด ทำให้การทดสอบการรวมเป็นอย่างดีสำหรับการทดสอบ middleware ของ Rack
* `ActionController::CGIHandler` เป็นการห่อหุ้ม CGI ที่เข้ากันได้ย้อนกลับด้วย Rack `CGIHandler` จะรับอ็อบเจกต์ CGI เก่าและแปลงข้อมูลสภาพแวดล้อมให้เข้ากันได้กับ Rack
* `CgiRequest` และ `CgiResponse` ถูกลบออก
* การจัดเก็บเซสชันถูกโหลดเมื่อต้องการเท่านั้น หากคุณไม่เข้าถึงออบเจกต์เซสชันในระหว่างคำขอ เซสชันจะไม่พยายามโหลดข้อมูลเซสชัน (แยกคุกกี้, โหลดข้อมูลจาก memcache หรือค้นหาออบเจกต์ Active Record)
* คุณไม่จำเป็นต้องใช้ `CGI::Cookie.new` ในการทดสอบสำหรับการกำหนดค่าคุกกี้ การกำหนดค่าค่าสตริงให้กับ `request.cookies["foo"]` จะตั้งค่าคุกกี้ตามที่คาดหวัง
* `CGI::Session::CookieStore` ถูกแทนที่ด้วย `ActionController::Session::CookieStore`
* `CGI::Session::MemCacheStore` ถูกแทนที่ด้วย `ActionController::Session::MemCacheStore`
* `CGI::Session::ActiveRecordStore` ถูกแทนที่ด้วย `ActiveRecord::SessionStore`
* คุณยังคงสามารถเปลี่ยนการจัดเก็บเซสชันของคุณด้วย `ActionController::Base.session_store = :active_record_store`
* ตัวเลือกเริ่มต้นของเซสชันยังคงถูกตั้งค่าด้วย `ActionController::Base.session = { :key => "..." }` อย่างไรก็ตาม ตัวเลือก `:session_domain` ถูกเปลี่ยนชื่อเป็น `:domain`
* มิวเท็กซ์ที่ครอบคลุมคำขอทั้งหมดได้ถูกย้ายไปอยู่ใน middleware `ActionController::Lock`
* `ActionController::AbstractRequest` และ `ActionController::Request` ถูกรวมเข้าด้วยกัน คลาสใหม่ `ActionController::Request` สืบทอดมาจาก `Rack::Request` ส่งผลต่อการเข้าถึง `response.headers['type']` ในคำขอการทดสอบ ให้ใช้ `response.content_type` แทน
* มิวเท็กซ์ `ActiveRecord::QueryCache` ถูกแทรกอัตโนมัติลงในสแต็กของ middleware หาก `ActiveRecord` ถูกโหลด มิวเท็กซ์นี้จะตั้งค่าและล้างแคชคิวรีของ Active Record ต่อคำขอ
* เราท์เตอร์และคลาสคอนโทรลเลอร์ของ Rails ปฏิบัติตามสเปคของ Rack คุณสามารถเรียกคอนโทรลเลอร์โดยตรงด้วย `SomeController.call(env)` เราท์เตอร์จะเก็บพารามิเตอร์เส้นทางใน `rack.routing_args`
* `ActionController::Request` สืบทอดมาจาก `Rack::Request`
* แทนที่ `config.action_controller.session = { :session_key => 'foo', ...` ด้วย `config.action_controller.session = { :key => 'foo', ...`
* การใช้ middleware `ParamsParser` จะทำการประมวลผลคำขอ XML, JSON, หรือ YAML ก่อนเพื่อให้สามารถอ่านได้ตามปกติด้วยอ็อบเจกต์ `Rack::Request` ใดก็ได้หลังจากนั้น
### การสนับสนุน Rails Engines ที่อัพเกรดแล้ว

หลังจากไม่ได้อัพเกรดเป็นเวอร์ชันใหม่ในบางรุ่น  Rails 2.3 นำเสนอคุณสมบัติใหม่สำหรับ Rails Engines (แอปพลิเคชัน Rails ที่สามารถฝังอยู่ในแอปพลิเคชันอื่น) คุณสมบัติแรกคือไฟล์เส้นทางใน engines จะถูกโหลดและโหลดซ้ำโดยอัตโนมัติตอนนี้เหมือนกับไฟล์ `routes.rb` ของคุณ (สิ่งนี้ยังใช้กับไฟล์เส้นทางในปลั๊กอินอื่น ๆ) คุณสมบัติที่สองคือหากปลั๊กอินของคุณมีโฟลเดอร์แอป แล้ว app/[models|controllers|helpers] จะถูกเพิ่มเข้าไปในเส้นทางการโหลดของ Rails โดยอัตโนมัติ Engines ยังสนับสนุนการเพิ่มเส้นทางมุมมองและ Action Mailer รวมถึง Action View จะใช้มุมมองจาก engines และปลั๊กอินอื่น ๆ

เอกสาร
-------------

โครงการ [Ruby on Rails guides](https://guides.rubyonrails.org/) ได้เผยแพร่คู่มือเพิ่มเติมสำหรับ Rails 2.3 นอกจากนี้ยังมี [เว็บไซต์แยกต่างหาก](https://edgeguides.rubyonrails.org/) ที่บันทึกสำเนาคู่มือสำหรับ Edge Rails การพยายามเอกสารอื่น ๆ รวมถึงการเริ่มต้นใหม่ของ [Rails wiki](http://newwiki.rubyonrails.org/) และการวางแผนเร็ว ๆ นี้สำหรับ Rails Book

* ข้อมูลเพิ่มเติม: [โครงการเอกสาร Rails](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)

การสนับสนุน Ruby 1.9.1
------------------

Rails 2.3 ควรผ่านการทดสอบของตัวเองทั้งหมดไม่ว่าคุณจะใช้ Ruby 1.8 หรือ Ruby 1.9.1 ที่เปิดตัวใหม่ อย่างไรก็ตามคุณควรทราบว่าการย้ายไปยัง 1.9.1 เป็นการตรวจสอบทุกฟังก์ชันข้อมูล ปลั๊กอิน และรหัสอื่น ๆ ที่คุณพึ่งพากับความเข้ากันได้ของ Ruby 1.9.1 รวมถึง Rails core

Active Record
-------------

Active Record ได้รับคุณสมบัติใหม่และการแก้ไขข้อบกพร่องจำนวนมากใน Rails 2.3 จุดเด่นของมันรวมถึง nested attributes, nested transactions, dynamic และ default scopes, และ batch processing

### Nested Attributes

Active Record สามารถอัปเดตแอตทริบิวต์บนโมเดลที่ซ้อนกันได้โดยตรง หากคุณบอกให้มันทำ:

```ruby
class Book < ActiveRecord::Base
  has_one :author
  has_many :pages

  accepts_nested_attributes_for :author, :pages
end
```

การเปิดใช้งาน nested attributes จะเปิดใช้งานสิ่งต่อไปนี้: การบันทึกอัตโนมัติ (และอะตอมิก) ของบันทึกพร้อมกับลูกโดยสารที่เกี่ยวข้อง การตรวจสอบที่ตระหนักถึงลูก และการสนับสนุนสำหรับฟอร์มที่ซ้อนกัน (ที่จะถูกพูดถึงในภายหลัง)
คุณยังสามารถระบุความต้องการสำหรับบันทึกใหม่ที่เพิ่มผ่าน nested attributes โดยใช้ตัวเลือก `:reject_if`:

```ruby
accepts_nested_attributes_for :author,
  :reject_if => proc { |attributes| attributes['name'].blank? }
```

* ผู้มีส่วนร่วมหลัก: [Eloy Duran](http://superalloy.nl/)
* ข้อมูลเพิ่มเติม: [Nested Model Forms](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)

### การทำธุรกรรมซ้อนกัน

Active Record ตอนนี้รองรับการทำธุรกรรมซ้อนกันซึ่งเป็นคุณสมบัติที่ถูกขอให้มากที่สุด ตอนนี้คุณสามารถเขียนโค้ดเช่นนี้ได้:

```ruby
User.transaction do
  User.create(:username => 'Admin')
  User.transaction(:requires_new => true) do
    User.create(:username => 'Regular')
    raise ActiveRecord::Rollback
  end
end

User.find(:all)  # => คืนค่าเฉพาะ Admin เท่านั้น
```

การทำธุรกรรมซ้อนกันช่วยให้คุณสามารถยกเลิกธุรกรรมภายในได้โดยไม่มีผลต่อสถานะของธุรกรรมภายนอก หากคุณต้องการให้ธุรกรรมซ้อนกัน คุณต้องเพิ่มตัวเลือก `:requires_new` โดยชัดเจน มิฉะนั้น ธุรกรรมซ้อนกันจะกลายเป็นส่วนหนึ่งของธุรกรรมหลัก (เหมือนกับที่เป็นใน Rails 2.2) ภายในธุรกรรมซ้อนกันใช้ [savepoints](http://rails.lighthouseapp.com/projects/8994/tickets/383) ดังนั้นการทำงานนี้สามารถทำได้แม้ว่าฐานข้อมูลจะไม่รองรับการทำธุรกรรมซ้อนกันจริง ๆ ยังมีการใช้เทคนิคบางอย่างเพื่อให้ธุรกรรมเหล่านี้ทำงานร่วมกับ transactional fixtures ในการทดสอบ

* ผู้มีส่วนร่วมหลัก: [Jonathan Viney](http://www.workingwithrails.com/person/4985-jonathan-viney) และ [Hongli Lai](http://izumi.plan99.net/blog/)

### Dynamic Scopes

คุณรู้เกี่ยวกับ dynamic finders ใน Rails (ซึ่งช่วยให้คุณสร้างเมธอดเช่น `find_by_color_and_flavor` ตามความต้องการ) และ named scopes (ซึ่งช่วยให้คุณแยกเงื่อนไขการค้นหาที่ใช้ซ้ำได้เป็นชื่อที่เข้าใจง่าย เช่น `currently_active`) ตอนนี้คุณสามารถใช้ dynamic scope methods ได้ ความคิดคือการรวมไวยากรณ์ที่ช่วยให้คุณกรองข้อมูลตามความต้องการและเชื่อมต่อเมธอดเข้าด้วยกัน เช่น:

```ruby
Order.scoped_by_customer_id(12)
Order.scoped_by_customer_id(12).find(:all,
  :conditions => "status = 'open'")
Order.scoped_by_customer_id(12).scoped_by_status("open")
```

ไม่ต้องกำหนดอะไรเพิ่มเติมเพื่อใช้ dynamic scopes: มันทำงานอย่างง่ายดาย

* ผู้มีส่วนร่วมหลัก: [Yaroslav Markin](http://evilmartians.com/)
* ข้อมูลเพิ่มเติม: [What's New in Edge Rails: Dynamic Scope Methods](http://archives.ryandaigle.com/articles/2008/12/29/what-s-new-in-edge-rails-dynamic-scope-methods)

### Default Scopes

Rails 2.3 จะนำเสนอแนวคิดของ _default scopes_ ที่คล้ายกับ named scopes แต่ใช้กับทุก named scopes หรือเมธอด find ภายในโมเดล ตัวอย่างเช่น คุณสามารถเขียน `default_scope :order => 'name ASC'` และทุกครั้งที่คุณเรียกดึงข้อมูลจากโมเดลนั้น ข้อมูลจะถูกเรียงตามชื่อ (ยกเว้นถ้าคุณเขียนทับตัวเลือกนั้น แน่นอน)
* ผู้มีส่วนร่วมหลัก: Paweł Kondzior
* ข้อมูลเพิ่มเติม: [สิ่งใหม่ใน Edge Rails: Default Scoping](http://archives.ryandaigle.com/articles/2008/11/18/what-s-new-in-edge-rails-default-scoping)

### Batch Processing

คุณสามารถประมวลผลจำนวนมากของเร็คคอร์ดจาก Active Record model โดยใช้หน่วยความจำน้อยลงด้วย `find_in_batches`:

```ruby
Customer.find_in_batches(:conditions => {:active => true}) do |customer_group|
  customer_group.each { |customer| customer.update_account_balance! }
end
```

คุณสามารถส่งค่าตัวเลือกใน `find` เข้าไปใน `find_in_batches` ได้เกือบทั้งหมด อย่างไรก็ตาม คุณไม่สามารถระบุลำดับของเร็คคอร์ดที่จะถูกส่งคืน (เร็คคอร์ดจะถูกส่งคืนเสมอในลำดับของ primary key ที่เป็นจำนวนเต็ม ซึ่งต้องเป็นจำนวนเต็ม) หรือใช้ตัวเลือก `:limit` แทน แทนที่นั้น ให้ใช้ตัวเลือก `:batch_size` ซึ่งมีค่าเริ่มต้นเป็น 1000 เพื่อตั้งค่าจำนวนเร็คคอร์ดที่จะถูกส่งคืนในแต่ละกลุ่ม

เมธอดใหม่ `find_each` ให้คลุม `find_in_batches` และส่งคืนเรคคอร์ดแต่ละรายการ โดยการค้นหาเองจะทำในแบบกลุ่ม (โดยค่าเริ่มต้นคือ 1000):

```ruby
Customer.find_each do |customer|
  customer.update_account_balance!
end
```

โปรดทราบว่าคุณควรใช้เมธอดนี้เฉพาะสำหรับการประมวลผลแบบกลุ่ม: สำหรับจำนวนเร็คคอร์ดที่น้อย (น้อยกว่า 1000) คุณควรใช้เมธอดค้นหาปกติพร้อมกับลูปของคุณเอง

* ข้อมูลเพิ่มเติม (ในจุดนั้น มีการเรียกใช้เมธอดสะดวกเพียงแค่ `each`):
    * [Rails 2.3: Batch Finding](http://afreshcup.com/2009/02/23/rails-23-batch-finding/)
    * [สิ่งใหม่ใน Edge Rails: Batched Find](http://archives.ryandaigle.com/articles/2009/2/23/what-s-new-in-edge-rails-batched-find)

### เงื่อนไขหลายอย่างสำหรับ Callbacks

เมื่อใช้ Active Record callbacks คุณสามารถรวม `:if` และ `:unless` ได้ใน callback เดียวกัน และส่งเงื่อนไขหลายอย่างเป็นอาร์เรย์:

```ruby
before_save :update_credit_rating, :if => :active,
  :unless => [:admin, :cash_only]
```
* ผู้มีส่วนร่วมหลัก: L. Caviola

### ค้นหาพร้อมกับการมี

Rails ตอนนี้มีตัวเลือก `:having` ในการค้นหา (รวมถึงใน `has_many` และ `has_and_belongs_to_many` associations) เพื่อกรองเรคคอร์ดในการค้นหาที่มีการจัดกลุ่ม ตามที่ผู้ที่มีพื้นหลัง SQL หนักรู้ว่าสิ่งนี้ช่วยกรองตามผลลัพธ์ที่จัดกลุ่ม:

```ruby
developers = Developer.find(:all, :group => "salary",
  :having => "sum(salary) > 10000", :select => "salary")
```
* ผู้มีส่วนร่วมหลัก: [Emilio Tagua](https://github.com/miloops)

### การเชื่อมต่อ MySQL อีกครั้ง

MySQL สนับสนุนตัวชี้วัดการเชื่อมต่อในการเชื่อมต่อของมัน - หากตั้งค่าเป็น true แล้วไคลเอ็นต์จะพยายามเชื่อมต่อกับเซิร์ฟเวอร์อีกครั้งก่อนที่จะยกเลิกการเชื่อมต่อในกรณีที่เกิดการสูญเสียการเชื่อมต่อ คุณสามารถตั้งค่า `reconnect = true` สำหรับการเชื่อมต่อ MySQL ใน `database.yml` เพื่อให้ได้พฤติกรรมนี้จากแอปพลิเคชัน Rails ค่าเริ่มต้นคือ `false` ดังนั้นพฤติกรรมของแอปพลิเคชันที่มีอยู่ไม่เปลี่ยนแปลง

* ผู้มีส่วนร่วมหลัก: [Dov Murik](http://twitter.com/dubek)
* ข้อมูลเพิ่มเติม:
    * [การควบคุมพฤติกรรมการเชื่อมต่ออัตโนมัติ](http://dev.mysql.com/doc/refman/5.6/en/auto-reconnect.html)
    * [การเชื่อมต่ออัตโนมัติของ MySQL ที่ถูกต้อง](http://groups.google.com/group/rubyonrails-core/browse_thread/thread/49d2a7e9c96cb9f4)

### การเปลี่ยนแปลง Active Record อื่น ๆ

* ลบ `AS` เพิ่มเติมออกจาก SQL ที่สร้างขึ้นสำหรับการโหลดล่วงหน้า `has_and_belongs_to_many` เพื่อให้ทำงานได้ดีขึ้นสำหรับฐานข้อมูลบางประเภท
* `ActiveRecord::Base#new_record?` ตอนนี้จะคืนค่า `false` แทนที่จะคืนค่า `nil` เมื่อเจอบันทึกที่มีอยู่แล้ว
* แก้ไขข้อบกพร่องในการอ้างอิงชื่อตารางในบางความสัมพันธ์ `has_many :through`
* ตอนนี้คุณสามารถระบุ timestamp ที่เฉพาะเวลาสำหรับ `updated_at` timestamps: `cust = Customer.create(:name => "ABC Industries", :updated_at => 1.day.ago)`
* ข้อความข้อผิดพลาดที่ดีขึ้นเมื่อเรียกใช้ `find_by_attribute!` ไม่สำเร็จ
* การสนับสนุน `to_xml` ของ Active Record ยืดหยุ่นขึ้นเล็กน้อยด้วยการเพิ่มตัวเลือก `:camelize`
* แก้ไขข้อบกพร่องในการยกเลิก callback จาก `before_update` หรือ `before_create`
* เพิ่มงาน Rake สำหรับทดสอบฐานข้อมูลผ่าน JDBC
* `validates_length_of` จะใช้ข้อความข้อผิดพลาดที่กำหนดเองด้วยตัวเลือก `:in` หรือ `:within` (หากมีการระบุ)
* การนับบนการเลือกที่มีขอบเขตทำงานได้ถูกต้องเรียบร้อยแล้ว ดังนั้นคุณสามารถทำสิ่งต่าง ๆ เช่น `Account.scoped(:select => "DISTINCT credit_limit").count`
* `ActiveRecord::Base#invalid?` ตอนนี้ทำงานเป็นตรงกันข้ามกับ `ActiveRecord::Base#valid?`

Action Controller
-----------------

Action Controller มีการเปลี่ยนแปลงที่สำคัญในการแสดงผลรวมถึงการปรับปรุงในการเส้นทางและพื้นที่อื่น ๆ ในการเปิดตัวในรุ่นนี้

### การแสดงผลรวม

`ActionController::Base#render` มีความฉลาดมากขึ้นในการตัดสินใจว่าจะแสดงผลอะไร ตอนนี้คุณสามารถบอกให้มันแสดงผลและคาดหวังผลลัพธ์ที่ถูกต้องได้ ในรุ่นเก่าของ Rails คุณต้องให้ข้อมูลชัดเจนให้กับการแสดงผล:
```ruby
render :file => '/tmp/random_file.erb'
render :template => 'other_controller/action'
render :action => 'show'
```

ใน Rails 2.3 เราสามารถระบุสิ่งที่ต้องการ render ได้โดยตรง:

```ruby
render '/tmp/random_file.erb'
render 'other_controller/action'
render 'show'
render :show
```

Rails จะเลือกการ render ระหว่าง file, template, และ action ขึ้นอยู่กับว่ามีเครื่องหมาย / นำหน้า, / ภายใน, หรือไม่มีเครื่องหมาย / เลยในสิ่งที่ต้องการ render โปรดทราบว่าคุณยังสามารถใช้สัญลักษณ์แทนสตริงเมื่อ render action ได้ รูปแบบการ render อื่น ๆ (`:inline`, `:text`, `:update`, `:nothing`, `:json`, `:xml`, `:js`) ยังต้องระบุตัวเลือกโดยชัดเจน

### แอพพลิเคชันควบคุมเปลี่ยนชื่อ

หากคุณเป็นคนหนึ่งที่รู้สึกไม่พอใจกับการตั้งชื่อเฉพาะกรณีของ `application.rb` ของ Rails ในเวอร์ชัน 2.3 นี้คุณสามารถเรียนรู้ได้ว่ามันถูกแก้ไขเป็น `application_controller.rb` แล้ว นอกจากนี้ยังมี rake task ใหม่ชื่อ `rake rails:update:application_controller` ที่จะทำการเปลี่ยนชื่อโดยอัตโนมัติสำหรับคุณ - และมันจะถูกเรียกใช้เป็นส่วนหนึ่งของกระบวนการ `rake rails:update` ปกติ

* ข้อมูลเพิ่มเติม:
    * [The Death of Application.rb](https://afreshcup.com/home/2008/11/17/rails-2x-the-death-of-applicationrb)
    * [What's New in Edge Rails: Application.rb Duality is no More](http://archives.ryandaigle.com/articles/2008/11/19/what-s-new-in-edge-rails-application-rb-duality-is-no-more)

### รองรับการตรวจสอบความถูกต้องของ HTTP Digest

ใน Rails ตอนนี้มีการรองรับการตรวจสอบความถูกต้องของ HTTP digest อยู่แล้ว ในการใช้งานคุณสามารถเรียกใช้ `authenticate_or_request_with_http_digest` พร้อมกับบล็อกที่ส่งคืนรหัสผ่านของผู้ใช้ (ซึ่งจะถูกแฮชและเปรียบเทียบกับข้อมูลประจำตัวที่ถูกส่ง):

```ruby
class PostsController < ApplicationController
  Users = {"dhh" => "secret"}
  before_filter :authenticate

  def secret
    render :text => "Password Required!"
  end

  private
  def authenticate
    realm = "Application"
    authenticate_or_request_with_http_digest(realm) do |name|
      Users[name]
    end
  end
end
```

* ผู้มีส่วนร่วมหลัก: [Gregg Kellogg](http://www.kellogg-assoc.com/)
* ข้อมูลเพิ่มเติม: [What's New in Edge Rails: HTTP Digest Authentication](http://archives.ryandaigle.com/articles/2009/1/30/what-s-new-in-edge-rails-http-digest-authentication)

### เส้นทางที่มีประสิทธิภาพมากขึ้น

มีการเปลี่ยนแปลงเส้นทางสำคัญสองอย่างใน Rails 2.3 คือ `formatted_` route helpers ถูกลบออกและใช้การส่ง `:format` เป็นตัวเลือกแทน สิ่งนี้ลดกระบวนการสร้างเส้นทางลง 50% สำหรับทรัพยากรใด ๆ - และสามารถประหยัดหน่วยความจำได้มาก (ถึง 100MB สำหรับแอปพลิเคชันขนาดใหญ่) หากโค้ดของคุณใช้ `formatted_` helpers โค้ดยังคงทำงานได้ตามปกติในขณะนี้ - แต่พฤติกรรมนี้ถูกยกเลิกและแอปพลิเคชันของคุณจะมีประสิทธิภาพมากขึ้นหากคุณเขียนเส้นทางเหล่านั้นใหม่โดยใช้มาตรฐานใหม่ การเปลี่ยนแปลงอีกอย่างใหญ่คือ Rails ตอนนี้รองรับไฟล์เส้นทางหลายไฟล์ไม่ใช่เพียง `routes.rb` เท่านั้น คุณสามารถใช้ `RouteSet#add_configuration_file` เพื่อนำเส้นทางเพิ่มเติมเข้ามาได้ทุกเมื่อ - โดยไม่ต้องล้างเส้นทางที่โหลดอยู่ในปัจจุบัน การเปลี่ยนแปลงนี้เป็นประโยชน์มากที่สุดสำหรับ Engines แต่คุณสามารถใช้ได้ในแอปพลิเคชันใด ๆ ที่ต้องโหลดเส้นทางเป็นกลุ่ม
* ผู้มีส่วนร่วมสำคัญ: [Aaron Batalion](http://blog.hungrymachine.com/)

### การจัดการเซสชันที่โหลดแบบ Lazy บน Rack

การเปลี่ยนแปลงขนาดใหญ่ได้ทำการย้ายการเก็บเซสชันของ Action Controller ลงไปที่ระดับของ Rack นั่นเป็นการทำงานที่ต้องใช้เวลาและความพยายามในการเขียนโค้ด แต่สิ่งนี้ไม่ควรมีผลกระทบต่อแอปพลิเคชัน Rails ของคุณ (นอกจากนั้นยังมีการลบแพทช์ที่ไม่ดีเกี่ยวกับตัวจัดการเซสชัน CGI เก่าออกไปด้วย) แต่สิ่งที่สำคัญคือแอปพลิเคชัน Rack ที่ไม่ใช่ Rails สามารถเข้าถึงตัวจัดการเก็บเซสชันเดียวกัน (และดังนั้นเซสชันเดียวกัน) กับแอปพลิเคชัน Rails ของคุณ นอกจากนี้เซสชันยังถูกโหลดแบบ lazy (ในสายการโหลดที่ดีขึ้นของเฟรมเวิร์ก) นั่นหมายความว่าคุณไม่จำเป็นต้องปิดใช้งานเซสชันโดยชัดเจนหากคุณไม่ต้องการใช้งาน แค่ไม่อ้างถึงเซสชันแล้วเซสชันก็จะไม่ถูกโหลด

### การเปลี่ยนแปลงในการจัดการ MIME Type

มีการเปลี่ยนแปลงในโค้ดสำหรับการจัดการ MIME Type ใน Rails บางส่วน ก่อนอื่น `MIME::Type` ตอนนี้มีการใช้งานตัวดำเนินการ `=~` ซึ่งทำให้ง่ายขึ้นเมื่อคุณต้องการตรวจสอบว่ามีชนิดที่มีคำเหมือนกันหรือไม่:

```ruby
if content_type && Mime::JS =~ content_type
  # ทำอะไรสักอย่างที่เจ๋ง
end

Mime::JS =~ "text/javascript"        => true
Mime::JS =~ "application/javascript" => true
```

การเปลี่ยนแปลงอื่นคือเฟรมเวิร์กตอนนี้ใช้ `Mime::JS` เมื่อตรวจสอบ JavaScript ในจุดต่าง ๆ ทำให้การจัดการแบบสะอาดกับตัวเลือกเหล่านั้น

* ผู้มีส่วนร่วมสำคัญ: [Seth Fitzsimmons](http://www.workingwithrails.com/person/5510-seth-fitzsimmons)

### การปรับปรุง `respond_to`

ในบางส่วนของผลงานแรกของทีมผู้ร่วมกันระหว่าง Rails และ Merb ใน Rails 2.3 มีการปรับปรุงบางอย่างสำหรับเมธอด `respond_to` ซึ่งเป็นเมธอดที่ใช้งานอย่างหนักในแอปพลิเคชัน Rails หลาย ๆ ตัวเพื่อให้คอนโทรลเลอร์ของคุณสามารถจัดรูปแบบผลลัพธ์ต่าง ๆ ได้ตามประเภท MIME ของคำขอที่เข้ามา หลังจากกำจัดการเรียกใช้ `method_missing` และการประมาณค่าและปรับแต่ง เราพบว่ามีการปรับปรุงขึ้น 8% ในจำนวนคำขอต่อวินาทีที่บริการด้วย `respond_to` ที่เปลี่ยนรูปแบบระหว่างสามรูปแบบ ส่วนที่ดีที่สุดคือไม่จำเป็นต้องเปลี่ยนโค้ดของแอปพลิเคชันของคุณเลยเพื่อให้ได้ประโยชน์จากการเร่งความเร็วนี้
### ประสิทธิภาพการเก็บแคชที่ดีขึ้น

Rails ตอนนี้เก็บแคชท้องถิ่นต่อคำขอละเอียดจากการเก็บแคชระยะไกล เพื่อลดการอ่านที่ไม่จำเป็นและเพิ่มประสิทธิภาพของเว็บไซต์ งานนี้เดิมเฉพาะกับ `MemCacheStore` แต่สามารถใช้ได้กับร้านค้าระยะไกลใด ๆ ที่ดำเนินการด้วยวิธีการที่จำเป็น

* ผู้มีส่วนร่วมหลัก: [Nahum Wild](http://www.motionstandingstill.com/)

### มุมมองท้องถิ่น

Rails ตอนนี้สามารถให้มุมมองท้องถิ่นได้ ขึ้นอยู่กับภาษาท้องถิ่นที่คุณตั้งค่าไว้ ตัวอย่างเช่น สมมติว่าคุณมีควบคุม `Posts` ด้วยการกระทำ `show` โดยค่าเริ่มต้นจะแสดงผล `app/views/posts/show.html.erb` แต่ถ้าคุณตั้งค่า `I18n.locale = :da` จะแสดงผล `app/views/posts/show.da.html.erb` หากไม่มีเทมเพลตท้องถิ่น จะใช้เวอร์ชันที่ไม่มีการตกแต่งแทน  Rails ยังรวม `I18n#available_locales` และ `I18n::SimpleBackend#available_locales` ซึ่งจะคืนอาร์เรย์ของการแปลที่มีอยู่ในโปรเจกต์ Rails ปัจจุบัน

นอกจากนี้คุณยังสามารถใช้รูปแบบเดียวกันเพื่อทำให้ไฟล์การช่วยเหลือในไดเรกทอรีสาธารณะท้องถิ่น: `public/500.da.html` หรือ `public/404.en.html` ทำงานเช่นนั้น

### การจำกัดขอบเขตส่วนบางส่วนสำหรับการแปล

การเปลี่ยนแปลงใน API การแปลทำให้ง่ายและไม่ซ้ำซ้อนในการเขียนการแปลคีย์ภายในพาร์ทเชียล หากคุณเรียกใช้ `translate(".foo")` จากเทมเพลต `people/index.html.erb` คุณจะเรียกใช้ `I18n.translate("people.index.foo")` หากคุณไม่ใส่จุดขั้นตอนก่อนคีย์ แล้ว API จะไม่มีขอบเขตเหมือนเดิม

### การเปลี่ยนแปลงอื่น ๆ ใน Action Controller

* การจัดการ ETag ได้รับการทำความสะอาดเล็กน้อย: Rails ตอนนี้จะข้ามการส่งส่วนหัว ETag เมื่อไม่มีเนื้อหาในการตอบสนองหรือเมื่อส่งไฟล์ด้วย `send_file`
* การตรวจสอบการปลอม IP อาจเป็นการรบกวนสำหรับเว็บไซต์ที่มีการจราจรหนักด้วยโทรศัพท์มือถือ เนื่องจากพร็อกซีของพวกเขาไม่ได้ตั้งค่าอย่างถูกต้อง หากคุณเป็นคุณ คุณสามารถตั้งค่า `ActionController::Base.ip_spoofing_check = false` เพื่อปิดการตรวจสอบอย่างสมบูรณ์
* `ActionController::Dispatcher` ตอนนี้ใช้สแต็ก middleware เองซึ่งคุณสามารถดูได้โดยการเรียกใช้ `rake middleware`
* การเก็บเซสชันคุกกี้ตอนนี้มีตัวระบุเซสชันที่ต่อเนื่อง และเข้ากันได้กับร้านค้าด้านเซิร์ฟเวอร์
* ตอนนี้คุณสามารถใช้สัญลักษณ์สำหรับตัวเลือก `:type` ของ `send_file` และ `send_data` เช่น `send_file("fabulous.png", :type => :png)`
* ตัวเลือก `:only` และ `:except` สำหรับ `map.resources` ไม่ได้ถูกสืบทอดโดยทรรศนะที่ซ้อนกัน
* ไคลเอ็นต์ memcached ที่แนบมาถูกอัปเดตเป็นเวอร์ชัน 1.6.4.99
* เมธอด `expires_in`, `stale?`, และ `fresh_when` ตอนนี้ยอมรับตัวเลือก `:public` เพื่อทำให้ทำงานได้ดีกับการแคชโดยพร็อกซี
* ตัวเลือก `:requirements` ทำงานอย่างถูกต้องกับเส้นทางสมาชิก RESTful เพิ่มเติม
* เส้นทางที่ต่ำลึกตอนนี้ปฏิบัติตามเนมสเปซได้อย่างถูกต้อง
* `polymorphic_url` ทำงานดีขึ้นในการจัดการวัตถุที่มีชื่อพหูพจน์ที่ไม่เป็นไปตามกฎ
Action View
-----------

Action View ใน Rails 2.3 มีการเพิ่มฟอร์มข้อมูลแบบฟอร์มย่อยที่ซ้อนกัน การปรับปรุงใน `render` การให้คำให้การเลือกวันที่ใน helper ที่ยืดหยุ่นมากขึ้น และการเร่งความเร็วในการแคชทรัพยากร รวมถึงอื่น ๆ

### ฟอร์มข้อมูลแบบฟอร์มย่อยที่ซ้อนกัน

หากโมเดลหลักยอมรับแอตทริบิวต์ที่ซ้อนกันสำหรับอ็อบเจ็กต์ย่อย (ตามที่ได้รับการอภิปรายในส่วนของ Active Record) คุณสามารถสร้างฟอร์มที่ซ้อนกันได้โดยใช้ `form_for` และ `field_for` ฟอร์มเหล่านี้สามารถซ้อนกันได้ลึกอย่างออกอัตราการแก้ไขโครงสร้างวัตถุที่ซับซ้อนบนหน้าต่างเดียวโดยไม่ต้องเขียนโค้ดมากเกินไป ตัวอย่างเช่น โมเดลนี้:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders

  accepts_nested_attributes_for :orders, :allow_destroy => true
end
```

คุณสามารถเขียนหน้าต่างนี้ใน Rails 2.3:

```html+erb
<% form_for @customer do |customer_form| %>
  <div>
    <%= customer_form.label :name, 'ชื่อลูกค้า:' %>
    <%= customer_form.text_field :name %>
  </div>

  <!-- ที่นี่เราเรียก fields_for บนตัวอินสแตนซ์ของ builder ของ customer_form
   บล็อกจะถูกเรียกสำหรับแต่ละสมาชิกในคอลเลกชันของคำสั่ง -->
  <% customer_form.fields_for :orders do |order_form| %>
    <p>
      <div>
        <%= order_form.label :number, 'หมายเลขคำสั่งซื้อ:' %>
        <%= order_form.text_field :number %>
      </div>

  <!-- ตัวเลือก allow_destroy ในโมเดลทำให้สามารถลบระเบียนย่อยได้ -->
      <% unless order_form.object.new_record? %>
        <div>
          <%= order_form.label :_delete, 'ลบ:' %>
          <%= order_form.check_box :_delete %>
        </div>
      <% end %>
    </p>
  <% end %>

  <%= customer_form.submit %>
<% end %>
```

* ผู้มีส่วนร่วมหลัก: [Eloy Duran](http://superalloy.nl/)
* ข้อมูลเพิ่มเติม:
    * [ฟอร์มข้อมูลแบบฟอร์มย่อย](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)
    * [complex-form-examples](https://github.com/alloy/complex-form-examples)
    * [สิ่งใหม่ใน Edge Rails: ฟอร์มข้อมูลแบบฟอร์มย่อย](http://archives.ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes)

### การแสดงผลส่วนย่อยอัจฉริยะ

เมธอด render ได้รับการปรับปรุงให้ฉลาดขึ้นตลอดเวลา และตอนนี้มันฉลาดมากขึ้นอีกด้วย หากคุณมีอ็อบเจ็กต์หรือคอลเลกชันที่เหมาะสมและการตั้งชื่อตรงกัน คุณสามารถแค่แสดงผลอ็อบเจ็กต์และสิ่งที่ต้องการจะทำงานได้ ตัวอย่างเช่นใน Rails 2.3 การเรียก render เหล่านี้จะทำงานในหน้าต่างของคุณ (ในกรณีที่มีการตั้งชื่อที่เหมาะสม):
```ruby
# เทียบเท่ากับ render :partial => 'articles/_article',
# :object => @article
render @article

# เทียบเท่ากับ render :partial => 'articles/_article',
# :collection => @articles
render @articles
```

* ข้อมูลเพิ่มเติม: [What's New in Edge Rails: render Stops Being High-Maintenance](http://archives.ryandaigle.com/articles/2008/11/20/what-s-new-in-edge-rails-render-stops-being-high-maintenance)

### Prompts สำหรับ Date Select Helpers

ใน Rails 2.3, คุณสามารถกำหนด prompts ที่กำหนดเองสำหรับ date select helpers (`date_select`, `time_select`, และ `datetime_select`), อย่างเดียวกับ collection select helpers ได้ คุณสามารถกำหนด prompt string หรือ hash ของ prompt strings สำหรับส่วนประกอบต่าง ๆ ได้ คุณยังสามารถกำหนด `:prompt` เป็น `true` เพื่อใช้ prompt ทั่วไปที่กำหนดเองได้:

```ruby
select_datetime(DateTime.now, :prompt => true)

select_datetime(DateTime.now, :prompt => "Choose date and time")

select_datetime(DateTime.now, :prompt =>
  {:day => 'Choose day', :month => 'Choose month',
   :year => 'Choose year', :hour => 'Choose hour',
   :minute => 'Choose minute'})
```

* ผู้มีส่วนร่วมหลัก: [Sam Oliver](http://samoliver.com/)

### AssetTag Timestamp Caching

คุณคงคุ้นเคยกับการเพิ่ม timestamp ในเส้นทางของ static asset ใน Rails เพื่อ "cache buster" นี้ช่วยให้แน่ใจว่าสำเนาที่เก่าของสิ่งเช่นรูปภาพและสไตล์ชีตไม่ได้รับการให้บริการจากแคชของเบราว์เซอร์ของผู้ใช้เมื่อคุณเปลี่ยนแปลงเหล่านั้นบนเซิร์ฟเวอร์ ตอนนี้คุณสามารถแก้ไขพฤติกรรมนี้ด้วยตัวเลือกการกำหนดค่า `cache_asset_timestamps` สำหรับ Action View หากคุณเปิดใช้แคช แล้ว Rails จะคำนวณ timestamp ครั้งเดียวเมื่อเซิร์ฟเวอร์ให้บริการสิ่งที่เป็นสินทรัพย์ครั้งแรก และบันทึกค่านั้น นั่นหมายความว่าจะมีการเรียกใช้ระบบไฟล์น้อยลง (ที่มีค่าสูง) เพื่อให้บริการสินทรัพย์แบบสถิต แต่นี่ยังหมายความว่าคุณไม่สามารถแก้ไขสินทรัพย์ใด ๆ ในขณะที่เซิร์ฟเวอร์กำลังทำงานและคาดหวังว่าการเปลี่ยนแปลงจะถูกนำไปใช้งานโดยไคลเอ็นต์

### Asset Hosts เป็นอ็อบเจ็กต์

Asset hosts กลายเป็นเครื่องมือที่ยืดหยุ่นมากขึ้นใน edge Rails ด้วยความสามารถในการประกาศ asset host เป็นอ็อบเจ็กต์ที่เฉพาะเจาะจงที่ตอบสนองกับการเรียกใช้งาน นี้ช่วยให้คุณสามารถนำเสนอตรรกะที่ซับซ้อนในการโฮสต์สินทรัพย์ของคุณได้ตามที่คุณต้องการ
* ข้อมูลเพิ่มเติม: [asset-hosting-with-minimum-ssl](https://github.com/dhh/asset-hosting-with-minimum-ssl/tree/master)

### วิธีใช้ grouped_options_for_select Helper Method

Action View มีเครื่องมือช่วยในการสร้างควบคุม select อยู่แล้ว แต่ตอนนี้มีอีกหนึ่งอันคือ `grouped_options_for_select` ฟังก์ชันนี้รับอาร์เรย์หรือแฮชของสตริงและแปลงเป็นสตริงของแท็ก `option` ที่ห่อหุ้มด้วยแท็ก `optgroup` ตัวอย่างเช่น:

```ruby
grouped_options_for_select([["Hats", ["Baseball Cap","Cowboy Hat"]]],
  "Cowboy Hat", "Choose a product...")
```

จะคืนค่า

```html
<option value="">Choose a product...</option>
<optgroup label="Hats">
  <option value="Baseball Cap">Baseball Cap</option>
  <option selected="selected" value="Cowboy Hat">Cowboy Hat</option>
</optgroup>
```

### แท็กตัวเลือกที่ถูกปิดใช้งานสำหรับ Form Select Helpers

Form select helpers (เช่น `select` และ `options_for_select`) ตอนนี้สนับสนุนตัวเลือก `:disabled` ซึ่งสามารถรับค่าเดียวหรืออาร์เรย์ของค่าที่จะถูกปิดใช้งานในแท็กที่ได้รับ:

```ruby
select(:post, :category, Post::CATEGORIES, :disabled => 'private')
```

จะคืนค่า

```html
<select name="post[category]">
<option>story</option>
<option>joke</option>
<option>poem</option>
<option disabled="disabled">private</option>
</select>
```

คุณยังสามารถใช้ฟังก์ชันไม่มีชื่อเพื่อกำหนดในเวลาทำงานว่าตัวเลือกจากคอลเลกชันจะถูกเลือกและ/หรือถูกปิดใช้งาน:

```ruby
options_from_collection_for_select(@product.sizes, :name, :id, :disabled => lambda{|size| size.out_of_stock?})
```

* ผู้มีส่วนร่วมหลัก: [Tekin Suleyman](http://tekin.co.uk/)
* ข้อมูลเพิ่มเติม: [New in rails 2.3 - disabled option tags and lambdas for selecting and disabling options from collections](https://tekin.co.uk/2009/03/new-in-rails-23-disabled-option-tags-and-lambdas-for-selecting-and-disabling-options-from-collections)

### หมายเหตุเกี่ยวกับการโหลดเทมเพลต

Rails 2.3 รวมความสามารถในการเปิดหรือปิดการใช้งานเทมเพลตแคชสำหรับแต่ละสภาพแวดล้อมได้ เทมเพลตแคชช่วยเพิ่มความเร็วเนื่องจากไม่ต้องตรวจสอบไฟล์เทมเพลตใหม่เมื่อทำการแสดงผล - แต่มันยังหมายความว่าคุณไม่สามารถแทนที่เทมเพลต "ทันที" โดยไม่ต้องรีสตาร์ทเซิร์ฟเวอร์

ในกรณีส่วนใหญ่ คุณต้องการให้แคชเทมเพลตเปิดใช้งานในสภาพแวดล้อมการผลิต ซึ่งคุณสามารถทำได้โดยตั้งค่าในไฟล์ `production.rb` ของคุณ:

```ruby
config.action_view.cache_template_loading = true
```

บรรทัดนี้จะถูกสร้างขึ้นโดยค่าเริ่มต้นในแอปพลิเคชัน Rails 2.3 ใหม่ หากคุณอัปเกรดจากเวอร์ชันเก่าของ Rails Rails จะเปิดใช้งานแคชเทมเพลตในสภาพแวดล้อมการผลิตและการทดสอบ แต่ไม่ใช่ในการพัฒนา
### การเปลี่ยนแปลง Action View อื่น ๆ

* การสร้างโทเค็นสำหรับการป้องกัน CSRF ได้รับการปรับปรุงให้ง่ายขึ้น; ตอนนี้ Rails ใช้สตริงสุ่มที่ง่ายโดยใช้ `ActiveSupport::SecureRandom` แทนการใช้ session ID
* `auto_link` ตอนนี้ใช้ตัวเลือก (เช่น `:target` และ `:class`) ในการสร้างลิงก์อีเมลได้อย่างถูกต้อง
* ช่วยเรียกใช้งาน `autolink` ได้รับการแก้ไขให้ง่ายขึ้นและใช้งานได้ง่ายมากขึ้น
* `current_page?` ตอนนี้ทำงานได้อย่างถูกต้องแม้ว่าจะมีพารามิเตอร์คิวรีมากกว่าหนึ่งใน URL

Active Support
--------------

Active Support มีการเปลี่ยนแปลงที่น่าสนใจบางอย่าง รวมถึงการเพิ่ม `Object#try`.

### Object#try

ผู้คนมักใช้คำสั่ง try() เพื่อทดลองดำเนินการกับออบเจ็กต์ มันเป็นประโยชน์มากในการแสดงผลที่คุณสามารถหลีกเลี่ยงการตรวจสอบค่า null โดยเขียนโค้ดเช่น `<%= @person.try(:name) %>` ตอนนี้มันถูกนำเข้ามาใน Rails แล้ว ในการนำมาใช้ใน Rails มันจะเรียก `NoMethodError` สำหรับเมธอดที่เป็น private และเสมอคืนค่า `nil` ถ้าออบเจ็กต์เป็น null

* ข้อมูลเพิ่มเติม: [try()](http://ozmm.org/posts/try.html)

### Object#tap Backport

`Object#tap` เป็นการเพิ่มเติมใน [Ruby 1.9](http://www.ruby-doc.org/core-1.9/classes/Object.html#M000309) และ 1.8.7 ที่คล้ายกับเมธอด `returning` ที่ Rails มีมานานแล้ว: มันจะ yield ไปยังบล็อก แล้วคืนค่าออบเจ็กต์ที่ yield ไป ตอนนี้ Rails รวมรหัสเพื่อทำให้สามารถใช้งานได้ในเวอร์ชันเก่าของ Ruby ด้วย

### Swappable Parsers สำหรับ XMLmini

การสนับสนุนการแยกวิเคราะห์ XML ใน Active Support ได้รับการทำให้ยืดหยุ่นมากขึ้นโดยอนุญาตให้คุณสามารถแทนที่ตัววิเคราะห์ได้ โดยค่าเริ่มต้นใช้การประมวลผล REXML มาตรฐาน แต่คุณสามารถระบุการประมวลผล LibXML หรือ Nokogiri ที่เร็วกว่าสำหรับแอปพลิเคชันของคุณเองได้ง่าย ๆ หากคุณมี gem ที่เหมาะสมติดตั้งอยู่:

```ruby
XmlMini.backend = 'LibXML'
```

* ผู้มีส่วนร่วมหลัก: [Bart ten Brinke](http://www.movesonrails.com/)
* ผู้มีส่วนร่วมหลัก: [Aaron Patterson](http://tenderlovemaking.com/)

### วินาทีเศษสำหรับ TimeWithZone

คลาส `Time` และ `TimeWithZone` รวมถึงเมธอด `xmlschema` เพื่อคืนค่าเวลาในรูปแบบสตริงที่เหมาะสมกับ XML ตั้งแต่ Rails 2.3 เป็นต้นไป `TimeWithZone` รองรับอาร์กิวเมนต์เดียวกันสำหรับการระบุจำนวนหลักในส่วนวินาทีเศษของสตริงที่คืนค่าเช่นเดียวกับ `Time`:
```ruby
Time.zone.now.xmlschema(6) # => "2009-01-16T13:00:06.13653Z"
```

* ผู้มีส่วนร่วมหลัก: [Nicholas Dainty](http://www.workingwithrails.com/person/13536-nicholas-dainty)

### การอ้างอิงคีย์ใน JSON

หากคุณตรวจสอบสเปคในเว็บไซต์ "json.org" คุณจะค้นพบว่าคีย์ทั้งหมดในโครงสร้าง JSON ต้องเป็นสตริงและต้องอ้างอิงด้วยเครื่องหมายคำพูดคู่ (double quotes) ตั้งแต่ Rails 2.3 เราทำสิ่งที่ถูกต้องที่นี่ แม้ว่าจะเป็นคีย์ที่เป็นตัวเลข

### การเปลี่ยนแปลง Active Support อื่น ๆ

* คุณสามารถใช้ `Enumerable#none?` เพื่อตรวจสอบว่าไม่มีองค์ประกอบใด ๆ ตรงกับบล็อกที่กำหนด
* หากคุณกำลังใช้ Active Support [delegates](https://afreshcup.com/home/2008/10/19/coming-in-rails-22-delegate-prefixes) ตัวเลือกใหม่ `:allow_nil` ช่วยให้คุณสามารถส่งคืน `nil` แทนที่จะเกิดข้อยกเว้นเมื่อวัตถุเป้าหมายเป็น nil
* `ActiveSupport::OrderedHash`: ตอนนี้มีการนำมาใช้ `each_key` และ `each_value`
* `ActiveSupport::MessageEncryptor` ให้วิธีง่ายในการเข้ารหัสข้อมูลสำหรับการจัดเก็บในตำแหน่งที่ไม่น่าเชื่อถือ (เช่นคุกกี้)
* `from_xml` ของ Active Support ไม่อาศัย XmlSimple อีกต่อไป แทนที่ Rails ตอนนี้รวมซอร์ส XmlMini ของตัวเองที่มีฟังก์ชันเพียงพอสำหรับการใช้งาน นี้ช่วยให้ Rails สามารถละทิ้งสำเนา XmlSimple ที่มีอยู่ในตัวแพ็คเกจได้
* หากคุณใช้งานเมธอด private ในการจดจำค่า ผลลัพธ์จะเป็น private
* `String#parameterize` ยอมรับตัวคั่นทางเลือก: `"Quick Brown Fox".parameterize('_') => "quick_brown_fox"`
* `number_to_phone` ยอมรับหมายเลขโทรศัพท์ 7 หลักเดี๋ยวนี้
* `ActiveSupport::Json.decode` ตอนนี้รองรับการหนีไปยัง `\u0000` แบบรหัสหนีได้

Railties
--------

นอกจากการเปลี่ยนแปลงใน Rack ที่กล่าวถึงข้างต้น Railties (รหัสหลักของ Rails เอง) ยังมีการเปลี่ยนแปลงที่สำคัญอื่น ๆ เช่น Rails Metal, แม่แบบแอปพลิเคชัน และการแสดง backtrace ที่เงียบ

### Rails Metal

Rails Metal เป็นกลไกใหม่ที่ให้บริการจุดปลายทางที่เร็วมากภายในแอปพลิเคชัน Rails ของคุณ คลาส Metal จะข้ามการเส้นทางและ Action Controller เพื่อให้คุณได้ความเร็วสูง (แต่ต้องสละสิ่งทั้งหมดใน Action Controller แน่นอน) สิ่งนี้สร้างขึ้นบนงานรากฐานล่าสุดทั้งหมดเพื่อทำให้ Rails เป็นแอปพลิเคชัน Rack ที่มีสแต็ก middleware เปิดเผย Metal endpoints สามารถโหลดจากแอปพลิเคชันหรือจากปลั๊กอินของคุณได้
* ข้อมูลเพิ่มเติม:
    * [แนะนำ Rails Metal](https://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal)
    * [Rails Metal: โครงสร้างขนาดเล็กที่มีความสามารถเหมือน Rails](http://soylentfoo.jnewland.com/articles/2008/12/16/rails-metal-a-micro-framework-with-the-power-of-rails-m)
    * [Metal: จุดสิ้นสุดที่เร็วที่สุดในแอปพลิเคชัน Rails ของคุณ](http://www.railsinside.com/deployment/180-metal-super-fast-endpoints-within-your-rails-apps.html)
    * [สิ่งใหม่ใน Edge Rails: Rails Metal](http://archives.ryandaigle.com/articles/2008/12/18/what-s-new-in-edge-rails-rails-metal)

### เทมเพลตแอปพลิเคชัน

Rails 2.3 รวมการสร้างแอปพลิเคชันแบบเทมเพลตของ Jeremy McAnally's [rg](https://github.com/jm/rg) ลงใน Rails โดยตรง นั่นหมายความว่าเราสามารถสร้างแอปพลิเคชันโดยใช้เทมเพลตได้โดยตรง หากคุณมีชุดของปลั๊กอินที่คุณต้องการรวมเข้ากับแอปพลิเคชันทุกตัว (รวมถึงกรณีใช้งานอื่น ๆ อีกมากมาย) คุณสามารถตั้งค่าเทมเพลตครั้งเดียวแล้วใช้ซ้ำได้เมื่อคุณรันคำสั่ง `rails` อีกครั้ง ยังมีงาน rake เพื่อใช้เทมเพลตกับแอปพลิเคชันที่มีอยู่แล้ว:

```bash
$ rake rails:template LOCATION=~/template.rb
```

นี้จะนำเสนอการเปลี่ยนแปลงจากเทมเพลตลงบนโค้ดที่โปรเจกต์มีอยู่แล้ว

* ผู้มีส่วนร่วมหลัก: [Jeremy McAnally](http://www.jeremymcanally.com/)
* ข้อมูลเพิ่มเติม: [เทมเพลต Rails](http://m.onkey.org/2008/12/4/rails-templates)

### การแสดงผล Backtraces ที่เงียบขึ้น

โดยใช้ปลั๊กอิน [Quiet Backtrace](https://github.com/thoughtbot/quietbacktrace) ของ thoughtbot ที่ช่วยให้คุณสามารถเอาบางบรรทัดออกจาก Backtrace ของ `Test::Unit` ได้เลือกทำให้ Rails 2.3 นำ `ActiveSupport::BacktraceCleaner` และ `Rails::BacktraceCleaner` มาใช้ในคอร์เรียล ซึ่งรองรับการกรอง (เพื่อทำการแทนที่ด้วย regex บนบรรทัด Backtrace) และการปิดเสียง (เพื่อลบบรรทัด Backtrace ออกทั้งหมด) Rails จะเพิ่มการปิดเสียงเพื่อกำจัดเสียงรบกวนที่พบบ่อยในแอปพลิเคชันใหม่ และสร้างไฟล์ `config/backtrace_silencers.rb` เพื่อเก็บการเพิ่มของคุณเอง คุณสมบัตินี้ยังช่วยให้การพิมพ์ที่สวยงามขึ้นจากแพ็กเกจใด ๆ ใน Backtrace

### เร็วขึ้นในการเริ่มต้นในโหมดการพัฒนาด้วยการโหลดแบบเกินความจำ/ออโต้โหลด

ทำงานอย่างหนักเพื่อให้แน่ใจว่าส่วนของ Rails (และขึ้นอยู่กับมัน) จะถูกนำเข้าหน่วยความจำเมื่อจำเป็นจริง โครงสร้างหลัก - Active Support, Active Record, Action Controller, Action Mailer, และ Action View - ใช้ `autoload` เพื่อโหลดคลาสแต่ละตัวของพวกเขาในลักษณะของการโหลดแบบเกินความจำ งานนี้ควรช่วยลดการใช้หน่วยความจำและปรับปรุงประสิทธิภาพของ Rails โดยรวม

คุณยังสามารถระบุ (โดยใช้ตัวเลือกใหม่ `preload_frameworks`) ว่าควรโหลดไลบรารีหลักที่เกี่ยวข้องในขณะที่เริ่มต้น ค่าเริ่มต้นคือ `false` เพื่อให้ Rails โหลดเองเป็นส่วนต่อส่วน แต่มีบางสถานการณ์ที่คุณยังต้องการนำเข้าทั้งหมดในครั้งเดียว - Passenger และ JRuby ต้องการเห็น Rails ทั้งหมดโหลดพร้อมกัน
### การเขียนรหัสงาน rake gem ถูกแก้ไขใหม่

การทำงานภายในของงาน rake gem ต่าง ๆ ได้รับการแก้ไขให้ทำงานได้ดีขึ้นสำหรับกรณีต่าง ๆ มากขึ้น ระบบ gem ตอนนี้รู้ถึงความแตกต่างระหว่าง dependencies ในการพัฒนาและรัน มีระบบการแยกแพ็คที่แข็งแกร่งมากขึ้น ให้ข้อมูลที่ดีขึ้นเมื่อสอบถามสถานะของ gem และไม่ต้องเผชิญกับปัญหา "ไข่และไก่" ของ dependencies เมื่อคุณกำลังเริ่มต้นสิ่งที่ต้องการ ยังมีการแก้ไขสำหรับใช้คำสั่ง gem ภายใต้ JRuby และสำหรับ dependencies ที่พยายามนำเข้าสำเนาภายนอกของ gem ที่มีอยู่แล้ว

* ผู้มีส่วนร่วมหลัก: [David Dollar](http://www.workingwithrails.com/person/12240-david-dollar)

### การเปลี่ยนแปลง Railties อื่น ๆ

* คำแนะนำสำหรับการอัปเดตเซิร์ฟเวอร์ CI เพื่อสร้าง Rails ได้รับการอัปเดตและขยาย
* การทดสอบภายในของ Rails ได้ถูกเปลี่ยนจาก `Test::Unit::TestCase` เป็น `ActiveSupport::TestCase` และ Rails core ต้องการ Mocha เพื่อทดสอบ
* ไฟล์ `environment.rb` เริ่มต้นได้รับการลดความรก
* สคริปต์ dbconsole ตอนนี้ให้คุณใช้รหัสผ่านที่เป็นตัวเลขเท่านั้นโดยไม่ทำให้เกิดข้อผิดพลาด
* `Rails.root` ตอนนี้คืนค่าเป็นออบเจ็กต์ `Pathname` ซึ่งหมายความว่าคุณสามารถใช้กับเมธอด `join` ได้โดยตรงเพื่อ [ทำความสะอาดรหัสที่มีอยู่](https://afreshcup.wordpress.com/2008/12/05/a-little-rails_root-tidiness/) ที่ใช้ `File.join`
* ไฟล์ต่าง ๆ ใน /public ที่เกี่ยวข้องกับการส่งต่อ CGI และ FCGI ไม่ได้ถูกสร้างขึ้นในแอปพลิเคชัน Rails ทุกอันตามค่าเริ่มต้นแล้ว (คุณยังสามารถรับได้หากคุณต้องการโดยการเพิ่ม `--with-dispatchers` เมื่อคุณรันคำสั่ง `rails` หรือเพิ่มภายหลังด้วย `rake rails:update:generate_dispatchers`)
* Rails Guides ได้ถูกแปลงจาก AsciiDoc เป็น Textile markup
* ไฟล์และคอนโทรลเลอร์ที่ถูกสร้างขึ้นโดย Scaffolded ได้รับการทำความสะอาดเล็กน้อย
* สคริปต์/เซิร์ฟเวอร์ตอนนี้ยอมรับอาร์กิวเมนต์ `--path` เพื่อเชื่อมต่อแอปพลิเคชัน Rails จากเส้นทางที่ระบุ
* หากขาด gem ที่กำหนดค่าไว้ งาน rake gem จะข้ามการโหลดส่วนใหญ่ของ environment นี้ควรแก้ไขปัญหา "ไข่และไก่" ที่ rake gems:install ไม่สามารถทำงานได้เนื่องจากขาด gem
* Gems ถูกแยกแพ็คเพียงครั้งเดียว นี้แก้ไขปัญหาเกี่ยวกับ gems (เช่น hoe) ที่ถูกแพ็คด้วยสิทธิ์อ่านอย่างเดียวบนไฟล์
เลิกใช้งาน
----------

มีรหัสเก่าบางส่วนที่ถูกเลิกใช้ในเวอร์ชันนี้:

* หากคุณเป็นหนึ่งในนักพัฒนา Rails (ที่น้อยมาก) ที่ใช้วิธีการติดตั้งที่ขึ้นอยู่กับสคริปต์ inspector, reaper, และ spawner คุณจะต้องรู้ว่าสคริปต์เหล่านั้นไม่ได้รวมอยู่ใน Rails หลักแล้ว หากคุณต้องการใช้งานสคริปต์เหล่านั้น คุณสามารถดาวน์โหลดได้ผ่านปลั๊กอิน [irs_process_scripts](https://github.com/rails/irs_process_scripts)
* `render_component` ถูกเลิกใช้งานใน Rails 2.3 หากคุณยังต้องการใช้งาน คุณสามารถติดตั้งปลั๊กอิน [render_component plugin](https://github.com/rails/render_component/tree/master)
* ไม่มีการสนับสนุนสำหรับ Rails components อีกต่อไป
* หากคุณเคยใช้งาน `script/performance/request` เพื่อดูประสิทธิภาพที่เกี่ยวข้องกับการทดสอบการรวมกัน คุณต้องเรียนรู้วิธีใหม่: สคริปต์นี้ถูกลบออกจาก Rails หลักแล้ว มีปลั๊กอินใหม่ที่ชื่อว่า request_profiler ที่คุณสามารถติดตั้งเพื่อใช้งานฟังก์ชันเดียวกันได้อีกครั้ง
* `ActionController::Base#session_enabled?` ถูกเลิกใช้งานเนื่องจาก sessions ถูกโหลดเมื่อต้องการเท่านั้น
* ตัวเลือก `:digest` และ `:secret` ใน `protect_from_forgery` ถูกเลิกใช้งานและไม่มีผล
* มีการลบบางช่วยด้านการทดสอบการรวมกัน `response.headers["Status"]` และ `headers["Status"]` จะไม่ส่งค่าออกมาอีกต่อไป Rack ไม่อนุญาตให้มี "Status" ในส่วนหัวการส่งคืน อย่างไรก็ตามคุณยังสามารถใช้ช่วยด้าน `status` และ `status_message` ได้ `response.headers["cookie"]` และ `headers["cookie"]` จะไม่ส่งค่าคุกกี้ CGI ออกมาอีกต่อไป คุณสามารถตรวจสอบ `headers["Set-Cookie"]` เพื่อดูส่วนหัวคุกกี้แบบรวมหรือใช้ช่วยด้าน `cookies` เพื่อรับแฮชของคุกกี้ที่ส่งไปยังไคลเอนต์
* `formatted_polymorphic_url` ถูกเลิกใช้งาน ให้ใช้ `polymorphic_url` พร้อมกับ `:format` แทน
* ตัวเลือก `:http_only` ใน `ActionController::Response#set_cookie` ถูกเปลี่ยนชื่อเป็น `:httponly`
* ตัวเลือก `:connector` และ `:skip_last_comma` ของ `to_sentence` ถูกแทนที่ด้วยตัวเลือก `:words_connector`, `:two_words_connector`, และ `:last_word_connector`
* การโพสต์ฟอร์มหลายส่วนด้วยควบคุม `file_field` ที่ว่างเปล่าใช้ส่งสตริงว่างไปยังคอนโทรลเลอร์ ตอนนี้มันจะส่งค่า nil เนื่องจากความแตกต่างของตัวแยกส่วนหลายของ Rack และตัวแยกส่วนเก่าของ Rails
เครดิต

-------

บันทึกการออกแบบโดย [Mike Gunderloy](http://afreshcup.com) รุ่นนี้ของบันทึกการออกแบบ Rails 2.3 ถูกสร้างขึ้นโดยใช้ RC2 ของ Rails 2.3 เป็นฐาน.
