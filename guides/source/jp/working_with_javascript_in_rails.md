**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c1e56036aa9fd68276daeec5a9407096
RailsでJavaScriptを使用する
===========================

このガイドでは、JavaScriptの機能をRailsアプリケーションに統合するためのオプションについて説明します。外部のJavaScriptパッケージの使用方法や、RailsでTurboを使用する方法などについても説明します。

このガイドを読み終えると、以下のことがわかるようになります。

* Node.js、Yarn、JavaScriptバンドラーの必要性なしにRailsを使用する方法
* import maps、esbuild、rollup、またはwebpackを使用してJavaScriptをバンドルするための新しいRailsアプリケーションの作成方法
* Turboとは何か、そしてTurboが提供するRailsのTurbo HTMLヘルパーの使用方法
* Railsが提供するTurbo HTMLヘルパーの使用方法

--------------------------------------------------------------------------------

Import Maps
-----------

[Import maps](https://github.com/rails/importmap-rails)を使用すると、ブラウザから直接バージョン管理されたファイルに対応する論理名を使用してJavaScriptモジュールをインポートできます。Import mapsはRails 7からデフォルトで使用され、トランスパイルやバンドルの必要なく、ほとんどのNPMパッケージを使用してモダンなJavaScriptアプリケーションを構築できます。

Import mapsを使用するアプリケーションでは、[Node.js](https://nodejs.org/en/)や[Yarn](https://yarnpkg.com/)は必要ありません。JavaScriptの依存関係を管理するためにRailsと`importmap-rails`を使用する予定がある場合、Node.jsやYarnをインストールする必要はありません。

import mapsを使用する場合、別個のビルドプロセスは必要ありません。`bin/rails server`でサーバーを起動するだけで使用できます。

### importmap-railsのインストール

Rails 7以降の新しいアプリケーションには、Importmap for Railsが自動的に含まれていますが、既存のアプリケーションに手動でインストールすることもできます。

```bash
$ bin/bundle add importmap-rails
```

インストールタスクを実行します。

```bash
$ bin/rails importmap:install
```

### importmap-railsでのNPMパッケージの追加

import mapを使用したアプリケーションに新しいパッケージを追加するには、ターミナルから`bin/importmap pin`コマンドを実行します。

```bash
$ bin/importmap pin react react-dom
```

その後、通常通り`application.js`にパッケージをインポートします。

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

JavaScriptバンドラーを使用したNPMパッケージの追加
----------------------------------------------

Import mapsは新しいRailsアプリケーションのデフォルトですが、従来のJavaScriptバンドリングを希望する場合は、[esbuild](https://esbuild.github.io/)、[webpack](https://webpack.js.org/)、または[rollup.js](https://rollupjs.org/guide/en/)のいずれかを選択して新しいRailsアプリケーションを作成できます。

新しいRailsアプリケーションでimport mapsの代わりにバンドラーを使用するには、`rails new`に`--javascript`または`-j`オプションを渡します。

```bash
$ rails new my_new_app --javascript=webpack
または
$ rails new my_new_app -j webpack
```

これらのバンドリングオプションには、シンプルな設定と[jsbundling-rails](https://github.com/rails/jsbundling-rails) gemを介したアセットパイプラインとの統合が付属しています。

バンドリングオプションを使用する場合は、開発用にRailsサーバーを起動し、JavaScriptをビルドするために`bin/dev`を使用します。

### Node.jsとYarnのインストール

RailsアプリケーションでJavaScriptバンドラーを使用する場合、Node.jsとYarnをインストールする必要があります。

インストール手順は[Node.jsのウェブサイト](https://nodejs.org/en/download/)で確認し、次のコマンドで正しくインストールされていることを確認します。

```bash
$ node --version
```

Node.jsランタイムのバージョンが表示されるはずです。バージョンが`8.16.0`よりも新しいことを確認してください。

Yarnをインストールするには、[Yarnのウェブサイト](https://classic.yarnpkg.com/en/docs/install)のインストール手順に従います。次のコマンドを実行すると、Yarnのバージョンが表示されるはずです。

```bash
$ yarn --version
```

`1.22.0`などと表示されれば、Yarnは正しくインストールされています。

Import MapsとJavaScriptバンドラーの選択
-----------------------------------

新しいRailsアプリケーションを作成する際には、import mapsとJavaScriptバンドリングソリューションのどちらを選択するかを選択する必要があります。すべてのアプリケーションには異なる要件があり、大規模で複雑なアプリケーションでは、別のオプションに移行することが時間のかかる場合があるため、要件を慎重に考慮する必要があります。

Import mapsはデフォルトのオプションです。Railsチームは、import mapsが複雑さを減らし、開発者のエクスペリエンスを向上させ、パフォーマンスの向上に貢献する可能性を信じています。

多くのアプリケーション、特にJavaScriptのニーズに主に[Hotwire](https://hotwired.dev/)スタックを依存しているアプリケーションでは、import mapsが長期的な選択肢となるでしょう。Rails 7でimport mapsをデフォルトにする理由については、[こちら](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b)をご覧ください。

他のアプリケーションでは、従来のJavaScriptバンドラーが必要な場合があります。以下の要件がある場合は、従来のバンドラーを選択する必要があります。

* JSXやTypeScriptなどのトランスパイルが必要な場合
* CSSを含むJavaScriptライブラリや[Webpack loaders](https://webpack.js.org/loaders/)に依存する場合
* [tree-shaking](https://webpack.js.org/guides/tree-shaking/)が必要な場合
* [cssbundling-rails gem](https://github.com/rails/cssbundling-rails)を介してBootstrap、Bulma、PostCSS、またはDart CSSをインストールする場合。このgemが提供するTailwindとSass以外のすべてのオプションは、`rails new`で別のオプションを指定しない場合、自動的に`esbuild`をインストールします。
ターボ
-----

インポートマップを選ぶか、伝統的なバンドラを選ぶかにかかわらず、Railsは[Turbo](https://turbo.hotwired.dev/)を搭載しています。これにより、アプリケーションの速度が向上し、書く必要があるJavaScriptの量が劇的に減少します。

Turboは、従来のフロントエンドフレームワークに代わるものとして、サーバーがHTMLを直接配信することができます。これにより、RailsアプリケーションのサーバーサイドがJSON APIに過ぎない状態になるのを防ぎます。

### Turbo Drive

[Turbo Drive](https://turbo.hotwired.dev/handbook/drive)は、フルページのティアダウンと再構築を回避することでページの読み込みを高速化します。Turbo Driveは、Turbolinksの改良版であり、置き換えも可能です。

### Turbo Frames

[Turbo Frames](https://turbo.hotwired.dev/handbook/frames)は、ページの特定の部分を更新することなくリクエストに応じて更新することができます。

Turbo Framesを使用すると、カスタムJavaScriptなしでインプレース編集を行ったり、コンテンツを遅延ロードしたり、簡単にサーバーレンダリングされたタブ付きインターフェースを作成したりすることができます。

Railsは、[turbo-rails](https://github.com/hotwired/turbo-rails) gemを介してTurbo Framesの使用を簡素化するためのHTMLヘルパーを提供しています。

このgemを使用すると、次のようにしてTurbo Frameをアプリケーションに追加することができます。

```erb
<%= turbo_frame_tag dom_id(post) do %>
  <div>
     <%= link_to post.title, post_path(post) %>
  </div>
<% end %>
```

### Turbo Streams

[Turbo Streams](https://turbo.hotwired.dev/handbook/streams)は、自己実行の`<turbo-stream>`要素で囲まれたHTMLのフラグメントとしてページの変更を配信します。Turbo Streamsを使用すると、他のユーザーが行った変更をWebSocketsを介してブロードキャストし、フォームの送信後にページの一部を更新することができます。

Railsは、[turbo-rails](https://github.com/hotwired/turbo-rails) gemを介してTurbo Streamsの使用を簡素化するためのHTMLとサーバーサイドのヘルパーを提供しています。

このgemを使用すると、コントローラーアクションからTurbo Streamsをレンダリングすることができます。

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Railsは、`.turbo_stream.erb`ビューファイルを自動的に検索し、そのビューを見つけた場合にはそのビューをレンダリングします。

Turbo Streamのレスポンスは、コントローラーアクション内でインラインでレンダリングすることもできます。

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream { render turbo_stream: turbo_stream.prepend('posts', partial: 'post') }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

最後に、Turbo Streamsは、モデルやバックグラウンドジョブからビルトインのヘルパーを使用して開始することもできます。これらのブロードキャストは、WebSocket接続を介してすべてのユーザーにコンテンツを更新するために使用することができます。これにより、ページのコンテンツが新鮮に保たれ、アプリケーションが活気づけられます。

モデルからTurbo Streamをブロードキャストするには、次のようにモデルコールバックを組み合わせます。

```ruby
class Post < ApplicationRecord
  after_create_commit { broadcast_append_to('posts') }
end
```

これにより、次のように更新を受け取るページにWebSocket接続が設定されます。

```erb
<%= turbo_stream_from "posts" %>
```

Rails/UJSの機能の代替
----------------------------------------

Rails 6には、UJS（Unobtrusive JavaScript）と呼ばれるツールが搭載されています。UJSを使用すると、`<a>`タグのHTTPリクエストメソッドをオーバーライドしたり、アクションを実行する前に確認ダイアログを追加したりすることができます。Rails 7以前ではデフォルトでしたが、Turboを使用することが推奨されています。

### メソッド

リンクをクリックすると常にHTTP GETリクエストが発生します。アプリケーションが[RESTful](https://en.wikipedia.org/wiki/Representational_State_Transfer)である場合、一部のリンクは実際にはサーバー上のデータを変更するアクションであり、GETリクエストでは実行されるべきではありません。`data-turbo-method`属性を使用して、そのようなリンクに明示的なメソッド（"post"、"put"、"delete"など）を指定することができます。

Turboは、`turbo-method`データ属性を持つ`<a>`タグをスキャンし、指定されたメソッドを使用してデフォルトのGETアクションを上書きします。

例えば：

```erb
<%= link_to "Delete post", post_path(post), data: { turbo_method: "delete" } %>
```

これにより、次のように生成されます：

```html
<a data-turbo-method="delete" href="...">Delete post</a>
```

`data-turbo-method`を使用してリンクのメソッドを変更する代わりに、Railsの`button_to`ヘルパーを使用することもできます。アクセシビリティの観点から、非GETアクションには実際のボタンやフォームを使用することが望ましいです。

### 確認

リンクやフォームに`data-turbo-confirm`属性を追加することで、ユーザーに追加の確認を求めることができます。リンクをクリックするかフォームを送信すると、属性のテキストがJavaScriptの`confirm()`ダイアログに表示されます。ユーザーがキャンセルを選択すると、アクションは実行されません。

例えば、`link_to`ヘルパーを使用する場合：

```erb
<%= link_to "Delete post", post_path(post), data: { turbo_method: "delete", turbo_confirm: "Are you sure?" } %>
```

これにより、次のように生成されます：

```html
<a href="..." data-turbo-confirm="Are you sure?" data-turbo-method="delete">Delete post</a>
```
ユーザーが「投稿を削除する」リンクをクリックすると、「本当に削除しますか？」という確認ダイアログが表示されます。

ただし、`button_to` ヘルパーと一緒にこの属性を使用する場合は、`button_to` ヘルパーが内部でレンダリングするフォームに追加する必要があります。

```erb
<%= button_to "Delete post", post, method: :delete, form: { data: { turbo_confirm: "本当に削除しますか？" } } %>
```

### Ajax リクエスト

JavaScript から非 GET リクエストを行う場合、`X-CSRF-Token` ヘッダーが必要です。
このヘッダーがないと、リクエストは Rails によって受け入れられません。

注意: このトークンは、Rails によるクロスサイトリクエストフォージェリ（CSRF）攻撃を防ぐために必要です。[セキュリティガイド](security.html#cross-site-request-forgery-csrf)を読んでください。

[Rails Request.JS](https://github.com/rails/request.js) は、Rails に必要なリクエストヘッダーを追加するロジックをカプセル化しています。パッケージから `FetchRequest` クラスをインポートし、リクエストメソッド、URL、オプションを渡してインスタンスを作成し、`await request.perform()` を呼び出してレスポンスを処理します。

例:

```javascript
import { FetchRequest } from '@rails/request.js'

....

async myMethod () {
  const request = new FetchRequest('post', 'localhost:3000/posts', {
    body: JSON.stringify({ name: 'Request.JS' })
  })
  const response = await request.perform()
  if (response.ok) {
    const body = await response.text
  }
}
```

Ajax コールを行うために別のライブラリを使用する場合は、セキュリティトークンをデフォルトのヘッダーとして自分で追加する必要があります。トークンを取得するには、アプリケーションビューで [`csrf_meta_tags`][] によって出力される `<meta name='csrf-token' content='THE-TOKEN'>` タグを確認してください。次のようにすることができます。

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
