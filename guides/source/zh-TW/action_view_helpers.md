**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37d2486eee8522a64c5f97f86900b8a6
動作視圖輔助程式
====================

閱讀完本指南後，您將了解以下內容：

* 如何格式化日期、字串和數字
* 如何連結圖片、影片、樣式表等等...
* 如何清理內容
* 如何本地化內容

--------------------------------------------------------------------------------

Action View 提供的輔助程式概述
-------------------------------------------

WIP：這裡未列出所有的輔助程式。完整清單請參閱[API 文件](https://api.rubyonrails.org/classes/ActionView/Helpers.html)

以下僅為 Action View 中可用的輔助程式的簡要概述。建議您查閱[API 文件](https://api.rubyonrails.org/classes/ActionView/Helpers.html)，該文件更詳細地介紹了所有的輔助程式，但這裡可以作為一個很好的起點。

### AssetTagHelper

此模組提供了一些方法，用於生成將視圖連結到圖片、JavaScript 檔案、樣式表和訂閱源等資源的 HTML。

預設情況下，Rails 會在公共資料夾中的當前主機上連結到這些資源，但您可以通過在應用程式配置中設置 [`config.asset_host`][]，將 Rails 指向專用的資源伺服器。通常在 `config/environments/production.rb` 中進行設置。例如，假設您的資源主機是 `assets.example.com`：

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```


#### auto_discovery_link_tag

返回一個連結標籤，供瀏覽器和訂閱器用於自動偵測 RSS、Atom 或 JSON 訂閱源。

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

#### image_path

計算 `app/assets/images` 目錄中圖片資源的路徑。完整路徑將通過文件根目錄傳遞。內部由 `image_tag` 使用以建立圖片路徑。

```ruby
image_path("edit.png") # => /assets/edit.png
```

如果設置了 config.assets.digest 為 true，則會在檔名中添加指紋。

```ruby
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

計算 `app/assets/images` 目錄中圖片資源的 URL。這將內部調用 `image_path`，並與當前主機或資源主機合併。

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

返回一個 HTML 圖片標籤。源可以是完整路徑，也可以是存在於 `app/assets/images` 目錄中的檔案。

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

返回每個提供的源的 HTML script 標籤。您可以傳遞存在於 `app/assets/javascripts` 目錄中的 JavaScript 檔案的檔名（`.js` 擴展名是可選的），以將其包含到當前頁面中，或者您可以傳遞相對於文件根目錄的完整路徑。

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

計算 `app/assets/javascripts` 目錄中 JavaScript 資源的路徑。如果源檔名沒有擴展名，將添加 `.js`。完整路徑將通過文件根目錄傳遞。內部由 `javascript_include_tag` 使用以建立腳本路徑。

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

計算 `app/assets/javascripts` 目錄中 JavaScript 資源的 URL。這將內部調用 `javascript_path`，並與當前主機或資源主機合併。

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

返回指定的源的樣式表連結標籤。如果未指定擴展名，將自動添加 `.css`。

```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" rel="stylesheet" />
```

#### stylesheet_path

計算 `app/assets/stylesheets` 目錄中樣式表資源的路徑。如果源檔名沒有擴展名，將添加 `.css`。完整路徑將通過文件根目錄傳遞。內部由 `stylesheet_link_tag` 使用以建立樣式表路徑。

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

計算 `app/assets/stylesheets` 目錄中樣式表資源的 URL。這將內部調用 `stylesheet_path`，並與當前主機或資源主機合併。

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

此輔助程式可輕鬆建立 Atom 訂閱源。以下是完整的使用範例：

**config/routes.rb**

```ruby
resources :articles
```

**app/controllers/articles_controller.rb**

```ruby
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```ruby
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

### BenchmarkHelper

#### benchmark

允許您在模板中測量區塊的執行時間並將結果記錄到日誌中。將此區塊包裹在昂貴的操作或可能的瓶頸周圍，以獲得操作的時間讀數。
```html+erb
<% benchmark "處理資料檔案" do %>
  <%= expensive_files_operation %>
<% end %>
```

這將在日誌中添加類似"處理資料檔案 (0.34523)"的內容，您可以在優化代碼時使用它來比較時間。

### CacheHelper

#### cache

一個用於緩存視圖片段而不是整個操作或頁面的方法。這種技術對於緩存菜單、新聞主題列表、靜態HTML片段等片段非常有用。此方法接受一個包含您要緩存的內容的區塊。有關更多信息，請參見`AbstractController::Caching::Fragments`。

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

`capture`方法允許您將模板的一部分提取到變量中。然後，您可以在模板或佈局中的任何地方使用此變量。

```html+erb
<% @greeting = capture do %>
  <p>歡迎！現在的日期和時間是 <%= Time.now %></p>
<% end %>
```

然後可以在其他地方使用捕獲的變量。

```html+erb
<html>
  <head>
    <title>歡迎！</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### content_for

調用`content_for`將一個標記的塊存儲為標識符以供以後使用。您可以通過將標識符作為`yield`的參數傳遞給其他模板或佈局，對存儲的內容進行後續調用。

例如，假設我們有一個標準的應用佈局，但也有一個特殊的頁面需要某些其他頁面不需要的特定JavaScript。我們可以使用`content_for`在特殊頁面上包含此JavaScript，而不會使其他頁面變得臃腫。

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>歡迎！</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>歡迎！現在的日期和時間是 <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>這是一個特殊頁面。</p>

<% content_for :special_script do %>
  <script>alert('Hello!')</script>
<% end %>
```

### DateHelper

#### distance_of_time_in_words

報告兩個時間或日期對象或整數之間的大致時間間隔（以秒為單位）。如果您想要更詳細的近似值，請將`include_seconds`設置為true。

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => 少於一分鐘
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => 少於20秒
```

#### time_ago_in_words

與`distance_of_time_in_words`類似，但`to_time`固定為`Time.now`。

```ruby
time_ago_in_words(3.minutes.from_now) # => 3 分鐘
```

### DebugHelper

返回一個使用YAML轉儲的對象的`pre`標籤。這創建了一種非常可讀的方式來檢查對象。

```ruby
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1, 2, 3] }
debug(my_hash)
```

```html
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

### FormHelper

表單助手旨在通過提供一組基於模型的方法來創建表單，使與模型一起工作比僅使用標準HTML元素更加容易。此助手生成表單的HTML，為每種類型的輸入（例如文本、密碼、選擇等）提供一種方法。當提交表單（即當用戶點擊提交按鈕或通過JavaScript調用form.submit）時，表單輸入將被打包到params對象中並傳回控制器。

您可以在[Action View Form Helpers
Guide](form_helpers.html)中了解更多有關表單助手的信息。

### JavaScriptHelper

提供在視圖中使用JavaScript的功能。

#### escape_javascript

對於JavaScript片段，對換行符和單引號和雙引號進行轉義。

#### javascript_tag

返回包裝提供的代碼的JavaScript標籤。

```ruby
javascript_tag "alert('All is good')"
```

```html
<script>
//<![CDATA[
alert('All is good')
//]]>
</script>
```

### NumberHelper

提供將數字轉換為格式化字符串的方法。提供了用於電話號碼、貨幣、百分比、精度、位置表示法和文件大小的方法。

#### number_to_currency

將數字格式化為貨幣字符串（例如$13.65）。

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### number_to_human

將數字進行漂亮的打印（格式化和近似），使其對用戶更易讀；對於可能非常大的數字很有用。

```ruby
number_to_human(1234)    # => 1.23 千
number_to_human(1234567) # => 1.23 百萬
```

#### number_to_human_size

將大小（以字節為單位）格式化為更易理解的表示形式；對於向用戶報告文件大小很有用。

```ruby
number_to_human_size(1234)    # => 1.21 KB
number_to_human_size(1234567) # => 1.18 MB
```

#### number_to_percentage

將數字格式化為百分比字符串。
```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

將數字格式化為電話號碼（預設為美國）。

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

使用分隔符號將數字格式化為千分位。

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

使用指定的 `precision` 層級（預設為 3）將數字格式化。

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

SanitizeHelper 模組提供了一組方法，用於清除文本中不需要的 HTML 元素。

#### sanitize

此 sanitize 輔助方法將對所有標籤進行 HTML 編碼，並刪除除了特別允許的屬性之外的所有屬性。

```ruby
sanitize @article.body
```

如果傳遞了 `:attributes` 或 `:tags` 選項，則只允許提到的屬性和標籤，不允許其他任何內容。

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

要更改多個用途的默認值，例如將表格標籤添加到默認值中：

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

清除一段 CSS 代碼。

#### strip_links(html)

從文本中刪除所有連結標籤，只保留連結文字。

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('emails to <a href="mailto:me@email.com">me@email.com</a>.')
# => emails to me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visit</a>.')
# => Blog: Visit.
```

#### strip_tags(html)

從 HTML 中刪除所有標籤，包括註釋。
此功能由 rails-html-sanitizer gem 提供支援。

```ruby
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!
```

```ruby
strip_tags("<b>Bold</b> no more!  <a href='more.html'>See more</a>")
# => Bold no more!  See more
```

注意：輸出可能仍包含未轉義的 '<'、'>' 和 '&' 字符，可能會使瀏覽器混淆。

### UrlHelper

提供了一些方法來生成連結和獲取依賴於路由子系統的 URL。

#### url_for

返回提供的 `options` 集合的 URL。

##### 範例

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

在幕後使用 `url_for` 得到的 URL 連結。主要用於創建 RESTful 資源連結，對於此範例，可以將模型傳遞給 `link_to`。

**範例**

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>
```

如果連結目標無法適應名稱參數，也可以使用區塊。例如 ERB 範例：

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
<% end %>
```

將輸出：

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Check it out!</span>
</a>
```

詳細資訊請參閱[API 文件](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)。

#### button_to

生成一個提交到傳遞的 URL 的表單。該表單具有一個值為 `name` 的提交按鈕。

##### 範例

```html+erb
<%= button_to "Sign in", sign_in_path %>
```

大致輸出如下：

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

詳細資訊請參閱[API 文件](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)。

### CsrfHelper

返回具有跨站請求偽造保護參數和令牌名稱的元標籤 "csrf-param" 和 "csrf-token"。

```html
<%= csrf_meta_tags %>
```

注意：常規表單會生成隱藏字段，因此不使用這些標籤。更多詳細資訊請參閱[Rails 安全指南](security.html#cross-site-request-forgery-csrf)。
[`config.asset_host`]: configuring.html#config-asset-host
