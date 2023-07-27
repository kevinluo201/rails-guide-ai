**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: da25f37b5b3eddff86c5b5b2cd24007f
เอกสารปล่อยตัวของ Ruby on Rails 3.1
===============================

จุดเด่นใน Rails 3.1:

* Streaming
* Reversible Migrations
* Assets Pipeline
* jQuery เป็นไลบรารี JavaScript เริ่มต้น

เอกสารปล่อยตัวนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่เอกสารเปลี่ยนแปลงหรือตรวจสอบ [รายการของการเปลี่ยนแปลง](https://github.com/rails/rails/commits/3-1-stable) ในเก็บรักษาของ Rails ใน GitHub

--------------------------------------------------------------------------------

การอัพเกรดไปยัง Rails 3.1
----------------------

หากคุณกำลังอัพเกรดแอปพลิเคชันที่มีอยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัพเกรดไปยัง Rails 3 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัพเกรดไปยัง Rails 3.1 จากนั้นทำตามขั้นตอนต่อไปนี้:

### Rails 3.1 ต้องการ Ruby 1.8.7 ขึ้นไป

Rails 3.1 ต้องการ Ruby 1.8.7 หรือสูงกว่า การสนับสนุนสำหรับเวอร์ชัน Ruby ก่อนหน้านี้ทั้งหมดถูกยกเลิกอย่างเป็นทางการและคุณควรอัพเกรดให้เร็วที่สุด  Rails 3.1 ยังเข้ากันได้กับ Ruby 1.9.2

เคล็ดลับ: โปรดทราบว่า Ruby 1.8.7 p248 และ p249 มีข้อบกพร่องในการมาร์ชลิ่งที่ทำให้ Rails ล้มเหลว แต่ Ruby Enterprise Edition ได้แก้ไขปัญหาเหล่านี้ตั้งแต่เวอร์ชัน 1.8.7-2010.02 สำหรับเวอร์ชัน 1.9  Ruby 1.9.1 ไม่สามารถใช้งานได้เพราะมีข้อบกพร่องที่ร้ายแรง ดังนั้นหากคุณต้องการใช้ 1.9.x คุณควรใช้ 1.9.2 เพื่อความราบรื่น

### อัพเดตในแอปพลิเคชันของคุณ

การเปลี่ยนแปลงต่อไปนี้เหมาะสำหรับการอัพเกรดแอปพลิเคชันของคุณไปยัง Rails 3.1.3 เวอร์ชันล่าสุดของ Rails 3.1.x

#### Gemfile

ทำการเปลี่ยนแปลงต่อไปนี้ใน `Gemfile` ของคุณ

```ruby
gem 'rails', '= 3.1.3'
gem 'mysql2'

# จำเป็นสำหรับ asset pipeline ใหม่
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# jQuery เป็นไลบรารี JavaScript เริ่มต้นใน Rails 3.1
gem 'jquery-rails'
```

#### config/application.rb

* Asset pipeline ต้องการการเพิ่มต่อไปนี้:

    ```ruby
    config.assets.enabled = true
    config.assets.version = '1.0'
    ```

* หากแอปพลิเคชันของคุณใช้เส้นทาง "/assets" สำหรับทรัพยากร คุณอาจต้องเปลี่ยนคำนำหน้าที่ใช้สำหรับทรัพยากรเพื่อหลีกเลี่ยงความขัดแย้ง:

    ```ruby
    # ค่าเริ่มต้นคือ '/assets'
    config.assets.prefix = '/asset-files'
    ```

#### config/environments/development.rb

* ลบการตั้งค่า RJS `config.action_view.debug_rjs = true`.

* เพิ่มต่อไปนี้หากคุณเปิดใช้งาน asset pipeline.

    ```ruby
    # ไม่บีบอัดทรัพยากร
    config.assets.compress = false

    # ขยายบรรทัดที่โหลดทรัพยากร
    config.assets.debug = true
    ```

#### config/environments/production.rb

* อีกครั้ง, การเปลี่ยนแปลงส่วนใหญ่ด้านล่างเป็นสำหรับ asset pipeline คุณสามารถอ่านเพิ่มเติมเกี่ยวกับเรื่องนี้ได้ใน [Asset Pipeline](asset_pipeline.html) คู่มือ

    ```ruby
    # บีบอัด JavaScripts และ CSS
    config.assets.compress = true

    # ไม่สลับไปใช้งาน asset pipeline หากไม่พบทรัพยากรที่ถูกสร้างไว้ล่วงหน้า
    config.assets.compile = false

    # สร้างเอกสารสำหรับ URLs ของทรัพยากร
    config.assets.digest = true

    # ค่าเริ่มต้นคือ Rails.root.join("public/assets")
    # config.assets.manifest = YOUR_PATH

    # สร้างทรัพยากรเพิ่มเติม (application.js, application.css, และทรัพยากรที่ไม่ใช่ JS/CSS ทั้งหมดถูกเพิ่มไว้แล้ว)
    # config.assets.precompile `= %w( admin.js admin.css )


    # บังคับให้เข้าถึงแอปผ่าน SSL, ใช้ Strict-Transport-Security, และใช้ secure cookies.
    # config.force_ssl = true
    ```

#### config/environments/test.rb

```ruby
# กำหนดค่าเซิร์ฟเวอร์ทรัพยากรสถิตในการทดสอบพร้อมกับ Cache-Control เพื่อเพิ่มประสิทธิภาพ
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

#### config/initializers/wrap_parameters.rb

* เพิ่มไฟล์นี้พร้อมเนื้อหาต่อไปนี้หากคุณต้องการแพ็คเกจเข้ากับพารามิเตอร์เป็นแฮชซ้อน ค่าเริ่มต้นในแอปพลิเคชันใหม่

    ```ruby
    # ตรวจสอบให้แน่ใจว่าคุณรีสตาร์ทเซิร์ฟเวอร์ของคุณเมื่อคุณแก้ไขไฟล์นี้
    # ไฟล์นี้มีการตั้งค่าสำหรับ ActionController::ParamsWrapper ซึ่ง
    # เปิดใช้งานโดยค่าเริ่มต้น

    # เปิดใช้งานการแพ็คเกจสำหรับ JSON คุณสามารถปิดใช้งานได้โดยการตั้งค่า :format เป็นอาร์เรย์ที่ว่างเปล่า
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters :format => [:json]
    end

    # ปิดใช้งานองค์ประกอบรูทใน JSON โดยค่าเริ่มต้น
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
    ```
#### ลบ :cache และ :concat ออกจากตัวเลือกในการอ้างอิง asset helpers ใน views

* ด้วย Asset Pipeline ตัวเลือก :cache และ :concat ไม่ได้ใช้แล้ว ให้ลบตัวเลือกเหล่านี้ออกจาก views ของคุณ

การสร้างแอปพลิเคชัน Rails 3.1
--------------------------------

```bash
# คุณควรมี 'rails' RubyGem ติดตั้งแล้ว
$ rails new myapp
$ cd myapp
```

### Vendoring Gems

Rails ใช้ `Gemfile` ในรากแอปพลิเคชันเพื่อกำหนด gem ที่คุณต้องการสำหรับแอปพลิเคชันของคุณให้เริ่มต้น ไฟล์ `Gemfile` นี้จะถูกประมวลผลโดย gem [Bundler](https://github.com/carlhuda/bundler) ซึ่งจากนั้นจะติดตั้ง dependencies ทั้งหมดของคุณ มันยังสามารถติดตั้ง dependencies ทั้งหมดไปยังแอปพลิเคชันของคุณในรูปแบบ local เพื่อไม่ต้องพึ่งพา system gems

ข้อมูลเพิ่มเติม: - [bundler homepage](https://bundler.io/)

### อยู่ในเส้นขอบ

`Bundler` และ `Gemfile` ทำให้การแชร์แอปพลิเคชัน Rails ของคุณเป็นเรื่องง่ายดายด้วยคำสั่ง `bundle` ที่เฉพาะเจาะจงใหม่ หากคุณต้องการแชร์โดยตรงจาก Git repository คุณสามารถส่งผ่าน flag `--edge`:

```bash
$ rails new myapp --edge
```

หากคุณมีการ checkout ท้องถิ่นของ Rails repository และต้องการสร้างแอปพลิเคชันโดยใช้มัน คุณสามารถส่งผ่าน flag `--dev`:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

การเปลี่ยนแปลงทางสถาปัตยกรรมของ Rails
---------------------------

### Assets Pipeline

การเปลี่ยนแปลงหลักใน Rails 3.1 คือ Assets Pipeline มันทำให้ CSS และ JavaScript เป็น code citizens ระดับแรกและสามารถจัดการอย่างถูกต้องได้ รวมถึงการใช้งานใน plugins และ engines

Assets pipeline ถูกขับเคลื่อนด้วย [Sprockets](https://github.com/rails/sprockets) และอธิบายในเอกสาร [Asset Pipeline](asset_pipeline.html)

### HTTP Streaming

HTTP Streaming เป็นการเปลี่ยนแปลงอีกอย่างหนึ่งที่ใหม่ใน Rails 3.1 นี้ มันช่วยให้เบราว์เซอร์ดาวน์โหลด stylesheets และไฟล์ JavaScript ของคุณในขณะที่เซิร์ฟเวอร์กำลังสร้างการตอบสนอง นี่ต้องการ Ruby 1.9.2 เป็นตัวเลือกและต้องการการสนับสนุนจากเว็บเซิร์ฟเวอร์ด้วย แต่คู่สุดยอดของ NGINX และ Unicorn พร้อมที่จะใช้ประโยชน์จากมัน

### ไลบรารี JS เริ่มต้นคือ jQuery

jQuery เป็นไลบรารี JavaScript เริ่มต้นที่มาพร้อมกับ Rails 3.1 แต่หากคุณใช้ Prototype มันง่ายที่จะสลับ

```bash
$ rails new myapp -j prototype
```

### Identity Map

Active Record มี Identity Map ใน Rails 3.1 แผนที่ Identity Map เก็บบันทึกที่เคยสร้างและคืนวัตถุที่เกี่ยวข้องกับบันทึกเมื่อเข้าถึงอีกครั้ง แผนที่ Identity ถูกสร้างขึ้นตามคำขอและถูกล้างเมื่อคำขอเสร็จสมบูรณ์

Rails 3.1 มาพร้อมกับ Identity Map ที่ปิดใช้งานโดยค่าเริ่มต้น

Railties
--------

* jQuery เป็นไลบรารี JavaScript เริ่มต้นใหม่

* jQuery และ Prototype ไม่ได้ถูก vendored และจะให้จากตอนนี้ไปเป็นไลบรารี `jquery-rails` และ `prototype-rails`

* ตัวสร้างแอปพลิเคชันยอมรับตัวเลือก `-j` ซึ่งสามารถเป็นสตริงอะไรก็ได้ หากส่ง "foo" จะเพิ่ม gem "foo-rails" ใน `Gemfile` และแอปพลิเคชัน JavaScript manifest จะต้องการ "foo" และ "foo_ujs" ในปัจจุบันมีเพียง "prototype-rails" และ "jquery-rails" ที่มีและให้ไฟล์เหล่านี้ผ่าน asset pipeline

* การสร้างแอปพลิเคชันหรือ plugin จะเรียกใช้ `bundle install` ถ้าไม่ระบุ `--skip-gemfile` หรือ `--skip-bundle`

* ตัวสร้าง controller และ resource จะสร้าง asset stubs โดยอัตโนมัติ (สามารถปิดใช้งานได้ด้วย `--skip-assets`) เหล่า stubs เหล่านี้จะใช้ CoffeeScript และ Sass หากมีไลบรารีเหล่านี้ให้ใช้งาน

* Scaffold และ app generators ใช้รูปแบบ hash สไตล์ Ruby 1.9 เมื่อทำงานบน Ruby 1.9 หากต้องการสร้าง hash สไตล์เก่าสามารถส่ง `--old-style-hash` ได้

* Scaffold controller generator สร้างบล็อกรูปแบบสำหรับ JSON แทน XML

* การบันทึก Active Record ถูกนำไปยัง STDOUT และแสดงในคอนโซล

* เพิ่มการกำหนดค่า `config.force_ssl` ซึ่งโหลด `Rack::SSL` middleware และบังคับให้คำขอทั้งหมดอยู่ในโปรโตคอล HTTPS

* เพิ่มคำสั่ง `rails plugin new` ที่สร้าง Rails plugin พร้อมกับ gemspec, tests และ dummy application สำหรับการทดสอบ
* เพิ่ม `Rack::Etag` และ `Rack::ConditionalGet` เข้าไปในสแต็กของ middleware เริ่มต้น

* เพิ่ม `Rack::Cache` เข้าไปในสแต็กของ middleware เริ่มต้น

* อัปเดต Engines - คุณสามารถ mount ได้ที่เส้นทางใดก็ได้, เปิดใช้งาน assets, รัน generators, เป็นต้น

Action Pack
-----------

### Action Controller

* แจ้งเตือนเมื่อไม่สามารถยืนยันความถูกต้องของ CSRF token ได้

* ระบุ `force_ssl` ใน controller เพื่อบังคับเบราว์เซอร์ให้ถ่ายโอนข้อมูลผ่านโปรโตคอล HTTPS ใน controller นั้น ๆ หากต้องการจำกัดเฉพาะการกระทำบางอย่าง สามารถใช้ `:only` หรือ `:except` ได้

* พารามิเตอร์ของ query string ที่เป็นข้อมูลที่สำคัญที่ระบุใน `config.filter_parameters` จะถูกกรองออกจากเส้นทางของคำขอในบันทึก

* พารามิเตอร์ URL ที่คืนค่า `nil` สำหรับ `to_param` จะถูกลบออกจาก query string

* เพิ่ม `ActionController::ParamsWrapper` เพื่อแพ็คเกจพารามิเตอร์เป็นแฮชซ้อนกัน และจะถูกเปิดใช้งานสำหรับ JSON request ในแอปพลิเคชันใหม่ตามค่าเริ่มต้น สามารถปรับแต่งได้ใน `config/initializers/wrap_parameters.rb`

* เพิ่ม `config.action_controller.include_all_helpers` โดยค่าเริ่มต้น `helper :all` จะถูกทำใน `ActionController::Base` ซึ่งรวมเข้ากับ helpers ทั้งหมดโดยค่าเริ่มต้น การตั้งค่า `include_all_helpers` เป็น `false` จะทำให้รวมเข้ากับ application_helper เท่านั้นและ helper ที่สอดคล้องกับ controller (เช่น foo_helper สำหรับ foo_controller)

* `url_for` และ named URL helpers ตอนนี้ยอมรับ `:subdomain` และ `:domain` เป็นตัวเลือก

* เพิ่ม `Base.http_basic_authenticate_with` เพื่อทำการตรวจสอบความถูกต้องของการรับรองความปลอดภัยของ http basic ด้วยการเรียกใช้เมธอดคลาสเดียว

    ```ruby
    class PostsController < ApplicationController
      USER_NAME, PASSWORD = "dhh", "secret"

      before_filter :authenticate, :except => [ :index ]

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end

      private
        def authenticate
          authenticate_or_request_with_http_basic do |user_name, password|
            user_name == USER_NAME && password == PASSWORD
          end
        end
    end
    ```

    ..สามารถเขียนได้เป็น

    ```ruby
    class PostsController < ApplicationController
      http_basic_authenticate_with :name => "dhh", :password => "secret", :except => :index

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end
    end
    ```

* เพิ่มการสนับสนุนการสตรีมมิ่ง คุณสามารถเปิดใช้งานได้ด้วย:

    ```ruby
    class PostsController < ActionController::Base
      stream
    end
    ```

    คุณสามารถจำกัดได้เฉพาะการกระทำบางอย่างโดยใช้ `:only` หรือ `:except` โปรดอ่านเอกสารที่ [`ActionController::Streaming`](https://api.rubyonrails.org/v3.1.0/classes/ActionController/Streaming.html) เพื่อข้อมูลเพิ่มเติม

* เมธอดเส้นทางการเปลี่ยนเส้นทางตอนนี้ยอมรับแม้ว่าจะเป็นแฮชของตัวเลือกที่จะเปลี่ยนส่วนของ URL ที่เกี่ยวข้อง หรือวัตถุที่ตอบสนองกับการเรียกใช้งาน ทำให้สามารถใช้งานเส้นทางการเปลี่ยนเส้นทางได้ซ้ำใช้งานได้

### Action Dispatch

* `config.action_dispatch.x_sendfile_header` ตอนนี้มีค่าเริ่มต้นเป็น `nil` และ `config/environments/production.rb` ไม่ตั้งค่าใด ๆ ให้กับมัน สิ่งนี้ทำให้เซิร์ฟเวอร์สามารถตั้งค่าได้ผ่าน `X-Sendfile-Type`

* `ActionDispatch::MiddlewareStack` ตอนนี้ใช้คอมโพสิชันแทนการสืบทอดและไม่ใช่อาร์เรย์อีกต่อไป

* เพิ่ม `ActionDispatch::Request.ignore_accept_header` เพื่อละเว้นเฮดเดอร์ที่ยอมรับ

* เพิ่ม `Rack::Cache` เข้าไปในสแต็กเริ่มต้น

* ย้ายความรับผิดชอบของ etag จาก `ActionDispatch::Response` ไปยังสแต็กของ middleware

* พึ่งพากับ `Rack::Session` stores API เพื่อให้เข้ากันได้มากขึ้นในโลกของ Ruby ซึ่งเป็นไม่เข้ากันได้ย้อนกลับเนื่องจาก `Rack::Session` คาดหวังให้ `#get_session` ยอมรับพารามิเตอร์สี่ตัวและต้องการ `#destroy_session` แทนที่จะใช้งานเพียง `#destroy` เท่านั้น

* การค้นหาเทมเพลตตอนนี้ค้นหาไปในสายลูกของการสืบทอด

### Action View

* เพิ่มตัวเลือก `:authenticity_token` ให้กับ `form_tag` เพื่อการจัดการที่กำหนดเองหรือการละเว้น token โดยการส่ง `:authenticity_token => false`

* สร้าง `ActionView::Renderer` และระบุ API สำหรับ `ActionView::Context`

* การเปลี่ยนแปลงใน `SafeBuffer` ในที่เดียวไม่ได้รับอนุญาตใน Rails 3.1

* เพิ่ม helper `button_tag` สำหรับ HTML5

* `file_field` จะเพิ่ม `:multipart => true` ให้กับฟอร์มที่ห่อหุ้ม

* เพิ่มวิธีที่สะดวกในการสร้าง HTML5 data-* attributes ใน tag helpers จาก `:data` แฮชของตัวเลือก:

    ```ruby
    tag("div", :data => {:name => 'Stephen', :city_state => %w(Chicago IL)})
    # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
    ```

    คีย์จะถูกแยกเป็นขีดกลาง ค่าจะถูกเข้ารหัสเป็น JSON ยกเว้นสตริงและสัญลักษณ์
* `csrf_meta_tag` ถูกเปลี่ยนชื่อเป็น `csrf_meta_tags` และเปลี่ยนชื่อเลียนแบบ `csrf_meta_tag` เพื่อรองรับการใช้ย้อนกลับ

* API ตัวจัดการเทมเพลตเก่าถูกยกเลิกและ API ใหม่ต้องการตัวจัดการเทมเพลตให้ตอบสนองกับการเรียกใช้

* rhtml และ rxml ถูกลบออกจากตัวจัดการเทมเพลต

* `config.action_view.cache_template_loading` ถูกนำกลับมาซึ่งช่วยให้สามารถตัดสินใจว่าจะใช้แคชเทมเพลตหรือไม่

* ช่วยให้ `FormHelper#form_for` สามารถระบุ `:method` เป็นตัวเลือกโดยตรงแทนที่จะใช้ผ่าน `:html` hash ได้ `form_for(@post, remote: true, method: :delete)` แทนที่จะใช้ `form_for(@post, remote: true, html: { method: :delete })`

* ให้ `JavaScriptHelper#j()` เป็นชื่อย่อสำหรับ `JavaScriptHelper#escape_javascript()` ซึ่งเป็นการแทนที่ `Object#j()` ที่ JSON gem เพิ่มในเทมเพลตโดยใช้ JavaScriptHelper

* อนุญาตให้ใช้รูปแบบ AM/PM ในตัวเลือกเลือกวันเวลา

* `auto_link` ถูกลบออกจาก Rails และถูกแยกออกเป็น [rails_autolink gem](https://github.com/tenderlove/rails_autolink)

Active Record
-------------

* เพิ่มเมธอดคลาส `pluralize_table_names` เพื่อทำให้เปลี่ยนชื่อตารางของโมเดลแต่ละรายการเป็นรูปพจน์/เอกพจน์ ก่อนหน้านี้สามารถตั้งค่าได้ทั้งระบบสำหรับโมเดลทั้งหมดผ่าน `ActiveRecord::Base.pluralize_table_names`

    ```ruby
    class User < ActiveRecord::Base
      self.pluralize_table_names = false
    end
    ```

* เพิ่มการตั้งค่าแบบบล็อกของแอตทริบิวต์ในส่วนตัว บล็อกจะถูกเรียกหลังจากตัวอินสแตนซ์ถูกเริ่มต้น

    ```ruby
    class User < ActiveRecord::Base
      has_one :account
    end

    user.build_account{ |a| a.credit_limit = 100.0 }
    ```

* เพิ่ม `ActiveRecord::Base.attribute_names` เพื่อให้ส่งคืนรายการชื่อแอตทริบิวต์ ซึ่งจะส่งคืนอาร์เรย์ว่างหากโมเดลเป็นแบบหน้าที่หรือตารางไม่มีอยู่

* รูปแบบ CSV Fixtures ถูกยกเลิกและจะถูกลบออกใน Rails 3.2.0

* `ActiveRecord#new`, `ActiveRecord#create` และ `ActiveRecord#update_attributes` สามารถยอมรับแฮชที่สองเป็นตัวเลือกที่ช่วยให้คุณสามารถระบุบที่จะพิจารณาเมื่อกำหนดแอตทริบิวต์ได้ สิ่งนี้ถูกสร้างขึ้นบนความสามารถใหม่ในการกำหนดค่าแบบมวลส่ง

    ```ruby
    class Post < ActiveRecord::Base
      attr_accessible :title
      attr_accessible :title, :published_at, :as => :admin
    end

    Post.new(params[:post], :as => :admin)
    ```

* `default_scope` สามารถรับบล็อก, แลมบ์ดา หรืออ็อบเจกต์อื่น ๆ ที่ตอบสนองกับการเรียกใช้งานที่เกิดขึ้นเมื่อต้องการ

* ค่าเริ่มต้นของขอบเขตถูกประเมินในเวลาล่าสุดเพื่อหลีกเลี่ยงปัญหาที่ขอบเขตจะถูกสร้างขึ้นซึ่งจะมีขอบเขตเริ่มต้นที่ประกอบด้วยขอบเขตเริ่มต้น ซึ่งจะเป็นไปไม่ได้ที่จะกำจัดผ่าน Model.unscoped

* อแดปเตอร์ PostgreSQL เท่านั้นที่รองรับเวอร์ชัน PostgreSQL เวอร์ชัน 8.2 และสูงกว่า

* มิดเวียร์ `ConnectionManagement` ถูกเปลี่ยนแปลงเพื่อทำความสะอาดคอนเน็กชันพูลหลังจากที่รักษาได้รับการล้าง

* เพิ่มเมธอด `update_column` ใน Active Record เมธอดใหม่นี้จะอัปเดตแอตทริบิวต์ที่กำหนดให้กับออบเจกต์โดยข้ามการตรวจสอบและการเรียกใช้งานคอลแบ็ค แนะนำให้ใช้ `update_attributes` หรือ `update_attribute` ยกเว้นกรณีที่แน่ใจว่าคุณไม่ต้องการที่จะดำเนินการใด ๆ ที่เกี่ยวข้องกับคอลัมน์ `updated_at` ไม่ควรเรียกใช้กับเรคคอร์ดใหม่

* ความสัมพันธ์ที่มีตัวเลือก `:through` สามารถใช้การสัมพันธ์ใด ๆ เป็นการสัมพันธ์ผ่านหรือการสัมพันธ์แหล่งที่มีตัวเลือก `:through` และการสัมพันธ์ `has_and_belongs_to_many`

* การกำหนดค่าสำหรับการเชื่อมต่อฐานข้อมูลปัจจุบันสามารถเข้าถึงได้ผ่าน `ActiveRecord::Base.connection_config`

* ลบ limits และ offsets จากคำสั่ง COUNT หากไม่ได้ระบุทั้งสอง

    ```ruby
    People.limit(1).count           # => 'SELECT COUNT(*) FROM people'
    People.offset(1).count          # => 'SELECT COUNT(*) FROM people'
    People.limit(1).offset(1).count # => 'SELECT COUNT(*) FROM people LIMIT 1 OFFSET 1'
    ```

* `ActiveRecord::Associations::AssociationProxy` ถูกแยกออกเป็นสองส่วน มีคลาส `Association` (และคลาสย่อย) ที่รับผิดชอบในการดำเนินการกับการสัมพันธ์ และมีตัวครอบที่แยกออกมาเป็นเล็กน้อยที่เรียกว่า `CollectionProxy` ซึ่งเป็นตัวครอบที่บางส่วนสำหรับการสัมพันธ์กลุ่ม สิ่งนี้ช่วยป้องกันการปนเปื้อนของเนมสเปซ แยกสิ่งที่สนใจและจะช่วยให้สามารถทำการรีแฟคเตอร์เพิ่มเติมได้

* การสัมพันธ์แบบเอกพจน์ (`has_one`, `belongs_to`) ไม่มีพร็อกซีอีกต่อไปและเพียงแค่ส่งคืนเรคคอร์ดที่เกี่ยวข้องหรือ `nil` นี่หมายความว่าคุณไม่ควรใช้เมธอดที่ไม่ได้รับการเอกสารอย่าง `bob.mother.create` - ใช้ `bob.create_mother` แทน
* รองรับตัวเลือก `:dependent` ในการสร้างความสัมพันธ์ `has_many :through` สำหรับเหตุผลทางประวัติศาสตร์และทางปฏิบัติ การลบโดยค่าเริ่มต้นที่ใช้ในการลบคือ `:delete_all` แม้ว่าค่าเริ่มต้นจะเป็น `:nullify` สำหรับ has_many ทั่วไป นอกจากนี้ การทำงานนี้เป็นไปได้เฉพาะเมื่อ source reflection เป็น belongs_to สำหรับสถานการณ์อื่น ๆ คุณควรแก้ไขการสร้างความสัมพันธ์ผ่านตัวแทนโดยตรง

* พฤติกรรมของ `association.destroy` สำหรับ `has_and_belongs_to_many` และ `has_many :through` ถูกเปลี่ยนแปลง ตั้งแต่ตอนนี้ไป เราจะตัดสินใจว่า 'destroy' หรือ 'delete' ในการสร้างความสัมพันธ์หมายถึง 'กำจัดลิงก์' ไม่ได้หมายถึง 'กำจัดระเบียนที่เกี่ยวข้อง' (อาจจะไม่เป็นไปตามที่คาดไว้)

* ก่อนหน้านี้ `has_and_belongs_to_many.destroy(*records)` จะทำลายระเบียนเอง แต่จะไม่ลบระเบียนในตารางเชื่อมโยง ตอนนี้จะลบระเบียนในตารางเชื่อมโยง

* ก่อนหน้านี้ `has_many_through.destroy(*records)` จะทำลายระเบียนเองและระเบียนในตารางเชื่อมโยง [หมายเหตุ: นี่ไม่ได้เป็นกรณีที่เกิดขึ้นเสมอ รุ่นก่อนหน้าของ Rails จะลบเฉพาะระเบียนเองเท่านั้น] ตอนนี้จะทำลายเฉพาะระเบียนในตารางเชื่อมโยง

* โปรดทราบว่าการเปลี่ยนแปลงนี้เป็นการเปลี่ยนแปลงที่ไม่สามารถทำให้เกิดความไม่สัมพันธ์ได้ แต่เสียอย่างไม่น่าเสียดายว่าไม่มีทาง 'ยุติ' ก่อนที่จะเปลี่ยนแปลง การเปลี่ยนแปลงนี้กำลังดำเนินการเพื่อให้มีความสอดคล้องในความหมายของ 'destroy' หรือ 'delete' ในประเภทการสร้างความสัมพันธ์ที่แตกต่างกัน หากคุณต้องการที่จะทำลายระเบียนเองคุณสามารถทำได้โดยใช้ `records.association.each(&:destroy)` 

* เพิ่มตัวเลือก `:bulk => true` ใน `change_table` เพื่อทำให้การเปลี่ยนแปลง schema ที่กำหนดในบล็อกใช้คำสั่ง ALTER เดียว

    ```ruby
    change_table(:users, :bulk => true) do |t|
      t.string :company_name
      t.change :birthdate, :datetime
    end
    ```

* เอาออกการเข้าถึง attributes บนตารางเชื่อมโยง `has_and_belongs_to_many` แทนที่จะใช้ `has_many :through`

* เพิ่มเมธอด `create_association!` สำหรับการสร้างความสัมพันธ์ `has_one` และ `belongs_to`

* การเคลื่อนย้ายตอนนี้สามารถย้อนกลับได้ ซึ่งหมายความว่า Rails จะคิดวิธีการย้อนกลับการเคลื่อนย้ายของคุณ ในการใช้งานการเคลื่อนย้ายที่สามารถย้อนกลับได้ เพียงแค่กำหนดเมธอด `change`

    ```ruby
    class MyMigration < ActiveRecord::Migration
      def change
        create_table(:horses) do |t|
          t.column :content, :text
          t.column :remind_at, :datetime
        end
      end
    end
    ```

* บางสิ่งบางอย่างไม่สามารถย้อนกลับโดยอัตโนมัติได้ หากคุณรู้วิธีการย้อนกลับสิ่งเหล่านั้นคุณควรกำหนด `up` และ `down` ในการเคลื่อนย้ายของคุณ หากคุณกำหนดสิ่งใดสิ่งหนึ่งในการเปลี่ยนแปลงที่ไม่สามารถย้อนกลับได้ จะเกิดข้อยกเว้น `IrreversibleMigration` เมื่อกำลังลดระดับ

* การเคลื่อนย้ายใช้เมธอดของอินสแตนซ์แทนเมธอดของคลาส:

    ```ruby
    class FooMigration < ActiveRecord::Migration
      def up # ไม่ใช่ self.up
        # ...
      end
    end
    ```

* ไฟล์การเคลื่อนย้ายที่สร้างจากโมเดลและเครื่องมือสร้างการเคลื่อนย้ายที่สร้าง (ตัวอย่างเช่น add_name_to_users) ใช้เมธอดการเคลื่อนย้ายที่สามารถย้อนกลับได้ `change` แทนเมธอด `up` และ `down` ทั่วไป

* เอาออกการสนับสนุนในการตัดสินใจเงื่อนไข SQL บนการสร้างความสัมพันธ์ แทนที่ควรใช้ proc

    ```ruby
    has_many :things, :conditions => 'foo = #{bar}'          # ก่อนหน้า
    has_many :things, :conditions => proc { "foo = #{bar}" } # ตอนนี้
    ```

    ภายใน proc `self` คือวัตถุที่เป็นเจ้าของของความสัมพันธ์ ยกเว้นถ้าคุณกำลังโหลดความสัมพันธ์อย่างรวดเร็ว `self` คือคลาสที่ความสัมพันธ์อยู่ภายใน

    คุณสามารถใช้เงื่อนไข "ปกติ" ใน proc ดังนั้นตัวอย่างต่อไปนี้จะทำงานได้เช่นกัน:

    ```ruby
    has_many :things, :conditions => proc { ["foo = ?", bar] }
    ```

* ก่อนหน้านี้ `:insert_sql` และ `:delete_sql` ในการสร้างความสัมพันธ์ `has_and_belongs_to_many` ช่วยให้คุณเรียกใช้ 'record' เพื่อรับระเบียนที่กำลังถูกแทรกหรือลบ ตอนนี้มีการส่งผ่านเป็นอาร์กิวเมนต์ให้กับ proc

* เพิ่ม `ActiveRecord::Base#has_secure_password` (ผ่าน `ActiveModel::SecurePassword`) เพื่อแยกการใช้รหัสผ่านที่ง่ายมากกับการเข้ารหัสและการเก็บเกี่ยวกับ BCrypt

    ```ruby
    # โครงสร้าง: User(name:string, password_digest:string, password_salt:string)
    class User < ActiveRecord::Base
      has_secure_password
    end
    ```

* เมื่อสร้างโมเดล `add_index` ถูกเพิ่มโดยค่าเริ่มต้นสำหรับคอลัมน์ `belongs_to` หรือ `references`
* การตั้งค่า id ของวัตถุ `belongs_to` จะอัปเดตการอ้างอิงไปยังวัตถุ

* การทำงานของ `ActiveRecord::Base#dup` และ `ActiveRecord::Base#clone` ได้เปลี่ยนแปลงให้ใกล้เคียงกับการทำงานของ dup และ clone ของ Ruby ปกติ

* เรียกใช้ `ActiveRecord::Base#clone` จะทำให้ได้รับการคัดลอกที่เป็น shallow copy ของเรคคอร์ด รวมถึงการคัดลอกสถานะที่ถูกแช่แข็ง ไม่มีการเรียกใช้ callback

* เรียกใช้ `ActiveRecord::Base#dup` จะทำการคัดลอกเรคคอร์ด รวมถึงการเรียกใช้ after initialize hooks สถานะที่ถูกแช่แข็งจะไม่ถูกคัดลอก และการเชื่อมโยงทั้งหมดจะถูกล้าง ระเบียนที่ถูกคัดลอกจะคืนค่า `true` สำหรับ `new_record?` มีฟิลด์ id เป็น `nil` และสามารถบันทึกได้

* แคชคิวรีตอนเรียกของทำงานกับคำสั่งที่เตรียมไว้ ไม่ต้องมีการเปลี่ยนแปลงในแอปพลิเคชัน

Active Model
------------

* `attr_accessible` ยอมรับตัวเลือก `:as` เพื่อระบุบทบาท

* `InclusionValidator`, `ExclusionValidator`, และ `FormatValidator` ตอนนี้ยอมรับตัวเลือกที่อาจเป็น proc, lambda, หรืออะไรก็ตามที่ตอบสนองกับ `call` ตัวเลือกนี้จะถูกเรียกใช้งานกับเรคคอร์ดปัจจุบันเป็นอาร์กิวเมนต์และคืนค่าวัตถุที่ตอบสนองกับ `include?` สำหรับ `InclusionValidator` และ `ExclusionValidator` และคืนค่าวัตถุประเภท regular expression สำหรับ `FormatValidator`

* เพิ่ม `ActiveModel::SecurePassword` เพื่อแยกการใช้รหัสผ่านที่ง่ายดายด้วยการเข้ารหัสและการเก็บเกี่ยวกับ BCrypt

* `ActiveModel::AttributeMethods` อนุญาตให้กำหนดแอตทริบิวต์ตามความต้องการ

* เพิ่มการสนับสนุนในการเปิดใช้งานและปิดใช้งาน observers ได้เลือกทำงาน

* ไม่สนับสนุนการค้นหาชื่อเนมสเปซแบบอื่นแล้ว

Active Resource
---------------

* รูปแบบเริ่มต้นถูกเปลี่ยนเป็น JSON สำหรับคำขอทั้งหมด หากคุณต้องการที่จะใช้ XML ต่อไปคุณจะต้องตั้งค่า `self.format = :xml` ในคลาส เช่น

    ```ruby
    class User < ActiveResource::Base
      self.format = :xml
    end
    ```

Active Support
--------------

* `ActiveSupport::Dependencies` ตอนนี้เรียกขึ้น `NameError` หากพบค่าคงที่ที่มีอยู่ใน `load_missing_constant`

* เพิ่มเมธอดรายงานใหม่ `Kernel#quietly` ซึ่งทำให้เงียบสงบทั้ง `STDOUT` และ `STDERR`

* เพิ่ม `String#inquiry` เป็นเมธอดสะดวกสำหรับแปลงสตริงเป็นวัตถุ `StringInquirer`

* เพิ่ม `Object#in?` เพื่อทดสอบว่าวัตถุหนึ่งอยู่ในวัตถุอื่นหรือไม่

* กลยุทธ์ `LocalCache` ตอนนี้เป็นคลาส middleware จริงและไม่ใช่คลาสที่ไม่มีชื่อ

* มีการเพิ่มคลาส `ActiveSupport::Dependencies::ClassCache` เพื่อเก็บอ้างอิงไว้สำหรับคลาสที่สามารถโหลดใหม่ได้

* `ActiveSupport::Dependencies::Reference` ได้รับการรีแฟคเตอร์เพื่อใช้ประโยชน์จาก `ClassCache` ใหม่

* สำรอง `Range#cover?` เป็นตัวย่อสำหรับ `Range#include?` ใน Ruby 1.8

* เพิ่ม `weeks_ago` และ `prev_week` สำหรับ Date/DateTime/Time

* เพิ่ม `before_remove_const` callback ให้กับ `ActiveSupport::Dependencies.remove_unloadable_constants!`

การเลิกใช้งาน:

* `ActiveSupport::SecureRandom` ถูกเลิกใช้งานแล้วและแนะนำให้ใช้ `SecureRandom` จากไลบรารีมาตรฐานของ Ruby

เครดิต
-------

ดู [รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](https://contributors.rubyonrails.org/) สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและแข็งแรง ยินดีด้วยทุกคน

บันทึกการเปิดตัว Rails 3.1 ได้รับการรวบรวมโดย [Vijay Dev](https://github.com/vijaydev)
