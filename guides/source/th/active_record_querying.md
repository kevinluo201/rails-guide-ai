**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cc70f06da31561d3461720649cc42371
อินเตอร์เฟซการค้นหา Active Record
=============================

เอกสารนี้เป็นคู่มือเกี่ยวกับวิธีการเรียกดูข้อมูลจากฐานข้อมูลโดยใช้ Active Record

หลังจากอ่านคู่มือนี้คุณจะรู้:

* วิธีการค้นหาเร็คคอร์ดโดยใช้วิธีและเงื่อนไขต่าง ๆ
* วิธีการระบุลำดับ แอตทริบิวต์ที่ได้รับ การจัดกลุ่ม และคุณสมบัติอื่น ๆ ของเร็คคอร์ดที่พบ
* วิธีการใช้ eager loading เพื่อลดจำนวนคำสั่งคิวรีฐานข้อมูลที่ต้องใช้สำหรับการเรียกดูข้อมูล
* วิธีการใช้เมธอด dynamic finder
* วิธีการใช้ method chaining เพื่อใช้เมธอด Active Record หลาย ๆ ตัวร่วมกัน
* วิธีการตรวจสอบว่ามีเร็คคอร์ดบางรายการหรือไม่
* วิธีการทำการคำนวณต่าง ๆ บนโมเดล Active Record
* วิธีการเรียกใช้ EXPLAIN บนความสัมพันธ์

--------------------------------------------------------------------------------

อินเตอร์เฟซการค้นหา Active Record คืออะไร?
------------------------------------------

หากคุณเคยใช้ SQL สดเพื่อค้นหาเร็คคอร์ดในฐานข้อมูล คุณจะพบว่ามีวิธีที่ดีกว่าในการดำเนินการเดียวกันใน Rails  Active Record ช่วยให้คุณไม่ต้องใช้ SQL ในกรณีส่วนใหญ่

Active Record จะดำเนินการคิวรีในฐานข้อมูลให้แทนคุณและเข้ากันได้กับระบบฐานข้อมูลส่วนใหญ่รวมถึง MySQL, MariaDB, PostgreSQL, และ SQLite ไม่ว่าคุณจะใช้ระบบฐานข้อมูลใด Active Record จะมีรูปแบบเมธอดเดียวกันเสมอ

ตัวอย่างโค้ดที่ใช้ในคู่มือนี้จะอ้างอิงถึงโมเดลต่อไปนี้หนึ่งหรือมากกว่านี้:

เคล็ดลับ: โมเดลทั้งหมดต่อไปนี้ใช้ `id` เป็น primary key ยกเว้นระบุไว้อย่างอื่น

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

```ruby
class Book < ApplicationRecord
  belongs_to :supplier
  belongs_to :author
  has_many :reviews
  has_and_belongs_to_many :orders, join_table: 'books_orders'

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
  scope :out_of_print_and_expensive, -> { out_of_print.where('price > 500') }
  scope :costs_more_than, ->(amount) { where('price > ?', amount) }
end
```

```ruby
class Customer < ApplicationRecord
  has_many :orders
  has_many :reviews
end
```

```ruby
class Order < ApplicationRecord
  belongs_to :customer
  has_and_belongs_to_many :books, join_table: 'books_orders'

  enum :status, [:shipped, :being_packed, :complete, :cancelled]

  scope :created_before, ->(time) { where(created_at: ...time) }
end
```

```ruby
class Review < ApplicationRecord
  belongs_to :customer
  belongs_to :book

  enum :state, [:not_reviewed, :published, :hidden]
end
```

```ruby
class Supplier < ApplicationRecord
  has_many :books
  has_many :authors, through: :books
end
```

![แผนภาพของโมเดลร้านหนังสือทั้งหมด](images/active_record_querying/bookstore_models.png)

การเรียกดูวัตถุจากฐานข้อมูล
------------------------------------

เพื่อเรียกดูวัตถุจากฐานข้อมูล Active Record ให้ใช้เมธอด finder หลาย ๆ วิธี แต่ละเมธอดให้คุณส่งอาร์กิวเมนต์เข้าไปเพื่อดำเนินการคิวรีบางอย่างในฐานข้อมูลของคุณโดยไม่ต้องเขียน SQL สด

เมธอดที่ใช้ได้คือ:

* [`annotate`][]
* [`find`][]
* [`create_with`][]
* [`distinct`][]
* [`eager_load`][]
* [`extending`][]
* [`extract_associated`][]
* [`from`][]
* [`group`][]
* [`having`][]
* [`includes`][]
* [`joins`][]
* [`left_outer_joins`][]
* [`limit`][]
* [`lock`][]
* [`none`][]
* [`offset`][]
* [`optimizer_hints`][]
* [`order`][]
* [`preload`][]
* [`readonly`][]
* [`references`][]
* [`reorder`][]
* [`reselect`][]
* [`regroup`][]
* [`reverse_order`][]
* [`select`][]
* [`where`][]

เมธอด finder ที่ส่งคืนคอลเลกชัน เช่น `where` และ `group` จะส่งคืนอินสแตนซ์ของ [`ActiveRecord::Relation`][] เมธอดที่ค้นหาเอกสารเดียว เช่น `find` และ `first` จะส่งคืนอินสแตนซ์เดียวของโมเดล 1 รายการ
การดำเนินการหลักของ `Model.find(options)` สามารถสรุปได้ว่า:

* แปลงตัวเลือกที่ระบุให้เป็นคำสั่ง SQL ที่เทียบเท่ากัน
* ส่งคำสั่ง SQL และเรียกข้อมูลที่เกี่ยวข้องจากฐานข้อมูล
* สร้างอ็อบเจ็กต์ Ruby ที่เทียบเท่ากับโมเดลที่เหมาะสมสำหรับแต่ละแถวที่ได้รับ
* รัน `after_find` แล้ว `after_initialize` callbacks ถ้ามี

### การเรียกข้อมูลวัตถุเดียว

Active Record มีวิธีการเรียกข้อมูลวัตถุเดียวหลายวิธี

#### `find`

โดยใช้เมธอด [`find`][] คุณสามารถเรียกข้อมูลวัตถุที่สอดคล้องกับ _primary key_ ที่ระบุที่ตรงกันกับตัวเลือกที่ระบุได้ ตัวอย่างเช่น:

```irb
# ค้นหาลูกค้าที่มี primary key (id) เป็น 10
irb> customer = Customer.find(10)
=> #<Customer id: 10, first_name: "Ryan">
```

คำสั่ง SQL เทียบเท่ากับข้างต้นคือ:

```sql
SELECT * FROM customers WHERE (customers.id = 10) LIMIT 1
```

เมื่อไม่พบบันทึกที่ตรงกัน  `find` จะเรียกใช้ข้อยกเว้น `ActiveRecord::RecordNotFound`

คุณยังสามารถใช้เมธอดนี้เพื่อค้นหาวัตถุหลายๆ วัตถุ โดยเรียกใช้เมธอด `find` และส่งอาร์เรย์ของ primary keys เข้าไป ผลลัพธ์ที่ได้จะเป็นอาร์เรย์ที่มีข้อมูลที่ตรงกันทั้งหมดสำหรับ _primary keys_ ที่ระบุ เช่น:

```irb
# ค้นหาลูกค้าที่มี primary keys เป็น 1 และ 10
irb> customers = Customer.find([1, 10]) # หรือ Customer.find(1, 10)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 10, first_name: "Ryan">]
```

คำสั่ง SQL เทียบเท่ากับข้างต้นคือ:

```sql
SELECT * FROM customers WHERE (customers.id IN (1,10))
```

คำเตือน: เมื่อไม่พบบันทึกที่ตรงกัน `find` จะเรียกใช้ข้อยกเว้น `ActiveRecord::RecordNotFound` ยกเว้นว่าจะพบบันทึกที่ตรงกันสำหรับ **ทุก** primary keys ที่ระบุ

#### `take`

เมธอด [`take`][] จะเรียกข้อมูลบันทึกโดยไม่มีการจัดเรียงแบบอัตโนมัติ ตัวอย่างเช่น:

```irb
irb> customer = Customer.take
=> #<Customer id: 1, first_name: "Lifo">
```

คำสั่ง SQL เทียบเท่ากับข้างต้นคือ:

```sql
SELECT * FROM customers LIMIT 1
```

เมื่อไม่พบบันทึก  `take` จะส่งค่า `nil` และไม่เกิดข้อยกเว้น

คุณสามารถส่งอาร์กิวเมนต์ตัวเลขให้กับเมธอด `take` เพื่อคืนค่าผลลัพธ์ของจำนวนที่กำหนด ตัวอย่างเช่น

```irb
irb> customers = Customer.take(2)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 220, first_name: "Sara">]
```

คำสั่ง SQL เทียบเท่ากับข้างต้นคือ:

```sql
SELECT * FROM customers LIMIT 2
```

เมธอด [`take!`][] ทำงานเหมือนกับ `take` แต่จะเรียกใช้ `ActiveRecord::RecordNotFound` ถ้าไม่พบบันทึกที่ตรงกัน

เคล็ดลับ: บันทึกที่ได้รับอาจแตกต่างกันไปขึ้นอยู่กับเครื่องมือฐานข้อมูล

#### `first`

เมธอด [`first`][] จะค้นหาบันทึกแรกตามลำดับของ primary key (ค่าเริ่มต้น) ตัวอย่างเช่น:

```irb
irb> customer = Customer.first
=> #<Customer id: 1, first_name: "Lifo">
```

คำสั่ง SQL เทียบเท่ากับข้างต้นคือ:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 1
```

เมื่อไม่พบบันทึกที่ตรงกัน `first` จะส่งค่า `nil` และไม่เกิดข้อยกเว้น

หาก [default scope](active_record_querying.html#applying-a-default-scope) ของคุณมีเมธอดการจัดเรียง `first` จะคืนค่าบันทึกแรกตามลำดับนี้

คุณสามารถส่งอาร์กิวเมนต์ตัวเลขให้กับเมธอด `first` เพื่อคืนค่าผลลัพธ์ของจำนวนที่กำหนด ตัวอย่างเช่น
```irb
irb> customers = Customer.first(3)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 2, first_name: "Fifo">, #<Customer id: 3, first_name: "Filo">]
```

SQL ที่เทียบเท่ากับข้างต้นคือ:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 3
```

บนคอลเลกชันที่เรียงลำดับโดยใช้ `order`, `first` จะคืนค่าเร็คคอร์ดแรกที่เรียงลำดับตามแอตทริบิวต์ที่ระบุสำหรับ `order`.

```irb
irb> customer = Customer.order(:first_name).first
=> #<Customer id: 2, first_name: "Fifo">
```

SQL ที่เทียบเท่ากับข้างต้นคือ:

```sql
SELECT * FROM customers ORDER BY customers.first_name ASC LIMIT 1
```

เมธอด [`first!`][] จะทำงานเหมือนกับ `first`, แต่ถ้าไม่พบเรคคอร์ดที่ตรงกันจะเกิดข้อผิดพลาด `ActiveRecord::RecordNotFound`


#### `last`

เมธอด [`last`][] จะค้นหาเรคคอร์ดสุดท้ายที่เรียงลำดับตามคีย์หลัก (ค่าเริ่มต้น) ตัวอย่างเช่น:

```irb
irb> customer = Customer.last
=> #<Customer id: 221, first_name: "Russel">
```

SQL ที่เทียบเท่ากับข้างต้นคือ:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 1
```

เมธอด `last` จะคืนค่า `nil` ถ้าไม่พบเรคคอร์ดที่ตรงกันและไม่เกิดข้อผิดพลาด

หาก [default scope](active_record_querying.html#applying-a-default-scope) ของคุณมีเมธอด order, `last` จะคืนค่าเรคคอร์ดสุดท้ายตามการเรียงลำดับนี้

คุณสามารถส่งอาร์กิวเมนต์ตัวเลขให้กับเมธอด `last` เพื่อคืนค่าผลลัพธ์ได้สูงสุดตามจำนวนนั้น ตัวอย่างเช่น

```irb
irb> customers = Customer.last(3)
=> [#<Customer id: 219, first_name: "James">, #<Customer id: 220, first_name: "Sara">, #<Customer id: 221, first_name: "Russel">]
```

SQL ที่เทียบเท่ากับข้างต้นคือ:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 3
```

บนคอลเลกชันที่เรียงลำดับโดยใช้ `order`, `last` จะคืนค่าเรคคอร์ดสุดท้ายที่เรียงลำดับตามแอตทริบิวต์ที่ระบุสำหรับ `order`.

```irb
irb> customer = Customer.order(:first_name).last
=> #<Customer id: 220, first_name: "Sara">
```

SQL ที่เทียบเท่ากับข้างต้นคือ:

```sql
SELECT * FROM customers ORDER BY customers.first_name DESC LIMIT 1
```

เมธอด [`last!`][] จะทำงานเหมือนกับ `last`, แต่ถ้าไม่พบเรคคอร์ดที่ตรงกันจะเกิดข้อผิดพลาด `ActiveRecord::RecordNotFound`


#### `find_by`

เมธอด [`find_by`][] จะค้นหาเรคคอร์ดแรกที่ตรงกับเงื่อนไขบางอย่าง ตัวอย่างเช่น:

```irb
irb> Customer.find_by first_name: 'Lifo'
=> #<Customer id: 1, first_name: "Lifo">

irb> Customer.find_by first_name: 'Jon'
=> nil
```

เทียบเท่ากับการเขียน:

```ruby
Customer.where(first_name: 'Lifo').take
```

SQL ที่เทียบเท่ากับข้างต้นคือ:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Lifo') LIMIT 1
```

โปรดทราบว่าไม่มี `ORDER BY` ใน SQL ข้างต้น หากเงื่อนไขของคุณสามารถตรงกับเรคคอร์ดหลายรายการคุณควร [ใช้การเรียงลำดับ](#ordering) เพื่อรับผลลัพธ์ที่แน่นอน

เมธอด [`find_by!`][] จะทำงานเหมือนกับ `find_by`, แต่ถ้าไม่พบเรคคอร์ดที่ตรงกันจะเกิดข้อผิดพลาด `ActiveRecord::RecordNotFound` ตัวอย่างเช่น:

```irb
irb> Customer.find_by! first_name: 'does not exist'
ActiveRecord::RecordNotFound
```

เทียบเท่ากับการเขียน:

```ruby
Customer.where(first_name: 'does not exist').take!
```


### การเรียกข้อมูลหลายๆ รายการในชุด

เราบ่งชี้ถึงการทำงานกับชุดข้อมูลที่มีข้อมูลจำนวนมาก เช่นเมื่อเราส่งจดหมายข่าวไปยังกลุ่มลูกค้าจำนวนมาก หรือเมื่อเราส่งออกข้อมูล

การทำนี้อาจดูเป็นเรื่องง่าย:

```ruby
# นี้อาจใช้หน่วยความจำมากเกินไปหากตารางมีข้อมูลมาก
Customer.all.each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

แต่วิธีนี้กลายเป็นไม่ค่อยเป็นไปตามความเป็นจริงเมื่อขนาดของตารางเพิ่มขึ้น เนื่องจาก `Customer.all.each` สั่งให้ Active Record ดึงข้อมูล _ทั้งตาราง_ ในครั้งเดียว สร้างออบเจ็กต์โมเดลต่อแถว และเก็บอาร์เรย์ของออบเจ็กต์โมเดลทั้งหมดในหน่วยความจำ ในความเป็นจริง หากเรามีจำนวนเรคคอร์ดมาก คอลเลกชันทั้งหมดอาจเกินจำนวนหน่วยความจำที่มีอยู่

Rails มีวิธีการสองวิธีที่จัดการกับปัญหานี้โดยแบ่งรายการเป็นชุดข้อมูลที่เหมาะสมกับหน่วยความจำสำหรับการประมวลผล วิธีแรกคือ `find_each` ซึ่งดึงรายการเป็นชุดแล้วส่งคืน _แต่ละ_ รายการให้กับบล็อกเป็นโมเดล วิธีที่สองคือ `find_in_batches` ซึ่งดึงรายการเป็นชุดแล้วส่งคืน _ชุดทั้งหมด_ ให้กับบล็อกเป็นอาร์เรย์ของโมเดล

เคล็ดลับ: วิธี `find_each` และ `find_in_batches` ถูกออกแบบมาสำหรับใช้ในการประมวลผลชุดข้อมูลจำนวนมากที่ไม่สามารถเก็บไว้ในหน่วยความจำทั้งหมดได้ในครั้งเดียว หากคุณต้องการเพียงแค่วนซ้ำข้อมูลพันรายการ วิธีการค้นหาปกติเป็นตัวเลือกที่แนะนำ

#### `find_each`

วิธี [`find_each`][] ดึงรายการเป็นชุดแล้วส่งคืน _แต่ละ_ รายการให้กับบล็อก ในตัวอย่างต่อไปนี้ `find_each` ดึงลูกค้าเป็นชุดของ 1000 และส่งคืนให้กับบล็อกทีละรายการ:

```ruby
Customer.find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

กระบวนการนี้จะทำซ้ำ ดึงชุดเพิ่มเมื่อจำเป็น จนกว่ารายการทั้งหมดจะถูกประมวลผลเสร็จสิ้น

`find_each` ทำงานกับคลาสโมเดลเช่นที่เห็นข้างต้น และก็ทำงานกับความสัมพันธ์:

```ruby
Customer.where(weekly_subscriber: true).find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

เพียงแต่ต้องไม่มีการจัดเรียง เนื่องจากวิธีนี้ต้องบังคับการจัดเรียงภายในเพื่อทำการวนซ้ำ

หากมีการจัดเรียงในผู้รับ พฤติกรรมขึ้นอยู่กับฟล็อก [`config.active_record.error_on_ignored_order`][] หากเป็นจริง จะเกิด `ArgumentError` หากไม่เป็นจริง การจัดเรียงจะถูกละเว้นและแจ้งเตือน ซึ่งเป็นค่าเริ่มต้น สามารถเปลี่ยนแปลงได้ด้วยตัวเลือก `:error_on_ignore` ที่อธิบายด้านล่าง

##### ตัวเลือกสำหรับ `find_each`

**`:batch_size`**

ตัวเลือก `:batch_size` ช่วยให้คุณระบุจำนวนรายการที่จะดึงในแต่ละชุดก่อนส่งให้บล็อกทีละรายการ ตัวอย่างเช่น เพื่อดึงรายการเป็นชุดของ 5000:

```ruby
Customer.find_each(batch_size: 5000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:start`**

ตามค่าเริ่มต้น รายการจะถูกดึงตามลำดับของคีย์หลักที่เพิ่มขึ้น ตัวเลือก `:start` ช่วยให้คุณกำหนดค่า ID แรกของลำดับเมื่อ ID ต่ำสุดไม่ใช่ค่าที่คุณต้องการ นี่จะเป็นประโยชน์เมื่อคุณต้องการที่จะดำเนินกระบวนการชุดที่ถูกตัดสินใจ หากคุณบันทึก ID ที่ประมวลผลล่าสุดเป็นจุดตรวจสอบ

ตัวอย่างเช่น เพื่อส่งจดหมายข่าวไปยังลูกค้าที่มี primary key เริ่มต้นที่ 2000 เท่านั้น:

```ruby
Customer.find_each(start: 2000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:finish`**

คล้ายกับตัวเลือก `:start` `:finish` ช่วยให้คุณกำหนดค่า ID สุดท้ายของลำดับเมื่อ ID สูงสุดไม่ใช่ค่าที่คุณต้องการ
นี่จะเป็นประโยชน์เมื่อคุณต้องการเรียกใช้กระบวนการชุดโดยใช้เซตรายการที่ขึ้นอยู่กับ `:start` และ `:finish`

ตัวอย่างเช่น เพื่อส่งจดหมายข่าวไปยังลูกค้าที่มี primary key เริ่มต้นที่ 2000 ถึง 10000:
```ruby
Customer.find_each(start: 2000, finish: 10000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

ตัวอย่างอื่น ๆ คือหากคุณต้องการให้มี worker หลายคนที่จัดการคิวการประมวลผลเดียวกัน คุณสามารถตั้งค่า `:start` และ `:finish` ที่เหมาะสมบนแต่ละ worker เพื่อให้แต่ละ worker จัดการกับรายการ 10000 รายการ

**`:error_on_ignore`**

เขียนทับการกำหนดค่าแอปพลิเคชันเพื่อระบุว่าควรเกิดข้อผิดพลาดเมื่อมีคำสั่งในความสัมพันธ์

**`:order`**

ระบุลำดับคีย์หลัก (สามารถเป็น `:asc` หรือ `:desc` ได้) ค่าเริ่มต้นคือ `:asc`

```ruby
Customer.find_each(order: :desc) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

#### `find_in_batches`

เมธอด [`find_in_batches`][] คล้ายกับ `find_each` เนื่องจากทั้งสองเมธอดนี้ดึงรายการเป็นกลุ่ม แต่ความแตกต่างคือ `find_in_batches` จะส่งกลับให้บล็อกที่กำหนดเป็นอาร์เรย์ของโมเดล แทนที่จะส่งกลับเป็นรายการแต่ละรายการ ตัวอย่างต่อไปนี้จะส่งกลับให้บล็อกที่กำหนดอาร์เรย์ของลูกค้าสูงสุด 1000 รายการในแต่ละครั้ง และบล็อกสุดท้ายจะมีลูกค้าที่เหลืออยู่:

```ruby
# ส่ง add_customers อาร์เรย์ของลูกค้า 1000 รายการในแต่ละครั้ง
Customer.find_in_batches do |customers|
  export.add_customers(customers)
end
```

`find_in_batches` ทำงานกับคลาสโมเดลเช่นที่เห็นข้างต้น และยังทำงานกับความสัมพันธ์:

```ruby
# ส่ง add_customers อาร์เรย์ของลูกค้าที่ใช้บริการล่าสุด 1000 รายการในแต่ละครั้ง
Customer.recently_active.find_in_batches do |customers|
  export.add_customers(customers)
end
```

เพียงแต่ต้องไม่มีการจัดเรียง เนื่องจากเมธอดจำเป็นต้องบังคับใช้การจัดเรียงภายในการทำซ้ำ

##### ตัวเลือกสำหรับ `find_in_batches`

เมธอด `find_in_batches` ยอมรับตัวเลือกเดียวกับ `find_each`:

**`:batch_size`**

เหมือนกับ `find_each` `batch_size` กำหนดจำนวนรายการที่จะดึงในแต่ละกลุ่ม เช่น การดึงรายการ 2500 รายการสามารถระบุได้ดังนี้:

```ruby
Customer.find_in_batches(batch_size: 2500) do |customers|
  export.add_customers(customers)
end
```

**`:start`**

ตัวเลือก `start` ช่วยในการระบุ ID เริ่มต้นที่รายการจะถูกเลือก ตามที่กล่าวไว้ก่อนหน้านี้ โดยค่าเริ่มต้นคือการดึงรายการตามลำดับของคีย์หลัก ตัวอย่างเช่น การดึงลูกค้าที่เริ่มต้นด้วย ID: 5000 ในกลุ่มของรายการ 2500 รายการ สามารถใช้โค้ดต่อไปนี้:

```ruby
Customer.find_in_batches(batch_size: 2500, start: 5000) do |customers|
  export.add_customers(customers)
end
```

**`:finish`**

ตัวเลือก `finish` ช่วยในการระบุ ID สิ้นสุดของรายการที่จะดึง โค้ดด้านล่างแสดงตัวอย่างการดึงลูกค้าเป็นกลุ่มโดยถึงลูกค้าที่มี ID: 7000:

```ruby
Customer.find_in_batches(finish: 7000) do |customers|
  export.add_customers(customers)
end
```

**`:error_on_ignore`**

ตัวเลือก `error_on_ignore` เขียนทับการกำหนดค่าแอปพลิเคชันเพื่อระบุว่าควรเกิดข้อผิดพลาดเมื่อมีคำสั่งในความสัมพันธ์

เงื่อนไข
----------

เมธอด [`where`][] ช่วยให้คุณระบุเงื่อนไขเพื่อจำกัดรายการที่ส่งกลับ แทนส่วน `WHERE` ของคำสั่ง SQL เงื่อนไขสามารถระบุได้เป็นสตริง อาร์เรย์ หรือแฮช

### เงื่อนไขเป็นสตริงเท่านั้น

หากคุณต้องการเพิ่มเงื่อนไขในการค้นหาคุณสามารถระบุได้ในนั้นเช่นเดียวกับ `Book.where("title = 'Introduction to Algorithms'")` นี้จะค้นหาหนังสือทั้งหมดที่มีค่าฟิลด์ `title` เป็น 'Introduction to Algorithms'

คำเตือน: การสร้างเงื่อนไขด้วยสตริงเปล่า ๆ อาจทำให้คุณเป็นเป้าหมายของการโจมตี SQL injection ตัวอย่างเช่น `Book.where("title LIKE '%#{params[:title]}%'")` ไม่ปลอดภัย โปรดดูส่วนถัดไปสำหรับวิธีการจัดการเงื่อนไขโดยใช้อาร์เรย์

### เงื่อนไขเป็นอาร์เรย์
ถ้าหัวข้อนั้นสามารถเปลี่ยนแปลงได้ ตัวอย่างเช่นเป็นอาร์กิวเมนต์จากที่ไหนก็ได้ การค้นหาจะมีรูปแบบดังนี้:

```ruby
Book.where("title = ?", params[:title])
```

Active Record จะใช้อาร์กิวเมนต์แรกเป็นสตริงเงื่อนไขและอาร์กิวเมนต์เพิ่มเติมจะแทนที่เครื่องหมายคำถาม `(?)` ในสตริงเงื่อนไข

หากคุณต้องการระบุเงื่อนไขหลายอย่าง:

```ruby
Book.where("title = ? AND out_of_print = ?", params[:title], false)
```

ในตัวอย่างนี้ เครื่องหมายคำถามแรกจะถูกแทนที่ด้วยค่าใน `params[:title]` และเครื่องหมายคำถามที่สองจะถูกแทนที่ด้วย SQL representation ของ `false` ซึ่งขึ้นอยู่กับ adapter

โค้ดนี้เป็นที่ชื่นชอบมาก:

```ruby
Book.where("title = ?", params[:title])
```

กว่าโค้ดนี้:

```ruby
Book.where("title = #{params[:title]}")
```

เพราะความปลอดภัยของอาร์กิวเมนต์ การใส่ตัวแปรโดยตรงลงในสตริงเงื่อนไขจะส่งตัวแปรไปยังฐานข้อมูล **ตามที่เป็น** นั่นหมายความว่ามันจะเป็นตัวแปรที่ไม่ได้รับการหลีกเลี่ยงโดยตรงจากผู้ใช้ที่อาจมีเจตนาที่ไม่ดี หากคุณทำเช่นนี้ คุณกำลังเสี่ยงทั้งฐานข้อมูลของคุณเพราะเมื่อผู้ใช้ค้นพบว่าพวกเขาสามารถใช้ประโยชน์จากฐานข้อมูลของคุณได้พวกเขาสามารถทำอะไรก็ได้กับมัน อย่าเคลื่อนไหวใด ๆ ใส่อาร์กิวเมนต์ของคุณโดยตรงในสตริงเงื่อนไข

เคล็ดลับ: สำหรับข้อมูลเพิ่มเติมเกี่ยวกับอันตรายของ SQL injection ดูที่ [Ruby on Rails Security Guide](security.html#sql-injection)

#### เงื่อนไขแบบ Placeholder

คล้ายกับการแทนที่ `(?)` ของ params คุณยังสามารถระบุคีย์ในสตริงเงื่อนไขพร้อมกับคีย์ / ค่าที่เกี่ยวข้อง:

```ruby
Book.where("created_at >= :start_date AND created_at <= :end_date",
  { start_date: params[:start_date], end_date: params[:end_date] })
```

นี้ทำให้การอ่านที่ชัดเจนขึ้นหากคุณมีจำนวนเงื่อนไขที่หลากหลาย

#### เงื่อนไขที่ใช้ `LIKE`

แม้ว่าอาร์กิวเมนต์เงื่อนไขจะถูกหลีกเลี่ยงโดยอัตโนมัติเพื่อป้องกันการฉีด SQL แต่ SQL `LIKE` wildcards (เช่น `%` และ `_`) จะไม่ถูกหลีกเลี่ยง สิ่งนี้อาจทำให้เกิดปัญหาที่ไม่คาดคิดหากใช้ค่าที่ไม่ได้รับการตรวจสอบในอาร์กิวเมนต์ เช่น:

```ruby
Book.where("title LIKE ?", params[:title] + "%")
```

ในโค้ดข้างต้น จุดประสงค์คือการจับคู่กับชื่อหนังสือที่เริ่มต้นด้วยสตริงที่ผู้ใช้ระบุ อย่างไรก็ตาม การเกิดขึ้นของ `%` หรือ `_` ใน `params[:title]` จะถูกจัดการเป็น wildcards ซึ่งอาจทำให้ผลลัพธ์ของคิวรีไม่คาดคิด ในบางกรณีนี้อาจยังป้องกันฐานข้อมูลไม่ใช้ดัชนีที่ตั้งใจไว้ ซึ่งทำให้คิวรีช้ามากขึ้น

เพื่อหลีกเลี่ยงปัญหาเหล่านี้ ใช้ [`sanitize_sql_like`][] เพื่อหลีกเลี่ยงตัวอักษร wildcards ในส่วนที่เกี่ยวข้องของอาร์กิวเมนต์:

```ruby
Book.where("title LIKE ?",
  Book.sanitize_sql_like(params[:title]) + "%")
```

### เงื่อนไขแบบแฮช

Active Record ยังช่วยให้คุณสามารถส่งเงื่อนไขแบบแฮชเพื่อเพิ่มความอ่านง่ายในไวยากรณ์ของเงื่อนไขของคุณ ด้วยเงื่อนไขแบบแฮชคุณส่งเงื่อนไขแบบแฮชที่มีคีย์ของฟิลด์ที่คุณต้องการระบุและค่าของวิธีที่คุณต้องการระบุ:

หมายเหตุ: เงื่อนไขแบบแฮชสามารถใช้เฉพาะเงื่อนไขเท่ากัน เช่น เงื่อนไขเท่ากัน เงื่อนไขช่วง เช็คสับเซ็ต

#### เงื่อนไขเท่ากัน

```ruby
Book.where(out_of_print: true)
```

นี้จะสร้าง SQL เช่นนี้:

```sql
SELECT * FROM books WHERE (books.out_of_print = 1)
```

ชื่อฟิลด์ยังสามารถเป็นสตริงได้:

```ruby
Book.where('out_of_print' => true)
```

ในกรณีของความสัมพันธ์ belongs_to คีย์ของการเชื่อมโยงสามารถใช้ระบุโมเดลหากใช้วัตถุ Active Record เป็นค่า วิธีนี้ยังสามารถทำงานได้กับความสัมพันธ์หลายรูปแบบ
```ruby
author = Author.first
Book.where(author: author)
Author.joins(:books).where(books: { author: author })
```

#### เงื่อนไขช่วง

```ruby
Book.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
```

นี้จะค้นหาหนังสือทั้งหมดที่สร้างเมื่อวานนี้โดยใช้คำสั่ง SQL `BETWEEN`:

```sql
SELECT * FROM books WHERE (books.created_at BETWEEN '2008-12-21 00:00:00' AND '2008-12-22 00:00:00')
```

นี้เป็นตัวอย่างสั้นกว่าสำหรับตัวอย่างใน [เงื่อนไขอาร์เรย์](#array-conditions)

รองรับช่วงที่ไม่มีจุดเริ่มและจุดสิ้นสุดและสามารถใช้สร้างเงื่อนไขน้อยกว่า/มากกว่าได้

```ruby
Book.where(created_at: (Time.now.midnight - 1.day)..)
```

นี้จะสร้าง SQL เช่น:

```sql
SELECT * FROM books WHERE books.created_at >= '2008-12-21 00:00:00'
```

#### เงื่อนไขเซตย่อย

หากคุณต้องการค้นหาเร็คคอร์ดโดยใช้นิพจน์ `IN` คุณสามารถส่งอาร์เรย์ไปยังแฮชเงื่อนไข:

```ruby
Customer.where(orders_count: [1, 3, 5])
```

โค้ดนี้จะสร้าง SQL เช่นนี้:

```sql
SELECT * FROM customers WHERE (customers.orders_count IN (1,3,5))
```

### เงื่อนไข NOT

คำสั่ง SQL `NOT` สามารถสร้างได้โดยใช้ [`where.not`][]:

```ruby
Customer.where.not(orders_count: [1, 3, 5])
```

กล่าวอีกนัยหนึ่งคำสั่งนี้สามารถสร้างได้โดยเรียกใช้ `where` โดยไม่มีอาร์กิวเมนต์ แล้วตามด้วย `not` โดยส่งเงื่อนไข `where` ไป นี้จะสร้าง SQL เช่นนี้:

```sql
SELECT * FROM customers WHERE (customers.orders_count NOT IN (1,3,5))
```

หากคำสั่งค้นหามีเงื่อนไขแฮชที่มีค่าที่ไม่ใช่ `nil` บนคอลัมน์ที่สามารถเป็น `nil` ได้ รายการที่มีค่า `nil` บนคอลัมน์ที่สามารถเป็น `nil` จะไม่ถูกส่งคืน ตัวอย่างเช่น:

```ruby
Customer.create!(nullable_country: nil)
Customer.where.not(nullable_country: "UK")
=> []
# แต่
Customer.create!(nullable_country: "UK")
Customer.where.not(nullable_country: nil)
=> [#<Customer id: 2, nullable_country: "UK">]
```


### เงื่อนไข OR

เงื่อนไข `OR` ระหว่างสองความสัมพันธ์สามารถสร้างได้โดยเรียกใช้ [`or`][] บนความสัมพันธ์แรก และส่งความสัมพันธ์ที่สองเป็นอาร์กิวเมนต์

```ruby
Customer.where(last_name: 'Smith').or(Customer.where(orders_count: [1, 3, 5]))
```

```sql
SELECT * FROM customers WHERE (customers.last_name = 'Smith' OR customers.orders_count IN (1,3,5))
```


### เงื่อนไข AND

เงื่อนไข `AND` สามารถสร้างได้โดยเชื่อมต่อเงื่อนไข `where` ต่อกัน

```ruby
Customer.where(last_name: 'Smith').where(orders_count: [1, 3, 5])
```

```sql
SELECT * FROM customers WHERE customers.last_name = 'Smith' AND customers.orders_count IN (1,3,5)
```

เงื่อนไข `AND` สำหรับการตัดกันระหว่างความสัมพันธ์สามารถสร้างได้โดยเรียกใช้ [`and`][] บนความสัมพันธ์แรก และส่งความสัมพันธ์ที่สองเป็นอาร์กิวเมนต์

```ruby
Customer.where(id: [1, 2]).and(Customer.where(id: [2, 3]))
```

```sql
SELECT * FROM customers WHERE (customers.id IN (1, 2) AND customers.id IN (2, 3))
```


การเรียงลำดับ
--------

เพื่อเรียกคืนเรคคอร์ดจากฐานข้อมูลในลำดับที่กำหนด คุณสามารถใช้เมธอด [`order`][]

ตัวอย่างเช่น หากคุณกำลังรับชุดของเรคคอร์ดและต้องการเรียงลำดับตามฟิลด์ `created_at` ในตารางของคุณในลำดับเรียงขึ้น:

```ruby
Book.order(:created_at)
# หรือ
Book.order("created_at")
```

คุณสามารถระบุ `ASC` หรือ `DESC` ได้ด้วย:

```ruby
Book.order(created_at: :desc)
# หรือ
Book.order(created_at: :asc)
# หรือ
Book.order("created_at DESC")
# หรือ
Book.order("created_at ASC")
```

หรือการเรียงลำดับตามฟิลด์หลายอัน:

```ruby
Book.order(title: :asc, created_at: :desc)
# หรือ
Book.order(:title, created_at: :desc)
# หรือ
Book.order("title ASC, created_at DESC")
# หรือ
Book.order("title ASC", "created_at DESC")
```

หากคุณต้องการเรียกใช้ `order` หลายครั้ง การเรียกครั้งถัดไปจะถูกเพิ่มเข้าไปที่คำสั่งแรก:

```irb
irb> Book.order("title ASC").order("created_at DESC")
SELECT * FROM books ORDER BY title ASC, created_at DESC
```

คำเตือน: ในระบบฐานข้อมูลส่วนใหญ่ เมื่อเลือกฟิลด์ด้วย `distinct` จากชุดผลลัพธ์โดยใช้เมธอดเช่น `select`, `pluck` และ `ids`  เมื่อใช้เมธอด `order` จะเกิดข้อยกเว้น `ActiveRecord::StatementInvalid`  ยกเว้นฟิลด์ที่ใช้ในประโยค `order` ถูกเพิ่มในรายการที่เลือก ดูส่วนถัดไปสำหรับการเลือกฟิลด์จากชุดผลลัพธ์

การเลือกฟิลด์ที่เฉพาะเจาะจง
-------------------------

ตามค่าเริ่มต้น `Model.find` จะเลือกฟิลด์ทั้งหมดจากชุดผลลัพธ์โดยใช้ `select *`.

หากต้องการเลือกเฉพาะส่วนหนึ่งของฟิลด์จากชุดผลลัพธ์ คุณสามารถระบุส่วนหนึ่งนั้นผ่านเมธอด [`select`][]

ตัวอย่างเช่น หากต้องการเลือกเฉพาะคอลัมน์ `isbn` และ `out_of_print` เท่านั้น:

```ruby
Book.select(:isbn, :out_of_print)
# หรือ
Book.select("isbn, out_of_print")
```

คำสั่ง SQL ที่ใช้ในการค้นหานี้จะเป็นแบบนี้:

```sql
SELECT isbn, out_of_print FROM books
```

ควรระมัดระวังเนื่องจากนี้หมายความว่าคุณกำลังเริ่มต้นวัตถุโมเดลด้วยเฉพาะฟิลด์ที่คุณเลือก หากคุณพยายามเข้าถึงฟิลด์ที่ไม่ได้อยู่ในบันทึกที่เริ่มต้น คุณจะได้รับ:

```
ActiveModel::MissingAttributeError: missing attribute '<attribute>' for Book
```

ที่ `<attribute>` คือแอตทริบิวต์ที่คุณขอ แต่เมธอด `id` จะไม่เกิดข้อยกเว้น `ActiveRecord::MissingAttributeError` ดังนั้นควรระมัดระวังเมื่อทำงานกับความสัมพันธ์เนื่องจากต้องใช้เมธอด `id` เพื่อทำงานอย่างถูกต้อง

หากคุณต้องการเพียงแค่เลือกบันทึกเดียวต่อค่าที่ไม่ซ้ำกันในฟิลด์ที่กำหนด คุณสามารถใช้ [`distinct`][]:

```ruby
Customer.select(:last_name).distinct
```

นี้จะสร้าง SQL เช่นนี้:

```sql
SELECT DISTINCT last_name FROM customers
```

คุณยังสามารถลบข้อจำกัดของความไม่ซ้ำกันได้:

```ruby
# คืนค่า last_names ที่ไม่ซ้ำกัน
query = Customer.select(:last_name).distinct

# คืนค่า last_names ทั้งหมด แม้ว่าจะมีซ้ำกันก็ตาม
query.distinct(false)
```

การจำกัดและการข้าม
----------------

เพื่อใช้ `LIMIT` กับ SQL ที่เรียกใช้โดย `Model.find` คุณสามารถระบุ `LIMIT` โดยใช้เมธอด [`limit`][] และ [`offset`][] บนความสัมพันธ์

คุณสามารถใช้ `limit` เพื่อระบุจำนวนบันทึกที่จะเรียกคืน และใช้ `offset` เพื่อระบุจำนวนบันทึกที่ข้ามก่อนเริ่มคืนค่าบันทึก ตัวอย่างเช่น

```ruby
Customer.limit(5)
```

จะคืนค่าลูกค้าสูงสุด 5 รายการและเนื่องจากไม่ระบุ offset จะคืนค่า 5 รายการแรกในตาราง คำสั่ง SQL ที่เรียกใช้ดูเช่นนี้:

```sql
SELECT * FROM customers LIMIT 5
```

เพิ่ม `offset` เข้าไปในนั้น

```ruby
Customer.limit(5).offset(30)
```

จะคืนค่าสูงสุด 5 ลูกค้าเริ่มต้นที่ลำดับที่ 31 คำสั่ง SQL ดูเช่นนี้:

```sql
SELECT * FROM customers LIMIT 5 OFFSET 30
```

การจัดกลุ่ม
--------

เพื่อใช้ประโยค `GROUP BY` กับ SQL ที่เรียกใช้โดย finder คุณสามารถใช้เมธอด [`group`][]

ตัวอย่างเช่น หากคุณต้องการค้นหาคอลเลกชันของวันที่สร้างคำสั่งซื้อ:

```ruby
Order.select("created_at").group("created_at")
```

และนี้จะให้คุณได้วัตถุ `Order` เดียวสำหรับแต่ละวันที่มีคำสั่งซื้อในฐานข้อมูล

SQL ที่จะถูกเรียกใช้จะเป็นแบบนี้:

```sql
SELECT created_at
FROM orders
GROUP BY created_at
```

### ผลรวมของรายการที่จัดกลุ่ม

เพื่อรับผลรวมของรายการที่จัดกลุ่มในคำสั่งเดียว ให้เรียก [`count`][] หลังจาก `group`

```irb
irb> Order.group(:status).count
=> {"being_packed"=>7, "shipped"=>12}
```
SQL ที่จะถูก execute จะเป็นดังนี้:

```sql
SELECT COUNT (*) AS count_all, status AS status
FROM orders
GROUP BY status
```


### เงื่อนไข HAVING

SQL ใช้คำสั่ง `HAVING` เพื่อระบุเงื่อนไขในฟิลด์ `GROUP BY` คุณสามารถเพิ่มคำสั่ง `HAVING` ใน SQL ที่ถูกเรียกใช้โดย `Model.find` โดยเพิ่มเมธอด [`having`][] เข้าไปในการค้นหา

ตัวอย่างเช่น:

```ruby
Order.select("created_at, sum(total) as total_price").
  group("created_at").having("sum(total) > ?", 200)
```

SQL ที่จะถูก execute จะเป็นดังนี้:

```sql
SELECT created_at as ordered_date, sum(total) as total_price
FROM orders
GROUP BY created_at
HAVING sum(total) > 200
```

นี้จะคืนวันที่และราคารวมสำหรับแต่ละออบเจกต์ของคำสั่ง, จัดกลุ่มตามวันที่สั่งซื้อและราคารวมมากกว่า 200 ดอลลาร์

คุณสามารถเข้าถึง `total_price` สำหรับแต่ละออบเจกต์ของคำสั่งที่คืนมาได้ดังนี้:

```ruby
big_orders = Order.select("created_at, sum(total) as total_price")
                  .group("created_at")
                  .having("sum(total) > ?", 200)

big_orders[0].total_price
# คืนค่าราคารวมสำหรับออบเจกต์ Order แรก
```

การแทนที่เงื่อนไข
---------------------

### `unscope`

คุณสามารถระบุเงื่อนไขบางอย่างที่จะถูกลบโดยใช้เมธอด [`unscope`][] เช่น:

```ruby
Book.where('id > 100').limit(20).order('id desc').unscope(:order)
```

SQL ที่จะถูก execute จะเป็นดังนี้:

```sql
SELECT * FROM books WHERE id > 100 LIMIT 20

-- คำสั่งเดิมโดยไม่มี `unscope`
SELECT * FROM books WHERE id > 100 ORDER BY id desc LIMIT 20
```

คุณยังสามารถลบเงื่อนไข `where` ที่เฉพาะเจาะจงได้อีกด้วย เช่น นี้จะลบเงื่อนไข `id` จากคำสั่ง where:

```ruby
Book.where(id: 10, out_of_print: false).unscope(where: :id)
# SELECT books.* FROM books WHERE out_of_print = 0
```

ความสัมพันธ์ที่ใช้ `unscope` จะมีผลต่อความสัมพันธ์ใด ๆ ที่ผ่านมา:

```ruby
Book.order('id desc').merge(Book.unscope(:order))
# SELECT books.* FROM books
```


### `only`

คุณยังสามารถแทนที่เงื่อนไขโดยใช้เมธอด [`only`][] เช่น:

```ruby
Book.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

SQL ที่จะถูก execute จะเป็นดังนี้:

```sql
SELECT * FROM books WHERE id > 10 ORDER BY id DESC

-- คำสั่งเดิมโดยไม่มี `only`
SELECT * FROM books WHERE id > 10 ORDER BY id DESC LIMIT 20
```


### `reselect`

เมธอด [`reselect`][] จะแทนที่คำสั่ง select เดิม เช่น:

```ruby
Book.select(:title, :isbn).reselect(:created_at)
```

SQL ที่จะถูก execute จะเป็นดังนี้:

```sql
SELECT books.created_at FROM books
```

เปรียบเทียบกับกรณีที่ไม่ใช้คำสั่ง `reselect`:

```ruby
Book.select(:title, :isbn).select(:created_at)
```

SQL ที่จะถูก execute จะเป็นดังนี้:

```sql
SELECT books.title, books.isbn, books.created_at FROM books
```

### `reorder`

เมธอด [`reorder`][] จะแทนที่ลำดับของ default scope เช่นถ้าคำจำกัดความของคลาสรวมถึงนี้:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

และคุณ execute นี้:

```ruby
Author.find(10).books
```

SQL ที่จะถูก execute จะเป็นดังนี้:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published DESC
```

คุณสามารถใช้คำสั่ง `reorder` เพื่อระบุวิธีการจัดเรียงหนังสือที่แตกต่างกันได้ เช่น:

```ruby
Author.find(10).books.reorder('year_published ASC')
```

SQL ที่จะถูก execute จะเป็นดังนี้:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published ASC
```
### `reverse_order`

เมธอด [`reverse_order`][] จะกลับการจัดลำดับของคำสั่งถ้าระบุไว้

```ruby
Book.where("author_id > 10").order(:year_published).reverse_order
```

SQL ที่จะถูก execute:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY year_published DESC
```

หากไม่ระบุคำสั่งการจัดลำดับในคำสั่ง query จะใช้ `reverse_order` เรียงตาม primary key ในลำดับที่กลับกัน

```ruby
Book.where("author_id > 10").reverse_order
```

SQL ที่จะถูก execute:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY books.id DESC
```

เมธอด `reverse_order` รับ arguments **ไม่มี**


### `rewhere`

เมธอด [`rewhere`][] จะแทนที่เงื่อนไข `where` ที่มีอยู่แล้ว ตัวอย่างเช่น:

```ruby
Book.where(out_of_print: true).rewhere(out_of_print: false)
```

SQL ที่จะถูก execute:

```sql
SELECT * FROM books WHERE out_of_print = 0
```

หากไม่ใช้เงื่อนไข `rewhere` เงื่อนไข `where` จะถูก ANDed ร่วมกัน:

```ruby
Book.where(out_of_print: true).where(out_of_print: false)
```

SQL ที่จะถูก execute:

```sql
SELECT * FROM books WHERE out_of_print = 1 AND out_of_print = 0
```



### `regroup`

เมธอด [`regroup`][] จะแทนที่เงื่อนไข `group` ที่มีอยู่แล้ว ตัวอย่างเช่น:

```ruby
Book.group(:author).regroup(:id)
```

SQL ที่จะถูก execute:

```sql
SELECT * FROM books GROUP BY id
```

หากไม่ใช้เงื่อนไข `regroup` เงื่อนไข `group` จะถูกรวมกัน:

```ruby
Book.group(:author).group(:id)
```

SQL ที่จะถูก execute:

```sql
SELECT * FROM books GROUP BY author, id
```



Null Relation
-------------

เมธอด [`none`][] จะคืนค่าเป็น relation ที่สามารถเชื่อมต่อได้แต่ไม่มี records ใด ๆ หากมีเงื่อนไขที่เชื่อมต่อต่อจาก relation ที่คืนค่าออกมาจะยังคงสร้าง relation ที่ว่างเปล่าต่อไป สิ่งนี้มีประโยชน์ในสถานการณ์ที่คุณต้องการการตอบสนองที่สามารถเชื่อมต่อได้กับเมธอดหรือ scope ที่อาจส่งคืนผลลัพธ์ที่เป็นศูนย์

```ruby
Book.none # คืนค่า Relation ที่ว่างเปล่าและไม่ execute queries
```

```ruby
# เมธอด highlighted_reviews ด้านล่างคาดหวังว่าจะคืนค่าเป็น Relation เสมอ
Book.first.highlighted_reviews.average(:rating)
# => คืนค่าค่าเฉลี่ยของ rating ของหนังสือ

class Book
  # คืนค่า reviews หากมีอย่างน้อย 5,
  # มิฉะนั้นพิจารณาหนังสือที่ไม่ได้รับการตรวจสอบ
  def highlighted_reviews
    if reviews.count > 5
      reviews
    else
      Review.none # ยังไม่ได้ตรงตามเกณฑ์ขั้นต่ำ
    end
  end
end
```

Readonly Objects
----------------

Active Record ให้เมธอด [`readonly`][] บน relation เพื่อป้องกันการแก้ไขวัตถุที่คืนค่าออกมา การพยายามเปลี่ยนแปลง record ที่เป็น readonly จะไม่สำเร็จ และจะเกิดข้อยกเว้น `ActiveRecord::ReadOnlyRecord`

```ruby
customer = Customer.readonly.first
customer.visits += 1
customer.save
```

เนื่องจาก `customer` ถูกกำหนดให้เป็นวัตถุที่ไม่สามารถแก้ไขได้ โค้ดด้านบนจะเกิดข้อยกเว้น `ActiveRecord::ReadOnlyRecord` เมื่อเรียกใช้ `customer.save` โดยมีค่า _visits_ ที่อัปเดต

Locking Records for Update
--------------------------

การล็อกเป็นประโยชน์ในการป้องกันเหตุการณ์แข่งขันเมื่ออัปเดต records ในฐานข้อมูลและการให้การอัปเดตแบบอะตอมิก

Active Record ให้กลไกการล็อกสองรูปแบบ:

* Optimistic Locking
* Pessimistic Locking

### Optimistic Locking

Optimistic locking ช่วยให้ผู้ใช้หลายคนสามารถเข้าถึง record เดียวกันสำหรับการแก้ไขได้ และคาดหวังว่าจะมีการแข่งขันข้อมูลน้อยที่สุด โดยการตรวจสอบว่ากระบวนการอื่นได้ทำการเปลี่ยนแปลง record ตั้งแต่เปิดใช้งาน หากเกิดเหตุการณ์ดังกล่าวและการอัปเดตถูกละเว้น จะเกิดข้อยกเว้น `ActiveRecord::StaleObjectError`


**คอลัมน์การล็อกแบบคาดหวัง**

เพื่อใช้การล็อกแบบคาดหวัง ตารางจำเป็นต้องมีคอลัมน์ที่เรียกว่า `lock_version` ของชนิด integer ทุกครั้งที่มีการอัปเดตเรคคอร์ด Active Record จะเพิ่มคอลัมน์ `lock_version` ถ้าคำขอการอัปเดตถูกทำด้วยค่าที่ต่ำกว่าในฟิลด์ `lock_version` ที่อยู่ในคอลัมน์ `lock_version` ในฐานข้อมูล คำขอการอัปเดตจะล้มเหลวพร้อมกับ `ActiveRecord::StaleObjectError`

ตัวอย่าง:

```ruby
c1 = Customer.find(1)
c2 = Customer.find(1)

c1.first_name = "Sandra"
c1.save

c2.first_name = "Michael"
c2.save # จะเกิดข้อผิดพลาด ActiveRecord::StaleObjectError
```

คุณต้องรับผิดชอบการแก้ไขข้อขัดแย้งโดยการรับข้อยกเว้นและทำการย้อนกลับ ผสานหรือใช้ตรรกะธุรกิจที่จำเป็นในการแก้ไขข้อขัดแย้ง

พฤติกรรมนี้สามารถปิดการใช้งานได้โดยการตั้งค่า `ActiveRecord::Base.lock_optimistically = false`

ในการแทนที่ชื่อคอลัมน์ `lock_version` `ActiveRecord::Base` ให้ใช้แอตทริบิวต์คลาสที่เรียกว่า `locking_column`:

```ruby
class Customer < ApplicationRecord
  self.locking_column = :lock_customer_column
end
```

### การล็อกแบบเศรษฐกิจ

การล็อกแบบเศรษฐกิจใช้กลไกการล็อกที่ฐานข้อมูลให้ การใช้ `lock` เมื่อสร้างความสัมพันธ์จะได้รับการล็อกแบบเศรษฐกิจสำหรับแถวที่เลือก ความสัมพันธ์ที่ใช้ `lock` มักจะถูกห่อหุ้มไว้ในการทำธุรกรรมเพื่อป้องกันเงื่อนไขการติดขัด

ตัวอย่าง:

```ruby
Book.transaction do
  book = Book.lock.first
  book.title = 'Algorithms, second edition'
  book.save!
end
```

เซสชันด้านบนจะสร้าง SQL ต่อไปนี้สำหรับฐานข้อมูล MySQL:

```sql
SQL (0.2ms)   BEGIN
Book Load (0.3ms)   SELECT * FROM books LIMIT 1 FOR UPDATE
Book Update (0.4ms)   UPDATE books SET updated_at = '2009-02-07 18:05:56', title = 'Algorithms, second edition' WHERE id = 1
SQL (0.8ms)   COMMIT
```

คุณยังสามารถส่ง SQL แบบ raw ไปยังเมธอด `lock` เพื่ออนุญาตให้ใช้ประเภทการล็อกที่แตกต่างกัน ตัวอย่างเช่น MySQL มีนิพจน์ที่เรียกว่า `LOCK IN SHARE MODE` ที่คุณสามารถล็อกเร็คคอร์ดได้แต่ยังอนุญาตให้คิวรีอื่นอ่านได้ ในการระบุนิพจน์นี้เพียงแค่ส่งมันเป็นตัวเลือกล็อก:

```ruby
Book.transaction do
  book = Book.lock("LOCK IN SHARE MODE").find(1)
  book.increment!(:views)
end
```

หมายเหตุ: โปรดทราบว่าฐานข้อมูลของคุณต้องรองรับ SQL แบบ raw ที่คุณส่งไปยังเมธอด `lock`

หากคุณมีอินสแตนซ์ของโมเดลของคุณแล้ว คุณสามารถเริ่มทำธุรกรรมและรับการล็อกได้ในคราวเดียวกันโดยใช้โค้ดต่อไปนี้:

```ruby
book = Book.first
book.with_lock do
  # บล็อกนี้ถูกเรียกในการทำธุรกรรม
  # หนังสือถูกล็อกแล้ว
  book.increment!(:views)
end
```

การเชื่อมต่อตาราง
--------------

Active Record ให้บริการเมธอด finder สองวิธีสำหรับระบุคลอส `JOIN` ใน SQL ที่ได้รับ: `joins` และ `left_outer_joins` ในขณะที่ `joins` ควรใช้สำหรับ `INNER JOIN` หรือคิวรีที่กำหนดเอง `left_outer_joins` ใช้สำหรับคิวรีที่ใช้ `LEFT OUTER JOIN`

### `joins`

มีวิธีการใช้ [`joins`][] หลายวิธี

#### ใช้ String SQL Fragment

คุณสามารถให้ SQL แบบ raw ที่ระบุคำสั่ง `JOIN` ไปยัง `joins` ได้:

```ruby
Author.joins("INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE")
```

นี้จะทำให้ได้ SQL ต่อไปนี้:

```sql
SELECT authors.* FROM authors INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE
```

#### ใช้ Array/Hash ของ Named Associations

Active Record ช่วยให้คุณใช้ชื่อของ [การเชื่อมโยง](association_basics.html) ที่กำหนดในโมเดลเป็นทางเลือกในการระบุคำสั่ง `JOIN` สำหรับการเชื่อมโยงเหล่านั้นเมื่อใช้เมธอด `joins`
ทุกอย่างต่อไปนี้จะสร้างคำสั่ง join ที่คาดหวังโดยใช้ `INNER JOIN`:

##### เข้าร่วมการเชื่อมต่อแบบเดี่ยว

```ruby
Book.joins(:reviews)
```

สร้างคำสั่ง SQL ดังนี้:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
```

หรือเป็นภาษาอังกฤษ: "คืนวัตถุ Book สำหรับหนังสือทั้งหมดที่มีรีวิว" โปรดทราบว่าคุณจะเห็นหนังสือที่ซ้ำกันหากหนังสือนั้นมีรีวิวมากกว่าหนึ่งรีวิว หากคุณต้องการหนังสือที่ไม่ซ้ำกันคุณสามารถใช้ `Book.joins(:reviews).distinct` 

#### เข้าร่วมการเชื่อมต่อหลายอันดับ

```ruby
Book.joins(:author, :reviews)
```

สร้างคำสั่ง SQL ดังนี้:

```sql
SELECT books.* FROM books
  INNER JOIN authors ON authors.id = books.author_id
  INNER JOIN reviews ON reviews.book_id = books.id
```

หรือเป็นภาษาอังกฤษ: "คืนหนังสือทั้งหมดพร้อมกับผู้เขียนของหนังสือนั้นที่มีอย่างน้อยหนึ่งรีวิว" โปรดทราบอีกครั้งว่าหนังสือที่มีรีวิวมากกว่าหนึ่งรีวิวจะปรากฏหลายครั้ง

##### เข้าร่วมการเชื่อมต่อแบบซ้อน (ระดับเดียว)

```ruby
Book.joins(reviews: :customer)
```

สร้างคำสั่ง SQL ดังนี้:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
```

หรือเป็นภาษาอังกฤษ: "คืนหนังสือทั้งหมดที่มีรีวิวโดยลูกค้า"

##### เข้าร่วมการเชื่อมต่อแบบซ้อน (ระดับหลายระดับ)

```ruby
Author.joins(books: [{ reviews: { customer: :orders } }, :supplier])
```

สร้างคำสั่ง SQL ดังนี้:

```sql
SELECT * FROM authors
  INNER JOIN books ON books.author_id = authors.id
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
  INNER JOIN orders ON orders.customer_id = customers.id
INNER JOIN suppliers ON suppliers.id = books.supplier_id
```

หรือเป็นภาษาอังกฤษ: "คืนผู้เขียนทั้งหมดที่มีหนังสือที่มีรีวิว _และ_ ถูกสั่งซื้อโดยลูกค้า และซัพพลายเออร์สำหรับหนังสือเหล่านั้น"

#### ระบุเงื่อนไขในตารางที่เชื่อมต่อ

คุณสามารถระบุเงื่อนไขในตารางที่เชื่อมต่อโดยใช้เงื่อนไขปกติของ [Array](#array-conditions) และ [String](#pure-string-conditions)  เงื่อนไข [Hash conditions](#hash-conditions) ให้คำสั่งพิเศษสำหรับระบุเงื่อนไขสำหรับตารางที่เชื่อมต่อ:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where('orders.created_at' => time_range).distinct
```

นี้จะค้นหาลูกค้าทั้งหมดที่มีคำสั่งซื้อที่สร้างเมื่อวานนี้โดยใช้นิพจน์ SQL `BETWEEN` เปรียบเทียบ `created_at`

วิธีทางเลือกและสะอาดกว่าคือการซ้อนเงื่อนไขแบบแฮช:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where(orders: { created_at: time_range }).distinct
```

สำหรับเงื่อนไขที่ซับซ้อนมากขึ้นหรือเพื่อใช้งานช่วงที่มีชื่อเรียกอยู่แล้ว [`merge`][] สามารถใช้ได้ ก่อนอื่นเรามาเพิ่มชื่อเรียกใหม่ในโมเดล `Order`:

```ruby
class Order < ApplicationRecord
  belongs_to :customer

  scope :created_in_time_range, ->(time_range) {
    where(created_at: time_range)
  }
end
```

ตอนนี้เราสามารถใช้ `merge` เพื่อผสานชื่อเรียก `created_in_time_range` เข้ากับ:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).merge(Order.created_in_time_range(time_range)).distinct
```

นี้จะค้นหาลูกค้าทั้งหมดที่มีคำสั่งซื้อที่สร้างเมื่อวานนี้อีกครั้งโดยใช้นิพจน์ SQL `BETWEEN`

### `left_outer_joins`

หากคุณต้องการเลือกเซตของระเบียนไม่ว่าจะมีระเบียนที่เกี่ยวข้องหรือไม่ คุณสามารถใช้เมธอด [`left_outer_joins`][]

```ruby
Customer.left_outer_joins(:reviews).distinct.select('customers.*, COUNT(reviews.*) AS reviews_count').group('customers.id')
```

ซึ่งจะสร้างคำสั่ง SQL ดังนี้:

```sql
SELECT DISTINCT customers.*, COUNT(reviews.*) AS reviews_count FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id GROUP BY customers.id
```

ซึ่งหมายความว่า: "คืนลูกค้าทั้งหมดพร้อมกับจำนวนรีวิวของพวกเขา ไม่ว่าพวกเขาจะมีรีวิวหรือไม่ก็ตาม"

### `where.associated` และ `where.missing`
เมธอด `associated` และ `missing` ให้คุณเลือกเซตของเร็คคอร์ดโดยอิงตามการมีหรือไม่มีความสัมพันธ์

ใช้ `where.associated` ดังนี้:

```ruby
Customer.where.associated(:reviews)
```

จะสร้าง:

```sql
SELECT customers.* FROM customers
INNER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NOT NULL
```

ซึ่งหมายความว่า "คืนค่าลูกค้าทั้งหมดที่ทำรีวิวอย่างน้อยหนึ่งรายการ"

ใช้ `where.missing` ดังนี้:

```ruby
Customer.where.missing(:reviews)
```

จะสร้าง:

```sql
SELECT customers.* FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NULL
```

ซึ่งหมายความว่า "คืนค่าลูกค้าทั้งหมดที่ไม่ได้ทำรีวิวเลย"


การโหลดข้อมูลสัมพันธ์ล่วงหน้า
--------------------------

การโหลดข้อมูลสัมพันธ์ล่วงหน้าคือกลไกสำหรับโหลดเรคคอร์ดที่เกี่ยวข้องกับวัตถุที่คืนค่าจาก `Model.find` โดยใช้จำนวนคำสั่งที่น้อยที่สุดเท่าที่จะเป็นไปได้

### ปัญหา N + 1 Queries

พิจารณาโค้ดต่อไปนี้ซึ่งค้นหาหนังสือ 10 เล่มและพิมพ์นามสกุลของผู้เขียน:

```ruby
books = Book.limit(10)

books.each do |book|
  puts book.author.last_name
end
```

โค้ดนี้ดูดีตามสายตาเหมือนกัน แต่ปัญหาอยู่ที่จำนวนคำสั่งที่ถูกดำเนินการ โค้ดด้านบนดำเนินการ 1 (เพื่อค้นหาหนังสือ 10 เล่ม) + 10 (หนึ่งคำสั่งต่อหนึ่งเล่มเพื่อโหลดผู้เขียน) = **11** คำสั่งทั้งหมด

#### วิธีแก้ปัญหา N + 1 Queries

Active Record ช่วยให้คุณระบุล่วงหน้าถึงสัมพันธ์ทั้งหมดที่จะโหลด

เมธอดที่ใช้ได้คือ:

* [`includes`][]
* [`preload`][]
* [`eager_load`][]

### `includes`

ด้วย `includes` Active Record จะรับรองให้โหลดสัมพันธ์ที่ระบุทั้งหมดโดยใช้จำนวนคำสั่งที่น้อยที่สุดเท่าที่จะเป็นไปได้

เมื่อพิจารณาโค้ดด้านบนโดยใช้เมธอด `includes` เราสามารถเขียนใหม่ `Book.limit(10)` เพื่อโหลดผู้เขียนล่วงหน้าได้:

```ruby
books = Book.includes(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

โค้ดด้านบนจะดำเนินการเพียง **2** คำสั่งเท่านั้น ตรงกันข้ามกับ **11** คำสั่งจากกรณีเดิม:

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.book_id IN (1,2,3,4,5,6,7,8,9,10)
```

#### การโหลดสัมพันธ์หลายๆ อันพร้อมกัน

Active Record ช่วยให้คุณโหลดสัมพันธ์ใดๆ ก็ได้พร้อมกันด้วยการเรียกใช้ `Model.find` เดียวโดยใช้อาร์เรย์ แฮช หรือแฮชซ้อนกันของอาร์เรย์/แฮชด้วยเมธอด `includes`

##### อาร์เรย์ของสัมพันธ์หลายๆ อัน

```ruby
Customer.includes(:orders, :reviews)
```

นี้จะโหลดลูกค้าทั้งหมดและคำสั่งที่เกี่ยวข้องและรีวิวสำหรับแต่ละคำสั่ง

##### แฮชสัมพันธ์ซ้อนกัน

```ruby
Customer.includes(orders: { books: [:supplier, :author] }).find(1)
```

นี้จะค้นหาลูกค้าที่มี id เป็น 1 และโหลดคำสั่งที่เกี่ยวข้องทั้งหมดสำหรับมัน หนังสือสำหรับทุกคำสั่ง และผู้เขียนและผู้ผลิตสำหรับแต่ละหนังสือ

#### การระบุเงื่อนไขในสัมพันธ์ที่โหลดล่วงหน้า

แม้ว่า Active Record จะช่วยให้คุณระบุเงื่อนไขในสัมพันธ์ที่โหลดล่วงหน้าเหมือน `joins` แต่วิธีที่แนะนำคือใช้ [joins](#joining-tables) แทน

อย่างไรก็ตามหากคุณต้องการทำเช่นนี้คุณสามารถใช้ `where` เหมือนเช่นเดิม

```ruby
Author.includes(:books).where(books: { out_of_print: true })
```

นี้จะสร้างคำสั่งที่มี `LEFT OUTER JOIN` ในขณะที่
เมธอด `joins` จะสร้างคำสั่งที่ใช้ฟังก์ชัน `INNER JOIN` แทน

```sql
  SELECT authors.id AS t0_r0, ... books.updated_at AS t1_r5 FROM authors LEFT OUTER JOIN books ON books.author_id = authors.id WHERE (books.out_of_print = 1)
```
หากไม่มีเงื่อนไข `where` จะสร้างชุดคำสั่งสองรายการตามปกติ

หมายเหตุ: การใช้ `where` เช่นนี้จะทำงานเมื่อคุณส่ง Hash เข้าไป สำหรับ SQL-fragments คุณต้องใช้ `references` เพื่อบังคับให้ตารางที่เชื่อมต่อกัน:

```ruby
Author.includes(:books).where("books.out_of_print = true").references(:books)
```

ในกรณีของคำสั่ง `includes` นี้ หากไม่มีหนังสือสำหรับผู้เขียนใด ๆ ผู้เขียนทั้งหมดจะถูกโหลดอยู่เสมอ โดยใช้ `joins` (INNER JOIN) เงื่อนไขการเชื่อมต่อ **ต้อง** ตรงกัน มิฉะนั้นจะไม่มีระเบียนที่จะถูกส่งกลับ

หมายเหตุ: หากการเชื่อมต่อถูกโหลดล่วงหน้าเป็นส่วนหนึ่งของการเชื่อมต่อ ข้อมูลจากคำสั่งเลือกที่กำหนดเองจะไม่ปรากฏในโมเดลที่โหลดไว้ นี่เพราะว่าไม่ชัดเจนว่าควรปรากฏบนระเบียนหลักหรือลูก

### `preload`

ด้วย `preload` Active Record โหลดแต่ละการเชื่อมต่อที่ระบุโดยใช้คำสั่งคิวรีหนึ่งต่อการเชื่อมต่อ

เมื่อมองกลับไปที่ปัญหา N + 1 queries เราสามารถเขียน `Book.limit(10)` เพื่อโหลด authors ล่วงหน้าได้ดังนี้:

```ruby
books = Book.preload(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

โค้ดข้างต้นจะทำงานเพียง **2** คำสั่งคิวรี ตรงกันข้ามกับ **11** คำสั่งคิวรีจากกรณีเดิม:

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.book_id IN (1,2,3,4,5,6,7,8,9,10)
```

หมายเหตุ: วิธีการ `preload` ใช้ array, hash หรือ nested hash ในลักษณะเดียวกับวิธีการ `includes` เพื่อโหลดจำนวนการเชื่อมต่อใด ๆ ด้วยการเรียก `Model.find` เดียว อย่างไรก็ตาม ไม่เหมือนกับวิธีการ `includes` ไม่สามารถระบุเงื่อนไขสำหรับการเชื่อมต่อที่โหลดล่วงหน้าได้

### `eager_load`

ด้วย `eager_load` Active Record โหลดทุกการเชื่อมต่อที่ระบุโดยใช้ `LEFT OUTER JOIN`

เมื่อมองกลับไปที่กรณีที่เกิด N + 1 โดยใช้วิธีการ `eager_load` เราสามารถเขียน `Book.limit(10)` เพื่อโหลด authors ได้ดังนี้:

```ruby
books = Book.eager_load(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

โค้ดข้างต้นจะทำงานเพียง **2** คำสั่งคิวรี ตรงกันข้ามกับ **11** คำสั่งคิวรีจากกรณีเดิม:

```sql
SELECT DISTINCT books.id FROM books LEFT OUTER JOIN authors ON authors.book_id = books.id LIMIT 10
SELECT books.id AS t0_r0, books.last_name AS t0_r1, ...
  FROM books LEFT OUTER JOIN authors ON authors.book_id = books.id
  WHERE books.id IN (1,2,3,4,5,6,7,8,9,10)
```

หมายเหตุ: วิธีการ `eager_load` ใช้ array, hash หรือ nested hash ในลักษณะเดียวกับวิธีการ `includes` เพื่อโหลดจำนวนการเชื่อมต่อใด ๆ ด้วยการเรียก `Model.find` เดียว นอกจากนี้ คุณยังสามารถระบุเงื่อนไขสำหรับการเชื่อมต่อที่โหลดล่วงหน้าได้เช่นกัน

### `strict_loading`

การโหลดล่วงหน้าอาจป้องกันการเกิด N + 1 queries แต่คุณอาจยังคงโหลดล่าช้าบางการเชื่อมต่อ ในการตรวจสอบว่าไม่มีการโหลดล่าช้าใด ๆ คุณสามารถเปิดใช้ [`strict_loading`][]

โดยเปิดใช้โหมดการโหลดอย่างเคร่งครัดบนความสัมพันธ์ จะเกิดข้อผิดพลาด `ActiveRecord::StrictLoadingViolationError` หากบันทึกพยายามโหลดการเชื่อมต่อในลักษณะของ lazy loading:

```ruby
user = User.strict_loading.first
user.comments.to_a # จะเกิดข้อผิดพลาด ActiveRecord::StrictLoadingViolationError
```


ขอบเขต (Scopes)
------

ขอบเขต (Scoping) ช่วยให้คุณระบุคำสั่งที่ใช้บ่อยในการค้นหาที่สามารถอ้างอิงได้เป็นเมธอดเรียกใช้กับวัตถุการเชื่อมต่อหรือโมเดล ด้วยขอบเขตเหล่านี้คุณสามารถใช้เมธอดที่ได้กล่าวถึงไว้ทั้งหมด เช่น `where`, `joins` และ `includes` ขอบเขตทั้งหมดควรส่งคืน `ActiveRecord::Relation` หรือ `nil` เพื่ออนุญาตให้เรียกใช้เมธอดเพิ่มเติม (เช่นขอบเขตอื่น ๆ) บนมันได้
ในการกำหนดขอบเขตที่เรียบง่าย เราใช้เมธอด [`scope`][] ภายในคลาส โดยส่งคิวรีที่เราต้องการให้ทำงานเมื่อเรียกใช้ขอบเขตนี้:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

ในการเรียกใช้ขอบเขต `out_of_print` เราสามารถเรียกใช้ได้ทั้งในระดับคลาส:

```irb
irb> Book.out_of_print
=> #<ActiveRecord::Relation> # หนังสือทั้งหมดที่หมดพิมพ์
```

หรือในการเรียกใช้บนออบเจกต์ที่เกี่ยวข้องกับ `Book`:

```irb
irb> author = Author.first
irb> author.books.out_of_print
=> #<ActiveRecord::Relation> # หนังสือทั้งหมดที่หมดพิมพ์โดย `author`
```

ขอบเขตสามารถเชื่อมต่อกันได้ภายในขอบเขตอื่น ๆ:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :out_of_print_and_expensive, -> { out_of_print.where("price > 500") }
end
```


### การส่งอาร์กิวเมนต์

ขอบเขตของคุณสามารถรับอาร์กิวเมนต์ได้:

```ruby
class Book < ApplicationRecord
  scope :costs_more_than, ->(amount) { where("price > ?", amount) }
end
```

เรียกใช้ขอบเขตเหมือนกับเมธอดของคลาส:

```irb
irb> Book.costs_more_than(100.10)
```

อย่างไรก็ตาม นี่เป็นการทำซ้ำฟังก์ชันที่จะถูกให้คุณโดยเมธอดของคลาส

```ruby
class Book < ApplicationRecord
  def self.costs_more_than(amount)
    where("price > ?", amount)
  end
end
```

เมธอดเหล่านี้ยังสามารถเข้าถึงได้ในออบเจกต์ที่เกี่ยวข้อง:

```irb
irb> author.books.costs_more_than(100.10)
```

### การใช้เงื่อนไข

ขอบเขตของคุณสามารถใช้เงื่อนไขได้:

```ruby
class Order < ApplicationRecord
  scope :created_before, ->(time) { where(created_at: ...time) if time.present? }
end
```

เหมือนตัวอย่างอื่น ๆ นี้ จะทำงานเช่นเมธอดของคลาส

```ruby
class Order < ApplicationRecord
  def self.created_before(time)
    where(created_at: ...time) if time.present?
  end
end
```

อย่างไรก็ตาม มีหนึ่งข้อควรระวัง: ขอบเขตจะส่งกลับออบเจกต์ `ActiveRecord::Relation` เสมอ แม้ว่าเงื่อนไขจะประเมินเป็น `false` ในขณะที่เมธอดของคลาสจะส่งกลับ `nil` สามารถทำให้เกิด `NoMethodError` เมื่อเชื่อมต่อเมธอดของคลาสด้วยเงื่อนไขที่ตรวจสอบเป็น `false`

### การใช้งานขอบเขตเริ่มต้น

หากเราต้องการให้ขอบเขตถูกใช้กับคิวรีทั้งหมดในโมเดล เราสามารถใช้เมธอด [`default_scope`][] ภายในโมเดลเอง

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

เมื่อมีการดำเนินการคิวรีในโมเดลนี้ คิวรี SQL จะมีลักษณะเช่นนี้:

```sql
SELECT * FROM books WHERE (out_of_print = false)
```

หากคุณต้องการทำสิ่งที่ซับซ้อนมากขึ้นกับขอบเขตเริ่มต้น คุณสามารถกำหนดได้เป็นเมธอดของคลาส:

```ruby
class Book < ApplicationRecord
  def self.default_scope
    # ควรส่งกลับออบเจกต์ ActiveRecord::Relation
  end
end
```

หมายเหตุ: `default_scope` จะถูกใช้ในขณะสร้าง/สร้างออบเจกต์เมื่ออาร์กิวเมนต์ของขอบเขตถูกกำหนดเป็น `Hash` แต่จะไม่ถูกใช้ในขณะอัปเดตออบเจกต์ เช่น:

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

```irb
irb> Book.new
=> #<Book id: nil, out_of_print: false>
irb> Book.unscoped.new
=> #<Book id: nil, out_of_print: nil>
```

โปรดทราบว่าเมื่อให้ในรูปแบบ `Array` อาร์กิวเมนต์ของ `default_scope` ไม่สามารถแปลงเป็น `Hash` สำหรับการกำหนดค่าเริ่มต้นของแอตทริบิวต์ได้ เช่น:

```ruby
class Book < ApplicationRecord
  default_scope { where("out_of_print = ?", false) }
end
```

```irb
irb> Book.new
=> #<Book id: nil, out_of_print: nil>
```
### การผสานขอบเขต

เหมือนกับคำสั่ง `where` ของ `scope` จะถูกผสานกันโดยใช้เงื่อนไข `AND`

```ruby
class Book < ApplicationRecord
  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }

  scope :recent, -> { where(year_published: 50.years.ago.year..) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
end
```

```irb
irb> Book.out_of_print.old
SELECT books.* FROM books WHERE books.out_of_print = 'true' AND books.year_published < 1969
```

เราสามารถผสานเงื่อนไขของ `scope` และ `where` ได้และ SQL สุดท้ายจะมีเงื่อนไขทั้งหมดรวมกันด้วย `AND`

```irb
irb> Book.in_print.where(price: ...100)
SELECT books.* FROM books WHERE books.out_of_print = 'false' AND books.price < 100
```

หากเราต้องการให้เงื่อนไข `where` สุดท้ายชนะ [`merge`][] สามารถใช้ได้

```irb
irb> Book.in_print.merge(Book.out_of_print)
SELECT books.* FROM books WHERE books.out_of_print = true
```

หนึ่งอย่างที่สำคัญคือ `default_scope` จะถูกเตรียมไว้ก่อนในเงื่อนไขของ `scope` และ `where`

```ruby
class Book < ApplicationRecord
  default_scope { where(year_published: 50.years.ago.year..) }

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

```irb
irb> Book.all
SELECT books.* FROM books WHERE (year_published >= 1969)

irb> Book.in_print
SELECT books.* FROM books WHERE (year_published >= 1969) AND books.out_of_print = false

irb> Book.where('price > 50')
SELECT books.* FROM books WHERE (year_published >= 1969) AND (price > 50)
```

จากตัวอย่างด้านบนจะเห็นว่า `default_scope` ถูกผสานเข้ากับทั้ง `scope` และ `where`


### การลบขอบเขตทั้งหมด

หากเราต้องการลบขอบเขตเพื่อเหตุผลใดๆ เราสามารถใช้เมธอด [`unscoped`][] ได้ นี่เป็นวิธีที่มีประโยชน์มากโดยเฉพาะหากมี `default_scope` ที่ระบุในโมเดลและไม่ควรใช้กับคิวรีนี้

```ruby
Book.unscoped.load
```

เมธอดนี้จะลบขอบเขตทั้งหมดและจะดำเนินการคิวรีตามปกติบนตาราง

```irb
irb> Book.unscoped.all
SELECT books.* FROM books

irb> Book.where(out_of_print: true).unscoped.all
SELECT books.* FROM books
```

`unscoped` ยังสามารถรับบล็อกได้

```irb
irb> Book.unscoped { Book.out_of_print }
SELECT books.* FROM books WHERE books.out_of_print
```


Dynamic Finders
---------------

สำหรับทุกฟิลด์ (ที่เรียกว่าแอตทริบิวต์) ที่คุณกำหนดในตารางของคุณ Active Record จะให้เมธอดค้นหา หากคุณมีฟิลด์ที่เรียกว่า `first_name` ในโมเดล `Customer` เช่น เราจะได้รับเมธอด `find_by_first_name` ฟรีจาก Active Record หากคุณมีฟิลด์ `locked` ในโมเดล `Customer` คุณยังได้รับเมธอด `find_by_locked`

คุณสามารถระบุเครื่องหมายจุดตกในเมธอดค้นหาเพื่อให้เกิดข้อผิดพลาด `ActiveRecord::RecordNotFound` หากไม่มีการคืนค่าเร็กคอร์ดใดๆ เช่น `Customer.find_by_first_name!("Ryan")`

หากคุณต้องการค้นหาด้วยทั้ง `first_name` และ `orders_count` คุณสามารถเชื่อมต่อเมธอดค้นหาเหล่านี้ด้วยการพิมพ์ "`and`" ระหว่างฟิลด์ เช่น `Customer.find_by_first_name_and_orders_count("Ryan", 5)`.

Enums
-----

Enum ช่วยให้คุณกำหนดอาร์เรย์ของค่าสำหรับแอตทริบิวต์และอ้างอิงถึงค่าเหล่านั้นโดยใช้ชื่อ ค่าจริงที่จัดเก็บในฐานข้อมูลคือจำนวนเต็มที่ถูกแมปไปยังหนึ่งในค่าเหล่านั้น

การประกาศ enum จะ:

* สร้างสโคปที่สามารถใช้ในการค้นหาวัตถุทั้งหมดที่มีหรือไม่มีหนึ่งในค่า enum
* สร้างเมธอดของอินสแตนซ์ที่สามารถใช้ในการกำหนดว่าวัตถุมีค่า enum ใด
* สร้างเมธอดของอินสแตนซ์ที่สามารถใช้ในการเปลี่ยนค่า enum ของวัตถุ
สำหรับค่าที่เป็นไปได้ทั้งหมดของ enum

ตัวอย่างเช่น ให้มีการประกาศ [`enum`][] ดังนี้:

```ruby
class Order < ApplicationRecord
  enum :status, [:shipped, :being_packaged, :complete, :cancelled]
end
```

สร้าง [scopes](#scopes) เหล่านี้โดยอัตโนมัติและสามารถใช้ในการค้นหาวัตถุทั้งหมดที่มีหรือไม่มีค่าที่ระบุสำหรับ `status`:

```irb
irb> Order.shipped
=> #<ActiveRecord::Relation> # คำสั่งทั้งหมดที่มี status == :shipped
irb> Order.not_shipped
=> #<ActiveRecord::Relation> # คำสั่งทั้งหมดที่มี status != :shipped
```

สร้างเมธอดของตัวอย่างเหล่านี้โดยอัตโนมัติและสอบถามว่าโมเดลมีค่านั้นสำหรับ enum `status` หรือไม่:

```irb
irb> order = Order.shipped.first
irb> order.shipped?
=> true
irb> order.complete?
=> false
```

สร้างเมธอดของตัวอย่างเหล่านี้โดยอัตโนมัติและจะอัปเดตค่าของ `status` ไปยังค่าที่ระบุก่อนแล้วสอบถามว่าสถานะได้ถูกตั้งค่าเป็นค่านั้นหรือไม่:

```irb
irb> order = Order.first
irb> order.shipped!
UPDATE "orders" SET "status" = ?, "updated_at" = ? WHERE "orders"."id" = ?  [["status", 0], ["updated_at", "2019-01-24 07:13:08.524320"], ["id", 1]]
=> true
```

เอกสารเต็มเกี่ยวกับ enums สามารถค้นหาได้ที่นี่ [here](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).


เข้าใจ Method Chaining
-----------------------------

แพทเทิร์น Active Record นำเสนอ [Method Chaining](https://en.wikipedia.org/wiki/Method_chaining) ซึ่งช่วยให้เราสามารถใช้เมธอด Active Record หลาย ๆ ตัวร่วมกันได้อย่างง่ายดายและตรงไปตรงมา

คุณสามารถเชื่อมต่อเมธอดในคำสั่งเมื่อเมธอดก่อนหน้าที่เรียกคืน [`ActiveRecord::Relation`][] เช่น `all`, `where`, และ `joins` เมธอดที่คืนค่าวัตถุเดียว (ดูในส่วน [Retrieving a Single Object Section](#retrieving-a-single-object)) จะต้องอยู่ที่สุดของคำสั่ง

ตัวอย่างบางส่วนแสดงด้านล่าง คู่มือนี้จะไม่ครอบคลุมทุกกรณีเป็นตัวอย่าง แต่เพียงเล็กน้อย แต่เมื่อเรียกใช้เมธอด Active Record คิวรี่จะไม่ถูกสร้างและส่งไปยังฐานข้อมูลทันที คิวรี่จะถูกส่งเมื่อข้อมูลจริงๆ จำเป็นต้องใช้งาน ดังนั้นแต่ละตัวอย่างด้านล่างจะสร้างคิวรี่เพียงคิวรี่เดียว

### การเรียกดูข้อมูลที่กรองจากตารางหลาย ๆ ตาราง

```ruby
Customer
  .select('customers.id, customers.last_name, reviews.body')
  .joins(:reviews)
  .where('reviews.created_at > ?', 1.week.ago)
```

ผลลัพธ์ควรจะเป็นแบบนี้:

```sql
SELECT customers.id, customers.last_name, reviews.body
FROM customers
INNER JOIN reviews
  ON reviews.customer_id = customers.id
WHERE (reviews.created_at > '2019-01-08')
```

### การเรียกดูข้อมูลที่ระบุจากตารางหลาย ๆ ตาราง

```ruby
Book
  .select('books.id, books.title, authors.first_name')
  .joins(:author)
  .find_by(title: 'Abstraction and Specification in Program Development')
```

สิ่งที่ได้จากข้างบนควรจะเป็น:

```sql
SELECT books.id, books.title, authors.first_name
FROM books
INNER JOIN authors
  ON authors.id = books.author_id
WHERE books.title = $1 [["title", "Abstraction and Specification in Program Development"]]
LIMIT 1
```

หมายเหตุ: โปรดทราบว่าหากคิวรีตรงกับเร็คคอร์ดหลายรายการ `find_by` จะดึงเพียงรายการแรกเท่านั้นและไม่สนใจรายการอื่น ๆ (ดูคำสั่ง `LIMIT 1` ด้านบน)

ค้นหาหรือสร้างวัตถุใหม่
--------------------------

มักจะมีความเป็นไปได้ที่คุณต้องการค้นหาเร็คคอร์ดหรือสร้างเร็คคอร์ดใหม่หากไม่มีอยู่แล้ว คุณสามารถทำได้ด้วยเมธอด `find_or_create_by` และ `find_or_create_by!`

### `find_or_create_by`

เมธอด [`find_or_create_by`][] จะตรวจสอบว่ามีเร็คคอร์ดที่มีแอตทริบิวต์ที่ระบุหรือไม่ หากไม่มี จะเรียกใช้ `create` มาดูตัวอย่าง

สมมุติว่าคุณต้องการค้นหาลูกค้าชื่อ "Andy" และหากไม่มีให้สร้างใหม่ คุณสามารถทำได้ดังนี้:

```irb
irb> Customer.find_or_create_by(first_name: 'Andy')
=> #<Customer id: 5, first_name: "Andy", last_name: nil, title: nil, visits: 0, orders_count: nil, lock_version: 0, created_at: "2019-01-17 07:06:45", updated_at: "2019-01-17 07:06:45">
```
SQL ที่สร้างขึ้นโดยวิธีนี้จะมีลักษณะดังนี้:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO customers (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by` จะส่งคืนเรคคอร์ดที่มีอยู่แล้วหรือเรคคอร์ดใหม่ ในกรณีของเรา เรายังไม่มีลูกค้าที่ชื่อ Andy ดังนั้นเรคคอร์ดจะถูกสร้างขึ้นและส่งคืน

เรคคอร์ดใหม่อาจจะไม่ถูกบันทึกลงในฐานข้อมูล ขึ้นอยู่กับว่าการตรวจสอบความถูกต้องผ่านหรือไม่ (เหมือนกับ `create`)

สมมติว่าเราต้องการตั้งค่าแอตทริบิวต์ 'locked' เป็น `false` หากเรากำลังสร้างเรคคอร์ดใหม่ แต่เราไม่ต้องการรวมมันในคำสั่ง ดังนั้นเราต้องการค้นหาลูกค้าที่ชื่อ "Andy" หรือหากไม่มีลูกค้าดังกล่าวอยู่ เราจะสร้างลูกค้าที่ชื่อ "Andy" และไม่ล็อก

เราสามารถทำได้ในวิธีสองวิธี วิธีแรกคือใช้ `create_with`:

```ruby
Customer.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

วิธีที่สองคือใช้บล็อก:

```ruby
Customer.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

บล็อกจะถูกทำงานเฉพาะเมื่อกำลังสร้างลูกค้า ครั้งที่สองที่เราเรียกใช้โค้ดนี้ บล็อกจะถูกละเว้น


### `find_or_create_by!`

คุณยังสามารถใช้ [`find_or_create_by!`][] เพื่อเรียกขึ้นข้อยกเว้นหากเรคคอร์ดใหม่ไม่ถูกต้อง การตรวจสอบความถูกต้องไม่ได้ถูกครอบคลุมในเอกสารนี้ แต่เราสมมติได้เสมอว่าคุณเพิ่มชุดคำสั่งนี้ชั่วคราว

```ruby
validates :orders_count, presence: true
```

ในโมเดล `Customer` ของคุณ หากคุณพยายามสร้าง `Customer` ใหม่โดยไม่ระบุ `orders_count` เรคคอร์ดจะไม่ถูกต้องและจะเกิดข้อยกเว้นขึ้น:

```irb
irb> Customer.find_or_create_by!(first_name: 'Andy')
ActiveRecord::RecordInvalid: Validation failed: Orders count can’t be blank
```


### `find_or_initialize_by`

เมธอด [`find_or_initialize_by`][] จะทำงานเหมือนกับ `find_or_create_by` แต่จะเรียกใช้ `new` แทน `create` นั่นหมายความว่าจะสร้างอินสแตนซ์โมเดลใหม่ในหน่วยความจำ แต่จะไม่ถูกบันทึกลงในฐานข้อมูล ต่อจากตัวอย่าง `find_or_create_by` เราต้องการลูกค้าที่ชื่อ 'Nina':

```irb
irb> nina = Customer.find_or_initialize_by(first_name: 'Nina')
=> #<Customer id: nil, first_name: "Nina", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

irb> nina.persisted?
=> false

irb> nina.new_record?
=> true
```

เนื่องจากวัตถุยังไม่ได้เก็บในฐานข้อมูล  SQL ที่สร้างขึ้นจะมีลักษณะดังนี้:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Nina') LIMIT 1
```

เมื่อคุณต้องการบันทึกลงในฐานข้อมูล เพียงเรียกใช้ `save`:

```irb
irb> nina.save
=> true
```


การค้นหาด้วย SQL
--------------

หากคุณต้องการใช้ SQL เองในการค้นหาเรคคอร์ดในตาราง คุณสามารถใช้ [`find_by_sql`][] ได้ เมธอด `find_by_sql` จะส่งคืนอาร์เรย์ของออบเจ็กต์ แม้ว่าคำสั่งในฐานข้อมูลใต้กำลังจะส่งคืนเพียงรายการเดียว ตัวอย่างเช่นคุณสามารถเรียกใช้คำสั่งนี้:

```irb
irb> Customer.find_by_sql("SELECT * FROM customers INNER JOIN orders ON customers.id = orders.customer_id ORDER BY customers.created_at desc")
=> [#<Customer id: 1, first_name: "Lucas" ...>, #<Customer id: 2, first_name: "Jan" ...>, ...]
```

`find_by_sql` จะให้คุณทำการเรียกใช้ฐานข้อมูลเองและเรียกคืนออบเจ็กต์ที่ถูกสร้างขึ้น
### `select_all`

`find_by_sql` มีญาติใกล้เคียงที่เรียกว่า [`connection.select_all`][]. `select_all` จะดึงวัตถุจากฐานข้อมูลโดยใช้ SQL ที่กำหนดเองเหมือนกับ `find_by_sql` แต่จะไม่สร้างวัตถุขึ้นมา วิธีนี้จะส่งคืนอินสแตนซ์ของคลาส `ActiveRecord::Result` และการเรียกใช้ `to_a` กับอ็อบเจ็กต์นี้จะส่งคืนอาร์เรย์ของแฮชที่แต่ละแฮชแสดงถึงบันทึก

```irb
irb> Customer.connection.select_all("SELECT first_name, created_at FROM customers WHERE id = '1'").to_a
=> [{"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"}, {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}]
```


### `pluck`

[`pluck`][] สามารถใช้เพื่อเลือกค่าจากคอลัมน์ที่ระบุในความสัมพันธ์ปัจจุบันได้ มันรับชื่อคอลัมน์เป็นอาร์กิวเมนต์และส่งคืนอาร์เรย์ของค่าของคอลัมน์ที่ระบุพร้อมกับประเภทข้อมูลที่เกี่ยวข้อง

```irb
irb> Book.where(out_of_print: true).pluck(:id)
SELECT id FROM books WHERE out_of_print = true
=> [1, 2, 3]

irb> Order.distinct.pluck(:status)
SELECT DISTINCT status FROM orders
=> ["shipped", "being_packed", "cancelled"]

irb> Customer.pluck(:id, :first_name)
SELECT customers.id, customers.first_name FROM customers
=> [[1, "David"], [2, "Fran"], [3, "Jose"]]
```

`pluck` ทำให้เป็นไปได้ที่จะแทนที่รหัสเช่นนี้:

```ruby
Customer.select(:id).map { |c| c.id }
# หรือ
Customer.select(:id).map(&:id)
# หรือ
Customer.select(:id, :first_name).map { |c| [c.id, c.first_name] }
```

ด้วย:

```ruby
Customer.pluck(:id)
# หรือ
Customer.pluck(:id, :first_name)
```

ไม่เหมือนกับ `select`, `pluck` แปลงผลลัพธ์จากฐานข้อมูลเป็นอาร์เรย์ของรูบี้โดยตรงโดยไม่สร้างวัตถุ `ActiveRecord` ซึ่งอาจหมายความว่ามีประสิทธิภาพที่ดีกว่าสำหรับคิวรีที่ใหญ่หรือรันบ่อย อย่างไรก็ตาม การโอเวอร์ไรด์เมธอดของโมเดลจะไม่สามารถใช้ได้ เช่น:

```ruby
class Customer < ApplicationRecord
  def name
    "I am #{first_name}"
  end
end
```

```irb
irb> Customer.select(:first_name).map &:name
=> ["I am David", "I am Jeremy", "I am Jose"]

irb> Customer.pluck(:first_name)
=> ["David", "Jeremy", "Jose"]
```

คุณไม่จำกัดการค้นหาฟิลด์จากตารางเดียว คุณสามารถค้นหาตารางหลายตารางได้เช่นกัน

```irb
irb> Order.joins(:customer, :books).pluck("orders.created_at, customers.email, books.title")
```

นอกจากนี้ `pluck` ไม่เหมือนกับ `select` และสโคปอื่น ๆ ของ `Relation` เพราะ `pluck` จะเรียกคิวรีทันที และไม่สามารถเชื่อมต่อกับสโคปเพิ่มเติมได้ แม้ว่าจะสามารถทำงานร่วมกับสโคปที่สร้างไว้ก่อนหน้านี้ได้:

```irb
irb> Customer.pluck(:first_name).limit(1)
NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

irb> Customer.limit(1).pluck(:first_name)
=> ["David"]
```

หมายเหตุ: คุณควรรู้ว่าการใช้ `pluck` จะเรียกใช้การโหลดแบบอิเกอร์หากวัตถุความสัมพันธ์มีค่าการรวมอยู่ แม้ว่าการโหลดแบบอิเกอร์อาจไม่จำเป็นสำหรับคิวรี ตัวอย่างเช่น:

```irb
irb> assoc = Customer.includes(:reviews)
irb> assoc.pluck(:id)
SELECT "customers"."id" FROM "customers" LEFT OUTER JOIN "reviews" ON "reviews"."id" = "customers"."review_id"
```

วิธีหนึ่งในการหลีกเลี่ยงสิ่งนี้คือการ `unscope` การรวม:

```irb
irb> assoc.unscope(:includes).pluck(:id)
```


### `pick`

[`pick`][] สามารถใช้เพื่อเลือกค่าจากคอลัมน์ที่ระบุในความสัมพันธ์ปัจจุบันได้ มันรับชื่อคอลัมน์เป็นอาร์กิวเมนต์และส่งคืนแถวแรกของค่าคอลัมน์ที่ระบุพร้อมกับประเภทข้อมูลที่เกี่ยวข้อง
`pick` เป็นการย่อสั้นสำหรับ `relation.limit(1).pluck(*column_names).first` ซึ่งเป็นประโยชน์ในที่สุดเมื่อคุณมีความสัมพันธ์ที่ถูก จำกัด เพื่อหนึ่งแถว

`pick` ทำให้เป็นไปได้ที่จะแทนที่รหัสเช่นนี้:

```ruby
Customer.where(id: 1).pluck(:id).first
```

ด้วย:

```ruby
Customer.where(id: 1).pick(:id)
```


### `ids`

[`ids`][] สามารถใช้เพื่อเลือกค่า ID ทั้งหมดสำหรับความสัมพันธ์โดยใช้ primary key ของตาราง
```irb
irb> Customer.ids
SELECT id FROM customers
```

```ruby
class Customer < ApplicationRecord
  self.primary_key = "customer_id"
end
```

```irb
irb> Customer.ids
SELECT customer_id FROM customers
```


การตรวจสอบความมีอยู่ของวัตถุ
--------------------

หากคุณต้องการตรวจสอบความมีอยู่ของวัตถุเพียงแค่นั้น คุณสามารถใช้เมธอดที่เรียกว่า [`exists?`][]
เมธอดนี้จะสอบถามฐานข้อมูลโดยใช้คำสั่งเดียวกับ `find` แต่ไม่ได้ส่งคืนวัตถุหรือคอลเลกชันของวัตถุแต่จะส่งคืน `true` หรือ `false` เท่านั้น

```ruby
Customer.exists?(1)
```

เมธอด `exists?` ยังรองรับการระบุค่าหลายค่า แต่จะส่งคืน `true` หากมีบันทึกใดบันทึกหนึ่งอยู่

```ruby
Customer.exists?(id: [1, 2, 3])
# หรือ
Customer.exists?(first_name: ['Jane', 'Sergei'])
```

ยังสามารถใช้ `exists?` โดยไม่มีอาร์กิวเมนต์ใด ๆ บนโมเดลหรือความสัมพันธ์

```ruby
Customer.where(first_name: 'Ryan').exists?
```

ข้างต้นจะส่งคืน `true` หากมีลูกค้าอย่างน้อยหนึ่งคนที่มี `first_name` เป็น 'Ryan' และ `false`
ในกรณีอื่น ๆ

```ruby
Customer.exists?
```

ข้างต้นจะส่งคืน `false` หากตาราง `customers` ว่างเปล่าและ `true` ในกรณีอื่น ๆ

คุณยังสามารถใช้ `any?` และ `many?` เพื่อตรวจสอบความมีอยู่ของโมเดลหรือความสัมพันธ์ `many?` จะใช้ SQL `count` เพื่อกำหนดว่ารายการนั้นมีอยู่หรือไม่

```ruby
# ผ่านโมเดล
Order.any?
# SELECT 1 FROM orders LIMIT 1
Order.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders LIMIT 2)

# ผ่านสโคปชื่อ
Order.shipped.any?
# SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 1
Order.shipped.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 2)

# ผ่านความสัมพันธ์
Book.where(out_of_print: true).any?
Book.where(out_of_print: true).many?

# ผ่านความสัมพันธ์
Customer.first.orders.any?
Customer.first.orders.many?
```


การคำนวณ
------------

ส่วนนี้ใช้ [`count`][] เป็นตัวอย่างเมธอดในส่วนนำเสนอ แต่ตัวเลือกที่อธิบายสามารถใช้กับส่วนย่อยทั้งหมด

เมธอดการคำนวณทั้งหมดทำงานโดยตรงบนโมเดล:

```irb
irb> Customer.count
SELECT COUNT(*) FROM customers
```

หรือบนความสัมพันธ์:

```irb
irb> Customer.where(first_name: 'Ryan').count
SELECT COUNT(*) FROM customers WHERE (first_name = 'Ryan')
```

คุณยังสามารถใช้เมธอดการค้นหาต่าง ๆ บนความสัมพันธ์เพื่อดำเนินการคำนวณที่ซับซ้อน:

```irb
irb> Customer.includes("orders").where(first_name: 'Ryan', orders: { status: 'shipped' }).count
```

ซึ่งจะดำเนินการ:

```sql
SELECT COUNT(DISTINCT customers.id) FROM customers
  LEFT OUTER JOIN orders ON orders.customer_id = customers.id
  WHERE (customers.first_name = 'Ryan' AND orders.status = 0)
```

โดยสมมติว่า Order มี `enum status: [ :shipped, :being_packed, :cancelled ]`.

### `count`

หากคุณต้องการดูจำนวนบันทึกที่อยู่ในตารางของโมเดลของคุณ คุณสามารถเรียกใช้ `Customer.count` และจะส่งคืนจำนวนนั้น
หากคุณต้องการเป็นเฉพาะและค้นหาลูกค้าทั้งหมดที่มีชื่อเรียกอยู่ในฐานข้อมูลคุณสามารถใช้ `Customer.count(:title)`.

สำหรับตัวเลือกโปรดดูส่วนหลัก [Calculations](#calculations).

### `average`

หากคุณต้องการดูค่าเฉลี่ยของตัวเลขใดตัวเลขหนึ่งในตารางของคุณคุณสามารถเรียกใช้เมธอด [`average`][] บนคลาสที่เกี่ยวข้องกับตารางนั้น ๆ การเรียกใช้เมธอดนี้จะมีลักษณะดังนี้:

```ruby
Order.average("subtotal")
```

สิ่งนี้จะส่งคืนตัวเลข (อาจเป็นตัวเลขทศนิยมเช่น 3.14159265) ที่แสดงค่าเฉลี่ยในฟิลด์

สำหรับตัวเลือกโปรดดูส่วนหลัก [Calculations](#calculations).
### `minimum`

หากคุณต้องการหาค่าน้อยที่สุดของฟิลด์ในตารางของคุณ คุณสามารถเรียกใช้เมธอด [`minimum`][] บนคลาสที่เกี่ยวข้องกับตารางได้ การเรียกใช้เมธอดนี้จะมีรูปแบบดังนี้:

```ruby
Order.minimum("subtotal")
```

สำหรับตัวเลือก โปรดดูในส่วนหลัก [การคำนวณ](#calculations) 


### `maximum`

หากคุณต้องการหาค่าสูงสุดของฟิลด์ในตารางของคุณ คุณสามารถเรียกใช้เมธอด [`maximum`][] บนคลาสที่เกี่ยวข้องกับตารางได้ การเรียกใช้เมธอดนี้จะมีรูปแบบดังนี้:

```ruby
Order.maximum("subtotal")
```

สำหรับตัวเลือก โปรดดูในส่วนหลัก [การคำนวณ](#calculations) 


### `sum`

หากคุณต้องการหาผลรวมของฟิลด์สำหรับเรคคอร์ดทั้งหมดในตารางของคุณ คุณสามารถเรียกใช้เมธอด [`sum`][] บนคลาสที่เกี่ยวข้องกับตารางได้ การเรียกใช้เมธอดนี้จะมีรูปแบบดังนี้:

```ruby
Order.sum("subtotal")
```

สำหรับตัวเลือก โปรดดูในส่วนหลัก [การคำนวณ](#calculations) 


การเรียกใช้ EXPLAIN
---------------

คุณสามารถเรียกใช้ [`explain`][] บนความสัมพันธ์ได้ ผลลัพธ์ของ EXPLAIN จะแตกต่างกันตามฐานข้อมูลแต่ละรายการ

ตัวอย่างเช่น การเรียกใช้

```ruby
Customer.where(id: 1).joins(:orders).explain
```

อาจให้ผลลัพธ์ดังนี้

```
EXPLAIN SELECT `customers`.* FROM `customers` INNER JOIN `orders` ON `orders`.`customer_id` = `customers`.`id` WHERE `customers`.`id` = 1
+----+-------------+------------+-------+---------------+
| id | select_type | table      | type  | possible_keys |
+----+-------------+------------+-------+---------------+
|  1 | SIMPLE      | customers  | const | PRIMARY       |
|  1 | SIMPLE      | orders     | ALL   | NULL          |
+----+-------------+------------+-------+---------------+
+---------+---------+-------+------+-------------+
| key     | key_len | ref   | rows | Extra       |
+---------+---------+-------+------+-------------+
| PRIMARY | 4       | const |    1 |             |
| NULL    | NULL    | NULL  |    1 | Using where |
+---------+---------+-------+------+-------------+

2 rows in set (0.00 sec)
```

ใน MySQL และ MariaDB

Active Record ทำการพิมพ์แบบที่เหมือนกับ shell ของฐานข้อมูลที่เกี่ยวข้อง ดังนั้น คำสั่งเดียวกันที่ทำงานกับ PostgreSQL adapter จะให้ผลลัพธ์ดังต่อไปนี้

```
EXPLAIN SELECT "customers".* FROM "customers" INNER JOIN "orders" ON "orders"."customer_id" = "customers"."id" WHERE "customers"."id" = $1 [["id", 1]]
                                  QUERY PLAN
------------------------------------------------------------------------------
 Nested Loop  (cost=4.33..20.85 rows=4 width=164)
    ->  Index Scan using customers_pkey on customers  (cost=0.15..8.17 rows=1 width=164)
          Index Cond: (id = '1'::bigint)
    ->  Bitmap Heap Scan on orders  (cost=4.18..12.64 rows=4 width=8)
          Recheck Cond: (customer_id = '1'::bigint)
          ->  Bitmap Index Scan on index_orders_on_customer_id  (cost=0.00..4.18 rows=4 width=0)
                Index Cond: (customer_id = '1'::bigint)
(7 rows)
```

การโหลดแบบอิ่มตัวอาจเรียกใช้งานคำสั่งที่มากกว่าหนึ่งคำสั่งในฐานข้อมูลและบางคำสั่งอาจต้องการผลลัพธ์จากคำสั่งก่อนหน้า ด้วยเหตุนี้ `explain` จริงๆ แล้วทำการ execute คำสั่งและขอแผนการคำสั่ง ตัวอย่างเช่น

```ruby
Customer.where(id: 1).includes(:orders).explain
```

อาจให้ผลลัพธ์ดังนี้สำหรับ MySQL และ MariaDB:

```
EXPLAIN SELECT `customers`.* FROM `customers`  WHERE `customers`.`id` = 1
+----+-------------+-----------+-------+---------------+
| id | select_type | table     | type  | possible_keys |
+----+-------------+-----------+-------+---------------+
|  1 | SIMPLE      | customers | const | PRIMARY       |
+----+-------------+-----------+-------+---------------+
+---------+---------+-------+------+-------+
| key     | key_len | ref   | rows | Extra |
+---------+---------+-------+------+-------+
| PRIMARY | 4       | const |    1 |       |
+---------+---------+-------+------+-------+

1 row in set (0.00 sec)

EXPLAIN SELECT `orders`.* FROM `orders`  WHERE `orders`.`customer_id` IN (1)
+----+-------------+--------+------+---------------+
| id | select_type | table  | type | possible_keys |
+----+-------------+--------+------+---------------+
|  1 | SIMPLE      | orders | ALL  | NULL          |
+----+-------------+--------+------+---------------+
+------+---------+------+------+-------------+
| key  | key_len | ref  | rows | Extra       |
+------+---------+------+------+-------------+
| NULL | NULL    | NULL |    1 | Using where |
+------+---------+------+------+-------------+


1 row in set (0.00 sec)
```
และอาจให้ผลลัพธ์ดังต่อไปนี้สำหรับ PostgreSQL:

```
  Customer Load (0.3ms)  SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1  [["id", 1]]
  Order Load (0.3ms)  SELECT "orders".* FROM "orders" WHERE "orders"."customer_id" = $1  [["customer_id", 1]]
=> EXPLAIN SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1 [["id", 1]]
                                    QUERY PLAN
----------------------------------------------------------------------------------
 Index Scan using customers_pkey on customers  (cost=0.15..8.17 rows=1 width=164)
   Index Cond: (id = '1'::bigint)
(2 rows)
```


### ตัวเลือกการอธิบาย

สำหรับฐานข้อมูลและแอดเปอร์ที่รองรับ (ปัจจุบันคือ PostgreSQL และ MySQL) สามารถส่งตัวเลือกเพื่อให้การวิเคราะห์ลึกขึ้นได้

ใช้ PostgreSQL ดังต่อไปนี้:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze, :verbose)
```

จะได้ผลลัพธ์ดังนี้:

```sql
EXPLAIN (ANALYZE, VERBOSE) SELECT "shop_accounts".* FROM "shop_accounts" INNER JOIN "customers" ON "customers"."id" = "shop_accounts"."customer_id" WHERE "shop_accounts"."id" = $1 [["id", 1]]
                                                                   QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.30..16.37 rows=1 width=24) (actual time=0.003..0.004 rows=0 loops=1)
   Output: shop_accounts.id, shop_accounts.customer_id, shop_accounts.customer_carrier_id
   Inner Unique: true
   ->  Index Scan using shop_accounts_pkey on public.shop_accounts  (cost=0.15..8.17 rows=1 width=24) (actual time=0.003..0.003 rows=0 loops=1)
         Output: shop_accounts.id, shop_accounts.customer_id, shop_accounts.customer_carrier_id
         Index Cond: (shop_accounts.id = '1'::bigint)
   ->  Index Only Scan using customers_pkey on public.customers  (cost=0.15..8.17 rows=1 width=8) (never executed)
         Output: customers.id
         Index Cond: (customers.id = shop_accounts.customer_id)
         Heap Fetches: 0
 Planning Time: 0.063 ms
 Execution Time: 0.011 ms
(12 rows)
```

ใช้ MySQL หรือ MariaDB ดังต่อไปนี้:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze)
```

จะได้ผลลัพธ์ดังนี้:

```sql
ANALYZE SELECT `shop_accounts`.* FROM `shop_accounts` INNER JOIN `customers` ON `customers`.`id` = `shop_accounts`.`customer_id` WHERE `shop_accounts`.`id` = 1
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | r_rows | filtered | r_filtered | Extra                          |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
|  1 | SIMPLE      | NULL  | NULL | NULL          | NULL | NULL    | NULL | NULL | NULL   | NULL     | NULL       | no matching row in const table |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
1 row in set (0.00 sec)
```

หมายเหตุ: ตัวเลือก EXPLAIN และ ANALYZE แตกต่างกันไปในรุ่น MySQL และ MariaDB
([MySQL 5.7][MySQL5.7-explain], [MySQL 8.0][MySQL8-explain], [MariaDB][MariaDB-explain])


### การอ่านผลลัพธ์ EXPLAIN

การอ่านผลลัพธ์จาก EXPLAIN เกินขอบเขตของเอกสารนี้ ข้อมูลเพิ่มเติมที่อาจเป็นประโยชน์คือ:

* SQLite3: [EXPLAIN QUERY PLAN](https://www.sqlite.org/eqp.html)

* MySQL: [EXPLAIN Output Format](https://dev.mysql.com/doc/refman/en/explain-output.html)

* MariaDB: [EXPLAIN](https://mariadb.com/kb/en/mariadb/explain/)

* PostgreSQL: [Using EXPLAIN](https://www.postgresql.org/docs/current/static/using-explain.html)
[`ActiveRecord::Relation`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html
[`annotate`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-annotate
[`create_with`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-create_with
[`distinct`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-distinct
[`eager_load`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-eager_load
[`extending`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-extending
[`extract_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-extract_associated
[`find`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find
[`from`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-from
[`group`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-group
[`having`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-having
[`includes`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-includes
[`joins`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-joins
[`left_outer_joins`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-left_outer_joins
[`limit`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-limit
[`lock`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-lock
[`none`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-none
[`offset`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-offset
[`optimizer_hints`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-optimizer_hints
[`order`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-order
[`preload`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-preload
[`readonly`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-readonly
[`references`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-references
[`reorder`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reorder
[`reselect`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reselect
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`reverse_order`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reverse_order
[`select`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-select
[`where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
[`take`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-take
[`take!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-take-21
[`first`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first
[`first!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first-21
[`last`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-last
[`last!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-last-21
[`find_by`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_by
[`find_by!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_by-21
[`config.active_record.error_on_ignored_order`]: configuring.html#config-active-record-error-on-ignored-order
[`find_each`]: https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_each
[`find_in_batches`]: https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_in_batches
[`sanitize_sql_like`]: https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql_like
[`where.not`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods/WhereChain.html#method-i-not
[`or`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-or
[`and`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-and
[`count`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-count
[`unscope`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-unscope
[`only`]: https://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-only
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`strict_loading`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-strict_loading
[`scope`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-scope
[`default_scope`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-default_scope
[`merge`]: https://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-merge
[`unscoped`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-unscoped
[`enum`]: https://api.rubyonrails.org/classes/ActiveRecord/Enum.html#method-i-enum
[`find_or_create_by`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by
[`find_or_create_by!`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by-21
[`find_or_initialize_by`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_initialize_by
[`find_by_sql`]: https://api.rubyonrails.org/classes/ActiveRecord/Querying.html#method-i-find_by_sql
[`connection.select_all`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-select_all
[`pluck`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pluck
[`pick`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pick
[`ids`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-ids
[`exists?`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F
[`average`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-average
[`minimum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-minimum
[`maximum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-maximum
[`sum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-sum
[`explain`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-explain
[MySQL5.7-explain]: https://dev.mysql.com/doc/refman/5.7/en/explain.html
[MySQL8-explain]: https://dev.mysql.com/doc/refman/8.0/en/explain.html
[MariaDB-explain]: https://mariadb.com/kb/en/analyze-and-explain-statements/
