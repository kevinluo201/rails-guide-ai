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

Action Text นำเนื้อหาและการแก้ไข Rich Text มาใส่ใน Rails โดยมี [Trix editor](https://trix-editor.org) ซึ่งจัดการทุกอย่างตั้งแต่การจัดรูปแบบ การเชื่อมโยง การอ้างอิง รายการ รวมถึงการแทรกรูปภาพและแกลเลอรี
เนื้อหา Rich Text ที่สร้างขึ้นโดย Trix editor จะถูกบันทึกในโมเดล RichText ที่เกี่ยวข้องกับโมเดล Active Record ที่มีอยู่ในแอปพลิเคชัน
รูปภาพแนบ (หรือไฟล์แนบอื่น ๆ) จะถูกเก็บไว้โดยอัตโนมัติโดยใช้ Active Storage และเชื่อมโยงกับโมเดล RichText ที่รวมอยู่

## Trix เปรียบเทียบกับ Rich Text Editors อื่น ๆ

เครื่องมือแก้ไข WYSIWYG ส่วนใหญ่เป็นตัวห่อหุ้มรอบ HTML's `contenteditable` และ `execCommand` APIs
ออกแบบโดย Microsoft เพื่อสนับสนุนการแก้ไขเนื้อหาของหน้าเว็บแบบสดใน Internet Explorer 5.5
และ [ในที่สุดถูกสร้างขึ้นจากการทดลองกลับ](https://blog.whatwg.org/the-road-to-html-5-contenteditable#history)
และถูกคัดลอกโดยเบราว์เซอร์อื่น ๆ

เนื่องจาก APIs เหล่านี้ไม่เคยระบุหรือเอกสารอย่างเต็มที่
และเนื่องจากเครื่องมือ HTML editors มีขอบเขตใหญ่มาก แต่ละ
การดำเนินการของเบราว์เซอร์แต่ละตัวมีชุดข้อบกพร่องและความแปลกประหลาดของตัวเอง
และนักพัฒนา JavaScript ต้องแก้ไขความไม่สอดคล้องกัน

Trix หลีกเลี่ยงความไม่สอดคล้องเหล่านี้โดยการจัดการ contenteditable
เป็นอุปกรณ์ I/O: เมื่อข้อมูลนำเข้าเข้าสู่ตัวแก้ไข Trix จะแปลงข้อมูลนำเข้านั้น
เป็นการดำเนินการแก้ไขบนโมเดลเอกสารภายใน จากนั้นทำการเรนเดอร์
เอกสารดังกล่าวกลับเข้าสู่ตัวแก้ไขอีกครั้ง นี้ทำให้ Trix มีควบคุมสมบูรณ์เกี่ยวกับสิ่งที่เกิดขึ้นหลังจากทุกการกดคีย์ และละเว้นการใช้ execCommand ทั้งหมด

## การติดตั้ง

รัน `bin/rails action_text:install` เพื่อเพิ่มแพคเกจ Yarn และคัดลอกการเคลื่อนย้ายที่จำเป็น นอกจากนี้คุณต้องติดตั้ง Active Storage สำหรับรูปภาพแนบและไฟล์แนบอื่น ๆ โปรดอ้างอิงที่ [ภาพรวมของ Active Storage](active_storage_overview.html) เอกสาร

หมายเหตุ: Action Text ใช้ความสัมพันธ์หลายรูปแบบกับตาราง `action_text_rich_texts` เพื่อให้สามารถแชร์กับโมเดลทั้งหมดที่มีแอตทริบิวต์ Rich Text หากโมเดลของคุณที่มีเนื้อหา Action Text ใช้ค่า UUID สำหรับตัวระบุ โมเดลที่ใช้แอตทริบิวต์ Action Text ทั้งหมดจะต้องใช้ค่า UUID สำหรับตัวระบุที่ไม่ซ้ำกัน การเคลื่อนย้ายที่สร้างขึ้นสำหรับ Action Text ยังต้องอัปเดตเพื่อระบุ `type: :uuid` สำหรับบรรทัด `:record` `references`

หลังจากการติดตั้งเสร็จสมบูรณ์แอป Rails ควรมีการเปลี่ยนแปลงต่อไปนี้:

1. ทั้ง `trix` และ `@rails/actiontext` ควรถูกต้องในจุดเริ่มต้นของ JavaScript ของคุณ

    ```js
    // application.js
    import "trix"
    import "@rails/actiontext"
    ```

2. ไฟล์สไตล์ `trix` จะถูกนำเข้าพร้อมกับสไตล์ Action Text ในไฟล์ `application.css` ของคุณ

## สร้างเนื้อหา Rich Text

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

จากนั้นใช้ [`rich_text_area`] เพื่ออ้างอิงฟิลด์นี้ในแบบฟอร์มสำหรับโมเดล:

```erb
<%# app/views/messages/_form.html.erb %>
<%= form_with model: message do |form| %>
  <div class="field">
    <%= form.label :content %>
    <%= form.rich_text_area :content %>
  </div>
<% end %>
```

และสุดท้ายแสดงเนื้อหา Rich Text ที่ถูกตรวจสอบบนหน้าเว็บ:

```erb
<%= @message.content %>
```

หมายเหตุ: หากมีแหล่งทรัพยากรที่แนบอยู่ภายในฟิลด์ `content` อาจไม่แสดงอย่างถูกต้องเว้นแต่คุณ
ติดตั้งแพ็คเกจ *libvips/libvips42* บนเครื่องของคุณ
ตรวจสอบ [เอกสารการติดตั้งของพวกเขา](https://www.libvips.org/install.html) เพื่อดูวิธีการรับมัน

ในการยอมรับเนื้อหา Rich Text ที่คุณต้องทำคืออนุญาตให้แอตทริบิวต์ที่อ้างถึง:

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create! params.require(:message).permit(:title, :content)
    redirect_to message
  end
end
```
## การแสดงเนื้อหา Rich Text

โดยค่าเริ่มต้น Action Text จะแสดงเนื้อหา Rich Text ภายในองค์ประกอบที่มีคลาส `.trix-content`:

```html+erb
<%# app/views/layouts/action_text/contents/_content.html.erb %>
<div class="trix-content">
  <%= yield %>
</div>
```

องค์ประกอบที่มีคลาสนี้รวมถึงตัวแก้ไข Action Text และจะได้รับการจัดรูปแบบจาก [สไตล์ชีท trix](https://unpkg.com/trix/dist/trix.css) หากต้องการให้สไตล์ที่กำหนดเอง ให้ลบบรรทัด `= require trix` ออกจากสไตล์ชีท `app/assets/stylesheets/actiontext.css` ที่สร้างขึ้นโดยตัวติดตั้ง

หากต้องการปรับแต่ง HTML ที่แสดงรอบเนื้อหา Rich Text แก้ไขเลเอาท์ `app/views/layouts/action_text/contents/_content.html.erb` ที่สร้างขึ้นโดยตัวติดตั้ง

หากต้องการปรับแต่ง HTML ที่แสดงสำหรับภาพและไฟล์แนบอื่น ๆ (ที่เรียกว่า blobs) แก้ไขเทมเพลต `app/views/active_storage/blobs/_blob.html.erb` ที่สร้างขึ้นโดยตัวติดตั้ง

### การแสดงไฟล์แนบ

นอกจากไฟล์แนบที่อัปโหลดผ่าน Active Storage แล้ว Action Text ยังสามารถฝังอะไรก็ได้ที่สามารถแก้ไขได้โดย [Signed GlobalID](https://github.com/rails/globalid#signed-global-ids)

Action Text จะแสดงองค์ประกอบ `<action-text-attachment>` ที่ฝังไว้โดยแก้ไขคุณสมบัติ `sgid` ขององค์ประกอบนั้นให้เป็นอินสแตนซ์ หลังจากแก้ไขแล้ว อินสแตนซ์นั้นจะถูกส่งไปยัง [`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render) และ HTML ที่ได้จะถูกฝังเป็นลูกขององค์ประกอบ `<action-text-attachment>`

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

ต่อมา พิจารณาเนื้อหา Rich Text ที่ฝังองค์ประกอบ `<action-text-attachment>` ที่อ้างอิงไปยัง signed GlobalID ของอินสแตนซ์ `User`:

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>.</p>
```

Action Text จะใช้สตริง "BAh7CEkiCG…" เพื่อแก้ไขอินสแตนซ์ `User` ต่อมา พิจารณาเทมเพลต `users/user` ของแอปพลิเคชัน:

```html+erb
<%# app/views/users/_user.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

HTML ที่ได้จาก Action Text จะมีลักษณะเช่นนี้:

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"><span><img src="..."> Jane Doe</span></action-text-attachment>.</p>
```

หากต้องการแสดงเทมเพลตอื่น ๆ กำหนด `User#to_attachable_partial_path`:

```ruby
class User < ApplicationRecord
  def to_attachable_partial_path
    "users/attachable"
  end
end
```

จากนั้นประกาศเทมเพลตนั้น เอาอินสแตนซ์ `User` จะสามารถใช้งานได้ในรูปแบบของตัวแปร partial-local `user`:

```html+erb
<%# app/views/users/_attachable.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

หาก Action Text ไม่สามารถแก้ไขอินสแตนซ์ `User` (เช่นหากบันทึกถูกลบ) จะแสดงเทมเพลต fallback ตามค่าเริ่มต้น

Rails มีเทมเพลตทั่วไปสำหรับไฟล์แนบที่หายไป ที่ติดตั้งในแอปพลิเคชันของคุณที่ `views/action_text/attachables/missing_attachable` และสามารถแก้ไขได้หากต้องการแสดง HTML ที่แตกต่างกัน

หากต้องการแสดงเทมเพลตไฟล์แนบที่หายไปอื่น ๆ กำหนดเมธอด `to_missing_attachable_partial_path` ระดับคลาส:

```ruby
class User < ApplicationRecord
  def self.to_missing_attachable_partial_path
    "users/missing_attachable"
  end
end
```

จากนั้นประกาศเทมเพลตนั้น

```html+erb
<%# app/views/users/missing_attachable.html.erb %>
<span>ผู้ใช้ที่ถูกลบ</span>
```

เพื่อให้ Action Text สามารถแสดงองค์ประกอบ `<action-text-attachment>` ได้ คลาสจำเป็นต้อง:

* รวม `ActionText::Attachable` module
* ประกาศ `#to_sgid(**options)` (ที่สามารถใช้ได้ผ่านความเกี่ยวข้อง [`GlobalID::Identification` concern][global-id])
* (ตัวเลือก) ประกาศ `#to_attachable_partial_path`
* (ตัวเลือก) ประกาศเมธอดระดับคลาส `#to_missing_attachable_partial_path` สำหรับการจัดการบันทึกที่หายไป

โดยค่าเริ่มต้น ทุกๆ `ActiveRecord::Base` ลูกสายมีการผสม [`GlobalID::Identification` concern][global-id] และเป็นไปตามนั้นว่าเข้ากันได้กับ `ActionText::Attachable`


## หลีกเลี่ยงการคิวรี่ N+1

หากต้องการโหลดล่วงหน้าโมเดล `ActionText::RichText` ที่ขึ้นอยู่กับฟิลด์ Rich Text ที่ชื่อ `content` สามารถใช้ named scope ได้:

```ruby
Message.all.with_rich_text_content # โหลด body โดยไม่มีไฟล์แนบ
Message.all.with_rich_text_content_and_embeds # โหลดทั้ง body และไฟล์แนบ
```

## API / การพัฒนา Backend

1. Backend API (เช่น JSON) ต้องมีจุดปลายทางแยกต่างหากสำหรับการอัปโหลดไฟล์ที่สร้าง `ActiveStorage::Blob` และส่งคืน `attachable_sgid`:

    ```json
    {
      "attachable_sgid": "BAh7CEkiCG…"
    }
    ```

2. นำ `attachable_sgid` นั้นและขอให้ฝังไว้ในเนื้อหา Rich Text โดยใช้แท็ก `<action-text-attachment>`:

    ```html
    <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>
    ```

ข้อมูลนี้เกี่ยวกับ Basecamp ดังนั้นหากคุณยังไม่พบสิ่งที่คุณต้องการ โปรดตรวจสอบ[เอกสาร Basecamp](https://github.com/basecamp/bc3-api/blob/master/sections/rich_text.md)
[`rich_text_area`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area
[global-id]: https://github.com/rails/globalid#usage
