**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cee957545ee75801aab30265bc416992
พื้นฐานของ Active Model
===================

เอกสารนี้จะให้คุณทราบทุกสิ่งที่คุณต้องการเพื่อเริ่มต้นใช้งานคลาสโมเดล  Active Model ช่วยให้ Action Pack helpers สามารถทำงานร่วมกับอ็อบเจกต์ของ Ruby ได้ และยังช่วยในการสร้าง ORM ที่กำหนดเองสำหรับการใช้งานนอกเฟรมเวิร์คเรลส์

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีการทำงานของโมเดล Active Record
* วิธีการทำงานของ Callbacks และการตรวจสอบความถูกต้อง
* วิธีการทำงานของ Serializers
* วิธีการใช้งาน Active Model ร่วมกับเฟรมเวิร์คเรลส์ในการแปลภาษา (i18n)

--------------------------------------------------------------------------------

Active Model คืออะไร?
---------------------

Active Model เป็นไลบรารีที่ประกอบด้วยโมดูลต่างๆที่ใช้ในการพัฒนาคลาสที่ต้องการคุณสมบัติบางอย่างที่มีอยู่ใน Active Record บางส่วนของโมดูลเหล่านี้จะอธิบายด้านล่าง

### API

`ActiveModel::API` เพิ่มความสามารถให้กับคลาสที่ทำงานร่วมกับ Action Pack และ Action View ได้ทันที

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # ส่งอีเมล
    end
  end
end
```

เมื่อรวม `ActiveModel::API` คุณจะได้รับคุณสมบัติต่างๆ เช่น:

- การตรวจสอบชื่อโมเดล
- การแปลงข้อมูล
- การแปลภาษา
- การตรวจสอบความถูกต้อง

นอกจากนี้ยังช่วยให้คุณสามารถสร้างออบเจกต์ด้วยแอตทริบิวต์แบบแฮชเหมือนกับออบเจกต์ Active Record ได้

```irb
irb> email_contact = EmailContact.new(name: 'David', email: 'david@example.com', message: 'Hello World')
irb> email_contact.name
=> "David"
irb> email_contact.email
=> "david@example.com"
irb> email_contact.valid?
=> true
irb> email_contact.persisted?
=> false
```

คลาสใดๆที่รวม `ActiveModel::API` สามารถใช้งานกับ `form_with`, `render` และเมธอดช่วยอื่นๆของ Action View เหมือนกับออบเจกต์ Active Record

### Attribute Methods

โมดูล `ActiveModel::AttributeMethods` สามารถเพิ่มคำนำหน้าและคำส่วนท้ายที่กำหนดเองในเมธอดของคลาสได้ โดยกำหนดคำนำหน้าและคำส่วนท้ายและระบุว่าเมธอดใดบนออบเจกต์จะใช้งานกับคำนำหน้าและคำส่วนท้ายเหล่านี้

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_prefix 'reset_'
  attribute_method_suffix '_highest?'
  define_attribute_methods 'age'

  attr_accessor :age

  private
    def reset_attribute(attribute)
      send("#{attribute}=", 0)
    end

    def attribute_highest?(attribute)
      send(attribute) > 100
    end
end
```

```irb
irb> person = Person.new
irb> person.age = 110
irb> person.age_highest?
=> true
irb> person.reset_age
=> 0
irb> person.age_highest?
=> false
```

### Callbacks

`ActiveModel::Callbacks` ให้คุณสามารถใช้งาน Callback แบบ Active Record ได้ ซึ่งจะช่วยในการกำหนด Callback ที่ทำงานในเวลาที่เหมาะสม หลังจากกำหนด Callback คุณสามารถใช้งานกับเมธอดก่อนหลังและรอบเมธอดที่กำหนดเองได้

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # เมธอดนี้ถูกเรียกเมื่อมีการเรียกใช้งาน update บนออบเจกต์
    end
  end

  def reset_me
    # เมธอดนี้ถูกเรียกเมื่อมีการเรียกใช้งาน update บนออบเจกต์เนื่องจากมีการกำหนด callback before_update
  end
end
```

### Conversion

หากคลาสกำหนดเมธอด `persisted?` และ `id` คุณสามารถรวมโมดูล `ActiveModel::Conversion` เข้ากับคลาสนั้น และเรียกใช้เมธอดแปลงข้อมูลของเรลส์บนออบเจกต์ของคลาสนั้น

```ruby
class Person
  include ActiveModel::Conversion

  def persisted?
    false
  end

  def id
    nil
  end
end
```

```irb
irb> person = Person.new
irb> person.to_model == person
=> true
irb> person.to_key
=> nil
irb> person.to_param
=> nil
```

### Dirty

ออบเจกต์จะกลายเป็นสกปรกเมื่อมีการเปลี่ยนแปลงค่าแอตทริบิวต์และไม่ได้ถูกบันทึก `ActiveModel::Dirty` ให้ความสามารถในการตรวจสอบว่าออบเจกต์มีการเปลี่ยนแปลงหรือไม่ และยังมีเมธอดเข้าถึงแอตทริบิวต์ พิจารณาคลาส Person ที่มีแอตทริบิวต์ `first_name` และ `last_name`:
```ruby
class Person
  include ActiveModel::Dirty
  define_attribute_methods :first_name, :last_name

  def first_name
    @first_name
  end

  def first_name=(value)
    first_name_will_change!
    @first_name = value
  end

  def last_name
    @last_name
  end

  def last_name=(value)
    last_name_will_change!
    @last_name = value
  end

  def save
    # ทำงานการบันทึก...
    changes_applied
  end
end
```

#### การสอบถามวัตถุโดยตรงเพื่อให้ได้รายการของแอตทริบิวต์ที่เปลี่ยนแปลงทั้งหมด

```irb
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "ชื่อจริง"
irb> person.first_name
=> "ชื่อจริง"

# คืนค่า true หากมีการเปลี่ยนแปลงที่ยังไม่ได้บันทึก
irb> person.changed?
=> true

# คืนค่ารายการของแอตทริบิวต์ที่เปลี่ยนแปลงก่อนที่จะบันทึก
irb> person.changed
=> ["first_name"]

# คืนค่าแอตทริบิวต์ที่เปลี่ยนแปลงพร้อมกับค่าเดิม
irb> person.changed_attributes
=> {"first_name"=>nil}

# คืนค่าแอตทริบิวต์ที่เปลี่ยนแปลงพร้อมกับค่าเดิมและค่าปัจจุบัน ในรูปแบบของ Hash
irb> person.changes
=> {"first_name"=>[nil, "ชื่อจริง"]}
```

#### เมธอดเข้าถึงแอตทริบิวต์ตามชื่อ

ติดตามว่าแอตทริบิวต์นั้นเปลี่ยนแปลงหรือไม่

```irb
irb> person.first_name
=> "ชื่อจริง"

# attr_name_changed?
irb> person.first_name_changed?
=> true
```

ติดตามค่าก่อนหน้าของแอตทริบิวต์

```irb
# attr_name_was accessor
irb> person.first_name_was
=> nil
```

ติดตามค่าก่อนหน้าและค่าปัจจุบันของแอตทริบิวต์ที่เปลี่ยนแปลง คืนค่าเป็นอาร์เรย์
หากมีการเปลี่ยนแปลง มิฉะนั้นคืนค่าเป็น nil

```irb
# attr_name_change
irb> person.first_name_change
=> [nil, "ชื่อจริง"]
irb> person.last_name_change
=> nil
```

### การตรวจสอบความถูกต้อง

โมดูล `ActiveModel::Validations` เพิ่มความสามารถในการตรวจสอบวัตถุเช่นใน Active Record

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end
```

```irb
irb> person = Person.new
irb> person.token = "2b1f325"
irb> person.valid?
=> false
irb> person.name = 'vishnu'
irb> person.email = 'me'
irb> person.valid?
=> false
irb> person.email = 'me@vishnuatrai.com'
irb> person.valid?
=> true
irb> person.token = nil
irb> person.valid?
ActiveModel::StrictValidationFailed
```

### การตั้งชื่อ

`ActiveModel::Naming` เพิ่มเมธอดคลาสหลายตัวที่ทำให้การตั้งชื่อและการเรียกใช้เส้นทางง่ายขึ้น
โมดูลนี้กำหนดเมธอด `model_name` ที่เป็นเมธอดคลาสซึ่งจะกำหนดเมธอดเข้าถึงหลายตัวโดยใช้ `ActiveSupport::Inflector`

```ruby
class Person
  extend ActiveModel::Naming
end

Person.model_name.name                # => "Person"
Person.model_name.singular            # => "person"
Person.model_name.plural              # => "people"
Person.model_name.element             # => "person"
Person.model_name.human               # => "Person"
Person.model_name.collection          # => "people"
Person.model_name.param_key           # => "person"
Person.model_name.i18n_key            # => :person
Person.model_name.route_key           # => "people"
Person.model_name.singular_route_key  # => "person"
```

### โมเดล

`ActiveModel::Model` ช่วยให้สามารถสร้างโมเดลที่คล้ายกับ `ActiveRecord::Base` ได้

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # ส่งอีเมล
    end
  end
end
```

เมื่อรวม `ActiveModel::Model` คุณจะได้รับคุณสมบัติทั้งหมดจาก `ActiveModel::API`

### การซีรีอัลไลเซชัน

`ActiveModel::Serialization` ให้การซีรีอัลไลเซชันพื้นฐานสำหรับวัตถุของคุณ
คุณต้องประกาศแอตทริบิวต์แฮชที่มีแอตทริบิวต์ที่คุณต้องการซีรีอัลไลส์ แอตทริบิวต์ต้องเป็นสตริงไม่ใช่สัญลักษณ์

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

ตอนนี้คุณสามารถเข้าถึงแอตทริบิวต์ของวัตถุที่ถูกซีรีอัลไลส์ได้โดยใช้เมธอด `serializable_hash`

```irb
irb> person = Person.new
irb> person.serializable_hash
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.serializable_hash
=> {"name"=>"Bob"}
```

#### ActiveModel::Serializers

Active Model ยังมีโมดูล `ActiveModel::Serializers::JSON` สำหรับการแปลงเป็น JSON / การแปลงกลับจาก JSON โมดูลนี้รวมโมดูล `ActiveModel::Serialization` ที่ได้ถูกพูดถึงไว้ก่อนหน้านี้อัตโนมัติ

##### ActiveModel::Serializers::JSON

ในการใช้ `ActiveModel::Serializers::JSON` คุณเพียงแค่เปลี่ยนโมดูลที่คุณกำลังเพิ่มเข้าไปจาก `ActiveModel::Serialization` เป็น `ActiveModel::Serializers::JSON`

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

เมธอด `as_json` คล้ายกับ `serializable_hash` ให้ค่าแทนตัวแบบ Hash ที่แสดงโมเดล

```irb
irb> person = Person.new
irb> person.as_json
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.as_json
=> {"name"=>"Bob"}
```

คุณยังสามารถกำหนดคุณสมบัติสำหรับโมเดลจากสตริง JSON ได้ แต่คุณต้องกำหนดเมธอด `attributes=` ในคลาสของคุณ:

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    { 'name' => nil }
  end
end
```

ตอนนี้คุณสามารถสร้างอินสแตนซ์ของ `Person` และกำหนดคุณสมบัติโดยใช้ `from_json` ได้

```irb
irb> json = { name: 'Bob' }.to_json
irb> person = Person.new
irb> person.from_json(json)
=> #<Person:0x00000100c773f0 @name="Bob">
irb> person.name
=> "Bob"
```

### การแปลภาษา

`ActiveModel::Translation` ให้การผสมกันระหว่างออบเจ็กต์ของคุณและเฟรมเวิร์กการแปลภาษา (i18n) ของ Rails

```ruby
class Person
  extend ActiveModel::Translation
end
```

ด้วยเมธอด `human_attribute_name` คุณสามารถแปลงชื่อแอตทริบิวต์ให้เป็นรูปแบบที่อ่านง่ายกว่า รูปแบบที่อ่านง่ายนี้ถูกกำหนดไว้ในไฟล์โลเคลล์ของคุณ

* config/locales/app.pt-BR.yml

```yaml
pt-BR:
  activemodel:
    attributes:
      person:
        name: 'Nome'
```

```ruby
Person.human_attribute_name('name') # => "Nome"
```

### การทดสอบ Lint

`ActiveModel::Lint::Tests` ช่วยให้คุณทดสอบว่าออบเจ็กต์เป็นไปตาม Active Model API หรือไม่

* `app/models/person.rb`

    ```ruby
    class Person
      include ActiveModel::Model
    end
    ```

* `test/models/person_test.rb`

    ```ruby
    require "test_helper"

    class PersonTest < ActiveSupport::TestCase
      include ActiveModel::Lint::Tests

      setup do
        @model = Person.new
      end
    end
    ```

```bash
$ bin/rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

ไม่จำเป็นต้องใช้วัตถุที่ประยุกต์ใช้ทุก API เพื่อทำงานกับ Action Pack โมดูลนี้เพียงแค่ต้องการแนะนำในกรณีที่คุณต้องการคุณลักษณะทั้งหมดในกล่อง

### SecurePassword

`ActiveModel::SecurePassword` ให้วิธีการเก็บรักษารหัสผ่านใด ๆ ในรูปแบบที่เข้ารหัสอย่างปลอดภัย เมื่อคุณรวมโมดูลนี้ เมธอด `has_secure_password` จะถูกให้ในรูปแบบคลาสที่กำหนด `password` accessor พร้อมกับการตรวจสอบบางอย่างบนมันโดยค่าเริ่มต้น

#### ข้อกำหนด

`ActiveModel::SecurePassword` ขึ้นอยู่กับ [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt') เพื่อใช้ `ActiveModel::SecurePassword` ได้อย่างถูกต้อง ในการทำงานนี้ โมเดลต้องมี accessor ที่ชื่อ `XXX_digest` โดยที่ `XXX` คือชื่อแอตทริบิวต์ของรหัสผ่านที่คุณต้องการ การตรวจสอบต่อไปนี้ถูกเพิ่มโดยอัตโนมัติ:

1. รหัสผ่านควรมีการระบุ
2. รหัสผ่านควรเท่ากับการยืนยันของมัน (หากมีการส่ง `XXX_confirmation` มาด้วย)
3. ความยาวสูงสุดของรหัสผ่านคือ 72 (ที่จำเป็นต้องใช้โดย `bcrypt` ที่ `ActiveModel::SecurePassword` ขึ้นอยู่)

#### ตัวอย่าง

```ruby
class Person
  include ActiveModel::SecurePassword
  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest
end
```

```irb
irb> person = Person.new

# เมื่อรหัสผ่านว่างเปล่า
irb> person.valid?
=> false

# เมื่อการยืนยันไม่ตรงกับรหัสผ่าน
irb> person.password = 'aditya'
irb> person.password_confirmation = 'nomatch'
irb> person.valid?
=> false

# เมื่อความยาวของรหัสผ่านเกิน 72
irb> person.password = person.password_confirmation = 'a' * 100
irb> person.valid?
=> false

# เมื่อมีเพียงรหัสผ่านเท่านั้นที่ระบุโดยไม่มีการยืนยันรหัสผ่าน
irb> person.password = 'aditya'
irb> person.valid?
=> true

# เมื่อผ่านการตรวจสอบทั้งหมด
irb> person.password = person.password_confirmation = 'aditya'
irb> person.valid?
=> true

irb> person.recovery_password = "42password"

irb> person.authenticate('aditya')
=> #<Person> # == person
irb> person.authenticate('notright')
=> false
irb> person.authenticate_password('aditya')
=> #<Person> # == person
irb> person.authenticate_password('notright')
=> false

irb> person.authenticate_recovery_password('42password')
=> #<Person> # == person
irb> person.authenticate_recovery_password('notright')
=> false

irb> person.password_digest
=> "$2a$04$gF8RfZdoXHvyTjHhiU4ZsO.kQqV9oonYZu31PRE4hLQn3xM2qkpIy"
irb> person.recovery_password_digest
=> "$2a$04$iOfhwahFymCs5weB3BNH/uXkTG65HR.qpW.bNhEjFP3ftli3o5DQC"
```
