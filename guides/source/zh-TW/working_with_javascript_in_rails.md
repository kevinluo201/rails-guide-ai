**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c1e56036aa9fd68276daeec5a9407096
在Rails中使用JavaScript
=======================

本指南介紹了將JavaScript功能集成到Rails應用程序中的選項，包括使用外部JavaScript包的選項以及如何在Rails中使用Turbo。

閱讀本指南後，您將了解：

* 如何在不需要Node.js、Yarn或JavaScript打包工具的情況下使用Rails。
* 如何使用import maps、esbuild、rollup或webpack來打包JavaScript來創建新的Rails應用程序。
* Turbo是什麼，以及如何使用它。
* 如何使用Rails提供的Turbo HTML輔助工具。

--------------------------------------------------------------------------------

Import Maps
-----------

[Import maps](https://github.com/rails/importmap-rails)允許您使用與版本化文件直接映射的邏輯名稱導入JavaScript模塊。從Rails 7開始，import maps是默認選項，允許任何人在不需要轉譯或打包的情況下使用大多數NPM包來構建現代JavaScript應用程序。

使用import maps的應用程序不需要[Node.js](https://nodejs.org/en/)或[Yarn](https://yarnpkg.com/)。如果您計劃使用`importmap-rails`在Rails中管理JavaScript依賴項，則無需安裝Node.js或Yarn。

使用import maps時，不需要單獨的構建過程，只需使用`bin/rails server`啟動服務器即可。

### 安裝importmap-rails

對於新應用程序，Rails 7+會自動包含Importmap for Rails，但您也可以在現有應用程序中手動安裝它：

```bash
$ bin/bundle add importmap-rails
```

運行安裝任務：

```bash
$ bin/rails importmap:install
```

### 使用importmap-rails添加NPM包

要將新的包添加到使用import map的應用程序中，從終端運行`bin/importmap pin`命令：

```bash
$ bin/importmap pin react react-dom
```

然後，像往常一樣將該包導入`application.js`：

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

使用JavaScript打包工具添加NPM包
--------------------------

對於新的Rails應用程序，默認使用import maps，但如果您更喜歡傳統的JavaScript打包，可以使用您選擇的[esbuild](https://esbuild.github.io/)、[webpack](https://webpack.js.org/)或[rollup.js](https://rollupjs.org/guide/en/)創建新的Rails應用程序。

要在新的Rails應用程序中使用打包工具而不是import maps，請將`—javascript`或`-j`選項傳遞給`rails new`：

```bash
$ rails new my_new_app --javascript=webpack
或
$ rails new my_new_app -j webpack
```

這些打包選項都帶有簡單的配置，並通過[jsbundling-rails](https://github.com/rails/jsbundling-rails) gem與資源管道進行集成。

使用打包選項時，使用`bin/dev`啟動Rails服務器並為開發版構建JavaScript。

### 安裝Node.js和Yarn

如果您在Rails應用程序中使用JavaScript打包工具，則必須安裝Node.js和Yarn。

在[Node.js網站](https://nodejs.org/en/download/)上找到安裝說明，並使用以下命令驗證其是否正確安裝：

```bash
$ node --version
```

您的Node.js運行時版本應該被列印出來。請確保它大於`8.16.0`。

要安裝Yarn，請按照[Yarn網站](https://classic.yarnpkg.com/en/docs/install)上的安裝說明進行操作。運行此命令應該會列印出Yarn的版本：

```bash
$ yarn --version
```

如果顯示類似`1.22.0`的內容，則Yarn已正確安裝。

在Import Maps和JavaScript打包工具之間進行選擇
------------------------------------------------

在創建新的Rails應用程序時，您需要在import maps和JavaScript打包解決方案之間進行選擇。每個應用程序都有不同的要求，您應該在選擇JavaScript選項之前仔細考慮您的要求，因為對於大型、複雜的應用程序來說，從一個選項遷移到另一個選項可能需要花費大量時間。

Import maps是默認選項，因為Rails團隊相信import maps在減少複雜性、改善開發者體驗和提供性能增益方面的潛力。

對於許多應用程序，特別是那些主要依賴[Hotwire](https://hotwired.dev/)堆棧滿足其JavaScript需求的應用程序，import maps將是長期的正確選擇。您可以在[這裡](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b)閱讀有關在Rails 7中將import maps設置為默認選項的原因的更多信息。

其他應用程序可能仍然需要傳統的JavaScript打包工具。表明您應該選擇傳統打包工具的要求包括：

* 如果您的代碼需要轉譯步驟，例如JSX或TypeScript。
* 如果您需要使用包含CSS或依賴於[Webpack loaders](https://webpack.js.org/loaders/)的JavaScript庫。
* 如果您確定需要[tree-shaking](https://webpack.js.org/guides/tree-shaking/)。
* 如果您將通過[cssbundling-rails gem](https://github.com/rails/cssbundling-rails)安裝Bootstrap、Bulma、PostCSS或Dart CSS。如果您在`rails new`中未指定其他選項，此gem提供的所有選項都會自動為您安裝`esbuild`。
Turbo
-----

無論您選擇使用導入地圖或傳統的打包工具，Rails都內建了[Turbo](https://turbo.hotwired.dev/)，以加快應用程式的速度，同時大幅減少您需要編寫的JavaScript程式碼量。

Turbo讓您的伺服器直接傳送HTML，作為傳統前端框架的替代方案，將您的Rails應用程式的伺服器端減少到僅僅是一個JSON API。

### Turbo Drive

[Turbo Drive](https://turbo.hotwired.dev/handbook/drive)通過避免在每次導航請求時進行完整的頁面拆除和重建，加快頁面載入速度。 Turbo Drive是對Turbolinks的改進和替代。

### Turbo Frames

[Turbo Frames](https://turbo.hotwired.dev/handbook/frames)允許在請求時更新頁面的預定義部分，而不影響頁面的其他內容。

您可以使用Turbo Frames來建立內部編輯而無需任何自定義JavaScript，延遲加載內容，並輕鬆創建伺服器渲染的分頁界面。

Rails提供了HTML輔助程式，通過[turbo-rails](https://github.com/hotwired/turbo-rails) gem簡化Turbo Frames的使用。

使用這個gem，您可以使用`turbo_frame_tag`輔助程式將Turbo Frame添加到您的應用程式中，如下所示：

```erb
<%= turbo_frame_tag dom_id(post) do %>
  <div>
     <%= link_to post.title, post_path(post) %>
  </div>
<% end %>
```

### Turbo Streams

[Turbo Streams](https://turbo.hotwired.dev/handbook/streams)以自執行的`<turbo-stream>`元素包裹的HTML片段形式傳遞頁面更改。 Turbo Streams允許您通過WebSockets廣播其他使用者進行的更改，並在表單提交後更新頁面的部分內容，而無需進行完整的頁面載入。

Rails通過[turbo-rails](https://github.com/hotwired/turbo-rails) gem提供了HTML和伺服器端輔助程式，以簡化Turbo Streams的使用。

使用這個gem，您可以從控制器動作中呈現Turbo Streams：

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

Rails將自動尋找`.turbo_stream.erb`視圖檔案，並在找到時呈現該視圖。

Turbo Stream回應也可以在控制器動作中內嵌呈現：

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

最後，Turbo Streams可以從模型或後台工作中使用內建的輔助程式啟動。這些廣播可以用於通過WebSocket連接向所有使用者更新內容，使頁面內容保持新鮮，使您的應用程式更加生動。

要從模型中廣播Turbo Stream，結合模型回呼，例如：

```ruby
class Post < ApplicationRecord
  after_create_commit { broadcast_append_to('posts') }
end
```

在應該接收更新的頁面上設置WebSocket連接，如下所示：

```erb
<%= turbo_stream_from "posts" %>
```

替代Rails/UJS功能
----------------------------------------

Rails 6附帶了一個名為UJS（Unobtrusive JavaScript）的工具。 UJS允許開發人員覆蓋`<a>`標籤的HTTP請求方法，在執行操作之前添加確認對話框等功能。在Rails 7之前，UJS是默認選項，但現在建議改用Turbo。

### 方法

點擊鏈接始終導致HTTP GET請求。如果您的應用程式是[RESTful](https://en.wikipedia.org/wiki/Representational_State_Transfer)，某些鏈接實際上是在伺服器上更改數據的操作，應該使用非GET請求執行。`data-turbo-method`屬性允許將此類鏈接標記為明確的方法，例如“post”，“put”或“delete”。

Turbo將掃描應用程式中的`<a>`標籤，尋找`turbo-method`數據屬性，並在存在時使用指定的方法，覆蓋默認的GET操作。

例如：

```erb
<%= link_to "刪除文章", post_path(post), data: { turbo_method: "delete" } %>
```

這將生成：

```html
<a data-turbo-method="delete" href="...">刪除文章</a>
```

改變鏈接方法的另一種方法是使用Rails的`button_to`輔助程式。出於可訪問性的原因，對於任何非GET操作，實際的按鈕和表單是首選。

### 確認

您可以通過在鏈接和表單上添加`data-turbo-confirm`屬性，向用戶要求額外的確認。在點擊鏈接或提交表單時，用戶將看到一個包含屬性文本的JavaScript `confirm()`對話框。如果用戶選擇取消，操作將不會執行。

例如，使用`link_to`輔助程式：

```erb
<%= link_to "刪除文章", post_path(post), data: { turbo_method: "delete", turbo_confirm: "確定要刪除嗎？" } %>
```

這將生成：

```html
<a href="..." data-turbo-confirm="確定要刪除嗎？" data-turbo-method="delete">刪除文章</a>
```
當使用者點擊「刪除文章」連結時，將彈出一個「您確定嗎？」的確認對話框。

該屬性也可以與 `button_to` 輔助方法一起使用，但必須添加到 `button_to` 輔助方法內部渲染的表單中：

```erb
<%= button_to "刪除文章", post, method: :delete, form: { data: { turbo_confirm: "您確定嗎？" } } %>
```

### Ajax 請求

從 JavaScript 發出非 GET 請求時，需要使用 `X-CSRF-Token` 標頭。如果沒有這個標頭，請求將不會被 Rails 接受。

注意：Rails 需要此令牌來防止跨站請求偽造（CSRF）攻擊。詳細資訊請參閱[安全指南](security.html#cross-site-request-forgery-csrf)。

[Rails Request.JS](https://github.com/rails/request.js) 封裝了添加 Rails 所需的請求標頭的邏輯。只需從該套件中導入 `FetchRequest` 類別，並實例化它，傳遞請求方法、URL 和選項，然後調用 `await request.perform()`，並對回應進行必要的處理。

例如：

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

使用其他庫進行 Ajax 請求時，需要自行將安全令牌添加為預設標頭。要獲取令牌，請查看應用程式視圖中由 [`csrf_meta_tags`][] 打印的 `<meta name='csrf-token' content='THE-TOKEN'>` 標籤。您可以進行如下操作：

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```

[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
