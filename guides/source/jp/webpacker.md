**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 148ef2d23e16b9e0df83b14e98526736
Webpacker
=========

このガイドでは、Webpackerをインストールして使用する方法について説明します。Webpackerは、RailsアプリケーションのクライアントサイドのJavaScript、CSS、およびその他のアセットをパッケージ化するためのものですが、[Webpackerは廃止されました](https://github.com/rails/webpacker#webpacker-has-been-retired-)ので注意してください。

このガイドを読み終えると、以下のことがわかります。

* Webpackerの役割とSprocketsとの違い
* Webpackerのインストール方法とフレームワークとの統合方法
* JavaScriptアセットにWebpackerを使用する方法
* CSSアセットにWebpackerを使用する方法
* 静的アセットにWebpackerを使用する方法
* Webpackerを使用したサイトのデプロイ方法
* エンジンやDockerコンテナなど、別のRailsコンテキストでWebpackerを使用する方法

-------------------------------------------------- ------------

Webpackerとは何ですか？
------------------

Webpackerは、[webpack](https://webpack.js.org)ビルドシステムをラップしたRailsのラッパーであり、標準のwebpack設定と合理的なデフォルトを提供します。

### Webpackとは何ですか？

webpack、または他のフロントエンドビルドシステムの目的は、開発者にとって便利な方法でフロントエンドコードを記述し、ブラウザにとって便利な方法でそのコードをパッケージ化することです。webpackを使用すると、JavaScript、CSS、画像やフォントなどの静的アセットを管理できます。webpackを使用すると、コードを記述し、アプリケーション内の他のコードを参照し、コードを変換し、コードを簡単にダウンロード可能なパックに結合することができます。

詳細については、[webpackのドキュメント](https://webpack.js.org)を参照してください。

### WebpackerはSprocketsとどう違うのですか？

RailsにはSprocketsというアセットパッケージングツールも同梱されており、その機能はWebpackerと重複しています。両方のツールはJavaScriptをブラウザフレンドリーなファイルにコンパイルし、本番環境ではそれらを最小化してフィンガープリントします。開発環境では、SprocketsとWebpackerの両方を使用してファイルを逐次的に変更できます。

RailsにはSprocketsが同梱されており、比較的簡単に統合できます。特に、コードはRubyのgemを介してSprocketsに追加することができます。ただし、webpackはより現代的なJavaScriptツールやNPMパッケージとの統合に優れており、より幅広い統合範囲を提供します。新しいRailsアプリケーションは、JavaScriptにwebpackを使用し、CSSにSprocketsを使用するように設定されていますが、webpackでもCSSを使用することができます。

NPMパッケージを使用したい場合や、最新のJavaScriptの機能やツールにアクセスしたい場合は、新しいプロジェクトではSprocketsの代わりにWebpackerを選択する必要があります。移行にコストがかかる可能性がある既存のアプリケーションや、Gemを使用して統合したい場合、またはパッケージ化するコードが非常に少量の場合は、Webpackerの代わりにSprocketsを選択する必要があります。

Sprocketsに詳しい場合は、次のガイドが参考になるかもしれません。ただし、各ツールには若干異なる構造があり、コンセプトは直接対応しないことに注意してください。

| タスク | Sprockets | Webpacker |
|------------------|----------------------|-------------------|
| JavaScriptを追加 |javascript_include_tag|javascript_pack_tag|
| CSSを追加 |stylesheet_link_tag|stylesheet_pack_tag|
| 画像へのリンク |image_url|image_pack_tag|
| アセットへのリンク |asset_url|asset_pack_tag|
| スクリプトの要求 |//= require|importまたはrequire|

Webpackerのインストール
--------------------

Webpackerを使用するには、バージョン1.x以上のYarnパッケージマネージャーをインストールし、バージョン10.13.0以上のNode.jsをインストールする必要があります。

注意：WebpackerはNPMとYarnに依存しています。NPMは、Node.jsおよびブラウザのランタイム用のオープンソースJavaScriptプロジェクトを公開およびダウンロードするための主要なリポジトリであり、Rubyのgemのrubygems.orgに類似しています。 Yarnは、JavaScriptの依存関係のインストールと管理を可能にするコマンドラインユーティリティであり、RubyのBundlerと同様の機能を提供します。

新しいプロジェクトにWebpackerを含めるには、`rails new`コマンドに`--webpack`を追加します。既存のプロジェクトにWebpackerを追加するには、プロジェクトの`Gemfile`に`webpacker`ジェムを追加し、`bundle install`を実行し、その後`bin/rails webpacker:install`を実行します。

Webpackerのインストールにより、次のローカルファイルが作成されます。

| ファイル | 場所 | 説明 |
|------------------------|------------------------|----------------------------------------------------------------------------------------------------|
| JavaScriptフォルダ | `app/javascript` | フロントエンドソースの場所 |
| Webpackerの設定 | `config/webpacker.yml` | Webpackerジェムの設定 |
| Babelの設定 | `babel.config.js` | [Babel](https://babeljs.io) JavaScriptコンパイラの設定 |
| PostCSSの設定 | `postcss.config.js` | [PostCSS](https://postcss.org) CSSポストプロセッサの設定 |
| Browserlist | `.browserslistrc` | [Browserlist](https://github.com/browserslist/browserslist)は、ターゲットブラウザの設定を管理します |

インストールでは、`yarn`パッケージマネージャーが呼び出され、基本的なパッケージのセットがリストアップされた`package.json`ファイルが作成され、これらの依存関係をインストールするためにYarnが使用されます。

使用法
-----

### JavaScriptのためのWebpackerの使用

Webpackerがインストールされている場合、`app/javascript/packs`ディレクトリにある任意のJavaScriptファイルは、デフォルトで独自のパックファイルにコンパイルされます。
`app/javascript/packs/application.js`というファイルがある場合、Webpackerは`application`というパックを作成し、コード`<%= javascript_pack_tag "application" %>`を使用してRailsアプリケーションに追加できます。これにより、開発中に`application.js`ファイルが変更されるたびに、Railsはそのパックを使用するページをロードするたびに再コンパイルします。通常、実際の`packs`ディレクトリ内のファイルは、他のファイルを主にロードするマニフェストですが、任意のJavaScriptコードも含めることができます。

Webpackerによって作成されるデフォルトのパックは、プロジェクトに含まれている場合にのみ、RailsのデフォルトのJavaScriptパッケージにリンクします。

```javascript
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

これらのパッケージを使用するには、これらのパッケージを必要とするパックを含める必要があります。

`app/javascript/packs`ディレクトリには、webpackのエントリーファイルのみを配置する必要があります。Webpackは各エントリーポイントごとに別々の依存関係グラフを作成するため、多数のパックがあるとコンパイルのオーバーヘッドが増加します。その他のアセットソースコードはこのディレクトリの外に配置する必要がありますが、Webpackerはソースコードの構造について制限を設けたり、提案を行ったりしません。以下に例を示します。

```sh
app/javascript:
  ├── packs:
  │   # ここにはwebpackのエントリーファイルのみ
  │   └── application.js
  │   └── application.css
  └── src:
  │   └── my_component.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

通常、パックファイル自体は、必要なファイルを`import`または`require`してロードし、初期化を行う場合もあります。

これらのディレクトリを変更する場合は、`config/webpacker.yml`ファイルで`source_path`（デフォルトは`app/javascript`）と`source_entry_path`（デフォルトは`packs`）を調整できます。

ソースファイル内では、`import`ステートメントはインポートを行っているファイルを基準に解決されます。つまり、`import Bar from "./foo"`は、現在のファイルと同じディレクトリにある`foo.js`ファイルを見つけます。一方、`import Bar from "../src/foo"`は、兄弟ディレクトリにある`src`という名前のディレクトリ内のファイルを見つけます。

### CSSのためのWebpackerの使用

デフォルトでは、WebpackerはPostCSSプロセッサを使用してCSSとSCSSをサポートしています。

パックにCSSコードを含めるには、まずCSSファイルをトップレベルのパックファイルに含めます。つまり、CSSのトップレベルマニフェストが`app/javascript/styles/styles.scss`にある場合、`import styles/styles`でインポートします。これにより、WebpackにCSSファイルをダウンロードに含めるように指示します。実際にページにロードするには、ビューに`<%= stylesheet_pack_tag "application" %>`を含めます。ここで、`application`は使用しているパック名と同じです。

CSSフレームワークを使用している場合は、`yarn`を使用してフレームワークをNPMモジュールとして読み込むための手順に従って追加できます。通常は`yarn add <framework>`です。フレームワークのインポート方法に関する指示があるはずです。

### 静的アセットのためのWebpackerの使用

デフォルトのWebpackerの[設定](https://github.com/rails/webpacker/blob/master/lib/install/config/webpacker.yml#L21)は、静的アセットに対してそのまま機能するはずです。設定には、いくつかの画像およびフォントファイル形式の拡張子が含まれており、webpackがそれらを生成された`manifest.json`ファイルに含めることができます。

Webpackを使用すると、静的アセットをJavaScriptファイル内で直接インポートできます。インポートされた値はアセットへのURLを表します。例えば：

```javascript
import myImageUrl from '../images/my-image.jpg'

// ...
let myImage = new Image();
myImage.src = myImageUrl;
myImage.alt = "I'm a Webpacker-bundled image";
document.body.appendChild(myImage);
```

Webpackerの静的アセットをRailsのビューから参照する場合は、WebpackerでバンドルされたJavaScriptファイルから明示的にアセットを要求する必要があります。Sprocketsとは異なり、Webpackerはデフォルトでは静的アセットをインポートしません。デフォルトの`app/javascript/packs/application.js`ファイルには、指定されたディレクトリからファイルをインポートするためのテンプレートがあります。静的ファイルを持つディレクトリごとにコメント解除することができます。ディレクトリは`app/javascript`を基準にしています。テンプレートでは`images`ディレクトリを使用していますが、`app/javascript`内の任意のディレクトリを使用できます。

```javascript
const images = require.context("../images", true)
const imagePath = name => images(name, true)
```

静的アセットは`public/packs/media`の下のディレクトリに出力されます。例えば、`app/javascript/images/my-image.jpg`にあるイメージは、`public/packs/media/images/my-image-abcd1234.jpg`に出力されます。このイメージのためにRailsのビューで画像タグをレンダリングするには、`image_pack_tag 'media/images/my-image.jpg'`を使用します。

WebpackerのActionViewヘルパーは、次の表に示すように、アセットパイプラインのヘルパーに対応しています。
|ActionViewヘルパー|Webpackerヘルパー|
|------------------|------------------|
|favicon_link_tag  |favicon_pack_tag  |
|image_tag         |image_pack_tag    |

また、ジェネリックヘルパーの`asset_pack_path`は、ファイルのローカルな場所を受け取り、Railsのビューで使用するためのWebpackerの場所を返します。

また、`app/javascript`内のCSSファイルから直接ファイルを参照することで、画像にアクセスすることもできます。

### RailsエンジンでのWebpacker

Webpackerバージョン6以降、Webpackerは「エンジンに対応していない」ため、Sprocketsと同様の機能をRailsエンジン内で使用する場合には、Webpackerは機能のパリティを持っていません。

Webpackerを使用する消費者をサポートするRailsエンジンのGemの作者は、Gem自体に加えてフロントエンドのアセットをNPMパッケージとして配布し、ホストアプリケーションがどのように統合すべきかを示すための手順（またはインストーラー）を提供することが推奨されています。このアプローチの良い例は、[Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms)です。

### ホットモジュールリプレースメント（HMR）

Webpackerは、webpack-dev-serverを使用してHMRをサポートしており、`webpacker.yml`内の`dev_server/hmr`オプションを設定することで切り替えることができます。

詳細については、[webpackのDevServerのドキュメント](https://webpack.js.org/configuration/dev-server/#devserver-hot)を参照してください。

ReactでHMRをサポートするには、react-hot-loaderを追加する必要があります。[React Hot Loaderの「はじめに」ガイド](https://gaearon.github.io/react-hot-loader/getstarted/)を参照してください。

スタイルシートに対してwebpack-dev-serverを実行していない場合は、HMRを無効にすることを忘れないでください。そうしないと、「not found error」が発生します。

異なる環境でのWebpacker
-----------------------------------

Webpackerには、デフォルトで`development`、`test`、`production`の3つの環境があります。`webpacker.yml`ファイルに追加の環境設定を追加し、各環境ごとに異なるデフォルトを設定することができます。Webpackerは、追加の環境設定のために`config/webpack/<environment>.js`ファイルも読み込みます。

## 開発中のWebpackerの実行

Webpackerには、開発中に実行するための2つのbinstubファイルが付属しています：`./bin/webpack`と`./bin/webpack-dev-server`です。これらは、標準の`webpack.js`と`webpack-dev-server.js`実行可能ファイルの薄いラッパーであり、環境に基づいて正しい設定ファイルと環境変数が読み込まれるようにします。

デフォルトでは、Webpackerは開発中にRailsのページが読み込まれると自動的にコンパイルされます。つまり、別のプロセスを実行する必要はなく、コンパイルエラーは標準のRailsログに記録されます。`config/webpacker.yml`ファイルで`compile: false`に変更することで、これを変更することができます。`bin/webpack`を実行すると、パックのコンパイルが強制されます。

ライブコードリローディングを使用したい場合や、オンデマンドのコンパイルが遅すぎるほどのJavaScriptがある場合は、`./bin/webpack-dev-server`または`ruby ./bin/webpack-dev-server`を実行する必要があります。このプロセスは、`app/javascript/packs/*.js`ファイルの変更を監視し、自動的に再コンパイルしてブラウザをリロードします。

Windowsユーザーは、これらのコマンドを`bundle exec rails server`とは別のターミナルで実行する必要があります。

この開発サーバーを起動すると、Webpackerは自動的にすべてのwebpackアセットリクエストをこのサーバーにプロキシします。サーバーを停止すると、オンデマンドのコンパイルに戻ります。

[Webpackerのドキュメント](https://github.com/rails/webpacker)には、`webpack-dev-server`を制御するために使用できる環境変数に関する情報が記載されています。[rails/webpackerのドキュメントのwebpack-dev-serverの使用方法](https://github.com/rails/webpacker#development)に関する追加の注意事項を参照してください。

### Webpackerのデプロイ

Webpackerは、`bin/rails assets:precompile`タスクに`webpacker:compile`タスクを追加するため、`assets:precompile`を使用していた既存のデプロイパイプラインは動作するはずです。コンパイルタスクはパックをコンパイルし、`public/packs`に配置します。

その他のドキュメント
------------------------

Webpackerを人気のあるフレームワークと使用するなど、詳細なトピックについては、[Webpackerのドキュメント](https://github.com/rails/webpacker)を参照してください。
