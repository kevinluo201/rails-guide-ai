**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fb66c6f4aafffdb8f8d44e8a2076c9b0
การเชื่อมต่อ URL ใน Rails
==============================

เอกสารนี้เป็นเกี่ยวกับคุณสมบัติที่ผู้ใช้เห็นของการเชื่อมต่อ URL ใน Rails

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีการอ่านรหัสใน `config/routes.rb`
* วิธีการสร้างเส้นทางของคุณเองโดยใช้รูปแบบที่ชื่อว่า resourceful style หรือเมธอด `match`
* วิธีการประกาศพารามิเตอร์ของเส้นทางซึ่งถูกส่งไปยังการกระทำของคอนโทรลเลอร์
* วิธีการสร้างเส้นทางและ URL โดยอัตโนมัติโดยใช้ route helpers
* เทคนิคขั้นสูงเช่นการสร้างเงื่อนไขและการติดตั้ง Rack endpoints

--------------------------------------------------------------------------------

วัตถุประสงค์ของ Rails Router
-------------------------------

Rails router จะรู้จัก URL และส่งต่อไปยังการกระทำของคอนโทรลเลอร์หรือแอปพลิเคชัน Rack ได้ นอกจากนี้ยังสามารถสร้างเส้นทางและ URL ได้อัตโนมัติเพื่อลดความจำเป็นในการเขียนรหัสสตริงในหน้าต่างของคุณ

### เชื่อมต่อ URL กับรหัส

เมื่อแอปพลิเคชัน Rails ของคุณได้รับคำขอเข้าสู่ระบบเพื่อ:

```
GET /patients/17
```

มันจะขอให้ router จับคู่กับการกระทำของคอนโทรลเลอร์ หากเส้นทางที่ตรงกันคือ:

```ruby
get '/patients/:id', to: 'patients#show'
```

คำขอจะถูกส่งต่อไปยังการกระทำ `show` ของคอนโทรลเลอร์ `patients` พร้อมกับ `{ id: '17' }` ใน `params`

หมายเหตุ: Rails ใช้ snake_case สำหรับชื่อคอนโทรลเลอร์ที่นี่ หากคุณมีคอนโทรลเลอร์ที่มีคำว่าหลายคำเช่น `MonsterTrucksController` คุณต้องใช้ `monster_trucks#show` เป็นตัวอย่าง

### สร้างเส้นทางและ URL จากรหัส

คุณยังสามารถสร้างเส้นทางและ URL ได้ หากเส้นทางด้านบนถูกแก้ไขให้เป็น:

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

และแอปพลิเคชันของคุณมีรหัสนี้ในคอนโทรลเลอร์:

```ruby
@patient = Patient.find(params[:id])
```

และในมุมมองที่เกี่ยวข้อง:

```erb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

แล้ว router จะสร้างเส้นทาง `/patients/17` ซึ่งจะลดความหักหลังของมุมมองของคุณและทำให้รหัสของคุณง่ายต่อการเข้าใจ โปรดทราบว่าไม่จำเป็นต้องระบุ id ใน route helper

### กำหนดค่า Rails Router

เส้นทางสำหรับแอปพลิเคชันหรือเอ็นจิ้นของคุณจะอยู่ในไฟล์ `config/routes.rb` และมักจะมีลักษณะดังนี้:

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

เนื่องจากเป็นไฟล์ต้นฉบับของ Ruby คุณสามารถใช้คุณสมบัติทั้งหมดของมันเพื่อช่วยในการกำหนดเส้นทาง แต่ควรระมัดระวังเรื่องชื่อตัวแปรเนื่องจากมันอาจชนกับเมธอด DSL ของ router

หมายเหตุ: บล็อก `Rails.application.routes.draw do ... end` ที่ครอบคลุมการกำหนดเส้นทางของคุณจำเป็นต้องสร้างขอบเขตสำหรับ DSL ของ router และต้องไม่ถูกลบ

การเชื่อมต่อทรัพยากร: ค่าเริ่มต้นของ Rails
--------------------------------------------

การเชื่อมต่อทรัพยากรช่วยให้คุณสามารถประกาศเส้นทางทั้งหมดที่เกี่ยวข้องกับคอนโทรลเลอร์ที่ให้ทรัพยากร การเรียกใช้เพียงครั้งเดียวกับ [`resources`][] สามารถประกาศเส้นทางที่จำเป็นทั้งหมดสำหรับการกระทำ `index`, `show`, `new`, `edit`, `create`, `update`, และ `destroy` ของคุณ

### ทรัพยากรบนเว็บ

เบราว์เซอร์จะขอหน้าเว็บจาก Rails โดยการส่งคำขอสำหรับ URL โดยใช้ HTTP method ที่เฉพาะเจาะจง เช่น `GET`, `POST`, `PATCH`, `PUT`, และ `DELETE` แต่ละเมธอดเป็นคำขอในการดำเนินการกับทรัพยากร เส้นทางทรัพยากรจะแมปคำขอที่เกี่ยวข้องไปยังการกระทำในคอนโทรลเลอร์เดียว

เมื่อแอปพลิเคชัน Rails ของคุณได้รับคำขอเข้าสู่ระบบเพื่อ:

```
DELETE /photos/17
```

มันจะขอให้ router แมปไปยังการกระทำของคอนโทรลเลอร์ หากเส้นทางที่ตรงกันคือ:

```ruby
resources :photos
```

Rails จะส่งคำขอนั้นไปยังการกระทำ `destroy` ในคอนโทรลเลอร์ `photos` พร้อมกับ `{ id: '17' }` ใน `params`

### CRUD, Verbs, และ Actions

ใน Rails เส้นทางทรัพยากรให้การแมประหว่าง HTTP verbs และ URLs ไปยังการกระทำในคอนโทรลเลอร์ ตามปกติแล้วแต่การกระทำเชื่อมโยงไปยังการดำเนินการ CRUD ที่เฉพาะเจาะจงในฐานข้อมูล รายการเดียวในไฟล์เส้นทาง เช่น:
```ruby
resources :photos
```

สร้างเส้นทางเจ็ดเส้นทางที่แตกต่างกันในแอปพลิเคชันของคุณ ทั้งหมดเชื่อมโยงกับคอนโทรลเลอร์ `Photos`:

| HTTP Verb | เส้นทาง           | คอนโทรลเลอร์#แอคชัน | ใช้สำหรับ                                     |
| --------- | ---------------- | ----------------- | -------------------------------------------- |
| GET       | /photos          | photos#index      | แสดงรายการภาพทั้งหมด                 |
| GET       | /photos/new      | photos#new        | ส่งคืนแบบฟอร์ม HTML เพื่อสร้างภาพใหม่ |
| POST      | /photos          | photos#create     | สร้างภาพใหม่                           |
| GET       | /photos/:id      | photos#show       | แสดงภาพที่เฉพาะเจาะจง                     |
| GET       | /photos/:id/edit | photos#edit       | ส่งคืนแบบฟอร์ม HTML เพื่อแก้ไขภาพ      |
| PATCH/PUT | /photos/:id      | photos#update     | อัปเดตภาพที่เฉพาะเจาะจง                      |
| DELETE    | /photos/:id      | photos#destroy    | ลบภาพที่เฉพาะเจาะจง                      |

หมายเหตุ: เนื่องจากเราใช้ HTTP verb และ URL ในการจับคู่คำขอที่เข้ามา จึงทำให้มี URL สี่อันที่จับคู่กับแอคชันเจ็ดอันที่แตกต่างกัน

หมายเหตุ: เส้นทางของ Rails จะถูกจับคู่ตามลำดับที่ระบุ ดังนั้นหากคุณมี `resources :photos` อยู่ด้านบนของ `get 'photos/poll'` เส้นทางของแอคชัน `show` สำหรับบรรทัด `resources` จะถูกจับคู่ก่อนบรรทัด `get` เพื่อแก้ไขปัญหานี้ให้ย้ายบรรทัด `get` **ขึ้นไปด้านบน** ของบรรทัด `resources` เพื่อให้มันถูกจับคู่ก่อน

### เส้นทางและเครื่องมือช่วย URL

การสร้างเส้นทางที่มีทรัพยากรจะเปิดเผยเครื่องมือหลายอย่างให้กับคอนโทรลเลอร์ในแอปพลิเคชันของคุณ ในกรณีของ `resources :photos`:

* `photos_path` ส่งคืน `/photos`
* `new_photo_path` ส่งคืน `/photos/new`
* `edit_photo_path(:id)` ส่งคืน `/photos/:id/edit` (ตัวอย่างเช่น `edit_photo_path(10)` ส่งคืน `/photos/10/edit`)
* `photo_path(:id)` ส่งคืน `/photos/:id` (ตัวอย่างเช่น `photo_path(10)` ส่งคืน `/photos/10`)

แต่ละเครื่องมือช่วยนี้มีเครื่องมือ `_url` ที่สอดคล้อง (เช่น `photos_url`) ซึ่งส่งคืนเส้นทางเดียวกันที่มีคำนำหน้าโฮสต์ปัจจุบัน เลขพอร์ต และคำนำหน้าเส้นทาง

เคล็ดลับ: หากต้องการหาชื่อเครื่องมือเส้นทางสำหรับเส้นทางของคุณ ดูที่ [การรายการเส้นทางที่มีอยู่](#การรายการเส้นทางที่มีอยู่) ด้านล่าง

### การกำหนดทรัพยากรหลายรายการในเวลาเดียวกัน

หากคุณต้องการสร้างเส้นทางสำหรับทรัพยากรมากกว่าหนึ่งรายการ คุณสามารถประหยัดการพิมพ์ได้โดยกำหนดทั้งหมดในการเรียกใช้เดียวกันกับ `resources`:

```ruby
resources :photos, :books, :videos
```

นี้ทำงานเหมือนกับ:

```ruby
resources :photos
resources :books
resources :videos
```

### ทรัพยากรเดี่ยว

บางครั้งคุณมีทรัพยากรที่ไคลเอ็นต์ต้องการค้นหาเสมอโดยไม่ต้องอ้างอิง ID ตัวอย่างเช่นคุณต้องการให้ `/profile` แสดงโปรไฟล์ของผู้ใช้ที่เข้าสู่ระบบอยู่ในขณะนั้น ในกรณีนี้คุณสามารถใช้ทรัพยากรเดี่ยวเพื่อแมป `/profile` (ไม่ใช่ `/profile/:id`) ไปยังแอคชัน `show`:

```ruby
get 'profile', to: 'users#show'
```

การส่ง `String` ไปยัง `to:` จะคาดหวังรูปแบบ `controller#action` เมื่อใช้ `Symbol` ตัวเลือก `to:` ควรถูกแทนที่ด้วย `action:` เมื่อใช้ `String` โดยไม่มี `#` ตัวเลือก `to:` ควรถูกแทนที่ด้วย `controller:`:

```ruby
get 'profile', action: :show, controller: 'users'
```

เส้นทางทรัพยากรเดี่ยวนี้:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

สร้างเส้นทางหกเส้นทางที่แตกต่างกันในแอปพลิเคชันของคุณ ทั้งหมดเชื่อมโยงกับคอนโทรลเลอร์ `Geocoders`:

| HTTP Verb | เส้นทาง           | คอนโทรลเลอร์#แอคชัน | ใช้สำหรับ                                      |
| --------- | -------------- | ----------------- | --------------------------------------------- |
| GET       | /geocoder/new  | geocoders#new     | ส่งคืนแบบฟอร์ม HTML เพื่อสร้าง geocoder ใหม่ |
| POST      | /geocoder      | geocoders#create  | สร้าง geocoder ใหม่                           |
| GET       | /geocoder      | geocoders#show    | แสดงทรัพยากร geocoder เดียวเท่านั้น            |
| GET       | /geocoder/edit | geocoders#edit    | ส่งคืนแบบฟอร์ม HTML เพื่อแก้ไข geocoder     |
| PATCH/PUT | /geocoder      | geocoders#update  | อัปเดตทรัพยากร geocoder เดียวเท่านั้น             |
| DELETE    | /geocoder      | geocoders#destroy | ลบทรัพยากร geocoder                           |

หมายเหตุ: เนื่องจากคุณอาจต้องการใช้คอนโทรลเลอร์เดียวกันสำหรับเส้นทางเดี่ยว (`/account`) และเส้นทางพหูพจน์ (`/accounts/45`) ทรัพยากรเดี่ยวจะแมปไปยังคอนโทรลเลอร์พหูพจน์ เพื่อตัวอย่างเช่น `resource :photo` และ `resources :photos` จะสร้างทั้งเส้นทางเดี่ยวและพหูพจน์ที่แมปไปยังคอนโทรลเลอร์เดียวกัน (`PhotosController`)
เส้นทางที่มีความสามารถเดียวกันสร้างผู้ช่วยเหล่านี้:

* `new_geocoder_path` ส่งคืน `/geocoder/new`
* `edit_geocoder_path` ส่งคืน `/geocoder/edit`
* `geocoder_path` ส่งคืน `/geocoder`

หมายเหตุ: การเรียกใช้ `resolve` เป็นจำเป็นสำหรับแปลงอินสแตนซ์ของ `Geocoder` เป็นเส้นทางผ่าน [การระบุระเบียน](form_helpers.html#relying-on-record-identification) 

เช่นเดียวกับทรัพยากรพหูพจน์ เหล่าผู้ช่วยที่สิ้นสุดด้วย `_url` จะรวมถึงโฮสต์ พอร์ต และคำนำหน้าเส้นทางเช่นเดียวกัน

### การจัดกลุ่มและเส้นทางของคอนโทรลเลอร์

คุณอาจต้องการจัดกลุ่มคอนโทรลเลอร์ภายใต้เนมสเปซ โดยทั่วไป คุณอาจจะจัดกลุ่มคอนโทรลเลอร์ทางด้านการบริหารในเนมสเปซ `Admin::` และวางคอนโทรลเลอร์เหล่านี้ภายใต้ไดเรกทอรี `app/controllers/admin` คุณสามารถเส้นทางไปยังกลุ่มดังกล่าวได้โดยใช้บล็อก [`namespace`][]:

```ruby
namespace :admin do
  resources :articles, :comments
end
```

สิ่งนี้จะสร้างเส้นทางหลายเส้นสำหรับแต่ละคอนโทรลเลอร์ `articles` และ `comments` สำหรับ `Admin::ArticlesController` Rails จะสร้าง:

| HTTP Verb | เส้นทาง                     | คอนโทรลเลอร์#แอคชัน      | ผู้ช่วยเส้นทางที่มีชื่อ |
| --------- | ------------------------ | ---------------------- | ---------------------------- |
| GET       | /admin/articles          | admin/articles#index   | admin_articles_path          |
| GET       | /admin/articles/new      | admin/articles#new     | new_admin_article_path       |
| POST      | /admin/articles          | admin/articles#create  | admin_articles_path          |
| GET       | /admin/articles/:id      | admin/articles#show    | admin_article_path(:id)      |
| GET       | /admin/articles/:id/edit | admin/articles#edit    | edit_admin_article_path(:id) |
| PATCH/PUT | /admin/articles/:id      | admin/articles#update  | admin_article_path(:id)      |
| DELETE    | /admin/articles/:id      | admin/articles#destroy | admin_article_path(:id)      |

หากคุณต้องการเส้นทาง `/articles` (โดยไม่มีคำนำหน้า `/admin`) ไปยัง `Admin::ArticlesController` คุณสามารถระบุโมดูลด้วยบล็อก [`scope`][]:

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

สามารถทำได้เช่นเดียวกันสำหรับเส้นทางเดียว:

```ruby
resources :articles, module: 'admin'
```

หากคุณต้องการเส้นทาง `/admin/articles` ไปยัง `ArticlesController` (โดยไม่มีคำนำหน้าโมดูล `Admin::`) คุณสามารถระบุเส้นทางด้วยบล็อก `scope`:

```ruby
scope '/admin' do
  resources :articles, :comments
end
```

สามารถทำได้เช่นเดียวกันสำหรับเส้นทางเดียว:

```ruby
resources :articles, path: '/admin/articles'
```

ในทั้งสองกรณีเหล่าผู้ช่วยเส้นทางที่มีชื่อจะเหมือนเดิมกับกรณีที่คุณไม่ได้ใช้ `scope` ในกรณีสุดท้าย เส้นทางต่อไปนี้จะแมปไปยัง `ArticlesController`:

| HTTP Verb | เส้นทาง                     | คอนโทรลเลอร์#แอคชัน    | ผู้ช่วยเส้นทางที่มีชื่อ |
| --------- | ------------------------ | -------------------- | ---------------------- |
| GET       | /admin/articles          | articles#index       | articles_path          |
| GET       | /admin/articles/new      | articles#new         | new_article_path       |
| POST      | /admin/articles          | articles#create      | articles_path          |
| GET       | /admin/articles/:id      | articles#show        | article_path(:id)      |
| GET       | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id) |
| PATCH/PUT | /admin/articles/:id      | articles#update      | article_path(:id)      |
| DELETE    | /admin/articles/:id      | articles#destroy     | article_path(:id)      |

เคล็ดลับ: หากคุณต้องการใช้เนมสเปซคอนโทรลเลอร์ที่แตกต่างภายในบล็อก `namespace` คุณสามารถระบุเส้นทางคอนโทรลเลอร์แบบสมบูรณ์ เช่น: `get '/foo', to: '/foo#index'`


### ทรัพยากรที่ซ้อนกัน

มักจะมีทรัพยากรที่เป็นลูกของทรัพยากรอื่นที่มีความสัมพันธ์ตามตรรกะ ตัวอย่างเช่น สมมติว่าแอปพลิเคชันของคุณรวมถึงโมเดลเหล่านี้:

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

เส้นทางที่ซ้อนกันช่วยให้คุณจับความสัมพันธ์นี้ในการเส้นทางของคุณ ในกรณีนี้ คุณสามารถรวมการประกาศเส้นทางดังต่อไปนี้:

```ruby
resources :magazines do
  resources :ads
end
```

นอกจากเส้นทางสำหรับนิตยสารแล้ว การประกาศนี้ยังจะเส้นทางโฆษณาไปยัง `AdsController` URL ของโฆษณาต้องการนิตยสาร:

| HTTP Verb | เส้นทาง                                 | คอนโทรลเลอร์#แอคชัน | ใช้สำหรับ                                                             |
| --------- | ------------------------------------ | ----------------- | -------------------------------------------------------------------------- |
| GET       | /magazines/:magazine_id/ads          | ads#index         | แสดงรายการโฆษณาทั้งหมดสำหรับนิตยสารที่ระบุ                          |
| GET       | /magazines/:magazine_id/ads/new      | ads#new           | ส่งคืนแบบฟอร์ม HTML สำหรับสร้างโฆษณาใหม่ที่เป็นของนิตยสารที่ระบุ |
| POST      | /magazines/:magazine_id/ads          | ads#create        | สร้างโฆษณาใหม่ที่เป็นของนิตยสารที่ระบุ                                |
| GET       | /magazines/:magazine_id/ads/:id      | ads#show          | แสดงโฆษณาที่เฉพาะเจาะจงที่เป็นของนิตยสารที่ระบุ                      |
| GET       | /magazines/:magazine_id/ads/:id/edit | ads#edit          | ส่งคืนแบบฟอร์ม HTML สำหรับแก้ไขโฆษณาที่เป็นของนิตยสารที่ระบุ      |
| PATCH/PUT | /magazines/:magazine_id/ads/:id      | ads#update        | อัปเดตโฆษณาที่เฉพาะเจาะจงที่เป็นของนิตยสารที่ระบุ                      |
| DELETE    | /magazines/:magazine_id/ads/:id      | ads#destroy       | ลบโฆษณาที่เฉพาะเจาะจงที่เป็นของนิตยสารที่ระบุ                      |
นอกจากนี้ยังสร้างเครื่องมือช่วยในการเชื่อมต่อเช่น `magazine_ads_url` และ `edit_magazine_ad_path` ซึ่งเครื่องมือเหล่านี้จะรับอินสแตนซ์ของ Magazine เป็นพารามิเตอร์แรก (`magazine_ads_url(@magazine)`)

#### ข้อจำกัดในการซ้อนกัน

คุณสามารถซ้อนทรัพยากรภายในทรัพยากรซ้อนกันได้ตามต้องการ ตัวอย่างเช่น:

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

ทรัพยากรที่ซ้อนกันลึกๆ จะทำให้เกิดความยุ่งยาก ในกรณีนี้ เช่น เมื่อแอปพลิเคชันรับรู้เส้นทางเช่น:

```
/publishers/1/magazines/2/photos/3
```

เครื่องมือช่วยเส้นทางที่เกี่ยวข้องคือ `publisher_magazine_photo_url` ซึ่งต้องการให้คุณระบุอ็อบเจ็กต์ในระดับทั้งสามระดับ ในความเป็นจริง สถานการณ์นี้ยุ่งยากพอที่ [บทความยอดนิยมของ Jamis Buck](http://weblog.jamisbuck.org/2007/2/5/nesting-resources) แนะนำกฎบัญญัติสำหรับการออกแบบ Rails ที่ดี:

เคล็ดลับ: ทรัพยากรไม่ควรซ้อนกันมากกว่า 1 ระดับ

#### การซ้อนกันแบบ Shallow

วิธีหนึ่งในการหลีกเลี่ยงการซ้อนกันลึก (ตามที่แนะนำด้านบน) คือการสร้างการกระทำของคอลเลกชันที่มีขอบเขตอยู่ภายใต้คอลเลกชันหลัก เพื่อให้ได้ความรู้สึกเกี่ยวข้องกับลำดับชั้น แต่ไม่ซ้อนกันของการกระทำสมาชิก กล่าวอีกนัยหนึ่งคือการสร้างเส้นทางโดยใช้ข้อมูลที่น้อยที่สุดเพื่อระบุทรัพยากรที่ไม่ซ้ำกัน เช่น:

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

ความคิดนี้สมดุลระหว่างเส้นทางที่มีคำอธิบายและการซ้อนกันลึก มีสัญลักษณ์ย่อที่ใช้สำหรับการทำเช่นนั้น ผ่านตัวเลือก `:shallow`:

```ruby
resources :articles do
  resources :comments, shallow: true
end
```

นี้จะสร้างเส้นทางเหมือนกับตัวอย่างแรก คุณยังสามารถระบุตัวเลือก `:shallow` ในทรัพยากรหลัก ในกรณีนี้ทรัพยากรที่ซ้อนกันทั้งหมดจะเป็นแบบ shallow:

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

ทรัพยากรบทความที่นี่จะมีเส้นทางที่สร้างขึ้นสำหรับมัน:

| HTTP Verb | เส้นทาง                                         | คอนโทรลเลอร์#การกระทำ | เครื่องมือช่วยเส้นทางที่มีชื่อ |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_comment_path        |
| GET       | /comments/:id(.:format)                      | comments#show     | comment_path             |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | comment_path             |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | comment_path             |
| GET       | /articles/:article_id/quotes(.:format)       | quotes#index      | article_quotes_path      |
| POST      | /articles/:article_id/quotes(.:format)       | quotes#create     | article_quotes_path      |
| GET       | /articles/:article_id/quotes/new(.:format)   | quotes#new        | new_article_quote_path   |
| GET       | /quotes/:id/edit(.:format)                   | quotes#edit       | edit_quote_path          |
| GET       | /quotes/:id(.:format)                        | quotes#show       | quote_path               |
| PATCH/PUT | /quotes/:id(.:format)                        | quotes#update     | quote_path               |
| DELETE    | /quotes/:id(.:format)                        | quotes#destroy    | quote_path               |
| GET       | /articles/:article_id/drafts(.:format)       | drafts#index      | article_drafts_path      |
| POST      | /articles/:article_id/drafts(.:format)       | drafts#create     | article_drafts_path      |
| GET       | /articles/:article_id/drafts/new(.:format)   | drafts#new        | new_article_draft_path   |
| GET       | /drafts/:id/edit(.:format)                   | drafts#edit       | edit_draft_path          |
| GET       | /drafts/:id(.:format)                        | drafts#show       | draft_path               |
| PATCH/PUT | /drafts/:id(.:format)                        | drafts#update     | draft_path               |
| DELETE    | /drafts/:id(.:format)                        | drafts#destroy    | draft_path               |
| GET       | /articles(.:format)                          | articles#index    | articles_path            |
| POST      | /articles(.:format)                          | articles#create   | articles_path            |
| GET       | /articles/new(.:format)                      | articles#new      | new_article_path         |
| GET       | /articles/:id/edit(.:format)                 | articles#edit     | edit_article_path        |
| GET       | /articles/:id(.:format)                      | articles#show     | article_path             |
| PATCH/PUT | /articles/:id(.:format)                      | articles#update   | article_path             |
| DELETE    | /articles/:id(.:format)                      | articles#destroy  | article_path             |

เมธอด [`shallow`][] ใน DSL สร้างขอบเขตภายในนั้นทุกการซ้อนกันจะเป็นแบบ shallow สร้างเส้นทางเหมือนกับตัวอย่างก่อนหน้านี้:

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```
มีตัวเลือกสองอย่างสำหรับ `scope` เพื่อปรับแต่งเส้นทาง shallow ได้ `:shallow_path` ทำให้เส้นทางสมาชิกมีคำนำหน้าด้วยพารามิเตอร์ที่ระบุ:

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

ทรัพยากรความคิดเห็นที่นี่จะมีเส้นทางที่สร้างขึ้นสำหรับมันดังนี้:

| HTTP Verb | เส้นทาง                                         | คอนโทรลเลอร์#แอคชัน | เฮลเปอร์ของเส้นทางที่มีชื่อ       |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /sekret/comments/:id/edit(.:format)          | comments#edit     | edit_comment_path        |
| GET       | /sekret/comments/:id(.:format)               | comments#show     | comment_path             |
| PATCH/PUT | /sekret/comments/:id(.:format)               | comments#update   | comment_path             |
| DELETE    | /sekret/comments/:id(.:format)               | comments#destroy  | comment_path             |

ตัวเลือก `:shallow_prefix` เพิ่มพารามิเตอร์ที่ระบุไปยังเฮลเปอร์ของเส้นทางที่มีชื่อ:

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

ทรัพยากรความคิดเห็นที่นี่จะมีเส้นทางที่สร้างขึ้นสำหรับมันดังนี้:

| HTTP Verb | เส้นทาง                                         | คอนโทรลเลอร์#แอคชัน | เฮลเปอร์ของเส้นทางที่มีชื่อ          |
| --------- | -------------------------------------------- | ----------------- | --------------------------- |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path       |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path       |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path    |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_sekret_comment_path    |
| GET       | /comments/:id(.:format)                      | comments#show     | sekret_comment_path         |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | sekret_comment_path         |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | sekret_comment_path         |


### เรื่องที่เกี่ยวกับการเชื่อมโยง

การเชื่อมโยงเรื่องที่เกี่ยวข้องช่วยให้คุณประกาศเส้นทางที่ซ้ำกันที่สามารถนำมาใช้ในทรัพยากรและเส้นทางอื่น ๆ ได้ ในการกำหนดเรื่องที่เกี่ยวข้องให้ใช้บล็อก [`concern`][]:

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

เรื่องที่เกี่ยวข้องเหล่านี้สามารถใช้ในทรัพยากรเพื่อหลีกเลี่ยงการทำซ้ำของโค้ดและแบ่งปันพฤติกรรมของเส้นทาง:

```ruby
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

สิ่งที่กล่าวมาข้างต้นเทียบเท่ากับ:

```ruby
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```

คุณยังสามารถใช้เรื่องที่เกี่ยวข้องที่ใดก็ได้โดยเรียกใช้ [`concerns`][]. ตัวอย่างเช่นในบล็อก `scope` หรือ `namespace`:

```ruby
namespace :articles do
  concerns :commentable
end
```


### การสร้างเส้นทางและ URL จากอ็อบเจกต์

นอกจากการใช้ตัวช่วยในการเชื่อมโยงเส้นทาง Rails ยังสามารถสร้างเส้นทางและ URL จากอาร์เรย์ของพารามิเตอร์ได้ ตัวอย่างเช่นสมมุติว่าคุณมีเซ็ตของเส้นทางนี้:

```ruby
resources :magazines do
  resources :ads
end
```

เมื่อใช้ `magazine_ad_path` คุณสามารถส่งอินสแตนซ์ของ `Magazine` และ `Ad` แทน ID ตัวเลขได้:

```erb
<%= link_to 'รายละเอียดโฆษณา', magazine_ad_path(@magazine, @ad) %>
```

คุณยังสามารถใช้ [`url_for`][ActionView::RoutingUrlFor#url_for] กับชุดอ็อบเจกต์และ Rails จะกำหนดเส้นทางที่คุณต้องการโดยอัตโนมัติ:

```erb
<%= link_to 'รายละเอียดโฆษณา', url_for([@magazine, @ad]) %>
```

ในกรณีนี้ Rails จะเห็นว่า `@magazine` เป็น `Magazine` และ `@ad` เป็น `Ad` และจะใช้ตัวช่วย `magazine_ad_path` ในช่วยเหลือเส้นทาง ในตัวช่วยเช่น `link_to` คุณสามารถระบุอ็อบเจกต์เพียงอย่างเดียวแทนการเรียก `url_for` เต็มรูปแบบ:

```erb
<%= link_to 'รายละเอียดโฆษณา', [@magazine, @ad] %>
```

หากคุณต้องการเชื่อมโยงไปยังนิติกรรมเพียงอย่างเดียว:

```erb
<%= link_to 'รายละเอียดนิติกรรม', @magazine %>
```

สำหรับการกระทำอื่น ๆ คุณเพียงแค่เพิ่มชื่อการกระทำเป็นส่วนแรกของอาร์เรย์:

```erb
<%= link_to 'แก้ไขโฆษณา', [:edit, @magazine, @ad] %>
```

สิ่งนี้ช่วยให้คุณสามารถใช้อินสแตนซ์ของโมเดลของคุณเป็น URL และเป็นข้อดีสำคัญในการใช้รูปแบบทรัพยากร


### เพิ่มการกระทำ RESTful เพิ่มเติม

คุณไม่จำกัดเพียงเพียงเจ็ดเส้นทางที่ RESTful routing สร้างโดยค่าเริ่มต้น หากคุณต้องการคุณสามารถเพิ่มเส้นทางเพิ่มเติมที่ใช้กับคอลเลกชันหรือสมาชิกแต่ละรายการได้
#### เพิ่มเส้นทางสมาชิก

ในการเพิ่มเส้นทางสมาชิกเพียงแค่เพิ่มบล็อก [`member`][] ลงในบล็อกของทรัพยากร:

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

นี้จะรู้จัก `/photos/1/preview` ด้วย GET และเส้นทางไปยังการกระทำ `preview` ของ `PhotosController` โดยมีค่า id ของทรัพยากรที่ผ่านมาใน `params[:id]` นอกจากนี้ยังสร้างตัวช่วย `preview_photo_url` และ `preview_photo_path` ด้วย

ภายในบล็อกของเส้นทางสมาชิก ชื่อเส้นทางแต่ละอันระบุ HTTP verb ที่จะรู้จัก คุณสามารถใช้ [`get`][], [`patch`][], [`put`][], [`post`][], หรือ [`delete`][] ที่นี่ได้
. หากคุณไม่มีเส้นทางสมาชิกหลายอัน คุณยังสามารถส่ง `:on` ไปยังเส้นทางเพื่อลดบล็อกได้:

```ruby
resources :photos do
  get 'preview', on: :member
end
```

คุณสามารถละเว้นตัวเลือก `:on` นี้ได้ นี้จะสร้างเส้นทางสมาชิกเดียวกันยกเว้นว่าค่า id ของทรัพยากรจะสามารถใช้ได้ใน `params[:photo_id]` แทนที่จะใช้ `params[:id]` เส้นทางช่วยก็จะถูกเปลี่ยนชื่อจาก `preview_photo_url` และ `preview_photo_path` เป็น `photo_preview_url` และ `photo_preview_path`


#### เพิ่มเส้นทางสำหรับคอลเลกชัน

ในการเพิ่มเส้นทางไปยังคอลเลกชัน ให้ใช้บล็อก [`collection`][]:

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

นี้จะทำให้ Rails รู้จักเส้นทางเช่น `/photos/search` ด้วย GET และเส้นทางไปยังการกระทำ `search` ของ `PhotosController` โดยยังสร้างตัวช่วย `search_photos_url` และ `search_photos_path` ด้วย

เหมือนกับเส้นทางสมาชิก คุณสามารถส่ง `:on` ไปยังเส้นทางได้:

```ruby
resources :photos do
  get 'search', on: :collection
end
```

หมายเหตุ: หากคุณกำลังกำหนดเส้นทางทรัพยากรเพิ่มเติมด้วยสัญลักษณ์เป็นอาร์กิวเมนต์ตำแหน่งแรก โปรดทราบว่าสัญลักษณ์จะให้ความหมายถึงการกระทำของคอนโทรลเลอร์ในขณะที่สตริงจะให้ความหมายถึงเส้นทาง


#### เพิ่มเส้นทางสำหรับการกระทำใหม่เพิ่มเติม

ในการเพิ่มการกระทำใหม่โดยใช้ทางลัด `:on`:

```ruby
resources :comments do
  get 'preview', on: :new
end
```

นี้จะทำให้ Rails รู้จักเส้นทางเช่น `/comments/new/preview` ด้วย GET และเส้นทางไปยังการกระทำ `preview` ของ `CommentsController` โดยยังสร้างตัวช่วย `preview_new_comment_url` และ `preview_new_comment_path` ด้วย

เคล็ดลับ: หากคุณพบว่าคุณกำลังเพิ่มการกระทำเพิ่มเติมมากมายในเส้นทางทรัพยากร นั่นคือเวลาที่คุณควรหยุดและถามตัวเองว่าคุณกำลังปกปิดการมีอีกทรัพยากรหรือไม่

เส้นทางที่ไม่ใช่ทรัพยากร
----------------------

นอกเหนือจากการเส้นทางทรัพยากร Rails ยังมีการสนับสนุนที่แข็งแกร่งสำหรับการเส้นทาง URL อย่างอิสระไปยังการกระทำ ที่นี่คุณไม่ได้รับกลุ่มของเส้นทางที่สร้างขึ้นโดยอัตโนมัติจากการเส้นทางทรัพยากร แต่คุณตั้งค่าเส้นทางแต่ละเส้นทางแยกต่างหากภายในแอปพลิเคชันของคุณ

แม้ว่าคุณควรใช้การเส้นทางทรัพยากรเสมอ แต่ก็ยังมีสถานที่หลายแห่งที่การเส้นทางที่เรียบง่ายกว่าเหมาะสม ไม่จำเป็นต้องพยายามเอาทุกส่วนสุดท้ายของแอปพลิเคชันของคุณเข้ากับกรอบการทำงานที่เป็นทรัพยากรหากไม่เหมาะสม

โดยเฉพาะอย่างยิ่ง เส้นทางที่เรียบง่ายทำให้ง่ายมากที่จะแมป URL เก่ากับการกระทำ Rails ใหม่

### พารามิเตอร์ที่ผูก

เมื่อคุณตั้งค่าเส้นทางปกติ คุณจะระบุชุดของสัญลักษณ์ที่ Rails จะแมปไปยังส่วนของคำขอ HTTP ที่เข้ามา ตัวอย่างเช่นพิจารณาเส้นทางนี้:

```ruby
get 'photos(/:id)', to: 'photos#display'
```

หากคำขอเข้ามาเป็น `/photos/1` ถูกประมวลผลโดยเส้นทางนี้ (เนื่องจากไม่ตรงกับเส้นทางก่อนหน้าในไฟล์) ผลลัพธ์จะเป็นการเรียกใช้การกระทำ `display` ของ `PhotosController` และทำให้พารามิเตอร์สุดท้ายเป็น `"1"` ที่ใช้ใน `params[:id]` ส่วนเส้นทางนี้ยังจะเส้นทางคำขอเข้ามาเป็น `/photos` ไปยัง `PhotosController#display` เนื่องจาก `:id` เป็นพารามิเตอร์ที่ไม่บังคับ ที่ระบุโดยวงเล็บ

### ส่วนที่เปลี่ยนแปลงได้

คุณสามารถตั้งค่าส่วนที่เปลี่ยนได้ในเส้นทางปกติเท่าที่คุณต้องการ ส่วนใดก็ตามจะสามารถใช้ในการกระทำเป็นส่วนหนึ่งของ `params` หากคุณตั้งค่าเส้นทางนี้:

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

เส้นทางที่เข้ามาเป็น `/photos/1/2` จะถูกส่งต่อไปยังการกระทำ `show` ของ `PhotosController` `params[:id]` จะเป็น `"1"` และ `params[:user_id]` จะเป็น `"2"`
เคล็ดลับ: ตามค่าเริ่มต้น, ส่วนที่เปลี่ยนได้แบบพลวัตไม่รับรู้จุด - นี่เพราะจุดถูกใช้เป็นตัวคั่นสำหรับเส้นทางที่จัดรูปแบบไว้ หากคุณต้องการใช้จุดภายในส่วนที่เปลี่ยนได้แบบพลวัต ให้เพิ่มข้อจำกัดที่เขียนทับนี้ - ตัวอย่างเช่น `id: /[^\/]+/` อนุญาตให้ใช้ทุกอย่างยกเว้นเครื่องหมายสแลช

### ส่วนที่เปลี่ยนได้แบบคงที่

คุณสามารถระบุส่วนที่เปลี่ยนได้แบบคงที่เมื่อสร้างเส้นทางโดยไม่ตั้งค่าเครื่องหมายสแลชไว้ก่อนส่วน:

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

เส้นทางนี้จะตอบสนองกับเส้นทางเช่น `/photos/1/with_user/2` ในกรณีนี้ `params` จะเป็น `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### สตริงคิวรีสต์

`params` ยังรวมถึงพารามิเตอร์จากสตริงคิวรีสต์ด้วย ตัวอย่างเช่น, ด้วยเส้นทางนี้:

```ruby
get 'photos/:id', to: 'photos#show'
```

เส้นทางเข้า `/photos/1?user_id=2` จะถูกส่งต่อไปยังการกระทำ `show` ของคอนโทรลเลอร์ `Photos` `params` จะเป็น `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### การกำหนดค่าเริ่มต้น

คุณสามารถกำหนดค่าเริ่มต้นในเส้นทางโดยให้แฮชสำหรับตัวเลือก `:defaults` นี้ใช้งานได้แม้ว่าจะไม่ได้ระบุพารามิเตอร์ที่เปลี่ยนได้แบบพลวัต ตัวอย่างเช่น:

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails จะจับคู่ `photos/12` กับการกระทำ `show` ของ `PhotosController` และตั้งค่า `params[:format]` เป็น `"jpg"`.

คุณยังสามารถใช้บล็อก [`defaults`][] เพื่อกำหนดค่าเริ่มต้นสำหรับรายการหลายรายการ:

```ruby
defaults format: :json do
  resources :photos
end
```

หมายเหตุ: คุณไม่สามารถเขียนทับค่าเริ่มต้นผ่านพารามิเตอร์คิวรี - นี้เป็นเรื่องความปลอดภัย ค่าเริ่มต้นที่สามารถเขียนทับได้คือส่วนที่เปลี่ยนได้แบบพลวัตผ่านการแทนที่ในเส้นทาง URL


### การตั้งชื่อเส้นทาง

คุณสามารถระบุชื่อสำหรับเส้นทางใดก็ได้โดยใช้ตัวเลือก `:as`:

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

นี้จะสร้าง `logout_path` และ `logout_url` เป็นช่วยเส้นทางที่มีชื่อในแอปพลิเคชันของคุณ การเรียกใช้ `logout_path` จะคืนค่า `/exit`

คุณยังสามารถใช้สิ่งนี้เพื่อเขียนทับเมธอดเส้นทางที่ถูกกำหนดโดยทรัพยากรโดยวางเส้นทางที่กำหนดเองก่อนที่ทรัพยากรจะถูกกำหนด, เช่น:

```ruby
get ':username', to: 'users#show', as: :user
resources :users
```

นี้จะกำหนดเมธอด `user_path` ที่จะใช้ได้ในคอนโทรลเลอร์ เครื่องช่วย และวิวที่จะไปยังเส้นทางเช่น `/bob` ภายในการกระทำ `show` ของ `UsersController` `params[:username]` จะมีชื่อผู้ใช้สำหรับผู้ใช้ แก้ไข `:username` ในการกำหนดเส้นทางหากคุณไม่ต้องการให้ชื่อพารามิเตอร์ของคุณเป็น `:username`.

### การกำหนดเงื่อนไข HTTP Verb

โดยทั่วไปคุณควรใช้ [`get`][], [`post`][], [`put`][], [`patch`][], และ [`delete`][] เมธอดเพื่อจำกัดเส้นทางไปยังกริยาที่เฉพาะเจาะจง คุณสามารถใช้เมธอด [`match`][] พร้อมกับตัวเลือก `:via` เพื่อจับคู่กริยาหลายอย่างในครั้งเดียว:

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

คุณสามารถจับคู่กริยาทั้งหมดกับเส้นทางเฉพาะได้โดยใช้ `via: :all`:

```ruby
match 'photos', to: 'photos#show', via: :all
```

หมายเหตุ: การกำหนดเส้นทางทั้ง `GET` และ `POST` ไปยังการกระทำเดียวกันมีผลกระทบต่อความปลอดภัย โดยทั่วไปคุณควรหลีกเลี่ยงการกำหนดเส้นทางทั้งหมดไปยังการกระทำเว้นแต่ว่าคุณจะมีเหตุผลที่ดี

หมายเหตุ: `GET` ใน Rails จะไม่ตรวจสอบ CSRF token คุณไม่ควรเขียนลงในฐานข้อมูลจากคำขอ `GET` สำหรับข้อมูลเพิ่มเติมดูที่[คู่มือด้านความปลอดภัย](security.html#csrf-countermeasures) เกี่ยวกับการป้องกัน CSRF


### เงื่อนไขส่วน

คุณสามารถใช้ตัวเลือก `:constraints` เพื่อบังคับรูปแบบสำหรับส่วนที่เปลี่ยนได้:

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

เส้นทางนี้จะจับคู่เส้นทางเช่น `/photos/A12345` แต่ไม่ใช่ `/photos/893` คุณสามารถแสดงออกมาอย่างสรุปได้ดังนี้:

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` รับสูตรประกอบด้วยข้อจำกัดว่าไม่สามารถใช้เครื่องหมายตรวจจับได้ ตัวอย่างเช่นเส้นทางต่อไปนี้จะไม่ทำงาน:
```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

อย่างไรก็ตาม โปรดทราบว่าคุณไม่จำเป็นต้องใช้ anchors เนื่องจากเส้นทางทั้งหมดถูกยึดติดที่จุดเริ่มต้นและจุดสิ้นสุด

ตัวอย่างเช่น เส้นทางต่อไปนี้จะอนุญาตให้ `articles` ที่มีค่า `to_param` เช่น `1-hello-world` ที่เริ่มต้นด้วยตัวเลขและ `users` ที่มีค่า `to_param` เช่น `david` ที่ไม่เริ่มต้นด้วยตัวเลขแบ่งปันเนมสเปซรูท:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### การจำกัดเงื่อนไขตามคำขอ

คุณยังสามารถจำกัดเส้นทางตามวิธีใดก็ได้บนวัตถุคำขอที่ส่งคืน `String` ใด ๆ จาก [วัตถุคำขอ](action_controller_overview.html#the-request-object)

คุณระบุเงื่อนไขตามคำขอได้ด้วยวิธีเดียวกับการระบุเงื่อนไขของเซกเมนต์:

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

คุณยังสามารถระบุเงื่อนไขโดยใช้บล็อก [`constraints`][]:

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

หมายเหตุ: เงื่อนไขของคำขอทำงานโดยเรียกเมธอดบน [วัตถุคำขอ](action_controller_overview.html#the-request-object) ด้วยชื่อเดียวกันกับคีย์แฮชแล้วเปรียบเทียบค่าที่ส่งคืนกับค่าแฮช ดังนั้นค่าเงื่อนไขควรตรงกับประเภทการส่งคืนเมธอดของวัตถุคำขอที่เกี่ยวข้อง ตัวอย่างเช่น: `constraints: { subdomain: 'api' }` จะตรงกับ subdomain `api` ตามที่คาดหวัง อย่างไรก็ตามการใช้สัญลักษณ์ `constraints: { subdomain: :api }` จะไม่ตรง เนื่องจาก `request.subdomain` ส่งคืน `'api'` เป็นสตริง

หมายเหตุ: มีข้อยกเว้นสำหรับเงื่อนไข `format`: แม้ว่าจะเป็นเมธอดบนวัตถุคำขอ แต่ก็เป็นพารามิเตอร์ที่ไม่บังคับใช้ในเส้นทางทุกเส้นทาง เงื่อนไขของเซกเมนต์จะมีความสำคัญกว่าและเงื่อนไข `format` จะถูกใช้เป็นเช่นนั้นเมื่อบังคับใช้ผ่านแฮช เช่น `get 'foo', constraints: { format: 'json' }` จะตรงกับ `GET  /foo` เนื่องจากรูปแบบเป็นทางเลือกตามค่าเริ่มต้น อย่างไรก็ตามคุณสามารถ [ใช้แลมบ์ดา](#advanced-constraints) เช่นใน `get 'foo', constraints: lambda { |req| req.format == :json }` และเส้นทางจะตรงกับคำขอ JSON ที่ระบุโดยชัดเจนเท่านั้น


### เงื่อนไขขั้นสูง

หากคุณมีเงื่อนไขที่ซับซ้อนมากขึ้นคุณสามารถให้วัตถุที่ตอบสนองกับ `matches?` ที่ Rails ควรใช้ สำหรับตัวอย่างเช่น หากคุณต้องการเส้นทางผู้ใช้ทั้งหมดในรายการที่ถูกจำกัดไว้กับ `RestrictedListController` คุณสามารถทำได้ดังนี้:

```ruby
class RestrictedListConstraint
  def initialize
    @ips = RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: RestrictedListConstraint.new
end
```

คุณยังสามารถระบุเงื่อนไขเป็นแบบแลมบ์ดาได้:

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

ทั้ง `matches?` และแลมบ์ดาจะได้รับวัตถุคำขอเป็นอาร์กิวเมนต์

#### เงื่อนไขในรูปแบบบล็อก

คุณสามารถระบุเงื่อนไขในรูปแบบบล็อกได้ ซึ่งเป็นวิธีที่ใช้ได้เมื่อคุณต้องใช้กฎเดียวกันกับเส้นทางหลายเส้นทาง ตัวอย่างเช่น:

```ruby
class RestrictedListConstraint
  # ...เหมือนตัวอย่างด้านบน
end

Rails.application.routes.draw do
  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

คุณยังสามารถใช้ `แลมบ์ดา` ได้:

```ruby
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

### การรวมเส้นทางและเซกเมนต์ที่เป็นสัญลักษณ์

การรวมเส้นทางเป็นวิธีที่ระบุว่าพารามิเตอร์ใด ๆ ควรจับคู่กับส่วนที่เหลือของเส้นทาง ตัวอย่างเช่น:

```ruby
get 'photos/*other', to: 'photos#unknown'
```

เส้นทางนี้จะตรงกับ `photos/12` หรือ `/photos/long/path/to/12` โดยกำหนด `params[:other]` เป็น `"12"` หรือ `"long/path/to/12"` เซกเมนต์ที่มีเครื่องหมายดอกจันนำหน้าเรียกว่า "เซกเมนต์สัญลักษณ์"

เซกเมนต์สัญลักษณ์สามารถเกิดขึ้นที่ใดก็ได้ในเส้นทาง ตัวอย่างเช่น:

```ruby
get 'books/*section/:title', to: 'books#show'
```

จะตรงกับ `books/some/section/last-words-a-memoir` โดยกำหนด `params[:section]` เท่ากับ `'some/section'` และ `params[:title]` เท่ากับ `'last-words-a-memoir'`

ทางเทคนิคแล้ว เส้นทางสามารถมีเซกเมนต์สัญลักษณ์ได้มากกว่าหนึ่งเซกเมนต์ ตัวตรวจจับจะกำหนดเซกเมนต์ให้กับพารามิเตอร์ในวิธีที่เข้าใจง่าย ตัวอย่างเช่น:
```ruby
get '*a/foo/*b', to: 'test#index'
```

จะตรงกับ `zoo/woo/foo/bar/baz` โดย `params[:a]` จะเท่ากับ `'zoo/woo'` และ `params[:b]` จะเท่ากับ `'bar/baz'` 

หมายเหตุ: โดยการร้องขอ `'/foo/bar.json'` ค่าของ `params[:pages]` จะเท่ากับ `'foo/bar'` โดยมีรูปแบบของการร้องขอเป็น JSON หากคุณต้องการให้มีพฤติกรรมเหมือนเวอร์ชัน 3.0.x เดิมคุณสามารถให้ `format: false` เช่นนี้:

```ruby
get '*pages', to: 'pages#show', format: false
```

หมายเหตุ: หากคุณต้องการให้เซ็กเมนต์รูปแบบเป็นบังคับ โดยไม่สามารถละเว้นได้ คุณสามารถให้ `format: true` เช่นนี้:

```ruby
get '*pages', to: 'pages#show', format: true
```

### การเปลี่ยนเส้นทาง

คุณสามารถเปลี่ยนเส้นทางใดๆ เป็นเส้นทางอื่นๆ โดยใช้ช่วยเหลือ [`redirect`][] ในเราเตอร์ของคุณ:

```ruby
get '/stories', to: redirect('/articles')
```

คุณยังสามารถใช้ส่วนที่ได้รับจากการตรงกันในเส้นทางเพื่อเปลี่ยนเส้นทางไปยัง:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

คุณยังสามารถให้บล็อกกับ `redirect` ซึ่งจะได้รับพารามิเตอร์เป็นสัญลักษณ์ของเส้นทางและออบเจ็กต์คำขอ:

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

โปรดทราบว่าการเปลี่ยนเส้นทางเริ่มต้นคือการเปลี่ยนเส้นทาง 301 "ย้ายไปถาวร" โปรดทราบว่าบางเบราว์เซอร์เว็บหรือเซิร์ฟเวอร์พร็อกซีอาจจะเก็บแคชการเปลี่ยนเส้นทางประเภทนี้ ทำให้หน้าเก่าไม่สามารถเข้าถึงได้ คุณสามารถใช้ตัวเลือก `:status` เพื่อเปลี่ยนสถานะการตอบสนอง:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

ในทุกกรณีเหล่านี้ หากคุณไม่ได้ให้โฮสต์หน้าหลัก (`http://www.example.com`) Rails จะเอารายละเอียดเหล่านั้นจากคำขอปัจจุบัน

### เส้นทางไปยังแอปพลิเคชันแบบ Rack

แทนที่จะใช้สตริงเช่น `'articles#index'` ซึ่งสอดคล้องกับการกระทำ `index` ใน `ArticlesController` คุณสามารถระบุแอปพลิเคชัน [Rack](rails_on_rack.html) ใดๆ เป็นจุดปลายทางสำหรับการตรงกัน:

```ruby
match '/application.js', to: MyRackApp, via: :all
```

เมื่อ `MyRackApp` ตอบสนอง `call` และส่งคืน `[status, headers, body]` เราเรียกใช้ `via: :all` เพื่อให้แอปพลิเคชัน Rack ของคุณรับมือกับเมธอดทุกตัวอย่างไรก็ตามที่คิดว่าเหมาะสม

หมายเหตุ: สำหรับผู้ที่อยากรู้สึกอยากรู้อย่างจริงจัง `'articles#index'` จริงๆ แล้วขยายออกเป็น `ArticlesController.action(:index)` ซึ่งส่งคืนแอปพลิเคชัน Rack ที่ถูกต้อง

หมายเหตุ: เนื่องจาก procs/lambdas เป็นอ็อบเจ็กต์ที่ตอบสนองกับ `call` คุณสามารถดำเนินการเรียกเส้นทางที่เรียบง่ายมาก (เช่นสำหรับการตรวจสุขภาพ) ในบรรทัดเดียว:<br>`get '/health', to: ->(env) { [204, {}, ['']] }`

หากคุณระบุแอปพลิเคชัน Rack เป็นจุดปลายทางสำหรับการตรงกัน โปรดจำไว้ว่าเส้นทางจะไม่เปลี่ยนในแอปพลิเคชันที่ได้รับ ด้วยเส้นทางต่อไปนี้แอปพลิเคชัน Rack ของคุณควรคาดหวังว่าเส้นทางจะเป็น `/admin`:

```ruby
match '/admin', to: AdminApp, via: :all
```

หากคุณต้องการให้แอปพลิเคชัน Rack ของคุณรับคำขอที่เส้นทางรากแทน ให้ใช้ [`mount`][]:

```ruby
mount AdminApp, at: '/admin'
```

### การใช้ `root`

คุณสามารถระบุว่า Rails ควรเส้นทาง `'/'` ไปยังอะไรด้วย [`root`][] เมธอด:

```ruby
root to: 'pages#main'
root 'pages#main' # ลัดวิธีสำหรับข้างต้น
```

คุณควรวางเส้นทาง `root` ที่ด้านบนของไฟล์ เพราะเป็นเส้นทางที่ได้รับความนิยมมากที่สุดและควรจับคู่ก่อน

หมายเหตุ: เส้นทาง `root` เฉพาะเส้นทาง `GET` เท่านั้นที่จะเส้นทางไปยังการกระทำ

คุณยังสามารถใช้ `root` ภายในเนมสเปซและสโคปได้เช่นกัน เช่น:

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```

### เส้นทางตัวอักษรยูนิโค้ด

คุณสามารถระบุเส้นทางตัวอักษรยูนิโค้ดโดยตรง ตัวอย่างเช่น:

```ruby
get 'こんにちは', to: 'welcome#index'
```

### เส้นทางตรง

คุณสามารถสร้างเครื่องมือ URL ที่กำหนดเองได้โดยตรงโดยเรียก [`direct`][] ตัวอย่างเช่น:

```ruby
direct :homepage do
  "https://rubyonrails.org"
end

# >> homepage_url
# => "https://rubyonrails.org"
```

ค่าที่ส่งคืนจากบล็อกต้องเป็นอาร์กิวเมนต์ที่ถูกต้องสำหรับเมธอด `url_for` ดังนั้นคุณสามารถส่งค่าสตริง URL, แฮช, อาร์เรย์, อินสแตนซ์ Active Model หรือคลาส Active Model ที่ถูกต้องได้
```ruby
resources :photos, path_names: { new: 'add', edit: 'modify' }
```

This will generate paths with `/photos/add` instead of `/photos/new` for the new action, and `/photos/modify` instead of `/photos/:id/edit` for the edit action.

| HTTP Verb | Path             | Controller#Action | Named Route Helper   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | photos#index      | photos_path          |
| GET       | /photos/add      | photos#new        | add_photo_path       |
| POST      | /photos          | photos#create     | photos_path          |
| GET       | /photos/:id      | photos#show       | photo_path(:id)      |
| GET       | /photos/:id/edit | photos#edit       | modify_photo_path(:id) |
| PATCH/PUT | /photos/:id      | photos#update     | photo_path(:id)      |
| DELETE    | /photos/:id      | photos#destroy    | photo_path(:id)      |

### Overriding the `show` Segment

The `:param` option lets you override the automatically-generated `show` segment in paths:

```ruby
resources :photos, param: :photo_id
```

This will generate paths with `/photos/:photo_id` instead of `/photos/:id`.

| HTTP Verb | Path             | Controller#Action | Named Route Helper   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | photos#index      | photos_path          |
| GET       | /photos/new      | photos#new        | new_photo_path       |
| POST      | /photos          | photos#create     | photos_path          |
| GET       | /photos/:photo_id      | photos#show       | photo_path(:photo_id)      |
| GET       | /photos/:photo_id/edit | photos#edit       | edit_photo_path(:photo_id) |
| PATCH/PUT | /photos/:photo_id      | photos#update     | photo_path(:photo_id)      |
| DELETE    | /photos/:photo_id      | photos#destroy    | photo_path(:photo_id)      |

### Limiting the Routes Created

The `:only` and `:except` options let you limit the routes created by `resources`.

```ruby
resources :photos, only: [:index, :show]
```

This will create only the `index` and `show` routes for the `PhotosController`.

```ruby
resources :photos, except: :destroy
```

This will create all the routes for the `PhotosController` except the `destroy` route.

### Adding More RESTful Actions

You can add additional RESTful actions to a resourceful route. For example:

```ruby
resources :photos do
  member do
    get 'preview'
  end

  collection do
    get 'search'
  end
end
```

This will recognize `/photos/1/preview` with `GET`, and `/photos/search` with `GET`, respectively, and route to the `preview` and `search` actions of the `PhotosController`.

| HTTP Verb | Path             | Controller#Action | Named Route Helper   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | photos#index      | photos_path          |
| GET       | /photos/new      | photos#new        | new_photo_path       |
| POST      | /photos          | photos#create     | photos_path          |
| GET       | /photos/:id      | photos#show       | photo_path(:id)      |
| GET       | /photos/:id/edit | photos#edit       | edit_photo_path(:id) |
| PATCH/PUT | /photos/:id      | photos#update     | photo_path(:id)      |
| DELETE    | /photos/:id      | photos#destroy    | photo_path(:id)      |
| GET       | /photos/:id/preview | photos#preview   | preview_photo_path(:id) |
| GET       | /photos/search  | photos#search     | search_photos_path   |

### Naming Routes

You can specify a custom name for any route using the `:as` option:

```ruby
resources :photos, as: 'images'
```

This will rename all routes from `photos` to `images`. The routing helpers `photos_path`, `new_photo_path`, etc. become `images_path`, `new_image_path`, and so on.

### Overriding the Singular Form

By default, `resources` creates pluralized routes. If you want to create singular routes, you can use the `:singular` option:

```ruby
resource :geocoder
```

This will create the following routes:

| HTTP Verb | Path             | Controller#Action | Named Route Helper   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /geocoder        | geocoders#show    | geocoder_path        |
| GET       | /geocoder/new    | geocoders#new     | new_geocoder_path    |
| POST      | /geocoder        | geocoders#create  | geocoder_path        |
| GET       | /geocoder/edit   | geocoders#edit    | edit_geocoder_path   |
| PATCH/PUT | /geocoder        | geocoders#update  | geocoder_path        |
| DELETE    | /geocoder        | geocoders#destroy | geocoder_path        |

### Singular Resources

Sometimes, you have a resource that clients always look up without referencing an ID. For example, you would like `/profile` to always show the profile of the currently logged in user. In this case, you can use a singular resource to map `/profile` (rather than `/profile/:id`) to the show action.

```ruby
resource :profile
```

This resourceful route:

```ruby
resource :geocoder
```

creates six different routes in your application, all mapping to the `Geocoders` controller:

| HTTP Verb | Path             | Controller#Action | Named Route Helper   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /geocoder        | geocoders#show    | geocoder_path        |
| GET       | /geocoder/new    | geocoders#new     | new_geocoder_path    |
| POST      | /geocoder        | geocoders#create  | geocoder_path        |
| GET       | /geocoder/edit   | geocoders#edit    | edit_geocoder_path   |
| PATCH/PUT | /geocoder        | geocoders#update  | geocoder_path        |
| DELETE    | /geocoder        | geocoders#destroy | geocoder_path        |

### Namespaces

You can organize groups of controllers under a namespace. For example, you might group all admin-related controllers under an `admin` directory. To do this, you would place the controllers in the `app/controllers/admin` directory and define a route like this:

```ruby
namespace :admin do
  resources :photos, :accounts
end
```

This will create a number of routes for each of the `photos` and `accounts` resources. The routes will all be prefixed with `/admin`, and will look like `/admin/photos`, `/admin/photos/new`, and so on. Additionally, it will create named route helpers such as `admin_photos_path` and `new_admin_photo_path`.

You can nest namespaces as deeply as you like. For example:

```ruby
namespace :admin do
  namespace :management do
    resources :photos
  end
end
```

This will create routes such as `/admin/management/photos` and named route helpers such as `admin_management_photos_path`.

### Routing Concerns

You can specify common routes that can be reused across multiple resources using the `concern` method. For example:

```ruby
concern :commentable do |options|
  resources :comments, options
end

resources :messages, concerns: :commentable
resources :articles, concerns: :commentable
```

This will create the same routes for both `messages` and `articles` resources, including the nested `comments` routes.

### Scoping

You can use the `scope` method to specify common routing options for a group of routes. For example:

```ruby
scope module: 'admin' do
  resources :photos
end
```

This will route all requests for the `photos` resource to the `Admin::PhotosController`.

You can also use the `scope` method to specify a path prefix for a group of routes. For example:

```ruby
scope '/admin' do
  resources :photos
end
```

This will route all requests for the `photos` resource to the `PhotosController`, but prefix the URL with `/admin`.

### Routing to Rack Applications

You can route to Rack applications in your `config/routes.rb` file. For example:

```ruby
mount MyRackApp, at: '/my_rack_app'
```

This will route all requests for `/my_rack_app` to the `MyRackApp` Rack application.

### Routing to a Redirect

You can route to a redirect in your `config/routes.rb` file. For example:

```ruby
get '/stories', to: redirect('/articles')
```

This will redirect all requests for `/stories` to `/articles`.

### Routing to a Subdomain

You can route to a subdomain in your `config/routes.rb` file. For example:

```ruby
constraints subdomain: 'api' do
  namespace :api, path: '/' do
    resources :photos
  end
end
```

This will route all requests for the `photos` resource to the `Api::PhotosController`, but only if the subdomain is `api`. The URL will be prefixed with `/api`.

### Routing to a Namespace

You can route to a namespace in your `config/routes.rb` file. For example:

```ruby
namespace :admin do
  resources :photos
end
```

This will route all requests for the `photos` resource to the `Admin::PhotosController`. The URL will be prefixed with `/admin`.

### Routing to a Controller

You can route directly to a controller in your `config/routes.rb` file. For example:

```ruby
get '/photos', to: 'photos#index'
```

This will route all requests for `/photos` to the `PhotosController` and the `index` action.

### Routing to a Static File

You can route to a static file in your `config/routes.rb` file. For example:

```ruby
get '/about', to: redirect('/about.html')
```

This will route all requests for `/about` to the `about.html` file.

### Routing to a Ruby Block

You can route to a Ruby block in your `config/routes.rb` file. For example:

```ruby
get '/hello', to: proc { |env| [200, {}, ['Hello, World!']] }
```

This will route all requests for `/hello` to the specified Ruby block, which returns a response with the body `Hello, World!`.

### Routing to a Dynamic Segment

You can route to a dynamic segment in your `config/routes.rb` file. For example:

```ruby
get '/photos/:id', to: 'photos#show'
```

This will route all requests for `/photos/:id` to the `PhotosController` and the `show` action. The value of the `:id` segment will be passed as a parameter to the action.

### Routing to a Dynamic Segment with Constraints

You can route to a dynamic segment with constraints in your `config/routes.rb` file. For example:

```ruby
get '/photos/:id', to: 'photos#show', constraints: { id: /\d+/ }
```

This will route all requests for `/photos/:id` to the `PhotosController` and the `show` action, but only if the `:id` segment matches the specified regular expression.

### Routing to a Dynamic Segment with Defaults

You can route to a dynamic segment with defaults in your `config/routes.rb` file. For example:

```ruby
get '/photos/:id', to: 'photos#show', defaults: { id: '1' }
```

This will route all requests for `/photos/:id` to the `PhotosController` and the `show` action, and set the default value of the `:id` segment to `'1'`.

### Routing to a Dynamic Segment with Constraints and Defaults

You can route to a dynamic segment with constraints and defaults in your `config/routes.rb` file. For example:

```ruby
get '/photos/:id', to: 'photos#show', constraints: { id: /\d+/ }, defaults: { id: '1' }
```

This will route all requests for `/photos/:id` to the `PhotosController` and the `show` action, but only if the `:id` segment matches the specified regular expression. If no value is provided for the `:id` segment, it will default to `'1'`.

### Routing to a Dynamic Segment with a Custom Parameter Name

You can route to a dynamic segment with a custom parameter name in your `config/routes.rb` file. For example:

```ruby
get '/photos/:photo_id', to: 'photos#show', as: 'photo'
```

This will route all requests for `/photos/:photo_id` to the `PhotosController` and the `show` action. The value of the `:photo_id` segment will be passed as a parameter to the action, and the named route helper will be `photo_path`.

### Routing to a Dynamic Segment with a Custom Parameter Name and Constraints

You can route to a dynamic segment with a custom parameter name and constraints in your `config/routes.rb` file. For example:

```ruby
get '/photos/:photo_id', to: 'photos#show', as: 'photo', constraints: { photo_id: /\d+/ }
```

This will route all requests for `/photos/:photo_id` to the `PhotosController` and the `show` action, but only if the `:photo_id` segment matches the specified regular expression. The value of the `:photo_id` segment will be passed as a parameter to the action, and the named route helper will be `photo_path`.

### Routing to
```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

นี้จะทำให้เส้นทางรับรู้เส้นทางเช่น:

```
/photos/make
/photos/1/change
```

หมายเหตุ: ชื่อแอ็กชันจริงๆ ไม่เปลี่ยนเมื่อใช้ตัวเลือกนี้ สองเส้นทางที่แสดงจะยังคงเส้นทางไปยังแอ็กชัน `new` และ `edit`

เคล็ดลับ: หากคุณพบว่าต้องการเปลี่ยนตัวเลือกนี้ให้เหมือนกันสำหรับเส้นทางทั้งหมดคุณสามารถใช้ scope ได้เช่นด้านล่าง:

```ruby
scope path_names: { new: 'make' } do
  # เส้นทางที่เหลือ
end
```

### เติมคำนำหน้าให้กับ Named Route Helpers

คุณสามารถใช้ตัวเลือก `:as` เพื่อเติมคำนำหน้าให้กับ named route helpers ที่ Rails สร้างขึ้นสำหรับเส้นทาง ใช้ตัวเลือกนี้เพื่อป้องกันการชนชื่อระหว่างเส้นทางที่ใช้ path scope เช่น:

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

นี้เปลี่ยน named route helpers สำหรับ `/admin/photos` จาก `photos_path`, `new_photos_path`, เป็น `admin_photos_path`, `new_admin_photo_path` เป็นต้น โดยไม่มีการเพิ่ม `as: 'admin_photos` ใน scoped `resources :photos` จะไม่มี named route helpers สำหรับ non-scoped `resources :photos`

เพื่อเติมคำนำหน้าให้กับกลุ่มของ named route helpers ใช้ `:as` กับ `scope`:

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

เช่นเดียวกับเดิม นี้เปลี่ยน `/admin` scoped resource helpers เป็น `admin_photos_path` และ `admin_accounts_path` และอนุญาตให้ non-scoped resources ใช้ `photos_path` และ `accounts_path`

หมายเหตุ: `namespace` scope จะเพิ่ม `:as` รวมถึง `:module` และ `:path` prefixes โดยอัตโนมัติ

#### Parametric Scopes

คุณสามารถเติมคำนำหน้าเส้นทางด้วยพารามิเตอร์ที่มีชื่อ:

```ruby
scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
  resources :articles
end
```

นี้จะให้คุณเส้นทางเช่น `/1/articles/9` และจะอนุญาตให้คุณอ้างอิงส่วนของเส้นทางที่เป็น `account_id` เป็น `params[:account_id]` ในคอนโทรลเลอร์ เฮลเปอร์ และวิว

นี้ยังสร้าง path และ URL helpers ที่เติมคำนำหน้าด้วย `account_` ซึ่งคุณสามารถส่งออบเจ็กต์ของคุณได้เหมือนที่คาดหวัง:

```ruby
account_article_path(@account, @article) # => /1/article/9
url_for([@account, @article])            # => /1/article/9
form_with(model: [@account, @article])   # => <form action="/1/article/9" ...>
```

เรากำลัง [ใช้เงื่อนไข](#segment-constraints) เพื่อจำกัดขอบเขตของเส้นทางเพียงแค่ตรงกับสตริงที่คล้ายกับ ID คุณสามารถเปลี่ยนเงื่อนไขเพื่อตรงกับความต้องการของคุณหรือละเว้นได้ ตัวเลือก `:as` ไม่จำเป็นอย่างเคร่งครัด แต่หากไม่มีจะทำให้ Rails เกิดข้อผิดพลาดเมื่อประเมิน `url_for([@account, @article])` หรือเฮลเปอร์อื่น ๆ ที่ขึ้นอยู่กับ `url_for` เช่น [`form_with`][]


### จำกัดเส้นทางที่สร้างขึ้น

โดยค่าเริ่มต้น Rails จะสร้างเส้นทางสำหรับแอ็กชันเริ่มต้นเจ็ดตัว (`index`, `show`, `new`, `create`, `edit`, `update`, และ `destroy`) สำหรับเส้นทาง RESTful ทุกเส้นทางในแอปพลิเคชันของคุณ คุณสามารถใช้ตัวเลือก `:only` และ `:except` เพื่อปรับแต่งพฤติกรรมนี้ได้อย่างละเอียด ตัวเลือก `:only` บอกให้ Rails สร้างเฉพาะเส้นทางที่ระบุ:

```ruby
resources :photos, only: [:index, :show]
```

ตอนนี้ คำขอ `GET` ไปที่ `/photos` จะสำเร็จ แต่คำขอ `POST` ไปที่ `/photos` (ซึ่งเรียกใช้แอ็กชัน `create` ตามปกติ) จะล้มเหลว

ตัวเลือก `:except` ระบุเส้นทางหรือรายการเส้นทางที่ Rails ไม่ควรสร้าง:

```ruby
resources :photos, except: :destroy
```

ในกรณีนี้ Rails จะสร้างเส้นทางปกติทั้งหมดยกเว้นเส้นทางสำหรับ `destroy` (คำขอ `DELETE` ไปที่ `/photos/:id`)

เคล็ดลับ: หากแอปพลิเคชันของคุณมีเส้นทาง RESTful จำนวนมาก การใช้ `:only` และ `:except` เพื่อสร้างเฉพาะเส้นทางที่จำเป็นจริงๆ สามารถลดการใช้หน่วยความจำและเร่งกระบวนการเส้นทางได้

### เส้นทางที่แปลเป็นภาษาอื่น

โดยใช้ `scope` เราสามารถเปลี่ยนชื่อเส้นทางที่สร้างขึ้นโดย `resources`:

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

Rails ตอนนี้สร้างเส้นทางไปยัง `CategoriesController`.

| HTTP Verb | Path                       | Controller#Action  | Named Route Helper      |
| --------- | -------------------------- | ------------------ | ----------------------- |
| GET       | /kategorien                | categories#index   | categories_path         |
| GET       | /kategorien/neu            | categories#new     | new_category_path       |
| POST      | /kategorien                | categories#create  | categories_path         |
| GET       | /kategorien/:id            | categories#show    | category_path(:id)      |
| GET       | /kategorien/:id/bearbeiten | categories#edit    | edit_category_path(:id) |
| PATCH/PUT | /kategorien/:id            | categories#update  | category_path(:id)      |
| DELETE    | /kategorien/:id            | categories#destroy | category_path(:id)      |
### การเขียนทับรูปแบบเป็นเอกพจน์

หากคุณต้องการเขียนทับรูปแบบเป็นเอกพจน์ของทรัพยากร คุณควรเพิ่มกฎเพิ่มเติมใน inflector ผ่าน [`inflections`][]:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```


### การใช้ `:as` ในทรัพยากรที่ซ้อนกัน

ตัวเลือก `:as` จะทับชื่อทรัพยากรที่สร้างขึ้นโดยอัตโนมัติในตัวช่วยเส้นทางที่ซ้อนกัน ตัวอย่างเช่น:

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

นี้จะสร้างตัวช่วยเส้นทางเช่น `magazine_periodical_ads_url` และ `edit_magazine_periodical_ad_path`


### การเขียนทับพารามิเตอร์ของเส้นทางที่ตั้งชื่อแล้ว

ตัวเลือก `:param` จะทับรหัสแห่งทรัพยากรเริ่มต้น `:id` (ชื่อของ [ส่วนเคลื่อนที่แบบไดนามิก](routing.html#dynamic-segments) ที่ใช้สร้างเส้นทาง) คุณสามารถเข้าถึงส่วนนั้นจากคอนโทรลเลอร์ของคุณโดยใช้ `params[<:param>]`.

```ruby
resources :videos, param: :identifier
```

```
    videos GET  /videos(.:format)                  videos#index
           POST /videos(.:format)                  videos#create
 new_video GET  /videos/new(.:format)              videos#new
edit_video GET  /videos/:identifier/edit(.:format) videos#edit
```

```ruby
Video.find_by(identifier: params[:identifier])
```

คุณสามารถเขียนทับ `ActiveRecord::Base#to_param` ของโมเดลที่เกี่ยวข้องเพื่อสร้าง URL:

```ruby
class Video < ApplicationRecord
  def to_param
    identifier
  end
end
```

```ruby
video = Video.find_by(identifier: "Roman-Holiday")
edit_video_path(video) # => "/videos/Roman-Holiday/edit"
```

การแบ่งไฟล์เส้นทางที่ใหญ่มากเป็นหลายไฟล์เล็กๆ
-------------------------------------------------------

หากคุณทำงานในแอปพลิเคชันที่ใหญ่มีเส้นทางหลายพันเส้นทาง ไฟล์เดียวของ `config/routes.rb` อาจกลายเป็นสิ่งที่ยุ่งยากและยากต่อการอ่าน

Rails มีวิธีการแบ่งไฟล์เส้นทางที่ใหญ่มากเป็นหลายไฟล์เล็กๆ โดยใช้แมโค [`draw`][]

คุณสามารถมีไฟล์เส้นทาง `admin.rb` ที่มีเส้นทางทั้งหมดสำหรับพื้นที่แอดมิน ไฟล์อื่นๆ เช่น `api.rb` สำหรับทรัพยากรที่เกี่ยวข้องกับ API เป็นต้น

```ruby
# config/routes.rb

Rails.application.routes.draw do
  get 'foo', to: 'foo#bar'

  draw(:admin) # จะโหลดไฟล์เส้นทางอื่นที่อยู่ใน `config/routes/admin.rb`
end
```

```ruby
# config/routes/admin.rb

namespace :admin do
  resources :comments
end
```

การเรียกใช้ `draw(:admin)` ภายในบล็อก `Rails.application.routes.draw` จะพยายามโหลดไฟล์เส้นทางที่มีชื่อเดียวกับอาร์กิวเมนต์ที่กำหนด (`admin.rb` ในตัวอย่างนี้) ไฟล์จะต้องอยู่ภายในไดเรกทอรี `config/routes` หรือในไดเรกทอรีย่อย (เช่น `config/routes/admin.rb` หรือ `config/routes/external/admin.rb`).

คุณสามารถใช้ DSL เส้นทางปกติภายในไฟล์เส้นทาง `admin.rb` ได้ แต่คุณ **ไม่ควร** ใส่บล็อก `Rails.application.routes.draw` เหมือนที่คุณทำในไฟล์เส้นทางหลัก `config/routes.rb`


### อย่าใช้คุณสมบัตินี้ นอกจากว่าคุณจะต้องการจริงๆ

การมีไฟล์เส้นทางหลายไฟล์ทำให้ค้นหาและเข้าใจยากขึ้น สำหรับแอปพลิเคชันส่วนใหญ่ - แม้แต่ในกรณีที่มีเส้นทางหลายร้อยเส้นทาง - มันง่ายกว่าสำหรับนักพัฒนาที่มีไฟล์เส้นทางเดียว  DSL เส้นทางของ Rails มีวิธีการแบ่งเส้นทางในลักษณะที่เรียบร้อยด้วย `namespace` และ `scope`


การตรวจสอบและทดสอบเส้นทาง
-----------------------------

Rails มีเครื่องมือสำหรับตรวจสอบและทดสอบเส้นทางของคุณ

### การรายการเส้นทางที่มีอยู่

เพื่อรับรายการเส้นทางที่มีอยู่ในแอปพลิเคชันของคุณ ให้เข้าไปที่ <http://localhost:3000/rails/info/routes> ในเบราว์เซอร์ของคุณในขณะที่เซิร์ฟเวอร์ของคุณกำลังทำงานในสภาพแวดล้อม **development** คุณยังสามารถใช้คำสั่ง `bin/rails routes` ในเทอร์มินัลของคุณเพื่อสร้างผลลัพธ์เดียวกัน

ทั้งสองวิธีนี้จะแสดงรายการเส้นทางทั้งหมดในลำดับเดียวกันกับที่พวกเขาปรากฏใน `config/routes.rb` สำหรับแต่ละเส้นทาง คุณจะเห็น:

* ชื่อเส้นทาง (ถ้ามี)
* HTTP verb ที่ใช้ (หากเส้นทางไม่ตอบสนองต่อ verb ทั้งหมด)
* รูปแบบ URL ที่ตรงกัน
* พารามิเตอร์ของเส้นทาง

ตัวอย่างเช่น นี่คือส่วนเล็กของผลลัพธ์ `bin/rails routes` สำหรับเส้นทาง RESTful:

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

คุณยังสามารถใช้ตัวเลือก `--expanded` เพื่อเปิดใช้โหมดการจัดรูปแบบตารางที่ขยายออก

```bash
$ bin/rails routes --expanded

--[ Route 1 ]----------------------------------------------------
Prefix            | users
Verb              | GET
URI               | /users(.:format)
Controller#Action | users#index
--[ Route 2 ]----------------------------------------------------
Prefix            |
Verb              | POST
URI               | /users(.:format)
Controller#Action | users#create
--[ Route 3 ]----------------------------------------------------
Prefix            | new_user
Verb              | GET
URI               | /users/new(.:format)
Controller#Action | users#new
--[ Route 4 ]----------------------------------------------------
Prefix            | edit_user
Verb              | GET
URI               | /users/:id/edit(.:format)
Controller#Action | users#edit
```
คุณสามารถค้นหาเส้นทางของคุณด้วยตัวเลือก grep: -g ซึ่งจะแสดงผลเส้นทางที่ตรงกับชื่อ URL helper method, HTTP verb หรือ URL path บางส่วน

```bash
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

หากคุณต้องการเห็นเฉพาะเส้นทางที่เชื่อมโยงกับคอนโทรลเลอร์ที่ระบุเท่านั้น ให้ใช้ตัวเลือก -c

```bash
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

เคล็ดลับ: คุณจะพบว่าผลลัพธ์จาก `bin/rails routes` อ่านง่ายมากขึ้นหากคุณขยายหน้าต่าง terminal ของคุณจนเส้นทางผลลัพธ์ไม่แบ่งแยก

### การทดสอบเส้นทาง

เส้นทางควรถูกนำเข้าไว้ในกลยุทธ์การทดสอบของคุณ (เหมือนกับส่วนอื่น ๆ ของแอปพลิเคชันของคุณ) Rails มีการตรวจสอบสามข้อความที่มีอยู่แล้วที่ออกแบบมาเพื่อทำให้การทดสอบเส้นทางง่ายขึ้น:

* [`assert_generates`][]
* [`assert_recognizes`][]
* [`assert_routing`][]


#### การตรวจสอบด้วย `assert_generates`

[`assert_generates`][] ตรวจสอบว่าชุดตัวเลือกใด ๆ สร้างเส้นทางที่ระบุได้และสามารถใช้กับเส้นทางเริ่มต้นหรือเส้นทางที่กำหนดเอง เช่น:

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### การตรวจสอบด้วย `assert_recognizes`

[`assert_recognizes`][] เป็นการตรวจสอบที่เป็นตรงข้ามกับ `assert_generates` มันตรวจสอบว่าเส้นทางที่กำหนดใด ๆ ถูกรับรู้และเส้นทางไปยังส่วนที่กำหนดในแอปพลิเคชันของคุณ เช่น:

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

คุณสามารถให้ `:method` ในการระบุ HTTP verb:

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### การตรวจสอบด้วย `assert_routing`

การตรวจสอบ [`assert_routing`][] ตรวจสอบเส้นทางทั้งสองทาง: มันทดสอบว่าเส้นทางสร้างตัวเลือกและเส้นทางสร้างเส้นทาง เช่น:

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```
[`resources`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
[`namespace`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-namespace
[`scope`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-scope
[`shallow`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-shallow
[`concern`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concern
[`concerns`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concerns
[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`delete`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-delete
[`get`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-get
[`member`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-member
[`patch`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-patch
[`post`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-post
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`collection`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-collection
[`defaults`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-defaults
[`match`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-match
[`constraints`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints
[`redirect`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Redirection.html#method-i-redirect
[`mount`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-mount
[`root`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-root
[`direct`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-direct
[`resolve`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve
[`form_with`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[`inflections`]: https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-inflections
[`draw`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-draw
[`assert_generates`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates
[`assert_recognizes`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes
[`assert_routing`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_routing
