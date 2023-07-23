**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fb66c6f4aafffdb8f8d44e8a2076c9b0
從外部開始的Rails路由
=======================

本指南涵蓋了Rails路由的用戶界面功能。

閱讀本指南後，您將了解：

* 如何解讀`config/routes.rb`中的代碼。
* 如何構建自己的路由，使用首選的資源風格或`match`方法。
* 如何聲明路由參數，這些參數將傳遞給控制器動作。
* 如何使用路由助手自動創建路徑和URL。
* 創建約束和掛載Rack端點等高級技術。

--------------------------------------------------------------------------------

Rails路由器的目的
----------------

Rails路由器識別URL並將其分派給控制器的動作或Rack應用程序。它還可以生成路徑和URL，避免在視圖中硬編碼字符串的需要。

### 將URL連接到代碼

當您的Rails應用程序接收到一個請求：

```
GET /patients/17
```

它會要求路由器將其與控制器動作匹配。如果第一個匹配的路由是：

```ruby
get '/patients/:id', to: 'patients#show'
```

則請求將被分派到`patients`控制器的`show`動作，並帶有`{ id: '17' }`在`params`中。

注意：Rails在這裡使用snake_case作為控制器名稱，如果您有一個多字控制器，例如`MonsterTrucksController`，您可以使用`monster_trucks#show`。

### 從代碼生成路徑和URL

您還可以生成路徑和URL。如果上面的路由修改為：

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

並且您的應用程序在控制器中包含以下代碼：

```ruby
@patient = Patient.find(params[:id])
```

以及在相應的視圖中包含以下代碼：

```erb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

那麼路由器將生成路徑`/patients/17`。這減少了視圖的脆弱性，使您的代碼更容易理解。請注意，路由助手中不需要指定id。

### 配置Rails路由器

您的應用程序或引擎的路由位於文件`config/routes.rb`中，通常如下所示：

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

由於這是一個常規的Ruby源文件，您可以使用它的所有功能來幫助您定義路由，但要小心變量名，因為它們可能與路由器的DSL方法衝突。

注意：包裹路由定義的`Rails.application.routes.draw do ... end`塊是為了建立路由器DSL的範圍，不能刪除。

資源路由：Rails的默認方式
--------------------------

資源路由允許您快速聲明給定資源控制器的所有常見路由。一次調用[`resources`][]可以聲明您的`index`、`show`、`new`、`edit`、`create`、`update`和`destroy`動作所需的所有路由。

### 網絡上的資源

瀏覽器通過使用特定的HTTP方法，如`GET`、`POST`、`PATCH`、`PUT`和`DELETE`，對URL發出請求，從Rails請求頁面。每個方法都是對資源執行操作的請求。資源路由將多個相關的請求映射到單個控制器中的動作。

當您的Rails應用程序接收到一個請求：

```
DELETE /photos/17
```

它會要求路由器將其映射到控制器動作。如果第一個匹配的路由是：

```ruby
resources :photos
```

Rails將將該請求分派給`photos`控制器的`destroy`動作，並在`params`中帶有`{ id: '17' }`。

CRUD、動詞和動作

在Rails中，資源路由提供了HTTP動詞和URL到控制器動作的映射。按照慣例，每個動作還對應到數據庫中的特定CRUD操作。在路由文件中的單個條目，例如：

```ruby
resources :photos
```

在您的應用程序中創建了七個不同的路由，全部映射到`Photos`控制器：

| HTTP動詞 | 路徑             | 控制器#動作 | 用於                                         |
| --------- | ---------------- | ----------------- | -------------------------------------------- |
| GET       | /photos          | photos#index      | 顯示所有照片的列表                 |
| GET       | /photos/new      | photos#new        | 返回創建新照片的HTML表單 |
| POST      | /photos          | photos#create     | 創建新照片                           |
| GET       | /photos/:id      | photos#show       | 顯示特定照片                     |
| GET       | /photos/:id/edit | photos#edit       | 返回編輯照片的HTML表單      |
| PATCH/PUT | /photos/:id      | photos#update     | 更新特定照片                      |
| DELETE    | /photos/:id      | photos#destroy    | 刪除特定照片                      |
注意：因為路由器使用HTTP動詞和URL來匹配入站請求，所以四個URL對應到七個不同的操作。

注意：Rails路由按照它們指定的順序進行匹配，所以如果你在`resources :photos`上方有一個`get 'photos/poll'`，則`resources`行的`show`操作的路由將在`get`行之前匹配。要解決這個問題，將`get`行**移到**`resources`行的上方，以便它首先匹配。

### 路徑和URL助手

創建一個資源路由還會為應用程序中的控制器提供一些助手。以`resources :photos`為例：

* `photos_path`返回`/photos`
* `new_photo_path`返回`/photos/new`
* `edit_photo_path(:id)`返回`/photos/:id/edit`（例如，`edit_photo_path(10)`返回`/photos/10/edit`）
* `photo_path(:id)`返回`/photos/:id`（例如，`photo_path(10)`返回`/photos/10`）

這些助手中的每個都有一個相應的`_url`助手（例如`photos_url`），它返回帶有當前主機、端口和路徑前綴的相同路徑。

提示：要查找路由的路由助手名稱，請參閱下面的[列出現有路由](#列出現有路由)。

### 同時定義多個資源

如果您需要為多個資源創建路由，可以通過一次調用`resources`來節省一些輸入：

```ruby
resources :photos, :books, :videos
```

這與以下完全相同：

```ruby
resources :photos
resources :books
resources :videos
```

### 單數資源

有時，您有一個資源，客戶端總是查找而不引用ID。例如，您希望`/profile`始終顯示當前登錄用戶的個人資料。在這種情況下，您可以使用單數資源將`/profile`（而不是`/profile/:id`）映射到`show`操作：

```ruby
get 'profile', to: 'users#show'
```

將`String`傳遞給`to:`將期望`controller#action`格式。使用`Symbol`時，`to:`選項應替換為`action:`。在不帶`#`的`String`的情況下，`to:`選項應替換為`controller:`：

```ruby
get 'profile', action: :show, controller: 'users'
```

這個資源路由：

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

在應用程序中創建了六個不同的路由，都映射到`Geocoders`控制器：

| HTTP動詞 | 路徑                | 控制器#操作        | 用於                                          |
| --------- | ------------------- | ----------------- | --------------------------------------------- |
| GET       | /geocoder/new       | geocoders#new     | 返回用於創建地理編碼器的HTML表單              |
| POST      | /geocoder           | geocoders#create  | 創建新的地理編碼器                            |
| GET       | /geocoder           | geocoders#show    | 顯示唯一的地理編碼器資源                      |
| GET       | /geocoder/edit      | geocoders#edit    | 返回用於編輯地理編碼器的HTML表單              |
| PATCH/PUT | /geocoder           | geocoders#update  | 更新唯一的地理編碼器資源                      |
| DELETE    | /geocoder           | geocoders#destroy | 刪除地理編碼器資源                            |

注意：因為您可能希望將同一個控制器用於單數路由（`/account`）和複數路由（`/accounts/45`），單數資源將映射到複數控制器。因此，例如，`resource :photo`和`resources :photos`創建了既有單數路由又有複數路由，它們都映射到同一個控制器（`PhotosController`）。

單數資源路由生成以下助手：

* `new_geocoder_path`返回`/geocoder/new`
* `edit_geocoder_path`返回`/geocoder/edit`
* `geocoder_path`返回`/geocoder`

注意：調用`resolve`對於通過[記錄識別](form_helpers.html#relying-on-record-identification)將`Geocoder`的實例轉換為路由是必需的。

與複數資源一樣，以`_url`結尾的相同助手也將包括主機、端口和路徑前綴。

### 控制器命名空間和路由

您可能希望在一個命名空間下組織一組控制器。最常見的情況是將一些管理控制器分組到`Admin::`命名空間下，並將這些控制器放在`app/controllers/admin`目錄下。您可以使用[`namespace`][]塊來路由到這樣的一組控制器：

```ruby
namespace :admin do
  resources :articles, :comments
end
```

這將為每個`articles`和`comments`控制器創建多個路由。對於`Admin::ArticlesController`，Rails將創建：

| HTTP動詞 | 路徑                      | 控制器#操作           | 命名路由助手               |
| --------- | ------------------------- | --------------------- | -------------------------- |
| GET       | /admin/articles           | admin/articles#index  | admin_articles_path        |
| GET       | /admin/articles/new       | admin/articles#new    | new_admin_article_path     |
| POST      | /admin/articles           | admin/articles#create | admin_articles_path        |
| GET       | /admin/articles/:id       | admin/articles#show   | admin_article_path(:id)    |
| GET       | /admin/articles/:id/edit  | admin/articles#edit   | edit_admin_article_path(:id)|
| PATCH/PUT | /admin/articles/:id       | admin/articles#update | admin_article_path(:id)    |
| DELETE    | /admin/articles/:id       | admin/articles#destroy| admin_article_path(:id)    |
如果您想將 `/articles`（不包含前綴 `/admin`）路由到 `Admin::ArticlesController`，您可以使用 [`scope`][] 區塊指定模組：

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

這也可以用於單個路由：

```ruby
resources :articles, module: 'admin'
```

如果您想將 `/admin/articles` 路由到 `ArticlesController`（不包含 `Admin::` 模組前綴），您可以使用 `scope` 區塊指定路徑：

```ruby
scope '/admin' do
  resources :articles, :comments
end
```

這也可以用於單個路由：

```ruby
resources :articles, path: '/admin/articles'
```

在這兩種情況下，命名路由助手與不使用 `scope` 時保持相同。在最後一種情況下，以下路徑對應到 `ArticlesController`：

| HTTP 動詞 | 路徑                     | 控制器#動作           | 命名路由助手           |
| --------- | ------------------------ | -------------------- | ---------------------- |
| GET       | /admin/articles          | articles#index       | articles_path          |
| GET       | /admin/articles/new      | articles#new         | new_article_path       |
| POST      | /admin/articles          | articles#create      | articles_path          |
| GET       | /admin/articles/:id      | articles#show        | article_path(:id)      |
| GET       | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id) |
| PATCH/PUT | /admin/articles/:id      | articles#update      | article_path(:id)      |
| DELETE    | /admin/articles/:id      | articles#destroy     | article_path(:id)      |

提示：如果您需要在 `namespace` 區塊內使用不同的控制器命名空間，您可以指定絕對控制器路徑，例如：`get '/foo', to: '/foo#index'`。


### 嵌套資源

通常會有一些資源在邏輯上是其他資源的子資源。例如，假設您的應用程式包含以下模型：

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

嵌套路由允許您在路由中捕獲這種關係。在這種情況下，您可以包含以下路由聲明：

```ruby
resources :magazines do
  resources :ads
end
```

除了雜誌的路由外，這個聲明還會將廣告路由到一個 `AdsController`。廣告的 URL 需要一本雜誌：

| HTTP 動詞 | 路徑                                 | 控制器#動作 | 用於                                                                       |
| --------- | ------------------------------------ | ----------- | -------------------------------------------------------------------------- |
| GET       | /magazines/:magazine_id/ads          | ads#index   | 顯示特定雜誌的所有廣告列表                                                |
| GET       | /magazines/:magazine_id/ads/new      | ads#new     | 返回一個用於創建屬於特定雜誌的新廣告的 HTML 表單                           |
| POST      | /magazines/:magazine_id/ads          | ads#create  | 創建屬於特定雜誌的新廣告                                                  |
| GET       | /magazines/:magazine_id/ads/:id      | ads#show    | 顯示屬於特定雜誌的特定廣告                                                |
| GET       | /magazines/:magazine_id/ads/:id/edit | ads#edit    | 返回一個用於編輯屬於特定雜誌的特定廣告的 HTML 表單                           |
| PATCH/PUT | /magazines/:magazine_id/ads/:id      | ads#update  | 更新屬於特定雜誌的特定廣告                                                  |
| DELETE    | /magazines/:magazine_id/ads/:id      | ads#destroy | 刪除屬於特定雜誌的特定廣告                                                  |

這還將創建路由助手，例如 `magazine_ads_url` 和 `edit_magazine_ad_path`。這些助手以 Magazine 的實例作為第一個參數（`magazine_ads_url(@magazine)`）。

#### 嵌套的限制

如果需要，您可以在其他嵌套資源中嵌套資源。例如：

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

深度嵌套的資源很快變得冗長。在這種情況下，例如，應用程式將識別以下路徑：

```
/publishers/1/magazines/2/photos/3
```

相應的路由助手將是 `publisher_magazine_photo_url`，需要您在所有三個層級上指定對象。事實上，這種情況很令人困惑，以至於 [Jamis Buck 的一篇熱門文章](http://weblog.jamisbuck.org/2007/2/5/nesting-resources) 提出了一個有關良好 Rails 設計的原則：

提示：資源的嵌套層級不應超過 1 層。

#### 淺層嵌套

避免深層嵌套（如上所建議）的一種方法是在父級下生成集合動作，以便獲得層次結構的感覺，但不嵌套成員動作。換句話說，只構建具有足夠信息以唯一識別資源的路由，如下所示：

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

這個想法在描述性路由和深層嵌套之間取得了平衡。存在一種簡寫語法可以實現這一點，通過 `:shallow` 選項：

```ruby
resources :articles do
  resources :comments, shallow: true
end
```
這將生成與第一個示例完全相同的路由。您還可以在父資源中指定 `:shallow` 選項，這樣所有嵌套的資源都將是 shallow 的：

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

這裡的 articles 資源將生成以下路由：

| HTTP 方法 | 路徑                                         | 控制器#動作 | 命名路由輔助方法        |
| --------- | -------------------------------------------- | ----------- | ----------------------- |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_comment_path        |
| GET       | /comments/:id(.:format)                      | comments#show     | comment_path             |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | comment_path             |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | comment_path             |
| GET       | /articles/:article_id/quotes(.:format)       | quotes#index      | article_quotes_path      |
| POST      | /articles/:article_id/quotes(.:format)       | quotes#create     | article_quotes_path      |
| GET       | /articles/:article_id/quotes/new(.:format)   | quotes#new        | new_article_quote_path   |
| GET       | /quotes/:id/edit(.:format)                   | quotes#edit       | edit_quote_path          |
| GET       | /quotes/:id(.:format)                        | quotes#show       | quote_path               |
| PATCH/PUT | /quotes/:id(.:format)                        | quotes#update     | quote_path               |
| DELETE    | /quotes/:id(.:format)                        | quotes#destroy    | quote_path               |
| GET       | /articles/:article_id/drafts(.:format)       | drafts#index      | article_drafts_path      |
| POST      | /articles/:article_id/drafts(.:format)       | drafts#create     | article_drafts_path      |
| GET       | /articles/:article_id/drafts/new(.:format)   | drafts#new        | new_article_draft_path   |
| GET       | /drafts/:id/edit(.:format)                   | drafts#edit       | edit_draft_path          |
| GET       | /drafts/:id(.:format)                        | drafts#show       | draft_path               |
| PATCH/PUT | /drafts/:id(.:format)                        | drafts#update     | draft_path               |
| DELETE    | /drafts/:id(.:format)                        | drafts#destroy    | draft_path               |
| GET       | /articles(.:format)                          | articles#index    | articles_path            |
| POST      | /articles(.:format)                          | articles#create   | articles_path            |
| GET       | /articles/new(.:format)                      | articles#new      | new_article_path         |
| GET       | /articles/:id/edit(.:format)                 | articles#edit     | edit_article_path        |
| GET       | /articles/:id(.:format)                      | articles#show     | article_path             |
| PATCH/PUT | /articles/:id(.:format)                      | articles#update   | article_path             |
| DELETE    | /articles/:id(.:format)                      | articles#destroy  | article_path             |

DSL 的 [`shallow`][] 方法創建了一個範圍，其中每個嵌套都是 shallow 的。這將生成與前一個示例相同的路由：

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

`scope` 有兩個選項可以自定義 shallow 路由。`:shallow_path` 在成員路徑前綴指定的參數：

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

這裡的 comments 資源將生成以下路由：

| HTTP 方法 | 路徑                                         | 控制器#動作 | 命名路由輔助方法        |
| --------- | -------------------------------------------- | ----------- | ----------------------- |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /sekret/comments/:id/edit(.:format)          | comments#edit     | edit_comment_path        |
| GET       | /sekret/comments/:id(.:format)               | comments#show     | comment_path             |
| PATCH/PUT | /sekret/comments/:id(.:format)               | comments#update   | comment_path             |
| DELETE    | /sekret/comments/:id(.:format)               | comments#destroy  | comment_path             |

`:shallow_prefix` 選項將指定的參數添加到命名路由輔助方法：

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

這裡的 comments 資源將生成以下路由：

| HTTP 方法 | 路徑                                         | 控制器#動作 | 命名路由輔助方法          |
| --------- | -------------------------------------------- | ----------- | --------------------------- |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path       |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path       |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path    |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_sekret_comment_path    |
| GET       | /comments/:id(.:format)                      | comments#show     | sekret_comment_path         |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | sekret_comment_path         |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | sekret_comment_path         |


### 路由關注點

路由關注點允許您聲明可以在其他資源和路由中重複使用的常見路由。要定義一個關注點，請使用 [`concern`][] 區塊：

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

這些關注點可以在資源中使用，以避免代碼重複並在路由之間共享行為：

```ruby
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

以上等同於：

```ruby
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```
你也可以在`scope`或`namespace`區塊中使用[`concerns`][]。例如：

```ruby
namespace :articles do
  concerns :commentable
end
```


### 從物件建立路徑和URL

除了使用路由輔助方法外，Rails還可以從參數陣列中建立路徑和URL。例如，假設你有以下路由設定：

```ruby
resources :magazines do
  resources :ads
end
```

當使用`magazine_ad_path`時，你可以傳入`Magazine`和`Ad`的實例，而不是數字ID：

```erb
<%= link_to '廣告詳情', magazine_ad_path(@magazine, @ad) %>
```

你也可以使用[`url_for`][ActionView::RoutingUrlFor#url_for]和一組物件，Rails會自動判斷你要使用的路由：

```erb
<%= link_to '廣告詳情', url_for([@magazine, @ad]) %>
```

在這種情況下，Rails會看到`@magazine`是一個`Magazine`物件，`@ad`是一個`Ad`物件，因此會使用`magazine_ad_path`輔助方法。在`link_to`等輔助方法中，你可以只指定物件，而不是完整的`url_for`呼叫：

```erb
<%= link_to '廣告詳情', [@magazine, @ad] %>
```

如果你只想連結到一本雜誌：

```erb
<%= link_to '雜誌詳情', @magazine %>
```

對於其他動作，你只需要將動作名稱插入陣列的第一個元素：

```erb
<%= link_to '編輯廣告', [:edit, @magazine, @ad] %>
```

這使你可以將模型的實例視為URL，這是使用資源風格的關鍵優勢。


### 添加更多的RESTful動作

你不僅限於RESTful路由預設創建的七個路徑。如果需要，你可以添加適用於集合或集合中個別成員的其他路由。

#### 添加成員路由

要添加成員路由，只需在資源區塊中添加一個[`member`][]區塊：

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

這將識別`/photos/1/preview`的GET請求，並將其路由到`PhotosController`的`preview`動作，並將資源ID值傳遞給`params[:id]`。它還會創建`preview_photo_url`和`preview_photo_path`輔助方法。

在成員路由的區塊中，每個路由名稱指定將被識別的HTTP動詞。你可以在這裡使用[`get`][], [`patch`][], [`put`][], [`post`][], 或 [`delete`][]。如果你沒有多個`member`路由，你也可以將`:on`傳遞給路由，省略區塊：

```ruby
resources :photos do
  get 'preview', on: :member
end
```

你可以省略`:on`選項，這將創建相同的成員路由，只是資源ID值將在`params[:photo_id]`中而不是`params[:id]`中可用。路由輔助方法也將從`preview_photo_url`和`preview_photo_path`更名為`photo_preview_url`和`photo_preview_path`。


#### 添加集合路由

要添加集合路由，使用[`collection`][]區塊：

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

這將使Rails識別`/photos/search`的GET請求，並將其路由到`PhotosController`的`search`動作。它還會創建`search_photos_url`和`search_photos_path`路由輔助方法。

與成員路由一樣，你可以將`:on`傳遞給路由：

```ruby
resources :photos do
  get 'search', on: :collection
end
```

注意：如果你正在使用符號作為第一個位置參數定義其他資源路由，請注意它與使用字符串不等價。符號表示控制器動作，而字符串表示路徑。


#### 添加其他新動作的路由

要使用`:on`快捷方式添加替代的新動作：

```ruby
resources :comments do
  get 'preview', on: :new
end
```

這將使Rails識別`/comments/new/preview`的GET請求，並將其路由到`CommentsController`的`preview`動作。它還會創建`preview_new_comment_url`和`preview_new_comment_path`路由輔助方法。

提示：如果你發現自己在資源路由中添加了許多額外的動作，那麼是時候停下來問問自己是否正在掩蓋另一個資源的存在。

非資源路由
-----------

除了資源路由外，Rails還支援將任意URL路由到動作的功能。在這裡，你不會得到由資源路由自動生成的路由群組。相反，你需要在應用程式中分別設定每個路由。

雖然通常應該使用資源路由，但仍然有許多情況下簡單的路由更適合。如果將應用程式的每一個部分都強行塞進資源路由中，那是不必要的。
特別是簡單的路由使得將舊的URL映射到新的Rails操作非常容易。

### 綁定參數

當您設置一個常規路由時，您提供了一系列符號，Rails將這些符號映射到傳入的HTTP請求的部分。例如，考慮以下路由：

```ruby
get 'photos(/:id)', to: 'photos#display'
```

如果這個路由處理了一個`/photos/1`的傳入請求（因為它在文件中沒有匹配到任何先前的路由），那麼結果將是調用`PhotosController`的`display`操作，並將最終參數`"1"`作為`params[:id]`可用。這個路由還會將傳入的`/photos`請求路由到`PhotosController#display`，因為`:id`是一個可選的參數，用括號表示。

### 動態片段

您可以在常規路由中設置任意多個動態片段。任何片段都將作為`params`的一部分可用於操作。如果您設置了這個路由：

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

一個`/photos/1/2`的傳入路徑將被分派到`PhotosController`的`show`操作。`params[:id]`將是`"1"`，`params[:user_id]`將是`"2"`。

提示：默認情況下，動態片段不接受點號 - 這是因為點號用作格式化路由的分隔符。如果您需要在動態片段中使用點號，可以添加一個覆蓋此行為的約束 - 例如，`id: /[^\/]+/`允許除斜杠以外的任何字符。

### 靜態片段

在創建路由時，您可以通過不在片段前加冒號來指定靜態片段：

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

這個路由將響應像`/photos/1/with_user/2`這樣的路徑。在這種情況下，`params`將是`{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`。

### 查詢字符串

`params`還將包括查詢字符串中的任何參數。例如，使用這個路由：

```ruby
get 'photos/:id', to: 'photos#show'
```

一個`/photos/1?user_id=2`的傳入路徑將被分派到`Photos`控制器的`show`操作。`params`將是`{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`。

### 定義默認值

您可以通過為`：defaults`選項提供一個哈希來在路由中定義默認值。這甚至適用於您未指定為動態片段的參數。例如：

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails將匹配`photos/12`到`PhotosController`的`show`操作，並將`params[:format]`設置為`"jpg"`。

您還可以使用[`defaults`][]塊來為多個項目定義默認值：

```ruby
defaults format: :json do
  resources :photos
end
```

注意：您不能通過查詢參數覆蓋默認值 - 這是出於安全考慮。唯一可以被覆蓋的默認值是URL路徑中的動態片段。

### 命名路由

您可以使用`：as`選項為任何路由指定一個名稱：

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

這將在您的應用程序中創建`logout_path`和`logout_url`作為命名路由助手。調用`logout_path`將返回`/exit`

您還可以使用這個方法來覆蓋由資源定義的路由方法，將自定義路由放在資源定義之前，像這樣：

```ruby
get ':username', to: 'users#show', as: :user
resources :users
```

這將定義一個`user_path`方法，它將在控制器、助手和視圖中可用，並將轉到像`/bob`這樣的路由。在`UsersController`的`show`操作中，`params[:username]`將包含用戶的用戶名。如果您不希望參數名稱為`:username`，請在路由定義中更改`:username`。

### HTTP動詞約束

通常，您應該使用[`get`][]、[`post`][]、[`put`][]、[`patch`][]和[`delete`][]方法來限制路由到特定的動詞。您可以使用[`match`][]方法和`：via`選項一次匹配多個動詞：

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

您可以使用`via: :all`將所有動詞匹配到特定的路由：

```ruby
match 'photos', to: 'photos#show', via: :all
```

注意：將`GET`和`POST`請求都路由到單個操作具有安全風險。通常情況下，除非有充分的理由，否則應該避免將所有動詞路由到一個操作。

注意：在Rails中，`GET`不會檢查CSRF令牌。您不應該從`GET`請求中對數據庫進行寫入操作，有關更多信息，請參閱CSRF對策的[安全指南](security.html#csrf-countermeasures)。
### 分段限制

您可以使用 `:constraints` 選項來強制動態分段的格式：

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

此路由將匹配 `/photos/A12345` 這樣的路徑，但不匹配 `/photos/893`。您也可以使用更簡潔的方式表達相同的路由：

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` 接受正則表達式，但不能使用正則表達式錨點。例如，以下路由將無法正常工作：

```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

但是，請注意，您不需要使用錨點，因為所有路由都在開頭和結尾處有錨點。

例如，以下路由將允許具有 `to_param` 值為 `1-hello-world`（始於數字）的 `articles` 和具有 `to_param` 值為 `david`（不以數字開頭）的 `users` 共享根命名空間：

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### 基於請求的限制

您還可以根據 [Request 物件](action_controller_overview.html#the-request-object) 上的任何返回 `String` 的方法來限制路由。

您可以像指定分段限制一樣指定基於請求的限制：

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

您還可以使用 [`constraints`][] 塊來指定限制：

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

注意：請求限制是通過調用 [Request 物件](action_controller_overview.html#the-request-object) 上與哈希鍵同名的方法並將返回值與哈希值進行比較來工作的。因此，限制值應與相應的 Request 物件方法返回類型匹配。例如：`constraints: { subdomain: 'api' }` 將如預期地匹配 `api` 子域。但是，使用符號 `constraints: { subdomain: :api }` 將不匹配，因為 `request.subdomain` 返回的是字符串 `'api'`。

注意：對於 `format` 限制，有一個例外情況：儘管它是 Request 物件上的一個方法，但它也是每個路徑的隱式可選參數。分段限制優先，只有通過哈希強制執行時，`format` 限制才會應用。例如，`get 'foo', constraints: { format: 'json' }` 將匹配 `GET  /foo`，因為默認情況下格式是可選的。但是，您可以使用 [lambda](#advanced-constraints)，就像在 `get 'foo', constraints: lambda { |req| req.format == :json }` 中一樣，該路由只會匹配明確的 JSON 請求。


### 高級限制

如果您有更高級的限制，可以提供一個響應 `matches?` 的對象，Rails 應該使用該對象。假設您想將受限列表中的所有用戶路由到 `RestrictedListController`。您可以這樣做：

```ruby
class RestrictedListConstraint
  def initialize
    @ips = RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: RestrictedListConstraint.new
end
```

您也可以將限制指定為 lambda：

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

`matches?` 方法和 lambda 都將 `request` 物件作為參數。

#### 塊形式的限制

您可以以塊形式指定限制。這在需要將相同規則應用於多個路由時很有用。例如：

```ruby
class RestrictedListConstraint
  # ...與上面的示例相同
end

Rails.application.routes.draw do
  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

您也可以使用 `lambda`：

```ruby
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

### 路由匹配和萬用分段

路由匹配是一種指定特定參數應與路由的所有剩餘部分匹配的方式。例如：

```ruby
get 'photos/*other', to: 'photos#unknown'
```

此路由將匹配 `photos/12` 或 `/photos/long/path/to/12`，並將 `params[:other]` 設置為 `"12"` 或 `"long/path/to/12"`。以星號為前綴的分段稱為「萬用分段」。

萬用分段可以出現在路由的任何位置。例如：

```ruby
get 'books/*section/:title', to: 'books#show'
```

將匹配 `books/some/section/last-words-a-memoir`，其中 `params[:section]` 等於 `'some/section'`，`params[:title]` 等於 `'last-words-a-memoir'`。

從技術上講，一個路由甚至可以有多個萬用分段。匹配器以直觀的方式將分段分配給參數。例如：

```ruby
get '*a/foo/*b', to: 'test#index'
```

將匹配 `zoo/woo/foo/bar/baz`，其中 `params[:a]` 等於 `'zoo/woo'`，`params[:b]` 等於 `'bar/baz'`。
注意：通過請求`'/foo/bar.json'`，你的`params[:pages]`將等於`'foo/bar'`，請求格式為JSON。如果你想恢復舊的3.0.x行為，你可以像這樣提供`format: false`：

```ruby
get '*pages', to: 'pages#show', format: false
```

注意：如果你想使格式段成為必填項，不能省略，你可以像這樣提供`format: true`：

```ruby
get '*pages', to: 'pages#show', format: true
```

### 重定向

你可以在路由器中使用[`redirect`][]輔助程序將任何路徑重定向到另一個路徑：

```ruby
get '/stories', to: redirect('/articles')
```

你還可以重用匹配中的動態段，以重定向到其他路徑：

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

你還可以為`redirect`提供一個塊，該塊接收符號化的路徑參數和請求對象：

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

請注意，默認的重定向是301“永久移動”重定向。請記住，某些網絡瀏覽器或代理服務器會緩存此類重定向，使舊頁面無法訪問。你可以使用`:status`選項來更改響應狀態：

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

在所有這些情況下，如果你不提供前導主機（`http://www.example.com`），Rails將從當前請求中獲取這些詳細信息。


### 路由到Rack應用程序

在匹配器中，你可以指定任何[Rack應用程序](rails_on_rack.html)作為端點，而不是像`'articles#index'`這樣的字符串，它對應於`ArticlesController`中的`index`操作：

```ruby
match '/application.js', to: MyRackApp, via: :all
```

只要`MyRackApp`響應`call`並返回`[status, headers, body]`，路由器就無法分辨Rack應用程序和操作之間的區別。這是`via: :all`的適當用法，因為你希望允許Rack應用程序根據需要處理所有動詞。

注意：對於好奇的人來說，`'articles#index'`實際上展開為`ArticlesController.action(:index)`，它返回一個有效的Rack應用程序。

注意：由於procs/lambdas是響應`call`的對象，你可以內聯實現非常簡單的路由（例如用於健康檢查）：<br>`get '/health', to: ->(env) { [204, {}, ['']] }`

如果你將Rack應用程序指定為匹配器的端點，請記住接收應用程序的路由在接收應用程序中不會改變。對於以下路由，你的Rack應用程序應該期望路由為`/admin`：

```ruby
match '/admin', to: AdminApp, via: :all
```

如果你希望你的Rack應用程序在根路徑接收請求，而不是其他路徑，請使用[`mount`][]：

```ruby
mount AdminApp, at: '/admin'
```


### 使用`root`

你可以使用[`root`][]方法指定Rails應該將`'/'`路由到哪裡：

```ruby
root to: 'pages#main'
root 'pages#main' # 上述的快捷方式
```

你應該將`root`路由放在文件的頂部，因為它是最常用的路由，應該首先匹配。

注意：`root`路由只將`GET`請求路由到操作。

你還可以在命名空間和作用域中使用`root`。例如：

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```


### Unicode字符路由

你可以直接指定Unicode字符路由。例如：

```ruby
get 'こんにちは', to: 'welcome#index'
```

### 直接路由

你可以通過調用[`direct`][]直接創建自定義URL輔助程序。例如：

```ruby
direct :homepage do
  "https://rubyonrails.org"
end

# >> homepage_url
# => "https://rubyonrails.org"
```

塊的返回值必須是`url_for`方法的有效參數。因此，你可以傳遞有效的字符串URL、Hash、Array、Active Model實例或Active Model類。

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```


### 使用`resolve`

[`resolve`][]方法允許自定義模型的多態映射。例如：

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_with model: @basket do |form| %>
  <!-- basket form -->
<% end %>
```

這將生成單數URL`/basket`，而不是通常的`/baskets/:id`。


自定義資源路由
------------------------------

雖然[`resources`][]生成的默認路由和輔助程序通常能滿足你的需求，但你可能想以某種方式自定義它們。Rails允許你自定義幾乎任何資源輔助程序的通用部分。
### 指定要使用的控制器

`:controller` 選項允許您明確指定要用於資源的控制器。例如：

```ruby
resources :photos, controller: 'images'
```

將識別以 `/photos` 開頭的請求路徑，但將路由到 `Images` 控制器：

| HTTP 動詞 | 路徑             | 控制器#動作 | 命名路由輔助方法   |
| --------- | ---------------- | ----------- | ------------------ |
| GET       | /photos          | images#index | photos_path        |
| GET       | /photos/new      | images#new   | new_photo_path     |
| POST      | /photos          | images#create| photos_path        |
| GET       | /photos/:id      | images#show  | photo_path(:id)    |
| GET       | /photos/:id/edit | images#edit  | edit_photo_path(:id)|
| PATCH/PUT | /photos/:id      | images#update| photo_path(:id)    |
| DELETE    | /photos/:id      | images#destroy| photo_path(:id)    |

注意：使用 `photos_path`、`new_photo_path` 等來生成此資源的路徑。

對於有命名空間的控制器，您可以使用目錄表示法。例如：

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

這將路由到 `Admin::UserPermissions` 控制器。

注意：僅支援目錄表示法。使用 Ruby 常量表示法（例如 `controller: 'Admin::UserPermissions'`）可能會導致路由問題並產生警告。

### 指定約束條件

您可以使用 `:constraints` 選項來指定對隱式 `id` 的格式要求。例如：

```ruby
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

此聲明將約束 `:id` 參數與提供的正則表達式匹配。因此，在這種情況下，路由器將不再將 `/photos/1` 與此路由匹配。相反，`/photos/RR27` 將匹配。

您可以使用區塊形式來指定單個約束條件，以應用於多個路由：

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

注意：當然，您可以在此上下文中使用非資源路由中提供的更高級約束。

提示：預設情況下，`:id` 參數不接受點號 - 這是因為點號用作格式化路由的分隔符。如果您需要在 `:id` 內使用點號，請添加一個覆蓋此行為的約束 - 例如 `id: /[^\/]+/` 允許除斜線以外的任何字符。

### 覆蓋命名路由輔助方法

`:as` 選項允許您覆蓋命名路由輔助方法的正常命名。例如：

```ruby
resources :photos, as: 'images'
```

將識別以 `/photos` 開頭的請求路徑，並將請求路由到 `PhotosController`，但使用 `:as` 選項的值來命名輔助方法。

| HTTP 動詞 | 路徑             | 控制器#動作 | 命名路由輔助方法   |
| --------- | ---------------- | ----------- | ------------------ |
| GET       | /photos          | photos#index | images_path        |
| GET       | /photos/new      | photos#new   | new_image_path     |
| POST      | /photos          | photos#create| images_path        |
| GET       | /photos/:id      | photos#show  | image_path(:id)    |
| GET       | /photos/:id/edit | photos#edit  | edit_image_path(:id)|
| PATCH/PUT | /photos/:id      | photos#update| image_path(:id)    |
| DELETE    | /photos/:id      | photos#destroy| image_path(:id)    |

### 覆蓋 `new` 和 `edit` 段落

`:path_names` 選項允許您覆蓋路徑中自動生成的 `new` 和 `edit` 段落：

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

這將使路由識別以下路徑：

```
/photos/make
/photos/1/change
```

注意：此選項不會更改實際的動作名稱。這兩個示例路徑仍將路由到 `new` 和 `edit` 動作。

提示：如果您希望統一更改所有路由的此選項，可以使用作用域，如下所示：

```ruby
scope path_names: { new: 'make' } do
  # 其餘的路由
end
```

### 給命名路由輔助方法加上前綴

您可以使用 `:as` 選項為 Rails 為路由生成的命名路由輔助方法加上前綴。使用此選項可防止使用路徑範圍的路由之間發生名稱衝突。例如：

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

這將將 `/admin/photos` 的路由輔助方法從 `photos_path`、`new_photos_path` 等更改為 `admin_photos_path`、`new_admin_photo_path` 等。如果在範圍為 `resources :photos` 的路由中沒有添加 `as: 'admin_photos'`，則非範圍的 `resources :photos` 將不會有任何路由輔助方法。

要為一組路由輔助方法加上前綴，請在 `scope` 中使用 `:as`：

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

與之前一樣，這將將 `/admin` 範圍的資源輔助方法更改為 `admin_photos_path` 和 `admin_accounts_path`，並允許非範圍的資源使用 `photos_path` 和 `accounts_path`。
注意：`namespace`範圍將自動添加`：as`以及`：module`和`：path`前綴。

#### 參數範圍

您可以在路由前面添加一個命名參數：

```ruby
scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
  resources :articles
end
```

這將為您提供像`/1/articles/9`這樣的路徑，並允許您在控制器、幫助程序和視圖中引用路徑的`account_id`部分為`params[:account_id]`。

它還會生成以`account_`為前綴的路徑和URL幫助程序，您可以像預期的那樣將對象傳遞給它們：

```ruby
account_article_path(@account, @article) # => /1/article/9
url_for([@account, @article])            # => /1/article/9
form_with(model: [@account, @article])   # => <form action="/1/article/9" ...>
```

我們正在[使用約束](#segment-constraints)來限制範圍僅匹配類似ID的字符串。您可以根據需要更改約束，或者完全省略它。`：as`選項也不是絕對必需的，但是如果沒有它，Rails在評估`url_for([@account, @article])`或依賴於`url_for`的其他幫助程序（如[`form_with`][]）時將引發錯誤。


### 限制創建的路由

默認情況下，Rails為應用程序中的每個RESTful路由創建七個默認操作（`index`、`show`、`new`、`create`、`edit`、`update`和`destroy`）的路由。您可以使用`：only`和`：except`選項來微調此行為。`：only`選項告訴Rails僅創建指定的路由：

```ruby
resources :photos, only: [:index, :show]
```

現在，對`/photos`的`GET`請求將成功，但對`/photos`的`POST`請求（通常會路由到`create`操作）將失敗。

`：except`選項指定Rails不應創建的路由或路由列表：

```ruby
resources :photos, except: :destroy
```

在這種情況下，Rails將創建所有常規路由，除了`destroy`的路由（一個`DELETE`請求到`/photos/:id`）。

提示：如果您的應用程序有很多RESTful路由，使用`：only`和`：except`僅生成您實際需要的路由可以減少內存使用量並加快路由過程。

### 翻譯路徑

使用`scope`，我們可以修改`resources`生成的路徑名稱：

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

現在，Rails將創建到`CategoriesController`的路由。

| HTTP方法 | 路徑                       | 控制器#操作  | 命名路由幫助程序      |
| --------- | -------------------------- | ------------------ | ----------------------- |
| GET       | /kategorien                | categories#index   | categories_path         |
| GET       | /kategorien/neu            | categories#new     | new_category_path       |
| POST      | /kategorien                | categories#create  | categories_path         |
| GET       | /kategorien/:id            | categories#show    | category_path(:id)      |
| GET       | /kategorien/:id/bearbeiten | categories#edit    | edit_category_path(:id) |
| PATCH/PUT | /kategorien/:id            | categories#update  | category_path(:id)      |
| DELETE    | /kategorien/:id            | categories#destroy | category_path(:id)      |

### 覆蓋單數形式

如果要覆蓋資源的單數形式，應該通過[`inflections`][]向詞形變化器添加其他規則：

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```


### 在嵌套資源中使用`：as`

`：as`選項將覆蓋嵌套路由幫助程序中自動生成的資源名稱。例如：

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

這將創建路由幫助程序，例如`magazine_periodical_ads_url`和`edit_magazine_periodical_ad_path`。

### 覆蓋命名路由參數

`：param`選項將覆蓋默認的資源標識符`：id`（用於生成路由的[動態段](routing.html#dynamic-segments)的名稱）。您可以使用`params[<:param>]`從控制器中訪問該段。

```ruby
resources :videos, param: :identifier
```

```
    videos GET  /videos(.:format)                  videos#index
           POST /videos(.:format)                  videos#create
 new_video GET  /videos/new(.:format)              videos#new
edit_video GET  /videos/:identifier/edit(.:format) videos#edit
```

```ruby
Video.find_by(identifier: params[:identifier])
```

您可以覆蓋相關模型的`ActiveRecord::Base#to_param`以構建URL：

```ruby
class Video < ApplicationRecord
  def to_param
    identifier
  end
end
```

```ruby
video = Video.find_by(identifier: "Roman-Holiday")
edit_video_path(video) # => "/videos/Roman-Holiday/edit"
```

將非常大的路由文件拆分為多個小文件
-------------------------------------------------------

如果您在一個有數千個路由的大型應用程序中工作，單個`config/routes.rb`文件可能變得冗長且難以閱讀。

Rails提供了一種將巨大的單個`routes.rb`文件拆分為多個小文件的方法，使用[`draw`][]宏。

您可以有一個包含管理區域的所有路由的`admin.rb`路由，另一個用於API相關資源的`api.rb`文件，等等。

```ruby
# config/routes.rb

Rails.application.routes.draw do
  get 'foo', to: 'foo#bar'

  draw(:admin) # 將加載位於`config/routes/admin.rb`中的另一個路由文件
end
```
```ruby
# config/routes/admin.rb

namespace :admin do
  resources :comments
end
```

在 `Rails.application.routes.draw` 區塊內部呼叫 `draw(:admin)` 會嘗試載入一個與參數名稱相同的路由檔案（在此範例中為 `admin.rb`）。
該檔案需要位於 `config/routes` 目錄下或其子目錄中（例如 `config/routes/admin.rb` 或 `config/routes/external/admin.rb`）。

您可以在 `admin.rb` 路由檔案中使用正常的路由 DSL，但**不應該**像在主要的 `config/routes.rb` 檔案中那樣將其包裹在 `Rails.application.routes.draw` 區塊中。


### 除非真的需要，否則不要使用此功能

擁有多個路由檔案會使發現性和理解性變得更困難。對於大多數應用程序，即使是具有數百個路由的應用程序，開發人員使用單一路由檔案更容易。Rails 路由 DSL 已經提供了使用 `namespace` 和 `scope` 以有組織的方式拆分路由的方法。


檢查和測試路由
-----------------------------

Rails 提供了檢查和測試路由的工具。

### 列出現有路由

要獲取應用程序中可用路由的完整列表，在您的瀏覽器中訪問 <http://localhost:3000/rails/info/routes>（在服務器以**開發**環境運行時）。您也可以在終端中執行 `bin/rails routes` 命令以產生相同的輸出。

這兩種方法都會列出所有路由，並按照它們在 `config/routes.rb` 中出現的順序列出。對於每個路由，您將看到：

* 路由名稱（如果有）
* 使用的 HTTP 動詞（如果路由不響應所有動詞）
* 要匹配的 URL 模式
* 路由的路由參數

例如，這是一個 RESTful 路由的 `bin/rails routes` 輸出的一小部分：

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

您還可以使用 `--expanded` 選項打開擴展表格格式模式。

```bash
$ bin/rails routes --expanded

--[ 路由 1 ]----------------------------------------------------
前綴              | users
動詞              | GET
URI               | /users(.:format)
控制器#動作        | users#index
--[ 路由 2 ]----------------------------------------------------
前綴              |
動詞              | POST
URI               | /users(.:format)
控制器#動作        | users#create
--[ 路由 3 ]----------------------------------------------------
前綴              | new_user
動詞              | GET
URI               | /users/new(.:format)
控制器#動作        | users#new
--[ 路由 4 ]----------------------------------------------------
前綴              | edit_user
動詞              | GET
URI               | /users/:id/edit(.:format)
控制器#動作        | users#edit
```

您可以使用 grep 選項搜索路由：-g。這將輸出部分匹配 URL 輔助方法名稱、HTTP 動詞或 URL 路徑的任何路由。

```bash
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

如果只想看到映射到特定控制器的路由，可以使用 -c 選項。

```bash
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

提示：如果將終端窗口擴大到輸出行不換行，則 `bin/rails routes` 的輸出會更易讀。

### 測試路由

路由應該包含在您的測試策略中（就像應用程序的其餘部分一樣）。Rails 提供了三個內建斷言，旨在使測試路由更簡單：

* [`assert_generates`][]
* [`assert_recognizes`][]
* [`assert_routing`][]


#### `assert_generates` 斷言

[`assert_generates`][] 斷言特定的選項生成特定的路徑，並可與默認路由或自定義路由一起使用。例如：

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### `assert_recognizes` 斷言

[`assert_recognizes`][] 是 `assert_generates` 的相反。它斷言給定的路徑被識別並將其路由到應用程序中的特定位置。例如：

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

您可以提供 `:method` 參數來指定 HTTP 動詞：

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### `assert_routing` 斷言

[`assert_routing`][] 斷言檢查路由的兩個方向：它測試路徑生成選項，並且選項生成路徑。因此，它結合了 `assert_generates` 和 `assert_recognizes` 的功能：

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```

[`resources`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
[`namespace`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-namespace
[`scope`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-scope
[`shallow`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-shallow
[`concern`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concern
[`concerns`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concerns
[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`delete`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-delete
[`get`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-get
[`member`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-member
[`patch`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-patch
[`post`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-post
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`collection`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-collection
[`defaults`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-defaults
[`match`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-match
[`constraints`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints
[`redirect`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Redirection.html#method-i-redirect
[`mount`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-mount
[`root`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-root
[`direct`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-direct
[`resolve`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve
[`form_with`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[`inflections`]: https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-inflections
[`draw`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-draw
[`assert_generates`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates
[`assert_recognizes`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes
[`assert_routing`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_routing
