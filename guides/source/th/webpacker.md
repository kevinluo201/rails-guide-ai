**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 148ef2d23e16b9e0df83b14e98526736
Webpacker
=========

คู่มือนี้จะแสดงวิธีการติดตั้งและใช้งาน Webpacker เพื่อแพ็คเกจ JavaScript, CSS และแอสเซ็ตอื่น ๆ สำหรับฝั่งไคลเอ็นต์ของแอปพลิเคชัน Rails ของคุณ แต่โปรดทราบว่า [Webpacker ถูกเลิกใช้งานแล้ว](https://github.com/rails/webpacker#webpacker-has-been-retired-)

หลังจากอ่านคู่มือนี้คุณจะรู้:

* Webpacker ทำอะไรและทำไมมันแตกต่างจาก Sprockets
* วิธีการติดตั้ง Webpacker และผสานมันกับเฟรมเวิร์กของคุณ
* วิธีใช้ Webpacker สำหรับแอสเซ็ต JavaScript
* วิธีใช้ Webpacker สำหรับแอสเซ็ต CSS
* วิธีใช้ Webpacker สำหรับแอสเซ็ตแบบสถิต
* วิธีการติดตั้งเว็บไซต์ที่ใช้งาน Webpacker
* วิธีใช้ Webpacker ในบริบท Rails ที่แตกต่าง เช่น เอ็นจินหรือคอนเทนเนอร์ Docker

-------------------------------------------------- ------------

Webpacker คืออะไร?
------------------

Webpacker เป็นการห่อหุ้ม Rails รอบ webpack ระบบสร้างที่ให้การกำหนดค่า webpack มาตรฐานและค่าเริ่มต้นที่เหมาะสม

### Webpack คืออะไร?

เป้าหมายของ webpack หรือระบบสร้างฝั่งหน้าใด ๆ คืออนุญาตให้คุณเขียนโค้ดฝั่งหน้าของคุณในวิธีที่สะดวกสำหรับนักพัฒนาแล้วแพ็คเกจโค้ดนั้นในวิธีที่สะดวกสำหรับเบราว์เซอร์ ด้วย webpack คุณสามารถจัดการ JavaScript, CSS และแอสเซ็ตแบบสถิต เช่น รูปภาพหรือแบบอักษร การใช้งาน webpack จะช่วยให้คุณเขียนโค้ดของคุณ อ้างอิงโค้ดอื่นในแอปพลิเคชันของคุณ แปลงรูปแบบโค้ดของคุณ และรวมโค้ดของคุณเข้าด้วยกันเป็นแพ็คที่สามารถดาวน์โหลดได้ง่าย

ดู [เอกสาร webpack](https://webpack.js.org) สำหรับข้อมูลเพิ่มเติม

### Webpacker แตกต่างจาก Sprockets อย่างไร?

Rails ยังมี Sprockets ซึ่งเป็นเครื่องมือการแพ็คแอสเซ็ตที่มีคุณสมบัติที่ซ้อนทับกันกับ Webpacker ทั้งสองเครื่องมือจะคอมไพล์ JavaScript ของคุณเป็นไฟล์ที่เหมาะสำหรับเบราว์เซอร์และย่อขนาดและสร้างรหัสลายนิ้วในการใช้งานจริง ในสภาวะการพัฒนา Sprockets และ Webpacker ช่วยให้คุณเปลี่ยนแปลงไฟล์ได้เป็นลำดับ

Sprockets ซึ่งออกแบบมาใช้กับ Rails มีความเรียบง่ายกว่าในการรวมเข้ากัน โดยเฉพาะอย่างยิ่งโค้ดสามารถเพิ่มเข้าไปใน Sprockets ผ่าน gem ของ Ruby อย่างไรก็ตาม webpack ดีกว่าในการรวมกับเครื่องมือ JavaScript และแพ็คเกจ NPM ที่ให้ความสามารถที่หลากหลายมากขึ้นและอนุญาตให้รวมเข้ากับอะไรก็ได้ แอป Rails ใหม่ถูกกำหนดให้ใช้ webpack สำหรับ JavaScript และ Sprockets สำหรับ CSS แต่คุณสามารถทำ CSS ใน webpack ได้

คุณควรเลือก Webpacker แทน Sprockets ในโปรเจคใหม่หากคุณต้องการใช้แพ็คเกจ NPM และ / หรือต้องการเข้าถึงคุณลักษณะและเครื่องมือ JavaScript ที่เป็นปัจจุบันที่สุด คุณควรเลือก Sprockets แทน Webpacker สำหรับแอปพลิเคชันเก่าที่การย้ายอาจเป็นที่สูง หากคุณต้องการรวมเข้ากับ Gems หรือหากคุณมีจำนวนโค้ดที่น้อยมากที่จะแพ็คเกจ

หากคุณคุ้นเคยกับ Sprockets คู่มือต่อไปนี้อาจให้คุณความคิดเห็นเกี่ยวกับวิธีการแปลง โปรดทราบว่าแต่ละเครื่องมือมีโครงสร้างที่แตกต่างกันเล็กน้อยและแนวความคิดไม่สามารถแมปโดยตรงกับกันได้

| งาน | Sprockets | Webpacker |
| ---------------- - | ---------------------- - | ------------------- |
| แนบ JavaScript | javascript_include_tag | javascript_pack_tag |
| แนบ CSS | stylesheet_link_tag | stylesheet_pack_tag |
| เชื่อมโยงไปยังรูปภาพ | image_url | image_pack_tag |
| เชื่อมโยงไปยังแอสเซ็ต | asset_url | asset_pack_tag |
| ต้องการสคริปต์ | //= ต้องการ | นำเข้าหรือต้องการ |

การติดตั้ง Webpacker
--------------------

ในการใช้งาน Webpacker คุณต้องติดตั้งตัวจัดการแพ็คเกจ Yarn เวอร์ชัน 1.x หรือสูงกว่า และคุณต้องมี Node.js ติดตั้งเวอร์ชัน 10.13.0 ขึ้นไป
หมายเหตุ: Webpacker ขึ้นอยู่กับ NPM และ Yarn โดย NPM เป็นที่เก็บข้อมูลหลักสำหรับการเผยแพร่และดาวน์โหลดโปรเจค JavaScript โอเพนซอร์สทั้งสำหรับ Node.js และรันไทม์ในเบราว์เซอร์ มันเปรียบเสมือนกับ rubygems.org สำหรับ Ruby gems ส่วน Yarn เป็นเครื่องมือคอมมานด์ไลน์ที่ช่วยให้สามารถติดตั้งและจัดการกับการขึ้นอยู่ของ JavaScript ได้เช่นเดียวกับ Bundler สำหรับ Ruby

ในการรวม Webpacker เข้ากับโปรเจคใหม่ ให้เพิ่ม `--webpack` ในคำสั่ง `rails new` ในการเพิ่ม Webpacker เข้ากับโปรเจคที่มีอยู่แล้ว ให้เพิ่ม gem `webpacker` เข้าไปใน `Gemfile` ของโปรเจค แล้วรัน `bundle install` และตามด้วย `bin/rails webpacker:install`

การติดตั้ง Webpacker จะสร้างไฟล์ท้องถิ่นต่อไปนี้:

|ไฟล์                   |ตำแหน่ง                |คำอธิบาย                                                                                         |
|------------------------|------------------------|----------------------------------------------------------------------------------------------------|
|โฟลเดอร์ JavaScript       | `app/javascript`       |สำหรับแหล่งที่มาของฟรอนต์เอนด์ของคุณ                                                                   |
|การกำหนดค่า Webpacker | `config/webpacker.yml` |กำหนดค่า gem Webpacker                                                                         |
|การกำหนดค่า Babel     | `babel.config.js`      |การกำหนดค่าสำหรับ [Babel](https://babeljs.io) คอมไพล์เลอร์ของ JavaScript                               |
|การกำหนดค่า PostCSS   | `postcss.config.js`    |การกำหนดค่าสำหรับ [PostCSS](https://postcss.org) CSS Post-Processor                             |
|Browserlist             | `.browserslistrc`      |[Browserlist](https://github.com/browserslist/browserslist) จัดการการกำหนดค่าเบราว์เซอร์เป้าหมาย   |


การติดตั้งยังเรียกใช้ตัวจัดการแพคเกจ `yarn` สร้างไฟล์ `package.json` พร้อมกับรายการแพคเกจพื้นฐานและใช้ Yarn เพื่อติดตั้งแพคเกจเหล่านี้

การใช้งาน
-----

### การใช้งาน Webpacker สำหรับ JavaScript

เมื่อติดตั้ง Webpacker แล้ว ไฟล์ JavaScript ใดๆ ในไดเรกทอรี `app/javascript/packs` จะถูกคอมไพล์เป็นแพคไฟล์ของตัวเองตามค่าเริ่มต้น

ดังนั้นหากคุณมีไฟล์ชื่อ `app/javascript/packs/application.js` Webpacker จะสร้างแพคที่ชื่อ `application` และคุณสามารถเพิ่มไปยังแอปพลิเคชัน Rails ของคุณด้วยโค้ด `<%= javascript_pack_tag "application" %>` โดยที่ในโหมดการพัฒนา Rails จะคอมไพล์ไฟล์ `application.js` ทุกครั้งที่มีการเปลี่ยนแปลง และคุณโหลดหน้าที่ใช้แพคนั้น โดยทั่วไปไฟล์ในไดเรกทอรี `packs` จะเป็นแมนิเฟสต์ที่โหลดไฟล์อื่นๆ แต่ก็สามารถมีโค้ด JavaScript อื่นๆ ได้

แพคที่ถูกสร้างขึ้นโดย Webpacker จะเชื่อมโยงไปยังแพคเกจ JavaScript เริ่มต้นของ Rails หากได้รับการรวมเข้ากับโปรเจค:

```javascript
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

คุณจะต้องเพิ่มแพคที่ต้องการใช้งานแพคเกจเหล่านี้ในแอปพลิเคชัน Rails ของคุณ

สำคัญที่จะทราบว่าเฉพาะไฟล์เริ่มต้นของ webpack ควรวางไว้ในไดเรกทอรี `app/javascript/packs` เท่านั้น โดย Webpack จะสร้างกราฟขึ้นอย่างแยกต่างหากสำหรับแต่ละจุดเริ่มต้น ดังนั้นหากมีจำนวนแพคมากๆ จะทำให้การคอมไพล์ช้าลง ส่วนส่วนที่เหลือของโค้ดของคุณควรอยู่นอกไดเรกทอรีนี้ แม้ว่า Webpacker จะไม่มีข้อจำกัดหรือข้อเสนอแนะใดๆ เกี่ยวกับวิธีการโครงสร้างโค้ดของคุณ ตัวอย่างเช่น:

```sh
app/javascript:
  ├── packs:
  │   # เฉพาะไฟล์เริ่มต้นของ webpack ที่นี่เท่านั้น
  │   └── application.js
  │   └── application.css
  └── src:
  │   └── my_component.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

โดยทั่วไปแล้วแพคไฟล์เองเป็นแมนิเฟสต์ที่ใช้ `import` หรือ `require` เพื่อโหลดไฟล์ที่จำเป็นและอาจมีการเริ่มต้นบางอย่าง

หากคุณต้องการเปลี่ยนไดเรกทอรีเหล่านี้ คุณสามารถปรับแต่ง `source_path` (ค่าเริ่มต้น `app/javascript`) และ `source_entry_path` (ค่าเริ่มต้น `packs`) ในไฟล์ `config/webpacker.yml` ได้
ในไฟล์ต้นฉบับ `import` จะถูกแก้ไขตามที่ไฟล์ที่ทำการ import อยู่ ดังนั้น `import Bar from "./foo"` จะค้นหาไฟล์ `foo.js` ในโฟลเดอร์เดียวกับไฟล์ปัจจุบัน ในขณะที่ `import Bar from "../src/foo"` จะค้นหาไฟล์ในโฟลเดอร์พี่น้องที่ชื่อ `src`.

### การใช้งาน Webpacker สำหรับ CSS

Webpacker สนับสนุน CSS และ SCSS โดยใช้ตัวประมวลผล PostCSS มาให้พร้อมใช้งาน

ในการรวมรหัส CSS เข้ากับแพ็คของคุณ ให้เริ่มต้นด้วยการรวมไฟล์ CSS ในแพคไฟล์ระดับบนสุดเหมือนกับไฟล์ JavaScript ดังนั้นหากไฟล์แพคระดับบนสุดของ CSS อยู่ที่ `app/javascript/styles/styles.scss` คุณสามารถ import ไฟล์นั้นด้วย `import styles/styles` นี่จะบอก webpack ให้รวมไฟล์ CSS เข้ากับการดาวน์โหลด ในการโหลดไฟล์ CSS ในหน้าเว็บ ให้รวม `<%= stylesheet_pack_tag "application" %>` ในหน้าแสดงผล โดยที่ `application` เป็นชื่อแพคเดียวกันที่คุณใช้

หากคุณใช้ CSS framework คุณสามารถเพิ่มมันเข้ากับ Webpacker ได้โดยทำตามคำแนะนำในการโหลด framework เป็นโมดูล NPM โดยใช้ `yarn` โดยปกติ `yarn add <framework>` โครงสร้างของ framework ควรมีคำแนะนำในการ import ลงในไฟล์ CSS หรือ SCSS

### การใช้งาน Webpacker สำหรับสิ่งที่แนบมาด้วย

ค่าเริ่มต้นของ Webpacker [การกำหนดค่า](https://github.com/rails/webpacker/blob/master/lib/install/config/webpacker.yml#L21) ควรทำงานได้โดยไม่ต้องปรับแต่งสำหรับสิ่งที่แนบมาด้วย
การกำหนดค่ารวมถึงส่วนขยายของไฟล์รูปภาพและแบบอักษร ทำให้ webpack สามารถรวมมันเข้ากับไฟล์ `manifest.json` ที่สร้างขึ้น

ด้วย webpack สิ่งที่แนบมาด้วยสามารถ import โดยตรงในไฟล์ JavaScript ได้ ค่าที่ import มาจะแทนที่ URL ของสิ่งที่แนบมา ตัวอย่างเช่น:

```javascript
import myImageUrl from '../images/my-image.jpg'

// ...
let myImage = new Image();
myImage.src = myImageUrl;
myImage.alt = "I'm a Webpacker-bundled image";
document.body.appendChild(myImage);
```

หากคุณต้องการอ้างอิงสิ่งที่แนบมาด้วยจาก Rails view คุณจำเป็นต้องระบุการต้องการสิ่งที่แนบมาด้วยจากไฟล์ JavaScript ที่ถูกแนบมาด้วย Webpacker ไม่เหมือน Sprockets ที่ import สิ่งที่แนบมาให้โดยอัตโนมัติ Webpacker ไม่ได้ทำการ import สิ่งที่แนบมาให้โดยค่าเริ่มต้น ไฟล์ `app/javascript/packs/application.js` มีเทมเพลตสำหรับการ import ไฟล์จากโฟลเดอร์ที่กำหนด คุณสามารถยกเลิกคอมเมนต์สำหรับทุกโฟลเดอร์ที่คุณต้องการให้มีไฟล์แนบมา โดยที่โฟลเดอร์เหล่านั้นเป็นโฟลเดอร์ที่เกี่ยวข้องกับ `app/javascript` เทมเพลตใช้โฟลเดอร์ `images` แต่คุณสามารถใช้ใดก็ได้ใน `app/javascript`:

```javascript
const images = require.context("../images", true)
const imagePath = name => images(name, true)
```

สิ่งที่แนบมาจะถูกส่งออกไปยังโฟลเดอร์ใต้ `public/packs/media` ตัวอย่างเช่น รูปภาพที่อยู่และถูก import มาที่ `app/javascript/images/my-image.jpg` จะถูกส่งออกที่ `public/packs/media/images/my-image-abcd1234.jpg` ในการสร้างแท็กรูปภาพสำหรับรูปภาพนี้ใน Rails view ให้ใช้ `image_pack_tag 'media/images/my-image.jpg`.

WebPack ActionView helpers สำหรับสิ่งที่แนบมาตรงกับ asset pipeline helpers ตามตารางต่อไปนี้:

|ActionView helper | Webpacker helper |
|------------------|------------------|
|favicon_link_tag  |favicon_pack_tag  |
|image_tag         |image_pack_tag    |

นอกจากนี้ ช่วยเหลือทั่วไป `asset_pack_path` จะใช้ตำแหน่งท้องถิ่นของไฟล์และส่งคืนตำแหน่ง Webpacker สำหรับใช้ใน Rails view

คุณยังสามารถเข้าถึงรูปภาพโดยอ้างอิงไฟล์โดยตรงจากไฟล์ CSS ใน `app/javascript`.

### Webpacker ใน Rails Engines

ตั้งแต่เวอร์ชัน 6 ของ Webpacker เริ่มต้นไม่รองรับการใช้งานใน Rails engines
ผู้เขียน Gem ของ Rails engines ที่ต้องการสนับสนุนผู้ใช้งานที่ใช้ Webpacker แนะนำให้แจกแจง frontend assets เป็นแพคเกจ NPM นอกเหนือจาก gem ตัวเองและให้คำแนะนำ (หรือติดตั้ง) เพื่อแสดงให้เห็นวิธีการผสานกับแอปฯโฮสต์ ตัวอย่างที่ดีของวิธีการนี้คือ [Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms).

### Hot Module Replacement (HMR)

Webpacker รองรับ HMR ด้วย webpack-dev-server และคุณสามารถเปิด-ปิดได้โดยตั้งค่า dev_server/hmr ภายใน `webpacker.yml`.

ดูเอกสาร [webpack สำหรับ DevServer](https://webpack.js.org/configuration/dev-server/#devserver-hot) เพื่อข้อมูลเพิ่มเติม

ในการสนับสนุน HMR กับ React คุณจะต้องเพิ่ม react-hot-loader ดูเอกสาร [React Hot Loader's _Getting Started_ guide](https://gaearon.github.io/react-hot-loader/getstarted/).

อย่าลืมปิดใช้งาน HMR หากคุณไม่ได้รัน webpack-dev-server มิฉะนั้นคุณจะได้รับข้อผิดพลาด "not found error" สำหรับ stylesheets.

Webpacker ในสภาพแวดล้อมที่แตกต่างกัน
-----------------------------------

Webpacker มีสามสภาพแวดล้อมตามค่าเริ่มต้น `development`, `test`, และ `production`. คุณสามารถเพิ่มการกำหนดค่าสภาพแวดล้อมเพิ่มเติมในไฟล์ `webpacker.yml` และตั้งค่าเริ่มต้นที่แตกต่างกันสำหรับแต่ละสภาพแวดล้อม. Webpacker ยังจะโหลดไฟล์ `config/webpack/<environment>.js` เพื่อการตั้งค่าสภาพแวดล้อมเพิ่มเติม.

## การรัน Webpacker ในสภาพแวดล้อมการพัฒนา

Webpacker มาพร้อมกับไฟล์ binstub สองไฟล์สำหรับการรันในสภาพแวดล้อมการพัฒนา: `./bin/webpack` และ `./bin/webpack-dev-server`. ทั้งสองเป็นตัวครอบบางส่วนของ `webpack.js` และ `webpack-dev-server.js` และตรวจสอบให้แน่ใจว่าไฟล์การกำหนดค่าและตัวแปรสภาพแวดล้อมถูกโหลดตามสภาพแวดล้อมของคุณ.

ตามค่าเริ่มต้น Webpacker จะคอมไพล์โดยอัตโนมัติตามคำขอในการโหลดหน้า Rails ในสภาพแวดล้อมการพัฒนา. นั่นหมายความว่าคุณไม่ต้องรันกระบวนการแยกต่างหากและข้อผิดพลาดในการคอมไพล์จะถูกบันทึกลงในบันทึกมาตรฐานของ Rails. คุณสามารถเปลี่ยนการตั้งค่านี้โดยเปลี่ยนเป็น `compile: false` ในไฟล์ `config/webpacker.yml`. การรัน `bin/webpack` จะบังคับให้คอมไพล์ packs ของคุณ.

หากคุณต้องการใช้การโหลดโค้ดแบบสดหรือมี JavaScript มากพอที่การคอมไพล์ตามคำขอจะช้าเกินไป คุณจะต้องรัน `./bin/webpack-dev-server` หรือ `ruby ./bin/webpack-dev-server`. กระบวนการนี้จะตรวจสอบการเปลี่ยนแปลงในไฟล์ `app/javascript/packs/*.js` และคอมไพล์ใหม่และโหลดหน้าเว็บใหม่โดยอัตโนมัติ.

ผู้ใช้ Windows จะต้องรันคำสั่งเหล่านี้ในเทอร์มินอักขระที่แยกต่างหากจาก `bundle exec rails server`.

เมื่อคุณเริ่มเซิร์ฟเวอร์การพัฒนานี้ Webpacker จะเริ่มโปรกซีทุกคำขอทรัพยากร webpack ไปยังเซิร์ฟเวอร์นี้. เมื่อคุณหยุดเซิร์ฟเวอร์ การคอมไพล์จะกลับมาเป็นการคอมไพล์ตามคำขอ.

เอกสาร [Webpacker Documentation](https://github.com/rails/webpacker) ให้ข้อมูลเกี่ยวกับตัวแปรสภาพแวดล้อมที่คุณสามารถใช้เพื่อควบคุม `webpack-dev-server`. ดูหมายเหตุเพิ่มเติมใน [rails/webpacker docs on the webpack-dev-server usage](https://github.com/rails/webpacker#development).

### การนำ Webpacker ไปใช้งาน

Webpacker เพิ่มงาน `webpacker:compile` เข้าไปในงาน `bin/rails assets:precompile` ดังนั้นกระบวนการการนำไปใช้งานที่มีอยู่ใด ๆ ที่ใช้ `assets:precompile` ควรทำงานได้. งานการคอมไพล์จะคอมไพล์ packs และวางไว้ใน `public/packs`.

เอกสารเพิ่มเติม
------------------------

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับหัวข้อขั้นสูง เช่นการใช้ Webpacker กับเฟรมเวิร์กที่นิยม โปรดเรียกดู [Webpacker Documentation](https://github.com/rails/webpacker).
