**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b8e9de3d2aa934a8a6fc3e1dccb4824c
ภาพรวมของ Active Storage
=======================

เอกสารนี้เป็นคู่มือเกี่ยวกับวิธีการแนบไฟล์กับโมเดล Active Record ของคุณ

หลังจากอ่านคู่มือนี้คุณจะรู้:

* วิธีการแนบไฟล์หนึ่งหรือหลายไฟล์กับเรคคอร์ด
* วิธีการลบไฟล์ที่แนบมา
* วิธีการเชื่อมโยงไปยังไฟล์ที่แนบมา
* วิธีการใช้ตัวแปรเพื่อแปลงรูปภาพ
* วิธีการสร้างรูปภาพแทนของไฟล์ที่ไม่ใช่รูปภาพ เช่น PDF หรือวิดีโอ
* วิธีการส่งการอัปโหลดไฟล์โดยตรงจากเบราว์เซอร์ไปยังบริการจัดเก็บ โดยไม่ผ่านเซิร์ฟเวอร์แอปพลิเคชันของคุณ
* วิธีการทำความสะอาดไฟล์ที่เก็บระหว่างการทดสอบ
* วิธีการสนับสนุนบริการจัดเก็บเพิ่มเติม

--------------------------------------------------------------------------------

Active Storage คืออะไร?
-----------------------

Active Storage ช่วยให้คุณสามารถอัปโหลดไฟล์ไปยังบริการจัดเก็บในคลาวด์ เช่น Amazon S3, Google Cloud Storage หรือ Microsoft Azure Storage และแนบไฟล์เหล่านั้นกับอ็อบเจ็กต์ Active Record มันมาพร้อมกับบริการดิสก์ในเครื่องสำหรับการพัฒนาและทดสอบและสนับสนุนการสำรองข้อมูลและการย้ายไฟล์ไปยังบริการย่อย

โดยใช้ Active Storage แอปพลิเคชันสามารถแปลงการอัปโหลดรูปภาพหรือสร้างรูปภาพแทนของการอัปโหลดที่ไม่ใช่รูปภาพ เช่น PDF และวิดีโอ และสามารถแยกข้อมูลเมตาดาต้าจากไฟล์ที่ไม่เป็นรูปภาพได้

### ความต้องการ

คุณลักษณะต่าง ๆ ของ Active Storage ขึ้นอยู่กับซอฟต์แวร์จากบุคคลที่สามที่ Rails จะไม่ติดตั้งและต้องติดตั้งแยกกัน:

* [libvips](https://github.com/libvips/libvips) เวอร์ชัน 8.6+ หรือ [ImageMagick](https://imagemagick.org/index.php) สำหรับการวิเคราะห์และการแปลงรูปภาพ
* [ffmpeg](http://ffmpeg.org/) เวอร์ชัน 3.4+ สำหรับการแสดงตัวอย่างวิดีโอและ ffprobe สำหรับการวิเคราะห์วิดีโอ/เสียง
* [poppler](https://poppler.freedesktop.org/) หรือ [muPDF](https://mupdf.com/) สำหรับการแสดงตัวอย่าง PDF

การวิเคราะห์และการแปลงรูปภาพยังต้องการแพคเกจ `image_processing` ถ้ายังไม่ได้เปิดคอมเมนต์ใน `Gemfile` ให้เปิดคอมเมนต์หรือเพิ่มแพคเกจดังกล่าว:

```ruby
gem "image_processing", ">= 1.2"
```

เคล็ดลับ: เมื่อเปรียบเทียบกับ libvips, ImageMagick มีชื่อที่ดีกว่าและมีความพร้อมใช้งานมากกว่า อย่างไรก็ตาม libvips สามารถทำงานได้เร็วขึ้นถึง 10 เท่าและใช้หน่วยความจำน้อยลง สำหรับไฟล์ JPEG สามารถปรับปรุงได้อีกโดยการแทนที่ `libjpeg-dev` ด้วย `libjpeg-turbo-dev` ซึ่งเร็วขึ้น 2-7 เท่า

คำเตือน: ก่อนที่คุณจะติดตั้งและใช้ซอฟต์แวร์จากบุคคลที่สาม ตรวจสอบให้แน่ใจว่าคุณเข้าใจผลที่เกิดจากการใช้งานที่เกี่ยวข้องกับการอนุญาตในการใช้งาน โดยเฉพาะอย่างยิ่ง MuPDF ที่มีการอนุญาตภายใต้ AGPL และต้องใช้ใบอนุญาตพาณิชย์สำหรับบางการใช้งาน

## การติดตั้ง

```bash
$ bin/rails active_storage:install
$ bin/rails db:migrate
```

การตั้งค่าและสร้างตารางสามตารางที่ Active Storage ใช้งาน:
`active_storage_blobs`, `active_storage_attachments`, และ `active_storage_variant_records`.

| ตาราง      | วัตถุประสงค์ |
| ------------------- | ----- |
| `active_storage_blobs` | เก็บข้อมูลเกี่ยวกับไฟล์ที่อัปโหลด เช่นชื่อไฟล์และประเภทเนื้อหา |
| `active_storage_attachments` | เป็นตารางเชื่อมโยงโพลิมอร์ฟิกที่ [เชื่อมโยงโมเดลของคุณกับ blobs](#attaching-files-to-records) หากชื่อคลาสของโมเดลเปลี่ยน คุณจะต้องเรียกใช้การเคลื่อนย้ายบนตารางนี้เพื่ออัปเดต `record_type` ให้เป็นชื่อคลาสใหม่ของโมเดล |
| `active_storage_variant_records` | หากเปิดใช้งาน [การติดตามตัวแปรแบบ](#attaching-files-to-records) จะเก็บบันทึกสำหรับแต่ละตัวแปรที่ถูกสร้าง |

คำเตือน: หากคุณใช้ UUID แทนตัวระบุหลักเป็นจำนวนเต็มบนโมเดลของคุณ คุณควรตั้งค่า `Rails.application.config.generators { |g| g.orm :active_record, primary_key_type: :uuid }` ในไฟล์คอนฟิก

ประกาศบริการ Active Storage ใน `config/storage.yml` สำหรับแต่ละบริการที่แอปพลิเคชันของคุณใช้ ให้ระบุชื่อและการกำหนดค่าที่จำเป็น ตัวอย่างด้านล่างประกาศบริการสามบริการชื่อ `local`, `test`, และ `amazon`:
```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  bucket: ""
  region: "" # เช่น 'us-east-1'
```

ตั้งค่าให้ Active Storage ใช้บริการใดโดยการตั้งค่า `Rails.application.config.active_storage.service` โดยแนะนำให้ทำการตั้งค่านี้ในแต่ละ environment โดยเฉพาะ ตัวอย่างเช่น เพื่อใช้บริการ disk จากตัวอย่างก่อนหน้านี้ใน environment การพัฒนา คุณควรเพิ่มต่อไปนี้ใน `config/environments/development.rb`:

```ruby
# เก็บไฟล์ในเครื่อง
config.active_storage.service = :local
```

เพื่อใช้บริการ S3 ใน production คุณควรเพิ่มต่อไปนี้ใน `config/environments/production.rb`:

```ruby
# เก็บไฟล์ใน Amazon S3
config.active_storage.service = :amazon
```

เพื่อใช้บริการ test เมื่อทดสอบ คุณควรเพิ่มต่อไปนี้ใน `config/environments/test.rb`:

```ruby
# เก็บไฟล์ที่อัปโหลดในระบบไฟล์ใน temporary directory
config.active_storage.service = :test
```

หมายเหตุ: ไฟล์การตั้งค่าที่เฉพาะกับแต่ละ environment จะมีความสำคัญกว่า: ตัวอย่างเช่นใน production ไฟล์ `config/storage/production.yml` (หากมี) จะมีความสำคัญกว่าไฟล์ `config/storage.yml`

แนะนำให้ใช้ `Rails.env` ในชื่อ bucket เพิ่มเติมเพื่อลดความเสี่ยงในการทำลายข้อมูลใน production

```yaml
amazon:
  service: S3
  # ...
  bucket: your_own_bucket-<%= Rails.env %>

google:
  service: GCS
  # ...
  bucket: your_own_bucket-<%= Rails.env %>

azure:
  service: AzureStorage
  # ...
  container: your_container_name-<%= Rails.env %>
```

อ่านต่อเพื่อดูข้อมูลเพิ่มเติมเกี่ยวกับตัวอย่างการใช้งานแอดาปเตอร์บริการที่มีอยู่ (เช่น `Disk` และ `S3`) และการตั้งค่าที่ต้องการ

### บริการ Disk

ประกาศบริการ Disk ใน `config/storage.yml`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### บริการ S3 (Amazon S3 และ S3-compatible APIs)

เพื่อเชื่อมต่อกับ Amazon S3 ให้ประกาศบริการ S3 ใน `config/storage.yml`:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

ให้ระบุตัวเลือก client และ upload ได้ตามต้องการ:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
  http_open_timeout: 0
  http_read_timeout: 0
  retry_limit: 0
  upload:
    server_side_encryption: "" # 'aws:kms' หรือ 'AES256'
    cache_control: "private, max-age=<%= 1.day.to_i %>"
```

เคล็ดลับ: ตั้งค่า client HTTP timeouts และ retry limits ที่เหมาะสมสำหรับแอปพลิเคชันของคุณ ในสถานการณ์ที่เกิดข้อผิดพลาดบางกรณี การตั้งค่าเริ่มต้นของ AWS client อาจทำให้เกิดการเก็บเชื่อมต่อไว้เป็นเวลานานถึงหลายนาทีและทำให้เกิดการจัดคิวของคำขอ

เพิ่ม [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) gem เข้าไปใน `Gemfile`:

```ruby
gem "aws-sdk-s3", require: false
```

หมายเหตุ: คุณจำเป็นต้องมีสิทธิ์ต่อตัวอย่างหลักของ Active Storage ดังต่อไปนี้: `s3:ListBucket`, `s3:PutObject`, `s3:GetObject`, และ `s3:DeleteObject` [การเข้าถึงสาธารณะ](#public-access) ต้องการ `s3:PutObjectAcl` อีกด้วย หากคุณมีการตั้งค่าตัวเลือกการอัปโหลดเพิ่มเติม เช่น การตั้งค่า ACLs อาจต้องการสิทธิ์เพิ่มเติม

หากคุณต้องการใช้ตัวแปรสภาพแวดล้อม ไฟล์การตั้งค่ามาตรฐานของ SDK โปรไฟล์ โปรไฟล์ของตัวอย่าง IAM หรือ task roles คุณสามารถละเว้นคีย์ `access_key_id`, `secret_access_key`, และ `region` ในตัวอย่างข้างต้นได้ บริการ S3 รองรับทุกตัวเลือกการรับรองตัวตนที่อธิบายใน [เอกสาร AWS SDK](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html)

เพื่อเชื่อมต่อกับ S3-compatible object storage API เช่น DigitalOcean Spaces ให้ระบุ `endpoint`:

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: ...
  secret_access_key: ...
  # ...และตัวเลือกอื่นๆ
```

มีตัวเลือกอื่นๆอีกมากมาย คุณสามารถตรวจสอบได้ที่ [AWS S3 Client](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method) เอกสาร
### บริการเก็บข้อมูล Microsoft Azure Storage

ประกาศบริการเก็บข้อมูล Azure Storage ใน `config/storage.yml`:

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

เพิ่ม gem [`azure-storage-blob`](https://github.com/Azure/azure-storage-ruby) เข้าไปใน `Gemfile`:

```ruby
gem "azure-storage-blob", "~> 2.0", require: false
```

### บริการเก็บข้อมูล Google Cloud Storage

ประกาศบริการเก็บข้อมูล Google Cloud Storage ใน `config/storage.yml`:

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: ""
```

สามารถให้ Hash ของข้อมูลรับรองแทนที่เส้นทางไฟล์คีย์ได้ตามต้องการ:

```yaml
google:
  service: GCS
  credentials:
    type: "service_account"
    project_id: ""
    private_key_id: <%= Rails.application.credentials.dig(:gcs, :private_key_id) %>
    private_key: <%= Rails.application.credentials.dig(:gcs, :private_key).dump %>
    client_email: ""
    client_id: ""
    auth_uri: "https://accounts.google.com/o/oauth2/auth"
    token_uri: "https://accounts.google.com/o/oauth2/token"
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs"
    client_x509_cert_url: ""
  project: ""
  bucket: ""
```

สามารถให้ Cache-Control metadata เพื่อตั้งค่าบนสิ่งที่อัปโหลดได้ตามต้องการ:

```yaml
google:
  service: GCS
  ...
  cache_control: "public, max-age=3600"
```

สามารถใช้ [IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam) แทนที่ `credentials` เมื่อเซ็นต์ URL ได้ตามต้องการ ซึ่งมีประโยชน์หากคุณกำลังรับรองความถูกต้องของแอปพลิเคชัน GKE ของคุณด้วย Workload Identity ดูรายละเอียดเพิ่มเติมใน [บล็อกโพสต์ Google Cloud นี้](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications)

```yaml
google:
  service: GCS
  ...
  iam: true
```

สามารถใช้ GSA ที่เฉพาะเจาะจงเมื่อเซ็นต์ URL ได้ตามต้องการ ในกรณีที่ใช้ IAM จะมีการติดต่อกับ [metadata server](https://cloud.google.com/compute/docs/storing-retrieving-metadata) เพื่อรับอีเมล GSA แต่เซิร์ฟเวอร์ metadata นี้ไม่มีอยู่เสมอ (เช่นการทดสอบในเครื่อง) และคุณอาจต้องการใช้ GSA ที่ไม่ใช่ค่าเริ่มต้น

```yaml
google:
  service: GCS
  ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

เพิ่ม gem [`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) เข้าไปใน `Gemfile`:

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

### บริการ Mirror

คุณสามารถทำให้บริการหลาย ๆ รายการสะท้อนกันได้โดยกำหนดบริการ Mirror บริการ Mirror จะทำการทำซ้ำการอัปโหลดและการลบข้อมูลข้ามบริการย่อยสองรายการหรือมากกว่า

บริการ Mirror ถูกออกแบบมาเพื่อใช้ชั่วคราวในระหว่างการย้ายระหว่างบริการในการใช้งานจริง คุณสามารถเริ่มการสะท้อนกับบริการใหม่ คัดลอกไฟล์ที่มีอยู่ก่อนหน้านี้จากบริการเก่าไปยังบริการใหม่ แล้วเปลี่ยนไปใช้บริการใหม่

หมายเหตุ: การสะท้อนไม่เป็นแบบอะตอมิก อาจมีการอัปโหลดสำเร็จในบริการหลักและล้มเหลวในบริการย่อยใดบางรายการ ก่อนที่จะเปลี่ยนไปใช้บริการใหม่ ตรวจสอบให้แน่ใจว่าไฟล์ทั้งหมดถูกคัดลอก

กำหนดบริการที่คุณต้องการสะท้อนตามที่อธิบายไว้ด้านบน อ้างถึงชื่อของบริการเมื่อกำหนดบริการ Mirror:

```yaml
s3_west_coast:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""

s3_east_coast:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""

production:
  service: Mirror
  primary: s3_east_coast
  mirrors:
    - s3_west_coast
```

แม้ว่าบริการรองทั้งหมดจะได้รับการอัปโหลด การดาวน์โหลดจะถูกจัดการโดยบริการหลักเสมอ

บริการ Mirror เข้ากันได้กับการอัปโหลดโดยตรง ไฟล์ใหม่ถูกอัปโหลดโดยตรงไปยังบริการหลัก เมื่อไฟล์ที่อัปโหลดโดยตรงถูกแนบกับบันทึก งานพื้นหลังจะถูกเพิ่มเข้าไปในคิวเพื่อคัดลอกไปยังบริการรอง

### การเข้าถึงสาธารณะ

ตามค่าเริ่มต้น Active Storage ถือว่าการเข้าถึงบริการเป็นส่วนตัว ซึ่งหมายความว่าจะสร้างลายเซ็น URL ที่ใช้ได้เพียงครั้งเดียวสำหรับ blobs หากคุณต้องการให้ blobs เป็นสาธารณะได้ ระบุ `public: true` ใน `config/storage.yml` ของแอปของคุณ:

```yaml
gcs: &gcs
  service: GCS
  project: ""

private_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/private_key.json") %>
  bucket: ""

public_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/public_key.json") %>
  bucket: ""
  public: true
```
ตรวจสอบให้แน่ใจว่า Bucket ของคุณได้รับการกำหนดค่าให้สามารถเข้าถึงได้สาธารณะอย่างถูกต้อง ดูเอกสารเกี่ยวกับวิธีเปิดใช้งานสิทธิ์การอ่านสาธารณะสำหรับบริการเก็บข้อมูล [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html), [Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets), และ [Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal) นอกจากนี้ Amazon S3 ยังต้องการให้คุณมีสิทธิ์ `s3:PutObjectAcl` 

เมื่อแปลงแอปพลิเคชันที่มีอยู่ให้ใช้ `public: true` ตรวจสอบให้แน่ใจว่าอัปเดตไฟล์แต่ละไฟล์ใน Bucket เพื่อให้สามารถอ่านได้สาธารณะก่อนที่จะสลับไปใช้งาน

การแนบไฟล์กับเรคคอร์ด
--------------------------

### `has_one_attached`

แมโคร [`has_one_attached`][] จะตั้งค่าการแมปหนึ่งต่อหนึ่งระหว่างเรคคอร์ดและไฟล์ แต่ละเรคคอร์ดสามารถมีไฟล์ที่แนบมาหนึ่งไฟล์ได้

ตัวอย่างเช่น สมมติว่าแอปพลิเคชันของคุณมีโมเดล `User` หากคุณต้องการให้แต่ละผู้ใช้มีอวาตาร์ กำหนดโมเดล `User` ดังนี้:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

หรือหากคุณใช้ Rails 6.0+ คุณสามารถเรียกใช้คำสั่งสร้างโมเดลได้ดังนี้:

```ruby
bin/rails generate model User avatar:attachment
```

คุณสามารถสร้างผู้ใช้พร้อมอวาตาร์ได้:

```erb
<%= form.file_field :avatar %>
```

```ruby
class SignupController < ApplicationController
  def create
    user = User.create!(user_params)
    session[:user_id] = user.id
    redirect_to root_path
  end

  private
    def user_params
      params.require(:user).permit(:email_address, :password, :avatar)
    end
end
```

เรียกใช้ [`avatar.attach`][Attached::One#attach] เพื่อแนบอวาตาร์กับผู้ใช้ที่มีอยู่:

```ruby
user.avatar.attach(params[:avatar])
```

เรียกใช้ [`avatar.attached?`][Attached::One#attached?] เพื่อตรวจสอบว่าผู้ใช้รายบุคคลใดบางรายมีอวาตาร์หรือไม่:

```ruby
user.avatar.attached?
```

ในบางกรณีคุณอาจต้องการแทนที่บริการเริ่มต้นสำหรับการแนบที่เฉพาะ คุณสามารถกำหนดค่าบริการเฉพาะต่อไปนี้ต่อไปนี้โดยใช้ตัวเลือก `service`:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

คุณสามารถกำหนดค่าตัวแปรเฉพาะต่อไปนี้สำหรับการแนบโดยเรียกใช้เมธอด `variant` บนวัตถุที่ได้รับการแนบ:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

เรียกใช้ `avatar.variant(:thumb)` เพื่อรับตัวแปร thumb ของอวาตาร์:

```erb
<%= image_tag user.avatar.variant(:thumb) %>
```

คุณสามารถใช้ตัวแปรเฉพาะสำหรับการแสดงตัวอย่างด้วย:

```ruby
class User < ApplicationRecord
  has_one_attached :video do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

```erb
<%= image_tag user.video.preview(:thumb) %>
```


### `has_many_attached`

แมโคร [`has_many_attached`][] จะตั้งค่าความสัมพันธ์หนึ่งต่อหลายระหว่างเรคคอร์ดและไฟล์ แต่ละเรคคอร์ดสามารถมีไฟล์หลายไฟล์ที่แนบมาได้

ตัวอย่างเช่น สมมติว่าแอปพลิเคชันของคุณมีโมเดล `Message` หากคุณต้องการให้แต่ละข้อความมีภาพหลายภาพ กำหนดโมเดล `Message` ดังนี้:

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

หรือหากคุณใช้ Rails 6.0+ คุณสามารถเรียกใช้คำสั่งสร้างโมเดลได้ดังนี้:

```ruby
bin/rails generate model Message images:attachments
```

คุณสามารถสร้างข้อความพร้อมภาพได้:

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create!(message_params)
    redirect_to message
  end

  private
    def message_params
      params.require(:message).permit(:title, :content, images: [])
    end
end
```

เรียกใช้ [`images.attach`][Attached::Many#attach] เพื่อเพิ่มภาพใหม่ในข้อความที่มีอยู่:

```ruby
@message.images.attach(params[:images])
```

เรียกใช้ [`images.attached?`][Attached::Many#attached?] เพื่อตรวจสอบว่าข้อความใดข้อความหนึ่งมีภาพหรือไม่:

```ruby
@message.images.attached?
```

การแทนที่บริการเริ่มต้นทำได้เหมือนกับ `has_one_attached` โดยใช้ตัวเลือก `service`:

```ruby
class Message < ApplicationRecord
  has_many_attached :images, service: :s3
end
```

การกำหนดค่าตัวแปรเฉพาะทำได้เหมือนกับ `has_one_attached` โดยเรียกใช้เมธอด `variant` บนวัตถุที่ได้รับการแนบ:
```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```



### การแนบไฟล์/วัตถุ IO

บางครั้งคุณอาจต้องแนบไฟล์ที่ไม่ได้มาจาก HTTP request
เช่น คุณอาจต้องการแนบไฟล์ที่คุณสร้างบนดิสก์หรือดาวน์โหลดจาก URL ที่ผู้ใช้ส่งเข้ามา
คุณอาจต้องการแนบไฟล์ fixture ในการทดสอบโมเดล ในกรณีนั้น คุณสามารถให้ Hash ที่มีอย่างน้อย IO object ที่เปิดและชื่อไฟล์:

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

เมื่อเป็นไปได้ โปรดระบุ content type ด้วย Active Storage พยายาม
กำหนดประเภทของไฟล์จากข้อมูลของมัน หากไม่สามารถทำได้ Active Storage จะใช้ content type ที่คุณระบุแทน

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

คุณสามารถข้ามการตรวจสอบประเภทเนื้อหาจากข้อมูลได้โดยส่ง `identify: false` พร้อมกับ `content_type`

```ruby
@message.images.attach(
  io: File.open('/path/to/file'),
  filename: 'file.pdf',
  content_type: 'application/pdf',
  identify: false
)
```

หากคุณไม่ได้ระบุ content type และ Active Storage ไม่สามารถกำหนดประเภทของไฟล์ได้โดยอัตโนมัติ Active Storage จะใช้ค่าเริ่มต้นเป็น application/octet-stream


การลบไฟล์
--------------

ในการลบไฟล์ที่แนบในโมเดล ให้เรียกใช้ [`purge`][Attached::One#purge] บน attachment นั้น หากแอปพลิเคชันของคุณตั้งค่าให้ใช้ Active Job การลบสามารถทำได้ในพื้นหลังโดยเรียกใช้ [`purge_later`][Attached::One#purge_later] การลบจะลบ blob และไฟล์จากบริการจัดเก็บ

```ruby
# ทำลาย avatar และไฟล์ทรัพยากรจริงๆ แบบเสียงตอบกลับ
user.avatar.purge

# ทำลายโมเดลที่เกี่ยวข้องและไฟล์ทรัพยากรจริงๆ แบบเสียงตอบกลับ ผ่าน Active Job
user.avatar.purge_later
```


การให้บริการไฟล์
-------------

Active Storage สนับสนุนวิธีการให้บริการไฟล์สองวิธี: การเปลี่ยนเส้นทางและการโปรกซี

คำเตือน: คอนโทรลเลอร์ Active Storage ทั้งหมดสามารถเข้าถึงได้โดยสาธารณะตามค่าเริ่มต้น URL ที่สร้างขึ้นยากที่จะเดา แต่ถาวรตามออกแบบ หากไฟล์ของคุณต้องการระดับความปลอดภัยที่สูงขึ้น คุณควรพิจารณาการดำเนินการ
[Authenticated Controllers](#authenticated-controllers).

### โหมดการเปลี่ยนเส้นทาง

ในการสร้าง URL ถาวรสำหรับ blob คุณสามารถส่ง blob ไปยัง
[`url_for`][ActionView::RoutingUrlFor#url_for] view helper นี้จะสร้าง
URL ด้วย [`signed_id`][ActiveStorage::Blob#signed_id] ของ blob
ที่เชื่อมต่อกับ [`RedirectController`][`ActiveStorage::Blobs::RedirectController`] ของ blob

```ruby
url_for(user.avatar)
# => /rails/active_storage/blobs/:signed_id/my-avatar.png
```

`RedirectController` จะเปลี่ยนเส้นทางไปยังจุดปลายทางบริการจริง การเปลี่ยนเส้นทางนี้
ทำให้ URL บริการแยกต่างหากจาก URL จริง และอนุญาตให้เกิดการเชื่อมโยงไฟล์ในบริการต่าง ๆ เพื่อให้มีความพร้อมสูง
ตัวเลือกการเปลี่ยนเส้นทางมีอายุการใช้งาน HTTP 5 นาที

ในการสร้างลิงก์ดาวน์โหลด ให้ใช้ `rails_blob_{path|url}` helper นี้
ช่วยให้คุณสามารถตั้งค่า disposition ได้

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

คำเตือน: เพื่อป้องกันการโจมตี XSS Active Storage บังคับให้ Content-Disposition header
เป็น "attachment" สำหรับบางประเภทของไฟล์ หากต้องการเปลี่ยนแปลงพฤติกรรมนี้ โปรดดู
ตัวเลือกการกำหนดค่าที่มีอยู่ใน [การกำหนดค่าแอปพลิเคชัน Rails](configuring.html#configuring-active-storage).

หากคุณต้องการสร้างลิงก์จากภายนอกคอนโทรลเลอร์/วิว (Background
jobs, Cronjobs, เป็นต้น) คุณสามารถเข้าถึง `rails_blob_path` ได้ดังนี้:

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```


### โหมดการโปรกซี

ตัวเลือกอื่น ๆ คือการโปรกซีไฟล์ ซึ่งหมายความว่าเซิร์ฟเวอร์แอปพลิเคชันของคุณจะดาวน์โหลดข้อมูลไฟล์จากบริการจัดเก็บเป็นการตอบสนองต่อคำขอ สิ่งนี้สามารถใช้งานได้สำหรับการให้บริการไฟล์จาก CDN
คุณสามารถกำหนดค่า Active Storage เพื่อใช้โหมด proxying เป็นค่าเริ่มต้นได้:

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

หรือหากคุณต้องการ proxy แนบที่เฉพาะเฉพาะ คุณสามารถใช้ URL helpers ในรูปแบบของ `rails_storage_proxy_path` และ `rails_storage_proxy_url` ได้

```erb
<%= image_tag rails_storage_proxy_path(@user.avatar) %>
```

#### การใช้ CDN สำหรับ Active Storage

นอกจากนี้ เพื่อใช้ CDN สำหรับการแนบ Active Storage คุณจะต้องสร้าง URL ด้วยโหมด proxy เพื่อให้บริการโดยแอปของคุณและ CDN จะแคชแนบโดยไม่ต้องมีการกำหนดค่าเพิ่มเติม สิ่งนี้ทำงานได้โดยอัตโนมัติเนื่องจากคอนโทรลเลอร์ proxy Active Storage เริ่มต้นกำหนด HTTP header เพื่อแจ้งให้ CDN แคชการตอบสนอง

คุณยังควรตรวจสอบให้แน่ใจว่า URL ที่สร้างขึ้นใช้โฮสต์ของ CDN แทนโฮสต์แอปของคุณ มีหลายวิธีในการทำสิ่งนี้ แต่โดยทั่วไปนั้นเกี่ยวข้องกับการปรับแต่งไฟล์ `config/routes.rb` เพื่อให้คุณสามารถสร้าง URL ที่เหมาะสมสำหรับการแนบและการแปลงแบบต่าง ๆ ตัวอย่างเช่น คุณสามารถเพิ่มโค้ดนี้:

```ruby
# config/routes.rb
direct :cdn_image do |model, options|
  expires_in = options.delete(:expires_in) { ActiveStorage.urls_expire_in }

  if model.respond_to?(:signed_id)
    route_for(
      :rails_service_blob_proxy,
      model.signed_id(expires_in: expires_in),
      model.filename,
      options.merge(host: ENV['CDN_HOST'])
    )
  else
    signed_blob_id = model.blob.signed_id(expires_in: expires_in)
    variation_key  = model.variation.key
    filename       = model.blob.filename

    route_for(
      :rails_blob_representation_proxy,
      signed_blob_id,
      variation_key,
      filename,
      options.merge(host: ENV['CDN_HOST'])
    )
  end
end
```

แล้วสร้างเส้นทางดังนี้:

```erb
<%= cdn_image_url(user.avatar.variant(resize_to_limit: [128, 128])) %>
```

### คอนโทรลเลอร์ที่ต้องการการรับรองสิทธิ์

คอนโทรลเลอร์ Active Storage ทั้งหมดสามารถเข้าถึงได้โดยสาธารณะตามค่าเริ่มต้น URL ที่สร้างขึ้นใช้ [`signed_id`][ActiveStorage::Blob#signed_id] ธรรมดา ทำให้ยากต่อการเดาแต่ถาวร ใครก็ตามที่รู้ URL ของ blob จะสามารถเข้าถึงได้ แม้ว่า `before_action` ใน `ApplicationController` ของคุณจะต้องการการเข้าสู่ระบบ หากไฟล์ของคุณต้องการระดับความปลอดภัยที่สูงขึ้น คุณสามารถสร้างคอนโทรลเลอร์ที่ต้องการการรับรองสิทธิ์ของคุณเอง โดยใช้ [`ActiveStorage::Blobs::RedirectController`][], [`ActiveStorage::Blobs::ProxyController`][], [`ActiveStorage::Representations::RedirectController`][] และ [`ActiveStorage::Representations::ProxyController`][]

เพื่ออนุญาตให้บัญชีเฉพาะเข้าถึงโลโก้ของตนเองเท่านั้น คุณสามารถทำตามขั้นตอนต่อไปนี้:

```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # ผ่าน ApplicationController:
  # include Authenticate, SetCurrentAccount

  def show
    redirect_to Current.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

และคุณควรปิดใช้งานเส้นทางเริ่มต้นของ Active Storage ด้วย:

```ruby
config.active_storage.draw_routes = false
```

เพื่อป้องกันการเข้าถึงไฟล์ด้วย URL ที่สาธารณะได้

ดาวน์โหลดไฟล์
-----------------

บางครั้งคุณอาจต้องประมวลผล blob หลังจากอัปโหลด เช่น เพื่อแปลงรูปแบบไฟล์ ใช้เมธอด [`download`][Blob#download] ของแนบเพื่ออ่านข้อมูลไบนารีของ blob เข้าสู่หน่วยความจำ:

```ruby
binary = user.avatar.download
```

คุณอาจต้องการดาวน์โหลด blob เป็นไฟล์บนดิสก์เพื่อให้โปรแกรมภายนอก (เช่น โปรแกรมสแกนไวรัสหรือโปรแกรมแปลงสื่อ) สามารถดำเนินการได้ ใช้เมธอด [`open`][Blob#open] ของแนบเพื่อดาวน์โหลด blob เป็น tempfile บนดิสก์:

```ruby
message.video.open do |file|
  system '/path/to/virus/scanner', file.path
  # ...
end
```

สิ่งสำคัญที่ต้องรู้คือไฟล์ยังไม่พร้อมใช้งานใน callback `after_create` แต่จะพร้อมใช้งานใน `after_create_commit` เท่านั้น

วิเคราะห์ไฟล์
---------------

Active Storage วิเคราะห์ไฟล์หลังจากอัปโหลดโดยจัดคิวงานใน Active Job ไฟล์ที่วิเคราะห์แล้วจะเก็บข้อมูลเพิ่มเติมในแฮช metadata รวมถึง `analyzed: true` คุณสามารถตรวจสอบว่า blob ได้รับการวิเคราะห์แล้วหรือไม่ โดยเรียกใช้ [`analyzed?`][] บน blob
การวิเคราะห์ภาพให้คุณสมบัติ `width` และ `height` ภาพยนตร์วิเคราะห์ให้คุณสมบัติเหล่านี้รวมทั้ง `duration` `angle` `display_aspect_ratio` และ `video` และ `audio` ที่เป็นบูลีนเพื่อแสดงถึงการมีช่องเสียงเหล่านั้น การวิเคราะห์เสียงให้คุณสมบัติ `duration` และ `bit_rate` 

การแสดงภาพ วิดีโอ และ PDF
---------------

Active Storage สนับสนุนการแสดงผลไฟล์หลากหลายรูปแบบ คุณสามารถเรียกใช้ [`representation`][] บน attachment เพื่อแสดงตัวแปรภาพ หรือตัวอย่างวิดีโอหรือ PDF ก่อนที่จะเรียกใช้ `representation` ตรวจสอบว่า attachment สามารถแสดงได้โดยเรียก [`representable?`] บางรูปแบบไฟล์ไม่สามารถดูตัวอย่างได้โดย Active Storage อย่างเช่นเอกสาร Word หาก `representable?` คืนค่าเป็นเท็จคุณอาจต้องการ [ลิงก์ไปยัง](#serving-files) ไฟล์แทน

```erb
<ul>
  <% @message.files.each do |file| %>
    <li>
      <% if file.representable? %>
        <%= image_tag file.representation(resize_to_limit: [100, 100]) %>
      <% else %>
        <%= link_to rails_blob_path(file, disposition: "attachment") do %>
          <%= image_tag "placeholder.png", alt: "Download file" %>
        <% end %>
      <% end %>
    </li>
  <% end %>
</ul>
```

ภายใน `representation` เรียกใช้ `variant` สำหรับภาพ และ `preview` สำหรับไฟล์ที่สามารถดูตัวอย่างได้ คุณยังสามารถเรียกใช้เมธอดเหล่านี้โดยตรง

### การโหลดแบบเกียวกับการโหลดทันที

โดยค่าเริ่มต้น Active Storage จะประมวลผลตัวแทนอย่างเกียวกับการโหลด โค้ดนี้:

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

จะสร้างแท็ก `<img>` โดย `src` ชี้ไปที่ [`ActiveStorage::Representations::RedirectController`][] เบราว์เซอร์จะส่งคำขอไปยังตัวควบคุมนั้น ซึ่งจะดำเนินการดังต่อไปนี้:

1. ประมวลผลไฟล์และอัปโหลดไฟล์ที่ประมวลผลได้ตามที่จำเป็น
2. ส่ง `302` ไปยังไฟล์ทั้งนี้ไปที่
  * บริการระยะไกล (เช่น S3)
  * หรือ `ActiveStorage::Blobs::ProxyController` ซึ่งจะส่งคืนเนื้อหาของไฟล์หาก [โหมดพร็อกซี](#proxy-mode) เปิดใช้งาน

การโหลดไฟล์แบบเกียวกับการโหลดทันทีช่วยให้ฟีเจอร์เช่น [URL ที่ใช้ครั้งเดียว](#public-access) ทำงานโดยไม่ทำให้หน้าเว็บโหลดช้าลง

สำหรับกรณีส่วนใหญ่นี้ทำงานได้ดี

หากคุณต้องการสร้าง URL สำหรับภาพทันทีคุณสามารถเรียกใช้ `.processed.url`:

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

ตัวติดตามตัวแปร Active Storage ปรับปรุงประสิทธิภาพของสิ่งนี้โดยการเก็บบันทึกในฐานข้อมูลหากตัวแทนที่ร้องขอได้ถูกประมวลผลไว้ก่อนหน้านี้ ดังนั้นโค้ดด้านบนจะทำการเรียก API ไปยังบริการระยะไกล (เช่น S3) เพียงครั้งเดียวและเมื่อตัวแปรถูกเก็บไว้แล้วจะใช้ตัวแปรนั้น ตัวติดตามตัวแปรทำงานโดยอัตโนมัติ แต่สามารถปิดใช้งานได้ผ่าน [`config.active_storage.track_variants`][]

หากคุณกำลังแสดงภาพจำนวนมากบนหน้าเว็บตัวอย่างด้านบนอาจส่งผลให้เกิดคำถาม N+1 โหลดเร็คคอร์ดตัวแปรทั้งหมด หากต้องการหลีกเลี่ยงคำถาม N+1 เรียกใช้งานขอบเขตชื่อบน [`ActiveStorage::Attachment`][]

```ruby
message.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```

### การแปลงภาพ

การแปลงภาพช่วยให้คุณสามารถแสดงภาพในขนาดที่คุณเลือกได้ เพื่อสร้างตัวแปรของภาพให้เรียก [`variant`][] บน attachment คุณสามารถส่งการแปลงใดก็ได้ที่รองรับโดยตัวประมวลผลตัวแปรไปยังเมธอดนี้ เมื่อเบราว์เซอร์เข้าถึง URL ตัวแปร Active Storage จะแปลงภาพต้นฉบับเป็นรูปแบบที่ระบุและเปลี่ยนเส้นทางไปยังตำแหน่งบริการใหม่ของมัน

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```

หากร้องขอตัวแปร Active Storage จะใช้การแปลงโดยอัตโนมัติขึ้นอยู่กับรูปแบบของภาพ
1. ประเภทเนื้อหาที่เปลี่ยนแปลงได้ (ตามที่กำหนดโดย [`config.active_storage.variable_content_types`][] )
และไม่ถือเป็นรูปภาพเว็บ (ตามที่กำหนดโดย [`config.active_storage.web_image_content_types`][] )
จะถูกแปลงเป็น PNG

2. หากไม่ระบุ `quality` จะใช้คุณภาพเริ่มต้นของตัวประมวลผลแบร์เวียนตามรูปแบบ

Active Storage สามารถใช้ [Vips][] หรือ MiniMagick เป็นตัวประมวลผลแบร์เวียนได้
ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults` และ
สามารถเปลี่ยนตัวประมวลผลได้โดยการตั้งค่า [`config.active_storage.variant_processor`][]

สองตัวประมวลผลนี้ไม่สามารถทำงานร่วมกันได้อย่างสมบูรณ์ ดังนั้นเมื่อย้ายแอปพลิเคชันที่มีอยู่ระหว่าง MiniMagick และ Vips จะต้องทำการเปลี่ยนแปลงบางอย่างหากใช้ตัวเลือกที่เฉพาะเจาะจงตามรูปแบบ:

```rhtml
<!-- MiniMagick -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80) %>

<!-- Vips -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, saver: { subsample_mode: "on", strip: true, interlace: true, quality: 80 }) %>
```

พารามิเตอร์ที่ใช้ให้ใช้งานได้ถูกกำหนดโดย gem [`image_processing`][] และขึ้นอยู่กับตัวประมวลผลแบร์เวียนที่คุณใช้ แต่ทั้งสองรองรับพารามิเตอร์ต่อไปนี้:

| พารามิเตอร์      | ตัวอย่าง | คำอธิบาย |
| ------------------- | ---------------- | ----- |
| `resize_to_limit` | `resize_to_limit: [100, 100]` | ลดขนาดรูปภาพให้พอดีกับขนาดที่ระบุ โดยรักษาอัตราส่วนเดิม จะปรับขนาดรูปภาพเฉพาะเมื่อมีขนาดใหญ่กว่าที่ระบุ |
| `resize_to_fit` | `resize_to_fit: [100, 100]` | ปรับขนาดรูปภาพให้พอดีกับขนาดที่ระบุ โดยรักษาอัตราส่วนเดิม จะลดขนาดรูปภาพเมื่อมีขนาดใหญ่กว่าที่ระบุ หรือขยายขนาดเมื่อมีขนาดเล็กกว่า |
| `resize_to_fill` | `resize_to_fill: [100, 100]` | ปรับขนาดรูปภาพให้เต็มพื้นที่ที่ระบุ โดยรักษาอัตราส่วนเดิม หากจำเป็นจะตัดรูปภาพในมิติที่ใหญ่กว่า |
| `resize_and_pad` | `resize_and_pad: [100, 100]` | ปรับขนาดรูปภาพให้พอดีกับขนาดที่ระบุ โดยรักษาอัตราส่วนเดิม หากจำเป็นจะเติมพื้นที่ที่เหลือด้วยสีโปร่งใสหากภาพต้นฉบับมีช่องทางอัลฟา หรือสีดำหากไม่มี |
| `crop` | `crop: [20, 50, 300, 300]` | สกัดพื้นที่จากรูปภาพ อาร์กิวเมนต์ 2 ตัวแรกคือขอบซ้ายและบนของพื้นที่ที่จะสกัด ในขณะที่อาร์กิวเมนต์ 2 ตัวสุดท้ายคือความกว้างและความสูงของพื้นที่ที่จะสกัด |
| `rotate` | `rotate: 90` | หมุนภาพตามมุมที่ระบุ |

[`image_processing`][] มีตัวเลือกเพิ่มเติม (เช่น `saver` ซึ่งช่วยกำหนดการบีบอัดรูปภาพ) ในเอกสารของตัวประมวลผลแบร์เวียน [Vips](https://github.com/janko/image_processing/blob/master/doc/vips.md) และ [MiniMagick](https://github.com/janko/image_processing/blob/master/doc/minimagick.md) ได้เอง


### การแสดงตัวอย่างไฟล์

บางไฟล์ที่ไม่ใช่รูปภาพสามารถแสดงตัวอย่างได้: กล่าวคือ สามารถนำเสนอเป็นรูปภาพได้
ตัวอย่างเช่น ไฟล์วิดีโอสามารถแสดงตัวอย่างได้โดยการแยกเฟรมแรกของมัน โดยอัตโนมัติ
Active Storage สนับสนุนการแสดงตัวอย่างวิดีโอและเอกสาร PDF โดยอัตโนมัติ ในการสร้าง
ลิงก์ไปยังตัวอย่างที่สร้างขึ้นแบบ lazy ให้ใช้เมธอด [`preview`][] ของ attachment:

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

หากต้องการเพิ่มการสนับสนุนสำหรับรูปแบบอื่น ๆ ให้เพิ่มตัวแสดงตัวอย่างของคุณเอง ดู
เอกสาร [`ActiveStorage::Preview`][] เพื่อข้อมูลเพิ่มเติม


การอัปโหลดโดยตรง
--------------

Active Storage ร่วมกับไลบรารี JavaScript ที่มาพร้อมในการสนับสนุนการอัปโหลด
โดยตรงจากไคลเอ็นต์ไปยังคลาวด์
### วิธีการใช้งาน

1. เพิ่ม `activestorage.js` ในแบนเดิล JavaScript ของแอปพลิเคชันของคุณ

    ใช้ asset pipeline:

    ```js
    //= require activestorage
    ```

    ใช้ npm package:

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. เพิ่ม `direct_upload: true` ใน [file field](form_helpers.html#uploading-files) ของคุณ

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    หรือหากคุณไม่ได้ใช้ `FormBuilder` ให้เพิ่มแอตทริบิวต์ข้อมูลโดยตรง:

    ```erb
    <input type="file" data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. กำหนดค่า CORS บนบริการจัดเก็บข้อมูลจากบุคคลที่สามเพื่ออนุญาตให้สามารถส่งคำขออัปโหลดโดยตรงได้

4. เสร็จสิ้น! การอัปโหลดจะเริ่มต้นเมื่อฟอร์มถูกส่ง

### การกำหนดค่า Cross-Origin Resource Sharing (CORS)

เพื่อให้การอัปโหลดโดยตรงไปยังบริการจัดเก็บข้อมูลจากบุคคลที่สามทำงานได้ คุณจะต้องกำหนดค่าบริการเพื่ออนุญาตให้รับคำขอ Cross-Origin จากแอปของคุณ โปรดอ่านเอกสาร CORS สำหรับบริการของคุณ:

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

ให้แน่ใจว่าคุณอนุญาต:

* ทุกต้นทางที่แอปของคุณถูกเข้าถึง
* วิธีการคำขอ `PUT`
* ส่วนหัวต่อไปนี้:
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition` (ยกเว้นสำหรับ Azure Storage)
  * `x-ms-blob-content-disposition` (สำหรับ Azure Storage เท่านั้น)
  * `x-ms-blob-type` (สำหรับ Azure Storage เท่านั้น)
  * `Cache-Control` (สำหรับ GCS เท่านั้น หากตั้งค่า `cache_control`)

ไม่จำเป็นต้องกำหนดค่า CORS สำหรับ Disk service เนื่องจากมันใช้ origin ของแอปของคุณ

#### ตัวอย่าง: การกำหนดค่า CORS สำหรับ S3

```json
[
  {
    "AllowedHeaders": [
      "*"
    ],
    "AllowedMethods": [
      "PUT"
    ],
    "AllowedOrigins": [
      "https://www.example.com"
    ],
    "ExposeHeaders": [
      "Origin",
      "Content-Type",
      "Content-MD5",
      "Content-Disposition"
    ],
    "MaxAgeSeconds": 3600
  }
]
```

#### ตัวอย่าง: การกำหนดค่า CORS สำหรับ Google Cloud Storage

```json
[
  {
    "origin": ["https://www.example.com"],
    "method": ["PUT"],
    "responseHeader": ["Origin", "Content-Type", "Content-MD5", "Content-Disposition"],
    "maxAgeSeconds": 3600
  }
]
```

#### ตัวอย่าง: การกำหนดค่า CORS สำหรับ Azure Storage

```xml
<Cors>
  <CorsRule>
    <AllowedOrigins>https://www.example.com</AllowedOrigins>
    <AllowedMethods>PUT</AllowedMethods>
    <AllowedHeaders>Origin, Content-Type, Content-MD5, x-ms-blob-content-disposition, x-ms-blob-type</AllowedHeaders>
    <MaxAgeInSeconds>3600</MaxAgeInSeconds>
  </CorsRule>
</Cors>
```

### เหตุการณ์ JavaScript สำหรับการอัปโหลดโดยตรง

| ชื่อเหตุการณ์ | เป้าหมายเหตุการณ์ | ข้อมูลเหตุการณ์ (`event.detail`) | คำอธิบาย |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | ไม่มี | ฟอร์มที่มีไฟล์สำหรับฟิลด์อัปโหลดโดยตรงถูกส่ง |
| `direct-upload:initialize` | `<input>` | `{id, file}` | ส่งออกสำหรับทุกไฟล์หลังจากการส่งฟอร์ม |
| `direct-upload:start` | `<input>` | `{id, file}` | เริ่มการอัปโหลดโดยตรง |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | ก่อนที่จะทำคำขอไปยังแอปของคุณสำหรับข้อมูลอัปโหลดโดยตรง |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | ก่อนที่จะทำคำขอเพื่อเก็บไฟล์ |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | เมื่อคำขอเพื่อเก็บไฟล์กำลังดำเนินการ |
| `direct-upload:error` | `<input>` | `{id, file, error}` | เกิดข้อผิดพลาด จะแสดง `alert` ถ้าไม่มีการยกเลิกเหตุการณ์นี้ |
| `direct-upload:end` | `<input>` | `{id, file}` | การอัปโหลดโดยตรงเสร็จสิ้น |
| `direct-uploads:end` | `<form>` | ไม่มี | การอัปโหลดโดยตรงทั้งหมดเสร็จสิ้น |

### ตัวอย่าง

คุณสามารถใช้เหตุการณ์เหล่านี้เพื่อแสดงความคืบหน้าของการอัปโหลด

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

เพื่อแสดงไฟล์ที่อัปโหลดในฟอร์ม:

```js
// direct_uploads.js

addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event
  const { id, file } = detail
  target.insertAdjacentHTML("beforebegin", `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename"></span>
    </div>
  `)
  target.previousElementSibling.querySelector(`.direct-upload__filename`).textContent = file.name
})

addEventListener("direct-upload:start", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.remove("direct-upload--pending")
})

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail
  const progressElement = document.getElementById(`direct-upload-progress-${id}`)
  progressElement.style.width = `${progress}%`
})

addEventListener("direct-upload:error", event => {
  event.preventDefault()
  const { id, error } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--error")
  element.setAttribute("title", error)
})

addEventListener("direct-upload:end", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--complete")
})
```
เพิ่มสไตล์:

```css
/* direct_uploads.css */

.direct-upload {
  display: inline-block;
  position: relative;
  padding: 2px 4px;
  margin: 0 3px 3px 0;
  border: 1px solid rgba(0, 0, 0, 0.3);
  border-radius: 3px;
  font-size: 11px;
  line-height: 13px;
}

.direct-upload--pending {
  opacity: 0.6;
}

.direct-upload__progress {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  opacity: 0.2;
  background: #0076ff;
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in;
  transform: translate3d(0, 0, 0);
}

.direct-upload--complete .direct-upload__progress {
  opacity: 0.4;
}

.direct-upload--error {
  border-color: red;
}

input[type=file][data-direct-upload-url][disabled] {
  display: none;
}
```

### การใช้งาน Drag and Drop ที่กำหนดเอง

คุณสามารถใช้คลาส `DirectUpload` เพื่อวัตถุประสงค์นี้ โดยเมื่อได้รับไฟล์จากไลบรารีที่คุณเลือก ให้สร้างอินสแตนซ์ของ `DirectUpload` และเรียกใช้เมธอด create ของมัน ซึ่ง create จะรับค่า callback เพื่อเรียกใช้เมื่อการอัปโหลดเสร็จสิ้น

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// ผูกกับการลากและวางไฟล์ - ใช้ ondrop บนองค์ประกอบหลักหรือใช้
// ไลบรารีเช่น Dropzone
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// ผูกกับการเลือกไฟล์ปกติ
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // คุณอาจล้างไฟล์ที่เลือกจากอินพุต
  input.value = null
})

const uploadFile = (file) => {
  // แบบฟอร์มของคุณต้องมี file_field direct_upload: true ซึ่ง
  // จะให้ข้อมูล data-direct-upload-url
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // จัดการข้อผิดพลาด
    } else {
      // เพิ่มอินพุตที่ซ่อนอยู่ในแบบฟอร์มด้วยชื่อที่เหมาะสม
      // และมีค่าเป็น blob.signed_id เพื่อให้ไอดีของ blob ถูกส่งผ่านกระแสการอัปโหลดปกติ
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

### ติดตามความคืบหน้าของการอัปโหลดไฟล์

เมื่อใช้คอนสตรักเตอร์ `DirectUpload` คุณสามารถรวมพารามิเตอร์ที่สามเข้าไปได้ ซึ่งจะช่วยให้วัตถุ `DirectUpload` เรียกใช้เมธอด `directUploadWillStoreFileWithXHR` ระหว่างกระบวนการอัปโหลด
จากนั้นคุณสามารถแนบตัวจัดการความคืบหน้าของคุณเองกับ XHR เพื่อตอบสนองตามความต้องการของคุณ

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url) {
    this.upload = new DirectUpload(this.file, this.url, this)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // จัดการข้อผิดพลาด
      } else {
        // เพิ่มอินพุตที่ซ่อนอยู่ในแบบฟอร์ม
        // โดยมีค่าเป็น blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // ใช้ event.loaded และ event.total เพื่ออัปเดตแถบความคืบหน้า
  }
}
```

### การผสานรวมกับไลบรารีหรือเฟรมเวิร์ก

เมื่อได้รับไฟล์จากไลบรารีที่คุณเลือก คุณต้องสร้างอินสแตนซ์ `DirectUpload` และใช้เมธอด "create" เพื่อเริ่มกระบวนการอัปโหลด โดยเพิ่มส่วนหัวเพิ่มเติมที่จำเป็นตามที่ต้องการ  "create" ยังต้องการฟังก์ชัน callback เพื่อให้ทำงานเมื่อการอัปโหลดเสร็จสิ้น

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url, token) {
    const headers = { 'Authentication': `Bearer ${token}` }
    // ข้อมูล: การส่งส่วนหัวเป็นพารามิเตอร์ที่ไม่บังคับ หากคุณเลือกไม่ส่งส่วนหัว
    // การรับรองตนเองจะถูกดำเนินการโดยใช้คุกกี้หรือข้อมูลเซสชัน
    this.upload = new DirectUpload(this.file, this.url, this, headers)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // จัดการข้อผิดพลาด
      } else {
        // ใช้ blob.signed_id เป็นการอ้างอิงไฟล์ในคำขอถัดไป
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // ใช้ event.loaded และ event.total เพื่ออัปเดตแถบความคืบหน้า
  }
}
```
ในการนำเอาการรับรองความถูกต้องที่กำหนดเองมาใช้งาน จะต้องสร้างคอนโทรลเลอร์ใหม่ในแอปพลิเคชัน Rails ที่คล้ายกับตัวอย่างด้านล่าง:

```ruby
class DirectUploadsController < ActiveStorage::DirectUploadsController
  skip_forgery_protection
  before_action :authenticate!

  def authenticate!
    @token = request.headers['Authorization']&.split&.last

    return head :unauthorized unless valid_token?(@token)
  end
end
```

หมายเหตุ: การใช้งาน [Direct Uploads](#direct-uploads) อาจทำให้ไฟล์อัปโหลดได้ แต่ไม่ได้แนบไปยังเร็คคอร์ด ควรพิจารณาใช้ [purging unattached uploads](#purging-unattached-uploads) 

การทดสอบ
-------------------------------------------

ใช้ [`fixture_file_upload`][] เพื่อทดสอบการอัปโหลดไฟล์ในการทดสอบการรวมกันหรือการทดสอบคอนโทรลเลอร์  Rails จัดการไฟล์เหมือนกับพารามิเตอร์อื่น ๆ

```ruby
class SignupController < ActionDispatch::IntegrationTest
  test "can sign up" do
    post signup_path, params: {
      name: "David",
      avatar: fixture_file_upload("david.png", "image/png")
    }

    user = User.order(:created_at).last
    assert user.avatar.attached?
  end
end
```


### การลบไฟล์ที่สร้างขึ้นในระหว่างการทดสอบ

#### การทดสอบระบบ

การทดสอบระบบจะล้างข้อมูลการทดสอบโดยการย้อนกลับการทำธุรกรรม โดยเรียกใช้ `destroy` ไม่เคยถูกเรียกใช้กับอ็อบเจกต์ ไฟล์ที่แนบมาจึงไม่ถูกล้าง หากต้องการล้างไฟล์ สามารถทำได้ใน callback `after_teardown` การทำเช่นนี้จะทำให้แน่ใจว่าการเชื่อมต่อที่สร้างขึ้นในระหว่างการทดสอบเสร็จสมบูรณ์และคุณจะไม่ได้รับข้อผิดพลาดจาก Active Storage ที่บอกว่าไม่พบไฟล์

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
  # ...
end
```

หากคุณกำลังใช้ [parallel tests][] และ `DiskService` คุณควรกำหนดค่าให้แต่ละกระบวนการใช้โฟลเดอร์ของตัวเองสำหรับ Active Storage นี้จะทำให้ callback `teardown` ลบไฟล์เฉพาะจากกระบวนการทดสอบที่เกี่ยวข้อง

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
  # ...
end
```

หากการทดสอบระบบของคุณยืนยันการลบโมเดลที่มีการแนบและคุณกำลังใช้งาน Active Job ตั้งค่าสภาพแวดล้อมการทดสอบของคุณให้ใช้ตัวอ่อนแทนคิวเพื่อให้งานการล้างถูกดำเนินการทันทีแทนที่จะเกิดขึ้นในอนาคต

```ruby
# Use inline job processing to make things happen immediately
config.active_job.queue_adapter = :inline
```

[parallel tests]: testing.html#parallel-testing

#### การทดสอบการรวมกัน

เช่นเดียวกับการทดสอบระบบ ไฟล์ที่อัปโหลดในการทดสอบการรวมกันจะไม่ถูกล้างโดยอัตโนมัติ หากต้องการล้างไฟล์ สามารถทำได้ใน callback `teardown`

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

หากคุณกำลังใช้ [parallel tests][] และ Disk service คุณควรกำหนดค่าให้แต่ละกระบวนการใช้โฟลเดอร์ของตัวเองสำหรับ Active Storage นี้จะทำให้ callback `teardown` ลบไฟล์เฉพาะจากกระบวนการทดสอบที่เกี่ยวข้อง

```ruby
class ActionDispatch::IntegrationTest
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

[parallel tests]: testing.html#parallel-testing

### เพิ่มการแนบไฟล์ใน Fixture

คุณสามารถเพิ่มการแนบไฟล์ใน [fixtures][] ที่มีอยู่ของคุณได้ ก่อนอื่นคุณควรสร้างบริการเก็บข้อมูลแยกต่างหาก:

```yml
# config/storage.yml

test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

สิ่งนี้จะบอก Active Storage ว่าจะ "อัปโหลด" ไฟล์ Fixture ไปที่ไหน ดังนั้นควรเป็นไดเรกทอรีชั่วคราว โดยทำให้เป็นไดเรกทอรีที่แตกต่างจากบริการ `test` ปกติของคุณ เพื่อแยกไฟล์ Fixture จากไฟล์ที่อัปโหลดขึ้นในระหว่างการทดสอบ

ต่อไปให้สร้างไฟล์ Fixture สำหรับคลาส Active Storage:

```yml
# active_storage/attachments.yml
david_avatar:
  name: avatar
  record: david (User)
  blob: david_avatar_blob
```

```yml
# active_storage/blobs.yml
david_avatar_blob: <%= ActiveStorage::FixtureSet.blob filename: "david.png", service_name: "test_fixtures" %>
```

จากนั้นให้วางไฟล์ในไดเรกทอรี fixtures ของคุณ (path เริ่มต้นคือ `test/fixtures/files`) โดยใช้ชื่อไฟล์ที่ตรงกัน
ดูเอกสาร [`ActiveStorage::FixtureSet`][] เพื่อข้อมูลเพิ่มเติม

เมื่อทุกอย่างตั้งค่าเรียบร้อยแล้ว คุณจะสามารถเข้าถึงไฟล์แนบในการทดสอบของคุณได้:

```ruby
class UserTest < ActiveSupport::TestCase
  def test_avatar
    avatar = users(:david).avatar

    assert avatar.attached?
    assert_not_nil avatar.download
    assert_equal 1000, avatar.byte_size
  end
end
```

#### การทำความสะอาด Fixtures

ขณะที่ไฟล์ที่อัปโหลดในการทดสอบจะถูกทำความสะอาด [ที่สิ้นสุดของแต่ละทดสอบ](#discarding-files-created-during-tests),
คุณต้องทำความสะอาดไฟล์ fixtures เพียงครั้งเดียว: เมื่อทุกทดสอบเสร็จสมบูรณ์

หากคุณใช้การทดสอบแบบ parallel ให้เรียกใช้ `parallelize_teardown`:

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
  # ...
end
```

หากคุณไม่ใช้การทดสอบแบบ parallel ให้ใช้ `Minitest.after_run` หรือตัวเลือกที่เหมาะสมสำหรับ framework ทดสอบของคุณ (เช่น `after(:suite)` สำหรับ RSpec):

```ruby
# test_helper.rb

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```


### การกำหนดค่า services

คุณสามารถเพิ่ม `config/storage/test.yml` เพื่อกำหนดค่า services ที่จะใช้ในสภาพแวดล้อมการทดสอบ
สิ่งนี้เป็นประโยชน์เมื่อใช้ตัวเลือก `service`.

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

โดยไม่มี `config/storage/test.yml`, จะใช้ `s3` service ที่กำหนดค่าใน `config/storage.yml` - แม้ว่าจะเป็นการรันการทดสอบ

การกำหนดค่าเริ่มต้นจะถูกใช้และไฟล์จะถูกอัปโหลดไปยังผู้ให้บริการที่กำหนดค่าใน `config/storage.yml`

ในกรณีนี้ คุณสามารถเพิ่ม `config/storage/test.yml` และใช้ Disk service สำหรับ `s3` service เพื่อป้องกันการส่งคำขอ

```yaml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

s3:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

การสนับสนุนบริการคลาวด์อื่น
---------------------------------------------

หากคุณต้องการสนับสนุนบริการคลาวด์อื่นนอกเหนือจากนี้ คุณจะต้อง
สร้าง Service เอง แต่ละ Service จะสืบทอดมาจาก
[`ActiveStorage::Service`](https://api.rubyonrails.org/classes/ActiveStorage/Service.html)
โดยการสร้างเมธอดที่จำเป็นในการอัปโหลดและดาวน์โหลดไฟล์ไปยังคลาวด์

การล้างอัปโหลดที่ไม่ได้แนบ
--------------------------

มีกรณีที่ไฟล์ถูกอัปโหลดแต่ไม่ได้แนบกับเรคคอร์ด สามารถเกิดขึ้นได้เมื่อใช้ [การอัปโหลดโดยตรง](#direct-uploads) คุณสามารถค้นหาเรคคอร์ดที่ไม่ได้แนบโดยใช้ [unattached scope](https://github.com/rails/rails/blob/8ef5bd9ced351162b673904a0b77c7034ca2bc20/activestorage/app/models/active_storage/blob.rb#L49) ดังตัวอย่างด้านล่างที่ใช้ [custom rake task](command_line.html#custom-rake-tasks).

```ruby
namespace :active_storage do
  desc "Purges unattached Active Storage blobs. Run regularly."
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge_later)
  end
end
```

คำเตือน: คิวรี่ที่สร้างขึ้นโดย `ActiveStorage::Blob.unattached` อาจช้าและอาจสร้างความไม่สงบในแอปพลิเคชันที่มีฐานข้อมูลขนาดใหญ่กว่านี้
[`has_one_attached`]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_one_attached
[Attached::One#attach]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attach
[Attached::One#attached?]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attached-3F
[`has_many_attached`]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_many_attached
[Attached::Many#attach]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attach
[Attached::Many#attached?]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attached-3F
[Attached::One#purge]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge
[Attached::One#purge_later]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge_later
[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[ActiveStorage::Blob#signed_id]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-signed_id
[`ActiveStorage::Blobs::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Blobs/RedirectController.html
[`ActiveStorage::Blobs::ProxyController`]: https://api.rubyonrails.org/classes/ActiveStorage/Blobs/ProxyController.html
[`ActiveStorage::Representations::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/RedirectController.html
[`ActiveStorage::Representations::ProxyController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/ProxyController.html
[Blob#download]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-download
[Blob#open]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-open
[`analyzed?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html#method-i-analyzed-3F
[`representable?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representable-3F
[`representation`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representation
[`config.active_storage.track_variants`]: configuring.html#config-active-storage-track-variants
[`ActiveStorage::Representations::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/RedirectController.html
[`ActiveStorage::Attachment`]: https://api.rubyonrails.org/classes/ActiveStorage/Attachment.html
[`config.active_storage.variable_content_types`]: configuring.html#config-active-storage-variable-content-types
[`config.active_storage.variant_processor`]: configuring.html#config-active-storage-variant-processor
[`config.active_storage.web_image_content_types`]: configuring.html#config-active-storage-web-image-content-types
[`variant`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-variant
[Vips]: https://www.rubydoc.info/gems/ruby-vips/Vips/Image
[`image_processing`]: https://github.com/janko/image_processing
[`preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-preview
[`ActiveStorage::Preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Preview.html
[`fixture_file_upload`]: https://api.rubyonrails.org/classes/ActionDispatch/TestProcess/FixtureFile.html
[fixtures]: testing.html#the-low-down-on-fixtures
[`ActiveStorage::FixtureSet`]: https://api.rubyonrails.org/classes/ActiveStorage/FixtureSet.html
