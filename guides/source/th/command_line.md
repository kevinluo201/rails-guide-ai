**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 7dbd0564d604e07d111b2a827bef559f
คำสั่ง Rails Command Line
======================

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีสร้างแอปพลิเคชัน Rails
* วิธีสร้างโมเดล, คอนโทรลเลอร์, การเปลี่ยนแปลงฐานข้อมูลและการทดสอบหน่วย
* วิธีเริ่มเซิร์ฟเวอร์ในโหมดการพัฒนา
* วิธีทดลองใช้วัตถุผ่านเชลล์แบบอินเตอร์แอคทีฟ

--------------------------------------------------------------------------------

หมายเหตุ: คู่มือนี้ถือว่าคุณมีความรู้พื้นฐานเกี่ยวกับ Rails จากการอ่านคู่มือ [เริ่มต้นใช้งาน Rails](getting_started.html)

การสร้างแอปพลิเคชัน Rails
--------------------

ก่อนอื่นเรามาสร้างแอปพลิเคชัน Rails ง่ายๆ โดยใช้คำสั่ง `rails new`

เราจะใช้แอปพลิเคชันนี้เพื่อทดลองและค้นพบคำสั่งทั้งหมดที่อธิบายในคู่มือนี้

ข้อมูล: หากคุณยังไม่มี gem rails คุณสามารถติดตั้งได้โดยพิมพ์ `gem install rails`

### `rails new`

อาร์กิวเมนต์แรกที่เราจะส่งให้กับคำสั่ง `rails new` คือชื่อแอปพลิเคชัน

```bash
$ rails new my_app
     create
     create  README.md
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

Rails จะตั้งค่าสิ่งที่ดูเหมือนจะมีจำนวนมากสำหรับคำสั่งที่เล็กน้อยเช่นนี้! เราได้โครงสร้างไดเรกทอรี Rails ทั้งหมดตอนนี้พร้อมโค้ดที่เราต้องการในการเรียกใช้แอปพลิเคชันง่ายๆ

หากคุณต้องการข้ามการสร้างไฟล์บางส่วนหรือข้ามไลบรารีบางส่วนคุณสามารถเพิ่มอาร์กิวเมนต์ต่อไปนี้ในคำสั่ง `rails new` ของคุณ:

| อาร์กิวเมนต์                | คำอธิบาย                                                 |
| ----------------------- | ----------------------------------------------------------- |
| `--skip-git`            | ข้าม git init, .gitignore และ .gitattributes               |
| `--skip-docker`         | ข้าม Dockerfile, .dockerignore และ bin/docker-entrypoint    |
| `--skip-keeps`          | ข้ามไฟล์ควบคุมแหล่งที่เก็บข้อมูล                           |
| `--skip-action-mailer`  | ข้ามไฟล์ Action Mailer                                    |
| `--skip-action-mailbox` | ข้าม Action Mailbox gem                                     |
| `--skip-action-text`    | ข้าม Action Text gem                                        |
| `--skip-active-record`  | ข้ามไฟล์ Active Record                                    |
| `--skip-active-job`     | ข้าม Active Job                                             |
| `--skip-active-storage` | ข้ามไฟล์ Active Storage                                   |
| `--skip-action-cable`   | ข้ามไฟล์ Action Cable                                     |
| `--skip-asset-pipeline` | ข้าม Asset Pipeline                                         |
| `--skip-javascript`     | ข้ามไฟล์ JavaScript                                       |
| `--skip-hotwire`        | ข้ามการผสาน Hotwire                                    |
| `--skip-jbuilder`       | ข้าม jbuilder gem                                           |
| `--skip-test`           | ข้ามไฟล์ทดสอบ                                             |
| `--skip-system-test`    | ข้ามไฟล์ทดสอบระบบ                                      |
| `--skip-bootsnap`       | ข้าม bootsnap gem                                           |
นี่เป็นเพียงบางตัวเลือกที่ `rails new` ยอมรับ สำหรับรายการเต็มของตัวเลือก พิมพ์ `rails new --help`

### กำหนดค่าฐานข้อมูลที่แตกต่างกันล่วงหน้า

เมื่อสร้างแอปพลิเคชัน Rails ใหม่ คุณสามารถระบุว่าแอปพลิเคชันของคุณจะใช้ฐานข้อมูลชนิดใด สิ่งนี้จะช่วยประหยัดเวลาสักหน่อยและแน่นอนจะประหยัดการพิมพ์

มาดูว่าตัวเลือก `--database=postgresql` จะทำอะไรให้เรา:

```bash
$ rails new petstore --database=postgresql
      create
      create  app/controllers
      create  app/helpers
...
```

มาดูว่ามันใส่อะไรลงใน `config/database.yml` ของเรา:

```yaml
# PostgreSQL. Versions 9.3 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On macOS with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On Windows:
#   gem install pg
#       Choose the win32 build.
#       Install PostgreSQL and put its /bin directory on your path.
#
# Configure Using Gemfile
# gem "pg"
#
default: &default
  adapter: postgresql
  encoding: unicode

  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: petstore_development
...
```

มันสร้างการกำหนดค่าฐานข้อมูลที่สอดคล้องกับการเลือก PostgreSQL ของเรา

พื้นฐานของคำสั่งบรรทัดคำสั่ง
-------------------

มีคำสั่งบางอย่างที่สำคัญมากสำหรับการใช้งานประจำวันของคุณใน Rails ตามลำดับของความถี่ที่คุณจะน่าจะใช้:

* `bin/rails console`
* `bin/rails server`
* `bin/rails test`
* `bin/rails generate`
* `bin/rails db:migrate`
* `bin/rails db:create`
* `bin/rails routes`
* `bin/rails dbconsole`
* `rails new app_name`

คุณสามารถรับรายการคำสั่ง rails ที่มีอยู่ ซึ่งจะขึ้นอยู่กับไดเรกทอรีปัจจุบันของคุณ โดยพิมพ์ `rails --help` แต่ละคำสั่งมีคำอธิบายและควรช่วยคุณค้นหาสิ่งที่คุณต้องการ

```bash
$ rails --help
Usage:
  bin/rails COMMAND [options]

คุณต้องระบุคำสั่ง คำสั่งที่ใช้บ่อยที่สุดคือ:

  generate     สร้างโค้ดใหม่ (ตัวย่อสั้น: "g")
  console      เริ่มคอนโซล Rails (ตัวย่อสั้น: "c")
  server       เริ่มเซิร์ฟเวอร์ Rails (ตัวย่อสั้น: "s")
  ...

คุณสามารถรับรายการคำสั่ง rails ที่มีอยู่ ซึ่งจะขึ้นอยู่กับไดเรกทอรีปัจจุบันของคุณ โดยพิมพ์ `rails --help` แต่ละคำสั่งมีคำอธิบายและควรช่วยคุณค้นหาสิ่งที่คุณต้องการ

```bash
$ rails --help
Usage:
  bin/rails COMMAND [options]

You must specify a command. The most common commands are:

  generate     Generate new code (short-cut alias: "g")
  console      Start the Rails console (short-cut alias: "c")
  server       Start the Rails server (short-cut alias: "s")
  ...

All commands can be run with -h (or --help) for more information.

In addition to those commands, there are:
about                               List versions of all Rails ...
assets:clean[keep]                  Remove old compiled assets
assets:clobber                      Remove compiled assets
assets:environment                  Load asset compile environment
assets:precompile                   Compile all the assets ...
...
db:fixtures:load                    Load fixtures into the ...
db:migrate                          Migrate the database ...
db:migrate:status                   Display status of migrations
db:rollback                         Roll the schema back to ...
db:schema:cache:clear               Clears a db/schema_cache.yml file
db:schema:cache:dump                Create a db/schema_cache.yml file
db:schema:dump                      Create a database schema file (either db/schema.rb or db/structure.sql ...
db:schema:load                      Load a database schema file (either db/schema.rb or db/structure.sql ...
db:seed                             Load the seed data ...
db:version                          Retrieve the current schema ...
...
restart                             Restart app by touching ...
tmp:create                          Create tmp directories ...
```
### `bin/rails server`

คำสั่ง `bin/rails server` จะเปิดเซิร์ฟเวอร์เว็บชื่อ Puma ซึ่งมาพร้อมกับ Rails คุณจะใช้คำสั่งนี้เมื่อต้องการเข้าถึงแอปพลิเคชันของคุณผ่านเบราว์เซอร์

โดยไม่ต้องทำอะไรเพิ่มเติม `bin/rails server` จะเรียกใช้แอป Rails ใหม่ของเรา:

```bash
$ cd my_app
$ bin/rails server
=> Booting Puma
=> Rails 7.0.0 application starting in development
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Version 3.12.1 (ruby 2.5.7-p206), codename: Llamas in Pajamas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
```

ด้วยเพียงสามคำสั่งเราก็สร้างเซิร์ฟเวอร์ Rails ที่ฟังก์ชันในพอร์ต 3000 ได้แล้ว ไปที่เบราว์เซอร์ของคุณและเปิด [http://localhost:3000](http://localhost:3000) คุณจะเห็นแอป Rails พื้นฐานที่ทำงานอยู่

INFO: คุณยังสามารถใช้คำสั่งย่อ "s" เพื่อเริ่มเซิร์ฟเวอร์: `bin/rails s`.

เซิร์ฟเวอร์สามารถทำงานบนพอร์ตที่แตกต่างกันได้โดยใช้ตัวเลือก `-p` สภาพแวดล้อมการพัฒนาเริ่มต้นสามารถเปลี่ยนได้โดยใช้ `-e`.

```bash
$ bin/rails server -e production -p 4000
```

ตัวเลือก `-b` จะผูก Rails กับ IP ที่ระบุ โดยค่าเริ่มต้นคือ localhost คุณสามารถเรียกใช้เซิร์ฟเวอร์ในรูปแบบเดมอนได้โดยใส่ตัวเลือก `-d`.

### `bin/rails generate`

คำสั่ง `bin/rails generate` ใช้เทมเพลตในการสร้างอะไรก็ตาม การเรียกใช้ `bin/rails generate` โดยตัวเองจะแสดงรายการของตัวสร้างที่ใช้ได้:

INFO: คุณยังสามารถใช้คำสั่งย่อ "g" เพื่อเรียกใช้คำสั่งตัวสร้าง: `bin/rails g`.

```bash
$ bin/rails generate
Usage:
  bin/rails generate GENERATOR [args] [options]

...
...

Please choose a generator below.

Rails:
  assets
  channel
  controller
  generator
  ...
  ...
```

หมายเหตุ: คุณสามารถติดตั้งตัวสร้างเพิ่มเติมผ่าน generator gems, ส่วนของปลั๊กอินที่คุณติดตั้งแน่นอน และคุณยังสามารถสร้างตัวสร้างของคุณเองได้! 

การใช้ตัวสร้างจะช่วยประหยัดเวลาให้คุณโดยการเขียน **โค้ดพื้นฐาน** โค้ดที่จำเป็นสำหรับแอปพลิเคชันให้ทำงาน
ให้เราสร้างคอนโทรลเลอร์ของเราเองด้วยเครื่องมือสร้างคอนโทรลเลอร์ แต่คำสั่งที่เราควรใช้คืออะไร? เรามาถามเครื่องมือสร้างคอนโทรลเลอร์:

INFO: โปรแกรมย่อยของ Rails ทั้งหมดมีข้อความคำแนะนำ อย่างเช่นเครื่องมือ *nix ส่วนใหญ่ คุณสามารถลองเพิ่ม `--help` หรือ `-h` ที่ท้าย ตัวอย่างเช่น `bin/rails server --help`.

```bash
$ bin/rails generate controller
Usage:
  bin/rails generate controller NAME [action action] [options]

...
...

Description:
    ...

    เพื่อสร้างคอนโทรลเลอร์ภายในโมดูล ให้ระบุชื่อคอนโทรลเลอร์เป็นเส้นทางเช่น 'parent_module/controller_name'.

    ...

Example:
    `bin/rails generate controller CreditCards open debit credit close`

    สร้างคอนโทรลเลอร์บัตรเครดิตที่มี URL เช่น /credit_cards/debit.
        Controller: app/controllers/credit_cards_controller.rb
        Test:       test/controllers/credit_cards_controller_test.rb
        Views:      app/views/credit_cards/debit.html.erb [...]
        Helper:     app/helpers/credit_cards_helper.rb
```

เครื่องมือสร้างคอนโทรลเลอร์คาดหวังพารามิเตอร์ในรูปแบบ `generate controller ชื่อคอนโทรลเลอร์ การกระทำ1 การกระทำ2`. เรามาสร้างคอนโทรลเลอร์ `Greetings` พร้อมการกระทำ **hello** ซึ่งจะพูดคำที่ดีต่อเราเอง

```bash
$ bin/rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get 'greetings/hello'
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke    test_unit
```

สิ่งที่สร้างขึ้นทั้งหมดคือ ตรวจสอบให้แน่ใจว่ามีไดเรกทอรีหลายๆ อันในแอปพลิเคชันของเรา และสร้างไฟล์คอนโทรลเลอร์ ไฟล์วิว ไฟล์ทดสอบฟังก์ชัน ไฟล์ช่วยเหลือสำหรับวิว ไฟล์ JavaScript และไฟล์สไตล์ชีต

ตรวจสอบคอนโทรลเลอร์และแก้ไขเล็กน้อย (ใน `app/controllers/greetings_controller.rb`):

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "สวัสดีครับ คุณเป็นอย่างไรบ้างในวันนี้?"
  end
end
```

แล้วมาดูวิว เพื่อแสดงข้อความของเรา (ใน `app/views/greetings/hello.html.erb`):

```erb
<h1>คำทักทายสำหรับคุณ!</h1>
<p><%= @message %></p>
```

เปิดเซิร์ฟเวอร์ของคุณโดยใช้ `bin/rails server`.

```bash
$ bin/rails server
=> Booting Puma...
```

URL จะเป็น [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello).

INFO: ในแอปพลิเคชัน Rails ธรรมดา ที่มีเพียงแอปพลิเคชันเดียว  URL ของคุณจะมีรูปแบบเป็น http://(โฮสต์)/(คอนโทรลเลอร์)/(การกระทำ) และ URL เช่น http://(โฮสต์)/(คอนโทรลเลอร์) จะเข้าถึงการกระทำ **index** ของคอนโทรลเลอร์นั้น
Rails มาพร้อมกับเครื่องมือสร้างโมเดลข้อมูลด้วย

```bash
$ bin/rails generate model
การใช้งาน:
  bin/rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

...

ตัวเลือก ActiveRecord:
      [--migration], [--no-migration]        # ระบุเมื่อต้องการสร้าง migration
                                             # ค่าเริ่มต้น: true

...

คำอธิบาย:
    สร้างโมเดลใหม่ ระบุชื่อโมเดล ทั้งแบบ CamelCased หรือ under_scored และรายการคู่ค่าแอตทริบิวต์เพิ่มเติมเป็นอาร์กิวเมนต์

...
```

หมายเหตุ: สำหรับรายการประเภทฟิลด์ที่ใช้ในพารามิเตอร์ `type` ดูได้ที่ [เอกสาร API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column) สำหรับเมธอด add_column ในโมดูล SchemaStatements พารามิเตอร์ `index` จะสร้างดัชนีที่เกี่ยวข้องสำหรับคอลัมน์

แต่แทนที่จะสร้างโมเดลโดยตรง (ซึ่งเราจะทำในภายหลัง) เราจะติดตั้ง scaffold แทน สคริปต์ **scaffold** ใน Rails เป็นชุดเต็มที่ประกอบด้วยโมเดล การเปลี่ยนแปลงฐานข้อมูลสำหรับโมเดลนั้น คอนโทรลเลอร์เพื่อจัดการกับข้อมูล และมุมมองเพื่อดูและจัดการข้อมูล และชุดทดสอบสำหรับทุกอย่างที่กล่าวมา

เราจะตั้งค่าทรัพยากรง่าย ๆ ที่เรียกว่า "HighScore" ซึ่งจะเก็บคะแนนสูงสุดของเราในเกมวิดีโอที่เราเล่น

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20190416145729_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    create      test/system/high_scores_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke      test_unit
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    create      app/views/high_scores/_high_score.json.jbuilder
```

เครื่องมือสร้างโมเดลสร้างโมเดล มุมมอง คอนโทรลเลอร์ เส้นทางทรัพยากร และการเปลี่ยนแปลงฐานข้อมูล (ซึ่งสร้างตาราง `high_scores`) สำหรับ HighScore และเพิ่มการทดสอบสำหรับสิ่งเหล่านั้น

การเปลี่ยนแปลงฐานข้อมูลต้องการให้เรา **migrate** หรือเรียกใช้โค้ด Ruby (ไฟล์ `20190416145729_create_high_scores.rb` จากผลลัพธ์ด้านบน) เพื่อปรับเปลี่ยนโครงสร้างของฐานข้อมูลของเรา ฐานข้อมูลใด? ฐานข้อมูล SQLite3 ที่ Rails จะสร้างให้เราเมื่อเราเรียกใช้คำสั่ง `bin/rails db:migrate` เราจะพูดถึงคำสั่งนี้มากขึ้นในส่วนถัดไป
```bash
$ bin/rails db:migrate
==  CreateHighScores: กำลังทำการโยกย้าย ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: โยกย้ายเสร็จสิ้น (0.0019s) ======================================
```

INFO: เรามาพูดถึงการทดสอบหน่วยกันบ้าง การทดสอบหน่วยคือการเขียนโค้ดที่ทดสอบและตรวจสอบโค้ดอื่น ๆ การทดสอบหน่วยเป็นเพื่อนของคุณ คุณจะมีคุณภาพชีวิตที่ดีขึ้นอย่างมากเมื่อคุณทดสอบหน่วยโค้ดของคุณ จริงจัง โปรดเยี่ยมชม [คู่มือการทดสอบ](testing.html) เพื่อดูข้อมูลเพิ่มเติมเกี่ยวกับการทดสอบหน่วย

มาดูอินเตอร์เฟสที่ Rails สร้างขึ้นให้เรา

```bash
$ bin/rails server
```

ไปที่เบราว์เซอร์ของคุณและเปิด [http://localhost:3000/high_scores](http://localhost:3000/high_scores) เราสามารถสร้างคะแนนสูงใหม่ได้แล้ว (55,160 บน Space Invaders!)

### `bin/rails console`

คำสั่ง `console` ช่วยให้คุณสามารถแสดงผลแอปพลิเคชัน Rails ของคุณจาก command line ได้ ในด้านล่าง `bin/rails console` ใช้ IRB ดังนั้นหากคุณเคยใช้มันแล้วคุณจะรู้สึกเหมือนอยู่บ้าน สิ่งนี้เป็นประโยชน์สำหรับการทดลองไอเดียรวดเร็วด้วยโค้ดและการเปลี่ยนแปลงข้อมูลที่อยู่ฝั่งเซิร์ฟเวอร์โดยไม่ต้องสัมผัสเว็บไซต์

INFO: คุณยังสามารถใช้ชื่อย่อ "c" เพื่อเรียกใช้คอนโซล: `bin/rails c`.

คุณสามารถระบุสภาพแวดล้อมที่คำสั่ง `console` ควรทำงานในได้

```bash
$ bin/rails console -e staging
```

หากคุณต้องการทดสอบโค้ดโดยไม่เปลี่ยนแปลงข้อมูลใด ๆ คุณสามารถทำได้โดยเรียกใช้ `bin/rails console --sandbox`.

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 7.1.0)
การปรับเปลี่ยนใด ๆ ที่คุณทำจะถูกยกเลิกเมื่อออก
irb(main):001:0>
```

#### อ็อบเจ็กต์ `app` และ `helper`

ภายใน `bin/rails console` คุณสามารถเข้าถึงอ็อบเจ็กต์ `app` และ `helper` ได้

ด้วยเมธอด `app` คุณสามารถเข้าถึงช่วยเหลือของเส้นทางที่มีชื่อ และทำการร้องขอ

```irb
irb> app.root_path
=> "/"

irb> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

ด้วยเมธอด `helper` คุณสามารถเข้าถึง Rails และ helper ของแอปพลิเคชันของคุณได้

```irb
irb> helper.time_ago_in_words 30.days.ago
=> "ประมาณ 1 เดือน"

irb> helper.my_custom_helper
=> "helper ที่กำหนดเอง"
```

### `bin/rails dbconsole`

`bin/rails dbconsole` จะตรวจสอบว่าคุณใช้ฐานข้อมูลชนิดใดและเปิดให้คุณเข้าสู่อินเตอร์เฟซคอมมานด์ไลน์ที่คุณใช้กับฐานข้อมูลนั้น (และกำหนดพารามิเตอร์สำหรับคอมมานด์ไลน์ด้วยด้วย) รองรับ MySQL (รวมถึง MariaDB) PostgreSQL และ SQLite3

INFO: คุณยังสามารถใช้ชื่อย่อ "db" เพื่อเรียกใช้ dbconsole: `bin/rails db`.

หากคุณใช้ฐานข้อมูลหลายรายการ `bin/rails dbconsole` จะเชื่อมต่อกับฐานข้อมูลหลักโดยค่าเริ่มต้น คุณสามารถระบุฐานข้อมูลที่ต้องการเชื่อมต่อโดยใช้ `--database` หรือ `--db`:

```bash
$ bin/rails dbconsole --database=animals
```

### `bin/rails runner`

`runner` ใช้ในการเรียกใช้โค้ด Ruby ในรูปแบบที่ไม่ต้องมีการตอบสนองจากผู้ใช้ ตัวอย่างเช่น:

```bash
$ bin/rails runner "Model.long_running_method"
```

INFO: คุณยังสามารถใช้ชื่อย่อ "r" เพื่อเรียกใช้ runner: `bin/rails r`.

คุณสามารถระบุสภาพแวดล้อมที่ `runner` ควรทำงานในโดยใช้สวิตช์ `-e`.

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```

คุณยังสามารถเรียกใช้โค้ด Ruby ที่เขียนไว้ในไฟล์ด้วย runner

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `bin/rails destroy`

คิดว่า `destroy` เป็นการย้อนกลับของ `generate` มันจะหาว่า generate ทำอะไรและยกเลิกมัน

INFO: คุณยังสามารถใช้ชื่อย่อ "d" เพื่อเรียกใช้คำสั่ง destroy: `bin/rails d`.

```bash
$ bin/rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```

```bash
$ bin/rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

### `bin/rails about`

`bin/rails about` ให้ข้อมูลเกี่ยวกับเลขเวอร์ชันสำหรับ Ruby, RubyGems, Rails, ส่วนประกอบย่อยของ Rails, โฟลเดอร์ของแอปพลิเคชันของคุณ, ชื่อสภาพแวดล้อม Rails ปัจจุบัน, อะแดปเตอร์ฐานข้อมูลของแอปพลิเคชันของคุณ และเวอร์ชันสกีมา มันเป็นประโยชน์เมื่อคุณต้องการขอความช่วยเหลือ ตรวจสอบว่าแพทช์ความปลอดภัยอาจมีผลต่อคุณ หรือเมื่อคุณต้องการสถิติบางอย่างสำหรับการติดตั้ง Rails ที่มีอยู่แล้ว
```bash
$ bin/rails about
เกี่ยวกับสภาพแวดล้อมของแอปพลิเคชันของคุณ
เวอร์ชัน Rails             7.0.0
เวอร์ชัน Ruby              2.7.0 (x86_64-linux)
เวอร์ชัน RubyGems          2.7.3
เวอร์ชัน Rack              2.0.4
เวลาการเรียกใช้งาน JavaScript        Node.js (V8)
Middleware:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Application root          /home/foobar/my_app
สภาพแวดล้อม               การพัฒนา
Database adapter          sqlite3
เวอร์ชัน Database schema   20180205173523
```

### `bin/rails assets:`

คุณสามารถคอมไพล์แอสเซ็ตใน `app/assets` โดยใช้ `bin/rails assets:precompile` และลบแอสเซ็ตที่คอมไพล์เก่าออกโดยใช้ `bin/rails assets:clean` คำสั่ง `assets:clean` ช่วยให้สามารถทำการเปลี่ยนแปลงแอสเซ็ตในระหว่างการเปิดใช้งานได้ โดยที่ยังมีลิงก์ไปยังแอสเซ็ตเก่าในขณะที่แอสเซ็ตใหม่กำลังถูกสร้างขึ้น

หากคุณต้องการล้าง `public/assets` ให้สมบูรณ์ คุณสามารถใช้ `bin/rails assets:clobber` ได้

### `bin/rails db:`

คำสั่งที่ใช้บ่อยที่สุดในเนมสเปซ `db:` ของ Rails คือ `migrate` และ `create` และคุณจะได้ประโยชน์จากการลองใช้คำสั่งการเปลี่ยนแปลงฐานข้อมูลทั้งหมด (`up`, `down`, `redo`, `reset`) `bin/rails db:version` มีประโยชน์ในกรณีที่ต้องการแก้ปัญหา โดยบอกเวอร์ชันปัจจุบันของฐานข้อมูล

ข้อมูลเพิ่มเติมเกี่ยวกับการเปลี่ยนแปลงฐานข้อมูลสามารถหาได้ในคู่มือ [การเปลี่ยนแปลง](active_record_migrations.html)

### `bin/rails notes`

`bin/rails notes` ค้นหาความคิดเห็นที่เริ่มต้นด้วยคำสำคัญที่ระบุ เราสามารถอ้างอิงไปยัง `bin/rails notes --help` เพื่อดูข้อมูลเกี่ยวกับวิธีการใช้งาน

โดยค่าเริ่มต้น มันจะค้นหาในไดเรกทอรี `app`, `config`, `db`, `lib`, และ `test` สำหรับคำอธิบายที่เริ่มต้นด้วย FIXME, OPTIMIZE, และ TODO ในไฟล์ที่มีนามสกุล `.builder`, `.rb`, `.rake`, `.yml`, `.yaml`, `.ruby`, `.css`, `.js`, และ `.erb`

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

#### หมายเหตุ

คุณสามารถส่งค่าอนุมานเฉพาะโดยใช้อาร์กิวเมนต์ `--annotations` โดยค่าเริ่มต้น มันจะค้นหา FIXME, OPTIMIZE, และ TODO โปรดทราบว่าการอนุมานเป็นตัวพิมพ์ใหญ่เล็กได้
```bash
$ bin/rails notes --annotations FIXME RELEASE
app/controllers/admin/users_controller.rb:
  * [101] [RELEASE] เราต้องดูส่วนนี้ก่อนการเปิดตัวครั้งถัดไป
  * [132] [FIXME] มีความสำคัญสูงสำหรับการติดตั้งครั้งถัดไป

lib/school.rb:
  * [ 17] [FIXME]
```

#### แท็ก

คุณสามารถเพิ่มแท็กเริ่มต้นเพิ่มเติมในการค้นหาโดยใช้ `config.annotations.register_tags` โดยรับรายการแท็ก

```ruby
config.annotations.register_tags("DEPRECATEME", "TESTME")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] ทำการทดสอบ A/B บนสิ่งนี้
  * [ 42] [TESTME] สิ่งนี้ต้องการการทดสอบฟังก์ชันเพิ่มเติม
  * [132] [DEPRECATEME] ตรวจสอบว่าเมธอดนี้ถูกยกเลิกในการเปิดตัวครั้งถัดไป
```

#### ไดเรกทอรี

คุณสามารถเพิ่มไดเรกทอรีเริ่มต้นเพิ่มเติมในการค้นหาโดยใช้ `config.annotations.register_directories` โดยรับรายการชื่อไดเรกทอรี

```ruby
config.annotations.register_directories("spec", "vendor")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] วิธีการอื่น ๆ ในการทำสิ่งนี้?
  * [132] [FIXME] มีความสำคัญสูงสำหรับการติดตั้งครั้งถัดไป

lib/school.rb:
  * [ 13] [OPTIMIZE] ปรับโค้ดนี้ให้เร็วขึ้น
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] ตรวจสอบผู้ใช้ที่มีการสมัครสมาชิกทำงาน

vendor/tools.rb:
  * [ 56] [TODO] กำจัดความขึ้นอยู่กับความขึ้นอยู่กับสิ่งนี้
```

#### ส่วนขยาย

คุณสามารถเพิ่มส่วนขยายไฟล์เริ่มต้นเพิ่มเติมในการค้นหาโดยใช้ `config.annotations.register_extensions` โดยรับรายการส่วนขยายไฟล์พร้อมกับ regex ที่เกี่ยวข้องในการจับคู่

```ruby
config.annotations.register_extensions("scss", "sass") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] วิธีการอื่น ๆ ในการทำสิ่งนี้?
  * [132] [FIXME] มีความสำคัญสูงสำหรับการติดตั้งครั้งถัดไป

app/assets/stylesheets/application.css.sass:
  * [ 34] [TODO] ใช้องค์ประกอบเทียมสำหรับคลาสนี้

app/assets/stylesheets/application.css.scss:
  * [  1] [TODO] แยกเป็นคอมโพเนนต์หลายอัน

lib/school.rb:
  * [ 13] [OPTIMIZE] ปรับโค้ดนี้ให้เร็วขึ้น
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] ตรวจสอบผู้ใช้ที่มีการสมัครสมาชิกทำงาน

vendor/tools.rb:
  * [ 56] [TODO] กำจัดความขึ้นอยู่กับความขึ้นอยู่กับสิ่งนี้
```

### `bin/rails routes`
```
คำสั่ง `bin/rails routes` จะแสดงรายการเส้นทางที่คุณกำหนดไว้ทั้งหมด ซึ่งมีประโยชน์ในการติดตามปัญหาในการเส้นทางในแอปของคุณหรือให้คุณมีภาพรวมที่ดีเกี่ยวกับ URL ในแอปที่คุณกำลังพยายามทำความรู้จัก

### `bin/rails test`

ข้อมูล: คำอธิบายที่ดีของการทดสอบหน่วยใน Rails มีอยู่ใน [A Guide to Testing Rails Applications](testing.html)

Rails มาพร้อมกับเฟรมเวิร์กการทดสอบที่เรียกว่า minitest Rails เสียใจเป็นอย่างยิ่งกับการใช้ทดสอบ คำสั่งที่มีให้ในเนมสเปซ `test:` จะช่วยในการเรียกใช้การทดสอบต่างๆ ที่คุณคาดหวังว่าคุณจะเขียน

### `bin/rails tmp:`

ไดเรกทอรี `Rails.root/tmp` เหมือนกับไดเรกทอรี /tmp ในระบบปฏิบัติการ *nix เป็นที่เก็บไฟล์ชั่วคราวเช่นไฟล์รหัสประจำตัวกระบวนการและการกระทำที่ถูกแคช

คำสั่งที่มีเนมสเปซ `tmp:` จะช่วยในการล้างแคชและสร้างไดเรกทอรี `Rails.root/tmp`:

* `bin/rails tmp:cache:clear` ล้าง `tmp/cache`
* `bin/rails tmp:sockets:clear` ล้าง `tmp/sockets`
* `bin/rails tmp:screenshots:clear` ล้าง `tmp/screenshots`
* `bin/rails tmp:clear` ล้างไฟล์แคชทั้งหมด ไฟล์ sockets และไฟล์สกรีนช็อต
* `bin/rails tmp:create` สร้างไดเรกทอรี tmp สำหรับแคช sockets และ pids

### อื่นๆ

* `bin/rails initializers` พิมพ์รายการ initializers ที่กำหนดไว้ทั้งหมดตามลำดับที่ Rails เรียกใช้
* `bin/rails middleware` แสดงรายการ Rack middleware stack ที่เปิดใช้สำหรับแอปของคุณ
* `bin/rails stats` เหมาะสำหรับดูสถิติเกี่ยวกับโค้ดของคุณ เช่น KLOCs (พันบรรทัดของโค้ด) และอัตราส่วนของโค้ดกับการทดสอบ
* `bin/rails secret` จะให้คุณได้รับคีย์เป็นจำลองสุ่มเพื่อใช้สำหรับคีย์เซสชันของคุณ
* `bin/rails time:zones:all` แสดงรายการเขตเวลาที่ Rails รู้จักทั้งหมด

### งาน Rake ที่กำหนดเอง

งาน Rake ที่กำหนดเองมีนามสกุล `.rake` และถูกวางไว้ใน `Rails.root/lib/tasks` คุณสามารถสร้างงาน Rake ที่กำหนดเองเหล่านี้ได้ด้วยคำสั่ง `bin/rails generate task`

```ruby
desc "I am short, but comprehensive description for my cool task"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # All your magic here
  # Any valid Ruby code is allowed
end
```
เพื่อส่งอาร์กิวเมนต์ไปยังเทสท์เรา:

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

คุณสามารถจัดกลุ่มงานได้โดยการวางไว้ในเนมสเปซ:

```ruby
namespace :db do
  desc "งานนี้ไม่ทำอะไร"
  task :nothing do
    # จริงๆแล้วไม่ทำอะไร
  end
end
```

การเรียกใช้งานงานจะมีลักษณะดังนี้:

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # ต้องใส่เครื่องหมายคำพูดครอบครัวสตริงอาร์กิวเมนต์ทั้งหมด
$ bin/rails "task_name[value 1,value2,value3]" # แยกอาร์กิวเมนต์หลายๆตัวด้วยเครื่องหมายจุลภาค
$ bin/rails db:nothing
```

หากคุณต้องการที่จะปฏิบัติต่อกับโมเดลแอปพลิเคชันของคุณ ดำเนินการค้นหาฐานข้อมูล และอื่นๆ งานของคุณควรขึ้นอยู่กับงาน `environment` ซึ่งจะโหลดโค้ดแอปพลิเคชันของคุณ

```ruby
task task_that_requires_app_code: [:environment] do
  User.create!
end
```
