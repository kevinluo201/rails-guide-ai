**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 282c6f5888c41f4c28238cd40bce5aa7
การติดตั้งความขึ้นอยู่กับการพัฒนา Rails Core
==============================================

เอกสารนี้เป็นคู่มือเกี่ยวกับวิธีการตั้งค่าสภาพแวดล้อมสำหรับการพัฒนา Rails Core ด้วย Ruby

หลังจากอ่านเอกสารนี้คุณจะรู้:

* วิธีการตั้งค่าเครื่องของคุณสำหรับการพัฒนา Rails

--------------------------------------------------------------------------------

วิธีการตั้งค่าสภาพแวดล้อมอื่น ๆ
-------------------------------------

หากคุณไม่ต้องการตั้งค่า Rails สำหรับการพัฒนาบนเครื่องของคุณเอง คุณสามารถใช้ Codespaces, VS Code Remote Plugin หรือ rails-dev-box ได้ ดูข้อมูลเพิ่มเติมเกี่ยวกับตัวเลือกเหล่านี้ได้ที่นี่ (contributing_to_ruby_on_rails.html#setting-up-a-development-environment).

การพัฒนาในเครื่องที่ติดตั้ง
-----------------

หากคุณต้องการพัฒนา Ruby on Rails ในเครื่องของคุณเอง ดูขั้นตอนด้านล่าง

### ติดตั้ง Git

Ruby on Rails ใช้ Git สำหรับการควบคุมรหัสซอร์ส คุณสามารถดาวน์โหลด Git ได้ที่ [Git homepage](https://git-scm.com/) มีคำแนะนำในการติดตั้งออนไลน์หลายแห่งที่คุณสามารถศึกษาได้

### คลังรหัสซอร์ส Ruby on Rails

ไปที่โฟลเดอร์ที่คุณต้องการดาวน์โหลดรหัสซอร์ส Ruby on Rails (มันจะสร้างโฟลเดอร์ย่อย `rails` ของตัวเอง) และเรียกใช้:

```bash
$ git clone https://github.com/rails/rails.git
$ cd rails
```

### ติดตั้งเครื่องมือและบริการเพิ่มเติม

บางการทดสอบของ Rails ขึ้นอยู่กับเครื่องมือเพิ่มเติมที่คุณต้องติดตั้งก่อนการเรียกใช้การทดสอบเฉพาะนั้น

นี่คือรายการของเครื่องมือเพิ่มเติมของแต่ละ gem:

* Action Cable ขึ้นอยู่กับ Redis
* Active Record ขึ้นอยู่กับ SQLite3, MySQL และ PostgreSQL
* Active Storage ขึ้นอยู่กับ Yarn (นอกจากนี้ยังขึ้นอยู่กับ Yarn ที่ขึ้นอยู่กับ [Node.js](https://nodejs.org/)), ImageMagick, libvips, FFmpeg, muPDF, Poppler และบน macOS ยังมี XQuartz
* Active Support ขึ้นอยู่กับ memcached และ Redis
* Railties ขึ้นอยู่กับสภาพแวดล้อมการเรียกใช้งาน JavaScript เช่นการติดตั้ง [Node.js](https://nodejs.org/)

ติดตั้งบริการทั้งหมดที่คุณต้องการทดสอบ gem ทั้งหมดที่คุณจะทำการเปลี่ยนแปลง วิธีการติดตั้งบริการเหล่านี้สำหรับ macOS, Ubuntu, Fedora/CentOS, Arch Linux และ FreeBSD อธิบายด้านล่าง

หมายเหตุ: เอกสาร Redis ไม่แนะนำการติดตั้งด้วยตัวจัดการแพคเกจเนื่องจากมักจะเป็นเวอร์ชันเก่า การติดตั้งจากแหล่งที่มาและการเริ่มเซิร์ฟเวอร์เป็นเรื่องง่ายและมีเอกสารอย่างละเอียดใน [เอกสาร Redis](https://redis.io/download#installation)

หมายเหตุ: การทดสอบ Active Record _ต้อง_ ผ่าน MySQL, PostgreSQL และ SQLite3 อย่างน้อย แพทช์ของคุณจะถูกปฏิเสธหากทดสอบกับแอดเพตเดียว ยกเว้นว่าการเปลี่ยนและการทดสอบเป็นเฉพาะกับแอดเพต

ด้านล่างคุณสามารถหาคำแนะนำในการติดตั้งเครื่องมือเพิ่มเติมสำหรับระบบปฏิบัติการต่าง ๆ

#### macOS

ใน macOS คุณสามารถใช้ [Homebrew](https://brew.sh/) เพื่อติดตั้งเครื่องมือเพิ่มเติมทั้งหมด

ในการติดตั้งทั้งหมดให้รัน:

```bash
$ brew bundle
```

คุณจะต้องเริ่มต้นบริการที่ติดตั้งแต่ละรายการ ให้รันคำสั่งนี้เพื่อแสดงรายการบริการทั้งหมด:

```bash
$ brew services list
```

คุณสามารถเริ่มต้นบริการแต่ละรายการได้หนึ่งตัวต่อหนึ่งตัวดังนี้:

```bash
$ brew services start mysql
```

แทน `mysql` ด้วยชื่อของบริการที่คุณต้องการเริ่มต้น

##### ปัญหาที่เป็นไปได้

ส่วนนี้อธิบายปัญหาที่เป็นไปได้บางอย่างที่คุณอาจพบกับส่วนขยายภายในบน macOS โดยเฉพาะเมื่อรวม mysql2 gem ในการพัฒนาในเครื่องท้องถิ่น ข้อมูลเอกสารนี้อาจเปลี่ยนแปลงและอาจไม่ถูกต้องเนื่องจาก Apple ทำการเปลี่ยนแปลงสภาพแวดล้อมนักพัฒนาบน Rails

เพื่อคอมไพล์ gem `mysql2` บน macOS คุณจะต้องมีสิ่งต่อไปนี้:

1. ติดตั้ง `openssl@1.1` (ไม่ใช่ `openssl@3`)
2. Ruby ที่คอมไพล์ด้วย `openssl@1.1`
3. ตั้งค่าตัวแปรสำหรับคอมไพล์ในการกำหนดค่าของ `mysql2`

หากติดตั้งทั้ง `openssl@1.1` และ `openssl@3` คุณจะต้องบอกให้ Ruby ใช้ `openssl@1.1` เพื่อให้ Rails สามารถรวม `mysql2` ได้

ใน `.bash_profile` ของคุณตั้งค่า `PATH` และ `RUBY_CONFIGURE_OPTS` เพื่อชี้ไปที่ `openssl@1.1`:

```
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
```

ใน `~/.bundle/config` ของคุณตั้งค่าต่อไปนี้สำหรับ `mysql2` โปรดแน่ใจว่าคุณลบรายการอื่น ๆ สำหรับ `BUNDLE_BUILD__MYSQL2`:

```
BUNDLE_BUILD__MYSQL2: "--with-ldflags=-L/usr/local/opt/openssl@1.1/lib --with-cppflags=-L/usr/local/opt/openssl@1.1/include"
```

โดยตั้งค่าพวกนี้ก่อนการติดตั้ง Ruby และการรวม Rails คุณควรสามารถใช้งานสภาพแวดล้อมการพัฒนา macOS ในเครื่องของคุณได้

#### Ubuntu

ในการติดตั้งทั้งหมดให้รัน:

```bash
$ sudo apt-get update
$ sudo apt-get install sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils

# ติดตั้ง Yarn
# ใช้คำสั่งนี้หากคุณยังไม่ได้ติดตั้ง Node.js
$ curl --fail --silent --show-error --location https://deb.nodesource.com/setup_18.x | sudo -E bash -
$ sudo apt-get install -y nodejs
# เมื่อคุณติดตั้ง Node.js เสร็จแล้ว ให้ติดตั้งแพ็คเกจ npm ของ yarn
$ sudo npm install --global yarn
```
#### Fedora หรือ CentOS

ในการติดตั้งทั้งหมดให้ใช้คำสั่งต่อไปนี้:

```bash
$ sudo dnf install sqlite-devel sqlite-libs mysql-server mysql-devel postgresql-server postgresql-devel redis memcached imagemagick ffmpeg mupdf libxml2-devel vips poppler-utils

# ติดตั้ง Yarn
# ใช้คำสั่งนี้หากคุณยังไม่ได้ติดตั้ง Node.js
$ curl --silent --location https://rpm.nodesource.com/setup_18.x | sudo bash -
$ sudo dnf install -y nodejs
# เมื่อคุณติดตั้ง Node.js เสร็จสิ้น ให้ติดตั้งแพ็กเกจ npm ของ yarn
$ sudo npm install --global yarn
```

#### Arch Linux

ในการติดตั้งทั้งหมดให้ใช้คำสั่งต่อไปนี้:

```bash
$ sudo pacman -S sqlite mariadb libmariadbclient mariadb-clients postgresql postgresql-libs redis memcached imagemagick ffmpeg mupdf mupdf-tools poppler yarn libxml2 libvips poppler
$ sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
$ sudo systemctl start redis mariadb memcached
```

หมายเหตุ: หากคุณใช้ Arch Linux จะไม่รองรับ MySQL อีกต่อไป ดังนั้นคุณจะต้องใช้ MariaDB แทน (ดู [ประกาศนี้](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)).

#### FreeBSD

ในการติดตั้งทั้งหมดให้ใช้คำสั่งต่อไปนี้:

```bash
$ sudo pkg install sqlite3 mysql80-client mysql80-server postgresql11-client postgresql11-server memcached imagemagick6 ffmpeg mupdf yarn libxml2 vips poppler-utils
# portmaster databases/redis
```

หรือติดตั้งทั้งหมดผ่านทาง ports (แพ็กเกจเหล่านี้จะอยู่ในโฟลเดอร์ `databases`).

หมายเหตุ: หากคุณพบปัญหาในระหว่างการติดตั้ง MySQL โปรดดู [เอกสาร MySQL](https://dev.mysql.com/doc/refman/en/freebsd-installation.html).

#### Debian

ในการติดตั้งทั้งหมดให้ใช้คำสั่งต่อไปนี้:

```bash
$ sudo apt-get install sqlite3 libsqlite3-dev default-mysql-server default-libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils
```

หมายเหตุ: หากคุณใช้ Debian จะใช้ MariaDB เป็นเซิร์ฟเวอร์ MySQL เริ่มต้น ดังนั้นคุณควรทราบว่าอาจมีความแตกต่าง.

### การกำหนดค่าฐานข้อมูล

มีขั้นตอนเพิ่มเติมสำหรับการกำหนดค่าเครื่องมือฐานข้อมูลที่จำเป็นสำหรับการทดสอบ Active Record.

การตรวจสอบสิทธิ์การเข้าถึงของ PostgreSQL ทำงานแตกต่างกัน ในการตั้งค่าสภาพแวดล้อมการพัฒนาด้วยบัญชีการพัฒนาของคุณ บน Linux หรือ BSD คุณเพียงแค่เรียกใช้:

```bash
$ sudo -u postgres createuser --superuser $USER
```

และสำหรับ macOS:

```bash
$ createuser --superuser $USER
```

หมายเหตุ: MySQL จะสร้างผู้ใช้เมื่อสร้างฐานข้อมูล งานนี้ถือว่าผู้ใช้ของคุณคือ `root` โดยไม่มีรหัสผ่าน.

จากนั้นคุณต้องสร้างฐานข้อมูลทดสอบสำหรับ MySQL และ PostgreSQL ด้วยคำสั่ง:

```bash
$ cd activerecord
$ bundle exec rake db:create
```

คุณยังสามารถสร้างฐานข้อมูลทดสอบสำหรับแต่ละเครื่องมือฐานข้อมูลโดยแยกกันได้:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
$ bundle exec rake db:postgresql:build
```

และคุณสามารถลบฐานข้อมูลได้โดยใช้:

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

หมายเหตุ: การใช้งานงาน Rake เพื่อสร้างฐานข้อมูลทดสอบจะตรวจสอบให้แน่ใจว่ามีชุดอักขระและการจัดเรียงที่ถูกต้อง.

หากคุณใช้เครื่องมือฐานข้อมูลอื่น ๆ โปรดตรวจสอบไฟล์ `activerecord/test/config.yml` หรือ `activerecord/test/config.example.yml` เพื่อดูข้อมูลการเชื่อมต่อเริ่มต้น คุณสามารถแก้ไข `activerecord/test/config.yml` เพื่อให้มีข้อมูลรับรองที่แตกต่างกันบนเครื่องของคุณ แต่คุณไม่ควรอัปเดตการเปลี่ยนแปลงเหล่านั้นกลับไปยัง Rails.

### ติดตั้ง JavaScript Dependencies

หากคุณติดตั้ง Yarn คุณจะต้องติดตั้ง JavaScript dependencies ดังนี้:

```bash
$ yarn install
```

### ติดตั้ง Gem Dependencies

Gems จะถูกติดตั้งด้วย [Bundler](https://bundler.io/) ซึ่งจะมาพร้อมกับ Ruby เป็นค่าเริ่มต้น.

ในการติดตั้ง Gemfile สำหรับ Rails ให้ใช้คำสั่งต่อไปนี้:

```bash
$ bundle install
```

หากคุณไม่ต้องการเรียกใช้งาน Active Record tests คุณสามารถใช้คำสั่งต่อไปนี้ได้:

```bash
$ bundle install --without db
```

### สนับสนุน Rails

หลังจากที่คุณตั้งค่าทุกอย่างแล้ว อ่านวิธีการเริ่มต้นการ [สนับสนุน](contributing_to_ruby_on_rails.html#running-an-application-against-your-local-branch).
