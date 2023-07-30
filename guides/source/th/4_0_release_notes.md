**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b21dbc892c0a841f1bc1fafdf5ee0126
เอกสารปล่อยตัวของ Ruby on Rails 4.0
===============================

จุดเด่นใน Rails 4.0:

* แนะนำให้ใช้ Ruby 2.0; ต้องการ 1.9.3 ขึ้นไป
* Strong Parameters
* Turbolinks
* Russian Doll Caching

เอกสารปล่อยตัวนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการเรียนรู้เกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่างๆ โปรดอ้างอิงที่ changelogs หรือตรวจสอบ [รายการคอมมิต](https://github.com/rails/rails/commits/4-0-stable) ในเก็บรักษาหลักของ Rails ใน GitHub

--------------------------------------------------------------------------------

การอัพเกรดไปยัง Rails 4.0
----------------------

หากคุณกำลังอัพเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัพเกรดไปยัง Rails 3.2 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัพเดตไปยัง Rails 4.0 มีรายการสิ่งที่ควรระวังเมื่ออัพเกรดใน [คู่มือการอัพเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0)

การสร้างแอปพลิเคชัน Rails 4.0
--------------------------------

```bash
# คุณควรมี 'rails' RubyGem ที่ติดตั้งแล้ว
$ rails new myapp
$ cd myapp
```

### การเก็บ Gems

Rails ใช้ `Gemfile` ในรากแอปพลิเคชันเพื่อกำหนด Gems ที่คุณต้องการสำหรับแอปพลิเคชันของคุณในการเริ่มต้น ไฟล์ `Gemfile` นี้จะถูกประมวลผลโดย [Bundler](https://github.com/carlhuda/bundler) gem ซึ่งจะติดตั้ง dependencies ทั้งหมดของคุณ มันยังสามารถติดตั้ง dependencies ทั้งหมดไปยังแอปพลิเคชันของคุณเองเพื่อไม่ต้องพึ่งพากับ system gems

ข้อมูลเพิ่มเติม: [Bundler homepage](https://bundler.io)

### อยู่ในส่วนของการพัฒนา

`Bundler` และ `Gemfile` ทำให้การแชร์แอปพลิเคชัน Rails ของคุณเป็นเรื่องง่ายดายด้วยคำสั่ง `bundle` ที่เป็นเฉพาะ หากคุณต้องการแชร์โดยตรงจาก Git repository คุณสามารถส่งผ่าน flag `--edge`:

```bash
$ rails new myapp --edge
```

หากคุณมีการ checkout ท้องถิ่นของเก็บรักษา Rails และต้องการสร้างแอปพลิเคชันโดยใช้มัน คุณสามารถส่งผ่าน flag `--dev`:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

คุณสามารถอ่านเพิ่มเติมได้ที่ [เอกสารปล่อยตัว Rails 4.0](https://guides.rubyonrails.org/images/4_0_release_notes/rails4_features.png)

คุณสามารถอ่านเพิ่มเติมได้ที่ [เอกสารปล่อยตัว Rails 4.0](https://guides.rubyonrails.org/images/4_0_release_notes/rails4_features.png)

### การอัพเกรด

* **Ruby 1.9.3** ([คอมมิต](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)) - แนะนำให้ใช้ Ruby 2.0; ต้องการ 1.9.3 ขึ้นไป
* **[นโยบายการเลิกใช้งานใหม่](https://www.youtube.com/watch?v=z6YgD6tVPQs)** - คุณสมบัติที่ถูกเลิกใช้งานจะเป็นคำเตือนใน Rails 4.0 และจะถูกลบออกใน Rails 4.1
* **ActionPack page และ action caching** ([คอมมิต](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)) - Page และ action caching ถูกแยกออกเป็น gem แยก Page และ action caching ต้องการการแก้ไขด้วยตนเองมากเกินไป (ต้องลบแคชด้วยตนเองเมื่อวัตถุโมเดลหลักที่อยู่ภายใต้มันถูกอัพเดต) แทนที่จะใช้ Russian doll caching
* **ActiveRecord observers** ([คอมมิต](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)) - Observers ถูกแยกออกเป็น gem แยก Observers จำเป็นเฉพาะสำหรับ Page และ action caching และสามารถนำไปสู่การเขียนโค้ดที่ซับซ้อนได้
* **ActiveRecord session store** ([คอมมิต](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)) - ActiveRecord session store ถูกแยกออกเป็น gem การเก็บ session ใน SQL เป็นการใช้ทรัพยากรมาก แทนที่จะใช้ cookie sessions, memcache sessions หรือ custom session store
* **ActiveModel mass assignment protection** ([คอมมิต](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)) - Rails 3 mass assignment protection ถูกเลิกใช้งาน แทนที่ให้ใช้ strong parameters
* **ActiveResource** ([คอมมิต](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)) - ActiveResource ถูกแยกออกเป็น gem ActiveResource ไม่ได้ถูกใช้งานอย่างแพร่หลาย
* **vendor/plugins ถูกลบออก** ([คอมมิต](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)) - ใช้ `Gemfile` เพื่อจัดการกับ gems ที่ติดตั้ง
### ActionPack

* **พารามิเตอร์ที่แข็งแกร่ง** ([commit](https://github.com/rails/rails/commit/a8f6d5c6450a7fe058348a7f10a908352bb6c7fc)) - อนุญาตเฉพาะพารามิเตอร์ที่ได้รับอนุญาตให้อัปเดตอ็อบเจกต์โมเดล (`params.permit(:title, :text)`).
* **Routing concerns** ([commit](https://github.com/rails/rails/commit/0dd24728a088fcb4ae616bb5d62734aca5276b1b)) - ใน DSL ของการเรียกเส้นทาง, แยกออกจากเส้นทางย่อยที่ซ้ำกัน (`comments` จาก `/posts/1/comments` และ `/videos/1/comments`).
* **ActionController::Live** ([commit](https://github.com/rails/rails/commit/af0a9f9eefaee3a8120cfd8d05cbc431af376da3)) - สตรีม JSON ด้วย `response.stream`.
* **Declarative ETags** ([commit](https://github.com/rails/rails/commit/ed5c938fa36995f06d4917d9543ba78ed506bb8d)) - เพิ่มการเพิ่ม etag ระดับคอนโทรลเลอร์ที่จะเป็นส่วนหนึ่งของการคำนวณ etag ของแอ็กชัน.
* **[การแคชแบบหุ่นรุ่นรัสเซีย](https://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)** ([commit](https://github.com/rails/rails/commit/4154bf012d2bec2aae79e4a49aa94a70d3e91d49)) - แคชส่วนย่อยของวิว. แต่ละส่วนย่อยหมดอายุตามขึ้นตอนขึ้นอยู่กับชุดขึ้นตอน (คีย์แคช). คีย์แคช通常เป็นหมายเลขเวอร์ชันเทมเพลตและออบเจกต์โมเดล.
* **Turbolinks** ([commit](https://github.com/rails/rails/commit/e35d8b18d0649c0ecc58f6b73df6b3c8d0c6bb74)) - เซิร์ฟเฉพาะหน้า HTML เริ่มต้นเพียงหนึ่งหน้า. เมื่อผู้ใช้นำทางไปยังหน้าอื่น ใช้ pushState เพื่ออัปเดต URL และใช้ AJAX เพื่ออัปเดตไตเติลและเนื้อหา.
* **แยก ActionView จาก ActionController** ([commit](https://github.com/rails/rails/commit/78b0934dd1bb84e8f093fb8ef95ca99b297b51cd)) - ActionView ถูกแยกออกจาก ActionPack และจะถูกย้ายไปเป็นแพ็คเกจแยกต่างหากใน Rails 4.1.
* **ไม่ต้องพึ่งพา ActiveModel** ([commit](https://github.com/rails/rails/commit/166dbaa7526a96fdf046f093f25b0a134b277a68)) - ActionPack ไม่พึ่งพา ActiveModel อีกต่อไป.

### ทั่วไป

 * **ActiveModel::Model** ([commit](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)) - `ActiveModel::Model`, การผสมผสานเพื่อให้วัตถุธรรมดาใน Ruby ทำงานกับ ActionPack ได้โดยอัตโนมัติ (เช่นสำหรับ `form_for`)
 * **API ขอบเขตใหม่** ([commit](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)) - ขอบเขตต้องใช้เฉพาะเรียกได้เสมอ.
 * **การเก็บแคชสกีมา** ([commit](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)) - เพื่อปรับปรุงเวลาเริ่มต้นของ Rails, แทนที่จะโหลดสกีมาโดยตรงจากฐานข้อมูล, โหลดสกีมาจากไฟล์ดัมป์.
 * **สนับสนุนการระบุระดับการแยกการทำงาน** ([commit](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)) - เลือกว่าการอ่านซ้ำหรือประสิทธิภาพที่ดีขึ้น (การล็อกน้อยลง) สำคัญกว่า.
 * **Dalli** ([commit](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)) - ใช้ไคลเอ็นต์ memcache ของ Dalli สำหรับการจัดเก็บ memcache.
 * **การเริ่มต้นและการสิ้นสุดการแจ้งเตือน** ([commit](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)) - Active Support instrumentation รายงานการแจ้งเตือนเริ่มต้นและการสิ้นสุดให้กับผู้ติดตาม.
 * **ปลอดภัยสำหรับเธรดโดยค่าเริ่มต้น** ([commit](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)) - Rails สามารถทำงานในเซิร์ฟเวอร์แอปพลิเคชันที่มีเธรดได้โดยไม่ต้องกำหนดค่าเพิ่มเติม.

หมายเหตุ: ตรวจสอบว่าแพ็คเกจที่คุณกำลังใช้เป็นปลอดภัยสำหรับเธรดหรือไม่.
* **PATCH verb** ([commit](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)) - ใน Rails PATCH จะแทนที่ PUT ใช้สำหรับการอัปเดตข้อมูลบางส่วนของทรัพยากร

### ความปลอดภัย

* **match do not catch all** ([commit](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)) - ใน DSL ของการเรียกใช้เส้นทาง ต้องระบุ HTTP verb หรือ verbs
* **html entities escaped by default** ([commit](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)) - สตริงที่แสดงผลใน erb จะถูกหนีไว้เว้นแต่ถ้าใช้ `raw` หรือเรียกใช้ `html_safe`
* **New security headers** ([commit](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)) - Rails ส่ง headers ต่อไปนี้พร้อมกับทุก HTTP request: `X-Frame-Options` (ป้องกันการ clickjacking โดยไม่อนุญาตให้เบราว์เซอร์ฝังหน้าเว็บในเฟรม), `X-XSS-Protection` (ขอให้เบราว์เซอร์หยุดการฝังสคริปต์) และ `X-Content-Type-Options` (ป้องกันเบราว์เซอร์เปิดไฟล์ jpeg เป็น exe)

การแยกคุณสมบัติเป็นแพ็คเกจย่อย
---------------------------

ใน Rails 4.0 มีการแยกคุณสมบัติบางอย่างเป็นแพ็คเกจย่อย คุณสามารถเพิ่มแพ็คเกจย่อยที่แยกออกมาใน `Gemfile` เพื่อให้ได้ความสามารถเดิมกลับมาใช้งานได้

* Hash-based & Dynamic finder methods ([GitHub](https://github.com/rails/activerecord-deprecated_finders))
* Mass assignment protection in Active Record models ([GitHub](https://github.com/rails/protected_attributes), [Pull Request](https://github.com/rails/rails/pull/7251))
* ActiveRecord::SessionStore ([GitHub](https://github.com/rails/activerecord-session_store), [Pull Request](https://github.com/rails/rails/pull/7436))
* Active Record Observers ([GitHub](https://github.com/rails/rails-observers), [Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2))
* Active Resource ([GitHub](https://github.com/rails/activeresource), [Pull Request](https://github.com/rails/rails/pull/572), [Blog](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource))
* Action Caching ([GitHub](https://github.com/rails/actionpack-action_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Page Caching ([GitHub](https://github.com/rails/actionpack-page_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Sprockets ([GitHub](https://github.com/rails/sprockets-rails))
* Performance tests ([GitHub](https://github.com/rails/rails-perftest), [Pull Request](https://github.com/rails/rails/pull/8876))

เอกสาร
-------------

* ไกด์ถูกเขียนใหม่ในรูปแบบ GitHub Flavored Markdown

* ไกด์มีการออกแบบให้เหมาะสมกับหน้าจอที่ตอบสนอง

Railties
--------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md) เพื่อดูการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

* ตำแหน่งทดสอบใหม่ `test/models`, `test/helpers`, `test/controllers`, และ `test/mailers` ถูกเพิ่มเข้ามา รวมถึง rake tasks ที่เกี่ยวข้อง ([Pull Request](https://github.com/rails/rails/pull/7878))

* โปรแกรมที่ใช้ในแอปของคุณตอนนี้อยู่ในไดเรกทอรี `bin/` รัน `rake rails:update:bin` เพื่อรับ `bin/bundle`, `bin/rails`, และ `bin/rake`

* Threadsafe เปิดใช้งานโดยค่าเริ่มต้น

* ไม่สามารถใช้ builder ที่กำหนดเองได้โดยใช้ `--builder` (หรือ `-b`) กับ `rails new` ได้ ควรพิจารณาใช้เทมเพลตแอปพลิเคชันแทน ([Pull Request](https://github.com/rails/rails/pull/9401))

### การเลิกใช้งาน

* `config.threadsafe!` ถูกเลิกใช้แล้ว แนะนำให้ใช้ `config.eager_load` ซึ่งให้ควบคุมการโหลดแบบละเอียดมากกว่า
* `Rails::Plugin` ได้ถูกยกเลิก แทนที่จะเพิ่มปลั๊กอินใน `vendor/plugins` ให้ใช้ gem หรือ bundler พร้อมกับการระบุ path หรือ git dependencies

Action Mailer
-------------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionmailer/CHANGELOG.md) เพื่อดูการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

### การเลิกใช้

Active Model
------------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-0-stable/activemodel/CHANGELOG.md) เพื่อดูการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

* เพิ่ม `ActiveModel::ForbiddenAttributesProtection`, โมดูลที่เรียกใช้งานง่ายเพื่อป้องกันการกำหนดค่าแบบมวลส่วนเมื่อมีการส่งค่าที่ไม่ได้รับอนุญาต

* เพิ่ม `ActiveModel::Model`, การผสมผสานเพื่อทำให้วัตถุ Ruby ทำงานกับ Action Pack ได้อย่างง่ายดาย

### การเลิกใช้

Active Support
--------------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-0-stable/activesupport/CHANGELOG.md) เพื่อดูการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

* แทนที่ gem `memcache-client` ที่ถูกยกเลิกด้วย `dalli` ใน `ActiveSupport::Cache::MemCacheStore`

* ปรับปรุง `ActiveSupport::Cache::Entry` เพื่อลดการใช้หน่วยความจำและการประมวลผล

* สามารถกำหนด Inflections ตามภาษาได้แล้ว `singularize` และ `pluralize` รับ locale เป็นอาร์กิวเมนต์เพิ่มเติม

* `Object#try` จะส่งคืนค่า nil แทนที่จะเกิด NoMethodError หากวัตถุที่รับได้ไม่มีการนำเสนอเมธอด แต่คุณยังสามารถใช้พฤติกรรมเดิมได้โดยใช้ `Object#try!` ใหม่

* `String#to_date` ตอนนี้จะเกิด `ArgumentError: invalid date` แทนที่จะเกิด `NoMethodError: undefined method 'div' for nil:NilClass` เมื่อได้รับวันที่ที่ไม่ถูกต้อง ตอนนี้เหมือนกับ `Date.parse` และยอมรับวันที่ที่ไม่ถูกต้องมากกว่า 3.x เช่น:

    ```ruby
    # ActiveSupport 3.x
    "asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
    "333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

    # ActiveSupport 4
    "asdf".to_date # => ArgumentError: invalid date
    "333".to_date # => Fri, 29 Nov 2013
    ```

### การเลิกใช้

* เลิกใช้เมธอด `ActiveSupport::TestCase#pending`, ใช้ `skip` จาก minitest แทน

* `ActiveSupport::Benchmarkable#silence` ถูกเลิกใช้เนื่องจากขาดความปลอดภัยในเรื่องของเธรด จะถูกลบโดยไม่มีการแทนที่ใน Rails 4.1

* `ActiveSupport::JSON::Variable` ถูกเลิกใช้ กำหนด `#as_json` และ `#encode_json` เองสำหรับสตริงลิตเตอรัล JSON ที่กำหนดเอง

* เลิกใช้เมธอดที่เข้ากันได้ `Module#local_constant_names`, ใช้ `Module#local_constants` แทน (ที่ส่งคืนสัญลักษณ์)
* `ActiveSupport::BufferedLogger` ถูกยกเลิกการใช้งานแล้ว ให้ใช้ `ActiveSupport::Logger` หรือ logger จากไลบรารีมาตรฐานของ Ruby แทน

* เลิกใช้ `assert_present` และ `assert_blank` และใช้ `assert object.blank?` และ `assert object.present?` แทน

Action Pack
-----------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

* เปลี่ยนสไตล์ชีทสตายเลขของหน้าข้อผิดพลาดสำหรับโหมดการพัฒนา แสดงเพิ่มเติมเช่นบรรทัดของโค้ดและชิ้นส่วนที่เกิดข้อผิดพลาดในหน้าข้อผิดพลาดทั้งหมด

### การเลิกใช้งาน

Active Record
-------------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

* ปรับปรุงวิธีการเขียน migration `change` ทำให้ไม่จำเป็นต้องใช้ `up` และ `down` เดิมอีกต่อไป

    * เมธอด `drop_table` และ `remove_column` สามารถย้อนกลับได้ตามที่กำหนดไว้ ถ้ามีข้อมูลที่จำเป็น
      เมธอด `remove_column` เคยรับชื่อคอลัมน์หลายคอลัมน์ แต่ในตอนนี้ให้ใช้ `remove_columns` (ซึ่งไม่สามารถย้อนกลับได้)
      เมธอด `change_table` ย้อนกลับได้เช่นกัน ถ้าบล็อกของมันไม่เรียกใช้ `remove` `change` หรือ `change_default`

    * เมธอดใหม่ `reversible` ทำให้เป็นไปได้ที่จะระบุโค้ดที่จะทำงานเมื่อทำการเพิ่มหรือลด migration
      ดูเพิ่มเติมที่ [Guide on Migration](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#using-reversible)

    * เมธอดใหม่ `revert` จะย้อนกลับ migration ทั้งหมดหรือบล็อกที่กำหนด
      ถ้าทำการย้อนกลับ migration บล็อกที่กำหนดจะทำงานตามปกติ
      ดูเพิ่มเติมที่ [Guide on Migration](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#reverting-previous-migrations)

* เพิ่มการสนับสนุนชนิดข้อมูล array ของ PostgreSQL สามารถใช้ชนิดข้อมูลใดก็ได้ในการสร้างคอลัมน์แบบ array พร้อมการสนับสนุนการเปลี่ยนแปลง migration และ schema dumper ทั้งหมด

* เพิ่ม `Relation#load` เพื่อโหลดเรคคอร์ดและคืนค่า `self` โดยชัดเจน

* `Model.all` ตอนนี้คืนค่าเป็น `ActiveRecord::Relation` แทนที่จะเป็นอาร์เรย์ของเรคคอร์ด ใช้ `Relation#to_a` หากต้องการอาร์เรย์จริง ในบางกรณีเฉพาะนี้อาจทำให้เกิดปัญหาเมื่ออัพเกรด

* เพิ่ม `ActiveRecord::Migration.check_pending!` ซึ่งจะเรียกขึ้นข้อผิดพลาดหากมี migration ที่รอดำเนินการ

* เพิ่มการสนับสนุน custom coders สำหรับ `ActiveRecord::Store` ตอนนี้คุณสามารถตั้งค่า custom coder ได้ดังนี้:

        store :settings, accessors: [ :color, :homepage ], coder: JSON
* การเชื่อมต่อ `mysql` และ `mysql2` จะตั้งค่า `SQL_MODE=STRICT_ALL_TABLES` เป็นค่าเริ่มต้นเพื่อป้องกันการสูญเสียข้อมูลที่เกิดขึ้นโดยไม่มีเสียง เราสามารถปิดการใช้งานนี้ได้โดยระบุ `strict: false` ใน `database.yml` ของคุณ

* ลบ IdentityMap

* ลบการทำงานอัตโนมัติของคำสั่ง EXPLAIN ตัวเลือก `active_record.auto_explain_threshold_in_seconds` ไม่ได้ใช้แล้วและควรลบออก

* เพิ่ม `ActiveRecord::NullRelation` และ `ActiveRecord::Relation#none` ที่นำเสนอรูปแบบวัตถุที่เป็นค่าว่างสำหรับคลาส Relation

* เพิ่มการช่วยเหลือการเชื่อมต่อ HABTM โดยใช้การเคลื่อนย้ายตาราง join

* อนุญาตให้สร้างบันทึก hstore ใน PostgreSQL

### การเลิกใช้งาน

* เลิกใช้งาน API แบบเก่าที่ใช้แฮชเป็นพารามิเตอร์ค้นหา นั่นหมายความว่าเมธอดที่ก่อนหน้านี้ยอมรับ "ตัวเลือกค้นหา" จะไม่ทำงานอีกต่อไป

* เลิกใช้งานเมธอดแบบไดนามิกทั้งหมดยกเว้น `find_by_...` และ `find_by_...!` นี่คือวิธีการเขียนโค้ดใหม่:

      * `find_all_by_...` สามารถเขียนใหม่โดยใช้ `where(...)`
      * `find_last_by_...` สามารถเขียนใหม่โดยใช้ `where(...).last`
      * `scoped_by_...` สามารถเขียนใหม่โดยใช้ `where(...)`
      * `find_or_initialize_by_...` สามารถเขียนใหม่โดยใช้ `find_or_initialize_by(...)`
      * `find_or_create_by_...` สามารถเขียนใหม่โดยใช้ `find_or_create_by(...)`
      * `find_or_create_by_...!` สามารถเขียนใหม่โดยใช้ `find_or_create_by!(...)`

เครดิต
-------

ดู [รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](https://contributors.rubyonrails.org/) สำหรับผู้ที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails เป็นเฟรมเวิร์กที่เสถียรและทนทาน ยินดีด้วยทุกคน
