**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e904ad42aee9a68f37b4e79e0b70b685
Rails應用程式中的錯誤報告
========================

本指南介紹了在Ruby on Rails應用程式中管理發生的例外情況的方法。

閱讀本指南後，您將了解：

* 如何使用Rails的錯誤報告器捕獲和報告錯誤。
* 如何為您的錯誤報告服務創建自定義訂閱者。

--------------------------------------------------------------------------------

錯誤報告
------------------------

Rails的[錯誤報告器](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html)提供了一種標準的方式來收集應用程式中發生的例外情況並將其報告給您選擇的服務或位置。

錯誤報告器旨在取代這樣的樣板式錯誤處理代碼：

```ruby
begin
  do_something
rescue SomethingIsBroken => error
  MyErrorReportingService.notify(error)
end
```

使用一致的接口：

```ruby
Rails.error.handle(SomethingIsBroken) do
  do_something
end
```

Rails將所有執行（例如HTTP請求、作業和`rails runner`調用）都包裝在錯誤報告器中，因此在您的應用程式中引發的任何未處理錯誤都將自動通過訂閱者報告給您的錯誤報告服務。

這意味著第三方錯誤報告庫不再需要插入Rack中間件或進行任何猴子補丁來捕獲未處理的例外情況。使用ActiveSupport的庫也可以使用此功能來非侵入性地報告以前在日誌中丟失的警告。

使用Rails的錯誤報告器並不是必需的。所有其他捕獲錯誤的方法仍然有效。

### 訂閱報告器

要使用錯誤報告器，您需要一個「訂閱者」。訂閱者是具有`report`方法的任何對象。當應用程式中發生錯誤或手動報告錯誤時，Rails錯誤報告器將使用錯誤對象和一些選項調用此方法。

某些錯誤報告庫（例如[Sentry的](https://github.com/getsentry/sentry-ruby/blob/e18ce4b6dcce2ebd37778c1e96164684a1e9ebfc/sentry-rails/lib/sentry/rails/error_subscriber.rb)和[Honeybadger的](https://docs.honeybadger.io/lib/ruby/integration-guides/rails-exception-tracking/)）會自動為您註冊一個訂閱者。請參閱您提供者的文檔以獲取更多詳細信息。

您還可以創建自定義訂閱者。例如：

```ruby
# config/initializers/error_subscriber.rb
class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    MyErrorReportingService.report_error(error, context: context, handled: handled, level: severity)
  end
end
```

在定義訂閱者類之後，通過調用[`Rails.error.subscribe`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-subscribe)方法來註冊它：

```ruby
Rails.error.subscribe(ErrorSubscriber.new)
```

您可以註冊任意多個訂閱者。Rails將按照註冊的順序依次調用它們。

注意：Rails錯誤報告器將始終調用已註冊的訂閱者，無論您的環境如何。但是，許多錯誤報告服務默認僅在生產環境中報告錯誤。您應根據需要配置和測試您的設置。

### 使用錯誤報告器

有三種使用錯誤報告器的方法：

#### 報告並忽略錯誤

[`Rails.error.handle`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-handle)將報告在塊內引發的任何錯誤。然後，它將**忽略**錯誤，並且塊外的其餘代碼將繼續正常執行。

```ruby
result = Rails.error.handle do
  1 + '1' # 引發TypeError
end
result # => nil
1 + 1 # 這將被執行
```

如果在塊內未引發錯誤，`Rails.error.handle`將返回塊的結果，否則將返回`nil`。您可以通過提供`fallback`來覆蓋此行為：

```ruby
user = Rails.error.handle(fallback: -> { User.anonymous }) do
  User.find_by(params[:id])
end
```

#### 報告並重新引發錯誤

[`Rails.error.record`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-record)將錯誤報告給所有已註冊的訂閱者，然後重新引發錯誤，這意味著塊外的其餘代碼將不會執行。

```ruby
Rails.error.record do
  1 + '1' # 引發TypeError
end
1 + 1 # 這將不會執行
```

如果在塊內未引發錯誤，`Rails.error.record`將返回塊的結果。

#### 手動報告錯誤

您還可以通過調用[`Rails.error.report`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-report)來手動報告錯誤：

```ruby
begin
  # 代碼
rescue StandardError => e
  Rails.error.report(e)
end
```

您傳遞的任何選項都將傳遞給錯誤訂閱者。

### 錯誤報告選項

所有3個報告API（`#handle`、`#record`和`#report`）都支持以下選項，然後將它們傳遞給所有已註冊的訂閱者：

- `handled`：一個`Boolean`，指示錯誤是否已處理。默認情況下，此值設置為`true`。`#record`將其設置為`false`。
- `severity`：一個描述錯誤嚴重性的`Symbol`。預期的值為：`:error`、`:warning`和`:info`。`#handle`將其設置為`:warning`，而`#record`將其設置為`:error`。
- `context`：一個提供有關錯誤的更多上下文的`Hash`，例如請求或用戶詳細信息。
- `source`：一個關於錯誤來源的`String`。默認來源是`"application"`。內部庫報告的錯誤可能會設置其他來源；例如，Redis緩存庫可能使用`"redis_cache_store.active_support"`。您的訂閱者可以使用來源來忽略您不感興趣的錯誤。
```ruby
Rails.error.handle(context: { user_id: user.id }, severity: :info) do
  # ...
end
```

### 依錯誤類別篩選

使用 `Rails.error.handle` 和 `Rails.error.record`，您也可以選擇只報告特定類別的錯誤。例如：

```ruby
Rails.error.handle(IOError) do
  1 + '1' # 會拋出 TypeError
end
1 + 1 # TypeErrors 不是 IOError，所以這行不會被執行
```

在這個例子中，`TypeError` 不會被 Rails 錯誤報告器捕獲。只有 `IOError` 及其子類別的實例會被報告。其他任何錯誤都會像平常一樣拋出。

### 全域設定上下文

除了透過 `context` 選項設定上下文外，您還可以使用 [`#set_context`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-set_context) API。例如：

```ruby
Rails.error.set_context(section: "checkout", user_id: @user.id)
```

這種方式設定的任何上下文都會與 `context` 選項合併。

```ruby
Rails.error.set_context(a: 1)
Rails.error.handle(context: { b: 2 }) { raise }
# 報告的上下文將是：{:a=>1, :b=>2}
Rails.error.handle(context: { b: 3 }) { raise }
# 報告的上下文將是：{:a=>1, :b=>3}
```

### 針對函式庫

錯誤報告函式庫可以在 `Railtie` 中註冊其訂閱者：

```ruby
module MySdk
  class Railtie < ::Rails::Railtie
    initializer "my_sdk.error_subscribe" do
      Rails.error.subscribe(MyErrorSubscriber.new)
    end
  end
end
```

如果您註冊了錯誤訂閱者，但仍然有其他錯誤機制，例如 Rack 中介軟體，可能會導致錯誤被多次報告。您應該移除其他機制，或調整報告功能，以便跳過已經見過的例外報告。
