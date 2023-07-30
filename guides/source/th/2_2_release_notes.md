**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 29fda46e32914456eb8369ab3f2cb7d6
เอกสารปล่อยตัวของ Ruby on Rails 2.2
===============================

Rails 2.2 มีการปรับปรุงและเพิ่มฟีเจอร์ใหม่หลายอย่าง รายการนี้จะครอบคลุมการอัปเกรดที่สำคัญ แต่ไม่รวมถึงการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงทุกอย่าง หากคุณต้องการดูทุกอย่าง โปรดตรวจสอบ [รายการการเปลี่ยนแปลง](https://github.com/rails/rails/commits/2-2-stable) ในเรพอสิทอรี Rails หลักบน GitHub

พร้อมกับ Rails 2.2 นี้เป็นการเปิดตัวของ [Ruby on Rails Guides](https://guides.rubyonrails.org/) ผลลัพธ์แรกจากการปรับปรุงต่อเนื่องของ [Rails Guides hackfest](http://hackfest.rubyonrails.org/guide) ที่กำลังดำเนินการอยู่ ไซต์นี้จะให้เอกสารคุณภาพสูงเกี่ยวกับฟีเจอร์หลักของ Rails

--------------------------------------------------------------------------------

โครงสร้างพื้นฐาน
--------------

Rails 2.2 เป็นการปล่อยตัวที่สำคัญสำหรับโครงสร้างพื้นฐานที่ทำให้ Rails ทำงานได้อย่างราบรื่นและเชื่อมต่อกับโลกภายนอก

### การรองรับการใช้งานระหว่างประเทศ

Rails 2.2 มีระบบง่ายสำหรับการรองรับการใช้งานระหว่างประเทศ (หรือ i18n สำหรับผู้ที่เบื่อกับการพิมพ์)

* ผู้มีส่วนร่วมหลัก: ทีม Rails i18
* ข้อมูลเพิ่มเติม:
    * [เว็บไซต์ Rails i18 อย่างเป็นทางการ](http://rails-i18n.org)
    * [สุดท้ายแล้ว Ruby on Rails ได้รับการรองรับการใช้งานระหว่างประเทศ](https://web.archive.org/web/20140407075019/http://www.artweb-design.de/2008/7/18/finally-ruby-on-rails-gets-internationalized)
    * [การใช้งานระหว่างประเทศของ Rails: แอปพลิเคชันตัวอย่าง](https://github.com/clemens/i18n_demo_app)

### ความเข้ากันได้กับ Ruby 1.9 และ JRuby

พร้อมกับความปลอดภัยของเธรด มีการทำงานอย่างหนักเพื่อให้ Rails ทำงานได้ดีกับ JRuby และ Ruby 1.9 ที่กำลังจะมาถึง ด้วย Ruby 1.9 เป็นเป้าหมายที่เปลี่ยนแปลงอยู่เสมอ การทำงาน Rails บน Ruby 1.9 ยังคงเป็นเรื่องที่ไม่แน่นอน แต่ Rails พร้อมที่จะเปลี่ยนไปใช้ Ruby 1.9 เมื่อมีการเปิดตัว

เอกสารประกอบ
-------------

เอกสารภายในของ Rails ในรูปแบบของความคิดเห็นในรหัส ได้รับการปรับปรุงในหลายที่ นอกจากนี้ [Ruby on Rails Guides](https://guides.rubyonrails.org/) เป็นแหล่งข้อมูลที่แน่นอนสำหรับข้อมูลเกี่ยวกับคอมโพเนนต์หลักของ Rails ในการเปิดตัวครั้งแรก หน้า Guides ประกอบด้วย:

* [เริ่มต้นใช้ Rails](getting_started.html)
* [การเปลี่ยนแปลงฐานข้อมูลของ Rails](active_record_migrations.html)
* [การเชื่อมโยงข้อมูลของ Active Record](association_basics.html)
* [อินเตอร์เฟซการค้นหาข้อมูลของ Active Record](active_record_querying.html)
* [เลเอาท์และการเรนเดอร์ใน Rails](layouts_and_rendering.html)
* [ตัวช่วยฟอร์มของ Action View](form_helpers.html)
* [การกำหนดเส้นทางของ Rails จากด้านนอกเข้าไป](routing.html)
* [ภาพรวมของ Action Controller](action_controller_overview.html)
* [การใช้งานแคชของ Rails](caching_with_rails.html)
* [คู่มือการทดสอบแอปพลิเคชัน Rails](testing.html)
* [การรักษาความปลอดภัยของแอปพลิเคชัน Rails](security.html)
* [การแก้ไขข้อบกพร่องของแอปพลิเคชัน Rails](debugging_rails_applications.html)
* [พื้นฐานในการสร้างปลั๊กอิน Rails](plugins.html)
โดยรวมแล้วเอกสารแนะนำนี้จะให้คำแนะนำที่มีคำอธิบายเป็นหลายหมื่นคำสำหรับนักพัฒนา Rails ที่เริ่มต้นและระดับกลาง

หากคุณต้องการสร้างเอกสารแนะนำเหล่านี้ในโปรแกรมของคุณ:

```bash
$ rake doc:guides
```

นี้จะวางเอกสารแนะนำไว้ใน `Rails.root/doc/guides` และคุณสามารถเริ่มเรียกดูได้ทันทีโดยเปิด `Rails.root/doc/guides/index.html` ในเบราว์เซอร์ที่คุณชื่นชอบ

* มีความสนับสนุนจาก [Xavier Noria](http://advogato.org/person/fxn/diary.html) และ [Hongli Lai](http://izumi.plan99.net/blog/)
* ข้อมูลเพิ่มเติม:
    * [Rails Guides hackfest](http://hackfest.rubyonrails.org/guide)
    * [ช่วยปรับปรุงเอกสาร Rails ใน Git branch](https://weblog.rubyonrails.org/2008/5/2/help-improve-rails-documentation-on-git-branch)

การผสานตัวกับ HTTP ที่ดีขึ้น: การสนับสนุน ETag แบบพร้อมใช้งาน
----------------------------------------------------------

การสนับสนุน ETag และการปรับปรุงล่าสุดในเวลา HTTP headers หมายความว่า Rails สามารถส่งคำขอกลับที่ว่างเปล่าได้หากได้รับคำขอสำหรับทรัพยากรที่ไม่ได้รับการปรับปรุงล่าสุด เรื่องนี้ช่วยให้คุณสามารถตรวจสอบว่าจำเป็นต้องส่งคำขอกลับหรือไม่

```ruby
class ArticlesController < ApplicationController
  def show_with_respond_to_block
    @article = Article.find(params[:id])

    # หากคำขอส่ง headers ที่แตกต่างจากตัวเลือกที่ให้กับ stale? แล้ว
    # คำขอจะเป็นคำขอที่ไม่เป็นปัจจุบันและบล็อก respond_to จะถูกเรียกใช้งาน (และตัวเลือก
    # ที่ให้กับ stale? จะถูกตั้งค่าในการตอบสนอง)
    #
    # หาก headers ของคำขอตรงกัน คำขอจะเป็นคำขอที่เป็นปัจจุบันและบล็อก respond_to จะไม่ถูกเรียกใช้งาน แต่
    # การเรนเดอร์เริ่มต้นจะเกิดขึ้น ซึ่งจะตรวจสอบ headers ที่เป็น last-modified
    # และ etag และสรุปว่ามีเพียงการส่ง "304 Not Modified" แทนการเรนเดอร์เทมเพลต
    if stale?(:last_modified => @article.published_at.utc, :etag => @article)
      respond_to do |wants|
        # การประมวลผลการตอบสนองปกติ
      end
    end
  end

  def show_with_implied_render
    @article = Article.find(params[:id])

    # ตั้งค่า headers การตอบสนองและตรวจสอบคำขอกับ headers หากคำขอเป็นคำขอที่ไม่เป็นปัจจุบัน
    # (เช่นไม่ตรงกับ etag หรือ last-modified) แล้วการเรนเดอร์เริ่มต้นของเทมเพลตจะเกิดขึ้น
    # หากคำขอเป็นคำขอที่เป็นปัจจุบัน การเรนเดอร์เริ่มต้นจะส่งคำขอ "304 Not Modified"
    # แทนการเรนเดอร์เทมเพลต
    fresh_when(:last_modified => @article.published_at.utc, :etag => @article)
  end
end
```
ความปลอดภัยของเธรด
-------------

การทำงานเพื่อทำให้ Rails เป็นเธรดปลอดภัยกำลังถูกนำมาใช้ใน Rails 2.2 ขึ้นอยู่กับโครงสร้างเว็บเซิร์ฟเวอร์ของคุณ นี่หมายความว่าคุณสามารถจัดการคำขอได้มากขึ้นด้วยการทำสำเนาของ Rails ในหน่วยความจำน้อยลง ซึ่งจะนำไปสู่ประสิทธิภาพของเซิร์ฟเวอร์ที่ดีขึ้นและการใช้งานหลายคอร์สมากขึ้น

ในการเปิดใช้งานการส่งเธรดหลายเธรดในโหมดการใช้งานจริงของแอปพลิเคชันของคุณ ให้เพิ่มบรรทัดต่อไปนี้ใน `config/environments/production.rb`:

```ruby
config.threadsafe!
```

* ข้อมูลเพิ่มเติม:
    * [ความปลอดภัยของเธรดสำหรับ Rails ของคุณ](http://m.onkey.org/2008/10/23/thread-safety-for-your-rails)
    * [ประกาศโครงการความปลอดภัยของเธรด](https://weblog.rubyonrails.org/2008/8/16/josh-peek-officially-joins-the-rails-core)
    * [คำถามและคำตอบ: ความหมายของ Rails ที่ปลอดภัยเธรด](http://blog.headius.com/2008/08/qa-what-thread-safe-rails-means.html)

Active Record
-------------

มีสองส่วนใหญ่ที่ต้องพูดถึง: การเคลื่อนย้ายทรัพยากรแบบทรานแซกชันและการทำงานร่วมกันของฐานข้อมูลแบบเพิ่มขึ้น นอกจากนี้ยังมีไวยากรณ์ใหม่ (และสะอาดกว่า) สำหรับเงื่อนไขตารางเชื่อมโยง รวมถึงการปรับปรุงขนาดเล็กๆ อีกมากมาย

### การเคลื่อนย้ายทรัพยากรแบบทรานแซกชัน

ในอดีต การเคลื่อนย้ายทรัพยากรแบบหลายขั้นตอนใน Rails เคยเป็นที่สร้างปัญหา หากเกิดข้อผิดพลาดในระหว่างการเคลื่อนย้าย ทุกอย่างก่อนข้อผิดพลาดจะเปลี่ยนแปลงฐานข้อมูลและทุกอย่างหลังข้อผิดพลาดจะไม่ถูกนำไปใช้งาน นอกจากนี้ยังจัดเก็บเวอร์ชันการเคลื่อนย้ายเป็นว่าได้รับการดำเนินการแล้ว ซึ่งหมายความว่าไม่สามารถรันใหม่ได้โดยใช้ `rake db:migrate:redo` หลังจากแก้ไขปัญหา การเคลื่อนย้ายแบบทรานแซกชันเปลี่ยนแปลงสิ่งนี้โดยห่อหุ้มขั้นตอนการเคลื่อนย้ายในทรัพยากร DDL ดังนั้นหากมีข้อผิดพลาดเกิดขึ้น การเคลื่อนย้ายทั้งหมดจะถูกยกเลิก ใน Rails 2.2 การเคลื่อนย้ายแบบทรานแซกชันได้รับการสนับสนุนบน PostgreSQL โดยค่าเริ่มต้น โค้ดสามารถขยายได้สำหรับประเภทฐานข้อมูลอื่นในอนาคต - และ IBM ได้ขยายการสนับสนุนให้รองรับตัวอ่อนของ DB2

* ผู้มีส่วนร่วมหลัก: [Adam Wiggins](http://about.adamwiggins.com/)
* ข้อมูลเพิ่มเติม:
    * [การทำธุรกรรม DDL](http://adam.heroku.com/past/2008/9/3/ddl_transactions/)
    * [เหตุการณ์สำคัญสำหรับ DB2 on Rails](http://db2onrails.com/2008/11/08/a-major-milestone-for-db2-on-rails/)

### การจัดการเชื่อมต่อ

การจัดการเชื่อมต่อช่วยให้ Rails แจกแจงคำขอฐานข้อมูลในกลุ่มของการเชื่อมต่อฐานข้อมูลที่จะเติมขึ้นไปเรื่อยๆ (โดยค่าเริ่มต้นคือ 5 แต่คุณสามารถเพิ่มคีย์ `pool` ใน `database.yml` เพื่อปรับเปลี่ยนได้) สิ่งนี้ช่วยลดปัญหาที่เกิดขึ้นในแอปพลิเคชันที่รองรับผู้ใช้หลายคนพร้อมกัน นอกจากนี้ยังมี `wait_timeout` ที่ค่าเริ่มต้นคือ 5 วินาทีก่อนที่จะยกเลิก  `ActiveRecord::Base.connection_pool` ให้คุณเข้าถึงพูลโดยตรงหากคุณต้องการ
```yaml
development:
  adapter: mysql
  username: root
  database: sample_development
  pool: 10
  wait_timeout: 10
```

* ผู้มีส่วนร่วมสำคัญ: [Nick Sieger](http://blog.nicksieger.com/)
* ข้อมูลเพิ่มเติม:
    * [What's New in Edge Rails: Connection Pools](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-connection-pools)

### Hashes สำหรับเงื่อนไขในตารางการเชื่อมต่อ

ตอนนี้คุณสามารถระบุเงื่อนไขในตารางการเชื่อมต่อโดยใช้ Hash ได้ ซึ่งเป็นการช่วยใหญ่ในกรณีที่คุณต้องการค้นหาข้ามการเชื่อมต่อที่ซับซ้อน

```ruby
class Photo < ActiveRecord::Base
  belongs_to :product
end

class Product < ActiveRecord::Base
  has_many :photos
end

# รับผลิตภัณฑ์ทั้งหมดที่มีรูปถ่ายที่ไม่มีลิขสิทธิ์
Product.all(:joins => :photos, :conditions => { :photos => { :copyright => false }})
```

* ข้อมูลเพิ่มเติม:
    * [What's New in Edge Rails: Easy Join Table Conditions](http://archives.ryandaigle.com/articles/2008/7/7/what-s-new-in-edge-rails-easy-join-table-conditions)

### Dynamic Finders ใหม่

เพิ่มเซตของเมธอดใหม่ในครอบครัวของ Dynamic Finders ใน Active Record

#### `find_last_by_attribute`

เมธอด `find_last_by_attribute` เทียบเท่ากับ `Model.last(:conditions => {:attribute => value})`

```ruby
# รับผู้ใช้ล่าสุดที่ลงทะเบียนจากเมืองลอนดอน
User.find_last_by_city('London')
```

* ผู้มีส่วนร่วมสำคัญ: [Emilio Tagua](http://www.workingwithrails.com/person/9147-emilio-tagua)

#### `find_by_attribute!`

เวอร์ชัน bang! ใหม่ของ `find_by_attribute!` เทียบเท่ากับ `Model.first(:conditions => {:attribute => value}) || raise ActiveRecord::RecordNotFound` แทนที่จะส่งคืน `nil` หากไม่พบระเบียนที่ตรงกัน เมธอดนี้จะเรียกใช้งานข้อยกเว้นหากไม่พบการจับคู่

```ruby
# ยกเลิกการทำงานแสดงข้อยกเว้น ActiveRecord::RecordNotFound หาก 'Moby' ยังไม่ได้ลงทะเบียน!
User.find_by_name!('Moby')
```

* ผู้มีส่วนร่วมสำคัญ: [Josh Susser](http://blog.hasmanythrough.com)

### การเชื่อมโยงให้เคารพขอบเขตส่วนตัว/ป้องกัน

ตัวแทนการเชื่อมโยงใน Active Record ตอนนี้เคารพขอบเขตของเมธอดบนออบเจกต์ที่เชื่อมโยง ก่อนหน้านี้ (โดยกำหนดให้ User has_one :account) `@user.account.private_method` จะเรียกเมธอดส่วนตัวบนออบเจกต์ Account ซึ่งล้มเหลวใน Rails 2.2 หากคุณต้องการฟังก์ชันนี้คุณควรใช้ `@user.account.send(:private_method)` (หรือทำให้เมธอดเป็นสาธารณะแทนที่จะเป็นส่วนตัวหรือป้องกัน) โปรดทราบว่าหากคุณกำหนดการแทนที่ `method_missing` คุณควรกำหนดการแทนที่ `respond_to` เพื่อให้ตรงกับพฤติกรรมเพื่อให้การเชื่อมโยงทำงานได้ตามปกติ

* ผู้มีส่วนร่วมสำคัญ: Adam Milligan
* ข้อมูลเพิ่มเติม:
    * [Rails 2.2 Change: Private Methods on Association Proxies are Private](http://afreshcup.com/2008/10/24/rails-22-change-private-methods-on-association-proxies-are-private/)
### การเปลี่ยนแปลง Active Record อื่น ๆ

* `rake db:migrate:redo` ตอนนี้ยอมรับ VERSION ที่เป็นทางเลือกเพื่อเป้าหมายในการทำซ้ำการเคลื่อนย้ายนั้น
* ตั้งค่า `config.active_record.timestamped_migrations = false` เพื่อให้การเคลื่อนย้ายมีคำนำหน้าที่เป็นตัวเลขแทน UTC timestamp
* คอลัมน์ Counter cache (สำหรับความสัมพันธ์ที่ประกาศด้วย `:counter_cache => true`) ไม่จำเป็นต้องเริ่มต้นด้วยศูนย์อีกต่อไป
* `ActiveRecord::Base.human_name` สำหรับการแปลแบบมีการตรวจสอบความรู้ในเรื่องระบบรุ่นของชื่อโมเดล

Action Controller
-----------------

ในส่วนของคอนโทรลเลอร์ มีการเปลี่ยนแปลงหลายอย่างที่จะช่วยให้เสถียรกับเส้นทางของคุณ นอกจากนี้ยังมีการเปลี่ยนแปลงภายในของเครื่องมือเส้นทางเพื่อลดการใช้หน่วยความจำในแอปพลิเคชันที่ซับซ้อน

### Shallow Route Nesting

การซ้อนเส้นทางแบบ shallow ให้คำตอบกับความยากลำบากที่รู้จักกันดีในการใช้ทรัพยากรที่ซ้อนกันอย่างลึก ด้วยการซ้อนเส้นทางแบบ shallow คุณต้องให้ข้อมูลเพียงพอเพื่อระบุทรัพยากรที่คุณต้องการทำงานด้วย

```ruby
map.resources :publishers, :shallow => true do |publisher|
  publisher.resources :magazines do |magazine|
    magazine.resources :photos
  end
end
```

นี้จะทำให้สามารถรู้จักเส้นทางเหล่านี้ได้ (รวมถึงอื่น ๆ):

```
/publishers/1           ==> publisher_path(1)
/publishers/1/magazines ==> publisher_magazines_path(1)
/magazines/2            ==> magazine_path(2)
/magazines/2/photos     ==> magazines_photos_path(2)
/photos/3               ==> photo_path(3)
```

* ผู้มีส่วนร่วมหลัก: [S. Brent Faulkner](http://www.unwwwired.net/)
* ข้อมูลเพิ่มเติม:
    * [Rails Routing from the Outside In](routing.html#nested-resources)
    * [What's New in Edge Rails: Shallow Routes](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-shallow-routes)

### อาร์เรย์เมธอดสำหรับเส้นทางสมาชิกหรือคอลเลกชัน

ตอนนี้คุณสามารถให้อาร์เรย์ของเมธอดสำหรับเส้นทางสมาชิกหรือคอลเลกชันใหม่ได้ ซึ่งจะลดความรำคาญของการต้องกำหนดเส้นทางให้ยอมรับแบบเดียวกันทันทีที่คุณต้องการให้มันจัดการมากกว่าหนึ่ง ด้วย Rails 2.2 นี้เป็นการประกาศเส้นทางที่ถูกต้อง:

```ruby
map.resources :photos, :collection => { :search => [:get, :post] }
```

* ผู้มีส่วนร่วมหลัก: [Brennan Dunn](http://brennandunn.com/)

### ทรัพยากรที่มีการกระทำเฉพาะ

ตามค่าเริ่มต้น เมื่อคุณใช้ `map.resources` เพื่อสร้างเส้นทาง Rails จะสร้างเส้นทางสำหรับการกระทำเริ่มต้นทั้งหมดเจ็ดรายการ (ดัชนี แสดง สร้าง ใหม่ แก้ไข อัปเดต และลบ) แต่แต่ละเส้นทางเหล่านี้ใช้หน่วยความจำในแอปพลิเคชันของคุณ และทำให้ Rails สร้างตรรกะการเส้นทางเพิ่มเติม ตอนนี้คุณสามารถใช้ตัวเลือก `:only` และ `:except` เพื่อปรับแต่งเส้นทางที่ Rails จะสร้างสำหรับทรัพยากร คุณสามารถให้การกระทำเดียว อาร์เรย์ของการกระทำ หรือตัวเลือกพิเศษ `:all` หรือ `:none` ตัวเลือกเหล่านี้จะถูกสืบทอดโดยทรัพยากรที่ซ้อนกัน
```ruby
map.resources :photos, :only => [:index, :show]
map.resources :products, :except => :destroy
```

* ผู้มีส่วนร่วมสำคัญ: [Tom Stuart](http://experthuman.com/)

### การเปลี่ยนแปลงอื่น ๆ ใน Action Controller

* ตอนนี้คุณสามารถแสดงหน้าข้อผิดพลาดที่กำหนดเองได้ง่ายขึ้นสำหรับข้อผิดพลาดที่เกิดขึ้นในระหว่างการเรียกเส้นทางของคำขอ ([อ่านเพิ่มเติม](http://m.onkey.org/2008/7/20/rescue-from-dispatching))
* ส่วนหัว HTTP Accept ถูกปิดใช้งานโดยค่าเริ่มต้นตอนนี้ คุณควรใช้ URL ที่กำหนดรูปแบบ (เช่น `/customers/1.xml`) เพื่อระบุรูปแบบที่คุณต้องการ หากคุณต้องการใช้หัวข้อ Accept คุณสามารถเปิดใช้งานอีกครั้งโดยใช้ `config.action_controller.use_accept_header = true`
* ตัววัดเวลา Benchmarking รายงานตอนนี้ในหน่วยเวลามิลลิวินาทีแทนที่จะเป็นส่วนเล็กน้อยของวินาที
* Rails ตอนนี้รองรับคุกกี้ที่ใช้เฉพาะ HTTP (และใช้ในเซสชัน) ซึ่งช่วยลดความเสี่ยงของการโจมตีแบบครอสไซต์สคริปต์ในเบราว์เซอร์รุ่นใหม่
* `redirect_to` ตอนนี้รองรับ URI schemes อย่างเต็มรูปแบบ (ดังนั้น เช่น คุณสามารถเปลี่ยนเส้นทางไปยัง svn`ssh: URI)
* `render` ตอนนี้รองรับตัวเลือก `:js` เพื่อแสดง JavaScript ธรรมดาโดยใช้ MIME type ที่ถูกต้อง
* การป้องกันการปลอมแปลงคำขอถูกเข้มงวดขึ้นเพื่อใช้กับคำขอที่มีเนื้อหารูปแบบ HTML เท่านั้น
* Polymorphic URLs ทำงานอย่างมีเหตุผลมากขึ้นหากพารามิเตอร์ที่ถูกส่งเป็น nil ตัวอย่างเช่นการเรียกใช้ `polymorphic_path([@project, @date, @area])` โดยกำหนดวันที่เป็น nil จะให้คุณได้ `project_area_path`.

Action View
-----------

* `javascript_include_tag` และ `stylesheet_link_tag` รองรับตัวเลือก `:recursive` ใหม่ที่จะใช้ร่วมกับ `:all` เพื่อให้คุณสามารถโหลดไฟล์ทั้งต้นไม้ด้วยบรรทัดเดียว
* ไลบรารี Prototype JavaScript ที่รวมอยู่ถูกอัปเกรดเป็นเวอร์ชัน 1.6.0.3
* `RJS#page.reload` เพื่อโหลดหน้าเว็บใหม่ของเบราว์เซอร์ผ่าน JavaScript
* ช่วยเหลือ `atom_feed` ตอนนี้รองรับตัวเลือก `:instruct` เพื่อให้คุณสามารถแทรกคำสั่งประมวลผล XML

Action Mailer
-------------

Action Mailer ตอนนี้รองรับเลเอาท์เมลเลย์เอาท์ คุณสามารถทำให้อีเมล HTML สวยงามเหมือนกับมุมมองในเบราว์เซอร์ของคุณได้โดยให้เลือกเลเอาท์ที่มีชื่อที่เหมาะสม - ตัวอย่างเช่น คลาส `CustomerMailer` คาดหวังว่าจะใช้ `layouts/customer_mailer.html.erb`.
* ข้อมูลเพิ่มเติม:
    * [สิ่งใหม่ใน Edge Rails: Mailer Layouts](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-mailer-layouts)

Action Mailer ตอนนี้มีการสนับสนุนสำหรับเซิร์ฟเวอร์ SMTP ของ GMail ที่มีอยู่แล้ว โดยเปิดใช้งาน STARTTLS โดยอัตโนมัติ สิ่งนี้ต้องการให้ติดตั้ง Ruby 1.8.7

Active Support
--------------

Active Support ตอนนี้มีการสนับสนุน memoization สำหรับแอปพลิเคชัน Rails ที่มีอยู่แล้ว มีเมธอด `each_with_object` การสนับสนุน prefix บน delegates และเมธอดเครื่องมือใหม่อื่น ๆ

### Memoization

Memoization เป็นรูปแบบการเริ่มต้นเมธอดครั้งเดียวแล้วเก็บค่าไว้สำหรับการใช้งานซ้ำ คุณอาจเคยใช้รูปแบบนี้ในแอปพลิเคชันของคุณเอง:

```ruby
def full_name
  @full_name ||= "#{first_name} #{last_name}"
end
```

Memoization ช่วยให้คุณจัดการงานนี้ได้ในรูปแบบที่กำหนด:

```ruby
extend ActiveSupport::Memoizable

def full_name
  "#{first_name} #{last_name}"
end
memoize :full_name
```

คุณสามารถใช้คุณสมบัติอื่น ๆ ของ memoization เช่น `unmemoize`, `unmemoize_all`, และ `memoize_all` เพื่อเปิดหรือปิด memoization

* ผู้มีส่วนร่วมหลัก: [Josh Peek](http://joshpeek.com/)
* ข้อมูลเพิ่มเติม:
    * [สิ่งใหม่ใน Edge Rails: Easy Memoization](http://archives.ryandaigle.com/articles/2008/7/16/what-s-new-in-edge-rails-memoization)
    * [Memo-what? คู่มือการใช้งาน Memoization](http://www.railway.at/articles/2008/09/20/a-guide-to-memoization)

### each_with_object

เมธอด `each_with_object` ให้ตัวเลือกทางเลือกในการใช้งาน `inject` โดยใช้เมธอดที่ถูกนำกลับมาจาก Ruby 1.9 มันทำการวนซ้ำผ่านคอลเลกชัน โดยส่งองค์ปัจจุบันและเมโมเรนดัมเข้าสู่บล็อก

```ruby
%w(foo bar).each_with_object({}) { |str, hsh| hsh[str] = str.upcase } # => {'foo' => 'FOO', 'bar' => 'BAR'}
```

ผู้มีส่วนร่วมหลัก: [Adam Keys](http://therealadam.com/)

### Delegates พร้อม Prefixes

หากคุณตั้งค่าการเชื่อมต่อพฤติกรรมจากคลาสหนึ่งไปยังอีกคลาสหนึ่ง คุณสามารถระบุ prefix ที่จะใช้เพื่อระบุวิธีการที่ถูกเชื่อมต่อไว้ ตัวอย่างเช่น:

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => true
end
```

นี้จะสร้างเมธอดที่ถูกเชื่อมต่อไว้ `vendor#account_email` และ `vendor#account_password` คุณยังสามารถระบุ prefix ที่กำหนดเองได้:

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => :owner
end
```

นี้จะสร้างเมธอดที่ถูกเชื่อมต่อไว้ `vendor#owner_email` และ `vendor#owner_password`

ผู้มีส่วนร่วมหลัก: [Daniel Schierbeck](http://workingwithrails.com/person/5830-daniel-schierbeck)
### การเปลี่ยนแปลงที่เกี่ยวกับ Active Support อื่น ๆ

* อัปเดตอย่างเป็นรายละเอียดใน `ActiveSupport::Multibyte` รวมถึงการแก้ไขความเข้ากันได้กับ Ruby 1.9
* เพิ่ม `ActiveSupport::Rescuable` ที่ช่วยให้คลาสใด ๆ สามารถผสม `rescue_from` syntax ได้
* `past?`, `today?` และ `future?` สำหรับคลาส `Date` และ `Time` เพื่อให้ง่ายต่อการเปรียบเทียบวันที่/เวลา
* `Array#second` ถึง `Array#fifth` เป็นตัวย่อสำหรับ `Array#[1]` ถึง `Array#[4]`
* `Enumerable#many?` เพื่อแทนที่ `collection.size > 1`
* `Inflector#parameterize` สร้างเวอร์ชันที่พร้อมใช้งานใน URL ของข้อมูลนำเข้าของมันสำหรับใช้ใน `to_param`
* `Time#advance` รองรับวันที่และสัปดาห์ทศนิยม เช่น `1.7.weeks.ago`, `1.5.hours.since`, และอื่น ๆ
* TzInfo library ที่รวมอยู่ได้รับการอัปเกรดเป็นเวอร์ชัน 0.3.12
* `ActiveSupport::StringInquirer` ให้คุณสามารถทดสอบความเท่าเทียมของสตริงได้อย่างสวยงาม: `ActiveSupport::StringInquirer.new("abc").abc? => true`

Railties
--------

ใน Railties (รหัสหลักของ Rails เอง) การเปลี่ยนแปลงที่สำคัญอยู่ในกลไก `config.gems`.

### config.gems

เพื่อหลีกเลี่ยงปัญหาการติดตั้งและทำให้แอปพลิเคชัน Rails เป็นอิสระมากขึ้น คุณสามารถวางสำเนาของเจ็มทั้งหมดที่แอปพลิเคชัน Rails ของคุณต้องการไว้ใน `/vendor/gems` ความสามารถนี้ปรากฏครั้งแรกใน Rails 2.1 แต่มันยืดหยุ่นและทนทานมากขึ้นใน Rails 2.2 โดยจัดการความสัมพันธ์ที่ซับซ้อนระหว่างเจ็ม การจัดการเจ็มใน Rails รวมถึงคำสั่งเหล่านี้:

* `config.gem _ชื่อเจ็ม_` ในไฟล์ `config/environment.rb` ของคุณ
* `rake gems` เพื่อแสดงรายการเจ็มที่กำหนดค่าทั้งหมดพร้อมกับการตรวจสอบว่าเจ็มเหล่านั้น (และส่วนประกอบของเจ็ม) ได้ถูกติดตั้งแล้วหรือไม่ ถูกติดตั้งแบบแช่แข็งหรือไม่ หรือเป็นเจ็มของเฟรมเวิร์ก (เจ็มของเฟรมเวิร์กคือเจ็มที่โหลดโดย Rails ก่อนที่จะมีการดำเนินการโค้ดที่ขึ้นอยู่กับเจ็มที่ต้องการ; เจ็มเหล่านี้ไม่สามารถแช่แข็งได้)
* `rake gems:install` เพื่อติดตั้งเจ็มที่ขาดหายไปในคอมพิวเตอร์
* `rake gems:unpack` เพื่อวางสำเนาของเจ็มที่ต้องการไว้ใน `/vendor/gems`
* `rake gems:unpack:dependencies` เพื่อรับสำเนาของเจ็มที่ต้องการและส่วนประกอบของเจ็มเหล่านั้นไว้ใน `/vendor/gems`
* `rake gems:build` เพื่อสร้างส่วนขยายที่ขาดหายไป
* `rake gems:refresh_specs` เพื่อปรับให้เจ็มที่วางสำเนาที่สร้างขึ้นด้วย Rails 2.1 สอดคล้องกับวิธีการเก็บรักษาเวอร์ชัน 2.2 
คุณสามารถแยกและติดตั้ง gem เดี่ยวโดยระบุ `GEM=_ชื่อ_gem_` บน command line

* ผู้มีส่วนร่วมหลัก: [Matt Jones](https://github.com/al2o3cr)
* ข้อมูลเพิ่มเติม:
    * [สิ่งใหม่ใน Edge Rails: การขึ้นอยู่กับ Gem](http://archives.ryandaigle.com/articles/2008/4/1/what-s-new-in-edge-rails-gem-dependencies)
    * [Rails 2.1.2 และ 2.2RC1: อัปเดต RubyGems ของคุณ](https://afreshcup.com/home/2008/10/25/rails-212-and-22rc1-update-your-rubygems)
    * [การสนทนาอย่างละเอียดใน Lighthouse](http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1128)

### การเปลี่ยนแปลง Railties อื่น ๆ

* หากคุณเป็นแฟนของเว็บเซิร์ฟเวอร์ [Thin](http://code.macournoyer.com/thin/) คุณจะดีใจที่รู้ว่า `script/server` สนับสนุน Thin โดยตรงเลย
* `script/plugin install &lt;plugin&gt; -r &lt;revision&gt;` ทำงานกับปลั๊กอินที่ใช้ git และ svn ได้แล้ว
* `script/console` สนับสนุนตัวเลือก `--debugger` เดี๋ยวนี้
* คำแนะนำสำหรับการติดตั้งเซิร์ฟเวอร์การสร้างต่อเนื่องเพื่อสร้าง Rails เองถูกนำเข้าไว้ในแหล่งที่มาของ Rails
* `rake notes:custom ANNOTATION=MYFLAG` ช่วยให้คุณสามารถรายการออกมาได้สำหรับหมายเหตุที่กำหนดเอง
* ครอบคลุม `Rails.env` ด้วย `StringInquirer` เพื่อให้คุณสามารถทำ `Rails.env.development?` ได้
* เพื่อกำจัดคำเตือนการเลิกใช้และจัดการกับการขึ้นอยู่กับ gem อย่างถูกต้อง Rails ต้องการ rubygems เวอร์ชัน 1.3.1 หรือสูงกว่า

เลิกใช้
----------

มีรหัสเก่าบางส่วนที่ถูกเลิกใช้ในการเวลานี้:

* `Rails::SecretKeyGenerator` ถูกแทนที่ด้วย `ActiveSupport::SecureRandom`
* `render_component` ถูกเลิกใช้ มีปลั๊กอิน [render_components](https://github.com/rails/render_component/tree/master) ที่ใช้ได้หากคุณต้องการฟังก์ชันนี้
* การกำหนดค่าตัวแปรท้องถิ่นอัตโนมัติเมื่อเรียกใช้ partial ถูกเลิกใช้

    ```ruby
    def partial_with_implicit_local_assignment
      @customer = Customer.new("Marcel")
      render :partial => "customer"
    end
    ```

    ก่อนหน้านี้โค้ดด้านบนทำให้ตัวแปรท้องถิ่นชื่อ `customer` สามารถใช้งานได้ภายใน partial 'customer' คุณควรส่งตัวแปรทั้งหมดผ่าน :locals hash อย่างชัดเจนตอนนี้

* `country_select` ถูกลบออก ดู[หน้าการเลิกใช้](http://www.rubyonrails.org/deprecation/list-of-countries) เพื่อข้อมูลเพิ่มเติมและการแทนที่ด้วยปลั๊กอิน
* `ActiveRecord::Base.allow_concurrency` ไม่มีผลอีกต่อไป
* `ActiveRecord::Errors.default_error_messages` ถูกเลิกใช้แล้วและแนะนำให้ใช้ `I18n.translate('activerecord.errors.messages')` แทน
* การตัดสินใจ `%s` และ `%d` สำหรับการระบุตำแหน่งทางสากลถูกเลิกใช้
* `String#chars` ถูกเลิกใช้และแนะนำให้ใช้ `String#mb_chars` แทน
* ระยะเวลาของเดือนทศนิยมหรือปีทศนิยมถูกเลิกใช้ ใช้การคำนวณคลาส `Date` และ `Time` ในภาษา Ruby แทน
* `Request#relative_url_root` ถูกเลิกใช้ ใช้ `ActionController::Base.relative_url_root` แทน
เครดิต

บันทึกการอัปเดตรุ่นที่รวมกันโดย [ไมค์ กันเดอร์ลอย](http://afreshcup.com)
