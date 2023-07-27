**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b21dbc892c0a841f1bc1fafdf5ee0126
เรื่องสำคัญใน Rails 4.0:

* แนะนำให้ใช้ Ruby 2.0; ต้องการ 1.9.3 ขึ้นไป
* Strong Parameters
* Turbolinks
* Russian Doll Caching

เอกสารเวอร์ชันนี้ครอบคลุมเฉพาะการเปลี่ยนแปลงที่สำคัญเท่านั้น หากต้องการทราบข้อมูลเพิ่มเติมเกี่ยวกับการแก้ไขข้อบกพร่องและการเปลี่ยนแปลงต่าง ๆ โปรดอ้างอิงที่ changelogs หรือตรวจสอบ [รายการของการ commit](https://github.com/rails/rails/commits/4-0-stable) ในเก็บรักษาของ Rails ที่หลักบน GitHub

--------------------------------------------------------------------------------

การอัปเกรดไปยัง Rails 4.0
----------------------

หากคุณกำลังอัปเกรดแอปพลิเคชันที่มีอยู่อยู่ ควรมีการทดสอบที่ดีก่อนที่จะเริ่มต้น คุณควรอัปเกรดเป็น Rails 3.2 ก่อนหากคุณยังไม่ได้ทำ และตรวจสอบให้แน่ใจว่าแอปพลิเคชันของคุณยังทำงานตามที่คาดหวังก่อนที่จะพยายามอัปเดตเป็น Rails 4.0 มีรายการสิ่งที่ควรระวังเมื่ออัปเกรดใน [คู่มือการอัปเกรด Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0)

การสร้างแอปพลิเคชัน Rails 4.0
--------------------------------

```bash
# คุณควรมี 'rails' RubyGem ที่ติดตั้งแล้ว
$ rails new myapp
$ cd myapp
```

### Vendoring Gems

Rails ใช้ `Gemfile` ในรากแอปพลิเคชันเพื่อกำหนด gem ที่คุณต้องการสำหรับแอปพลิเคชันของคุณให้เริ่มต้น ไฟล์ `Gemfile` นี้จะถูกประมวลผลโดย [Bundler](https://github.com/carlhuda/bundler) gem ซึ่งจะติดตั้ง dependencies ทั้งหมดของคุณ มันยังสามารถติดตั้ง dependencies ทั้งหมดไปยังแอปพลิเคชันของคุณในรูปแบบที่ไม่ขึ้นอยู่กับ gem ของระบบ

ข้อมูลเพิ่มเติม: [Bundler homepage](https://bundler.io)

### Living on the Edge

`Bundler` และ `Gemfile` ทำให้การแชร์แอปพลิเคชัน Rails ของคุณเป็นเรื่องง่ายดายด้วยคำสั่ง `bundle` ใหม่ หากคุณต้องการแชร์โดยตรงจากเก็บรักษา Git คุณสามารถส่งผ่าน `--edge` flag:

```bash
$ rails new myapp --edge
```

หากคุณมีการตรวจสอบท้องถิ่นของเก็บรักษา Rails และต้องการสร้างแอปพลิเคชันโดยใช้มันคุณสามารถส่งผ่าน `--dev` flag:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

คุณสมบัติหลัก
--------------

[![Rails 4.0](images/4_0_release_notes/rails4_features.png)](https://guides.rubyonrails.org/images/4_0_release_notes/rails4_features.png)

### การอัปเกรด

* **Ruby 1.9.3** ([commit](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)) - แนะนำให้ใช้ Ruby 2.0; ต้องการ 1.9.3 ขึ้นไป
* **[นโยบายการเลิกใช้งานใหม่](https://www.youtube.com/watch?v=z6YgD6tVPQs)** - คุณสมบัติที่ถูกเลิกใช้งานเป็นคำเตือนใน Rails 4.0 และจะถูกลบออกใน Rails 4.1
* **ActionPack page และ action caching** ([commit](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)) - การแคชหน้าและการแคชแอคชันถูกแยกออกเป็น gem แยก การแคชหน้าและการแคชแอคชันต้องการการแก้ไขด้วยตนเองมากเกินไป (การล้างแคชด้วยตนเองเมื่อวัตถุโมเดลในพื้นหลังถูกอัปเดต) แทนที่จะใช้ Russian doll caching
* **ActiveRecord observers** ([commit](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)) - Observers ถูกแยกออกเป็น gem แยก Observers จำเป็นเฉพาะสำหรับการแคชหน้าและการแคชแอคชันและสามารถนำมาสู่การเขียนโค้ดที่ซับซ้อนได้
* **ActiveRecord session store** ([commit](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)) - ActiveRecord session store ถูกแยกออกเป็น gem แยกการเก็บ session ใน SQL เป็นที่มีค่าสูง แทนที่ให้ใช้ cookie sessions, memcache sessions, หรือ custom session store
* **ActiveModel mass assignment protection** ([commit](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)) - การป้องกันการกำหนดค่าจำนวนมากใน Rails 3 ถูกเลิกใช้งาน แทนที่ให้ใช้ strong parameters
* **ActiveResource** ([commit](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)) - ActiveResource ถูกแยกออกเป็น gem แยก ActiveResource ไม่ได้ถูกใช้งานอย่างแพร่หลาย
* **vendor/plugins ถูกลบออก** ([commit](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)) - ใช้ `Gemfile` ในการจัดการ gem ที่ติดตั้งแล้ว
### ทั่วไป

* **ActiveModel::Model** ([commit](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)) - `ActiveModel::Model` เป็น mixin ที่ทำให้ Object ธรรมดาของ Ruby ทำงานกับ ActionPack ได้โดยอัตโนมัติ (เช่นสำหรับ `form_for`)
* **API ขอบเขตใหม่** ([commit](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)) - Scopes ต้องใช้ callable เสมอ
* **Schema cache dump** ([commit](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)) - เพื่อปรับปรุงเวลาเริ่มต้นของ Rails แทนที่จะโหลด schema โดยตรงจากฐานข้อมูล ให้โหลด schema จากไฟล์ dump
* **รองรับการระบุระดับการแยกการทำงานของ transaction** ([commit](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)) - เลือกว่าการอ่านที่ซ้ำซ้อนหรือประสิทธิภาพที่ดีขึ้น (ลดการล็อก) สำคัญกว่า
* **Dalli** ([commit](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)) - ใช้ Dalli memcache client สำหรับ memcache store
* **การเริ่มและสิ้นสุดการแจ้งเตือน** ([commit](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)) - Active Support instrumentation รายงานการเริ่มและสิ้นสุดการแจ้งเตือนให้กับผู้ติดตาม
* **เป็นสายด้วยค่าเริ่มต้น** ([commit](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)) - Rails สามารถทำงานในเซิร์ฟเวอร์แอปพลิเคชันที่มีเธรดได้โดยไม่ต้องกำหนดค่าเพิ่มเติม

หมายเหตุ: ตรวจสอบว่า gem ที่คุณใช้เป็น threadsafe

* **PATCH verb** ([commit](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)) - ใน Rails PATCH แทนที่ PUT ใช้สำหรับการอัปเดตบางส่วนของทรัพยากร

### ความปลอดภัย

* **match do not catch all** ([commit](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)) - ใน routing DSL match ต้องระบุ HTTP verb หรือ verbs
* **html entities escaped by default** ([commit](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)) - สตริงที่แสดงผลใน erb จะถูกหนีไว้เว้นแต่จะถูกครอบด้วย `raw` หรือเรียกใช้ `html_safe`
* **ส่วนหัวความปลอดภัยใหม่** ([commit](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)) - Rails ส่งส่วนหัวต่อไปนี้พร้อมกับคำขอ HTTP ทุกครั้ง: `X-Frame-Options` (ป้องกันการ clickjacking โดยห้ามเบราว์เซอร์ฝังหน้าเว็บในเฟรม), `X-XSS-Protection` (ขอให้เบราว์เซอร์หยุดการฉีดสคริปต์) และ `X-Content-Type-Options` (ป้องกันเบราว์เซอร์เปิด jpeg เป็น exe)

การแยกคุณสมบัติเป็น gem
---------------------------

ใน Rails 4.0 มีการแยกคุณสมบัติบางอย่างเป็น gem คุณสามารถเพิ่ม gem ที่แยกออกมาใน `Gemfile` เพื่อนำความสามารถกลับมาใช้งานได้

* วิธีการค้นหาแบบ Hash และแบบ Dynamic ([GitHub](https://github.com/rails/activerecord-deprecated_finders))
* การป้องกันการกำหนดค่าแบบ Mass assignment ใน Active Record models ([GitHub](https://github.com/rails/protected_attributes), [Pull Request](https://github.com/rails/rails/pull/7251))
* ActiveRecord::SessionStore ([GitHub](https://github.com/rails/activerecord-session_store), [Pull Request](https://github.com/rails/rails/pull/7436))
* Active Record Observers ([GitHub](https://github.com/rails/rails-observers), [Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2))
* Active Resource ([GitHub](https://github.com/rails/activeresource), [Pull Request](https://github.com/rails/rails/pull/572), [Blog](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource))
* Action Caching ([GitHub](https://github.com/rails/actionpack-action_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Page Caching ([GitHub](https://github.com/rails/actionpack-page_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Sprockets ([GitHub](https://github.com/rails/sprockets-rails))
* Performance tests ([GitHub](https://github.com/rails/rails-perftest), [Pull Request](https://github.com/rails/rails/pull/8876))

เอกสาร
-------------

* เอกสารแนะนำถูกเขียนใหม่ในรูปแบบ GitHub Flavored Markdown

* เอกสารแนะนำมีการออกแบบให้เหมาะสมกับหน้าจอที่ตอบสนอง

Railties
--------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

* ตำแหน่งทดสอบใหม่ `test/models`, `test/helpers`, `test/controllers`, และ `test/mailers` ได้เพิ่มเข้ามา และมีการเพิ่ม rake tasks ที่เกี่ยวข้องด้วย ([Pull Request](https://github.com/rails/rails/pull/7878))

* โปรแกรมที่ใช้งานในแอปของคุณตอนนี้อยู่ในไดเรกทอรี `bin/` ใช้คำสั่ง `rake rails:update:bin` เพื่อรับ `bin/bundle`, `bin/rails`, และ `bin/rake`

* Threadsafe เปิดใช้งานโดยค่าเริ่มต้น

* ลบความสามารถในการใช้งาน builder ที่กำหนดเองโดยการส่ง `--builder` (หรือ `-b`) ไปยัง `rails new` พิจารณาใช้ application templates แทน ([
* `String#to_date` ตอนนี้จะเรียก `ArgumentError: invalid date` แทนที่จะเรียก `NoMethodError: undefined method 'div' for nil:NilClass` เมื่อได้รับวันที่ที่ไม่ถูกต้อง ตอนนี้มันเหมือนกับ `Date.parse` และมันยอมรับวันที่ที่ไม่ถูกต้องมากกว่าเวอร์ชัน 3.x เช่น:

    ```ruby
    # ActiveSupport 3.x
    "asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
    "333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

    # ActiveSupport 4
    "asdf".to_date # => ArgumentError: invalid date
    "333".to_date # => Fri, 29 Nov 2013
    ```

### การเลิกใช้งาน

* เลิกใช้งานเมธอด `ActiveSupport::TestCase#pending` ใช้ `skip` จาก minitest แทน

* `ActiveSupport::Benchmarkable#silence` ถูกเลิกใช้งานเนื่องจากขาดความปลอดภัยในเรื่องของเธรด จะถูกลบออกไปโดยไม่มีการแทนที่ใน Rails 4.1

* `ActiveSupport::JSON::Variable` ถูกเลิกใช้งาน กำหนด `#as_json` และ `#encode_json` เองสำหรับสตริงลิตเติล JSON ที่กำหนดเอง

* เลิกใช้งานเมธอดความเข้ากันได้ `Module#local_constant_names` ใช้ `Module#local_constants` แทน (ซึ่งจะคืนค่าเป็นสัญลักษณ์)

* `ActiveSupport::BufferedLogger` ถูกเลิกใช้งาน ใช้ `ActiveSupport::Logger` หรือ Logger จากไลบรารีมาตรฐานของ Ruby แทน

* เลิกใช้งาน `assert_present` และ `assert_blank` และใช้ `assert object.blank?` และ `assert object.present?` แทน

Action Pack
-----------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

* เปลี่ยนสไตล์ชีทสตางค์ของหน้าข้อผิดพลาดสำหรับโหมดการพัฒนา แสดงเพิ่มเติมเช่นบรรทัดของโค้ดและชิ้นส่วนที่เกี่ยวข้องที่เกิดข้อผิดพลาดในหน้าข้อผิดพลาดทั้งหมด

### การเลิกใช้งาน


Active Record
-------------

โปรดอ้างอิงที่ [Changelog](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md) สำหรับการเปลี่ยนแปลงที่ละเอียด

### การเปลี่ยนแปลงที่สำคัญ

* ปรับปรุงวิธีการเขียน migration `change` โดยไม่จำเป็นต้องใช้เมธอด `up` และ `down` เดิมอีกต่อไป

    * เมธอด `drop_table` และ `remove_column` สามารถย้อนกลับได้ตามที่กำหนดไว้ ถ้ามีข้อมูลที่จำเป็นให้ใส่
      เมธอด `remove_column` เคยรับชื่อคอลัมน์หลายคอลัมน์ แต่ในตอนนี้ให้ใช้ `remove_columns` (ซึ่งไม่สามารถย้อนกลับได้)
      เมธอด `change_table` ย้อนกลับได้เช่นกัน ถ้าบล็อกของมันไม่เรียก `remove`, `change` หรือ `change_default`

    * เมธอดใหม่ `reversible` ทำให้เป็นไปได้ที่จะระบุโค้ดที่จะทำงานเมื่อทำการเพิ่มหรือลด migration
      ดูที่ [Guide on Migration](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#using-reversible)

    * เมธอดใหม่ `revert` จะย้อนกลับ migration ทั้งหมดหรือบล็อกที่กำหนด
      ถ้าทำการย้อนกลับ, migration / บล็อกที่กำหนดจะทำงานตามปกติ
      ดูที่ [Guide on Migration](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#reverting-previous-migrations)

* เพิ่มการสนับสนุนชนิดข้อมูล array ของ PostgreSQL สามารถใช้ชนิดข้อมูลใดก็ได้ในการสร้างคอลัมน์ array พร้อมการสนับสนุนการ migration และ schema dumper เต็มรูปแบบ

* เพิ่ม `Relation#load` เพื่อโหลดเรคคอร์ดและคืนค่า `self` โดยชัดเจน

* `Model.all` ตอนนี้คืนค่าเป็น `ActiveRecord::Relation` แทนที่จะเป็นอาร์เรย์ของเรคคอร์ด ใช้ `Relation#to_a` หากคุณต้องการอาร์เรย์จริง ในบางกรณีเฉพาะนี้อาจทำให้เกิดปัญหาเมื่ออัปเกรด

* เพิ่ม `ActiveRecord::Migration.check_pending!` ซึ่งจะเรียกขึ้นข้อผิดพลาดหากมี migration ที่ยังไม่ได้ทำ

* เพิ่มการสนับสนุน custom coders สำหรับ `ActiveRecord::Store` ตอนนี้คุณสามารถตั้งค่า custom coder เองได้ดังนี้:

        store :settings, accessors: [ :color, :homepage ], coder: JSON

* การเชื่อมต่อ `mysql` และ `mysql2` จะตั้งค่า `SQL_MODE=STRICT_ALL_TABLES` เป็นค่าเริ่มต้นเพื่อป้องกันการสูญเสียข้อมูลโดยไม่มีเสียงเสียง สามารถปิดการใช้งานได้โดยระบุ `strict: false` ใน `database.yml` ของคุณ

* เอาออก IdentityMap

* เอาการดำเนินการ EXPLAIN queries โดยอัตโนมัติออก ตัวเลือก `active_record.auto_explain_threshold_in_seconds` ไม่ได้ใช้และควรถูกเอาออก

* เพิ่ม `ActiveRecord::NullRelation` และ `ActiveRecord::Relation#none` ที่นำเสนอรูปแบบอ็อบเจกต์เป็นค่าว่างสำหรับคลาส Relation

* เพิ่มการสร้างตารางเชื่อมโยง HABTM ใน migration

* อนุญาตให้สร้างเรคคอร์ด hstore ของ PostgreSQL

### การเลิกใช้งาน

* เลิกใช้งาน API แบบเก่าที่ใช้แฮชเป็นพารามิเตอร์ นั่นหมายความว่าเมธอดที่เคยยอมรับ "ตัวเลือกการค้นหา" จะไม่ทำงานอีกต่อไป

* เลิกใช้งานเมธอดแบบไดนามิกทั้งหมดยกเว้น `find_by_...` และ `find_by_...!` นี่คือวิธีการเขียนโค้ดใหม่:

      * `find_all_by_...` สามารถเขียนใหม่ได้โดยใช้ `where(...)`
      * `find_last_by_...` สามารถเขียนใหม่ได้โดยใช้ `where(...).last`
      * `scoped_by_...` สามารถเขียนใหม่ได้โดยใช้ `where(...)`
      * `find_or_initialize_by_...` สามารถเขียนใหม่ได้โดยใช้ `find_or_initialize_by(...)`
      * `find_or_create_by_...` สามารถเขียนใหม่ได้โดยใช้ `find_or_create_by(...)`
      * `find_or_create_by_...!` สามารถเขียนใหม่ได้โดยใช้ `find_or_create_by!(...)`

Credits
-------
ดูรายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails ได้ที่ [รายชื่อผู้มีส่วนร่วมทั้งหมดใน Rails](https://contributors.rubyonrails.org/) เพื่อดูว่ามีผู้คนจำนวนมากที่ใช้เวลาหลายชั่วโมงในการสร้าง Rails ให้เป็นเฟรมเวิร์กที่เสถียรและแข็งแกร่ง ยินดีด้วยทุกคนที่มีส่วนร่วม
