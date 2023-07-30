**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 8e409a33cc6caed27c82b91e6adad6c7
พื้นฐานของ Active Job
=================

เอกสารนี้จะให้คุณทราบทุกสิ่งที่คุณต้องการเพื่อเริ่มต้นในการสร้างงานพื้นหลัง (background jobs) และการเรียกใช้งาน

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีการสร้างงาน
* วิธีการเพิ่มงานในคิว (enqueue jobs)
* วิธีการเรียกใช้งานงานในพื้นหลัง (run jobs in the background)
* วิธีการส่งอีเมลจากแอปพลิเคชันของคุณในรูปแบบไม่ระบุเวลา (asynchronously)

--------------------------------------------------------------------------------

Active Job คืออะไร?
-------------------

Active Job เป็นเฟรมเวิร์กสำหรับการประกาศงานและการทำงานของงานในหลายรูปแบบของการเก็บงานในคิว (queuing backends) งานเหล่านี้สามารถเป็นทั้งการทำความสะอาดเป็นประจำ, การเรียกเก็บเงิน, การส่งจดหมาย อย่างไรก็ตามทุกอย่างที่สามารถแบ่งออกเป็นหน่วยงานเล็ก ๆ และทำงานพร้อมกันได้จริง ๆ

วัตถุประสงค์ของ Active Job
-----------------------------

จุดสำคัญคือการให้แน่ใจว่าแอปพลิเคชัน Rails ทุกตัวจะมีโครงสร้างงานพื้นฐานอยู่ในที่ จากนั้นเราสามารถใช้คุณสมบัติของเฟรมเวิร์กและเจมอื่น ๆ สร้างขึ้นบนโครงสร้างนั้นได้โดยไม่ต้องกังวลเรื่องความแตกต่างของ API ระหว่างตัวรันงานต่าง ๆ เช่น Delayed Job และ Resque การเลือกเลือกเครื่องมือเก็บงานในคิวกลายเป็นเรื่องที่เกี่ยวข้องกับการดำเนินการ และคุณจะสามารถสลับระหว่างเครื่องมือเหล่านั้นได้โดยไม่ต้องเขียนงานใหม่

หมายเหตุ: Rails มาพร้อมกับการสร้างคิวแบบไม่เชื่อมต่อที่ทำงานโดยใช้เธรดในกระบวนการ งานจะทำงานแบบไม่ระบุเวลา แต่งานในคิวจะถูกลบออกเมื่อเริ่มต้นใหม่

การสร้างงาน
--------------

ส่วนนี้จะให้คำแนะนำขั้นตอนการสร้างงานและการเพิ่มงานในคิว

### สร้างงาน

Active Job มีเครื่องมือสร้างงานให้ใช้กับ Rails คำสั่งต่อไปนี้จะสร้างงานใน `app/jobs` (พร้อมกับไฟล์ทดสอบที่แนบอยู่ใน `test/jobs`):

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

คุณยังสามารถสร้างงานที่จะทำงานในคิวที่ระบุได้:

```bash
$ bin/rails generate job guests_cleanup --queue urgent
```

หากคุณไม่ต้องการใช้เครื่องมือสร้าง คุณสามารถสร้างไฟล์ของคุณเองภายใน `app/jobs` แต่ต้องแน่ใจว่ามันสืบทอดจาก `ApplicationJob`

นี่คือรูปแบบของงาน:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # ทำบางอย่างในภายหลัง
  end
end
```

โปรดทราบว่าคุณสามารถกำหนด `perform` ด้วยอาร์กิวเมนต์ได้เท่าที่คุณต้องการ

หากคุณมีคลาสแบบสรุปและชื่อของมันแตกต่างจาก `ApplicationJob` คุณสามารถส่ง `--parent` เพื่อระบุว่าคุณต้องการคลาสสรุปที่แตกต่างกัน:

```bash
$ bin/rails generate job process_payment --parent=payment_job
```

```ruby
class ProcessPaymentJob < PaymentJob
  queue_as :default

  def perform(*args)
    # ทำบางอย่างในภายหลัง
  end
end
```

### เพิ่มงานในคิว

เพิ่มงานในคิวโดยใช้ [`perform_later`][] และตัวเลือก [`set`][]. ดังนี้:

```ruby
# เพิ่มงานในคิวเพื่อทำงานเมื่อระบบคิวว่าง
GuestsCleanupJob.perform_later guest
```

```ruby
# เพิ่มงานในคิวเพื่อทำงานในวันพรุ่งนี้เวลาเที่ยง
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
```

```ruby
# เพิ่มงานในคิวเพื่อทำงานในอีก 1 สัปดาห์
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

```ruby
# `perform_now` และ `perform_later` จะเรียกใช้ `perform` ภายใน ดังนั้นคุณสามารถส่งอาร์กิวเมนต์ได้เท่าที่กำหนดไว้ใน `perform`
GuestsCleanupJob.perform_later(guest1, guest2, filter: 'some_filter')
```
การดำเนินการงาน
-------------

สำหรับการเรียกคิวและการดำเนินการงานงานในการใช้งานจริงคุณต้องติดตั้งระบบคิวที่เหมาะสม
กล่าวคือคุณต้องตัดสินใจเลือกไลบรารีคิวที่เป็นของบุคคลที่สามที่ Rails ควรใช้
Rails เองมีระบบคิวในกระบวนการภายในเท่านั้น ซึ่งเก็บงานไว้ใน RAM เท่านั้น
หากกระบวนการล้มเหลวหรือเครื่องถูกรีเซ็ต งานที่ค้างอยู่ทั้งหมดจะหายไปกับ
backend แบบ async ที่ตั้งค่าเริ่มต้น สำหรับแอปขนาดเล็กหรืองานที่ไม่สำคัญ
อาจเป็นไปได้ แต่แอปในการใช้งานจริงส่วนใหญ่จะต้องเลือก backend ที่มีความทนทาน

### แบ็กเอนด์

Active Job มีตัวอย่างแบ็กเอนด์สำหรับหลาย backend คิว (Sidekiq,
Resque, Delayed Job, และอื่น ๆ) เพื่อให้ได้รายการอัปเดตล่าสุดของแอ็ดเอปเตอร์
ดูที่เอพีไอเอกสารประกอบ [`ActiveJob::QueueAdapters`][]


### การตั้งค่าแบ็กเอนด์

คุณสามารถตั้งค่า backend ของคิวได้อย่างง่ายดายด้วย [`config.active_job.queue_adapter`]:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # ตรวจสอบให้แน่ใจว่ามี gem ของแอ็ดเอปเตอร์ใน Gemfile ของคุณ
    # และปฏิบัติตามคำแนะนำการติดตั้งและการใช้งานของแอ็ดเอปเตอร์นั้น
    config.active_job.queue_adapter = :sidekiq
  end
end
```

คุณยังสามารถกำหนดค่า backend ของคุณในแต่ละงานได้:

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  # ...
end

# ตอนนี้งานของคุณจะใช้ `resque` เป็น backend ของคิว แทนที่จะใช้
# ค่าที่ตั้งค่าไว้ใน `config.active_job.queue_adapter`.
```


### เริ่ม backend

เนื่องจากงานทำงานแบบพร้อมกันกับแอปเว็บ Rails ของคุณ หลายไลบรารีคิว
ต้องการให้คุณเริ่มบริการคิวที่เฉพาะเจาะจงสำหรับไลบรารีนั้น (นอกเหนือจาก
การเริ่มแอป Rails ของคุณ) เพื่อให้การประมวลผลงานทำงานได้ ดูเอกสารของไลบรารี
สำหรับคำแนะนำในการเริ่ม backend คิวของคุณ

นี่คือรายการเอกสารที่ไม่ครอบคลุมทั้งหมด:

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)
- [Que](https://github.com/que-rb/que#additional-rails-specific-setup)
- [Good Job](https://github.com/bensheldon/good_job#readme)

คิว
------

ส่วนใหญ่ของแอ็ดเอปเตอร์รองรับคิวหลายรายการ ด้วย Active Job คุณสามารถกำหนดเวลา
การทำงานของงานให้เรียกใช้งานในคิวที่เฉพาะเจาะจงโดยใช้ [`queue_as`][]:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

คุณสามารถเติมคำนำหน้าชื่อคิวสำหรับงานทั้งหมดของคุณโดยใช้
[`config.active_job.queue_name_prefix`][] ใน `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# ตอนนี้งานของคุณจะทำงานในคิว production_low_priority ในสภาพแวดล้อม
# production และในคิว staging_low_priority
# ในสภาพแวดล้อม staging
```

คุณยังสามารถกำหนดคำนำหน้าชื่อในแต่ละงานได้

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  self.queue_name_prefix = nil
  # ...
end

# ตอนนี้คิวของงานของคุณจะไม่มีคำนำหน้า แทนที่จะใช้ค่าที่ตั้งค่าไว้ใน `config.active_job.queue_name_prefix`.
```

ตัวคั่นคำนำหน้าชื่อคิวเริ่มต้นคือ '\_' สามารถเปลี่ยนได้โดยการตั้งค่า
[`config.active_job.queue_name_delimiter`][] ใน `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = '.'
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# ตอนนี้งานของคุณจะทำงานในคิว production.low_priority ในสภาพแวดล้อม
# production และในคิว staging.low_priority
# ในสภาพแวดล้อม staging
```
หากคุณต้องการควบคุมคิวที่งานจะถูกเรียกใช้คุณสามารถส่ง `:queue` option ไปยัง `set`:

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

หากต้องการควบคุมคิวจาก job level คุณสามารถส่ง block ไปยัง `queue_as` โดย block จะถูกเรียกใช้ใน context ของ job (ดังนั้นจึงสามารถเข้าถึง `self.arguments` ได้) และ block ต้องส่งคืนชื่อคิว:

```ruby
class ProcessVideoJob < ApplicationJob
  queue_as do
    video = self.arguments.first
    if video.owner.premium?
      :premium_videojobs
    else
      :videojobs
    end
  end

  def perform(video)
    # ดำเนินการประมวลผลวิดีโอ
  end
end
```

```ruby
ProcessVideoJob.perform_later(Video.last)
```

หมายเหตุ: ตรวจสอบให้แน่ใจว่า queuing backend ของคุณ "ฟัง" ชื่อคิวของคุณ สำหรับบาง backend คุณจำเป็นต้องระบุคิวที่จะ "ฟัง"

Callbacks
---------

Active Job มี hooks เพื่อเรียกใช้ตรรกะในระหว่าง lifecycle ของ job เช่นเดียวกับ callbacks อื่น ๆ ใน Rails คุณสามารถสร้าง callbacks เป็นเมธอดธรรมดาและใช้ macro-style class method เพื่อลงทะเบียนเป็น callbacks:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # ดำเนินการอื่น ๆ ในภายหลัง
  end

  private
    def around_cleanup
      # ดำเนินการก่อน perform
      yield
      # ดำเนินการหลัง perform
    end
end
```

Macro-style class methods ยังสามารถรับ block ได้ คิดจะใช้รูปแบบนี้หาก code ภายใน block สั้นมากพอที่จะพอดีในบรรทัดเดียว ตัวอย่างเช่น คุณสามารถส่ง metrics สำหรับทุก job ที่ enqueue:

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| $statsd.increment "#{job.class.name.underscore}.enqueue" }
end
```

### Callbacks ที่มีอยู่

* [`before_enqueue`][]
* [`around_enqueue`][]
* [`after_enqueue`][]
* [`before_perform`][]
* [`around_perform`][]
* [`after_perform`][]


Action Mailer
------------

หนึ่งในงานที่สำคัญที่สุดในแอปพลิเคชันเว็บที่ทันสมัยคือการส่งอีเมลภายนอกของรอบการตอบสนอง ดังนั้นผู้ใช้ไม่ต้องรอในการตอบสนอง Active Job ได้รวมกับ Action Mailer เพื่อให้คุณสามารถส่งอีเมลแบบ asynchronous ได้ง่าย:

```ruby
# หากคุณต้องการส่งอีเมลทันทีให้ใช้ #deliver_now
UserMailer.welcome(@user).deliver_now

# หากคุณต้องการส่งอีเมลผ่าน Active Job ให้ใช้ #deliver_later
UserMailer.welcome(@user).deliver_later
```

หมายเหตุ: การใช้คิว asynchronous จาก Rake task (ตัวอย่างเช่นการส่งอีเมลโดยใช้ `.deliver_later`) มักจะไม่ทำงานเนื่องจาก Rake จะจบลง ทำให้เส้นทางการทำงานในกระบวนการถูกลบออกก่อนที่อีเมลที่ `.deliver_later` จะถูกประมวลผลทั้งหมด เพื่อหลีกเลี่ยงปัญหานี้ให้ใช้ `.deliver_now` หรือเรียกใช้คิวที่ยังคงอยู่ในการพัฒนา


Internationalization
--------------------

แต่ละ job ใช้ `I18n.locale` ที่ตั้งเมื่อ job ถูกสร้าง สิ่งนี้เป็นประโยชน์หากคุณส่งอีเมลแบบ asynchronous:

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # อีเมลจะถูกแปลงเป็นภาษา Esperanto
```


Supported Types for Arguments
----------------------------

ActiveJob รองรับประเภทต่อไปนี้ของ arguments โดยค่าเริ่มต้น:

  - ประเภทพื้นฐาน (`NilClass`, `String`, `Integer`, `Float`, `BigDecimal`, `TrueClass`, `FalseClass`)
  - `Symbol`
  - `Date`
  - `Time`
  - `DateTime`
  - `ActiveSupport::TimeWithZone`
  - `ActiveSupport::Duration`
  - `Hash` (Keys ควรเป็นประเภท `String` หรือ `Symbol`)
  - `ActiveSupport::HashWithIndifferentAccess`
  - `Array`
  - `Range`
  - `Module`
  - `Class`

### GlobalID

Active Job รองรับ [GlobalID](https://github.com/rails/globalid/blob/master/README.md) สำหรับพารามิเตอร์ ซึ่งทำให้เป็นไปได้ที่จะส่งอ็อบเจ็กต์ Active Record สดไปยัง job ของคุณแทนที่จะเป็นคู่คลาส/ID ซึ่งคุณต้องแยกออกมาเอง ก่อนหน้านี้ job จะมีรูปแบบดังนี้:
```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

ตอนนี้คุณสามารถทำได้อย่างง่ายดาย:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

สิ่งนี้ทำงานกับคลาสใดก็ได้ที่มีการผสม `GlobalID::Identification` ซึ่ง
โดยค่าเริ่มต้นถูกผสมเข้ากับคลาส Active Record

### Serializers

คุณสามารถขยายรายการประเภทอาร์กิวเมนต์ที่รองรับได้ คุณเพียงแค่ต้องกำหนดซีรีย์ไลเซอร์ของคุณเอง:

```ruby
# app/serializers/money_serializer.rb
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  # ตรวจสอบว่าอาร์กิวเมนต์ควรถูกซีรีย์ไลซ์โดยซีรีย์ไลเซอร์นี้หรือไม่
  def serialize?(argument)
    argument.is_a? Money
  end

  # แปลงออบเจ็กต์เป็นรูปแบบที่เรียกว่าง่ายกว่าโดยใช้ประเภทออบเจ็กต์ที่รองรับ
  # รูปแบบที่แนะนำคือแฮชที่มีคีย์เฉพาะ คีย์สามารถเป็นประเภทพื้นฐานเท่านั้น
  # คุณควรเรียกใช้ `super` เพื่อเพิ่มประเภทซีรีย์ไลเซอร์ที่กำหนดเองในแฮช
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  # แปลงค่าที่ถูกซีรีย์ไลซ์เป็นออบเจ็กต์ที่เหมาะสม
  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end
end
```

และเพิ่มซีรีย์ไลเซอร์นี้ในรายการ:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

โปรดทราบว่าการโหลดโค้ดที่สามารถโหลดได้ใหม่ระหว่างการเริ่มต้นไม่ได้รับการสนับสนุน ดังนั้นควร
ตั้งค่าซีรีย์ไลเซอร์ให้โหลดเพียงครั้งเดียวเท่านั้น เช่น โดยการแก้ไข `config/application.rb` ดังนี้:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.autoload_once_paths << Rails.root.join('app', 'serializers')
  end
end
```

ข้อยกเว้น
----------

ข้อยกเว้นที่เกิดขึ้นระหว่างการประมวลผลงานสามารถจัดการได้ด้วย
[`rescue_from`][]:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # ทำบางสิ่งกับข้อยกเว้น
  end

  def perform
    # ทำบางสิ่งในภายหลัง
  end
end
```

หากงานเกิดข้อยกเว้นแล้วไม่ได้รับการกู้คืน งานนั้นจะถูกเรียกว่า "ล้มเหลว" (failed)


### ลองใหม่หรือละทิ้งงานที่ล้มเหลว

งานที่ล้มเหลวจะไม่ได้รับการลองใหม่ ยกเว้นถ้ากำหนดไว้เป็นอย่างอื่น

สามารถลองใหม่หรือละทิ้งงานที่ล้มเหลวได้โดยใช้ [`retry_on`] หรือ
[`discard_on`] ตามลำดับ ตัวอย่างเช่น:

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # ค่าเริ่มต้นคือรอ 3 วินาที ลองใหม่ 5 ครั้ง

  discard_on ActiveJob::DeserializationError

  def perform(*args)
    # อาจเกิด CustomAppException หรือ ActiveJob::DeserializationError
  end
end
```


### การถอดรหัส

GlobalID ช่วยให้สามารถซีรีย์ไลซ์ออบเจ็กต์ Active Record เต็มรูปแบบที่ส่งผ่านไปยัง `#perform` ได้

หากบันทึกที่ส่งผ่านถูกลบหลังจากงานถูกเพิ่มลงในคิวแต่ก่อนที่ `#perform`
จะถูกเรียก Active Job จะยกเว้น [`ActiveJob::DeserializationError`][]

[`perform_later`]: https://api.rubyonrails.org/classes/ActiveJob/Enqueuing/ClassMethods.html#method-i-perform_later
[`set`]: https://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html#method-i-set
[`ActiveJob::QueueAdapters`]: https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html
[`config.active_job.queue_adapter`]: configuring.html#config-active-job-queue-adapter
[`config.active_job.queue_name_delimiter`]: configuring.html#config-active-job-queue-name-delimiter
[`config.active_job.queue_name_prefix`]: configuring.html#config-active-job-queue-name-prefix
[`queue_as`]: https://api.rubyonrails.org/classes/ActiveJob/QueueName/ClassMethods.html#method-i-queue_as
[`before_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_enqueue
[`around_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_enqueue
[`after_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_enqueue
[`before_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_perform
[`around_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_perform
[`after_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_perform
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`discard_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-discard_on
[`retry_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
[`ActiveJob::DeserializationError`]: https://api.rubyonrails.org/classes/ActiveJob/DeserializationError.html
