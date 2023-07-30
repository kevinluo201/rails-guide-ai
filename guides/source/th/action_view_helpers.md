**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37d2486eee8522a64c5f97f86900b8a6
Action View Helpers
====================

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีการจัดรูปแบบวันที่ สตริง และตัวเลข
* วิธีการเชื่อมโยงไปยังรูปภาพ วิดีโอ สไตล์ชีต เป็นต้น
* วิธีการทำความสะอาดเนื้อหา
* วิธีการใช้งานภาษาท้องถิ่น

--------------------------------------------------------------------------------

ภาพรวมของ Helpers ที่ Action View มีให้บริการ
-------------------------------------------

WIP: ไม่ได้ระบุทุก helpers ที่นี่ สำหรับรายการเต็ม ๆ โปรดดูที่ [เอกสาร API](https://api.rubyonrails.org/classes/ActionView/Helpers.html)

ส่วนที่ต่อไปนี้เป็นภาพรวมสรุปเกี่ยวกับ helpers ที่มีให้ใช้ใน Action View ซึ่งแนะนำให้คุณตรวจสอบ [เอกสาร API](https://api.rubyonrails.org/classes/ActionView/Helpers.html) ซึ่งระบุรายละเอียดของ helpers ทั้งหมดอย่างละเอียด แต่สิ่งนี้ควรเป็นจุดเริ่มต้นที่ดี

### AssetTagHelper

โมดูลนี้ให้เมธอดสำหรับสร้าง HTML ที่เชื่อมโยงวิวไปยังทรัพยากรเช่นรูปภาพ ไฟล์ JavaScript สไตล์ชีต และฟีด

โดยค่าเริ่มต้น Rails จะเชื่อมโยงไปยังทรัพยากรเหล่านี้บนโฮสต์ปัจจุบันในโฟลเดอร์ public แต่คุณสามารถกำหนดให้ Rails เชื่อมโยงไปยังทรัพยากรจากเซิร์ฟเวอร์ทรัพยากรที่มีการกำหนดค่า [`config.asset_host`][] ในการกำหนดค่าแอปพลิเคชัน โดยทั่วไปจะอยู่ใน `config/environments/production.rb` ตัวอย่างเช่น สมมุติว่าโฮสต์ทรัพยากรของคุณคือ `assets.example.com`:

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```


#### auto_discovery_link_tag

คืนค่าแท็กลิงก์ที่เบราว์เซอร์และอ่านเนื้อหาสามารถใช้ในการตรวจหาอัตโนมัติฟีด RSS, Atom หรือ JSON

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

#### image_path

คำนวณเส้นทางไปยังทรัพยากรรูปภาพในไดเรกทอรี `app/assets/images` จะถูกส่งผ่านเส้นทางเต็มจากรากเอกสาร ใช้ภายใน `image_tag` เพื่อสร้างเส้นทางรูปภาพ

```ruby
image_path("edit.png") # => /assets/edit.png
```

จะเพิ่ม fingerprint ในชื่อไฟล์หาก config.assets.digest ถูกตั้งค่าเป็น true

```ruby
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

คำนวณ URL ไปยังทรัพยากรรูปภาพในไดเรกทอรี `app/assets/images` นี้จะเรียกใช้ `image_path` ภายในและผสานกับโฮสต์ปัจจุบันหรือโฮสต์ทรัพยากรของคุณ

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

คืนแท็กรูปภาพ HTML สำหรับแหล่งที่มา แหล่งที่มาสามารถเป็นเส้นทางเต็มหรือไฟล์ที่มีอยู่ในไดเรกทอรี `app/assets/images` ของคุณ

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

คืนแท็กสคริปต์ HTML สำหรับแต่ละแหล่งที่มาที่ระบุ คุณสามารถส่งชื่อไฟล์ (นามสกุล `.js` เป็นทางเลือก) ของไฟล์ JavaScript ที่มีอยู่ในไดเรกทอรี `app/assets/javascripts` เพื่อรวมเข้ากับหน้าปัจจุบัน หรือคุณสามารถส่งเส้นทางเต็มที่เกี่ยวข้องกับรากเอกสารของคุณ

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

คำนวณเส้นทางไปยังทรัพยากรสคริปต์ JavaScript ในไดเรกทอรี `app/assets/javascripts` หากชื่อไฟล์แหล่งที่มาไม่มีนามสกุล จะเพิ่ม `.js` ให้ จะถูกส่งผ่านเส้นทางเต็มจากรากเอกสาร ใช้ภายใน `javascript_include_tag` เพื่อสร้างเส้นทางสคริปต์

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

คำนวณ URL ไปยังทรัพยากรสคริปต์ JavaScript ในไดเรกทอรี `app/assets/javascripts` นี้จะเรียกใช้ `javascript_path` ภายในและผสานกับโฮสต์ปัจจุบันหรือโฮสต์ทรัพยากรของคุณ

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

คืนแท็กลิงก์สไตล์ชีตสำหรับแหล่งที่มาที่ระบุเป็นอาร์กิวเมนต์ หากคุณไม่ระบุนามสกุล จะเพิ่ม `.css` โดยอัตโนมัติ
```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" rel="stylesheet" />
```

#### stylesheet_path

คำนวณเส้นทางไปยังแอสเซ็ตสไตล์ในไดเรกทอรี `app/assets/stylesheets` หากชื่อไฟล์ต้นฉบับไม่มีนามสกุล จะถูกเพิ่ม `.css` ไปท้าย พาธเต็มจากรากเอกสารจะถูกส่งผ่าน ใช้ภายในโดย `stylesheet_link_tag` เพื่อสร้างเส้นทางไปยังสไตล์ชีท

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

คำนวณ URL ไปยังแอสเซ็ตสไตล์ในไดเรกทอรี `app/assets/stylesheets` นี้จะเรียกใช้ `stylesheet_path` ภายในและผสานกับโฮสต์ปัจจุบันหรือโฮสต์แอสเซ็ตของคุณ

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

ช่วยให้การสร้างฟีด Atom เป็นเรื่องง่าย นี่คือตัวอย่างการใช้งานเต็มรูปแบบ:

**config/routes.rb**

```ruby
resources :articles
```

**app/controllers/articles_controller.rb**

```ruby
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```ruby
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

### BenchmarkHelper

#### benchmark

ช่วยให้คุณสามารถวัดเวลาการประมวลผลของบล็อกในเทมเพลตและบันทึกผลลัพธ์ลงในบันทึกได้ ใช้บล็อกนี้รอบกระบวนการที่ใช้เวลามากหรือเป็นจุดขวางเพื่อให้ได้เวลาอ่านสำหรับการปรับปรุงโค้ดของคุณ

```html+erb
<% benchmark "Process data files" do %>
  <%= expensive_files_operation %>
<% end %>
```

สิ่งนี้จะเพิ่มบางอย่างเช่น "Process data files (0.34523)" เข้าไปในบันทึก ซึ่งคุณสามารถใช้เปรียบเทียบเวลาเมื่อปรับปรุงโค้ดของคุณ

### CacheHelper

#### cache

เป็นวิธีหนึ่งสำหรับแคชเฟรกเมนต์ของวิวแทนทั้งการกระทำหรือหน้า วิธีนี้เป็นประโยชน์ในการแคชส่วนที่เป็นเมนู รายการหัวข่าว ฟรากเมนต์ HTML แบบคงที่ ฯลฯ วิธีนี้รับบล็อกที่มีเนื้อหาที่คุณต้องการแคช ดู `AbstractController::Caching::Fragments` เพื่อข้อมูลเพิ่มเติม

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

เมธอด `capture` ช่วยให้คุณสามารถแยกส่วนของเทมเพลตออกเป็นตัวแปรได้ คุณสามารถใช้ตัวแปรนี้ที่ใดก็ได้ในเทมเพลตหรือเลเอาท์ของคุณ

```html+erb
<% @greeting = capture do %>
  <p>Welcome! The date and time is <%= Time.now %></p>
<% end %>
```

ตัวแปรที่ถูกแยกออกมานั้นสามารถใช้ที่อื่นได้

```html+erb
<html>
  <head>
    <title>Welcome!</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### content_for

การเรียกใช้ `content_for` เก็บบล็อกของมาร์กอัปในตัวระบุเพื่อใช้ในภายหลัง คุณสามารถเรียกใช้เนื้อหาที่เก็บไว้ในเทมเพลตอื่นหรือเลเอาท์โดยส่งตัวระบุเป็นอาร์กิวเมนต์ให้กับ `yield`

ตัวอย่างเช่น สมมติว่าเรามีเลเอาท์แอปพลิเคชันมาตรฐาน แต่ยังมีหน้าพิเศษที่ต้องการสคริปต์บางอย่างที่เว็บไซต์อื่นไม่ต้องการ เราสามารถใช้ `content_for` เพื่อรวมสคริปต์นี้ในหน้าพิเศษของเราโดยไม่ทำให้เว็บไซต์อื่นโตขึ้น

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>Welcome!</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Welcome! The date and time is <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>This is a special page.</p>

<% content_for :special_script do %>
  <script>alert('Hello!')</script>
<% end %>
```
### DateHelper

#### distance_of_time_in_words

รายงานระยะเวลาโดยประมาณระหว่างวัตถุเวลาหรือวันที่สองอันหรือจำนวนเต็มเป็นวินาที ตั้งค่า `include_seconds` เป็น true หากต้องการคำประมาณที่ละเอียดมากขึ้น

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => น้อยกว่าหนึ่งนาที
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => น้อยกว่า 20 วินาที
```

#### time_ago_in_words

คล้ายกับ `distance_of_time_in_words` แต่ `to_time` ถูกกำหนดเป็น `Time.now`.

```ruby
time_ago_in_words(3.minutes.from_now) # => 3 นาที
```

### DebugHelper

คืนค่าแท็ก `pre` ที่มีวัตถุที่ถูกดัมป์โดย YAML ซึ่งสร้างวิธีการที่อ่านง่ายมากในการตรวจสอบวัตถุ

```ruby
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1, 2, 3] }
debug(my_hash)
```

```html
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

### FormHelper

Form helpers ออกแบบมาเพื่อทำให้การทำงานกับโมเดลง่ายขึ้นมากเมื่อเปรียบเทียบกับการใช้เพียงอิลิเมนต์ HTML มาตรฐานโดยให้เซตของเมธอดสำหรับสร้างฟอร์มขึ้นมาจากโมเดลของคุณ ช่วยให้สร้าง HTML สำหรับฟอร์มโดยให้เมธอดสำหรับแต่ละประเภทของอินพุต (เช่น ข้อความ รหัสผ่าน เลือก และอื่น ๆ) เมื่อฟอร์มถูกส่ง (เช่น เมื่อผู้ใช้กดปุ่มส่งหรือเรียกใช้ form.submit ผ่าน JavaScript) อินพุตของฟอร์มจะถูกรวบรวมเข้ากับออบเจกต์ params และส่งกลับไปยังคอนโทรลเลอร์

คุณสามารถเรียนรู้เพิ่มเติมเกี่ยวกับ form helpers ใน [Action View Form Helpers
Guide](form_helpers.html).

### JavaScriptHelper

ให้ความสามารถในการทำงานกับ JavaScript ในมุมมองของคุณ

#### escape_javascript

หนีตัวอักษรพิเศษและเครื่องหมายเริ่มต้นและเครื่องหมายคำพูดสำหรับเซกเมนต์ JavaScript

#### javascript_tag

คืนค่าแท็ก JavaScript ที่ห่อหุ้มโค้ดที่ให้มา

```ruby
javascript_tag "alert('All is good')"
```

```html
<script>
//<![CDATA[
alert('All is good')
//]]>
</script>
```

### NumberHelper

ให้เมธอดสำหรับแปลงตัวเลขเป็นสตริงที่จัดรูปแบบ มีเมธอดสำหรับหมายเลขโทรศัพท์ เงินตรา เปอร์เซ็นต์ ความแม่นยำ ตัวเลขตำแหน่ง และขนาดไฟล์

#### number_to_currency

จัดรูปแบบตัวเลขเป็นสตริงสกุลเงิน (เช่น $13.65).

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### number_to_human

พิมพ์สวยงาม (จัดรูปและประมาณ) ตัวเลขเพื่อให้มีความอ่านง่ายขึ้นสำหรับผู้ใช้ มีประโยชน์สำหรับตัวเลขที่อาจมีขนาดใหญ่มาก

```ruby
number_to_human(1234)    # => 1.23 พัน
number_to_human(1234567) # => 1.23 ล้าน
```

#### number_to_human_size

จัดรูปแบบไบต์ในขนาดเป็นรูปแบบที่เข้าใจง่ายมากขึ้น มีประโยชน์สำหรับรายงานขนาดไฟล์ให้ผู้ใช้

```ruby
number_to_human_size(1234)    # => 1.21 KB
number_to_human_size(1234567) # => 1.18 MB
```

#### number_to_percentage

จัดรูปแบบตัวเลขเป็นสตริงเปอร์เซ็นต์

```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

จัดรูปแบบตัวเลขเป็นหมายเลขโทรศัพท์ (ค่าเริ่มต้นในสหรัฐอเมริกา)

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

จัดรูปแบบตัวเลขด้วยการจัดกลุ่มพันด้วยตัวคั่น

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

จัดรูปแบบตัวเลขด้วยระดับความแม่นยำที่ระบุ ซึ่งค่าเริ่มต้นเป็น 3

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

โมดูล SanitizeHelper ให้ชุดเมธอดสำหรับล้างข้อความของอิลิเมนต์ HTML ที่ไม่ต้องการ

#### sanitize

sanitize helper นี้จะเข้ารหัส HTML สำหรับแท็กทั้งหมดและลบแอตทริบิวต์ทั้งหมดที่ไม่ได้รับอนุญาตโดยเฉพาะ
```ruby
sanitize @article.body
```

หากผ่าน `:attributes` หรือ `:tags` ไป จะอนุญาตเฉพาะแอตทริบิวต์และแท็กที่ระบุไว้เท่านั้น และไม่อนุญาตให้มีอย่างอื่น

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

เพื่อเปลี่ยนค่าเริ่มต้นสำหรับการใช้งานหลายครั้ง เช่นการเพิ่มแท็กตารางในค่าเริ่มต้น:

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

ทำความสะอาดรหัส CSS

#### strip_links(html)

ลบแท็กลิงก์ทั้งหมดออกจากข้อความ และเหลือเพียงข้อความลิงก์เท่านั้น

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('emails to <a href="mailto:me@email.com">me@email.com</a>.')
# => emails to me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visit</a>.')
# => Blog: Visit.
```

#### strip_tags(html)

ลบแท็ก HTML ทั้งหมดออกจาก html รวมถึงคอมเมนต์ด้วย
ฟังก์ชันนี้ใช้งานโดย rails-html-sanitizer gem

```ruby
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!
```

```ruby
strip_tags("<b>Bold</b> no more!  <a href='more.html'>See more</a>")
# => Bold no more!  See more
```

หมายเหตุ: ผลลัพธ์อาจยังมีตัวอักษร '<', '>', '&' ที่ไม่ได้รับการหลีกเลี่ยงและทำให้เกิดความสับสนกับเบราว์เซอร์

### UrlHelper

ให้เมธอดเพื่อสร้างลิงก์และรับ URL ที่ขึ้นอยู่กับระบบเร้าท์ติ้ง

#### url_for

คืนค่า URL สำหรับชุด `options` ที่ให้มา

##### ตัวอย่าง

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

ลิงก์ไปยัง URL ที่ได้รับมาจาก `url_for` ในพื้นหลัง ใช้โดยส่วนใหญ่เพื่อสร้างลิงก์ทรัพยากร RESTful ซึ่งสำหรับตัวอย่างนี้ จะยุบเป็นเมื่อส่งโมเดลไปยัง `link_to`

**ตัวอย่าง**

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>
```

คุณสามารถใช้บล็อกได้เช่นกันหากเป้าหมายลิงก์ของคุณไม่สามารถพอดีกับพารามิเตอร์ชื่อ ตัวอย่าง ERB:

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
<% end %>
```

จะแสดงผลเป็น:

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Check it out!</span>
</a>
```

ดู [เอกสาร API เพิ่มเติม](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)

#### button_to

สร้างฟอร์มที่ส่งไปยัง URL ที่ระบุ ฟอร์มจะมีปุ่มส่งค่าของ `name`

##### ตัวอย่าง

```html+erb
<%= button_to "Sign in", sign_in_path %>
```

จะแสดงผลประมาณนี้:

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

ดู [เอกสาร API เพิ่มเติม](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)

### CsrfHelper

คืนค่าแท็กเมต้า "csrf-param" และ "csrf-token" พร้อมชื่อพารามิเตอร์และโทเค็นการป้องกันการโจมตีแบบข้ามไซต์

```html
<%= csrf_meta_tags %>
```

หมายเหตุ: แบบฟอร์มปกติจะสร้างฟิลด์ที่ซ่อนอยู่ดังนั้นจึงไม่ใช้แท็กเหล่านี้ สามารถดูรายละเอียดเพิ่มเติมได้ใน [คู่มือความปลอดภัยของ Rails](security.html#cross-site-request-forgery-csrf)
[`config.asset_host`]: configuring.html#config-asset-host
