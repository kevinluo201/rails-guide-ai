**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2aedcd7fcf6f0b83538e8a8220d38afd
เริ่มต้นใช้งาน Engines
============================

ในคู่มือนี้คุณจะได้เรียนรู้เกี่ยวกับ engines และวิธีการใช้งานเพื่อให้สามารถให้ฟังก์ชันเพิ่มเติมให้กับแอปพลิเคชันหลักผ่านอินเตอร์เฟซที่สะอาดและง่ายต่อการใช้งาน

หลังจากอ่านคู่มือนี้คุณจะรู้:

* สิ่งที่ทำให้เกิด engine
* วิธีการสร้าง engine
* วิธีการสร้างคุณสมบัติสำหรับ engine
* วิธีการเชื่อมต่อ engine เข้ากับแอปพลิเคชัน
* วิธีการแทนที่ฟังก์ชันของ engine ในแอปพลิเคชัน
* วิธีการหลีกเลี่ยงการโหลดเฟรมเวิร์คของ Rails ด้วย Load และ Configuration Hooks

--------------------------------------------------------------------------------

Engine คืออะไร?
-----------------

Engine สามารถถือเป็นแอปพลิเคชันขนาดเล็กที่ให้ฟังก์ชันให้กับแอปพลิเคชันหลักได้ Rails แอปพลิเคชันจริงๆ ก็คือ engine ที่มีคลาส `Rails::Application` ที่สืบทอดพฤติกรรมจาก `Rails::Engine` อย่างมาก

ดังนั้น engine และแอปพลิเคชันสามารถถือเป็นสิ่งเดียวกันเกือบทั้งหมด แต่มีความแตกต่างเล็กน้อย ตามที่คุณจะเห็นในคู่มือนี้ Engine และแอปพลิเคชันยังมีโครงสร้างที่เหมือนกัน

Engine และ plugin ก็เกี่ยวข้องกันอย่างใกล้ชิด ทั้งสองมีโครงสร้างไดเรกทอรี `lib` ที่เหมือนกัน และถูกสร้างขึ้นโดยใช้เจเนอเรเตอร์ `rails plugin new` ความแตกต่างคือ engine ถูกพิจารณาว่าเป็น "full plugin" โดย Rails (ตามที่แสดงในตัวเลือก `--full` ที่ถูกส่งผ่านคำสั่งเจเนอเรเตอร์) ในคู่มือนี้เราจะใช้ตัวเลือก `--mountable` ซึ่งรวมคุณสมบัติทั้งหมดของ `--full` และอื่นๆ คู่มือนี้จะอ้างถึง "full plugin" นี้เป็น "engines" อย่างง่าย ๆ Engine **สามารถ**เป็น plugin และ plugin **สามารถ**เป็น engine

Engine ที่จะถูกสร้างในคู่มือนี้จะชื่อ "blorgh" โดย engine นี้จะให้ความสามารถในการเขียนบล็อกให้กับแอปพลิเคชันหลัก โดยให้สร้างบทความและความคิดเห็นใหม่ ณ จุดเริ่มต้นของคู่มือนี้คุณจะทำงานอยู่ภายใน engine เท่านั้น แต่ในส่วนท้ายของคู่มือคุณจะเห็นวิธีการเชื่อมต่อ engine เข้ากับแอปพลิเคชัน

Engine ยังสามารถแยกจากแอปพลิเคชันหลักได้ นั่นหมายความว่าแอปพลิเคชันสามารถมีเส้นทางที่ให้โดยช่วยเหลือในการเรียกใช้เส้นทางเช่น `articles_path` และใช้ engine ที่ให้เส้นทางเช่นเดียวกันที่ชื่อ `articles_path` และสองอย่างนี้จะไม่มีการชนกัน นอกจากนี้ controller, model และชื่อตารางยังมีการจัดกลุ่มชื่อเช่นกัน คุณจะเห็นวิธีการทำนี้ในภายหลังในคู่มือนี้

สิ่งสำคัญที่ต้องจำไว้เสมอคือแอปพลิเคชันควรมีความสำคัญเสมอต่อ engines แอปพลิเคชันเป็นวัตถุที่มีคำตอบสุดท้ายในสิ่งที่เกิดขึ้นในสภาพแวดล้อมของมัน Engine ควรเพียงเพิ่มความสามารถให้แอปพลิเคชัน แทนที่จะเปลี่ยนแปลงมันอย่างรุนแรง

หากต้องการดูตัวอย่าง engine อื่น ๆ ลองเช็ค [Devise](https://github.com/plataformatec/devise) ซึ่งเป็น engine ที่ให้ความสามารถในการรับรองตัวตนสำหรับแอปพลิเคชันหลัก หรือ [Thredded](https://github.com/thredded/thredded) ซึ่งเป็น engine ที่ให้ความสามารถในการสร้างฟอรั่ม ยังมี [Spree](https://github.com/spree/spree) ที่ให้แพลตฟอร์มอีคอมเมิร์ซ และ [Refinery CMS](https://github.com/refinery/refinerycms) ที่เป็นเอ็นจินที่ให้บริการ CMS

สุดท้าย engine จะไม่สามารถเกิดขึ้นได้โดยไม่มีงานของ James Adam, Piotr Sarnacki, ทีมคอร์ของ Rails และบุคคลอื่น ๆ หลายคน หากคุณเคยพบพวกเขาอย่าลืมขอบคุณ!
การสร้างเครื่องยนต์
--------------------

เพื่อสร้างเครื่องยนต์ คุณจะต้องเรียกใช้ตัวสร้างปลั๊กอินและส่งตัวเลือกตามที่เหมาะสมตามความต้องการ สำหรับตัวอย่าง "blorgh" คุณจะต้องสร้างเครื่องยนต์ที่สามารถติดตั้งได้ โดยใช้คำสั่งนี้ในเทอร์มินัล:

```bash
$ rails plugin new blorgh --mountable
```

รายการเต็มของตัวเลือกสำหรับตัวสร้างปลั๊กอินสามารถดูได้โดยพิมพ์:

```bash
$ rails plugin --help
```

ตัวเลือก `--mountable` บอกตัวสร้างว่าคุณต้องการสร้างเครื่องยนต์ที่สามารถติดตั้งและแยกชื่อออกจากเนมสเปซได้ ตัวสร้างนี้จะให้โครงสร้างโครงร่างเดียวกับตัวเลือก `--full` ตัวเลือก `--full` บอกตัวสร้างว่าคุณต้องการสร้างเครื่องยนต์ที่รวมถึงโครงสร้างโครงร่างต่อไปนี้:

  * โครงสร้างไดเรกทอรี `app`
  * ไฟล์ `config/routes.rb`:

    ```ruby
    Rails.application.routes.draw do
    end
    ```

  * ไฟล์ที่อยู่ที่ `lib/blorgh/engine.rb` ซึ่งมีฟังก์ชันเดียวกับไฟล์ `config/application.rb` ของแอปพลิเคชัน Rails มาตรฐาน:

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
      end
    end
    ```

ตัวเลือก `--mountable` จะเพิ่มเติมในตัวเลือก `--full`:

  * ไฟล์แมนิเฟสต์ของแอสเซ็ต (`blorgh_manifest.js` และ `application.css`)
  * สแต็บ `ApplicationController` ที่อยู่ในเนมสเปซ
  * สแต็บ `ApplicationHelper` ที่อยู่ในเนมสเปซ
  * เทมเพลตมุมมองเลเอาท์สำหรับเครื่องยนต์
  * การแยกชื่อเนมสเปซใน `config/routes.rb`:

    ```ruby
    Blorgh::Engine.routes.draw do
    end
    ```

  * การแยกชื่อเนมสเปซใน `lib/blorgh/engine.rb`:

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
        isolate_namespace Blorgh
      end
    end
    ```

นอกจากนี้ ตัวเลือก `--mountable` บอกตัวสร้างว่าจะติดตั้งเครื่องยนต์ภายในแอปพลิเคชันทดสอบดัมมี่ที่อยู่ที่ `test/dummy` โดยเพิ่มส่วนต่อไปนี้ในไฟล์เส้นทางของแอปพลิเคชันดัมมี่ที่อยู่ที่ `test/dummy/config/routes.rb`:

```ruby
mount Blorgh::Engine => "/blorgh"
```

### ภายในเครื่องยนต์

#### ไฟล์ที่สำคัญ

ที่รากของไดเรกทอรีเครื่องยนต์ใหม่นี้มีไฟล์ `blorgh.gemspec` เมื่อคุณรวมเครื่องยนต์เข้ากับแอปพลิเคชันในภายหลัง คุณจะทำเช่นนี้โดยใส่บรรทัดนี้ในไฟล์ `Gemfile` ของแอปพลิเคชัน Rails:

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

อย่าลืมรัน `bundle install` เหมือนเคย โดยระบุให้เป็น gem ใน `Gemfile` Bundler จะโหลดมันเป็นเช่นนั้น แยกวิเคราะห์ไฟล์ `blorgh.gemspec` และต้องการไฟล์ในไดเรกทอรี `lib` ที่ชื่อว่า `lib/blorgh.rb` ไฟล์นี้จะต้องการไฟล์ `blorgh/engine.rb` (ที่อยู่ที่ `lib/blorgh/engine.rb`) และกำหนดโมดูลหลักที่ชื่อว่า `Blorgh`.

```ruby
require "blorgh/engine"

module Blorgh
end
```

เคล็ดลับ: บางเครื่องยนต์เลือกที่จะใช้ไฟล์นี้เพื่อใส่ตัวเลือกการกำหนดค่าสำหรับเครื่องยนต์ของพวกเขา นี่เป็นความคิดที่ดีเล็กน้อย ดังนั้นหากคุณต้องการเสนอตัวเลือกการกำหนดค่าไฟล์ที่กำหนดโมดูลของเครื่องยนต์ของคุณเป็นสิ่งที่เหมาะสม วางเมธอดภายในโมดูลแล้วคุณก็พร้อมที่จะไป

ภายใน `lib/blorgh/engine.rb` เป็นคลาสหลักสำหรับเครื่องยนต์:

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

โดยสืบทอดจากคลาส `Rails::Engine` จะแจ้งให้ Rails รู้ว่ามีเครื่องยนต์อยู่ที่เส้นทางที่ระบุและจะติดตั้งเครื่องยนต์ภายในแอปพลิเคชัน โดยดำเนินการเช่นเพิ่มไดเรกทอรี `app` ของเครื่องยนต์เข้าสู่เส้นทางการโหลดสำหรับโมเดลเมลเลอร์คอนโทรลเลอร์และวิว

เมธอด `isolate_namespace` ที่นี่ควรได้รับการสังเกตพิเศษ การเรียกใช้นี้รับผิดชอบในการแยกชื่อเนมสเปซของคอนโทรลเลอร์โมเดลเส้นทางและสิ่งอื่น ๆ เข้าสู่เนมสเปซของตัวเอง ห่างไกลจากส่วนประกอบที่คล้ายกันภายในแอปพลิเคชัน โดยไม่ต้องการส่วนประกอบของเครื่องยนต์ที่สามารถ "รั่ว" เข้าสู่แอปพลิเคชันได้ ทำให้เกิดความขัดแย้งที่ไม่ต้องการหรือส่วนประกอบสำคัญของเครื่องยนต์อาจถูกแทนที่ด้วยสิ่งที่มีชื่อคล้ายกันภายในแอปพลิเคชัน หนึ่งในตัวอย่างของการขัดแย้งเช่นนี้คือช่วยเหลือ หากไม่เรียกใช้ `isolate_namespace` เฮลเปอร์ของเครื่องยนต์จะถูกนำเข้าในคอนโทรลเลอร์ของแอปพลิเคชัน
หมายเหตุ: ขอแนะนำอย่างเข้มข้นว่าควรเก็บบรรทัด `isolate_namespace` ไว้ภายในคลาส `Engine` โดยไม่ควรเอาออก หากไม่เก็บไว้ คลาสที่สร้างขึ้นในเอ็นจินอาจมีความขัดแย้งกับแอปพลิเคชัน

การแยกชื่อเนมสเปซหมายถึงโมเดลที่สร้างขึ้นโดยการเรียกใช้ `bin/rails generate model` เช่น `bin/rails generate model article` จะไม่ถูกเรียกว่า `Article` แต่จะถูกแยกชื่อเนมสเปซและเรียกว่า `Blorgh::Article` นอกจากนี้ ตารางสำหรับโมเดลจะถูกแยกชื่อเนมสเปซและกลายเป็น `blorgh_articles` แทนที่จะเป็น `articles` เช่นเดียวกันกับการแยกชื่อเนมสเปซของคอนโทรลเลอร์ เช่น `ArticlesController` จะกลายเป็น `Blorgh::ArticlesController` และวิวสำหรับคอนโทรลเลอร์นั้นจะไม่อยู่ที่ `app/views/articles` แต่จะอยู่ที่ `app/views/blorgh/articles` แทน แม่แบบอีเมล งาน และช่วยเหลือก็ถูกแยกชื่อเนมสเป็ซเช่นกัน

สุดท้าย เส้นทางก็จะถูกแยกออกจากเอ็นจินด้วย นี่เป็นหนึ่งในส่วนสำคัญที่สุดเกี่ยวกับการแยกชื่อเนมสเปซ และจะถูกพูดถึงในส่วนของเอกสารนี้ในส่วนของ [เส้นทาง](#เส้นทาง)

#### ไดเรกทอรี `app`

ภายในไดเรกทอรี `app` จะมีไดเรกทอรีมาตรฐานอย่าง `assets`, `controllers`, `helpers`, `jobs`, `mailers`, `models`, และ `views` ซึ่งคุณควรเคยเห็นเนื่องจากความคล้ายคลึงกันกับแอปพลิเคชัน ในส่วนของโมเดล เราจะพูดถึงมันในส่วนของเอ็นจินในภายหลัง

ภายในไดเรกทอรี `app/assets` จะมีไดเรกทอรี `images` และ `stylesheets` ซึ่งอยู่ในรูปแบบที่คุณควรเคยเห็นเนื่องจากความคล้ายคลึงกันกับแอปพลิเคชัน อย่างไรก็ตาม ความแตกต่างที่นี่คือทุกไดเรกทอรีจะมีไดเรกทอรีย่อยที่มีชื่อของเอ็นจิน โดยเนื่องจากเอ็นจินนี้จะถูกแยกชื่อเนมสเปซ ทรัพยากรของเอ็นจินควรเป็นเช่นนั้นด้วย

ภายในไดเรกทอรี `app/controllers` จะมีไดเรกทอรี `blorgh` ที่มีไฟล์ชื่อ `application_controller.rb` ไฟล์นี้จะให้ฟังก์ชันที่เป็นประโยชน์ร่วมกันสำหรับคอนโทรลเลอร์ของเอ็นจิน ไดเรกทอรี `blorgh` คือที่ที่คอนโทรลเลอร์อื่น ๆ ของเอ็นจินจะอยู่ โดยการวางไฟล์ในไดเรกทอรีที่แยกชื่อเนมสเปซนี้จะป้องกันการขัดแย้งกับคอนโทรลเลอร์ที่มีชื่อเดียวกันในเอ็นจินอื่น ๆ หรือแม้แต่ในแอปพลิเคชัน

หมายเหตุ: คลาส `ApplicationController` ภายในเอ็นจินจะมีชื่อเหมือนกับแอปพลิเคชัน Rails เพื่อทำให้ง่ายต่อการแปลงแอปพลิเคชันของคุณให้เป็นเอ็นจิน

หมายเหตุ: หากแอปพลิเคชันหลักทำงานในโหมด `classic` คุณอาจพบสถานการณ์ที่คอนโทรลเลอร์ของเอ็นจินได้รับการสืบทอดจากคอนโทรลเลอร์ของแอปพลิเคชันหลักและไม่ใช่คอนโทรลเลอร์ของเอ็นจิน วิธีที่ดีที่สุดในการป้องกันสถานการณ์นี้คือการสลับไปใช้โหมด `zeitwerk` ในแอปพลิเคชันหลัก มิฉะนั้นให้ใช้ `require_dependency` เพื่อให้แน่ใจว่าคอนโทรลเลอร์ของเอ็นจินถูกโหลด ตัวอย่างเช่น:

```ruby
# จำเป็นเฉพาะในโหมด `classic` เท่านั้น
require_dependency "blorgh/application_controller"

module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

คำเตือน: อย่าใช้ `require` เพราะจะทำให้การโหลดคลาสโดยอัตโนมัติในสภาพแวดล้อมการพัฒนาเสีย - การใช้ `require_dependency` จะรับรองว่าคลาสถูกโหลดและถูกปลดปล่อยอย่างถูกต้อง

เช่นเดียวกับ `app/controllers` คุณจะพบไดเรกทอรีย่อย `blorgh` ภายใต้ไดเรกทอรี `app/helpers`, `app/jobs`, `app/mailers` และ `app/models` ที่มีไฟล์ `application_*.rb` ที่เกี่ยวข้องกับการรวบรวมฟังก์ชันที่เป็นประโยชน์ร่วมกัน โดยการวางไฟล์ของคุณในไดเรกทอรีย่อยนี้และแยกชื่อเนมสเปซของวัตถุของคุณจะป้องกันการขัดแย้งกับองค์ประกอบที่มีชื่อเดียวกันในเอ็นจินอื่น ๆ หรือแม้แต่ในแอปพลิเคชัน

สุดท้าย ไดเรกทอรี `app/views` มีไดเรกทอรี `layouts` ที่มีไฟล์ที่ `blorgh/application.html.erb` ไฟล์นี้ช่วยให้คุณระบุเลเอาต์สำหรับเอ็นจิน หากเอ็นจินนี้จะใช้เป็นเอ็นจินแบบแยกตัวอย่าง คุณควรเพิ่มการปรับแต่งในเลเอาต์นี้แทนที่ไฟล์ `app/views/layouts/application.html.erb` ของแอปพลิเคชัน
หากคุณไม่ต้องการบังคับเค้าโครงให้กับผู้ใช้ของเครื่องจักร คุณสามารถลบไฟล์นี้และอ้างอิงเค้าโครงที่แตกต่างกันในตัวควบคุมของเครื่องจักรของคุณได้

#### ไดเรกทอรี `bin`

ไดเรกทอรีนี้ประกอบด้วยไฟล์เดียว `bin/rails` ซึ่งช่วยให้คุณสามารถใช้คำสั่งย่อยและเครื่องมือสร้างเหมือนกับที่คุณจะใช้ในแอปพลิเคชัน นี่หมายความว่าคุณจะสามารถสร้างควบคุมเครื่องจักรและโมเดลใหม่สำหรับเครื่องจักรนี้ได้ง่ายๆ โดยใช้คำสั่งเช่นนี้:

```bash
$ bin/rails generate model
```

โปรดจำไว้ว่า สิ่งที่สร้างขึ้นด้วยคำสั่งเหล่านี้ภายในเครื่องจักรที่มี `isolate_namespace` ในคลาส `Engine` จะถูกตั้งชื่อเป็นชื่อพื้นที่

#### ไดเรกทอรี `test`

ไดเรกทอรี `test` เป็นที่เก็บทดสอบสำหรับเครื่องจักร ในการทดสอบเครื่องจักร มีแอปพลิเคชัน Rails เวอร์ชันย่อยที่ฝังอยู่ภายในที่ `test/dummy` แอปพลิเคชันนี้จะติดตั้งเครื่องจักรในไฟล์ `test/dummy/config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

บรรทัดนี้จะติดตั้งเครื่องจักรที่เส้นทาง `/blorgh` ซึ่งจะทำให้สามารถเข้าถึงได้ผ่านแอปพลิเคชันเท่านั้น

ในไดเรกทอรีทดสอบนี้มีไดเรกทอรี `test/integration` ซึ่งเป็นที่เก็บการทดสอบการรวมกันสำหรับเครื่องจักร สามารถสร้างไดเรกทอรีอื่นๆในไดเรกทอรี `test` ได้เช่นกัน ตัวอย่างเช่นคุณอาจต้องการสร้างไดเรกทอรี `test/models` สำหรับการทดสอบโมเดลของคุณ

การให้ความสามารถให้กับเครื่องจักร
------------------------------

เครื่องจักรที่คู่มือนี้พูดถึงให้ความสามารถในการส่งบทความและการแสดงความคิดเห็น และตามแนวคิดที่คล้ายกับ [คู่มือเริ่มต้น](getting_started.html) แต่มีการเพิ่มเติมบางอย่าง

หมายเหตุ: สำหรับส่วนนี้ โปรดตรวจสอบให้แน่ใจว่าคุณเรียกใช้คำสั่งในรูทของเครื่องจักร `blorgh` ในไดเรกทอรีราก

### การสร้างทรัพยากรบทความ

สิ่งแรกที่คุณต้องการสร้างสำหรับเครื่องจักรบล็อกคือโมเดล `Article` และควบคุมที่เกี่ยวข้อง หากต้องการสร้างอย่างรวดเร็วคุณสามารถใช้เครื่องมือสร้าง scaffold ของ Rails

```bash
$ bin/rails generate scaffold article title:string text:text
```

คำสั่งนี้จะแสดงข้อมูลดังต่อไปนี้:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_articles.rb
create    app/models/blorgh/article.rb
invoke    test_unit
create      test/models/blorgh/article_test.rb
create      test/fixtures/blorgh/articles.yml
invoke  resource_route
 route    resources :articles
invoke  scaffold_controller
create    app/controllers/blorgh/articles_controller.rb
invoke    erb
create      app/views/blorgh/articles
create      app/views/blorgh/articles/index.html.erb
create      app/views/blorgh/articles/edit.html.erb
create      app/views/blorgh/articles/show.html.erb
create      app/views/blorgh/articles/new.html.erb
create      app/views/blorgh/articles/_form.html.erb
invoke    test_unit
create      test/controllers/blorgh/articles_controller_test.rb
create      test/system/blorgh/articles_test.rb
invoke    helper
create      app/helpers/blorgh/articles_helper.rb
invoke      test_unit
```

สิ่งที่เครื่องมือ scaffold ทำคือเรียกใช้เครื่องมือ `active_record` ซึ่งจะสร้างการเคลื่อนย้ายและโมเดลสำหรับทรัพยากร โปรดทราบว่าการเคลื่อนย้ายถูกเรียกว่า `create_blorgh_articles` ไม่ใช่ `create_articles` ตามปกติ นี่เป็นเพราะว่าเรียกใช้เมธอด `isolate_namespace` ที่เรียกใช้ในการกำหนดค่าคลาส `Engine` โมเดลที่นี่ยังอยู่ในชื่อเนมสเปซ ถูกวางไว้ที่ `app/models/blorgh/article.rb` ไม่ใช่ `app/models/article.rb` เนื่องจากการเรียกใช้ `isolate_namespace` ภายในคลาส `Engine`

ต่อมา เรียกใช้เครื่องมือ `test_unit` สำหรับโมเดลนี้ โดยสร้างการทดสอบโมเดลที่ `test/models/blorgh/article_test.rb` (ไม่ใช่ `test/models/article_test.rb`) และ fixture ที่ `test/fixtures/blorgh/articles.yml` (ไม่ใช่ `test/fixtures/articles.yml`)

หลังจากนั้น เพิ่มบรรทัดสำหรับทรัพยากรในไฟล์ `config/routes.rb` สำหรับเครื่องจักร บรรทัดนี้เป็น `resources :articles` ทำให้ไฟล์ `config/routes.rb` สำหรับเครื่องจักรเป็นดังนี้:

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```
โปรดทราบว่าเส้นทางถูกวาดบนออบเจ็กต์ `Blorgh::Engine` แทน `YourApp::Application` class นี้เพื่อให้เส้นทางของเอ็นจินถูกจำกัดไว้ในเอนจินเองและสามารถติดตั้งได้ที่จุดที่ระบุในส่วน [ไดเรกทอรีทดสอบ](#test-directory) นี้ นอกจากนี้ยังทำให้เส้นทางของเอนจินถูกแยกจากเส้นทางที่อยู่ในแอปพลิเคชัน ส่วน [เส้นทาง](#routes) ในเอกสารนี้อธิบายโดยละเอียด

ถัดไป จะเรียกใช้ตัวสร้าง `scaffold_controller` เพื่อสร้างคอนโทรลเลอร์ที่ชื่อ `Blorgh::ArticlesController` (ที่ `app/controllers/blorgh/articles_controller.rb`) และมุมมองที่เกี่ยวข้องของมันที่ `app/views/blorgh/articles` ตัวสร้างนี้ยังสร้างเทสสำหรับคอนโทรลเลอร์ (`test/controllers/blorgh/articles_controller_test.rb` และ `test/system/blorgh/articles_test.rb`) และเฮลเปอร์ (`app/helpers/blorgh/articles_helper.rb`)

ทุกอย่างที่ตัวสร้างนี้สร้างขึ้นมาถูกจัดเก็บในเนมสเปซที่เรียบร้อย คลาสของคอนโทรลเลอร์ถูกกำหนดภายในโมดูล `Blorgh`:

```ruby
module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

หมายเหตุ: คลาส `ArticlesController` สืบทอดมาจาก `Blorgh::ApplicationController` ไม่ใช่ `ApplicationController` ของแอปพลิเคชัน

เฮลเปอร์ภายใน `app/helpers/blorgh/articles_helper.rb` ก็ถูกจัดเก็บในเนมสเปซเช่นกัน:

```ruby
module Blorgh
  module ArticlesHelper
    # ...
  end
end
```

สิ่งนี้ช่วยป้องกันความขัดแย้งกับเอนจินหรือแอปพลิเคชันอื่นที่อาจมีทรัพยากรบทความเช่นกัน

คุณสามารถดูสิ่งที่เอนจินมีได้โดยการเรียกใช้ `bin/rails db:migrate` ที่รากของเอนจินเพื่อเรียกใช้การเปลี่ยนแปลงที่สร้างขึ้นโดยตัวสร้าง scaffold แล้วเรียกใช้ `bin/rails server` ใน `test/dummy` เมื่อคุณเปิด
`http://localhost:3000/blorgh/articles` คุณจะเห็นสคริปต์เริ่มต้นที่ถูกสร้างขึ้น คลิกเลย! คุณเพิ่งสร้างฟังก์ชันแรกของเอนจินแรกของคุณ

หากคุณต้องการเล่นในคอนโซล `bin/rails console` ก็จะทำงานเหมือนแอปพลิเคชัน Rails คุณจำได้ไหม: โมเดล `Article` ถูกตั้งชื่อเนมสเปซ ดังนั้นหากต้องการอ้างอิงคุณต้องเรียกใช้เป็น `Blorgh::Article`

```irb
irb> Blorgh::Article.find(1)
=> #<Blorgh::Article id: 1 ...>
```

สิ่งสุดท้ายคือทรัพยากร `articles` สำหรับเอนจินนี้ควรเป็นรูทของเอนจิน ในกรณีที่มีคนเข้าถึงเส้นทางรูทที่เอนจินถูกติดตั้ง ควรแสดงรายการบทความให้เห็น สิ่งนี้สามารถทำได้โดยการแทรกบรรทัดนี้ในไฟล์ `config/routes.rb` ภายในเอนจิน:

```ruby
root to: "articles#index"
```

ตอนนี้ผู้คนจะต้องไปที่รูทของเอนจินเพื่อดูบทความทั้งหมดแทนที่จะไปที่ `/articles` นั่นหมายความว่าแทนที่จะไปที่ `http://localhost:3000/blorgh/articles` คุณเพียงแค่ไปที่ `http://localhost:3000/blorgh`
```bash
$ bin/rails db:migrate
```

เพื่อแสดงความคิดเห็นในบทความ แก้ไข `app/views/blorgh/articles/show.html.erb` และ
เพิ่มบรรทัดนี้ก่อนลิงค์ "แก้ไข":

```html+erb
<h3>ความคิดเห็น</h3>
<%= render @article.comments %>
```

บรรทัดนี้จะต้องมีการกำหนดความสัมพันธ์ `has_many` สำหรับความคิดเห็นที่กำหนดไว้
ในโมเดล `Blorgh::Article` ซึ่งยังไม่ได้กำหนดไว้ในขณะนี้ ในการกำหนดความสัมพันธ์
เปิดไฟล์ `app/models/blorgh/article.rb` และเพิ่มบรรทัดนี้ลงในโมเดล:

```ruby
has_many :comments
```

ทำให้โมเดลดูเป็นแบบนี้:

```ruby
module Blorgh
  class Article < ApplicationRecord
    has_many :comments
  end
end
```

หมายเหตุ: เนื่องจาก `has_many` ถูกกำหนดภายในคลาสที่อยู่ภายในโมดูล `Blorgh`
Rails จะรู้ว่าคุณต้องการใช้โมเดล `Blorgh::Comment` สำหรับอ็อบเจกต์เหล่านี้
ดังนั้นไม่จำเป็นต้องระบุด้วย `:class_name` ที่นี่

ต่อไปจะต้องมีแบบฟอร์มเพื่อสร้างความคิดเห็นในบทความ ในการเพิ่มนี้ให้เพิ่มบรรทัดนี้
ใต้การเรียกใช้ `render @article.comments` ใน `app/views/blorgh/articles/show.html.erb`:

```erb
<%= render "blorgh/comments/form" %>
```

ต่อมา ต้องมีพาร์เชียลที่บรรทัดนี้จะแสดง ให้สร้างไดเรกทอรีใหม่ที่ `app/views/blorgh/comments`
และในไดเรกทอรีนั้นสร้างไฟล์ใหม่ชื่อ `_form.html.erb` ซึ่งมีเนื้อหาดังต่อไปนี้เพื่อสร้างพาร์เชียลที่จำเป็น:

```html+erb
<h3>ความคิดเห็นใหม่</h3>
<%= form_with model: [@article, @article.comments.build] do |form| %>
  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>
  <%= form.submit %>
<% end %>
```

เมื่อแบบฟอร์มนี้ถูกส่ง มันจะพยายามทำ `POST` request
ไปยังเส้นทาง `/articles/:article_id/comments` ภายในเอ็นจิน สร้างเส้นทางนี้ได้โดยเปลี่ยนบรรทัด `resources :articles`
ภายใน `config/routes.rb` เป็นบรรทัดเหล่านี้:

```ruby
resources :articles do
  resources :comments
end
```

สร้างเส้นทางซ้อนกันสำหรับความคิดเห็น ซึ่งเป็นสิ่งที่แบบฟอร์มต้องการ

เส้นทางตอนนี้มีอยู่แล้ว แต่คอนโทรลเลอร์ที่เส้นทางนี้ไปยังยังไม่มี ในการสร้าง
ให้รันคำสั่งนี้จากรากของเอ็นจิน:

```bash
$ bin/rails generate controller comments
```

นี้จะสร้างสิ่งต่อไปนี้:

```
create  app/controllers/blorgh/comments_controller.rb
invoke  erb
 exist    app/views/blorgh/comments
invoke  test_unit
create    test/controllers/blorgh/comments_controller_test.rb
invoke  helper
create    app/helpers/blorgh/comments_helper.rb
invoke    test_unit
```

แบบฟอร์มจะทำ `POST` request ไปที่ `/articles/:article_id/comments`
ซึ่งจะสอดคล้องกับการกระทำ `create` ใน `Blorgh::CommentsController`
การกระทำนี้ต้องถูกสร้าง ซึ่งสามารถทำได้โดยใส่บรรทัดต่อไปนี้
ภายในคลาสที่กำหนดไว้ใน `app/controllers/blorgh/comments_controller.rb`:

```ruby
def create
  @article = Article.find(params[:article_id])
  @comment = @article.comments.create(comment_params)
  flash[:notice] = "ความคิดเห็นถูกสร้างแล้ว!"
  redirect_to articles_path
end

private
  def comment_params
    params.require(:comment).permit(:text)
  end
```

นี้เป็นขั้นตอนสุดท้ายที่จำเป็นในการทำให้แบบฟอร์มความคิดเห็นใหม่ทำงานได้
การแสดงความคิดเห็นอย่างไรก็ตาม ยังไม่ถูกต้องอย่างสมบูรณ์ หากคุณสร้างความคิดเห็น
ในขณะนี้ คุณจะเห็นข้อผิดพลาดนี้:

```
Missing partial blorgh/comments/_comment with {:handlers=>[:erb, :builder],
:formats=>[:html], :locale=>[:en, :en]}. Searched in:   *
"/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"   *
"/Users/ryan/Sites/side_projects/blorgh/app/views"
```

เอ็นจินไม่สามารถค้นหาพาร์เชียลที่จำเป็นสำหรับการแสดงความคิดเห็นได้
Rails จะค้นหาในไดเรกทอรี `app/views` ของแอปพลิเคชัน (`test/dummy`) ก่อน
แล้วค้นหาในไดเรกทอรี `app/views` ของเอ็นจิน เมื่อไม่พบ จะโยนข้อผิดพลาดนี้
เอ็นจินรู้ว่าจะค้นหา `blorgh/comments/_comment` เนื่องจากอ็อบเจกต์โมเดลที่ได้รับ
เป็นของคลาส `Blorgh::Comment`
ส่วนนี้จะรับผิดชอบในการแสดงเฉพาะข้อความความคิดเห็นเท่านั้น สร้างไฟล์ใหม่ที่ `app/views/blorgh/comments/_comment.html.erb` และใส่บรรทัดนี้ลงไป:

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

ตัวแปร `comment_counter` ถูกกำหนดให้เราโดยการเรียกใช้ `<%= render @article.comments %>` ซึ่งจะกำหนดให้โดยอัตโนมัติและเพิ่มค่าตัวนับเมื่อวนซ้ำผ่านทุกความคิดเห็น ในตัวอย่างนี้ใช้ในการแสดงตัวเลขเล็กๆ ข้างข้างของแต่ละความคิดเห็นเมื่อสร้างขึ้น

นี้เป็นการสมบูรณ์ของฟังก์ชันความคิดเห็นของเครื่องมือบล็อกกิ้ง ตอนนี้เป็นเวลาที่จะใช้ในแอปพลิเคชัน

การเชื่อมต่อกับแอปพลิเคชัน
---------------------------

การใช้เครื่องมือภายในแอปพลิเคชันนั้นง่ายมาก ส่วนนี้จะอธิบายวิธีการเชื่อมต่อเครื่องมือลงในแอปพลิเคชันและการตั้งค่าเริ่มต้นที่จำเป็น รวมถึงการเชื่อมต่อเครื่องมือกับคลาส `User` ที่ให้โดยแอปพลิเคชันเพื่อให้มีเจ้าของสำหรับบทความและความคิดเห็นภายในเครื่องมือ

### เชื่อมต่อเครื่องมือ

ก่อนอื่น เครื่องมือจำเป็นต้องระบุใน `Gemfile` ของแอปพลิเคชัน หากไม่มีแอปพลิเคชันที่พร้อมทดสอบนี้ สามารถสร้างได้โดยใช้คำสั่ง `rails new` นอกเหนือจากไดเรกทอรีของเครื่องมือเช่นนี้:

```bash
$ rails new unicorn
```

โดยปกติ การระบุเครื่องมือใน `Gemfile` จะทำโดยระบุเป็นเจ็มปกติ

```ruby
gem 'devise'
```

อย่างไรก็ตาม เนื่องจากคุณกำลังพัฒนาเครื่องมือ `blorgh` บนเครื่องคอมพิวเตอร์ของคุณ คุณจะต้องระบุตัวเลือก `:path` ใน `Gemfile`:

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

จากนั้นรัน `bundle` เพื่อติดตั้งเจ็ม

ตามที่อธิบายไว้ก่อนหน้านี้ โดยการวางเจ็มใน `Gemfile` จะโหลดเมื่อ Rails โหลด จะต้องเรียกใช้ `lib/blorgh.rb` จากเครื่องมือก่อน จากนั้น `lib/blorgh/engine.rb` ซึ่งเป็นไฟล์ที่กำหนดฟังก์ชันหลักสำหรับเครื่องมือ

เพื่อให้สามารถเข้าถึงฟังก์ชันของเครื่องมือจากภายในแอปพลิเคชันได้ เครื่องมือจำเป็นต้องถูกติดตั้งในไฟล์ `config/routes.rb` ของแอปพลิเคชัน:

```ruby
mount Blorgh::Engine, at: "/blog"
```

บรรทัดนี้จะเชื่อมต่อเครื่องมือที่ `/blog` ในแอปพลิเคชัน ทำให้สามารถเข้าถึงได้ที่ `http://localhost:3000/blog` เมื่อแอปพลิเคชันทำงานด้วย `bin/rails server`

หมายเหตุ: เครื่องมืออื่น ๆ เช่น Devise จัดการด้วยวิธีที่แตกต่างกัน โดยให้คุณระบุช่วยเหลือที่กำหนดเอง (เช่น `devise_for`) ในเส้นทาง ช่วยในการเชื่อมต่อส่วนของฟังก์ชันของเครื่องมือที่เส้นทางที่กำหนดไว้ล่วงหน้า

### การตั้งค่าเครื่องมือ

เครื่องมือมีการเคลื่อนย้ายสำหรับตาราง `blorgh_articles` และ `blorgh_comments` ที่ต้องสร้างในฐานข้อมูลของแอปพลิเคชัน เพื่อให้โมเดลของเครื่องมือสามารถสอบถามได้อย่างถูกต้อง ให้คัดลอกการเคลื่อนย้ายเหล่านี้ไปยังแอปพลิเคชันโดยใช้คำสั่งต่อไปนี้จากรูทของแอปพลิเคชัน:

```bash
$ bin/rails blorgh:install:migrations
```

หากคุณมีเครื่องมือหลายตัวที่ต้องการคัดลอกการเคลื่อนย้าย ให้ใช้ `railties:install:migrations` แทน:

```bash
$ bin/rails railties:install:migrations
```

คุณสามารถระบุเส้นทางที่กำหนดเองในเครื่องมือต้นฉบับสำหรับการเคลื่อนย้ายได้โดยระบุ MIGRATIONS_PATH

```bash
$ bin/rails railties:install:migrations MIGRATIONS_PATH=db_blourgh
```

หากคุณมีฐานข้อมูลหลายรายการคุณยังสามารถระบุฐานข้อมูลเป้าหมายได้โดยระบุ DATABASE

```bash
$ bin/rails railties:install:migrations DATABASE=animals
```
เมื่อรันคำสั่งนี้ครั้งแรก จะทำการคัดลอก migration ทั้งหมดจาก engine นั้น แต่เมื่อรันครั้งต่อไป จะทำการคัดลอกเฉพาะ migration ที่ยังไม่ได้คัดลอกมาก่อนแล้ว การรันครั้งแรกของคำสั่งนี้จะแสดงผลดังนี้:

```
คัดลอก migration [timestamp_1]_create_blorgh_articles.blorgh.rb จาก blorgh
คัดลอก migration [timestamp_2]_create_blorgh_comments.blorgh.rb จาก blorgh
```

timestamp แรก (`[timestamp_1]`) จะเป็นเวลาปัจจุบัน และ timestamp ที่สอง (`[timestamp_2]`) จะเป็นเวลาปัจจุบันบวก 1 วินาที สาเหตุที่ทำเช่นนี้คือเพื่อให้ migration ของ engine ถูกรันหลังจาก migration ที่มีอยู่ในแอปพลิเคชัน

ในการรัน migration เหล่านี้ภายในแอปพลิเคชัน ให้รันคำสั่ง `bin/rails db:migrate` เพียงเท่านั้น หากเข้าถึง engine ผ่าน `http://localhost:3000/blog` บทความจะว่างเปล่า เนื่องจากตารางที่สร้างขึ้นภายในแอปพลิเคชันแตกต่างจากตารางที่สร้างขึ้นใน engine ลองเล่นกับ engine ที่ถูกติดตั้งใหม่ได้เลย คุณจะพบว่ามันเหมือนเมื่อมันเป็น engine เท่านั้น

หากคุณต้องการรัน migration เฉพาะจาก engine เดียว คุณสามารถทำได้โดยระบุ `SCOPE`:

```bash
$ bin/rails db:migrate SCOPE=blorgh
```

นี้อาจเป็นประโยชน์หากคุณต้องการย้อนกลับ migration ของ engine ก่อนที่จะลบมันออก ในการย้อนกลับ migration ทั้งหมดจาก blorgh engine คุณสามารถรันโค้ดดังนี้:

```bash
$ bin/rails db:migrate SCOPE=blorgh VERSION=0
```

### การใช้คลาสที่ให้มาจากแอปพลิเคชัน

#### การใช้โมเดลที่ให้มาจากแอปพลิเคชัน

เมื่อสร้าง engine อาจต้องการใช้คลาสที่เฉพาะเจาะจงจากแอปพลิเคชันเพื่อให้เชื่อมโยงระหว่างส่วนของ engine และส่วนของแอปพลิเคชัน ในกรณีของ engine `blorgh` การทำให้บทความและความคิดเห็นมีผู้เขียนจะมีความหมายมาก

แอปพลิเคชันปกติอาจมีคลาส `User` ที่จะใช้แทนผู้เขียนสำหรับบทความหรือความคิดเห็น แต่อาจมีกรณีที่แอปพลิเคชันเรียกใช้คลาสนี้ด้วยชื่ออื่น เช่น `Person` ดังนั้น engine ไม่ควรระบุการเชื่อมโยงโดยเฉพาะสำหรับคลาส `User`

เพื่อให้ง่ายในกรณีนี้ แอปพลิเคชันจะมีคลาสที่ชื่อ `User` ที่แทนผู้ใช้งานของแอปพลิเคชัน (เราจะพูดถึงวิธีทำให้เปลี่ยนแปลงได้ในภายหลัง) สามารถสร้างได้โดยใช้คำสั่งนี้ภายในแอปพลิเคชัน:

```bash
$ bin/rails generate model user name:string
```

คำสั่ง `bin/rails db:migrate` จำเป็นต้องรันที่นี่เพื่อให้แอปพลิเคชันมีตาราง `users` สำหรับการใช้ในอนาคต

นอกจากนี้ เพื่อให้ง่าย แบบฟอร์มบทความจะมีฟิลด์ข้อความใหม่ที่ชื่อ `author_name` ที่ผู้ใช้งานสามารถเลือกใส่ชื่อของตนเองได้ จากนั้น engine จะใช้ชื่อนี้และสร้าง `User` object ใหม่จากชื่อนี้หรือค้นหา `User` object ที่มีชื่อนี้อยู่แล้ว จากนั้น engine จะเชื่อมโยงบทความกับ `User` object ที่พบหรือสร้างขึ้น

ก่อนอื่น ต้องเพิ่มฟิลด์ `author_name` ใน partial `app/views/blorgh/articles/_form.html.erb` ภายใน engine นี้ สามารถเพิ่มได้ด้านบนของฟิลด์ `title` ด้วยโค้ดนี้:

```html+erb
<div class="field">
  <%= form.label :author_name %><br>
  <%= form.text_field :author_name %>
</div>
```
ต่อไปเราจะต้องอัปเดตเมธอด `Blorgh::ArticlesController#article_params` ในการอนุญาตให้พารามิเตอร์ฟอร์มใหม่:

```ruby
def article_params
  params.require(:article).permit(:title, :text, :author_name)
end
```

จากนั้น `Blorgh::Article` โมเดลควรมีโค้ดบางส่วนเพื่อแปลงฟิลด์ `author_name` เป็นออบเจ็กต์ `User` และเชื่อมโยงให้เป็น `author` ของบทความนั้นก่อนบทความถูกบันทึก นอกจากนี้จะต้องมี `attr_accessor` ที่กำหนดขึ้นสำหรับฟิลด์นี้เพื่อให้มีเมธอด setter และ getter สำหรับฟิลด์นี้

เพื่อทำทั้งหมดนี้ คุณจะต้องเพิ่ม `attr_accessor` สำหรับ `author_name` การเชื่อมโยงสำหรับผู้เขียน และการเรียกใช้ `before_validation` เข้าไปใน `app/models/blorgh/article.rb` การเชื่อมโยง `author` จะถูกกำหนดค่าไปยังคลาส `User` ชั่วคราว

```ruby
attr_accessor :author_name
belongs_to :author, class_name: "User"

before_validation :set_author

private
  def set_author
    self.author = User.find_or_create_by(name: author_name)
  end
```

โดยการแทนที่ออบเจ็กต์ของการเชื่อมโยง `author` ด้วยคลาส `User` เชื่อมโยงระหว่างเอ็นจินและแอปพลิเคชันจะถูกสร้างขึ้น จะต้องมีวิธีในการเชื่อมโยงระหว่างบันทึกในตาราง `blorgh_articles` กับบันทึกในตาราง `users` เนื่องจากการเชื่อมโยงถูกเรียกว่า `author` จะต้องมีคอลัมน์ `author_id` เพิ่มในตาราง `blorgh_articles`

เพื่อสร้างคอลัมน์ใหม่นี้ให้รันคำสั่งนี้ภายในเอ็นจิน:

```bash
$ bin/rails generate migration add_author_id_to_blorgh_articles author_id:integer
```

หมายเหตุ: เนื่องจากชื่อของการเมืองและการระบุคอลัมน์หลังจากนั้น Rails จะรู้อัตโนมัติว่าคุณต้องการเพิ่มคอลัมน์ในตารางที่ระบุและเขียนลงในการเมืองให้คุณ คุณไม่จำเป็นต้องบอกให้มันมากกว่านี้

การรันการเมืองนี้จะต้องรันในแอปพลิเคชัน ในการทำงานนั้นจะต้องคัดลอกก่อนโดยใช้คำสั่งนี้:

```bash
$ bin/rails blorgh:install:migrations
```

สังเกตว่ามีการคัดลอกเพียง _หนึ่ง_ การเมืองที่นี่ นั่นเป็นเพราะการคัดลอกการเมืองสองครั้งแรกได้ถูกคัดลอกครั้งแรกที่คำสั่งนี้ถูกเรียกใช้

```
หมายเหตุ การเมือง [timestamp]_create_blorgh_articles.blorgh.rb จาก blorgh ถูกข้ามไป การเมืองที่มีชื่อเดียวกันมีอยู่แล้ว
หมายเหตุ การเมือง [timestamp]_create_blorgh_comments.blorgh.rb จาก blorgh ถูกข้ามไป การเมืองที่มีชื่อเดียวกันมีอยู่แล้ว
คัดลอกการเมือง [timestamp]_add_author_id_to_blorgh_articles.blorgh.rb จาก blorgh
```

รันการเมืองโดยใช้:

```bash
$ bin/rails db:migrate
```

ตอนนี้ทุกอย่างพร้อมแล้ว การกระทำหนึ่งจะเกิดขึ้นซึ่งจะเชื่อมโยงผู้เขียน - ที่แสดงในรูปของบันทึกในตาราง `users` - กับบทความ ที่แสดงในตาราง `blorgh_articles` จากเอ็นจิน

สุดท้าย ชื่อผู้เขียนควรแสดงบนหน้าบทความ เพิ่มโค้ดนี้ด้านบนของการแสดงผล "Title" ภายใน `app/views/blorgh/articles/show.html.erb`:

```html+erb
<p>
  <b>Author:</b>
  <%= @article.author.name %>
</p>
```

#### การใช้คอนโทรลเลอร์ที่ให้มาจากแอปพลิเคชัน

เนื่องจากคอนโทรลเลอร์ของ Rails มักจะแชร์โค้ดสำหรับสิ่งเช่นการตรวจสอบสิทธิ์และการเข้าถึงตัวแปรเซสชัน ค่าเริ่มต้นคือการสืบทอดจาก `ApplicationController` โดยอัตโนมัติ แต่เอ็นจินของ Rails ถูกจำกัดให้ทำงานอิสระจากแอปพลิเคชันหลัก ดังนั้นแต่ละเอ็นจินจะได้รับ `ApplicationController` ที่ถูกจำกัดขอบเขต การตั้งชื่อเพื่อป้องกันการชนกันของโค้ด แต่บ่อยครั้งคอนโทรลเลอร์ของเอ็นจินต้องเข้าถึงเมธอดใน `ApplicationController` ของแอปพลิเคชันหลัก วิธีง่ายในการให้การเข้าถึงนี้คือเปลี่ยน `ApplicationController` ของเอ็นจินให้สืบทอดจาก `ApplicationController` ของแอปพลิเคชันหลัก สำหรับเอ็นจิน Blorgh เราสามารถทำได้โดยเปลี่ยน `app/controllers/blorgh/application_controller.rb` เป็นดังนี้:
```ruby
module Blorgh
  class ApplicationController < ::ApplicationController
  end
end
```

โดยค่าเริ่มต้น คลาสของเอ็นจินจะสืบทอดมาจาก `Blorgh::ApplicationController` ดังนั้นหลังจากการเปลี่ยนแปลงนี้ คลาสเหล่านั้นจะสามารถเข้าถึง `ApplicationController` ของแอปพลิเคชันหลักได้เหมือนกับว่าเป็นส่วนหนึ่งของแอปพลิเคชันหลัก

การเปลี่ยนแปลงนี้ต้องการให้เอ็นจินทำงานจากแอปพลิเคชัน Rails ที่มี `ApplicationController` อยู่

### การกำหนดค่าให้กับเอ็นจิน

ส่วนนี้จะอธิบายวิธีการกำหนดค่าให้กับคลาส `User` และเคล็ดลับการกำหนดค่าทั่วไปสำหรับเอ็นจิน

#### การกำหนดค่าในแอปพลิเคชัน

ขั้นตอนถัดไปคือการทำให้คลาสที่แทน `User` ในแอปพลิเคชันสามารถกำหนดค่าได้สำหรับเอ็นจิน นี่เพราะคลาสนั้นอาจไม่ใช่ `User` เสมอ ตามที่อธิบายไว้ก่อนหน้านี้ ในการทำให้ค่านี้สามารถกำหนดค่าได้ เอ็นจินจะมีการกำหนดค่าที่เรียกว่า `author_class` ซึ่งจะใช้ในการระบุคลาสที่แทนผู้ใช้ในแอปพลิเคชัน

ในการกำหนดค่านี้ คุณควรใช้ `mattr_accessor` ภายในโมดูล `Blorgh` สำหรับเอ็นจิน ให้เพิ่มบรรทัดนี้ใน `lib/blorgh.rb` ภายในเอ็นจิน:

```ruby
mattr_accessor :author_class
```

เมธอดนี้ทำงานเหมือนกับ `attr_accessor` และ `cattr_accessor` แต่จะให้เมธอด setter และ getter บนโมดูลที่มีชื่อที่ระบุ ในการใช้งาน เราต้องอ้างอิงถึง `Blorgh.author_class`

ขั้นตอนถัดไปคือการเปลี่ยนโมเดล `Blorgh::Article` ให้ใช้ค่าใหม่นี้ แก้ไขความสัมพันธ์ `belongs_to` ภายในโมเดลนี้ (`app/models/blorgh/article.rb`) เป็นดังนี้:

```ruby
belongs_to :author, class_name: Blorgh.author_class
```

เมธอด `set_author` ในโมเดล `Blorgh::Article` ก็ควรใช้คลาสนี้เช่นกัน:

```ruby
self.author = Blorgh.author_class.constantize.find_or_create_by(name: author_name)
```

เพื่อไม่ต้องเรียกใช้ `constantize` กับผลลัพธ์ของ `author_class` ทุกครั้ง เราสามารถแทนที่ด้วยการเขียนทับเมธอด getter `author_class` ภายในโมดูล `Blorgh` ในไฟล์ `lib/blorgh.rb` เพื่อให้เรียกใช้ `constantize` กับค่าที่บันทึกไว้ก่อนส่งคืนผลลัพธ์:

```ruby
def self.author_class
  @@author_class.constantize
end
```

จากนั้นโค้ดสำหรับ `set_author` จะเป็นดังนี้:

```ruby
self.author = Blorgh.author_class.find_or_create_by(name: author_name)
```

ทำให้โค้ดสั้นลงและมีความแม่นยำมากขึ้น และเมธอด `author_class` ควรส่งคืนออบเจกต์ `Class`

เนื่องจากเราเปลี่ยนเมธอด `author_class` ให้ส่งคืน `Class` แทน `String` เราต้องแก้ไขการกำหนดค่า `belongs_to` ในโมเดล `Blorgh::Article` เป็นดังนี้:

```ruby
belongs_to :author, class_name: Blorgh.author_class.to_s
```

ในการกำหนดค่านี้ในแอปพลิเคชัน คุณควรใช้ initializer เพื่อให้การกำหนดค่าเกิดขึ้นก่อนที่แอปพลิเคชันจะเริ่มต้นและเรียกโมเดลของเอ็นจิน ซึ่งอาจขึ้นอยู่กับการกำหนดค่านี้

สร้าง initializer ใหม่ที่ `config/initializers/blorgh.rb` ภายในแอปพลิเคชันที่ติดตั้งเอ็นจิน `blorgh` และใส่เนื้อหาต่อไปนี้ในไฟล์:

```ruby
Blorgh.author_class = "User"
```

คำเตือน: สำคัญมากที่นี่คือการใช้เวอร์ชัน `String` ของคลาส แทนคลาสเอง ถ้าคุณใช้คลาส  Rails จะพยายามโหลดคลาสนั้นและอ้างถึงตารางที่เกี่ยวข้อง ซึ่งอาจทำให้เกิดปัญหาหากตารางยังไม่มีอยู่ ดังนั้นควรใช้ `String` แล้วแปลงเป็นคลาสโดยใช้ `constantize` ในเอ็นจินในภายหลัง
ลองสร้างบทความใหม่ดูสิ คุณจะเห็นว่ามันทำงานเหมือนเดิม แต่ครั้งนี้เครื่องมือใช้การตั้งค่าใน `config/initializers/blorgh.rb` เพื่อเรียนรู้ว่าคลาสคืออะไร

ตอนนี้ไม่มีการขึ้นอยู่กับคลาสเดียวกันแล้ว แต่ขึ้นอยู่กับ API ของคลาสนั้น ๆ เท่านั้น แค่เพียงเครื่องมือนี้ต้องการให้คลาสนั้นกำหนดเมธอด `find_or_create_by` ที่คืนค่าออบเจกต์ของคลาสนั้น ๆ เพื่อเชื่อมโยงกับบทความเมื่อมีการสร้าง ออบเจกต์นี้ควรมีตัวระบุใด ๆ ที่สามารถอ้างอิงได้

#### การกำหนดค่าเครื่องมือทั่วไป

ในเครื่องมือ อาจมีเวลาที่คุณต้องการใช้สิ่งต่าง ๆ เช่น initializers, internationalization หรือตัวเลือกการกำหนดค่าอื่น ๆ ข่าวดีคือสิ่งเหล่านี้เป็นไปได้ทั้งหมด เพราะเครื่องมือ Rails แชร์ความสามารถเดียวกับแอปพลิเคชัน Rails จริง ๆ แต่จริง ๆ แล้วความสามารถของแอปพลิเคชัน Rails นั้นเป็นเซตย่อยของสิ่งที่เครื่องมือให้!

หากคุณต้องการใช้ initializer - โค้ดที่ควรทำงานก่อนที่เครื่องมือจะโหลด - สถานที่ที่เหมาะสำหรับมันคือโฟลเดอร์ `config/initializers` ฟังก์ชันของไดเรกทอรีนี้อธิบายไว้ในส่วน [Initializers
section](configuring.html#initializers) ของเอกสาร Configuring และทำงานเหมือนกับไดเรกทอรี `config/initializers` ภายในแอปพลิเคชันเช่นกัน สิ่งเดียวกันก็เกิดขึ้นหากคุณต้องการใช้ initializer มาตรฐาน

สำหรับ locale ให้เพียงแค่วางไฟล์ locale ในไดเรกทอรี `config/locales` เหมือนที่คุณทำในแอปพลิเคชัน

การทดสอบเครื่องมือ
-----------------

เมื่อสร้างเครื่องมือ จะมีแอปพลิเคชันเล็กขนาดเล็กถูกสร้างขึ้นภายในเครื่องมือที่ `test/dummy` แอปพลิเคชันนี้ใช้เป็นจุดติดตั้งสำหรับเครื่องมือเพื่อทำให้การทดสอบเครื่องมือเป็นเรื่องง่ายมาก คุณสามารถขยายแอปพลิเคชันนี้ได้โดยการสร้างคอนโทรลเลอร์ โมเดล หรือวิวจากภายในไดเรกทอรี แล้วใช้เหล่านั้นในการทดสอบเครื่องมือของคุณ

ไดเรกทอรี `test` ควรถูกใช้เหมือนสภาพแวดล้อมการทดสอบของ Rails ปกติ ที่อนุญาตให้ทดสอบหน่วย ฟังก์ชัน และการทดสอบการรวมกัน

### การทดสอบฟังก์ชัน

สิ่งที่ควรพิจารณาเมื่อเขียนการทดสอบฟังก์ชันคือการทดสอบจะทำงานบนแอปพลิเคชัน - แอปพลิเคชันทดสอบ `test/dummy` - ไม่ใช่เครื่องมือของคุณ สาเหตุที่เป็นเช่นนี้เนื่องจากการตั้งค่าสภาพแวดล้อมการทดสอบ เครื่องมือต้องการแอปพลิเคชันเป็นโฮสต์สำหรับการทดสอบฟังก์ชันหลักของมัน โดยเฉพาะอย่างยิ่งคอนโทรลเลอร์ นี่หมายความว่าหากคุณทำ `GET` ทั่วไปไปยังคอนโทรลเลอร์ในการทดสอบฟังก์ชันของคอนโทรลเลอร์เช่นนี้:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def test_index
      get foos_url
      # ...
    end
  end
end
```

อาจทำงานไม่ถูกต้อง สาเหตุเพราะแอปพลิเคชันไม่รู้วิธีเส้นทางคำขอเหล่านี้ไปยังเครื่องมือนอกจากคุณบอกให้มัน **วิธี** ทำ ในการทำเช่นนี้คุณต้องตั้งค่าตัวแปรอินสแตนซ์ `@routes` เป็นชุดเส้นทางของเครื่องมือในรหัสการตั้งค่าของคุณ:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_index
      get foos_url
      # ...
    end
  end
end
```

สิ่งนี้บอกแอปพลิเคชันว่าคุณยังต้องการทำ `GET` ไปยังการกระทำ `index` ของคอนโทรลเลอร์นี้ แต่คุณต้องการใช้เส้นทางของเครื่องมือในการไปถึงจุดนั้น ไม่ใช่ของแอปพลิเคชัน
นอกจากนี้ยังตรวจสอบให้แน่ใจว่า URL helpers ของเครื่องมือจะทำงานตามที่คาดหวังในการทดสอบของคุณ

การปรับปรุงความสามารถของ Engine
------------------------------

ส่วนนี้อธิบายวิธีการเพิ่มและ/หรือแทนที่ความสามารถของ engine MVC ในแอปพลิเคชัน Rails หลัก

### การแทนที่โมเดลและคอนโทรลเลอร์

โมเดลและคอนโทรลเลอร์ของเอ็นจินสามารถเปิดใช้งานใหม่โดยแอปพลิเคชันหลักเพื่อขยายหรือตกแต่ง

การแทนที่สามารถจัดระเบียบไว้ในไดเรกทอรีที่กำหนดเอง `app/overrides` ซึ่งจะถูกละเว้นโดย autoloader และโหลดล่วงหน้าใน `to_prepare` callback:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        load override
      end
    end
  end
end
```

#### เปิดใช้งานคลาสที่มีอยู่โดยใช้ `class_eval`

ตัวอย่างเช่น เพื่อแทนที่โมเดลของเอ็นจิน

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    # ...
  end
end
```

คุณเพียงแค่สร้างไฟล์ที่ _เปิดใช้งาน_ คลาสนั้น:

```ruby
# MyApp/app/overrides/models/blorgh/article_override.rb
Blorgh::Article.class_eval do
  # ...
end
```

สำคัญมากที่การแทนที่ _เปิดใช้งาน_ คลาสหรือโมดูล การใช้คำสำคัญ `class` หรือ `module` จะกำหนดให้ถ้าหากว่าพวกเขายังไม่ได้อยู่ในหน่วยความจำแล้ว ซึ่งจะไม่ถูกต้องเพราะการกำหนดอยู่ในเอ็นจิน การใช้ `class_eval` ตามที่แสดงในตัวอย่างข้างบนจะทำให้คุณเปิดใช้งาน

#### เปิดใช้งานคลาสที่มีอยู่โดยใช้ ActiveSupport::Concern

การใช้ `Class#class_eval` ดีสำหรับการปรับปรุงที่เรียบง่าย แต่สำหรับการปรับปรุงคลาสที่ซับซ้อนมากขึ้น คุณอาจต้องพิจารณาใช้ [`ActiveSupport::Concern`](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html) แทน
ActiveSupport::Concern จัดการลำดับการโหลดของโมดูลและคลาสที่เชื่อมโยงกันที่เกิดขึ้นในเวลาทำงาน ทำให้คุณสามารถแยกโมดูลของคุณได้อย่างมีระเบียบ

**การเพิ่ม** `Article#time_since_created` และ **การแทนที่** `Article#summary`:

```ruby
# MyApp/app/models/blorgh/article.rb

class Blorgh::Article < ApplicationRecord
  include Blorgh::Concerns::Models::Article

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    include Blorgh::Concerns::Models::Article
  end
end
```

```ruby
# Blorgh/lib/concerns/models/article.rb

module Blorgh::Concerns::Models::Article
  extend ActiveSupport::Concern

  # `included do` causes the block to be evaluated in the context
  # in which the module is included (i.e. Blorgh::Article),
  # rather than in the module itself.
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_validation :set_author

    private
      def set_author
        self.author = User.find_or_create_by(name: author_name)
      end
  end

  def summary
    "#{title}"
  end

  module ClassMethods
    def some_class_method
      'some class method string'
    end
  end
end
```

### Autoloading และ Engines

โปรดตรวจสอบคู่มือ [Autoloading and Reloading Constants](autoloading_and_reloading_constants.html#autoloading-and-engines) เพื่อข้อมูลเพิ่มเติมเกี่ยวกับ autoloading และ engines


### การแทนที่วิว

เมื่อ Rails มองหาวิวที่จะแสดง จะมองหาในไดเรกทอรี `app/views` ของแอปพลิเคชันก่อน หากไม่พบวิวที่นั่น จะตรวจสอบในไดเรกทอรี `app/views` ของเอ็นจินทั้งหมดที่มีไดเรกทอรีนี้

เมื่อแอปพลิเคชันถูกขอให้แสดงวิวสำหรับการกระทำ index ของ `Blorgh::ArticlesController` จะมองหาเส้นทาง
`app/views/blorgh/articles/index.html.erb` ภายในแอปพลิเคชันก่อน หากไม่พบ จะมองหาในเอ็นจิน

คุณสามารถแทนที่วิวนี้ในแอปพลิเคชันโดยการสร้างไฟล์ใหม่ที่ `app/views/blorgh/articles/index.html.erb` จากนั้นคุณสามารถเปลี่ยนแปลงเนื้อหาของวิวนี้ได้ตามที่คุณต้องการ

ลองดูเลยโดยการสร้างไฟล์ใหม่ที่ `app/views/blorgh/articles/index.html.erb` และใส่เนื้อหาต่อไปนี้ลงไป:

```html+erb
<h1>Articles</h1>
<%= link_to "New Article", new_article_path %>
<% @articles.each do |article| %>
  <h2><%= article.title %></h2>
  <small>By <%= article.author %></small>
  <%= simple_format(article.text) %>
  <hr>
<% end %>
```
### เส้นทาง

เส้นทางภายในเอ็นจิ้นจะถูกแยกจากแอปพลิเคชันโดยค่าเริ่มต้น ซึ่งทำโดยการเรียกใช้ `isolate_namespace` ภายในคลาส `Engine` นั่นหมายความว่าแอปพลิเคชันและเอ็นจิ้นของมันสามารถมีเส้นทางที่มีชื่อเหมือนกันได้โดยที่ไม่มีการชนกัน

เส้นทางภายในเอ็นจิ้นจะถูกกำหนดในคลาส `Engine` ภายใน `config/routes.rb` ดังนี้:

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

โดยมีเส้นทางที่แยกออกมาเช่นนี้ หากคุณต้องการลิงก์ไปยังพื้นที่ในเอ็นจิ้นจากภายในแอปพลิเคชัน คุณจะต้องใช้เมธอดพร็อกซี่เส้นทางของเอ็นจิ้น เรียกใช้เมธอดเส้นทางปกติเช่น `articles_path` อาจจะไปยังตำแหน่งที่ไม่ต้องการหากทั้งแอปพลิเคชันและเอ็นจิ้นมีเมธอดชื่อเดียวกัน

ตัวอย่างเช่น ตัวอย่างต่อไปนี้จะไปที่ `articles_path` ของแอปพลิเคชันหากเทมเพลตนั้นถูกแสดงจากแอปพลิเคชัน หรือไปที่ `articles_path` ของเอ็นจิ้นหากถูกแสดงจากเอ็นจิ้น:

```erb
<%= link_to "บทความบล็อก", articles_path %>
```

เพื่อให้เส้นทางนี้ใช้เสมอเมธอดช่วยเส้นทาง `articles_path` ของเอ็นจิ้น เราต้องเรียกเมธอดนั้นบนเมธอดพร็อกซี่เส้นทางที่มีชื่อเดียวกันกับเอ็นจิ้น

```erb
<%= link_to "บทความบล็อก", blorgh.articles_path %>
```

หากคุณต้องการอ้างอิงแอปพลิเคชันภายในเอ็นจิ้นในลักษณะที่คล้ายกัน ให้ใช้ช่วยเหลือ `main_app`:

```erb
<%= link_to "หน้าหลัก", main_app.root_path %>
```

หากคุณใช้สิ่งนี้ภายในเอ็นจิ้น มันจะไปที่ root ของแอปพลิเคชันเสมอ หากคุณไม่เรียกใช้เมธอดพร็อกซี่ "main_app" มันอาจไปที่ root ของเอ็นจิ้นหรือแอปพลิเคชันได้ตามที่เรียกมา

หากเทมเพลตที่ถูกแสดงจากเอ็นจิ้นพยายามใช้เมธอดช่วยเส้นทางของแอปพลิเคชัน อาจเกิดข้อผิดพลาดเมธอดที่ไม่ได้ถูกกำหนดได้ หากคุณพบปัญหาเช่นนี้ ตรวจสอบให้แน่ใจว่าคุณไม่พยายามเรียกใช้เมธอดช่วยเส้นทางของแอปพลิเคชันโดยไม่มีคำนำหน้า `main_app` จากภายในเอ็นจิ้น

### ทรัพยากร

ทรัพยากรภายในเอ็นจิ้นทำงานเหมือนกับแอปพลิเคชันเต็มรูปแบบ โดยเพราะคลาสเอ็นจิ้นสืบทอดมาจาก `Rails::Engine` แอปพลิเคชันจะรู้ว่าจะค้นหาทรัพยากรในไดเรกทอรี `app/assets` และ `lib/assets` ของเอ็นจิ้น

เหมือนกับส่วนอื่น ๆ ของเอ็นจิ้น ทรัพยากรควรอยู่ในเนมสเปซ นั่นหมายความว่าหากคุณมีทรัพยากรที่ชื่อว่า `style.css` คุณควรวางไว้ที่ `app/assets/stylesheets/[ชื่อเอ็นจิ้น]/style.css` แทนที่จะวางไว้ที่ `app/assets/stylesheets/style.css` หากทรัพยากรนี้ไม่ได้อยู่ในเนมสเปซ มีโอกาสที่แอปพลิเคชันหลักอาจมีทรัพยากรที่มีชื่อเดียวกัน ในกรณีนี้ทรัพยากรของแอปพลิเคชันจะมีความสำคัญกว่าและทรัพยากรของเอ็นจิ้นจะถูกละเลย

สมมติว่าคุณมีทรัพยากรที่ตั้งอยู่ที่ `app/assets/stylesheets/blorgh/style.css` เพื่อรวมทรัพยากรนี้ในแอปพลิเคชัน เพียงแค่ใช้ `stylesheet_link_tag` และอ้างอิงทรัพยากรเหมือนกับที่อยู่ในเอ็นจิ้น:

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

คุณยังสามารถระบุทรัพยากรเหล่านี้เป็นลักษณะของทรัพยากรอื่น ๆ โดยใช้คำสั่ง require ในไฟล์ที่ประมวลผล:

```css
/*
 *= require blorgh/style
 */
```

INFO. โปรดจำไว้ว่าเพื่อให้ใช้ภาษาเช่น Sass หรือ CoffeeScript คุณควรเพิ่มไลบรารีที่เกี่ยวข้องใน `.gemspec` ของเอ็นจิ้นของคุณ
### แยกทรัพยากรและการเตรียมคอมไพล์

มีบางสถานการณ์ที่ทรัพยากรของเอ็นจิ้นของคุณไม่จำเป็นต้องใช้โดยแอปพลิเคชันโฮสต์ ตัวอย่างเช่น สมมติว่าคุณได้สร้างฟังก์ชันการดูแลระบบที่มีอยู่เฉพาะสำหรับเอ็นจิ้นของคุณ ในกรณีนี้ แอปพลิเคชันโฮสต์ไม่จำเป็นต้องร้องขอ `admin.css` หรือ `admin.js` เพียงแค่เลเอาท์ของเอ็นจิ้นเท่านั้นที่ต้องการทรัพยากรเหล่านี้ ไม่มีเหตุผลที่จะให้แอปพลิเคชันโฮสต์รวม `"blorgh/admin.css"` ในสไตล์ชีตของมัน ในสถานการณ์นี้ คุณควรกำหนดทรัพยากรเหล่านี้ไว้เพื่อการเตรียมคอมไพล์ นี่จะบอก Sprockets ให้เพิ่มทรัพยากรเอ็นจิ้นของคุณเมื่อเรียกใช้ `bin/rails assets:precompile` 

คุณสามารถกำหนดทรัพยากรเพื่อการเตรียมคอมไพล์ใน `engine.rb`:

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile += %w( admin.js admin.css )
end
```

สำหรับข้อมูลเพิ่มเติม อ่าน[คู่มือ Asset Pipeline](asset_pipeline.html)

### ความขึ้นต่อกันของ Gem Dependencies

Gem dependencies ภายในเอ็นจิ้นควรระบุในไฟล์ `.gemspec` ที่อยู่ในรากของเอ็นจิ้น สาเหตุที่เป็นเช่นนั้นคือเอ็นจิ้นอาจถูกติดตั้งเป็น gem หาก dependencies ถูกระบุใน `Gemfile` เหล่านี้จะไม่ได้รับการรู้จักจากการติดตั้ง gem แบบดั้งเดิม ดังนั้นจะไม่ได้รับการติดตั้ง ซึ่งจะทำให้เอ็นจิ้นไม่ทำงานได้อย่างถูกต้อง

ในการระบุ dependency ที่ควรติดตั้งพร้อมกับเอ็นจิ้นในการติดตั้ง gem แบบดั้งเดิม ให้ระบุในบล็อก `Gem::Specification` ภายในไฟล์ `.gemspec` ในเอ็นจิ้น:

```ruby
s.add_dependency "moo"
```

ในการระบุ dependency ที่ควรติดตั้งเฉพาะเป็น dependency ในการพัฒนาของแอปพลิเคชัน ให้ระบุดังนี้:

```ruby
s.add_development_dependency "moo"
```

ทั้งสองประเภทของ dependency จะถูกติดตั้งเมื่อเรียกใช้ `bundle install` ภายในแอปพลิเคชัน แต่ dependency ในการพัฒนาของ gem จะถูกใช้เฉพาะเมื่อมีการพัฒนาและทดสอบเอ็นจิ้น

โปรดทราบว่าหากคุณต้องการร้องขอ dependencies เมื่อเอ็นจิ้นถูกต้องควรร้องขอก่อนเอ็นจิ้นเริ่มต้น เช่น:

```ruby
require "other_engine/engine"
require "yet_another_engine/engine"

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```

การโหลดและการกำหนดค่าเฉียบของการเชื่อมต่อ
----------------------------

โค้ดของ Rails สามารถอ้างถึงได้ในขณะที่แอปพลิเคชันกำลังโหลด  Rails รับผิดชอบในการโหลดเฟรมเวิร์กเหล่านี้ ดังนั้นเมื่อคุณโหลดเฟรมเวิร์กเช่น `ActiveRecord::Base` ก่อนเวลาที่ถูกกำหนดไว้คุณกำลังละเมิดสัญญาอัตโนมัติที่แอปพลิเคชันของคุณมีกับ Rails นอกจากนี้ โดยโหลดโค้ดเช่น `ActiveRecord::Base` เมื่อแอปพลิเคชันของคุณเริ่มต้น คุณกำลังโหลดเฟรมเวิร์กทั้งหมดซึ่งอาจทำให้เวลาเริ่มต้นช้าลงและอาจทำให้เกิดข้อขัดแย้งกับการโหลดและเริ่มต้นแอปพลิเคชันของคุณ

การโหลดและการกำหนดค่าเฉียบของการเชื่อมต่อเป็น API ที่ช่วยให้คุณเชื่อมต่อกับกระบวนการเริ่มต้นนี้โดยไม่ละเมิดสัญญาการโหลดกับ Rails นี่ยังช่วยลดประสิทธิภาพการเริ่มต้นและลดความขัดแย้ง

### หลีกเลี่ยงการโหลดเฟรมเวิร์กของ Rails

เนื่องจาก Ruby เป็นภาษาแบบไดนามิก บางโค้ดจะทำให้เกิดการโหลดเฟรมเวิร์กของ Rails ที่แตกต่างกัน เช่น โค้ดตัวอย่างนี้:

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

โค้ดตัวอย่างนี้หมายความว่าเมื่อไฟล์นี้ถูกโหลด จะพบ `ActiveRecord::Base` การพบเจอนี้ทำให้ Ruby มองหาค่าคงที่นั้นและจะต้องการให้โหลดมัน ซึ่งจะทำให้โหลดเฟรมเวิร์ก Active Record ทั้งหมดในขณะที่เริ่มต้น

`ActiveSupport.on_load` เป็นกลไกที่ใช้เพื่อการโหลดโค้ดในเวลาที่จำเป็นจริง ๆ โค้ดตัวอย่างด้านบนสามารถเปลี่ยนได้เป็น:

```ruby
ActiveSupport.on_load(:active_record) do
  include MyActiveRecordHelper
end
```

โค้ดตัวอย่างใหม่นี้จะเพิ่ม `MyActiveRecordHelper` เฉพาะเมื่อ `ActiveRecord::Base` ถูกโหลดเท่านั้น

### เมื่อ Hooks ถูกเรียกใช้งาน?

ในเฟรมเวิร์กเรลส์ การเรียกใช้งาน hooks เหล่านี้จะเกิดขึ้นเมื่อไลบรารีที่ระบุถูกโหลด เช่นเมื่อ `ActionController::Base` ถูกโหลด จะเรียกใช้งาน hooks `:action_controller_base` นี้ ซึ่งหมายความว่า `ActiveSupport.on_load` ทั้งหมดที่มี hooks `:action_controller_base` จะถูกเรียกใช้งานในบริบทของ `ActionController::Base` (ซึ่งหมายความว่า `self` จะเป็น `ActionController::Base`)

### การแก้ไขโค้ดเพื่อใช้ Load Hooks

การแก้ไขโค้ดทั่วไปมักจะง่ายดาย หากคุณมีบรรทัดโค้ดที่อ้างอิงถึงเฟรมเวิร์กเรลส์เช่น `ActiveRecord::Base` คุณสามารถครอบโค้ดดังกล่าวด้วย load hook ได้

**การแก้ไขการเรียกใช้ `include`**

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

เปลี่ยนเป็น

```ruby
ActiveSupport.on_load(:active_record) do
  # self จะเป็น ActiveRecord::Base ที่นี่
  # เราสามารถเรียกใช้ .include ได้
  include MyActiveRecordHelper
end
```

**การแก้ไขการเรียกใช้ `prepend`**

```ruby
ActionController::Base.prepend(MyActionControllerHelper)
```

เปลี่ยนเป็น

```ruby
ActiveSupport.on_load(:action_controller_base) do
  # self จะเป็น ActionController::Base ที่นี่
  # เราสามารถเรียกใช้ .prepend ได้
  prepend MyActionControllerHelper
end
```

**การแก้ไขการเรียกใช้เมธอดคลาส**

```ruby
ActiveRecord::Base.include_root_in_json = true
```

เปลี่ยนเป็น

```ruby
ActiveSupport.on_load(:active_record) do
  # self จะเป็น ActiveRecord::Base ที่นี่
  self.include_root_in_json = true
end
```

### Load Hooks ที่มีให้ใช้งาน

นี่คือ load hooks ที่คุณสามารถใช้งานในโค้ดของคุณ เพื่อเชื่อมต่อกับกระบวนการเริ่มต้นของคลาสที่ระบุ

| คลาส                                | Hook                                 |
| -------------------------------------| ------------------------------------ |
| `ActionCable`                        | `action_cable`                       |
| `ActionCable::Channel::Base`         | `action_cable_channel`               |
| `ActionCable::Connection::Base`      | `action_cable_connection`            |
| `ActionCable::Connection::TestCase`  | `action_cable_connection_test_case`  |
| `ActionController::API`              | `action_controller_api`              |
| `ActionController::API`              | `action_controller`                  |
| `ActionController::Base`             | `action_controller_base`             |
| `ActionController::Base`             | `action_controller`                  |
| `ActionController::TestCase`         | `action_controller_test_case`        |
| `ActionDispatch::IntegrationTest`    | `action_dispatch_integration_test`   |
| `ActionDispatch::Response`           | `action_dispatch_response`           |
| `ActionDispatch::Request`            | `action_dispatch_request`            |
| `ActionDispatch::SystemTestCase`     | `action_dispatch_system_test_case`   |
| `ActionMailbox::Base`                | `action_mailbox`                     |
| `ActionMailbox::InboundEmail`        | `action_mailbox_inbound_email`       |
| `ActionMailbox::Record`              | `action_mailbox_record`              |
| `ActionMailbox::TestCase`            | `action_mailbox_test_case`           |
| `ActionMailer::Base`                 | `action_mailer`                      |
| `ActionMailer::TestCase`             | `action_mailer_test_case`            |
| `ActionText::Content`                | `action_text_content`                |
| `ActionText::Record`                 | `action_text_record`                 |
| `ActionText::RichText`               | `action_text_rich_text`              |
| `ActionText::EncryptedRichText`      | `action_text_encrypted_rich_text`    |
| `ActionView::Base`                   | `action_view`                        |
| `ActionView::TestCase`               | `action_view_test_case`              |
| `ActiveJob::Base`                    | `active_job`                         |
| `ActiveJob::TestCase`                | `active_job_test_case`               |
| `ActiveRecord::Base`                 | `active_record`                      |
| `ActiveRecord::TestFixtures`         | `active_record_fixtures`             |
| `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter`    | `active_record_postgresqladapter`    |
| `ActiveRecord::ConnectionAdapters::Mysql2Adapter`        | `active_record_mysql2adapter`        |
| `ActiveRecord::ConnectionAdapters::TrilogyAdapter`       | `active_record_trilogyadapter`       |
| `ActiveRecord::ConnectionAdapters::SQLite3Adapter`       | `active_record_sqlite3adapter`       |
| `ActiveStorage::Attachment`          | `active_storage_attachment`          |
| `ActiveStorage::VariantRecord`       | `active_storage_variant_record`      |
| `ActiveStorage::Blob`                | `active_storage_blob`                |
| `ActiveStorage::Record`              | `active_storage_record`              |
| `ActiveSupport::TestCase`            | `active_support_test_case`           |
| `i18n`                               | `i18n`                               |

### Available Configuration Hooks

Configuration hooks ไม่ได้เชื่อมต่อกับเฟรมเวิร์กใด ๆ โดยเฉพาะ แต่จะทำงานในบริบทของแอปพลิเคชันทั้งหมด

| Hook                   | Use Case                                                                           |
| ---------------------- | ---------------------------------------------------------------------------------- |
| `before_configuration` | บล็อกที่กำหนดค่าแรกที่จะทำงาน โดยเรียกก่อนที่จะมีการเรียกใช้งาน initializer ใด ๆ |
| `before_initialize`    | บล็อกที่กำหนดค่าที่สองที่จะทำงาน โดยเรียกก่อนที่จะมีการเริ่มต้นเฟรมเวิร์ก                |
| `before_eager_load`    | บล็อกที่กำหนดค่าที่สามที่จะทำงาน ไม่ทำงานหาก [`config.eager_load`][] ถูกตั้งค่าเป็น false |
| `after_initialize`     | บล็อกที่กำหนดค่าล่าสุดที่จะทำงาน โดยเรียกหลังจากเฟรมเวิร์กเริ่มต้นแล้ว                |
การกำหนดค่า hooks สามารถเรียกใช้ในคลาส Engine

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    config.before_configuration do
      puts 'ฉันถูกเรียกก่อนที่จะมีการเริ่มต้นใด ๆ'
    end
  end
end
```
[`config.eager_load`]: configuring.html#config-eager-load
