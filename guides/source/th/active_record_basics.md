**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b2cb0ab668ead9e8bd48cbd1bcac9b59
พื้นฐานของ Active Record
====================

เอกสารนี้เป็นการแนะนำเกี่ยวกับ Active Record

หลังจากอ่านเอกสารนี้คุณจะรู้:

* Object Relational Mapping และ Active Record คืออะไรและวิธีการใช้งานใน Rails
* วิธีการใช้งาน Active Record models เพื่อจัดการข้อมูลที่เก็บไว้ในฐานข้อมูลที่เกี่ยวข้อง
* กฎเกณฑ์การตั้งชื่อสกุลของ Active Record schema
* แนวคิดของ database migrations, validations, callbacks, และ associations

--------------------------------------------------------------------------------

Active Record คืออะไร?
----------------------

Active Record เป็นส่วนของ [MVC][] - โมเดล - ซึ่งเป็นชั้นของระบบที่รับผิดชอบในการแสดงข้อมูลและตรรกะทางธุรกิจ  Active Record ช่วยให้สามารถสร้างและใช้งานอ็อบเจ็กต์ทางธุรกิจที่ต้องการเก็บข้อมูลไว้ในฐานข้อมูลได้ง่ายขึ้น นี่เป็นการนำเสนอของรูปแบบ Active Record ซึ่งเป็นรายละเอียดของระบบ Object Relational Mapping

### รูปแบบ Active Record

[Active Record ถูกอธิบายโดย Martin Fowler][MFAR] ในหนังสือของเขา _Patterns of Enterprise Application Architecture_ ใน Active Record อ็อบเจ็กต์จะมีข้อมูลที่ต้องการเก็บไว้และพฤติกรรมที่ใช้กับข้อมูลนั้น  Active Record เชื่อว่าการสร้างตรรกะการเข้าถึงข้อมูลเป็นส่วนหนึ่งของอ็อบเจ็กต์จะช่วยให้ผู้ใช้ของอ็อบเจ็กต์นั้นรู้วิธีการเขียนและอ่านข้อมูลจากฐานข้อมูล

### Object Relational Mapping

[Object Relational Mapping][ORM] หรือที่เรียกว่า ORM ในทางทั่วไป เป็นเทคนิคที่เชื่อมต่ออ็อบเจ็กต์ที่มีคุณสมบัติและความสัมพันธ์ในแอปพลิเคชันกับตารางในระบบจัดการฐานข้อมูลที่เกี่ยวข้อง โดยใช้ ORM คุณสมบัติและความสัมพันธ์ของอ็อบเจ็กต์ในแอปพลิเคชันสามารถเก็บและเรียกคืนข้อมูลจากฐานข้อมูลได้ง่ายๆ โดยไม่ต้องเขียนคำสั่ง SQL โดยตรงและมีการเข้าถึงฐานข้อมูลทั้งหมดน้อยลง

หมายเหตุ: ความรู้พื้นฐานเกี่ยวกับระบบจัดการฐานข้อมูลที่เกี่ยวข้อง (RDBMS) และ structured query language (SQL) จะช่วยให้เข้าใจ Active Record ได้อย่างเต็มที่ กรุณาอ้างอิง [บทเรียนนี้][sqlcourse] (หรือ [บทเรียนนี้][rdbmsinfo]) หรือศึกษาจากแหล่งอื่นๆ หากคุณต้องการเรียนรู้เพิ่มเติม

### Active Record เป็นเฟรมเวิร์ค ORM

Active Record ให้เราสิ่งที่สำคัญหลายอย่าง โดยสิ่งที่สำคัญที่สุดคือความสามารถในการ:

* แสดงตัวแบบและข้อมูลของตัวแบบ
* แสดงความสัมพันธ์ระหว่างตัวแบบเหล่านี้
* แสดงลำดับชั้นที่สืบทอดผ่านตัวแบบที่เกี่ยวข้อง
* ตรวจสอบตัวแบบก่อนที่จะเก็บไว้ในฐานข้อมูล
* ดำเนินการฐานข้อมูลในรูปแบบเชิงวัตถุ

การปฏิบัติตามกฎเกณฑ์ของ Active Record
----------------------------------------------

เมื่อเขียนแอปพลิเคชันโดยใช้ภาษาหรือเฟรมเวิร์คอื่นๆ อาจจำเป็นต้องเขียนโค้ดการกำหนดค่ามากมาย สำหรับเฟรมเวิร์ค ORM โดยทั่วไป อย่างไรก็ตาม หากคุณปฏิบัติตามกฎเกณฑ์ที่ Rails นำมาใช้ คุณจะต้องเขียนการกำหนดค่าน้อยมาก (บางกรณีไม่ต้องกำหนดค่าเลย) เมื่อสร้าง Active Record models ความคิดคือหากคุณกำหนดค่าแอปพลิเคชันของคุณในวิธีเดียวกันเป็นปกติเสมอ นี่คือวิธีที่เป็นค่าเริ่มต้น ดังนั้น การกำหนดค่าชัดเจนจะต้องใช้เฉพาะในกรณีที่คุณไม่สามารถปฏิบัติตามกฎเกณฑ์มาตรฐานได้

### กฎเกณฑ์การตั้งชื่อ

โดยค่าเริ่มต้น Active Record ใช้กฎเกณฑ์บางส่วนในการหาวิธีการสร้างการจับคู่ระหว่างตัวแบบและตารางฐานข้อมูล  Rails จะทำการพหล่งชื่อคลาสของคุณเพื่อหาตารางฐานข้อมูลที่เกี่ยวข้อง ดังนั้นสำหรับคลาส `Book` คุณควรมีตารางฐานข้อมูลที่ชื่อว่า **books** กลไกการพหล่งของ Rails เป็นกลไกที่มีประสิทธิภาพมาก สามารถพหล่ง (และเปลี่ยนรูป) คำทั่วไปและคำที่ไม่เป็นไปตามกฎได้ ในกรณีที่ใช้ชื่อคลาสที่ประกอบด้วยคำสองคำหรือมากกว่า ชื่อคลาสต้องเป็นตามแนวคิดของ Ruby โดยใช้รูปแบบ CamelCase ในขณะที่ชื่อตารางต้องใช้รูปแบบ snake_case ตัวอย่าง:
* คลาสโมเดล - เป็นรูปเดียวกับคำแรกของแต่ละคำที่เริ่มต้นด้วยตัวพิมพ์ใหญ่ (เช่น `BookClub`).
* ตารางฐานข้อมูล - เป็นรูปพหูพจน์โดยใช้ขีดล่างคั่นคำ (เช่น `book_clubs`).

| โมเดล / คลาส    | ตาราง / สกีม่า |
| ---------------- | -------------- |
| `Article`        | `articles`     |
| `LineItem`       | `line_items`   |
| `Deer`           | `deers`        |
| `Mouse`          | `mice`         |
| `Person`         | `people`       |

### กฎเกณฑ์สกีม่า

Active Record ใช้กฎเกณฑ์ในการตั้งชื่อคอลัมน์ในตารางฐานข้อมูล
ขึ้นอยู่กับวัตถุประสงค์ของคอลัมน์เหล่านี้

* **คีย์ต่างประเทศ** - ฟิลด์เหล่านี้ควรมีชื่อตามรูปแบบ
  `singularized_table_name_id` (เช่น `item_id`, `order_id`) นี่คือ
  ฟิลด์ที่ Active Record จะค้นหาเมื่อคุณสร้างความสัมพันธ์ระหว่าง
  โมเดลของคุณ
* **คีย์หลัก** - โดยค่าเริ่มต้น Active Record จะใช้คอลัมน์จำนวนเต็มที่ชื่อว่า
  `id` เป็นคีย์หลักของตาราง (`bigint` สำหรับ PostgreSQL และ MySQL, `integer`
  สำหรับ SQLite) เมื่อใช้ [Active Record Migrations](active_record_migrations.html)
  เพื่อสร้างตารางของคุณ คอลัมน์นี้จะถูกสร้างโดยอัตโนมัติ

นอกจากนี้ยังมีชื่อคอลัมน์ทางเลือกบางอย่างที่จะเพิ่มคุณสมบัติเพิ่มเติมให้กับอินสแตนซ์ของ Active Record:

* `created_at` - จะถูกตั้งค่าโดยอัตโนมัติเป็นวันที่และเวลาปัจจุบันเมื่อบันทึกครั้งแรก
* `updated_at` - จะถูกตั้งค่าโดยอัตโนมัติเป็นวันที่และเวลาปัจจุบันเมื่อมีการสร้างหรืออัปเดตบันทึก
* `lock_version` - เพิ่ม [การล็อกแบบมุมมองเชิงโต้ตอบ](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html) ให้กับโมเดล
* `type` - ระบุว่าโมเดลใช้ [การสืบทอดแบบตารางเดียว](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance)
* `(association_name)_type` - เก็บประเภทสำหรับ
  [การสัมพันธ์หลายรูปแบบ](association_basics.html#polymorphic-associations)
* `(table_name)_count` - ใช้ในการแคชจำนวนวัตถุที่เกี่ยวข้องในการสัมพันธ์ เช่น คอลัมน์ `comments_count` ในคลาส `Article` ที่มีหลายอินสแตนซ์ของ `Comment` จะแคชจำนวนความคิดเห็นที่มีอยู่สำหรับแต่ละบทความ

หมายเหตุ: แม้ว่าชื่อคอลัมน์เหล่านี้จะเป็นทางเลือก แต่จริงๆ แล้ว Active Record จองไว้แล้ว อย่าใช้คำสงวนเว้นแต่คุณต้องการฟังก์ชันพิเศษเพิ่มเติม เช่น `type` เป็นคำสงวนที่ใช้ในการระบุตารางที่ใช้การสืบทอดแบบตารางเดียว (STI) หากคุณไม่ได้ใช้ STI ลองใช้คำสงวนที่คล้ายกันเช่น "context" ซึ่งอาจยังอธิบายข้อมูลที่คุณกำลังจัดรูปแบบได้อย่างถูกต้อง

การสร้างโมเดล Active Record
-----------------------------

เมื่อสร้างแอปพลิเคชัน คลาส `ApplicationRecord` จะถูกสร้างขึ้นใน `app/models/application_record.rb` นี่คือคลาสหลักสำหรับโมเดลทั้งหมดในแอปพลิเคชัน และมันเป็นสิ่งที่ทำให้คลาสรูบีเป็นโมเดล Active Record

ในการสร้างโมเดล Active Record ให้สืบทอดคลาส `ApplicationRecord` และคุณก็พร้อมที่จะเริ่มต้น:

```ruby
class Product < ApplicationRecord
end
```

นี้จะสร้างโมเดล `Product` ที่มีการแมปกับตาราง `products` ในฐานข้อมูล โดยการทำเช่นนี้คุณยังสามารถแมปคอลัมน์ของแต่ละแถวในตารางนั้นกับแอตทริบิวต์ของอินสแตนซ์ของโมเดลของคุณได้ สมมติว่าตาราง `products` ถูกสร้างขึ้นโดยใช้คำสั่ง SQL (หรือหนึ่งในส่วนขยายของ SQL) เช่น:

```sql
CREATE TABLE products (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
);
```

สกีม่าข้างต้นประกาศตารางที่มีคอลัมน์สองคอลัมน์: `id` และ `name` แต่ละแถวของตารางนี้แทนสินค้าบางอย่างด้วยพารามิเตอร์สองอย่างเหล่านี้ ดังนั้นคุณจะสามารถเขียนโค้ดเช่นต่อไปนี้:
```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

การแทนที่การตั้งชื่อ
---------------------------------

ถ้าคุณต้องการที่จะปฏิบัติตามการตั้งชื่อที่แตกต่างหรือต้องการใช้แอปพลิเคชัน Rails ของคุณกับฐานข้อมูลที่เก่า ไม่มีปัญหาคุณสามารถแทนที่การตั้งค่าเริ่มต้นได้อย่างง่ายดาย

เนื่องจาก `ApplicationRecord` สืบทอดมาจาก `ActiveRecord::Base` โมเดลของแอปพลิเคชันของคุณจะมีเมธอดที่มีประโยชน์มากมายที่ใช้ได้ ตัวอย่างเช่น คุณสามารถใช้เมธอด `ActiveRecord::Base.table_name=` เพื่อกำหนดชื่อตารางที่ควรใช้:

```ruby
class Product < ApplicationRecord
  self.table_name = "my_products"
end
```

หากคุณทำเช่นนั้น คุณจะต้องกำหนดชื่อคลาสที่เป็นเจ้าภาพของ fixtures (`my_products.yml`) ด้วยเมธอด `set_fixture_class` ในการกำหนดค่าการทดสอบ:

```ruby
# test/models/product_test.rb
class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
  # ...
end
```

คุณยังสามารถแทนที่คอลัมน์ที่ควรใช้เป็น primary key ของตารางได้โดยใช้เมธอด `ActiveRecord::Base.primary_key=`:

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

หมายเหตุ: **Active Record ไม่รองรับการใช้คอลัมน์ที่ไม่ใช่ primary key ที่ชื่อ `id`.**

หมายเหตุ: หากคุณพยายามสร้างคอลัมน์ที่ชื่อ `id` ที่ไม่ใช่ primary key Rails จะโยนข้อผิดพลาดในระหว่างการโยกย้าย เช่น
`you can't redefine the primary key column 'id' on 'my_products'.`
`To define a custom primary key, pass { id: false } to create_table.`

CRUD: การอ่านและเขียนข้อมูล
------------------------------

CRUD เป็นตัวย่อสำหรับสี่คำกริยาที่เราใช้ในการดำเนินการกับข้อมูล: **C**reate,
**R**ead, **U**pdate และ **D**elete  Active Record สร้างเมธอดขึ้นโดยอัตโนมัติเพื่อให้แอปพลิเคชันสามารถอ่านและจัดการข้อมูลที่เก็บอยู่ในตารางได้

### Create

ออบเจ็กต์ Active Record สามารถสร้างขึ้นจากแฮช, บล็อก หรือตั้งค่าแอตทริบิวต์ของมันเองหลังจากการสร้าง การเรียกใช้เมธอด `new` จะสร้างออบเจ็กต์ใหม่ขึ้น ในขณะที่ `create` จะสร้างออบเจ็กต์และบันทึกลงในฐานข้อมูล

ตัวอย่างเช่น กำหนดให้มีโมเดล `User` ที่มีแอตทริบิวต์ชื่อ `name` และ `occupation` เรียกใช้เมธอด `create` จะสร้างและบันทึกบันทึกใหม่ลงในฐานข้อมูล:

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```

โดยใช้เมธอด `new` ออบเจ็กต์สามารถสร้างขึ้นได้โดยไม่ต้องบันทึก:

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

การเรียกใช้ `user.save` จะบันทึกบันทึกลงในฐานข้อมูล

สุดท้าย หากมีบล็อกที่ให้ ทั้ง `create` และ `new` จะส่งคืนออบเจ็กต์ใหม่ให้กับบล็อกเพื่อทำการเริ่มต้น ในขณะที่เฉพาะ `create` เท่านั้นที่จะบันทึกออบเจ็กต์ที่ได้จากนั้นลงในฐานข้อมูล:

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### Read

Active Record ให้ API ที่มีความหลากหลายสำหรับการเข้าถึงข้อมูลภายในฐานข้อมูล ด้านล่างคือตัวอย่างของเมธอดการเข้าถึงข้อมูลที่ต่างกันที่ Active Record ให้

```ruby
# ส่งคืนคอลเลกชันที่มีผู้ใช้ทั้งหมด
users = User.all
```

```ruby
# ส่งคืนผู้ใช้คนแรก
user = User.first
```

```ruby
# ส่งคืนผู้ใช้คนแรกที่ชื่อ David
david = User.find_by(name: 'David')
```

```ruby
# ค้นหาผู้ใช้ทั้งหมดที่ชื่อ David ที่เป็น Code Artist และเรียงลำดับตาม created_at จากมากไปน้อย
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

คุณสามารถเรียนรู้เพิ่มเติมเกี่ยวกับการคิวรีของโมเดล Active Record ในเอกสาร [Active Record Query Interface](active_record_querying.html) 

### การอัปเดต

เมื่อได้รับออบเจ็กต์ Active Record แล้ว คุณสามารถแก้ไขแอตทริบิวต์และบันทึกลงในฐานข้อมูลได้

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

วิธีที่สั้นกว่าคือใช้แฮชแมปแอตทริบิวต์กับค่าที่ต้องการ เช่น

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

วิธีนี้เป็นประโยชน์มากที่สุดเมื่อต้องการอัปเดตหลายแอตทริบิวต์ในครั้งเดียว

หากคุณต้องการอัปเดตบันทึกหลายรายการพร้อมกัน **โดยไม่ใช้ callbacks หรือ validations** คุณสามารถอัปเดตฐานข้อมูลโดยตรงโดยใช้ `update_all`:

```ruby
User.update_all max_login_attempts: 3, must_change_password: true
```

### การลบ

เช่นเดียวกับการเรียกคืน ออบเจ็กต์ Active Record ที่ได้รับ สามารถทำลายได้ซึ่งจะลบออกจากฐานข้อมูล

```ruby
user = User.find_by(name: 'David')
user.destroy
```

หากคุณต้องการลบบันทึกหลายรายการพร้อมกัน คุณสามารถใช้เมธอด `destroy_by` หรือ `destroy_all`:

```ruby
# ค้นหาและลบผู้ใช้ทั้งหมดที่ชื่อ David
User.destroy_by(name: 'David')

# ลบผู้ใช้ทั้งหมด
User.destroy_all
```

การตรวจสอบความถูกต้อง
-----------

Active Record ช่วยให้คุณสามารถตรวจสอบสถานะของโมเดลก่อนที่จะเขียนลงในฐานข้อมูลได้ มีเมธอดหลายรูปแบบที่คุณสามารถใช้เพื่อตรวจสอบโมเดลของคุณและตรวจสอบว่าค่าแอตทริบิวต์ไม่ว่างเปล่า ไม่ซ้ำกับฐานข้อมูลอยู่แล้ว ตามรูปแบบที่กำหนด และอื่น ๆ

เมื่อใช้เมธอด `save` `create` และ `update` จะทำการตรวจสอบโมเดลก่อนที่จะบันทึกลงในฐานข้อมูล หากโมเดลไม่ถูกต้อง เมธอดเหล่านี้จะคืนค่า `false` และไม่มีการดำเนินการใด ๆ กับฐานข้อมูล ทั้งหมดเหล่านี้มีเมธอดแบบแบงค์ (เช่น `save!` `create!` และ `update!`) ซึ่งเข้มงวดกว่าโดยเรียกใช้ข้อยกเว้น `ActiveRecord::RecordInvalid` เมื่อการตรวจสอบล้มเหลว ตัวอย่างอย่างรวดเร็วเพื่อแสดง:

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> user = User.new
irb> user.save
=> false
irb> user.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

คุณสามารถเรียนรู้เพิ่มเติมเกี่ยวกับการตรวจสอบความถูกต้องในเอกสาร [Active Record Validations
guide](active_record_validations.html).

Callbacks
---------

Callback ใน Active Record ช่วยให้คุณสามารถเชื่อมโยงโค้ดกับเหตุการณ์บางอย่างในไลฟ์เซิลของโมเดลของคุณ สิ่งนี้ช่วยให้คุณเพิ่มพฤติกรรมให้กับโมเดลของคุณโดยการทำงานโดย透明เมื่อเหตุการณ์เหล่านั้นเกิดขึ้น เช่นเมื่อคุณสร้างบันทึกใหม่ อัปเดต ทำลาย และอื่น ๆ

```ruby
class User < ApplicationRecord
  after_create :log_new_user

  private
    def log_new_user
      puts "A new user was registered"
    end
end
```

```irb
irb> @user = User.create
A new user was registered
```

คุณสามารถเรียนรู้เพิ่มเติมเกี่ยวกับ Callback ในเอกสาร [Active Record Callbacks
guide](active_record_callbacks.html).

การเปลี่ยนแปลงโครงสร้างของฐานข้อมูล
----------

Rails มีวิธีที่สะดวกในการจัดการการเปลี่ยนแปลงโครงสร้างของฐานข้อมูลผ่านการเรียกใช้งาน การเปลี่ยนแปลงถูกเขียนในภาษาที่เฉพาะเจาะจงและเก็บไว้ในไฟล์ที่ดำเนินการกับฐานข้อมูลที่ Active Record รองรับ

นี่คือการเปลี่ยนแปลงที่สร้างตารางใหม่ที่ชื่อ `publications`:

```ruby
class CreatePublications < ActiveRecord::Migration[7.1]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.references :publisher, polymorphic: true
      t.boolean :single_issue

      t.timestamps
    end
  end
end
```

โปรดทราบว่าโค้ดด้านบนเป็นระบบที่ไม่ขึ้นกับฐานข้อมูล: มันจะทำงานใน MySQL PostgreSQL SQLite และอื่น ๆ
Rails จะเก็บบันทึกว่ามีการทำการอัปเดตใดๆ ที่ถูกบันทึกลงในฐานข้อมูลและจัดเก็บไว้ในตารางที่อยู่ในฐานข้อมูลเดียวกันที่ชื่อว่า `schema_migrations` 

ในการรันการอัปเดตและสร้างตาราง คุณสามารถรันคำสั่ง `bin/rails db:migrate` และในการย้อนกลับและลบตาราง คุณสามารถรันคำสั่ง `bin/rails db:rollback`

คุณสามารถเรียนรู้เพิ่มเติมเกี่ยวกับการอัปเดตในเอกสาร [Active Record Migrations guide](active_record_migrations.html)

การเชื่อมโยง
------------

การเชื่อมโยงใน Active Record ช่วยให้คุณสามารถกำหนดความสัมพันธ์ระหว่างโมเดลได้
การเชื่อมโยงสามารถใช้เพื่ออธิบายความสัมพันธ์หนึ่งต่อหนึ่ง หนึ่งต่อหลาย และหลายต่อหลาย
ตัวอย่างเช่น ความสัมพันธ์ "ผู้เขียนมีหนังสือหลายเล่ม" สามารถกำหนดได้ดังนี้:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

คลาส Author ตอนนี้มีเมธอดที่ใช้ในการเพิ่มและลบหนังสือของผู้เขียน และอื่นๆ อีกมากมาย

คุณสามารถเรียนรู้เพิ่มเติมเกี่ยวกับการเชื่อมโยงในเอกสาร [Active Record Associations guide](association_basics.html)
[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[MFAR]: https://www.martinfowler.com/eaaCatalog/activeRecord.html
[ORM]: https://en.wikipedia.org/wiki/Object-relational_mapping
[sqlcourse]: https://www.khanacademy.org/computing/computer-programming/sql
[rdbmsinfo]: https://www.devart.com/what-is-rdbms/
