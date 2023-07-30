**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: da25f37b5b3eddff86c5b5b2cd24007f
เอกสารปล่อยตัวของ Ruby on Rails 3.1
===============================

จุดเด่นใน Rails 3.1:

* Streaming
* Reversible Migrations
* Assets Pipeline
* jQuery เป็นไลบรารี JavaScript เริ่มต้น

เอกสารปล่อยตัวนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่เรื่องราวการเปลี่ยนแปลงหรือตรวจสอบ [รายการของการเปลี่ยนแปลง](https://github.com/rails/rails/commits/3-1-stable) ในเก็บรวบรวมของ Rails ที่หลักบน GitHub

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 3.1
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดไปยัง Rails 3 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตไปยัง Rails 3.1 จากนั้นให้ทำตามขั้นตอนต่อไปนี้:

### Rails 3.1 ต้องการ Ruby 1.8.7 หรือสูงกว่า

Rails 3.1 ต้องการ Ruby 1.8.7 หรือสูงกว่า การสนับสนุนสำหรับรุ่น Ruby ก่อนหน้านี้ทั้งหมดถูกยกเลิกอย่างเป็นทางการและคุณควรอัปเกรดให้เร็วที่สุด  Rails 3.1 ยังเข้ากันได้กับ Ruby 1.9.2

เคล็ดลับ: โปรดทราบว่า Ruby 1.8.7 p248 และ p249 มีข้อบกพร่องในการมาร์ชลิ่งที่ทำให้ระบบล้มเหลว แต่ Ruby Enterprise Edition ได้แก้ไขปัญหาเหล่านี้ตั้งแต่เวอร์ชัน 1.8.7-2010.02 สำหรับเวอร์ชัน 1.9  Ruby 1.9.1 ไม่สามารถใช้งานได้เพราะมีข้อบกพร่องที่รุนแรง ดังนั้นหากคุณต้องการใช้ 1.9.x ควรใช้เวอร์ชัน 1.9.2 เพื่อความราบรื่น

### อัปเดตในแอปพลิเคชันของคุณ

การเปลี่ยนแปลงต่อไปนี้เหมาะสำหรับการอัปเกรดแอปพลิเคชันของคุณไปยัง Rails 3.1.3 เวอร์ชันล่าสุดของ Rails 3.1.x

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
    # อย่าบีบอัดทรัพยากร
    config.assets.compress = false

    # ขยายบรรทัดที่โหลดทรัพยากร
    config.assets.debug = true
    ```

#### config/environments/production.rb

* อีกครั้ง, การเปลี่ยนแปลงส่วนใหญ่ด้านล่างเป็นสำหรับ asset pipeline คุณสามารถอ่านเพิ่มเติมเกี่ยวกับเรื่องนี้ใน [Asset Pipeline](asset_pipeline.html) ได้

    ```ruby
    # บีบอัด JavaScripts และ CSS
    config.assets.compress = true

    # ไม่ต้องสลับกลับไปที่ asset pipeline หากไม่พบทรัพยากรที่ถูกสร้างไว้ล่วงหน้า
    config.assets.compile = false

    # สร้างเลขรหัสสำหรับ URL ของทรัพยากร
    config.assets.digest = true

    # ค่าเริ่มต้นคือ Rails.root.join("public/assets")
    # config.assets.manifest = YOUR_PATH

    # ทำการสร้างทรัพยากรเพิ่มเติม (application.js, application.css, และทรัพยากรที่ไม่ใช่ JS/CSS ทั้งหมดถูกเพิ่มไว้แล้ว)
    # config.assets.precompile `= %w( admin.js admin.css )


    # บังคับให้เข้าถึงแอปผ่าน SSL, ใช้ Strict-Transport-Security, และใช้ secure cookies.
    # config.force_ssl = true
    ```

#### config/environments/test.rb

```ruby
# กำหนดค่าเซิร์ฟเวอร์ทรัพยากรแบบสถิตในการทดสอบพร้อมกับ Cache-Control เพื่อเพิ่มประสิทธิภาพ
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```
#### config/initializers/wrap_parameters.rb

* เพิ่มไฟล์นี้พร้อมเนื้อหาดังต่อไปนี้หากคุณต้องการแพ็คเกจพารามิเตอร์เข้ากับแฮชซ้อนกัน ซึ่งมีการเปิดใช้งานโดยค่าเริ่มต้นในแอปพลิเคชันใหม่

    ```ruby
    # ตรวจสอบให้แน่ใจว่าคุณเริ่มเซิร์ฟเวอร์ของคุณใหม่เมื่อคุณแก้ไขไฟล์นี้
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

#### ลบตัวเลือก :cache และ :concat ในการอ้างอิงเฮลเปอร์ของแอสเซ็ทในวิว

* ด้วย Asset Pipeline ตัวเลือก :cache และ :concat ไม่ได้ใช้งานอีกต่อไป ลบตัวเลือกเหล่านี้ออกจากวิวของคุณ

การสร้างแอปพลิเคชัน Rails 3.1
--------------------------------

```bash
# คุณควรมี 'rails' RubyGem ติดตั้งแล้ว
$ rails new myapp
$ cd myapp
```

### การเก็บเอาไว้ในแฟ้ม

Rails ใช้ `Gemfile` ในรากแอปพลิเคชันเพื่อกำหนดแพ็คเกจที่คุณต้องการสำหรับแอปพลิเคชันของคุณให้เริ่มต้น ไฟล์ `Gemfile` นี้จะถูกประมวลผลโดยแพ็คเกจ [Bundler](https://github.com/carlhuda/bundler) ซึ่งจะติดตั้งแพ็คเกจทั้งหมดที่คุณต้องการ มันยังสามารถติดตั้งแพ็คเกจทั้งหมดไว้ในแอปพลิเคชันของคุณเพื่อไม่ต้องพึ่งพาแพ็คเกจของระบบ

ข้อมูลเพิ่มเติม: - [หน้าหลัก bundler](https://bundler.io/)

### อาศัยอยู่บนเส้นขอบ

`Bundler` และ `Gemfile` ทำให้การแช่แข็งแอปพลิเคชัน Rails ของคุณง่ายเหมือนพาย ด้วยคำสั่ง `bundle` ที่มีไว้เฉพาะการแช่แข็ง หากคุณต้องการแพ็คเกจโดยตรงจากที่เก็บ Git คุณสามารถส่งผ่านตัวเลือก `--edge`:

```bash
$ rails new myapp --edge
```

หากคุณมีการเช็คเอาต์ท้องถิ่นของเก็บรักษาของ Rails และต้องการสร้างแอปพลิเคชันโดยใช้นั้นคุณสามารถส่งผ่านตัวเลือก `--dev`:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

การเปลี่ยนแปลงทางสถาปัตยกรรมของ Rails
---------------------------

### พายไลน์ทรัพยากร

การเปลี่ยนแปลงหลักใน Rails 3.1 คือพายไลน์ทรัพยากร มันทำให้ CSS และ JavaScript เป็นโค้ดพลังงานแรกชั้นและเปิดให้ใช้งานอย่างถูกต้อง รวมถึงการใช้งานในปลั๊กอินและเอนจิน

พายไลน์ทรัพยากรถูกขับเคลื่อนด้วย [Sprockets](https://github.com/rails/sprockets) และอธิบายในคู่มือ [พายไลน์ทรัพยากร](asset_pipeline.html)

### HTTP Streaming

HTTP Streaming เป็นการเปลี่ยนแปลงอีกอย่างหนึ่งที่ใหม่ใน Rails 3.1 นี้ สิ่งนี้ช่วยให้เบราว์เซอร์ดาวน์โหลดสไตล์ชีตและไฟล์ JavaScript ของคุณในขณะที่เซิร์ฟเวอร์กำลังสร้างการตอบสนอง สิ่งนี้ต้องการ Ruby 1.9.2 เป็นตัวเลือกและต้องการการสนับสนุนจากเว็บเซิร์ฟเวอร์เช่นกัน แต่คู่สุดยอดของ NGINX และ Unicorn พร้อมที่จะใช้ประโยชน์จากนี้

### ไลบรารี JS เริ่มต้นคือ jQuery

jQuery เป็นไลบรารี JavaScript เริ่มต้นที่มาพร้อมกับ Rails 3.1 แต่หากคุณใช้ Prototype มันง่ายที่จะสลับ

```bash
$ rails new myapp -j prototype
```

### แผนที่ Identity

Active Record มีแผนที่ Identity ใน Rails 3.1 แผนที่ Identity จะเก็บบันทึกที่เรียกใช้แล้วไว้และคืนค่าออบเจกต์ที่เกี่ยวข้องกับบันทึกเมื่อเข้าถึงอีกครั้ง แผนที่ Identity ถูกสร้างขึ้นตามคำขอและถูกล้างเมื่อคำขอเสร็จสมบูรณ์

Rails 3.1 มาพร้อมกับแผนที่ Identity ที่ปิดใช้งานโดยค่าเริ่มต้น

Railties
--------

* jQuery เป็นไลบรารี JavaScript เริ่มต้นใหม่

* jQuery และ Prototype ไม่ได้เป็นแพ็คเกจและจะให้จากนี้ไปโดยแพ็คเกจ `jquery-rails` และ `prototype-rails`
* ตัวสร้างแอปพลิเคชันยอมรับตัวเลือก `-j` ซึ่งสามารถเป็นสตริงอะไรก็ได้ ถ้าส่ง "foo" จะเพิ่ม gem "foo-rails" เข้าไปใน `Gemfile` และแอปพลิเคชันจะต้องใช้ "foo" และ "foo_ujs" ในการจัดการ JavaScript ขณะนี้มีเพียง "prototype-rails" และ "jquery-rails" เท่านั้นที่มีและให้ไฟล์เหล่านี้ผ่านทาง asset pipeline

* การสร้างแอปพลิเคชันหรือปลั๊กอินจะเรียกใช้ `bundle install` ถ้าไม่ระบุ `--skip-gemfile` หรือ `--skip-bundle`

* ตัวสร้างคอนโทรลเลอร์และเรซอร์สจะสร้าง asset stubs โดยอัตโนมัติ (สามารถปิดการใช้งานได้ด้วย `--skip-assets`) เหล่า stubs เหล่านี้จะใช้ CoffeeScript และ Sass ถ้าไลบรารีเหล่านี้มีอยู่

* ตัวสร้าง Scaffold และ app จะใช้รูปแบบแฮชสไตล์ Ruby 1.9 เมื่อทำงานบน Ruby 1.9 สามารถสร้างแฮชสไตล์เก่าได้โดยใช้ `--old-style-hash`

* ตัวสร้างคอนโทรลเลอร์ Scaffold จะสร้างบล็อกรูปแบบสำหรับ JSON แทน XML

* การบันทึก Active Record จะถูกนำไปยัง STDOUT และแสดงในคอนโซล

* เพิ่มการกำหนดค่า `config.force_ssl` ซึ่งโหลด middleware `Rack::SSL` และบังคับให้คำขอทั้งหมดอยู่ในโปรโตคอล HTTPS

* เพิ่มคำสั่ง `rails plugin new` ซึ่งสร้างปลั๊กอิน Rails พร้อมกับ gemspec, tests และ dummy application สำหรับการทดสอบ

* เพิ่ม `Rack::Etag` และ `Rack::ConditionalGet` เข้าไปใน default middleware stack

* เพิ่ม `Rack::Cache` เข้าไปใน default middleware stack

* Engines ได้รับการอัปเดตใหญ่ - คุณสามารถ mount ได้ที่เส้นทางใดก็ได้, เปิดใช้งาน assets, รันตัวสร้าง เป็นต้น

Action Pack
-----------

### Action Controller

* จะแสดงคำเตือนถ้าไม่สามารถตรวจสอบความถูกต้องของ CSRF token authenticity ได้

* ระบุ `force_ssl` ในคอนโทรลเลอร์เพื่อบังคับเบราว์เซอร์ให้ถ่ายโอนข้อมูลผ่านโปรโตคอล HTTPS บนคอนโทรลเลอร์นั้นๆ สามารถจำกัดได้เฉพาะ action ที่ระบุได้โดยใช้ `:only` หรือ `:except`

* พารามิเตอร์สตริงคิวรี่ที่ระบุใน `config.filter_parameters` จะถูกกรองออกจากเส้นทางคำขอในบันทึก

* พารามิเตอร์ URL ที่ส่งค่า `nil` สำหรับ `to_param` จะถูกลบออกจากคิวรี่สตริง

* เพิ่ม `ActionController::ParamsWrapper` เพื่อห่อพารามิเตอร์เป็นแฮชที่ซ้อนกัน และจะถูกเปิดใช้งานสำหรับ JSON request ในแอปพลิเคชันใหม่ตามค่าเริ่มต้น สามารถปรับแต่งได้ใน `config/initializers/wrap_parameters.rb`

* เพิ่ม `config.action_controller.include_all_helpers` โดยค่าเริ่มต้น `helper :all` จะถูกทำใน `ActionController::Base` ซึ่งรวมเข้ากับ helpers ทั้งหมดโดยค่าเริ่มต้น การตั้งค่า `include_all_helpers` เป็น `false` จะทำให้รวมเข้ากับ application_helper เท่านั้นและ helper ที่สอดคล้องกับคอนโทรลเลอร์ (เช่น foo_helper สำหรับ foo_controller)

* `url_for` และ named URL helpers ตอนนี้ยอมรับ `:subdomain` และ `:domain` เป็นตัวเลือก

* เพิ่ม `Base.http_basic_authenticate_with` เพื่อทำการตรวจสอบความถูกต้องของการรับรองตัวตนแบบ http basic ด้วยการเรียกใช้เมธอดคลาสเดียว

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

    ..สามารถเขียนเป็น

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
* เพิ่มการสนับสนุนการสตรีมสตรีม คุณสามารถเปิดใช้งานได้ด้วย:

    ```ruby
    class PostsController < ActionController::Base
      stream
    end
    ```

    คุณสามารถจำกัดได้เฉพาะบางแอ็คชันโดยใช้ `:only` หรือ `:except` โปรดอ่านเอกสารที่ [`ActionController::Streaming`](https://api.rubyonrails.org/v3.1.0/classes/ActionController/Streaming.html) สำหรับข้อมูลเพิ่มเติม

* เมธอดเส้นทางการเปลี่ยนเส้นทางตอนนี้ยังยอมรับแฮชของตัวเลือกเป็นค่าเริ่มต้น ซึ่งจะเปลี่ยนเฉพาะส่วนที่เกี่ยวข้องกับ URL หรือวัตถุที่ตอบสนองกับการเรียกใช้งาน ทำให้สามารถใช้งานการเปลี่ยนเส้นทางได้อีกครั้ง

### Action Dispatch

* `config.action_dispatch.x_sendfile_header` ตอนนี้มีค่าเริ่มต้นเป็น `nil` และ `config/environments/production.rb` ไม่ตั้งค่าใด ๆ ให้กับมัน ซึ่งทำให้เซิร์ฟเวอร์สามารถตั้งค่าได้ผ่าน `X-Sendfile-Type`

* `ActionDispatch::MiddlewareStack` ตอนนี้ใช้การสร้างคลาสแบบคอมโพสิชันแทนการสืบทอดแบบอาร์เรย์

* เพิ่ม `ActionDispatch::Request.ignore_accept_header` เพื่อละเว้นส่วนหัวการยอมรับ

* เพิ่ม `Rack::Cache` เข้าไปในสแต็กเริ่มต้น

* ย้ายความรับผิดชอบของ etag จาก `ActionDispatch::Response` ไปยังสแต็กมิดเดิลแวร์

* พึ่งพากับ API การเก็บรักษาเซสชันของ `Rack::Session` เพื่อให้เข้ากันได้มากขึ้นในโลกของ Ruby ซึ่งเป็นการเปลี่ยนแปลงที่ไม่สามารถทำได้ย้อนกลับ เนื่องจาก `Rack::Session` คาดหวังให้ `#get_session` ยอมรับอาร์กิวเมนต์สี่ตัวและต้องการ `#destroy_session` แทนที่จะใช้งานเพียง `#destroy`

* การค้นหาเทมเพลตตอนนี้ค้นหาไปในสายการสืบทอดไกลกว่าเดิม

### Action View

* เพิ่มตัวเลือก `:authenticity_token` ให้กับ `form_tag` เพื่อการจัดการที่กำหนดเองหรือการละเว้นโทเค็นโดยการส่ง `:authenticity_token => false`

* สร้าง `ActionView::Renderer` และระบุ API สำหรับ `ActionView::Context`

* การเปลี่ยนแปลงใน `SafeBuffer` ที่เกิดขึ้นในที่นั่นถูกห้ามใน Rails 3.1

* เพิ่มตัวช่วย `button_tag` สำหรับ HTML5

* `file_field` จะเพิ่ม `:multipart => true` ให้กับฟอร์มที่ครอบอยู่โดยอัตโนมัติ

* เพิ่มวิธีที่สะดวกในการสร้างแอตทริบิวต์ `data-*` ในตัวช่วยแท็กจากแฮช `:data` ของตัวเลือก:

    ```ruby
    tag("div", :data => {:name => 'Stephen', :city_state => %w(Chicago IL)})
    # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
    ```

คีย์จะถูกแยกเป็นขีดกลาง ค่าจะถูกเข้ารหัสเป็น JSON ยกเว้นสตริงและสัญลักษณ์

* `csrf_meta_tag` ถูกเปลี่ยนชื่อเป็น `csrf_meta_tags` และตั้งชื่อเลียนแบบ `csrf_meta_tag` เพื่อความเข้ากันได้ย้อนกลับ

* API การจัดการเทมเพลตเก่าถูกยกเลิกและ API ใหม่ต้องการเพียงเทมเพลตแฮนเดอร์ที่ตอบสนองกับการเรียกใช้งาน

* rhtml และ rxml ถูกลบออกเป็นตัวจัดการเทมเพลต

* `config.action_view.cache_template_loading` ถูกนำกลับมาซึ่งช่วยให้สามารถตัดสินใจว่าเทมเพลตควรถูกเก็บไว้ในแคชหรือไม่

* ช่วยให้ `FormHelper#form_for` สามารถระบุ `:method` เป็นตัวเลือกโดยตรงแทนที่จะผ่าน `:html` ซึ่งเป็นแฮช `form_for(@post, remote: true, method: :delete)` แทนที่จะเป็น `form_for(@post, remote: true, html: { method: :delete })`

* ให้ `JavaScriptHelper#j()` เป็นตัวย่อของ `JavaScriptHelper#escape_javascript()` ซึ่งเป็นการแทนที่เมธอด `Object#j()` ที่ JSON gem เพิ่มในเทมเพลตโดยใช้ JavaScriptHelper

* อนุญาตให้ใช้รูปแบบ AM/PM ในตัวเลือกเลือกวันที่และเวลา

* `auto_link` ถูกลบออกจาก Rails และถูกแยกออกเป็น [rails_autolink gem](https://github.com/tenderlove/rails_autolink)

Active Record
-------------

* เพิ่มเมธอดคลาส `pluralize_table_names` เพื่อทำให้เปลี่ยนชื่อตารางของแต่ละโมเดลเป็นรูปพหูพจน์/เอกพจน์ ก่อนหน้านี้สามารถตั้งค่าได้ทั้งระบบสำหรับโมเดลทั้งหมดผ่าน `ActiveRecord::Base.pluralize_table_names`

    ```ruby
    class User < ActiveRecord::Base
      self.pluralize_table_names = false
    end
    ```

* เพิ่มการตั้งค่าแบบบล็อกของแอตทริบิวต์สำหรับสัมพันธ์แบบเดี่ยว บล็อกจะถูกเรียกหลังจากตัวอินสแตนซ์ถูกเริ่มต้น

    ```ruby
    class User < ActiveRecord::Base
      has_one :account
    end

    user.build_account{ |a| a.credit_limit = 100.0 }
    ```
* เพิ่ม `ActiveRecord::Base.attribute_names` เพื่อให้ส่งคืนรายการชื่อแอตทริบิวต์ ซึ่งจะส่งคืนอาร์เรย์ว่างหากโมเดลเป็นแบบสรุปหรือตารางไม่มีอยู่

* CSV Fixtures ถูกยกเลิกและจะถูกลบออกใน Rails 3.2.0

* `ActiveRecord#new`, `ActiveRecord#create` และ `ActiveRecord#update_attributes` สามารถรับแอตทริบิวต์เพิ่มเติมในรูปแบบของแฮชเป็นตัวเลือกที่ช่วยให้คุณสามารถระบุบทบาทที่จะใช้เมื่อกำหนดแอตทริบิวต์ ซึ่งสร้างขึ้นบนความสามารถใหม่ในการมอบหมายแบบมวลส่วนของ Active Model:

    ```ruby
    class Post < ActiveRecord::Base
      attr_accessible :title
      attr_accessible :title, :published_at, :as => :admin
    end

    Post.new(params[:post], :as => :admin)
    ```

* `default_scope` สามารถรับบล็อก แลมบ์ดา หรืออ็อบเจ็กต์อื่น ๆ ที่ตอบสนองกับการเรียกใช้งานที่เกิดขึ้นในภายหลัง

* Default scopes ถูกประเมินในจุดสุดท้ายที่เป็นไปได้เพื่อหลีกเลี่ยงปัญหาที่จะสร้างขอบเขตที่จะมีขอบเขตเริ่มต้นอยู่ซึ่งจะเป็นไปไม่ได้ที่จะกำจัดได้ผ่าน Model.unscoped

* อแดปเตอร์ PostgreSQL เฉพาะรองรับเวอร์ชัน PostgreSQL 8.2 และสูงกว่า

* `ConnectionManagement` middleware ถูกเปลี่ยนแปลงเพื่อทำความสะอาดเพิ่มเติมในพูลการเชื่อมต่อหลังจาก rack body ถูกส่งออก

* เพิ่มเมธอด `update_column` ใน Active Record วิธีใหม่นี้จะอัปเดตแอตทริบิวต์ที่กำหนดให้กับออบเจ็กต์โดยข้ามการตรวจสอบและการเรียกใช้งานตัวช่วย แนะนำให้ใช้ `update_attributes` หรือ `update_attribute` ยกเว้นกรณีที่แน่ใจว่าคุณไม่ต้องการทำใด ๆ จากการเรียกใช้งานตัวช่วย รวมถึงการแก้ไขคอลัมน์ `updated_at` ไม่ควรเรียกใช้กับเร็คคอร์ดใหม่

* ความสัมพันธ์ที่มีตัวเลือก `:through` สามารถใช้ความสัมพันธ์ใด ๆ เป็นตัวเลือก `through` หรือ `source` ได้ รวมถึงความสัมพันธ์อื่น ๆ ที่มีตัวเลือก `:through` และความสัมพันธ์ `has_and_belongs_to_many`

* การกำหนดค่าสำหรับการเชื่อมต่อฐานข้อมูลปัจจุบันสามารถเข้าถึงได้ผ่าน `ActiveRecord::Base.connection_config`

* ลบ limits และ offsets จากคำสั่ง COUNT หากไม่ได้ระบุทั้งสอง

    ```ruby
    People.limit(1).count           # => 'SELECT COUNT(*) FROM people'
    People.offset(1).count          # => 'SELECT COUNT(*) FROM people'
    People.limit(1).offset(1).count # => 'SELECT COUNT(*) FROM people LIMIT 1 OFFSET 1'
    ```

* `ActiveRecord::Associations::AssociationProxy` ถูกแยกออกเป็นสองส่วน มีคลาส `Association` (และคลาสย่อย) ที่รับผิดชอบในการดำเนินการกับความสัมพันธ์ และมีตัวครอบบางส่วนที่เรียกว่า `CollectionProxy` ซึ่งเป็นตัวครอบที่บางส่วนสำหรับความสัมพันธ์ของคอลเลกชัน สิ่งนี้ช่วยป้องกันการปนเปื้อนของเนมสเปซ แยกประเภทงาน และช่วยให้สามารถทำการระบบการเรียงลำดับเพิ่มเติมได้

* ความสัมพันธ์แบบเอกเทียบเท่ากัน (`has_one`, `belongs_to`) ไม่มีตัวครอบและเพียงแค่ส่งคืนเรคคอร์ดที่เกี่ยวข้องหรือ `nil` เท่านั้น นั่นหมายความว่าคุณไม่ควรใช้เมธอดที่ไม่ได้รับการเอกสารอย่าง `bob.mother.create` - ให้ใช้ `bob.create_mother` แทน

* รองรับตัวเลือก `:dependent` ในความสัมพันธ์ `has_many :through` ด้วย ด้วยเหตุผลทางประวัติศาสตร์และปฏิบัติ การลบเป็นวิธีการลบเริ่มต้นที่ใช้กับ `association.delete(*records)` แม้ว่าวิธีการเริ่มต้นจะเป็น `:nullify` สำหรับ has_many ทั่วไป นอกจากนี้ สิ่งนี้ทำงานได้เฉพาะเมื่อการสะท้อนแหล่งที่มาเป็น belongs_to เท่านั้น สำหรับสถานการณ์อื่น ๆ คุณควรแก้ไขความสัมพันธ์ผ่านทางการสร้าง

* พฤติกรรมของ `association.destroy` สำหรับ `has_and_belongs_to_many` และ `has_many :through` ถูกเปลี่ยนแปลง ตั้งแต่ตอนนี้ไปเป็นต้นไป 'destroy' หรือ 'delete' ในความสัมพันธ์จะถูกตีความว่า 'กำจัดลิงก์' ไม่ (จำเป็นต้อง) 'กำจัดเรคคอร์ดที่เกี่ยวข้อง'

* ก่อนหน้านี้ `has_and_belongs_to_many.destroy(*records)` จะทำลายเรคคอร์ดเอง แต่จะไม่ลบเรคคอร์ดในตารางเชื่อมต่อ ตอนนี้จะลบเรคคอร์ดในตารางเชื่อมต่อ
* ก่อนหน้านี้ `has_many_through.destroy(*records)` จะทำลายเรคคอร์ดเองและเรคคอร์ดในตารางเชื่อมโยง  [หมายเหตุ: ไม่ใช่ทุกเวอร์ชัน; เวอร์ชันก่อนหน้าของ Rails เฉพาะลบเรคคอร์ดเองเท่านั้น] ตอนนี้มันจะทำลายเฉพาะเรคคอร์ดในตารางเชื่อมโยงเท่านั้น

* โปรดทราบว่าการเปลี่ยนแปลงนี้เป็นการเข้ากันได้ย้อนกลับได้ในระดับหนึ่ง แต่ไม่มีวิธี 'เลิกใช้' ก่อนเปลี่ยนแปลง การเปลี่ยนแปลงนี้ถูกดำเนินการเพื่อให้มีความสอดคล้องกับความหมายของ 'ทำลาย' หรือ 'ลบ' ในประเภทการเชื่อมโยงที่แตกต่างกัน หากคุณต้องการทำลายเรคคอร์ดเอง คุณสามารถทำได้โดยใช้ `records.association.each(&:destroy)`.

* เพิ่มตัวเลือก `:bulk => true` ใน `change_table` เพื่อทำให้การเปลี่ยนแปลง schema ทั้งหมดที่กำหนดในบล็อกใช้คำสั่ง ALTER เดียว

    ```ruby
    change_table(:users, :bulk => true) do |t|
      t.string :company_name
      t.change :birthdate, :datetime
    end
    ```

* ลบการสนับสนุนในการเข้าถึงแอตทริบิวต์บนตารางเชื่อมโยง `has_and_belongs_to_many` ต้องใช้ `has_many :through` แทน

* เพิ่มเมธอด `create_association!` สำหรับการเชื่อมโยง `has_one` และ `belongs_to`

* การเคลื่อนย้ายตอนนี้สามารถย้อนกลับได้ ซึ่งหมายความว่า Rails จะคิดวิธีที่จะย้อนกลับการเคลื่อนย้ายของคุณ ในการใช้การเคลื่อนย้ายที่สามารถย้อนกลับได้ เพียงแค่กำหนดเมธอด `change`

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

* บางสิ่งบางอย่างไม่สามารถย้อนกลับได้อัตโนมัติ หากคุณรู้วิธีการย้อนกลับสิ่งเหล่านั้น คุณควรกำหนด `up` และ `down` ในการเคลื่อนย้ายของคุณ หากคุณกำหนดสิ่งใดสิ่งหนึ่งในการเปลี่ยนแปลงที่ไม่สามารถย้อนกลับได้ จะเกิดข้อยกเว้น `IrreversibleMigration` เมื่อกำลังย้อนกลับ

* การเคลื่อนย้ายใช้เมธอดของอินสแตนซ์แทนเมธอดของคลาส:

    ```ruby
    class FooMigration < ActiveRecord::Migration
      def up # ไม่ใช่ self.up
        # ...
      end
    end
    ```

* ไฟล์การเคลื่อนย้ายที่สร้างจากโมเดลและเจเนอเรเตอร์การเคลื่อนย้ายสร้างใช้เมธอดการเคลื่อนย้ายที่สามารถย้อนกลับได้ `change` แทนเมธอด `up` และ `down` ทั่วไป

* ลบการสนับสนุนในการตั้งค่าเงื่อนไข SQL แบบสตริงบนการเชื่อมโยง แทนที่ควรใช้ proc

    ```ruby
    has_many :things, :conditions => 'foo = #{bar}'          # ก่อนหน้า
    has_many :things, :conditions => proc { "foo = #{bar}" } # ตอนนี้
    ```

    ภายใน proc `self` คือออบเจ็กต์ที่เป็นเจ้าของของการเชื่อมโยง ยกเว้นถ้าคุณกำลังโหลดการเชื่อมโยงอย่างรวดเร็ว `self` คือคลาสที่การเชื่อมโยงอยู่ภายใน

    คุณสามารถใช้เงื่อนไข "ปกติ" ใน proc ดังนั้นตัวอย่างต่อไปนี้จะทำงานได้เช่นกัน:

    ```ruby
    has_many :things, :conditions => proc { ["foo = ?", bar] }
    ```

* ก่อนหน้านี้ `:insert_sql` และ `:delete_sql` บนการเชื่อมโยง `has_and_belongs_to_many` อนุญาตให้เรียกใช้ 'record' เพื่อรับเรคคอร์ดที่กำลังถูกแทรกหรือลบ ตอนนี้มันถูกส่งผ่านเป็นอาร์กิวเมนต์ให้กับ proc

* เพิ่ม `ActiveRecord::Base#has_secure_password` (ผ่าน `ActiveModel::SecurePassword`) เพื่อแยกการใช้รหัสผ่านที่ง่ายด้วยการเข้ารหัสและการเก็บเกี่ยวกับ BCrypt

    ```ruby
    # โครงสร้าง: User(name:string, password_digest:string, password_salt:string)
    class User < ActiveRecord::Base
      has_secure_password
    end
    ```

* เมื่อสร้างโมเดล `add_index` ถูกเพิ่มโดยค่าเริ่มต้นสำหรับคอลัมน์ `belongs_to` หรือ `references`

* การตั้งค่า id ของวัตถุ `belongs_to` จะอัปเดตการอ้างอิงไปยังวัตถุ

* การเข้าใช้งาน `ActiveRecord::Base#dup` และ `ActiveRecord::Base#clone` มีการเปลี่ยนแปลงในลักษณะที่ใกล้เคียงกับคำสั่ง dup และ clone ของ Ruby ปกติ
* เรียกใช้ `ActiveRecord::Base#clone` จะทำให้ได้รับการคัดลอกที่เป็น shallow copy ของเรคคอร์ด รวมถึงการคัดลอกสถานะที่ถูกแช่แข็ง ไม่มีการเรียกใช้ callback

* เรียกใช้ `ActiveRecord::Base#dup` จะทำการคัดลอกเรคคอร์ด รวมถึงการเรียกใช้ after initialize hooks สถานะที่ถูกแช่แข็งจะไม่ถูกคัดลอก และการเชื่อมต่อทั้งหมดจะถูกล้าง รายการที่ถูกคัดลอกจะส่งคืนค่า `true` สำหรับ `new_record?` มีฟิลด์ id เป็น `nil` และสามารถบันทึกได้

* แคชคิวรี่ทำงานกับ prepared statements ตอนนี้ ไม่จำเป็นต้องเปลี่ยนแปลงในแอปพลิเคชัน

Active Model
------------

* `attr_accessible` ยอมรับตัวเลือก `:as` เพื่อระบุบทบาท

* `InclusionValidator`, `ExclusionValidator`, และ `FormatValidator` ตอนนี้ยอมรับตัวเลือกที่อาจเป็น proc, lambda, หรืออะไรก็ตามที่ตอบสนองกับ `call` ตัวเลือกนี้จะถูกเรียกใช้งานกับเรคคอร์ดปัจจุบันเป็นอาร์กิวเมนต์และส่งคืนวัตถุที่ตอบสนองกับ `include?` สำหรับ `InclusionValidator` และ `ExclusionValidator` และส่งคืนวัตถุประเภท regular expression สำหรับ `FormatValidator`

* เพิ่ม `ActiveModel::SecurePassword` เพื่อแยกการใช้รหัสผ่านที่ง่ายดายด้วยการเข้ารหัสและเก็บเกี่ยวกับ BCrypt

* `ActiveModel::AttributeMethods` อนุญาตให้กำหนดแอตทริบิวต์ตามความต้องการ

* เพิ่มการสนับสนุนในการเปิดใช้งานและปิดใช้งาน observers ได้อย่างเลือกที่ต้องการ

* ไม่สนับสนุนการค้นหาชื่อเนมสเปซแบบอื่นแล้ว

Active Resource
---------------

* รูปแบบเริ่มต้นถูกเปลี่ยนเป็น JSON สำหรับคำขอทั้งหมด หากคุณต้องการใช้ XML ต่อไปคุณจะต้องตั้งค่า `self.format = :xml` ในคลาส ตัวอย่างเช่น

    ```ruby
    class User < ActiveResource::Base
      self.format = :xml
    end
    ```

Active Support
--------------

* `ActiveSupport::Dependencies` ตอนนี้เรียกใช้ `NameError` หากพบค่าคงที่ที่มีอยู่ใน `load_missing_constant`

* เพิ่มเมธอดรายงานใหม่ `Kernel#quietly` ซึ่งทำให้เงียบลงทั้ง `STDOUT` และ `STDERR`

* เพิ่ม `String#inquiry` เป็นเมธอดสะดวกสำหรับแปลงสตริงเป็นวัตถุ `StringInquirer`

* เพิ่ม `Object#in?` เพื่อทดสอบว่าวัตถุหนึ่งอยู่ในวัตถุอื่นหรือไม่

* กลยุทธ์ `LocalCache` เป็นคลาส middleware แท้จริงและไม่ใช่คลาสอนูมิเนียสแบบไม่มีชื่ออีกต่อไป

* มีการแนะนำ `ActiveSupport::Dependencies::ClassCache` คลาสเพื่อเก็บอ้างอิงไว้สำหรับคลาสที่สามารถโหลดใหม่ได้

* `ActiveSupport::Dependencies::Reference` ได้รับการรีแฟคเตอร์เพื่อใช้ประโยชน์จาก `ClassCache` ใหม่

* Backports `Range#cover?` เป็นนามแฝงสำหรับ `Range#include?` ใน Ruby 1.8

* เพิ่ม `weeks_ago` และ `prev_week` สำหรับ Date/DateTime/Time

* เพิ่ม `before_remove_const` callback ให้กับ `ActiveSupport::Dependencies.remove_unloadable_constants!`

การเลิกใช้:

* `ActiveSupport::SecureRandom` ถูกเลิกใช้แล้วและแนะนำให้ใช้ `SecureRandom` จากไลบรารีมาตรฐานของ Ruby

เครดิต
-------

ดูรายชื่อเต็มของผู้มีส่วนร่วมใน Rails ได้ที่ [รายชื่อผู้มีส่วนร่วมใน Rails](https://contributors.rubyonrails.org/) สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและแข็งแรง ยินดีกับทุกคน

บันทึกการเปิดตัว Rails 3.1 ถูกรวบรวมโดย [Vijay Dev](https://github.com/vijaydev)
