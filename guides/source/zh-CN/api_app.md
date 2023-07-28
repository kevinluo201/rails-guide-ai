**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fe858c0828e87f595c5d8c23c4b6326e
使用Rails构建API应用程序
=======================

在本指南中，您将学习到：

* Rails为API应用程序提供了什么功能
* 如何配置Rails以在没有任何浏览器功能的情况下启动
* 如何决定要包含哪些中间件
* 如何决定在控制器中使用哪些模块

--------------------------------------------------------------------------------

什么是API应用程序？
-------------------

传统上，当人们说他们使用Rails作为“API”时，他们指的是在他们的Web应用程序旁边提供一个可编程访问的API。例如，GitHub提供了[一个API](https://developer.github.com)，您可以从自己的自定义客户端使用。

随着客户端框架的出现，越来越多的开发人员使用Rails构建一个在Web应用程序和其他本地应用程序之间共享的后端。

例如，Twitter在其Web应用程序中使用其[公共API](https://developer.twitter.com/)，该应用程序构建为一个消耗JSON资源的静态站点。

许多开发人员不再使用Rails生成通过表单和链接与服务器通信的HTML，而是将他们的Web应用程序视为仅作为使用JSON API的HTML交付的API客户端。

本指南介绍了构建Rails应用程序，该应用程序向API客户端提供JSON资源，包括客户端端框架。

为什么要使用Rails构建JSON API？
-------------------------------

当考虑使用Rails构建JSON API时，很多人首先会问的问题是：“使用Rails输出一些JSON不是有点过头了吗？我不应该使用类似Sinatra的东西吗？”。

对于非常简单的API，这可能是正确的。然而，即使在非常依赖HTML的应用程序中，大部分应用程序的逻辑都存在于视图层之外。

大多数人使用Rails的原因是它提供了一组默认值，允许开发人员快速启动，而无需做出许多琐碎的决策。

让我们来看看Rails提供的一些开箱即用的功能，这些功能仍然适用于API应用程序。

在中间件层处理：

- 重新加载：Rails应用程序支持透明重新加载。即使您的应用程序变得庞大，并且为每个请求重新启动服务器变得不可行，这也可以工作。
- 开发模式：Rails应用程序具有开发的智能默认值，使开发变得愉快，而不会影响生产性能。
- 测试模式：同开发模式。
- 日志记录：Rails应用程序记录每个请求，日志的详细程度适合当前模式。Rails在开发中的日志包括有关请求环境、数据库查询和基本性能信息的信息。
- 安全性：Rails以[时间攻击](https://en.wikipedia.org/wiki/Timing_attack)感知方式检测和阻止[IP欺骗攻击](https://en.wikipedia.org/wiki/IP_address_spoofing)，并处理加密签名。不知道什么是IP欺骗攻击或时间攻击？没关系。
- 参数解析：想要将参数指定为JSON而不是URL编码的字符串？没问题。Rails将为您解码JSON，并在`params`中提供它。想要使用嵌套的URL编码参数？也可以。
- 条件GET：Rails处理条件`GET`（`ETag`和`Last-Modified`）处理请求头，并返回正确的响应头和状态码。您只需要在控制器中使用[`stale?`](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F)检查，Rails将为您处理所有HTTP细节。
- HEAD请求：Rails将透明地将`HEAD`请求转换为`GET`请求，并在返回时仅返回头部。这使得在所有Rails API中可靠地使用`HEAD`。

虽然您可以通过现有的Rack中间件构建这些功能，但是这个列表证明了默认的Rails中间件堆栈提供了很多价值，即使您只是“生成JSON”。

在Action Pack层处理：

- 资源路由：如果您正在构建一个RESTful JSON API，您应该使用Rails路由器。从HTTP到控制器的干净和常规映射意味着不需要花时间考虑如何在HTTP方面建模API。
- URL生成：路由的反面是URL生成。基于HTTP的良好API包括URL（参见[GitHub Gist API](https://docs.github.com/en/rest/reference/gists)的示例）。
- 头部和重定向响应：`head :no_content`和`redirect_to user_url(current_user)`非常方便。当然，您可以手动添加响应头，但为什么呢？
- 缓存：Rails提供页面、动作和片段缓存。在构建嵌套的JSON对象时，片段缓存特别有帮助。
- 基本、摘要和令牌身份验证：Rails提供了对三种HTTP身份验证的开箱即用支持。
- 仪表板：Rails具有仪表板API，可以触发注册的处理程序来处理各种事件，例如操作处理、发送文件或数据、重定向和数据库查询。每个事件的有效负载都带有相关信息（对于操作处理事件，有效负载包括控制器、操作、参数、请求格式、请求方法和请求的完整路径）。
- 生成器：生成资源并在单个命令中为您创建模型、控制器、测试存根和路由通常很方便，以供进一步调整。迁移等也是如此。
- 插件：许多第三方库都带有对Rails的支持，可以减少或消除设置和将库与Web框架粘合在一起的成本。这包括覆盖默认生成器、添加Rake任务和遵守Rails选择（如记录器和缓存后端）。
当然，Rails的启动过程还会将所有注册的组件粘合在一起。
例如，当配置Active Record时，Rails的启动过程会使用您的`config/database.yml`文件。

**简短版本是**：即使您删除了视图层，您可能没有考虑到Rails的哪些部分仍然适用，但答案是大部分都适用。

基本配置
-----------------------

如果您正在构建一个首要用途是API服务器的Rails应用程序，您可以从更有限的Rails子集开始，并根据需要添加功能。

### 创建新应用程序

您可以生成一个新的api Rails应用程序：

```bash
$ rails new my_api --api
```

这将为您做三件主要的事情：

- 配置您的应用程序以使用比正常情况下更有限的中间件集。具体来说，默认情况下不会包含任何主要用于浏览器应用程序（如cookie支持）的中间件。
- 使`ApplicationController`继承自`ActionController::API`，而不是`ActionController::Base`。与中间件一样，这将省略任何主要用于浏览器应用程序的Action Controller模块。
- 配置生成器，在生成新资源时跳过生成视图、助手和资产。

### 生成新资源

为了了解我们新创建的API如何处理生成新资源，让我们创建一个新的Group资源。每个组都有一个名称。

```bash
$ bin/rails g scaffold Group name:string
```

在我们可以使用我们的脚手架代码之前，我们需要更新我们的数据库模式。

```bash
$ bin/rails db:migrate
```

现在，如果我们打开我们的`GroupsController`，我们应该注意到，在API Rails应用程序中，我们只渲染JSON数据。在索引操作中，我们查询`Group.all`并将其分配给名为`@groups`的实例变量。将其传递给`render`与`:json`选项一起将自动将组渲染为JSON。

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

最后，我们可以从Rails控制台向数据库添加一些组：

```irb
irb> Group.create(name: "Rails Founders")
irb> Group.create(name: "Rails Contributors")
```

有了一些数据后，我们可以启动服务器并访问<http://localhost:3000/groups.json>来查看我们的JSON数据。

```json
[
{"id":1, "name":"Rails Founders", "created_at": ...},
{"id":2, "name":"Rails Contributors", "created_at": ...}
]
```

### 更改现有应用程序

如果您想将现有应用程序变为API应用程序，请阅读以下步骤。

在`config/application.rb`中，在`Application`类定义的顶部添加以下行：

```ruby
config.api_only = true
```

在`config/environments/development.rb`中，设置[`config.debug_exception_response_format`][]以配置在开发模式下发生错误时响应中使用的格式。

要使用带有调试信息的HTML页面，请使用值`:default`。

```ruby
config.debug_exception_response_format = :default
```

要使用保留响应格式的调试信息，请使用值`:api`。

```ruby
config.debug_exception_response_format = :api
```

默认情况下，当`config.api_only`设置为true时，`config.debug_exception_response_format`设置为`:api`。

最后，在`app/controllers/application_controller.rb`中，不再使用：

```ruby
class ApplicationController < ActionController::Base
end
```

而是使用：

```ruby
class ApplicationController < ActionController::API
end
```


选择中间件
--------------------

API应用程序默认使用以下中间件：

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

有关它们的更多信息，请参阅Rack指南的[内部中间件](rails_on_rack.html#internal-middleware-stack)部分。

其他插件，包括Active Record，可能会添加其他中间件。一般来说，这些中间件对于您构建的应用程序类型是不可知的，并且在仅限API的Rails应用程序中是有意义的。
您可以通过以下方式获取应用程序中所有中间件的列表：

```bash
$ bin/rails middleware
```

### 使用 Rack::Cache

在与Rails一起使用时，`Rack::Cache`使用Rails缓存存储作为其实体和元存储。这意味着如果您在Rails应用程序中使用memcache，内置的HTTP缓存将使用memcache。

要使用`Rack::Cache`，首先需要将`rack-cache` gem添加到`Gemfile`中，并将`config.action_dispatch.rack_cache`设置为`true`。为了启用其功能，您将希望在控制器中使用`stale?`。以下是`stale?`的使用示例。

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

对`stale?`的调用将比较请求中的`If-Modified-Since`头与`@post.updated_at`。如果头部比上次修改时间更新，则此操作将返回“304 Not Modified”响应。否则，它将呈现响应并在其中包含`Last-Modified`头。

通常，此机制是在每个客户端基础上使用的。`Rack::Cache`允许我们在多个客户端之间共享此缓存机制。我们可以在对`stale?`的调用中启用跨客户端缓存：

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end
end
```

这意味着`Rack::Cache`将在Rails缓存中存储URL的`Last-Modified`值，并在任何后续对相同URL的入站请求中添加`If-Modified-Since`头。

可以将其视为使用HTTP语义的页面缓存。

### 使用 Rack::Sendfile

当您在Rails控制器中使用`send_file`方法时，它会设置`X-Sendfile`头。`Rack::Sendfile`负责实际发送文件。

如果您的前端服务器支持加速文件发送，`Rack::Sendfile`将将实际的文件发送工作卸载到前端服务器。

您可以使用[`config.action_dispatch.x_sendfile_header`][]在适当环境的配置文件中配置前端服务器用于此目的的头的名称。

您可以在[Rack::Sendfile文档](https://www.rubydoc.info/gems/rack/Rack/Sendfile)中了解有关如何与常用前端一起使用`Rack::Sendfile`的更多信息。

以下是一些流行服务器的此头的值，一旦这些服务器配置为支持加速文件发送：

```ruby
# Apache和lighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

请确保按照`Rack::Sendfile`文档中的说明配置服务器以支持这些选项。

### 使用 ActionDispatch::Request

`ActionDispatch::Request#params`将以JSON格式从客户端获取参数，并在控制器内部的`params`中使其可用。

要使用此功能，您的客户端需要使用JSON编码的参数发出请求，并将`Content-Type`指定为`application/json`。

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

`ActionDispatch::Request`将检查`Content-Type`，您的参数将是：

```ruby
{ person: { firstName: "Yehuda", lastName: "Katz" } }
```

### 使用会话中间件

以下用于会话管理的中间件在API应用程序中被排除在外，因为它们通常不需要会话。如果您的API客户端之一是浏览器，您可能希望重新添加其中之一：

- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

重新添加它们的技巧是，默认情况下，它们在添加时会传递`session_options`（包括会话密钥），因此您不能只添加一个`session_store.rb`初始化程序，添加`use ActionDispatch::Session::CookieStore`并使会话正常工作。（明确地说：会话可能有效，但会忽略会话选项 - 即会话密钥将默认为`_session_id`）

而不是使用初始化程序，您将不得不在构建中间件之前的某个地方设置相关选项（如`config/application.rb`），并将它们传递给您首选的中间件，如下所示：

```ruby
# 这也为下面的使用配置session_options
config.session_store :cookie_store, key: '_interslice_session'

# 对所有会话管理都是必需的（无论session_store如何）
config.middleware.use ActionDispatch::Cookies

config.middleware.use config.session_store, config.session_options
```

### 其他中间件

Rails附带了许多其他中间件，您可能希望在API应用程序中使用，特别是如果您的API客户端之一是浏览器：

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`

可以通过以下方式添加其中任何一个中间件：

```ruby
config.middleware.use Rack::MethodOverride
```

### 删除中间件

如果您不想使用API-only中间件集中默认包含的中间件，可以使用以下方法将其删除：
```ruby
config.middleware.delete ::Rack::Sendfile
```

请注意，删除这些中间件将会删除Action Controller中的某些功能支持。

选择控制器模块
---------------------------

API应用程序（使用`ActionController::API`）默认包含以下控制器模块：

|   |   |
|---|---|
| `ActionController::UrlFor` | 使`url_for`和类似的辅助方法可用。 |
| `ActionController::Redirecting` | 支持`redirect_to`。 |
| `AbstractController::Rendering` 和 `ActionController::ApiRendering` | 基本的渲染支持。 |
| `ActionController::Renderers::All` | 支持`render :json`和相关方法。 |
| `ActionController::ConditionalGet` | 支持`stale?`。 |
| `ActionController::BasicImplicitRender` | 确保如果没有明确的响应，则返回一个空响应。 |
| `ActionController::StrongParameters` | 支持与Active Model批量赋值结合使用的参数过滤。 |
| `ActionController::DataStreaming` | 支持`send_file`和`send_data`。 |
| `AbstractController::Callbacks` | 支持`before_action`和类似的辅助方法。 |
| `ActionController::Rescue` | 支持`rescue_from`。 |
| `ActionController::Instrumentation` | 支持Action Controller定义的仪表盘钩子（有关详细信息，请参见[仪表盘指南](active_support_instrumentation.html#action-controller)）。 |
| `ActionController::ParamsWrapper` | 将参数哈希包装成嵌套哈希，这样您就不必为发送POST请求的根元素指定。 |
| `ActionController::Head` | 支持返回仅包含头部的响应。 |

其他插件可能会添加其他模块。您可以在Rails控制台中获取包含在`ActionController::API`中的所有模块的列表：

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

### 添加其他模块

所有Action Controller模块都知道它们的依赖模块，因此您可以随意将任何模块包含到您的控制器中，并且所有依赖项也将被包含和设置。

您可能想要添加的一些常见模块：

- `AbstractController::Translation`：支持`l`和`t`本地化和翻译方法。
- 支持基本、摘要或令牌HTTP身份验证：
  * `ActionController::HttpAuthentication::Basic::ControllerMethods`
  * `ActionController::HttpAuthentication::Digest::ControllerMethods`
  * `ActionController::HttpAuthentication::Token::ControllerMethods`
- `ActionView::Layouts`：在渲染时支持布局。
- `ActionController::MimeResponds`：支持`respond_to`。
- `ActionController::Cookies`：支持`cookies`，包括对签名和加密cookie的支持。这需要cookies中间件。
- `ActionController::Caching`：为API控制器支持视图缓存。请注意，您需要在控制器内手动指定缓存存储，如下所示：

    ```ruby
    class ApplicationController < ActionController::API
      include ::ActionController::Caching
      self.cache_store = :mem_cache_store
    end
    ```

    Rails不会自动传递此配置。

添加模块的最佳位置是在您的`ApplicationController`中，但您也可以将模块添加到单个控制器中。
[`config.debug_exception_response_format`]: configuring.html#config-debug-exception-response-format
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
