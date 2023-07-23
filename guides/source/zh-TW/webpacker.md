Webpacker
=========

本指南將向您展示如何安裝和使用Webpacker來打包JavaScript、CSS和其他用於Rails應用程序的客戶端的資源，但請注意[Webpacker已經被停用](https://github.com/rails/webpacker#webpacker-has-been-retired-)。

閱讀本指南後，您將了解：

* Webpacker是什麼，以及它與Sprockets的區別。
* 如何安裝Webpacker並將其集成到您選擇的框架中。
* 如何使用Webpacker處理JavaScript資源。
* 如何使用Webpacker處理CSS資源。
* 如何使用Webpacker處理靜態資源。
* 如何部署使用Webpacker的網站。
* 如何在其他Rails上下文中使用Webpacker，例如引擎或Docker容器。

--------------------------------------------------------------

什麼是Webpacker？
------------------

Webpacker是一個封裝了[webpack](https://webpack.js.org)構建系統的Rails包裝器，它提供了一個標準的webpack配置和合理的默認值。

### 什麼是Webpack？

webpack或任何前端構建系統的目標是允許您以對開發人員方便的方式編寫前端代碼，然後以對瀏覽器方便的方式打包該代碼。使用webpack，您可以管理JavaScript、CSS和靜態資源，如圖像或字體。Webpack將允許您編寫代碼、引用應用程序中的其他代碼、轉換代碼並將代碼組合成易於下載的包。

有關詳細信息，請參閱[webpack文檔](https://webpack.js.org)。

### Webpacker與Sprockets有何不同？

Rails還附帶了Sprockets，這是一個資源打包工具，其功能與Webpacker重疊。這兩個工具都會將您的JavaScript編譯為瀏覽器友好的文件，並在生產環境中對其進行最小化和指紋處理。在開發環境中，Sprockets和Webpacker允許您逐步更改文件。

Sprockets是專為Rails設計的，相對較容易集成。特別是，可以通過Ruby gem將代碼添加到Sprockets中。然而，webpack更擅長與更現代的JavaScript工具和NPM包集成，並允許更廣泛的集成。新的Rails應用程序配置為使用webpack處理JavaScript和Sprockets處理CSS，儘管您也可以使用webpack處理CSS。

如果您想使用NPM包和/或想要使用最新的JavaScript功能和工具，則應該在新項目中選擇Webpacker而不是Sprockets。如果您要對遷移成本較高的舊應用程序進行集成，或者如果您只有很少的代碼需要打包，則應該選擇Sprockets而不是Webpacker。

如果您熟悉Sprockets，下面的指南可能會給您一些轉換的想法。請注意，每個工具的結構略有不同，這些概念並不直接對應。

|任務              | Sprockets            | Webpacker         |
|------------------|----------------------|-------------------|
|添加JavaScript |javascript_include_tag|javascript_pack_tag|
|添加CSS        |stylesheet_link_tag   |stylesheet_pack_tag|
|鏈接到圖像  |image_url             |image_pack_tag     |
|鏈接到資源  |asset_url             |asset_pack_tag     |
|引用腳本  |//= require           |import or require  |

安裝Webpacker
--------------------

要使用Webpacker，您必須安裝Yarn包管理器，版本為1.x或更高版本，並且必須安裝Node.js，版本為10.13.0或更高版本。

注意：Webpacker依賴於NPM和Yarn。NPM是Node.js和瀏覽器運行時的主要開源JavaScript項目發布和下載存儲庫，類似於Ruby的rubygems.org。Yarn是一個命令行工具，可以像Bundler一樣安裝和管理JavaScript依賴項。

要在新項目中包含Webpacker，請將`--webpack`添加到`rails new`命令中。要將Webpacker添加到現有項目中，請將`webpacker` gem添加到項目的`Gemfile`中，運行`bundle install`，然後運行`bin/rails webpacker:install`。

安裝Webpacker會創建以下本地文件：

|文件                    |位置                |說明                                                                                         |
|------------------------|------------------------|----------------------------------------------------------------------------------------------------|
|JavaScript資料夾       | `app/javascript`       |前端源代碼的位置                                                                   |
|Webpacker配置文件 | `config/webpacker.yml` |配置Webpacker gem                                                                         |
|Babel配置文件     | `babel.config.js`      |[Babel](https://babeljs.io) JavaScript編譯器的配置                               |
|PostCSS配置文件   | `postcss.config.js`    |[PostCSS](https://postcss.org) CSS後處理器的配置                             |
|Browserlist             | `.browserslistrc`      |[Browserlist](https://github.com/browserslist/browserslist)管理目標瀏覽器的配置   |


安裝還會調用`yarn`包管理器，創建一個帶有基本套件列表的`package.json`文件，並使用Yarn安裝這些依賴項。

使用方法
-----

### 使用Webpacker處理JavaScript

安裝Webpacker後，`app/javascript/packs`目錄中的任何JavaScript文件將默認編譯為自己的pack文件。
如果您有一個名為`app/javascript/packs/application.js`的文件，Webpacker將創建一個名為`application`的pack，您可以使用代碼`<%= javascript_pack_tag "application" %>`將其添加到您的Rails應用程序中。這樣一來，在開發中，當`application.js`文件更改並且您加載使用該pack的頁面時，Rails將重新編譯該文件。通常，實際`packs`目錄中的文件將是一個主要加載其他文件的清單，但它也可以包含任意的JavaScript代碼。

Webpacker為您創建的默認pack將鏈接到Rails的默認JavaScript包（如果它們已包含在項目中）：

```javascript
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

您需要包含一個需要這些包的pack才能在Rails應用程序中使用它們。

需要注意的是，只有webpack入口文件應該放在`app/javascript/packs`目錄中；Webpack將為每個入口點創建一個獨立的依賴圖，因此大量的pack將增加編譯開銷。您的其他資源代碼應該放在此目錄之外，儘管Webpacker不對如何結構化源代碼提出任何限制或建議。這是一個示例：

```sh
app/javascript:
  ├── packs:
  │   # 只有webpack入口文件在這裡
  │   └── application.js
  │   └── application.css
  └── src:
  │   └── my_component.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

通常，pack文件本身主要是一個使用`import`或`require`來加載必要文件的清單，並且還可以進行一些初始化操作。

如果您想更改這些目錄，可以在`config/webpacker.yml`文件中調整`source_path`（默認為`app/javascript`）和`source_entry_path`（默認為`packs`）。

在源文件中，`import`語句是相對於執行導入的文件解析的，因此`import Bar from "./foo"`將在當前文件所在目錄中找到一個名為`foo.js`的文件，而`import Bar from "../src/foo"`將在兄弟目錄中的名為`src`的目錄中找到一個文件。

### 使用Webpacker進行CSS

Webpacker支持使用PostCSS處理器的CSS和SCSS。

要在packs中包含CSS代碼，首先在頂級pack文件中包含CSS文件，就像它是一個JavaScript文件一樣。因此，如果您的CSS頂級清單位於`app/javascript/styles/styles.scss`，您可以使用`import styles/styles`將其導入。這告訴Webpack將您的CSS文件包含在下載中。要在頁面中實際加載它，請在視圖中包含`<%= stylesheet_pack_tag "application" %>`，其中的`application`是您使用的相同pack名稱。

如果您使用的是CSS框架，您可以按照使用`yarn`將該框架作為NPM模塊加載的說明將其添加到Webpacker中，通常是`yarn add <framework>`。該框架應該有關於將其導入到CSS或SCSS文件中的說明。

### 使用Webpacker進行靜態資源

默認的Webpacker配置應該可以直接用於靜態資源。
該配置包括多個圖像和字體文件格式擴展名，允許Webpack將它們包含在生成的`manifest.json`文件中。

使用Webpack，可以直接在JavaScript文件中導入靜態資源。導入的值表示資源的URL。例如：

```javascript
import myImageUrl from '../images/my-image.jpg'

// ...
let myImage = new Image();
myImage.src = myImageUrl;
myImage.alt = "I'm a Webpacker-bundled image";
document.body.appendChild(myImage);
```

如果您需要從Rails視圖引用Webpacker靜態資源，則需要從Webpacker打包的JavaScript文件中明確地引用這些資源。與Sprockets不同，Webpacker不會默認導入您的靜態資源。默認的`app/javascript/packs/application.js`文件有一個從給定目錄導入文件的模板，您可以取消對每個希望具有靜態文件的目錄的注釋。這些目錄是相對於`app/javascript`的。模板使用目錄`images`，但您可以使用`app/javascript`中的任何目錄：

```javascript
const images = require.context("../images", true)
const imagePath = name => images(name, true)
```

靜態資源將輸出到`public/packs/media`目錄下。例如，位於`app/javascript/images/my-image.jpg`並且在導入時的位置是`public/packs/media/images/my-image-abcd1234.jpg`的圖像將被輸出。要在Rails視圖中為此圖像渲染圖像標籤，請使用`image_pack_tag 'media/images/my-image.jpg`。

Webpacker的ActionView助手與asset pipeline助手對應如下表所示：
|ActionView 助手 | Webpacker 助手 |
|------------------|------------------|
|favicon_link_tag  |favicon_pack_tag  |
|image_tag         |image_pack_tag    |

此外，通用助手 `asset_pack_path` 接受文件的本地位置，並返回其在 Rails 視圖中使用的 Webpacker 位置。

您也可以通過在 `app/javascript` 中的 CSS 文件中直接引用文件來訪問圖像。

### 在 Rails 引擎中使用 Webpacker

從 Webpacker 6 版本開始，Webpacker 不再「知道引擎」，這意味著在使用 Rails 引擎時，Webpacker 在功能上不如 Sprockets。

希望支援使用 Webpacker 的 Rails 引擎的 Gem 作者被鼓勵將前端資源作為 NPM 套件發布，並在 Gem 自身之外提供說明（或安裝程式），以示範主應用程式應如何整合。這種方法的一個很好的例子是 [Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms)。

### 熱模組替換（HMR）

Webpacker 預設支援使用 webpack-dev-server 的 HMR，您可以通過在 `webpacker.yml` 中設置 dev_server/hmr 選項來切換它。

更多資訊，請參閱 [webpack 的 DevServer 文件](https://webpack.js.org/configuration/dev-server/#devserver-hot)。

要支援 React 的 HMR，您需要添加 react-hot-loader。請參閱 [React Hot Loader 的「入門指南」](https://gaearon.github.io/react-hot-loader/getstarted/)。

如果您沒有運行 webpack-dev-server，請不要忘記禁用 HMR；否則，樣式表將會出現「找不到錯誤」。

不同環境中的 Webpacker
-----------------------

Webpacker 預設有三個環境：`development`、`test` 和 `production`。您可以在 `webpacker.yml` 文件中添加其他環境配置，並為每個環境設置不同的默認值。Webpacker 還會加載 `config/webpack/<environment>.js` 文件以進行其他環境設置。

## 在開發中運行 Webpacker

Webpacker 提供了兩個用於開發的 binstub 文件：`./bin/webpack` 和 `./bin/webpack-dev-server`。它們都是對標準 `webpack.js` 和 `webpack-dev-server.js` 可執行文件的薄包裝，並確保根據您的環境加載正確的配置文件和環境變量。

預設情況下，Webpacker 在開發中根據需要自動編譯，當一個 Rails 頁面加載時。這意味著您不需要運行任何單獨的進程，並且編譯錯誤將被記錄到標準的 Rails 日誌中。您可以通過在 `config/webpacker.yml` 文件中更改為 `compile: false` 來改變這一默認行為。運行 `bin/webpack` 將強制編譯您的 packs。

如果您想要使用實時代碼重新加載，或者 JavaScript 代碼量足夠大，以至於按需編譯太慢，您需要運行 `./bin/webpack-dev-server` 或 `ruby ./bin/webpack-dev-server`。此進程將監視 `app/javascript/packs/*.js` 文件的變化，並自動重新編譯並重新載入瀏覽器。

Windows 用戶需要在與 `bundle exec rails server` 不同的終端中運行這些命令。

一旦您啟動了這個開發服務器，Webpacker 將自動開始將所有 webpack 資源請求代理到此服務器。當您停止服務器時，它將恢復到按需編譯。

[Webpacker 文件](https://github.com/rails/webpacker) 提供了您可以用來控制 `webpack-dev-server` 的環境變量的資訊。請參閱 [rails/webpacker 文件中有關 webpack-dev-server 用法的其他注意事項](https://github.com/rails/webpacker#development)。

### 部署 Webpacker

Webpacker 將 `webpacker:compile` 任務添加到 `bin/rails assets:precompile` 任務中，因此任何使用 `assets:precompile` 的現有部署流程都應該可以正常工作。編譯任務將編譯 packs 並將它們放置在 `public/packs` 中。

其他文件
--------

有關高級主題的更多資訊，例如如何使用 Webpacker 與流行框架，請參閱 [Webpacker 文件](https://github.com/rails/webpacker)。
