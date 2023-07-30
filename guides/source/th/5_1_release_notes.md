**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ddd82b1a207070829b1ec46e4bb40d80
เนื้อหาสำคัญใน Rails 5.1:
==============

* รองรับ Yarn
* รองรับ Webpack แบบไม่บังคับ
* jQuery ไม่เป็นการติดตั้งเริ่มต้นอีกต่อไป
* การทดสอบระบบ
* การเข้ารหัสความลับ
* การใช้พารามิเตอร์ในเมลเลอร์
* เส้นทางตรงและเส้นทางที่แก้ไขแล้ว
* การรวม form_for และ form_tag เข้าด้วยกันใน form_with

เอกสารเวอร์ชันนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่เอกสารเปลี่ยนแปลงหรือตรวจสอบ [รายการของการเปลี่ยนแปลง](https://github.com/rails/rails/commits/5-1-stable) ในเก็บรักษาของ Rails ที่ GitHub

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 5.1
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 5.0 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานได้ตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 5.1 มีรายการสิ่งที่ควรระวังเมื่ออัปเกรดใน
[การอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1)
คู่มือ

คุณสมบัติหลัก
--------------

### รองรับ Yarn

[Pull Request](https://github.com/rails/rails/pull/26836)

Rails 5.1 ช่วยให้สามารถจัดการกับการขึ้นอยู่กันของ JavaScript จาก npm ผ่าน Yarn ได้ง่ายขึ้น สิ่งนี้จะทำให้ใช้ไลบรารีเช่น React, VueJS หรือไลบรารีอื่นๆจากโลกของ npm ได้ง่ายขึ้น Yarn รองรับการทำงานร่วมกับ asset pipeline เพื่อให้ทุกขึ้นอยู่กันทำงานได้อย่างราบรื่นกับแอปพลิเคชัน Rails 5.1

### รองรับ Webpack แบบไม่บังคับ

[Pull Request](https://github.com/rails/rails/pull/27288)

แอปพลิเคชัน Rails สามารถรวมกับ [Webpack](https://webpack.js.org/) ที่เป็นตัวรวมส่วน JavaScript ได้อย่างง่ายดายมากขึ้นโดยใช้ gem [Webpacker](https://github.com/rails/webpacker) ใหม่ ใช้ตัวเลือก `--webpack` เมื่อสร้างแอปพลิเคชันใหม่เพื่อเปิดใช้งานการรวมกับ Webpack

สิ่งนี้เป็นเวอร์ชันที่เข้ากันได้อย่างสมบูรณ์กับ asset pipeline ซึ่งคุณสามารถใช้ต่อไปสำหรับรูปภาพ เสียง และทรัพยากรอื่นๆ คุณยังสามารถมีรหัส JavaScript บางส่วนที่จัดการโดย asset pipeline และรหัสอื่นที่ประมวลผลผ่าน Webpack ทั้งหมดนี้จัดการโดย Yarn ซึ่งเปิดใช้งานโดยค่าเริ่มต้น

### jQuery ไม่เป็นการติดตั้งเริ่มต้นอีกต่อไป
[Pull Request](https://github.com/rails/rails/pull/27113)

jQuery ถูกต้องต้องใช้ในเวอร์ชันก่อนหน้าของ Rails เพื่อให้มีคุณสมบัติเช่น `data-remote`, `data-confirm` และส่วนอื่น ๆ ของ Unobtrusive JavaScript ของ Rails แต่ไม่จำเป็นต้องใช้แล้ว เนื่องจาก UJS ได้รับการเขียนใหม่เพื่อใช้งานด้วย JavaScript ธรรมดา โค้ดนี้ตอนนี้ถูกจัดส่งพร้อมกับ Action View เป็น `rails-ujs`

คุณยังสามารถใช้ jQuery ได้หากต้องการ แต่ไม่จำเป็นต้องใช้โดยค่าเริ่มต้น

### การทดสอบระบบ

[Pull Request](https://github.com/rails/rails/pull/26703)

Rails 5.1 มีการสนับสนุนการเขียนการทดสอบด้วย Capybara แบบฝังอยู่ในระบบ ในรูปแบบของการทดสอบระบบ (System tests) คุณไม่ต้องกังวลเกี่ยวกับการกำหนดค่า Capybara และกลยุทธ์การล้างฐานข้อมูลสำหรับการทดสอบเช่นนี้แล้ว Rails 5.1 มีการให้ Wrapper สำหรับการเรียกใช้งานทดสอบใน Chrome พร้อมกับคุณสมบัติเพิ่มเติม เช่น การบันทึกภาพหน้าจอเมื่อเกิดข้อผิดพลาด

### การเข้ารหัสความลับ

[Pull Request](https://github.com/rails/rails/pull/28038)

Rails ตอนนี้อนุญาตให้จัดการความลับของแอปพลิเคชันอย่างปลอดภัย โดยได้รับแรงบันดาลใจจาก gem [sekrets](https://github.com/ahoward/sekrets)

รัน `bin/rails secrets:setup` เพื่อตั้งค่าไฟล์ความลับที่เข้ารหัสใหม่ นี่ยังจะสร้างคีย์หลักซึ่งต้องเก็บไว้นอกเก็บข้อมูลเพื่อรักษาความปลอดภัย ความลับเองสามารถเก็บไว้ในระบบควบคุมการทบทวนรหัสภายในในรูปแบบที่เข้ารหัส

ความลับจะถูกถอดรหัสในโปรดักชันโดยใช้คีย์ที่เก็บไว้ entironment variable `RAILS_MASTER_KEY` หรือในไฟล์คีย์

### การส่งอีเมลพารามิเตอร์

[Pull Request](https://github.com/rails/rails/pull/27825)

อนุญาตให้ระบุพารามิเตอร์ที่ใช้ร่วมกันสำหรับเมธอดทั้งหมดในคลาสเมลเลอร์เพื่อแชร์ตัวแปรอินสแตนซ์, ส่วนหัว และการตั้งค่าที่ใช้ร่วมกัน

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

### เส้นทางโดยตรงและเส้นทางที่แก้ไข

[Pull Request](https://github.com/rails/rails/pull/23138)

Rails 5.1 เพิ่มเมธอดสองเมธอดใหม่คือ `resolve` และ `direct` ใน DSL ของเส้นทาง เมธอด `resolve` ช่วยให้สามารถกำหนดการแมปโพลิมอร์ฟิกของโมเดลได้เอง
```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_for @basket do |form| %>
  <!-- แบบฟอร์มของตะกร้า -->
<% end %>
```

นี้จะสร้าง URL แบบเอกพจน์ `/basket` แทนที่จะเป็น `/baskets/:id` ตามปกติ

เมธอด `direct` ช่วยในการสร้าง URL helpers ที่กำหนดเอง

```ruby
direct(:homepage) { "https://rubyonrails.org" }

homepage_url # => "https://rubyonrails.org"
```

ค่าที่ส่งกลับจาก block ต้องเป็นอาร์กิวเมนต์ที่ถูกต้องสำหรับเมธอด `url_for` ดังนั้นคุณสามารถส่งค่า URL ที่ถูกต้องเป็นสตริง, แฮช, อาร์เรย์, อินสแตนซ์ของ Active Model หรือคลาส Active Model

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### การรวม form_for และ form_tag เข้าด้วยกันเป็น form_with

[Pull Request](https://github.com/rails/rails/pull/26976)

ก่อน Rails 5.1 มีอินเตอร์เฟสสองอันในการจัดการฟอร์ม HTML: `form_for` สำหรับอินสแตนซ์ของโมเดลและ `form_tag` สำหรับ URL ที่กำหนดเอง

Rails 5.1 รวมทั้งสองอินเตอร์เฟสเข้าด้วยกันด้วย `form_with` และสามารถสร้างแท็กฟอร์มขึ้นมาจาก URL, สโคป, หรือโมเดลได้

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

การเพิ่มสโคปจะเติมคำนำหน้าชื่อฟิลด์ของอินพุต:

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

การใช้โมเดลที่มีอยู่จะสร้างฟอร์มแก้ไขและกรอกค่าในฟิลด์:

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
ความไม่เข้ากัน
-----------------

การเปลี่ยนแปลงต่อไปนี้อาจต้องการการดำเนินการทันทีหลังจากอัปเกรด

### การทดสอบแบบทรานแซกชันกับการเชื่อมต่อหลายตัว

การทดสอบแบบทรานแซกชันตอนนี้จะครอบคลุมการเชื่อมต่อ Active Record ทั้งหมดในการทำธุรกรรมฐานข้อมูล

เมื่อทดสอบสร้างเธรดเพิ่มเติม และเธรดเหล่านั้นได้รับการเชื่อมต่อฐานข้อมูล เธรดเหล่านั้นจะถูกจัดการเฉพาะเจาะจง:

เธรดจะแบ่งปันการเชื่อมต่อเดียวกัน ซึ่งอยู่ภายในการทำธุรกรรมที่จัดการ นี้จะทำให้เธรดทั้งหมดเห็นฐานข้อมูลในสถานะเดียวกัน โดยไม่สนใจการทำธุรกรรมที่อยู่ภายนอกสุด ก่อนหน้านี้การเชื่อมต่อเพิ่มเติมเช่นนี้ไม่สามารถเห็นแถวข้อมูลตัวอย่างได้ เป็นต้น

เมื่อเธรดเข้าสู่การทำธุรกรรมที่ซ้อนกัน เธรดจะได้รับการใช้การเชื่อมต่อที่เป็นเอกลักษณ์ชั่วคราว เพื่อรักษาความเป็นอิสระ

หากการทดสอบของคุณใช้การเชื่อมต่อแยกต่างหากภายนอกการทำธุรกรรมในเธรดที่สร้างขึ้น คุณจะต้องเปลี่ยนไปใช้การจัดการการเชื่อมต่อที่ชัดเจนมากขึ้น

หากการทดสอบของคุณสร้างเธรดและเธรดเหล่านั้นมีการปฏิสัมพันธ์ในขณะที่ใช้การทำธุรกรรมฐานข้อมูลที่ชัดเจน การเปลี่ยนแปลงนี้อาจทำให้เกิดการติดขัด

วิธีที่ง่ายที่สุดในการไม่ใช้พฤติกรรมใหม่นี้คือปิดใช้งานการทดสอบแบบทรานแซกชันในกรณีที่มีผลต่อกรณีทดสอบใด ๆ

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

*   เพิ่มส่วนที่แบ่งปันใน `config/secrets.yml` ที่จะโหลดสำหรับทุก environment
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   ไฟล์ config `config/secrets.yml` ถูกโหลดเข้ามาพร้อมกับคีย์ทั้งหมดเป็นสัญลักษณ์
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   ลบ jquery-rails ออกจากสแต็กเริ่มต้น และเพิ่ม rails-ujs ซึ่งจัดส่งพร้อมกับ Action View เป็นตัวอย่าง UJS ที่เริ่มต้น
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   เพิ่มการสนับสนุน Yarn ในแอปใหม่ด้วย yarn binstub และ package.json
    ([Pull Request](https://github.com/rails/rails/pull/26836))
*   เพิ่มการสนับสนุน Webpack ในแอปใหม่ผ่านตัวเลือก `--webpack` ซึ่งจะส่งงานให้กับ gem rails/webpacker
    ([Pull Request](https://github.com/rails/rails/pull/27288))

*   เริ่มต้น Git repo เมื่อสร้างแอปใหม่ หากไม่มีตัวเลือก `--skip-git`
    ([Pull Request](https://github.com/rails/rails/pull/27632))

*   เพิ่ม encrypted secrets ใน `config/secrets.yml.enc`
    ([Pull Request](https://github.com/rails/rails/pull/28038))

*   แสดงชื่อคลาส railtie ใน `rails initializers`
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

โปรดอ้างอิงที่ [Changelog][action-cable] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มการสนับสนุน `channel_prefix` ใน Redis และ evented Redis adapters
    ใน `cable.yml` เพื่อหลีกเลี่ยงการชื่อซ้ำเมื่อใช้เซิร์ฟเวอร์ Redis เดียวกัน
    กับแอปพลิเคชันหลายๆ แอปพลิเคชัน
    ([Pull Request](https://github.com/rails/rails/pull/27425))

*   เพิ่ม `ActiveSupport::Notifications` hook เพื่อส่งข้อมูลออกไปยังหลายๆ ที่พบ
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

โปรดอ้างอิงที่ [Changelog][action-pack] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการสนับสนุนสำหรับอาร์กิวเมนต์ที่ไม่ใช่คีย์เวิร์ดใน `#process`, `#get`, `#post`,
    `#patch`, `#put`, `#delete`, และ `#head` สำหรับคลาส `ActionDispatch::IntegrationTest`
    และ `ActionController::TestCase`
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

*   ลบ `ActionDispatch::Callbacks.to_prepare` และ `ActionDispatch::Callbacks.to_cleanup`
    ที่ถูกเลิกใช้
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

*   ลบเมธอดที่ถูกเลิกใช้ที่เกี่ยวข้องกับตัวกรองของคอนโทรลเลอร์
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

*   ลบการสนับสนุนที่ถูกเลิกใช้สำหรับ `:text` และ `:nothing` ใน `render`
    ([Commit](https://github.com/rails/rails/commit/79a5ea9eadb4d43b62afacedc0706cbe88c54496),
    [Commit](https://github.com/rails/rails/commit/57e1c99a280bdc1b324936a690350320a1cd8111))

*   ลบการสนับสนุนที่ถูกเลิกใช้สำหรับการเรียกใช้เมธอดของ `HashWithIndifferentAccess` บน `ActionController::Parameters`
    ([Commit](https://github.com/rails/rails/pull/26746/commits/7093ceb480ad6a0a91b511832dad4c6a86981b93))

### การเลิกใช้

*   เลิกใช้ `config.action_controller.raise_on_unfiltered_parameters`
    ไม่มีผลใน Rails 5.1
    ([Commit](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มเมธอด `direct` และ `resolve` ใน DSL ของการเรียกเส้นทาง
    ([Pull Request](https://github.com/rails/rails/pull/23138))

*   เพิ่มคลาสใหม่ `ActionDispatch::SystemTestCase` เพื่อเขียนเทสระบบในแอปพลิเคชันของคุณ
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

โปรดอ้างอิงที่ [Changelog][action-view] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบ `#original_exception` ที่ถูกเลิกใช้ใน `ActionView::Template::Error`
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

*   ลบตัวเลือก `encode_special_chars` ที่ผิดชื่อจาก `strip_tags`
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### การเลิกใช้

*   เลิกใช้ Erubis ERB handler และใช้ Erubi แทน
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### การเปลี่ยนแปลงที่สำคัญ

*   Raw template handler (template handler เริ่มต้นใน Rails 5) ตอนนี้แสดงผลเป็นสตริงที่ปลอดภัยสำหรับ HTML
    ([commit](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

*   เปลี่ยน `datetime_field` และ `datetime_field_tag` เพื่อสร้างฟิลด์ `datetime-local`
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   ไวยากรณ์ใหม่แบบ Builder-style สำหรับแท็ก HTML (`tag.div`, `tag.br`, เป็นต้น)
    ([Pull Request](https://github.com/rails/rails/pull/25543))
*   เพิ่ม `form_with` เพื่อรวมการใช้งาน `form_tag` และ `form_for` เข้าด้วยกัน
    ([Pull Request](https://github.com/rails/rails/pull/26976))

*   เพิ่มตัวเลือก `check_parameters` ให้กับ `current_page?`
    ([Pull Request](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog][action-mailer] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

*   อนุญาตให้ตั้งค่าประเภทเนื้อหาที่กำหนดเองเมื่อมีการแนบแฟ้มและตั้งค่าเนื้อหาในบรรทัดเดียวกัน
    ([Pull Request](https://github.com/rails/rails/pull/27227))

*   อนุญาตให้ส่ง lambda เป็นค่าให้กับเมธอด `default`
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   เพิ่มการสนับสนุนการเรียกใช้ mailer ที่มีพารามิเตอร์เป็นพารามิเตอร์ที่กำหนดได้เพื่อแชร์ตัวกรองก่อนและค่าเริ่มต้น
    ระหว่างการกระทำของ mailer ที่แตกต่างกัน
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   ส่งอาร์กิวเมนต์ที่รับเข้ามาให้กับการกระทำของ mailer ไปยังเหตุการณ์ `process.action_mailer` ในรูปแบบของคีย์ `args`
    ([Pull Request](https://github.com/rails/rails/pull/27900))

Active Record
-------------

โปรดอ้างอิงที่ [Changelog][active-record] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบออก

*   เอาการสนับสนุนการส่งอาร์กิวเมนต์และบล็อกพร้อมกันออกจาก `ActiveRecord::QueryMethods#select`
    ([Commit](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

*   เอา i18n scopes `activerecord.errors.messages.restrict_dependent_destroy.one` และ
    `activerecord.errors.messages.restrict_dependent_destroy.many` ที่ถูกเลิกใช้ออก
    ([Commit](https://github.com/rails/rails/commit/00e3973a311))

*   เอาการสนับสนุนการรีโหลดแบบบังคับออกจาก singular และ collection association readers
    ([Commit](https://github.com/rails/rails/commit/09cac8c67af))

*   เอาการสนับสนุนการส่งคอลัมน์เป็นค่าให้กับ `#quote` ที่ถูกเลิกใช้ออก
    ([Commit](https://github.com/rails/rails/commit/e646bad5b7c))

*   เอาอาร์กิวเมนต์ `name` ที่ถูกเลิกใช้ออกจาก `#tables`
    ([Commit](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

*   เอาพฤติกรรมที่ถูกเลิกใช้ของ `#tables` และ `#table_exists?` ที่จะส่งกลับเฉพาะตารางและไม่ใช่วิวออก
    ([Commit](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

*   เอาอาร์กิวเมนต์ `original_exception` ใน `ActiveRecord::StatementInvalid#initialize`
    และ `ActiveRecord::StatementInvalid#original_exception` ที่ถูกเลิกใช้ออก
    ([Commit](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

*   เอาการสนับสนุนในการส่งคลาสเป็นค่าในคิวรีที่ถูกเลิกใช้ออก
    ([Commit](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

*   เอาการสนับสนุนในการคิวรีโดยใช้เครื่องหมายจุลภาคใน LIMIT ที่ถูกเลิกใช้ออก
    ([Commit](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

*   เอาพารามิเตอร์ `conditions` ออกจาก `#destroy_all` ที่ถูกเลิกใช้ออก
    ([Commit](https://github.com/rails/rails/commit/d31a6d1384cd740c8518d0bf695b550d2a3a4e9b))

*   เอาพารามิเตอร์ `conditions` ออกจาก `#delete_all` ที่ถูกเลิกใช้ออก
    ([Commit](https://github.com/rails/rails/pull/27503/commits/e7381d289e4f8751dcec9553dcb4d32153bd922b))

*   เอาเมธอด `#load_schema_for` ที่ถูกเลิกใช้ออกและใช้ `#load_schema` แทน
    ([Commit](https://github.com/rails/rails/commit/419e06b56c3b0229f0c72d3e4cdf59d34d8e5545))

*   เอาการกำหนดค่า `#raise_in_transactional_callbacks` ที่ถูกเลิกใช้ออก
    ([Commit](https://github.com/rails/rails/commit/8029f779b8a1dd9848fee0b7967c2e0849bf6e07))

*   เอาการกำหนดค่า `#use_transactional_fixtures` ที่ถูกเลิกใช้ออก
    ([Commit](https://github.com/rails/rails/commit/3955218dc163f61c932ee80af525e7cd440514b3))

### การเลิกใช้

*   เลิกใช้ตัวแปร `error_on_ignored_order_or_limit` และใช้ `error_on_ignored_order` แทน
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   เลิกใช้ `sanitize_conditions` และใช้ `sanitize_sql` แทน
    ([Pull Request](https://github.com/rails/rails/pull/25999))

*   เลิกใช้ `supports_migrations?` ใน connection adapters
    ([Pull Request](https://github.com/rails/rails/pull/28172))

*   เลิกใช้ `Migrator.schema_migrations_table_name` ใช้ `SchemaMigration.table_name` แทน
    ([Pull Request](https://github.com/rails/rails/pull/28351))

*   เลิกใช้ `#quoted_id` ในการอ้างอิงและแปลงประเภท
    ([Pull Request](https://github.com/rails/rails/pull/27962))
*   ยกเลิกการส่งอาร์กิวเมนต์ `default` ให้กับ `#index_name_exists?`
    ([Pull Request](https://github.com/rails/rails/pull/26930))

### การเปลี่ยนแปลงที่สำคัญ

*   เปลี่ยน Primary Keys เริ่มต้นเป็น BIGINT
    ([Pull Request](https://github.com/rails/rails/pull/26266))

*   รองรับคอลัมน์เสมือน/สร้างขึ้นสำหรับ MySQL 5.7.5+ และ MariaDB 5.2.0+
    ([Commit](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

*   เพิ่มการสนับสนุนขีดจำกัดในการประมวลผลแบทช์
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   ทดสอบแบบทรานแซกชันกลุ่มทั้งหมดของการเชื่อมต่อ Active Record ในฐานข้อมูล
    ([Pull Request](https://github.com/rails/rails/pull/28726))

*   ข้ามคอมเมนต์ในผลลัพธ์ของคำสั่ง `mysqldump` โดยค่าเริ่มต้น
    ([Pull Request](https://github.com/rails/rails/pull/23301))

*   แก้ไข `ActiveRecord::Relation#count` เพื่อใช้ `Enumerable#count` ของ Ruby ในการนับเรคคอร์ดเมื่อมีการส่งบล็อกเป็นอาร์กิวเมนต์แทนที่จะละเว้นบล็อกที่ส่งผ่าน
    ([Pull Request](https://github.com/rails/rails/pull/24203))

*   ส่งค่า `"-v ON_ERROR_STOP=1"` พร้อมกับคำสั่ง `psql` เพื่อไม่ซ่อนข้อผิดพลาด SQL
    ([Pull Request](https://github.com/rails/rails/pull/24773))

*   เพิ่ม `ActiveRecord::Base.connection_pool.stat`
    ([Pull Request](https://github.com/rails/rails/pull/26988))

*   การสืบทอดโดยตรงจาก `ActiveRecord::Migration` จะเกิดข้อผิดพลาด
    ระบุเวอร์ชัน Rails ที่เขียน Migration สำหรับ
    ([Commit](https://github.com/rails/rails/commit/249f71a22ab21c03915da5606a063d321f04d4d3))

*   เกิดข้อผิดพลาดเมื่อมีการสร้าง `through` association ที่มีชื่อ reflection ที่ไม่แน่ชัด
    ([Commit](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

โปรดอ้างอิง [Changelog][active-model] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบเมธอดที่ถูกยกเลิกใน `ActiveModel::Errors`
    ([commit](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

*   ลบตัวเลือก `:tokenizer` ที่ถูกยกเลิกในตัวตรวจสอบความยาว
    ([commit](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

*   ลบพฤติกรรมที่ถูกยกเลิกที่หยุดการเรียกใช้งาน callback เมื่อค่าที่ส่งกลับเป็นเท็จ
    ([commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### การเปลี่ยนแปลงที่สำคัญ

*   สตริงเดิมที่กำหนดให้กับแอตทริบิวต์ของโมเดลจะไม่ถูกแช่แข็งอย่างไม่ถูกต้องอีกต่อไป
    ([Pull Request](https://github.com/rails/rails/pull/28729))

Active Job
-----------

โปรดอ้างอิง [Changelog][active-job] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบการสนับสนุนที่ถูกยกเลิกในการส่งคลาสแอดาปเตอร์ไปยัง `.queue_adapter`
    ([commit](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   ลบ `#original_exception` ที่ถูกยกเลิกใน `ActiveJob::DeserializationError`
    ([commit](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### การเปลี่ยนแปลงที่สำคัญ

*   เพิ่มการจัดการข้อผิดพลาดแบบสร้างคำสั่งผ่าน `ActiveJob::Base.retry_on` และ `ActiveJob::Base.discard_on`
    ([Pull Request](https://github.com/rails/rails/pull/25991))

*   ส่งคืนตัวอย่างงานเพื่อให้คุณสามารถเข้าถึงสิ่งต่าง ๆ เช่น `job.arguments` ในตรรกะหลังการลองทำงานใหม่ล้มเหลว
    ([commit](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

Active Support
--------------

โปรดอ้างอิง [Changelog][active-support] สำหรับการเปลี่ยนแปลงที่ละเอียด

### การลบ

*   ลบคลาส `ActiveSupport::Concurrency::Latch`
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   ลบ `halt_callback_chains_on_return_false`
    ([Commit](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))

*   ลบพฤติกรรมที่ถูกยกเลิกที่หยุดการเรียกใช้งาน callback เมื่อค่าที่ส่งกลับเป็นเท็จ
    ([Commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))
### การยกเลิกการใช้งาน

*   คลาส `HashWithIndifferentAccess` ระดับบนสุดถูกยกเลิกการใช้งานอย่างอ่อนไหวแล้ว
    เพื่อใช้แทนด้วย `ActiveSupport::HashWithIndifferentAccess` แทน
    ([Pull Request](https://github.com/rails/rails/pull/28157))

*   การส่งสตริงเป็นพารามิเตอร์ใน `:if` และ `:unless` ตัวเลือกเงื่อนไขใน `set_callback` และ `skip_callback` ถูกยกเลิกการใช้งาน
    ([Commit](https://github.com/rails/rails/commit/0952552))

### การเปลี่ยนแปลงที่สำคัญ

*   แก้ไขการแปลงระยะเวลาและการเดินทางเพื่อให้สอดคล้องกันในการเปลี่ยนเวลาออกแสดงผล
    ([Commit](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [Pull Request](https://github.com/rails/rails/pull/26597))

*   อัปเดต Unicode เป็นเวอร์ชัน 9.0.0
    ([Pull Request](https://github.com/rails/rails/pull/27822))

*   เพิ่ม Duration#before และ #after เป็นตัวแทนสำหรับ #ago และ #since
    ([Pull Request](https://github.com/rails/rails/pull/27721))

*   เพิ่ม `Module#delegate_missing_to` เพื่อส่งการเรียกเมธอดที่ไม่ได้ถูกกำหนดสำหรับวัตถุปัจจุบันไปยังวัตถุพร็อกซี
    ([Pull Request](https://github.com/rails/rails/pull/23930))

*   เพิ่ม `Date#all_day` ซึ่งคืนค่าช่วงเวลาทั้งวันของวันที่และเวลาปัจจุบัน
    ([Pull Request](https://github.com/rails/rails/pull/24930))

*   นำเข้าเมธอด `assert_changes` และ `assert_no_changes` สำหรับการทดสอบ
    ([Pull Request](https://github.com/rails/rails/pull/25393))

*   เมธอด `travel` และ `travel_to` ตอนนี้จะเกิดข้อผิดพลาดเมื่อมีการเรียกซ้อน
    ([Pull Request](https://github.com/rails/rails/pull/24890))

*   อัปเดต `DateTime#change` เพื่อรองรับ usec และ nsec
    ([Pull Request](https://github.com/rails/rails/pull/28242))

เครดิต
-------

ดู
[รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](https://contributors.rubyonrails.org/) สำหรับ
ผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและทนทาน ยินดีด้วยทุกคน
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
