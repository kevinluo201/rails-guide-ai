**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 282c6f5888c41f4c28238cd40bce5aa7
Rails Core 개발 의존성 설치
==============================================

이 안내서는 Ruby on Rails 코어 개발을 위한 환경 설정 방법을 다룹니다.

이 안내서를 읽은 후에는 다음을 알게 됩니다:

* Rails 개발을 위한 기계 설정 방법

--------------------------------------------------------------------------------

환경 설정을 위한 다른 방법
-------------------------------------

로컬 기계에서 개발을 위해 Rails를 설정하고 싶지 않다면, Codespaces, VS Code Remote 플러그인 또는 rails-dev-box를 사용할 수 있습니다. 이러한 옵션에 대해 자세히 알아보려면 [여기](contributing_to_ruby_on_rails.html#setting-up-a-development-environment)를 참조하세요.

로컬 개발
-----------------

기계에서 Ruby on Rails를 로컬로 개발하려면 아래 단계를 참조하세요.

### Git 설치

Ruby on Rails는 소스 코드 관리를 위해 Git을 사용합니다. [Git 홈페이지](https://git-scm.com/)에 설치 지침이 있습니다. Git에 익숙해지는 데 도움이 되는 다양한 온라인 자료가 있습니다.

### Ruby on Rails 저장소 복제

Ruby on Rails 소스 코드를 다운로드할 폴더로 이동한 다음 다음 명령을 실행하세요. (자체적으로 `rails` 하위 디렉토리를 생성합니다.)

```bash
$ git clone https://github.com/rails/rails.git
$ cd rails
```

### 추가 도구 및 서비스 설치

일부 Rails 테스트는 특정 테스트를 실행하기 전에 설치해야 하는 추가 도구에 의존합니다.

각 젬의 추가 종속성 목록은 다음과 같습니다:

* Action Cable은 Redis에 의존합니다.
* Active Record는 SQLite3, MySQL 및 PostgreSQL에 의존합니다.
* Active Storage는 Yarn에 의존합니다 (추가로 Yarn은 [Node.js](https://nodejs.org/)에 의존합니다), ImageMagick, libvips, FFmpeg, muPDF, Poppler 및 macOS에서는 XQuartz에도 의존합니다.
* Active Support는 memcached와 Redis에 의존합니다.
* Railties는 [Node.js](https://nodejs.org/)와 같은 JavaScript 런타임 환경에 의존합니다.

변경할 전체 젬을 올바르게 테스트하기 위해 필요한 모든 서비스를 설치하세요. macOS, Ubuntu, Fedora/CentOS, Arch Linux 및 FreeBSD에 대한 이러한 서비스의 설치 방법은 아래에 자세히 설명되어 있습니다.

참고: Redis의 문서에서는 패키지 관리자를 통한 설치를 권장하지 않습니다. 대개 이러한 패키지 관리자는 오래되었기 때문입니다. 소스에서 설치하고 서버를 시작하는 것은 직관적이고 [Redis 문서](https://redis.io/download#installation)에 잘 설명되어 있습니다.

참고: Active Record 테스트는 최소한 MySQL, PostgreSQL 및 SQLite3에서 통과해야 합니다. 변경 사항과 테스트가 어댑터별인 경우를 제외하고 단일 어댑터에 대해 테스트된 패치는 거부됩니다.

다음은 다른 운영 체제에 대한 모든 추가 도구 설치 방법에 대한 지침입니다.

#### macOS

macOS에서는 [Homebrew](https://brew.sh/)를 사용하여 모든 추가 도구를 설치할 수 있습니다.

모두 설치하려면 다음을 실행하세요:

```bash
$ brew bundle
```

설치한 각 서비스를 시작해야 합니다. 사용 가능한 모든 서비스를 나열하려면 다음을 실행하세요:

```bash
$ brew services list
```

그런 다음 다음과 같이 각 서비스를 하나씩 시작할 수 있습니다:

```bash
$ brew services start mysql
```

시작할 서비스의 이름으로 `mysql`을(를) 대체하세요.

##### 잠재적인 문제점

이 섹션에서는 macOS에서 네이티브 확장에 대한 잠재적인 문제점을 설명합니다. 특히 로컬 개발에서 mysql2 젬을 번들링할 때 발생할 수 있는 문제입니다. 이 문서는 Apple이 Rails의 개발자 환경을 변경함에 따라 변경될 수 있으며 잘못된 정보일 수 있습니다.

macOS에서 `mysql2` 젬을 컴파일하려면 다음이 필요합니다:

1. `openssl@1.1` 설치 (`openssl@3`이 아님)
2. `openssl@1.1`로 Ruby를 컴파일
3. `mysql2`에 대한 번들 구성에서 컴파일러 플래그 설정

`openssl@1.1`과 `openssl@3`이 모두 설치된 경우, Rails가 `mysql2`를 번들링하기 위해 Ruby가 `openssl@1.1`을 사용하도록 알려야 합니다.

`.bash_profile`에서 `PATH`와 `RUBY_CONFIGURE_OPTS`를 `openssl@1.1`을 가리키도록 설정하세요:

```
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
```

`~/.bundle/config`에서 다음을 `mysql2`에 대해 설정하세요. `BUNDLE_BUILD__MYSQL2`에 대한 다른 항목을 모두 삭제하세요:

```
BUNDLE_BUILD__MYSQL2: "--with-ldflags=-L/usr/local/opt/openssl@1.1/lib --with-cppflags=-L/usr/local/opt/openssl@1.1/include"
```

이러한 플래그를 Ruby를 설치하고 Rails를 번들링하기 전에 설정하면 로컬 macOS 개발 환경을 작동시킬 수 있습니다.

#### Ubuntu

모두 설치하려면 다음을 실행하세요:

```bash
$ sudo apt-get update
$ sudo apt-get install sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils

# Yarn 설치
# Node.js가 설치되어 있지 않은 경우 이 명령을 사용하세요
$ curl --fail --silent --show-error --location https://deb.nodesource.com/setup_18.x | sudo -E bash -
$ sudo apt-get install -y nodejs
# Node.js를 설치한 후 yarn npm 패키지를 설치하세요
$ sudo npm install --global yarn
```
#### Fedora 또는 CentOS

모두 설치하려면 다음을 실행하세요:

```bash
$ sudo dnf install sqlite-devel sqlite-libs mysql-server mysql-devel postgresql-server postgresql-devel redis memcached imagemagick ffmpeg mupdf libxml2-devel vips poppler-utils

# Yarn 설치
# Node.js가 설치되어 있지 않은 경우 이 명령을 사용하세요
$ curl --silent --location https://rpm.nodesource.com/setup_18.x | sudo bash -
$ sudo dnf install -y nodejs
# Node.js를 설치한 후 yarn npm 패키지를 설치하세요
$ sudo npm install --global yarn
```

#### Arch Linux

모두 설치하려면 다음을 실행하세요:

```bash
$ sudo pacman -S sqlite mariadb libmariadbclient mariadb-clients postgresql postgresql-libs redis memcached imagemagick ffmpeg mupdf mupdf-tools poppler yarn libxml2 libvips poppler
$ sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
$ sudo systemctl start redis mariadb memcached
```

참고: Arch Linux를 실행 중인 경우 MySQL은 더 이상 지원되지 않으므로 대신 MariaDB를 사용해야 합니다(자세한 내용은 [이 공지](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)를 참조하세요).

#### FreeBSD

모두 설치하려면 다음을 실행하세요:

```bash
$ sudo pkg install sqlite3 mysql80-client mysql80-server postgresql11-client postgresql11-server memcached imagemagick6 ffmpeg mupdf yarn libxml2 vips poppler-utils
# portmaster databases/redis
```

또는 포트를 통해 모두 설치하세요(이 패키지는 `databases` 폴더에 있습니다).

참고: MySQL 설치 중 문제가 발생하는 경우 [MySQL 문서](https://dev.mysql.com/doc/refman/en/freebsd-installation.html)를 참조하세요.

#### Debian

모든 종속성을 설치하려면 다음을 실행하세요:

```bash
$ sudo apt-get install sqlite3 libsqlite3-dev default-mysql-server default-libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils
```

참고: Debian을 실행 중인 경우 MariaDB가 기본 MySQL 서버이므로 차이점이 있을 수 있습니다.

### 데이터베이스 구성

Active Record 테스트를 실행하기 위해 데이터베이스 엔진을 구성하는 몇 가지 추가 단계가 필요합니다.

PostgreSQL의 인증 방식은 다릅니다. Linux 또는 BSD에서 개발 환경을 개발 계정으로 설정하려면 다음을 실행하세요:

```bash
$ sudo -u postgres createuser --superuser $USER
```

macOS에서는 다음을 실행하세요:

```bash
$ createuser --superuser $USER
```

참고: MySQL은 데이터베이스가 생성될 때 사용자를 생성합니다. 이 작업에서는 사용자가 `root`이고 암호가 없다고 가정합니다.

그런 다음 MySQL과 PostgreSQL의 테스트 데이터베이스를 생성하세요:

```bash
$ cd activerecord
$ bundle exec rake db:create
```

또는 각 데이터베이스 엔진별로 테스트 데이터베이스를 생성할 수 있습니다:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
$ bundle exec rake db:postgresql:build
```

데이터베이스를 삭제하려면 다음을 실행하세요:

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

참고: Rake 작업을 사용하여 테스트 데이터베이스를 생성하면 올바른 문자 집합과 정렬이 적용됩니다.

다른 데이터베이스를 사용하는 경우 `activerecord/test/config.yml` 또는 `activerecord/test/config.example.yml` 파일에서 기본 연결 정보를 확인하세요. `activerecord/test/config.yml` 파일을 편집하여 컴퓨터에서 다른 자격 증명을 제공할 수 있지만 이러한 변경 사항을 Rails에 다시 푸시하지 않아야 합니다.

### JavaScript 종속성 설치

Yarn을 설치한 경우 JavaScript 종속성을 설치해야 합니다:

```bash
$ yarn install
```

### Gem 종속성 설치

Gem은 Ruby와 함께 기본으로 제공되는 [Bundler](https://bundler.io/)를 사용하여 설치됩니다.

Rails의 Gemfile을 설치하려면 다음을 실행하세요:

```bash
$ bundle install
```

Active Record 테스트를 실행할 필요가 없는 경우 다음을 실행하세요:

```bash
$ bundle install --without db
```

### Rails에 기여하기

모든 설정을 완료한 후 [기여](contributing_to_ruby_on_rails.html#running-an-application-against-your-local-branch)를 시작하는 방법을 읽어보세요.
