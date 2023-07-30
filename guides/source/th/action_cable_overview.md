**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4f7308fdab05dc13d399bde6a8ac302c
ภาพรวมของ Action Cable
=====================

ในคู่มือนี้คุณจะเรียนรู้วิธีการทำงานของ Action Cable และวิธีใช้ WebSockets เพื่อเพิ่มคุณลักษณะแบบเรียลไทม์ในแอปพลิเคชัน Rails ของคุณ

หลังจากอ่านคู่มือนี้คุณจะรู้:

* Action Cable คืออะไรและการผสานรวมระหว่าง backend และ frontend
* วิธีการตั้งค่า Action Cable
* วิธีการตั้งค่าช่อง
* การติดตั้งและการตั้งค่าสถาปัตยกรรมสำหรับการเรียกใช้ Action Cable

--------------------------------------------------------------------------------

Action Cable คืออะไร?
---------------------

Action Cable ผสานการใช้งาน [WebSockets](https://en.wikipedia.org/wiki/WebSocket) กับแอปพลิเคชัน Rails ของคุณอย่างราบรื่น มันช่วยให้คุณสามารถเขียนคุณลักษณะแบบเรียลไทม์ในรูปแบบและรูปแบบเดียวกับส่วนอื่นของแอปพลิเคชัน Rails ของคุณ ในขณะเดียวกันยังมีประสิทธิภาพและมีความสามารถในการขยายขนาด มันเป็นการให้บริการแบบ full-stack ที่ให้เฟรมเวิร์กฝั่งไคลเอนต์และเฟรมเวิร์กฝั่งเซิร์ฟเวอร์ คุณสามารถเข้าถึงโมเดลโดเมนทั้งหมดของคุณที่เขียนด้วย Active Record หรือ ORM ที่คุณเลือก

คำศัพท์ทางเทคนิค
-----------

Action Cable ใช้ WebSockets แทนโปรโตคอลการร้องขอและตอบ HTTP ทั้ง Action Cable และ WebSockets มีคำศัพท์ที่ไม่คุ้นเคยบางอย่าง:

### การเชื่อมต่อ (Connections)

*การเชื่อมต่อ* เป็นพื้นฐานของความสัมพันธ์ระหว่างไคลเอนต์และเซิร์ฟเวอร์ หนึ่งเซิร์ฟเวอร์ Action Cable สามารถจัดการกับหลายตัวอย่างการเชื่อมต่อได้ มีหนึ่งตัวอย่างการเชื่อมต่อต่อหนึ่งการเชื่อมต่อ WebSocket ผู้ใช้เดียวอาจมีการเปิด WebSocket หลายตัวสู่แอปพลิเคชันของคุณหากพวกเขาใช้แท็บเบราว์เซอร์หรืออุปกรณ์หลายตัว

### ผู้บริโภค (Consumers)

ไคลเอนต์ของการเชื่อมต่อ WebSocket ถูกเรียกว่า *ผู้บริโภค* ใน Action Cable ผู้บริโภคถูกสร้างขึ้นโดยเฟรมเวิร์กฝั่งไคลเอนต์ JavaScript

### ช่อง (Channels)

แต่ละผู้บริโภคสามารถสมัครสมาชิกกับหลาย *ช่อง* แต่ละช่องแยกแยะหน่วยงานที่เป็นตัวตนที่คล้ายกับที่คอนโทรลเลอร์ทำในการติดตั้ง MVC ทั่วไป ตัวอย่างเช่นคุณสามารถมี `ChatChannel` และ `AppearancesChannel` และผู้บริโภคสามารถสมัครสมาชิกกับช่องเหล่านี้ทั้งสองหรือทั้งสอง อย่างน้อยแล้วผู้บริโภคควรสมัครสมาชิกกับช่องหนึ่ง

### ผู้ติดตาม (Subscribers)

เมื่อผู้บริโภคสมัครสมาชิกกับช่องเขาจะเป็น *ผู้ติดตาม* การเชื่อมต่อระหว่างผู้ติดตามและช่องเรียกว่าการสมัครสมาชิก ผู้บริโภคสามารถทำหน้าที่เป็นผู้ติดตามกับช่องที่กำหนดได้หลายครั้ง ตัวอย่างเช่นผู้บริโภคสามารถสมัครสมาชิกกับห้องแชทหลายห้องในเวลาเดียวกัน (และจำไว้ว่าผู้ใช้ทางกายภาพอาจมีผู้บริโภคหลายคนหนึ่งต่อแท็บ / อุปกรณ์ที่เปิดใช้งานการเชื่อมต่อของคุณ)

### การเผยแพร่ / การส่งข้อมูล (Pub/Sub)

[การเผยแพร่ / การส่งข้อมูล](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern) หรือการเผยแพร่-การสมัครสมาชิก เป็นรูปแบบคิวข้อความที่ผู้ส่งข้อมูล (ผู้เผยแพร่) ส่งข้อมูลไปยังกลุ่มผู้รับ (ผู้ติดตาม) โดยไม่ระบุผู้รับแต่ละรายบุคคล Action Cable ใช้วิธีการนี้ในการสื่อสารระหว่างเซิร์ฟเวอร์และไคลเอนต์หลายคน

### การส่งออก (Broadcastings)

การส่งออกเป็นการเชื่อมโยงการเผยแพร่ / การส่งข้อมูลที่อะไรก็ตามที่ถูกส่งโดยผู้ส่งออกจะถูกส่งโดยตรงไปยังผู้ติดตามของช่องที่กำลังสตรีมส่งออกชื่อนั้น แต่ละช่องสามารถสตรีมส่งออกได้ศูนย์หรือมากกว่านั้น
การเชื่อมต่อเป็นตัวอย่างของ `ApplicationCable::Connection` ซึ่งขยาย
[`ActionCable::Connection::Base`][] ใน `ApplicationCable::Connection` คุณ
อนุญาตการเชื่อมต่อที่เข้ามาและดำเนินการเชื่อมต่อได้หากผู้ใช้สามารถระบุตัวตนได้

#### การตั้งค่าการเชื่อมต่อ

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if verified_user = User.find_by(id: cookies.encrypted[:user_id])
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

ที่นี่ [`identified_by`][] กำหนดตัวระบุการเชื่อมต่อที่สามารถใช้ในการค้นหา
การเชื่อมต่อที่เฉพาะเมื่อต้องการในภายหลัง โปรดทราบว่าอะไรก็ตามที่ถูกทำเครื่องหมายว่าเป็นตัวระบุจะสร้างตัวแทนด้วยชื่อเดียวกันบนอินสแตนซ์ของช่องที่สร้างจากการเชื่อมต่อ

ตัวอย่างนี้พึงพอใจในความเชื่อมต่อของผู้ใช้ที่คุณได้จัดการไว้แล้วในแอปพลิเคชันของคุณและการรับรองความถูกต้องของผู้ใช้ที่ประสบความสำเร็จจะตั้งค่าคุกกี้ที่เข้ารหัสด้วย ID ของผู้ใช้

คุกกี้จะถูกส่งโดยอัตโนมัติไปยังอินสแตนซ์การเชื่อมต่อเมื่อมีการเชื่อมต่อใหม่
และคุณใช้คุกกี้นั้นเพื่อตั้งค่า `current_user` โดยระบุการเชื่อมต่อ
โดยผู้ใช้ปัจจุบันเดียวกันนี้คุณยังตรวจสอบว่าคุณสามารถเรียกดูการเชื่อมต่อทั้งหมดที่เปิดอยู่โดยผู้ใช้ที่กำหนด (และอาจตัดการเชื่อมต่อทั้งหมดหากผู้ใช้ถูกลบหรือไม่ได้รับอนุญาต)

หากวิธีการรับรองความถูกต้องของคุณรวมถึงการใช้เซสชัน คุณใช้คุกกี้สโตร์สำหรับเซสชัน คุกกี้เซสชันของคุณมีชื่อ `_session` และคีย์ ID ของผู้ใช้คือ `user_id` คุณสามารถใช้วิธีนี้ได้:

```ruby
verified_user = User.find_by(id: cookies.encrypted['_session']['user_id'])
```


#### การจัดการข้อยกเว้น

ตามค่าเริ่มต้น ข้อยกเว้นที่ไม่ได้รับการจัดการจะถูกจับและบันทึกลงในตัวจับข้อยกเว้นของ Rails หากคุณต้องการ
จัดการข้อยกเว้นเหล่านี้และรายงานให้บริการติดตามข้อผิดพลาดภายนอกตัวอย่างเช่นคุณสามารถทำได้ดังนี้ด้วย [`rescue_from`][]:

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    rescue_from StandardError, with: :report_error

    private
      def report_error(e)
        SomeExternalBugtrackingService.notify(e)
      end
  end
end
```


#### การตอบสนองของการเชื่อมต่อ

มีการตอบสนอง `before_command`, `after_command`, และ `around_command` ที่สามารถเรียกใช้ก่อนหลังหรือรอบคำสั่งที่ได้รับจากไคลเอนต์ได้ตามลำดับ
คำว่า "คำสั่ง" ที่นี่หมายถึงการกระทำใด ๆ ที่ได้รับจากไคลเอนต์ (การสมัครสมาชิก การยกเลิกการสมัครสมาชิก หรือการดำเนินการ):

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    around_command :set_current_account

    private
      def set_current_account(&block)
        # ตอนนี้ทุกช่องสามารถใช้ Current.account
        Current.set(account: user.account, &block)
      end
  end
end
```

### ช่อง

*ช่อง* ห่อหุ้มหน่วยงานที่มีความสัมพันธ์ทางตรรกะเช่นเดียวกับที่ตัวควบคุมทำใน
การตั้งค่า MVC ทั่วไป โดยค่าเริ่มต้น Rails จะสร้างคลาส `ApplicationCable::Channel` แม่
(ซึ่งขยาย [`ActionCable::Channel::Base`][]) เพื่อห่อหุ้มตรรกะที่ใช้ร่วมกันระหว่างช่องของคุณ

#### การตั้งค่าช่องแม่

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

จากนั้นคุณสามารถสร้างคลาสช่องของคุณเอง เช่น คุณสามารถมี `ChatChannel` และ `AppearanceChannel`:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
end
```

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
end
```


ผู้บริโภคจะสามารถสมัครสมาชิกกับช่องเหล่านี้ได้ทั้งหมดหรือบางส่วน

#### การสมัครสมาชิก

ผู้บริโภคสมัครสมาชิกกับช่องเป็น *ผู้สมัครสมาชิก* การเชื่อมต่อของพวกเขาคือ
*การสมัครสมาชิก* ข้อความที่สร้างขึ้นจะถูกส่งไปยังการสมัครสมาชิกของช่องเหล่านี้
โดยอิงตามตัวระบุที่ส่งโดยผู้บริโภคของช่อง
```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # เรียกใช้เมื่อผู้ใช้งานสามารถเป็นผู้สมัครสมาชิกในช่องนี้ได้สำเร็จ
  def subscribed
  end
end
```

#### Exception Handling

เช่นเดียวกับ `ApplicationCable::Connection` คุณยังสามารถใช้ [`rescue_from`][] บนช่องที่ระบุเพื่อจัดการข้อยกเว้นที่เกิดขึ้น:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  private
    def deliver_error_message(e)
      broadcast_to(...)
    end
end
```

#### Channel Callbacks

`ApplicationCable::Channel` มีคำสั่งเรียกกลับหลายรูปแบบที่สามารถใช้เพื่อเรียกใช้ตรรกะในระหว่างวงจรช่องได้ คำสั่งเรียกกลับที่มีให้ใช้งานได้มีดังนี้:

- `before_subscribe`
- `after_subscribe` (ยังเรียกว่า: `on_subscribe`)
- `before_unsubscribe`
- `after_unsubscribe` (ยังเรียกว่า: `on_unsubscribe`)

หมายเหตุ: คำสั่งเรียกกลับ `after_subscribe` จะถูกเรียกเมื่อเรียกใช้เมธอด `subscribed` ไม่ว่าการสมัครสมาชิกจะถูกปฏิเสธด้วยเมธอด `reject` หรือไม่ หากต้องการเรียกใช้ `after_subscribe` เฉพาะในการสมัครสมาชิกที่ประสบความสำเร็จเท่านั้น ให้ใช้ `after_subscribe :send_welcome_message, unless: :subscription_rejected?`

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  after_subscribe :send_welcome_message, unless: :subscription_rejected?
  after_subscribe :track_subscription

  private
    def send_welcome_message
      broadcast_to(...)
    end

    def track_subscription
      # ...
    end
end
```

## องค์ประกอบด้านลูกค้า

### การเชื่อมต่อ

ผู้บริโภคต้องการการเชื่อมต่อของการเชื่อมต่อในฝั่งของพวกเขา สามารถทำได้โดยใช้ JavaScript ต่อไปนี้ ซึ่งถูกสร้างขึ้นโดยค่าเริ่มต้นของ Rails:

#### เชื่อมต่อผู้บริโภค

```js
// app/javascript/channels/consumer.js
// Action Cable ให้กรอบการจัดการกับ WebSockets ใน Rails
// คุณสามารถสร้างช่องใหม่ที่มีคุณสมบัติ WebSocket โดยใช้คำสั่ง `bin/rails generate channel`

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
```

นี้จะเตรียมผู้บริโภคที่จะเชื่อมต่อกับ `/cable` บนเซิร์ฟเวอร์ของคุณโดยค่าเริ่มต้น
การเชื่อมต่อจะไม่ถูกสร้างขึ้นจนกว่าคุณจะระบุการสมัครสมาชิกอย่างน้อยหนึ่งรายการที่คุณสนใจ

ผู้บริโภคสามารถรับอาร์กิวเมนต์ที่ระบุ URL ที่จะเชื่อมต่อไปได้เพิ่มเติม สามารถเป็นสตริงหรือฟังก์ชันที่ส่งคืนสตริงที่จะถูกเรียกเมื่อ WebSocket เปิด

```js
// ระบุ URL ที่แตกต่างกันในการเชื่อมต่อ
createConsumer('wss://example.com/cable')
// หรือเมื่อใช้ websockets ผ่าน HTTP
createConsumer('https://ws.example.com/cable')

// ใช้ฟังก์ชันเพื่อสร้าง URL ได้แบบไดนามิก
createConsumer(getWebSocketURL)

function getWebSocketURL() {
  const token = localStorage.get('auth-token')
  return `wss://example.com/cable?token=${token}`
}
```

#### ผู้สมัครสมาชิก

ผู้บริโภคกลายเป็นผู้สมัครสมาชิกโดยการสร้างการสมัครสมาชิกกับช่องที่กำหนด:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" })

// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AppearanceChannel" })
```

ในขณะที่สร้างการสมัครสมาชิกนี้ ฟังก์ชันที่จำเป็นต้องตอบสนองกับข้อมูลที่ได้รับจะถูกอธิบายในภายหลัง

ผู้บริโภคสามารถทำหน้าที่เป็นผู้สมัครสมาชิกกับช่องที่กำหนดได้เท่าที่ต้องการ ตัวอย่างเช่น ผู้บริโภคสามารถสมัครสมาชิกกับห้องแชทหลายห้องในเวลาเดียวกันได้:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "1st Room" })
consumer.subscriptions.create({ channel: "ChatChannel", room: "2nd Room" })
```

## การติดต่อระหว่างเครื่องลูกค้าและเซิร์ฟเวอร์

### สตรีม

*สตรีม* ให้กลไกที่ช่องเส้นทางการเผยแพร่เนื้อหา (การแพร่กระจาย) ไปยังผู้สมัครสมาชิกของช่องนั้น ตัวอย่างเช่น รหัสต่อไปนี้ใช้ [`stream_from`][] เพื่อสมัครสมาชิกกับการแพร่กระจายที่ชื่อว่า `chat_Best Room` เมื่อค่าของพารามิเตอร์ `:room` เป็น `"Best Room"`:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

จากนั้น ในแอปพลิเคชัน Rails ของคุณที่อื่น ๆ คุณสามารถส่งออกไปยังห้องดังกล่าวโดยเรียกใช้ [`broadcast`][]:

```ruby
ActionCable.server.broadcast("chat_Best Room", { body: "ห้องนี้เป็นห้องที่ดีที่สุด" })
```

หากคุณมีการสตรีมที่เกี่ยวข้องกับโมเดล แล้วชื่อการส่งออกสามารถสร้างจากช่องและโมเดลได้ ตัวอย่างเช่น โค้ดต่อไปนี้ใช้ [`stream_for`][] เพื่อสมัครสมาชิกในการส่งออกเช่น `posts:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE` โดยที่ `Z2lkOi8vVGVzdEFwcC9Qb3N0LzE` เป็น GlobalID ของโมเดลโพสต์

```ruby
class PostsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

คุณสามารถส่งออกไปยังช่องนี้ได้โดยเรียกใช้ [`broadcast_to`][]:

```ruby
PostsChannel.broadcast_to(@post, @comment)
```


### การส่งออก

*การส่งออก* เป็นการเชื่อมต่อแบบ pub/sub ที่สิ่งใดที่ถูกส่งออกโดยผู้เผยแพร่จะถูกส่งตรงไปยังผู้สมัครสมาชิกของช่องที่กำลังสตรีมการส่งออกนั้น แต่ละช่องสามารถสตรีมการส่งออกได้ศูนย์หรือมากกว่า

การส่งออกเป็นคิวที่ออนไลน์และขึ้นอยู่กับเวลา หากผู้บริโภคไม่ได้สตรีม (สมัครสมาชิกกับช่องที่กำหนด) พวกเขาจะไม่ได้รับการส่งออกเมื่อพวกเขาเชื่อมต่อในภายหลัง

### การสมัครสมาชิก

เมื่อผู้บริโภคสมัครสมาชิกกับช่อง พวกเขาจะทำหน้าที่เป็นผู้สมัครสมาชิก การเชื่อมต่อนี้เรียกว่าการสมัครสมาชิก ข้อความที่เข้ามาจะถูกส่งไปยังการสมัครสมาชิกของช่องเหล่านี้โดยอิงตามตัวระบุที่ถูกส่งมาจากผู้ใช้เคเบิล

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

### การส่งพารามิเตอร์ไปยังช่อง

คุณสามารถส่งพารามิเตอร์จากฝั่งไคลเอ็นต์ไปยังฝั่งเซิร์ฟเวอร์เมื่อสร้างการสมัครสมาชิก ตัวอย่างเช่น:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

วัตถุที่ถูกส่งเป็นอาร์กิวเมนต์แรกใน `subscriptions.create` กลายเป็นแฮชพารามิเตอร์ในช่องเคเบิล คำสำคัญ `channel` เป็นสิ่งที่จำเป็น:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

```ruby
# ที่ใดที่แอปของคุณเรียกใช้งานนี้ บางที
# จาก NewCommentJob
ActionCable.server.broadcast(
  "chat_#{room}",
  {
    sent_by: 'Paul',
    body: 'แอปแชทนี้เยี่ยมมาก'
  }
)
```

### การส่งออกข้อความซ้ำ

กรณีการใช้ที่พบบ่อยคือการ *ส่งออกข้อความซ้ำ* ที่ถูกส่งโดยไคลเอ็นต์หนึ่งไปยังไคลเอ็นต์ที่เชื่อมต่ออื่น ๆ

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def receive(data)
    ActionCable.server.broadcast("chat_#{params[:room]}", data)
  end
end
```

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    // data => { sent_by: "Paul", body: "แอปแชทนี้เยี่ยมมาก" }
  }
}

chatChannel.send({ sent_by: "Paul", body: "แอปแชทนี้เยี่ยมมาก" })
```

การส่งออกซ้ำจะถูกรับโดยไคลเอ็นต์ที่เชื่อมต่อทั้งหมด รวมถึงไคลเอ็นต์ที่ส่งข้อความด้วย โปรดทราบว่าพารามิเตอร์เหมือนเดิมกับเมื่อคุณสมัครสมาชิกกับช่อง
## ตัวอย่าง Full-Stack

ขั้นตอนการติดตั้งต่อไปนี้เป็นขั้นตอนที่เหมือนกันสำหรับทั้งสองตัวอย่าง:

  1. [ติดตั้งการเชื่อมต่อ](#connection-setup).
  2. [ติดตั้งช่องส่วนหลัก](#parent-channel-setup).
  3. [เชื่อมต่อผู้บริโภค](#connect-consumer).

### ตัวอย่างที่ 1: การปรากฏตัวของผู้ใช้

นี่คือตัวอย่างง่ายๆ ของช่องที่ติดตามว่าผู้ใช้เป็นออนไลน์หรือไม่
และหน้าที่พวกเขาอยู่ (สิ่งนี้เป็นประโยชน์ในการสร้างคุณลักษณะการปรากฏตัวเช่นการแสดง
จุดสีเขียวข้างข้างชื่อผู้ใช้ถ้าพวกเขาออนไลน์)

สร้างช่องการปรากฏตัวของเซิร์ฟเวอร์:

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    current_user.appear
  end

  def unsubscribed
    current_user.disappear
  end

  def appear(data)
    current_user.appear(on: data['appearing_on'])
  end

  def away
    current_user.away
  end
end
```

เมื่อการสมัครสมาชิกเริ่มต้น จะเรียกใช้งาน `subscribed` callback และเรา
ใช้โอกาสนี้เพื่อบอกว่า "ผู้ใช้ปัจจุบันได้ปรากฏตัวแล้ว" ฟังก์ชัน
appear/disappear นี้อาจมีการสนับสนุนจาก Redis, ฐานข้อมูล หรือสิ่งอื่นๆ

สร้างการสมัครสมาชิกของช่องการปรากฏตัวทางด้านไคลเอ็นต์:

```js
// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("AppearanceChannel", {
  // เรียกใช้ครั้งเดียวเมื่อสร้างการสมัครสมาชิก
  initialized() {
    this.update = this.update.bind(this)
  },

  // เรียกเมื่อการสมัครสมาชิกพร้อมใช้งานบนเซิร์ฟเวอร์
  connected() {
    this.install()
    this.update()
  },

  // เรียกเมื่อการเชื่อมต่อ WebSocket ถูกปิด
  disconnected() {
    this.uninstall()
  },

  // เรียกเมื่อการสมัครสมาชิกถูกปฏิเสธโดยเซิร์ฟเวอร์
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // เรียกใช้ `AppearanceChannel#appear(data)` บนเซิร์ฟเวอร์
    this.perform("appear", { appearing_on: this.appearingOn })
  },

  away() {
    // เรียกใช้ `AppearanceChannel#away` บนเซิร์ฟเวอร์
    this.perform("away")
  },

  install() {
    window.addEventListener("focus", this.update)
    window.addEventListener("blur", this.update)
    document.addEventListener("turbo:load", this.update)
    document.addEventListener("visibilitychange", this.update)
  },

  uninstall() {
    window.removeEventListener("focus", this.update)
    window.removeEventListener("blur", this.update)
    document.removeEventListener("turbo:load", this.update)
    document.removeEventListener("visibilitychange", this.update)
  },

  get documentIsActive() {
    return document.visibilityState === "visible" && document.hasFocus()
  },

  get appearingOn() {
    const element = document.querySelector("[data-appearing-on]")
    return element ? element.getAttribute("data-appearing-on") : null
  }
})
```

#### การโต้ตอบระหว่างไคลเอ็นต์และเซิร์ฟเวอร์

1. **ไคลเอ็นต์** เชื่อมต่อกับ **เซิร์ฟเวอร์** ผ่าน `createConsumer()` (`consumer.js`) 
   **เซิร์ฟเวอร์** ระบุการเชื่อมต่อนี้โดย `current_user`.

2. **ไคลเอ็นต์** สมัครสมาชิกช่องการปรากฏตัวผ่าน
   `consumer.subscriptions.create({ channel: "AppearanceChannel" })` (`appearance_channel.js`)

3. **เซิร์ฟเวอร์** รับรู้ว่ามีการสมัครสมาชิกใหม่สำหรับช่องการปรากฏตัวและเรียกใช้งาน `subscribed` callback ของมัน
   โดยเรียกใช้เมธอด `appear` บน `current_user` (`appearance_channel.rb`)

4. **ไคลเอ็นต์** รับรู้ว่าการสมัครสมาชิกได้รับการสร้างและเรียกใช้งาน `connected` (`appearance_channel.js`) 
   ซึ่งเรียกใช้งาน `install` และ `appear` `appear` เรียกใช้ `AppearanceChannel#appear(data)` บนเซิร์ฟเวอร์
   และให้ข้อมูลแฮชของ `{ appearing_on: this.appearingOn }` สิ่งนี้เป็นไปได้เพราะตัวอย่างช่องด้านเซิร์ฟเวอร์จะเปิดเผยโดยอัตโนมัติ
   ว่ามีเมธอดสาธารณะที่ถูกประกาศในคลาส (ยกเว้น callback) เพื่อให้สามารถเรียกใช้งานได้เป็นการเรียกใช้งานระยะไกลผ่านเมธอด `perform` ของการสมัครสมาชิก

5. **เซิร์ฟเวอร์** ได้รับคำขอสำหรับการกระทำ `appear` บนช่องการปรากฏตัวสำหรับการเชื่อมต่อที่ระบุโดย `current_user`
   (`appearance_channel.rb`) **เซิร์ฟเวอร์** ดึงข้อมูลด้วยคีย์ `:appearing_on` จากแฮชข้อมูลและตั้งค่าเป็นค่าสำหรับคีย์ `:on`
   ที่ถูกส่งไปยัง `current_user.appear`.

### ตัวอย่างที่ 2: การรับการแจ้งเตือนเว็บใหม่

ตัวอย่างการปรากฏตัวข้างต้นเกี่ยวกับการเปิดเผยฟังก์ชันของเซิร์ฟเวอร์ไปยังการเรียกใช้งานด้านไคลเอ็นต์ผ่านการเชื่อมต่อ WebSocket แต่สิ่งที่ยอดเยี่ยมกับ WebSocket คือมันเป็นถนนสองทาง ดังนั้น ตอนนี้เราจะแสดงตัวอย่างที่เซิร์ฟเวอร์เรียกใช้งานการกระทำบนไคลเอ็นต์
นี่คือช่องแจ้งเตือนเว็บที่ช่วยให้คุณสามารถเรียกใช้การแจ้งเตือนด้านลูกค้าได้เมื่อคุณส่งออกไปยังสตรีมที่เกี่ยวข้อง:

สร้างช่องแจ้งเตือนเว็บด้านเซิร์ฟเวอร์:

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

สร้างการสมัครสมาชิกช่องแจ้งเตือนเว็บด้านลูกค้า:

```js
// app/javascript/channels/web_notifications_channel.js
// ด้านลูกค้าซึ่งถือว่าคุณได้ร้องขอสิทธิ์ในการส่งการแจ้งเตือนเว็บไปแล้ว
import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  received(data) {
    new Notification(data["title"], { body: data["body"] })
  }
})
```

ส่งเนื้อหาไปยังช่องแจ้งเตือนเว็บจากที่อื่นในแอปพลิเคชันของคุณ:

```ruby
# ที่ใดก็ตามในแอปของคุณที่เรียกใช้งาน, บางทีจาก NewCommentJob
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'สิ่งใหม่!',
  body: 'ข่าวทั้งหมดที่เหมาะสมที่จะพิมพ์'
)
```

การเรียกใช้ `WebNotificationsChannel.broadcast_to` จะวางข้อความในคิว pubsub ของแอดาปเตอร์การสมัครสมาชิกปัจจุบันในชื่อการแพร่กระจายแยกต่างหากสำหรับแต่ละผู้ใช้ สำหรับผู้ใช้ที่มี ID เป็น 1 ชื่อการแพร่กระจายจะเป็น `web_notifications:1`

ช่องได้รับคำสั่งให้สตรีมทุกอย่างที่มาถึงที่ `web_notifications:1` โดยตรงไปยังไคลเอ็นต์โดยเรียกใช้งาน `received` callback ข้อมูลที่ส่งผ่านเป็นอาร์กิวเมนต์คือแฮชที่ส่งเป็นพารามิเตอร์ที่สองในการเรียกส่งของฝั่งเซิร์ฟเวอร์ และถูกเข้ารหัสเป็น JSON สำหรับการเดินทางข้ามสายและถูกแกะสำหรับอาร์กิวเมนต์ข้อมูลที่มาเป็น `received`

### ตัวอย่างที่ครบถ้วนมากขึ้น

ดูที่ [rails/actioncable-examples](https://github.com/rails/actioncable-examples)
เก็บรวมตัวอย่างเต็มรูปแบบเกี่ยวกับวิธีการตั้งค่า Action Cable ในแอป Rails และการเพิ่มช่อง

## การกำหนดค่า

Action Cable มีการกำหนดค่าสองอย่างที่จำเป็น: ตัวอักษรการสมัครสมาชิกและต้นทางคำขอที่อนุญาต

### ตัวอักษรการสมัครสมาชิก

ตามค่าเริ่มต้น Action Cable จะค้นหาไฟล์การกำหนดค่าใน `config/cable.yml`
ไฟล์ต้องระบุตัวอักษรสำหรับแต่ละสภาพแวดล้อมของ Rails ดู
[Dependencies](#dependencies) ส่วนสำหรับข้อมูลเพิ่มเติมเกี่ยวกับตัวอักษร

```yaml
development:
  adapter: async

test:
  adapter: test

production:
  adapter: redis
  url: redis://10.10.3.153:6381
  channel_prefix: appname_production
```

#### การกำหนดค่าแอดาปเตอร์

ด้านล่างนี้คือรายการแอดาปเตอร์การสมัครสมาชิกที่ใช้งานได้สำหรับผู้ใช้ที่สิ้นสุด

##### แอดาปเตอร์ Async

แอดาปเตอร์ Async ใช้สำหรับการพัฒนา/ทดสอบและไม่ควรใช้ในการดำเนินงานจริง

##### แอดาปเตอร์ Redis

แอดาปเตอร์ Redis ต้องการผู้ใช้ที่จะให้ URL ชี้ไปที่เซิร์ฟเวอร์ Redis
นอกจากนี้ยังสามารถระบุ `channel_prefix` เพื่อหลีกเลี่ยงการชื่อช่องที่ซ้ำซ้อนเมื่อใช้เซิร์ฟเวอร์ Redis เดียวกันสำหรับแอปพลิเคชันหลายๆ แอปพลิเคชัน ดู
[Redis Pub/Sub documentation](https://redis.io/docs/manual/pubsub/#database--scoping) สำหรับข้อมูลเพิ่มเติม

แอดาปเตอร์ Redis ยังรองรับการเชื่อมต่อ SSL/TLS พารามิเตอร์ที่จำเป็นสามารถส่งผ่านใน `ssl_params` ในไฟล์การกำหนดค่า YAML

```
production:
  adapter: redis
  url: rediss://10.10.3.153:tls_port
  channel_prefix: appname_production
  ssl_params: {
    ca_file: "/path/to/ca.crt"
  }
```

ตัวเลือกที่ให้กับ `ssl_params` ถูกส่งตรงไปยังวิธี `OpenSSL::SSL::SSLContext#set_params` และสามารถเป็นแอตทริบิวต์ที่ถูกต้องของบริบท SSL
โปรดอ้างอิงที่ [OpenSSL::SSL::SSLContext documentation](https://docs.ruby-lang.org/en/master/OpenSSL/SSL/SSLContext.html) สำหรับแอตทริบิวต์ที่มีอยู่

หากคุณใช้ใบรับรองที่ลงชื่อด้วยตนเองสำหรับแอดาปเตอร์ Redis อยู่หลังไฟร์วอลล์และเลือกที่จะข้ามการตรวจสอบใบรับรอง แล้ว ssl `verify_mode` ควรตั้งค่าเป็น `OpenSSL::SSL::VERIFY_NONE`

คำเตือน: ไม่แนะนำให้ใช้ `VERIFY_NONE` ในการดำเนินงานจริง ยกเว้นว่าคุณเข้าใจผลกระทบด้านความปลอดภัยอย่างแน่นอน ในการตั้งค่าตัวเลือกนี้สำหรับแอดาปเตอร์ Redis ควรเป็น `ssl_params: { verify_mode: <%= OpenSSL::SSL::VERIFY_NONE %> }`
##### อะแดปเตอร์ PostgreSQL

อะแดปเตอร์ PostgreSQL ใช้พูลการเชื่อมต่อของ Active Record และดังนั้นการกำหนดค่าฐานข้อมูลใน `config/database.yml` ของแอปพลิเคชันสำหรับการเชื่อมต่อ นี่อาจเปลี่ยนแปลงในอนาคต [#27214](https://github.com/rails/rails/issues/27214)

### ต้นกำเนิดคำขอที่อนุญาต

Action Cable จะยอมรับเฉพาะคำขอจากต้นกำเนิดที่ระบุไว้เท่านั้น ซึ่งถูกส่งให้กับการกำหนดค่าเซิร์ฟเวอร์เป็นอาร์เรย์ ต้นกำเนิดสามารถเป็นสตริงหรือเป็นสมการปรกติที่จะถูกตรวจสอบว่าตรงกันหรือไม่

```ruby
config.action_cable.allowed_request_origins = ['https://rubyonrails.com', %r{http://ruby.*}]
```

ในการปิดใช้งานและอนุญาตให้คำขอมาจากต้นกำเนิดใดก็ได้:

```ruby
config.action_cable.disable_request_forgery_protection = true
```

โดยค่าเริ่มต้น Action Cable อนุญาตให้คำขอทั้งหมดมาจาก localhost:3000 เมื่อทำงานในสภาพแวดล้อมการพัฒนา

### การกำหนดค่า Consumer

ในการกำหนดค่า URL เพิ่มการเรียกใช้ [`action_cable_meta_tag`][] ในหัวเอกสาร HTML layout ของคุณ นี่ใช้ URL หรือเส้นทางที่ตั้งค่าโดยปกติผ่าน [`config.action_cable.url`][] ในไฟล์การกำหนดค่าสภาพแวดล้อม

### การกำหนดค่า Worker Pool

พูลของเวิร์กเกอร์ถูกใช้ในการเรียกใช้งานเชื่อมต่อและการดำเนินการของช่องในการแยกจากเธรดหลักของเซิร์ฟเวอร์ Action Cable อนุญาตให้แอปพลิเคชันกำหนดจำนวนเธรดที่ประมวลผลพร้อมกันในพูลของเวิร์กเกอร์

```ruby
config.action_cable.worker_pool_size = 4
```

นอกจากนี้ โปรดทราบว่าเซิร์ฟเวอร์ของคุณต้องให้การเชื่อมต่อฐานข้อมูลอย่างน้อยเท่ากับจำนวนเวิร์กเกอร์ที่คุณมี ขนาดของพูลของเวิร์กเกอร์เริ่มต้นถูกตั้งค่าเป็น 4 ซึ่งหมายความว่าคุณต้องมีการเชื่อมต่อฐานข้อมูลอย่างน้อย 4 รายการที่พร้อมใช้งาน คุณสามารถเปลี่ยนแปลงได้ใน `config/database.yml` ผ่านคุณสมบัติ `pool`

### การบันทึกข้อมูลทางไคลเอ็นต์

การบันทึกข้อมูลทางไคลเอ็นต์ถูกปิดใช้งานตามค่าเริ่มต้น คุณสามารถเปิดใช้งานได้โดยตั้งค่า `ActionCable.logger.enabled` เป็น true

```ruby
import * as ActionCable from '@rails/actioncable'

ActionCable.logger.enabled = true
```

### การกำหนดค่าอื่น ๆ

ตัวเลือกที่พบบ่อยอื่น ๆ ในการกำหนดค่าคือแท็กบันทึกที่ใช้กับเครื่องบันทึกต่อการเชื่อมต่อแต่ละต่อ ต่อไปนี้คือตัวอย่างที่ใช้
รหัสบัญชีผู้ใช้ถ้ามี มิฉะนั้นใช้ "no-account" ในขณะที่แท็ก:

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

สำหรับรายการเต็มของตัวเลือกการกำหนดค่าทั้งหมด โปรดดูคลาส `ActionCable::Server::Configuration`

## การเรียกใช้เซิร์ฟเวอร์เคเบิลแบบแยกต่างหาก

Action Cable สามารถทำงานร่วมกับแอปพลิเคชัน Rails ของคุณหรือเป็นเซิร์ฟเวอร์แยกต่างหาก ในการพัฒนา การทำงานร่วมกับแอปพลิเคชัน Rails
เป็นสิ่งปกติ แต่ในการดำเนินการควรเรียกใช้เป็นเซิร์ฟเวอร์แยกต่างหากในการดำเนินการจริง

### ในแอปพลิเคชัน

Action Cable สามารถทำงานร่วมกับแอปพลิเคชัน Rails ของคุณ ตัวอย่างเช่น เพื่อรับคำขอ WebSocket ที่เส้นทาง `/websocket` ระบุเส้นทางนั้นไปยัง
[`config.action_cable.mount_path`][]:

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

คุณสามารถใช้ `ActionCable.createConsumer()` เพื่อเชื่อมต่อกับเซิร์ฟเวอร์เคเบิลหาก [`action_cable_meta_tag`][] ถูกเรียกใช้ในเลเอาท์ มิฉะนั้นเส้นทางจะถูกระบุเป็นอาร์กิวเมนต์แรกของ `createConsumer` (เช่น `ActionCable.createConsumer("/websocket")`)

สำหรับทุกตัวอย่างของเซิร์ฟเวอร์ที่คุณสร้าง และสำหรับทุกเวิร์กเกอร์ที่เซิร์ฟเวอร์ของคุณสร้างขึ้น คุณจะมีตัวอย่างใหม่ของ Action Cable แต่อะแดปเตอร์ Redis หรือ PostgreSQL จะเก็บข้อความที่ซิงค์กันระหว่างการเชื่อมต่อ

### แยกต่างหาก

เซิร์ฟเวอร์เคเบิลสามารถแยกจากเซิร์ฟเวอร์แอปพลิเคชันปกติของคุณได้ นี่ยังเป็นแอปพลิเคชันแบบ Rack แต่เป็นแอปพลิเคชันแบบตัวเอง การตั้งค่าพื้นฐานที่แนะนำคือดังนี้:
```ruby
# cable/config.ru
require_relative "../config/environment"
Rails.application.eager_load!

run ActionCable.server
```

จากนั้นเพื่อเริ่มเซิร์ฟเวอร์:

```
bundle exec puma -p 28080 cable/config.ru
```

นี้จะเริ่มเซิร์ฟเวอร์เคเบิลบนพอร์ต 28080 ให้ Rails ใช้เซิร์ฟเวอร์นี้ อัปเดตค่าใน config:

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_cable.mount_path = nil
  config.action_cable.url = "ws://localhost:28080" # ในการใช้งานจริงให้ใช้ wss://
end
```

ในที่สุด ตรวจสอบให้แน่ใจว่าคุณได้ [กำหนดค่าคอนซูเมอร์อย่างถูกต้อง](#consumer-configuration).

### หมายเหตุ

เซิร์ฟเวอร์ WebSocket ไม่สามารถเข้าถึงเซสชันได้ แต่สามารถเข้าถึงคุกกี้ได้ สามารถใช้ได้เมื่อคุณต้องการจัดการการรับรองความถูกต้อง คุณสามารถดูวิธีการทำงานนั้นด้วย Devise ในบทความนี้ [article](https://greg.molnar.io/blog/actioncable-devise-authentication/).

## ขึ้นอยู่กับ

Action Cable ให้ส่วนเสริมการสมัครสมาชิกในการประมวลผลภายใน pubsub ของมัน ตามค่าเริ่มต้น มีส่วนเสริม asynchronous, inline, PostgreSQL, และ Redis รวมอยู่ ส่วนเสริมเริ่มต้น
ในแอปพลิเคชัน Rails ใหม่คือส่วนเสริม asynchronous (`async`).

ด้าน Ruby สร้างขึ้นบน [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r), และ [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby).

## การปรับใช้

Action Cable ใช้เทคนิคการประยุกต์ใช้ WebSockets และเธรด การทำงานทั้งสองของโครงสร้างและการทำงานของช่องทางที่ระบุโดยผู้ใช้จัดการภายในโดยใช้การสนับสนุนเธรดของ Ruby ที่เป็นธรรมชาติ นี้หมายความว่าคุณสามารถใช้โมเดล Rails ทั้งหมดที่มีอยู่โดยไม่มีปัญหา ตราบเท่าที่คุณไม่ได้กระทำผิดกฎความปลอดภัยของเธรด

เซิร์ฟเวอร์ Action Cable นำเสนอ API การยึดความคลาดเคลื่อนของ Rack socket ทำให้สามารถใช้รูปแบบการจัดการหลายเธรดในการจัดการการเชื่อมต่อภายในได้โดยไม่สนใจว่าเซิร์ฟเวอร์แอปพลิเคชันมีการใช้เธรดหลายเธรดหรือไม่

ดังนั้น Action Cable ทำงานร่วมกับเซิร์ฟเวอร์ยอดนิยมเช่น Unicorn, Puma, และ
Passenger.

## การทดสอบ

คุณสามารถหาคำแนะนำอย่างละเอียดเกี่ยวกับวิธีการทดสอบความสามารถของ Action Cable ของคุณใน
[testing guide](testing.html#testing-action-cable).
[`ActionCable::Connection::Base`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Base.html
[`identified_by`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Identification/ClassMethods.html#method-i-identified_by
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`ActionCable::Channel::Base`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html
[`broadcast`]: https://api.rubyonrails.org/classes/ActionCable/Server/Broadcasting.html#method-i-broadcast
[`broadcast_to`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Broadcasting/ClassMethods.html#method-i-broadcast_to
[`stream_for`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_for
[`stream_from`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_from
[`config.action_cable.url`]: configuring.html#config-action-cable-url
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
[`config.action_cable.mount_path`]: configuring.html#config-action-cable-mount-path
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
