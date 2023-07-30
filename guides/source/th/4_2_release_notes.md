**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4d8311a1435138a81e26a7e8f537dbde
เนื้อหาสำคัญใน Rails 4.2:
==============

* Active Job
* การส่งอีเมลแบบไม่เชื่อมต่อ
* Adequate Record
* Web Console
* การสนับสนุน Foreign key

เอกสารเวอร์ชันนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับคุณลักษณะอื่น ๆ การแก้ไขข้อบกพร่อง และการเปลี่ยนแปลง โปรดอ้างอิงที่เอกสารเปลี่ยนแปลงหรือตรวจสอบ [รายการคอมมิต](https://github.com/rails/rails/commits/4-2-stable) ในเรพอสิทอรี Rails หลักบน GitHub

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 4.2
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 4.1 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเกรดไปเป็น Rails 4.2 มีรายการสิ่งที่ควรระวังเมื่ออัปเกรดในเอกสาร [การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2)

คุณลักษณะหลัก
--------------

### Active Job

Active Job เป็นเฟรมเวิร์กใหม่ใน Rails 4.2 มันเป็นอินเตอร์เฟสที่ร่วมกันบนระบบคิวเช่น [Resque](https://github.com/resque/resque), [Delayed
Job](https://github.com/collectiveidea/delayed_job),
[Sidekiq](https://github.com/mperham/sidekiq), และอื่น ๆ

งานที่เขียนด้วย Active Job API ทำงานบนคิวที่รองรับได้ทั้งหมดด้วยตัวอัพเดตของตัวเอง  Active Job มาพร้อมกับตัวรันอินไลน์ที่ทำงานงานทันที

งานบ่อยครั้งต้องการใช้วัตถุ Active Record เป็นอาร์กิวเมนต์ Active Job ส่งอ้างอิงวัตถุเป็น URI (uniform resource identifiers) แทนที่จะทำการมาร์ชล์วัตถุเอง ไลบรารีใหม่ [Global ID](https://github.com/rails/globalid) สร้าง URI และค้นหาวัตถุที่อ้างถึง การส่งอาร์กิวเมนต์วัตถุ Active Record ใช้งานได้ง่ายโดยใช้ Global ID ภายใน

ตัวอย่างเช่น หาก `trashable` เป็นออบเจ็กต์ Active Record แล้วงานนี้ทำงานได้อย่างถูกต้องโดยไม่ต้องมีการซีรีส์ไลซ์:

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

ดูเอกสาร [Active Job Basics](active_job_basics.html) สำหรับข้อมูลเพิ่มเติม

### การส่งอีเมลแบบไม่เชื่อมต่อ

โดยอาศัย Active Job, Action Mailer มาพร้อมกับเมธอด `deliver_later` ที่ส่งอีเมลผ่านคิว ดังนั้นจึงไม่บล็อกคอนโทรลเลอร์หรือโมเดลหากคิวเป็นแบบไม่เชื่อมต่อ (คิวอินไลน์เริ่มต้นบล็อก)
การส่งอีเมลได้ทันทียังคงเป็นไปได้ด้วย `deliver_now`.

### Adequate Record

Adequate Record เป็นชุดการปรับปรุงประสิทธิภาพใน Active Record ที่ทำให้การเรียกใช้ `find` และ `find_by` ทั่วไปและการค้นหาข้อมูลที่เกี่ยวข้องบางประเภทเร็วขึ้นสูงสุดถึง 2 เท่า

มันทำงานโดยการเก็บคำสั่ง SQL ที่ใช้บ่อยเป็น prepared statements และนำมาใช้ซ้ำในการเรียกใช้ที่คล้ายกัน โดยข้ามการสร้างคำสั่ง query ในการเรียกใช้ครั้งถัดไปได้เป็นส่วนใหญ่ สำหรับรายละเอียดเพิ่มเติมโปรดอ่านบทความใน [เว็บไซต์ของ Aaron Patterson](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html).

Active Record จะใช้คุณสมบัตินี้โดยอัตโนมัติในการดำเนินการที่รองรับโดยไม่ต้องมีการเข้ามาเกี่ยวข้องหรือเปลี่ยนแปลงโค้ดของผู้ใช้ ตัวอย่างการดำเนินการที่รองรับคือ:

```ruby
Post.find(1)  # การเรียกใช้ครั้งแรกจะสร้างและเก็บ prepared statement
Post.find(2)  # การเรียกใช้ครั้งถัดไปจะใช้ prepared statement ที่เก็บไว้

Post.find_by_title('first post')
Post.find_by_title('second post')

Post.find_by(title: 'first post')
Post.find_by(title: 'second post')

post.comments
post.comments(true)
```

สำคัญที่จะเน้นว่า ตามที่ตัวอย่างข้างต้นแนะนำ คำสั่ง prepared statements ไม่ได้เก็บค่าที่ถูกส่งผ่านในการเรียกใช้เมธอด แต่มีตัวยึดสำหรับค่าเหล่านั้น

การใช้งานแคชจะไม่ถูกใช้ในสถานการณ์ต่อไปนี้:

- โมเดลมี default scope
- โมเดลใช้ single table inheritance
- `find` พร้อมกับรายการ id, เช่น:

    ```ruby
    # ไม่ได้ถูกแคช
    Post.find(1, 2, 3)
    Post.find([1,2])
    ```

- `find_by` พร้อมกับ SQL fragments:

    ```ruby
    Post.find_by('published_at < ?', 2.weeks.ago)
    ```

### Web Console

แอปพลิเคชันใหม่ที่สร้างด้วย Rails 4.2 มาพร้อมกับ [Web
Console](https://github.com/rails/web-console) gem โดยค่าเริ่มต้น  Web Console เพิ่มคอนโซล Ruby แบบอินเทอร์แอคทีฟลงในทุกหน้าข้อผิดพลาดและให้ความช่วยเหลือด้วย `console` view และ controller helpers

คอนโซลแบบอินเทอร์แอคทีฟในหน้าข้อผิดพลาดช่วยให้คุณสามารถดำเนินการโค้ดในบริบทของสถานที่ที่เกิดข้อยกเว้น ฟังก์ชัน `console` ถ้าถูกเรียกใน view หรือ controller ใด ๆ จะเรียกใช้คอนโซลแบบอินเทอร์แอคทีฟที่มีบริบทสุดท้ายหลังจากการเรนเดอร์เสร็จสมบูรณ์

### การสนับสนุน Foreign Key

Migration DSL ตอนนี้สนับสนุนการเพิ่มและลบ foreign key และถูกดัมป์ไปยัง `schema.rb` ในขณะนี้เฉพาะ adapter `mysql`, `mysql2` และ `postgresql` รองรับ foreign key เท่านั้น
```ruby
# เพิ่ม foreign key ไปยัง `articles.author_id` ที่อ้างอิง `authors.id`
add_foreign_key :articles, :authors

# เพิ่ม foreign key ไปยัง `articles.author_id` ที่อ้างอิง `users.lng_id`
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# ลบ foreign key ที่ `accounts.branch_id`
remove_foreign_key :accounts, :branches

# ลบ foreign key ที่ `accounts.owner_id`
remove_foreign_key :accounts, column: :owner_id
```

ดูเอกสาร API ที่
[add_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)
และ
[remove_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)
สำหรับคำอธิบายเพิ่มเติม


ความไม่เข้ากัน
-----------------

ฟังก์ชันที่ถูกเลิกไว้ก่อนหน้านี้ถูกลบออกแล้ว โปรดอ้างอิงไปยังส่วนประกอบแต่ละส่วนสำหรับการเลิกใช้งานใหม่ในการอัปเกรดนี้

การเปลี่ยนแปลงต่อไปนี้อาจต้องการการดำเนินการทันทีหลังจากอัปเกรด

### `render` ด้วยอาร์กิวเมนต์เป็นสตริง

ก่อนหน้านี้ การเรียกใช้ `render "foo/bar"` ในคอนโทรลเลอร์เป็นเทียบเท่ากับ `render file: "foo/bar"` ใน Rails 4.2 นี้ถูกเปลี่ยนเป็นหมายความว่า `render template: "foo/bar"` แทน หากคุณต้องการเรียกใช้ไฟล์โปรดเปลี่ยนรหัสของคุณให้ใช้รูปแบบชัดเจน (`render file: "foo/bar"`) แทน

### `respond_with` / Class-Level `respond_to`

`respond_with` และ class-level `respond_to` ที่เกี่ยวข้องถูกย้ายไปยัง gem [responders](https://github.com/plataformatec/responders) เพิ่ม `gem 'responders', '~> 2.0'` ใน `Gemfile` เพื่อใช้:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

Instance-level `respond_to` ไม่ได้รับผลกระทบ:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

### Default Host สำหรับ `rails server`

เนื่องจากการเปลี่ยนแปลงใน Rack (https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc) `rails server` ตอนนี้จะฟังก์ชันบน `localhost` แทนที่จะฟังก์ชันบน `0.0.0.0` เริ่มต้น สิ่งนี้ควรมีผลกระทบน้อยต่อกระบวนการพัฒนามาตรฐานเนื่องจากทั้ง http://127.0.0.1:3000 และ http://localhost:3000 จะยังคงทำงานเหมือนเดิมบนเครื่องของคุณเอง

อย่างไรก็ตาม ด้วยการเปลี่ยนแปลงนี้คุณจะไม่สามารถเข้าถึงเซิร์ฟเวอร์ Rails จากเครื่องอื่นได้อีกต่อไป เช่น หากสภาพแวดล้อมการพัฒนาของคุณอยู่ในเครื่องจำลองเสมือนและคุณต้องการเข้าถึงจากเครื่องโฮสต์ ในกรณีเช่นนี้โปรดเริ่มเซิร์ฟเวอร์ด้วย `rails server -b 0.0.0.0` เพื่อเรียกคืนพฤติกรรมเดิม
หากคุณทำเช่นนี้ โปรดตั้งค่าไฟร์วอลล์ของคุณอย่างถูกต้องเพื่อให้เฉพาะเครื่องที่เชื่อถือได้บนเครือข่ายของคุณเท่านั้นที่สามารถเข้าถึงเซิร์ฟเวอร์การพัฒนาของคุณได้

### สัญลักษณ์ตัวเลือกสถานะที่เปลี่ยนไปสำหรับ `render`

เนื่องจากมีการเปลี่ยนแปลงใน Rack (https://github.com/rack/rack/commit/be28c6a2ac152fe4adfbef71f3db9f4200df89e8) สัญลักษณ์ที่เมธอด `render` ยอมรับสำหรับตัวเลือก `:status` ได้เปลี่ยนไปดังนี้:

- 306: `:reserved` ถูกลบออก
- 413: `:request_entity_too_large` ถูกเปลี่ยนชื่อเป็น `:payload_too_large`
- 414: `:request_uri_too_long` ถูกเปลี่ยนชื่อเป็น `:uri_too_long`
- 416: `:requested_range_not_satisfiable` ถูกเปลี่ยนชื่อเป็น `:range_not_satisfiable`

โปรดจำไว้ว่าหากเรียกใช้ `render` ด้วยสัญลักษณ์ที่ไม่รู้จัก สถานะการตอบกลับจะเป็นค่าเริ่มต้นเป็น 500

### HTML Sanitizer

HTML sanitizer ได้ถูกแทนที่ด้วยการสร้างขึ้นใหม่ที่แข็งแกร่งมากขึ้นโดยใช้ [Loofah](https://github.com/flavorjones/loofah) และ [Nokogiri](https://github.com/sparklemotion/nokogiri) สามารถทำการฆ่าเชื้อโรคได้มากขึ้นและการทำความสะอาดของมันมีความแข็งแกร่งและยืดหยุ่นมากขึ้น

เนื่องจากอัลกอริทึมใหม่ ผลลัพธ์ที่ถูกทำความสะอาดอาจแตกต่างกันไปสำหรับข้อมูลที่ผิดปกติบางประการ

หากคุณต้องการผลลัพธ์ที่แน่นอนจากตัวทำความสะอาดเก่าคุณสามารถเพิ่ม gem [rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer) เข้าไปใน `Gemfile` เพื่อให้มีพฤติกรรมเก่า และ gem นี้จะไม่แสดงคำเตือนการเลิกใช้เพราะมันเป็นการเลือกใช้

`rails-deprecated_sanitizer` จะได้รับการสนับสนุนสำหรับ Rails 4.2 เท่านั้น และจะไม่ได้รับการบำรุงรักษาสำหรับ Rails 5.0

ดู [บล็อกโพสต์นี้](https://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/) เพื่อดูรายละเอียดเพิ่มเติมเกี่ยวกับการเปลี่ยนแปลงในตัวทำความสะอาดใหม่

### `assert_select`

`assert_select` ตอนนี้ใช้เป็นพื้นฐานบน [Nokogiri](https://github.com/sparklemotion/nokogiri) ดังนั้น บางตัวเลือกที่เป็นไปได้ก่อนหน้านี้จะไม่ได้รับการสนับสนุนอีกต่อไป หากแอปพลิเคชันของคุณใช้รูปแบบเหล่านี้คุณจะต้องอัปเดต:

*   ค่าในตัวเลือกแอตทริบิวต์อาจต้องใส่เครื่องหมายคำพูดหากมีอักขระที่ไม่ใช่ตัวอักษรและตัวเลข

    ```ruby
    # ก่อนหน้านี้
    a[href=/]
    a[href$=/]

    # ตอนนี้
    a[href="/"]
    a[href$="/"]
    ```

*   DOMs ที่สร้างขึ้นจากแหล่งที่มาของ HTML ที่มี HTML ที่ไม่ถูกต้องที่มีองค์ประกอบที่ไม่ถูกต้องอาจแตกต่างกัน

    ตัวอย่างเช่น:

    ```ruby
    # เนื้อหา: <div><i><p></i></div>

    # ก่อนหน้านี้:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => false
    assert_select('i > p')    # => true

    # ตอนนี้:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => true
    assert_select('i > p')    # => false
    ```
*   หากข้อมูลที่เลือกมี entity อยู่ ค่าที่เลือกสำหรับการเปรียบเทียบที่ใช้เคยเป็น raw (เช่น `AT&amp;T`) และตอนนี้ถูกประเมิน (เช่น `AT&T`)

    ```ruby
    # content: <p>AT&amp;T</p>

    # ก่อน:
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # ตอนนี้:
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

นอกจากนี้การแทนที่ก็มีการเปลี่ยนไปใช้ไวยากรณ์ใหม่

ตอนนี้คุณต้องใช้ตัวเลือก `:match` ที่คล้ายกับ CSS selector:

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

นอกจากนี้การแทนที่ด้วย Regexp จะมีรูปแบบที่แตกต่างเมื่อการตรวจสอบล้มเหลว
สังเกตว่า `/hello/` ที่นี่:

```ruby
assert_select(":match('id', ?)", /hello/)
```

กลายเป็น `"(?-mix:hello)"`:

```
Expected at least 1 element matching "div:match('id', "(?-mix:hello)")", found 0..
Expected 0 to be >= 1.
```

ดูเอกสาร [Rails Dom Testing](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b) เพื่อดูข้อมูลเพิ่มเติมเกี่ยวกับ `assert_select`


Railties
--------

โปรดอ้างอิง [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ตัวเลือก `--skip-action-view` ถูกลบออกจาก app generator ([Pull Request](https://github.com/rails/rails/pull/17042))

*   คำสั่ง `rails application` ถูกลบออกโดยไม่มีการแทนที่ ([Pull Request](https://github.com/rails/rails/pull/11616))

### การเลิกใช้

*   เลิกใช้ `config.log_level` ที่ขาดหายไปสำหรับ production environments ([Pull Request](https://github.com/rails/rails/pull/16622))

*   เลิกใช้ `rake test:all` และใช้ `rake test` แทนเนื่องจากตอนนี้รันทดสอบทั้งหมดในโฟลเดอร์ `test` ([Pull Request](https://github.com/rails/rails/pull/17348))

*   เลิกใช้ `rake test:all:db` และใช้ `rake test:db` แทน ([Pull Request](https://github.com/rails/rails/pull/17348))

*   เลิกใช้ `Rails::Rack::LogTailer` โดยไม่มีการแทนที่ ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม `web-console` ใน `Gemfile` ของแอปพลิเคชันเริ่มต้น ([Pull Request](https://github.com/rails/rails/pull/11667))

*   เพิ่มตัวเลือก `required` ใน generator ของโมเดลสำหรับการสร้างความสัมพันธ์ ([Pull Request](https://github.com/rails/rails/pull/16062))

*   เพิ่มเนมสเปซ `x` สำหรับการกำหนดตัวเลือกการกำหนดค่าที่กำหนดเอง:

    ```ruby
    # config/environments/production.rb
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries  = 3
    config.x.super_debugger              = true
    ```

    ตัวเลือกเหล่านี้จะสามารถใช้ได้ผ่านอ็อบเจกต์การกำหนดค่า:

    ```ruby
    Rails.configuration.x.payment_processing.schedule # => :daily
    Rails.configuration.x.payment_processing.retries  # => 3
    Rails.configuration.x.super_debugger              # => true
    ```

    ([Commit](https://github.com/rails/rails/commit/611849772dd66c2e4d005dcfe153f7ce79a8a7db))

*   เพิ่ม `Rails::Application.config_for` เพื่อโหลดการกำหนดค่าสำหรับ environment ปัจจุบัน

    ```yaml
    # config/exception_notification.yml
    production:
      url: http://127.0.0.1:8080
      namespace: my_app_production
    development:
      url: http://localhost:3001
      namespace: my_app_development
    ```
```ruby
# config/environments/production.rb
Rails.application.configure do
  config.middleware.use ExceptionNotifier, config_for(:exception_notification)
end
```

([Pull Request](https://github.com/rails/rails/pull/16129))

* ในเครื่องมือสร้างแอปเพิ่ม `--skip-turbolinks` option เพื่อไม่สร้างการผสานรวมกับ turbolinks
([Commit](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

* ในการสร้างแอปเพิ่ม `bin/setup` script เป็นสคริปต์ที่ใช้งานอัตโนมัติเมื่อติดตั้งแอปพลิเคชัน
([Pull Request](https://github.com/rails/rails/pull/15189))

* เปลี่ยนค่าเริ่มต้นของ `config.assets.digest` เป็น `true` ในโหมดการพัฒนา
([Pull Request](https://github.com/rails/rails/pull/15155))

* เพิ่ม API เพื่อลงทะเบียนส่วนขยายใหม่สำหรับ `rake notes`
([Pull Request](https://github.com/rails/rails/pull/14379))

* เพิ่ม `after_bundle` callback เพื่อใช้ในเทมเพลตของ Rails
([Pull Request](https://github.com/rails/rails/pull/16359))

* เพิ่ม `Rails.gem_version` เป็นเมธอดที่สะดวกในการส่งคืน `Gem::Version.new(Rails.version)`
([Pull Request](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

โปรดอ้างอิงที่ [Changelog][action-pack] เพื่อดูการเปลี่ยนแปลงอย่างละเอียด

### การลบ

* `respond_with` และ `respond_to` ที่ระดับคลาสถูกลบออกจาก Rails และย้ายไปยัง gem `responders` (เวอร์ชัน 2.0) เพิ่ม `gem 'responders', '~> 2.0'` เข้าไปใน `Gemfile` เพื่อใช้งานคุณสมบัติเหล่านี้ต่อไป
([Pull Request](https://github.com/rails/rails/pull/16526),
 [รายละเอียดเพิ่มเติม](https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders))

* ลบ `AbstractController::Helpers::ClassMethods::MissingHelperError` ที่ถูกยกเลิกแล้วและใช้ `AbstractController::Helpers::MissingHelperError` แทน
([Commit](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### การเลิกใช้

* เลิกใช้ตัวเลือก `only_path` ในช่วยเหลือ `*_path` helpers
([Commit](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9))

* เลิกใช้ `assert_tag`, `assert_no_tag`, `find_tag` และ `find_all_tag` และใช้ `assert_select` แทน
([Commit](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

* เลิกใช้การตั้งค่า `:to` ของเราเตอร์เป็นสัญลักษณ์หรือสตริงที่ไม่มีอักขระ "#" :
```ruby
get '/posts', to: MyRackApp    => (ไม่ต้องเปลี่ยนอะไร)
get '/posts', to: 'post#index' => (ไม่ต้องเปลี่ยนอะไร)
get '/posts', to: 'posts'      => get '/posts', controller: :posts
get '/posts', to: :index       => get '/posts', action: :index
```
([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

* เลิกใช้คีย์สตริงใน URL helpers:
```ruby
# ไม่ดี
root_path('controller' => 'posts', 'action' => 'index')

# ดี
root_path(controller: 'posts', action: 'index')
```
([Pull Request](https://github.com/rails/rails/pull/17743))

### การเปลี่ยนแปลงที่สำคัญ

* ลบครอบคลุมของเมธอด `*_filter` ออกจากเอกสาร และแนะนำให้ใช้เมธอด `*_action` แทน:
```
after_filter          => after_action
append_after_filter   => append_after_action
append_around_filter  => append_around_action
append_before_filter  => append_before_action
around_filter         => around_action
before_filter         => before_action
prepend_after_filter  => prepend_after_action
prepend_around_filter => prepend_around_action
prepend_before_filter => prepend_before_action
skip_after_filter     => skip_after_action
skip_around_filter    => skip_around_action
skip_before_filter    => skip_before_action
skip_filter           => skip_action_callback
```
หากแอปพลิเคชันของคุณขึ้นอยู่กับเมธอดเหล่านี้ให้ใช้เมธอด `*_action` แทน โดยเมธอดเหล่านี้จะถูกยกเลิกในอนาคตและในที่สุดจะถูกลบออกจาก Rails

- `render nothing: true` หรือการเรนเดอร์ body `nil` จะไม่เพิ่มช่องว่างหนึ่งตัวใน body ของการตอบสนองอีกต่อไป
- Rails ตอนนี้รวม digest ของเทมเพลตใน ETags โดยอัตโนมัติ
- ส่วนที่ถูกส่งผ่านไปยัง URL helpers จะถูกหนีไว้โดยอัตโนมัติ
- มีตัวเลือก `always_permitted_parameters` เพื่อกำหนดค่าพารามิเตอร์ที่อนุญาตทั้งหมดในระดับทั่วโลก ค่าเริ่มต้นของการกำหนดค่านี้คือ `['controller', 'action']`
- เพิ่ม HTTP method `MKCALENDAR` จาก RFC 4791
- การแจ้งเตือน `*_fragment.action_controller` ตอนนี้รวมชื่อคอนโทรลเลอร์และชื่อแอ็กชันใน payload
- ปรับปรุงหน้าข้อผิดพลาดของเร้าท์ด้วยการจับคู่ที่ไม่แน่นอนสำหรับการค้นหาเส้นทาง
- เพิ่มตัวเลือกในการปิดการบันทึกข้อผิดพลาดของ CSRF
- เมื่อเซิร์ฟเวอร์ Rails ถูกตั้งค่าให้ให้บริการค่าสถานะแบบสถิตให้บริการไฟล์ gzip ถ้าไคลเอ็นต์รองรับและมีไฟล์ gzip ที่ถูกสร้างล่วงหน้า (`.gz`) อยู่บนดิสก์ โดยค่าเริ่มต้นของ asset pipeline คือการสร้างไฟล์ `.gz` สำหรับทรัพยากรที่สามารถบีบอัดได้ การให้บริการไฟล์ gzip จะลดการถ่ายโอนข้อมูลและเพิ่มความเร็วในการร้องขอทรัพยากร ในการให้บริการทรัพยากรจากเซิร์ฟเวอร์ Rails ในโหมดการใช้งานจริง ให้ [ใช้ CDN](https://guides.rubyonrails.org/v4.2/asset_pipeline.html#cdns) เสมอ
- เมื่อเรียกใช้เมธอด `process` ในการทดสอบการรวมกัน ต้องมีเครื่องหมายทางเส้นทางด้านหน้า ก่อนหน้านี้คุณสามารถละเว้นได้ แต่นั่นเป็นผลลัพธ์ของการดำเนินการและไม่ใช่คุณสมบัติที่ตั้งใจ เช่น:

```ruby
test "list all posts" do
  get "/posts"
  assert_response :success
end
```

Action View
-----------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียดอ่อน
*   ยกเลิกการใช้ `ActionView::Digestor#digest(name, format, finder, options = {})` และแนะนำให้ใช้อาร์กิวเมนต์ในรูปแบบของแฮชแทน
    ([Pull Request](https://github.com/rails/rails/pull/14243))

### การเปลี่ยนแปลงที่สำคัญ

*   `render "foo/bar"` ตอนนี้จะขยายเป็น `render template: "foo/bar"` แทนที่จะเป็น `render file: "foo/bar"`
    ([Pull Request](https://github.com/rails/rails/pull/16888))

*   ช่วยเหลือในการสร้างฟอร์มไม่ได้สร้างอิลิเมนต์ `<div>` พร้อมกับ CSS ภายใน
    ([Pull Request](https://github.com/rails/rails/pull/14738))

*   เพิ่มตัวแปรพิเศษ `#{partial_name}_iteration` สำหรับใช้กับพาร์ทเชียลที่ถูกเรียกด้วยคอลเลกชัน มันจะให้การเข้าถึงสถานะปัจจุบันของการเรียกด้วยตัวชี้วัดผ่านเมธอด `index`, `size`, `first?` และ `last?`
    ([Pull Request](https://github.com/rails/rails/pull/7698))

*   Placeholder I18n ตามหลักการเดียวกับ `label` I18n
    ([Pull Request](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog][action-mailer] สำหรับรายละเอียดการเปลี่ยนแปลง

### การเลิกใช้

*   ยกเลิกใช้เฮลเปอร์ `*_path` ในเมลเลอร์ และแนะนำให้ใช้เฮลเปอร์ `*_url` แทน
    ([Pull Request](https://github.com/rails/rails/pull/15840))

*   ยกเลิกใช้ `deliver` / `deliver!` และแนะนำให้ใช้ `deliver_now` / `deliver_now!` แทน
    ([Pull Request](https://github.com/rails/rails/pull/16582))

### การเปลี่ยนแปลงที่สำคัญ

*   `link_to` และ `url_for` สร้าง URL แบบสมบูรณ์โดยค่าเริ่มต้นในเทมเพลต ไม่จำเป็นต้องส่ง `only_path: false` อีกต่อไป
    ([Commit](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

*   เพิ่ม `deliver_later` ซึ่งจะเพิ่มงานในคิวของแอปพลิเคชันเพื่อส่งอีเมลแบบไม่เดียวกัน
    ([Pull Request](https://github.com/rails/rails/pull/16485))

*   เพิ่มตัวเลือกการกำหนดค่า `show_previews` เพื่อเปิดใช้งานการแสดงตัวอย่างเมลเลอร์นอกจากสภาวะการพัฒนา
    ([Pull Request](https://github.com/rails/rails/pull/15970))


Active Record
-------------

โปรดอ้างอิงที่ [Changelog][active-record] สำหรับรายละเอียดการเปลี่ยนแปลง

### การลบ

*   ลบ `cache_attributes` และคำสั่งที่เกี่ยวข้อง ทุกแอตทริบิวต์จะถูกแคช
    ([Pull Request](https://github.com/rails/rails/pull/15429))

*   ลบเมธอดที่ถูกยกเลิก `ActiveRecord::Base.quoted_locking_column`
    ([Pull Request](https://github.com/rails/rails/pull/15612))

*   ลบเมธอดที่ถูกยกเลิก `ActiveRecord::Migrator.proper_table_name` ใช้เมธอดตัวอย่าง `proper_table_name` ในอินสแตนซ์ของ `ActiveRecord::Migration` แทน
    ([Pull Request](https://github.com/rails/rails/pull/15512))

*   ลบประเภท `:timestamp` ที่ไม่ได้ใช้ แทนที่จะใช้ `:datetime` ในทุกกรณี แก้ไขความไม่สอดคล้องเมื่อประเภทคอลัมน์ถูกส่งออกนอก Active Record เช่นสำหรับการซีเรียลไซเซชัน XML
    ([Pull Request](https://github.com/rails/rails/pull/15184))

### การเลิกใช้

*   ยกเลิกการซ่อนข้อผิดพลาดภายใน `after_commit` และ `after_rollback`
    ([Pull Request](https://github.com/rails/rails/pull/16537))

*   ยกเลิกการสนับสนุนการตรวจหาค่านับโดยอัตโนมัติบนการสัมพันธ์ `has_many :through` ที่เสียหาย คุณควรระบุค่านับโดยตรงในการสัมพันธ์ `has_many` และ `belongs_to` สำหรับบันทึกผ่าน
    ([Pull Request](https://github.com/rails/rails/pull/15754))
*   ยกเลิกการส่งออบเจ็กต์ Active Record ไปยัง `.find` หรือ `.exists?` ให้เรียก `id` บนออบเจ็กต์ก่อน
    (คอมมิต [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
    [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   ยกเลิกการสนับสนุนรูปแบบค่าเริ่มต้นสำหรับ PostgreSQL range ที่ไม่สมบูรณ์ที่มีการยกเว้นจุดเริ่มต้น ณ ปัจจุบันเราแมประเภท range ของ PostgreSQL เป็นระยะเวลาของ Ruby การแปลงนี้ไม่เป็นไปตามที่สมบูรณ์เพราะระยะเวลาของ Ruby ไม่สนับสนุนการยกเว้นจุดเริ่มต้น

    วิธีการปัจจุบันของการเพิ่มค่าเริ่มต้นไม่ถูกต้องและถูกยกเลิกแล้ว สำหรับ subtype ที่เราไม่รู้วิธีการเพิ่มค่า (เช่น `succ` ไม่ได้ถูกกำหนด) จะเกิดข้อผิดพลาดของ `ArgumentError` สำหรับระยะเวลาที่มีการยกเว้นจุดเริ่มต้น
    (คอมมิต [1](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   ยกเลิกการเรียกใช้ `DatabaseTasks.load_schema` โดยไม่มีการเชื่อมต่อ ให้ใช้ `DatabaseTasks.load_schema_current` แทน
    (คอมมิต [1](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   ยกเลิก `sanitize_sql_hash_for_conditions` โดยไม่มีการแทนที่ การใช้ `Relation` สำหรับการดำเนินการค้นหาและอัปเดตเป็น API ที่แนะนำ
    (คอมมิต [1](https://github.com/rails/rails/commit/d5902c9e))

*   ยกเลิก `add_timestamps` และ `t.timestamps` โดยไม่ส่ง `:null` option ค่าเริ่มต้นของ `null: true` จะเปลี่ยนใน Rails 5 เป็น `null: false`
    (พูลรีเควส [1](https://github.com/rails/rails/pull/16481))

*   ยกเลิก `Reflection#source_macro` โดยไม่มีการแทนที่เนื่องจากไม่จำเป็นต้องใช้ใน Active Record อีกต่อไป
    (พูลรีเควส [1](https://github.com/rails/rails/pull/16373))

*   ยกเลิก `serialized_attributes` โดยไม่มีการแทนที่
    (พูลรีเควส [1](https://github.com/rails/rails/pull/15704))

*   ยกเลิกการส่งค่า `nil` จาก `column_for_attribute` เมื่อไม่มีคอลัมน์อยู่ ใน Rails 5.0 จะส่งกลับวัตถุ null
    (พูลรีเควส [1](https://github.com/rails/rails/pull/15878))

*   ยกเลิกการใช้ `.joins`, `.preload` และ `.eager_load` กับการเชื่อมโยงที่ขึ้นอยู่กับสถานะของอินสแตนซ์ (เช่น นั่นที่ถูกกำหนดด้วย scope ที่รับอาร์กิวเมนต์) โดยไม่มีการแทนที่
    (คอมมิต [1](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### การเปลี่ยนแปลงที่สำคัญ

*   `SchemaDumper` ใช้ `force: :cascade` ใน `create_table` นี้ทำให้เป็นไปได้ที่จะโหลดสกีม่าเมื่อมีคีย์ต่างประเทศอยู่

*   เพิ่ม `:required` option ในการเชื่อมโยงแบบเดี่ยว ซึ่งกำหนดการตรวจสอบความมีอยู่ในการเชื่อมโยง
    (พูลรีเควส [1](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty` ตอนนี้สามารถตรวจจับการเปลี่ยนแปลงในที่เดียวกันกับค่าที่เปลี่ยนแปลงได้ แอตทริบิวต์ที่ถูกซีเรียลไว้บนโมเดล Active Record จะไม่ถูกบันทึกเมื่อไม่เปลี่ยนแปลง สิ่งนี้ยังสามารถทำงานได้กับประเภทอื่น เช่น คอลัมน์สตริงและคอลัมน์ json บน PostgreSQL
    (พูลรีเควส [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))

*   เพิ่มงาน Rake `db:purge` เพื่อล้างฐานข้อมูลสำหรับสภาพแวดล้อมปัจจุบัน
    (คอมมิต [1](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))
*   นำเสนอ `ActiveRecord::Base#validate!` ซึ่งเรียกใช้ `ActiveRecord::RecordInvalid` หากเกิดข้อผิดพลาดในการตรวจสอบข้อมูล
    ([Pull Request](https://github.com/rails/rails/pull/8639))

*   นำเสนอ `validate` เป็นตัวย่อสำหรับ `valid?`
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   `touch` สามารถรับค่า attribute ได้หลายค่าพร้อมกัน
    ([Pull Request](https://github.com/rails/rails/pull/14423))

*   อแดปเตอร์ PostgreSQL สนับสนุนชนิดข้อมูล `jsonb` ใน PostgreSQL 9.4+
    ([Pull Request](https://github.com/rails/rails/pull/16220))

*   อแดปเตอร์ PostgreSQL และ SQLite ไม่เพิ่มค่า default limit 255 ตัวอักษรในคอลัมน์ชนิด string อีกต่อไป
    ([Pull Request](https://github.com/rails/rails/pull/14579))

*   เพิ่มการสนับสนุนชนิดคอลัมน์ `citext` ในอแดปเตอร์ PostgreSQL
    ([Pull Request](https://github.com/rails/rails/pull/12523))

*   เพิ่มการสนับสนุนชนิด range types ที่สร้างโดยผู้ใช้ในอแดปเตอร์ PostgreSQL
    ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

*   `sqlite3:///some/path` ตอนนี้จะแปลงเป็นเส้นทางระบบแบบสมบูรณ์ `/some/path` สำหรับเส้นทางที่เป็นเส้นทางสัมพันธ์ให้ใช้ `sqlite3:some/path` แทน
    (ก่อนหน้านี้ `sqlite3:///some/path` แปลงเป็นเส้นทางสัมพันธ์ `some/path` ซึ่งเป็นการใช้งานที่ถูกยกเลิกใน Rails 4.1)
    ([Pull Request](https://github.com/rails/rails/pull/14569))

*   เพิ่มการสนับสนุนวินาทีเศษสำหรับ MySQL 5.6 และสูงกว่า
    (Pull Request [1](https://github.com/rails/rails/pull/8240),
    [2](https://github.com/rails/rails/pull/14359))

*   เพิ่ม `ActiveRecord::Base#pretty_print` เพื่อพิมพ์แบบสวยงามสำหรับโมเดล
    ([Pull Request](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload` ตอนนี้มีพฤติกรรมเดียวกับ `m = Model.find(m.id)` ซึ่งหมายความว่าจะไม่เก็บค่า attributes เพิ่มเติมจาก `SELECT` ที่กำหนดเอง
    ([Pull Request](https://github.com/rails/rails/pull/15866))

*   `ActiveRecord::Base#reflections` ตอนนี้คืนค่าเป็นแฮชที่มีคีย์เป็นสตริงแทนที่จะเป็นสัญลักษณ์
    ([Pull Request](https://github.com/rails/rails/pull/17718))

*   เมธอด `references` ในการทำฐานข้อมูลสนับสนุนตัวเลือก `type` เพื่อระบุชนิดของคีย์ต่างประเทศ (เช่น `:uuid`)
    ([Pull Request](https://github.com/rails/rails/pull/16231))

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `Validator#setup` ที่ถูกยกเลิกโดยไม่มีตัวแทน
    ([Pull Request](https://github.com/rails/rails/pull/10716))

### การเลิกใช้

*   เลิกใช้ `reset_#{attribute}` และใช้ `restore_#{attribute}` แทน
    ([Pull Request](https://github.com/rails/rails/pull/16180))

*   เลิกใช้ `ActiveModel::Dirty#reset_changes` และใช้ `clear_changes_information` แทน
    ([Pull Request](https://github.com/rails/rails/pull/16180))

### การเปลี่ยนแปลงที่สำคัญ

*   นำเสนอ `validate` เป็นตัวย่อสำหรับ `valid?`
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   นำเสนอเมธอด `restore_attributes` ใน `ActiveModel::Dirty` เพื่อกู้คืนค่า attribute ที่เปลี่ยนแปลง (dirty) กลับเป็นค่าก่อนหน้า
    (Pull Request [1](https://github.com/rails/rails/pull/14861),
    [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password` ไม่ได้ห้ามรหัสผ่านที่ว่างเปล่า (เช่น รหัสผ่านที่มีเฉพาะช่องว่าง) โดยค่าเริ่มต้นอีกต่อไป
    ([Pull Request](https://github.com/rails/rails/pull/16412))
* `has_secure_password` ตอนนี้ตรวจสอบว่ารหัสผ่านที่ให้มามีความยาวไม่เกิน 72 ตัวอักษรเมื่อการตรวจสอบถูกเปิดใช้งานแล้ว
    ([Pull Request](https://github.com/rails/rails/pull/15708))

Active Support
--------------

โปรดอ้างอิง [Changelog][active-support] สำหรับรายละเอียดการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `Numeric#ago`, `Numeric#until`, `Numeric#since`, `Numeric#from_now` ที่ถูกยกเลิกไปแล้ว
    ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   ลบ string based terminators ที่ถูกยกเลิกไปแล้วสำหรับ `ActiveSupport::Callbacks`
    ([Pull Request](https://github.com/rails/rails/pull/15100))

### การเลิกใช้งาน

*   เลิกใช้งาน `Kernel#silence_stderr`, `Kernel#capture` และ `Kernel#quietly` โดยไม่มีการแทนที่
    ([Pull Request](https://github.com/rails/rails/pull/13392))

*   เลิกใช้งาน `Class#superclass_delegating_accessor` ใช้ `Class#class_attribute` แทน
    ([Pull Request](https://github.com/rails/rails/pull/14271))

*   เลิกใช้งาน `ActiveSupport::SafeBuffer#prepend!` เนื่องจาก `ActiveSupport::SafeBuffer#prepend` ทำหน้าที่เดียวกันแล้ว
    ([Pull Request](https://github.com/rails/rails/pull/14529))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มตัวเลือกการกำหนดค่าใหม่ `active_support.test_order` เพื่อระบุลำดับที่ทดสอบจะถูกดำเนินการ ตัวเลือกนี้เริ่มต้นด้วย `:sorted` แต่จะเปลี่ยนเป็น `:random` ใน Rails 5.0
    ([Commit](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   `Object#try` และ `Object#try!` สามารถใช้ได้โดยไม่ต้องระบุผู้รับโดยชัดเจนในบล็อก
    ([Commit](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830),
    [Pull Request](https://github.com/rails/rails/pull/17361))

*   เครื่องมือทดสอบ `travel_to` ตอนนี้จะตัดส่วน `usec` ให้เป็น 0
    ([Commit](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   เพิ่ม `Object#itself` เป็นฟังก์ชัน identity
    (Commit [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810),
    [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   `Object#with_options` สามารถใช้ได้โดยไม่ต้องระบุผู้รับโดยชัดเจนในบล็อก
    ([Pull Request](https://github.com/rails/rails/pull/16339))

*   เพิ่ม `String#truncate_words` เพื่อตัดคำในสตริงตามจำนวนคำที่กำหนด
    ([Pull Request](https://github.com/rails/rails/pull/16190))

*   เพิ่ม `Hash#transform_values` และ `Hash#transform_values!` เพื่อทำให้ง่ายขึ้นในกรณีที่ต้องเปลี่ยนค่าของคีย์ในแฮช แต่คีย์ยังคงเดิม
    ([Pull Request](https://github.com/rails/rails/pull/15819))

*   เครื่องมือ inflector `humanize` ตอนนี้จะลบขีดล่างด้านหน้าทิ้งทั้งหมด
    ([Commit](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   เพิ่ม `Concern#class_methods` เป็นทางเลือกในการใช้งานแทน `module ClassMethods` และ `Kernel#concern` เพื่อลดการเขียนโค้ด boilerplate `module Foo; extend ActiveSupport::Concern; end`
    ([Commit](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   [คู่มือใหม่](autoloading_and_reloading_constants_classic_mode.html) เกี่ยวกับการโหลดและโหลดค่าคงที่

เครดิต
-------

ดูรายชื่อเต็มของผู้มีส่วนร่วมใน Rails ได้ที่
[รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](https://contributors.rubyonrails.org/) สำหรับ
ผู้ที่ใช้เวลาหลายชั่วโมงในการทำให้ Rails เป็นเฟรมเวิร์กที่เสถียรและแข็งแกร่งในปัจจุบัน ยินดีด้วยทุกคน
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
