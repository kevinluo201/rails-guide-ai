**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 30550ed8fa3c0983f3d99a0e91571a98
เอกสารปล่อยตัวของ Ruby on Rails 3.2
===============================

จุดเด่นใน Rails 3.2:

* โหมดการพัฒนาที่เร็วขึ้น
* เครื่องมือเส้นทางใหม่
* การอธิบายคำสั่งคิวอาร์รี่อัตโนมัติ
* การบันทึกแท็ก

เอกสารปล่อยตัวนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่เอกสารเปลี่ยนแปลงหรือตรวจสอบ [รายการของการเปลี่ยนแปลง](https://github.com/rails/rails/commits/3-2-stable) ในเก็บรักษาหลักของ Rails ใน GitHub

--------------------------------------------------------------------------------

การอัพเกรดไปยัง Rails 3.2
----------------------

หากคุณกำลังอัพเกรดแอปพลิเคชันที่มีอยู่อยู่ คุณควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัพเกรดไปยัง Rails 3.1 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานได้ตามที่คาดหวังก่อนที่จะพยายามอัพเดตไปยัง Rails 3.2 จากนั้นให้ทำตามขั้นตอนต่อไปนี้:

### Rails 3.2 ต้องการ Ruby 1.8.7 หรือสูงกว่า

Rails 3.2 ต้องการ Ruby 1.8.7 หรือสูงกว่า การสนับสนุนสำหรับเวอร์ชัน Ruby ก่อนหน้านี้ทั้งหมดถูกยกเลิกอย่างเป็นทางการและคุณควรอัพเกรดให้เร็วที่สุด Rails 3.2 ยังเข้ากันได้กับ Ruby 1.9.2

เคล็ดลับ: โปรดทราบว่า Ruby 1.8.7 p248 และ p249 มีข้อบกพร่องในการมาร์ชลิ่งที่ทำให้ Rails ล้มเหลว แต่ Ruby Enterprise Edition ได้แก้ไขปัญหาเหล่านี้ตั้งแต่เวอร์ชัน 1.8.7-2010.02 ในด้านของ Ruby 1.9 รุ่น 1.9.1 ไม่สามารถใช้งานได้เพราะมีข้อผิดพลาดที่รุนแรง ดังนั้นหากคุณต้องการใช้ 1.9.x โปรดเลือกใช้ 1.9.2 หรือ 1.9.3 เพื่อความราบรื่นในการทำงาน

### อัพเดตในแอปพลิเคชันของคุณ

* อัพเดต `Gemfile` ของคุณให้ขึ้นอยู่กับ
    * `rails = 3.2.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

* Rails 3.2 ยกเลิกการใช้ `vendor/plugins` และ Rails 4.0 จะลบออกเป็นอย่างสมบูรณ์ คุณสามารถเริ่มแทนที่ปลั๊กอินเหล่านี้โดยการแยกเป็นแพ็คเกจและเพิ่มใน `Gemfile` หากคุณเลือกที่จะไม่ทำให้เป็นแพ็คเกจ คุณสามารถย้ายไปที่, ตัวอย่างเช่น, `lib/my_plugin/*` และเพิ่มตัวกำหนดเริ่มต้นที่เหมาะสมใน `config/initializers/my_plugin.rb`

* มีการเปลี่ยนแปลงการกำหนดค่าใหม่สองรายการที่คุณต้องการเพิ่มใน `config/environments/development.rb`:

    ```ruby
    # ยกเว้นการป้องกันการกำหนดค่าจำนวนมากสำหรับโมเดล Active Record
    config.active_record.mass_assignment_sanitizer = :strict

    # บันทึกแผนการคิวสำหรับคำสั่งคิวที่ใช้เวลามากกว่านี้ (ทำงานกับ SQLite, MySQL, และ PostgreSQL)
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    การกำหนดค่า `mass_assignment_sanitizer` ยังต้องเพิ่มใน `config/environments/test.rb`:

    ```ruby
    # ยกเว้นการป้องกันการกำหนดค่าจำนวนมากสำหรับโมเดล Active Record
    config.active_record.mass_assignment_sanitizer = :strict
    ```

### อัพเดตในเอ็นจินของคุณ

แทนที่รหัสภายใต้คำอธิบายใน `script/rails` ด้วยเนื้อหาต่อไปนี้:

```ruby
ENGINE_ROOT = File.expand_path('../..', __FILE__)
ENGINE_PATH = File.expand_path('../../lib/your_engine_name/engine', __FILE__)

require "rails/all"
require "rails/engine/commands"
```

การสร้างแอปพลิเคชัน Rails 3.2
--------------------------------

```bash
# คุณควรมี RubyGem 'rails' ติดตั้งแล้ว
$ rails new myapp
$ cd myapp
```

### การจัดเก็บ Gems

Rails ใช้ `Gemfile` ในรากแอปพลิเคชันเพื่อกำหนด Gems ที่คุณต้องการให้แอปพลิเคชันเริ่มต้น ไฟล์ `Gemfile` นี้จะถูกประมวลผลโดย [Bundler](https://github.com/carlhuda/bundler) gem ซึ่งจากนั้นจะติดตั้ง dependencies ทั้งหมดของคุณ มันยังสามารถติดตั้ง dependencies ทั้งหมดไปยังแอปพลิเคชันของคุณในที่เดียวเพื่อไม่ต้องพึ่งพา Gems ของระบบ

ข้อมูลเพิ่มเติม: [Bundler homepage](https://bundler.io/)

### การใช้งานรุ่นล่าสุด

`Bundler` และ `Gemfile` ทำให้การแชร์แอปพลิเคชัน Rails ของคุณเป็นเรื่องง่ายดายด้วยคำสั่ง `bundle` ที่เป็นเฉพาะ หากคุณต้องการที่จะแบนเดียวจาก Git repository คุณสามารถส่งพารามิเตอร์ `--edge` ได้
```bash
$ rails new myapp --edge
```

หากคุณมีการเช็คเอาท์ท้องถิ่นของเรลส์และต้องการสร้างแอปพลิเคชันโดยใช้เอาท์ท้องถิ่นนั้น คุณสามารถใช้ค่า `--dev`:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

คุณสมบัติหลัก
--------------

### โหมดการพัฒนาที่เร็วขึ้นและเราท์ติ้ง

เรลส์ 3.2 มาพร้อมกับโหมดการพัฒนาที่เร็วขึ้นอย่างมีนัยสำคัญ โดยได้รับแรงบันดาลใจจาก [Active Reload](https://github.com/paneq/active_reload) เรลส์จะโหลดคลาสเฉพาะเมื่อไฟล์เปลี่ยนจริงๆ การเพิ่มประสิทธิภาพนี้เป็นอย่างมากในแอปพลิเคชันขนาดใหญ่ การรู้จักเราท์ก็ได้รับการเพิ่มประสิทธิภาพอีกด้วยด้วยเครื่องมือใหม่ [Journey](https://github.com/rails/journey)

### การอธิบายคิวรีโดยอัตโนมัติ

เรลส์ 3.2 มาพร้อมกับคุณสมบัติที่น่าสนใจที่อธิบายคิวรีที่สร้างขึ้นโดย Arel โดยการกำหนดเมธอด `explain` ใน `ActiveRecord::Relation` ตัวอย่างเช่น คุณสามารถรันบางอย่างเช่น `puts Person.active.limit(5).explain` และคิวรีที่ Arel สร้างขึ้นจะถูกอธิบาย สิ่งนี้ช่วยให้คุณตรวจสอบดัชนีที่เหมาะสมและการปรับปรุงเพิ่มเติม

คิวรีที่ใช้เวลาเกินครึ่งวินาทีในโหมดการพัฒนาจะถูกอธิบายโดยอัตโนมัติ แน่นอนว่าค่าเกณฑ์นี้สามารถเปลี่ยนได้

### การเขียนล็อกแบบแท็ก

เมื่อทำงานกับแอปพลิเคชันที่มีผู้ใช้หลายคนและหลายบัญชี การสามารถกรองล็อกตามผู้ใช้งานคนไหนทำอะไรเป็นประโยชน์อย่างมาก TaggedLogging ใน Active Support ช่วยในการทำเช่นนั้นโดยการใส่ตราบรรทัดล็อกด้วย subdomains, request ids และอื่นๆ เพื่อช่วยในการแก้ปัญหาในแอปพลิเคชันเหล่านี้

เอกสาร
-------------

ตั้งแต่เรลส์ 3.2 เรลส์ไกด์มีให้ใช้สำหรับ Kindle และแอป Kindle Reading ฟรีสำหรับ iPad, iPhone, Mac, Android ฯลฯ

Railties
--------

* เพิ่มความเร็วในการพัฒนาโดยการโหลดคลาสเฉพาะเมื่อไฟล์ที่เกี่ยวข้องเปลี่ยนแปลง สามารถปิดการใช้งานได้โดยการตั้งค่า `config.reload_classes_only_on_change` เป็น false

* แอปพลิเคชันใหม่ได้รับค่า `config.active_record.auto_explain_threshold_in_seconds` ในไฟล์การกำหนดค่าของ environment ด้วย มีค่าเป็น `0.5` ใน `development.rb` และถูกคอมเมนท์ออกใน `production.rb` ไม่มีการกล่าวถึงใน `test.rb`

* เพิ่ม `config.exceptions_app` เพื่อกำหนดแอปพลิเคชันข้อยกเว้นที่เรียกใช้งานโดย ShowException middleware เมื่อเกิดข้อยกเว้น ค่าเริ่มต้นคือ `ActionDispatch::PublicExceptions.new(Rails.public_path)`

* เพิ่ม DebugExceptions middleware ซึ่งมีคุณสมบัติที่ถูกแยกออกมาจาก ShowExceptions middleware

* แสดงเส้นทางของเอนจินที่มีการติดตั้งใน `rake routes`

* อนุญาตให้เปลี่ยนลำดับการโหลด railties ด้วย `config.railties_order` เช่น:

    ```ruby
    config.railties_order = [Blog::Engine, :main_app, :all]
    ```

* Scaffold ส่งคืน 204 No Content สำหรับ API requests ที่ไม่มีเนื้อหา ทำให้ scaffold ทำงานกับ jQuery ได้โดยอัตโนมัติ

* อัปเดต Rails::Rack::Logger middleware เพื่อใช้แท็กที่ตั้งค่าใน `config.log_tags` กับ ActiveSupport::TaggedLogging นี้ทำให้ง่ายต่อการติดแท็กบรรทัดล็อกด้วยข้อมูลการแก้ปัญหาเช่น subdomain และ request id -- ทั้งคู่เป็นประโยชน์มากในการแก้ปัญหาในแอปพลิเคชันที่มีผู้ใช้งานหลายคนในสภาพการผลิต

* ตัวเลือกเริ่มต้นสำหรับ `rails new` สามารถตั้งค่าได้ใน `~/.railsrc` คุณสามารถระบุอาร์กิวเมนต์เพิ่มเติมที่จะใช้ทุกครั้งที่ `rails new` ทำงานในไฟล์การกำหนดค่า `.railsrc` ในไดเรกทอรีบ้านของคุณ

* เพิ่มการตั้งชื่อย่อ `d` สำหรับ `destroy` สามารถใช้งานได้กับเอนจินเช่นกัน

* แอตทริบิวต์ใน scaffold และ model generators มีค่าเริ่มต้นเป็น string นี้ช่วยให้สามารถใช้งานได้ดังนี้ `bin/rails g scaffold Post title body:text author`

* อนุญาตให้ scaffold/model/migration generators รับ modifier "index" และ "uniq" เช่น

    ```bash
    bin/rails g scaffold Post title:string:index author:uniq price:decimal{7,2}
    ```

    จะสร้างดัชนีสำหรับ `title` และ `author` โดยตัวหลังเป็นดัชนีที่ไม่ซ้ำกัน บางประเภทเช่น decimal ยอมรับตัวเลือกที่กำหนดเอง ในตัวอย่าง `price` จะเป็นคอลัมน์ decimal ที่มีความแม่นยำและมาตราส่วนที่ตั้งค่าเป็น 7 และ 2 ตามลำดับ
* ไฟล์ gem ถูกลบออกจาก `Gemfile` ค่าเริ่มต้น

* ลบ generator เก่าของ plugin `rails generate plugin` และใช้คำสั่ง `rails plugin new` แทน

* ลบ API เก่า `config.paths.app.controller` และใช้ `config.paths["app/controller"]` แทน

### การเลิกใช้งาน

* `Rails::Plugin` ถูกเลิกใช้และจะถูกลบใน Rails 4.0 แทนที่จะเพิ่ม plugin ใน `vendor/plugins` ให้ใช้ gems หรือ bundler กับ path หรือ git dependencies

Action Mailer
-------------

* อัพเกรดเวอร์ชัน `mail` เป็น 2.4.0

* ลบ API เก่าของ Action Mailer ที่ถูกเลิกใช้ตั้งแต่ Rails 3.0

Action Pack
-----------

### Action Controller

* ทำให้ `ActiveSupport::Benchmarkable` เป็นโมดูลเริ่มต้นสำหรับ `ActionController::Base` เพื่อให้เมธอด `#benchmark` สามารถใช้งานใน context ของ controller ได้เหมือนเดิม

* เพิ่ม `:gzip` option ให้กับ `caches_page` สามารถกำหนดค่าเริ่มต้นได้ global โดยใช้ `page_cache_compression`

* Rails จะใช้ layout เริ่มต้น (เช่น "layouts/application") เมื่อคุณระบุ layout ด้วยเงื่อนไข `:only` และ `:except` และเงื่อนไขเหล่านั้นล้มเหลว

    ```ruby
    class CarsController
      layout 'single_car', :only => :show
    end
    ```

    Rails จะใช้ `layouts/single_car` เมื่อมีคำขอเข้ามาใน action `:show` และใช้ `layouts/application` (หรือ `layouts/cars` ถ้ามี) เมื่อมีคำขอเข้ามาใน actions อื่น ๆ

* `form_for` ถูกเปลี่ยนให้ใช้ `#{action}_#{as}` เป็น CSS class และ id ถ้ามี `:as` option ถูกกำหนดไว้ เวอร์ชันก่อนหน้าใช้ `#{as}_#{action}`

* `ActionController::ParamsWrapper` บน Active Record models ตอนนี้จะ wrap เฉพาะ attributes ที่กำหนดใน `attr_accessible` ถ้าไม่ได้กำหนด จะ wrap เฉพาะ attributes ที่ได้รับจากเมธอดคลาส `attribute_names` เท่านั้น นี่แก้ปัญหาการ wrap nested attributes โดยเพิ่มเข้าไปใน `attr_accessible`

* บันทึก "Filter chain halted as CALLBACKNAME rendered or redirected" ทุกครั้งที่ before callback หยุด

* `ActionDispatch::ShowExceptions` ถูก refactor ตอนนี้ controller จะรับผิดชอบในการเลือกที่จะแสดง exceptions สามารถ override `show_detailed_exceptions?` ใน controllers เพื่อระบุว่าคำขอใดควรให้ข้อมูลการแก้ไขข้อผิดพลาด

* Responders ตอนนี้จะ return 204 No Content สำหรับ API requests ที่ไม่มี response body (เหมือน scaffold ใหม่)

* `ActionController::TestCase` ถูก refactor cookies ตอนนี้ควรใช้ `cookies[]` เพื่อกำหนดค่า cookies ใน test cases

    ```ruby
    cookies[:email] = 'user@example.com'
    get :index
    assert_equal 'user@example.com', cookies[:email]
    ```

    เพื่อล้าง cookies ให้ใช้ `clear`

    ```ruby
    cookies.clear
    get :index
    assert_nil cookies[:email]
    ```

    เราไม่ได้เขียน HTTP_COOKIE และ cookie jar จะยังคงอยู่ระหว่างคำขอเพื่อถ้าคุณต้องการแก้ไข environment สำหรับ test คุณต้องทำก่อนที่ cookie jar จะถูกสร้าง

* `send_file` ตอนนี้จะทาย MIME type จากนามสกุลไฟล์ถ้าไม่ได้ระบุ `:type`

* เพิ่ม MIME type entries สำหรับ PDF, ZIP และรูปแบบอื่น ๆ

* อนุญาตให้ `fresh_when/stale?` รับ record แทนที่ options hash

* เปลี่ยนระดับ log ของ warning สำหรับ CSRF token ที่หายไปจาก `:debug` เป็น `:warn`

* Assets ควรใช้ protocol ของคำขอเป็นค่าเริ่มต้นหรือถ้าไม่มีคำขอให้เป็น relative

#### การเลิกใช้งาน

* เลิกใช้งานการค้นหา layout ที่ถูกนำมาใช้งานอัตโนมัติใน controllers ที่ parent มีการตั้งค่า layout แบบชัดเจน:

    ```ruby
    class ApplicationController
      layout "application"
    end

    class PostsController < ApplicationController
    end
    ```

    ในตัวอย่างข้างต้น `PostsController` จะไม่ค้นหา layout ของ posts โดยอัตโนมัติ ถ้าคุณต้องการฟังก์ชันนี้คุณสามารถลบ `layout "application"` จาก `ApplicationController` หรือตั้งค่าเป็น `nil` ใน `PostsController` ได้
* ยกเลิกการใช้ `ActionController::UnknownAction` และใช้ `AbstractController::ActionNotFound` แทน

* ยกเลิกการใช้ `ActionController::DoubleRenderError` และใช้ `AbstractController::DoubleRenderError` แทน

* ยกเลิกการใช้ `method_missing` และใช้ `action_missing` แทนสำหรับการไม่พบการกระทำ

* ยกเลิกการใช้ `ActionController#rescue_action`, `ActionController#initialize_template_class` และ `ActionController#assign_shortcuts`

### Action Dispatch

* เพิ่ม `config.action_dispatch.default_charset` เพื่อกำหนดค่า charset เริ่มต้นสำหรับ `ActionDispatch::Response`

* เพิ่ม middleware `ActionDispatch::RequestId` ที่จะทำให้ header X-Request-Id ที่ไม่ซ้ำกันสามารถใช้งานได้ในการตอบสนองและเปิดใช้งานเมธอด `ActionDispatch::Request#uuid` ซึ่งทำให้ง่ายต่อการติดตามคำขอจากจุดสุดท้ายในสแต็กและระบุคำขอแต่ละคำในบันทึกผสม เช่น Syslog

* Middleware `ShowExceptions` ตอนนี้ยอมรับแอปพลิเคชันข้อยกเว้นที่รับผิดชอบในการแสดงข้อยกเว้นเมื่อแอปพลิเคชันล้มเหลว แอปพลิเคชันจะถูกเรียกใช้งานพร้อมกับข้อยกเว้นที่คัดลอกใน `env["action_dispatch.exception"]` และ `PATH_INFO` ที่ถูกเขียนใหม่เป็นรหัสสถานะ

* อนุญาตให้กำหนดการตอบสนองของการช่วยเหลือผ่าน railtie เช่น `config.action_dispatch.rescue_responses`

#### การเลิกใช้งาน

* ยกเลิกการกำหนด charset เริ่มต้นที่ระดับคอนโทรลเลอร์ ให้ใช้ `config.action_dispatch.default_charset` แทน

### Action View

* เพิ่มการสนับสนุน `button_tag` ใน `ActionView::Helpers::FormBuilder` ซึ่งจะทำให้มีพฤติกรรมเริ่มต้นเหมือนกับ `submit_tag`

    ```erb
    <%= form_for @post do |f| %>
      <%= f.button %>
    <% end %>
    ```

* ช่วยให้เมธอดเกี่ยวกับวันที่ยอมรับตัวเลือกใหม่ `:use_two_digit_numbers => true` ซึ่งจะแสดงกล่องเลือกสำหรับเดือนและวันด้วยตัวเลขสองหลักโดยมีเลขศูนย์นำหน้าโดยไม่เปลี่ยนแปลงค่าที่เกี่ยวข้อง ตัวอย่างเช่น สามารถใช้งานได้สำหรับการแสดงวันที่แบบ ISO 8601 เช่น '2011-08-01'

* คุณสามารถระบุเนมสเปซสำหรับฟอร์มของคุณเพื่อให้แน่ใจว่า id attributes บนองค์ประกอบของฟอร์มไม่ซ้ำกัน แอตทริบิวต์เนมสเปซจะถูกเติมขีดล่างไว้กับ HTML id ที่สร้างขึ้น

    ```erb
    <%= form_for(@offer, :namespace => 'namespace') do |f| %>
      <%= f.label :version, 'Version' %>:
      <%= f.text_field :version %>
    <% end %>
    ```

* จำกัดจำนวนตัวเลือกสำหรับ `select_year` เป็น 1000 ตัวเลือก สามารถใช้ตัวเลือก `:max_years_allowed` เพื่อกำหนดขีดจำกัดของคุณเอง

* `content_tag_for` และ `div_for` สามารถรับคอลเลกชันของเรคคอร์ดได้แล้ว และจะส่งค่าเรคคอร์ดเป็นอาร์กิวเมนต์แรกถ้าคุณตั้งค่าอาร์กิวเมนต์ที่รับไว้ในบล็อกของคุณ ดังนั้นไม่จำเป็นต้องทำดังนี้:

    ```ruby
    @items.each do |item|
      content_tag_for(:li, item) do
        Title: <%= item.title %>
      end
    end
    ```

    คุณสามารถทำดังนี้ได้:

    ```ruby
    content_tag_for(:li, @items) do |item|
      Title: <%= item.title %>
    end
    ```

* เพิ่มเมธอดช่วย `font_path` ซึ่งคำนวณเส้นทางไปยังแอสเซ็ตฟอนต์ใน `public/fonts`

#### การเลิกใช้งาน

* การส่ง formats หรือ handlers ไปยัง `render :template` และคล้ายๆ กัน เช่น `render :template => "foo.html.erb"` ถูกยกเลิก แทนที่คุณสามารถให้ :handlers และ :formats โดยตรงเป็นตัวเลือกได้ เช่น `render :template => "foo", :formats => [:html, :js], :handlers => :erb`

### Sprockets

* เพิ่มตัวเลือกการกำหนดค่า `config.assets.logger` เพื่อควบคุมการบันทึกของ Sprockets ตั้งค่าเป็น `false` เพื่อปิดการบันทึก และเป็น `nil` เพื่อใช้ค่าเริ่มต้น `Rails.logger`

Active Record
-------------

* คอลัมน์บูลีนที่มีค่า 'on' และ 'ON' จะถูกแปลงเป็น true

* เมื่อเมธอด `timestamps` สร้างคอลัมน์ `created_at` และ `updated_at` จะทำให้คอลัมน์เหล่านี้ไม่สามารถเป็นค่าว่างได้ตามค่าเริ่มต้น

* สร้าง `ActiveRecord::Relation#explain`

* สร้าง `ActiveRecord::Base.silence_auto_explain` ซึ่งช่วยให้ผู้ใช้สามารถปิดการใช้งาน EXPLAIN อัตโนมัติได้ในบล็อก

* สร้างการบันทึก EXPLAIN อัตโนมัติสำหรับคำสั่งคิวรี่ช้า พารามิเตอร์การกำหนดค่าใหม่ `config.active_record.auto_explain_threshold_in_seconds` กำหนดว่าคิวรี่ใดจะถือว่าเป็นคิวรี่ช้า การตั้งค่าเป็น nil จะปิดการใช้งานคุณสมบัตินี้ เริ่มต้นคือ 0.5 ในโหมดการพัฒนา และ nil ในโหมดการทดสอบและการใช้งานจริง Rails 3.2 รองรับคุณสมบัตินี้ใน SQLite, MySQL (mysql2 adapter) และ PostgreSQL
* เพิ่ม `ActiveRecord::Base.store` เพื่อประกาศการเก็บค่า key/value แบบ single-column ที่เรียบง่าย

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [ :color, :homepage ]
    end

    u = User.new(color: 'black', homepage: '37signals.com')
    u.color                          # Accessor stored attribute
    u.settings[:country] = 'Denmark' # Any attribute, even if not specified with an accessor
    ```

* เพิ่มความสามารถในการรัน migrations เฉพาะส่วนที่กำหนด ซึ่งช่วยให้สามารถรัน migrations เฉพาะจากเอ็นจินที่กำหนดได้ (เช่นการย้อนกลับการเปลี่ยนแปลงจากเอ็นจินที่ต้องการลบออก)

    ```
    rake db:migrate SCOPE=blog
    ```

* Migrations ที่คัดลอกมาจากเอ็นจินจะมีขอบเขตที่ระบุด้วยชื่อของเอ็นจิน เช่น `01_create_posts.blog.rb`.

* สร้าง `ActiveRecord::Relation#pluck` เพื่อให้สามารถรับค่าคอลัมน์เป็นอาร์เรย์โดยตรงจากตารางในฐานข้อมูล ฟังก์ชันนี้ยังสามารถทำงานกับ attribute ที่ถูก serialize ได้

    ```ruby
    Client.where(:active => true).pluck(:id)
    # SELECT id from clients where active = 1
    ```

* สร้างเมธอดของ association ในโมดูลที่แยกออกมาเพื่อให้สามารถ override และสร้างคอมโพสิตได้ สำหรับคลาสที่ชื่อ MyModel โมดูลจะชื่อ `MyModel::GeneratedFeatureMethods` และถูก include เข้าไปในคลาสโมเดลทันทีหลังจากโมดูล `generated_attributes_methods` ที่ถูกกำหนดใน Active Model เพื่อให้เมธอดของ association สามารถ override attribute methods ที่มีชื่อเดียวกันได้

* เพิ่ม `ActiveRecord::Relation#uniq` เพื่อสร้างคิวรี่ที่ไม่ซ้ำกัน

    ```ruby
    Client.select('DISTINCT name')
    ```

    ..สามารถเขียนได้เป็น:

    ```ruby
    Client.select(:name).uniq
    ```

    นี้ยังช่วยให้สามารถย้อนกลับการไม่ซ้ำกันใน relation ได้:

    ```ruby
    Client.select(:name).uniq.uniq(false)
    ```

* รองรับการเรียงลำดับด้วยดัชนีใน SQLite, MySQL และ PostgreSQL adapters

* อนุญาตให้ใช้ `:class_name` option สำหรับ associations ให้รับ symbol นอกจาก string นอกจากนี้ยังช่วยให้เข้าใจง่ายขึ้นสำหรับผู้เริ่มต้น และเป็นความสม่ำเสมอกับความจริงที่ options อื่น ๆ เช่น `:foreign_key` อนุญาตให้ใช้ symbol หรือ string

    ```ruby
    has_many :clients, :class_name => :Client # โปรดทราบว่าต้องใช้ตัวพิมพ์ใหญ่สำหรับ symbol
    ```

* ในโหมดการพัฒนา, `db:drop` จะลบฐานข้อมูลทดสอบเพื่อให้สมมุติกับ `db:create`

* การตรวจสอบความไม่ซ้ำกันที่ไม่สนใจตัวอักษรใน MySQL จะไม่เรียกใช้ LOWER เมื่อคอลัมน์ใช้ collation ที่ไม่สนใจตัวอักษร

* Transactional fixtures จะเรียกใช้งาน connection ฐานข้อมูลที่ใช้งานอยู่ทั้งหมด คุณสามารถทดสอบโมเดลบน connection ที่แตกต่างกันได้โดยไม่ต้องปิด transactional fixtures

* เพิ่ม `first_or_create`, `first_or_create!`, `first_or_initialize` เข้าสู่ Active Record เป็นวิธีการที่ดีกว่าเมธอด `find_or_create_by` ที่เก่าเพราะชัดเจนว่าอาร์กิวเมนต์ใดที่ใช้ในการค้นหาและอาร์กิวเมนต์ใดที่ใช้ในการสร้าง

    ```ruby
    User.where(:first_name => "Scarlett").first_or_create!(:last_name => "Johansson")
    ```

* เพิ่มเมธอด `with_lock` เข้าสู่ออบเจ็กต์ Active Record ซึ่งจะเริ่ม transaction, ล็อกออบเจ็กต์ (โดยเชื่อมต่อกับความไม่เชื่อมต่อ) และ yield ไปยังบล็อก ฟังก์ชันรับพารามิเตอร์หนึ่ง (ที่ไม่บังคับ) และส่งต่อไปยัง `lock!`

    นี้ทำให้เป็นไปได้ที่จะเขียนดังนี้:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        transaction do
          lock!
          # ... ตรรกะการยกเลิก
        end
      end
    end
    ```

    เป็น:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        with_lock do
          # ... ตรรกะการยกเลิก
        end
      end
    end
    ```

### การเลิกใช้

* การปิดการเชื่อมต่ออัตโนมัติใน thread ถูกเลิกใช้งาน ตัวอย่างเช่นรหัสต่อไปนี้ถูกเลิกใช้งาน:

    ```ruby
    Thread.new { Post.find(1) }.join
    ```

    ควรเปลี่ยนให้ปิดการเชื่อมต่อฐานข้อมูลที่สิ้นสุดของ thread:

    ```ruby
    Thread.new {
      Post.find(1)
      Post.connection.close
    }.join
    ```
เฉพาะผู้ที่สร้างเธรดในโค้ดแอปพลิเคชันของพวกเขาเท่านั้นที่ต้องกังวลเกี่ยวกับการเปลี่ยนแปลงนี้

* เมธอด `set_table_name`, `set_inheritance_column`, `set_sequence_name`, `set_primary_key`, `set_locking_column` ถูกยกเลิกการใช้งานแล้ว ให้ใช้เมธอดการกำหนดค่าแทน ตัวอย่างเช่น แทนที่จะใช้ `set_table_name` ให้ใช้ `self.table_name=`

    ```ruby
    class Project < ActiveRecord::Base
      self.table_name = "project"
    end
    ```

    หรือกำหนด `self.table_name` เอง

    ```ruby
    class Post < ActiveRecord::Base
      def self.table_name
        "special_" + super
      end
    end

    Post.table_name # => "special_posts"
    ```

Active Model
------------

* เพิ่ม `ActiveModel::Errors#added?` เพื่อตรวจสอบว่ามีข้อผิดพลาดที่ระบุไว้หรือไม่

* เพิ่มความสามารถในการกำหนดการตรวจสอบที่เข้มงวดด้วย `strict => true` ซึ่งจะเกิดข้อยกเว้นเสมอเมื่อการตรวจสอบล้มเหลว

* ให้ mass_assignment_sanitizer เป็น API ที่ง่ายต่อการแทนที่พฤติกรรมของตัวกรอง รองรับทั้ง sanitizer แบบ :logger (ค่าเริ่มต้น) และ sanitizer แบบ :strict

### การเลิกใช้งาน

* เลิกใช้งาน `define_attr_method` ใน `ActiveModel::AttributeMethods` เนื่องจากมีอยู่เพียงเพื่อสนับสนุนเมธอดเช่น `set_table_name` ใน Active Record ซึ่งกำลังถูกเลิกใช้งาน

* เลิกใช้งาน `Model.model_name.partial_path` และใช้ `model.to_partial_path` แทน

Active Resource
---------------

* การตอบสนองการเปลี่ยนเส้นทาง: การตอบสนอง 303 See Other และ 307 Temporary Redirect ตอนนี้มีพฤติกรรมเหมือนกับ 301 Moved Permanently และ 302 Found

Active Support
--------------

* เพิ่ม `ActiveSupport:TaggedLogging` ซึ่งสามารถคลุมคลองคลาส `Logger` มาตรฐานใดก็ได้เพื่อให้สามารถใช้แท็กได้

    ```ruby
    Logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    Logger.tagged("BCX") { Logger.info "Stuff" }
    # Logs "[BCX] Stuff"

    Logger.tagged("BCX", "Jason") { Logger.info "Stuff" }
    # Logs "[BCX] [Jason] Stuff"

    Logger.tagged("BCX") { Logger.tagged("Jason") { Logger.info "Stuff" } }
    # Logs "[BCX] [Jason] Stuff"
    ```

* เมธอด `beginning_of_week` ใน `Date`, `Time` และ `DateTime` ยอมรับอาร์กิวเมนต์ที่เป็นตัวเลือกที่แสดงว่าสัปดาห์เริ่มต้นในวันใด

* `ActiveSupport::Notifications.subscribed` ให้การสมัครสมาชิกกับเหตุการณ์ขณะที่บล็อกทำงาน

* กำหนดเมธอดใหม่ `Module#qualified_const_defined?`, `Module#qualified_const_get` และ `Module#qualified_const_set` ที่เป็นคล้ายกับเมธอดที่เกี่ยวข้องใน API มาตรฐาน แต่ยอมรับชื่อค่าคงที่ที่มีคุณสมบัติ

* เพิ่ม `#deconstantize` ซึ่งเสริม `#demodulize` ในการเปลี่ยนรูปแบบ นี้จะลบส่วนที่อยู่ทางขวาสุดในชื่อค่าคงที่ที่มีคุณสมบัติ

* เพิ่ม `safe_constantize` ซึ่งจะทำให้เป็นค่าคงที่ตามสตริง แต่ถ้าค่าคงที่ (หรือส่วนหนึ่งของมัน) ไม่มีอยู่จะคืนค่า `nil` แทนที่จะเกิดข้อยกเว้น

* `ActiveSupport::OrderedHash` ถูกทำเครื่องหมายว่าสามารถแยกออกมาได้เมื่อใช้ `Array#extract_options!`

* เพิ่ม `Array#prepend` เป็นตัวย่อสำหรับ `Array#unshift` และ `Array#append` เป็นตัวย่อสำหรับ `Array#<<`

* การกำหนดสตริงว่างสำหรับ Ruby 1.9 ถูกขยายให้รองรับช่องว่าง Unicode นอกจากนี้ใน Ruby 1.8 ช่องว่างที่เป็นไอโดกราฟิก U`3000` ถือว่าเป็นช่องว่าง

* ตัวเติมเข้าใจคำย่อ

* เพิ่ม `Time#all_day`, `Time#all_week`, `Time#all_quarter` และ `Time#all_year` เป็นวิธีการสร้างช่วง

    ```ruby
    Event.where(:created_at => Time.now.all_week)
    Event.where(:created_at => Time.now.all_day)
    ```

* เพิ่ม `instance_accessor: false` เป็นตัวเลือกให้กับ `Class#cattr_accessor` และฟังก์ชันที่เกี่ยวข้อง

* `ActiveSupport::OrderedHash` ตอนนี้มีพฤติกรรมที่แตกต่างกันสำหรับ `#each` และ `#each_pair` เมื่อมีบล็อกที่รับพารามิเตอร์ของมันด้วย splat

* เพิ่ม `ActiveSupport::Cache::NullStore` เพื่อใช้ในการพัฒนาและทดสอบ

* เอาออก `ActiveSupport::SecureRandom` และใช้ `SecureRandom` จากไลบรารีมาตรฐานแทน

### การเลิกใช้งาน

* `ActiveSupport::Base64` เลิกใช้งานและใช้ `::Base64` แทน

* เลิกใช้งาน `ActiveSupport::Memoizable` และใช้รูปแบบการจดจำของ Ruby แทน

* `Module#synchronize` เลิกใช้งานโดยไม่มีตัวเลือกทดแทน โปรดใช้ monitor จากไลบรารีมาตรฐานของ Ruby แทน

* เลิกใช้งาน `ActiveSupport::MessageEncryptor#encrypt` และ `ActiveSupport::MessageEncryptor#decrypt`
* `ActiveSupport::BufferedLogger#silence` ถูกยกเลิกการใช้งานแล้ว หากคุณต้องการปิดเสียงบันทึกสำหรับบล็อกที่ระบุ ให้เปลี่ยนระดับบันทึกสำหรับบล็อกนั้น

* `ActiveSupport::BufferedLogger#open_log` ถูกยกเลิกการใช้งานแล้ว วิธีนี้ไม่ควรเป็นสาธารณะในที่แรก

* พฤติกรรมของ `ActiveSupport::BufferedLogger` ในการสร้างไดเรกทอรีอัตโนมัติสำหรับไฟล์บันทึกของคุณถูกยกเลิกการใช้งานแล้ว โปรดตรวจสอบให้แน่ใจว่าคุณได้สร้างไดเรกทอรีสำหรับไฟล์บันทึกของคุณก่อนที่จะสร้างอินสแตนซ์

* `ActiveSupport::BufferedLogger#auto_flushing` ถูกยกเลิกการใช้งานแล้ว คุณสามารถตั้งระดับการซิงค์บนไฟล์แฮนเดิลใต้ดัชนีได้ดังนี้ หรือปรับแต่งระบบไฟล์ของคุณ แคชของระบบไฟล์เป็นสิ่งที่ควบคุมการซิงค์

    ```ruby
    f = File.open('foo.log', 'w')
    f.sync = true
    ActiveSupport::BufferedLogger.new f
    ```

* `ActiveSupport::BufferedLogger#flush` ถูกยกเลิกการใช้งานแล้ว ตั้งค่าการซิงค์บนไฟล์แฮนเดิลของคุณ หรือปรับแต่งระบบไฟล์ของคุณ

เครดิต
-------

ดู [รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](http://contributors.rubyonrails.org/) สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและทนทาน ยินดีด้วยทุกคน

บันทึกการเปิดตัว Rails 3.2 รวบรวมโดย [Vijay Dev](https://github.com/vijaydev)
