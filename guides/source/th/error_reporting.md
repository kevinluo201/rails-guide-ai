**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e904ad42aee9a68f37b4e79e0b70b685
การรายงานข้อผิดพลาดในแอปพลิเคชัน Rails
========================

เอกสารนี้จะแนะนำวิธีการจัดการข้อผิดพลาดที่เกิดขึ้นในแอปพลิเคชัน Ruby on Rails

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีใช้ error reporter ของ Rails เพื่อรับและรายงานข้อผิดพลาด
* วิธีสร้าง subscribers ที่กำหนดเองสำหรับบริการรายงานข้อผิดพลาดของคุณ

--------------------------------------------------------------------------------

การรายงานข้อผิดพลาด
------------------------

Rails [error reporter](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html) ให้วิธีมาตรฐานในการรวบรวมข้อผิดพลาดที่เกิดขึ้นในแอปพลิเคชันของคุณและรายงานให้บริการหรือตำแหน่งที่คุณต้องการ

Error reporter มีเป้าหมายที่จะแทนที่โค้ดการจัดการข้อผิดพลาดที่ซ้ำซ้อนเช่นนี้:

```ruby
begin
  do_something
rescue SomethingIsBroken => error
  MyErrorReportingService.notify(error)
end
```

ด้วยอินเทอร์เฟซที่สอดคล้อง:

```ruby
Rails.error.handle(SomethingIsBroken) do
  do_something
end
```

Rails ครอบคลุมการดำเนินการทั้งหมด (เช่นการร้องขอ HTTP, งาน และการเรียกใช้ `rails runner`) ใน error reporter เพื่อให้ข้อผิดพลาดที่ไม่ได้รับการจัดการที่เกิดขึ้นในแอปของคุณถูกรายงานโดยอัตโนมัติไปยังบริการรายงานข้อผิดพลาดของคุณผ่าน subscribers ของพวกเขา

นั่นหมายความว่าไลบรารีการรายงานข้อผิดพลาดจากบุคคลที่สามไม่จำเป็นต้องแทรก Rack middleware หรือทำการ monkey-patching เพื่อจับข้อผิดพลาดที่ไม่ได้รับการจัดการไว้ ไลบรารีที่ใช้ ActiveSupport ยังสามารถใช้สิ่งนี้เพื่อรายงานคำเตือนที่อาจหายไปในบันทึกได้อย่างไม่เข้ารุก

การใช้ error reporter ของ Rails ไม่จำเป็น วิธีการรับข้อผิดพลาดที่อื่นยังคงทำงานได้

### การสมัครสมาชิกกับ Reporter

ในการใช้ error reporter คุณต้องมี _subscriber_ ซึ่งเป็นอ็อบเจกต์ใด ๆ ที่มีเมธอด `report` เมื่อเกิดข้อผิดพลาดในแอปของคุณหรือรายงานด้วยตนเอง error reporter ของ Rails จะเรียกเมธอดนี้พร้อมกับอ็อบเจกต์ข้อผิดพลาดและตัวเลือกบางอย่าง

บางไลบรารีการรายงานข้อผิดพลาด เช่น [Sentry's](https://github.com/getsentry/sentry-ruby/blob/e18ce4b6dcce2ebd37778c1e96164684a1e9ebfc/sentry-rails/lib/sentry/rails/error_subscriber.rb) และ [Honeybadger's](https://docs.honeybadger.io/lib/ruby/integration-guides/rails-exception-tracking/) จะลงทะเบียน subscriber ให้คุณโดยอัตโนมัติ โปรดอ่านเอกสารของผู้ให้บริการของคุณเพื่อดูรายละเอียดเพิ่มเติม

คุณยังสามารถสร้าง subscriber ที่กำหนดเองได้ เช่น:

```ruby
# config/initializers/error_subscriber.rb
class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    MyErrorReportingService.report_error(error, context: context, handled: handled, level: severity)
  end
end
```

หลังจากกำหนดคลาส subscriber เสร็จ ลงทะเบียนโดยเรียกใช้เมธอด [`Rails.error.subscribe`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-subscribe):

```ruby
Rails.error.subscribe(ErrorSubscriber.new)
```

คุณสามารถลงทะเบียน subscribers ได้เท่าที่คุณต้องการ Rails จะเรียกใช้พวกเขาตามลำดับที่ลงทะเบียน

หมายเหตุ: error-reporter ของ Rails จะเรียก subscribers ที่ลงทะเบียนเสมอไม่ว่าสภาพแวดล้อมของคุณจะเป็นอย่างไร อย่างไรก็ตาม บริการรายงานข้อผิดพลาดหลายรายการมักจะรายงานข้อผิดพลาดในโหมดการผลิตเท่านั้นตามค่าเริ่มต้น คุณควรกำหนดค่าและทดสอบการตั้งค่าของคุณในสภาพแวดล้อมต่าง ๆ ตามที่จำเป็น

### การใช้ Error Reporter

มีวิธีที่คุณสามารถใช้ error reporter ได้สามวิธี:

#### การรายงานและการยึดข้อผิดพลาด

[`Rails.error.handle`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-handle) จะรายงานข้อผิดพลาดที่เกิดขึ้นในบล็อก และจะ **ยึด** ข้อผิดพลาดนั้น และโค้ดที่เหลือของคุณนอกบล็อกจะดำเนินการต่อไปเหมือนเดิม

```ruby
result = Rails.error.handle do
  1 + '1' # ยกเลิก TypeError
end
result # => nil
1 + 1 # จะถูกดำเนินการ
```

หากไม่มีข้อผิดพลาดที่เกิดขึ้นในบล็อก `Rails.error.handle` จะคืนผลลัพธ์ของบล็อก มิฉะนั้นจะคืน `nil` คุณสามารถแทนที่ได้โดยให้ `fallback`:

```ruby
user = Rails.error.handle(fallback: -> { User.anonymous }) do
  User.find_by(params[:id])
end
```

#### การรายงานและการยกเลิกข้อผิดพลาด

[`Rails.error.record`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-record) จะรายงานข้อผิดพลาดให้กับ subscribers ที่ลงทะเบียนทั้งหมดและจะยกเลิกข้อผิดพลาดนั้น หมายความว่าโค้ดที่เหลือของคุณจะไม่ถูกดำเนินการต่อ
```ruby
Rails.error.record do
  1 + '1' # ยกเลิก TypeError
end
1 + 1 # ไม่ได้รัน

```

ถ้าไม่มีข้อผิดพลาดที่เกิดขึ้นในบล็อก `Rails.error.record` จะส่งคืนผลลัพธ์ของบล็อก

#### รายงานข้อผิดพลาดด้วยตนเอง

คุณยังสามารถรายงานข้อผิดพลาดด้วยตนเองได้โดยเรียกใช้ [`Rails.error.report`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-report):

```ruby
begin
  # โค้ด
rescue StandardError => e
  Rails.error.report(e)
end
```

ตัวเลือกใด ๆ ที่คุณส่งผ่านจะถูกส่งต่อไปยังผู้สมัครรับข้อผิดพลาดทั้งหมด

### ตัวเลือกการรายงานข้อผิดพลาด

API การรายงานทั้ง 3 (`#handle`, `#record`, และ `#report`) รองรับตัวเลือกต่อไปนี้ ซึ่งจะถูกส่งต่อไปยังผู้สมัครรับที่ลงทะเบียนทั้งหมด:

- `handled`: `Boolean` เพื่อแสดงถึงว่าข้อผิดพลาดได้รับการจัดการหรือไม่ ค่าเริ่มต้นคือ `true` `#record` จะตั้งค่าเป็น `false`
- `severity`: `Symbol` ที่อธิบายความรุนแรงของข้อผิดพลาด ค่าที่คาดหวังคือ: `:error`, `:warning`, และ `:info` `#handle` จะตั้งค่าเป็น `:warning` ในขณะที่ `#record` จะตั้งค่าเป็น `:error`
- `context`: `Hash` เพื่อให้ข้อมูลเพิ่มเติมเกี่ยวกับข้อผิดพลาด เช่น รายละเอียดของคำขอหรือผู้ใช้
- `source`: `String` เกี่ยวกับแหล่งของข้อผิดพลาด แหล่งเริ่มต้นคือ `"application"` ข้อผิดพลาดที่รายงานโดยไลบรารีภายในอาจตั้งค่าแหล่งอื่น ๆ เช่น ไลบรารีแคช Redis อาจใช้ `"redis_cache_store.active_support"` ตัวสมาชิกของคุณสามารถใช้แหล่งข้อมูลเพื่อละเว้นข้อผิดพลาดที่คุณไม่สนใจ

```ruby
Rails.error.handle(context: { user_id: user.id }, severity: :info) do
  # ...
end
```

### กรองตามคลาสข้อผิดพลาด

ด้วย `Rails.error.handle` และ `Rails.error.record` คุณยังสามารถเลือกที่จะรายงานข้อผิดพลาดเฉพาะคลาสบางอย่างได้ ตัวอย่างเช่น:

```ruby
Rails.error.handle(IOError) do
  1 + '1' # ยกเลิก TypeError
end
1 + 1 # TypeErrors ไม่ใช่ IOError ดังนั้นจะ *ไม่* รัน

```

ที่นี่ `TypeError` จะไม่ถูกจับได้โดยตัวรายงานข้อผิดพลาดของ Rails แต่จะรายงานเฉพาะอินสแตนซ์ของ `IOError` และลูกสายของมันเท่านั้น ข้อผิดพลาดอื่น ๆ จะถูกยกเลิกเหมือนเดิม

### ตั้งค่า Context ทั่วโลก

นอกจากการตั้งค่า context ผ่านตัวเลือก `context` คุณยังสามารถใช้ [`#set_context`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-set_context) API ได้ เช่น:

```ruby
Rails.error.set_context(section: "checkout", user_id: @user.id)
```

Context ใด ๆ ที่ตั้งค่าด้วยวิธีนี้จะถูกผสานกับตัวเลือก `context`

```ruby
Rails.error.set_context(a: 1)
Rails.error.handle(context: { b: 2 }) { raise }
# Context ที่รายงานคือ: {:a=>1, :b=>2}
Rails.error.handle(context: { b: 3 }) { raise }
# Context ที่รายงานคือ: {:a=>1, :b=>3}
```

### สำหรับไลบรารี

ไลบรารีการรายงานข้อผิดพลาดสามารถลงทะเบียนผู้สมัครรับข้อผิดพลาดได้ใน `Railtie`:

```ruby
module MySdk
  class Railtie < ::Rails::Railtie
    initializer "my_sdk.error_subscribe" do
      Rails.error.subscribe(MyErrorSubscriber.new)
    end
  end
end
```

หากคุณลงทะเบียนผู้สมัครรับข้อผิดพลาด แต่ยังมีกลไกข้อผิดพลาดอื่น ๆ เช่น Rack middleware คุณอาจพบว่าข้อผิดพลาดถูกรายงานหลายครั้ง คุณควรลบกลไกอื่น ๆ หรือปรับฟังก์ชันการรายงานข้อผิดพลาดของคุณเพื่อให้ข้ามการรายงานข้อผิดพลาดที่เคยเห็นแล้ว
