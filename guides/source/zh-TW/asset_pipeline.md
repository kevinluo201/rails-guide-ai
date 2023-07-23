**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0f0bbb2fd67f1843d30e360c15c03c61
資產管道
==================

本指南介紹了資產管道。

閱讀本指南後，您將了解以下內容：

* 資產管道是什麼以及它的功能。
* 如何正確組織應用程式的資產。
* 資產管道的好處。
* 如何將預處理器添加到管道中。
* 如何使用 gem 打包資產。

--------------------------------------------------------------------------------

什麼是資產管道？
---------------------------

資產管道提供了一個處理 JavaScript 和 CSS 資產交付的框架。這是通過利用 HTTP/2 等技術和串聯和最小化等技巧來實現的。最後，它允許您的應用程式自動與其他 gem 的資產結合。

資產管道由 [importmap-rails](https://github.com/rails/importmap-rails)、[sprockets](https://github.com/rails/sprockets) 和 [sprockets-rails](https://github.com/rails/sprockets-rails) gem 實現，並且默認情況下啟用。您可以在創建新應用程式時禁用它，只需傳遞 `--skip-asset-pipeline` 選項。

```bash
$ rails new appname --skip-asset-pipeline
```

注意：本指南專注於使用只有 `sprockets` 用於 CSS 和 `importmap-rails` 用於 JavaScript 處理的默認資產管道。這兩者的主要限制是它們不支援轉譯，因此您無法使用像 `Babel`、`Typescript`、`Sass`、`React JSX 格式` 或 `TailwindCSS` 等功能。如果您需要對 JavaScript/CSS 進行轉譯，我們建議您閱讀 [替代庫部分](#alternative-libraries)。

## 主要功能

資產管道的第一個功能是將 SHA256 指紋插入到每個檔案名稱中，以便網頁瀏覽器和 CDN 緩存該檔案。當您更改檔案內容時，此指紋會自動更新，從而使緩存無效。

資產管道的第二個功能是在提供 JavaScript 檔案時使用 [import maps](https://github.com/WICG/import-maps)。這使您可以使用針對 ES 模組（ESM）製作的 JavaScript 函式庫來構建現代應用程式，而無需進行轉譯和打包。因此，**這消除了 Webpack、yarn、node 或 JavaScript 工具鏈的任何其他部分的需求**。

資產管道的第三個功能是將所有 CSS 檔案串聯到一個主要的 `.css` 檔案中，然後對其進行最小化或壓縮。正如您稍後在本指南中了解的那樣，您可以自定義此策略以任何您喜歡的方式分組檔案。在生產環境中，Rails 會將 SHA256 指紋插入到每個檔案名稱中，以便網頁瀏覽器緩存該檔案。您可以通過更改此指紋來使緩存失效，每當您更改檔案內容時，這將自動發生。

資產管道的第四個功能是它允許使用一種更高級的語言來編寫 CSS 資產。

### 什麼是指紋和為什麼我應該關心？

指紋是一種技術，使檔案名稱依賴於檔案的內容。當檔案內容更改時，檔案名稱也會更改。對於靜態或不經常更改的內容，這提供了一種簡單的方法來判斷兩個版本的檔案是否相同，即使在不同的伺服器或部署日期上也是如此。

當檔案名稱是唯一的並基於其內容時，可以設置 HTTP 標頭以鼓勵各處的快取（無論是在 CDN、ISP、網絡設備還是網頁瀏覽器中）保留其自己的內容副本。當內容更新時，指紋將更改。這將導致遠程客戶端請求新的內容副本。這通常被稱為 _緩存破壞_。

Sprockets 用於指紋的技術是將內容的哈希插入到名稱中，通常是在末尾。例如，CSS 檔案 `global.css`

```
global-908e25f4bf641868d8683022a5b62f54.css
```

這是 Rails 資產管道採用的策略。

指紋在開發和生產環境中都默認啟用。您可以通過配置中的 [`config.assets.digest`][] 選項來啟用或禁用它。

### 什麼是 Import Maps 以及為什麼我應該關心？

Import Maps 允許您使用邏輯名稱將 JavaScript 模組導入到網頁瀏覽器中的版本化/摘要檔案中。因此，您可以使用針對 ES 模組（ESM）製作的 JavaScript 函式庫來構建現代 JavaScript 應用程式，而無需進行轉譯或打包。

使用此方法，您將發送許多小的 JavaScript 檔案，而不是一個大的 JavaScript 檔案。由於 HTTP/2 在初始傳輸期間不再帶來實質的性能懲罰，並且實際上由於更好的快取動態而在長期運行中提供了實質的好處。
如何使用Import Maps作為Javascript資源管道
-----------------------------

Import Maps是預設的Javascript處理器，生成import maps的邏輯由[`importmap-rails`](https://github.com/rails/importmap-rails) gem處理。

警告：Import Maps僅用於Javascript文件，無法用於CSS傳遞。請查看[Sprockets部分](#how-to-use-sprockets)以了解CSS。

您可以在Gem主頁上找到詳細的使用說明，但了解`importmap-rails`的基本原理很重要。

### 工作原理

Import Maps本質上是對所謂的“裸模塊標識符”進行字符串替換。它們允許您標準化JavaScript模塊導入的名稱。

例如，如果沒有import map，以下import定義將無法工作：

```javascript
import React from "react"
```

您必須像這樣定義它才能使其工作：

```javascript
import React from "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

這就是import map的作用，我們將`react`名稱定義為`https://ga.jspm.io/npm:react@17.0.2/index.js`地址。有了這樣的信息，我們的瀏覽器接受簡化的`import React from "react"`定義。將import map視為庫源地址的別名。

### 使用方法

使用`importmap-rails`創建importmap配置文件，將庫路徑固定到一個名稱上：

```ruby
# config/importmap.rb
pin "application"
pin "react", to: "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

所有配置的import map都應該通過添加`<%= javascript_importmap_tags %>`將其附加到應用程序的`<head>`元素中。`javascript_importmap_tags`在`head`元素中呈現一堆腳本：

- 包含所有配置的import map的JSON：

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

- [`Es-module-shims`](https://github.com/guybedford/es-module-shims)作為polyfill，確保舊版瀏覽器支持`import maps`：

```html
<script src="/assets/es-module-shims.min" async="async" data-turbo-track="reload"></script>
```

- 從`app/javascript/application.js`加載JavaScript的入口點：

```html
<script type="module">import "application"</script>
```

### 通過JavaScript CDNs使用npm包

您可以使用作為`importmap-rails`安裝的一部分添加的`./bin/importmap`命令來固定、取消固定或更新import map中的npm包。該binstub使用[`JSPM.org`](https://jspm.org/)。

它的工作方式如下：

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

如您所見，兩個包react和react-dom通過jspm默認解析為四個依賴項。

現在，您可以像使用其他模塊一樣在`application.js`入口點中使用它們：

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

您還可以指定要固定的特定版本：

```sh
./bin/importmap pin react@17.0.1
Pinning "react" to https://ga.jspm.io/npm:react@17.0.1/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

或者甚至刪除固定：

```sh
./bin/importmap unpin react
Unpinning "react"
Unpinning "object-assign"
```

您可以控制包的環境，對於具有單獨的“生產”（默認）和“開發”構建的包：

```sh
./bin/importmap pin react --env development
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/dev.index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

在固定時，您還可以選擇另一個支持的CDN提供程序，例如[`unpkg`](https://unpkg.com/)或[`jsdelivr`](https://www.jsdelivr.com/)（默認為[`jspm`](https://jspm.org/)）：

```sh
./bin/importmap pin react --from jsdelivr
Pinning "react" to https://cdn.jsdelivr.net/npm/react@17.0.2/index.js
```

請記住，如果您將固定從一個提供程序切換到另一個提供程序，您可能需要清理第一個提供程序添加的第二個提供程序不使用的依賴項。

運行`./bin/importmap`以查看所有選項。

請注意，此命令僅是將邏輯包名解析為CDN URL的便利包裝器。您也可以自己查找CDN URL，然後固定它們。例如，如果您想使用Skypack來使用React，您可以將以下內容添加到`config/importmap.rb`中：

```ruby
pin "react", to: "https://cdn.skypack.dev/react"
```

### 預加載固定模塊

為了避免瀏覽器在可以到達最深層嵌套導入之前必須加載一個文件的瀑布效應，importmap-rails支持[modulepreload鏈接](https://developers.google.com/web/updates/2017/12/modulepreload)。可以通過將`preload: true`附加到固定中來預加載固定模塊。

對於在整個應用程序中使用的庫或框架，預加載它們是一個好主意，因為這將告訴瀏覽器更早地下載它們。

示例：

```ruby
# config/importmap.rb
pin "@github/hotkey", to: "https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js", preload: true
pin "md5", to: "https://cdn.jsdelivr.net/npm/md5@2.3.0/md5.js"

# app/views/layouts/application.html.erb
<%= javascript_importmap_tags %>

# 在設置importmap之前，將包含以下鏈接：
<link rel="modulepreload" href="https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js">
...
```
注意：有關最新的文件，請參考 [`importmap-rails`](https://github.com/rails/importmap-rails) 存儲庫。

如何使用 Sprockets
-----------------------------

將應用程序資源公開到網絡的一種簡單方法是將它們存儲在 `public` 文件夾的子目錄中，例如 `images` 和 `stylesheets`。手動這樣做會很困難，因為大多數現代網絡應用程序需要以特定方式處理資源，例如壓縮和添加指紋。

Sprockets 設計用於自動預處理存儲在配置目錄中的資源，並在處理後將它們公開在 `public/assets` 文件夾中，包括指紋、壓縮、源映射生成和其他可配置功能。

資源仍然可以放置在 `public` 層級結構中。當 [`config.public_file_server.enabled`][] 設置為 true 時，`public` 下的任何資源都將由應用程序或 Web 服務器作為靜態文件提供。您必須為需要在提供之前進行某些預處理的文件定義 `manifest.js` 指令。

在生產環境中，Rails 默認將這些文件預編譯到 `public/assets`。然後，Web 服務器將這些預編譯的副本作為靜態資源提供。在生產環境中，`app/assets` 中的文件永遠不會直接提供。

### Manifest 文件和指令

使用 Sprockets 編譯資源時，Sprockets 需要決定要編譯的頂級目標，通常是 `application.css` 和圖像。頂級目標在 Sprockets 的 `manifest.js` 文件中定義，默認情況下如下所示：

```js
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_tree ../../javascript .js
//= link_tree ../../../vendor/javascript .js
```

它包含 _指令_ - 指示 Sprockets 要求哪些文件以構建單個 CSS 或 JavaScript 文件。

這意味著它將包含在 `./app/assets/images` 目錄或任何子目錄中找到的所有文件的內容，以及在 `./app/javascript` 或 `./vendor/javascript` 中直接識別為 JS 的任何文件。

它將加載 `./app/assets/stylesheets` 目錄中的任何 CSS（不包括子目錄）。假設您在 `./app/assets/stylesheets` 文件夾中有 `application.css` 和 `marketing.css` 文件，它將允許您使用 `<%= stylesheet_link_tag "application" %>` 或 `<%= stylesheet_link_tag "marketing" %>` 從視圖中加載這些樣式表。

您可能會注意到，我們的 JavaScript 文件默認情況下不是從 `assets` 目錄加載的，這是因為 `./app/javascript` 是 `importmap-rails` gem 的默認入口點，而 `vendor` 文件夾是下載的 JS 包的存放位置。

在 `manifest.js` 中，您還可以使用 `link` 指令來加載特定文件而不是整個目錄。`link` 指令需要提供明確的文件擴展名。

Sprockets 加載指定的文件，如果需要，對其進行處理，將它們連接成一個單一文件，然後壓縮它們（基於 `config.assets.css_compressor` 或 `config.assets.js_compressor` 的值）。壓縮可以減小文件大小，使瀏覽器能夠更快地下載文件。

### 控制器特定的資源

當您生成一個脚手架或控制器時，Rails 還會為該控制器生成一個層疊樣式表文件。此外，生成脚手架時，Rails 還會生成 `scaffolds.css` 文件。

例如，如果您生成一個 `ProjectsController`，Rails 還會在 `app/assets/stylesheets/projects.css` 中添加一個新文件。默認情況下，這些文件將立即可以在應用程序中使用，使用 `manifest.js` 文件中的 `link_directory` 指令。

您還可以選擇僅在相應的控制器中包含特定於控制器的樣式表文件，使用以下代碼：

```html+erb
<%= stylesheet_link_tag params[:controller] %>
```

這樣做時，請確保您的 `application.css` 中沒有使用 `require_tree` 指令，因為這可能導致您的控制器特定資源被多次包含。

### 資源組織

Pipeline 資源可以放置在應用程序的三個位置之一：`app/assets`、`lib/assets` 或 `vendor/assets`。

* `app/assets` 用於應用程序擁有的資源，例如自定義圖像或樣式表。

* `app/javascript` 用於您的 JavaScript 代碼。

* `vendor/[assets|javascript]` 用於由外部實體擁有的資源，例如 CSS 框架或 JavaScript 庫。請記住，具有對其他由資源 Pipeline 處理的文件的引用的第三方代碼（圖像、樣式表等）需要重寫以使用像 `asset_path` 這樣的輔助方法。

其他位置可以在 `manifest.js` 文件中進行配置，請參考[Manifest 文件和指令](#manifest-files-and-directives)。

#### 搜索路徑

當從 manifest 或輔助方法引用文件時，Sprockets 會在 `manifest.js` 中指定的所有位置中搜索該文件。您可以通過在 Rails 控制台中檢查 [`Rails.application.config.assets.paths`](configuring.html#config-assets-paths) 來查看搜索路徑。
#### 使用索引文件作為文件夾的代理

Sprockets使用名為`index`（帶有相關擴展名）的文件來進行特殊用途。

例如，如果您有一個包含許多模塊的CSS庫，存儲在`lib/assets/stylesheets/library_name`中，則文件`lib/assets/stylesheets/library_name/index.css`用作此庫中所有文件的清單。此文件可以包含按順序列出的所有所需文件，或者一個簡單的`require_tree`指令。

這也有點類似於通過請求`/library_name`可以訪問`public/library_name/index.html`中的文件。這意味著您不能直接使用索引文件。

可以在`.css`文件中像這樣訪問整個庫：

```css
/* ...
*= require library_name
*/
```

這樣可以簡化維護工作，並通過在其他地方包含相關代碼來保持代碼整潔。

### 鏈接到資源的編碼

Sprockets不會添加任何新的方法來訪問您的資源 - 您仍然使用熟悉的`stylesheet_link_tag`：

```erb
<%= stylesheet_link_tag "application", media: "all" %>
```

如果使用預設包含在Rails中的[`turbo-rails`](https://github.com/hotwired/turbo-rails) gem，則需要包含`data-turbo-track`選項，這導致Turbo檢查資源是否已更新，如果是，則將其加載到頁面中：

```erb
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
```

在常規視圖中，您可以像這樣訪問`app/assets/images`目錄中的圖像：

```erb
<%= image_tag "rails.png" %>
```

只要在應用程序中啟用了pipeline（並且在當前環境上下文中未禁用），Sprockets就會提供此文件。如果在`public/assets/rails.png`存在文件，則由Web服務器提供。

或者，對於具有SHA256哈希的文件的請求（例如`public/assets/rails-f90d8a84c707a8dc923fca1ca1895ae8ed0a09237f6992015fef1e11be77c023.png`），處理方式相同。如何生成這些哈希在本指南的[在生產中](#在生產中)部分中有介紹。

如果需要，圖像也可以組織到子目錄中，然後可以通過在標籤中指定目錄名稱來訪問：

```erb
<%= image_tag "icons/rails.png" %>
```

警告：如果您正在預編譯資源（參見[在生產中](#在生產中)），並且鏈接到不存在的資源，則會在調用頁面中引發異常。這包括鏈接到空字符串。因此，在使用`image_tag`和其他輔助函數時要小心使用用戶提供的數據。

#### CSS和ERB

資源管道會自動評估ERB。這意味著如果您將`erb`擴展名添加到CSS資源中（例如，`application.css.erb`），則在CSS規則中可以使用`asset_path`等輔助函數：

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

這將寫入對特定資源的路徑。在此示例中，可以在資源加載路徑之一（例如`app/assets/images/image.png`）中有一個圖像，並在此處引用它。如果此圖像已經作為指紋文件存在於`public/assets`中，則引用該路徑。

如果要使用[data URI](https://en.wikipedia.org/wiki/Data_URI_scheme) - 將圖像數據直接嵌入CSS文件的方法 - 可以使用`asset_data_uri`輔助函數。

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

這將在CSS源碼中插入格式正確的data URI。

請注意，結尾標籤不能是`-%>`風格。

### 當找不到資源時引發錯誤

如果您使用的是sprockets-rails >= 3.2.0，則可以配置在執行資源查找時找不到資源時發生的情況。如果關閉了"asset fallback"，則在找不到資源時將引發錯誤。

```ruby
config.assets.unknown_asset_fallback = false
```

如果啟用了"asset fallback"，則在找不到資源時將輸出路徑，並且不會引發錯誤。默認情況下禁用"asset fallback"行為。

### 關閉指紋

您可以通過更新`config/environments/development.rb`來關閉指紋：

```ruby
config.assets.digest = false
```

當此選項為true時，將為資源URL生成指紋。

### 打開源映射

您可以通過更新`config/environments/development.rb`來打開源映射：

```ruby
config.assets.debug = true
```

當調試模式打開時，Sprockets將為每個資源生成一個源映射。這使您可以在瀏覽器的開發者工具中單獨調試每個文件。

資源在服務器啟動後的第一個請求上編譯並緩存。Sprockets設置了`must-revalidate`的Cache-Control HTTP標頭，以減少後續請求的開銷 - 在這些請求中，瀏覽器會收到304（未修改）的響應。
如果清單中的任何文件在請求之間發生變化，服務器將回應一個新的編譯文件。

在生產環境中
-------------

在生產環境中，Sprockets使用上面概述的指紋方案。默認情況下，Rails假設資源已經被預編譯並將由Web服務器作為靜態資源提供。

在預編譯階段，從編譯文件的內容生成SHA256，並將其插入到寫入磁盤的文件名中。這些帶有指紋的名稱由Rails助手在清單名稱的位置使用。

例如：

```erb
<%= stylesheet_link_tag "application" %>
```

生成類似於：

```html
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" rel="stylesheet" />
```

指紋行為由[`config.assets.digest`]初始化選項控制（默認為`true`）。

注意：在正常情況下，不應更改默認的`config.assets.digest`選項。如果文件名中沒有摘要，並且設置了遠程客戶端的遠期標題，則在其內容更改時，遠程客戶端將永遠不知道重新獲取文件。

### 預編譯資源

Rails附帶了一個命令來編譯資源清單和管道中的其他文件。

編譯後的資源寫入到[`config.assets.prefix`]指定的位置。默認情況下，這是`/assets`目錄。

您可以在部署期間在服務器上調用此命令，直接在服務器上創建編譯後的資源版本。有關在本地編譯的信息，請參閱下一節。

命令如下：

```bash
$ RAILS_ENV=production rails assets:precompile
```

這將將`config.assets.prefix`中指定的文件夾鏈接到`shared/assets`。如果您已經使用此共享文件夾，您需要編寫自己的部署命令。

重要的是，此文件夾在部署之間是共享的，以便對舊的編譯資源進行遠程緩存的頁面在緩存頁面的生命週期內仍然可用。

注意：始終指定以`.js`或`.css`結尾的預期編譯文件名。

該命令還生成一個`.sprockets-manifest-randomhex.json`（其中`randomhex`是一個16字節的隨機十六進制字符串），其中包含所有資源及其相應指紋的列表。這是Rails助手方法使用的，以避免將映射請求返回給Sprockets。典型的清單文件如下所示：

```json
{"files":{"application-<fingerprint>.js":{"logical_path":"application.js","mtime":"2016-12-23T20:12:03-05:00","size":412383,
"digest":"<fingerprint>","integrity":"sha256-<random-string>"}},
"assets":{"application.js":"application-<fingerprint>.js"}}
```

在您的應用程序中，清單中將列出更多的文件和資源，`<fingerprint>`和`<random-string>`也將被生成。

清單的默認位置是`config.assets.prefix`指定的位置的根目錄（默認為'/assets'）。

注意：如果在生產中缺少預編譯文件，您將收到一個`Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError`異常，指示缺少文件的名稱。

#### 遠期到期標題

預編譯的資源存在於文件系統上，並由Web服務器直接提供。它們默認情況下不具有遠期標題，因此要獲得指紋的好處，您需要更新服務器配置以添加這些標題。

對於Apache：

```apache
# Expires*指令需要啟用Apache模塊`mod_expires`。
<Location /assets/>
  # 當存在Last-Modified時，不建議使用ETag
  Header unset ETag
  FileETag None
  # RFC規定只緩存1年
  ExpiresActive On
  ExpiresDefault "access plus 1 year"
</Location>
```

對於NGINX：

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
}
```

### 本地編譯

有時，您可能不希望或無法在生產服務器上編譯資源。例如，您可能對生產文件系統的寫入訪問權限有限，或者您可能計劃經常部署而不對資源進行任何更改。

在這種情況下，您可以在推送到生產之前將一組最終編譯的生產就緒資源添加到源代碼庫中，以便預編譯它們不需要在每次部署時在生產服務器上單獨進行。

如上所述，您可以使用以下命令執行此步驟：

```bash
$ RAILS_ENV=production rails assets:precompile
```

請注意以下注意事項：

* 如果可用，將提供預編譯的資源 - 即使它們不再與原始（未編譯）資源匹配，_即使在開發服務器上也是如此_。

    為了確保開發服務器始終即時編譯資源（並且始終反映代碼的最新狀態），開發環境 _必須配置為將預編譯的資源保存在與生產不同的位置。_ 否則，任何為生產使用預編譯的資源將覆蓋開發中對它們的請求（即，您對資源所做的後續更改將不會在瀏覽器中反映出來）。
您可以通過將以下行添加到`config/environments/development.rb`文件中來實現：

```ruby
config.assets.prefix = "/dev-assets"
```

* 在部署工具（例如Capistrano）中禁用資源預編譯任務。
* 開發系統上必須可用所需的壓縮器或最小化工具。

您還可以設置`ENV["SECRET_KEY_BASE_DUMMY"]`以觸發使用存儲在臨時文件中的隨機生成的`secret_key_base`。這在將資源預編譯為生產的一部分時非常有用，因為它不需要訪問生產密鑰的其他構建步驟。

```bash
$ SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
```

### 即時編譯

在某些情況下，您可能希望使用即時編譯。在此模式下，管道中的所有資源請求都由Sprockets直接處理。

要啟用此選項，請設置：

```ruby
config.assets.compile = true
```

在第一個請求中，資源將根據[資源緩存存儲](#assets-cache-store)的規定進行編譯和緩存，並且輔助函數中使用的清單名稱將被修改以包含SHA256哈希。

Sprockets還將`Cache-Control` HTTP標頭設置為`max-age=31536000`。這向您的服務器和客戶端瀏覽器之間的所有緩存發出信號，表明此內容（提供的文件）可以緩存1年。這樣做的效果是減少來自您的服務器的對該資源的請求數量；該資源有很大機會在本地瀏覽器緩存或某個中間緩存中。

此模式使用的內存更多，性能比默認模式差，不建議使用。

### CDN

CDN代表[內容交付網絡](https://en.wikipedia.org/wiki/Content_delivery_network)，它們主要用於在全球範圍內緩存資源，以便當瀏覽器請求資源時，將有一個緩存的副本地理位置靠近該瀏覽器。如果您在生產中直接從Rails服務器提供資源，最佳做法是在應用程序前面使用CDN。

使用CDN的常見模式是將生產應用程序設置為“源”服務器。這意味著當瀏覽器從CDN請求資源並且缺少緩存時，它將即時從您的服務器獲取文件並緩存它。例如，如果您在`example.com`上運行Rails應用程序並在`mycdnsubdomain.fictional-cdn.com`上配置了CDN，那麼當請求`mycdnsubdomain.fictional-cdn.com/assets/smile.png`時，CDN將在`example.com/assets/smile.png`上向您的服務器發出一次請求並緩存該請求。對於相同URL的下一個請求，將命中緩存的副本。當CDN可以直接提供資源時，請求不會觸及您的Rails服務器。由於CDN的資源地理位置靠近瀏覽器，因此請求速度更快，並且由於您的服務器不需要花時間提供資源，它可以專注於盡快提供應用程序代碼。

#### 設置CDN以提供靜態資源

要設置CDN，您必須在公共可用的URL上在生產環境中運行應用程序，例如`example.com`。接下來，您需要從雲主機提供商註冊CDN服務。在這樣做時，您需要將CDN的“源”配置為指向您的網站`example.com`。請查看您的提供商的文檔以了解如何配置源服務器。

您配置的CDN應該為您的應用程序提供一個自定義子域名，例如`mycdnsubdomain.fictional-cdn.com`（注意，fictional-cdn.com在撰寫本文時不是有效的CDN提供商）。現在，您已經配置了CDN服務器，您需要告訴瀏覽器使用CDN來獲取資源，而不是直接從您的Rails服務器獲取。您可以通過在Rails中配置您的資源主機（而不是使用相對路徑）來實現這一點。要在Rails中設置資源主機，您需要在`config/environments/production.rb`中設置[`config.asset_host`][]：

```ruby
config.asset_host = 'mycdnsubdomain.fictional-cdn.com'
```

注意：您只需要提供“主機”，這是子域名和根域名，您不需要指定協議或“方案”，例如`http://`或`https://`。當請求網頁時，生成的資源鏈接中的協議將與默認情況下訪問網頁的協議匹配。

您還可以通過[環境變量](https://en.wikipedia.org/wiki/Environment_variable)設置此值，以便更輕鬆地運行站點的測試副本：
```ruby
config.asset_host = ENV['CDN_HOST']
```

注意：您需要在伺服器上設置 `CDN_HOST` 為 `mycdnsubdomain.fictional-cdn.com` 才能使此功能正常運作。

一旦您配置了伺服器和 CDN，諸如以下幫助程式所產生的資產路徑：

```erb
<%= asset_path('smile.png') %>
```

將被渲染為完整的 CDN URL，例如 `http://mycdnsubdomain.fictional-cdn.com/assets/smile.png`
（為了可讀性，摘要被省略）。

如果 CDN 有 `smile.png` 的副本，它將將其提供給瀏覽器，而您的伺服器甚至不知道它被請求了。如果 CDN 沒有副本，它將嘗試在「源」`example.com/assets/smile.png` 中找到它，然後將其存儲以供將來使用。

如果您只想從 CDN 提供某些資產，您可以在資產幫助程式中使用自定義的 `:host` 選項，該選項將覆蓋 [`config.action_controller.asset_host`][] 中設定的值。

```erb
<%= asset_path 'image.png', host: 'mycdnsubdomain.fictional-cdn.com' %>
```


#### 自定義 CDN 快取行為

CDN 通過快取內容來工作。如果 CDN 有過期或錯誤的內容，則對您的應用程序的幫助不大，反而有害。本節的目的是描述大多數 CDN 的一般快取行為。您的特定提供商可能會有稍微不同的行為。

##### CDN 請求快取

雖然 CDN 被描述為對快取資產有好處，但它實際上是對整個請求進行快取。這包括資產的主體以及任何標頭。其中最重要的是 `Cache-Control`，它告訴 CDN（和瀏覽器）如何快取內容。這意味著如果有人請求一個不存在的資產，例如 `/assets/i-dont-exist.png`，並且您的 Rails 應用程序返回 404，那麼如果存在有效的 `Cache-Control` 標頭，您的 CDN 可能會快取 404 頁面。

##### CDN 標頭調試

檢查 CDN 中的標頭是否正確快取的一種方法是使用 [curl](
https://explainshell.com/explain?cmd=curl+-I+http%3A%2F%2Fwww.example.com)。您可以請求來自您的伺服器和 CDN 的標頭，以驗證它們是否相同：

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

與 CDN 副本對比：

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

請查看您的 CDN 文件以獲取他們可能提供的任何其他信息，例如 `X-Cache` 或他們可能添加的任何其他標頭。

##### CDN 和 Cache-Control 標頭

[`Cache-Control`][] 標頭描述了請求的快取方式。當不使用 CDN 時，瀏覽器將使用此信息來快取內容。這對於未修改的資產非常有用，這樣瀏覽器就不需要在每次請求時重新下載網站的 CSS 或 JavaScript。通常，我們希望我們的 Rails 伺服器告訴我們的 CDN（和瀏覽器）該資產是「公共的」。這意味著任何快取都可以存儲該請求。同樣，我們通常希望設置 `max-age`，這是快取在無效之前存儲該對象的時間。`max-age` 的值以秒為單位，最大值為 `31536000`，即一年。您可以在 Rails 應用程序中通過設置以下方式來實現：

```ruby
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=31536000'
}
```

現在，當您的應用程序在生產環境中提供資產時，CDN 將將該資產存儲長達一年。由於大多數 CDN 也會快取請求的標頭，這個 `Cache-Control` 將傳遞給所有未來尋求此資產的瀏覽器。然後，瀏覽器知道在需要重新請求之前可以將此資產存儲很長時間。

##### CDN 和基於 URL 的快取失效

大多數 CDN 將根據完整的 URL 快取資產的內容。這意味著對於以下請求：

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile-123.png
```

與

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

將是完全不同的快取。如果您希望在 `Cache-Control` 中設置遠期 `max-age`（您確實希望這樣做），請確保在更改資產時使快取失效。例如，當將圖像中的笑臉從黃色更改為藍色時，您希望網站的所有訪問者都能獲得新的藍色笑臉。使用 Rails 資產管道時，`config.assets.digest` 默認為 true，這樣每個資產在更改時都會有不同的文件名。這樣，您就不必手動使快取中的任何項目失效。通過使用不同的唯一資產名稱，您的用戶可以獲得最新的資產。
自訂化流程
------------------------

### CSS 壓縮

壓縮 CSS 的選項之一是 YUI。[YUI CSS
compressor](https://yui.github.io/yuicompressor/css.html) 提供了壓縮功能。

以下程式碼啟用 YUI 壓縮，需要 `yui-compressor`
gem。

```ruby
config.assets.css_compressor = :yui
```

### JavaScript 壓縮

JavaScript 壓縮的可能選項有 `:terser`、`:closure` 和
`:yui`。這些選項分別需要使用 `terser`、`closure-compiler` 或
`yui-compressor` gem。

以 `terser` gem 為例。
這個 gem 將 [Terser](https://github.com/terser/terser)（用於
Node.js）封裝成 Ruby。它通過刪除空格和註釋、縮短局部變量名稱以及執行其他微優化操作（例如在可能的情況下將 `if` 和 `else` 語句更改為三元運算符）來壓縮代碼。

以下程式碼調用 `terser` 進行 JavaScript 壓縮。

```ruby
config.assets.js_compressor = :terser
```

注意：使用 `terser` 需要一個支援 [ExecJS](https://github.com/rails/execjs#readme) 的運行時。如果你使用的是 macOS 或
Windows，你的操作系統已經安裝了一個 JavaScript 運行時。

注意：當你通過 `importmap-rails` 或 `jsbundling-rails` gem 加載資源時，JavaScript 壓縮也會適用於你的 JavaScript 檔案。

### 壓縮資源

預設情況下，編譯後的資源將生成壓縮和未壓縮的版本。壓縮後的資源有助於減少數據在網絡上的傳輸。你可以通過設置 `gzip` 標誌來配置此功能。

```ruby
config.assets.gzip = false # 禁用壓縮資源的生成
```

請參考你的網頁伺服器的文檔，了解如何提供壓縮資源的指示。

### 使用自定義的壓縮器

CSS 和 JavaScript 的壓縮器配置設置也可以接受任何對象。該對象必須具有一個接受字符串作為唯一參數的 `compress` 方法，並且必須返回一個字符串。

```ruby
class Transformer
  def compress(string)
    do_something_returning_a_string(string)
  end
end
```

要啟用此功能，請將一個新的對象傳遞給 `application.rb` 中的配置選項：

```ruby
config.assets.css_compressor = Transformer.new
```

### 更改 _assets_ 路徑

Sprockets 默認使用的公共路徑是 `/assets`。

你可以將其更改為其他路徑：

```ruby
config.assets.prefix = "/some_other_path"
```

如果你正在更新一個之前沒有使用資源管道並且已經使用此路徑的舊項目，或者你希望為新資源使用此路徑，這是一個方便的選項。

### X-Sendfile 標頭

X-Sendfile 標頭是一個指示網頁伺服器忽略應用程序的響應，而是從磁盤上提供指定文件的指令。默認情況下，此選項是關閉的，但如果你的伺服器支援，可以啟用它。啟用後，這將把提供文件的責任轉交給網頁伺服器，這樣可以更快地提供文件。請參考 [send_file](https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file) 以了解如何使用此功能。

Apache 和 NGINX 支援此選項，可以在 `config/environments/production.rb` 中啟用：

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # 用於 Apache
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # 用於 NGINX
```

警告：如果你正在升級一個現有的應用程序並打算使用此選項，請注意只將此配置選項粘貼到 `production.rb` 和任何其他定義了生產行為的環境中（而不是 `application.rb`）。

提示：有關詳細信息，請查看你的生產網頁伺服器的文檔：

- [Apache](https://tn123.org/mod_xsendfile/)
- [NGINX](https://www.nginx.com/resources/wiki/start/topics/examples/xsendfile/)

資源快取存儲
------------------

默認情況下，Sprockets 在開發和生產環境中將資源快取到 `tmp/cache/assets`。你可以按照以下方式進行更改：

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:memory_store,
                                                { size: 32.megabytes })
end
```

要禁用資源快取存儲：

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:null_store)
end
```

將資源添加到你的 Gems
--------------------------

資源也可以來自於以 gem 形式提供的外部來源。

一個很好的例子是 `jquery-rails` gem。
這個 gem 包含一個繼承自 `Rails::Engine` 的引擎類。通過這樣做，Rails 會知道這個 gem 的目錄可能包含資源，並將這個引擎的 `app/assets`、`lib/assets` 和 `vendor/assets` 目錄添加到 Sprockets 的搜索路徑中。

使你的庫或 gem 成為預處理器
------------------------------------------

Sprockets 使用處理器（Processors）、轉換器（Transformers）、壓縮器（Compressors）和導出器（Exporters）來擴展 Sprockets 的功能。請參考 [擴展 Sprockets](https://github.com/rails/sprockets/blob/master/guides/extending_sprockets.md) 以了解更多。這裡我們註冊了一個預處理器，將一個註釋添加到 text/css（`.css`）檔案的末尾。

```ruby
module AddComment
  def self.call(input)
    { data: input[:data] + "/* Hello From my sprockets extension */" }
  end
end
```

現在你有了一個修改輸入資料的模塊，是時候將其註冊為你的 MIME 類型的預處理器了。
```ruby
Sprockets.register_preprocessor 'text/css', AddComment
```


替代庫
------------------------------------------

多年來，處理資源的方式有多種預設方法。隨著網路的演進，我們開始看到越來越多以JavaScript為主的應用程式。在《Rails信條》中，我們相信「菜單是大廚選擇」，所以我們專注於預設設定：**使用Sprockets和Import Maps**。

我們知道，對於各種JavaScript和CSS框架/擴展，沒有一個適用於所有情況的解決方案。在Rails生態系統中，還有其他捆綁庫可以在預設設定不足的情況下提供支援。

### jsbundling-rails

[`jsbundling-rails`](https://github.com/rails/jsbundling-rails)是一個依賴於Node.js的選擇，用於使用[esbuild](https://esbuild.github.io/)、[rollup.js](https://rollupjs.org/)或[Webpack](https://webpack.js.org/)將JavaScript進行捆綁。

這個gem提供了`yarn build --watch`的過程，以在開發中自動生成輸出。對於生產環境，它會自動將`javascript:build`任務鉤入`assets:precompile`任務，以確保所有的套件依賴都已安裝並為所有的入口點建立了JavaScript。

**何時使用而不是`importmap-rails`？** 如果您的JavaScript代碼依賴於轉譯，例如使用[Babel](https://babeljs.io/)、[TypeScript](https://www.typescriptlang.org/)或React的`JSX`格式，那麼`jsbundling-rails`是正確的選擇。

### Webpacker/Shakapacker

[`Webpacker`](webpacker.html)是Rails 5和6的預設JavaScript預處理器和捆綁工具。它現在已經停用。有一個名為[`shakapacker`](https://github.com/shakacode/shakapacker)的後繼者存在，但它不由Rails團隊或項目維護。

與此列表中的其他庫不同，`webpacker`/`shakapacker`完全獨立於Sprockets，可以處理JavaScript和CSS文件。請閱讀[Webpacker指南](https://guides.rubyonrails.org/webpacker.html)以了解更多信息。

注意：請閱讀[與Webpacker的比較](https://github.com/rails/jsbundling-rails/blob/main/docs/comparison_with_webpacker.md)文件，以了解`jsbundling-rails`和`webpacker`/`shakapacker`之間的差異。

### cssbundling-rails

[`cssbundling-rails`](https://github.com/rails/cssbundling-rails)允許使用[Tailwind CSS](https://tailwindcss.com/)、[Bootstrap](https://getbootstrap.com/)、[Bulma](https://bulma.io/)、[PostCSS](https://postcss.org/)或[Dart Sass](https://sass-lang.com/)進行CSS的捆綁和處理，然後通過資源管道傳遞CSS。

它的工作方式與`jsbundling-rails`類似，因此在應用程式中添加了Node.js依賴，並提供了`yarn build:css --watch`的過程，以在開發中重新生成樣式表，並在生產環境中鉤入`assets:precompile`任務。

**與Sprockets的區別是什麼？** 單獨的Sprockets無法將Sass轉譯為CSS，需要使用Node.js從`.sass`文件生成`.css`文件。一旦生成了`.css`文件，`Sprockets`就能夠將它們傳遞給客戶端。

注意：`cssbundling-rails`依賴於Node來處理CSS。`dartsass-rails`和`tailwindcss-rails` gem使用獨立版本的Tailwind CSS和Dart Sass，因此不需要Node依賴。如果您使用`importmap-rails`來處理JavaScript，並使用`dartsass-rails`或`tailwindcss-rails`來處理CSS，則可以完全避免Node依賴，從而獲得更簡單的解決方案。

### dartsass-rails

如果您想在應用程式中使用[`Sass`](https://sass-lang.com/)，[`dartsass-rails`](https://github.com/rails/dartsass-rails)是對傳統的`sassc-rails` gem的替代品。`dartsass-rails`使用了2020年被棄用的[`LibSass`](https://sass-lang.com/blog/libsass-is-deprecated)的`Dart Sass`實現。

與`sassc-rails`不同，這個新的gem沒有直接集成到`Sprockets`中。有關安裝/遷移說明，請參閱[gem主頁](https://github.com/rails/dartsass-rails)。

警告：自2019年以來，受歡迎的`sassc-rails` gem已停止維護。

### tailwindcss-rails

[`tailwindcss-rails`](https://github.com/rails/tailwindcss-rails)是Tailwind CSS v3框架的[獨立執行版本](https://tailwindcss.com/blog/standalone-cli)的包裝gem。當在`rails new`命令中提供`--css tailwind`時，用於新應用程式。在開發中，它提供了一個`watch`過程，以自動生成Tailwind輸出。對於生產環境，它鉤入`assets:precompile`任務。
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.assets.digest`]: configuring.html#config-assets-digest
[`config.assets.prefix`]: configuring.html#config-assets-prefix
[`config.action_controller.asset_host`]: configuring.html#config-action-controller-asset-host
[`config.asset_host`]: configuring.html#config-asset-host
[`Cache-Control`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
