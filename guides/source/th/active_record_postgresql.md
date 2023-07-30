**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9a8daf85251d1a12237dd39a65eed51a
Active Record และ PostgreSQL
============================

เอกสารนี้เป็นเกี่ยวกับการใช้งาน Active Record สำหรับ PostgreSQL

หลังจากอ่านเอกสารนี้แล้วคุณจะรู้:

* วิธีใช้งานข้อมูลชนิดของ PostgreSQL
* วิธีใช้งาน primary key แบบ UUID
* วิธีรวมคอลัมน์ที่ไม่ใช่ key ในดัชนี
* วิธีใช้งาน foreign key แบบ deferrable
* วิธีใช้งาน unique constraint
* วิธีใช้งาน exclusion constraint
* วิธีใช้งานการค้นหาข้อความแบบเต็มของ PostgreSQL
* วิธีสร้าง Active Record models ที่ใช้งานกับ database views

--------------------------------------------------------------------------------

เพื่อใช้งาน PostgreSQL adapter คุณต้องติดตั้งเวอร์ชัน 9.3 ขึ้นไป รุ่นเก่าไม่ได้รับการสนับสนุน

เพื่อเริ่มต้นใช้งาน PostgreSQL โปรดดูที่
[เอกสารการกำหนดค่า Rails](configuring.html#configuring-a-postgresql-database) 
มันอธิบายวิธีการตั้งค่า Active Record สำหรับ PostgreSQL อย่างถูกต้อง

ข้อมูลชนิด
---------

PostgreSQL มีข้อมูลชนิดที่เฉพาะเจาะจงหลายประเภท ต่อไปนี้คือรายการของชนิดที่รองรับโดย PostgreSQL adapter

### Bytea

* [คำนิยามชนิด](https://www.postgresql.org/docs/current/static/datatype-binary.html)
* [ฟังก์ชันและตัวดำเนินการ](https://www.postgresql.org/docs/current/static/functions-binarystring.html)

```ruby
# db/migrate/20140207133952_create_documents.rb
create_table :documents do |t|
  t.binary 'payload'
end
```

```ruby
# app/models/document.rb
class Document < ApplicationRecord
end
```

```ruby
# การใช้งาน
data = File.read(Rails.root + "tmp/output.pdf")
Document.create payload: data
```

### Array

* [คำนิยามชนิด](https://www.postgresql.org/docs/current/static/arrays.html)
* [ฟังก์ชันและตัวดำเนินการ](https://www.postgresql.org/docs/current/static/functions-array.html)

```ruby
# db/migrate/20140207133952_create_books.rb
create_table :books do |t|
  t.string 'title'
  t.string 'tags', array: true
  t.integer 'ratings', array: true
end
add_index :books, :tags, using: 'gin'
add_index :books, :ratings, using: 'gin'
```

```ruby
# app/models/book.rb
class Book < ApplicationRecord
end
```

```ruby
# การใช้งาน
Book.create title: "Brave New World",
            tags: ["fantasy", "fiction"],
            ratings: [4, 5]

## หนังสือสำหรับแท็กเดียว
Book.where("'fantasy' = ANY (tags)")

## หนังสือสำหรับแท็กหลายตัว
Book.where("tags @> ARRAY[?]::varchar[]", ["fantasy", "fiction"])

## หนังสือที่มีการจัดอันดับ 3 หรือมากกว่า
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [คำนิยามชนิด](https://www.postgresql.org/docs/current/static/hstore.html)
* [ฟังก์ชันและตัวดำเนินการ](https://www.postgresql.org/docs/current/static/hstore.html#id-1.11.7.26.5)

หมายเหตุ: คุณต้องเปิดใช้งานส่วนขยาย `hstore` เพื่อใช้งาน hstore

```ruby
# db/migrate/20131009135255_create_profiles.rb
class CreateProfiles < ActiveRecord::Migration[7.0]
  enable_extension 'hstore' unless extension_enabled?('hstore')
  create_table :profiles do |t|
    t.hstore 'settings'
  end
end
```

```ruby
# app/models/profile.rb
class Profile < ApplicationRecord
end
```

```irb
irb> Profile.create(settings: { "color" => "blue", "resolution" => "800x600" })

irb> profile = Profile.first
irb> profile.settings
=> {"color"=>"blue", "resolution"=>"800x600"}

irb> profile.settings = {"color" => "yellow", "resolution" => "1280x1024"}
irb> profile.save!

irb> Profile.where("settings->'color' = ?", "yellow")
=> #<ActiveRecord::Relation [#<Profile id: 1, settings: {"color"=>"yellow", "resolution"=>"1280x1024"}>]>
```

### JSON และ JSONB

* [คำนิยามชนิด](https://www.postgresql.org/docs/current/static/datatype-json.html)
* [ฟังก์ชันและตัวดำเนินการ](https://www.postgresql.org/docs/current/static/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
# ... สำหรับชนิดข้อมูล json:
create_table :events do |t|
  t.json 'payload'
end
# ... หรือสำหรับชนิดข้อมูล jsonb:
create_table :events do |t|
  t.jsonb 'payload'
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(payload: { kind: "user_renamed", change: ["jack", "john"]})

irb> event = Event.first
irb> event.payload
=> {"kind"=>"user_renamed", "change"=>["jack", "john"]}

## ค้นหาข้อมูลโดยใช้เอกสาร JSON
# ตัวดำเนินการ -> จะคืนค่าชนิด JSON ต้นฉบับ (ซึ่งอาจเป็นวัตถุ), ในขณะที่ ->> จะคืนค่าเป็นข้อความ
irb> Event.where("payload->>'kind' = ?", "user_renamed")
```

### ชนิดช่วง

* [คำนิยามชนิด](https://www.postgresql.org/docs/current/static/rangetypes.html)
* [ฟังก์ชันและตัวดำเนินการ](https://www.postgresql.org/docs/current/static/functions-range.html)

ชนิดนี้ถูกแมปกับวัตถุ Ruby [`Range`](https://ruby-doc.org/core-2.7.0/Range.html)

```ruby
# db/migrate/20130923065404_create_events.rb
create_table :events do |t|
  t.daterange 'duration'
end
```
```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(duration: Date.new(2014, 2, 11)..Date.new(2014, 2, 12))

irb> event = Event.first
irb> event.duration
=> วันอังคารที่ 11 กุมภาพันธ์ 2014...วันพฤหัสบดีที่ 13 กุมภาพันธ์ 2014

## กิจกรรมทั้งหมดในวันที่กำหนด
irb> Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## การทำงานกับขอบเขตของช่วง
irb> event = Event.select("lower(duration) AS starts_at").select("upper(duration) AS ends_at").first

irb> event.starts_at
=> วันอังคารที่ 11 กุมภาพันธ์ 2014
irb> event.ends_at
=> วันพฤหัสบดีที่ 13 กุมภาพันธ์ 2014
```

### ประเภทที่รวมกัน

* [คำนิยามประเภท](https://www.postgresql.org/docs/current/static/rowtypes.html)

ในปัจจุบันยังไม่มีการสนับสนุนพิเศษสำหรับประเภทที่รวมกัน แต่พวกเขาถูกแมปเป็นคอลัมน์ข้อความปกติ:

```sql
CREATE TYPE full_address AS
(
  city VARCHAR(90),
  street VARCHAR(90)
);
```

```ruby
# db/migrate/20140207133952_create_contacts.rb
execute <<-SQL
  CREATE TYPE full_address AS
  (
    city VARCHAR(90),
    street VARCHAR(90)
  );
SQL
create_table :contacts do |t|
  t.column :address, :full_address
end
```

```ruby
# app/models/contact.rb
class Contact < ApplicationRecord
end
```

```irb
irb> Contact.create address: "(Paris,Champs-Élysées)"
irb> contact = Contact.first
irb> contact.address
=> "(Paris,Champs-Élysées)"
irb> contact.address = "(Paris,Rue Basse)"
irb> contact.save!
```

### ประเภทที่ระบุ

* [คำนิยามประเภท](https://www.postgresql.org/docs/current/static/datatype-enum.html)

ประเภทสามารถแมปเป็นคอลัมน์ข้อความปกติ หรือเป็น [`ActiveRecord::Enum`](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

```ruby
# db/migrate/20131220144913_create_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  create_table :articles do |t|
    t.enum :status, enum_type: :article_status, default: "draft", null: false
  end
end
```

คุณยังสามารถสร้างประเภท enum และเพิ่มคอลัมน์ enum ในตารางที่มีอยู่:

```ruby
# db/migrate/20230113024409_add_status_to_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  add_column :articles, :status, :enum, enum_type: :article_status, default: "draft", null: false
end
```

การเปลี่ยนแปลงข้างต้นสามารถย้อนกลับได้ แต่คุณสามารถกำหนดเมธอด `#up` และ `#down` แยกกันได้หากจำเป็น ตรวจสอบให้แน่ใจว่าคุณลบคอลัมน์หรือตารางที่ขึ้นอยู่กับประเภท enum ก่อนที่จะลบ:

```ruby
def down
  drop_table :articles

  # หรือ: remove_column :articles, :status
  drop_enum :article_status
end
```

การประกาศแอตทริบิวต์ enum ในโมเดลจะเพิ่มเมธอดช่วยและป้องกันค่าที่ไม่ถูกต้องจากการกำหนดให้กับอินสแตนซ์ของคลาส:

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  enum status: {
    draft: "draft", published: "published", archived: "archived"
  }, _prefix: true
end
```

```irb
irb> article = Article.create
irb> article.status
=> "draft" # สถานะเริ่มต้นจาก PostgreSQL ตามที่กำหนดในการเปลี่ยนแปลงด้านบน

irb> article.status_published!
irb> article.status
=> "published"

irb> article.status_archived?
=> false

irb> article.status = "deleted"
ArgumentError: 'deleted' ไม่ใช่สถานะที่ถูกต้อง
```

หากต้องการเปลี่ยนชื่อ enum คุณสามารถใช้ `rename_enum` พร้อมกับการอัปเดตการใช้โมเดล:

```ruby
# db/migrate/20150718144917_rename_article_status.rb
def change
  rename_enum :article_status, to: :article_state
end
```

หากต้องการเพิ่มค่าใหม่คุณสามารถใช้ `add_enum_value`:

```ruby
# db/migrate/20150720144913_add_new_state_to_articles.rb
def up
  add_enum_value :article_state, "archived", # จะอยู่ที่ท้ายหลัง published
  add_enum_value :article_state, "in review", before: "published"
  add_enum_value :article_state, "approved", after: "in review"
end
```

หมายเหตุ: ค่า enum ไม่สามารถลบได้ ซึ่งหมายความว่า add_enum_value ไม่สามารถย้อนกลับได้ คุณสามารถอ่านเหตุผลได้ที่นี่ [ที่นี่](https://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com).

หากต้องการเปลี่ยนชื่อค่าคุณสามารถใช้ `rename_enum_value`:

```ruby
# db/migrate/20150722144915_rename_article_state.rb
def change
  rename_enum_value :article_state, from: "archived", to: "deleted"
end
```

คำแนะนำ: หากต้องการแสดงค่าทั้งหมดของ enum ทั้งหมดที่คุณมี คุณสามารถเรียกใช้คำสั่งนี้ใน `bin/rails db` หรือคอนโซล `psql`:
```
```sql
SELECT n.nspname AS enum_schema,
       t.typname AS enum_name,
       e.enumlabel AS enum_value
  FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
```

### UUID

* [type definition](https://www.postgresql.org/docs/current/static/datatype-uuid.html)
* [pgcrypto generator function](https://www.postgresql.org/docs/current/static/pgcrypto.html)
* [uuid-ossp generator functions](https://www.postgresql.org/docs/current/static/uuid-ossp.html)

NOTE: หากคุณใช้ PostgreSQL เวอร์ชันที่เก่ากว่า 13.0 คุณอาจต้องเปิดใช้งานส่วนขยายพิเศษเพื่อใช้งาน UUIDs ใช้คำสั่งเปิดใช้งานส่วนขยาย `pgcrypto` (PostgreSQL >= 9.4) หรือ `uuid-ossp` (สำหรับเวอร์ชันที่เก่ากว่านั้น)

```ruby
# db/migrate/20131220144913_create_revisions.rb
create_table :revisions do |t|
  t.uuid :identifier
end
```

```ruby
# app/models/revision.rb
class Revision < ApplicationRecord
end
```

```irb
irb> Revision.create identifier: "A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11"

irb> revision = Revision.first
irb> revision.identifier
=> "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
```

คุณสามารถใช้ประเภท `uuid` เพื่อกำหนดการอ้างอิงในการเปลี่ยนแปลง:

```ruby
# db/migrate/20150418012400_create_blog.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :posts, id: :uuid

create_table :comments, id: :uuid do |t|
  # t.belongs_to :post, type: :uuid
  t.references :post, type: :uuid
end
```

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments
end
```

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
end
```

ดู [ส่วนนี้](#uuid-primary-keys) เพื่อดูรายละเอียดเพิ่มเติมเกี่ยวกับการใช้ UUIDs เป็น primary key

### Bit String Types

* [type definition](https://www.postgresql.org/docs/current/static/datatype-bit.html)
* [functions and operators](https://www.postgresql.org/docs/current/static/functions-bitstring.html)

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users, force: true do |t|
  t.column :settings, "bit(8)"
end
```

```ruby
# app/models/user.rb
class User < ApplicationRecord
end
```

```irb
irb> User.create settings: "01010011"
irb> user = User.first
irb> user.settings
=> "01010011"
irb> user.settings = "0xAF"
irb> user.settings
=> "10101111"
irb> user.save!
```

### Network Address Types

* [type definition](https://www.postgresql.org/docs/current/static/datatype-net-types.html)

ประเภท `inet` และ `cidr` ถูกแมปเป็นอ็อบเจ็กต์ Ruby [`IPAddr`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ipaddr/rdoc/IPAddr.html) อ็อบเจ็กต์. ประเภท `macaddr` ถูกแมปเป็นข้อความปกติ

```ruby
# db/migrate/20140508144913_create_devices.rb
create_table(:devices, force: true) do |t|
  t.inet 'ip'
  t.cidr 'network'
  t.macaddr 'address'
end
```

```ruby
# app/models/device.rb
class Device < ApplicationRecord
end
```

```irb
irb> macbook = Device.create(ip: "192.168.1.12", network: "192.168.2.0/24", address: "32:01:16:6d:05:ef")

irb> macbook.ip
=> #<IPAddr: IPv4:192.168.1.12/255.255.255.255>

irb> macbook.network
=> #<IPAddr: IPv4:192.168.2.0/255.255.255.0>

irb> macbook.address
=> "32:01:16:6d:05:ef"
```

### Geometric Types

* [type definition](https://www.postgresql.org/docs/current/static/datatype-geometric.html)

ทุกประเภททางเรขาคณิต, ยกเว้น `points` ถูกแมปเป็นข้อความปกติ. จุดถูกแปลงเป็นอาร์เรย์ที่มีพิกัด `x` และ `y`

### Interval

* [type definition](https://www.postgresql.org/docs/current/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
* [functions and operators](https://www.postgresql.org/docs/current/static/functions-datetime.html)

ประเภทนี้ถูกแมปเป็น [`ActiveSupport::Duration`](https://api.rubyonrails.org/classes/ActiveSupport/Duration.html) อ็อบเจ็กต์

```ruby
# db/migrate/20200120000000_create_events.rb
create_table :events do |t|
  t.interval 'duration'
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(duration: 2.days)

irb> event = Event.first
irb> event.duration
=> 2 days
```

UUID Primary Keys
-----------------

NOTE: คุณต้องเปิดใช้งานส่วนขยาย `pgcrypto` (เฉพาะ PostgreSQL >= 9.4) หรือ `uuid-ossp` เพื่อสร้าง UUIDs แบบสุ่ม

```ruby
# db/migrate/20131220144913_create_devices.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :devices, id: :uuid do |t|
  t.string :kind
end
```

```ruby
# app/models/device.rb
class Device < ApplicationRecord
end
```

```irb
irb> device = Device.create
irb> device.id
=> "814865cd-5a1d-4771-9306-4268f188fe9e"
```

NOTE: `gen_random_uuid()` (จาก `pgcrypto`) ถูกถือเป็นค่าเริ่มต้นหากไม่มีตัวเลือก `:default` ถูกส่งให้กับ `create_table`

เมื่อสร้างโมเดลด้วย primary key เป็น UUID ให้ใช้ตัวสร้างโมเดล Rails สำหรับตารางนั้น ๆ โดยส่ง `--primary-key-type=uuid` ไปยังตัวสร้างโมเดล

ตัวอย่างเช่น:

```bash
$ rails generate model Device --primary-key-type=uuid kind:string
```

เมื่อสร้างโมเดลที่มีคีย์ต่างประเภท UUID ให้ใช้ประเภทฟิลด์เป็นฟิลด์เดียวกับฐานข้อมูล, ตัวอย่างเช่น:
```bash
$ rails generate model Case device_id:uuid
```

การสร้างดัชนี
--------

* [การสร้างดัชนี](https://www.postgresql.org/docs/current/sql-createindex.html)

PostgreSQL มีตัวเลือกดัชนีหลายรูปแบบ ตัวเลือกต่อไปนี้รองรับโดย PostgreSQL adapter เพิ่มเติมจาก
[ตัวเลือกดัชนีทั่วไป](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index)

### Include

เมื่อสร้างดัชนีใหม่ สามารถรวมคอลัมน์ที่ไม่ใช่คีย์ได้ด้วยตัวเลือก `:include` 
คีย์เหล่านี้ไม่ถูกใช้ในการสแกนดัชนีเพื่อค้นหา แต่สามารถอ่านได้ในขณะที่สแกนดัชนีเท่านั้นโดยไม่ต้องเข้าถึงตารางที่เกี่ยวข้อง

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id.rb

add_index :users, :email, include: :id
```

รองรับหลายคอลัมน์:

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id_and_created_at.rb

add_index :users, :email, include: [:id, :created_at]
```

คอลัมน์ที่สร้างขึ้น
-----------------

หมายเหตุ: รองรับคอลัมน์ที่สร้างขึ้นตั้งแต่เวอร์ชัน 12.0 ของ PostgreSQL

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users do |t|
  t.string :name
  t.virtual :name_upcased, type: :string, as: 'upper(name)', stored: true
end

# app/models/user.rb
class User < ApplicationRecord
end

# การใช้งาน
user = User.create(name: 'John')
User.last.name_upcased # => "JOHN"
```

Foreign Keys ที่สามารถเลื่อนการตรวจสอบได้
-----------------------

* [การกำหนดเงื่อนไขตาราง foreign key](https://www.postgresql.org/docs/current/sql-set-constraints.html)

โดยค่าเริ่มต้น เงื่อนไขตารางใน PostgreSQL จะถูกตรวจสอบทันทีหลังจากแต่ละคำสั่ง มันไม่อนุญาตให้สร้างระเบียนที่อ้างอิงยังไม่อยู่ในตารางที่อ้างอิง อย่างไรก็ตาม สามารถเรียกการตรวจสอบความสมบูรณ์นี้ในภายหลังเมื่อธุรกรรมถูกยืนยันได้โดยการเพิ่ม `DEFERRABLE` ในการกำหนดค่า foreign key แบบนี้ ใน Rails สามารถเข้าถึงคุณลักษณะ PostgreSQL นี้ได้โดยการเพิ่มคีย์ `:deferrable` ในตัวเลือก `foreign_key` ในเมธอด `add_reference` และ `add_foreign_key`

ตัวอย่างหนึ่งของการสร้างความสัมพันธ์วงกลมในธุรกรรม แม้ว่าคุณจะสร้าง foreign key:

```ruby
add_reference :person, :alias, foreign_key: { deferrable: :deferred }
add_reference :alias, :person, foreign_key: { deferrable: :deferred }
```

หากอ้างอิงถูกสร้างขึ้นด้วยตัวเลือก `foreign_key: true` ธุรกรรมต่อไปนี้จะล้มเหลวเมื่อดำเนินการ `INSERT` คำสั่งแรก แต่ไม่ล้มเหลวเมื่อตั้งค่าตัวเลือก `deferrable: :deferred`

```ruby
ActiveRecord::Base.connection.transaction do
  person = Person.create(id: SecureRandom.uuid, alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

เมื่อตัวเลือก `:deferrable` ถูกตั้งค่าเป็น `:immediate` ให้ foreign key ใช้ค่าเริ่มต้นของการตรวจสอบเงื่อนไขทันที แต่อนุญาตให้เลื่อนการตรวจสอบด้วย `SET CONSTRAINTS ALL DEFERRED` ภายในธุรกรรม นี่จะทำให้ foreign key ถูกตรวจสอบเมื่อธุรกรรมถูกยืนยัน:

```ruby
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL DEFERRED")
  person = Person.create(alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

โดยค่าเริ่มต้น `:deferrable` เป็น `false` และเงื่อนไขจะถูกตรวจสอบทันทีเสมอ

การกำหนดเงื่อนไข Unique
-----------------

* [เงื่อนไข unique](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS)

```ruby
# db/migrate/20230422225213_create_items.rb
create_table :items do |t|
  t.integer :position, null: false
  t.unique_key [:position], deferrable: :immediate
end
```

หากต้องการเปลี่ยนดัชนี unique ที่มีอยู่ให้เป็น deferrable สามารถใช้ `:using_index` เพื่อสร้างเงื่อนไข unique ที่เลื่อนการตรวจสอบได้

```ruby
add_unique_key :items, deferrable: :deferred, using_index: "index_items_on_position"
```

เช่นเดียวกับ foreign key เงื่อนไข unique สามารถเลื่อนการตรวจสอบได้โดยการตั้งค่า `:deferrable` เป็น `:immediate` หรือ `:deferred` โดยค่าเริ่มต้น `:deferrable` เป็น `false` และเงื่อนไขจะถูกตรวจสอบทันทีเสมอ

เงื่อนไขการตัดสินใจ
---------------------
* [ข้อจำกัดการยกเว้น](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION)

```ruby
# db/migrate/20131220144913_create_products.rb
create_table :products do |t|
  t.integer :price, null: false
  t.daterange :availability_range, null: false

  t.exclusion_constraint "price WITH =, availability_range WITH &&", using: :gist, name: "price_check"
end
```

เช่นเดียวกับ foreign keys, ข้อจำกัดการยกเว้นสามารถถูกเลื่อนออกไปได้โดยการตั้งค่า `:deferrable` เป็น `:immediate` หรือ `:deferred` โดยค่าเริ่มต้น `:deferrable` คือ `false` และข้อจำกัดจะถูกตรวจสอบทันทีเสมอ

การค้นหาข้อความเต็ม
----------------

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body
end

add_index :documents, "to_tsvector('english', title || ' ' || body)", using: :gin, name: 'documents_idx'
```

```ruby
# app/models/document.rb
class Document < ApplicationRecord
end
```

```ruby
# การใช้งาน
Document.create(title: "Cats and Dogs", body: "are nice!")

## เอกสารทั้งหมดที่ตรงกับ 'cat & dog'
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "cat & dog")
```

ตามต้องการคุณสามารถเก็บเวกเตอร์เป็นคอลัมน์ที่สร้างขึ้นโดยอัตโนมัติ (ตั้งแต่ PostgreSQL 12.0):

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body

  t.virtual :textsearchable_index_col,
            type: :tsvector, as: "to_tsvector('english', title || ' ' || body)", stored: true
end

add_index :documents, :textsearchable_index_col, using: :gin, name: 'documents_idx'

# การใช้งาน
Document.create(title: "Cats and Dogs", body: "are nice!")

## เอกสารทั้งหมดที่ตรงกับ 'cat & dog'
Document.where("textsearchable_index_col @@ to_tsquery(?)", "cat & dog")
```

มุมมองฐานข้อมูล
--------------

* [การสร้างมุมมอง](https://www.postgresql.org/docs/current/static/sql-createview.html)

สมมติว่าคุณต้องการทำงานกับฐานข้อมูลเก่าที่มีตารางต่อไปนี้:

```
rails_pg_guide=# \d "TBL_ART"
                                        Table "public.TBL_ART"
   Column   |            Type             |                         Modifiers
------------+-----------------------------+------------------------------------------------------------
 INT_ID     | integer                     | not null default nextval('"TBL_ART_INT_ID_seq"'::regclass)
 STR_TITLE  | character varying           |
 STR_STAT   | character varying           | default 'draft'::character varying
 DT_PUBL_AT | timestamp without time zone |
 BL_ARCH    | boolean                     | default false
Indexes:
    "TBL_ART_pkey" PRIMARY KEY, btree ("INT_ID")
```

ตารางนี้ไม่ตามหลักการของ Rails เลย
เนื่องจากมุมมอง PostgreSQL ที่เรียบง่ายสามารถอัปเดตได้โดยค่าเริ่มต้น
เราสามารถห่อหุ้มได้ดังนี้:

```ruby
# db/migrate/20131220144913_create_articles_view.rb
execute <<-SQL
CREATE VIEW articles AS
  SELECT "INT_ID" AS id,
         "STR_TITLE" AS title,
         "STR_STAT" AS status,
         "DT_PUBL_AT" AS published_at,
         "BL_ARCH" AS archived
  FROM "TBL_ART"
  WHERE "BL_ARCH" = 'f'
SQL
```

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  self.primary_key = "id"
  def archive!
    update_attribute :archived, true
  end
end
```

```irb
irb> first = Article.create! title: "Winter is coming", status: "published", published_at: 1.year.ago
irb> second = Article.create! title: "Brace yourself", status: "draft", published_at: 1.month.ago

irb> Article.count
=> 2
irb> first.archive!
irb> Article.count
=> 1
```

หมายเหตุ: แอปพลิเคชันนี้สนใจเฉพาะ `Articles` ที่ไม่ได้ถูกเก็บเอาไว้ มุมมองยัง
อนุญาตให้กำหนดเงื่อนไขเพื่อไม่รวม `Articles` ที่ถูกเก็บเอาไว้โดยตรง

การสร้างโครงสร้าง
--------------

หาก `config.active_record.schema_format` ของคุณเป็น `:sql`, Rails จะเรียกใช้ `pg_dump` เพื่อสร้าง
การสร้างโครงสร้าง

คุณสามารถใช้ `ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags` เพื่อกำหนดค่า `pg_dump` ได้
ตัวอย่างเช่น เพื่อไม่รวมความคิดเห็นในการสร้างโครงสร้าง เพิ่มสิ่งนี้ในไฟล์เริ่มต้น:

```ruby
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
```
