**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 282c6f5888c41f4c28238cd40bce5aa7
Railsコア開発の依存関係のインストール
==============================================

このガイドでは、Ruby on Railsコア開発の環境のセットアップ方法について説明します。

このガイドを読み終えると、以下のことがわかります。

* Rails開発のためのマシンのセットアップ方法

--------------------------------------------------------------------------------

環境をセットアップする他の方法
-------------------------------------

ローカルマシンでのRails開発のセットアップを行いたくない場合、Codespaces、VS Code Remote Plugin、またはrails-dev-boxを使用することができます。これらのオプションについては[こちら](contributing_to_ruby_on_rails.html#setting-up-a-development-environment)を参照してください。

ローカル開発
-----------------

マシン上でRuby on Railsをローカルに開発したい場合は、以下の手順を参照してください。

### Gitのインストール

Ruby on Railsはソースコードの管理にGitを使用しています。[Gitのホームページ](https://git-scm.com/)にはインストール手順が記載されています。Gitについての詳細な情報は、オンラインのさまざまなリソースを参照してください。

### Ruby on Railsリポジトリのクローン

Ruby on Railsのソースコードをダウンロードするフォルダに移動し（自動的に`rails`サブディレクトリが作成されます）、次のコマンドを実行します。

```bash
$ git clone https://github.com/rails/rails.git
$ cd rails
```

### 追加のツールとサービスのインストール

一部のRailsのテストは、特定のテストを実行する前にインストールする必要がある追加のツールに依存しています。

以下は、各gemの追加の依存関係のリストです。

* Action CableはRedisに依存しています。
* Active RecordはSQLite3、MySQL、およびPostgreSQLに依存しています。
* Active StorageはYarnに依存しています（さらにYarnは[Node.js](https://nodejs.org/)に依存しています）、ImageMagick、libvips、FFmpeg、muPDF、Poppler、およびmacOSではXQuartzも依存しています。
* Active SupportはmemcachedとRedisに依存しています。
* RailtiesはJavaScriptランタイム環境に依存しており、[Node.js](https://nodejs.org/)がインストールされている必要があります。

変更を加えるために正しくテストするために必要なすべてのサービスをインストールしてください。macOS、Ubuntu、Fedora/CentOS、Arch Linux、FreeBSDでこれらのサービスをインストールする方法については、以下に詳細が記載されています。

注意：Redisのドキュメントでは、パッケージマネージャを使用したインストールは通常古くなっているため、推奨されていません。Redisをソースからインストールし、サーバーを起動する方法は、[Redisのドキュメント](https://redis.io/download#installation)で詳しく説明されています。

注意：Active Recordのテストは、少なくともMySQL、PostgreSQL、およびSQLite3でパスする必要があります。変更とテストがアダプタに特化していない限り、単一のアダプタでテストされたパッチは拒否されます。

以下では、さまざまなオペレーティングシステムに追加ツールをインストールする方法について説明します。

#### macOS

macOSでは、[Homebrew](https://brew.sh/)を使用して追加のツールをすべてインストールできます。

すべてをインストールするには、次のコマンドを実行します。

```bash
$ brew bundle
```

また、インストールした各サービスを起動する必要もあります。利用可能なサービスの一覧を表示するには、次のコマンドを実行します。

```bash
$ brew services list
```

次のようにして、各サービスを個別に起動できます。

```bash
$ brew services start mysql
```

`mysql`の部分を起動したいサービスの名前に置き換えてください。

##### 潜在的な問題

このセクションでは、macOSでのネイティブ拡張機能に関する潜在的な問題について詳しく説明します。特に、ローカル開発でmysql2 gemをバンドルする場合の問題について説明します。このドキュメントは変更される可能性があり、AppleがRailsの開発環境に変更を加えると不正確になる可能性があります。

macOSで`mysql2` gemをコンパイルするためには、次のものが必要です。

1. `openssl@1.1`がインストールされていること（`openssl@3`ではないこと）
2. `openssl@1.1`でコンパイルされたRuby
3. `mysql2`のバンドル構成でコンパイラフラグを設定する

`openssl@1.1`と`openssl@3`の両方がインストールされている場合、Railsが`mysql2`をバンドルするためにRubyに`openssl@1.1`を使用する必要があります。

`.bash_profile`に`PATH`と`RUBY_CONFIGURE_OPTS`を設定して、`openssl@1.1`を指すようにします。

```
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
```

`~/.bundle/config`に、`mysql2`のために次の設定を行います。`BUNDLE_BUILD__MYSQL2`の他のエントリを削除してください。

```
BUNDLE_BUILD__MYSQL2: "--with-ldflags=-L/usr/local/opt/openssl@1.1/lib --with-cppflags=-L/usr/local/opt/openssl@1.1/include"
```

これらのフラグをRubyのインストールとRailsのバンドルの前に設定することで、macOSのローカル開発環境を動作させることができるはずです。

#### Ubuntu

すべてをインストールするには、次のコマンドを実行します。

```bash
$ sudo apt-get update
$ sudo apt-get install sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils

# Yarnのインストール
# Node.jsがインストールされていない場合は、このコマンドを使用してください
$ curl --fail --silent --show-error --location https://deb.nodesource.com/setup_18.x | sudo -E bash -
$ sudo apt-get install -y nodejs
# Node.jsをインストールした後、yarn npmパッケージをインストールします
$ sudo npm install --global yarn
```
#### FedoraまたはCentOS

すべてをインストールするには、次のコマンドを実行します。

```bash
$ sudo dnf install sqlite-devel sqlite-libs mysql-server mysql-devel postgresql-server postgresql-devel redis memcached imagemagick ffmpeg mupdf libxml2-devel vips poppler-utils

# Yarnをインストールする
# Node.jsがインストールされていない場合は、このコマンドを使用します
$ curl --silent --location https://rpm.nodesource.com/setup_18.x | sudo bash -
$ sudo dnf install -y nodejs
# Node.jsをインストールした後、yarn npmパッケージをインストールします
$ sudo npm install --global yarn
```

#### Arch Linux

すべてをインストールするには、次のコマンドを実行します。

```bash
$ sudo pacman -S sqlite mariadb libmariadbclient mariadb-clients postgresql postgresql-libs redis memcached imagemagick ffmpeg mupdf mupdf-tools poppler yarn libxml2 libvips poppler
$ sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
$ sudo systemctl start redis mariadb memcached
```

注意：Arch Linuxを実行している場合、MySQLはもはやサポートされていないため、代わりにMariaDBを使用する必要があります（[この発表](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)を参照）。

#### FreeBSD

すべてをインストールするには、次のコマンドを実行します。

```bash
$ sudo pkg install sqlite3 mysql80-client mysql80-server postgresql11-client postgresql11-server memcached imagemagick6 ffmpeg mupdf yarn libxml2 vips poppler-utils
# portmaster databases/redis
```

または、ポートを介してすべてをインストールします（これらのパッケージは「databases」フォルダーの下にあります）。

注意：MySQLのインストール中に問題が発生した場合は、[MySQLのドキュメント](https://dev.mysql.com/doc/refman/en/freebsd-installation.html)を参照してください。

#### Debian

すべての依存関係をインストールするには、次のコマンドを実行します。

```bash
$ sudo apt-get install sqlite3 libsqlite3-dev default-mysql-server default-libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils
```

注意：Debianを実行している場合、MariaDBはデフォルトのMySQLサーバーですので、違いがあるかもしれません。

### データベースの設定

Active Recordテストを実行するためには、データベースエンジンの設定にはいくつかの追加手順が必要です。

PostgreSQLの認証は異なる方法で動作します。開発環境を開発アカウントで設定するには、LinuxまたはBSDで次のコマンドを実行します。

```bash
$ sudo -u postgres createuser --superuser $USER
```

macOSの場合は次のようにします。

```bash
$ createuser --superuser $USER
```

注意：MySQLはデータベースが作成されるとユーザーも作成します。このタスクでは、ユーザーはパスワードなしで`root`であることを想定しています。

その後、次のコマンドでMySQLとPostgreSQLのテストデータベースを作成する必要があります。

```bash
$ cd activerecord
$ bundle exec rake db:create
```

または、各データベースエンジンごとにテストデータベースを作成することもできます。

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
$ bundle exec rake db:postgresql:build
```

データベースを削除するには、次のコマンドを使用します。

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

注意：テストデータベースを作成するためにRakeタスクを使用すると、正しい文字セットと照合が設定されたデータベースが作成されます。

別のデータベースを使用している場合は、`activerecord/test/config.yml`または`activerecord/test/config.example.yml`ファイルを確認してデフォルトの接続情報を確認してください。`activerecord/test/config.yml`を編集してマシン上で異なる資格情報を提供することもできますが、これらの変更をRailsにプッシュしないでください。

### JavaScriptの依存関係をインストールする

Yarnをインストールした場合、JavaScriptの依存関係をインストールする必要があります。

```bash
$ yarn install
```

### Gemの依存関係をインストールする

GemはデフォルトでRubyと一緒に配布されている[Bundler](https://bundler.io/)を使用してインストールされます。

RailsのGemfileをインストールするには、次のコマンドを実行します。

```bash
$ bundle install
```

Active Recordのテストを実行する必要がない場合は、次のコマンドを実行します。

```bash
$ bundle install --without db
```

### Railsへの貢献

すべてを設定した後、[貢献の方法](contributing_to_ruby_on_rails.html#running-an-application-against-your-local-branch)を読んで、ローカルブランチに対してアプリケーションを実行する方法を確認してください。
