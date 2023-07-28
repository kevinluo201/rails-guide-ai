**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 48f8290cbf9190673c32a3eb9777acba
Rails on Rack
=============

本指南介绍了Rails与Rack的集成以及与其他Rack组件的接口。

阅读本指南后，您将了解：

* 如何在Rails应用程序中使用Rack中间件。
* Action Pack的内部中间件堆栈。
* 如何定义自定义中间件堆栈。

--------------------------------------------------------------------------------

警告：本指南假定您具备Rack协议和Rack概念的工作知识，例如中间件、URL映射和`Rack::Builder`。

Rack简介
--------------------

Rack提供了一个最小、模块化和可适应的接口，用于在Ruby中开发Web应用程序。通过以最简单的方式包装HTTP请求和响应，它将Web服务器、Web框架和中间件（所谓的中间件）之间的API统一和提炼为一个方法调用。

解释Rack的工作原理不在本指南的范围之内。如果您对Rack的基础知识不熟悉，可以查看下面的[资源](#resources)部分。

Rails on Rack
-------------

### Rails应用程序的Rack对象

`Rails.application`是Rails应用程序的主要Rack应用程序对象。任何符合Rack标准的Web服务器都应该使用`Rails.application`对象来提供Rails应用程序。

### `bin/rails server`

`bin/rails server`的基本工作是创建一个`Rack::Server`对象并启动Web服务器。

以下是`bin/rails server`如何创建`Rack::Server`的实例：

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

`Rails::Server`继承自`Rack::Server`，并以以下方式调用`Rack::Server#start`方法：

```ruby
class Server < ::Rack::Server
  def start
    # ...
    super
  end
end
```

### `rackup`

要使用`rackup`而不是Rails的`bin/rails server`，您可以将以下内容放入Rails应用程序根目录的`config.ru`中：

```ruby
# Rails.root/config.ru
require_relative "config/environment"
run Rails.application
```

然后启动服务器：

```bash
$ rackup config.ru
```

要了解有关不同的`rackup`选项的更多信息，可以运行：

```bash
$ rackup --help
```

### 开发和自动重新加载

中间件只加载一次，不会监视更改。您需要重新启动服务器才能使更改在运行中的应用程序中生效。

Action Dispatcher中间件堆栈
----------------------------------

许多Action Dispatcher的内部组件都是作为Rack中间件实现的。`Rails::Application`使用`ActionDispatch::MiddlewareStack`将各种内部和外部中间件组合在一起，形成一个完整的Rails Rack应用程序。

注意：`ActionDispatch::MiddlewareStack`是Rails的等效于`Rack::Builder`，但为了更好的灵活性和更多功能，它被构建用于满足Rails的要求。

### 检查中间件堆栈

Rails有一个方便的命令用于检查正在使用的中间件堆栈：

```bash
$ bin/rails middleware
```

对于一个新生成的Rails应用程序，可能会产生类似以下内容：

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

这里显示的默认中间件（和其他一些中间件）在下面的[内部中间件](#internal-middleware-stack)部分中进行了总结。

### 配置中间件堆栈

Rails提供了一个简单的配置接口[`config.middleware`][]，通过`application.rb`或环境特定的配置文件`environments/<environment>.rb`来添加、删除和修改中间件堆栈中的中间件。

#### 添加中间件

您可以使用以下任何方法将新的中间件添加到中间件堆栈中：

* `config.middleware.use(new_middleware, args)` - 在中间件堆栈的底部添加新的中间件。

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - 在指定的现有中间件之前在中间件堆栈中添加新的中间件。

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - 在指定的现有中间件之后在中间件堆栈中添加新的中间件。

```ruby
# config/application.rb

# 在底部添加 Rack::BounceFavicon
config.middleware.use Rack::BounceFavicon

# 在 ActionDispatch::Executor 之后添加 Lifo::Cache。
# 将 { page_cache: false } 参数传递给 Lifo::Cache。
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### 交换中间件

您可以使用`config.middleware.swap`来交换中间件堆栈中的现有中间件。

```ruby
# config/application.rb

# 将 ActionDispatch::ShowExceptions 替换为 Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### 移动中间件

您可以使用`config.middleware.move_before`和`config.middleware.move_after`来移动中间件堆栈中的现有中间件。

```ruby
# config/application.rb

# 将 ActionDispatch::ShowExceptions 移动到 Lifo::ShowExceptions 之前
config.middleware.move_before Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

```ruby
# config/application.rb

# 将 ActionDispatch::ShowExceptions 移动到 Lifo::ShowExceptions 之后
config.middleware.move_after Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

#### 删除中间件
将以下行添加到应用程序配置中：

```ruby
# config/application.rb
config.middleware.delete Rack::Runtime
```

现在，如果检查中间件堆栈，您会发现`Rack::Runtime`不再是其中的一部分。

```bash
$ bin/rails middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
...
run Rails.application.routes
```

如果要删除与会话相关的中间件，请执行以下操作：

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash
```

要删除与浏览器相关的中间件，请执行以下操作：

```ruby
# config/application.rb
config.middleware.delete Rack::MethodOverride
```

如果要在尝试删除不存在的项时引发错误，请改用`delete!`。

```ruby
# config/application.rb
config.middleware.delete! ActionDispatch::Executor
```

### 内部中间件堆栈

许多Action Controller的功能是作为中间件实现的。以下列表解释了每个中间件的目的：

**`ActionDispatch::HostAuthorization`**

* 通过明确允许请求可以发送到的主机来防止DNS重绑定攻击。有关配置说明，请参见[配置指南](configuring.html#actiondispatch-hostauthorization)。

**`Rack::Sendfile`**

* 设置特定于服务器的X-Sendfile标头。通过[`config.action_dispatch.x_sendfile_header`][]选项进行配置。

**`ActionDispatch::Static`**

* 用于从public目录提供静态文件。如果[`config.public_file_server.enabled`][]为`false`，则禁用。

**`Rack::Lock`**

* 将`env["rack.multithread"]`标志设置为`false`，并在互斥体内包装应用程序。

**`ActionDispatch::Executor`**

* 用于开发期间的线程安全代码重新加载。

**`ActionDispatch::ServerTiming`**

* 设置包含请求的性能指标的[`Server-Timing`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server-Timing)标头。

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* 用于内存缓存。此缓存不是线程安全的。

**`Rack::Runtime`**

* 设置一个包含执行请求所需时间（以秒为单位）的X-Runtime标头。

**`Rack::MethodOverride`**

* 如果设置了`params[:_method]`，则允许覆盖方法。这是支持PUT和DELETE HTTP方法类型的中间件。

**`ActionDispatch::RequestId`**

* 使唯一的`X-Request-Id`标头可用于响应，并启用`ActionDispatch::Request#request_id`方法。

**`ActionDispatch::RemoteIp`**

* 检查IP欺骗攻击。

**`Sprockets::Rails::QuietAssets`**

* 抑制资源请求的日志记录器输出。

**`Rails::Rack::Logger`**

* 通知日志记录器请求已开始。请求完成后，刷新所有日志。

**`ActionDispatch::ShowExceptions`**

* 捕获应用程序返回的任何异常，并调用一个异常应用程序将其包装成适用于最终用户的格式。

**`ActionDispatch::DebugExceptions`**

* 负责记录异常并在请求为本地时显示调试页面。

**`ActionDispatch::ActionableExceptions`**

* 提供一种从Rails错误页面调度操作的方法。

**`ActionDispatch::Reloader`**

* 提供准备和清理回调，用于开发期间的代码重新加载。

**`ActionDispatch::Callbacks`**

* 提供在调度请求之前和之后执行的回调。

**`ActiveRecord::Migration::CheckPending`**

* 检查待处理的迁移，并如果有任何待处理的迁移，则引发`ActiveRecord::PendingMigrationError`。

**`ActionDispatch::Cookies`**

* 为请求设置cookie。

**`ActionDispatch::Session::CookieStore`**

* 负责将会话存储在cookie中。

**`ActionDispatch::Flash`**

* 设置flash键。仅在[`config.session_store`][]设置为某个值时可用。

**`ActionDispatch::ContentSecurityPolicy::Middleware`**

* 提供用于配置Content-Security-Policy标头的DSL。

**`Rack::Head`**

* 将HEAD请求转换为`GET`请求并作为`GET`请求提供。

**`Rack::ConditionalGet`**

* 添加对“条件`GET`”的支持，以便如果页面未更改，则服务器不会响应任何内容。

**`Rack::ETag`**

* 在所有字符串正文上添加ETag标头。ETag用于验证缓存。

**`Rack::TempfileReaper`**

* 清理用于缓冲多部分请求的临时文件。

提示：您可以在自定义Rack堆栈中使用上述任何中间件。

资源
---------

### 学习Rack

* [官方Rack网站](https://rack.github.io)
* [介绍Rack](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### 理解中间件

* [关于Rack中间件的Railscast](http://railscasts.com/episodes/151-rack-middleware)
[`config.middleware`]: configuring.html#config-middleware
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.session_store`]: configuring.html#config-session-store
