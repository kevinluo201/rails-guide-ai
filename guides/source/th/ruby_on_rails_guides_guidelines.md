**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f9c36972ad6f0627da4da84b0067618
คู่มือ Ruby on Rails Guidelines
===============================

คู่มือนี้เอกสารแนวทางสำหรับเขียนคู่มือ Ruby on Rails คู่มือนี้จะตามหลักการของตัวเองในลูปที่สวยงามโดยใช้ตัวอย่างตัวเอง

หลังจากอ่านคู่มือนี้คุณจะรู้:

* เกี่ยวกับกฎและข้อกำหนดที่จะใช้ในเอกสาร Rails
* วิธีการสร้างคู่มือในเครื่องของคุณ

--------------------------------------------------------------------------------

Markdown
-------

คู่มือเขียนด้วย [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown) มีเอกสารอธิบายอย่างละเอียดสำหรับ Markdown และ [cheatsheet](https://daringfireball.net/projects/markdown/basics)

Prologue
--------

แต่ละคู่มือควรเริ่มต้นด้วยข้อความที่มีแรงบันดาลใจด้านบน (นั่นคือการแนะนำเล็กน้อยในพื้นที่สีน้ำเงิน) โปรโลกควรบอกผู้อ่านว่าคู่มือนี้เกี่ยวกับอะไรและว่าพวกเขาจะเรียนรู้อะไร ตัวอย่างเช่นดูที่ [Routing Guide](routing.html)

หัวข้อ
------

ชื่อของทุกคู่มือใช้หัวข้อ `h1` ส่วนคู่มือใช้หัวข้อ `h2` ส่วนย่อยใช้หัวข้อ `h3` ฯลฯ โปรดทราบว่าผลลัพธ์ HTML ที่สร้างขึ้นจะใช้แท็กหัวข้อเริ่มต้นด้วย `<h2>`

```markdown
Guide Title
===========

Section
-------

### Sub Section
```

เมื่อเขียนหัวข้อให้เรียงตามลำดับทั้งหมดยกเว้นคำบุพบท คำเชื่อม คำบุพบทภายในและรูปแบบของคำกริยา "to be":

```markdown
#### Assertions and Testing Jobs inside Components
#### Middleware Stack is an Array
#### When are Objects Saved?
```

ใช้การจัดรูปแบบเดียวกับข้อความปกติ:

```markdown
##### The `:content_type` Option
```

การเชื่อมโยงไปยัง API
------------------

ลิงก์ไปยัง API (`api.rubyonrails.org`) จะถูกประมวลผลโดยตัวสร้างคู่มือในลักษณะต่อไปนี้:

ลิงก์ที่รวมแท็กการเผยแพร่จะไม่เปลี่ยนแปลง เช่น

```
https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

จะไม่ถูกแก้ไข

โปรดใช้ในบันทึกการเผยแพร่เนื่องจากจะต้องชี้ไปที่รุ่นที่เกี่ยวข้องไม่ว่าจะเป็นเป้าหมายใด

หากลิงก์ไม่รวมแท็กการเผยแพร่และกำลังสร้างคู่มือเวอร์ชันล่าสุด โดเมนจะถูกแทนที่ด้วย `edgeapi.rubyonrails.org` เช่น

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

กลายเป็น

```
https://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

หากลิงก์ไม่รวมแท็กการเผยแพร่และกำลังสร้างคู่มือเวอร์ชันการเผยแพร่ รุ่น Rails จะถูกฉีดเข้าไป เช่นหากเรากำลังสร้างคู่มือสำหรับ v5.1.0 ลิงก์

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

กลายเป็น

```
https://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

โปรดอย่าเชื่อมโยงไปยัง `edgeapi.rubyonrails.org` ด้วยตนเอง

แนวทางเอกสาร API
----------------------------

คู่มือและ API ควรสอดคล้องและสอดคล้องกันในส่วนที่เหมาะสม โดยเฉพาะส่วนเหล่านี้ของ [แนวทางเอกสาร API](api_documentation_guidelines.html) ก็เป็นไปในทางเดียวกัน:

* [Wording](api_documentation_guidelines.html#wording)
* [English](api_documentation_guidelines.html#english)
* [Example Code](api_documentation_guidelines.html#example-code)
* [Filenames](api_documentation_guidelines.html#file-names)
* [Fonts](api_documentation_guidelines.html#fonts)

คู่มือ HTML
-----------

ก่อนที่จะสร้างคู่มือ โปรดตรวจสอบว่าคุณมี Bundler เวอร์ชันล่าสุดติดตั้งในระบบของคุณ ในการติดตั้ง Bundler เวอร์ชันล่าสุดให้ใช้คำสั่ง `gem install bundler`

หากคุณมี Bundler ติดตั้งแล้ว คุณสามารถอัปเดตได้โดยใช้ `gem update bundler`

### การสร้าง

ในการสร้างคู่มือทั้งหมด เพียงแค่เข้าไปในไดเรกทอรี `guides` รันคำสั่ง `bundle install` และรัน:

```bash
$ bundle exec rake guides:generate
```

หรือ

```bash
$ bundle exec rake guides:generate:html
```

ไฟล์ HTML ที่ได้จะอยู่ในไดเรกทอรี `./output`

หากต้องการประมวลผล `my_guide.md` เท่านั้นให้ใช้ตัวแปรสภาพแวดล้อม `ONLY`:

```bash
$ touch my_guide.md
$ bundle exec rake guides:generate ONLY=my_guide
```

โดยค่าเริ่มต้นคู่มือที่ไม่ได้ถูกแก้ไขจะไม่ถูกประมวลผล ดังนั้น `ONLY` ไม่จำเป็นต้องใช้ในการปฏิบัติจริง

หากต้องการบังคับให้ประมวลผลคู่มือทั้งหมดให้ใช้ `ALL=1`

หากคุณต้องการสร้างคู่มือในภาษาอื่นนอกเหนือจากภาษาอังกฤษ คุณสามารถเก็บไว้ในไดเรกทอรีย่อยภายใต้ `source` (เช่น `source/es`) และใช้ตัวแปรสภาพแวดล้อม `GUIDES_LANGUAGE`:

```bash
$ bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

หากคุณต้องการดูตัวแปรสภาพแวดล้อมทั้งหมดที่คุณสามารถใช้กำหนดค่าสคริปต์การสร้างเพียงรัน:

```bash
$ rake
```

### การตรวจสอบความถูกต้อง

โปรดตรวจสอบ HTML ที่สร้างขึ้นด้วย:

```bash
$ bundle exec rake guides:validate
```

โดยเฉพาะอย่างยิ่ง ชื่อเรื่องจะได้รับการสร้าง ID จากเนื้อหาของมันและส่วนใหญ่นี้จะทำให้ซ้ำกัน

คู่มือ Kindle
-------------

### การสร้าง

ในการสร้างคู่มือสำหรับ Kindle ให้ใช้งาน rake task ต่อไปนี้:

```bash
$ bundle exec rake guides:generate:kindle
```
