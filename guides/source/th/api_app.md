**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fe858c0828e87f595c5d8c23c4b6326e
การใช้ Rails สำหรับแอปพลิเคชัน API เท่านั้น
=====================================

ในคู่มือนี้คุณจะได้เรียนรู้:

* สิ่งที่ Rails มีให้สำหรับแอปพลิเคชัน API เท่านั้น
* วิธีการกำหนดค่า Rails เพื่อเริ่มต้นโดยไม่มีคุณสมบัติของเบราว์เซอร์
* วิธีการตัดสินใจว่าคุณจะต้องการรวม middleware ใด
* วิธีการตัดสินใจว่าคุณจะใช้โมดูลใดในคอนโทรลเลอร์ของคุณ

--------------------------------------------------------------------------------

แอปพลิเคชัน API คืออะไร?
---------------------------

ในอดีตเมื่อคนพูดถึงการใช้ Rails เป็น "API" พวกเขาหมายถึงการให้บริการ API ที่สามารถเข้าถึงได้โดยโปรแกรมรวมกับแอปพลิเคชันเว็บของพวกเขา ตัวอย่างเช่น GitHub ให้บริการ [API](https://developer.github.com) ที่คุณสามารถใช้ได้จากไคลเอ็นต์ที่กำหนดเอง

ด้วยการเกิดขึ้นของเฟรมเวิร์กด้านไคลเอ็นต์ นักพัฒนามากขึ้นกำลังใช้ Rails เพื่อสร้างแอปพลิเคชันด้านหลังที่ใช้ร่วมกันกับแอปพลิเคชันเว็บและแอปพลิเคชันเกิดขึ้น

ตัวอย่างเช่น Twitter ใช้ [public API](https://developer.twitter.com/) ในแอปพลิเคชันเว็บของตน ซึ่งถูกสร้างเป็นไซต์สถิตที่ใช้แหล่งข้อมูล JSON

แทนที่จะใช้ Rails เพื่อสร้าง HTML ที่สื่อสารกับเซิร์ฟเวอร์ผ่านฟอร์มและลิงก์ นักพัฒนามากขึ้นกำลังจะใช้แอปพลิเคชันเว็บของพวกเขาเป็นเพียงไคลเอ็นต์ API ที่ส่งมอบเป็น HTML พร้อมกับ JavaScript ที่ใช้แหล่งข้อมูล JSON API

คู่มือนี้เป็นการสร้างแอปพลิเคชัน Rails ที่ให้บริการแหล่งข้อมูล JSON ให้กับไคลเอ็นต์ API รวมถึงเฟรมเวิร์กด้านไคลเอ็นต์

ทำไมถึงใช้ Rails สำหรับ JSON API?
----------------------------

คำถามแรกที่คนส่วนใหญ่มักจะมีเมื่อคิดถึงการสร้าง JSON API โดยใช้ Rails คือ: "การใช้ Rails เพื่อสร้าง JSON ไม่ได้มีความเหมาะสมหรือไม่? ไม่ควรใช้สิ่งเช่น Sinatra เพียงอย่างเดียว?" 

สำหรับ API ที่ง่ายมาก อาจจะเป็นจริง อย่างไรก็ตาม แม้แต่ในแอปพลิเคชันที่มี HTML มากมาย ส่วนใหญ่ของตัวแอปพลิเคชันจะอยู่นอกเลเยอร์ของมุมมอง

เหตุผลที่คนส่วนใหญ่ใช้ Rails คือมันมีค่าเริ่มต้นที่ช่วยให้นักพัฒนาสามารถเริ่มต้นและทำงานได้อย่างรวดเร็วโดยไม่ต้องตัดสินใจเล็กน้อย

มาลองดูบางสิ่งที่ Rails มีให้เริ่มต้นที่เป็นไปได้ที่สุดที่ยังเกี่ยวข้องกับแอปพลิเคชัน API

จัดการที่เลเยอร์ middleware:

- การโหลดซ้ำ: แอปพลิเคชัน Rails รองรับการโหลดซ้ำโดยเป็นโปร่งใส นี้ยังทำงานได้แม้แอปพลิเคชันของคุณจะใหญ่ขึ้นและการเริ่มต้นเซิร์ฟเวอร์สำหรับทุกคำขอกลายเป็นสิ่งที่ไม่เป็นไปตามกฎหมาย
- โหมดการพัฒนา: แอปพลิเคชัน Rails มาพร้อมกับค่าเริ่มต้นที่เป็นสมาร์ทสำหรับการพัฒนา ทำให้การพัฒนาเป็นสิ่งที่น่าพอใจโดยไม่เสียประสิทธิภาพในเวลาที่ใช้ในการผลิต
- โหมดการทดสอบ: เช่นเดียวกับโหมดการพัฒนา
- การบันทึก: แอปพลิเคชัน Rails บันทึกทุกคำขอพร้อมระดับความสมบูรณ์ที่เหมาะสมสำหรับโหมดปัจจุบัน บันทึก Rails ในโหมดการพัฒนารวมถึงข้อมูลเกี่ยวกับสภาพแวดล้อมของคำขอ คำสั่งค้นฐานข้อมูล และข้อมูลเกี่ยวกับประสิทธิภาพพื้นฐาน
- ความปลอดภัย: Rails ตรวจจับและป้องกันการโจมตี [IP spoofing
  attacks](https://en.wikipedia.org/wiki/IP_address_spoofing) และจัดการ
  ลายเซ็นทางคริปโตกราฟใน [timing
  attack](https://en.wikipedia.org/wiki/Timing_attack) โดยมีความตระหนักถึงวิธีการโจมตี IP spoofing หรือ timing attack หรือไม่รู้? แน่นอน
- การแยกวิเคราะห์พารามิเตอร์: ต้องการระบุพารามิเตอร์ของคุณเป็น JSON แทนที่เป็นสตริงที่เข้ารหัสด้วย URL? ไม่มีปัญหา Rails จะถอดรหัส JSON ให้คุณและทำให้พร้อมใช้งานใน `params` ต้องการใช้พารามิเตอร์ที่เข้ารหัสเป็น URL ที่ซ้อนกัน? นั่นก็ทำงานได้
- การร้องขอ GET เงื่อนไข: Rails จัดการการร้องขอ GET เงื่อนไข (`ETag` และ `Last-Modified`) การประมวลผลส่วนของส่วนหัวของคำขอและการส่งคืนส่วนหัวและสถานะที่ถูกต้อง ที่คุณต้องทำคือใช้
  [`stale?`](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F)
  เช็คในคอนโทรลเลอร์ของคุณและ Rails จะจัดการรายละเอียด HTTP ทั้งหมดให้คุณ
- การร้องขอ HEAD: Rails จะแปลงคำขอ HEAD เป็นคำขอ GET โดยโปร่งใสและส่งคืนเฉพาะส่วนหัวเท่านั้น ซึ่งทำให้การทำงานของ HEAD ทำงานได้อย่างเสถียรใน API ทั้งหมด
แม้ว่าคุณสามารถสร้างส่วนเสริม Rack ขึ้นมาใช้ได้ แต่รายการนี้แสดงให้เห็นว่าชุด middleware ตั้งต้นของ Rails มีคุณค่ามากมาย แม้ว่าคุณจะ "เพียงสร้าง JSON" เท่านั้น

จัดการที่เลเยอร์ Action Pack:

- Resourceful Routing: หากคุณกำลังสร้าง RESTful JSON API คุณต้องใช้ตัวเราท์เตอร์ของ Rails การแมปที่สะอาดและเป็นไปตามปกติจาก HTTP ไปยังคอนโทรลเลอร์ หมายความว่าคุณไม่ต้องใช้เวลาคิดถึงวิธีจัดโครง API ของคุณในทาง HTTP
- URL Generation: ด้านตรงข้ามของการเรียกใช้เราท์เตอร์คือการสร้าง URL การใช้งาน API ที่ดีที่สุดตาม HTTP รวมถึง URL (ดู [the GitHub Gist API](https://docs.github.com/en/rest/reference/gists) เป็นตัวอย่าง)
- การตอบสนองเฮดเดอร์และการเปลี่ยนเส้นทาง: `head :no_content` และ `redirect_to user_url(current_user)` มีประโยชน์ แน่นอนคุณสามารถเพิ่มเฮดเดอร์ตอบสนองด้วยตนเอง แต่ทำไมต้องทำเช่นนั้น?
- การเก็บแคช: Rails มีการเก็บแคชหน้า แคชแอ็กชัน และแคชฟรากเมนต์ การเก็บแคชฟรากเมนต์มีประโยชน์มากโดยเฉพาะเมื่อสร้างวัตถุ JSON ที่ซ้อนกัน
- การรับรองความถูกต้องของการรับรองความปลอดภัยแบบพื้นฐาน การรับรองความถูกต้องของการรับรองความปลอดภัยแบบ Digest และการรับรองความถูกต้องของการรับรองความปลอดภัยแบบ Token มาพร้อมกับ Rails โดยอัตโนมัติ
- การตรวจวัด: Rails มี API การตรวจวัดที่เรียกใช้ตัวจัดการที่ลงทะเบียนสำหรับเหตุการณ์ต่าง ๆ เช่นการประมวลผลแอ็กชัน การส่งไฟล์หรือข้อมูล การเปลี่ยนเส้นทาง และการค้นหาฐานข้อมูล ข้อมูลเพลาของแต่ละเหตุการณ์มาพร้อมกับข้อมูลที่เกี่ยวข้อง (สำหรับเหตุการณ์การประมวลผลแอ็กชัน เพลาข้อมูลรวมถึงคอนโทรลเลอร์ แอ็กชัน พารามิเตอร์ รูปแบบคำขอ วิธีคำขอ และเส้นทางเต็มของคำขอ)
- ตัวสร้าง: มันมักจะเป็นประโยชน์ที่จะสร้างทรัพยากรและรับโมเดลคอนโทรลเลอร์ สแต็บการทดสอบ และเส้นทางที่สร้างขึ้นสำหรับคุณในคำสั่งเดียวสำหรับการปรับแต่งเพิ่มเติม สำหรับการเรียกใช้งานและอื่น ๆ
- ปลั๊กอิน: ห้องสมุดของบุคคลที่สามมาพร้อมกับการสนับสนุน Rails ที่ลดหรือไม่ต้องเสียค่าใช้จ่ายในการตั้งค่าและเชื่อมต่อระหว่างห้องสมุดและเฟรมเวิร์กเว็บ ซึ่งรวมถึงสิ่งที่เกี่ยวข้องกับการแทนที่ตัวสร้างเริ่มต้น เพิ่มงาน Rake และยอมรับการเลือกของ Rails (เช่นตัวบันทึกและแคชแบ็กเอนด์)

แน่นอนว่ากระบวนการเริ่มต้นของ Rails ยังเชื่อมต่อส่วนประกอบที่ลงทะเบียนทั้งหมด เช่นกระบวนการเริ่มต้นของ Rails คือสิ่งที่ใช้ `config/database.yml` ของคุณเมื่อกำหนดค่า Active Record

**สรุปแบบสั้น ๆ คือ**: คุณอาจไม่ได้คิดถึงส่วนใดของ Rails ที่ยังเป็นที่น่าสนใจแม้ว่าคุณจะลบชั้นมุมมองออก แต่คำตอบกลับมากกว่าที่คุณคาดหวัง

การกำหนดค่าพื้นฐาน
-----------------------

หากคุณกำลังสร้างแอปพลิเคชัน Rails ที่เป็นเซิร์ฟเวอร์ API ก่อนอื่น คุณสามารถเริ่มต้นด้วยชุดย่อยของ Rails และเพิ่มคุณลักษณะตามที่ต้องการ

### สร้างแอปพลิเคชันใหม่

คุณสามารถสร้างแอปพลิเคชัน Rails แบบ api ใหม่ได้:

```bash
$ rails new my_api --api
```

สิ่งที่มันจะทำสามสิ่งหลักสำหรับคุณ:

- กำหนดค่าแอปพลิเคชันของคุณให้เริ่มต้นด้วยชุดย่อยที่จำกัดมากกว่าปกติ โดยเฉพาะอย่างยิ่งจะไม่รวมมิดเดิลแวร์ที่มีประโยชน์โดยส่วนใหญ่สำหรับแอปพลิเคชันเบราว์เซอร์ (เช่นการรองรับคุกกี้) เป็นค่าเริ่มต้น
- ทำให้ `ApplicationController` สืบทอดจาก `ActionController::API` แทนที่จะสืบทอดจาก `ActionController::Base` เช่นเดียวกับมิดเดิลแวร์ นี้จะไม่รวมโมดูล Action Controller ใด ๆ ที่ให้ฟังก์ชันที่ใช้โดยส่วนใหญ่สำหรับแอปพลิเคชันเบราว์เซอร์
- กำหนดค่าตัวสร้างให้ข้ามการสร้างมุมมอง เฮลเปอร์ และส่วนช่วยเหลือเมื่อคุณสร้างทรัพยากรใหม่
### สร้างทรัพยากรใหม่

เพื่อดูว่า API ที่เราสร้างขึ้นใหม่มีการจัดการทรัพยากรใหม่อย่างไร ให้เราสร้างทรัพยากรกลุ่มใหม่ โดยแต่ละกลุ่มจะมีชื่อ

```bash
$ bin/rails g scaffold Group name:string
```

ก่อนที่เราจะใช้โค้ดที่สร้างขึ้นมา เราต้องอัปเดตแผนฐานข้อมูลก่อน

```bash
$ bin/rails db:migrate
```

ตอนนี้ถ้าเราเปิด `GroupsController` เราควรสังเกตุว่าในแอป Rails แบบ API เราจะแสดงข้อมูล JSON เท่านั้น ในการดึงข้อมูลทั้งหมดของกลุ่มเราจะใช้คำสั่ง `Group.all` และกำหนดให้เป็นตัวแปรอินสแตนซ์ชื่อ `@groups` โดยการส่งตัวแปรนี้ไปยัง `render` พร้อมกับตัวเลือก `:json` จะทำให้ข้อมูลกลุ่มถูกแสดงเป็น JSON โดยอัตโนมัติ

```ruby
# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show update destroy ]

  # GET /groups
  def index
    @groups = Group.all

    render json: @groups
  end

  # GET /groups/1
  def show
    render json: @group
  end

  # POST /groups
  def create
    @group = Group.new(group_params)

    if @group.save
      render json: @group, status: :created, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name)
    end
end
```

สุดท้าย เราสามารถเพิ่มกลุ่มบางกลุ่มลงในฐานข้อมูลของเราจากคอนโซล Rails ได้:

```irb
irb> Group.create(name: "Rails Founders")
irb> Group.create(name: "Rails Contributors")
```

กับข้อมูลบางส่วนในแอป เราสามารถเปิดเซิร์ฟเวอร์และเข้าชม <http://localhost:3000/groups.json> เพื่อดูข้อมูล JSON ของเรา

```json
[
{"id":1, "name":"Rails Founders", "created_at": ...},
{"id":2, "name":"Rails Contributors", "created_at": ...}
]
```

### เปลี่ยนแปลงแอปพลิเคชันที่มีอยู่

หากคุณต้องการเอาแอปพลิเคชันที่มีอยู่และทำให้เป็นแอปพลิเคชัน API อ่านขั้นตอนต่อไปนี้

ใน `config/application.rb` เพิ่มบรรทัดต่อไปนี้ไว้ที่ด้านบนของคลาส `Application`:

```ruby
config.api_only = true
```

ใน `config/environments/development.rb` ตั้งค่า [`config.debug_exception_response_format`][]
เพื่อกำหนดรูปแบบที่ใช้ในการตอบสนองเมื่อเกิดข้อผิดพลาดในโหมดการพัฒนา

ในการแสดงหน้า HTML พร้อมข้อมูลการแก้ปัญหาใช้ค่า `:default`

```ruby
config.debug_exception_response_format = :default
```

ในการแสดงข้อมูลการแก้ปัญหาโดยรักษารูปแบบการตอบสนองใช้ค่า `:api`

```ruby
config.debug_exception_response_format = :api
```

โดยค่าเริ่มต้น `config.debug_exception_response_format` ถูกตั้งค่าเป็น `:api` เมื่อ `config.api_only` ถูกตั้งค่าเป็น true

สุดท้าย ใน `app/controllers/application_controller.rb` แทนที่:

```ruby
class ApplicationController < ActionController::Base
end
```

ด้วย:

```ruby
class ApplicationController < ActionController::API
end
```


การเลือก Middleware
--------------------

แอปพลิเคชัน API มาพร้อมกับ Middleware ต่อไปนี้โดยค่าเริ่มต้น:

- `ActionDispatch::HostAuthorization`
- `Rack::Sendfile`
- `ActionDispatch::Static`
- `ActionDispatch::Executor`
- `ActionDispatch::ServerTiming`
- `ActiveSupport::Cache::Strategy::LocalCache::Middleware`
- `Rack::Runtime`
- `ActionDispatch::RequestId`
- `ActionDispatch::RemoteIp`
- `Rails::Rack::Logger`
- `ActionDispatch::ShowExceptions`
- `ActionDispatch::DebugExceptions`
- `ActionDispatch::ActionableExceptions`
- `ActionDispatch::Reloader`
- `ActionDispatch::Callbacks`
- `ActiveRecord::Migration::CheckPending`
- `Rack::Head`
- `Rack::ConditionalGet`
- `Rack::ETag`

ดูเพิ่มเติมเกี่ยวกับ Middleware ภายในได้ที่ [internal middleware](rails_on_rack.html#internal-middleware-stack)
ในเอกสารเกี่ยวกับ Rack

ปลั๊กอินอื่น ๆ รวมถึง Active Record อาจเพิ่ม Middleware เพิ่มเติมได้ โดยทั่วไป Middleware เหล่านี้เป็นเนิร์สเติร์นต่อประเภทของแอปพลิเคชันที่คุณกำลังสร้าง และเหมาะสมสำหรับแอปพลิเคชัน Rails แบบ API-only
คุณสามารถรับรายการของ middleware ทั้งหมดในแอปพลิเคชันของคุณได้ผ่าน:

```bash
$ bin/rails middleware
```

### การใช้งาน Rack::Cache

เมื่อใช้กับ Rails, `Rack::Cache` จะใช้ Rails cache store สำหรับ entity และ meta stores ของมัน นั่นหมายความว่าหากคุณใช้ memcache สำหรับแอป Rails ของคุณ เช่น แคช HTTP ที่มีอยู่ในระบบจะใช้ memcache

ในการใช้งาน `Rack::Cache` คุณต้องเพิ่ม gem `rack-cache` ลงใน `Gemfile` และตั้งค่า `config.action_dispatch.rack_cache` เป็น `true` เพื่อเปิดใช้งานฟังก์ชันของมัน ในการเปิดใช้งานฟังก์ชันนี้ คุณควรใช้ `stale?` ในคอนโทรลเลอร์ของคุณ ต่อไปคือตัวอย่างการใช้งาน `stale?`

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

การเรียกใช้ `stale?` จะเปรียบเทียบ `If-Modified-Since` ในส่วนหัวของคำขอกับ `@post.updated_at` หากส่วนหัวใหม่กว่าการแก้ไขครั้งล่าสุด การกระทำนี้จะส่งคืนการตอบสนอง "304 Not Modified" มิเช่นนั้น จะแสดงการตอบสนองและรวมส่วนหัว `Last-Modified` ไว้ในนั้น

โดยปกติแล้ว กลไกนี้ถูกใช้งานตามลูกค้าแต่ละราย แต่ `Rack::Cache` ช่วยให้เราสามารถแชร์กลไกแคชนี้ได้ทั่วไป โดยเราสามารถเปิดใช้งานแคชระหว่างลูกค้าได้ในการเรียกใช้ `stale?`:

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end
end
```

นี่หมายความว่า `Rack::Cache` จะเก็บค่า `Last-Modified` สำหรับ URL ในแคช Rails และเพิ่มส่วนหัว `If-Modified-Since` ในคำขอเข้าสู่ระบบสำหรับ URL เดียวกันที่เกิดขึ้นในภายหลัง

คิดเป็นการแคชหน้าโดยใช้ HTTP semantics

### การใช้งาน Rack::Sendfile

เมื่อคุณใช้เมธอด `send_file` ภายในคอนโทรลเลอร์ Rails มันจะตั้งค่าส่วนหัว `X-Sendfile` `Rack::Sendfile` รับผิดชอบในการส่งไฟล์จริง

หากเซิร์ฟเวอร์ด้านหน้าของคุณรองรับการส่งไฟล์อย่างรวดเร็ว `Rack::Sendfile` จะเป็นผู้รับผิดชอบในการส่งไฟล์จริง

คุณสามารถกำหนดชื่อส่วนหัวที่เซิร์ฟเวอร์ด้านหน้าของคุณใช้สำหรับวัตถุประสงค์นี้ได้โดยใช้ [`config.action_dispatch.x_sendfile_header`][] ในไฟล์การกำหนดค่าสภาพแวดล้อมที่เหมาะสม

คุณสามารถเรียนรู้เพิ่มเติมเกี่ยวกับวิธีการใช้ `Rack::Sendfile` กับเฟรนต์เอนด์ที่นิยมใน [เอกสาร Rack::Sendfile](https://www.rubydoc.info/gems/rack/Rack/Sendfile)

นี่คือค่าสำหรับส่วนหัวนี้สำหรับเซิร์ฟเวอร์ที่นิยม หลังจากที่กำหนดค่าเซิร์ฟเวอร์เหล่านี้ให้รองรับการส่งไฟล์อย่างรวดเร็ว:

```ruby
# Apache และ lighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

ตรวจสอบให้แน่ใจว่ากำหนดค่าเซิร์ฟเวอร์ของคุณให้รองรับตัวเลือกเหล่านี้ตามคำแนะนำในเอกสาร `Rack::Sendfile`

### การใช้งาน ActionDispatch::Request

`ActionDispatch::Request#params` จะรับพารามิเตอร์จากไคลเอนต์ในรูปแบบ JSON และทำให้พารามิเตอร์เหล่านั้นสามารถใช้ได้ในคอนโทรลเลอร์ของคุณภายใน `params`

ในการใช้งานนี้ ไคลเอนต์ของคุณจะต้องทำคำขอด้วยพารามิเตอร์ที่เข้ารหัสเป็น JSON และระบุ `Content-Type` เป็น `application/json`

นี่คือตัวอย่างใน jQuery:

```js
jQuery.ajax({
  type: 'POST',
  url: '/people',
  dataType: 'json',
  contentType: 'application/json',
  data: JSON.stringify({ person: { firstName: "Yehuda", lastName: "Katz" } }),
  success: function(json) { }
});
```

`ActionDispatch::Request` จะเห็น `Content-Type` และพารามิเตอร์ของคุณจะเป็น:

```ruby
{ person: { firstName: "Yehuda", lastName: "Katz" } }
```

### การใช้งาน Session Middlewares

Middleware ต่อไปนี้ที่ใช้สำหรับการจัดการเซสชันถูกยกเว้นจากแอป API เนื่องจากพวกเขาไม่จำเป็นต้องใช้เซสชัน หากหนึ่งในลูกค้า API ของคุณเป็นเบราว์เซอร์ คุณอาจต้องเพิ่มหนึ่งในเหล่านี้กลับเข้ามา:
- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

เคล็ดลับในการเพิ่มส่วนเสริมเหล่านี้กลับมาคือ โดยค่าเริ่มต้น เมื่อเพิ่มเข้ามา (รวมถึงคีย์เซสชั่น) จะถูกส่งผ่าน `session_options` ดังนั้นคุณไม่สามารถเพิ่ม `session_store.rb` initializer และเพิ่ม `use ActionDispatch::Session::CookieStore` แล้วให้เซสชั่นทำงานเหมือนเดิมได้ (ให้เข้าใจได้ชัดเจน: เซสชั่นอาจทำงานได้ แต่ตัวเลือกเซสชั่นของคุณจะถูกละเว้น - กล่าวคือคีย์เซสชั่นจะกลายเป็นค่าเริ่มต้นเป็น `_session_id`)

แทนที่ initializer คุณต้องตั้งค่าตัวเลือกที่เกี่ยวข้องในสถานที่ใดก็ได้ก่อน middleware ของคุณถูกสร้างขึ้น (เช่น `config/application.rb`) และส่งผ่านไปยัง middleware ที่คุณต้องการ ดังนี้:

```ruby
# ส่วนนี้ยังกำหนด session_options สำหรับใช้งานด้านล่าง
config.session_store :cookie_store, key: '_interslice_session'

# จำเป็นสำหรับการจัดการเซสชั่นทั้งหมด (ไม่ว่าจะเป็น session_store ใด)
config.middleware.use ActionDispatch::Cookies

config.middleware.use config.session_store, config.session_options
```

### Middleware อื่น ๆ

Rails มาพร้อมกับ middleware อื่น ๆ ที่คุณอาจต้องการใช้ในแอปพลิเคชัน API โดยเฉพาะอย่างยิ่งหากไคลเอนต์ API หนึ่งของคุณคือเบราว์เซอร์:

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`

คุณสามารถเพิ่ม middleware เหล่านี้ได้โดยใช้:

```ruby
config.middleware.use Rack::MethodOverride
```

### การลบ Middleware

หากคุณไม่ต้องการใช้ middleware ที่รวมมาในชุด middleware สำหรับ API เริ่มต้น คุณสามารถลบได้ด้วย:

```ruby
config.middleware.delete ::Rack::Sendfile
```

โปรดทราบว่าการลบ middleware เหล่านี้จะลบการสนับสนุนสำหรับคุณลักษณะบางอย่างใน Action Controller

การเลือกโมดูลควบคุม
---------------------------

แอปพลิเคชัน API (ที่ใช้ `ActionController::API`) มาพร้อมกับโมดูลควบคุมต่อไปนี้โดยค่าเริ่มต้น:

|   |   |
|---|---|
| `ActionController::UrlFor` | ทำให้ `url_for` และเฮลเปอร์ที่คล้ายกันสามารถใช้ได้ |
| `ActionController::Redirecting` | สนับสนุนสำหรับ `redirect_to` |
| `AbstractController::Rendering` และ `ActionController::ApiRendering` | สนับสนุนพื้นฐานสำหรับการเรนเดอร์ |
| `ActionController::Renderers::All` | สนับสนุนสำหรับ `render :json` และคำสั่งที่เกี่ยวข้อง |
| `ActionController::ConditionalGet` | สนับสนุนสำหรับ `stale?` |
| `ActionController::BasicImplicitRender` | ตรวจสอบและส่งคืนการตอบกลับที่ว่างเปล่าหากไม่มีการตอบกลับที่ระบุ |
| `ActionController::StrongParameters` | สนับสนุนสำหรับการกรองพารามิเตอร์ในการกำหนดค่าจำนวนมากของ Active Model |
| `ActionController::DataStreaming` | สนับสนุนสำหรับ `send_file` และ `send_data` |
| `AbstractController::Callbacks` | สนับสนุนสำหรับ `before_action` และเฮลเปอร์ที่คล้ายกัน |
| `ActionController::Rescue` | สนับสนุนสำหรับ `rescue_from` |
| `ActionController::Instrumentation` | สนับสนุนสำหรับตัวเก็บข้อมูลที่กำหนดโดย Action Controller (ดู[เอกสารเกี่ยวกับการใช้เครื่องมือตัวช่วย](active_support_instrumentation.html#action-controller)สำหรับข้อมูลเพิ่มเติมเกี่ยวกับเรื่องนี้) |
| `ActionController::ParamsWrapper` | ห่อพารามิเตอร์แฮชเป็นแฮชที่ซ้อนกัน เพื่อให้คุณไม่ต้องระบุองค์ประกอบรากเมื่อส่งคำขอ POST เช่น
| `ActionController::Head` | สนับสนุนสำหรับการส่งคำขอตอบกลับที่ไม่มีเนื้อหา แต่มีเฮดเดอร์เท่านั้น |

ปลั๊กอินอื่น ๆ อาจเพิ่มโมดูลเพิ่มเติม คุณสามารถรับรายการโมดูลทั้งหมดที่รวมอยู่ใน `ActionController::API` ได้ในคอนโซลของ Rails:

```irb
irb> ActionController::API.ancestors - ActionController::Metal.ancestors
=> [ActionController::API,
    ActiveRecord::Railties::ControllerRuntime,
    ActionDispatch::Routing::RouteSet::MountedHelpers,
    ActionController::ParamsWrapper,
    ... ,
    AbstractController::Rendering,
    ActionView::ViewPaths]
```

### เพิ่มโมดูลอื่น ๆ

โมดูล Action Controller ทั้งหมดรู้เกี่ยวกับโมดูลที่ขึ้นอยู่กัน ดังนั้นคุณสามารถเพิ่มโมดูลใดๆ เข้าไปในคอนโทรลเลอร์ของคุณได้อย่างอิสระ และโมดูลที่ขึ้นอยู่กันทั้งหมดจะถูกเพิ่มและตั้งค่าเช่นกัน

บางโมดูลที่คุณอาจต้องการเพิ่ม:

- `AbstractController::Translation`: สนับสนุนสำหรับ `l` และ `t` วิธีการใช้งานการแปลและการแปล
- สนับสนุนการรับรองความถูกต้องของ HTTP แบบพื้นฐาน, การรับรองความถูกต้องของ HTTP แบบดิจิตอล หรือการรับรองความถูกต้องของโทเค็น:
  * `ActionController::HttpAuthentication::Basic::ControllerMethods`
  * `ActionController::HttpAuthentication::Digest::ControllerMethods`
  * `ActionController::HttpAuthentication::Token::ControllerMethods`
- `ActionView::Layouts`: สนับสนุนสำหรับเลเอาต์เมื่อเรนเดอร์
- `ActionController::MimeResponds`: สนับสนุนสำหรับ `respond_to`
- `ActionController::Cookies`: สนับสนุนสำหรับ `cookies` ซึ่งรวมถึงการรับรองความถูกต้องและการเข้ารหัสคุกกี้ นี้ต้องการ middleware คุกกี้
- `ActionController::Caching`: สนับสนุนการแคชวิวสำหรับคอนโทรลเลอร์ API โปรดทราบว่าคุณจะต้องระบุร้านค้าแคชด้วยตนเองภายในคอนโทรลเลอร์ดังนี้:
```ruby
class ApplicationController < ActionController::API
  include ::ActionController::Caching
  self.cache_store = :mem_cache_store
end
```

เรลส์ไม่ส่งการกำหนดค่านี้โดยอัตโนมัติ

สถานที่ที่ดีที่สุดในการเพิ่มโมดูลคือใน `ApplicationController` ของคุณ แต่คุณยังสามารถเพิ่มโมดูลในคอนโทรลเลอร์แต่ละตัวได้เช่นกัน
[`config.debug_exception_response_format`]: configuring.html#config-debug-exception-response-format
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
