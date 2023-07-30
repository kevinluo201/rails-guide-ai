**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a4b9132308ed3786777061bd137af660
ภาพรวมของ Action Text
====================

เอกสารนี้จะให้คุณทราบทุกสิ่งที่คุณต้องการเพื่อเริ่มต้นในการจัดการเนื้อหา Rich Text

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีการกำหนดค่า Action Text
* วิธีการจัดการเนื้อหา Rich Text
* วิธีการจัดรูปแบบเนื้อหา Rich Text และไฟล์แนบ

--------------------------------------------------------------------------------

Action Text คืออะไร?
--------------------

Action Text นำเนื้อหาและการแก้ไข Rich Text มาให้ใช้กับ Rails โดยมี [Trix editor](https://trix-editor.org) ซึ่งจัดการทุกอย่างตั้งแต่การจัดรูปแบบ การสร้างลิงก์ การเพิ่มคำคม การสร้างรายการ การแทรกรูปภาพและแกลเลอรี
เนื้อหา Rich Text ที่สร้างขึ้นโดย Trix editor จะถูกบันทึกในตาราง RichText ที่เป็นของตัวเองและเชื่อมโยงกับ Active Record model ใดๆ ในแอปพลิเคชัน
รูปภาพแนบ (หรือไฟล์แนบอื่นๆ) จะถูกเก็บไว้โดยอัตโนมัติโดยใช้ Active Storage และเชื่อมโยงกับตาราง RichText ที่รวมอยู่

## Trix เปรียบเทียบกับ Rich Text Editors อื่นๆ

เครื่องมือแก้ไข WYSIWYG ส่วนใหญ่เป็นตัวครอบ HTML's `contenteditable` และ `execCommand` APIs ที่ออกแบบโดย Microsoft เพื่อสนับสนุนการแก้ไขเนื้อหาของหน้าเว็บใน Internet Explorer 5.5
และ [ในที่สุดถูกทำแบบย้อนกลับ](https://blog.whatwg.org/the-road-to-html-5-contenteditable#history)
และถูกคัดลอกโดยเบราว์เซอร์อื่นๆ

เนื่องจาก APIs เหล่านี้ไม่เคยระบุหรือเอกสารอย่างเต็มที่
และเนื่องจากเครื่องมือแก้ไข HTML WYSIWYG มีขอบเขตใหญ่มาก การประมวลผลของแต่ละเบราว์เซอร์จึงมีข้อบกพร่องและความแปลกประหลาดของตัวเอง
และนักพัฒนา JavaScript ต้องแก้ไขความไม่สอดคล้องเหล่านี้

Trix หลีกเลี่ยงความไม่สอดคล้องเหล่านี้โดยการใช้ contenteditable
เป็นอุปกรณ์ I/O: เมื่อข้อมูลเข้าสู่ตัวแก้ไข Trix จะแปลงข้อมูลนั้นเป็นการดำเนินการแก้ไขบนโมเดลเอกสารภายใน แล้วทำการเรนเดอร์เอกสารนั้นกลับเข้าสู่ตัวแก้ไขอีกครั้ง นี้ทำให้ Trix มีควบคุมสมบูรณ์เมื่อเกิดการกดแต่ละครั้ง และไม่ต้องใช้ execCommand เลย

## การติดตั้ง

รัน `bin/rails action_text:install` เพื่อเพิ่มแพคเกจ Yarn และคัดลอกการเคลื่อนย้ายที่จำเป็น นอกจากนี้คุณต้องตั้งค่า Active Storage สำหรับรูปภาพแนบและไฟล์แนบอื่นๆ โปรดอ้างอิงที่ [Active Storage Overview](active_storage_overview.html) เอกสารแนะนำ

หมายเหตุ: Action Text ใช้ความสัมพันธ์หลายรูปแบบกับตาราง `action_text_rich_texts` เพื่อให้สามารถแชร์กับโมเดลที่มีแอตทริบิวต์ Rich Text ได้ หากโมเดลของคุณที่มีเนื้อหา Action Text ใช้ค่า UUID สำหรับตัวระบุ โมเดลที่ใช้แอตทริบิวต์ Action Text ทั้งหมดจะต้องใช้ค่า UUID สำหรับตัวระบุที่ไม่ซ้ำกัน การเคลื่อนย้ายที่สร้างขึ้นสำหรับ Action Text จะต้องอัปเดตเพื่อระบุ `type: :uuid` สำหรับบรรทัด `:record` `references`

หลังจากการติดตั้งเสร็จสมบูรณ์แอปพลิเคชัน Rails ควรมีการเปลี่ยนแปลงต่อไปนี้:

1. ทั้ง `trix` และ `@rails/actiontext` ควรถูกต้องในจุดเริ่มต้นของ JavaScript

    ```js
    // application.js
    import "trix"
    import "@rails/actiontext"
    ```

2. ไฟล์สไตล์ `trix` จะถูกเพิ่มรวมกับสไตล์ Action Text ในไฟล์ `application.css` ของคุณ

## การสร้างเนื้อหา Rich Text

เพิ่มฟิลด์ Rich Text ในโมเดลที่มีอยู่:

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  has_rich_text :content
end
```

หรือเพิ่มฟิลด์ Rich Text เมื่อสร้างโมเดลใหม่โดยใช้:

```bash
$ bin/rails generate model Message content:rich_text
```

หมายเหตุ: คุณไม่จำเป็นต้องเพิ่มฟิลด์ `content` ในตาราง `messages` ของคุณ

จากนั้นใช้ [`rich_text_area`] เพื่ออ้างอิงถึงฟิลด์นี้ในแบบฟอร์มสำหรับโมเดล:
```erb
<%# app/views/messages/_form.html.erb %>
<%= form_with model: message do |form| %>
  <div class="field">
    <%= form.label :content %>
    <%= form.rich_text_area :content %>
  </div>
<% end %>
```

และสุดท้ายนี้ แสดง rich text ที่ผ่านการตรวจสอบแล้วบนหน้าเว็บ:

```erb
<%= @message.content %>
```

หมายเหตุ: หากมีไฟล์ที่แนบอยู่ภายในฟิลด์ `content` อาจไม่แสดงอย่างถูกต้องเว้นแต่คุณ
ได้ติดตั้งแพ็คเกจ *libvips/libvips42* ไว้ในเครื่องของคุณ
ตรวจสอบ[เอกสารการติดตั้ง](https://www.libvips.org/install.html)ของพวกเขาเพื่อดูวิธีการที่คุณจะได้รับมัน

ในการยอมรับเนื้อหา rich text ทั้งหมดที่คุณต้องทำคืออนุญาตให้แอตทริบิวต์ที่อ้างถึง:

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create! params.require(:message).permit(:title, :content)
    redirect_to message
  end
end
```


## การแสดงเนื้อหา Rich Text

โดยค่าเริ่มต้น Action Text จะแสดงเนื้อหา rich text ภายในองค์ประกอบที่มีคลาส `.trix-content`:

```html+erb
<%# app/views/layouts/action_text/contents/_content.html.erb %>
<div class="trix-content">
  <%= yield %>
</div>
```

องค์ประกอบที่มีคลาสนี้รวมถึงตัวแก้ไข Action Text จะถูกจัดรูปแบบโดย
[สไตล์ชีต trix](https://unpkg.com/trix/dist/trix.css)
หากคุณต้องการให้สไตล์ของคุณเองแทน ให้ลบบรรทัด `= require trix` ออกจาก
สไตล์ชีต `app/assets/stylesheets/actiontext.css` ที่สร้างขึ้นโดยตัวติดตั้ง

ในการปรับแต่ง HTML ที่แสดงรอบเนื้อหา rich text แก้ไขเลเอาท์
`app/views/layouts/action_text/contents/_content.html.erb` ที่สร้างขึ้นโดยตัวติดตั้ง

ในการปรับแต่ง HTML ที่แสดงสำหรับภาพและไฟล์แนบอื่น ๆ (ที่รู้จักกันเป็น blobs) แก้ไขเทมเพลต
`app/views/active_storage/blobs/_blob.html.erb` ที่สร้างขึ้นโดยตัวติดตั้ง

### การแสดงไฟล์แนบ

นอกจากไฟล์แนบที่อัปโหลดผ่าน Active Storage Action Text ยังสามารถฝังอะไรก็ได้ที่สามารถแก้ไขได้โดย [Signed
GlobalID](https://github.com/rails/globalid#signed-global-ids).

Action Text จะแสดงองค์ประกอบ `<action-text-attachment>` ที่ฝังโดยแก้ไขคุณสมบัติ `sgid` ของพวกเขาเป็นตัวอย่าง
เมื่อแก้ไขแล้ว องค์ประกอบนั้นจะถูกส่งต่อไปยัง
[`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render).
HTML ที่ได้จะถูกฝังเป็นลูกขององค์ประกอบ `<action-text-attachment>`

ตัวอย่างเช่น พิจารณาโมเดล `User`:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar
end

user = User.find(1)
user.to_global_id.to_s #=> gid://MyRailsApp/User/1
user.to_signed_global_id.to_s #=> BAh7CEkiCG…
```

ต่อไปพิจารณาเนื้อหา rich text บางส่วนที่ฝังองค์ประกอบ `<action-text-attachment>` ที่อ้างอิงถึง signed GlobalID ของอินสแตนซ์ `User`:

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>.</p>
```

Action Text จะใช้สตริง "BAh7CEkiCG…" เพื่อแก้ไขอินสแตนซ์ `User` ต่อไปพิจารณาพาร์ทิชั่น `users/user` ของแอปพลิเคชัน:

```html+erb
<%# app/views/users/_user.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

HTML ที่ได้จาก Action Text จะมีลักษณะเช่นนี้:

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"><span><img src="..."> Jane Doe</span></action-text-attachment>.</p>
```

ในการแสดงพาร์ทิชั่นที่แตกต่างกัน กำหนด `User#to_attachable_partial_path`:

```ruby
class User < ApplicationRecord
  def to_attachable_partial_path
    "users/attachable"
  end
end
```

แล้วประกาศพาร์ทิชั่นนั้น อินสแตนซ์ `User` จะสามารถใช้ได้เป็นตัวแปร partial-local `user`:

```html+erb
<%# app/views/users/_attachable.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

หาก Action Text ไม่สามารถแก้ไขอินสแตนซ์ `User` (ตัวอย่างเช่นหากบันทึกถูกลบ) แทนที่จะแสดงพาร์ทิชั่น fallback จะถูกแสดง

Rails จะให้พาร์ทิชั่นทั่วโลกสำหรับไฟล์แนบที่หายไป พาร์ทิชั่นนี้ถูกติดตั้งในแอปพลิเคชันของคุณที่ `views/action_text/attachables/missing_attachable` และสามารถแก้ไขได้หากคุณต้องการแสดง HTML ที่แตกต่างกัน

ในการแสดงพาร์ทิชั่นไฟล์แนบที่หายไป กำหนดเมธอด `to_missing_attachable_partial_path` ระดับคลาส:

```ruby
class User < ApplicationRecord
  def self.to_missing_attachable_partial_path
    "users/missing_attachable"
  end
end
```

แล้วประกาศพาร์ทิชั่นนั้น

```html+erb
<%# app/views/users/missing_attachable.html.erb %>
<span>Deleted user</span>
```
ในการรวมกับ Action Text `<action-text-attachment>` องค์ประกอบการแสดงผล คลาสจะต้อง:

* รวมโมดูล `ActionText::Attachable`
* ดำเนินการ `#to_sgid(**options)` (ที่สามารถใช้ได้ผ่าน [`GlobalID::Identification` concern][global-id])
* (ตัวเลือก) ประกาศ `#to_attachable_partial_path`
* (ตัวเลือก) ประกาศเมธอดระดับคลาส `#to_missing_attachable_partial_path` เพื่อจัดการระเบียนที่หายไป

โดยค่าเริ่มต้นทั้งหมดของ `ActiveRecord::Base` ลูกสายผสม
[`GlobalID::Identification` concern][global-id] และดังนั้น
เข้ากันได้กับ `ActionText::Attachable`


## หลีกเลี่ยงการคิวรี N+1

หากคุณต้องการโหลดล่วงหน้าโมเดล `ActionText::RichText` ที่ขึ้นอยู่กับฟิลด์ rich text ที่ชื่อ `content` คุณสามารถใช้ named scope:

```ruby
Message.all.with_rich_text_content # โหลดล่วงหน้าเนื้อหาโดยไม่มีการแนบไฟล์
Message.all.with_rich_text_content_and_embeds # โหลดล่วงหน้าทั้งเนื้อหาและการแนบ
```

## API / การพัฒนา Backend

1. API ที่เชื่อมต่อกับฝั่ง Backend (เช่นใช้ JSON) ต้องมีจุดปลายทางแยกต่างหากสำหรับการอัปโหลดไฟล์ที่สร้าง `ActiveStorage::Blob` และส่งคืน `attachable_sgid`:

    ```json
    {
      "attachable_sgid": "BAh7CEkiCG…"
    }
    ```

2. ใช้ `attachable_sgid` นั้นและขอให้ฝั่ง Frontend แทรกไว้ในเนื้อหา rich text โดยใช้แท็ก `<action-text-attachment>`:

    ```html
    <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>
    ```

ข้อมูลนี้เป็นอิงจาก Basecamp ดังนั้นหากคุณยังไม่พบสิ่งที่คุณต้องการ โปรดตรวจสอบเอกสาร [Basecamp Doc](https://github.com/basecamp/bc3-api/blob/master/sections/rich_text.md) นี้
[`rich_text_area`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area
[global-id]: https://github.com/rails/globalid#usage
