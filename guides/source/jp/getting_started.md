**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2cf37358fedc8b51ed3ab7f408ecfc76
Railsのはじめ方
==========================

このガイドでは、Ruby on Railsを使って始める方法について説明します。

このガイドを読み終えると、以下のことがわかるようになります：

* Railsのインストール方法、新しいRailsアプリケーションの作成方法、およびデータベースへの接続方法。
* Railsアプリケーションの一般的なレイアウト。
* MVC（モデル、ビュー、コントローラ）とRESTfulデザインの基本原則。
* Railsアプリケーションの開始部分を素早く生成する方法。

--------------------------------------------------------------------------------

ガイドの前提条件
-----------------

このガイドは、Railsをゼロから作成して始めたい初心者を対象にしています。Railsの事前の経験は必要ありません。

RailsはRubyプログラミング言語上で動作するWebアプリケーションフレームワークです。
Rubyの事前の経験がない場合、Railsに直接取り組むと非常に学習コストがかかります。Rubyの学習には、いくつかのオンラインリソースのキュレーションされたリストがあります：

* [公式Rubyプログラミング言語のウェブサイト](https://www.ruby-lang.org/en/documentation/)
* [無料のプログラミング書籍のリスト](https://github.com/EbookFoundation/free-programming-books/blob/master/books/free-programming-books-langs.md#ruby)

一部のリソースは、まだ優れているものの、古いバージョンのRubyをカバーしており、Railsの日常的な開発で見られる一部の構文が含まれていない場合があります。

Railsとは何ですか？
--------------

Railsは、Rubyプログラミング言語で書かれたWebアプリケーション開発フレームワークです。
Railsは、開発者が始めるために必要なものについての前提を立てることで、Webアプリケーションのプログラミングを容易にするように設計されています。他の言語やフレームワークよりも少ないコードで多くのことを実現できるようにします。
経験豊富なRails開発者は、Railsを使うことでWebアプリケーションの開発がより楽しくなると報告しています。

Railsは意見の強いソフトウェアです。Railsは、あることを行うための「最良の」方法があるという前提を立て、その方法を奨励するように設計されています。場合によっては、代替案を推奨しないこともあります。もし「Railsのやり方」を学ぶなら、生産性が非常に向上することに気づくでしょう。他の言語での古い習慣をRailsの開発に持ち込んだり、他で学んだパターンを使おうとすると、あまり良い経験にはならないかもしれません。

Railsの哲学には2つの主要な指針があります：

* **Don't Repeat Yourself（DRY）：** DRYはソフトウェア開発の原則であり、「システム内のすべての知識は、一つの明確で明確な表現を持つ必要がある」と述べています。同じ情報を何度も書かないことで、コードは保守性が高く、拡張性があり、バグが少なくなります。
* **Convention Over Configuration（設定より規約）：** Railsは、Webアプリケーションの多くのことを行うための最良の方法についての意見を持っており、設定ファイルを延々と指定する必要はありません。代わりに、一連の規約に従います。

新しいRailsプロジェクトの作成
----------------------------

このガイドを読む最良の方法は、ステップバイステップで進めることです。すべてのステップは、この例のアプリケーションを実行するために必要であり、追加のコードや手順は必要ありません。

このガイドに従って進めると、`blog`というRailsプロジェクト、非常にシンプルなウェブログを作成します。アプリケーションの構築を開始する前に、Rails自体がインストールされていることを確認する必要があります。

注意：以下の例では、UNIXのようなOSでは`$`をターミナルプロンプトを表すために使用していますが、カスタマイズされて異なる表示になる場合もあります。Windowsを使用している場合、プロンプトは`C:\source_code>`のように表示されます。

### Railsのインストール

Railsをインストールする前に、システムに必要な前提条件がインストールされているか確認する必要があります。これには以下が含まれます：

* Ruby
* SQLite3

#### Rubyのインストール

コマンドラインプロンプトを開きます。macOSではTerminal.appを開き、Windowsではスタートメニューから「実行」を選択し、`cmd.exe`と入力します。`$`で始まるコマンドは、コマンドラインで実行する必要があります。現在のバージョンのRubyがインストールされていることを確認します：

```bash
$ ruby --version
ruby 2.7.0
```

RailsにはRubyバージョン2.7.0以降が必要です。最新のRubyバージョンを使用することが推奨されています。
返されるバージョン番号がその数値よりも小さい場合（2.3.7や1.8.7など）、新しいバージョンのRubyをインストールする必要があります。

WindowsでRailsをインストールするには、まず[Ruby Installer](https://rubyinstaller.org/)をインストールする必要があります。

ほとんどのオペレーティングシステムのインストール方法については、
[ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/)を参照してください。

#### SQLite3のインストール

SQLite3データベースのインストールも必要です。
多くの人気のあるUNIXのようなOSには、適切なバージョンのSQLite3が同梱されています。
その他のOSでは、[SQLite3のウェブサイト](https://www.sqlite.org)のインストール手順を参照してください。
インストールが正しく行われ、`PATH` にロードされていることを確認してください。

```bash
$ sqlite3 --version
```

プログラムはバージョンを報告するはずです。

#### Rails のインストール

Rails をインストールするには、RubyGems が提供する `gem install` コマンドを使用します。

```bash
$ gem install rails
```

正しくインストールされているかを確認するために、新しいターミナルで次のコマンドを実行できるはずです。

```bash
$ rails --version
```

もし "Rails 7.0.0" のような表示がされたら、準備ができています。

### ブログアプリケーションの作成

Rails には、特定のタスクを開始するために必要なすべてを作成するための便利なスクリプトであるジェネレータがいくつか用意されています。その中の1つが新しいアプリケーションジェネレータであり、自分で書く必要がないように新しい Rails アプリケーションの基盤を提供します。

このジェネレータを使用するには、ターミナルを開き、ファイルを作成する権限があるディレクトリに移動し、次のコマンドを実行します。

```bash
$ rails new blog
```

これにより、`blog` ディレクトリ内に Blog という名前の Rails アプリケーションが作成され、`Gemfile` で既に言及されているジェムの依存関係が `bundle install` を使用してインストールされます。

TIP: Rails アプリケーションジェネレータが受け入れるすべてのコマンドラインオプションを表示するには、`rails new --help` を実行します。

ブログアプリケーションを作成した後、そのフォルダに移動します。

```bash
$ cd blog
```

`blog` ディレクトリには、Rails アプリケーションの構造を構成する生成されたファイルとフォルダがいくつか含まれています。このチュートリアルでは、ほとんどの作業は `app` フォルダで行われますが、デフォルトで Rails が作成する各ファイルとフォルダの機能について基本的な説明を以下に示します。

| ファイル/フォルダ | 目的 |
| ----------- | ------- |
|app/|アプリケーションのコントローラ、モデル、ビュー、ヘルパー、メーラー、チャネル、ジョブ、およびアセットが含まれています。このガイドの残りの部分では、このフォルダに焦点を当てます。|
|bin/|アプリケーションを起動する `rails` スクリプトが含まれており、アプリケーションのセットアップ、更新、デプロイ、実行に使用する他のスクリプトを含めることもできます。|
|config/|アプリケーションのルート、データベースなどの設定が含まれています。これについての詳細は、[Configuring Rails Applications](configuring.html) を参照してください。|
|config.ru|アプリケーションを起動するために使用される Rack ベースのサーバの Rack 設定です。Rack の詳細については、[Rack website](https://rack.github.io/) を参照してください。|
|db/|現在のデータベーススキーマとデータベースマイグレーションが含まれています。|
|Gemfile<br>Gemfile.lock|これらのファイルを使用して、Rails アプリケーションに必要なジェムの依存関係を指定できます。これらのファイルは Bundler ジェムによって使用されます。Bundler の詳細については、[Bundler website](https://bundler.io) を参照してください。|
|lib/|アプリケーションの拡張モジュール。|
|log/|アプリケーションのログファイル。|
|public/|静的ファイルとコンパイルされたアセットが含まれています。アプリケーションが実行されている間、このディレクトリはそのまま公開されます。|
|Rakefile|コマンドラインから実行できるタスクを見つけて読み込むためのファイルです。タスクの定義は Rails の各コンポーネントによって定義されます。`Rakefile` を変更する代わりに、`lib/tasks` ディレクトリにファイルを追加することで独自のタスクを追加するべきです。|
|README.md|アプリケーションの簡単な説明書です。他の人にアプリケーションの機能や設定方法などを伝えるために、このファイルを編集する必要があります。|
|storage/|ディスクサービスの Active Storage ファイル。[Active Storage Overview](active_storage_overview.html) を参照してください。|
|test/|ユニットテスト、フィクスチャ、およびその他のテスト用具。[Testing Rails Applications](testing.html) を参照してください。|
|tmp/|キャッシュや PID ファイルなどの一時ファイル。|
|vendor/|サードパーティのコードを配置する場所。典型的な Rails アプリケーションでは、ベンダーのジェムが含まれます。|
|.gitattributes|このファイルは、git リポジトリ内の特定のパスのメタデータを定義します。このメタデータは、git や他のツールが動作を向上させるために使用できます。詳細については、[gitattributes documentation](https://git-scm.com/docs/gitattributes) を参照してください。|
|.gitignore|このファイルは、git が無視するべきファイル（またはパターン）を指定します。ファイルを無視する方法についての詳細は、[GitHub - Ignoring files](https://help.github.com/articles/ignoring-files) を参照してください。|
|.ruby-version|このファイルにはデフォルトの Ruby バージョンが含まれています。|

Hello, Rails!
-------------

まずは、画面にテキストを表示しましょう。これを行うには、Rails アプリケーションサーバを起動する必要があります。

### Web サーバの起動

実際には、すでに機能する Rails アプリケーションがあります。それを表示するには、開発マシンで Web サーバを起動する必要があります。`blog` ディレクトリで次のコマンドを実行することでこれを行うことができます。

```bash
$ bin/rails server
```
ヒント：Windowsを使用している場合、スクリプトをRubyインタプリタに直接渡す必要があります。例：`ruby bin\rails server`。

ヒント：JavaScriptのアセット圧縮には、システムにJavaScriptランタイムが必要です。ランタイムがない場合、アセットの圧縮中に`execjs`エラーが表示されます。通常、macOSとWindowsにはJavaScriptランタイムがインストールされています。`therubyrhino`はJRubyユーザーに推奨されるランタイムであり、JRubyで生成されたアプリの`Gemfile`にデフォルトで追加されます。サポートされているすべてのランタイムについては、[ExecJS](https://github.com/rails/execjs#readme)を調べることができます。

これにより、デフォルトでRailsと一緒に配布されているWebサーバーであるPumaが起動します。アプリケーションを実行するには、ブラウザウィンドウを開き、<http://localhost:3000>に移動します。Railsのデフォルトの情報ページが表示されるはずです。

![Railsの起動ページのスクリーンショット](images/getting_started/rails_welcome.png)

Webサーバーを停止するには、実行中のターミナルウィンドウでCtrl+Cを押します。開発環境では、Railsは通常、サーバーを再起動する必要はありません。ファイルで行った変更は、サーバーによって自動的に反映されます。

Railsの起動ページは、新しいRailsアプリケーションの「スモークテスト」です。これにより、ソフトウェアが正しく設定され、ページを提供できるようになっているかどうかが確認されます。

### Railsに「こんにちは」と言わせる

Railsに「こんにちは」と言わせるには、少なくとも*ルート*、*コントローラ*、および*ビュー*を作成する必要があります。ルートはリクエストをコントローラのアクションにマッピングします。コントローラのアクションは、リクエストを処理するために必要な作業を実行し、ビューのためのデータを準備します。ビューは、指定された形式でデータを表示します。

実装の観点からは、ルートはRubyの[DSL（ドメイン固有言語）](https://en.wikipedia.org/wiki/Domain-specific_language)で書かれたルールです。コントローラはRubyのクラスであり、そのパブリックメソッドはアクションです。ビューはテンプレートであり、通常はHTMLとRubyの組み合わせで書かれます。

まず、`config/routes.rb`ファイルの`Rails.application.routes.draw`ブロックの先頭に、ルートを追加します。

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
```

上記のルートは、`GET /articles`リクエストが`ArticlesController`の`index`アクションにマッピングされることを宣言しています。

`ArticlesController`とその`index`アクションを作成するには、コントローラジェネレータを実行します（既に適切なルートがあるため、`--skip-routes`オプションを使用します）。

```bash
$ bin/rails generate controller Articles index --skip-routes
```

Railsはいくつかのファイルを作成します。

```
create  app/controllers/articles_controller.rb
invoke  erb
create    app/views/articles
create    app/views/articles/index.html.erb
invoke  test_unit
create    test/controllers/articles_controller_test.rb
invoke  helper
create    app/helpers/articles_helper.rb
invoke    test_unit
```

これらのうち最も重要なのは、コントローラファイルである`app/controllers/articles_controller.rb`です。中身を見てみましょう。

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```

`index`アクションは空です。アクションが明示的にビューをレンダリングしない場合（またはHTTPレスポンスをトリガーしない場合）、Railsは自動的にコントローラとアクションの名前に一致するビューをレンダリングします。設定による規約！ビューは`app/views`ディレクトリにあります。したがって、`index`アクションはデフォルトで`app/views/articles/index.html.erb`をレンダリングします。

`app/views/articles/index.html.erb`を開き、その内容を次のように置き換えます。

```html
<h1>Hello, Rails!</h1>
```

以前にWebサーバーを停止してコントローラジェネレータを実行した場合は、`bin/rails server`で再起動します。今度は<http://localhost:3000/articles>にアクセスして、テキストが表示されることを確認します。

### アプリケーションのホームページを設定する

現時点では、<http://localhost:3000>はまだRuby on Railsのロゴが表示されるページです。同じく<http://localhost:3000>にも「Hello, Rails!」というテキストを表示しましょう。そのために、アプリケーションの*ルートパス*を適切なコントローラとアクションにマッピングするルートを追加します。

`config/routes.rb`を開き、次の`root`ルートを`Rails.application.routes.draw`ブロックの先頭に追加します。

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

これで、<http://localhost:3000>を訪れると「Hello, Rails!」というテキストが表示されるようになりました。これにより、`root`ルートも`ArticlesController`の`index`アクションにマッピングされていることが確認できます。

ヒント：ルーティングの詳細については、[Rails Routing from the Outside In](routing.html)を参照してください。

自動読み込み
-----------

Railsアプリケーションでは、アプリケーションコードを読み込むために`require`を使用しません。

`ArticlesController`が`ApplicationController`を継承していることに気付いたかもしれませんが、`app/controllers/articles_controller.rb`には次のようなものはありません。

```ruby
require "application_controller" # これは行わないでください。
```

アプリケーションのクラスやモジュールはどこでも利用できます。`app`の下にあるものを`require`で読み込む必要はありませんし、**すべきではありません**。この機能は「自動読み込み」と呼ばれ、[_Autoloading and Reloading Constants_](autoloading_and_reloading_constants.html)で詳しく説明されています。
`require`コールは2つのユースケースでのみ必要です：

* `lib`ディレクトリのファイルをロードするために。
* `Gemfile`で`require: false`と指定されているgemの依存関係をロードするために。

MVCとあなた
-----------

これまで、ルート、コントローラ、アクション、ビューについて説明してきました。これらはすべて、[MVC（モデル-ビュー-コントローラ）](
https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)パターンに従うウェブアプリケーションの典型的な要素です。
MVCは、アプリケーションの責任を分割して理解しやすくするための設計パターンです。Railsは、この設計パターンに従っています。

コントローラとビューがあるので、次の要素であるモデルを生成しましょう。

### モデルの生成

*モデル*は、データを表すために使用されるRubyクラスです。さらに、モデルはRailsの*Active Record*と呼ばれる機能を介してアプリケーションのデータベースと対話することができます。

モデルを定義するために、モデルジェネレータを使用します：

```bash
$ bin/rails generate model Article title:string body:text
```

注意：モデル名は**単数形**です。なぜなら、インスタンス化されたモデルは単一のデータレコードを表すからです。この規約を覚えるのに役立つために、モデルのコンストラクタを呼び出す方法を考えてみてください：`Article.new(...)`と書きたいのですが、`Articles.new(...)`とは書きたくありません。

これにより、いくつかのファイルが作成されます：

```
invoke  active_record
create    db/migrate/<timestamp>_create_articles.rb
create    app/models/article.rb
invoke    test_unit
create      test/models/article_test.rb
create      test/fixtures/articles.yml
```

焦点を当てるべき2つのファイルは、マイグレーションファイル（`db/migrate/<timestamp>_create_articles.rb`）とモデルファイル（`app/models/article.rb`）です。

### データベースマイグレーション

*マイグレーション*は、アプリケーションのデータベースの構造を変更するために使用されます。Railsアプリケーションでは、マイグレーションはデータベースに依存しないようにRubyで書かれています。

新しいマイグレーションファイルの内容を見てみましょう：

```ruby
class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

`create_table`への呼び出しは、`articles`テーブルの構造を指定しています。デフォルトでは、`create_table`メソッドは自動増分のプライマリキーとして`id`列を追加します。したがって、テーブルの最初のレコードは`id`が1、次のレコードは`id`が2、というようになります。

`create_table`のブロック内では、`title`と`body`の2つの列が定義されています。これらは、私たちが生成コマンドに含めたため、ジェネレータによって追加されました（`bin/rails generate model Article title:string body:text`）。

ブロックの最後の行では、`t.timestamps`という呼び出しがあります。このメソッドは、`created_at`と`updated_at`という2つの追加の列を定義します。後で見るように、Railsはこれらを管理し、モデルオブジェクトを作成または更新するときに値を設定します。

次のコマンドでマイグレーションを実行しましょう：

```bash
$ bin/rails db:migrate
```

コマンドは、テーブルが作成されたことを示す出力を表示します：

```
==  CreateArticles: migrating ===================================
-- create_table(:articles)
   -> 0.0018s
==  CreateArticles: migrated (0.0018s) ==========================
```

ヒント：マイグレーションについて詳しくは、[Active Record Migrations](
active_record_migrations.html)を参照してください。

これで、モデルを使用してテーブルと対話することができます。

### データベースとの対話にモデルを使用する

モデルを少しいじってみるために、Railsの機能である*コンソール*を使用します。コンソールは、`irb`と同様の対話型のコーディング環境ですが、Railsとアプリケーションのコードを自動的にロードすることもできます。

次のコマンドでコンソールを起動しましょう：

```bash
$ bin/rails console
```

次のような`irb`プロンプトが表示されるはずです：

```irb
Loading development environment (Rails 7.0.0)
irb(main):001:0>
```

このプロンプトで、新しい`Article`オブジェクトを初期化できます：

```irb
irb> article = Article.new(title: "Hello Rails", body: "I am on Rails!")
```

重要なことは、このオブジェクトは単に*初期化*されただけであるということです。このオブジェクトはまったくデータベースに保存されていません。現時点では、コンソールでのみ利用可能です。オブジェクトをデータベースに保存するには、[`save`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save)を呼び出さなければなりません：

```irb
irb> article.save
(0.1ms)  begin transaction
Article Create (0.4ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "Hello Rails"], ["body", "I am on Rails!"], ["created_at", "2020-01-18 23:47:30.734416"], ["updated_at", "2020-01-18 23:47:30.734416"]]
(0.9ms)  commit transaction
=> true
```

上記の出力は、`INSERT INTO "articles" ...`というデータベースクエリを示しています。これは、記事がテーブルに挿入されたことを示しています。そして、もう一度`article`オブジェクトを見てみると、興味深いことが起こったことがわかります：

```irb
irb> article
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```
オブジェクトの`id`、`created_at`、および`updated_at`属性が設定されました。
オブジェクトを保存すると、Railsがこれを行いました。

データベースからこの記事を取得する場合、モデルで[`find`](
https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find)
を呼び出し、`id`を引数として渡すことができます。

```irb
irb> Article.find(1)
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

また、データベースからすべての記事を取得する場合、モデルで[`all`](
https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all)
を呼び出すことができます。

```irb
irb> Article.all
=> #<ActiveRecord::Relation [#<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">]>
```

このメソッドは[`ActiveRecord::Relation`](
https://api.rubyonrails.org/classes/ActiveRecord/Relation.html)オブジェクトを返します。これは、スーパーパワーを持つ配列と考えることができます。

TIP: モデルについて詳しくは、[Active Record Basics](
active_record_basics.html)と[Active Record Query Interface](
active_record_querying.html)を参照してください。

モデルはMVCパズルの最後のピースです。次に、すべてのピースを組み合わせます。

### 記事の一覧表示

`app/controllers/articles_controller.rb`のコントローラに戻り、`index`アクションを変更してデータベースからすべての記事を取得します。

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

コントローラのインスタンス変数はビューからアクセスできます。つまり、`app/views/articles/index.html.erb`で`@articles`を参照することができます。そのファイルを開き、次の内容に置き換えます。

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

上記のコードはHTMLと*ERB*の組み合わせです。ERBは、ドキュメントに埋め込まれたRubyコードを評価するテンプレートシステムです。ここでは、2種類のERBタグが見られます:`<% %>`と`<%= %>`。`<% %>`タグは「囲まれたRubyコードを評価する」という意味です。`<%= %>`タグは「囲まれたRubyコードを評価し、それが返す値を出力する」という意味です。通常、ERBタグの内容を読みやすくするために、ERBタグの内容を短く保つことが最善ですが、通常のRubyプログラムで書くことができるものはすべてこれらのERBタグの内部に入れることができます。

`@articles.each`が返す値を出力したくないので、そのコードを`<% %>`で囲みました。しかし、各記事の`article.title`が返す値を出力したいので、そのコードを`<%= %>`で囲みました。

<http://localhost:3000>を訪れることで最終結果を確認できます（`bin/rails server`が実行されていることを忘れないでください）。以下は、それを行ったときの動作です。

1. ブラウザがリクエストを行います：`GET http://localhost:3000`。
2. Railsアプリケーションがこのリクエストを受け取ります。
3. Railsルータがルートルートを`ArticlesController`の`index`アクションにマッピングします。
4. `index`アクションは`Article`モデルを使用してデータベースからすべての記事を取得します。
5. Railsは自動的に`app/views/articles/index.html.erb`ビューをレンダリングします。
6. ビューのERBコードが評価されてHTMLが出力されます。
7. サーバはHTMLを含むレスポンスをブラウザに送信します。

すべてのMVCのピースを組み合わせ、最初のコントローラアクションを持っています！次に、2番目のアクションに移りましょう。

CRUDit Where CRUDit Is Due
--------------------------

ほとんどのWebアプリケーションには、[CRUD（作成、読み取り、更新、削除）](
https://en.wikipedia.org/wiki/Create,_read,_update,_and_delete)の操作が含まれています。実際、アプリケーションのほとんどの作業がCRUDであることさえあるかもしれません。Railsはこれを認識し、CRUDを行うコードを簡素化するための多くの機能を提供しています。

この機能を探索するために、アプリケーションにさらなる機能を追加してみましょう。

### 単一の記事の表示

現在、データベース内のすべての記事をリスト表示するビューがあります。単一の記事のタイトルと本文を表示する新しいビューを追加しましょう。

まず、新しいルートを追加して新しいコントローラアクションにマッピングする新しいルートを追加します（次に追加する予定のものです）。`config/routes.rb`を開き、以下の最後のルートを挿入します。

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

新しいルートは別の`get`ルートですが、パスには追加の要素があります：`:id`。これはルート*パラメータ*を指定します。ルートパラメータは、リクエストのパスのセグメントをキャプチャし、その値をコントローラアクションでアクセス可能な`params`ハッシュに入れます。たとえば、`GET http://localhost:3000/articles/1`のようなリクエストを処理する場合、`1`は`:id`の値としてキャプチャされ、それは`ArticlesController`の`show`アクションで`params[:id]`としてアクセスできるようになります。
`show`アクションを`index`アクションの下に追加しましょう。`app/controllers/articles_controller.rb`に以下のコードを追加します。

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

`show`アクションは、ルートパラメータでキャプチャされたIDを使用して`Article.find`（前述の通り）を呼び出します。返された記事は`@article`インスタンス変数に格納されるため、ビューからアクセスできます。デフォルトでは、`show`アクションは`app/views/articles/show.html.erb`をレンダリングします。

次に、以下の内容で`app/views/articles/show.html.erb`を作成しましょう。

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

これで、<http://localhost:3000/articles/1>にアクセスすると記事が表示されます！

最後に、記事のページに移動するための便利な方法を追加しましょう。`app/views/articles/index.html.erb`の各記事のタイトルをそのページにリンクさせます。

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

### リソースフルなルーティング

これまで、CRUDの「R」（Read）について説明しました。次に、「C」（Create）、
「U」（Update）、および「D」（Delete）をカバーします。これらの操作を実行するために、新しいルート、コントローラのアクション、ビューを追加します。ルート、コントローラのアクション、ビューが組み合わさってエンティティのCRUD操作を実行する場合、そのエンティティを「リソース」と呼びます。例えば、このアプリケーションでは、記事がリソースであると言えます。

Railsは、[`resources`](
https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources)というルートメソッドを提供しており、コレクションのリソース（例：記事）に対してすべての標準的なルートをマッピングします。したがって、「C」、「U」、「D」のセクションに進む前に、`config/routes.rb`の2つの`get`ルートを`resources`で置き換えましょう。

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

`bin/rails routes`コマンドを実行してマッピングされたルートを確認できます。

```bash
$ bin/rails routes
      Prefix Verb   URI Pattern                  Controller#Action
        root GET    /                            articles#index
    articles GET    /articles(.:format)          articles#index
 new_article GET    /articles/new(.:format)      articles#new
     article GET    /articles/:id(.:format)      articles#show
             POST   /articles(.:format)          articles#create
edit_article GET    /articles/:id/edit(.:format) articles#edit
             PATCH  /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
```

`resources`メソッドは、URLとパスのヘルパーメソッドも設定します。これらのヘルパーメソッドは、コードが特定のルート構成に依存しないようにするために使用できます。上記の「Prefix」列の値に`_url`または`_path`の接尾辞を追加したものがこれらのヘルパーメソッドの名前になります。例えば、`article_path`ヘルパーは、記事が与えられた場合に`"/articles/#{article.id}"`を返します。これを使用して、`app/views/articles/index.html.erb`のリンクを整理できます。

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

さらに、[`link_to`](
https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)ヘルパーを使用して、さらに改善します。`link_to`ヘルパーは、最初の引数をリンクのテキストとし、2番目の引数をリンクの先としてリンクをレンダリングします。2番目の引数にモデルオブジェクトを渡すと、`link_to`は適切なパスヘルパーを呼び出してオブジェクトをパスに変換します。例えば、記事を渡すと、`link_to`は`article_path`を呼び出します。したがって、`app/views/articles/index.html.erb`は次のようになります。

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

素晴らしいですね！

TIP: ルーティングについて詳しくは、[Rails Routing from the Outside In](
routing.html)を参照してください。

### 新しい記事の作成

次に、CRUDの「C」（Create）に進みます。通常、Webアプリケーションでは、新しいリソースを作成するためには複数のステップが必要です。まず、ユーザーは入力フォームをリクエストします。次に、ユーザーがフォームを送信します。エラーがない場合、リソースが作成され、確認が表示されます。エラーがある場合は、フォームがエラーメッセージとともに再表示され、プロセスが繰り返されます。

Railsアプリケーションでは、これらのステップは通常、コントローラの`new`アクションと`create`アクションで処理されます。`app/controllers/articles_controller.rb`に、これらのアクションの典型的な実装を追加しましょう。`show`アクションの下に以下のコードを追加します。

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

`new`アクションは新しい記事をインスタンス化しますが、保存はしません。この記事は、ビューでフォームを構築する際に使用されます。デフォルトでは、`new`アクションは`app/views/articles/new.html.erb`をレンダリングします。次に、このファイルを作成します。
`create`アクションは、タイトルと本文の値を持つ新しい記事をインスタンス化し、保存を試みます。記事が正常に保存された場合、アクションはブラウザを記事のページにリダイレクトします。URLは`"http://localhost:3000/articles/#{@article.id}"`です。
保存に失敗した場合、アクションはフォームを再表示し、ステータスコード[422 Unprocessable Entity](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/422)で`app/views/articles/new.html.erb`をレンダリングします。
ここでのタイトルと本文はダミーの値です。フォームを作成した後、これらを変更します。

注意：[`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to)は、ブラウザが新しいリクエストを行うため、
[`render`](https://api.rubyonrails.org/classes/AbstractController/Rendering.html#method-i-render)は現在のリクエストに対して指定されたビューをレンダリングします。
データベースやアプリケーションの状態を変更した後は、`redirect_to`を使用することが重要です。
そうしないと、ユーザーがページを更新すると、ブラウザが同じリクエストを行い、変更が繰り返されます。

#### フォームビルダーの使用

フォームを作成するためにRailsの機能である*フォームビルダー*を使用します。フォームビルダーを使用すると、最小限のコードで設定が完了し、Railsの規約に従ったフォームを出力することができます。

以下の内容で`app/views/articles/new.html.erb`を作成しましょう。

```html+erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

[`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)ヘルパーメソッドは、フォームビルダーをインスタンス化します。`form_with`ブロック内で、フォームビルダーの[`label`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-label)や[`text_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_field)などのメソッドを呼び出して適切なフォーム要素を出力します。

`form_with`の呼び出し結果は次のようになります。

```html
<form action="/articles" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="...">

  <div>
    <label for="article_title">Title</label><br>
    <input type="text" name="article[title]" id="article_title">
  </div>

  <div>
    <label for="article_body">Body</label><br>
    <textarea name="article[body]" id="article_body"></textarea>
  </div>

  <div>
    <input type="submit" name="commit" value="Create Article" data-disable-with="Create Article">
  </div>
</form>
```

TIP: フォームビルダーについて詳しくは、[Action View Form Helpers](form_helpers.html)を参照してください。

#### ストロングパラメータの使用

送信されたフォームデータは、キャプチャされたルートパラメータとともに`params`ハッシュに格納されます。したがって、`create`アクションは、`params[:article][:title]`を介して送信されたタイトルにアクセスし、`params[:article][:body]`を介して送信された本文にアクセスすることができます。
これらの値を個別に`Article.new`に渡すこともできますが、冗長でエラーの原因になる可能性があります。さらに、フィールドを追加するにつれて悪化します。

代わりに、値が含まれる単一のハッシュを渡します。ただし、そのハッシュ内で許可される値を指定する必要があります。そうしないと、悪意のあるユーザーが追加のフォームフィールドを送信してプライベートデータを上書きする可能性があります。実際には、未フィルタリングの`params[:article]`ハッシュを直接`Article.new`に渡すと、Railsは`ForbiddenAttributesError`を発生させて問題を警告します。
そのため、Railsの機能である*ストロングパラメータ*を使用して`params`をフィルタリングします。`params`のために`article_params`という名前のプライベートメソッドを`app/controllers/articles_controller.rb`の最後に追加しましょう。そして、`create`を変更してそれを使用します。

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

TIP: ストロングパラメータについて詳しくは、[Action Controller Overview § Strong Parameters](action_controller_overview.html#strong-parameters)を参照してください。

#### バリデーションとエラーメッセージの表示

これまで見てきたように、リソースの作成は複数のステップからなるプロセスです。無効なユーザー入力の処理もそのプロセスの一部です。Railsは、無効なユーザー入力に対処するための*バリデーション*という機能を提供しています。バリデーションは、モデルオブジェクトが保存される前にチェックされるルールです。チェックのいずれかが失敗した場合、保存は中止され、適切なエラーメッセージがモデルオブジェクトの`errors`属性に追加されます。

`app/models/article.rb`にモデルにいくつかのバリデーションを追加しましょう。

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

最初のバリデーションは、`title`の値が存在する必要があることを宣言しています。`title`は文字列なので、`title`の値には少なくとも1つの空白以外の文字が含まれている必要があります。

2番目のバリデーションは、`body`の値も存在する必要があることを宣言しています。さらに、`body`の値は少なくとも10文字である必要があります。

注意：`title`と`body`の属性がどこで定義されているか疑問に思うかもしれません。Active Recordは、すべてのテーブル列に対してモデル属性を自動的に定義するため、モデルファイルでこれらの属性を宣言する必要はありません。
バリデーションが完了したので、`app/views/articles/new.html.erb`を変更して`title`と`body`のエラーメッセージを表示しましょう。

```html+erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

[`full_messages_for`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_messages_for)メソッドは、指定された属性に対するユーザーフレンドリーなエラーメッセージの配列を返します。その属性にエラーがない場合、配列は空になります。

これがどのように動作するかを理解するために、`new`と`create`のコントローラーアクションをもう一度見てみましょう。

```ruby
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
```

<http://localhost:3000/articles/new>にアクセスすると、`GET /articles/new`リクエストは`new`アクションにマッピングされます。`new`アクションは`@article`を保存しようとしません。そのため、バリデーションはチェックされず、エラーメッセージは表示されません。

フォームを送信すると、`POST /articles`リクエストが`create`アクションにマッピングされます。`create`アクションは`@article`を保存しようとします。そのため、バリデーションがチェックされます。バリデーションに失敗した場合、`@article`は保存されず、`app/views/articles/new.html.erb`がエラーメッセージと共にレンダリングされます。

TIP: バリデーションについて詳しくは、[Active Record Validations](active_record_validations.html)を参照してください。バリデーションエラーメッセージについて詳しくは、[Active Record Validations § Working with Validation Errors](active_record_validations.html#working-with-validation-errors)を参照してください。

#### 最後に

<http://localhost:3000/articles/new>を訪れることで記事を作成できます。最後に、`app/views/articles/index.html.erb`の最下部にそのページへのリンクを追加しましょう。

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

### 記事の更新

CRUDの「CR」をカバーしました。次は「U」（更新）に移りましょう。リソースの更新はリソースの作成と非常に似ています。両方とも複数のステップで行われるプロセスです。まず、ユーザーはデータを編集するためのフォームをリクエストします。次に、ユーザーがフォームを送信します。エラーがない場合、リソースが更新されます。それ以外の場合、フォームがエラーメッセージと共に再表示され、プロセスが繰り返されます。

これらのステップは、通常、コントローラーの`edit`と`update`アクションで処理されます。`create`アクションの下にこれらのアクションの典型的な実装を追加しましょう。

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

`edit`と`update`アクションが`new`と`create`アクションに似ていることに注意してください。

`edit`アクションはデータベースから記事を取得し、フォームを構築する際に使用するために`@article`に保存します。デフォルトでは、`edit`アクションは`app/views/articles/edit.html.erb`をレンダリングします。

`update`アクションは（再）データベースから記事を取得し、`article_params`でフィルタリングされた送信されたフォームデータで更新を試みます。バリデーションが失敗せずに更新が成功した場合、アクションはブラウザを記事のページにリダイレクトします。それ以外の場合、アクションはエラーメッセージと共にフォームを再表示するために`app/views/articles/edit.html.erb`をレンダリングします。

#### パーシャルを使用してビューコードを共有する

`edit`フォームは`new`フォームと同じになります。Railsのフォームビルダーとリソースフルルーティングのおかげで、コードも同じになります。フォームビルダーは、モデルオブジェクトが以前に保存されているかどうかに基づいて、適切な種類のリクエストを行うようにフォームを自動的に設定します。

コードが同じであるため、それを共有ビューである*パーシャル*に分解します。`app/views/articles/_form.html.erb`を作成し、次の内容を追加します。

```html+erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```
上記のコードは、`app/views/articles/new.html.erb`のフォームと同じですが、`@article`のすべての出現箇所が`article`に置き換えられています。
パーシャルは共有コードなので、コントローラアクションによって設定された特定のインスタンス変数に依存しないようにするのがベストプラクティスです。その代わりに、パーシャルに記事をローカル変数として渡します。

`app/views/articles/new.html.erb`を[`render`]（https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render）を使用してパーシャルを使用するように更新しましょう。

```html+erb
<h1>New Article</h1>

<%= render "form", article: @article %>
```

注意：パーシャルのファイル名は、アンダースコアで始まる必要があります。例：`_form.html.erb`。ただし、レンダリングする際にはアンダースコアなしで参照されます。例：`render "form"`。

そして、非常に似たような`app/views/articles/edit.html.erb`を作成しましょう。

```html+erb
<h1>Edit Article</h1>

<%= render "form", article: @article %>
```

ヒント：パーシャルについて詳しくは、[Railsのレイアウトとレンダリング § パーシャルの使用](layouts_and_rendering.html#using-partials)を参照してください。

#### 完了

記事の編集ページにアクセスすることで、記事を更新できるようになりました。例：`http://localhost:3000/articles/1/edit`。最後に、`app/views/articles/show.html.erb`の最下部に編集ページへのリンクを追加しましょう。

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
</ul>
```

### 記事の削除

最後に、CRUDの「D」（Delete）に到達します。リソースの削除は作成や更新よりも簡単なプロセスです。ルートとコントローラアクションのみが必要です。そして、リソースフルなルーティング（`resources :articles`）は、`ArticlesController`の`destroy`アクションに`DELETE /articles/:id`リクエストをマッピングするルートを既に提供しています。

したがって、`app/controllers/articles_controller.rb`に`update`アクションの下に典型的な`destroy`アクションを追加しましょう。

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

`destroy`アクションは、データベースから記事を取得し、それに対して[`destroy`]（https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy）を呼び出します。その後、ルートパスにブラウザをリダイレクトし、ステータスコード[303 See Other]（https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/303）を返します。

記事へのメインアクセスポイントがルートパスであるため、ルートパスにリダイレクトすることを選択しました。ただし、他の状況では、`articles_path`などにリダイレクトすることもあります。

では、`app/views/articles/show.html.erb`の最下部にリンクを追加して、記事をそのページから削除できるようにしましょう。

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>
```

上記のコードでは、`data`オプションを使用して「Destroy」リンクの`data-turbo-method`と`data-turbo-confirm`のHTML属性を設定しています。これらの属性は、デフォルトで新しいRailsアプリケーションに含まれている[Turbo]（https://turbo.hotwired.dev/）にフックされます。`data-turbo-method="delete"`は、リンクが`GET`リクエストではなく`DELETE`リクエストを行うようにします。`data-turbo-confirm="Are you sure?"`は、リンクがクリックされたときに確認ダイアログが表示されるようにします。ユーザーがダイアログをキャンセルすると、リクエストは中止されます。

以上です！記事の一覧表示、表示、作成、更新、削除ができるようになりました！InCRUDable！

2つ目のモデルの追加
---------------------

アプリケーションに2つ目のモデルを追加する時が来ました。2つ目のモデルは、記事へのコメントを扱います。

### モデルの生成

前に`Article`モデルを作成したときと同じジェネレータを見てみましょう。今回は、記事への参照を保持する`Comment`モデルを作成します。ターミナルで次のコマンドを実行してください。

```bash
$ bin/rails generate model Comment commenter:string body:text article:references
```

このコマンドにより、4つのファイルが生成されます。

| ファイル                                         | 目的                                                                                                 |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| db/migrate/20140120201010_create_comments.rb | データベースにコメントテーブルを作成するマイグレーション（名前には異なるタイムスタンプが含まれます） |
| app/models/comment.rb                        | Commentモデル                                                                                      |
| test/models/comment_test.rb                  | Commentモデルのテストハーネス                                                                 |
| test/fixtures/comments.yml                   | テスト用のサンプルコメント                                                                     |

まず、`app/models/comment.rb`を見てみましょう。

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

これは、先ほど見た`Article`モデルと非常に似ています。違いは、`belongs_to :article`という行で、Active Recordの_関連付け_を設定していることです。関連付けについては、このガイドの次のセクションで少し学びます。
シェルコマンドで使用される(`:references`)キーワードは、モデルのための特別なデータ型です。
これにより、提供されたモデル名に`_id`が追加された新しい列がデータベーステーブルに作成され、整数値を保持することができます。より良い理解を得るために、マイグレーションを実行した後に`db/schema.rb`ファイルを分析してください。

モデルに加えて、Railsは対応するデータベーステーブルを作成するためのマイグレーションも作成しました。

```ruby
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

`t.references`の行は、`article_id`という名前の整数列、それに対するインデックス、および`articles`テーブルの`id`列を指す外部キー制約を作成します。マイグレーションを実行してください。

```bash
$ bin/rails db:migrate
```

Railsは、現在のデータベースに対してまだ実行されていないマイグレーションのみを実行するように賢く設計されているため、この場合は次のように表示されます。

```
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```

### モデルの関連付け

Active Recordの関連付けを使用すると、2つのモデル間の関係を簡単に宣言できます。コメントと記事の場合、関係を次のように書くことができます。

* 各コメントは1つの記事に所属します。
* 1つの記事には複数のコメントがあります。

実際には、これはRailsがこの関連付けを宣言するために使用する構文に非常に近いです。すでに`Comment`モデル(`app/models/comment.rb`)内のコード行を見たことがあります。それにより、各コメントが記事に所属するようになります。

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

関連付けのもう一方の側面を追加するために、`app/models/article.rb`を編集する必要があります。

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

これらの2つの宣言により、多くの自動動作が可能になります。たとえば、記事を含むインスタンス変数`@article`がある場合、`@article.comments`を使用してその記事に所属するすべてのコメントを配列として取得できます。

TIP: Active Recordの関連付けの詳細については、[Active Record Associations](association_basics.html)ガイドを参照してください。

### コメントのルートの追加

`articles`コントローラと同様に、`comments`を表示するためのルートを追加する必要があります。再度、`config/routes.rb`ファイルを開き、次のように編集します。

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

これにより、`comments`が`articles`のネストされたリソースとして作成されます。これは、記事とコメントの階層関係をキャプチャするための別の部分です。

TIP: ルーティングの詳細については、[Rails Routing](routing.html)ガイドを参照してください。

### コントローラの生成

モデルができたので、次は対応するコントローラを作成することにします。前と同じジェネレータを使用します。

```bash
$ bin/rails generate controller Comments
```

これにより、3つのファイルと1つの空のディレクトリが作成されます。

| ファイル/ディレクトリ                           | 目的                                     |
| -------------------------------------------- | ---------------------------------------- |
| app/controllers/comments_controller.rb       | Commentsコントローラ                      |
| app/views/comments/                          | コントローラのビューがここに保存されます  |
| test/controllers/comments_controller_test.rb | コントローラのテスト                      |
| app/helpers/comments_helper.rb               | ビューヘルパーファイル                    |

ブログの場合と同様に、読者は記事を読んだ直後にコメントを作成し、コメントを追加した後は記事の表示ページに戻されます。そのため、`CommentsController`はコメントを作成し、スパムコメントが到着した場合に削除するためのメソッドを提供するために存在します。

まず、`Article`の表示テンプレート(`app/views/articles/show.html.erb`)を編集して、新しいコメントを作成できるようにします。

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

これにより、`Article`の表示ページにフォームが追加され、`CommentsController`の`create`アクションを呼び出して新しいコメントを作成します。ここでの`form_with`呼び出しでは、配列が使用され、`/articles/1/comments`のようなネストされたルートが作成されます。
`app/controllers/comments_controller.rb`にある`create`を配線しましょう：

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

ここでは、記事のコントローラーに比べて少し複雑さが増しています。これは、ネスト構造の影響です。コメントのリクエストごとに、コメントが関連付けられる記事を追跡する必要があります。そのため、`Article`モデルの`find`メソッドを呼び出して、対象の記事を取得しています。

さらに、コードは関連付けに利用できるいくつかのメソッドを活用しています。`@article.comments`上の`create`メソッドを使用して、コメントを作成して保存しています。これにより、コメントが特定の記事に所属するように自動的にリンクされます。

新しいコメントを作成したら、`article_path(@article)`ヘルパーを使用してユーザーを元の記事に戻します。既に見たように、これは`ArticlesController`の`show`アクションを呼び出し、`show.html.erb`テンプレートをレンダリングします。ここにコメントを表示したいので、`app/views/articles/show.html.erb`に追加しましょう。

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Comments</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

これで、ブログに記事とコメントを追加し、適切な場所に表示することができます。

![Article with Comments](images/getting_started/article_with_comments.png)

リファクタリング
-----------

記事とコメントが機能するようになったので、`app/views/articles/show.html.erb`テンプレートを見てみましょう。長くて扱いにくいです。パーシャルを使用して整理することができます。

### パーシャルコレクションのレンダリング

まず、記事のすべてのコメントを表示するためのコメントパーシャルを作成します。`app/views/comments/_comment.html.erb`というファイルを作成し、次のコードを追加します：

```html+erb
<p>
  <strong>Commenter:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comment:</strong>
  <%= comment.body %>
</p>
```

次に、`app/views/articles/show.html.erb`を以下のように変更します：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

これにより、`app/views/comments/_comment.html.erb`のパーシャルが`@article.comments`コレクション内の各コメントに対して一度ずつレンダリングされます。`render`メソッドは`@article.comments`コレクションを反復処理するときに、各コメントをパーシャルと同じ名前のローカル変数（この場合は`comment`）に代入し、パーシャル内で使用できるようにします。

### パーシャルフォームのレンダリング

次に、新しいコメントセクションを独自のパーシャルに移動しましょう。`app/views/comments/_form.html.erb`というファイルを作成し、次のコードを追加します：

```html+erb
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

次に、`app/views/articles/show.html.erb`を以下のように変更します：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= render 'comments/form' %>
```

2番目の`render`は、レンダリングしたいパーシャルテンプレート`comments/form`を定義しています。Railsは、その文字列内のスラッシュを認識し、`app/views/comments`ディレクトリ内の`_form.html.erb`ファイルをレンダリングすることを理解します。

`@article`オブジェクトは、ビューでレンダリングされるすべてのパーシャルで利用できます。なぜなら、それをインスタンス変数として定義したからです。

### Concernの使用

Concernは、大きなコントローラーやモデルを理解しやすく管理しやすくするための方法です。また、複数のモデル（またはコントローラー）で同じConcernを共有する場合に再利用性の利点もあります。Concernは、モデルまたはコントローラーが担当する機能の明確に定義されたスライスを表すメソッドを含むモジュールを使用して実装されます。他の言語では、モジュールはしばしばミックスインとして知られています。
コントローラやモデルでconcernsを使用するには、他のモジュールと同じように使用できます。`rails new blog`でアプリを作成したときに、`app/`内に2つのフォルダが作成されました。

```
app/controllers/concerns
app/models/concerns
```

以下の例では、concernを使用することでメンテナンス性とDRYさを向上させることができる、ブログの新しい機能を実装します。

ブログ記事にはさまざまなステータスがあります。例えば、誰にでも表示される（つまり`public`）、または著者のみに表示される（つまり`private`）などです。また、非表示になっているが取得可能な状態（つまり`archived`）もあります。コメントも同様に非表示または表示される場合があります。これは、各モデルに`status`カラムを使用して表すことができます。

まず、以下のマイグレーションを実行して`Articles`と`Comments`に`status`を追加します。

```bash
$ bin/rails generate migration AddStatusToArticles status:string
$ bin/rails generate migration AddStatusToComments status:string
```

次に、生成されたマイグレーションでデータベースを更新します。

```bash
$ bin/rails db:migrate
```

既存の記事とコメントのステータスを選択するには、生成されたマイグレーションファイルに`default: "public"`オプションを追加してマイグレーションを再度実行することができます。または、railsコンソールで`Article.update_all(status: "public")`と`Comment.update_all(status: "public")`を呼び出すこともできます。

TIP: マイグレーションについて詳しくは、[Active Record Migrations](active_record_migrations.html)を参照してください。

また、`app/controllers/articles_controller.rb`で`strong parameter`の一部として`:status`キーを許可する必要があります。

```ruby

  private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
```

そして、`app/controllers/comments_controller.rb`でも同様に設定します。

```ruby

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

`article`モデル内では、`bin/rails db:migrate`コマンドを使用して`status`カラムを追加するマイグレーションを実行した後に、次のように追加します。

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

そして、`Comment`モデル内では次のようにします。

```ruby
class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

次に、`index`アクションのテンプレート（`app/views/articles/index.html.erb`）では、`archived?`メソッドを使用してアーカイブされた記事を表示しないようにします。

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

同様に、コメントの部分ビュー（`app/views/comments/_comment.html.erb`）では、アーカイブされたコメントを表示しないようにします。

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>
```

ただし、モデルを再度確認すると、ロジックが重複していることがわかります。将来的にブログの機能を拡張し、プライベートメッセージなどを含める場合、ロジックが再度重複する可能性があります。ここでconcernsが役立ちます。

concernは、モデルの責任範囲の一部にのみ責任を持つものです。concern内のメソッドはすべてモデルの可視性に関連しています。新しいconcern（モジュール）を`Visible`と呼びましょう。`app/models/concerns`内に`visible.rb`という新しいファイルを作成し、モデルで重複していたすべてのステータスメソッドを保存します。

`app/models/concerns/visible.rb`

```ruby
module Visible
  def archived?
    status == 'archived'
  end
end
```

concernにステータスのバリデーションを追加することもできますが、これはやや複雑です。バリデーションはクラスレベルで呼び出されるメソッドです。`ActiveSupport::Concern`（[APIガイド](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)）を使用すると、簡単に含めることができます。

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  def archived?
    status == 'archived'
  end
end
```

これで、各モデルから重複したロジックを削除し、新しい`Visible`モジュールを含めることができます。

`app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

`app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  include Visible

  belongs_to :article
end
```
クラスメソッドはconcernにも追加することができます。メインページに公開された記事やコメントの数を表示したい場合、Visibleにクラスメソッドを追加することができます。

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      where(status: 'public').count
    end
  end

  def archived?
    status == 'archived'
  end
end
```

ビューでは、通常のクラスメソッドのように呼び出すことができます。

```html+erb
<h1>Articles</h1>

Our blog has <%= Article.public_count %> articles and counting!

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

次に、フォームに選択ボックスを追加し、ユーザーが新しい記事を作成したり、新しいコメントを投稿する際にステータスを選択できるようにします。デフォルトのステータスを「public」に指定することもできます。`app/views/articles/_form.html.erb`に以下を追加します。

```html+erb
<div>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</div>
```

そして、`app/views/comments/_form.html.erb`に以下を追加します。

```html+erb
<p>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</p>
```

コメントの削除
-----------------

ブログのもう一つの重要な機能は、スパムコメントを削除できることです。これを行うには、ビューにリンクを実装し、`CommentsController`に`destroy`アクションを追加する必要があります。

まず、`app/views/comments/_comment.html.erb`のパーシャルに削除リンクを追加します。

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>

  <p>
    <%= link_to "Destroy Comment", [comment.article, comment], data: {
                  turbo_method: :delete,
                  turbo_confirm: "Are you sure?"
                } %>
  </p>
<% end %>
```

この新しい「Destroy Comment」リンクをクリックすると、`DELETE /articles/:article_id/comments/:id`が`CommentsController`に送信され、コメントを削除するために使用されます。そのため、コントローラーに`destroy`アクションを追加します（`app/controllers/comments_controller.rb`）。

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), status: :see_other
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
end
```

`destroy`アクションでは、対象の記事を見つけ、`@article.comments`コレクション内のコメントを特定し、データベースから削除し、記事の表示アクションに戻ります。

### 関連オブジェクトの削除

記事を削除すると、関連するコメントも削除する必要があります。そうしないと、データベースに単にスペースを占有するだけになります。Railsでは、関連の`dependent`オプションを使用してこれを実現することができます。`app/models/article.rb`のArticleモデルを以下のように変更します。

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

セキュリティ
--------

### ベーシック認証

ブログをオンラインで公開する場合、誰でも記事を追加、編集、削除したり、コメントを削除することができます。

Railsには、このような状況でうまく機能するHTTP認証システムが用意されています。

`ArticlesController`では、各アクションへのアクセスを認証されていない場合にブロックする方法が必要です。Railsの`http_basic_authenticate_with`メソッドを使用することで、要求されたアクションへのアクセスが許可される場合、そのメソッドを使用することができます。

認証システムを使用するために、`ArticlesController`の先頭に指定します。この場合、`index`と`show`以外のすべてのアクションでユーザーが認証されるようにしたいので、次のように記述します。

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # 省略
```

コメントの削除も認証されたユーザーのみ許可するようにしたいので、`CommentsController`（`app/controllers/comments_controller.rb`）に次のように記述します。

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # 省略
```

これで、新しい記事を作成しようとすると、基本的なHTTP認証のチャレンジが表示されます。

![Basic HTTP Authentication Challenge](images/getting_started/challenge.png)

正しいユーザー名とパスワードを入力すると、異なるユーザー名とパスワードが必要になるか、ブラウザが閉じられるまで認証が維持されます。
Railsアプリケーションでは、他の認証方法も利用できます。Rails向けの人気のある認証アドオンには、[Devise](https://github.com/plataformatec/devise) railsエンジンと[Authlogic](https://github.com/binarylogic/authlogic) gemがあります。他にもいくつかの認証方法があります。

### その他のセキュリティに関する考慮事項

セキュリティは、特にWebアプリケーションにおいて広範かつ詳細な領域です。Railsアプリケーションのセキュリティについては、[Ruby on Railsセキュリティガイド](security.html)で詳しく説明されています。

次は何ですか？
------------

最初のRailsアプリケーションを見たので、自由に更新したり、自分で実験したりすることができます。

覚えておいてください、すべてを一人でやる必要はありません。Railsの使用方法に関するサポートが必要な場合は、次のサポートリソースを参照してください。

* [Ruby on Railsガイド](index.html)
* [Ruby on Railsメーリングリスト](https://discuss.rubyonrails.org/c/rubyonrails-talk)

設定の注意点
---------------------

Railsで作業する最も簡単な方法は、すべての外部データをUTF-8で保存することです。そうしないと、RubyライブラリやRailsは、ネイティブデータをUTF-8に変換できることが多いですが、これは常に信頼性がありません。したがって、すべての外部データがUTF-8であることを確認する方が良いです。

この領域でミスをした場合、最も一般的な症状は、ブラウザに黒いダイヤモンドと内部に疑問符が表示されることです。もう一つの一般的な症状は、"Ã¼"のような文字が表示されることです。Railsは、これらの問題の一般的な原因を軽減するために、自動的に検出および修正できるいくつかの内部手順を実行します。ただし、UTF-8以外の形式で保存されている外部データがある場合、Railsでは自動的に検出および修正できないこの種の問題が発生することがあります。

UTF-8以外の非常に一般的なデータソースは次のとおりです。

* テキストエディタ：ほとんどのテキストエディタ（TextMateなど）は、ファイルをUTF-8で保存するようにデフォルトになっています。テキストエディタがそうでない場合、テンプレートに入力した特殊文字（例：é）がブラウザでダイヤモンドと疑問符の内部で表示されることがあります。これはi18nの翻訳ファイルにも適用されます。UTF-8をデフォルトにしないほとんどのエディタ（Dreamweaverの一部のバージョンなど）は、デフォルトをUTF-8に変更する方法を提供しています。変更してください。
* データベース：Railsは、データベースからのデータをUTF-8に変換することをデフォルトで行います。ただし、データベースが内部的にUTF-8を使用していない場合、ユーザーが入力したすべての文字を保存できない場合があります。たとえば、データベースが内部的にLatin-1を使用している場合、ユーザーがロシア語、ヘブライ語、または日本語の文字を入力した場合、データはデータベースに入力された時点で永久に失われます。可能であれば、データベースの内部ストレージにUTF-8を使用してください。
