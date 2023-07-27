**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 282c6f5888c41f4c28238cd40bce5aa7
Įdiegiant "Rails Core" plėtros priklausomybes
==============================================

Šiame vadove aprašoma, kaip sukurti aplinką "Ruby on Rails" pagrindinės plėtros priklausomybėms.

Po šio vadovo perskaitymo jūs žinosite:

* Kaip sukonfigūruoti savo mašiną "Rails" plėtrai

--------------------------------------------------------------------------------

Kiti būdai sukonfigūruoti aplinką
--------------------------------

Jei nenorite sukonfigūruoti "Rails" plėtros savo vietinėje mašinoje, galite naudoti "Codespaces", "VS Code Remote Plugin" arba "rails-dev-box". Sužinokite daugiau apie šias galimybes [čia](contributing_to_ruby_on_rails.html#setting-up-a-development-environment).

Vietinė plėtra
--------------

Jei norite plėtoti "Ruby on Rails" vietinėje mašinoje, žr. žemiau pateiktus žingsnius.

### Įdiegti Git

"Ruby on Rails" naudoja "Git" šaltinio kodo kontrolės priemonę. [Git pagrindinis puslapis](https://git-scm.com/) turi diegimo instrukcijas. Yra įvairių interneto išteklių, kurie padės jums susipažinti su "Git".

### Klonuoti "Ruby on Rails" saugyklą

Eikite į aplanką, kuriame norite atsisiųsti "Ruby on Rails" šaltinio kodą (jis sukurs savo "rails" poaplankį) ir paleiskite:

```bash
$ git clone https://github.com/rails/rails.git
$ cd rails
```

### Įdiegti papildomas priemones ir paslaugas

Kai kurie "Rails" testai priklauso nuo papildomų priemonių, kurias reikia įdiegti prieš paleidžiant tuos konkretūs testus.

Čia pateikiamas kiekvienos gemo papildomų priklausomybių sąrašas:

* "Action Cable" priklauso nuo "Redis"
* "Active Record" priklauso nuo "SQLite3", "MySQL" ir "PostgreSQL"
* "Active Storage" priklauso nuo "Yarn" (papildomai "Yarn" priklauso nuo
  [Node.js](https://nodejs.org/)), "ImageMagick", "libvips", "FFmpeg", "muPDF",
  "Poppler" ir "macOS" taip pat nuo "XQuartz".
* "Active Support" priklauso nuo "memcached" ir "Redis"
* "Railties" priklauso nuo JavaScript vykdymo aplinkos, pvz., turėti
  įdiegtą [Node.js](https://nodejs.org/).

Įdiekite visas paslaugas, kurias reikia tinkamai išbandyti visą jūsų kurtą gemą. Kaip įdiegti šias paslaugas "macOS", "Ubuntu", "Fedora/CentOS",
"Arch Linux" ir "FreeBSD" yra išsamiai aprašyta žemiau.

PASTABA: "Redis" dokumentacija nerekomenduoja naudoti paketų tvarkytuvų, nes jie dažniausiai yra pasenusi. Įdiegimas iš šaltinio ir serverio paleidimas yra paprasti ir gerai aprašyti [Redis dokumentacijoje](https://redis.io/download#installation).

PASTABA: "Active Record" testai _turi_ sėkmingai baigtis bent jau su "MySQL", "PostgreSQL" ir "SQLite3". Jūsų pakeitimas bus atmestas, jei jis bus išbandytas tik su vienu adapteriu, nebent pakeitimas ir testai yra skirti konkrečiam adapteriui.

Žemiau pateikiamos instrukcijos, kaip įdiegti visus papildomus įrankius skirtingoms operacinėms sistemoms.

#### "macOS"

"macOS" galite naudoti [Homebrew](https://brew.sh/), kad įdiegtumėte visus papildomus įrankius.

Norėdami įdiegti visus, paleiskite:

```bash
$ brew bundle
```

Jums taip pat reikės paleisti kiekvieną įdiegtą paslaugą. Norėdami pamatyti visų
galimų paslaugų sąrašą, paleiskite:

```bash
$ brew services list
```

Tada galite paleisti kiekvieną paslaugą atskirai taip:

```bash
$ brew services start mysql
```

Pakeiskite `mysql` į norimos paleisti paslaugos pavadinimą.

##### Galimos problemos

Šiame skyriuje aprašomos galimos problemos, su kuriomis galite susidurti naudodami natyvias plėtinius "macOS", ypač kai diegiate "mysql2" gemą vietinėje plėtroje. Ši dokumentacija gali keistis ir gali būti neteisinga, kai "Apple" keičia plėtros aplinką "Rails".

Norėdami sukompiliuoti "mysql2" gemą "macOS", jums reikės šių dalykų:

1. Įdiegtas `openssl@1.1` (ne `openssl@3`)
2. "Ruby" sukonfigūruotas su `openssl@1.1`
3. Nustatyti kompiliatoriaus vėliavas "mysql2" paketo konfigūracijai.

Jei įdiegti abu `openssl@1.1` ir `openssl@3`, turėsite pranešti "Ruby", kad naudotų `openssl@1.1`, kad "Rails" galėtų įtraukti "mysql2".

Savo `.bash_profile` faile nustatykite `PATH` ir `RUBY_CONFIGURE_OPTS`, kad rodytų į `openssl@1.1`:

```
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
```

Savo `~/.bundle/config` faile nustatykite šiuos parametrus "mysql2". Įsitikinkite, kad ištrinate bet kokius kitus įrašus, susijusius su `BUNDLE_BUILD__MYSQL2`:

```
BUNDLE_BUILD__MYSQL2: "--with-ldflags=-L/usr/local/opt/openssl@1.1/lib --with-cppflags=-L/usr/local/opt/openssl@1.1/include"
```

Nustatę šias vėliavas prieš diegiant "Ruby" ir įtraukiant "Rails", turėtumėte galėti paleisti savo vietinę "macOS" plėtros aplinką.

#### "Ubuntu"

Norėdami įdiegti visus, paleiskite:

```bash
$ sudo apt-get update
$ sudo apt-get install sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils

# Įdiegti "Yarn"
# Naudokite šią komandą, jei neturite "Node.js" įdiegto
$ curl --fail --silent --show-error --location https://deb.nodesource.com/setup_18.x | sudo -E bash -
$ sudo apt-get install -y nodejs
# Kai jau įdiegėte "Node.js", įdiekite "yarn" npm paketą
$ sudo npm install --global yarn
```
#### Fedora arba CentOS

Norint įdiegti viską, įvykdykite šias komandas:

```bash
$ sudo dnf install sqlite-devel sqlite-libs mysql-server mysql-devel postgresql-server postgresql-devel redis memcached imagemagick ffmpeg mupdf libxml2-devel vips poppler-utils

# Įdiekite Yarn
# Jei neturite įdiegto Node.js
$ curl --silent --location https://rpm.nodesource.com/setup_18.x | sudo bash -
$ sudo dnf install -y nodejs
# Kai įdiegėte Node.js, įdiekite yarn npm paketą
$ sudo npm install --global yarn
```

#### Arch Linux

Norint įdiegti viską, įvykdykite šias komandas:

```bash
$ sudo pacman -S sqlite mariadb libmariadbclient mariadb-clients postgresql postgresql-libs redis memcached imagemagick ffmpeg mupdf mupdf-tools poppler yarn libxml2 libvips poppler
$ sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
$ sudo systemctl start redis mariadb memcached
```

PASTABA: Jei naudojate Arch Linux, MySQL nebepalaikoma, todėl turėsite naudoti MariaDB (žr. [šį pranešimą](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)).

#### FreeBSD

Norint įdiegti viską, įvykdykite šias komandas:

```bash
$ sudo pkg install sqlite3 mysql80-client mysql80-server postgresql11-client postgresql11-server memcached imagemagick6 ffmpeg mupdf yarn libxml2 vips poppler-utils
# portmaster databases/redis
```

Arba įdiekite viską per ports (šie paketai yra rasti `databases` aplanke).

PASTABA: Jei įvyksta problemų diegiant MySQL, žr. [MySQL dokumentaciją](https://dev.mysql.com/doc/refman/en/freebsd-installation.html).

#### Debian

Norint įdiegti visus priklausomybes, įvykdykite šią komandą:

```bash
$ sudo apt-get install sqlite3 libsqlite3-dev default-mysql-server default-libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils
```

PASTABA: Jei naudojate Debian, MariaDB yra numatytasis MySQL serveris, todėl gali būti skirtumų.

### Duomenų bazės konfigūracija

Yra keletas papildomų žingsnių, reikalingų konfigūruojant duomenų bazių variklius, kurie reikalingi veikiančių Active Record testų vykdymui.

PostgreSQL autentifikacija veikia kitaip. Norint sukonfigūruoti vystymo aplinką su savo vystymo paskyra, Linux ar BSD, tiesiog įvykdykite:

```bash
$ sudo -u postgres createuser --superuser $USER
```

ir macOS:

```bash
$ createuser --superuser $USER
```

PASTABA: MySQL sukurs naudotojus, kai bus sukuriamos duomenų bazės. Užduotis numato, kad jūsų naudotojas yra `root` be slaptažodžio.

Tada, sukurkite testavimo duomenų bazes tiek MySQL, tiek PostgreSQL su:

```bash
$ cd activerecord
$ bundle exec rake db:create
```

Taip pat galite sukurti atskiras testavimo duomenų bazes kiekvienam duomenų bazių varikliui atskirai:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
$ bundle exec rake db:postgresql:build
```

ir duomenų bazes galite ištrinti naudodami:

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

PASTABA: Naudojant Rake užduotį sukurti testavimo duomenų bazes, užtikrinama, kad jos turės teisingą simbolių rinkinį ir lyginimą.

Jei naudojate kitą duomenų bazę, patikrinkite failą `activerecord/test/config.yml` arba `activerecord/test/config.example.yml` dėl numatytosios prisijungimo informacijos. Galite redaguoti `activerecord/test/config.yml`, kad pateiktumėte skirtingus prisijungimo duomenis savo kompiuteryje, tačiau neturėtumėte siųsti jokių šių pakeitimų atgal į Rails.

### Įdiekite JavaScript priklausomybes

Jei įdiegėte Yarn, turėsite įdiegti JavaScript priklausomybes:

```bash
$ yarn install
```

### Įdiekite Gem priklausomybes

Gems yra įdiegiami su [Bundler](https://bundler.io/), kuris pagal numatymą yra pridedamas su Ruby.

Norėdami įdiegti Gemfile Rails, įvykdykite:

```bash
$ bundle install
```

Jei nereikia vykdyti Active Record testų, galite įvykdyti:

```bash
$ bundle install --without db
```

### Prisidėkite prie Rails

Kai viskas sukonfigūruota, perskaitykite, kaip galite pradėti [prisidėti](contributing_to_ruby_on_rails.html#running-an-application-against-your-local-branch).
