**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 975163c53746728404fb3a3658fbd0f6
Action View 表單輔助程式
========================

在網路應用程式中，表單是用戶輸入的重要介面。然而，由於需要處理表單控制項的命名和眾多屬性，表單標記很容易變得冗長且難以維護。Rails 通過提供視圖輔助程式來解決這個複雜性。然而，由於這些輔助程式有不同的用例，開發人員在使用之前需要了解輔助方法之間的差異。

閱讀本指南後，您將了解：

* 如何創建搜索表單和類似的通用表單，這些表單不代表應用程序中的任何特定模型。
* 如何創建以模型為中心的表單，用於創建和編輯特定的數據庫記錄。
* 如何從多種類型的數據生成下拉框。
* Rails 提供了哪些日期和時間輔助程式。
* 文件上傳表單的不同之處。
* 如何將表單發送到外部資源並指定設置 `authenticity_token`。
* 如何構建複雜的表單。

--------------------------------------------------------------------------------

注意：本指南不旨在完整記錄所有可用的表單輔助程式及其參數。請參閱 [Rails API 文件](https://api.rubyonrails.org/classes/ActionView/Helpers.html) 以獲取所有可用輔助程式的完整參考。

處理基本表單
------------------------

主要的表單輔助程式是 [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)。

```erb
<%= form_with do |form| %>
  表單內容
<% end %>
```

當像這樣不帶參數調用時，它會創建一個表單標記，當提交時將 POST 到當前頁面。例如，假設當前頁面是首頁，生成的 HTML 如下所示：

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  表單內容
</form>
```

您會注意到 HTML 包含一個類型為 `hidden` 的 `input` 元素。這個 `input` 很重要，因為非 GET 表單在沒有它的情況下無法成功提交。
名為 `authenticity_token` 的隱藏輸入元素是 Rails 的一個名為**跨站請求偽造保護**的安全功能，表單輔助程式會為每個非 GET 表單生成它（前提是啟用了此安全功能）。您可以在 [保護 Rails 應用程式](security.html#cross-site-request-forgery-csrf) 指南中了解更多信息。

### 通用搜索表單

網絡上最基本的表單之一是搜索表單。該表單包含：

* 一個使用 "GET" 方法的表單元素，
* 一個用於輸入的標籤，
* 一個文本輸入元素，以及
* 一個提交元素。

要創建此表單，您將使用 `form_with` 和它產生的表單構建器對象。如下所示：

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Search for:" %>
  <%= form.text_field :query %>
  <%= form.submit "Search" %>
<% end %>
```

這將生成以下 HTML：

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Search for:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Search" data-disable-with="Search" />
</form>
```

提示：將 `url: my_specified_path` 傳遞給 `form_with` 可以告訴表單在哪裡發送請求。然而，如下所述，您也可以將 Active Record 對象傳遞給表單。

提示：對於每個表單輸入，都會從其名稱（上面示例中的 `"query"`）生成一個 ID 屬性。這些 ID 對於使用 CSS 進行樣式設置或使用 JavaScript 操作表單控制項非常有用。
重要提示：在搜索表單中使用"GET"作為方法。這樣可以讓用戶將特定的搜索加入書籤並返回。更一般地，Rails鼓勵您使用正確的HTTP動詞執行操作。

### 生成表單元素的輔助方法

`form_with`生成的表單生成器對象提供了許多輔助方法，用於生成文本字段、勾選框和單選按鈕等表單元素。這些方法的第一個參數始終是輸入的名稱。當提交表單時，名稱將與表單數據一起傳遞，並通過用戶為該字段輸入的值傳遞到控制器的`params`中。例如，如果表單包含`<%= form.text_field :query %>`，那麼您可以在控制器中通過`params[:query]`獲取此字段的值。

在命名輸入時，Rails使用某些慣例，使得可以提交具有非標量值（例如數組或哈希）的參數，這些參數也可以在`params`中訪問。您可以在本指南的[理解參數命名慣例](#understanding-parameter-naming-conventions)部分中閱讀更多相關信息。有關這些輔助方法的具體用法詳情，請參閱[API文檔](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)。

#### 勾選框

勾選框是一種表單控件，用戶可以啟用或禁用一組選項：

```erb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "我有一隻狗" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "我有一隻貓" %>
```

這將生成以下代碼：

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">我有一隻狗</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">我有一隻貓</label>
```

[`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box)的第一個參數是輸入的名稱。勾選框的值（將出現在`params`中的值）可以使用第三個和第四個參數進行指定。詳情請參閱API文檔。

#### 單選按鈕

單選按鈕與勾選框類似，但是它們是一組互斥的選項（即，用戶只能選擇其中一個）：

```erb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "我未滿21歲" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "我已滿21歲" %>
```

輸出：

```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">我未滿21歲</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">我已滿21歲</label>
```

[`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button)的第二個參數是輸入的值。由於這兩個單選按鈕共享相同的名稱（`age`），用戶只能選擇其中一個，`params[:age]`將包含`"child"`或`"adult"`。

注意：始終為勾選框和單選按鈕使用標籤。它們將文本與特定選項關聯起來，並通過擴大可點擊區域，使用戶更容易點擊輸入。

### 其他有用的輔助方法

其他值得一提的表單控件包括文本區域、隱藏字段、密碼字段、數字字段、日期和時間字段等等：

```erb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```
輸出：

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```

隱藏的輸入欄位不會顯示給使用者，而是像任何文字輸入一樣保存資料。它們內部的值可以使用 JavaScript 進行更改。

重要提示：搜尋、電話、日期、時間、顏色、日期時間、月份、週、URL、電子郵件、數字和範圍輸入是 HTML5 控制項。如果您希望應用在舊版瀏覽器中具有一致的體驗，則需要使用 HTML5 polyfill（由 CSS 和/或 JavaScript 提供）。當然，[有很多解決方案](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills)可供選擇，目前很受歡迎的工具是 [Modernizr](https://modernizr.com/)，它提供了一種基於檢測到的 HTML5 功能存在與否的簡單方法來添加功能。

提示：如果您使用密碼輸入欄位（無論用途如何），您可能希望配置應用程序以防止記錄這些參數。您可以在[保護 Rails 應用程序](security.html#logging)指南中了解更多信息。

處理模型對象
--------------------------

### 將表單綁定到對象

`form_with` 的 `:model` 參數允許我們將表單生成器對象綁定到模型對象。這意味著表單將限定在該模型對象範圍內，並且表單的字段將填充為該模型對象的值。

例如，如果我們有一個 `@article` 模型對象，如下所示：

```ruby
@article = Article.find(42)
# => #<Article id: 42, title: "My Title", body: "My Body">
```

以下表單：

```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

輸出：

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="My Title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    My Body
  </textarea>
  <input type="submit" name="commit" value="Update Article" data-disable-with="Update Article">
</form>
```

這裡有幾個要注意的地方：

* 表單的 `action` 屬性會自動填充為 `@article` 的適當值。
* 表單字段會自動填充為 `@article` 中對應的值。
* 表單字段的名稱會以 `article[...]` 作為作用域。這意味著 `params[:article]` 將是一個包含所有這些字段值的哈希。您可以在本指南的 [理解參數命名慣例](#understanding-parameter-naming-conventions) 章節中閱讀更多關於輸入名稱的重要性的信息。
* 提交按鈕會自動獲得適當的文本值。

提示：按照慣例，您的輸入字段應與模型屬性相對應。但是，這不是必需的！如果您需要其他信息，您可以像處理屬性一樣在表單中包含它，並通過 `params[:article][:my_nifty_non_attribute_input]` 進行訪問。

#### `fields_for` 輔助方法

[`fields_for`][] 輔助方法創建了一個類似的綁定，但不會渲染 `<form>` 標籤。這可用於在同一表單中為其他模型對象渲染字段。例如，如果您有一個 `Person` 模型和一個關聯的 `ContactDetail` 模型，您可以像這樣為兩者創建一個單一表單：
```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

產生以下輸出：

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

`fields_for` 所產生的物件是一個表單建立器，就像 `form_with` 所產生的一樣。

### 依賴於記錄識別

Article 模型直接對應應用程式的使用者，所以 - 遵循 Rails 開發的最佳實踐 - 您應該將其聲明為**資源**：

```ruby
resources :articles
```

提示：聲明資源會產生一些副作用。請參閱 [Rails Routing from the Outside In](routing.html#resource-routing-the-rails-default) 指南，以獲取有關設置和使用資源的更多資訊。

在處理 RESTful 資源時，如果依賴於**記錄識別**，則 `form_with` 的調用可以變得更加簡單。簡而言之，您只需傳遞模型實例，Rails 就會自動解析模型名稱和其他內容。在這兩個示例中，長式和短式的結果相同：

```ruby
## 建立新文章
# 長式：
form_with(model: @article, url: articles_path)
# 短式：
form_with(model: @article)

## 編輯現有文章
# 長式：
form_with(model: @article, url: article_path(@article), method: "patch")
# 短式：
form_with(model: @article)
```

請注意，短式的 `form_with` 調用非常方便，無論記錄是新的還是現有的，都是相同的。記錄識別足夠聰明，可以通過 `record.persisted?` 來判斷記錄是否為新記錄。它還會選擇正確的提交路徑和基於對象類別的名稱。

如果您有一個[單數資源](routing.html#singular-resources)，您需要調用 `resource` 和 `resolve` 以使其與 `form_with` 配合使用：

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

警告：如果您的模型使用 STI（單表繼承），並且只有其父類別被聲明為資源，則無法依賴於子類別的記錄識別。您必須明確指定 `:url` 和 `:scope`（模型名稱）。

#### 處理命名空間

如果您創建了命名空間路由，`form_with` 也有一個簡便的快捷方式。如果您的應用程式有一個 admin 命名空間，則

```ruby
form_with model: [:admin, @article]
```

將創建一個提交到 admin 命名空間內的 `ArticlesController` 的表單（在更新的情況下，提交到 `admin_article_path(@article)`）。如果您有多層命名空間，語法類似：

```ruby
form_with model: [:admin, :management, @article]
```

有關 Rails 的路由系統和相關慣例的更多資訊，請參閱 [Rails Routing from the Outside In](routing.html) 指南。

### PATCH、PUT 或 DELETE 方法的表單如何工作？

Rails 框架鼓勵您以 RESTful 的方式設計應用程式，這意味著您將會發出許多 "PATCH"、"PUT" 和 "DELETE" 請求（除了 "GET" 和 "POST"）。然而，大多數瀏覽器在提交表單時**不支援**除了 "GET" 和 "POST" 之外的其他方法。

Rails 通過在名為 `"_method"` 的隱藏輸入中模擬其他方法（該輸入的值反映所需的方法），來解決此問題：

```ruby
form_with(url: search_path, method: "patch")
```

輸出:

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->
</form>
```

在解析POST數據時，Rails會考慮到特殊的`_method`參數，並假設HTTP方法是在其中指定的方法（在此例中為“PATCH”）。

在渲染表單時，提交按鈕可以通過`formmethod:`關鍵字覆蓋已聲明的`method`屬性：

```erb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Delete", formmethod: :delete, data: { confirm: "Are you sure?" } %>
  <%= form.button "Update" %>
<% end %>
```

與`<form>`元素類似，大多數瀏覽器不支持除“GET”和“POST”之外的[formmethod][]中聲明的覆蓋表單方法。

Rails通過結合[formmethod][]、[value][button-value]和[name][button-name]屬性來模擬POST之外的其他方法：

```html
<form accept-charset="UTF-8" action="/posts/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->

  <button type="submit" formmethod="post" name="_method" value="delete" data-confirm="Are you sure?">Delete</button>
  <button type="submit" name="button">Update</button>
</form>
```


輕鬆製作選擇框
-----------------------------

在HTML中，選擇框需要大量的標記 - 每個選項都需要一個`<option>`元素。因此，Rails提供了幫助方法來減輕這個負擔。

例如，假設我們有一個城市列表供用戶選擇。我們可以使用[`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select)幫助方法，如下所示：

```erb
<%= form.select :city, ["Berlin", "Chicago", "Madrid"] %>
```

輸出:

```html
<select name="city" id="city">
  <option value="Berlin">Berlin</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```

我們還可以指定與標籤不同的`<option>`值：

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
```

輸出:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

這樣，用戶將看到完整的城市名稱，但`params[:city]`將是`"BE"`、`"CHI"`或`"MD"`之一。

最後，我們可以使用`selected:`參數為選擇框指定默認選擇：

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]], selected: "CHI" %>
```

輸出:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

### 選項組

在某些情況下，我們可能希望通過將`Hash`（或可比較的`Array`）傳遞給`select`來改善用戶體驗，將相關選項分組在一起：

```erb
<%= form.select :city,
      {
        "Europe" => [ ["Berlin", "BE"], ["Madrid", "MD"] ],
        "North America" => [ ["Chicago", "CHI"] ],
      },
      selected: "CHI" %>
```

輸出:

```html
<select name="city" id="city">
  <optgroup label="Europe">
    <option value="BE">Berlin</option>
    <option value="MD">Madrid</option>
  </optgroup>
  <optgroup label="North America">
    <option value="CHI" selected="selected">Chicago</option>
  </optgroup>
</select>
```

### 選擇框和模型對象

與其他表單控件一樣，選擇框可以與模型屬性綁定。例如，如果我們有一個像這樣的`@person`模型對象：

```ruby
@person = Person.new(city: "MD")
```

以下表單：

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
<% end %>
```

輸出的選擇框如下：

```html
<select name="person[city]" id="person_city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD" selected="selected">Madrid</option>
</select>
```

請注意，適當的選項已自動標記為`selected="selected"`。由於此選擇框已綁定到模型，我們不需要指定`:selected`參數！

### 時區和國家選擇

要在Rails中使用時區支援，您必須詢問用戶所在的時區。為此，您需要從預定義的[`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html)對象列表生成選擇選項，但您可以直接使用已經封裝了這個功能的[`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select)輔助方法：

```erb
<%= form.time_zone_select :time_zone %>
```

Rails _曾經_有一個用於選擇國家的`country_select`輔助方法，但這已被提取到[country_select插件](https://github.com/stefanpenner/country_select)中。

使用日期和時間表單輔助方法
--------------------------------

如果您不想使用HTML5的日期和時間輸入框，Rails提供了替代的日期和時間表單輔助方法，可以渲染普通的選擇框。這些輔助方法為每個時間組件（例如年、月、日等）渲染一個選擇框。例如，如果我們有一個像這樣的`@person`模型對象：

```ruby
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

以下表單：

```erb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

輸出的選擇框如下：

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">一月</option>
  <option value="2">二月</option>
  <option value="3">三月</option>
  <option value="4">四月</option>
  <option value="5">五月</option>
  <option value="6">六月</option>
  <option value="7">七月</option>
  <option value="8">八月</option>
  <option value="9">九月</option>
  <option value="10">十月</option>
  <option value="11">十一月</option>
  <option value="12" selected="selected">十二月</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1</option>
  ...
  <option value="21" selected="selected">21</option>
  ...
  <option value="31">31</option>
</select>
```

請注意，當提交表單時，`params`哈希中不會有包含完整日期的單個值。相反，將有幾個具有特殊名稱（如`"birth_date(1i)"`）的值。Active Record知道如何將這些具有特殊名稱的值組合成完整的日期或時間，這取決於模型屬性的聲明類型。因此，我們可以將`params[:person]`傳遞給例如`Person.new`或`Person#update`，就像表單使用單個字段來表示完整日期一樣。

除了[`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select)輔助方法外，Rails還提供了[`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select)和[`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select)。

### 個別時間組件的選擇框

Rails還提供了用於個別時間組件的輔助方法：[`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year)、[`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month)、[`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day)、[`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour)、[`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute)和[`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second)。這些輔助方法是"裸"方法，意味著它們不是在表單生成器實例上調用的。例如：

```erb
<%= select_year 1999, prefix: "party" %>
```

輸出的選擇框如下：

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

對於這些輔助方法的每一個，您可以指定一個日期或時間對象作為默認值，並提取和使用適當的時間組件。

從任意對象集合中生成選擇項
----------------------------------------------

有時，我們希望從一個任意對象集合生成一組選擇項。例如，如果我們有一個`City`模型和相應的`belongs_to :city`關聯：
```ruby
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```

```ruby
City.order(:name).map { |city| [city.name, city.id] }
# => [["柏林", 3], ["芝加哥", 1], ["馬德里", 2]]
```

然後我們可以使用以下表單讓使用者從資料庫中選擇一個城市：

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

注意：當渲染屬於 `belongs_to` 關聯的欄位時，必須指定外鍵的名稱（在上面的例子中是 `city_id`），而不是關聯本身的名稱。

然而，Rails 提供了一些輔助方法，可以從集合中生成選項，而不需要明確地遍歷它。這些輔助方法通過在集合中的每個對象上調用指定的方法來確定每個選項的值和文本標籤。

### `collection_select` 輔助方法

要生成下拉框，我們可以使用 [`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select)：

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

輸出：

```html
<select name="person[city_id]" id="person_city_id">
  <option value="3">柏林</option>
  <option value="1">芝加哥</option>
  <option value="2">馬德里</option>
</select>
```

注意：使用 `collection_select` 時，我們首先指定值方法（在上面的例子中是 `:id`），然後是文本標籤方法（在上面的例子中是 `:name`）。這與為 `select` 輔助方法指定選項時的順序相反，其中文本標籤在前，值在後。

### `collection_radio_buttons` 輔助方法

要生成一組單選按鈕，我們可以使用 [`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons)：

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

輸出：

```html
<input type="radio" name="person[city_id]" value="3" id="person_city_id_3">
<label for="person_city_id_3">柏林</label>

<input type="radio" name="person[city_id]" value="1" id="person_city_id_1">
<label for="person_city_id_1">芝加哥</label>

<input type="radio" name="person[city_id]" value="2" id="person_city_id_2">
<label for="person_city_id_2">馬德里</label>
```

### `collection_check_boxes` 輔助方法

要生成一組勾選框（例如，支持 `has_and_belongs_to_many` 關聯），我們可以使用 [`collection_check_boxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes)：

```erb
<%= form.collection_check_boxes :interest_ids, Interest.order(:name), :id, :name %>
```

輸出：

```html
<input type="checkbox" name="person[interest_id][]" value="3" id="person_interest_id_3">
<label for="person_interest_id_3">工程學</label>

<input type="checkbox" name="person[interest_id][]" value="4" id="person_interest_id_4">
<label for="person_interest_id_4">數學</label>

<input type="checkbox" name="person[interest_id][]" value="1" id="person_interest_id_1">
<label for="person_interest_id_1">科學</label>

<input type="checkbox" name="person[interest_id][]" value="2" id="person_interest_id_2">
<label for="person_interest_id_2">科技</label>
```

上傳文件
---------------

常見的任務之一是上傳某種類型的文件，無論是一個人的照片還是包含要處理的數據的 CSV 文件。文件上傳字段可以使用 [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) 輔助方法渲染。

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

最重要的是要記住，渲染的表單的 `enctype` 屬性必須設置為 "multipart/form-data"。如果在 `form_with` 內部使用 `file_field`，則會自動完成此操作。您也可以手動設置該屬性：

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :picture %>
<% end %>
```

請注意，根據 `form_with` 的慣例，上述兩個表單中的字段名稱也將不同。也就是說，第一個表單中的字段名稱將是 `person[picture]`（可以通過 `params[:person][:picture]` 訪問），而第二個表單中的字段名稱將只是 `picture`（可以通過 `params[:picture]` 訪問）。

### 上傳的內容

`params` 哈希中的對象是 [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html) 的實例。以下代碼片段將上傳的文件保存在 `#{Rails.root}/public/uploads` 目錄下，並使用原始文件的相同名稱保存。
```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

一旦文件上傳完成，就有很多潛在的任務，包括文件存儲位置（在磁盤、Amazon S3等）、與模型關聯、調整圖像文件大小、生成縮略圖等等。[Active Storage](active_storage_overview.html) 專為協助處理這些任務而設計。

自定義表單生成器
----------------

`form_with` 和 `fields_for` 產生的對象是 [`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html) 的實例。表單生成器封裝了為單個對象顯示表單元素的概念。雖然您可以以通常的方式編寫表單的輔助方法，但您也可以創建 `ActionView::Helpers::FormBuilder` 的子類，並在其中添加輔助方法。例如，

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

可以替換為

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

只需定義一個類似下面的 `LabellingFormBuilder` 類：

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    label(attribute) + super
  end
end
```

如果您經常重複使用這個功能，可以定義一個 `labeled_form_with` 輔助方法，自動應用 `builder: LabellingFormBuilder` 選項：

```ruby
def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
  options[:builder] = LabellingFormBuilder
  form_with model: model, scope: scope, url: url, format: format, **options, &block
end
```

使用的表單生成器還決定了當您執行以下操作時會發生什麼：

```erb
<%= render partial: f %>
```

如果 `f` 是 `ActionView::Helpers::FormBuilder` 的實例，則會渲染 `form` 部分，並將該部分的對象設置為表單生成器。如果表單生成器是 `LabellingFormBuilder` 類的實例，則會渲染 `labelling_form` 部分。

理解參數命名慣例
--------------

表單的值可以位於 `params` 散列的頂層，也可以嵌套在另一個散列中。例如，在 Person 模型的標準 `create` 操作中，`params[:person]` 通常是一個包含要創建的 Person 的所有屬性的散列。`params` 散列還可以包含數組、數組的散列等等。

從根本上說，HTML 表單不知道任何結構化數據，它們只生成名稱-值對，其中對是普通字符串。您在應用程序中看到的數組和散列是 Rails 使用的一些參數命名慣例的結果。

### 基本結構

兩種基本結構是數組和散列。散列反映了訪問 `params` 中的值的語法。例如，如果一個表單包含：

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

`params` 散列將包含

```ruby
{ 'person' => { 'name' => 'Henry' } }
```

而 `params[:person][:name]` 將在控制器中檢索提交的值。

散列可以嵌套多層，例如：

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

將導致 `params` 散列為

```ruby
{ 'person' => { 'address' => { 'city' => 'New York' } } }
```

通常情況下，Rails 忽略重複的參數名。如果參數名以一組空方括號 `[]` 結尾，則它們將累積到一個數組中。如果您希望用戶能夠輸入多個電話號碼，可以在表單中放置以下內容：
```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

這將導致`params[:person][:phone_number]`成為包含輸入的電話號碼的陣列。

### 結合它們

我們可以混合和匹配這兩個概念。哈希的一個元素可能是一個陣列，就像前面的例子中一樣，或者你可以有一個哈希的陣列。例如，一個表單可以通過重複以下表單片段來讓您創建任意數量的地址

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

這將導致`params[:person][:addresses]`成為一個包含鍵為`line1`、`line2`和`city`的哈希的陣列。

然而，有一個限制：雖然哈希可以任意嵌套，但只允許一層的"陣列性"。陣列通常可以被哈希替換；例如，可以將模型對象的陣列替換為以其id、陣列索引或其他參數為鍵的模型對象的哈希。

警告：陣列參數與`check_box`輔助程序不相容。根據HTML規範，未選中的複選框不提交任何值。然而，複選框總是提交一個值往往很方便。`check_box`輔助程序通過創建具有相同名稱的輔助隱藏輸入來模擬這一點。如果複選框未選中，只有隱藏輸入被提交，如果選中，則兩者都被提交，但複選框提交的值優先。

### `fields_for`輔助程序的`:index`選項

假設我們想要渲染一個表單，其中包含每個人的一組地址字段。[`fields_for`][]輔助程序及其`:index`選項可以提供幫助：

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

假設該人有ID為23和45的兩個地址，上面的表單將渲染類似以下的輸出：

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

這將導致一個類似以下的`params`哈希：

```ruby
{
  "person" => {
    "name" => "Bob",
    "address" => {
      "23" => {
        "city" => "Paris"
      },
      "45" => {
        "city" => "London"
      }
    }
  }
}
```

所有的表單輸入都映射到`"person"`哈希，因為我們在`person_form`表單構建器上調用了`fields_for`。同時，通過指定`index: address.id`，我們將每個城市輸入的`name`屬性渲染為`person[address][#{address.id}][city]`而不是`person[address][city]`。因此，我們能夠在處理`params`哈希時確定應該修改哪些地址記錄。

您可以通過`:index`選項傳遞其他重要的數字或字符串。您甚至可以傳遞`nil`，這將生成一個陣列參數。

要創建更複雜的嵌套，您可以明確指定輸入名稱的前面部分。例如：

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```
將創建輸入如下：

```html
<input id="person_address_primary_23_city" name="person[address][primary][23][city]" type="text" value="巴黎" />
```

您也可以直接將 `:index` 選項傳遞給輔助函數，例如 `text_field`，但通常在表單生成器級別指定這一點比在個別輸入字段上指定更少重複。

一般來說，最終的輸入名稱將是 `fields_for` / `form_with` 指定的名稱、`:index` 選項值和屬性名稱的連接。

最後，作為一個快捷方式，可以在 `:index`（例如 `index: address.id`）中指定一個 ID，您可以將 `"[]"` 附加到給定的名稱。例如：

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

產生與我們原來的示例完全相同的輸出。

將表單提交到外部資源
---------------------------

Rails 的表單輔助函數也可以用於構建提交數據到外部資源的表單。但是，有時需要為資源設置一個 `authenticity_token`；這可以通過將 `authenticity_token: 'your_external_token'` 參數傳遞給 `form_with` 選項來完成：

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  表單內容
<% end %>
```

有時，當將數據提交到外部資源（如支付網關）時，表單中可以使用的字段受到外部 API 的限制，並且生成 `authenticity_token` 可能是不可取的。要不發送令牌，只需將 `:authenticity_token` 選項設置為 `false`：

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  表單內容
<% end %>
```

構建複雜表單
----------------------

許多應用程序超出了編輯單個對象的簡單表單。例如，當創建一個 `Person` 時，您可能希望允許用戶在同一表單上創建多個地址記錄（家庭、工作等）。當以後編輯該人時，用戶應該能夠根據需要添加、刪除或修改地址。

### 配置模型

Active Record 通過 [`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for) 方法提供了模型級別的支持：

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses
end

class Address < ApplicationRecord
  belongs_to :person
end
```

這在 `Person` 上創建了一個 `addresses_attributes=` 方法，允許您創建、更新和（可選地）刪除地址。

### 嵌套表單

以下表單允許用戶創建一個 `Person` 及其相關聯的地址。

```html+erb
<%= form_with model: @person do |form| %>
  地址：
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

當關聯接受嵌套屬性時，`fields_for` 會為關聯的每個元素渲染其區塊。特別是，如果一個人沒有地址，它將不會渲染任何內容。一個常見的模式是控制器構建一個或多個空的子元素，以便至少向用戶顯示一組字段。下面的示例將在新人表單上渲染 2 組地址字段。

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```
`fields_for`會產生一個表單建構器。參數的名稱應該符合`accepts_nested_attributes_for`的預期。例如，當創建一個具有2個地址的使用者時，提交的參數將如下所示：

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

`addresses_attributes`哈希中鍵的實際值並不重要；然而，它們需要是整數的字符串，並且對於每個地址都需要不同的值。

如果關聯對象已經保存，`fields_for`會自動生成一個帶有保存記錄的`id`的隱藏輸入。您可以通過將`include_id: false`傳遞給`fields_for`來禁用此功能。

### 控制器

像往常一樣，在將參數傳遞給模型之前，您需要在控制器中[聲明允許的參數](action_controller_overview.html#strong-parameters)：

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### 刪除對象

您可以通過將`allow_destroy: true`傳遞給`accepts_nested_attributes_for`來允許用戶刪除關聯對象。

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

如果對象的屬性哈希包含具有求值為`true`（例如1、'1'、true或'true'）的`_destroy`鍵，則對象將被刪除。此表單允許用戶刪除地址：

```erb
<%= form_with model: @person do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

不要忘記在控制器中更新允許的參數，以包括`_destroy`字段：

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### 防止空記錄

忽略用戶未填寫的一組字段通常很有用。您可以通過將`reject_if` proc傳遞給`accepts_nested_attributes_for`來控制此行為。此proc將使用表單提交的每個屬性哈希調用。如果proc返回`true`，則Active Record將不會為該哈希構建關聯對象。下面的示例只在設置了`kind`屬性時才嘗試構建地址。

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda { |attributes| attributes['kind'].blank? }
end
```

作為一種便利，您可以傳遞符號`:all_blank`，它將創建一個proc，該proc將拒絕所有屬性都為空（除了`_destroy`的任何值）的記錄。

### 動態添加字段

您可能希望僅在用戶點擊“添加新地址”按鈕時才添加多個字段集。Rails不提供任何內置支持。在生成新的字段集時，您必須確保關聯數組的鍵是唯一的-當前的JavaScript日期（自[紀元](https://en.wikipedia.org/wiki/Unix_time)以來的毫秒數）是一個常見的選擇。

使用標籤輔助程序而不使用表單建構器
----------------------------------------
如果您需要在表單生成器的上下文之外呈現表單字段，Rails 提供了常見表單元素的標籤輔助方法。例如，[`check_box_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-check_box_tag)：

```erb
<%= check_box_tag "accept" %>
```

輸出：

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

通常，這些輔助方法的名稱與其表單生成器對應方法的名稱相同，只是在後面加上 `_tag` 後綴。完整列表請參閱 [`FormTagHelper` API 文件](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)。

使用 `form_tag` 和 `form_for`
-------------------------------

在 Rails 5.1 之前，`form_with` 被引入之前，其功能被分為 [`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag) 和 [`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for) 兩個方法。現在這兩個方法已被軟棄用。有關使用方法的文檔可以在[本指南的舊版本](https://guides.rubyonrails.org/v5.2/form_helpers.html)中找到。
[`fields_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for
[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-formmethod
[button-name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-name
[button-value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-value
