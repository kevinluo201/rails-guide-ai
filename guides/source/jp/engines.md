**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2aedcd7fcf6f0b83538e8a8220d38afd
エンジンを使い始める
====================

このガイドでは、エンジンについて学び、クリーンで使いやすいインターフェースを通じてホストアプリケーションに追加の機能を提供する方法を学びます。

このガイドを読み終えると、以下のことがわかるようになります：

* エンジンとは何か。
* エンジンを生成する方法。
* エンジンのための機能を構築する方法。
* エンジンをアプリケーションにフックする方法。
* アプリケーションでエンジンの機能をオーバーライドする方法。
* ロードと設定フックを使用してRailsフレームワークを読み込まない方法。

--------------------------------------------------------------------------------

エンジンとは何ですか？
-----------------------

エンジンは、ホストアプリケーションに機能を提供するミニアチュアアプリケーションと考えることができます。Railsアプリケーションは実際には「スーパーチャージされた」エンジンであり、`Rails::Application`クラスが`Rails::Engine`から多くの振る舞いを継承しています。

したがって、エンジンとアプリケーションはほとんど同じものと考えることができますが、微妙な違いがあります。また、エンジンとアプリケーションは共通の構造を共有しています。

エンジンはプラグインとも密接に関連しています。両者は共通の`lib`ディレクトリ構造を共有し、`rails plugin new`ジェネレータを使用して両方を生成します。違いは、エンジンがRailsによって「完全なプラグイン」と見なされることです（ジェネレータコマンドに渡される`--full`オプションで示されます）。ここでは実際には`--mountable`オプションを使用しますが、これには`--full`のすべての機能とそれ以上が含まれます。このガイドでは、これらの「完全なプラグイン」を単に「エンジン」と呼びます。エンジンはプラグインであり、プラグインはエンジンである可能性があります。

このガイドで作成するエンジンの名前は「blorgh」とします。このエンジンはホストアプリケーションにブログの機能を提供し、新しい記事とコメントを作成することができます。このガイドの最初ではエンジン自体での作業に集中しますが、後のセクションではアプリケーションにフックする方法を見ていきます。

エンジンはホストアプリケーションから分離することもできます。これは、アプリケーションが`articles_path`などのルーティングヘルパーで提供されるパスを持ち、同じく`articles_path`というパスを提供するエンジンを使用でき、両者が衝突しないことを意味します。これに加えて、コントローラ、モデル、テーブル名も名前空間で分けられます。このガイドの後半でその方法を見ていきます。

常にアプリケーションがエンジンよりも優先されることを心に留めておくことは重要です。アプリケーションは自身の環境で何が起こるかについて最終的な判断を下すオブジェクトです。エンジンはアプリケーションを大幅に変更するのではなく、それを強化する役割を果たすべきです。

他のエンジンのデモンストレーションを見るには、[Devise](https://github.com/plataformatec/devise)（親アプリケーションに認証機能を提供するエンジン）や[Thredded](https://github.com/thredded/thredded)（フォーラム機能を提供するエンジン）をチェックしてみてください。また、[Spree](https://github.com/spree/spree)は電子商取引プラットフォームを提供し、[Refinery CMS](https://github.com/refinery/refinerycms)はCMSエンジンです。

最後に、James Adam、Piotr Sarnacki、Rails Core Team、およびその他の多くの人々のおかげでエンジンは可能になりました。彼らに会ったらお礼を言うのを忘れないでください！

エンジンの生成
----------------

エンジンを生成するには、プラグインジェネレータを実行し、必要なオプションを渡す必要があります。例えば、「blorgh」の場合、ターミナルで次のコマンドを実行します：

```bash
$ rails plugin new blorgh --mountable
```

プラグインジェネレータのオプションの完全なリストは、次のコマンドを入力して確認できます：

```bash
$ rails plugin --help
```

`--mountable`オプションは、"mountable"で名前空間が分離されたエンジンを作成することをジェネレータに伝えます。このジェネレータは、`--full`オプションと同じ骨組みの構造を提供します。`--full`オプションは、次のものを提供する骨組みの構造を含むエンジンを作成することをジェネレータに伝えます：

  * `app`ディレクトリツリー
  * `config/routes.rb`ファイル：

    ```ruby
    Rails.application.routes.draw do
    end
    ```

  * `lib/blorgh/engine.rb`というファイル。これは、標準のRailsアプリケーションの`config/application.rb`ファイルと同じ機能を持っています：

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
      end
    end
    ```

`--mountable`オプションは、`--full`オプションに以下を追加します：

  * アセットマニフェストファイル（`blorgh_manifest.js`と`application.css`）
  * 名前空間が分離された`ApplicationController`のスタブ
  * 名前空間が分離された`ApplicationHelper`のスタブ
  * エンジン用のレイアウトビューテンプレート
  * `config/routes.rb`への名前空間の分離：
```ruby
Blorgh::Engine.routes.draw do
end
```

* `lib/blorgh/engine.rb`に名前空間の分離を追加します：

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

さらに、`--mountable`オプションは、ダミーテストアプリケーション（`test/dummy`にある）にエンジンをマウントするために、ダミーアプリケーションのルートファイル（`test/dummy/config/routes.rb`）に次のコードを追加します：

```ruby
mount Blorgh::Engine => "/blorgh"
```

### エンジン内部

#### 重要なファイル

この新しいエンジンのディレクトリのルートには、`blorgh.gemspec`ファイルがあります。後でこのエンジンをアプリケーションに組み込むときには、Railsアプリケーションの`Gemfile`に次の行を追加します：

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

通常通り`bundle install`を実行することを忘れないでください。`Gemfile`内でそれをgemとして指定することで、Bundlerはこの`blorgh.gemspec`ファイルを解析し、`lib`ディレクトリ内の`lib/blorgh.rb`というファイルを要求します。このファイルは`lib/blorgh/engine.rb`ファイル（`lib/blorgh/engine.rb`にある）を要求し、`Blorgh`というベースモジュールを定義します。

```ruby
require "blorgh/engine"

module Blorgh
end
```

TIP: 一部のエンジンは、このファイルを使用してエンジンのグローバル設定オプションを配置します。それは比較的良いアイデアなので、設定オプションを提供したい場合は、エンジンの`module`が定義されているファイルが完璧です。メソッドをモジュール内に配置すれば、問題ありません。

`lib/blorgh/engine.rb`内には、エンジンのベースクラスがあります：

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

`Rails::Engine`クラスを継承することで、このgemはRailsにエンジンがあることを通知し、アプリケーション内にエンジンを正しくマウントします。これには、モデル、メーラー、コントローラー、ビューのための`app`ディレクトリをロードパスに追加するなどのタスクが含まれます。

ここで特筆すべきは、`isolate_namespace`メソッドです。この呼び出しは、コントローラー、モデル、ルートなどを独自の名前空間に分離する責任を持っています。これにより、エンジンのコンポーネントがアプリケーションに「漏れ出す」ことがなくなり、望ましくない混乱が発生する可能性がなくなります。また、アプリケーション内の同じ名前のコンポーネントによって重要なエンジンのコンポーネントが上書きされる可能性もありません。そのような競合の例の1つは、ヘルパーです。`isolate_namespace`を呼び出さない場合、エンジンのヘルパーはアプリケーションのコントローラーに含まれます。

注意：`isolate_namespace`行は`Engine`クラスの定義内に残すことを**強く**お勧めします。これがないと、エンジンで生成されたクラスがアプリケーションと競合する可能性があります。

名前空間の分離によって、`bin/rails generate model`などの呼び出しで生成されるモデル（たとえば`bin/rails generate model article`）は`Article`と呼ばれるのではなく、名前空間が付いて`Blorgh::Article`と呼ばれます。さらに、モデルのテーブルも名前空間が付き、`blorgh_articles`となります。モデルの名前空間と同様に、`ArticlesController`というコントローラーは`Blorgh::ArticlesController`となり、そのコントローラーのビューは`app/views/articles`ではなく、`app/views/blorgh/articles`になります。メーラー、ジョブ、ヘルパーも同様に名前空間が付きます。

最後に、ルートもエンジン内で分離されます。これは名前空間の中で最も重要な部分の1つであり、後述する[ルート](#routes)のセクションで詳しく説明します。

#### `app`ディレクトリ

`app`ディレクトリ内には、アプリケーションと似ているためにおなじみの`assets`、`controllers`、`helpers`、`jobs`、`mailers`、`models`、`views`ディレクトリがあります。エンジンを作成する際には、モデルの作成時に詳しく見ていきます。

`app/assets`ディレクトリ内には、`images`と`stylesheets`ディレクトリがあります。これもアプリケーションに似ているため、おなじみかもしれません。ただし、ここでは各ディレクトリにエンジン名のサブディレクトリが含まれている点が異なります。このエンジンが名前空間を持つため、そのアセットも名前空間を持つ必要があります。

`app/controllers`ディレクトリ内には、`blorgh`ディレクトリがあり、`application_controller.rb`というファイルが含まれています。このファイルは、エンジンのコントローラーに共通の機能を提供します。`blorgh`ディレクトリは、エンジンの他のコントローラーが配置される場所です。この名前空間のディレクトリに配置することで、他のエンジンやアプリケーション内の同じ名前のコントローラーと衝突する可能性を防ぐことができます。

注意：エンジン内の`ApplicationController`クラスは、Railsアプリケーションと同じように名前付けられています。これにより、アプリケーションをエンジンに簡単に変換できるようになります。
注意：親アプリケーションが`classic`モードで実行されている場合、エンジンコントローラーがメインアプリケーションコントローラーを継承してしまい、エンジンのアプリケーションコントローラーを継承していない状況になる可能性があります。これを防ぐためには、親アプリケーションで`zeitwerk`モードに切り替えることが最善の方法です。そうでない場合は、`require_dependency`を使用してエンジンのアプリケーションコントローラーがロードされるようにします。例：

```ruby
# `classic`モードの場合のみ必要です。
require_dependency "blorgh/application_controller"

module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

警告：自動リロードが壊れるため、`require`は使用しないでください。`require_dependency`を使用することで、クラスが正しい方法でロードおよびアンロードされることが保証されます。

`app/controllers`と同様に、`app/helpers`、`app/jobs`、`app/mailers`、`app/models`ディレクトリの下には`blorgh`サブディレクトリがあり、関連する`application_*.rb`ファイルが含まれています。これにより、これらのサブディレクトリにファイルを配置し、オブジェクトに名前空間を付けることで、他のエンジンまたはアプリケーション内の同じ名前の要素と衝突する可能性を防ぐことができます。

最後に、`app/views`ディレクトリには`layouts`フォルダが含まれており、`blorgh/application.html.erb`というファイルがあります。このファイルを使用すると、エンジンのレイアウトを指定できます。このエンジンをスタンドアロンエンジンとして使用する場合、カスタマイズをこのファイルに追加することで、アプリケーションの`app/views/layouts/application.html.erb`ファイルではなく、エンジンのレイアウトに対してカスタマイズを行うことができます。

エンジンのユーザーにレイアウトを強制したくない場合は、このファイルを削除し、エンジンのコントローラーで異なるレイアウトを参照することができます。

#### `bin`ディレクトリ

このディレクトリには`bin/rails`という1つのファイルが含まれており、アプリケーション内でのサブコマンドとジェネレーターの使用を可能にします。これにより、次のようなコマンドを実行することで、このエンジンの新しいコントローラーとモデルを簡単に生成することができます。

```bash
$ bin/rails generate model
```

もちろん、`Engine`クラスで`isolate_namespace`が呼び出されているエンジン内でこれらのコマンドで生成されたものは、名前空間が付けられます。

#### `test`ディレクトリ

`test`ディレクトリはエンジンのテストが配置される場所です。エンジンをテストするために、`test/dummy`内にRailsアプリケーションの簡略版が埋め込まれています。このアプリケーションは、`test/dummy/config/routes.rb`ファイルでエンジンをマウントします。

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

この行はエンジンをパス`/blorgh`でマウントし、アプリケーション内でのみアクセス可能にします。

`test`ディレクトリ内には、`test/integration`ディレクトリがあり、エンジンの統合テストを配置する場所です。`test`ディレクトリ内には他のディレクトリも作成できます。たとえば、モデルのテストには`test/models`ディレクトリを作成することができます。

エンジンの機能の提供
------------------------------

このガイドでカバーされているエンジンは、記事の投稿とコメント機能を提供し、[入門ガイド](getting_started.html)と似たスレッドをたどります。

注意：このセクションでは、`blorgh`エンジンのディレクトリのルートでコマンドを実行することを確認してください。

### 記事リソースの生成

ブログエンジンの最初の生成物は`Article`モデルと関連するコントローラーです。これを素早く生成するために、Railsのスキャフォールドジェネレーターを使用できます。

```bash
$ bin/rails generate scaffold article title:string text:text
```

このコマンドは次の情報を出力します：

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_articles.rb
create    app/models/blorgh/article.rb
invoke    test_unit
create      test/models/blorgh/article_test.rb
create      test/fixtures/blorgh/articles.yml
invoke  resource_route
 route    resources :articles
invoke  scaffold_controller
create    app/controllers/blorgh/articles_controller.rb
invoke    erb
create      app/views/blorgh/articles
create      app/views/blorgh/articles/index.html.erb
create      app/views/blorgh/articles/edit.html.erb
create      app/views/blorgh/articles/show.html.erb
create      app/views/blorgh/articles/new.html.erb
create      app/views/blorgh/articles/_form.html.erb
invoke    test_unit
create      test/controllers/blorgh/articles_controller_test.rb
create      test/system/blorgh/articles_test.rb
invoke    helper
create      app/helpers/blorgh/articles_helper.rb
invoke      test_unit
```

スキャフォールドジェネレーターが最初に行うことは、`active_record`ジェネレーターを呼び出すことです。これにより、リソースのためのマイグレーションとモデルが生成されます。ただし、ここで注意する必要があります。通常の`create_articles`ではなく、マイグレーションは`create_blorgh_articles`と呼ばれています。これは、`Blorgh::Engine`クラスの定義内で呼び出される`isolate_namespace`メソッドによるものです。ここでのモデルも名前空間が付けられており、`app/models/blorgh/article.rb`に配置されています。通常の`app/models/article.rb`ではなく、`Engine`クラス内の`isolate_namespace`呼び出しによるものです。

次に、このモデルのために`test_unit`ジェネレーターが呼び出され、モデルテストが`test/models/blorgh/article_test.rb`（`test/models/article_test.rb`ではなく）に生成され、フィクスチャが`test/fixtures/blorgh/articles.yml`（`test/fixtures/articles.yml`ではなく）に生成されます。

その後、リソースのための行が`config/routes.rb`ファイルに挿入されます。この行は単純に`resources :articles`であり、`config/routes.rb`ファイル全体は次のようになります：
```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

ここで、ルートは `YourApp::Application` クラスではなく `Blorgh::Engine` オブジェクトに対して描かれていることに注意してください。これは、エンジンのルートがエンジン自体に制約され、テストディレクトリのセクションで示されているように特定のポイントにマウントされるためです。また、これにより、エンジンのルートはアプリケーション内のルートとは分離されます。このガイドの [Routes](#routes) セクションでは、詳細に説明されています。

次に、`scaffold_controller` ジェネレータが呼び出され、`Blorgh::ArticlesController` というコントローラ（`app/controllers/blorgh/articles_controller.rb` に配置される）とそれに関連するビュー（`app/views/blorgh/articles`）が生成されます。このジェネレータは、コントローラのテスト（`test/controllers/blorgh/articles_controller_test.rb` および `test/system/blorgh/articles_test.rb`）とヘルパー（`app/helpers/blorgh/articles_helper.rb`）も生成します。

このジェネレータが作成したすべてのものは、きちんと名前空間で分類されています。コントローラのクラスは `Blorgh` モジュール内で定義されています。

```ruby
module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

注意：`ArticlesController` クラスは、アプリケーションの `ApplicationController` ではなく、`Blorgh::ApplicationController` を継承しています。

`app/helpers/blorgh/articles_helper.rb` 内のヘルパーも名前空間で分類されています。

```ruby
module Blorgh
  module ArticlesHelper
    # ...
  end
end
```

これにより、他のエンジンやアプリケーションにも記事リソースがある場合に競合が発生するのを防ぐことができます。

`bin/rails db:migrate` をエンジンのルートで実行して、スキャフォールドジェネレータによって生成されたマイグレーションを実行し、`test/dummy` で `bin/rails server` を実行すると、エンジンが現在持っているものが表示されます。`http://localhost:3000/blorgh/articles` を開くと、生成されたデフォルトのスキャフォールドが表示されます。クリックしてみてください！これで最初のエンジンの最初の機能が生成されました。

コンソールで遊ぶ場合は、`bin/rails console` も通常の Rails アプリケーションと同様に動作します。ただし、`Article` モデルは名前空間化されているため、`Blorgh::Article` として呼び出す必要があります。

```irb
irb> Blorgh::Article.find(1)
=> #<Blorgh::Article id: 1 ...>
```

最後に、このエンジンの `articles` リソースはエンジンのルートであるべきです。エンジンがマウントされているルートパスにアクセスすると、記事の一覧が表示されるべきです。これを実現するには、`config/routes.rb` ファイル内に次の行を挿入します。

```ruby
root to: "articles#index"
```

これで、人々は記事を表示するために `/articles` を訪れる必要はなくなります。つまり、`http://localhost:3000/blorgh/articles` の代わりに `http://localhost:3000/blorgh` にアクセスするだけで済みます。

### コメントリソースの生成

エンジンが新しい記事を作成できるようになったので、コメント機能も追加するのは当然のことです。これを行うには、コメントモデルとコメントコントローラを生成し、記事のスキャフォールドを編集してコメントを表示し、新しいコメントを作成できるようにする必要があります。

エンジンのルートから、モデルジェネレータを実行します。`Comment` モデルを生成し、関連するテーブルには `article_id` 整数型のカラムと `text` テキスト型のカラムがあることを指定します。

```bash
$ bin/rails generate model Comment article_id:integer text:text
```

これにより、次の出力が生成されます。

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_comments.rb
create    app/models/blorgh/comment.rb
invoke    test_unit
create      test/models/blorgh/comment_test.rb
create      test/fixtures/blorgh/comments.yml
```

このジェネレータ呼び出しは、必要なモデルファイルだけを生成し、`blorgh` ディレクトリの下にファイルを名前空間で分類し、`Blorgh::Comment` というモデルクラスを作成します。次に、マイグレーションを実行して `blorgh_comments` テーブルを作成します。

```bash
$ bin/rails db:migrate
```

記事にコメントを表示するために、`app/views/blorgh/articles/show.html.erb` を編集し、"Edit" リンクの前に次の行を追加します。

```html+erb
<h3>Comments</h3>
<%= render @article.comments %>
```

この行では、`Blorgh::Article` モデルにコメントの `has_many` 関連が定義されていることが必要ですが、現時点では定義されていません。定義するために、`app/models/blorgh/article.rb` を開き、次の行をモデルに追加します。

```ruby
has_many :comments
```

モデルは次のようになります。

```ruby
module Blorgh
  class Article < ApplicationRecord
    has_many :comments
  end
end
```

注意：`has_many` は `Blorgh` モジュール内のクラス内で定義されているため、Rails はこれらのオブジェクトに `Blorgh::Comment` モデルを使用したいという意図を理解し、ここでは `:class_name` オプションを指定する必要はありません。

次に、記事にコメントを作成するためのフォームが必要です。これを追加するには、`app/views/blorgh/articles/show.html.erb` の `render @article.comments` の下に次の行を追加します。

```erb
<%= render "blorgh/comments/form" %>
```

次に、この行がレンダリングするパーシャルが存在する必要があります。`app/views/blorgh/comments` という新しいディレクトリを作成し、その中に `app/views/blorgh/comments/_form.html.erb` という新しいファイルを作成し、次の内容で必要なパーシャルを作成します。
```html+erb
<h3>新しいコメント</h3>
<%= form_with model: [@article, @article.comments.build] do |form| %>
  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>
  <%= form.submit %>
<% end %>
```

このフォームが送信されると、エンジン内の`/articles/:article_id/comments`というルートに`POST`リクエストを試みます。このルートは現時点では存在しませんが、`config/routes.rb`内の`resources :articles`行を以下のように変更することで作成できます。

```ruby
resources :articles do
  resources :comments
end
```

これにより、コメントのネストされたルートが作成され、フォームが必要とするものです。

ルートは存在しますが、このルートに移動するコントローラは存在しません。これを作成するには、エンジンのルートから次のコマンドを実行します。

```bash
$ bin/rails generate controller comments
```

これにより、次のものが生成されます。

```
create  app/controllers/blorgh/comments_controller.rb
invoke  erb
 exist    app/views/blorgh/comments
invoke  test_unit
create    test/controllers/blorgh/comments_controller_test.rb
invoke  helper
create    app/helpers/blorgh/comments_helper.rb
invoke    test_unit
```

フォームは、`/articles/:article_id/comments`に`POST`リクエストを行い、`Blorgh::CommentsController`の`create`アクションに対応します。このアクションは作成する必要があります。`app/controllers/blorgh/comments_controller.rb`のクラス定義内に以下の行を追加することで行えます。

```ruby
def create
  @article = Article.find(params[:article_id])
  @comment = @article.comments.create(comment_params)
  flash[:notice] = "コメントが作成されました！"
  redirect_to articles_path
end

private
  def comment_params
    params.require(:comment).permit(:text)
  end
```

これは、新しいコメントフォームを動作させるために必要な最後のステップです。ただし、コメントの表示はまだ正しくありません。現時点でコメントを作成すると、次のエラーが表示されます。

```
Missing partial blorgh/comments/_comment with {:handlers=>[:erb, :builder],
:formats=>[:html], :locale=>[:en, :en]}. Searched in:   *
"/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"   *
"/Users/ryan/Sites/side_projects/blorgh/app/views"
```

エンジンは、コメントのレンダリングに必要なパーシャルを見つけることができません。Railsはまずアプリケーションの(`test/dummy`) `app/views`ディレクトリを検索し、次にエンジンの`app/views`ディレクトリを検索します。見つけられない場合は、このエラーが発生します。エンジンは、`Blorgh::Comment`クラスから受け取ったモデルオブジェクトに基づいて、`blorgh/comments/_comment`を探す必要があることを知っています。

このパーシャルは、現時点ではコメントのテキストのみをレンダリングする責任を持ちます。`app/views/blorgh/comments/_comment.html.erb`という新しいファイルを作成し、次の行を追加します。

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

`comment_counter`ローカル変数は、`<%= render @article.comments %>`呼び出しによって与えられ、自動的に定義され、各コメントを反復処理する際にカウンターがインクリメントされます。この例では、コメントが作成されるたびに小さな番号を表示するために使用されます。

これで、ブログエンジンのコメント機能が完成しました。次は、アプリケーション内で使用する方法です。

アプリケーションへの組み込み
---------------------------

エンジンをアプリケーション内で使用するのは非常に簡単です。このセクションでは、エンジンをアプリケーションにマウントする方法と、初期設定が必要な内容、およびエンジンをアプリケーションの提供する`User`クラスにリンクして、エンジン内の記事とコメントに所有権を提供する方法について説明します。

### エンジンのマウント

まず、エンジンをアプリケーションの`Gemfile`に指定する必要があります。テスト用のアプリケーションが手元にない場合は、次のようにエンジンディレクトリの外で`rails new`コマンドを使用してアプリケーションを生成します。

```bash
$ rails new unicorn
```

通常、`Gemfile`内でエンジンを指定する場合は、通常のジェムと同じように指定します。

```ruby
gem 'devise'
```

ただし、`blorgh`エンジンをローカルマシンで開発しているため、`Gemfile`に`path`オプションを指定する必要があります。

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

その後、`bundle`コマンドを実行してジェムをインストールします。

前述のように、`Gemfile`にジェムを配置することで、Railsがロードされるときにジェムがロードされます。まず、エンジンはエンジンから`lib/blorgh.rb`を要求し、次にエンジンの主要な機能を定義する`lib/blorgh/engine.rb`を要求します。

エンジンの機能をアプリケーション内からアクセス可能にするには、そのエンジンをアプリケーションの`config/routes.rb`ファイルにマウントする必要があります。

```ruby
mount Blorgh::Engine, at: "/blog"
```

この行は、エンジンをアプリケーションの`/blog`にマウントします。アプリケーションが`bin/rails server`で実行されている場合、`http://localhost:3000/blog`でアクセスできるようになります。

注意：Deviseなどの他のエンジンは、ルートで`devise_for`などのカスタムヘルパーを指定することで、少し異なる方法で処理します。これらのヘルパーは、エンジンの機能の一部を事前に定義されたパスにマウントするものであり、カスタマイズ可能な場合があります。
### エンジンのセットアップ

エンジンには、アプリケーションのデータベース内に作成する必要がある `blorgh_articles` と `blorgh_comments` テーブルのマイグレーションが含まれています。エンジンのモデルがこれらのテーブルを正しくクエリできるように、これらのマイグレーションをアプリケーションにコピーする必要があります。アプリケーションのルートから以下のコマンドを実行して、これらのマイグレーションをコピーします。

```bash
$ bin/rails blorgh:install:migrations
```

複数のエンジンにマイグレーションをコピーする必要がある場合は、代わりに `railties:install:migrations` を使用します。

```bash
$ bin/rails railties:install:migrations
```

マイグレーションのソースエンジンにカスタムパスを指定する場合は、MIGRATIONS_PATH を指定します。

```bash
$ bin/rails railties:install:migrations MIGRATIONS_PATH=db_blourgh
```

複数のデータベースを持っている場合は、DATABASE を指定してターゲットデータベースを指定することもできます。

```bash
$ bin/rails railties:install:migrations DATABASE=animals
```

このコマンドは、初回実行時にエンジンからすべてのマイグレーションをコピーします。次回以降の実行時には、すでにコピーされていないマイグレーションのみをコピーします。このコマンドの最初の実行では、次のような出力が表示されます。

```
Copied migration [timestamp_1]_create_blorgh_articles.blorgh.rb from blorgh
Copied migration [timestamp_2]_create_blorgh_comments.blorgh.rb from blorgh
```

最初のタイムスタンプ（`[timestamp_1]`）は現在の時刻であり、2番目のタイムスタンプ（`[timestamp_2]`）は現在の時刻に1秒を加えたものです。これは、エンジンのマイグレーションがアプリケーションの既存のマイグレーションの後に実行されるようにするためです。

これらのマイグレーションをアプリケーションのコンテキストで実行するには、単純に `bin/rails db:migrate` を実行します。`http://localhost:3000/blog` を介してエンジンにアクセスすると、記事は空になります。これは、アプリケーション内で作成されたテーブルがエンジン内で作成されたテーブルと異なるためです。新しくマウントされたエンジンで遊んでみてください。エンジンが単独のエンジンの場合、マイグレーションを実行することもできます。これは、`SCOPE` を指定することで実行できます。

```bash
$ bin/rails db:migrate SCOPE=blorgh
```

これは、エンジンを削除する前にエンジンのマイグレーションを元に戻す場合に便利です。blorgh エンジンのすべてのマイグレーションを元に戻すには、次のようなコードを実行できます。

```bash
$ bin/rails db:migrate SCOPE=blorgh VERSION=0
```

### アプリケーションが提供するクラスの使用

#### アプリケーションが提供するモデルの使用

エンジンが作成されると、エンジンの部分とアプリケーションの部分をリンクするために、アプリケーションの特定のクラスを使用したい場合があります。`blorgh` エンジンの場合、記事とコメントには著者がいることが理にかなっています。

典型的なアプリケーションでは、記事やコメントの著者を表すために `User` クラスが使用される場合があります。ただし、アプリケーションでは `Person` などと呼ばれる場合もあります。そのため、エンジンは `User` クラスに固有の関連をハードコードすべきではありません。

この場合を単純にするために、アプリケーションには `User` という名前のクラスがあり、これがアプリケーションのユーザーを表すために使用されるとします（これについては後で設定可能にします）。次のコマンドをアプリケーション内で実行して、このクラスを生成できます。

```bash
$ bin/rails generate model user name:string
```

`bin/rails db:migrate` コマンドをここで実行して、アプリケーションが将来使用するための `users` テーブルを確認します。

また、単純にするために、記事のフォームには `author_name` という新しいテキストフィールドがあり、ユーザーが名前を入力できるようになっています。エンジンはこの名前を取得し、それに基づいて新しい `User` オブジェクトを作成するか、既にその名前を持つオブジェクトを検索します。エンジンはその後、記事を見つけたまたは作成した `User` オブジェクトと関連付けます。

まず、`author_name` テキストフィールドをエンジン内の `app/views/blorgh/articles/_form.html.erb` パーシャルに追加する必要があります。次のコードを使用して、`title` フィールドの上に追加できます。

```html+erb
<div class="field">
  <%= form.label :author_name %><br>
  <%= form.text_field :author_name %>
</div>
```

次に、`Blorgh::ArticlesController#article_params` メソッドを更新して、新しいフォームパラメータを許可する必要があります。

```ruby
def article_params
  params.require(:article).permit(:title, :text, :author_name)
end
```

`Blorgh::Article` モデルには、`author_name` フィールドを実際の `User` オブジェクトに変換し、記事が保存される前にその記事の `author` として関連付けるためのコードが必要です。また、このフィールドのために `attr_accessor` も設定する必要があります。これにより、セッターとゲッターメソッドが定義されます。

これを行うには、`app/models/blorgh/article.rb` に `author_name` のための `attr_accessor`、著者の関連付け、および `before_validation` の呼び出しを追加する必要があります。現時点では、`author` 関連付けは `User` クラスにハードコードされます。
```ruby
module Blorgh
  mattr_accessor :author_class

  def self.author_class
    @@author_class
  end
end
```

With this change, the `author_class` can be accessed as `Blorgh.author_class`
throughout the engine.

#### Configuring the Application

To configure the engine in the application, an initializer file needs to be
created. This file will be loaded when the application starts up and can be used
to set the engine's configuration settings.

Create a new file called `blorgh.rb` in `config/initializers` and add the
following code:

```ruby
Blorgh.author_class = "User"
```

This sets the `author_class` configuration setting to `"User"`, which is the
default value. However, this can be changed to any other class name if needed.

#### Overriding the Configuration in the Application

To override the configuration setting in the application, simply change the
value in the initializer file. For example, to use a different class called
`Author` instead of `User`, modify the `blorgh.rb` initializer file like this:

```ruby
Blorgh.author_class = "Author"
```

Now the engine will use the `Author` class instead of the `User` class for the
`author` association.

#### Configuration Tips

Here are some general tips for configuring the engine:

- Use configuration settings to make the engine customizable and adaptable to
  different applications.
- Provide sensible default values for configuration settings to minimize the
  need for customization.
- Document the configuration settings and their purpose to make it easier for
  developers to understand and use the engine.
- Consider using environment-specific configuration settings to allow different
  behavior in different environments (e.g., development, production).
- Use initializer files to set the configuration settings in the application.
- Allow the application to override the configuration settings to provide
  flexibility and customization options.
```ruby
def self.author_class
  @@author_class.constantize
end
```

これによって、`set_author`のコードは次のようになります：

```ruby
self.author = Blorgh.author_class.find_or_create_by(name: author_name)
```

これにより、少し短くなり、動作がより暗黙的になります。`author_class`メソッドは常に`Class`オブジェクトを返す必要があります。

`author_class`メソッドを`String`ではなく`Class`を返すように変更したため、`Blorgh::Article`モデルの`belongs_to`定義も変更する必要があります：

```ruby
belongs_to :author, class_name: Blorgh.author_class.to_s
```

この設定をアプリケーション内で行うためには、イニシャライザを使用する必要があります。イニシャライザを使用することで、アプリケーションが開始され、エンジンのモデルが呼び出される前にこの設定が行われるため、この設定が存在することに依存する可能性があるモデルに影響を与えることがあります。

`blorgh`エンジンがインストールされているアプリケーション内の`config/initializers/blorgh.rb`に新しいイニシャライザを作成し、次の内容を追加します：

```ruby
Blorgh.author_class = "User"
```

警告：ここで非常に重要なのは、クラス自体ではなく、クラスの`String`バージョンを使用することです。クラスを使用すると、Railsはそのクラスをロードし、関連するテーブルを参照しようとします。テーブルがまだ存在しない場合、問題が発生する可能性があります。したがって、`String`を使用してから、エンジンで`constantize`を使用してクラスに変換する必要があります。

新しい記事を作成してみてください。`config/initializers/blorgh.rb`の設定を使用して、以前とまったく同じ方法で動作することがわかります。

クラスが何であるかに厳密な依存関係はなくなり、クラスのAPIのみが必要とされます。エンジンは、このクラスが`find_or_create_by`メソッドを定義していることを要求するだけで、記事が作成されるときに関連付けられるそのクラスのオブジェクトを返します。もちろん、このオブジェクトには参照できるようにするための識別子が必要です。

#### 一般的なエンジンの設定

エンジン内で、初期化子、国際化、その他の設定オプションを使用したい場合があります。素晴らしいニュースは、これらのことが完全に可能であることです。なぜなら、RailsエンジンはRailsアプリケーションとほぼ同じ機能を共有しているからです。実際、Railsアプリケーションの機能は、エンジンが提供するものの上位集合です！

初期化子を使用する場合は、`config/initializers`フォルダがその場所です。このディレクトリの機能は、Configuringガイドの[Initializersセクション](configuring.html#initializers)で説明されており、アプリケーション内の`config/initializers`ディレクトリとまったく同じ方法で機能します。同じことが通常の初期化子を使用する場合も当てはまります。

ロケールの場合は、ロケールファイルを`config/locales`ディレクトリに配置するだけで、アプリケーションと同じように使用できます。

エンジンのテスト
-----------------

エンジンが生成されると、その内部に`test/dummy`という小さなダミーアプリケーションが作成されます。このアプリケーションは、エンジンをテストするためのマウントポイントとして使用されます。このディレクトリ内からコントローラ、モデル、ビューを生成し、それらを使用してエンジンをテストすることができます。

`test`ディレクトリは、ユニットテスト、機能テスト、統合テストを許可する、典型的なRailsのテスト環境と同様に扱われるべきです。

### 機能テスト

機能テストを作成する際に考慮すべき重要な点は、テストがアプリケーション（`test/dummy`アプリケーション）で実行されるということです。これは、テスト環境のセットアップによるものです。エンジンは、主な機能をテストするためにアプリケーションをホストとして必要とします。特にコントローラの場合は、アプリケーションがこれらのリクエストをエンジンにどのようにルーティングするかを明示的に指定しない限り、これらのリクエストをエンジンにルーティングする方法をアプリケーションが知りません。これを行うには、セットアップコードで`@routes`インスタンス変数をエンジンのルートセットに設定する必要があります。

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_index
      get foos_url
      # ...
    end
  end
end
```
これにより、アプリケーションは、アプリケーションのものではなく、エンジンのルートを使用して目的地に到達するために、このコントローラの`index`アクションへの`GET`リクエストを実行することを示します。

これにより、テストでエンジンのURLヘルパーが正常に動作することも保証されます。

エンジンの機能の改善
------------------------------

このセクションでは、メインのRailsアプリケーションにエンジンのMVC機能を追加またはオーバーライドする方法について説明します。

### モデルとコントローラのオーバーライド

エンジンのモデルとコントローラは、親アプリケーションで再オープンして拡張または装飾することができます。

オーバーライドは、専用のディレクトリ`app/overrides`に整理され、オートローダーによって無視され、`to_prepare`コールバックでプリロードされることができます：

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        load override
      end
    end
  end
end
```

#### `class_eval`を使用して既存のクラスを再オープンする

たとえば、エンジンのモデルをオーバーライドするためには、

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    # ...
  end
end
```

単にそのクラスを再オープンするファイルを作成します：

```ruby
# MyApp/app/overrides/models/blorgh/article_override.rb
Blorgh::Article.class_eval do
  # ...
end
```

オーバーライドがクラスまたはモジュールを再オープンすることが非常に重要です。`class`または`module`キーワードを使用すると、それらが既にメモリに存在しない場合にそれらを定義してしまうため、エンジンに定義が存在するため、これは正しくありません。上記のように`class_eval`を使用することで、再オープンしていることを確認できます。

#### ActiveSupport::Concernを使用して既存のクラスを再オープンする

`Class#class_eval`は単純な調整には適していますが、より複雑なクラスの変更には[`ActiveSupport::Concern`](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)を使用することを検討することもできます。
ActiveSupport::Concernは、実行時に相互にリンクされた依存モジュールとクラスの読み込み順序を管理し、コードを大幅にモジュール化することができます。

`Article#time_since_created`を**追加**し、`Article#summary`を**オーバーライド**する：

```ruby
# MyApp/app/models/blorgh/article.rb

class Blorgh::Article < ApplicationRecord
  include Blorgh::Concerns::Models::Article

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    include Blorgh::Concerns::Models::Article
  end
end
```

```ruby
# Blorgh/lib/concerns/models/article.rb

module Blorgh::Concerns::Models::Article
  extend ActiveSupport::Concern

  # `included do`は、モジュールが含まれるコンテキスト（つまりBlorgh::Article）でブロックが評価されるため、モジュール自体ではなく、そのコンテキストで評価されることを意味します。
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_validation :set_author

    private
      def set_author
        self.author = User.find_or_create_by(name: author_name)
      end
  end

  def summary
    "#{title}"
  end

  module ClassMethods
    def some_class_method
      'some class method string'
    end
  end
end
```

### オートローディングとエンジン

オートローディングとエンジンについての詳細については、[オートローディングと定数のリロード](autoloading_and_reloading_constants.html#autoloading-and-engines)ガイドを参照してください。


### ビューのオーバーライド

Railsはビューをレンダリングするために、まずアプリケーションの`app/views`ディレクトリを検索します。そこでビューが見つからない場合は、このディレクトリを持つすべてのエンジンの`app/views`ディレクトリをチェックします。

アプリケーションが`Blorgh::ArticlesController`のインデックスアクションのビューをレンダリングするように要求された場合、まずアプリケーション内のパス`app/views/blorgh/articles/index.html.erb`を探します。それが見つからない場合は、エンジン内を探します。

アプリケーションでこのビューをオーバーライドするには、単に`app/views/blorgh/articles/index.html.erb`に新しいファイルを作成します。その後、このビューが通常出力する内容を完全に変更することができます。

次のコンテンツを含む`app/views/blorgh/articles/index.html.erb`という新しいファイルを作成して、これを試してみてください：

```html+erb
<h1>Articles</h1>
<%= link_to "New Article", new_article_path %>
<% @articles.each do |article| %>
  <h2><%= article.title %></h2>
  <small>By <%= article.author %></small>
  <%= simple_format(article.text) %>
  <hr>
<% end %>
```

### ルート

エンジン内のルートはデフォルトでアプリケーションから分離されています。これは、`Engine`クラス内の`isolate_namespace`呼び出しによって行われます。これは、アプリケーションとそのエンジンが同じ名前のルートを持つことができ、それらが衝突しないことを意味します。

エンジン内のルートは、次のように`config/routes.rb`内の`Engine`クラスで描かれます：

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

このような分離されたルートを持つことで、アプリケーション内からエンジンの領域にリンクする場合は、エンジンのルーティングプロキシメソッドを使用する必要があります。`articles_path`などの通常のルーティングメソッドの呼び出しは、アプリケーションとエンジンの両方にそのようなヘルパーが定義されている場合、望ましくない場所に行く可能性があります。

たとえば、次の例は、テンプレートがアプリケーションからレンダリングされた場合はアプリケーションの`articles_path`に、エンジンからレンダリングされた場合はエンジンの`articles_path`に移動します。
```erb
<%= link_to "ブログ記事", articles_path %>
```

このルートが常にエンジンの `articles_path` ルーティングヘルパーメソッドを使用するようにするには、
エンジンと同じ名前を共有するルーティングプロキシメソッドでメソッドを呼び出す必要があります。

```erb
<%= link_to "ブログ記事", blorgh.articles_path %>
```

同様の方法でエンジン内のアプリケーションを参照する場合は、`main_app` ヘルパーを使用します。

```erb
<%= link_to "ホーム", main_app.root_path %>
```

これをエンジン内のテンプレートで使用すると、**常に**アプリケーションのルートに移動します。`main_app` の「ルーティングプロキシ」メソッド呼び出しを省略すると、呼び出し元に応じてエンジンまたはアプリケーションのルートに移動する可能性があります。

エンジン内でレンダリングされるテンプレートがアプリケーションのルーティングヘルパーメソッドのいずれかを使用しようとすると、未定義のメソッド呼び出しになる場合があります。このような問題が発生した場合は、エンジン内から `main_app` 接頭辞なしでアプリケーションのルーティングメソッドを呼び出そうとしていないか確認してください。

### アセット

エンジン内のアセットは、完全なアプリケーションと同じ方法で機能します。エンジンクラスが `Rails::Engine` を継承しているため、アプリケーションはエンジンの `app/assets` および `lib/assets` ディレクトリでアセットを検索するようになります。

エンジンの他のコンポーネントと同様に、アセットは名前空間である必要があります。つまり、`style.css` というアセットは、`app/assets/stylesheets/[エンジン名]/style.css` に配置する必要があります。このアセットが名前空間になっていない場合、ホストアプリケーションに同じ名前のアセットが存在する可能性があります。その場合、アプリケーションのアセットが優先され、エンジンのアセットは無視されます。

`app/assets/stylesheets/blorgh/style.css` にアセットがあると想像してください。このアセットをアプリケーション内で使用するには、`stylesheet_link_tag` を使用し、エンジン内のアセットとして参照します。

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

また、処理されたファイル内の Asset Pipeline の require ステートメントを使用して、これらのアセットを他のアセットの依存関係として指定することもできます。

```css
/*
 *= require blorgh/style
 */
```

INFO. Sass や CoffeeScript などの言語を使用するには、エンジンの `.gemspec` に関連するライブラリを追加する必要があります。

### アセットの分離とプリコンパイル

エンジンのアセットがホストアプリケーションによって必要とされない場合があります。たとえば、エンジン専用の管理機能を作成した場合、ホストアプリケーションは `admin.css` や `admin.js` を要求する必要はありません。これらのアセットは、ジェムの管理者レイアウトのみが必要です。ホストアプリケーションが `"blorgh/admin.css"` をスタイルシートに含めることは意味がありません。この場合、プリコンパイルのためにこれらのアセットを明示的に定義する必要があります。これにより、`bin/rails assets:precompile` をトリガーとしたときに Sprockets がエンジンのアセットを追加するようになります。

`engine.rb` でプリコンパイルのためのアセットを定義できます。

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile += %w( admin.js admin.css )
end
```

詳細については、[Asset Pipeline ガイド](asset_pipeline.html)を参照してください。

### その他のジェムの依存関係

エンジン内のジェムの依存関係は、エンジンのルートにある `.gemspec` ファイル内で指定する必要があります。その理由は、エンジンがジェムとしてインストールされる可能性があるためです。依存関係を `Gemfile` 内に指定すると、従来のジェムのインストールでは認識されず、インストールされないため、エンジンが正常に動作しなくなります。

トラディショナルな `gem install` 中にエンジンと一緒にインストールする必要がある依存関係を指定するには、エンジンの `.gemspec` ファイル内の `Gem::Specification` ブロック内に指定します。

```ruby
s.add_dependency "moo"
```

アプリケーションの開発依存関係としてのみインストールする必要がある依存関係を指定するには、次のように指定します。

```ruby
s.add_development_dependency "moo"
```

`bundle install` をアプリケーション内で実行すると、両方の種類の依存関係がインストールされます。ジェムの開発依存関係は、エンジンの開発とテストが実行されるときにのみ使用されます。

エンジンが必要な依存関係をエンジンが必要とされる時点で即座に要求する場合は、エンジンの初期化よりも前にそれらを要求する必要があります。たとえば：

```ruby
require "other_engine/engine"
require "yet_another_engine/engine"

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```

ロードと設定のフック
----------------------------

Rails のコードは、アプリケーションのロード時に参照されることがよくあります。Rails はこれらのフレームワークのロード順序を管理しているため、`ActiveRecord::Base` のようなフレームワークを事前にロードすると、アプリケーションが Rails との暗黙の契約に違反します。さらに、`ActiveRecord::Base` のようなコードをアプリケーションの起動時にロードすると、起動時間が遅くなり、ロード順序と起動に関する競合が発生する可能性があります。
ロードフックと設定フックは、Railsとのロード契約を破ることなく、この初期化プロセスにフックするためのAPIです。これにより、ブートパフォーマンスの低下を軽減し、競合を回避することができます。

### Railsフレームワークの読み込みを回避する

Rubyは動的な言語であるため、一部のコードは異なるRailsフレームワークの読み込みを引き起こします。例えば、次のコードスニペットを見てください。

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

このスニペットは、このファイルが読み込まれると`ActiveRecord::Base`に遭遇します。この遭遇により、Rubyはその定数の定義を探し、それを要求します。これにより、Active Recordフレームワーク全体が起動時に読み込まれます。

`ActiveSupport.on_load`は、コードの読み込みを実際に必要な時まで遅延させるために使用できるメカニズムです。上記のスニペットは次のように変更できます。

```ruby
ActiveSupport.on_load(:active_record) do
  include MyActiveRecordHelper
end
```

この新しいスニペットは、`ActiveRecord::Base`が読み込まれたときにのみ`MyActiveRecordHelper`を含めます。

### フックはいつ呼び出されますか？

Railsフレームワークでは、これらのフックは特定のライブラリが読み込まれたときに呼び出されます。たとえば、`ActionController::Base`が読み込まれると、`:action_controller_base`フックが呼び出されます。これは、`ActionController::Base`のコンテキストで`ActiveSupport.on_load`呼び出しが行われることを意味します（つまり、`self`は`ActionController::Base`になります）。

### コードの修正方法

コードの修正は一般的に簡単です。`ActiveRecord::Base`などのRailsフレームワークを参照するコードがある場合は、そのコードをロードフックで囲むことができます。

**`include`の呼び出しの修正**

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

は次のようになります。

```ruby
ActiveSupport.on_load(:active_record) do
  # ここではselfはActiveRecord::Baseを参照しているため、.includeを呼び出すことができます
  include MyActiveRecordHelper
end
```

**`prepend`の呼び出しの修正**

```ruby
ActionController::Base.prepend(MyActionControllerHelper)
```

は次のようになります。

```ruby
ActiveSupport.on_load(:action_controller_base) do
  # ここではselfはActionController::Baseを参照しているため、.prependを呼び出すことができます
  prepend MyActionControllerHelper
end
```

**クラスメソッドの呼び出しの修正**

```ruby
ActiveRecord::Base.include_root_in_json = true
```

は次のようになります。

```ruby
ActiveSupport.on_load(:active_record) do
  # ここではselfはActiveRecord::Baseを参照しています
  self.include_root_in_json = true
end
```

### 使用可能なロードフック

以下は、独自のコードで使用できるロードフックです。以下のクラスの初期化プロセスにフックするために使用できる利用可能なフックを使用します。

| クラス                                | フック                                 |
| -------------------------------------| ------------------------------------ |
| `ActionCable`                        | `action_cable`                       |
| `ActionCable::Channel::Base`         | `action_cable_channel`               |
| `ActionCable::Connection::Base`      | `action_cable_connection`            |
| `ActionCable::Connection::TestCase`  | `action_cable_connection_test_case`  |
| `ActionController::API`              | `action_controller_api`              |
| `ActionController::API`              | `action_controller`                  |
| `ActionController::Base`             | `action_controller_base`             |
| `ActionController::Base`             | `action_controller`                  |
| `ActionController::TestCase`         | `action_controller_test_case`        |
| `ActionDispatch::IntegrationTest`    | `action_dispatch_integration_test`   |
| `ActionDispatch::Response`           | `action_dispatch_response`           |
| `ActionDispatch::Request`            | `action_dispatch_request`            |
| `ActionDispatch::SystemTestCase`     | `action_dispatch_system_test_case`   |
| `ActionMailbox::Base`                | `action_mailbox`                     |
| `ActionMailbox::InboundEmail`        | `action_mailbox_inbound_email`       |
| `ActionMailbox::Record`              | `action_mailbox_record`              |
| `ActionMailbox::TestCase`            | `action_mailbox_test_case`           |
| `ActionMailer::Base`                 | `action_mailer`                      |
| `ActionMailer::TestCase`             | `action_mailer_test_case`            |
| `ActionText::Content`                | `action_text_content`                |
| `ActionText::Record`                 | `action_text_record`                 |
| `ActionText::RichText`               | `action_text_rich_text`              |
| `ActionText::EncryptedRichText`      | `action_text_encrypted_rich_text`    |
| `ActionView::Base`                   | `action_view`                        |
| `ActionView::TestCase`               | `action_view_test_case`              |
| `ActiveJob::Base`                    | `active_job`                         |
| `ActiveJob::TestCase`                | `active_job_test_case`               |
| `ActiveRecord::Base`                 | `active_record`                      |
| `ActiveRecord::TestFixtures`         | `active_record_fixtures`             |
| `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter`    | `active_record_postgresqladapter`    |
| `ActiveRecord::ConnectionAdapters::Mysql2Adapter`        | `active_record_mysql2adapter`        |
| `ActiveRecord::ConnectionAdapters::TrilogyAdapter`       | `active_record_trilogyadapter`       |
| `ActiveRecord::ConnectionAdapters::SQLite3Adapter`       | `active_record_sqlite3adapter`       |
| `ActiveStorage::Attachment`          | `active_storage_attachment`          |
| `ActiveStorage::VariantRecord`       | `active_storage_variant_record`      |
| `ActiveStorage::Blob`                | `active_storage_blob`                |
| `ActiveStorage::Record`              | `active_storage_record`              |
| `ActiveSupport::TestCase`            | `active_support_test_case`           |
| `i18n`                               | `i18n`                               |

### 使用可能な設定フック

設定フックは特定のフレームワークにフックするのではなく、アプリケーション全体のコンテキストで実行されます。

| フック                   | ユースケース                                                                           |
| ---------------------- | ---------------------------------------------------------------------------------- |
| `before_configuration` | 最初の設定可能なブロック。初期化子が実行される前に呼び出されます。           |
| `before_initialize`    | 2番目の設定可能なブロック。フレームワークが初期化される前に呼び出されます。             |
| `before_eager_load`    | 3番目の設定可能なブロック。[`config.eager_load`][]がfalseに設定されていない場合には実行されません。 |
| `after_initialize`     | 最後の設定可能なブロック。フレームワークが初期化された後に呼び出されます。                |

設定フックはEngineクラスで呼び出すことができます。

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    config.before_configuration do
      puts '初期化子の前に呼び出されます'
    end
  end
end
```
[`config.eager_load`]: configuring.html#config-eager-load
