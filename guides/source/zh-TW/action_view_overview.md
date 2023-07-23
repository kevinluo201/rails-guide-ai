**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f6b613040c7aed4c76b6648b6fd963cf
Action View 概述
====================

閱讀本指南後，您將了解以下內容：

* Action View 是什麼，以及如何在 Rails 中使用它。
* 如何最佳使用模板、局部視圖和佈局。
* 如何使用本地化視圖。

--------------------------------------------------------------------------------

什麼是 Action View？
--------------------

在 Rails 中，網絡請求由 [Action Controller](action_controller_overview.html) 和 Action View 處理。通常，Action Controller 負責與數據庫通信並執行 CRUD 操作。然後，Action View 負責編譯響應。

Action View 模板使用嵌入的 Ruby 代碼和 HTML 標籤編寫。為了避免模板中充斥著樣板代碼，幾個輔助類提供了常見的表單、日期和字符串操作。同時，隨著應用程序的演進，輕鬆添加新的輔助類也是很容易的。

注意：Action View 的某些功能與 Active Record 相關聯，但這並不意味著 Action View 依賴於 Active Record。Action View 是一個獨立的套件，可以與任何類型的 Ruby 庫一起使用。

使用 Action View 和 Rails
----------------------------

對於每個控制器，`app/views` 目錄中都有一個相應的目錄，其中包含構成與該控制器關聯的視圖的模板文件。這些文件用於顯示每個控制器操作的視圖。

讓我們來看看在使用脚手架生成器創建新資源時，Rails 默認做了什麼：

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

在 Rails 中，視圖有一個命名慣例。通常，視圖與相應的控制器操作共享名稱，就像上面所示的那樣。
例如，`articles_controller.rb` 的 index 控制器操作將使用 `app/views/articles` 目錄中的 `index.html.erb` 視圖文件。
返回給客戶端的完整 HTML 是由這個 ERB 文件、包裝它的佈局模板以及視圖可能引用的所有局部視圖組成的。在本指南中，您將找到有關這三個組件的更詳細的文檔。

正如前面提到的，最終的 HTML 輸出是由三個 Rails 元素組成的：`模板`、`局部視圖` 和 `佈局`。
以下是對每個組件的簡要概述。

模板
---------

Action View 模板可以以多種方式編寫。如果模板文件的擴展名是 `.erb`，則使用 ERB（嵌入式 Ruby）和 HTML 的混合。如果模板文件的擴展名是 `.builder`，則使用 `Builder::XmlMarkup` 庫。

Rails 支持多個模板系統，並使用文件擴展名來區分它們。例如，使用 ERB 模板系統的 HTML 文件的文件擴展名為 `.html.erb`。

### ERB

在 ERB 模板中，可以使用 `<% %>` 和 `<%= %>` 標籤包含 Ruby 代碼。`<% %>` 標籤用於執行不返回任何內容的 Ruby 代碼，例如條件、循環或塊，而 `<%= %>` 標籤用於輸出。

考慮以下的名字循環：

```html+erb
<h1>所有人的名字</h1>
<% @people.each do |person| %>
  名字： <%= person.name %><br>
<% end %>
```

該循環使用常規嵌入標籤（`<% %>`）設置，並使用輸出嵌入標籤（`<%= %>`）插入名字。請注意，這不僅僅是一個使用建議：常規輸出函數（如 `print` 和 `puts`）不會在 ERB 模板中呈現到視圖中。所以這是錯誤的：

```html+erb
<%# 錯誤 %>
嗨，Frodo 先生：<% puts "Frodo" %>
```

為了抑制前導和尾隨的空格，您可以在 `<%` 和 `%>` 之間互換使用 `<%-` `-%>`。

### Builder

Builder 模板是 ERB 的一個更具程序性的替代方案。它們尤其適用於生成 XML 內容。具有 `.builder` 擴展名的模板會自動提供一個名為 `xml` 的 XmlMarkup 對象。

以下是一些基本示例：

```ruby
xml.em("強調")
xml.em { xml.b("強調且粗體") }
xml.a("連結", "href" => "https://rubyonrails.org")
xml.target("name" => "compile", "option" => "fast")
```

這將產生：

```html
<em>強調</em>
<em><b>強調且粗體</b></em>
<a href="https://rubyonrails.org">連結</a>
<target option="fast" name="compile" />
```

帶有塊的任何方法都將被視為帶有嵌套標記的 XML 標記。例如，以下內容：
```ruby
xml.div {
  xml.h1(@person.name)
  xml.p(@person.bio)
}
```

會產生像這樣的結果：

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>A product of Danish Design during the Winter of '79...</p>
</div>
```

以下是實際在Basecamp上使用的完整RSS範例：

```ruby
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@feed_title)
    xml.link(@url)
    xml.description "Basecamp: 最新項目"
    xml.language "en-us"
    xml.ttl "40"

    for item in @recent_items
      xml.item do
        xml.title(item_title(item))
        xml.description(item_description(item)) if item_description(item)
        xml.pubDate(item_pubDate(item))
        xml.guid(@person.firm.account.url + @recent_items.url(item))
        xml.link(@person.firm.account.url + @recent_items.url(item))
        xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
      end
    end
  end
end
```

### Jbuilder

[Jbuilder](https://github.com/rails/jbuilder)是由Rails團隊維護並包含在預設的Rails `Gemfile`中的一個gem。它類似於Builder，但用於生成JSON，而不是XML。

如果您沒有安裝它，可以將以下代碼添加到您的`Gemfile`中：

```ruby
gem 'jbuilder'
```

模板中會自動提供一個名為`json`的Jbuilder對象，該對象用於具有`.jbuilder`擴展名的模板。

以下是一個基本示例：

```ruby
json.name("Alex")
json.email("alex@example.com")
```

會生成：

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

有關更多示例和信息，請參閱[Jbuilder文檔](https://github.com/rails/jbuilder#jbuilder)。

### 模板緩存

默認情況下，Rails會將每個模板編譯為一個方法來渲染它。在開發環境中，當您更改模板時，Rails會檢查文件的修改時間並重新編譯它。

局部模板
--------

局部模板 - 通常只稱為"局部" - 是將渲染過程分解為更可管理的塊的另一種方法。使用局部，您可以從模板中提取代碼片段到單獨的文件中，並在整個模板中重複使用它們。

### 渲染局部

要在視圖的一部分中呈現局部，可以在視圖內使用`render`方法：

```erb
<%= render "menu" %>
```

這將在正在渲染的視圖中的該點呈現名為`_menu.html.erb`的文件。請注意前面的下劃線字符：局部模板以前導下劃線來區分它們與常規視圖，即使它們在引用時不帶下劃線。即使從另一個文件夾中提取局部，這一點仍然成立：

```erb
<%= render "shared/menu" %>
```

該代碼將從`app/views/shared/_menu.html.erb`中提取局部。

### 使用局部簡化視圖

使用局部的一種方式是將它們視為子程序的等效物；一種將細節從視圖中移出的方式，以便您可以更容易地理解正在發生的事情。例如，您可能有一個如下所示的視圖：

```html+erb
<%= render "shared/ad_banner" %>

<h1>產品</h1>

<p>這裡有一些我們的優質產品：</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "shared/footer" %>
```

在這裡，`_ad_banner.html.erb`和`_footer.html.erb`局部可以包含在應用程序中的許多頁面之間共享的內容。當您專注於特定頁面時，您不需要看到這些部分的細節。

### `render`不使用`partial`和`locals`選項

在上面的示例中，`render`使用了2個選項：`partial`和`locals`。但是，如果這些是您要傳遞的唯一選項，則可以跳過使用這些選項。例如，不使用：

```erb
<%= render partial: "product", locals: { product: @product } %>
```

您也可以這樣做：

```erb
<%= render "product", product: @product %>
```

### `as`和`object`選項

默認情況下，`ActionView::Partials::PartialRenderer`將其對象放在與模板同名的局部變量中。因此，給定：

```erb
<%= render partial: "product" %>
```

在`_product`局部中，我們將在局部變量`product`中得到`@product`，就好像我們寫了：

```erb
<%= render partial: "product", locals: { product: @product } %>
```

`object`選項可用於直接指定要渲染到局部的對象；當模板的對象在其他地方時（例如在不同的實例變量或局部變量中）很有用。

例如，不使用：

```erb
<%= render partial: "product", locals: { product: @item } %>
```

我們可以這樣做：

```erb
<%= render partial: "product", object: @item %>
```

使用`as`選項，我們可以為該局部變量指定不同的名稱。例如，如果我們希望它是`item`而不是`product`，我們可以這樣做：

```erb
<%= render partial: "product", object: @item, as: "item" %>
```

這相當於
```erb
<%= render partial: "product", locals: { item: @item } %>
```

### 渲染集合

通常，模板需要遍歷一個集合並為集合中的每個元素渲染一個子模板。這個模式已經被實現為一個方法，該方法接受一個數組並為數組中的每個元素渲染一個局部模板。

所以，渲染所有產品的例子：

```erb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

可以簡化為一行：

```erb
<%= render partial: "product", collection: @products %>
```

當使用集合調用局部模板時，局部模板的各個實例可以通過以局部模板命名的變量訪問正在渲染的集合成員。在這個例子中，局部模板是 `_product`，在其中，您可以引用 `product` 來獲取正在渲染的集合成員。

您可以使用簡寫語法來渲染集合。假設 `@products` 是一個 `Product` 實例的集合，您可以簡單地寫以下內容以產生相同的結果：

```erb
<%= render @products %>
```

Rails 通過查看集合中的模型名稱（在這個例子中是 `Product`）來確定要使用的局部模板的名稱。事實上，您甚至可以使用這個簡寫來渲染由不同模型的實例組成的集合，Rails 將為集合的每個成員選擇適當的局部模板。

### 空格模板

您還可以通過使用 `:spacer_template` 選項在主要局部模板的實例之間指定要渲染的第二個局部模板：

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails 將在每對 `_product` 局部模板之間渲染 `_product_ruler` 局部模板（不傳遞任何數據給它）。

### 嚴格的局部變量

默認情況下，模板將接受任何 `locals` 作為關鍵字參數。要定義模板接受的 `locals`，請添加一個 `locals` 魔術註釋：

```erb
<%# locals: (message:) -%>
<%= message %>
```

也可以提供默認值：

```erb
<%# locals: (message: "Hello, world!") -%>
<%= message %>
```

或者完全禁用 `locals`：

```erb
<%# locals: () %>
```

佈局
-------

佈局可用於在 Rails 控制器操作的結果周圍呈現一個常見的視圖模板。通常，Rails 應用程序會有幾個佈局，頁面將在其中呈現。例如，一個網站可能有一個用於已登錄用戶的佈局，另一個用於營銷或銷售部分的佈局。已登錄用戶佈局可能包含應該在許多控制器操作中存在的頂級導航。SaaS 應用程序的銷售佈局可能包含像“價格”和“聯繫我們”頁面的頂級導航。您期望每個佈局都有不同的外觀和感覺。您可以在[佈局和渲染](https://guides.ruby-china.org/layouts_and_rendering.html)指南中詳細了解佈局。

### 局部佈局

局部可以應用自己的佈局。這些佈局與應用於控制器操作的佈局不同，但它們的工作方式類似。

假設我們在頁面上顯示一篇文章，該文章應該被包裹在一個 `div` 中以供顯示。首先，我們將創建一個新的 `Article`：

```ruby
Article.create(body: '局部佈局很酷！')
```

在 `show` 模板中，我們將渲染 `_article` 局部模板並應用 `box` 佈局：

**articles/show.html.erb**

```erb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

`box` 佈局只是在 `_article` 局部模板中包裹一個 `div`：

**articles/_box.html.erb**

```html+erb
<div class='box'>
  <%= yield %>
</div>
```

請注意，局部佈局可以訪問傳遞給 `render` 調用的局部變量 `article`。但是，與應用程序範圍的佈局不同，局部佈局仍然具有下劃線前綴。

您還可以在局部佈局中渲染一個代碼塊，而不是調用 `yield`。例如，如果我們沒有 `_article` 局部模板，我們可以這樣做：

**articles/show.html.erb**

```html+erb
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

假設我們使用上面的相同 `_box` 局部模板，這將產生與前面的示例相同的輸出。

視圖路徑
----------

在渲染響應時，控制器需要解析不同視圖的位置。默認情況下，它只查找 `app/views` 目錄中的視圖。
我們可以使用 `prepend_view_path` 和 `append_view_path` 方法來添加其他位置並給予它們特定的優先順序，以便在解析路徑時使用。

### Prepend View Path

這在我們想要將視圖放在不同目錄下的子域名中時非常有用。

我們可以這樣做：

```ruby
prepend_view_path "app/views/#{request.subdomain}"
```

然後，Action View 在解析視圖時會首先查找此目錄。

### Append View Path

同樣地，我們可以添加路徑：

```ruby
append_view_path "app/views/direct"
```

這將在查找路徑的末尾添加 `app/views/direct`。

Helpers
-------

Rails 提供了許多與 Action View 一起使用的輔助方法。這些方法包括：

* 格式化日期、字符串和數字
* 創建指向圖片、視頻、樣式表等的 HTML 鏈接
* 清理內容
* 創建表單
* 本地化內容

您可以在 [Action View Helpers Guide](action_view_helpers.html) 和 [Action View Form Helpers Guide](form_helpers.html) 中了解更多有關輔助方法的信息。

本地化視圖
---------------

Action View 具有根據當前語言環境渲染不同模板的功能。

例如，假設您有一個 `ArticlesController`，其中包含一個 show 動作。默認情況下，調用此動作將渲染 `app/views/articles/show.html.erb`。但是，如果您設置 `I18n.locale = :de`，則將渲染 `app/views/articles/show.de.html.erb`。如果找不到本地化模板，則將使用未修飾的版本。這意味著您不需要為所有情況提供本地化視圖，但如果有可用的話，它們將被優先使用。

您可以使用相同的技術來本地化公共目錄中的救援文件。例如，設置 `I18n.locale = :de` 並創建 `public/500.de.html` 和 `public/404.de.html`，這將允許您擁有本地化的救援頁面。

由於 Rails 不限制您用於設置 I18n.locale 的符號，因此您可以利用此系統根據您喜歡的任何內容顯示不同的內容。例如，假設您有一些“專家”用戶應該看到與“普通”用戶不同的頁面。您可以將以下代碼添加到 `app/controllers/application_controller.rb` 中：

```ruby
before_action :set_expert_locale

def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
```

然後，您可以創建特殊的視圖，例如 `app/views/articles/show.expert.html.erb`，這些視圖只會顯示給專家用戶。

您可以在 [Rails Internationalization (I18n) API](i18n.html) 中閱讀更多關於 Rails 國際化 (I18n) 的信息。
