**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: d3947b8dd1115e8f8e4279581ff626f6
เทมเพลตแอปพลิเคชัน Rails
===========================

เทมเพลตแอปพลิเคชันคือไฟล์ Ruby ที่มี DSL สำหรับเพิ่ม gems, initializers, เป็นต้นลงในโปรเจค Rails ที่คุณสร้างใหม่หรือโปรเจค Rails ที่มีอยู่แล้ว

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีใช้เทมเพลตในการสร้าง/ปรับแต่งแอปพลิเคชัน Rails
* วิธีเขียนเทมเพลตแอปพลิเคชันที่สามารถนำมาใช้ซ้ำได้โดยใช้ Rails template API

--------------------------------------------------------------------------------

การใช้งาน
-----

ในการใช้เทมเพลตคุณต้องให้ Rails generator รู้ว่าคุณต้องการใช้เทมเพลตไหนโดยใช้ตัวเลือก `-m` ซึ่งสามารถเป็นที่อยู่ของไฟล์หรือ URL

```bash
$ rails new blog -m ~/template.rb
$ rails new blog -m http://example.com/template.rb
```

คุณสามารถใช้คำสั่ง `app:template` ของ Rails เพื่อใช้เทมเพลตกับแอปพลิเคชัน Rails ที่มีอยู่แล้ว โดยต้องระบุที่อยู่ของเทมเพลตผ่านตัวแปรสภาพแวดล้อม LOCATION อีกครั้ง ซึ่งสามารถเป็นที่อยู่ของไฟล์หรือ URL

```bash
$ bin/rails app:template LOCATION=~/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

API เทมเพลต
------------

API เทมเพลตของ Rails เป็น API ที่ง่ายต่อการเข้าใจ ต่อไปนี้คือตัวอย่างของเทมเพลต Rails ที่มีลักษณะทั่วไป:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rails_command("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

ส่วนต่อไปนี้อธิบายเมธอดหลักที่ API นี้มีให้ใช้งาน:

### gem(*args)

เพิ่ม `gem` entry สำหรับ gem ที่ระบุลงใน `Gemfile` ของแอปพลิเคชันที่สร้างขึ้น

ตัวอย่างเช่น ถ้าแอปพลิเคชันของคุณขึ้นอยู่กับ gems `bj` และ `nokogiri`:

```ruby
gem "bj"
gem "nokogiri"
```

โปรดทราบว่าเมธอดนี้เพียงแค่เพิ่ม gem ลงใน `Gemfile` เท่านั้น ไม่ได้ทำการติดตั้ง gem

### gem_group(*names, &block)

ห่อหุ้ม gem entries ภายในกลุ่ม

ตัวอย่างเช่น ถ้าคุณต้องการโหลด `rspec-rails` เฉพาะในกลุ่ม `development` และ `test`:

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### add_source(source, options={}, &block)

เพิ่ม source ที่ระบุลงใน `Gemfile` ของแอปพลิเคชันที่สร้างขึ้น

ตัวอย่างเช่น ถ้าคุณต้องการใช้ source gem จาก `"http://gems.github.com"`:

```ruby
add_source "http://gems.github.com"
```

ถ้ามี block ระบุ เมธอด gem entries ใน block จะถูกห่อหุ้มด้วยกลุ่ม source

```ruby
add_source "http://gems.github.com/" do
  gem "rspec-rails"
end
```

### environment/application(data=nil, options={}, &block)

เพิ่มบรรทัดในคลาส `Application` ใน `config/application.rb`

ถ้าระบุ `options[:env]` บรรทัดจะถูกเพิ่มในไฟล์ที่เกี่ยวข้องใน `config/environments`

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
```

สามารถใช้ block แทน `data` argument ได้

### vendor/lib/file/initializer(filename, data = nil, &block)

เพิ่ม initializer ลงในไดเรกทอรี `config/initializers` ของแอปพลิเคชันที่สร้างขึ้น

เช่น ถ้าคุณชอบใช้ `Object#not_nil?` และ `Object#not_blank?`:

```ruby
initializer 'bloatlol.rb', <<-CODE
  class Object
    def not_nil?
      !nil?
    end

    def not_blank?
      !blank?
    end
  end
CODE
```

เช่นเดียวกัน `lib()` สร้างไฟล์ในไดเรกทอรี `lib/` และ `vendor()` สร้างไฟล์ในไดเรกทอรี `vendor/`

มีเมธอด `file()` ที่รับพารามิเตอร์เป็นเส้นทางสัมพันธ์จาก `Rails.root` และสร้างไดเรกทอรี/ไฟล์ที่จำเป็น:

```ruby
file 'app/components/foo.rb', <<-CODE
  class Foo
  end
CODE
```

จะสร้างไดเรกทอรี `app/components` และวาง `foo.rb` ลงในนั้น

### rakefile(filename, data = nil, &block)

สร้างไฟล์ rake ใหม่ใน `lib/tasks` พร้อมกับ tasks ที่ระบุ:

```ruby
rakefile("bootstrap.rake") do
  <<-TASK
    namespace :boot do
      task :strap do
        puts "i like boots!"
      end
    end
  TASK
end
```

ตัวอย่างข้างต้นสร้าง `lib/tasks/bootstrap.rake` พร้อมกับ task `boot:strap`

### generate(what, *args)

รัน generator ของ Rails ที่ระบุพร้อมกับอาร์กิวเมนต์ที่กำหนด

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### run(command)

รันคำสั่งอื่น ๆ คล้ายกับเครื่องหมาย backticks ตัวอย่างเช่น ถ้าคุณต้องการลบไฟล์ `README.rdoc`:

```ruby
run "rm README.rdoc"
```

### rails_command(command, options = {})

รันคำสั่งที่ระบุในแอปพลิเคชัน Rails ตัวอย่างเช่น ถ้าคุณต้องการทำการ migrate ฐานข้อมูล:
```ruby
rails_command "db:migrate"
```

คุณยังสามารถรันคำสั่งด้วย Rails environment ที่แตกต่างกันได้:

```ruby
rails_command "db:migrate", env: 'production'
```

คุณยังสามารถรันคำสั่งเป็น super-user ได้:

```ruby
rails_command "log:clear", sudo: true
```

คุณยังสามารถรันคำสั่งที่ควรยุติการสร้างแอปพลิเคชันหากเกิดข้อผิดพลาด:

```ruby
rails_command "db:migrate", abort_on_failure: true
```

### route(routing_code)

เพิ่มรายการเส้นทางในไฟล์ `config/routes.rb` ได้ด้วยคำสั่งนี้ ในขั้นตอนด้านบน เราสร้าง scaffold ของ person และลบ `README.rdoc` ออกแล้ว ตอนนี้ เพื่อที่จะทำให้ `PeopleController#index` เป็นหน้าเริ่มต้นของแอปพลิเคชัน:

```ruby
route "root to: 'person#index'"
```

### inside(dir)

ช่วยให้คุณรันคำสั่งจากไดเรกทอรีที่กำหนด ตัวอย่างเช่น หากคุณมีการสร้าง symlink จาก edge rails ที่คุณต้องการใช้ในแอปใหม่ของคุณ คุณสามารถทำดังนี้:

```ruby
inside('vendor') do
  run "ln -s ~/commit-rails/rails rails"
end
```

### ask(question)

`ask()` ช่วยให้คุณได้รับคำตอบจากผู้ใช้และนำมาใช้ในเทมเพลตของคุณ สมมุติว่าคุณต้องการให้ผู้ใช้ตั้งชื่อ library ใหม่ที่คุณกำลังเพิ่ม:

```ruby
lib_name = ask("What do you want to call the shiny library ?")
lib_name << ".rb" unless lib_name.index(".rb")

lib lib_name, <<-CODE
  class Shiny
  end
CODE
```

### yes?(question) หรือ no?(question)

เมธอดเหล่านี้ช่วยให้คุณสามารถถามคำถามจากเทมเพลตและตัดสินใจการทำงานตามคำตอบของผู้ใช้ได้ สมมุติว่าคุณต้องการให้ผู้ใช้เรียกใช้การทำฐานข้อมูล:

```ruby
rails_command("db:migrate") if yes?("Run database migrations?")
# no?(question) ทำงานที่ตรงกันข้าม
```

### git(:command)

เทมเพลต Rails ช่วยให้คุณรันคำสั่ง git ใดๆ:

```ruby
git :init
git add: "."
git commit: "-a -m 'Initial commit'"
```

### after_bundle(&block)

ลงทะเบียน callback เพื่อทำงานหลังจากที่ gems ถูก bundle และ binstubs ถูกสร้าง มีประโยชน์ในการเพิ่มไฟล์ที่สร้างขึ้นในการควบคุมเวอร์ชัน:

```ruby
after_bundle do
  git :init
  git add: '.'
  git commit: "-a -m 'Initial commit'"
end
```

Callback จะถูกเรียกใช้งานแม้ว่า `--skip-bundle` จะถูกส่งผ่านไปแล้ว

การใช้งานขั้นสูง
--------------

แม่แบบแอปพลิเคชันจะถูกประเมินในบริบทของตัวอย่าง `Rails::Generators::AppGenerator` ซึ่งใช้การดำเนินการ [`apply`](https://www.rubydoc.info/gems/thor/Thor/Actions#apply-instance_method) ที่ Thor จัดหา

นี่หมายความว่าคุณสามารถขยายและเปลี่ยนแปลงตัวอย่างเพื่อให้ตรงกับความต้องการของคุณ

ตัวอย่างเช่น โดยการเขียนทับเมธอด `source_paths` เพื่อระบุตำแหน่งของแม่แบบของคุณ ตอนนี้เมธอดเช่น `copy_file` จะยอมรับเส้นทางสัมพันธ์กับตำแหน่งแม่แบบของคุณ

```ruby
def source_paths
  [__dir__]
end
```

