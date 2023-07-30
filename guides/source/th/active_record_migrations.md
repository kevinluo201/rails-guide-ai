**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 311d5225fa32d069369256501f31c507
Active Record Migrations
========================

การเคลื่อนย้าย (Migrations) เป็นคุณสมบัติของ Active Record ที่ช่วยให้คุณสามารถพัฒนาโครงสร้างฐานข้อมูลของคุณได้ในระยะเวลาที่ต่างกัน แทนที่จะเขียนการปรับเปลี่ยนโครงสร้างด้วย SQL สามารถใช้ Migrations เพื่อใช้ Ruby DSL เพื่ออธิบายการเปลี่ยนแปลงในตารางของคุณ

หลังจากอ่านเอกสารนี้คุณจะรู้:

* ตัวสร้างที่คุณสามารถใช้สร้าง
* วิธีการใช้งาน Active Record เพื่อจัดการฐานข้อมูลของคุณ
* คำสั่งของ Rails ที่ใช้ในการจัดการ Migrations และโครงสร้างของคุณ
* วิธีการเชื่อมโยง Migrations กับ `schema.rb`

--------------------------------------------------------------------------------

ภาพรวมของ Migrations
------------------

Migrations เป็นวิธีที่สะดวกในการปรับเปลี่ยนโครงสร้างฐานข้อมูลของคุณในระยะเวลาที่สม่ำเสมอ โดยใช้ Ruby DSL เพื่อไม่ต้องเขียน SQL ด้วยตนเอง ทำให้โครงสร้างและการเปลี่ยนแปลงของคุณเป็นอิสระต่อฐานข้อมูล

คุณสามารถคิดว่าแต่ละ Migration เป็น 'เวอร์ชัน' ใหม่ของฐานข้อมูล โครงสร้างเริ่มต้นโดยไม่มีอะไรในนั้น และแต่ละ Migration จะแก้ไขโครงสร้างเพื่อเพิ่มหรือลบตาราง คอลัมน์ หรือรายการ Active Record รู้วิธีอัปเดตโครงสร้างตามไทม์ไลน์นี้ โดยนำมาจากจุดใดก็ตามในประวัติศาสตร์ไปยังเวอร์ชันล่าสุด Active Record ยังจะอัปเดตไฟล์ `db/schema.rb` เพื่อตรงกับโครงสร้างปัจจุบันของฐานข้อมูลของคุณ

นี่คือตัวอย่างของ Migration:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Migration นี้เพิ่มตารางที่ชื่อว่า `products` มีคอลัมน์ชื่อ `name` เป็น string และคอลัมน์ชื่อ `description` เป็น text คอลัมน์หลักที่ชื่อ `id` จะถูกเพิ่มอัตโนมัติเป็น primary key เริ่มต้นสำหรับ Active Record models คำสั่ง `timestamps` เพิ่มคอลัมน์สองคอลัมน์คือ `created_at` และ `updated_at` คอลัมน์พิเศษเหล่านี้จะถูกจัดการโดย Active Record โดยอัตโนมัติหากมีอยู่

โปรดทราบว่าเรากำหนดการเปลี่ยนแปลงที่เราต้องการให้เกิดขึ้นในอนาคต ก่อนที่ Migration นี้จะถูกเรียกใช้ จะไม่มีตาราง หลังจากนั้นตารางจะมีอยู่ Active Record รู้วิธีการย้อนกลับ Migration นี้เช่นกัน: หากเราย้อนกลับ Migration นี้ จะลบตารางออก

ในฐานข้อมูลที่รองรับการทำงานร่วมกับคำสั่งที่เปลี่ยนแปลงโครงสร้าง แต่ละ Migration จะถูกห่อหุ้มด้วยการทำธุรกรรม หากฐานข้อมูลไม่รองรับการทำงานนี้ เมื่อ Migration ล้มเหลว ส่วนที่สำเร็จจะไม่ถูกย้อนกลับ คุณต้องย้อนกลับการเปลี่ยนแปลงที่ทำโดยตนเอง

หมายเหตุ: มีคำถามบางอย่างที่ไม่สามารถทำงานภายในธุรกรรมได้ หากอะแดปเตอร์ของคุณรองรับธุรกรรม DDL คุณสามารถใช้ `disable_ddl_transaction!` เพื่อปิดใช้งานสำหรับ Migration เดียว

### ทำให้สิ่งที่ไม่สามารถย้อนกลับได้เป็นไปได้

หากคุณต้องการให้ Migration ทำสิ่งที่ Active Record ไม่รู้จักวิธีการย้อนกลับ คุณสามารถใช้ `reversible`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      change_table :products do |t|
        direction.up   { t.change :price, :string }
        direction.down { t.change :price, :integer }
      end
    end
  end
end
```

Migration นี้จะเปลี่ยนประเภทของคอลัมน์ `price` เป็น string หรือกลับเป็น integer เมื่อ Migration ถูกย้อนกลับ โปรดสังเกตบล็อกที่ถูกส่งให้กับ `direction.up` และ `direction.down` ตามลำดับ
หรือคุณสามารถใช้ `up` และ `down` แทน `change`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def up
    change_table :products do |t|
      t.change :price, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :price, :integer
    end
  end
end
```

INFO: ข้อมูลเพิ่มเติมเกี่ยวกับ [`reversible`](#using-reversible) จะอธิบายต่อไป

การสร้าง Migration
----------------------

### การสร้าง Migration แบบแยกต่างหาก

Migration จะถูกเก็บเป็นไฟล์ในไดเรกทอรี `db/migrate` โดยมีไฟล์หนึ่งสำหรับแต่ละคลาส migration ชื่อของไฟล์จะเป็นรูปแบบ `YYYYMMDDHHMMSS_create_products.rb` ซึ่งเป็น timestamp ของเวลา UTC ที่ระบุ migration ตามด้วย underscore และตามด้วยชื่อของ migration ชื่อของคลาส migration (รูปแบบ CamelCased) ควรตรงกับส่วนท้ายของชื่อไฟล์ ตัวอย่างเช่น `20080906120000_create_products.rb` ควรกำหนดคลาส `CreateProducts` และ `20080906120001_add_details_to_products.rb` ควรกำหนด `AddDetailsToProducts` Rails ใช้ timestamp นี้เพื่อกำหนดว่า migration ใดควรถูกเรียกใช้และในลำดับใด ดังนั้นหากคุณก๊อปปี้ migration จากแอปพลิเคชันอื่นหรือสร้างไฟล์ด้วยตัวเอง โปรดทราบตำแหน่งของมันในลำดับ

แน่นอนว่าการคำนวณ timestamp ไม่ได้สนุกเท่าไร ดังนั้น Active Record จึงมีเครื่องมือสร้างให้คุณ:

```bash
$ bin/rails generate migration AddPartNumberToProducts
```

นี้จะสร้าง migration ที่มีชื่อที่เหมาะสมและว่างเปล่า:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
  end
end
```

เครื่องมือสร้างนี้สามารถทำได้มากกว่าการเติม timestamp ลงในชื่อไฟล์ โดยอ้างอิงตามกฎการตั้งชื่อและอาร์กิวเมนต์เพิ่มเติม (ที่เป็นตัวเลือก) สามารถเติมเนื้อหาให้กับ migration ได้ด้วย

### เพิ่มคอลัมน์ใหม่

หากชื่อ migration เป็นรูปแบบ "AddColumnToTable" หรือ "RemoveColumnFromTable" และตามด้วยรายชื่อคอลัมน์และประเภท จะสร้าง migration ที่มีคำสั่ง [`add_column`][] และ [`remove_column`][] ที่เหมาะสม

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

นี้จะสร้าง migration ต่อไปนี้:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
  end
end
```

หากคุณต้องการเพิ่มดัชนีในคอลัมน์ใหม่ คุณสามารถทำได้เช่นกัน

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

นี้จะสร้างคำสั่ง [`add_column`][] และ [`add_index`][] ที่เหมาะสม:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

คุณ **ไม่จำกัด** ในการสร้างคอลัมน์ที่สร้างขึ้นโดยอัตโนมัติ ตัวอย่างเช่น:

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

จะสร้าง migration สกีมาที่เพิ่มคอลัมน์สองคอลัมน์เพิ่มเติมในตาราง `products`

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

### ลบคอลัมน์

เช่นเดียวกันคุณสามารถสร้าง migration เพื่อลบคอลัมน์จาก command line:

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

นี้จะสร้างคำสั่ง [`remove_column`][] ที่เหมาะสม:

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :part_number, :string
  end
end
```

### สร้างตารางใหม่

หากชื่อ migration เป็นรูปแบบ "CreateXXX" และตามด้วยรายชื่อคอลัมน์และประเภท จะสร้าง migration ที่สร้างตาราง XXX พร้อมคอลัมน์ที่ระบุ ตัวอย่างเช่น:

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```
สร้าง

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :part_number

      t.timestamps
    end
  end
end
```

เช่นเคย สิ่งที่ถูกสร้างขึ้นมาให้คุณเป็นจุดเริ่มต้นเท่านั้น
คุณสามารถเพิ่มหรือลบได้ตามต้องการโดยแก้ไขไฟล์ `db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb` 

### สร้างความสัมพันธ์โดยใช้ references

นอกจากนี้ โปรแกรมสร้างยังรองรับประเภทคอลัมน์เป็น `references` (ที่มีให้ใช้เป็น `belongs_to` ด้วย) เช่น

```bash
$ bin/rails generate migration AddUserRefToProducts user:references
```

จะสร้าง [`add_reference`][] ดังต่อไปนี้:

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

การเปลี่ยนแปลงนี้จะสร้างคอลัมน์ `user_id` [References](#references) เป็นการสร้างคอลัมน์, ดัชนี, คีย์ต่างประเทศ หรือแม้กระทั่งคอลัมน์สัมพันธ์หลากหลาย

ยังมีโปรแกรมสร้างที่จะสร้างตารางเชื่อมต่อถ้า `JoinTable` เป็นส่วนหนึ่งของชื่อ:

```bash
$ bin/rails generate migration CreateJoinTableCustomerProduct customer product
```

จะสร้างการเปลี่ยนแปลงต่อไปนี้:

```ruby
class CreateJoinTableCustomerProduct < ActiveRecord::Migration[7.1]
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
    end
  end
end
```


### โปรแกรมสร้างโมเดล

โปรแกรมสร้างโมเดล, ทรัพยากร, และสคริปต์จะสร้างการเปลี่ยนแปลงที่เหมาะสมสำหรับการเพิ่มโมเดลใหม่ การเปลี่ยนแปลงนี้จะมีคำสั่งสร้างตารางที่เกี่ยวข้องอยู่แล้ว หากคุณบอกให้ Rails รู้ว่าคุณต้องการคอลัมน์ใด คำสั่งสร้างคอลัมน์เหล่านี้จะถูกสร้างขึ้นด้วย เช่น การรัน:

```bash
$ bin/rails generate model Product name:string description:text
```

จะสร้างการเปลี่ยนแปลงที่มีลักษณะดังนี้:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

คุณสามารถเพิ่มคู่ชื่อคอลัมน์/ประเภทเท่าที่คุณต้องการ

### ส่งผ่านตัวดัดแปลง

บางครั้งคุณอาจส่งผ่าน [type modifiers](#column-modifiers) ที่ใช้บ่อยได้โดยตรงในบรรทัดคำสั่ง โดยใส่ในเครื่องหมายวงเล็บปีกกาและตามด้วยประเภทของฟิลด์:

ตัวอย่างเช่นการรัน:

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

จะสร้างการเปลี่ยนแปลงที่มีลักษณะดังนี้

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

เคล็ดลับ: ดูคำสั่งช่วยของโปรแกรมสร้าง (`bin/rails generate --help`) สำหรับรายละเอียดเพิ่มเติม

เขียนการเปลี่ยนแปลง
------------------

เมื่อคุณสร้างการเปลี่ยนแปลงของคุณด้วยโปรแกรมสร้างหนึ่งในนั้นเป็นเวลาที่จะทำงาน!

### สร้างตาราง

เมธอด [`create_table`][] เป็นหนึ่งในเมธอดที่สำคัญที่สุด แต่ส่วนใหญ่จะถูกสร้างขึ้นให้คุณจากการใช้โปรแกรมสร้างโมเดล, ทรัพยากร, หรือสคริปต์ การใช้งานทั่วไปคือ

```ruby
create_table :products do |t|
  t.string :name
end
```

เมธอดนี้จะสร้างตาราง `products` พร้อมคอลัมน์ชื่อ `name`

โดยค่าเริ่มต้น `create_table` จะสร้าง primary key ที่ชื่อ `id` ให้คุณ คุณสามารถเปลี่ยนชื่อคอลัมน์ด้วยตัวเลือก `:primary_key` หรือหากคุณไม่ต้องการ primary key เลย คุณสามารถส่งตัวเลือก `id: false` 

หากคุณต้องการส่งตัวเลือกที่เฉพาะเจาะจงของฐานข้อมูลคุณสามารถใส่ฟรากเมนต์ SQL ในตัวเลือก `:options` เช่น:

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

นี้จะเพิ่ม `ENGINE=BLACKHOLE` เข้าไปในคำสั่ง SQL ที่ใช้สร้างตาราง

สามารถสร้างดัชนีบนคอลัมน์ที่สร้างภายในบล็อก `create_table` โดยใช้ `index: true` หรือ options hash กับ `:index` option:

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

นอกจากนี้คุณยังสามารถส่ง `:comment` option พร้อมกับคำอธิบายใด ๆ สำหรับตารางที่จะถูกเก็บไว้ในฐานข้อมูลเองและสามารถดูได้ด้วยเครื่องมือการจัดการฐานข้อมูล เช่น MySQL Workbench หรือ PgAdmin III แนะนำอย่างยิ่งให้ระบุความคิดเห็นในการโยกย้ายสำหรับแอปพลิเคชันที่มีฐานข้อมูลขนาดใหญ่เนื่องจากมันช่วยให้ผู้คนเข้าใจโมเดลข้อมูลและสร้างเอกสารได้ ปัจจุบันเฉพาะ MySQL และ PostgreSQL adapters รองรับความคิดเห็นเท่านั้น


### การสร้างตารางเชื่อมต่อ

วิธีการโยกย้าย [`create_join_table`][] สร้างตารางเชื่อมต่อ HABTM (has and belongs to many) การใช้งานทั่วไปคือ:

```ruby
create_join_table :products, :categories
```

การโยกย้ายนี้จะสร้างตาราง `categories_products` ที่มีคอลัมน์สองคอลัมน์ที่เรียกว่า `category_id` และ `product_id`

คอลัมน์เหล่านี้มีตัวเลือก `:null` ที่ตั้งค่าเป็น `false` โดยค่าเริ่มต้นซึ่งหมายความว่าคุณต้องระบุค่าเพื่อบันทึกบันทึกในตารางนี้ สามารถเปลี่ยนแปลงได้โดยระบุ `:column_options` option:

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

ตามค่าเริ่มต้นชื่อของตารางเชื่อมต่อมาจากการรวมของอาร์กิวเมนต์สองตัวแรกที่ให้กับ create_join_table ตามลำดับตัวอักษร

ในการปรับแต่งชื่อของตาราง ให้ใช้ `:table_name` option:

```ruby
create_join_table :products, :categories, table_name: :categorization
```

นี้จะตั้งชื่อตารางเชื่อมต่อเป็น `categorization` ตามที่ร้องขอ

นอกจากนี้ `create_join_table` ยอมรับ block ซึ่งคุณสามารถใช้เพื่อเพิ่มดัชนี (ซึ่งไม่ถูกสร้างโดยค่าเริ่มต้น) หรือคอลัมน์เพิ่มเติมตามที่คุณต้องการ

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```


### การเปลี่ยนแปลงตาราง

หากคุณต้องการเปลี่ยนแปลงตารางที่มีอยู่ในที่เดียว ใช้ [`change_table`][]

มันถูกใช้ในลักษณะที่คล้ายกับ `create_table` แต่วัตถุที่ yield ภายในบล็อกสามารถเข้าถึงฟังก์ชันพิเศษหลายอย่าง เช่น:

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

การโยกย้ายนี้จะลบคอลัมน์ `description` และ `name` สร้างคอลัมน์สตริงใหม่ที่เรียกว่า `part_number` และเพิ่มดัชนีในนั้น ในที่สุดจะเปลี่ยนชื่อคอลัมน์ `upccode` เป็น `upc_code`


### เปลี่ยนคอลัมน์

คล้ายกับเมธอด `remove_column` และ `add_column` ที่เราได้พูดถึง
[ก่อนหน้านี้](#adding-new-columns) Rails ยังให้ [`change_column`][] ในการโยกย้าย

```ruby
change_column :products, :part_number, :text
```

นี้เปลี่ยนคอลัมน์ `part_number` บนตารางสินค้าให้เป็นฟิลด์ `:text`

หมายเหตุ: คำสั่ง `change_column` ไม่สามารถย้อนกลับได้
คุณควรจะให้การโยกย้ายที่สามารถย้อนกลับได้ของคุณเอง เหมือนที่เราได้พูดถึง
[ก่อนหน้านี้](#making-the-irreversible-possible)

นอกจาก `change_column` ยังมี [`change_column_null`][] และ [`change_column_default`][]
ใช้เฉพาะในการเปลี่ยนการจำกัดความว่างเปล่าและค่าเริ่มต้นของคอลัมน์

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

นี้ตั้งค่าฟิลด์ `:name` บนสินค้าให้เป็นคอลัมน์ `NOT NULL` และค่าเริ่มต้น
ของฟิลด์ `:approved` จาก true เป็น false การเปลี่ยนแปลงทั้งสองนี้จะ
ถูกใช้กับธุรกรรมที่เกิดขึ้นในอนาคตเท่านั้น ไม่มีการใช้กับบันทึกที่มีอยู่อยู่
เมื่อตั้งค่า null constraint เป็น true นั่นหมายความว่าคอลัมน์จะยอมรับค่า null ในกรณีที่ไม่ได้กำหนดค่า null constraint เป็น `NOT NULL` และจะต้องมีการส่งค่าเพื่อบันทึกข้อมูลลงในฐานข้อมูล

หมายเหตุ: คุณยังสามารถเขียน migration `change_column_default` ดังกล่าวเป็น `change_column_default :products, :approved, false` แต่ไม่เหมือนตัวอย่างก่อนหน้านี้ การทำเช่นนั้นจะทำให้ไม่สามารถย้อนกลับการ migration ได้

### ตัวแปรคอลัมน์

ตัวแปรคอลัมน์สามารถใช้ได้เมื่อสร้างหรือเปลี่ยนแปลงคอลัมน์:

* `comment` เพิ่มความคิดเห็นสำหรับคอลัมน์
* `collation` ระบุการจัดเรียงสำหรับคอลัมน์ `string` หรือ `text`
* `default` อนุญาตให้กำหนดค่าเริ่มต้นในคอลัมน์ โปรดทราบว่าหากคุณใช้ค่าที่เปลี่ยนแปลงได้ (เช่นวันที่) ค่าเริ่มต้นจะถูกคำนวณเพียงครั้งเดียว (เช่นในวันที่ migration ถูกนำมาใช้) ใช้ `nil` สำหรับ `NULL`
* `limit` กำหนดจำนวนสูงสุดของตัวอักษรสำหรับคอลัมน์ `string` และจำนวนสูงสุดของไบต์สำหรับคอลัมน์ `text/binary/integer`
* `null` อนุญาตหรือไม่อนุญาตให้ใช้ค่า `NULL` ในคอลัมน์
* `precision` ระบุความแม่นยำสำหรับคอลัมน์ `decimal/numeric/datetime/time`
* `scale` ระบุสเกลสำหรับคอลัมน์ `decimal` และ `numeric` ซึ่งแทนจำนวนหลักหลังจุดทศนิยม

หมายเหตุ: สำหรับ `add_column` หรือ `change_column` ไม่มีตัวเลือกในการเพิ่มดัชนี ต้องเพิ่มดัชนีแยกต่างหากโดยใช้ `add_index`

บางแอดาปเตอร์อาจรองรับตัวเลือกเพิ่มเติม โปรดดูเอกสาร API ของแอดาปเตอร์เพื่อข้อมูลเพิ่มเติม

หมายเหตุ: ไม่สามารถระบุ `null` และ `default` ผ่าน command line เมื่อสร้าง migration

### การอ้างอิง

เมธอด `add_reference` ช่วยในการสร้างคอลัมน์ที่มีชื่อที่เหมาะสมเพื่อเป็นการเชื่อมโยงระหว่างการสัมพันธ์หนึ่งหรือมากกว่า

```ruby
add_reference :users, :role
```

Migration นี้จะสร้างคอลัมน์ `role_id` ในตาราง users และสร้างดัชนีสำหรับคอลัมน์นี้ด้วย ยกเว้นถ้าระบุให้ไม่สร้างดัชนีด้วยตัวเลือก `index: false`

ข้อมูลเพิ่มเติม: ดูเพิ่มเติมใน [Active Record Associations][] เพื่อเรียนรู้เพิ่มเติม

เมธอด `add_belongs_to` เป็นตัวย่อของ `add_reference`

```ruby
add_belongs_to :taggings, :taggable, polymorphic: true
```

ตัวเลือก polymorphic จะสร้างคอลัมน์สองคอลัมน์ในตาราง taggings ที่สามารถใช้สำหรับการสัมพันธ์ polymorphic: `taggable_type` และ `taggable_id`

ข้อมูลเพิ่มเติม: ดูเพิ่มเติมในเอกสารนี้เพื่อเรียนรู้เพิ่มเติมเกี่ยวกับ [การสัมพันธ์ polymorphic][]

สามารถสร้าง foreign key ด้วยตัวเลือก `foreign_key`

```ruby
add_reference :users, :role, foreign_key: true
```

สำหรับตัวเลือก `add_reference` เพิ่มเติม ดูที่ [เอกสาร API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference)

อ้างอิงสามารถถูกลบได้เช่นกัน:

```ruby
remove_reference :products, :user, foreign_key: true, index: false
```

[Active Record Associations]: association_basics.html
[การสัมพันธ์ polymorphic]: association_basics.html#polymorphic-associations

### คีย์ต่างประเทศ

แม้จะไม่จำเป็น แต่คุณอาจต้องการเพิ่มการจำกัดความสัมพันธ์ต่างประเทศเพื่อ [รับรองความสอดคล้องทางอ้างอิง](#active-record-and-referential-integrity)

```ruby
add_foreign_key :articles, :authors
```

การเรียกใช้ [`add_foreign_key`][] นี้เพิ่มการจำกัดความสัมพันธ์ใหม่ในตาราง `articles` การจำกัดความสัมพันธ์รับประกันว่ามีแถวในตาราง `authors` ที่ตรงกับคอลัมน์ `id` ใน `articles.author_id`

หากไม่สามารถระบุชื่อคอลัมน์ `from_table` จากชื่อ `to_table` ได้ คุณสามารถใช้ตัวเลือก `:column` ใช้ตัวเลือก `:primary_key` หาก primary key ที่อ้างอิงไม่ใช่ `:id`

ตัวอย่างเช่น เพื่อเพิ่มคีย์ต่างประเทศบน `articles.reviewer` ที่อ้างอิง `authors.email`:
```ruby
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

การใช้งานนี้จะเพิ่มข้อจำกัดในตาราง `articles` ที่รับประกันว่ามีแถวในตาราง `authors` ที่ตรงกับคอลัมน์ `email` ในฟิลด์ `articles.reviewer` 

มีตัวเลือกอื่น ๆ ที่รองรับเช่น `name`, `on_delete`, `if_not_exists`, `validate`, และ `deferrable` โดย `add_foreign_key`

Foreign key ยังสามารถถูกลบได้โดยใช้ [`remove_foreign_key`][]:

```ruby
# ให้ Active Record กำหนดชื่อคอลัมน์
remove_foreign_key :accounts, :branches

# ลบ foreign key สำหรับคอลัมน์ที่ระบุ
remove_foreign_key :accounts, column: :owner_id
```

หมายเหตุ: Active Record รองรับเฉพาะ foreign key ที่มีคอลัมน์เดียวเท่านั้น ต้องใช้ `execute` และ `structure.sql` เพื่อใช้งาน composite foreign key ดูเพิ่มเติมที่ [Schema Dumping and You](#schema-dumping-and-you).

### เมื่อ Helpers ไม่เพียงพอ

หาก helpers ที่ Active Record จัดหาไม่เพียงพอ คุณสามารถใช้เมธอด [`execute`][] เพื่อ execute SQL อย่างอิสระ:

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

สำหรับรายละเอียดและตัวอย่างเพิ่มเติมของเมธอดแต่ละเมธอด โปรดตรวจสอบเอกสาร API

โดยเฉพาะเอกสารสำหรับ [`ActiveRecord::ConnectionAdapters::SchemaStatements`][] ซึ่งให้เมธอดที่ใช้ได้ในเมธอด `change`, `up` และ `down`

สำหรับเมธอดที่ใช้ได้เกี่ยวกับวัตถุที่ถูก yield โดย `create_table` ดูที่ [`ActiveRecord::ConnectionAdapters::TableDefinition`][]

และสำหรับวัตถุที่ถูก yield โดย `change_table` ดูที่ [`ActiveRecord::ConnectionAdapters::Table`][]

### การใช้งานเมธอด `change`

เมธอด `change` เป็นวิธีหลักในการเขียน migration มันทำงานสำหรับกรณีส่วนใหญ่ที่ Active Record รู้วิธีการย้อนกลับของการกระทำใน migration โดยอัตโนมัติ ด้านล่างคือบางการกระทำที่ `change` รองรับ:

* [`add_check_constraint`][]
* [`add_column`][]
* [`add_foreign_key`][]
* [`add_index`][]
* [`add_reference`][]
* [`add_timestamps`][]
* [`change_column_comment`][] (ต้องระบุ `:from` และ `:to`)
* [`change_column_default`][] (ต้องระบุ `:from` และ `:to`)
* [`change_column_null`][]
* [`change_table_comment`][] (ต้องระบุ `:from` และ `:to`)
* [`create_join_table`][]
* [`create_table`][]
* `disable_extension`
* [`drop_join_table`][]
* [`drop_table`][] (ต้องระบุ block)
* `enable_extension`
* [`remove_check_constraint`][] (ต้องระบุ constraint expression)
* [`remove_column`][] (ต้องระบุประเภท)
* [`remove_columns`][] (ต้องระบุ `:type`)
* [`remove_foreign_key`][] (ต้องระบุตารางที่สอง)
* [`remove_index`][]
* [`remove_reference`][]
* [`remove_timestamps`][]
* [`rename_column`][]
* [`rename_index`][]
* [`rename_table`][]

[`change_table`][] ยังสามารถย้อนกลับได้ ตราบเท่าที่ block เรียกใช้งานเพียงการดำเนินการที่สามารถย้อนกลับได้เท่านั้น

`remove_column` สามารถย้อนกลับได้หากคุณระบุประเภทคอลัมน์เป็นอาร์กิวเมนต์ที่สาม ให้ระบุตัวเลือกคอลัมน์เดิมด้วย มิฉะนั้น Rails จะไม่สามารถสร้างคอลัมน์ใหม่ได้อย่างแม่นยำเมื่อย้อนกลับ:

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

หากคุณต้องการใช้เมธอดอื่น ๆ คุณควรใช้ `reversible` หรือเขียนเมธอด `up` และ `down` แทนการใช้เมธอด `change`

### การใช้งาน `reversible`

Migration ที่ซับซ้อนอาจต้องการการประมวลผลที่ Active Record ไม่รู้วิธีการย้อนกลับ คุณสามารถใช้ [`reversible`][] เพื่อระบุว่าจะทำอะไรเมื่อเรียกใช้ migration และทำอะไรเพิ่มเติมเมื่อย้อนกลับ ตัวอย่างเช่น:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # สร้าง distributors view
        execute <<-SQL
          CREATE VIEW distributors_view AS
          SELECT id, zipcode
          FROM distributors;
        SQL
      end
      direction.down do
        execute <<-SQL
          DROP VIEW distributors_view;
        SQL
      end
    end

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
end
```

การใช้ `reversible` จะทำให้คำสั่งถูกดำเนินการตามลำดับที่ถูกต้องด้วย หากการย้อนกลับการโยกย้ายตัวอย่างก่อนหน้านี้ถูกเรียกคืน บล็อก `down` จะถูกเรียกใช้หลังจากที่คอลัมน์ `home_page_url` ถูกลบและคอลัมน์ `email_address` ถูกเปลี่ยนชื่อและก่อนที่ตาราง `distributors` จะถูกลบ

### การใช้เมธอด `up`/`down`

คุณยังสามารถใช้รูปแบบการโยกย้ายเก่าๆ โดยใช้เมธอด `up` และ `down` แทนเมธอด `change`

เมธอด `up` ควรอธิบายการเปลี่ยนแปลงที่คุณต้องการทำกับสกีมาของคุณ และเมธอด `down` ของการโยกย้ายควรย้อนกลับการเปลี่ยนแปลงที่ทำโดยเมธอด `up` กล่าวอีกนัยหนึ่ง สกีมาฐานข้อมูลควรไม่เปลี่ยนแปลงหากคุณทำ `up` ตามด้วย `down`

ตัวอย่างเช่น หากคุณสร้างตารางในเมธอด `up` คุณควรลบตารางนั้นในเมธอด `down` การดำเนินการควรทำในลำดับที่ถูกต้องตามที่ทำในเมธอด `up` ตัวอย่างในส่วน `reversible` เทียบเท่ากับ:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # สร้างมุมมองของผู้จัดจำหน่าย
    execute <<-SQL
      CREATE VIEW distributors_view AS
      SELECT id, zipcode
      FROM distributors;
    SQL

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end

  def down
    rename_column :users, :email_address, :email
    remove_column :users, :home_page_url

    execute <<-SQL
      DROP VIEW distributors_view;
    SQL

    drop_table :distributors
  end
end
```

### การสร้างข้อผิดพลาดเพื่อป้องกันการย้อนกลับ

บางครั้งการโยกย้ายของคุณอาจทำบางอย่างที่ไม่สามารถย้อนกลับได้เช่น อาจทำลายข้อมูลบางส่วน

ในกรณีเช่นนี้คุณสามารถเรียก `ActiveRecord::IrreversibleMigration` ในบล็อก `down` ของคุณ

หากมีคนพยายามย้อนกลับการโยกย้ายของคุณ จะแสดงข้อความข้อผิดพลาดที่บอกว่าไม่สามารถทำได้

### การย้อนกลับการโยกย้ายก่อนหน้านี้

คุณสามารถใช้ความสามารถของ Active Record ในการย้อนกลับการโยกย้ายโดยใช้เมธอด [`revert`][]:

```ruby
require_relative "20121212123456_example_migration"

class FixupExampleMigration < ActiveRecord::Migration[7.1]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

เมธอด `revert` ยังรับบล็อกของคำสั่งในการย้อนกลับได้ สิ่งนี้อาจเป็นประโยชน์ในการย้อนกลับส่วนที่เลือกได้ของการโยกย้ายก่อนหน้า

ตัวอย่างเช่น สมมุติว่า `ExampleMigration` ถูกเก็บรักษาและตัดสินใจว่าไม่จำเป็นต้องใช้ Distributors view อีกต่อไป

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.1]
  def change
    revert do
      # คัดลอกโค้ดจาก ExampleMigration
      reversible do |direction|
        direction.up do
          # สร้างมุมมองของผู้จัดจำหน่าย
          execute <<-SQL
            CREATE VIEW distributors_view AS
            SELECT id, zipcode
            FROM distributors;
          SQL
        end
        direction.down do
          execute <<-SQL
            DROP VIEW distributors_view;
          SQL
        end
      end

      # ส่วนที่เหลือของการโยกย้ายเป็นปกติ
    end
  end
end
```

การโยกย้ายเดียวกันอาจถูกเขียนโดยไม่ใช้ `revert` แต่นี้อาจเกี่ยวข้องกับขั้นตอนเพิ่มเติม:

1. สลับลำดับของ `create_table` และ `reversible`
2. แทนที่ `create_table` ด้วย `drop_table`
3. สุดท้าย แทนที่ `up` ด้วย `down` และ `down` ด้วย `up`

การดูแลทั้งหมดนี้ถูกดูแลโดย `revert`


การเรียกใช้การโยกย้าย
------------------

Rails มีชุดคำสั่งในการเรียกใช้การโยกย้ายบางชุด

คำสั่งเกี่ยวกับการโยกย้ายที่เกี่ยวข้องกับเรลส์คำสั่งแรกที่คุณจะใช้คือ `bin/rails db:migrate` ในรูปแบบที่ง่ายที่สุด มันจะเรียกใช้เมธอด `change` หรือ `up` สำหรับการโยกย้ายทั้งหมดที่ยังไม่ได้รัน หากไม่มีการโยกย้ายเช่นนั้นมันจะออก มันจะเรียกใช้การโยกย้ายเหล่านี้ตามลำดับตามวันที่ของการโยกย้าย
โปรดทราบว่าการเรียกใช้คำสั่ง `db:migrate` ยังเรียกใช้คำสั่ง `db:schema:dump` ซึ่งจะอัปเดตไฟล์ `db/schema.rb` เพื่อให้ตรงกับโครงสร้างของฐานข้อมูลของคุณ

หากคุณระบุเวอร์ชันเป้าหมาย Active Record จะเรียกใช้การเรียกใช้งานของการเมืองที่จำเป็น (เปลี่ยน, เริ่ม, ยกเลิก) จนกว่าจะได้รับเวอร์ชันที่ระบุ รหัสเวอร์ชันคือคำนำหน้าตัวเลขในชื่อไฟล์ของการเรียกใช้งาน ตัวอย่างเช่น เพื่อเรียกใช้การเรียกใช้งานเวอร์ชัน 20080906120000 ให้เรียกใช้:

```bash
$ bin/rails db:migrate VERSION=20080906120000
```

หากเวอร์ชัน 20080906120000 มากกว่าเวอร์ชันปัจจุบัน (กล่าวคือกำลังย้ายขึ้น) นี้จะเรียกใช้เมธอด `change` (หรือ `up`) ในการเรียกใช้งานทั้งหมด จนถึง 20080906120000 และจะไม่เรียกใช้งานการเรียกใช้งานที่เกิดขึ้นในภายหลัง หากกำลังย้ายลง นี้จะเรียกใช้เมธอด `down` ในการเรียกใช้งานทั้งหมด จนถึง 20080906120000 แต่ไม่รวมถึง

### ย้อนกลับ

งานที่พบบ่อยคือการย้อนกลับการเรียกใช้งานล่าสุด ตัวอย่างเช่นหากคุณทำข้อผิดพลาดในการเรียกใช้งานและต้องการแก้ไข แทนที่จะติดตามหมายเลขเวอร์ชันที่เกี่ยวข้องกับการเรียกใช้งานก่อนหน้านี้คุณสามารถเรียกใช้:

```bash
$ bin/rails db:rollback
```

นี้จะย้อนกลับการเรียกใช้งานล่าสุด โดยการย้อนกลับเมธอด `change` หรือการเรียกใช้งานเมธอด `down` หากคุณต้องการย้อนกลับการเรียกใช้งานหลายรุ่นคุณสามารถระบุพารามิเตอร์ `STEP`:

```bash
$ bin/rails db:rollback STEP=3
```

รุ่นล่าสุด 3 จะถูกย้อนกลับ

คำสั่ง `db:migrate:redo` เป็นทางลัดในการย้อนกลับและจากนั้นย้ายขึ้นอีกครั้ง อย่างเช่นเดียวกับคำสั่ง `db:rollback` คุณสามารถใช้พารามิเตอร์ `STEP` หากคุณต้องการย้อนกลับมากกว่าหนึ่งรุ่นย้อนหลัง เช่น:

```bash
$ bin/rails db:migrate:redo STEP=3
```

ไม่มีคำสั่งเรลส์เหล่านี้ทำอะไรที่คุณไม่สามารถทำได้ด้วย `db:migrate` พวกเขาอยู่ที่นั่นเพื่อความสะดวก เนื่องจากคุณไม่จำเป็นต้องระบุเวอร์ชันที่จะย้าย

### ติดตั้งฐานข้อมูล

คำสั่ง `bin/rails db:setup` จะสร้างฐานข้อมูลโหลดสกีมาและเริ่มต้นด้วยข้อมูลเมล็ด

### รีเซ็ตฐานข้อมูล

คำสั่ง `bin/rails db:reset` จะลบฐานข้อมูลและตั้งค่าใหม่ นี่เป็นเทียบเท่ากับ `bin/rails db:drop db:setup`

หมายเหตุ: นี่ไม่เหมือนกับการเรียกใช้งานการเรียกใช้งานทั้งหมด มันจะใช้เฉพาะเนื้อหาของไฟล์ `db/schema.rb` หรือ `db/structure.sql` ปัจจุบัน
หากไม่สามารถย้อนกลับการเรียกใช้งานได้ `bin/rails db:reset` อาจไม่ช่วยคุณ หากต้องการดูข้อมูลเพิ่มเติมเกี่ยวกับการดัมพ์สกีมาดูในส่วน [การดัมพ์สกีมาและคุณ][]

[การดัมพ์สกีมาและคุณ]: #การดัมพ์สกีมาและคุณ

### การเรียกใช้งานการเรียกใช้งานเฉพาะ

หากคุณต้องการเรียกใช้งานการเรียกใช้งานเฉพาะขึ้นหรือลง คำสั่ง `db:migrate:up` และ `db:migrate:down` จะทำเช่นนั้น เพียงระบุเวอร์ชันที่เหมาะสมและการเรียกใช้งานที่เกี่ยวข้องจะมีเมธอด `change`, `up` หรือ `down` ถูกเรียกใช้ เช่น:

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

โดยการเรียกใช้คำสั่งนี้ เมธอด `change` (หรือ `up` เมธอด) จะถูกเรียกใช้สำหรับการเรียกใช้งานที่มีเวอร์ชัน "20080906120000"

ก่อนอื่นคำสั่งนี้จะตรวจสอบว่าการเรียกใช้งานมีอยู่และถ้ามีการดำเนินการไปแล้วจะไม่ทำอะไร

หากไม่มีเวอร์ชันที่ระบุ Rails จะโยนข้อยกเว้น

```bash
$ bin/rails db:migrate VERSION=zomg
rails aborted!
ActiveRecord::UnknownMigrationVersionError:

ไม่มีการเรียกใช้งานที่มีหมายเลขเวอร์ชัน zomg
```
### การรันการเมืองในสภาพแวดล้อมที่แตกต่างกัน

โดยค่าเริ่มต้นการรัน `bin/rails db:migrate` จะทำงานในสภาพแวดล้อม `development` 

ในการรันการเมืองในสภาพแวดล้อมอื่น ๆ คุณสามารถระบุได้โดยใช้ตัวแปรสภาพแวดล้อม `RAILS_ENV` ขณะที่รันคำสั่ง ตัวอย่างเช่นในการรันการเมืองในสภาพแวดล้อม `test` คุณสามารถรันได้ดังนี้:

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### เปลี่ยนแปลงผลลัพธ์ของการรันการเมือง

โดยค่าเริ่มต้นการรันการเมืองจะแสดงให้คุณทราบถึงสิ่งที่พวกเขากำลังทำและใช้เวลานานเท่าใด การรันการเมืองที่สร้างตารางและเพิ่มดัชนีอาจสร้างผลลัพธ์ดังนี้

```
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

มีการให้บริการหลายวิธีในการรันการเมืองที่ช่วยให้คุณควบคุมทั้งหมดนี้ได้:

| วิธีการ                     | วัตถุประสงค์
| -------------------------- | -------
| [`suppress_messages`][]    | รับบล็อกเป็นอาร์กิวเมนต์และยกเลิกการแสดงผลที่สร้างขึ้นโดยบล็อก
| [`say`][]                  | รับอาร์กิวเมนต์ข้อความและแสดงผลเป็นอย่างเดียว สามารถระบุอาร์กิวเมนต์ boolean ที่สองเพื่อระบุว่าจะเยื้องหรือไม่
| [`say_with_time`][]        | แสดงข้อความพร้อมกับเวลาที่ใช้ในการเรียกใช้บล็อก หากบล็อกส่งคืนจำนวนเต็ม จะถือว่าเป็นจำนวนแถวที่ได้รับผลกระทบ

ตัวอย่างเช่น ดูการเมืองต่อไปนี้:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    suppress_messages do
      create_table :products do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say "Created a table"

    suppress_messages { add_index :products, :name }
    say "and an index!", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end
```

จะสร้างผลลัพธ์ดังนี้:

```
==  CreateProducts: migrating =================================================
-- Created a table
   -> and an index!
-- Waiting for a while
   -> 10.0013s
   -> 250 rows
==  CreateProducts: migrated (10.0054s) =======================================
```

หากคุณต้องการให้ Active Record ไม่แสดงผลใด ๆ คุณสามารถรัน `bin/rails db:migrate VERBOSE=false` เพื่อยกเลิกการแสดงผลทั้งหมด

การเปลี่ยนแปลงการเมืองที่มีอยู่
----------------------------

บางครั้งคุณอาจทำข้อผิดพลาดเมื่อเขียนการเมือง หากคุณได้รันการเมืองไปแล้ว คุณจะไม่สามารถแก้ไขการเมืองและรันการเมืองอีกครั้งได้: Rails คิดว่าการเมืองได้รันไปแล้ว ดังนั้นจะไม่ทำอะไรเมื่อคุณรัน `bin/rails db:migrate` คุณต้องย้อนกลับการเมือง (ตัวอย่างเช่นด้วย `bin/rails db:rollback`) แก้ไขการเมืองของคุณและจากนั้นรัน `bin/rails db:migrate` เพื่อรันเวอร์ชันที่แก้ไขแล้ว

โดยทั่วไปแล้ว การแก้ไขการเมืองที่มีอยู่ไม่ใช่ไอเดียที่ดี คุณจะสร้างงานเพิ่มให้กับตัวเองและเพื่อนร่วมงานของคุณและทำให้เกิดปัญหาใหญ่หากเวอร์ชันที่มีอยู่ของการเมืองได้รับการรันบนเครื่องเซิร์ฟเวอร์การผลิต

แทนที่คุณควรเขียนการเมืองใหม่ที่ดำเนินการเปลี่ยนแปลงที่คุณต้องการ การแก้ไขการเมืองที่สร้างขึ้นใหม่ที่ยังไม่ได้รับการควบคุมระบบควบคุมเวอร์ชัน (หรือโดยทั่วไปที่ยังไม่ได้ถูกแพร่กระจายไปเกินเครื่องพัฒนาของคุณ) จะไม่เป็นอันตราย

เมื่อเขียนการเมืองใหม่ เมธอด `revert` สามารถช่วยให้คุณย้อนกลับการเมืองก่อนหน้าทั้งหมดหรือบางส่วนได้ (ดู [การย้อนกลับการเมืองก่อนหน้า][] ด้านบน)

[การย้อนกลับการเมืองก่อนหน้า]: #การย้อนกลับการเมืองก่อนหน้า

การสร้างสกีมาและคุณ
----------------------

### ไฟล์สกีมาใช้ทำอะไร?

การเมืองที่มีความสามารถอย่างมากอย่างไรก็ตาม ไม่ใช่แหล่งข้อมูลที่เป็นอำนาจสำหรับโครงสร้างฐานข้อมูลของคุณ **ฐานข้อมูลของคุณยังคงเป็นแหล่งข้อมูลที่เป็นความจริง**


โดยค่าเริ่มต้น Rails จะสร้าง `db/schema.rb` ซึ่งพยายามจะบันทึกสถานะปัจจุบันของ schema ฐานข้อมูลของคุณ

มันมักจะเร็วกว่าและน้อยข้อผิดพลาดกว่าที่จะสร้างฐานข้อมูลของแอปพลิเคชันของคุณใหม่โดยโหลดไฟล์ schema ผ่าน `bin/rails db:schema:load` กว่าที่จะเล่น migration history ทั้งหมด
[Old migrations][] อาจล้มเหลวในการใช้งานอย่างถูกต้องหาก migration เหล่านั้นใช้ external dependencies ที่เปลี่ยนแปลงหรือพฤติกรรมของแอปพลิเคชันที่เปลี่ยนไปแยกจาก migrations ของคุณ

ไฟล์ schema ยังเป็นประโยชน์หากคุณต้องการดูคุณสมบัติของออบเจ็กต์ Active Record ว่ามีอะไรบ้าง ข้อมูลนี้ไม่ได้อยู่ในโค้ดของโมเดลและแบ่งอยู่ใน migrations หลายๆ ตัว แต่ข้อมูลถูกสรุปไว้ในไฟล์ schema

[Old migrations]: #old-migrations

### ประเภทของ Schema Dumps

รูปแบบของ schema dump ที่ถูกสร้างขึ้นโดย Rails จะถูกควบคุมโดยการตั้งค่า [`config.active_record.schema_format`][] ที่กำหนดไว้ใน `config/application.rb` โดยค่าเริ่มต้นคือ `:ruby` หรือสามารถตั้งค่าเป็น `:sql` ได้

#### การใช้ `:ruby` schema ค่าเริ่มต้น

เมื่อเลือก `:ruby` แล้ว schema จะถูกเก็บไว้ใน `db/schema.rb` หากคุณดูไฟล์นี้คุณจะพบว่ามันคล้ายกับ migration ที่มีขนาดใหญ่มาก:

```ruby
ActiveRecord::Schema[7.1].define(version: 2008_09_06_171750) do
  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "part_number"
  end
end
```

ในหลายๆ ด้านนี้ก็เป็นที่แน่นอน ไฟล์นี้ถูกสร้างขึ้นโดยการตรวจสอบฐานข้อมูลและแสดงโครงสร้างของฐานข้อมูลโดยใช้ `create_table`, `add_index`, และอื่นๆ

#### การใช้ `:sql` schema dumper

อย่างไรก็ตาม, `db/schema.rb` ไม่สามารถแสดงอะไรที่ฐานข้อมูลของคุณอาจรองรับได้ทั้งหมด เช่น triggers, sequences, stored procedures ฯลฯ

ในขณะที่ migrations อาจใช้ `execute` เพื่อสร้างโครงสร้างฐานข้อมูลที่ไม่รองรับโดย Ruby migration DSL, โครงสร้างเหล่านี้อาจไม่สามารถสร้างใหม่ได้โดยใช้ schema dumper

หากคุณใช้คุณสมบัติเช่นนี้คุณควรตั้งค่ารูปแบบ schema เป็น `:sql` เพื่อให้ได้ไฟล์ schema ที่ถูกต้องและมีประโยชน์ในการสร้างฐานข้อมูลใหม่

เมื่อรูปแบบ schema ถูกตั้งค่าเป็น `:sql` โครงสร้างฐานข้อมูลจะถูก dump โดยใช้เครื่องมือที่เฉพาะเจาะจงกับฐานข้อมูลไปยัง `db/structure.sql` ตัวอย่างเช่นสำหรับ PostgreSQL จะใช้เครื่องมือ `pg_dump` สำหรับ MySQL และ MariaDB ไฟล์นี้จะประกอบด้วยผลลัพธ์ของ `SHOW CREATE TABLE` สำหรับตารางต่างๆ

ในการโหลด schema จาก `db/structure.sql` ให้เรียกใช้ `bin/rails db:schema:load` การโหลดไฟล์นี้จะทำโดยการ execute SQL statements ที่มีอยู่ในไฟล์ ตามนิยามนั้น จะสร้างสำเนาโครงสร้างของฐานข้อมูลอย่างสมบูรณ์

### Schema Dumps และ Source Control

เนื่องจากไฟล์ schema มักถูกใช้สร้างฐานข้อมูลใหม่ แนะนำอย่างเข้มแข็งให้คุณเช็คไฟล์ schema เข้าสู่ source control

การเกิดข้อขัดแย้งในไฟล์ schema อาจเกิดขึ้นเมื่อสอง branch แก้ไข schema ในเวลาเดียวกัน ในการแก้ไขข้อขัดแย้งเหล่านี้ให้เรียกใช้ `bin/rails db:migrate` เพื่อสร้างไฟล์ schema ใหม่

INFO: แอปพลิเคชัน Rails ที่สร้างขึ้นใหม่จะมีโฟลเดอร์ migrations อยู่ใน git tree อยู่แล้ว ดังนั้นคุณต้องเพียงแค่เพิ่ม migrations ใหม่ที่คุณเพิ่มและ commit มัน
Active Record และความสัมพันธ์ที่สอดคล้องกัน
---------------------------------------

วิธีการ Active Record กล่าวว่าความสามารถอยู่ในโมเดลของคุณ ไม่ใช่ในฐานข้อมูล ดังนั้น คุณไม่ควรใช้คุณสมบัติเช่น triggers หรือ constraints ซึ่งจะนำความสามารถบางส่วนกลับไปที่ฐานข้อมูล

การตรวจสอบความถูกต้องเช่น `validates :foreign_key, uniqueness: true` เป็นวิธีหนึ่งที่โมเดลสามารถบังคับความสมบูรณ์ของข้อมูลได้ ตัวเลือก `:dependent` บนความสัมพันธ์ช่วยให้โมเดลสามารถทำลายวัตถุลูกโดยอัตโนมัติเมื่อวัตถุหลักถูกทำลาย อย่างไรก็ตาม อย่างใดอย่างหนึ่งที่ทำงานในระดับแอปพลิเคชันไม่สามารถรับประกันความสัมพันธ์ที่สอดคล้องกันได้ ดังนั้นบางคนจึงเสริมด้วย [foreign key constraints][] ในฐานข้อมูล

แม้ว่า Active Record จะไม่ให้เครื่องมือทั้งหมดสำหรับการทำงานโดยตรงกับคุณลักษณะเหล่านี้ แต่เมธอด `execute` สามารถใช้ในการดำเนินการ SQL อย่างอิสระ

[foreign key constraints]: #foreign-keys

การเคลื่อนย้ายและข้อมูลเมล็ดพันธุ์
----------------------------------

วัตถุประสงค์หลักของคุณสมบัติการเคลื่อนย้ายของ Rails คือการออกคำสั่งที่แก้ไข schema โดยใช้กระบวนการที่สอดคล้องกัน การเคลื่อนย้ายยังสามารถใช้เพื่อเพิ่มหรือแก้ไขข้อมูลได้ นี่เป็นประโยชน์ในฐานข้อมูลที่มีอยู่แล้วที่ไม่สามารถทำลายและสร้างใหม่ได้ เช่นฐานข้อมูลการผลิต

```ruby
class AddInitialProducts < ActiveRecord::Migration[7.1]
  def up
    5.times do |i|
      Product.create(name: "Product ##{i}", description: "A product.")
    end
  end

  def down
    Product.delete_all
  end
end
```

เพื่อเพิ่มข้อมูลเริ่มต้นหลังจากสร้างฐานข้อมูล  Rails มีคุณลักษณะ 'seeds' ที่มีอยู่ซึ่งช่วยเร่งกระบวนการนี้ นี่เป็นประโยชน์มากโดยเฉพาะเมื่อโหลดฐานข้อมูลบ่อยครั้งในสภาพแวดล้อมการพัฒนาและทดสอบ หรือเมื่อตั้งค่าข้อมูลเริ่มต้นสำหรับการผลิต

เพื่อเริ่มต้นใช้คุณลักษณะนี้ เปิด `db/seeds.rb` และเพิ่มโค้ด Ruby บางส่วน จากนั้นรัน `bin/rails db:seed`

หมายเหตุ: โค้ดที่นี่ควรเป็น idempotent เพื่อให้สามารถรันได้ทุกจุดในทุกสภาพแวดล้อม

```ruby
["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
  MovieGenre.find_or_create_by!(name: genre_name)
end
```

นี่เป็นวิธีที่สะอาดกว่ามากในการตั้งค่าฐานข้อมูลของแอปพลิเคชันที่ว่างเปล่า

การเคลื่อนย้ายเก่า
------------------

`db/schema.rb` หรือ `db/structure.sql` เป็นภาพรวมของสถานะปัจจุบันของฐานข้อมูลของคุณและเป็นแหล่งข้อมูลที่เป็นอำนาจสำหรับการสร้างฐานข้อมูลนั้น นี่ทำให้เป็นไปได้ที่จะลบหรือตัดสินใจเกี่ยวกับไฟล์การเคลื่อนย้ายเก่า

เมื่อคุณลบไฟล์การเคลื่อนย้ายในไดเรกทอรี `db/migrate/` สภาพแวดล้อมใด ๆ ที่ `bin/rails db:migrate` ถูกเรียกใช้เมื่อไฟล์เหล่านั้นยังคงอยู่จะเก็บอ้างอิงไปยังการปรับปรุงเวลาเฉพาะของพวกเขาภายในตารางฐานข้อมูล Rails ที่ชื่อ `schema_migrations` ตารางนี้ใช้ในการติดตามว่าการเคลื่อนย้ายได้รับการดำเนินการในสภาพแวดล้อมที่เฉพาะเจาะจง

หากคุณรันคำสั่ง `bin/rails db:migrate:status` ซึ่งแสดงสถานะ (เปิดหรือปิด) ของการเคลื่อนย้ายแต่ละรายการ คุณควรเห็น `********** NO FILE **********` ที่แสดงข้างๆไฟล์การเคลื่อนย้ายที่ถูกลบที่เคยดำเนินการในสภาพแวดล้อมที่เฉพาะเจาะจง แต่ไม่สามารถค้นหาได้ในไดเรกทอรี `db/migrate/`

### การเคลื่อนย้ายจากเอนจิน

อย่างไรก็ตาม มีข้อควรระวังเกี่ยวกับ [เอนจิน][Engines] การติดตั้งการเคลื่อนย้ายจากเอนจินเป็น idempotent ซึ่งหมายความว่าผลลัพธ์จะเหมือนกันไม่ว่าจะเรียกใช้กี่ครั้ง การเคลื่อนย้ายที่มีอยู่ในแอปพลิเคชันหลักเนื่องจากการติดตั้งก่อนหน้านั้นถูกข้ามไป และไฟล์ที่หายไปถูกคัดลอกพร้อมกับการเพิ่มเวลาแบบใหม่ หากคุณลบการเคลื่อนย้ายเอนจินเก่าและเรียกใช้งานงานการติดตั้งอีกครั้ง คุณจะได้รับไฟล์ใหม่พร้อมกับเวลาใหม่ และ `db:migrate` จะพยายามเรียกใช้งานอีกครั้ง

[Engines]: https://guides.rubyonrails.org/engines.html
ดังนั้นคุณต้องการที่จะเก็บรักษาการเคลื่อนย้ายที่มาจากเครื่องยนต์ มีคอมเมนต์พิเศษเช่นนี้:

```ruby
# This migration comes from blorgh (originally 20210621082949)
```

 [Engines]: engines.html
[`add_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`add_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[`remove_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_column
[`create_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_table
[`create_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_join_table
[`change_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table
[`change_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column
[`change_column_default`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_default
[`change_column_null`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_null
[`execute`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-execute
[`ActiveRecord::ConnectionAdapters::SchemaStatements`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
[`ActiveRecord::ConnectionAdapters::TableDefinition`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html
[`ActiveRecord::ConnectionAdapters::Table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html
[`add_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_check_constraint
[`add_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key
[`add_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_timestamps
[`change_column_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_comment
[`change_table_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table_comment
[`drop_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_join_table
[`drop_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_table
[`remove_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_check_constraint
[`remove_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key
[`remove_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_index
[`remove_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_reference
[`remove_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_timestamps
[`rename_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_column
[`remove_columns`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_columns
[`rename_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_index
[`rename_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_table
[`reversible`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-reversible
[`revert`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-revert
[`say`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say
[`say_with_time`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say_with_time
[`suppress_messages`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-suppress_messages
[`config.active_record.schema_format`]: configuring.html#config-active-record-schema-format
