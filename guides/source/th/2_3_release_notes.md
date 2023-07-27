**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 77b47af4826df984dead9f6263cfd135
เอกสารปล่อยตัวของ Ruby on Rails 2.3
===============================

Rails 2.3 นำเสนอคุณสมบัติใหม่และปรับปรุงให้ดีขึ้นในหลายด้าน รวมถึงการรวม Rack อย่างแพร่หลาย การสนับสนุน Rails Engines ที่อัพเดต การทำงานภายใน Active Record ด้วยการทำธุรกรรมซ้อนกัน สเกลและค่าเริ่มต้นที่ไดนามิก การเรนเดอร์ที่เป็นรวม การเรนเดอร์เส้นทางที่มีประสิทธิภาพมากขึ้น แม่แบบแอปพลิเคชัน และการแสดงผลที่เงียบสงบ รายการนี้ครอบคลุมการอัพเกรดที่สำคัญ แต่ไม่รวมถึงการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงทุกอย่าง หากคุณต้องการดูทุกอย่าง โปรดตรวจสอบ [รายการคอมมิต](https://github.com/rails/rails/commits/2-3-stable) ในเก็บรักษาของ Rails หลักบน GitHub หรือตรวจสอบไฟล์ `CHANGELOG` สำหรับคอมโพเนนต์ของ Rails แต่ละส่วน

--------------------------------------------------------------------------------

สถาปัตยกรรมแอปพลิเคชัน
------------------------

มีการเปลี่ยนแปลงสำคัญสองประการในสถาปัตยกรรมของแอปพลิเคชัน Rails: การรวมทั้งหมดของอินเทอร์เฟซเว็บเซิร์ฟเวอร์แบบโมดูล Rack และการสนับสนุนใหม่สำหรับ Rails Engines

### การรวม Rack

Rails ตอนนี้ได้ยกเลิกการใช้ CGI และใช้ Rack ทั่วไป นี้ต้องการและผลิตภัณฑ์จำนวนมากของการเปลี่ยนแปลงภายใน (แต่หากคุณใช้ CGI ไม่ต้องกังวล เพราะ Rails ตอนนี้รองรับ CGI ผ่านอินเทอร์เฟซพร็อกซี่) แต่นี่เป็นการเปลี่ยนแปลงสำคัญในส่วนของ Rails ภายใน หลังจากอัพเกรดเป็นเวอร์ชัน 2.3 คุณควรทดสอบในสภาพแวดล้อมท้องถิ่นและสภาพแวดล้อมการใช้งานจริงของคุณ บางสิ่งที่ควรทดสอบ:

* เซสชัน
* คุกกี้
* การอัปโหลดไฟล์
* JSON/XML APIs

นี่คือสรุปของการเปลี่ยนแปลงที่เกี่ยวข้องกับ Rack:

* `script/server` ได้ถูกเปลี่ยนให้ใช้ Rack ซึ่งหมายความว่ามันรองรับเซิร์ฟเวอร์ที่เข้ากันได้กับ Rack ใด ๆ `script/server` ยังจะเรียกใช้ไฟล์กำหนดค่า rackup หากมีอยู่ โดยค่าเริ่มต้นจะมองหาไฟล์ `config.ru` แต่คุณสามารถเขียนทับได้ด้วยการใช้สวิตช์ `-c`
* ตัวจัดการ FCGI ผ่าน Rack
* `ActionController::Dispatcher` รักษาสแต็กของ middleware เริ่มต้นของตัวเอง สามารถซึมซับเข้าไป จัดลำดับ และลบออกได้ สแต็กถูกคอมไพล์เป็นเชือกในขณะที่เริ่มต้น คุณสามารถกำหนดค่าสแต็กของ middleware ใน `environment.rb`
* มีงาน rake middleware เพื่อตรวจสอบสแต็กของ middleware นี้เป็นประโยชน์ในการแก้ปัญหาสแต็กของ middleware
* ตัวรันการทดสอบการรวมแกนได้ถูกแก้ไขให้ทำงานกับสแต็กของ middleware และสแต็กแอปพลิเคชันทั้งหมด นี่ทำให้การทดสอบการรวมแกนเหมาะสมสำหรับการทดสอบสแต็กของ middleware
* `ActionController::CGIHandler` เป็นการห่อหุ้ม CGI ที่เข้ากันได้ย้อนกลับด้วย Rack ตัว `CGIHandler` จะรับวัตถุ CGI เก่าและแปลงข้อมูลสภาพแวดล้อมของมันให้เข้ากันได้กับ Rack
* `CgiRequest` และ `CgiResponse` ถูกลบออก
* การเก็บรักษาเซสชันถูกโหลดเมื่อต้องการ หากคุณไม่เข้าถึงวัตถุเซสชันในระหว่างคำขอ เซสชันจะไม่พยายามโหลดข้อมูลเซสชัน (แยกวิเคราะห์คุกกี้ โหลดข้อมูลจาก memcache หรือค้นหาวัตถุ Active Record)
* คุณไม่ต้องใช้ `CGI::Cookie.new` ในการทดสอบสำหรับการตั้งค่าค่าคุกกี้ การกำหนดค่าค่าสตริงให้กับ request.cookies["foo"] จะตั้งค่าคุกกี้ตามที่คาดหวัง
* `CGI::Session::CookieStore` ถูกแทนที่ด้วย `ActionController::Session::CookieStore`
* `CGI::Session::MemCacheStore` ถูกแทนที่ด้วย `ActionController::Session::MemCacheStore`
* `CGI::Session::ActiveRecordStore` ถูกแทนที่ด้วย `ActiveRecord::SessionStore`
* คุณยังคงสามารถเปลี่ยนแปลงร้านค้าเซสชันของคุณด้วย `ActionController::Base.session_store = :active_record_store`
* ตัวเลือกเริ่มต้นของเซสชันยังคงถูกตั้งค่าด้วย `ActionController::Base.session = { :key => "..." }` อย่างไรก็ตาม ตัวเลือก `:session_domain` ถูกเปลี่ยนชื่อเป็น `:domain`
* มิวเท็กซ์ที่ครอบคลุมคำขอทั้งหมดของคุณถูกย้ายไปอยู่ใน middleware `ActionController::Lock`
* `ActionController::AbstractRequest` และ `ActionController::Request` ถูกรวมเข้าด้วยกัน คำขอใหม่ `ActionController::Request` สืบทอดมาจาก `Rack::Request` ส่งผลต่อการเข้าถึง `response.headers['type']` ในคำขอการทดสอบ ให้ใช้ `response.content_type` แทน
* มี middleware `ActiveRecord::QueryCache` ถูกแทรกอัตโนมัติลงในสแต็กของ middleware หาก `ActiveRecord` ได้ถูกโหลด มิวเท็กซ์นี้ตั้งค่าและล้างแคชคิวรีของ Active Record ต่อคำขอ
* เราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเราเร
### การสนับสนุน Rails Engines ที่อัพเกรดแล้ว

หลังจากไม่ได้อัพเกรดเป็นเวอร์ชันใหม่เป็นเวลาหลายรุ่น ใน Rails 2.3 มีการเสนอคุณสมบัติใหม่สำหรับ Rails Engines (แอปพลิเคชัน Rails ที่สามารถฝังได้ในแอปพลิเคชันอื่น) คุณสมบัติแรกคือไฟล์เส้นทางใน engines จะถูกโหลดและโหลดซ้ำโดยอัตโนมัติตอนนี้เหมือนกับไฟล์ `routes.rb` ของคุณ (สิ่งนี้ยังใช้กับไฟล์เส้นทางในปลั๊กอินอื่น ๆ) คุณสมบัติที่สองคือหากปลั๊กอินของคุณมีโฟลเดอร์ app แล้ว app/[models|controllers|helpers] จะถูกเพิ่มในเส้นทางการโหลดของ Rails โดยอัตโนมัติ Engines ยังสนับสนุนการเพิ่มเส้นทางมุมมองและ Action Mailer รวมถึง Action View จะใช้มุมมองจาก engines และปลั๊กอินอื่น ๆ

เอกสาร
-------------

โครงการ [Ruby on Rails guides](https://guides.rubyonrails.org/) ได้เผยแพร่คู่มือเพิ่มเติมสำหรับ Rails 2.3 นอกจากนี้ยังมี [เว็บไซต์แยกต่างหาก](https://edgeguides.rubyonrails.org/) ที่บันทึกสำเนาคู่มือสำหรับ Edge Rails การพยายามเอกสารอื่น ๆ รวมถึงการเริ่มต้นใหม่ของ [Rails wiki](http://newwiki.rubyonrails.org/) และการวางแผนเร็ว ๆ นี้สำหรับ Rails Book

* ข้อมูลเพิ่มเติม: [โครงการเอกสาร Rails](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)

การสนับสนุน Ruby 1.9.1
------------------

Rails 2.3 ควรผ่านการทดสอบของตัวเองทั้งหมดไม่ว่าคุณจะใช้ Ruby 1.8 หรือ Ruby 1.9.1 ที่เปิดตัวแล้ว อย่างไรก็ตามคุณควรทราบว่าการย้ายไปยัง 1.9.1 นั้นเกี่ยวข้องกับการตรวจสอบความเข้ากันได้ของตัวอ่านข้อมูล ปลั๊กอิน และรหัสอื่น ๆ ที่คุณพึ่งพอใจในการเข้ากันได้กับ Ruby 1.9.1 รวมถึง Rails core

Active Record
-------------

Active Record ได้รับคุณสมบัติใหม่และการแก้ไขข้อบกพร่องจำนวนมากใน Rails 2.3 จุดเด่นของมันรวมถึง nested attributes, nested transactions, dynamic และ default scopes และ batch processing

### Nested Attributes

Active Record สามารถอัปเดตแอตทริบิวต์บนโมเดลที่ซ้อนกันได้โดยตรง หากคุณบอกให้มันทำเช่นนั้น:

```ruby
class Book < ActiveRecord::Base
  has_one :author
  has_many :pages

  accepts_nested_attributes_for :author, :pages
end
```

การเปิดใช้งาน nested attributes จะเปิดให้ใช้งานหลายอย่าง: การบันทึกบันทึก (และอะตอมิก) ของบันทึกพร้อมกับลูกของมัน การตรวจสอบความถูกต้องของลูก และการสนับสนุนฟอร์มที่ซ้อนกัน (ที่จะได้กล่าวถึงในภายหลัง)

คุณยังสามารถระบุเงื่อนไขสำหรับบันทึกใหม่ใด ๆ ที่เพิ่มผ่าน nested attributes โดยใช้ตัวเลือก `:reject_if`:

```ruby
accepts_nested_attributes_for :author,
  :reject_if => proc { |attributes| attributes['name'].blank? }
```

* ผู้มีส่วนร่วมหลัก: [Eloy Duran](http://superalloy.nl/)
* ข้อมูลเพิ่มเติม: [ฟอร์มโมเดลที่ซ้อนกัน](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)

### Nested Transactions

Active Record ตอนนี้สนับสนุนการทำธุรกรรมที่ซ้อนกัน ซึ่งเป็นคุณสมบัติที่ถูกขอให้มากที่สุด ตอนนี้คุณสามารถเขียนโค้ดเช่นนี้ได้:

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

การทำธุรกรรมที่ซ้อนกันช่วยให้คุณยกเลิกการทำธุรกรรมภายในโดยไม่มีผลต่อสถานะของธุรกรรมภายนอก หากคุณต้องการให้การทำธุรกรรมเป็นซ้อนกันคุณต้องเพิ่มตัวเลือก `:requires_new` โดยชัดเจน มิฉะนั้นการทำธุรกรรมที่ซ้อนกันก็เป็นส่วนหนึ่งของธุรกรรมหลัก (เหมือนกับที่เกิดขึ้นใน Rails 2.2) ภายใต้การดูแลระดับนอกจากนี้การทำธุรกรรมที่ซ้อนกันก็ใช้ [savepoints](http://rails.lighthouseapp.com/projects/8994/tickets/383) ดังนั้นมันสามารถใช้ได้แม้บนฐานข้อมูลที่ไม่มีการทำธุรกรรมที่ซ้อนกันจริง ๆ ยังมีการใช้เทคนิคเล็กน้อยเพื่อให้การทำธุรกรรมเหล่านี้ทำงานร่วมกับการติดตั้งทดสอบของ transactional fixtures

* ผู้มีส่วนร่วมหลัก: [Jonathan Viney](http://www.workingwithrails.com/person/4985-jonathan-viney) และ [Hongli Lai](http://izumi.plan99.net/blog/)

### Dynamic Scopes

คุณรู้จัก dynamic finders ใน Rails (ซึ่งช่วยให้คุณสร้างเมธอดเช่น `find_by_color_and_flavor` ตอนที่คุณต้องการ) และ named scopes (ซึ่งช่วยให้คุณแยกเงื่อนไขการค้นหาที่ใช้ซ้ำได้เป็นชื่อที่เป็นมิตรเช่น `currently_active`) ที่นี่คุณสามารถมีเมธอด dynamic scope ได้ ความคิดคือการรวบรวมไวยากรณ์ที่ช่วยให้คุณกรองข้อมูลได้ตลอดเวลา _และ_ สามารถเชื่อมต่อเมธอดได้ เช่น:

```ruby
Order.scoped_by_customer_id(12)
Order.scoped_by_customer_id(12).find(:all,
  :conditions => "status = 'open'")
Order.scoped_by_customer_id(12).scoped_by_status("open")
```

ไม่ต้องกำหนดให้ใช้ dynamic scopes: มันทำงานโดยอัตโนมัติ

* ผู้มีส่วนร่วมหลัก: [Yaroslav Markin](http://evilmartians.com/)
* ข้อมูลเพิ่มเติม: [สิ่งใหม่ใน Edge Rails: Dynamic Scope Methods](http://archives.ryandaigle.com/articles/2008/12/29/what-s-new-in-edge-rails-dynamic-scope-methods)

### Default Scopes

Rails 2.3 จะนำเสนอแนวคิดของ _default scopes_ ที่คล้ายกับ named scopes แต่ใช้กับทุก ๆ named scopes หรือเมธอดการค้นหาภายในโมเดล ตัวอย่างเช่นคุณสามารถเขียน `default_scope :order => 'name ASC'` และทุกครั้งที่คุณเรียกดึงข้อมูลจากโมเดลนั้น ๆ มันจะถู
* ผู้มีส่วนร่วมหลัก: Paweł Kondzior
* ข้อมูลเพิ่มเติม: [สิ่งใหม่ใน Edge Rails: Default Scoping](http://archives.ryandaigle.com/articles/2008/11/18/what-s-new-in-edge-rails-default-scoping)

### Batch Processing

คุณสามารถประมวลผลจำนวนมากของเรคคอร์ดจาก Active Record model โดยใช้หน่วยความจำน้อยลงด้วย `find_in_batches`:

```ruby
Customer.find_in_batches(:conditions => {:active => true}) do |customer_group|
  customer_group.each { |customer| customer.update_account_balance! }
end
```

คุณสามารถส่งค่าตัวเลือกของ `find` เข้าไปใน `find_in_batches` ได้เกือบทั้งหมด อย่างไรก็ตาม คุณไม่สามารถระบุลำดับของเรคคอร์ดที่จะถูกส่งกลับมา (เรคคอร์ดจะถูกส่งกลับมาเสมอในลำดับของ primary key ที่เป็น integer) หรือใช้ตัวเลือก `:limit` แทน แทนที่นั้น ให้ใช้ตัวเลือก `:batch_size` ซึ่งมีค่าเริ่มต้นเป็น 1000 เพื่อกำหนดจำนวนเรคคอร์ดที่จะถูกส่งกลับมาในแต่ละกลุ่ม.

เมธอดใหม่ `find_each` จะให้คุณเรียกใช้ `find_in_batches` แต่ส่งค่าเรคคอร์ดแต่ละรายการกลับมา โดยการค้นหาเองจะถูกทำในแต่ละกลุ่ม (โดยค่าเริ่มต้นคือ 1000):

```ruby
Customer.find_each do |customer|
  customer.update_account_balance!
end
```

โปรดทราบว่าคุณควรใช้เมธอดนี้เฉพาะสำหรับการประมวลผลแบบกลุ่ม: สำหรับจำนวนเรคคอร์ดที่น้อย (น้อยกว่า 1000) คุณควรใช้เมธอด find ปกติพร้อมกับลูปของคุณเอง.

* ข้อมูลเพิ่มเติม (ในจุดนั้น วิธีการที่สะดวกเรียกว่า `each`):
    * [Rails 2.3: Batch Finding](http://afreshcup.com/2009/02/23/rails-23-batch-finding/)
    * [สิ่งใหม่ใน Edge Rails: Batched Find](http://archives.ryandaigle.com/articles/2009/2/23/what-s-new-in-edge-rails-batched-find)

### เงื่อนไขหลายอย่างสำหรับ Callbacks

เมื่อใช้ Active Record callbacks คุณสามารถรวม `:if` และ `:unless` options ใน callback เดียวกันได้ และสามารถให้เงื่อนไขหลายอย่างเป็นอาร์เรย์ได้:

```ruby
before_save :update_credit_rating, :if => :active,
  :unless => [:admin, :cash_only]
```
* ผู้มีส่วนร่วมหลัก: L. Caviola

### ค้นหาพร้อมกับการมี

Rails ตอนนี้มีตัวเลือก `:having` ในการค้นหา (รวมถึงในการสร้างความสัมพันธ์ `has_many` และ `has_and_belongs_to_many`) เพื่อกรองเรคคอร์ดในการค้นหาที่มีการจัดกลุ่ม ตามที่ผู้ที่มีพื้นฐาน SQL แข็งแกร่งรู้ว่าสิ่งนี้ช่วยในการกรองข้อมูลตามผลลัพธ์ที่จัดกลุ่ม:

```ruby
developers = Developer.find(:all, :group => "salary",
  :having => "sum(salary) > 10000", :select => "salary")
```

* ผู้มีส่วนร่วมหลัก: [Emilio Tagua](https://github.com/miloops)

### เชื่อมต่อ MySQL Connections ใหม่

MySQL รองรับตัวแปร reconnect ในการเชื่อมต่อ - หากตั้งค่าเป็น true แล้วไคลเอนต์จะพยายามเชื่อมต่อกับเซิร์ฟเวอร์อีกครั้งก่อนที่จะยกเลิกในกรณีที่เชื่อมต่อหายไป คุณสามารถตั้งค่า `reconnect = true` สำหรับการเชื่อมต่อ MySQL ใน `database.yml` เพื่อให้แอปพลิเคชัน Rails ทำงานดังนี้ ค่าเริ่มต้นคือ `false` ดังนั้นพฤติกรรมของแอปพลิเคชันที่มีอยู่ไม่เปลี่ยนแปลง.

* ผู้มีส่วนร่วมหลัก: [Dov Murik](http://twitter.com/dubek)
* ข้อมูลเพิ่มเติม:
    * [การควบคุมพฤติกรรมการเชื่อมต่ออัตโนมัติ](http://dev.mysql.com/doc/refman/5.6/en/auto-reconnect.html)
    * [MySQL auto-reconnect revisited](http://groups.google.com/group/rubyonrails-core/browse_thread/thread/49d2a7e9c96cb9f4)

### การเปลี่ยนแปลง Active Record อื่น ๆ

* ลบ `AS` เพิ่มเติมออกจาก SQL ที่สร้างขึ้นสำหรับการโหลดล่วงหน้าของ `has_and_belongs_to_many` เพื่อให้ทำงานได้ดีขึ้นสำหรับฐานข้อมูลบางแห่ง
* `ActiveRecord::Base#new_record?` ตอนนี้จะส่งคืน `false` แทนที่จะส่งคืน `nil` เมื่อพบเรคคอร์ดที่มีอยู่แล้ว
* แก้ไขข้อบกพร่องในการอ้างอิงชื่อตารางในบางความสัมพันธ์ `has_many :through`
* คุณสามารถระบุ timestamp ที่เฉพาะเวลาสำหรับ `updated_at` timestamps: `cust = Customer.create(:name => "ABC Industries", :updated_at => 1.day.ago)`
* ข้อความผิดพลาดที่ดีขึ้นเมื่อเรียกใช้ `find_by_attribute!` ไม่สำเร็จ
* การสนับสนุน `to_xml` ของ Active Record ยืดหยุ่นขึ้นเล็กน้อยด้วยการเพิ่มตัวเลือก `:camelize`
* แก้ไขข้อบกพร่องในการยกเลิก callbacks จาก `before_update` หรือ `before_create`
* เพิ่มงาน Rake สำหรับการทดสอบฐานข้อมูลผ่าน JDBC
* `validates_length_of` จะใช้ข้อความผิดพลาดที่กำหนดเองด้วยตัวเลือก `:in` หรือ `:within` (หากมีการระบุ)
* การนับบนการเลือกที่มีเงื่อนไขทำงานอย่างถูกต้อง ดังนั้นคุณสามารถทำสิ่งต่าง ๆ เช่น `Account.scoped(:select => "DISTINCT credit_limit").count`
* `ActiveRecord::Base#invalid?` ตอนนี้ทำงานเป็นตรงกันข้ามกับ `ActiveRecord::Base#valid?`.

Action Controller
-----------------

Action Controller มีการเปลี่ยนแปลงที่สำคัญในการเรนเดอร์ และการปรับปรุงในเส้นทางและพื้นที่อื่น ๆ ในการเผยแพร่นี้.

### เรนเดอร์ที่เป็นเอกลักษณ์

`ActionController::Base#render` มีความฉลาดมากขึ้นในการตัดสินใจว่าจะเรนเดอร์อะไร ตอนนี้คุณสามารถบอกให้มันเรนเดอร์และคาดหวังผลลัพธ์ที่ถูกต้องได้ ในรุ่นเก่าของ Rails คุณต้องให้ข้อมูลชัดเจนให้กับเรนเดอร์:

```ruby
render :template => "users/show"
```

```ruby
render :file => '/tmp/random_file.erb'
render :template => 'other_controller/action'
render :action => 'show'
```

ใน Rails 2.3 คุณสามารถให้ข้อมูลที่คุณต้องการ render ได้เลย:

```ruby
render '/tmp/random_file.erb'
render 'other_controller/action'
render 'show'
render :show
```

Rails จะเลือกการ render ระหว่าง file, template, และ action ขึ้นอยู่กับว่ามีเครื่องหมาย / นำหน้า, / ภายใน, หรือไม่มีเครื่องหมาย / ที่จะ render ข้อมูล โปรดทราบว่าคุณยังสามารถใช้สัญลักษณ์แทนสตริงเมื่อ render action ได้ รูปแบบการ render อื่น ๆ (`:inline`, `:text`, `:update`, `:nothing`, `:json`, `:xml`, `:js`) ยังต้องใช้ตัวเลือกอย่างชัดเจน

### Application Controller ถูกเปลี่ยนชื่อ

หากคุณเป็นคนหนึ่งที่รู้สึกไม่พอใจกับการตั้งชื่อพิเศษของ `application.rb` ใน Rails 2.3 คุณสามารถดีใจได้! มันถูกเปลี่ยนเป็น `application_controller.rb` ใน Rails 2.3 นอกจากนี้ยังมี rake task ใหม่ `rake rails:update:application_controller` ที่จะทำการเปลี่ยนชื่อโดยอัตโนมัติให้คุณ - และมันจะถูกเรียกใช้เป็นส่วนหนึ่งของกระบวนการ `rake rails:update` ปกติ

* ข้อมูลเพิ่มเติม:
    * [The Death of Application.rb](https://afreshcup.com/home/2008/11/17/rails-2x-the-death-of-applicationrb)
    * [What's New in Edge Rails: Application.rb Duality is no More](http://archives.ryandaigle.com/articles/2008/11/19/what-s-new-in-edge-rails-application-rb-duality-is-no-more)

### รองรับการตรวจสอบสิทธิ์ด้วย HTTP Digest Authentication

Rails ตอนนี้มีการรองรับการตรวจสอบสิทธิ์ด้วย HTTP digest authentication ในตัว ในการใช้งานคุณเรียกใช้ `authenticate_or_request_with_http_digest` พร้อมกับบล็อกที่คืนรหัสผ่านของผู้ใช้ (ซึ่งจะถูกแฮชและเปรียบเทียบกับข้อมูลประจำตัวที่ถูกส่ง):

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

### Routing ที่มีประสิทธิภาพมากขึ้น

มีการเปลี่ยนแปลงในการ routing ที่สำคัญใน Rails 2.3 มีการลบ `formatted_` route helpers และใช้การส่ง `:format` เป็นตัวเลือกแทน สิ่งนี้ลดกระบวนการสร้างเส้นทางลง 50% สำหรับทรัพยากรใด ๆ - และสามารถประหยัดหน่วยความจำได้มาก (สูงสุดถึง 100MB สำหรับแอปพลิเคชันขนาดใหญ่) หากโค้ดของคุณใช้ `formatted_` helpers โค้ดยังคงทำงานได้ตามปกติในขณะนี้ - แต่พฤติกรรมนี้ถูกยกเลิกและแอปพลิเคชันของคุณจะมีประสิทธิภาพมากขึ้นหากคุณเขียนเส้นทางเหล่านั้นใหม่โดยใช้มาตรฐานใหม่ การเปลี่ยนแปลงอีกอย่างหนึ่งคือ Rails ตอนนี้รองรับไฟล์ routing หลายไฟล์ไม่ใช่เพียง `routes.rb` เท่านั้น คุณสามารถใช้ `RouteSet#add_configuration_file` เพื่อนำเสนอเส้นทางเพิ่มเติมได้ทุกเมื่อ - โดยไม่ต้องล้างเส้นทางที่โหลดอยู่ในปัจจุบัน แม้ว่าการเปลี่ยนแปลงนี้จะเป็นประโยชน์มากที่สุดสำหรับ Engines แต่คุณสามารถใช้ได้ในแอปพลิเคชันใด ๆ ที่ต้องโหลดเส้นทางเป็นกลุ่ม

* ผู้มีส่วนร่วมหลัก: [Aaron Batalion](http://blog.hungrymachine.com/)

### การจัดการเซสชันที่โหลดเกินความจำด้วย Rack

การเปลี่ยนแปลงที่สำคัญคือการย้ายการจัดเก็บเซสชันใน Action Controller ลงไปยังระดับ Rack นี้เป็นการทำงานที่มีความสำคัญมากในรหัส แม้ว่ามันจะเป็นการเปลี่ยนแปลงที่สำคัญ แต่มันควรเป็นโปร่งใสต่อแอปพลิเคชัน Rails ของคุณ (นอกจากนี้ยังมีการลบแพทช์ที่ไม่ดีรอบ CGI session handler เก่าออก) แต่มันยังมีความสำคัญอย่างง่ายดาย: แอปพลิเคชัน Rack ที่ไม่ใช่ Rails สามารถเข้าถึงการจัดเก็บเซสชันเดียวกัน (และดังนั้นเซสชันเดียวกัน) กับแอปพลิเคชัน Rails ของคุณ นอกจากนี้ การโหลดเซสชันเป็นการโหลดเมื่อจำเป็น (ในส่วนของการปรับปรุงการโหลดในส่วนอื่น ๆ ของเฟรมเวิร์ก) นี่หมายความว่าคุณไม่จำเป็นต้องปิดใช้งานเซสชันโดยชัดเจนหากคุณไม่ต้องการใช้งาน; เพียงแค่อย่าอ้างถึงเซสชันและมันจะไม่โหลด

### การเปลี่ยนแปลงในการจัดการ MIME Type

มีการเปลี่ยนแปลงในรหัสการจัดการ MIME types ใน Rails ก่อนอื่น `MIME::Type` ตอนนี้มีการใช้งานตัวดำเนินการ `=~` ทำให้สะดวกมากขึ้นเมื่อคุณต้องการตรวจสอบการมีอยู่ของชนิดที่มีคำเหมือนกัน:

```ruby
if content_type && Mime::JS =~ content_type
  # ทำบางสิ่งที่น่าสนใจ
end

Mime::JS =~ "text/javascript"        => true
Mime::JS =~ "application/javascript" => true
```

การเปลี่ยนแปลงอีกอย่างคือ framework ใช้ `Mime::JS` เมื่อตรวจสอบ JavaScript ในสถานที่ต่าง ๆ ทำให้มันทำงานได้อย่างสะอาด

* ผู้มีส่วนร่วมหลัก: [Seth Fitzsimmons](http://www.workingwithrails.com/person/5510-seth-fitzsimmons)

### การปรับปรุง `respond_to`

ในบางส่วนของผลงานแรกของทีมผู้พัฒนา Rails-Merb การปรับปรุง Rails 2.3 รวมถึงการปรับปรุงสำหรับเมธอด `respond_to` ซึ่งถูกใช้งานอย่างหนักในแอปพลิเคชัน Rails หลายรายการเพื่อให้คอนโทรลเลอร์ของคุณสามารถจัดรูปแบบผลลัพธ์ได้อย่างแตกต่างกันตามประเภท MIME ของคำขอที่เข้ามา หลังจากลดการเรียกใช้ `method_missing` และการปรับปรุงและปรับแต่งโดยใช้การวิเคราะห์ประสิทธิภาพ เราพบว่ามีการปรับปรุงขึ้น 8% ในจำนวนคำขอต่อวินาทีที่บริการด้วย `respond_to` ที่เปลี่ยนรูปแบบระหว่างสามรูปแบบ ส่วนที่ดีที่สุด? ไม่จำเป็นต้องเปลี่ยนโค้ดของแอปพลิเคชันของคุณเลยเพื่อใช้ประโยชน์จากการเร่งความเร็วนี้

### ประสิทธิภาพการใช้งานแคชที่ดีขึ้น

Rails ตอนนี้เก็บแคชที่อ่านจากร้านค้าแคชระยะไกลในแต่ละคำขอเพื่อลดการอ่านที่ไม่จำเป็นและเพิ่มประสิทธิภาพของเว็บไซต์ ขณะที่งานนี้เริ่มต้นจาก `MemCacheStore` แต่มันสามารถใช้ได้กับร้านค้าระยะไกลใด ๆ ที่ประยุกต์ใช้เมธอดที่จำเป็น

* ผู้มีส่วนร่วมหลัก: [Nahum Wild](http://www.motionstandingstill.com/)

### มุมมองที่แตกต่างกันตามภาษา

Rails ตอนนี้สามารถให้มุมมองที่แตกต่างกันได้ขึ้นอยู่กับภาษาที่คุณตั้งค่าไว้ ตัวอย่างเช่น สมมุติว่าคุณมีคอนโทรลเลอร์ `Posts` ที่มีการกระทำ `show` โดยค่าเริ่มต้นจะแสดงผล `app/views/posts/show.html.erb` แต่ถ้าคุณตั้งค่า `I18n.locale = :da` จะแสดงผล `app/views/posts/show.da.html.erb` หากไม่มีเทมเพลตที่แปลงไว้ จะใช้เทมเพลตที่ไม่มีการตกแต่งแทน นอกจากนี้ Rails ยังรวม `I18n#available_locales` และ `I18n::SimpleBackend#available_locales` ซึ่งจะส่งคืนอาร์เรย์ของการแปลที่มีอยู่ในโปรเจกต์ Rails ปัจจุบัน

นอกจากนี้คุณยังสามารถใช้รูปแบบเดียวกันเพื่อแปลงไฟล์ช่วยเหลือในไดเรกทอรีสาธารณะ: `public/500.da.html` หรือ `public/404.en.html` ทำงานเช่นนี้

### การจำกัดขอบเขตสำหรับการแปล

การเปลี่ยนแปลงใน API การแปลทำให้ง่ายและไม่ซ้ำซ้อนในการเขียนการแปลที่มีคีย์ภายในส่วนย่อย หากคุณเรียกใช้ `translate(".foo")` จากเทมเพลต `people/index.html.erb` จริง ๆ คุณกำลังเรียกใช้ `I18n.translate("people.index.foo")` หากคุณไม่ใส่จุดหน้าคีย์ แล้ว API จะไม่มีขอบเขตเหมือนเดิม

### การเปลี่ยนแปลงอื่น ๆ ใน Action Controller

* การจัดการ ETag ได้รับการปรับปรุงเล็กน้อย: Rails ตอนนี้จะข้ามการส่งส่วนหัว ETag เมื่อไม่มีเนื้อหาในการตอบกลับหรือเมื่อส่งไฟล์ด้วย `send_file`
* การตรวจสอบการปลอม IP อาจเป็นการรบกวนสำหรับเว็บไซต์ที่มีการใช้งานหนักกับโทรศัพท์มือถือ เนื่องจากพร็อกซี่ของพวกเขาไม่ได้ตั้งค่าอย่างถูกต้อง หากคุณเป็นคุณคือ คุณสามารถตั้งค่า `ActionController::Base.ip_spoofing_check = false` เพื่อปิดการตรวจสอบเลย
* `ActionController::Dispatcher` ตอนนี้ใช้งานสแต็กมิดเวร์แอร์เองซึ่งคุณสามารถดูได้โดยการเรียกใช้ `rake middleware`
* เซสชันคุกกี้ตอนนี้มีตัวระบุเซสชันที่ต่อเนื่องกับร้านค้าฝั่งเซิร์ฟเวอร์ และเข้ากันได้กับ API
* ตอนนี้คุณสามารถใช้สัญลักษณ์สำหรับตัวเลือก `:type` ของ `send_file` และ `send_data` เช่น `send_file("fabulous.png", :type => :png)`
* ตัวเลือก `:only` และ `:except` สำหรับ `map.resources` ไม่ได้ถูกสืบทอดโดยทรรศนะที่ซ้อนกัน
* ไคลเอ็นต์ memcached ที่รวมมาได้รับการอัปเดตเป็นเวอร์ชัน 1.6.4.99
* เมธอด `expires_in`, `stale?`, และ `fresh_when` ตอนนี้ยอมรับตัวเลือก `:public` เพื่อทำให้ทำงานร่วมกับแคชพร็อกซีได้ดี
* ตัวเลือก `:requirements` ทำงานอย่างถูกต้องกับเส้นทางสมาชิก RESTful เพิ่มเติม
* เส้นทางที่ต่ำลึกตอนนี้เคารพเนมสเปซได้อย่างถูกต้อง
* `polymorphic_url` ทำงานได้ดีขึ้นในการจัดการวัตถุที่มีชื่อพหูพจน์ที่ไม่เป็นไปตามกฎ
```ruby
class Customer < ActiveRecord::Base
  has_many :orders

  accepts_nested_attributes_for :orders, :allow_destroy => true
end
```

คุณสามารถเขียนมุมมองนี้ใน Rails 2.3:

```html+erb
<% form_for @customer do |customer_form| %>
  <div>
    <%= customer_form.label :name, 'ชื่อลูกค้า:' %>
    <%= customer_form.text_field :name %>
  </div>

  <!-- ที่นี่เราเรียก fields_for บนตัวอินสแตนซ์ของ customer_form builder
   บล็อกจะถูกเรียกสำหรับแต่ละสมาชิกในคอลเลกชันของคำสั่ง -->
  <% customer_form.fields_for :orders do |order_form| %>
    <p>
      <div>
        <%= order_form.label :number, 'หมายเลขคำสั่งซื้อ:' %>
        <%= order_form.text_field :number %>
      </div>

  <!-- ตัวเลือก allow_destroy ในโมเดลทำให้สามารถลบรายการย่อยได้ -->
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
    * [ฟอร์มโมเดลที่ซ้อนกัน](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)
    * [complex-form-examples](https://github.com/alloy/complex-form-examples)
    * [อะไรใหม่ใน Edge Rails: ฟอร์มวัตถุที่ซ้อนกัน](http://archives.ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes)

### การแสดงผลส่วนย่อยอัจฉริยะ

เมธอด render ได้รับการปรับปรุงให้ฉลาดมากขึ้นตลอดเวลา และตอนนี้มันฉลาดมากขึ้นอีกด้วย หากคุณมีวัตถุหรือคอลเลกชันที่เหมาะสมและชื่อตรงกัน คุณสามารถแค่แสดงผลวัตถุและสิ่งที่คุณต้องการจะทำงาน ตัวอย่างเช่นใน Rails 2.3 การเรียก render เหล่านี้จะทำงานในมุมมองของคุณ (ในกรณีที่มีการตั้งชื่อที่เหมาะสม):

```ruby
# เทียบเท่ากับ render :partial => 'articles/_article',
# :object => @article
render @article

# เทียบเท่ากับ render :partial => 'articles/_article',
# :collection => @articles
render @articles
```

* ข้อมูลเพิ่มเติม: [อะไรใหม่ใน Edge Rails: render ไม่ต้องดูแลมากแล้ว](http://archives.ryandaigle.com/articles/2008/11/20/what-s-new-in-edge-rails-render-stops-being-high-maintenance)

### ข้อความให้เลือกสำหรับช่วยเหลือในการเลือกวันที่

ใน Rails 2.3 คุณสามารถระบุข้อความให้เลือกเองสำหรับช่วยเหลือในเครื่องมือการเลือกวันที่ต่าง ๆ (`date_select`, `time_select`, และ `datetime_select`) ด้วยวิธีเดียวกับเครื่องมือการเลือกคอลเลกชัน คุณสามารถระบุสตริงข้อความหรือแฮชของข้อความช่วยเหลือแต่ละส่วนได้ คุณยังสามารถตั้งค่า `:prompt` เป็น `true` เพื่อใช้ข้อความช่วยเหลือทั่วไป:

```ruby
select_datetime(DateTime.now, :prompt => true)

select_datetime(DateTime.now, :prompt => "เลือกวันที่และเวลา")

select_datetime(DateTime.now, :prompt =>
  {:day => 'เลือกวัน', :month => 'เลือกเดือน',
   :year => 'เลือกปี', :hour => 'เลือกชั่วโมง',
   :minute => 'เลือกนาที'})
```

* ผู้มีส่วนร่วมหลัก: [Sam Oliver](http://samoliver.com/)

### การแคชแทมสำหรับ AssetTag

คุณคงคุ้นเคยกับการเพิ่มแทมสำหรับเส้นทางทรัพยากรแบบสถิตใน Rails เพื่อเป็น "cache buster" ซึ่งช่วยให้แน่ใจว่าสำเนาที่ล้าสมัยของสิ่งต่าง ๆ เช่นรูปภาพและสไตล์ชีทไม่ได้รับการให้บริการจากแคชของเบราว์เซอร์ของผู้ใช้เมื่อคุณเปลี่ยนแปลงเหล่านั้นบนเซิร์ฟเวอร์ ตอนนี้คุณสามารถปรับแต่งพฤติกรรมนี้ด้วยตัวเลือกการกำหนดค่า `cache_asset_timestamps` สำหรับ Action View หากคุณเปิดใช้แคช แล้ว Rails จะคำนวณแทมสำหรับทรัพยากรครั้งแรกที่มันให้บริการและบันทึกค่านั้น ซึ่งหมายความว่าจะมีการเรียกใช้ระบบไฟล์น้อยลง (ที่แพง) เพื่อให้บริการทรัพยากรแบบสถิต - แต่นี่ยังหมายความว่าคุณไม่สามารถแก้ไขทรัพยากรใด ๆ ในขณะที่เซิร์ฟเวอร์กำลังทำงานและคาดว่าการเปลี่ยนแปลงจะถูกเลือกโดยไคลเอ็นต์

### Asset Hosts เป็นวัตถุ

Asset hosts กลายเป็นเครื่องมือที่ยืดหยุ่นมากขึ้นใน edge Rails ด้วยความสามารถในการประกาศ asset host เป็นวัตถุที่เฉพาะที่ตอบสนองต่อการเรียกใช้ นี่ช่วยให้คุณสามารถนำเอาตรรกะที่ซับซ้อนที่คุณต้องการในการโฮสต์ทรัพยากรของคุณ

* ข้อมูลเพิ่มเติม: [asset-hosting-with-minimum-ssl](https://github.com/dhh/asset-hosting-with-minimum-ssl/tree/master)

### เมธอดช่วยเหลือ grouped_options_for_select

Action View มีเมธอดช่วยเหลืออีกหนึ่งเมธอดสำหรับการสร้างตัวควบคุมการเลือก ซึ่งเรียกว่า `grouped_options_for_select` เมธอดนี้รับอาร์เรย์หรือแฮชของสตริงและแปลงเป็นสตริงของแท็ก `option` ที่ห่อหุ้มด้วยแท็ก `optgroup` ตัวอย่างเช่น:

```ruby
grouped_options_for_select([["หมวก", ["หมวกเบสบอล","หมวกคาวบอย"]]],
  "หมวกคาวบอย", "เลือกผลิตภัณฑ์...")
```

จะคืนค่า

```html
<option value="">เลือกผลิตภัณฑ์...</option>
<optgroup label="หมวก">
  <option value="หมวกเบสบอล">หมวกเบสบอล</option>
  <option selected="selected" value="หมวกคาวบอย">หมวกคาวบอย</option>
</optgroup>
```
### แท็กตัวเลือกที่ถูกปิดใช้งานสำหรับฟอร์มเลือกตัวช่วย

ฟอร์มเลือกตัวช่วย (เช่น `select` และ `options_for_select`) ตอนนี้สนับสนุนตัวเลือก `:disabled` ซึ่งสามารถรับค่าเดียวหรืออาร์เรย์ของค่าที่จะถูกปิดใช้งานในแท็กที่ได้:

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

คุณยังสามารถใช้ฟังก์ชันไม่มีชื่อเพื่อกำหนดในเวลาที่รันว่าตัวเลือกจากคอลเลกชันใดจะถูกเลือกและ/หรือถูกปิดใช้งาน:

```ruby
options_from_collection_for_select(@product.sizes, :name, :id, :disabled => lambda{|size| size.out_of_stock?})
```

* ผู้มีส่วนร่วมหลัก: [Tekin Suleyman](http://tekin.co.uk/)
* ข้อมูลเพิ่มเติม: [ใหม่ในเรลส์ 2.3 - แท็กตัวเลือกที่ถูกปิดใช้งานและแลมบ์ดาสำหรับการเลือกและปิดใช้งานตัวเลือกจากคอลเลกชัน](https://tekin.co.uk/2009/03/new-in-rails-23-disabled-option-tags-and-lambdas-for-selecting-and-disabling-options-from-collections)

### หมายเหตุเกี่ยวกับการโหลดเทมเพลต

Rails 2.3 รวมความสามารถในการเปิดหรือปิดการใช้งานเทมเพลตแคชสำหรับแต่ละสภาพแวดล้อมได้ การเก็บเทมเพลตในแคชช่วยให้คุณเร็วขึ้นเพราะไม่ต้องตรวจสอบไฟล์เทมเพลตใหม่เมื่อถูกแสดงผล - แต่นั่นหมายความว่าคุณไม่สามารถแทนที่เทมเพลต "ทันที" โดยไม่ต้องเริ่มเซิร์ฟเวอร์ใหม่

ในกรณีส่วนใหญ่คุณต้องการให้แคชเทมเพลตเปิดใช้งานในการผลิตภัณฑ์ ซึ่งคุณสามารถทำได้โดยกำหนดค่าในไฟล์ `production.rb` ของคุณ:

```ruby
config.action_view.cache_template_loading = true
```

บรรทัดนี้จะถูกสร้างขึ้นให้โดยค่าเริ่มต้นในแอปพลิเคชัน Rails 2.3 ใหม่ หากคุณอัปเกรดจากเวอร์ชันเก่าของ Rails Rails จะใช้ค่าเริ่มต้นในการเก็บเทมเพลตในการผลิตและทดสอบแต่ไม่ใช่ในการพัฒนา

### การเปลี่ยนแปลง Action View อื่น ๆ

* การสร้างโทเค็นสำหรับการป้องกัน CSRF ได้รับการปรับปรุงให้ง่ายขึ้น ตอนนี้ Rails ใช้สตริงสุ่มง่ายที่สร้างขึ้นโดย `ActiveSupport::SecureRandom` แทนการใช้งาน session ID
* `auto_link` ตอนนี้ใช้ตัวเลือก (เช่น `:target` และ `:class`) ในการสร้างลิงก์อีเมลได้อย่างถูกต้อง
* เครื่องมือ `autolink` ได้รับการแก้ไขให้เป็นรูปแบบที่เรียบง่ายและใช้งานง่ายขึ้น
* `current_page?` ทำงานได้อย่างถูกต้องแม้ว่าจะมีพารามิเตอร์คิวรีมากกว่าหนึ่งใน URL

Active Support
--------------

Active Support มีการเปลี่ยนแปลงบางอย่างที่น่าสนใจ รวมถึงการนำเสนอ `Object#try`.

### Object#try

ผู้คนหลายคนได้นำแนวคิดในการใช้งาน `try()` เพื่อพยายามดำเนินการกับออบเจกต์ มันเป็นประโยชน์มากในมุมมองที่คุณสามารถหลีกเลี่ยงการตรวจสอบค่า null โดยเขียนโค้ดเช่น `<%= @person.try(:name) %>` ตอนนี้มันถูกบังคับใช้ใน Rails แล้ว ตามที่ได้รับการนำเสนอใน Rails มันจะเรียกใช้ `NoMethodError` สำหรับเมธอดที่เป็นส่วนตัวและคืนค่าเป็น `nil` เสมอหากออบเจกต์เป็น `nil`

* ข้อมูลเพิ่มเติม: [try()](http://ozmm.org/posts/try.html)

### Object#tap Backport

`Object#tap` เป็นการเพิ่มเติมใน [Ruby 1.9](http://www.ruby-doc.org/core-1.9/classes/Object.html#M000309) และ 1.8.7 ที่คล้ายกับเมธอด `returning` ที่ Rails มีมานานแล้ว: มันเรียกใช้งานบล็อกและคืนค่าออบเจกต์ที่ถูกเรียกใช้ ตอนนี้ Rails รวมรหัสเพื่อทำให้สามารถใช้งานได้ในเวอร์ชันเก่าของ Ruby เช่นกัน

### การเปลี่ยนแปลง Parsers ที่สามารถเปลี่ยนได้สำหรับ XMLmini

การสนับสนุนการแยกวิเคราะห์ XML ใน Active Support ได้รับความยืดหยุ่นมากขึ้นโดยอนุญาตให้คุณสามารถแทนที่ Parsers ที่แตกต่างกันได้ โดยค่าเริ่มต้นจะใช้การแยกวิเคราะห์ REXML มาตรฐาน แต่คุณสามารถระบุการแยกวิเคราะห์ LibXML หรือ Nokogiri ที่เร็วกว่าสำหรับแอปพลิเคชันของคุณได้ง่ายๆ หากคุณมี gem ที่เหมาะสมติดตั้งแล้ว:

```ruby
XmlMini.backend = 'LibXML'
```

* ผู้มีส่วนร่วมหลัก: [Bart ten Brinke](http://www.movesonrails.com/)
* ผู้มีส่วนร่วมหลัก: [Aaron Patterson](http://tenderlovemaking.com/)

### วินาทีทศนิยมสำหรับ TimeWithZone

คลาส `Time` และ `TimeWithZone` รวมถึงเมธอด `xmlschema` เพื่อคืนค่าเวลาในรูปแบบสตริงที่เหมาะกับ XML ตั้งแต่ Rails 2.3 เป็นต้นไป `TimeWithZone` รองรับอาร์กิวเมนต์เดียวกับ `Time` ในการระบุจำนวนหลักทศนิยมในส่วนที่เป็นวินาทีของสตริงที่คืนค่า:

```ruby
Time.zone.now.xmlschema(6) # => "2009-01-16T13:00:06.13653Z"
```

* ผู้มีส่วนร่วมหลัก: [Nicholas Dainty](http://www.workingwithrails.com/person/13536-nicholas-dainty)

### การอ้างอิงคีย์ JSON

หากคุณค้นหาสเปคในเว็บไซต์ "json.org" คุณจะค้นพบว่าคีย์ทั้งหมดในโครงสร้าง JSON ต้องเป็นสตริงและต้องอ้างอิงด้วยเครื่องหมายคำพูดคู่ ตั้งแต่ Rails 2.3 เป็นต้นไป เราทำสิ่งที่ถูกต้องที่นี่ แม้ว่าจะมีคีย์ที่เป็นตัวเลข


### การเปลี่ยนแปลง Active Support อื่น ๆ

* คุณสามารถใช้ `Enumerable#none?` เพื่อตรวจสอบว่าไม่มีองค์ประกอบใด ๆ ตรงกับบล็อกที่กำหนด
* หากคุณใช้ Active Support [delegates](https://afreshcup.com/home/2008/10/19/coming-in-rails-22-delegate-prefixes) ตัวเลือกใหม่ `:allow_nil` ช่วยให้คุณสามารถส่งคืน `nil` แทนที่จะเกิดข้อยกเว้นเมื่อวัตถุเป้าหมายเป็น nil
* `ActiveSupport::OrderedHash`: ตอนนี้มีการนำมาใช้งาน `each_key` และ `each_value`
* `ActiveSupport::MessageEncryptor` ให้วิธีง่าย ๆ ในการเข้ารหัสข้อมูลสำหรับการเก็บรักษาในตำแหน่งที่ไม่น่าเชื่อถือ (เช่นคุกกี้)
* `Active Support` ของ `from_xml` ไม่ได้พึ่งพา XmlSimple อีกต่อไป แทนที่ Rails ตอนนี้รวม XmlMini ที่มีฟังก์ชันเพียงพอต่อการทำงานของมันเท่านั้น นี้ทำให้ Rails สามารถทำงานได้โดยไม่ต้องมี XmlSimple ที่ถูกแนบมาด้วย
* หากคุณ memoize เมธอดส่วนตัว ผลลัพธ์จะเป็นส่วนตัว
* `String#parameterize` ยอมรับตัวคั่นทางเลือก: `"Quick Brown Fox".parameterize('_') => "quick_brown_fox"`
* `number_to_phone` ยอมรับหมายเลขโทรศัพท์ 7 หลักเท่านั้น
* `ActiveSupport::Json.decode` ตอนนี้รองรับ `\u0000` ลักษณะการหนีไปแล้ว

Railties
--------

นอกจากการเปลี่ยนแปลงของ Rack ที่กล่าวถึงข้างต้นแล้ว Railties (รหัสหลักของ Rails เอง) ยังมีการเปลี่ยนแปลงที่สำคัญอีกมากมาย เช่น Rails Metal, application templates, และ quiet backtraces.

### Rails Metal

Rails Metal เป็นกลไกใหม่ที่ให้สามารถสร้างจุดปลายทางที่เร็วมากภายในแอปพลิเคชัน Rails ของคุณได้ Metal classes ทำงานผ่านการเส้นทางและ Action Controller เพื่อให้คุณได้ความเร็วสูง (แต่ต้องสละสิ่งทั้งหมดใน Action Controller แน่นอน) นี้เป็นการพัฒนาต่อจากงานรากฐานล่าสุดที่ทำให้ Rails เป็นแอปพลิเคชัน Rack ที่มีการเปิดเผย middleware stack Metal endpoints สามารถโหลดจากแอปพลิเคชันของคุณหรือจากปลั๊กอิน

* ข้อมูลเพิ่มเติม:
    * [Introducing Rails Metal](https://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal)
    * [Rails Metal: a micro-framework with the power of Rails](http://soylentfoo.jnewland.com/articles/2008/12/16/rails-metal-a-micro-framework-with-the-power-of-rails-m)
    * [Metal: Super-fast Endpoints within your Rails Apps](http://www.railsinside.com/deployment/180-metal-super-fast-endpoints-within-your-rails-apps.html)
    * [What's New in Edge Rails: Rails Metal](http://archives.ryandaigle.com/articles/2008/12/18/what-s-new-in-edge-rails-rails-metal)

### Application Templates

Rails 2.3 รวมการสร้างแอปพลิเคชันที่ใช้เทมเพลตของ Jeremy McAnally [rg](https://github.com/jm/rg) ซึ่งหมายความว่าเราตอนนี้มีการสร้างแอปพลิเคชันที่ใช้เทมเพลตซึ่งมีอยู่ใน Rails แล้ว หากคุณมีเซ็ตของปลั๊กอินที่คุณเพิ่มเข้าไปในแอปพลิเคชันทุกตัวอย่างในทุกกรณีการใช้งานอื่น ๆ คุณสามารถตั้งค่าเทมเพลตครั้งเดียวแล้วใช้ซ้ำได้เมื่อคุณเรียกใช้คำสั่ง `rails` นอกจากนี้ยังมีงาน rake เพื่อใช้เทมเพลตกับแอปพลิเคชันที่มีอยู่แล้ว:

```bash
$ rake rails:template LOCATION=~/template.rb
```

นี้จะใช้เทมเพลตเพื่อเปลี่ยนแปลงโค้ดในโปรเจกต์ที่มีอยู่แล้ว

* ผู้มีส่วนร่วมหลัก: [Jeremy McAnally](http://www.jeremymcanally.com/)
* ข้อมูลเพิ่มเติม: [Rails templates](http://m.onkey.org/2008/12/4/rails-templates)

### การลดเสียง Backtraces

โดยใช้ปลั๊กอิน Quiet Backtrace ของ thoughtbot (https://github.com/thoughtbot/quietbacktrace) ที่ช่วยให้คุณสามารถเอาบางบรรทัดออกจาก backtraces ของ `Test::Unit` ได้เลือกทำให้ Rails 2.3 นำเข้า `ActiveSupport::BacktraceCleaner` และ `Rails::BacktraceCleaner` ในรหัสหลัก สนับสนุนการกรอง (เพื่อทำการแทนที่ด้วย regex บนบรรทัด backtrace) และการปิดเสียง (เพื่อลบบรรทัด backtrace ออก) Rails จะเพิ่มการปิดเสียงเพื่อกำจัดเสียงรบกวนที่ส่วนใหญ่ในแอปพลิเคชันใหม่ และสร้างไฟล์ `config/backtrace_silencers.rb` เพื่อเก็บเพิ่มเติมของคุณเอง คุณสมบัตินี้ยังช่วยให้การพิมพ์สวยงามขึ้นจากแพ็คเกจใด ๆ ใน backtrace

### เวลาเริ่มต้นเร็วขึ้นในโหมดการพัฒนาด้วยการโหลดแบบเกินความจำ/Autoload

ทำงานมากเพื่อให้แน่ใจว่าส่วนของ Rails (และขึ้นอยู่กับมัน) จะถูกนำเข้าหน่วยความจำเมื่อจำเป็นจริง กรอบหลัก - Active Support, Active Record, Action Controller, Action Mailer, และ Action View - ใช้ `autoload` เพื่อโหลดคลาสแต่ละตัวของตนเองเมื่อต้องการ งานนี้ควรช่วยให้ลดพื้นที่หน่วยความจำลงและปรับปรุงประสิทธิภาพของ Rails โดยรวม

คุณยังสามารถระบุ (โดยใช้ตัวเลือก `preload_frameworks` ใหม่) ว่าควรโหลดไลบรารีหลักเมื่อเริ่มต้น ค่าเริ่มต้นคือ `false` เพื่อให้ Rails โหลดตัวเองเป็นส่วนส่วนๆ แต่มีบางสถานการณ์ที่คุณยังต้องการนำเข้าทั้งหมดในครั้งเดียว - Passenger และ JRuby ต้องการเห็น Rails ทั้งหมดที่โหลดมาด้วยกัน
### การเขียนรหัสงาน rake gem ถูกแก้ไขใหม่

ภายในของงาน rake gem ต่าง ๆ ได้รับการแก้ไขอย่างมาก เพื่อให้ระบบทำงานได้ดีขึ้นสำหรับกรณีต่าง ๆ มีการแยกแยะระหว่างการขึ้นต้นและการรันของ dependencies มีระบบการแกะที่แข็งแกร่งมากขึ้น ให้ข้อมูลที่ดีขึ้นเมื่อสอบถามสถานะของ gems และมีความน่าเชื่อถือมากขึ้นเมื่อมีปัญหาเกี่ยวกับการขึ้นต้น dependencies "chicken and egg" เมื่อคุณกำลังเริ่มต้นสิ่งต่าง ๆ ขึ้นมาใหม่ ยังมีการแก้ไขสำหรับใช้คำสั่ง gem ภายใต้ JRuby และสำหรับ dependencies ที่พยายามนำเข้าสำเนาภายนอกของ gems ที่มีอยู่แล้ว

* ผู้มีส่วนร่วมหลัก: [David Dollar](http://www.workingwithrails.com/person/12240-david-dollar)

### การเปลี่ยนแปลง Railties อื่น ๆ

* คำแนะนำสำหรับการอัปเดตเซิร์ฟเวอร์ CI เพื่อสร้าง Rails ได้รับการอัปเดตและขยายขนาด
* การทดสอบภายในของ Rails ได้ถูกเปลี่ยนจาก `Test::Unit::TestCase` เป็น `ActiveSupport::TestCase` และ Rails core ต้องการ Mocha เพื่อทดสอบ
* ไฟล์ `environment.rb` เริ่มต้นได้รับการลดความรก
* สคริปต์ dbconsole ตอนนี้ให้คุณใช้รหัสผ่านที่เป็นตัวเลขเท่านั้นโดยไม่เกิดข้อผิดพลาด
* `Rails.root` ตอนนี้ส่งคืนวัตถุ `Pathname` ซึ่งหมายความว่าคุณสามารถใช้งานกับเมธอด `join` ได้โดยตรงเพื่อ [ทำความสะอาดรหัสที่มีอยู่](https://afreshcup.wordpress.com/2008/12/05/a-little-rails_root-tidiness/) ที่ใช้ `File.join`
* ไฟล์ต่าง ๆ ใน /public ที่เกี่ยวข้องกับการส่งต่อ CGI และ FCGI ไม่ได้ถูกสร้างในแอปพลิเคชัน Rails ทุกตัวโดยค่าเริ่มต้นแล้ว (คุณยังสามารถได้รับมันหากคุณต้องการโดยการเพิ่ม `--with-dispatchers` เมื่อคุณเรียกใช้คำสั่ง `rails` หรือเพิ่มมันในภายหลังด้วย `rake rails:update:generate_dispatchers`)
* Rails Guides ได้ถูกแปลงจาก AsciiDoc เป็น Textile markup
* ได้ทำการทำความสะอาด views และ controllers ที่ถูกสร้างขึ้นโดย scaffold
* สคริปต์ `script/server` ตอนนี้ยอมรับอาร์กิวเมนต์ `--path` เพื่อเชื่อมต่อแอปพลิเคชัน Rails จากเส้นทางที่ระบุ
* หากมี gems ที่กำหนดค่าหายไป งาน rake gem จะข้ามการโหลดส่วนใหญ่ของสภาพแวดล้อม นี่ควรแก้ไขปัญหา "chicken-and-egg" ที่ rake gems:install ไม่สามารถทำงานได้เนื่องจากขาด gems
* Gems ถูกแกะออกมาครั้งเดียว นี้แก้ไขปัญหาเกี่ยวกับ gems (เช่น hoe) ที่ถูกแพ็คด้วยสิทธิ์อ่านอย่างเดียวบนไฟล์

เลิกใช้
----------

มีรหัสเก่าบางส่วนที่ถูกเลิกใช้ในรุ่นนี้:

* หากคุณเป็นหนึ่งในนักพัฒนา Rails (ที่น้อยมาก) ที่ใช้วิธีการติดตั้งที่ขึ้นอยู่กับสคริปต์ inspector, reaper, และ spawner คุณจะต้องรู้ว่าสคริปต์เหล่านั้นไม่ได้รวมอยู่ใน Rails หลักแล้ว หากคุณต้องการใช้งานคุณจะสามารถรับสำเนาผ่านปลั๊กอิน [irs_process_scripts](https://github.com/rails/irs_process_scripts)
* `render_component` จาก "เลิกใช้" เป็น "ไม่มีอยู่" ใน Rails 2.3 หากคุณยังต้องการใช้งานคุณสามารถติดตั้งปลั๊กอิน [render_component plugin](https://github.com/rails/render_component/tree/master)
* ลบการสนับสนุนสำหรับ Rails components
* หากคุณเป็นคนหนึ่งที่เคยใช้ `script/performance/request` เพื่อดูประสิทธิภาพขึ้นอยู่กับการทดสอบการรวมกัน คุณต้องเรียนรู้เทคนิคใหม่: สคริปต์นี้ถูกลบออกจาก Rails หลักแล้ว มีปลั๊กอิน request_profiler ใหม่ที่คุณสามารถติดตั้งเพื่อให้ได้ความสามารถเดียวกันกลับมา
* `ActionController::Base#session_enabled?` เลิกใช้เนื่องจาก sessions ถูกโหลดเก็บเป็นลักษณะขีดสุด
* ตัวเลือก `:digest` และ `:secret` ใน `protect_from_forgery` เลิกใช้และไม่มีผล
* ลบเคล็ดลับการทดสอบการรวมกันบางอย่าง `response.headers["Status"]` และ `headers["Status"]` จะไม่ส่งคืนอะไรเลย Rack ไม่อนุญาตให้มี "Status" ในส่วนหัวการส่งคืน อย่างไรก็ตามคุณยังสามารถใช้เคล็ดลับ `status` และ `status_message` ได้ `response.headers["cookie"]` และ `headers["cookie"]` จะไม่ส่งคืนคุกกี้ CGI ใด ๆ อีกต่อไป คุณสามารถตรวจสอบ `headers["Set-Cookie"]` เพื่อดูส่วนหัวคุกกี้แบบดิบหรือใช้เคล็ดลับ `cookies` เพื่อรับแฮชของคุกกี้ที่ส่งไปยังไคลเอ็นต์
* `formatted_polymorphic_url` เลิกใช้ ใช้ `polymorphic_url` พร้อมกับ `:format` แทน
* ตัวเลือก `:http_only` ใน `ActionController::Response#set_cookie` ถูกเปลี่ยนชื่อเป็น `:httponly`
* ตัวเลือก `:connector` และ `:skip_last_comma` ของ `to_sentence` ถูกแทนที่ด้วยตัวเลือก `:words_connector`, `:two_words_connector`, และ `:last_word_connector`
* การโพสต์ฟอร์ม multipart ด้วยควบคุม `file_field` ที่ว่างเปล่าใช้ส่งสตริงว่างไปยังคอนโทรลเลอร์ ตอนนี้มันจะส่ง nil เนื่องจากความแตกต่างของตัวแยกส่วน multipart ของ Rack และ Rails เก่า
เครดิต

-------

บันทึกการออกแบบโดย [ไมค์ กันเดอร์ลอย](http://afreshcup.com) รุ่นนี้ของบันทึกการออกแบบ Rails 2.3 ถูกสร้างขึ้นโดยใช้ RC2 ของ Rails 2.3 ในการรวบรวม
