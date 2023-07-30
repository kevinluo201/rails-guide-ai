**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2cf37358fedc8b51ed3ab7f408ecfc76
เริ่มต้นใช้ Rails
=================

เอกสารนี้เป็นคู่มือสำหรับการเริ่มต้นใช้ Ruby on Rails

หลังจากอ่านคู่มือนี้คุณจะรู้:

* วิธีติดตั้ง Rails, สร้างแอปพลิเคชัน Rails ใหม่ และเชื่อมต่อแอปพลิเคชันของคุณกับฐานข้อมูล
* โครงสร้างทั่วไปของแอปพลิเคชัน Rails
* หลักการพื้นฐานของ MVC (Model, View, Controller) และการออกแบบ RESTful
* วิธีการสร้างส่วนเริ่มต้นของแอปพลิเคชัน Rails อย่างรวดเร็ว

--------------------------------------------------------------------------------

สมมติฐานในคู่มือ
-----------------

คู่มือนี้ออกแบบมาสำหรับผู้เริ่มต้นที่ต้องการเริ่มสร้างแอปพลิเคชัน Rails จากศูนย์ต้นทาง ไม่ต้องการความรู้ก่อนหน้าเกี่ยวกับ Rails

Rails เป็นเฟรมเวิร์กสำหรับการพัฒนาแอปพลิเคชันเว็บที่เขียนด้วยภาษาโปรแกรม Ruby มันถูกออกแบบให้ง่ายต่อการเขียนแอปพลิเคชันเว็บโดยทำสมมติฐานเกี่ยวกับสิ่งที่นักพัฒนาทุกคนต้องการเพื่อเริ่มต้น มันช่วยให้คุณเขียนโค้ดน้อยลงในขณะที่ทำงานได้มากกว่าภาษาและเฟรมเวิร์กอื่น ๆ นักพัฒนา Rails ที่มีประสบการณ์ก็รายงานว่ามันทำให้การพัฒนาแอปพลิเคชันเว็บเป็นเรื่องสนุกขึ้น

Rails เป็นซอฟต์แวร์ที่มีความเชื่อมั่น มันสมมติว่ามี "วิธีที่ดีที่สุด" ในการทำสิ่งต่าง ๆ และถูกออกแบบให้ส่งเสริมวิธีนั้น - และในบางกรณีอาจจะปฏิเสธวิธีทางเลือก หากคุณเรียนรู้ "The Rails Way" คุณอาจค้นพบว่าความสามารถในการทำงานของคุณเพิ่มขึ้นอย่างมหาศาล หากคุณยืนกรานในการนำเอานิสัยเก่าจากภาษาอื่น ๆ มาใช้ในการพัฒนา Rails ของคุณ และพยายามใช้รูปแบบที่คุณเรียนรู้จากที่อื่น ๆ คุณอาจมีประสบการณ์ที่ไม่ดีเท่านั้น

ปรัชญาของ Rails ประกอบด้วยหลักการนำทางสองอย่างหลัก:

* **Don't Repeat Yourself (DRY):** DRY เป็นหลักการในการพัฒนาซอฟต์แวร์ที่กล่าวว่า "ทุกชิ้นของความรู้ต้องมีการแสดงอย่างเดียวเท่านั้นภายในระบบ" โดยไม่ต้องเขียนข้อมูลเดียวกันซ้ำซ้อน โค้ดของเราจะง่ายต่อการบำรุงรักษา สามารถขยายได้มากขึ้น และมีข้อผิดพลาดน้อยลง
* **Convention Over Configuration:** Rails มีความคิดเห็นเกี่ยวกับวิธีการที่ดีที่สุดในการทำสิ่งต่าง ๆ ในแอปพลิเคชันเว็บ และใช้ค่าเริ่มต้นของการสร้างสรรค์นี้แทนที่จะต้องระบุรายละเอียดเล็ก ๆ น้อย ๆ ผ่านไฟล์การกำหนดค่าที่ไม่สิ้นสุด
สร้างโปรเจค Rails ใหม่
----------------------------

วิธีที่ดีที่สุดในการอ่านเอกสารนี้คือการทำตามขั้นตอนทีละขั้นตอน ขั้นตอนทั้งหมดเป็นสิ่งที่จำเป็นในการเรียกใช้แอปพลิเคชันตัวอย่างนี้และไม่จำเป็นต้องเพิ่มโค้ดหรือขั้นตอนเพิ่มเติม

โดยการทำตามขั้นตอนในเอกสารนี้ คุณจะสร้างโปรเจค Rails ที่ชื่อ `blog` ซึ่งเป็นเว็บบล็อก (weblog) ที่ง่ายมาก ก่อนที่คุณจะเริ่มสร้างแอปพลิเคชัน คุณต้องตรวจสอบให้แน่ใจว่าคุณได้ติดตั้ง Rails เอง

หมายเหตุ: ตัวอย่างด้านล่างใช้ `$` เพื่อแทนโปรมตรงของคุณในระบบปฏิบัติการแบบ UNIX แม้ว่ามันอาจถูกปรับแต่งให้แสดงผลต่างกันไป หากคุณใช้ Windows โปรมของคุณจะมีลักษณะคล้ายกับ `C:\source_code>`

### การติดตั้ง Rails

ก่อนที่คุณจะติดตั้ง Rails คุณควรตรวจสอบเพื่อให้แน่ใจว่าระบบของคุณมีสิ่งที่จำเป็นติดตั้งไว้ รวมถึง:

* Ruby
* SQLite3

#### การติดตั้ง Ruby

เปิดโปรแกรมคอมมานด์ไลน์ (command line prompt) บน macOS เปิด Terminal.app บน Windows เลือก "Run" จากเมนู Start และพิมพ์ `cmd.exe` คำสั่งใดๆที่มีเครื่องหมายดอลลาร์ `$` นำหน้าควรรันในโปรแกรมคอมมานด์ไลน์ ตรวจสอบว่าคุณได้ติดตั้ง Ruby เวอร์ชันปัจจุบัน:

```bash
$ ruby --version
ruby 2.7.0
```

Rails ต้องการ Ruby เวอร์ชัน 2.7.0 หรือใหม่กว่า แนะนำให้ใช้เวอร์ชันล่าสุดของ Ruby หากเลขเวอร์ชันที่แสดงออกมาน้อยกว่า (เช่น 2.3.7 หรือ 1.8.7) คุณจะต้องติดตั้ง Ruby ใหม่

ในการติดตั้ง Rails บน Windows คุณจะต้องติดตั้ง [Ruby Installer](https://rubyinstaller.org/) ก่อน

สำหรับวิธีการติดตั้งอื่นๆสำหรับระบบปฏิบัติการส่วนใหญ่ โปรดดูที่
[ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/)

#### การติดตั้ง SQLite3

คุณยังต้องติดตั้งฐานข้อมูล SQLite3 อีกด้วย
ระบบปฏิบัติการแบบ UNIX ที่ได้รับความนิยมมักจะมี SQLite3 เวอร์ชันที่เหมาะสม
สำหรับระบบปฏิบัติการอื่นๆ สามารถหาคำแนะนำการติดตั้งได้ที่เว็บไซต์ [SQLite3](https://www.sqlite.org)

ตรวจสอบว่าติดตั้งถูกต้องและอยู่ใน `PATH` ของคุณ:

```bash
$ sqlite3 --version
```

โปรแกรมควรรายงานเวอร์ชัน

#### การติดตั้ง Rails

ในการติดตั้ง Rails ให้ใช้คำสั่ง `gem install` ที่ RubyGems จัดหาให้:

```bash
$ gem install rails
```

เพื่อตรวจสอบว่าคุณติดตั้งทุกอย่างถูกต้อง คุณควรสามารถรันคำสั่งต่อไปนี้ในโปรแกรมคอมมานด์ไลน์ใหม่:

```bash
$ rails --version
```

หากมีข้อความที่บอกว่า "Rails 7.0.0" คุณพร้อมที่จะดำเนินการต่อ

### การสร้างแอปพลิเคชันบล็อก

Rails มาพร้อมกับสคริปต์ต่างๆที่เรียกว่า generators ซึ่งออกแบบมาเพื่อทำให้งานการพัฒนาของคุณง่ายขึ้นโดยการสร้างทุกอย่างที่จำเป็นในการเริ่มต้นทำงานในงานที่เฉพาะเจาะจง หนึ่งในนั้นคือ generator ของแอปพลิเคชันใหม่ ซึ่งจะให้คุณได้รับพื้นฐานของแอปพลิเคชัน Rails ใหม่เพื่อให้คุณไม่ต้องเขียนเอง
ในการใช้เครื่องมือสร้างนี้ ให้เปิด terminal และนำทางไปยังไดเรกทอรีที่คุณมีสิทธิ์ในการสร้างไฟล์ แล้วรันคำสั่งต่อไปนี้:

```bash
$ rails new blog
```

นี้จะสร้างแอปพลิเคชัน Rails ที่ชื่อ Blog ในไดเรกทอรี `blog` และติดตั้ง gem dependencies ที่ได้กล่าวถึงใน `Gemfile` โดยใช้ `bundle install`.

เคล็ดลับ: คุณสามารถดูตัวเลือกคำสั่งทั้งหมดที่เครื่องมือสร้างแอปพลิเคชัน Rails รองรับได้โดยรันคำสั่ง `rails new --help`.

หลังจากสร้างแอปพลิเคชันบล็อกแล้ว ให้เปลี่ยนไปยังโฟลเดอร์ของมัน:

```bash
$ cd blog
```

ไดเรกทอรี `blog` จะมีไฟล์และโฟลเดอร์ที่สร้างขึ้นมาหลายรายการที่เป็นส่วนประกอบของโครงสร้างของแอปพลิเคชัน Rails ส่วนใหญ่ของงานในบทแนะนำนี้จะเกิดขึ้นในโฟลเดอร์ `app` แต่นี่คือการอธิบายพื้นฐานเกี่ยวกับฟังก์ชันของแต่ละไฟล์และโฟลเดอร์ที่ Rails สร้างโดยค่าเริ่มต้น:

| ไฟล์/โฟลเดอร์ | วัตถุประสงค์ |
| ----------- | ------- |
|app/|มีควบคุมเกี่ยวกับ controllers, models, views, helpers, mailers, channels, jobs, และ assets สำหรับแอปพลิเคชันของคุณ คุณจะใช้โฟลเดอร์นี้ในส่วนที่เหลือของคู่มือนี้|
|bin/|มีสคริปต์ `rails` ที่ใช้เริ่มแอปพลิเคชันของคุณและอาจมีสคริปต์อื่น ๆ ที่คุณใช้ในการตั้งค่า อัปเดต ใช้งาน หรือรันแอปพลิเคชันของคุณ|
|config/|มีการตั้งค่าสำหรับเส้นทางของแอปพลิเคชัน ฐานข้อมูล และอื่น ๆ นี่จะอธิบายอย่างละเอียดมากขึ้นใน [การกำหนดค่าแอปพลิเคชัน Rails](configuring.html)|
|config.ru|การกำหนดค่า Rack สำหรับเซิร์ฟเวอร์ที่ใช้ Rack เพื่อเริ่มแอปพลิเคชัน สำหรับข้อมูลเพิ่มเติมเกี่ยวกับ Rack ดูที่ [เว็บไซต์ Rack](https://rack.github.io/)|
|db/|มีแผนฐานข้อมูลปัจจุบันของคุณรวมถึงการเคลื่อนย้ายฐานข้อมูล|
|Gemfile<br>Gemfile.lock|ไฟล์เหล่านี้ช่วยให้คุณระบุว่า gem dependencies ใดที่จำเป็นสำหรับแอปพลิเคชัน Rails ของคุณ ไฟล์เหล่านี้ถูกใช้โดย Bundler gem สำหรับข้อมูลเพิ่มเติมเกี่ยวกับ Bundler ดูที่ [เว็บไซต์ Bundler](https://bundler.io)|
|lib/|โมดูลที่ถูกขยายสำหรับแอปพลิเคชันของคุณ|
|log/|ไฟล์บันทึกแอปพลิเคชัน|
|public/|มีไฟล์และคอมไพล์แอสเซ็ตแบบสถิต ขณะที่แอปของคุณกำลังทำงานโฟลเดอร์นี้จะถูกเปิดเผยอย่างเดียว|
|Rakefile|ไฟล์นี้ค้นหาและโหลดงานที่สามารถรันได้จาก command line การกำหนดงานถูกกำหนดไว้ทั่วทั้งส่วนประกอบของ Rails แทนที่จะเปลี่ยน `Rakefile` คุณควรเพิ่มงานของคุณเองโดยเพิ่มไฟล์ในโฟลเดอร์ `lib/tasks` ของแอปพลิเคชันของคุณ|
|README.md|นี่เป็นคู่มือคำสั่งสั้น ๆ สำหรับแอปพลิเคชันของคุณ คุณควรแก้ไขไฟล์นี้เพื่อบอกผู้อื่นว่าแอปพลิเคชันของคุณทำอะไร วิธีการตั้งค่า และอื่น ๆ|
|storage/|ไฟล์ Active Storage สำหรับ Disk Service นี้อธิบายอย่างละเอียดใน [ภาพรวม Active Storage](active_storage_overview.html)|
|test/|เครื่องมือทดสอบหน่วย คำสั่งติดตั้ง และอุปกรณ์ทดสอบอื่น ๆ นี้อธิบายอย่างละเอียดใน [การทดสอบแอปพลิเคชัน Rails](testing.html)|
|tmp/|ไฟล์ชั่วคราว (เช่นแคชและไฟล์ pid)|
|vendor/|สถานที่สำหรับโค้ดจากบุคคลที่สาม ในแอปพลิเคชัน Rails ปกตินี้รวมถึง gem ที่ขาย|
|.gitattributes|ไฟล์นี้กำหนดข้อมูลเมตาดาต้าสำหรับเส้นทางที่ระบุในรีพอสิทอรี git ข้อมูลเมตาดาต้าเหล่านี้สามารถใช้โดย git และเครื่องมืออื่น ๆ เพื่อเพิ่มประสิทธิภาพของพฤติกรรมของพวกเขา ดูที่ [เอกสาร gitattributes](https://git-scm.com/docs/gitattributes) สำหรับข้อมูลเพิ่มเติม|
|.gitignore|ไฟล์นี้บอก git ว่าไฟล์ (หรือรูปแบบ) ใดที่ควรถูกละเว้น ดูที่ [GitHub - การละเว้นไฟล์](https://help.github.com/articles/ignoring-files) สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการละเว้นไฟล์|
|.ruby-version|ไฟล์นี้มีรุ่น Ruby เริ่มต้น|
สวัสดี Rails!
-------------

เริ่มต้นด้วยการนำข้อความขึ้นหน้าจอโดยรวดเร็ว ในการทำนี้คุณต้องเริ่มเซิร์ฟเวอร์แอปพลิเคชัน Rails ของคุณ

### เริ่มต้นเว็บเซิร์ฟเวอร์

คุณมีแอปพลิเคชัน Rails ที่ใช้งานได้แล้วจริงๆ หากต้องการดูแอปพลิเคชันนี้ คุณต้องเริ่มเว็บเซิร์ฟเวอร์บนเครื่องพัฒนาของคุณ คุณสามารถทำได้โดยรันคำสั่งต่อไปนี้ในไดเรกทอรี `blog`:

```bash
$ bin/rails server
```

เคล็ดลับ: หากคุณใช้ Windows คุณต้องส่งสคริปต์ในโฟลเดอร์ `bin` โดยตรงไปยังตัวแปลงรูบี เช่น `ruby bin\rails server`.

เคล็ดลับ: การบีบอัด JavaScript asset ต้องการ JavaScript runtime ที่พร้อมใช้งานบนระบบของคุณ หากไม่มี runtime คุณจะเห็นข้อผิดพลาด `execjs` ระหว่างการบีบอัด asset โดยทั่วไป macOS และ Windows มาพร้อมกับ JavaScript runtime ที่ติดตั้งแล้ว `therubyrhino` เป็น runtime ที่แนะนำสำหรับผู้ใช้ JRuby และถูกเพิ่มเข้าไปใน `Gemfile` โดยค่าเริ่มต้นในแอปที่สร้างขึ้นภายใต้ JRuby คุณสามารถสำรวจ runtime ที่รองรับได้ทั้งหมดที่ [ExecJS](https://github.com/rails/execjs#readme).

นี้จะเริ่ม Puma เว็บเซิร์ฟเวอร์ที่กระจายพร้อมกับ Rails โดยค่าเริ่มต้น เพื่อดูแอปพลิเคชันของคุณในการทำงาน เปิดหน้าต่างเบราว์เซอร์และไปยัง <http://localhost:3000> คุณควรเห็นหน้าข้อมูลเริ่มต้นของ Rails:

![รูปหน้าเริ่มต้นของ Rails](images/getting_started/rails_welcome.png)

เมื่อคุณต้องการหยุดเว็บเซิร์ฟเวอร์ ให้กด Ctrl+C ในหน้าต่างเทอร์มินัลที่เซิร์ฟเวอร์กำลังทำงานอยู่ ในสภาพแวดล้อมการพัฒนา Rails ไม่จำเป็นต้องรีสตาร์ทเซิร์ฟเวอร์; การเปลี่ยนแปลงที่คุณทำในไฟล์จะถูกรับรู้โดยอัตโนมัติโดยเซิร์ฟเวอร์

หน้าเริ่มต้นของ Rails เป็นการทดสอบการทำงานของแอปพลิเคชัน Rails ใหม่: มันตรวจสอบให้แน่ใจว่าคุณได้กำหนดค่าซอฟต์แวร์ของคุณอย่างถูกต้องพอที่จะให้บริการหน้าเว็บ

### พูด "สวัสดี" Rails

ในการให้ Rails พูด "สวัสดี" คุณต้องสร้างอย่างน้อย *เส้นทาง* (route), *คอนโทรลเลอร์* (controller) พร้อม *แอ็คชัน* (action), และ *วิว* (view) เส้นทางจะแมปคำขอไปยังแอคชันของคอนโทรลเลอร์ แอคชันของคอนโทรลเลอร์จะดำเนินการที่จำเป็นเพื่อจัดการคำขอ และเตรียมข้อมูลสำหรับวิว วิวจะแสดงข้อมูลในรูปแบบที่ต้องการ

ในเชิงการดำเนินการ: เส้นทางเป็นกฎที่เขียนใน Ruby [DSL (Domain-Specific Language)](https://en.wikipedia.org/wiki/Domain-specific_language) คอนโทรลเลอร์เป็นคลาส Ruby และเมธอดสาธารณะของคอนโทรลเลอร์คือแอคชัน และวิวเป็นเทมเพลตที่เขียนโดยใช้ HTML และ Ruby ร่วมกัน

เรามาเริ่มต้นด้วยการเพิ่มเส้นทางลงในไฟล์เส้นทาง `config/routes.rb` ที่บล็อก `Rails.application.routes.draw` ด้านบน:

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # สำหรับรายละเอียดเกี่ยวกับ DSL ที่ใช้ในไฟล์นี้ โปรดดูที่ https://guides.rubyonrails.org/routing.html
end
```
เส้นทางด้านบนประกาศว่า `GET /articles` จะถูกแมปไปยัง `index` action ของ `ArticlesController`

เพื่อสร้าง `ArticlesController` และ `index` action เราจะใช้คำสั่ง controller generator (พร้อมกับตัวเลือก `--skip-routes` เนื่องจากเรามีเส้นทางที่เหมาะสมอยู่แล้ว):

```bash
$ bin/rails generate controller Articles index --skip-routes
```

Rails จะสร้างไฟล์หลายๆ ไฟล์ให้เรา:

```
create  app/controllers/articles_controller.rb
invoke  erb
create    app/views/articles
create    app/views/articles/index.html.erb
invoke  test_unit
create    test/controllers/articles_controller_test.rb
invoke  helper
create    app/helpers/articles_helper.rb
invoke    test_unit
```

ไฟล์ที่สำคัญที่สุดคือไฟล์ controller `app/controllers/articles_controller.rb` มาดูกัน:

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```

`index` action ว่างเปล่า ถ้า action ไม่ได้เรียกใช้งาน view โดยชัดเจน (หรือไม่ได้เรียกใช้งานการตอบสนอง HTTP ใดๆ) Rails จะทำการเรียกใช้งาน view ที่ตรงกันกับชื่อของ controller และ action โดยอัตโนมัติ ตามหลัก Convention Over Configuration! View จะอยู่ในไดเรกทอรี `app/views` ดังนั้น action `index` จะเรียกใช้งาน `app/views/articles/index.html.erb` โดยค่าเริ่มต้น

เรามาเปิด `app/views/articles/index.html.erb` และแทนที่เนื้อหาด้วย:

```html
<h1>Hello, Rails!</h1>
```

หากคุณหยุดเว็บเซิร์ฟเวอร์ก่อนที่จะเรียกใช้งาน controller generator ให้เริ่มเว็บเซิร์ฟเวอร์ใหม่ด้วย `bin/rails server` ตอนนี้เราเข้าไปที่ <http://localhost:3000/articles> และเราจะเห็นข้อความของเราที่แสดงอยู่!

### ตั้งค่าหน้าแรกของแอปพลิเคชัน

ขณะนี้ <http://localhost:3000> ยังแสดงหน้าที่มีโลโก้ของ Ruby on Rails เรามาแสดงข้อความ "Hello, Rails!" ที่ <http://localhost:3000> เช่นกัน เพื่อทำเช่นนั้น เราจะเพิ่มเส้นทางที่แมป *root path* ของแอปพลิเคชันของเราไปยัง controller และ action ที่เหมาะสม

เรามาเปิด `config/routes.rb` และเพิ่ม `root` route ต่อไปนี้ไว้ที่ด้านบนของบล็อก `Rails.application.routes.draw`:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

ตอนนี้เราสามารถเห็นข้อความ "Hello, Rails!" เมื่อเราเข้าไปที่ <http://localhost:3000> ซึ่งยืนยันว่าเส้นทาง `root` ยังถูกแมปไปยัง `index` action ของ `ArticlesController` อีกด้วย

เคล็ดลับ: หากต้องการเรียนรู้เพิ่มเติมเกี่ยวกับเส้นทาง ดูที่ [Rails Routing from the Outside In](routing.html).

Autoloading
-----------

แอปพลิเคชัน Rails **ไม่** ใช้ `require` เพื่อโหลดโค้ดของแอปพลิเคชัน

คุณอาจจะสังเกตเห็นว่า `ArticlesController` สืบทอดมาจาก `ApplicationController` แต่ `app/controllers/articles_controller.rb` ไม่มีอะไรเช่น

```ruby
require "application_controller" # อย่าทำเช่นนี้
```

คลาสและโมดูลของแอปพลิเคชันสามารถใช้งานได้ทุกที่ คุณไม่จำเป็นต้องและ **ไม่ควร** โหลดอะไรที่อยู่ใต้ `app` ด้วย `require` ฟีเจอร์นี้เรียกว่า _autoloading_ และคุณสามารถเรียนรู้เพิ่มเติมเกี่ยวกับมันได้ที่ [_Autoloading and Reloading Constants_](autoloading_and_reloading_constants.html).

คุณต้องใช้ `require` เฉพาะสำหรับสองกรณีใช้งาน:

* เพื่อโหลดไฟล์ที่อยู่ในไดเรกทอรี `lib`
* เพื่อโหลด dependency ของ gem ที่มี `require: false` ใน `Gemfile`
MVC และคุณ
-----------

จนถึงตอนนี้เราได้พูดถึงเรื่องของเส้นทาง (routes), คอนโทรลเลอร์ (controllers), แอ็กชัน (actions), และวิว (views) ทั้งหมดนี้เป็นส่วนประกอบที่ตามมาตรฐานของแอปพลิเคชันเว็บที่ใช้รูปแบบ [MVC (Model-View-Controller)](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) ซึ่งเป็นรูปแบบการออกแบบที่แบ่งหน้าที่ของแอปพลิเคชันเพื่อให้ง่ายต่อการคิดเช่นเดียวกัน รูปแบบนี้ถูกใช้ใน Rails ตามความเป็นที่

เนื่องจากเรามีคอนโทรลเลอร์และวิวที่จะทำงานร่วมกัน ให้เราสร้างส่วนถัดไป: โมเดล

### การสร้างโมเดล

*โมเดล* เป็นคลาส Ruby ที่ใช้แทนข้อมูล นอกจากนี้ โมเดลยังสามารถทำงานร่วมกับฐานข้อมูลของแอปพลิเคชันผ่านคุณสมบัติ Active Record ของ Rails

ในการกำหนดโมเดล เราจะใช้เครื่องมือสร้างโมเดลดังนี้:

```bash
$ bin/rails generate model Article title:string body:text
```

หมายเหตุ: ชื่อโมเดลจะเป็นรูปกริยาในรูปเอกพจน์ เนื่องจากโมเดลที่ถูกสร้างขึ้นแทนข้อมูลเดียว ในการจดจำกฎแนวทางนี้ คิดว่าถ้าเราต้องการเรียกใช้คอนสตรัคเตอร์ของโมเดล เราต้องเขียน `Article.new(...)` และไม่ใช่ `Articles.new(...)`

การสร้างคำสั่งดังกล่าวจะสร้างไฟล์หลายไฟล์ดังนี้:

```
invoke  active_record
create    db/migrate/<timestamp>_create_articles.rb
create    app/models/article.rb
invoke    test_unit
create      test/models/article_test.rb
create      test/fixtures/articles.yml
```

ไฟล์สองไฟล์ที่เราจะให้ความสนใจคือไฟล์ migration (`db/migrate/<timestamp>_create_articles.rb`) และไฟล์โมเดล (`app/models/article.rb`)

### การเปลี่ยนแปลงฐานข้อมูล

*การเปลี่ยนแปลงฐานข้อมูล* ใช้สำหรับเปลี่ยนโครงสร้างของฐานข้อมูลในแอปพลิเคชัน ในแอปพลิเคชัน Rails การเปลี่ยนแปลงฐานข้อมูลเขียนด้วยภาษา Ruby เพื่อให้สามารถใช้กับฐานข้อมูลที่แตกต่างกันได้

มาดูเนื้อหาในไฟล์ migration ใหม่ของเรา:

```ruby
class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

การเรียกใช้ `create_table` ระบุวิธีการสร้างตาราง `articles` โดยค่าเริ่มต้น `create_table` จะเพิ่มคอลัมน์ `id` เป็น primary key ที่เพิ่มขึ้นอัตโนมัติ ดังนั้นแถวแรกในตารางจะมี `id` เป็น 1 แถวถัดไปจะมี `id` เป็น 2 และอื่น ๆ

ภายในบล็อกสำหรับ `create_table` กำหนดคอลัมน์สองคอลัมน์คือ `title` และ `body` คอลัมน์เหล่านี้ถูกเพิ่มโดยเครื่องมือสร้างเนื่องจากเราระบุในคำสั่ง generate (`bin/rails generate model Article title:string body:text`)

บรรทัดสุดท้ายของบล็อกเป็นการเรียก `t.timestamps` เมธอดนี้กำหนดคอลัมน์เพิ่มเติมสองคอลัมน์ชื่อ `created_at` และ `updated_at` ดังที่เราจะเห็น Rails จะจัดการให้เราโดยการกำหนดค่าเมื่อเราสร้างหรืออัปเดตออบเจกต์โมเดล

ให้เราเรียกใช้การเปลี่ยนแปลงฐานข้อมูลด้วยคำสั่งต่อไปนี้:

```bash
$ bin/rails db:migrate
```

คำสั่งจะแสดงผลลัพธ์ที่แสดงว่าตารางถูกสร้างขึ้น:
```
== CreateArticles: กำลังทำการโยกย้าย ===================================
-- create_table(:articles)
   -> 0.0018s
== CreateArticles: โยกย้ายเสร็จสิ้น (0.0018s) ==========================

เคล็ดลับ: หากต้องการเรียนรู้เพิ่มเติมเกี่ยวกับการโยกย้าย โปรดดู [Active Record Migrations](
active_record_migrations.html).

ตอนนี้เราสามารถใช้โมเดลเพื่อทำงานกับตารางได้แล้ว

### การใช้โมเดลเพื่อทำงานกับฐานข้อมูล

เพื่อทดลองใช้โมเดลของเราเล็กน้อย เราจะใช้คุณสมบัติของ Rails ที่เรียกว่า *console* คอนโซลเป็นสภาพแวดล้อมการเขียนโค้ดแบบแบบป้อนเข้า คล้ายกับ `irb` แต่มันยังโหลด Rails และโค้ดแอปพลิเคชันของเราโดยอัตโนมัติ

ให้เราเริ่มคอนโซลด้วยคำสั่งนี้:

```bash
$ bin/rails console
```

คุณควรเห็นโปรโมป์ `irb` เช่น:

```irb
Loading development environment (Rails 7.0.0)
irb(main):001:0>
```

ที่โปรโมป์นี้ เราสามารถสร้างอ็อบเจ็กต์ `Article` ใหม่ได้:

```irb
irb> article = Article.new(title: "Hello Rails", body: "I am on Rails!")
```

สำคัญที่จะระบุว่าเราเพียงแค่ *เริ่มต้น* อ็อบเจ็กต์นี้เท่านั้น อ็อบเจ็กต์นี้ยังไม่ได้ถูกบันทึกลงในฐานข้อมูลเลย มันมีอยู่เฉพาะในคอนโซลเท่านั้น หากต้องการบันทึกอ็อบเจ็กต์ลงในฐานข้อมูล เราต้องเรียกใช้ [`save`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save):

```irb
irb> article.save
(0.1ms)  begin transaction
Article Create (0.4ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "Hello Rails"], ["body", "I am on Rails!"], ["created_at", "2020-01-18 23:47:30.734416"], ["updated_at", "2020-01-18 23:47:30.734416"]]
(0.9ms)  commit transaction
=> true
```

ผลลัพธ์ด้านบนแสดงคิวรีฐานข้อมูล `INSERT INTO "articles" ...` ซึ่งแสดงว่าบทความถูกแทรกลงในตารางของเราแล้ว และหากเรามองอ็อบเจ็กต์ `article` อีกครั้ง เราจะเห็นว่ามีสิ่งที่น่าสนใจเกิดขึ้น:

```irb
irb> article
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

แอตทริบิวต์ `id`, `created_at`, และ `updated_at` ของอ็อบเจ็กต์ถูกตั้งค่าแล้ว รูปแบบนี้ถูก Rails ทำให้เราเมื่อเราบันทึกอ็อบเจ็กต์

เมื่อเราต้องการเรียกดูบทความนี้จากฐานข้อมูล เราสามารถเรียกใช้ [`find`](
https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find)
บนโมเดลและส่ง `id` เป็นอาร์กิวเมนต์:

```irb
irb> Article.find(1)
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

และเมื่อเราต้องการเรียกดูบทความทั้งหมดจากฐานข้อมูล เราสามารถเรียกใช้ [`all`](
https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all)
บนโมเดลได้:

```irb
irb> Article.all
=> #<ActiveRecord::Relation [#<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">]>
```

เมธอดนี้จะส่งกลับอ็อบเจ็กต์ [`ActiveRecord::Relation`](
https://api.rubyonrails.org/classes/ActiveRecord/Relation.html) ซึ่งคุณสามารถคิดเป็นอาร์เรย์ที่มีความสามารถพิเศษได้
เคล็ดลับ: หากต้องการเรียนรู้เพิ่มเติมเกี่ยวกับโมเดล โปรดดู [Active Record Basics](
active_record_basics.html) และ [Active Record Query Interface](
active_record_querying.html).

โมเดลเป็นส่วนสุดท้ายของปริภูมิประกอบ MVC ต่อไปเราจะเชื่อมต่อส่วนทั้งหมดเข้าด้วยกัน

### แสดงรายการบทความ

ให้เรากลับไปที่คอนโทรลเลอร์ใน `app/controllers/articles_controller.rb` และเปลี่ยนการทำงานของ `index` เพื่อดึงข้อมูลบทความทั้งหมดจากฐานข้อมูล:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

ตัวแปรอินสแตนซ์ของคอนโทรลเลอร์สามารถเข้าถึงได้จากวิว นั่นหมายความว่าเราสามารถอ้างอิง `@articles` ใน `app/views/articles/index.html.erb` ได้ ให้เราเปิดไฟล์นั้นและแทนที่เนื้อหาด้วย:

```html+erb
<h1>บทความ</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

โค้ดด้านบนเป็นการผสมผสานระหว่าง HTML และ *ERB* ERB เป็นระบบเทมเพลตที่ประเมินรหัส Ruby ที่ฝังอยู่ในเอกสาร ที่นี่เราสามารถเห็นสองประเภทของแท็ก ERB: `<% %>` และ `<%= %>` แท็ก `<% %>` หมายถึง "ประเมินรหัส Ruby ที่อยู่ในแท็ก" และแท็ก `<%= %>` หมายถึง "ประเมินรหัส Ruby ที่อยู่ในแท็ก และแสดงผลค่าที่คืนกลับ" สิ่งใดก็ตามที่คุณสามารถเขียนในโปรแกรม Ruby ปกติสามารถใส่ไว้ในแท็ก ERB เหล่านี้ได้ แม้ว่าจะเป็นที่ดีที่สุดที่จะเก็บเนื้อหาของแท็ก ERB ให้สั้น เพื่อความอ่านง่าย

เนื่องจากเราไม่ต้องการแสดงผลค่าที่คืนจาก `@articles.each` เราจึงใส่รหัสนั้นใน `<% %>` แต่เนื่องจากเราต้องการแสดงผลค่าที่คืนจาก `article.title` (สำหรับแต่ละบทความ) เราจึงใส่รหัสนั้นใน `<%= %>`

เราสามารถดูผลลัพธ์สุดท้ายได้โดยเข้าชม <http://localhost:3000> (โปรดจำไว้ว่า `bin/rails server` ต้องทำงานอยู่!) นี่คือสิ่งที่เกิดขึ้นเมื่อเราทำเช่นนั้น:

1. เบราว์เซอร์ทำการร้องขอ: `GET http://localhost:3000`.
2. แอปพลิเคชัน Rails ของเราได้รับคำขอนี้
3. เราเชื่อมต่อเส้นทางของ Rails กับการทำงาน `index` ของ `ArticlesController`
4. การทำงาน `index` ใช้โมเดล `Article` เพื่อดึงบทความทั้งหมดในฐานข้อมูล
5. Rails จะแสดงผลวิว `app/views/articles/index.html.erb` อัตโนมัติ
6. รหัส ERB ในวิวจะถูกประเมินเพื่อแสดงผล HTML
7. เซิร์ฟเวอร์จะส่งการตอบกลับที่มี HTML กลับไปยังเบราว์เซอร์

เราได้เชื่อมต่อส่วนประกอบ MVC ทั้งหมดเข้าด้วยกันและเรามีการทำงานของคอนโทรลเลอร์ครั้งแรก! ต่อไปเราจะไปทำงานกับคอนโทรลเลอร์ที่สอง

CRUDit Where CRUDit Is Due
--------------------------

เกือบทุกแอปพลิเคชันเว็บเกี่ยวข้องกับการดำเนินการ CRUD (สร้าง อ่าน อัปเดต และลบ) คุณอาจพบว่างานส่วนใหญ่ที่แอปพลิเคชันของคุณทำคือ CRUD Rails รับรู้ถึงสิ่งนี้และมีคุณสมบัติหลายอย่างที่ช่วยให้การเขียนโค้ดที่ทำ CRUD ง่ายขึ้น
เราจะเริ่มการสำรวจคุณสมบัติเหล่านี้โดยการเพิ่มฟังก์ชันเพิ่มเติมให้กับแอปพลิเคชันของเรา

### แสดงบทความเดียว

ขณะนี้เรามีมุมมองที่แสดงรายการบทความทั้งหมดในฐานข้อมูลของเรา ให้เราเพิ่มมุมมองใหม่ที่แสดงชื่อและเนื้อหาของบทความเดียว

เราเริ่มต้นด้วยการเพิ่มเส้นทางใหม่ที่จะแมปไปยังการกระทำของคอนโทรลเลอร์ใหม่ (ซึ่งเราจะเพิ่มต่อไป) เปิด `config/routes.rb` และแทรกเส้นทางสุดท้ายที่แสดงด้านล่างนี้:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

เส้นทางใหม่เป็นเส้นทาง `get` อีกเส้นทางหนึ่ง แต่มีสิ่งพิเศษเพิ่มเติมในเส้นทางของมัน: `:id` สิ่งนี้กำหนดเส้นทาง *พารามิเตอร์* เส้นทางพารามิเตอร์จะจับเซกเมนต์ของเส้นทางของคำขอ และใส่ค่านั้นลงใน `params` Hash ซึ่งสามารถเข้าถึงได้โดยการกระทำของคอนโทรลเลอร์ ตัวอย่างเช่น เมื่อจัดการคำขอเช่น `GET http://localhost:3000/articles/1` `1` จะถูกจับเป็นค่าสำหรับ `:id` ซึ่งจากนั้นจะสามารถเข้าถึงได้เป็น `params[:id]` ในการกระทำ `show` ของ `ArticlesController`

เรามาเพิ่มการกระทำ `show` ตอนนี้ ด้านล่างของการกระทำ `index` ใน `app/controllers/articles_controller.rb`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

การกระทำ `show` เรียกใช้ `Article.find` ([กล่าวถึงไว้ก่อนหน้านี้](#การใช้โมเดลในการโต้ตอบกับฐานข้อมูล)) ด้วย ID ที่จับได้จากพารามิเตอร์เส้นทาง บทความที่ได้รับคืนจะถูกเก็บไว้ในตัวแปร `@article` เพื่อให้สามารถเข้าถึงได้จากมุมมอง โดยค่าเริ่มต้นการกระทำ `show` คือการแสดงผล `app/views/articles/show.html.erb`

มาสร้าง `app/views/articles/show.html.erb` ด้วยเนื้อหาดังต่อไปนี้:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

ตอนนี้เราสามารถดูบทความเมื่อเราเข้าชม <http://localhost:3000/articles/1>!

เพื่อจบการทำงาน เรามาเพิ่มวิธีที่สะดวกในการเข้าถึงหน้าของบทความ โดยเราจะเชื่อมโยงชื่อบทความแต่ละรายการใน `app/views/articles/index.html.erb` ไปยังหน้าของบทความ:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

### การกำหนดเส้นทางทรัพยากร

จนถึงตอนนี้ เราได้ครอบคลุม "R" (อ่าน) ของ CRUD แล้ว เราจะครอบคลุม "C" (สร้าง) "U" (อัปเดต) และ "D" (ลบ) ในภายหลัง ตามที่คุณอาจเดาได้ เราจะทำโดยการเพิ่มเส้นทาง การกระทำของคอนโทรลเลอร์ และมุมมองใหม่ เมื่อเรามีการรวมกันของเส้นทาง การกระทำของคอนโทรลเลอร์ และมุมมองที่ทำงานร่วมกันเพื่อดำเนินการ CRUD บนสิ่งที่เรียกว่า *ทรัพยากร* ตัวอย่างเช่น ในแอปพลิเคชันของเรา เราจะพูดถึงว่าบทความเป็นทรัพยากร

Rails มีเมธอดเส้นทางชื่อ [`resources`](
https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources) ซึ่งจะแมปเส้นทางทั้งหมดที่เป็นไปตามปกติสำหรับคอลเลกชันของทรัพยากร เช่น บทความ ดังนั้นก่อนที่เราจะไปที่ส่วน "C" "U" และ "D" เรามาแทนที่เส้นทาง `get` สองเส้นใน `config/routes.rb` ด้วย `resources`:
```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

เราสามารถตรวจสอบเส้นทางที่ถูกจับคู่ได้โดยการรันคำสั่ง `bin/rails routes`:

```bash
$ bin/rails routes
      Prefix Verb   URI Pattern                  Controller#Action
        root GET    /                            articles#index
    articles GET    /articles(.:format)          articles#index
 new_article GET    /articles/new(.:format)      articles#new
     article GET    /articles/:id(.:format)      articles#show
             POST   /articles(.:format)          articles#create
edit_article GET    /articles/:id/edit(.:format) articles#edit
             PATCH  /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
```

เมธอด `resources` ยังตั้งค่า URL และเมธอดช่วยในการเข้าถึงที่เราสามารถใช้ได้
เพื่อให้โค้ดของเราไม่ขึ้นอยู่กับการกำหนดค่าเส้นทางเฉพาะ ค่าในคอลัมน์ "Prefix"
ที่แสดงด้านบนรวมกับคำต่อท้าย `_url` หรือ `_path` จะเป็นชื่อของเมธอดช่วยเหล่านี้
ตัวอย่างเช่น เมธอดช่วย `article_path` จะคืนค่า `"/articles/#{article.id}"`
เมื่อได้รับบทความ สามารถใช้เพื่อจัดการลิงก์ใน `app/views/articles/index.html.erb`:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

อย่างไรก็ตาม เราจะทำไปอีกขั้นตอนหนึ่งโดยใช้ [`link_to`](
https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)
เมธอดช่วย  เมธอดช่วย `link_to` จะแสดงลิงก์โดยใช้อาร์กิวเมนต์แรกเป็นข้อความของลิงก์
และอาร์กิวเมนต์ที่สองเป็นปลายทางของลิงก์ หากเราส่งวัตถุโมเดลเป็นอาร์กิวเมนต์ที่สอง
`link_to` จะเรียกใช้เมธอดช่วยเส้นทางที่เหมาะสมเพื่อแปลงวัตถุเป็นเส้นทาง ตัวอย่างเช่น
หากเราส่งบทความ `link_to` จะเรียกใช้ `article_path` ดังนั้น
`app/views/articles/index.html.erb` กลายเป็น:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

ดีมาก!

เคล็ดลับ: หากต้องการเรียนรู้เพิ่มเติมเกี่ยวกับเส้นทาง ดูที่ [Rails Routing from the Outside In](
routing.html).

### สร้างบทความใหม่

ตอนนี้เราไปที่ "C" (สร้าง) ของ CRUD โดยทั่วไปในแอปพลิเคชันเว็บ
การสร้างทรัพยากรใหม่เป็นกระบวนการหลายขั้นตอน ก่อนอื่นผู้ใช้จะขอแบบฟอร์ม
เพื่อกรอกข้อมูล จากนั้นผู้ใช้จะส่งแบบฟอร์ม หากไม่มีข้อผิดพลาด
ทรัพยากรจะถูกสร้างและแสดงข้อความยืนยันใด ๆ นอกเหนือจากนี้
แบบฟอร์มจะถูกแสดงอีกครั้งพร้อมกับข้อความข้อผิดพลาด และกระบวนการจะถูกทำซ้ำ

ในแอปพลิเคชัน Rails ขั้นตอนเหล่านี้จะถูกจัดการตามความสามารถของคอนโทรลเลอร์
`new` และ `create` ของคอนโทรลเลอร์ มาเพิ่มการดำเนินการเหล่านี้ใน `app/controllers/articles_controller.rb`
ด้านล่างของการดำเนินการ `show`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```
การกระทำ `new` จะสร้างอินสแตนซ์ของบทความใหม่ แต่ไม่บันทึกไว้ บทความนี้จะถูกใช้ในมุมมองเมื่อสร้างฟอร์ม โดยค่าเริ่มต้นการกระทำ `new` จะแสดงผล `app/views/articles/new.html.erb` ซึ่งเราจะสร้างต่อไป

การกระทำ `create` จะสร้างอินสแตนซ์ของบทความใหม่พร้อมค่าสำหรับชื่อเรื่องและเนื้อหา และพยายามบันทึกไว้ หากบทความถูกบันทึกเรียบร้อยแล้ว การกระทำจะเปลี่ยนเส้นทางเบราว์เซอร์ไปยังหน้าบทความที่ `"http://localhost:3000/articles/#{@article.id}"` หากไม่สำเร็จ การกระทำจะแสดงฟอร์มอีกครั้งโดยแสดงผล `app/views/articles/new.html.erb` พร้อมรหัสสถานะ [422 Unprocessable Entity](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/422) ชื่อเรื่องและเนื้อหาที่นี่เป็นค่าเสมือน หลังจากที่เราสร้างฟอร์มเสร็จ เราจะกลับมาแก้ไขส่วนนี้

หมายเหตุ: [`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to) จะทำให้เบราว์เซอร์สร้างคำขอใหม่ ในขณะที่ [`render`](https://api.rubyonrails.org/classes/AbstractController/Rendering.html#method-i-render) จะแสดงผลมุมมองที่ระบุสำหรับคำขอปัจจุบัน สำคัญที่จะใช้ `redirect_to` หลังจากเปลี่ยนแปลงฐานข้อมูลหรือสถานะแอปพลิเคชัน มิฉะนั้น หากผู้ใช้รีเฟรชหน้าเว็บ เบราว์เซอร์จะส่งคำขอเดียวกัน และการเปลี่ยนแปลงจะถูกทำซ้ำ

#### ใช้ฟอร์มบิลเดอร์

เราจะใช้คุณสมบัติของ Rails ที่เรียกว่า *ฟอร์มบิลเดอร์* เพื่อสร้างฟอร์มของเรา โดยใช้ฟอร์มบิลเดอร์ เราสามารถเขียนโค้ดเพียงเล็กน้อยเพื่อสร้างฟอร์มที่กำหนดค่าและปฏิบัติตามความเป็นไปของ Rails

ให้สร้าง `app/views/articles/new.html.erb` ด้วยเนื้อหาดังต่อไปนี้:

```html+erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

เมธอด [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with) เป็นเมธอดช่วยในการสร้างฟอร์มบิลเดอร์ เราเรียกใช้เมธอดเช่น [`label`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-label) และ [`text_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_field) บนฟอร์มบิลเดอร์เพื่อแสดงองค์ประกอบของฟอร์มที่เหมาะสม

ผลลัพธ์ที่ได้จากการเรียกใช้ `form_with` ของเราจะมีลักษณะดังนี้:

```html
<form action="/articles" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="...">

  <div>
    <label for="article_title">Title</label><br>
    <input type="text" name="article[title]" id="article_title">
  </div>

  <div>
    <label for="article_body">Body</label><br>
    <textarea name="article[body]" id="article_body"></textarea>
  </div>

  <div>
    <input type="submit" name="commit" value="Create Article" data-disable-with="Create Article">
  </div>
</form>
```

เคล็ดลับ: หากต้องการเรียนรู้เพิ่มเติมเกี่ยวกับฟอร์มบิลเดอร์ โปรดดูที่ [Action View Form Helpers](form_helpers.html)

#### ใช้พารามิเตอร์แข็งแกร่ง

ข้อมูลฟอร์มที่ส่งมาจะถูกเก็บใน `params` Hash พร้อมกับพารามิเตอร์เส้นทางที่ถูกจับไว้ ดังนั้น การกระทำ `create` สามารถเข้าถึงชื่อเรื่องที่ส่งมาผ่าน `params[:article][:title]` และเนื้อหาที่ส่งมาผ่าน `params[:article][:body]` เราสามารถส่งค่าเหล่านี้ไปยัง `Article.new` แต่นั่นจะยาวและอาจเกิดข้อผิดพลาดได้ และมันจะเลวร้ายขึ้นเมื่อเราเพิ่มฟิลด์เพิ่มเติม

แทนนั้น เราจะส่ง Hash เดียวที่มีค่าเหล่านั้น อย่างไรก็ตาม เราต้องระบุค่าที่อนุญาตใน Hash นั้นอยู่ มิฉะนั้น ผู้ใช้ที่มีเจตนาไม่ดีอาจส่งฟอร์มเพิ่มเติมและเขียนทับข้อมูลส่วนตัว ในความเป็นจริง หากเราส่ง `params[:article]` Hash ที่ไม่ผ่านการกรองโดยตรงไปยัง `Article.new` Rails จะเรียกข้อผิดพลาด `ForbiddenAttributesError` เพื่อแจ้งเตือนเราเกี่ยวกับปัญหานี้ ดังนั้นเราจะใช้คุณสมบัติของ Rails ที่เรียกว่า *พารามิเตอร์แข็งแกร่ง* เพื่อกรอง `params` คิดเหมือนการกำหนดประเภทแข็งแกร่งสำหรับ `params`
ให้เราเพิ่มเมธอดเอกสารส่วนตัวด้านล่างใน `app/controllers/articles_controller.rb` ที่ชื่อว่า `article_params` ที่กรอง `params` และเราจะเปลี่ยน `create` เพื่อใช้เมธอดนี้:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

เคล็ดลับ: หากต้องการเรียนรู้เพิ่มเติมเกี่ยวกับ Strong Parameters โปรดดู [Action Controller Overview §
Strong Parameters](action_controller_overview.html#strong-parameters).

#### การตรวจสอบความถูกต้องและการแสดงข้อความผิดพลาด

เหมือนที่เราเห็น การสร้างทรัพยากรเป็นกระบวนการหลายขั้นตอน การจัดการข้อมูลผู้ใช้ที่ไม่ถูกต้องเป็นขั้นตอนหนึ่งของกระบวนการนั้น  Rails มีคุณสมบัติที่เรียกว่า *validations* เพื่อช่วยให้เราจัดการข้อมูลผู้ใช้ที่ไม่ถูกต้อง การตรวจสอบความถูกต้องเป็นกฎที่ตรวจสอบก่อนที่จะบันทึกออบเจ็กต์โมเดล หากการตรวจสอบใด ๆ ล้มเหลวการบันทึกจะถูกยกเลิกและข้อความผิดพลาดที่เหมาะสมจะถูกเพิ่มในแอตทริบิวต์ `errors` ของออบเจ็กต์โมเดล

ให้เราเพิ่มการตรวจสอบความถูกต้องบางอย่างในโมเดลของเราใน `app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

การตรวจสอบความถูกต้องแรกเป็นการประกาศว่าค่า `title` ต้องมีค่าที่มีอยู่ โดยเนื่องจาก `title` เป็นสตริงนั่นหมายความว่าค่า `title` ต้องมีอย่างน้อยหนึ่งอักขระที่ไม่ใช่ช่องว่าง

การตรวจสอบความถูกต้องที่สองเป็นการประกาศว่าค่า `body` ต้องมีค่าที่มีอยู่เช่นกัน นอกจากนี้ยังประกาศว่าค่า `body` ต้องมีความยาวอย่างน้อย 10 อักขระ

หมายเหตุ: คุณอาจสงสัยว่าแอตทริบิวต์ `title` และ `body` ถูกกำหนดไว้ที่ไหน Active Record กำหนดแอตทริบิวต์โมเดลสำหรับทุกคอลัมน์ของตารางโดยอัตโนมัติดังนั้นคุณไม่ต้องประกาศแอตทริบิวต์เหล่านี้ในไฟล์โมเดลของคุณ

กับการตรวจสอบความถูกต้องที่เราได้กำหนดไว้ เราจะปรับเปลี่ยน `app/views/articles/new.html.erb` เพื่อแสดงข้อความผิดพลาดสำหรับ `title` และ `body`:

```html+erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

เมธอด [`full_messages_for`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_messages_for)
จะคืนอาร์เรย์ของข้อความผิดพลาดที่เป็นมิตรกับผู้ใช้สำหรับแอตทริบิวต์ที่ระบุ หากไม่มีข้อผิดพลาดสำหรับแอตทริบิวต์นั้น อาร์เรย์จะเป็นว่างเปล่า

เพื่อให้เข้าใจว่าทุกอย่างทำงานร่วมกันอย่างไร ให้เรามองอีกครั้งที่การกระทำของคอนโทรลเลอร์ `new` และ `create`:
```ruby
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
```

เมื่อเราเข้าถึง <http://localhost:3000/articles/new> คำขอ `GET /articles/new` จะถูกแมปไปยังแอ็กชัน `new` แอ็กชัน `new` ไม่พยายามบันทึก `@article` ดังนั้นการตรวจสอบความถูกต้องจะไม่ถูกตรวจสอบและจะไม่มีข้อความข้อผิดพลาด

เมื่อเราส่งแบบฟอร์ม คำขอ `POST /articles` จะถูกแมปไปยังแอ็กชัน `create` แอ็กชัน `create` *พยายาม* บันทึก `@article` ดังนั้นการตรวจสอบความถูกต้อง *ถูกตรวจสอบ* หากการตรวจสอบความถูกต้องล้มเหลว `@article` จะไม่ถูกบันทึกและ `app/views/articles/new.html.erb` จะถูกแสดงพร้อมกับข้อความข้อผิดพลาด

เคล็ดลับ: หากต้องการเรียนรู้เพิ่มเติมเกี่ยวกับการตรวจสอบความถูกต้อง ดูที่ [Active Record Validations](active_record_validations.html) หากต้องการเรียนรู้เพิ่มเติมเกี่ยวกับข้อความข้อผิดพลาดจากการตรวจสอบความถูกต้อง ดูที่ [Active Record Validations § การทำงานกับข้อผิดพลาดจากการตรวจสอบความถูกต้อง](active_record_validations.html#working-with-validation-errors)

#### การเสร็จสิ้น

เราสามารถสร้างบทความได้โดยเข้าถึง <http://localhost:3000/articles/new> เพื่อเสร็จสิ้น เราจะเชื่อมโยงไปยังหน้านั้นจากด้านล่างของ `app/views/articles/index.html.erb`:

```html+erb
<h1>บทความ</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "บทความใหม่", new_article_path %>
```

### การอัปเดตบทความ

เราได้พูดถึง "CR" ของ CRUD แล้ว ตอนนี้เรามาเรียนรู้เกี่ยวกับ "U" (อัปเดต) การอัปเดตทรัพยากรคล้ายกับการสร้างทรัพยากร ทั้งคู่เป็นกระบวนการหลายขั้นตอน ก่อนอื่นผู้ใช้จะขอแบบฟอร์มเพื่อแก้ไขข้อมูล จากนั้นผู้ใช้จะส่งแบบฟอร์ม หากไม่มีข้อผิดพลาด ทรัพยากรจะถูกอัปเดต มิฉะนั้น แบบฟอร์มจะถูกแสดงอีกครั้งพร้อมกับข้อความข้อผิดพลาดและกระบวนการจะถูกทำซ้ำ

ขั้นตอนเหล่านี้ถูกจัดการโดยแอ็กชัน `edit` และ `update` ของคอนโทรลเลอร์ตามปกติ มาเพิ่มการดำเนินการทั่วไปของแอ็กชันเหล่านี้ใน `app/controllers/articles_controller.rb` ด้านล่างของแอ็กชัน `create`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

สังเกตว่าแอ็กชัน `edit` และ `update` คล้ายกับแอ็กชัน `new` และ `create`

แอ็กชัน `edit` ดึงบทความจากฐานข้อมูลและเก็บไว้ใน `@article` เพื่อใช้ในการสร้างแบบฟอร์ม โดยค่าเริ่มต้นแอ็กชัน `edit` จะแสดง `app/views/articles/edit.html.erb`

แอ็กชัน `update` ดึงบทความจากฐานข้อมูลอีกครั้งและพยายามอัปเดตด้วยข้อมูลแบบฟอร์มที่ส่งมาผ่าน `article_params` หากไม่มีการตรวจสอบความถูกต้องล้มเหลวและการอัปเดตสำเร็จแอ็กชันจะเปลี่ยนเส้นทางเบราว์เซอร์ไปยังหน้าบทความ มิฉะนั้นแอ็กชันจะแสดงแบบฟอร์มอีกครั้งพร้อมกับข้อความข้อผิดพลาด โดยการแสดง `app/views/articles/edit.html.erb`
#### การใช้ Partial เพื่อแบ่งปันโค้ดของ View

ฟอร์ม `edit` ของเราจะมีลักษณะเดียวกับฟอร์ม `new` ของเรา และโค้ดก็จะเหมือนกันเนื่องจากมี Rails form builder และ resourceful routing ช่วยให้โค้ดเหมือนกัน ฟอร์มบิลเดอร์จะกำหนดค่าฟอร์มให้เหมาะสมตามการร้องขอประเภทที่เหมาะสม ขึ้นอยู่กับว่าวัตถุโมเดลได้ถูกบันทึกไว้ก่อนหน้านี้หรือไม่

เนื่องจากโค้ดจะเหมือนกัน เราจะแยกออกเป็นส่วนย่อยที่เรียกว่า *partial* มาเก็บไว้ใน view ที่แชร์กัน โดยสร้างไฟล์ `app/views/articles/_form.html.erb` ด้วยเนื้อหาดังต่อไปนี้:

```html+erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

โค้ดข้างต้นเหมือนกับฟอร์มใน `app/views/articles/new.html.erb` เพียงแต่ทุกครั้งที่พบ `@article` ถูกแทนที่ด้วย `article` โดย partial เป็นโค้ดที่แชร์กัน ดังนั้น สิ่งที่เป็นที่นิยมคือ partial ไม่ควรขึ้นอยู่กับตัวแปรอินสแตนซ์ที่ถูกกำหนดโดย controller action เราจะส่ง article เข้าไปใน partial เป็นตัวแปร local

ให้เราอัปเดต `app/views/articles/new.html.erb` เพื่อใช้ partial ผ่าน [`render`](
https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render):

```html+erb
<h1>บทความใหม่</h1>

<%= render "form", article: @article %>
```

หมายเหตุ: ชื่อไฟล์ของ partial ต้องมีเครื่องหมายขีดล่าง **นำหน้า**, เช่น `_form.html.erb` แต่เมื่อเรียกใช้ จะไม่ต้องใส่เครื่องหมายขีดล่าง เช่น `render "form"`

และตอนนี้ เราจะสร้าง `app/views/articles/edit.html.erb` ที่คล้ายกันมาก:

```html+erb
<h1>แก้ไขบทความ</h1>

<%= render "form", article: @article %>
```

เคล็ดลับ: หากต้องการเรียนรู้เพิ่มเติมเกี่ยวกับ partial ดูที่ [Layouts and Rendering in Rails § Using
Partials](layouts_and_rendering.html#using-partials).

#### การจบงาน

เราสามารถอัปเดตบทความได้โดยเข้าไปที่หน้าแก้ไข ตัวอย่างเช่น
<http://localhost:3000/articles/1/edit> เพื่อจบงาน เราจะเพิ่มลิงก์ไปยังหน้าแก้ไขจากด้านล่างของ `app/views/articles/show.html.erb`:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "แก้ไข", edit_article_path(@article) %></li>
</ul>
```

### การลบบทความ

สุดท้าย เรามาถึง "D" (Delete) ของ CRUD การลบทรัพยากรง่ายกว่าการสร้างหรืออัปเดต มันต้องการเพียงเส้นทางเดียวกับการร้องขอและการกระทำของคอนโทรลเลอร์ และ resourceful routing (`resources :articles`) ที่เรามีอยู่แล้วจะให้เส้นทาง ซึ่งจะแมปการร้องขอ `DELETE /articles/:id` ไปยังการกระทำ `destroy` ของ `ArticlesController`

ดังนั้น เราจะเพิ่มการกระทำ `destroy` ทั่วไปใน `app/controllers/articles_controller.rb` ด้านล่างของการกระทำ `update`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```
การกระทำ `destroy` จะดึงบทความจากฐานข้อมูลและเรียกใช้ [`destroy`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy)
บนมัน จากนั้นจะเปลี่ยนเส้นทางของเบราว์เซอร์ไปยังเส้นทางหลักด้วยรหัสสถานะ
[303 See Other](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/303).

เราได้เลือกเปลี่ยนเส้นทางไปยังเส้นทางหลักเนื่องจากเป็นจุดเข้าถึงหลักของบทความของเรา แต่ในสถานการณ์อื่น ๆ คุณอาจเลือกเปลี่ยนเส้นทางไปยังเช่น `articles_path` เป็นต้น

ตอนนี้เรามาเพิ่มลิงก์ที่ด้านล่างของ `app/views/articles/show.html.erb` เพื่อให้เราสามารถลบบทความจากหน้าของตัวเองได้:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>
```

ในโค้ดด้านบน เราใช้ตัวเลือก `data` เพื่อตั้งค่าแอตทริบิวต์ HTML `data-turbo-method` และ `data-turbo-confirm` ของลิงก์ "Destroy" ทั้งสองแอตทริบิวต์นี้เชื่อมต่อกับ [Turbo](https://turbo.hotwired.dev/) ซึ่งรวมอยู่ในแอปพลิเคชัน Rails ใหม่ๆ โดยค่าเริ่มต้น `data-turbo-method="delete"` จะทำให้ลิงก์ทำการร้องขอ `DELETE` แทนที่จะร้องขอ `GET` `data-turbo-confirm="Are you sure?"` จะทำให้ปรากฏกล่องโต้ตอบการยืนยันเมื่อคลิกลิงก์ หากผู้ใช้ยกเลิกกล่องโต้ตอบ การร้องขอจะถูกยกเลิก

และนั่นคือทั้งหมด! เราสามารถรายการบทความ แสดงรายละเอียดบทความ สร้าง แก้ไข และลบบทความได้แล้ว! InCRUDable!

การเพิ่มโมเดลที่สอง
---------------------

ถึงเวลาที่จะเพิ่มโมเดลที่สองในแอปพลิเคชัน เป็นโมเดลที่สองที่จะจัดการความคิดเห็นในบทความ

### การสร้างโมเดล

เราจะใช้เจเนอเรเตอร์เดียวกับที่เราใช้ก่อนหน้านี้เมื่อสร้างโมเดล `Article` ครั้งนี้เราจะสร้างโมเดล `Comment` เพื่อเก็บอ้างอิงไปยังบทความ ให้รันคำสั่งนี้ในเทอร์มินัลของคุณ:

```bash
$ bin/rails generate model Comment commenter:string body:text article:references
```

คำสั่งนี้จะสร้างไฟล์สี่ไฟล์:

| ไฟล์                                         | วัตถุประสงค์                                                                                                |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| db/migrate/20140120201010_create_comments.rb | การโยกย้ายเพื่อสร้างตารางความคิดเห็นในฐานข้อมูลของคุณ (ชื่อของคุณจะรวมไปถึงการปรับเปลี่ยนเวลาที่แตกต่างกัน) |
| app/models/comment.rb                        | โมเดล Comment                                                                                      |
| test/models/comment_test.rb                  | เครื่องมือทดสอบสำหรับโมเดล Comment                                                                 |
| test/fixtures/comments.yml                   | ความคิดเห็นตัวอย่างสำหรับใช้ในการทดสอบ                                                                     |

ก่อนอื่น ลองดูที่ `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

นี่คือคลาสโมเดล Comment ที่คล้ายกับโมเดล Article ที่คุณเห็นก่อนหน้านี้ ความแตกต่างคือบรรทัด `belongs_to :article` ซึ่งกำหนดการสร้าง _association_ ของ Active Record คุณจะเรียนรู้เล็กน้อยเกี่ยวกับการสร้าง _association_ ในส่วนถัดไปของเอกสารนี้

คำสำคัญ (`:references`) ที่ใช้ในคำสั่งเชลนี้เป็นชนิดข้อมูลพิเศษสำหรับโมเดล
มันจะสร้างคอลัมน์ใหม่ในตารางฐานข้อมูลของคุณที่มีชื่อโมเดลที่ให้มาต่อท้ายด้วย `_id`
ซึ่งสามารถเก็บค่าจำนวนเต็มได้ เพื่อให้เข้าใจได้ดีขึ้น วิเคราะห์ไฟล์ `db/schema.rb` หลังจากเรียกใช้การโยกย้าย
นอกจากโมเดลแล้ว Rails ยังสร้างการเคลื่อนย้ายเพื่อสร้างตารางฐานข้อมูลที่เกี่ยวข้อง:

```ruby
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

บรรทัด `t.references` สร้างคอลัมน์ชนิด integer ที่ชื่อ `article_id` พร้อมดัชนีและข้อจำกัดความสัมพันธ์ที่ชี้ไปที่คอลัมน์ `id` ของตาราง `articles` ลองรันการเคลื่อนย้าย:

```bash
$ bin/rails db:migrate
```

Rails มีความสามารถในการเรียกใช้เฉพาะการเคลื่อนย้ายที่ยังไม่ได้รันกับฐานข้อมูลปัจจุบัน ดังนั้นในกรณีนี้คุณจะเห็นเพียง:

```
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```

### การเชื่อมโยงโมเดล

การเชื่อมโยง Active Record ช่วยให้คุณสามารถประกาศความสัมพันธ์ระหว่างโมเดลสองตัวได้ง่ายดาย ในกรณีของความคิดเห็นและบทความ คุณสามารถเขียนความสัมพันธ์ได้ดังนี้:

* แต่ละความคิดเห็นเป็นส่วนหนึ่งของบทความหนึ่ง
* บทความหนึ่งสามารถมีความคิดเห็นได้หลายอัน

ในความเป็นจริงนี้เป็นรูปแบบที่ใกล้เคียงกับไวยากรณ์ที่ Rails ใช้ในการประกาศความสัมพันธ์นี้ คุณเคยเห็นบรรทัดโค้ดภายในโมเดล `Comment` (app/models/comment.rb) ที่ทำให้แต่ละความคิดเห็นเป็นส่วนหนึ่งของบทความ:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

คุณจะต้องแก้ไข `app/models/article.rb` เพื่อเพิ่มส่วนอื่น ๆ ของความสัมพันธ์:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

การประกาศสองส่วนนี้ช่วยให้มีพฤติกรรมอัตโนมัติได้มากมาย ตัวอย่างเช่นหากคุณมีตัวแปรอินสแตนซ์ `@article` ที่มีบทความ คุณสามารถเรียกดูความคิดเห็นทั้งหมดที่เกี่ยวข้องกับบทความนั้นในรูปแบบอาร์เรย์ได้โดยใช้ `@article.comments`.

เคล็ดลับ: สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการเชื่อมโยง Active Record ดูที่ [Active Record
Associations](association_basics.html) guide.

### เพิ่มเส้นทางสำหรับความคิดเห็น

เช่นเดียวกับควบคุมเรื่อง `articles` เราจะต้องเพิ่มเส้นทางเพื่อให้ Rails ทราบว่าเราต้องการไปยังไหนเพื่อดู `comments` เปิดไฟล์ `config/routes.rb` อีกครั้งและแก้ไขดังนี้:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

สร้าง `comments` เป็น _nested resource_ ภายใน `articles` นี้เป็นส่วนหนึ่งของการจับคู่ความสัมพันธ์ที่มีลำดับที่อยู่ระหว่างบทความและความคิดเห็น

เคล็ดลับ: สำหรับข้อมูลเพิ่มเติมเกี่ยวกับการเชื่อมต่อดูที่ [Rails Routing](routing.html)
guide.

### การสร้างควบคุมเลเยอร์

ด้วยโมเดลที่มีอยู่แล้วคุณสามารถสร้างควบคุมเลเยอร์ที่เข้ากันได้ อีกครั้งเราจะใช้เครื่องมือเดียวกันที่เราใช้ก่อนหน้านี้:
```bash
$ bin/rails generate controller Comments
```

นี้จะสร้างไฟล์สามไฟล์และไดเรกทอรีว่างเปล่าหนึ่ง:

| ไฟล์/ไดเรกทอรี                               | วัตถุประสงค์                                  |
| -------------------------------------------- | ---------------------------------------- |
| app/controllers/comments_controller.rb       | Comments controller                  |
| app/views/comments/                          | จัดเก็บวิวของคอนโทรลเลอร์ที่นี่  |
| test/controllers/comments_controller_test.rb | ทดสอบคอนโทรลเลอร์              |
| app/helpers/comments_helper.rb               | ไฟล์ช่วยเหลือในการแสดงผล                       |

เช่นเดียวกับบล็อกใด ๆ ผู้อ่านของเราจะสร้างความคิดเห็นของตนโดยตรงหลังจากอ่านบทความและเมื่อเพิ่มความคิดเห็นของตนแล้วจะถูกส่งกลับไปที่หน้าแสดงบทความเพื่อดูความคิดเห็นของตนที่รายการแล้ว ด้วยเหตุนี้ `CommentsController` ของเราจึงมีการให้บริการเพื่อสร้างความคิดเห็นและลบความคิดเห็นสแปมเมื่อมันมาถึง

ดังนั้นก่อนอื่นเราจะเชื่อมต่อเทมเพลตแสดงบทความ (`app/views/articles/show.html.erb`) เพื่อให้เราสามารถสร้างความคิดเห็นใหม่ได้:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "แก้ไข", edit_article_path(@article) %></li>
  <li><%= link_to "ลบ", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "แน่ใจหรือไม่?"
                  } %></li>
</ul>

<h2>เพิ่มความคิดเห็น:(3)</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

นี้เพิ่มฟอร์มในหน้าแสดง `Article` ที่สร้างความคิดเห็นใหม่โดยเรียกใช้การกระทำ `create` ของ `CommentsController` การเรียกใช้ `form_with` ที่นี่ใช้อาร์เรย์ซึ่งจะสร้างเส้นทางที่ซ้อนกัน เช่น `/articles/1/comments`

มาเชื่อมต่อ `create` ใน `app/controllers/comments_controller.rb`:

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

คุณจะเห็นความซับซ้อนเล็กน้อยที่นี่มากกว่าที่คุณเห็นในคอนโทรลเลอร์สำหรับบทความ นั่นเป็นผลข้างเคียงของการซ้อนที่คุณได้ตั้งค่า แต่ละคำขอสำหรับความคิดเห็นต้องติดตามบทความที่ความคิดเห็นแนบอยู่ ดังนั้นการเรียกใช้เมธอด `find` ของโมเดล `Article` เพื่อรับบทความที่สงสัย

นอกจากนี้โค้ดยังใช้ประโยชน์จากเมธอดบางอย่างที่มีอยู่สำหรับความสัมพันธ์ เราใช้เมธอด `create` บน `@article.comments` เพื่อสร้างและบันทึกความคิดเห็น นี้จะเชื่อมโยงความคิดเห็นโดยอัตโนมัติเพื่อให้เป็นส่วนหนึ่งของบทความนั้น

เมื่อเราทำความคิดเห็นใหม่แล้วเราจะส่งผู้ใช้กลับไปที่บทความเดิมโดยใช้ตัวช่วย `article_path(@article)` เหมือนที่เราเคยเห็น นี้เรียกใช้การกระทำ `show` ของ `ArticlesController` ซึ่งในเทมเพลต `show.html.erb` จะแสดงความคิดเห็น ดังนั้นเราจะเพิ่มส่วนนั้นใน `app/views/articles/show.html.erb`
```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "แก้ไข", edit_article_path(@article) %></li>
  <li><%= link_to "ลบ", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "คุณแน่ใจหรือไม่?"
                  } %></li>
</ul>

<h2>ความคิดเห็น1</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>ผู้แสดงความคิดเห็น:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>ความคิดเห็น:</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>เพิ่มความคิดเห็น:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

ตอนนี้คุณสามารถเพิ่มบทความและความคิดเห็นในบล็อกของคุณและมีการแสดงผลในตำแหน่งที่ถูกต้อง

![บทความพร้อมความคิดเห็น](images/getting_started/article_with_comments.png)

การรวมรูปแบบ
-----------

ตอนนี้ที่เรามีบทความและความคิดเห็นทำงานอยู่แล้ว ลองดูที่เทมเพลต `app/views/articles/show.html.erb` มันยาวและยุ่งเหยิง พวกเราสามารถใช้ partials เพื่อทำความสะอาด

### การแสดงรวมของ Partial

ก่อนอื่น เราจะสร้าง partial สำหรับแสดงความคิดเห็นทั้งหมดในบทความ สร้างไฟล์ `app/views/comments/_comment.html.erb` และใส่โค้ดต่อไปนี้ลงไป:

```html+erb
<p>
  <strong>ผู้แสดงความคิดเห็น:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>ความคิดเห็น:</strong>
  <%= comment.body %>
</p>
```

จากนั้นคุณสามารถเปลี่ยน `app/views/articles/show.html.erb` เป็นดังนี้:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "แก้ไข", edit_article_path(@article) %></li>
  <li><%= link_to "ลบ", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "คุณแน่ใจหรือไม่?"
                  } %></li>
</ul>

<h2>ความคิดเห็น3</h2>
<%= render @article.comments %>

<h2>เพิ่มความคิดเห็น:(1)</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

ตอนนี้มันจะแสดง partial ใน `app/views/comments/_comment.html.erb` สำหรับแต่ละความคิดเห็นที่อยู่ในคอลเลกชัน `@article.comments` โดยเมื่อเรียกใช้เมธอด `render` จะทำการวนซ้ำผ่านคอลเลกชัน `@article.comments` และกำหนดค่าแต่ละความคิดเห็นให้เป็นตัวแปรโลคอลชื่อเดียวกับ partial ในที่นี้คือ `comment` ซึ่งจะสามารถใช้ใน partial เพื่อแสดงผลได้

### การแสดงฟอร์ม Partial

เรายังสามารถย้ายส่วนของการเพิ่มความคิดเห็นใหม่ไปยัง partial ของตัวเองได้อีกด้วย อีกครั้ง คุณสร้างไฟล์ `app/views/comments/_form.html.erb` ที่มีโค้ดต่อไปนี้:

```html+erb
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

จากนั้นคุณทำให้ `app/views/articles/show.html.erb` ดูเหมือนนี้:
```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "แก้ไข", edit_article_path(@article) %></li>
  <li><%= link_to "ลบ", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "คุณแน่ใจหรือไม่?"
                  } %></li>
</ul>

<h2>ความคิดเห็น2</h2>
<%= render @article.comments %>

<h2>เพิ่มความคิดเห็น:(2)</h2>
<%= render 'comments/form' %>
```

การ render ครั้งที่สองเพียงกำหนด template ย่อยที่เราต้องการ render คือ `comments/form` ระบบ Rails จะสามารถรู้ว่าเราต้องการ render ไฟล์ `_form.html.erb` ในโฟลเดอร์ `app/views/comments` ได้เอง

ออบเจ็กต์ `@article` สามารถใช้งานได้ใน partials ที่ render ใน view ได้เนื่องจากเรากำหนดให้เป็นตัวแปรอินสแตนซ์

### การใช้ Concerns

Concerns เป็นวิธีที่ช่วยให้การจัดการและเข้าใจความหมายของ controller หรือ model ที่ใหญ่มากขึ้น นอกจากนี้ยังมีประโยชน์ในเรื่องการ reuse เมื่อมีการใช้งานของ model (หรือ controller) หลายๆ ตัวที่มี concerns เหมือนกัน การใช้งาน concerns จะใช้ module เหมือนกับการใช้งาน module ในภาษาอื่นๆ โดย module จะมี method ที่แสดงถึงฟังก์ชันที่กำหนดไว้ใน model หรือ controller ที่รับผิดชอบในส่วนที่กำหนดไว้ ในภาษาอื่นๆ โมดูลมักจะเรียกว่า mixins

คุณสามารถใช้ concerns ใน controller หรือ model ได้เหมือนกับการใช้งาน module ใดๆ ก่อนหน้านี้เมื่อคุณสร้างแอปพลิเคชันครั้งแรกด้วยคำสั่ง `rails new blog` โฟลเดอร์สองโฟลเดอร์ที่สร้างขึ้นใน `app/` คือ:

```
app/controllers/concerns
app/models/concerns
```

ในตัวอย่างด้านล่าง เราจะนำเสนอฟีเจอร์ใหม่สำหรับบล็อกของเราที่จะได้รับประโยชน์จากการใช้งาน concerns จากนั้นเราจะสร้าง concerns และ refactor โค้ดให้ใช้งาน concerns เพื่อทำให้โค้ดสั้นลงและง่ายต่อการบำรุงรักษา

บทความบล็อกอาจมีสถานะต่างๆ เช่น อาจเป็นสถานะที่มองเห็นได้ทุกคน (เช่น `public`) หรือเป็นสถานะที่มองเห็นได้เฉพาะผู้เขียน (เช่น `private`) หรืออาจถูกซ่อนไม่ให้มองเห็น (เช่น `archived`) ความคิดเห็นอาจมีลักษณะเดียวกันเช่นกัน ซึ่งสามารถแสดงได้โดยใช้คอลัมน์ `status` ในแต่ละโมเดล

ก่อนอื่น เราจะรัน migration ต่อไปนี้เพื่อเพิ่ม `status` ใน `Articles` และ `Comments`:

```bash
$ bin/rails generate migration AddStatusToArticles status:string
$ bin/rails generate migration AddStatusToComments status:string
```

และต่อมา เราจะอัปเดตฐานข้อมูลด้วย migration ที่สร้างขึ้น:

```bash
$ bin/rails db:migrate
```

ในการเลือกสถานะสำหรับบทความและความคิดเห็นที่มีอยู่ คุณสามารถเพิ่มค่าเริ่มต้นให้กับไฟล์ migration ที่สร้างขึ้นโดยเพิ่ม `default: "public"` และรัน migration อีกครั้ง คุณยังสามารถเรียกใช้ `Article.update_all(status: "public")` และ `Comment.update_all(status: "public")` ในระหว่างการทำงานใน rails console ได้

เคล็ดลับ: หากต้องการเรียนรู้เพิ่มเติมเกี่ยวกับ migrations โปรดดูที่ [Active Record Migrations](
active_record_migrations.html).
```
เรายังต้องอนุญาตให้คีย์ `:status` เป็นส่วนหนึ่งของพารามิเตอร์ที่เข้มงวดใน `app/controllers/articles_controller.rb`:

```ruby

  private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
```

และใน `app/controllers/comments_controller.rb`:

```ruby

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

ภายในโมเดล `article` หลังจากเรียกใช้การโยกย้ายเพื่อเพิ่มคอลัมน์ `status` โดยใช้คำสั่ง `bin/rails db:migrate` คุณจะเพิ่ม:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

และในโมเดล `Comment`:

```ruby
class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

จากนั้นในแม่แบบการกระทำ `index` (`app/views/articles/index.html.erb`) เราจะใช้เมธอด `archived?` เพื่อหลีกเลี่ยงการแสดงบทความที่ถูกเก็บถาวร:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

ในทางเดียวกัน ในมุมมองส่วนหนึ่งของความคิด (`app/views/comments/_comment.html.erb`) เราจะใช้เมธอด `archived?` เพื่อหลีกเลี่ยงการแสดงความคิดเห็นที่ถูกเก็บถาวร:

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>
```

อย่างไรก็ตาม หากคุณมองอีกครั้งที่โมเดลของเราตอนนี้ คุณจะเห็นว่าตรรกะซ้ำกัน หากในอนาคตเราเพิ่มฟังก์ชันการทำงานของบล็อกของเรา - เช่นการรวมข้อความส่วนตัว - เราอาจพบว่าตรรกะซ้ำกันอีกครั้ง นี่คือสิ่งที่ความกังวลมาช่วยเรา

ความกังวลเป็นเพียงความรับผิดชอบเฉพาะสำหรับส่วนย่อยที่เกี่ยวข้องกับความสามารถในการมองเห็นของโมเดล ให้เราเรียกความกังวลใหม่ของเรา (โมดูล) `Visible` เราสามารถสร้างไฟล์ใหม่ภายใน `app/models/concerns` ที่เรียกว่า `visible.rb` และเก็บเมธอดทั้งหมดที่เกี่ยวข้องกับสถานะที่ซ้ำกันในโมเดล

`app/models/concerns/visible.rb`

```ruby
module Visible
  def archived?
    status == 'archived'
  end
end
```

เราสามารถเพิ่มการตรวจสอบสถานะในความกังวล แต่นี้จะซับซ้อนขึ้นเล็กน้อยเนื่องจากการตรวจสอบคือเมธอดที่เรียกใช้ในระดับคลาส  `ActiveSupport::Concern` ([API Guide](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)) ให้เราวิธีที่ง่ายกว่าในการรวมมัน:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  def archived?
    status == 'archived'
  end
end
```
ตอนนี้เราสามารถลบโลจิกที่ซ้ำกันออกจากแต่ละโมเดลและแทนที่ด้วยโมดูล `Visible` ใหม่ของเราได้:


ใน `app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

และใน `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  include Visible

  belongs_to :article
end
```

เมธอดคลาสก็สามารถเพิ่มในความสนใจได้ หากเราต้องการแสดงจำนวนบทความหรือความคิดเห็นสาธารณะบนหน้าหลักของเรา เราอาจเพิ่มเมธอดคลาสไปยัง `Visible` ดังนี้:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      where(status: 'public').count
    end
  end

  def archived?
    status == 'archived'
  end
end
```

จากนั้นในมุมมอง เราสามารถเรียกใช้ได้เหมือนเมธอดคลาสอื่น ๆ:

```html+erb
<h1>บทความ</h1>

บล็อกของเรามีบทความ <%= Article.public_count %> บทความและกำลังเพิ่มขึ้น!

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "บทความใหม่", new_article_path %>
```

เพื่อจบการทำงาน เราจะเพิ่มกล่องเลือกในฟอร์มและให้ผู้ใช้เลือกสถานะเมื่อสร้างบทความใหม่หรือโพสต์ความคิดเห็นใหม่ เรายังสามารถระบุสถานะเริ่มต้นเป็น `public` ได้ด้วย ใน `app/views/articles/_form.html.erb` เราสามารถเพิ่มได้:

```html+erb
<div>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</div>
```

และใน `app/views/comments/_form.html.erb`:

```html+erb
<p>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</p>
```

การลบความคิดเห็น
-----------------

คุณลักษณะอีกอย่างที่สำคัญของบล็อกคือการลบความคิดเห็นสแปม ในการทำ
นี้ เราต้องการสร้างลิงก์ในมุมมองและการกระทำ `destroy` ใน `CommentsController`


ดังนั้นก่อนอื่น เราจะเพิ่มลิงก์ลบในส่วน `app/views/comments/_comment.html.erb`:

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>ผู้แสดงความคิดเห็น:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>ความคิดเห็น:</strong>
    <%= comment.body %>
  </p>

  <p>
    <%= link_to "ลบความคิดเห็น", [comment.article, comment], data: {
                  turbo_method: :delete,
                  turbo_confirm: "แน่ใจหรือไม่?"
                } %>
  </p>
<% end %>
```

การคลิกลิงก์ "ลบความคิดเห็น" ใหม่นี้จะเรียกใช้ `DELETE
/articles/:article_id/comments/:id` ไปยัง `CommentsController` ของเรา ซึ่งจะใช้สิ่งนี้ในการค้นหาความคิดเห็นที่เราต้องการลบ ดังนั้นเราจะเพิ่มการกระทำ `destroy` ในคอนโทรลเลอร์ (`app/controllers/comments_controller.rb`):

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), status: :see_other
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
end
```
การกระทำ `destroy` จะค้นหาบทความที่เรากำลังมองหา และค้นหาความคิดเห็นภายในคอลเลกชัน `@article.comments` จากนั้นจึงลบออกจากฐานข้อมูลและส่งกลับไปที่การกระทำ show สำหรับบทความ

### การลบวัตถุที่เกี่ยวข้อง

หากคุณลบบทความ ความคิดเห็นที่เกี่ยวข้องก็จะต้องถูกลบด้วย มิฉะนั้นมันจะเพียงแค่ใช้พื้นที่ในฐานข้อมูล  Rails ช่วยให้คุณสามารถใช้ตัวเลือก `dependent` ของการเชื่อมโยงเพื่อทำสิ่งนี้ได้ แก้ไขโมเดล Article `app/models/article.rb` ดังนี้:

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

ความปลอดภัย
--------

### การรับรองความถูกต้องขั้นพื้นฐาน

หากคุณต้องการเผยแพร่บล็อกของคุณออนไลน์ ใครก็สามารถเพิ่ม แก้ไข และลบบทความหรือลบความคิดเห็นได้

Rails มีระบบการรับรองความถูกต้องขั้นพื้นฐานที่จะทำงานได้ดีในสถานการณ์นี้

ใน `ArticlesController` เราต้องมีวิธีการบล็อกการเข้าถึงการกระทำต่าง ๆ หากบุคคลไม่ได้รับการรับรองความถูกต้อง ที่นี่เราสามารถใช้วิธี `http_basic_authenticate_with` ของ Rails ซึ่งอนุญาตให้เข้าถึงการกระทำที่ร้องขอได้หากวิธีนั้นอนุญาตให้เข้าถึง

ในการใช้ระบบการรับรองความถูกต้อง เราระบุให้มันที่ด้านบนของ `ArticlesController` ใน `app/controllers/articles_controller.rb` ในกรณีของเรา เราต้องการให้ผู้ใช้รับรองความถูกต้องในทุก ๆ การกระทำยกเว้น `index` และ `show` เราเขียนดังนี้:

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # โค้ดส่วนที่เหลือเพื่อความกระชับ
```

เรายังต้องการให้เฉพาะผู้ใช้ที่รับรองความถูกต้องเท่านั้นที่สามารถลบความคิดเห็นได้ ดังนั้นใน `CommentsController` (`app/controllers/comments_controller.rb`) เราเขียนดังนี้:

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # โค้ดส่วนที่เหลือเพื่อความกระชับ
```

ตอนนี้หากคุณพยายามสร้างบทความใหม่ คุณจะได้รับการทดสอบการรับรองความถูกต้อง HTTP พื้นฐาน:

![Basic HTTP Authentication Challenge](images/getting_started/challenge.png)

หลังจากใส่ชื่อผู้ใช้และรหัสผ่านที่ถูกต้อง คุณจะยังคงได้รับการรับรองความถูกต้องจนกว่าจะต้องการชื่อผู้ใช้และรหัสผ่านที่แตกต่างหรือปิดเบราว์เซอร์

วิธีการรับรองความถูกต้องอื่น ๆ สามารถใช้ได้สำหรับแอปพลิเคชัน Rails มีเครื่องมือรับรองความถูกต้องสองตัวที่นิยมคือ
[Devise](https://github.com/plataformatec/devise) และ
[Authlogic](https://github.com/binarylogic/authlogic) รวมถึงอื่น ๆ อีกหลายตัว

### ข้อคิดอื่น ๆ เกี่ยวกับความปลอดภัย

ความปลอดภัย โดยเฉพาะในแอปพลิเคชันเว็บ เป็นเรื่องที่กว้างขวางและละเอียดอ่อน ความปลอดภัยในแอปพลิเคชัน Rails ของคุณจะถูกครอบคลุมอย่างละเอียดมากขึ้นใน
[คู่มือความปลอดภัยของ Ruby on Rails](security.html)
สิ่งที่ต่อไป?
------------

ตอนนี้ที่คุณได้เห็นแอปพลิเคชัน Rails ครั้งแรกของคุณแล้ว คุณสามารถอัปเดตและทดลองด้วยตัวเองได้เลย

อย่าลืมว่าคุณไม่ต้องทำทุกอย่างด้วยตัวเอง หากคุณต้องการความช่วยเหลือในการเริ่มต้นและใช้งาน Rails คุณสามารถเรียกดูทรัพยากรการสนับสนุนเหล่านี้ได้:

* [Ruby on Rails Guides](index.html)
* [Ruby on Rails mailing list](https://discuss.rubyonrails.org/c/rubyonrails-talk)


การตั้งค่าที่ควรระวัง
---------------------

วิธีที่ง่ายที่สุดในการทำงานกับ Rails คือการเก็บข้อมูลภายนอกทั้งหมดในรูปแบบ UTF-8 หากคุณไม่ทำเช่นนั้น ไลบรารีของ Ruby และ Rails บางครั้งอาจสามารถแปลงข้อมูลภาษาในรูปแบบเดิมของคุณเป็น UTF-8 ได้ แต่นี่ไม่ได้ทำงานอย่างเสถียรเสมอ ดังนั้นคุณควรให้แน่ใจว่าข้อมูลภายนอกทั้งหมดเป็น UTF-8

หากคุณทำผิดพลาดในส่วนนี้ อาการที่พบบ่อยที่สุดคือมีสัญลักษณ์เพชรสีดำที่มีเครื่องหมายคำถามอยู่ภายในปรากฏในเบราว์เซอร์ อาการที่พบบ่อยอื่น ๆ คือตัวอักษรเช่น "Ã¼" ปรากฏแทน "ü"  Rails มีขั้นตอนภายในหลายอย่างเพื่อลดปัญหาที่เกิดขึ้นบ่อยๆ เช่นนี้ที่อาจตรวจจับและแก้ไขได้โดยอัตโนมัติ อย่างไรก็ตามหากคุณมีข้อมูลภายนอกที่ไม่ได้เก็บเป็น UTF-8 อาจทำให้เกิดปัญหาเช่นนี้ที่ Rails ไม่สามารถตรวจจับและแก้ไขได้อัตโนมัติ

แหล่งข้อมูลสองแห่งที่พบบ่อยที่ไม่ใช่ UTF-8:

* ตัวแก้ไขข้อความของคุณ: ส่วนใหญ่ตัวแก้ไขข้อความ (เช่น TextMate) จะตั้งค่าเริ่มต้นให้บันทึกไฟล์เป็น UTF-8 หากตัวแก้ไขข้อความของคุณไม่ได้ทำเช่นนั้น อาจทำให้ตัวอักษรพิเศษที่คุณป้อนในเทมเพลต (เช่น é) ปรากฏเป็นเพชรที่มีเครื่องหมายคำถามอยู่ในเบราว์เซอร์ สิ่งเดียวกันนี้ยังใช้กับไฟล์แปลภาษา i18n ของคุณ ตัวแก้ไขที่ไม่ได้ตั้งค่าเริ่มต้นเป็น UTF-8 (เช่นเวอร์ชันบางรุ่นของ Dreamweaver) มีวิธีเปลี่ยนค่าเริ่มต้นเป็น UTF-8 ให้ทำเช่นนั้น
* ฐานข้อมูลของคุณ: Rails มีค่าเริ่มต้นในการแปลงข้อมูลจากฐานข้อมูลของคุณเป็น UTF-8 ที่ขอบเขต อย่างไรก็ตามหากฐานข้อมูลของคุณไม่ใช้ UTF-8 เป็นรูปแบบภายใน อาจไม่สามารถเก็บตัวอักษรที่ผู้ใช้ป้อนได้ทั้งหมด เช่นหากฐานข้อมูลของคุณใช้ Latin-1 เป็นรูปแบบภายใน และผู้ใช้ป้อนตัวอักษรรัสเซีย ฮิบรู หรือญี่ปุ่น ข้อมูลจะหายไปตลอดไปเมื่อเข้าสู่ฐานข้อมูล หากเป็นไปได้ โปรดใช้ UTF-8 เป็นการเก็บข้อมูลภายในฐานข้อมูลของคุณ
