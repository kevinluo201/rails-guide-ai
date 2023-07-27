**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4d8311a1435138a81e26a7e8f537dbde
เรื่องเด่นใน Rails 4.2:

* Active Job
* การส่งอีเมลแบบไม่สั่งส่งทันที
* Adequate Record
* Web Console
* การสนับสนุนคีย์ต่างประเทศ

เอกสารเวอร์ชันนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับคุณสมบัติอื่น ๆ การแก้ไขข้อบกพร่อง และการเปลี่ยนแปลง โปรดอ้างถึงเรื่องราวการเปลี่ยนแปลงหรือตรวจสอบ [รายการคอมมิต](https://github.com/rails/rails/commits/4-2-stable) ในเก็บข้อมูลหลักของ Rails ใน GitHub

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 4.2
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดไปยัง Rails 4.1 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเกรดไปยัง Rails 4.2 มีรายการสิ่งที่ควรระวังเมื่ออัปเกรดในคู่มือ [การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2)

คุณสมบัติหลัก
--------------

### Active Job

Active Job เป็นเฟรมเวิร์กใหม่ใน Rails 4.2 มันเป็นอินเตอร์เฟซทั่วไปบนระบบคิวเช่น [Resque](https://github.com/resque/resque), [Delayed
Job](https://github.com/collectiveidea/delayed_job),
[Sidekiq](https://github.com/mperham/sidekiq), และอื่น ๆ

งานที่เขียนด้วย Active Job API ทำงานบนคิวที่รองรับได้ทั้งหมดด้วยตัวอัพเดตของตัวเอง Active Job มาพร้อมกับตัวรันอินไลน์ที่ทำงานงานทันที

งานบ่อยครั้งต้องการใช้วัตถุ Active Record เป็นอาร์กิวเมนต์ Active Job ส่งอ้างอิงวัตถุเป็น URI (uniform resource identifiers) แทนที่จะทำการมาร์ชลอลวัตถุเอง ไลบรารีใหม่ [Global ID](https://github.com/rails/globalid) สร้าง URI และค้นหาวัตถุที่อ้างถึง การส่งอาร์กิวเมนต์ Active Record เป็นงานที่ทำงานโดยใช้ Global ID ภายใน

ตัวอย่างเช่น หาก `trashable` เป็นออบเจ็กต์ Active Record แล้วงานนี้ทำงานได้ดีโดยไม่ต้องมีการซีรีย์ไลซ์เอง:

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

ดูเพิ่มเติมในคู่มือ [Active Job Basics](active_job_basics.html)

### การส่งอีเมลแบบไม่สั่งส่งทันที

โดยใช้ Active Job เป็นพื้นฐาน Action Mailer มาพร้อมกับเมธอด `deliver_later` ที่ส่งอีเมลผ่านคิว ดังนั้นจึงไม่บล็อกคอนโทรลเลอร์หรือโมเดลหากคิวเป็นแบบไม่สั่งส่งทันที (คิวอินไลน์เริ่มต้นบล็อก)

การส่งอีเมลทันทียังเป็นไปได้ด้วย `deliver_now`

### Adequate Record

Adequate Record เป็นชุดการปรับปรุงประสิทธิภาพใน Active Record ที่ทำให้การเรียกใช้ `find` และ `find_by` ทั่วไปและการสอบถามความสัมพันธ์บางอย่างเร็วขึ้นถึง 2 เท่า

มันทำงานโดยการแคชคำสั่ง SQL ที่ใช้บ่อยเป็นคำสั่งที่เตรียมไว้และนำมาใช้ในการเรียกใช้ที่คล้ายกัน โดยข้ามการสร้างคำสั่งคิวรีในการเรียกใช้ครั้งถัดไป สำหรับรายละเอียดเพิ่มเติมโปรดอ้างถึง [บล็อกของ Aaron Patterson](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html)

Active Record จะใช้คุณสมบัตินี้โดยอัตโนมัติในการดำเนินการที่รองรับโดยไม่ต้องมีการเข้ามามีส่วนร่วมของผู้ใช้หรือเปลี่ยนแปลงโค้ด ตัวอย่างการดำเนินการที่รองรับคือ:

```ruby
Post.find(1)  # การเรียกครั้งแรกสร้างและแคชคำสั่งเตรียมไว้
Post.find(2)  # การเรียกครั้งถัดไปใช้คำสั่งเตรียมที่แคชไว้

Post.find_by_title('first post')
Post.find_by_title('second post')

Post.find_by(title: 'first post')
Post.find_by(title: 'second post')

post.comments
post.comments(true)
```

สำคัญที่จะเน้นว่า ตามที่ตัวอย่างข้างต้นแนะนำ คำสั่งเตรียมไม่แคชค่าที่ผ่านมาในการเรียกเมธอด แต่มีตัวยึดสำหรับมัน

ไม่ใช้การแคชในสถานการณ์ต่อไปนี้:

- โมเดลมีขอบเขตเริ่มต้น
- โมเดลใช้การสืบทอดตารางเดียว
- `find` ด้วยรายการ id เช่น:

    ```ruby
    # ไม่มีการแคช
    Post.find(1, 2, 3)
    Post.find([1,2])
    ```

- `find_by` ด้วยฟรากเมนต์ SQL:

    ```ruby
    Post.find_by('published_at < ?', 2.weeks.ago)
    ```

### Web Console

แอปพลิเคชันใหม่ที่สร้างด้วย Rails 4.2 มาพร้อมกับ [Web
Console](https://github.com/rails/web-console) แบบเริ่มต้น  Web Console เพิ่มคอนโซล Ruby แบบแอ็กทีฟบนหน้าข้อผิดพลาดและให้ความช่วยเหลือในการสร้างและควบคุมวิวและคอนโทรลเลอร์

คอนโซลแบบแอ็กทีฟบนหน้าข้อผิดพลาดช่วยให้คุณสามารถดำเนินการโค้ดในบริบทของสถานที่ที่เกิดข้อยกเว้น ฟังก์ชัน `console` ถ้าเรียกใช้ในวิวหรือคอนโทรลเลอร์ใด ๆ จะเริ่มคอนโซลแบบแอ็กทีฟที่มีบริบทสุดท้ายหลังจากการเรนเดอร์เสร็จสมบูรณ์
### การสนับสนุน Foreign Key

Migration DSL ตอนนี้สนับสนุนการเพิ่มและลบ foreign key และจะถูกบันทึกไว้ใน `schema.rb` ในขณะนี้เฉพาะ adapter `mysql`, `mysql2` และ `postgresql` เท่านั้นที่สนับสนุน foreign key

```ruby
# เพิ่ม foreign key ให้กับ `articles.author_id` ที่อ้างอิงไปที่ `authors.id`
add_foreign_key :articles, :authors

# เพิ่ม foreign key ให้กับ `articles.author_id` ที่อ้างอิงไปที่ `users.lng_id`
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# ลบ foreign key ที่อยู่ใน `accounts.branch_id`
remove_foreign_key :accounts, :branches

# ลบ foreign key ที่อยู่ใน `accounts.owner_id`
remove_foreign_key :accounts, column: :owner_id
```

ดูเอกสาร API ที่
[add_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)
และ
[remove_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)
สำหรับคำอธิบายเพิ่มเติม


ความไม่เข้ากัน
-----------------

ฟังก์ชันที่ถูกยกเลิกไว้ก่อนหน้านี้ถูกลบออกแล้ว โปรดอ้างอิงไปที่ส่วนประกอบแต่ละอันสำหรับการยกเลิกใหม่ในรุ่นนี้

การเปลี่ยนแปลงต่อไปนี้อาจต้องการการดำเนินการทันทีหลังจากการอัปเกรด

### `render` ด้วยอาร์กิวเมนต์เป็นสตริง

ก่อนหน้านี้การเรียกใช้ `render "foo/bar"` ใน controller action เป็นเทียบเท่ากับ `render file: "foo/bar"` ใน Rails 4.2 นี้ถูกเปลี่ยนเป็นหมายความว่า `render template: "foo/bar"` แทน หากคุณต้องการเรียกใช้ไฟล์ โปรดเปลี่ยนรหัสของคุณให้ใช้รูปแบบชัดเจน (`render file: "foo/bar"`) แทน

### `respond_with` / Class-Level `respond_to`

`respond_with` และ class-level `respond_to` ได้ถูกย้ายไปยัง [responders](https://github.com/plataformatec/responders) gem เพิ่ม `gem 'responders', '~> 2.0'` ใน `Gemfile` เพื่อใช้งาน:

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

เนื่องจากการเปลี่ยนแปลงใน Rack (https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc) `rails server` ตอนนี้จะฟังที่ `localhost` แทน `0.0.0.0` เป็นค่าเริ่มต้น สิ่งนี้ควรมีผลกระทบต่ำสำหรับการทำงานพัฒนามาตรฐานเนื่องจากทั้ง http://127.0.0.1:3000 และ http://localhost:3000 จะยังคงทำงานเหมือนเดิมบนเครื่องของคุณเอง

อย่างไรก็ตาม ด้วยการเปลี่ยนแปลงนี้คุณจะไม่สามารถเข้าถึงเซิร์ฟเวอร์ Rails จากเครื่องอื่นได้ เช่น หากสภาพแวดล้อมการพัฒนาของคุณอยู่ในเครื่องจำลองเสมือนและคุณต้องการเข้าถึงจากเครื่องโฮสต์ ในกรณีเช่นนี้โปรดเริ่มเซิร์ฟเวอร์ด้วย `rails server -b 0.0.0.0` เพื่อเรียกคืนพฤติกรรมเดิม

หากคุณทำเช่นนี้ โปรดตั้งค่าไฟร์วอลล์ของคุณให้ถูกต้องเพื่อให้เซิร์ฟเวอร์พัฒนาของคุณสามารถเข้าถึงได้เฉพาะเครื่องที่เชื่อถือได้บนเครือข่ายของคุณ

### สัญลักษณ์ตัวเลือกสถานะที่เปลี่ยนไปสำหรับ `render`

เนื่องจากการเปลี่ยนแปลงใน Rack (https://github.com/rack/rack/commit/be28c6a2ac152fe4adfbef71f3db9f4200df89e8) สัญลักษณ์ที่ `render` ยอมรับสำหรับตัวเลือก `:status` ได้เปลี่ยนไป:

- 306: `:reserved` ถูกลบออก
- 413: `:request_entity_too_large` ถูกเปลี่ยนชื่อเป็น `:payload_too_large`
- 414: `:request_uri_too_long` ถูกเปลี่ยนชื่อเป็น `:uri_too_long`
- 416: `:requested_range_not_satisfiable` ถูกเปลี่ยนชื่อเป็น `:range_not_satisfiable`

โปรดทราบว่าหากเรียกใช้ `render` ด้วยสัญลักษณ์ที่ไม่รู้จัก สถานะการตอบกลับจะกลายเป็น 500 โดยค่าเริ่มต้น

### HTML Sanitizer

HTML sanitizer ถูกแทนที่ด้วยการสร้างใหม่ที่มีความแข็งแกร่งมากขึ้น โดยใช้ [Loofah](https://github.com/flavorjones/loofah) และ [Nokogiri](https://github.com/sparklemotion/nokogiri) ในการสร้าง ตัวกรอง HTML ใหม่มีความปลอดภัยมากขึ้นและการกรองข้อมูลมีความสามารถและความยืดหยุ่นมากขึ้น

เนื่องจากอัลกอริทึมใหม่ ผลลัพธ์ที่ถูกกรองอาจแตกต่างกันสำหรับข้อมูลที่มีความผิดปกติบางกรณี

หากคุณต้องการผลลัพธ์ที่แน่นอนของตัวกรอง HTML เก่า คุณสามารถเพิ่ม [rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer) gem เข้าไปใน `Gemfile` เพื่อให้มีพฤติกรรมเดิม แต่ gem นี้ไม่มีการแจ้งเตือนเกี่ยวกับการเลิกใช้ เนื่องจากเป็นการเลือกใช้

`rails-deprecated_sanitizer` จะได้รับการสนับสนุนสำหรับ Rails 4.2 เท่านั้น และจะไม่ได้รับการบำรุงรักษาสำหรับ Rails 5.0

ดู [บทความบล็อกนี้](https://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/) สำหรับรายละเอียดเพิ่มเติมเกี่ยวกับการเปลี่ยนแปลงในตัวกรอง HTML ใหม่

### `assert_select`

`assert_select` ตอนนี้ใช้ [Nokogiri](https://github.com/sparklemotion/nokogiri) เป็นพื้นฐาน ดังนั้น บางตัวเลือกที่เคยถูกยอมรับก่อนหน้านี้ไม่ได้รับการสนับสนุนอีกต่อไป หากแอปพลิเคชันของคุณใช้รูปแบบเหล่านี้คุณจะต้องอัปเดต:


* ค่าในตัวเลือกแอตทริบิวต์อาจต้องใส่ในเครื่องหมายคำพูดหากมีอักขระที่ไม่ใช่ตัวอักษรและตัวเลข

    ```ruby
    # ก่อนหน้านี้
    a[href=/]
    a[href$=/]

    # ตอนนี้
    a[href="/"]
    a[href$="/"]
    ```

* DOMs ที่สร้างขึ้นจากแหล่งที่มาของ HTML ที่มี HTML ที่ไม่ถูกต้องที่มีองค์ประกอบที่ไม่ถูกต้องอาจแตกต่างกัน

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

* หากข้อมูลที่เลือกมี entities ค่าที่เลือกสำหรับการเปรียบเทียบที่ใช้เคยเป็น raw (เช่น `AT&amp;T`) และตอนนี้ถูกประเมิน (เช่น `AT&T`)

    ```ruby
    # เนื้อหา: <p>AT&amp;T</p>

    # ก่อนหน้านี้:
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # ตอนนี้:
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

นอกจากนี้การแทนที่เปลี่ยนไปใช้ไวยกรณ์ `:match` แบบ CSS:

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

นอกจากนี้การแทนที่ด้วย Regexp ดูแตกต่างเมื่อการตรวจสอบล้มเหลว
สังเกตว่า `/hello/` ที่นี่:

```ruby
assert_select(":match('id', ?)", /hello/)
```

กลายเป็น `"(?-mix:hello)"`:

```
Expected at least 1 element matching "div:match('id', "(?-mix:hello)")", found 0..
Expected 0 to be >= 1.
```

ดูเอกสาร [การทดสอบด้วย Dom ของ Rails](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b) เพื่อดูข้อมูลเพิ่มเติมเกี่ยวกับ `assert_select`


Railties
--------

โปรดอ้างอิง [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ตัวเลือก `--skip-action-view` ถูกลบออกจากตัวสร้างแอปพลิเคชัน ([Pull Request](https://github.com/rails/rails/pull/17042))

*   คำสั่ง `rails application` ถูกลบโดยไม่มีการแทนที่ ([Pull Request](https://github.com/rails/rails/pull/11616))

### การเลิกใช้

*   เลิกใช้ `config.log_level` ที่ขาดหายไปสำหรับสภาพแวดล้อมการผลิต ([Pull Request](https://github.com/rails/rails/pull/16622))

*   เลิกใช้ `rake test:all` แล้วใช้ `rake test` แทนเนื่องจากตอนนี้รันทดสอบทั้งหมดในโฟลเดอร์ `test` ([Pull Request](https://github.com/rails/rails/pull/17348))

*   เลิกใช้ `rake test:all:db` แล้วใช้ `rake test:db` แทน ([Pull Request](https://github.com/rails/rails/pull/17348))

*   เลิกใช้ `Rails::Rack::LogTailer` โดยไม่มีการแทนที่ ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม `web-console` ใน `Gemfile` แอปพลิเคชันเริ่มต้น ([Pull Request](https://github.com/rails/rails/pull/11667))

*   เพิ่มตัวเลือก `required` ในตัวสร้างโมเดลสำหรับการเชื่อมโยง ([Pull Request](https://github.com/rails/rails/pull/16062))

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

*   เพิ่ม `Rails::Application.config_for` เพื่อโหลดการกำหนดค่าสำหรับสภาพแวดล้อมปัจจุบัน

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

*   เพิ่มตัวเลือก `--skip-turbolinks` ในตัวสร้างแอปพลิเคชันเพื่อไม่สร้างการผสาน turbolinks ([Commit](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

*   เพิ่มสคริปต์ `bin/setup` เป็นสคริปต์ที่ใช้งานอัตโนมัติเมื่อเริ่มต้นแอปพลิเคชัน ([Pull Request](https://github.com/rails/rails/pull/15189))

*   เปลี่ยนค่าเริ่มต้นของ `config.assets.digest` เป็น `true` ในโหมดการพัฒนา ([Pull Request](https://github.com/rails/rails/pull/15155))

*   เพิ่ม API เพื่อลงทะเบียนส่วนขยายใหม่สำหรับ `rake notes` ([Pull Request](https://github.com/rails/rails/pull/14379))

*   เพิ่มการเรียกใช้
([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

*   ยกเลิกการสนับสนุนคีย์สตริงใน URL helpers:

    ```ruby
    # ไม่ดี
    root_path('controller' => 'posts', 'action' => 'index')

    # ดี
    root_path(controller: 'posts', action: 'index')
    ```

    ([Pull Request](https://github.com/rails/rails/pull/17743))

### การเปลี่ยนแปลงที่สำคัญ

*   ลบเมธอดตระกูล `*_filter` ออกจากเอกสารคู่มือ แนะนำให้ใช้เมธอดตระกูล `*_action` แทน:

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

    หากแอปพลิเคชันของคุณใช้เมธอดเหล่านี้ คุณควรใช้เมธอด `*_action` ทดแทน โดยเมธอดเหล่านี้จะถูกยกเลิกในอนาคตและในที่สุดจะถูกลบออกจาก Rails

    (Commit [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de),
    [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4))

*   `render nothing: true` หรือการเรนเดอร์ body `nil` จะไม่เพิ่มช่องว่างหนึ่งตัวใน body ของการตอบกลับอีกต่อไป
    ([Pull Request](https://github.com/rails/rails/pull/14883))

*   Rails ตอนนี้รวม digest ของเทมเพลตใน ETags โดยอัตโนมัติ
    ([Pull Request](https://github.com/rails/rails/pull/16527))

*   ส่วนที่ถูกส่งผ่านไปยัง URL helpers จะถูกหนีไว้โดยอัตโนมัติ
    ([Commit](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

*   เพิ่มตัวเลือก `always_permitted_parameters` เพื่อกำหนดว่าพารามิเตอร์ใดที่อนุญาตให้ใช้ทั่วไป ค่าเริ่มต้นของการกำหนดค่านี้คือ `['controller', 'action']`
    ([Pull Request](https://github.com/rails/rails/pull/15933))

*   เพิ่ม HTTP method `MKCALENDAR` จาก [RFC 4791](https://tools.ietf.org/html/rfc4791)
    ([Pull Request](https://github.com/rails/rails/pull/15121))

*   การแจ้งเตือน `*_fragment.action_controller` ตอนนี้รวมชื่อคอนโทรลเลอร์และแอ็กชันใน payload
    ([Pull Request](https://github.com/rails/rails/pull/14137))

*   ปรับปรุงหน้าข้อผิดพลาดของเส้นทางด้วยการค้นหาแบบ fuzzy matching
    ([Pull Request](https://github.com/rails/rails/pull/14619))

*   เพิ่มตัวเลือกในการปิดการบันทึกข้อผิดพลาดของ CSRF
    ([Pull Request](https://github.com/rails/rails/pull/14280))

*   เมื่อเซิร์ฟเวอร์ Rails ถูกตั้งค่าให้ให้บริการค่าสถานะแบบสถิต ไฟล์ gzip จะถูกบริการถ้าไคลเอ็นต์รองรับและมีไฟล์ gzip ที่ถูกสร้างล่วงหน้า (`.gz`) อยู่บนดิสก์
    โดยค่าเริ่มต้น asset pipeline จะสร้างไฟล์ `.gz` สำหรับทรัพยากรที่สามารถบีบอัดได้ การบริการไฟล์ gzip จะลดการถ่ายโอนข้อมูลและเพิ่มความเร็วในการร้องขอทรัพยากร ในการให้บริการทรัพยากรจากเซิร์ฟเวอร์ Rails ในโหมดการใช้งานจริง เสมอ
    [ใช้ CDN](https://guides.rubyonrails.org/v4.2/asset_pipeline.html#cdns)
    ([Pull Request](https://github.com/rails/rails/pull/16466))

*   เมื่อเรียกใช้เมธอด `process` ในการทดสอบการรวมกัน พาธจำเป็นต้องมีเครื่องหมายสำหรับการเริ่มต้น ก่อนหน้านี้คุณสามารถละเว้นได้ แต่นั่นเป็นผลลัพธ์ของการดำเนินการและไม่ใช่คุณสมบัติที่ตั้งใจ เช่น:

    ```ruby
    test "list all posts" do
      get "/posts"
      assert_response :success
    end
    ```

Action View
-----------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเลิกใช้งาน

*   ยกเลิกใช้งาน `AbstractController::Base.parent_prefixes` แทนที่จะใช้ `AbstractController::Base.local_prefixes` เมื่อคุณต้องการเปลี่ยนที่จะค้นหาวิว
    ([Pull Request](https://github.com/rails/rails/pull/15026))

*   ยกเลิกใช้งาน `ActionView::Digestor#digest(name, format, finder, options = {})` ควรส่งอาร์กิวเมนต์เป็นแฮชแทน
    ([Pull Request](https://github.com/rails/rails/pull/14243))

### การเปลี่ยนแปลงที่สำคัญ

*   `render "foo/bar"` ตอนนี้จะขยายเป็น `render template: "foo/bar"` แทนที่จะเป็น `render file: "foo/bar"`
    ([Pull Request](https://github.com/rails/rails/pull/16888))

*   ช่วยเหลือฟอร์มไม่สร้าง `<div>` พร้อม CSS ภายในส่วนที่ซ่อนอยู่
    ([Pull Request](https://github.com/rails/rails/pull/14738))

*   เพิ่มตัวแปรโลคัลพิเศษ `#{partial_name}_iteration` สำหรับใช้กับพาร์ทเชียลที่ถูกเรนเดอร์ด้วยคอลเลกชัน มันจะให้การเข้าถึงสถานะปัจจุบันของการเรนเดอร์ผ่านเมธอด `index`, `size`, `first?` และ `last?`
    ([Pull Request](https://github.com/rails/rails/pull/7698))

*   Placeholder I18n ตามแบบเดียวกับ I18n ของ `label`
    ([Pull Request](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog][action-mailer] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเลิกใช้งาน

*   ยกเลิกใช้งานเฮลเปอร์ `*_path` ในเมลเลอร์ ให้ใช้เฮลเปอ
Active Record
-------------

โปรดอ้างอิงที่ [Changelog][active-record] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `cache_attributes` และเพื่อนๆ ทั้งหมด แอตทริบิวต์ทั้งหมดถูกเก็บแคชไว้
    ([Pull Request](https://github.com/rails/rails/pull/15429))

*   ลบเมธอดที่ถูกยกเลิก `ActiveRecord::Base.quoted_locking_column`
    ([Pull Request](https://github.com/rails/rails/pull/15612))

*   ลบ `ActiveRecord::Migrator.proper_table_name` ที่ถูกยกเลิก ใช้เมธอดตัวอย่าง `proper_table_name` บน `ActiveRecord::Migration` แทน
    ([Pull Request](https://github.com/rails/rails/pull/15512))

*   ลบ `:timestamp` type ที่ไม่ได้ใช้ แทนที่จะเป็น `:datetime` ในทุกกรณี แก้ไขความไม่สอดคล้องเมื่อประเภทคอลัมน์ถูกส่งออกนอก Active Record เช่นสำหรับการซีเรียลไลซ์ XML
    ([Pull Request](https://github.com/rails/rails/pull/15184))

### การเลิกใช้

*   เลิกใช้การละเว้นข้อผิดพลาดภายใน `after_commit` และ `after_rollback`
    ([Pull Request](https://github.com/rails/rails/pull/16537))

*   เลิกใช้การสนับสนุนที่เสียหายสำหรับการตรวจหาการนับค่าในการรวมกันของ `has_many :through` associations ควรระบุการนับค่าในการรวมกันใน `has_many` และ `belongs_to` associations สำหรับเร็คคอร์ดที่ผ่านมา
    ([Pull Request](https://github.com/rails/rails/pull/15754))

*   เลิกใช้การส่งออบเจ็กต์ Active Record ไปยัง `.find` หรือ `.exists?` ให้เรียก `id` บนออบเจ็กต์ก่อน
    (Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
    [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   เลิกใช้การสนับสนุนที่ไม่สมบูรณ์สำหรับค่าเริ่มต้นของระยะเวลา PostgreSQL ที่มีการยกเว้นจากจุดเริ่มต้น ขณะนี้เราแมประยะเวลา PostgreSQL เป็นระยะเวลา Ruby การแปลงนี้ไม่สามารถทำได้เต็มที่เนื่องจากระยะเวลา Ruby ไม่สนับสนุนการยกเว้นจากจุดเริ่มต้น

    วิธีการปัจจุบันของการเพิ่มค่าจุดเริ่มต้นไม่ถูกต้องและถูกเลิกใช้ สำหรับชนิดย่อยที่เราไม่รู้วิธีการเพิ่มค่า (เช่น `succ` ไม่ได้ถูกกำหนด) จะเกิดข้อผิดพลาด `ArgumentError` สำหรับระยะเวลาที่มีการยกเว้นจากจุดเริ่มต้น
    ([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   เลิกใช้ `DatabaseTasks.load_schema` โดยไม่มีการเชื่อมต่อ ให้ใช้ `DatabaseTasks.load_schema_current` แทน
    ([Commit](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   เลิกใช้ `sanitize_sql_hash_for_conditions` โดยไม่มีการแทนที่ การใช้ `Relation` สำหรับการทำคำสั่งคิวรีและการอัปเดตเป็น API ที่แนะนำ
    ([Commit](https://github.com/rails/rails/commit/d5902c9e))

*   เลิกใช้ `add_timestamps` และ `t.timestamps` โดยไม่ผ่าน `:null` option ค่าเริ่มต้นของ `null: true` จะเปลี่ยนใน Rails 5 เป็น `null: false`
    ([Pull Request](https://github.com/rails/rails/pull/16481))

*   เลิกใช้ `Reflection#source_macro` โดยไม่มีการแทนที่เนื่องจากไม่จำเป็นใน Active Record อีกต่อไป
    ([Pull Request](https://github.com/rails/rails/pull/16373))

*   เลิกใช้ `serialized_attributes` โดยไม่มีการแทนที่
    ([Pull Request](https://github.com/rails/rails/pull/15704))

*   เลิกใช้การส่งค่า `nil` จาก `column_for_attribute` เมื่อไม่มีคอลัมน์อยู่ ใน Rails 5.0 จะส่งกลับออบเจ็กต์ null
    ([Pull Request](https://github.com/rails/rails/pull/15878))

*   เลิกใช้ `.joins`, `.preload` และ `.eager_load` กับการรวมกันที่ขึ้นอยู่กับสถานะของอินสแตนซ์ (เช่นคำนิยามด้วยสโคปที่รับอาร์กิวเมนต์) โดยไม่มีการแทนที่
    ([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### การเปลี่ยนแปลงที่สำคัญ

*   `SchemaDumper` ใช้ `force: :cascade` บน `create_table` ทำให้เป็นไปได้ที่จะโหลดสกีมาใหม่เมื่อมีคีย์ต่างประเทศอยู่

*   เพิ่ม `:required` option ในการรวมกันแบบเดี่ยว ซึ่งกำหนดการตรวจสอบความถูกต้องในการรวมกัน
    ([Pull Request](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty` ตอนนี้ตรวจจับการเปลี่ยนแปลงในตำแหน่งเดิมของค่าที่เปลี่ยนได้ แอตทริบิวต์ที่ถูกซีเรียลไลซ์บนโมเดล Active Record จะไม่ถูกบันทึกเมื่อไม่เปลี่ยนแปลง สิ่งนี้ยังสามารถทำงานได้กับประเภทอื่น เช่นคอลัมน์สตริงและคอลัมน์ json บน PostgreSQL
    (Pull Requests [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))

*   เพิ่มงาน Rake `db:purge` เพื่อล้างฐานข้อมูลสำหรับสภาพแว
*   `ActiveRecord::Base#reflections` ตอนนี้จะส่งคืนแฮชที่มีคีย์เป็นสตริงแทนที่จะเป็นสัญลักษณ์ ([Pull Request](https://github.com/rails/rails/pull/17718))

*   เมธอด `references` ในการทำฐานข้อมูลตอนนี้รองรับตัวเลือก `type` เพื่อระบุประเภทของคีย์ต่างประเทศ (เช่น `:uuid`) ([Pull Request](https://github.com/rails/rails/pull/16231))

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `Validator#setup` ที่ถูกยกเลิกโดยไม่มีการแทนที่ ([Pull Request](https://github.com/rails/rails/pull/10716))

### การเลิกใช้

*   เลิกใช้ `reset_#{attribute}` และใช้ `restore_#{attribute}` แทน ([Pull Request](https://github.com/rails/rails/pull/16180))

*   เลิกใช้ `ActiveModel::Dirty#reset_changes` และใช้ `clear_changes_information` แทน ([Pull Request](https://github.com/rails/rails/pull/16180))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่ม `validate` เป็นตัวย่อสำหรับ `valid?` ([Pull Request](https://github.com/rails/rails/pull/14456))

*   เพิ่มเมธอด `restore_attributes` ใน `ActiveModel::Dirty` เพื่อกู้คืนคุณสมบัติที่เปลี่ยนแปลง (dirty) ให้กลับเป็นค่าเดิม ([1](https://github.com/rails/rails/pull/14861), [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password` ไม่ได้ห้ามรหัสผ่านที่ว่างเปล่า (เช่น รหัสผ่านที่มีเฉพาะช่องว่าง) โดยค่าเริ่มต้นอีกต่อไป ([Pull Request](https://github.com/rails/rails/pull/16412))

*   `has_secure_password` ตอนนี้ตรวจสอบว่ารหัสผ่านที่กำหนดมีความยาวไม่เกิน 72 ตัวอักษรหากเปิดใช้งานการตรวจสอบ ([Pull Request](https://github.com/rails/rails/pull/15708))

Active Support
--------------

โปรดอ้างอิงที่ [Changelog][active-support] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `Numeric#ago`, `Numeric#until`, `Numeric#since`, `Numeric#from_now` ที่ถูกเลิกใช้ ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   ลบตัวสิ้นสุดที่ใช้สตริงเป็นพื้นฐานสำหรับ `ActiveSupport::Callbacks` ที่ถูกเลิกใช้ ([Pull Request](https://github.com/rails/rails/pull/15100))

### การเลิกใช้

*   เลิกใช้ `Kernel#silence_stderr`, `Kernel#capture` และ `Kernel#quietly` โดยไม่มีการแทนที่ ([Pull Request](https://github.com/rails/rails/pull/13392))

*   เลิกใช้ `Class#superclass_delegating_accessor` ใช้ `Class#class_attribute` แทน ([Pull Request](https://github.com/rails/rails/pull/14271))

*   เลิกใช้ `ActiveSupport::SafeBuffer#prepend!` เนื่องจาก `ActiveSupport::SafeBuffer#prepend` ทำงานเหมือนกัน ([Pull Request](https://github.com/rails/rails/pull/14529))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มตัวเลือกการกำหนดค่าใหม่ `active_support.test_order` เพื่อระบุลำดับที่ทดสอบเคสถูกดำเนินการ ตัวเลือกนี้เริ่มต้นเป็น `:sorted` แต่จะเปลี่ยนเป็น `:random` ใน Rails 5.0 ([Commit](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   `Object#try` และ `Object#try!` ตอนนี้สามารถใช้ได้โดยไม่ต้องระบุผู้รับโดยชัดเจนในบล็อก ([Commit](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830), [Pull Request](https://github.com/rails/rails/pull/17361))

*   เครื่องมือทดสอบ `travel_to` ตอนนี้ตัดส่วน `usec` เป็น 0 ([Commit](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   เพิ่ม `Object#itself` เป็นฟังก์ชันเอกลักษณ์ ([1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810), [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   `Object#with_options` ตอนนี้สามารถใช้ได้โดยไม่ต้องระบุผู้รับโดยชัดเจนในบล็อก ([Pull Request](https://github.com/rails/rails/pull/16339))

*   เพิ่ม `String#truncate_words` เพื่อตัดคำในสตริงตามจำนวนคำที่กำหนด ([Pull Request](https://github.com/rails/rails/pull/16190))

*   เพิ่ม `Hash#transform_values` และ `Hash#transform_values!` เพื่ออำนวยความสะดวกในกรณีที่ค่าของแฮชต้องเปลี่ยนแปลง แต่คีย์เหลือเดิม ([Pull Request](https://github.com/rails/rails/pull/15819))

*   เครื่องมือช่วย `humanize` ตอนนี้จะลบขีดล่างที่นำหน้าออก ([Commit](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   เพิ่ม `Concern#class_methods` เป็นทางเลือกในการใช้งาน `module ClassMethods` และ `Kernel#concern` เพื่อหลีกเลี่ยงการเขียนโค้ด boilerplate `module Foo; extend ActiveSupport::Concern; end` ([Commit](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   [คู่มือใหม่](autoloading_and_reloading_constants_classic_mode.html) เกี่ยวกับการโหลดและรีโหลดค่าคงที่

เครดิต
-------

ดู[รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](https://contributors.rubyonrails.org/) สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการทำให้ Rails เป็นเฟรมเวิร์กที่เสถียรและแข็งแกร่งที่มีให้ใช้งานในปัจจุบัน ยินดีด้วยทุกคน
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
