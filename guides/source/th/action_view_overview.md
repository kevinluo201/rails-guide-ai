**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f6b613040c7aed4c76b6648b6fd963cf
ภาพรวมของ Action View
====================

หลังจากอ่านเอกสารนี้คุณจะรู้:

* Action View คืออะไรและวิธีการใช้งานกับ Rails
* วิธีการใช้งานเทมเพลต พาร์เชียล และเลเอาท์
* วิธีการใช้งานวิวที่ถูกแปลงเป็นภาษาท้องถิ่น

--------------------------------------------------------------------------------

Action View คืออะไร?
--------------------

ใน Rails เราใช้ [Action Controller](action_controller_overview.html) และ Action View ในการจัดการคำขอเว็บ โดยทั่วไป Action Controller จะเกี่ยวข้องกับการสื่อสารกับฐานข้อมูลและการดำเนินการ CRUD ตามที่จำเป็น ในขณะที่ Action View จะรับผิดชอบในการรวบรวมการตอบสนอง

เทมเพลตของ Action View เขียนด้วย Ruby ที่ซ้อนอยู่ในแท็กที่ผสมผสานกับ HTML เพื่อหลีกเลี่ยงการรกตัวเทมเพลตด้วยรหัสที่ซ้ำซ้อน มีคลาสช่วยในการจัดการกับฟอร์ม วันที่ และสตริงที่ใช้บ่อย นอกจากนี้ยังสามารถเพิ่มคลาสช่วยใหม่ในแอปพลิเคชันของคุณได้อย่างง่ายดายเมื่อแอปพลิเคชันของคุณเติบโตขึ้น

หมายเหตุ: บางคุณสมบัติของ Action View เกี่ยวข้องกับ Active Record แต่นั่นไม่ได้หมายความว่า Action View ขึ้นอยู่กับ Active Record Action View เป็นแพคเกจที่อิสระที่สามารถใช้งานได้กับไลบรารี Ruby ใด ๆ

การใช้งาน Action View กับ Rails
----------------------------

สำหรับแต่ละคอนโทรลเลอร์ จะมีไดเรกทอรีที่เกี่ยวข้องในไดเรกทอรี `app/views` ซึ่งเก็บไฟล์เทมเพลตที่เป็นส่วนประกอบของวิวที่เกี่ยวข้องกับคอนโทรลเลอร์นั้น ไฟล์เหล่านี้ใช้ในการแสดงผลวิวที่เกิดจากแต่ละการกระทำของคอนโทรลเลอร์

มาดูว่า Rails ทำอะไรเมื่อสร้างทรัพยากรใหม่โดยใช้เจเนอเรเตอร์ scaffold:

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

มีกฎในการตั้งชื่อวิวใน Rails โดยทั่วไปวิวจะใช้ชื่อเดียวกับการกระทำของคอนโทรลเลอร์ที่เกี่ยวข้อง ดังที่เราเห็นข้างต้น
ตัวอย่างเช่น การกระทำ index ของ `articles_controller.rb` จะใช้ไฟล์วิว `index.html.erb` ในไดเรกทอรี `app/views/articles`
HTML ที่ส่งกลับไปยังไคลเอนต์จะประกอบด้วยไฟล์ ERB นี้ เลเอาท์เทมเพลตที่ห่อหุ้ม และพาร์เชียลทั้งหมดที่วิวอาจอ้างถึง ในเอกสารนี้คุณจะพบคำอธิบายอย่างละเอียดเกี่ยวกับสามส่วนเหล่านี้

เหมือนกับที่กล่าวไว้ ผลลัพธ์ HTML สุดท้ายเป็นการรวมกันของสามองค์ประกอบของ Rails: `เทมเพลต`, `พาร์เชียล`, และ `เลเอาท์`
ด้านล่างนี้เป็นภาพรวมสั้น ๆ เกี่ยวกับแต่ละส่วน

เทมเพลต
---------

เทมเพลตของ Action View สามารถเขียนได้หลายวิธี หากไฟล์เทมเพลตมีนามสกุล `.erb` แสดงว่าใช้ร่วมกับ ERB (Embedded Ruby) และ HTML หากไฟล์เทมเพลตมีนามสกุล `.builder` แสดงว่าใช้กับไลบรารี `Builder::XmlMarkup`

Rails รองรับระบบเทมเพลตหลายรูปแบบและใช้นามสกุลไฟล์เพื่อแยกแยะระหว่างพวกเขา ตัวอย่างเช่น ไฟล์ HTML ที่ใช้ระบบเทมเพลต ERB จะมีนามสกุล `.html.erb`

### ERB

ในเทมเพลต ERB สามารถรวมรหัส Ruby ได้โดยใช้แท็ก `<% %>` และ `<%= %>` แท็ก `<% %>` ใช้ในการประมวลผลรหัส Ruby ที่ไม่ต้องการส่งคืนอะไรกลับ เช่นเงื่อนไข ลูป หรือบล็อก และแท็ก `<%= %>` ใช้เมื่อต้องการแสดงผล

พิจารณาลูปต่อไปนี้สำหรับชื่อ:

```html+erb
<h1>ชื่อของคนทั้งหมด</h1>
<% @people.each do |person| %>
  ชื่อ: <%= person.name %><br>
<% end %>
```

ลูปถูกตั้งค่าโดยใช้แท็กซ้อนกัน (`<% %>`) และชื่อถูกแทรกโดยใช้แท็กแทรกผลลัพธ์ (`<%= %>`) โปรดทราบว่านี่ไม่ใช่เพียงคำแนะนำในการใช้งาน: ฟังก์ชันแสดงผลทั่วไปเช่น `print` และ `puts` จะไม่ถูกแสดงในวิวด้วยเทมเพลต ERB ดังนั้นตัวอย่างนี้จะผิด:

```html+erb
<%# ผิด %>
สวัสดีคุณ <% puts "Frodo" %>
```

หากต้องการลดช่องว่างด้านหน้าและด้านหลัง คุณสามารถใช้ `<%-` `-%>` แทน `<%` และ `%>`

### Builder

เทมเพลต Builder เป็นทางเลือกที่เป็นโปรแกรมมากกว่า ERB มีประโยชน์เฉพาะสำหรับการสร้างเนื้อหา XML ออกมา วัตถุ XmlMarkup ที่ชื่อว่า `xml` จะถูกสร้างขึ้นโดยอัตโนมัติและสามารถใช้ในเทมเพลตที่มีนามสกุล `.builder`

นี่คือตัวอย่างพื้นฐาน:

```ruby
xml.em("เน้น")
xml.em { xml.b("เน้นและหนา") }
xml.a("ลิงค์", "href" => "https://rubyonrails.org")
xml.target("name" => "คอมไพล์", "option" => "เร็ว")
```

ผลลัพธ์ที่ได้คือ:

```html
<em>เน้น</em>
<em><b>เน้นและหนา</b></em>
<a href="https://rubyonrails.org">ลิงค์</a>
<target option="เร็ว" name="คอมไพล์" />
```

เมื่อมีเมธอดที่มีบล็อก จะถูกจัดการเป็นแท็ก XML ที่มีแท็กซ้อนอยู่ในบล็อก ตัวอย่างเช่น:

```ruby
xml.div {
  xml.h1(@person.name)
  xml.p(@person.bio)
}
```

จะสร้างผลลัพธ์เช่นนี้:

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>A product of Danish Design during the Winter of '79...</p>
</div>
```

ด้านล่างนี้คือตัวอย่าง RSS ที่ใช้จริงบน Basecamp:

```ruby
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@feed_title)
    xml.link(@url)
    xml.description "Basecamp: Recent items"
    xml.language "en-us"
    xml.ttl "40"

    for item in @recent_items
      xml.item do
        xml.title(item_title(item))
        xml.description(item_description(item)) if item_description(item)
        xml.pubDate(item_pubDate(item))
        xml.guid(@person.firm.account.url + @recent_items.url(item))
        xml.link(@person.firm.account.url + @recent_items.url(item))
        xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
      end
    end
  end
end
```

### Jbuilder

[Jbuilder](https://github.com/rails/jbuilder) เป็น gem ที่ดูแลโดยทีม Rails และรวมอยู่ใน `Gemfile` ของ Rails โดยค่าเริ่มต้น
มันคล้ายกับ Builder แต่ใช้สร้าง JSON แทน XML

หากคุณยังไม่มี คุณสามารถเพิ่มโค้ดด้านล่างนี้ใน `Gemfile`:

```ruby
gem 'jbuilder'
```

Jbuilder object ที่ชื่อว่า `json` จะถูกสร้างขึ้นโดยอัตโนมัติและใช้ในเทมเพลตที่มีนามสกุล `.jbuilder`

นี่คือตัวอย่างพื้นฐาน:

```ruby
json.name("Alex")
json.email("alex@example.com")
```

จะสร้างผลลัพธ์เช่นนี้:

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

ดูเอกสาร [Jbuilder](https://github.com/rails/jbuilder#jbuilder) สำหรับตัวอย่างและข้อมูลเพิ่มเติม

### การเก็บแคชเทมเพลต

โดยค่าเริ่มต้น Rails จะคอมไพล์แต่ละเทมเพลตเป็นเมธอดเพื่อแสดงผล ในสภาพแวดล้อมการพัฒนา เมื่อคุณแก้ไขเทมเพลต Rails จะตรวจสอบเวลาแก้ไขของไฟล์และคอมไพล์ใหม่

Partial
--------

Partial templates - ที่เรียกว่า "partials" - เป็นอุปกรณ์อีกอันหนึ่งที่ใช้ในกระบวนการแสดงผลเพื่อทำให้ง่ายต่อการจัดการ ด้วย partials คุณสามารถแยกโค้ดออกจากเทมเพลตหลักไปยังไฟล์ที่แยกออกและใช้ซ้ำได้ในทุกๆ เทมเพลต

### การแสดงผล Partial

ในการแสดงผล partial เป็นส่วนหนึ่งของ view คุณใช้เมธอด `render` ภายใน view:

```erb
<%= render "menu" %>
```

นี้จะแสดงผลไฟล์ที่ชื่อ `_menu.html.erb` ที่จุดนั้นภายใน view ที่กำลังถูกแสดงผล โปรดทราบว่ามีอักขระขึ้นต้นด้วยเครื่องหมายขีดเส้นใต้: partials ถูกตั้งชื่อด้วยเครื่องหมายขีดเส้นใต้ขึ้นต้นเพื่อแยกจาก view ปกติ แม้ว่าจะใช้โดยไม่มีเครื่องหมายขีดเส้นใต้ นี่ยังเป็นจริงเมื่อคุณดึง partial จากโฟลเดอร์อื่น:

```erb
<%= render "shared/menu" %>
```

โค้ดนี้จะดึง partial จาก `app/views/shared/_menu.html.erb`

### การใช้ Partial เพื่อทำให้ View ง่ายขึ้น

วิธีหนึ่งในการใช้ partials คือที่จะใช้เป็นเทียบเท่ากับ subroutine; วิธีการเคลื่อนย้ายรายละเอียดออกจาก view เพื่อให้คุณสามารถเข้าใจว่าเกิดอะไรขึ้นได้ง่ายขึ้น ตัวอย่างเช่น คุณอาจมี view ที่มีลักษณะดังนี้:

```html+erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "shared/footer" %>
```

ที่นี่ partial `_ad_banner.html.erb` และ `_footer.html.erb` อาจมีเนื้อหาที่ใช้ร่วมกันในหลายๆ หน้าของแอปพลิเคชันของคุณ คุณไม่จำเป็นต้องเห็นรายละเอียดของส่วนเหล่านี้เมื่อคุณตั้งใจทำงานกับหน้าเฉพาะ

### `render` โดยไม่มี `partial` และ `locals` Options

ในตัวอย่างข้างต้น `render` ใช้ 2 options: `partial` และ `locals` แต่หาก
เป็นตัวเลือกที่คุณต้องการส่งต่อเท่านั้นคุณสามารถข้ามการใช้ตัวเลือกเหล่านี้ได้ เช่น แทนที่จะ:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

คุณยังสามารถทำได้:

```erb
<%= render "product", product: @product %>
```

### ตัวเลือก `as` และ `object`

โดยค่าเริ่มต้น `ActionView::Partials::PartialRenderer` จะมีวัตถุของมันในตัวแปรโลคอลที่มีชื่อเดียวกับเทมเพลต ดังนั้น เมื่อได้รับ:

```erb
<%= render partial: "product" %>
```

ภายใน partial `_product` เราจะได้ `@product` ในตัวแปรโลคอล `product` เหมือนกับเราเขียน:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

ตัวเลือก `object` สามารถใช้เพื่อระบุวัตถุที่จะแสดงผลใน partial โดยตรง มีประโยชน์เมื่อวัตถุของเทมเพลตอยู่ที่อื่น (เช่นในตัวแปรอินสแตนซ์อื่นหรือตัวแปรโลคอลอื่น)

ตัวอย่างเช่น แทนที่จะ:

```erb
<%= render partial: "product", locals: { product: @item } %>
```

เราจะทำ:

```erb
<%= render partial: "product", object: @item %>
```

ด้วยตัวเลือก `as` เราสามารถระบุชื่อตัวแปรโลคอลที่แตกต่างกันได้ ตัวอย่างเช่น หากเราต้องการให้เป็น `item` แทนที่ `product` เราจะทำ:

```erb
<%= render partial: "product", object: @item, as: "item" %>
```

นี่เทียบเท่ากับ
```erb
<%= render partial: "product", locals: { item: @item } %>
```

### การแสดงผลข้อมูลหลายรายการ

โดยทั่วไปแล้ว เราจะต้องการที่จะวนลูปผ่านรายการและแสดงผลข้อมูลในแต่ละรายการด้วย sub-template นี้เป็นรูปแบบการทำงานที่เรียกใช้เป็นเมธอดเดียวที่รับอาร์เรย์และแสดงผล sub-template สำหรับแต่ละองค์ประกอบในอาร์เรย์

ตัวอย่างการแสดงผลสินค้าทั้งหมด:

```erb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

สามารถเขียนใหม่ในบรรทัดเดียวได้:

```erb
<%= render partial: "product", collection: @products %>
```

เมื่อเรียกใช้ partial ด้วย collection แต่ละอินสแตนซ์ของ partial สามารถเข้าถึงสมาชิกของ collection ที่กำลังแสดงผลผ่านตัวแปรที่มีชื่อตาม partial ในกรณีนี้ partial คือ `_product` และภายใน partial นั้นคุณสามารถอ้างอิงไปยัง `product` เพื่อรับสมาชิกของ collection ที่กำลังแสดงผล

คุณสามารถใช้ไวยากรณ์ย่อสำหรับการแสดงผลข้อมูลหลายรายการ โดยสมมุติว่า `@products` เป็นคอลเลกชันของอินสแตนซ์ `Product` คุณสามารถเขียนดังนี้เพื่อให้ได้ผลลัพธ์เดียวกัน:

```erb
<%= render @products %>
```

Rails จะกำหนดชื่อของ partial ที่จะใช้โดยดูที่ชื่อโมเดลในคอลเลกชัน `Product` ในความเป็นจริงคุณยังสามารถแสดงผลข้อมูลหลายรายการที่ประกอบด้วยอินสแตนซ์ของโมเดลที่แตกต่างกันโดยใช้ไวยากรณ์ย่อนี้ และ Rails จะเลือก partial ที่เหมาะสมสำหรับแต่ละสมาชิกในคอลเลกชัน

### การใช้งาน Spacer Templates

คุณยังสามารถระบุ partial ที่สองที่จะแสดงผลระหว่างอินสแตนซ์ของ partial หลักโดยใช้ตัวเลือก `:spacer_template`:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails จะแสดงผล partial `_product_ruler` (โดยไม่มีข้อมูลที่ส่งไปยังมัน) ระหว่างแต่ละคู่ของ partial `_product`

### Strict Locals

โดยค่าเริ่มต้น template จะยอมรับ `locals` ใดๆ เป็น keyword arguments ในการกำหนดว่า template ยอมรับ `locals` ใด ให้เพิ่มคอมเมนต์ magic `locals`:

```erb
<%# locals: (message:) -%>
<%= message %>
```

ค่าเริ่มต้นสามารถกำหนดได้ดังนี้:

```erb
<%# locals: (message: "Hello, world!") -%>
<%= message %>
```

หรือ `locals` สามารถปิดใช้งานได้ทั้งหมด:

```erb
<%# locals: () %>
```

Layouts
-------

Layouts สามารถใช้ในการแสดงผล template ที่เป็นร่วมกันรอบผลลัพธ์ของการดำเนินการของคอนโทรลเลอร์ใน Rails โดยทั่วไปแล้ว แอปพลิเคชัน Rails จะมีเลย์เอาท์สองรูปแบบที่หน้าจอจะถูกแสดงภายใน เช่น ไซต์อาจมีเลย์เอาท์สำหรับผู้ใช้ที่เข้าสู่ระบบและอีกเลย์เอาท์สำหรับการตลาดหรือการขายของไซต์ เลย์เอาท์สำหรับผู้ใช้ที่เข้าสู่ระบบอาจรวมการนำทางระดับบนที่ควรมีอยู่ในหลายๆ การดำเนินการของคอนโทรลเลอร์ เลย์เอาท์สำหรับการขายของแอป SaaS อาจรวมการนำทางระดับบนสำหรับสิ่งเช่นหน้า "ราคา" และ "ติดต่อเรา" คุณคาดหวังว่าแต่ละเลย์เอาท์จะมีลักษณะและความรู้สึกที่แตกต่างกัน คุณสามารถอ่านเพิ่มเติมเกี่ยวกับเลย์เอาท์ใน [Layouts and Rendering in Rails](layouts_and_rendering.html) guide.

### Partial Layouts

Partial สามารถใช้เลย์เอาท์ของตัวเองได้ ลักษณะเลย์เอาท์เหล่านี้แตกต่างจากเลย์เอาท์ที่ใช้กับการดำเนินการของคอนโทรลเลอร์ แต่พวกเขาทำงานในลักษณะที่คล้ายกัน

เราสมมุติว่าเรากำลังแสดงบทความบนหน้าเว็บซึ่งควรจะถูกห่อหุ้มด้วย `div` เพื่อเป็นวัตถุประสงค์ในการแสดงผล ก่อนอื่น เราจะสร้าง `Article` ใหม่:

```ruby
Article.create(body: 'Partial Layouts are cool!')
```

ใน template `show` เราจะแสดงผล partial `_article` ที่ถูกห่อหุ้มด้วยเลย์เอาท์ `box`:

**articles/show.html.erb**

```erb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

เลย์เอาท์ `box` จะห่อหุ้ม partial `_article` ด้วย `div`:

**articles/_box.html.erb**

```html+erb
<div class='box'>
  <%= yield %>
</div>
```

โปรดทราบว่า partial layout สามารถเข้าถึงตัวแปร local `article` ที่ถูกส่งเข้าไปในการเรียกใช้ `render` อย่างไรก็ตาม ไม่เช่นนั้น เหมือนกับเลย์เอาท์ทั่วไปในแอปพลิเคชัน แต่ partial layout ยังคงมีคำนำหน้าด้วยเครื่องหมาย underscore

คุณยังสามารถแสดงผลบล็อกของโค้ดภายใน partial layout แทนการเรียกใช้ `yield` ตัวอย่างเช่น หากเราไม่มี partial `_article` เราสามารถทำได้ดังนี้:

**articles/show.html.erb**

```html+erb
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

สมมุติว่าเราใช้ partial `_box` เดียวกับตัวอย่างด้านบน สิ่งนี้จะให้ผลลัพธ์เดียวกับตัวอย่างก่อนหน้านี้

View Paths
----------

เมื่อแสดงผลการตอบสนอง คอนโทรลเลอร์จำเป็นต้องแก้ไขที่ตั้งของวิวต่างๆ โดยค่าเริ่มต้น มันจะมองหาในไดเรกทอรี `app/views` เท่านั้น
เราสามารถเพิ่มตำแหน่งอื่น ๆ และกำหนดลำดับความสำคัญให้กับการแก้ไขเส้นทางโดยใช้วิธีการ `prepend_view_path` และ `append_view_path` 

### Prepend View Path

นี้สามารถมีประโยชน์เช่นเมื่อเราต้องการวางวิวภายในไดเรกทอรีที่แตกต่างกันสำหรับโดเมนย่อย

เราสามารถทำได้โดยใช้:

```ruby
prepend_view_path "app/views/#{request.subdomain}"
```

จากนั้น Action View จะค้นหาในไดเรกทอรีนี้ก่อนเมื่อแก้ไขวิว

### Append View Path

เช่นเดียวกัน เราสามารถเพิ่มเส้นทางได้:

```ruby
append_view_path "app/views/direct"
```

นี้จะเพิ่ม `app/views/direct` ไปยังสิ้นสุดของเส้นทางการค้นหา

Helpers
-------

Rails มีเมธอดช่วยเหลือมากมายที่ใช้กับ Action View ซึ่งรวมถึงเมธอดสำหรับ:

* จัดรูปแบบวันที่ เป็นต้น
* สร้างลิงก์ HTML ไปยังรูปภาพ วิดีโอ สไตล์ชีต เป็นต้น
* ทำความสะอาดเนื้อหา
* สร้างแบบฟอร์ม
* จัดการเนื้อหาในภาษาท้องถิ่น

คุณสามารถเรียนรู้เพิ่มเติมเกี่ยวกับ helpers ใน [Action View Helpers
Guide](action_view_helpers.html) และ [Action View Form Helpers
Guide](form_helpers.html).

Localized Views
---------------

Action View สามารถแสดงเทมเพลตที่แตกต่างกันไปขึ้นอยู่กับภาษาปัจจุบันได้

ตัวอย่างเช่น สมมติว่าคุณมี `ArticlesController` ที่มีการดำเนินการแสดงผล โดยค่าเริ่มต้นการเรียกใช้การดำเนินการนี้จะแสดงผล `app/views/articles/show.html.erb` แต่ถ้าคุณตั้งค่า `I18n.locale = :de` แล้ว `app/views/articles/show.de.html.erb` จะถูกแสดงแทน หากไม่มีเทมเพลตที่แปลงภาษาให้ใช้ จะใช้เทมเพลตที่ไม่มีการตกแต่งแทน นั่นหมายความว่าคุณไม่จำเป็นต้องให้เทมเพลตที่แปลงภาษาสำหรับทุกกรณี แต่ถ้ามีจะถูกใช้งานและใช้งานได้

คุณสามารถใช้เทคนิคเดียวกันเพื่อแปลภาษาไฟล์ช่วยเหลือในไดเรกทอรีสาธารณะของคุณ ตัวอย่างเช่น การตั้งค่า `I18n.locale = :de` และการสร้าง `public/500.de.html` และ `public/404.de.html` จะช่วยให้คุณมีหน้าช่วยเหลือที่แปลภาษาได้

เนื่องจาก Rails ไม่จำกัดสัญลักษณ์ที่คุณใช้ในการตั้งค่า I18n.locale คุณสามารถใช้ระบบนี้เพื่อแสดงเนื้อหาที่แตกต่างกันขึ้นอยู่กับอะไรก็ได้ที่คุณชอบ ตัวอย่างเช่น สมมติว่าคุณมีผู้ใช้ "ผู้เชี่ยวชาญ" บางคนที่ควรเห็นหน้าเพจที่แตกต่างกันจากผู้ใช้ "ปกติ" คุณสามารถเพิ่มส่วนต่อไปนี้ใน `app/controllers/application_controller.rb`:

```ruby
before_action :set_expert_locale

def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
```

จากนั้นคุณสามารถสร้างวิวพิเศษเช่น `app/views/articles/show.expert.html.erb` ซึ่งจะแสดงเฉพาะผู้ใช้ที่เชี่ยวชาญ

คุณสามารถอ่านเพิ่มเติมเกี่ยวกับ Rails Internationalization (I18n) API [ที่นี่](i18n.html)
