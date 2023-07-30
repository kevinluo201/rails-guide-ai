**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 320082396ef549e27ab4cb837ec975dd
Active Record Callbacks
=======================

คู่มือนี้สอนวิธีการเชื่อมต่อกับวงจรชีวิตของอ็อบเจกต์ Active Record ของคุณ

หลังจากอ่านคู่มือนี้คุณจะรู้:

* เมื่อเกิดเหตุการณ์บางอย่างในช่วงชีวิตของออบเจกต์ Active Record
* วิธีการสร้างเมธอด callback ที่ตอบสนองต่อเหตุการณ์ในวงจรชีวิตของออบเจกต์
* วิธีการสร้างคลาสพิเศษที่ห่อหุ้มพฤติกรรมที่เป็นสากลสำหรับ callback ของคุณ

--------------------------------------------------------------------------------

วงจรชีวิตของออบเจกต์
---------------------

ในการทำงานปกติของแอปพลิเคชัน Rails ออบเจกต์อาจถูกสร้างขึ้น อัปเดต และลบทิ้งได้ Active Record มีการเชื่อมต่อไปยังวงจรชีวิตของออบเจกต์เหล่านี้เพื่อให้คุณสามารถควบคุมแอปพลิเคชันและข้อมูลของคุณได้

Callback ช่วยให้คุณสามารถเรียกใช้ตรรกะก่อนหรือหลังการเปลี่ยนแปลงสถานะของออบเจกต์ได้

```ruby
class Baby < ApplicationRecord
  after_create -> { puts "Congratulations!" }
end
```

```irb
irb> @baby = Baby.create
Congratulations!
```

จะเห็นได้ว่ามีเหตุการณ์วงจรชีวิตหลายอย่างและคุณสามารถเลือกเชื่อมต่อกับเหตุการณ์เหล่านี้ได้ก่อนหรือหลังหรือแม้กระทั่งรอบเหตุการณ์

ภาพรวมของ Callback
------------------

Callback คือเมธอดที่ถูกเรียกในช่วงเวลาที่กำหนดของวงจรชีวิตของออบเจกต์ ด้วย callback คุณสามารถเขียนโค้ดที่จะทำงานเมื่อออบเจกต์ Active Record ถูกสร้าง บันทึก อัปเดต ลบ ตรวจสอบความถูกต้อง หรือโหลดจากฐานข้อมูล

### การลงทะเบียน Callback

เพื่อใช้ callback ที่มีอยู่คุณต้องลงทะเบียน callback นั้น คุณสามารถสร้าง callback เป็นเมธอดธรรมดาและใช้เมธอดคลาสแบบ macro-style เพื่อลงทะเบียน callback:

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  private
    def ensure_login_has_a_value
      if login.blank?
        self.login = email unless email.blank?
      end
    end
end
```

เมธอดคลาสแบบ macro-style ยังสามารถรับบล็อกได้ คิดจะใช้รูปแบบนี้หากโค้ดภายในบล็อกของคุณสั้นมากเพียงพอที่จะพอดีในบรรทัดเดียว:

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

อีกวิธีหนึ่งคุณสามารถส่ง proc เข้าไปใน callback เพื่อเรียกใช้งาน

```ruby
class User < ApplicationRecord
  before_create ->(user) { user.name = user.login.capitalize if user.name.blank? }
end
```

สุดท้ายคุณสามารถกำหนดว่างาน callback ของคุณเอง ซึ่งเราจะพูดถึงในภายหลังอย่างละเอียด [ด้านล่าง](#callback-classes)

```ruby
class User < ApplicationRecord
  before_create MaybeAddName
end

class MaybeAddName
  def self.before_create(record)
    if record.name.blank?
      record.name = record.login.capitalize
    end
  end
end
```

Callback ยังสามารถลงทะเบียนเพื่อทำงานเฉพาะในเหตุการณ์วงจรชีวิตบางอย่าง ซึ่งช่วยให้คุณควบคุมได้อย่างสมบูรณ์เมื่อและในบริบทใด callback ของคุณจะถูกเรียกใช้

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on ยังสามารถรับอาร์เรย์ได้
  after_validation :set_location, on: [ :create, :update ]

  private
    def normalize_name
      self.name = name.downcase.titleize
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

ถือว่าเป็นการปฏิบัติที่ดีที่จะประกาศเมธอด callback เป็น private หากปล่อยให้เป็น public จะสามารถเรียกใช้จากภายนอกโมเดลได้และละเมิดหลักการของการห่อหุ้มออบเจกต์

คำเตือน. หลีกเลี่ยงการเรียกใช้ `update`, `save` หรือเมธอดอื่น ๆ ที่สร้างผลข้างเคียงให้กับออบเจกต์ภายใน callback ตัวอย่างเช่น อย่าเรียกใช้ `update(attribute: "value")` ใน callback นี้ สามารถเปลี่ยนแปลงสถานะของโมเดลและอาจทำให้เกิดผลข้างเคียงที่ไม่คาดคิดในระหว่างการ commit แทนนั้นคุณสามารถกำหนดค่าโดยตรงได้อย่างปลอดภัย (ตัวอย่างเช่น `self.attribute = "value"`) ใน `before_create` / `before_update` หรือ callback ก่อนหน้านี้
การเรียกใช้ Callbacks ที่มีอยู่
-------------------

นี่คือรายการทั้งหมดของ Callbacks ที่มีอยู่ใน Active Record แสดงในลำดับเดียวกันที่จะถูกเรียกใช้ในระหว่างการดำเนินการที่เกี่ยวข้อง:

### การสร้างออบเจ็กต์

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


### การอัปเดตออบเจ็กต์

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


คำเตือน. `after_save` ทำงานทั้งในการสร้างและการอัปเดต แต่เสมอ _หลัง_ ของ Callbacks ที่เฉพาะเจาะจงมากกว่า `after_create` และ `after_update` ไม่ว่าจะเรียกใช้ Macro ในลำดับใด

### การทำลายออบเจ็กต์

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]


หมายเหตุ: Callbacks `before_destroy` ควรวางไว้ก่อนการเชื่อมโยง `dependent: :destroy` (หรือใช้ตัวเลือก `prepend: true`) เพื่อให้แน่ใจว่าจะทำงานก่อนที่ระเบียนจะถูกลบโดย `dependent: :destroy`

คำเตือน. `after_commit` ให้การรับรองที่แตกต่างกันจาก `after_save`, `after_update`, และ `after_destroy` ตัวอย่างเช่นหากเกิดข้อผิดพลาดใน `after_save` การทำธุรกรรมจะถูกยกเลิกและข้อมูลจะไม่ถูกบันทึก ในขณะที่ทุกอย่างที่เกิดขึ้นหลังจาก `after_commit` สามารถรับรองได้ว่าการทำธุรกรรมได้เสร็จสิ้นและข้อมูลถูกบันทึกในฐานข้อมูล ข้อมูลเพิ่มเติมเกี่ยวกับ [transactional callbacks](#transaction-callbacks) ด้านล่าง

### `after_initialize` และ `after_find`

เมื่อมีการสร้างออบเจ็กต์ Active Record  [`after_initialize`][] callback จะถูกเรียกใช้ ไม่ว่าจะใช้ `new` โดยตรงหรือเมื่อบันทึกถูกโหลดจากฐานข้อมูล มันสามารถใช้เพื่อหลีกเลี่ยงความจำเป็นในการเขียนโค้ดเพื่อแทนที่เมธอด `initialize` ของ Active Record

เมื่อโหลดบันทึกจากฐานข้อมูล [`after_find`][] callback จะถูกเรียกใช้ ถ้าทั้งสองอย่างถูกกำหนดไว้

หมายเหตุ: Callbacks `after_initialize` และ `after_find` ไม่มีคู่สมรรถนะ `before_*`

สามารถลงทะเบียนได้เหมือนกับ Callbacks อื่น ๆ ของ Active Record

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "คุณได้เริ่มต้นออบเจ็กต์!"
  end

  after_find do |user|
    puts "คุณได้พบออบเจ็กต์!"
  end
end
```

```irb
irb> User.new
คุณได้เริ่มต้นออบเจ็กต์!
=> #<User id: nil>

irb> User.first
คุณได้พบออบเจ็กต์!
คุณได้เริ่มต้นออบเจ็กต์!
=> #<User id: 1>
```


### `after_touch`

Callback [`after_touch`][] จะถูกเรียกเมื่อมีการสัมผัสกับออบเจ็กต์ Active Record

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "คุณได้สัมผัสกับออบเจ็กต์"
  end
end
```

```irb
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
คุณได้สัมผัสกับออบเจ็กต์
=> true
```

สามารถใช้งานร่วมกับ `belongs_to` ได้:

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    puts 'มีการสัมผัสกับหนังสือ'
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      puts 'มีการสัมผัสกับหนังสือหรือห้องสมุด'
    end
end
```

```irb
irb> @book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @book.touch # กระตุ้น @book.library.touch
มีการสัมผัสกับหนังสือ
มีการสัมผัสกับหนังสือหรือห้องสมุด
=> true
```


การเรียกใช้ Callbacks
-----------------

เมทอดต่อไปนี้เป็นตัวกระตุ้น Callbacks:

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `destroy_by`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update`
* `update!`
* `valid?`
นอกจากนี้ยังมีการเรียกใช้ `after_find` callback โดยใช้เมธอด finder ต่อไปนี้:

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

`after_initialize` callback จะถูกเรียกทุกครั้งที่มีการสร้างอ็อบเจ็กต์ใหม่ของคลาสนี้

หมายเหตุ: เมธอด `find_by_*` และ `find_by_*!` เป็น dynamic finders ที่สร้างขึ้นโดยอัตโนมัติสำหรับแต่ละ attribute อ่านข้อมูลเพิ่มเติมได้ที่ [ส่วน Dynamic finders](active_record_querying.html#dynamic-finders)

การข้าม Callbacks
------------------

เช่นเดียวกับการตรวจสอบความถูกต้อง ยังสามารถข้าม callback ได้โดยใช้เมธอดต่อไปนี้:

* `decrement!`
* `decrement_counter`
* `delete`
* `delete_all`
* `delete_by`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `touch_all`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`
* `upsert`
* `upsert_all`

อย่างไรก็ตาม ควรใช้เมธอดเหล่านี้อย่างระมัดระวัง เนื่องจากกฎธุรกิจที่สำคัญและตรรกะในแอปพลิเคชันอาจถูกเก็บไว้ใน callbacks การข้ามไปโดยไม่เข้าใจผลกระทบที่อาจเกิดขึ้นอาจทำให้ข้อมูลไม่ถูกต้อง

หยุดการทำงาน
-----------------

เมื่อคุณเริ่มลงทะเบียน callback ใหม่สำหรับโมเดลของคุณ มันจะถูกจัดคิวเพื่อทำงาน คิวนี้จะรวมถึงการตรวจสอบความถูกต้องของโมเดล การลงทะเบียน callback และการดำเนินการฐานข้อมูลที่จะทำงาน

ทั้งหมดใน callback chain จะถูกครอบตัดด้วย transaction หาก callback ใดๆ ที่เกิดขึ้นเกิดข้อผิดพลาด การทำงานจะถูกหยุดและจะมีการ ROLLBACK ถ้าต้องการหยุด chain โดยตั้งใจใช้:

```ruby
throw :abort
```

คำเตือน. ข้อยกเว้นใดๆ ที่ไม่ใช่ `ActiveRecord::Rollback` หรือ `ActiveRecord::RecordInvalid` จะถูกเรียกใช้ใหม่โดย Rails หลังจากที่ chain ของ callback ถูกหยุด อีกทั้งอาจทำให้โค้ดที่ไม่คาดหวังเช่น `save` และ `update` (ซึ่งโดยปกติจะพยายามส่งคืน `true` หรือ `false`) เกิดข้อผิดพลาด

หมายเหตุ: หากเกิด `ActiveRecord::RecordNotDestroyed` ภายใน `after_destroy`, `before_destroy` หรือ `around_destroy` callback จะไม่ถูกเรียกใช้ใหม่และเมธอด `destroy` จะส่งคืน `false`

Relational Callbacks
--------------------

Callbacks ทำงานผ่านความสัมพันธ์ของโมเดล และสามารถกำหนดได้โดยใช้ความสัมพันธ์นั้นเอง พิจารณาตัวอย่างที่ผู้ใช้มีบทความหลายเรื่อง บทความของผู้ใช้ควรถูกลบหากผู้ใช้ถูกลบ ให้เพิ่ม `after_destroy` callback ในโมเดล `User` ผ่านความสัมพันธ์กับโมเดล `Article`:

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Article destroyed'
  end
end
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
Article destroyed
=> #<User id: 1>
```

Conditional Callbacks
---------------------

เช่นเดียวกับการตรวจสอบความถูกต้อง เรายังสามารถกำหนดให้เรียกใช้เมธอด callback ตามเงื่อนไขที่กำหนดได้ โดยใช้ตัวเลือก `:if` และ `:unless` ซึ่งสามารถรับสัญลักษณ์ เมธอด `Proc` หรือ `Array` ได้

คุณสามารถใช้ตัวเลือก `:if` เมื่อคุณต้องการระบุเงื่อนไขที่ callback **ควร** ถูกเรียกใช้ หากคุณต้องการระบุเงื่อนไขที่ callback **ไม่ควร** ถูกเรียกใช้ คุณสามารถใช้ตัวเลือก `:unless` ได้

### การใช้ `:if` และ `:unless` กับ `Symbol`

คุณสามารถเชื่อมโยงตัวเลือก `:if` และ `:unless` กับสัญลักษณ์ที่เป็นชื่อของเมธอดตัวตรวจสอบที่จะถูกเรียกใช้ก่อน callback
เมื่อใช้ตัวเลือก `:if` คำสั่ง callback **จะไม่**ถูกเรียกใช้หากเมธอดตัดสินใจส่วนหนึ่งคืนค่า **false**; เมื่อใช้ตัวเลือก `:unless` คำสั่ง callback **จะไม่**ถูกเรียกใช้หากเมธอดตัดสินใจส่วนหนึ่งคืนค่า **true** นี่เป็นตัวเลือกที่พบบ่อยที่สุด

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

ในกรณีที่ใช้รูปแบบการลงทะเบียนนี้ ยังสามารถลงทะเบียนตัวตัดสินใจหลายตัวที่ต้องเรียกใช้เพื่อตรวจสอบว่าคำสั่ง callback ควรถูกเรียกใช้หรือไม่ จะถูกอธิบายต่อไปนี้ [ด้านล่าง](#multiple-callback-conditions).

### การใช้ `:if` และ `:unless` พร้อมกับ `Proc`

สามารถเชื่อมโยง `:if` และ `:unless` กับอ็อบเจกต์ `Proc` ได้ ตัวเลือกนี้เหมาะสำหรับการเขียนเมธอดการตรวจสอบที่สั้น ๆ ซึ่งมักจะเป็นเมธอดที่เขียนเพียงหนึ่งบรรทัด:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

เนื่องจาก proc ถูกประเมินในบริบทของอ็อบเจกต์ สามารถเขียนได้เช่นนี้:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```

### เงื่อนไขตัดสินใจหลายรายการ

ตัวเลือก `:if` และ `:unless` ยังรองรับอาร์เรย์ของ procs หรือชื่อเมธอดเป็นสัญลักษณ์:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

สามารถรวม proc ในรายการเงื่อนไขได้ง่าย ๆ:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, Proc.new { untrusted_author? }]
end
```

### การใช้ทั้ง `:if` และ `:unless`

Callback สามารถผสม `:if` และ `:unless` ในการประกาศเดียวกันได้:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: Proc.new { forum.parental_control? },
    unless: Proc.new { author.trusted? }
end
```

Callback จะทำงานเมื่อทุกเงื่อนไข `:if` และไม่มีเงื่อนไข `:unless` ที่ถูกประเมินเป็น `true`.

คลาส Callback
----------------

บางครั้งเมธอด callback ที่คุณเขียนอาจมีประโยชน์มากพอที่จะนำไปใช้ซ้ำกับโมเดลอื่น ๆ Active Record ช่วยให้เป็นไปได้ที่จะสร้างคลาสที่ห่อหุ้มเมธอด callback เพื่อนำไปใช้ซ้ำได้

ตัวอย่างนี้แสดงถึงการสร้างคลาสที่มี callback `after_destroy` เพื่อจัดการกับการล้างข้อมูลของไฟล์ที่ถูกทิ้งในระบบไฟล์ พฤติกรรมนี้อาจไม่ใช่เฉพาะกับโมเดล `PictureFile` เราอาจต้องการแบ่งปันมัน ดังนั้นควรห่อหุ้มเป็นคลาสแยกต่างหาก สิ่งนี้จะทำให้การทดสอบพฤติกรรมนั้นและการเปลี่ยนแปลงมันง่ายขึ้น

```ruby
class FileDestroyerCallback
  def after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

เมื่อประกาศภายในคลาสเช่นข้างต้น เมธอด callback จะได้รับอ็อบเจกต์โมเดลเป็นพารามิเตอร์ สิ่งนี้จะทำงานกับโมเดลใดก็ได้ที่ใช้คลาสเช่นนี้ดังนี้:

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback.new
end
```

โปรดทราบว่าเราต้องสร้างอ็อบเจกต์ `FileDestroyerCallback` ใหม่ เนื่องจากเราประกาศ callback เป็นเมธอดอินสแตนซ์ สิ่งนี้เป็นประโยชน์มากโดยเฉพาะอย่างยิ่งถ้า callback ใช้สถานะของอ็อบเจกต์ที่ถูกสร้างขึ้น อย่างไรก็ตาม บ่อยครั้งจะมีความเหมาะสมกว่าที่จะประกาศ callback เป็นเมธอดคลาส:

```ruby
class FileDestroyerCallback
  def self.after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

เมื่อประกาศเมธอด callback ในลักษณะนี้ จะไม่จำเป็นต้องสร้างอ็อบเจกต์ `FileDestroyerCallback` ใหม่ในโมเดลของเรา
```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback
end
```

คุณสามารถประกาศ callback ได้เท่าที่คุณต้องการภายในคลาส callback ของคุณ

Transaction Callbacks
---------------------

### การจัดการกับความสอดคล้อง

มี callback อีกสองตัวที่ถูกเรียกใช้หลังจากที่เสร็จสิ้นการทำงานของธุรกรรมฐานข้อมูล: [`after_commit`][] และ [`after_rollback`][] การทำงานของ callback เหล่านี้คล้ายกับ callback `after_save` ยกเว้นว่าจะไม่ถูกเรียกใช้จนกว่าการเปลี่ยนแปลงในฐานข้อมูลจะถูก commit หรือ rollback การใช้งานมีประโยชน์มากที่สุดเมื่อโมเดล active record ของคุณต้องปฏิสัมพันธ์กับระบบภายนอกที่ไม่ได้เป็นส่วนหนึ่งของการทำธุรกรรมในฐานข้อมูล

พิจารณาตัวอย่างเช่น โมเดล `PictureFile` ต้องลบไฟล์หลังจากที่บันทึกบันทึกที่เกี่ยวข้องถูกลบไปแล้ว หากมีอะไรที่เกิดขึ้นขึ้นข้อยกเว้นหลังจากที่เรียกใช้งาน callback `after_destroy` และการทำธุรกรรมถูก rollback ไฟล์จะถูกลบและโมเดลจะอยู่ในสถานะที่ไม่สอดคล้องกัน ตัวอย่างเช่น สมมุติว่า `picture_file_2` ในโค้ดด้านล่างไม่ถูกต้องและเมธอด `save!` ยกเลิกการทำงาน

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

โดยใช้ callback `after_commit` เราสามารถปรับปรุงกรณีนี้ได้

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

หมายเหตุ: ตัวเลือก `:on` ระบุเมื่อ callback จะถูกเรียกใช้งาน หากคุณไม่ได้ให้ตัวเลือก `:on` callback จะถูกเรียกใช้สำหรับทุก ๆ การกระทำ

### บริบทสำคัญ

เนื่องจากใช้ callback `after_commit` เฉพาะในการสร้าง อัปเดต หรือลบเป็นสิ่งที่พบบ่อย มีตัวย่อสำหรับการดำเนินการเหล่านั้น:

* [`after_create_commit`][]
* [`after_update_commit`][]
* [`after_destroy_commit`][]

```ruby
class PictureFile < ApplicationRecord
  after_destroy_commit :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

คำเตือน. เมื่อธุรกรรมเสร็จสิ้น callback `after_commit` หรือ `after_rollback` จะถูกเรียกสำหรับโมเดลที่ถูกสร้าง อัปเดต หรือลบภายในธุรกรรมนั้น อย่างไรก็ตามหากเกิดข้อยกเว้นขึ้นภายในหนึ่งใน callback เหล่านี้ ข้อยกเว้นจะแผ่ขึ้นและ callback `after_commit` หรือ `after_rollback` เหลืออยู่จะไม่ถูกเรียกใช้งาน ดังนั้นหากโค้ด callback ของคุณสามารถเกิดข้อยกเว้นได้ คุณจะต้อง rescue และจัดการกับมันภายใน callback เพื่อให้ callback อื่น ๆ ทำงานได้

คำเตือน. โค้ดที่ทำงานภายใน callback `after_commit` หรือ `after_rollback` ไม่ได้ถูกครอบคลุมด้วยธุรกรรม

คำเตือน. การใช้ทั้ง `after_create_commit` และ `after_update_commit` ด้วยชื่อเมธอดเดียวกันจะทำให้ callback ที่กำหนดล่าสุดเท่านั้นที่มีผล โดยที่ทั้งคู่จะเปลี่ยนชื่อเป็น `after_commit` ซึ่งจะแทนที่ callback ที่กำหนดไว้ก่อนหน้านี้ที่มีชื่อเมธอดเดียวกัน

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'User was saved to database'
    end
end
```

```irb
irb> @user = User.create # ไม่พิมพ์อะไร

irb> @user.save # อัปเดต @user
User was saved to database
```

### `after_save_commit`

ยังมี [`after_save_commit`][] ซึ่งเป็นตัวย่อสำหรับใช้ callback `after_commit` สำหรับการสร้างและอัปเดตพร้อมกัน:

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'User was saved to database'
    end
end
```

```irb
irb> @user = User.create # สร้าง User
User was saved to database

irb> @user.save # อัปเดต @user
User was saved to database
```

### การจัดลำดับการเรียกใช้ Transactional Callback

เมื่อกำหนด transactional `after_` callbacks (`after_commit`, `after_rollback`, เป็นต้น) หลายตัว ลำดับจะถูกกลับด้านจากที่กำหนด

```ruby
class User < ActiveRecord::Base
  after_commit { puts("this actually gets called second") }
  after_commit { puts("this actually gets called first") }
end
```

หมายเหตุ: สิ่งนี้ยังใช้กับ `after_*_commit` variations ทั้งหมด เช่น `after_destroy_commit` ด้วย
[`after_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_create
[`after_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_commit
[`after_rollback`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_rollback
[`after_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_save
[`after_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-after_validation
[`around_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_create
[`around_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_save
[`before_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_create
[`before_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_save
[`before_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-before_validation
[`after_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_update
[`around_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_update
[`before_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_update
[`after_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_destroy
[`around_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_destroy
[`before_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_destroy
[`after_find`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_find
[`after_initialize`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_initialize
[`after_touch`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_touch
[`after_create_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_create_commit
[`after_destroy_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_destroy_commit
[`after_save_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_save_commit
[`after_update_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_update_commit
