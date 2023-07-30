**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fdd2e5c41171c61b555549ced4d68a82
ส่วนขยายของ Active Support Core
==============================

Active Support เป็นส่วนประกอบของ Ruby on Rails ที่รับผิดชอบในการ提供ส่วนขยายและเครื่องมือของภาษา Ruby

มันให้ความสามารถที่เพิ่มขึ้นในระดับภาษาที่เป้าหมายทั้งในการพัฒนาแอปพลิเคชัน Rails และในการพัฒนา Ruby on Rails เอง

หลังจากอ่านเอกสารนี้คุณจะรู้:

* ส่วนขยายหลักคืออะไร
* วิธีโหลดส่วนขยายทั้งหมด
* วิธีเลือกเฉพาะส่วนขยายที่คุณต้องการ
* ส่วนขยายที่ Active Support มี

--------------------------------------------------------------------------------

วิธีโหลดส่วนขยายหลัก
---------------------------

### Active Support เดี่ยว

เพื่อให้มีขนาดเล็กที่สุดเป็นไปได้ Active Support โหลดความขึ้นต่ำที่สุดโดยค่าเริ่มต้น มันถูกแบ่งออกเป็นชิ้นเล็กๆ เพื่อให้สามารถโหลดส่วนขยายที่ต้องการได้เท่านั้น มันยังมีจุดเริ่มต้นที่สะดวกในการโหลดส่วนขยายที่เกี่ยวข้องในครั้งเดียว แม้ว่าจะเป็นทุกอย่าง

ดังนั้นหลังจาก require ง่ายๆ เช่น:

```ruby
require "active_support"
```

เฉพาะส่วนขยายที่ Active Support framework ต้องการจะถูกโหลดเท่านั้น

#### เลือกเฉพาะการกำหนดค่า

ตัวอย่างนี้แสดงวิธีการโหลด [`Hash#with_indifferent_access`][Hash#with_indifferent_access] ส่วนขยายนี้ช่วยให้สามารถแปลง `Hash` เป็น [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] ซึ่งอนุญาตให้เข้าถึงคีย์เป็นสตริงหรือสัญลักษณ์ได้

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

สำหรับทุกเมธอดที่กำหนดเป็นส่วนขยายหลัก คู่มือนี้มีหมายเหตุที่ระบุว่าเมธอดดังกล่าวถูกกำหนดที่ไหน ในกรณีของ `with_indifferent_access` หมายเหตุกล่าวว่า:

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/hash/indifferent_access.rb`

ซึ่งหมายความว่าคุณสามารถ require ได้ดังนี้:

```ruby
require "active_support"
require "active_support/core_ext/hash/indifferent_access"
```

Active Support ได้รับการตรวจสอบอย่างรอบคอบเพื่อให้การโหลดไฟล์เลือกเฉพาะเฉพาะที่จำเป็นอย่างเคร่งครัด

#### โหลดส่วนขยายหลักที่จัดกลุ่ม

ระดับถัดไปคือการโหลดส่วนขยายทั้งหมดไปยัง `Hash` เพียงแค่โหลด `active_support/core_ext/hash` คือเพียงพอ:

```ruby
require "active_support"
require "active_support/core_ext/hash"
```

#### โหลดส่วนขยายหลักทั้งหมด

คุณอาจต้องการเพียงแค่โหลดส่วนขยายหลักทั้งหมด มีไฟล์สำหรับนั้น:

```ruby
require "active_support"
require "active_support/core_ext"
```

#### โหลด Active Support ทั้งหมด

และสุดท้าย หากคุณต้องการให้ Active Support ทั้งหมดพร้อมใช้งานเพียงแค่เรียกใช้:

```ruby
require "active_support/all"
```

ซึ่งไม่ได้เก็บ Active Support ทั้งหมดในหน่วยความจำล่วงหน้าจริงๆ บางส่วนถูกกำหนดค่าผ่าน `autoload` เพื่อให้โหลดเฉพาะเมื่อใช้งาน

### Active Support ภายในแอปพลิเคชัน Ruby on Rails

แอปพลิเคชัน Ruby on Rails จะโหลด Active Support ทั้งหมด ยกเว้น [`config.active_support.bare`][] เป็นจริง ในกรณีนั้นแอปพลิเคชันจะโหลดเพียงสิ่งที่เฟรมเวิร์กเองเลือกเฉพาะสำหรับความต้องการของตัวเอง และยังสามารถเลือกเฉพาะตัวเองได้ในระดับที่เหมาะสม ตามที่อธิบายในส่วนก่อนหน้านี้


ส่วนขยายสำหรับวัตถุทั้งหมด
-------------------------

### `blank?` และ `present?`

ค่าต่อไปนี้ถือว่าเป็นค่าว่างในแอปพลิเคชัน Rails:

* `nil` และ `false`,

* สตริงที่ประกอบด้วยช่องว่างเท่านั้น (ดูหมายเหตุด้านล่าง),

* อาร์เรย์และแฮชที่ว่างเปล่า, และ

* วัตถุอื่น ๆ ที่ตอบสนองกับ `empty?` และเป็นว่าง

ข้อมูล: ตัวบ่งชี้สำหรับสตริงใช้คลาสอักขระที่ตระหนักถึง Unicode `[:space:]` ดังนั้นตัวอย่างเช่น U+2029 (ตัวแบ่งย่อหน้า) ถือว่าเป็นช่องว่าง
คำเตือน: โปรดทราบว่าไม่ได้กล่าวถึงตัวเลข โดยเฉพาะ 0 และ 0.0 ไม่ใช่ค่าว่าง

ตัวอย่างเช่น เมธอดนี้จาก `ActionController::HttpAuthentication::Token::ControllerMethods` ใช้ [`blank?`][Object#blank?] เพื่อตรวจสอบว่ามีโทเค็นอยู่หรือไม่:

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

เมธอด [`present?`][Object#present?] เทียบเท่ากับ `!blank?` ตัวอย่างนี้มาจาก `ActionDispatch::Http::Cache::Response`:

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  # ...
end
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/object/blank.rb`


### `presence`

เมธอด [`presence`][Object#presence] จะคืนค่าตัวเองหาก `present?` และ `nil` ในกรณีอื่น ๆ มีประโยชน์สำหรับการใช้งานเช่นนี้:

```ruby
host = config[:host].presence || 'localhost'
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/object/blank.rb`


### `duplicable?`

ตั้งแต่ Ruby 2.5 เป็นต้นมา ส่วนใหญ่ของออบเจ็กต์สามารถทำซ้ำได้ผ่าน `dup` หรือ `clone`:

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (allocator undefined for Method)
```

Active Support มี [`duplicable?`][Object#duplicable?] เพื่อสอบถามออบเจ็กต์เกี่ยวกับนี้:

```ruby
"foo".duplicable?           # => true
"".duplicable?              # => true
Rational(1).duplicable?     # => true
Complex(1).duplicable?      # => true
1.method(:+).duplicable?    # => false
```

คำเตือน: คลาสใด ๆ สามารถปฏิเสธการทำซ้ำได้โดยการลบ `dup` และ `clone` หรือยกเว้นข้อยกเว้นจากการใช้งาน ดังนั้นเพียงแค่ `rescue` เท่านั้นที่สามารถบอกได้ว่าวัตถุอะไรก็ตามสามารถทำซ้ำได้หรือไม่  `duplicable?` ขึ้นอยู่กับรายการที่กำหนดไว้แบบฮาร์ดโค้ดด้านบน แต่มันเร็วกว่า `rescue` มาก ใช้เฉพาะเมื่อคุณทราบว่ารายการที่กำหนดไว้แบบฮาร์ดโค้ดเพียงพอสำหรับกรณีการใช้งานของคุณ

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/object/duplicable.rb`


### `deep_dup`

เมธอด [`deep_dup`][Object#deep_dup] จะคืนค่าสำเนาลึกของวัตถุที่กำหนด โดยปกติเมื่อคุณทำซ้ำวัตถุที่มีวัตถุอื่น ๆ ภายใน Ruby จะไม่ทำซ้ำวัตถุเหล่านั้น ดังนั้นจะสร้างสำเนาตื้นของวัตถุ ถ้าคุณมีอาร์เรย์ที่มีสตริงเช่น เช่นนี้:

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# วัตถุถูกทำซ้ำดังนั้นองค์ประกอบถูกเพิ่มไปในสำเนาเท่านั้น
array     # => ['string']
duplicate # => ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# องค์ประกอบแรกไม่ได้ทำซ้ำ จะเปลี่ยนแปลงในทั้งสองอาร์เรย์
array     # => ['foo']
duplicate # => ['foo', 'another-string']
```

จากตัวอย่างนี้ หลังจากทำซ้ำอินสแตนซ์ของ `Array` เราได้วัตถุอื่น ๆ ซึ่งเราสามารถแก้ไขได้และวัตถุต้นฉบับจะไม่เปลี่ยนแปลง แต่สำหรับองค์ประกอบของอาร์เรย์ ไม่เช่นนั้น โดยเนื่องจาก `dup` ไม่ทำสำเนาลึก สตริงภายในอาร์เรย์ยังคงเป็นวัตถุเดียวกัน

หากคุณต้องการสำเนาลึกของวัตถุ คุณควรใช้ `deep_dup` ตัวอย่างเช่นนี้:

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     # => ['string']
duplicate # => ['foo']
```

หากวัตถุไม่สามารถทำซ้ำได้ `deep_dup` จะคืนค่าวัตถุเดิม:

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/object/deep_dup.rb`


### `try`

เมื่อคุณต้องการเรียกเมธอดบนวัตถุเฉพาะเมื่อไม่เป็น `nil` วิธีที่ง่ายที่สุดในการทำได้คือใช้เงื่อนไขเพิ่มเติมซึ่งทำให้เกิดความสับสนโดยไม่จำเป็น ทางเลือกคือการใช้ [`try`][Object#try] `try` เหมือนกับ `Object#public_send` ยกเว้นว่าจะคืนค่า `nil` หากส่งไปยัง `nil`
นี่คือตัวอย่าง:

```ruby
# โดยไม่ใช้ try
unless @number.nil?
  @number.next
end

# ใช้ try
@number.try(:next)
```

ตัวอย่างอื่นคือโค้ดนี้จาก `ActiveRecord::ConnectionAdapters::AbstractAdapter` ที่ `@logger` อาจเป็น `nil` คุณสามารถเห็นว่าโค้ดใช้ `try` และหลีกเลี่ยงการตรวจสอบที่ไม่จำเป็น

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try` ยังสามารถเรียกโดยไม่มีอาร์กิวเมนต์แต่มีบล็อก ซึ่งจะถูกดำเนินการเฉพาะเมื่อออบเจ็กต์ไม่ใช่ nil:

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

โปรดทราบว่า `try` จะย่อการเกิดข้อผิดพลาดที่ไม่มีเมธอด และส่งคืน nil แทน หากคุณต้องการป้องกันการพิมพ์ผิดใช้ [`try!`][Object#try!] แทน:

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/object/try.rb`.


### `class_eval(*args, &block)`

คุณสามารถประเมินโค้ดในบริบทของคลาสเดี่ยวของวัตถุใด ๆ โดยใช้ [`class_eval`][Kernel#class_eval]:

```ruby
class Proc
  def bind(object)
    block, time = self, Time.current
    object.class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/kernel/singleton_class.rb`.


### `acts_like?(duck)`

เมธอด [`acts_like?`][Object#acts_like?] ให้วิธีการตรวจสอบว่าคลาสใดคลาสหนึ่งทำหน้าที่เหมือนคลาสอื่นๆ โดยอิงตามสัญญาที่เรียบง่าย: คลาสที่ให้ส่วนติดต่อเดียวกับ `String` กำหนด

```ruby
def acts_like_string?
end
```

ซึ่งเป็นเพียงตัวบ่งชี้เท่านั้น ส่วนเนื้อหาหรือค่าที่ส่งกลับไม่สำคัญ จากนั้น โค้ดไคลเอ็นต์สามารถสอบถามความปลอดภัยของ duck-type ได้ดังนี้:

```ruby
some_klass.acts_like?(:string)
```

Rails มีคลาสที่ทำหน้าที่เหมือน `Date` หรือ `Time` และปฏิบัติตามสัญญานี้

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/object/acts_like.rb`.


### `to_param`

วัตถุทั้งหมดใน Rails ตอบสนองต่อเมธอด [`to_param`][Object#to_param] ซึ่งจะส่งคืนสิ่งที่แทนวัตถุนั้นในรูปของค่าในสตริงคิวรี หรือเป็นส่วนของ URL

โดยค่าเริ่มต้น `to_param` เพียงเรียก `to_s` เท่านั้น:

```ruby
7.to_param # => "7"
```

ค่าที่ส่งคืนจาก `to_param` ไม่ควรถูกหนีไป:

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

คลาสหลายคลาสใน Rails เขียนทับเมธอดนี้

ตัวอย่างเช่น `nil`, `true`, และ `false` จะส่งคืนตัวเอง [`Array#to_param`][Array#to_param] เรียก `to_param` บนสมาชิกและรวมผลลัพธ์ด้วย "/":

```ruby
[0, true, String].to_param # => "0/true/String"
```

ความสำคัญคือระบบเส้นทางของ Rails เรียก `to_param` บนโมเดลเพื่อรับค่าสำหรับตัวแทน `:id`  [`ActiveRecord::Base#to_param`][ActiveRecord::Base#to_param] ส่งคืน `id` ของโมเดล แต่คุณสามารถกำหนดเมธอดนี้ในโมเดลของคุณได้ ตัวอย่างเช่น กำหนดให้

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

เราจะได้:

```ruby
user_path(@user) # => "/users/357-john-smith"
```

คำเตือน ตัวควบคุมจำเป็นต้องรับทราบการกำหนดเมธอด `to_param` เพราะเมื่อคำขอเช่นนั้นเข้ามา "357-john-smith" เป็นค่าของ `params[:id]` 

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/object/to_param.rb`.


### `to_query`

เมธอด [`to_query`][Object#to_query] สร้างสตริงคิวรีที่เชื่อมโยงคีย์ที่กำหนดกับค่าที่ส่งคืนจาก `to_param` ตัวอย่างเช่น ด้วยการกำหนด `to_param` ต่อไปนี้:

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

เราจะได้:

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

เมธอดนี้หนีไปทุกอย่างที่จำเป็นทั้งสำหรับคีย์และค่า:

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

ดังนั้นผลลัพธ์ของมันพร้อมใช้งานในสตริงคิวรี

อาร์เรย์จะส่งผลลัพธ์จากการใช้ `to_query` กับแต่ละองค์ประกอบโดยใช้ `key[]` เป็นคีย์ และรวมผลลัพธ์ด้วย "&":

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

และแฮชตอนเรียกใช้ `to_query` ด้วยลายเซ็นต์ที่แตกต่างกัน หากไม่มีอาร์กิวเมนต์ที่ถูกส่งผ่าน การเรียกใช้จะสร้างชุดคีย์/ค่าที่เรียงลำดับและเรียกใช้ `to_query(key)` กับค่าของมัน จากนั้นรวมผลลัพธ์ด้วย "&":

```ruby
{ c: 3, b: 2, a: 1 }.to_query # => "a=1&b=2&c=3"
```

เมธอด [`Hash#to_query`][Hash#to_query] ยอมรับเนมสเปซเวชั่นที่เป็นทางเลือกสำหรับคีย์:

```ruby
{ id: 89, name: "John Smith" }.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/object/to_query.rb`.


### `with_options`

เมธอด [`with_options`][Object#with_options] ให้วิธีการในการแบ่งออกเป็นตัวเลือกที่ซ้ำกันในชุดของการเรียกเมธอด

โดยให้แฮชตัวเลือกเริ่มต้น  `with_options` ส่งคืนวัตถุพร็อกซีไปยังบล็อก ภายในบล็อก การเรียกเมธอดบนพร็อกจะถูกส่งต่อไปยังผู้รับด้วยตัวเลือกที่ถูกผสาน ตัวอย่างเช่น คุณจะกำจัดความซ้ำซ้อนใน:

```ruby
class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

โดยใช้วิธีนี้:

```ruby
class Account < ApplicationRecord
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end
```

วิธีการนี้อาจสื่อถึงการจัดกลุ่มให้กับผู้อ่านด้วย ตัวอย่างเช่น สมมุติว่าคุณต้องการส่งจดหมายข่าวที่ภาษาขึ้นอยู่กับผู้ใช้ คุณสามารถจัดกลุ่มส่วนที่ขึ้นอยู่กับภาษาได้ดังนี้:

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

เคล็ดลับ: เนื่องจาก `with_options` ส่งการเรียกไปยังผู้รับของมัน คุณสามารถซ้อนกันได้ แต่ละระดับการซ้อนจะผสานค่าเริ่มต้นที่ถูกสืบทอดเพิ่มเติมนอกจากตัวเอง

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/object/with_options.rb`.


### การสนับสนุน JSON

Active Support ให้การสนับสนุน JSON ที่ดีกว่า `json` gem ที่มักจะให้สำหรับวัตถุ Ruby นี้เพราะบางคลาส เช่น `Hash` และ `Process::Status` ต้องการการจัดการพิเศษเพื่อให้ได้รูปแบบ JSON ที่ถูกต้อง

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/object/json.rb`.

### ตัวแปรอินสแตนซ์

Active Support ให้เมธอดหลายตัวเพื่อสะดวกในการเข้าถึงตัวแปรอินสแตนซ์

#### `instance_values`

เมธอด [`instance_values`][Object#instance_values] ส่งคืนแฮชที่แมปชื่อตัวแปรอินสแตนซ์โดยไม่มี "@" ไปยังค่าที่เกี่ยวข้อง คีย์เป็นสตริง:

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/object/instance_variables.rb`.


#### `instance_variable_names`

เมธอด [`instance_variable_names`][Object#instance_variable_names] ส่งคืนอาร์เรย์ แต่ละชื่อรวมถึงเครื่องหมาย "@"

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/object/instance_variables.rb`.


### การปิดเสียงคำเตือนและข้อยกเว้น

เมธอด [`silence_warnings`][Kernel#silence_warnings] และ [`enable_warnings`][Kernel#enable_warnings] เปลี่ยนค่าของ `$VERBOSE` ตามที่เหมาะสมสำหรับระยะเวลาในบล็อกของพวกเขา และรีเซ็ตค่าเดิมหลังจากนั้น:

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

การปิดเสียงข้อยกเว้นก็เป็นไปได้ด้วย [`suppress`][Kernel#suppress] เมธอดนี้รับคลาสข้อยกเว้นอย่างไม่จำกัด หากมีข้อยกเว้นถูกเรียกใช้ระหว่างการดำเนินการในบล็อกและเป็น `kind_of?` ของอาร์กิวเมนต์ใด ๆ `suppress` จะจับค่านั้นและส่งคืนโดยเงียบ มิฉะนั้นข้อยกเว้นจะไม่ถูกจับ:

```ruby
# หากผู้ใช้ถูกล็อกไว้ การเพิ่มจำนวนจะหายไปโดยไม่มีผลกระทบใหญ่
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/kernel/reporting.rb`.


### `in?`

ตัวตรวจสอบ [`in?`][Object#in?] ทดสอบว่าวัตถุหนึ่งอยู่ในวัตถุอื่น หากอาร์กิวเมนต์ที่ส่งผ่านไม่ตอบสนองกับ `include?` จะเกิดข้อยกเว้น `ArgumentError`.

ตัวอย่างของ `in?`:

```ruby
1.in?([1, 2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/object/inclusion.rb`.


ส่วนขยายของ `Module`
----------------------

### แอตทริบิวต์

#### `alias_attribute`

แอตทริบิวต์ของโมเดลมีตัวอ่าน ตัวเขียน และตัวตรวจสอบ คุณสามารถตั้งชื่อแอตทริบิวต์ของโมเดลให้มีเมธอดสามตัวที่กำหนดไว้ทั้งหมดโดยใช้ [`alias_attribute`][Module#alias_attribute] คล้ายกับเมธอดการตั้งชื่ออื่น ชื่อใหม่เป็นอาร์กิวเมนต์แรกและชื่อเดิมเป็นอาร์กิวเมนต์ที่สอง (หนึ่งวิธีจำชื่อได้คือใส่ตามลำดับเหมือนกับการกำหนดค่า):

```ruby
class User < ApplicationRecord
  # คุณสามารถอ้างอิงคอลัมน์อีเมลเป็น "login" ได้
  # สิ่งนี้อาจมีความหมายสำหรับรหัสการตรวจสอบ
  alias_attribute :login, :email
end
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/module/aliasing.rb`.


#### แอตทริบิวต์ภายใน

เมื่อคุณกำลังกำหนดแอตทริบิวต์ในคลาสที่ตั้งใจให้เป็นคลาสย่อย การชนกันของชื่อเป็นความเสี่ยง ซึ่งเป็นสิ่งสำคัญอย่างมากสำหรับไลบรารี

Active Support กำหนดแมโคร [`attr_internal_reader`][Module#attr_internal_reader], [`attr_internal_writer`][Module#attr_internal_writer], และ [`attr_internal_accessor`][Module#attr_internal_accessor] พวกเขามีพฤติกรรมเหมือนกับ `attr_*` ที่มีอยู่ใน Ruby แต่ชื่อตัวแปรอินสแตนซ์ใต้หลังคาที่ทำให้เกิดชนกันน้อยลง

แมโคร [`attr_internal`][Module#attr_internal] เป็นคำเหมือนกับ `attr_internal_accessor`:

```ruby
# ไลบรารี
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# โค้ดของไคลเอ็นต์
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

ในตัวอย่างก่อนหน้านี้อาจเป็นได้ว่า `:log_level` ไม่ได้อยู่ในอินเทอร์เฟซสาธารณะของไลบรารีและใช้เพียงสำหรับการพัฒนาเท่านั้น โค้ดของไคลเอ็นต์ไม่รู้จักชนกันและกำหนด `:log_level` ของตัวเอง ด้วย `attr_internal` ไม่มีการชนกัน

ตามค่าเริ่มต้น ตัวแปรอินสแตนซ์ภายในจะถูกตั้งชื่อด้วยเครื่องหมายขีดล่างนำหน้า `@_log_level` ในตัวอย่างข้างต้น สามารถกำหนดได้ผ่าน `Module.attr_internal_naming_format` คุณสามารถส่งสตริงรูปแบบ `sprintf` ที่มีเครื่องหมาย `@` นำหน้าและ `%s` ที่ใดก็ได้ที่จะใส่ชื่อ ค่าเริ่มต้นคือ `"@_%s"`

Rails ใช้แอตทริบิวต์ภายในในสถานที่บางแห่ง เช่นสำหรับวิว:

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/module/attr_internal.rb`.


#### แอตทริบิวต์ของโมดูล

แมโคร [`mattr_reader`][Module#mattr_reader], [`mattr_writer`][Module#mattr_writer], และ [`mattr_accessor`][Module#mattr_accessor] เหมือนกับแมโคร `cattr_*` ที่กำหนดไว้สำหรับคลาส ในความเป็นจริงแล้ว แมโคร `cattr_*` เป็นคำย่อสำหรับแมโคร `mattr_*` ดูที่ [แอตทริบิวต์ของคลาส](#class-attributes)

ตัวอย่างเช่น API สำหรับ logger ของ Active Storage ถูกสร้างขึ้นด้วย `mattr_accessor`:

```ruby
module ActiveStorage
  mattr_accessor :logger
end
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/module/attribute_accessors.rb`.


### พ่อแม่

#### `module_parent`

เมธอด [`module_parent`][Module#module_parent] บนโมดูลที่มีชื่อซ้อนกันคืนค่าโมดูลที่มีค่าคงที่ที่สอดคล้องกับค่าคงที่ของมัน:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent # => X::Y
M.module_parent       # => X::Y
```

หากโมดูลเป็นโมดูลที่ไม่มีชื่อหรือเป็นส่วนหนึ่งของระดับบนสุด `module_parent` จะคืนค่า `Object`.
คำเตือน: โปรดทราบว่าในกรณีนั้น `module_parent_name` จะส่งคืนค่า `nil`.

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/module/introspection.rb`.


#### `module_parent_name`

เมธอด [`module_parent_name`][Module#module_parent_name] บนโมดูลที่มีชื่อซ้อนกันจะส่งคืนชื่อที่เต็มรูปแบบของโมดูลที่มีค่าคงที่ที่เกี่ยวข้อง:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent_name # => "X::Y"
M.module_parent_name       # => "X::Y"
```

สำหรับโมดูลระดับบนสุดหรือโมดูลที่ไม่มีชื่อ `module_parent_name` จะส่งคืนค่า `nil`.

คำเตือน: โปรดทราบว่าในกรณีนั้น `module_parent` จะส่งคืนค่า `Object`.

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/module/introspection.rb`.


#### `module_parents`

เมธอด [`module_parents`][Module#module_parents] เรียกใช้ `module_parent` บนวัตถุต้นฉบับและวัตถุย้อนหลังจนถึง `Object` เส้นโซ่จะถูกส่งคืนในรูปแบบของอาร์เรย์จากล่างไปบน:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parents # => [X::Y, X, Object]
M.module_parents       # => [X::Y, X, Object]
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/module/introspection.rb`.


### โมดูลที่ไม่มีชื่อ

โมดูลอาจมีชื่อหรือไม่มีชื่อ:

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

คุณสามารถตรวจสอบว่าโมดูลมีชื่อหรือไม่ด้วยตัวตรวจสอบ [`anonymous?`][Module#anonymous?]:

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

โปรดทราบว่าการไม่สามารถเข้าถึงได้ไม่ได้หมายความว่าไม่มีชื่อ:

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

แม้ว่าโมดูลที่ไม่มีชื่อจะไม่สามารถเข้าถึงได้ตามนิยาม

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/module/anonymous.rb`.


### การส่งมอบเมธอด

#### `delegate`

แมโคร [`delegate`][Module#delegate] นำเสนอวิธีง่ายในการส่งเมธอดไปยังอื่น ๆ

สมมติว่าผู้ใช้ในแอปพลิเคชันบางอย่างมีข้อมูลการเข้าสู่ระบบในโมเดล `User` แต่ชื่อและข้อมูลอื่น ๆ อยู่ในโมเดล `Profile` ที่แยกออกมา:

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

ด้วยการกำหนดค่านี้คุณสามารถรับชื่อของผู้ใช้ผ่านโปรไฟล์ของพวกเขาได้ `user.profile.name` แต่อาจจะเป็นประโยชน์ที่จะยังสามารถเข้าถึงแอตทริบิวต์ดังกล่าวโดยตรงได้:

```ruby
class User < ApplicationRecord
  has_one :profile

  def name
    profile.name
  end
end
```

นั่นคือสิ่งที่ `delegate` ทำให้คุณ:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate :name, to: :profile
end
```

มันสั้นกว่าและเจตนาชัดเจนกว่า

เมธอดต้องเป็นสาธารณะในเป้าหมาย

แมโคร `delegate` ยอมรับเมธอดหลาย ๆ ตัว:

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

เมื่อถูกตีพิมพ์เป็นสตริง ตัวเลือก `:to` ควรกลายเป็นนิพจน์ที่ประเมินค่าเป็นวัตถุที่เมธอดถูกส่งมอบไป โดยทั่วไปเป็นสตริงหรือสัญลักษณ์ นิพจน์เช่นนี้จะถูกประเมินในบริบทของผู้รับ:

```ruby
# ส่งมอบไปยังค่าคงที่ Rails
delegate :logger, to: :Rails

# ส่งมอบไปยังคลาสของผู้รับ
delegate :table_name, to: :class
```

คำเตือน: หากตัวเลือก `:prefix` เป็น `true` นี้จะไม่สามารถใช้ได้ทั่วไป ดูข้างล่าง

ตามค่าเริ่มต้น หากการส่งมอบเกิดข้อผิดพลาด `NoMethodError` และเป้าหมายเป็น `nil` ข้อยกเว้นจะถูกส่งต่อ คุณสามารถขอให้ส่งคืน `nil` แทนด้วยตัวเลือก `:allow_nil`:

```ruby
delegate :name, to: :profile, allow_nil: true
```

ด้วย `:allow_nil` การเรียก `user.name` จะส่งคืน `nil` หากผู้ใช้ไม่มีโปรไฟล์

ตัวเลือก `:prefix` เพิ่มคำนำหน้าในชื่อของเมธอดที่สร้างขึ้น นี่อาจเป็นประโยชน์ตัวอย่างเช่นในการรับชื่อที่ดีขึ้น:
```ruby
delegate :street, to: :address, prefix: true
```

ตัวอย่างก่อนหน้านี้สร้าง `address_street` แทนที่จะเป็น `street`

คำเตือน: ในกรณีนี้เนื่องจากชื่อของเมธอดที่สร้างขึ้นมาเป็นชื่อของวัตถุเป้าหมายและชื่อเมธอดเป้าหมาย ตัวเลือก `:to` ต้องเป็นชื่อเมธอด

สามารถกำหนดคำนำหน้าที่กำหนดเองได้เช่นกัน:

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

ในตัวอย่างก่อนหน้านี้ แมโครสร้าง `avatar_size` แทนที่จะเป็น `size`

ตัวเลือก `:private` จะเปลี่ยนขอบเขตของเมธอด:

```ruby
delegate :date_of_birth, to: :profile, private: true
```

เมธอดที่ถูกมอบหมายจะเป็นสาธารณะตามค่าเริ่มต้น ส่ง `private: true` เพื่อเปลี่ยนแปลงค่านั้น

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/module/delegation.rb`


#### `delegate_missing_to`

สมมติว่าคุณต้องการมอบหมายทุกอย่างที่ขาดหายไปจากวัตถุ `User` ไปยัง `Profile` โมดูล [`delegate_missing_to`][Module#delegate_missing_to] ช่วยให้คุณสามารถทำได้ง่ายๆ:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate_missing_to :profile
end
```

เป้าหมายสามารถเป็นอะไรก็ได้ที่เรียกใช้งานได้ภายในวัตถุ เช่น ตัวแปรอินสแตนซ์ เมธอด ค่าคงที่ เป็นต้น เฉพาะเมธอดสาธารณะของเป้าหมายเท่านั้นที่ถูกมอบหมาย

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/module/delegation.rb`.


### การกำหนดเมธอดใหม่

มีกรณีที่คุณต้องการกำหนดเมธอดด้วย `define_method` แต่ไม่ทราบว่าเมธอดที่มีชื่อนั้นมีอยู่แล้วหรือไม่ หากมี จะมีการเตือนเตือนถ้าเปิดใช้งาน ไม่ใหญ่มาก แต่ไม่สะอาดเท่าไหร่

เมธอด [`redefine_method`][Module#redefine_method] ป้องกันการเตือนเตือนเช่นนั้น โดยลบเมธอดที่มีอยู่ก่อนหน้านั้นออกหากจำเป็น

คุณยังสามารถใช้ [`silence_redefinition_of_method`][Module#silence_redefinition_of_method] หากคุณต้องการกำหนดเมธอดทดแทนเอง (เนื่องจากคุณกำลังใช้ `delegate` เป็นต้น)

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/module/redefine_method.rb`.


ส่วนขยายให้กับ `Class`
---------------------

### แอตทริบิวต์ของคลาส

#### `class_attribute`

เมธอด [`class_attribute`][Class#class_attribute] ประกาศแอตทริบิวต์ของคลาสที่สามารถถูกเขียนทับได้ในระดับใดก็ได้ในลำดับชั้นล่าง

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

ตัวอย่างเช่น `ActionMailer::Base` กำหนด:

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

สามารถเข้าถึงและเขียนทับได้ในระดับอินสแตนซ์เช่นกัน

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1, มาจาก A
a2.x # => 2, ถูกเขียนทับใน a2
```

การสร้างเมธอดไอนสแตนซ์ได้ถูกป้องกันโดยการตั้งค่า `:instance_writer` เป็น `false`.

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false, default: "my"
  end
end
```

โมเดลอาจพบว่าตัวเลือกนั้นเป็นประโยชน์เมื่อต้องการป้องกันการกำหนดค่าจำนวนมากจากการกำหนดค่าแบบมวลชน

การสร้างเมธอดอินสแตนซ์เพื่ออ่านได้ถูกป้องกันโดยการตั้งค่า `:instance_reader` เป็น `false`.

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

เพื่อความสะดวก `class_attribute` ยังกำหนดตัวตรวจสอบอินสแตนซ์ซึ่งเป็นการปฏิเสธค่าที่เมธอดอินสแตนซ์คืนค่า ในตัวอย่างข้างต้นจะเรียกว่า `x?`
เมื่อ `:instance_reader` เป็น `false` ตัวตรวจสอบของอินสแตนซ์จะคืนค่า `NoMethodError` เหมือนกับเมธอดอ่าน

หากคุณไม่ต้องการตัวตรวจสอบของอินสแตนซ์ ให้ส่ง `instance_predicate: false` และมันจะไม่ถูกกำหนด

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/class/attribute.rb`


#### `cattr_reader`, `cattr_writer`, และ `cattr_accessor`

แมโคร [`cattr_reader`][Module#cattr_reader], [`cattr_writer`][Module#cattr_writer], และ [`cattr_accessor`][Module#cattr_accessor] เป็นคู่คำสั่งที่คล้ายกับ `attr_*` แต่สำหรับคลาส พวกเขาจะกำหนดค่าตัวแปรคลาสเป็น `nil` ยกเว้นถ้ามันมีอยู่แล้ว และสร้างเมธอดคลาสที่เกี่ยวข้องในการเข้าถึง:

```ruby
class MysqlAdapter < AbstractAdapter
  # สร้างเมธอดคลาสเพื่อเข้าถึง @@emulate_booleans
  cattr_accessor :emulate_booleans
end
```

นอกจากนี้คุณยังสามารถส่งบล็อกไปยัง `cattr_*` เพื่อกำหนดค่าเริ่มต้นของแอตทริบิวต์:

```ruby
class MysqlAdapter < AbstractAdapter
  # สร้างเมธอดคลาสเพื่อเข้าถึง @@emulate_booleans โดยมีค่าเริ่มต้นเป็น true
  cattr_accessor :emulate_booleans, default: true
end
```

เมธอดอินสแตนซ์จะถูกสร้างขึ้นเพื่อความสะดวกด้วย แต่พวกเขาเป็นพร็อกซีไปยังแอตทริบิวต์คลาส ดังนั้นอินสแตนซ์สามารถเปลี่ยนแปลงแอตทริบิวต์คลาสได้ แต่ไม่สามารถแทนที่ได้เหมือนกับ `class_attribute` (ดูข้างต้น) ตัวอย่างเช่น

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

เราสามารถเข้าถึง `field_error_proc` ในวิวได้

การสร้างเมธอดอินสแตนซ์อ่านสามารถป้องกันได้โดยตั้งค่า `:instance_reader` เป็น `false` และการสร้างเมธอดอินสแตนซ์เขียนสามารถป้องกันได้โดยตั้งค่า `:instance_writer` เป็น `false` การสร้างทั้งสองเมธอดสามารถป้องกันได้โดยตั้งค่า `:instance_accessor` เป็น `false` ในทุกกรณีค่าจะต้องเป็น `false` เท่านั้นและไม่ใช่ค่าเท็จใดๆ

```ruby
module A
  class B
    # ไม่มีตัวอ่าน first_name สำหรับอินสแตนซ์ที่ถูกสร้างขึ้น
    cattr_accessor :first_name, instance_reader: false
    # ไม่มีตัวเขียน last_name= สำหรับอินสแตนซ์ที่ถูกสร้างขึ้น
    cattr_accessor :last_name, instance_writer: false
    # ไม่มีตัวอ่าน surname หรือตัวเขียน surname= สำหรับอินสแตนซ์ที่ถูกสร้างขึ้น
    cattr_accessor :surname, instance_accessor: false
  end
end
```

โมเดลอาจพบว่ามันเป็นประโยชน์ที่จะตั้งค่า `:instance_accessor` เป็น `false` เพื่อป้องกันการกำหนดค่าจำนวนมากจากการกำหนดค่าแบบมวลชน

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/module/attribute_accessors.rb`


### คลาสย่อยและลูกหลาน

#### `subclasses`

เมธอด [`subclasses`][Class#subclasses] จะคืนค่าคลาสย่อยของอ็อบเจกต์:

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

ลำดับที่คลาสเหล่านี้ถูกคืนค่าไม่ได้ระบุ

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/class/subclasses.rb`


#### `descendants`

เมธอด [`descendants`][Class#descendants] จะคืนค่าคลาสทั้งหมดที่เป็น `<` กว่าอ็อบเจกต์:

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

ลำดับที่คลาสเหล่านี้ถูกคืนค่าไม่ได้ระบุ

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/class/subclasses.rb`


ขยาย `String`
----------------

### ความปลอดภัยของผลลัพธ์

#### แรงจูงใจ

การแทรกข้อมูลลงในเทมเพลต HTML ต้องการความระมัดระวังเพิ่มเติม ตัวอย่างเช่นคุณไม่สามารถแทรก `@review.title` โดยตรงลงในหน้า HTML ได้ อย่างหนึ่งเพราะถ้าชื่อเรื่องรีวิวคือ "Flanagan & Matz rules!" ผลลัพธ์จะไม่ถูกต้องเพราะต้องหนีเครื่องหมายแอมเปอร์แทนด้วย "&amp;amp;" อีกอย่างนั้น ขึ้นอยู่กับแอปพลิเคชัน มันอาจเป็นช่องโหว่ความปลอดภัยที่ใหญ่เพราะผู้ใช้สามารถฉายโค้ด HTML ที่ไม่ดีเข้าไปได้โดยการตั้งค่าชื่อเรื่องรีวิวเอง ดูส่วนเกี่ยวกับการโจมตีแบบ Cross-Site Scripting ใน[คู่มือความปลอดภัย](security.html#cross-site-scripting-xss) เพื่อข้อมูลเพิ่มเติมเกี่ยวกับความเสี่ยง
#### สตริงที่ปลอดภัย

Active Support มีแนวคิดของสตริงที่เป็น _(html) safe_ สตริงที่ปลอดภัยคือสตริงที่ถูกทำเครื่องหมายว่าสามารถแทรกใส่ HTML ได้อย่างเดียว มันถูกเชื่อถือไม่ว่าจะถูกหลีกเลี่ยงหรือไม่

สตริงถือว่า _ไม่ปลอดภัย_ โดยค่าเริ่มต้น:

```ruby
"".html_safe? # => false
```

คุณสามารถรับสตริงที่ปลอดภัยจากสตริงที่กำหนดได้ด้วยเมธอด [`html_safe`][String#html_safe]:

```ruby
s = "".html_safe
s.html_safe? # => true
```

สิ่งสำคัญที่ต้องเข้าใจคือ `html_safe` ไม่ได้ทำการหลีกเลี่ยงใดๆเลย มันเป็นการยืนยันเท่านั้น:

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

คุณต้องรับผิดชอบในการตรวจสอบว่าการเรียกใช้ `html_safe` กับสตริงที่เฉพาะเจาะจงนั้นเป็นเรื่องปลอดภัยหรือไม่

หากคุณต่อสตริงที่ปลอดภัย ไม่ว่าจะโดยใช้ `concat`/`<<` หรือ `+` ผลลัพธ์ที่ได้คือสตริงที่ปลอดภัย อาร์กิวเมนต์ที่ไม่ปลอดภัยจะถูกหลีกเลี่ยง:

```ruby
"".html_safe + "<" # => "&lt;"
```

อาร์กิวเมนต์ที่ปลอดภัยจะถูกต่อเติมโดยตรง:

```ruby
"".html_safe + "<".html_safe # => "<"
```

เมธอดเหล่านี้ไม่ควรใช้ในมุมมองทั่วไป ค่าที่ไม่ปลอดภัยจะถูกหลีกเลี่ยงโดยอัตโนมัติ:

```erb
<%= @review.title %> <%# ปลอดภัยถ้าจำเป็น %>
```

ในการแทรกสิ่งที่ตรงกันข้ามใช้ตัวช่วย [`raw`][] แทนการเรียกใช้ `html_safe`:

```erb
<%= raw @cms.current_template %> <%# แทรก @cms.current_template ตามที่กำหนดไว้อย่างเดียว %>
```

หรือใช้ `<%==` ในทางเทียบเท่า:

```erb
<%== @cms.current_template %> <%# แทรก @cms.current_template ตามที่กำหนดไว้อย่างเดียว %>
```

ตัวช่วย `raw` เรียกใช้ `html_safe` ให้คุณ:

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/string/output_safety.rb`.


#### การแปลง

ตามหลักทั่วไป ยกเว้นการต่อสตริงเช่นที่อธิบายไว้ข้างต้น วิธีการใดๆที่อาจเปลี่ยนแปลงสตริงจะให้คุณได้สตริงที่ไม่ปลอดภัย ตัวอย่างเช่น `downcase`, `gsub`, `strip`, `chomp`, `underscore`, เป็นต้น

ในกรณีของการเปลี่ยนแปลงในตำแหน่งเดียวกันเช่น `gsub!` ตัวรับเองก็จะกลายเป็นสตริงที่ไม่ปลอดภัย

ข้อมูล: สตริงที่ปลอดภัยจะสูญหายเสมอไม่ว่าการเปลี่ยนแปลงจะเป็นอย่างไร


#### การแปลงและการบังคับ

การเรียกใช้ `to_s` กับสตริงที่ปลอดภัยจะคืนค่าเป็นสตริงที่ปลอดภัย แต่การบังคับด้วย `to_str` จะคืนค่าเป็นสตริงที่ไม่ปลอดภัย


#### การคัดลอก

การเรียกใช้ `dup` หรือ `clone` กับสตริงที่ปลอดภัยจะคืนค่าเป็นสตริงที่ปลอดภัย

### `remove`

เมธอด [`remove`][String#remove] จะลบทุกครั้งที่พบรูปแบบ:

```ruby
"Hello World".remove(/Hello /) # => "World"
```

ยังมีเวอร์ชันที่ทำลาย `String#remove!` เช่นกัน

ข้อมูล: ถูกกำหนดไว้ใน `active_support/core_ext/string/filters.rb`.


### `squish`

เมธอด [`squish`][String#squish] จะลบช่องว่างด้านหน้าและด้านหลัง และแทนที่ช่วงช่องว่างด้วยช่องว่างเดียว:

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

ยังมีเวอร์ชันที่ทำลาย `String#squish!` เช่นกัน

โปรดทราบว่ามันจัดการกับช่องว่างทั้ง ASCII และ Unicode

ข้อมูล: ถูกกำหนดไว้ใน `active_support/core_ext/string/filters.rb`.


### `truncate`

เมธอด [`truncate`][String#truncate] จะคืนค่าสำเนาของสตริงตัดท้ายหลังจากความยาวที่กำหนด:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

สามารถกำหนดลักษณะของ ellipsis ด้วยตัวเลือก `:omission`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

โปรดทราบโดยเฉพาะว่าการตัดท้ายนี้คำนึงถึงความยาวของสตริงที่ใช้แทน

ส่ง `:separator` เพื่อตัดสตริงที่จุดพักธรรมชาติ:
```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

ตัวเลือก `:separator` สามารถเป็น regexp ได้:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

ในตัวอย่างข้างต้น "dear" ถูกตัดก่อน แต่ตัวเลือก `:separator` ป้องกันการตัด

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/filters.rb`.


### `truncate_bytes`

เมธอด [`truncate_bytes`][String#truncate_bytes] คืนค่าสำเนาของตัวอักษรตัดแต่ละตัวอักษรให้มีขนาดไม่เกิน `bytesize` ไบต์:

```ruby
"👍👍👍👍".truncate_bytes(15)
# => "👍👍👍…"
```

สามารถกำหนด ellipsis ด้วยตัวเลือก `:omission`:

```ruby
"👍👍👍👍".truncate_bytes(15, omission: "🖖")
# => "👍👍🖖"
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/filters.rb`.


### `truncate_words`

เมธอด [`truncate_words`][String#truncate_words] คืนค่าสำเนาของตัวอักษรตัดหลังจากจำนวนคำที่กำหนด:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

สามารถกำหนด ellipsis ด้วยตัวเลือก `:omission`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

ส่ง `:separator` เพื่อตัดตัวอักษรที่จุดพักธรรมชาติ:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! I shall be late..."
```

ตัวเลือก `:separator` สามารถเป็น regexp ได้:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/filters.rb`.


### `inquiry`

เมธอด [`inquiry`][String#inquiry] แปลงสตริงเป็นออบเจ็กต์ `StringInquirer` เพื่อทำให้การเปรียบเทียบเป็นรูปแบบที่สวยงามขึ้น

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/inquiry.rb`.


### `starts_with?` และ `ends_with?`

Active Support กำหนดตัวย่อของ `String#start_with?` และ `String#end_with?` ในบุคคลที่สาม:

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/starts_ends_with.rb`.

### `strip_heredoc`

เมธอด [`strip_heredoc`][String#strip_heredoc] ลบการเยื้องใน heredocs

ตัวอย่างเช่นใน

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    This command does such and such.

    Supported options are:
      -h         This message
      ...
  USAGE
end
```

ผู้ใช้จะเห็นข้อความการใช้งานที่จัดชิดกับขอบซ้าย

เทคนิคนี้จะค้นหาบรรทัดที่ย่อยที่สุดในสตริงทั้งหมดและลบ
จำนวนช่องว่างด้านหน้านั้น

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/strip.rb`.


### `indent`

เมธอด [`indent`][String#indent] ย่อหน้าบรรทัดในสตริง:

```ruby
<<EOS.indent(2)
def some_method
  some_code
end
EOS
# =>
  def some_method
    some_code
  end
```

อาร์กิวเมนต์ที่สอง `indent_string` ระบุว่าจะใช้สตริงย่อหน้าใด ค่าเริ่มต้นคือ `nil` ซึ่งบอกให้เมธอดทำการเดาโดยมองไปที่บรรทัดแรกที่ย่อหน้าแล้วใช้ช่องว่างหากไม่มี

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

ในขณะที่ `indent_string` มักจะเป็นช่องว่างหรือแท็บ แต่ก็สามารถเป็นสตริงอื่นได้

อาร์กิวเมนต์ที่สาม `indent_empty_lines` เป็นตัวกำหนดว่าจะย่อหน้าบรรทัดว่างหรือไม่ ค่าเริ่มต้นคือเท็จ

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

เมธอด [`indent!`][String#indent!] ทำการย่อหน้าในตำแหน่งเดิม

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/indent.rb`.
### การเข้าถึง

#### `at(position)`

เมธอด [`at`][String#at] จะคืนค่าตัวอักษรของสตริงที่ตำแหน่ง `position`:

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/access.rb`.


#### `from(position)`

เมธอด [`from`][String#from] จะคืนค่าสตริงย่อยของสตริงที่เริ่มต้นที่ตำแหน่ง `position`:

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/access.rb`.


#### `to(position)`

เมธอด [`to`][String#to] จะคืนค่าสตริงย่อยของสตริงจนถึงตำแหน่ง `position`:

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/access.rb`.


#### `first(limit = 1)`

เมธอด [`first`][String#first] จะคืนค่าสตริงย่อยที่ประกอบด้วยตัวอักษรแรก `limit` ตัวของสตริง

การเรียกใช้ `str.first(n)` เทียบเท่ากับ `str.to(n-1)` ถ้า `n` > 0 และจะคืนสตริงว่างสำหรับ `n` == 0.

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/access.rb`.


#### `last(limit = 1)`

เมธอด [`last`][String#last] จะคืนค่าสตริงย่อยที่ประกอบด้วยตัวอักษรสุดท้าย `limit` ตัวของสตริง

การเรียกใช้ `str.last(n)` เทียบเท่ากับ `str.from(-n)` ถ้า `n` > 0 และจะคืนสตริงว่างสำหรับ `n` == 0.

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/access.rb`.


### การผันคำ

#### `pluralize`

เมธอด [`pluralize`][String#pluralize] จะคืนค่ารูปพหูพจน์ของสตริงที่รับเข้ามา:

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

เช่นตัวอย่างก่อนหน้านี้แสดงให้เห็นว่า Active Support รู้จักบางรูปพหูพจน์ที่ไม่เป็นไปตามกฎและคำนามที่ไม่นับได้ กฎที่มีอยู่สามารถขยายได้ใน `config/initializers/inflections.rb` ไฟล์นี้ถูกสร้างขึ้นโดยค่าเริ่มต้นโดยคำสั่ง `rails new` และมีคำแนะนำในคอมเมนต์

`pluralize` ยังสามารถรับพารามิเตอร์ `count` ได้ ถ้า `count == 1` จะคืนรูปเอกพจน์ สำหรับค่าอื่น ๆ ของ `count` จะคืนรูปพหูพจน์:

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

Active Record ใช้เมธอดนี้เพื่อคำนวณชื่อตารางเริ่มต้นที่สอดคล้องกับโมเดล:

```ruby
# active_record/model_schema.rb
def undecorated_table_name(model_name)
  table_name = model_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/inflections.rb`.


#### `singularize`

เมธอด [`singularize`][String#singularize] เป็นการกลับค่าของ `pluralize`:

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

การสร้างคลาสที่เกี่ยวข้องกันโดยค่าเริ่มต้นใช้เมธอดนี้:

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/inflections.rb`.


#### `camelize`

เมธอด [`camelize`][String#camelize] จะคืนค่ารับเป็นตัวอักษรในรูปแบบแคเมิลเคส:

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

เป็นกฎทั่วไปที่คุณสามารถคิดว่าเมธอดนี้เป็นเมธอดที่แปลงเส้นทางเป็นชื่อคลาสหรือโมดูลใน Ruby โดยที่เครื่องหมายสแลชแยกเนมสเปซ:

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

เช่น เอ็กชันแพ็คใช้เมธอดนี้เพื่อโหลดคลาสที่ให้บริการเก็บเซสชันที่แน่นอน:

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize` ยอมรับอาร์กิวเมนต์ที่เป็นตัวเลือก สามารถเป็น `:upper` (ค่าเริ่มต้น) หรือ `:lower` โดยที่ตัวอักษรแรกจะกลายเป็นตัวพิมพ์เล็ก:
```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

นั่นอาจเป็นสิ่งที่มีประโยชน์ในการคำนวณชื่อเมธอดในภาษาที่ปฏิบัติตามกฎเดียวกันนั่นคือ JavaScript

ข้อมูล: เป็นกฎเกณฑ์ทั่วไปที่คุณสามารถคิดว่า `camelize` เป็นการกลับของ `underscore` แต่มีกรณีที่ไม่เป็นเช่นนั้น: `"SSLError".underscore.camelize` จะให้ผลลัพธ์เป็น `"SslError"` ในการรองรับกรณีเช่นนี้ Active Support ช่วยให้คุณระบุคำย่อใน `config/initializers/inflections.rb`:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize` ถูกตั้งชื่อให้เป็น [`camelcase`][String#camelcase]

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/inflections.rb`.


#### `underscore`

เมธอด [`underscore`][String#underscore] ทำการแปลงจากแบบ Camel case เป็นรูปแบบของพาธ:

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

และแปลง "::" กลับเป็น "/":

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

และเข้าใจสตริงที่ขึ้นต้นด้วยตัวพิมพ์เล็ก:

```ruby
"visualEffect".underscore # => "visual_effect"
```

`underscore` ไม่รับอาร์กิวเมนต์

Rails ใช้ `underscore` เพื่อให้ได้ชื่อที่เป็นตัวพิมพ์เล็กสำหรับคลาสคอนโทรลเลอร์:

```ruby
# actionpack/lib/abstract_controller/base.rb
def controller_path
  @controller_path ||= name.delete_suffix("Controller").underscore
end
```

ตัวอย่างเช่นค่านั้นคือค่าที่คุณได้รับใน `params[:controller]`

ข้อมูล: เป็นกฎเกณฑ์ทั่วไปที่คุณสามารถคิดว่า `underscore` เป็นการกลับของ `camelize` แต่มีกรณีที่ไม่เป็นเช่นนั้น เช่น `"SSLError".underscore.camelize` จะให้ผลลัพธ์เป็น `"SslError"`

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/inflections.rb`.


#### `titleize`

เมธอด [`titleize`][String#titleize] ทำการเปลี่ยนตัวอักษรตัวแรกของคำในสตริงให้เป็นตัวพิมพ์ใหญ่:

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize` ถูกตั้งชื่อให้เป็น [`titlecase`][String#titlecase]

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/inflections.rb`.


#### `dasherize`

เมธอด [`dasherize`][String#dasherize] ทำการแทนที่เครื่องหมาย underscore ในสตริงด้วยเครื่องหมาย dash:

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

ตัวแปลง XML ของโมเดลใช้เมธอดนี้เพื่อแทนที่เครื่องหมายของโหนดด้วย dash:

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/inflections.rb`.


#### `demodulize`

ให้สตริงที่มีชื่อคงที่ที่มีคุณสมบัติที่กำหนด, [`demodulize`][String#demodulize] คืนค่าชื่อคงที่เดียวกัน นั่นคือส่วนที่อยู่ทางขวาสุด:

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""
```

Active Record เช่นใช้เมธอดนี้ในการคำนวณชื่อคอลัมน์ของการนับจำนวน:

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/inflections.rb`.


#### `deconstantize`

ให้สตริงที่มีการอ้างอิงค่าคงที่ที่มีคุณสมบัติที่กำหนด, [`deconstantize`][String#deconstantize] ลบส่วนสุดท้ายออก โดยทั่วไปจะเหลือชื่อของคอนสแตนต์ที่เก็บ:

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/string/inflections.rb`.


#### `parameterize`

เมธอด [`parameterize`][String#parameterize] ทำการปรับปรุงสตริงให้เป็นรูปแบบที่ใช้ใน URL ที่สวยงาม

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

เพื่อรักษาตัวอักษรในสตริง ให้ตั้งค่าอาร์กิวเมนต์ `preserve_case` เป็น true โดยค่าเริ่มต้น `preserve_case` ถูกตั้งค่าเป็น false

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

ในการใช้ตัวคั่นแบบกำหนดเอง ให้แทนที่อาร์กิวเมนต์ `separator`

```ruby
"John Smith".parameterize(separator: "_") # => "john_smith"
"Kurt Gödel".parameterize(separator: "_") # => "kurt_godel"
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/string/inflections.rb`


#### `tableize`

เมธอด [`tableize`][String#tableize] คือ `underscore` ตามด้วย `pluralize`.

```ruby
"Person".tableize      # => "people"
"Invoice".tableize     # => "invoices"
"InvoiceLine".tableize # => "invoice_lines"
```

เป็นกฎทั่วไปว่า `tableize` จะคืนชื่อตารางที่สอดคล้องกับโมเดลที่กำหนดให้ ในกรณีที่เป็นกรณีง่าย การประมวลผลจริงใน Active Record ไม่ได้เป็นแบบ `tableize` โดยตรง แต่ยังทำการ demodulize ชื่อคลาสและตรวจสอบตัวเลือกบางอย่างที่อาจมีผลต่อสตริงที่คืนกลับ

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/string/inflections.rb`


#### `classify`

เมธอด [`classify`][String#classify] เป็นการกลับค่าของ `tableize` โดยคืนชื่อคลาสที่สอดคล้องกับชื่อตาราง:

```ruby
"people".classify        # => "Person"
"invoices".classify      # => "Invoice"
"invoice_lines".classify # => "InvoiceLine"
```

เมธอดเข้าใจชื่อตารางที่มีคุณสมบัติ:

```ruby
"highrise_production.companies".classify # => "Company"
```

โปรดทราบว่า `classify` คืนชื่อคลาสเป็นสตริง คุณสามารถรับออบเจกต์คลาสจริงๆได้โดยเรียกใช้ `constantize` บนสตริงนั้น ซึ่งจะอธิบายต่อไป

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/string/inflections.rb`


#### `constantize`

เมธอด [`constantize`][String#constantize] แก้ไขนิพจน์การอ้างอิงค่าคงที่ในตัวรับของมัน:

```ruby
"Integer".constantize # => Integer

module M
  X = 1
end
"M::X".constantize # => 1
```

หากสตริงประเมินไม่ได้เป็นค่าคงที่ที่รู้จักหรือเนื้อหาของมันไม่ใช่ชื่อค่าคงที่ที่ถูกต้อง `constantize` จะเรียก `NameError`

การแก้ไขชื่อค่าคงที่ด้วย `constantize` เริ่มต้นที่ `Object` ระดับสูงสุดเสมอ แม้ว่าจะไม่มี "::" นำหน้า

```ruby
X = :in_Object
module M
  X = :in_M

  X                 # => :in_M
  "::X".constantize # => :in_Object
  "X".constantize   # => :in_Object (!)
end
```

ดังนั้น โดยทั่วไปแล้ว มันไม่เทียบเท่ากับสิ่งที่ Ruby จะทำในจุดเดียวกัน หากค่าคงที่จริงๆถูกประเมิน

ทดสอบเมลเลอร์ได้รับเมลเลอร์ที่กำลังทดสอบจากชื่อคลาสทดสอบโดยใช้ `constantize`:

```ruby
# action_mailer/test_case.rb
def determine_default_mailer(name)
  name.delete_suffix("Test").constantize
rescue NameError => e
  raise NonInferrableMailerError.new(name)
end
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/string/inflections.rb`


#### `humanize`

เมธอด [`humanize`][String#humanize] ปรับแต่งชื่อแอตทริบิวต์สำหรับการแสดงผลให้กับผู้ใช้งาน

โดยเฉพาะอย่างยิ่ง มันทำการดำเนินการต่อไปนี้:

  * ใช้กฎการเอาชื่อมนุษย์กับอาร์กิวเมนต์
  * ลบขีดล่างนำหน้าหากมี
  * ลบ "_id" ท้ายสุดหากมี
  * แทนที่ขีดล่างด้วยช่องว่างหากมี
  * ทำให้ตัวพิมพ์เล็กทั้งหมดยกเว้นคำย่อ
  * ทำให้ตัวพิมพ์ใหญ่ตัวแรก

การทำให้ตัวพิมพ์ใหญ่ตัวแรกสามารถปิดการใช้งานได้โดยตั้งค่าตัวเลือก `:capitalize` เป็น false (ค่าเริ่มต้นคือ true)

```ruby
"name".humanize                         # => "Name"
"author_id".humanize                    # => "Author"
"author_id".humanize(capitalize: false) # => "author"
"comments_count".humanize               # => "Comments count"
"_id".humanize                          # => "Id"
```

หาก "SSL" ถูกกำหนดให้เป็นคำย่อ:

```ruby
'ssl_error'.humanize # => "SSL error"
```

เมธอดช่วย `full_messages` ใช้ `humanize` เป็นค่าเริ่มต้นเพื่อรวมชื่อแอตทริบิวต์:

```ruby
def full_messages
  map { |attribute, message| full_message(attribute, message) }
end

def full_message
  # ...
  attr_name = attribute.to_s.tr('.', '_').humanize
  attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
  # ...
end
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/string/inflections.rb`


#### `foreign_key`

เมธอด [`foreign_key`][String#foreign_key] ให้ชื่อคอลัมน์คีย์ต่างประเทศจากชื่อคลาส โดยการ demodulize, underscores, และเพิ่ม "_id":

```ruby
"User".foreign_key           # => "user_id"
"InvoiceLine".foreign_key    # => "invoice_line_id"
"Admin::Session".foreign_key # => "session_id"
```
ส่งอาร์กิวเมนต์เท็จหากคุณไม่ต้องการขีดล่างใน "_id":

```ruby
"User".foreign_key(false) # => "userid"
```

การเชื่อมโยงใช้เมธอดนี้เพื่อสร้างคีย์ต่างประเทศโดยอัตโนมัติ เช่น `has_one` และ `has_many` ทำดังนี้:

```ruby
# active_record/associations.rb
foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/string/inflections.rb`.


#### `upcase_first`

เมธอด [`upcase_first`][String#upcase_first] จะทำให้ตัวอักษรแรกของวัตถุเป็นตัวพิมพ์ใหญ่:

```ruby
"employee salary".upcase_first # => "Employee salary"
"".upcase_first                # => ""
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/string/inflections.rb`.


#### `downcase_first`

เมธอด [`downcase_first`][String#downcase_first] จะแปลงตัวอักษรแรกของวัตถุเป็นตัวพิมพ์เล็ก:

```ruby
"If I had read Alice in Wonderland".downcase_first # => "if I had read Alice in Wonderland"
"".downcase_first                                  # => ""
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/string/inflections.rb`.


### การแปลง

#### `to_date`, `to_time`, `to_datetime`

เมธอด [`to_date`][String#to_date], [`to_time`][String#to_time], และ [`to_datetime`][String#to_datetime] เป็นเมธอดที่ใช้สะดวกในการแปลงข้อมูลเป็นวันที่และเวลา:

```ruby
"2010-07-27".to_date              # => Tue, 27 Jul 2010
"2010-07-27 23:37:00".to_time     # => 2010-07-27 23:37:00 +0200
"2010-07-27 23:37:00".to_datetime # => Tue, 27 Jul 2010 23:37:00 +0000
```

`to_time` รับอาร์กิวเมนต์ทางเลือก `:utc` หรือ `:local` เพื่อระบุโซนเวลาที่ต้องการ:

```ruby
"2010-07-27 23:42:00".to_time(:utc)   # => 2010-07-27 23:42:00 UTC
"2010-07-27 23:42:00".to_time(:local) # => 2010-07-27 23:42:00 +0200
```

ค่าเริ่มต้นคือ `:local`.

โปรดอ้างอิงเอกสารของ `Date._parse` เพื่อดูรายละเอียดเพิ่มเติม

ข้อมูล: เมื่อวัตถุว่างเปล่า เมธอดเหล่านี้จะส่งคืน `nil`.

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/string/conversions.rb`.


ส่วนขยายให้กับ `Symbol`
----------------------

### `starts_with?` และ `ends_with?`

Active Support กำหนดตัวย่อของ `Symbol#start_with?` และ `Symbol#end_with?` ในบุคคลที่ 3:

```ruby
:foo.starts_with?("f") # => true
:foo.ends_with?("o")   # => true
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/symbol/starts_ends_with.rb`.

ส่วนขยายให้กับ `Numeric`
-----------------------

### Bytes

ตัวเลขทุกตัวสามารถใช้เมธอดเหล่านี้ได้:

* [`bytes`][Numeric#bytes]
* [`kilobytes`][Numeric#kilobytes]
* [`megabytes`][Numeric#megabytes]
* [`gigabytes`][Numeric#gigabytes]
* [`terabytes`][Numeric#terabytes]
* [`petabytes`][Numeric#petabytes]
* [`exabytes`][Numeric#exabytes]

เมธอดเหล่านี้จะส่งคืนจำนวนไบต์ที่เกี่ยวข้องโดยใช้อัตราการแปลงเป็น 1024:

```ruby
2.kilobytes   # => 2048
3.megabytes   # => 3145728
3.5.gigabytes # => 3758096384.0
-4.exabytes   # => -4611686018427387904
```

รูปพจน์เอกพจน์ถูกตั้งชื่อใหม่เพื่อให้คุณสามารถใช้ได้เช่น:

```ruby
1.megabyte # => 1048576
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/numeric/bytes.rb`.


### เวลา

เมธอดต่อไปนี้:

* [`seconds`][Numeric#seconds]
* [`minutes`][Numeric#minutes]
* [`hours`][Numeric#hours]
* [`days`][Numeric#days]
* [`weeks`][Numeric#weeks]
* [`fortnights`][Numeric#fortnights]

ช่วยให้คุณประกาศและคำนวณเวลา เช่น `45.minutes + 2.hours + 4.weeks` ค่าที่ส่งคืนยังสามารถเพิ่มหรือลบจากวัตถุเวลาได้

เมธอดเหล่านี้สามารถผสมกับ [`from_now`][Duration#from_now], [`ago`][Duration#ago], เป็นต้น เพื่อคำนวณวันที่อย่างแม่นยำ เช่น:

```ruby
# เทียบเท่ากับ Time.current.advance(days: 1)
1.day.from_now

# เทียบเท่ากับ Time.current.advance(weeks: 2)
2.weeks.from_now

# เทียบเท่ากับ Time.current.advance(days: 4, weeks: 5)
(4.days + 5.weeks).from_now
```

คำเตือน: สำหรับระยะเวลาอื่น ๆ โปรดอ้างอิงส่วนขยายเวลาให้กับ `Integer`.

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/numeric/time.rb`.


### การจัดรูปแบบ

ช่วยให้คุณจัดรูปแบบตัวเลขในหลายรูปแบบ

สร้างสตริงที่แสดงตัวเลขเป็นหมายเลขโทรศัพท์:

```ruby
5551234.to_fs(:phone)
# => 555-1234
1235551234.to_fs(:phone)
# => 123-555-1234
1235551234.to_fs(:phone, area_code: true)
# => (123) 555-1234
1235551234.to_fs(:phone, delimiter: " ")
# => 123 555 1234
1235551234.to_fs(:phone, area_code: true, extension: 555)
# => (123) 555-1234 x 555
1235551234.to_fs(:phone, country_code: 1)
# => +1-123-555-1234
```

สร้างสตริงที่แสดงตัวเลขเป็นสกุลเงิน:

```ruby
1234567890.50.to_fs(:currency)                 # => $1,234,567,890.50
1234567890.506.to_fs(:currency)                # => $1,234,567,890.51
1234567890.506.to_fs(:currency, precision: 3)  # => $1,234,567,890.506
```
สร้างสตริงที่แสดงตัวเลขเป็นเปอร์เซ็นต์:

```ruby
100.to_fs(:percentage)
# => 100.000%
100.to_fs(:percentage, precision: 0)
# => 100%
1000.to_fs(:percentage, delimiter: '.', separator: ',')
# => 1.000,000%
302.24398923423.to_fs(:percentage, precision: 5)
# => 302.24399%
```

สร้างสตริงที่แสดงตัวเลขในรูปแบบที่มีตัวคั่น:

```ruby
12345678.to_fs(:delimited)                     # => 12,345,678
12345678.05.to_fs(:delimited)                  # => 12,345,678.05
12345678.to_fs(:delimited, delimiter: ".")     # => 12.345.678
12345678.to_fs(:delimited, delimiter: ",")     # => 12,345,678
12345678.05.to_fs(:delimited, separator: " ")  # => 12,345,678 05
```

สร้างสตริงที่แสดงตัวเลขที่ถูกปัดเศษ:

```ruby
111.2345.to_fs(:rounded)                     # => 111.235
111.2345.to_fs(:rounded, precision: 2)       # => 111.23
13.to_fs(:rounded, precision: 5)             # => 13.00000
389.32314.to_fs(:rounded, precision: 0)      # => 389
111.2345.to_fs(:rounded, significant: true)  # => 111
```

สร้างสตริงที่แสดงตัวเลขในรูปแบบขนานกับขนาดไบต์:

```ruby
123.to_fs(:human_size)                  # => 123 Bytes
1234.to_fs(:human_size)                 # => 1.21 KB
12345.to_fs(:human_size)                # => 12.1 KB
1234567.to_fs(:human_size)              # => 1.18 MB
1234567890.to_fs(:human_size)           # => 1.15 GB
1234567890123.to_fs(:human_size)        # => 1.12 TB
1234567890123456.to_fs(:human_size)     # => 1.1 PB
1234567890123456789.to_fs(:human_size)  # => 1.07 EB
```

สร้างสตริงที่แสดงตัวเลขในรูปแบบข้อความที่อ่านง่าย:

```ruby
123.to_fs(:human)               # => "123"
1234.to_fs(:human)              # => "1.23 Thousand"
12345.to_fs(:human)             # => "12.3 Thousand"
1234567.to_fs(:human)           # => "1.23 Million"
1234567890.to_fs(:human)        # => "1.23 Billion"
1234567890123.to_fs(:human)     # => "1.23 Trillion"
1234567890123456.to_fs(:human)  # => "1.23 Quadrillion"
```

หมายเหตุ: นิยามใน `active_support/core_ext/numeric/conversions.rb`.

ส่วนขยายให้กับ `Integer`
-----------------------

### `multiple_of?`

เมธอด [`multiple_of?`][Integer#multiple_of?] ทดสอบว่าจำนวนเต็มเป็นเท่ากับอาร์กิวเมนต์หรือไม่:

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

หมายเหตุ: นิยามใน `active_support/core_ext/integer/multiple.rb`.


### `ordinal`

เมธอด [`ordinal`][Integer#ordinal] คืนคำต่อท้ายที่เป็นลำดับของจำนวนเต็ม:

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

หมายเหตุ: นิยามใน `active_support/core_ext/integer/inflections.rb`.


### `ordinalize`

เมธอด [`ordinalize`][Integer#ordinalize] คืนคำที่เป็นลำดับของจำนวนเต็ม ในการเปรียบเทียบ โปรดทราบว่าเมธอด `ordinal` คืนค่าเฉพาะสตริงต่อท้ายเท่านั้น.

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

หมายเหตุ: นิยามใน `active_support/core_ext/integer/inflections.rb`.


### Time

เมธอดต่อไปนี้:

* [`months`][Integer#months]
* [`years`][Integer#years]

ช่วยให้สามารถประกาศและคำนวณเวลา เช่น `4.months + 5.years` ค่าที่คืนค่าสามารถเพิ่มหรือลบจากออบเจ็กต์เวลาได้เช่นกัน.

เมธอดเหล่านี้สามารถใช้ร่วมกับ [`from_now`][Duration#from_now], [`ago`][Duration#ago], เป็นต้น เพื่อคำนวณวันที่อย่างแม่นยำ เช่น:

```ruby
# เทียบเท่ากับ Time.current.advance(months: 1)
1.month.from_now

# เทียบเท่ากับ Time.current.advance(years: 2)
2.years.from_now

# เทียบเท่ากับ Time.current.advance(months: 4, years: 5)
(4.months + 5.years).from_now
```

คำเตือน: สำหรับระยะเวลาอื่นๆ โปรดอ้างอิงส่วนขยายเวลาไปยัง `Numeric`.

หมายเหตุ: นิยามใน `active_support/core_ext/integer/time.rb`.


ส่วนขยายให้กับ `BigDecimal`
--------------------------

### `to_s`

เมธอด `to_s` ให้ตัวกำหนดเริ่มต้นเป็น "F" ซึ่งหมายความว่าการเรียกใช้งาน `to_s` จะได้ผลลัพธ์เป็นตัวเลขทศนิยมแทนการแสดงเลขวิศวกรรม:

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

การแสดงเลขวิศวกรรมยังคงรองรับ:

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

ส่วนขยายให้กับ `Enumerable`
--------------------------

### `sum`

เมธอด [`sum`][Enumerable#sum] บวกสมาชิกของอินเทอร์เอเบิล:
```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

การบวกเพิ่มเติมเฉพาะสมาชิกที่ตอบสนองกับ `+`:

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{ a: 1, b: 2, c: 3 }.sum          # => [:a, 1, :b, 2, :c, 3]
```

ผลรวมของคอลเลกชันที่ว่างเปล่าเป็นศูนย์ตามค่าเริ่มต้น แต่สามารถกำหนดค่าเริ่มต้นได้:

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

หากมีบล็อกที่กำหนดให้ `sum` เป็นตัววนซ้ำที่ส่งคืนค่าของสมาชิกในคอลเลกชันและรวมผลลัพธ์ที่ส่งกลับ:

```ruby
(1..5).sum { |n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

ผลรวมของตัวรับที่ว่างเปล่าสามารถกำหนดเองได้ในรูปแบบนี้เช่นกัน:

```ruby
[].sum(1) { |n| n**3 } # => 1
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/enumerable.rb`.


### `index_by`

เมธอด [`index_by`][Enumerable#index_by] สร้างแฮชที่มีสมาชิกของคอลเลกชันที่มีดัชนีโดยใช้คีย์ที่กำหนด

มันวนซ้ำผ่านคอลเลกชันและส่งผ่านแต่ละสมาชิกให้กับบล็อก สมาชิกจะถูกจัดกุญแจโดยค่าที่ส่งกลับจากบล็อก:

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

คำเตือน คีย์ควรเป็นค่าที่ไม่ซ้ำกันตามปกติ หากบล็อกส่งค่าเดียวกันสำหรับสมาชิกที่แตกต่างกัน จะไม่สร้างคอลเลกชันสำหรับคีย์นั้น รายการสุดท้ายจะชนะ

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/enumerable.rb`.


### `index_with`

เมธอด [`index_with`][Enumerable#index_with] สร้างแฮชที่มีสมาชิกของคอลเลกชันเป็นคีย์ ค่า
เป็นค่าเริ่มต้นที่ผ่านหรือส่งกลับในบล็อก

```ruby
post = Post.new(title: "hey there", body: "what's up?")

%i( title body ).index_with { |attr_name| post.public_send(attr_name) }
# => { title: "hey there", body: "what's up?" }

WEEKDAYS.index_with(Interval.all_day)
# => { monday: [ 0, 1440 ], … }
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/enumerable.rb`.


### `many?`

เมธอด [`many?`][Enumerable#many?] เป็นตัวย่อสำหรับ `collection.size > 1`:

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

หากมีบล็อกที่กำหนดเพิ่มเติม `many?` จะพิจารณาเฉพาะสมาชิกที่ส่งคืนค่าเป็นจริง:

```ruby
@see_more = videos.many? { |video| video.category == params[:category] }
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/enumerable.rb`.


### `exclude?`

พรีดิเคต [`exclude?`][Enumerable#exclude?] ทดสอบว่าวัตถุที่กำหนดไม่เป็นส่วนหนึ่งของคอลเลกชัน นี่คือการปฏิเสธของ `include?` ที่มีอยู่:

```ruby
to_visit << node if visited.exclude?(node)
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/enumerable.rb`.


### `including`

เมธอด [`including`][Enumerable#including] ส่งคืนคอลเลกชันใหม่ที่รวมสมาชิกที่ผ่านมา:

```ruby
[ 1, 2, 3 ].including(4, 5)                    # => [ 1, 2, 3, 4, 5 ]
["David", "Rafael"].including %w[ Aaron Todd ] # => ["David", "Rafael", "Aaron", "Todd"]
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/enumerable.rb`.


### `excluding`

เมธอด [`excluding`][Enumerable#excluding] ส่งคืนสำเนาของคอลเลกชันที่กำหนดสมาชิกที่ระบุ
ถูกลบออก:

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
```

`excluding` เป็นนามแฝงของ [`without`][Enumerable#without].

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/enumerable.rb`.


### `pluck`

เมธอด [`pluck`][Enumerable#pluck] แยกคีย์ที่กำหนดจากแต่ละสมาชิก:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pluck(:id, :name) # => [[1, "David"], [2, "Rafael"]]
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/enumerable.rb`


### `pick`

เมธอด [`pick`][Enumerable#pick] สกัดคีย์ที่กำหนดมาจากองค์ประกอบแรก:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pick(:name) # => "David"
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pick(:id, :name) # => [1, "David"]
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/enumerable.rb`


ส่วนขยายของ `Array`
---------------------

### การเข้าถึง

Active Support ขยาย API ของอาร์เรย์เพื่อสะดวกในการเข้าถึงบางวิธี ตัวอย่างเช่น [`to`][Array#to] จะคืนค่าอาร์เรย์ย่อยขององค์ประกอบจนถึงองค์ประกอบที่มีดัชนีที่ระบุ:

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

อย่างเดียวกัน [`from`][Array#from] จะคืนค่าส่วนท้ายของอาร์เรย์ตั้งแต่องค์ประกอบที่มีดัชนีที่ระบุไปจนถึงสุดท้าย หากดัชนีมากกว่าความยาวของอาร์เรย์ จะคืนค่าอาร์เรย์ว่าง

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

เมธอด [`including`][Array#including] จะคืนค่าอาร์เรย์ใหม่ที่รวมองค์ประกอบที่ระบุ:

```ruby
[ 1, 2, 3 ].including(4, 5)          # => [ 1, 2, 3, 4, 5 ]
[ [ 0, 1 ] ].including([ [ 1, 0 ] ]) # => [ [ 0, 1 ], [ 1, 0 ] ]
```

เมธอด [`excluding`][Array#excluding] จะคืนค่าสำเนาของอาร์เรย์โดยไม่รวมองค์ประกอบที่ระบุ นี่เป็นการปรับปรุงของ `Enumerable#excluding` ที่ใช้ `Array#-` แทน `Array#reject` เพื่อเพิ่มประสิทธิภาพ

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
[ [ 0, 1 ], [ 1, 0 ] ].excluding([ [ 1, 0 ] ])                  # => [ [ 0, 1 ] ]
```

เมธอด [`second`][Array#second], [`third`][Array#third], [`fourth`][Array#fourth], และ [`fifth`][Array#fifth] จะคืนค่าองค์ประกอบที่สอง, ที่สาม, ที่สี่, และที่ห้าตามลำดับ องค์ประกอบที่สองจากท้ายและองค์ประกอบที่สามจากท้ายก็คืนค่าเช่นกัน (`first` และ `last` เป็นฟังก์ชันที่มีอยู่แล้ว) ด้วยความรู้สึกทางสังคมและการสร้างสรรค์ที่เชิดชูกันทั่วไป จึงมี [`forty_two`][Array#forty_two] ให้ใช้งานเช่นกัน

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/array/access.rb`


### การสกัด

เมธอด [`extract!`][Array#extract!] จะลบและคืนค่าองค์ประกอบที่ฟังก์ชันคืนค่าเป็นจริง หากไม่มีฟังก์ชันคืนค่า จะคืนค่า Enumerator แทน

```ruby
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
numbers # => [0, 2, 4, 6, 8]
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/array/extract.rb`


### การสกัดตัวเลือก

เมื่ออาร์กิวเมนต์สุดท้ายในการเรียกเมธอดเป็นแฮช เว้นแต่จะมีอาร์กิวเมนต์ `&block`  Ruby อนุญาตให้คุณละเว้นวงเล็บได้:

```ruby
User.exists?(email: params[:email])
```

การใช้ไวยากรณ์นี้มีความสะดวกมากใน Rails เพื่อหลีกเลี่ยงอาร์กิวเมนต์ตำแหน่งที่มีจำนวนมาก และให้แทนที่ด้วยอินเทอร์เฟซที่จำลองพารามิเตอร์ที่มีชื่อ โดยเฉพาะอย่างยิ่งการใช้แฮชที่ตามมา

หากเมธอดคาดหวังอาร์กิวเมนต์จำนวนตัวแปรและใช้ `*` ในการประกาศ แต่แฮชตัวเลือกนั้นจะเป็นส่วนหนึ่งของอาร์เรย์ของอาร์กิวเมนต์ แล้วแฮชตัวเลือกจะสูญเสียบทบาทของตน

ในกรณีเช่นนั้น คุณสามารถให้แฮชตัวเลือกได้รับการจัดการที่แตกต่างด้วย [`extract_options!`][Array#extract_options!] เมธอดนี้จะตรวจสอบประเภทของรายการสุดท้ายในอาร์เรย์ หากเป็นแฮชจะดึงออกและคืนค่า มิฉะนั้นจะคืนค่าแฮชว่าง


เรามาดูตัวอย่างการกำหนด `caches_action` controller macro:

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  # ...
end
```

เมธอดนี้รับชื่อแอ็กชันได้เป็นจำนวนไม่จำกัด และมีตัวเลือกแบบแฮชเป็นอาร์กิวเมนต์สุดท้าย ด้วยการเรียกใช้ `extract_options!` คุณจะได้รับแบบแฮชตัวเลือกและลบออกจาก `actions` อย่างง่ายและชัดเจน

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/array/extract_options.rb`.


### การแปลง

#### `to_sentence`

เมธอด [`to_sentence`][Array#to_sentence] แปลงอาร์เรย์ให้เป็นสตริงที่ประกอบด้วยประโยคที่ระบุรายการ:

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

เมธอดนี้รับตัวเลือกสามตัว:

* `:two_words_connector`: ใช้อะไรสำหรับอาร์เรย์ที่มีความยาว 2 ค่า ค่าเริ่มต้นคือ " and "
* `:words_connector`: ใช้เชื่อมต่อองค์ประกอบของอาร์เรย์ที่มี 3 หรือมากกว่า ค่าเริ่มต้นคือ ", "
* `:last_word_connector`: ใช้เชื่อมต่อรายการสุดท้ายของอาร์เรย์ที่มี 3 หรือมากกว่า ค่าเริ่มต้นคือ ", and "

ค่าเริ่มต้นสำหรับตัวเลือกเหล่านี้สามารถแปลงเป็นภาษาท้องถิ่นได้ โดยใช้คีย์ต่างๆ ดังนี้:

| ตัวเลือก                 | คีย์ I18n                            |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/array/conversions.rb`.


#### `to_fs`

เมธอด [`to_fs`][Array#to_fs] ทำงานเหมือน `to_s` เป็นค่าเริ่มต้น

แต่ถ้าอาร์เรย์มีรายการที่ตอบสนองต่อ `id` สัญลักษณ์ `:db` สามารถถูกส่งเป็นอาร์กิวเมนต์ได้ ซึ่งใช้งานได้โดยปกติกับคอลเลกชันของออบเจกต์ Active Record สตริงที่คืนค่าคือ:

```ruby
[].to_fs(:db)            # => "null"
[user].to_fs(:db)        # => "8456"
invoice.lines.to_fs(:db) # => "23,567,556,12"
```

จำนวนเต็มในตัวอย่างข้างต้นควรมาจากการเรียก `id` ที่เกี่ยวข้อง

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/array/conversions.rb`.


#### `to_xml`

เมธอด [`to_xml`][Array#to_xml] คืนค่าสตริงที่ประกอบด้วยรายการ XML ของอ็อบเจกต์ที่รับเป็นอาร์กิวเมนต์:

```ruby
Contributor.limit(2).order(:rank).to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors type="array">
#   <contributor>
#     <id type="integer">4356</id>
#     <name>Jeremy Kemper</name>
#     <rank type="integer">1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id type="integer">4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank type="integer">2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

เพื่อทำเช่นนี้ มันจะส่ง `to_xml` ไปยังทุกออบเจกต์ตามลำดับ และรวบรวมผลลัพธ์ภายใต้โหนดราก รายการทั้งหมดต้องตอบสนองต่อ `to_xml` มิฉะนั้นจะเกิดข้อยกเว้น

ตามค่าเริ่มต้น ชื่อขององค์ประกอบรากคือชื่อคลาสของรายการแรกที่มีเส้นใต้และเครื่องหมายขีดกลาง หากส่วนที่เหลือขององค์ประกอบเป็นชนิดเดียวกัน (ตรวจสอบด้วย `is_a?`) และไม่ใช่แฮช ในตัวอย่างข้างต้นคือ "contributors"

หากมีองค์ประกอบใดๆ ที่ไม่เป็นชนิดขององค์ประกอบแรก โหนดรากก็จะกลายเป็น "objects":

```ruby
[Contributor.first, Commit.first].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <id type="integer">4583</id>
#     <name>Aaron Batalion</name>
#     <rank type="integer">53</rank>
#     <url-id>aaron-batalion</url-id>
#   </object>
#   <object>
#     <author>Joshua Peek</author>
#     <authored-timestamp type="datetime">2009-09-02T16:44:36Z</authored-timestamp>
#     <branch>origin/master</branch>
#     <committed-timestamp type="datetime">2009-09-02T16:44:36Z</committed-timestamp>
#     <committer>Joshua Peek</committer>
#     <git-show nil="true"></git-show>
#     <id type="integer">190316</id>
#     <imported-from-svn type="boolean">false</imported-from-svn>
#     <message>Kill AMo observing wrap_with_notifications since ARes was only using it</message>
#     <sha1>723a47bfb3708f968821bc969a9a3fc873a3ed58</sha1>
#   </object>
# </objects>
```
หากผู้รับเป็นอาร์เรย์ของแฮช องค์ประกอบรากจะเป็น "ออบเจ็กต์" โดยค่าเริ่มต้น:

```ruby
[{ a: 1, b: 2 }, { c: 3 }].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <b type="integer">2</b>
#     <a type="integer">1</a>
#   </object>
#   <object>
#     <c type="integer">3</c>
#   </object>
# </objects>
```

คำเตือน. หากคอลเลกชันเป็นว่างเปล่า องค์ประกอบรากจะเป็น "nil-classes" โดยค่าเริ่มต้น นั่นคือสิ่งที่คุณต้องระวัง เช่น องค์ประกอบรากของรายการผู้มีส่วนร่วมด้านบนจะไม่ใช่ "ผู้มีส่วนร่วม" หากคอลเลกชันเป็นว่างเปล่า แต่เป็น "nil-classes" คุณสามารถใช้ตัวเลือก `:root` เพื่อให้มีองค์ประกอบรากที่สม่ำเสมอ

ชื่อของโหนดลูกๆ คือชื่อของโหนดรากที่ถูกกำหนดให้เป็นรูปพจนานุกรม ในตัวอย่างด้านบนเราเห็น "ผู้มีส่วนร่วม" และ "ออบเจ็กต์" ตัวเลือก `:children` ช่วยให้คุณตั้งชื่อโหนดเหล่านี้

XML builder เริ่มต้นค่าเป็นตัวอย่างใหม่ของ `Builder::XmlMarkup` คุณสามารถกำหนดค่า builder เองผ่านตัวเลือก `:builder` วิธีนี้ยังรองรับตัวเลือกอื่น ๆ เช่น `:dasherize` และอื่น ๆ ซึ่งถูกส่งต่อไปยัง builder:

```ruby
Contributor.limit(2).order(:rank).to_xml(skip_types: true)
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors>
#   <contributor>
#     <id>4356</id>
#     <name>Jeremy Kemper</name>
#     <rank>1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id>4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank>2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/array/conversions.rb`.


### การห่อหุ้ม

เมธอด [`Array.wrap`][Array.wrap] ห่อหุ้มอาร์กิวเมนต์ของมันในอาร์เรย์ ยกเว้นถ้ามันเป็นอาร์เรย์ (หรืออาร์เรย์เหมือน)

โดยเฉพาะอย่างยิ่ง:

* หากอาร์กิวเมนต์เป็น `nil` จะคืนอาร์เรย์ว่างเปล่า
* มิฉะนั้น หากอาร์กิวเมนต์ตอบสนองกับ `to_ary` จะเรียกใช้ และหากค่าของ `to_ary` ไม่ใช่ `nil` จะคืนค่านั้น
* มิฉะนั้น จะคืนอาร์เรย์ที่มีอาร์กิวเมนต์เป็นสมาชิกเดียว

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

เมธอดนี้คล้ายกับ `Kernel#Array` แต่มีความแตกต่างบางอย่าง:

* หากอาร์กิวเมนต์ตอบสนองกับ `to_ary` จะเรียกใช้เมธอด แต่ `Kernel#Array` จะลองเรียกใช้ `to_a` หากค่าที่คืนมาเป็น `nil` แต่ `Array.wrap` จะคืนอาร์เรย์ที่มีอาร์กิวเมนต์เป็นสมาชิกเดียวทันที
* หากค่าที่คืนมาจาก `to_ary` ไม่ใช่ `nil` หรือออบเจ็กต์ของอาร์เรย์ `Kernel#Array` จะเรียกใช้ raise exception ในขณะที่ `Array.wrap` ไม่ได้ทำเช่นนั้น มันแค่คืนค่า
* มันไม่เรียกใช้ `to_a` กับอาร์กิวเมนต์ หากอาร์กิวเมนต์ไม่ตอบสนองกับ `to_ary` มันจะคืนอาร์เรย์ที่มีอาร์กิวเมนต์เป็นสมาชิกเดียว

จุดสุดท้ายนี้เป็นสิ่งที่ควรเปรียบเทียบกับบางอย่างใน enumerables บางอย่าง:

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

ยังมีรูปแบบที่เกี่ยวข้องที่ใช้ตัวดอกจัน:

```ruby
[*object]
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/array/wrap.rb`.


### การทำซ้ำ

เมธอด [`Array#deep_dup`][Array#deep_dup] ทำซ้ำตัวเองและวัตถุทั้งหมดภายใน
โดยใช้เมธอด `Object#deep_dup` ใน Active Support มันทำงานเหมือนกับ `Array#map` โดยส่งเมธอด `deep_dup` ไปยังแต่ละวัตถุภายใน

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/object/deep_dup.rb`
### การจัดกลุ่ม

#### `in_groups_of(number, fill_with = nil)`

เมธอด [`in_groups_of`][Array#in_groups_of] แบ่งอาร์เรย์เป็นกลุ่มติดต่อกันของขนาดที่กำหนด และคืนค่าอาร์เรย์ที่มีกลุ่ม:

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

หรือส่งค่าต่อไปในลำดับถ้ามีบล็อกที่ถูกส่ง:

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

ตัวอย่างแรกแสดงวิธี `in_groups_of` เติมกลุ่มสุดท้ายด้วยสมาชิก `nil` ตามที่ต้องการ คุณสามารถเปลี่ยนค่าเติมนี้ได้โดยใช้อาร์กิวเมนต์ที่สอง:

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

และคุณสามารถบอกเมธอดให้ไม่เติมกลุ่มสุดท้ายโดยส่ง `false`:

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

เนื่องจากนั้น `false` ไม่สามารถใช้เป็นค่าเติมได้

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/array/grouping.rb`.


#### `in_groups(number, fill_with = nil)`

เมธอด [`in_groups`][Array#in_groups] แบ่งอาร์เรย์เป็นจำนวนกลุ่มที่กำหนด และคืนค่าอาร์เรย์ที่มีกลุ่ม:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

หรือส่งค่าต่อไปในลำดับถ้ามีบล็อกที่ถูกส่ง:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) { |group| p group }
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

ตัวอย่างข้างต้นแสดงว่า `in_groups` เติมกลุ่มบางกลุ่มด้วยสมาชิก `nil` ตามที่ต้องการ กลุ่มสามารถได้รับสมาชิกเพิ่มเติมได้สูงสุดหนึ่งตัว ตัวที่อยู่ทางขวาสุดถ้ามี และกลุ่มที่มีสมาชิกเพิ่มเติมเป็นกลุ่มสุดท้ายเสมอ

คุณสามารถเปลี่ยนค่าเติมนี้ได้โดยใช้อาร์กิวเมนต์ที่สอง:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

และคุณสามารถบอกเมธอดให้ไม่เติมกลุ่มที่เล็กกว่าโดยส่ง `false`:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

เนื่องจากนั้น `false` ไม่สามารถใช้เป็นค่าเติมได้

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/array/grouping.rb`.


#### `split(value = nil)`

เมธอด [`split`][Array#split] แบ่งอาร์เรย์ด้วยตัวคั่นและคืนค่าชิ้นส่วนที่ได้

ถ้าส่งบล็อกไป ตัวคั่นคือสมาชิกของอาร์เรย์ที่บล็อกส่งคืนค่า true:

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

มิฉะนั้น ค่าที่ได้รับเป็นอาร์กิวเมนต์ ซึ่งมีค่าเริ่มต้นเป็น `nil`, เป็นตัวคั่น:

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

เคล็ดลับ: สังเกตในตัวอย่างก่อนหน้านี้ว่าตัวคั่นต่อเนื่องจะทำให้ได้อาร์เรย์เปล่า

หมายเหตุ: ถูกกำหนดใน `active_support/core_ext/array/grouping.rb`.


ส่วนขยายให้กับ `Hash`
--------------------

### การแปลง

#### `to_xml`

เมธอด [`to_xml`][Hash#to_xml] คืนค่าสตริงที่มีการแสดงผล XML ของวัตถุที่ได้รับ:

```ruby
{ foo: 1, bar: 2 }.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```
เพื่อทำเช่นนั้น วิธีการจะวนลูปผ่านคู่และสร้างโหนดที่ขึ้นอยู่กับ _values_ ที่กำหนด โดยให้คู่ `key`, `value`:

* หาก `value` เป็นแฮช จะมีการเรียกใช้งานแบบเรียกตัวเองกับ `key` เป็น `:root` ในลูปซ้ำ

* หาก `value` เป็นอาร์เรย์ จะมีการเรียกใช้งานแบบเรียกตัวเองกับ `key` เป็น `:root` และ `key` ที่ถูกแยกเป็นรูปเดี่ยวเป็น `:children` ในลูปซ้ำ

* หาก `value` เป็นวัตถุที่เรียกใช้งานได้ จะต้องคาดหวังอาร์กิวเมนต์หนึ่งหรือสองตัว ขึ้นอยู่กับความยาวของอาร์กิวเมนต์ วิธีการเรียกใช้งานคือเรียกใช้งานวัตถุที่เรียกใช้งานได้ด้วยแฮช `options` เป็นอาร์กิวเมนต์แรกด้วย `key` เป็น `:root` และ `key` ที่ถูกแยกเป็นรูปเดี่ยวเป็นอาร์กิวเมนต์ที่สอง ค่าที่ส่งกลับจะกลายเป็นโหนดใหม่

* หาก `value` ตอบสนองกับ `to_xml` วิธีการจะเรียกใช้งานคือเรียกใช้งานวิธีด้วย `key` เป็น `:root`

* มิฉะนั้น จะสร้างโหนดด้วย `key` เป็นแท็กพร้อมกับการแสดงตัวอย่างของ `value` เป็นโหนดข้อความ หาก `value` เป็น `nil` จะเพิ่มแอตทริบิวต์ "nil" ที่ตั้งค่าเป็น "true" นอกจากนั้น หากตัวเลือก `:skip_types` มีอยู่และเป็นจริง จะเพิ่มแอตทริบิวต์ "type" ตามการแมปต่อไปนี้:

```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "symbol",
  "Integer"    => "integer",
  "BigDecimal" => "decimal",
  "Float"      => "float",
  "TrueClass"  => "boolean",
  "FalseClass" => "boolean",
  "Date"       => "date",
  "DateTime"   => "datetime",
  "Time"       => "datetime"
}
```

โดยค่าเริ่มต้นของโหนดรูทคือ "hash" แต่สามารถกำหนดค่าได้ผ่านตัวเลือก `:root`

XML builder เริ่มต้นคือตัวอย่างใหม่ของ `Builder::XmlMarkup` คุณสามารถกำหนดค่า builder เองได้ด้วยตัวเลือก `:builder` วิธีการยังยอมรับตัวเลือกเช่น `:dasherize` และเพื่อนๆ ซึ่งจะถูกส่งต่อไปยัง builder

หมายเหตุ: ได้กำหนดไว้ใน `active_support/core_ext/hash/conversions.rb`


### การผสาน

Ruby มีเมธอด `Hash#merge` ที่ผสานสองแฮชอย่างมีอยู่แล้ว:

```ruby
{ a: 1, b: 1 }.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support กำหนดวิธีการผสานแฮชเพิ่มเติมที่อาจจะสะดวก

#### `reverse_merge` และ `reverse_merge!`

ในกรณีที่มีการชนกัน คีย์ในแฮชของอาร์กิวเมนต์จะชนะในการผสาน คุณสามารถรองรับแฮชตัวเลือกที่มีค่าเริ่มต้นได้อย่างสะดวกด้วยวิธีนี้:

```ruby
options = { length: 30, omission: "..." }.merge(options)
```

Active Support กำหนด [`reverse_merge`][Hash#reverse_merge] ในกรณีที่คุณชอบรูปแบบทางเลือกที่แตกต่างนี้:

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

และเวอร์ชันแบบแบง [`reverse_merge!`][Hash#reverse_merge!] ที่ดำเนินการผสานในที่เดียว:

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

คำเตือน. โปรดทราบว่า `reverse_merge!` อาจเปลี่ยนแปลงแฮชในตัวเรียก ซึ่งอาจเป็นได้หรือไม่เป็นได้ตามที่ต้องการ

หมายเหตุ: ได้กำหนดไว้ใน `active_support/core_ext/hash/reverse_merge.rb`


#### `reverse_update`

เมธอด [`reverse_update`][Hash#reverse_update] เป็นชื่อย่อสำหรับ `reverse_merge!` ที่อธิบายไว้ข้างต้น

คำเตือน. โปรดทราบว่า `reverse_update` ไม่มีเครื่องหมายแบง

หมายเหตุ: ได้กำหนดไว้ใน `active_support/core_ext/hash/reverse_merge.rb`


#### `deep_merge` และ `deep_merge!`

ตามที่คุณเห็นในตัวอย่างก่อนหน้านี้ หากพบคีย์ในทั้งสองแฮช ค่าในแอร์กิวเมนต์จะชนะ

Active Support กำหนด [`Hash#deep_merge`][Hash#deep_merge] ในการผสานลึก หากพบคีย์ในทั้งสองแฮชและค่าของพวกเขาเป็นแฮชต่อไป ค่าผสานของพวกเขาจะกลายเป็นค่าในแฮชที่ได้:

```ruby
{ a: { b: 1 } }.deep_merge(a: { c: 2 })
# => {:a=>{:b=>1, :c=>2}}
```
เมธอด [`deep_merge!`][Hash#deep_merge!] ทำการผสานรวมค่าในแบบลึกในตำแหน่งเดิม

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/hash/deep_merge.rb`


### การทำสำเนาแบบลึก

เมธอด [`Hash#deep_dup`][Hash#deep_dup] ทำการทำสำเนาของตัวเองและคีย์และค่าทั้งหมดภายในโดยใช้เมธอด `Object#deep_dup` ใน Active Support มันทำงานเหมือน `Enumerator#each_with_object` โดยส่งเมธอด `deep_dup` ไปยังคู่แต่ละคู่ภายใน

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/object/deep_dup.rb`


### การทำงานกับคีย์

#### `except` และ `except!`

เมธอด [`except`][Hash#except] คืนค่าเป็นแฮชที่มีคีย์ในรายการอาร์กิวเมนต์ถูกลบออกหากมีอยู่:

```ruby
{ a: 1, b: 2 }.except(:a) # => {:b=>2}
```

หากผู้รับตอบสนองกับ `convert_key` เมธอดจะถูกเรียกใช้กับแต่ละอาร์กิวเมนต์ ซึ่งทำให้ `except` สามารถทำงานร่วมกับแฮชที่มีการเข้าถึงได้โดยไม่สนใจตัวอักษรตัวพิมพ์ใหญ่หรือเล็ก เช่น:

```ruby
{ a: 1 }.with_indifferent_access.except(:a)  # => {}
{ a: 1 }.with_indifferent_access.except("a") # => {}
```

ยังมีรูปแบบแบง [`except!`][Hash#except!] ที่ลบคีย์ในตำแหน่งเดิม

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/hash/except.rb`


#### `stringify_keys` และ `stringify_keys!`

เมธอด [`stringify_keys`][Hash#stringify_keys] คืนค่าเป็นแฮชที่มีรุ่นที่ถูกแปลงเป็นสตริงของคีย์ในแฮชต้นฉบับ โดยส่ง `to_s` ไปยังคีย์:

```ruby
{ nil => nil, 1 => 1, a: :a }.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

ในกรณีที่มีการชนกันของคีย์ ค่าจะเป็นค่าที่ถูกแทรกล่าสุดในแฮช:

```ruby
{ "a" => 1, a: 2 }.stringify_keys
# ผลลัพธ์จะเป็น
# => {"a"=>2}
```

เมธอดนี้อาจมีประโยชน์ตัวอย่างเช่นในการยอมรับตัวเลือกทั้งสัญลักษณ์และสตริงได้อย่างง่ายดาย เช่น `ActionView::Helpers::FormHelper` กำหนด:

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  # ...
end
```

บรรทัดที่สองสามารถเข้าถึงคีย์ "type" ได้อย่างปลอดภัย และให้ผู้ใช้สามารถส่ง `:type` หรือ "type" ได้

ยังมีรูปแบบแบง [`stringify_keys!`][Hash#stringify_keys!] ที่แปลงคีย์เป็นสตริงในตำแหน่งเดิม

นอกจากนี้ยังสามารถใช้ [`deep_stringify_keys`][Hash#deep_stringify_keys] และ [`deep_stringify_keys!`][Hash#deep_stringify_keys!] เพื่อแปลงเป็นสตริงทั้งหมดในแฮชที่กำหนดและแฮชที่ซ้อนอยู่ภายใน ตัวอย่างผลลัพธ์คือ:

```ruby
{ nil => nil, 1 => 1, nested: { a: 3, 5 => 5 } }.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

หมายเหตุ: ถูกกำหนดไว้ใน `active_support/core_ext/hash/keys.rb`


#### `symbolize_keys` และ `symbolize_keys!`

เมธอด [`symbolize_keys`][Hash#symbolize_keys] คืนค่าเป็นแฮชที่มีรุ่นที่ถูกแปลงเป็นสัญลักษณ์ของคีย์ในแฮชต้นฉบับ โดยส่ง `to_sym` ไปยังคีย์:

```ruby
{ nil => nil, 1 => 1, "a" => "a" }.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

คำเตือน โปรดทราบในตัวอย่างก่อนหน้านี้มีเพียงคีย์เดียวที่ถูกแปลงเป็นสัญลักษณ์

ในกรณีที่มีการชนกันของคีย์ ค่าจะเป็นค่าที่ถูกแทรกล่าสุดในแฮช:

```ruby
{ "a" => 1, a: 2 }.symbolize_keys
# => {:a=>2}
```

เมธอดนี้อาจมีประโยชน์ตัวอย่างเช่นในการยอมรับตัวเลือกทั้งสัญลักษณ์และสตริงได้อย่างง่ายดาย เช่น `ActionText::TagHelper` กำหนด
```ruby
def rich_text_area_tag(name, value = nil, options = {})
  options = options.symbolize_keys

  options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
  # ...
end
```

บรรทัดที่สามสามารถเข้าถึงคีย์ `:input` ได้อย่างปลอดภัย และอนุญาตให้ผู้ใช้ส่ง `:input` หรือ "input" เข้ามาได้

ยังมีตัวแปรแบบ bang [`symbolize_keys!`][Hash#symbolize_keys!] ที่จะแปลงคีย์ให้เป็นสัญลักษณ์ในตำแหน่งเดียวกัน

นอกจากนี้ยังสามารถใช้ [`deep_symbolize_keys`][Hash#deep_symbolize_keys] และ [`deep_symbolize_keys!`][Hash#deep_symbolize_keys!] เพื่อแปลงคีย์ทั้งหมดในแฮชที่กำหนดและแฮชที่ซ้อนอยู่ในนั้นให้เป็นสัญลักษณ์ ตัวอย่างของผลลัพธ์คือ:

```ruby
{ nil => nil, 1 => 1, "nested" => { "a" => 3, 5 => 5 } }.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

หมายเหตุ: นิยามใน `active_support/core_ext/hash/keys.rb`


#### `to_options` และ `to_options!`

เมธอด [`to_options`][Hash#to_options] และ [`to_options!`][Hash#to_options!] เป็นตัวย่อของ `symbolize_keys` และ `symbolize_keys!` ตามลำดับ

หมายเหตุ: นิยามใน `active_support/core_ext/hash/keys.rb`


#### `assert_valid_keys`

เมธอด [`assert_valid_keys`][Hash#assert_valid_keys] รับอาร์กิวเมนต์จำนวนไม่จำกัด และตรวจสอบว่าแฮชที่รับมีคีย์นอกเหนือจากนั้นหรือไม่ ถ้ามีจะเกิด `ArgumentError`

```ruby
{ a: 1 }.assert_valid_keys(:a)  # ผ่าน
{ a: 1 }.assert_valid_keys("a") # ArgumentError
```

Active Record ไม่ยอมรับตัวเลือกที่ไม่รู้จักเมื่อสร้างความสัมพันธ์ เช่น มันนำมาใช้ควบคู่กับ `assert_valid_keys` เพื่อควบคุม

หมายเหตุ: นิยามใน `active_support/core_ext/hash/keys.rb`


### การทำงานกับค่า

#### `deep_transform_values` และ `deep_transform_values!`

เมธอด [`deep_transform_values`][Hash#deep_transform_values] จะคืนแฮชใหม่ที่มีค่าทั้งหมดถูกแปลงด้วยการดำเนินการบล็อก รวมถึงค่าจากแฮชรูทและแฮชซ้อนอยู่ภายใน

```ruby
hash = { person: { name: 'Rob', age: '28' } }

hash.deep_transform_values { |value| value.to_s.upcase }
# => {person: {name: "ROB", age: "28"}}
```

ยังมีตัวแปรแบบ bang [`deep_transform_values!`][Hash#deep_transform_values!] ที่แปลงค่าทั้งหมดโดยทำการใช้งานบล็อก

หมายเหตุ: นิยามใน `active_support/core_ext/hash/deep_transform_values.rb`


### การแบ่ง

เมธอด [`slice!`][Hash#slice!] จะแทนที่แฮชด้วยเฉพาะคีย์ที่กำหนดและคืนแฮชที่มีคีย์/ค่าที่ถูกลบ

```ruby
hash = { a: 1, b: 2 }
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

หมายเหตุ: นิยามใน `active_support/core_ext/hash/slice.rb`


### การแยก

เมธอด [`extract!`][Hash#extract!] จะลบและคืนคีย์/ค่าที่ตรงกับคีย์ที่กำหนด

```ruby
hash = { a: 1, b: 2 }
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

เมธอด `extract!` จะคืนคลาสแฮชเดียวกับแฮชต้นฉบับ

```ruby
hash = { a: 1, b: 2 }.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

หมายเหตุ: นิยามใน `active_support/core_ext/hash/slice.rb`


### การเข้าถึงโดยไม่สนใจตัวอักษรตัวพิมพ์ใหญ่หรือเล็ก

เมธอด [`with_indifferent_access`][Hash#with_indifferent_access] จะคืน [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] จากแฮชต้นฉบับ:

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

หมายเหตุ: นิยามใน `active_support/core_ext/hash/indifferent_access.rb`


ส่วนขยายให้กับ `Regexp`
----------------------

### `multiline?`

เมธอด [`multiline?`][Regexp#multiline?] บอกว่ารูปแบบเรกเอ็กซ์มีตัวสองเส้น `/m` ที่ตั้งไว้หรือไม่ กล่าวคือ ว่าจุดจับตรงกับบรรทัดใหม่หรือไม่

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails ใช้เมธอดนี้ในที่เดียวเท่านั้น ในรหัสการเชื่อมต่อเส้นทาง รูปแบบเรกเอ็กซ์ที่มีหลายบรรทัดถูกห้ามสำหรับความต้องการของเส้นทางและตรงนี้จะทำให้การบังคับข้อจำกัดนั้นง่ายขึ้น

```ruby
def verify_regexp_requirements(requirements)
  # ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option is not allowed in routing requirements: #{requirement.inspect}"
  end
  # ...
end
```
หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/regexp.rb`


ส่วนขยายให้กับ `Range`
---------------------

### `to_fs`

Active Support กำหนด `Range#to_fs` เป็นตัวเลือกทางเลือกสำหรับ `to_s` ที่เข้าใจอารมณ์ทางเลือกได้ โดยในขณะที่เขียนข้อความนี้รูปแบบที่รองรับที่ไม่ใช่ค่าเริ่มต้นเดียวคือ `:db`:

```ruby
(Date.today..Date.tomorrow).to_fs
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_fs(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

เช่นที่แสดงในตัวอย่าง รูปแบบ `:db` สร้างคำสั่ง SQL `BETWEEN` ซึ่งใช้โดย Active Record เพื่อรองรับค่าช่วงในเงื่อนไข

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/range/conversions.rb`


### `===` และ `include?`

เมธอด `Range#===` และ `Range#include?` บอกว่าค่าใดค่าหนึ่งอยู่ระหว่างสิ้นสุดของอินสแตนซ์ที่กำหนด:

```ruby
(2..3).include?(Math::E) # => true
```

Active Support ขยายเมธอดเหล่านี้เพื่อให้สามารถใช้อาร์กิวเมนต์เป็นช่วงอื่นได้อีกด้วย ในกรณีนั้นเราจะทดสอบว่าสิ้นสุดของช่วงอาร์กิวเมนต์เป็นส่วนของตัวรับเองหรือไม่:

```ruby
(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false
(1..10) === (3..11) # => false
(1...9) === (3..9)  # => false

(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false
(1..10).include?(3..11) # => false
(1...9).include?(3..9)  # => false
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/range/compare_range.rb`


### `overlap?`

เมธอด [`Range#overlap?`][Range#overlap?] บอกว่าช่วงสองช่วงที่กำหนดมีการตัดกันที่ไม่เป็นค่าว่าง:

```ruby
(1..10).overlap?(7..11)  # => true
(1..10).overlap?(0..7)   # => true
(1..10).overlap?(11..27) # => false
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/range/overlap.rb`


ส่วนขยายให้กับ `Date`
--------------------

### การคำนวณ

ข้อมูล: เมธอดการคำนวณต่อไปนี้มีกรณีพิเศษในเดือนตุลาคม ค.ศ. 1582 เนื่องจากวันที่ 5-14 ไม่มีอยู่จริง คู่มือนี้ไม่ได้ระบุพฤติกรรมของพวกเขารอบวันเหล่านั้นเพื่อความกระชับ แต่สามารถบอกได้ว่าพวกเขาทำตามที่คุณคาดหวัง กล่าวคือ `Date.new(1582, 10, 4).tomorrow` จะคืนค่า `Date.new(1582, 10, 15)` และอื่น ๆ โปรดตรวจสอบ `test/core_ext/date_ext_test.rb` ในชุดทดสอบ Active Support เพื่อดูพฤติกรรมที่คาดหวัง

#### `Date.current`

Active Support กำหนด [`Date.current`][Date.current] ให้เป็นวันนี้ในเขตเวลาปัจจุบัน คล้ายกับ `Date.today` แต่มันยอมรับเขตเวลาของผู้ใช้ถ้าถูกกำหนดไว้ นอกจากนี้ยังกำหนด [`Date.yesterday`][Date.yesterday] และ [`Date.tomorrow`][Date.tomorrow] และตัวบ่งชี้ของอินสแตนซ์ [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?], [`future?`][DateAndTime::Calculations#future?], [`on_weekday?`][DateAndTime::Calculations#on_weekday?] และ [`on_weekend?`][DateAndTime::Calculations#on_weekend?] ทั้งหมดเกี่ยวข้องกับ `Date.current`

เมื่อทำการเปรียบเทียบวันที่โดยใช้เมธอดที่ยอมรับเขตเวลาของผู้ใช้ โปรดใช้ `Date.current` และไม่ใช้ `Date.today` มีกรณีที่เขตเวลาของผู้ใช้อาจอยู่ในอนาคตเมื่อเปรียบเทียบกับเขตเวลาของระบบ ซึ่ง `Date.today` ใช้ค่าเริ่มต้น นั่นหมายความว่า `Date.today` อาจเท่ากับ `Date.yesterday`

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/date/calculations.rb`


#### ชื่อวันที่

##### `beginning_of_week`, `end_of_week`

เมธอด [`beginning_of_week`][DateAndTime::Calculations#beginning_of_week] และ [`end_of_week`][DateAndTime::Calculations#end_of_week] คืนค่าวันที่สำหรับเริ่มต้นและสิ้นสุดของสัปดาห์ตามลำดับ สัปดาห์ถือว่าเริ่มต้นในวันจันทร์ แต่สามารถเปลี่ยนได้โดยส่งอาร์กิวเมนต์ ตั้งค่า `Date.beginning_of_week` ที่เก็บในเธรดหรือ [`config.beginning_of_week`][]

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

`beginning_of_week` เป็นนามแฝงของ [`at_beginning_of_week`][DateAndTime::Calculations#at_beginning_of_week] และ `end_of_week` เป็นนามแฝงของ [`at_end_of_week`][DateAndTime::Calculations#at_end_of_week]

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/date_and_time/calculations.rb`


##### `monday`, `sunday`

เมธอด [`monday`][DateAndTime::Calculations#monday] และ [`sunday`][DateAndTime::Calculations#sunday] คืนค่าวันที่จันทร์ก่อนหน้าและวันอาทิตย์ถัดไปตามลำดับ
```ruby
date = Date.new(2010, 6, 7)
date.months_ago(3)   # => Mon, 07 Mar 2010
date.months_since(3) # => Thu, 07 Sep 2010
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2012, 3, 31).months_ago(1)     # => Thu, 29 Feb 2012
Date.new(2012, 1, 31).months_since(1)   # => Thu, 29 Feb 2012
```

[`last_month`][DateAndTime::Calculations#last_month] is short-hand for `#months_ago(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.


##### `weeks_ago`, `weeks_since`

The methods [`weeks_ago`][DateAndTime::Calculations#weeks_ago] and [`weeks_since`][DateAndTime::Calculations#weeks_since] work analogously for weeks:

```ruby
date = Date.new(2010, 6, 7)
date.weeks_ago(2)   # => Mon, 24 May 2010
date.weeks_since(2) # => Mon, 21 Jun 2010
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2012, 3, 31).weeks_ago(4)     # => Sat, 03 Mar 2012
Date.new(2012, 1, 31).weeks_since(4)   # => Sat, 03 Mar 2012
```

[`last_week`][DateAndTime::Calculations#last_week] is short-hand for `#weeks_ago(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.


##### `days_ago`, `days_since`

The methods [`days_ago`][DateAndTime::Calculations#days_ago] and [`days_since`][DateAndTime::Calculations#days_since] work analogously for days:

```ruby
date = Date.new(2010, 6, 7)
date.days_ago(5)   # => Wed, 02 Jun 2010
date.days_since(5) # => Sat, 12 Jun 2010
```

[`yesterday`][DateAndTime::Calculations#yesterday] is short-hand for `#days_ago(1)`, and [`tomorrow`][DateAndTime::Calculations#tomorrow] is short-hand for `#days_since(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.
```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Mon Jun 07 19:55:00 +0200 2010
```

The method [`end_of_minute`][DateTime#end_of_minute] returns a timestamp at the end of the minute (hh:mm:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Mon Jun 07 19:55:59 +0200 2010
```

`beginning_of_minute` is aliased to [`at_beginning_of_minute`][DateTime#at_beginning_of_minute].

NOTE: Defined in `active_support/core_ext/date_time/calculations.rb`.
```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => จันทร์ 7 มิถุนายน 19:55:00 +0200 2010
```

เมธอด [`end_of_minute`][DateTime#end_of_minute] จะคืนค่า timestamp ที่สิ้นสุดของนาที (hh:mm:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => จันทร์ 7 มิถุนายน 19:55:59 +0200 2010
```

`beginning_of_minute` มีการตั้งชื่อให้เป็น [`at_beginning_of_minute`][DateTime#at_beginning_of_minute].

ข้อมูล: `beginning_of_hour`, `end_of_hour`, `beginning_of_minute`, และ `end_of_minute` ถูกนำมาใช้สำหรับ `Time` และ `DateTime` แต่ไม่สำหรับ `Date` เนื่องจากไม่มีความหมายที่จะขอข้อมูลเริ่มต้นหรือสิ้นสุดของชั่วโมงหรือนาทีใน `Date` instance

หมายเหตุ: ถูกนิยามใน `active_support/core_ext/date_time/calculations.rb`.


##### `ago`, `since`

เมธอด [`ago`][Date#ago] รับอาร์กิวเมนต์เป็นจำนวนวินาทีและคืนค่า timestamp กี่วินาทีก่อนเที่ยงคืน:

```ruby
date = Date.current # => วันศุกร์ 11 มิถุนายน 2010
date.ago(1)         # => วันพฤหัสบดี 10 มิถุนายน 2010 23:59:59 EDT -04:00
```

อย่างเดียวกัน [`since`][Date#since] จะเลื่อนไปข้างหน้า:

```ruby
date = Date.current # => วันศุกร์ 11 มิถุนายน 2010
date.since(1)       # => วันศุกร์ 11 มิถุนายน 2010 00:00:01 EDT -04:00
```

หมายเหตุ: ถูกนิยามใน `active_support/core_ext/date/calculations.rb`.


ส่วนขยายให้กับ `DateTime`
------------------------

คำเตือน: `DateTime` ไม่รู้จักกฎ DST ดังนั้นเมธอดบางส่วนอาจมีกรณีพิเศษเมื่อมีการเปลี่ยน DST ตัวอย่างเช่น [`seconds_since_midnight`][DateTime#seconds_since_midnight] อาจไม่คืนค่าจริงในวันที่มีการเปลี่ยน DST

### การคำนวณ

คลาส `DateTime` เป็นคลาสลูกของ `Date` ดังนั้นโดยการโหลด `active_support/core_ext/date/calculations.rb` คุณจะสืบทอดเมธอดเหล่านี้และนามแฝงของพวกเขา แต่จะคืนค่าเป็น datetimes เสมอ

เมธอดต่อไปนี้ถูกนำมาสร้างใหม่เพื่อให้คุณไม่จำเป็นต้องโหลด `active_support/core_ext/date/calculations.rb` สำหรับเหล่านี้:

* [`beginning_of_day`][DateTime#beginning_of_day] / [`midnight`][DateTime#midnight] / [`at_midnight`][DateTime#at_midnight] / [`at_beginning_of_day`][DateTime#at_beginning_of_day]
* [`end_of_day`][DateTime#end_of_day]
* [`ago`][DateTime#ago]
* [`since`][DateTime#since] / [`in`][DateTime#in]

อย่างไรก็ตาม [`advance`][DateTime#advance] และ [`change`][DateTime#change] ก็ถูกนิยามและรองรับตัวเลือกเพิ่มเติม และได้รับการเอกสารด้านล่าง

เมธอดต่อไปนี้มีการนำมาใช้เฉพาะใน `active_support/core_ext/date_time/calculations.rb` เนื่องจากมีความหมายเฉพาะเมื่อใช้กับ `DateTime` instance เท่านั้น:

* [`beginning_of_hour`][DateTime#beginning_of_hour] / [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]
* [`end_of_hour`][DateTime#end_of_hour]


#### วันที่ที่ตั้งชื่อ

##### `DateTime.current`

Active Support กำหนด [`DateTime.current`][DateTime.current] ให้เป็นเหมือน `Time.now.to_datetime` แต่จะใช้ time zone ของผู้ใช้งานถ้าได้กำหนดไว้ ตัวตรวจสอบของ instance [`past?`][DateAndTime::Calculations#past?] และ [`future?`][DateAndTime::Calculations#future?] ถูกกำหนดให้เป็นสัมพันธ์กับ `DateTime.current`

หมายเหตุ: ถูกนิยามใน `active_support/core_ext/date_time/calculations.rb`.


#### ส่วนขยายอื่น ๆ

##### `seconds_since_midnight`

เมธอด [`seconds_since_midnight`][DateTime#seconds_since_midnight] คืนค่าจำนวนวินาทีตั้งแต่เที่ยงคืน:

```ruby
now = DateTime.current     # => จันทร์ 7 มิถุนายน 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

หมายเหตุ: ถูกนิยามใน `active_support/core_ext/date_time/calculations.rb`.


##### `utc`

เมธอด [`utc`][DateTime#utc] จะให้คุณได้ datetime เดียวกันใน receiver ที่แสดงออกเป็น UTC

```ruby
now = DateTime.current # => จันทร์ 7 มิถุนายน 2010 19:27:52 -0400
now.utc                # => จันทร์ 7 มิถุนายน 2010 23:27:52 +0000
```

เมธอดนี้ยังมีการตั้งชื่อให้เป็น [`getutc`][DateTime#getutc].

หมายเหตุ: ถูกนิยามใน `active_support/core_ext/date_time/calculations.rb`.


##### `utc?`

ตัวตรวจสอบ [`utc?`][DateTime#utc?] บอกว่า receiver มีเขตเวลาเป็น UTC หรือไม่:

```ruby
now = DateTime.now # => จันทร์ 7 มิถุนายน 2010 19:30:47 -0400
now.utc?           # => เท็จ
now.utc.utc?       # => จริง
```

หมายเหตุ: ถูกนิยามใน `active_support/core_ext/date_time/calculations.rb`.


##### `advance`

วิธีที่สามารถกระโดดไปยัง datetime อื่น ๆ ได้ที่สุด [`advance`][DateTime#advance] เมธอดนี้รับ hash ที่มีคีย์ `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes`, และ `:seconds` และคืนค่า datetime ที่ได้รับการเลื่อนไปตามคีย์ที่ระบุในปัจจุบัน
```ruby
d = DateTime.current
# => พฤหัสบดี, 05 สิงหาคม 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => อังคาร, 06 กันยายน 2011 12:34:32 +0000
```

เมธอดนี้จะคำนวณวันที่ปลายทางโดยส่ง `:years`, `:months`, `:weeks`, และ `:days` ไปยัง `Date#advance` ที่ได้ระบุไว้ข้างต้น หลังจากนั้น จะปรับเวลาโดยเรียกใช้ [`since`][DateTime#since] ด้วยจำนวนวินาทีที่ต้องการเลื่อนขึ้น การเรียงลำดับนี้มีความสำคัญ การเรียงลำดับที่แตกต่างกันอาจทำให้ได้วันที่และเวลาที่แตกต่างกันในบางกรณีที่เป็นกรณีพิเศษ ตัวอย่างใน `Date#advance` ยังใช้ได้ และเราสามารถขยายไปเพื่อแสดงความสำคัญของการเรียงลำดับที่เกี่ยวข้องกับชิ้นส่วนเวลา

หากเราย้ายชิ้นส่วนวันที่ (ซึ่งยังมีการเรียงลำดับที่สัมพันธ์กันอีกด้วยตามที่ได้ระบุไว้ข้างต้น) แล้วค่อยย้ายชิ้นส่วนเวลา เราจะได้ผลลัพธ์ดังต่อไปนี้:

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => อาทิตย์, 28 กุมภาพันธ์ 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => จันทร์, 29 มีนาคม 2010 00:00:00 +0000
```

แต่หากเราคำนวณในทิศทางตรงกันข้าม ผลลัพธ์จะแตกต่าง:

```ruby
d.advance(seconds: 1).advance(months: 1)
# => พฤหัสบดี, 01 เมษายน 2010 00:00:00 +0000
```

คำเตือน: เนื่องจาก `DateTime` ไม่รองรับการจัดเก็บข้อมูลเกี่ยวกับการปรับเวลาตามฤดูกาล คุณอาจได้เวลาที่ไม่มีอยู่จริงโดยไม่มีการเตือนหรือข้อผิดพลาดที่บอกให้คุณทราบ

หมายเหตุ: ได้กำหนดไว้ใน `active_support/core_ext/date_time/calculations.rb`


#### เปลี่ยนแปลงส่วนประกอบ

เมธอด [`change`][DateTime#change] ช่วยให้คุณได้วันที่และเวลาใหม่ที่เหมือนกับวัตถุรับข้อมูลยกเว้นส่วนประกอบที่กำหนด ซึ่งอาจรวมถึง `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start`:

```ruby
now = DateTime.current
# => อังคาร, 08 มิถุนายน 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => พุธ, 08 มิถุนายน 2011 01:56:22 -0600
```

หากชั่วโมงถูกตั้งเป็นศูนย์ นาทีและวินาทีก็จะเป็นศูนย์ด้วย (ยกเว้นถ้ามีค่าที่กำหนด):

```ruby
now.change(hour: 0)
# => อังคาร, 08 มิถุนายน 2010 00:00:00 +0000
```

ในทางเดียวกัน หากนาทีถูกตั้งเป็นศูนย์ วินาทีก็จะเป็นศูนย์ด้วย (ยกเว้นถ้ามีค่าที่กำหนด):

```ruby
now.change(min: 0)
# => อังคาร, 08 มิถุนายน 2010 01:00:00 +0000
```

เมธอดนี้ไม่ยอมรับวันที่ที่ไม่มีอยู่ หากการเปลี่ยนแปลงไม่ถูกต้อง จะเกิดข้อผิดพลาด `ArgumentError`:

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: invalid date
```

หมายเหตุ: ได้กำหนดไว้ใน `active_support/core_ext/date_time/calculations.rb`


#### ระยะเวลา

วัตถุ [`Duration`][ActiveSupport::Duration] สามารถเพิ่มหรือลดจากวันที่และเวลาได้:

```ruby
now = DateTime.current
# => จันทร์, 09 สิงหาคม 2010 23:15:17 +0000
now + 1.year
# => อังคาร, 09 สิงหาคม 2011 23:15:17 +0000
now - 1.week
# => จันทร์, 02 สิงหาคม 2010 23:15:17 +0000
```

การเพิ่มหรือลดจะแปลงเป็นการเรียกใช้ `since` หรือ `advance` ตัวอย่างเช่นที่นี่เราได้รับการเลื่อนที่ถูกต้องในการปฏิทิน:

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => ศุกร์, 15 ตุลาคม 1582 00:00:00 +0000
```

ส่วนขยายใน `Time`
--------------------

### การคำนวณ

มันคล้ายกัน โปรดอ้างอิงคู่มือของพวกเขาด้านบนและพิจารณาความแตกต่างต่อไปนี้:

* [`change`][Time#change] ยอมรับตัวเลือกเพิ่มเติม `:usec` อีกตัวหนึ่ง
* `Time` เข้าใจ DST ดังนั้นคุณจะได้การคำนวณ DST ที่ถูกต้องเช่นเดียวกับ

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# ในบาร์เซโลนา เวลา 2010/03/28 02:00 +0100 กลายเป็น 2010/03/28 03:00 +0200 เนื่องจาก DST
t = Time.local(2010, 3, 28, 1, 59, 59)
# => อาทิตย์ มีนาคม 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => อาทิตย์ มีนาคม 28 03:00:00 +0200 2010
```
* หาก [`since`][Time#since] หรือ [`ago`][Time#ago] กระโดดไปยังเวลาที่ไม่สามารถแสดงได้ด้วย `Time` จะส่งกลับเป็นอ็อบเจกต์ `DateTime` แทน


#### `Time.current`

Active Support กำหนด [`Time.current`][Time.current] ให้เป็นวันนี้ในโซนเวลาปัจจุบัน คล้ายกับ `Time.now` แต่มันจะให้ความสำคัญกับโซนเวลาของผู้ใช้ หากได้กำหนดไว้ มันยังกำหนดตัวพิสัย [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?] และ [`future?`][DateAndTime::Calculations#future?] ทั้งหมดเทียบกับ `Time.current`

เมื่อทำการเปรียบเทียบเวลาโดยใช้เมธอดที่ให้ความสำคัญกับโซนเวลาของผู้ใช้ ตรวจสอบให้แน่ใจว่าใช้ `Time.current` แทน `Time.now` มีกรณีที่โซนเวลาของผู้ใช้อาจอยู่ในอนาคตเมื่อเทียบกับโซนเวลาของระบบซึ่ง `Time.now` ใช้โดยค่าเริ่มต้น นี่หมายความว่า `Time.now.to_date` อาจเท่ากับ `Date.yesterday`

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/time/calculations.rb`


#### `all_day`, `all_week`, `all_month`, `all_quarter`, และ `all_year`

เมธอด [`all_day`][DateAndTime::Calculations#all_day] จะส่งกลับช่วงเวลาที่แทนวันทั้งหมดของเวลาปัจจุบัน

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

ในทางเดียวกัน [`all_week`][DateAndTime::Calculations#all_week], [`all_month`][DateAndTime::Calculations#all_month], [`all_quarter`][DateAndTime::Calculations#all_quarter] และ [`all_year`][DateAndTime::Calculations#all_year] ใช้สำหรับสร้างช่วงเวลา

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_week
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Sun, 15 Aug 2010 23:59:59 UTC +00:00
now.all_week(:sunday)
# => Sun, 16 Sep 2012 00:00:00 UTC +00:00..Sat, 22 Sep 2012 23:59:59 UTC +00:00
now.all_month
# => Sat, 01 Aug 2010 00:00:00 UTC +00:00..Tue, 31 Aug 2010 23:59:59 UTC +00:00
now.all_quarter
# => Thu, 01 Jul 2010 00:00:00 UTC +00:00..Thu, 30 Sep 2010 23:59:59 UTC +00:00
now.all_year
# => Fri, 01 Jan 2010 00:00:00 UTC +00:00..Fri, 31 Dec 2010 23:59:59 UTC +00:00
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/date_and_time/calculations.rb`


#### `prev_day`, `next_day`

[`prev_day`][Time#prev_day] และ [`next_day`][Time#next_day] จะส่งกลับเวลาในวันก่อนหน้าหรือวันถัดไป:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_day               # => 2010-05-07 00:00:00 +0900
t.next_day               # => 2010-05-09 00:00:00 +0900
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/time/calculations.rb`


#### `prev_month`, `next_month`

[`prev_month`][Time#prev_month] และ [`next_month`][Time#next_month] จะส่งกลับเวลาในเดือนก่อนหน้าหรือเดือนถัดไปที่มีวันเดียวกัน:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_month             # => 2010-04-08 00:00:00 +0900
t.next_month             # => 2010-06-08 00:00:00 +0900
```

หากวันดังกล่าวไม่มีอยู่ จะส่งกลับวันสุดท้ายของเดือนที่เกี่ยวข้อง:

```ruby
Time.new(2000, 5, 31).prev_month # => 2000-04-30 00:00:00 +0900
Time.new(2000, 3, 31).prev_month # => 2000-02-29 00:00:00 +0900
Time.new(2000, 5, 31).next_month # => 2000-06-30 00:00:00 +0900
Time.new(2000, 1, 31).next_month # => 2000-02-29 00:00:00 +0900
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/time/calculations.rb`


#### `prev_year`, `next_year`

[`prev_year`][Time#prev_year] และ [`next_year`][Time#next_year] จะส่งกลับเวลาในปีก่อนหน้าหรือปีถัดไปที่มีวัน/เดือนเดียวกัน:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_year              # => 2009-05-08 00:00:00 +0900
t.next_year              # => 2011-05-08 00:00:00 +0900
```

หากวันที่เป็นวันที่ 29 กุมภาพันธ์ของปีอธิปไตย จะได้วันที่ 28:

```ruby
t = Time.new(2000, 2, 29) # => 2000-02-29 00:00:00 +0900
t.prev_year               # => 1999-02-28 00:00:00 +0900
t.next_year               # => 2001-02-28 00:00:00 +0900
```
หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/time/calculations.rb`


#### `prev_quarter`, `next_quarter`

[`prev_quarter`][DateAndTime::Calculations#prev_quarter] และ [`next_quarter`][DateAndTime::Calculations#next_quarter] จะคืนค่าวันที่เดียวกันในไตรมาสก่อนหน้าหรือไตรมาสถัดไป:

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 +0300
t.prev_quarter             # => 2010-02-08 00:00:00 +0200
t.next_quarter             # => 2010-08-08 00:00:00 +0300
```

หากไม่มีวันดังกล่าวอยู่ จะคืนค่าวันสุดท้ายของเดือนที่เกี่ยวข้อง:

```ruby
Time.local(2000, 7, 31).prev_quarter  # => 2000-04-30 00:00:00 +0300
Time.local(2000, 5, 31).prev_quarter  # => 2000-02-29 00:00:00 +0200
Time.local(2000, 10, 31).prev_quarter # => 2000-07-31 00:00:00 +0300
Time.local(2000, 11, 31).next_quarter # => 2001-03-01 00:00:00 +0200
```

`prev_quarter` มีชื่อย่อเป็น [`last_quarter`][DateAndTime::Calculations#last_quarter].

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/date_and_time/calculations.rb`.


### ตัวสร้างเวลา

Active Support กำหนด [`Time.current`][Time.current] ให้เป็น `Time.zone.now` หากมีการกำหนดโซนเวลาของผู้ใช้ มีการย้อนกลับไปที่ `Time.now` หากไม่มี:

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

เหมือนกับ `DateTime`, ตัวบ่งชี้ [`past?`][DateAndTime::Calculations#past?] และ [`future?`][DateAndTime::Calculations#future?] เป็นสัมพันธ์กับ `Time.current`.

หากเวลาที่จะสร้างอยู่นอกขอบเขตที่รองรับโดย `Time` ในแพลตฟอร์มการทำงาน จะละทิ้งไมโครวินาทีและคืนค่าออบเจ็กต์ `DateTime` แทน.

#### ระยะเวลา

ออบเจ็กต์ [`Duration`][ActiveSupport::Duration] สามารถเพิ่มหรือลบจากออบเจ็กต์เวลาได้:

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
# => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

การแปลงเป็นการเรียกใช้ `since` หรือ `advance` ตัวอย่างเช่นที่นี่เราได้รับการกระโดดที่ถูกต้องในการปฏิทิน:

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

ส่วนขยายให้กับ `File`
--------------------

### `atomic_write`

ด้วยเมธอดคลาส [`File.atomic_write`][File.atomic_write] คุณสามารถเขียนไปยังไฟล์ในวิธีที่จะป้องกันผู้อ่านใดๆ จากการเห็นเนื้อหาที่เขียนครึ่งหนึ่ง

ชื่อของไฟล์ถูกส่งผ่านเป็นอาร์กิวเมนต์ และเมธอดจะเรียกใช้ไฟล์แฮนเดิลที่เปิดเพื่อเขียน หลังจากที่บล็อกเสร็จสิ้น `atomic_write` จะปิดไฟล์แฮนเดิลและทำงานเสร็จ

ตัวอย่างเช่น Action Pack ใช้เมธอดนี้ในการเขียนไฟล์แคชสินทรัพย์เช่น `all.css`:

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

เพื่อทำให้สำเร็จ `atomic_write` สร้างไฟล์ชั่วคราว นั่นคือไฟล์ที่โค้ดในบล็อกจริงๆ เขียนไป หลังจากเสร็จสิ้น ไฟล์ชั่วคราวจะถูกเปลี่ยนชื่อ ซึ่งเป็นการดำเนินการแอตอมิกบนระบบ POSIX หากไฟล์เป้าหมายมีอยู่ `atomic_write` จะเขียนทับและเก็บเจ้าของและสิทธิ์ อย่างไรก็ตามมีกรณีบางกรณีที่ `atomic_write` ไม่สามารถเปลี่ยนเจ้าของหรือสิทธิ์ของไฟล์ได้ ข้อผิดพลาดนี้ถูกจับและข้ามไปเชื่อมใจในผู้ใช้/ระบบไฟล์เพื่อให้ไฟล์สามารถเข้าถึงได้โดยกระบวนการที่ต้องการ

หมายเหตุ. เนื่องจากการดำเนินการ chmod `atomic_write` ทำ หากไฟล์เป้าหมายมี ACL ที่ตั้งค่าไว้ ACL นี้จะถูกคำนวณ/แก้ไขใหม่

คำเตือน. โปรดทราบว่าคุณไม่สามารถเพิ่มเข้าไปด้วย `atomic_write` ได้

ไฟล์ช่วยเพิ่มให้กับ `NameError`
-------------------------
Active Support เพิ่ม [`missing_name?`][NameError#missing_name?] ใน `NameError` เพื่อทดสอบว่าข้อยกเว้นถูกเกิดขึ้นเพราะชื่อที่ถูกส่งเป็นอาร์กิวเมนต์

ชื่ออาจถูกกำหนดให้เป็นสัญลักษณ์หรือสตริง สัญลักษณ์จะถูกทดสอบกับชื่อค่าคงที่เปล่าเปลี่ยน สตริงจะถูกทดสอบกับชื่อค่าคงที่ที่เต็มรูปแบบ

เคล็ดลับ: สัญลักษณ์สามารถแทนชื่อค่าคงที่ที่เต็มรูปแบบได้เช่น `:"ActiveRecord::Base"` ดังนั้นพฤติกรรมสำหรับสัญลักษณ์ถูกกำหนดเพื่อความสะดวก ไม่ใช่เพราะว่าจำเป็นตามเทคนิค

ตัวอย่างเช่น เมื่อเรียกใช้การกระทำของ `ArticlesController` Rails พยายามที่จะใช้ `ArticlesHelper` ในทางทฤษฎี ไม่มีปัญหาที่โมดูลช่วยเหลือไม่มีอยู่ ดังนั้นหากมีข้อยกเว้นสำหรับชื่อค่าคงที่นั้นถูกเกิดขึ้น ควรปิดเสียง แต่อาจเป็นได้ว่า `articles_helper.rb` กำลังเกิดข้อผิดพลาด `NameError` เนื่องจากค่าคงที่ที่ไม่รู้จักจริง ในกรณีนั้นควรเกิดขึ้นอีกครั้ง วิธี `missing_name?` ให้วิธีที่จะแยกแยะทั้งสองกรณี:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/name_error.rb`


ส่วนขยายให้กับ `LoadError`
-------------------------

Active Support เพิ่ม [`is_missing?`][LoadError#is_missing?] ใน `LoadError`

โดยกำหนดให้ `is_missing?` ทดสอบว่าข้อยกเว้นถูกเกิดขึ้นเนื่องจากไฟล์ที่เฉพาะเจาะจงนั้น (ยกเว้นบางครั้งสำหรับส่วนขยาย ".rb")

ตัวอย่างเช่น เมื่อเรียกใช้การกระทำของ `ArticlesController` Rails พยายามโหลด `articles_helper.rb` แต่ไฟล์นั้นอาจไม่มีอยู่ นั่นไม่เป็นไร โมดูลช่วยเหลือไม่บังคับให้ Rails ปิดเสียงข้อผิดพลาดในการโหลด แต่อาจเป็นได้ว่าโมดูลช่วยเหลือนั้นมีอยู่และต้องการไลบรารีอื่นที่หายไป ในกรณีนั้น Rails ต้องเกิดข้อผิดพลาดอีกครั้ง วิธี `is_missing?` ให้วิธีที่จะแยกแยะทั้งสองกรณี:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/load_error.rb`


ส่วนขยายให้กับ Pathname
-------------------------

### `existence`

เมธอด [`existence`][Pathname#existence] จะส่งคืนตัวรับถ้ามีไฟล์ที่ระบุอยู่ มิฉะนั้นจะส่งคืน `nil` เป็นประโยชน์สำหรับไอดีอิโดมเช่นนี้:

```ruby
content = Pathname.new("file").existence&.read
```

หมายเหตุ: กำหนดไว้ใน `active_support/core_ext/pathname/existence.rb`
[`config.active_support.bare`]: configuring.html#config-active-support-bare
[Object#blank?]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[Object#present?]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[Object#presence]: https://api.rubyonrails.org/classes/Object.html#method-i-presence
[Object#duplicable?]: https://api.rubyonrails.org/classes/Object.html#method-i-duplicable-3F
[Object#deep_dup]: https://api.rubyonrails.org/classes/Object.html#method-i-deep_dup
[Object#try]: https://api.rubyonrails.org/classes/Object.html#method-i-try
[Object#try!]: https://api.rubyonrails.org/classes/Object.html#method-i-try-21
[Kernel#class_eval]: https://api.rubyonrails.org/classes/Kernel.html#method-i-class_eval
[Object#acts_like?]: https://api.rubyonrails.org/classes/Object.html#method-i-acts_like-3F
[Array#to_param]: https://api.rubyonrails.org/classes/Array.html#method-i-to_param
[Object#to_param]: https://api.rubyonrails.org/classes/Object.html#method-i-to_param
[Hash#to_query]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_query
[Object#to_query]: https://api.rubyonrails.org/classes/Object.html#method-i-to_query
[Object#with_options]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[Object#instance_values]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_values
[Object#instance_variable_names]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_variable_names
[Kernel#enable_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-enable_warnings
[Kernel#silence_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-silence_warnings
[Kernel#suppress]: https://api.rubyonrails.org/classes/Kernel.html#method-i-suppress
[Object#in?]: https://api.rubyonrails.org/classes/Object.html#method-i-in-3F
[Module#alias_attribute]: https://api.rubyonrails.org/classes/Module.html#method-i-alias_attribute
[Module#attr_internal]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal
[Module#attr_internal_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_accessor
[Module#attr_internal_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_reader
[Module#attr_internal_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_writer
[Module#mattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_accessor
[Module#mattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_reader
[Module#mattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_writer
[Module#module_parent]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent
[Module#module_parent_name]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent_name
[Module#module_parents]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parents
[Module#anonymous?]: https://api.rubyonrails.org/classes/Module.html#method-i-anonymous-3F
[Module#delegate]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate
[Module#delegate_missing_to]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate_missing_to
[Module#redefine_method]: https://api.rubyonrails.org/classes/Module.html#method-i-redefine_method
[Module#silence_redefinition_of_method]: https://api.rubyonrails.org/classes/Module.html#method-i-silence_redefinition_of_method
[Class#class_attribute]: https://api.rubyonrails.org/classes/Class.html#method-i-class_attribute
[Module#cattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_accessor
[Module#cattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_reader
[Module#cattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_writer
[Class#subclasses]: https://api.rubyonrails.org/classes/Class.html#method-i-subclasses
[Class#descendants]: https://api.rubyonrails.org/classes/Class.html#method-i-descendants
[`raw`]: https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-raw
[String#html_safe]: https://api.rubyonrails.org/classes/String.html#method-i-html_safe
[String#remove]: https://api.rubyonrails.org/classes/String.html#method-i-remove
[String#squish]: https://api.rubyonrails.org/classes/String.html#method-i-squish
[String#truncate]: https://api.rubyonrails.org/classes/String.html#method-i-truncate
[String#truncate_bytes]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_bytes
[String#truncate_words]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_words
[String#inquiry]: https://api.rubyonrails.org/classes/String.html#method-i-inquiry
[String#strip_heredoc]: https://api.rubyonrails.org/classes/String.html#method-i-strip_heredoc
[String#indent!]: https://api.rubyonrails.org/classes/String.html#method-i-indent-21
[String#indent]: https://api.rubyonrails.org/classes/String.html#method-i-indent
[String#at]: https://api.rubyonrails.org/classes/String.html#method-i-at
[String#from]: https://api.rubyonrails.org/classes/String.html#method-i-from
[String#to]: https://api.rubyonrails.org/classes/String.html#method-i-to
[String#first]: https://api.rubyonrails.org/classes/String.html#method-i-first
[String#last]: https://api.rubyonrails.org/classes/String.html#method-i-last
[String#pluralize]: https://api.rubyonrails.org/classes/String.html#method-i-pluralize
[String#singularize]: https://api.rubyonrails.org/classes/String.html#method-i-singularize
[String#camelcase]: https://api.rubyonrails.org/classes/String.html#method-i-camelcase
[String#camelize]: https://api.rubyonrails.org/classes/String.html#method-i-camelize
[String#underscore]: https://api.rubyonrails.org/classes/String.html#method-i-underscore
[String#titlecase]: https://api.rubyonrails.org/classes/String.html#method-i-titlecase
[String#titleize]: https://api.rubyonrails.org/classes/String.html#method-i-titleize
[String#dasherize]: https://api.rubyonrails.org/classes/String.html#method-i-dasherize
[String#demodulize]: https://api.rubyonrails.org/classes/String.html#method-i-demodulize
[String#deconstantize]: https://api.rubyonrails.org/classes/String.html#method-i-deconstantize
[String#parameterize]: https://api.rubyonrails.org/classes/String.html#method-i-parameterize
[String#tableize]: https://api.rubyonrails.org/classes/String.html#method-i-tableize
[String#classify]: https://api.rubyonrails.org/classes/String.html#method-i-classify
[String#constantize]: https://api.rubyonrails.org/classes/String.html#method-i-constantize
[String#humanize]: https://api.rubyonrails.org/classes/String.html#method-i-humanize
[String#foreign_key]: https://api.rubyonrails.org/classes/String.html#method-i-foreign_key
[String#upcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-upcase_first
[String#downcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-downcase_first
[String#to_date]: https://api.rubyonrails.org/classes/String.html#method-i-to_date
[String#to_datetime]: https://api.rubyonrails.org/classes/String.html#method-i-to_datetime
[String#to_time]: https://api.rubyonrails.org/classes/String.html#method-i-to_time
[Numeric#bytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-bytes
[Numeric#exabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-exabytes
[Numeric#gigabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-gigabytes
[Numeric#kilobytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-kilobytes
[Numeric#megabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-megabytes
[Numeric#petabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-petabytes
[Numeric#terabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-terabytes
[Duration#ago]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-ago
[Duration#from_now]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-from_now
[Numeric#days]: https://api.rubyonrails.org/classes/Numeric.html#method-i-days
[Numeric#fortnights]: https://api.rubyonrails.org/classes/Numeric.html#method-i-fortnights
[Numeric#hours]: https://api.rubyonrails.org/classes/Numeric.html#method-i-hours
[Numeric#minutes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-minutes
[Numeric#seconds]: https://api.rubyonrails.org/classes/Numeric.html#method-i-seconds
[Numeric#weeks]: https://api.rubyonrails.org/classes/Numeric.html#method-i-weeks
[Integer#multiple_of?]: https://api.rubyonrails.org/classes/Integer.html#method-i-multiple_of-3F
[Integer#ordinal]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinal
[Integer#ordinalize]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinalize
[Integer#months]: https://api.rubyonrails.org/classes/Integer.html#method-i-months
[Integer#years]: https://api.rubyonrails.org/classes/Integer.html#method-i-years
[Enumerable#sum]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-sum
[Enumerable#index_by]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_by
[Enumerable#index_with]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_with
[Enumerable#many?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-many-3F
[Enumerable#exclude?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-exclude-3F
[Enumerable#including]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-including
[Enumerable#excluding]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-excluding
[Enumerable#without]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-without
[Enumerable#pluck]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pluck
[Enumerable#pick]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pick
[Array#excluding]: https://api.rubyonrails.org/classes/Array.html#method-i-excluding
[Array#fifth]: https://api.rubyonrails.org/classes/Array.html#method-i-fifth
[Array#forty_two]: https://api.rubyonrails.org/classes/Array.html#method-i-forty_two
[Array#fourth]: https://api.rubyonrails.org/classes/Array.html#method-i-fourth
[Array#from]: https://api.rubyonrails.org/classes/Array.html#method-i-from
[Array#including]: https://api.rubyonrails.org/classes/Array.html#method-i-including
[Array#second]: https://api.rubyonrails.org/classes/Array.html#method-i-second
[Array#second_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-second_to_last
[Array#third]: https://api.rubyonrails.org/classes/Array.html#method-i-third
[Array#third_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-third_to_last
[Array#to]: https://api.rubyonrails.org/classes/Array.html#method-i-to
[Array#extract!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract-21
[Array#extract_options!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract_options-21
[Array#to_sentence]: https://api.rubyonrails.org/classes/Array.html#method-i-to_sentence
[Array#to_fs]: https://api.rubyonrails.org/classes/Array.html#method-i-to_fs
[Array#to_xml]: https://api.rubyonrails.org/classes/Array.html#method-i-to_xml
[Array.wrap]: https://api.rubyonrails.org/classes/Array.html#method-c-wrap
[Array#deep_dup]: https://api.rubyonrails.org/classes/Array.html#method-i-deep_dup
[Array#in_groups_of]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups_of
[Array#in_groups]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups
[Array#split]: https://api.rubyonrails.org/classes/Array.html#method-i-split
[Hash#to_xml]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_xml
[Hash#reverse_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge-21
[Hash#reverse_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge
[Hash#reverse_update]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_update
[Hash#deep_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge-21
[Hash#deep_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge
[Hash#deep_dup]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_dup
[Hash#except!]: https://api.rubyonrails.org/classes/Hash.html#method-i-except-21
[Hash#except]: https://api.rubyonrails.org/classes/Hash.html#method-i-except
[Hash#deep_stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys-21
[Hash#deep_stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys
[Hash#stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys-21
[Hash#stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys
[Hash#deep_symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys-21
[Hash#deep_symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys
[Hash#symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys-21
[Hash#symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys
[Hash#to_options!]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options-21
[Hash#to_options]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options
[Hash#assert_valid_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-assert_valid_keys
[Hash#deep_transform_values!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values-21
[Hash#deep_transform_values]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values
[Hash#slice!]: https://api.rubyonrails.org/classes/Hash.html#method-i-slice-21
[Hash#extract!]: https://api.rubyonrails.org/classes/Hash.html#method-i-extract-21
[ActiveSupport::HashWithIndifferentAccess]: https://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html
[Hash#with_indifferent_access]: https://api.rubyonrails.org/classes/Hash.html#method-i-with_indifferent_access
[Regexp#multiline?]: https://api.rubyonrails.org/classes/Regexp.html#method-i-multiline-3F
[Range#overlap?]: https://api.rubyonrails.org/classes/Range.html#method-i-overlaps-3F
[Date.current]: https://api.rubyonrails.org/classes/Date.html#method-c-current
[Date.tomorrow]: https://api.rubyonrails.org/classes/Date.html#method-c-tomorrow
[Date.yesterday]: https://api.rubyonrails.org/classes/Date.html#method-c-yesterday
[DateAndTime::Calculations#future?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-future-3F
[DateAndTime::Calculations#on_weekday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekday-3F
[DateAndTime::Calculations#on_weekend?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekend-3F
[DateAndTime::Calculations#past?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-past-3F
[`config.beginning_of_week`]: configuring.html#config-beginning-of-week
[DateAndTime::Calculations#at_beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_week
[DateAndTime::Calculations#at_end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_week
[DateAndTime::Calculations#beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_week
[DateAndTime::Calculations#end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_week
[DateAndTime::Calculations#monday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-monday
[DateAndTime::Calculations#sunday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-sunday
[Date.beginning_of_week]: https://api.rubyonrails.org/classes/Date.html#method-c-beginning_of_week
[DateAndTime::Calculations#last_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_week
[DateAndTime::Calculations#next_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_week
[DateAndTime::Calculations#prev_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_week
[DateAndTime::Calculations#at_beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_month
[DateAndTime::Calculations#at_end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_month
[DateAndTime::Calculations#beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_month
[DateAndTime::Calculations#end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_month
[DateAndTime::Calculations#quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-quarter
[DateAndTime::Calculations#at_beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_quarter
[DateAndTime::Calculations#at_end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_quarter
[DateAndTime::Calculations#beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_quarter
[DateAndTime::Calculations#end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_quarter
[DateAndTime::Calculations#at_beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_year
[DateAndTime::Calculations#at_end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_year
[DateAndTime::Calculations#beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_year
[DateAndTime::Calculations#end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_year
[DateAndTime::Calculations#last_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_year
[DateAndTime::Calculations#years_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_ago
[DateAndTime::Calculations#years_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_since
[DateAndTime::Calculations#last_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_month
[DateAndTime::Calculations#months_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_ago
[DateAndTime::Calculations#months_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_since
[DateAndTime::Calculations#weeks_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-weeks_ago
[Date#advance]: https://api.rubyonrails.org/classes/Date.html#method-i-advance
[Date#change]: https://api.rubyonrails.org/classes/Date.html#method-i-change
[ActiveSupport::Duration]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html
[Date#at_beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-at_beginning_of_day
[Date#at_midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-at_midnight
[Date#beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-beginning_of_day
[Date#end_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-end_of_day
[Date#midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-midnight
[DateTime#at_beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_minute
[DateTime#beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_minute
[DateTime#end_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_minute
[Date#ago]: https://api.rubyonrails.org/classes/Date.html#method-i-ago
[Date#since]: https://api.rubyonrails.org/classes/Date.html#method-i-since
[DateTime#ago]: https://api.rubyonrails.org/classes/DateTime.html#method-i-ago
[DateTime#at_beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_day
[DateTime#at_beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_hour
[DateTime#at_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_midnight
[DateTime#beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_day
[DateTime#beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_hour
[DateTime#end_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_day
[DateTime#end_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_hour
[DateTime#in]: https://api.rubyonrails.org/classes/DateTime.html#method-i-in
[DateTime#midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-midnight
[DateTime.current]: https://api.rubyonrails.org/classes/DateTime.html#method-c-current
[DateTime#seconds_since_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-seconds_since_midnight
[DateTime#getutc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-getutc
[DateTime#utc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc
[DateTime#utc?]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc-3F
[DateTime#advance]: https://api.rubyonrails.org/classes/DateTime.html#method-i-advance
[DateTime#since]: https://api.rubyonrails.org/classes/DateTime.html#method-i-since
[DateTime#change]: https://api.rubyonrails.org/classes/DateTime.html#method-i-change
[Time#ago]: https://api.rubyonrails.org/classes/Time.html#method-i-ago
[Time#change]: https://api.rubyonrails.org/classes/Time.html#method-i-change
[Time#since]: https://api.rubyonrails.org/classes/Time.html#method-i-since
[DateAndTime::Calculations#next_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_day-3F
[DateAndTime::Calculations#prev_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_day-3F
[DateAndTime::Calculations#today?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-today-3F
[DateAndTime::Calculations#tomorrow?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-tomorrow-3F
[DateAndTime::Calculations#yesterday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-yesterday-3F
[DateAndTime::Calculations#all_day]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_day
[DateAndTime::Calculations#all_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_month
[DateAndTime::Calculations#all_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_quarter
[DateAndTime::Calculations#all_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_week
[DateAndTime::Calculations#all_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_year
[Time.current]: https://api.rubyonrails.org/classes/Time.html#method-c-current
[Time#next_day]: https://api.rubyonrails.org/classes/Time.html#method-i-next_day
[Time#prev_day]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_day
[Time#next_month]: https://api.rubyonrails.org/classes/Time.html#method-i-next_month
[Time#prev_month]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_month
[Time#next_year]: https://api.rubyonrails.org/classes/Time.html#method-i-next_year
[Time#prev_year]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_year
[DateAndTime::Calculations#last_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_quarter
[DateAndTime::Calculations#next_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_quarter
[DateAndTime::Calculations#prev_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_quarter
[File.atomic_write]: https://api.rubyonrails.org/classes/File.html#method-c-atomic_write
[NameError#missing_name?]: https://api.rubyonrails.org/classes/NameError.html#method-i-missing_name-3F
[LoadError#is_missing?]: https://api.rubyonrails.org/classes/LoadError.html#method-i-is_missing-3F
[Pathname#existence]: https://api.rubyonrails.org/classes/Pathname.html#method-i-existence
