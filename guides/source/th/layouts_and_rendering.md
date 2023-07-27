**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 02f663dc709da76ced45deb2ba800a78
เลย์เอาท์และการเรนเดอร์ในเรลส์
==============================

เอกสารนี้เป็นเกี่ยวกับคุณสมบัติเบื้องหลังของ Action Controller และ Action View

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีใช้วิธีการเรนเดอร์ต่าง ๆ ที่มีอยู่ในเรลส์
* วิธีสร้างเลย์เอาท์ที่มีส่วนเนื้อหาหลายส่วน
* วิธีใช้พาร์เชียลเพื่อลดการซ้ำซ้อนในมุมมองของคุณ
* วิธีใช้เลย์เอาท์ที่ซ้อนกัน (เทมเพลตย่อย)

--------------------------------------------------------------------------------

ภาพรวม: วิธีการที่ชิ้นส่วนต่าง ๆ ถูกเชื่อมต่อกัน
-------------------------------------

เอกสารนี้เน้นการปฏิสัมพันธ์ระหว่างคอนโทรลเลอร์และวิวในสามเหลี่ยมโมเดล-วิว-คอนโทรลเลอร์ ตามที่คุณทราบคอนโทรลเลอร์รับผิดชอบในการจัดการกระบวนการทั้งหมดของการจัดการคำขอในเรลส์ แม้ว่ามันจะส่งงานที่หนักให้กับโมเดล แต่เมื่อถึงเวลาส่งคำตอบกลับไปยังผู้ใช้ คอนโทรลเลอร์จะส่งงานให้กับวิว การส่งงานนั้นเป็นเรื่องหลักของเอกสารนี้

อย่างรวดเร็ว นี้เกี่ยวข้องกับการตัดสินใจว่าควรส่งอะไรเป็นการตอบกลับและเรียกใช้เมธอดที่เหมาะสมในการสร้างการตอบกลับนั้น หากการตอบกลับเป็นวิวที่เต็มรูปแบบ เรลส์ยังทำงานเพิ่มเติมเพื่อห่อหุ้มวิวในเลย์เอาท์และบางครั้งอาจดึงวิวย่อยเข้ามาด้วย คุณจะเห็นทางเลือกเหล่านี้ทั้งหมดในภายหลังในเอกสารนี้

การสร้างการตอบกลับ
------------------

จากมุมมองของคอนโทรลเลอร์ มีวิธีสามวิธีในการสร้างการตอบกลับ HTTP:

* เรียกใช้ [`render`][controller.render] เพื่อสร้างการตอบกลับเต็มรูปแบบที่จะส่งกลับไปยังเบราว์เซอร์
* เรียกใช้ [`redirect_to`][] เพื่อส่งรหัสสถานะการเปลี่ยนเส้นทาง HTTP ไปยังเบราว์เซอร์
* เรียกใช้ [`head`][] เพื่อสร้างการตอบกลับที่ประกอบด้วยส่วนหัว HTTP เท่านั้นที่จะส่งกลับไปยังเบราว์เซอร์


### เรนเดอร์ตามค่าเริ่มต้น: ความสะดวกสบายเหนือการกำหนดค่าในการกระทำ

คุณได้ยินว่าเรลส์สนับสนุน "ความสะดวกสบายเหนือการกำหนดค่า" การเรนเดอร์ตามค่าเริ่มต้นเป็นตัวอย่างที่ดีของสิ่งนี้ ตามค่าเริ่มต้นคอนโทรลเลอร์ในเรลส์จะเรนเดอร์วิวที่มีชื่อที่สอดคล้องกับเส้นทางที่ถูกต้อง ตัวอย่างเช่น หากคุณมีโค้ดนี้ในคลาส `BooksController` ของคุณ:

```ruby
class BooksController < ApplicationController
end
```

และต่อไปนี้ในไฟล์เส้นทางของคุณ:

```ruby
resources :books
```

และคุณมีไฟล์วิว `app/views/books/index.html.erb`:

```html+erb
<h1>Books are coming soon!</h1>
```

เรลส์จะเรนเดอร์ `app/views/books/index.html.erb` โดยอัตโนมัติเมื่อคุณไปที่ `/books` และคุณจะเห็น "Books are coming soon!" บนหน้าจอของคุณ

อย่างไรก็ตาม หน้าจอที่กำลังจะมานั้นมีประโยชน์เพียงความยาวน้อยเท่านั้น ดังนั้นคุณจะสร้างโมเดล `Book` ของคุณและเพิ่มการกระทำดัชนีไปยัง `BooksController`:

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

โปรดทราบว่าเราไม่ได้มีการเรนเดอร์ชัดเจนที่สุดท้ายของการกระทำดัชนีในความสอดคล้องกับหลักการ "ความสะดวกสบายเหนือการกำหนดค่า" กฎกำหนดว่าหากคุณไม่เรนเดอร์อะไรชัดเจนท้ายการกระทำของคอนโทรลเลอร์ เรลส์จะค้นหาเทมเพลต `action_name.html.erb` ในเส้นทางวิวของคอนโทรลเลอร์และเรนเดอร์มัน ดังนั้นในกรณีนี้ เรลส์จะเรนเดอร์ไฟล์ `app/views/books/index.html.erb`

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

หมายเหตุ: เรนเดอร์จริงจังถูกดำเนินการโดยคลาสย่อยของโมดูล [`ActionView::Template::Handlers`](https://api.rubyonrails.org/classes/ActionView/Template/Handlers.html) แต่เอกสารนี้ไม่ได้ขุดลึกเข้าไปในกระบวนการนั้น แต่สิ่งสำคัญที่ต้องรู้คือนามสกุลไฟล์ของวิวของคุณควบคุมการเลือกเทมเพลตแฮนเดอร์

### การใช้ `render`
ในกรณีส่วนใหญ่ วิธีการใช้งานเมธอด [`render`][controller.render] ของคอนโทรลเลอร์จะทำหน้าที่หนักในการเรนเดอร์เนื้อหาของแอปพลิเคชันของคุณเพื่อให้ใช้งานโดยเบราว์เซอร์ มีหลายวิธีในการปรับแต่งพฤติกรรมของ `render` คุณสามารถเรนเดอร์วิวเริ่มต้นสำหรับเทมเพลต Rails หรือเทมเพลตที่ระบุเฉพาะ หรือไฟล์ หรือโค้ดในบรรทัดเดียวกัน หรือไม่เรนเดอร์เลย คุณสามารถเรนเดอร์ข้อความ JSON หรือ XML คุณสามารถระบุประเภทเนื้อหาหรือสถานะ HTTP ของการเรนเดอร์ที่ได้รับเช่นกัน

เคล็ดลับ: หากคุณต้องการดูผลลัพธ์ที่แน่นอนของการเรียกใช้ `render` โดยไม่ต้องตรวจสอบในเบราว์เซอร์ คุณสามารถเรียกใช้ `render_to_string` ได้ วิธีนี้ใช้ตัวเลือกเหมือนกับ `render` แต่จะส่งคืนสตริงแทนการส่งคำตอบกลับไปยังเบราว์เซอร์

#### เรนเดอร์วิวของแอคชัน

หากคุณต้องการเรนเดอร์วิวที่สอดคล้องกับเทมเพลตที่แตกต่างในคอนโทรลเลอร์เดียวกัน คุณสามารถใช้ `render` พร้อมกับชื่อของวิว:

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

หากการเรียกใช้ `update` ล้มเหลว การเรียกใช้แอคชัน `update` ในคอนโทรลเลอร์นี้จะเรนเดอร์เทมเพลต `edit.html.erb` ที่เป็นของคอนโทรลเลอร์เดียวกัน

หากคุณต้องการ คุณสามารถใช้สัญลักษณ์แทนสตริงเพื่อระบุแอคชันที่จะเรนเดอร์:

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

#### เรนเดอร์เทมเพลตของแอคชันจากคอนโทรลเลอร์อื่น

หากคุณต้องการเรนเดอร์เทมเพลตจากคอนโทรลเลอร์ที่แตกต่างอย่างสิ้นเชิงจากคอนโทรลเลอร์ที่มีโค้ดแอคชัน คุณสามารถทำได้ด้วย `render` ซึ่งยอมรับเส้นทางเต็ม (เทียบเท่ากับ `app/views`) ของเทมเพลตที่จะเรนเดอร์ ตัวอย่างเช่น หากคุณกำลังเรียกใช้โค้ดใน `AdminProductsController` ที่อยู่ใน `app/controllers/admin` คุณสามารถเรนเดอร์ผลลัพธ์ของแอคชันไปยังเทมเพลตใน `app/views/products` ได้ดังนี้:

```ruby
render "products/show"
```

Rails รู้ว่าวิวนี้เป็นของคอนโทรลเลอร์ที่แตกต่างกันเนื่องจากมีอักขระสแลชภายในสตริง หากคุณต้องการเป็นชัดเจน คุณสามารถใช้ตัวเลือก `:template` (ซึ่งจำเป็นใน Rails 2.2 และรุ่นก่อนหน้านี้):

```ruby
render template: "products/show"
```

#### สรุป

วิธีการเรนเดอร์สองวิธีด้านบน (การเรนเดอร์เทมเพลตของแอคชันอื่นในคอนโทรลเลอร์เดียวกันและการเรนเดอร์เทมเพลตของแอคชันอื่นในคอนโทรลเลอร์ที่แตกต่างกัน) นั้นเป็นรูปแบบที่คล้ายกัน

ในความเป็นจริง ในคลาส `BooksController` ภายในแอคชัน `update` ที่เราต้องการเรนเดอร์เทมเพลตแก้ไขหากหนังสือไม่อัปเดตสำเร็จ การเรียกใช้เรนเดอร์ต่อไปนี้ทั้งหมดจะเรนเดอร์เทมเพลต `edit.html.erb` ในไดเรกทอรี `views/books`:

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

วิธีใดที่คุณใช้เป็นเรื่องของสไตล์และประเพณี แต่หลักการที่สำคัญคือใช้วิธีที่ง่ายที่สุดที่เหมาะสมกับโค้ดที่คุณเขียน

#### การใช้ `render` พร้อมกับ `:inline`

เมธอด `render` สามารถทำงานได้โดยไม่ต้องใช้วิวเลย หากคุณยินดีที่จะใช้ตัวเลือก `:inline` เพื่อให้ ERB เป็นส่วนหนึ่งของการเรียกเมธอด นี่เป็นที่ถูกต้อง:

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

คำเตือน: ไม่มีเหตุผลที่ดีในการใช้ตัวเลือกนี้ การผสม ERB เข้ากับคอนโทรลเลอร์ของคุณจะทำให้ Rails สับสนใจเรื่องการจัดการ MVC และจะทำให้ยากต่อผู้พัฒนาอื่นที่จะติดตามตรรกะของโปรเจกต์ของคุณ ให้ใช้วิว erb แยกต่างหากแทน

ตามค่าเริ่มต้น เรนเดอร์แบบอินไลน์ใช้ ERB คุณสามารถบังคับให้ใช้ Builder แทนด้วยตัวเลือก `:type`:

```ruby
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```
#### การแสดงผลข้อความ

คุณสามารถส่งข้อความธรรมดา - โดยไม่มีการมาร์กอัปเลย์ใด ๆ - กลับไปยังเบราว์เซอร์โดยใช้ตัวเลือก `:plain` กับ `render`:

```ruby
render plain: "OK"
```

เคล็ดลับ: การแสดงข้อความธรรมดามีประโยชน์มากที่สุดเมื่อคุณตอบสนองกับการร้องขอ Ajax หรือเว็บเซอร์วิสที่คาดหวังสิ่งที่ไม่ใช่ HTML ที่ถูกต้อง

หมายเหตุ: โดยค่าเริ่มต้น หากคุณใช้ตัวเลือก `:plain` ข้อความจะถูกแสดงโดยไม่ใช้เลเอาท์ปัจจุบัน หากคุณต้องการให้ Rails ใส่ข้อความลงในเลเอาท์ปัจจุบัน คุณต้องเพิ่มตัวเลือก `layout: true` และใช้นามสกุล `.text.erb` สำหรับไฟล์เลเอาท์

#### การแสดงผล HTML

คุณสามารถส่งสตริง HTML กลับไปยังเบราว์เซอร์โดยใช้ตัวเลือก `:html` กับ `render`:

```ruby
render html: helpers.tag.strong('Not Found')
```

เคล็ดลับ: สิ่งนี้มีประโยชน์เมื่อคุณแสดงส่วนย่อยของโค้ด HTML ที่เล็กน้อย อย่างไรก็ตาม หากมาร์กอัปซับซ้อนคุณอาจต้องพิจารณาย้ายไปยังไฟล์เทมเพลต

หมายเหตุ: เมื่อใช้ตัวเลือก `html:` อักขระ HTML จะถูกหนีไล่ถ้าสตริงไม่ได้รับการสร้างขึ้นด้วย API ที่รองรับ `html_safe`

#### การแสดงผล JSON

JSON เป็นรูปแบบข้อมูล JavaScript ที่ใช้ในหลายไลบรารี Ajax Rails มีการสนับสนุนในการแปลงออบเจ็กต์เป็น JSON และการแสดงผล JSON กลับไปยังเบราว์เซอร์:

```ruby
render json: @product
```

เคล็ดลับ: คุณไม่จำเป็นต้องเรียกใช้ `to_json` บนออบเจ็กต์ที่คุณต้องการแสดงผล หากคุณใช้ตัวเลือก `:json` `render` จะเรียกใช้ `to_json` โดยอัตโนมัติให้คุณ

#### การแสดงผล XML

Rails ยังมีการสนับสนุนในการแปลงออบเจ็กต์เป็น XML และการแสดงผล XML กลับไปยังผู้เรียก:

```ruby
render xml: @product
```

เคล็ดลับ: คุณไม่จำเป็นต้องเรียกใช้ `to_xml` บนออบเจ็กต์ที่คุณต้องการแสดงผล หากคุณใช้ตัวเลือก `:xml` `render` จะเรียกใช้ `to_xml` โดยอัตโนมัติให้คุณ

#### การแสดงผล JavaScript แบบ Vanilla

Rails สามารถแสดง JavaScript แบบ Vanilla:

```ruby
render js: "alert('Hello Rails');"
```

นี้จะส่งสตริงที่ให้มาให้เบราว์เซอร์ด้วย MIME type เป็น `text/javascript`

#### การแสดงผลเนื้อหาแบบ Raw

คุณสามารถส่งเนื้อหาแบบ raw กลับไปยังเบราว์เซอร์โดยไม่ตั้งค่าเนื้อหาใด ๆ โดยใช้ตัวเลือก `:body` กับ `render`:

```ruby
render body: "raw"
```

เคล็ดลับ: ตัวเลือกนี้ควรใช้เฉพาะหากคุณไม่สนใจเนื้อหาประเภทของการตอบสนอง การใช้ `:plain` หรือ `:html` อาจเหมาะสมกว่าในส่วนมากของเวลา

หมายเหตุ: ยกเว้นกรณีที่ถูกแทนที่ การตอบสนองที่คืนมาจากตัวเลือกการแสดงผลนี้จะเป็น `text/plain` เนื่องจากนั้นเป็นประเภทเนื้อหาเริ่มต้นของการตอบสนอง Action Dispatch

#### การแสดงผลไฟล์แบบ Raw

Rails สามารถแสดงไฟล์แบบ raw จากเส้นทางแบบสมบูรณ์ นี้เป็นประโยชน์สำหรับการแสดงไฟล์สถานการณ์เช่นหน้าข้อผิดพลาด

```ruby
render file: "#{Rails.root}/public/404.html", layout: false
```

ส่งผลให้ไฟล์แบบ raw (ไม่รองรับ ERB หรือตัวจัดการอื่น) โดยค่าเริ่มต้นจะถูกแสดงภายในเลเอาท์ปัจจุบัน

คำเตือน: การใช้ตัวเลือก `:file` ร่วมกับข้อมูลที่ผู้ใช้ป้อนอาจเป็นปัญหาด้านความปลอดภัยเนื่องจากผู้โจมตีอาจใช้การกระทำนี้เพื่อเข้าถึงไฟล์ที่มีความสำคัญด้านความปลอดภัยในระบบไฟล์ของคุณ

เคล็ดลับ: `send_file` เป็นตัวเลือกที่ดีกว่าและเร็วกว่าในกรณีที่ไม่จำเป็นต้องใช้เลเอาท์

#### การแสดงผลออบเจ็กต์

Rails สามารถแสดงออบเจ็กต์ที่ตอบสนองกับ `:render_in`

```ruby
render MyRenderable.new
```

นี้จะเรียกใช้ `render_in` บนออบเจ็กต์ที่ให้มาด้วยบริบทของมุมมองปัจจุบัน

คุณยังสามารถให้ออบเจ็กต์โดยใช้ตัวเลือก `:renderable` กับ `render`:

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

โดยค่าเริ่มต้น Rails จะให้บริการผลลัพธ์ของการดำเนินการแสดงผลด้วย MIME content-type เป็น `text/html` (หรือ `application/json` หากคุณใช้ตัวเลือก `:json` หรือ `application/xml` สำหรับตัวเลือก `:xml`) มีเวลาที่คุณอาจต้องการเปลี่ยนแปลงสิ่งนี้และคุณสามารถทำได้โดยการตั้งค่าตัวเลือก `:content_type`:
```ruby
render template: "feed", content_type: "application/rss"
```

##### ตัวเลือก `:layout`

ด้วยตัวเลือกส่วนใหญ่ของ `render` การแสดงเนื้อหาที่ถูกแสดงเป็นส่วนหนึ่งของเลเอาท์ปัจจุบัน คุณจะเรียนรู้เพิ่มเติมเกี่ยวกับเลเอาท์และวิธีการใช้งานในภายหลังในคู่มือนี้

คุณสามารถใช้ตัวเลือก `:layout` เพื่อบอก Rails ให้ใช้ไฟล์ที่ระบุเป็นเลเอาท์สำหรับการกระทำปัจจุบัน:

```ruby
render layout: "special_layout"
```

คุณยังสามารถบอก Rails ให้แสดงผลโดยไม่มีเลเอาท์เลย:

```ruby
render layout: false
```

##### ตัวเลือก `:location`

คุณสามารถใช้ตัวเลือก `:location` เพื่อตั้งค่าส่วนหัว HTTP `Location`:

```ruby
render xml: photo, location: photo_url(photo)
```

##### ตัวเลือก `:status`

Rails จะสร้างตอบสนองโดยอัตโนมัติพร้อมรหัสสถานะ HTTP ที่ถูกต้อง (ในกรณีส่วนใหญ่นี้คือ `200 OK`) คุณสามารถใช้ตัวเลือก `:status` เพื่อเปลี่ยนสิ่งนี้:

```ruby
render status: 500
render status: :forbidden
```

Rails เข้าใจทั้งรหัสสถานะตัวเลขและสัญลักษณ์ที่สอดคล้องกันที่แสดงด้านล่าง

| ชั้นความสำเร็จ      | รหัสสถานะ HTTP | สัญลักษณ์                           |
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
| **เปลี่ยนเส้นทาง**     | 300              | :multiple_choices                |
|                     | 301              | :moved_permanently               |
|                     | 302              | :found                           |
|                     | 303              | :see_other                       |
|                     | 304              | :not_modified                    |
|                     | 305              | :use_proxy                       |
|                     | 307              | :temporary_redirect              |
|                     | 308              | :permanent_redirect              |
| **ข้อผิดพลาดของไคลเอนต์**    | 400              | :bad_request                     |
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

Rails ใช้รูปแบบที่ระบุในคำขอ (หรือ `:html` เป็นค่าเริ่มต้น) คุณสามารถเปลี่ยนได้โดยส่งตัวเลือก `:formats` พร้อมกับสัญลักษณ์หรืออาร์เรย์:

```ruby
render formats: :xml
render formats: [:json, :xml]
```

หากไม่มีเทมเพลตที่มีรูปแบบที่ระบุไว้ จะเกิดข้อผิดพลาด `ActionView::MissingTemplate`.

##### ตัวเลือก `:variants`

นี้บอกให้ Rails มองหาเทมเพลตที่มีรูปแบบเดียวกันแต่แตกต่างกัน
คุณสามารถระบุรายการของตัวแปรได้โดยใช้ตัวเลือก `:variants` ด้วยสัญลักษณ์หรืออาร์เรย์

ตัวอย่างการใช้งานคือนี้

```ruby
# เรียกใช้ใน HomeController#index
render variants: [:mobile, :desktop]
```

ด้วยชุดตัวแปรเหล่านี้ Rails จะมองหาเทมเพลตตามชุดต่อไปนี้และใช้ตัวแรกที่มีอยู่

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

หากไม่มีเทมเพลตที่มีรูปแบบที่ระบุไว้ จะเกิดข้อผิดพลาด `ActionView::MissingTemplate`.

แทนที่จะตั้งค่าตัวแปรแปลงแบบในการเรียกใช้งานคุณยังสามารถตั้งค่าได้ในอ็อบเจกต์คำขอในคำสั่งควบคุมของคุณ

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

เพื่อหาเลเอาท์ปัจจุบัน Rails จะมองหาไฟล์ใน `app/views/layouts` ที่มีชื่อเบสเดียวกับคอนโทรลเลอร์ ตัวอย่างเช่นการแสดงผลของการกระทำจากคลาส `PhotosController` จะใช้ `app/views/layouts/photos.html.erb` (หรือ `app/views/layouts/photos.builder`) หากไม่มีเลเอาท์ที่เฉพาะเจาะจงสำหรับคอนโทรลเลอร์นั้น  Rails จะใช้ `app/views/layouts/application.html.erb` หรือ `app/views/layouts/application.builder` หากไม่มีเลเอาท์ `.erb` Rails จะใช้เลเอาท์ `.builder` หากมีอยู่  Rails ยังให้วิธีการหลายวิธีในการกำหนดเลเอาท์เฉพาะสำหรับคอนโทรลเลอร์และการกระทำแต่ละอัน

##### การระบุเลเอาท์สำหรับคอนโทรลเลอร์

คุณสามารถเขียนทับกฎเริ่มต้นของเลเอาท์ในคอนโทรลเลอร์ของคุณโดยใช้การประกาศ [`layout`][] ตัวอย่างเช่น:

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

ด้วยการประกาศนี้ มุมมองทั้งหมดที่ถูกแสดงผลโดย `ProductsController` จะใช้ `app/views/layouts/inventory.html.erb` เป็นเลเอาท์ของพวกเขา

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

คุณยังสามารถใช้เมธอดแบบอินไลน์ เช่น Proc เพื่อกำหนดเลเอาท์ ตัวอย่างเช่นหากคุณส่งวัตถุ Proc บล็อกที่คุณให้กับ Proc จะได้รับอินสแตนซ์คอนโทรลเลอร์เพื่อให้เลเอาท์สามารถกำหนดได้ตามคำขอปัจจุบัน:

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### เลเอาท์เงื่อนไข

เลเอาท์ที่ระบุในระดับคอนโทรลเลอร์รองรับตัวเลือก `:only` และ `:except` ตัวเลือกเหล่านี้รับชื่อเมธอดหรืออาร์เรย์ของชื่อเมธอดที่สอดคล้องกับชื่อเมธอดภายในคอนโทรลเลอร์:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

ด้วยการประกาศนี้ เลเอาท์ `product` จะถูกใช้สำหรับทุกอย่างยกเว้นเมธอด `rss` และ `index`

##### การสืบทอดเลเอาท์

การประกาศเลเอาท์จะสืบทอดลงมาในลำดับชั้นล่าง และการประกาศเลเอาท์ที่เฉพาะเจาะจงมากขึ้นจะเขียนทับการประกาศที่ทั่วไปมากขึ้น เช่น:

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

* โดยทั่วไป วิวจะถูกแสดงในเลเอาต์ `main`
* `ArticlesController#index` จะใช้เลเอาต์ `main`
* `SpecialArticlesController#index` จะใช้เลเอาต์ `special`
* `OldArticlesController#show` จะไม่ใช้เลเอาต์เลย
* `OldArticlesController#index` จะใช้เลเอาต์ `old`

##### การสืบทอดเทมเพลต

คล้ายกับตรรกะการสืบทอดเลเอาต์ หากไม่พบเทมเพลตหรือพาร์ทเชียลในเส้นทางที่สามารถใช้งานได้ คอนโทรลเลอร์จะค้นหาเทมเพลตหรือพาร์ทเชียลที่จะแสดงในสายสืบทอดของมัน ตัวอย่างเช่น:

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

นี่ทำให้ `app/views/application/` เป็นที่เหมาะสำหรับพาร์ทเชียลที่ใช้ร่วมกัน ซึ่งสามารถแสดงใน ERB ได้ดังนี้:

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
ไม่มีรายการในรายการนี้ <em>เลย</em>.
```

#### การหลีกเลี่ยงข้อผิดพลาดการแสดงซ้ำ

ก่อนหน้านี้หรือในภายหลัง นักพัฒนา Rails ส่วนใหญ่จะเจอข้อความผิดพลาด "Can only render or redirect once per action" แม้ว่าจะน่ารำคาญ แต่มันง่ายต่อการแก้ไข ส่วนใหญ่เกิดขึ้นเพราะเข้าใจผิดเกี่ยวกับวิธีที่ `render` ทำงาน

ตัวอย่างเช่น นี่คือโค้ดที่จะเกิดข้อผิดพลาด:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

หาก `@book.special?` ประเมินเป็น `true` Rails จะเริ่มกระบวนการแสดงผลเพื่อเอาต์พุตตัวแปร `@book` เข้าสู่วิว `special_show` แต่นี้จะ _ไม่_ หยุดรันโค้ดที่เหลือในการกระทำ `show` และเมื่อ Rails ถึงส่วนท้ายของการกระทำ จะเริ่มแสดงผลวิว `regular_show` - และโยนข้อผิดพลาด วิธีแก้ไขง่ายๆ คือ ตรวจสอบให้แน่ใจว่าคุณมีการเรียกใช้ `render` หรือ `redirect` เพียงครั้งเดียวในเส้นทางโค้ดเดียว สิ่งหนึ่งที่ช่วยได้คือ `return` นี่คือเวอร์ชันที่แก้ไขของเมธอด:

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

โปรดทราบว่าการแสดงผลที่เกิดขึ้นโดยอัตโนมัติโดย ActionController จะตรวจสอบว่า `render` ได้รับการเรียกหรือไม่ ดังนั้นตัวอย่างต่อไปนี้จะทำงานได้โดยไม่มีข้อผิดพลาด:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

นี้จะแสดงผลหนังสือที่ตั้งค่า `special?` ด้วยเทมเพลต `special_show` ในขณะที่หนังสืออื่นๆ จะแสดงผลด้วยเทมเพลต `show` เริ่มต้น

### การใช้ `redirect_to`

วิธีการอื่นในการจัดการการส่งคืนการตอบรับให้กับคำขอ HTTP คือด้วย [`redirect_to`][] ตามที่คุณเคยเห็น `render` บอก Rails วิว (หรือทรัพยากรอื่นๆ) ที่จะใช้ในการสร้างการตอบรับ วิธีการ `redirect_to` ทำอย่างต่างหาก: มันบอกเบราว์เซอร์ให้ส่งคำขอใหม่สำหรับ URL ที่แตกต่าง ตัวอย่างเช่น คุณสามารถเปลี่ยนเส้นทางจากที่คุณอยู่ในโค้ดของคุณไปยังดัชนีของรูปภาพในแอปพลิเคชันของคุณด้วยการเรียกใช้:

```ruby
redirect_to photos_url
```

คุณสามารถใช้ [`redirect_back`][] เพื่อส่งผู้ใช้กลับไปยังหน้าที่พึ่งเข้ามา ตำแหน่งนี้ถูกดึงจากส่วนหัว `HTTP_REFERER` ซึ่งไม่ได้รับการรับรองว่าจะถูกตั้งค่าโดยเบราว์เซอร์ดังนั้นคุณต้องระบุ `fallback_location` เพื่อใช้ในกรณีนี้

```ruby
redirect_back(fallback_location: root_path)
```

หมายเหตุ: `redirect_to` และ `redirect_back` ไม่หยุดและส่งคืนทันทีจากการดำเนินการของเมธอด แต่เพียงแค่ตั้งค่าการตอบรับ HTTP คำสั่งที่เกิดขึ้นหลังจากนั้นในเมธอดจะถูกรันคุณสามารถหยุดโดยการใช้ `return` แสดงผลหรือกลไกหยุดอื่นๆ หากจำเป็น


#### รับรหัสสถานะการเปลี่ยนเส้นทางที่แตกต่างกัน

Rails ใช้รหัสสถานะ HTTP 302 การเปลี่ยนเส้นทางชั่วคราว เมื่อคุณเรียกใช้ `redirect_to` หากคุณต้องการใช้รหัสสถานะที่แตกต่าง เช่น 301 การเปลี่ยนเส้นทางถาวร คุณสามารถใช้ตัวเลือก `:status` ได้:
```ruby
redirect_to photos_path, status: 301
```

เหมือนกับตัวเลือก `:status` สำหรับ `render`, `:status` สำหรับ `redirect_to` ยอมรับทั้งตัวเลขและสัญลักษณ์ในการระบุส่วนหัว

#### ความแตกต่างระหว่าง `render` และ `redirect_to`

บางครั้งนักพัฒนาที่ไม่มีประสบการณ์คิดว่า `redirect_to` เป็นคำสั่งประเภท `goto` ที่ย้ายการประมวลผลจากที่หนึ่งไปยังอีกที่หนึ่งในโค้ด Rails ของคุณ นี่คือ _ไม่ถูกต้อง_ โค้ดของคุณจะหยุดทำงานและรอคำขอใหม่จากเบราว์เซอร์ มันเพียงแค่ว่าคุณได้บอกเบราว์เซอร์ว่าคำขอใหม่ที่ควรจะทำอะไรโดยการส่งกลับรหัสสถานะ HTTP 302

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

ด้วยโค้ดในรูปแบบนี้ จะมีปัญหาเมื่อตัวแปร `@book` เป็น `nil` จำไว้ว่า `render :action` ไม่ได้เรียกใช้โค้ดใด ๆ ในการกระทำเป้าหมาย ดังนั้นไม่มีอะไรจะตั้งค่าตัวแปร `@books` ที่มุมมอง `index` ที่อาจจะต้องการ วิธีการแก้ไขหนึ่งคือการเปลี่ยนเส้นทางแทนการเรียกใช้:

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

ด้วยโค้ดนี้ เบราว์เซอร์จะสร้างคำขอใหม่สำหรับหน้าดัชนี โค้ดในเมธอด `index` จะทำงานและทุกอย่างจะเป็นไปได้

เพียงเท่านี้โค้ดนี้จะมีข้อเสียเพียงอย่างเดียวคือต้องมีการส่งกลับไปยังเบราว์เซอร์: เบราว์เซอร์ขอคำขอแสดงการกระทำแสดงรายการที่ `/books/1` และคอนโทรลเลอร์พบว่าไม่มีหนังสือ ดังนั้นคอนโทรลเลอร์จะส่งคำขอตอบการเปลี่ยนเส้นทาง 302 กลับไปยังเบราว์เซอร์เพื่อบอกให้ไปที่ `/books/` เบราว์เซอร์ทำตามและส่งคำขอใหม่กลับไปยังคอนโทรลเลอร์เพื่อขอการกระทำ `index` คอนโทรลเลอร์จะได้รับหนังสือทั้งหมดในฐานข้อมูลและเรียกใช้เทมเพลตดัชนีและส่งกลับไปยังเบราว์เซอร์ซึ่งจะแสดงบนหน้าจอของคุณ

ในแอปพลิเคชันขนาดเล็ก การเพิ่มความล่าช้านี้อาจไม่เป็นปัญหา แต่ถ้าเวลาตอบสนองเป็นปัญหา คุณควรพิจารณา ตัวอย่างการจัดการด้วยตัวอย่างที่สร้างขึ้น:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "ไม่พบหนังสือของคุณ"
    render "index"
  end
end
```

สิ่งนี้จะตรวจสอบว่าไม่มีหนังสือที่ระบุ ID จะเติมตัวแปร `@books` ด้วยหนังสือทั้งหมดในโมเดล และจากนั้นเรียกใช้เทมเพลต `index.html.erb` โดยตรงและส่งกลับไปยังเบราว์เซอร์พร้อมกับข้อความแจ้งเตือนเพื่อบอกผู้ใช้ว่าเกิดอะไรขึ้น

### การใช้ `head` เพื่อสร้างการตอบสนองที่มีเฉพาะส่วนหัว

เมธอด [`head`][] สามารถใช้ส่งการตอบสนองที่มีเฉพาะส่วนหัวไปยังเบราว์เซอร์ได้ เมธอด `head` ยอมรับตัวเลขหรือสัญลักษณ์ (ดูตารางอ้างอิงที่[นี่](#the-status-option)) ที่แทนรหัสสถานะ HTTP เมธอดอาร์กิวเมนต์จะถูกแปลงเป็นแฮชของชื่อส่วนหัวและค่า ตัวอย่างเช่นคุณสามารถส่งเฉพาะส่วนหัวข้อผิดพลาดได้:

```ruby
head :bad_request
```

นี้จะสร้างส่วนหัวต่อไปนี้:

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

หรือคุณสามารถใช้ส่วนหัว HTTP อื่น ๆ เพื่อสื่อสารข้อมูลอื่น ๆ:

```ruby
head :created, location: photo_path(@photo)
```

ซึ่งจะสร้าง:

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

การสร้างเลเอาท์
-------------------

เมื่อ Rails แสดงมุมมองเป็นการตอบสนอง มันทำโดยการรวมมุมมองกับเลเอาท์ปัจจุบันโดยใช้กฎการค้นหาเลเอาท์ปัจจุบันที่ถูกพูดถึงในส่วนที่แล้วของคู่มือนี้ ภายในเลเอาท์คุณสามารถเข้าถึงเครื่องมือสามอย่างสำหรับการรวมผลลัพธ์ที่แตกต่างกันเพื่อสร้างการตอบสนองโดยรวม:
* แท็กทรัพยากร
* `yield` และ [`content_for`][]
* ส่วนประกอบ


### ตัวช่วยแท็กทรัพยากร

ตัวช่วยแท็กทรัพยากรให้เมธอดสำหรับสร้าง HTML ที่เชื่อมโยงวิวไปยังฟีด จาวาสคริปต์ สไตล์ชีต รูปภาพ วิดีโอ และเสียง มีตัวช่วยแท็กทรัพยากรทั้งหมด 6 ตัวใช้ได้ใน Rails:

* [`auto_discovery_link_tag`][]
* [`javascript_include_tag`][]
* [`stylesheet_link_tag`][]
* [`image_tag`][]
* [`video_tag`][]
* [`audio_tag`][]

คุณสามารถใช้แท็กเหล่านี้ในเลเอาท์หรือวิวอื่น ๆ แม้ว่า `auto_discovery_link_tag`, `javascript_include_tag`, และ `stylesheet_link_tag` จะใช้งานอย่างแพร่หลายในส่วน `<head>` ของเลเอาท์

คำเตือน: ตัวช่วยแท็กทรัพยากรไม่ตรวจสอบความมีอยู่ของทรัพยากรในตำแหน่งที่ระบุ; มันเพียงแค่สมมุติว่าคุณรู้ว่าคุณกำลังทำอะไรและสร้างลิงก์


#### เชื่อมโยงไปยังฟีดด้วย `auto_discovery_link_tag`

ตัวช่วย [`auto_discovery_link_tag`][] สร้าง HTML ที่เบราว์เซอร์และอ่านเฟดสามารถใช้เพื่อตรวจหาการมีอยู่ของฟีด RSS, Atom หรือ JSON มันรับประเภทของลิงก์ (`:rss`, `:atom`, หรือ `:json`), แฮชของตัวเลือกที่ถูกส่งผ่านไปยัง url_for, และแฮชของตัวเลือกสำหรับแท็ก:

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS Feed"}) %>
```

มีตัวเลือกแท็ก 3 ตัวสำหรับ `auto_discovery_link_tag`:

* `:rel` ระบุค่า `rel` ในลิงก์ ค่าเริ่มต้นคือ "alternate"
* `:type` ระบุประเภท MIME แบบชัดเจน Rails จะสร้างประเภท MIME ที่เหมาะสมโดยอัตโนมัติ
* `:title` ระบุชื่อของลิงก์ ค่าเริ่มต้นคือค่า `:type` ตัวพิมพ์ใหญ่ เช่น "ATOM" หรือ "RSS"

#### เชื่อมโยงไปยังไฟล์จาวาสคริปต์ด้วย `javascript_include_tag`

ตัวช่วย [`javascript_include_tag`][] ส่งคืนแท็ก HTML `<script>` สำหรับแต่ละแหล่งที่ให้

หากคุณใช้ Rails พร้อมกับ [Asset Pipeline](asset_pipeline.html) ที่เปิดใช้งาน ตัวช่วยนี้จะสร้างลิงก์ไปยัง `/assets/javascripts/` แทนที่จะใช้ `public/javascripts` ที่ใช้ในเวอร์ชันก่อนหน้าของ Rails ลิงก์นี้จะถูกบริการโดย asset pipeline

ไฟล์จาวาสคริปต์ภายในแอปพลิเคชัน Rails หรือเอนจิน Rails จะอยู่ในหนึ่งในสามตำแหน่ง: `app/assets`, `lib/assets` หรือ `vendor/assets` สถานที่เหล่านี้อธิบายอย่างละเอียดในส่วน [Asset Organization ในเอกสาร Asset Pipeline Guide](asset_pipeline.html#asset-organization)

คุณสามารถระบุเส้นทางเต็มที่เกี่ยวข้องกับรากเอกสาร หรือ URL หากคุณต้องการ ตัวอย่างเช่นเชื่อมโยงไปยังไฟล์จาวาสคริปต์ที่อยู่ในไดเรกทอรีที่ชื่อ `javascripts` ภายในหนึ่งใน `app/assets`, `lib/assets` หรือ `vendor/assets` คุณจะทำดังนี้:

```erb
<%= javascript_include_tag "main" %>
```

Rails จะแสดงแท็ก `script` เช่นนี้:

```html
<script src='/assets/main.js'></script>
```

คำขอไปยังทรัพยากรนี้จะถูกบริการโดย Sprockets gem

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

#### เชื่อมโยงไปยังไฟล์ CSS ด้วย `stylesheet_link_tag`

ตัวช่วย [`stylesheet_link_tag`][] ส่งคืนแท็ก HTML `<link>` สำหรับแต่ละแหล่งที่ให้

หากคุณใช้ Rails พร้อมกับ "Asset Pipeline" ที่เปิดใช้งาน ตัวช่วยนี้จะสร้างลิงก์ไปยัง `/assets/stylesheets/` ลิงก์นี้จะถูกประมวลผ่าน Sprockets gem ไฟล์สไตล์ชีตสามารถเก็บไว้ในหนึ่งในสามตำแหน่ง: `app/assets`, `lib/assets`, หรือ `vendor/assets`

คุณสามารถระบุเส้นทางเต็มที่เกี่ยวข้องกับรากเอกสาร หรือ URL ตัวอย่างเช่นเชื่อมโยงไปยังไฟล์สไตล์ชีตที่อยู่ในไดเรกทอรีที่ชื่อ `stylesheets` ภายในหนึ่งใน `app/assets`, `lib/assets`, หรือ `vendor/assets` คุณจะทำดังนี้:

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

ตัวช่วย [`image_tag`][] สร้างแท็ก HTML `<img />` สำหรับไฟล์ที่ระบุ โดยค่าเริ่มต้นไฟล์จะถูกโหลดจาก `public/images` 

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

คุณสามารถระบุข้อความทดแทนสำหรับรูปภาพที่จะใช้หากผู้ใช้ปิดรูปภาพในเบราว์เซอร์ของพวกเขา หากคุณไม่ระบุข้อความทดแทนโดยชัดเจน มันจะเป็นค่าเริ่มต้นเป็นชื่อไฟล์ของไฟล์ โดยทำให้เป็นตัวพิมพ์ใหญ่และไม่มีนามสกุล ตัวอย่างเช่น แท็กรูปภาพสองอันนี้จะส่งคืนรหัสเดียวกัน:

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

คุณยังสามารถระบุแท็กขนาดพิเศษในรูปแบบ "{ความกว้าง}x{ความสูง}":

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

นอกจากแท็กพิเศษด้านบนคุณยังสามารถระบุแฮชสุดท้ายของตัวเลือก HTML มาตรฐาน เช่น `:class`, `:id`, หรือ `:name`:

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### การเชื่อมโยงไปยังวิดีโอด้วย `video_tag`

ตัวช่วย [`video_tag`][] สร้างแท็ก HTML5 `<video>` สำหรับไฟล์ที่ระบุ โดยค่าเริ่มต้นไฟล์จะถูกโหลดจาก `public/videos`

```erb
<%= video_tag "movie.ogg" %>
```

จะสร้าง

```erb
<video src="/videos/movie.ogg" />
```

เช่นเดียวกับ `image_tag` คุณสามารถระบุเส้นทางเป็นแบบสัมพันธ์หรือแบบสัมพันธ์กับไดเรกทอรี `public/videos` นอกจากนี้คุณยังสามารถระบุตัวเลือก `size: "#{ความกว้าง}x#{ความสูง}"` เหมือนกับ `image_tag` แท็กวิดีโอยังสามารถมีตัวเลือก HTML อื่น ๆ ที่ระบุได้ที่สุด (`id`, `class` เป็นต้น)

แท็กวิดีโอยังรองรับตัวเลือก HTML ทั้งหมดของ `<video>` ผ่านแฮชตัวเลือก HTML รวมถึง:

* `poster: "image_name.png"` ให้รูปภาพแทนวิดีโอก่อนที่จะเริ่มเล่น
* `autoplay: true` เริ่มเล่นวิดีโอเมื่อโหลดหน้าเว็บ
* `loop: true` วนวิดีโอเมื่อเล่นจนถึงจุดสิ้นสุด
* `controls: true` ให้ควบคุมที่จัดหาให้โดยเบราว์เซอร์สำหรับผู้ใช้เพื่อปรับแต่งวิดีโอ
* `autobuffer: true` วิดีโอจะโหลดไฟล์สำหรับผู้ใช้เมื่อโหลดหน้าเว็บ

คุณยังสามารถระบุวิดีโอหลายรายการที่จะเล่นได้โดยการส่งอาร์เรย์ของวิดีโอไปยัง `video_tag`:

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

จะสร้าง:

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### การเชื่อมโยงไปยังไฟล์เสียงด้วย `audio_tag`

ตัวช่วย [`audio_tag`][] สร้างแท็ก HTML5 `<audio>` สำหรับไฟล์ที่ระบุ โดยค่าเริ่มต้นไฟล์จะถูกโหลดจาก `public/audios`

```erb
<%= audio_tag "music.mp3" %>
```

คุณสามารถระบุเส้นทางไปยังไฟล์เสียงได้ถ้าคุณต้องการ:

```erb
<%= audio_tag "music/first_song.mp3" %>
```

คุณยังสามารถระบุแฮชของตัวเลือกเพิ่มเติม เช่น `:id`, `:class` เป็นต้น

เช่นเดียวกับ `video_tag`, `audio_tag` มีตัวเลือกพิเศษ:

* `autoplay: true` เริ่มเล่นเสียงเมื่อโหลดหน้าเว็บ
* `controls: true` ให้ควบคุมที่จัดหาให้โดยเบราว์เซอร์สำหรับผู้ใช้เพื่อปรับแต่งเสียง
* `autobuffer: true` เสียงจะโหลดไฟล์สำหรับผู้ใช้เมื่อโหลดหน้าเว็บ

### เข้าใจ `yield`

ภายใต้บริบทของเลเอาท์ `yield` ระบุส่วนที่เนื้อหาจากมุมมองควรถูกแทรก วิธีง่ายที่สุดในการใช้งานนี้คือการมี `yield` เดียว ซึ่งเนื้อหาทั้งหมดของมุมมองที่กำลังถูกแสดงอยู่จะถูกแทรก:

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

คุณยังสามารถสร้างเลเอาท์ที่มีส่วนที่เปิดให้ใช้งานหลายส่วนได้:

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
ส่วนหลักของมุมมองจะถูกแสดงผลใน `yield` ที่ไม่มีชื่อ ในการแสดงเนื้อหาใน `yield` ที่มีชื่อ คุณสามารถใช้เมธอด `content_for` 

### การใช้เมธอด `content_for`

เมธอด [`content_for`][] ช่วยให้คุณสามารถแทรกเนื้อหาลงในบล็อก `yield` ที่มีชื่อในเลเอาท์ของคุณได้ ตัวอย่างเช่น มุมมองนี้จะทำงานกับเลเอาท์ที่คุณเพิ่งเห็น:

```html+erb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

ผลลัพธ์จากการแสดงหน้านี้ลงในเลเอาท์ที่กำหนดจะเป็น HTML ดังนี้:

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

เมธอด `content_for` มีประโยชน์มากเมื่อเลเอาท์ของคุณมีส่วนที่แตกต่างกันเช่น แถบข้างและส่วนท้ายที่ควรได้รับบล็อกเนื้อหาของตัวเอง นอกจากนี้ยังมีประโยชน์ในการแทรกแท็กที่โหลดไฟล์ JavaScript หรือ CSS ที่เฉพาะหน้าลงในส่วนหัวของเลเอาท์ที่มีลักษณะทั่วไป

### การใช้ Partial

Partial templates - ที่เรียกว่า "partials" - เป็นอุปกรณ์อีกอย่างที่ช่วยให้กระบวนการแสดงผลแบ่งออกเป็นชิ้นย่อยที่สามารถจัดการได้ง่ายขึ้น ด้วย partial คุณสามารถย้ายรหัสสำหรับการแสดงผลส่วนหนึ่งของการตอบสนองไปยังไฟล์ของตัวเอง

#### การตั้งชื่อ Partial

ในการแสดงผล partial เป็นส่วนหนึ่งของมุมมอง คุณใช้เมธอด [`render`][view.render] ภายในมุมมอง:

```html+erb
<%= render "menu" %>
```

นี้จะแสดงผลไฟล์ที่ชื่อ `_menu.html.erb` ที่จุดนั้นภายในมุมมองที่กำลังแสดงผล โปรดทราบว่ามีอักขระขึ้นต้นด้วยเครื่องหมายขีดเส้นใต้: partial มีชื่อที่ขึ้นต้นด้วยเครื่องหมายขีดเส้นใต้เพื่อแยกจากมุมมองปกติ แม้ว่าจะถูกอ้างอิงโดยไม่มีเครื่องหมายขีดเส้นใต้ สิ่งนี้ยังคงเป็นจริงเมื่อคุณดึง partial จากโฟลเดอร์อื่น:

```html+erb
<%= render "shared/menu" %>
```

รหัสนี้จะดึง partial จาก `app/views/shared/_menu.html.erb`


#### การใช้ Partial เพื่อบูรณาการมุมมอง

วิธีหนึ่งในการใช้ partial คือที่จะใช้เป็นเทียบเท่ากับ subroutine: เป็นวิธีในการย้ายรายละเอียดออกจากมุมมองเพื่อให้คุณสามารถเข้าใจว่าอะไรกำลังเกิดขึ้นได้ง่ายขึ้น ตัวอย่างเช่น คุณอาจมีมุมมองที่มีลักษณะดังนี้:

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

ที่นี่ partial `_ad_banner.html.erb` และ `_footer.html.erb` อาจมีเนื้อหาที่ใช้ร่วมกันในหลายหน้าของแอปพลิเคชันของคุณ คุณไม่จำเป็นต้องเห็นรายละเอียดของส่วนเหล่านี้เมื่อคุณกำลังสนใจในหน้าที่เฉพาะเจาะจง

เหมือนกับที่เห็นในส่วนก่อนหน้าของเอกสารนี้ `yield` เป็นเครื่องมือที่มีประสิทธิภาพมากในการทำความสะอาดเลเอาท์ของคุณ โดยจำไว้ว่าเป็นรูปแบบของ Ruby ที่สมบูรณ์ ดังนั้นคุณสามารถใช้ได้เกือบทุกที่ ตัวอย่างเช่น เราสามารถใช้เพื่อ DRY up การกำหนดเลเอาท์ฟอร์มสำหรับทรัพยากรที่คล้ายกันหลายรายการ:

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
      <h1>Search form:</h1>
      <fieldset>
        <%= yield form %>
      </fieldset>
      <p>
        <%= form.submit "Search" %>
      </p>
    <% end %>
    ```

เคล็ดลับ: สำหรับเนื้อหาที่ใช้ร่วมกันในทุกหน้าของแอปพลิเคชันของคุณ คุณสามารถใช้ partial โดยตรงจากเลเอาท์

#### Partial Layouts

Partial สามารถใช้ไฟล์เลเอาท์ของตัวเองเช่นเดียวกับมุมมองที่ใช้เลเอาท์ได้ ตัวอย่างเช่น คุณอาจเรียกใช้ partial ดังนี้:

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

นี้จะค้นหา partial ที่ชื่อ `_link_area.html.erb` และแสดงผลโดยใช้เลเอาท์ `_graybar.html.erb` โปรดทราบว่าเลเอาท์สำหรับ partial จะตามหลักการตั้งชื่อด้วยขีดเส้นใต้ดังเดิมเช่นเดียวกับ partial ปกติและจัดวางในโฟลเดอร์เดียวกับ partial ที่เกี่ยวข้อง (ไม่ในโฟลเดอร์ `layouts` หลัก)
โปรดทราบว่าการระบุ `:partial` โดยชัดเจนจำเป็นต้องทำเมื่อส่งตัวเลือกเพิ่มเติม เช่น `:layout` 

#### การส่งตัวแปรท้องถิ่น

คุณยังสามารถส่งตัวแปรท้องถิ่นเข้าไปใน partial เพื่อทำให้มีความสามารถและยืดหยุ่นมากขึ้น ตัวอย่างเช่น คุณสามารถใช้เทคนิคนี้เพื่อลดการทำซ้ำระหว่างหน้าใหม่และหน้าแก้ไข โดยยังคงเนื้อหาที่แตกต่างกันเล็กน้อย:

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

แม้ว่า partial เดียวกันจะถูกแสดงในทั้งสองวิว แต่ Action View's submit helper จะคืนค่า "สร้างโซน" สำหรับการกระทำใหม่และ "อัปเดตโซน" สำหรับการแก้ไข

ในการส่งตัวแปรท้องถิ่นไปยัง partial ในกรณีที่เฉพาะเท่านั้น ให้ใช้ `local_assigns`

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

นี่คือวิธีการใช้ partial โดยไม่ต้องประกาศตัวแปรท้องถิ่นทั้งหมด

ทุก partial ยังมีตัวแปรท้องถิ่นที่มีชื่อเดียวกับ partial (ไม่รวมเครื่องหมายขีดเส้นบน) คุณสามารถส่งวัตถุเข้าไปในตัวแปรท้องถิ่นนี้ผ่านตัวเลือก `:object`:

```erb
<%= render partial: "customer", object: @new_customer %>
```

ภายใน partial `customer` ตัวแปร `customer` จะอ้างอิงถึง `@new_customer` จากวิวหลัก

หากคุณมีอินสแตนซ์ของโมเดลที่จะแสดงใน partial คุณสามารถใช้ไวยากรณ์ย่อสั้นได้:

```erb
<%= render @customer %>
```

สมมติว่าตัวแปรอินสแตนซ์ `@customer` มีอินสแตนซ์ของโมเดล `Customer` การใช้งานนี้จะใช้ `_customer.html.erb` ในการแสดงและจะส่งตัวแปรท้องถิ่น `customer` เข้าไปใน partial ซึ่งจะอ้างอิงถึงตัวแปรอินสแตนซ์ `@customer` ในวิวหลัก

#### การแสดงคอลเลกชัน

Partial มีประโยชน์มากในการแสดงคอลเลกชัน โดยเมื่อคุณส่งคอลเลกชันไปยัง partial ผ่านตัวเลือก `:collection` partial จะถูกแทรกเพียงครั้งเดียวสำหรับแต่ละสมาชิกในคอลเลกชัน:

* `index.html.erb`

    ```html+erb
    <h1>ผลิตภัณฑ์</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>ชื่อผลิตภัณฑ์: <%= product.name %></p>
    ```

เมื่อ partial ถูกเรียกด้วยคอลเลกชันที่มีชื่อพหูพจน์ ตัวอย่างเช่น สมาชิกแต่ละตัวของ partial สามารถเข้าถึงสมาชิกของคอลเลกชันที่กำลังแสดงผ่านตัวแปรที่มีชื่อตาม partial ในกรณีนี้ partial คือ `_product` และภายใน partial `_product` คุณสามารถอ้างอิงถึง `product` เพื่อรับอินสแตนซ์ที่กำลังถูกแสดง

ยังมีวิธีย่อสำหรับนี้ด้วย สมมติ `@products` เป็นคอลเลกชันของอินสแตนซ์ `Product` คุณสามารถเขียนแบบนี้ใน `index.html.erb` เพื่อให้ได้ผลลัพธ์เดียวกัน:

```html+erb
<h1>ผลิตภัณฑ์</h1>
<%= render @products %>
```

Rails จะกำหนดชื่อของ partial ที่จะใช้โดยดูชื่อโมเดลในคอลเลกชัน ในความเป็นจริงคุณสามารถสร้างคอลเลกชันที่แตกต่างกันและแสดงผลได้ในวิธีนี้ และ Rails จะเลือก partial ที่เหมาะสมสำหรับแต่ละสมาชิกของคอลเลกชัน:

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

ในกรณีนี้ Rails จะใช้ partial ของลูกค้าหรือพนักงานตามที่เหมาะสมสำหรับแต่ละสมาชิกของคอลเลกชัน

ในกรณีที่คอลเลกชันว่างเปล่า `render` จะคืนค่า nil ดังนั้นควรง่ายต่อการให้เนื้อหาทดแทน
```html+erb
<h1>สินค้า</h1>
<%= render(@products) || "ไม่มีสินค้าที่มีอยู่" %>
```

#### ตัวแปรท้องถิ่น

ในการใช้ชื่อตัวแปรท้องถิ่นที่กำหนดเองใน partial ให้ระบุตัวเลือก `:as` ในการเรียกใช้ partial:

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

ด้วยการเปลี่ยนแปลงนี้คุณสามารถเข้าถึงสำเนาของคอลเลกชัน `@products` เป็นตัวแปรท้องถิ่น `item` ภายใน partial ได้

คุณยังสามารถส่งตัวแปรท้องถิ่นอื่น ๆ เข้าไปใน partial ที่คุณกำลังเรียกใช้ด้วยตัวเลือก `locals: {}`:

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "หน้าสินค้า"} %>
```

ในกรณีนี้ partial จะสามารถเข้าถึงตัวแปรท้องถิ่น `title` ที่มีค่าเป็น "หน้าสินค้า" ได้

#### ตัวแปรนับ

Rails ยังให้ตัวแปรนับที่ใช้ใน partial ที่เรียกใช้โดยคอลเลกชัน ตัวแปรนี้มีชื่อตามชื่อของ partial ตามด้วย `_counter` ตัวอย่างเช่น เมื่อเรียกใช้คอลเลกชัน `@products` partial `_product.html.erb` สามารถเข้าถึงตัวแปร `product_counter` ได้ ตัวแปรนับจะเป็นดัชนีของจำนวนครั้งที่ partial ถูกเรียกใช้ในมุมมองที่ห่อหุ้ม โดยเริ่มต้นด้วยค่า `0` ในการเรนเดอร์ครั้งแรก

```erb
# index.html.erb
<%= render partial: "product", collection: @products %>
```

```erb
# _product.html.erb
<%= product_counter %> # 0 สำหรับสินค้าแรก, 1 สำหรับสินค้าที่สอง...
```

สิ่งเดียวกันนี้ยังสามารถทำงานได้เมื่อเปลี่ยนชื่อ partial โดยใช้ตัวเลือก `as:` ดังนั้นหากคุณใช้ `as: :item` ตัวแปรนับจะเป็น `item_counter`

#### ต้นแบบ Spacer

คุณยังสามารถระบุ partial ที่สองที่จะถูกเรนเดอร์ระหว่างส่วนประกอบหลักๆ โดยใช้ตัวเลือก `:spacer_template`:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails จะเรนเดอร์ partial `_product_ruler` (โดยไม่มีข้อมูลที่ส่งผ่าน) ระหว่างแต่ละคู่ของ partial `_product`

#### โครงร่าง Partial ของคอลเลกชัน

เมื่อเรียกใช้คอลเลกชัน คุณยังสามารถใช้ตัวเลือก `:layout`:

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

โครงร่างจะถูกเรนเดอร์พร้อมกับ partial สำหรับแต่ละรายการในคอลเลกชัน วัตถุปัจจุบันและตัวแปร object_counter จะสามารถใช้ได้ในโครงร่างเช่นเดียวกับใน partial

### การใช้งานโครงร่างซ้อน

คุณอาจพบว่าแอปพลิเคชันของคุณต้องการโครงร่างที่แตกต่างเล็กน้อยจากโครงร่างแอปพลิเคชันปกติเพื่อรองรับคอนโทรลเลอร์หนึ่งอันเป็นพิเศษ แทนที่จะทำซ้ำโครงร่างหลักและแก้ไข คุณสามารถทำได้โดยใช้โครงร่างซ้อน (ที่บางครั้งเรียกว่า sub-templates) ตัวอย่างเช่น:

สมมุติว่าคุณมีโครงร่าง `ApplicationController` ต่อไปนี้:

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "Page Title" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">รายการเมนูด้านบนที่นี่</div>
      <div id="menu">รายการเมนูที่นี่</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

บนหน้าที่สร้างขึ้นโดย `NewsController` คุณต้องการซ่อนเมนูด้านบนและเพิ่มเมนูด้านขวา:

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">รายการเมนูด้านขวาที่นี่</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

เพียงเท่านี้ มุมมองข่าวจะใช้โครงร่างใหม่ที่ซ่อนเมนูด้านบนและเพิ่มเมนูด้านขวาใน div "content"

มีหลายวิธีในการให้ผลลัพธ์ที่คล้ายกันด้วยรูปแบบการซับเทมเพลตย่อยที่แตกต่างกัน โปรดทราบว่าไม่มีขีดจำกัดในระดับการซ้อน คุณสามารถใช้เมธอด `ActionView::render` ผ่าน `render template: 'layouts/news'` เพื่อใช้โครงร่างใหม่ที่ซ่อนเมนูข่าว หากคุณแน่ใจว่าคุณจะไม่ใช้โครงร่างย่อยของ `News` คุณสามารถแทนที่ `content_for?(:news_content) ? yield(:news_content) : yield` ด้วย `yield` เท่านั้น
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
