**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 48f8290cbf9190673c32a3eb9777acba
Rails on Rack
=============

本指南介紹了Rails與Rack的整合以及與其他Rack組件的接口。

閱讀完本指南後，您將了解：

* 如何在Rails應用程序中使用Rack中間件。
* Action Pack的內部中間件堆棧。
* 如何定義自定義的中間件堆棧。

--------------------------------------------------------------------------------

警告：本指南假設您已經熟悉Rack協議和Rack概念，例如中間件、URL映射和`Rack::Builder`。

Rack簡介
--------------------

Rack提供了一個最小、模塊化和可適應的接口，用於在Ruby中開發Web應用程序。通過以最簡單的方式封裝HTTP請求和響應，它將Web服務器、Web框架和中間件（所謂的中間件）之間的API統一並提煉成一個方法調用。

解釋Rack的工作原理不在本指南的範圍內。如果您對Rack的基礎不熟悉，請查看下面的[資源](#resources)部分。

Rails on Rack
-------------

### Rails應用程序的Rack對象

`Rails.application`是Rails應用程序的主要Rack應用程序對象。任何符合Rack標準的Web服務器都應該使用`Rails.application`對象來提供Rails應用程序。

### `bin/rails server`

`bin/rails server`的基本工作是創建一個`Rack::Server`對象並啟動Web服務器。

以下是`bin/rails server`如何創建`Rack::Server`的實例：

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

`Rails::Server`繼承自`Rack::Server`，並以以下方式調用`Rack::Server#start`方法：

```ruby
class Server < ::Rack::Server
  def start
    # ...
    super
  end
end
```

### `rackup`

如果要使用`rackup`而不是Rails的`bin/rails server`，可以將以下內容放在Rails應用程序根目錄的`config.ru`中：

```ruby
# Rails.root/config.ru
require_relative "config/environment"
run Rails.application
```

然後啟動服務器：

```bash
$ rackup config.ru
```

要了解有關不同的`rackup`選項的更多信息，可以運行：

```bash
$ rackup --help
```

### 開發和自動重新加載

中間件只加載一次，不會監視更改。您需要重新啟動服務器才能使更改在運行中的應用程序中生效。

Action Dispatcher中間件堆棧
----------------------------------

Action Dispatcher的許多內部組件都是作為Rack中間件實現的。`Rails::Application`使用`ActionDispatch::MiddlewareStack`將各種內部和外部中間件組合成一個完整的Rails Rack應用程序。

注意：`ActionDispatch::MiddlewareStack`是Rails的等效物`Rack::Builder`，但為了更好的靈活性和更多功能，它被構建用於滿足Rails的要求。

### 檢查中間件堆棧

Rails提供了一個方便的命令來檢查正在使用的中間件堆棧：

```bash
$ bin/rails middleware
```

對於一個新生成的Rails應用程序，可能會產生以下結果：

```ruby
use ActionDispatch::HostAuthorization
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
use ActionDispatch::ServerTiming
use ActiveSupport::Cache::Strategy::LocalCache::Middleware
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use ActionDispatch::RemoteIp
use Sprockets::Rails::QuietAssets
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use WebConsole::Middleware
use ActionDispatch::DebugExceptions
use ActionDispatch::ActionableExceptions
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::Migration::CheckPending
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ContentSecurityPolicy::Middleware
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
use Rack::TempfileReaper
run MyApp::Application.routes
```

這裡顯示的默認中間件（以及其他一些中間件）在下面的[內部中間件](#internal-middleware-stack)部分中有簡要介紹。

### 配置中間件堆棧

Rails提供了一個簡單的配置接口[`config.middleware`][]，用於通過`application.rb`或環境特定的配置文件`environments/<environment>.rb`添加、刪除和修改中間件堆棧中的中間件。


#### 添加中間件

您可以使用以下任何方法將新的中間件添加到中間件堆棧中：

* `config.middleware.use(new_middleware, args)` - 在中間件堆棧的底部添加新的中間件。

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - 在中間件堆棧中指定的現有中間件之前添加新的中間件。

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - 在中間件堆棧中指定的現有中間件之後添加新的中間件。

```ruby
# config/application.rb

# 在底部添加Rack::BounceFavicon
config.middleware.use Rack::BounceFavicon

# 在ActionDispatch::Executor之後添加Lifo::Cache。
# 將{ page_cache: false }參數傳遞給Lifo::Cache。
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### 替換中間件

您可以使用`config.middleware.swap`將中間件堆棧中的現有中間件替換為新的中間件。

```ruby
# config/application.rb

# 將ActionDispatch::ShowExceptions替換為Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### 移動中間件

您可以使用`config.middleware.move_before`和`config.middleware.move_after`將中間件堆棧中的現有中間件移動。

```ruby
# config/application.rb

# 將ActionDispatch::ShowExceptions移動到Lifo::ShowExceptions之前
config.middleware.move_before Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

```ruby
# config/application.rb

# 將ActionDispatch::ShowExceptions移動到Lifo::ShowExceptions之後
config.middleware.move_after Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

#### 刪除中間件
將以下行添加到應用程式配置中：

```ruby
# config/application.rb
config.middleware.delete Rack::Runtime
```

現在，如果檢查中介軟體堆疊，你會發現 `Rack::Runtime` 不再是其中的一部分。

```bash
$ bin/rails middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
...
run Rails.application.routes
```

如果要刪除與會話相關的中介軟體，請執行以下操作：

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash
```

如果要刪除與瀏覽器相關的中介軟體，

```ruby
# config/application.rb
config.middleware.delete Rack::MethodOverride
```

如果要在嘗試刪除不存在的項目時引發錯誤，請使用 `delete!`。

```ruby
# config/application.rb
config.middleware.delete! ActionDispatch::Executor
```

### 內部中介軟體堆疊

Action Controller 的許多功能都是以中介軟體的形式實現的。以下列表解釋了每個中介軟體的目的：

**`ActionDispatch::HostAuthorization`**

* 通過明確允許請求可以發送到的主機，防止 DNS 重綁定攻擊。有關配置說明，請參閱[配置指南](configuring.html#actiondispatch-hostauthorization)。

**`Rack::Sendfile`**

* 設置特定於伺服器的 X-Sendfile 標頭。通過 [`config.action_dispatch.x_sendfile_header`][] 選項進行配置。

**`ActionDispatch::Static`**

* 用於從 public 目錄提供靜態文件。如果 [`config.public_file_server.enabled`][] 為 `false`，則禁用。

**`Rack::Lock`**

* 將 `env["rack.multithread"]` 標誌設置為 `false`，並在 Mutex 內包裹應用程式。

**`ActionDispatch::Executor`**

* 用於開發期間的線程安全代碼重新加載。

**`ActionDispatch::ServerTiming`**

* 設置包含請求的性能指標的 [`Server-Timing`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server-Timing) 標頭。

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* 用於記憶體緩存。此緩存不是線程安全的。

**`Rack::Runtime`**

* 設置包含執行請求所需時間（以秒為單位）的 X-Runtime 標頭。

**`Rack::MethodOverride`**

* 如果設置了 `params[:_method]`，則允許覆蓋方法。這是支援 PUT 和 DELETE HTTP 方法類型的中介軟體。

**`ActionDispatch::RequestId`**

* 使唯一的 `X-Request-Id` 標頭可用於回應，並啟用 `ActionDispatch::Request#request_id` 方法。

**`ActionDispatch::RemoteIp`**

* 檢查 IP 欺騙攻擊。

**`Sprockets::Rails::QuietAssets`**

* 抑制資源請求的日誌輸出。

**`Rails::Rack::Logger`**

* 通知日誌請求已開始。請求完成後，刷新所有日誌。

**`ActionDispatch::ShowExceptions`**

* 捕獲應用程式返回的任何異常，並調用一個異常應用程式，將其包裝成用於最終使用者的格式。

**`ActionDispatch::DebugExceptions`**

* 負責記錄異常並在請求為本地時顯示調試頁面。

**`ActionDispatch::ActionableExceptions`**

* 提供從 Rails 錯誤頁面調度操作的方法。

**`ActionDispatch::Reloader`**

* 提供準備和清理回調，用於開發期間的代碼重新加載。

**`ActionDispatch::Callbacks`**

* 提供在調度請求之前和之後執行的回調。

**`ActiveRecord::Migration::CheckPending`**

* 檢查待處理的遷移，如果有任何待處理的遷移，則引發 `ActiveRecord::PendingMigrationError`。

**`ActionDispatch::Cookies`**

* 為請求設置 cookies。

**`ActionDispatch::Session::CookieStore`**

* 負責將會話存儲在 cookies 中。

**`ActionDispatch::Flash`**

* 設置 flash 鍵。僅在 [`config.session_store`][] 設置為某個值時可用。

**`ActionDispatch::ContentSecurityPolicy::Middleware`**

* 提供 DSL 以配置 Content-Security-Policy 標頭。

**`Rack::Head`**

* 將 HEAD 請求轉換為 `GET` 請求並作為 `GET` 請求提供。

**`Rack::ConditionalGet`**

* 添加對「條件 `GET`」的支援，以便如果頁面未更改，伺服器不會回應任何內容。

**`Rack::ETag`**

* 在所有字符串主體上添加 ETag 標頭。ETag 用於驗證快取。

**`Rack::TempfileReaper`**

* 清理用於緩衝多部分請求的臨時文件。

提示：可以在自定義 Rack 堆疊中使用上述任何中介軟體。

資源
---------

### 學習 Rack

* [官方 Rack 網站](https://rack.github.io)
* [介紹 Rack](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### 理解中介軟體

* [Rack 中介軟體的 Railscast](http://railscasts.com/episodes/151-rack-middleware)
[`config.middleware`]: configuring.html#config-middleware
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.session_store`]: configuring.html#config-session-store
