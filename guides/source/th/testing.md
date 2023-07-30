**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 6da9945dc313b748574b8aca256f1435
การทดสอบแอปพลิเคชัน Rails
==========================

เอกสารนี้เป็นการครอบคลุมกลไกที่มีอยู่ใน Rails สำหรับการทดสอบแอปพลิเคชันของคุณ

หลังจากอ่านเอกสารนี้คุณจะรู้:

* คำศัพท์ทดสอบใน Rails
* วิธีการเขียนเทสหน่วย (unit), เทสฟังก์ชัน (functional), เทสอินทิเกรชัน (integration), และเทสระบบ (system) สำหรับแอปพลิเคชันของคุณ
* วิธีการทดสอบอื่นๆ ที่ได้รับความนิยมและปลั๊กอิน

--------------------------------------------------------------------------------

ทำไมต้องเขียนเทสสำหรับแอปพลิเคชัน Rails ของคุณ?
--------------------------------------------

Rails ทำให้การเขียนเทสง่ายมาก โดยเริ่มต้นด้วยการสร้างโค้ดเทสพื้นฐานขณะคุณกำลังสร้างโมเดลและคอนโทรลเลอร์ของคุณ

การรันเทส Rails ช่วยให้คุณสามารถตรวจสอบว่าโค้ดของคุณปฏิบัติตามฟังก์ชันที่ต้องการได้ แม้จะมีการเปลี่ยนโค้ดใหญ่

เทส Rails ยังสามารถจำลองคำขอจากเบราว์เซอร์ได้ ดังนั้นคุณสามารถทดสอบการตอบสนองของแอปพลิเคชันของคุณโดยไม่ต้องทดสอบผ่านเบราว์เซอร์

แนะนำการทดสอบ
-----------------------

การสนับสนุนการทดสอบถูกผสมผสานเข้ากับ Rails ตั้งแต่เริ่มต้น ไม่ใช่ "โอ้! เรามาเพิ่มการสนับสนุนในการรันเทสเพราะมันใหม่และเจ๋ง" แน่นอน

### Rails ตั้งค่าสำหรับการทดสอบตั้งแต่ต้น

Rails สร้างไดเรกทอรี `test` ให้คุณเมื่อคุณสร้างโปรเจกต์ Rails โดยใช้ `rails new` _application_name_ หากคุณแสดงรายการเนื้อหาของไดเรกทอรีนี้คุณจะเห็น:

```bash
$ ls -F test
application_system_test_case.rb  controllers/                     helpers/                         mailers/                         system/
channels/                        fixtures/                        integration/                     models/                          test_helper.rb
```

ไดเรกทอรี `helpers`, `mailers`, และ `models` ใช้เก็บเทสสำหรับวิวเฮลเปอร์, เมลเลอร์, และโมเดลตามลำดับ ไดเรกทอรี `channels` ใช้เก็บเทสสำหรับการเชื่อมต่อและช่องของ Action Cable ไดเรกทอรี `controllers` ใช้เก็บเทสสำหรับคอนโทรลเลอร์, เส้นทาง, และวิว ไดเรกทอรี `integration` ใช้เก็บเทสสำหรับการตอบสนองระหว่างคอนโทรลเลอร์

ไดเรกทอรีเทสระบบเก็บเทสระบบที่ใช้สำหรับการทดสอบแบบเบราว์เซอร์เต็มรูปแบบของแอปพลิเคชันของคุณ เทสระบบช่วยให้คุณทดสอบแอปพลิเคชันของคุณได้เหมือนกับผู้ใช้ประสบการณ์จริงและช่วยให้คุณทดสอบ JavaScript ของคุณด้วย เทสระบบสืบทอดมาจาก Capybara และทำการทดสอบในเบราว์เซอร์สำหรับแอปพลิเคชันของคุณ

Fixtures เป็นวิธีการจัดระเบียบข้อมูลทดสอบ และอยู่ในไดเรกทอรี `fixtures`

ไดเรกทอรี `jobs` จะถูกสร้างขึ้นเมื่อเทสที่เกี่ยวข้องถูกสร้างครั้งแรก

ไฟล์ `test_helper.rb` เก็บการกำหนดค่าเริ่มต้นสำหรับเทสของคุณ

ไฟล์ `application_system_test_case.rb` เก็บการกำหนดค่าเริ่มต้นสำหรับเทสระบบของคุณ

### สภาพแวดล้อมการทดสอบ

ตามค่าเริ่มต้นแล้วแอปพลิเคชัน Rails มีสามสภาพแวดล้อม: development, test, และ production

สามารถแก้ไขการกำหนดค่าสภาพแวดล้อมแต่ละอันได้เช่นกัน ในกรณีนี้เราสามารถแก้ไขสภาพแวดล้อมการทดสอบของเราได้โดยเปลี่ยนตัวเลือกที่พบใน `config/environments/test.rb`

หมายเหตุ: เทสของคุณถูกรันภายใต้ `RAILS_ENV=test`

### Rails พบกับ Minitest

หากคุณจำได้เราใช้คำสั่ง `bin/rails generate model` ในเอกสาร [เริ่มต้นกับ Rails](getting_started.html) เราสร้างโมเดลแรกของเรา และระหว่างอื่นๆ มันสร้างสแต็ปเทสในไดเรกทอรี `test`:

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

สแต็ปเทสเริ่มต้นใน `test/models/article_test.rb` มีลักษณะดังนี้:

```ruby
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

การตรวจสอบไฟล์นี้ทีละบรรทัดจะช่วยให้คุณเข้าใจโค้ดและคำศัพท์การทดสอบของ Rails
```ruby
require "test_helper"
```

โดยการเรียกใช้ไฟล์นี้ `test_helper.rb` ค่าการกำหนดค่าเริ่มต้นในการเรียกใช้งานทดสอบของเราจะถูกโหลด เราจะรวมไฟล์นี้กับทุกโทดสอบที่เราเขียน เพื่อให้เมธอดที่เพิ่มเข้าไปในไฟล์นี้สามารถใช้งานได้ในทุกโทดสอบของเรา

```ruby
class ArticleTest < ActiveSupport::TestCase
```

คลาส `ArticleTest` กำหนด _test case_ เนื่องจากมันสืบทอดมาจาก `ActiveSupport::TestCase` `ArticleTest` จึงมีเมธอดทั้งหมดที่มีอยู่ใน `ActiveSupport::TestCase` ในส่วนท้ายของเอกสารนี้ เราจะเห็นบางเมธอดที่มันให้เราใช้งาน

เมื่อกำหนดเมธอดภายในคลาสที่สืบทอดมาจาก `Minitest::Test` (ซึ่งเป็น superclass ของ `ActiveSupport::TestCase`) และขึ้นต้นด้วย `test_` จะถือว่าเป็นเมธอดทดสอบ ดังนั้น เมธอดที่กำหนดเป็น `test_password` และ `test_valid_password` จะถือว่าเป็นชื่อเมธอดทดสอบที่ถูกต้องและจะถูกเรียกใช้งานโดยอัตโนมัติเมื่อทดสอบถูกเรียกใช้งาน

Rails ยังเพิ่มเมธอด `test` ที่รับชื่อเมธอดทดสอบและบล็อก มันจะสร้างเทส `Minitest::Unit` ปกติที่มีชื่อเมธอดที่เริ่มต้นด้วย `test_` ดังนั้นคุณไม่ต้องกังวลเรื่องการตั้งชื่อเมธอด และคุณสามารถเขียนอย่างนี้ได้:

```ruby
test "the truth" do
  assert true
end
```

ซึ่งเป็นเทียบเท่ากับการเขียนนี้:

```ruby
def test_the_truth
  assert true
end
```

แม้ว่าคุณสามารถใช้การกำหนดเมธอดแบบปกติได้ การใช้ macro `test` ช่วยให้ชื่อเมธอดทดสอบอ่านง่ายขึ้น

หมายเหตุ: ชื่อเมธอดถูกสร้างโดยการแทนที่ช่องว่างด้วยขีดล่าง ผลลัพธ์ไม่จำเป็นต้องเป็นตัวระบุ Ruby ที่ถูกต้อง แต่ชื่ออาจมีอักขระเครื่องหมายวรรคตอน ฯลฯ เนื่องจากใน Ruby ทางเทคนิค สตริงใดๆ อาจเป็นชื่อเมธอดได้ นี่อาจต้องการใช้ `define_method` และการเรียกใช้ `send` เพื่อให้ทำงานอย่างถูกต้อง แต่ในทางปฏิบัตินั้นไม่มีข้อจำกัดในการตั้งชื่อ

ต่อไปเรามาดูการตรวจสอบครั้งแรกของเรา:

```ruby
assert true
```

การตรวจสอบคือบรรทัดของโค้ดที่ประเมินวัตถุ (หรือนิพจน์) สำหรับผลลัพธ์ที่คาดหวัง ตัวอย่างเช่นการตรวจสอบสามารถตรวจสอบได้ว่า:

* ค่านี้เท่ากับค่านั้นหรือไม่?
* วัตถุนี้เป็น nil หรือไม่?
* บรรทัดโค้ดนี้จะส่ง exception หรือไม่?
* รหัสผ่านของผู้ใช้มีความยาวมากกว่า 5 ตัวอักษรหรือไม่?

ทุกโทดสอบอาจมีการตรวจสอบหนึ่งหรือมากกว่าหนึ่ง โดยไม่มีข้อจำกัดว่าจะต้องมีการตรวจสอบเท่าไหร่ โดยเมื่อทุกการตรวจสอบผ่านทุกตัวจะทำให้ทดสอบผ่าน

#### การทดสอบที่ล้มเหลวครั้งแรกของคุณ

เพื่อดูว่าการล้มเหลวในการทดสอบถูกรายงานอย่างไร คุณสามารถเพิ่มการทดสอบที่ล้มเหลวใน `article_test.rb` ไฟล์ทดสอบ

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save
end
```

ให้เราเรียกใช้งานทดสอบที่เพิ่มเข้ามาใหม่นี้ (โดยที่ `6` เป็นหมายเลขบรรทัดที่กำหนดการทดสอบ)

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 44656

# Running:

F

Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Expected true to be nil or false


bin/rails test test/models/article_test.rb:6



Finished in 0.023918s, 41.8090 runs/s, 41.8090 assertions/s.

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
```

ในผลลัพธ์ `F` แสดงถึงความล้มเหลว คุณสามารถเห็นการติดตามที่เกี่ยวข้องที่แสดงในส่วนของ `Failure` พร้อมกับชื่อของการทดสอบที่ล้มเหลว บรรทัดถัดไปประกอบด้วย stack trace ตามด้วยข้อความที่กล่าวถึงค่าจริงและค่าที่คาดหวังโดยการตรวจสอบ ข้อความที่เกี่ยวกับการล้มเหลวของการตรวจสอบให้ข้อมูลเพียงพอเพื่อช่วยให้ระบุข้อผิดพลาด ในการทำให้ข้อความการล้มเหลวของการตรวจสอบอ่านง่ายขึ้น เมื่อตรวจสอบล้มเหลว การตรวจสอบทุกๆ อย่างจะให้พารามิเตอร์ข้อความที่เพิ่มเติม ดังที่แสดงในตัวอย่างนี้:
```ruby
test "ไม่ควรบันทึกบทความโดยไม่มีชื่อ" do
  article = Article.new
  assert_not article.save, "บันทึกบทความโดยไม่มีชื่อ"
end
```

การรันทดสอบนี้จะแสดงข้อความการตรวจสอบที่เป็นมิตรมากขึ้น:

```
ความล้มเหลว:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
บันทึกบทความโดยไม่มีชื่อ
```

ตอนนี้เราสามารถทำให้ทดสอบผ่านได้โดยเพิ่มการตรวจสอบระดับโมเดลสำหรับฟิลด์ _title_.

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

ตอนนี้ทดสอบควรผ่าน ให้เราทำการตรวจสอบอีกครั้ง:

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 31252

# Running:

.

Finished in 0.027476s, 36.3952 runs/s, 36.3952 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

ตอนนี้หากคุณสังเกตเห็นเราเขียนทดสอบที่ล้มเหลวสำหรับฟังก์ชันที่ต้องการไว้ก่อน จากนั้นเราเขียนโค้ดที่เพิ่มฟังก์ชันนั้นและในที่สุดเราตรวจสอบให้แน่ใจว่าทดสอบผ่าน การพัฒนาซอฟต์แวร์ด้วยวิธีนี้เรียกว่า
[_Test-Driven Development_ (TDD)](http://c2.com/cgi/wiki?TestDrivenDevelopment).

#### รูปแบบของข้อผิดพลาด

เพื่อดูว่าข้อผิดพลาดถูกรายงานอย่างไร นี่คือทดสอบที่มีข้อผิดพลาด:

```ruby
test "ควรรายงานข้อผิดพลาด" do
  # some_undefined_variable ไม่ได้ถูกกำหนดค่าในส่วนอื่นของกรณีทดสอบ
  some_undefined_variable
  assert true
end
```

ตอนนี้คุณสามารถเห็นผลลัพธ์เพิ่มเติมในคอนโซลจากการรันทดสอบ:

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1808

# Running:

.E

Error:
ArticleTest#test_should_report_error:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9



Finished in 0.040609s, 49.2500 runs/s, 24.6250 assertions/s.

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

สังเกต 'E' ในผลลัพธ์ แสดงว่ามีการทดสอบที่มีข้อผิดพลาด

หมายเหตุ: การรันของแต่ละเมธอดทดสอบจะหยุดทันทีที่พบข้อผิดพลาดหรือการล้มเหลวในการตรวจสอบ และชุดทดสอบจะดำเนินการต่อด้วยเมธอดถัดไป ทุกเมธอดทดสอบจะถูกดำเนินการในลำดับสุ่ม ตัวเลือก [`config.active_support.test_order`][] สามารถใช้กำหนดลำดับการทดสอบได้

เมื่อทดสอบล้มเหลวคุณจะได้รับการแสดงผลของ backtrace ที่เกี่ยวข้อง โดยค่าเริ่มต้น Rails จะกรอง backtrace นั้นและจะพิมพ์เฉพาะบรรทัดที่เกี่ยวข้องกับแอปพลิเคชันของคุณ เพื่อลดเสียงรบกวนของเฟรมเวิร์คและช่วยให้โฟกัสกับโค้ดของคุณ อย่างไรก็ตาม มีสถานการณ์บางครั้งที่คุณต้องการดู backtrace เต็มรูปแบบ ให้ตั้งค่าอาร์กิวเมนต์ `-b` (หรือ `--backtrace`) เพื่อเปิดใช้งานพฤติกรรมนี้:

```bash
$ bin/rails test -b test/models/article_test.rb
```

หากเราต้องการให้ทดสอบนี้ผ่าน เราสามารถแก้ไขโดยใช้ `assert_raises` ดังนี้:

```ruby
test "ควรรายงานข้อผิดพลาด" do
  # some_undefined_variable ไม่ได้ถูกกำหนดค่าในส่วนอื่นของกรณีทดสอบ
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

ทดสอบนี้ควรผ่านเดี๋ยวนี้


### การตรวจสอบที่มีอยู่

ตอนนี้คุณได้เห็นการตรวจสอบบางส่วนที่มีอยู่แล้ว การตรวจสอบเป็นคนงานในการทดสอบ มันทำงานจริงๆ เพื่อตรวจสอบว่าสิ่งที่เกิดขึ้นได้ตามที่วางแผนไว้

นี่คือส่วนหนึ่งของการตรวจสอบที่คุณสามารถใช้ได้กับ
[`Minitest`](https://github.com/minitest/minitest) ไลบรารีการทดสอบเริ่มต้นที่ใช้กับ Rails. พารามิเตอร์ `[msg]` เป็นสตริงข้อความที่ไม่บังคับที่คุณสามารถระบุเพื่อทำให้ข้อความข้อผิดพลาดของการทดสอบชัดเจนขึ้น.
| การยืนยัน                                                       | วัตถุประสงค์ |
| ---------------------------------------------------------------- | ------- |
| `assert( test, [msg] )`                                          | ให้แน่ใจว่า `test` เป็นจริง |
| `assert_not( test, [msg] )`                                      | ให้แน่ใจว่า `test` เป็นเท็จ |
| `assert_equal( expected, actual, [msg] )`                        | ให้แน่ใจว่า `expected == actual` เป็นจริง |
| `assert_not_equal( expected, actual, [msg] )`                    | ให้แน่ใจว่า `expected != actual` เป็นจริง |
| `assert_same( expected, actual, [msg] )`                         | ให้แน่ใจว่า `expected.equal?(actual)` เป็นจริง |
| `assert_not_same( expected, actual, [msg] )`                     | ให้แน่ใจว่า `expected.equal?(actual)` เป็นเท็จ |
| `assert_nil( obj, [msg] )`                                       | ให้แน่ใจว่า `obj.nil?` เป็นจริง |
| `assert_not_nil( obj, [msg] )`                                   | ให้แน่ใจว่า `obj.nil?` เป็นเท็จ |
| `assert_empty( obj, [msg] )`                                     | ให้แน่ใจว่า `obj` เป็น `empty?` |
| `assert_not_empty( obj, [msg] )`                                 | ให้แน่ใจว่า `obj` ไม่เป็น `empty?` |
| `assert_match( regexp, string, [msg] )`                          | ให้แน่ใจว่าสตริงตรงกับนิพจน์ปรกติ |
| `assert_no_match( regexp, string, [msg] )`                       | ให้แน่ใจว่าสตริงไม่ตรงกับนิพจน์ปรกติ |
| `assert_includes( collection, obj, [msg] )`                      | ให้แน่ใจว่า `obj` อยู่ใน `collection` |
| `assert_not_includes( collection, obj, [msg] )`                  | ให้แน่ใจว่า `obj` ไม่อยู่ใน `collection` |
| `assert_in_delta( expected, actual, [delta], [msg] )`            | ให้แน่ใจว่าตัวเลข `expected` และ `actual` อยู่ในระยะ `delta` ของกัน |
| `assert_not_in_delta( expected, actual, [delta], [msg] )`        | ให้แน่ใจว่าตัวเลข `expected` และ `actual` ไม่อยู่ในระยะ `delta` ของกัน |
| `assert_in_epsilon ( expected, actual, [epsilon], [msg] )`       | ให้แน่ใจว่าตัวเลข `expected` และ `actual` มีความคลาดเคลื่อนที่เป็นค่าสัมพันธ์น้อยกว่า `epsilon` |
| `assert_not_in_epsilon ( expected, actual, [epsilon], [msg] )`   | ให้แน่ใจว่าตัวเลข `expected` และ `actual` มีความคลาดเคลื่อนที่เป็นค่าสัมพันธ์ไม่น้อยกว่า `epsilon` |
| `assert_throws( symbol, [msg] ) { block }`                       | ให้แน่ใจว่าบล็อกที่กำหนดจะโยนสัญลักษณ์ |
| `assert_raises( exception1, exception2, ... ) { block }`         | ให้แน่ใจว่าบล็อกที่กำหนดจะเรียกขึ้นข้อยกเว้นหนึ่งในข้อยกเว้นที่กำหนด |
| `assert_instance_of( class, obj, [msg] )`                        | ให้แน่ใจว่า `obj` เป็นอินสแตนซ์ของ `class` |
| `assert_not_instance_of( class, obj, [msg] )`                    | ให้แน่ใจว่า `obj` ไม่เป็นอินสแตนซ์ของ `class` |
| `assert_kind_of( class, obj, [msg] )`                            | ให้แน่ใจว่า `obj` เป็นอินสแตนซ์ของ `class` หรือลูกสาวของมัน |
| `assert_not_kind_of( class, obj, [msg] )`                        | ให้แน่ใจว่า `obj` ไม่เป็นอินสแตนซ์ของ `class` และไม่ได้ลงทะเบียน |
| `assert_respond_to( obj, symbol, [msg] )`                        | ให้แน่ใจว่า `obj` ตอบสนองต่อ `symbol` |
| `assert_not_respond_to( obj, symbol, [msg] )`                    | ให้แน่ใจว่า `obj` ไม่ตอบสนองต่อ `symbol` |
| `assert_operator( obj1, operator, [obj2], [msg] )`               | ให้แน่ใจว่า `obj1.operator(obj2)` เป็นจริง |
| `assert_not_operator( obj1, operator, [obj2], [msg] )`           | ให้แน่ใจว่า `obj1.operator(obj2)` เป็นเท็จ |
| `assert_predicate ( obj, predicate, [msg] )`                     | ให้แน่ใจว่า `obj.predicate` เป็นจริง เช่น `assert_predicate str, :empty?` |
| `assert_not_predicate ( obj, predicate, [msg] )`                 | ให้แน่ใจว่า `obj.predicate` เป็นเท็จ เช่น `assert_not_predicate str, :empty?` |
| `flunk( [msg] )`                                                 | ให้แน่ใจว่าล้มเหลว นี้เป็นประโยชน์ในการระบุแบบชัดเจนว่าทดสอบนี้ยังไม่เสร็จสมบูรณ์ |

สิ่งที่ได้กล่าวมาข้างต้นเป็นส่วนหนึ่งของการยืนยันที่ minitest สนับสนุน สำหรับรายการที่ครอบคลุมทั้งหมดและที่อัปเดตล่าสุดโปรดตรวจสอบ
[เอกสาร API ของ Minitest](http://docs.seattlerb.org/minitest/) โดยเฉพาะ
[`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html).
เนื่องจากโครงสร้างของเฟรมเวิร์กการทดสอบเป็นโมดูล จึงเป็นไปได้ที่จะสร้างการตรวจสอบของคุณเอง ในความเป็นจริง นั่นคือสิ่งที่ Rails ทำ มันรวมการตรวจสอบที่เฉพาะเจาะจงบางอย่างเพื่อทำให้ชีวิตของคุณง่ายขึ้น

หมายเหตุ: การสร้างการตรวจสอบของคุณเองเป็นหัวข้อขั้นสูงที่เราจะไม่พูดถึงในบทแนะนำนี้

### การตรวจสอบที่เฉพาะเจาะจงของ Rails

Rails เพิ่มการตรวจสอบที่กำหนดเองลงในเฟรมเวิร์ก `minitest`:

| การตรวจสอบ                                                                         | วัตถุประสงค์ |
| --------------------------------------------------------------------------------- | ------- |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | ทดสอบความแตกต่างทางตัวเลขระหว่างค่าที่ส่งกลับจากนิพจน์เนื่องจากสิ่งที่ประเมินในบล็อกที่ส่งคืน |
| [`assert_no_difference(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | ยืนยันว่าผลลัพธ์ทางตัวเลขจากการประเมินนิพจน์ไม่เปลี่ยนแปลงก่อนและหลังเรียกใช้บล็อกที่ส่ง |
| [`assert_changes(expressions, message = nil, from:, to:, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes) | ทดสอบว่าผลลัพธ์จากการประเมินนิพจน์เปลี่ยนแปลงหลังจากเรียกใช้บล็อกที่ส่ง |
| [`assert_no_changes(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes) | ทดสอบว่าผลลัพธ์จากการประเมินนิพจน์ไม่เปลี่ยนแปลงหลังจากเรียกใช้บล็อกที่ส่ง |
| [`assert_nothing_raised { block }`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised) | ตรวจสอบว่าบล็อกที่กำหนดไม่เกิดข้อยกเว้นใด ๆ |
| [`assert_recognizes(expected_options, path, extras={}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | ยืนยันว่าการเรียกใช้เส้นทางของเส้นทางที่กำหนดได้รับการจัดการอย่างถูกต้องและตัวเลือกที่ถูกแยกวิเคราะห์ (ที่กำหนดในแฮช expected_options) ตรงกับเส้นทาง โดยพื้นฐานแล้ว มันยืนยันว่า Rails รู้จักเส้นทางที่กำหนดโดย expected_options |
| [`assert_generates(expected_path, options, defaults={}, extras = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | ยืนยันว่าตัวเลือกที่ให้ได้รับการใช้สร้างเส้นทางที่ให้ได้ นี่คือการกลับของ assert_recognizes พารามิเตอร์ extras ใช้เพื่อบอกของร้องขอชื่อและค่าของพารามิเตอร์เพิ่มเติมที่จะอยู่ในสตริงคิวรี พารามิเตอร์ message ช่วยให้คุณระบุข้อความข้อผิดพลาดที่กำหนดเองสำหรับการล้มเหลวในการยืนยัน |
| [`assert_response(type, message = nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | ยืนยันว่าการตอบสนองมาพร้อมกับรหัสสถานะที่กำหนดเอง คุณสามารถระบุ `:success` เพื่อแสดงถึง 200-299, `:redirect` เพื่อแสดงถึง 300-399, `:missing` เพื่อแสดงถึง 404 หรือ `:error` เพื่อจับคู่กับช่วง 500-599 คุณยังสามารถส่งเลขสถานะแบบชัดเจนหรือเทียบเท่าได้ สำหรับข้อมูลเพิ่มเติม ดูที่ [รายการสถานะทั้งหมด](https://rubydoc.info/gems/rack/Rack/Utils#HTTP_STATUS_CODES-constant) และวิธีการ [แมป](https://rubydoc.info/gems/rack/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant) ทำงานของพวกเขา |
| [`assert_redirected_to(options = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | ยืนยันว่าการตอบสนองเป็นการเปลี่ยนเส้นทางไปยัง URL ที่ตรงกับตัวเลือกที่กำหนด คุณยังสามารถส่งเส้นทางที่มีชื่อเป็นพารามิเตอร์ เช่น `assert_redirected_to root_path` และออบเจกต์ Active Record เช่น `assert_redirected_to @article` |

คุณจะเห็นการใช้งานของบางการตรวจสอบเหล่านี้ในบทถัดไป

### บันทึกสั้นเกี่ยวกับกรณีทดสอบ

การตรวจสอบพื้นฐานทั้งหมดเช่น `assert_equal` ที่กำหนดใน `Minitest::Assertions` ก็มีให้ใช้ในคลาสที่เราใช้ในกรณีทดสอบของเราเอง ในความเป็นจริง Rails จัดหาคลาสต่อไปนี้ให้คุณสืบทอด:

* [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](https://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::IntegrationTest`](https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActionDispatch::SystemTestCase`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](https://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

แต่ละคลาสเหล่านี้รวมถึง `Minitest::Assertions` ทำให้เราสามารถใช้การตรวจสอบพื้นฐานทั้งหมดในการทดสอบของเราได้

หมายเหตุ: สำหรับข้อมูลเพิ่มเติมเกี่ยวกับ `Minitest` อ่านเอกสารของมันได้ที่ [เอกสาร](http://docs.seattlerb.org/minitest)
### ตัวรันการทดสอบของ Rails

เราสามารถรันทดสอบทั้งหมดในครั้งเดียวโดยใช้คำสั่ง `bin/rails test` 

หรือเราสามารถรันไฟล์ทดสอบเดียวโดยส่งคำสั่ง `bin/rails test` พร้อมกับชื่อไฟล์ที่มีกรณีทดสอบ

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1559

# Running:

..

Finished in 0.027034s, 73.9810 runs/s, 110.9715 assertions/s.

2 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

นี้จะรันเมทอดทดสอบทั้งหมดจากกรณีทดสอบ

คุณยังสามารถรันเมทอดทดสอบเฉพาะจากกรณีทดสอบโดยใช้ตัวบอก `-n` หรือ `--name` และชื่อเมทอดทดสอบ

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Run options: -n test_the_truth --seed 43583

# Running:

.

Finished tests in 0.009064s, 110.3266 tests/s, 110.3266 assertions/s.

1 tests, 1 assertions, 0 failures, 0 errors, 0 skips
```

คุณยังสามารถรันทดสอบที่บรรทัดที่กำหนดได้โดยให้เลขบรรทัด

```bash
$ bin/rails test test/models/article_test.rb:6 # รันทดสอบและบรรทัดที่กำหนด
```

คุณยังสามารถรันไดเรกทอรีทั้งหมดของทดสอบโดยให้เส้นทางไปยังไดเรกทอรี

```bash
$ bin/rails test test/controllers # รันทดสอบทั้งหมดจากไดเรกทอรีที่กำหนด
```

ตัวรันการทดสอบยังมีคุณสมบัติอื่น ๆ อีกมากมาย เช่น การรายงานผลลัพธ์ที่ผิดพลาดเร็ว การเลื่อนการแสดงผลของทดสอบไปยังท้ายการรันทดสอบ เป็นต้น โปรดตรวจสอบเอกสารของตัวรันการทดสอบดังต่อไปนี้:

```bash
$ bin/rails test -h
Usage: rails test [options] [files or directories]

You can run a single test by appending a line number to a filename:

    bin/rails test test/models/user_test.rb:27

You can run multiple files and directories at the same time:

    bin/rails test test/controllers test/integration/login_test.rb

By default test failures and errors are reported inline during a run.

minitest options:
    -h, --help                       Display this help.
        --no-plugins                 Bypass minitest plugin auto-loading (or set $MT_NO_PLUGINS).
    -s, --seed SEED                  Sets random seed. Also via env. Eg: SEED=n rake
    -v, --verbose                    Verbose. Show progress processing files.
    -n, --name PATTERN               Filter run on /regexp/ or string.
        --exclude PATTERN            Exclude /regexp/ or string from run.

Known extensions: rails, pride
    -w, --warnings                   Run with Ruby warnings enabled
    -e, --environment ENV            Run tests in the ENV environment
    -b, --backtrace                  Show the complete backtrace
    -d, --defer-output               Output test failures and errors after the test run
    -f, --fail-fast                  Abort test run on first failure or error
    -c, --[no-]color                 Enable color in the output
    -p, --pride                      Pride. Show your testing pride!
```

### การรันทดสอบใน Continuous Integration (CI)

ในการรันทดสอบทั้งหมดในสภาพแวดล้อม CI มีเพียงคำสั่งเดียวที่คุณต้องการ:

```bash
$ bin/rails test
```

หากคุณกำลังใช้ [System Tests](#system-testing) `bin/rails test` จะไม่รันเนื่องจากมันอาจช้า ในการรันทดสอบเหล่านี้ ให้เพิ่มขั้นตอน CI อีกขั้นที่รัน `bin/rails test:system` หรือเปลี่ยนขั้นตอนแรกของคุณเป็น `bin/rails test:all` ซึ่งรันทดสอบทั้งหมดรวมถึงทดสอบระบบ
### การทดสอบแบบขนานด้วยกระบวนการ

วิธีการแบ่งการทำงานแบบขนานเริ่มต้นคือการแบ่งกระบวนการโดยใช้ระบบ DRb ของ Ruby กระบวนการจะถูกแบ่งตามจำนวนของ workers ที่ระบุ จำนวนเริ่มต้นคือจำนวนคอร์ที่มีจริงในเครื่องที่คุณใช้อยู่ แต่สามารถเปลี่ยนแปลงได้โดยการระบุจำนวนในเมธอด parallelize

ในการเปิดใช้งานการแบ่งการทำงานแบบขนานให้เพิ่มโค้ดต่อไปนี้ใน `test_helper.rb`:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

จำนวน workers ที่ระบุคือจำนวนครั้งที่กระบวนการจะถูกแบ่ง คุณอาจต้องการแบ่งการทดสอบในเครื่องทดสอบท้องถิ่นของคุณแตกต่างจาก CI ดังนั้นจึงมีตัวแปรสภาพแวดล้อมที่ให้ใช้เพื่อเปลี่ยนแปลงจำนวน workers ที่การทดสอบควรใช้:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

เมื่อทำการแบ่งการทดสอบแบบขนาน Active Record จะดำเนินการสร้างฐานข้อมูลและโหลด schema ลงในฐานข้อมูลสำหรับแต่ละกระบวนการโดยอัตโนมัติ ฐานข้อมูลจะมีคำต่อท้ายด้วยตัวเลขที่สอดคล้องกับ worker ตัวอย่างเช่นหากคุณมี workers 2 การทดสอบจะสร้าง `test-database-0` และ `test-database-1` ตามลำดับ

หากจำนวน workers ที่ระบุเป็น 1 หรือน้อยกว่า กระบวนการจะไม่ถูกแบ่งและการทดสอบจะไม่ถูกแบ่งและการทดสอบจะใช้ฐานข้อมูล `test-database` เดิม

มีการให้บริการสอง hooks หนึ่งรันเมื่อกระบวนการถูกแบ่งและหนึ่งรันก่อนที่กระบวนการที่แบ่งจะถูกปิด สามารถใช้งานได้เมื่อแอปของคุณใช้งานฐานข้อมูลหลายรายการหรือดำเนินการอื่น ๆ ที่ขึ้นอยู่กับจำนวน workers

เมื่อกระบวนการถูกแบ่ง `parallelize_setup` จะถูกเรียกใช้งานทันทีหลังจากกระบวนการถูกแบ่ง และ `parallelize_teardown` จะถูกเรียกใช้งานทันทีก่อนที่กระบวนการจะถูกปิด

```ruby
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # ตั้งค่าฐานข้อมูล
  end

  parallelize_teardown do |worker|
    # ล้างฐานข้อมูล
  end

  parallelize(workers: :number_of_processors)
end
```

ไม่จำเป็นต้องใช้หรือใช้ได้เมื่อใช้การทดสอบแบบขนานด้วย threads

### การทดสอบแบบขนานด้วย Threads

หากคุณต้องการใช้งาน threads หรือใช้ JRuby มีตัวเลือกการแบ่งการทำงานแบบขนานด้วย threads ที่มีการให้บริการ การแบ่งการทำงานแบบขนานด้วย threads นี้ใช้ Minitest's `Parallel::Executor` เป็นพื้นฐาน

ในการเปลี่ยนแปลงวิธีการแบ่งการทำงานแบบขนานให้ใช้ threads แทน forks ให้เพิ่มโค้ดต่อไปนี้ใน `test_helper.rb`

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)
end
```

แอปพลิเคชัน Rails ที่สร้างจาก JRuby หรือ TruffleRuby จะรวมตัวเลือก `with: :threads` โดยอัตโนมัติ

จำนวน workers ที่ระบุใน `parallelize` กำหนดจำนวน threads ที่การทดสอบจะใช้ คุณอาจต้องการแบ่งการทดสอบในเครื่องทดสอบท้องถิ่นของคุณแตกต่างจาก CI ดังนั้นจึงมีตัวแปรสภาพแวดล้อมที่ให้ใช้เพื่อเปลี่ยนแปลงจำนวน workers ที่การทดสอบควรใช้:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

### การทดสอบการทำธุรกรรมแบบขนาน

Rails จะครอบคลุมการทดสอบในธุรกรรมฐานข้อมูลที่จะถูกยกเลิกหลังจากที่ทดสอบเสร็จสิ้น สิ่งนี้ทำให้การทดสอบเป็นอิสระต่อกันและการเปลี่ยนแปลงในฐานข้อมูลจะมองเห็นเฉพาะในการทดสอบเดียว

เมื่อคุณต้องการทดสอบโค้ดที่ทำธุรกรรมแบบขนานใน threads ธุรกรรมอาจบล็อกกันเนื่องจากมีการซ้อนซ้อนภายใต้ธุรกรรมการทดสอบแล้ว

คุณสามารถปิดใช้งานธุรกรรมในคลาสของกรณีทดสอบโดยตั้งค่า `self.use_transactional_tests = false`:
```ruby
class WorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "parallel transactions" do
    # เริ่มเธรดที่สร้างการทำธุรกรรม
  end
end
```

หมายเหตุ: เมื่อปิดการใช้งานการทดสอบแบบทรานแซกชัน, คุณต้องทำความสะอาดข้อมูลทดสอบที่สร้างขึ้นเนื่องจากการเปลี่ยนแปลงจะไม่ถูกยกเลิกโดยอัตโนมัติหลังจากทดสอบเสร็จสิ้น

### ค่าเกณฑ์สำหรับการทำงานขนานของการทดสอบ

การทดสอบที่ทำงานขนานเพิ่มความซับซ้อนในเชิงประสิทธิภาพในการติดตั้งฐานข้อมูลและโหลดข้อมูลทดสอบ ดังนั้น Rails จะไม่ทำการทำงานขนานในกรณีที่มีการทดสอบน้อยกว่า 50 รายการ

คุณสามารถกำหนดค่าเกณฑ์นี้ได้ใน `test.rb`:

```ruby
config.active_support.test_parallelization_threshold = 100
```

และเมื่อตั้งค่าการทำงานขนานที่ระดับของกรณีทดสอบ:

```ruby
class ActiveSupport::TestCase
  parallelize threshold: 100
end
```

ฐานข้อมูลทดสอบ
-----------------

แทบทุกแอปพลิเคชัน Rails มีการใช้งานฐานข้อมูลอย่างหนัก และเพื่อให้ทดสอบของคุณสามารถทำงานได้เร็วและมีประสิทธิภาพ คุณจะต้องเข้าใจวิธีการติดตั้งฐานข้อมูลนี้และเติมข้อมูลตัวอย่างลงไป

โดยค่าเริ่มต้นแล้วแอปพลิเคชัน Rails มีสามสภาพแวดล้อม: development, test, และ production ฐานข้อมูลสำหรับแต่ละสภาพแวดล้อมจะถูกกำหนดค่าใน `config/database.yml`

ฐานข้อมูลทดสอบที่มีการกำหนดค่าเฉพาะอนุญาตให้คุณติดตั้งและทำงานกับข้อมูลทดสอบในโหมดที่แยกต่างหาก นี้จะทำให้ทดสอบของคุณสามารถแก้ไขข้อมูลทดสอบได้อย่างมั่นใจโดยไม่ต้องกังวลเกี่ยวกับข้อมูลในฐานข้อมูลของการพัฒนาหรือการใช้งานจริง

### การรักษาโครงสร้างของฐานข้อมูลทดสอบ

เพื่อให้ทดสอบของคุณทำงานได้ ฐานข้อมูลทดสอบของคุณจะต้องมีโครงสร้างปัจจุบัน ตัวช่วยการทดสอบจะตรวจสอบว่าฐานข้อมูลทดสอบของคุณมีการเคลื่อนย้ายที่ยังไม่เสร็จสิ้น มันจะพยายามโหลด `db/schema.rb` หรือ `db/structure.sql` ของคุณลงในฐานข้อมูลทดสอบ หากยังมีการเคลื่อนย้ายที่ยังไม่เสร็จสิ้น จะเกิดข้อผิดพลาดขึ้น โดยทั่วไปนี้แสดงว่าโครงสร้างของคุณยังไม่ได้ถูกเคลื่อนย้ายเสร็จสมบูรณ์ การเรียกใช้การเคลื่อนย้ายฐานข้อมูลกับฐานข้อมูลการพัฒนา (`bin/rails db:migrate`) จะทำให้โครงสร้างอัปเดต

หมายเหตุ: หากมีการแก้ไขการเคลื่อนย้ายที่มีอยู่แล้ว จะต้องสร้างฐานข้อมูลทดสอบใหม่ สามารถทำได้โดยการดำเนินการ `bin/rails db:test:prepare`

### ข้อมูลตัวอย่าง

สำหรับการทดสอบที่ดี คุณจะต้องคิดให้ดีกับการตั้งค่าข้อมูลทดสอบ ใน Rails คุณสามารถจัดการได้โดยกำหนดและปรับแต่งข้อมูลตัวอย่าง คุณสามารถค้นหาเอกสารที่ครอบคลุมอย่างละเอียดใน [เอกสาร API ของ Fixtures](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)

#### Fixtures คืออะไร?

_Fixtures_ เป็นคำที่ใช้เรียกข้อมูลตัวอย่าง Fixtures ช่วยให้คุณสามารถเติมฐานข้อมูลทดสอบของคุณด้วยข้อมูลที่กำหนดไว้ล่วงหน้าก่อนที่การทดสอบจะเริ่มต้น Fixtures เป็นอิสระต่อฐานข้อมูลและเขียนในรูปแบบ YAML มีไฟล์หนึ่งต่อแบบจำลอง

หมายเหตุ: Fixtures ไม่ได้ถูกออกแบบให้สร้างทุกอ็อบเจกต์ที่ทดสอบของคุณและจัดการได้ดีเมื่อใช้สำหรับข้อมูลเริ่มต้นที่สามารถนำไปใช้กับกรณีที่เป็นที่พบ

คุณจะพบ Fixtures ภายใต้ไดเรกทอรี `test/fixtures` เมื่อคุณเรียกใช้ `bin/rails generate model` เพื่อสร้างแบบจำลองใหม่ Rails จะสร้างไฟล์ Fixtures สำหรับแบบจำลองเหล่านี้ในไดเรกทอรีนี้

#### YAML

Fixtures ในรูปแบบ YAML เป็นวิธีที่เป็นมิตรต่อมนุษย์ในการอธิบายข้อมูลตัวอย่างของคุณ แบบจำลองเหล่านี้มีนามสกุลไฟล์ **.yml** (เช่น `users.yml`)

นี่คือตัวอย่างไฟล์ Fixtures ในรูปแบบ YAML:

```yaml
# ดูนี่แล้ว! ฉันเป็นคอมเมนต์ YAML!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Systems development

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: guy with keyboard
```

แต่ละ Fixture จะมีชื่อตามด้วยรายการคีย์/ค่าที่แยกด้วยเครื่องหมายจุลภาค (:). ระเบียนจะถูกแยกออกจากกันโดยมีบรรทัดว่าง. คุณสามารถใส่ความคิดเห็นในไฟล์ Fixture โดยใช้ตัวอักษร # ในคอลัมน์แรก

หากคุณกำลังทำงานกับ [การเชื่อมโยง](/association_basics.html) คุณสามารถกำหนดอ้างอิงระหว่าง Fixture สองรายการที่แตกต่างกันได้ ตัวอย่างเช่น

```yaml
# test/fixtures/categories.yml
about:
  name: About
```

```yaml
# test/fixtures/articles.yml
first:
  title: Welcome to Rails!
  category: about
```

```yaml
# test/fixtures/action_text/rich_texts.yml
first_content:
  record: first (Article)
  name: content
  body: <div>Hello, from <strong>a fixture</strong></div>
```

สังเกตว่าคีย์ `category` ของ Article `first` ที่พบใน `fixtures/articles.yml` มีค่าเป็น `about` และคีย์ `record` ของรายการ `first_content` ที่พบใน `fixtures/action_text/rich_texts.yml` มีค่าเป็น `first (Article)` นี้บอกให้ Active Record โหลด Category `about` ที่พบใน `fixtures/categories.yml` สำหรับข้อแรก และ Action Text โหลด Article `first` ที่พบใน `fixtures/articles.yml` สำหรับข้อสุดท้าย

หมายเหตุ: สำหรับการอ้างอิงกันระหว่างกันโดยใช้ชื่อ คุณสามารถใช้ชื่อ Fixture แทนที่จะระบุแอตทริบิวต์ `id:` ใน Fixture ที่เกี่ยวข้อง Rails จะกำหนดคีย์หลักอัตโนมัติเพื่อให้สอดคล้องกันระหว่างการทำงาน สำหรับข้อมูลเพิ่มเติมเกี่ยวกับพฤติกรรมการเชื่อมโยงนี้โปรดอ่านเอกสาร [Fixtures API documentation](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)

#### Fixture แนบไฟล์แนบ

เช่นกับโมเดลที่มีการสนับสนุน Active Record อื่น ๆ การแนบไฟล์ Active Storage สืบทอดจากอินสแตนซ์ของ ActiveRecord::Base และสามารถเติมข้อมูล Fixture ได้

พิจารณาโมเดล `Article` ที่มีภาพที่เกี่ยวข้องเป็นไฟล์แนบ `thumbnail` พร้อมกับข้อมูล Fixture YAML:

```ruby
class Article
  has_one_attached :thumbnail
end
```

```yaml
# test/fixtures/articles.yml
first:
  title: An Article
```

สมมติว่ามีไฟล์ที่เข้ารหัส [image/png][] ที่ `test/fixtures/files/first.png` รายการ Fixture YAML ต่อไปนี้จะสร้างเรคคอร์ด `ActiveStorage::Blob` และ `ActiveStorage::Attachment` ที่เกี่ยวข้อง:

```yaml
# test/fixtures/active_storage/blobs.yml
first_thumbnail_blob: <%= ActiveStorage::FixtureSet.blob filename: "first.png" %>
```

```yaml
# test/fixtures/active_storage/attachments.yml
first_thumbnail_attachment:
  name: thumbnail
  record: first (Article)
  blob: first_thumbnail_blob
```

#### ERB'in It Up

ERB ช่วยให้คุณสามารถฝังรหัส Ruby ในเทมเพลตได้ รูปแบบ Fixture YAML จะถูกประมวลผลล่วงหน้าด้วย ERB เมื่อ Rails โหลด Fixture นี้ช่วยให้คุณสามารถใช้ Ruby เพื่อช่วยในการสร้างข้อมูลตัวอย่างบางส่วน ตัวอย่างเช่น โค้ดต่อไปนี้สร้างผู้ใช้หนึ่งพันคน:

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```

#### Fixture ในการทำงาน

Rails โหลด Fixture ทั้งหมดจากไดเรกทอรี `test/fixtures` โดยค่าเริ่มต้น กระบวนการโหลดประกอบด้วยสามขั้นตอน:

1. ลบข้อมูลที่มีอยู่ในตารางที่สอดคล้องกับ Fixture
2. โหลดข้อมูล Fixture เข้าสู่ตาราง
3. บันทึกข้อมูล Fixture เป็นเมธอดในกรณีที่คุณต้องการเข้าถึงโดยตรง

เคล็ดลับ: เพื่อลบข้อมูลที่มีอยู่ในฐานข้อมูล Rails พยายามปิดการใช้งานตัวกรองความสัมพันธ์ (เช่นคีย์ต่างประเทศและเงื่อนไขการตรวจสอบ) หากคุณพบข้อผิดพลาดในการอนุญาตขณะเรียกใช้งานทดสอบ โปรดตรวจสอบว่าผู้ใช้ฐานข้อมูลมีสิทธิ์ในการปิดการใช้งานตัวกรองเหล่านี้ในสภาพแวดล้อมการทดสอบ (ใน PostgreSQL เฉพาะผู้ใช้ที่มีสิทธิ์สูงสุดเท่านั้นที่สามารถปิดการใช้งานตัวกรองทั้งหมด อ่านเพิ่มเติมเกี่ยวกับสิทธิ์ PostgreSQL [ที่นี่](https://www.postgresql.org/docs/current/sql-altertable.html))

#### Fixture เป็นวัตถุ Active Record
Fixtures เป็นตัวอย่างของ Active Record ตามที่กล่าวไว้ในข้อที่ 3 ข้างต้น คุณสามารถเข้าถึงออบเจ็กต์โดยตรงเนื่องจากมันถูกสร้างขึ้นโดยอัตโนมัติเป็นเมธอดที่มีขอบเขตเป็นท้องถิ่นของกรณีทดสอบ ตัวอย่างเช่น:

```ruby
# นี้จะคืนค่าออบเจ็กต์ User สำหรับ fixture ที่ชื่อ david
users(:david)

# นี้จะคืนค่าคุณสมบัติสำหรับ david ที่ชื่อว่า id
users(:david).id

# สามารถเข้าถึงเมธอดที่มีอยู่ในคลาส User ได้เช่นกัน
david = users(:david)
david.call(david.partner)
```

หากต้องการรับ fixture หลายตัวพร้อมกัน คุณสามารถส่งรายชื่อ fixture เป็นรายการได้ เช่น:

```ruby
# นี้จะคืนค่าอาร์เรย์ที่มี fixtures david และ steve
users(:david, :steve)
```


การทดสอบโมเดล
-------------

การทดสอบโมเดลใช้สำหรับทดสอบโมเดลต่าง ๆ ของแอปพลิเคชันของคุณ

การทดสอบโมเดลของ Rails จะถูกเก็บไว้ในไดเรกทอรี `test/models`  Rails มีเครื่องมือสร้างโครงสร้างการทดสอบโมเดลให้คุณ

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

การทดสอบโมเดลไม่มี superclass เป็นของตัวเองเหมือนกับ `ActionMailer::TestCase` แต่จะสืบทอดมาจาก [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html).

การทดสอบระบบ
--------------

การทดสอบระบบช่วยให้คุณทดสอบการปฏิสัมพันธ์ของผู้ใช้กับแอปพลิเคชันของคุณ โดยการเรียกใช้การทดสอบในเบราว์เซอร์จริงหรือเบราว์เซอร์แบบ headless การทดสอบระบบใช้ Capybara ในฐานะเครื่องมือในการดำเนินการ

ในการสร้างการทดสอบระบบของ Rails คุณสามารถใช้ไดเรกทอรี `test/system` ในแอปพลิเคชันของคุณ Rails มีเครื่องมือสร้างโครงสร้างการทดสอบระบบให้คุณ

```bash
$ bin/rails generate system_test users
      invoke test_unit
      create test/system/users_test.rb
```

นี่คือรูปแบบของการทดสอบระบบที่สร้างขึ้นใหม่:

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
end
```

โดยค่าเริ่มต้น การทดสอบระบบจะถูกเรียกใช้กับไดรเวอร์ Selenium โดยใช้เบราว์เซอร์ Chrome และขนาดหน้าจอ 1400x1400 ส่วนส่วนถัดไปจะอธิบายวิธีการเปลี่ยนการตั้งค่าเริ่มต้น

### เปลี่ยนการตั้งค่าเริ่มต้น

Rails ทำให้การเปลี่ยนการตั้งค่าเริ่มต้นสำหรับการทดสอบระบบเป็นเรื่องง่ายมาก การตั้งค่าทั้งหมดถูกแยกออกมาเพื่อให้คุณสามารถใส่ความสนใจในการเขียนการทดสอบของคุณ

เมื่อคุณสร้างแอปพลิเคชันหรือสคริปต์ใหม่ ไฟล์ `application_system_test_case.rb` จะถูกสร้างขึ้นในไดเรกทอรีทดสอบ นี่คือสถานที่ที่ควรเก็บการตั้งค่าทั้งหมดสำหรับการทดสอบระบบของคุณ

หากคุณต้องการเปลี่ยนการตั้งค่าเริ่มต้นคุณสามารถเปลี่ยนสิ่งที่การทดสอบระบบ "ขับเคลื่อนโดย" สำหรับการเปลี่ยนไดรเวอร์จาก Selenium เป็น Cuprite ให้เพิ่ม gem `cuprite` ใน `Gemfile` จากนั้นในไฟล์ `application_system_test_case.rb` ทำตามขั้นตอนต่อไปนี้:

```ruby
require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
```

ชื่อไดรเวอร์เป็นอาร์กิวเมนต์ที่ต้องใช้สำหรับ `driven_by` อาร์กิวเมนต์ทางเลือกที่สามารถส่งให้กับ `driven_by` ได้คือ `:using` สำหรับเบราว์เซอร์ (ซึ่งจะใช้เฉพาะโดย Selenium เท่านั้น) `:screen_size` เพื่อเปลี่ยนขนาดหน้าจอสำหรับภาพหน้าจอ และ `:options` ซึ่งสามารถใช้เพื่อตั้งค่าตามที่ไดรเวอร์รองรับ

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```

หากคุณต้องการใช้เบราว์เซอร์แบบ headless คุณสามารถใช้ Headless Chrome หรือ Headless Firefox โดยเพิ่ม `headless_chrome` หรือ `headless_firefox` ในอาร์กิวเมนต์ `:using`
```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

หากคุณต้องการใช้เบราว์เซอร์ระยะไกล เช่น [Headless Chrome in Docker](https://github.com/SeleniumHQ/docker-selenium) คุณต้องเพิ่ม `url` ระยะไกลผ่าน `options` 

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  options = ENV["SELENIUM_REMOTE_URL"].present? ? { url: ENV["SELENIUM_REMOTE_URL"] } : {}
  driven_by :selenium, using: :headless_chrome, options: options
end
```

ในกรณีนี้ gem `webdrivers` ไม่จำเป็นอีกต่อไป คุณสามารถลบมันออกได้หรือเพิ่ม `require:` option ใน `Gemfile`

```ruby
# ...
group :test do
  gem "webdrivers", require: !ENV["SELENIUM_REMOTE_URL"] || ENV["SELENIUM_REMOTE_URL"].empty?
end
```

ตอนนี้คุณควรได้รับการเชื่อมต่อกับเบราว์เซอร์ระยะไกลแล้ว

```bash
$ SELENIUM_REMOTE_URL=http://localhost:4444/wd/hub bin/rails test:system
```

หากแอปพลิเคชันของคุณในการทดสอบกำลังทำงานระยะไกลด้วย เช่น Docker container Capybara ต้องการข้อมูลเพิ่มเติมเกี่ยวกับวิธีการ [เรียกใช้เซิร์ฟเวอร์ระยะไกล](https://github.com/teamcapybara/capybara#calling-remote-servers)

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  def setup
    Capybara.server_host = "0.0.0.0" # bind to all interfaces
    Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}" if ENV["SELENIUM_REMOTE_URL"].present?
    super
  end
  # ...
end
```

ตอนนี้คุณควรได้รับการเชื่อมต่อกับเบราว์เซอร์และเซิร์ฟเวอร์ระยะไกล ไม่ว่าจะทำงานใน Docker container หรือ CI

หากการกำหนดค่า Capybara ของคุณต้องการการตั้งค่าเพิ่มเติมที่ไม่ได้รับจาก Rails การกำหนดค่าเพิ่มเติมนี้สามารถเพิ่มเข้าไปในไฟล์ `application_system_test_case.rb` ได้

โปรดดู [เอกสารของ Capybara](https://github.com/teamcapybara/capybara#setup) สำหรับการตั้งค่าเพิ่มเติม

### Screenshot Helper

`ScreenshotHelper` เป็นช่วยเหลือที่ออกแบบมาเพื่อจับภาพหน้าจอของการทดสอบของคุณ สิ่งนี้สามารถช่วยในการดูเบราว์เซอร์ในจุดที่การทดสอบล้มเหลวหรือใช้ดูภาพหน้าจอภายหลังเพื่อการดีบัก

มีเมธอดสองเมธอดที่ให้ใช้: `take_screenshot` และ `take_failed_screenshot` `take_failed_screenshot` ถูกเพิ่มอัตโนมัติใน `before_teardown` ภายใน Rails

เมธอด `take_screenshot` ช่วยให้คุณสามารถเพิ่มได้ทุกที่ในการทดสอบของคุณเพื่อจับภาพหน้าจอของเบราว์เซอร์

### การสร้าง System Test

ตอนนี้เรากำลังจะเพิ่มระบบการทดสอบในแอปพลิเคชันบล็อกของเรา เราจะสาธิตการเขียนระบบการทดสอบโดยเข้าชมหน้าดัชนีและสร้างบทความบล็อกใหม่

หากคุณใช้เครื่องมือ scaffold generator ระบบการทดสอบระบบจะถูกสร้างขึ้นโดยอัตโนมัติสำหรับคุณ หากคุณไม่ได้ใช้ scaffold generator เริ่มต้นโดยการสร้างระบบการทดสอบ

```bash
$ bin/rails generate system_test articles
```

มันควรสร้างไฟล์ทดสอบสำหรับเรา ด้วยผลลัพธ์จากคำสั่งก่อนหน้านี้คุณควรเห็น:

```
      invoke  test_unit
      create    test/system/articles_test.rb
```

ตอนนี้เรามาเปิดไฟล์นั้นและเขียนการตรวจสอบครั้งแรกของเรา:

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "viewing the index" do
    visit articles_path
    assert_selector "h1", text: "Articles"
  end
end
```

การทดสอบควรเห็นว่ามี `h1` อยู่ในหน้าดัชนีบทความและผ่าน

เรียกใช้ระบบการทดสอบ

```bash
$ bin/rails test:system
```

หมายเหตุ: โดยค่าเริ่มต้นการเรียกใช้ `bin/rails test` จะไม่เรียกใช้ระบบการทดสอบของคุณ ตรวจสอบให้แน่ใจว่าเรียกใช้ `bin/rails test:system` เพื่อเรียกใช้จริง คุณยังสามารถเรียกใช้ `bin/rails test:all` เพื่อเรียกใช้ทุกการทดสอบรวมถึงระบบการทดสอบ

#### การสร้างระบบการทดสอบบทความ

ตอนนี้เรามาทดสอบกระบวนการสร้างบทความใหม่ในบล็อกของเรา

```ruby
test "should create Article" do
  visit articles_path

  click_on "New Article"

  fill_in "Title", with: "Creating an Article"
  fill_in "Body", with: "Created this article successfully!"

  click_on "Create Article"

  assert_text "Creating an Article"
end
```

ขั้นแรกคือการเรียกใช้ `visit articles_path` ซึ่งจะพาทดสอบไปยังหน้าดัชนีบทความ

จากนั้น `click_on "New Article"` จะค้นหาปุ่ม "New Article" ในหน้าดัชนี และจะเปลี่ยนเส้นทางของเบราว์เซอร์ไปที่ `/articles/new`

จากนั้นทดสอบจะกรอกข้อมูลในช่องหัวข้อและเนื้อหาของบทความด้วยข้อความที่ระบุ หลังจากกรอกข้อมูลเสร็จ "Create Article" จะถูกคลิก เป็นการส่งคำขอ POST เพื่อสร้างบทความใหม่ในฐานข้อมูล

จะถูกเปลี่ยนเส้นทางกลับไปที่หน้าดัชนีบทความ และที่นั่นเราจะยืนยันว่าข้อความจากหัวข้อบทความใหม่อยู่ในหน้าดัชนีบทความ

#### การทดสอบสำหรับขนาดหน้าจอหลายขนาด

หากคุณต้องการทดสอบสำหรับขนาดหน้าจอมือถือนอกเหนือจากการทดสอบสำหรับเดสก์ท็อป คุณสามารถสร้างคลาสอื่นที่สืบทอดมาจาก `ActionDispatch::SystemTestCase` และใช้ในชุดทดสอบของคุณ ในตัวอย่างนี้ไฟล์ที่ชื่อ `mobile_system_test_case.rb` ถูกสร้างขึ้นในไดเรกทอรี `/test` ด้วยการกำหนดค่าต่อไปนี้

```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

ในการใช้งานการกำหนดค่านี้ ให้สร้างทดสอบภายใน `test/system` ที่สืบทอดมาจาก `MobileSystemTestCase` ตอนนี้คุณสามารถทดสอบแอปของคุณโดยใช้การกำหนดค่าต่าง ๆ

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase
  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### การเดินทางไปไกลกว่านี้

ความสวยงามของการทดสอบระบบคือ มันคล้ายกับการทดสอบการรวมกันในเรื่องของการทดสอบประสบการณ์ของผู้ใช้กับตัวควบคุม โมเดล และวิวของคุณ แต่การทดสอบระบบมีความทนทานมากขึ้นและจริงจังกว่า และจริงจังทดสอบแอปของคุณเหมือนผู้ใช้จริง ในการเดินทางไกล คุณสามารถทดสอบอะไรก็ได้ที่ผู้ใช้เองจะทำในแอปของคุณ เช่นการแสดงความคิดเห็น การลบบทความ การเผยแพร่บทความร่างกาย ฯลฯ

การทดสอบการรวมกัน
-------------------

การทดสอบการรวมกันใช้สำหรับทดสอบวิธีการที่ส่วนต่าง ๆ ของแอปของเรามีการปฏิสัมพันธ์กัน โดยทั่วไปใช้สำหรับทดสอบกระบวนการที่สำคัญภายในแอปของเรา

สำหรับการสร้างการทดสอบการรวมกันของ Rails เราใช้ไดเรกทอรี `test/integration` สำหรับแอปของเรา Rails มีเครื่องมือสร้างเทสเพื่อสร้างโครงสร้างการทดสอบการรวมกันสำหรับเรา

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

นี่คือการทดสอบการรวมกันที่สร้างขึ้นใหม่:

```ruby
require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

ที่นี่การทดสอบสืบทอดมาจาก `ActionDispatch::IntegrationTest` ซึ่งทำให้มีเครื่องมือเพิ่มเติมที่สามารถใช้ในการเขียนการทดสอบการรวมกันของเรา

### เครื่องมือที่ใช้ในการทดสอบการรวมกัน

นอกจากเครื่องมือการทดสอบมาตรฐาน เมื่อสืบทอดมาจาก `ActionDispatch::IntegrationTest` ยังมีเครื่องมือเพิ่มเติมที่ใช้ในการเขียนการทดสอบการรวมกัน มาดูกันสั้น ๆ ว่ามีเครื่องมือหมวดหมู่ใดที่เราสามารถเลือกใช้ได้

สำหรับการจัดการกับตัวรันเนอร์การทดสอบการรวมกัน ดูที่ [`ActionDispatch::Integration::Runner`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html)

เมื่อทำการร้องขอ จะมี [`ActionDispatch::Integration::RequestHelpers`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html) ที่ใช้ได้สำหรับการใช้งานของเรา

หากเราต้องการแก้ไขเซสชันหรือสถานะของการทดสอบการรวมกันของเรา ลองดูที่ [`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html) เพื่อช่วยเหลือ

### การนำไปใช้

มาเพิ่มการทดสอบการรวมกันในแอปของเรากันเถอะ เราจะเริ่มด้วยกระบวนการทำงานพื้นฐานของการสร้างบทความบล็อกใหม่ เพื่อยืนยันว่าทุกอย่างทำงานอย่างถูกต้อง
เราจะเริ่มต้นด้วยการสร้างโครงสร้างการทดสอบการผสานรวมของเรา:

```bash
$ bin/rails generate integration_test blog_flow
```

มันควรจะสร้างไฟล์ทดสอบสำหรับเรา ด้วยผลลัพธ์ของคำสั่งก่อนหน้านี้ เราควรจะเห็น:

```
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

ตอนนี้เรามาเปิดไฟล์นั้นและเขียนการยืนยันครั้งแรกของเรา:

```ruby
require "test_helper"

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

เราจะมองไปที่ `assert_select` เพื่อสอบถาม HTML ที่ได้รับจากคำขอในส่วน "การทดสอบมุมมอง" ด้านล่าง มันถูกใช้สำหรับการทดสอบการตอบสนองของคำขอของเราโดยการยืนยันการมีองค์ประกอบ HTML ที่สำคัญและเนื้อหาของมัน

เมื่อเราเข้าชมเส้นทางรากของเรา เราควรจะเห็น `welcome/index.html.erb` ที่ถูกแสดงสำหรับมุมมอง ดังนั้นการยืนยันนี้ควรจะผ่าน

#### การสร้างการผสานรวมของบทความ

เราจะทดสอบความสามารถในการสร้างบทความใหม่ในบล็อกของเราและดูบทความที่ได้

```ruby
test "can create an article" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "can create", body: "article successfully." } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "Title:\n  can create"
end
```

เรามาแบ่งการทดสอบนี้ออกเพื่อให้เราเข้าใจ

เราเริ่มต้นด้วยการเรียกใช้การกระทำ `:new` ในคอนโทรลเลอร์ของเราเราควรจะได้รับการตอบสนองที่ประสบความสำเร็จ

หลังจากนี้เราจะทำการส่งคำขอ post ไปที่การกระทำ `:create` ของคอนโทรลเลอร์ของเรา:

```ruby
post "/articles",
  params: { article: { title: "can create", body: "article successfully." } }
assert_response :redirect
follow_redirect!
```

สองบรรทัดที่ตามหลังคำขอเป็นการจัดการการเปลี่ยนเส้นทางที่เราตั้งค่าเมื่อสร้างบทความใหม่

หมายเหตุ: อย่าลืมเรียกใช้ `follow_redirect!` หากคุณวางแผนที่จะทำคำขอต่อไปหลังจากเกิดการเปลี่ยนเส้นทาง

ในที่สุดเราสามารถยืนยันได้ว่าการตอบสนองของเราเป็นที่ประสบความสำเร็จและบทความใหม่ของเราสามารถอ่านได้ในหน้า

#### การเดินทางไปไกลกว่านั้น

เราสามารถทดสอบได้สำเร็จแล้วในการทดสอบกระบวนการที่เล็กมากสำหรับการเข้าชมบล็อกของเราและสร้างบทความใหม่ หากเราต้องการเดินไปไกลกว่านี้เราสามารถเพิ่มการทดสอบสำหรับการแสดงความคิดเห็นการลบบทความหรือแก้ไขความคิดเห็น การผสานรวมเป็นสถานที่ที่ดีที่จะทดลองกับกรณีการใช้งานทั้งหมดสำหรับแอปพลิเคชันของเรา


การทดสอบฟังก์ชันสำหรับคอนโทรลเลอร์ของคุณ
------------------------------------------

ใน Rails การทดสอบการกระทำต่าง ๆ ของคอนโทรลเลอร์เป็นการเขียนการทดสอบฟังก์ชัน โปรดจำไว้ว่าคอนโทรลเลอร์ของคุณจัดการกับคำขอเว็บที่เข้ามาในแอปพลิเคชันของคุณและตอบกลับด้วยมุมมองที่ถูกแสดง ในขณะเขียนการทดสอบฟังก์ชันคุณกำลังทดสอบวิธีการกระทำของคุณในการจัดการคำขอและผลลัพธ์หรือการตอบสนองที่คาดหวังในบางกรณีเป็นมุมมอง HTML

### สิ่งที่ควรรวมในการทดสอบฟังก์ชันของคุณ

คุณควรทดสอบสิ่งต่าง ๆ เช่น:

* คำขอเว็บสำเร็จหรือไม่?
* ผู้ใช้ได้รับการเปลี่ยนเส้นทางไปที่หน้าที่ถูกต้องหรือไม่?
* ผู้ใช้ได้รับการรับรองตัวตนเรียบร้อยหรือไม่?
* ข้อความที่เหมาะสมถูกแสดงให้ผู้ใช้เห็นในมุมมองหรือไม่?
* ข้อมูลที่ถูกต้องถูกแสดงในการตอบสนองหรือไม่?

วิธีที่ง่ายที่สุดในการดูการทดสอบฟังก์ชันในการดำเนินการคือการสร้างคอนโทรลเลอร์โดยใช้ตัวสร้าง scaffold:
```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
สร้าง  app/controllers/articles_controller.rb
...
เรียกใช้  test_unit
สร้าง    test/controllers/articles_controller_test.rb
...
```

คำสั่งนี้จะสร้างโค้ดของคอนโทรลเลอร์และเทสสำหรับทรัพยากร `Article` คุณสามารถดูไฟล์ `articles_controller_test.rb` ในไดเรกทอรี `test/controllers` 

หากคุณมีคอนโทรลเลอร์อยู่แล้วและต้องการสร้างโค้ดเทสสำหรับแต่ละแอ็คชันเริ่มต้น คุณสามารถใช้คำสั่งต่อไปนี้:

```bash
$ bin/rails generate test_unit:scaffold article
...
เรียกใช้  test_unit
สร้าง    test/controllers/articles_controller_test.rb
...
```

มาดูตัวอย่างเทสหนึ่ง เช่น `test_should_get_index` จากไฟล์ `articles_controller_test.rb`

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

ในเทส `test_should_get_index` Rails จำลองการร้องขอในแอ็คชันที่เรียกว่า `index` เพื่อตรวจสอบว่าการร้องขอเสร็จสมบูรณ์
และตรวจสอบให้แน่ใจว่าได้สร้างเนื้อหาตอบกลับที่ถูกต้อง

เมธอด `get` เริ่มการร้องขอเว็บและเก็บผลลัพธ์ไว้ใน `@response` สามารถรับอาร์กิวเมนต์ได้สูงสุด 6 อาร์กิวเมนต์:

* URI ของแอ็คชันคอนโทรลเลอร์ที่คุณกำลังร้องขอ
  สามารถเป็นสตริงหรือเป็นเฮลเปอร์ของเส้นทาง (เช่น `articles_url`)
* `params`: ตัวเลือกที่มีแฮชของพารามิเตอร์การร้องขอที่จะส่งเข้าไปในแอ็คชัน
  (เช่น พารามิเตอร์สตริงคิวรี่หรือตัวแปรบทความ)
* `headers`: สำหรับตั้งค่าส่วนหัวที่จะส่งพร้อมกับการร้องขอ
* `env`: สำหรับปรับแต่งสภาพแวดล้อมการร้องขอตามต้องการ
* `xhr`: ว่าการร้องขอเป็น Ajax request หรือไม่ สามารถตั้งค่าเป็น true เพื่อระบุว่าการร้องขอเป็น Ajax
* `as`: สำหรับเข้ารหัสการร้องขอด้วยประเภทเนื้อหาที่แตกต่างกัน

ทุกอาร์กิวเมนต์เหล่านี้เป็นตัวเลือก

ตัวอย่าง: เรียกใช้แอ็คชัน `:show` สำหรับ `Article` แรก โดยส่งเข้าไปเฮดเดอร์ `HTTP_REFERER`:

```ruby
get article_url(Article.first), headers: { "HTTP_REFERER" => "http://example.com/home" }
```

ตัวอย่างอื่น: เรียกใช้แอ็คชัน `:update` สำหรับ `Article` สุดท้าย โดยส่งเข้าไปใหม่ในตัวแปร `title` ใน `params` เป็นการร้องขอแบบ Ajax:

```ruby
patch article_url(Article.last), params: { article: { title: "updated" } }, xhr: true
```

ตัวอย่างอีกตัว: เรียกใช้แอ็คชัน `:create` เพื่อสร้างบทความใหม่ โดยส่งเข้าไปในตัวแปร `title` ใน `params` เป็นการร้องขอแบบ JSON:

```ruby
post articles_path, params: { article: { title: "Ahoy!" } }, as: :json
```

หมายเหตุ: หากคุณพยายามเรียกใช้เทส `test_should_create_article` จาก `articles_controller_test.rb` จะล้มเหลวเนื่องจากมีการตรวจสอบระดับโมเดลที่เพิ่มเข้ามาและถูกต้อง

ให้เราแก้ไขเทส `test_should_create_article` ใน `articles_controller_test.rb` เพื่อให้ทุกเทสผ่าน:

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }
  end

  assert_redirected_to article_path(Article.last)
end
```

ตอนนี้คุณสามารถลองรันเทสทั้งหมดและควรผ่าน

หมายเหตุ: หากคุณทำตามขั้นตอนในส่วน [การรับรองความถูกต้องเบื้องต้น](getting_started.html#basic-authentication) คุณจะต้องเพิ่มการอนุญาตในส่วนหัวของการร้องขอทุกอย่างเพื่อให้เทสผ่านทั้งหมด:

```ruby
post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
```

### ประเภทการร้องขอที่ใช้ได้สำหรับเทสฟังก์ชัน
หากคุณคุ้นเคยกับโปรโตคอล HTTP คุณจะทราบว่า `get` เป็นประเภทของคำขอ มีรองรับประเภทคำขอทั้งหมด 6 ประเภทในการทดสอบฟังก์ชันของ Rails:

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

ทุกประเภทของคำขอมีเมธอดที่เทียบเท่าที่คุณสามารถใช้ได้ ในแอปพลิเคชัน C.R.U.D. ทั่วไปคุณจะใช้ `get`, `post`, `put`, และ `delete` บ่อยกว่า

หมายเหตุ: การทดสอบฟังก์ชันไม่ตรวจสอบว่าประเภทคำขอที่ระบุได้รับการยอมรับโดยการกระทำ สิ่งที่เราสนใจมากกว่าคือผลลัพธ์ การทดสอบคำขอมีอยู่สำหรับกรณีการใช้งานนี้เพื่อทำให้การทดสอบของคุณมีความตั้งใจ

### การทดสอบคำขอ XHR (Ajax)

ในการทดสอบคำขอ Ajax คุณสามารถระบุตัวเลือก `xhr: true` ให้กับเมธอด `get`, `post`, `patch`, `put`, และ `delete` ตัวอย่างเช่น:

```ruby
test "ajax request" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal "hello world", @response.body
  assert_equal "text/javascript", @response.media_type
end
```

### สามแฮชของโลกที่พินิจ

หลังจากที่คำขอถูกทำและประมวลผลแล้ว คุณจะมีอ็อบเจกต์แฮช 3 อันพร้อมใช้งาน:

* `cookies` - คุกกี้ที่ถูกตั้งค่า
* `flash` - อ็อบเจกต์ใด ๆ ที่อยู่ในแฟลช
* `session` - อ็อบเจกต์ใด ๆ ที่อยู่ในตัวแปรเซสชัน

เหมือนกับอ็อบเจกต์แฮชปกติ คุณสามารถเข้าถึงค่าโดยอ้างอิงคีย์ด้วยสตริง คุณยังสามารถอ้างอิงด้วยชื่อสัญลักษณ์ได้ เช่น:

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### ตัวแปรอินสแตนซ์ที่ใช้ได้

**หลังจาก**ที่คำขอถูกทำ คุณยังสามารถเข้าถึงตัวแปรอินสแตนซ์สามตัวในการทดสอบฟังก์ชันของคุณได้:

* `@controller` - คอนโทรลเลอร์ที่ประมวลผลคำขอ
* `@request` - อ็อบเจกต์คำขอ
* `@response` - อ็อบเจกต์การตอบกลับ


```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Articles", @response.body
  end
end
```

### การตั้งค่าเฮดเดอร์และตัวแปร CGI

[เฮดเดอร์ HTTP](https://tools.ietf.org/search/rfc2616#section-5.3)
และ
[ตัวแปร CGI](https://tools.ietf.org/search/rfc3875#section-4.1)
สามารถถ่ายโอนเป็นเฮดเดอร์ได้:

```ruby
# ตั้งค่าเฮดเดอร์ HTTP
get articles_url, headers: { "Content-Type": "text/plain" } # จำลองคำขอด้วยเฮดเดอร์ที่กำหนดเอง

# ตั้งค่าตัวแปร CGI
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # จำลองคำขอด้วยตัวแปร env ที่กำหนดเอง
```

### การทดสอบ `flash` Notices

หากคุณจำได้จากตอนก่อนหน้านี้ หนึ่งในสามแฮชของโลกที่พินิจคือ `flash`

เราต้องการเพิ่มข้อความ `flash` ในแอปพลิเคชันบล็อกของเราเมื่อมีคนสร้างบทความใหม่เรียบร้อยแล้ว

เราจะเริ่มต้นโดยเพิ่มการยืนยันนี้ในการทดสอบ `test_should_create_article` ของเรา:

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { title: "Some title" } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal "Article was successfully created.", flash[:notice]
end
```

หากเราเรียกใช้งานทดสอบของเราตอนนี้ เราควรเห็นข้อผิดพลาด:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 32266

# Running:

F

Finished in 0.114870s, 8.7055 runs/s, 34.8220 assertions/s.

  1) Failure:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- expected
+++ actual
@@ -1 +1 @@
-"Article was successfully created."
+nil

1 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

ให้เราทำการสร้างข้อความ flash ในคอนโทรลเลอร์ของเราตอนนี้ การกระทำ `:create` ของเราควรมีลักษณะดังนี้:
```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = "บทความถูกสร้างเรียบร้อยแล้ว"
    redirect_to @article
  else
    render "new"
  end
end
```

ตอนนี้ถ้าเรารันการทดสอบของเรา เราควรจะเห็นว่ามันผ่าน:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 18981

# Running:

.

Finished in 0.081972s, 12.1993 runs/s, 48.7972 assertions/s.

1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### รวมทุกอย่างเข้าด้วยกัน

ในจุดนี้ คอนโทรลเลอร์ของเราทดสอบ `:index` และ `:new` และ `:create` ได้แล้ว แต่เราจะจัดการกับข้อมูลที่มีอยู่แล้วอย่างไร?

เรามาเขียนการทดสอบสำหรับการทำงานของ `:show` กัน:

```ruby
test "ควรแสดงบทความ" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

จำไว้จากการอภิปรายก่อนหน้าเราเรื่อง fixtures ว่า `articles()` จะให้เราเข้าถึง fixtures ของบทความของเราได้

แล้วเราจะลบบทความที่มีอยู่ออกไปอย่างไร?

```ruby
test "ควรลบบทความ" do
  article = articles(:one)
  assert_difference("Article.count", -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

เรายังสามารถเพิ่มการทดสอบสำหรับการอัปเดตบทความที่มีอยู่ได้อีกด้วย

```ruby
test "ควรอัปเดตบทความ" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "อัปเดตแล้ว" } }

  assert_redirected_to article_path(article)
  # โหลดข้อมูลที่อัปเดตใหม่และตรวจสอบว่าชื่อเรื่องถูกอัปเดต
  article.reload
  assert_equal "อัปเดตแล้ว", article.title
end
```

สังเกตเราเริ่มเห็นความซ้ำซ้อนในการทดสอบสามตัวนี้ ทั้งหมดเข้าถึงข้อมูล fixtures บทความเดียวกัน เราสามารถ D.R.Y. ได้โดยใช้เมธอด `setup` และ `teardown` ที่ `ActiveSupport::Callbacks` จัดหาให้

การทดสอบของเราตอนนี้ควรจะมีลักษณะเช่นต่อไปนี้ ละเว้นการทดสอบอื่นๆ เพื่อความกระชับ

```ruby
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # เรียกใช้ก่อนทุกการทดสอบ
  setup do
    @article = articles(:one)
  end

  # เรียกใช้หลังทุกการทดสอบ
  teardown do
    # เมื่อคอนโทรลเลอร์ใช้แคช อาจเป็นไอเดียที่ดีที่จะต้องรีเซ็ตหลังจากนั้น
    Rails.cache.clear
  end

  test "ควรแสดงบทความ" do
    # ใช้ตัวแปร @article จาก setup ใหม่
    get article_url(@article)
    assert_response :success
  end

  test "ควรลบบทความ" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "ควรอัปเดตบทความ" do
    patch article_url(@article), params: { article: { title: "อัปเดตแล้ว" } }

    assert_redirected_to article_path(@article)
    # โหลดข้อมูลที่อัปเดตใหม่และตรวจสอบว่าชื่อเรื่องถูกอัปเดต
    @article.reload
    assert_equal "อัปเดตแล้ว", @article.title
  end
end
```

เหมือนกับ callback อื่นๆ ใน Rails เราสามารถใช้เมธอด `setup` และ `teardown` ได้โดยการส่งบล็อก แลมบ์ดา หรือชื่อเมธอดเป็นสัญลักษณ์เพื่อเรียกใช้

### Test Helpers

เพื่อหลีกเลี่ยงการซ้ำซ้อนของโค้ด เราสามารถเพิ่ม test helpers เองได้
ตัวอย่างที่ดีคือ helper ในการเข้าสู่ระบบ:

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "ควรแสดงโปรไฟล์" do
    # helper สามารถใช้ซ้ำได้จากทุก test case ของคอนโทรลเลอร์
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

#### การใช้ไฟล์แยกต่างหาก

หากคุณพบว่า helpers ของคุณกลายเป็นรกใน `test_helper.rb` คุณสามารถแยกไฟล์เหล่านั้นออกเป็นไฟล์แยกต่างหากได้
สถานที่ที่ดีที่สุดในการเก็บไฟล์เหล่านั้นคือ `test/lib` หรือ `test/test_helpers`
```ruby
# test/test_helpers/multiple_assertions.rb
module MultipleAssertions
  def assert_multiple_of_forty_two(number)
    assert (number % 42 == 0), "คาดว่า #{number} จะเป็นเลขคู่ของ 42"
  end
end
```

เมื่อต้องการใช้งาน helpers เหล่านี้ สามารถระบุให้ require โดยชื่อไฟล์และระบุให้ include ตามต้องการ

```ruby
require "test_helper"
require "test_helpers/multiple_assertions"

class NumberTest < ActiveSupport::TestCase
  include MultipleAssertions

  test "420 เป็นเลขคู่ของ 42" do
    assert_multiple_of_forty_two 420
  end
end
```

หรือสามารถ include เข้าไปในคลาสหลักที่เกี่ยวข้องได้เลย

```ruby
# test/test_helper.rb
require "test_helpers/sign_in_helper"

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

#### Eagerly Requiring Helpers

หากต้องการให้ไฟล์ทดสอบสามารถเข้าถึง helpers ได้โดยอัตโนมัติ สามารถทำได้โดยการ require ไฟล์ที่เกี่ยวข้องใน `test_helper.rb` ดังตัวอย่างต่อไปนี้

```ruby
# test/test_helper.rb
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }
```

วิธีนี้จะทำให้เวลาเริ่มต้นแอปพลิเคชันช้าลงเนื่องจากต้อง require ไฟล์ทั้งหมด แต่จะไม่ต้องระบุ require แยกตามไฟล์ทดสอบแต่ละไฟล์

การทดสอบเส้นทาง (Routes)
--------------

เช่นเดียวกับสิ่งอื่นในแอปพลิเคชัน Rails ของคุณ คุณสามารถทดสอบเส้นทางได้ การทดสอบเส้นทางจะอยู่ใน `test/controllers/` หรือเป็นส่วนหนึ่งของการทดสอบคอนโทรลเลอร์

หมายเหตุ: หากแอปพลิเคชันของคุณมีเส้นทางที่ซับซ้อน Rails จะมีเครื่องมือช่วยที่มีประโยชน์ในการทดสอบเส้นทาง

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการตรวจสอบเส้นทางที่มีให้ใช้ใน Rails โปรดดูเอกสาร API สำหรับ [`ActionDispatch::Assertions::RoutingAssertions`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html).

การทดสอบวิว (Views)
-------------

การทดสอบการตอบสนองของคำขอโดยการตรวจสอบการมีองค์ประกอบ HTML ที่สำคัญและเนื้อหาขององค์ประกอบนั้นเป็นวิธีที่พบบ่อยในการทดสอบวิวของแอปพลิเคชันของคุณ คล้ายกับการทดสอบเส้นทาง การทดสอบวิวจะอยู่ใน `test/controllers/` หรือเป็นส่วนหนึ่งของการทดสอบคอนโทรลเลอร์ วิธี `assert_select` ช่วยให้คุณสามารถค้นหาองค์ประกอบ HTML ในการตอบสนองได้โดยใช้ไวยากรณ์ที่เรียบง่ายแต่มีประสิทธิภาพ

มีรูปแบบของ `assert_select` อยู่สองรูปแบบ:

`assert_select(selector, [equality], [message])` ให้แน่ใจว่าเงื่อนไขความเท่ากันถูกต้องสำหรับองค์ประกอบที่เลือกผ่านตัวเลือก ตัวเลือกอาจเป็นสมการเลือก CSS (String) หรือสมการที่มีค่าแทนที่

`assert_select(element, selector, [equality], [message])` ให้แน่ใจว่าเงื่อนไขความเท่ากันถูกต้องสำหรับองค์ประกอบที่เลือกผ่านตัวเลือกเริ่มต้นจาก _element_ (instance of `Nokogiri::XML::Node` หรือ `Nokogiri::XML::NodeSet`) และลูกของมัน

ตัวอย่างเช่น คุณสามารถตรวจสอบเนื้อหาในองค์ประกอบ title ในการตอบสนองด้วย:

```ruby
assert_select "title", "ยินดีต้อนรับสู่ Rails Testing Guide"
```

คุณยังสามารถใช้บล็อก `assert_select` ซ้อนกันได้สำหรับการสำรวจลึกลงไป

ในตัวอย่างต่อไปนี้ การใช้ `assert_select` ภายใน `li.menu_item` จะทำงานภายในคอลเลกชันขององค์ประกอบที่ถูกเลือกโดยบล็อกภายนอก:

```ruby
assert_select "ul.navigation" do
  assert_select "li.menu_item"
end
```

คอลเลกชันขององค์ประกอบที่ถูกเลือกสามารถวนซ้ำได้เพื่อให้ `assert_select` สามารถเรียกแยกกันสำหรับแต่ละองค์ประกอบ

ตัวอย่างเช่น หากการตอบสนองมี ordered list สองรายการ แต่ละรายการมี list element ซึ่งเป็นลูกของรายการนั้น การทดสอบต่อไปนี้จะผ่านทั้งสองรายการ

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

การตรวจสอบนี้มีความสามารถที่สูงมาก สำหรับการใช้งานที่ซับซ้อนมากขึ้น โปรดอ่านเอกสาร [documentation](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb) ของมัน

### การตรวจสอบวิวเพิ่มเติม

มีการตรวจสอบเพิ่มเติมที่ใช้งานในการทดสอบวิว:

| การตรวจสอบ                                                 | วัตถุประสงค์ |
| --------------------------------------------------------- | ------- |
| `assert_select_email`                                     | ช่วยให้คุณสามารถตรวจสอบเนื้อหาในอีเมลได้ |
| `assert_select_encoded`                                   | ช่วยให้คุณสามารถตรวจสอบ HTML ที่ถูกเข้ารหัสได้ โดยการถอดรหัสเนื้อหาของแต่ละองค์ประกอบแล้วเรียกใช้บล็อกกับองค์ประกอบที่ถอดรหัสแล้วทั้งหมด |
| `css_select(selector)` หรือ `css_select(element, selector)` | คืนค่าอาร์เรย์ขององค์ประกอบที่ถูกเลือกโดย _selector_ ในรูปแบบแรก จะตรงกับองค์ประกอบฐานและพยายามตรงกับสมการ _selector_ ในลูกของมัน หากไม่มีการตรงกันทั้งสองรูปแบบจะคืนค่าอาร์เรย์ว่าง |
นี่คือตัวอย่างการใช้ `assert_select_email`:

```ruby
assert_select_email do
  assert_select "small", "กรุณาคลิกที่ลิงก์ 'ยกเลิกการรับข่าวสาร' หากคุณต้องการยกเลิกการรับข่าวสาร"
end
```

Testing Helpers
---------------

Helper เป็นโมดูลที่เรียกใช้งานได้ในวิวของคุณ

เพื่อทดสอบ helper ทั้งหมดที่คุณต้องทำคือตรวจสอบผลลัพธ์ของเมธอด helper ว่าตรงกับที่คุณคาดหวังหรือไม่ ทดสอบที่เกี่ยวข้องกับ helper จะอยู่ภายใต้ไดเรกทอรี `test/helpers`

เมื่อเรามี helper ดังต่อไปนี้:

```ruby
module UsersHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

เราสามารถทดสอบผลลัพธ์ของเมธอดนี้ได้ดังนี้:

```ruby
class UsersHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

นอกจากนี้เนื่องจากคลาสทดสอบขยายจาก `ActionView::TestCase` คุณสามารถเข้าถึงเมธอด helper ของ Rails เช่น `link_to` หรือ `pluralize` ได้

การทดสอบ Mailer ของคุณ
--------------------

การทดสอบคลาส mailer ต้องใช้เครื่องมือที่เฉพาะเจาะจงบางอย่างเพื่อทำงานอย่างละเอียด

### การตรวจสอบ Postman

คลาส mailer ของคุณ - เช่นเดียวกับส่วนอื่น ๆ ของแอปพลิเคชัน Rails ของคุณ - ควรทดสอบเพื่อให้แน่ใจว่ามันทำงานตามที่คาดหวัง

เป้าหมายของการทดสอบคลาส mailer ของคุณคือ:

* อีเมลถูกประมวลผล (สร้างและส่ง)
* เนื้อหาอีเมลถูกต้อง (หัวข้อเรื่อง ผู้ส่ง ข้อความเนื้อหา เป็นต้น)
* อีเมลที่ถูกส่งถูกส่งในเวลาที่ถูกต้อง

#### จากทุกทิศทาง

มีสองด้านของการทดสอบ mailer ของคุณ คือการทดสอบหน่วยและการทดสอบฟังก์ชัน ในการทดสอบหน่วยคุณเรียกใช้ mailer ในโหมดที่แยกต่างหากกับข้อมูลที่ควบคุมอย่างเข้มงวดและเปรียบเทียบผลลัพธ์กับค่าที่รู้จัก (fixture) ในการทดสอบฟังก์ชันคุณไม่ได้ทดสอบรายละเอียดเล็กน้อยที่ถูกสร้างขึ้นโดย mailer แทนที่เราจะทดสอบว่าคอนโทรลเลอร์และโมเดลของเราใช้ mailer ในทางที่ถูกต้อง คุณทดสอบเพื่อพิสูจน์ว่าอีเมลที่ถูกส่งถูกส่งในเวลาที่ถูกต้อง

### การทดสอบหน่วย

เพื่อทดสอบว่า mailer ของคุณทำงานตามที่คาดหวังคุณสามารถใช้การทดสอบหน่วยเพื่อเปรียบเทียบผลลัพธ์จริงของ mailer กับตัวอย่างที่เขียนไว้ล่วงหน้าว่าควรจะถูกสร้างขึ้น

#### การกลับมาของ Fixture

สำหรับวัตถุประสงค์ของการทดสอบหน่วย mailer ใช้ fixture เพื่อให้ตัวอย่างของผลลัพธ์ที่ควรจะมี โดยเนื่องจากเป็นอีเมลตัวอย่างและไม่ใช่ข้อมูล Active Record เช่น fixture อื่น ๆ และเก็บไว้ในไดเรกทอรีย่อยของตัวเองอยู่ห่างจาก fixture อื่น ๆ ชื่อของไดเรกทอรีภายใน `test/fixtures` สอดคล้องกับชื่อของ mailer เช่นสำหรับ mailer ที่ชื่อ `UserMailer` fixture ควรอยู่ในไดเรกทอรี `test/fixtures/user_mailer`

หากคุณสร้าง mailer แล้ว generator จะไม่สร้าง fixture สำหรับ mailer actions คุณต้องสร้างไฟล์เหล่านี้ด้วยตัวคุณเองตามที่ได้กล่าวไว้ข้างต้น

#### กรณีทดสอบพื้นฐาน

นี่คือการทดสอบหน่วยเพื่อทดสอบ mailer ที่ชื่อ `UserMailer` ซึ่งมีการกระทำ `invite` ที่ใช้สำหรับส่งคำเชิญให้กับเพื่อน นี่คือเวอร์ชันที่ปรับเปลี่ยนของการทดสอบหลักที่สร้างขึ้นโดย generator สำหรับการกระทำ `invite`
```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # สร้างอีเมลและเก็บไว้สำหรับการตรวจสอบเพิ่มเติม
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # ส่งอีเมลแล้วตรวจสอบว่าถูกคิวไว้
    assert_emails 1 do
      email.deliver_now
    end

    # ตรวจสอบเนื้อหาของอีเมลที่ส่งว่าตรงตามที่คาดหวัง
    assert_equal ["me@example.com"], email.from
    assert_equal ["friend@example.com"], email.to
    assert_equal "You have been invited by me@example.com", email.subject
    assert_equal read_fixture("invite").join, email.body.to_s
  end
end
```

ในการทดสอบเราสร้างอีเมลและเก็บวัตถุที่ส่งกลับในตัวแปร `email` จากนั้นเราตรวจสอบว่ามันถูกส่ง (assert แรก) แล้วในกลุ่มของการตรวจสอบที่สองเราตรวจสอบว่าอีเมลจริงๆ มีเนื้อหาที่เราคาดหวัง ฟังก์ชันช่วยเหลือ `read_fixture` ใช้ในการอ่านเนื้อหาจากไฟล์นี้

หมายเหตุ: `email.body.to_s` ปรากฏเมื่อมีส่วนเดียว (HTML หรือ text) อยู่ ถ้า mailer มีทั้งคู่ คุณสามารถทดสอบ fixture ของคุณกับส่วนที่เฉพาะได้ด้วย `email.text_part.body.to_s` หรือ `email.html_part.body.to_s`

นี่คือเนื้อหาของ `invite` fixture:

```
Hi friend@example.com,

You have been invited.

Cheers!
```

นี่คือเวลาที่เหมาะสมในการเข้าใจเพิ่มเติมเกี่ยวกับการเขียนการทดสอบสำหรับ mailer ของคุณ บรรทัด `ActionMailer::Base.delivery_method = :test` ใน `config/environments/test.rb` จะตั้งค่าวิธีการส่งเป็นโหมดทดสอบเพื่อให้อีเมลจริง ๆ ไม่ถูกส่ง (เป็นประโยชน์ในการหลีกเลี่ยงการส่งสแปมให้กับผู้ใช้ของคุณในขณะทดสอบ) แต่จะถูกเพิ่มเข้าไปในอาร์เรย์ (`ActionMailer::Base.deliveries`) แทน

หมายเหตุ: อาร์เรย์ `ActionMailer::Base.deliveries` จะถูกรีเซ็ตโดยอัตโนมัติเฉพาะในการทดสอบ `ActionMailer::TestCase` และ `ActionDispatch::IntegrationTest` หากคุณต้องการให้มีสถานะเริ่มต้นใหม่นอกเหนือจากกรณีทดสอบเหล่านี้ คุณสามารถรีเซ็ตด้วยตนเองด้วย: `ActionMailer::Base.deliveries.clear`

#### การทดสอบอีเมลที่อยู่ในคิว

คุณสามารถใช้การยืนยัน `assert_enqueued_email_with` เพื่อยืนยันว่าอีเมลถูกคิวไว้พร้อมกับอาร์กิวเมนต์และ/หรือพารามิเตอร์ของเมธอดเมลเลอร์ที่คาดหวัง นี้ช่วยให้คุณสามารถจับคู่กับอีเมลใด ๆ ที่ถูกคิวไว้ด้วยเมธอด `deliver_later`

เช่นเดียวกับกรณีทดสอบพื้นฐาน เราสร้างอีเมลและเก็บวัตถุที่ส่งกลับในตัวแปร `email` ตัวอย่างต่อไปนี้รวมถึงการส่งอาร์กิวเมนต์และ/หรือพารามิเตอร์ในรูปแบบต่าง ๆ

ตัวอย่างนี้จะยืนยันว่าอีเมลถูกคิวไว้ด้วยอาร์กิวเมนต์ที่ถูกต้อง:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # สร้างอีเมลและเก็บไว้สำหรับการตรวจสอบเพิ่มเติม
    email = UserMailer.create_invite("me@example.com", "friend@example.com")

    # ตรวจสอบว่าอีเมลถูกคิวไว้ด้วยอาร์กิวเมนต์ที่ถูกต้อง
    assert_enqueued_email_with UserMailer, :create_invite, args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

ตัวอย่างนี้จะยืนยันว่า mailer ถูกคิวไว้ด้วยอาร์กิวเมนต์ของเมธอดเมลเลอร์ที่ถูกต้องโดยการส่งแบบชื่ออาร์กิวเมนต์เป็นแฮช:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # สร้างอีเมลและเก็บไว้สำหรับการตรวจสอบเพิ่มเติม
    email = UserMailer.create_invite(from: "me@example.com", to: "friend@example.com")

    # ตรวจสอบว่าอีเมลถูกคิวไว้ด้วยอาร์กิวเมนต์ที่มีชื่อ
    assert_enqueued_email_with UserMailer, :create_invite, args: [{ from: "me@example.com",
                                                                    to: "friend@example.com" }] do
      email.deliver_later
    end
  end
end
```

ตัวอย่างนี้จะยืนยันว่า mailer ที่มีพารามิเตอร์ถูกคิวไว้ด้วยพารามิเตอร์และอาร์กิวเมนต์ที่ถูกต้อง พารามิเตอร์ของเมลเลอร์ถูกส่งเป็น `params` และอาร์กิวเมนต์ของเมธอดเมลเลอร์ถูกส่งเป็น `args`:
```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # สร้างอีเมลและเก็บไว้สำหรับการตรวจสอบเพิ่มเติม
    email = UserMailer.with(all: "good").create_invite("me@example.com", "friend@example.com")

    # ทดสอบว่าอีเมลถูกเพิ่มในคิวเพื่อส่งด้วยพารามิเตอร์และอาร์กิวเมนต์ที่ถูกต้อง
    assert_enqueued_email_with UserMailer, :create_invite, params: { all: "good" },
                                                           args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

ตัวอย่างนี้แสดงวิธีทดสอบทางเลือกในการตรวจสอบว่ามีการเพิ่มอีเมลพารามิเตอร์ได้ถูกต้อง:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # สร้างอีเมลและเก็บไว้สำหรับการตรวจสอบเพิ่มเติม
    email = UserMailer.with(to: "friend@example.com").create_invite

    # ทดสอบว่าอีเมลถูกเพิ่มในคิวเพื่อส่งด้วยพารามิเตอร์และอาร์กิวเมนต์ที่ถูกต้อง
    assert_enqueued_email_with UserMailer.with(to: "friend@example.com"), :create_invite do
      email.deliver_later
    end
  end
end
```

### การทดสอบฟังก์ชันและระบบ

การทดสอบหน่วยช่วยให้เราสามารถทดสอบคุณสมบัติของอีเมลได้ในขณะที่การทดสอบฟังก์ชันและระบบช่วยให้เราสามารถทดสอบว่าการกระทำของผู้ใช้ส่งผลให้อีเมลถูกส่งได้อย่างเหมาะสม ตัวอย่างเช่นคุณสามารถตรวจสอบว่าการเชิญเพื่อนส่งอีเมลได้อย่างถูกต้อง:

```ruby
# การทดสอบการรวมกัน
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    # ยืนยันความแตกต่างใน ActionMailer::Base.deliveries
    assert_emails 1 do
      post invite_friend_url, params: { email: "friend@example.com" }
    end
  end
end
```

```ruby
# การทดสอบระบบ
require "test_helper"

class UsersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "inviting a friend" do
    visit invite_users_url
    fill_in "Email", with: "friend@example.com"
    assert_emails 1 do
      click_on "Invite"
    end
  end
end
```

หมายเหตุ: เมธอด `assert_emails` ไม่ได้เชื่อมโยงกับเมธอดส่งเฉพาะและจะทำงานกับอีเมลที่ส่งด้วยเมธอด `deliver_now` หรือ `deliver_later` ถ้าเราต้องการยืนยันโดยเฉพาะว่าอีเมลถูกเพิ่มในคิวเราสามารถใช้เมธอด `assert_enqueued_email_with` ([ตัวอย่างด้านบน](#การทดสอบอีเมลที่ถูกเพิ่มในคิว)) หรือเมธอด `assert_enqueued_emails` ได้ ข้อมูลเพิ่มเติมสามารถดูได้ใน[เอกสารที่นี่](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html) 

การทดสอบงาน
------------

เนื่องจากงานที่กำหนดเองของคุณสามารถเพิ่มในคิวในระดับต่าง ๆ ภายในแอปพลิเคชันของคุณได้ คุณจะต้องทดสอบงานเหล่านั้นเพื่อตรวจสอบพฤติกรรมเมื่องานถูกเพิ่มในคิวและตรวจสอบว่าองค์ประกอบอื่น ๆ ได้เพิ่มงานในคิวได้อย่างถูกต้อง

### เคสทดสอบพื้นฐาน

ตามค่าเริ่มต้น เมื่อคุณสร้างงาน งานทดสอบที่เกี่ยวข้องจะถูกสร้างขึ้นด้วยภายใต้ไดเรกทอรี `test/jobs` นี่คือตัวอย่างการทดสอบกับงานการเรียกเก็บเงิน:

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "that account is charged" do
    BillingJob.perform_now(account, product)
    assert account.reload.charged_for?(product)
  end
end
```

ทดสอบนี้ง่ายและเพียงแค่ยืนยันว่างานทำงานตามที่คาดหวัง

### การยืนยันและทดสอบงานภายในองค์ประกอบอื่น

Active Job มาพร้อมกับการยืนยันที่กำหนดเองหลายอย่างที่สามารถใช้เพื่อลดความยุ่งเหยิงของการทดสอบ สำหรับรายการเต็มของการยืนยันที่มีอยู่ ดูเอกสาร API สำหรับ [`ActiveJob::TestHelper`](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html)

เป็นการปฏิบัติที่ดีที่จะตรวจสอบว่างานของคุณถูกเพิ่มในคิวหรือทำงานอย่างถูกต้องทุกครั้งที่คุณเรียกใช้งาน (เช่นในคอนโทรลเลอร์ของคุณ) นี่คือที่เอกสารการให้บริการ Active Job มีประโยชน์อย่างมาก ตัวอย่างเช่น ภายในโมเดลคุณสามารถยืนยันว่างานถูกเพิ่มในคิว:

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "billing job scheduling" do
    assert_enqueued_with(job: BillingJob) do
      product.charge(account)
    end
    assert_not account.reload.charged_for?(product)
  end
end
```

อแอดเตอร์เริ่มต้น `:test` ไม่ทำงานงานเมื่อถูกเพิ่มในคิว คุณต้องบอกให้มันรู้ว่าคุณต้องการให้งานทำงานเมื่อไร:

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "การตั้งเวลางานการเรียกเก็บเงิน" do
    perform_enqueued_jobs(only: BillingJob) do
      product.charge(account)
    end
    assert account.reload.charged_for?(product)
  end
end
```

งานที่ทำงานและที่อยู่ในคิวอยู่ก่อนหน้านี้จะถูกล้างทิ้งก่อนทดสอบเริ่มต้น ดังนั้นคุณสามารถสมมติได้ว่าไม่มีงานที่ได้รับการดำเนินการไว้แล้วในขอบเขตของแต่ละทดสอบ

การทดสอบ Action Cable
--------------------

เนื่องจาก Action Cable ถูกใช้ในระดับต่าง ๆ ภายในแอปพลิเคชันของคุณ คุณจะต้องทดสอบทั้งช่องทาง คลาสการเชื่อมต่อตนเอง และการกระจายข้อความที่ถูกต้องขององค์ประกอบอื่น ๆ

### กรณีทดสอบการเชื่อมต่อ

โดยค่าเริ่มต้นเมื่อคุณสร้างแอปพลิเคชัน Rails ใหม่ด้วย Action Cable จะมีการสร้างทดสอบสำหรับคลาสการเชื่อมต่อหลัก (`ApplicationCable::Connection`) ด้วยภายใต้ไดเรกทอรี `test/channels/application_cable`

การทดสอบการเชื่อมต่อมีเป้าหมายเพื่อตรวจสอบว่าตัวระบุของการเชื่อมต่อถูกกำหนดอย่างถูกต้องหรือไม่ หรือว่าคำขอการเชื่อมต่อที่ไม่ถูกต้องถูกปฏิเสธหรือไม่ ตัวอย่างเช่น:

```ruby
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "เชื่อมต่อด้วยพารามิเตอร์" do
    # จำลองการเปิดการเชื่อมต่อโดยเรียกใช้เมธอด `connect`
    connect params: { user_id: 42 }

    # คุณสามารถเข้าถึงออบเจกต์การเชื่อมต่อผ่าน `connection` ในการทดสอบ
    assert_equal connection.user_id, "42"
  end

  test "ปฏิเสธการเชื่อมต่อโดยไม่มีพารามิเตอร์" do
    # ใช้เมทเชอร์ `assert_reject_connection` เพื่อยืนยันว่า
    # การเชื่อมต่อถูกปฏิเสธ
    assert_reject_connection { connect }
  end
end
```

คุณยังสามารถระบุคุกกี้คำขอเช่นเดียวกับที่คุณทำในการทดสอบการรวม:

```ruby
test "เชื่อมต่อด้วยคุกกี้" do
  cookies.signed[:user_id] = "42"

  connect

  assert_equal connection.user_id, "42"
end
```

ดูเอกสาร API สำหรับ [`ActionCable::Connection::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html) เพื่อข้อมูลเพิ่มเติม

### กรณีทดสอบช่อง

โดยค่าเริ่มต้นเมื่อคุณสร้างช่อง จะมีการสร้างทดสอบที่เกี่ยวข้องด้วยภายใต้ไดเรกทอรี `test/channels` ตัวอย่างการทดสอบกับช่องแชท:

```ruby
require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  test "สมัครสมาชิกและสตรีมสำหรับห้อง" do
    # จำลองการสร้างการสมัครสมาชิกโดยเรียกใช้ `subscribe`
    subscribe room: "15"

    # คุณสามารถเข้าถึงออบเจกต์ช่องผ่าน `subscription` ในการทดสอบ
    assert subscription.confirmed?
    assert_has_stream "chat_15"
  end
end
```

ทดสอบนี้ง่ายมากและเพียงยืนยันว่าช่องสมัครสมาชิกการเชื่อมต่อกับสตรีมที่เฉพาะเจาะจง

คุณยังสามารถระบุตัวระบุการเชื่อมต่อใต้สิ่งที่อยู่ ตัวอย่างการทดสอบกับช่องการแจ้งเตือนผ่านเว็บ:

```ruby
require "test_helper"

class WebNotificationsChannelTest < ActionCable::Channel::TestCase
  test "สมัครสมาชิกและสตรีมสำหรับผู้ใช้" do
    stub_connection current_user: users(:john)

    subscribe

    assert_has_stream_for users(:john)
  end
end
```

ดูเอกสาร API สำหรับ [`ActionCable::Channel::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html) เพื่อข้อมูลเพิ่มเติม

### การยืนยันและทดสอบการกระจายข้อความภายในองค์ประกอบอื่น

Action Cable มาพร้อมกับการยืนยันที่กำหนดเองที่สามารถใช้เพื่อลดความยาวของการทดสอบ สำหรับรายการเต็มของการยืนยันที่มีอยู่ ดูเอกสาร API สำหรับ [`ActionCable::TestHelper`](https://api.rubyonrails.org/classes/ActionCable/TestHelper.html)

เป็นการปฏิบัติที่ดีที่จะตรวจสอบว่าข้อความที่ถูกต้องถูกกระจายไปยังองค์ประกอบอื่น (เช่นในคอนโทรลเลอร์ของคุณ) นี่คือที่เอกสารการยืนยันที่มีอยู่ใน Action Cable มีประโยชน์มาก ตัวอย่างเช่น ในโมเดล:

```ruby
require "test_helper"

class ProductTest < ActionCable::TestCase
  test "กระจายสถานะหลังจากการเรียกเก็บเงิน" do
    assert_broadcast_on("products:#{product.id}", type: "charged") do
      product.charge(account)
    end
  end
end
```
หากคุณต้องการทดสอบการส่งออกที่ทำด้วย `Channel.broadcast_to` คุณควรใช้ `Channel.broadcasting_for` เพื่อสร้างชื่อสตรีมใต้เบื้องหลัง:

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end
```

```ruby
# test/jobs/chat_relay_job_test.rb
require "test_helper"

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "broadcast message to room" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "Hi!") do
      ChatRelayJob.perform_now(room, "Hi!")
    end
  end
end
```

การทดสอบการโหลดเร็ว
---------------------

โดยปกติแล้วแอปพลิเคชันจะไม่โหลดเร็วในสภาพแวดล้อม `development` หรือ `test` เพื่อเพิ่มความเร็ว แต่ในสภาพแวดล้อม `production` จะโหลดเร็ว

หากมีไฟล์ในโปรเจกต์ที่ไม่สามารถโหลดได้ด้วยเหตุผลใดๆ คุณควรตรวจสอบก่อนการติดตั้งในสภาพแวดล้อม `production` ใช่ไหม?

### การรวมระบบต่อเนื่อง

หากโปรเจกต์ของคุณมี CI อยู่ การโหลดเร็วใน CI เป็นวิธีง่ายๆ เพื่อให้แอปพลิเคชันโหลดเร็ว

CI มักตั้งค่าตัวแปรสภาพแวดล้อมบางอย่างเพื่อแสดงว่าชุดทดสอบกำลังทำงานอยู่ที่นั่น เช่น อาจเป็น `CI`:

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

เริ่มต้นด้วย Rails 7 แอปพลิเคชันที่สร้างใหม่จะกำหนดค่านั้นเป็นค่าเริ่มต้น

### ชุดทดสอบเบา

หากโปรเจกต์ของคุณไม่มีการรวมระบบต่อเนื่อง คุณยังสามารถโหลดเร็วในชุดทดสอบได้โดยเรียกใช้ `Rails.application.eager_load!`:

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "eager loads all files without errors" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk compliance" do
  it "eager loads all files without errors" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

ทรัพยากรการทดสอบเพิ่มเติม
----------------------------

### การทดสอบรหัสที่ขึ้นกับเวลา

Rails มีเมธอดช่วยในการทดสอบที่ช่วยให้คุณสามารถยืนยันว่ารหัสที่ขึ้นกับเวลาทำงานตามที่คาดหวังได้

ตัวอย่างต่อไปนี้ใช้เมธอด [`travel_to`][travel_to] ช่วย:

```ruby
# กำหนดให้ผู้ใช้มีสิทธิ์ในการให้ของขวัญหลังจากที่ลงทะเบียนไปเป็นเวลาหนึ่งเดือน
user = User.create(name: "Gaurish", activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?

travel_to Date.new(2004, 11, 24) do
  # ภายในบล็อก `travel_to` `Date.current` จะถูก stub
  assert_equal Date.new(2004, 10, 24), user.activation_date
  assert user.applicable_for_gifting?
end

# การเปลี่ยนแปลงเห็นได้เฉพาะภายในบล็อก `travel_to` เท่านั้น
assert_equal Date.new(2004, 10, 24), user.activation_date
```

โปรดดู API reference [`ActiveSupport::Testing::TimeHelpers`][time_helpers_api] สำหรับข้อมูลเพิ่มเติมเกี่ยวกับเมธอดช่วยเวลาที่ใช้ได้
[`config.active_support.test_order`]: configuring.html#config-active-support-test-order
[image/png]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types
[travel_to]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to
[time_helpers_api]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html
