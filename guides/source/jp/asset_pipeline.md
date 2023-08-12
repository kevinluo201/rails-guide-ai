**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0f0bbb2fd67f1843d30e360c15c03c61
アセットパイプライン
==================

このガイドでは、アセットパイプラインについて説明します。

このガイドを読み終えると、以下のことがわかります：

* アセットパイプラインとは何か、そして何をするのか。
* アプリケーションのアセットを適切に整理する方法。
* アセットパイプラインの利点。
* パイプラインにプリプロセッサを追加する方法。
* ジェムと一緒にアセットをパッケージ化する方法。

--------------------------------------------------------------------------------

アセットパイプラインとは何ですか？
---------------------------

アセットパイプラインは、JavaScriptやCSSのアセットの配信を処理するためのフレームワークを提供します。これは、HTTP/2や連結、最小化などの技術を活用して行われます。最後に、他のジェムからのアセットと自動的に組み合わせることができます。

アセットパイプラインは、[importmap-rails](https://github.com/rails/importmap-rails)、[sprockets](https://github.com/rails/sprockets)、[sprockets-rails](https://github.com/rails/sprockets-rails)のジェムによって実装され、デフォルトで有効になっています。新しいアプリケーションを作成する際に無効にすることもできます。

```bash
$ rails new appname --skip-asset-pipeline
```

注意：このガイドでは、デフォルトのアセットパイプラインに焦点を当てています。CSSには`sprockets`、JavaScriptの処理には`importmap-rails`のみを使用しています。これらの2つの主な制限は、トランスパイルのサポートがないため、`Babel`、`Typescript`、`Sass`、`React JSX形式`、`TailwindCSS`などを使用することができないことです。JavaScript/CSSのトランスパイルが必要な場合は、[代替ライブラリのセクション](#alternative-libraries)を読むことをお勧めします。

## 主な機能

アセットパイプラインの最初の機能は、SHA256のフィンガープリントを各ファイル名に挿入することで、ファイルがWebブラウザとCDNによってキャッシュされるようにすることです。このフィンガープリントは、ファイルの内容が変更されると自動的に更新され、キャッシュが無効になります。

アセットパイプラインの2番目の機能は、JavaScriptファイルの配信時に[import maps](https://github.com/WICG/import-maps)を使用することです。これにより、トランスパイルやバンドルなしでESモジュール（ESM）用に作られたJavaScriptライブラリを使用してモダンなアプリケーションを構築することができます。これにより、「Webpack」、「yarn」、「node」などのJavaScriptツールチェーンの必要性がなくなります。

アセットパイプラインの3番目の機能は、すべてのCSSファイルを1つのメインの`.css`ファイルに連結し、それを最小化または圧縮することです。後でこのガイドで学ぶように、この戦略を好きなようにカスタマイズすることができます。本番環境では、Railsは各ファイル名にSHA256のフィンガープリントを挿入するため、ファイルがWebブラウザによってキャッシュされます。ファイルの内容を変更すると、このフィンガープリントが変更され、キャッシュが無効になります。

アセットパイプラインの4番目の機能は、CSSの高レベル言語を使用してアセットをコーディングすることができることです。

### フィンガープリントとは何であり、なぜ気にする必要がありますか？

フィンガープリントは、ファイルの内容に依存してファイル名を一意にする技術です。ファイルの内容が変更されると、ファイル名も変更されます。静的または頻繁に変更されないコンテンツの場合、異なるサーバーやデプロイ日付を超えて、2つのバージョンのファイルが同一であるかどうかを簡単に判断する方法を提供します。

ファイル名が一意であり、その内容に基づいている場合、HTTPヘッダーを設定して、キャッシュ（CDN、ISP、ネットワーキング機器、Webブラウザなど）がコンテンツの自己のコピーを保持するように促すことができます。コンテンツが更新されると、フィンガープリントが変更されます。これにより、リモートクライアントはコンテンツの新しいコピーを要求します。これは一般的に「キャッシュバスティング」として知られています。

Sprocketsがフィンガープリントに使用する技術は、通常、名前の末尾にコンテンツのハッシュを挿入することです。たとえば、CSSファイル`global.css`は次のようになります。

```
global-908e25f4bf641868d8683022a5b62f54.css
```

これは、Railsのアセットパイプラインで採用されている戦略です。

フィンガープリントは、開発環境と本番環境の両方でデフォルトで有効になっています。[`config.assets.digest`][]オプションを使用して、設定で有効または無効にすることができます。
インポートマップとは何か、なぜ私が気にする必要があるのか？

インポートマップを使用すると、ブラウザから直接バージョン管理/ダイジェストされたファイルにマッピングされた論理名を使用してJavaScriptモジュールをインポートできます。そのため、トランスパイルやバンドリングの必要なく、ESモジュール（ESM）用に作られたJavaScriptライブラリを使用して、モダンなJavaScriptアプリケーションを構築することができます。

このアプローチでは、1つの大きなJavaScriptファイルではなく、多くの小さなJavaScriptファイルを配信します。HTTP/2のおかげで、初期の転送時には以前のようにパフォーマンスに大きなペナルティはありません。実際には、キャッシュの動態が改善されるため、長期的には大きな利点があります。

JavaScriptアセットパイプラインとしてのインポートマップの使用方法
-----------------------------

インポートマップは、デフォルトのJavaScriptプロセッサであり、インポートマップの生成ロジックは[`importmap-rails`](https://github.com/rails/importmap-rails) gemによって処理されます。

警告：インポートマップはJavaScriptファイルのみに使用され、CSSの配信には使用できません。CSSについては[Sprocketsセクション](#how-to-use-sprockets)を確認してください。

詳しい使用方法については、Gemのホームページに詳細な使用方法が記載されていますが、`importmap-rails`の基本を理解することが重要です。

### 動作原理

インポートマップは、いわゆる「ベアモジュール指定子」のための文字列置換です。JavaScriptモジュールのインポート名を標準化することができます。

たとえば、次のようなインポート定義は、インポートマップなしでは機能しません：

```javascript
import React from "react"
```

これを機能させるには、次のように定義する必要があります：

```javascript
import React from "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

ここでインポートマップが登場します。`react`という名前を`https://ga.jspm.io/npm:react@17.0.2/index.js`のアドレスに固定するように定義します。この情報により、ブラウザは簡略化された`import React from "react"`の定義を受け入れます。インポートマップは、ライブラリのソースアドレスのエイリアスと考えてください。

### 使用方法

`importmap-rails`を使用すると、ライブラリのパスを名前に固定するインポートマップの設定ファイルを作成できます。

```ruby
# config/importmap.rb
pin "application"
pin "react", to: "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

設定されたすべてのインポートマップは、`<head>`要素に`<%= javascript_importmap_tags %>`を追加することでアプリケーションにアタッチされます。`javascript_importmap_tags`は、`head`要素にいくつかのスクリプトをレンダリングします。

- すべての設定されたインポートマップを含むJSON：

```html
<script type="importmap">
{
  "imports": {
    "application": "/assets/application-39f16dc3f3....js"
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js"
  }
}
</script>
```

- 古いブラウザで`import maps`をサポートするためのポリフィルとしての[`Es-module-shims`](https://github.com/guybedford/es-module-shims)：

```html
<script src="/assets/es-module-shims.min" async="async" data-turbo-track="reload"></script>
```

- `app/javascript/application.js`からJavaScriptをロードするためのエントリーポイント：

```html
<script type="module">import "application"</script>
```

### JavaScript CDNを介したnpmパッケージの使用

`importmap-rails`のインストールの一部として追加される`./bin/importmap`コマンドを使用して、インポートマップ内のnpmパッケージを固定、解除、または更新することができます。このバイナリスタブは[`JSPM.org`](https://jspm.org/)を使用します。

次のように機能します：

```sh
./bin/importmap pin react react-dom
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/index.js
Pinning "react-dom" to https://ga.jspm.io/npm:react-dom@17.0.2/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
Pinning "scheduler" to https://ga.jspm.io/npm:scheduler@0.20.2/index.js

./bin/importmap json

{
  "imports": {
    "application": "/assets/application-37f365cbecf1fa2810a8303f4b6571676fa1f9c56c248528bc14ddb857531b95.js",
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js",
    "react-dom": "https://ga.jspm.io/npm:react-dom@17.0.2/index.js",
    "object-assign": "https://ga.jspm.io/npm:object-assign@4.1.1/index.js",
    "scheduler": "https://ga.jspm.io/npm:scheduler@0.20.2/index.js"
  }
}
```

上記のように、reactとreact-domの2つのパッケージは、jspmのデフォルトで解決されると、合計4つの依存関係に解決されます。

これで、他のモジュールと同様に、`application.js`のエントリーポイントでこれらを使用できます：

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

特定のバージョンを固定することもできます：

```sh
./bin/importmap pin react@17.0.1
Pinning "react" to https://ga.jspm.io/npm:react@17.0.1/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

または、ピンを解除することもできます：

```sh
./bin/importmap unpin react
Unpinning "react"
Unpinning "object-assign"
```

パッケージの環境を制御することもできます。パッケージには「本番」（デフォルト）と「開発」のビルドが別々に存在する場合です：

```sh
./bin/importmap pin react --env development
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/dev.index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

ピンをする際に、デフォルト以外のサポートされているCDNプロバイダーを選択することもできます。例えば、[`unpkg`](https://unpkg.com/)や[`jsdelivr`](https://www.jsdelivr.com/)（デフォルトは[`jspm`](https://jspm.org/)）：

```sh
./bin/importmap pin react --from jsdelivr
Pinning "react" to https://cdn.jsdelivr.net/npm/react@17.0.2/index.js
```
ただし、ピンを1つのプロバイダから別のプロバイダに切り替える場合、2番目のプロバイダで使用されていない最初のプロバイダによって追加された依存関係をクリーンアップする必要があるかもしれません。

すべてのオプションを表示するには、`./bin/importmap`を実行します。

このコマンドは、論理的なパッケージ名をCDNのURLに解決するための便利なラッパーに過ぎません。CDNのURLを自分で調べてピンを追加することもできます。たとえば、ReactにSkypackを使用したい場合は、次の内容を`config/importmap.rb`に追加するだけです。

```ruby
pin "react", to: "https://cdn.skypack.dev/react"
```

### ピンされたモジュールのプリロード

ブラウザが最も深くネストされたインポートに到達する前に、ファイルを1つずつロードする必要があるというウォーターフォール効果を避けるために、importmap-railsは[modulepreloadリンク](https://developers.google.com/web/updates/2017/12/modulepreload)をサポートしています。ピンされたモジュールは、ピンに`preload: true`を追加することでプリロードできます。

アプリ全体で使用されるライブラリやフレームワークをプリロードすることは良いアイデアです。これにより、ブラウザにそれらを早めにダウンロードするように指示することができます。

例：

```ruby
# config/importmap.rb
pin "@github/hotkey", to: "https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js", preload: true
pin "md5", to: "https://cdn.jsdelivr.net/npm/md5@2.3.0/md5.js"

# app/views/layouts/application.html.erb
<%= javascript_importmap_tags %>

# importmapがセットアップされる前に次のリンクが含まれます：
<link rel="modulepreload" href="https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js">
...
```

注意：最新のドキュメントについては、[`importmap-rails`](https://github.com/rails/importmap-rails)リポジトリを参照してください。

Sprocketsの使用方法
-----------------------------

アプリケーションのアセットをWebに公開するための素朴なアプローチは、`public`フォルダのサブディレクトリ（例：`images`や`stylesheets`）に保存することです。ただし、これを手動で行うのは困難です。なぜなら、ほとんどのモダンなWebアプリケーションでは、アセットを特定の方法で処理する必要があるからです。例えば、アセットの圧縮やフィンガープリントの追加などです。

Sprocketsは、設定されたディレクトリに保存されているアセットを自動的に前処理し、フィンガープリント、圧縮、ソースマップの生成などの機能を持つ`public/assets`フォルダに公開するように設計されています。

アセットはまだ`public`の階層に配置することができます。`config.public_file_server.enabled`がtrueに設定されている場合、`public`以下のアセットはアプリケーションまたはWebサーバーによって静的ファイルとして提供されます。一部の前処理が必要なファイルには、`manifest.js`ディレクティブを定義する必要があります。

本番環境では、Railsはこれらのファイルをデフォルトで`public/assets`に事前コンパイルします。事前コンパイルされたコピーは、Webサーバーによって静的アセットとして提供されます。`app/assets`のファイルは、本番環境では直接提供されません。

### マニフェストファイルとディレクティブ

Sprocketsでアセットをコンパイルする際、Sprocketsは通常、`application.css`や画像などのトップレベルのターゲットをどれをコンパイルするかを決定する必要があります。トップレベルのターゲットは、Sprocketsの`manifest.js`ファイルで定義されています。デフォルトでは、次のようになります：

```js
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_tree ../../javascript .js
//= link_tree ../../../vendor/javascript .js
```

これには、Sprocketsにファイルをビルドするために必要なファイルを指示する「ディレクティブ」が含まれています。

これにより、`./app/assets/images`ディレクトリまたはそのサブディレクトリに見つかるすべてのファイルの内容が含まれるようになります。また、`./app/javascript`または`./vendor/javascript`で直接JSとして認識されるファイルも含まれます。

`./app/assets/stylesheets`ディレクトリ（サブディレクトリは含まれません）からCSSをロードします。`./app/assets/stylesheets`フォルダに`application.css`と`marketing.css`ファイルがあると仮定すると、ビューから`<%= stylesheet_link_tag "application" %>`または`<%= stylesheet_link_tag "marketing" %>`を使用してこれらのスタイルシートをロードできます。

デフォルトではJavaScriptファイルは`assets`ディレクトリからロードされないことに注意してください。これは`importmap-rails`ジェムのデフォルトのエントリポイントである`./app/javascript`であり、`vendor`フォルダはダウンロードしたJSパッケージが保存される場所です。

`manifest.js`では、ディレクトリ全体ではなく特定のファイルをロードするために`link`ディレクティブを指定することもできます。`link`ディレクティブでは、明示的なファイル拡張子を指定する必要があります。

Sprocketsは指定されたファイルをロードし、必要に応じて処理し、1つのファイルに結合し、その後圧縮します（`config.assets.css_compressor`または`config.assets.js_compressor`の値に基づいて）。圧縮により、ファイルサイズが縮小され、ブラウザがファイルを高速にダウンロードできるようになります。
### コントローラー固有のアセット

スキャフォールドまたはコントローラーを生成すると、Railsはそのコントローラー用のスタイルシートファイルも生成します。また、スキャフォールドを生成する場合、Railsは`scaffolds.css`というファイルも生成します。

例えば、`ProjectsController`を生成すると、Railsは`app/assets/stylesheets/projects.css`という新しいファイルを追加します。デフォルトでは、これらのファイルは`manifest.js`ファイルの`link_directory`ディレクティブを使用して、アプリケーションで直ちに使用できるようになります。

また、以下の方法を使用して、各コントローラーごとにコントローラー固有のスタイルシートファイルのみを含めることもできます。

```html+erb
<%= stylesheet_link_tag params[:controller] %>
```

これを行う場合、`application.css`で`require_tree`ディレクティブを使用していないことを確認してください。なぜなら、それによってコントローラー固有のアセットが複数回含まれる可能性があるからです。

### アセットの組織化

パイプラインアセットは、`app/assets`、`lib/assets`、または`vendor/assets`のいずれかの場所に配置することができます。

* `app/assets`は、カスタムの画像やスタイルシートなど、アプリケーションが所有するアセット用です。

* `app/javascript`はJavaScriptコード用です。

* `vendor/[assets|javascript]`は、CSSフレームワークやJavaScriptライブラリなど、外部のエンティティが所有するアセット用です。ただし、他のファイルへの参照を持つサードパーティのコード（画像、スタイルシートなど）もアセットパイプラインで処理する必要があるため、`asset_path`などのヘルパーを使用して書き直す必要があります。

その他の場所は、`manifest.js`ファイルで設定することができます。[マニフェストファイルとディレクティブ](#manifest-files-and-directives)を参照してください。

#### 検索パス

ファイルがマニフェストやヘルパーから参照されると、Sprocketsは`manifest.js`で指定されたすべての場所を検索します。Railsコンソールで[`Rails.application.config.assets.paths`](configuring.html#config-assets-paths)を検査することで、検索パスを確認できます。

#### フォルダのプロキシとしてのインデックスファイルの使用

Sprocketsは、特定の目的のために`index`という名前のファイル（関連する拡張子を持つ）を使用します。

例えば、`lib/assets/stylesheets/library_name`に保存されている多くのモジュールを持つCSSライブラリがある場合、ファイル`lib/assets/stylesheets/library_name/index.css`はこのライブラリのすべてのファイルのマニフェストとして機能します。このファイルには、必要なファイルのリストが順番に含まれるか、単純な`require_tree`ディレクティブが含まれる場合があります。

これは、`public/library_name/index.html`のファイルが`/library_name`へのリクエストでアクセスできる方法とも似ています。つまり、直接インデックスファイルを使用することはできません。

`.css`ファイル内でライブラリ全体にアクセスするには、次のようにします。

```css
/* ...
*= require library_name
*/
```

これにより、関連するコードをグループ化して他の場所でインクルードすることで、メンテナンスが容易になり、整理された状態を保つことができます。

### アセットへのリンクのコーディング

Sprocketsはアセットにアクセスするための新しいメソッドを追加しません。引き続きおなじみの`stylesheet_link_tag`を使用します。

```erb
<%= stylesheet_link_tag "application", media: "all" %>
```

Railsにデフォルトで含まれている[`turbo-rails`](https://github.com/hotwired/turbo-rails) gemを使用している場合は、`data-turbo-track`オプションを含める必要があります。これにより、Turboがアセットが更新されたかどうかをチェックし、更新されている場合はページにロードされます。

```erb
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
```

通常のビューでは、次のようにして`app/assets/images`ディレクトリの画像にアクセスできます。

```erb
<%= image_tag "rails.png" %>
```

アプリケーション内でパイプラインが有効になっている場合（および現在の環境コンテキストで無効にされていない場合）、このファイルはSprocketsによって提供されます。`public/assets/rails.png`にファイルが存在する場合は、ウェブサーバーによって提供されます。

また、`public/assets/rails-f90d8a84c707a8dc923fca1ca1895ae8ed0a09237f6992015fef1e11be77c023.png`のようなSHA256ハッシュを持つファイルのリクエストも同様に処理されます。これらのハッシュは、このガイドの後半の[本番環境](#in-production)のセクションで生成方法が説明されています。

必要に応じて、画像をサブディレクトリに整理し、タグでディレクトリの名前を指定してアクセスすることもできます。

```erb
<%= image_tag "icons/rails.png" %>
```

警告: アセットをプリコンパイルしている場合（[本番環境](#in-production)を参照）、存在しないアセットにリンクすると、呼び出し元のページで例外が発生します。これには、空の文字列にリンクすることも含まれます。したがって、`image_tag`や他のヘルパーをユーザーからのデータと慎重に使用する必要があります。
#### CSSとERB

アセットパイプラインは自動的にERBを評価します。これは、CSSアセットに`erb`拡張子を追加すると（例えば、`application.css.erb`）、`asset_path`のようなヘルパーがCSSルールで利用できることを意味します。

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

これは参照されている特定のアセットへのパスを書き込みます。この例では、`app/assets/images/image.png`のようなアセットのロードパスに画像が存在することが理にかなっています。もしこの画像が既に指紋付きファイルとして`public/assets`に存在する場合、そのパスが参照されます。

もし[データURI](https://en.wikipedia.org/wiki/Data_URI_scheme)を使用したい場合 - 画像データをCSSファイルに直接埋め込む方法 - `asset_data_uri`ヘルパーを使用することができます。

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

これは正しくフォーマットされたデータURIをCSSソースに挿入します。

クロージングタグは`-%>`のスタイルではないことに注意してください。

### アセットが見つからない場合にエラーを発生させる

もしsprockets-rails >= 3.2.0を使用している場合、アセットの検索が行われ、何も見つからない場合の動作を設定することができます。もし「アセットのフォールバック」をオフにすると、アセットが見つからない場合にエラーが発生します。

```ruby
config.assets.unknown_asset_fallback = false
```

「アセットのフォールバック」が有効になっている場合、アセットが見つからない場合はパスが出力され、エラーは発生しません。アセットのフォールバックの動作はデフォルトで無効になっています。

### ダイジェストをオフにする

`config/environments/development.rb`を更新してダイジェストをオフにすることができます。

```ruby
config.assets.digest = false
```

このオプションがtrueの場合、アセットのURLに対してダイジェストが生成されます。

### ソースマップをオンにする

`config/environments/development.rb`を更新してソースマップをオンにすることができます。

```ruby
config.assets.debug = true
```

デバッグモードがオンになっている場合、Sprocketsは各アセットに対してソースマップを生成します。これにより、ブラウザの開発者ツールで各ファイルを個別にデバッグすることができます。

アセットはサーバーが起動した後の最初のリクエストでコンパイルされ、キャッシュされます。Sprocketsは後続のリクエストでリクエストオーバーヘッドを減らすために`must-revalidate`キャッシュコントロールHTTPヘッダーを設定します - これにより、ブラウザは304（未変更）のレスポンスを受け取ります。

リクエスト間でマニフェスト内のファイルのいずれかが変更された場合、サーバーは新しいコンパイル済みファイルで応答します。

本番環境での動作
-------------

本番環境では、Sprocketsは上記で説明した指紋付けスキームを使用します。デフォルトでは、Railsはアセットが事前にコンパイルされ、ウェブサーバーによって静的アセットとして提供されることを想定しています。

事前コンパイルフェーズでは、コンパイルされたファイルの内容からSHA256が生成され、ディスクに書き込まれる際にファイル名に挿入されます。これらの指紋付き名前は、マニフェスト名の代わりにRailsのヘルパーによって使用されます。

例えば、次のようなコード:

```erb
<%= stylesheet_link_tag "application" %>
```

は次のようなものを生成します:

```html
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" rel="stylesheet" />
```

指紋付けの動作は[`config.assets.digest`][]の初期化オプションによって制御されます（デフォルトは`true`）。

注意: 通常の状況では、デフォルトの`config.assets.digest`オプションを変更する必要はありません。ファイル名にダイジェストが含まれていない場合、かつ遠隔クライアントに遠い将来のヘッダーが設定されている場合、その内容が変更されたときにファイルを再取得する必要がなくなります。


### アセットの事前コンパイル

Railsには、アセットマニフェストとパイプライン内の他のファイルをコンパイルするためのコマンドがバンドルされています。

コンパイルされたアセットは、[`config.assets.prefix`][]で指定された場所に書き込まれます。デフォルトでは、これは`/assets`ディレクトリです。

デプロイ中にサーバーでこのコマンドを呼び出すことで、アセットのコンパイル済みバージョンをサーバー上で直接作成することができます。ローカルでのコンパイルに関する情報については、次のセクションを参照してください。

コマンドは次のとおりです:

```bash
$ RAILS_ENV=production rails assets:precompile
```

これにより、`config.assets.prefix`で指定されたフォルダが`shared/assets`にリンクされます。既にこの共有フォルダを使用している場合は、独自のデプロイコマンドを作成する必要があります。
デプロイ間でこのフォルダが共有されるようにすることは重要です。これにより、古いコンパイル済みアセットを参照するリモートキャッシュページがキャッシュページの寿命中に機能し続けます。

注意：常に、拡張子が `.js` または `.css` で終わる予想されるコンパイル済みファイル名を指定してください。

このコマンドは、すべてのアセットとそれらの対応するフィンガープリントのリストを含む `.sprockets-manifest-randomhex.json`（`randomhex` は16バイトのランダムな16進数文字列です）を生成します。これは、RailsのヘルパーメソッドがSprocketsにマッピングリクエストを戻さないようにするために使用されます。典型的なマニフェストファイルは次のようになります。

```json
{"files":{"application-<fingerprint>.js":{"logical_path":"application.js","mtime":"2016-12-23T20:12:03-05:00","size":412383,
"digest":"<fingerprint>","integrity":"sha256-<random-string>"}},
"assets":{"application.js":"application-<fingerprint>.js"}}
```

アプリケーションでは、マニフェストにリストされるファイルとアセットがさらにあり、`<fingerprint>` と `<random-string>` も生成されます。

マニフェストのデフォルトの場所は、`config.assets.prefix`（デフォルトでは '/assets'）で指定された場所のルートです。

注意：本番環境でコンパイルされていないファイルが欠落している場合、`Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError` 例外が発生し、欠落しているファイルの名前が示されます。


#### 遠い将来の有効期限ヘッダ

コンパイル済みアセットはファイルシステム上に存在し、ウェブサーバーによって直接提供されます。デフォルトでは、それらには遠い将来のヘッダはありません。そのため、フィンガープリントの利点を得るためには、サーバーの設定を更新してこれらのヘッダを追加する必要があります。

Apacheの場合：

```apache
# Expires*ディレクティブは、Apacheモジュール`mod_expires`が有効になっている必要があります。
<Location /assets/>
  # Last-Modifiedが存在する場合、ETagの使用は推奨されません
  Header unset ETag
  FileETag None
  # RFCでは1年間のみキャッシュするとされています
  ExpiresActive On
  ExpiresDefault "access plus 1 year"
</Location>
```

NGINXの場合：

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
}
```

### ローカルでの事前コンパイル

場合によっては、本番サーバーでアセットをコンパイルすることが望ましくない場合があります。たとえば、本番ファイルシステムへの書き込みアクセスが制限されている場合や、アセットに変更を加えずに頻繁にデプロイする予定がある場合などです。

このような場合、アセットを _ローカルに_ 事前コンパイルすることができます。つまり、本番にデプロイする前に、コンパイル済みで本番用のアセットをソースコードリポジトリに追加します。これにより、本番サーバーでの各デプロイごとに個別にアセットを事前コンパイルする必要はありません。

上記と同様に、次のコマンドを使用してこの手順を実行できます。

```bash
$ RAILS_ENV=production rails assets:precompile
```

次の注意点に注意してください。

* コンパイル済みのアセットが利用可能な場合、それらが提供されます。ただし、元の（コンパイルされていない）アセットとは異なる場合でも、開発サーバーでも提供されます。

    開発サーバーが常にアセットを即座にコンパイルするようにするために（つまり、常にコードの最新の状態を反映するために）、開発環境は本番環境とは異なる場所に事前コンパイルされたアセットを保持するように設定されている必要があります。そうしないと、本番用に事前コンパイルされたアセットが開発環境でのそれらへのリクエストを上書きしてしまいます（つまり、アセットへの後続の変更がブラウザに反映されません）。

    これを実現するには、`config/environments/development.rb` に次の行を追加します。

    ```ruby
    config.assets.prefix = "/dev-assets"
    ```

* デプロイツール（たとえば、Capistrano）のアセット事前コンパイルタスクは無効にする必要があります。
* 必要な圧縮ツールや最小化ツールは、開発システムで利用可能である必要があります。

また、`ENV["SECRET_KEY_BASE_DUMMY"]` を設定することで、一時ファイルに保存されたランダムに生成された `secret_key_base` の使用をトリガーすることもできます。これは、本番環境のアセットを事前コンパイルする際に、本番のシークレットにアクセスする必要がないビルドステップの一部として使用すると便利です。

```bash
$ SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
```

### ライブコンパイル

一部の状況では、ライブコンパイルを使用したい場合があります。このモードでは、パイプライン内のアセットへのすべてのリクエストが直接Sprocketsによって処理されます。

このオプションを有効にするには、次のように設定します。

```ruby
config.assets.compile = true
```
最初のリクエストでは、[Assets Cache Store](#assets-cache-store)で説明されているように、アセットはコンパイルされキャッシュされ、ヘルパーで使用されるマニフェスト名にはSHA256ハッシュが含まれるように変更されます。

Sprocketsはまた、`Cache-Control` HTTPヘッダを`max-age=31536000`に設定します。これにより、サーバとクライアントのブラウザ間のすべてのキャッシュに、このコンテンツ（提供されるファイル）を1年間キャッシュできることを示します。これにより、サーバからのこのアセットへのリクエストの数が減少し、アセットはローカルのブラウザキャッシュまたはいくつかの中間キャッシュに存在する可能性が高くなります。

このモードはメモリをより多く使用し、パフォーマンスが悪くなり、推奨されません。

### CDN

CDNは[コンテンツデリバリーネットワーク](https://en.wikipedia.org/wiki/Content_delivery_network)の略で、主に世界中にアセットをキャッシュするために設計されています。これにより、ブラウザがアセットをリクエストする際に、キャッシュされたコピーが地理的に近い場所にあることが保証されます。本番環境でRailsサーバから直接アセットを提供している場合、最良の方法はアプリケーションの前にCDNを使用することです。

CDNを使用する一般的なパターンは、本番アプリケーションを「オリジン」サーバとして設定することです。これは、ブラウザがCDNからアセットをリクエストし、キャッシュミスが発生した場合、ファイルをサーバから取得してキャッシュすることを意味します。たとえば、Railsアプリケーションを`example.com`で実行し、`mycdnsubdomain.fictional-cdn.com`でCDNを設定している場合、`mycdnsubdomain.fictional-cdn.com/assets/smile.png`にリクエストが行われると、CDNは`example.com/assets/smile.png`に一度リクエストを行い、リクエストをキャッシュします。同じURLに対する次のCDNへのリクエストは、キャッシュされたコピーにアクセスします。CDNがアセットを直接提供できる場合、リクエストはRailsサーバには届きません。CDNからのアセットはブラウザに地理的に近いため、リクエストが高速化され、サーバはアセットの提供に時間を費やす必要がないため、できるだけ迅速にアプリケーションコードの提供に集中できます。

#### 静的アセットを提供するためのCDNの設定

CDNを設定するには、アプリケーションを公開可能なURLで本番環境で実行する必要があります。たとえば、`example.com`です。次に、クラウドホスティングプロバイダからCDNサービスにサインアップする必要があります。これを行う際には、CDNの「オリジン」をウェブサイト`example.com`に設定する必要があります。オリジンサーバの設定に関するドキュメントは、プロバイダのサイトを参照してください。

プロビジョニングしたCDNは、アプリケーションのためのカスタムサブドメイン（例：`mycdnsubdomain.fictional-cdn.com`）を提供するはずです（注意：fictional-cdn.comはこの執筆時点では有効なCDNプロバイダではありません）。CDNサーバを設定したら、ブラウザに対してRailsサーバの代わりにCDNを使用してアセットを取得するように指示する必要があります。これを行うには、Railsでアセットホストを相対パスではなくCDNに設定する必要があります。Railsでアセットホストを設定するには、`config/environments/production.rb`で[`config.asset_host`][]を設定する必要があります。

```ruby
config.asset_host = 'mycdnsubdomain.fictional-cdn.com'
```

注意：「ホスト」のみを指定する必要があります。つまり、サブドメインとルートドメインであり、`http://`や`https://`などのプロトコルや「スキーム」を指定する必要はありません。ウェブページがリクエストされる際に生成されるアセットへのリンクのプロトコルは、デフォルトでウェブページへのアクセス方法と一致します。

ステージングサイトのコピーを実行する際に設定を簡単にするために、この値を[環境変数](https://en.wikipedia.org/wiki/Environment_variable)を介して設定することもできます。

```ruby
config.asset_host = ENV['CDN_HOST']
```

注意：これを動作させるには、サーバ上で`CDN_HOST`を`mycdnsubdomain.fictional-cdn.com`に設定する必要があります。
サーバーとCDNを設定した後、ヘルパーからのアセットパスは次のようになります。

```erb
<%= asset_path('smile.png') %>
```

これは、完全なCDNのURLとしてレンダリングされます。例えば、`http://mycdnsubdomain.fictional-cdn.com/assets/smile.png`（可読性のためにダイジェストは省略されています）。

CDNに`smile.png`のコピーがある場合、それはブラウザに提供され、サーバーはリクエストがあったことさえ知りません。CDNにコピーがない場合、それは「オリジン」の`example.com/assets/smile.png`でそれを見つけようとし、将来の使用のために保存します。

CDNからの一部のアセットのみを提供したい場合は、アセットヘルパーのカスタム`:host`オプションを使用することができます。これは[`config.action_controller.asset_host`][]で設定された値を上書きします。

```erb
<%= asset_path 'image.png', host: 'mycdnsubdomain.fictional-cdn.com' %>
```


#### CDNキャッシュの動作をカスタマイズする

CDNはコンテンツをキャッシュすることで動作します。CDNに古いまたは不正なコンテンツがある場合、アプリケーションにとって有益ではなくなります。このセクションの目的は、ほとんどのCDNの一般的なキャッシュ動作を説明することです。特定のプロバイダーは若干異なる動作をする場合があります。

##### CDNリクエストのキャッシュ

CDNはアセットのキャッシュに適しているとされていますが、実際にはリクエスト全体をキャッシュします。これにはアセットの本体とヘッダーが含まれます。最も重要なのは`Cache-Control`です。これはCDN（およびWebブラウザ）にコンテンツをキャッシュする方法を伝えます。つまり、`/assets/i-dont-exist.png`のような存在しないアセットがリクエストされ、Railsアプリケーションが404を返す場合、有効な`Cache-Control`ヘッダーが存在する場合、CDNはおそらく404ページをキャッシュします。

##### CDNヘッダーのデバッグ

CDNでヘッダーが適切にキャッシュされているかどうかを確認する方法の1つは、[curl](https://explainshell.com/explain?cmd=curl+-I+http%3A%2F%2Fwww.example.com)を使用してヘッダーをリクエストすることです。サーバーとCDNの両方からヘッダーをリクエストして、同じであることを確認できます。

```bash
$ curl -I http://www.example/assets/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK
Server: Cowboy
Date: Sun, 24 Aug 2014 20:27:50 GMT
Connection: keep-alive
Last-Modified: Thu, 08 May 2014 01:24:14 GMT
Content-Type: text/css
Cache-Control: public, max-age=2592000
Content-Length: 126560
Via: 1.1 vegur
```

CDNのコピーと比較すると、

```bash
$ curl -I http://mycdnsubdomain.fictional-cdn.com/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK Server: Cowboy Last-
Modified: Thu, 08 May 2014 01:24:14 GMT Content-Type: text/css
Cache-Control:
public, max-age=2592000
Via: 1.1 vegur
Content-Length: 126560
Accept-Ranges:
bytes
Date: Sun, 24 Aug 2014 20:28:45 GMT
Via: 1.1 varnish
Age: 885814
Connection: keep-alive
X-Served-By: cache-dfw1828-DFW
X-Cache: HIT
X-Cache-Hits:
68
X-Timer: S1408912125.211638212,VS0,VE0
```

CDNのドキュメントを確認して、`X-Cache`などの追加情報や追加される可能性のあるヘッダーなどの追加情報があるかどうかを確認してください。

##### CDNとCache-Controlヘッダー

[`Cache-Control`][]ヘッダーは、リクエストをキャッシュする方法を説明します。CDNを使用しない場合、ブラウザはこの情報を使用してコンテンツをキャッシュします。これは、ウェブサイトのCSSやJavaScriptを毎回再ダウンロードする必要がないように、変更されていないアセットに非常に役立ちます。一般的に、Railsサーバーはアセットが「公開」されていることをCDN（およびブラウザ）に伝える必要があります。つまり、どのキャッシュでもリクエストを保存できます。また、キャッシュを無効にする前にオブジェクトを保存する期間を示す`max-age`を設定することも一般的です。`max-age`の値は秒単位で設定され、最大値は1年の`31536000`です。これは、Railsアプリケーションで次のように設定することができます。

```ruby
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=31536000'
}
```

これで、アプリケーションが本番環境でアセットを提供すると、CDNは最大1年間アセットを保存します。ほとんどのCDNはリクエストのヘッダーもキャッシュするため、この`Cache-Control`はこのアセットを求めるすべての将来のブラウザに渡されます。ブラウザは、再リクエストする前にこのアセットを非常に長い時間保存できることを知ります。
##### CDNsとURLベースのキャッシュ無効化

ほとんどのCDNは、アセットの内容を完全なURLに基づいてキャッシュします。つまり、

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile-123.png
```

というリクエストは、

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

とは完全に異なるキャッシュです。

`Cache-Control`で遠い将来の`max-age`を設定したい場合（そして、そうするべきです）、アセットを変更する際にキャッシュが無効化されるようにしてください。たとえば、イメージの笑顔の色を黄色から青に変更する場合、サイトのすべての訪問者に新しい青い顔を表示したいです。Railsのアセットパイプラインを使用する場合、`config.assets.digest`はデフォルトでtrueに設定されているため、アセットが変更されるたびに異なるファイル名が付けられます。これにより、キャッシュ内のアイテムを手動で無効化する必要はありません。代わりに、異なる一意のアセット名を使用することで、ユーザーは最新のアセットを取得できます。

パイプラインのカスタマイズ
------------------------

### CSSの圧縮

CSSを圧縮するオプションの1つはYUIです。[YUI CSS
compressor](https://yui.github.io/yuicompressor/css.html)は、最小化を提供します。

以下の行は、YUI圧縮を有効にし、`yui-compressor` gemを必要とします。

```ruby
config.assets.css_compressor = :yui
```

### JavaScriptの圧縮

JavaScriptの圧縮の可能なオプションは、`:terser`、`:closure`、`:yui`です。それぞれ、`terser`、`closure-compiler`、`yui-compressor`のgemを使用する必要があります。

たとえば、`terser` gemを取り上げます。
このgemは、Rubyで[Terser](https://github.com/terser/terser)（Node.js向けに作成された）をラップしています。これにより、空白やコメントを削除し、ローカル変数名を短縮し、`if`と`else`ステートメントを可能な限り三項演算子に変更するなど、コードを圧縮します。

以下の行は、JavaScriptの圧縮に`terser`を呼び出します。

```ruby
config.assets.js_compressor = :terser
```

注意：`terser`を使用するには、[ExecJS](https://github.com/rails/execjs#readme)でサポートされているランタイムが必要です。macOSまたはWindowsを使用している場合、オペレーティングシステムにはJavaScriptランタイムがインストールされています。

注意：JavaScriptの圧縮は、`importmap-rails`や`jsbundling-rails`のgemを使用してアセットをロードする場合にも機能します。

### アセットのGZip圧縮

デフォルトでは、コンパイルされたアセットのGZipバージョンが生成されます。これに加えて、非GZip化されたバージョンのアセットも生成されます。GZip化されたアセットは、データの送信を効率化するのに役立ちます。これは、`gzip`フラグを設定することで構成できます。

```ruby
config.assets.gzip = false # GZip化されたアセットの生成を無効にする
```

GZip化されたアセットの提供方法については、ウェブサーバーのドキュメントを参照してください。

### 独自の圧縮器の使用

CSSとJavaScriptの圧縮のための圧縮器の設定は、任意のオブジェクトも受け入れます。このオブジェクトは、唯一の引数として文字列を受け取り、文字列を返す`compress`メソッドを持っている必要があります。

```ruby
class Transformer
  def compress(string)
    do_something_returning_a_string(string)
  end
end
```

これを有効にするには、`application.rb`の設定オプションに新しいオブジェクトを渡します。

```ruby
config.assets.css_compressor = Transformer.new
```

### _assets_パスの変更

Sprocketsがデフォルトで使用するパブリックパスは`/assets`です。

これを他のものに変更できます。

```ruby
config.assets.prefix = "/some_other_path"
```

これは、アセットパイプラインを使用していない古いプロジェクトを更新する場合や、既にこのパスを使用している場合、または新しいリソースにこのパスを使用したい場合に便利なオプションです。

### X-Sendfileヘッダー

X-Sendfileヘッダーは、Webサーバーに対して、アプリケーションからのレスポンスを無視し、代わりにディスクから指定されたファイルを提供するよう指示するものです。このオプションはデフォルトではオフになっていますが、サーバーがサポートしている場合に有効にすることができます。有効にすると、ファイルの提供の責任がWebサーバーに移り、速度が向上します。この機能の使用方法については、[send_file](https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file)を参照してください。

ApacheとNGINXはこのオプションをサポートしており、`config/environments/production.rb`で有効にすることができます。

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # Apache用
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # NGINX用
```
警告：既存のアプリケーションをアップグレードし、このオプションを使用する場合は、`production.rb` および本番環境の動作を定義する他の環境にのみこの設定オプションを貼り付けるように注意してください（`application.rb` ではなく）。

ヒント：詳細については、プロダクションウェブサーバーのドキュメントを参照してください：

- [Apache](https://tn123.org/mod_xsendfile/)
- [NGINX](https://www.nginx.com/resources/wiki/start/topics/examples/xsendfile/)

アセットキャッシュストア
------------------

デフォルトでは、Sprockets は開発環境と本番環境でアセットを `tmp/cache/assets` にキャッシュします。これは以下のように変更できます：

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:memory_store,
                                                { size: 32.megabytes })
end
```

アセットキャッシュストアを無効にするには：

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:null_store)
end
```

Gem へのアセットの追加
--------------------------

アセットは、gem の形で外部ソースからも取得できます。

良い例としては、`jquery-rails` gem があります。
この gem には `Rails::Engine` を継承するエンジンクラスが含まれています。
これにより、Rails はこの gem のディレクトリがアセットを含んでいる可能性があることを知らされ、このエンジンの `app/assets`、`lib/assets`、`vendor/assets` ディレクトリが Sprockets の検索パスに追加されます。

ライブラリまたは Gem をプリプロセッサにする
------------------------------------------

Sprockets は、プリプロセッサ、トランスフォーマ、コンプレッサ、エクスポータを使用して Sprockets の機能を拡張します。詳細については、[Sprockets の拡張](https://github.com/rails/sprockets/blob/master/guides/extending_sprockets.md)を参照してください。ここでは、テキスト/CSS（`.css`）ファイルの末尾にコメントを追加するためのプリプロセッサを登録しました。

```ruby
module AddComment
  def self.call(input)
    { data: input[:data] + "/* Hello From my sprockets extension */" }
  end
end
```

入力データを変更するモジュールができたので、MIME タイプのプリプロセッサとして登録する時が来ました。

```ruby
Sprockets.register_preprocessor 'text/css', AddComment
```


代替ライブラリ
------------------------------------------

これまでにアセットを処理するための複数のデフォルトアプローチがありました。Web は進化し、JavaScript 重視のアプリケーションが増えてきました。Rails の教義では、[メニューはおまかせ](https://rubyonrails.org/doctrine#omakase)と考えているため、デフォルトのセットアップに焦点を当てています：**Sprockets with Import Maps**。

JavaScript や CSS のフレームワーク/拡張には、一つの解決策がすべてに適しているわけではありません。デフォルトのセットアップでは十分ではない場合には、Rails のエコシステムには他のバンドリングライブラリが存在し、それらを使用することでより強力な機能を提供できます。

### jsbundling-rails

[`jsbundling-rails`](https://github.com/rails/jsbundling-rails) は、JavaScript を [esbuild](https://esbuild.github.io/)、[rollup.js](https://rollupjs.org/)、または [Webpack](https://webpack.js.org/) でバンドルするための Node.js 依存の代替手段です。

この gem は、開発時に自動的に出力を生成するための `yarn build --watch` プロセスを提供します。本番環境では、`assets:precompile` タスクに `javascript:build` タスクを自動的にフックして、すべてのパッケージ依存関係がインストールされ、すべてのエントリポイントの JavaScript がビルドされるようにします。

**`importmap-rails` の代わりに使用するタイミングは？** JavaScript コードがトランスパイルに依存している場合、つまり [Babel](https://babeljs.io/)、[TypeScript](https://www.typescriptlang.org/)、または React の `JSX` 形式を使用している場合は、`jsbundling-rails` を使用するのが適切です。

### Webpacker/Shakapacker

[`Webpacker`](webpacker.html) は、Rails 5 および 6 のデフォルトの JavaScript プリプロセッサおよびバンドラでしたが、現在は廃止されています。[`shakapacker`](https://github.com/shakacode/shakapacker) という後継のライブラリが存在しますが、Rails チームやプロジェクトによってメンテナンスされていません。

このリストの他のライブラリとは異なり、`webpacker`/`shakapacker` は Sprockets と完全に独立しており、JavaScript と CSS ファイルの両方を処理できます。詳細については、[Webpacker ガイド](https://guides.rubyonrails.org/webpacker.html)を参照してください。

注意：`jsbundling-rails` と `webpacker`/`shakapacker` の違いを理解するために、[Webpacker との比較](https://github.com/rails/jsbundling-rails/blob/main/docs/comparison_with_webpacker.md) ドキュメントを読んでください。

### cssbundling-rails

[`cssbundling-rails`](https://github.com/rails/cssbundling-rails) は、[Tailwind CSS](https://tailwindcss.com/)、[Bootstrap](https://getbootstrap.com/)、[Bulma](https://bulma.io/)、[PostCSS](https://postcss.org/)、または [Dart Sass](https://sass-lang.com/) を使用して CSS をバンドルおよび処理し、アセットパイプラインを介して CSS を配信することができます。

`jsbundling-rails` と同様の方法で機能し、開発時に `yarn build:css --watch` プロセスを使用してスタイルシートを再生成し、本番環境では `assets:precompile` タスクにフックします。

**Sprockets との違いは何ですか？** Sprockets 単体では Sass を CSS にトランスパイルすることはできません。Node.js が必要であり、`.sass` ファイルから `.css` ファイルを生成します。`.css` ファイルが生成された後、`Sprockets` はそれらをクライアントに配信することができます。
注意：`cssbundling-rails`はCSSを処理するためにNodeを使用しています。`dartsass-rails`と`tailwindcss-rails`のgemは、Tailwind CSSとDart Sassのスタンドアロンバージョンを使用しているため、Nodeの依存関係はありません。もし、`importmap-rails`を使用してJavascriptを処理し、CSSには`dartsass-rails`または`tailwindcss-rails`を使用している場合、Nodeの依存関係を完全に回避することができ、よりシンプルなソリューションになります。

### dartsass-rails

アプリケーションで[`Sass`](https://sass-lang.com/)を使用したい場合、[`dartsass-rails`](https://github.com/rails/dartsass-rails)は従来の`sassc-rails` gemの代わりとして提供されています。`dartsass-rails`は、`sassc-rails`で使用されている2020年に非推奨となった[`LibSass`](https://sass-lang.com/blog/libsass-is-deprecated)の代わりに、`Dart Sass`の実装を使用しています。

新しいgemは`sprockets`と直接統合されていません。インストール/移行手順については、[gemのホームページ](https://github.com/rails/dartsass-rails)を参照してください。

警告：人気のある`sassc-rails` gemは2019年以来メンテナンスされていません。

### tailwindcss-rails

[`tailwindcss-rails`](https://github.com/rails/tailwindcss-rails)は、Tailwind CSS v3フレームワークの[スタンドアロン実行可能バージョン](https://tailwindcss.com/blog/standalone-cli)のラッパーgemです。`rails new`コマンドに`--css tailwind`が指定された場合に新しいアプリケーションで使用されます。開発中に自動的にTailwindの出力を生成するための`watch`プロセスを提供します。本番環境では、`assets:precompile`タスクにフックします。
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.assets.digest`]: configuring.html#config-assets-digest
[`config.assets.prefix`]: configuring.html#config-assets-prefix
[`config.action_controller.asset_host`]: configuring.html#config-action-controller-asset-host
[`config.asset_host`]: configuring.html#config-asset-host
[`Cache-Control`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
