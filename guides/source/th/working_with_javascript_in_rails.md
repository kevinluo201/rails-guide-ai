**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c1e56036aa9fd68276daeec5a9407096
การทำงานกับ JavaScript ใน Rails
================================

เอกสารนี้เป็นคู่มือเกี่ยวกับตัวเลือกในการรวมฟังก์ชัน JavaScript เข้ากับแอปพลิเคชัน Rails ของคุณ รวมถึงตัวเลือกในการใช้แพ็คเกจ JavaScript จากภายนอกและวิธีการใช้ Turbo กับ Rails

หลังจากอ่านคู่มือนี้คุณจะรู้:

* วิธีการใช้ Rails โดยไม่ต้องใช้ Node.js, Yarn หรือ JavaScript bundler
* วิธีการสร้างแอปพลิเคชัน Rails ใหม่โดยใช้ import maps, esbuild, rollup หรือ webpack เพื่อรวม JavaScript ของคุณ
* Turbo คืออะไรและวิธีการใช้
* วิธีการใช้ Turbo HTML helpers ที่ Rails จัดหาให้

--------------------------------------------------------------------------------

Import Maps
-----------

[Import maps](https://github.com/rails/importmap-rails) ช่วยให้คุณสามารถนำเข้าโมดูล JavaScript โดยใช้ชื่อตรรกะที่แมปกับไฟล์ที่มีเวอร์ชันได้เลยจากเบราว์เซอร์  Import maps เป็นค่าเริ่มต้นใน Rails 7 ซึ่งช่วยให้ทุกคนสามารถสร้างแอปพลิเคชัน JavaScript ที่ใช้แพคเกจ NPM สมัยใหม่โดยไม่ต้องทำการ transpiling หรือ bundling

แอปพลิเคชันที่ใช้ import maps ไม่ต้องการ [Node.js](https://nodejs.org/en/) หรือ [Yarn](https://yarnpkg.com/) เพื่อให้ทำงาน หากคุณวางแผนที่จะใช้ Rails กับ `importmap-rails` เพื่อจัดการความขึ้นต่อกันของ JavaScript ของคุณ ไม่จำเป็นต้องติดตั้ง Node.js หรือ Yarn

เมื่อใช้ import maps ไม่ต้องมีกระบวนการสร้างแยกต่างหาก แค่เริ่มเซิร์ฟเวอร์ของคุณด้วย `bin/rails server` แล้วคุณก็พร้อมที่จะเริ่มต้นได้

### การติดตั้ง importmap-rails

Importmap สำหรับ Rails รวมอยู่ใน Rails 7+ สำหรับแอปพลิเคชันใหม่ แต่คุณยังสามารถติดตั้งเองในแอปพลิเคชันที่มีอยู่:

```bash
$ bin/bundle add importmap-rails
```

เรียกใช้งานงานติดตั้ง:

```bash
$ bin/rails importmap:install
```

### เพิ่มแพคเกจ NPM ด้วย importmap-rails

ในการเพิ่มแพคเกจใหม่ในแอปพลิเคชันที่ใช้ import map ให้รันคำสั่ง `bin/importmap pin` จากเทอร์มินัลของคุณ:

```bash
$ bin/importmap pin react react-dom
```

จากนั้นนำเข้าแพคเกจเข้าไปใน `application.js` เหมือนเคย:

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

การเพิ่มแพคเกจ NPM ด้วย JavaScript Bundlers
--------

Import maps เป็นค่าเริ่มต้นสำหรับแอปพลิเคชัน Rails ใหม่ แต่หากคุณต้องการใช้การรวม JavaScript แบบดั้งเดิมคุณสามารถสร้างแอปพลิเคชัน Rails ใหม่ด้วยตัวเลือกที่คุณต้องการ เช่น [esbuild](https://esbuild.github.io/), [webpack](https://webpack.js.org/) หรือ [rollup.js](https://rollupjs.org/guide/en/)

ในการใช้ bundler แทน import maps ในแอปพลิเคชัน Rails ใหม่ ให้ใช้ตัวเลือก `—javascript` หรือ `-j` กับ `rails new`:

```bash
$ rails new my_new_app --javascript=webpack
หรือ
$ rails new my_new_app -j webpack
```

ตัวเลือกการรวมเหล่านี้มาพร้อมกับการกำหนดค่าง่าย และการรวมเข้ากับ asset pipeline ผ่าน gem [jsbundling-rails](https://github.com/rails/jsbundling-rails)

เมื่อใช้ตัวเลือกการรวม ให้ใช้ `bin/dev` เพื่อเริ่มเซิร์ฟเวอร์ Rails และสร้าง JavaScript สำหรับการพัฒนา

### การติดตั้ง Node.js และ Yarn

หากคุณใช้ JavaScript bundler ในแอปพลิเคชัน Rails ของคุณ จะต้องติดตั้ง Node.js และ Yarn

ค้นหาคำแนะนำการติดตั้งที่เว็บไซต์ [Node.js](https://nodejs.org/en/download/) และตรวจสอบว่าติดตั้งถูกต้องด้วยคำสั่งต่อไปนี้:

```bash
$ node --version
```

เวอร์ชันของ Node.js ของคุณควรถูกพิมพ์ออกมา ตรวจสอบให้แน่ใจว่ามากกว่า `8.16.0`

ในการติดตั้ง Yarn สามารถทำตามคำแนะนำการติดตั้งที่เว็บไซต์ [Yarn](https://classic.yarnpkg.com/en/docs/install) การรันคำสั่งนี้ควรพิมพ์เวอร์ชัน Yarn ออกมา:

```bash
$ yarn --version
```

หากมีข้อความประมาณว่า `1.22.0` แสดงว่า Yarn ถูกติดตั้งอย่างถูกต้อง

การเลือกระหว่าง Import Maps และ JavaScript Bundler
-----------------------------------------------------
เมื่อคุณสร้างแอปพลิเคชัน Rails ใหม่ คุณจะต้องเลือกระหว่าง import maps และการรวม JavaScript แบบอื่น ๆ ทุกแอปพลิเคชันมีความต้องการที่แตกต่างกันและคุณควรพิจารณาความต้องการของคุณอย่างรอบคอบก่อนเลือกตัวเลือก JavaScript เนื่องจากการย้ายจากตัวเลือกหนึ่งไปยังอีกตัวเลือกหนึ่งอาจใช้เวลานานสำหรับแอปพลิเคชันที่ซับซ้อนและใหญ่

Import maps เป็นตัวเลือกเริ่มต้นเนื่องจากทีม Rails เชื่อในศักยภาพของ import maps ในการลดความซับซ้อน ปรับปรุงประสบการณ์การพัฒนาและส่งผลให้ได้ประสิทธิภาพที่ดีขึ้น

สำหรับแอปพลิเคชันหลายรายการ โดยเฉพาะอย่างยิ่งรายการที่พึ่งพาบนสแต็ก [Hotwire](https://hotwired.dev/) สำหรับความต้องการ JavaScript ของพวกเขา import maps จะเป็นตัวเลือกที่เหมาะสมในระยะยาว คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับเหตุผลที่ทำให้ import maps เป็นค่าเริ่มต้นใน Rails 7 ได้ที่นี่ (https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b).

แอปพลิเคชันอื่น ๆ อาจยังต้องการตัวรวม JavaScript แบบดั้งเดิม ความต้องการที่แสดงให้เห็นว่าคุณควรเลือกตัวรวมแบบดั้งเดิมรวมถึง:

* หากโค้ดของคุณต้องการขั้นตอนการแปลงรูป เช่น JSX หรือ TypeScript
* หากคุณต้องการใช้ไลบรารี JavaScript ที่รวม CSS หรือพฤติกรรมอื่น ๆ ที่พึ่งพา [Webpack loaders](https://webpack.js.org/loaders/)
* หากคุณแน่ใจแน่นอนว่าคุณต้องการ [tree-shaking](https://webpack.js.org/guides/tree-shaking/)
* หากคุณติดตั้ง Bootstrap, Bulma, PostCSS หรือ Dart CSS ผ่าน [cssbundling-rails gem](https://github.com/rails/cssbundling-rails) ตัวเลือกทั้งหมดที่ให้โดย gem นี้ยกเว้น Tailwind และ Sass จะติดตั้ง `esbuild` ให้คุณโดยอัตโนมัติหากคุณไม่ระบุตัวเลือกอื่นใน `rails new`

Turbo
-----

ไม่ว่าคุณจะเลือก import maps หรือตัวรวม JavaScript แบบดั้งเดิม Rails จะมาพร้อมกับ [Turbo](https://turbo.hotwired.dev/) เพื่อเพิ่มความเร็วให้แอปพลิเคชันของคุณพร้อมลดจำนวน JavaScript ที่คุณต้องเขียนอย่างมาก

Turbo ช่วยให้เซิร์ฟเวอร์ส่ง HTML โดยตรงเป็นทางเลือกที่แทนที่เฟรมเวิร์กด้านหน้าที่ลดฝั่งเซิร์ฟเวอร์ของแอปพลิเคชัน Rails ของคุณให้เหลือเพียง JSON API เท่านั้น

### Turbo Drive

[Turbo Drive](https://turbo.hotwired.dev/handbook/drive) เพิ่มความเร็วในการโหลดหน้าโดยหลีกเลี่ยงการสร้างและสร้างใหม่ของหน้าเต็มทุกคำขอการนำทาง Turbo Drive เป็นการปรับปรุงและแทนที่ Turbolinks

### Turbo Frames

[Turbo Frames](https://turbo.hotwired.dev/handbook/frames) ช่วยให้ส่วนที่กำหนดไว้ล่วงหน้าของหน้าถูกอัปเดตตามคำขอโดยไม่มีผลต่อเนื้อหาของส่วนที่เหลือของหน้า

คุณสามารถใช้ Turbo Frames เพื่อสร้างการแก้ไขในตำแหน่งโดยไม่ต้องใช้ JavaScript ที่กำหนดเอง โหลดเนื้อหาแบบล่าช้า และสร้างอินเทอร์เฟซแท็บที่มีการเรนเดอร์บนเซิร์ฟเวอร์ได้อย่างง่ายดาย

Rails มี HTML helpers เพื่อทำให้ใช้ Turbo Frames ง่ายขึ้นผ่าน gem [turbo-rails](https://github.com/hotwired/turbo-rails)

โดยใช้ gem นี้คุณสามารถเพิ่ม Turbo Frame เข้าสู่แอปพลิเคชันของคุณด้วยตัวช่วย `turbo_frame_tag` เช่นนี้:

```erb
<%= turbo_frame_tag dom_id(post) do %>
  <div>
     <%= link_to post.title, post_path(post) %>
  </div>
<% end %>
```

### Turbo Streams

[Turbo Streams](https://turbo.hotwired.dev/handbook/streams) ส่งการเปลี่ยนแปลงของหน้าเป็นส่วนของ HTML ที่ถูกห่อหุ้มในองค์ประกอบ `<turbo-stream>` ที่ประมวลผลเอง Turbo Streams ช่วยให้คุณสามารถแพร่กระจายการเปลี่ยนแปลงที่ผู้ใช้คนอื่นทำผ่าน WebSockets และอัปเดตส่วนของหน้าหลังจากการส่งฟอร์มโดยไม่ต้องโหลดหน้าทั้งหมด

Rails มี HTML และ server-side helpers เพื่อทำให้ใช้ Turbo Streams ง่ายขึ้นผ่าน gem [turbo-rails](https://github.com/hotwired/turbo-rails)

โดยใช้ gem นี้คุณสามารถเรนเดอร์ Turbo Streams จากการกระทำของคอนโทรลเลอร์:

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```
Rails จะค้นหาไฟล์ `.turbo_stream.erb` และเรียกใช้งานไฟล์ดังกล่าวเมื่อพบ

การตอบกลับ Turbo Stream ยังสามารถเรียกใช้งานใน controller action ได้ดังนี้:

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream { render turbo_stream: turbo_stream.prepend('posts', partial: 'post') }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

สุดท้าย Turbo Streams สามารถเริ่มต้นจาก model หรือ background job โดยใช้ helper ที่มีอยู่ในระบบ
การกระจายสัญญาณเหล่านี้สามารถใช้ในการอัปเดตเนื้อหาผ่านการเชื่อมต่อ WebSocket ไปยังผู้ใช้ทั้งหมด เพื่อให้เนื้อหาของหน้าเว็บปรับปรุงและทำให้แอปพลิเคชันของคุณมีชีวิตชีวา

ในการกระจายสัญญาณ Turbo Stream จาก model สามารถรวม callback ของ model ได้ดังนี้:

```ruby
class Post < ApplicationRecord
  after_create_commit { broadcast_append_to('posts') }
end
```

พร้อมกับการตั้งค่าการเชื่อมต่อ WebSocket ในหน้าที่ควรรับการอัปเดตดังนี้:

```erb
<%= turbo_stream_from "posts" %>
```

การแทนที่ฟังก์ชันของ Rails/UJS
----------------------------------------

Rails 6 มาพร้อมกับเครื่องมือที่เรียกว่า UJS (Unobtrusive JavaScript) UJS ช่วยให้นักพัฒนาสามารถแทนที่วิธีการร้องขอ HTTP ของแท็ก `<a>` เพื่อเพิ่มกล่องโต้ตอบการยืนยันก่อนดำเนินการและอื่น ๆ UJS เป็นค่าเริ่มต้นก่อน Rails 7 แต่ขณะนี้แนะนำให้ใช้ Turbo แทน

### Method

การคลิกลิงก์เสมอจะส่งคำขอ HTTP GET หากแอปพลิเคชันของคุณเป็น [RESTful](https://en.wikipedia.org/wiki/Representational_State_Transfer) ลิงก์บางอย่างจริง ๆ เป็นการกระทำที่เปลี่ยนข้อมูลบนเซิร์ฟเวอร์และควรดำเนินการด้วยคำขอที่ไม่ใช่ GET แอตทริบิวต์ `data-turbo-method` ช่วยให้สามารถทำเครื่องหมายลิงก์เหล่านี้ด้วยวิธีการที่ชัดเจน เช่น "post", "put", หรือ "delete"

Turbo จะสแกนแท็ก `<a>` ในแอปพลิเคชันของคุณเพื่อหาแอตทริบิวต์ข้อมูล `turbo-method` และใช้วิธีการที่ระบุเมื่อมีการระบุ แทนที่การกระทำ GET เริ่มต้น

ตัวอย่าง:

```erb
<%= link_to "Delete post", post_path(post), data: { turbo_method: "delete" } %>
```

สร้าง:

```html
<a data-turbo-method="delete" href="...">Delete post</a>
```

วิธีทดแทนที่วิธีการของลิงก์ด้วย `data-turbo-method` คือใช้ตัวช่วย `button_to` ของ Rails เพื่อเป็นทางเลือกที่ดีกว่าเพื่อเหตุผลด้านการเข้าถึง ปุ่มและแบบฟอร์มจริงๆ เหมาะสำหรับการกระทำที่ไม่ใช่ GET

### Confirmations

คุณสามารถขอการยืนยันเพิ่มเติมจากผู้ใช้ได้โดยเพิ่มแอตทริบิวต์ `data-turbo-confirm` ในลิงก์และแบบฟอร์ม เมื่อคลิกลิงก์หรือส่งแบบฟอร์ม ผู้ใช้จะได้รับกล่องโต้ตอบ `confirm()` ที่มีข้อความจากแอตทริบิวต์ หากผู้ใช้เลือกยกเลิก การดำเนินการจะไม่เกิดขึ้น

ตัวอย่างด้วยตัวช่วย `link_to`:

```erb
<%= link_to "Delete post", post_path(post), data: { turbo_method: "delete", turbo_confirm: "Are you sure?" } %>
```

สร้าง:

```html
<a href="..." data-turbo-confirm="Are you sure?" data-turbo-method="delete">Delete post</a>
```

เมื่อผู้ใช้คลิกที่ลิงก์ "Delete post" จะปรากฏกล่องโต้ตอบ "Are you sure?" 

แอตทริบิวต์ยังสามารถใช้กับตัวช่วย `button_to` ได้ แต่ต้องเพิ่มในแบบฟอร์มที่ `button_to` สร้างขึ้นภายใน:

```erb
<%= button_to "Delete post", post, method: :delete, form: { data: { turbo_confirm: "Are you sure?" } } %>
```

### การร้องขอ Ajax

เมื่อทำการร้องขอที่ไม่ใช่ GET จาก JavaScript จำเป็นต้องมีส่วนหัว `X-CSRF-Token` หากไม่มีส่วนหัวนี้ คำขอจะไม่ได้รับการยอมรับจาก Rails
หมายเหตุ: โทเค็นนี้จำเป็นสำหรับ Rails เพื่อป้องกันการโจมตี Cross-Site Request Forgery (CSRF) อ่านเพิ่มเติมใน[คู่มือด้านความปลอดภัย](security.html#cross-site-request-forgery-csrf) 

[Rails Request.JS](https://github.com/rails/request.js) ห่อหุ้มตรรกะในการเพิ่มส่วนตรงของคำขอที่จำเป็นตามที่ Rails ต้องการ แค่นำเข้าคลาส `FetchRequest` จากแพ็คเกจแล้วสร้างอ็อบเจ็กต์โดยส่งวิธีการขอคำขอ  URL และตัวเลือก จากนั้นเรียกใช้ `await request.perform()` และทำสิ่งที่คุณต้องการกับการตอบสนอง

ตัวอย่าง:

```javascript
import { FetchRequest } from '@rails/request.js'

....

async myMethod () {
  const request = new FetchRequest('post', 'localhost:3000/posts', {
    body: JSON.stringify({ name: 'Request.JS' })
  })
  const response = await request.perform()
  if (response.ok) {
    const body = await response.text
  }
}
```

เมื่อใช้ไลบรารีอื่นในการทำการเรียก Ajax จำเป็นต้องเพิ่มโทเค็นความปลอดภัยเป็นส่วนหัวเริ่มต้นด้วยตัวเอง ในการรับโทเค็น ดูที่แท็ก `<meta name='csrf-token' content='THE-TOKEN'>` ที่พิมพ์โดย [`csrf_meta_tags`][] ในมุมมองแอปพลิเคชันของคุณ คุณสามารถทำอย่างนี้:

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
