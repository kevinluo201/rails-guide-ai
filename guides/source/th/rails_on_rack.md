**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 48f8290cbf9190673c32a3eb9777acba
เรลส์บนแพลตฟอร์มแร็ก
=============

เอกสารนี้เป็นเกี่ยวกับการรวมเรลส์กับแร็กและการติดต่อกับคอมโพเนนต์แร็กอื่น ๆ

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีใช้ Rack Middlewares ในแอปพลิเคชันเรลส์ของคุณ
* สแต็ก Middleware ภายในแอคชันแพ็ค
* วิธีกำหนดสแต็ก Middleware ที่กำหนดเอง

--------------------------------------------------------------------------------

คำเตือน: เอกสารนี้ถือว่าคุณมีความรู้พื้นฐานเกี่ยวกับโปรโตคอลแร็กและแนวคิดเกี่ยวกับแร็กเช่น middlewares, URL maps, และ `Rack::Builder`.

แนะนำเกี่ยวกับแร็ก
--------------------

แร็กให้ส่วนต่อประสานการทำงานของแอปพลิเคชันเว็บในรูปแบบที่เล็กที่สุดและสามารถปรับเปลี่ยนได้ในภาษา Ruby โดยการห่อหุ้มคำขอและคำตอบ HTTP ในวิธีที่ง่ายที่สุดเพื่อรวมและสกัด API สำหรับเว็บเซิร์ฟเวอร์ เฟรมเวิร์กเกอร์ และซอฟต์แวร์ต่าง ๆ ที่อยู่ระหว่างนั้น (ที่เรียกว่า middleware)

การอธิบายวิธีการทำงานของแร็กไม่ได้อยู่ในขอบเขตของเอกสารนี้ หากคุณไม่คุ้นเคยกับพื้นฐานของแร็กคุณควรตรวจสอบส่วน [ทรัพยากร](#ทรัพยากร) ด้านล่าง

เรลส์บนแร็ก
-------------

### อ็อบเจกต์แร็กของแอปพลิเคชันเรลส์

`Rails.application` เป็นอ็อบเจกต์แอปพลิเคชันแร็กหลักของแอปพลิเคชันเรลส์ แม่แบบเว็บเซิร์ฟเวอร์ที่เป็นไปตามมาตรฐานแร็กควรใช้อ็อบเจกต์ `Rails.application` เพื่อให้บริการแอปพลิเคชันเรลส์

### `bin/rails server`

`bin/rails server` ทำงานเบื้องต้นของการสร้างอ็อบเจกต์ `Rack::Server` และเริ่มเว็บเซิร์ฟเวอร์

นี่คือวิธีที่ `bin/rails server` สร้างอ็อบเจกต์ `Rack::Server`

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

`Rails::Server` สืบทอดมาจาก `Rack::Server` และเรียกใช้เมธอด `Rack::Server#start` ดังนี้:

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

หากต้องการดูข้อมูลเพิ่มเติมเกี่ยวกับตัวเลือก `rackup` คุณสามารถรัน:

```bash
$ rackup --help
```

### การพัฒนาและการโหลดอัตโนมัติ

Middlewares จะถูกโหลดครั้งเดียวและไม่ได้รับการตรวจสอบเพื่อดูว่ามีการเปลี่ยนแปลงหรือไม่ คุณต้องรีสตาร์ทเซิร์ฟเวอร์เพื่อให้การเปลี่ยนแปลงปรากฏในแอปพลิเคชันที่กำลังทำงาน

สแต็ก Middleware ของแอคชันดิสพาตเชอร์
----------------------------------

ส่วนใหญ่ของคอมโพเนนต์ภายในของแอคชันดิสพาตเชอร์ถูกนำมาใช้เป็น Rack middlewares `Rails::Application` ใช้ `ActionDispatch::MiddlewareStack` เพื่อรวม middlewares ภายในและภายนอกต่าง ๆ เข้าด้วยกันเพื่อสร้างแอปพลิเคชันเรลส์แบบเต็มรูปแบบ

หมายเหตุ: `ActionDispatch::MiddlewareStack` เป็นเทียบเท่ากับ `Rack::Builder` ของเรลส์ แต่ถูกสร้างขึ้นเพื่อให้ยืดหยุ่นและมีคุณสมบัติเพิ่มเติมเพื่อตอบสนองต่อความต้องการของเรลส์

### การตรวจสอบสแต็ก Middleware

เรลส์มีคำสั่งที่มีประโยชน์สำหรับการตรวจสอบสแต็ก middleware ที่ใช้งาน:

```bash
$ bin/rails middleware
```

สำหรับแอปพลิเคชันเรลส์ที่สร้างขึ้นใหม่ อาจแสดงผลเช่นนี้:

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

Middlewares เริ่มต้นที่แสดงที่นี่ (และอื่น ๆ) จะถูกสรุปไว้ในส่วน [Internal Middlewares](#internal-middleware-stack) ด้านล่าง

### การกำหนดค่าสแต็ก Middleware

เรลส์มีอินเตอร์เฟซการกำหนดค่าที่เรียบง่าย [`config.middleware`][] เพื่อเพิ่ม ลบ และแก้ไข middlewares ในสแต็ก middleware ผ่าน `application.rb` หรือไฟล์กำหนดค่าสำหรับสภาพแวดล้อมที่เฉพาะเจาะจง `environments/<environment>.rb`


#### เพิ่ม Middleware

คุณสามารถเพิ่ม middleware ใหม่ในสแต็ก middleware โดยใช้วิธีใดวิธีหนึ่งต่อไปนี้:

* `config.middleware.use(new_middleware, args)` - เพิ่ม middleware ใหม่ที่ด้านล่างสุดของสแต็ก middleware

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - เพิ่ม middleware ใหม่ก่อน middleware ที่ระบุที่มีอยู่ในสแต็ก middleware

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - เพิ่ม middleware ใหม่หลังจาก middleware ที่ระบุที่มีอยู่ในสแต็ก middleware

```ruby
# config/application.rb

# เพิ่ม Rack::BounceFavicon ที่ด้านล่างสุด
config.middleware.use Rack::BounceFavicon

# เพิ่ม Lifo::Cache หลังจาก ActionDispatch::Executor
# ส่งอาร์กิวเมนต์ { page_cache: false } ไปยัง Lifo::Cache
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### การสลับ Middleware

คุณสามารถสลับ middleware ที่มีอยู่ใน middleware stack โดยใช้ `config.middleware.swap`.

```ruby
# config/application.rb

# แทนที่ ActionDispatch::ShowExceptions ด้วย Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### การย้าย Middleware

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

#### การลบ Middleware

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

หากคุณต้องการลบ middleware เกี่ยวกับ session ให้ทำตามขั้นตอนต่อไปนี้:

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash
```

และหากคุณต้องการลบ middleware เกี่ยวกับเบราว์เซอร์,

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

* ป้องกันการโจมตี DNS rebinding โดยอนุญาตโฮสต์ที่ร้องขอสามารถส่งไปได้ ดูเพิ่มเติมใน[คู่มือการกำหนดค่า](configuring.html#actiondispatch-hostauthorization) เพื่อคำแนะนำในการกำหนดค่า

**`Rack::Sendfile`**

* ตั้งค่าเซิร์ฟเวอร์เฉพาะสำหรับส่วนหัว X-Sendfile กำหนดค่านี้ผ่าน [`config.action_dispatch.x_sendfile_header`][]

**`ActionDispatch::Static`**

* ใช้ในการให้บริการไฟล์สถิติจากไดเรกทอรี public ถูกปิดใช้งานหาก [`config.public_file_server.enabled`][] เป็น `false`

**`Rack::Lock`**

* ตั้งค่า `env["rack.multithread"]` เป็น `false` และห่อแอปพลิเคชันด้วย Mutex

**`ActionDispatch::Executor`**

* ใช้สำหรับการโหลดโค้ดที่ปลอดภัยในระหว่างการพัฒนา

**`ActionDispatch::ServerTiming`**

* ตั้งค่าเฮดเดอร์ [`Server-Timing`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server-Timing) ที่มีประสิทธิภาพสำหรับคำขอ

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* ใช้สำหรับการเก็บแคชในหน่วยความจำ แคชนี้ไม่ปลอดภัยในกรณีมีการใช้งานหลายเธรด

**`Rack::Runtime`**

* ตั้งค่าเฮดเดอร์ X-Runtime ที่มีเวลา (เป็นวินาที) ที่ใช้ในการประมวลผลคำขอ

**`Rack::MethodOverride`**

* อนุญาตให้แก้ไขวิธีการหากตั้งค่า `params[:_method]` ถูกตั้งค่า นี่คือ middleware ที่รองรับวิธีการ HTTP ประเภท PUT และ DELETE

**`ActionDispatch::RequestId`**

* ทำให้เฮดเดอร์ `X-Request-Id` ที่ไม่ซ้ำกันสามารถใช้งานได้ในการตอบสนองและเปิดใช้งานเมธอด `ActionDispatch::Request#request_id`

**`ActionDispatch::RemoteIp`**

* ตรวจสอบการโจมตี IP spoofing

**`Sprockets::Rails::QuietAssets`**

* ยับยั้งการแสดงผลของล็อกสำหรับคำขอทรัพยากร

**`Rails::Rack::Logger`**

* แจ้งให้ล็อกทราบว่าคำขอเริ่มต้นแล้ว หลังจากคำขอเสร็จสิ้น จะล้างล็อกทั้งหมด

**`ActionDispatch::ShowExceptions`**

* ช่วยแก้ไขข้อผิดพลาดที่แอปพลิเคชันส่งกลับและเรียกใช้แอปข้อยกเว้นที่จะห่อหุ้มในรูปแบบสำหรับผู้ใช้งานสุดท้าย

**`ActionDispatch::DebugExceptions`**

* รับผิดชอบในการล็อกข้อผิดพลาดและแสดงหน้าต่างการแก้ไขข้อผิดพลาดในกรณีที่คำขอเป็นท้องถิ่น

**`ActionDispatch::ActionableExceptions`**

* ให้วิธีการส่งต่อการกระทำจากหน้าข้อผิดพลาดของ Rails

**`ActionDispatch::Reloader`**

* ให้การเตรียมการและการล้างค่าย่อย ที่จะช่วยในการโหลดโค้ดในระหว่างการพัฒนา

**`ActionDispatch::Callbacks`**

* ให้การเรียกใช้งานก่อนและหลังการส่งคำขอ

**`ActiveRecord::Migration::CheckPending`**

* ตรวจสอบการเคลื่อนย้ายที่รอดำเนินการและเรียก `ActiveRecord::PendingMigrationError` หากมีการเคลื่อนย้ายที่รอดำเนินการ

**`ActionDispatch::Cookies`**

* ตั้งค่าคุกกี้สำหรับคำขอ

**`ActionDispatch::Session::CookieStore`**

* รับผิดชอบในการเก็บข้อมูลเซสชันในคุกกี้

**`ActionDispatch::Flash`**

* ตั้งค่าคีย์แฟลช สามารถใช้ได้เฉพาะหาก [`config.session_store`][] ถูกตั้งค่าเป็นค่า

**`ActionDispatch::ContentSecurityPolicy::Middleware`**

* ให้ DSL เพื่อกำหนดค่าเฮดเดอร์ Content-Security-Policy

**`Rack::Head`**

* แปลงคำขอ HEAD เป็นคำขอ GET และให้บริการเป็นเช่นนั้น

**`Rack::ConditionalGet`**

* เพิ่มการสนับสนุน "Conditional `GET`" เพื่อให้เซิร์ฟเวอร์ตอบสนองโดยไม่มีอะไรถ้าหน้าเว็บไม่เปลี่ยนแปลง

**`Rack::ETag`**

* เพิ่มเฮดเดอร์ ETag บนเนื้อหาข้อความทั้งหมด ETag ใช้สำหรับการตรวจสอบแคช

**`Rack::TempfileReaper`**

* ทำความสะอาด tempfiles ที่ใช้ในการเก็บข้อมูลคำขอแบบมาตรฐาน

เคล็ดลับ: คุณสามารถใช้ middlewares ด้านบนในสแต็ก Rack ที่กำหนดเองได้
ทรัพยากร

### เรียนรู้ Rack

* [เว็บไซต์ Rack อย่างเป็นทางการ](https://rack.github.io)
* [การแนะนำ Rack](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### เข้าใจ Middlewares

* [Railscast เกี่ยวกับ Rack Middlewares](http://railscasts.com/episodes/151-rack-middleware)
[`config.middleware`]: configuring.html#config-middleware
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.session_store`]: configuring.html#config-session-store
