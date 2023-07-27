**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ddd82b1a207070829b1ec46e4bb40d80
เรื่องสำคัญใน Rails 5.1:

* รองรับ Yarn
* รองรับ Webpack แบบไม่บังคับ
* ไม่มี jQuery เป็นการติดตั้งเริ่มต้นอีกต่อไป
* ทดสอบระบบ
* การเข้ารหัสความลับ
* Mailer ที่มีพารามิเตอร์
* เส้นทางตรงและเส้นทางที่แก้ไข
* การรวม form_for และ form_tag เข้าด้วยกันเป็น form_with

เอกสารเวอร์ชันนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่เอกสารเปลี่ยนแปลงหรือตรวจสอบ [รายการคอมมิต](https://github.com/rails/rails/commits/5-1-stable) ในเรพอสิทอรีหลักของ Rails บน GitHub.

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 5.1
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 5.0 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 5.1 มีรายการสิ่งที่ควรระมัดระวังเมื่ออัปเกรดใน
[การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1)
คู่มือ.


คุณสมบัติหลัก
--------------

### รองรับ Yarn

[Pull Request](https://github.com/rails/rails/pull/26836)

Rails 5.1 ช่วยให้สามารถจัดการกับการขึ้นอยู่กันของ JavaScript จาก npm ผ่าน Yarn ได้ง่ายขึ้น สิ่งนี้จะทำให้ใช้ไลบรารีเช่น React, VueJS หรือไลบรารีอื่นๆจากโลกของ npm ได้ง่ายขึ้น Yarn รองรับการทำงานร่วมกับ asset pipeline เพื่อให้ได้ระบบขึ้นอยู่กันที่ทำงานได้อย่างราบรื่นกับแอปพลิเคชัน Rails 5.1

### รองรับ Webpack แบบไม่บังคับ

[Pull Request](https://github.com/rails/rails/pull/27288)

แอปพลิเคชัน Rails สามารถรวมกับ [Webpack](https://webpack.js.org/) ที่เป็นตัวรวมส่วน JavaScript ได้อย่างง่ายดายมากขึ้นโดยใช้ gem ใหม่ที่ชื่อ [Webpacker](https://github.com/rails/webpacker) ใช้ตัวเลือก `--webpack` เมื่อสร้างแอปพลิเคชันใหม่เพื่อเปิดใช้งานการรวมกับ Webpack

สิ่งนี้เป็นเวอร์ชันที่เข้ากันได้อย่างสมบูรณ์กับ asset pipeline ซึ่งคุณสามารถใช้ต่อไปสำหรับรูปภาพ เสียง และส่วนประกอบอื่นๆ คุณยังสามารถใช้รหัส JavaScript บางส่วนที่จัดการโดย asset pipeline และรหัสอื่นๆที่ประมวลผลผ่าน Webpack สิ่งทั้งหมดนี้จัดการโดยใช้ Yarn ซึ่งเปิดใช้งานโดยค่าเริ่มต้น

### ไม่มี jQuery เป็นการติดตั้งเริ่มต้นอีกต่อไป

[Pull Request](https://github.com/rails/rails/pull/27113)

jQuery จำเป็นต้องใช้งานตามค่าเริ่มต้นในเวอร์ชันก่อนหน้าของ Rails เพื่อให้มีคุณสมบัติเช่น `data-remote`, `data-confirm` และส่วนอื่นๆของ Unobtrusive JavaScript ของ Rails แต่ไม่จำเป็นต้องใช้งานอีกต่อไป เนื่องจาก UJS ได้รับการเขียนใหม่เพื่อใช้งาน JavaScript แบบธรรมดา โค้ดนี้ตอนนี้ได้รวมอยู่ใน Action View เป็น `rails-ujs`

คุณยังสามารถใช้ jQuery ได้หากต้องการ แต่ไม่จำเป็นต้องใช้งานตามค่าเริ่มต้นอีกต่อไป

### ทดสอบระบบ

[Pull Request](https://github.com/rails/rails/pull/26703)

Rails 5.1 มีการรองรับการเขียนทดสอบด้วย Capybara ในรูปแบบของ System tests คุณไม่ต้องกังวลเกี่ยวกับการกำหนดค่า Capybara และกลยุทธ์การล้างฐานข้อมูลสำหรับการทดสอบเช่นนี้อีกต่อไป Rails 5.1 มีการให้บริการ wrapper สำหรับการเรียกใช้งานทดสอบใน Chrome พร้อมกับคุณสมบัติเพิ่มเติมเช่นการแสดงภาพหน้าจอเมื่อเกิดความล้มเหลว

### การเข้ารหัสความลับ

[Pull Request](https://github.com/rails/rails/pull/28038)

Rails ตอนนี้สามารถจัดการความลับของแอปพลิเคชันได้อย่างปลอดภัย โดยใช้แรงบันดาลใจจาก gem [sekrets](https://github.com/ahoward/sekrets)

ใช้คำสั่ง `bin/rails secrets:setup` เพื่อตั้งค่าไฟล์ความลับที่เข้ารหัสใหม่ สิ่งนี้ยังจะสร้างคีย์หลักที่ต้องเก็บไว้นอกเหนือจากเรพอสิทอรี เรื่องความลับเองสามารถเก็บไว้ในระบบควบคุมการทบทวนรหัสในรูปแบบที่เข้ารหัส

ความลับจะถูกถอดรหัสในการดำเนินการจริงโดยใช้คีย์ที่เก็บไว้ entironment variable `RAILS_MASTER_KEY` หรือในไฟล์คีย์

### Mailer ที่มีพารามิเตอร์

[Pull Request](https://github.com/rails/rails/pull/27825)

ช่วยให้สามารถระบุพารามิเตอร์ที่ใช้ร่วมกันสำหรับทุกเมธอดในคลาส mailer เพื่อแบ่งปันตัวแปรอินสแตนซ์ เฮดเดอร์ และการตั้งค่าที่ใช้ร่วมกัน

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end
end
```

```ruby
InvitationsMailer.with(inviter: person_a, invitee: person_b)
                 .account_invitation.deliver_later
```

### เส้นทางตรงและเส้นทางที่แก้ไข

[Pull Request](https://github.com/rails/rails/pull/23138)

Rails 5.1 เพิ่มเมธอดสองเมธอดใหม่คือ `resolve` และ `direct` ใน DSL เส้นทาง เมธอด `resolve` ช่วยกำหนดการแมปโพลิมอร์ฟิกของโมเดลได้เอง
```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_for @basket do |form| %>
  <!-- แบบฟอร์มของตะกร้า -->
<% end %>
```

นี้จะสร้าง URL แบบเอกพจน์ `/basket` แทนที่จะเป็น `/baskets/:id` เช่นเคย

เมธอด `direct` ช่วยให้สร้างเฮลเปอร์ URL ที่กำหนดเองได้

```ruby
direct(:homepage) { "https://rubyonrails.org" }

homepage_url # => "https://rubyonrails.org"
```

ค่าที่ส่งกลับจากบล็อกต้องเป็นอาร์กิวเมนต์ที่ถูกต้องสำหรับเมธอด `url_for` ดังนั้นคุณสามารถส่งอาร์กิวเมนต์ URL สตริงที่ถูกต้อง แฮช อาร์เรย์ อินสแตนซ์ Active Model หรือคลาส Active Model

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### การรวม form_for และ form_tag เข้าด้วยกันใน form_with

[Pull Request](https://github.com/rails/rails/pull/26976)

ก่อน Rails 5.1 มีอินเตอร์เฟสสองอันสำหรับการจัดการฟอร์ม HTML: `form_for` สำหรับอินสแตนซ์โมเดลและ `form_tag` สำหรับ URL ที่กำหนดเอง

Rails 5.1 รวมทั้งสองอินเตอร์เฟสนี้เข้าด้วยกันด้วย `form_with` และสามารถสร้างแท็กฟอร์มขึ้นมาจาก URL, สโคป, หรือโมเดลได้

ใช้เฉพาะ URL:

```erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# จะสร้าง %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

การเพิ่มสโคปจะเติมคำนำหน้าชื่อฟิลด์อินพุต:

```erb
<%= form_with scope: :post, url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# จะสร้าง %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

การใช้โมเดลจะสร้าง URL และสโคปโดยอัตโนมัติ:

```erb
<%= form_with model: Post.new do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# จะสร้าง %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

การใช้โมเดลที่มีอยู่จะสร้างฟอร์มอัปเดตและกรอกค่าฟิลด์:

```erb
<%= form_with model: Post.first do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# จะสร้าง %>

<form action="/posts/1" method="post" data-remote="true">
  <input type="hidden" name="_method" value="patch">
  <input type="text" name="post[title]" value="<the title of the post>">
</form>
```

การไม่สามารถทำงานร่วมกันได้
-----------------

การเปลี่ยนแปลงต่อไปนี้อาจต้องการการดำเนินการทันทีหลังจากอัปเกรด

### การทดสอบแบบทรานแซกชันกับการเชื่อมต่อหลายตัว

การทดสอบแบบทรานแซกชันตอนนี้จะครอบคลุมการเชื่อมต่อ Active Record ทั้งหมดในการทำธุรกรรมฐานข้อมูล

เมื่อทดสอบสร้างเธรดเพิ่มเติม และเธรดเหล่านั้นได้รับการเชื่อมต่อฐานข้อมูล เธรดเหล่านั้นจะถูกจัดการเฉพาะ:

เธรดจะแบ่งปันการเชื่อมต่อเดียวกัน ซึ่งอยู่ภายในการทำธุรกรรมที่จัดการ นี้จะทำให้เธรดทั้งหมดเห็นฐานข้อมูลในสถานะเดียวกัน โดยไม่สนใจการทำธุรกรรมภายนอก ก่อนหน้านี้ เชื่อมต่อเพิ่มเติมเช่นนี้ไม่สามารถเห็นแถวข้อมูลตัวอย่างได้

เมื่อเธรดเข้าสู่การทำธุรกรรมซ้อนเข้าไป เธรดจะได้รับการใช้งานแบบสมัครเลือกของการเชื่อมต่อ เพื่อรักษาความเป็นอิสระ

หากการทดสอบของคุณใช้การเชื่อมต่อแยกต่างหากภายนอกการทำธุรกรรม คุณจะต้องเปลี่ยนไปใช้การจัดการการเชื่อมต่อที่ชัดเจนมากขึ้น

หากการทดสอบของคุณสร้างเธรดและเธรดเหล่านั้นมีการโต้ตอบพร้อมกันในขณะที่ใช้การทำธุรกรรมฐานข้อมูลแบบชัดเจน การเปลี่ยนแปลงนี้อาจเกิดความตายของกระบวนการ

วิธีง่ายที่สุดในการไม่ใช้พฤติกรรมใหม่นี้คือปิดใช้งานการทดสอบแบบทรานแซกชันบนกรณีทดสอบที่ได้รับผลกระทบ

Railties
--------

โปรดอ้างอิงที่ [Changelog][railties] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `config.static_cache_control` ที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/c861decd44198f8d7d774ee6a74194d1ac1a5a13))

*   ลบ `config.serve_static_files` ที่ถูกยกเลิก
    ([commit](https://github.com/rails/rails/commit/0129ca2eeb6d5b2ea8c6e6be38eeb770fe45f1fa))

*   ลบไฟล์ที่ถูกยกเลิก `rails/rack/debugger`
    ([commit](https://github.com/rails/rails/commit/7563bf7b46e6f04e160d664e284a33052f9804b8))

*   ลบงานที่ถูกยกเลิก: `rails:update`, `rails:template`, `rails:template:copy`,
    `rails:update:configs` และ `rails:update:bin`
    ([commit](https://github.com/rails/rails/commit/f7782812f7e727178e4a743aa2874c078b722eef))

*   ลบตัวแปรสภาพแวดล้อม `CONTROLLER` สำหรับงาน `routes`
    ([commit](https://github.com/rails/rails/commit/f9ed83321ac1d1902578a0aacdfe55d3db754219))

*   ลบตัวเลือก -j (--javascript) จากคำสั่ง `rails new`
    ([Pull Request](https://github.com/rails/rails/pull/28546))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มส่วนที่แชร์ใน `config/secrets.yml` ที่จะโหลดสำหรับทุก environment
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   ไฟล์ config `config/secrets.yml` ถูกโหลดด้วยคีย์ทั้งหมดเป็นสัญลักษณ์
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   ลบ jquery-rails ออกจากสแต็กเริ่มต้น และเพิ่ม rails-ujs ซึ่งจัดส่ง
*   เพิ่มการสนับสนุน Yarn ในแอปใหม่ด้วย yarn binstub และ package.json.
    ([Pull Request](https://github.com/rails/rails/pull/26836))

*   เพิ่มการสนับสนุน Webpack ในแอปใหม่ผ่านตัวเลือก `--webpack` ซึ่งจะเป็นการใช้งาน rails/webpacker gem.
    ([Pull Request](https://github.com/rails/rails/pull/27288))

*   เริ่มต้น Git repo เมื่อสร้างแอปใหม่หากไม่มีตัวเลือก `--skip-git`.
    ([Pull Request](https://github.com/rails/rails/pull/27632))

*   เพิ่ม encrypted secrets ใน `config/secrets.yml.enc`.
    ([Pull Request](https://github.com/rails/rails/pull/28038))

*   แสดงชื่อคลาส railtie ใน `rails initializers`.
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

โปรดอ้างอิงที่ [Changelog][action-cable] สำหรับการเปลี่ยนแปลงที่ละเอียด.

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มการสนับสนุน `channel_prefix` ใน Redis และ evented Redis adapters
    ใน `cable.yml` เพื่อหลีกเลี่ยงการชื่อซ้ำเมื่อใช้เซิร์ฟเวอร์ Redis เดียวกัน
    กับแอปพลิเคชันหลายๆ แอปพลิเคชัน.
    ([Pull Request](https://github.com/rails/rails/pull/27425))

*   เพิ่ม `ActiveSupport::Notifications` hook เพื่อส่งข้อมูลออกไปยังหลายๆ ที่พัก.
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

โปรดอ้างอิงที่ [Changelog][action-pack] สำหรับการเปลี่ยนแปลงที่ละเอียด.

### การลบ

*   ลบการสนับสนุนอาร์กิวเมนต์ที่ไม่ใช่คีย์เวิร์ดใน `#process`, `#get`, `#post`,
    `#patch`, `#put`, `#delete`, และ `#head` สำหรับคลาส `ActionDispatch::IntegrationTest`
    และ `ActionController::TestCase`.
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

*   ลบ `ActionDispatch::Callbacks.to_prepare` และ `ActionDispatch::Callbacks.to_cleanup`
    ที่ถูกยกเลิกแล้ว.
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

*   ลบเมธอดที่ถูกยกเลิกที่เกี่ยวข้องกับตัวกรองของคอนโทรลเลอร์.
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

*   ลบการสนับสนุนที่ถูกยกเลิกสำหรับ `:text` และ `:nothing` ใน `render`.
    ([Commit](https://github.com/rails/rails/commit/79a5ea9eadb4d43b62afacedc0706cbe88c54496),
    [Commit](https://github.com/rails/rails/commit/57e1c99a280bdc1b324936a690350320a1cd8111))

*   ลบการสนับสนุนที่ถูกยกเลิกในการเรียกใช้เมธอดของ `HashWithIndifferentAccess` บน `ActionController::Parameters`.
    ([Commit](https://github.com/rails/rails/pull/26746/commits/7093ceb480ad6a0a91b511832dad4c6a86981b93))

### การเลิกใช้

*   เลิกใช้ `config.action_controller.raise_on_unfiltered_parameters`.
    ไม่มีผลใน Rails 5.1.
    ([Commit](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มเมธอด `direct` และ `resolve` ใน routing DSL.
    ([Pull Request](https://github.com/rails/rails/pull/23138))

*   เพิ่มคลาสใหม่ `ActionDispatch::SystemTestCase` เพื่อเขียนเทสระบบในแอปพลิเคชันของคุณ.
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียด.

### การลบ

*   ลบ `#original_exception` ที่ถูกยกเลิกใน `ActionView::Template::Error`.
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

*   ลบตัวเลือก `encode_special_chars` ที่ผิดชื่อจาก `strip_tags`.
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### การเลิกใช้

*   เลิกใช้ Erubis ERB handler ในการสนับสนุน Erubi.
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### การเปลี่ยนแปลงที่
*   ยกเลิกการใช้งาน `supports_migrations?` ในตัวอักษรเชื่อมต่อ
    ([Pull Request](https://github.com/rails/rails/pull/28172))

*   ยกเลิกการใช้งาน `Migrator.schema_migrations_table_name` ใช้ `SchemaMigration.table_name` แทน
    ([Pull Request](https://github.com/rails/rails/pull/28351))

*   ยกเลิกการใช้งาน `#quoted_id` ในการอ้างอิงและแปลงประเภท
    ([Pull Request](https://github.com/rails/rails/pull/27962))

*   ยกเลิกการส่ง `default` argument ไปยัง `#index_name_exists?`
    ([Pull Request](https://github.com/rails/rails/pull/26930))

### การเปลี่ยนแปลงที่สำคัญ

*   เปลี่ยน Primary Keys เริ่มต้นเป็น BIGINT
    ([Pull Request](https://github.com/rails/rails/pull/26266))

*   เพิ่มการสนับสนุนคอลัมน์เสมือน/สร้างสำหรับ MySQL 5.7.5+ และ MariaDB 5.2.0+
    ([Commit](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

*   เพิ่มการสนับสนุนการจำกัดในการประมวลผลแบทช์
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   ทดสอบแบบทรานแซกชันเรียกใช้การเชื่อมต่อ Active Record ทั้งหมดในการทำธุรกรรมฐานข้อมูล
    ([Pull Request](https://github.com/rails/rails/pull/28726))

*   ข้ามคอมเมนต์ในผลลัพธ์ของคำสั่ง `mysqldump` โดยค่าเริ่มต้น
    ([Pull Request](https://github.com/rails/rails/pull/23301))

*   แก้ไข `ActiveRecord::Relation#count` เพื่อใช้ `Enumerable#count` ของ Ruby ในการนับเร็คคอร์ดเมื่อมีการส่งบล็อกเป็นอาร์กิวเมนต์แทนที่จะเพิกเฉยๆ ไม่สนใจบล็อกที่ส่งผ่าน
    ([Pull Request](https://github.com/rails/rails/pull/24203))

*   ส่ง `"-v ON_ERROR_STOP=1"` พร้อมกับคำสั่ง `psql` เพื่อไม่ย่อยค่าผิดพลาด SQL
    ([Pull Request](https://github.com/rails/rails/pull/24773))

*   เพิ่ม `ActiveRecord::Base.connection_pool.stat`
    ([Pull Request](https://github.com/rails/rails/pull/26988))

*   การสืบทอดโดยตรงจาก `ActiveRecord::Migration` จะเกิดข้อผิดพลาด
    ระบุเวอร์ชัน Rails สำหรับการเขียน Migration
    ([Commit](https://github.com/rails/rails/commit/249f71a22ab21c03915da5606a063d321f04d4d3))

*   จะเกิดข้อผิดพลาดเมื่อการสมาชิก `through` มีชื่อการสะท้อนที่ไม่แน่ชัด
    ([Commit](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

โปรดอ้างอิงที่ [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบเมธอดที่ถูกยกเลิกใน `ActiveModel::Errors`
    ([commit](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

*   ลบตัวเลือก `:tokenizer` ที่ถูกยกเลิกในตัวตรวจสอบความยาว
    ([commit](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

*   ลบพฤติกรรมที่ถูกยกเลิกที่หยุดการเรียกเช็คบาล็อกเมื่อค่าส่งกลับเป็นเท็จ
    ([commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### การเปลี่ยนแปลงที่สำคัญ

*   สตริงต้นฉบับที่กำหนดให้กับแอตทริบิวต์ของโมเดลจะไม่ถูกแช่แข็งอีกต่อไป
    ([Pull Request](https://github.com/rails/rails/pull/28729))

Active Job
-----------

โปรดอ้างอิงที่ [Changelog][active-job] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการสนับสนุนที่ถูกยกเลิกในการส่งคลาสอะแดปเตอร์ไปยัง `.queue_adapter`
    ([commit](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   ลบ `#original_exception` ที่ถูกยกเลิกใน `ActiveJob::DeserializationError`
    ([commit](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มการจัดการข้อผิดพลาดแบบสร้างคำสั่งผ่าน `ActiveJob::Base.retry_on` และ `ActiveJob::Base.discard_on`
    ([Pull Request](https://github.com/rails/rails/pull/25991))

*   ส่งตัวอย่างงานเพื่อให้คุณสามารถเข้าถึงสิ่งที่เกี่ยวข้องเช่น `job.arguments` ในตรรกะหลังการลองทำงานล้มเหลว
    ([commit](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

Active Support
--------------

โปรดอ้างอิงที่ [Changelog][active-support] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบคลาส `ActiveSupport::Concurrency::Latch`
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
