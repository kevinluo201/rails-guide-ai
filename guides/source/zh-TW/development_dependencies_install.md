**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 282c6f5888c41f4c28238cd40bce5aa7
安裝Rails核心開發相依套件
==========================

本指南介紹如何設置Ruby on Rails核心開發環境。

閱讀完本指南後，您將了解：

* 如何為Rails開發設置您的機器

--------------------------------------------------------------------------------

其他設置環境的方法
------------------

如果您不想在本機設置Rails進行開發，您可以使用Codespaces、VS Code Remote Plugin或rails-dev-box。了解更多關於這些選項的資訊[在這裡](contributing_to_ruby_on_rails.html#setting-up-a-development-environment)。

本機開發
--------

如果您想在本機機器上進行Ruby on Rails開發，請參考以下步驟。

### 安裝Git

Ruby on Rails使用Git進行原始碼控制。[Git官網](https://git-scm.com/)提供安裝指南。網上有許多資源可以幫助您熟悉Git。

### 複製Ruby on Rails存儲庫

前往您想要下載Ruby on Rails原始碼的文件夾（它將創建自己的`rails`子目錄），然後執行以下命令：

```bash
$ git clone https://github.com/rails/rails.git
$ cd rails
```

### 安裝其他工具和服務

某些Rails測試依賴於您在運行這些特定測試之前需要安裝的其他工具。

以下是每個gem的附加相依套件列表：

* Action Cable依賴於Redis
* Active Record依賴於SQLite3、MySQL和PostgreSQL
* Active Storage依賴於Yarn（另外Yarn還依賴於[Node.js](https://nodejs.org/)）、ImageMagick、libvips、FFmpeg、muPDF、Poppler，並且在macOS上還依賴於XQuartz。
* Active Support依賴於memcached和Redis
* Railties依賴於JavaScript運行環境，例如已安裝[Node.js](https://nodejs.org/)。

安裝您需要正確測試您將要進行更改的完整gem所需的所有服務。如何在macOS、Ubuntu、Fedora/CentOS、Arch Linux和FreeBSD上安裝這些服務的詳細步驟如下。

注意：Redis的文檔不建議使用套件管理器進行安裝，因為這些通常已經過時。從源代碼安裝並啟動服務是直接且有良好文檔的方法，請參考[Redis的文檔](https://redis.io/download#installation)。

注意：Active Record測試必須至少通過MySQL、PostgreSQL和SQLite3。如果對單個適配器進行測試，除非更改和測試是適配器特定的，否則您的修補程序將被拒絕。

以下是如何在不同操作系統上安裝所有附加工具的說明。

#### macOS

在macOS上，您可以使用[Homebrew](https://brew.sh/)安裝所有附加工具。

要安裝所有工具，執行以下命令：

```bash
$ brew bundle
```

您還需要啟動每個已安裝的服務。要列出所有可用的服務，執行以下命令：

```bash
$ brew services list
```

然後，您可以逐個啟動每個服務，例如：

```bash
$ brew services start mysql
```

將`mysql`替換為您要啟動的服務的名稱。

##### 潛在問題

本節詳細介紹了在macOS上使用本地擴展時可能遇到的一些潛在問題，特別是在本地開發中捆綁mysql2 gem時。此文檔可能會隨著Apple對Rails開發環境進行更改而變動，並且可能不正確。

要在macOS上編譯`mysql2` gem，您需要以下內容：

1. 安裝`openssl@1.1`（不是`openssl@3`）
2. 使用`openssl@1.1`編譯Ruby
3. 在bundle配置中為`mysql2`設置編譯器標誌。

如果同時安裝了`openssl@1.1`和`openssl@3`，您需要告訴Ruby使用`openssl@1.1`，以便Rails可以捆綁`mysql2`。

在您的`.bash_profile`中設置`PATH`和`RUBY_CONFIGURE_OPTS`以指向`openssl@1.1`：

```
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
```

在您的`~/.bundle/config`中為`mysql2`設置以下內容。請確保刪除任何其他`BUNDLE_BUILD__MYSQL2`的條目：

```
BUNDLE_BUILD__MYSQL2: "--with-ldflags=-L/usr/local/opt/openssl@1.1/lib --with-cppflags=-L/usr/local/opt/openssl@1.1/include"
```

在安裝Ruby並捆綁Rails之前設置這些標誌，您應該能夠使您的本地macOS開發環境正常工作。

#### Ubuntu

要安裝所有工具，執行以下命令：

```bash
$ sudo apt-get update
$ sudo apt-get install sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils

# 安裝Yarn
# 如果您尚未安裝Node.js，請使用此命令
$ curl --fail --silent --show-error --location https://deb.nodesource.com/setup_18.x | sudo -E bash -
$ sudo apt-get install -y nodejs
# 安裝Node.js後，安裝yarn npm套件
$ sudo npm install --global yarn
```
#### Fedora 或 CentOS

要安裝所有的套件，請執行以下指令：

```bash
$ sudo dnf install sqlite-devel sqlite-libs mysql-server mysql-devel postgresql-server postgresql-devel redis memcached imagemagick ffmpeg mupdf libxml2-devel vips poppler-utils

# 安裝 Yarn
# 如果您尚未安裝 Node.js，請使用此指令
$ curl --silent --location https://rpm.nodesource.com/setup_18.x | sudo bash -
$ sudo dnf install -y nodejs
# 安裝 yarn npm 套件
$ sudo npm install --global yarn
```

#### Arch Linux

要安裝所有的套件，請執行以下指令：

```bash
$ sudo pacman -S sqlite mariadb libmariadbclient mariadb-clients postgresql postgresql-libs redis memcached imagemagick ffmpeg mupdf mupdf-tools poppler yarn libxml2 libvips poppler
$ sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
$ sudo systemctl start redis mariadb memcached
```

注意：如果您使用的是 Arch Linux，MySQL 已不再支援，您需要改用 MariaDB（請參閱[此公告](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)）。

#### FreeBSD

要安裝所有的套件，請執行以下指令：

```bash
$ sudo pkg install sqlite3 mysql80-client mysql80-server postgresql11-client postgresql11-server memcached imagemagick6 ffmpeg mupdf yarn libxml2 vips poppler-utils
# portmaster databases/redis
```

或者您也可以透過 ports 安裝所有套件（這些套件位於 `databases` 資料夾中）。

注意：如果在安裝 MySQL 過程中遇到問題，請參閱[MySQL 文件](https://dev.mysql.com/doc/refman/en/freebsd-installation.html)。

#### Debian

要安裝所有的相依套件，請執行以下指令：

```bash
$ sudo apt-get install sqlite3 libsqlite3-dev default-mysql-server default-libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils
```

注意：如果您使用的是 Debian，預設的 MySQL 伺服器是 MariaDB，因此可能會有一些差異。

### 資料庫設定

設定資料庫引擎所需的額外步驟如下：

PostgreSQL 的驗證方式不同。在 Linux 或 BSD 上，要使用您的開發帳號設定開發環境，只需執行以下指令：

```bash
$ sudo -u postgres createuser --superuser $USER
```

在 macOS 上，請執行以下指令：

```bash
$ createuser --superuser $USER
```

注意：MySQL 會在建立資料庫時自動建立使用者。此任務假設您的使用者是 `root`，且沒有密碼。

接著，您需要使用以下指令為 MySQL 和 PostgreSQL 建立測試資料庫：

```bash
$ cd activerecord
$ bundle exec rake db:create
```

您也可以分別為每個資料庫引擎建立測試資料庫：

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
$ bundle exec rake db:postgresql:build
```

要刪除資料庫，請使用以下指令：

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

注意：使用 Rake 任務建立測試資料庫可以確保它們具有正確的字元集和排序規則。

如果您使用其他資料庫，請檢查檔案 `activerecord/test/config.yml` 或 `activerecord/test/config.example.yml` 中的預設連線資訊。您可以編輯 `activerecord/test/config.yml` 以在您的機器上提供不同的憑證，但請不要將這些變更推送回 Rails。

### 安裝 JavaScript 相依套件

如果您已經安裝了 Yarn，您需要安裝 JavaScript 相依套件：

```bash
$ yarn install
```

### 安裝 Gem 相依套件

Gem 相依套件是使用預設隨 Ruby 一同提供的 [Bundler](https://bundler.io/) 安裝的。

要安裝 Rails 的 Gemfile，請執行以下指令：

```bash
$ bundle install
```

如果您不需要執行 Active Record 測試，可以執行以下指令：

```bash
$ bundle install --without db
```

### 貢獻至 Rails

在設定好一切之後，請閱讀如何開始[貢獻](contributing_to_ruby_on_rails.html#running-an-application-against-your-local-branch)。
