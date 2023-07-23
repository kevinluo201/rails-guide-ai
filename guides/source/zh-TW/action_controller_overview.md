**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3529115f04b9d5fe01401105d9c154e2
Action Controller 概述
==========================

在本指南中，您將學習控制器的工作原理以及它們如何適應應用程序中的請求週期。

閱讀本指南後，您將了解如何：

* 跟隨請求通過控制器的流程。
* 限制傳遞給控制器的參數。
* 在會話或 cookie 中存儲數據，以及原因。
* 使用過濾器在請求處理期間執行代碼。
* 使用 Action Controller 內置的 HTTP 身份驗證。
* 直接將數據流式傳輸到用戶的瀏覽器。
* 過濾敏感參數，以便它們不會出現在應用程序的日誌中。
* 處理在請求處理期間可能引發的異常。
* 使用內置的健康檢查端點進行負載均衡器和正常運行時間監控。

--------------------------------------------------------------------------------

控制器的功能是什麼？
--------------------------

Action Controller 是 [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) 中的 C。在路由器確定了要用於請求的控制器之後，控制器負責理解請求並生成適當的輸出。幸運的是，Action Controller 為您完成了大部分的基礎工作，並使用智能約定使這一切變得盡可能簡單明了。

對於大多數常規的 [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer) 應用程序，控制器將接收請求（作為開發人員，您看不到這一點），從模型中提取或保存數據，並使用視圖創建 HTML 輸出。如果您的控制器需要以稍微不同的方式進行操作，那也沒問題，這只是控制器工作的最常見方式。

因此，控制器可以被視為模型和視圖之間的中間人。它使模型數據可用於視圖，以便將該數據顯示給用戶，並將用戶數據保存或更新到模型中。

注意：有關路由過程的更多詳細信息，請參閱 [Rails 從外到內的路由](routing.html)。

控制器命名慣例
----------------------------

Rails 中控制器的命名慣例偏向於將控制器名稱的最後一個單詞變成複數形式，儘管這不是強制要求的（例如 `ApplicationController`）。例如，`ClientsController` 比 `ClientController` 更好，`SiteAdminsController` 比 `SiteAdminController` 或 `SitesAdminsController` 更好，依此類推。

遵循這個慣例將使您能夠使用默認的路由生成器（例如 `resources` 等）而無需限定每個 `:path` 或 `:controller`，並且將保持命名路由助手在整個應用程序中的一致使用。有關詳細信息，請參閱 [佈局和渲染指南](layouts_and_rendering.html)。

注意：控制器的命名慣例與模型的命名慣例不同，模型的命名慣例要求使用單數形式。

方法和動作
-------------------

控制器是一個 Ruby 類，它繼承自 `ApplicationController`，並且像任何其他類一樣具有方法。當您的應用程序接收到請求時，路由將確定要運行的控制器和動作，然後 Rails 將創建該控制器的實例並運行與動作同名的方法。

```ruby
class ClientsController < ApplicationController
  def new
  end
end
```

例如，如果用戶在您的應用程序中訪問 `/clients/new` 以添加新客戶，Rails 將創建 `ClientsController` 的實例並調用其 `new` 方法。請注意，上面示例中的空方法也可以正常工作，因為除非動作另有規定，否則 Rails 將默認渲染 `new.html.erb` 視圖。通過創建新的 `Client`，`new` 方法可以在視圖中使 `@client` 實例變量可訪問：

```ruby
def new
  @client = Client.new
end
```

[佈局和渲染指南](layouts_and_rendering.html) 對此進行了更詳細的解釋。

`ApplicationController` 繼承自 [`ActionController::Base`][]，它定義了許多有用的方法。本指南將涵蓋其中一些方法，但如果您想知道其中的內容，可以在 [API 文檔](https://api.rubyonrails.org/classes/ActionController.html) 或源代碼中查看所有方法。

只有公共方法可以作為動作調用。最佳實踐是將不打算作為動作的方法（使用 `private` 或 `protected`）降低可見性，例如輔助方法或過濾器。

警告：某些方法名被 Action Controller 保留。意外地將它們重新定義為動作，甚至作為輔助方法，可能會導致 `SystemStackError`。如果您的控制器僅限於 RESTful [資源路由][] 動作，則不需要擔心這個問題。

注意：如果必須將保留方法用作動作名稱，一種解決方法是使用自定義路由將保留方法名映射到非保留動作方法。
[資源路由]: routing.html#resource-routing-the-rails-default

參數
----------

您可能希望在控制器操作中訪問由用戶或其他參數傳遞的數據。網絡應用程序中有兩種可能的參數類型。第一種是作為URL的一部分發送的參數，稱為查詢字符串參數。查詢字符串是URL中"?"之後的所有內容。第二種類型的參數通常被稱為POST數據。這些信息通常來自用戶填寫的HTML表單。它被稱為POST數據，因為它只能作為HTTP POST請求的一部分發送。Rails不對查詢字符串參數和POST參數進行任何區分，兩者都可以在控制器的[`params`][]哈希中使用：

```ruby
class ClientsController < ApplicationController
  # 這個操作使用查詢字符串參數，因為它是由HTTP GET請求運行的，
  # 但這不會影響參數的訪問方式。用於此操作的URL將如下所示，
  # 以列出已激活的客戶：/clients?status=activated
  def index
    if params[:status] == "activated"
      @clients = Client.activated
    else
      @clients = Client.inactivated
    end
  end

  # 這個操作使用POST參數。它們很可能來自用戶提交的HTML表單。
  # 這個RESTful請求的URL將是"/clients"，數據將作為請求主體的一部分發送。
  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client
    else
      # 這行代碼覆蓋了默認的渲染行為，默認情況下將渲染"create"視圖。
      render "new"
    end
  end
end
```


### 哈希和數組參數

`params`哈希不僅限於一維鍵和值。它可以包含嵌套的數組和哈希。要發送一個值的數組，請在鍵名後面添加一對空的方括號"[]"：

```
GET /clients?ids[]=1&ids[]=2&ids[]=3
```

注意：此示例中的實際URL將編碼為"/clients?ids%5b%5d=1&ids%5b%5d=2&ids%5b%5d=3"，因為"["和"]"字符在URL中不允許。大多數情況下，您不必擔心這一點，因為瀏覽器會自動對其進行編碼，Rails會自動解碼，但如果您發現自己必須手動將這些請求發送到服務器，請記住這一點。

`params[:ids]`的值現在將是`["1", "2", "3"]`。請注意，參數值始終是字符串；Rails不會嘗試猜測或轉換類型。

注意：在`params`中，像`[nil]`或`[nil, nil, ...]`這樣的值會被默認替換為`[]`，出於安全原因。有關更多信息，請參閱[安全指南](security.html#unsafe-query-generation)。

要發送一個哈希，請將鍵名包含在方括號內：

```html
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
```

提交此表單時，`params[:client]`的值將是`{ "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } }`。請注意，`params[:client][:address]`中有一個嵌套的哈希。

`params`對象的行為類似於哈希，但允許您將符號和字符串互換使用作為鍵。

### JSON參數

如果您的應用程序公開了API，您可能會接受JSON格式的參數。如果您的請求的"Content-Type"標頭設置為"application/json"，Rails將自動將參數加載到`params`哈希中，您可以像平常一樣訪問它們。

例如，如果您發送以下JSON內容：

```json
{ "company": { "name": "acme", "address": "123 Carrot Street" } }
```

您的控制器將接收到`params[:company]`作為`{ "name" => "acme", "address" => "123 Carrot Street" }`。

此外，如果您在初始化程序中打開了`config.wrap_parameters`，或者在控制器中調用了[`wrap_parameters`][]，您可以安全地省略JSON參數中的根元素。在這種情況下，參數將被克隆並包裝在基於控制器名稱選擇的鍵中。因此，上述JSON請求可以編寫為：

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

假設您將數據發送到`CompaniesController`，則它將被包裝在`:company`鍵中，如下所示：
```ruby
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: "123 Carrot Street" } }
```

您可以根據[API文件](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)自定義鍵的名稱或要包裝的特定參數。

注意：對於解析XML參數的支援已經被提取到名為`actionpack-xml_parser`的gem中。


### 路由參數

`params`哈希表始終包含`:controller`和`:action`鍵，但您應該使用[`controller_name`][]和[`action_name`][]方法來訪問這些值。路由定義的任何其他參數，例如`:id`，也將可用。例如，考慮一個客戶列表，列表可以顯示活動或非活動客戶。我們可以添加一個路由，以在“漂亮”的URL中捕獲`:status`參數：

```ruby
get '/clients/:status', to: 'clients#index', foo: 'bar'
```

在這種情況下，當用戶打開URL`/clients/active`時，`params[:status]`將被設置為“active”。當使用此路由時，`params[:foo]`也將被設置為“bar”，就像它是在查詢字符串中傳遞的一樣。您的控制器還將收到`params[:action]`為“index”和`params[:controller]`為“clients”。


### `default_url_options`

您可以通過在控制器中定義一個名為`default_url_options`的方法來為URL生成設置全局默認參數。這樣的方法必須返回一個帶有所需默認值的哈希，其鍵必須是符號：

```ruby
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

這些選項將用作生成URL的起點，因此可能會被傳遞給`url_for`調用的選項覆蓋。

如果您在`ApplicationController`中定義了`default_url_options`，如上面的示例，則這些默認值將用於所有URL生成。該方法也可以在特定控制器中定義，這樣它只會影響在那裡生成的URL。

在給定的請求中，該方法實際上並不會為每個生成的URL調用一次。出於性能原因，返回的哈希被緩存，每個請求最多只有一次調用。

### 強參數

使用強參數，Action Controller參數在未經許可之前禁止用於Active Model的批量賦值。這意味著您必須對要進行批量更新的屬性做出明確的許可決策。這是一種更好的安全實踐，有助於防止意外允許用戶更新敏感的模型屬性。

此外，參數可以被標記為必需的，並且將通過預定義的raise/rescue流程流動，如果未傳遞所有必需的參數，將返回400 Bad Request。

```ruby
class PeopleController < ActionController::Base
  # 這將引發ActiveModel::ForbiddenAttributesError異常，
  # 因為它在沒有明確許可的情況下使用了批量賦值。
  def create
    Person.create(params[:person])
  end

  # 只要參數中有一個person鍵，這將通過，否則它將引發
  # ActionController::ParameterMissing異常，該異常將被
  # ActionController::Base捕獲並轉換為400 Bad
  # Request錯誤。
  def update
    person = current_account.people.find(params[:id])
    person.update!(person_params)
    redirect_to person
  end

  private
    # 使用私有方法封裝可允許的參數是一種良好的模式，因為您可以在create和update之間重用相同的許可列表。此外，您可以使用特定用戶的許可屬性對此方法進行特殊化。
    def person_params
      params.require(:person).permit(:name, :age)
    end
end
```

#### 允許的標量值

像這樣調用[`permit`][]：

```ruby
params.permit(:id)
```

如果`params`中出現並且具有允許的標量值，則允許指定的鍵（`:id`）包含在內。否則，該鍵將被過濾掉，因此無法注入數組、哈希或任何其他對象。

允許的標量類型包括`String`、`Symbol`、`NilClass`、`Numeric`、`TrueClass`、`FalseClass`、`Date`、`Time`、`DateTime`、`StringIO`、`IO`、`ActionDispatch::Http::UploadedFile`和`Rack::Test::UploadedFile`。

要聲明`params`中的值必須是允許的標量值數組，將鍵映射為空數組：

```ruby
params.permit(id: [])
```

有時不可能或不方便聲明哈希參數的有效鍵或其內部結構。只需映射到空哈希：

```ruby
params.permit(preferences: {})
```

但要小心，因為這打開了任意輸入的大門。在這種情況下，`permit`確保返回結構中的值是允許的標量，並過濾掉其他任何內容。
要允許整個參數的哈希，可以使用 [`permit!`][] 方法：

```ruby
params.require(:log_entry).permit!
```

這標記了 `:log_entry` 參數哈希及其任何子哈希為允許的，並不檢查允許的純量，任何內容都會被接受。在使用 `permit!` 時要非常小心，因為它將允許所有當前和未來的模型屬性進行批量賦值。

#### 嵌套參數

您也可以對嵌套參數使用 `permit`，例如：

```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

此聲明允許 `name`、`emails` 和 `friends` 屬性。預期 `emails` 將是一個允許的純量值數組，而 `friends` 將是一個具有特定屬性的資源數組：它們應該具有一個 `name` 屬性（允許任何純量值），一個 `hobbies` 屬性作為允許的純量值數組，以及一個 `family` 屬性，該屬性僅限於具有 `name`（這裡也允許任何允許的純量值）。

#### 更多範例

您可能還想在 `new` 操作中使用允許的屬性。這會引發一個問題，即在調用 `new` 時，您無法對根鍵使用 [`require`][]，因為通常情況下，它不存在：

```ruby
# 使用 `fetch` 您可以提供一個默認值並從那裡使用 Strong Parameters API。
params.fetch(:blog, {}).permit(:title, :author)
```

模型類方法 `accepts_nested_attributes_for` 允許您更新和刪除相關記錄。這是基於 `id` 和 `_destroy` 參數：

```ruby
# 允許 :id 和 :_destroy
params.require(:author).permit(:name, books_attributes: [:title, :id, :_destroy])
```

具有整數鍵的哈希處理方式不同，您可以將屬性聲明為直接子級。當您將 `accepts_nested_attributes_for` 與 `has_many` 關聯結合使用時，會得到這些類型的參數：

```ruby
# 允許以下數據：
# {"book" => {"title" => "Some Book",
#             "chapters_attributes" => { "1" => {"title" => "First Chapter"},
#                                        "2" => {"title" => "Second Chapter"}}}}

params.require(:book).permit(:title, chapters_attributes: [:title])
```

想像一個情境，您有代表產品名稱的參數，以及與該產品關聯的任意數據的哈希，您希望允許產品名稱屬性以及整個數據哈希：

```ruby
def product_params
  params.require(:product).permit(:name, data: {})
end
```

#### 超出 Strong Parameters 的範圍

強參數 API 是針對最常見的使用情況設計的。它並不意味著是解決所有參數過濾問題的萬能解決方案。但是，您可以輕鬆地將 API 與自己的代碼混合使用，以適應您的情況。

Session
-------

您的應用程序為每個用戶保留一個會話，您可以在其中存儲少量的數據，這些數據將在請求之間保留。會話僅在控制器和視圖中可用，並且可以使用多種不同的存儲機制之一：

* [`ActionDispatch::Session::CookieStore`][] - 將所有數據存儲在客戶端。
* [`ActionDispatch::Session::CacheStore`][] - 將數據存儲在 Rails 緩存中。
* [`ActionDispatch::Session::MemCacheStore`][] - 將數據存儲在 memcached 集群中（這是一個遺留實現；請考慮改用 `CacheStore`）。
* [`ActionDispatch::Session::ActiveRecordStore`][activerecord-session_store] - 使用 Active Record 將數據存儲在數據庫中（需要 [`activerecord-session_store`][activerecord-session_store] gem）。
* 自定義存儲或由第三方 gem 提供的存儲

所有會話存儲都使用 cookie 存儲每個會話的唯一 ID（您必須使用 cookie，Rails 不允許您將會話 ID 作為 URL 參數傳遞，因為這樣不安全）。

對於大多數存儲，此 ID 用於在服務器上查找會話數據，例如在數據庫表中。有一個例外，那就是默認和推薦的會話存儲 - CookieStore - 它將所有會話數據存儲在 cookie 中本身（如果需要，仍然可以使用 ID）。這樣做的好處是非常輕量級，並且在新應用程序中使用會話時不需要任何設置。 cookie 數據在加密後具有防篡改功能。它還被加密，因此任何可以訪問它的人都無法讀取其內容（如果已經被編輯，Rails 將不接受它）。

CookieStore 可以存儲約 4 KB 的數據 - 遠少於其他存儲方式 - 但通常足夠使用。無論應用程序使用哪種會話存儲，都應該避免存儲大量數據在會話中。特別是應該避免在會話中存儲複雜對象（例如模型實例），因為服務器可能無法在請求之間重新組合它們，這將導致錯誤。
如果您的使用者會話不存儲關鍵數據或不需要長時間存在（例如，如果您只是使用快閃進行消息傳遞），您可以考慮使用`ActionDispatch::Session::CacheStore`。這將使用您為應用程序配置的緩存實現來存儲會話。這樣做的好處是您可以使用現有的緩存基礎設施來存儲會話，而無需進行任何額外的設置或管理。當然，缺點是會話是短暫的，可能隨時消失。

在[安全指南](security.html)中了解有關會話存儲的更多信息。

如果您需要不同的會話存儲機制，可以在初始化程序中更改它：

```ruby
Rails.application.config.session_store :cache_store
```

有關更多信息，請參閱[配置指南](configuring.html#config-session-store)中的[`config.session_store`](configuring.html#config-session-store)。

Rails在簽署會話數據時設置了會話密鑰（cookie的名稱）。這些也可以在初始化程序中更改：

```ruby
# 當您修改此文件時，請確保重新啟動您的服務器。
Rails.application.config.session_store :cookie_store, key: '_your_app_session'
```

您還可以傳遞一個`:domain`鍵，並指定cookie的域名：

```ruby
# 當您修改此文件時，請確保重新啟動您的服務器。
Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: ".example.com"
```

Rails在`config/credentials.yml.enc`中為CookieStore設置了用於簽署會話數據的密鑰。可以使用`bin/rails credentials:edit`來更改它。

```yaml
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# 用於Rails中所有MessageVerifiers的基本密鑰，包括保護cookie的密鑰。
secret_key_base: 492f...
```

注意：在使用`CookieStore`時更改`secret_key_base`將使所有現有會話失效。



### 訪問會話

在控制器中，您可以通過`session`實例方法訪問會話。

注意：會話是延遲加載的。如果您的操作代碼中不訪問會話，它們將不會被加載。因此，您永遠不需要禁用會話，只需不訪問它們即可。

會話值使用鍵/值對（如哈希）存儲：

```ruby
class ApplicationController < ActionController::Base
  private
    # 通過存儲在鍵為:current_user_id的會話中的ID查找用戶
    # 這是處理Rails應用程序中用戶登錄的常見方式；登錄設置會話值，
    # 登出則刪除它。
    def current_user
      @_current_user ||= session[:current_user_id] &&
        User.find_by(id: session[:current_user_id])
    end
end
```

要將某些內容存儲在會話中，只需像哈希一樣將其分配給鍵：

```ruby
class LoginsController < ApplicationController
  # "創建"一個登錄，也就是"登錄用戶"
  def create
    if user = User.authenticate(params[:username], params[:password])
      # 將用戶ID保存在會話中，以便在後續請求中使用
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end
end
```

要從會話中刪除某些內容，刪除鍵/值對：

```ruby
class LoginsController < ApplicationController
  # "刪除"一個登錄，也就是"登出用戶"
  def destroy
    # 從會話中刪除用戶ID
    session.delete(:current_user_id)
    # 清除緩存的當前用戶
    @_current_user = nil
    redirect_to root_url, status: :see_other
  end
end
```

要重置整個會話，請使用[`reset_session`][]。


### 快閃

快閃是會話的一個特殊部分，每次請求都會被清除。這意味著存儲在其中的值只能在下一個請求中使用，這對於傳遞錯誤消息等非常有用。

可以通過[`flash`][]方法訪問快閃。與會話一樣，快閃被表示為哈希。

讓我們以登出的行為作為示例。控制器可以發送一條消息，該消息將在下一個請求中顯示給用戶：

```ruby
class LoginsController < ApplicationController
  def destroy
    session.delete(:current_user_id)
    flash[:notice] = "您已成功登出。"
    redirect_to root_url, status: :see_other
  end
end
```

請注意，也可以在重定向中分配快閃消息。您可以分配`:notice`、`:alert`或通用的`:flash`：

```ruby
redirect_to root_url, notice: "您已成功登出。"
redirect_to root_url, alert: "您被困在這裡了！"
redirect_to root_url, flash: { referral_code: 1234 }
```

`destroy`操作將重定向到應用程序的`root_url`，消息將在那裡顯示。請注意，下一個操作完全由上一個操作放入快閃中的內容決定是否執行任何操作。根據慣例，在應用程序的佈局中顯示快閃中的任何錯誤警報或通知：

```erb
<html>
  <!-- <head/> -->
  <body>
    <% flash.each do |name, msg| -%>
      <%= content_tag :div, msg, class: name %>
    <% end -%>

    <!-- more content -->
  </body>
</html>
```

這樣，如果一個動作設置了一個通知或警告消息，佈局將自動顯示它。

您可以傳遞任何會話可以存儲的內容；您不僅僅限於通知和警告：

```erb
<% if flash[:just_signed_up] %>
  <p class="welcome">歡迎來到我們的網站！</p>
<% end %>
```

如果您希望將flash值傳遞到另一個請求，請使用[`flash.keep`][]：

```ruby
class MainController < ApplicationController
  # 假設此動作對應於root_url，但您希望所有請求都被重定向到UsersController#index。
  # 如果一個動作設置了flash並重定向到這裡，當另一個重定向發生時，這些值通常會丟失，但您可以使用'keep'使其持續存在另一個請求中。
  def index
    # 將保留所有flash值。
    flash.keep

    # 您也可以使用一個鍵只保留某種類型的值。
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```


#### `flash.now`

默認情況下，將值添加到flash將使它們在下一個請求中可用，但有時您可能希望在同一個請求中訪問這些值。例如，如果`create`動作無法保存資源並直接渲染`new`模板，這不會導致新的請求，但您仍然可能希望使用flash顯示一條消息。為此，您可以像使用普通的flash一樣使用[`flash.now`][]：

```ruby
class ClientsController < ApplicationController
  def create
    @client = Client.new(client_params)
    if @client.save
      # ...
    else
      flash.now[:error] = "無法保存客戶"
      render action: "new"
    end
  end
end
```


Cookies
-------

您的應用程序可以在客戶端上存儲少量數據 - 稱為cookies - 這些數據將在請求和會話之間保留。Rails通過[`cookies`][]方法輕鬆訪問cookies，該方法 - 就像`session`一樣 - 像一個哈希表一樣工作：

```ruby
class CommentsController < ApplicationController
  def new
    # 如果在cookie中存儲了評論者的名字，自動填充評論者的名字
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:notice] = "感謝您的評論！"
      if params[:remember_name]
        # 記住評論者的名字。
        cookies[:commenter_name] = @comment.author
      else
        # 刪除評論者名字的cookie，如果有的話。
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

請注意，雖然對於會話值，您可以將鍵設置為`nil`，以刪除cookie值，您應該使用`cookies.delete(:key)`。

Rails還提供了一個簽名cookie jar和一個加密cookie jar來存儲敏感數據。簽名cookie jar在cookie值上附加了一個加密簽名，以保護其完整性。加密cookie jar在簽名的基礎上對值進行加密，以防止最終用戶讀取它們。有關詳細信息，請參閱[API文檔](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html)。

這些特殊的cookie jar使用序列化器將分配的值序列化為字符串，在讀取時將其反序列化為Ruby對象。您可以通過[`config.action_dispatch.cookies_serializer`][]指定要使用的序列化器。

新應用程序的默認序列化器是`:json`。請注意，JSON對於往返Ruby對象的支持有限。例如，`Date`，`Time`和`Symbol`對象（包括`Hash`鍵）將被序列化和反序列化為`String`：

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

如果您需要存儲這些或更複雜的對象，您可能需要在後續請求中手動轉換它們的值。

如果使用cookie會話存儲，上述內容也適用於`session`和`flash`哈希。


Rendering
---------

ActionController使渲染HTML、XML或JSON數據變得輕而易舉。如果您使用脚手架生成了一個控制器，它看起來可能是這樣的：

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @users }
      format.json { render json: @users }
    end
  end
end
```

您可能會注意到上面的代碼中，我們使用的是`render xml: @users`，而不是`render xml: @users.to_xml`。如果對象不是字符串，那麼Rails將自動為我們調用`to_xml`。
你可以在[版面配置和渲染指南](layouts_and_rendering.html)中了解更多有關渲染的資訊。

過濾器
-------

過濾器是在控制器動作之前、之後或周圍運行的方法。

過濾器是繼承的，所以如果你在`ApplicationController`上設置了一個過濾器，它將在應用程序中的每個控制器上運行。

"before"過濾器通過[`before_action`][]註冊。它們可以停止請求週期。一個常見的"before"過濾器是要求用戶在運行動作之前登錄。你可以這樣定義過濾器方法：

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private
    def require_login
      unless logged_in?
        flash[:error] = "您必須登錄才能訪問此部分"
        redirect_to new_login_url # 停止請求週期
      end
    end
end
```

該方法只是將錯誤消息存儲在快閃中，並在用戶未登錄時重定向到登錄表單。如果"before"過濾器渲染或重定向，動作將不運行。如果有其他過濾器在該過濾器之後運行，它們也將被取消。

在這個例子中，過濾器被添加到`ApplicationController`中，因此應用程序中的所有控制器都繼承它。這將使應用程序中的所有內容都需要用戶登錄才能使用。出於明顯的原因（用戶首先無法登錄！），並不是所有的控制器或動作都應該需要這個。您可以使用[`skip_before_action`][]來防止該過濾器在特定動作之前運行：

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

現在，`LoginsController`的`new`和`create`動作將像以前一樣工作，而不需要用戶登錄。`：only`選項用於僅跳過這些動作的過濾器，還有一個`：except`選項可以反過來使用。這些選項也可以在添加過濾器時使用，因此您可以添加一個僅對選定動作運行的過濾器。

注意：多次使用不同選項調用相同的過濾器將不起作用，因為最後一個過濾器定義將覆蓋之前的定義。


### "After"過濾器和"around"過濾器

除了"before"過濾器之外，您還可以在動作執行後運行過濾器，或者在動作之前和之後都運行。

"after"過濾器通過[`after_action`][]註冊。它們與"before"過濾器類似，但由於動作已經運行，它們可以訪問即將發送給客戶端的響應數據。顯然，"after"過濾器無法阻止動作運行。請注意，"after"過濾器僅在成功運行動作時執行，而不在請求週期中引發異常時執行。

"around"過濾器通過[`around_action`][]註冊。它們負責通過yield運行其相關聯的動作，類似於Rack中間件的工作方式。

例如，在具有審批工作流程的網站中，管理員可以通過在事務中應用更改來輕鬆預覽它們：

```ruby
class ChangesController < ApplicationController
  around_action :wrap_in_transaction, only: :show

  private
    def wrap_in_transaction
      ActiveRecord::Base.transaction do
        begin
          yield
        ensure
          raise ActiveRecord::Rollback
        end
      end
    end
end
```

請注意，"around"過濾器還包裹了渲染。特別是，在上面的例子中，如果視圖本身從數據庫中讀取（例如通過範圍），它將在事務中進行，從而將數據呈現為預覽。

您可以選擇不yield並自己構建響應，這樣動作就不會運行。


### 使用過濾器的其他方法

雖然使用私有方法並使用`before_action`、`after_action`或`around_action`將過濾器添加到過濾器最常見的方法，但還有其他兩種方法可以完成相同的事情。

第一種方法是直接使用`*_action`方法的塊。該塊接收控制器作為參數。上面的`require_login`過濾器可以重寫為使用塊：

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless controller.send(:logged_in?)
      flash[:error] = "您必須登錄才能訪問此部分"
      redirect_to new_login_url
    end
  end
end
```

請注意，該過濾器在這種情況下使用`send`，因為`logged_in?`方法是私有的，並且該過濾器不在控制器的範圍內運行。這不是推薦的實現這個特定過濾器的方式，但在更簡單的情況下，這可能是有用的。
對於 `around_action`，該區塊還會在 `action` 中執行：

```ruby
around_action { |_controller, action| time(&action) }
```

第二種方法是使用一個類別（實際上，任何回應正確方法的物件都可以）來處理過濾。這在更複雜且無法使用其他兩種方法以可讀性和可重複使用的方式實現的情況下非常有用。例如，您可以重新編寫登入過濾器以使用類別：

```ruby
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.before(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "您必須登入才能訪問此區域"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

同樣，這對於此過濾器來說並不是一個理想的範例，因為它不在控制器的範圍內運行，而是作為參數傳遞給控制器。過濾器類必須實現與過濾器相同名稱的方法，因此對於 `before_action` 過濾器，類必須實現 `before` 方法，以此類推。`around` 方法必須使用 `yield` 執行操作。

防止請求偽造
--------------------------

跨站請求偽造是一種攻擊類型，其中一個網站欺騙用戶在另一個網站上進行請求，可能在用戶不知情或未經許可的情況下添加、修改或刪除該網站上的數據。

避免這種情況的第一步是確保所有「破壞性」操作（創建、更新和刪除）只能通過非 GET 請求訪問。如果您遵循 RESTful 慣例，則已經在這樣做了。然而，惡意網站仍然可以輕鬆地向您的網站發送非 GET 請求，這就是請求偽造保護的作用。正如其名，它保護免受偽造的請求。

這樣做的方法是在每個請求中添加一個只有您的服務器知道的不可猜測的令牌。這樣，如果沒有正確的令牌，請求將被拒絕訪問。

如果您生成這樣的表單：

```erb
<%= form_with model: @user do |form| %>
  <%= form.text_field :username %>
  <%= form.text_field :password %>
<% end %>
```

您將看到令牌作為隱藏字段添加：

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- fields -->
</form>
```

Rails 會將此令牌添加到使用 [form helpers](form_helpers.html) 生成的每個表單中，因此大多數情況下您不必擔心它。如果您手動編寫表單或需要出於其他原因添加令牌，可以通過 `form_authenticity_token` 方法獲取：

`form_authenticity_token` 生成一個有效的身份驗證令牌。這在 Rails 不會自動添加它的地方很有用，例如在自定義 Ajax 調用中。

[Security Guide](security.html) 中有更多相關資訊，以及開發 Web 應用程序時應該注意的許多其他安全問題。

請求和響應對象
--------------------------------

在每個控制器中，有兩個存取器方法指向與當前執行的請求週期相關聯的請求和響應對象。[`request`][] 方法包含 [`ActionDispatch::Request`][] 的實例，而 [`response`][] 方法返回表示將發送回客戶端的響應對象。


### `request` 對象

請求對象包含有關從客戶端發出的請求的許多有用信息。要獲取可用方法的完整列表，請參閱 [Rails API documentation](https://api.rubyonrails.org/classes/ActionDispatch/Request.html) 和 [Rack Documentation](https://www.rubydoc.info/github/rack/rack/Rack/Request)。您可以在此對象上訪問的屬性包括：

| `request` 的屬性                     | 目的                                                                          |
| ----------------------------------------- | -------------------------------------------------------------------------------- |
| `host`                                    | 此請求使用的主機名。                                              |
| `domain(n=2)`                             | 主機名的前 `n` 段，從右邊開始（TLD）。            |
| `format`                                  | 客戶端請求的內容類型。                                        |
| `method`                                  | 請求使用的 HTTP 方法。                                            |
| `get?`, `post?`, `patch?`, `put?`, `delete?`, `head?` | 如果 HTTP 方法是 GET/POST/PATCH/PUT/DELETE/HEAD，則返回 true。   |
| `headers`                                 | 返回包含與請求關聯的標頭的哈希。               |
| `port`                                    | 用於請求的端口號（整數）。                                  |
| `protocol`                                | 返回包含使用的協議加上「://」的字符串，例如「http://」。 |
| `query_string`                            | URL 的查詢字符串部分，即「?」之後的所有內容。                    |
| `remote_ip`                               | 用戶端的 IP 地址。                                                    |
| `url`                                     | 用於請求的完整 URL。                                             |
#### `path_parameters`、`query_parameters`和`request_parameters`

Rails將請求中傳遞的所有參數收集在`params`哈希中，無論它們是作為查詢字符串的一部分還是作為POST請求的主體。請求對象具有三個訪問器，根據它們的來源，可以讓您訪問這些參數。[`query_parameters`][]哈希包含作為查詢字符串的一部分發送的參數，而[`request_parameters`][]哈希包含作為POST請求的主體發送的參數。[`path_parameters`][]哈希包含被路由識別為屬於此特定控制器和操作的路徑的一部分的參數。


### `response`對象

通常不直接使用響應對象，而是在執行操作和渲染返回給用戶的數據時構建起來，但有時（例如在後過濾器中）直接訪問響應可能很有用。這些訪問器方法中的一些也具有設置器，允許您更改它們的值。要獲得可用方法的完整列表，請參閱[Rails API文檔](https://api.rubyonrails.org/classes/ActionDispatch/Response.html)和[Rack文檔](https://www.rubydoc.info/github/rack/rack/Rack/Response)。

| `response`的屬性 | 目的                                                                 |
| ----------------- | -------------------------------------------------------------------- |
| `body`            | 這是發送回客戶端的數據字符串。通常是HTML。                             |
| `status`          | 響應的HTTP狀態碼，例如200表示成功的請求，404表示文件未找到。          |
| `location`        | 客戶端被重定向到的URL（如果有）。                                     |
| `content_type`    | 響應的內容類型。                                                      |
| `charset`         | 用於響應的字符集。默認為“utf-8”。                                     |
| `headers`         | 用於響應的標頭。                                                      |

#### 設置自定義標頭

如果要為響應設置自定義標頭，則可以使用`response.headers`。標頭屬性是一個將標頭名稱映射到其值的哈希，Rails將自動設置其中一些標頭。如果要添加或更改標頭，只需將其分配給`response.headers`，例如：

```ruby
response.headers["Content-Type"] = "application/pdf"
```

注意：在上述情況下，直接使用`content_type`設置器更合理。

HTTP身份驗證
--------------------

Rails提供了三種內置的HTTP身份驗證機制：

* 基本身份驗證（Basic Authentication）
* 摘要身份驗證（Digest Authentication）
* Token身份驗證（Token Authentication）

### HTTP基本身份驗證

HTTP基本身份驗證是一種被大多數瀏覽器和其他HTTP客戶端支持的身份驗證方案。例如，考慮一個只有在在瀏覽器的HTTP基本對話窗口中輸入用戶名和密碼時才能訪問的管理部分。只需使用一個方法[`http_basic_authenticate_with`][]，就可以使用內置的身份驗證。

```ruby
class AdminsController < ApplicationController
  http_basic_authenticate_with name: "humbaba", password: "5baa61e4"
end
```

有了這個設置，您可以創建從`AdminsController`繼承的命名空間控制器。該過濾器將對這些控制器中的所有操作運行，使用HTTP基本身份驗證保護它們。


### HTTP摘要身份驗證

HTTP摘要身份驗證優於基本身份驗證，因為它不需要客戶端在網絡上發送未加密的密碼（儘管在HTTPS上，HTTP基本身份驗證是安全的）。在Rails中使用摘要身份驗證只需要使用一個方法[`authenticate_or_request_with_http_digest`][]。

```ruby
class AdminsController < ApplicationController
  USERS = { "lifo" => "world" }

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_digest do |username|
        USERS[username]
      end
    end
end
```

如上面的示例所示，`authenticate_or_request_with_http_digest`塊只接受一個參數 - 用戶名。塊返回密碼。從`authenticate_or_request_with_http_digest`返回`false`或`nil`將導致身份驗證失敗。


### HTTP Token身份驗證

HTTP Token身份驗證是一種在HTTP `Authorization`標頭中使用Bearer令牌的方案。有許多可用的令牌格式，描述它們超出了本文檔的範圍。

例如，假設您想要使用事先發行的身份驗證令牌來執行身份驗證和訪問。在Rails中實現令牌身份驗證只需要使用一個方法[`authenticate_or_request_with_http_token`][]。

```ruby
class PostsController < ApplicationController
  TOKEN = "secret"

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
    end
end
```

如上面的示例所示，`authenticate_or_request_with_http_token`塊接受兩個參數 - 令牌和包含從HTTP `Authorization`標頭解析的選項的`Hash`。如果身份驗證成功，塊應返回`true`。在塊中返回`false`或`nil`將導致身份驗證失敗。
串流和檔案下載
----------------------------

有時候您可能想要將檔案傳送給使用者，而不是渲染一個HTML頁面。Rails中的所有控制器都有[`send_data`][]和[`send_file`][]方法，這兩個方法都可以將資料串流到客戶端。`send_file`是一個方便的方法，讓您提供磁碟上的檔案名稱，它會為您串流該檔案的內容。

要將資料串流到客戶端，請使用`send_data`：

```ruby
require "prawn"
class ClientsController < ApplicationController
  # 生成包含客戶資訊的PDF文件並返回給使用者。使用者將以檔案下載的方式獲取PDF。
  def download_pdf
    client = Client.find(params[:id])
    send_data generate_pdf(client),
              filename: "#{client.name}.pdf",
              type: "application/pdf"
  end

  private
    def generate_pdf(client)
      Prawn::Document.new do
        text client.name, align: :center
        text "地址：#{client.address}"
        text "電子郵件：#{client.email}"
      end.render
    end
end
```

上面的範例中的`download_pdf`動作將調用一個私有方法，該方法實際上生成PDF文件並將其作為字串返回。然後，該字串將以檔案下載的方式串流到客戶端，並向使用者建議一個檔案名稱。有時候在將檔案串流給使用者時，您可能不希望他們下載該檔案。以圖片為例，圖片可以嵌入到HTML頁面中。為了告訴瀏覽器該檔案不是用於下載的，您可以將`:disposition`選項設置為"inline"。這個選項的相反和默認值是"attachment"。

### 傳送檔案

如果您想要傳送一個已經存在於磁碟上的檔案，請使用`send_file`方法。

```ruby
class ClientsController < ApplicationController
  # 串流已經生成並存儲在磁碟上的檔案。
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

這將以每次4KB的方式讀取和串流檔案，避免一次性將整個檔案加載到記憶體中。您可以使用`:stream`選項關閉串流，或使用`:buffer_size`選項調整區塊大小。

如果未指定`:type`，則會從`:filename`中指定的檔案擴展名猜測。如果該擴展名的內容類型未註冊，則將使用`application/octet-stream`。

警告：謹慎使用來自客戶端（params、cookies等）的資料來定位磁碟上的檔案，因為這是一個安全風險，可能允許某人獲取他們不應該訪問的檔案。

提示：如果可以將靜態檔案保留在Web伺服器上的公共資料夾中，則不建議通過Rails串流靜態檔案。讓使用者直接使用Apache或其他Web伺服器下載檔案，這樣更有效率，並避免不必要地通過整個Rails堆棧處理請求。

### RESTful下載

雖然`send_data`可以正常工作，但如果您正在創建一個RESTful應用程式，通常不需要為檔案下載創建單獨的動作。在REST術語中，上面的範例中的PDF檔案可以被視為客戶端資源的另一種表示形式。Rails提供了一種簡潔的方式來實現"RESTful"下載。以下是如何重寫範例，使PDF下載成為`show`動作的一部分，而不需要任何串流：

```ruby
class ClientsController < ApplicationController
  # 使用者可以要求以HTML或PDF格式接收此資源。
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

為了使這個範例工作，您必須將PDF的MIME類型添加到Rails中。可以通過將以下行添加到文件`config/initializers/mime_types.rb`中來完成：

```ruby
Mime::Type.register "application/pdf", :pdf
```

注意：配置文件不會在每次請求時重新加載，所以您必須重新啟動伺服器才能使其更改生效。

現在使用者可以通過在URL中添加".pdf"來請求獲取客戶端的PDF版本：

```
GET /clients/1.pdf
```

### 即時串流任意資料

Rails允許您串流不僅僅是檔案。事實上，您可以在回應物件中串流任何您想要的資料。[`ActionController::Live`][]模組允許您與瀏覽器建立持久連接。使用此模組，您將能夠在特定時間點向瀏覽器發送任意資料。
#### 整合直播串流

在你的控制器類別中包含 `ActionController::Live`，將為控制器中的所有動作提供串流資料的能力。你可以像這樣混入這個模組：

```ruby
class MyController < ActionController::Base
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    100.times {
      response.stream.write "hello world\n"
      sleep 1
    }
  ensure
    response.stream.close
  end
end
```

上述程式碼將與瀏覽器保持持續連線，並每隔一秒傳送 100 個訊息 `"hello world\n"`。

在上面的範例中有幾點需要注意。我們需要確保關閉回應串流。若忘記關閉串流，將會永遠保持著連線。在寫入回應串流之前，我們還需要將內容類型設定為 `text/event-stream`。這是因為在回應已提交後（當 `response.committed?` 返回真值時），就無法再寫入標頭，而這發生在你 `write` 或 `commit` 回應串流時。

#### 範例使用

假設你正在製作一個卡拉OK機，使用者想要取得特定歌曲的歌詞。每首 `Song` 都有一定數量的行數，每行需要 `num_beats` 的時間來唱完。

如果我們想要以卡拉OK的方式返回歌詞（只在歌手完成前一行後才傳送下一行），我們可以使用 `ActionController::Live` 如下：

```ruby
class LyricsController < ActionController::Base
  include ActionController::Live

  def show
    response.headers['Content-Type'] = 'text/event-stream'
    song = Song.find(params[:id])

    song.each do |line|
      response.stream.write line.lyrics
      sleep line.num_beats
    end
  ensure
    response.stream.close
  end
end
```

上述程式碼在歌手完成前一行後才傳送下一行。

#### 串流考量事項

串流任意資料是一個非常強大的工具。如前面的範例所示，你可以選擇何時和何種資料傳送到回應串流。然而，你也應該注意以下幾點：

* 每個回應串流都會建立一個新的執行緒並複製原始執行緒的執行緒本地變數。擁有太多執行緒本地變數可能會對效能產生負面影響。同樣地，大量的執行緒也可能影響效能。
* 忘記關閉回應串流將會永遠保持相應的連線開啟。請確保在使用回應串流時呼叫 `close`。
* WEBrick 伺服器會緩衝所有回應，因此包含 `ActionController::Live` 將無效。你必須使用不會自動緩衝回應的網頁伺服器。

日誌過濾
-------------

Rails 在 `log` 資料夾中為每個環境保留一個日誌檔案。這些日誌在除錯應用程式實際運行時非常有用，但在實際應用程式中，你可能不希望將每一個資訊都存儲在日誌檔案中。

### 參數過濾

你可以通過將敏感的請求參數附加到應用程式配置中的 [`config.filter_parameters`][] 來過濾日誌檔案中的參數。這些參數將在日誌中標記為 [FILTERED]。

```ruby
config.filter_parameters << :password
```

注意：提供的參數將使用部分匹配的正則表達式進行過濾。Rails 在適當的初始化器（`initializers/filter_parameter_logging.rb`）中添加了一個預設過濾器列表，包括 `:passw`、`:secret` 和 `:token`，以處理典型應用程式參數，如 `password`、`password_confirmation` 和 `my_token`。

### 重定向過濾

有時候，希望從日誌檔案中過濾掉應用程式正在重定向到的一些敏感位置。你可以使用 `config.filter_redirect` 配置選項來實現：

```ruby
config.filter_redirect << 's3.amazonaws.com'
```

你可以將其設置為字串、正則表達式或兩者的陣列。

```ruby
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

匹配的 URL 將被標記為 '[FILTERED]'。

救援
------

很可能你的應用程式會包含錯誤或引發需要處理的異常。例如，如果使用者點擊連結到資料庫中不存在的資源，Active Record 將引發 `ActiveRecord::RecordNotFound` 異常。

Rails 的預設異常處理對所有異常顯示 "500 Server Error" 訊息。如果請求是在本地進行的，將顯示一個漂亮的回溯和一些額外的資訊，以便你找出出了什麼問題並處理它。如果請求是遠程的，Rails 將只向使用者顯示一個簡單的 "500 Server Error" 訊息，或者如果有路由錯誤或找不到記錄，則顯示 "404 Not Found"。有時你可能想要自定義這些錯誤的捕獲方式以及向使用者顯示的方式。在 Rails 應用程式中有幾個層次的異常處理可用：
### 預設的 500 和 404 範本

預設情況下，在生產環境中，應用程式會呈現 404 或 500 的錯誤訊息。在開發環境中，所有未處理的例外情況都會被直接引發。這些訊息包含在 public 資料夾中的靜態 HTML 檔案中，分別是 `404.html` 和 `500.html`。您可以自訂這些檔案以添加一些額外的資訊和樣式，但請記住它們是靜態 HTML，也就是說您無法在其中使用 ERB、SCSS、CoffeeScript 或版面配置。

### `rescue_from`

如果您想在捕獲錯誤時進行更複雜的操作，可以使用 [`rescue_from`][]，它可以在整個控制器及其子類中處理特定類型（或多個類型）的例外情況。

當 `rescue_from` 指令捕獲到例外情況時，例外物件將傳遞給處理程序。處理程序可以是一個方法或傳遞給 `:with` 選項的 `Proc` 物件。您也可以直接使用區塊而不是顯式的 `Proc` 物件。

以下是如何使用 `rescue_from` 捕獲所有 `ActiveRecord::RecordNotFound` 錯誤並對其進行處理的示例。

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

當然，這個示例並不複雜，並且並沒有改進默認的例外處理，但一旦您可以捕獲所有這些例外情況，您可以自由地對它們進行任何操作。例如，您可以創建自定義的例外類，當使用者無法訪問應用程式的某個區域時，將引發這些例外類：

```ruby
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private
    def user_not_authorized
      flash[:error] = "您無法訪問此區域。"
      redirect_back(fallback_location: root_path)
    end
end

class ClientsController < ApplicationController
  # 檢查使用者是否具有訪問客戶端的權限。
  before_action :check_authorization

  # 注意，這些動作不需要擔心所有的授權問題。
  def edit
    @client = Client.find(params[:id])
  end

  private
    # 如果使用者未獲授權，只需引發例外情況。
    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

警告：使用 `Exception` 或 `StandardError` 的 `rescue_from` 會導致嚴重的副作用，因為它會阻止 Rails 正確處理例外情況。因此，除非有充分的理由，否則不建議這樣做。

注意：在生產環境中運行時，所有的 `ActiveRecord::RecordNotFound` 錯誤都會呈現 404 錯誤頁面。除非您需要自定義行為，否則您不需要處理這個。

注意：某些例外情況只能從 `ApplicationController` 類中進行捕獲，因為它們在控制器初始化之前引發，並且動作被執行。

強制使用 HTTPS 協議
--------------------

如果您希望確保只能通過 HTTPS 來與控制器進行通信，您應該通過在環境配置中啟用 [`ActionDispatch::SSL`][] 中介軟體來實現，方法是使用 [`config.force_ssl`][]。

內建的健康檢查端點
------------------

Rails 還附帶了一個內建的健康檢查端點，可以在 `/up` 路徑上訪問。如果應用程式在啟動時沒有發生例外情況，則此端點將返回 200 狀態碼；否則返回 500 狀態碼。

在生產環境中，許多應用程式需要向上報告其狀態，無論是向一個故障時會通知工程師的可用性監控器，還是用於確定 pod 健康狀態的負載平衡器或 Kubernetes 控制器。這個健康檢查端點被設計為一個一刀切的解決方案，適用於許多情況。

雖然任何新生成的 Rails 應用程式都會在 `/up` 上擁有健康檢查，但您可以在 "config/routes.rb" 中配置路徑為您想要的任何內容：

```ruby
Rails.application.routes.draw do
  get "healthz" => "rails/health#show", as: :rails_health_check
end
```

現在，健康檢查將可以通過 `/healthz` 路徑訪問。

注意：此端點不反映應用程式的所有相依性的狀態，例如資料庫或 Redis 叢集。如果您有應用程式特定的需求，請將 "rails/health#show" 替換為您自己的控制器動作。

請仔細考慮您要檢查的內容，因為這可能導致應用程式因第三方服務出現問題而被重新啟動。理想情況下，您應該設計您的應用程式以優雅地處理這些中斷。
[`ActionController::Base`]: https://api.rubyonrails.org/classes/ActionController/Base.html
[`params`]: https://api.rubyonrails.org/classes/ActionController/StrongParameters.html#method-i-params
[`wrap_parameters`]: https://api.rubyonrails.org/classes/ActionController/ParamsWrapper/Options/ClassMethods.html#method-i-wrap_parameters
[`controller_name`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-controller_name
[`action_name`]: https://api.rubyonrails.org/classes/AbstractController/Base.html#method-i-action_name
[`permit`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit
[`permit!`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit-21
[`require`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-require
[`ActionDispatch::Session::CookieStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CookieStore.html
[`ActionDispatch::Session::CacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CacheStore.html
[`ActionDispatch::Session::MemCacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/MemCacheStore.html
[activerecord-session_store]: https://github.com/rails/activerecord-session_store
[`reset_session`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-reset_session
[`flash`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/RequestMethods.html#method-i-flash
[`flash.keep`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-keep
[`flash.now`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-now
[`config.action_dispatch.cookies_serializer`]: configuring.html#config-action-dispatch-cookies-serializer
[`cookies`]: https://api.rubyonrails.org/classes/ActionController/Cookies.html#method-i-cookies
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`skip_before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-skip_before_action
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`request`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-request
[`response`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-response
[`path_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Http/Parameters.html#method-i-path_parameters
[`query_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-query_parameters
[`request_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-request_parameters
[`http_basic_authenticate_with`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic/ControllerMethods/ClassMethods.html#method-i-http_basic_authenticate_with
[`authenticate_or_request_with_http_digest`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Digest/ControllerMethods.html#method-i-authenticate_or_request_with_http_digest
[`authenticate_or_request_with_http_token`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token/ControllerMethods.html#method-i-authenticate_or_request_with_http_token
[`send_data`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_data
[`send_file`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file
[`ActionController::Live`]: https://api.rubyonrails.org/classes/ActionController/Live.html
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`config.force_ssl`]: configuring.html#config-force-ssl
[`ActionDispatch::SSL`]: https://api.rubyonrails.org/classes/ActionDispatch/SSL.html
