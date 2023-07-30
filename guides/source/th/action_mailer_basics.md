**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 390d20a8bee6232c0ffa7faeb0e9d8e8
พื้นฐานของ Action Mailer
====================

เอกสารนี้จะให้คุณทราบทุกสิ่งที่คุณต้องการเพื่อเริ่มส่งอีเมลจากแอปพลิเคชันของคุณและภายในของ Action Mailer นอกจากนี้ยังครอบคลุมวิธีการทดสอบ mailer ของคุณ

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีการส่งอีเมลภายในแอปพลิเคชัน Rails
* วิธีการสร้างและแก้ไขคลาส Action Mailer และ mailer view
* วิธีการกำหนดค่า Action Mailer สำหรับสภาพแวดล้อมของคุณ
* วิธีการทดสอบคลาส Action Mailer ของคุณ

--------------------------------------------------------------------------------

Action Mailer คืออะไร?
----------------------

Action Mailer ช่วยให้คุณสามารถส่งอีเมลจากแอปพลิเคชันของคุณโดยใช้คลาส mailer และ views

### Mailer คล้ายกับ Controller

Mailer สืบทอดมาจาก [`ActionMailer::Base`][] และอยู่ใน `app/mailers` นอกจากนี้ Mailer ยังทำงานอย่างคล้ายคลึงกับ Controller ตัวอย่างบางส่วนของความคล้ายคลึงคือ:

* มี Actions และยังมี views ที่เกิดขึ้นใน `app/views`
* ตัวแปร Instance ที่สามารถเข้าถึงได้ใน views
* สามารถใช้ layouts และ partials ได้
* สามารถเข้าถึง params hash ได้

การส่งอีเมล
--------------

ส่วนนี้จะให้คำแนะนำขั้นตอนการสร้าง mailer และ views

### การสร้าง Mailer

#### สร้าง Mailer

```bash
$ bin/rails generate mailer User
create  app/mailers/user_mailer.rb
create  app/mailers/application_mailer.rb
invoke  erb
create    app/views/user_mailer
create    app/views/layouts/mailer.text.erb
create    app/views/layouts/mailer.html.erb
invoke  test_unit
create    test/mailers/user_mailer_test.rb
create    test/mailers/previews/user_mailer_preview.rb
```

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout 'mailer'
end
```

```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
end
```

เห็นได้ว่าคุณสามารถสร้าง mailer เหมือนกับการใช้ generator อื่น ๆ กับ Rails

หากคุณไม่ต้องการใช้ generator คุณสามารถสร้างไฟล์ของคุณเองภายใน `app/mailers` แต่ต้องแน่ใจว่ามันสืบทอดมาจาก `ActionMailer::Base`:

```ruby
class MyMailer < ActionMailer::Base
end
```

#### แก้ไข Mailer

Mailer มีเมธอดที่เรียกว่า "actions" และใช้ views เพื่อกำหนดโครงสร้างเนื้อหาของมัน ที่ Controller สร้างเนื้อหาเช่น HTML เพื่อส่งกลับไปยังไคลเอนต์ Mailer สร้างข้อความเพื่อส่งผ่านทางอีเมล
`app/mailers/user_mailer.rb` มี mailer ที่ว่างเปล่า:

```ruby
class UserMailer < ApplicationMailer
end
```

ให้เราเพิ่มเมธอดที่เรียกว่า `welcome_email` ซึ่งจะส่งอีเมลไปยังที่อยู่อีเมลที่ลงทะเบียนของผู้ใช้:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'ยินดีต้อนรับสู่เว็บไซต์ที่ยอดเยี่ยมของฉัน')
  end
end
```

นี่คือคำอธิบายอย่างรวดเร็วของรายการที่แสดงในเมธอดก่อนหน้านี้ สำหรับรายการทั้งหมดที่มีอยู่ โปรดดูที่ส่วนรายการที่กำหนดไว้ใน Action Mailer user-settable attributes.

* เมธอด [`default`][] ตั้งค่าค่าเริ่มต้นสำหรับอีเมลทั้งหมดที่ส่งจาก mailer นี้ ในกรณีนี้เราใช้มันเพื่อตั้งค่าค่า `:from` สำหรับข้อความทั้งหมดในคลาสนี้ สามารถเขียนทับได้ตามแต่ละอีเมล
* เมธอด [`mail`][] สร้างข้อความอีเมลจริง ในที่นี้เราใช้มันเพื่อระบุค่าของส่วนหัวเช่น `:to` และ `:subject` ต่ออีเมลละ

#### สร้างมุมมองของ Mailer

สร้างไฟล์ที่เรียกว่า `welcome_email.html.erb` ใน `app/views/user_mailer/` นี้จะเป็นเทมเพลตที่ใช้สำหรับอีเมล รูปแบบเป็น HTML:

```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>ยินดีต้อนรับสู่ example.com, <%= @user.name %></h1>
    <p>
      คุณได้ลงทะเบียนเข้าใช้ example.com สำเร็จแล้ว
      ชื่อผู้ใช้ของคุณคือ: <%= @user.login %>.<br>
    </p>
    <p>
      เพื่อเข้าสู่ระบบเว็บไซต์ โปรดตามลิงก์นี้: <%= @url %>.
    </p>
    <p>ขอบคุณที่เข้าร่วมและขอให้คุณมีวันที่ดี!</p>
  </body>
</html>
```

เรายังต้องสร้างส่วนข้อความสำหรับอีเมลนี้ด้วย ไม่ใช่ทุกไคลเอ็นต์ชอบอีเมล HTML ดังนั้นการส่งทั้งสองแบบจึงเป็นที่นิยม ในการทำเช่นนี้ ให้สร้างไฟล์ที่เรียกว่า `welcome_email.text.erb` ใน `app/views/user_mailer/`:

```erb
ยินดีต้อนรับสู่ example.com, <%= @user.name %>
===============================================

คุณได้ลงทะเบียนเข้าใช้ example.com สำเร็จแล้ว
ชื่อผู้ใช้ของคุณคือ: <%= @user.login %>.

เพื่อเข้าสู่ระบบเว็บไซต์ โปรดตามลิงก์นี้: <%= @url %>.

ขอบคุณที่เข้าร่วมและขอให้คุณมีวันที่ดี!
```
เมื่อคุณเรียกใช้เมธอด `mail` ตอนนี้ Action Mailer จะตรวจจับเทมเพลตสองรูปแบบ (ข้อความและ HTML) และสร้างอีเมล `multipart/alternative` โดยอัตโนมัติ

#### เรียกใช้ Mailer

Mailer นั้นเป็นวิธีการแสดงผลวิวอีกวิธีหนึ่ง แตกต่างจากการแสดงผลวิวและส่งผ่านโปรโตคอล HTTP แทนที่จะส่งผ่านโปรโตคอลอีเมล ด้วยเหตุนี้ จึงเหมาะสมที่จะให้คอนโทรลเลอร์บอก Mailer ให้ส่งอีเมลเมื่อผู้ใช้ถูกสร้างสำเร็จ

การตั้งค่านี้ง่ายดาย

ก่อนอื่นเราจะสร้าง scaffold `User`:

```bash
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

ตอนนี้เรามีโมเดลผู้ใช้ที่จะใช้เล่น จากนั้นเราจะแก้ไขไฟล์ `app/controllers/users_controller.rb` ให้คอนโทรลเลอร์บอก `UserMailer` ให้ส่งอีเมลไปยังผู้ใช้ที่ถูกสร้างขึ้นใหม่โดยแก้ไขแอ็กชัน create และแทรกการเรียก `UserMailer.with(user: @user).welcome_email` ตามหลังการบันทึกผู้ใช้สำเร็จ

เราจะเพิ่มอีเมลให้ส่งไปในคิวโดยใช้ [`deliver_later`][] ซึ่งมีการสนับสนุนจาก Active Job ดังนั้นแอ็กชันของคอนโทรลเลอร์สามารถดำเนินการต่อไปได้โดยไม่ต้องรอให้การส่งเสร็จสิ้น

```ruby
class UsersController < ApplicationController
  # ...

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # บอก UserMailer ให้ส่งอีเมลต้อนรับหลังจากบันทึกสำเร็จ
        UserMailer.with(user: @user).welcome_email.deliver_later

        format.html { redirect_to(@user, notice: 'User was successfully created.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # ...
end
```

หมายเหตุ: พฤติกรรมเริ่มต้นของ Active Job คือการดำเนินการงานผ่านตัวอ่าน `:async` ดังนั้นคุณสามารถใช้ `deliver_later` เพื่อส่งอีเมลแบบไม่รอให้ส่งเสร็จสิ้น
ตัวอ่านเริ่มต้นของ Active Job จะเรียกใช้งานงานด้วยเธรดในกระบวนการ มันเหมาะสำหรับสภาพแวดล้อมการพัฒนา/ทดสอบ เนื่องจากไม่ต้องใช้โครงสร้างพื้นฐานภายนอก แต่ไม่เหมาะสำหรับการใช้งานจริง เนื่องจากมันจะละงานที่รออยู่เมื่อเริ่มต้นใหม่
หากคุณต้องการแบ็กเอนด์ที่ต่อเนื่องคุณจะต้องใช้ตัวอ่าน Active Job ที่มีแบ็กเอนด์ที่ต่อเนื่อง (เช่น Sidekiq, Resque, เป็นต้น)
หากคุณต้องการส่งอีเมลทันที (เช่นจาก cronjob) เพียงแค่เรียกใช้ [`deliver_now`][]:

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```

คู่คีย์-ค่าใดๆที่ถูกส่งผ่านไปยัง [`with`][] จะกลายเป็น `params` สำหรับการกระทำของเมลเลอร์
ดังนั้น `with(user: @user, account: @user.account)` จะทำให้ `params[:user]` และ `params[:account]` สามารถใช้ได้ในการกระทำของเมลเลอร์เหมือนกับการใช้ params ในคอนโทรลเลอร์

เมธอด `welcome_email` จะส่งกลับ [`ActionMailer::MessageDelivery`][] ซึ่งสามารถใช้ `deliver_now` หรือ `deliver_later` เพื่อส่งอีเมลได้เอง
`ActionMailer::MessageDelivery` เป็นตัวห่อหุ้มของ [`Mail::Message`][] หากคุณต้องการตรวจสอบ แก้ไข หรือดำเนินการอื่นๆกับ `Mail::Message` คุณสามารถเข้าถึงได้โดยใช้เมธอด [`message`][] บนอ็อบเจกต์ `ActionMailer::MessageDelivery`


### การเข้ารหัสหัวข้ออัตโนมัติ

Action Mailer จัดการการเข้ารหัสอัตโนมัติของอักขระหลายไบต์ภายในหัวข้อและเนื้อหา

สำหรับตัวอย่างที่ซับซ้อนกว่า เช่นการกำหนดชุดอักขระที่แตกต่างหรือการเข้ารหัสข้อความที่เข้ารหัสเอง โปรดอ้างอิงไปที่ไลบรารี
[Mail](https://github.com/mikel/mail) library.

### รายการเมธอด Action Mailer ทั้งหมด

มีเพียงสามเมธอดที่คุณต้องการส่งอีเมลเกือบทุกข้อความ:

* [`headers`][] - ระบุส่วนหัวใดๆในอีเมลที่คุณต้องการ คุณสามารถส่งผ่านแฮชของชื่อฟิลด์และคู่ค่าค่าได้ หรือคุณสามารถเรียกใช้ `headers[:field_name] = 'value'` ได้
* [`attachments`][] - ช่วยให้คุณเพิ่มไฟล์แนบในอีเมลของคุณ เช่น `attachments['file-name.jpg'] = File.read('file-name.jpg')`
* [`mail`][] - สร้างอีเมลจริงๆ คุณสามารถส่ง headers เป็นแฮชไปยังเมธอด `mail` เป็นพารามิเตอร์  `mail` จะสร้างอีเมล - อย่างเป็นข้อความธรรมดาหรือหลายส่วน - ขึ้นอยู่กับเทมเพลตอีเมลที่คุณกำหนด


#### เพิ่มไฟล์แนบ

Action Mailer ทำให้ง่ายมากในการเพิ่มไฟล์แนบ

* ส่งชื่อไฟล์และเนื้อหาไปยัง Action Mailer และ [Mail gem](https://github.com/mikel/mail) จะเดา `mime_type`, ตั้งค่า `encoding` และสร้างไฟล์แนบโดยอัตโนมัติ
```ruby
attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
```

เมื่อเรียกใช้เมธอด `mail` จะส่งอีเมลแบบมีส่วนประกอบหลายส่วนพร้อมแนบไฟล์แนบ โดยจัดลำดับให้ส่วนบนสุดเป็น `multipart/mixed` และส่วนแรกเป็น `multipart/alternative` ที่ประกอบด้วยข้อความอีเมลแบบข้อความธรรมดาและ HTML

หมายเหตุ: Mail จะทำการเข้ารหัส Base64 อัตโนมัติสำหรับไฟล์แนบ หากคุณต้องการอย่างอื่น คุณสามารถเข้ารหัสเนื้อหาของคุณและส่งเนื้อหาที่เข้ารหัสและการเข้ารหัสเป็น `Hash` ไปยังเมธอด `attachments`

* ส่งชื่อไฟล์และระบุส่วนหัวและเนื้อหาใน Action Mailer และ Mail จะใช้การตั้งค่าที่คุณส่งไป

```ruby
encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
attachments['filename.jpg'] = {
  mime_type: 'application/gzip',
  encoding: 'SpecialEncoding',
  content: encoded_content
}
```

หมายเหตุ: หากคุณระบุการเข้ารหัส Mail จะถือว่าเนื้อหาของคุณถูกเข้ารหัสแล้วและไม่พยายามเข้ารหัส Base64

#### การสร้างไฟล์แนบแบบ Inline

Action Mailer 3.0 ทำให้การสร้างไฟล์แนบแบบ Inline ที่ใช้การแฮ็กกิ้งมาก่อนเวอร์ชัน 3.0 ง่ายและเรียบง่ายมากขึ้น

* ก่อนอื่น เพื่อบอก Mail ให้แปลงไฟล์แนบเป็นไฟล์แนบแบบ Inline คุณเพียงเรียกใช้ `#inline` บนเมธอด attachments ภายใน Mailer ของคุณ:

```ruby
def welcome
  attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
end
```

* จากนั้นในหน้าต่างของคุณ คุณสามารถอ้างอิง attachments เป็นแฮชและระบุไฟล์แนบที่คุณต้องการแสดง โดยเรียกใช้ `url` บนมันแล้วส่งผลลัพธ์เข้าไปในเมธอด `image_tag`:

```html+erb
<p>Hello there, this is our image</p>

<%= image_tag attachments['image.jpg'].url %>
```

* เนื่องจากนี่เป็นการเรียกใช้ `image_tag` มาตรฐาน คุณสามารถส่งเข้าไปในแฮชตัวเลือกหลัง URL ของไฟล์แนบเหมือนกับรูปภาพอื่น ๆ:

```html+erb
<p>Hello there, this is our image</p>

<%= image_tag attachments['image.jpg'].url, alt: 'My Photo', class: 'photos' %>
```

#### การส่งอีเมลถึงผู้รับหลายคน

คุณสามารถส่งอีเมลถึงผู้รับหลายคนในอีเมลเดียวกัน (เช่น แจ้งเตือนผู้ดูแลระบบทั้งหมดเมื่อมีการลงทะเบียนใหม่) โดยการตั้งค่ารายชื่ออีเมลในคีย์ `:to` รายชื่ออีเมลสามารถเป็นอาร์เรย์ของที่อยู่อีเมลหรือสตริงเดียวที่มีที่อยู่อีเมลคั่นด้วยจุลภาค
```ruby
class AdminMailer < ApplicationMailer
  default to: -> { Admin.pluck(:email) },
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "การลงทะเบียนผู้ใช้ใหม่: #{@user.email}")
  end
end
```

รูปแบบเดียวกันสามารถใช้ในการตั้งค่ารายชื่อผู้รับสำเนา (Cc:) และสำเนาบนบรรทัดเดียวกัน (Bcc:) โดยใช้คีย์ `:cc` และ `:bcc` ตามลำดับ

#### การส่งอีเมลพร้อมชื่อ

บางครั้งคุณอาจต้องการแสดงชื่อของบุคคลแทนที่อย่างเดียวที่อีเมลถูกส่งไปยังบุคคลนั้น คุณสามารถใช้ [`email_address_with_name`][] สำหรับการทำเช่นนั้น:

```ruby
def welcome_email
  @user = params[:user]
  mail(
    to: email_address_with_name(@user.email, @user.name),
    subject: 'ยินดีต้อนรับสู่เว็บไซต์ที่ยอดเยี่ยมของฉัน'
  )
end
```

เทคนิคเดียวกันสามารถใช้ในการระบุชื่อผู้ส่ง:

```ruby
class UserMailer < ApplicationMailer
  default from: email_address_with_name('notification@example.com', 'Example Company Notifications')
end
```

หากชื่อเป็นสตริงที่ว่างเปล่า จะคืนค่าเฉพาะที่อยู่เท่านั้น


### มุมมองของเมลเลอร์

มุมมองของเมลเลอร์ตั้งอยู่ในไดเรกทอรี `app/views/name_of_mailer_class` มุมมองเมลเลอร์ที่เฉพาะเจาะจงรู้จักกับคลาสเนื่องจากชื่อของมันเหมือนกับเมธอดของเมลเลอร์ ในตัวอย่างของเราจากข้างต้น มุมมองเมลเลอร์สำหรับเมธอด `welcome_email` จะอยู่ใน `app/views/user_mailer/welcome_email.html.erb` สำหรับเวอร์ชัน HTML และ `welcome_email.text.erb` สำหรับเวอร์ชันข้อความธรรมดา

หากต้องการเปลี่ยนมุมมองเมลเลอร์เริ่มต้นสำหรับการดำเนินการของคุณ คุณสามารถทำเช่นนี้:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'ยินดีต้อนรับสู่เว็บไซต์ที่ยอดเยี่ยมของฉัน',
         template_path: 'notifications',
         template_name: 'another')
  end
end
```

ในกรณีนี้ มันจะค้นหาเทมเพลตที่ `app/views/notifications` ชื่อ `another` คุณยังสามารถระบุอาร์เรย์ของเส้นทางสำหรับ `template_path` และมันจะถูกค้นหาตามลำดับ

หากคุณต้องการความยืดหยุ่นมากขึ้น คุณยังสามารถส่งบล็อกและเรนเดอร์เทมเพลตที่เฉพาะเจาะจงหรือแม้แต่เรนเดอร์อินไลน์หรือข้อความโดยไม่ใช้ไฟล์เทมเพลต:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'ยินดีต้อนรับสู่เว็บไซต์ที่ยอดเยี่ยมของฉัน') do |format|
      format.html { render 'another_template' }
      format.text { render plain: 'แสดงข้อความ' }
    end
  end
end
```
นี้จะแสดงเทมเพลต 'another_template.html.erb' สำหรับส่วน HTML และใช้ข้อความที่แสดงผลสำหรับส่วนข้อความ คำสั่ง render เป็นคำสั่งเดียวกับที่ใช้ใน Action Controller ดังนั้นคุณสามารถใช้ตัวเลือกเดียวกันทั้งหมด เช่น :text, :inline เป็นต้น

หากคุณต้องการแสดงเทมเพลตที่ตั้งอยู่นอกไดเรกทอรีเริ่มต้น 'app/views/mailer_name/' คุณสามารถใช้ [`prepend_view_path`][] ได้ดังนี้:

```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # นี้จะพยายามโหลดเทมเพลต "custom/path/to/mailer/view/welcome_email"
  def welcome_email
    # ...
  end
end
```

คุณยังสามารถพิจารณาใช้ [`append_view_path`][] เช่นกัน


#### การใช้งานแคชเมลเลอร์วิว

คุณสามารถทำแคชเมลเลอร์วิวเหมือนกับแคชแบบชิ้นเนื้อในมุมมองแอปพลิเคชันโดยใช้ [`cache`][] เมธอด

```html+erb
<% cache do %>
  <%= @company.name %>
<% end %>
```

และในการใช้งานคุณต้องกำหนดค่าแอปพลิเคชันของคุณดังนี้:

```ruby
config.action_mailer.perform_caching = true
```

การแคชแบบชิ้นเนื้อยังรองรับในอีเมลหลายส่วน
อ่านเพิ่มเติมเกี่ยวกับการแคชใน[คู่มือการแคชของ Rails](caching_with_rails.html).


### หน้าแบบ Action Mailer

เหมือนกับมุมมองควบคุม คุณยังสามารถมีเลเอาท์เมลเลอร์ได้ ชื่อเลเอาท์ต้องเหมือนกับเมลเลอร์ของคุณ เช่น `user_mailer.html.erb` และ `user_mailer.text.erb` เพื่อรู้จักอัตโนมัติโดยเมลเลอร์ของคุณเป็นเลเอาท์

ในการใช้ไฟล์ที่แตกต่างกัน ให้เรียกใช้ [`layout`][] ในเมลเลอร์ของคุณ:

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # ใช้ awesome.(html|text).erb เป็นเลเอาท์
end
```

เหมือนกับมุมมองควบคุม ใช้ `yield` เพื่อแสดงผลมุมมองภายในเลเอาท์

คุณยังสามารถส่ง `layout: 'layout_name'` เป็นตัวเลือกในการเรียกใช้ render ภายในบล็อกรูปแบบเพื่อระบุเลเอาท์ที่แตกต่างกันสำหรับรูปแบบที่แตกต่างกัน:

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

จะแสดงส่วน HTML โดยใช้ไฟล์ `my_layout.html.erb` และส่วนข้อความด้วยไฟล์ `user_mailer.text.erb` ตามปกติ หากมีอยู่
### การดูตัวอย่างอีเมล

การดูตัวอย่างอีเมลใน Action Mailer จะให้เราเห็นว่าอีเมลมีลักษณะอย่างไรโดยการเข้าถึง URL พิเศษที่แสดงผลอีเมลนั้น ในตัวอย่างด้านบน คลาสตัวอย่างสำหรับ `UserMailer` ควรถูกตั้งชื่อว่า `UserMailerPreview` และตั้งอยู่ในไฟล์ `test/mailers/previews/user_mailer_preview.rb` ในการดูตัวอย่างของ `welcome_email` ให้สร้างเมธอดที่มีชื่อเดียวกันและเรียกใช้ `UserMailer.welcome_email`:

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

จากนั้นตัวอย่างจะสามารถเข้าถึงได้ที่ <http://localhost:3000/rails/mailers/user_mailer/welcome_email> 

หากคุณเปลี่ยนแปลงบางอย่างใน `app/views/user_mailer/welcome_email.html.erb` หรือใน mailer เอง มันจะโหลดและแสดงผลใหม่โดยอัตโนมัติเพื่อให้คุณสามารถเห็นสไตล์ใหม่ได้ทันที รายการตัวอย่างอีเมลยังมีให้เลือกดูได้ที่ <http://localhost:3000/rails/mailers>

ตามค่าเริ่มต้น คลาสตัวอย่างอยู่ใน `test/mailers/previews` สามารถกำหนดค่าได้โดยใช้ตัวเลือก `preview_paths` ตัวอย่างเช่นหากคุณต้องการเพิ่ม `lib/mailer_previews` เข้าไป คุณสามารถกำหนดค่าได้ใน `config/application.rb`:

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### การสร้าง URL ใน Action Mailer Views

ไม่เหมือนกับคอนโทรลเลอร์ อินสแตนซ์เมลเลอร์ไม่มีข้อมูลเกี่ยวกับคำขอเข้ามา ดังนั้นคุณจะต้องระบุพารามิเตอร์ `:host` เอง

เนื่องจาก `:host` มักจะเป็นค่าที่เหมือนกันทั่วแอปพลิเคชัน คุณสามารถกำหนดค่าได้ทั่วไปใน `config/application.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```

เนื่องจากพฤติกรรมนี้ คุณไม่สามารถใช้เฮลเปอร์ `*_path` ในอีเมลได้ แทนที่คุณจะต้องใช้เฮลเปอร์ที่เกี่ยวข้อง `*_url` ตัวอย่างเช่นแทนที่จะใช้

```html+erb
<%= link_to 'ยินดีต้อนรับ', welcome_path %>
```

คุณจะต้องใช้:

```html+erb
<%= link_to 'ยินดีต้อนรับ', welcome_url %>
```

โดยใช้ URL เต็ม ลิงก์ของคุณจะทำงานในอีเมลของคุณ

#### การสร้าง URL ด้วย `url_for`

[`url_for`][] จะสร้าง URL เต็มโดยค่าเริ่มต้นในเทมเพลต

หากคุณไม่ได้กำหนดค่า `:host` ทั่วไป โปรดตรวจสอบว่าคุณได้ส่งมันไปยัง `url_for` ด้วย


```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```
#### การสร้าง URL ด้วย Named Routes

Email clients ไม่มีเนื้อหาเว็บและเพราะฉะนั้นเส้นทางไม่มี URL หลักที่จะสร้างที่อยู่เว็บที่สมบูรณ์ ดังนั้นคุณควรใช้ช่วยเหลือของ named route helpers รุ่น `*_url` เสมอ

หากคุณไม่ได้กำหนดค่าตัวเลือก `:host` ในระดับทั่วโลก โปรดตรวจสอบให้แน่ใจว่าคุณส่งมันไปยัง URL helper

```erb
<%= user_url(@user, host: 'example.com') %>
```

หมายเหตุ: ลิงก์ที่ไม่ใช่ `GET` ต้องการ [rails-ujs](https://github.com/rails/rails/blob/main/actionview/app/assets/javascripts) หรือ [jQuery UJS](https://github.com/rails/jquery-ujs) และจะไม่ทำงานในเทมเพลตของ mailer และจะส่งคำขอ `GET` ตามปกติ

### เพิ่มรูปภาพใน Action Mailer Views

ไม่เหมือนกับคอนโทรลเลอร์ mailer instance ไม่มีเนื้อหาเกี่ยวกับคำขอเข้ารับเพราะฉะนั้นคุณจะต้องให้พารามิเตอร์ `:asset_host` เอง

เนื่องจาก `:asset_host` มักจะเป็นค่าคงที่ทั่วแอปพลิเคชันคุณสามารถกำหนดค่าได้ทั่วโลกใน `config/application.rb`:

```ruby
config.asset_host = 'http://example.com'
```

ตอนนี้คุณสามารถแสดงภาพภายในอีเมลของคุณได้

```html+erb
<%= image_tag 'image.jpg' %>
```

### ส่งอีเมลแบบ Multipart

Action Mailer จะส่งอีเมลแบบ Multipart โดยอัตโนมัติหากคุณมีเทมเพลตที่แตกต่างกันสำหรับการกระทำเดียวกัน ดังนั้นสำหรับตัวอย่าง `UserMailer` ของเราหากคุณมี `welcome_email.text.erb` และ `welcome_email.html.erb` ใน `app/views/user_mailer` Action Mailer จะส่งอีเมลแบบ Multipart พร้อมกับเวอร์ชัน HTML และข้อความที่ตั้งค่าเป็นส่วนที่แตกต่างกัน

ลำดับของส่วนที่ถูกแทรกจะถูกกำหนดโดย `:parts_order` ภายใน `ActionMailer::Base.default` method

### ส่งอีเมลพร้อมตัวเลือกการส่งแบบไดนามิก

หากคุณต้องการแทนที่ตัวเลือกการส่งเริ่มต้น (เช่นข้อมูลรับ SMTP) เมื่อส่งอีเมลคุณสามารถทำได้โดยใช้ `delivery_method_options` ในการกระทำของ mailer

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = user_url(@user)
    delivery_options = { user_name: params[:company].smtp_user,
                         password: params[:company].smtp_password,
                         address: params[:company].smtp_host }
    mail(to: @user.email,
         subject: "Please see the Terms and Conditions attached",
         delivery_method_options: delivery_options)
  end
end
```

### ส่งอีเมลโดยไม่ต้องทำการเรนเดอร์เทมเพลต

อาจมีกรณีที่คุณต้องการข้ามขั้นตอนการเรนเดอร์เทมเพลตและให้เนื้อหาอีเมลเป็นสตริง คุณสามารถทำได้นี้โดยใช้ตัวเลือก `:body` ในกรณีเช่นนี้อย่าลืมเพิ่มตัวเลือก `:content_type` ระบบจะใช้ค่าเริ่มต้นเป็น `text/plain` มิฉะนั้น
```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email,
         body: params[:email_body],
         content_type: "text/html",
         subject: "Already rendered!")
  end
end
```

Action Mailer Callbacks
-----------------------

Action Mailer ช่วยให้คุณสามารถระบุ [`before_action`][], [`after_action`][] และ [`around_action`][] เพื่อกำหนดค่าข้อความ และ [`before_deliver`][], [`after_deliver`][] และ [`around_deliver`][] เพื่อควบคุมการส่ง

* Callbacks สามารถระบุด้วยบล็อกหรือสัญลักษณ์เป็นเมธอดในคลาสเมลเลือกเหมือนกับคอนโทรลเลอร์

* คุณสามารถใช้ `before_action` เพื่อตั้งค่าตัวแปรอินสแตนซ์ เติมออบเจ็กต์เมลด้วยค่าเริ่มต้น หรือแทรกส่วนหัวและไฟล์แนบเริ่มต้น

```ruby
class InvitationsMailer < ApplicationMailer
  before_action :set_inviter_and_invitee
  before_action { @account = params[:inviter].account }

  default to:       -> { @invitee.email_address },
          from:     -> { common_address(@inviter) },
          reply_to: -> { @inviter.email_address_with_name }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end

  def project_invitation
    @project    = params[:project]
    @summarizer = ProjectInvitationSummarizer.new(@project.bucket)

    mail subject: "#{@inviter.name.familiar} added you to a project in Basecamp (#{@account.name})"
  end

  private
    def set_inviter_and_invitee
      @inviter = params[:inviter]
      @invitee = params[:invitee]
    end
end
```

* คุณสามารถใช้ `after_action` เพื่อทำการตั้งค่าที่คล้ายกับ `before_action` แต่ใช้ตัวแปรอินสแตนซ์ที่ตั้งค่าในแอ็กชันเมลของคุณ

* การใช้คำสั่ง `after_action` ยังช่วยให้คุณสามารถแก้ไขการตั้งค่าวิธีการส่งโดยการอัปเดต `mail.delivery_method.settings` ได้

```ruby
class UserMailer < ApplicationMailer
  before_action { @business, @user = params[:business], params[:user] }

  after_action :set_delivery_options,
               :prevent_delivery_to_guests,
               :set_business_headers

  def feedback_message
  end

  def campaign_message
  end

  private
    def set_delivery_options
      # คุณสามารถเข้าถึงอินสแตนซ์เมล @business และ @user ได้ที่นี่
      if @business && @business.has_smtp_settings?
        mail.delivery_method.settings.merge!(@business.smtp_settings)
      end
    end

    def prevent_delivery_to_guests
      if @user && @user.guest?
        mail.perform_deliveries = false
      end
    end

    def set_business_headers
      if @business
        headers["X-SMTPAPI-CATEGORY"] = @business.code
      end
    end
end
```

* คุณสามารถใช้ `after_delivery` เพื่อบันทึกการส่งข้อความ

* Mailer callbacks ยกเลิกการประมวลผลเพิ่มเติมหากตั้งค่า body เป็นค่าที่ไม่ใช่ nil `before_deliver` สามารถยกเลิกได้ด้วย `throw :abort`
การใช้ Action Mailer Helpers
---------------------------

Action Mailer สืบทอดมาจาก `AbstractController` ดังนั้นคุณสามารถเข้าถึง helpers เหมือนกับ Action Controller ได้เกือบทั้งหมด

นอกจากนี้ยังมีเมธอด helper ที่เฉพาะเจาะจงสำหรับ Action Mailer ที่ใช้ได้ใน [`ActionMailer::MailHelper`][]. ตัวอย่างเช่น คุณสามารถเข้าถึง instance ของ mailer จาก view ของคุณได้ด้วย [`mailer`][MailHelper#mailer], และเข้าถึงข้อความด้วย [`message`][MailHelper#message]:

```erb
<%= stylesheet_link_tag mailer.name.underscore %>
<h1><%= message.subject %></h1>
```


การกำหนดค่า Action Mailer
---------------------------

ตัวเลือกการกำหนดค่าต่อไปนี้เหมาะสมที่สุดเมื่อต้องทำในไฟล์ environment (environment.rb, production.rb, เป็นต้น)

| การกำหนดค่า | คำอธิบาย |
|---------------|-------------|
|`logger`|สร้างข้อมูลเกี่ยวกับการส่งอีเมลถ้ามีข้อมูลให้ใช้งาน. สามารถกำหนดให้เป็น `nil` เพื่อไม่มีการบันทึก. สามารถใช้ร่วมกับ `Logger` ของ Ruby และ Log4r loggers ได้.|
|`smtp_settings`|อนุญาตให้กำหนดค่าอย่างละเอียดสำหรับวิธีการส่ง `:smtp`:<ul><li>`:address` - ช่วยให้คุณสามารถใช้เซิร์ฟเวอร์อีเมลระยะไกลได้. คุณสามารถเปลี่ยนจากค่าเริ่มต้น `"localhost"` ได้.</li><li>`:port` - ในกรณีที่เซิร์ฟเวอร์อีเมลของคุณไม่ทำงานบนพอร์ต 25 คุณสามารถเปลี่ยนได้.</li><li>`:domain` - หากคุณต้องการระบุโดเมน HELO คุณสามารถทำได้ที่นี่.</li><li>`:user_name` - หากเซิร์ฟเวอร์อีเมลของคุณต้องการการตรวจสอบสิทธิ์ในการเข้าใช้งาน ให้กำหนดชื่อผู้ใช้ในการตั้งค่านี้.</li><li>`:password` - หากเซิร์ฟเวอร์อีเมลของคุณต้องการการตรวจสอบสิทธิ์ในการเข้าใช้งาน ให้กำหนดรหัสผ่านในการตั้งค่านี้.</li><li>`:authentication` - หากเซิร์ฟเวอร์อีเมลของคุณต้องการการตรวจสอบสิทธิ์ในการเข้าใช้งาน คุณต้องระบุประเภทการตรวจสอบสิทธิ์ที่นี่. นี่เป็นสัญลักษณ์และเป็นหนึ่งใน `:plain` (จะส่งรหัสผ่านในรูปแบบข้อความปกติ), `:login` (จะส่งรหัสผ่านในรูปแบบ Base64 encoded) หรือ `:cram_md5` (รวมกลไก Challenge/Response เพื่อแลกเปลี่ยนข้อมูลและข้อความที่สำคัญในการเข้ารหัสด้วยวิธี Message Digest 5)</li><li>`:enable_starttls` - ใช้ STARTTLS เมื่อเชื่อมต่อกับเซิร์ฟเวอร์ SMTP และล้มเหลวหากไม่รองรับ. ค่าเริ่มต้นคือ `false`.</li><li>`:enable_starttls_auto` - ตรวจสอบว่า STARTTLS เปิดใช้งานในเซิร์ฟเวอร์ SMTP และเริ่มใช้งาน. ค่าเริ่มต้นคือ `true`.</li><li>`:openssl_verify_mode` - เมื่อใช้ TLS คุณสามารถกำหนดวิธีการตรวจสอบใบรับรองของ OpenSSL ได้. สิ่งนี้เป็นประโยชน์อย่างมากหากคุณต้องการตรวจสอบใบรับรองที่ลงชื่อเองและ/หรือใบรับรองแบบวิลด์การ์ด. คุณสามารถใช้ชื่อคงที่ของ OpenSSL verify constant ('none' หรือ 'peer') หรือตรงไปยังค่าคงที่ (`OpenSSL::SSL::VERIFY_NONE` หรือ `OpenSSL::SSL::VERIFY_PEER`).</li><li>`:ssl/:tls` - เปิดใช้งานการเชื่อมต่อ SMTP เพื่อใช้งาน SMTP/TLS (SMTPS: การเชื่อมต่อ SMTP ผ่านการเชื่อมต่อ TLS โดยตรง)</li><li>`:open_timeout` - จำนวนวินาทีที่ต้องรอขณะพยายามเปิดการเชื่อมต่อ.</li><li>`:read_timeout` - จำนวนวินาทีที่ต้องรอจนกว่าการเรียกใช้งาน read(2) จะหมดเวลา.</li></ul>|
|`sendmail_settings`|อนุญาตให้คุณแทนที่ตัวเลือกสำหรับวิธีการส่ง `:sendmail`.<ul><li>`:location` - ตำแหน่งของไฟล์ส่งอีเมล sendmail. ค่าเริ่มต้นคือ `/usr/sbin/sendmail`.</li><li>`:arguments` - อาร์กิวเมนต์บรรทัดคำสั่งที่จะถูกส่งไปยัง sendmail. ค่าเริ่มต้นคือ `["-i"]`.</li></ul>|
|`raise_delivery_errors`|ว่าควรเกิดข้อผิดพลาดหรือไม่หากอีเมลล้มเหลวในการส่ง. สิ่งนี้ทำงานเฉพาะเมื่อเซิร์ฟเวอร์อีเมลภายนอกได้กำหนดค่าให้ส่งทันที. ค่าเริ่มต้นคือ `true`.|
|`delivery_method`|กำหนดวิธีการส่ง. ค่าที่เป็นไปได้คือ:<ul><li>`:smtp` (ค่าเริ่มต้น), สามารถกำหนดค่าได้โดยใช้ [`config.action_mailer.smtp_settings`][].</li><li>`:sendmail`, สามารถกำหนดค่าได้โดยใช้ [`config.action_mailer.sendmail_settings`][].</li><li>`:file`: บันทึกอีเมลล์เป็นไฟล์; สามารถกำหนดค่าได้โดยใช้ `config.action_mailer.file_settings`.</li><li>`:test`: บันทึกอีเมลล์ไว้ในอาร์เรย์ `ActionMailer::Base.deliveries`.</li></ul>ดู [API docs](https://api.rubyonrails.org/classes/ActionMailer/Base.html) สำหรับข้อมูลเพิ่มเติม.|
|`perform_deliveries`|กำหนดว่าจะดำเนินการส่งจริงหรือไม่เมื่อเรียกใช้เมธอด `deliver` บนข้อความ Mail. ค่าเริ่มต้นคือใช่ แต่สามารถปิดการใช้งานเพื่อช่วยในการทดสอบฟังก์ชันได้. หากค่านี้เป็น `false`, อาร์เรย์ `deliveries` จะไม่ถูกเติมค่า แม้ว่า `delivery_method` จะเป็น `:test` อยู่เสมอ.|
|`deliveries`|เก็บอีเมลล์ทั้งหมดที่ส่งออกผ่าน Action Mailer ด้วย `delivery_method` เป็น `:test` อยู่. มีประโยชน์มากที่สุดสำหรับการทดสอบหน่วยและฟังก์ชัน.|
|`delivery_job`|คลาสงานที่ใช้กับ `deliver_later`. ค่าเริ่มต้นคือ `ActionMailer::MailDeliveryJob`.|
|`deliver_later_queue_name`|ชื่อคิวที่ใช้กับ `delivery_job` ค่าเริ่มต้นคือคิว Active Job ที่เป็นค่าเริ่มต้น.|
|`default_options`|อนุญาตให้คุณกำหนดค่าเริ่มต้นสำหรับตัวเลือกของเมธอด `mail` (`:from`, `:reply_to`, เป็นต้น).|
สำหรับการกำหนดค่าที่เป็นไปได้อย่างละเอียดดูที่ [การกำหนดค่า Action Mailer](configuring.html#configuring-action-mailer) ในเอกสาร Configuring Rails Applications ของเรา

### ตัวอย่างการกำหนดค่า Action Mailer

ตัวอย่างการเพิ่มโค้ดต่อไปนี้ในไฟล์ `config/environments/$RAILS_ENV.rb` ที่เหมาะสม:

```ruby
config.action_mailer.delivery_method = :sendmail
# ค่าเริ่มต้น:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: %w[ -i ]
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = { from: 'no-reply@example.com' }
```

### การกำหนดค่า Action Mailer สำหรับ Gmail

Action Mailer ใช้ [Mail gem](https://github.com/mikel/mail) และยอมรับการกำหนดค่าที่คล้ายกัน ให้เพิ่มโค้ดต่อไปนี้ในไฟล์ `config/environments/$RAILS_ENV.rb` เพื่อส่งผ่าน Gmail:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:         'smtp.gmail.com',
  port:            587,
  domain:          'example.com',
  user_name:       '<username>',
  password:        '<password>',
  authentication:  'plain',
  enable_starttls: true,
  open_timeout:    5,
  read_timeout:    5 }
```

หากคุณใช้เวอร์ชันเก่าของ Mail gem (2.6.x หรือต่ำกว่า) ให้ใช้ `enable_starttls_auto` แทน `enable_starttls`

หมายเหตุ: Google [บล็อกการเข้าสู่ระบบ](https://support.google.com/accounts/answer/6010255) จากแอปที่ถือว่าไม่ปลอดภัยมากพอ คุณสามารถเปลี่ยนการตั้งค่า Gmail ของคุณ [ที่นี่](https://www.google.com/settings/security/lesssecureapps) เพื่ออนุญาตให้พยายามเข้าสู่ระบบได้ หากบัญชี Gmail ของคุณเปิดใช้งานการตรวจสอบสองขั้นตอน คุณจะต้องตั้งค่า [รหัสแอป](https://myaccount.google.com/apppasswords) และใช้รหัสนั้นแทนรหัสผ่านปกติของคุณ

การทดสอบ Mailer
--------------

คุณสามารถหาคำแนะนำอย่างละเอียดเกี่ยวกับวิธีการทดสอบ Mailer ของคุณในเอกสาร [คู่มือการทดสอบ](testing.html#testing-your-mailers)

การดักจับและสังเกตอีเมล
-------------------

Action Mailer ให้การเชื่อมต่อกับเมท็อดตัวช่วยและตัวดักจับของ Mail นี้ช่วยให้คุณลงทะเบียนคลาสที่จะถูกเรียกใช้ระหว่างการส่งอีเมลทุกครั้งในรอบการส่งอีเมล

### การดักจับอีเมล

ตัวดักจับช่วยให้คุณสามารถแก้ไขอีเมลก่อนที่จะส่งให้กับตัวแทนการส่ง คลาสตัวดักจับต้องประมวลผลเมท็อด `::delivering_email(message)` ซึ่งจะถูกเรียกก่อนที่จะส่งอีเมล

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

ก่อนที่ตัวดักจับจะทำงานได้ คุณต้องลงทะเบียนด้วยตัวเลือกการกำหนดค่า `interceptors` คุณสามารถทำได้ในไฟล์เริ่มต้นเช่น `config/initializers/mail_interceptors.rb`:
```ruby
Rails.application.configure do
  if Rails.env.staging?
    config.action_mailer.interceptors = %w[SandboxEmailInterceptor]
  end
end
```

หมายเหตุ: ตัวอย่างข้างต้นใช้สภาพแวดล้อมที่กำหนดเองที่เรียกว่า "staging" สำหรับเซิร์ฟเวอร์ที่คล้ายกับการใช้งานจริง แต่เพื่อวัตถุประสงค์ในการทดสอบ คุณสามารถอ่านเพิ่มเติมเกี่ยวกับการสร้างสภาพแวดล้อม Rails ที่กำหนดเองได้ที่ [การสร้างสภาพแวดล้อม Rails](configuring.html#creating-rails-environments)

### การสังเกตอีเมล

Observers ช่วยให้คุณเข้าถึงข้อความอีเมลหลังจากที่ส่งไปแล้ว คลาส Observer จะต้องมีการสร้างเมธอด `:delivered_email(message)` ซึ่งจะถูกเรียกใช้หลังจากที่อีเมลถูกส่ง

```ruby
class EmailDeliveryObserver
  def self.delivered_email(message)
    EmailDelivery.log(message)
  end
end
```

เหมือนกับ interceptors คุณต้องลงทะเบียน observers โดยใช้ตัวเลือก config `observers` คุณสามารถทำได้ในไฟล์ initializer เช่น `config/initializers/mail_observers.rb`:

```ruby
Rails.application.configure do
  config.action_mailer.observers = %w[EmailDeliveryObserver]
end
```
[`ActionMailer::Base`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html
[`default`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-c-default
[`mail`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-mail
[`ActionMailer::MessageDelivery`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html
[`deliver_later`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_later
[`deliver_now`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_now
[`Mail::Message`]: https://api.rubyonrails.org/classes/Mail/Message.html
[`message`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-message
[`with`]: https://api.rubyonrails.org/classes/ActionMailer/Parameterized/ClassMethods.html#method-i-with
[`attachments`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-attachments
[`headers`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-headers
[`email_address_with_name`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-email_address_with_name
[`append_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-append_view_path
[`prepend_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-prepend_view_path
[`cache`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CacheHelper.html#method-i-cache
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`url_for`]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`after_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-after_deliver
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`around_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-around_deliver
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`before_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-before_deliver
[`ActionMailer::MailHelper`]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html
[MailHelper#mailer]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-mailer
[MailHelper#message]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-message
[`config.action_mailer.sendmail_settings`]: configuring.html#config-action-mailer-sendmail-settings
[`config.action_mailer.smtp_settings`]: configuring.html#config-action-mailer-smtp-settings
