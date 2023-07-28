**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 282c6f5888c41f4c28238cd40bce5aa7
安装Rails核心开发依赖项
=========================

本指南介绍如何为Ruby on Rails核心开发设置环境。

阅读本指南后，您将了解：

* 如何为Rails开发设置您的机器

--------------------------------------------------------------------------------

其他设置环境的方法
------------------

如果您不想在本地机器上设置Rails进行开发，您可以使用Codespaces、VS Code远程插件或rails-dev-box。了解更多关于这些选项的信息[在这里](contributing_to_ruby_on_rails.html#setting-up-a-development-environment)。

本地开发
----------

如果您想在本地机器上开发Ruby on Rails，请参阅以下步骤。

### 安装Git

Ruby on Rails使用Git进行源代码控制。[Git主页](https://git-scm.com/)上有安装说明。有很多在线资源可以帮助您熟悉Git。

### 克隆Ruby on Rails存储库

导航到您想要下载Ruby on Rails源代码的文件夹（它将创建自己的`rails`子目录）并运行：

```bash
$ git clone https://github.com/rails/rails.git
$ cd rails
```

### 安装其他工具和服务

某些Rails测试依赖于在运行这些特定测试之前需要安装的其他工具。

以下是每个gem的附加依赖项列表：

* Action Cable依赖于Redis
* Active Record依赖于SQLite3、MySQL和PostgreSQL
* Active Storage依赖于Yarn（此外，Yarn还依赖于[Node.js](https://nodejs.org/)）、ImageMagick、libvips、FFmpeg、muPDF、Poppler，以及在macOS上还有XQuartz。
* Active Support依赖于memcached和Redis
* Railties依赖于JavaScript运行时环境，例如已安装[Node.js](https://nodejs.org/)。

安装您需要正确测试您将要进行更改的完整gem所需的所有服务。如何在macOS、Ubuntu、Fedora/CentOS、Arch Linux和FreeBSD上安装这些服务的详细说明如下。

注意：Redis的文档不建议使用软件包管理器进行安装，因为这些通常过时。从源代码安装并启动服务器非常简单，并且在[Redis文档](https://redis.io/download#installation)上有很好的文档。

注意：Active Record测试必须至少通过MySQL、PostgreSQL和SQLite3。如果针对单个适配器进行测试，则您的补丁将被拒绝，除非更改和测试是适配器特定的。

下面您可以找到有关如何为不同操作系统安装所有附加工具的说明。

#### macOS

在macOS上，您可以使用[Homebrew](https://brew.sh/)安装所有附加工具。

要全部安装，请运行：

```bash
$ brew bundle
```

您还需要启动每个已安装服务。要列出所有可用服务，请运行：

```bash
$ brew services list
```

然后，您可以像这样逐个启动每个服务：

```bash
$ brew services start mysql
```

将`mysql`替换为您要启动的服务的名称。

##### 潜在问题

本节详细介绍了您在macOS上使用本地开发时可能遇到的一些潜在问题，特别是在捆绑mysql2 gem时的本机扩展。此文档可能会随着Apple对Rails开发环境进行更改而发生变化，并且可能不准确。

为了在macOS上编译`mysql2` gem，您需要以下内容：

1. 安装`openssl@1.1`（而不是`openssl@3`）
2. 使用`openssl@1.1`编译的Ruby
3. 在bundle配置中为`mysql2`设置编译器标志。

如果同时安装了`openssl@1.1`和`openssl@3`，则需要告诉Ruby使用`openssl@1.1`，以便Rails可以捆绑`mysql2`。

在您的`.bash_profile`中设置`PATH`和`RUBY_CONFIGURE_OPTS`以指向`openssl@1.1`：

```
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
```

在您的`~/.bundle/config`中为`mysql2`设置以下内容。确保删除任何其他`BUNDLE_BUILD__MYSQL2`的条目：

```
BUNDLE_BUILD__MYSQL2: "--with-ldflags=-L/usr/local/opt/openssl@1.1/lib --with-cppflags=-L/usr/local/opt/openssl@1.1/include"
```

通过在安装Ruby和捆绑Rails之前设置这些标志，您应该能够使您的本地macOS开发环境正常工作。

#### Ubuntu

要全部安装，请运行：

```bash
$ sudo apt-get update
$ sudo apt-get install sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils

# 安装Yarn
# 如果您没有安装Node.js，请使用此命令
$ curl --fail --silent --show-error --location https://deb.nodesource.com/setup_18.x | sudo -E bash -
$ sudo apt-get install -y nodejs
# 安装Node.js后，安装yarn npm包
$ sudo npm install --global yarn
```
#### Fedora或CentOS

要安装所有依赖项，请运行以下命令：

```bash
$ sudo dnf install sqlite-devel sqlite-libs mysql-server mysql-devel postgresql-server postgresql-devel redis memcached imagemagick ffmpeg mupdf libxml2-devel vips poppler-utils

# 安装Yarn
# 如果您没有安装Node.js，请使用此命令
$ curl --silent --location https://rpm.nodesource.com/setup_18.x | sudo bash -
$ sudo dnf install -y nodejs
# 安装yarn npm包
$ sudo npm install --global yarn
```

#### Arch Linux

要安装所有依赖项，请运行以下命令：

```bash
$ sudo pacman -S sqlite mariadb libmariadbclient mariadb-clients postgresql postgresql-libs redis memcached imagemagick ffmpeg mupdf mupdf-tools poppler yarn libxml2 libvips poppler
$ sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
$ sudo systemctl start redis mariadb memcached
```

注意：如果您正在运行Arch Linux，则不再支持MySQL，因此您需要改用MariaDB（请参阅[此公告](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)）。

#### FreeBSD

要安装所有依赖项，请运行以下命令：

```bash
$ sudo pkg install sqlite3 mysql80-client mysql80-server postgresql11-client postgresql11-server memcached imagemagick6 ffmpeg mupdf yarn libxml2 vips poppler-utils
# portmaster databases/redis
```

或通过ports安装所有内容（这些软件包位于`databases`文件夹下）。

注意：如果在安装MySQL时遇到问题，请参阅[MySQL文档](https://dev.mysql.com/doc/refman/en/freebsd-installation.html)。

#### Debian

要安装所有依赖项，请运行以下命令：

```bash
$ sudo apt-get install sqlite3 libsqlite3-dev default-mysql-server default-libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils
```

注意：如果您正在运行Debian，则MariaDB是默认的MySQL服务器，因此可能会有一些差异。

### 数据库配置

配置运行Active Record测试所需的数据库引擎还需要一些额外的步骤。

PostgreSQL的身份验证方式不同。要使用您的开发帐户设置开发环境，在Linux或BSD上，只需运行：

```bash
$ sudo -u postgres createuser --superuser $USER
```

对于macOS：

```bash
$ createuser --superuser $USER
```

注意：MySQL将在创建数据库时创建用户。该任务假设您的用户是`root`且没有密码。

然后，您需要使用以下命令为MySQL和PostgreSQL创建测试数据库：

```bash
$ cd activerecord
$ bundle exec rake db:create
```

您还可以分别为每个数据库引擎创建测试数据库：

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
$ bundle exec rake db:postgresql:build
```

您可以使用以下命令删除数据库：

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

注意：使用Rake任务创建测试数据库可以确保它们具有正确的字符集和排序规则。

如果您使用其他数据库，请检查文件`activerecord/test/config.yml`或`activerecord/test/config.example.yml`以获取默认连接信息。您可以编辑`activerecord/test/config.yml`以在您的计算机上提供不同的凭据，但不应将这些更改推送回Rails。

### 安装JavaScript依赖项

如果您安装了Yarn，则需要安装JavaScript依赖项：

```bash
$ yarn install
```

### 安装Gem依赖项

Gems是使用[Ruby](https://bundler.io/)默认提供的Bundler安装的。

要安装Rails的Gemfile，请运行以下命令：

```bash
$ bundle install
```

如果您不需要运行Active Record测试，可以运行：

```bash
$ bundle install --without db
```

### 贡献到Rails

在设置好一切之后，阅读如何开始[贡献](contributing_to_ruby_on_rails.html#running-an-application-against-your-local-branch)。
