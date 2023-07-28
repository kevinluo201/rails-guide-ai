**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e904ad42aee9a68f37b4e79e0b70b685
Rails应用程序中的错误报告
========================

本指南介绍了在Ruby on Rails应用程序中处理异常的方法。

阅读本指南后，您将了解以下内容：

* 如何使用Rails的错误报告器捕获和报告错误。
* 如何为您的错误报告服务创建自定义订阅者。

--------------------------------------------------------------------------------

错误报告
------------------------

Rails的[错误报告器](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html)提供了一种标准的方式来收集应用程序中发生的异常并将其报告给您首选的服务或位置。

错误报告器旨在取代类似于以下代码的样板错误处理代码：

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

Rails将所有执行操作（如HTTP请求、作业和`rails runner`调用）都包装在错误报告器中，因此在您的应用程序中引发的任何未处理错误都将自动通过订阅者报告给您的错误报告服务。

这意味着第三方错误报告库不再需要插入Rack中间件或进行任何猴子补丁来捕获未处理的异常。使用ActiveSupport的库也可以使用此功能非侵入性地报告以前在日志中丢失的警告。

使用Rails的错误报告器不是必需的。所有其他捕获错误的方法仍然有效。

### 订阅报告器

要使用错误报告器，您需要一个_订阅者_。订阅者是具有`report`方法的任何对象。当应用程序中发生错误或手动报告错误时，Rails错误报告器将使用错误对象和一些选项调用此方法。

某些错误报告库（例如[Sentry的](https://github.com/getsentry/sentry-ruby/blob/e18ce4b6dcce2ebd37778c1e96164684a1e9ebfc/sentry-rails/lib/sentry/rails/error_subscriber.rb)和[Honeybadger的](https://docs.honeybadger.io/lib/ruby/integration-guides/rails-exception-tracking/)）会自动为您注册一个订阅者。有关更多详细信息，请参阅您提供程序的文档。

您还可以创建自定义订阅者。例如：

```ruby
# config/initializers/error_subscriber.rb
class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    MyErrorReportingService.report_error(error, context: context, handled: handled, level: severity)
  end
end
```

定义订阅者类后，通过调用[`Rails.error.subscribe`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-subscribe)方法注册它：

```ruby
Rails.error.subscribe(ErrorSubscriber.new)
```

您可以注册任意数量的订阅者。Rails将按照注册的顺序依次调用它们。

注意：Rails错误报告器将始终调用已注册的订阅者，而不考虑您的环境。但是，许多错误报告服务默认仅在生产环境中报告错误。您应根据需要配置和测试跨环境的设置。

### 使用错误报告器

有三种方法可以使用错误报告器：

#### 报告和忽略错误

[`Rails.error.handle`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-handle)将报告在块内引发的任何错误。然后它将**忽略**该错误，并且块外部的其余代码将继续正常执行。

```ruby
result = Rails.error.handle do
  1 + '1' # 引发TypeError
end
result # => nil
1 + 1 # 这将被执行
```

如果在块内没有引发错误，`Rails.error.handle`将返回块的结果，否则将返回`nil`。您可以通过提供一个`fallback`来覆盖此行为：

```ruby
user = Rails.error.handle(fallback: -> { User.anonymous }) do
  User.find_by(params[:id])
end
```

#### 报告和重新引发错误

[`Rails.error.record`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-record)将向所有注册的订阅者报告错误，然后重新引发错误，这意味着您的代码的其余部分将不会执行。

```ruby
Rails.error.record do
  1 + '1' # 引发TypeError
end
1 + 1 # 这将不会被执行
```

如果在块内没有引发错误，`Rails.error.record`将返回块的结果。

#### 手动报告错误

您还可以通过调用[`Rails.error.report`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-report)来手动报告错误：

```ruby
begin
  # 代码
rescue StandardError => e
  Rails.error.report(e)
end
```

您传递的任何选项都将传递给错误订阅者。

### 错误报告选项

所有3个报告API（`#handle`、`#record`和`#report`）都支持以下选项，然后将其传递给所有注册的订阅者：

- `handled`：一个`Boolean`，指示错误是否已处理。默认设置为`true`。`#record`将其设置为`false`。
- `severity`：描述错误严重性的`Symbol`。预期值为：`:error`、`:warning`和`:info`。`#handle`将其设置为`:warning`，而`#record`将其设置为`:error`。
- `context`：提供有关错误的更多上下文的`Hash`，例如请求或用户详细信息
- `source`：关于错误来源的`String`。默认来源为`"application"`。内部库报告的错误可能会设置其他来源；例如，Redis缓存库可以使用`"redis_cache_store.active_support"`。您的订阅者可以使用来源来忽略您不感兴趣的错误。
```ruby
Rails.error.handle(context: { user_id: user.id }, severity: :info) do
  # ...
end
```

### 按错误类过滤

通过 `Rails.error.handle` 和 `Rails.error.record`，您还可以选择仅报告特定类的错误。例如：

```ruby
Rails.error.handle(IOError) do
  1 + '1' # 抛出 TypeError
end
1 + 1 # TypeErrors 不是 IOError，所以这个语句 *不会* 被执行
```

在这里，`TypeError` 不会被 Rails 错误报告器捕获。只有 `IOError` 及其子类的实例才会被报告。其他任何错误都会正常抛出。

### 全局设置上下文

除了通过 `context` 选项设置上下文外，您还可以使用 [`#set_context`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-set_context) API。例如：

```ruby
Rails.error.set_context(section: "checkout", user_id: @user.id)
```

以这种方式设置的任何上下文都将与 `context` 选项合并

```ruby
Rails.error.set_context(a: 1)
Rails.error.handle(context: { b: 2 }) { raise }
# 报告的上下文将是：{:a=>1, :b=>2}
Rails.error.handle(context: { b: 3 }) { raise }
# 报告的上下文将是：{:a=>1, :b=>3}
```

### 对于库

错误报告库可以在 `Railtie` 中注册其订阅者：

```ruby
module MySdk
  class Railtie < ::Rails::Railtie
    initializer "my_sdk.error_subscribe" do
      Rails.error.subscribe(MyErrorSubscriber.new)
    end
  end
end
```

如果您注册了错误订阅者，但仍然有其他错误机制，比如 Rack 中间件，可能会导致错误多次报告。您应该删除其他机制或调整报告功能，以便跳过已经看到的异常的报告。
