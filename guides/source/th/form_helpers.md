**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 975163c53746728404fb3a3658fbd0f6
Action View Form Helpers
========================

ฟอร์มในแอปพลิเคชันเว็บเป็นอินเทอร์เฟซที่สำคัญสำหรับการรับข้อมูลจากผู้ใช้ อย่างไรก็ตาม การเขียนและบำรุงรักษามาร์กอัปสิเซชันของฟอร์มสามารถเป็นงานที่น่าเบื่อและยากเนื่องจากความจำเป็นในการจัดการการตั้งชื่อควบคุมฟอร์มและแอตทริบิวต์ต่างๆ แต่ Rails ก็ได้กำจัดความซับซ้อนนี้ด้วยการ提供เฮลเปอร์ของวิวสำหรับการสร้างมาร์กอัปฟอร์ม อย่างไรก็ตาม เนื่องจากเฮลเปอร์เหล่านี้มีการใช้งานที่แตกต่างกัน นักพัฒนาจำเป็นต้องทราบความแตกต่างระหว่างเมธอดช่วยเหลือก่อนที่จะนำมาใช้งาน

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีการสร้างฟอร์มค้นหาและฟอร์มที่คล้ายกันที่ไม่แสดงตัวแทนของโมเดลใดๆ ในแอปพลิเคชันของคุณ
* วิธีการสร้างฟอร์มที่เกี่ยวข้องกับโมเดลสำหรับการสร้างและแก้ไขระเบียนฐานข้อมูลที่เฉพาะเจาะจง
* วิธีการสร้างกล่องเลือกจากข้อมูลหลายประเภท
* วิธีการใช้เครื่องมือวันที่และเวลาที่ Rails มีให้
* สิ่งที่ทำให้ฟอร์มอัปโหลดไฟล์แตกต่างกัน
* วิธีการโพสต์ฟอร์มไปยังทรัพยากรภายนอกและระบุการตั้งค่า `authenticity_token`
* วิธีการสร้างฟอร์มที่ซับซ้อน

--------------------------------------------------------------------------------

หมายเหตุ: เอกสารนี้ไม่ได้มีไว้เพื่อเป็นเอกสารเต็มรูปแบบของเครื่องมือช่วยสร้างฟอร์มที่มีอยู่และอาร์กิวเมนต์ของพวกเขา กรุณาเยี่ยมชม [เอกสาร API ของ Rails](https://api.rubyonrails.org/classes/ActionView/Helpers.html) เพื่ออ้างอิงเต็มรูปแบบของเครื่องมือช่วยสร้างทั้งหมดที่มีอยู่

การจัดการกับฟอร์มพื้นฐาน
------------------------

เฮลเปอร์ฟอร์มหลักคือ [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)。

```erb
<%= form_with do |form| %>
  เนื้อหาฟอร์ม
<% end %>
```

เมื่อเรียกใช้โดยไม่มีอาร์กิวเมนต์เช่นนี้ จะสร้างแท็กฟอร์มซึ่งเมื่อส่งข้อมูลจะ POST ไปยังหน้าปัจจุบัน ตัวอย่างเช่น ถ้าหน้าปัจจุบันเป็นหน้าหลัก  HTML ที่สร้างจะมีลักษณะดังนี้:

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  เนื้อหาฟอร์ม
</form>
```

คุณจะเห็นว่า HTML มีอิลิเมนต์ `input` ที่มีประเภท `hidden` นี้ อิลิเมนต์ `input` นี้สำคัญเพราะฟอร์มที่ไม่ใช่ GET จะไม่สามารถส่งข้อมูลได้สำเร็จโดยไม่มีอันตราย
อิลิเมนต์ `input` ที่ซ่อนอยู่ที่มีชื่อ `authenticity_token` เป็นคุณสมบัติความปลอดภัยของ Rails ที่เรียกว่า **การป้องกันการโจมตีข้ามไซต์โดยการขอข้อมูล (cross-site request forgery protection)** และเครื่องมือช่วยสร้างฟอร์มจะสร้างขึ้นสำหรับฟอร์มที่ไม่ใช่ GET ทุกฟอร์ม (ให้แน่ใจว่าคุณเปิดใช้คุณสมบัติความปลอดภัยนี้) คุณสามารถอ่านเพิ่มเติมเกี่ยวกับนี้ได้ใน[เอกสารการรักษาความปลอดภัยของแอปพลิเคชัน Rails](security.html#cross-site-request-forgery-csrf)

### ฟอร์มค้นหาทั่วไป

หนึ่งในฟอร์มที่พื้นฐานที่คุณเห็นบ่อยในเว็บคือฟอร์มค้นหา ฟอร์มนี้ประกอบด้วย:

* อิลิเมนต์ฟอร์มที่มีเมธอด "GET",
* ป้ายกำกับสำหรับอินพุต,
* อินพุตข้อความ, และ
* อินพุตส่ง

เพื่อสร้างฟอร์มนี้คุณจะใช้ `form_with` และออบเจกต์ฟอร์มที่มันสร้างขึ้น ดังนี้:

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "ค้นหา:" %>
  <%= form.text_field :query %>
  <%= form.submit "ค้นหา" %>
<% end %>
```

นี้จะสร้าง HTML ดังนี้:

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">ค้นหา:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="ค้นหา" data-disable-with="ค้นหา" />
</form>
```

เคล็ดลับ: การส่ง `url: my_specified_path` ไปยัง `form_with` บอกให้ฟอร์มทราบว่าจะส่งคำขอไปที่ไหน อย่างไรก็ตาม ตามที่อธิบายด้านล่างคุณยังสามารถส่งออบเจกต์ Active Record ไปยังฟอร์มได้

เคล็ดลับ: สำหรับทุกอินพุตฟอร์ม จะสร้างอิลิเมนต์ ID จากชื่อของมัน (`"query"` ในตัวอย่างด้านบน) อิลิเมนต์เหล่านี้สามารถมีประโยชน์มากสำหรับการจัดรูปแบบ CSS หรือการจัดการควบคุมฟอร์มด้วย JavaScript
สำคัญ: ใช้ "GET" เป็นวิธีการสำหรับฟอร์มการค้นหา นี้ช่วยให้ผู้ใช้สามารถบุ๊กมาร์กการค้นหาที่เฉพาะเจาะจงและกลับไปยังนั้นได้ โดยทั่วไป Rails ส่งเสริมให้คุณใช้ HTTP verb ที่ถูกต้องสำหรับการดำเนินการ

### ช่วยเหลือในการสร้างองค์ประกอบแบบฟอร์ม

ออบเจ็กต์ฟอร์มบิลเดอร์ที่ถูกส่งออกโดย `form_with` มีเมธอดช่วยเหลือจำนวนมากในการสร้างองค์ประกอบแบบฟอร์ม เช่น ช่องข้อความ, ช่องเลือก, และปุ่มวิทยุ พารามิเตอร์แรกสุดของเมทอดเหล่านี้เป็นชื่อของอินพุตเสมอ เมื่อฟอร์มถูกส่ง, ชื่อจะถูกส่งพร้อมกับข้อมูลฟอร์ม และจะถูกส่งไปยัง `params` ในคอนโทรลเลอร์พร้อมกับค่าที่ผู้ใช้ป้อนสำหรับฟิลด์นั้น ตัวอย่างเช่น หากฟอร์มมี `<%= form.text_field :query %>` แล้วคุณจะสามารถรับค่าของฟิลด์นี้ในคอนโทรลเลอร์ด้วย `params[:query]`

เมื่อตั้งชื่ออินพุต Rails ใช้กฎเกณฑ์บางอย่างที่ทำให้เป็นไปได้ที่จะส่งพารามิเตอร์ด้วยค่าที่ไม่ใช่สกาล เช่น อาร์เรย์หรือแฮช ซึ่งจะสามารถเข้าถึงได้ใน `params` คุณสามารถอ่านเพิ่มเติมเกี่ยวกับมันได้ในส่วน [เข้าใจกฎเกณฑ์การตั้งชื่อพารามิเตอร์](#เข้าใจกฎเกณฑ์การตั้งชื่อพารามิเตอร์) ของเอกสารนี้ สำหรับรายละเอียดเกี่ยวกับการใช้เมทอดช่วยเหล่านี้โปรดอ้างอิงที่ [เอกสาร API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)

#### ช่องเลือก

ช่องเลือกเป็นตัวควบคุมฟอร์มที่ให้ผู้ใช้เลือกตัวเลือกที่พวกเขาสามารถเปิดหรือปิดได้:

```erb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "ฉันเป็นเจ้าของสุนัข" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "ฉันเป็นเจ้าของแมว" %>
```

สร้างดังนี้:

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">ฉันเป็นเจ้าของสุนัข</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">ฉันเป็นเจ้าของแมว</label>
```

พารามิเตอร์แรกของ [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) คือชื่อของอินพุต ค่าของช่องเลือก (ค่าที่จะปรากฏใน `params`) สามารถระบุได้ตามต้องการโดยใช้พารามิเตอร์ที่สามและที่สี่ ดูเอกสาร API สำหรับรายละเอียด

#### ปุ่มวิทยุ

ปุ่มวิทยุ ในขณะที่คล้ายกับช่องเลือก คือตัวควบคุมที่ระบุชุดตัวเลือกที่เป็นสมาชิกของกันและกัน (เช่นผู้ใช้สามารถเลือกได้เพียงหนึ่ง):

```erb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "ฉันอายุต่ำกว่า 21 ปี" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "ฉันอายุมากกว่า 21 ปี" %>
```

ผลลัพธ์:

```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">ฉันอายุต่ำกว่า 21 ปี</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">ฉันอายุมากกว่า 21 ปี</label>
```

พารามิเตอร์ที่สองของ [`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) คือค่าของอินพุต เนื่องจากปุ่มวิทยุสองปุ่มเหล่านี้ใช้ชื่อเดียวกัน (`age`) ผู้ใช้จะสามารถเลือกได้เพียงหนึ่งในนั้นเท่านั้น และ `params[:age]` จะมีค่าเป็น "child" หรือ "adult"

หมายเหตุ: ใช้ป้ายชื่อสำหรับช่องเลือกและปุ่มวิทยุเสมอ พวกเขาเชื่อมโยงข้อความกับตัวเลือกที่เฉพาะเจาะจงและโดยการขยายพื้นที่ที่สามารถคลิกได้ ทำให้ผู้ใช้สามารถคลิกที่อินพุตได้ง่ายขึ้น

### ช่วยเหลืออื่น ๆ ที่น่าสนใจ

องค์ประกอบฟอร์มอื่น ๆ ที่น่าพูดถึงคือพื้นที่ข้อความ, ฟิลด์ที่ซ่อนอยู่, ฟิลด์รหัสผ่าน, ฟิลด์ตัวเลข, ฟิลด์วันที่และเวลา และอื่น ๆ อีกมากมาย:

```erb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```
ผลลัพธ์:

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```

Input ที่ซ่อนไม่แสดงให้ผู้ใช้เห็น แต่จะเก็บข้อมูลเหมือนกับ input ที่ใส่ข้อความ ค่าภายใน input สามารถเปลี่ยนแปลงได้ด้วย JavaScript

สำคัญ: การค้นหา, เบอร์โทรศัพท์, วันที่, เวลา, สี, วันที่และเวลา, เดือน, สัปดาห์, URL, อีเมล, ตัวเลข และช่วงของ input เป็นควบคุม HTML5
หากคุณต้องการให้แอปของคุณมีประสบการณ์ที่สม่ำเสมอในเบราว์เซอร์เวอร์ชันเก่า คุณจะต้องใช้ HTML5 polyfill (ที่ CSS และ/หรือ JavaScript จัดหาให้)
มีการแนะนำหลายวิธีในการแก้ปัญหานี้ (https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills) แต่เครื่องมือยอดนิยมในขณะนี้คือ
Modernizr (https://modernizr.com/) ซึ่งให้วิธีง่ายๆในการเพิ่มฟังก์ชันตามการตรวจพบคุณลักษณะ HTML5

เคล็ดลับ: หากคุณกำลังใช้ input รหัสผ่าน (สำหรับวัตถุประสงค์ใดก็ตาม) คุณอาจต้องกำหนดค่าให้แอปของคุณป้องกันการบันทึกพารามิเตอร์เหล่านั้น คุณสามารถเรียนรู้เพิ่มเติมเกี่ยวกับนี้ได้ในคู่มือ [Securing Rails Applications](security.html#logging)

การจัดการกับวัตถุโมเดล
--------------------------

### การผูกฟอร์มกับวัตถุ

อาร์กิวเมนต์ `:model` ของ `form_with` ช่วยให้เราสามารถผูกวัตถุฟอร์มกับวัตถุโมเดลได้ นี้หมายความว่าฟอร์มจะถูกจำกัดไว้กับวัตถุโมเดลนั้น และฟิลด์ของฟอร์มจะถูกเติมค่าด้วยค่าจากวัตถุโมเดลนั้น

ตัวอย่างเช่น หากเรามีวัตถุโมเดล `@article` เช่น:

```ruby
@article = Article.find(42)
# => #<Article id: 42, title: "My Title", body: "My Body">
```

ฟอร์มต่อไปนี้:

```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

ผลลัพธ์:

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="My Title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    My Body
  </textarea>
  <input type="submit" name="commit" value="Update Article" data-disable-with="Update Article">
</form>
```

มีสิ่งที่ต้องสังเกตที่นี่:

* ค่า `action` ของฟอร์มถูกเติมอัตโนมัติด้วยค่าที่เหมาะสมสำหรับ `@article`
* ฟิลด์ของฟอร์มถูกเติมอัตโนมัติด้วยค่าที่เกี่ยวข้องจาก `@article`
* ชื่อฟิลด์ของฟอร์มถูกจำกัดด้วย `article[...]` นี้หมายความว่า `params[:article]` จะเป็นแฮชที่มีค่าของฟิลด์เหล่านี้ทั้งหมด คุณสามารถอ่านเพิ่มเติมเกี่ยวกับความสำคัญของชื่ออินพุตในบทที่ [Understanding Parameter Naming Conventions](#understanding-parameter-naming-conventions) ของคู่มือนี้
* ปุ่มส่งฟอร์มได้รับค่าข้อความที่เหมาะสมโดยอัตโนมัติ

เคล็ดลับ: ตามปกติ อินพุตของคุณจะสอดคล้องกับแอตทริบิวต์ของโมเดล อย่างไรก็ตาม ไม่จำเป็นต้องเป็นแบบนั้น! หากมีข้อมูลอื่นที่คุณต้องการ คุณสามารถรวมเข้ากับฟอร์มเหมือนกับแอตทริบิวต์และเข้าถึงได้ผ่าน `params[:article][:my_nifty_non_attribute_input]`

#### ตัวช่วย `fields_for`

ตัวช่วย [`fields_for`][] สร้างการผูกที่คล้ายกัน แต่ไม่ได้เรนเดอร์แท็ก `<form>` นี้สามารถใช้เพื่อเรนเดอร์ฟิลด์สำหรับวัตถุโมเดลเพิ่มเติมภายในฟอร์มเดียวกัน ตัวอย่างเช่น หากคุณมีโมเดล `Person` ที่เกี่ยวข้องกับโมเดล `ContactDetail` คุณสามารถสร้างฟอร์มเดียวสำหรับทั้งสองดังนี้:
```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

ซึ่งจะสร้างผลลัพธ์ดังต่อไปนี้:

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

วัตถุที่ถูกส่งกลับโดย `fields_for` เป็น form builder เช่นเดียวกับ form builder ที่ถูกส่งกลับโดย `form_with`


### การพึ่งพาการระบุระเบียน

โมเดล Article สามารถใช้งานได้โดยตรงกับผู้ใช้แอปพลิเคชัน ดังนั้น - ตามหลักการที่ดีที่สุดสำหรับการพัฒนาด้วย Rails - คุณควรประกาศให้เป็น **resource**:

```ruby
resources :articles
```

เคล็ดลับ: การประกาศ resource มีผลข้างเคียงหลายอย่าง ดูเพิ่มเติมเกี่ยวกับการตั้งค่าและการใช้งาน resource ได้ที่ [Rails Routing from the Outside In](routing.html#resource-routing-the-rails-default) guide

เมื่อจัดการกับทรัพยากร RESTful การเรียกใช้ `form_with` จะง่ายขึ้นอย่างมากถ้าคุณพึ่งพาการระบุระเบียน สั้นๆ ก็คือคุณสามารถส่ง instance ของโมเดลและให้ Rails คำนวณชื่อโมเดลและส่วนที่เหลือได้เอง ในทั้งสองตัวอย่างเหล่านี้ รูปแบบยาวและสั้นจะให้ผลลัพธ์เดียวกัน:

```ruby
## สร้างบทความใหม่
# รูปแบบยาว:
form_with(model: @article, url: articles_path)
# รูปแบบสั้น:
form_with(model: @article)

## แก้ไขบทความที่มีอยู่
# รูปแบบยาว:
form_with(model: @article, url: article_path(@article), method: "patch")
# รูปแบบสั้น:
form_with(model: @article)
```

สังเกตว่าการเรียกใช้ `form_with` ในรูปแบบสั้นจะสะดวกเช่นเดียวกันไม่ว่าระเบียนจะเป็นใหม่หรือเดิม การระบุระเบียนจะเฉลี่ยออกมาว่าเป็นระเบียนใหม่หรือไม่โดยการถาม `record.persisted?` นอกจากนี้ยังเลือกเส้นทางที่ถูกต้องสำหรับการส่งค่า และชื่อตามคลาสของวัตถุ

หากคุณมี [singular resource](routing.html#singular-resources) คุณจะต้องเรียกใช้ `resource` และ `resolve` เพื่อให้สามารถใช้งานกับ `form_with` ได้:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

คำเตือน: เมื่อคุณใช้ STI (single-table inheritance) กับโมเดลของคุณ คุณไม่สามารถพึ่งพาการระบุระเบียนในคลาสย่อยได้หากเฉพาะคลาสหลักของพวกเขาถูกประกาศเป็น resource เท่านั้น คุณจะต้องระบุ `:url` และ `:scope` (ชื่อโมเดล) โดยชัดเจน

#### การจัดการ Namespaces

หากคุณได้สร้างเส้นทางที่มีชื่อเรียก `form_with` มีวิธีย่อสะดวกสำหรับนั้นด้วย หากแอปพลิเคชันของคุณมี admin namespace แล้ว

```ruby
form_with model: [:admin, @article]
```

จะสร้างฟอร์มที่ส่งไปยัง `ArticlesController` ภายใน admin namespace (ส่งไปที่ `admin_article_path(@article)` ในกรณีของการอัปเดต) หากคุณมีหลายระดับของ namespacing รูปแบบจะคล้ายกัน:

```ruby
form_with model: [:admin, :management, @article]
```

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับระบบเส้นทางของ Rails และกฎเกณฑ์ที่เกี่ยวข้อง โปรดดูที่ [Rails Routing from the Outside In](routing.html) guide

### ฟอร์มที่ใช้วิธี PATCH, PUT, หรือ DELETE ทำงานอย่างไร?

เฟรมเวิร์กของ Rails สนับสนุนการออกแบบแอปพลิเคชันของคุณให้เป็น RESTful ซึ่งหมายความว่าคุณจะต้องทำ "PATCH", "PUT", และ "DELETE" ร้องขอ (นอกเหนือจาก "GET" และ "POST") อย่างไรก็ตาม บราวเซอร์ส่วนใหญ่ _ไม่รองรับ_ วิธีการอื่นๆ นอกจาก "GET" และ "POST" เมื่อเรื่องการส่งฟอร์ม

Rails จึงใช้วิธีการที่เหลือเหมือนกับ POST โดยใช้อินพุตที่ซ่อนอยู่ชื่อ `"_method"` ซึ่งถูกตั้งค่าให้สอดคล้องกับวิธีการที่ต้องการ:

```ruby
form_with(url: search_path, method: "patch")
```

Output:

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->
</form>
```

เมื่อแยกวิเคราะห์ข้อมูลที่ส่งผ่าน POST  Rails จะพิจารณาพารามิเตอร์พิเศษ `_method` และทำงานเสมือนว่าวิธี HTTP คือวิธีที่ระบุไว้ภายในนั้น ("PATCH" ในตัวอย่างนี้)

เมื่อแสดงฟอร์ม ปุ่มส่งข้อมูลสามารถแทนที่ค่าที่ระบุไว้ในแอตทริบิวต์ `method` ผ่านคีย์เวิร์ด `formmethod:`:

```erb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Delete", formmethod: :delete, data: { confirm: "Are you sure?" } %>
  <%= form.button "Update" %>
<% end %>
```

คล้ายกับองค์ประกอบ `<form>` ส่วนใหญ่ของเบราว์เซอร์ _ไม่รองรับ_ การแทนที่วิธีฟอร์มที่ระบุผ่าน [formmethod][] นอกเหนือจาก "GET" และ "POST"

Rails ทำงานรอบปัญหานี้โดยจำลองวิธีอื่นๆ ผ่าน POST ด้วยการผสาน [formmethod][] [value][button-value] และ [name][button-name] องค์ประกอบ:

```html
<form accept-charset="UTF-8" action="/posts/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->

  <button type="submit" formmethod="post" name="_method" value="delete" data-confirm="Are you sure?">Delete</button>
  <button type="submit" name="button">Update</button>
</form>
```


สร้างกล่องเลือกง่ายๆ
-----------------------------

กล่องเลือกใน HTML ต้องการการเขียนโค้ดมาก - หนึ่งองค์ประกอบ `<option>` สำหรับแต่ละตัวเลือกที่จะเลือก ดังนั้น Rails จึงมีเมธอดช่วยในการลดภาระนี้

ตัวอย่างเช่น สมมุติว่าเรามีรายการเมืองที่ผู้ใช้สามารถเลือกได้ เราสามารถใช้เมธอด [`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select) ได้ดังนี้:

```erb
<%= form.select :city, ["Berlin", "Chicago", "Madrid"] %>
```

Output:

```html
<select name="city" id="city">
  <option value="Berlin">Berlin</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```

เรายังสามารถกำหนดค่า `<option>` ที่แตกต่างจากตัวเลือก:

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
```

Output:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

ดังนั้นผู้ใช้จะเห็นชื่อเมืองเต็ม แต่ `params[:city]` จะเป็นหนึ่งใน `"BE"`, `"CHI"`, หรือ `"MD"`

สุดท้าย เราสามารถระบุตัวเลือกเริ่มต้นสำหรับกล่องเลือกด้วยอาร์กิวเมนต์ `:selected`:

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]], selected: "CHI" %>
```

Output:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

### กลุ่มตัวเลือก

ในบางกรณีเราอาจต้องการปรับปรุงประสบการณ์ของผู้ใช้โดยการจัดกลุ่มตัวเลือกที่เกี่ยวข้องกัน เราสามารถทำได้โดยส่ง `Hash` (หรือ `Array` ที่เปรียบเทียบได้) ไปยัง `select`:

```erb
<%= form.select :city,
      {
        "Europe" => [ ["Berlin", "BE"], ["Madrid", "MD"] ],
        "North America" => [ ["Chicago", "CHI"] ],
      },
      selected: "CHI" %>
```

Output:

```html
<select name="city" id="city">
  <optgroup label="Europe">
    <option value="BE">Berlin</option>
    <option value="MD">Madrid</option>
  </optgroup>
  <optgroup label="North America">
    <option value="CHI" selected="selected">Chicago</option>
  </optgroup>
</select>
```

### กล่องเลือกและออบเจกต์โมเดล

เช่นกับองค์ประกอบฟอร์มอื่น กล่องเลือกสามารถผูกกับแอตทริบิวต์ของโมเดลได้ เช่น ถ้าเรามีออบเจกต์โมเดล `@person` เช่น:

```ruby
@person = Person.new(city: "MD")
```

ฟอร์มต่อไปนี้:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
<% end %>
```

จะแสดงกล่องเลือกเช่นนี้:

```html
<select name="person[city]" id="person_city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD" selected="selected">Madrid</option>
</select>
```
โปรดทราบว่าตัวเลือกที่เหมาะสมถูกทำเครื่องหมาย `selected="selected"` โดยอัตโนมัติ โดยเนื่องจากกล่องเลือกนี้ถูกผูกกับโมเดลเราไม่จำเป็นต้องระบุอาร์กิวเมนต์ `:selected`!

### เลือกเขตเวลาและประเทศ

ในการใช้งานระบบการรองรับเขตเวลาใน Rails คุณต้องถามผู้ใช้ของคุณว่าเขตเวลาที่พวกเขาอยู่ในเขตใด การทำเช่นนั้นจะต้องการการสร้างตัวเลือกจากรายการของอ็อบเจ็กต์ [`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html) ที่กำหนดไว้ล่วงหน้า แต่คุณสามารถใช้เพียงแค่เมธอด [`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select) ที่มีการครอบห่ออยู่แล้ว:

```erb
<%= form.time_zone_select :time_zone %>
```

Rails _เคย_ มีเมธอด `country_select` สำหรับการเลือกประเทศ แต่นี้ถูกแยกออกเป็น [ปลั๊กอิน country_select](https://github.com/stefanpenner/country_select) แล้ว

การใช้ Date และ Time Form Helpers
--------------------------------

หากคุณไม่ต้องการใช้งานอินพุตวันที่และเวลาของ HTML5 Rails จะให้เครื่องมือช่วยแบบเลือกทางเลือกที่แสดงกล่องเลือกธรรมดา โดยเครื่องมือช่วยเหล่านี้จะแสดงกล่องเลือกสำหรับแต่ละส่วนของเวลา (เช่น ปี เดือน วัน เป็นต้น) ตัวอย่างเช่น หากเรามีออบเจ็กต์โมเดล `@person` เช่น:

```ruby
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

ฟอร์มต่อไปนี้:

```erb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

จะแสดงกล่องเลือกดังนี้:

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">January</option>
  <option value="2">February</option>
  <option value="3">March</option>
  <option value="4">April</option>
  <option value="5">May</option>
  <option value="6">June</option>
  <option value="7">July</option>
  <option value="8">August</option>
  <option value="9">September</option>
  <option value="10">October</option>
  <option value="11">November</option>
  <option value="12" selected="selected">December</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1</option>
  ...
  <option value="21" selected="selected">21</option>
  ...
  <option value="31">31</option>
</select>
```

โปรดทราบว่าเมื่อฟอร์มถูกส่ง จะไม่มีค่าเดี่ยวในแฮช `params` ที่มีวันที่เต็ม แต่จะมีค่าหลายค่าที่มีชื่อพิเศษเช่น `"birth_date(1i)"`  Active Record รู้วิธีรวมค่าที่มีชื่อพิเศษเหล่านี้เป็นวันที่หรือเวลาเต็ม โดยอิงตามประเภทที่ประกาศของแอตทริบิวต์ของโมเดล เราสามารถส่ง `params[:person]` ไปยังเมธอดเช่น `Person.new` หรือ `Person#update` เหมือนกับการใช้ฟอร์มที่ใช้ฟิลด์เดียวเพื่อแทนวันที่เต็ม

นอกจาก [`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select) เครื่องมือช่วย Rails ยังให้ [`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select) และ [`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select)

### เลือกกล่องสำหรับส่วนประกอบของเวลาแต่ละอัน

Rails ยังให้เครื่องมือช่วยในการแสดงกล่องเลือกสำหรับส่วนประกอบของเวลาแต่ละอัน: [`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year), [`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month), [`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day), [`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour), [`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute), และ [`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second) เครื่องมือช่วยเหล่านี้เป็นเมธอด "เปล่า" ซึ่งหมายความว่าไม่ได้เรียกใช้ในอินสแตนซ์ของฟอร์มบิลเดอร์ ตัวอย่างเช่น:

```erb
<%= select_year 1999, prefix: "party" %>
```

จะแสดงกล่องเลือกดังนี้:

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

สำหรับแต่ละเครื่องมือช่วยเหล่านี้ คุณสามารถระบุวันที่หรือเวลาเป็นวัตถุแทนตัวเลขเป็นค่าเริ่มต้น และส่วนประกอบของเวลาที่เหมาะสมจะถูกแยกออกและใช้งาน
```ruby
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```

```ruby
City.order(:name).map { |city| [city.name, city.id] }
# => [["เบอร์ลิน", 3], ["ชิคาโก", 1], ["มาดริด", 2]]
```

จากนั้นเราสามารถอนุญาตให้ผู้ใช้เลือกเมืองจากฐานข้อมูลด้วยแบบฟอร์มต่อไปนี้:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

หมายเหตุ: เมื่อแสดงผลฟิลด์สำหรับความสัมพันธ์ `belongs_to` คุณต้องระบุชื่อของคีย์ต่างประเทศ (`city_id` ในตัวอย่างด้านบน) แทนชื่อของความสัมพันธ์เอง

อย่างไรก็ตาม Rails มีเครื่องมือช่วยในการสร้างตัวเลือกจากคอลเลกชันโดยไม่ต้องวนซ้ำโดยชัดเจน เครื่องมือเหล่านี้จะกำหนดค่าและป้ายกำกับข้อเสนอของแต่ละตัวโดยเรียกเมธอดที่ระบุบนวัตถุแต่ละตัวในคอลเลกชัน

### เครื่องมือ `collection_select`

ในการสร้างกล่องเลือก เราสามารถใช้ [`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select):

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

ผลลัพธ์:

```html
<select name="person[city_id]" id="person_city_id">
  <option value="3">เบอร์ลิน</option>
  <option value="1">ชิคาโก</option>
  <option value="2">มาดริด</option>
</select>
```

หมายเหตุ: ด้วย `collection_select` เราระบุเมธอดค่าก่อน (`:id` ในตัวอย่างด้านบน) และเมธอดป้ายกำกับหลัง (`:name` ในตัวอย่างด้านบน) ซึ่งตรงกันข้ามกับลำดับที่ใช้เมื่อระบุตัวเลือกสำหรับเครื่องมือ `select` ที่ป้ายกำกับข้อเสนอมาก่อนและค่าที่สอง

### เครื่องมือ `collection_radio_buttons`

ในการสร้างชุดปุ่มวิทยุ เราสามารถใช้ [`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons):

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

ผลลัพธ์:

```html
<input type="radio" name="person[city_id]" value="3" id="person_city_id_3">
<label for="person_city_id_3">เบอร์ลิน</label>

<input type="radio" name="person[city_id]" value="1" id="person_city_id_1">
<label for="person_city_id_1">ชิคาโก</label>

<input type="radio" name="person[city_id]" value="2" id="person_city_id_2">
<label for="person_city_id_2">มาดริด</label>
```

### เครื่องมือ `collection_check_boxes`

ในการสร้างชุดเช็คบ็อกซ์ - ตัวอย่างเช่น เพื่อรองรับความสัมพันธ์ `has_and_belongs_to_many` - เราสามารถใช้ [`collection_check_boxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes):

```erb
<%= form.collection_check_boxes :interest_ids, Interest.order(:name), :id, :name %>
```

ผลลัพธ์:

```html
<input type="checkbox" name="person[interest_id][]" value="3" id="person_interest_id_3">
<label for="person_interest_id_3">วิศวกรรม</label>

<input type="checkbox" name="person[interest_id][]" value="4" id="person_interest_id_4">
<label for="person_interest_id_4">คณิตศาสตร์</label>

<input type="checkbox" name="person[interest_id][]" value="1" id="person_interest_id_1">
<label for="person_interest_id_1">วิทยาศาสตร์</label>

<input type="checkbox" name="person[interest_id][]" value="2" id="person_interest_id_2">
<label for="person_interest_id_2">เทคโนโลยี</label>
```

การอัปโหลดไฟล์
---------------

งานที่พบบ่อยคือการอัปโหลดไฟล์บางประเภท เช่น รูปภาพของบุคคลหรือไฟล์ CSV ที่มีข้อมูลเพื่อดำเนินการต่อไป ฟิลด์อัปโหลดไฟล์สามารถแสดงผลด้วยเครื่องมือ [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field)

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

สิ่งสำคัญที่สุดในการอัปโหลดไฟล์คือคุณลักษณะ `enctype` ของฟอร์มที่แสดงผล **ต้อง** ถูกตั้งค่าเป็น "multipart/form-data" นี้จะถูกทำอัตโนมัติหากคุณใช้ `file_field` ภายใน `form_with` คุณยังสามารถตั้งค่าแอตทริบิวต์เองได้:

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :picture %>
<% end %>
```

โปรดทราบว่าตามกฎของ `form_with` ชื่อฟิลด์ในฟอร์มสองแบบด้านบนจะแตกต่างกันด้วย กล่าวคือ ชื่อฟิลด์ในฟอร์มแบบแรกจะเป็น `person[picture]` (สามารถเข้าถึงได้ผ่าน `params[:person][:picture]`) และชื่อฟิลด์ในฟอร์มแบบที่สองจะเป็นเพียง `picture` (สามารถเข้าถึงได้ผ่าน `params[:picture]`)

### สิ่งที่ถูกอัปโหลด

วัตถุในแฮช `params` เป็นตัวอย่างของ [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html) ตัวอย่างต่อไปนี้จะบันทึกไฟล์ที่อัปโหลดใน `#{Rails.root}/public/uploads` ในชื่อเดียวกับไฟล์ต้นฉบับ
```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

เมื่อไฟล์ถูกอัปโหลดแล้ว มีงานที่หลากหลายที่เป็นไปได้ เช่น การเก็บไฟล์ (บนดิสก์, Amazon S3, เป็นต้น) การเชื่อมโยงไฟล์กับโมเดล การปรับขนาดไฟล์รูปภาพ และการสร้างรูปย่อ เป็นต้น [Active Storage](active_storage_overview.html) ถูกออกแบบมาเพื่อช่วยในงานเหล่านี้

การปรับแต่ง Form Builders
-------------------------

วัตถุที่ถูกส่งคืนโดย `form_with` และ `fields_for` เป็นอินสแตนซ์ของ [`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html) Form builders ห่อหุ้มความคิดเกี่ยวกับการแสดงองค์ประกอบฟอร์มสำหรับวัตถุเดียว ในขณะที่คุณสามารถเขียนช่วยเหลือสำหรับฟอร์มของคุณได้ตามปกติ คุณยังสามารถสร้างคลาสย่อยของ `ActionView::Helpers::FormBuilder` และเพิ่มช่วยเหลือในนั้นได้เช่นกัน ตัวอย่างเช่น

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

สามารถแทนที่ด้วย

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

โดยกำหนดคลาส `LabellingFormBuilder` ที่คล้ายกับตัวอย่างต่อไปนี้:

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    label(attribute) + super
  end
end
```

หากคุณใช้งานส่วนนี้บ่อยคุณสามารถกำหนด `labeled_form_with` helper ที่ใช้ `builder: LabellingFormBuilder` โดยอัตโนมัติ:

```ruby
def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
  options[:builder] = LabellingFormBuilder
  form_with model: model, scope: scope, url: url, format: format, **options, &block
end
```

Form builder ที่ใช้งานยังกำหนดว่าจะเกิดอะไรขึ้นเมื่อคุณทำ:

```erb
<%= render partial: f %>
```

หาก `f` เป็นอินสแตนซ์ของ `ActionView::Helpers::FormBuilder` จะแสดงผล `form` partial โดยกำหนดวัตถุของพาร์ทิชันเป็น form builder หาก form builder เป็นคลาส `LabellingFormBuilder` จะแสดงผล `labelling_form` partial แทน

เข้าใจการตั้งชื่อพารามิเตอร์
--------------------------------

ค่าจากฟอร์มอาจอยู่ในระดับบนสุดของ `params` หรืออยู่ภายในแฮชอื่น ๆ ตัวอย่างเช่นในการกระทำ `create` มาตรฐานสำหรับโมเดล Person `params[:person]` จะเป็นแฮชของแอตทริบิวต์ทั้งหมดสำหรับบุคคลที่จะสร้าง แฮช `params` ยังสามารถมีอาร์เรย์ อาร์เรย์ของแฮช และอื่น ๆ

ในพื้นฐานแล้วฟอร์ม HTML ไม่รู้เรื่องข้อมูลที่มีโครงสร้าง ที่พวกเขาสร้างขึ้นมาเป็นคู่ชื่อ-ค่า โดยคู่เป็นสตริงธรรมดา อาร์เรย์และแฮชที่คุณเห็นในแอปพลิเคชันของคุณเป็นผลมาจากการตั้งชื่อพารามิเตอร์ที่ Rails ใช้

### โครงสร้างพื้นฐาน

โครงสร้างพื้นฐานสองอย่างคืออาร์เรย์และแฮช แฮชสะท้อนไวยากรณ์ที่ใช้ในการเข้าถึงค่าใน `params` ตัวอย่างเช่นหากฟอร์มมี:

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

แฮช `params` จะมีค่าเป็น

```ruby
{ 'person' => { 'name' => 'Henry' } }
```

และ `params[:person][:name]` จะเรียกคืนค่าที่ส่งมาในคอนโทรลเลอร์

แฮชสามารถซ้อนกันได้เท่าที่ต้องการ เช่น:

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

จะทำให้แฮช `params` เป็น

```ruby
{ 'person' => { 'address' => { 'city' => 'New York' } } }
```

โดยปกติ Rails จะไม่สนใจชื่อพารามิเตอร์ที่ซ้ำกัน หากชื่อพารามิเตอร์จบด้วยวงเล็บเหล่านี้ `[]` จะถูกสะสมในอาร์เรย์ หากคุณต้องการให้ผู้ใช้ป้อนหมายเลขโทรศัพท์หลายหมายเลขคุณสามารถใส่โค้ดนี้ในฟอร์ม:
```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

นี้จะทำให้ `params[:person][:phone_number]` เป็นอาร์เรย์ที่มีหมายเลขโทรศัพท์ที่ป้อนเข้าไป

### การรวมกัน

เราสามารถผสมผสานความสามารถของสองแนวคิดเหล่านี้ได้ องค์ประกอบหนึ่งของแฮชอาจเป็นอาร์เรย์เหมือนในตัวอย่างก่อนหน้านี้ หรือคุณสามารถมีอาร์เรย์ของแฮชได้เช่นกัน ตัวอย่างเช่น แบบฟอร์มอาจช่วยให้คุณสร้างที่อยู่ได้หลายรายการโดยทำซ้ำส่วนของแบบฟอร์มต่อไปนี้

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

นี้จะทำให้ `params[:person][:addresses]` เป็นอาร์เรย์ของแฮชที่มีคีย์ `line1` `line2` และ `city`

อย่างไรก็ตาม มีข้อจำกัด: แม้ว่าแฮชสามารถซ้อนกันได้ตามต้องการ แต่อนุญาตให้มีเพียงระดับเดียวของ "อาร์เรย์" เท่านั้น อาร์เรย์สามารถแทนที่ด้วยแฮชได้โดยทั่วไป ตัวอย่างเช่น แทนที่จะมีอาร์เรย์ของออบเจกต์โมเดล คุณสามารถมีแฮชของออบเจกต์โมเดลที่มีคีย์เป็น id หรือดัชนีของอาร์เรย์ หรือพารามิเตอร์อื่น ๆ

คำเตือน: พารามิเตอร์อาร์เรย์ไม่เข้ากันได้กับช่วยเหลือ `check_box` ตามข้อกำหนดของ HTML ช่องทำเครื่องหมายที่ไม่ได้เลือกจะส่งค่าว่าง อย่างไรก็ตาม มันมักจะสะดวกสำหรับช่องทำเครื่องหมายที่จะส่งค่าเสมอ `check_box` ช่วยในการสร้างอินพุตที่ซ่อนและมีชื่อเดียวกัน ถ้าช่องทำเครื่องหมายไม่ได้เลือก จะส่งเฉพาะอินพุตที่ซ่อนและถ้ามันถูกเลือก ทั้งสองจะถูกส่งแต่ค่าที่ส่งโดยช่องทำเครื่องหมายจะมีความสำคัญกว่า

### ช่วยในการสร้างฟิลด์ `:index`

สมมติว่าเราต้องการแสดงแบบฟอร์มที่มีชุดของฟิลด์สำหรับแต่ละที่อยู่ของบุคคล ช่วยในการสร้างฟิลด์ `fields_for` ด้วยตัวเลือก `:index` สามารถช่วยได้:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

ถ้าบุคคลมีที่อยู่สองที่ โดยมี ID 23 และ 45 แบบฟอร์มด้านบนจะแสดงผลเป็น:

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

ซึ่งจะทำให้ได้ `params` แฮชที่มีรูปแบบเช่นนี้:

```ruby
{
  "person" => {
    "name" => "Bob",
    "address" => {
      "23" => {
        "city" => "Paris"
      },
      "45" => {
        "city" => "London"
      }
    }
  }
}
```

อินพุตทั้งหมดจะแมปกับแฮช `"person"` เพราะเราเรียกใช้ `fields_for` บนฟอร์มบิลเดอร์ `person_form` นอกจากนี้ โดยระบุ `index: address.id` เราได้แสดงแอตทริบิวต์ `name` ของแต่ละอินพุตเมืองเป็น `person[address][#{address.id}][city]` แทนที่จะเป็น `person[address][city]` ดังนั้นเราสามารถระบุได้ว่าเราต้องการแก้ไขเรคคอร์ดที่อยู่เมืองใดเมื่อประมวลผลแฮช `params`

คุณสามารถส่งตัวเลขหรือสตริงอื่น ๆ ที่สำคัญผ่านตัวเลือก `:index` ได้ คุณสามารถส่ง `nil` ได้ซึ่งจะสร้างพารามิเตอร์อาร์เรย์

ในการสร้างการซ้อนที่ซับซ้อนขึ้นคุณสามารถระบุส่วนหน้าของชื่ออินพุตโดยชัดเจน เช่น:

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```
จะสร้างอินพุตเช่น:

```html
<input id="person_address_primary_23_city" name="person[address][primary][23][city]" type="text" value="Paris" />
```

คุณยังสามารถส่งค่า `:index` โดยตรงไปยัง helpers เช่น `text_field` ได้ แต่มักจะไม่ซ้ำซ้อนเท่ากับการระบุที่ระดับฟอร์มบิลเดียว

โดยทั่วไปแล้ว ชื่ออินพุตสุดท้ายจะเป็นการต่อกันของชื่อที่กำหนดให้กับ `fields_for` / `form_with` ค่า `:index` และชื่อแอตทริบิวต์

สุดท้าย ในกรณีที่เป็นทางลัด แทนที่จะระบุ ID สำหรับ `:index` (เช่น `index: address.id`) คุณสามารถเพิ่ม `"[]"` ไปยังชื่อที่กำหนด ตัวอย่างเช่น:

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

จะสร้างผลลัพธ์เหมือนกับตัวอย่างเดิม

แบบฟอร์มสำหรับทรัพยากรภายนอก
---------------------------

Rails' form helpers ยังสามารถใช้สร้างแบบฟอร์มสำหรับโพสต์ข้อมูลไปยังทรัพยากรภายนอกได้ อย่างไรก็ตาม บางครั้งอาจจำเป็นต้องตั้งค่า `authenticity_token` สำหรับทรัพยากรนั้น สามารถทำได้โดยส่งพารามิเตอร์ `authenticity_token: 'your_external_token'` ไปยังตัวเลือก `form_with`:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  เนื้อหาแบบฟอร์ม
<% end %>
```

บางครั้งเมื่อส่งข้อมูลไปยังทรัพยากรภายนอก เช่นเกตเวย์การชำระเงิน ฟิลด์ที่สามารถใช้ในแบบฟอร์มจะถูกจำกัดโดย API ภายนอกและอาจไม่ต้องการสร้าง `authenticity_token` ในกรณีนี้เพียงแค่ส่ง `false` ไปยังตัวเลือก `:authenticity_token`:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  เนื้อหาแบบฟอร์ม
<% end %>
```

สร้างแบบฟอร์มที่ซับซ้อน
----------------------

แอปพลิเคชันหลายๆ แอปพลิเคชันเติบโตเกินแบบฟอร์มที่แก้ไขอ็อบเจกต์เดียว ตัวอย่างเช่น เมื่อสร้าง `Person` คุณอาจต้องการให้ผู้ใช้สามารถ (ในแบบฟอร์มเดียวกัน) สร้างเร็คคอร์ดที่อยู่หลายรายการ (บ้าน ที่ทำงาน เป็นต้น) เมื่อแก้ไขคนนั้น ผู้ใช้ควรสามารถเพิ่ม ลบ หรือแก้ไขที่อยู่ตามต้องการ

### กำหนดค่าในโมเดล

Active Record มีการสนับสนุนระดับโมเดลผ่านวิธี [`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for):

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses
end

class Address < ApplicationRecord
  belongs_to :person
end
```

สร้างเมธอด `addresses_attributes=` บน `Person` ซึ่งช่วยให้คุณสามารถสร้าง อัปเดต และ (ตามต้องการ) ลบที่อยู่ได้

### แบบฟอร์มที่ซับซ้อน

แบบฟอร์มต่อไปนี้ช่วยให้ผู้ใช้สามารถสร้าง `Person` และที่อยู่ที่เกี่ยวข้องได้

```html+erb
<%= form_with model: @person do |form| %>
  ที่อยู่:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

เมื่อความสัมพันธ์ยอมรับแบบฟอร์มที่ซับซ้อน `fields_for` จะแสดงบล็อกของมันหนึ่งครั้งสำหรับทุกๆ องค์ประกอบในความสัมพันธ์ โดยเฉพาะอย่างยิ่งถ้าคนไม่มีที่อยู่เลย จะไม่แสดงอะไรเลย รูปแบบที่พบบ่อยคือคอนโทรลเลอร์จะสร้างลูกที่ว่างเปล่าหรือมากกว่าหนึ่งเพื่อให้แสดงชุดของฟิลด์อย่างน้อยหนึ่งชุดให้กับผู้ใช้ ตัวอย่างด้านล่างจะทำให้แสดงชุดของฟิลด์ที่อยู่สองชุดในแบบฟอร์มคนใหม่

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```
`fields_for` จะให้ form builder เป็นผลลัพธ์ ชื่อพารามิเตอร์จะเป็นสิ่งที่ `accepts_nested_attributes_for` คาดหวัง ตัวอย่างเช่น เมื่อสร้างผู้ใช้งานพร้อมที่อยู่ 2 ที่ พารามิเตอร์ที่ส่งมาจะมีลักษณะดังนี้:

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

ค่าจริงของคีย์ในแฮช `:addresses_attributes` ไม่สำคัญ; อย่างไรก็ตาม พวกเขาจะต้องเป็นสตริงของจำนวนเต็มและต่างกันสำหรับแต่ละที่อยู่

หากวัตถุที่เกี่ยวข้องถูกบันทึกไว้แล้ว `fields_for` จะสร้างอินพุตที่ซ่อนไว้ด้วย `id` ของบันทึกที่บันทึกไว้ คุณสามารถปิดใช้งานนี้ได้โดยส่ง `include_id: false` ไปยัง `fields_for`

### ตัวควบคุม

เช่นเคยคุณต้อง
[ประกาศพารามิเตอร์ที่อนุญาต](action_controller_overview.html#strong-parameters) ใน
ตัวควบคุมก่อนที่คุณจะส่งพารามิเตอร์เหล่านั้นไปยังโมเดล:

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### การลบวัตถุ

คุณสามารถอนุญาตให้ผู้ใช้ลบวัตถุที่เกี่ยวข้องได้โดยส่ง `allow_destroy: true` ไปยัง `accepts_nested_attributes_for`

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

หากแฮชของแอตทริบิวต์สำหรับวัตถุมีคีย์ `_destroy` ที่มีค่าที่
ประเมินเป็น `true` (เช่น 1, '1', true, หรือ 'true') แล้ววัตถุจะถูกทำลาย
แบบฟอร์มนี้อนุญาตให้ผู้ใช้ลบที่อยู่:

```erb
<%= form_with model: @person do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

อย่าลืมอัปเดตพารามิเตอร์ที่อนุญาตในตัวควบคุมของคุณเพื่อรวม
ฟิลด์ `_destroy`:

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### ป้องกันระเบียบว่างเปล่า

มันมักจะเป็นประโยชน์ที่จะละเว้นชุดของฟิลด์ที่ผู้ใช้ไม่ได้กรอก คุณสามารถควบคุมได้โดยส่ง `:reject_if` proc ไปยัง `accepts_nested_attributes_for` โปรกจนี้จะถูกเรียกใช้กับแต่ละแฮชของแอตทริบิวต์ที่ส่งมาจากแบบฟอร์ม หากโปรกคืนค่า `true` แล้ว Active Record จะไม่สร้างวัตถุที่เกี่ยวข้องสำหรับแฮชนั้น ตัวอย่างด้านล่างจะพยายามสร้างที่อยู่เท่านั้นถ้ามีแอตทริบิวต์ `kind` ที่ถูกตั้งค่า

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda { |attributes| attributes['kind'].blank? }
end
```

เป็นความสะดวกคุณสามารถส่งสัญลักษณ์ `:all_blank` แทนซึ่งจะสร้าง proc ที่จะปฏิเสธระเบียบที่ว่างเปล่าทั้งหมด ยกเว้นค่าใดค่าหนึ่งสำหรับ `_destroy`

### เพิ่มฟิลด์ในขณะที่เคลื่อนที่

แทนที่การแสดงผลชุดของฟิลด์หลายชุดล่วงหน้าคุณอาจต้องการเพิ่มเฉพาะเมื่อผู้ใช้คลิกที่ปุ่ม "เพิ่มที่อยู่ใหม่" Rails ไม่มีการสนับสนุนในส่วนนี้ ในขณะที่สร้างชุดของฟิลด์ใหม่คุณต้องให้แน่ใจว่าคีย์ของอาร์เรย์ที่เกี่ยวข้องเป็นค่าที่ไม่ซ้ำกัน - วันที่ JavaScript ปัจจุบัน (มิลลิวินาทีตั้งแต่ [epoch](https://en.wikipedia.org/wiki/Unix_time)) เป็นตัวเลือกที่พบบ่อย

การใช้ Tag Helpers โดยไม่มี Form Builder
----------------------------------------
ในกรณีที่คุณต้องการแสดงฟอร์มฟิลด์นอกเนื้อหาของฟอร์มบิลเดอร์  Rails จะให้ความช่วยเหลือด้วยตัวช่วยแท็กสำหรับองค์ประกอบของฟอร์มที่พบบ่อย ตัวอย่างเช่น [`check_box_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-check_box_tag):

```erb
<%= check_box_tag "accept" %>
```

ผลลัพธ์:

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

โดยทั่วไปแล้วตัวช่วยเหล่านี้จะมีชื่อเดียวกันกับตัวช่วยของฟอร์มบิลเดอร์และเพิ่ม `_tag` ต่อท้าย สำหรับรายการทั้งหมด ดูที่ [เอพีไอของ FormTagHelper](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).

การใช้ `form_tag` และ `form_for`
-------------------------------

ก่อนที่ `form_with` จะถูกนำเสนอใน Rails 5.1 ฟังก์ชันของมันถูกแบ่งออกเป็น [`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag) และ [`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for) ทั้งสองตอนนี้ถูกเลิกใช้แบบอ่อนโยน คู่มือการใช้งานสามารถพบได้ใน [เวอร์ชันเก่าของคู่มือนี้](https://guides.rubyonrails.org/v5.2/form_helpers.html).
[`fields_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for
[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-formmethod
[button-name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-name
[button-value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-value
