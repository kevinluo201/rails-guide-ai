**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 30550ed8fa3c0983f3d99a0e91571a98
บันทึกการเปลี่ยนแปลงใน Rails 3.2:

* โหมดการพัฒนาที่เร็วขึ้น
* เครื่องมือเส้นทางใหม่
* การอธิบายคำสั่งคิวอาร์รี่อัตโนมัติ
* การบันทึกแท็ก

บันทึกการเปลี่ยนแปลงเหล่านี้เกี่ยวข้องเฉพาะกับการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่ changelogs หรือตรวจสอบ [รายการของการเปลี่ยนแปลง](https://github.com/rails/rails/commits/3-2-stable) ในเรพอสิทอรีหลักของ Rails ใน GitHub

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 3.2
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดไปยัง Rails 3.1 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตไปยัง Rails 3.2 จากนั้นคุณควรทำตามขั้นตอนต่อไปนี้:

### Rails 3.2 ต้องการ Ruby 1.8.7 หรือสูงกว่า

Rails 3.2 ต้องการ Ruby 1.8.7 หรือสูงกว่า การสนับสนุนสำหรับรุ่น Ruby ก่อนหน้านี้ทั้งหมดถูกยกเลิกอย่างเป็นทางการและคุณควรอัปเกรดให้เร็วที่สุด  Rails 3.2 ยังเข้ากันได้กับ Ruby 1.9.2

เคล็ดลับ: โปรดทราบว่า Ruby 1.8.7 p248 และ p249 มีข้อบกพร่องในการมาร์ชลิ่งที่ทำให้ Rails ล้มเหลว  Ruby Enterprise Edition ได้แก้ไขปัญหาเหล่านี้ตั้งแต่เวอร์ชัน 1.8.7-2010.02 ในด้านของ Ruby 1.9, Ruby 1.9.1 ไม่สามารถใช้งานได้เนื่องจากมีข้อบกพร่องที่ร้ายแรง ดังนั้นหากคุณต้องการใช้ 1.9.x คุณควรใช้เวอร์ชัน 1.9.2 หรือ 1.9.3 เพื่อให้การทำงานเรียบร้อย

### อัปเดตในแอปพลิเคชันของคุณ

* อัปเดต `Gemfile` ของคุณเพื่อขึ้นอยู่กับ
    * `rails = 3.2.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

* Rails 3.2 ยกเลิกการใช้ `vendor/plugins` และ Rails 4.0 จะลบออกเนื่องจากนั้นคุณสามารถเริ่มแทนที่ปลั๊กอินเหล่านี้โดยการแยกเป็นแพ็กเกจและเพิ่มใน `Gemfile` หากคุณเลือกที่จะไม่ทำให้เป็นแพ็กเกจคุณสามารถย้ายไปที่, ตัวอย่างเช่น, `lib/my_plugin/*` และเพิ่มตัวกำหนดเริ่มต้นที่เหมาะสมใน `config/initializers/my_plugin.rb`

* มีการเปลี่ยนแปลงการกำหนดค่าใหม่สองรายการที่คุณต้องการเพิ่มใน `config/environments/development.rb`:

    ```ruby
    # ยกเว้นการป้องกันการกำหนดค่าแบบมวลสำหรับโมเดล Active Record
    config.active_record.mass_assignment_sanitizer = :strict

    # บันทึกแผนการคิวสำหรับคำสั่งคิวที่ใช้เวลามากกว่านี้ (ทำงานกับ SQLite, MySQL, และ PostgreSQL)
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    การกำหนดค่า `mass_assignment_sanitizer` ยังต้องเพิ่มใน `config/environments/test.rb`:

    ```ruby
    # ยกเว้นการป้องกันการกำหนดค่าแบบมวลสำหรับโมเดล Active Record
    config.active_record.mass_assignment_sanitizer = :strict
    ```

### อัปเดตในเอ็นจินของคุณ

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
# คุณควรมี 'rails' RubyGem ติดตั้งแล้ว
$ rails new myapp
$ cd myapp
```

### การเก็บ Gem

Rails ใช้ `Gemfile` ในรากแอปพลิเคชันเพื่อกำหนดแพ็กเกจที่คุณต้องการสำหรับแอปพลิเคชันของคุณให้เริ่มต้น  `Gemfile` นี้จะถูกประมวลผลโดย [Bundler](https://github.com/carlhuda/bundler) gem ซึ่งจะติดตั้งแพ็กเกจทั้งหมดที่คุณต้องการ มันยังสามารถติดตั้งแพ็กเกจทั้งหมดในแอปพลิเคชันของคุณในระดับท้องถิ่นเพื่อไม่ต้องพึ่งพาแพ็กเกจของระบบ

ข้อมูลเพิ่มเติม: [Bundler homepage](https://bundler.io/)

### อยู่ในส่วนของการพัฒนา

`Bundler` และ `Gemfile` ทำให้การแชร์แอปพลิเคชัน Rails ของคุณเป็นเรื่องง่ายดายด้วยคำสั่ง `bundle` ที่ให้เฉพาะ หากคุณต้องการแบนเดิมจากเรพอสิทอรี Git คุณสามารถส่งพารามิเตอร์ `--edge`:

```bash
$ rails new myapp --edge
```

หากคุณมีการเช็คเอาท์ท้องถิ่นของเรพอสิทอรี Rails และต้องการสร้างแอปพลิเคชันโดยใช้นั้นคุณสามารถส่งพารามิเตอร์ `--dev`:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

คุณสามารถอ่านเพิ่มเติมเกี่ยวกับการติดตั้งและการใช้งาน Rails 3.2 ในเอกสารอ้างอิงที่เกี่ยวข้อง
### การอธิบายคำสั่งค้นหาอัตโนมัติ

Rails 3.2 มาพร้อมกับคุณสมบัติที่น่าสนใจที่อธิบายคำสั่งค้นหาที่สร้างขึ้นโดย Arel โดยการกำหนดเมธอด `explain` ใน `ActiveRecord::Relation` ตัวอย่างเช่นคุณสามารถเรียกใช้ `puts Person.active.limit(5).explain` และคำสั่งค้นหาที่ Arel สร้างขึ้นจะถูกอธิบาย สิ่งนี้ช่วยให้สามารถตรวจสอบดัชนีที่ถูกต้องและการปรับปรุงเพิ่มเติมได้

คำสั่งค้นหาที่ใช้เวลาในการทำงานมากกว่าครึ่งวินาทีจะถูกอธิบายโดยอัตโนมัติในโหมดการพัฒนา แน่นอนว่าค่านี้สามารถเปลี่ยนแปลงได้

### การบันทึกลายเซ็น

เมื่อเรียกใช้แอปพลิเคชันที่รองรับการใช้งานหลายผู้ใช้และหลายบัญชี การสามารถกรองบันทึกโดยผู้ใช้งานคนใดทำอะไรเป็นประโยชน์อย่างมาก TaggedLogging ใน Active Support ช่วยในการทำเช่นนั้นโดยการประทับลงบันทึกบรรทัดด้วยโดเมนย่อย รหัสคำขอ และอื่น ๆ เพื่อช่วยในการแก้ปัญหาแอปพลิเคชันเช่นนี้

เอกสาร
-------------

ตั้งแต่ Rails 3.2 เรื่องราวของ Rails สามารถใช้ได้สำหรับ Kindle และแอปอ่าน Kindle ฟรีสำหรับ iPad, iPhone, Mac, Android เป็นต้น

Railties
--------

* เพิ่มความเร็วในการพัฒนาโดยเฉพาะอย่างยิ่งโดยการโหลดคลาสเฉพาะเมื่อไฟล์ที่เกี่ยวข้องเปลี่ยนแปลง สามารถปิดการใช้งานได้โดยตั้งค่า `config.reload_classes_only_on_change` เป็น false

* แอปพลิเคชันใหม่ได้รับค่า `config.active_record.auto_explain_threshold_in_seconds` ในไฟล์การกำหนดค่าสภาพแวดล้อม ด้วยค่า `0.5` ใน `development.rb` และคอมเมนต์ออกใน `production.rb` ไม่มีการกล่าวถึงใน `test.rb`

* เพิ่ม `config.exceptions_app` เพื่อตั้งค่าการใช้งานของแอปพลิเคชันข้อยกเว้นที่เรียกใช้โดย `ShowException` middleware เมื่อเกิดข้อผิดพลาด ค่าเริ่มต้นคือ `ActionDispatch::PublicExceptions.new(Rails.public_path)`

* เพิ่ม `DebugExceptions` middleware ที่มีคุณสมบัติที่ถูกแยกออกมาจาก `ShowExceptions` middleware

* แสดงเส้นทางของเอ็นจินที่ติดตั้งไว้ใน `rake routes`

* อนุญาตให้เปลี่ยนลำดับการโหลด railties ด้วย `config.railties_order` เช่น:

    ```ruby
    config.railties_order = [Blog::Engine, :main_app, :all]
    ```

* Scaffold ส่งคืน 204 No Content สำหรับคำขอ API ที่ไม่มีเนื้อหา สิ่งนี้ทำให้ scaffold ทำงานกับ jQuery ได้โดยอัตโนมัติ

* อัปเดต `Rails::Rack::Logger` middleware เพื่อใช้แท็กที่ตั้งค่าใน `config.log_tags` กับ `ActiveSupport::TaggedLogging` สิ่งนี้ทำให้ง่ายต่อการติดแท็กบรรทัดบันทึกด้วยข้อมูลการแก้ปัญหาเช่นโดเมนย่อยและรหัสคำขอ - ทั้งคู่เป็นประโยชน์มากในการแก้ปัญหาแอปพลิเคชันที่ใช้งานหลายผู้ใช้ในการดำเนินงาน

* ตัวเลือกเริ่มต้นสำหรับ `rails new` สามารถตั้งค่าได้ใน `~/.railsrc` คุณสามารถระบุอาร์กิวเมนต์บางอย่างเพิ่มเติมที่จะใช้ทุกครั้งที่ `rails new` ทำงานในไฟล์การกำหนดค่า `.railsrc` ในไดเรกทอรีบ้านของคุณ

* เพิ่มการตั้งค่า `d` สำหรับ `destroy` สามารถใช้งานได้สำหรับเอ็นจินเช่น

* แอตทริบิวต์ใน scaffold และ model generators มีค่าเริ่มต้นเป็น string สิ่งนี้ช่วยให้สามารถใช้งานได้ดังนี้ `bin/rails g scaffold Post title body:text author`

* อนุญาตให้ scaffold/model/migration generators รับ "index" และ "uniq" modifiers ตัวอย่างเช่น

    ```bash
    bin/rails g scaffold Post title:string:index author:uniq price:decimal{7,2}
    ```

    จะสร้างดัชนีสำหรับ `title` และ `author` โดยที่สุดท้ายเป็นดัชนีที่ไม่ซ้ำกัน บางประเภทเช่น decimal ยอมรับตัวเลือกที่กำหนดเอง ในตัวอย่างนี้ `price` จะเป็นคอลัมน์ที่เป็นทศนิยมที่มีความแม่นยำและมาตราส่วนที่ตั้งค่าเป็น 7 และ 2 ตามลำดับ

* ลบ gem ที่ไม่ได้ใช้จาก `Gemfile` เริ่มต้น

* ลบ generator เก่าของ plugin `rails generate plugin` และใช้คำสั่ง `rails plugin new` แทน

* ลบเก่า `config.paths.app.controller` API และใช้ `config.paths["app/controller"]` แทน

### การเลิกใช้งาน

* `Rails::Plugin` ถูกเลิกใช้และจะถูกลบออกใน Rails 4.0 แทนที่จะเพิ่มปลั๊กอินเข้าไปใน `vendor/plugins` ให้ใช้ gem หรือ bundler กับ path หรือ git dependencies แทน

Action Mailer
-------------

* อัปเกรดเวอร์ชัน `mail` เป็น 2.4.0

* ลบ API เก่าของ Action Mailer ที่ถูกเลิกใช้ตั้งแต่ Rails 3.0

Action Pack
-----------

### Action Controller

* ทำให้ `ActiveSupport::Benchmarkable` เป็นโมดูลเริ่มต้นสำหรับ `ActionController::Base` เพื่อให้เมธอด `#benchmark` ใช้งานได้ในบริบทของคอนโทรลเลอร์เหมือนเดิม

* เพิ่มตัวเลือก `:gzip` ให้กับ `caches_page` ตัวเลือกเริ่มต้นสามารถกำหนดค่าได้ทั่วโลกโดยใช้ `page_cache_compression`

* Rails จะใช้เลเอาต์เริ่มต้นของคุณ (เช่น "layouts/application") เมื่อคุณระบุเลเอาต์ด้วยเงื่อนไข `:only` และ `:except` และเงื่อนไขเหล่านั้นล้มเหลว
```ruby
class CarsController
  layout 'single_car', :only => :show
end
```

เมื่อมีการร้องขอแอ็คชัน `:show` จะใช้เลเอาท์ `layouts/single_car` และเมื่อมีการร้องขอแอ็คชันอื่น ๆ จะใช้เลเอาท์ `layouts/application` (หรือ `layouts/cars` ถ้ามีอยู่)
* คุณสามารถกำหนดชื่อเนมสเปซสำหรับฟอร์มของคุณเพื่อให้แน่ใจว่า id attributes บนองค์ประกอบของฟอร์มมีความเป็นเอกลักษณ์ คุณสามารถใช้ attribute namespace และเติมเครื่องหมาย underscore ไว้ข้างหน้า id ใน HTML ที่สร้างขึ้น

    ```erb
    <%= form_for(@offer, :namespace => 'namespace') do |f| %>
      <%= f.label :version, 'Version' %>:
      <%= f.text_field :version %>
    <% end %>
    ```

* จำกัดจำนวนตัวเลือกสำหรับ `select_year` ไว้ที่ 1000 โดยใช้ตัวเลือก `:max_years_allowed`

* `content_tag_for` และ `div_for` สามารถรับคอลเลกชันของเรคคอร์ดได้แล้ว และจะส่งค่าเรคคอร์ดเป็นอาร์กิวเมนต์แรกถ้าคุณตั้งค่าพารามิเตอร์รับค่าในบล็อกของคุณ ดังนั้นไม่จำเป็นต้องทำดังนี้อีกต่อไป:

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

* เพิ่มเมธอดช่วยเส้นทางไปยังแหล่งทรัพยากรฟอนต์ใน `public/fonts` ด้วยเมธอด `font_path`

#### การเลิกใช้งาน

* การส่ง formats หรือ handlers ไปยัง render :template และคำสั่งอื่น ๆ เช่น `render :template => "foo.html.erb"` ถูกเลิกใช้งาน แทนที่คุณสามารถให้ :handlers และ :formats โดยตรงเป็นตัวเลือกได้: `render :template => "foo", :formats => [:html, :js], :handlers => :erb`.

### Sprockets

* เพิ่มตัวเลือกการกำหนดค่า `config.assets.logger` เพื่อควบคุมการบันทึกของ Sprockets คุณสามารถตั้งค่าเป็น `false` เพื่อปิดการบันทึก และเป็น `nil` เพื่อใช้ค่าเริ่มต้นจาก `Rails.logger`.

Active Record
-------------

* คอลัมน์บูลีนที่มีค่า 'on' และ 'ON' จะถูกแปลงเป็น true.

* เมื่อเมธอด `timestamps` สร้างคอลัมน์ `created_at` และ `updated_at` จะทำให้คอลัมน์เหล่านี้ไม่สามารถเป็นค่าว่างได้ตามค่าเริ่มต้น

* สร้างเมธอด `ActiveRecord::Relation#explain` ขึ้นมา

* สร้างเมธอด `ActiveRecord::Base.silence_auto_explain` ซึ่งช่วยให้ผู้ใช้สามารถปิดการแสดงผล EXPLAIN อัตโนมัติได้ในบล็อกที่กำหนด

* สร้างการบันทึก EXPLAIN อัตโนมัติสำหรับคำสั่งที่ช้า พารามิเตอร์การกำหนดค่าใหม่ `config.active_record.auto_explain_threshold_in_seconds` กำหนดว่าคำสั่งใดจะถือว่าเป็นคำสั่งที่ช้า การตั้งค่าเริ่มต้นคือ 0.5 ในโหมดการพัฒนา และ nil ในโหมดการทดสอบและการใช้งานจริง Rails 3.2 รองรับคุณลักษณะนี้ใน SQLite, MySQL (mysql2 adapter) และ PostgreSQL

* เพิ่มเมธอดช่วย `ActiveRecord::Base.store` สำหรับการประกาศค่าเก็บข้อมูลแบบคีย์/ค่าเดียว

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [ :color, :homepage ]
    end

    u = User.new(color: 'black', homepage: '37signals.com')
    u.color                          # Accessor stored attribute
    u.settings[:country] = 'Denmark' # Any attribute, even if not specified with an accessor
    ```

* เพิ่มความสามารถในการเรียกใช้ migration เฉพาะส่วนที่กำหนด ซึ่งช่วยให้สามารถเรียกใช้ migration เฉพาะจากเอ็นจิ้นที่เดียวได้ (เช่นเพื่อย้อนกลับการเปลี่ยนแปลงจากเอ็นจิ้นที่ต้องการลบออก)

    ```
    rake db:migrate SCOPE=blog
    ```

* การคัดลอก migration จากเอ็นจิ้นถูกกำหนดขอบเขตด้วยชื่อของเอ็นจิ้น เช่น `01_create_posts.blog.rb`.

* สร้างเมธอด `ActiveRecord::Relation#pluck` ที่คืนค่าอาร์เรย์ของคอลัมน์โดยตรงจากตารางในฐานข้อมูล สามารถใช้งานกับคุณสมบัติที่ถูกซีเรียลไว้ได้เช่นกัน

    ```ruby
    Client.where(:active => true).pluck(:id)
    # SELECT id from clients where active = 1
    ```

* เมธอดที่สร้างขึ้นสำหรับการเชื่อมโยงถูกสร้างขึ้นในโมดูลที่แยกออกมาเพื่อให้สามารถแทนที่และรวมกันได้ สำหรับคลาสที่ชื่อ MyModel โมดูลจะชื่อ `MyModel::GeneratedFeatureMethods` มันถูกเพิ่มเข้าไปในคลาสโมเดลทันทีหลังจากโมดูล `generated_attributes_methods` ที่ถูกกำหนดไว้ใน Active Model ดังนั้นเมธอดเชื่อมโยงจะแทนที่เมธอดแอตทริบิวต์ที่มีชื่อเดียวกัน

* เพิ่ม `ActiveRecord::Relation#uniq` เพื่อสร้างคำสั่งที่ไม่ซ้ำกัน

    ```ruby
    Client.select('DISTINCT name')
    ```

    ..สามารถเขียนได้เป็น:

    ```ruby
    Client.select(:name).uniq
    ```

    นี่ยังช่วยให้คุณย้อนกลับความไม่ซ้ำกันในความสัมพันธ์:

    ```ruby
    Client.select(:name).uniq.uniq(false)
    ```

* รองรับการเรียงลำดับด้วยดัชนีใน SQLite, MySQL และ PostgreSQL adapters

* อนุญาตให้ใช้ตัวเลือก `:class_name` สำหรับความสัมพันธ์ให้รับค่าเป็นสัญลักษณ์เพิ่มเติมจากสตริง นี้เพื่อป้องกันความสับสนและเพื่อให้สอดคล้องกับความจริงที่ตัวเลือกอื่น ๆ เช่น `:foreign_key` อนุญาตให้ใช้สัญลักษณ์หรือสตริงได้

    ```ruby
    has_many :clients, :class_name => :Client # โปรดทราบว่าต้องให้สัญลักษณ์เป็นตัวพิมพ์ใหญ่
    ```
* ในโหมดการพัฒนา `db:drop` ยังคงลบฐานข้อมูลทดสอบเพื่อให้สมมติกับ `db:create` ในทางกลับกัน

* การตรวจสอบความเป็นเอกลักษณ์ที่ไม่สนใจตัวพิมพ์ในการเรียกใช้ LOWER ใน MySQL เมื่อคอลัมน์ใช้การจัดเรียงที่ไม่สนใจตัวพิมพ์อยู่แล้ว

* Transactional fixtures จะลงทะเบียนกับการเชื่อมต่อฐานข้อมูลที่ใช้งานอยู่ทั้งหมด คุณสามารถทดสอบโมเดลบนการเชื่อมต่อฐานข้อมูลที่แตกต่างกันได้โดยไม่ต้องปิดการใช้งาน transactional fixtures

* เพิ่มเมธอด `first_or_create`, `first_or_create!`, `first_or_initialize` ให้กับ Active Record นี่เป็นวิธีที่ดีกว่าเมธอด `find_or_create_by` ที่เก่าเพราะชัดเจนว่าอาร์กิวเมนต์ใดที่ใช้ในการค้นหาและอาร์กิวเมนต์ใดที่ใช้ในการสร้าง

    ```ruby
    User.where(:first_name => "Scarlett").first_or_create!(:last_name => "Johansson")
    ```

* เพิ่มเมธอด `with_lock` ให้กับออบเจกต์ Active Record ซึ่งจะเริ่ม transaction, ล็อกออบเจกต์ (โดยใช้วิธีการที่ไม่มีความหวัง) และส่งผลให้บล็อกทำงาน มีพารามิเตอร์หนึ่ง (ที่เป็นทางเลือก) และส่งไปยัง `lock!`

    นี้ทำให้เราสามารถเขียนโค้ดต่อไปนี้ได้:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        transaction do
          lock!
          # ... โลจิกการยกเลิก
        end
      end
    end
    ```

    เป็น:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        with_lock do
          # ... โลจิกการยกเลิก
        end
      end
    end
    ```

### การเลิกใช้งาน

* การปิดการเชื่อมต่ออัตโนมัติในเธรดถูกเลิกใช้งาน ตัวอย่างเช่นโค้ดต่อไปนี้ถูกเลิกใช้งาน:

    ```ruby
    Thread.new { Post.find(1) }.join
    ```

    ควรเปลี่ยนเพื่อปิดการเชื่อมต่อฐานข้อมูลที่สิ้นสุดของเธรด:

    ```ruby
    Thread.new {
      Post.find(1)
      Post.connection.close
    }.join
    ```

    เฉพาะผู้ที่สร้างเธรดในโค้ดแอปพลิเคชันของพวกเขาเท่านั้นที่ต้องกังวลเกี่ยวกับการเปลี่ยนแปลงนี้

* เมธอด `set_table_name`, `set_inheritance_column`, `set_sequence_name`, `set_primary_key`, `set_locking_column` ถูกเลิกใช้งาน ใช้เมธอดการกำหนดค่าแทน ตัวอย่างเช่น แทนที่ `set_table_name` ใช้ `self.table_name=`

    ```ruby
    class Project < ActiveRecord::Base
      self.table_name = "project"
    end
    ```

    หรือกำหนดเมธอด `self.table_name` ของคุณเอง:

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

* เพิ่ม `ActiveModel::Errors#added?` เพื่อตรวจสอบว่ามีข้อผิดพลาดที่ระบุแบบเจาะจงหรือไม่

* เพิ่มความสามารถในการกำหนดการตรวจสอบที่เข้มงวดด้วย `strict => true` ซึ่งจะเรียกข้อยกเว้นเสมอเมื่อล้มเหลว

* ให้ mass_assignment_sanitizer เป็น API ที่ง่ายต่อการแทนที่พฤติกรรมของ sanitizer รองรับทั้ง :logger (ค่าเริ่มต้น) และ :strict sanitizer behavior

### การเลิกใช้งาน

* เลิกใช้งาน `define_attr_method` ใน `ActiveModel::AttributeMethods` เนื่องจากมีอยู่เพื่อสนับสนุนเมธอดเช่น `set_table_name` ใน Active Record ซึ่งกำลังถูกเลิกใช้งาน

* เลิกใช้งาน `Model.model_name.partial_path` และใช้ `model.to_partial_path` แทน

Active Resource
---------------

* การเปลี่ยนเส้นทาง: การตอบสนองแบบเปลี่ยนเส้นทาง 303 See Other และ 307 Temporary Redirect ทำงานเหมือนกับ 301 Moved Permanently และ 302 Found

Active Support
--------------

* เพิ่ม `ActiveSupport:TaggedLogging` ที่สามารถห่อหุ้มคลาส `Logger` มาตรฐานใดก็ได้เพื่อให้มีความสามารถในการแท็ก

    ```ruby
    Logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    Logger.tagged("BCX") { Logger.info "Stuff" }
    # Logs "[BCX] Stuff"

    Logger.tagged("BCX", "Jason") { Logger.info "Stuff" }
    # Logs "[BCX] [Jason] Stuff"

    Logger.tagged("BCX") { Logger.tagged("Jason") { Logger.info "Stuff" } }
    # Logs "[BCX] [Jason] Stuff"
    ```

* เมธอด `beginning_of_week` ใน `Date`, `Time` และ `DateTime` ยอมรับอาร์กิวเมนต์ที่เป็นทางเลือกที่แสดงถึงวันที่เริ่มต้นของสัปดาห์

* `ActiveSupport::Notifications.subscribed` ให้การสมัครสมาชิกกับเหตุการณ์ในขณะที่บล็อกทำงาน

* กำหนดเมธอดใหม่ `Module#qualified_const_defined?`, `Module#qualified_const_get` และ `Module#qualified_const_set` ที่เป็นคล้ายกับเมธอดที่เกี่ยวข้องใน API มาตรฐาน แต่ยอมรับชื่อค่าคงที่ที่มีคุณสมบัติ

* เพิ่ม `#deconstantize` ซึ่งเสริม `#demodulize` ใน inflections นี้จะลบส่วนที่ถูกสุดของชื่อค่าคงที่ที่มีคุณสมบัติ

* เพิ่ม `safe_constantize` ที่จะทำให้ค่าคงที่เป็นค่าคงที่ แต่คืนค่า `nil` แทนที่จะเกิดข้อยกเว้นหากค่าคงที่ (หรือส่วนหนึ่งของมัน) ไม่มีอยู่

* `ActiveSupport::OrderedHash` ถูกทำเครื่องหมายว่าสามารถแยกออกมาได้เมื่อใช้ `Array#extract_options!`

* เพิ่ม `Array#prepend` เป็นตัวย่อของ `Array#unshift` และ `Array#append` เป็นตัวย่อของ `Array#<<`

* การกำหนดค่าของสตริงที่ว่างเปล่าสำหรับ Ruby 1.9 ถูกขยายให้รองรับช่องว่าง Unicode นอกจากนี้ใน Ruby 1.8 ช่องว่างที่เป็นอิโดกราฟิก U+3000 ถือว่าเป็นช่องว่าง
* อินเฟล็กเตอร์เข้าใจคำย่อ

* เพิ่ม `Time#all_day`, `Time#all_week`, `Time#all_quarter` และ `Time#all_year` เป็นวิธีการสร้างช่วง

    ```ruby
    Event.where(:created_at => Time.now.all_week)
    Event.where(:created_at => Time.now.all_day)
    ```

* เพิ่ม `instance_accessor: false` เป็นตัวเลือกให้กับ `Class#cattr_accessor` และฟังก์ชันที่เกี่ยวข้อง

* `ActiveSupport::OrderedHash` ตอนนี้มีพฤติกรรมที่แตกต่างกันสำหรับ `#each` และ `#each_pair` เมื่อมีการให้บล็อกรับพารามิเตอร์ด้วย splat

* เพิ่ม `ActiveSupport::Cache::NullStore` สำหรับใช้ในการพัฒนาและทดสอบ

* ลบ `ActiveSupport::SecureRandom` เพื่อเลือกใช้ `SecureRandom` จากไลบรารีมาตรฐาน

### การเลิกใช้

* `ActiveSupport::Base64` เลิกใช้แล้วแนะนำให้ใช้ `::Base64` แทน

* เลิกใช้ `ActiveSupport::Memoizable` แนะนำให้ใช้รูปแบบการจดจำของ Ruby

* `Module#synchronize` เลิกใช้แล้วไม่มีตัวเลือกใหม่ โปรดใช้ monitor จากไลบรารีมาตรฐานของ Ruby

* เลิกใช้ `ActiveSupport::MessageEncryptor#encrypt` และ `ActiveSupport::MessageEncryptor#decrypt`

* `ActiveSupport::BufferedLogger#silence` เลิกใช้แล้ว หากคุณต้องการปิดเสียงบันทึกสำหรับบล็อกที่แน่นอน โปรดเปลี่ยนระดับบันทึกสำหรับบล็อกนั้น

* `ActiveSupport::BufferedLogger#open_log` เลิกใช้แล้ว วิธีนี้ไม่ควรเป็นสาธารณะในที่แรก

* เลิกใช้ `ActiveSupport::BufferedLogger` ในการสร้างไดเรกทอรีอัตโนมัติสำหรับไฟล์บันทึกของคุณ โปรดตรวจสอบให้แน่ใจว่าไดเรกทอรีสำหรับไฟล์บันทึกของคุณถูกสร้างก่อนการสร้าง

* `ActiveSupport::BufferedLogger#auto_flushing` เลิกใช้แล้ว ตั้งระดับการซิงค์บนไฟล์แฮนเดิลให้เป็นแบบนี้ หรือปรับแต่งระบบไฟล์ของคุณ แคชของระบบไฟล์เป็นสิ่งที่ควบคุมการซักข้อมูล

    ```ruby
    f = File.open('foo.log', 'w')
    f.sync = true
    ActiveSupport::BufferedLogger.new f
    ```

* `ActiveSupport::BufferedLogger#flush` เลิกใช้แล้ว ตั้งค่าการซิงค์บนไฟล์แฮนเดิลของคุณ หรือปรับแต่งระบบไฟล์ของคุณ

เครดิต
-------

ดู [รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](http://contributors.rubyonrails.org/) สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการทำให้ Rails เป็นเฟรมเวิร์กที่เสถียรและแข็งแกร่ง ยินดีด้วยทุกคน

บันทึกการเปิดตัว Rails 3.2 รวบรวมโดย [Vijay Dev](https://github.com/vijaydev).
