**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 516604959485cfefb0e0d775d767699b
การเชื่อมต่อ Active Record Associations
==========================

เอกสารนี้เป็นคู่มือการใช้งานฟีเจอร์การเชื่อมต่อของ Active Record

หลังจากอ่านคู่มือนี้คุณจะรู้วิธีการ:

* ประกาศการเชื่อมต่อระหว่างโมเดล Active Record
* เข้าใจประเภทต่างๆ ของการเชื่อมต่อ Active Record
* ใช้เมธอดที่เพิ่มเข้ามาในโมเดลของคุณโดยการสร้างการเชื่อมต่อ

--------------------------------------------------------------------------------

ทำไมต้องการเชื่อมต่อ?
-----------------

ใน Rails, _การเชื่อมต่อ_ คือการเชื่อมโยงระหว่างโมเดล Active Record สองตัวเข้าด้วยกัน ทำไมเราต้องการการเชื่อมต่อระหว่างโมเดล? เพราะว่ามันทำให้การดำเนินการที่ซ้ำกันบ่งบอกในโค้ดของคุณง่ายและสะดวกยิ่งขึ้น

ตัวอย่างเช่น พิจารณาแอปพลิเคชัน Rails ที่เรียกใช้โมเดลสำหรับผู้เขียนและหนังสือ แต่ละผู้เขียนสามารถมีหนังสือได้หลายเล่ม

โดยไม่มีการเชื่อมต่อ การประกาศโมเดลจะดูเป็นแบบนี้:

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

ตอนนี้สมมติว่าเราต้องการเพิ่มหนังสือใหม่สำหรับผู้เขียนที่มีอยู่ เราต้องทำอย่างนี้:

```ruby
@book = Book.create(published_at: Time.now, author_id: @author.id)
```

หรือพิจารณาการลบผู้เขียนและให้แน่ใจว่าหนังสือทั้งหมดของเขาถูกลบด้วย:

```ruby
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

ด้วยการเชื่อมต่อ Active Record associations เราสามารถทำให้กระบวนการเหล่านี้ - และอื่นๆ - ง่ายขึ้นโดยการบอก Rails ให้รู้ว่ามีการเชื่อมโยงระหว่างโมเดลสองตัว นี่คือรหัสที่แก้ไขสำหรับการตั้งค่าผู้เขียนและหนังสือ:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

ด้วยการเปลี่ยนแปลงนี้ การสร้างหนังสือใหม่สำหรับผู้เขียนที่เฉพาะเจาะจงง่ายขึ้น:

```ruby
@book = @author.books.create(published_at: Time.now)
```

การลบผู้เขียนและหนังสือทั้งหมดง่ายมาก:

```ruby
@author.destroy
```

เพื่อเรียนรู้เพิ่มเติมเกี่ยวกับประเภทต่างๆ ของการเชื่อมต่อ อ่านส่วนถัดไปของคู่มือนี้ จากนั้นคือเคล็ดลับและเทคนิคสำหรับการทำงานกับการเชื่อมต่อ แล้วตามด้วยการอ้างอิงที่สมบูรณ์สำหรับเมธอดและตัวเลือกสำหรับการเชื่อมต่อใน Rails

ประเภทของการเชื่อมต่อ
-------------------------

Rails รองรับการเชื่อมต่อทั้งหมด 6 ประเภท แต่ละประเภทมีการใช้งานที่เฉพาะเจาะจง

นี่คือรายการของประเภทที่รองรับทั้งหมดพร้อมลิงก์ไปยังเอพีไอเอสของพวกเขาสำหรับข้อมูลเพิ่มเติมเกี่ยวกับวิธีการใช้งาน พารามิเตอร์ของเมธอด ฯลฯ

* [`belongs_to`][]
* [`has_one`][]
* [`has_many`][]
* [`has_many :through`][`has_many`]
* [`has_one :through`][`has_one`]
* [`has_and_belongs_to_many`][]

การเชื่อมต่อถูกนำมาใช้โดยการเรียกใช้แบบแมโคร ดังนั้นคุณสามารถเพิ่มคุณสมบัติให้กับโมเดลของคุณได้โดยการประกาศ ตัวอย่างเช่น โดยประกาศว่าโมเดลหนึ่ง `belongs_to` อีกตัวหนึ่งคุณสั่งให้ Rails รักษาข้อมูล [Primary Key](https://en.wikipedia.org/wiki/Primary_key)-[Foreign Key](https://en.wikipedia.org/wiki/Foreign_key) ระหว่างอินสแตนซ์ของโมเดลสองตัว และคุณยังได้รับเมธอดช่วยเพิ่มในโมเดลของคุณ

ในส่วนที่เหลือของคู่มือนี้ คุณจะเรียนรู้วิธีการประกาศและใช้งานรูปแบบต่างๆ ของการเชื่อมต่อ แต่ก่อนอื่นมาดูการแนะนำอย่างสั้นๆ เกี่ยวกับสถานการณ์ที่แต่ละประเภทของการเชื่อมต่อเหมาะสม


### การเชื่อมต่อ `belongs_to`

การเชื่อมต่อ [`belongs_to`][] จะตั้งค่าการเชื่อมโยงกับโมเดลอื่นโดยที่แต่ละอินสแตนซ์ของโมเดลที่ประกาศ "เป็นของ" อินสแตนซ์หนึ่งของโมเดลอื่น ตัวอย่างเช่น หากแอปพลิเคชันของคุณรวมถึงผู้เขียนและหนังสือ และแต่ละเล่มหนังสือสามารถกำหนดให้กับผู้เขียนได้เพียงหนึ่งคน คุณควรประกาศโมเดลหนังสือในลักษณะนี้:
```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

![แผนภาพความสัมพันธ์ belongs_to](images/association_basics/belongs_to.png)

หมายเหตุ: ความสัมพันธ์ `belongs_to` _ต้อง_ ใช้คำนามในรูปเอกพจน์ หากคุณใช้รูปพจน์ในตัวอย่างด้านบนสำหรับความสัมพันธ์ `author` ในโมเดล `Book` และพยายามสร้างอินสแตนซ์โดย `Book.create(authors: author)` คุณจะได้รับข้อความว่า "uninitialized constant Book::Authors" เนื่องจาก Rails จะสร้างชื่อคลาสอัตโนมัติจากชื่อความสัมพันธ์ หากชื่อความสัมพันธ์ถูกพยายามให้เป็นรูปพจน์อย่างไม่ถูกต้อง คลาสที่ได้จะเป็นรูปพจน์อย่างไม่ถูกต้องเช่นกัน

การเปลี่ยนแปลงที่เกี่ยวข้องอาจมีลักษณะดังนี้:

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

เมื่อใช้คนเดียว `belongs_to` จะสร้างการเชื่อมโยงแบบหนึ่งทางแบบหนึ่ง ดังนั้นแต่ละหนังสือในตัวอย่างด้านบน "รู้" ถึงผู้เขียน แต่ผู้เขียนไม่รู้เรื่องหนังสือของตน
ในการตั้งค่า [ความสัมพันธ์ทางสองทิศ](#bi-directional-associations) - ใช้ `belongs_to` ร่วมกับ `has_one` หรือ `has_many` ในโมเดลอื่น ในกรณีนี้คือโมเดล Author

`belongs_to` ไม่รับรองความสอดคล้องของการอ้างอิงหากตั้งค่า `optional` เป็น true ดังนั้นขึ้นอยู่กับกรณีการใช้งานคุณอาจต้องเพิ่มการจำกัดความสัมพันธ์ระดับฐานข้อมูลบนคอลัมน์อ้างอิง เช่น:

```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```

### ความสัมพันธ์ `has_one`

ความสัมพันธ์ [`has_one`][] แสดงว่าโมเดลอื่นมีการอ้างอิงไปยังโมเดลนี้ โมเดลนั้นสามารถเรียกดูได้ผ่านความสัมพันธ์นี้

ตัวอย่างเช่น หากแต่ละซัพพลายเออร์ในแอปพลิเคชันของคุณมีบัญชีเพียงหนึ่งบัญชี คุณสามารถประกาศโมเดลซัพพลายเออร์ดังนี้:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

ความแตกต่างหลักจาก `belongs_to` คือคอลัมน์ลิงก์ `supplier_id` จะอยู่ในตารางอื่น:

![แผนภาพความสัมพันธ์ has_one](images/association_basics/has_one.png)

เมื่อใช้คนเดียว `belongs_to` จะสร้างการเชื่อมโยงแบบหนึ่งทางแบบหนึ่ง ดังนั้นแต่ละหนังสือในตัวอย่างด้านบน "รู้" ถึงผู้เขียน แต่ผู้เขียนไม่รู้เรื่องหนังสือของตน
ในการตั้งค่า [ความสัมพันธ์ทางสองทิศ](#bi-directional-associations) - ใช้ `belongs_to` ร่วมกับ `has_one` หรือ `has_many` ในโมเดลอื่น ในกรณีนี้คือโมเดล Author

`belongs_to` ไม่รับรองความสอดคล้องของการอ้างอิงหากตั้งค่า `optional` เป็น true ดังนั้นขึ้นอยู่กับกรณีการใช้งานคุณอาจต้องเพิ่มการจำกัดความสัมพันธ์ระดับฐานข้อมูลบนคอลัมน์อ้างอิง เช่น:

```ruby
create_table :accounts do |t|
  t.belongs_to :supplier, index: { unique: true }, foreign_key: true
  # ...
end
```

ความสัมพันธ์นี้สามารถเป็น [ความสัมพันธ์ทางสองทิศ](#bi-directional-associations) เมื่อใช้ร่วมกับ `belongs_to` ในโมเดลอื่น

### ความสัมพันธ์ `has_many`

ความสัมพันธ์ [`has_many`][] คล้ายกับ `has_one` แต่แสดงถึงความสัมพันธ์หนึ่งต่อหลายกับโมเดลอื่น คุณจะพบความสัมพันธ์นี้บ่อยครั้งใน "ด้านอื่น" ของความสัมพันธ์ `belongs_to` ความสัมพันธ์นี้แสดงว่าแต่ละอินสแตนซ์ของโมเดลมีอินสแตนซ์ซึ่งเป็นของโมเดลอื่น ตัวอย่างเช่น ในแอปพลิเคชันที่มีผู้เขียนและหนังสือ โมเดลผู้เขียนสามารถประกาศได้ดังนี้:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

หมายเหตุ: ชื่อของโมเดลอื่นจะถูกพยายามให้เป็นรูปพจน์เมื่อประกาศความสัมพันธ์ `has_many`

![แผนภาพความสัมพันธ์ has_many](images/association_basics/has_many.png)

เมื่อใช้คนเดียว `belongs_to` จะสร้างการเชื่อมโยงแบบหนึ่งทางแบบหนึ่ง ดังนั้นแต่ละหนังสือในตัวอย่างด้านบน "รู้" ถึงผู้เขียน แต่ผู้เขียนไม่รู้เรื่องหนังสือของตน
ในการตั้งค่า [ความสัมพันธ์ทางสองทิศ](#bi-directional-associations) - ใช้ `belongs_to` ร่วมกับ `has_one` หรือ `has_many` ในโมเดลอื่น ในกรณีนี้คือโมเดล Author

`belongs_to` ไม่รับรองความสอดคล้องของการอ้างอิงหากตั้งค่า `optional` เป็น true ดังนั้นขึ้นอยู่กับกรณีการใช้งานคุณอาจต้องเพิ่มการจำกัดความสัมพันธ์ระดับฐานข้อมูลบนคอลัมน์อ้างอิง เช่น:

```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```

```ruby
class CreateAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```
ขึ้นอยู่กับกรณีการใช้งาน แต่ละครั้งควรสร้างดัชนีที่ไม่ซ้ำกันและตรวจสอบความสัมพันธ์แบบต่างประเทศ (foreign key constraint) บนคอลัมน์ author สำหรับตาราง books:

```ruby
create_table :books do |t|
  t.belongs_to :author, index: true, foreign_key: true
  # ...
end
```

### การเชื่อมโยงแบบ `has_many :through`

การเชื่อมโยงแบบ [`has_many :through`][`has_many`] ถูกใช้บ่อยครั้งเพื่อตั้งค่าการเชื่อมโยงแบบหลายต่อหลายกับโมเดลอื่น ๆ การเชื่อมโยงนี้แสดงว่าโมเดลที่ประกาศสามารถจับคู่กับอินสแตนซ์ของโมเดลอื่น ๆ ได้ศูนย์หรือมากกว่านั้นโดยผ่านโมเดลที่สาม ตัวอย่างเช่น พิจารณาที่คลินิกทางการแพทย์ที่ผู้ป่วยทำการนัดหมายเพื่อพบแพทย์ การประกาศการเชื่อมโยงที่เกี่ยวข้องอาจมีลักษณะดังนี้:

```ruby
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :physician
  belongs_to :patient
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end
```

![แผนภาพการเชื่อมโยงแบบ has_many :through](images/association_basics/has_many_through.png)

การเปลี่ยนแปลงที่เกี่ยวข้องอาจมีลักษณะดังนี้:

```ruby
class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :physicians do |t|
      t.string :name
      t.timestamps
    end

    create_table :patients do |t|
      t.string :name
      t.timestamps
    end

    create_table :appointments do |t|
      t.belongs_to :physician
      t.belongs_to :patient
      t.datetime :appointment_date
      t.timestamps
    end
  end
end
```

คอลเลกชันของโมเดลเชื่อมโยงสามารถจัดการได้ผ่าน [`has_many` association methods](#has-many-association-reference) ตัวอย่างเช่น หากคุณกำหนดค่า:

```ruby
physician.patients = patients
```

จะสร้างโมเดลเชื่อมโยงใหม่โดยอัตโนมัติสำหรับอ็อบเจกต์ที่เชื่อมโยงใหม่ หากมีบางส่วนที่ไม่มีอยู่ก่อนหน้านี้แล้ว แถวการเชื่อมโยงของพวกเขาจะถูกลบโดยอัตโนมัติ

คำเตือน: การลบโมเดลเชื่อมโยงโดยอัตโนมัติเป็นโดยตรง ไม่มีการเรียกใช้งาน destroy callbacks

การเชื่อมโยงแบบ `has_many :through` ยังเป็นประโยชน์ในการตั้งค่า "ทางลัด" ผ่านการเชื่อมโยง `has_many` ที่ซ้อนกัน ตัวอย่างเช่น หากเอกสารมีหลายส่วน และส่วนละเอียดมีหลายย่อหน้า คุณอาจต้องการรับคอลเลกชันที่เป็นส่วนย่อยทั้งหมดในเอกสาร คุณสามารถตั้งค่าได้ดังนี้:

```ruby
class Document < ApplicationRecord
  has_many :sections
  has_many :paragraphs, through: :sections
end

class Section < ApplicationRecord
  belongs_to :document
  has_many :paragraphs
end

class Paragraph < ApplicationRecord
  belongs_to :section
end
```

ด้วยการระบุ `through: :sections` Rails จะเข้าใจได้ว่า:

```ruby
@document.paragraphs
```

### การเชื่อมโยงแบบ `has_one :through`

การเชื่อมโยงแบบ [`has_one :through`][`has_one`] ตั้งค่าการเชื่อมโยงแบบหนึ่งต่อหนึ่งกับโมเดลอื่น ๆ การเชื่อมโยงนี้แสดงว่าโมเดลที่ประกาศสามารถจับคู่กับอินสแตนซ์หนึ่งของโมเดลอื่น ๆ ได้โดยผ่านโมเดลที่สาม ตัวอย่างเช่น หากแต่ละซัพพลายเออร์มีบัญชีหนึ่ง และแต่ละบัญชีเชื่อมโยงกับประวัติบัญชีหนึ่ง โมเดลซัพพลายเออร์อาจมีลักษณะดังนี้:

```ruby
class Supplier < ApplicationRecord
  has_one :account
  has_one :account_history, through: :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  has_one :account_history
end

class AccountHistory < ApplicationRecord
  belongs_to :account
end
```

![แผนภาพการเชื่อมโยงแบบ has_one :through](images/association_basics/has_one_through.png)

การเปลี่ยนแปลงที่เกี่ยวข้องอาจมีลักษณะดังนี้:

```ruby
class CreateAccountHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account
      t.integer :credit_rating
      t.timestamps
    end
  end
end
```

### การเชื่อมโยงแบบ `has_and_belongs_to_many`

การเชื่อมโยงแบบ [`has_and_belongs_to_many`][] สร้างการเชื่อมโยงหลายต่อหลายโดยตรงกับโมเดลอื่นๆ โดยไม่มีโมเดลกลาง การเชื่อมโยงนี้แสดงว่าแต่ละอินสแตนซ์ของโมเดลที่ประกาศอ้างอิงไปยังอินสแตนซ์หนึ่งหรือมากกว่านั้นของโมเดลอื่น ๆ ตัวอย่างเช่น หากแอปพลิเคชันของคุณรวมอะแสมบลีและชิ้นส่วน โดยที่แต่ละอะแสมบลีมีชิ้นส่วนหลายชิ้นและแต่ละชิ้นส่วนปรากฏในอะแสมบลีหลายอะแสมบลี คุณสามารถประกาศโมเดลได้ดังนี้:
```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

![has_and_belongs_to_many Association Diagram](images/association_basics/habtm.png)

การเขียน migration ที่เกี่ยวข้องอาจมีลักษณะดังนี้:

```ruby
class CreateAssembliesAndParts < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies do |t|
      t.string :name
      t.timestamps
    end

    create_table :parts do |t|
      t.string :part_number
      t.timestamps
    end

    create_table :assemblies_parts, id: false do |t|
      t.belongs_to :assembly
      t.belongs_to :part
    end
  end
end
```

### เลือกใช้ `belongs_to` หรือ `has_one`

หากคุณต้องการสร้างความสัมพันธ์แบบ one-to-one ระหว่างโมเดลสองตัว คุณจะต้องเพิ่ม `belongs_to` ในตัวหนึ่งและ `has_one` ในอีกตัวหนึ่ง คุณจะรู้ได้อย่างไรว่าตัวไหนคือตัวไหน?

ความแตกต่างอยู่ที่คุณวาง foreign key (มันจะอยู่ในตารางสำหรับคลาสที่ประกาศความสัมพันธ์ `belongs_to`) แต่คุณควรคิดถึงความหมายจริงของข้อมูลด้วย ความสัมพันธ์ `has_one` หมายถึงว่าสิ่งหนึ่งของคุณเป็นของคุณ - กล่าวคือสิ่งนั้นชี้กลับมาหาคุณ ตัวอย่างเช่น มันจะมีความเหมาะสมกว่าที่จะพูดว่าผู้ผลิตเป็นเจ้าของบัญชีมากกว่าบัญชีเป็นเจ้าของผู้ผลิต นี่แสดงให้เห็นว่าความสัมพันธ์ที่ถูกต้องคือดังนี้:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

การเขียน migration ที่เกี่ยวข้องอาจมีลักษณะดังนี้:

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.bigint  :supplier_id
      t.string  :account_number
      t.timestamps
    end

    add_index :accounts, :supplier_id
  end
end
```

หมายเหตุ: การใช้ `t.bigint :supplier_id` ทำให้ชื่อ foreign key ชัดเจนและชัดเจน ในรุ่นปัจจุบันของ Rails คุณสามารถซ่อนรายละเอียดการดำเนินการนี้ได้โดยใช้ `t.references :supplier` แทน

### เลือกใช้ `has_many :through` หรือ `has_and_belongs_to_many`

Rails มีวิธีการประกาศความสัมพันธ์ many-to-many ระหว่างโมเดลสองตัว วิธีแรกคือการใช้ `has_and_belongs_to_many` ซึ่งช่วยให้คุณสามารถทำการเชื่อมโยงโดยตรงได้:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

วิธีที่สองในการประกาศความสัมพันธ์ many-to-many คือการใช้ `has_many :through` ซึ่งทำการเชื่อมโยงผ่านโมเดล join:

```ruby
class Assembly < ApplicationRecord
  has_many :manifests
  has_many :parts, through: :manifests
end

class Manifest < ApplicationRecord
  belongs_to :assembly
  belongs_to :part
end

class Part < ApplicationRecord
  has_many :manifests
  has_many :assemblies, through: :manifests
end
```

กฎง่าย ๆ คือคุณควรตั้งค่าความสัมพันธ์ `has_many :through` หากคุณต้องการทำงานกับโมเดลความสัมพันธ์เป็นตัวแยกต่างหาก หากคุณไม่ต้องการทำอะไรกับโมเดลความสัมพันธ์ อาจง่ายกว่าที่จะตั้งค่าความสัมพันธ์ `has_and_belongs_to_many` (แต่คุณจะต้องจำไว้ว่าต้องสร้างตารางเชื่อมต่อในฐานข้อมูล)

คุณควรใช้ `has_many :through` หากคุณต้องการการตรวจสอบความถูกต้อง การเรียกใช้ callback หรือแอตทริบิวต์เพิ่มเติมในโมเดล join

### ความสัมพันธ์หลายรูปแบบ

การสัมพันธ์ที่ซับซ้อนขึ้นเล็กน้อยคือ _ความสัมพันธ์หลายรูปแบบ_ ด้วยความสัมพันธ์หลายรูปแบบ โมเดลสามารถเป็นส่วนหนึ่งของโมเดลอื่นได้มากกว่าหนึ่งโมเดลในความสัมพันธ์เดียวกัน ตัวอย่างเช่น คุณอาจมีโมเดลรูปภาพที่เป็นส่วนหนึ่งของโมเดลพนักงานหรือโมเดลผลิตภัณฑ์ นี่คือวิธีที่สามารถประกาศได้:
```ruby
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end
```

คุณสามารถพิจารณาการประกาศ `belongs_to` ที่ polymorphic เป็นการตั้งค่าอินเตอร์เฟซที่โมเดลอื่น ๆ สามารถใช้ได้ จากตัวอย่างของโมเดล `Employee` คุณสามารถเรียกดูคอลเลกชันของรูปภาพได้: `@employee.pictures` 

เช่นเดียวกัน คุณสามารถเรียกดู `@product.pictures` 

หากคุณมีตัวอย่างของโมเดล `Picture` คุณสามารถเข้าถึงโมเดลแม่ของมันผ่าน `@picture.imageable` ในการทำงานนี้ คุณจำเป็นต้องประกาศคอลัมน์ foreign key และคอลัมน์ประเภทในโมเดลที่ประกาศอินเตอร์เฟซ polymorphic:

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string  :name
      t.bigint  :imageable_id
      t.string  :imageable_type
      t.timestamps
    end

    add_index :pictures, [:imageable_type, :imageable_id]
  end
end
```

การเปลี่ยนแปลงนี้สามารถทำให้ง่ายขึ้นได้โดยใช้รูปแบบ `t.references`:

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true
      t.timestamps
    end
  end
end
```

![Polymorphic Association Diagram](images/association_basics/polymorphic.png)

### Self Joins

ในการออกแบบโมเดลข้อมูล คุณอาจพบโมเดลที่ควรมีความสัมพันธ์กับตัวเอง ตัวอย่างเช่น คุณอาจต้องการเก็บข้อมูลของพนักงานทั้งหมดในโมเดลฐานข้อมูลเดียว แต่ต้องการสามารถติดตามความสัมพันธ์ เช่น ระหว่างผู้จัดการและลูกน้อง สถานการณ์นี้สามารถจัดแบบโมเดลที่มีการเชื่อมต่อตัวเองเองได้:

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true
end
```

ด้วยการตั้งค่านี้ คุณสามารถเรียกดู `@employee.subordinates` และ `@employee.manager` 

ในการสร้างตารางในการเปลี่ยนแปลง/สเครีย์ของคุณ คุณจะเพิ่มคอลัมน์ references ไปยังโมเดลเอง:

```ruby
class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :manager, foreign_key: { to_table: :employees }
      t.timestamps
    end
  end
end
```

หมายเหตุ: ตัวเลือก `to_table` ที่ถูกส่งผ่านไปยัง `foreign_key` และอื่น ๆ อธิบายไว้ใน [`SchemaStatements#add_reference`][connection.add_reference].


เคล็ดลับ ที่เป็นประโยชน์ และคำเตือน
--------------------------

นี่คือสิ่งที่คุณควรรู้เพื่อใช้งาน Active Record associations อย่างมีประสิทธิภาพในแอปพลิเคชัน Rails ของคุณ:

* การควบคุมการแคช
* การหลีกเลี่ยงชื่อซ้ำกัน
* การอัปเดต schema
* การควบคุมขอบเขตของการเชื่อมโยง
* การเชื่อมโยงแบบสองทิศทาง

### การควบคุมการแคช

ทุกเมธอดที่เกี่ยวข้องกับการเชื่อมโยงถูกสร้างขึ้นโดยใช้แคช ซึ่งจะเก็บผลลัพธ์ของคิวรีล่าสุดเอาไว้สำหรับการดำเนินการต่อไป แคชถูกแบ่งปันระหว่างเมธอดทั้งหมด ตัวอย่างเช่น:

```ruby
# ดึงข้อมูลหนังสือจากฐานข้อมูล
author.books.load

# ใช้ข้อมูลที่แคชไว้
author.books.size

# ใช้ข้อมูลที่แคชไว้
author.books.empty?
```

แต่ถ้าคุณต้องการโหลดแคชใหม่ เพราะข้อมูลอาจถูกเปลี่ยนแปลงโดยส่วนอื่นของแอปพลิเคชัน คุณสามารถเรียกใช้ `reload` บนการเชื่อมโยง:

```ruby
# ดึงข้อมูลหนังสือจากฐานข้อมูล
author.books.load

# ใช้ข้อมูลที่แคชไว้
author.books.size

# ล้างข้อมูลที่แคชไว้และเรียกข้อมูลจากฐานข้อมูลใหม่
author.books.reload.empty?
```

### การหลีกเลี่ยงชื่อซ้ำกัน

คุณไม่สามารถใช้ชื่อใด ๆ สำหรับการเชื่อมโยงของคุณ การสร้างการเชื่อมโยงจะเพิ่มเมธอดที่มีชื่อนั้นในโมเดล ดังนั้น ไม่ควรตั้งชื่อการเชื่อมโยงที่มีชื่อที่ใช้สำหรับเมธอดของ `ActiveRecord::Base` การเชื่อมโยงจะทับเมธอดฐานและทำให้เกิดข้อผิดพลาด ตัวอย่างเช่น `attributes` หรือ `connection` คือชื่อที่ไม่เหมาะสมสำหรับการเชื่อมโยง
### การอัปเดต Schema

การเชื่อมโยง (Associations) เป็นสิ่งที่มีประโยชน์อย่างมาก แต่มันไม่ใช่เวทมนตร์ คุณต้องรับผิดชอบในการบำรุงรักษา schema ของฐานข้อมูลของคุณให้ตรงกับการเชื่อมโยง (associations) ของคุณ ในการปฏิบัติจริงนั้น คุณต้องทำสองสิ่ง ขึ้นอยู่กับประเภทของการเชื่อมโยงที่คุณกำลังสร้าง สำหรับการเชื่อมโยง `belongs_to` คุณต้องสร้าง foreign keys และสำหรับการเชื่อมโยง `has_and_belongs_to_many` คุณต้องสร้างตารางเชื่อมโยงที่เหมาะสม

#### การสร้าง Foreign Keys สำหรับการเชื่อมโยง `belongs_to`

เมื่อคุณประกาศการเชื่อมโยง `belongs_to` คุณต้องสร้าง foreign keys ตามที่เหมาะสม ตัวอย่างเช่น พิจารณาโมเดลนี้:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

การประกาศนี้ต้องมีการสร้างคอลัมน์ foreign key ที่เกี่ยวข้องในตาราง books สำหรับตารางใหม่ การเปลี่ยนแปลงอาจมีลักษณะเช่นนี้:

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.datetime   :published_at
      t.string     :book_number
      t.references :author
    end
  end
end
```

ในขณะที่สำหรับตารางที่มีอยู่อาจมีลักษณะเช่นนี้:

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[7.1]
  def change
    add_reference :books, :author
  end
end
```

หมายเหตุ: หากคุณต้องการ [บังคับให้ความสอดคล้องในระดับฐานข้อมูล][foreign_keys] เพิ่มตัวเลือก `foreign_key: true` ในการประกาศคอลัมน์ 'reference' ด้านบน

#### การสร้างตารางเชื่อมโยงสำหรับการเชื่อมโยง `has_and_belongs_to_many`

หากคุณสร้างการเชื่อมโยง `has_and_belongs_to_many` คุณต้องสร้างตารางเชื่อมโยงโดยชัดเจน ยกเว้นชื่อของตารางเชื่อมโยงถูกระบุโดยใช้ตัวเลือก `:join_table`  Active Record จะสร้างชื่อโดยใช้ลำดับตามคำสั่งภาษา ดังนั้นการเชื่อมโยงระหว่างโมเดลผู้เขียนและโมเดลหนังสือจะให้ชื่อตารางเชื่อมโยงเริ่มต้นเป็น "authors_books" เนื่องจาก "a" มีความสำคัญมากกว่า "b" ในการเรียงลำดับตามคำสั่งภาษา

คำเตือน: ลำดับความสำคัญระหว่างชื่อโมเดลคำนวณโดยใช้ตัวดำเนินการ `<=>` สำหรับ `String` นั่นหมายความว่าหากสตริงมีความยาวที่แตกต่างกัน และสตริงเหล่านั้นเท่ากันเมื่อเปรียบเทียบจนถึงความยาวที่สั้นที่สุด แล้วสตริงที่ยาวกว่าจะถูกพิจารณาว่ามีความสำคัญทางการเรียงลำดับสูงกว่าสตริงที่สั้นกว่า ตัวอย่างเช่น คุณคาดหวังว่าตาราง "paper_boxes" และ "papers" จะสร้างชื่อตารางเชื่อมโยงเป็น "papers_paper_boxes" เนื่องจากความยาวของชื่อ "paper_boxes" แต่ในความเป็นจริงแล้วจะสร้างชื่อตารางเชื่อมโยงเป็น "paper_boxes_papers" (เนื่องจากเครื่องหมาย underscore '\_' มีค่าน้อยกว่า 's' ในการเรียงลำดับตามคำสั่งภาษาทั่วไป)

ไม่ว่าชื่อจะเป็นอย่างไร คุณต้องสร้างตารางเชื่อมโยงด้วยการโยนมานูนอย่างเหมาะสม ตัวอย่างเช่น พิจารณาการเชื่อมโยงเหล่านี้:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

การเชื่อมโยงเหล่านี้ต้องมีการสร้าง migration เพื่อสร้างตาราง `assemblies_parts` ตารางนี้ควรถูกสร้างโดยไม่มี primary key:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.bigint :assembly_id
      t.bigint :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end
```

เราส่ง `id: false` ไปยัง `create_table` เพราะตารางนั้นไม่แทนโมเดล นั่นเป็นสิ่งที่จำเป็นสำหรับการเชื่อมโยงที่จะทำงานอย่างถูกต้อง หากคุณสังเกตพฤติกรรมแปลกๆ ในการเชื่อมโยง `has_and_belongs_to_many` เช่น ID ของโมเดลที่ผิดพลาด หรือข้อยกเว้นเกี่ยวกับ ID ที่ขัดแย้งกัน โอกาสที่คุณจะลืมส่วนนี้ได้มีอยู่

เพื่อความง่าย คุณยังสามารถใช้เมธอด `create_join_table` ได้:
```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :assemblies, :parts do |t|
      t.index :assembly_id
      t.index :part_id
    end
  end
end
```

### การควบคุมขอบเขตของการเชื่อมโยง

โดยค่าเริ่มต้น การเชื่อมโยงจะค้นหาวัตถุภายในขอบเขตของโมดูลปัจจุบันเท่านั้น สิ่งนี้สำคัญเมื่อคุณประกาศโมเดล Active Record ภายในโมดูล เช่น:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end

    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

สิ่งนี้จะทำงานได้ดี เนื่องจากทั้งคลาส `Supplier` และ `Account` ถูกกำหนดภายในขอบเขตเดียวกัน แต่ตัวอย่างต่อไปนี้จะ _ไม่_ ทำงาน เนื่องจาก `Supplier` และ `Account` ถูกกำหนดในขอบเขตที่แตกต่างกัน:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

ในการเชื่อมโยงโมเดลกับโมเดลในเนมสเปซที่แตกต่างกัน คุณต้องระบุชื่อคลาสเต็มในการประกาศการเชื่อมโยงของคุณ:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account,
        class_name: "MyApplication::Billing::Account"
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier,
        class_name: "MyApplication::Business::Supplier"
    end
  end
end
```

### การเชื่อมโยงสองทิศทาง

การทำงานของการเชื่อมโยงส่วนใหญ่จะเป็นไปในทิศทางสองทิศทาง ซึ่งต้องประกาศในโมเดลสองคลาสที่แตกต่างกัน:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Active Record จะพยายามระบุโมเดลสองตัวนี้ว่ามีการเชื่อมโยงสองทิศทางโดยอัตโนมัติ โดยใช้ชื่อการเชื่อมโยง ข้อมูลเหล่านี้ช่วยให้ Active Record:

* ป้องกันการค้นหาข้อมูลที่โหลดแล้วซ้ำซ้อน:

    ```irb
    irb> author = Author.first
    irb> author.books.all? do |book|
    irb>   book.author.equal?(author) # ไม่มีการค้นหาเพิ่มเติมที่นี่
    irb> end
    => true
    ```

* ป้องกันข้อมูลที่ไม่สอดคล้องกัน (เนื่องจากมีเพียงหนึ่งสำเนาของอ็อบเจกต์ `Author` ที่ถูกโหลด):

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Changed Name"
    irb> author.name == book.author.name
    => true
    ```

* บันทึกการเชื่อมโยงโดยอัตโนมัติในกรณีที่มากกว่านี้:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => true
    ```

* ตรวจสอบความถูกต้องของการเชื่อมโยง (การตรวจสอบ [การมีอยู่](active_record_validations.html#presence) และ [การไม่มีอยู่](active_record_validations.html#absence) ของการเชื่อมโยง) ในกรณีที่มากกว่านี้:

    ```irb
    irb> book = Book.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => true
    ```

Active Record รองรับการระบุโมเดลสองตัวที่เชื่อมโยงกันโดยอัตโนมัติสำหรับส่วนใหญ่ของการเชื่อมโยงที่มีชื่อมาตรฐาน อย่างไรก็ตาม การเชื่อมโยงสองทิศทางที่มีตัวเลือก `:through` หรือ `:foreign_key` จะไม่ระบุโดยอัตโนมัติ

ขอบเขตที่กำหนดเองบนการเชื่อมโยงที่ตรงข้ามกันยังป้องกันการระบุโดยอัตโนมัติ รวมถึงขอบเขตที่กำหนดเองบนการเชื่อมโยงเอง ยกเว้นถ้า [`config.active_record.automatic_scope_inversing`][] ถูกตั้งค่าเป็น true (ค่าเริ่มต้นสำหรับแอปพลิเคชันใหม่)

ตัวอย่างเช่น พิจารณาการประกาศโมเดลต่อไปนี้:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

เนื่องจากตัวเลือก `:foreign_key` Active Record จะไม่ระบุการเชื่อมโยงสองทิศทางโดยอัตโนมัติอีกต่อไป สิ่งนี้อาจทำให้แอปพลิเคชันของคุณ:

* ดำเนินการค้นหาข้อมูลที่ซ้ำซ้อน (ในตัวอย่างนี้จะทำให้เกิดการค้นหา N+1):

    ```irb
    irb> author = Author.first
    irb> author.books.any? do |book|
    irb>   book.author.equal?(author) # ส่งคำสั่งค้นหาผู้เขียนสำหรับแต่ละเล่ม
    irb> end
    => false
    ```

* อ้างอิงหลายสำเนาของโมเดลที่มีข้อมูลไม่สม่ำเสมอ:

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "ชื่อที่เปลี่ยนแปลง"
    irb> author.name == book.author.name
    => false
    ```

* ไม่สามารถบันทึกผูกข้อมูลอัตโนมัติได้:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => false
    ```

* ไม่สามารถตรวจสอบความสมบูรณ์หรือความขาดหายได้:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["ต้องมีผู้เขียน"]
    ```

Active Record ให้คุณใช้ตัวเลือก `:inverse_of` เพื่อประกาศความสัมพันธ์สองทิศทางโดยชัดเจน:

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

โดยรวม `:inverse_of` ในการประกาศความสัมพันธ์ `has_many` จะทำให้ Active Record รู้จักความสัมพันธ์ทางทิศทางสองทิศทางและทำงานเหมือนตัวอย่างเริ่มต้นด้านบน

อ้างอิงความสัมพันธ์อย่างละเอียด
------------------------------

ส่วนต่อไปนี้ให้รายละเอียดของแต่ละประเภทของความสัมพันธ์ รวมถึงเมธอดที่เพิ่มเข้ามาและตัวเลือกที่คุณสามารถใช้เมื่อประกาศความสัมพันธ์

### การอ้างอิง `belongs_to`

ในทางด้านฐานข้อมูล ความสัมพันธ์ `belongs_to` หมายถึงว่าตารางของโมเดลนี้มีคอลัมน์ที่แทนอ้างอิงไปยังตารางอื่น
สามารถใช้สร้างความสัมพันธ์หนึ่งต่อหนึ่งหรือหนึ่งต่อมากได้ ขึ้นอยู่กับการตั้งค่า
หากตารางของคลาสอื่นมีการอ้างอิงในความสัมพันธ์หนึ่งต่อหนึ่ง คุณควรใช้ `has_one` แทน

#### เมธอดที่เพิ่มเข้ามาโดย `belongs_to`

เมื่อคุณประกาศความสัมพันธ์ `belongs_to` คลาสที่ประกาศจะได้รับเมธอดที่เกี่ยวข้องกับความสัมพันธ์ 8 เมธอดอัตโนมัติ:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`
* `association_changed?`
* `association_previously_changed?`

ในเมธอดทั้งหมดเหล่านี้ `association` จะถูกแทนที่ด้วยสัญลักษณ์ที่ถูกส่งผ่านเป็นอาร์กิวเมนต์แรกใน `belongs_to` ตัวอย่างเช่น โดยให้คำสั่ง:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

แต่ละอินสแตนซ์ของโมเดล `Book` จะมีเมธอดเหล่านี้:

* `author`
* `author=`
* `build_author`
* `create_author`
* `create_author!`
* `reload_author`
* `reset_author`
* `author_changed?`
* `author_previously_changed?`

หมายเหตุ: เมื่อเริ่มต้นการสร้างความสัมพันธ์ `has_one` หรือ `belongs_to` ใหม่คุณต้องใช้คำนำหน้า `build_` เพื่อสร้างความสัมพันธ์ แทนที่จะใช้เมธอด `association.build` ที่ใช้สำหรับความสัมพันธ์ `has_many` หรือ `has_and_belongs_to_many` ในการสร้างความสัมพันธ์ สำหรับการสร้างความสัมพันธ์ใหม่ให้ใช้คำนำหน้า `create_`

##### `association`

เมธอด `association` จะคืนออบเจกต์ที่เกี่ยวข้อง หากไม่พบออบเจกต์ที่เกี่ยวข้องจะคืนค่า `nil`

```ruby
@author = @book.author
```

หากออบเจกต์ที่เกี่ยวข้องถูกดึงข้อมูลมาแล้วสำหรับออบเจกต์นี้ จะคืนเวอร์ชันที่แคชไว้ หากต้องการเขียนทับพฤติกรรมนี้ (และบังคับให้อ่านฐานข้อมูล) ให้เรียกใช้ `#reload_association` บนออบเจกต์หลัก

```ruby
@author = @book.reload_author
```

เพื่อยกเลิกการแคชเวอร์ชันของออบเจกต์ที่เกี่ยวข้อง - ทำให้การเข้าถึงครั้งถัดไป (หากมี) จะคิวรีจากฐานข้อมูล - เรียกใช้ `#reset_association` บนออบเจกต์หลัก

```ruby
@book.reset_author
```

##### `association=(associate)`

เมธอด `association=` จะกำหนดออบเจกต์ที่เกี่ยวข้องกับออบเจกต์นี้ ในพื้นหลัง นี่หมายความว่าจะดึงคีย์หลักจากออบเจกต์ที่เกี่ยวข้องและกำหนดคีย์ต่างประเทศของออบเจกต์นี้ให้เป็นค่าเดียวกัน
```ruby
@book.author = @author
```

##### `build_association(attributes = {})`

เมธอด `build_association` จะสร้างออบเจ็กต์ใหม่ของประเภทที่เกี่ยวข้อง ออบเจ็กต์นี้จะถูกสร้างขึ้นจากแอตทริบิวต์ที่ผ่านมา และลิงค์ผ่านคีย์ต่างประเทศของออบเจ็กต์นี้จะถูกตั้งค่า แต่ออบเจ็กต์ที่เกี่ยวข้องจะยังไม่ถูกบันทึกไว้

```ruby
@author = @book.build_author(author_number: 123,
                             author_name: "John Doe")
```

##### `create_association(attributes = {})`

เมธอด `create_association` จะสร้างออบเจ็กต์ใหม่ของประเภทที่เกี่ยวข้อง ออบเจ็กต์นี้จะถูกสร้างขึ้นจากแอตทริบิวต์ที่ผ่านมา และลิงค์ผ่านคีย์ต่างประเทศของออบเจ็กต์นี้จะถูกตั้งค่า และเมื่อผ่านการตรวจสอบทั้งหมดที่ระบุในโมเดลที่เกี่ยวข้อง ออบเจ็กต์ที่เกี่ยวข้องจะถูกบันทึกไว้

```ruby
@author = @book.create_author(author_number: 123,
                              author_name: "John Doe")
```

##### `create_association!(attributes = {})`

ทำเหมือนกับ `create_association` ด้านบน แต่จะเรียกใช้ `ActiveRecord::RecordInvalid` ถ้าเกิดข้อผิดพลาดในการบันทึก

##### `association_changed?`

เมธอด `association_changed?` จะคืนค่าเป็นจริงถ้ามีวัตถุเกี่ยวข้องใหม่ที่ถูกกำหนดค่าและคีย์ต่างประเทศจะถูกอัปเดตในการบันทึกถัดไป

```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.author_changed? # => true

@book.save!
@book.author_changed? # => false
```

##### `association_previously_changed?`

เมธอด `association_previously_changed?` จะคืนค่าเป็นจริงถ้าการบันทึกก่อนหน้าได้อัปเดตการอ้างอิงวัตถุเกี่ยวข้องให้ชี้ไปที่วัตถุเกี่ยวข้องใหม่

```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_previously_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.save!
@book.author_previously_changed? # => true
```

#### ตัวเลือกสำหรับ `belongs_to`

ในขณะที่ Rails ใช้ค่าเริ่มต้นที่ฉลาดซึ่งจะทำงานได้ดีในสถานการณ์ส่วนใหญ่ อาจมีเวลาที่คุณต้องการปรับแต่งพฤติกรรมของการอ้างอิงสมาชิก `belongs_to` ได้อย่างง่ายดายโดยการส่งต่อค่าตัวเลือกและบล็อกขอบเขตเมื่อคุณสร้างการอ้างอิง ตัวอย่างเช่น การอ้างอิงนี้ใช้ตัวเลือกสองตัวดังต่อไปนี้:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at,
    counter_cache: true
end
```

การอ้างอิง [`belongs_to`][] รองรับตัวเลือกเหล่านี้:

* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:primary_key`
* `:inverse_of`
* `:polymorphic`
* `:touch`
* `:validate`
* `:optional`

##### `:autosave`

หากคุณตั้งค่าตัวเลือก `:autosave` เป็น `true` Rails จะบันทึกวัตถุสมาชิกที่โหลดและทำลายวัตถุที่ถูกทำเครื่องหมายว่าจะถูกทำลายเมื่อคุณบันทึกวัตถุหลัก การตั้งค่า `:autosave` เป็น `false` ไม่ได้หมายความว่าไม่ตั้งค่าตัวเลือก `:autosave` หากไม่มีตัวเลือก `:autosave` อยู่ วัตถุที่อ้างอิงใหม่จะถูกบันทึก แต่วัตถุที่อ้างอิงที่อัปเดตจะไม่ถูกบันทึก

##### `:class_name`

หากชื่อของโมเดลอื่นไม่สามารถได้มาจากชื่อการอ้างอิงคุณสามารถใช้ตัวเลือก `:class_name` เพื่อระบุชื่อโมเดล ตัวอย่างเช่น หากหนังสืออ้างอิงผู้เขียน แต่ชื่อจริงของโมเดลที่มีผู้เขียนคือ `Patron` คุณสามารถตั้งค่าได้ดังนี้:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron"
end
```

##### `:counter_cache`

ตัวเลือก `:counter_cache` สามารถใช้ในการค้นหาจำนวนวัตถุที่เกี่ยวข้องได้อย่างมีประสิทธิภาพมากขึ้น พิจารณาโมเดลเหล่านี้:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :books
end
```

ด้วยการประกาศเหล่านี้ การขอค่า `@author.books.size` จะต้องทำการเรียกใช้ฐานข้อมูลเพื่อทำการค้นหา `COUNT(*)` query หากต้องการหลีกเลี่ยงการเรียกใช้งานนี้ คุณสามารถเพิ่มการเก็บค่าจำนวนเล่มหนังสือลงในโมเดลที่เกี่ยวข้องได้ดังนี้:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end

class Author < ApplicationRecord
  has_many :books
end
```

ด้วยการประกาศนี้ Rails จะอัปเดตค่าแคชและส่งค่านั้นกลับมาในการเรียกใช้งาน `size` method

แม้ว่าตัวเลือก `:counter_cache` จะถูกระบุในโมเดลที่รวมการประกาศ `belongs_to` แต่คอลัมน์จริงๆ ต้องถูกเพิ่มในโมเดลที่เกี่ยวข้อง (`has_many`) ในกรณีข้างต้น คุณจะต้องเพิ่มคอลัมน์ที่ชื่อว่า `books_count` ในโมเดล `Author`

คุณสามารถแทนที่ชื่อคอลัมน์เริ่มต้นได้โดยระบุชื่อคอลัมน์ที่กำหนดเองในการประกาศ `counter_cache` แทนที่ `true` ตัวอย่างเช่น เพื่อใช้ `count_of_books` แทน `books_count`:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: :count_of_books
end

class Author < ApplicationRecord
  has_many :books
end
```

หมายเหตุ: คุณเพียงแค่ต้องระบุตัวเลือก `:counter_cache` บนด้าน `belongs_to` ของความสัมพันธ์

คอลัมน์แคชเคาท์เตอร์ถูกเพิ่มในรายการแอตทริบิวต์อ่านอย่างเดียวของโมเดลเจ้าของผ่าน `attr_readonly`

หากเนื่องจากเหตุผลใดเหตุใดคุณเปลี่ยนค่าของคีย์หลักของโมเดลเจ้าของ และไม่ได้อัปเดตคีย์ต่างประเทศของโมเดลที่นับจำนวน แล้วแคชเคาท์เตอร์อาจมีข้อมูลที่ล้าสมัย กล่าวคือ โมเดลที่ไม่มีเจ้าของจะถูกนับเข้าไปในค่านับ ในการแก้ไขค่าแคชเคาท์เตอร์ที่ล้าสมัย ให้ใช้ [`reset_counters`][]

##### `:dependent`

หากคุณตั้งค่าตัวเลือก `:dependent` เป็น:

* `:destroy` เมื่อวัตถุถูกทำลาย `destroy` จะถูกเรียกใช้งานกับวัตถุที่เกี่ยวข้อง
* `:delete` เมื่อวัตถุถูกทำลาย วัตถุที่เกี่ยวข้องทั้งหมดจะถูกลบโดยตรงจากฐานข้อมูลโดยไม่เรียกใช้งานเมธอด `destroy` ของวัตถุเหล่านั้น
* `:destroy_async` เมื่อวัตถุถูกทำลาย จะมีการเพิ่มงาน `ActiveRecord::DestroyAssociationAsyncJob` ลงในคิว ซึ่งจะเรียกใช้งานเมธอด `destroy` กับวัตถุที่เกี่ยวข้อง Active Job ต้องถูกตั้งค่าให้ทำงาน อย่าใช้ตัวเลือกนี้หากความสัมพันธ์ได้รับการสนับสนุนด้วยข้อจำกัดของคีย์ต่างประเทศในฐานข้อมูลของคุณ การดำเนินการของข้อจำกัดคีย์ต่างประเทศจะเกิดขึ้นภายในการทำธุรกรรมเดียวกันที่ลบเจ้าของ

คำเตือน: คุณไม่ควรระบุตัวเลือกนี้ในความสัมพันธ์ `belongs_to` ที่เชื่อมโยงกับความสัมพันธ์ `has_many` ในคลาสอื่น การทำเช่นนี้อาจทำให้เกิดข้อมูลที่ไม่มีเจ้าของในฐานข้อมูลของคุณ

##### `:foreign_key`

ตามปกติ Rails จะถือว่าคอลัมน์ที่ใช้เก็บคีย์ต่างประเทศในโมเดลนี้คือชื่อของความสัมพันธ์พร้อมกับเพิ่มเติม `_id` ตัวเลือก `:foreign_key` ช่วยให้คุณสามารถกำหนดชื่อคีย์ต่างประเทศโดยตรงได้:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                      foreign_key: "patron_id"
end
```

เคล็ดลับ: ในทุกกรณี Rails จะไม่สร้างคอลัมน์คีย์ต่างประเทศให้คุณ คุณต้องกำหนดคอลัมน์เหล่านี้โดยชัดเจนในการทำฐานข้อมูล

##### `:primary_key`

ตามปกติ Rails จะถือว่าคอลัมน์ `id` ถูกใช้เป็นคีย์หลักของตาราง ตัวเลือก `:primary_key` ช่วยให้คุณสามารถระบุคอลัมน์อื่นได้

ตัวอย่างเช่น หากเรามีตาราง `users` โดยใช้ `guid` เป็นคีย์หลัก หากเราต้องการตาราง `todos` ที่เก็บคีย์ต่างประเทศ `user_id` ในคอลัมน์ `guid` เราสามารถใช้ `primary_key` เพื่อทำได้ดังนี้:
```ruby
class User < ApplicationRecord
  self.primary_key = 'guid' # คีย์หลักคือ guid ไม่ใช่ id
end

class Todo < ApplicationRecord
  belongs_to :user, primary_key: 'guid'
end
```

เมื่อเรา execute `@user.todos.create` แล้ว `@todo` จะมีค่า `user_id` เป็นค่า `guid` ของ `@user`.

##### `:inverse_of`

ตัวเลือก `:inverse_of` ระบุชื่อของ `has_many` หรือ `has_one` association ที่เป็น inverse ของ association นี้
ดูส่วน [bi-directional association](#bi-directional-associations) เพื่อรายละเอียดเพิ่มเติม

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:polymorphic`

การส่งค่า `true` ให้กับตัวเลือก `:polymorphic` แสดงว่านี่เป็น polymorphic association การสร้าง polymorphic associations ได้ถูกพูดถึงอย่างละเอียดในส่วนที่ผ่านมา <a href="#polymorphic-associations">ในเอกสารนี้</a>.

##### `:touch`

หากคุณตั้งค่าตัวเลือก `:touch` เป็น `true` แล้ว timestamp `updated_at` หรือ `updated_on` บน associated object จะถูกตั้งค่าเป็นเวลาปัจจุบันเมื่อ object นี้ถูกบันทึกหรือลบ:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: true
end

class Author < ApplicationRecord
  has_many :books
end
```

ในกรณีนี้ การบันทึกหรือลบหนังสือจะอัปเดต timestamp บน author ที่เกี่ยวข้อง คุณยังสามารถระบุ attribute timestamp ที่เฉพาะเพื่ออัปเดตได้:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at
end
```

##### `:validate`

หากคุณตั้งค่าตัวเลือก `:validate` เป็น `true` แล้ว associated objects ใหม่จะถูกตรวจสอบความถูกต้องเมื่อคุณบันทึก object นี้ โดยค่าเริ่มต้นคือ `false`: associated objects ใหม่จะไม่ถูกตรวจสอบความถูกต้องเมื่อบันทึก object นี้

##### `:optional`

หากคุณตั้งค่าตัวเลือก `:optional` เป็น `true` แล้วการตรวจสอบความมีอยู่ของ associated object จะไม่ถูกตรวจสอบ ค่าเริ่มต้นของตัวเลือกนี้คือ `false`.

#### Scopes สำหรับ `belongs_to`

บางครั้งคุณอาจต้องการปรับแต่งคำสั่ง query ที่ใช้โดย `belongs_to` การปรับแต่งเหล่านี้สามารถทำได้ผ่าน scope block ตัวอย่างเช่น:

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

คุณสามารถใช้ [querying methods](active_record_querying.html) มาตรฐานภายใน scope block ได้ ต่อไปนี้คือตัวอย่าง:

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

เมธอด `where` ช่วยให้คุณระบุเงื่อนไขที่ associated object ต้องตรงกัน

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

##### `includes`

คุณสามารถใช้เมธอด `includes` เพื่อระบุ second-order associations ที่ควรถูก eager-loaded เมื่อใช้ association นี้ ตัวอย่างเช่น พิจารณา model เหล่านี้:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

หากคุณใช้การเรียกข้อมูล author โดยตรงจาก chapters (`@chapter.book.author`) คุณสามารถทำให้โค้ดของคุณมีประสิทธิภาพมากขึ้นโดยการรวม authors ใน association จาก chapters ไปยัง books:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book, -> { includes :author }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

หมายเหตุ: ไม่จำเป็นต้องใช้ `includes` สำหรับ immediate associations - นั่นคือ หากคุณมี `Book belongs_to :author` แล้ว author จะถูก eager-loaded โดยอัตโนมัติเมื่อมีความจำเป็น
##### `readonly`

หากคุณใช้ `readonly` แล้ววัตถุที่เกี่ยวข้องจะเป็นแบบอ่านอย่างเดียวเมื่อเรียกดูผ่านการเชื่อมโยง

##### `select`

เมธอด `select` ช่วยให้คุณสามารถแทนที่คำสั่ง SQL `SELECT` ที่ใช้ในการเรียกดูข้อมูลเกี่ยวกับวัตถุที่เกี่ยวข้องได้ โดยค่าเริ่มต้น Rails จะเรียกดูคอลัมน์ทั้งหมด

เคล็ดลับ: หากคุณใช้เมธอด `select` ในการเชื่อมโยง `belongs_to` คุณควรตั้งค่า `:foreign_key` เพื่อให้ได้ผลลัพธ์ที่ถูกต้อง

#### วัตถุที่เกี่ยวข้องมีอยู่หรือไม่?

คุณสามารถตรวจสอบว่ามีวัตถุที่เกี่ยวข้องอยู่หรือไม่โดยใช้เมธอด `association.nil?`:

```ruby
if @book.author.nil?
  @msg = "ไม่พบผู้เขียนสำหรับหนังสือเล่มนี้"
end
```

#### เมื่อวัตถุถูกบันทึก?

การกำหนดวัตถุให้กับการเชื่อมโยง `belongs_to` จะไม่บันทึกวัตถุโดยอัตโนมัติ และวัตถุที่เกี่ยวข้องจะไม่ถูกบันทึกเช่นกัน

### การเชื่อมโยง `has_one` อ้างอิง

การเชื่อมโยง `has_one` สร้างการจับคู่แบบหนึ่งต่อหนึ่งกับโมเดลอื่น ในทางดาต้าเบส การเชื่อมโยงนี้หมายความว่าคลาสอื่นมีคีย์ต่างประเภท หากคลาสนี้มีคีย์ต่างประเภท คุณควรใช้ `belongs_to` แทน

#### เมธอดที่เพิ่มเข้ามาโดย `has_one`

เมื่อคุณประกาศการเชื่อมโยง `has_one` คลาสที่ประกาศจะได้รับเมธอดที่เกี่ยวข้องกับการเชื่อมโยงทั้งหมด 6 เมธอด:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`

ในเมธอดเหล่านี้ `association` จะถูกแทนที่ด้วยสัญลักษณ์ที่ถูกส่งผ่านเป็นอาร์กิวเมนต์แรกใน `has_one` ตัวอย่างเช่น โดยให้คำสั่งดังต่อไปนี้:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

แต่ละอินสแตนซ์ของโมเดล `Supplier` จะมีเมธอดเหล่านี้:

* `account`
* `account=`
* `build_account`
* `create_account`
* `create_account!`
* `reload_account`
* `reset_account`

หมายเหตุ: เมื่อกำลังเริ่มต้นการเชื่อมโยง `has_one` หรือ `belongs_to` คุณต้องใช้คำนำหน้า `build_` เพื่อสร้างการเชื่อมโยง แทนที่ใช้เมธอด `association.build` ที่ใช้สำหรับการเชื่อมโยง `has_many` หรือ `has_and_belongs_to_many` ในการสร้างใหม่ใช้คำนำหน้า `create_`

##### `association`

เมธอด `association` จะคืนวัตถุที่เกี่ยวข้อง หากไม่พบวัตถุที่เกี่ยวข้องจะคืนค่า `nil`

```ruby
@account = @supplier.account
```

หากวัตถุที่เกี่ยวข้องได้รับจากฐานข้อมูลไว้แล้วส่วนที่เก็บไว้จะถูกคืนค่า หากต้องการเขียนทับพฤติกรรมนี้ (และบังคับให้อ่านฐานข้อมูลใหม่) ให้เรียกใช้ `#reload_association` บนวัตถุหลัก

```ruby
@account = @supplier.reload_account
```

เพื่อยกเลิกการเก็บข้อมูลที่เกี่ยวข้องที่ถูกเก็บไว้ (และบังคับให้การเข้าถึงครั้งถัดไปถามข้อมูลจากฐานข้อมูล) ให้เรียกใช้ `#reset_association` บนวัตถุหลัก

```ruby
@supplier.reset_account
```

##### `association=(associate)`

เมธอด `association=` จะกำหนดวัตถุที่เกี่ยวข้องให้กับวัตถุนี้ ภายในเมธอดนี้หมายความว่าการดึงคีย์หลักออกจากวัตถุนี้และกำหนดคีย์ต่างประเภทของวัตถุที่เกี่ยวข้องให้เป็นค่าเดียวกัน

```ruby
@supplier.account = @account
```

##### `build_association(attributes = {})`

เมธอด `build_association` จะคืนวัตถุใหม่ของประเภทที่เกี่ยวข้อง วัตถุนี้จะถูกสร้างขึ้นจากแอตทริบิวต์ที่ส่งผ่าน และลิงก์ผ่านคีย์ต่างประเภทของมันจะถูกกำหนดค่า แต่วัตถุที่เกี่ยวข้องจะยังไม่ถูกบันทึก

```ruby
@account = @supplier.build_account(terms: "Net 30")
```

##### `create_association(attributes = {})`

เมธอด `create_association` จะคืนวัตถุใหม่ของประเภทที่เกี่ยวข้อง วัตถุนี้จะถูกสร้างขึ้นจากแอตทริบิวต์ที่ส่งผ่าน ลิงก์ผ่านคีย์ต่างประเภทของมันจะถูกกำหนดค่า และเมื่อผ่านการตรวจสอบทั้งหมดที่ระบุในโมเดลที่เกี่ยวข้องวัตถุที่เกี่ยวข้องจะถูกบันทึก

```ruby
@account = @supplier.create_account(terms: "Net 30")
```
```ruby
@account = @supplier.create_account(terms: "Net 30")
```

##### `create_association!(attributes = {})`

ทำเหมือนกับ `create_association` ด้านบน แต่จะเกิดข้อผิดพลาด `ActiveRecord::RecordInvalid` ถ้าเรคคอร์ดไม่ถูกต้อง

#### ตัวเลือกสำหรับ `has_one`

ในขณะที่ Rails ใช้ค่าเริ่มต้นที่ฉลาดซึ่งจะทำงานได้ดีในสถานการณ์ส่วนใหญ่ อาจมีเวลาที่คุณต้องการปรับแต่งพฤติกรรมของการอ้างอิงของ `has_one` ได้ การปรับแต่งเหล่านี้สามารถทำได้ง่ายๆ โดยการส่งตัวเลือกเมื่อคุณสร้างการอ้างอิง ตัวอย่างเช่น การอ้างอิงนี้ใช้ตัวเลือกสองตัวดังนี้:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing", dependent: :nullify
end
```

การอ้างอิง [`has_one`][] รองรับตัวเลือกเหล่านี้:

* `:as`
* `:autosave`
* `:class_name`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:touch`
* `:validate`

##### `:as`

การตั้งค่าตัวเลือก `:as` แสดงว่านี่เป็นการอ้างอิงหลายรูปแบบ การอ้างอิงหลายรูปแบบถูกพูดถึงอย่างละเอียด [ในส่วนที่ผ่านมาของเอกสารนี้](#polymorphic-associations)

##### `:autosave`

หากคุณตั้งค่าตัวเลือก `:autosave` เป็น `true` Rails จะบันทึกสมาชิกของการอ้างอิงที่โหลดและทำลายสมาชิกที่ถูกทำเครื่องหมายสำหรับทำลายเมื่อคุณบันทึกวัตถุหลัก การตั้งค่า `:autosave` เป็น `false` ไม่เหมือนกับไม่ตั้งค่าตัวเลือก `:autosave` หากไม่มีตัวเลือก `:autosave` อยู่ วัตถุที่อ้างอิงใหม่จะถูกบันทึก แต่วัตถุที่อ้างอิงที่อัปเดตจะไม่ถูกบันทึก

##### `:class_name`

หากชื่อของโมเดลอื่นไม่สามารถได้มาจากชื่อการอ้างอิงคุณสามารถใช้ตัวเลือก `:class_name` เพื่อระบุชื่อของโมเดล ตัวอย่างเช่น หากซัพพลายเออร์มีบัญชี แต่ชื่อจริงของโมเดลที่มีบัญชีคือ `Billing` คุณสามารถตั้งค่าได้ดังนี้:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing"
end
```

##### `:dependent`

ควบคุมสิ่งที่เกิดขึ้นกับวัตถุที่อ้างอิงเมื่อเจ้าของถูกทำลาย:

* `:destroy` ทำให้วัตถุที่อ้างอิงถูกทำลายไปด้วย
* `:delete` ทำให้วัตถุที่อ้างอิงถูกลบโดยตรงจากฐานข้อมูล (ดังนั้น callback จะไม่ถูกเรียกใช้)
* `:destroy_async`: เมื่อวัตถุถูกทำลาย จะเรียกงาน `ActiveRecord::DestroyAssociationAsyncJob` ซึ่งจะเรียกใช้ destroy บนวัตถุที่อ้างอิง Active Job ต้องถูกตั้งค่าให้ทำงาน อย่าใช้ตัวเลือกนี้หากการอ้างอิงถูกสนับสนุนโดยข้อจำกัดของคีย์ต่างประเทศในฐานข้อมูลของคุณ การกระทำข้อจำกัดของคีย์ต่างประเทศจะเกิดขึ้นภายในธุรกรรมเดียวกันที่ลบเจ้าของ
* `:nullify` ทำให้คีย์ต่างประเทศถูกตั้งค่าเป็น `NULL` คอลัมน์ประเภทหลายรูปแบบจะถูกตั้งค่าเป็น `NULL` ในการอ้างอิงหลายรูปแบบ ไม่เรียกใช้ callback
* `:restrict_with_exception` ทำให้เกิดข้อยกเว้น `ActiveRecord::DeleteRestrictionError` ถ้ามีบันทึกที่เกี่ยวข้อง
* `:restrict_with_error` ทำให้เกิดข้อผิดพลาดที่เพิ่มเข้าไปในเจ้าของหากมีวัตถุที่เกี่ยวข้อง

จำเป็นต้องไม่ตั้งค่าหรือปล่อยว่างไว้สำหรับตัวเลือก `:nullify` สำหรับการอ้างอิงเหล่านั้นที่มีข้อจำกัด `NOT NULL` ในฐานข้อมูลของคุณ หากคุณไม่ตั้งค่า `dependent` เพื่อทำลายการอ้างอิงเหล่านั้นคุณจะไม่สามารถเปลี่ยนวัตถุที่อ้างอิงได้เพราะคีย์ต่างประเทศของวัตถุที่อ้างอิงเริ่มต้นจะถูกตั้งค่าเป็นค่า `NULL` ที่ไม่ได้รับอนุญาต
```ruby
class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
end
```

คำแนะนำ: ในกรณีใดก็ตาม Rails จะไม่สร้างคอลัมน์ foreign key ให้คุณ คุณจำเป็นต้องกำหนดให้เป็นชัดเจนเป็นส่วนหนึ่งของการโยกย้ายของคุณ

##### `:inverse_of`

ตัวเลือก `:inverse_of` ระบุชื่อของความสัมพันธ์ `belongs_to` ที่เป็นความสัมพันธ์กลับของความสัมพันธ์นี้ ดูส่วน [ความสัมพันธ์แบบสองทิศทาง](#bi-directional-associations) สำหรับรายละเอียดเพิ่มเติม

```ruby
class Supplier < ApplicationRecord
  has_one :account, inverse_of: :supplier
end

class Account < ApplicationRecord
  belongs_to :supplier, inverse_of: :account
end
```

##### `:primary_key`

ตามแบบฉบับ Rails ถือว่าคอลัมน์ที่ใช้เก็บ primary key ของโมเดลนี้คือ `id` คุณสามารถเขียนทับและระบุ primary key โดยชัดเจนด้วยตัวเลือก `:primary_key`

##### `:source`

ตัวเลือก `:source` ระบุชื่อความสัมพันธ์ต้นทางสำหรับความสัมพันธ์ `has_one :through`

##### `:source_type`

ตัวเลือก `:source_type` ระบุประเภทความสัมพันธ์ต้นทางสำหรับความสัมพันธ์ `has_one :through` ที่ผ่านความสัมพันธ์หลายรูปแบบ

```ruby
class Author < ApplicationRecord
  has_one :book
  has_one :hardback, through: :book, source: :format, source_type: "Hardback"
  has_one :dust_jacket, through: :hardback
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Paperback < ApplicationRecord; end

class Hardback < ApplicationRecord
  has_one :dust_jacket
end

class DustJacket < ApplicationRecord; end
```

##### `:through`

ตัวเลือก `:through` ระบุโมเดลเชื่อมต่อผ่านซึ่งให้ดำเนินการค้นหา `has_one :through` ได้ ความสัมพันธ์ `has_one :through` ได้ถูกพูดถึงอย่างละเอียดในส่วน [ความสัมพันธ์แบบ has_one ผ่าน](#the-has-one-through-association)

##### `:touch`

หากคุณตั้งค่าตัวเลือก `:touch` เป็น `true` แล้ว แล้วเวลาที่วัตถุที่เกี่ยวข้องถูกบันทึกหรือลบออก จะมีการตั้งค่าเวลาปัจจุบันให้กับไทม์สแตมป์ `updated_at` หรือ `updated_on` บนวัตถุที่เกี่ยวข้อง:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: true
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

ในกรณีนี้ การบันทึกหรือลบ Supplier จะอัปเดตไทม์สแตมป์บน Account ที่เกี่ยวข้อง คุณยังสามารถระบุแอตทริบิวต์ไทม์สแตมป์ที่เฉพาะเจาะจงที่จะอัปเดตได้:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: :suppliers_updated_at
end
```

##### `:validate`

หากคุณตั้งค่าตัวเลือก `:validate` เป็น `true` แล้ว วัตถุที่เกี่ยวข้องใหม่จะถูกตรวจสอบความถูกต้องเมื่อคุณบันทึกวัตถุนี้ ตามค่าเริ่มต้นนี้คือ `false`: วัตถุที่เกี่ยวข้องใหม่จะไม่ถูกตรวจสอบความถูกต้องเมื่อบันทึกวัตถุนี้

#### สโคปสำหรับ `has_one`

อาจมีเวลาที่คุณต้องการปรับแต่งคิวรีที่ใช้โดย `has_one` การปรับแต่งเหล่านี้สามารถทำได้ผ่านบล็อกสโคป ตัวอย่างเช่น:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```

คุณสามารถใช้ [เมธอดการค้นหามาตรฐาน](active_record_querying.html) ใดก็ได้ภายในบล็อกสโคป ต่อไปนี้คือเมธอดที่ถูกพูดถึง:

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

เมธอด `where` ช่วยให้คุณระบุเงื่อนไขที่วัตถุที่เกี่ยวข้องต้องตรงกัน

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where "confirmed = 1" }
end
```

##### `includes`

คุณสามารถใช้เมธอด `includes` เพื่อระบุความสัมพันธ์ระดับสองที่ควรโหลดล่วงหน้าเมื่อใช้ความสัมพันธ์นี้ ตัวอย่างเช่น พิจารณาโมเดลเหล่านี้:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```
หากคุณต้องการเรียกข้อมูลตัวแทนโดยตรงจากซัพพลายเออร์ (`@supplier.account.representative`) บ่อยครั้ง คุณสามารถทำให้โค้ดของคุณมีประสิทธิภาพมากขึ้นโดยการรวมตัวแทนในการเชื่อมโยงจากซัพพลายเออร์ไปยังบัญชี:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { includes :representative }
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

##### `readonly`

หากคุณใช้เมธอด `readonly` แล้ววัตถุที่เกี่ยวข้องจะเป็นอ่านเท่านั้นเมื่อเรียกข้อมูลผ่านการเชื่อมโยง

##### `select`

เมธอด `select` ช่วยให้คุณสามารถแทนที่คำสั่ง SQL `SELECT` ที่ใช้ในการเรียกข้อมูลเกี่ยวกับวัตถุที่เกี่ยวข้อง โดยค่าเริ่มต้น Rails จะเรียกข้อมูลคอลัมน์ทั้งหมด

#### วัตถุที่เกี่ยวข้องมีอยู่หรือไม่?

คุณสามารถตรวจสอบว่ามีวัตถุที่เกี่ยวข้องอยู่หรือไม่โดยใช้เมธอด `association.nil?`:

```ruby
if @supplier.account.nil?
  @msg = "ไม่พบบัญชีสำหรับซัพพลายเออร์นี้"
end
```

#### เมื่อวัตถุถูกบันทึก?

เมื่อคุณกำหนดวัตถุให้กับการเชื่อมโยง `has_one` วัตถุนั้นจะถูกบันทึกโดยอัตโนมัติ (เพื่ออัปเดตคีย์ต่างประเทศของมัน) นอกจากนี้วัตถุใดก็ตามที่ถูกแทนที่จะถูกบันทึกโดยอัตโนมัติเช่นกันเนื่องจากคีย์ต่างประเทศของมันจะเปลี่ยน

หากการบันทึกเหล่านี้ล้มเหลวเนื่องจากข้อผิดพลาดในการตรวจสอบความถูกต้อง คำสั่งกำหนดค่าจะส่งคืน `false` และการกำหนดค่าเองจะถูกยกเลิก

หากวัตถุหลัก (วัตถุที่ประกาศการเชื่อมโยง `has_one`) ยังไม่ได้ถูกบันทึก (กล่าวคือ `new_record?` ส่งคืน `true`) วัตถุย่อยจะไม่ถูกบันทึก วัตถุเหล่านี้จะถูกบันทึกโดยอัตโนมัติเมื่อวัตถุหลักถูกบันทึก

หากคุณต้องการกำหนดวัตถุให้กับการเชื่อมโยง `has_one` โดยไม่บันทึกวัตถุ ให้ใช้เมธอด `build_association`

### การอ้างอิงการเชื่อมโยง `has_many`

การเชื่อมโยง `has_many` สร้างความสัมพันธ์หนึ่งต่อหนึ่งกับโมเดลอื่น ในทางดาต้าเบส การเชื่อมโยงนี้บอกว่าคลาสอื่นจะมีคีย์ต่างประเทศที่อ้างอิงถึงตัวอย่างของคลาสนี้

#### เมธอดที่เพิ่มโดย `has_many`

เมื่อคุณประกาศการเชื่อมโยง `has_many` คลาสที่ประกาศจะได้รับเมธอดที่เกี่ยวข้องกับการเชื่อมโยงทั้งหมด 17 เมธอด:

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

ในเมธอดเหล่านี้ `collection` จะถูกแทนที่ด้วยสัญลักษณ์ที่ส่งผ่านเป็นอาร์กิวเมนต์แรกไปยัง `has_many` และ `collection_singular` จะถูกแทนที่ด้วยรูปแบบเป็นพหูพจน์ของสัญลักษณ์นั้น ตัวอย่างเช่น โดยให้ประกาศดังนี้:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

แต่ละตัวอย่างของโมเดล `Author` จะมีเมธอดเหล่านี้:

```ruby
books
books<<(object, ...)
books.delete(object, ...)
books.destroy(object, ...)
books=(objects)
book_ids
book_ids=(ids)
books.clear
books.empty?
books.size
books.find(...)
books.where(...)
books.exists?(...)
books.build(attributes = {}, ...)
books.create(attributes = {})
books.create!(attributes = {})
books.reload
```

##### `collection`

เมธอด `collection` จะส่งคืน Relation ของวัตถุที่เกี่ยวข้องทั้งหมด หากไม่มีวัตถุที่เกี่ยวข้อง เมธอดนี้จะส่งคืน Relation ที่ว่างเปล่า

```ruby
@books = @author.books
```

##### `collection<<(object, ...)`

เมธอด [`collection<<`][] จะเพิ่มวัตถุหนึ่งหรือมากกว่าเข้าสู่คอลเลกชันโดยตั้งค่าคีย์ต่างประเทศของวัตถุเหล่านั้นเป็นคีย์หลักของโมเดลที่เรียก

```ruby
author.books << book1
```

##### `collection.delete(object, ...)`
เมธอด [`collection.delete`][] จะลบวัตถุหนึ่งหรือมากกว่าจากคอลเลกชันโดยกำหนดค่าคีย์ต่างประเทศของวัตถุเป็น `NULL`.

```ruby
@author.books.delete(@book1)
```

คำเตือน: นอกจากนี้ยังมีการทำลายวัตถุถ้ามีการเชื่อมโยงกับ `dependent: :destroy` และลบถ้ามีการเชื่อมโยงกับ `dependent: :delete_all`.

##### เมธอด `collection.destroy(object, ...)`

เมธอด [`collection.destroy`][] จะลบวัตถุหนึ่งหรือมากกว่าจากคอลเลกชันโดยเรียกใช้ `destroy` บนแต่ละวัตถุ.

```ruby
@author.books.destroy(@book1)
```

คำเตือน: วัตถุจะถูกลบออกจากฐานข้อมูล _เสมอ_ โดยไม่สนใจตัวเลือก `:dependent`.

##### เมธอด `collection=(objects)`

เมธอด `collection=` ทำให้คอลเลกชันมีเพียงวัตถุที่ระบุเท่านั้น โดยเพิ่มและลบตามที่เหมาะสม การเปลี่ยนแปลงจะถูกบันทึกในฐานข้อมูล.

##### เมธอด `collection_singular_ids`

เมธอด `collection_singular_ids` จะคืนค่าอาร์เรย์ของไอดีของวัตถุในคอลเลกชัน.

```ruby
@book_ids = @author.book_ids
```

##### เมธอด `collection_singular_ids=(ids)`

เมธอด `collection_singular_ids=` ทำให้คอลเลกชันมีเพียงวัตถุที่ระบุโดยใช้ค่าไอดีหลักที่ระบุ โดยเพิ่มและลบตามที่เหมาะสม การเปลี่ยนแปลงจะถูกบันทึกในฐานข้อมูล.

##### เมธอด `collection.clear`

เมธอด [`collection.clear`][] จะลบวัตถุทั้งหมดออกจากคอลเลกชันตามกลยุทธ์ที่ระบุโดยตัวเลือก `dependent` ถ้าไม่มีตัวเลือกที่กำหนด เมธอดจะทำตามกลยุทธ์เริ่มต้น กลยุทธ์เริ่มต้นสำหรับความสัมพันธ์ `has_many :through` คือ `delete_all` และสำหรับความสัมพันธ์ `has_many` คือการตั้งค่าคีย์ต่างประเทศเป็น `NULL`.

```ruby
@books.clear
```

คำเตือน: วัตถุจะถูกลบถ้ามีการเชื่อมโยงกับ `dependent: :destroy` หรือ `dependent: :destroy_async` เหมือนกับ `dependent: :delete_all`.

##### เมธอด `collection.empty?`

เมธอด [`collection.empty?`][] จะคืนค่า `true` ถ้าคอลเลกชันไม่มีวัตถุที่เกี่ยวข้อง.

```erb
<% if @books.empty? %>
  ไม่พบหนังสือ
<% end %>
```

##### เมธอด `collection.size`

เมธอด [`collection.size`][] จะคืนค่าจำนวนวัตถุในคอลเลกชัน.

```ruby
@book_count = @books.size
```

##### เมธอด `collection.find(...)`

เมธอด [`collection.find`][] จะค้นหาวัตถุภายในตารางของคอลเลกชัน.

```ruby
@available_book = @books.find(1)
```

##### เมธอด `collection.where(...)`

เมธอด [`collection.where`][] จะค้นหาวัตถุภายในคอลเลกชันโดยอิงตามเงื่อนไขที่ระบุ แต่วัตถุจะถูกโหลดเมื่อมีการเข้าถึงวัตถุ.

```ruby
@available_books = @books.where(available: true) # ยังไม่มีการค้นหา
@available_book = @available_books.first # ตอนนี้ฐานข้อมูลจะถูกค้นหา
```

##### เมธอด `collection.exists?(...)`

เมธอด [`collection.exists?`][] จะตรวจสอบว่ามีวัตถุที่ตรงกับเงื่อนไขที่ระบุอยู่ในตารางของคอลเลกชันหรือไม่.

##### เมธอด `collection.build(attributes = {})`

เมธอด [`collection.build`][] จะคืนค่าวัตถุใหม่หนึ่งตัวหรืออาร์เรย์ของวัตถุใหม่ของชนิดที่เกี่ยวข้อง วัตถุ(วัตถุ)จะถูกสร้างจากแอตทริบิวต์ที่ผ่านมา และการเชื่อมโยงผ่านคีย์ต่างประเทศจะถูกสร้าง แต่วัตถุที่เกี่ยวข้องจะ _ไม่_ ถูกบันทึก.

```ruby
@book = @books.build(published_at: Time.now,
                     book_number: "A12345")

@books = @books.build([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### เมธอด `collection.create(attributes = {})`

เมธอด [`collection.create`][] จะคืนค่าวัตถุใหม่หนึ่งตัวหรืออาร์เรย์ของวัตถุใหม่ของชนิดที่เกี่ยวข้อง วัตถุ(วัตถุ)จะถูกสร้างจากแอตทริบิวต์ที่ผ่านมา การเชื่อมโยงผ่านคีย์ต่างประเทศจะถูกสร้าง และเมื่อผ่านการตรวจสอบทั้งหมดที่ระบุในโมเดลที่เกี่ยวข้อง วัตถุที่เกี่ยวข้อง _จะ_ ถูกบันทึก.

```ruby
@book = @books.create(published_at: Time.now,
                      book_number: "A12345")

@books = @books.create([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```
##### `collection.create!(attributes = {})`

ทำเหมือนกับ `collection.create` ด้านบน แต่จะเกิด `ActiveRecord::RecordInvalid` ถ้าเกิดว่าเรคคอร์ดไม่ถูกต้อง

##### `collection.reload`

เมธอด [`collection.reload`][] จะคืนค่า Relation ของวัตถุที่เกี่ยวข้องทั้งหมด และบังคับให้มีการอ่านฐานข้อมูล ถ้าไม่มีวัตถุที่เกี่ยวข้อง จะคืนค่า Relation ที่ว่างเปล่า

```ruby
@books = @author.books.reload
```

#### ตัวเลือกสำหรับ `has_many`

ในขณะที่ Rails ใช้ค่าเริ่มต้นที่ฉลาดซึ่งจะทำงานได้ดีในสถานการณ์ส่วนใหญ่ อาจมีเวลาที่คุณต้องการปรับแต่งพฤติกรรมของการอ้างอิง `has_many` ได้อย่างง่ายดาย โดยการส่งตัวเลือกเมื่อคุณสร้างการอ้างอิง ตัวอย่างเช่น การอ้างอิงนี้ใช้ตัวเลือกสองตัวดังต่อไปนี้:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :delete_all, validate: false
end
```

การอ้างอิง [`has_many`][] รองรับตัวเลือกเหล่านี้:

* `:as`
* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:validate`

##### `:as`

การตั้งค่าตัวเลือก `:as` แสดงว่านี่เป็นการอ้างอิงหลายรูปแบบ ตามที่ได้กล่าวมาใน[คู่มือนี้](#polymorphic-associations)

##### `:autosave`

หากคุณตั้งค่าตัวเลือก `:autosave` เป็น `true` Rails จะบันทึกวัตถุที่อ้างอิงที่โหลดและทำลายวัตถุที่ถูกทำเครื่องหมายลบเมื่อคุณบันทึกวัตถุหลัก การตั้งค่า `:autosave` เป็น `false` ไม่เหมือนกับไม่ตั้งค่าตัวเลือก `:autosave` หากไม่มีตัวเลือก `:autosave` อยู่ วัตถุที่อ้างอิงใหม่จะถูกบันทึก แต่วัตถุที่อ้างอิงที่อัปเดตจะไม่ถูกบันทึก

##### `:class_name`

หากชื่อของโมเดลอื่นไม่สามารถได้มาจากชื่อการอ้างอิง คุณสามารถใช้ตัวเลือก `:class_name` เพื่อระบุชื่อของโมเดล ตัวอย่างเช่น หากผู้เขียนมีหนังสือหลายเล่ม แต่ชื่อจริงของโมเดลที่มีหนังสือคือ `Transaction` คุณสามารถตั้งค่าได้ดังนี้:

```ruby
class Author < ApplicationRecord
  has_many :books, class_name: "Transaction"
end
```

##### `:counter_cache`

ตัวเลือกนี้สามารถใช้กำหนดชื่อ `:counter_cache` ที่กำหนดเองได้ คุณจำเป็นต้องใช้ตัวเลือกนี้เมื่อคุณปรับแต่งชื่อ `:counter_cache` ของคุณใน [การอ้างอิง belongs_to](#options-for-belongs-to)

##### `:dependent`

ควบคุมสิ่งที่เกิดขึ้นกับวัตถุที่อ้างอิงเมื่อวัตถุเจ้าของถูกทำลาย:

* `:destroy` ทำให้วัตถุที่อ้างอิงทั้งหมดถูกทำลายไปด้วย
* `:delete_all` ทำให้วัตถุที่อ้างอิงทั้งหมดถูกลบโดยตรงจากฐานข้อมูล (ดังนั้น callback จะไม่ถูกเรียกใช้)
* `:destroy_async`: เมื่อวัตถุถูกทำลาย จะมีการเพิ่มงาน `ActiveRecord::DestroyAssociationAsyncJob` ลงในคิว ซึ่งจะเรียกใช้ destroy บนวัตถุที่อ้างอิง Active Job ต้องถูกตั้งค่าให้ใช้งาน
* `:nullify` ทำให้คีย์ต่างด้าวถูกตั้งค่าเป็น `NULL` คอลัมน์ประเภทหลายรูปแบบจะถูกตั้งค่าเป็น `NULL` ในการอ้างอิงหลายรูปแบบ ไม่เรียกใช้ callback
* `:restrict_with_exception` ทำให้เกิดข้อยกเว้น `ActiveRecord::DeleteRestrictionError` ถ้ามีระเบียนที่เกี่ยวข้อง
* `:restrict_with_error` ทำให้เกิดข้อผิดพลาดที่เพิ่มในวัตถุเจ้าของ ถ้ามีวัตถุที่เกี่ยวข้อง

ตัวเลือก `:destroy` และ `:delete_all` ยังมีผลต่อความหมายของเมธอด `collection.delete` และ `collection=` โดยทำให้ทำลายวัตถุที่อ้างอิงเมื่อถูกลบออกจากคอลเลกชัน
```ruby
class Author < ApplicationRecord
  has_many :books, foreign_key: "cust_id"
end
```

คำแนะนำ: ในกรณีใดๆ Rails จะไม่สร้างคอลัมน์ foreign key ให้คุณ คุณต้องกำหนดให้เป็นชัดเจนเป็นส่วนหนึ่งของการเคลื่อนย้ายข้อมูล

##### `:inverse_of`

ตัวเลือก `:inverse_of` ระบุชื่อของความสัมพันธ์ `belongs_to` ที่เป็นความสัมพันธ์ที่กลับกันของความสัมพันธ์นี้ ดูส่วน [ความสัมพันธ์แบบสองทิศทาง](#bi-directional-associations) เพื่อข้อมูลเพิ่มเติม

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:primary_key`

ตามปกติ Rails ถือว่าคอลัมน์ที่ใช้เก็บ primary key ของความสัมพันธ์คือ `id` คุณสามารถเขียนทับค่านี้และระบุ primary key โดยใช้ตัวเลือก `:primary_key`

เราสมมติว่าตาราง `users` มี `id` เป็น primary_key แต่มีคอลัมน์ `guid` อีกตัวหนึ่ง ความต้องการคือตาราง `todos` ควรเก็บค่าของคอลัมน์ `guid` เป็น foreign key แทนค่า `id` สามารถทำได้ดังนี้:

```ruby
class User < ApplicationRecord
  has_many :todos, primary_key: :guid
end
```

เมื่อเราทำ `@todo = @user.todos.create` แล้วค่า `user_id` ของเร็คอร์ด `@todo` จะเป็นค่า `guid` ของ `@user`

##### `:source`

ตัวเลือก `:source` ระบุชื่อความสัมพันธ์ต้นฉบับสำหรับความสัมพันธ์ `has_many :through` คุณต้องใช้ตัวเลือกนี้เมื่อชื่อความสัมพันธ์ต้นฉบับไม่สามารถสร้างขึ้นโดยอัตโนมัติจากชื่อความสัมพันธ์ได้

##### `:source_type`

ตัวเลือก `:source_type` ระบุประเภทความสัมพันธ์ต้นฉบับสำหรับความสัมพันธ์ `has_many :through` ที่ผ่านความสัมพันธ์ polymorphic

```ruby
class Author < ApplicationRecord
  has_many :books
  has_many :paperbacks, through: :books, source: :format, source_type: "Paperback"
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Hardback < ApplicationRecord; end
class Paperback < ApplicationRecord; end
```

##### `:through`

ตัวเลือก `:through` ระบุโมเดลเชื่อมร่วมที่ใช้ในการดำเนินการค้นหา ความสัมพันธ์ `has_many :through` ให้วิธีการที่จะนำมาใช้กับความสัมพันธ์แบบหลายต่อหลาย เหมือนที่ได้กล่าวถึงในส่วน [ความสัมพันธ์แบบหลายต่อหลาย](#the-has-many-through-association)

##### `:validate`

หากคุณตั้งค่าตัวเลือก `:validate` เป็น `false` แล้ววัตถุที่เกี่ยวข้องใหม่จะไม่ถูกตรวจสอบเมื่อคุณบันทึกวัตถุนี้ ตามค่าเริ่มต้นนี้คือ `true`: วัตถุที่เกี่ยวข้องใหม่จะถูกตรวจสอบเมื่อบันทึกวัตถุนี้

#### Scopes for `has_many`

บางครั้งคุณอาจต้องการปรับแต่งคิวรีที่ใช้โดย `has_many` การปรับแต่งเหล่านี้สามารถทำได้ผ่านบล็อกของ scope เช่น:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { where processed: true }
end
```

คุณสามารถใช้ [เมธอดการค้นหามาตรฐาน](active_record_querying.html) ใดๆ ภายในบล็อก scope ต่อไปนี้ ซึ่งจะถูกพูดถึงต่อไป:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

เมธอด `where` ช่วยให้คุณระบุเงื่อนไขที่วัตถุที่เกี่ยวข้องต้องตรงกัน

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where "confirmed = 1" },
    class_name: "Book"
end
```

คุณยังสามารถตั้งเงื่อนไขผ่านแบบแฮชได้:

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where confirmed: true },
    class_name: "Book"
end
```

หากคุณใช้ตัวเลือกแบบแฮชสไตล์ `where` แล้วการสร้างเร็คอร์ดผ่านความสัมพันธ์นี้จะถูกจำกัดโดยอัตโนมัติโดยใช้แบบแฮช ในกรณีนี้การใช้ `@author.confirmed_books.create` หรือ `@author.confirmed_books.build` จะสร้างหนังสือโดยที่คอลัมน์ confirmed มีค่าเป็น `true`
##### `extending`

เมธอด `extending` ระบุชื่อโมดูลที่ต้องการเพิ่มเข้าไปใน association proxy การเพิ่มส่วนขยายของ association จะถูกพูดถึงอย่างละเอียดใน [ส่วนท้ายของเอกสารนี้](#association-extensions)

##### `group`

เมธอด `group` ใช้ระบุชื่อแอตทริบิวต์ที่ต้องการจัดกลุ่มผลลัพธ์ โดยใช้คำสั่ง `GROUP BY` ใน SQL ของ finder

```ruby
class Author < ApplicationRecord
  has_many :chapters, -> { group 'books.id' },
                      through: :books
end
```

##### `includes`

คุณสามารถใช้เมธอด `includes` เพื่อระบุการเชื่อมโยงระดับสองที่ควรถูกโหลดล่วงหน้าเมื่อใช้ association นี้ ตัวอย่างเช่น พิจารณาโมเดลเหล่านี้:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

หากคุณใช้การเรียก chapters โดยตรงจาก authors (`@author.books.chapters`) คุณสามารถทำให้โค้ดของคุณมีประสิทธิภาพมากขึ้นโดยการรวม chapters ใน association จาก authors ไปยัง books:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { includes :chapters }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

##### `limit`

เมธอด `limit` ช่วยให้คุณจำกัดจำนวนรวมของออบเจ็กต์ที่จะถูกดึงผ่าน association

```ruby
class Author < ApplicationRecord
  has_many :recent_books,
    -> { order('published_at desc').limit(100) },
    class_name: "Book"
end
```

##### `offset`

เมธอด `offset` ช่วยให้คุณระบุตำแหน่งเริ่มต้นสำหรับการดึงออบเจ็กต์ผ่าน association ตัวอย่างเช่น `-> { offset(11) }` จะข้ามระเบียนแรก 11 รายการ

##### `order`

เมธอด `order` กำหนดลำดับที่ออบเจ็กต์ที่เกี่ยวข้องจะได้รับ (ในรูปแบบที่ใช้ในคำสั่ง SQL `ORDER BY`)

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order "date_confirmed DESC" }
end
```

##### `readonly`

หากคุณใช้เมธอด `readonly` ออบเจ็กต์ที่เกี่ยวข้องจะเป็นอ่านอย่างเดียวเมื่อดึงข้อมูลผ่าน association

##### `select`

เมธอด `select` ช่วยให้คุณสามารถแทนที่คำสั่ง SQL `SELECT` ที่ใช้ในการดึงข้อมูลเกี่ยวกับออบเจ็กต์ที่เกี่ยวข้อง โดยค่าเริ่มต้น Rails จะดึงคอลัมน์ทั้งหมด

คำเตือน: หากคุณระบุ `select` เอง โปรดแน่ใจว่าคุณรวมคอลัมน์หลักและคอลัมน์ตัวแปรต่าง ๆ ของโมเดลที่เกี่ยวข้อง หากไม่เป็นเช่นนั้น Rails จะส่งข้อผิดพลาด

##### `distinct`

ใช้เมธอด `distinct` เพื่อให้คอลเลกชันปลอดภัยจากข้อมูลที่ซ้ำกัน ส่วนนี้มีประโยชน์มากกับตัวเลือก `:through`

```ruby
class Person < ApplicationRecord
  has_many :readings
  has_many :articles, through: :readings
end
```

```irb
irb> person = Person.create(name: 'John')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 5, name: "a1">, #<Article id: 5, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 12, person_id: 5, article_id: 5>, #<Reading id: 13, person_id: 5, article_id: 5>]
```

ในกรณีข้างต้นมีการอ่านสองรายการและ `person.articles` นำออกมาทั้งสองแม้ว่าระเบียนเหล่านี้จะชี้ไปที่บทความเดียวกัน

ตอนนี้เรามาตั้งค่า `distinct`:

```ruby
class Person
  has_many :readings
  has_many :articles, -> { distinct }, through: :readings
end
```

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 7, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 16, person_id: 7, article_id: 7>, #<Reading id: 17, person_id: 7, article_id: 7>]
```
ในกรณีด้านบนยังมีการอ่านสองครั้ง อย่างไรก็ตาม `person.articles` จะแสดงเพียงบทความเดียวเนื่องจากคอลเลกชันจะโหลดเฉพาะระเบียนที่ไม่ซ้ำเท่านั้น

หากคุณต้องการให้แน่ใจว่าเมื่อมีการเพิ่มระเบียนในการเชื่อมโยงที่ถูกจัดเก็บแล้วจะไม่ซ้ำกัน (เพื่อให้คุณสามารถแน่ใจได้ว่าเมื่อคุณตรวจสอบการเชื่อมโยงคุณจะไม่พบระเบียนที่ซ้ำกัน) คุณควรเพิ่มดัชนีที่ไม่ซ้ำกันในตารางเอง ตัวอย่างเช่นหากคุณมีตารางที่ชื่อว่า `readings` และคุณต้องการให้บทความสามารถเพิ่มได้เฉพาะครั้งเดียวสำหรับบุคคล คุณสามารถเพิ่มโค้ดต่อไปนี้ในการเรียกใช้งาน:

```ruby
add_index :readings, [:person_id, :article_id], unique: true
```

เมื่อคุณมีดัชนีที่ไม่ซ้ำกันนี้ การพยายามเพิ่มบทความให้กับบุคคลสองครั้งจะเกิดข้อผิดพลาด `ActiveRecord::RecordNotUnique`:

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
ActiveRecord::RecordNotUnique
```

โปรดทราบว่าการตรวจสอบความไม่ซ้ำกันโดยใช้ `include?` อาจมีการแข่งขันระหว่างกระบวนการ อย่าพยายามใช้ `include?` เพื่อให้แน่ใจว่าไม่มีการเชื่อมโยงที่ซ้ำกันในการสมาชิก ตัวอย่างเช่น โดยใช้ตัวอย่างบทความข้างต้น โค้ดต่อไปนี้จะเป็นการแข่งขันเนื่องจากผู้ใช้หลายคนอาจพยายามทำเช่นนี้ในเวลาเดียวกัน:

```ruby
person.articles << article unless person.articles.include?(article)
```

#### เมื่อวัตถุถูกบันทึก?

เมื่อคุณกำหนดวัตถุให้กับการเชื่อมโยง `has_many` วัตถุนั้นจะถูกบันทึกโดยอัตโนมัติ (เพื่ออัปเดตคีย์ต่างประเทศของมัน) หากคุณกำหนดวัตถุหลายๆ วัตถุในคำสั่งเดียวกัน วัตถุเหล่านั้นจะถูกบันทึกทั้งหมด

หากการบันทึกใดๆ ล้มเหลวเนื่องจากข้อผิดพลาดในการตรวจสอบความถูกต้อง คำสั่งกำหนดค่าจะส่งคืน `false` และการกำหนดค่าเองจะถูกยกเลิก

หากวัตถุหลัก (วัตถุที่ประกาศการเชื่อมโยง `has_many`) ยังไม่ได้บันทึก (นั่นคือ `new_record?` ส่งคืน `true`) วัตถุย่อยจะไม่ถูกบันทึกเมื่อเพิ่มเข้าไป สมาชิกที่ยังไม่ได้บันทึกในการเชื่อมโยงจะถูกบันทึกโดยอัตโนมัติเมื่อบุคคลที่เป็นผู้ปกครองถูกบันทึก

หากคุณต้องการกำหนดวัตถุให้กับการเชื่อมโยง `has_many` โดยไม่บันทึกวัตถุ ให้ใช้เมธอด `collection.build`
##### เมธอดคอลัมน์เพิ่มเติม

หากตารางเชื่อมต่อสำหรับความสัมพันธ์ `has_and_belongs_to_many` มีคอลัมน์เพิ่มเติมนอกเหนือจากคีย์ต่างประเทศสองตัว คอลัมน์เหล่านี้จะถูกเพิ่มเป็นแอตทริบิวต์ให้กับเรคคอร์ดที่ได้รับผ่านความสัมพันธ์นั้น รายการที่ส่งคืนพร้อมแอตทริบิวต์เพิ่มเติมจะเป็นแบบอ่านอย่างเดียว เนื่องจาก Rails ไม่สามารถบันทึกการเปลี่ยนแปลงในแอตทริบิวต์เหล่านั้นได้

คำเตือน: การใช้แอตทริบิวต์เพิ่มเติมในตารางเชื่อมต่อในความสัมพันธ์ `has_and_belongs_to_many` ถูกยกเลิกแล้ว หากคุณต้องการพฤติกรรมที่ซับซ้อนในตารางที่เชื่อมระหว่างโมเดลสองตัวในความสัมพันธ์หลายต่อหลาย คุณควรใช้ความสัมพันธ์ `has_many :through` แทน `has_and_belongs_to_many`

##### `collection`

เมธอด `collection` คืนค่า Relation ของวัตถุที่เกี่ยวข้องทั้งหมด หากไม่มีวัตถุที่เกี่ยวข้อง จะคืนค่า Relation ที่ว่างเปล่า

```ruby
@assemblies = @part.assemblies
```

##### `collection<<(object, ...)`

เมธอด [`collection<<`][] เพิ่มวัตถุหนึ่งหรือมากกว่าเข้าสู่คอลเลกชันโดยการสร้างเรคคอร์ดในตารางเชื่อมต่อ

```ruby
@part.assemblies << @assembly1
```

หมายเหตุ: เมธอดนี้มีชื่อเลียนแบบเป็น `collection.concat` และ `collection.push`

##### `collection.delete(object, ...)`

เมธอด [`collection.delete`][] ลบวัตถุหนึ่งหรือมากกว่าออกจากคอลเลกชันโดยการลบเรคคอร์ดในตารางเชื่อมต่อ การดำเนินการนี้ไม่ทำลายวัตถุ

```ruby
@part.assemblies.delete(@assembly1)
```

##### `collection.destroy(object, ...)`

เมธอด [`collection.destroy`][] ลบวัตถุหนึ่งหรือมากกว่าออกจากคอลเลกชันโดยการลบเรคคอร์ดในตารางเชื่อมต่อ การดำเนินการนี้ไม่ทำลายวัตถุ

```ruby
@part.assemblies.destroy(@assembly1)
```

##### `collection=(objects)`

เมธอด `collection=` ทำให้คอลเลกชันมีเพียงวัตถุที่ระบุเท่านั้น โดยการเพิ่มและลบตามที่เหมาะสม การเปลี่ยนแปลงจะถูกบันทึกในฐานข้อมูล

##### `collection_singular_ids`

เมธอด `collection_singular_ids` คืนค่าอาร์เรย์ของไอดีของวัตถุในคอลเลกชัน

```ruby
@assembly_ids = @part.assembly_ids
```

##### `collection_singular_ids=(ids)`

เมธอด `collection_singular_ids=` ทำให้คอลเลกชันมีเพียงวัตถุที่ระบุโดยค่าหลักของไอดีที่รับเข้ามา โดยการเพิ่มและลบตามที่เหมาะสม การเปลี่ยนแปลงจะถูกบันทึกในฐานข้อมูล

##### `collection.clear`

เมธอด [`collection.clear`][] ลบวัตถุทุกตัวออกจากคอลเลกชันโดยการลบแถวจากตารางที่เชื่อมต่อ การดำเนินการนี้ไม่ทำลายวัตถุที่เกี่ยวข้อง

##### `collection.empty?`

เมธอด [`collection.empty?`][] คืนค่า `true` หากคอลเลกชันไม่มีวัตถุที่เกี่ยวข้อง

```html+erb
<% if @part.assemblies.empty? %>
  ชิ้นส่วนนี้ไม่ได้ใช้ในการประกอบใด ๆ
<% end %>
```

##### `collection.size`

เมธอด [`collection.size`][] คืนค่าจำนวนวัตถุในคอลเลกชัน

```ruby
@assembly_count = @part.assemblies.size
```

##### `collection.find(...)`

เมธอด [`collection.find`][] ค้นหาวัตถุภายในตารางของคอลเลกชัน

```ruby
@assembly = @part.assemblies.find(1)
```

##### `collection.where(...)`

เมธอด [`collection.where`][] ค้นหาวัตถุภายในคอลเลกชันตามเงื่อนไขที่ระบุ แต่วัตถุจะถูกโหลดโดยการเรียกใช้ฐานข้อมูลเท่านั้น

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

##### `collection.exists?(...)`

เมธอด [`collection.exists?`][] ตรวจสอบว่ามีวัตถุที่ตรงกับเงื่อนไขที่ระบุอยู่ในตารางของคอลเลกชันหรือไม่

##### `collection.build(attributes = {})`

เมธอด [`collection.build`][] คืนค่าวัตถุใหม่ของประเภทที่เกี่ยวข้อง วัตถุนี้จะถูกสร้างจากแอตทริบิวต์ที่ส่งผ่าน และลิงก์ผ่านตารางเชื่อมต่อจะถูกสร้าง แต่วัตถุที่เกี่ยวข้องจะยังไม่ถูกบันทึก

```ruby
@assembly = @part.assemblies.build({ assembly_name: "Transmission housing" })
```
##### `collection.create(attributes = {})`

วิธี `collection.create` จะสร้างวัตถุใหม่ของประเภทที่เกี่ยวข้องกลับมา วัตถุนี้จะถูกสร้างขึ้นจากแอตทริบิวต์ที่ถูกส่งผ่าน การเชื่อมโยงผ่านตารางเชื่อมโยงจะถูกสร้างขึ้น และเมื่อผ่านการตรวจสอบทั้งหมดที่ระบุในโมเดลที่เกี่ยวข้องแล้ว วัตถุที่เกี่ยวข้องจะถูกบันทึก

```ruby
@assembly = @part.assemblies.create({ assembly_name: "Transmission housing" })
```

##### `collection.create!(attributes = {})`

ทำเหมือนกับ `collection.create` แต่จะเรียก `ActiveRecord::RecordInvalid` ถ้าบันทึกไม่ถูกต้อง

##### `collection.reload`

วิธี `collection.reload` จะคืนค่า Relation ของวัตถุที่เกี่ยวข้องทั้งหมด และบังคับให้อ่านฐานข้อมูล ถ้าไม่มีวัตถุที่เกี่ยวข้อง จะคืนค่า Relation ที่ว่างเปล่า

```ruby
@assemblies = @part.assemblies.reload
```

#### ตัวเลือกสำหรับ `has_and_belongs_to_many`

ในขณะที่ Rails ใช้ค่าเริ่มต้นที่ฉลาดซึ่งจะทำงานได้ดีในสถานการณ์ส่วนใหญ่ อาจมีเวลาที่คุณต้องการปรับแต่งพฤติกรรมของการอ้างอิง `has_and_belongs_to_many` การปรับแต่งเหล่านี้สามารถทำได้ง่ายๆ โดยการส่งตัวเลือกเมื่อคุณสร้างการอ้างอิง ตัวอย่างเช่น การอ้างอิงนี้ใช้ตัวเลือกสองตัวดังต่อไปนี้:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { readonly },
                                       autosave: true
end
```

การอ้างอิง [`has_and_belongs_to_many`][] รองรับตัวเลือกเหล่านี้:

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
* `:validate`

##### `:association_foreign_key`

ตามปกติ Rails จะถือว่าคอลัมน์ในตารางเชื่อมโยงที่ใช้เก็บคีย์ต่างประเทศที่ชี้ไปยังโมเดลอื่น คือชื่อของโมเดลนั้นๆ พร้อมกับเพิ่มคำต่อท้าย `_id` ตัวเลือก `:association_foreign_key` ช่วยให้คุณสามารถตั้งชื่อคีย์ต่างประเทศได้โดยตรง:

เคล็ดลับ: ตัวเลือก `:foreign_key` และ `:association_foreign_key` มีประโยชน์เมื่อตั้งค่าการอ้างอิงหลายต่อหลายเอง เช่น:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:autosave`

ถ้าคุณตั้งค่าตัวเลือก `:autosave` เป็น `true` Rails จะบันทึกสมาชิกการอ้างอิงที่โหลดและทำลายสมาชิกที่ถูกทำเครื่องหมายว่าจะถูกทำลายเมื่อคุณบันทึกวัตถุหลัก การตั้งค่า `:autosave` เป็น `false` ไม่ได้หมายความว่าไม่ตั้งค่าตัวเลือก `:autosave` ถ้าไม่มีตัวเลือก `:autosave` จะไม่มีการบันทึกวัตถุที่เกี่ยวข้องที่อัพเดต แต่วัตถุที่เกี่ยวข้องใหม่จะถูกบันทึก

##### `:class_name`

ถ้าชื่อของโมเดลอื่นไม่สามารถได้มาจากชื่อการอ้างอิงได้ คุณสามารถใช้ตัวเลือก `:class_name` เพื่อระบุชื่อโมเดล ตัวอย่างเช่น ถ้าส่วนประกอบมีหลายส่วน แต่ชื่อจริงของโมเดลที่มีส่วนประกอบคือ `Gadget` คุณสามารถตั้งค่าได้ดังนี้:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```

##### `:foreign_key`

ตามปกติ Rails จะถือว่าคอลัมน์ในตารางเชื่อมโยงที่ใช้เก็บคีย์ต่างประเทศที่ชี้ไปยังโมเดลนี้ คือชื่อของโมเดลนี้พร้อมกับเพิ่มคำต่อท้าย `_id` ตัวเลือก `:foreign_key` ช่วยให้คุณสามารถตั้งชื่อคีย์ต่างประเทศได้โดยตรง:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:join_table`

ถ้าชื่อตารางเชื่อมโยงที่ตามคำสั่งเรียงตามลำดับอักษรเริ่มต้นไม่ใช่สิ่งที่คุณต้องการ คุณสามารถใช้ตัวเลือก `:join_table` เพื่อแทนที่ค่าเริ่มต้น

##### `:validate`
หากคุณตั้งค่าตัวเลือก `:validate` เป็น `false` แล้ววัตถุที่เกี่ยวข้องใหม่จะไม่ถูกตรวจสอบความถูกต้องเมื่อคุณบันทึกวัตถุนี้ โดยค่าเริ่มต้นคือ `true`: วัตถุที่เกี่ยวข้องใหม่จะถูกตรวจสอบความถูกต้องเมื่อบันทึกวัตถุนี้

#### ขอบเขตสำหรับ `has_and_belongs_to_many`

บางครั้งคุณอาจต้องการปรับแต่งคิวรีที่ใช้โดย `has_and_belongs_to_many` การปรับแต่งเหล่านี้สามารถทำได้ผ่านบล็อกของขอบเขต ตัวอย่างเช่น:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

คุณสามารถใช้ [เมธอดการค้นหามาตรฐาน](active_record_querying.html) ใดก็ได้ภายในบล็อกขอบเขต ต่อไปนี้คือเมธอดที่ถูกพูดถึง:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

เมธอด `where` ช่วยให้คุณระบุเงื่อนไขที่วัตถุที่เกี่ยวข้องต้องตรงกัน

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

คุณยังสามารถตั้งเงื่อนไขผ่านแฮชได้เช่นกัน:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

หากคุณใช้ `where` แบบแฮช การสร้างบันทึกผ่านการเชื่อมโยงนี้จะถูกจำกัดโดยอัตโนมัติโดยใช้แฮชนี้ ในกรณีนี้การใช้ `@parts.assemblies.create` หรือ `@parts.assemblies.build` จะสร้างการประชุมที่คอลัมน์ `factory` มีค่าเป็น "Seattle"

##### `extending`

เมธอด `extending` ระบุโมดูลที่มีชื่อเพื่อขยายโปรกฤตการเชื่อมโยง การขยายโปรกฤตการเชื่อมโยงถูกพูดถึงอย่างละเอียด [ในส่วนที่เหลือของเอกสารนี้](#association-extensions)

##### `group`

เมธอด `group` จัดหมวดหมู่ชุดผลลัพธ์ตามชื่อแอตทริบิวต์โดยใช้คำสั่ง `GROUP BY` ใน SQL ของตัวค้นหา

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```

##### `includes`

คุณสามารถใช้เมธอด `includes` เพื่อระบุการเชื่อมโยงระดับสองที่ควรโหลดล่วงหน้าเมื่อใช้การเชื่อมโยงนี้

##### `limit`

เมธอด `limit` ช่วยให้คุณจำกัดจำนวนวัตถุทั้งหมดที่จะถูกเรียกด้วยการเชื่อมโยง

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```

##### `offset`

เมธอด `offset` ช่วยให้คุณระบุตำแหน่งเริ่มต้นสำหรับการเรียกวัตถุผ่านการเชื่อมโยง เช่นหากคุณตั้งค่า `offset(11)` จะข้ามบันทึกแรก 11 รายการ

##### `order`

เมธอด `order` กำหนดลำดับที่วัตถุที่เกี่ยวข้องจะได้รับ (ในรูปแบบที่ใช้ในคำสั่ง SQL `ORDER BY`)

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```

##### `readonly`

หากคุณใช้เมธอด `readonly` วัตถุที่เกี่ยวข้องจะเป็นอ่านอย่างเดียวเมื่อเรียกด้วยการเชื่อมโยง

##### `select`

เมธอด `select` ช่วยให้คุณเขียนทับคำสั่ง SQL `SELECT` ที่ใช้ในการเรียกข้อมูลเกี่ยวกับวัตถุที่เกี่ยวข้อง โดยค่าเริ่มต้น Rails จะดึงคอลัมน์ทั้งหมด

##### `distinct`

ใช้เมธอด `distinct` เพื่อลบรายการที่ซ้ำออกจากคอลเลกชัน

#### เมื่อไหร่วัตถุถูกบันทึก?

เมื่อคุณกำหนดวัตถุให้กับการเชื่อมโยง `has_and_belongs_to_many` วัตถุนั้นจะถูกบันทึกโดยอัตโนมัติ (เพื่ออัปเดตตารางเชื่อมโยง) หากคุณกำหนดวัตถุหลายๆ วัตถุในคำสั่งเดียวกัน วัตถุเหล่านั้นจะถูกบันทึกทั้งหมด

หากบันทึกใดๆ ล้มเหลวเนื่องจากข้อผิดพลาดในการตรวจสอบความถูกต้อง คำสั่งกำหนดค่าจะส่งคืน `false` และการกำหนดค่าเองจะถูกยกเลิก
หากวัตถุประสงค์หลัก (วัตถุประสงค์ที่ประกาศ `has_and_belongs_to_many` และยังไม่ได้บันทึก (กล่าวคือ `new_record?` คืนค่า `true`) แล้ววัตถุย่อยจะไม่ถูกบันทึกเมื่อถูกเพิ่มเข้าไป วัตถุที่ยังไม่ได้บันทึกทั้งหมดในการเชื่อมโยงจะถูกบันทึกโดยอัตโนมัติเมื่อวัตถุหลักถูกบันทึก

หากคุณต้องการกำหนดวัตถุให้กับการเชื่อมโยง `has_and_belongs_to_many` โดยไม่บันทึกวัตถุ ให้ใช้เมธอด `collection.build`

### การเรียกใช้งานของการเชื่อมโยง

การเรียกใช้งานปกติจะเชื่อมโยงกับวัตถุ Active Record ในรอบชีวิตของวัตถุ ซึ่งช่วยให้คุณทำงานกับวัตถุเหล่านั้นในจุดต่างๆ ตัวอย่างเช่น คุณสามารถใช้ callback `:before_save` เพื่อทำให้เกิดเหตุการณ์ก่อนที่วัตถุจะถูกบันทึก

การเรียกใช้งานของการเชื่อมโยงคล้ายกับการเรียกใช้งานปกติ แต่จะถูกเรียกใช้งานโดยเหตุการณ์ในรอบชีวิตของคอลเลกชัน มีการเรียกใช้งานการเชื่อมโยง 4 รูปแบบดังนี้:

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

คุณกำหนดการเรียกใช้งานของการเชื่อมโยงโดยเพิ่มตัวเลือกในการประกาศการเชื่อมโยง ตัวอย่างเช่น:

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_credit_limit

  def check_credit_limit(book)
    # ...
  end
end
```

Rails จะส่งวัตถุที่กำลังเพิ่มหรือลบไปยัง callback

คุณสามารถเรียงลำดับ callback ในเหตุการณ์เดียวกันได้โดยส่งผ่านเป็นอาร์เรย์:

```ruby
class Author < ApplicationRecord
  has_many :books,
    before_add: [:check_credit_limit, :calculate_shipping_charges]

  def check_credit_limit(book)
    # ...
  end

  def calculate_shipping_charges(book)
    # ...
  end
end
```

หาก callback `before_add` โยน `:abort` วัตถุจะไม่ถูกเพิ่มเข้าไปในคอลเลกชัน อย่างเดียวกันหาก callback `before_remove` โยน `:abort` วัตถุจะไม่ถูกลบออกจากคอลเลกชัน:

```ruby
# หนังสือจะไม่ถูกเพิ่มเข้าไปหากถึงขีดจำกัด
def check_credit_limit(book)
  throw(:abort) if limit_reached?
end
```

หมายเหตุ: Callback เหล่านี้จะถูกเรียกเมื่อวัตถุที่เกี่ยวข้องถูกเพิ่มหรือลบผ่านคอลเลกชันการเชื่อมโยง:

```ruby
# เรียกใช้งาน callback `before_add`
author.books << book
author.books = [book, book2]

# ไม่เรียกใช้งาน callback `before_add`
book.update(author_id: 1)
```

### การขยายความสามารถของการเชื่อมโยง

คุณไม่จำกัดเฉพาะฟังก์ชันที่ Rails สร้างให้กับวัตถุการเชื่อมโยง คุณยังสามารถขยายวัตถุเหล่านี้ผ่านโมดูลที่ไม่มีชื่อ โดยเพิ่มฟังก์ชันค้นหาใหม่ การสร้างหรือเมธอดอื่นๆ ตัวอย่างเช่น:

```ruby
class Author < ApplicationRecord
  has_many :books do
    def find_by_book_prefix(book_number)
      find_by(category_id: book_number[0..2])
    end
  end
end
```

หากคุณมีการขยายที่ควรจะใช้ร่วมกันกับการเชื่อมโยงหลายๆ อัน คุณสามารถใช้โมดูลขยายที่มีชื่อได้ ตัวอย่างเช่น:

```ruby
module FindRecentExtension
  def find_recent
    where("created_at > ?", 5.days.ago)
  end
end

class Author < ApplicationRecord
  has_many :books, -> { extending FindRecentExtension }
end

class Supplier < ApplicationRecord
  has_many :deliveries, -> { extending FindRecentExtension }
end
```

การขยายสามารถอ้างถึงภายในของวัตถุการเชื่อมโยงได้โดยใช้แอตทริบิวต์เหล่านี้ของ `proxy_association`:

* `proxy_association.owner` คืนค่าวัตถุที่เป็นส่วนหนึ่งของการเชื่อมโยง
* `proxy_association.reflection` คืนค่าวัตถุ reflection ที่อธิบายการเชื่อมโยง
* `proxy_association.target` คืนค่าวัตถุที่เกี่ยวข้องสำหรับ `belongs_to` หรือ `has_one` หรือคอลเลกชันของวัตถุที่เกี่ยวข้องสำหรับ `has_many` หรือ `has_and_belongs_to_many`

### การกำหนดขอบเขตของการเชื่อมโยงโดยใช้เจ้าของการเชื่อมโยง

เจ้าของของการเชื่อมโยงสามารถถูกส่งผ่านเป็นอาร์กิวเมนต์เดียวในบล็อกของขอบเขตเมื่อคุณต้องการควบคุมขอบเขตการเชื่อมโยงได้อย่างเต็มที่ อย่างไรก็ตาม การโหลดข้อมูลล่วงหน้าของการเชื่อมโยงจะไม่สามารถทำได้อีกต่อไป
```ruby
class Supplier < ApplicationRecord
  has_one :account, ->(supplier) { where active: supplier.active? }
end
```

การสืบทอดแบบตารางเดียว (Single Table Inheritance - STI)
-------------------------------------------------------

บางครั้งคุณอาจต้องการแบ่งปันฟิลด์และพฤติกรรมระหว่างโมเดลที่แตกต่างกัน
เราเรียกว่ามีโมเดล Car, Motorcycle, และ Bicycle เราต้องการแบ่งปันฟิลด์ `color` และ `price` และบางเมธอดบางอย่างสำหรับทั้งหมด แต่มีพฤติกรรมที่แตกต่างกันสำหรับแต่ละโมเดล และควบคุมความแยกกันด้วย

ก่อนอื่น เราจะสร้างโมเดลหลัก Vehicle:

```bash
$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}
```

คุณเห็นไหมว่าเรากำลังเพิ่มฟิลด์ "type" ใช่ไหม? เนื่องจากโมเดลทั้งหมดจะถูกบันทึกในตารางฐานข้อมูลเดียวกัน Rails จะบันทึกชื่อของโมเดลที่กำลังถูกบันทึกในคอลัมน์นี้ ในตัวอย่างของเรา สามารถเป็นได้เป็น "Car", "Motorcycle" หรือ "Bicycle" STI จะไม่ทำงานโดยไม่มีฟิลด์ "type" ในตาราง

ต่อไป เราจะสร้างโมเดล Car ที่สืบทอดจาก Vehicle สำหรับนี้ เราสามารถใช้ `--parent=PARENT` ตัวเลือกที่จะสร้างโมเดลที่สืบทอดจากผู้ปกครองที่ระบุและไม่มีการเคลื่อนย้ายเทียบเท่า (เนื่องจากตารางมีอยู่แล้ว)

ตัวอย่างเช่น เพื่อสร้างโมเดล Car:

```bash
$ bin/rails generate model car --parent=Vehicle
```

โมเดลที่สร้างจะมีลักษณะดังนี้:

```ruby
class Car < Vehicle
end
```

นี่หมายความว่าพฤติกรรมที่เพิ่มใน Vehicle สามารถใช้ได้สำหรับ Car ด้วย เช่น ความสัมพันธ์ เมธอดสาธารณะ เป็นต้น

การสร้างรถยนต์จะบันทึกไว้ในตาราง `vehicles` ด้วย "Car" เป็นฟิลด์ `type`:

```ruby
Car.create(color: 'Red', price: 10000)
```

จะสร้าง SQL ดังนี้:

```sql
INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

การค้นหารถยนต์จะค้นหาเฉพาะยานพาหนะที่เป็นรถยนต์:

```ruby
Car.all
```

จะเรียกใช้คำสั่ง SQL เช่น:

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```

Delegated Types
----------------

[`Single Table Inheritance (STI)`](#single-table-inheritance-sti) ทำงานได้ดีที่สุดเมื่อมีความแตกต่างน้อยระหว่างคลาสย่อยและแอตทริบิวต์ของคลาสย่อย แต่รวมถึงแอตทริบิวต์ทั้งหมดของคลาสย่อยที่คุณต้องการสร้างตารางเดียว

ข้อเสียของวิธีนี้คือจะทำให้ตารางมีข้อมูลที่ไม่จำเป็น โดยจะรวมถึงแอตทริบิวต์ที่เฉพาะเจาะจงสำหรับคลาสย่อยที่ไม่ได้ใช้โดยอะไรก็ตาม

ในตัวอย่างต่อไปนี้ มี Active Record models สองตัวที่สืบทอดจากคลาส "Entry" เดียวกันซึ่งรวมถึงแอตทริบิวต์ `subject`

```ruby
# Schema: entries[ id, type, subject, created_at, updated_at]
class Entry < ApplicationRecord
end

class Comment < Entry
end

class Message < Entry
end
```

Delegated types แก้ปัญหานี้ ผ่าน `delegated_type`

เพื่อใช้ delegated types เราต้องออกแบบข้อมูลของเราในวิธีที่เฉพาะเจาะจง ข้อกำหนดคือดังนี้:

* มี superclass ที่เก็บแอตทริบิวต์ที่แชร์กันระหว่างคลาสย่อยทั้งหมดในตารางของมัน
* แต่ละคลาสย่อยต้องสืบทอดจาก superclass และจะมีตารางแยกสำหรับแอตทริบิวต์เพิ่มเติมที่เฉพาะกับคลาสนั้น

สิ่งนี้จะลดความจำเป็นที่จะกำหนดแอตทริบิวต์ในตารางเดียวที่แชร์กันระหว่างคลาสย่อยทั้งหมด

เพื่อนำไปใช้กับตัวอย่างข้างต้น เราต้องสร้างโมเดลใหม่
ก่อนอื่น เราจะสร้างโมเดลหลัก `Entry` ซึ่งจะเป็น superclass ของเรา:
```bash
$ bin/rails generate model entry entryable_type:string entryable_id:integer
```

จากนั้นเราจะสร้างโมเดล `Message` และ `Comment` สำหรับการจัดส่ง:

```bash
$ bin/rails generate model message subject:string body:string
$ bin/rails generate model comment content:string
```

หลังจากที่รันคำสั่งเสร็จสิ้น เราจะได้โมเดลที่มีลักษณะดังนี้:

```ruby
# Schema: entries[ id, entryable_type, entryable_id, created_at, updated_at ]
class Entry < ApplicationRecord
end

# Schema: messages[ id, subject, body, created_at, updated_at ]
class Message < ApplicationRecord
end

# Schema: comments[ id, content, created_at, updated_at ]
class Comment < ApplicationRecord
end
```

### ประกาศ `delegated_type`

ก่อนอื่น เราจะประกาศ `delegated_type` ในคลาสหลัก `Entry`.

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
end
```

พารามิเตอร์ `entryable` ระบุฟิลด์ที่ใช้สำหรับการจัดส่ง และรวมประเภท `Message` และ `Comment` เป็นคลาสที่จะถูกจัดส่ง

คลาส `Entry` มีฟิลด์ `entryable_type` และ `entryable_id` นี้คือฟิลด์ที่มี `_type` และ `_id` ที่เพิ่มเข้าไปในชื่อ `entryable` ในการกำหนด `delegated_type`
`entryable_type` เก็บชื่อคลาสย่อยของ delegatee และ `entryable_id` เก็บรหัสบันทึกของคลาสย่อยของ delegatee

ต่อไป เราต้องกำหนดโมดูลเพื่อนำเสนอประเภทที่ถูกจัดส่ง โดยประกาศพารามิเตอร์ `as: :entryable` ในการสัมพันธ์ `has_one`

```ruby
module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

และจากนั้นรวมโมดูลที่สร้างเข้าไปในคลาสย่อย

```ruby
class Message < ApplicationRecord
  include Entryable
end

class Comment < ApplicationRecord
  include Entryable
end
```

ด้วยการกำหนดนี้เสร็จสิ้น เราสามารถใช้ `Entry` เป็นตัวจัดส่ง ดังนี้:

| เมธอด | คืนค่า |
|---|---|
| `Entry#entryable_class` | Message หรือ Comment |
| `Entry#entryable_name` | "message" หรือ "comment" |
| `Entry.messages` | `Entry.where(entryable_type: "Message")` |
| `Entry#message?` | คืนค่า true เมื่อ `entryable_type == "Message"` |
| `Entry#message` | คืนค่าบันทึกข้อความ เมื่อ `entryable_type == "Message"` มิเช่นนั้นคืนค่า `nil` |
| `Entry#message_id` | คืนค่า `entryable_id` เมื่อ `entryable_type == "Message"` มิเช่นนั้นคืนค่า `nil` |
| `Entry.comments` | `Entry.where(entryable_type: "Comment")` |
| `Entry#comment?` | คืนค่า true เมื่อ `entryable_type == "Comment"` |
| `Entry#comment` | คืนค่าบันทึกความเห็น เมื่อ `entryable_type == "Comment"` มิเช่นนั้นคืนค่า `nil` |
| `Entry#comment_id` | คืนค่า `entryable_id` เมื่อ `entryable_type == "Comment"` มิเช่นนั้นคืนค่า `nil` |

### การสร้างวัตถุ

เมื่อสร้างวัตถุ `Entry` ใหม่ เราสามารถระบุคลาสย่อย `entryable` พร้อมกันได้

```ruby
Entry.create! entryable: Message.new(subject: "hello!")
```

### เพิ่มการจัดส่งเพิ่มเติม

เราสามารถขยายตัวจัดส่ง `Entry` และเพิ่มความสามารถได้โดยกำหนด `delegates` และใช้พอลิมอร์ฟิสซึมกับคลาสย่อย
ตัวอย่างเช่น เพื่อจัดส่งเมธอด `title` จาก `Entry` ไปยังคลาสย่อย:

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ]
  delegates :title, to: :entryable
end

class Message < ApplicationRecord
  include Entryable

  def title
    subject
  end
end

class Comment < ApplicationRecord
  include Entryable

  def title
    content.truncate(20)
  end
end
```

[`belongs_to`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
[`has_and_belongs_to_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_and_belongs_to_many
[`has_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many
[`has_one`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one
[connection.add_reference]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[foreign_keys]: active_record_migrations.html#foreign-keys
[`config.active_record.automatic_scope_inversing`]: configuring.html#config-active-record-automatic-scope-inversing
[`reset_counters`]: https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-reset_counters
[`collection<<`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-3C-3C
[`collection.build`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-build
[`collection.clear`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-clear
[`collection.create`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create
[`collection.create!`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create-21
[`collection.delete`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-delete
[`collection.destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-destroy
[`collection.empty?`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-empty-3F
[`collection.exists?`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F
[`collection.find`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-find
[`collection.reload`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-reload
[`collection.size`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-size
[`collection.where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
