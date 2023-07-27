**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: dd2584972aa8eae419ed5d55a287e27d
เรื่องราวการเปิดตัวของ Ruby on Rails 3.0
===============================

Rails 3.0 เป็นเรื่องราวของโล่งและสีสัน! มันจะทำอาหารให้คุณกินและพับผ้าซักผ้าให้คุณ คุณจะสงสัยว่าชีวิตเคยเป็นไปได้ก่อนที่มันจะมาถึง มันเป็นเวอร์ชันที่ดีที่สุดของ Rails ที่เราเคยทำ!

แต่แบบจริงๆ มันเป็นสิ่งที่ดีจริงๆ มีความคิดที่ดีทั้งหมดที่นำมาจากทีม Merb เมื่อเข้าร่วมงานและเน้นไปที่ความเป็นเฟรมเวิร์กที่ไม่เกี่ยวข้องกับเฟรมเวิร์กอื่น ๆ และมีการปรับปรุงและเพิ่ม API ที่น่าสนใจ หากคุณเป็นคนที่เข้ามาใช้ Rails 3.0 จาก Merb 1.x คุณควรจะรู้จักมันมากมาย หากคุณเป็นคนที่เข้ามาใช้ Rails 2.x คุณจะตกหลุมรักมันเช่นกัน

แม้ว่าคุณจะไม่สนใจเรื่องการทำความสะอาดภายในของเรา แต่ Rails 3.0 จะทำให้คุณตื่นเต้น มีคุณสมบัติใหม่และ API ที่ปรับปรุง นี่เป็นเวลาที่ดีที่สุดในการเป็นนักพัฒนา Rails บางส่วนของเนื้อหาที่น่าสนใจคือ:

* เราเปลี่ยนเส้นทางใหม่ที่เน้นการประกาศแบบ RESTful
* มี API ใหม่สำหรับ Action Mailer ที่ออกแบบใหม่ตาม Action Controller (โดยไม่ต้องเจ็บปวดในการส่งข้อความแบบมาตรฐานหลายส่วน!)
* มีภาษาคิวรีใหม่สำหรับ Active Record ที่สามารถเชื่อมต่อกับตัวดำเนินการทางคณิตศาสตร์ได้
* มีตัวช่วย JavaScript ที่ไม่รบกวนด้วยการสนับสนุนสำหรับ Prototype, jQuery และอื่น ๆ (สิ้นสุดการใช้งาน JS แบบอินไลน์)
* การจัดการความสัมพันธ์แบบชัดเจนด้วย Bundler

นอกจากนี้เราได้พยายามที่จะเลิกใช้ API เก่าๆ ด้วยการแจ้งเตือนที่ดี ซึ่งหมายความว่าคุณสามารถย้ายแอปพลิเคชันที่มีอยู่ของคุณไปยัง Rails 3 โดยไม่ต้องเขียนโค้ดเก่าใหม่ทั้งหมดตามหลักการที่ดีที่สุดทันที

เอกสารเวอร์ชันนี้ครอบคลุมการอัปเกรดที่สำคัญ แต่ไม่รวมถึงการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงทุกอย่าง Rails 3.0 ประกอบด้วยการเปลี่ยนแปลงเกือบ 4,000 ครั้งโดยมีผู้เขียนมากกว่า 250 คน! หากคุณต้องการดูทุกอย่าง โปรดตรวจสอบ [รายการการเปลี่ยนแปลง](https://github.com/rails/rails/commits/3-0-stable) ในเรพอสิทอรีหลักของ Rails บน GitHub

--------------------------------------------------------------------------------

การติดตั้ง Rails 3:

```bash
# ใช้ sudo หากการติดตั้งของคุณต้องการ
$ gem install rails
```


การอัปเกรดไปยัง Rails 3
--------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่ คุณควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 2.3.5 ก่อนและตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานได้ตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 3 จากนั้นให้ทำตามขั้นตอนต่อไปนี้:

### Rails 3 ต้องการ Ruby 1.8.7 หรือสูงกว่า

Rails 3.0 ต้องการ Ruby 1.8.7 หรือสูงกว่า การสนับสนุนสำหรับเวอร์ชัน Ruby ก่อนหน้านี้ทั้งหมดถูกยกเลิกอย่างเป็นทางการและคุณควรอัปเกรดให้เร็วที่สุด Rails 3.0 ยังเข้ากันได้กับ Ruby 1.9.2

เคล็ดลับ: โปรดทราบว่า Ruby 1.8.7 p248 และ p249 มีข้อบกพร่องในการมาร์ชลิงซึ่งทำให้ Rails 3.0 ล้มเหลว แต่ Ruby Enterprise Edition ได้แก้ไขปัญหาเหล่านี้ตั้งแต่เวอร์ชัน 1.8.7-2010.02 ในส่วนของ 1.9 Ruby 1.9.1 ไม่สามารถใช้งานได้เพราะมันทำให้ Rails 3.0 ล้มเหลวโดยตรง ดังนั้นหากคุณต้องการใช้ Rails 3 กับ 1.9.x คุณควรใช้เวอร์ชัน 1.9.2 เพื่อความราบรื่น

### วัตถุประสงค์ของแอปพลิเคชัน Rails

เป็นส่วนหนึ่งของงานเตรียมพื้นฐานสำหรับการรองรับการทำงานของแอปพลิเคชัน Rails หลายๆ แอปพลิเคชันในกระบวนการเดียวกัน  Rails 3 นำเสนอแนวคิดของวัตถุประสงค์แอปพลิเคชัน วัตถุประสงค์แอปพลิเคชันเก็บรวบรวมการกำหนดค่าที่เฉพาะเจาะจงของแอปพลิเคชันและคล้ายกับ `config/environment.rb` จากเวอร์ชันก่อนหน้าของ Rails

แต่ละแอปพลิเคชัน Rails ต้องมีวัตถุประสงค์แอปพลิเคชันที่เกี่ยวข้อง วัตถุประสงค์แอปพลิเคชันถูกกำหนดไว้ใน `config/application.rb` หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่เป็น Rails 3 คุณต้องเพิ่มไฟล์นี้และย้ายการกำหนดค่าที่เหมาะสมจาก `config/environment.rb` ไปยัง `config/application.rb`

### script/* ถูกแทนที่ด้วย script/rails

`script/rails` ใหม่แทนที่สคริปต์ทั้งหมดที่อยู่ในไดเรกทอรี `script` คุณไม่ต้องเรียกใช้ `script/rails` โดยตรง คำสั่ง `rails` จะตรวจสอบว่ามันถูกเรียกใช้ในรูทของแอปพลิเคชัน Rails และเรียกใช้สคริปต์ให้คุณ วิธีการใช้ที่ตั้งใจคือ:
```bash
$ rails console                      # แทนที่ script/console
$ rails g scaffold post title:string # แทนที่ script/generate scaffold post title:string
```

รัน `rails --help` เพื่อดูรายการตัวเลือกทั้งหมด

### ขึ้นอยู่กับ Dependencies และ config.gem

เมธอด `config.gem` ได้ถูกลบออกและถูกแทนที่ด้วยการใช้ `bundler` และ `Gemfile` ดูเพิ่มเติมที่ [Vendoring Gems](#vendoring-gems) ด้านล่าง

### กระบวนการอัพเกรด

เพื่อช่วยในกระบวนการอัพเกรด มีปลั๊กอินชื่อ [Rails Upgrade](https://github.com/rails/rails_upgrade) ถูกสร้างขึ้นเพื่อทำการอัพเกรดอัตโนมัติบางส่วน

เพียงติดตั้งปลั๊กอิน จากนั้นรัน `rake rails:upgrade:check` เพื่อตรวจสอบแอปของคุณว่ามีส่วนที่ต้องอัพเดตหรือไม่ (พร้อมลิงก์ไปยังข้อมูลเพิ่มเติมเกี่ยวกับวิธีการอัพเดต) มันยังมีการเสนองานในการสร้าง `Gemfile` จาก `config.gem` ปัจจุบันของคุณและการสร้างไฟล์เส้นทางใหม่จากไฟล์เส้นทางปัจจุบันของคุณ ในการรับปลั๊กอิน คุณสามารถรันคำสั่งต่อไปนี้:

```bash
$ ruby script/plugin install git://github.com/rails/rails_upgrade.git
```

คุณสามารถดูตัวอย่างว่ามันทำงานอย่างไรได้ที่ [Rails Upgrade is now an Official Plugin](http://omgbloglol.com/post/364624593/rails-upgrade-is-now-an-official-plugin)

นอกเหนือจากเครื่องมือ Rails Upgrade หากคุณต้องการความช่วยเหลือเพิ่มเติม มีผู้คนใน IRC และ [rubyonrails-talk](https://discuss.rubyonrails.org/c/rubyonrails-talk) ที่อาจกำลังทำเหมือนกัน โดยอาจพบปัญหาเดียวกัน อย่าลืมเขียนบล็อกเกี่ยวกับประสบการณ์ของคุณเมื่ออัพเกรดเพื่อให้ผู้อื่นได้รับประโยชน์จากความรู้ของคุณ!

สร้างแอปพลิเคชัน Rails 3.0
--------------------------------

```bash
# คุณควรมี 'rails' RubyGem ติดตั้งแล้ว
$ rails new myapp
$ cd myapp
```

### Vendoring Gems

Rails ใช้ `Gemfile` ในรากแอปพลิเคชันเพื่อกำหนด gem ที่คุณต้องการสำหรับแอปพลิเคชันของคุณให้เริ่มต้น ไฟล์ `Gemfile` นี้จะถูกประมวลผลโดย [Bundler](https://github.com/bundler/bundler) ซึ่งจะติดตั้ง dependencies ทั้งหมดของคุณ มันยังสามารถติดตั้ง dependencies ทั้งหมดไปยังแอปพลิเคชันของคุณเองเพื่อไม่ต้องพึ่งพากับ system gems

ข้อมูลเพิ่มเติม: - [bundler homepage](https://bundler.io/)

### อยู่ในส่วนของการพัฒนา

`Bundler` และ `Gemfile` ทำให้การแชร์แอปพลิเคชัน Rails ของคุณเป็นเรื่องง่ายด้วยคำสั่ง `bundle` ใหม่ ดังนั้น `rake freeze` ไม่เกี่ยวข้องและถูกลบออก

หากคุณต้องการแบนเดิมจาก Git repository คุณสามารถใช้ `--edge` flag:

```bash
$ rails new myapp --edge
```

หากคุณมีการ checkout ท้องถิ่นของ Rails repository และต้องการสร้างแอปพลิเคชันโดยใช้มัน คุณสามารถใช้ `--dev` flag:

```bash
$ ruby /path/to/rails/bin/rails new myapp --dev
```

การเปลี่ยนแปลงทางสถาปัตยกรรมของ Rails
---------------------------

มีการเปลี่ยนแปลงสถาปัตยกรรมใน Rails ทั้งหมด 6 ส่วนสำคัญ

### Railties Restrung

Railties ได้รับการอัปเดตเพื่อให้มี API ปลั๊กอินที่สม่ำเสมอสำหรับเฟรมเวิร์ค Rails ทั้งหมดและการเขียนใหม่ทั้งหมดของ generators และ Rails bindings ผลลัพธ์คือนักพัฒนาสามารถเชื่อมต่อกับขั้นตอนสำคัญใด ๆ ของ generators และเฟรมเวิร์คแอปพลิเคชันได้อย่างสม่ำเสมอและกำหนดไว้

### ส่วนประกอบหลักของ Rails ถูกแยกออกจากกัน

ด้วยการผสมรวมของ Merb และ Rails หนึ่งในงานที่ใหญ่คือการลดการผูกติดที่แน่นหนาระหว่างส่วนประกอบหลักของ Rails นี้ได้รับการทำเช่นนี้แล้ว และส่วนประกอบหลักของ Rails ทั้งหมดใช้ API เดียวกันที่คุณสามารถใช้ในการพัฒนาปลั๊กอิน นี่หมายความว่าปลั๊กอินใดก็ตามที่คุณทำหรือส่วนประกอบหลักที่เปลี่ยนแปลง (เช่น DataMapper หรือ Sequel) สามารถเข้าถึงฟังก์ชันทั้งหมดที่ส่วนประกอบหลักของ Rails มีการเข้าถึงและขยายขึ้นตามต้องการ

ข้อมูลเพิ่มเติม: - [The Great Decoupling](http://yehudakatz.com/2009/07/19/rails-3-the-great-decoupling/)


### การสร้างแบบ Active Model

ส่วนหนึ่งของการแยกส่วนประกอบหลักคือการแยกการเชื่อมต่อกับ Active Record จาก Action Pack นี้ได้รับการทำเสร็จสมบูรณ์แล้ว ปลั๊กอิน ORM ใหม่ทั้งหมดต้องการเพียงการดำเนินการ Active Model เพื่อทำงานร่วมกับ Action Pack ได้อย่างราบรื่น

ข้อมูลเพิ่มเติม: - [Make Any Ruby Object Feel Like ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### การแยกส่วนของ Controller

ส่วนใหญ่ของการแยกส่วนประกอบหลักคือการสร้าง superclass ที่แยกออกจากแนวคิดของ HTTP เพื่อจัดการการแสดงผลของมุมมอง ฯลฯ การสร้าง `AbstractController` นี้ช่วยให้ `ActionController` และ `ActionMailer` ง่ายขึ้นอย่างมากโดยลดโค้ดที่ซ้ำซ้อนออกจากไลบรารีเหล่านี้ทั้งหมดและนำเข้า Abstract Controller
ข้อมูลเพิ่มเติม: - [Rails Edge Architecture](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### การผสาน Arel

[Arel](https://github.com/brynary/arel) (หรือ Active Relation) ถูกนำมาใช้เป็นพื้นฐานของ Active Record และต้องใช้สำหรับ Rails แล้ว  Arel ให้การสร้างความเป็นมาตรฐานของ SQL ที่ทำให้ Active Record ง่ายขึ้นและให้ฟังก์ชันการเชื่อมโยงใน Active Record

ข้อมูลเพิ่มเติม: - [ทำไมฉันเขียน Arel](https://web.archive.org/web/20120718093140/http://magicscalingsprinkles.wordpress.com/2010/01/28/why-i-wrote-arel/)


### การแยกอีเมล

Action Mailer ตั้งแต่เริ่มต้นมีการแก้ไขโค้ด, การแยกส่วนการแปลงข้อมูลก่อน, การส่งและการรับอีเมล ทั้งหมดนี้เพิ่มเติมเข้ามาใน TMail ที่อยู่ในต้นฉบับของโค้ด รุ่น 3 เปลี่ยนแปลงโดยการแยกฟังก์ชันที่เกี่ยวข้องกับข้อความอีเมลออกไปยัง [Mail](https://github.com/mikel/mail) gem นี้ช่วยลดการทำซ้ำของโค้ดและช่วยสร้างขอบเขตที่กำหนดได้ระหว่าง Action Mailer และตัวแยกวิเคราะห์อีเมล

ข้อมูลเพิ่มเติม: - [API ใหม่ของ Action Mailer ใน Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)


เอกสาร
-------------

เอกสารในต้นฉบับของ Rails กำลังอัปเดตเพื่อปรับเปลี่ยน API ทั้งหมด นอกจากนี้ [Rails Edge Guides](https://edgeguides.rubyonrails.org/) กำลังอัปเดตเรื่อยๆ เพื่อสะท้อนการเปลี่ยนแปลงใน Rails 3.0 แต่เอกสารที่ [guides.rubyonrails.org](https://guides.rubyonrails.org/) จะยังคงมีเฉพาะเวอร์ชันที่เสถียร (ณ จุดนี้เป็นเวอร์ชัน 2.3.5 จนกว่าเวอร์ชัน 3.0 จะถูกเผยแพร่)

ข้อมูลเพิ่มเติม: - [โครงการเอกสาร Rails](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)


การรองรับการแปลภาษา
--------------------

มีการทำงานจำนวนมากเกี่ยวกับการรองรับ I18n ใน Rails 3 รวมถึง [I18n](https://github.com/svenfuchs/i18n) gem ล่าสุดที่มีการปรับปรุงความเร็วมากมาย

* I18n สำหรับวัตถุใดก็ได้ - พฤติกรรม I18n สามารถเพิ่มให้กับวัตถุใดก็ได้โดยการรวม `ActiveModel::Translation` และ `ActiveModel::Validations` นอกจากนี้ยังมีการสำรองข้อความ `errors.messages` สำหรับการแปล
* แอตทริบิวต์สามารถมีการแปลเริ่มต้นได้
* ฟอร์ม Submit Tags จะดึงสถานะที่ถูกต้อง (สร้างหรืออัปเดต) ขึ้นอัตโนมัติขึ้นอยู่กับสถานะของวัตถุและดึงการแปลที่ถูกต้อง
* ป้ายชื่อที่มี I18n ทำงานได้โดยการส่งชื่อแอตทริบิวต์เท่านั้น

ข้อมูลเพิ่มเติม: - [การเปลี่ยนแปลง I18n ใน Rails 3](http://blog.plataformatec.com.br/2010/02/rails-3-i18n-changes/)


Railties
--------

เมื่อตัดการเชื่อมโยงของกรอบหลักของ Rails  Railties ได้รับการปรับปรุงใหญ่เพื่อทำให้การเชื่อมโยงกรอบการทำงาน โมดูลเสริม หรือปลั๊กอินเป็นเรื่องง่ายและสามารถขยายได้:

* แอปพลิเคชันแต่ละอันตอนนี้มีเนมสเปซของตัวเอง แอปพลิเคชันเริ่มต้นด้วย `YourAppName.boot` เช่น ทำให้การติดต่อกับแอปพลิเคชันอื่นเป็นเรื่องง่ายขึ้นมาก
* ทุกอย่างที่อยู่ใต้ `Rails.root/app` ถูกเพิ่มเข้าไปในเส้นทางการโหลด ดังนั้นคุณสามารถสร้าง `app/observers/user_observer.rb` และ Rails จะโหลดมันโดยไม่ต้องแก้ไขใดๆ
* Rails 3.0 ให้ `Rails.config` object ซึ่งเป็นที่เก็บรวบรวมของตัวเลือกการกำหนดค่าทั่วทั้งระบบของ Rails

    การสร้างแอปพลิเคชันได้รับการเพิ่มค่าพิเศษที่ช่วยให้คุณสามารถข้ามการติดตั้ง test-unit, Active Record, Prototype และ Git ได้ นอกจากนี้ยังเพิ่มค่า `--dev` ใหม่ซึ่งจะตั้งค่าแอปพลิเคชันด้วย `Gemfile` ที่ชี้ไปยังการเช็คเอาท์ของคุณ (ซึ่งจะถูกกำหนดโดยเส้นทางไปยังไบนารี `rails`) ดู `rails --help` สำหรับข้อมูลเพิ่มเติม

Railties generators ได้รับความสนใจอย่างมากใน Rails 3.0 โดยสรุป:

* ทั้งหมดถูกเขียนใหม่และไม่สามารถทำงานร่วมกันกับเวอร์ชันก่อนหน้าได้
* Rails templates API และ generators API ถูกผสมกัน (เป็นเหมือนเดิม)
* ไม่มีการโหลด generators จากเส้นทางพิเศษอีกต่อไป แต่จะค้นหาในเส้นทางการโหลด Ruby ดังนั้นการเรียกใช้ `rails generate foo` จะค้นหา `generators/foo_generator`
* ตัวสร้างใหม่ให้การเชื่อมโยงเพื่อให้เครื่องมือสร้างเทมเพลต, ORM, เฟรมเวิร์กทดสอบสามารถเชื่อมโยงได้ง่าย
* ตัวสร้างใหม่ช่วยให้คุณสามารถแทนที่เทมเพลตได้โดยวางสำเนาที่ `Rails.root/lib/templates`
* มี `Rails::Generators::TestCase` เพื่อให้คุณสามารถสร้างตัวสร้างของคุณเองและทดสอบได้

นอกจากนี้ มีการปรับปรุงในมุมมองที่สร้างขึ้นโดย Railties generators:

* มุมมองใช้แท็ก `div` แทนแท็ก `p`
* การสร้าง Scaffolds ใช้ partial `_form` แทนการทำซ้ำโค้ดในมุมมองแก้ไขและมุมมองใหม่
* ฟอร์ม Scaffold ใช้ `f.submit` ซึ่งคืนค่า "สร้าง ModelName" หรือ "อัปเดต ModelName" ขึ้นอยู่กับสถานะของวัตถุที่ผ่านเข้ามา
ในที่สุดได้เพิ่มการปรับปรุงสองอย่างใน rake tasks ดังนี้:

* เพิ่ม `rake db:forward` ซึ่งช่วยให้คุณสามารถเลื่อนการทำงานของ migrations ได้แยกตามรายการหรือกลุ่ม
* เพิ่ม `rake routes CONTROLLER=x` ซึ่งช่วยให้คุณสามารถดูเฉพาะเส้นทางสำหรับคอนโทรลเลอร์ที่เฉพาะเจาะจงได้

Railties ตอนนี้เลิกใช้งาน:

* `RAILS_ROOT` เปลี่ยนเป็น `Rails.root`
* `RAILS_ENV` เปลี่ยนเป็น `Rails.env`
* `RAILS_DEFAULT_LOGGER` เปลี่ยนเป็น `Rails.logger`

`PLUGIN/rails/tasks` และ `PLUGIN/tasks` จะไม่ถูกโหลดอีกต่อไป ทุก task ต้องอยู่ใน `PLUGIN/lib/tasks` เท่านั้น

ข้อมูลเพิ่มเติม:

* [การค้นพบ Rails 3 generators](http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators)
* [โมดูล Rails (ใน Rails 3)](http://quaran.to/blog/2010/02/03/the-rails-module/)

Action Pack
-----------

มีการเปลี่ยนแปลงที่สำคัญทั้งภายในและภายนอกใน Action Pack


### Abstract Controller

Abstract Controller ถูกแยกออกจากส่วนที่เป็นทั่วไปของ Action Controller เพื่อให้สามารถนำไปใช้ซ้ำในโมดูลอื่น ๆ ที่ต้องการใช้งานการเรนเดอร์เทมเพลต เรนเดอร์พาร์เชียล เฮลเปอร์ การแปลภาษา การเขียนล็อก และส่วนใดส่วนหนึ่งของรอบการตอบสนองของคำขอ การแยกออกนี้ช่วยให้ `ActionMailer::Base` สามารถสืบทอดมาจาก `AbstractController` และใช้ DSL ของ Rails บน gem Mail ได้

นอกจากนี้ยังช่วยให้ Action Controller สามารถทำความสะอาดโค้ดได้ง่ายขึ้นด้วย

อย่างไรก็ตาม Abstract Controller ไม่ใช่ API ที่ใช้งานโดยผู้ใช้งาน คุณจะไม่พบกับมันในการใช้งานประจำวันของคุณใน Rails

ข้อมูลเพิ่มเติม: - [Rails Edge Architecture](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Action Controller

* `application_controller.rb` ตอนนี้มี `protect_from_forgery` เปิดใช้งานโดยค่าเริ่มต้น
* `cookie_verifier_secret` ถูกเลิกใช้และตอนนี้มีการกำหนดผ่าน `Rails.application.config.cookie_secret` และย้ายไปยังไฟล์เดียวของตัวเอง: `config/initializers/cookie_verification_secret.rb`
* `session_store` ถูกกำหนดค่าใน `ActionController::Base.session` และตอนนี้ย้ายไปยัง `Rails.application.config.session_store` ค่าเริ่มต้นถูกกำหนดใน `config/initializers/session_store.rb`
* `cookies.secure` ช่วยให้คุณสามารถกำหนดค่าที่เข้ารหัสในคุกกี้ได้ด้วย `cookie.secure[:key] => value`
* `cookies.permanent` ช่วยให้คุณสามารถกำหนดค่าถาวรในแฮชของคุกกี้ได้ด้วย `cookie.permanent[:key] => value` ซึ่งจะเกิดข้อยกเว้นในค่าที่เซ็นต์ถ้าการตรวจสอบล้มเหลว
* ตอนนี้คุณสามารถส่ง `:notice => 'This is a flash message'` หรือ `:alert => 'Something went wrong'` ไปยังการเรียกใช้ `format` ภายในบล็อก `respond_to` ได้ เฮช `flash[]` ยังใช้งานเหมือนเดิม
* เพิ่มเมธอด `respond_with` เข้ามาในคอนโทรลเลอร์เพื่อทำให้บล็อก `format` ง่ายขึ้น
* เพิ่ม `ActionController::Responder` เพื่อให้คุณสามารถกำหนดการตอบสนองได้อย่างยืดหยุ่น

การเลิกใช้งาน:

* `filter_parameter_logging` ถูกเลิกใช้และแนะนำให้ใช้ `config.filter_parameters << :password` แทน

ข้อมูลเพิ่มเติม:

* [Render Options in Rails 3](https://blog.engineyard.com/2010/render-options-in-rails-3)
* [Three reasons to love ActionController::Responder](https://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder)


### Action Dispatch

Action Dispatch เป็นส่วนใหม่ใน Rails 3.0 และมีการสร้างระบบเรนเดอร์ใหม่ที่สะอาดและเป็นระเบียบมากขึ้น

* ทำความสะอาดและเขียนระบบเรนเดอร์ใหม่ให้เป็น `rack_mount` ที่มี DSL ของ Rails อยู่ด้านบน มันเป็นซอฟต์แวร์แยกต่างหากที่สามารถใช้ได้อิสระ
* เส้นทางที่กำหนดโดยแอปพลิเคชันแต่ละตัวตอนนี้ถูกเนมสเปซอยู่ภายในโมดูลแอปพลิเคชันของคุณ นั่นคือ:

    ```ruby
    # แทนที่:

    ActionController::Routing::Routes.draw do |map|
      map.resources :posts
    end

    # คุณทำ:

    AppName::Application.routes do
      resources :posts
    end
    ```

* เพิ่มเมธอด `match` เข้ามาในเรนเดอร์ คุณยังสามารถส่งแอปพลิเคชัน Rack ใด ๆ เข้ากับเส้นทางที่ตรงกันได้
* เพิ่มเมธอด `constraints` เข้ามาในเรนเดอร์ เพื่อให้คุณสามารถป้องกันเส้นทางด้วยเงื่อนไขที่กำหนดได้
* เพิ่มเมธอด `scope` เข้ามาในเรนเดอร์ เพื่อให้คุณสามารถจัดกลุ่มเส้นทางสำหรับภาษาหรือการกระทำที่แตกต่างกัน เช่น:

    ```ruby
    scope 'es' do
      resources :projects, :path_names => { :edit => 'cambiar' }, :path => 'proyecto'
    end

    # จะได้การกระทำแก้ไขด้วย /es/proyecto/1/cambiar
    ```

* เพิ่มเมธอด `root` เข้ามาในเรนเดอร์เป็นทางลัดสำหรับ `match '/', :to => path`
* คุณสามารถส่งเซกเมนต์ที่เป็นตัวเลือกได้ใน match เช่น `match "/:controller(/:action(/:id))(.:format)"` แต่ละเซกเมนต์ที่อยู่ในวงเล็บเป็นตัวเลือก
* เส้นทางสามารถแสดงผลผ่านบล็อกได้ เช่นคุณสามารถเรียกใช้ `controller :home { match '/:action' }`
หมายเหตุ: คำสั่ง `map` แบบเก่ายังทำงานเหมือนเดิมด้วยชั้นความเข้ากันได้ย้อนหลัง อย่างไรก็ตาม สิ่งนี้จะถูกลบออกในเวอร์ชัน 3.1

การเลิกใช้งาน

* เส้นทางที่รับทุกอย่างสำหรับแอปพลิเคชันที่ไม่ใช่ REST (`/:controller/:action/:id`) ถูกคอมเมนท์ออกแล้ว
* เส้นทาง `:path_prefix` ไม่มีอยู่แล้วและ `:name_prefix` ตอนนี้เพิ่ม "_" ที่สิ้นสุดของค่าที่กำหนด

ข้อมูลเพิ่มเติม:
* [The Rails 3 Router: Rack it Up](http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/)
* [Revamped Routes in Rails 3](https://medium.com/fusion-of-thoughts/revamped-routes-in-rails-3-b6d00654e5b0)
* [Generic Actions in Rails 3](http://yehudakatz.com/2009/12/20/generic-actions-in-rails-3/)


### Action View

#### Unobtrusive JavaScript

มีการเขียนใหม่ใหญ่ใน Action View helpers โดยการนำเข้า Unobtrusive JavaScript (UJS) hooks และลบคำสั่ง AJAX แบบเก่าออก สิ่งนี้ทำให้ Rails สามารถใช้ UJS driver ที่เข้ากันได้กับ UJS hooks ใน helpers ได้

สิ่งที่หมายถึงคือ ช่วงเวลาก่อนหน้านี้ `remote_<method>` helpers ทั้งหมดถูกลบออกจาก Rails core และถูกย้ายไปยัง [Prototype Legacy Helper](https://github.com/rails/prototype_legacy_helper) เพื่อให้ได้ UJS hooks เข้าไปใน HTML ของคุณ ตอนนี้คุณส่ง `:remote => true` แทน ตัวอย่างเช่น:

```ruby
form_for @post, :remote => true
```

จะสร้าง:

```html
<form action="http://host.com" id="create-post" method="post" data-remote="true">
```

#### Helpers ที่มี Blocks

Helpers เช่น `form_for` หรือ `div_for` ที่แทรกเนื้อหาจาก block ใช้ `<%=` ตอนนี้:

```html+erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

Helpers ของคุณเองที่เป็นแบบนั้นคาดหวังว่าจะส่งคืนสตริง แทนที่จะเพิ่มเข้าไปใน output buffer ด้วยตัวเอง

Helpers ที่ทำอย่างอื่น เช่น `cache` หรือ `content_for` ไม่ได้ได้รับผลกระทบจากการเปลี่ยนแปลงนี้ ต้องใช้ `&lt;%` เหมือนเดิม

#### การเปลี่ยนแปลงอื่น ๆ

* คุณไม่ต้องเรียกใช้ `h(string)` เพื่อหนีไปจากการแสดงผล HTML มันเปิดใช้งานโดยค่าเริ่มต้นในเทมเพลตทั้งหมด หากคุณต้องการสตริงที่ไม่ได้หนีไป ให้เรียกใช้ `raw(string)`
* Helpers ตอนนี้เอาออก HTML5 เป็นค่าเริ่มต้น
* Form label helper ตอนนี้ดึงค่าจาก I18n ด้วยค่าเดียว ดังนั้น `f.label :name` จะดึงค่าแปลง `:name`
* I18n select label ควรเป็น :en.helpers.select แทน :en.support.select
* คุณไม่ต้องใส่เครื่องหมายลบที่สิ้นสุดของการตัดต่อ Ruby ภายในเทมเพลต ERB เพื่อลบการเคลื่อนไหวต่อท้ายในการแสดงผล HTML
* เพิ่ม `grouped_collection_select` helper ใน Action View
* เพิ่ม `content_for?` ที่ช่วยให้คุณตรวจสอบการมีเนื้อหาในมุมมองก่อนที่จะแสดงผล
* การส่ง `:value => nil` ไปยัง form helpers จะตั้งค่า `value` attribute ของฟิลด์เป็น nil แทนที่จะใช้ค่าเริ่มต้น
* การส่ง `:id => nil` ไปยัง form helpers จะทำให้ฟิลด์เหล่านั้นถูกแสดงผลโดยไม่มี attribute `id`
* การส่ง `:alt => nil` ไปยัง `image_tag` จะทำให้แท็ก `img` ถูกแสดงโดยไม่มี attribute `alt`

Active Model
------------

Active Model เป็นส่วนใหม่ใน Rails 3.0 มันให้ชั้นคลุมสำหรับไลบรารี ORM ใด ๆ ที่จะใช้ในการติดต่อกับ Rails โดยการนำเข้า Active Model interface


### ORM Abstraction และ Action Pack Interface

ส่วนหนึ่งของการแยกส่วนคอมโพเนนต์หลักคือการแยกการเชื่อมต่อกับ Active Record ออกจาก Action Pack สิ่งนี้ได้รับการดำเนินการเสร็จสมบูรณ์แล้ว ปลั๊กอิน ORM ใหม่ทั้งหมดตอนนี้เพียงแค่ต้องนำเข้า Active Model interfaces เพื่อทำงานร่วมกับ Action Pack ได้อย่างราบรื่น

ข้อมูลเพิ่มเติม: - [Make Any Ruby Object Feel Like ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### การตรวจสอบความถูกต้อง

การตรวจสอบความถูกต้องถูกย้ายจาก Active Record เข้าสู่ Active Model เพื่อให้มีอินเตอร์เฟซในการตรวจสอบความถูกต้องที่ทำงานร่วมกับไลบรารี ORM ใน Rails 3

* ตอนนี้มีเมธอดตัวย่อ `validates :attribute, options_hash` ที่ช่วยให้คุณส่งตัวเลือกสำหรับเมธอด validates ทั้งหมด คุณสามารถส่งตัวเลือกมากกว่าหนึ่งตัวเข้าไปในเมธอด validate
* เมธอด validates มีตัวเลือกต่อไปนี้:
    * `:acceptance => Boolean`
    * `:confirmation => Boolean`
    * `:exclusion => { :in => Enumerable }`
    * `:inclusion => { :in => Enumerable }`
    * `:format => { :with => Regexp, :on => :create }`
    * `:length => { :maximum => Fixnum }`
    * `:numericality => Boolean`
    * `:presence => Boolean`
    * `:uniqueness => Boolean`
หมายเหตุ: วิธีการตรวจสอบแบบเดิมของ Rails เวอร์ชัน 2.3 ยังคงรองรับใน Rails 3.0 แต่เมธอด validates ใหม่ถูกออกแบบเป็นการช่วยเพิ่มเติมในการตรวจสอบโมเดลของคุณ และไม่ใช่การแทนที่ API ที่มีอยู่ในปัจจุบัน

คุณยังสามารถส่งออบเจกต์ตัวตรวจสอบได้ซึ่งคุณสามารถนำกลับมาใช้ใหม่ระหว่างวัตถุที่ใช้ Active Model:

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

ยังมีการสนับสนุนการตรวจสอบด้วยตนเอง:

```ruby
User.validators
User.validators_on(:login)
```

ข้อมูลเพิ่มเติม:

* [การตรวจสอบที่น่าสนใจใน Rails 3](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)
* [การอธิบายการตรวจสอบใน Rails 3](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)


Active Record
-------------

Active Record ได้รับความสนใจมากใน Rails 3.0 รวมถึงการแยกตัวอย่างเป็น Active Model, การอัปเดตเต็มรูปแบบในอินเตอร์เฟสคิวรีโดยใช้ Arel, การอัปเดตการตรวจสอบ และการปรับปรุงและการแก้ไขอีกมากมาย ทั้งหมดของ API ใน Rails 2.x สามารถใช้ได้ผ่านชั้นความเข้ากันได้ที่จะรองรับจนถึงเวอร์ชัน 3.1 และจะไม่ถูกลบออกจนถึงเวอร์ชัน 3.2

### อินเตอร์เฟสคิวรี

Active Record ผ่านการใช้ Arel ตอนนี้ส่งคืนความสัมพันธ์ในเมธอดหลักของมัน ยังคงรองรับ API ที่มีอยู่ใน Rails 2.3.x และจะไม่ถูกยกเลิกจนถึง Rails 3.1 และไม่ถูกลบออกจนถึง Rails 3.2 อย่างไรก็ตาม API ใหม่นี้มีเมธอดใหม่ที่ให้คืนความสัมพันธ์ต่อกันทั้งหมดที่อนุญาตให้เชื่อมต่อกันได้:

* `where` - ให้เงื่อนไขในความสัมพันธ์ สิ่งที่จะได้รับกลับมา
* `select` - เลือกแอตทริบิวต์ของโมเดลที่คุณต้องการให้คืนค่าจากฐานข้อมูล
* `group` - จัดกลุ่มความสัมพันธ์ตามแอตทริบิวต์ที่กำหนด
* `having` - ให้นิพจน์ที่จำกัดความสัมพันธ์ของกลุ่ม (เงื่อนไข GROUP BY)
* `joins` - เชื่อมต่อความสัมพันธ์กับตารางอื่น
* `clause` - ให้นิพจน์ที่จำกัดความสัมพันธ์การเชื่อมต่อ (เงื่อนไข JOIN)
* `includes` - รวมความสัมพันธ์อื่นที่โหลดล่วงหน้า
* `order` - เรียงลำดับความสัมพันธ์ตามนิพจน์ที่กำหนด
* `limit` - จำกัดความสัมพันธ์ไปยังจำนวนเร็คคอร์ดที่ระบุ
* `lock` - ล็อกเรคคอร์ดที่คืนค่าจากตาราง
* `readonly` - คืนค่าสำเนาข้อมูลที่อ่านอย่างเดียว
* `from` - ให้วิธีการเลือกความสัมพันธ์จากตารางมากกว่าหนึ่งตาราง
* `scope` - (ก่อนหน้านี้เป็น `named_scope`) คืนค่าความสัมพันธ์และสามารถเชื่อมต่อกับเมธอดความสัมพันธ์อื่นได้
* `with_scope` - และ `with_exclusive_scope` ตอนนี้ยังคืนค่าความสัมพันธ์และสามารถเชื่อมต่อกันได้
* `default_scope` - ยังทำงานร่วมกับความสัมพันธ์ได้

ข้อมูลเพิ่มเติม:

* [อินเตอร์เฟสคิวรีของ Active Record](http://m.onkey.org/2010/1/22/active-record-query-interface)
* [ปล่อยให้ SQL ของคุณเติบโตใน Rails 3](http://hasmanyquestions.wordpress.com/2010/01/17/let-your-sql-growl-in-rails-3/)


### การปรับปรุง

* เพิ่ม `:destroyed?` ให้กับออบเจกต์ Active Record
* เพิ่ม `:inverse_of` ให้กับความสัมพันธ์ของ Active Record เพื่อให้คุณสามารถดึงอินสแตนซ์ของความสัมพันธ์ที่โหลดแล้วได้โดยไม่ต้องเข้าถึงฐานข้อมูล

### การแก้ไขและการยกเลิก

นอกจากนี้ยังมีการแก้ไขในส่วนของ Active Record:

* ไม่รองรับ SQLite 2 และเลือก SQLite 3 แทน
* รองรับการเรียงลำดับคอลัมน์ของ MySQL
* แก้ไขการสนับสนุน `TIME ZONE` ใน PostgreSQL ให้ไม่แทรกค่าผิด
* รองรับสกีมาหลายรูปแบบในชื่อตารางสำหรับ PostgreSQL
* รองรับชนิดข้อมูล XML ในคอลัมน์ของ PostgreSQL
* แคช `table_name` ตอนนี้
* ทำงานจำนวนมากกับอแดปเตอร์ Oracle พร้อมกับการแก้ไขข้อบกพร่องหลายอย่าง

รวมถึงการยกเลิกต่อไปนี้:

* `named_scope` ในคลาส Active Record ถูกยกเลิกและถูกเปลี่ยนชื่อเป็น `scope` เท่านั้น
* ในเมธอด `scope` คุณควรเปลี่ยนไปใช้เมธอดความสัมพันธ์แทนการใช้เมธอดค้นหา `:conditions => {}` เช่น `scope :since, lambda {|time| where("created_at > ?", time) }`
* `save(false)` ถูกยกเลิกและใช้แทนด้วย `save(:validate => false)`
* ข้อความข้อผิดพลาด I18n สำหรับ Active Record ควรเปลี่ยนจาก :en.activerecord.errors.template เป็น `:en.errors.template`
* `model.errors.on` ถูกยกเลิกและใช้แทนด้วย `model.errors[]`
* validates_presence_of => validates... :presence => true
* `ActiveRecord::Base.colorize_logging` และ `config.active_record.colorize_logging` ถูกยกเลิกและใช้แทนด้วย `Rails::LogSubscriber.colorize_logging` หรือ `config.colorize_logging`
หมายเหตุ: ในขณะที่การนำมาใช้งานของ State Machine ได้มีการใช้งานใน Active Record edge เป็นเวลาหลายเดือนแล้ว แต่ได้ถูกลบออกจากการเปิดตัวของ Rails 3.0

Active Resource
---------------

Active Resource ถูกแยกออกมาเป็น Active Model เพื่อให้คุณสามารถใช้วัตถุ Active Resource ร่วมกับ Action Pack ได้อย่างไม่มีปัญหา

* เพิ่มการตรวจสอบความถูกต้องผ่าน Active Model
* เพิ่มการตรวจสอบก่อนหลัง
* รองรับการใช้งาน HTTP proxy
* เพิ่มการรับรองความถูกต้องผ่านการตรวจสอบความถูกต้อง
* ย้ายการตั้งชื่อโมเดลไปยัง Active Model
* เปลี่ยนแอตทริบิวต์ของ Active Resource เป็น Hash ที่สามารถเข้าถึงได้โดยไม่สนใจการเข้าถึง
* เพิ่ม `first`, `last` และ `all` เป็นนามแฝงสำหรับขอบเขตการค้นหาที่เทียบเท่ากัน
* `find_every` ตอนนี้ไม่คืนค่าข้อผิดพลาด `ResourceNotFound` หากไม่มีข้อมูลที่คืนค่า
* เพิ่ม `save!` ซึ่งจะเรียก `ResourceInvalid` ยกเว้นกรณีที่วัตถุเป็น `valid?`
* เพิ่ม `update_attribute` และ `update_attributes` ในโมเดล Active Resource
* เพิ่ม `exists?`
* เปลี่ยนชื่อ `SchemaDefinition` เป็น `Schema` และ `define_schema` เป็น `schema`
* ใช้ `format` ของ Active Resources แทน `content-type` ของข้อผิดพลาดระยะไกลในการโหลดข้อผิดพลาด
* ใช้ `instance_eval` สำหรับบล็อก schema
* แก้ไข `ActiveResource::ConnectionError#to_s` เมื่อ `@response` ไม่ตอบสนองกับ #code หรือ #message จัดการความเข้ากันได้กับ Ruby 1.9
* เพิ่มการรับรองความผิดพลาดในรูปแบบ JSON
* ตรวจสอบว่า `load` ทำงานกับอาร์เรย์ที่มีตัวเลขได้
* รู้จักการตอบสนอง 410 จากทรัพยากรระยะไกลว่าทรัพยากรถูกลบแล้ว
* เพิ่มความสามารถในการตั้งค่า SSL ในการเชื่อมต่อ Active Resource
* การตั้งค่าเวลาหมดเวลาการเชื่อมต่อจะมีผลต่อ `Net::HTTP` `open_timeout`

การเลิกใช้:

* `save(false)` ถูกเลิกใช้แล้ว แทนที่จะใช้ `save(:validate => false)`
* Ruby 1.9.2: `URI.parse` และ `.decode` ถูกเลิกใช้และไม่ได้ใช้ในไลบรารีอีกต่อไป


Active Support
--------------

มีความพยายามใน Active Support เพื่อให้สามารถเลือกใช้ได้เป็นส่วนๆ นั่นคือคุณไม่ต้องต้องร้องขอไลบรารี Active Support ทั้งหมดเพื่อให้ได้ส่วนที่ต้องการ ซึ่งช่วยให้ส่วนประกอบหลักต่างๆ ของ Rails ทำงานได้อย่างเบา

นี่คือการเปลี่ยนแปลงหลักใน Active Support:

* ทำความสะอาดไลบรารีโดยการลบเมธอดที่ไม่ได้ใช้งานทั่วไปออก
* Active Support ไม่ได้ให้เวอร์ชันที่ถูกจัดหาของ TZInfo, Memcache Client และ Builder อีกต่อไป สิ่งเหล่านี้ถูกติดตั้งเป็น dependencies และติดตั้งผ่านคำสั่ง `bundle install`
* สร้าง Safe buffers ใน `ActiveSupport::SafeBuffer`
* เพิ่ม `Array.uniq_by` และ `Array.uniq_by!`
* ลบ `Array#rand` และนำ `Array#sample` จาก Ruby 1.9 กลับมาใช้
* แก้ไขข้อบกพร่องใน `TimeZone.seconds_to_utc_offset` ที่คืนค่าผิด
* เพิ่ม `ActiveSupport::Notifications` middleware
* `ActiveSupport.use_standard_json_time_format` ตอนนี้มีค่าเริ่มต้นเป็น true
* `ActiveSupport.escape_html_entities_in_json` ตอนนี้มีค่าเริ่มต้นเป็น false
* `Integer#multiple_of?` ยอมรับค่าศูนย์เป็นอาร์กิวเมนต์ และคืนค่าเท็จเว้นแต่ว่าผู้รับจะเป็นศูนย์
* `string.chars` ถูกเปลี่ยนชื่อเป็น `string.mb_chars`
* `ActiveSupport::OrderedHash` ตอนนี้สามารถถอดรหัสผ่าน YAML ได้
* เพิ่มตัวแยกวิเคราะห์ที่ใช้ SAX สำหรับ XmlMini โดยใช้ LibXML และ Nokogiri
* เพิ่ม `Object#presence` ซึ่งคืนค่าวัตถุหาก `#present?` มิฉะนั้นคืนค่าเป็น `nil`
* เพิ่มส่วนขยายหลัก `String#exclude?` ที่คืนค่าตรงกันข้ามของ `#include?`
* เพิ่ม `to_i` ใน `DateTime` ใน `ActiveSupport` เพื่อให้ `to_yaml` ทำงานได้อย่างถูกต้องกับโมเดลที่มีแอตทริบิวต์ `DateTime`
* เพิ่ม `Enumerable#exclude?` เพื่อให้เทียบเท่ากับ `Enumerable#include?` และหลีกเลี่ยงการใช้ `!x.include?`
* เปลี่ยนเป็นการหลีกเลี่ยงการทำ XSS escaping ใน Rails โดยค่าเริ่มต้น
* รองรับการผสานกันลึกใน `ActiveSupport::HashWithIndifferentAccess`
* `Enumerable#sum` ทำงานกับ enumerables ทั้งหมด แม้ว่าจะไม่ตอบสนองต่อ `:size`
* `inspect` ของระยะเวลาที่ยาวเท่าศูนย์จะคืนค่า '0 seconds' แทนที่จะเป็นสตริงว่างเปล่า
* เพิ่ม `element` และ `collection` ใน `ModelName`
* `String#to_time` และ `String#to_datetime` จัดการกับวินาทีทศนิยม
* เพิ่มการรองรับคำสั่งใหม่สำหรับตัวกรองรอบสำหรับวัตถุที่ตอบสนองกับ `:before` และ `:after` ที่ใช้ในตัวกรองก่อนและหลัง
* เมธอด `ActiveSupport::OrderedHash#to_a` คืนค่าชุดของอาร์เรย์ที่เรียงลำดับ ตรงกับ `Hash#to_a` ของ Ruby 1.9
* `MissingSourceFile` ยังคงเป็นค่าคงที่ แต่ตอนนี้เท่ากับ `LoadError`
* เพิ่ม `Class#class_attribute` เพื่อสามารถประกาศแอตทริบิวต์ระดับคลาสที่มีค่าที่สืบทอดและสามารถเขียนทับได้โดยคลาสย่อย
* ลบ `DeprecatedCallbacks` ใน `ActiveRecord::Associations` ออกสุดท้าย
* `Object#metaclass` ตอนนี้เป็น `Kernel#singleton_class` เพื่อให้เข้ากันได้กับ Ruby
วิธีการต่อไปนี้ถูกลบออกเนื่องจากตอนนี้มีให้ใช้ใน Ruby 1.8.7 และ 1.9

* `Integer#even?` และ `Integer#odd?`
* `String#each_char`
* `String#start_with?` และ `String#end_with?` (ยังเก็บคำสั่งเป็นบุคคลที่สาม)
* `String#bytesize`
* `Object#tap`
* `Symbol#to_proc`
* `Object#instance_variable_defined?`
* `Enumerable#none?`

แพทช์ความปลอดภัยสำหรับ REXML ยังคงอยู่ใน Active Support เนื่องจากต้องใช้กับรุ่นเริ่มต้นของ Ruby 1.8.7 อย่างไรก็ตาม Active Support รู้ว่าจะต้องใช้หรือไม่ต้องใช้

วิธีการต่อไปนี้ถูกลบออกเนื่องจากไม่ได้ใช้ในเฟรมเวิร์กอีกต่อไป

* `Kernel#daemonize`
* `Object#remove_subclasses_of` `Object#extend_with_included_modules_from`, `Object#extended_by`
* `Class#remove_class`
* `Regexp#number_of_captures`, `Regexp.unoptionalize`, `Regexp.optionalize`, `Regexp#number_of_captures`


Action Mailer
-------------

Action Mailer ได้รับ API ใหม่โดย TMail ถูกแทนที่ด้วย [Mail](https://github.com/mikel/mail) เป็นไลบรารีอีเมลใหม่  Action Mailer เองได้รับการเขียนใหม่เกือบทั้งหมดโดยเกือบทุกบรรทัดของโค้ดถูกแตะไป ผลลัพธ์คือ Action Mailer ตอนนี้เพียงแค่สืบทอดจาก Abstract Controller และห่อหุ้ม Mail gem ด้วย Rails DSL ซึ่งลดปริมาณโค้ดและการทำซ้ำของไลบรารีอื่น ๆ ใน Action Mailer อย่างมาก

* ทุกเมลเลอร์ตอนนี้อยู่ใน `app/mailers` ตามค่าเริ่มต้น
* สามารถส่งอีเมลด้วย API ใหม่ได้ด้วยวิธีการสามวิธี: `attachments`, `headers` และ `mail`
* Action Mailer ตอนนี้มีการสนับสนุนการแนบไฟล์แบบอินไลน์โดยใช้วิธี `attachments.inline`
* เมทอดส่งอีเมลของ Action Mailer ตอนนี้จะส่งกลับ `Mail::Message` object ซึ่งสามารถส่งข้อความ `deliver` เพื่อส่งอีเมลได้
* วิธีการส่งอีเมลทั้งหมดถูกแยกออกไปยัง Mail gem
* วิธีการส่งอีเมลสามารถรับแฮชของฟิลด์ส่วนหัวอีเมลทั้งหมดที่ถูกต้องพร้อมคู่ค่าของเขตระหว่าง
* เมทอดการส่ง `mail` ทำงานในลักษณะเดียวกับ `respond_to` ของ Action Controller และคุณสามารถเรียกใช้งานเทมเพลตได้โดยชัดเจนหรือไม่ชัดเจน Action Mailer จะแปลงอีเมลเป็นอีเมลหลายส่วนตามความต้องการ
* คุณสามารถส่ง proc ไปยังการเรียกใช้ `format.mime_type` ภายในบล็อกอีเมลและเรียกใช้งานเนื้อหาข้อความประเภทต่าง ๆ หรือเพิ่มเลเอาท์หรือเทมเพลตที่แตกต่างกัน เรียกใช้งาน `render` ภายใน proc มาจาก Abstract Controller และรองรับตัวเลือกเดียวกัน
* เมลเลอร์เทสที่เคยเป็นหน่วยทดสอบได้ถูกย้ายไปยังการทดสอบฟังก์ชัน
* Action Mailer ตอนนี้มอบหมายให้ Mail Gem เข้ารหัสอัตโนมัติทั้งฟิลด์ส่วนหัวและเนื้อหา

การเลิกใช้:

* `:charset`, `:content_type`, `:mime_version`, `:implicit_parts_order` ถูกเลิกใช้และแนะนำให้ใช้การประกาศแบบ `ActionMailer.default :key => value`
* Mailer dynamic `create_method_name` และ `deliver_method_name` ถูกเลิกใช้งาน เพียงเรียก `method_name` ซึ่งตอนนี้จะส่งกลับ `Mail::Message` object
* `ActionMailer.deliver(message)` ถูกเลิกใช้งาน เพียงเรียก `message.deliver`
* `template_root` ถูกเลิกใช้งาน ส่งค่าเลือกไปยังการเรียกใช้งานเทมเพลตภายใน proc จากเมทอด `format.mime_type` ภายในบล็อกการสร้าง `mail`
* เมทอด `body` ในการกำหนดตัวแปรอินสแตนซ์ถูกเลิกใช้งาน (`body {:ivar => value}`) เพียงเรียกตัวแปรอินสแตนซ์โดยตรงในเมทอดและจะสามารถใช้ในมุมมองได้
* เมลเลอร์ที่อยู่ใน `app/models` ถูกเลิกใช้งาน ให้ใช้ `app/mailers` แทน

ข้อมูลเพิ่มเติม:

* [API ใหม่ของ Action Mailer ใน Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)
* [Mail Gem ใหม่สำหรับ Ruby](http://lindsaar.net/2010/1/23/mail-gem-version-2-released)


เครดิต
-------

ดูรายชื่อเต็มของผู้มีส่วนร่วมใน Rails ได้ที่ [รายชื่อผู้มีส่วนร่วมใน Rails](https://contributors.rubyonrails.org/) สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails 3 ขอบคุณทุกคน

บันทึกการเปิดตัวของ Rails 3.0 ถูกรวบรวมโดย [Mikel Lindsaar](http://lindsaar.net)
