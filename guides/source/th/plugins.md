**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b550120024fb17dc176480922543264e
พื้นฐานในการสร้างปลั๊กอิน Rails
====================================

ปลั๊กอิน Rails เป็นการขยายหรือแก้ไขของกรอบการทำงานหลัก ปลั๊กอินให้:

* วิธีให้นักพัฒนาแบ่งปันไอเดียที่กำลังพัฒนาโดยไม่ทำให้ระบบโค้ดที่เสถียรเสียหาย
* สถาปัตยกรรมที่แยกส่วนเพื่อให้สามารถแก้ไขหรืออัปเดตหน่วยของโค้ดได้ตามกำหนดเวลาการอัปเดตของตัวเอง
* ช่องทางสำหรับนักพัฒนาหลักเพื่อไม่ต้องรวมฟีเจอร์ใหม่ที่เยี่ยมยอดทั้งหมด

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีการสร้างปลั๊กอินตั้งแต่เริ่มต้น
* วิธีเขียนและเรียกใช้การทดสอบสำหรับปลั๊กอิน

เอกสารนี้อธิบายวิธีการสร้างปลั๊กอินที่ใช้การทดสอบเป็นหลักซึ่งจะ:

* ขยายคลาส Ruby หลักเช่น Hash และ String
* เพิ่มเมธอดให้กับ `ApplicationRecord` ในแบบของปลั๊กอิน `acts_as`
* ให้ข้อมูลเกี่ยวกับที่จะวางตัวสร้างในปลั๊กอินของคุณ

สำหรับวัตถุประสงค์ของเอกสารนี้ สมมุติให้คุณเป็นนักสังคมนิยมการดูนก นกที่คุณชื่นชอบคือ Yaffle และคุณต้องการสร้างปลั๊กอินที่ช่วยให้นักพัฒนาคนอื่นสามารถแบ่งปันความสุขของ Yaffle ได้

--------------------------------------------------------------------------------

การติดตั้ง
-----

ปลั๊กอิน Rails ในปัจจุบันถูกสร้างเป็น gem, _gemified plugins_ สามารถแบ่งปันได้ในแอปพลิเคชัน Rails ต่างๆ โดยใช้ RubyGems และ Bundler ตามต้องการ

### สร้าง Gemified Plugin

Rails มาพร้อมกับคำสั่ง `rails plugin new` ซึ่งสร้างโครงสร้างพื้นฐานสำหรับการพัฒนาปลั๊กอินใดๆ ที่เกี่ยวข้องกับ Rails พร้อมทั้งสามารถรันการทดสอบการรวมกับ dummy Rails application ได้ สร้างปลั๊กอินของคุณด้วยคำสั่ง:

```bash
$ rails plugin new yaffle
```

ดูการใช้งานและตัวเลือกโดยการขอความช่วยเหลือ:

```bash
$ rails plugin new --help
```

การทดสอบปลั๊กอินที่สร้างขึ้นใหม่
-----------------------------------

ไปยังไดเรกทอรีที่มีปลั๊กอิน และแก้ไข `yaffle.gemspec` เพื่อแทนที่บรรทัดที่มีค่า `TODO`:

```ruby
spec.homepage    = "http://example.com"
spec.summary     = "Summary of Yaffle."
spec.description = "Description of Yaffle."

...

spec.metadata["source_code_uri"] = "http://example.com"
spec.metadata["changelog_uri"] = "http://example.com"
```

จากนั้นรันคำสั่ง `bundle install`

ตอนนี้คุณสามารถรันการทดสอบโดยใช้คำสั่ง `bin/test` และคุณควรเห็น:

```bash
$ bin/test
...
1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

นี้จะบอกให้คุณทราบว่าทุกอย่างถูกสร้างขึ้นอย่างถูกต้องและคุณพร้อมที่จะเริ่มเพิ่มฟังก์ชัน

ขยายคลาสหลัก
----------------------

ส่วนนี้จะอธิบายวิธีการเพิ่มเมธอดให้กับคลาส String ซึ่งจะสามารถใช้ได้ทุกที่ในแอปพลิเคชัน Rails ของคุณ

ในตัวอย่างนี้คุณจะเพิ่มเมธอดให้กับ String ที่ชื่อ `to_squawk` เพื่อเริ่มต้นสร้างไฟล์ทดสอบใหม่พร้อมกับการตรวจสอบบางสิ่ง:

```ruby
# yaffle/test/core_ext_test.rb

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase
  def test_to_squawk_prepends_the_word_squawk
    assert_equal "squawk! Hello World", "Hello World".to_squawk
  end
end
```

รัน `bin/test` เพื่อทดสอบ การทดสอบนี้ควรล้มเหลวเนื่องจากเรายังไม่ได้สร้างเมธอด `to_squawk`:

```bash
$ bin/test
E

Error:
CoreExtTest#test_to_squawk_prepends_the_word_squawk:
NoMethodError: undefined method `to_squawk' for "Hello World":String


bin/test /path/to/yaffle/test/core_ext_test.rb:4

.

Finished in 0.003358s, 595.6483 runs/s, 297.8242 assertions/s.
2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

เยี่ยมมาก - ตอนนี้คุณพร้อมที่จะเริ่มการพัฒนา
ใน `lib/yaffle.rb` เพิ่ม `require "yaffle/core_ext"`:

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"

module Yaffle
  # Your code goes here...
end
```

สุดท้ายสร้างไฟล์ `core_ext.rb` และเพิ่มเมธอด `to_squawk`:

```ruby
# yaffle/lib/yaffle/core_ext.rb

class String
  def to_squawk
    "squawk! #{self}".strip
  end
end
```

เพื่อทดสอบว่าเมธอดของคุณทำงานตามที่กล่าวไว้ ให้รันเทสหน่วยกับ `bin/test` จากไดเรกทอรีของปลั๊กอินของคุณ

```
$ bin/test
...
2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

เพื่อดูการทำงานของมัน ให้เปลี่ยนไปที่ไดเรกทอรี `test/dummy` เริ่ม `bin/rails console` และเริ่มการส่งเสียง:

```irb
irb> "Hello World".to_squawk
=> "squawk! Hello World"
```

เพิ่มเมธอด "acts_as" ให้กับ Active Record
----------------------------------------

รูปแบบที่พบบ่อยในปลั๊กอินคือการเพิ่มเมธอดที่เรียกว่า `acts_as_something` ในโมเดล ในกรณีนี้ คุณต้องการเขียนเมธอดที่เรียกว่า `acts_as_yaffle` ที่เพิ่มเมธอด `squawk` ให้กับโมเดล Active Record ของคุณ

เพื่อเริ่มต้น ตั้งค่าไฟล์ของคุณให้คุณมี:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
end
```

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"
require "yaffle/acts_as_yaffle"

module Yaffle
  # Your code goes here...
end
```

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
  end
end
```

### เพิ่มเมธอดคลาส

ปลั๊กอินนี้จะคาดหวังว่าคุณได้เพิ่มเมธอดในโมเดลของคุณที่ชื่อ `last_squawk` อยู่แล้ว อย่างไรก็ตาม ผู้ใช้ปลั๊กอินอาจได้กำหนดเมธอดชื่อ `last_squawk` บนโมเดลของพวกเขาไว้แล้วเพื่อใช้สำหรับสิ่งอื่น ปลั๊กอินนี้จะอนุญาตให้เปลี่ยนชื่อได้โดยการเพิ่มเมธอดคลาสที่ชื่อ `yaffle_text_field`

เพื่อเริ่มต้น เขียนเทสที่ล้มเหลวที่แสดงพฤติกรรมที่คุณต้องการ:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end
end
```

เมื่อคุณรัน `bin/test` คุณควรเห็นดังนี้:

```bash
$ bin/test
# Running:

..E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NameError: uninitialized constant ActsAsYaffleTest::Wickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NameError: uninitialized constant ActsAsYaffleTest::Hickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4



Finished in 0.004812s, 831.2949 runs/s, 415.6475 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

สิ่งนี้บอกให้เราทราบว่าเราไม่มีโมเดลที่จำเป็น (Hickwall และ Wickwall) ที่เรากำลังพยายามทดสอบ คุณสามารถสร้างโมเดลเหล่านี้ได้ง่ายๆ ในแอปพลิเคชัน Rails "dummy" ของคุณโดยการรันคำสั่งต่อไปนี้จากไดเรกทอรี `test/dummy`:

```bash
$ cd test/dummy
$ bin/rails generate model Hickwall last_squawk:string
$ bin/rails generate model Wickwall last_squawk:string last_tweet:string
```

ตอนนี้คุณสามารถสร้างตารางฐานข้อมูลที่จำเป็นในฐานข้อมูลทดสอบของคุณได้โดยไปที่แอป dummy และทำการ migrate ฐานข้อมูล ก่อนอื่น รัน:

```bash
$ cd test/dummy
$ bin/rails db:migrate
```

ในขณะที่คุณอยู่ที่นี่ เปลี่ยนโมเดล Hickwall และ Wickwall เพื่อให้รู้ว่าพวกเขาควรทำงานเหมือน yaffle

```ruby
# test/dummy/app/models/hickwall.rb

class Hickwall < ApplicationRecord
  acts_as_yaffle
end
```

```ruby
# test/dummy/app/models/wickwall.rb

class Wickwall < ApplicationRecord
  acts_as_yaffle yaffle_text_field: :last_tweet
end
```

เรายังจะเพิ่มโค้ดเพื่อกำหนดเมธอด `acts_as_yaffle`

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
      end
    end
  end
end
```
```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

จากนั้นคุณสามารถกลับไปที่ไดเรกทอรีหลัก (`cd ../..`) ของปลั๊กอินของคุณและรันการทดสอบอีกครั้งโดยใช้ `bin/test`.

```bash
$ bin/test
# Running:

.E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974ebbe9d8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4

E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974eb8cfc8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

.

Finished in 0.008263s, 484.0999 runs/s, 242.0500 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

ใกล้เสร็จแล้ว... ต่อไปเราจะนำเสนอโค้ดของเมธอด `acts_as_yaffle` เพื่อให้การทดสอบผ่าน

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

เมื่อคุณรัน `bin/test` คุณควรเห็นว่าการทดสอบผ่านทั้งหมด:

```bash
$ bin/test
...
4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### เพิ่มเมธอด Instance

ปลั๊กอินนี้จะเพิ่มเมธอดที่ชื่อว่า 'squawk' ให้กับอ็อบเจ็กต์ Active Record ใด ๆ ที่เรียกใช้ `acts_as_yaffle`  เมธอด 'squawk' จะเพียงแค่ตั้งค่าค่าของฟิลด์ในฐานข้อมูล

เพื่อเริ่มต้นเขียนการทดสอบที่ล้มเหลวที่แสดงพฤติกรรมที่คุณต้องการ:

```ruby
# yaffle/test/acts_as_yaffle_test.rb
require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end

  def test_hickwalls_squawk_should_populate_last_squawk
    hickwall = Hickwall.new
    hickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", hickwall.last_squawk
  end

  def test_wickwalls_squawk_should_populate_last_tweet
    wickwall = Wickwall.new
    wickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", wickwall.last_tweet
  end
end
```

รันการทดสอบเพื่อตรวจสอบว่าการทดสอบสองตัวสุดท้ายล้มเหลวพร้อมกับข้อผิดพลาดที่มี "NoMethodError: undefined method \`squawk'" จากนั้นอัปเดต `acts_as_yaffle.rb` เพื่อดูดังนี้:

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    included do
      def squawk(string)
        write_attribute(self.class.yaffle_text_field, string.to_squawk)
      end
    end

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

รัน `bin/test` อีกครั้งครับ และคุณควรเห็น:

```bash
$ bin/test
...
6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

หมายเหตุ: การใช้ `write_attribute` เพื่อเขียนไปยังฟิลด์ในโมเดลเป็นเพียงตัวอย่างเดียวของวิธีการที่ปลั๊กอินสามารถทำงานร่วมกับโมเดลได้ และอาจจะไม่ใช่เมธอดที่ถูกต้องตลอดเวลา ตัวอย่างเช่นคุณยังสามารถใช้:

```ruby
send("#{self.class.yaffle_text_field}=", string.to_squawk)
```

ตัวสร้าง
----------

ตัวสร้างสามารถรวมอยู่ใน gem ของคุณโดยเพียงแค่สร้างในไดเรกทอรี `lib/generators` ของปลั๊กอินของคุณ ข้อมูลเพิ่มเติมเกี่ยวกับการสร้างตัวสร้างสามารถหาได้ใน [Generators Guide](generators.html).

การเผยแพร่ Gem ของคุณ
-------------------

ปลั๊กอิน Gem ที่กำลังพัฒนาอยู่สามารถแบ่งปันได้ง่ายๆ จากทุก Git repository ให้แค่คุณ commit โค้ดไปยัง Git repository (เช่น GitHub) และเพิ่มบรรทัดใน `Gemfile` ของแอปพลิเคชันที่เกี่ยวข้อง:

```ruby
gem "yaffle", git: "https://github.com/rails/yaffle.git"
```

หลังจากที่รัน `bundle install` คุณจะสามารถใช้ความสามารถของ gem ในแอปพลิเคชันได้
เมื่อ gem เตรียมพร้อมที่จะเผยแพร่ในรูปแบบทางการ คุณสามารถเผยแพร่ไปยัง [RubyGems](https://rubygems.org) ได้

อีกทางเลือกคือคุณสามารถใช้ Bundler's Rake tasks ได้ คุณสามารถดูรายการเต็มได้ดังนี้:

```bash
$ bundle exec rake -T

$ bundle exec rake build
# สร้าง yaffle-0.1.0.gem ในไดเรกทอรี pkg

$ bundle exec rake install
# สร้างและติดตั้ง yaffle-0.1.0.gem เข้าสู่ระบบ gem

$ bundle exec rake release
# สร้างแท็ก v0.1.0 และสร้างและเผยแพร่ yaffle-0.1.0.gem ไปยัง Rubygems
```

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการเผยแพร่ gem ไปยัง RubyGems ดูที่: [การเผยแพร่ gem ของคุณ](https://guides.rubygems.org/publishing).

เอกสาร RDoc
------------------

เมื่อปลั๊กอินของคุณเสถียรและคุณพร้อมที่จะใช้งาน โปรดช่วยเพื่อความสะดวกของผู้อื่นโดยการเขียนเอกสาร! โชคดีที่การเขียนเอกสารสำหรับปลั๊กอินของคุณง่ายดาย

ขั้นแรกคือการอัปเดตไฟล์ README ด้วยข้อมูลที่ละเอียดเกี่ยวกับวิธีการใช้ปลั๊กอินของคุณ สิ่งที่ควรรวมอยู่บางส่วนคือ:

* ชื่อของคุณ
* วิธีการติดตั้ง
* วิธีการเพิ่มฟังก์ชันในแอป (ตัวอย่างหลายอย่างของการใช้งานที่พบบ่อย)
* คำเตือน ข้อควรระวังหรือเคล็ดลับที่อาจช่วยให้ผู้ใช้ประหยัดเวลา

เมื่อ README ของคุณเสร็จสมบูรณ์ ให้เพิ่มความคิดเห็น RDoc ในเมท็อดทั้งหมดที่นักพัฒนาจะใช้ นอกจากนี้ยังเป็นประจำที่จะเพิ่มความคิดเห็น `# :nodoc:` ในส่วนของรหัสที่ไม่ได้รวมอยู่ใน API สาธารณะ

เมื่อความคิดเห็นของคุณพร้อมแล้ว ไปที่ไดเรกทอรีของปลั๊กอินของคุณและเรียกใช้:

```bash
$ bundle exec rake rdoc
```

### อ้างอิง

* [การพัฒนา RubyGem โดยใช้ Bundler](https://github.com/radar/guides/blob/master/gem-development.md)
* [การใช้ .gemspecs ตามที่ตั้งใจ](https://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)
* [อ้างอิง Gemspec](https://guides.rubygems.org/specification-reference/)
