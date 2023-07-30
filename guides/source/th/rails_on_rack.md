**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 48f8290cbf9190673c32a3eb9777acba
เรลส์บนแร็ก
=============

เอกสารนี้เป็นคู่มือการรวมเรลส์กับแร็กและการติดต่อกับคอมโพเนนต์แร็กอื่น ๆ

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีใช้ Rack Middlewares ในแอปพลิเคชันเรลส์ของคุณ
* สแต็ก Middleware ภายในแอ็กชันแพ็ค
* วิธีกำหนดสแต็ก Middleware ที่กำหนดเอง

--------------------------------------------------------------------------------

คำเตือน: เอกสารนี้ถือว่าคุณมีความรู้พื้นฐานเกี่ยวกับโปรโตคอลแร็กและแนวคิดเกี่ยวกับแร็ก เช่น middlewares, URL maps, และ `Rack::Builder`.

แนะนำเกี่ยวกับแร็ก
--------------------

แร็กให้ส่วนติดต่อที่เล็กที่สุด แบบโมดูลและสามารถปรับเปลี่ยนได้สำหรับการพัฒนาแอปพลิเคชันเว็บใน Ruby โดยการห่อหุ้มคำขอและการตอบกลับ HTTP ในวิธีที่ง่ายที่สุด มันรวมและสกัด API สำหรับเว็บเซิร์ฟเวอร์ เฟรมเวิร์กเว็บ และซอฟต์แวร์ต่าง ๆ ระหว่าง (ที่เรียกว่า middleware)

การอธิบายวิธีการทำงานของแร็กไม่ได้อยู่ในขอบเขตของเอกสารนี้ ในกรณีที่คุณไม่คุ้นเคยกับพื้นฐานของแร็กคุณควรตรวจสอบส่วน [ทรัพยากร](#ทรัพยากร) ด้านล่าง

เรลส์บนแร็ก
-------------

### วัตถุแร็กของแอปพลิเคชันเรลส์

`Rails.application` เป็นวัตถุแอปพลิเคชันแร็กหลักของแอปพลิเคชันเรลส์ แม่แบบเว็บเซิร์ฟเวอร์แร็กใด ๆ ควรใช้วัตถุ `Rails.application` เพื่อให้บริการแอปพลิเคชันเรลส์

### `bin/rails server`

`bin/rails server` ทำงานเบื้องต้นของการสร้างวัตถุ `Rack::Server` และเริ่มเว็บเซิร์ฟเวอร์

นี่คือวิธี `bin/rails server` สร้างอินสแตนซ์ของ `Rack::Server`

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

`Rails::Server` สืบทอดมาจาก `Rack::Server` และเรียกใช้วิธี `Rack::Server#start` ดังนี้:

```ruby
class Server < ::Rack::Server
  def start
    # ...
    super
  end
end
```

### `rackup`

หากต้องการใช้ `rackup` แทน `bin/rails server` คุณสามารถใส่โค้ดต่อไปนี้ใน `config.ru` ในไดเรกทอรีรากของแอปพลิเคชันเรลส์ของคุณ:

```ruby
# Rails.root/config.ru
require_relative "config/environment"
run Rails.application
```

และเริ่มเซิร์ฟเวอร์:

```bash
$ rackup config.ru
```

หากต้องการดูข้อมูลเพิ่มเติมเกี่ยวกับตัวเลือก `rackup` คุณสามารถเรียกใช้:

```bash
$ rackup --help
```

### การพัฒนาและการโหลดอัตโนมัติ

Middlewares จะโหลดครั้งเดียวและไม่ได้ตรวจสอบการเปลี่ยนแปลง คุณต้องรีสตาร์ทเซิร์ฟเวอร์เพื่อให้การเปลี่ยนแปลงปรากฏในแอปพลิเคชันที่กำลังทำงาน

สแต็ก Middleware ของ Action Dispatcher
----------------------------------

ส่วนใหญ่ของคอมโพเนนต์ภายในของ Action Dispatcher ถูกนำมาใช้เป็น Rack middlewares `Rails::Application` ใช้ `ActionDispatch::MiddlewareStack` เพื่อรวม middlewares ภายในและภายนอกต่าง ๆ เข้าด้วยกันเพื่อสร้างแอปพลิเคชันเรลส์แบบเต็มรูปแบบ

หมายเหตุ: `ActionDispatch::MiddlewareStack` เป็นเทียบเท่าของ Rails กับ `Rack::Builder` แต่ถูกสร้างขึ้นเพื่อให้ยืดหยุ่นและมีคุณสมบัติมากขึ้นเพื่อตอบสนองต่อความต้องการของ Rails

### การตรวจสอบสแต็ก Middleware

Rails มีคำสั่งที่สะดวกสำหรับการตรวจสอบสแต็ก middleware ที่ใช้งานอยู่:

```bash
$ bin/rails middleware
```

สำหรับแอปพลิเคชันเรลส์ที่สร้างขึ้นใหม่เมื่อเร็ว ๆ นี้ อาจได้ผลลัพธ์ที่คล้ายกับนี้:

```ruby
use ActionDispatch::HostAuthorization
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
use ActionDispatch::ServerTiming
use ActiveSupport::Cache::Strategy::LocalCache::Middleware
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use ActionDispatch::RemoteIp
use Sprockets::Rails::QuietAssets
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use WebConsole::Middleware
use ActionDispatch::DebugExceptions
use ActionDispatch::ActionableExceptions
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::Migration::CheckPending
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ContentSecurityPolicy::Middleware
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
use Rack::TempfileReaper
run MyApp::Application.routes
```

Middlewares เริ่มต้นที่แสดงที่นี่ (และอื่น ๆ) จะถูกสรุปในส่วน [Internal Middlewares](#internal-middleware-stack) ด้านล่าง

### การกำหนดค่าสแต็ก Middleware

Rails ให้ส่วนกำหนดค่าง่าย [`config.middleware`][] สำหรับเพิ่ม ลบ และแก้ไข middlewares ในสแต็ก middleware ผ่าน `application.rb` หรือไฟล์กำหนดค่าสำหรับสภาพแวดล้อมที่เฉพาะเจาะจง `environments/<environment>.rb`
#### เพิ่ม Middleware

คุณสามารถเพิ่ม middleware ใหม่เข้าไปใน middleware stack โดยใช้วิธีการต่อไปนี้:

* `config.middleware.use(new_middleware, args)` - เพิ่ม middleware ใหม่ที่ด้านล่างของ middleware stack

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - เพิ่ม middleware ใหม่ก่อน middleware ที่ระบุใน middleware stack

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - เพิ่ม middleware ใหม่หลัง middleware ที่ระบุใน middleware stack

```ruby
# config/application.rb

# เพิ่ม Rack::BounceFavicon ที่ด้านล่าง
config.middleware.use Rack::BounceFavicon

# เพิ่ม Lifo::Cache หลัง ActionDispatch::Executor
# ส่งอาร์กิวเมนต์ { page_cache: false } ให้กับ Lifo::Cache
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### แทนที่ Middleware

คุณสามารถแทนที่ middleware ที่มีอยู่ใน middleware stack โดยใช้ `config.middleware.swap`.

```ruby
# config/application.rb

# แทนที่ ActionDispatch::ShowExceptions ด้วย Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### ย้าย Middleware

คุณสามารถย้าย middleware ที่มีอยู่ใน middleware stack โดยใช้ `config.middleware.move_before` และ `config.middleware.move_after`.

```ruby
# config/application.rb

# ย้าย ActionDispatch::ShowExceptions ไปก่อน Lifo::ShowExceptions
config.middleware.move_before Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

```ruby
# config/application.rb

# ย้าย ActionDispatch::ShowExceptions ไปหลัง Lifo::ShowExceptions
config.middleware.move_after Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

#### ลบ Middleware

เพิ่มบรรทัดต่อไปนี้ในการกำหนดค่าแอปพลิเคชันของคุณ:

```ruby
# config/application.rb
config.middleware.delete Rack::Runtime
```

และตอนนี้หากคุณตรวจสอบ middleware stack คุณจะพบว่า `Rack::Runtime` ไม่ได้เป็นส่วนหนึ่งของมัน.

```bash
$ bin/rails middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
...
run Rails.application.routes
```

หากคุณต้องการลบ middleware เกี่ยวกับ session ทำตามขั้นตอนต่อไปนี้:

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash
```

และเพื่อลบ middleware เกี่ยวกับเบราว์เซอร์,

```ruby
# config/application.rb
config.middleware.delete Rack::MethodOverride
```

หากคุณต้องการให้เกิดข้อผิดพลาดเมื่อคุณพยายามลบรายการที่ไม่มีอยู่ใช้ `delete!` แทน.

```ruby
# config/application.rb
config.middleware.delete! ActionDispatch::Executor
```

### Internal Middleware Stack

ฟังก์ชันหลักของ Action Controller ถูกนำมาใช้เป็น Middlewares ดังต่อไปนี้:

**`ActionDispatch::HostAuthorization`**

* ป้องกันการโจมตี DNS rebinding โดยอนุญาตเฉพาะโฮสต์ที่สามารถส่งคำขอได้ ดูคำแนะนำในการกำหนดค่าได้ที่ [configuration guide](configuring.html#actiondispatch-hostauthorization).

**`Rack::Sendfile`**

* ตั้งค่าเซิร์ฟเวอร์ให้มีส่วนหัว X-Sendfile ที่เฉพาะเจาะจง กำหนดค่านี้ผ่านตัวเลือก [`config.action_dispatch.x_sendfile_header`][].

**`ActionDispatch::Static`**

* ใช้ในการให้บริการไฟล์สถิติจากไดเรกทอรี public ถูกปิดใช้งานหาก [`config.public_file_server.enabled`][] เป็น `false`.

**`Rack::Lock`**

* ตั้งค่า `env["rack.multithread"]` เป็น `false` และห่อแอปพลิเคชันด้วย Mutex.

**`ActionDispatch::Executor`**

* ใช้สำหรับการโหลดโค้ดในรูปแบบที่ปลอดภัยสำหรับการพัฒนา.

**`ActionDispatch::ServerTiming`**

* ตั้งค่าส่วนหัว [`Server-Timing`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server-Timing) ที่มีข้อมูลเกี่ยวกับประสิทธิภาพของคำขอ.

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* ใช้สำหรับการเก็บแคชในหน่วยความจำ แคชนี้ไม่ปลอดภัยในกรณีใช้งานหลายเธรด.

**`Rack::Runtime`**

* ตั้งค่าส่วนหัว X-Runtime ที่มีเวลา (เป็นวินาที) ที่ใช้ในการประมวลผลคำขอ.

**`Rack::MethodOverride`**

* อนุญาตให้แก้ไขวิธีการหากตั้งค่า `params[:_method]` ถูกตั้งค่า นี่คือ middleware ที่รองรับวิธีการ HTTP แบบ PUT และ DELETE.

**`ActionDispatch::RequestId`**

* ทำให้สามารถใช้งาน `X-Request-Id` ที่ไม่ซ้ำกันในส่วนหัวของการตอบสนองและเปิดใช้งานเมธอด `ActionDispatch::Request#request_id`.

**`ActionDispatch::RemoteIp`**

* ตรวจสอบการโจมตี IP spoofing.

**`Sprockets::Rails::QuietAssets`**

* ยับยั้งการแสดงผลของล็อกเกอร์สำหรับคำขอทรัพยากร.

**`Rails::Rack::Logger`**

* แจ้งให้ล็อกทราบว่าคำขอเริ่มต้นแล้ว หลังจากคำขอเสร็จสิ้น จะล้างล็อกทั้งหมด.

**`ActionDispatch::ShowExceptions`**

* ช่วยแก้ไขข้อผิดพลาดที่ถูกส่งกลับจากแอปพลิเคชันและเรียกใช้แอปที่จัดรูปให้เหมาะสมสำหรับผู้ใช้สุดท้าย.
**`ActionDispatch::DebugExceptions`**

* รับผิดชอบในการบันทึกข้อผิดพลาดและแสดงหน้าต่างการแก้ปัญหาในกรณีที่คำขอเป็นท้องถิ่น

**`ActionDispatch::ActionableExceptions`**

* ให้วิธีการส่งการกระทำจากหน้าข้อผิดพลาดของ Rails

**`ActionDispatch::Reloader`**

* ให้การเตรียมและล้างคำขอสำหรับการโหลดโค้ดในระหว่างการพัฒนา

**`ActionDispatch::Callbacks`**

* ให้การเรียกใช้งานก่อนและหลังการส่งคำขอ

**`ActiveRecord::Migration::CheckPending`**

* ตรวจสอบการโยกย้ายที่รอดำเนินการและเรียก `ActiveRecord::PendingMigrationError` ถ้ามีการโยกย้ายที่รอดำเนินการ

**`ActionDispatch::Cookies`**

* ตั้งค่าคุกกี้สำหรับคำขอ

**`ActionDispatch::Session::CookieStore`**

* รับผิดชอบในการเก็บรักษาเซสชันในคุกกี้

**`ActionDispatch::Flash`**

* ตั้งค่าคีย์แฟลช สามารถใช้ได้เฉพาะเมื่อ [`config.session_store`][] ถูกตั้งค่าเป็นค่า

**`ActionDispatch::ContentSecurityPolicy::Middleware`**

* ให้ DSL เพื่อกำหนดค่าส่วนหัว Content-Security-Policy

**`Rack::Head`**

* แปลงคำขอ HEAD เป็นคำขอ `GET` และให้บริการเป็นเช่นนั้น

**`Rack::ConditionalGet`**

* เพิ่มการสนับสนุน "Conditional `GET`" เพื่อให้เซิร์ฟเวอร์ตอบกลับโดยไม่มีอะไรถ้าหน้าเว็บไม่เปลี่ยนแปลง

**`Rack::ETag`**

* เพิ่มส่วนหัว ETag ใน String bodies ทั้งหมด ETag ใช้สำหรับการตรวจสอบแคช

**`Rack::TempfileReaper`**

* ทำความสะอาดไฟล์ชั่วคราวที่ใช้เพื่อเก็บข้อมูลคำขอแบบหลายส่วน

เคล็ดลับ: คุณสามารถใช้ Middleware ใดก็ได้จากที่กล่าวมาข้างต้นใน Rack stack ที่กำหนดเองได้

ทรัพยากร
---------

### เรียนรู้เกี่ยวกับ Rack

* [เว็บไซต์ Rack อย่างเป็นทางการ](https://rack.github.io)
* [การแนะนำ Rack](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### เข้าใจเกี่ยวกับ Middlewares

* [Railscast เกี่ยวกับ Rack Middlewares](http://railscasts.com/episodes/151-rack-middleware)
[`config.middleware`]: configuring.html#config-middleware
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.session_store`]: configuring.html#config-session-store
