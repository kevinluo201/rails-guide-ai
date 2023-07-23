**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 02f663dc709da76ced45deb2ba800a78
Rails中的佈局和渲染
=================

本指南介紹了Action Controller和Action View的基本佈局功能。

閱讀本指南後，您將了解：

* 如何使用Rails內建的各種渲染方法。
* 如何創建具有多個內容區域的佈局。
* 如何使用局部視圖來減少重複代碼。
* 如何使用嵌套佈局（子模板）。

--------------------------------------------------------------------------------

概述：各個組件如何配合
----------------------

本指南重點介紹了模型-視圖-控制器三角形中控制器和視圖之間的交互。如您所知，控制器負責協調處理Rails中的請求過程，儘管它通常將任何繁重的代碼交給模型處理。但是，當需要向用戶發送響應時，控制器會將事情交給視圖。這就是本指南的主題。

大致上，這涉及決定應該發送什麼作為響應並調用適當的方法來創建該響應。如果響應是一個完整的視圖，Rails還會進行一些額外的工作，將視圖包裝在佈局中，並可能引入局部視圖。您將在本指南的後面看到所有這些路徑。

創建響應
----------

從控制器的角度來看，有三種方法可以創建HTTP響應：

* 調用[`render`][controller.render]來創建完整的響應並發送回瀏覽器
* 調用[`redirect_to`][]將HTTP重定向狀態碼發送到瀏覽器
* 調用[`head`][]創建僅由HTTP標頭組成的響應並發送回瀏覽器


### 默認渲染：在行動中的慣例優於配置

您可能聽說過Rails提倡“慣例優於配置”。默認渲染是這一點的一個很好的例子。默認情況下，Rails中的控制器會自動渲染與有效路由對應的視圖。例如，如果您在`BooksController`類中有以下代碼：

```ruby
class BooksController < ApplicationController
end
```

並且在路由文件中有以下代碼：

```ruby
resources :books
```

並且您有一個視圖文件`app/views/books/index.html.erb`：

```html+erb
<h1>Books are coming soon!</h1>
```

當您訪問`/books`時，Rails將自動渲染`app/views/books/index.html.erb`，並在屏幕上顯示“Books are coming soon!”。

然而，即將推出的畫面只有很少的用處，所以您很快會創建自己的`Book`模型並將索引操作添加到`BooksController`中：

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

請注意，根據“慣例優於配置”原則，在索引操作的末尾我們沒有明確地調用渲染。規則是，如果您在控制器操作的末尾沒有明確地渲染任何內容，Rails將自動查找控制器的視圖路徑中的`action_name.html.erb`模板並渲染它。因此，在這種情況下，Rails將渲染`app/views/books/index.html.erb`文件。

如果我們想在視圖中顯示所有書籍的屬性，可以使用以下ERB模板：

```html+erb
<h1>Listing Books</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Show", book %></td>
        <td><%= link_to "Edit", edit_book_path(book) %></td>
        <td><%= link_to "Destroy", book, data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "New book", new_book_path %>
```

注意：實際的渲染由[`ActionView::Template::Handlers`](https://api.rubyonrails.org/classes/ActionView/Template/Handlers.html)模塊的嵌套類完成。本指南不深入探討該過程，但重要的是要知道您視圖上的文件擴展名控制了模板處理程序的選擇。

### 使用`render`

在大多數情況下，控制器的[`render`][controller.render]方法負責為瀏覽器渲染應用程序的內容。有多種方法可以自定義`render`的行為。您可以渲染Rails模板的默認視圖，或特定的模板，或文件，或內嵌代碼，或根本不渲染。您可以渲染文本、JSON或XML。您還可以指定渲染響應的內容類型或HTTP狀態。

提示：如果您想在不需要在瀏覽器中檢查的情況下查看`render`調用的確切結果，可以調用`render_to_string`。此方法與`render`完全相同，但返回一個字符串而不是將響應發送回瀏覽器。
#### 渲染動作的視圖

如果你想要在同一個控制器中渲染對應於不同模板的視圖，你可以使用 `render` 並指定視圖的名稱：

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

如果 `update` 的呼叫失敗，呼叫這個控制器中的 `update` 動作將會渲染屬於同一個控制器的 `edit.html.erb` 模板。

如果你喜歡，你也可以使用符號而不是字串來指定要渲染的動作：

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit, status: :unprocessable_entity
  end
end
```

#### 從另一個控制器渲染動作的模板

如果你想要從完全不同的控制器中渲染模板，你也可以使用 `render`，它接受要渲染的模板的完整路徑（相對於 `app/views`）。例如，如果你在位於 `app/controllers/admin` 的 `AdminProductsController` 中執行程式碼，你可以這樣渲染來自 `app/views/products` 的動作結果到模板：

```ruby
render "products/show"
```

Rails 會根據字串中的斜線字符判斷這個視圖屬於不同的控制器。如果你想要明確指定，你可以使用 `:template` 選項（在 Rails 2.2 及之前的版本中是必需的）：

```ruby
render template: "products/show"
```

#### 總結

上述兩種渲染方式（渲染同一個控制器中另一個動作的模板，以及渲染不同控制器中另一個動作的模板）實際上是相同操作的變體。

事實上，在 `BooksController` 類中，在我們希望在書籍更新失敗時渲染編輯模板的更新動作中，以下所有的渲染呼叫都會渲染 `views/books` 目錄中的 `edit.html.erb` 模板：

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

你使用哪一種方式實際上是一個風格和慣例的問題，但一般原則是使用對於你正在編寫的程式碼最簡單的方式。

#### 使用 `render` 和 `:inline`

如果你願意在方法呼叫中使用 `:inline` 選項提供 ERB，`render` 方法可以完全不使用視圖。這是完全有效的：

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

警告：很少有好的理由使用這個選項。將 ERB 混入控制器中會破壞 Rails 的 MVC 導向，並且會使其他開發人員更難理解你的專案的邏輯。請改用獨立的 erb 視圖。

預設情況下，內聯渲染使用 ERB。你可以使用 `:type` 選項強制使用 Builder：

```ruby
render inline: "xml.p {'糟糕的編碼實踐！'}", type: :builder
```

#### 渲染純文字

你可以使用 `:plain` 選項將純文字（沒有任何標記）傳送回瀏覽器，並使用 `render`：

```ruby
render plain: "OK"
```

提示：渲染純文字最有用的情況是當你要回應期望不是正確 HTML 的 Ajax 或 Web 服務請求時。

注意：預設情況下，如果你使用 `:plain` 選項，文字將不會使用當前的佈局渲染。如果你希望 Rails 將文字放入當前的佈局中，你需要添加 `layout: true` 選項並使用 `.text.erb` 擴展名的佈局檔案。

#### 渲染 HTML

你可以使用 `:html` 選項將 HTML 字串傳送回瀏覽器，並使用 `render`：

```ruby
render html: helpers.tag.strong('Not Found')
```

提示：當你渲染一小段 HTML 代碼時，這很有用。但是，如果標記很複雜，你可能需要考慮將它移動到一個模板檔案中。

注意：使用 `html:` 選項時，如果字串不是使用 `html_safe` 相關的 API 組合而成，HTML 實體將被轉義。

#### 渲染 JSON

JSON 是許多 Ajax 函式庫使用的 JavaScript 資料格式。Rails 內建支援將物件轉換為 JSON 並將該 JSON 渲染回瀏覽器：

```ruby
render json: @product
```

提示：你不需要在要渲染的物件上調用 `to_json`。如果你使用 `:json` 選項，`render` 會自動為你調用 `to_json`。
#### 渲染 XML

Rails還內建支援將物件轉換為 XML 並將該 XML 渲染回呼叫者：

```ruby
render xml: @product
```

提示：您不需要在要渲染的物件上呼叫 `to_xml`。如果使用 `:xml` 選項，`render` 會自動為您呼叫 `to_xml`。

#### 渲染原生 JavaScript

Rails可以渲染原生 JavaScript：

```ruby
render js: "alert('Hello Rails');"
```

這將以 `text/javascript` 的 MIME 類型將提供的字串傳送到瀏覽器。

#### 渲染原始內容

您可以使用 `:body` 選項將原始內容傳送回瀏覽器，而不設置任何內容類型：

```ruby
render body: "raw"
```

提示：只有在您不關心回應的內容類型時才應使用此選項。大多數情況下，使用 `:plain` 或 `:html` 可能更適合。

注意：除非覆寫，否則從此渲染選項返回的回應將是 `text/plain`，因為這是 Action Dispatch 回應的預設內容類型。

#### 渲染原始檔案

Rails可以從絕對路徑渲染原始檔案。這對於有條件地渲染靜態檔案（例如錯誤頁面）非常有用。

```ruby
render file: "#{Rails.root}/public/404.html", layout: false
```

這會渲染原始檔案（不支援 ERB 或其他處理器）。預設情況下，它會在當前佈局中渲染。

警告：在使用者輸入的情況下，使用 `:file` 選項可能會導致安全問題，因為攻擊者可以使用此操作來訪問您檔案系統中的安全敏感檔案。

提示：如果不需要佈局，通常使用 `send_file` 是更快且更好的選擇。

#### 渲染物件

Rails可以渲染回應 `:render_in` 的物件。

```ruby
render MyRenderable.new
```

這會在提供的物件上使用當前視圖上下文呼叫 `render_in`。

您也可以使用 `:renderable` 選項將物件提供給 `render`：

```ruby
render renderable: MyRenderable.new
```

#### `render` 的選項

對 [`render`][controller.render] 方法的呼叫通常接受六個選項：

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`
* `:variants`

##### `:content_type` 選項

預設情況下，Rails會使用 `text/html` 的 MIME 內容類型（如果使用 `:json` 選項則為 `application/json`，如果使用 `:xml` 選項則為 `application/xml`）來提供渲染操作的結果。有時您可能希望更改這一點，您可以通過設置 `:content_type` 選項來實現：

```ruby
render template: "feed", content_type: "application/rss"
```

##### `:layout` 選項

對於大多數 `render` 選項，渲染的內容會作為當前佈局的一部分顯示。您將在本指南的後面學習有關佈局及其使用方法的更多內容。

您可以使用 `:layout` 選項告訴Rails使用特定的檔案作為當前操作的佈局：

```ruby
render layout: "special_layout"
```

您還可以告訴Rails不使用任何佈局來渲染：

```ruby
render layout: false
```

##### `:location` 選項

您可以使用 `:location` 選項設置HTTP `Location` 標頭：

```ruby
render xml: photo, location: photo_url(photo)
```

##### `:status` 選項

Rails會自動生成具有正確HTTP狀態碼的回應（在大多數情況下，這是 `200 OK`）。您可以使用 `:status` 選項來更改這一點：

```ruby
render status: 500
render status: :forbidden
```

Rails可以理解數字狀態碼和下面顯示的相應符號。

| 回應類別           | HTTP 狀態碼 | 符號                             |
| ------------------- | ------------ | -------------------------------- |
| **資訊**           | 100          | :continue                        |
|                     | 101          | :switching_protocols             |
|                     | 102          | :processing                      |
| **成功**           | 200          | :ok                              |
|                     | 201          | :created                         |
|                     | 202          | :accepted                        |
|                     | 203          | :non_authoritative_information   |
|                     | 204          | :no_content                      |
|                     | 205          | :reset_content                   |
|                     | 206          | :partial_content                 |
|                     | 207          | :multi_status                    |
|                     | 208          | :already_reported                |
|                     | 226          | :im_used                         |
| **重新導向**       | 300          | :multiple_choices                |
|                     | 301          | :moved_permanently               |
|                     | 302          | :found                           |
|                     | 303          | :see_other                       |
|                     | 304          | :not_modified                    |
|                     | 305          | :use_proxy                       |
|                     | 307          | :temporary_redirect              |
|                     | 308          | :permanent_redirect              |
| **用戶端錯誤**     | 400          | :bad_request                     |
|                     | 401          | :unauthorized                    |
|                     | 402          | :payment_required                |
|                     | 403          | :forbidden                       |
|                     | 404          | :not_found                       |
|                     | 405          | :method_not_allowed              |
|                     | 406          | :not_acceptable                  |
|                     | 407          | :proxy_authentication_required   |
|                     | 408          | :request_timeout                 |
|                     | 409          | :conflict                        |
|                     | 410          | :gone                            |
|                     | 411          | :length_required                 |
|                     | 412          | :precondition_failed             |
|                     | 413          | :payload_too_large               |
|                     | 414          | :uri_too_long                    |
|                     | 415          | :unsupported_media_type          |
|                     | 416          | :range_not_satisfiable           |
|                     | 417          | :expectation_failed              |
|                     | 421          | :misdirected_request             |
|                     | 422          | :unprocessable_entity            |
|                     | 423          | :locked                          |
|                     | 424          | :failed_dependency               |
|                     | 426          | :upgrade_required                |
|                     | 428          | :precondition_required           |
|                     | 429          | :too_many_requests               |
|                     | 431          | :request_header_fields_too_large |
|                     | 451          | :unavailable_for_legal_reasons   |
| **伺服器錯誤**     | 500          | :internal_server_error           |
|                     | 501          | :not_implemented                 |
|                     | 502          | :bad_gateway                     |
|                     | 503          | :service_unavailable             |
|                     | 504          | :gateway_timeout                 |
|                     | 505          | :http_version_not_supported      |
|                     | 506          | :variant_also_negotiates         |
|                     | 507          | :insufficient_storage            |
|                     | 508          | :loop_detected                   |
|                     | 510          | :not_extended                    |
|                     | 511          | :network_authentication_required |
注意：如果您嘗試在非內容狀態碼（100-199、204、205或304）中呈現內容，則該內容將從響應中刪除。

##### `:formats` 選項

Rails使用請求中指定的格式（或默認為 `:html` ）。您可以通過傳遞符號或數組的 `:formats` 選項來更改這一點：

```ruby
render formats: :xml
render formats: [:json, :xml]
```

如果不存在指定格式的模板，則會引發 `ActionView::MissingTemplate` 錯誤。

##### `:variants` 選項

這告訴Rails尋找相同格式的模板變體。您可以通過傳遞符號或數組的 `:variants` 選項來指定變體列表。

以下是使用示例。

```ruby
# 在HomeController#index中調用
render variants: [:mobile, :desktop]
```

使用這組變體，Rails將尋找以下一組模板並使用存在的第一個模板。

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

如果不存在指定格式的模板，則會引發 `ActionView::MissingTemplate` 錯誤。

您也可以在控制器操作中的請求對象上設置變體，而不是在渲染調用中設置它。

```ruby
def index
  request.variant = determine_variant
end

private
def determine_variant
  variant = nil
  # 一些用於確定要使用的變體的代碼
  variant = :mobile if session[:use_mobile]

  variant
end
```

#### 查找佈局

要查找當前佈局，Rails首先尋找 `app/views/layouts` 中與控制器同名的文件。例如，從 `PhotosController` 類呈現操作將使用 `app/views/layouts/photos.html.erb`（或 `app/views/layouts/photos.builder` ）。如果沒有這樣的控制器特定佈局，Rails將使用 `app/views/layouts/application.html.erb` 或 `app/views/layouts/application.builder` 。如果沒有 `.erb` 佈局，Rails將使用 `.builder` 佈局（如果存在）。Rails還提供了幾種更精確地為個別控制器和操作分配特定佈局的方法。

##### 為控制器指定佈局

您可以使用 [`layout`][] 声明在控制器中覆蓋默認佈局慣例。例如：

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

使用此声明，由 `ProductsController` 渲染的所有視圖將使用 `app/views/layouts/inventory.html.erb` 作為佈局。

要為整個應用程序分配特定佈局，請在 `ApplicationController` 類中使用 `layout` 声明：

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

使用此声明，整個應用程序中的所有視圖將使用 `app/views/layouts/main.html.erb` 作為佈局。

##### 在運行時選擇佈局

您可以使用符號推遲佈局的選擇，直到處理請求：

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
  def products_layout
    @current_user.special? ? "special" : "products"
  end
end
```

現在，如果當前用戶是特殊用戶，則在查看產品時將使用特殊佈局。

您甚至可以使用內聯方法，例如Proc，來確定佈局。例如，如果傳遞了Proc對象，則將給予Proc的塊將給予 `controller` 實例，因此可以根據當前請求來確定佈局：

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### 條件佈局

在控制器級別指定的佈局支持 `:only` 和 `:except` 選項。這些選項接受方法名或方法名數組，對應於控制器內的方法名：

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

使用此声明，`product` 佈局將用於除 `rss` 和 `index` 方法之外的所有內容。

##### 佈局繼承

佈局聲明在層次結構中向下級傳播，更具體的佈局聲明始終優先於更一般的佈局聲明。例如：

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `articles_controller.rb`

    ```ruby
    class ArticlesController < ApplicationController
    end
    ```

* `special_articles_controller.rb`

    ```ruby
    class SpecialArticlesController < ArticlesController
      layout "special"
    end
    ```

* `old_articles_controller.rb`

    ```ruby
    class OldArticlesController < SpecialArticlesController
      layout false

      def show
        @article = Article.find(params[:id])
      end

      def index
        @old_articles = Article.older
        render layout: "old"
      end
      # ...
    end
    ```

在此應用程序中：

* 通常，視圖將在 `main` 佈局中呈現
* `ArticlesController#index` 將使用 `main` 佈局
* `SpecialArticlesController#index` 將使用 `special` 佈局
* `OldArticlesController#show` 將不使用任何佈局
* `OldArticlesController#index` 將使用 `old` 佈局
##### 模板繼承

與佈局繼承邏輯類似，如果在常規路徑中找不到模板或部分，控制器將在其繼承鏈中尋找要渲染的模板或部分。例如：

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
end
```

```ruby
# app/controllers/admin_controller.rb
class AdminController < ApplicationController
end
```

```ruby
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < AdminController
  def index
  end
end
```

`admin/products#index` 操作的查找順序將為：

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

這使得 `app/views/application/` 成為共享部分的理想位置，然後可以在 ERB 中進行渲染，如下所示：

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
這個列表中還沒有任何項目 <em>。</em>
```

#### 避免重複渲染錯誤

遲早，大多數 Rails 開發人員都會看到錯誤消息 "Can only render or redirect once per action"。雖然這很煩人，但相對容易修復。通常，這是因為對 `render` 工作方式的基本誤解而引起的。

例如，這是一些會觸發此錯誤的代碼：

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

如果 `@book.special?` 評估為 `true`，Rails 將開始渲染過程，將 `@book` 變量轉儲到 `special_show` 視圖中。但這不會停止 `show` 操作中的其他代碼運行，當 Rails 達到操作結尾時，它將開始渲染 `regular_show` 視圖 - 並拋出錯誤。解決方案很簡單：確保在單個代碼路徑中只有一個對 `render` 或 `redirect` 的調用。可以使用 `return` 來幫助解決這個問題。以下是該方法的修補版本：

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
    return
  end
  render action: "regular_show"
end
```

請注意，由 ActionController 隱式渲染檢測到是否調用了 `render`，因此以下代碼將在沒有錯誤的情況下運行：

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

這將使用 `special_show` 模板渲染 `special?` 設置的書籍，而其他書籍將使用默認的 `show` 模板進行渲染。

### 使用 `redirect_to`

處理 HTTP 請求的返回響應的另一種方法是使用 [`redirect_to`][]。正如您所見，`render` 告訴 Rails 使用哪個視圖（或其他資源）來構建響應。`redirect_to` 方法完全不同：它告訴瀏覽器發送一個新的請求以獲取不同的 URL。例如，您可以從代碼中的任何位置重定向到應用程序中照片的索引，使用以下調用：

```ruby
redirect_to photos_url
```

您可以使用 [`redirect_back`][] 將用戶返回到他們剛才訪問的頁面。此位置從 `HTTP_REFERER` 標頭中提取，但瀏覽器不保證設置該標頭，因此您必須提供 `fallback_location` 以在此情況下使用。

```ruby
redirect_back(fallback_location: root_path)
```

注意：`redirect_to` 和 `redirect_back` 不會停止並立即從方法執行返回，而只是設置 HTTP 響應。在方法中它們之後出現的語句將被執行。如果需要，可以通過顯式的 `return` 或其他停止機制來停止。

#### 獲取不同的重定向狀態碼

當您調用 `redirect_to` 時，Rails 使用 HTTP 狀態碼 302，即臨時重定向。如果您想使用不同的狀態碼，例如 301，即永久重定向，可以使用 `:status` 選項：

```ruby
redirect_to photos_path, status: 301
```

就像 `render` 的 `:status` 選項一樣，`redirect_to` 的 `:status` 選項接受數字和符號標頭指定。

#### `render` 和 `redirect_to` 之間的區別

有時候，經驗不足的開發人員將 `redirect_to` 視為一種類似於 `goto` 命令的東西，在 Rails 代碼中將執行從一個地方移動到另一個地方。這是不正確的。您的代碼停止運行並等待瀏覽器的新請求。只是碰巧您已經告訴瀏覽器它應該下一個發出什麼請求，通過返回 HTTP 302 狀態碼。

請考慮以下操作以查看差異：

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

以這種形式的代碼，如果 `@book` 變量為 `nil`，可能會出現問題。請記住，`render :action` 不運行目標操作中的任何代碼，因此不會設置 `index` 視圖可能需要的 `@books` 變量。修復此問題的一種方法是重定向而不是渲染：
```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

使用這段程式碼，瀏覽器將對索引頁面進行新的請求，`index` 方法中的程式碼將運行，一切都很順利。

這段程式碼唯一的缺點是它需要往返於瀏覽器：瀏覽器請求了帶有 `/books/1` 的 show 動作，控制器發現沒有書籍，所以控制器向瀏覽器發送了一個 302 重定向響應，告訴它轉到 `/books/`，瀏覽器遵從並向控制器發送了一個新的請求，現在要求 `index` 動作，控制器然後從數據庫中獲取所有的書籍並渲染索引模板，將其返回給瀏覽器，然後在屏幕上顯示出來。

在小型應用程序中，這種增加的延遲可能不是一個問題，但如果響應時間是一個問題，這是需要考慮的。我們可以通過一個假設的例子來演示處理這個問題的一種方式：

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "找不到您的書籍"
    render "index"
  end
end
```

這將檢測到指定的 ID 沒有書籍，使用模型中的所有書籍填充 `@books` 實例變量，然後直接渲染 `index.html.erb` 模板，將其返回給瀏覽器並使用快閃警告消息告訴用戶發生了什麼。

### 使用 `head` 建立僅包含標頭的響應

[`head`][] 方法可以用於向瀏覽器發送僅包含標頭的響應。`head` 方法接受一個表示 HTTP 狀態碼的數字或符號（參見[參考表](#the-status-option)），選項參數被解釋為標頭名稱和值的哈希。例如，您可以僅返回一個錯誤標頭：

```ruby
head :bad_request
```

這將生成以下標頭：

```http
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

或者您可以使用其他 HTTP 標頭來傳達其他信息：

```ruby
head :created, location: photo_path(@photo)
```

這將生成：

```http
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

結構化佈局
-------------------

當 Rails 將視圖作為響應渲染時，它會將視圖與當前佈局結合在一起，使用在本指南中介紹的查找當前佈局的規則。在佈局中，您可以使用三種工具來組合不同的輸出部分以形成整體響應：

* 資源標籤
* `yield` 和 [`content_for`][]
* 局部視圖


### 資源標籤助手

資源標籤助手提供了用於生成 HTML 的方法，將視圖與饋送、JavaScript、樣式表、圖像、視頻和音頻鏈接在一起。Rails 提供了六個資源標籤助手：

* [`auto_discovery_link_tag`][]
* [`javascript_include_tag`][]
* [`stylesheet_link_tag`][]
* [`image_tag`][]
* [`video_tag`][]
* [`audio_tag`][]

您可以在佈局或其他視圖中使用這些標籤，儘管 `auto_discovery_link_tag`、`javascript_include_tag` 和 `stylesheet_link_tag` 最常用於佈局的 `<head>` 部分。

警告：資源標籤助手不會驗證指定位置的資源是否存在；它們只是假設您知道自己在做什麼並生成鏈接。


#### 使用 `auto_discovery_link_tag` 鏈接到饋送

[`auto_discovery_link_tag`][] 助手生成大多數瀏覽器和饋送閱讀器可以用來檢測 RSS、Atom 或 JSON 饋送存在的 HTML。它接受鏈接的類型（`:rss`、`:atom` 或 `:json`）、傳遞給 url_for 的選項哈希和標籤的選項哈希：

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS 饋送"}) %>
```

`auto_discovery_link_tag` 有三個標籤選項可用：

* `:rel` 指定鏈接中的 `rel` 值。默認值為 "alternate"。
* `:type` 指定明確的 MIME 類型。Rails 將自動生成適當的 MIME 類型。
* `:title` 指定鏈接的標題。默認值為大寫的 `:type` 值，例如 "ATOM" 或 "RSS"。
#### 使用 `javascript_include_tag` 鏈接到 JavaScript 文件

[`javascript_include_tag`][] 助手為每個提供的源文件返回一個 HTML `script` 標籤。

如果您使用啟用了[Asset Pipeline](asset_pipeline.html)的 Rails，此助手將生成一個鏈接到 `/assets/javascripts/` 而不是之前版本的 Rails 中使用的 `public/javascripts` 的鏈接。此鏈接然後由資源管道提供。

Rails 應用程序或 Rails 引擎中的 JavaScript 文件可以放在三個位置之一：`app/assets`、`lib/assets` 或 `vendor/assets`。這些位置在[資源管道指南中的資源組織部分](asset_pipeline.html#asset-organization)中有詳細說明。

您可以指定相對於文檔根目錄的完整路徑，或者如果您喜歡，可以指定 URL。例如，要鏈接到位於 `app/assets`、`lib/assets` 或 `vendor/assets` 中的名為 `javascripts` 的目錄內的 JavaScript 文件，您可以這樣做：

```erb
<%= javascript_include_tag "main" %>
```

Rails 將輸出以下 `script` 標籤：

```html
<script src='/assets/main.js'></script>
```

對此資源的請求然後由 Sprockets gem 提供。

要同時包含 `app/assets/javascripts/main.js` 和 `app/assets/javascripts/columns.js` 等多個文件：

```erb
<%= javascript_include_tag "main", "columns" %>
```

要包含 `app/assets/javascripts/main.js` 和 `app/assets/javascripts/photos/columns.js`：

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

要包含 `http://example.com/main.js`：

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### 使用 `stylesheet_link_tag` 鏈接到 CSS 文件

[`stylesheet_link_tag`][] 助手為每個提供的源文件返回一個 HTML `<link>` 標籤。

如果您使用了啟用了 "Asset Pipeline" 的 Rails，此助手將生成一個鏈接到 `/assets/stylesheets/` 的鏈接。此鏈接然後由 Sprockets gem 處理。樣式表文件可以存儲在 `app/assets`、`lib/assets` 或 `vendor/assets` 中的其中一個位置。

您可以指定相對於文檔根目錄的完整路徑，或者指定 URL。例如，要鏈接到位於 `app/assets`、`lib/assets` 或 `vendor/assets` 中的名為 `stylesheets` 的目錄內的樣式表文件，您可以這樣做：

```erb
<%= stylesheet_link_tag "main" %>
```

要包含 `app/assets/stylesheets/main.css` 和 `app/assets/stylesheets/columns.css`：

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

要包含 `app/assets/stylesheets/main.css` 和 `app/assets/stylesheets/photos/columns.css`：

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

要包含 `http://example.com/main.css`：

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

默認情況下，`stylesheet_link_tag` 創建帶有 `rel="stylesheet"` 的鏈接。您可以通過指定適當的選項（`:rel`）來覆蓋此默認值：

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### 使用 `image_tag` 鏈接到圖片

[`image_tag`][] 助手根據指定的文件構建一個 HTML `<img />` 標籤。默認情況下，文件從 `public/images` 加載。

警告：請注意，您必須指定圖片的擴展名。

```erb
<%= image_tag "header.png" %>
```

如果需要，您可以提供圖片的路徑：

```erb
<%= image_tag "icons/delete.gif" %>
```

您可以提供一個包含其他 HTML 選項的哈希：

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

您可以為圖片指定替代文本，如果用戶在其瀏覽器中關閉了圖片，則將使用該替代文本。如果您沒有明確指定 alt 文本，則默認為文件名，大寫且不包含擴展名。例如，這兩個圖片標籤將返回相同的代碼：

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

您還可以指定特殊的大小標籤，格式為 "{寬度}x{高度}"：

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

除了上述特殊標籤之外，您還可以提供一個最後的標準 HTML 選項的哈希，例如 `:class`、`:id` 或 `:name`：

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### 使用 `video_tag` 鏈接到視頻

[`video_tag`][] 助手根據指定的文件構建一個 HTML5 `<video>` 標籤。默認情況下，文件從 `public/videos` 加載。

```erb
<%= video_tag "movie.ogg" %>
```

生成

```erb
<video src="/videos/movie.ogg" />
```

與 `image_tag` 類似，您可以提供一個路徑，可以是絕對路徑，也可以是相對於 `public/videos` 目錄的路徑。此外，您可以像使用 `image_tag` 一樣指定 `size: "#{width}x#{height}"` 選項。視頻標籤還可以使用任何在最後指定的 HTML 選項（`id`、`class` 等）。

視頻標籤還通過 HTML 選項哈希支持所有 `<video>` HTML 選項，包括：

* `poster: "image_name.png"`，在視頻開始播放之前提供一個圖片。
* `autoplay: true`，在頁面加載時開始播放視頻。
* `loop: true`，視頻在結束時循環播放。
* `controls: true`，提供瀏覽器提供的控件，供用戶與視頻交互。
* `autobuffer: true`，視頻將在頁面加載時預先加載文件。
您也可以通過將一個視頻數組傳遞給`video_tag`來指定多個要播放的視頻：

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

這將生成：

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### 使用`audio_tag`鏈接到音頻文件

[`audio_tag`][]助手將HTML5 `<audio>`標籤構建到指定的文件。默認情況下，文件從`public/audios`加載。

```erb
<%= audio_tag "music.mp3" %>
```

如果需要，可以提供音頻文件的路徑：

```erb
<%= audio_tag "music/first_song.mp3" %>
```

您還可以提供其他選項的哈希，例如`：id`，`：class`等。

與`video_tag`一樣，`audio_tag`具有特殊選項：

* `autoplay: true`，在頁面加載時開始播放音頻
* `controls: true`，提供由瀏覽器提供的控件，供用戶與音頻交互。
* `autobuffer: true`，音頻將在頁面加載時預先加載文件給用戶。

### 理解`yield`

在佈局的上下文中，`yield`標識了視圖中應該插入的內容的部分。使用最簡單的方法是只有一個`yield`，將正在渲染的整個視圖的內容插入其中：

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

您還可以創建具有多個yield區域的佈局：

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

視圖的主體始終呈現為未命名的`yield`。要將內容呈現到命名的`yield`中，請使用`content_for`方法。

### 使用`content_for`方法

[`content_for`][]方法允許您將內容插入到佈局中的命名`yield`塊中。例如，此視圖將與剛才看到的佈局一起工作：

```html+erb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

將此頁面呈現到提供的佈局中的結果將是以下HTML：

```html+erb
<html>
  <head>
  <title>A simple page</title>
  </head>
  <body>
  <p>Hello, Rails!</p>
  </body>
</html>
```

當佈局包含不同的區域（例如側邊欄和頁腳）時，`content_for`方法非常有用，這些區域應該插入自己的內容塊。它還可用於將加載特定於頁面的JavaScript或CSS文件的標籤插入到否則通用佈局的標頭中。

### 使用局部模板

局部模板 - 通常只稱為“局部” - 是將渲染過程分解為更易管理的塊的另一種方法。使用局部，您可以將渲染特定部分的代碼移動到自己的文件中。

#### 命名局部

要將局部作為視圖的一部分呈現，可以在視圖內使用[`render`][view.render]方法：

```html+erb
<%= render "menu" %>
```

這將在正在渲染的視圖中的該點呈現名為`_menu.html.erb`的文件。請注意前面的下劃線字符：局部以前導下劃線命名，以區別於常視圖，即使在引用時不帶下劃線。即使從另一個文件夾中引入局部，這一點仍然成立：

```html+erb
<%= render "shared/menu" %>
```

該代碼將從`app/views/shared/_menu.html.erb`中引入局部。

#### 使用局部簡化視圖

使用局部的一種方式是將其視為子程序的等效物：一種將詳細信息移出視圖的方式，以便更容易理解正在發生的情況。例如，您可能有一個看起來像這樣的視圖：

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

在這裡，`_ad_banner.html.erb`和`_footer.html.erb`局部可以包含應用程序中許多頁面共享的內容。當您專注於特定頁面時，您不需要看到這些部分的細節。

正如在本指南的前幾節中所見，`yield`是一個非常強大的工具，可以清理佈局。請記住，它是純Ruby，因此您幾乎可以在任何地方使用它。例如，我們可以使用它來簡化幾個相似資源的表單佈局定義：

* `users/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Name contains: <%= form.text_field :name_contains %>
      </p>
    <% end %>
    ```

* `roles/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Title contains: <%= form.text_field :title_contains %>
      </p>
    <% end %>
    ```
* `shared/_search_filters.html.erb`

    ```html+erb
    <%= form_with model: search do |form| %>
      <h1>搜尋表單：</h1>
      <fieldset>
        <%= yield form %>
      </fieldset>
      <p>
        <%= form.submit "搜尋" %>
      </p>
    <% end %>
    ```

提示：對於在應用程式中的所有頁面共享的內容，您可以直接從佈局中使用局部視圖。

#### 局部視圖

局部視圖可以使用自己的佈局文件，就像視圖可以使用佈局一樣。例如，您可以像這樣調用局部視圖：

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

這將尋找名為 `_link_area.html.erb` 的局部視圖並使用 `_graybar.html.erb` 佈局文件呈現它。請注意，局部視圖的佈局遵循與常規局部視圖相同的前導底線命名，並且放置在它們所屬的局部視圖所在的相同文件夾中（而不是主 `layouts` 文件夾中）。

同樣請注意，當傳遞其他選項（如 `:layout`）時，需要明確指定 `:partial`。

#### 傳遞局部變量

您還可以將局部變量傳遞給局部視圖，使其更加強大和靈活。例如，您可以使用此技術來減少新建和編輯頁面之間的重複，同時仍保留一些不同的內容：

* `new.html.erb`

    ```html+erb
    <h1>新建區域</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>編輯區域</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```html+erb
    <%= form_with model: zone do |form| %>
      <p>
        <b>區域名稱</b><br>
        <%= form.text_field :name %>
      </p>
      <p>
        <%= form.submit %>
      </p>
    <% end %>
    ```

儘管相同的局部視圖將呈現在兩個視圖中，但 Action View 的 submit 助手將在新建操作中返回 "創建區域"，在編輯操作中返回 "更新區域"。

要僅在特定情況下將局部變量傳遞給局部視圖，請使用 `local_assigns`。

* `index.html.erb`

    ```erb
    <%= render user.articles %>
    ```

* `show.html.erb`

    ```erb
    <%= render article, full: true %>
    ```

* `_article.html.erb`

    ```erb
    <h2><%= article.title %></h2>

    <% if local_assigns[:full] %>
      <%= simple_format article.body %>
    <% else %>
      <%= truncate article.body %>
    <% end %>
    ```

這樣可以在不需要聲明所有局部變量的情況下使用局部視圖。

每個局部視圖還具有與局部視圖同名的局部變量（去掉前導底線）。您可以通過 `:object` 選項將對象傳遞給此局部變量：

```erb
<%= render partial: "customer", object: @new_customer %>
```

在 `customer` 局部視圖中，`customer` 變量將引用父視圖中的 `@new_customer`。

如果您有一個要渲染到局部視圖中的模型實例，可以使用簡寫語法：

```erb
<%= render @customer %>
```

假設 `@customer` 實例變量包含 `Customer` 模型的一個實例，這將使用 `_customer.html.erb` 來渲染它，並將局部變量 `customer` 傳遞給局部視圖，該局部變量將引用父視圖中的 `@customer` 實例變量。

#### 渲染集合

局部視圖在渲染集合時非常有用。當您通過 `:collection` 選項將集合傳遞給局部視圖時，該局部視圖將為集合中的每個成員插入一次：

* `index.html.erb`

    ```html+erb
    <h1>產品</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>產品名稱： <%= product.name %></p>
    ```

當使用複數形式的集合調用局部視圖時，則局部視圖的各個實例可以通過與局部視圖同名的變量來訪問正在渲染的集合的成員。在這種情況下，局部視圖是 `_product`，在 `_product` 局部視圖內，您可以引用 `product` 來獲取正在渲染的實例。

還有一種簡寫方式。假設 `@products` 是一個 `Product` 實例的集合，您可以在 `index.html.erb` 中簡單地這樣寫以產生相同的結果：

```html+erb
<h1>產品</h1>
<%= render @products %>
```

Rails通過查看集合中的模型名稱來確定要使用的局部視圖的名稱。實際上，您甚至可以創建一個異構集合並以這種方式渲染它，Rails將為集合的每個成員選擇適當的局部視圖：

* `index.html.erb`

    ```html+erb
    <h1>聯繫人</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    ```

* `customers/_customer.html.erb`

    ```html+erb
    <p>客戶： <%= customer.name %></p>
    ```

* `employees/_employee.html.erb`

    ```html+erb
    <p>員工： <%= employee.name %></p>
    ```

在這種情況下，Rails將根據集合的每個成員選擇適當的客戶或員工局部視圖。
如果集合為空，`render`將返回nil，因此提供替代內容應該相對簡單。

```html+erb
<h1>產品</h1>
<%= render(@products) || "目前沒有可用的產品。" %>
```

#### 區域變數

要在局部模板中使用自定義的局部變數名稱，請在調用局部模板時指定`:as`選項：

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

通過這個更改，您可以在局部模板中將`@products`集合的實例作為`item`局部變數進行訪問。

您還可以使用`locals: {}`選項將任意局部變數傳遞給您正在渲染的任何局部模板：

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "產品頁面"} %>
```

在這種情況下，該局部模板將可以訪問具有值"產品頁面"的局部變數`title`。

#### 計數器變數

Rails還在由集合調用的局部模板中提供了一個計數器變數。該變數以局部模板的標題命名，後跟`_counter`。例如，在渲染集合`@products`時，局部模板`_product.html.erb`可以訪問變數`product_counter`。該變數索引了局部模板在封閉視圖中呈現的次數，從第一次呈現開始，其值為`0`。

```erb
# index.html.erb
<%= render partial: "product", collection: @products %>
```

```erb
# _product.html.erb
<%= product_counter %> # 第一個產品為0，第二個產品為1...
```

當使用`as:`選項更改局部模板名稱時，此方法也適用。因此，如果您使用了`as: :item`，則計數器變數將為`item_counter`。

#### 空白模板

您還可以使用`:spacer_template`選項在主要局部模板的實例之間指定要呈現的第二個局部模板：

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails將在每對`_product`局部模板之間呈現`_product_ruler`局部模板（不傳遞任何數據）。

#### 集合局部模板佈局

在渲染集合時，還可以使用`:layout`選項：

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

該佈局將與集合中的每個項目的局部模板一起呈現。當前對象和object_counter變數也將在佈局中可用，就像它們在局部模板中一樣。

### 使用嵌套佈局

您可能會發現您的應用程序需要一個與常規應用程序佈局略有不同的佈局，以支持特定的控制器。您可以通過使用嵌套佈局（有時稱為子模板）來實現這一點，而不是重複主佈局並對其進行編輯。以下是一個示例：

假設您有以下`ApplicationController`佈局：

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "頁面標題" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">頂部菜單項目</div>
      <div id="menu">菜單項目</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

在由`NewsController`生成的頁面上，您想要隱藏頂部菜單並添加一個右側菜單：

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">右側菜單項目</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

就是這樣。News視圖將使用新的佈局，隱藏頂部菜單並在“content”div中添加一個新的右側菜單。

使用此技術可以使用不同的子模板方案獲得類似的結果。請注意，嵌套層級沒有限制。可以使用`ActionView::render`方法通過`render template: 'layouts/news'`在News佈局上構建新的佈局。如果您確定不會對`News`佈局進行子模板化，則可以將`content_for?(:news_content) ? yield(:news_content) : yield`簡化為`yield`。
[controller.render]: https://api.rubyonrails.org/classes/ActionController/Rendering.html#method-i-render
[`redirect_to`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to
[`head`]: https://api.rubyonrails.org/classes/ActionController/Head.html#method-i-head
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`redirect_back`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_back
[`content_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for
[`auto_discovery_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-auto_discovery_link_tag
[`javascript_include_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-javascript_include_tag
[`stylesheet_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-stylesheet_link_tag
[`image_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag
[`video_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-video_tag
[`audio_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-audio_tag
[view.render]: https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render
