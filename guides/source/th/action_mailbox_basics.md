**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a547b83b6f036a8e81899330fd515663
พื้นฐานของ Action Mailbox
=====================

เอกสารนี้จะให้คุณทราบทุกสิ่งที่คุณต้องการเพื่อเริ่มรับอีเมลในแอปพลิเคชันของคุณ

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีรับอีเมลภายในแอปพลิเคชัน Rails
* วิธีกำหนดค่า Action Mailbox
* วิธีสร้างและเส้นทางอีเมลไปยังกล่องจดหมาย
* วิธีทดสอบอีเมลที่เข้ามา

--------------------------------------------------------------------------------

Action Mailbox คืออะไร?
-----------------------

Action Mailbox นำเสนอการเส้นทางอีเมลที่เข้ามาไปยังกล่องจดหมายที่คล้ายกับคอนโทรลเลอร์สำหรับการประมวลผลใน Rails มันมาพร้อมกับ Ingress สำหรับ Mailgun, Mandrill, Postmark และ SendGrid คุณยังสามารถจัดการอีเมลที่เข้ามาได้โดยตรงผ่าน Ingress ที่มีอยู่แบบ Exim, Postfix และ Qmail

อีเมลที่เข้ามาจะถูกแปลงเป็นเร็คคอร์ด `InboundEmail` โดยใช้ Active Record และมีการติดตามวงจรชีวิต, การจัดเก็บอีเมลต้นฉบับในการจัดเก็บคลาวด์ผ่าน Active Storage และการจัดการข้อมูลที่รับผิดชอบด้วยการทำลายทิ้งที่เปิดใช้งานตามค่าเริ่มต้น

อีเมลเข้าทางนี้จะถูกเส้นทางแบบไม่เชื่อมต่อโดยใช้ Active Job ไปยังกล่องจดหมายหนึ่งหรือหลายกล่องที่สามารถทำงานร่วมกับโมเดลโดเมนอื่น ๆ ของคุณได้

## การติดตั้ง

ติดตั้งการเคลื่อนย้ายที่จำเป็นสำหรับ `InboundEmail` และตรวจสอบให้แน่ใจว่า Active Storage ถูกติดตั้ง:

```bash
$ bin/rails action_mailbox:install
$ bin/rails db:migrate
```

## การกำหนดค่า

### Exim

บอก Action Mailbox ให้ยอมรับอีเมลจาก SMTP relay:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

สร้างรหัสผ่านที่แข็งแกร่งที่ Action Mailbox สามารถใช้ในการตรวจสอบคำขอสู่ Ingress ได้

ใช้ `bin/rails credentials:edit` เพื่อเพิ่มรหัสผ่านลงในข้อมูลประกอบที่เข้ารหัสของแอปพลิเคชันของคุณภายใต้ `action_mailbox.ingress_password` ที่ Action Mailbox จะค้นหาโดยอัตโนมัติ:

```yaml
action_mailbox:
  ingress_password: ...
```

หรือให้รหัสผ่านในตัวแปรสภาพแวดล้อม `RAILS_INBOUND_EMAIL_PASSWORD`

กำหนดค่า Exim ให้ส่งอีเมลเข้ามาที่ `bin/rails action_mailbox:ingress:exim` โดยให้ `URL` ของ Ingress และ `INGRESS_PASSWORD` ที่คุณสร้างไว้ก่อนหน้านี้ หากแอปพลิเคชันของคุณอยู่ที่ `https://example.com` คำสั่งเต็มจะมีรูปแบบดังนี้:

```bash
$ bin/rails action_mailbox:ingress:exim URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun

ให้ Action Mailbox รับรู้คีย์การเซ็นต์ของ Mailgun (ซึ่งคุณสามารถค้นหาได้ที่ Settings -> Security & Users -> API security ใน Mailgun) เพื่อให้สามารถตรวจสอบคำขอสู่ Mailgun ingress ได้

ใช้ `bin/rails credentials:edit` เพื่อเพิ่มคีย์การเซ็นต์ลงในข้อมูลประกอบที่เข้ารหัสของแอปพลิเคชันของคุณภายใต้ `action_mailbox.mailgun_signing_key` ที่ Action Mailbox จะค้นหาโดยอัตโนมัติ:

```yaml
action_mailbox:
  mailgun_signing_key: ...
```

หรือให้คีย์การเซ็นต์ของคุณในตัวแปรสภาพแวดล้อม `MAILGUN_INGRESS_SIGNING_KEY`

บอก Action Mailbox ให้ยอมรับอีเมลจาก Mailgun:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mailgun
```

[กำหนดค่า Mailgun](https://documentation.mailgun.com/en/latest/user_manual.html#receiving-forwarding-and-storing-messages)
ให้ส่งอีเมลเข้ามาที่ `/rails/action_mailbox/mailgun/inbound_emails/mime` หากแอปพลิเคชันของคุณอยู่ที่ `https://example.com` คุณจะระบุ URL ที่เต็มรูปแบบ `https://example.com/rails/action_mailbox/mailgun/inbound_emails/mime`

### Mandrill

ให้ Action Mailbox รับรู้คีย์ API ของ Mandrill เพื่อให้สามารถตรวจสอบคำขอสู่ Mandrill ingress ได้

ใช้ `bin/rails credentials:edit` เพื่อเพิ่มคีย์ API ของคุณลงในข้อมูลประกอบที่เข้ารหัสของแอปพลิเคชันของคุณภายใต้ `action_mailbox.mandrill_api_key` ที่ Action Mailbox จะค้นหาโดยอัตโนมัติ:

```yaml
action_mailbox:
  mandrill_api_key: ...
```

หรือให้คีย์ API ของคุณในตัวแปรสภาพแวดล้อม `MANDRILL_INGRESS_API_KEY`

บอก Action Mailbox ให้ยอมรับอีเมลจาก Mandrill:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mandrill
```

[กำหนดค่า Mandrill](https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview)
ให้เส้นทางอีเมลเข้ามาที่ `/rails/action_mailbox/mandrill/inbound_emails` หากแอปพลิเคชันของคุณอยู่ที่ `https://example.com` คุณจะระบุ URL ที่เต็มรูปแบบ `https://example.com/rails/action_mailbox/mandrill/inbound_emails`

### Postfix

บอก Action Mailbox ให้ยอมรับอีเมลจาก SMTP relay:
```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

สร้างรหัสผ่านที่แข็งแกร่งให้ Action Mailbox ใช้ในการตรวจสอบคำขอสู่ระบบของ relay ingress

ใช้ `bin/rails credentials:edit` เพื่อเพิ่มรหัสผ่านลงในข้อมูลรับรองที่เข้ารหัสของแอปพลิเคชันของคุณภายใต้ `action_mailbox.ingress_password` ที่ Action Mailbox จะค้นหาโดยอัตโนมัติ:

```yaml
action_mailbox:
  ingress_password: ...
```

หรือให้รหัสผ่านในตัวแปรสภาพแวดล้อม `RAILS_INBOUND_EMAIL_PASSWORD`

[กำหนดค่า Postfix](https://serverfault.com/questions/258469/how-to-configure-postfix-to-pipe-all-incoming-email-to-a-script)
เพื่อส่งอีเมลเข้ารหัสไปยัง `bin/rails action_mailbox:ingress:postfix` โดยให้
`URL` ของ Postfix ingress และ `INGRESS_PASSWORD` ที่คุณได้สร้างไว้ก่อนหน้านี้
หากแอปพลิเคชันของคุณอยู่ที่ `https://example.com` คำสั่งเต็มจะมีรูปแบบดังนี้:

```bash
$ bin/rails action_mailbox:ingress:postfix URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Postmark

บอก Action Mailbox ให้ยอมรับอีเมลจาก Postmark:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :postmark
```

สร้างรหัสผ่านที่แข็งแกร่งให้ Action Mailbox ใช้ในการตรวจสอบคำขอสู่ระบบของ Postmark ingress

ใช้ `bin/rails credentials:edit` เพื่อเพิ่มรหัสผ่านลงในข้อมูลรับรองที่เข้ารหัสของแอปพลิเคชันของคุณภายใต้ `action_mailbox.ingress_password` ที่ Action Mailbox จะค้นหาโดยอัตโนมัติ:

```yaml
action_mailbox:
  ingress_password: ...
```

หรือให้รหัสผ่านในตัวแปรสภาพแวดล้อม `RAILS_INBOUND_EMAIL_PASSWORD`

[กำหนดค่า Postmark inbound webhook](https://postmarkapp.com/manual#configure-your-inbound-webhook-url)
เพื่อส่งอีเมลเข้ารหัสไปยัง `/rails/action_mailbox/postmark/inbound_emails` ด้วยชื่อผู้ใช้ `actionmailbox`
และรหัสผ่านที่คุณได้สร้างไว้ก่อนหน้านี้ หากแอปพลิเคชันของคุณอยู่ที่ `https://example.com` คุณจะ
กำหนดค่า SendGrid ด้วย URL ที่เต็มที่ต่อไปนี้:

```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/postmark/inbound_emails
```

หมายเหตุ: เมื่อกำหนดค่า webhook ขาเข้า SendGrid ของคุณ โปรดตรวจสอบช่องทำเครื่องหมาย **“Post the raw, full MIME message.”** Action Mailbox ต้องการข้อมูล MIME เต็มรูปแบบเพื่อทำงาน

### Qmail

บอก Action Mailbox ให้ยอมรับอีเมลจาก SMTP relay:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

สร้างรหัสผ่านที่แข็งแกร่งให้ Action Mailbox ใช้ในการตรวจสอบคำขอสู่ระบบของ relay ingress

ใช้ `bin/rails credentials:edit` เพื่อเพิ่มรหัสผ่านลงในข้อมูลรับรองที่เข้ารหัสของแอปพลิเคชันของคุณภายใต้ `action_mailbox.ingress_password` ที่ Action Mailbox จะค้นหาโดยอัตโนมัติ:

```yaml
action_mailbox:
  ingress_password: ...
```

หรือให้รหัสผ่านในตัวแปรสภาพแวดล้อม `RAILS_INBOUND_EMAIL_PASSWORD`

กำหนดค่า Qmail เพื่อส่งอีเมลเข้ารหัสไปยัง `bin/rails action_mailbox:ingress:qmail`
โดยให้ `URL` ของ relay ingress และ `INGRESS_PASSWORD` ที่คุณได้
สร้างไว้ก่อนหน้านี้ หากแอปพลิเคชันของคุณอยู่ที่ `https://example.com` คำสั่งเต็มจะมีรูปแบบดังนี้:

```bash
$ bin/rails action_mailbox:ingress:qmail URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### SendGrid

บอก Action Mailbox ให้ยอมรับอีเมลจาก SendGrid:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
```

สร้างรหัสผ่านที่แข็งแกร่งให้ Action Mailbox ใช้ในการตรวจสอบคำขอสู่ระบบของ SendGrid ingress

ใช้ `bin/rails credentials:edit` เพื่อเพิ่มรหัสผ่านลงในข้อมูลรับรองที่เข้ารหัสของแอปพลิเคชันของคุณภายใต้ `action_mailbox.ingress_password` ที่ Action Mailbox จะค้นหาโดยอัตโนมัติ:

```yaml
action_mailbox:
  ingress_password: ...
```

หรือให้รหัสผ่านในตัวแปรสภาพแวดล้อม `RAILS_INBOUND_EMAIL_PASSWORD`

[กำหนดค่า SendGrid Inbound Parse](https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/)
เพื่อส่งอีเมลเข้ารหัสไปยัง `/rails/action_mailbox/sendgrid/inbound_emails` ด้วยชื่อผู้ใช้ `actionmailbox`
และรหัสผ่านที่คุณได้สร้างไว้ก่อนหน้านี้ หากแอปพลิเคชันของคุณอยู่ที่ `https://example.com`
คุณจะกำหนดค่า SendGrid ด้วย URL ที่เต็มที่ต่อไปนี้:

```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/sendgrid/inbound_emails
```

หมายเหตุ: เมื่อกำหนดค่า webhook ขาเข้า SendGrid ของคุณ โปรดตรวจสอบช่องทำเครื่องหมาย **“Post the raw, full MIME message.”** Action Mailbox ต้องการข้อมูล MIME เต็มรูปแบบเพื่อทำงาน

## ตัวอย่าง

กำหนดค่าการเส้นทางพื้นฐาน:

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing(/^save@/i     => :forwards)
  routing(/@replies\./i => :replies)
end
```
จากนั้นติดตั้งกล่องจดหมาย:

```bash
# สร้างกล่องจดหมายใหม่
$ bin/rails generate mailbox forwards
```

```ruby
# app/mailboxes/forwards_mailbox.rb
class ForwardsMailbox < ApplicationMailbox
  # Callbacks ระบุเงื่อนไขการประมวลผล
  before_processing :require_projects

  def process
    # บันทึกการส่งต่อในโปรเจคเดียว หรือ...
    if forwarder.projects.one?
      record_forward
    else
      # ...ใช้ Action Mailer อีกตัวหนึ่งเพื่อถามว่าจะส่งต่อไปยังโปรเจคใด
      request_forwarding_project
    end
  end

  private
    def require_projects
      if forwarder.projects.none?
        # ใช้ Action Mailers เพื่อส่งอีเมล์กลับไปยังผู้ส่ง - สิ้นสุดการประมวลผล
        bounce_with Forwards::BounceMailer.no_projects(inbound_email, forwarder: forwarder)
      end
    end

    def record_forward
      forwarder.forwards.create subject: mail.subject, content: mail.content
    end

    def request_forwarding_project
      Forwards::RoutingMailer.choose_project(inbound_email, forwarder: forwarder).deliver_now
    end

    def forwarder
      @forwarder ||= User.find_by(email_address: mail.from)
    end
end
```

## การทำลาย InboundEmails

ตามค่าเริ่มต้น เมื่อ InboundEmail ถูกประมวลผลเรียบร้อยแล้ว จะถูกทำลายหลังจาก 30 วัน นี้จะทำให้คุณไม่ต้องเก็บข้อมูลของผู้ใช้โดยไม่จำเป็นหลังจากที่พวกเขายกเลิกบัญชีหรือลบเนื้อหาของพวกเขา ความตั้งใจคือหลังจากคุณประมวลผลอีเมล์แล้ว คุณควรได้รับข้อมูลทั้งหมดที่คุณต้องการและแปลงเป็นโมเดลของโดเมนและเนื้อหาในส่วนของแอปพลิเคชันของคุณ  InboundEmail จะยังคงอยู่ในระบบเพื่อให้คุณสามารถดูข้อมูลการแก้ปัญหาและการสืบสวนได้

การทำลายจริงจะถูกดำเนินการผ่าน `IncinerationJob` ที่ถูกกำหนดเวลาให้เรียกใช้หลังจาก [`config.action_mailbox.incinerate_after`][] เวลา ค่านี้ถูกตั้งค่าเริ่มต้นเป็น `30.days` แต่คุณสามารถเปลี่ยนแปลงได้ในการกำหนดค่า production.rb ของคุณ (โปรดทราบว่าการกำหนดเวลาการทำลายในอนาคตนี้ขึ้นอยู่กับคิวงานของคุณที่สามารถเก็บงานได้นานเท่านั้น)


## การทำงานกับ Action Mailbox ใน Development

การทดสอบอีเมล์เข้าระบบในระหว่างการพัฒนาโดยไม่ต้องส่งและรับอีเมล์จริงจะเป็นประโยชน์ สำหรับการทำงานนี้ มีตัวควบคุม conductor ที่ติดตั้งที่ `/rails/conductor/action_mailbox/inbound_emails` ซึ่งจะให้คุณดูรายการ InboundEmail ทั้งหมดในระบบ สถานะการประมวลผล และแบบฟอร์มสำหรับสร้าง InboundEmail ใหม่

## การทดสอบ Mailboxes

ตัวอย่าง:

```ruby
class ForwardsMailboxTest < ActionMailbox::TestCase
  test "directly recording a client forward for a forwarder and forwardee corresponding to one project" do
    assert_difference -> { people(:david).buckets.first.recordings.count } do
      receive_inbound_email_from_mail \
        to: 'save@example.com',
        from: people(:david).email_address,
        subject: "Fwd: Status update?",
        body: <<~BODY
          --- Begin forwarded message ---
          From: Frank Holland <frank@microsoft.com>

          What's the status?
        BODY
    end

    recording = people(:david).buckets.first.recordings.last
    assert_equal people(:david), recording.creator
    assert_equal "Status update?", recording.forward.subject
    assert_match "What's the status?", recording.forward.content.to_s
  end
end
```

โปรดอ้างอิง [ActionMailbox::TestHelper API](https://api.rubyonrails.org/classes/ActionMailbox/TestHelper.html) สำหรับเมธอดช่วยในการทดสอบเพิ่มเติม
[`config.action_mailbox.incinerate_after`]: configuring.html#config-action-mailbox-incinerate-after
