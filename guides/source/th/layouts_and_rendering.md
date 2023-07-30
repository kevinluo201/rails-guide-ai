**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 02f663dc709da76ced45deb2ba800a78
การจัดเลย์และการเรนเดอร์ใน Rails
==============================

เอกสารนี้เป็นเกี่ยวกับคุณสมบัติเบื้องหลังของ Action Controller และ Action View

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีใช้เมธอดการเรนเดอร์ต่างๆ ที่มีอยู่ใน Rails
* วิธีสร้างเลย์เอกสารที่มีส่วนเนื้อหาหลายส่วน
* วิธีใช้พาร์เชียลเพื่อลดการซ้ำซ้อนในมุมมองของคุณ
* วิธีใช้เลย์เอกสารที่ซ้อนกัน (เทมเพลตย่อย)

--------------------------------------------------------------------------------

ภาพรวม: การเชื่อมต่อกันของส่วนประกอบ
-------------------------------------

เอกสารนี้เน้นการปฏิสัมพันธ์ระหว่าง Controller และ View ในสามเหลี่ยม Model-View-Controller ตามที่คุณรู้อยู่ คอนโทรลเลอร์รับผิดชอบในการจัดการกระบวนการทั้งหมดในการจัดการคำขอใน Rails แม้ว่ามันจะส่งงานที่หนักให้กับโมเดล แต่เมื่อถึงเวลาส่งคำตอบกลับไปยังผู้ใช้ คอนโทรลเลอร์จะส่งงานให้กับวิว นั่นคือเรื่องที่เราจะพูดถึงในเอกสารนี้

โดยรวมแล้ว นี้เกี่ยวข้องกับการตัดสินใจว่าควรส่งอะไรเป็นการตอบกลับและเรียกใช้เมธอดที่เหมาะสมในการสร้างการตอบกลับนั้น หากการตอบกลับเป็นวิวที่ครบถ้วน Rails ยังทำงานเพิ่มเติมเพื่อห่อวิวในเลย์เอกสารและบางครั้งอาจดึงวิวย่อยเข้ามาด้วย คุณจะเห็นทุกเส้นทางเหล่านี้ในภายหลังในเอกสารนี้

การสร้างการตอบกลับ
------------------

จากมุมมองของคอนโทรลเลอร์ มีวิธีสามวิธีในการสร้างการตอบกลับ HTTP:

* เรียกใช้ [`render`][controller.render] เพื่อสร้างการตอบกลับที่ครบถ้วนเพื่อส่งกลับไปยังเบราว์เซอร์
* เรียกใช้ [`redirect_to`][] เพื่อส่งรหัสสถานะการเปลี่ยนเส้นทาง HTTP ไปยังเบราว์เซอร์
* เรียกใช้ [`head`][] เพื่อสร้างการตอบกลับที่ประกอบด้วยส่วนหัว HTTP เท่านั้นเพื่อส่งกลับไปยังเบราว์เซอร์


### เรนเดอร์ตามค่าเริ่มต้น: การกำหนดค่าตามปรกติในการดำเนินการ

คุณได้ยินว่า Rails สนับสนุน "ความสามารถในการกำหนดค่าตามปรกติ" การเรนเดอร์ตามค่าเริ่มต้นเป็นตัวอย่างที่ดีในเรื่องนี้ โดยค่าเริ่มต้นคือคอนโทรลเลอร์ใน Rails จะเรนเดอร์วิวที่มีชื่อที่สอดคล้องกับเส้นทางที่ถูกต้อง ตัวอย่างเช่น หากคุณมีโค้ดนี้ในคลาส `BooksController` ของคุณ:

```ruby
class BooksController < ApplicationController
end
```

และโค้ดต่อไปนี้ในไฟล์เส้นทางของคุณ:

```ruby
resources :books
```

และคุณมีไฟล์วิว `app/views/books/index.html.erb`:

```html+erb
<h1>Books are coming soon!</h1>
```

Rails จะเรนเดอร์ `app/views/books/index.html.erb` โดยอัตโนมัติเมื่อคุณไปที่ `/books` และคุณจะเห็น "Books are coming soon!" บนหน้าจอของคุณ

อย่างไรก็ตาม หน้าจอที่กำลังจะมาถึงไม่ได้มีประโยชน์อย่างมาก เราจะสร้างโมเดล `Book` และเพิ่มการกระทำดัชนีใน `BooksController` ของเราเร็วๆ นี้:

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

โปรดทราบว่าเราไม่ได้มีการเรนเดอร์แบบชัดเจนที่สุดท้ายของการกระทำดัชนีในความสอดคล้องกับหลักการ "ความสามารถในการกำหนดค่าตามปรกติ" กฎคือหากคุณไม่ได้เรนเดอร์อะไรบางอย่างชัดเจนที่สุดท้ายของการกระทำคอนโทรลเลอร์  Rails จะค้นหาเทมเพลต `action_name.html.erb` ในเส้นทางวิวของคอนโทรลเลอร์และเรนเดอร์มัน ดังนั้นในกรณีนี้ Rails จะเรนเดอร์ไฟล์ `app/views/books/index.html.erb`

หากเราต้องการแสดงคุณสมบัติของหนังสือทั้งหมดในวิวของเรา เราสามารถทำได้ด้วยเทมเพลต ERB ดังนี้:

```html+erb
<h1>Listing Books</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Show", book %></td>
        <td><%= link_to "Edit", edit_book_path(book) %></td>
        <td><%= link_to "Destroy", book, data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "New book", new_book_path %>
```
หมายเหตุ: การแสดงผลจริงจะทำโดยคลาสที่ซ้อนกันของโมดูล [`ActionView::Template::Handlers`](https://api.rubyonrails.org/classes/ActionView/Template/Handlers.html) คู่มือนี้ไม่ได้สำรวจกระบวนการนั้น แต่สิ่งสำคัญคือต้องรู้ว่านามสกุลไฟล์ในมุมมองของคุณควบคุมการเลือกตัวจัดการเทมเพลต

### การใช้ `render`

ในกรณีส่วนใหญ่ วิธีการ [`render`][controller.render] ของคอนโทรลเลอร์จะทำหน้าที่หนักในการแสดงเนื้อหาของแอปพลิเคชันของคุณเพื่อให้เบราว์เซอร์ใช้งาน มีหลายวิธีในการปรับแต่งพฤติกรรมของ `render` คุณสามารถแสดงเทมเพลตเริ่มต้นสำหรับเทมเพลตของ Rails หรือเทมเพลตที่ระบุ หรือไฟล์ หรือโค้ดแบบอินไลน์ หรือไม่ทำอะไรเลย คุณสามารถแสดงข้อความ  JSON หรือ XML คุณสามารถระบุประเภทเนื้อหาหรือสถานะ HTTP ของการแสดงผลที่ได้ด้วย

เคล็ดลับ: หากคุณต้องการดูผลลัพธ์ที่แน่นอนของการเรียกใช้ `render` โดยไม่ต้องตรวจสอบในเบราว์เซอร์ คุณสามารถเรียกใช้ `render_to_string` วิธีนี้ใช้ตัวเลือกเดียวกับ `render` แต่จะส่งคืนสตริงแทนการส่งคำตอบกลับไปยังเบราว์เซอร์

#### การแสดงเทมเพลตของแอคชัน

หากคุณต้องการแสดงเทมเพลตที่สอดคล้องกับเทมเพลตอื่นในคอนโทรลเลอร์เดียวกัน คุณสามารถใช้ `render` พร้อมชื่อของวิว:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

หากการเรียกใช้ `update` ล้มเหลว การเรียกใช้แอคชัน `update` ในคอนโทรลเลอร์นี้จะแสดงเทมเพลต `edit.html.erb` ที่เป็นของคอนโทรลเลอร์เดียวกัน

หากคุณต้องการ คุณสามารถใช้สัญลักษณ์แทนสตริงเพื่อระบุแอคชันที่จะแสดง:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit, status: :unprocessable_entity
  end
end
```

#### การแสดงเทมเพลตของแอคชันจากคอนโทรลเลอร์อื่น

หากคุณต้องการแสดงเทมเพลตจากคอนโทรลเลอร์ที่แตกต่างกันอย่างสิ้นเชิงจากคอนโทรลเลอร์ที่มีโค้ดแอคชัน คุณสามารถทำได้ด้วย `render` ซึ่งยอมรับเส้นทางเต็ม (เกี่ยวข้องกับ `app/views`) ของเทมเพลตที่จะแสดงผล ตัวอย่างเช่น หากคุณกำลังเรียกใช้รหัสใน `AdminProductsController` ที่อยู่ใน `app/controllers/admin` คุณสามารถแสดงผลของแอคชันไปยังเทมเพลตใน `app/views/products` ได้ดังนี้:

```ruby
render "products/show"
```

Rails รู้ว่าวิวนี้เป็นของคอนโทรลเลอร์ที่แตกต่างกันเนื่องจากมีอักขระแบ่งส่วนภายในสตริง หากคุณต้องการเป็นชัดเจน คุณสามารถใช้ตัวเลือก `:template` (ที่จำเป็นใน Rails 2.2 และรุ่นก่อนหน้านี้):

```ruby
render template: "products/show"
```

#### สรุป

วิธีการแสดงผลสองวิธีด้านบน (การแสดงเทมเพลตของแอคชันอื่นในคอนโทรลเลอร์เดียวกันและการแสดงเทมเพลตของแอคชันอื่นในคอนโทรลเลอร์ที่แตกต่างกัน) นั้นเป็นแบบเดียวกันจริง ในความเป็นจริงในคลาส `BooksController` ภายในแอคชัน update ที่เราต้องการแสดงเทมเพลต edit หากหนังสือไม่อัปเดตสำเร็จ การเรียกใช้ `render` ต่อไปนี้จะแสดงเทมเพลต `edit.html.erb` ในไดเรกทอรี `views/books`:

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

ว่าฉันที่คุณใช้เป็นเรื่องของสไตล์และประเพณี แต่กฎของนิ้วกลางคือใช้วิธีที่ง่ายที่สุดที่เหมาะสมสำหรับโค้ดที่คุณกำลังเขียน
#### การใช้ `render` กับ `:inline`

เมธอด `render` สามารถทำงานได้โดยไม่ต้องมีวิวเลย หากคุณต้องการใช้ตัวเลือก `:inline` เพื่อให้ ERB เป็นส่วนหนึ่งของการเรียกใช้เมธอด นี่เป็นการใช้ที่ถูกต้องอย่างสมบูรณ์:

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

คำเตือน: มักจะไม่มีเหตุผลที่ดีในการใช้ตัวเลือกนี้ การผสม ERB เข้ากับคอนโทรลเลอร์ของคุณจะทำให้ Rails สูญเสียการตั้งค่า MVC และทำให้เยาะเย้ยสำหรับนักพัฒนาคนอื่นที่จะติดตามตรรกะของโครงการของคุณ ควรใช้วิว erb แยกต่างหากแทน

ตามค่าเริ่มต้น การเรียกใช้งานแบบ inline จะใช้ ERB คุณสามารถบังคับให้ใช้ Builder แทนด้วยตัวเลือก `:type`:

```ruby
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```

#### การเรียกใช้งานข้อความ

คุณสามารถส่งข้อความธรรมดา - โดยไม่มีการปรับแต่งใด ๆ - กลับไปยังเบราว์เซอร์โดยใช้ตัวเลือก `:plain` กับ `render`:

```ruby
render plain: "OK"
```

เคล็ดลับ: การเรียกใช้ข้อความธรรมดามีประโยชน์มากที่สุดเมื่อคุณตอบสนองต่อ Ajax หรือคำขอเว็บเซอร์วิสที่คาดหวังสิ่งที่แตกต่างจาก HTML ที่ถูกต้อง

หมายเหตุ: โดยค่าเริ่มต้น หากคุณใช้ตัวเลือก `:plain` ข้อความจะถูกแสดงโดยไม่ใช้เลเอาท์ปัจจุบัน หากคุณต้องการให้ Rails ใส่ข้อความลงในเลเอาท์ปัจจุบัน คุณต้องเพิ่มตัวเลือก `layout: true` และใช้ส่วนขยาย `.text.erb` สำหรับไฟล์เลเอาท์

#### การเรียกใช้งาน HTML

คุณสามารถส่งสตริง HTML กลับไปยังเบราว์เซอร์โดยใช้ตัวเลือก `:html` กับ `render`:

```ruby
render html: helpers.tag.strong('Not Found')
```

เคล็ดลับ: นี่เป็นวิธีที่ใช้ได้เมื่อคุณต้องการแสดงส่วนย่อยของโค้ด HTML ที่เล็กน้อย อย่างไรก็ตาม หากมีการปรับแต่งมากของมาร์กอัพ คุณอาจต้องพิจารณาย้ายไปยังไฟล์เทมเพลต

หมายเหตุ: เมื่อใช้ตัวเลือก `html:` ตัวแปร HTML จะถูกหนีไล่หากสตริงไม่ได้ถูกสร้างขึ้นด้วย API ที่รองรับ `html_safe`

#### การเรียกใช้งาน JSON

JSON เป็นรูปแบบข้อมูล JavaScript ที่ใช้กับหลายไลบรารี Ajax Rails มีการสนับสนุนสำหรับการแปลงออบเจ็กต์เป็น JSON และการแสดง JSON กลับไปยังเบราว์เซอร์:

```ruby
render json: @product
```

เคล็ดลับ: คุณไม่จำเป็นต้องเรียกใช้ `to_json` บนออบเจ็กต์ที่คุณต้องการแสดงผล หากคุณใช้ตัวเลือก `:json` `render` จะเรียกใช้ `to_json` โดยอัตโนมัติ

#### การเรียกใช้งาน XML

Rails ยังมีการสนับสนุนสำหรับการแปลงออบเจ็กต์เป็น XML และการแสดง XML กลับไปยังผู้เรียก:

```ruby
render xml: @product
```

เคล็ดลับ: คุณไม่จำเป็นต้องเรียกใช้ `to_xml` บนออบเจ็กต์ที่คุณต้องการแสดงผล หากคุณใช้ตัวเลือก `:xml` `render` จะเรียกใช้ `to_xml` โดยอัตโนมัติ

#### การเรียกใช้งาน JavaScript ธรรมดา

Rails สามารถแสดง JavaScript ธรรมดาได้:

```ruby
render js: "alert('Hello Rails');"
```

สิ่งนี้จะส่งสตริงที่ให้ไปยังเบราว์เซอร์พร้อมกับ MIME type เป็น `text/javascript`

#### การเรียกใช้งานเนื้อหาแบบ Raw

คุณสามารถส่งเนื้อหาแบบ raw กลับไปยังเบราว์เซอร์โดยไม่ตั้งค่าเนื้อหาใด ๆ โดยใช้ตัวเลือก `:body` กับ `render`:

```ruby
render body: "raw"
```

เคล็ดลับ: ตัวเลือกนี้ควรใช้เฉพาะหากคุณไม่สนใจเนื้อหาประเภทใด ๆ ของการตอบสนอง การใช้ `:plain` หรือ `:html` อาจเหมาะสมกว่าในส่วนมากของเวลา
หมายเหตุ: ยกเว้นกรณีที่มีการกำหนดค่าเป็นอย่างอื่น การตอบกลับที่คุณได้รับจากตัวเลือกการเรนเดอร์นี้จะเป็น `text/plain` เนื่องจากเป็นเนื้อหาเริ่มต้นของการตอบกลับแบบแอ็คชันดิสพัทช์

#### เรนเดอร์ไฟล์แบบ Raw

Rails สามารถเรนเดอร์ไฟล์แบบ raw จากที่อยู่แบบสัมบูรณ์ได้ ซึ่งเป็นประโยชน์ในการเรนเดอร์ไฟล์สถิติเช่นหน้าข้อผิดพลาดตามเงื่อนไข

```ruby
render file: "#{Rails.root}/public/404.html", layout: false
```

การเรนเดอร์ไฟล์แบบ raw นี้จะไม่รองรับ ERB หรือตัวจัดการอื่น ๆ โดยค่าเริ่มต้นคือการเรนเดอร์ไฟล์ภายในเลเอาท์ปัจจุบัน

คำเตือน: การใช้ตัวเลือก `:file` ร่วมกับข้อมูลที่ผู้ใช้ป้อนเข้าสามารถทำให้เกิดปัญหาด้านความปลอดภัยได้ เนื่องจากผู้โจมตีอาจใช้การกระทำนี้เพื่อเข้าถึงไฟล์ที่มีความสำคัญในระบบไฟล์ของคุณ

เคล็ดลับ: `send_file` เป็นตัวเลือกที่ดีกว่าและเร็วกว่าในกรณีที่ไม่ต้องการเลเอาท์

#### เรนเดอร์ออบเจกต์

Rails สามารถเรนเดอร์ออบเจกต์ที่ตอบสนองกับ `:render_in` ได้

```ruby
render MyRenderable.new
```

สิ่งนี้จะเรียก `render_in` บนออบเจกต์ที่ให้มาพร้อมทั้งคอนเท็กซ์วิวปัจจุบัน

คุณยังสามารถให้ออบเจกต์โดยใช้ตัวเลือก `:renderable` กับ `render`:

```ruby
render renderable: MyRenderable.new
```

#### ตัวเลือกสำหรับ `render`

การเรียกใช้เมธอด [`render`][controller.render] ทั่วไปจะยอมรับตัวเลือกหกตัว:

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`
* `:variants`

##### ตัวเลือก `:content_type`

ตามค่าเริ่มต้น Rails จะให้บริการผลลัพธ์ของการเรนเดอร์ด้วย MIME content-type เป็น `text/html` (หรือ `application/json` หากคุณใช้ตัวเลือก `:json` หรือ `application/xml` สำหรับตัวเลือก `:xml`) มีเวลาที่คุณอาจต้องการเปลี่ยนแปลงสิ่งนี้ และคุณสามารถทำได้โดยการตั้งค่าตัวเลือก `:content_type`:

```ruby
render template: "feed", content_type: "application/rss"
```

##### ตัวเลือก `:layout`

กับส่วนใหญ่ของตัวเลือกในการเรนเดอร์ ส่วนที่เรนเดอร์จะแสดงเนื้อหาที่ได้เป็นส่วนหนึ่งของเลเอาท์ปัจจุบัน คุณจะเรียนรู้เพิ่มเติมเกี่ยวกับเลเอาท์และวิธีการใช้ในภายหลังในคู่มือนี้

คุณสามารถใช้ตัวเลือก `:layout` เพื่อบอกให้ Rails ใช้ไฟล์ที่เฉพาะเจาะจงเป็นเลเอาท์สำหรับการกระทำปัจจุบัน:

```ruby
render layout: "special_layout"
```

คุณยังสามารถบอกให้ Rails เรนเดอร์โดยไม่มีเลเอาท์เลย:

```ruby
render layout: false
```

##### ตัวเลือก `:location`

คุณสามารถใช้ตัวเลือก `:location` เพื่อตั้งค่าส่วนหัว HTTP `Location`:

```ruby
render xml: photo, location: photo_url(photo)
```

##### ตัวเลือก `:status`

Rails จะสร้างตอบกลับโดยอัตโนมัติด้วยรหัสสถานะ HTTP ที่ถูกต้อง (ในกรณีส่วนใหญ่นี้คือ `200 OK`) คุณสามารถใช้ตัวเลือก `:status` เพื่อเปลี่ยนสิ่งนี้:

```ruby
render status: 500
render status: :forbidden
```

Rails เข้าใจทั้งรหัสสถานะตัวเลขและสัญลักษณ์ที่สอดคล้องกันที่แสดงด้านล่าง

| ชั้นความเป็นไปได้ของการตอบกลับ | รหัสสถานะ HTTP | สัญลักษณ์                          |
| ------------------- | ---------------- | -------------------------------- |
| **ข้อมูล**   | 100              | :continue                        |
|                     | 101              | :switching_protocols             |
|                     | 102              | :processing                      |
| **สำเร็จ**         | 200              | :ok                              |
|                     | 201              | :created                         |
|                     | 202              | :accepted                        |
|                     | 203              | :non_authoritative_information   |
|                     | 204              | :no_content                      |
|                     | 205              | :reset_content                   |
|                     | 206              | :partial_content                 |
|                     | 207              | :multi_status                    |
|                     | 208              | :already_reported                |
|                     | 226              | :im_used                         |
| **การเปลี่ยนเส้นทาง**     | 300              | :multiple_choices                |
|                     | 301              | :moved_permanently               |
|                     | 302              | :found                           |
|                     | 303              | :see_other                       |
|                     | 304              | :not_modified                    |
|                     | 305              | :use_proxy                       |
|                     | 307              | :temporary_redirect              |
|                     | 308              | :permanent_redirect              |
| **ข้อผิดพลาดของไคลเอ็นต์**    | 400              | :bad_request                     |
|                     | 401              | :unauthorized                    |
|                     | 402              | :payment_required                |
|                     | 403              | :forbidden                       |
|                     | 404              | :not_found                       |
|                     | 405              | :method_not_allowed              |
|                     | 406              | :not_acceptable                  |
|                     | 407              | :proxy_authentication_required   |
|                     | 408              | :request_timeout                 |
|                     | 409              | :conflict                        |
|                     | 410              | :gone                            |
|                     | 411              | :length_required                 |
|                     | 412              | :precondition_failed             |
|                     | 413              | :payload_too_large               |
|                     | 414              | :uri_too_long                    |
|                     | 415              | :unsupported_media_type          |
|                     | 416              | :range_not_satisfiable           |
|                     | 417              | :expectation_failed              |
|                     | 421              | :misdirected_request             |
|                     | 422              | :unprocessable_entity            |
|                     | 423              | :locked                          |
|                     | 424              | :failed_dependency               |
|                     | 426              | :upgrade_required                |
|                     | 428              | :precondition_required           |
|                     | 429              | :too_many_requests               |
|                     | 431              | :request_header_fields_too_large |
|                     | 451              | :unavailable_for_legal_reasons   |
| **ข้อผิดพลาดของเซิร์ฟเวอร์**    | 500              | :internal_server_error           |
|                     | 501              | :not_implemented                 |
|                     | 502              | :bad_gateway                     |
|                     | 503              | :service_unavailable             |
|                     | 504              | :gateway_timeout                 |
|                     | 505              | :http_version_not_supported      |
|                     | 506              | :variant_also_negotiates         |
|                     | 507              | :insufficient_storage            |
|                     | 508              | :loop_detected                   |
|                     | 510              | :not_extended                    |
|                     | 511              | :network_authentication_required |
หมายเหตุ: หากคุณพยายามแสดงเนื้อหาพร้อมกับรหัสสถานะที่ไม่ใช่เนื้อหา (100-199, 204, 205 หรือ 304) จะถูกลบออกจากการตอบสนอง

##### ตัวเลือก `:formats`

Rails ใช้รูปแบบที่ระบุในคำขอ (หรือ `:html` เป็นค่าเริ่มต้น) คุณสามารถเปลี่ยนแปลงได้โดยส่ง `:formats` ในรูปแบบของสัญลักษณ์หรืออาร์เรย์:

```ruby
render formats: :xml
render formats: [:json, :xml]
```

หากไม่มีเทมเพลตที่ระบุรูปแบบที่กำหนด จะเกิดข้อผิดพลาด `ActionView::MissingTemplate`

##### ตัวเลือก `:variants`

สิ่งนี้บอก Rails ให้ค้นหาตัวแปรแบบเทมเพลตของรูปแบบเดียวกัน คุณสามารถระบุรายการตัวแปรได้โดยส่ง `:variants` ในรูปแบบของสัญลักษณ์หรืออาร์เรย์

ตัวอย่างการใช้งานคือดังนี้

```ruby
# เรียกใช้ใน HomeController#index
render variants: [:mobile, :desktop]
```

ด้วยชุดตัวแปรเหล่านี้ Rails จะค้นหาเทมเพลตตามชุดต่อไปนี้และใช้ตัวแรกที่มีอยู่

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

หากไม่มีเทมเพลตที่ระบุรูปแบบที่กำหนด จะเกิดข้อผิดพลาด `ActionView::MissingTemplate`

แทนที่จะตั้งค่าตัวแปรในการเรียกใช้งานคุณยังสามารถตั้งค่าในอ็อบเจกต์คำขอในคำสั่งควบคุมของคุณได้

```ruby
def index
  request.variant = determine_variant
end

  private
    def determine_variant
      variant = nil
      # รหัสบางส่วนเพื่อกำหนดตัวแปรที่จะใช้
      variant = :mobile if session[:use_mobile]

      variant
    end
```

#### การค้นหาเลเอาท์

เพื่อค้นหาเลเอาท์ปัจจุบัน Rails จะค้นหาไฟล์ใน `app/views/layouts` ที่มีชื่อเบสเดียวกับคอนโทรลเลอร์ ตัวอย่างเช่นการแสดงผลของการกระทำจากคลาส `PhotosController` จะใช้ `app/views/layouts/photos.html.erb` (หรือ `app/views/layouts/photos.builder`) หากไม่มีเลเอาท์ที่เฉพาะเจาะจงสำหรับคอนโทรลเลอร์นั้น  Rails จะใช้ `app/views/layouts/application.html.erb` หรือ `app/views/layouts/application.builder` หากไม่มีเลเอาท์ `.erb` Rails จะใช้เลเอาท์ `.builder` หากมีอยู่ Rails ยังให้วิธีการหลายวิธีในการกำหนดเลเอาท์เฉพาะให้กับคอนโทรลเลอร์และการกระทำแต่ละรายการ

##### การระบุเลเอาท์สำหรับคอนโทรลเลอร์

คุณสามารถแทนที่กฎเกณฑ์เลเอาท์เริ่มต้นในคอนโทรลเลอร์ของคุณโดยใช้การประกาศ [`layout`][] ตัวอย่างเช่น:

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

ด้วยการประกาศนี้ มุมมองทั้งหมดที่แสดงผลโดย `ProductsController` จะใช้ `app/views/layouts/inventory.html.erb` เป็นเลเอาท์ของพวกเขา

ในการกำหนดเลเอาท์เฉพาะสำหรับแอปพลิเคชันทั้งหมด ให้ใช้การประกาศเลเอาท์ในคลาส `ApplicationController` ของคุณ:

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

ด้วยการประกาศนี้ มุมมองทั้งหมดในแอปพลิเคชันจะใช้ `app/views/layouts/main.html.erb` เป็นเลเอาท์ของพวกเขา


##### เลือกเลเอาท์ในเวลาทำงาน

คุณสามารถใช้สัญลักษณ์เพื่อเลื่อนการเลือกเลเอาท์ไปจนกว่าคำขอจะถูกประมวลผล:

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end
end
```

ตอนนี้หากผู้ใช้ปัจจุบันเป็นผู้ใช้พิเศษ เขาจะได้รับเลเอาท์พิเศษเมื่อดูผลิตภัณฑ์

คุณยังสามารถใช้เมธอดแบบอินไลน์ เช่น Proc เพื่อกำหนดเลเอาท์ ตัวอย่างเช่นหากคุณส่งออบเจกต์ Proc บล็อกที่คุณให้กับ Proc จะได้รับอินสแตนซ์คอนโทรลเลอร์ ดังนั้นเลเอาท์สามารถกำหนดได้ตามคำขอปัจจุบัน:
```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### เลเอาท์ที่เปลี่ยนแปลงตามเงื่อนไข

การกำหนดเลเอาท์ที่ระดับคอนโทรลเลอร์สนับสนุนตัวเลือก `:only` และ `:except` ตัวเลือกเหล่านี้รับชื่อเมธอดหรืออาร์เรย์ของชื่อเมธอดที่สอดคล้องกับชื่อเมธอดภายในคอนโทรลเลอร์:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

ด้วยการประกาศนี้ เลเอาท์ `product` จะถูกใช้สำหรับทุกอย่างยกเว้นเมธอด `rss` และ `index` 

##### การสืบทอดเลเอาท์

การประกาศเลเอาท์จะสืบทอดลงมาในลำดับชั้นล่าง และการประกาศเลเอาท์ที่เฉพาะเจาะจงมักจะเขียนทับเลเอาท์ที่ทั่วไปมากกว่า ตัวอย่างเช่น:

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `articles_controller.rb`

    ```ruby
    class ArticlesController < ApplicationController
    end
    ```

* `special_articles_controller.rb`

    ```ruby
    class SpecialArticlesController < ArticlesController
      layout "special"
    end
    ```

* `old_articles_controller.rb`

    ```ruby
    class OldArticlesController < SpecialArticlesController
      layout false

      def show
        @article = Article.find(params[:id])
      end

      def index
        @old_articles = Article.older
        render layout: "old"
      end
      # ...
    end
    ```

ในแอปพลิเคชันนี้:

* โดยทั่วไป วิวจะถูกแสดงในเลเอาท์ `main`
* `ArticlesController#index` จะใช้เลเอาท์ `main`
* `SpecialArticlesController#index` จะใช้เลเอาท์ `special`
* `OldArticlesController#show` จะไม่ใช้เลเอาท์เลย
* `OldArticlesController#index` จะใช้เลเอาท์ `old`

##### การสืบทอดเทมเพลต

คล้ายกับตรรกะการสืบทอดเลเอาท์ หากไม่พบเทมเพลตหรือพาร์ทเชียลในเส้นทางที่เป็นไปตามปกติ คอนโทรลเลอร์จะค้นหาเทมเพลตหรือพาร์ทเชียลที่จะแสดงในโครงสร้างการสืบทอดของมัน เช่น:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
end
```

```ruby
# app/controllers/admin_controller.rb
class AdminController < ApplicationController
end
```

```ruby
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < AdminController
  def index
  end
end
```

การค้นหาสำหรับการกระทำ `admin/products#index` จะเป็นดังนี้:

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

นี่เป็นสถานที่ที่ดีสำหรับพาร์ทเชียลที่ใช้ร่วมกัน ซึ่งจะถูกแสดงใน ERB ของคุณได้ดังนี้:

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
ไม่มีรายการในรายการนี้ <em>เลย</em>.
```

#### การหลีกเลี่ยงข้อผิดพลาดการเรนเดอร์คู่

ก่อนหน้านี้ ส่วนใหญ่นักพัฒนา Rails จะเจอข้อความผิดพลาด "Can only render or redirect once per action" แม้ว่าจะน่ารำคาญ แต่มันง่ายต่อการแก้ไข ส่วนใหญ่เกิดขึ้นเพราะความเข้าใจที่ผิดเกี่ยวกับวิธีการทำงานของ `render`

ตัวอย่างเช่น นี่คือโค้ดที่จะเกิดข้อผิดพลาดนี้:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

หาก `@book.special?` ประเมินเป็น `true` Rails จะเริ่มกระบวนการเรนเดอร์เพื่อนำตัวแปร `@book` เข้าสู่วิว `special_show` แต่นี้จะ _ไม่_ หยุดรันโค้ดในแอ็กชัน `show` และเมื่อ Rails ถึงส่วนท้ายของแอ็กชัน จะเริ่มเรนเดอร์วิว `regular_show` - และโยนข้อผิดพลาด วิธีการแก้ไขง่าย: ตรวจสอบให้แน่ใจว่าคุณมีการเรียกใช้ `render` หรือ `redirect` เพียงครั้งเดียวในเส้นทางของโค้ดเดียว สิ่งหนึ่งที่ช่วยได้คือ `return` นี่คือเวอร์ชันที่แก้ไขของเมธอด:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
    return
  end
  render action: "regular_show"
end
```
โปรดทราบว่าการเรนเดอร์ที่ถูกทำโดย ActionController จะตรวจสอบว่า `render` ได้ถูกเรียกหรือไม่ ดังนั้นตัวอย่างต่อไปนี้จะทำงานได้โดยไม่มีข้อผิดพลาด:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

นี้จะเรนเดอร์หนังสือที่ตั้งค่า `special?` ด้วยเทมเพลต `special_show` ในขณะที่หนังสืออื่น ๆ จะถูกเรนเดอร์ด้วยเทมเพลต `show` เริ่มต้น

### การใช้ `redirect_to`

วิธีการที่อื่นในการจัดการการส่งคืนการตอบกลับให้กับคำขอ HTTP คือด้วย [`redirect_to`][]. ตามที่คุณเห็น `render` บอก Rails ว่าจะใช้วิว (หรือทรัพยากรอื่น ๆ) ในการสร้างการตอบกลับ แต่เมธอด `redirect_to` ทำอย่างแตกต่างอย่างสิ้นเชิง: มันบอกเบราว์เซอร์ให้ส่งคำขอใหม่สำหรับ URL ที่แตกต่างกัน ตัวอย่างเช่น คุณสามารถเปลี่ยนเส้นทางจากที่คุณอยู่ในรหัสของคุณไปยังดัชนีของรูปภาพในแอปพลิเคชันของคุณด้วยการเรียกนี้:

```ruby
redirect_to photos_url
```

คุณสามารถใช้ [`redirect_back`][] เพื่อส่งผู้ใช้กลับไปยังหน้าที่พวกเขาเพิ่งมาจาก ตำแหน่งนี้ถูกดึงมาจากส่วนหัว `HTTP_REFERER` ซึ่งไม่ได้รับการรับรองว่าจะถูกตั้งค่าโดยเบราว์เซอร์ดังนั้นคุณต้องระบุ `fallback_location` เพื่อใช้ในกรณีนี้

```ruby
redirect_back(fallback_location: root_path)
```

หมายเหตุ: `redirect_to` และ `redirect_back` ไม่หยุดและส่งคืนทันทีจากการดำเนินการของเมธอด แต่เพียงแค่ตั้งค่าการตอบกลับ HTTP คำสั่งที่เกิดขึ้นหลังจากนั้นในเมธอดจะถูกดำเนินการ คุณสามารถหยุดโดยใช้ `return` แบบชัดเจนหรือกลไกหยุดอื่น ๆ ถ้าจำเป็น

#### การรับรหัสสถานะการเปลี่ยนเส้นทางที่แตกต่างกัน

Rails ใช้รหัสสถานะ HTTP 302 เป็นการเปลี่ยนเส้นทางชั่วคราวเมื่อคุณเรียกใช้ `redirect_to` หากคุณต้องการใช้รหัสสถานะที่แตกต่าง เช่น 301 เป็นการเปลี่ยนเส้นทางถาวร คุณสามารถใช้ตัวเลือก `:status`:

```ruby
redirect_to photos_path, status: 301
```

เหมือนกับตัวเลือก `:status` สำหรับ `render` `:status` สำหรับ `redirect_to` ยอมรับการกำหนดหัวเรื่องทั้งตัวเลขและสัญลักษณ์

#### ความแตกต่างระหว่าง `render` และ `redirect_to`

บางครั้งนักพัฒนาที่ไม่มีประสบการณ์คิดว่า `redirect_to` เป็นคำสั่งประเภท `goto` ที่ย้ายการดำเนินการจากที่หนึ่งไปยังอีกที่หนึ่งในรหัส Rails ของคุณ นี่คือ _ไม่ถูกต้อง_ รหัสของคุณหยุดการทำงานและรอคำขอใหม่จากเบราว์เซอร์ มันเพียงแค่เกิดว่าคุณได้บอกเบราว์เซอร์ว่าคำขอใหม่ที่มันควรจะทำต่อ โดยการส่งกลับรหัสสถานะ HTTP 302

พิจารณาการกระทำเหล่านี้เพื่อดูความแตกต่าง:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

ด้วยรหัสในรูปแบบนี้ อาจมีปัญหาถ้าตัวแปร `@book` เป็น `nil` จำไว้ว่า `render :action` ไม่ได้เรียกใช้โค้ดใด ๆ ในการกระทำเป้าหมายดังนั้นไม่มีอะไรจะตั้งค่าตัวแปร `@books` ที่มุมมอง `index` อาจต้องการ วิธีการแก้ไขหนึ่งวิธีคือการเปลี่ยนเส้นทางแทนการเรนเดอร์:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

ด้วยรหัสนี้ เบราว์เซอร์จะส่งคำขอใหม่สำหรับหน้าดัชนี รหัสในเมธอด `index` จะทำงานและทุกอย่างจะดี

ข้อเสียเดียวของรหัสนี้คือมันต้องการการเดินทางไปกลับไปยังเบราว์เซอร์: เบราว์เซอร์ขอคำขอแสดงการแสดงผลด้วย `/books/1` และคอนโทรลเลอร์พบว่าไม่มีหนังสือเล่มใด ๆ ดังนั้นคอนโทรลเลอร์จึงส่งคำขอการเปลี่ยนเส้นทาง 302 กลับไปยังเบราว์เซอร์เพื่อบอกให้ไปที่ `/books/` เบราว์เซอร์ทำตามและส่งคำขอใหม่กลับไปยังคอนโทรลเลอร์เพื่อขอการกระทำ `index` คอนโทรลเลอร์จึงรับหนังสือทั้งหมดในฐานข้อมูลและเรนเดอร์เทมเพลตดัชนี และส่งกลับไปยังเบราว์เซอร์ซึ่งจะแสดงผลบนหน้าจอของคุณ
ในแอปพลิเคชันขนาดเล็ก ความหน่วงเวลาที่เพิ่มขึ้นนี้อาจไม่เป็นปัญหา แต่ถ้าเวลาตอบสนองเป็นปัญหา ควรพิจารณาเรื่องนี้ สามารถสาธิตวิธีการจัดการด้วยตัวอย่างที่สร้างขึ้นมาได้ดังนี้:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "หนังสือของคุณไม่พบ"
    render "index"
  end
end
```

การดักจับนี้จะตรวจสอบว่าไม่มีหนังสือที่มี ID ที่ระบุ จากนั้นจะเติมตัวแปร `@books` ด้วยหนังสือทั้งหมดในโมเดล และจากนั้นเรียกใช้งานเทมเพลต `index.html.erb` โดยตรง และส่งกลับไปยังเบราว์เซอร์พร้อมกับข้อความแจ้งเตือนแบบ flash เพื่อแจ้งให้ผู้ใช้รู้ว่าเกิดอะไรขึ้น

### การใช้ `head` เพื่อสร้างการตอบสนองที่มีเฉพาะส่วนหัว

เมธอด [`head`][] สามารถใช้ส่งการตอบสนองที่มีเฉพาะส่วนหัวไปยังเบราว์เซอร์ได้ เมธอด `head` รับพารามิเตอร์เป็นตัวเลขหรือสัญลักษณ์ (ดูตารางอ้างอิงที่ [นี่](#the-status-option)) ที่แทนรหัสสถานะ HTTP และอาร์กิวเมนต์ตัวเลือกจะถูกแปลงเป็นแฮชของชื่อและค่าของส่วนหัว ตัวอย่างเช่น คุณสามารถส่งเฉพาะส่วนหัวของข้อผิดพลาดได้ดังนี้:

```ruby
head :bad_request
```

นี้จะสร้างส่วนหัวดังต่อไปนี้:

```http
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

หรือคุณสามารถใช้ส่วนหัว HTTP อื่น ๆ เพื่อสื่อสารข้อมูลอื่น ๆ ได้ดังนี้:

```ruby
head :created, location: photo_path(@photo)
```

ซึ่งจะสร้างส่วนหัวดังต่อไปนี้:

```http
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

การกำหนดโครงสร้างเลเอาท์
-------------------

เมื่อ Rails แสดงมุมมองเป็นการตอบสนอง จะทำโดยรวมมุมมองกับเลเอาท์ปัจจุบัน โดยใช้กฎการค้นหาเลเอาท์ปัจจุบันที่ได้ถูกกล่าวถึงไว้ในเอกสารนี้ ภายในเลเอาท์ คุณสามารถเข้าถึงเครื่องมือสามอย่างสำหรับการรวมเอาส่วนประกอบต่าง ๆ เข้าด้วยกันเพื่อสร้างการตอบสนองโดยรวม:

* Asset tags
* `yield` และ [`content_for`][]
* Partials


### เครื่องมือช่วย Asset Tag

เครื่องมือช่วย Asset ให้เมธอดสำหรับสร้าง HTML ที่เชื่อมโยงมุมมองกับฟีด จาวาสคริปต์ สไตล์ชีต รูปภาพ วิดีโอ และเสียง มีเครื่องมือช่วย Asset ทั้งหมด 6 ตัวให้ใช้ใน Rails:

* [`auto_discovery_link_tag`][]
* [`javascript_include_tag`][]
* [`stylesheet_link_tag`][]
* [`image_tag`][]
* [`video_tag`][]
* [`audio_tag`][]

คุณสามารถใช้แท็กเหล่านี้ในเลเอาท์หรือมุมมองอื่น ๆ แม้ว่า `auto_discovery_link_tag`, `javascript_include_tag`, และ `stylesheet_link_tag` จะใช้งานอยู่ในส่วน `<head>` ของเลเอาท์อย่างส่วนใหญ่

คำเตือน: เครื่องมือช่วย Asset ไม่ตรวจสอบความมีอยู่ของส่วนประกอบในตำแหน่งที่ระบุ แต่เพียงแค่สมมุติว่าคุณรู้ว่าคุณทำอะไรอยู่และสร้างลิงก์


#### เชื่อมโยงไปยังฟีดด้วย `auto_discovery_link_tag`

ช่วยให้ [`auto_discovery_link_tag`][] สร้าง HTML ที่เบราว์เซอร์และอ่านฟีดสามารถใช้ตรวจสอบการมีอยู่ของฟีด RSS, Atom หรือ JSON ได้ มันรับประเภทของลิงก์ (`:rss`, `:atom`, หรือ `:json`) และแฮชของตัวเลือกที่ถูกส่งผ่านไปยัง url_for และแฮชของตัวเลือกสำหรับแท็ก:

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS Feed"}) %>
```

มีตัวเลือกแท็กทั้งหมด 3 ตัวสำหรับ `auto_discovery_link_tag`:
* `:rel` ระบุค่า `rel` ในลิงก์ ค่าเริ่มต้นคือ "alternate"
* `:type` ระบุ MIME type แบบชัดเจน  Rails จะสร้าง MIME type ที่เหมาะสมโดยอัตโนมัติ
* `:title` ระบุชื่อของลิงก์ ค่าเริ่มต้นคือค่า `:type` ในรูปแบบตัวพิมพ์ใหญ่ เช่น "ATOM" หรือ "RSS"

#### การเชื่อมโยงไฟล์ JavaScript ด้วย `javascript_include_tag`

ช่วยเหลือ [`javascript_include_tag`][] จะสร้างแท็ก HTML `script` สำหรับแต่ละแหล่งที่ให้

หากคุณใช้ Rails กับ [Asset Pipeline](asset_pipeline.html) ที่เปิดใช้งาน ช่วยเหลือนี้จะสร้างลิงก์ไปที่ `/assets/javascripts/` แทนที่จะเป็น `public/javascripts` ที่ใช้ในรุ่นก่อนหน้าของ Rails ลิงก์นี้จะถูกให้บริการโดย asset pipeline

ไฟล์ JavaScript ภายในแอปพลิเคชัน Rails หรือ Rails engine จะอยู่ในหนึ่งในสามตำแหน่ง: `app/assets`, `lib/assets` หรือ `vendor/assets` สถานที่เหล่านี้จะอธิบายอย่างละเอียดในส่วน [Asset Organization ในเอกสาร Asset Pipeline Guide](asset_pipeline.html#asset-organization)

คุณสามารถระบุเส้นทางเต็มที่เกี่ยวข้องกับรากเอกสารหรือ URL ได้ตามที่คุณต้องการ เช่น เพื่อเชื่อมโยงไปยังไฟล์ JavaScript ที่อยู่ในไดเรกทอรีที่ชื่อ `javascripts` ภายในหนึ่งใน `app/assets`, `lib/assets` หรือ `vendor/assets` คุณสามารถทำดังนี้:

```erb
<%= javascript_include_tag "main" %>
```

Rails จะแสดงแท็ก `script` เช่นนี้:

```html
<script src='/assets/main.js'></script>
```

คำขอสำหรับทรัพยากรนี้จะถูกให้บริการโดย gem Sprockets

ในการรวมไฟล์หลาย ๆ ไฟล์ เช่น `app/assets/javascripts/main.js` และ `app/assets/javascripts/columns.js` ในเวลาเดียวกัน:

```erb
<%= javascript_include_tag "main", "columns" %>
```

ในการรวม `app/assets/javascripts/main.js` และ `app/assets/javascripts/photos/columns.js`:

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

ในการรวม `http://example.com/main.js`:

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### การเชื่อมโยงไฟล์ CSS ด้วย `stylesheet_link_tag`

ช่วยเหลือ [`stylesheet_link_tag`][] จะสร้างแท็ก HTML `<link>` สำหรับแต่ละแหล่งที่ให้

หากคุณใช้ Rails กับ "Asset Pipeline" ที่เปิดใช้งาน ช่วยเหลือนี้จะสร้างลิงก์ไปที่ `/assets/stylesheets/` ลิงก์นี้จะถูกประมวลผ่าน gem Sprockets ไฟล์สไตล์ชีทสามารถเก็บไว้ในหนึ่งในสามตำแหน่ง: `app/assets`, `lib/assets` หรือ `vendor/assets`

คุณสามารถระบุเส้นทางเต็มที่เกี่ยวข้องกับรากเอกสารหรือ URL ได้ เช่น เพื่อเชื่อมโยงไปยังไฟล์สไตล์ชีทที่อยู่ในไดเรกทอรีที่ชื่อ `stylesheets` ภายในหนึ่งใน `app/assets`, `lib/assets` หรือ `vendor/assets` คุณสามารถทำดังนี้:

```erb
<%= stylesheet_link_tag "main" %>
```

ในการรวม `app/assets/stylesheets/main.css` และ `app/assets/stylesheets/columns.css`:

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

ในการรวม `app/assets/stylesheets/main.css` และ `app/assets/stylesheets/photos/columns.css`:

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

ในการรวม `http://example.com/main.css`:

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

โดยค่าเริ่มต้น `stylesheet_link_tag` สร้างลิงก์ด้วย `rel="stylesheet"` คุณสามารถแทนที่ค่าเริ่มต้นนี้ได้โดยระบุตัวเลือกที่เหมาะสม (`:rel`):

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### การเชื่อมโยงไปยังรูปภาพด้วย `image_tag`

ช่วยเหลือ [`image_tag`][] จะสร้างแท็ก HTML `<img />` สำหรับไฟล์ที่ระบุ โดยค่าเริ่มต้นไฟล์จะถูกโหลดจาก `public/images`

คำเตือน: โปรดทราบว่าคุณต้องระบุนามสกุลของรูปภาพ

```erb
<%= image_tag "header.png" %>
```

คุณสามารถระบุเส้นทางไปยังรูปภาพได้ถ้าคุณต้องการ:

```erb
<%= image_tag "icons/delete.gif" %>
```

คุณสามารถระบุแฮชของตัวเลือก HTML เพิ่มเติมได้:

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```
คุณสามารถระบุข้อความแทนภาพที่จะใช้เมื่อผู้ใช้ปิดภาพในเบราว์เซอร์ของพวกเขาได้ หากคุณไม่ระบุข้อความแทนภาพโดยชัดเจน มันจะเป็นค่าเริ่มต้นเป็นชื่อไฟล์ของไฟล์ โดยที่ไม่มีนามสกุล ตัวอย่างเช่น แท็กภาพสองตัวนี้จะคืนค่าโค้ดเดียวกัน:

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "หน้าแรก" %>
```

คุณยังสามารถระบุแท็กขนาดพิเศษในรูปแบบ "{ความกว้าง}x{ความสูง}":

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

นอกจากแท็กพิเศษด้านบน คุณยังสามารถระบุแฮชสุดท้ายของตัวเลือก HTML มาตรฐาน เช่น `:class`, `:id`, หรือ `:name`:

```erb
<%= image_tag "home.gif", alt: "ไปที่บ้าน",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### การเชื่อมโยงไปยังวิดีโอด้วย `video_tag`

ช่วยเหลือ [`video_tag`][] สร้างแท็ก HTML5 `<video>` ไปยังไฟล์ที่ระบุ โดยค่าเริ่มต้นไฟล์จะถูกโหลดจาก `public/videos`.

```erb
<%= video_tag "movie.ogg" %>
```

สร้าง

```erb
<video src="/videos/movie.ogg" />
```

เช่นเดียวกับ `image_tag` คุณสามารถระบุเส้นทาง ไม่ว่าจะเป็นสัมบูรณ์หรือเกี่ยวข้องกับไดเรกทอรี `public/videos` นอกจากนี้คุณยังสามารถระบุตัวเลือก `size: "#{ความกว้าง}x#{ความสูง}"` เหมือนกับ `image_tag` แท็กวิดีโอยังสามารถมีตัวเลือก HTML อื่น ๆ ที่ระบุท้าย (`id`, `class` เป็นต้น)

แท็กวิดีโอยังรองรับตัวเลือก HTML ทั้งหมดของ `<video>` ผ่านแฮชตัวเลือก HTML รวมถึง:

* `poster: "ชื่อรูปภาพ.png"` ให้รูปภาพไว้แทนวิดีโอก่อนที่จะเริ่มเล่น
* `autoplay: true` เริ่มเล่นวิดีโอเมื่อโหลดหน้า
* `loop: true` วนวิดีโอเมื่อถึงจุดสิ้นสุด
* `controls: true` ให้ควบคุมที่จัดหาให้โดยเบราว์เซอร์สำหรับผู้ใช้เล่นวิดีโอ
* `autobuffer: true` วิดีโอจะโหลดไฟล์สำหรับผู้ใช้เมื่อโหลดหน้า

คุณยังสามารถระบุวิดีโอหลายรายการที่จะเล่นโดยการส่งอาร์เรย์ของวิดีโอไปยัง `video_tag`:

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

นี้จะสร้าง:

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### การเชื่อมโยงไปยังไฟล์เสียงด้วย `audio_tag`

ช่วยเหลือ [`audio_tag`][] สร้างแท็ก HTML5 `<audio>` ไปยังไฟล์ที่ระบุ โดยค่าเริ่มต้นไฟล์จะถูกโหลดจาก `public/audios`.

```erb
<%= audio_tag "music.mp3" %>
```

คุณสามารถระบุเส้นทางไปยังไฟล์เสียงได้ถ้าคุณต้องการ:

```erb
<%= audio_tag "music/first_song.mp3" %>
```

คุณยังสามารถระบุแฮชของตัวเลือกเพิ่มเติม เช่น `:id`, `:class` เป็นต้น

เช่นเดียวกับ `video_tag` `audio_tag` มีตัวเลือกพิเศษ:

* `autoplay: true` เริ่มเล่นเสียงเมื่อโหลดหน้า
* `controls: true` ให้ควบคุมที่จัดหาให้โดยเบราว์เซอร์สำหรับผู้ใช้เล่นเสียง
* `autobuffer: true` เสียงจะโหลดไฟล์สำหรับผู้ใช้เมื่อโหลดหน้า

### เข้าใจ `yield`

ภายในเนื้อหาของเลเอาท์ `yield` ระบุส่วนที่เนื้อหาจากมุมมองควรถูกแทรก เริ่มต้นที่ง่ายที่สุดคือการใช้ `yield` เดียว ซึ่งเนื้อหาทั้งหมดของมุมมองที่กำลังถูกแสดงอยู่จะถูกแทรก:

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```
คุณยังสามารถสร้างเลเอาท์ที่มีภายในมีหลายส่วนที่ให้ผลลัพธ์:

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

ส่วนหลักของมุมมองจะถูกแสดงเสมอใน `yield` ที่ไม่มีชื่อ ในการแสดงเนื้อหาใน `yield` ที่มีชื่อ คุณสามารถใช้เมธอด `content_for` 

### การใช้เมธอด `content_for`

เมธอด [`content_for`][] ช่วยให้คุณสามารถแทรกเนื้อหาลงในบล็อก `yield` ที่มีชื่อในเลเอาท์ของคุณได้ ตัวอย่างเช่น มุมมองนี้จะทำงานร่วมกับเลเอาท์ที่คุณเพิ่งเห็น:

```html+erb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

ผลลัพธ์จากการแสดงหน้านี้ในเลเอาท์ที่กำหนดคือ HTML นี้:

```html+erb
<html>
  <head>
  <title>A simple page</title>
  </head>
  <body>
  <p>Hello, Rails!</p>
  </body>
</html>
```

เมธอด `content_for` มีประโยชน์มากเมื่อเลเอาท์ของคุณมีส่วนที่แตกต่างกันเช่น แถบข้างและส่วนท้ายที่ควรได้รับเนื้อหาของตนเอง นอกจากนี้ยังมีประโยชน์ในการแทรกแท็กที่โหลดไฟล์ JavaScript หรือ CSS ที่เฉพาะเพจลงในส่วนหัวของเลเอาท์ที่เป็นทั่วไป

### การใช้ Partial

Partial templates - ที่เรียกว่า "partials" - เป็นอุปกรณ์อื่น ๆ ที่ใช้ในการแบ่งกระบวนการเรนเดอร์เป็นชิ้นย่อยที่สามารถจัดการได้ง่ายขึ้น ด้วย partial คุณสามารถย้ายโค้ดสำหรับการเรนเดอร์ส่วนหนึ่งของการตอบสนองไปยังไฟล์ของตัวเอง

#### การตั้งชื่อ Partial

ในการเรนเดอร์ partial เป็นส่วนหนึ่งของมุมมอง คุณใช้เมธอด [`render`][view.render] ภายในมุมมอง:

```html+erb
<%= render "menu" %>
```

นี้จะเรนเดอร์ไฟล์ที่ชื่อ `_menu.html.erb` ที่จุดนั้นภายในมุมมองที่กำลังเรนเดอร์ โปรดทราบว่ามีอักขระขึ้นต้นด้วยขีดล่าง: partial ถูกตั้งชื่อด้วยอักขระขีดล่างเพื่อแยกจากมุมมองปกติ แม้ว่าจะไม่มีอักขระขีดล่างเมื่ออ้างถึง สิ่งนี้ยังเป็นจริงเมื่อคุณดึง partial จากโฟลเดอร์อื่น:

```html+erb
<%= render "shared/menu" %>
```

โค้ดนี้จะดึง partial จาก `app/views/shared/_menu.html.erb`


#### การใช้ Partial เพื่อทำให้มุมมองง่ายขึ้น

วิธีหนึ่งในการใช้ partial คือที่จะใช้เป็นส่วนเสริมของ subroutine: เป็นวิธีในการย้ายรายละเอียดออกจากมุมมองเพื่อให้คุณสามารถเข้าใจว่าอะไรกำลังเกิดขึ้นได้ง่ายขึ้น ตัวอย่างเช่น คุณอาจมีมุมมองที่มีลักษณะดังนี้:

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

ที่นี่ partial `_ad_banner.html.erb` และ `_footer.html.erb` อาจมีเนื้อหาที่ใช้ร่วมกันโดยหลายหน้าในแอปพลิเคชันของคุณ คุณไม่จำเป็นต้องเห็นรายละเอียดของส่วนเหล่านี้เมื่อคุณตั้งใจที่หน้าเฉพาะ

เหมือนกับที่เห็นในส่วนก่อนหน้าของเอกสารนี้ `yield` เป็นเครื่องมือที่มีประสิทธิภาพมากในการทำความสะอาดเลเอาท์ของคุณ โดยจำไว้ว่าเป็นรูบีเท่านั้น ดังนั้นคุณสามารถใช้ได้เกือบทุกที่ เช่น เราสามารถใช้ในการทำความสะอาดการกำหนดเลเอาท์ฟอร์มสำหรับทรัพยากรที่คล้ายกัน:

* `users/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Name contains: <%= form.text_field :name_contains %>
      </p>
    <% end %>
    ```

* `roles/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Title contains: <%= form.text_field :title_contains %>
      </p>
    <% end %>
    ```
* `shared/_search_filters.html.erb`

    ```html+erb
    <%= form_with model: search do |form| %>
      <h1>แบบฟอร์มค้นหา:</h1>
      <fieldset>
        <%= yield form %>
      </fieldset>
      <p>
        <%= form.submit "ค้นหา" %>
      </p>
    <% end %>
    ```

เคล็ดลับ: สำหรับเนื้อหาที่ใช้ร่วมกันในทุกหน้าของแอปพลิเคชันของคุณ คุณสามารถใช้ partials โดยตรงจาก layouts

#### Partial Layouts

Partial สามารถใช้ layout file ของตัวเองได้เช่นเดียวกับ view สำหรับตัวอย่าง เราอาจเรียก partial ดังนี้:

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

นี่จะค้นหา partial ที่ชื่อ `_link_area.html.erb` และ render ด้วย layout `_graybar.html.erb` โปรดทราบว่า layouts สำหรับ partials จะตามการตั้งชื่อด้วยขีดล่างด้านหน้าเช่นเดียวกับ partials ปกติ และจะถูกวางไว้ในโฟลเดอร์เดียวกับ partial ที่เกี่ยวข้อง (ไม่ใช่ในโฟลเดอร์ `layouts` หลัก)

โปรดทราบว่าการระบุ `:partial` โดยชัดเจนจำเป็นเมื่อส่งค่าตัวเลือกเพิ่มเติม เช่น `:layout`

#### การส่งตัวแปรท้องถิ่น

คุณยังสามารถส่งตัวแปรท้องถิ่นเข้าไปใน partials เพื่อทำให้มีความสามารถและยืดหยุ่นมากขึ้น ตัวอย่างเช่น คุณสามารถใช้เทคนิคนี้เพื่อลดความซ้ำซ้อนระหว่างหน้าใหม่และหน้าแก้ไข ในขณะที่ยังคงมีเนื้อหาที่แตกต่างกันเล็กน้อย:

* `new.html.erb`

    ```html+erb
    <h1>โซนใหม่</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>แก้ไขโซน</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```html+erb
    <%= form_with model: zone do |form| %>
      <p>
        <b>ชื่อโซน</b><br>
        <%= form.text_field :name %>
      </p>
      <p>
        <%= form.submit %>
      </p>
    <% end %>
    ```

แม้ว่า partial เดียวกันจะถูก render เข้าไปในทั้งสอง view แต่ Action View's submit helper จะคืนค่า "สร้างโซน" สำหรับการกระทำใหม่และ "อัปเดตโซน" สำหรับการแก้ไข

ในการส่งตัวแปรท้องถิ่นไปยัง partial ในกรณีที่เฉพาะเจาะจงใช้ `local_assigns`

* `index.html.erb`

    ```erb
    <%= render user.articles %>
    ```

* `show.html.erb`

    ```erb
    <%= render article, full: true %>
    ```

* `_article.html.erb`

    ```erb
    <h2><%= article.title %></h2>

    <% if local_assigns[:full] %>
      <%= simple_format article.body %>
    <% else %>
      <%= truncate article.body %>
    <% end %>
    ```

นี่เป็นวิธีที่เราสามารถใช้ partial โดยไม่ต้องประกาศตัวแปรท้องถิ่นทั้งหมด

ทุก partial ยังมีตัวแปรท้องถิ่นที่มีชื่อเดียวกันกับ partial (ไม่รวมขีดล่างด้านหน้า) คุณสามารถส่งวัตถุเข้าไปในตัวแปรท้องถิ่นนี้ผ่านตัวเลือก `:object`:

```erb
<%= render partial: "customer", object: @new_customer %>
```

ภายใน partial `customer` ตัวแปร `customer` จะอ้างอิงถึง `@new_customer` จาก parent view

หากคุณมี instance ของ model ที่จะ render เข้าสู่ partial คุณสามารถใช้ syntax ย่อได้:

```erb
<%= render @customer %>
```

สมมติว่าตัวแปร instance `@customer` มี instance ของ model `Customer` นี้จะใช้ `_customer.html.erb` เพื่อ render และจะส่งตัวแปรท้องถิ่น `customer` เข้าไปใน partial ซึ่งจะอ้างอิงถึงตัวแปร instance `@customer` ใน parent view

#### การ render คอลเลกชัน

Partials มีประโยชน์มากในการ render คอลเลกชัน เมื่อคุณส่งคอลเลกชันไปยัง partial ผ่านตัวเลือก `:collection` partial จะถูกแทรกเพียงครั้งเดียวสำหรับแต่ละสมาชิกในคอลเลกชัน:
* `index.html.erb`

    ```html+erb
    <h1>สินค้า</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>ชื่อสินค้า: <%= product.name %></p>
    ```

เมื่อ partial ถูกเรียกใช้งานด้วยคอลเลกชันที่มีชื่อเป็นพหูพจน์ แต่ละอินสแตนซ์ของ partial สามารถเข้าถึงสมาชิกในคอลเลกชันที่กำลังถูกแสดงผ่านตัวแปรที่มีชื่อตามชื่อของ partial ได้ ในกรณีนี้ partial คือ `_product` และภายใน partial `_product` คุณสามารถอ้างอิงถึง `product` เพื่อรับอินสแตนซ์ที่กำลังถูกแสดงผลได้

ยังมีวิธีย่อสั้นสำหรับการทำนี้ โดยสมมติว่า `@products` เป็นคอลเลกชันของอินสแตนซ์ของ `Product` คุณสามารถเขียนดังนี้ใน `index.html.erb` เพื่อให้ได้ผลลัพธ์เดียวกัน:

```html+erb
<h1>สินค้า</h1>
<%= render @products %>
```

Rails จะกำหนดชื่อของ partial ที่จะใช้โดยดูที่ชื่อโมเดลในคอลเลกชัน ในความเป็นจริงแล้วคุณยังสามารถสร้างคอลเลกชันที่แตกต่างกันได้และแสดงผลในวิธีนี้ และ Rails จะเลือก partial ที่เหมาะสมสำหรับแต่ละสมาชิกในคอลเลกชัน:

* `index.html.erb`

    ```html+erb
    <h1>ติดต่อ</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    ```

* `customers/_customer.html.erb`

    ```html+erb
    <p>ลูกค้า: <%= customer.name %></p>
    ```

* `employees/_employee.html.erb`

    ```html+erb
    <p>พนักงาน: <%= employee.name %></p>
    ```

ในกรณีนี้ Rails จะใช้ partial ของลูกค้าหรือพนักงานตามที่เหมาะสมสำหรับแต่ละสมาชิกในคอลเลกชัน

ในกรณีที่คอลเลกชันเป็นว่างเปล่า `render` จะคืนค่าเป็น nil ดังนั้นคุณสามารถให้เนื้อหาทดแทนได้อย่างง่ายดาย

```html+erb
<h1>สินค้า</h1>
<%= render(@products) || "ไม่มีสินค้าที่มีอยู่" %>
```

#### ตัวแปรท้องถิ่น

ในการใช้ตัวแปรท้องถิ่นที่กำหนดเองใน partial ระบุตัวเลือก `:as` ในการเรียกใช้ partial:

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

ด้วยการเปลี่ยนแปลงนี้คุณสามารถเข้าถึงอินสแตนซ์ของคอลเลกชัน `@products` ในรูปแบบของตัวแปรท้องถิ่น `item` ภายใน partial

คุณยังสามารถส่งตัวแปรท้องถิ่นอื่น ๆ เข้าไปใน partial ที่คุณกำลังแสดงผลด้วยตัวเลือก `locals: {}`:

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "หน้าสินค้า"} %>
```

ในกรณีนี้ partial จะสามารถเข้าถึงตัวแปรท้องถิ่น `title` ที่มีค่าเป็น "หน้าสินค้า" ได้

#### ตัวแปรนับ

Rails ยังมีตัวแปรนับที่ใช้ใน partial ที่ถูกเรียกใช้โดยคอลเลกชัน ตัวแปรนับมีชื่อตามชื่อของ partial ตามด้วย `_counter` ตัวอย่างเช่นเมื่อแสดงผลคอลเลกชัน `@products` partial `_product.html.erb` สามารถเข้าถึงตัวแปร `product_counter` ได้ ตัวแปรนับจะเป็นดัชนีของจำนวนครั้งที่ partial ถูกแสดงผลภายในวิวที่ครอบอยู่ เริ่มต้นด้วยค่า `0` ในการแสดงผลครั้งแรก

```erb
# index.html.erb
<%= render partial: "product", collection: @products %>
```

```erb
# _product.html.erb
<%= product_counter %> # 0 สำหรับสินค้าแรก 1 สำหรับสินค้าที่สอง...
```

นี้ยังสามารถทำงานได้เมื่อเปลี่ยนชื่อ partial โดยใช้ตัวเลือก `as:` ดังนั้นหากคุณใช้ `as: :item` ตัวแปรนับจะเป็น `item_counter`

#### Spacer Templates

คุณยังสามารถระบุ partial ที่สองที่จะถูกแสดงระหว่างอินสแตนซ์ของ partial หลักโดยใช้ตัวเลือก `:spacer_template`:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```
Rails จะแสดงผล partial `_product_ruler` (โดยไม่มีข้อมูลถูกส่งไปยังมัน) ระหว่างแต่ละคู่ของ partial `_product`.

#### การใช้งาน Collection Partial Layouts

เมื่อทำการแสดงผลข้อมูลเป็นกลุ่ม คุณสามารถใช้ `:layout` option ได้ดังนี้:

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

Layout จะถูกแสดงพร้อมกับ partial สำหรับแต่ละรายการในกลุ่ม ตัวแปร current object และ object_counter จะสามารถใช้ได้ใน layout เช่นเดียวกับใน partial.

### การใช้งาน Nested Layouts

คุณอาจพบว่าแอปพลิเคชันของคุณต้องการ layout ที่แตกต่างเล็กน้อยจาก layout ปกติของแอปพลิเคชันเพื่อรองรับคอนโทรลเลอร์หนึ่งอัน แทนที่จะทำซ้ำ layout หลักและแก้ไข คุณสามารถทำได้โดยใช้ nested layouts (ที่บางครั้งเรียกว่า sub-templates) ตัวอย่างเช่น:

สมมติว่าคุณมี layout ของ `ApplicationController` ดังนี้:

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "Page Title" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">เมนูด้านบนที่นี่</div>
      <div id="menu">เมนูที่นี่</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

ในหน้าที่ถูกสร้างขึ้นโดย `NewsController` คุณต้องการซ่อนเมนูด้านบนและเพิ่มเมนูด้านขวา:

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">เมนูด้านขวาที่นี่</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

เสร็จสิ้น หน้าที่เกี่ยวข้องกับ News จะใช้ layout ใหม่ โดยซ่อนเมนูด้านบนและเพิ่มเมนูด้านขวาใน div "content".

มีหลายวิธีในการใช้งานเพื่อให้ได้ผลลัพธ์ที่คล้ายกันด้วย sub-templating schemes ที่แตกต่างกัน โปรดทราบว่าไม่มีข้อจำกัดในระดับการซ้อนกัน คุณสามารถใช้เมธอด `ActionView::render` ผ่าน `render template: 'layouts/news'` เพื่อใช้ layout ใหม่ที่มีการซ้อนกันบน layout ของ News หากคุณแน่ใจว่าคุณจะไม่ใช้ subtemplate ของ layout `News` คุณสามารถแทนที่ `content_for?(:news_content) ? yield(:news_content) : yield` ด้วย `yield` เพียงอย่างเดียว.
[controller.render]: https://api.rubyonrails.org/classes/ActionController/Rendering.html#method-i-render
[`redirect_to`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to
[`head`]: https://api.rubyonrails.org/classes/ActionController/Head.html#method-i-head
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`redirect_back`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_back
[`content_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for
[`auto_discovery_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-auto_discovery_link_tag
[`javascript_include_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-javascript_include_tag
[`stylesheet_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-stylesheet_link_tag
[`image_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag
[`video_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-video_tag
[`audio_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-audio_tag
[view.render]: https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render
