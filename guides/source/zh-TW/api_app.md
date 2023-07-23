**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fe858c0828e87f595c5d8c23c4b6326e
使用Rails開發API應用程式
====================

在本指南中，您將學到：

* Rails為API應用程式提供了什麼功能
* 如何配置Rails以在沒有任何瀏覽器功能的情況下啟動
* 如何決定要包含哪些中介軟體
* 如何決定在控制器中使用哪些模組

--------------------------------------------------------------------------------

什麼是API應用程式？
------------------

傳統上，當人們說他們使用Rails作為「API」時，他們指的是在他們的網頁應用程式旁提供一個可程式化存取的API。例如，GitHub提供了[一個API](https://developer.github.com)，您可以從自己的自訂客戶端使用。

隨著客戶端框架的出現，越來越多的開發人員使用Rails來構建一個在網頁應用程式和其他原生應用程式之間共享的後端。

例如，Twitter在其網頁應用程式中使用其[公共API](https://developer.twitter.com/)，該應用程式是作為消耗JSON資源的靜態網站構建的。

許多開發人員不再使用Rails生成通過表單和連結與伺服器通信的HTML，而是將他們的網頁應用程式視為僅僅是一個使用JavaScript提供的HTML的API客戶端，該客戶端消耗JSON API。

本指南涵蓋了構建一個Rails應用程式，該應用程式向API客戶端提供JSON資源，包括客戶端框架。

為什麼要使用Rails開發JSON API？
-------------------------------

當人們考慮使用Rails來構建一個使用JSON API時，很多人會問的第一個問題是："使用Rails來輸出一些JSON是不是有點過度？我應該只使用像Sinatra這樣的東西嗎？"。

對於非常簡單的API來說，這可能是正確的。然而，即使在非常HTML密集的應用程式中，大部分的應用程式邏輯都存在於視圖層之外。

大多數人使用Rails的原因是它提供了一組預設值，使開發人員能夠快速啟動並運行，而不需要做出許多微不足道的決策。

讓我們來看看Rails提供的一些開箱即用的功能，這些功能在API應用程式中仍然適用。

在中介軟體層處理：

- 重新載入：Rails應用程式支援透明重新載入。即使您的應用程式變得很大，每個請求都重新啟動伺服器變得不可行，這也能正常運作。
- 開發模式：Rails應用程式具有開發的智能預設值，使開發變得愉快，同時不影響生產環境的效能。
- 測試模式：同樣適用於開發模式。
- 日誌記錄：Rails應用程式記錄每個請求，並根據當前模式適當地提供詳細程度適中的詳細資訊。Rails在開發中的日誌中包含有關請求環境、資料庫查詢和基本效能資訊的資訊。
- 安全性：Rails能夠檢測和阻止[IP欺騙攻擊](https://en.wikipedia.org/wiki/IP_address_spoofing)，並以[時間攻擊](https://en.wikipedia.org/wiki/Timing_attack)感知的方式處理加密簽名。不知道什麼是IP欺騙攻擊或時間攻擊？沒問題。
- 參數解析：想要將參數指定為JSON而不是URL編碼的字串？沒問題。Rails將為您解碼JSON並將其提供在`params`中。想要使用嵌套的URL編碼參數？也可以。
- 條件式GET：Rails處理條件式`GET`（`ETag`和`Last-Modified`）處理請求標頭並返回正確的回應標頭和狀態碼。您只需要在控制器中使用[`stale?`](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F)檢查，Rails將為您處理所有HTTP細節。
- HEAD請求：Rails將透明地將`HEAD`請求轉換為`GET`請求，並在返回時僅返回標頭。這使得`HEAD`在所有Rails API中可靠地工作。

雖然您可以通過現有的Rack中介軟體來構建這些功能，但這個清單證明了預設的Rails中介軟體堆疊提供了很多價值，即使您只是「生成JSON」。

在Action Pack層處理：

- 資源路由：如果您正在構建一個RESTful JSON API，您應該使用Rails路由器。從HTTP到控制器的清晰和傳統的映射意味著您不需要花時間思考如何在HTTP方面建模您的API。
- URL生成：路由的反面是URL生成。基於HTTP的良好API包括URL（請參閱[GitHub Gist API](https://docs.github.com/en/rest/reference/gists)的示例）。
- 標頭和重定向回應：`head :no_content`和`redirect_to user_url(current_user)`非常方便。當然，您可以手動添加回應標頭，但為什麼要這樣做呢？
- 快取：Rails提供頁面、動作和片段快取。在構建嵌套的JSON物件時，片段快取尤其有用。
- 基本、摘要和令牌驗證：Rails提供了對三種HTTP驗證的開箱即用支援。
- 儀表板：Rails具有一個儀表板API，可以觸發註冊的處理程序來處理各種事件，例如操作處理、發送檔案或資料、重定向和資料庫查詢。每個事件的有效負載都帶有相關資訊（對於操作處理事件，有效負載包括控制器、操作、參數、請求格式、請求方法和請求的完整路徑）。
- 產生器：通常很方便生成資源並在一個命令中為您創建模型、控制器、測試存根和路由，以供進一步調整。遷移和其他方面也是如此。
- 插件：許多第三方庫都提供了對Rails的支援，減少或消除了設置和將庫和Web框架結合在一起的成本。這包括覆蓋默認生成器、添加Rake任務和遵守Rails選擇（如記錄器和快取後端）。
當然，Rails的啟動過程也會將所有已註冊的組件黏合在一起。
例如，當配置Active Record時，Rails的啟動過程會使用您的`config/database.yml`文件。

**簡短版本是**：即使您刪除了視圖層，您可能沒有考慮過Rails的哪些部分仍然適用，但答案是大部分。

基本配置
-----------------------

如果您正在構建的Rails應用程序首先是API服務器，您可以從更有限的Rails子集開始，然後根據需要添加功能。

### 創建新應用程序

您可以生成一個新的api Rails應用程序：

```bash
$ rails new my_api --api
```

這將為您執行三個主要操作：

- 配置應用程序以使用比正常情況下更有限的中間件集。具體而言，默認情況下不包括任何主要用於瀏覽器應用程序（如cookie支持）的中間件。
- 使`ApplicationController`繼承自`ActionController::API`，而不是`ActionController::Base`。與中間件一樣，這將省略任何主要提供瀏覽器應用程序使用的Action Controller模塊。
- 配置生成器，在生成新資源時跳過生成視圖、幫助程序和資源。

### 生成新資源

為了了解我們新創建的API如何處理生成新資源，讓我們創建一個新的Group資源。每個組將有一個名稱。

```bash
$ bin/rails g scaffold Group name:string
```

在我們可以使用我們的脚手架代碼之前，我們需要更新我們的數據庫結構。

```bash
$ bin/rails db:migrate
```

現在，如果我們打開我們的`GroupsController`，我們應該注意到在API Rails應用程序中，我們只渲染JSON數據。在索引操作中，我們查詢`Group.all`並將其分配給名為`@groups`的實例變量。將其傳遞給`render`並使用`:json`選項將自動將組渲染為JSON。

```ruby
# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show update destroy ]

  # GET /groups
  def index
    @groups = Group.all

    render json: @groups
  end

  # GET /groups/1
  def show
    render json: @group
  end

  # POST /groups
  def create
    @group = Group.new(group_params)

    if @group.save
      render json: @group, status: :created, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name)
    end
end
```

最後，我們可以從Rails控制台將一些組添加到我們的數據庫中：

```irb
irb> Group.create(name: "Rails Founders")
irb> Group.create(name: "Rails Contributors")
```

有了一些數據，我們可以啟動服務器並訪問<http://localhost:3000/groups.json>以查看我們的JSON數據。

```json
[
{"id":1, "name":"Rails Founders", "created_at": ...},
{"id":2, "name":"Rails Contributors", "created_at": ...}
]
```

更改現有應用程序
--------------------

如果您想將現有應用程序變為API應用程序，請閱讀以下步驟。

在`config/application.rb`中，在`Application`類定義的頂部添加以下行：

```ruby
config.api_only = true
```

在`config/environments/development.rb`中，設置[`config.debug_exception_response_format`][]以配置開發模式下發生錯誤時的響應格式。

要使用帶有調試信息的HTML頁面，請使用值`:default`。

```ruby
config.debug_exception_response_format = :default
```

要使用保留響應格式的調試信息，請使用值`:api`。

```ruby
config.debug_exception_response_format = :api
```

默認情況下，當`config.api_only`設置為true時，`config.debug_exception_response_format`設置為`:api`。

最後，在`app/controllers/application_controller.rb`內，將：

```ruby
class ApplicationController < ActionController::Base
end
```

改為：

```ruby
class ApplicationController < ActionController::API
end
```


選擇中間件
--------------------

API應用程序默認使用以下中間件：

- `ActionDispatch::HostAuthorization`
- `Rack::Sendfile`
- `ActionDispatch::Static`
- `ActionDispatch::Executor`
- `ActionDispatch::ServerTiming`
- `ActiveSupport::Cache::Strategy::LocalCache::Middleware`
- `Rack::Runtime`
- `ActionDispatch::RequestId`
- `ActionDispatch::RemoteIp`
- `Rails::Rack::Logger`
- `ActionDispatch::ShowExceptions`
- `ActionDispatch::DebugExceptions`
- `ActionDispatch::ActionableExceptions`
- `ActionDispatch::Reloader`
- `ActionDispatch::Callbacks`
- `ActiveRecord::Migration::CheckPending`
- `Rack::Head`
- `Rack::ConditionalGet`
- `Rack::ETag`

有關詳細信息，請參閱Rack指南中的[內部中間件](rails_on_rack.html#internal-middleware-stack)部分。

其他插件，包括Active Record，可能會添加其他中間件。一般來說，這些中間件對於您正在構建的應用程序類型是不可知的，在僅限API的Rails應用程序中是有意義的。
您可以通過以下方式獲取應用程序中所有中間件的列表：

```bash
$ bin/rails middleware
```

### 使用 Rack::Cache

在Rails中使用`Rack::Cache`時，它會使用Rails緩存存儲作為其實體和元存儲。這意味著如果您在Rails應用程序中使用memcache，內置的HTTP緩存將使用memcache。

要使用`Rack::Cache`，首先需要將`rack-cache` gem添加到`Gemfile`中，並將`config.action_dispatch.rack_cache`設置為`true`。為了啟用其功能，您將希望在控制器中使用`stale?`。以下是使用`stale?`的示例。

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

`stale?`方法將比較請求中的`If-Modified-Since`標頭與`@post.updated_at`。如果標頭比最後修改的時間更新，則此操作將返回“304 Not Modified”響應。否則，它將呈現響應並在其中包含`Last-Modified`標頭。

通常，此機制是在每個客戶端基礎上使用的。`Rack::Cache`允許我們在客戶端之間共享此緩存機制。我們可以在調用`stale?`時啟用跨客戶端緩存：

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end
end
```

這意味著`Rack::Cache`將在Rails緩存中存儲URL的`Last-Modified`值，並在任何後續對相同URL的入站請求中添加`If-Modified-Since`標頭。

可以將其視為使用HTTP語義的頁面緩存。

### 使用 Rack::Sendfile

當您在Rails控制器中使用`send_file`方法時，它會設置`X-Sendfile`標頭。`Rack::Sendfile`負責實際發送文件。

如果您的前端服務器支持加速文件傳送，`Rack::Sendfile`將將實際的文件傳送工作卸載到前端服務器。

您可以使用[`config.action_dispatch.x_sendfile_header`][]在適當環境的配置文件中配置前端服務器用於此目的的標頭名稱。

您可以在[Rack::Sendfile文檔](https://www.rubydoc.info/gems/rack/Rack/Sendfile)中了解有關如何與常用前端服務器一起使用`Rack::Sendfile`的更多信息。

以下是一些常用服務器的此標頭的值，一旦這些服務器配置為支持加速文件傳送：

```ruby
# Apache和lighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

請確保按照`Rack::Sendfile`文檔中的說明配置您的服務器以支持這些選項。

### 使用 ActionDispatch::Request

`ActionDispatch::Request#params`將以JSON格式從客戶端接收參數並在控制器內部的`params`中提供。

要使用此功能，您的客戶端需要使用JSON編碼的參數發出請求，並將`Content-Type`指定為`application/json`。

以下是使用jQuery的示例：

```js
jQuery.ajax({
  type: 'POST',
  url: '/people',
  dataType: 'json',
  contentType: 'application/json',
  data: JSON.stringify({ person: { firstName: "Yehuda", lastName: "Katz" } }),
  success: function(json) { }
});
```

`ActionDispatch::Request`將檢測到`Content-Type`，並且您的參數將是：

```ruby
{ person: { firstName: "Yehuda", lastName: "Katz" } }
```

### 使用會話中間件

以下用於會話管理的中間件在API應用程序中被排除，因為它們通常不需要會話。如果您的API客戶端是瀏覽器，您可能需要將其中一個添加回去：

- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

將它們添加回去的技巧是，默認情況下，它們在添加時會傳遞`session_options`（包括會話密鑰），因此您不能只添加一個`session_store.rb`初始化程序，添加`use ActionDispatch::Session::CookieStore`並使會話正常運行。（明確地說明：會話可能會正常工作，但會忽略會話選項，即會話密鑰將默認為`_session_id`）

您將不得不在構建中間件之前的某個地方（例如`config/application.rb`）設置相關選項，並將它們傳遞給您首選的中間件，如下所示：

```ruby
# 這也為下面的使用配置session_options
config.session_store :cookie_store, key: '_interslice_session'

# 所有會話管理所需（無論session_store如何）
config.middleware.use ActionDispatch::Cookies

config.middleware.use config.session_store, config.session_options
```

### 其他中間件

Rails附帶了一些其他中間件，您可能希望在API應用程序中使用，特別是如果您的API客戶端是瀏覽器：

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`

可以通過以下方式添加任何這些中間件：

```ruby
config.middleware.use Rack::MethodOverride
```

### 刪除中間件

如果您不想使用API-only中默認包含的中間件，可以使用以下方法刪除它：
```ruby
config.middleware.delete ::Rack::Sendfile
```

請注意，刪除這些中間件將會移除 Action Controller 中的某些功能支援。

選擇控制器模組
---------------------------

API 應用程式（使用 `ActionController::API`）預設會附帶以下控制器模組：

|   |   |
|---|---|
| `ActionController::UrlFor` | 提供 `url_for` 和相似的輔助方法。 |
| `ActionController::Redirecting` | 支援 `redirect_to`。 |
| `AbstractController::Rendering` 和 `ActionController::ApiRendering` | 基本的渲染支援。 |
| `ActionController::Renderers::All` | 支援 `render :json` 和相關方法。 |
| `ActionController::ConditionalGet` | 支援 `stale?`。 |
| `ActionController::BasicImplicitRender` | 確保如果沒有明確的回應，則返回一個空回應。 |
| `ActionController::StrongParameters` | 支援與 Active Model 大量賦值結合的參數過濾。 |
| `ActionController::DataStreaming` | 支援 `send_file` 和 `send_data`。 |
| `AbstractController::Callbacks` | 支援 `before_action` 和相似的輔助方法。 |
| `ActionController::Rescue` | 支援 `rescue_from`。 |
| `ActionController::Instrumentation` | 支援 Action Controller 定義的儀器鉤子（有關詳細資訊，請參閱 [儀器鉤子指南](active_support_instrumentation.html#action-controller)）。 |
| `ActionController::ParamsWrapper` | 將參數哈希包裝成嵌套哈希，這樣您就不必為發送 POST 請求指定根元素。
| `ActionController::Head` | 支援僅回傳標頭而無內容的回應。 |

其他插件可能會添加其他模組。您可以在 Rails 控制台中獲取所有包含在 `ActionController::API` 中的模組列表：

```irb
irb> ActionController::API.ancestors - ActionController::Metal.ancestors
=> [ActionController::API,
    ActiveRecord::Railties::ControllerRuntime,
    ActionDispatch::Routing::RouteSet::MountedHelpers,
    ActionController::ParamsWrapper,
    ... ,
    AbstractController::Rendering,
    ActionView::ViewPaths]
```

### 添加其他模組

所有 Action Controller 模組都知道它們的相依模組，因此您可以隨意將任何模組包含到您的控制器中，所有相依項目也將被包含和設定。

一些常見的模組您可能想要添加：

- `AbstractController::Translation`：支援 `l` 和 `t` 本地化和翻譯方法。
- 支援基本、摘要或令牌 HTTP 認證：
  * `ActionController::HttpAuthentication::Basic::ControllerMethods`
  * `ActionController::HttpAuthentication::Digest::ControllerMethods`
  * `ActionController::HttpAuthentication::Token::ControllerMethods`
- `ActionView::Layouts`：在渲染時支援佈局。
- `ActionController::MimeResponds`：支援 `respond_to`。
- `ActionController::Cookies`：支援 `cookies`，包括對簽名和加密 cookie 的支援。這需要 cookies 中間件。
- `ActionController::Caching`：為 API 控制器支援視圖快取。請注意，您需要手動在控制器中指定快取存儲，如下所示：

    ```ruby
    class ApplicationController < ActionController::API
      include ::ActionController::Caching
      self.cache_store = :mem_cache_store
    end
    ```

    Rails *不會*自動傳遞此配置。

最佳的添加模組的地方是在您的 `ApplicationController` 中，但您也可以將模組添加到個別的控制器中。
[`config.debug_exception_response_format`]: configuring.html#config-debug-exception-response-format
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
