**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0651830a9dc9cbd4e8a1fddab047c719
การสร้างและปรับแต่งเจเนอเรเตอร์และเทมเพลตใน Rails
==================================================

เจเนอเรเตอร์ใน Rails เป็นเครื่องมือที่สำคัญในการปรับปรุงกระบวนการทำงานของคุณ ด้วยคู่มือนี้คุณจะเรียนรู้วิธีการสร้างเจเนอเรเตอร์และปรับแต่งเจเนอเรเตอร์ที่มีอยู่

หลังจากอ่านคู่มือนี้คุณจะรู้:

* วิธีดูเจเนอเรเตอร์ที่มีในแอปพลิเคชันของคุณ
* วิธีการสร้างเจเนอเรเตอร์โดยใช้เทมเพลต
* วิธีการค้นหาเจเนอเรเตอร์ใน Rails ก่อนเรียกใช้งาน
* วิธีปรับแต่งสคาฟโฟลด์ของคุณโดยการแทนที่เทมเพลตของเจเนอเรเตอร์
* วิธีปรับแต่งสคาฟโฟลด์ของคุณโดยการแทนที่เจเนอเรเตอร์
* วิธีใช้ fallback เพื่อหลีกเลี่ยงการเขียนทับเจเนอเรเตอร์จำนวนมาก
* วิธีการสร้างเทมเพลตแอปพลิเคชัน

--------------------------------------------------------------------------------

ครั้งแรกที่พบ
-------------

เมื่อคุณสร้างแอปพลิเคชันโดยใช้คำสั่ง `rails` คุณก็กำลังใช้เจเนอเรเตอร์ของ Rails แล้ว หลังจากนั้นคุณสามารถรับรายการของเจเนอเรเตอร์ทั้งหมดที่มีได้โดยเรียกใช้ `bin/rails generate`:

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

หมายเหตุ: เพื่อสร้างแอปพลิเคชัน Rails เราใช้คำสั่ง `rails` ที่เป็นคำสั่งทั่วไปซึ่งใช้เวอร์ชันของ Rails ที่ติดตั้งผ่าน `gem install rails` ในขณะที่อยู่ในไดเรกทอรีของแอปพลิเคชันของคุณ เราใช้คำสั่ง `bin/rails` ซึ่งใช้เวอร์ชันของ Rails ที่ถูกแพ็กเก็ตไว้กับแอปพลิเคชัน

คุณจะได้รายการของเจเนอเรเตอร์ทั้งหมดที่มากับ Rails ในรูปแบบรายละเอียด หากต้องการดูรายละเอียดของเจเนอเรเตอร์ใดๆ ให้เรียกใช้เจเนอเรเตอร์ด้วยตัวเลือก `--help` ตัวอย่างเช่น:

```bash
$ bin/rails generate scaffold --help
```

การสร้างเจเนอเรเตอร์แรกของคุณ
-----------------------------

เจเนอเรเตอร์ถูกสร้างบน [Thor](https://github.com/rails/thor) ซึ่งให้ตัวเลือกที่มีประสิทธิภาพในการแยกวิเคราะห์และ API ที่ยอดเยี่ยมในการจัดการไฟล์

มาสร้างเจเนอเรเตอร์ที่สร้างไฟล์เริ่มต้นชื่อ `initializer.rb` ภายใน `config/initializers` กันก่อน ขั้นแรกคือการสร้างไฟล์ที่ `lib/generators/initializer_generator.rb` ด้วยเนื้อหาดังต่อไปนี้:

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Add initialization content here
    RUBY
  end
end
```

เจเนอเรเตอร์ใหม่ของเราค่อนข้างเรียบง่าย: มันสืบทอดจาก [`Rails::Generators::Base`][] และมีการกำหนดเมธอดหนึ่ง เมื่อเรียกใช้เจเนอเรเตอร์ แต่ละเมธอดสาธารณะในเจเนอเรเตอร์จะถูกเรียกใช้ตามลำดับที่กำหนด ในกรณีของเรา เมธอดของเราเรียกใช้ [`create_file`][] ซึ่งจะสร้างไฟล์ในตำแหน่งปลายทางที่กำหนดพร้อมเนื้อหาที่กำหนด

เพื่อเรียกใช้เจเนอเรเตอร์ใหม่ของเรา เราใช้คำสั่ง:

```bash
$ bin/rails generate initializer
```

ก่อนที่เราจะไปต่อ ลองดูคำอธิบายของเจเนอเรเตอร์ใหม่ของเรากันก่อน:

```bash
$ bin/rails generate initializer --help
```

Rails สามารถสร้างคำอธิบายที่ดีได้โดยอัตโนมัติหากเจเนอเรเตอร์มีการเป็นชื่อเนมสเปซ เช่น `ActiveRecord::Generators::ModelGenerator` แต่ไม่ในกรณีนี้ เราสามารถแก้ไขปัญหานี้ได้ด้วยวิธีสองวิธี วิธีแรกคือการเรียกใช้ [`desc`][] ภายในเจเนอเรเตอร์ของเรา:

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "This generator creates an initializer file at config/initializers"
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Add initialization content here
    RUBY
  end
end
```

ตอนนี้เราสามารถดูคำอธิบายใหม่ได้โดยเรียกใช้ `--help` บนเจเนอเรเตอร์ใหม่

วิธีที่สองในการเพิ่มคำอธิบายคือการสร้างไฟล์ชื่อ `USAGE` ในไดเรกทอรีเดียวกับเจเนอเรเตอร์ของเรา เราจะทำในขั้นตอนถัดไป
สร้าง Generators ด้วย Generators
-----------------------------------

Generators เป็นตัวเองมี Generators อีกด้วย ลองลบ `InitializerGenerator` ของเราออกและใช้ `bin/rails generate generator` เพื่อสร้างใหม่:

```bash
$ rm lib/generators/initializer_generator.rb

$ bin/rails generate generator initializer
      create  lib/generators/initializer
      create  lib/generators/initializer/initializer_generator.rb
      create  lib/generators/initializer/USAGE
      create  lib/generators/initializer/templates
      invoke  test_unit
      create    test/lib/generators/initializer_generator_test.rb
```

นี่คือ Generator ที่สร้างใหม่:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
end
```

เริ่มแรก สังเกตว่า Generator สืบทอดมาจาก [`Rails::Generators::NamedBase`][] แทนที่จะเป็น `Rails::Generators::Base` นั่นหมายความว่า Generator ของเราคาดหวังอาร์กิวเมนต์อย่างน้อยหนึ่งตัว ซึ่งจะเป็นชื่อของ initializer และจะสามารถเข้าถึงได้ผ่าน `name`

เราสามารถเห็นได้จากคำอธิบายของ Generator ใหม่:

```bash
$ bin/rails generate initializer --help
Usage:
  bin/rails generate initializer NAME [options]
```

นอกจากนี้ Generator ยังมีเมธอดคลาสที่เรียกว่า [`source_root`][] ซึ่งชี้ไปยังตำแหน่งของเทมเพลต ถ้ามีอยู่ โดยค่าเริ่มต้นจะชี้ไปที่ไดเรกทอรี `lib/generators/initializer/templates` ที่เพิ่งถูกสร้างขึ้น

เพื่อเข้าใจว่าเทมเพลตของ Generator ทำงานอย่างไร เราลองสร้างไฟล์ `lib/generators/initializer/templates/initializer.rb` ด้วยเนื้อหาต่อไปนี้:

```ruby
# Add initialization content here
```

และเปลี่ยน Generator เพื่อคัดลอกเทมเพลตนี้เมื่อเรียกใช้:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

ตอนนี้ลองรัน Generator ของเรา:

```bash
$ bin/rails generate initializer core_extensions
      create  config/initializers/core_extensions.rb

$ cat config/initializers/core_extensions.rb
# Add initialization content here
```

เราเห็นว่า [`copy_file`][] สร้าง `config/initializers/core_extensions.rb` ด้วยเนื้อหาจากเทมเพลตของเรา (เมธอด `file_name` ที่ใช้ในเส้นทางปลายทางถูกสืบทอดมาจาก `Rails::Generators::NamedBase`)


ตัวเลือกบรรทัดคำสั่งของ Generator
------------------------------

Generator สามารถรองรับตัวเลือกบรรทัดคำสั่งได้โดยใช้ [`class_option`][] เช่น:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  class_option :scope, type: :string, default: "app"
end
```

ตอนนี้ Generator ของเราสามารถเรียกใช้งานพร้อมกับตัวเลือก `--scope` ได้:

```bash
$ bin/rails generate initializer theme --scope dashboard
```

ค่าตัวเลือกสามารถเข้าถึงได้ในเมธอดของ Generator ผ่าน [`options`][]:

```ruby
def copy_initializer_file
  @scope = options["scope"]
end
```


การตัดสินใจ Generator
--------------------

เมื่อต้องการตัดสินใจชื่อ Generator Rails จะค้นหา Generator โดยใช้ชื่อไฟล์หลายชื่อ ตัวอย่างเช่น เมื่อคุณรัน `bin/rails generate initializer core_extensions` Rails จะพยายามโหลดไฟล์ต่อไปนี้ทีละไฟล์ ตามลำดับ จนกว่าจะพบไฟล์หนึ่ง:

* `rails/generators/initializer/initializer_generator.rb`
* `generators/initializer/initializer_generator.rb`
* `rails/generators/initializer_generator.rb`
* `generators/initializer_generator.rb`

หากไม่พบไฟล์เหล่านี้ จะเกิดข้อผิดพลาด

เราวาง Generator ของเราในไดเรกทอรี `lib/` ของแอปพลิเคชันเพราะไดเรกทอรีนี้อยู่ใน `$LOAD_PATH` ซึ่งทำให้ Rails สามารถค้นหาและโหลดไฟล์ได้


การแทนที่เทมเพลต Generator ของ Rails
------------------------------------

Rails ยังค้นหาในสถานที่หลายแห่งเมื่อต้องการแทนที่ไฟล์เทมเพลตของ Generator หนึ่งในสถานที่นั้นคือไดเรกทอรี `lib/templates/` ของแอปพลิเคชัน นี้ทำให้เราสามารถแทนที่เทมเพลตที่ใช้โดย Generator ที่มีอยู่ใน Rails ได้ เช่น เราสามารถแทนที่ [scaffold controller template][] หรือ [scaffold view templates][]

เพื่อดูตัวอย่างนี้ให้เราสร้างไฟล์ `lib/templates/erb/scaffold/index.html.erb.tt` ด้วยเนื้อหาต่อไปนี้:

```erb
<%% @<%= plural_table_name %>.count %> <%= human_name.pluralize %>
```

โปรดทราบว่าเทมเพลตเป็นเทมเพลต ERB ที่เรนเดอร์ _อีก_ เทมเพลต ERB ดังนั้น ตัวอักษร `<%` ที่ควรปรากฏในเทมเพลต _ผลลัพธ์_ จะต้องถูกหนีเป็น `<%%` ในเทมเพลตของ _generator_
ตอนนี้เรามาเรียกใช้ตัวสร้าง scaffold ที่มีอยู่ใน Rails:

```bash
$ bin/rails generate scaffold Post title:string
      ...
      create      app/views/posts/index.html.erb
      ...
```

เนื้อหาของ `app/views/posts/index.html.erb` คือ:

```erb
<% @posts.count %> โพสต์
```

[scaffold controller template]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt
[scaffold view templates]: https://github.com/rails/rails/tree/main/railties/lib/rails/generators/erb/scaffold/templates

การแทนที่ Generators ของ Rails
---------------------------

เราสามารถกำหนดค่า Generators ที่มีอยู่ใน Rails ได้ผ่าน [`config.generators`][],
รวมถึงการแทนที่ Generators บางส่วนอย่างสมบูรณ์

ก่อนอื่นเรามาดูรายละเอียดของตัวสร้าง scaffold กันก่อน

```bash
$ bin/rails generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20230518000000_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      invoke  resource_route
       route    resources :users
      invoke  scaffold_controller
      create    app/controllers/users_controller.rb
      invoke    erb
      create      app/views/users
      create      app/views/users/index.html.erb
      create      app/views/users/edit.html.erb
      create      app/views/users/show.html.erb
      create      app/views/users/new.html.erb
      create      app/views/users/_form.html.erb
      create      app/views/users/_user.html.erb
      invoke    resource_route
      invoke    test_unit
      create      test/controllers/users_controller_test.rb
      create      test/system/users_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke      test_unit
      invoke    jbuilder
      create      app/views/users/index.json.jbuilder
      create      app/views/users/show.json.jbuilder
```

จากผลลัพธ์ เราสามารถเห็นได้ว่าตัวสร้าง scaffold เรียกใช้ตัวสร้างอื่น ๆ เช่นตัวสร้าง `scaffold_controller` และบางตัวสร้างก็เรียกใช้ตัวสร้างอื่น ๆ อีกด้วย โดยเฉพาะตัวสร้าง `scaffold_controller` ที่เรียกใช้ตัวสร้างอื่น ๆ หลายตัว เช่นตัวสร้าง `helper`

มาเราจะแทนที่ตัวสร้าง `helper` ที่มีอยู่ด้วยตัวสร้างใหม่ที่ชื่อว่า `my_helper` กัน:

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/rails/my_helper_generator_test.rb
```

และใน `lib/generators/rails/my_helper/my_helper_generator.rb` เราจะกำหนดตัวสร้างเป็นดังนี้:

```ruby
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<~RUBY
      module #{class_name}Helper
        # ฉันกำลังช่วยเหลือ!
      end
    RUBY
  end
end
```

สุดท้าย เราต้องบอกให้ Rails ใช้ตัวสร้าง `my_helper` แทนตัวสร้าง `helper` ที่มีอยู่ โดยใช้ `config.generators` ใน `config/application.rb` เราเพิ่ม:

```ruby
config.generators do |g|
  g.helper :my_helper
end
```

ตอนนี้ถ้าเราเรียกใช้ตัวสร้าง scaffold อีกครั้ง เราจะเห็นตัวสร้าง `my_helper` ทำงาน:

```bash
$ bin/rails generate scaffold Article body:text
      ...
      invoke  scaffold_controller
      ...
      invoke    my_helper
      create      app/helpers/articles_helper.rb
      ...
```

หมายเหตุ: เราอาจสังเกตได้ว่าผลลัพธ์สำหรับตัวสร้าง `helper` ที่มีอยู่รวมถึง "invoke test_unit" ในขณะที่ผลลัพธ์สำหรับ `my_helper` ไม่ได้รวมอยู่ แม้ว่าตัวสร้าง `helper` จะไม่สร้างเทสโดยค่าเริ่มต้น แต่มันก็ยังมีการเรียกใช้ [`hook_for`][] เพื่อทำเช่นเดียวกัน โดยการรวม `hook_for :test_framework, as: :helper` ในคลาส `MyHelperGenerator` ดูเอกสาร [`hook_for`][] เพื่อข้อมูลเพิ่มเติม


### Generators Fallbacks

วิธีการแทนที่ตัวสร้างเฉพาะอย่างอื่นคือการใช้ _fallbacks_ การใช้ fallback ช่วยให้เนมสเปซตัวสร้างสามารถเลือกใช้ตัวสร้างเนมสเปซอื่นได้

ตัวอย่างเช่น เราต้องการแทนที่ตัวสร้าง `test_unit:model` ด้วยตัวสร้าง `my_test_unit:model` ของเราเอง แต่เราไม่ต้องการแทนที่ตัวสร้าง `test_unit:*` อื่น ๆ เช่น `test_unit:controller`

ก่อนอื่น เราสร้างตัวสร้าง `my_test_unit:model` ใน `lib/generators/my_test_unit/model/model_generator.rb`:

```ruby
module MyTestUnit
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def do_different_stuff
      say "Doing different stuff..."
    end
  end
end
```

ต่อมา เราใช้ `config.generators` เพื่อกำหนดค่าตัวสร้าง `test_framework` เป็น `my_test_unit` แต่เราก็กำหนด fallback เพื่อให้ตัวสร้าง `my_test_unit:*` ที่หายไปสามารถแทนที่ด้วย `test_unit:*` ได้:

```ruby
config.generators do |g|
  g.test_framework :my_test_unit, fixture: false
  g.fallbacks[:my_test_unit] = :test_unit
end
```

ตอนนี้เมื่อเราเรียกใช้ตัวสร้าง scaffold เราจะเห็นว่า `my_test_unit` ได้แทนที่ `test_unit` แต่มีผลต่อเทสของแค่ตัวจัดการโมเดลเท่านั้น:
```bash
$ bin/rails generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20230518000000_create_comments.rb
      create    app/models/comment.rb
      invoke    my_test_unit
    กำลังทำสิ่งที่แตกต่าง...
      invoke  resource_route
       route    resources :comments
      invoke  scaffold_controller
      create    app/controllers/comments_controller.rb
      invoke    erb
      create      app/views/comments
      create      app/views/comments/index.html.erb
      create      app/views/comments/edit.html.erb
      create      app/views/comments/show.html.erb
      create      app/views/comments/new.html.erb
      create      app/views/comments/_form.html.erb
      create      app/views/comments/_comment.html.erb
      invoke    resource_route
      invoke    my_test_unit
      create      test/controllers/comments_controller_test.rb
      create      test/system/comments_test.rb
      invoke    helper
      create      app/helpers/comments_helper.rb
      invoke      my_test_unit
      invoke    jbuilder
      create      app/views/comments/index.json.jbuilder
      create      app/views/comments/show.json.jbuilder
```

Application Templates
---------------------

เทมเพลตแอปพลิเคชันเป็นชนิดพิเศษของเจเนอเรเตอร์ พวกเขาสามารถใช้เมธอดช่วยเจริญการสร้างเช่นเดียวกับ
[เมธอดช่วยเจริญเจเนอเรเตอร์](#เมธอดช่วยเจริญเจเนอเรเตอร์) แต่เขียนเป็นสคริปต์รูบีแทนที่จะเป็นคลาสรูบี ตัวอย่างเช่น:

```ruby
# template.rb

if yes?("คุณต้องการติดตั้ง Devise หรือไม่?")
  gem "devise"
  devise_model = ask("คุณต้องการตั้งชื่อโมเดลผู้ใช้ว่าอะไร?", default: "User")
end

after_bundle do
  if devise_model
    generate "devise:install"
    generate "devise", devise_model
    rails_command "db:migrate"
  end

  git add: ".", commit: %(-m 'Initial commit')
end
```

ก่อนอื่น เทมเพลตจะถามผู้ใช้ว่าต้องการติดตั้ง Devise หรือไม่ ถ้าผู้ใช้ตอบ "ใช่" (หรือ "y") เทมเพลตจะเพิ่ม Devise เข้าไปใน `Gemfile`
และถามผู้ใช้ชื่อโมเดลผู้ใช้ของ Devise (เริ่มต้นที่ `User`) ภายหลังจากนั้น เมื่อทำการรัน `bundle install` เทมเพลตจะรันเจเนอเรเตอร์ Devise
และ `rails db:migrate` หากมีการระบุโมเดล Devise ในท้ายที่สุด เทมเพลตจะ `git add` และ `git commit` ไดเรกทอรีแอปทั้งหมด

เราสามารถรันเทมเพลตของเราเมื่อสร้างแอปพลิเคชัน Rails ใหม่โดยใช้ตัวเลือก `-m` กับคำสั่ง `rails new`:

```bash
$ rails new my_cool_app -m path/to/template.rb
```

หรือเราสามารถรันเทมเพลตของเราภายในแอปพลิเคชันที่มีอยู่แล้วด้วย `bin/rails app:template`:

```bash
$ bin/rails app:template LOCATION=path/to/template.rb
```

เทมเพลตยังไม่จำเป็นต้องเก็บไว้ในเครื่องที่เก็บข้อมูลในเครือข่าย — เราสามารถระบุ URL แทนที่เส้นทาง:

```bash
$ rails new my_cool_app -m http://example.com/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

เมธอดช่วยเจริญเจเนอเรเตอร์
------------------------

Thor ให้เมธอดช่วยเจริญหลายอย่างผ่าน [`Thor::Actions`][], เช่น:

* [`copy_file`][]
* [`create_file`][]
* [`gsub_file`][]
* [`insert_into_file`][]
* [`inside`][]

นอกจากนี้ Rails ยังให้เมธอดช่วยเจริญหลายอย่างผ่าน [`Rails::Generators::Actions`][], เช่น:

* [`environment`][]
* [`gem`][]
* [`generate`][]
* [`git`][]
* [`initializer`][]
* [`lib`][]
* [`rails_command`][]
* [`rake`][]
* [`route`][]
[`Rails::Generators::Base`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html
[`Thor::Actions`]: https://www.rubydoc.info/gems/thor/Thor/Actions
[`create_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#create_file-instance_method
[`desc`]: https://www.rubydoc.info/gems/thor/Thor#desc-class_method
[`Rails::Generators::NamedBase`]: https://api.rubyonrails.org/classes/Rails/Generators/NamedBase.html
[`copy_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#copy_file-instance_method
[`source_root`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-source_root
[`class_option`]: https://www.rubydoc.info/gems/thor/Thor/Base/ClassMethods#class_option-instance_method
[`options`]: https://www.rubydoc.info/gems/thor/Thor/Base#options-instance_method
[`config.generators`]: configuring.html#configuring-generators
[`hook_for`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-hook_for
[`Rails::Generators::Actions`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html
[`environment`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-environment
[`gem`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-gem
[`generate`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-generate
[`git`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-git
[`gsub_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#gsub_file-instance_method
[`initializer`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-initializer
[`insert_into_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#insert_into_file-instance_method
[`inside`]: https://www.rubydoc.info/gems/thor/Thor/Actions#inside-instance_method
[`lib`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-lib
[`rails_command`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rails_command
[`rake`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rake
[`route`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-route
