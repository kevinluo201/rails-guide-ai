**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3cf93e3667cdacd242332d2d352d53fa
การแก้ปัญหาในแอปพลิเคชัน Rails
============================

เอกสารนี้จะแนะนำเทคนิคในการแก้ปัญหาในแอปพลิเคชัน Ruby on Rails

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วัตถุประสงค์ของการแก้ปัญหา
* วิธีการตรวจหาปัญหาและข้อบกพร่องในแอปพลิเคชันของคุณที่การทดสอบไม่สามารถระบุได้
* วิธีการแก้ปัญหาที่แตกต่างกัน
* วิธีการวิเคราะห์ stack trace

--------------------------------------------------------------------------------

View Helpers สำหรับการ Debugging
--------------------------

หนึ่งในงานที่พบบ่อยคือการตรวจสอบเนื้อหาของตัวแปร ใน Rails มีวิธีการที่แตกต่างกัน 3 วิธีดังนี้:

* `debug`
* `to_yaml`
* `inspect`

### `debug`

เมธอด `debug` จะคืนค่าแท็ก \<pre> ที่แสดงวัตถุโดยใช้รูปแบบ YAML ซึ่งจะสร้างข้อมูลที่สามารถอ่านได้จากวัตถุใดๆ ตัวอย่างเช่น ถ้าคุณมีโค้ดนี้ในวิว:

```html+erb
<%= debug @article %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

คุณจะเห็นผลลัพธ์เช่นนี้:

```yaml
--- !ruby/object Article
attributes:
  updated_at: 2008-09-05 22:55:47
  body: It's a very helpful guide for debugging your Rails app.
  title: Rails debugging guide
  published: t
  id: "1"
  created_at: 2008-09-05 22:55:47
attributes_cache: {}


Title: Rails debugging guide
```

### `to_yaml`

อีกวิธีหนึ่งคือการเรียกใช้ `to_yaml` กับวัตถุใดๆ เพื่อแปลงเป็น YAML คุณสามารถส่งวัตถุที่แปลงแล้วนี้เข้าไปในเมธอด `simple_format` เพื่อจัดรูปแบบผลลัพธ์ นี่คือวิธีที่ `debug` ทำงาน

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

โค้ดด้านบนจะแสดงผลลัพธ์เช่นนี้:

```yaml
--- !ruby/object Article
attributes:
updated_at: 2008-09-05 22:55:47
body: It's a very helpful guide for debugging your Rails app.
title: Rails debugging guide
published: t
id: "1"
created_at: 2008-09-05 22:55:47
attributes_cache: {}

Title: Rails debugging guide
```

### `inspect`

เมธอดที่มีประโยชน์อีกอย่างหนึ่งในการแสดงค่าวัตถุคือ `inspect` โดยเฉพาะเมื่อทำงานกับอาร์เรย์หรือแฮช ซึ่งจะพิมพ์ค่าวัตถุเป็นสตริง ตัวอย่างเช่น:

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```
จะแปลเป็น:

```
[1, 2, 3, 4, 5]

ชื่อเรื่อง: คู่มือการแก้ปัญหาใน Rails
```

Logger
----------

การบันทึกข้อมูลลงในไฟล์บันทึก (log files) ในระหว่างการทำงานอาจเป็นประโยชน์ ใน Rails จะเก็บไฟล์บันทึกแยกต่างหากสำหรับแต่ละสภาวะการทำงาน (runtime environment)

### Logger คืออะไร?

Rails ใช้คลาส `ActiveSupport::Logger` เพื่อเขียนข้อมูลบันทึก (log information) อื่นๆ เช่น `Log4r` ก็สามารถใช้แทนได้

คุณสามารถระบุ Logger ทางเลือกได้ใน `config/application.rb` หรือในไฟล์สภาวะการทำงานอื่นๆ ตัวอย่างเช่น:

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

หรือในส่วน `Initializer` เพิ่ม _ใดๆ_ จากต่อไปนี้

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

เคล็ดลับ: โดยค่าเริ่มต้น แต่ละ log ถูกสร้างขึ้นใน `Rails.root/log/` และไฟล์บันทึกมีชื่อตามสภาวะการทำงานของแอปพลิเคชัน

### ระดับของ Log

เมื่อมีการบันทึกข้อมูล จะถูกพิมพ์ลงในไฟล์บันทึกที่เกี่ยวข้อง หากระดับของข้อความเท่ากับหรือสูงกว่าระดับของการบันทึกที่กำหนดไว้ หากคุณต้องการทราบระดับการบันทึกปัจจุบัน คุณสามารถเรียกใช้เมธอด `Rails.logger.level` ได้

ระดับการบันทึกที่มีให้ใช้คือ: `:debug`, `:info`, `:warn`, `:error`, `:fatal`, และ `:unknown` ที่สอดคล้องกับตัวเลขระดับการบันทึกตั้งแต่ 0 ถึง 5 ตามลำดับ หากต้องการเปลี่ยนระดับการบันทึกเริ่มต้น ให้ใช้

```ruby
config.log_level = :warn # ในไฟล์สร้างสภาวะการทำงานใดๆ หรือ
Rails.logger.level = 0 # ได้ตลอดเวลา
```

สิ่งนี้เป็นประโยชน์เมื่อคุณต้องการบันทึกข้อมูลในระหว่างการพัฒนาหรือการทดสอบโดยไม่ต้องทำให้ไฟล์บันทึกการทำงานจนเต็มไปด้วยข้อมูลที่ไม่จำเป็น

เคล็ดลับ: ระดับการบันทึกเริ่มต้นของ Rails คือ `:debug` อย่างไรก็ตาม สำหรับสภาวะการทำงาน `production` ในไฟล์ `config/environments/production.rb` ที่สร้างขึ้นเริ่มต้น ระดับการบันทึกถูกตั้งค่าเป็น `:info`

### การส่งข้อความ

ในการเขียนลงในไฟล์บันทึกปัจจุบัน ให้ใช้เมธอด `logger.(debug|info|warn|error|fatal|unknown)` จากภายในคอนโทรลเลอร์ โมเดล หรือเมลเลอร์:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
logger.info "Processing the request..."
logger.fatal "Terminating application, raised unrecoverable error!!!"
```
นี่คือตัวอย่างของเมธอดที่มีการเพิ่มการบันทึกเพิ่มเติม:

```ruby
class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(article_params)
    logger.debug "บทความใหม่: #{@article.attributes.inspect}"
    logger.debug "บทความควรถูกต้อง: #{@article.valid?}"

    if @article.save
      logger.debug "บทความถูกบันทึกและผู้ใช้จะถูกเปลี่ยนเส้นทาง..."
      redirect_to @article, notice: 'บทความถูกสร้างเรียบร้อยแล้ว'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ...

  private
    def article_params
      params.require(:article).permit(:title, :body, :published)
    end
end
```

นี่คือตัวอย่างของบันทึกที่สร้างขึ้นเมื่อดำเนินการของตัวควบคุมนี้ถูกเรียกใช้:

```
Started POST "/articles" for 127.0.0.1 at 2018-10-18 20:09:23 -0400
Processing by ArticlesController#create as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"XLveDrKzF1SwaiNRPTaMtkrsTzedtebPPkmxEFIU0ordLjICSnXsSNfrdMa4ccyBjuGwnnEiQhEoMN6H1Gtz3A==", "article"=>{"title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>"0"}, "commit"=>"Create Article"}
บทความใหม่: {"id"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>false, "created_at"=>nil, "updated_at"=>nil}
บทความควรถูกต้อง: true
   (0.0ms)  begin transaction
  ↳ app/controllers/articles_controller.rb:31
  Article Create (0.5ms)  INSERT INTO "articles" ("title", "body", "published", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["title", "Debugging Rails"], ["body", "I'm learning how to print in logs."], ["published", 0], ["created_at", "2018-10-19 00:09:23.216549"], ["updated_at", "2018-10-19 00:09:23.216549"]]
  ↳ app/controllers/articles_controller.rb:31
   (2.3ms)  commit transaction
  ↳ app/controllers/articles_controller.rb:31
บทความถูกบันทึกและผู้ใช้จะถูกเปลี่ยนเส้นทาง...
Redirected to http://localhost:3000/articles/1
Completed 302 Found in 4ms (ActiveRecord: 0.8ms)
```

การเพิ่มการบันทึกเพิ่มเติมเช่นนี้ทำให้ง่ายต่อการค้นหาพฤติกรรมที่ไม่คาดคิดหรือผิดปกติในบันทึกของคุณ หากคุณเพิ่มการบันทึกเพิ่มเติม โปรดใช้ระดับการบันทึกที่มีเหตุผลเพื่อหลีกเลี่ยงการเต็มบันทึกการใช้งานในสภาพแวดล้อมการใช้งานจริง

### บันทึกการค้นหาอย่างละเอียด

เมื่อดูผลลัพธ์การค้นหาฐานข้อมูลในบันทึก อาจไม่เป็นทันทีที่จะเห็นว่าทำไมมีการเรียกใช้งานฐานข้อมูลหลายครั้งเมื่อเรียกใช้งานเพียงเมธอดเดียว:

```
irb(main):001:0> Article.pamplemousse
  Article Load (0.4ms)  SELECT "articles".* FROM "articles"
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```
หลังจากการรัน `ActiveRecord.verbose_query_logs = true` ในเซสชัน `bin/rails console` เพื่อเปิดใช้งาน verbose query logs และรันเมธอดอีกครั้ง จะเห็นว่ามีบรรทัดโค้ดเดียวที่สร้างการเรียกใช้ฐานข้อมูลแยกต่างหากเหล่านี้:

```
irb(main):003:0> Article.pamplemousse
  Article Load (0.2ms)  SELECT "articles".* FROM "articles"
  ↳ app/models/article.rb:5
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
  ↳ app/models/article.rb:6
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

ด้านล่างของแต่ละคำสั่งฐานข้อมูล คุณสามารถเห็นลูกศรชี้ไปที่ชื่อไฟล์และหมายเลขบรรทัดของเมธอดที่สร้างการเรียกใช้ฐานข้อมูล สิ่งนี้ช่วยให้คุณสามารถระบุและแก้ไขปัญหาประสิทธิภาพที่เกิดจากการเรียกใช้คำสั่ง N+1 queries: คำสั่งฐานข้อมูลเดียวที่สร้างคำสั่งเพิ่มเติมหลายคำสั่ง

Verbose query logs ถูกเปิดใช้งานโดยค่าเริ่มต้นในแฟ้มบันทึกสภาพแวดล้อมการพัฒนาหลังจาก Rails 5.2

คำเตือน: เราขอแนะนำให้ไม่ใช้การตั้งค่านี้ในสภาพแวดล้อมการใช้งานจริง มันขึ้นอยู่กับเมธอด `Kernel#caller` ของ Ruby ซึ่งมักจะจัดสรรหน่วยความจำมากเพื่อสร้าง stacktraces ของการเรียกเมธอด ใช้ query log tags (ดูด้านล่าง) แทน

### Verbose Enqueue Logs

คล้ายกับ "Verbose Query Logs" ด้านบน ช่วยให้พิมพ์ตำแหน่งแหล่งที่มาของเมธอดที่เก็บงานพื้นหลัง

มันถูกเปิดใช้งานโดยค่าเริ่มต้นในสภาพแวดล้อมการพัฒนา ในการเปิดใช้งานในสภาพแวดล้อมอื่น ๆ เพิ่มใน `application.rb` หรือในตัวกำหนดสภาพแวดล้อมใด ๆ:

```rb
config.active_job.verbose_enqueue_logs = true
```

เช่นเดียวกับ verbose query logs ไม่แนะนำให้ใช้ในสภาพแวดล้อมการใช้งานจริง

ความคิดเห็นของคำสั่ง SQL
------------------

คำสั่ง SQL สามารถใส่ความคิดเห็นด้วยแท็กที่มีข้อมูลเวลาการทำงาน เช่นชื่อคอนโทรลเลอร์หรืองาน เพื่อติดตามคำสั่งที่ทำงานได้ยากกับพื้นที่ของแอปพลิเคชันที่สร้างคำสั่งเหล่านี้ สิ่งนี้มีประโยชน์เมื่อคุณกำลังบันทึกคำสั่งช้า (เช่น [MySQL](https://dev.mysql.com/doc/refman/en/slow-query-log.html), [PostgreSQL](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT)), ดูคำสั่งที่กำลังทำงานอยู่ในปัจจุบัน หรือสำหรับเครื่องมือติดตามที่สามารถติดตามได้จากจุดเริ่มต้นถึงจุดสิ้นสุด
ในการเปิดใช้งานให้เพิ่มใน `application.rb` หรือในตัวกำหนด environment ใดก็ได้:

```rb
config.active_record.query_log_tags_enabled = true
```

ตามค่าเริ่มต้นชื่อของแอปพลิเคชัน ชื่อและการกระทำของคอนโทรลเลอร์ หรือชื่องานจะถูกบันทึกไว้ รูปแบบเริ่มต้นคือ [SQLCommenter](https://open-telemetry.github.io/opentelemetry-sqlcommenter/) ตัวอย่างเช่น:

```
Article Load (0.2ms)  SELECT "articles".* FROM "articles" /*application='Blog',controller='articles',action='index'*/

Article Update (0.3ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ? WHERE "posts"."id" = ? /*application='Blog',job='ImproveTitleJob'*/  [["title", "Improved Rails debugging guide"], ["updated_at", "2022-10-16 20:25:40.091371"], ["id", 1]]
```

พฤติกรรมของ [`ActiveRecord::QueryLogs`](https://api.rubyonrails.org/classes/ActiveRecord/QueryLogs.html) สามารถปรับเปลี่ยนได้เพื่อรวมอะไรก็ตามที่ช่วยเชื่อมต่อจากคำสั่ง SQL เช่น รหัสคำขอและงานสำหรับบันทึกแอปพลิเคชัน บัญชีและตัวระบุผู้เช่า เป็นต้น

### การล็อกแท็ก

เมื่อเรียกใช้งานแอปพลิเคชันที่มีผู้ใช้หลายคนและมีบัญชีหลายบัญชี มักจะมีประโยชน์ที่จะสามารถกรองบันทึกโดยใช้กฎที่กำหนดเองได้ `TaggedLogging` ใน Active Support ช่วยให้คุณทำเช่นนั้นได้โดยการประทับตราบันทึกด้วยโดเมนย่อย รหัสคำขอ และอื่น ๆ เพื่อช่วยในการแก้ปัญหาแอปพลิเคชันเช่นนี้

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # บันทึก "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # บันทึก "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # บันทึก "[BCX] [Jason] Stuff"
```

### ผลกระทบของบันทึกต่อประสิทธิภาพ

การล็อกจะมีผลกระทบต่อประสิทธิภาพของแอปพลิเคชัน Rails ของคุณเสมอ โดยเฉพาะเมื่อทำการล็อกลงดิสก์ นอกจากนี้ยังมีบางประเด็นที่ซับซ้อน:

การใช้ระดับ `:debug` จะมีผลกระทบต่อประสิทธิภาพมากกว่า `:fatal` เนื่องจากจำนวนสตริงที่ถูกประเมินและเขียนลงในเอาต์พุตบันทึกมากกว่า (เช่นดิสก์)

อีกหนึ่งข้อผิดพลาดที่เป็นไปได้คือการเรียกใช้ `Logger` มากเกินไปในโค้ดของคุณ:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

ในตัวอย่างข้างต้น จะมีผลกระทบต่อประสิทธิภาพแม้ว่าระดับเอาต์พุตที่อนุญาตจะไม่รวมถึงการแสดงผลของ debug สาเหตุคือ Ruby ต้องประเมินสตริงเหล่านี้ซึ่งรวมถึงการสร้างอ็อบเจ็กต์ `String` ที่มีน้ำหนักที่ค่อนข้างมากและการตัดคำตัวแปร
ดังนั้น แนะนำให้ส่งบล็อกไปยังเมธอดของ logger เนื่องจากบล็อกเหล่านี้จะถูกประเมินเฉพาะเมื่อระดับเอาต์พุตเป็นระดับเดียวกันหรือรวมอยู่ในระดับที่อนุญาต (เช่น lazy loading) โค้ดที่เขียนใหม่จะเป็นดังนี้:

```ruby
logger.debug { "Person attributes hash: #{@person.attributes.inspect}" }
```

เนื้อหาในบล็อกและตัวแทรกสตริงจะถูกประเมินเฉพาะเมื่อเปิดใช้งานโหมด debug การประหยัดประสิทธิภาพเหล่านี้จะเป็นที่สังเกตได้จริงเมื่อมีการเขียนบันทึกจำนวนมาก แต่เป็นการปฏิบัติที่ดีในการใช้งาน

ข้อมูลเพิ่มเติม: ส่วนนี้ถูกเขียนโดย [Jon Cairns ในคำตอบของ Stack Overflow](https://stackoverflow.com/questions/16546730/logging-in-rails-is-there-any-performance-hit/16546935#16546935) และได้รับอนุญาตภายใต้ [cc by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

การดีบักด้วยตัวแก้ไข `debug` 
------------------------------

เมื่อโค้ดของคุณทำงานอย่างไม่คาดคิด คุณสามารถลองพิมพ์ลงในบันทึกหรือคอนโซลเพื่อวินิจฉัยปัญหา แต่เสียดายที่มีเวลาที่วิธีการติดตามข้อผิดพลาดเช่นนี้ไม่ได้เป็นประสิทธิภาพในการค้นหาสาเหตุหลักของปัญหา ตอนที่คุณจริงๆ ต้องการเดินทางไปยังโค้ดต้นฉบับที่กำลังทำงาน ตัวแก้ไขเป็นเพื่อนร่วมทางที่ดีที่สุดของคุณ

ตัวแก้ไขยังสามารถช่วยคุณได้หากคุณต้องการเรียนรู้เกี่ยวกับโค้ดต้นฉบับของ Rails แต่ไม่รู้จะเริ่มต้นที่ไหน เพียงแค่ดีบักใดก็ได้ในแอปพลิเคชันของคุณและใช้คู่มือนี้เพื่อเรียนรู้วิธีการเคลื่อนย้ายจากโค้ดที่คุณเขียนไปยังโค้ดต้นฉบับของ Rails

Rails 7 รวมถึงแพ็กเกจ `debug` ใน `Gemfile` ของแอปพลิเคชันใหม่ที่สร้างขึ้นโดย CRuby โดยค่าเริ่มต้น มันพร้อมใช้งานในสภาพแวดล้อม `development` และ `test` โปรดตรวจสอบ [เอกสาร](https://github.com/ruby/debug) สำหรับวิธีการใช้งาน

### เข้าสู่เซสชันการดีบัก

ตามค่าเริ่มต้น เซสชันการดีบักจะเริ่มต้นหลังจากที่ไลบรารี `debug` ถูกต้อง ซึ่งเกิดขึ้นเมื่อแอปของคุณเริ่มทำงาน แต่ไม่ต้องกังวล เซสชันจะไม่มีผลต่อแอปพลิเคชันของคุณ

ในการเข้าสู่เซสชันการดีบัก คุณสามารถใช้ `binding.break` และตัวแปรย่อของมันได้: `binding.b` และ `debugger` ตัวอย่างต่อไปนี้จะใช้ `debugger`:
```rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    debugger
  end
  # ...
end
```

เมื่อแอปของคุณประเมินคำสั่งการแก้จุดบกพร่อง จะเข้าสู่เซสชันการแก้จุดบกพร่อง:

```rb
Processing by PostsController#index as HTML
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg)
```

คุณสามารถออกจากเซสชันการแก้จุดบกพร่องได้ทุกเมื่อและดำเนินการดำเนินการในแอปของคุณต่อด้วยคำสั่ง `continue` (หรือ `c`) หรือหากต้องการออกจากทั้งเซสชันการแก้จุดบกพร่องและแอปของคุณให้ใช้คำสั่ง `quit` (หรือ `q`)

### บริบท

หลังจากเข้าสู่เซสชันการแก้จุดบกพร่อง คุณสามารถพิมพ์รหัส Ruby เหมือนกับคุณอยู่ในคอนโซล Rails หรือ IRB

```rb
(rdbg) @posts    # ruby
[]
(rdbg) self
#<PostsController:0x0000000000aeb0>
(rdbg)
```

คุณยังสามารถใช้คำสั่ง `p` หรือ `pp` เพื่อประเมินนิพจน์ Ruby ซึ่งเป็นประโยชน์เมื่อชื่อตัวแปรขัดแย้งกับคำสั่งของตัวแก้จุดบกพร่อง

```rb
(rdbg) p headers    # command
=> {"X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "X-Download-Options"=>"noopen", "X-Permitted-Cross-Domain-Policies"=>"none", "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg) pp headers    # command
{"X-Frame-Options"=>"SAMEORIGIN",
 "X-XSS-Protection"=>"1; mode=block",
 "X-Content-Type-Options"=>"nosniff",
 "X-Download-Options"=>"noopen",
 "X-Permitted-Cross-Domain-Policies"=>"none",
 "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg)
```

นอกจากการประเมินโดยตรงแล้ว เครื่องมือแก้จุดบกพร่องยังช่วยคุณรวบรวมข้อมูลที่หลากหลายได้ผ่านคำสั่งต่าง ๆ เช่น:

- `info` (หรือ `i`) - ข้อมูลเกี่ยวกับเฟรมปัจจุบัน
- `backtrace` (หรือ `bt`) - Backtrace (พร้อมข้อมูลเพิ่มเติม)
- `outline` (หรือ `o`, `ls`) - วิธีการที่มีอยู่ ค่าคงที่ ตัวแปรท้องถิ่น และตัวแปรสถานการณ์ปัจจุบัน
```rb
(rdbg) info    # คำสั่ง
%self = #<PostsController:0x0000000000af78>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fd91a037e38 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fd91a03ea08 @mon_data=#<Monitor:0x00007fd91a03e8c8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = []
@rendered_format = nil
```

#### คำสั่ง `backtrace`

เมื่อใช้โดยไม่มีตัวเลือกใด ๆ `backtrace` จะแสดงรายการของเฟรมทั้งหมดในสแต็ก:

```rb
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  #2    AbstractController::Base#process_action(method_name="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/base.rb:214
  #3    ActionController::Rendering#process_action(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/rendering.rb:53
  #4    block in process_action at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/callbacks.rb:221
  #5    block in run_callbacks at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:118
  #6    ActionText::Rendering::ClassMethods#with_renderer(renderer=#<PostsController:0x0000000000af78>) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/rendering.rb:20
  #7    block {|controller=#<PostsController:0x0000000000af78>, action=#<Proc:0x00007fd91985f1c0 /Users/st0012/...|} in <class:Engine> (4 levels) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/engine.rb:69
  #8    [C] BasicObject#instance_exec at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:127
  ..... และอื่น ๆ
```

ทุกเฟรมมาพร้อมกับ:

- ตัวระบุเฟรม
- ตำแหน่งการเรียก
- ข้อมูลเพิ่มเติม (เช่นอาร์กิวเมนต์ของบล็อกหรือเมธอด)

สิ่งนี้จะช่วยให้คุณเข้าใจได้ดีเกี่ยวกับสิ่งที่เกิดขึ้นในแอปของคุณ อย่างไรก็ตาม คุณอาจสังเกตเห็นว่า:

- มีเฟรมมากเกินไป (โดยปกติจะมีมากกว่า 50 เฟรมในแอป Rails)
- เฟรมส่วนใหญ่เป็นของ Rails หรือไลบรารีอื่น ๆ ที่คุณใช้

คำสั่ง `backtrace` มีตัวเลือก 2 ตัวเพื่อช่วยคุณกรองเฟรม:

- `backtrace [num]` - แสดงเฟรมจำนวน `num` เฟรมเท่านั้น เช่น `backtrace 10` .
- `backtrace /pattern/` - แสดงเฟรมที่มีตัวระบุหรือตำแหน่งที่ตรงกับแพทเทิร์น เช่น `backtrace /MyModel/` .

ยังสามารถใช้ตัวเลือกเหล่านี้ร่วมกันได้: `backtrace [num] /pattern/` .

#### คำสั่ง `outline`

`outline` คล้ายกับคำสั่ง `ls` ใน `pry` และ `irb` โดยจะแสดงสิ่งที่สามารถเข้าถึงได้จากขอบเขตปัจจุบัน รวมถึง:

- ตัวแปรท้องถิ่น
- ตัวแปรอินสแตนซ์
- ตัวแปรคลาส
- เมธอดและแหล่งที่มาของเมธอด

```rb
ActiveSupport::Configurable#methods: config
AbstractController::Base#methods:
  action_methods  action_name  action_name=  available_action?  controller_path  inspect
  response_body
ActionController::Metal#methods:
  content_type       content_type=  controller_name  dispatch          headers
  location           location=      media_type       middleware_stack  middleware_stack=
  middleware_stack?  performed?     request          request=          reset_session
  response           response=      response_body=   response_code     session
  set_request!       set_response!  status           status=           to_a
ActionView::ViewPaths#methods:
  _prefixes  any_templates?  append_view_path   details_for_lookup  formats     formats=  locale
  locale=    lookup_context  prepend_view_path  template_exists?    view_paths
AbstractController::Rendering#methods: view_assigns

# .....

PostsController#methods: create  destroy  edit  index  new  show  update
instance variables:
  @_action_has_layout  @_action_name    @_config  @_lookup_context                      @_request
  @_response           @_response_body  @_routes  @marked_for_same_origin_verification  @posts
  @rendered_format
class variables: @@raise_on_missing_translations  @@raise_on_open_redirects
```
### จุดพัก

มีหลายวิธีในการแทรกและเรียกใช้จุดพักในตัวตรวจสอบข้อผิดพลาด นอกจากการเพิ่มคำสั่งตรวจสอบข้อผิดพลาด (เช่น `debugger`) โดยตรงในโค้ดของคุณ คุณยังสามารถแทรกจุดพักด้วยคำสั่งต่อไปนี้:

- `break` (หรือ `b`)
  - `break` - แสดงรายการจุดพักทั้งหมด
  - `break <num>` - ตั้งจุดพักในบรรทัด `num` ของไฟล์ปัจจุบัน
  - `break <file:num>` - ตั้งจุดพักในบรรทัด `num` ของ `file`
  - `break <Class#method>` หรือ `break <Class.method>` - ตั้งจุดพักใน `Class#method` หรือ `Class.method`
  - `break <expr>.<method>` - ตั้งจุดพักในเมธอด `<method>` ของผลลัพธ์ของ `<expr>`
- `catch <Exception>` - ตั้งจุดพักที่จะหยุดเมื่อเกิด `Exception`
- `watch <@ivar>` - ตั้งจุดพักที่จะหยุดเมื่อผลลัพธ์ของ `@ivar` ของออบเจกต์ปัจจุบันเปลี่ยนแปลง (การดำเนินการนี้จะช้า)

และในการลบจุดพัก คุณสามารถใช้:

- `delete` (หรือ `del`)
  - `delete` - ลบจุดพักทั้งหมด
  - `delete <num>` - ลบจุดพักที่มี id เป็น `num`

#### คำสั่ง `break`

**ตั้งจุดพักในหมายเลขบรรทัดที่ระบุ - เช่น `b 28`**

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # และ 72 frames (ใช้คำสั่ง `bt' เพื่อดูเฟรมทั้งหมด)
(rdbg) b 28    # คำสั่ง break
#0  BP - Line  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (line)
```

```rb
(rdbg) c    # คำสั่ง continue
[23, 32] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    23|   def create
    24|     @post = Post.new(post_params)
    25|     debugger
    26|
    27|     respond_to do |format|
=>  28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
    30|         format.json { render :show, status: :created, location: @post }
    31|       else
    32|         format.html { render :new, status: :unprocessable_entity }
=>#0    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  #1    ActionController::MimeResponds#respond_to(mimes=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/mime_responds.rb:205
  # และ 74 frames (ใช้คำสั่ง `bt' เพื่อดูเฟรมทั้งหมด)

หยุดที่ #0  BP - Line  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (line)
```
ตั้งจุดพักที่การเรียกใช้เมธอดที่กำหนด - เช่น `b @post.save`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # และ 72 frames (ใช้คำสั่ง `bt' เพื่อดูเฟรมทั้งหมด)
(rdbg) b @post.save    # คำสั่ง break
#0  BP - Method  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43

```

```rb
(rdbg) c    # คำสั่ง continue
[39, 48] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb
    39|         SuppressorRegistry.suppressed[name] = previous_state
    40|       end
    41|     end
    42|
    43|     def save(**) # :nodoc:
=>  44|       SuppressorRegistry.suppressed[self.class.name] ? true : super
    45|     end
    46|
    47|     def save!(**) # :nodoc:
    48|       SuppressorRegistry.suppressed[self.class.name] ? true : super
=>#0    ActiveRecord::Suppressor#save(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:44
  #1    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  # และ 75 frames (ใช้คำสั่ง `bt' เพื่อดูเฟรมทั้งหมด)

หยุดที่ #0  BP - Method  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43
```

#### คำสั่ง `catch`

หยุดเมื่อเกิดข้อผิดพลาด - เช่น `catch ActiveRecord::RecordInvalid`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # และ 72 frames (ใช้คำสั่ง `bt' เพื่อดูเฟรมทั้งหมด)
(rdbg) catch ActiveRecord::RecordInvalid    # คำสั่ง
#1  BP - Catch  "ActiveRecord::RecordInvalid"
```

```rb
(rdbg) c    # คำสั่ง continue
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # และ 88 frames (ใช้คำสั่ง `bt' เพื่อดูเฟรมทั้งหมด)

หยุดที่ #1  BP - Catch  "ActiveRecord::RecordInvalid"
#### คำสั่ง `watch`

หยุดเมื่อตัวแปร instance ถูกเปลี่ยนแปลง - เช่น `watch @_response_body`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # และ 72 frames (ใช้คำสั่ง `bt' เพื่อดูเฟรมทั้งหมด)
(rdbg) watch @_response_body    # คำสั่ง
#0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =
```

```rb
(rdbg) c    # คำสั่ง continue
[173, 182] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb
   173|       body = [body] unless body.nil? || body.respond_to?(:each)
   174|       response.reset_body!
   175|       return unless body
   176|       response.body = body
   177|       super
=> 178|     end
   179|
   180|     # Tests if render or redirect has already happened.
   181|     def performed?
   182|       response_body || response.committed?
=>#0    ActionController::Metal#response_body=(body=["<html><body>You are being <a href=\"ht...) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb:178 #=> ["<html><body>You are being <a href=\"ht...
  #1    ActionController::Redirecting#redirect_to(options=#<Post id: 13, title: "qweqwe", content:..., response_options={:allow_other_host=>false}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/redirecting.rb:74
  # และ 82 frames (ใช้คำสั่ง `bt' เพื่อดูเฟรมทั้งหมด)

หยุดที่ #0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =  -> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
(rdbg)
```

#### ตัวเลือกของจุดหยุด

นอกจากจุดหยุดประเภทต่าง ๆ คุณยังสามารถระบุตัวเลือกเพื่อให้ได้รับการดีบักที่มีขั้นตอนการดีบักที่ซับซ้อนมากขึ้นได้อีกด้วย ในปัจจุบัน ตัวดีบักรองรับตัวเลือก 4 อย่างดังนี้:

- `do: <cmd หรือ expr>` - เมื่อจุดหยุดถูกเรียกใช้ ดำเนินการคำสั่ง/นิพจน์ที่กำหนดและดำเนินการต่อโปรแกรม:
  - `break Foo#bar do: bt` - เมื่อมีการเรียกใช้ `Foo#bar` พิมพ์เฟรมสแต็ก
- `pre: <cmd หรือ expr>` - เมื่อจุดหยุดถูกเรียกใช้ ดำเนินการคำสั่ง/นิพจน์ที่กำหนดก่อนหยุด:
  - `break Foo#bar pre: info` - เมื่อมีการเรียกใช้ `Foo#bar` พิมพ์ตัวแปรที่อยู่รอบข้างก่อนหยุด
- `if: <expr>` - จุดหยุดเพียงหยุดเมื่อผลลัพธ์ของ `<expr>` เป็นจริง:
  - `break Post#save if: params[:debug]` - หยุดที่ `Post#save` ถ้า `params[:debug]` เป็นจริงเช่นกัน
- `path: <path_regexp>` - จุดหยุดเพียงหยุดเมื่อเกิดเหตุการณ์ที่เรียกใช้มัน (เช่นการเรียกเมธอด) จากเส้นทางที่กำหนด:
  - `break Post#save if: app/services/a_service` - หยุดที่ `Post#save` ถ้าการเรียกเมธอดเกิดขึ้นที่เมธอดที่ตรงกับรูปแบบเรกเซ็กซ์ Ruby `/app\/services\/a_service/`.
โปรดทราบว่าตัวเลือก 3 ตัวแรก: `do:`, `pre:` และ `if:` ก็มีให้ใช้กับคำสั่ง debug ที่เรากล่าวถึงก่อนหน้านี้ด้วย ตัวอย่างเช่น:

```rb
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger(do: "info")
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # และ 72 frames (ใช้คำสั่ง `bt' เพื่อดูเฟรมทั้งหมด)
(rdbg:binding.break) info
%self = #<PostsController:0x00000000017480>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fce3ad336b8 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fce3ad397e8 @mon_data=#<Monitor:0x00007fce3ad396a8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = #<ActiveRecord::Relation [#<Post id: 2, title: "qweqwe", content: "qweqwe", created_at: "...
@rendered_format = nil
```

#### โปรแกรมของคุณ Debugging Workflow

ด้วยตัวเลือกเหล่านั้น คุณสามารถสร้างสคริปต์ของขั้นตอนการ Debugging ได้ในบรรทัดเดียวเช่น:

```rb
def create
  debugger(do: "catch ActiveRecord::RecordInvalid do: bt 10")
  # ...
end
```

แล้วตัว debugger จะเรียกใช้คำสั่งสคริปต์และแทรกจุดพักที่ catch

```rb
(rdbg:binding.break) catch ActiveRecord::RecordInvalid do: bt 10
#0  BP - Catch  "ActiveRecord::RecordInvalid"
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # และ 88 frames (ใช้คำสั่ง `bt' เพื่อดูเฟรมทั้งหมด)
```

เมื่อจุดพัก catch ถูกเรียกใช้ จะพิมพ์เฟรมสแต็กออกมา

```rb
Stop by #0  BP - Catch  "ActiveRecord::RecordInvalid"

(rdbg:catch) bt 10
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  #2    block in save! at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/transactions.rb:302
```

เทคนิคนี้สามารถช่วยประหยัดเวลาจากการป้อนข้อมูลซ้ำซ้อนและทำให้ประสบการณ์ในการ Debugging นั้นราบรื่นขึ้น
คุณสามารถค้นหาคำสั่งและตัวเลือกการกำหนดค่าเพิ่มเติมได้จาก[เอกสารประกอบ](https://github.com/ruby/debug)ของมัน

การดีบักด้วย `web-console` Gem
------------------------------------

Web Console เป็นเหมือน `debug` แต่มันทำงานในเบราว์เซอร์ คุณสามารถขอคอนโซลในบริบทของวิวหรือคอนโทรลเลอร์บนหน้าเว็บใดก็ได้ คอนโซลจะถูกแสดงข้างๆเนื้อหา HTML ของคุณ

### คอนโซล

ภายในแอ็คชันคอนโทรลเลอร์หรือวิวใดๆ คุณสามารถเรียกใช้คอนโซลโดยเรียกใช้เมธอด `console`

ตัวอย่างเช่นในคอนโทรลเลอร์:

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

หรือในวิว:

```html+erb
<% console %>

<h2>New Post</h2>
```

นี้จะแสดงคอนโซลภายในวิวของคุณ คุณไม่จำเป็นต้องสนใจถึงตำแหน่งของการเรียก `console` มันจะไม่ถูกแสดงในจุดที่เรียกใช้ของมัน แต่จะอยู่ข้างๆเนื้อหา HTML ของคุณ

คอนโซลทำงานโดยการประมวลผลโค้ด Ruby สะอาด: คุณสามารถกำหนดคลาสที่กำหนดเองและสร้างอินสแตนซ์ สร้างโมเดลใหม่ และตรวจสอบตัวแปรได้

หมายเหตุ: สามารถแสดงคอนโซลได้เพียงหนึ่งครั้งต่อคำขอ มิเช่นนั้น `web-console` จะเรียกข้อผิดพลาดในการเรียกใช้ `console` ครั้งที่สอง

### การตรวจสอบตัวแปร

คุณสามารถเรียกใช้ `instance_variables` เพื่อแสดงรายการตัวแปรอินสแตนซ์ทั้งหมดที่มีในบริบทของคุณ หากคุณต้องการแสดงรายการตัวแปรโลคอลทั้งหมด คุณสามารถทำได้ด้วย `local_variables`

### การตั้งค่า

* `config.web_console.allowed_ips`: รายการที่ได้รับอนุญาตของที่อยู่ IP และเครือข่าย IPv4 หรือ IPv6 (ค่าเริ่มต้น: `127.0.0.1/8, ::1`).
* `config.web_console.whiny_requests`: บันทึกข้อความเมื่อการแสดงคอนโซลถูกป้องกัน (ค่าเริ่มต้น: `true`).

เนื่องจาก `web-console` ประเมินโค้ด Ruby แบบเรียบง่ายระยะไกลบนเซิร์ฟเวอร์ โปรดอย่าพยายามใช้ในการดำเนินการ

การดีบักการรั่วหน่วยความจำ
----------------------

แอปพลิเคชัน Ruby (บน Rails หรือไม่ก็ตาม) อาจรั่วหน่วยความจำ - ไม่ว่าจะเป็นในโค้ด Ruby หรือระดับโค้ด C

ในส่วนนี้คุณจะเรียนรู้วิธีการค้นหาและแก้ไขการรั่วหน่วยความจำเช่นนั้นโดยใช้เครื่องมือเช่น Valgrind
### Valgrind

[Valgrind](http://valgrind.org/) เป็นแอปพลิเคชันที่ใช้สำหรับตรวจหาการรั่วไหลของหน่วยความจำและเงื่อนไขการแข่งขันในภาษา C

มีเครื่องมือใน Valgrind ที่สามารถตรวจหาข้อผิดพลาดในการจัดการหน่วยความจำและการเขียนโปรแกรมแบบเธรดได้อัตโนมัติ ตัวอย่างเช่น หาก C extension ในตัวแปรแปลงภาษาเรียกใช้ `malloc()` แต่ไม่เรียกใช้ `free()` อย่างถูกต้อง หน่วยความจำนี้จะไม่สามารถใช้งานได้จนกว่าแอปพลิเคชันจะสิ้นสุดการทำงาน

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับวิธีการติดตั้ง Valgrind และใช้งานกับ Ruby โปรดอ่าน [Valgrind and Ruby](https://blog.evanweaver.com/2008/02/05/valgrind-and-ruby/) โดย Evan Weaver

### ค้นหาการรั่วไหลของหน่วยความจำ

มีบทความที่ยอดเยี่ยมเกี่ยวกับการตรวจหาและแก้ไขการรั่วไหลของหน่วยความจำที่ Derailed ซึ่งคุณสามารถอ่านได้ที่นี่ [คลิกที่นี่](https://github.com/schneems/derailed_benchmarks#is-my-app-leaking-memory)

ปลั๊กอินสำหรับการดีบัก
---------------------

มีปลั๊กอินของ Rails ที่ช่วยให้คุณค้นหาข้อผิดพลาดและดีบักในแอปพลิเคชันของคุณ นี่คือรายการของปลั๊กอินที่มีประโยชน์สำหรับการดีบัก:

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master) เพิ่มการติดตามต้นกำเนิดของคำสั่งในบันทึกของคุณ
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master) ให้วัตถุเมลเลอร์และเทมเพลตเริ่มต้นสำหรับการส่งการแจ้งเตือนทางอีเมลเมื่อเกิดข้อผิดพลาดในแอปพลิเคชัน Rails
* [Better Errors](https://github.com/charliesome/better_errors) แทนที่หน้าข้อผิดพลาดของ Rails ด้วยหน้าใหม่ที่มีข้อมูลบริบทเพิ่มเติม เช่น โค้ดต้นฉบับและการตรวจสอบตัวแปร
* [RailsPanel](https://github.com/dejan/rails_panel) ส่วนขยายของ Chrome สำหรับการพัฒนา Rails ที่จะสิ้นสุดการติดตาม development.log มีข้อมูลทั้งหมดเกี่ยวกับคำขอแอปพลิเคชัน Rails ในเบราว์เซอร์ - ในแผงเครื่องมือนักพัฒนา
* [Pry](https://github.com/pry/pry) ตัวเลือก IRB และคอนโซลนักพัฒนารันไทม์

อ้างอิง
----------

* [เว็บคอนโซล Homepage](https://github.com/rails/web-console)
* [หน้าหลักของ debug](https://github.com/ruby/debug)
