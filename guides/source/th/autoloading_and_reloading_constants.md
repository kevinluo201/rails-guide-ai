**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f53b3a12c263256fbbe154cfc8b2f4d
การโหลดอัตโนมัติและโหลดใหม่ของค่าคงที่
===================================

เอกสารนี้เป็นเอกสารที่อธิบายถึงวิธีการโหลดอัตโนมัติและโหลดใหม่ในโหมด `zeitwerk` 

หลังจากอ่านเอกสารนี้คุณจะทราบ:

* การกำหนดค่า Rails ที่เกี่ยวข้อง
* โครงสร้างโปรเจค
* การโหลดอัตโนมัติ การโหลดใหม่ และการโหลดแบบกระตือรือร้น
* Single Table Inheritance
* และอื่น ๆ

--------------------------------------------------------------------------------

บทนำ
------------

INFO. เอกสารนี้เป็นเอกสารที่อธิบายถึงการโหลดอัตโนมัติ การโหลดใหม่ และการโหลดแบบกระตือรือร้นในแอปพลิเคชัน Rails

ในโปรแกรม Ruby ทั่วไปคุณจะโหลดไฟล์ที่กำหนดคลาสและโมดูลที่คุณต้องการใช้งานโดยชัดเจน ตัวอย่างเช่น คอนโทรลเลอร์ต่อไปนี้อ้างอิงถึง `ApplicationController` และ `Post` และคุณต้องเรียกใช้ `require` เพื่อโหลดไฟล์เหล่านี้:

```ruby
# อย่าทำแบบนี้
require "application_controller"
require "post"
# อย่าทำแบบนี้

class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

แต่ไม่ใช่เช่นนั้นในแอปพลิเคชัน Rails ที่คลาสและโมดูลของแอปพลิเคชันจะสามารถใช้งานได้ทุกที่โดยไม่ต้องเรียกใช้ `require`:

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Rails _โหลดอัตโนมัติ_ ให้คุณหากจำเป็น สิ่งนี้เป็นไปได้เนื่องจากมี [Zeitwerk](https://github.com/fxn/zeitwerk) loaders ที่ Rails ตั้งค่าให้คุณ ซึ่งให้การโหลดอัตโนมัติ การโหลดใหม่ และการโหลดแบบกระตือรือร้น

อย่างไรก็ตาม โหลดเหล่านั้นไม่จัดการอะไรอื่นๆ โดยเฉพาะอย่างยิ่ง ไม่จัดการกับไลบรารีมาตรฐานของ Ruby ขึ้นอยู่กับ gem dependencies ตัวคอมโพเนนต์ของ Rails หรือแม้กระทั่ง (โดยค่าเริ่มต้น) ไดเรกทอรี `lib` ของแอปพลิเคชัน โค้ดเหล่านั้นต้องโหลดเหมือนเดิม


โครงสร้างโปรเจค
-----------------

ในแอปพลิเคชัน Rails ชื่อไฟล์จะต้องตรงกับค่าคงที่ที่กำหนด โดยใช้ไดเรกทอรีเป็นเนมสเปซ

ตัวอย่างเช่น ไฟล์ `app/helpers/users_helper.rb` ควรจะกำหนดค่า `UsersHelper` และไฟล์ `app/controllers/admin/payments_controller.rb` ควรจะกำหนดค่า `Admin::PaymentsController`

โดยค่าเริ่มต้น Rails กำหนด Zeitwerk ให้เปลี่ยนชื่อไฟล์ด้วย `String#camelize` ตัวอย่างเช่น มันคาดหวังว่า `app/controllers/users_controller.rb` จะกำหนดค่า `UsersController` เพราะว่า `"users_controller".camelize` จะคืนค่านั้น

ส่วน _การกำหนดค่า Inflections ที่กำหนดเอง_ ด้านล่างเอกสารนี้เป็นเอกสารที่อธิบายถึงวิธีการแทนที่ค่าเริ่มต้นนี้

โปรดตรวจสอบ [เอกสาร Zeitwerk](https://github.com/fxn/zeitwerk#file-structure) เพื่อข้อมูลเพิ่มเติม


config.autoload_paths
---------------------

เราอ้างถึงรายการของไดเรกทอรีในแอปพลิเคชันที่เนื้อหาของมันจะถูกโหลดอัตโนมัติและ (ตามต้องการ) โหลดใหม่เป็น _autoload paths_ ตัวอย่างเช่น `app/models` ไดเรกทอรีเหล่านี้แทนที่รากเนมสเปซ: `Object`

INFO. Autoload paths ถูกเรียกว่า _root directories_ ในเอกสาร Zeitwerk แต่เราจะใช้คำว่า "autoload path" ในเอกสารนี้

ภายใน autoload path ชื่อไฟล์จะต้องตรงกับค่าคงที่ที่กำหนดเหมือนที่อธิบายไว้ [ที่นี่](https://github.com/fxn/zeitwerk#file-structure)

โดยค่าเริ่มต้นของ autoload paths ในแอปพลิเคชันประกอบด้วยไดเรกทอรีย่อยทั้งหมดของ `app` ที่มีอยู่เมื่อแอปพลิเคชันเริ่มทำงาน ---ยกเว้น `assets`, `javascript`, และ `views`--- รวมถึง autoload paths ของ engines ที่อาจจะขึ้นอยู่กับแอปพลิเคชัน

ตัวอย่างเช่น หาก `UsersHelper` ถูกนำมาใช้งานใน `app/helpers/users_helper.rb` โมดูลนั้นสามารถโหลดอัตโนมัติได้ คุณไม่ต้อง (และไม่ควร) เขียน `require` เพื่อโหลดมัน:

```bash
$ bin/rails runner 'p UsersHelper'
UsersHelper
```

Rails จะเพิ่มไดเรกทอรีที่กำหนดเองภายใต้ `app` เข้าไปใน autoload paths โดยอัตโนมัติ ตัวอย่างเช่น หากแอปพลิเคชันของคุณมี `app/presenters` คุณไม่ต้องกำหนดค่าใดๆ เพื่อโหลด presenters มันทำงานได้ทันที

อาร์เรย์ของ autoload paths เริ่มต้นสามารถขยายได้โดยการเพิ่มข้อมูลเข้าไปใน `config.autoload_paths` ใน `config/application.rb` หรือ `config/environments/*.rb` ตัวอย่างเช่น:

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_paths << "#{root}/extras"
  end
end
```
นอกจากนี้ยังสามารถเพิ่มเครื่องยนต์ในตัวคลาสเองและใน `config/environments/*.rb` ของตัวเองได้

คำเตือน: โปรดอย่าเปลี่ยนแปลง `ActiveSupport::Dependencies.autoload_paths` โดยตรง วิธีการเปลี่ยนแปลง autoload paths ให้ใช้ `config.autoload_paths`

คำเตือน: คุณไม่สามารถ autoload code ใน autoload paths ขณะที่แอปพลิเคชันกำลัง boot โดยตรงใน `config/initializers/*.rb` โปรดตรวจสอบ [_Autoloading when the application boots_] (#autoloading-when-the-application-boots) ด้านล่างสำหรับวิธีที่ถูกต้องในการทำเช่นนั้น

Autoload paths จัดการโดย `Rails.autoloaders.main` autoloader

config.autoload_lib(ignore:)
----------------------------

โดยค่าเริ่มต้น `lib` directory ไม่ได้อยู่ใน autoload paths ของแอปพลิเคชันหรือเครื่องยนต์

เมธอดการกำหนดค่า `config.autoload_lib` เพิ่ม `lib` directory เข้าไปใน `config.autoload_paths` และ `config.eager_load_paths` ต้องเรียกใช้จาก `config/application.rb` หรือ `config/environments/*.rb` และไม่สามารถใช้สำหรับเครื่องยนต์ได้

โดยปกติ `lib` มีโฟลเดอร์ย่อยที่ไม่ควรถูกจัดการโดย autoloaders โปรดระบุชื่อของโฟลเดอร์เหล่านั้นที่เกี่ยวข้องกับ `lib` ในอาร์กิวเมนต์คีย์เวิร์ด `ignore` ตัวอย่างเช่น:

```ruby
config.autoload_lib(ignore: %w(assets tasks))
```

ทำไม? ในขณะที่ `assets` และ `tasks` แชร์ `lib` directory กับโค้ดปกติ แต่เนื้อหาของพวกเขาไม่ได้ถูกออโต้โหลดหรือ eager load แอสเซ็ทและแทสก์ไม่ใช่ Ruby namespaces ในที่นั้น อย่างเดียวกับ generators หากคุณมี:

```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

`config.autoload_lib` ไม่สามารถใช้ได้ก่อนเวอร์ชัน 7.1 แต่คุณยังสามารถจำลองได้ตามที่แอปพลิเคชันใช้ Zeitwerk:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.main.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

config.autoload_once_paths
--------------------------

คุณอาจต้องการสามารถ autoload classes และ modules โดยไม่ต้องโหลดซ้ำ การกำหนดค่า `autoload_once_paths` เก็บรหัสที่สามารถ autoload ได้ แต่จะไม่โหลดซ้ำ

โดยค่าเริ่มต้นคอลเลกชันนี้ว่างเปล่า แต่คุณสามารถเพิ่มได้โดยการเพิ่มลงใน `config.autoload_once_paths` คุณสามารถทำได้ใน `config/application.rb` หรือ `config/environments/*.rb` ตัวอย่างเช่น:

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_once_paths << "#{root}/app/serializers"
  end
end
```

นอกจากนี้ยังสามารถเพิ่มเครื่องยนต์ในตัวคลาสเองและใน `config/environments/*.rb` ของตัวเองได้

INFO. หาก `app/serializers` ถูกเพิ่มเข้าไปใน `config.autoload_once_paths` Rails จะไม่พิจารณาว่าเป็น autoload path แม้ว่าจะเป็นไดเรกทอรีที่กำหนดเองภายใต้ `app` การตั้งค่านี้จะเขียนทับกฎนั้น

สำหรับคลาสและโมดูลที่ถูกแคชในสถานที่ที่ยังคงอยู่หลังจากโหลดซ้ำ เช่นเดียวกับเฟรมเวิร์กของ Rails

ตัวอย่างเช่น ซีเรียลไรเซอร์ Active Job ถูกเก็บไว้ภายใน Active Job:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

และ Active Job เองจะไม่โหลดซ้ำเมื่อมีการโหลดซ้ำ เฉพาะแอปพลิเคชันและโค้ดเครื่องยนต์ใน autoload paths เท่านั้น

การทำให้ `MoneySerializer` สามารถโหลดซ้ำได้จะทำให้สับสน เนื่องจากการโหลดซ้ำเวอร์ชันที่แก้ไขจะไม่มีผลต่อวัตถุคลาสที่เก็บไว้ใน Active Job ในทางกลับกัน หาก `MoneySerializer` สามารถโหลดซ้ำได้ เริ่มต้นด้วย Rails 7 ตัวกำหนดค่าเช่นนั้นจะเรียก `NameError`

กรณีการใช้งานอื่นคือเมื่อเครื่องยนต์ตกแต่งคลาสของเฟรม:

```ruby
initializer "decorate ActionController::Base" do
  ActiveSupport.on_load(:action_controller_base) do
    include MyDecoration
  end
end
```

ที่นั่น วัตถุโมดูลที่เก็บไว้ใน `MyDecoration` ในขณะที่ตัวกำหนดค่าทำงานกลายเป็นลูกสายของ `ActionController::Base` และการโหลดซ้ำ `MyDecoration` ไม่มีประโยชน์ เพราะจะไม่มีผลต่อลูกสายของนั้น

คลาสและโมดูลจาก autoload once paths สามารถโหลดซ้ำใน `config/initializers` ดังนั้น ด้วยการกำหนดค่านี้สามารถทำงานได้ดังนี้:
```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

ข้อมูล: ในทางเทคนิค คุณสามารถโหลดคลาสและโมดูลที่จัดการโดย autoloader แบบ `once` ใน initializer ใด ๆ ที่ทำงานหลังจาก `:bootstrap_hook` 

เส้นทางการโหลดอัตโนมัติครั้งเดียวถูกจัดการโดย `Rails.autoloaders.once`

config.autoload_lib_once(ignore:)
---------------------------------

เมธอด `config.autoload_lib_once` คล้ายกับ `config.autoload_lib` ยกเว้นว่ามันเพิ่ม `lib` เข้าไปใน `config.autoload_once_paths` แทน ต้องเรียกใช้จาก `config/application.rb` หรือ `config/environments/*.rb` และไม่สามารถใช้สำหรับเอนจิน

โดยเรียกใช้ `config.autoload_lib_once` คลาสและโมดูลใน `lib` สามารถโหลดอัตโนมัติได้ แม้จะเรียกใช้ใน initializer ของแอปพลิเคชัน แต่จะไม่ถูกโหลดใหม่

`config.autoload_lib_once` ไม่สามารถใช้ได้ก่อน 7.1 แต่คุณยังสามารถจำลองได้ตามที่แอปพลิเคชันใช้ Zeitwerk:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_once_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.once.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

$LOAD_PATH{#load_path}
----------

เส้นทางการโหลดอัตโนมัติถูกเพิ่มใน `$LOAD_PATH` โดยค่าเริ่มต้น อย่างไรก็ตาม Zeitwerk ใช้ชื่อไฟล์แบบสมบูรณ์ภายใน และแอปพลิเคชันของคุณไม่ควรเรียกใช้ `require` สำหรับไฟล์ที่สามารถโหลดอัตโนมัติได้ ดังนั้น ไดเรกทอรีเหล่านั้นไม่จำเป็นต้องอยู่ที่นั่น คุณสามารถเลือกไม่ใช้ด้วยตัวเลือกนี้:

```ruby
config.add_autoload_paths_to_load_path = false
```

นั่นอาจทำให้การเรียก `require` ที่ถูกต้องเร็วขึ้นเล็กน้อยเนื่องจากมีการค้นหาน้อยลง นอกจากนี้หากแอปพลิเคชันของคุณใช้ [Bootsnap](https://github.com/Shopify/bootsnap) จะช่วยประหยัดหน่วยความจำในการสร้างดัชนีที่ไม่จำเป็น

ไดเรกทอรี `lib` ไม่ได้รับผลกระทบจากตัวเลือกนี้ เส้นทางนี้ถูกเพิ่มใน `$LOAD_PATH` เสมอ

การโหลดใหม่
---------

Rails โหลดคลาสและโมดูลโดยอัตโนมัติหากไฟล์แอปพลิเคชันในเส้นทางการโหลดอัตโนมัติเปลี่ยนแปลง

โดยแน่นอนถ้าเว็บเซิร์ฟเวอร์กำลังทำงานและไฟล์แอปพลิเคชันได้รับการแก้ไข Rails จะยกเลิกโครงสร้างค่าคงที่ที่โหลดอัตโนมัติทั้งหมดที่จัดการโดย autoloader `main` ก่อนที่คำขอถัดไปจะถูกประมวลผล ด้วยวิธีนี้คลาสหรือโมดูลของแอปพลิเคชันที่ใช้ระหว่างคำขอนั้นจะถูกโหลดอัตโนมัติอีกครั้ง ซึ่งจะเก็บการปรับปรุงปัจจุบันของตัวเองในระบบไฟล์

การโหลดใหม่สามารถเปิดหรือปิดได้ การตั้งค่าที่ควบคุมพฤติกรรมนี้คือ [`config.enable_reloading`][] ซึ่งเป็น `true` เริ่มต้นในโหมด `development` และ `false` เริ่มต้นในโหมด `production` สำหรับความเข้ากันทางถอยหลัง Rails ยังรองรับ `config.cache_classes` ซึ่งเทียบเท่ากับ `!config.enable_reloading`

Rails ใช้ตัวตรวจสอบไฟล์แบบเหตุการณ์เพื่อตรวจหาการเปลี่ยนแปลงของไฟล์โดยค่าเริ่มต้น สามารถกำหนดค่าให้ตรวจหาการเปลี่ยนแปลงของไฟล์โดยการเดินทางในเส้นทางการโหลดอัตโนมัติได้ ซึ่งควบคุมโดยการตั้งค่า [`config.file_watcher`][]

ในคอนโซลของ Rails ไม่มีตัวตรวจสอบไฟล์ที่ใช้งานอยู่ไม่ว่าค่าของ `config.enable_reloading` จะเป็นอย่างไร นี่เพราะว่า โดยปกติแล้ว การโหลดโค้ดใหม่ในระหว่างเซสชันคอนโซลอาจทำให้สับสน คุณต้องการให้เซสชันคอนโซลเสมอถูกบริการโดยชุดคลาสและโมดูลของแอปพลิเคชันที่เปลี่ยนแปลงไม่เปลี่ยนแปลง

อย่างไรก็ตาม คุณสามารถบังคับให้โหลดใหม่ในคอนโซลได้โดยการดำเนินการ `reload!`:

```irb
irb(main):001:0> User.object_id
=> 70136277390120
irb(main):002:0> reload!
Reloading...
=> true
irb(main):003:0> User.object_id
=> 70136284426020
```

จากตัวอย่างนี้ จะเห็นว่าวัตถุคลาสที่เก็บไว้ในค่าคงที่ `User` แตกต่างกันหลังจากโหลดใหม่


### การโหลดใหม่และวัตถุที่หมดอายุ

สิ่งสำคัญมากที่จะเข้าใจคือ Ruby ไม่มีวิธีการโหลดคลาสและโมดูลใหม่ในหน่วยความจำและให้มีผลทั่วไปที่ใช้งานอยู่ทั่วไป ในทางเทคนิค "การยกเลิกโหลด" คลาส `User` หมายถึงการลบค่าคงที่ `User` ผ่าน `Object.send(:remove_const, "User")`.
ตัวอย่างเช่น ดูเซสชั่นคอนโซล Rails นี้:

```irb
irb> joe = User.new
irb> reload!
irb> alice = User.new
irb> joe.class == alice.class
=> false
```

`joe` เป็นตัวอย่างของคลาส `User` ต้นฉบับ  เมื่อมีการโหลดใหม่ ค่าคงที่ `User` จะถูกประเมินใหม่เป็นคลาสที่โหลดใหม่  `alice` เป็นตัวอย่างของ `User` ที่โหลดใหม่ แต่ `joe` ไม่ใช่ - คลาสของเขาเป็นคลาสที่ล้าสมัย คุณสามารถกำหนด `joe` อีกครั้ง เริ่ม subsession IRB หรือเปิดคอนโซลใหม่แทนที่จะเรียกใช้ `reload!`.

สถานการณ์อื่น ๆ ที่คุณอาจพบกับสิ่งนี้คือการสืบทอดคลาสที่สามารถโหลดใหม่ได้ในสถานที่ที่ไม่ได้โหลดใหม่:

```ruby
# lib/vip_user.rb
class VipUser < User
end
```

ถ้า `User` โหลดใหม่ เนื่องจาก `VipUser` ไม่ได้โหลดใหม่ คลาสเหล่านี้จะเป็นคลาสวัตถุเดิมที่ล้าสมัย

สรุป: **อย่าเก็บแคชคลาสหรือโมดูลที่สามารถโหลดใหม่ได้**

## การโหลดอัตโนมัติเมื่อแอปพลิเคชันเริ่มทำงาน

ขณะที่กำลังเริ่มทำงาน แอปพลิเคชันสามารถโหลดอัตโนมัติจากเส้นทางโหลดอัตโนมัติครั้งเดียว ซึ่งจัดการโดยตัวโหลดอัตโนมัติ `once` โปรดตรวจสอบส่วน [`config.autoload_once_paths`](#config-autoload-once-paths) ด้านบน

อย่างไรก็ตาม คุณไม่สามารถโหลดอัตโนมัติจากเส้นทางโหลดอัตโนมัติได้ ซึ่งจัดการโดยตัวโหลดอัตโนมัติ `main` นี้ใช้กับโค้ดใน `config/initializers` และตัวเริ่มต้นของแอปพลิเคชันหรือเริ่มต้นของเอนจิน

ทำไม? เริ่มต้นทำงานเพียงครั้งเดียวเมื่อแอปพลิเคชันเริ่มทำงาน พวกเขาไม่ทำงานอีกครั้งในการโหลดใหม่ หากตัวเริ่มต้นใช้คลาสหรือโมดูลที่สามารถโหลดใหม่ได้ การแก้ไขที่เขาจะไม่สะท้อนในรหัสเริ่มต้นนั้น ทำให้เป็นค่าคงที่ ดังนั้น การอ้างอิงค่าคงที่ที่สามารถโหลดใหม่ได้ระหว่างการเริ่มต้นไม่ได้รับอนุญาต

มาดูว่าจะทำอย่างไรแทน

### กรณีใช้งานที่ 1: ในระหว่างการเริ่มต้นทำงาน โหลดโค้ดที่สามารถโหลดใหม่ได้

#### โหลดอัตโนมัติในขณะที่เริ่มต้นและในการโหลดใหม่ทุกครั้ง

พิจารณา `ApiGateway` เป็นคลาสที่สามารถโหลดใหม่ได้และคุณต้องการกำหนดค่าจุดปลายทางของมันในขณะที่แอปพลิเคชันเริ่มทำงาน:

```ruby
# config/initializers/api_gateway_setup.rb
ApiGateway.endpoint = "https://example.com" # NameError
```

ตัวเริ่มต้นไม่สามารถอ้างอิงถึงค่าคงที่ที่สามารถโหลดใหม่ได้ คุณต้องแทรกในบล็อก `to_prepare` ซึ่งทำงานเมื่อเริ่มต้นและหลังจากโหลดใหม่ทุกครั้ง:

```ruby
# config/initializers/api_gateway_setup.rb
Rails.application.config.to_prepare do
  ApiGateway.endpoint = "https://example.com" # CORRECT
end
```

หมายเหตุ: เนื่องจากเหตุผลประวัติศาสตร์ การเรียกใช้งานนี้อาจทำงานสองครั้ง รหัสที่มันทำงานต้องเป็นรหัสที่สามารถทำงานได้หลายครั้ง

#### โหลดอัตโนมัติเฉพาะในขณะที่เริ่มต้นเท่านั้น

คลาสและโมดูลที่สามารถโหลดใหม่ได้สามารถโหลดอัตโนมัติในบล็อก `after_initialize` ได้เช่นกัน พวกเขาทำงานเมื่อเริ่มต้นแต่ไม่ทำงานอีกครั้งในการโหลดใหม่ ในบางกรณีที่พิเศษนี้อาจเป็นสิ่งที่คุณต้องการ

การตรวจสอบก่อนทำงานเป็นกรณีใช้งานสำหรับสิ่งนี้:

```ruby
# config/initializers/check_admin_presence.rb
Rails.application.config.after_initialize do
  unless Role.where(name: "admin").exists?
    abort "The admin role is not present, please seed the database."
  end
end
```

### กรณีใช้งานที่ 2: ในระหว่างการเริ่มต้นทำงาน โหลดโค้ดที่ยังคงแคช

บางการกำหนดค่าใช้วัตถุคลาสหรือโมดูล และพวกเขาจัดเก็บในสถานที่ที่ไม่ได้โหลดใหม่ สำคัญที่ว่าเหล่านี้ไม่ใช่สิ่งที่สามารถโหลดใหม่ได้ เนื่องจากการแก้ไขจะไม่สะท้อนในวัตถุที่ถูกแคชไว้

ตัวอย่างหนึ่งคือ middleware:

```ruby
config.middleware.use MyApp::Middleware::Foo
```

เมื่อคุณโหลดใหม่ สแต็ก middleware จะไม่ได้รับผลกระทบ ดังนั้นมันจะสับสนที่ `MyApp::Middleware::Foo` เป็นสิ่งที่สามารถโหลดใหม่ได้ การเปลี่ยนแปลงในการดำเนินการของมันจะไม่มีผล

ตัวอย่างอื่น ๆ คือตัวแปรตัวเลือกงาน Active:

```ruby
config.active_job.serializer = :json
```

เมื่อคุณโหลดใหม่ ตัวเลือกงาน Active จะไม่ได้รับผลกระทบ การเปลี่ยนแปลงในการดำเนินการของมันจะไม่มีผล


```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

สิ่งที่ `MoneySerializer` ประเมินค่าในระหว่างการเริ่มต้นจะถูกเพิ่มเข้าไปในตัวแปร custom serializers และวัตถุนั้นจะอยู่ที่นั่นเมื่อโหลดใหม่

ตัวอย่างอื่น ๆ คือ railties หรือ engines ที่ตกแต่งคลาสของเฟรมเวิร์กโดยการรวมโมดูล เช่น [`turbo-rails`](https://github.com/hotwired/turbo-rails) ตกแต่ง `ActiveRecord::Base` ดังนี้:

```ruby
initializer "turbo.broadcastable" do
  ActiveSupport.on_load(:active_record) do
    include Turbo::Broadcastable
  end
end
```

สิ่งนี้เพิ่มวัตถุโมดูลเข้าไปในลำดับของ `ActiveRecord::Base` การเปลี่ยนแปลงใน `Turbo::Broadcastable` จะไม่มีผลต่อการโหลดใหม่ ลำดับของลูกสายจะยังคงมีอยู่เหมือนเดิม

ผลลัพธ์: คลาสหรือโมดูลเหล่านั้น **ไม่สามารถโหลดใหม่ได้**

วิธีที่ง่ายที่สุดในการอ้างอิงถึงคลาสหรือโมดูลเหล่านั้นในระหว่างการบูตคือการกำหนดให้มีการกำหนดค่าในไดเรกทอรีที่ไม่ได้เป็นส่วนหนึ่งของ autoload paths ตัวอย่างเช่น `lib` เป็นทางเลือกที่เหมาะสม มันไม่ได้อยู่ใน autoload paths เริ่มต้น แต่มันอยู่ใน `$LOAD_PATH` เพียงแค่ใช้ `require` เพื่อโหลดมัน

เช่นเดียวกับที่กล่าวไว้ข้างต้น ตัวเลือกอื่น ๆ คือการกำหนดให้ไดเรกทอรีที่กำหนดค่าใน autoload once paths และ autoload โปรดตรวจสอบ [ส่วนเกี่ยวกับ config.autoload_once_paths](#config-autoload-once-paths) เพื่อดูรายละเอียด

### กรณีการใช้งานที่ 3: กำหนดค่าคลาสแอปพลิเคชันสำหรับเอนจิน

เราสมมติว่าเอนจินทำงานกับคลาสแอปพลิเคชันที่โหลดใหม่ได้ที่จำลองผู้ใช้และมีจุดกำหนดค่าสำหรับมัน:

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = User # NameError
end
```

เพื่อให้ทำงานได้อย่างถูกต้องกับโค้ดแอปพลิเคชันที่โหลดเกินไป เอนจินจึงต้องการให้แอปพลิเคชันกำหนดค่า _ชื่อ_ ของคลาสนั้น:

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = "User" # OK
end
```

จากนั้น ในเวลารัน `config.user_model.constantize` จะให้คุณวัตถุคลาสปัจจุบัน

Eager Loading
-------------

ในสภาพแวดล้อมที่คล้ายกับการใช้งานจริง ๆ การโหลดแอปพลิเคชันทั้งหมดเมื่อแอปพลิเคชันบูตจะดีกว่า การโหลดแบบกระชับทำให้ทุกอย่างอยู่ในหน่วยความจำพร้อมที่จะให้บริการคำขอทันที และมันยังเป็น [CoW](https://en.wikipedia.org/wiki/Copy-on-write)-friendly

การโหลดแบบกระชับควบคุมโดยฟลาก [`config.eager_load`][] ซึ่งถูกปิดใช้งานตามค่าเริ่มต้นในสภาพแวดล้อมทั้งหมดยกเว้น `production` เมื่อเรียกใช้งานงาน Rake `config.eager_load` จะถูกแทนที่ด้วย [`config.rake_eager_load`][] ซึ่งเป็น `false` ตามค่าเริ่มต้น ดังนั้น ตามค่าเริ่มต้นในสภาพแวดล้อมการใช้งานงาน Rake จะไม่โหลดแอปพลิเคชันแบบกระชับ

ลำดับที่ไฟล์ถูกโหลดแบบกระชับไม่ได้ถูกกำหนดไว้

ในระหว่างการโหลดแบบกระชับ Rails เรียกใช้ `Zeitwerk::Loader.eager_load_all` เพื่อให้แน่ใจว่าทุกโมดูลที่จัดการโดย Zeitwerk โหลดแบบกระชับด้วย

การสืบทอดแบบตารางเดียว
------------------------

การสืบทอดแบบตารางเดียวไม่เข้ากันได้กับการโหลดแบบเลื่อน: Active Record ต้องรู้เรื่องของลำดับสายเอสทีไอเพื่อทำงานอย่างถูกต้อง แต่เมื่อโหลดแบบเลื่อน คลาสจะถูกโหลดเฉพาะตามความต้องการ!

เพื่อแก้ไขความไม่สอดคล้องนี้ เราต้องโหลด STI ล่วงหน้า มีตัวเลือกหลายอย่างที่สามารถทำได้ โดยมีการแลกเปลี่ยนที่แตกต่างกัน มาดูกัน

### ตัวเลือกที่ 1: เปิดใช้งานการโหลดแบบกระชับ

วิธีที่ง่ายที่สุดในการโหลด STI คือเปิดใช้งานการโหลดแบบกระชับโดยการตั้งค่า:

```ruby
config.eager_load = true
```

ใน `config/environments/development.rb` และ `config/environments/test.rb`

นี้เป็นวิธีง่าย แต่อาจมีค่าใช้จ่ายเพราะมันจะโหลดแอปพลิเคชันทั้งหมดในเวลาบูตและในการโหลดใหม่ทุกครั้ง แต่การแลกเปลี่ยนอาจมีค่าใช้จ่ายที่คุ้มค่าสำหรับแอปพลิเคชันขนาดเล็ก

### ตัวเลือกที่ 2: โหลดไดเรกทอรีที่ถูกยุบรวมกัน
เก็บไฟล์ที่กำหนดลำดับขั้นในไดเรกทอรีที่กำหนดเฉพาะ ซึ่งมีความหมายที่เข้าใจได้ตามแนวความคิดด้วย ไดเรกทอรีไม่ได้มีไว้เพื่อแทนที่เนมสเปซ วัตถุประสงค์เดียวของไดเรกทอรีคือการจัดกลุ่ม STI:

```
app/models/shapes/shape.rb
app/models/shapes/circle.rb
app/models/shapes/square.rb
app/models/shapes/triangle.rb
```

ในตัวอย่างนี้ เรายังต้องการให้ `app/models/shapes/circle.rb` กำหนด `Circle` ไม่ใช่ `Shapes::Circle` นี่อาจเป็นความชอบส่วนบุคคลของคุณในการเก็บสิ่งที่เรียบง่าย และยังลดการเปลี่ยนแปลงในรหัสที่มีอยู่แล้ว ฟีเจอร์การยุบรวม (collapsing) ของ Zeitwerk ช่วยให้เราทำได้:

```ruby
# config/initializers/preload_stis.rb

shapes = "#{Rails.root}/app/models/shapes"
Rails.autoloaders.main.collapse(shapes) # ไม่ใช่เนมสเปซ.

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir(shapes)
  end
end
```

ในตัวเลือกนี้ เราจะโหลดไฟล์เหล่านี้ในขณะที่เริ่มต้นและโหลดใหม่ แม้ว่า STI จะไม่ถูกใช้งาน อย่างไรก็ตาม ยกเว้นว่าแอปพลิเคชันของคุณมี STI จำนวนมาก สิ่งนี้จะไม่มีผลกระทบที่สามารถวัดได้

ข้อมูล: เมธอด `Zeitwerk::Loader#eager_load_dir` ถูกเพิ่มใน Zeitwerk 2.6.2 สำหรับเวอร์ชันเก่ากว่านั้น คุณยังสามารถระบุไดเรกทอรี `app/models/shapes` และเรียกใช้ `require_dependency` บนเนื้อหาของมันได้

คำเตือน: หากมีการเพิ่ม แก้ไข หรือลบโมเดลจาก STI การโหลดใหม่จะทำงานตามที่คาดหวัง อย่างไรก็ตามหากมีการเพิ่มลำดับ STI ที่แยกต่างหากในแอปพลิเคชัน คุณจะต้องแก้ไขไอนิเซลเซอร์และเริ่มเซิร์ฟเวอร์ใหม่

### ตัวเลือกที่ 3: โหลดล่วงหน้าจากไดเรกทอรีปกติ

คล้ายกับตัวเลือกก่อนหน้านี้ แต่ไดเรกทอรีจะถูกใช้เป็นเนมสเปซ กล่าวคือ `app/models/shapes/circle.rb` คาดหวังว่าจะกำหนด `Shapes::Circle`

สำหรับตัวเลือกนี้ ไอนิเซลเซอร์เหมือนเดิมยกเว้นไม่มีการกำหนดการยุบรวม:

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/shapes")
  end
end
```

เหมือนกับตัวเลือกก่อนหน้านี้

### ตัวเลือกที่ 4: โหลดล่วงหน้าจากฐานข้อมูล

ในตัวเลือกนี้ เราไม่จำเป็นต้องจัดระเบียบไฟล์ใด ๆ แต่เราต้องเข้าถึงฐานข้อมูล:

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    types = Shape.unscoped.select(:type).distinct.pluck(:type)
    types.compact.each(&:constantize)
  end
end
```

คำเตือน: STI จะทำงานได้ถูกต้องแม้ว่าตารางจะไม่มีประเภททั้งหมด แต่เมธอดเช่น `subclasses` หรือ `descendants` จะไม่ส่งคืนประเภทที่ขาดหายไป

คำเตือน: หากมีการเพิ่ม แก้ไข หรือลบโมเดลจาก STI การโหลดใหม่จะทำงานตามที่คาดหวัง อย่างไรก็ตามหากมีการเพิ่มลำดับ STI ที่แยกต่างหากในแอปพลิเคชัน คุณจะต้องแก้ไขไอนิเซลเซอร์และเริ่มเซิร์ฟเวอร์ใหม่

การปรับแต่งการเปลี่ยนรูปแบบ
-----------------------

โดยค่าเริ่มต้น Rails ใช้ `String#camelize` เพื่อรู้ว่าชื่อค่าคงที่ใดบางอย่างในไฟล์หรือชื่อไดเรกทอรีควรกำหนดค่าคงที่ใด ตัวอย่างเช่น `posts_controller.rb` ควรกำหนด `PostsController` เพราะว่าเป็นสิ่งที่ `"posts_controller".camelize` ส่งคืน

อาจเป็นได้ว่าชื่อไฟล์หรือชื่อไดเรกทอรีบางอย่างไม่ได้รับการเปลี่ยนรูปแบบตามที่คุณต้องการ ตัวอย่างเช่น `html_parser.rb` คาดหวังว่าจะกำหนด `HtmlParser` ตามค่าเริ่มต้น ถ้าคุณต้องการให้คลาสเป็น `HTMLParser` คุณสามารถปรับแต่งได้หลายวิธี

วิธีที่ง่ายที่สุดคือการกำหนดคำย่อ:

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "HTML"
  inflect.acronym "SSL"
end
```

การทำเช่นนี้จะมีผลต่อวิธีการเปลี่ยนรูปแบบของ Active Support ในระดับทั่วโลก อาจจะเหมาะกับบางแอปพลิเคชัน แต่คุณยังสามารถปรับแต่งวิธีการเปลี่ยนรูปแบบแยกต่างหากสำหรับเบสเนมได้โดยส่งค่าเริ่มต้นที่แตกต่างกันให้กับอินเฟล็กเตอร์เริ่มต้น:

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```
เทคนิคนี้ยังขึ้นอยู่กับ `String#camelize` อยู่ดีเพราะนี่คือสิ่งที่ inflector เริ่มต้นใช้เป็น fallback หากคุณต้องการไม่ต้องพึ่งพา Active Support inflections และต้องการควบคุม inflections ได้อย่างสมบูรณ์แบบ คุณสามารถกำหนด inflector เป็น instances ของ `Zeitwerk::Inflector`:

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector = Zeitwerk::Inflector.new
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

ไม่มีการกำหนดค่าส่วนกลางที่สามารถมีผลต่อ instances เหล่านั้นได้ มันเป็น deterministic

คุณยังสามารถกำหนด inflector ที่กำหนดเองได้สำหรับความยืดหยุ่นอย่างสมบูรณ์ โปรดตรวจสอบ [Zeitwerk documentation](https://github.com/fxn/zeitwerk#custom-inflector) เพื่อดูรายละเอียดเพิ่มเติม

### ที่ไหนควรวางการกำหนดค่า Inflection?

หากแอปพลิเคชันไม่ใช้ autoloader แบบ `once` ไฟล์ตัวอย่างด้านบนสามารถวางไว้ใน `config/initializers` ตัวอย่างเช่น `config/initializers/inflections.rb` สำหรับกรณีใช้งาน Active Support หรือ `config/initializers/zeitwerk.rb` สำหรับกรณีอื่น ๆ

แอปพลิเคชันที่ใช้ autoloader แบบ `once` จะต้องย้ายหรือโหลดการกำหนดค่านี้จากตัวอย่างแอปพลิเคชันใน `config/application.rb` เพราะ autoloader แบบ `once` ใช้ inflector ในขั้นตอนการบูตเร็ว

Custom Namespaces
-----------------

เหมือนที่เราเห็นข้างบน autoload paths แทนที่จะแสดงตัวแทนของ namespace ระดับบน: `Object`

เรามาพิจารณา `app/services` เป็นตัวอย่าง เส้นทางนี้ไม่ได้ถูกสร้างขึ้นโดยค่าเริ่มต้น แต่ถ้ามีอยู่ Rails จะเพิ่มมันเข้าไปใน autoload paths โดยอัตโนมัติ

ตามค่าเริ่มต้นไฟล์ `app/services/users/signup.rb` คาดหวังว่าจะกำหนด `Users::Signup` แต่ถ้าคุณต้องการที่ subtree ทั้งหมดนั้นจะอยู่ใน namespace `Services` คุณสามารถทำได้โดยการสร้าง subdirectory: `app/services/services`

อย่างไรก็ตาม ขึ้นอยู่กับความชอบของคุณ คุณอาจจะไม่รู้สึกถูกต้องเลยกับวิธีนี้ คุณอาจจะต้องการให้ `app/services/users/signup.rb` กำหนดเพียงแค่ `Services::Users::Signup`

Zeitwerk รองรับ [custom root namespaces](https://github.com/fxn/zeitwerk#custom-root-namespaces) เพื่อแก้ไขปัญหานี้ และคุณสามารถกำหนดค่า autoloader หลักเพื่อทำเช่นนั้นได้:

```ruby
# config/initializers/autoloading.rb

# ต้องมี namespace อยู่
#
# ในตัวอย่างนี้เรากำหนดโมดูลในที่นี้ ก็สามารถสร้างที่อื่นแล้วโหลดคำนิยามมาที่นี่ด้วย `require` ได้
# อย่างไรก็ตาม `push_dir` ต้องการวัตถุคลาสหรือโมดูล
module Services; end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/services", namespace: Services)
```

Rails < 7.1 ไม่รองรับคุณสมบัตินี้ แต่คุณยังสามารถเพิ่มโค้ดเพิ่มเติมในไฟล์เดียวกันและทำให้มันทำงานได้:

```ruby
# โค้ดเพิ่มเติมสำหรับแอปพลิเคชันที่ทำงานบน Rails < 7.1
app_services_dir = "#{Rails.root}/app/services" # ต้องเป็นสตริง
ActiveSupport::Dependencies.autoload_paths.delete(app_services_dir)
Rails.application.config.watchable_dirs[app_services_dir] = [:rb]
```

Custom namespaces ยังรองรับสำหรับ autoloader แบบ `once` อยู่ด้วย อย่างไรก็ตาม เนื่องจาก autoloader แบบนั้นถูกตั้งค่าก่อนในกระบวนการบูต การกำหนดค่าไม่สามารถทำได้ใน initializer ของแอปพลิเคชันได้ แทนนั้นโปรดวางไว้ใน `config/application.rb` เช่น

Autoloading and Engines
-----------------------

Engines ทำงานในบริบทของแอปพลิเคชันหลัก และโค้ดของพวกเขาถูก autoload, reload และ eager load โดยแอปพลิเคชันหลัก หากแอปพลิเคชันทำงานในโหมด `zeitwerk` โค้ดของเอ็นจินจะถูกโหลดโดยโหมด `zeitwerk` หากแอปพลิเคชันทำงานในโหมด `classic` โค้ดของเอ็นจินจะถูกโหลดโดยโหมด `classic`

เมื่อ Rails บูต เอ็นจินจะถูกเพิ่มเข้าไปใน autoload paths และจากมุมมองของ autoloader ไม่มีความแตกต่าง ข้อมูลเข้าหลักของ autoloader คือ autoload paths และว่าว่าพวกเขาเป็นส่วนหนึ่งของต้นฉบับของแอปพลิเคชันหรือไม่ก็ไม่สำคัญ
ตัวอย่างเช่นแอปพลิเคชันนี้ใช้ [Devise](https://github.com/heartcombo/devise):

```
% bin/rails runner 'pp ActiveSupport::Dependencies.autoload_paths'
[".../app/controllers",
 ".../app/controllers/concerns",
 ".../app/helpers",
 ".../app/models",
 ".../app/models/concerns",
 ".../gems/devise-4.8.0/app/controllers",
 ".../gems/devise-4.8.0/app/helpers",
 ".../gems/devise-4.8.0/app/mailers"]
 ```

หากเอ็นจินควบคุมโหมดการโหลดอัตโนมัติของแอปพลิเคชันหลัก แอปพลิเคชันสามารถเขียนได้เหมือนเดิม

อย่างไรก็ตาม หากเอ็นจินรองรับ Rails 6 หรือ Rails 6.1 และไม่ควบคุมแอปพลิเคชันหลัก เอ็นจินจะต้องพร้อมที่จะทำงานในโหมด `classic` หรือ `zeitwerk` อย่างไรก็ตาม สิ่งที่ต้องพิจารณา:

1. หากโหมด `classic` ต้องการการเรียกใช้ `require_dependency` เพื่อให้แน่ใจว่าค่าคงที่บางอย่างถูกโหลดในบางจุด ให้เขียนมัน ในขณะที่ `zeitwerk` ไม่จำเป็นต้องใช้ แต่มันก็ไม่เป็นอันตราย มันจะทำงานในโหมด `zeitwerk` ได้เช่นกัน

2. โหมด `classic` ใช้เครื่องหมายขีดล่างในชื่อค่าคงที่ ("User" -> "user.rb") และโหมด `zeitwerk` ใช้เครื่องหมายตัวใหญ่ในชื่อไฟล์ ("user.rb" -> "User") พวกเขาตรงกันในกรณีส่วนใหญ่ แต่ไม่ตรงกันหากมีตัวอักษรตัวใหญ่ต่อเนื่องเช่น "HTMLParser" วิธีที่ง่ายที่สุดในการเป็นเครื่องที่เข้ากันได้คือการหลีกเลี่ยงชื่อเช่นนั้น ในกรณีนี้เลือก "HtmlParser"

3. ในโหมด `classic` ไฟล์ `app/model/concerns/foo.rb` อนุญาตให้กำหนดทั้ง `Foo` และ `Concerns::Foo` ในโหมด `zeitwerk` มีตัวเลือกเพียงอย่างเดียว: ต้องกำหนด `Foo` เพื่อให้เข้ากันได้ ในการเป็นเครื่องที่เข้ากันได้ ให้กำหนด `Foo`

การทดสอบ
-------

### การทดสอบด้วยตนเอง

งาน `zeitwerk:check` จะตรวจสอบว่าโครงสร้างโปรเจกต์ตามชื่อที่คาดหวังและมีประโยชน์สำหรับการตรวจสอบด้วยตนเอง ตัวอย่างเช่นหากคุณกำลังย้ายจากโหมด `classic` เป็นโหมด `zeitwerk` หรือหากคุณกำลังแก้ไขบางอย่าง:

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

อาจมีผลลัพธ์เพิ่มเติมขึ้นอยู่กับการกำหนดค่าแอปพลิเคชัน แต่ "All is good!" ที่สุดคือสิ่งที่คุณกำลังมองหา

### การทดสอบอัตโนมัติ

การตรวจสอบในชุดทดสอบว่าโปรเจกต์โหลดอัตโนมัติได้อย่างถูกต้องเป็นการปฏิบัติที่ดี

นี้เป็นการตรวจสอบความเข้ากันได้ของ Zeitwerk และเงื่อนไขข้อผิดพลาดอื่น ๆ โปรดตรวจสอบ [ส่วนเกี่ยวกับการทดสอบการโหลดอัตโนมัติ](testing.html#testing-eager-loading) ในคู่มือ [_Testing Rails Applications_](testing.html)

การแก้ปัญหา
---------------

วิธีที่ดีที่สุดในการติดตามกิจกรรมของโหลดเป็นการตรวจสอบกิจกรรมของโหลด

วิธีที่ง่ายที่สุดในการทำเช่นนั้นคือการรวม

```ruby
Rails.autoloaders.log!
```

ใน `config/application.rb` หลังจากโหลดค่าเริ่มต้นของเฟรมเวิร์ก นั่นจะพิมพ์ตามเส้นทางมาตรฐาน

หากคุณต้องการเขียนล็อกไปยังไฟล์ กำหนดค่าดังนี้แทน:

```ruby
Rails.autoloaders.logger = Logger.new("#{Rails.root}/log/autoloading.log")
```

เมื่อ `config/application.rb` ทำงาน ไม่มีเลเยอร์ Rails ที่พร้อมใช้งาน หากคุณต้องการใช้เลเยอร์ Rails กำหนดค่านี้ในตัวกำหนดเริ่มต้นแทน:

```ruby
# config/initializers/log_autoloaders.rb
Rails.autoloaders.logger = Rails.logger
```

Rails.autoloaders
-----------------

ตัวอย่าง Zeitwerk ที่จัดการแอปพลิเคชันของคุณสามารถใช้ได้ที่

```ruby
Rails.autoloaders.main
Rails.autoloaders.once
```

ตัวตรวจสอบ

```ruby
Rails.autoloaders.zeitwerk_enabled?
```

ยังใช้ได้ในแอปพลิเคชัน Rails 7 และคืนค่า `true`
[`config.enable_reloading`]: configuring.html#config-enable-reloading
[`config.file_watcher`]: configuring.html#config-file-watcher
[`config.eager_load`]: configuring.html#config-eager-load
[`config.rake_eager_load`]: configuring.html#config-rake-eager-load
