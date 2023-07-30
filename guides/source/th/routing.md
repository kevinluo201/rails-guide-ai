**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fb66c6f4aafffdb8f8d44e8a2076c9b0
การเชื่อมต่อ URL กับโค้ด
===================

เมื่อแอปพลิเคชัน Rails ขอรับคำขอเข้าสู่ระบบสำหรับ:

```
GET /patients/17
```

มันจะขอให้เราตรวจสอบว่ามันตรงกับการกระทำของคอนโทรลเลอร์หรือไม่ ถ้าเส้นทางที่ตรงกันคือ:

```ruby
get '/patients/:id', to: 'patients#show'
```

คำขอจะถูกส่งต่อไปยังการกระทำ `show` ของคอนโทรลเลอร์ `patients` พร้อมกับ `{ id: '17' }` ใน `params`.

หมายเหตุ: Rails ใช้ snake_case สำหรับชื่อคอนโทรลเลอร์ที่นี่ หากคุณมีคอนโทรลเลอร์ที่มีหลายคำ เช่น `MonsterTrucksController` คุณต้องใช้ `monster_trucks#show` เป็นตัวอย่าง

การสร้างเส้นทางและ URL จากโค้ด

คุณยังสามารถสร้างเส้นทางและ URL ได้ หากเส้นทางด้านบนถูกแก้ไขให้เป็น:

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

และแอปพลิเคชันของคุณมีโค้ดนี้ในคอนโทรลเลอร์:

```ruby
@patient = Patient.find(params[:id])
```

และโค้ดนี้ในมุมมองที่เกี่ยวข้อง:

```erb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

แล้วเราจะสร้างเส้นทาง `/patients/17` นี้จะลดความเปราะบางของมุมมองและทำให้โค้ดของคุณง่ายต่อการเข้าใจ โปรดทราบว่าไม่จำเป็นต้องระบุ id ในตัวช่วยเส้นทาง

การกำหนดค่าเราเตอร์ของ Rails

เส้นทางสำหรับแอปพลิเคชันหรือเอ็นจิ้นของคุณอยู่ในไฟล์ `config/routes.rb` และมักจะมีลักษณะดังนี้:

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

เนื่องจากนี่เป็นไฟล์ต้นฉบับของ Ruby ปกติคุณสามารถใช้คุณลักษณะทั้งหมดของมันเพื่อช่วยให้คุณกำหนดเส้นทางของคุณ แต่ต้องระมัดระวังเรื่องชื่อตัวแปรเนื่องจากมันอาจชนกับเมธอด DSL ของเราเตอร์

หมายเหตุ: บล็อก `Rails.application.routes.draw do ... end` ที่ครอบคลุมการกำหนดเส้นทางของคุณจำเป็นต้องกำหนดขอบเขตสำหรับ DSL เราเตอร์และต้องไม่ถูกลบ

การกำหนดเส้นทางของทรัพยากร: ค่าเริ่มต้นของ Rails

การกำหนดเส้นทางของทรัพยากรช่วยให้คุณสามารถประกาศเส้นทางทั้งหมดที่เกี่ยวข้องสำหรับคอนโทรลเลอร์ที่ให้ทรัพยากรได้อย่างรวดเร็ว การเรียกใช้เดียวกับ [`resources`][] สามารถประกาศเส้นทางที่จำเป็นทั้งหมดสำหรับการกระทำ `index`, `show`, `new`, `edit`, `create`, `update`, และ `destroy` ของคุณ

ทรัพยากรบนเว็บ

เบราว์เซอร์ขอหน้าจาก Rails โดยการขอร้องขอ URL โดยใช้ HTTP method ที่เฉพาะเจาะจง เช่น `GET`, `POST`, `PATCH`, `PUT`, และ `DELETE` แต่ละวิธีเป็นคำขอในการดำเนินการกับทรัพยากร เส้นทางทรัพยากรแมปหลายคำขอที่เกี่ยวข้องกับการกระทำในคอนโทรลเลอร์เดียว
เมื่อแอปพลิเคชัน Rails ของคุณได้รับคำขอเข้ารหัสเข้ามาดังนี้:

```
DELETE /photos/17
```

มันจะขอให้เราทำการแมปคำขอนั้นไปยังการกระทำของคอนโทรลเลอร์ หากเส้นทางที่ตรงกันคือ:

```ruby
resources :photos
```

Rails จะส่งคำขอนั้นไปยังการกระทำ `destroy` ในคอนโทรลเลอร์ `photos` พร้อมกับ `{ id: '17' }` ใน `params`.

### CRUD, Verbs, และ Actions

ใน Rails เส้นทางที่ให้ทรัพยากรจะให้การแมประหว่าง HTTP verbs และ URLs ไปยังการกระทำของคอนโทรลเลอร์ ตามปกติแล้ว แต่ละการกระทำยังแมปไปยังการดำเนินการ CRUD ที่เฉพาะเจาะจงในฐานข้อมูลด้วย การกำหนดเส้นทางเดียวในไฟล์เส้นทาง เช่น:

```ruby
resources :photos
```

จะสร้างเส้นทางทั้งหมด 7 เส้นทางที่แตกต่างกันในแอปพลิเคชันของคุณ ทั้งหมดแมปไปยังคอนโทรลเลอร์ `Photos`:

| HTTP Verb | Path             | Controller#Action | ใช้สำหรับ                                     |
| --------- | ---------------- | ----------------- | -------------------------------------------- |
| GET       | /photos          | photos#index      | แสดงรายการภาพทั้งหมด                 |
| GET       | /photos/new      | photos#new        | แสดงฟอร์ม HTML สำหรับสร้างภาพใหม่ |
| POST      | /photos          | photos#create     | สร้างภาพใหม่                           |
| GET       | /photos/:id      | photos#show       | แสดงภาพที่เฉพาะเจาะจง                     |
| GET       | /photos/:id/edit | photos#edit       | แสดงฟอร์ม HTML สำหรับแก้ไขภาพ      |
| PATCH/PUT | /photos/:id      | photos#update     | อัปเดตภาพที่เฉพาะเจาะจง                      |
| DELETE    | /photos/:id      | photos#destroy    | ลบภาพที่เฉพาะเจาะจง                      |

หมายเหตุ: เนื่องจากเส้นทางใช้ HTTP verb และ URL เพื่อจับคู่คำขอที่เข้ามา 4 URLs จะแมปไปยังการกระทำทั้งหมด 7 การกระทำ

หมายเหตุ: เส้นทางของ Rails จะถูกจับคู่ตามลำดับที่ระบุ ดังนั้นหากคุณมี `resources :photos` อยู่ด้านบนของ `get 'photos/poll'` การกระทำ `show` ของเส้นทางในบรรทัด `resources` จะถูกจับคู่ก่อนบรรทัด `get` เพื่อแก้ไขปัญหานี้ให้ย้ายบรรทัด `get` **ขึ้นไปด้านบน** ของบรรทัด `resources` เพื่อให้มันถูกจับคู่ก่อน

### Path และ URL Helpers

การสร้างเส้นทางที่ให้ทรัพยากรยังจะเปิดเผยเฮลเปอร์หลายรายการให้กับคอนโทรลเลอร์ในแอปพลิเคชันของคุณ ในกรณีของ `resources :photos`:

* `photos_path` จะคืนค่า `/photos`
* `new_photo_path` จะคืนค่า `/photos/new`
* `edit_photo_path(:id)` จะคืนค่า `/photos/:id/edit` (ตัวอย่างเช่น `edit_photo_path(10)` จะคืนค่า `/photos/10/edit`)
* `photo_path(:id)` จะคืนค่า `/photos/:id` (ตัวอย่างเช่น `photo_path(10)` จะคืนค่า `/photos/10`)

แต่ละเฮลเปอร์นี้จะมีเฮลเปอร์ `_url` ที่สอดคล้อง (เช่น `photos_url`) ซึ่งจะคืนค่าเส้นทางเดียวกันที่เติมคำนำหน้าด้วยโฮสต์ปัจจุบัน เลขพอร์ต และคำนำหน้าเส้นทาง

เคล็ดลับ: หากต้องการหาชื่อเฮลเปอร์ของเส้นทางของคุณ ดูที่ [การแสดงเส้นทางที่มีอยู่](#listing-existing-routes) ด้านล่าง

### การกำหนดทรัพยากรหลายรายการในเวลาเดียวกัน

หากคุณต้องการสร้างเส้นทางสำหรับทรัพยากรมากกว่าหนึ่งรายการ คุณสามารถประหยัดการพิมพ์ได้โดยกำหนดทั้งหมดในการเรียกใช้เดียวกัน `resources`:

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

บางครั้งคุณมีทรัพยากรที่ไคลเอ็นต์ต้องการค้นหาเสมอโดยไม่ต้องอ้างอิงไปยัง ID ตัวอย่างเช่น คุณต้องการ `/profile` เพื่อแสดงโปรไฟล์ของผู้ใช้ที่เข้าสู่ระบบอยู่ในขณะนั้น ในกรณีนี้คุณสามารถใช้ทรัพยากรเดี่ยวเพื่อแมป `/profile` (ไม่ใช่ `/profile/:id`) ไปยังการกระทำ `show`:
```ruby
get 'profile', to: 'users#show'
```

การส่ง `String` ไปยัง `to:` จะคาดหวังรูปแบบ `controller#action` ในกรณีที่ใช้ `Symbol` ตัวเลือก `to:` ควรถูกแทนที่ด้วย `action:` ในกรณีที่ใช้ `String` โดยไม่มี `#` ตัวเลือก `to:` ควรถูกแทนที่ด้วย `controller:`:

```ruby
get 'profile', action: :show, controller: 'users'
```

เส้นทางทรัพยากรนี้:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

สร้างเส้นทางทั้งหกในแอปพลิเคชันของคุณ ที่จะแมปไปยังคอนโทรลเลอร์ `Geocoders`:

| HTTP Verb | เส้นทาง          | คอนโทรลเลอร์#แอคชัน | ใช้สำหรับ                                      |
| --------- | -------------- | ----------------- | --------------------------------------------- |
| GET       | /geocoder/new  | geocoders#new     | ส่งคืนแบบฟอร์ม HTML สำหรับการสร้าง geocoder |
| POST      | /geocoder      | geocoders#create  | สร้าง geocoder ใหม่                       |
| GET       | /geocoder      | geocoders#show    | แสดงแหล่งทรัพยากร geocoder เดียวเท่านั้น    |
| GET       | /geocoder/edit | geocoders#edit    | ส่งคืนแบบฟอร์ม HTML สำหรับแก้ไข geocoder  |
| PATCH/PUT | /geocoder      | geocoders#update  | อัปเดตแหล่งทรัพยากร geocoder เดียวเท่านั้น     |
| DELETE    | /geocoder      | geocoders#destroy | ลบแหล่งทรัพยากร geocoder                  |

หมายเหตุ: เนื่องจากคุณอาจต้องการใช้คอนโทรลเลอร์เดียวกันสำหรับเส้นทางเดี่ยว (`/account`) และเส้นทางพหูพจน์ (`/accounts/45`) ทรัพยากรเดี่ยวจะแมปไปยังคอนโทรลเลอร์พหูพจน์ ดังนั้น เช่น `resource :photo` และ `resources :photos` จะสร้างทั้งเส้นทางเดี่ยวและพหูพจน์ที่แมปไปยังคอนโทรลเลอร์เดียวกัน (`PhotosController`)

เส้นทางทรัพยากรเดี่ยวสร้างเฮลเปอร์เหล่านี้:

* `new_geocoder_path` ส่งคืน `/geocoder/new`
* `edit_geocoder_path` ส่งคืน `/geocoder/edit`
* `geocoder_path` ส่งคืน `/geocoder`

หมายเหตุ: การเรียกใช้ `resolve` เป็นสิ่งจำเป็นสำหรับแปลงอินสแตนซ์ของ `Geocoder` เป็นเส้นทางผ่าน [การระบุระเบียน](form_helpers.html#relying-on-record-identification)

เช่นเดียวกับทรัพยากรพหูพจน์ เฮลเปอร์เหล่าเดียวที่สิ้นสุดด้วย `_url` ยังรวมถึงโฮสต์ พอร์ต และคำนำหน้าเส้นทาง

### การจัดกลุ่มคอนโทรลเลอร์และเส้นทาง

คุณอาจต้องการจัดกลุ่มคอนโทรลเลอร์ต่าง ๆ ภายใต้เนมสเปซ โดยทั่วไป คุณอาจจัดกลุ่มคอนโทรลเลอร์ทางด้านการบริหารในเนมสเปซ `Admin::` และวางคอนโทรลเลอร์เหล่านี้ในไดเรกทอรี `app/controllers/admin` คุณสามารถเส้นทางไปยังกลุ่มดังกล่าวได้โดยใช้บล็อก [`namespace`][]:

```ruby
namespace :admin do
  resources :articles, :comments
end
```

นี้จะสร้างเส้นทางจำนวนมากสำหรับแต่ละคอนโทรลเลอร์ `articles` และ `comments` สำหรับ `Admin::ArticlesController` Rails จะสร้าง:

| HTTP Verb | เส้นทาง                     | คอนโทรลเลอร์#แอคชัน      | เฮลเปอร์เส้นทางที่ชื่อ |
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

สามารถทำเช่นนี้ได้เพียงเส้นทางเดียว:

```ruby
resources :articles, module: 'admin'
```

หากคุณต้องการเส้นทาง `/admin/articles` ไปยัง `ArticlesController` (โดยไม่มีคำนำหน้าโมดูล `Admin::`) คุณสามารถระบุเส้นทางด้วยบล็อก `scope`:
```ruby
scope '/admin' do
  resources :articles, :comments
end
```

นอกจากนี้ยังสามารถทำได้สำหรับเส้นทางเดียว:

```ruby
resources :articles, path: '/admin/articles'
```

ในทั้งสองกรณีเหล่านี้ named route helpers จะเหมือนเดิมหากคุณไม่ได้ใช้ `scope` ในกรณีสุดท้ายนี้ เส้นทางต่อไปนี้จะแมปไปยัง `ArticlesController`:

| HTTP Verb | เส้นทาง                     | คอนโทรลเลอร์#แอคชัน    | Named Route Helper     |
| --------- | ------------------------ | -------------------- | ---------------------- |
| GET       | /admin/articles          | articles#index       | articles_path          |
| GET       | /admin/articles/new      | articles#new         | new_article_path       |
| POST      | /admin/articles          | articles#create      | articles_path          |
| GET       | /admin/articles/:id      | articles#show        | article_path(:id)      |
| GET       | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id) |
| PATCH/PUT | /admin/articles/:id      | articles#update      | article_path(:id)      |
| DELETE    | /admin/articles/:id      | articles#destroy     | article_path(:id)      |

เคล็ดลับ: หากคุณต้องการใช้เนมสเปซคอนโทรเลอร์ที่แตกต่างกันภายในบล็อก `namespace` คุณสามารถระบุเส้นทางคอนโทรเลอร์แบบสมบูรณ์ได้ เช่น: `get '/foo', to: '/foo#index'`.


### ทรัพยากรที่ซ้อนกัน

มักจะมีทรัพยากรที่เป็นลูกของทรัพยากรอื่นที่มีความสัมพันธ์กันตามตรรกะ ตัวอย่างเช่น สมมติว่าแอปพลิเคชันของคุณรวมถึงโมเดลเหล่านี้:

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

การซ้อนกันของเส้นทางช่วยให้คุณจับความสัมพันธ์นี้ในการเรียกใช้เส้นทาง ในกรณีนี้คุณสามารถรวมการประกาศเส้นทางดังต่อไปนี้:

```ruby
resources :magazines do
  resources :ads
end
```

นอกจากเส้นทางสำหรับ magazines การประกาศนี้ยังจะเส้นทาง ads ไปยัง `AdsController`  URL ของ ads ต้องการ magazine:

| HTTP Verb | เส้นทาง                                 | คอนโทรลเลอร์#แอคชัน | ใช้สำหรับ                                                                   |
| --------- | ------------------------------------ | ----------------- | -------------------------------------------------------------------------- |
| GET       | /magazines/:magazine_id/ads          | ads#index         | แสดงรายการโฆษณาทั้งหมดสำหรับนิตยสารที่ระบุ                           |
| GET       | /magazines/:magazine_id/ads/new      | ads#new           | ส่งคืนฟอร์ม HTML สำหรับสร้างโฆษณาใหม่ที่เป็นของนิตยสารที่ระบุ           |
| POST      | /magazines/:magazine_id/ads          | ads#create        | สร้างโฆษณาใหม่ที่เป็นของนิตยสารที่ระบุ                                 |
| GET       | /magazines/:magazine_id/ads/:id      | ads#show          | แสดงโฆษณาที่เป็นของนิตยสารที่ระบุ                                       |
| GET       | /magazines/:magazine_id/ads/:id/edit | ads#edit          | ส่งคืนฟอร์ม HTML สำหรับแก้ไขโฆษณาที่เป็นของนิตยสารที่ระบุ               |
| PATCH/PUT | /magazines/:magazine_id/ads/:id      | ads#update        | อัปเดตโฆษณาที่เป็นของนิตยสารที่ระบุ                                       |
| DELETE    | /magazines/:magazine_id/ads/:id      | ads#destroy       | ลบโฆษณาที่เป็นของนิตยสารที่ระบุ                                           |

นี้ยังจะสร้างเฮลเปอร์เส้นทางเช่น `magazine_ads_url` และ `edit_magazine_ad_path` เฮลเปอร์เหล่านี้รับพารามิเตอร์แรกเป็นอินสแตนซ์ของ Magazine (`magazine_ads_url(@magazine)`).

#### ข้อจำกัดในการซ้อนกัน

คุณสามารถซ้อนทรัพยากรภายในทรัพยากรที่ซ้อนกันได้หากคุณต้องการ ตัวอย่างเช่น:

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

ทรัพยากรที่ซ้อนกันลึกๆ จะกลายเป็นเรื่องยุ่งยาก ในกรณีนี้ เช่น เมื่อแอปพลิเคชันรับรู้เส้นทางเช่น:

```
/publishers/1/magazines/2/photos/3
```

เฮลเปอร์เส้นทางที่เกี่ยวข้องคือ `publisher_magazine_photo_url` ซึ่งต้องการให้คุณระบุออบเจกต์ในระดับทั้งสามระดับ ในความเป็นจริง สถานการณ์นี้นั้นสับสนพอที่ [บทความยอดนิยมของ Jamis Buck](http://weblog.jamisbuck.org/2007/2/5/nesting-resources) แนะนำกฎข้อหนึ่งสำหรับการออกแบบ Rails ที่ดี:
เคล็ดลับ: ทรัพยากรไม่ควรถูกซ้อนกันมากกว่า 1 ระดับ

#### การซ้อนที่ตื้น

วิธีหนึ่งในการหลีกเลี่ยงการซ้อนลึก (ตามที่แนะนำด้านบน) คือการสร้างการกระทำของคอลเลกชันที่มีขอบเขตอยู่ภายใต้คอลเลกชันหลัก เพื่อให้เห็นความสัมพันธ์ของลำดับชั้น แต่ไม่ซ้อนการกระทำของสมาชิก กล่าวอีกนัยหนึ่งคือการสร้างเส้นทางด้วยข้อมูลที่น้อยที่สุดเพียงพอที่จะระบุทรัพยากรอย่างเฉพาะเจาะจง เช่น:

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

แนวคิดนี้สร้างสมดุลระหว่างเส้นทางที่เป็นคำอธิบายและการซ้อนลึก มีรูปแบบย่อสั้นที่ใช้ได้เพียงแค่นั้น ผ่านตัวเลือก `:shallow`:

```ruby
resources :articles do
  resources :comments, shallow: true
end
```

นี้จะสร้างเส้นทางเหมือนกับตัวอย่างแรก คุณยังสามารถระบุตัวเลือก `:shallow` ในทรัพยากรหลัก ในกรณีนี้ทรัพยากรที่ซ้อนกันทั้งหมดจะเป็นระดับตื้น:

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

ทรัพยากรบทความที่นี่จะมีเส้นทางที่สร้างขึ้นสำหรับมัน:

| HTTP Verb | เส้นทาง                                        | คอนโทรลเลอร์#การกระทำ | ช่วยเหลือเส้นทางที่มีชื่อ |
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

เมธอด [`shallow`][] ใน DSL สร้างขอบเขตภายในนั้นทุกการซ้อนลึกจะเป็นระดับตื้น สร้างเส้นทางเหมือนกับตัวอย่างก่อนหน้านี้:

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

มีตัวเลือกสำหรับ `scope` 2 ตัวเพื่อกำหนดเส้นทางที่ตื้นเอง `:shallow_path` นำหน้าเส้นทางสมาชิกด้วยพารามิเตอร์ที่ระบุ:
```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

ทรัพยากร comments ที่นี่จะมีเส้นทางที่สร้างขึ้นมาดังนี้:

| HTTP Verb | เส้นทาง                                         | คอนโทรลเลอร์#แอคชัน | ช่วยเหลือเส้นทางที่ตั้งชื่อ       |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /sekret/comments/:id/edit(.:format)          | comments#edit     | edit_comment_path        |
| GET       | /sekret/comments/:id(.:format)               | comments#show     | comment_path             |
| PATCH/PUT | /sekret/comments/:id(.:format)               | comments#update   | comment_path             |
| DELETE    | /sekret/comments/:id(.:format)               | comments#destroy  | comment_path             |

ตัวเลือก `:shallow_prefix` จะเพิ่มพารามิเตอร์ที่ระบุในช่วยเหลือเส้นทางที่ตั้งชื่อ:

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

ทรัพยากร comments ที่นี่จะมีเส้นทางที่สร้างขึ้นมาดังนี้:

| HTTP Verb | เส้นทาง                                         | คอนโทรลเลอร์#แอคชัน | ช่วยเหลือเส้นทางที่ตั้งชื่อ          |
| --------- | -------------------------------------------- | ----------------- | --------------------------- |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path       |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path       |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path    |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_sekret_comment_path    |
| GET       | /comments/:id(.:format)                      | comments#show     | sekret_comment_path         |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | sekret_comment_path         |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | sekret_comment_path         |


### เรื่องที่เกี่ยวกับการเชื่อมต่อเส้นทาง

เรื่องที่เกี่ยวกับการเชื่อมต่อเส้นทางช่วยให้คุณประกาศเส้นทางที่ซ้ำกันที่สามารถใช้ซ้ำได้ภายในทรัพยากรและเส้นทางอื่น ๆ ใน Rails ในการกำหนดเรื่องที่เกี่ยวข้องให้ใช้บล็อก [`concern`][]:

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

เรื่องที่เกี่ยวข้องเหล่านี้สามารถใช้ในทรัพยากรเพื่อหลีกเลี่ยงการทำซ้ำของโค้ดและแบ่งปันพฤติกรรมของเส้นทางร่วมกัน:

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

คุณยังสามารถใช้เรื่องที่เกี่ยวข้องได้ทุกที่โดยเรียกใช้ [`concerns`][]. ตัวอย่างเช่นในบล็อก `scope` หรือ `namespace`:

```ruby
namespace :articles do
  concerns :commentable
end
```


### การสร้างเส้นทางและ URL จากอ็อบเจกต์

นอกจากการใช้ช่วยเหลือเส้นทาง  Rails ยังสามารถสร้างเส้นทางและ URL จากอาร์เรย์ของพารามิเตอร์ได้ด้วย ตัวอย่างเช่นสมมติว่าคุณมีเซ็ตของเส้นทางนี้:

```ruby
resources :magazines do
  resources :ads
end
```

เมื่อใช้ `magazine_ad_path` คุณสามารถส่งอินสแตนซ์ของ `Magazine` และ `Ad` แทน ID ตัวเลขได้:

```erb
<%= link_to 'รายละเอียดโฆษณา', magazine_ad_path(@magazine, @ad) %>
```

คุณยังสามารถใช้ [`url_for`][ActionView::RoutingUrlFor#url_for] พร้อมกับอ็อบเจกต์เพื่อให้ Rails กำหนดเส้นทางที่คุณต้องการโดยอัตโนมัติ:

```erb
<%= link_to 'รายละเอียดโฆษณา', url_for([@magazine, @ad]) %>
```

ในกรณีนี้ Rails จะเห็นว่า `@magazine` เป็น `Magazine` และ `@ad` เป็น `Ad` และจะใช้ช่วยเหลือ `magazine_ad_path` ในช่วยเหลือเส้นทาง ในช่วยเหลือเส้นทางเช่น `link_to` คุณสามารถระบุเพียงวัตถุเท่านั้นแทนการเรียก `url_for` ทั้งหมด:

```erb
<%= link_to 'รายละเอียดโฆษณา', [@magazine, @ad] %>
```

หากคุณต้องการเชื่อมโยงไปยังนิตยสารเท่านั้น:
```erb
<%= link_to 'รายละเอียดนิตยสาร', @magazine %>
```

สำหรับการกระทำอื่น ๆ คุณเพียงแค่เพิ่มชื่อการกระทำเป็นส่วนแรกของอาร์เรย์:

```erb
<%= link_to 'แก้ไขโฆษณา', [:edit, @magazine, @ad] %>
```

สิ่งนี้ช่วยให้คุณสามารถจัดการกับอินสแตนซ์ของโมเดลของคุณเป็น URL และเป็นข้อดีสำคัญในการใช้รูปแบบที่เป็นทรัพยากร

### เพิ่มการกระทำ RESTful เพิ่มเติม

คุณไม่จำกัดเพียงเพียงเจ็ดเส้นทางที่ RESTful routing สร้างโดยค่าเริ่มต้น หากคุณต้องการคุณสามารถเพิ่มเส้นทางเพิ่มเติมที่ใช้กับคอลเลกชันหรือสมาชิกแต่ละรายการได้

#### เพิ่มเส้นทางสมาชิก

ในการเพิ่มเส้นทางสมาชิก เพียงเพิ่มบล็อก [`member`][] เข้าไปในบล็อกของทรัพยากร:

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

นี้จะรู้จัก `/photos/1/preview` ด้วย GET และเส้นทางไปยังการกระทำ `preview` ของ `PhotosController` โดยมีค่า id ของทรัพยากรที่ผ่านมาใน `params[:id]` นอกจากนี้ยังสร้างเฮลเปอร์ `preview_photo_url` และ `preview_photo_path`

ภายในบล็อกของเส้นทางสมาชิก ชื่อเส้นทางแต่ละเส้นทางระบุ HTTP verb ที่จะรู้จัก คุณสามารถใช้ [`get`][], [`patch`][], [`put`][], [`post`][], หรือ [`delete`][] ที่นี่ หากคุณไม่มี `member` เส้นทางหลายเส้นทางคุณยังสามารถส่ง `:on` ไปยังเส้นทางเพื่อลบบล็อก:

```ruby
resources :photos do
  get 'preview', on: :member
end
```

คุณสามารถละเว้นตัวเลือก `:on` นี้ได้ นี้จะสร้างเส้นทางสมาชิกเดียวกันยกเว้นว่าค่า id ของทรัพยากรจะสามารถใช้ได้ใน `params[:photo_id]` แทน `params[:id]` ช่วยเหลือเส้นทางจะถูกเปลี่ยนชื่อจาก `preview_photo_url` และ `preview_photo_path` เป็น `photo_preview_url` และ `photo_preview_path`

#### เพิ่มเส้นทางคอลเลกชัน

ในการเพิ่มเส้นทางไปยังคอลเลกชัน ใช้บล็อก [`collection`][]:

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

นี้จะเปิดให้ Rails รู้จักเส้นทางเช่น `/photos/search` ด้วย GET และเส้นทางไปยังการกระทำ `search` ของ `PhotosController` นอกจากนี้ยังสร้างเฮลเปอร์ `search_photos_url` และ `search_photos_path` เส้นทางช่วยเหลือ

เช่นเส้นทางสมาชิกคุณสามารถส่ง `:on` ไปยังเส้นทาง:

```ruby
resources :photos do
  get 'search', on: :collection
end
```

หมายเหตุ: หากคุณกำลังกำหนดเส้นทางทรัพยากรเพิ่มเติมด้วยสัญลักษณ์เป็นอาร์กิวเมนต์ตำแหน่งแรก โปรดทราบว่าสัญลักษณ์จะเป็นการกระทำของคอนโทรลเลอร์ในขณะที่สตริงจะเป็นเส้นทาง

#### เพิ่มเส้นทางสำหรับการกระทำใหม่เพิ่มเติม

ในการเพิ่มการกระทำใหม่โดยใช้ทางลัด `:on`:

```ruby
resources :comments do
  get 'preview', on: :new
end
```

นี้จะเปิดให้ Rails รู้จักเส้นทางเช่น `/comments/new/preview` ด้วย GET และเส้นทางไปยังการกระทำ `preview` ของ `CommentsController` นอกจากนี้ยังสร้างเฮลเปอร์ `preview_new_comment_url` และ `preview_new_comment_path` เส้นทางช่วยเหลือ

เคล็ดลับ: หากคุณพบว่าคุณกำลังเพิ่มการกระทำเพิ่มเติมมากมายในเส้นทางทรัพยากร นี่คือเวลาที่คุณควรหยุดและถามตัวเองว่าคุณกำลังปกปิดการมีอีกทรัพยากรหรือไม่

เส้นทางที่ไม่ใช่ทรัพยากร
----------------------

นอกเหนือจากการเส้นทางทรัพยากร Rails ยังมีการสนับสนุนที่มีประสิทธิภาพสำหรับการเส้นทาง URL อย่างอิสระไปยังการกระทำ ที่นี่คุณไม่ได้รับกลุ่มของเส้นทางที่สร้างโดยการเส้นทางทรัพยากร แต่คุณตั้งค่าเส้นทางแต่ละเส้นทางแยกต่างหากภายในแอปพลิเคชันของคุณ

แม้ว่าคุณควรใช้การเส้นทางที่เป็นทรัพยากรเสมอ แต่ก็ยังมีสถานที่หลายแห่งที่การเส้นทางที่เรียบง่ายกว่าเหมาะสม ไม่จำเป็นต้องพยายามจัดเรียงทุกส่วนของแอปพลิเคชันของคุณให้พอดีกับกรอบการทำงานที่เป็นทรัพยากร
โดยเฉพาะการเส้นทางที่ง่ายทำให้ง่ายมากที่จะแมป URL เก่ากับการดำเนินการใหม่ของ Rails

### พารามิเตอร์ที่ผูกไว้

เมื่อคุณตั้งค่าเส้นทางปกติคุณจะให้สัญลักษณ์ต่อเนื่องกันที่ Rails จะแมปไปยังส่วนต่าง ๆ ของคำขอ HTTP ที่เข้ามา ตัวอย่างเช่นพิจารณาเส้นทางนี้:

```ruby
get 'photos(/:id)', to: 'photos#display'
```

หากคำขอที่เข้ามาของ `/photos/1` ถูกประมวลผลโดยเส้นทางนี้ (เนื่องจากไม่ตรงกับเส้นทางก่อนหน้าในไฟล์) ผลลัพธ์จะเป็นการเรียกใช้การดำเนินการ `display` ของ `PhotosController` และทำให้พารามิเตอร์สุดท้ายเป็น `"1"` ที่ใช้ได้เป็น `params[:id]` เส้นทางนี้ยังจะเส้นทางคำขอที่เข้ามาของ `/photos` ไปยัง `PhotosController#display` เนื่องจาก `:id` เป็นพารามิเตอร์ที่เป็นทางเลือกที่ระบุโดยวงเล็บ

### ส่วนที่เปลี่ยนแปลงได้

คุณสามารถตั้งค่าส่วนที่เปลี่ยนแปลงได้ในเส้นทางปกติเท่าที่คุณต้องการ ส่วนใดก็ตามจะสามารถใช้ได้ในการดำเนินการเป็นส่วนหนึ่งของ `params` หากคุณตั้งค่าเส้นทางนี้:

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

เส้นทางที่เข้ามาของ `/photos/1/2` จะถูกส่งต่อไปยังการดำเนินการ `show` ของ `PhotosController` `params[:id]` จะเป็น `"1"` และ `params[:user_id]` จะเป็น `"2"`

เคล็ดลับ: โดยค่าเริ่มต้นส่วนที่เปลี่ยนแปลงไม่ยอมรับจุด - เนื่องจากจุดถูกใช้เป็นตัวคั่นสำหรับเส้นทางที่จัดรูปแบบ หากคุณต้องการใช้จุดภายในส่วนที่เปลี่ยนแปลง ให้เพิ่มข้อจำกัดที่เขียนทับนี้ - ตัวอย่างเช่น `id: /[^\/]+/` อนุญาตให้ใช้ทุกอย่างยกเว้นเส้นทาง

### ส่วนที่คงที่

คุณสามารถระบุส่วนที่คงที่เมื่อสร้างเส้นทางโดยไม่ต้องเติมเครื่องหมายคอลอนกับส่วน:

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

เส้นทางนี้จะตอบสนองกับเส้นทางเช่น `/photos/1/with_user/2` ในกรณีนี้ `params` จะเป็น `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`

### สตริงคิวรี

`params` ยังรวมถึงพารามิเตอร์จากสตริงคิวรีด้วย ตัวอย่างเช่นกับเส้นทางนี้:

```ruby
get 'photos/:id', to: 'photos#show'
```

เส้นทางที่เข้ามาของ `/photos/1?user_id=2` จะถูกส่งต่อไปยังการดำเนินการ `show` ของคอนโทรลเลอร์ `Photos` `params` จะเป็น `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`

### การกำหนดค่าเริ่มต้น

คุณสามารถกำหนดค่าเริ่มต้นในเส้นทางโดยให้แฮชสำหรับตัวเลือก `:defaults` นี้ยังมีผลกับพารามิเตอร์ที่คุณไม่ระบุเป็นส่วนที่เปลี่ยนแปลง ตัวอย่างเช่น:

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails จะตรงกับ `photos/12` กับการดำเนินการ `show` ของ `PhotosController` และตั้งค่า `params[:format]` เป็น `"jpg"`

คุณยังสามารถใช้บล็อก [`defaults`][] เพื่อกำหนดค่าเริ่มต้นสำหรับรายการหลายรายการ:

```ruby
defaults format: :json do
  resources :photos
end
```

หมายเหตุ: คุณไม่สามารถเขียนทับค่าเริ่มต้นผ่านพารามิเตอร์คิวรี - นี้เป็นเหตุผลด้านความปลอดภัย ค่าเริ่มต้นที่สามารถเขียนทับได้คือส่วนที่เปลี่ยนแปลงผ่านการแทนที่ในเส้นทาง URL


### การตั้งชื่อเส้นทาง

คุณสามารถระบุชื่อสำหรับเส้นทางใด ๆ โดยใช้ตัวเลือก `:as`:

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

นี้จะสร้าง `logout_path` และ `logout_url` เป็นช่วยในการตั้งชื่อเส้นทางที่มีชื่อในแอปพลิเคชันของคุณ เรียกใช้ `logout_path` จะคืนค่า `/exit`

คุณยังสามารถใช้สิ่งนี้เพื่อเขียนทับวิธีการเส้นทางที่กำหนดโดยทรัพยากรโดยวางเส้นทางที่กำหนดเองก่อนที่จะกำหนดทรัพยากร เช่นนี้:
```ruby
get ':username', to: 'users#show', as: :user
resources :users
```

นี้จะกำหนดเมธอด `user_path` ที่จะสามารถใช้ได้ในคอนโทรลเลอร์ เฮลเปอร์ และวิว ซึ่งจะไปยังเส้นทางเช่น `/bob` ภายในการกระทำ `show` ของ `UsersController` `params[:username]` จะมีชื่อผู้ใช้สำหรับผู้ใช้ แก้ไข `:username` ในการกำหนดเส้นทางหากคุณไม่ต้องการให้ชื่อพารามิเตอร์เป็น `:username`.

### การจำกัดเงื่อนไขของ HTTP Verb

โดยทั่วไปคุณควรใช้เมธอด [`get`][], [`post`][], [`put`][], [`patch`][], และ [`delete`][] เพื่อจำกัดเส้นทางไปยังตัวแปรเฉพาะ คุณสามารถใช้เมธอด [`match`][] พร้อมกับตัวเลือก `:via` เพื่อจับคู่หลายเมธอดพร้อมกัน:

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

คุณสามารถจับคู่ทุกเมธอดไปยังเส้นทางเฉพาะโดยใช้ `via: :all`:

```ruby
match 'photos', to: 'photos#show', via: :all
```

หมายเหตุ: การจับคู่ทั้ง `GET` และ `POST` ไปยังการกระทำเดียวกันมีผลกระทบต่อความปลอดภัย โดยทั่วไปคุณควรหลีกเลี่ยงการจับคู่ทุกเมธอดไปยังการกระทำเว้นแต่คุณมีเหตุผลที่ดี.

หมายเหตุ: `GET` ใน Rails จะไม่ตรวจสอบ CSRF token คุณไม่ควรเขียนลงในฐานข้อมูลจากคำขอ `GET` สำหรับข้อมูลเพิ่มเติมดูที่[คู่มือความปลอดภัย](security.html#csrf-countermeasures) เกี่ยวกับการป้องกัน CSRF.

### การจำกัดเงื่อนไขของ Segment

คุณสามารถใช้ตัวเลือก `:constraints` เพื่อบังคับรูปแบบสำหรับส่วนแปลกๆ:

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

เส้นทางนี้จะตรงกับเส้นทางเช่น `/photos/A12345` แต่ไม่ตรงกับ `/photos/893` คุณสามารถแสดงเส้นทางเดียวกันได้อย่างสรุปดังนี้:

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` รับรูปแบบปกติที่มีข้อจำกัดว่าไม่สามารถใช้เครื่องหมายยึดตำแหน่งได้ ตัวอย่างเช่น เส้นทางต่อไปนี้จะไม่ทำงาน:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

อย่างไรก็ตาม โปรดทราบว่าคุณไม่จำเป็นต้องใช้เครื่องหมายยึดตำแหน่งเนื่องจากเส้นทางทั้งหมดจะยึดตำแหน่งที่เริ่มต้นและสิ้นสุด

ตัวอย่างเช่น เส้นทางต่อไปนี้จะอนุญาตให้ `articles` กับ `to_param` ค่าเช่น `1-hello-world` ที่เริ่มต้นด้วยตัวเลขและ `users` กับ `to_param` ค่าเช่น `david` ที่ไม่เริ่มต้นด้วยตัวเลขใช้งานร่วมกันใน root namespace:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### การจำกัดเงื่อนไขของ Request-Based

คุณยังสามารถจำกัดเส้นทางตามเมธอดใดก็ได้บน [Request object](action_controller_overview.html#the-request-object) ที่ส่งคืน `String`.

คุณระบุเงื่อนไขขึ้นอยู่กับคำขอเช่นเดียวกับการระบุเงื่อนไขของส่วน:

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

หมายเหตุ: เงื่อนไขของคำขอทำงานโดยเรียกเมธอดบน [Request object](action_controller_overview.html#the-request-object) ด้วยชื่อเดียวกับคีย์แล้วเปรียบเทียบค่าที่ส่งคืนกับค่าของแฮช ดังนั้นค่าเงื่อนไขควรตรงกับประเภทการส่งคืนของวัตถุคำขอ ตัวอย่างเช่น: `constraints: { subdomain: 'api' }` จะตรงกับ subdomain `api` ตามที่คาดหวัง อย่างไรก็ตาม การใช้สัญลักษณ์ `constraints: { subdomain: :api }` จะไม่ทำงาน เนื่องจาก `request.subdomain` ส่งคืน `'api'` เป็นสตริง
หมายเหตุ: มีข้อยกเว้นสำหรับการจำกัดเงื่อนไข `format`: ในขณะที่เป็นเมธอดบนออบเจกต์ Request นั้นเอง แต่ก็เป็นพารามิเตอร์ที่ไม่บังคับในทุกๆเส้นทาง การจำกัดเงื่อนไขของเซกเมนต์จะมีความสำคัญกว่า และเงื่อนไข `format` จะถูกใช้เมื่อมีการบังคับใช้ผ่านแฮช ตัวอย่างเช่น `get 'foo', constraints: { format: 'json' }` จะตรงกับ `GET  /foo` เนื่องจาก format เป็นไม่บังคับตามค่าเริ่มต้น อย่างไรก็ตาม คุณสามารถ [ใช้ lambda](#advanced-constraints) เช่นเดียวกับ `get 'foo', constraints: lambda { |req| req.format == :json }` และเส้นทางจะตรงกับคำขอ JSON ที่ระบุโดยชัดเจนเท่านั้น


### การจำกัดเงื่อนไขขั้นสูง

หากคุณมีเงื่อนไขที่ซับซ้อนมากขึ้น คุณสามารถให้วัตถุที่ตอบสนองกับ `matches?` ซึ่ง Rails จะใช้ ตัวอย่างเช่น หากคุณต้องการเส้นทางผู้ใช้ทั้งหมดในรายการที่ถูกจำกัดไว้ให้กับ `RestrictedListController` คุณสามารถทำได้ดังนี้:

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

คุณยังสามารถระบุเงื่อนไขเป็น lambda ได้เช่นกัน:

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

ทั้ง `matches?` และ lambda จะได้รับอ็อบเจกต์ `request` เป็นอาร์กิวเมนต์

#### เงื่อนไขในรูปแบบบล็อก

คุณสามารถระบุเงื่อนไขในรูปแบบบล็อกได้ ซึ่งเป็นวิธีที่ใช้ได้เมื่อคุณต้องการใช้กฎเดียวกันกับเส้นทางหลายเส้นทาง ตัวอย่างเช่น:

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

คุณยังสามารถใช้ `lambda` ได้:

```ruby
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

### Route Globbing และ Wildcard Segments

Route globbing เป็นวิธีที่ระบุว่าพารามิเตอร์ใดต้องตรงกับส่วนที่เหลือทั้งหมดของเส้นทาง ตัวอย่างเช่น:

```ruby
get 'photos/*other', to: 'photos#unknown'
```

เส้นทางนี้จะตรงกับ `photos/12` หรือ `/photos/long/path/to/12` โดยกำหนดค่า `params[:other]` เป็น `"12"` หรือ `"long/path/to/12"`  เซกเมนต์ที่มีเครื่องหมายดอกจะเรียกว่า "wildcard segments"

Wildcard segments สามารถเกิดขึ้นที่ใดก็ได้ในเส้นทาง เช่น:

```ruby
get 'books/*section/:title', to: 'books#show'
```

จะตรงกับ `books/some/section/last-words-a-memoir` โดยกำหนดค่า `params[:section]` เป็น `'some/section'` และ `params[:title]` เป็น `'last-words-a-memoir'`

ทางเทคนิคแล้ว เส้นทางสามารถมี wildcard segments มากกว่าหนึ่งตัวได้ ตัวตรวจจับจะกำหนดค่าเซกเมนต์ให้กับพารามิเตอร์ในวิธีที่เข้าใจง่าย ตัวอย่างเช่น:

```ruby
get '*a/foo/*b', to: 'test#index'
```

จะตรงกับ `zoo/woo/foo/bar/baz` โดยกำหนดค่า `params[:a]` เป็น `'zoo/woo'` และ `params[:b]` เป็น `'bar/baz'`

หมายเหตุ: โดยการร้องขอ `'/foo/bar.json'` ค่า `params[:pages]` จะเท่ากับ `'foo/bar'` โดยมีรูปแบบคำขอเป็น JSON หากคุณต้องการให้พฤติกรรมเวอร์ชัน 3.0.x เหมือนเดิมคุณสามารถให้ `format: false` เช่นนี้:

```ruby
get '*pages', to: 'pages#show', format: false
```

หมายเหตุ: หากคุณต้องการให้เซกเมนต์รูปแบบเป็นบังคับ โดยไม่สามารถข้ามได้ คุณสามารถให้ `format: true` เช่นนี้:

```ruby
get '*pages', to: 'pages#show', format: true
```

### การเปลี่ยนเส้นทาง

คุณสามารถเปลี่ยนเส้นทางใดๆเป็นเส้นทางอื่นโดยใช้ตัวช่วย [`redirect`][] ในเราเตอร์ของคุณ:

```ruby
get '/stories', to: redirect('/articles')
```

คุณยังสามารถนำเซกเมนต์แบบไดนามิกจากการตรงกันมาใช้ในเส้นทางที่เปลี่ยนเส้นทางไป:
```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

คุณยังสามารถให้บล็อกให้กับ `redirect` ได้เช่นกัน โดยบล็อกจะได้รับพารามิเตอร์ของพาธที่ถูกสัญลักษณ์และออบเจ็กต์คำขอ:

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

โปรดทราบว่าการเปลี่ยนเส้นทางเริ่มต้นเป็นการเปลี่ยนเส้นทางเป็นการเปลี่ยนเส้นทาง 301 "เปลี่ยนที่อยู่ถาวร" โปรดทราบว่าบางเบราว์เซอร์เว็บหรือเซิร์ฟเวอร์พร็อกซีอาจจะเก็บแคชการเปลี่ยนเส้นทางประเภทนี้ ทำให้หน้าเว็บเก่าไม่สามารถเข้าถึงได้ คุณสามารถใช้ตัวเลือก `:status` เพื่อเปลี่ยนสถานะการตอบสนอง:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

ในทุกกรณีเหล่านี้ หากคุณไม่ได้ระบุโฮสต์ที่นำหน้า (`http://www.example.com`) Rails จะเอารายละเอียดเหล่านั้นจากคำขอปัจจุบัน


### เส้นทางไปยังแอปพลิเคชันแบบ Rack

แทนที่จะใช้สตริงเช่น `'articles#index'` ซึ่งสอดคล้องกับการกระทำ `index` ใน `ArticlesController` คุณสามารถระบุแอปพลิเคชันแบบ Rack ใด ๆ เป็นจุดปลายทางสำหรับตัวตรวจจับ:

```ruby
match '/application.js', to: MyRackApp, via: :all
```

เมื่อ `MyRackApp` ตอบสนอง `call` และส่งคืน `[status, headers, body]` เราตัวตรวจจับจะไม่รู้ว่าแอปพลิเคชันแบบ Rack และการกระทำนั้นต่างกัน นี่คือการใช้ `via: :all` ที่เหมาะสม เนื่องจากคุณต้องการให้แอปพลิเคชันแบบ Rack จัดการกระทำทั้งหมดตามที่คิดว่าเหมาะสม

หมายเหตุ: สำหรับผู้สนใจ `'articles#index'` จริงๆ นั้นขยายออกเป็น `ArticlesController.action(:index)` ซึ่งส่งคืนแอปพลิเคชันแบบ Rack ที่ถูกต้อง

หมายเหตุ: เนื่องจาก procs / lambdas เป็นวัตถุที่ตอบสนองกับ `call` คุณสามารถดำเนินการเริ่มต้นที่ง่ายมาก (เช่นสำหรับการตรวจสุขภาพ) ภายในบรรทัดเดียว:<br>`get '/health', to: ->(env) { [204, {}, ['']] }`

หากคุณระบุแอปพลิเคชันแบบ Rack เป็นจุดปลายทางสำหรับตัวตรวจจับ โปรดจำไว้ว่าเส้นทางจะไม่เปลี่ยนแปลงในแอปพลิเคชันที่ได้รับ ด้วยเส้นทางต่อไปนี้แอปพลิเคชันแบบ Rack ของคุณควรคาดหวังว่าเส้นทางจะเป็น `/admin`:

```ruby
match '/admin', to: AdminApp, via: :all
```

หากคุณต้องการให้แอปพลิเคชันแบบ Rack ของคุณได้รับคำขอที่เส้นทางรากแทน ให้ใช้ [`mount`][]:

```ruby
mount AdminApp, at: '/admin'
```


### การใช้ `root`

คุณสามารถระบุว่า Rails ควรเส้นทาง `'/'` ไปยังอะไรด้วย [`root`][] เมธอด:

```ruby
root to: 'pages#main'
root 'pages#main' # ทางลัดสำหรับข้างต้น
```

คุณควรวางเส้นทาง `root` ที่ด้านบนของไฟล์ เนื่องจากเป็นเส้นทางที่ได้รับความนิยมมากที่สุดและควรจะตรงกันก่อน

หมายเหตุ: เส้นทาง `root` เฉพาะเส้นทาง `GET` เท่านั้นที่จะเส้นทางไปยังการกระทำ

คุณยังสามารถใช้ root ภายในเนมสเปซและขอบเขตเช่นกัน เช่น:

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```


### เส้นทางอักขระยูนิโค้ด

คุณสามารถระบุเส้นทางอักขระยูนิโค้ดโดยตรง ตัวอย่างเช่น:

```ruby
get 'こんにちは', to: 'welcome#index'
```

### เส้นทางโดยตรง

คุณสามารถสร้างเฮลเปอร์ URL ที่กำหนดเองโดยตรงโดยการเรียก [`direct`][] ตัวอย่างเช่น:

```ruby
direct :homepage do
  "https://rubyonrails.org"
end

# >> homepage_url
# => "https://rubyonrails.org"
```

ค่าที่ส่งคืนจากบล็อกต้องเป็นอาร์กิวเมนต์ที่ถูกต้องสำหรับเมธอด `url_for` ดังนั้นคุณสามารถส่ง URL สตริงที่ถูกต้อง Hash, Array, อินสแตนซ์ Active Model หรือคลาส Active Model

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### การใช้ `resolve`

เมธอด [`resolve`][] ช่วยให้สามารถกำหนดการแมปโพลิมอร์ฟิกของโมเดลเองได้ ตัวอย่างเช่น:

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_with model: @basket do |form| %>
  <!-- แบบฟอร์มของตะกร้า -->
<% end %>
```

สิ่งนี้จะสร้าง URL แบบเอกพจน์ `/basket` แทนที่ `/baskets/:id` ที่ใช้งานปกติ


การกำหนดเส้นทางของทรัพยากรเอง
------------------------------

แม้ว่าเส้นทางและเฮลเปอร์ที่ถูกสร้างขึ้นโดย [`resources`][] จะใช้งานได้ดีเสมอ แต่คุณอาจต้องการกำหนดเส้นทางเหล่านี้ให้เหมาะสมกับคุณ ใน Rails คุณสามารถกำหนดเส้นทางของเฮลเปอร์ที่เป็นทรัพยากรได้เกือบทุกส่วน

### ระบุคอนโทรลเลอร์ที่จะใช้

ตัวเลือก `:controller` ช่วยให้คุณระบุคอนโทรลเลอร์ที่จะใช้สำหรับทรัพยากร ตัวอย่างเช่น:

```ruby
resources :photos, controller: 'images'
```

จะรู้จักเส้นทางที่เริ่มต้นด้วย `/photos` แต่จะเส้นทางไปยังคอนโทรลเลอร์ `Images`:

| HTTP Verb | เส้นทาง             | คอนโทรลเลอร์#แอคชัน | เฮลเปอร์ของเส้นทาง   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | images#index      | photos_path          |
| GET       | /photos/new      | images#new        | new_photo_path       |
| POST      | /photos          | images#create     | photos_path          |
| GET       | /photos/:id      | images#show       | photo_path(:id)      |
| GET       | /photos/:id/edit | images#edit       | edit_photo_path(:id) |
| PATCH/PUT | /photos/:id      | images#update     | photo_path(:id)      |
| DELETE    | /photos/:id      | images#destroy    | photo_path(:id)      |

หมายเหตุ: ใช้ `photos_path`, `new_photo_path`, เป็นต้น เพื่อสร้างเส้นทางสำหรับทรัพยากรนี้

สำหรับคอนโทรลเลอร์ที่อยู่ในเนมสเปซคุณสามารถใช้รูปแบบการระบุตามไดเรกทอรี ตัวอย่างเช่น:

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

นี้จะเส้นทางไปยังคอนโทรลเลอร์ `Admin::UserPermissions`.

หมายเหตุ: เฉพาะรูปแบบไดเรกทอรีเท่านั้นที่รองรับ การระบุคอนโทรลเลอร์ด้วยรูปแบบค่าคงที่ของ Ruby (เช่น `controller: 'Admin::UserPermissions'`) อาจทำให้เกิดปัญหาในการเส้นทางและทำให้เกิดคำเตือน

### ระบุเงื่อนไข

คุณสามารถใช้ตัวเลือก `:constraints` เพื่อระบุรูปแบบที่ต้องการบน `id` ที่ไม่ระบุโดยชัดเจน ตัวอย่างเช่น:

```ruby
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

การระบุนี้จำกัดพารามิเตอร์ `:id` ให้ตรงกับรูปแบบที่ระบุในเรกเอ็กซ์ ดังนั้นในกรณีนี้เราจะไม่สามารถเส้นทาง `/photos/1` ไปยังเส้นทางนี้ได้แล้ว แต่ `/photos/RR27` จะสามารถเส้นทางได้

คุณสามารถระบุเงื่อนไขเดียวเพื่อใช้กับหลายเส้นทางได้โดยใช้รูปแบบบล็อก:

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

หมายเหตุ: แน่นอนว่าคุณสามารถใช้เงื่อนไขที่ซับซ้อนมากขึ้นที่มีให้ในเส้นทางที่ไม่ใช่ทรัพยากรในบริบทนี้

เคล็ดลับ: โดยปกติพารามิเตอร์ `:id` ไม่รับค่าจุด - เนื่องจากจุดถูกใช้เป็นตัวคั่นเส้นทางที่มีรูปแบบ หากคุณต้องการใช้จุดภายใน `:id` เพิ่มเงื่อนไขที่จะแทนที่นี้ - ตัวอย่างเช่น `id: /[^\/]+/` อนุญาตให้ใช้ทุกอย่างยกเว้นเส้นทาง

### การแทนที่เฮลเปอร์ของเส้นทางที่ตั้งชื่อ

ตัวเลือก `:as` ช่วยให้คุณแทนที่ชื่อปกติของเฮลเปอร์ของเส้นทางที่ตั้งชื่อได้ ตัวอย่างเช่น:

```ruby
resources :photos, as: 'images'
```

จะรู้จักเส้นทางที่เริ่มต้นด้วย `/photos` และเส้นทางคำขอจะเส้นทางไปยัง `PhotosController` แต่ใช้ค่าของตัวเลือก `:as` เป็นชื่อเฮลเปอร์

| HTTP Verb | เส้นทาง             | คอนโทรลเลอร์#แอคชัน | เฮลเปอร์ของเส้นทาง   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | photos#index      | images_path          |
| GET       | /photos/new      | photos#new        | new_image_path       |
| POST      | /photos          | photos#create     | images_path          |
| GET       | /photos/:id      | photos#show       | image_path(:id)      |
| GET       | /photos/:id/edit | photos#edit       | edit_image_path(:id) |
| PATCH/PUT | /photos/:id      | photos#update     | image_path(:id)      |
| DELETE    | /photos/:id      | photos#destroy    | image_path(:id)      |
### การเขียนทับส่วน `new` และ `edit`

ตัวเลือก `:path_names` ช่วยให้คุณสามารถเขียนทับส่วน `new` และ `edit` ที่ถูกสร้างโดยอัตโนมัติในเส้นทางได้:

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

นี้จะทำให้เส้นทางรับรู้เส้นทางเช่น:

```
/photos/make
/photos/1/change
```

หมายเหตุ: ชื่อแอ็กชันจริงๆ ไม่เปลี่ยนไปด้วยตัวเลือกนี้ สองเส้นทางที่แสดงจะยังคงเส้นทางไปยังแอ็กชัน `new` และ `edit`

เคล็ดลับ: หากคุณพบว่าต้องการเปลี่ยนตัวเลือกนี้ให้เหมือนกันสำหรับเส้นทางทั้งหมดของคุณ คุณสามารถใช้สโคป เช่นด้านล่าง:

```ruby
scope path_names: { new: 'make' } do
  # เส้นทางที่เหลือ
end
```

### เติมคำนำหน้าให้กับ Named Route Helpers

คุณสามารถใช้ตัวเลือก `:as` เพื่อเติมคำนำหน้าให้กับ named route helpers ที่ Rails สร้างสำหรับเส้นทาง ใช้ตัวเลือกนี้เพื่อป้องกันการชนกันของชื่อระหว่างเส้นทางที่ใช้ path scope เช่น:

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

นี้เปลี่ยน named route helpers สำหรับ `/admin/photos` จาก `photos_path`, `new_photos_path`, เป็น `admin_photos_path`, `new_admin_photo_path` เป็นต้น โดยไม่มีการเพิ่ม `as: 'admin_photos` ใน scoped `resources :photos` แล้ว non-scoped `resources :photos` จะไม่มี named route helpers ใดๆ

เพื่อเติมคำนำหน้าให้กับกลุ่มของ named route helpers ใช้ `:as` กับ `scope`:

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

เหมือนเดิม นี้เปลี่ยน `/admin` scoped resource helpers เป็น `admin_photos_path` และ `admin_accounts_path` และอนุญาตให้ non-scoped resources ใช้ `photos_path` และ `accounts_path`

หมายเหตุ: สโคปของ `namespace` จะเพิ่ม `:as` รวมถึง `:module` และ `:path` prefixes โดยอัตโนมัติ

#### สโคปพารามิเตอร์

คุณสามารถเติมคำนำหน้าเส้นทางด้วยพารามิเตอร์ที่มีชื่อ:

```ruby
scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
  resources :articles
end
```

นี้จะให้คุณได้เส้นทางเช่น `/1/articles/9` และจะอนุญาตให้คุณอ้างอิงส่วน `account_id` ของเส้นทางเป็น `params[:account_id]` ในคอนโทรลเลอร์ เฮลเปอร์ และวิว

นี้ยังสร้าง path และ URL helpers ที่มีคำนำหน้า `account_` ซึ่งคุณสามารถส่งออบเจกต์ของคุณเข้าไปได้เหมือนเดิม:

```ruby
account_article_path(@account, @article) # => /1/article/9
url_for([@account, @article])            # => /1/article/9
form_with(model: [@account, @article])   # => <form action="/1/article/9" ...>
```

เรากำลัง [ใช้เงื่อนไข](#segment-constraints) เพื่อจำกัดขอบเขตของสโคปให้เข้ากันเฉพาะกับสตริงที่คล้ายกับ ID เราสามารถเปลี่ยนเงื่อนไขให้เหมาะสมกับความต้องการของคุณ หรือละเว้นได้ ตัวเลือก `:as` ไม่จำเป็นอย่างเคร่งครัด แต่โดยไม่มีมัน Rails จะเรียกข้อผิดพลาดเมื่อประเมิน `url_for([@account, @article])` หรือเฮลเปอร์อื่น ๆ ที่ขึ้นอยู่กับ `url_for` เช่น [`form_with`][]

### จำกัดเส้นทางที่สร้าง

โดยค่าเริ่มต้น Rails จะสร้างเส้นทางสำหรับแอ็กชันเริ่มต้นเจ็ดอัน (`index`, `show`, `new`, `create`, `edit`, `update`, และ `destroy`) สำหรับเส้นทาง RESTful ทุกเส้นทางในแอปพลิเคชันของคุณ คุณสามารถใช้ตัวเลือก `:only` และ `:except` เพื่อปรับแต่งพฤติกรรมนี้ได้อย่างละเอียดถี่ถ้วน เมื่อใช้ตัวเลือก `:only` จะบอก Rails ให้สร้างเฉพาะเส้นทางที่ระบุ:

```ruby
resources :photos, only: [:index, :show]
```

ตอนนี้คำขอ `GET` ไปยัง `/photos` จะสำเร็จ แต่คำขอ `POST` ไปยัง `/photos` (ซึ่งจะถูกเส้นทางไปยังแอ็กชัน `create` ตามปกติ) จะล้มเหลว

ตัวเลือก `:except` ระบุเส้นทางหรือรายการเส้นทางที่ Rails ไม่ควรสร้าง:
```ruby
resources :photos, except: :destroy
```

ในกรณีนี้ Rails จะสร้างเส้นทางทั้งหมดตามปกติยกเว้นเส้นทางสำหรับ `destroy` (คำขอ `DELETE` ไปยัง `/photos/:id`)

เคล็ดลับ: หากแอปพลิเคชันของคุณมีเส้นทาง RESTful จำนวนมาก การใช้ `:only` และ `:except` เพื่อสร้างเฉพาะเส้นทางที่คุณต้องการจริงๆ สามารถลดการใช้หน่วยความจำและเร่งกระบวนการเส้นทางได้

### เส้นทางที่แปลแล้ว

โดยใช้ `scope` เราสามารถเปลี่ยนชื่อเส้นทางที่สร้างโดย `resources`:

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

Rails ตอนนี้สร้างเส้นทางไปยัง `CategoriesController`.

| HTTP Verb | เส้นทาง                       | Controller#Action  | Named Route Helper      |
| --------- | -------------------------- | ------------------ | ----------------------- |
| GET       | /kategorien                | categories#index   | categories_path         |
| GET       | /kategorien/neu            | categories#new     | new_category_path       |
| POST      | /kategorien                | categories#create  | categories_path         |
| GET       | /kategorien/:id            | categories#show    | category_path(:id)      |
| GET       | /kategorien/:id/bearbeiten | categories#edit    | edit_category_path(:id) |
| PATCH/PUT | /kategorien/:id            | categories#update  | category_path(:id)      |
| DELETE    | /kategorien/:id            | categories#destroy | category_path(:id)      |

### การแทนที่รูปแบบเป็นเอกพจน์

หากคุณต้องการแทนที่รูปแบบเป็นเอกพจน์ของทรัพยากร คุณควรเพิ่มกฎเพิ่มเติมใน inflector ผ่าน [`inflections`][]:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```


### การใช้ `:as` ในทรัพยากรที่ซ้อนกัน

ตัวเลือก `:as` จะแทนที่ชื่อทรัพยากรที่สร้างโดยอัตโนมัติในตัวช่วยเส้นทางที่ซ้อนกัน ตัวอย่างเช่น:

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

นี้จะสร้างตัวช่วยเส้นทางเช่น `magazine_periodical_ads_url` และ `edit_magazine_periodical_ad_path`.

### การแทนที่พารามิเตอร์เส้นทางที่มีชื่อ

ตัวเลือก `:param` จะแทนที่ตัวระบุทรัพยากรเริ่มต้น `:id` (ชื่อของ [segment แบบไดนามิก](routing.html#dynamic-segments) ที่ใช้สร้างเส้นทาง) คุณสามารถเข้าถึงเซกเมนต์นั้นจากคอนโทรลเลอร์ของคุณโดยใช้ `params[<:param>]`.

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

คุณสามารถแทนที่ `ActiveRecord::Base#to_param` ของโมเดลที่เกี่ยวข้องเพื่อสร้าง URL:

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

แยกไฟล์เส้นทางที่ใหญ่มากเป็นหลายไฟล์เล็กๆ
-------------------------------------------------------

หากคุณทำงานในแอปพลิเคชันขนาดใหญ่ที่มีเส้นทางหลายพันเส้นทาง ไฟล์เดียว `config/routes.rb` อาจกลายเป็นซับซ้อนและยากต่อการอ่าน

Rails มีวิธีการแยกไฟล์เส้นทางที่ใหญ่มากเป็นหลายไฟล์เล็กๆ โดยใช้แมโค [`draw`][]

คุณสามารถมีไฟล์เส้นทาง `admin.rb` ที่มีเส้นทางทั้งหมดสำหรับพื้นที่แอดมิน ไฟล์อื่น `api.rb` สำหรับทรัพยากรที่เกี่ยวข้องกับ API ฯลฯ

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

การเรียกใช้ `draw(:admin)` ภายในบล็อก `Rails.application.routes.draw` จะพยายามโหลดไฟล์เส้นทางที่มีชื่อเดียวกับอาร์กิวเมนต์ที่กำหนด (`admin.rb` ในตัวอย่างนี้) ไฟล์ต้องอยู่ในไดเรกทอรี `config/routes` หรือในไดเรกทอรีย่อยใดก็ได้ (เช่น `config/routes/admin.rb` หรือ `config/routes/external/admin.rb`)

คุณสามารถใช้ DSL เส้นทางปกติภายในไฟล์เส้นทาง `admin.rb` แต่คุณ **ไม่ควร** ครอบด้วยบล็อก `Rails.application.routes.draw` เหมือนที่คุณทำในไฟล์เส้นทางหลัก `config/routes.rb`
### อย่าใช้คุณลักษณะนี้ นอกจากจำเป็นจริงๆ

การมีไฟล์เส้นทางหลายไฟล์ทำให้การค้นหาและการเข้าใจยากขึ้น สำหรับแอปพลิเคชันส่วนใหญ่ - แม้แต่แอปพลิเคชันที่มีเส้นทางหลายร้อยเส้นทาง - มันง่ายกว่าสำหรับนักพัฒนาที่จะมีไฟล์เส้นทางเดียว ภาษา DSL ของ Rails เส้นทางเสนอวิธีการแยกเส้นทางในลักษณะที่เรียบร้อยด้วย `namespace` และ `scope`


การตรวจสอบและทดสอบเส้นทาง
-----------------------------

Rails มีเครื่องมือให้คุณตรวจสอบและทดสอบเส้นทางของคุณ

### รายการเส้นทางที่มีอยู่

เพื่อให้ได้รายการเส้นทางที่มีอยู่ในแอปพลิเคชันของคุณ ให้ไปที่ <http://localhost:3000/rails/info/routes> ในเบราว์เซอร์ของคุณในขณะที่เซิร์ฟเวอร์ของคุณกำลังทำงานในสภาพแวดล้อม **development** คุณยังสามารถใช้คำสั่ง `bin/rails routes` ในเทอร์มินัลของคุณเพื่อสร้างผลลัพธ์เดียวกัน

ทั้งสองวิธีจะแสดงรายการเส้นทางทั้งหมดของคุณ ในลำดับเดียวกันกับที่พวกเขาปรากฏใน `config/routes.rb` สำหรับแต่ละเส้นทางคุณจะเห็น:

* ชื่อเส้นทาง (ถ้ามี)
* HTTP verb ที่ใช้ (หากเส้นทางไม่ตอบสนองต่อทุก verb)
* รูปแบบ URL เพื่อจับคู่
* พารามิเตอร์ของเส้นทาง

ตัวอย่างเช่นนี่คือส่วนเล็กของผลลัพธ์ `bin/rails routes` สำหรับเส้นทาง RESTful:

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

คุณสามารถค้นหาเส้นทางของคุณด้วยตัวเลือก grep: -g นี้จะแสดงผลเส้นทางใดๆ ที่ตรงกับชื่อเมธอดช่วยเหลือ URL บางส่วน คำกริยา HTTP หรือเส้นทาง URL

```bash
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

หากคุณต้องการเห็นเฉพาะเส้นทางที่แมปไปยังคอนโทรลเลอร์ที่เฉพาะเจาะจง ให้ใช้ตัวเลือก -c

```bash
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

เคล็ดลับ: คุณจะพบว่าผลลัพธ์จาก `bin/rails routes` อ่านง่ายมากขึ้นหากคุณขยายหน้าต่างเทอร์มินัลของคุณจนถึงบรรทัดผลลัพธ์ไม่แบ่ง

### การทดสอบเส้นทาง

เส้นทางควรถูกนำเข้าไปในกลยุทธ์การทดสอบของคุณ (เหมือนกับส่วนที่เหลือของแอปพลิเคชันของคุณ) Rails มีการยืนยันสามอย่างที่ออกแบบมาเพื่อทำให้การทดสอบเส้นทางง่ายขึ้น:

* [`assert_generates`][]
* [`assert_recognizes`][]
* [`assert_routing`][]


#### การยืนยัน `assert_generates`

[`assert_generates`][] ยืนยันว่าชุดเฉพาะของตัวเลือกสร้างเส้นทางที่เฉพาะเจาะจงและสามารถใช้กับเส้นทางเริ่มต้นหรือเส้นทางที่กำหนดเอง ตัวอย่างเช่น:

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### การยืนยัน `assert_recognizes`

[`assert_recognizes`][] เป็นการย้อนกลับของ `assert_generates` มันยืนยันว่าเส้นทางที่กำหนดให้รู้จักและเส้นทางไปยังจุดที่เฉพาะเจาะจงในแอปพลิเคชันของคุณ ตัวอย่างเช่น:
```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

คุณสามารถให้ `:method` argument เพื่อระบุ HTTP verb ได้:

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### การตรวจสอบด้วย `assert_routing`

การตรวจสอบด้วย [`assert_routing`][] จะตรวจสอบเส้นทางทั้งสองทิศทาง: มันทดสอบว่าเส้นทางสร้าง options และ options สร้างเส้นทาง ดังนั้น มันรวมฟังก์ชันของ `assert_generates` และ `assert_recognizes`:

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
