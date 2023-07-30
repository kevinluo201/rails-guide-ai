**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: dd2584972aa8eae419ed5d55a287e27d
บันทึกการเปิดตัวของ Ruby on Rails 3.0
===============================

Rails 3.0 เป็นการมีม้าและสายรุ้ง! มันจะทำอาหารให้คุณและพับเสื้อผ้าของคุณ คุณจะสงสัยว่าชีวิตเคยเป็นไปได้ก่อนที่มันจะมาถึง มันเป็นเวอร์ชันที่ดีที่สุดของ Rails ที่เราเคยทำ!

แต่จริงๆแล้ว มันเป็นสิ่งที่ดีจริงๆ มีไอเดียที่ดีทั้งหมดที่นำมาจากทีม Merb เมื่อเข้าร่วมงานและเน้นไปที่ความเป็นเฟรมเวิร์กที่เป็นอิสระ, ส่วนที่เล็กลงและเร็วขึ้น, และ API ที่อร่อยมาก หากคุณมาใช้ Rails 3.0 จาก Merb 1.x คุณควรจะรู้จักมากมาย หากคุณมาจาก Rails 2.x คุณจะตกหลุมรักมันเช่นกัน

แม้ว่าคุณจะไม่สนใจเรื่องการทำความสะอาดภายในของเรา แต่ Rails 3.0 จะทำให้คุณตื่นเต้น มีคุณลักษณะใหม่และ API ที่ปรับปรุง นี่เป็นเวลาที่ดีที่สุดสำหรับนักพัฒนา Rails บางส่วนของไฮไลต์ได้แก่:

* เราเปลี่ยนเส้นทางใหม่ที่เน้นการประกาศที่เป็น RESTful
* API ใหม่ของ Action Mailer ที่ออกแบบตาม Action Controller (ตอนนี้ไม่ต้องทำให้เจ็บปวดเมื่อส่งข้อความหลายส่วน!)
* ภาษาคิวรี่ Active Record ใหม่ที่สามารถเชื่อมต่อกันได้และสร้างขึ้นบนพื้นฐานของพีชคณิตสัมพันธ์
* ตัวช่วย JavaScript ที่ไม่รบกวนพร้อมกับไดรเวอร์สำหรับ Prototype, jQuery และอื่นๆ (สิ้นสุดการใช้งาน JS แบบอินไลน์)
* การจัดการความสัมพันธ์แบบชัดเจนด้วย Bundler

นอกจากนี้เราได้พยายามที่จะเลิกใช้ API เก่าด้วยการแจ้งเตือนที่ดี ซึ่งหมายความว่าคุณสามารถย้ายแอปพลิเคชันที่มีอยู่ของคุณไปยัง Rails 3 โดยไม่ต้องเขียนรหัสเก่าของคุณใหม่ตามหลักการที่ดีที่สุดทันที

บันทึกการเปิดตัวเหล่านี้ครอบคลุมการอัปเกรดที่สำคัญ แต่ไม่รวมถึงการแก้ไขข้อบกพร่องเล็กๆ และการเปลี่ยนแปลงทั้งหมด Rails 3.0 ประกอบด้วยการเปลี่ยนแปลงเกือบ 4,000 ครั้งโดยผู้เขียนมากกว่า 250 คน! หากคุณต้องการดูทุกอย่าง โปรดตรวจสอบ [รายการการเปลี่ยนแปลง](https://github.com/rails/rails/commits/3-0-stable) ในเก็บรวบรวม Rails หลักบน GitHub.
การติดตั้ง Rails 3:

```bash
# ใช้ sudo หากการติดตั้งของคุณต้องการ
$ gem install rails
```


การอัปเกรดไปยัง Rails 3
--------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดก่อนเป็น Rails 2.3.5 และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานได้ตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 3 จากนั้นคุณควรทำตามขั้นตอนต่อไปนี้:

### Rails 3 ต้องการ Ruby 1.8.7 ขึ้นไป

Rails 3.0 ต้องการ Ruby 1.8.7 หรือสูงกว่า การสนับสนุนสำหรับเวอร์ชัน Ruby ก่อนหน้านี้ทั้งหมดถูกยกเลิกอย่างเป็นทางการและคุณควรอัปเกรดให้เร็วที่สุด Rails 3.0 ยังเข้ากันได้กับ Ruby 1.9.2

เคล็ดลับ: โปรดทราบว่า Ruby 1.8.7 p248 และ p249 มีข้อบกพร่องในการมาร์ชลิ่งที่ทำให้ Rails 3.0 ล้มเหลว แต่ Ruby Enterprise Edition ได้แก้ไขปัญหาเหล่านี้ตั้งแต่เวอร์ชัน 1.8.7-2010.02 สำหรับเวอร์ชัน 1.9 Ruby 1.9.1 ไม่สามารถใช้งานได้เพราะมันเกิดข้อผิดพลาดทันทีใน Rails 3.0 ดังนั้นหากคุณต้องการใช้ Rails 3 กับ 1.9.x คุณควรใช้เวอร์ชัน 1.9.2 เพื่อการทำงานที่ราบรื่น

### วัตถุประสงค์ของแอปพลิเคชัน Rails

เป็นส่วนหนึ่งของการเตรียมพื้นฐานสำหรับการรองรับการเรียกใช้งานแอปพลิเคชัน Rails หลายรายการในกระบวนการเดียวกัน Rails 3 นำเสนอแนวคิดของวัตถุประสงค์ของแอปพลิเคชัน วัตถุประสงค์ของแอปพลิเคชันเก็บรวบรวมการกำหนดค่าที่เฉพาะเจาะจงของแอปพลิเคชันและคล้ายกับ `config/environment.rb` จากเวอร์ชันก่อนหน้าของ Rails

แต่ละแอปพลิเคชัน Rails ต้องมีวัตถุประสงค์ของแอปพลิเคชันที่เกี่ยวข้อง วัตถุประสงค์ของแอปพลิเคชันถูกกำหนดไว้ใน `config/application.rb` หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่เป็น Rails 3 คุณต้องเพิ่มไฟล์นี้และย้ายการกำหนดค่าที่เหมาะสมจาก `config/environment.rb` เข้าไปใน `config/application.rb`

### script/* ถูกแทนที่ด้วย script/rails

`script/rails` ใหม่แทนที่สคริปต์ทั้งหมดที่อยู่ในไดเรกทอรี `script` คุณไม่ต้องเรียกใช้ `script/rails` โดยตรง คำสั่ง `rails` จะตรวจจับว่ามันถูกเรียกใช้ในรากของแอปพลิเคชัน Rails และเรียกใช้สคริปต์ให้คุณ การใช้งานที่ตั้งใจคือ:
```bash
$ rails console                      # แทนที่ script/console
$ rails g scaffold post title:string # แทนที่ script/generate scaffold post title:string
```

รัน `rails --help` เพื่อดูรายการตัวเลือกทั้งหมด

### ขึ้นอยู่กับ Dependencies และ config.gem

เมธอด `config.gem` ได้ถูกลบออกและถูกแทนที่ด้วยการใช้ `bundler` และ `Gemfile` ดูเพิ่มเติมที่ [Vendoring Gems](#vendoring-gems) ด้านล่าง

### กระบวนการอัพเกรด

เพื่อช่วยในกระบวนการอัพเกรด มีปลั๊กอินชื่อ [Rails Upgrade](https://github.com/rails/rails_upgrade) ถูกสร้างขึ้นเพื่อทำงานอัตโนมัติบางส่วน

เพียงติดตั้งปลั๊กอิน จากนั้นรัน `rake rails:upgrade:check` เพื่อตรวจสอบแอปของคุณว่ามีส่วนที่ต้องอัพเดตหรือไม่ (พร้อมลิงก์ไปยังข้อมูลเพิ่มเติมเกี่ยวกับวิธีการอัพเดต) มันยังมีการเสนองานที่จะสร้าง `Gemfile` จากการเรียกใช้ `config.gem` ปัจจุบันและงานที่จะสร้างไฟล์เส้นทางใหม่จากไฟล์เส้นทางปัจจุบันของคุณ ในการรับปลั๊กอิน ให้รันคำสั่งต่อไปนี้:

```bash
$ ruby script/plugin install git://github.com/rails/rails_upgrade.git
```

คุณสามารถดูตัวอย่างการทำงานได้ที่ [Rails Upgrade is now an Official Plugin](http://omgbloglol.com/post/364624593/rails-upgrade-is-now-an-official-plugin)

นอกเหนือจากเครื่องมือ Rails Upgrade หากคุณต้องการความช่วยเหลือเพิ่มเติม มีผู้คนใน IRC และ [rubyonrails-talk](https://discuss.rubyonrails.org/c/rubyonrails-talk) ที่อาจกำลังทำเหมือนกัน อาจเจอปัญหาเดียวกัน โปรดเขียนบล็อกเกี่ยวกับประสบการณ์ของคุณในการอัพเกรดเพื่อให้ผู้อื่นได้รับประโยชน์จากความรู้ของคุณ!

การสร้างแอปพลิเคชัน Rails 3.0
--------------------------------

```bash
# คุณควรมี 'rails' RubyGem ติดตั้งแล้ว
$ rails new myapp
$ cd myapp
```

### Vendoring Gems

Rails ใช้ `Gemfile` ในรากแอปพลิเคชันเพื่อกำหนด gem ที่คุณต้องการให้แอปพลิเคชันเริ่มต้น ไฟล์ `Gemfile` นี้จะถูกประมวลผลโดย [Bundler](https://github.com/bundler/bundler) ซึ่งจะติดตั้ง dependencies ทั้งหมดของคุณ มันยังสามารถติดตั้ง dependencies ทั้งหมดไปยังแอปพลิเคชันของคุณเองเพื่อไม่ต้องพึ่งพา system gems

ข้อมูลเพิ่มเติม: - [bundler homepage](https://bundler.io/)

### อยู่ในระดับล่าง

`Bundler` และ `Gemfile` ทำให้การแช่แข็งแอปพลิเคชัน Rails ของคุณง่ายดายด้วยคำสั่ง `bundle` ที่เป็นคำสั่งที่ได้รับมอบหมายเฉพาะ ดังนั้น `rake freeze` ไม่เกี่ยวข้องและถูกลบออก
หากคุณต้องการที่จะรวมกลุ่มตรงจากที่เก็บรักษา Git คุณสามารถส่ง `--edge` แฟล็ก:

```bash
$ rails new myapp --edge
```

หากคุณมีการตรวจสอบท้องถิ่นของเก็บรักษา Rails และต้องการสร้างแอปพลิเคชันโดยใช้นั้นคุณสามารถส่ง `--dev` แฟล็ก:

```bash
$ ruby /path/to/rails/bin/rails new myapp --dev
```

การเปลี่ยนแปลงทางสถาปัตยกรรมของ Rails
---------------------------

มีการเปลี่ยนแปลงทางสถาปัตยกรรมของ Rails ทั้งหมด 6 ข้อสำคัญ

### Railties Restrung

Railties ได้รับการอัปเดตเพื่อให้มี API ปลั๊กอินที่สอดคล้องกันสำหรับเฟรมเวิร์ก Rails ทั้งหมดรวมถึงการเขียนใหม่ทั้งหมดของ generators และ Rails bindings ผลลัพธ์คือนักพัฒนาสามารถเชื่อมต่อกับขั้นตอนสำคัญใด ๆ ของ generators และโครงสร้างแอปพลิเคชันได้อย่างสม่ำเสมอและกำหนดไว้

### ส่วนประกอบคอร์ของ Rails ทั้งหมดถูกแยกออกจากกัน

ด้วยการผสมรวมของ Merb และ Rails หนึ่งในงานที่ใหญ่คือการลดการผูกติดที่แน่นหนาระหว่างส่วนประกอบคอร์ของ Rails นี้ได้รับการทำสำเร็จแล้ว และส่วนประกอบคอร์ของ Rails ทั้งหมดใช้ API เดียวกันที่คุณสามารถใช้สำหรับการพัฒนาปลั๊กอิน นี่หมายความว่าปลั๊กอินใด ๆ ที่คุณทำหรือส่วนประกอบคอร์ที่เปลี่ยนแปลง (เช่น DataMapper หรือ Sequel) สามารถเข้าถึงฟังก์ชันทั้งหมดที่ส่วนประกอบคอร์ของ Rails มีการเข้าถึงและขยายของตนเองได้

ข้อมูลเพิ่มเติม: - [The Great Decoupling](http://yehudakatz.com/2009/07/19/rails-3-the-great-decoupling/)


### การแยกตัวอย่าง Active Model

ส่วนหนึ่งของการแยกส่วนประกอบคอร์คือการแยกการเชื่อมต่อทั้งหมดกับ Active Record จาก Action Pack นี้ได้รับการทำสำเร็จแล้ว ปลั๊กอิน ORM ใหม่ทั้งหมดตอนนี้เพียงแค่ต้องประยุกต์ใช้อินเทอร์เฟซ Active Model เพื่อทำงานร่วมกับ Action Pack ได้อย่างราบรื่น

ข้อมูลเพิ่มเติม: - [Make Any Ruby Object Feel Like ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### การแยกตัวอย่าง Controller

ส่วนหนึ่งของการแยกส่วนประกอบคอร์คือการสร้างคลาสเบสที่แยกออกจากแนวคิดของ HTTP เพื่อจัดการการแสดงผลของมุมมอง ฯลฯ การสร้าง `AbstractController` นี้ช่วยให้ `ActionController` และ `ActionMailer` ได้รับการบรรลุเป้าหมายอย่างมากด้วยการลดรหัสที่ซ้ำซ้อนออกจากไลบรารีเหล่านี้ทั้งหมดและนำไปยัง Abstract Controller
ข้อมูลเพิ่มเติม: - [Rails Edge Architecture](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### การผสานรวม Arel

[Arel](https://github.com/brynary/arel) (หรือ Active Relation) ถูกนำมาใช้เป็นพื้นฐานของ Active Record และต้องใช้สำหรับ Rails ตอนนี้ Arel ให้การสร้างสรรค์ SQL ที่ทำให้ Active Record ง่ายขึ้นและให้พื้นฐานสำหรับฟังก์ชันการเชื่อมโยงใน Active Record

ข้อมูลเพิ่มเติม: - [ทำไมฉันเขียน Arel](https://web.archive.org/web/20120718093140/http://magicscalingsprinkles.wordpress.com/2010/01/28/why-i-wrote-arel/)


### การแยกออกจากการสกัดอีเมล

Action Mailer ตั้งแต่เริ่มต้นมีการแก้ไขโค้ด, ตัวแยกก่อน, และตัวส่งและตัวรับทั้งหมดนอกเหนือจากการให้ TMail ในต้นฉบับของต้นไม้เวอร์ชัน 3 เปลี่ยนแปลงด้วยความสามารถที่เกี่ยวข้องกับข้อความอีเมลทั้งหมดถูกแยกออกไปยังแพ็กเกจ [Mail](https://github.com/mikel/mail) นี้ลดการทำซ้ำของโค้ดและช่วยสร้างขอบเขตที่กำหนดได้ระหว่าง Action Mailer และตัวแยกอีเมล

ข้อมูลเพิ่มเติม: - [API ใหม่ของ Action Mailer ใน Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)


เอกสาร
-------------

เอกสารในต้นไม้ของ Rails กำลังอัปเดตด้วยการเปลี่ยนแปลง API ทั้งหมดนอกจากนี้ [Rails Edge Guides](https://edgeguides.rubyonrails.org/) กำลังอัปเดตทีละหนึ่งเพื่อสะท้อนการเปลี่ยนแปลงใน Rails 3.0 เอกสารที่ [guides.rubyonrails.org](https://guides.rubyonrails.org/) อย่างไรก็ตามจะยังคงมีเฉพาะเวอร์ชันที่เสถียร (ในจุดนี้คือเวอร์ชัน 2.3.5 จนกว่า 3.0 จะถูกเปิดตัว)

ข้อมูลเพิ่มเติม: - [โครงการเอกสาร Rails](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)


การรองรับการแปลภาษา
--------------------

มีการทำงานจำนวนมากเกี่ยวกับการรองรับ I18n ใน Rails 3 รวมถึง [I18n](https://github.com/svenfuchs/i18n) gem ล่าสุดที่ให้ความเร็วมากขึ้น

* I18n สำหรับวัตถุใดก็ได้ - พฤติกรรม I18n สามารถเพิ่มได้ในวัตถุใดก็ได้โดยการรวม `ActiveModel::Translation` และ `ActiveModel::Validations` ยังมีการสำรองข้อความ `errors.messages` สำหรับการแปล
* แอตทริบิวต์สามารถมีการแปลเริ่มต้นได้
* แท็กส่งฟอร์มจะดึงสถานะที่ถูกต้อง (สร้างหรืออัปเดต) ขึ้นอัตโนมัติตามสถานะของวัตถุ และดึงการแปลที่ถูกต้อง
* ป้ายชื่อด้วย I18n ทำงานได้โดยการส่งชื่อแอตทริบิวต์เท่านั้น

ข้อมูลเพิ่มเติม: - [การเปลี่ยนแปลง I18n ใน Rails 3](http://blog.plataformatec.com.br/2010/02/rails-3-i18n-changes/)


Railties
--------

ด้วยการแยกตัวระบบหลักของ Rails, Railties ได้รับการปรับปรุงใหญ่เพื่อทำให้การเชื่อมโยงระหว่างตัวระบบ เอนจิน หรือปลั๊กอินเป็นเรื่องง่ายและสามารถขยายได้สะดวกที่สุด:
* แอปพลิเคชันแต่ละตัวตอนนี้มีเนมสเปซของตัวเอง แอปพลิเคชันจะเริ่มต้นด้วย `YourAppName.boot` เช่น เพื่อทำให้การติดต่อกับแอปพลิเคชันอื่น ๆ ง่ายขึ้นมาก
* ทุกอย่างที่อยู่ภายใต้ `Rails.root/app` ถูกเพิ่มเข้าไปในเส้นทางการโหลด ดังนั้นคุณสามารถสร้าง `app/observers/user_observer.rb` และ Rails จะโหลดมันโดยไม่ต้องแก้ไขใด ๆ
* Rails 3.0 ให้บริการวัตถุ `Rails.config` ซึ่งเป็นที่เก็บรวบรวมของตัวเลือกการกำหนดค่าทั่วทั้ง Rails

การสร้างแอปพลิเคชันได้รับการเพิ่มค่าฟล็อกเพิ่มเติมที่ช่วยให้คุณสามารถข้ามการติดตั้ง test-unit, Active Record, Prototype และ Git ได้ นอกจากนี้ยังเพิ่มฟล็อกใหม่ `--dev` ซึ่งจะตั้งค่าแอปพลิเคชันของคุณด้วย `Gemfile` ที่ชี้ไปยังการเช็คเอาท์ของ Rails ของคุณ (ซึ่งจะกำหนดโดยเส้นทางไปยังไบนารี `rails`) ดู `rails --help` สำหรับข้อมูลเพิ่มเติม

ตัวสร้าง Railties ได้รับการให้ความสนใจอย่างมากใน Rails 3.0 โดยสรุป:

* ตัวสร้างถูกเขียนใหม่ทั้งหมดและเข้ากันได้ย้อนหลังไม่ได้
* ตัวสร้าง API และตัวสร้าง API ถูกผสานเข้าด้วยกัน (เป็นเหมือนเดิม)
* ตัวสร้างไม่ได้โหลดจากเส้นทางพิเศษอีกต่อไป แต่พวกเขาเพียงแค่พบในเส้นทางการโหลด Ruby ดังนั้นการเรียกใช้ `rails generate foo` จะมองหา `generators/foo_generator`
* ตัวสร้างใหม่ให้การเชื่อมต่อ ดังนั้นเครื่องมือเทมเพลต ฐานข้อมูล ORM และเครื่องมือทดสอบสามารถเชื่อมต่อได้อย่างง่ายดาย
* ตัวสร้างใหม่ช่วยให้คุณสามารถแทนที่เทมเพลตได้โดยวางสำเนาไว้ที่ `Rails.root/lib/templates`
* `Rails::Generators::TestCase` ยังมีให้ใช้งานเพื่อให้คุณสร้างตัวสร้างของคุณเองและทดสอบ

นอกจากนี้ มีการปรับปรุงบางอย่างในมุมมองที่สร้างขึ้นโดยตัวสร้าง Railties:

* มุมมองใช้แท็ก `div` แทนแท็ก `p`
* การสร้างโครงสร้างใช้ partial `_form` แทนการทำซ้ำโค้ดในมุมมองแก้ไขและมุมมองใหม่
* แบบฟอร์มของโครงสร้างใช้ `f.submit` ซึ่งจะคืนค่า "สร้าง ModelName" หรือ "อัปเดต ModelName" ขึ้นอยู่กับสถานะของออบเจกต์ที่ถ่ายทอด

สุดท้าย มีการเพิ่มความสามารถให้กับงาน rake อีกสองอย่าง:
* เพิ่ม `rake db:forward` เพื่อให้คุณสามารถเลื่อนการทำงานของการเรียกใช้งานได้แยกตามลำดับหรือกลุ่ม
* เพิ่ม `rake routes CONTROLLER=x` เพื่อให้คุณสามารถดูเส้นทางสำหรับคอนโทรลเลอร์เพียงคนเดียว

Railties ตอนนี้เลิกใช้งาน:

* `RAILS_ROOT` เปลี่ยนเป็น `Rails.root`,
* `RAILS_ENV` เปลี่ยนเป็น `Rails.env`, และ
* `RAILS_DEFAULT_LOGGER` เปลี่ยนเป็น `Rails.logger`.

`PLUGIN/rails/tasks` และ `PLUGIN/tasks` ไม่ได้โหลดงานทั้งหมดแล้ว ตอนนี้ต้องอยู่ใน `PLUGIN/lib/tasks` เท่านั้น

ข้อมูลเพิ่มเติม:

* [การค้นพบเจเนอเรเตอร์ Rails 3](http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators)
* [โมดูล Rails (ใน Rails 3)](http://quaran.to/blog/2010/02/03/the-rails-module/)

Action Pack
-----------

มีการเปลี่ยนแปลงที่สำคัญทั้งภายในและภายนอกใน Action Pack


### Abstract Controller

Abstract Controller ถอดส่วนที่เป็นทั่วไปของ Action Controller ออกมาเป็นโมดูลที่สามารถใช้ซ้ำได้โดยไลบรารีใดก็ได้เพื่อแสดงเทมเพลต แสดงส่วนบางส่วน เช่น ช่วยเหลือ การแปลภาษา การเข้าถึงข้อมูลการร้องขอ ฯลฯ การทำนายนี้ช่วยให้ `ActionMailer::Base` สามารถสืบทอดจาก `AbstractController` และใช้ DSL ของ Rails บน Mail gem ได้

นอกจากนี้ยังช่วยให้ Action Controller สามารถทำความสะอาดโค้ดได้ง่ายขึ้น

อย่างไรก็ตาม Abstract Controller ไม่ใช่ API ที่ใช้กับผู้ใช้ คุณจะไม่พบมันในการใช้งานประจำวันของคุณใน Rails

ข้อมูลเพิ่มเติม: - [สถาปัตยกรรมของ Rails Edge](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Action Controller

* `application_controller.rb` ตอนนี้มี `protect_from_forgery` เปิดใช้งานโดยค่าเริ่มต้น
* `cookie_verifier_secret` ถูกยกเลิกและตอนนี้จะกำหนดผ่าน `Rails.application.config.cookie_secret` และย้ายไปยังไฟล์ของตัวเอง: `config/initializers/cookie_verification_secret.rb`
* `session_store` ถูกกำหนดค่าใน `ActionController::Base.session` และตอนนี้ย้ายไปที่ `Rails.application.config.session_store` ค่าเริ่มต้นถูกกำหนดใน `config/initializers/session_store.rb`
* `cookies.secure` ช่วยให้คุณสามารถตั้งค่าค่าที่เข้ารหัสในคุกกี้ได้ด้วย `cookie.secure[:key] => value`
* `cookies.permanent` ช่วยให้คุณสามารถตั้งค่าค่าถาวรในแฮชคุกกี้ `cookie.permanent[:key] => value` ซึ่งจะเกิดข้อยกเว้นในค่าที่เข้ารหัสถ้าการตรวจสอบล้มเหลว
* ตอนนี้คุณสามารถส่ง `:notice => 'This is a flash message'` หรือ `:alert => 'Something went wrong'` ไปยังการเรียกใช้งาน `format` ภายในบล็อก `respond_to` ได้ เฮช `flash[]` ยังทำงานเหมือนเดิม
* เพิ่มเมธอด `respond_with` เข้ามาในคอนโทรลเลอร์ของคุณเพื่อทำให้บล็อก `format` ง่ายขึ้น
* เพิ่ม `ActionController::Responder` เพื่อให้คุณสามารถกำหนดการตอบสนองได้อย่างยืดหยุ่น
การเลิกใช้งาน:

* `filter_parameter_logging` ถูกเลิกใช้แล้วและแนะนำให้ใช้ `config.filter_parameters << :password` แทน

ข้อมูลเพิ่มเติม:

* [ตัวเลือกการเรนเดอร์ใน Rails 3](https://blog.engineyard.com/2010/render-options-in-rails-3)
* [สามเหตุผลในการรักใคร่กับ ActionController::Responder](https://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder)


### Action Dispatch

Action Dispatch เป็นความสามารถใหม่ใน Rails 3.0 และมีการปรับปรุงใหม่ที่สะอาดและดีกว่าในการเรียกใช้เส้นทาง (routing) 

* ทำความสะอาดและเขียนใหม่ให้กับเราท์เตอร์ ทำให้เราท์เตอร์ของ Rails เป็น `rack_mount` ที่มี DSL ของ Rails อยู่ด้านบน และเป็นซอฟต์แวร์ที่สามารถทำงานอิสระได้
* เส้นทางที่ถูกกำหนดโดยแอปพลิเคชันแต่ละตัวจะถูกเก็บในเนมสเปซของโมดูลแอปพลิเคชันของคุณ นั่นคือ:

    ```ruby
    # แทนที่:

    ActionController::Routing::Routes.draw do |map|
      map.resources :posts
    end

    # คุณจะใช้:

    AppName::Application.routes do
      resources :posts
    end
    ```

* เพิ่มเมธอด `match` ให้กับเราท์เตอร์ คุณยังสามารถส่งแอปพลิเคชัน Rack ใดๆไปยังเส้นทางที่ตรงกันได้
* เพิ่มเมธอด `constraints` ให้กับเราท์เตอร์ เพื่อให้คุณสามารถรักษาเส้นทางด้วยเงื่อนไขที่กำหนดได้
* เพิ่มเมธอด `scope` ให้กับเราท์เตอร์ เพื่อให้คุณสามารถสร้างเนมสเปซสำหรับเส้นทางที่แตกต่างกันสำหรับภาษาหรือการกระทำที่แตกต่างกัน เช่น:

    ```ruby
    scope 'es' do
      resources :projects, :path_names => { :edit => 'cambiar' }, :path => 'proyecto'
    end

    # จะให้คุณได้การกระทำแก้ไขด้วย /es/proyecto/1/cambiar
    ```

* เพิ่มเมธอด `root` ให้กับเราท์เตอร์เป็นทางลัดสำหรับ `match '/', :to => path`
* คุณสามารถส่งส่วนที่เป็นตัวเลือกเข้าไปในการเรียกใช้เส้นทาง เช่น `match "/:controller(/:action(/:id))(.:format)"` แต่ละส่วนที่อยู่ในวงเล็บเป็นส่วนเลือก
* เส้นทางสามารถถูกแสดงผ่านบล็อกได้ เช่นคุณสามารถเรียกใช้ `controller :home { match '/:action' }`


หมายเหตุ: คำสั่งแบบเก่า `map` ยังคงทำงานเหมือนเดิมด้วยชั้นความเข้ากันได้ย้อนหลัง แต่สิ่งนี้จะถูกลบออกในเวอร์ชัน 3.1

การเลิกใช้งาน

* เส้นทางที่รับค่าทั้งหมดสำหรับแอปพลิเคชันที่ไม่ใช่ REST (`/:controller/:action/:id`) ถูกคอมเมนท์ออกแล้ว
* เส้นทาง `:path_prefix` ไม่มีอยู่แล้วและ `:name_prefix` ตอนนี้จะเพิ่ม "_" ที่ส่วนที่กำหนดไว้

ข้อมูลเพิ่มเติม:
* [เราท์เตอร์ Rails 3: Rack it Up](http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/)
* [การปรับปรุงเส้นทางใน Rails 3](https://medium.com/fusion-of-thoughts/revamped-routes-in-rails-3-b6d00654e5b0)
* [การกระทำทั่วไปใน Rails 3](http://yehudakatz.com/2009/12/20/generic-actions-in-rails-3/)
### Action View

#### Unobtrusive JavaScript

มีการเขียนใหม่ใน Action View helpers โดยการนำเข้า Unobtrusive JavaScript (UJS) hooks และลบคำสั่ง AJAX แบบ inline เก่าออก นี้ทำให้ Rails สามารถใช้ UJS driver ที่เป็นไปตามมาตรฐานใดก็ได้เพื่อนำเข้า UJS hooks ใน helpers

สิ่งที่เปลี่ยนแปลงคือ การลบ helpers `remote_<method>` ทั้งหมดออกจาก Rails core และย้ายไปยัง [Prototype Legacy Helper](https://github.com/rails/prototype_legacy_helper) ในการใส่ UJS hooks เข้าไปใน HTML ของคุณ คุณต้องส่ง `:remote => true` แทน ตัวอย่างเช่น:

```ruby
form_for @post, :remote => true
```

จะสร้าง:

```html
<form action="http://host.com" id="create-post" method="post" data-remote="true">
```

#### Helpers ที่มี Blocks

Helpers เช่น `form_for` หรือ `div_for` ที่แทรกเนื้อหาจาก block ต้องใช้ `<%=` เท่านั้น:

```html+erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

Helpers ของคุณที่เป็นแบบนี้คาดหวังว่าจะส่งคืนสตริง แทนที่จะเพิ่มเข้าไปใน output buffer ด้วยตนเอง

Helpers ที่ทำอย่างอื่น เช่น `cache` หรือ `content_for` ไม่ได้รับผลกระทบจากการเปลี่ยนแปลงนี้ ต้องใช้ `&lt;%` เหมือนเดิม

#### การเปลี่ยนแปลงอื่นๆ

* คุณไม่ต้องเรียกใช้ `h(string)` เพื่อหนีไปจากการแสดงผล HTML แล้ว เพราะมันถูกเปิดใช้งานโดยค่าเริ่มต้นในเทมเพลตทั้งหมด หากคุณต้องการสตริงที่ไม่ได้หนีไป ให้เรียกใช้ `raw(string)`
* Helpers ตอนนี้เริ่มแสดงผลเป็น HTML5 โดยค่าเริ่มต้น
* Form label helper ตอนนี้ดึงค่าจาก I18n ด้วยค่าเดียว ดังนั้น `f.label :name` จะดึงค่าแปลของ `:name`
* I18n select label ควรเป็น :en.helpers.select แทน :en.support.select
* คุณไม่ต้องใส่เครื่องหมายลบที่สุดของการตัดตัวแปร Ruby ภายในเทมเพลต ERB เพื่อลบการเปลี่ยนบรรทัดท้ายในการแสดงผล HTML
* เพิ่ม `grouped_collection_select` helper เข้าไปใน Action View
* เพิ่ม `content_for?` เพื่อให้คุณตรวจสอบการมีเนื้อหาใน view ก่อนที่จะแสดงผล
* การส่ง `:value => nil` ให้กับ form helpers จะตั้งค่า `value` attribute ของฟิลด์เป็น nil แทนที่จะใช้ค่าเริ่มต้น
* การส่ง `:id => nil` ให้กับ form helpers จะทำให้ฟิลด์เหล่านั้นถูกแสดงผลโดยไม่มี `id` attribute
* การส่ง `:alt => nil` ให้กับ `image_tag` จะทำให้แท็ก `img` ถูกแสดงโดยไม่มี `alt` attribute
Active Model
------------

Active Model เป็นความสามารถใหม่ใน Rails 3.0 มันให้ชั้นข้อมูลระดับสายตามมาตรฐานใดก็ได้ที่จะใช้สื่อสารกับ Rails โดยการนำเสนออินเตอร์เฟส Active Model


### ORM Abstraction และ Action Pack Interface

ส่วนหนึ่งของการแยกส่วนคอมโพเนนต์หลักคือการแยก Active Record ออกจาก Action Pack ซึ่งได้เสร็จสมบูรณ์แล้ว ปลั๊กอิน ORM ใหม่ทั้งหมดต้องนำเสนออินเตอร์เฟส Active Model เพื่อทำงานร่วมกับ Action Pack ได้อย่างราบรื่น

ข้อมูลเพิ่มเติม: - [ทำให้วัตถุ Ruby ใด ๆ รู้สึกเหมือน ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### การตรวจสอบความถูกต้อง

การตรวจสอบความถูกต้องได้ถูกย้ายจาก Active Record เข้าสู่ Active Model เพื่อให้มีอินเตอร์เฟสสำหรับการตรวจสอบความถูกต้องที่ทำงานร่วมกับไลบรารี ORM ใน Rails 3

* มีเมธอดทางลัด `validates :attribute, options_hash` ที่ให้คุณสามารถส่งตัวเลือกสำหรับเมธอด validates ทั้งหมดได้ คุณสามารถส่งตัวเลือกมากกว่าหนึ่งตัวเลือกได้ในเมธอด validate เดียว
* เมธอด validates มีตัวเลือกต่อไปนี้:
    * `:acceptance => Boolean`.
    * `:confirmation => Boolean`.
    * `:exclusion => { :in => Enumerable }`.
    * `:inclusion => { :in => Enumerable }`.
    * `:format => { :with => Regexp, :on => :create }`.
    * `:length => { :maximum => Fixnum }`.
    * `:numericality => Boolean`.
    * `:presence => Boolean`.
    * `:uniqueness => Boolean`.

หมายเหตุ: เมธอดการตรวจสอบความถูกต้องรูปแบบเดิมของ Rails เวอร์ชัน 2.3 ยังคงรองรับใน Rails 3.0 เมธอด validates ใหม่ถูกออกแบบเพื่อเป็นการช่วยเหลือเพิ่มเติมในการตรวจสอบความถูกต้องของโมเดลของคุณ และไม่ได้เป็นการแทนที่ API ที่มีอยู่ในปัจจุบัน

คุณยังสามารถส่งออบเจกต์ตัวตรวจสอบเข้าไป ซึ่งคุณสามารถนำกลับมาใช้ใหม่ระหว่างวัตถุที่ใช้ Active Model:

```ruby
class TitleValidator < ActiveModel::EachValidator
  Titles = ['Mr.', 'Mrs.', 'Dr.']
  def validate_each(record, attribute, value)
    unless Titles.include?(value)
      record.errors[attribute] << 'must be a valid title'
    end
  end
end
```

```ruby
class Person
  include ActiveModel::Validations
  attr_accessor :title
  validates :title, :presence => true, :title => true
end

# หรือสำหรับ Active Record

class Person < ActiveRecord::Base
  validates :title, :presence => true, :title => true
end
```
ยังมีการสนับสนุนสำหรับ introspection:

```ruby
User.validators
User.validators_on(:login)
```

ข้อมูลเพิ่มเติม:

* [Sexy Validation in Rails 3](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)
* [Rails 3 Validations Explained](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)


Active Record
-------------

Active Record ได้รับความสนใจมากใน Rails 3.0 รวมถึงการแยกตัวออกเป็น Active Model, การอัปเดตเต็มรูปแบบใน Query interface โดยใช้ Arel, การอัปเดตการตรวจสอบความถูกต้อง และการปรับปรุงและการแก้ไขหลายอย่าง ทั้งหมดของ API ของ Rails 2.x สามารถใช้ได้ผ่านชั้นสมดุลที่จะได้รับการสนับสนุนจนถึงเวอร์ชัน 3.1


### Query Interface

Active Record ผ่านการใช้ Arel ตอนนี้สามารถส่งคืนความสัมพันธ์ในเมธอดหลักของมันได้ ยังคงรองรับ API ที่มีอยู่ใน Rails 2.3.x และจะไม่ถูกยกเลิกจนถึง Rails 3.1 และไม่ถูกลบจนถึง Rails 3.2 อย่างไรก็ตาม API ใหม่นี้มีเมธอดใหม่ที่ให้คืนความสัมพันธ์ดังต่อไปนี้ที่สามารถเชื่อมต่อกันได้:

* `where` - ให้เงื่อนไขในความสัมพันธ์ สิ่งที่จะได้รับกลับมา
* `select` - เลือกแอตทริบิวต์ของโมเดลที่คุณต้องการให้คืนค่าจากฐานข้อมูล
* `group` - จัดกลุ่มความสัมพันธ์ตามแอตทริบิวต์ที่กำหนด
* `having` - ให้นิพจน์ที่จำกัดความสัมพันธ์ของกลุ่ม (ข้อจำกัด GROUP BY)
* `joins` - เชื่อมต่อความสัมพันธ์กับตารางอื่น
* `clause` - ให้นิพจน์ที่จำกัดความสัมพันธ์การเชื่อมต่อ (ข้อจำกัด JOIN)
* `includes` - รวมความสัมพันธ์อื่นที่โหลดล่วงหน้า
* `order` - เรียงลำดับความสัมพันธ์ตามนิพจน์ที่กำหนด
* `limit` - จำกัดความสัมพันธ์ให้กับจำนวนเร็คคอร์ดที่ระบุ
* `lock` - ล็อกเร็คคอร์ดที่คืนค่าจากตาราง
* `readonly` - คืนค่าสำเนาข้อมูลที่อ่านอย่างเดียว
* `from` - ให้วิธีการเลือกความสัมพันธ์จากตารางมากกว่าหนึ่งตาราง
* `scope` - (ก่อนหน้านี้เป็น `named_scope`) คืนค่าความสัมพันธ์และสามารถเชื่อมต่อกับเมธอดความสัมพันธ์อื่น ๆ ได้
* `with_scope` - และ `with_exclusive_scope` ตอนนี้ยังคืนค่าความสัมพันธ์และสามารถเชื่อมต่อกันได้
* `default_scope` - ยังทำงานร่วมกับความสัมพันธ์ได้
ข้อมูลเพิ่มเติม:

* [Active Record Query Interface](http://m.onkey.org/2010/1/22/active-record-query-interface)
* [Let your SQL Growl in Rails 3](http://hasmanyquestions.wordpress.com/2010/01/17/let-your-sql-growl-in-rails-3/)


### การปรับปรุง

* เพิ่ม `:destroyed?` ในอ็อบเจกต์ Active Record
* เพิ่ม `:inverse_of` ในการเชื่อมโยง Active Record ที่ช่วยให้คุณสามารถดึงอินสแตนซ์ของการเชื่อมโยงที่โหลดแล้วได้โดยไม่ต้องเรียกใช้ฐานข้อมูล


### การแก้ไขและการเลิกใช้งาน

นอกจากนี้ยังมีการแก้ไขในส่วน Active Record ดังนี้:

* ไม่รองรับ SQLite 2 และเปลี่ยนมาใช้ SQLite 3 แทน
* รองรับการเรียงลำดับคอลัมน์ใน MySQL
* แก้ไขการสนับสนุน `TIME ZONE` ใน PostgreSQL ที่เขียนค่าผิด
* รองรับชื่อตารางที่มีหลายสกีมาใน PostgreSQL
* รองรับคอลัมน์ชนิด XML ใน PostgreSQL
* แคช `table_name` เพื่อเพิ่มประสิทธิภาพ
* ทำงานจำนวนมากกับ Oracle adapter และแก้ไขข้อบกพร่องหลายอย่าง

นอกจากนี้ยังมีการเลิกใช้งานต่อไปนี้:

* `named_scope` ในคลาส Active Record ถูกเลิกใช้และเปลี่ยนชื่อเป็น `scope` เท่านั้น
* ในเมธอด `scope` คุณควรเริ่มใช้เมธอดที่เกี่ยวข้องกับความสัมพันธ์แทนการใช้ `:conditions => {}` ในการค้นหา เช่น `scope :since, lambda {|time| where("created_at > ?", time) }`
* `save(false)` ถูกเลิกใช้และแนะนำให้ใช้ `save(:validate => false)` แทน
* ข้อความข้อผิดพลาด I18n สำหรับ Active Record ควรเปลี่ยนจาก :en.activerecord.errors.template เป็น `:en.errors.template`
* `model.errors.on` ถูกเลิกใช้และแนะนำให้ใช้ `model.errors[]` แทน
* validates_presence_of => validates... :presence => true
* `ActiveRecord::Base.colorize_logging` และ `config.active_record.colorize_logging` ถูกเลิกใช้และแนะนำให้ใช้ `Rails::LogSubscriber.colorize_logging` หรือ `config.colorize_logging` แทน

หมายเหตุ: แม้ว่า State Machine จะถูกนำเข้ามาใน Active Record มาหลายเดือนแล้ว แต่ถูกลบออกจากการเปิดตัวของ Rails 3.0


Active Resource
---------------

Active Resource ยังถูกแยกออกเป็น Active Model เพื่อให้คุณสามารถใช้อ็อบเจกต์ Active Resource กับ Action Pack ได้อย่างราบรื่น

* เพิ่มการตรวจสอบผ่าน Active Model
* เพิ่มการเชื่อมต่อกับการสังเกตการณ์
* รองรับการใช้งาน HTTP proxy
* เพิ่มการสนับสนุนการรับรองตัวตนแบบ Digest
* ย้ายการตั้งชื่อโมเดลไปยัง Active Model
* เปลี่ยนแอตทริบิวต์ Active Resource เป็น Hash ที่สามารถเข้าถึงได้โดยไม่สนใจตัวอักษรตัวพิมพ์ใหญ่หรือเล็ก
* เพิ่ม `first`, `last` และ `all` เป็นตัวย่อสำหรับการค้นหาที่เทียบเท่ากัน
* `find_every` ไม่คืนข้อผิดพลาด `ResourceNotFound` หากไม่มีข้อมูลที่คืนกลับมา
* เพิ่ม `save!` ซึ่งจะเรียก `ResourceInvalid` ถ้าวัตถุไม่ถูกต้อง
* เพิ่ม `update_attribute` และ `update_attributes` ใน Active Resource models
* เพิ่ม `exists?`
* เปลี่ยนชื่อ `SchemaDefinition` เป็น `Schema` และ `define_schema` เป็น `schema`
* ใช้ `format` ของ Active Resources แทน `content-type` ของข้อผิดพลาดจากรีโมทเพื่อโหลดข้อผิดพลาด
* ใช้ `instance_eval` สำหรับบล็อก schema
* แก้ไข `ActiveResource::ConnectionError#to_s` เมื่อ `@response` ไม่ตอบสนองกับ #code หรือ #message เพื่อรองรับความเข้ากันได้กับ Ruby 1.9
* เพิ่มการสนับสนุนข้อผิดพลาดในรูปแบบ JSON
* ให้ `load` ทำงานกับอาร์เรย์ที่มีตัวเลขได้
* รู้จักการตอบสนอง 410 จากทรัพยากรรีโมทว่าทรัพยากรถูกลบแล้ว
* เพิ่มความสามารถในการตั้งค่า SSL options ในการเชื่อมต่อ Active Resource
* การตั้งค่า connection timeout จะมีผลต่อ `Net::HTTP` `open_timeout` ด้วย
การเลิกใช้งาน:

* `save(false)` ถูกเลิกใช้แล้ว แนะนำให้ใช้ `save(:validate => false)` แทน
* Ruby 1.9.2: `URI.parse` และ `.decode` ถูกเลิกใช้และไม่ได้ใช้ในไลบรารีอีกต่อไป


Active Support
--------------

มีการพยายามใหญ่ใน Active Support เพื่อให้สามารถเลือกใช้ได้เฉพาะส่วนที่ต้องการ นั่นคือ คุณไม่จำเป็นต้องระบุไลบรารี Active Support ทั้งหมดเพื่อใช้งานส่วนที่ต้องการ ซึ่งทำให้ส่วนประกอบหลักต่าง ๆ ของ Rails ทำงานได้อย่างเบาเฟี้ยว

นี่คือการเปลี่ยนแปลงหลักใน Active Support:

* ทำความสะอาดไลบรารีโดยการลบเมธอดที่ไม่ได้ใช้งานทั่วไป
* Active Support ไม่ได้ให้เวอร์ชันที่เก็บไว้ของ TZInfo, Memcache Client และ Builder อีกต่อไป สิ่งเหล่านี้ถูกติดตั้งเป็น dependencies และติดตั้งผ่านคำสั่ง `bundle install`
* มีการนำเอา Safe buffers มาใช้งานใน `ActiveSupport::SafeBuffer`
* เพิ่ม `Array.uniq_by` และ `Array.uniq_by!`
* ลบ `Array#rand` และนำ `Array#sample` จาก Ruby 1.9 มาใช้แทน
* แก้ไขข้อบกพร่องใน `TimeZone.seconds_to_utc_offset` ที่คืนค่าผิด
* เพิ่ม `ActiveSupport::Notifications` middleware
* `ActiveSupport.use_standard_json_time_format` มีค่าเริ่มต้นเป็น true
* `ActiveSupport.escape_html_entities_in_json` มีค่าเริ่มต้นเป็น false
* `Integer#multiple_of?` ยอมรับค่าศูนย์เป็นอาร์กิวเมนต์ และคืนค่าเป็น false ถ้าผู้รับไม่ใช่ศูนย์
* `string.chars` ถูกเปลี่ยนชื่อเป็น `string.mb_chars`
* `ActiveSupport::OrderedHash` สามารถถอดรหัสผ่าน YAML ได้
* เพิ่ม SAX-based parser สำหรับ XmlMini โดยใช้ LibXML และ Nokogiri
* เพิ่ม `Object#presence` ที่คืนค่าวัตถุถ้า `#present?` แต่ถ้าไม่ใช่จะคืนค่าเป็น nil
* เพิ่ม core extension `String#exclude?` ที่คืนค่าตรงกันข้ามกับ `#include?`
* เพิ่ม `to_i` ใน `DateTime` ใน `ActiveSupport` เพื่อให้ `to_yaml` ทำงานได้อย่างถูกต้องกับโมเดลที่มีแอตทริบิวต์เป็น `DateTime`
* เพิ่ม `Enumerable#exclude?` เพื่อให้เทียบเท่ากับ `Enumerable#include?` และหลีกเลี่ยงการใช้ `!x.include?`
* เปลี่ยนเป็นการหายใจอัตโนมัติเมื่อเกิด XSS ใน Rails
* รองรับการผสานข้อมูลลึกใน `ActiveSupport::HashWithIndifferentAccess`
* `Enumerable#sum` ทำงานกับ enumerables ทุกประเภท แม้ว่าจะไม่ตอบสนองต่อ `:size`
* `inspect` ของระยะเวลาที่ยาวเท่าศูนย์ จะคืนค่า '0 seconds' แทนที่จะเป็นสตริงว่างเปล่า
* เพิ่ม `element` และ `collection` ใน `ModelName`
* `String#to_time` และ `String#to_datetime` จัดการกับวินาทีทศนิยมได้
* เพิ่มการสนับสนุนให้ใช้งาน callbacks ใหม่สำหรับ around filter object ที่ตอบสนองต่อ `:before` และ `:after` ที่ใช้ใน before และ after callbacks
* เมธอด `ActiveSupport::OrderedHash#to_a` จะคืนค่าเป็นชุดของอาร์เรย์ที่เรียงลำดับ ตรงกับ `Hash#to_a` ของ Ruby 1.9
* `MissingSourceFile` ยังคงเป็นค่าคงที่ แต่ตอนนี้มีค่าเท่ากับ `LoadError`
* เพิ่ม `Class#class_attribute` เพื่อสามารถประกาศแอตทริบิวต์ระดับคลาสที่มีค่าที่สืบทอดและสามารถเขียนทับได้โดยคลาสย่อย
* ลบ `DeprecatedCallbacks` ออกจาก `ActiveRecord::Associations` อย่างสมบูรณ์
* `Object#metaclass` เปลี่ยนเป็น `Kernel#singleton_class` เพื่อให้เข้ากันได้กับ Ruby
วิธีการต่อไปนี้ถูกลบออกเนื่องจากมีให้ใช้ใน Ruby 1.8.7 และ 1.9

* `Integer#even?` และ `Integer#odd?`
* `String#each_char`
* `String#start_with?` และ `String#end_with?` (ยังคงมีการเก็บตัวย่อบุคคลที่สาม)
* `String#bytesize`
* `Object#tap`
* `Symbol#to_proc`
* `Object#instance_variable_defined?`
* `Enumerable#none?`

การแก้ไขปัญหาด้านความปลอดภัยสำหรับ REXML ยังคงอยู่ใน Active Support เนื่องจากเวอร์ชันเริ่มต้นของ Ruby 1.8.7 ยังต้องการการแก้ไขปัญหาดังกล่าว  Active Support รู้ว่าจะต้องใช้หรือไม่ต้องใช้

วิธีการต่อไปนี้ถูกลบออกเนื่องจากไม่ได้ใช้ในเฟรมเวิร์กอีกต่อไป

* `Kernel#daemonize`
* `Object#remove_subclasses_of` `Object#extend_with_included_modules_from`, `Object#extended_by`
* `Class#remove_class`
* `Regexp#number_of_captures`, `Regexp.unoptionalize`, `Regexp.optionalize`, `Regexp#number_of_captures`

Action Mailer
-------------

Action Mailer ได้รับ API ใหม่โดย TMail ถูกแทนที่ด้วย [Mail](https://github.com/mikel/mail) เป็นไลบรารีอีเมลใหม่  Action Mailer เองได้รับการเขียนใหม่เกือบทั้งหมดโดยเกือบทุกบรรทัดของโค้ดถูกแตะไปแล้ว ผลลัพธ์คือ Action Mailer ตอนนี้เพียงแค่สืบทอดมาจาก Abstract Controller และห่อหุ้ม Mail gem ด้วย Rails DSL ซึ่งลดจำนวนโค้ดและการทำซ้ำของไลบรารีอื่น ๆ ใน Action Mailer อย่างมาก

* ทุกเมลเลอร์ตอนนี้อยู่ใน `app/mailers` โดยค่าเริ่มต้น
* สามารถส่งอีเมลโดยใช้ API ใหม่ได้ด้วยวิธีการสามวิธี: `attachments`, `headers` และ `mail`
* Action Mailer ตอนนี้สนับสนุนการแนบไฟล์แบบ inline โดยใช้วิธี `attachments.inline`
* วิธีการส่งอีเมลใน Action Mailer ตอนนี้จะส่งกลับ `Mail::Message` object ซึ่งสามารถส่งข้อความ `deliver` เพื่อส่งอีเมลได้เอง
* วิธีการส่งอีเมลทั้งหมดถูกแยกออกมาเป็น Mail gem
* วิธีการส่งอีเมลสามารถรับแฮชของฟิลด์ส่วนหัวอีเมลที่ถูกต้องทั้งหมดพร้อมคู่ค่าของมันได้
* วิธีการส่งอีเมล `mail` ทำงานในลักษณะเดียวกับ `respond_to` ของ Action Controller และคุณสามารถเรนเดอร์เทมเพลตได้โดยชัดเจนหรืออ้อมค้อม  Action Mailer จะแปลงอีเมลเป็นอีเมลหลายส่วนตามความจำเป็น
* คุณสามารถส่ง proc ไปยังการเรียกใช้ `format.mime_type` ภายในบล็อกอีเมลและเรนเดอร์เนื้อหาข้อความประเภทต่าง ๆ หรือเพิ่มเลเอาท์หรือเทมเพลตที่แตกต่างกัน การเรียกใช้ `render` ภายใน proc เป็นของ Abstract Controller และรองรับตัวเลือกเดียวกัน
* การทดสอบของเมลเลอร์ที่เคยอยู่ถูกย้ายไปที่การทดสอบฟังก์ชัน
* Action Mailer ตอนนี้มอบหมายให้ Mail Gem ดูแลการเข้ารหัสอัตโนมัติของฟิลด์ส่วนหัวและเนื้อหา
* Action Mailer จะเข้ารหัสอีเมลเนื้อหาและส่วนหัวโดยอัตโนมัติสำหรับคุณ
การเลิกใช้งาน:

* `:charset`, `:content_type`, `:mime_version`, `:implicit_parts_order` ถูกเลิกใช้แล้วและแนะนำให้ใช้การประกาศแบบ `ActionMailer.default :key => value` แทน
* การสร้างชื่อเมธอดแบบไดนามิก `create_method_name` และ `deliver_method_name` ถูกเลิกใช้แล้ว ให้เรียกใช้ `method_name` ที่ตอนนี้จะส่งคืนออบเจ็กต์ `Mail::Message`
* `ActionMailer.deliver(message)` ถูกเลิกใช้แล้ว ให้เรียกใช้ `message.deliver` แทน
* `template_root` ถูกเลิกใช้แล้ว ให้ส่งค่าตัวเลือกไปยังการเรียกใช้ `render` ภายใน `proc` จาก `format.mime_type` ภายในบล็อกการสร้าง `mail`
* เมธอด `body` ในการกำหนดตัวแปรอินสแตนซ์ถูกเลิกใช้แล้ว (`body {:ivar => value}`) ให้ประกาศตัวแปรอินสแตนซ์ในเมธอดโดยตรงและจะสามารถใช้ได้ในวิว
* การเก็บไฟล์ Mailers ใน `app/models` ถูกเลิกใช้แล้ว ให้ใช้ `app/mailers` แทน

ข้อมูลเพิ่มเติม:

* [API ใหม่ของ Action Mailer ใน Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)
* [Mail Gem ใหม่สำหรับ Ruby](http://lindsaar.net/2010/1/23/mail-gem-version-2-released)


เครดิต
-------

ดูรายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails ได้ที่ [รายชื่อผู้มีส่วนร่วมใน Rails](https://contributors.rubyonrails.org/) สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails 3 ขอบคุณทุกคน

บันทึกการเปิดตัว Rails 3.0 รวบรวมโดย [Mikel Lindsaar](http://lindsaar.net)
