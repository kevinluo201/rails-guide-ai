**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 67ad41dc27cc9079db9a7e31dffa5aac
หลายฐานข้อมูลด้วย Active Record
=====================================

เอกสารนี้เป็นการแนะนำการใช้งานหลายฐานข้อมูลกับแอปพลิเคชัน Rails ของคุณ

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีการตั้งค่าแอปพลิเคชันของคุณสำหรับหลายฐานข้อมูล
* การสลับการเชื่อมต่ออัตโนมัติทำงานอย่างไร
* วิธีใช้การแบ่งแยกแนวนอนสำหรับหลายฐานข้อมูล
* คุณสมบัติที่รองรับและคุณสมบัติที่ยังไม่สมบูรณ์

--------------------------------------------------------------------------------

เมื่อแอปพลิเคชันเติบโตในเรื่องความนิยมและการใช้งาน คุณจะต้องขยายแอปพลิเคชันเพื่อรองรับผู้ใช้ใหม่และข้อมูลของพวกเขา วิธีหนึ่งที่แอปพลิเคชันของคุณอาจต้องขยายคือระดับฐานข้อมูล Rails ตอนนี้มีการสนับสนุนหลายฐานข้อมูลเพื่อให้คุณไม่ต้องเก็บข้อมูลทั้งหมดไว้ที่เดียว

ในเวลานี้คุณสามารถใช้คุณสมบัติต่อไปนี้ได้:

* หลายฐานข้อมูลสำหรับการเขียนและฐานข้อมูลสำหรับการเลียนแบบแต่ละฐาน
* การสลับการเชื่อมต่ออัตโนมัติสำหรับโมเดลที่คุณกำลังทำงานอยู่
* การสลับอัตโนมัติระหว่างการเขียนและการเลียนแบบของฐานข้อมูลขึ้นอยู่กับ HTTP verb และการเขียนล่าสุด
* งาน Rails สำหรับสร้าง ลบ ย้ายและปฏิสัมพันธ์กับหลายฐานข้อมูล

คุณสมบัติต่อไปนี้ยังไม่ได้รับการสนับสนุน (เพิ่มเติม):

* การทดลองสมดุลภายในฐานข้อมูล

## การตั้งค่าแอปพลิเคชันของคุณ

ในขณะที่ Rails พยายามทำงานส่วนใหญ่ให้คุณ คุณยังต้องทำบางขั้นตอนเพื่อเตรียมแอปพลิเคชันของคุณสำหรับหลายฐานข้อมูล

เราเริ่มด้วยการมีแอปพลิเคชันที่มีฐานข้อมูลสำหรับการเขียนเดียวและเราต้องการเพิ่มฐานข้อมูลใหม่สำหรับตารางใหม่ที่เรากำลังเพิ่ม เราจะตั้งชื่อฐานข้อมูลใหม่ว่า "animals"

`database.yml` จะมีรูปแบบดังนี้:

```yaml
production:
  database: my_primary_database
  adapter: mysql2
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
```

เราจะเพิ่มฐานข้อมูลเลียนแบบสำหรับการตั้งค่าแรก และฐานข้อมูลที่สองที่เรียกว่า animals และฐานข้อมูลเลียนแบบสำหรับนั้นด้วย เพื่อทำเช่นนี้เราต้องเปลี่ยน `database.yml` ของเราจากการตั้งค่า 2 ชั้นเป็นการตั้งค่า 3 ชั้น
หากมีการกำหนดค่าหลัก (primary configuration) จะถูกใช้เป็นค่า "default" configuration หากไม่มีการกำหนดค่าชื่อ "primary" Rails จะใช้ค่า configuration แรกเป็นค่า default สำหรับแต่ละ environment ค่า configuration ที่ถูกกำหนดเป็นค่า default จะใช้ชื่อไฟล์ Rails ที่เป็นค่า default ตัวอย่างเช่น ค่า configuration หลักจะใช้ `schema.rb` เป็นไฟล์ schema ในขณะที่รายการอื่น ๆ จะใช้ `[CONFIGURATION_NAMESPACE]_schema.rb` เป็นชื่อไฟล์

```yaml
production:
  primary:
    database: my_primary_database
    username: root
    password: <%= ENV['ROOT_PASSWORD'] %>
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    username: root_readonly
    password: <%= ENV['ROOT_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
  animals:
    database: my_animals_database
    username: animals_root
    password: <%= ENV['ANIMALS_ROOT_PASSWORD'] %>
    adapter: mysql2
    migrations_paths: db/animals_migrate
  animals_replica:
    database: my_animals_database
    username: animals_readonly
    password: <%= ENV['ANIMALS_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
```

เมื่อใช้ฐานข้อมูลหลายรายการ จะมีการตั้งค่าสำคัญหลายอย่าง

คือ ชื่อฐานข้อมูลสำหรับ `primary` และ `primary_replica` ควรเป็นชื่อเดียวกันเนื่องจากมีข้อมูลเดียวกัน สำหรับ `animals` และ `animals_replica` ก็เช่นเดียวกัน

อีกอย่าง ชื่อผู้ใช้สำหรับผู้เขียนและผู้เขียนสำรองควรแตกต่างกัน และสิทธิ์การเข้าถึงฐานข้อมูลของผู้เขียนสำรองควรถูกตั้งค่าให้เป็นการอ่านเท่านั้นและไม่สามารถเขียนได้

เมื่อใช้ฐานข้อมูลสำรองคุณต้องเพิ่มรายการ `replica: true` ใน `database.yml` นี้เพราะ Rails ไม่มีวิธีที่จะรู้ว่าฐานข้อมูลใดเป็นสำรองและฐานข้อมูลใดเป็นผู้เขียน  Rails จะไม่เรียกใช้งานงานบางอย่าง เช่นการทำภารกิจต่าง ๆ เช่นการเรียกใช้งาน migrations กับฐานข้อมูลสำรอง

สุดท้าย สำหรับฐานข้อมูลผู้เขียนใหม่คุณต้องตั้งค่า `migrations_paths` เป็นไดเรกทอรีที่คุณจะเก็บ migrations สำหรับฐานข้อมูลนั้น ๆ เราจะพิจารณา `migrations_paths` มากขึ้นในส่วนที่เหลือของเอกสารนี้

ตอนนี้ที่เรามีฐานข้อมูลใหม่ ให้ตั้งค่าโมเดลการเชื่อมต่อ ในการใช้งานฐานข้อมูลใหม่เราต้องสร้างคลาสแบบ abstract ใหม่และเชื่อมต่อกับฐานข้อมูลสัตว์

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals, reading: :animals_replica }
end
```
จากนั้นเราต้องอัปเดต `ApplicationRecord` เพื่อที่จะรับรู้ถึง replica ใหม่ของเรา

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }
end
```

หากคุณใช้ชื่อคลาสที่แตกต่างกันสำหรับ application record ของคุณคุณต้องตั้งค่า `primary_abstract_class` แทน ดังนั้น Rails จะรู้ว่าคลาส `ActiveRecord::Base` ควรจะแชร์การเชื่อมต่อกับคลาสใด

```ruby
class PrimaryApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

คลาสที่เชื่อมต่อกับ primary/primary_replica สามารถสืบทอดจาก primary abstract class เช่นเดียวกับแอปพลิเคชัน Rails มาตรฐาน:

```ruby
class Person < ApplicationRecord
end
```

โดยค่าเริ่มต้น Rails คาดหวังให้บทบาทฐานข้อมูลเป็น `writing` และ `reading` สำหรับ primary และ replica ตามลำดับ หากคุณมีระบบที่เก่าแล้วคุณอาจจะมีบทบาทที่ตั้งค่าไว้แล้วที่คุณไม่ต้องการเปลี่ยนแปลง ในกรณีนั้นคุณสามารถตั้งชื่อบทบาทใหม่ในการกำหนดค่าแอปพลิเคชันของคุณได้

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

การเชื่อมต่อกับฐานข้อมูลในโมเดลเดียวแล้วสืบทอดจากโมเดลนั้นสำหรับตารางจะสำคัญ แทนที่จะเชื่อมต่อโมเดลแต่ละตัวเข้ากับฐานข้อมูลเดียวกัน ไคลเอ็นต์ฐานข้อมูลมีขีดจำกัดในการเปิดการเชื่อมต่อที่สามารถมีได้ และหากคุณทำเช่นนี้มันจะทำให้จำนวนการเชื่อมต่อของคุณเพิ่มขึ้นเนื่องจาก Rails ใช้ชื่อคลาสโมเดลสำหรับการระบุการเชื่อมต่อ

ตอนนี้ที่เรามี `database.yml` และโมเดลใหม่ตั้งค่าเสร็จแล้ว เป็นเวลาที่จะสร้างฐานข้อมูล ใน Rails 6.0 มาพร้อมกับเครื่องมือ rails tasks ที่คุณต้องการใช้งานหลายฐานข้อมูลใน Rails

คุณสามารถเรียกใช้ `bin/rails -T` เพื่อดูคำสั่งทั้งหมดที่คุณสามารถเรียกใช้ได้ คุณควรเห็นดังนี้:

```bash
$ bin/rails -T
bin/rails db:create                          # สร้างฐานข้อมูลจาก DATABASE_URL หรือ config/database.yml สำหรับ ...
bin/rails db:create:animals                  # สร้างฐานข้อมูล animals สำหรับสภาพแวดล้อมปัจจุบัน
bin/rails db:create:primary                  # สร้างฐานข้อมูล primary สำหรับสภาพแวดล้อมปัจจุบัน
bin/rails db:drop                            # ลบฐานข้อมูลจาก DATABASE_URL หรือ config/database.yml สำหรับสภาพแวดล้อมปัจจุบัน
bin/rails db:drop:animals                    # ลบฐานข้อมูล animals สำหรับสภาพแวดล้อมปัจจุบัน
bin/rails db:drop:primary                    # ลบฐานข้อมูล primary สำหรับสภาพแวดล้อมปัจจุบัน
bin/rails db:migrate                         # ทำการเมืองฐานข้อมูล (ตัวเลือก: VERSION=x, VERBOSE=false, SCOPE=blog)
bin/rails db:migrate:animals                 # ทำการเมืองฐานข้อมูล animals สำหรับสภาพแวดล้อมปัจจุบัน
bin/rails db:migrate:primary                 # ทำการเมืองฐานข้อมูล primary สำหรับสภาพแวดล้อมปัจจุบัน
bin/rails db:migrate:status                  # แสดงสถานะของการเมือง
bin/rails db:migrate:status:animals          # แสดงสถานะของการเมืองสำหรับฐานข้อมูล animals
bin/rails db:migrate:status:primary          # แสดงสถานะของการเมืองสำหรับฐานข้อมูล primary
bin/rails db:reset                           # ลบและสร้างฐานข้อมูลทั้งหมดจาก schema สำหรับสภาพแวดล้อมปัจจุบันและโหลด seed
bin/rails db:reset:animals                   # ลบและสร้างฐานข้อมูล animals จาก schema สำหรับสภาพแวดล้อมปัจจุบันและโหลด seed
bin/rails db:reset:primary                   # ลบและสร้างฐานข้อมูล primary จาก schema สำหรับสภาพแวดล้อมปัจจุบันและโหลด seed
bin/rails db:rollback                        # ย้อนกลับ schema ไปยังเวอร์ชันก่อนหน้า (ระบุขั้นตอนด้วย STEP=n)
bin/rails db:rollback:animals                # ย้อนกลับฐานข้อมูล animals สำหรับสภาพแวดล้อมปัจจุบัน (ระบุขั้นตอนด้วย STEP=n)
bin/rails db:rollback:primary                # ย้อนกลับฐานข้อมูล primary สำหรับสภาพแวดล้อมปัจจุบัน (ระบุขั้นตอนด้วย STEP=n)
bin/rails db:schema:dump                     # สร้างไฟล์ schema ฐานข้อมูล (เป็นไฟล์ db/schema.rb หรือ db/structure.sql ...
bin/rails db:schema:dump:animals             # สร้างไฟล์ schema ฐานข้อมูล (เป็นไฟล์ db/schema.rb หรือ db/structure.sql ...
bin/rails db:schema:dump:primary             # สร้างไฟล์ db/schema.rb ที่เป็นแบบพกพาสำหรับฐานข้อมูลที่รองรับทุก DB ...
bin/rails db:schema:load                     # โหลดไฟล์ schema ฐานข้อมูล (เป็นไฟล์ db/schema.rb หรือ db/structure.sql ...
bin/rails db:schema:load:animals             # โหลดไฟล์ schema ฐานข้อมูล (เป็นไฟล์ db/schema.rb หรือ db/structure.sql ...
bin/rails db:schema:load:primary             # โหลดไฟล์ schema ฐานข้อมูล (เป็นไฟล์ db/schema.rb หรือ db/structure.sql ...
bin/rails db:setup                           # สร้างฐานข้อมูลทั้งหมด โหลด schema ทั้งหมด และเริ่มต้นด้วยข้อมูล seed (ใช้ db:reset เพื่อลบฐานข้อมูลทั้งหมดก่อน)
bin/rails db:setup:animals                   # สร้างฐานข้อมูล animals โหลด schema และเริ่มต้นด้วยข้อมูล seed (ใช้ db:reset:animals เพื่อลบฐานข้อมูลก่อน)
bin/rails db:setup:primary                   # สร้างฐานข้อมูล primary โหลด schema และเริ่มต้นด้วยข้อมูล seed (ใช้ db:reset:primary เพื่อลบฐานข้อมูลก่อน)
```
การเรียกใช้คำสั่งเช่น `bin/rails db:create` จะสร้างฐานข้อมูลหลักและฐานข้อมูล animals พร้อมกัน
โปรดทราบว่าไม่มีคำสั่งสำหรับการสร้างผู้ใช้ฐานข้อมูล และคุณจะต้องทำการสร้างผู้ใช้ด้วยตนเอง
เพื่อรองรับผู้ใช้ที่มีสิทธิ์อ่านเท่านั้นสำหรับ replica ของคุณ หากคุณต้องการสร้างฐานข้อมูล animals เท่านั้น
คุณสามารถเรียกใช้ `bin/rails db:create:animals` ได้

## เชื่อมต่อกับฐานข้อมูลโดยไม่ต้องจัดการสกีมาและการเมจเรชัน

หากคุณต้องการเชื่อมต่อกับฐานข้อมูลภายนอกโดยไม่ต้องทำงานที่เกี่ยวกับการจัดการฐานข้อมูล
เช่นการจัดการสกีมา, การเมจเรชัน, การซีด, เป็นต้น คุณสามารถตั้งค่าตัวเลือกการกำหนดค่าฐานข้อมูลต่อฐานข้อมูลได้
`database_tasks: false` โดยค่าเริ่มต้นจะเป็น true

```yaml
production:
  primary:
    database: my_database
    adapter: mysql2
  animals:
    database: my_animals_database
    adapter: mysql2
    database_tasks: false
```

## การสร้างและการเคลื่อนย้าย

การเคลื่อนย้ายสำหรับฐานข้อมูลหลายรายการควรอยู่ในโฟลเดอร์ของตนเองที่มีคำนำหน้าชื่อเป็น
ชื่อของคีย์ฐานข้อมูลในการกำหนดค่า

คุณยังต้องตั้งค่า `migrations_paths` ในการกำหนดค่าฐานข้อมูลเพื่อบอกให้ Rails
ทราบว่าจะค้นหาการเคลื่อนย้ายที่ไหน

ตัวอย่างเช่นฐานข้อมูล `animals` จะค้นหาการเคลื่อนย้ายในไดเรกทอรี `db/animals_migrate` และ
`primary` จะค้นหาใน `db/migrate` ตอนนี้ Rails generators รับคำสั่ง `--database`
เพื่อให้ไฟล์ถูกสร้างในไดเรกทอรีที่ถูกต้อง คำสั่งสามารถใช้ได้ดังนี้:

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

หากคุณใช้ Rails generators คำสั่ง scaffold และ model จะสร้างคลาสนามธรรมสำหรับคุณ คุณเพียงแค่ส่งคีย์ฐานข้อมูลไปยัง command line

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

คลาสที่มีชื่อฐานข้อมูลและ `Record` จะถูกสร้างขึ้น ในตัวอย่างนี้
ฐานข้อมูลคือ `Animals` ดังนั้นเราจะได้ `AnimalsRecord`:

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

โมเดลที่สร้างขึ้นจะสืบทอดจาก `AnimalsRecord` โดยอัตโนมัติ

```ruby
class Dog < AnimalsRecord
end
```
หมายเหตุ: เนื่องจาก Rails ไม่รู้ว่าฐานข้อมูลใดเป็นฐานข้อมูลสำหรับการเขียนของคุณ คุณจะต้องเพิ่มส่วนนี้ในคลาสหลังจากที่คุณเสร็จสิ้น

Rails จะสร้างคลาสใหม่เพียงครั้งเดียวเท่านั้น มันจะไม่ถูกเขียนทับด้วย scaffold ใหม่หรือถูกลบหาก scaffold ถูกลบไปแล้ว

หากคุณมีคลาสแบบ abstract และชื่อของมันแตกต่างจาก `AnimalsRecord` คุณสามารถส่ง `--parent` option เพื่อระบุว่าคุณต้องการคลาสแบบ abstract ที่แตกต่างกัน:

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

นี้จะข้ามการสร้าง `AnimalsRecord` เนื่องจากคุณได้แสดงให้ Rails รู้ว่าคุณต้องการใช้คลาสแบบ parent ที่แตกต่างกัน

## เปิดใช้งานการสลับบทบาทอัตโนมัติ

ในที่สุด เพื่อใช้งาน replica ในแอปพลิเคชันของคุณ คุณจะต้องเปิดใช้งาน middleware สำหรับการสลับอัตโนมัติ

การสลับอัตโนมัติช่วยให้แอปพลิเคชันสามารถสลับจาก writer ไปยัง replica หรือจาก replica ไปยัง writer โดยอิงจาก HTTP verb และว่ามีการเขียนล่าสุดโดยผู้ร้องขอหรือไม่

หากแอปพลิเคชันได้รับคำขอ POST, PUT, DELETE หรือ PATCH แอปพลิเคชันจะเขียนไปยังฐานข้อมูล writer โดยอัตโนมัติ สำหรับเวลาที่ระบุหลังจากการเขียน แอปพลิเคชันจะอ่านจาก primary สำหรับคำขอ GET หรือ HEAD แอปพลิเคชันจะอ่านจาก replica ยกเว้นกรณีมีการเขียนล่าสุด

เพื่อเปิดใช้งาน middleware สลับการเชื่อมต่ออัตโนมัติคุณสามารถเรียกใช้ generator สลับอัตโนมัติได้:

```bash
$ bin/rails g active_record:multi_db
```

แล้วคุณควรยกเลิกคอมเมนต์บรรทัดต่อไปนี้:

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

Rails รับประกัน "อ่านข้อมูลที่คุณเขียน" และจะส่งคำขอ GET หรือ HEAD ของคุณไปยัง writer หากอยู่ในหน้าต่าง `delay` โดยค่าเริ่มต้นคือ 2 วินาที คุณควรเปลี่ยนค่านี้ตามโครงสร้างฐานข้อมูลของคุณ Rails ไม่รับประกัน "อ่านข้อมูลที่เขียนล่าสุด" สำหรับผู้ใช้งานอื่นในหน้าต่าง `delay` และจะส่งคำขอ GET และ HEAD ไปยัง replicas ยกเว้นกรณีที่พวกเขาเขียนล่าสุด
การสลับการเชื่อมต่ออัตโนมัติใน Rails เป็นระบบที่ค่อนข้างเบื้องต้นและมีการจัดให้มีความยืดหยุ่นเพียงพอที่จะสามารถปรับแต่งได้โดยนักพัฒนาแอปพลิเคชัน

การตั้งค่าใน Rails ช่วยให้คุณสามารถเปลี่ยนวิธีการสลับและพารามิเตอร์ที่ใช้ในการสลับได้อย่างง่ายดาย ตัวอย่างเช่น ถ้าคุณต้องการใช้คุกกี้แทนเซสชันในการตัดสินใจเมื่อจะสลับการเชื่อมต่อ คุณสามารถเขียนคลาสของคุณเองได้:

```ruby
class MyCookieResolver << ActiveRecord::Middleware::DatabaseSelector::Resolver
  def self.call(request)
    new(request.cookies)
  end

  def initialize(cookies)
    @cookies = cookies
  end

  attr_reader :cookies

  def last_write_timestamp
    self.class.convert_timestamp_to_time(cookies[:last_write])
  end

  def update_last_write_timestamp
    cookies[:last_write] = self.class.convert_time_to_timestamp(Time.now)
  end

  def save(response)
  end
end
```

แล้วส่งคลาสนี้ให้กับ middleware:

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## การใช้การสลับการเชื่อมต่อด้วยตนเอง

มีบางกรณีที่คุณอาจต้องการให้แอปพลิเคชันของคุณเชื่อมต่อกับ writer หรือ replica และการสลับการเชื่อมต่ออัตโนมัติไม่เพียงพอ ตัวอย่างเช่น คุณอาจรู้ว่าสำหรับคำขอบางคำขอ คุณต้องการส่งคำขอไปยัง replica เสมอ แม้ว่าคุณจะอยู่ในเส้นทางคำขอ POST

ใน Rails มีเมธอด `connected_to` ที่จะสลับไปยังการเชื่อมต่อที่คุณต้องการ

```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # โค้ดทั้งหมดในบล็อกนี้จะเชื่อมต่อกับบทบาทการอ่าน
end
```

"บทบาท" ในการเรียกใช้ `connected_to` จะค้นหาการเชื่อมต่อที่เชื่อมต่อกับตัวจัดการการเชื่อมต่อ (หรือบทบาท) ตัวจัดการการเชื่อมต่อ `reading` จะเก็บการเชื่อมต่อทั้งหมดที่เชื่อมต่อผ่าน `connects_to` ด้วยชื่อบทบาท `reading`

โปรดทราบว่า `connected_to` ด้วยบทบาทจะค้นหาการเชื่อมต่อที่มีอยู่และสลับโดยใช้ชื่อของการระบุการเชื่อมต่อ นั่นหมายความว่าหากคุณส่งบทบาทที่ไม่รู้จักเช่น `connected_to(role: :nonexistent)` คุณจะได้รับข้อผิดพลาดที่กล่าวว่า `ActiveRecord::ConnectionNotEstablished (No connection pool for 'ActiveRecord::Base' found for the 'nonexistent' role.)`
หากคุณต้องการให้ Rails ตรวจสอบและให้แน่ใจว่าคำสั่งค้นหาที่ทำงานจะเป็นแบบอ่านเท่านั้น ให้ส่ง `prevent_writes: true` ไปให้
การทำเช่นนี้จะป้องกันไม่ให้คำสั่งค้นหาที่ดูเหมือนจะเป็นคำสั่งเขียนถูกส่งไปยังฐานข้อมูล
คุณควรกำหนดค่าฐานข้อมูลเรพลิกาให้ทำงานในโหมดอ่านอย่างเดียวด้วย

```ruby
ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
  # Rails จะตรวจสอบแต่ละคำสั่งค้นหาเพื่อให้แน่ใจว่าเป็นคำสั่งค้นหาเท่านั้น
end
```

## การแบ่งแยกแนวนอน

การแบ่งแยกแนวนอนคือเมื่อคุณแบ่งฐานข้อมูลของคุณเพื่อลดจำนวนแถวในแต่ละเซิร์ฟเวอร์ฐานข้อมูล แต่ยังคงรูปแบบเดียวกันใน "ชาร์ด" นี้เป็นที่เรียกกันว่า "multi-tenant" แบ่งแยก

API สำหรับการสนับสนุนการแบ่งแยกแนวนอนใน Rails คล้ายกับ API การใช้งานหลายฐานข้อมูล / การแบ่งแยกแนวตั้งที่มีอยู่ตั้งแต่ Rails 6.0

ชาร์ดถูกประกาศในไฟล์คอนฟิกสามชั้นดังนี้:

```yaml
production:
  primary:
    database: my_primary_database
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    adapter: mysql2
    replica: true
  primary_shard_one:
    database: my_primary_shard_one
    adapter: mysql2
  primary_shard_one_replica:
    database: my_primary_shard_one
    adapter: mysql2
    replica: true
```

จากนั้นให้เชื่อมต่อโมเดลด้วย `connects_to` API ผ่านคีย์ `shards`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

คุณไม่จำเป็นต้องใช้ `default` เป็นชื่อชาร์ดแรก  Rails จะถือว่าชื่อชาร์ดแรกในแฮช `connects_to` เป็นการเชื่อมต่อ "default" การเชื่อมต่อนี้ใช้ภายในเพื่อโหลดข้อมูลประเภทและข้อมูลอื่น ๆ ที่สกัดเอาไว้ที่รูปแบบเดียวกันในชาร์ดต่าง ๆ

จากนั้นโมเดลสามารถสลับการเชื่อมต่อด้วย `connected_to` API ได้ด้วยตนเอง หากใช้การแบ่งแยกแนวนอน จะต้องส่ง `role` และ `shard`:

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # สร้างเร็คคอร์ดในชาร์ดที่ชื่อ ":default"
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # ไม่สามารถค้นหาเร็คคอร์ดได้ เนื่องจากไม่มีอยู่เพราะถูกสร้าง
                   # ในชาร์ดที่ชื่อ ":default"
end
```
API การแบ่งแยกแนวนอนยังรองรับการสร้างสำเนาสำหรับการอ่านได้ด้วย คุณสามารถสลับบทบาทและชาร์ดด้วย API `connected_to` ได้

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # ค้นหาเรคคอร์ดจากสำเนาสำหรับการอ่านของชาร์ดหนึ่ง
end
```

## เปิดใช้งานการสลับชาร์ดอัตโนมัติ

แอปพลิเคชันสามารถสลับชาร์ดโดยอัตโนมัติต่อคำขอได้โดยใช้ middleware ที่ให้มา

Middleware `ShardSelector` ให้เฟรมเวิร์กสำหรับการสลับชาร์ดโดยอัตโนมัติ  Rails ให้เฟรมเวิร์กพื้นฐานในการกำหนดว่าจะสลับชาร์ดไปที่ไหน และอนุญาตให้แอปพลิเคชันเขียนกลยุทธ์สำหรับการสลับเองถ้าจำเป็น

`ShardSelector` รับชุดตัวเลือก (ในปัจจุบันรองรับเฉพาะ `lock`) ซึ่ง middleware สามารถใช้เพื่อเปลี่ยนพฤติกรรมได้ `lock` เป็นค่าเริ่มต้นเป็นจริงและจะห้ามคำขอจากการสลับชาร์ดเมื่ออยู่ในบล็อก หาก `lock` เป็นเท็จ การสลับชาร์ดจะได้รับอนุญาต สำหรับการแบ่งแยกตามผู้เช่า `lock` ควรเป็นจริงเสมอเพื่อป้องกันการสลับระหว่างผู้เช่าโดยอุบัติการณ์

สามารถใช้เครื่องมือเดียวกันกับตัวเลือกฐานข้อมูลเพื่อสร้างไฟล์สำหรับการสลับชาร์ดอัตโนมัติ:

```bash
$ bin/rails g active_record:multi_db
```

จากนั้นในไฟล์ ยกเลิกคำสั่งต่อไปนี้:

```ruby
Rails.application.configure do
  config.active_record.shard_selector = { lock: true }
  config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end
```

แอปพลิเคชันต้องให้รหัสสำหรับตัวแก้ไขเนื่องจากขึ้นอยู่กับโมเดลที่เฉพาะเจาะจงของแอปพลิเคชัน ตัวแก้ไขตัวอย่างอาจมีลักษณะดังนี้:

```ruby
config.active_record.shard_resolver = ->(request) {
  subdomain = request.subdomain
  tenant = Tenant.find_by_subdomain!(subdomain)
  tenant.shard
}
```

## การสลับการเชื่อมต่อฐานข้อมูลอย่างละเอียด

ใน Rails 6.1 สามารถสลับการเชื่อมต่อสำหรับฐานข้อมูลหนึ่งโดยไม่กระทบต่อฐานข้อมูลอื่นทั้งหมดในระดับโลกได้

ด้วยการสลับการเชื่อมต่อฐานข้อมูลอย่างละเอียด คลาสการเชื่อมต่อที่เป็นแบบนามธรรมจะสามารถสลับการเชื่อมต่อได้โดยไม่กระทบต่อการเชื่อมต่ออื่น สิ่งนี้เป็นประโยชน์ในการสลับการค้นหาของคุณจาก `AnimalsRecord` เพื่ออ่านจากสำเนา ในขณะที่ยังรักษาการค้นหาของ `ApplicationRecord` ให้ไปที่หลัก
```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # อ่านจาก animals_replica
  Person.first  # อ่านจาก primary
end
```

ยังสามารถเปลี่ยนการเชื่อมต่อได้อย่างละเอียดสำหรับชาร์ด

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # จะอ่านจาก shard_one_replica หากไม่มีการเชื่อมต่อสำหรับ shard_one_replica
  # จะเกิดข้อผิดพลาด ConnectionNotEstablished
  Person.first # จะอ่านจาก primary writer
end
```

ในการสลับเฉพาะคลัสเตอร์ฐานข้อมูลหลักใช้ `ApplicationRecord`:

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # อ่านจาก primary_shard_one_replica
  Dog.first # อ่านจาก animals_primary
end
```

`ActiveRecord::Base.connected_to` รักษาความสามารถในการสลับการเชื่อมต่อทั่วโลก

### การจัดการความสัมพันธ์ด้วยการเชื่อมต่อร่วมกันข้ามฐานข้อมูล

ตั้งแต่ Rails 7.0+ เป็นต้นไป, Active Record มีตัวเลือกในการจัดการความสัมพันธ์ที่จะดำเนินการเชื่อมต่อข้ามฐานข้อมูลหลายรายการ หากคุณมีความสัมพันธ์ has many through หรือ has one through ที่คุณต้องการปิดการเชื่อมต่อและดำเนินการคิวรี 2 หรือมากกว่า, ให้ส่ง `disable_joins: true` เป็นตัวเลือก

ตัวอย่าง:

```ruby
class Dog < AnimalsRecord
  has_many :treats, through: :humans, disable_joins: true
  has_many :humans

  has_one :home
  has_one :yard, through: :home, disable_joins: true
end

class Home
  belongs_to :dog
  has_one :yard
end

class Yard
  belongs_to :home
end
```

การเรียกใช้ `@dog.treats` โดยไม่มี `disable_joins` หรือ `@dog.yard` โดยไม่มี `disable_joins` จะเกิดข้อผิดพลาดเนื่องจากฐานข้อมูลไม่สามารถจัดการการเชื่อมต่อข้ามคลัสเตอร์ได้ ด้วยตัวเลือก `disable_joins`, Rails จะสร้างคิวรีเลือกหลายครั้งเพื่อหลีกเลี่ยงการพยายามเชื่อมต่อข้ามคลัสเตอร์ สำหรับความสัมพันธ์ข้างต้น, `@dog.treats` จะสร้าง SQL ต่อไปนี้:

```sql
SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
```

ในขณะที่ `@dog.yard` จะสร้าง SQL ต่อไปนี้:

```sql
SELECT "home"."id" FROM "homes" WHERE "homes"."dog_id" = ? [["dog_id", 1]]
SELECT "yards".* FROM "yards" WHERE "yards"."home_id" = ? [["home_id", 1]]
```

มีบางสิ่งที่สำคัญที่ควรรู้เกี่ยวกับตัวเลือกนี้:
1. อาจมีผลกระทบต่อประสิทธิภาพเนื่องจากตอนนี้จะมีการดำเนินการคิวรีสอบถามสองครั้งหรือมากกว่า (ขึ้นอยู่กับความสัมพันธ์) แทนที่จะเป็นการเชื่อมต่อ (join) หากการเลือกสำหรับ `humans` ส่งคืน ID จำนวนมาก การเลือกสำหรับ `treats` อาจส่ง ID มากเกินไป
2. เนื่องจากเราไม่ได้ดำเนินการเชื่อมต่อแล้ว คิวรีที่มีการจัดเรียงหรือกำหนดขีดจำกัดจะถูกจัดเรียงในหน่วยความจำเนื่องจากไม่สามารถนำลำดับจากตารางหนึ่งไปใช้กับตารางอื่นได้
3. ต้องเพิ่มการตั้งค่านี้ในความสัมพันธ์ทั้งหมดที่คุณต้องการปิดการเชื่อมต่อ รูปแบบของ Rails ไม่สามารถเดาได้เพราะการโหลดความสัมพันธ์เกิดขึ้นเมื่อมีการเรียกใช้งาน ในการโหลด `treats` ใน `@dog.treats` Rails ต้องรู้ว่า SQL ที่ควรสร้างเป็นอย่างไร

### การเก็บแคชสกีม่า

หากคุณต้องการโหลดแคชสกีม่าสำหรับแต่ละฐานข้อมูล คุณต้องตั้งค่า `schema_cache_path` ในการกำหนดค่าฐานข้อมูลและตั้งค่า `config.active_record.lazily_load_schema_cache = true` ในการกำหนดค่าแอปพลิเคชันของคุณ โปรดทราบว่านี้จะโหลดแคชสกีม่าเมื่อเชื่อมต่อฐานข้อมูล

## ข้อควรระวัง

### การทดลองสมดุลเซิร์ฟเวอร์

Rails ยังไม่รองรับการทดลองสมดุลของเซิร์ฟเวอร์อัตโนมัติ นี่ขึ้นอยู่กับโครงสร้างพื้นฐานของคุณ ในอนาคตเราอาจจะนำเสนอการทดลองสมดุลเบื้องต้น แต่สำหรับแอปพลิเคชันในขนาดใหญ่นี้ควรให้แอปพลิเคชันของคุณจัดการเรื่องนี้นอกเหนือจาก Rails
