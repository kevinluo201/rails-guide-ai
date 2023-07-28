**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3529115f04b9d5fe01401105d9c154e2
Action Controller 概述
==========================

在本指南中，您将学习控制器的工作原理以及它们如何适应应用程序中的请求周期。

阅读本指南后，您将了解如何：

* 跟随请求通过控制器的流程。
* 限制传递给控制器的参数。
* 在会话或cookie中存储数据以及原因。
* 使用过滤器在请求处理期间执行代码。
* 使用 Action Controller 的内置 HTTP 身份验证。
* 直接向用户的浏览器流式传输数据。
* 过滤敏感参数，使其不出现在应用程序的日志中。
* 处理在请求处理过程中可能引发的异常。
* 使用内置的健康检查端点进行负载均衡器和运行时间监视器。

--------------------------------------------------------------------------------

控制器的作用是什么？
--------------------------

Action Controller 是 [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) 中的 C。在路由确定请求使用哪个控制器之后，控制器负责理解请求并生成适当的输出。幸运的是，Action Controller 为您完成了大部分的基础工作，并使用智能约定使其尽可能简单明了。

对于大多数常规的 [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer) 应用程序，控制器将接收请求（作为开发人员，您看不到这一点），从模型中获取或保存数据，并使用视图创建 HTML 输出。如果您的控制器需要以稍微不同的方式处理事务，那也没有问题，这只是控制器工作的最常见方式。

因此，可以将控制器视为模型和视图之间的中间人。它使模型数据可供视图使用，以便将数据显示给用户，并将用户数据保存或更新到模型中。

注意：有关路由过程的更多详细信息，请参阅 [Rails Routing from the Outside In](routing.html)。

控制器命名约定
----------------------------

Rails 中控制器的命名约定偏向于对控制器名称中的最后一个单词进行复数化，尽管这并不是严格要求的（例如 `ApplicationController`）。例如，`ClientsController` 优于 `ClientController`，`SiteAdminsController` 优于 `SiteAdminController` 或 `SitesAdminsController`，等等。

遵循此约定将使您能够使用默认的路由生成器（例如 `resources` 等）而无需限定每个 `:path` 或 `:controller`，并且将使命名路由助手在整个应用程序中的使用保持一致。有关更多详细信息，请参阅 [Layouts and Rendering Guide](layouts_and_rendering.html)。

注意：控制器命名约定与模型的命名约定不同，模型的命名约定要求使用单数形式命名。

方法和操作
-------------------

控制器是一个 Ruby 类，它继承自 `ApplicationController` 并具有与任何其他类一样的方法。当您的应用程序接收到请求时，路由将确定要运行的控制器和操作，然后 Rails 创建该控制器的实例并运行与操作同名的方法。

```ruby
class ClientsController < ApplicationController
  def new
  end
end
```

例如，如果用户在您的应用程序中访问 `/clients/new` 来添加新客户端，Rails 将创建 `ClientsController` 的实例并调用其 `new` 方法。请注意，上述示例中的空方法也可以正常工作，因为除非操作另有说明，否则 Rails 默认会渲染 `new.html.erb` 视图。通过创建一个新的 `Client`，`new` 方法可以在视图中使 `@client` 实例变量可访问：

```ruby
def new
  @client = Client.new
end
```

[Layouts and Rendering Guide](layouts_and_rendering.html) 对此进行了更详细的解释。

`ApplicationController` 继承自 [`ActionController::Base`][]，它定义了许多有用的方法。本指南将介绍其中一些方法，但如果您想了解其中的内容，可以在 [API 文档](https://api.rubyonrails.org/classes/ActionController.html) 或源代码中查看所有方法。

只有公共方法可以作为操作调用。最佳实践是降低那些不打算作为操作的方法的可见性（使用 `private` 或 `protected`），例如辅助方法或过滤器。

警告：一些方法名称被 Action Controller 保留。意外地将它们重新定义为操作，甚至作为辅助方法，可能会导致 `SystemStackError`。如果您的控制器仅限于 RESTful [Resource Routing][] 操作，您不需要担心这个问题。

注意：如果您必须使用保留方法作为操作名称，一种解决方法是使用自定义路由将保留方法名称映射到非保留的操作方法。
[资源路由]: routing.html#resource-routing-the-rails-default

参数
----------

您可能希望在控制器操作中访问用户发送的数据或其他参数。Web应用程序中有两种可能的参数类型。第一种是作为URL的一部分发送的参数，称为查询字符串参数。查询字符串是URL中"?"之后的所有内容。第二种类型的参数通常称为POST数据。这些信息通常来自用户填写的HTML表单。它被称为POST数据，因为它只能作为HTTP POST请求的一部分发送。Rails不区分查询字符串参数和POST参数，两者都可以在控制器的[`params`][]哈希中使用：

```ruby
class ClientsController < ApplicationController
  # 这个操作使用查询字符串参数，因为它是通过HTTP GET请求运行的，
  # 但这不会影响参数的访问方式。对于列出已激活的客户端，
  # 此操作的URL将如下所示：/clients?status=activated
  def index
    if params[:status] == "activated"
      @clients = Client.activated
    else
      @clients = Client.inactivated
    end
  end

  # 这个操作使用POST参数。它们很可能来自用户提交的HTML表单。
  # 这个RESTful请求的URL将是"/clients"，数据将作为请求体的一部分发送。
  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client
    else
      # 这一行覆盖了默认的渲染行为，否则会渲染"create"视图。
      render "new"
    end
  end
end
```


### 哈希和数组参数

`params`哈希不限于一维键和值。它可以包含嵌套的数组和哈希。要发送一个值的数组，请在键名后面添加一对空方括号"[]"：

```
GET /clients?ids[]=1&ids[]=2&ids[]=3
```

注意：在此示例中，实际的URL将被编码为"/clients?ids%5b%5d=1&ids%5b%5d=2&ids%5b%5d=3"，因为"["和"]"字符在URL中不允许出现。大多数情况下，您不必担心这个问题，因为浏览器会自动为您编码，而Rails会自动解码，但如果您发现自己必须手动将这些请求发送到服务器，请记住这一点。

`params[:ids]`的值现在将是`["1", "2", "3"]`。请注意，参数值始终是字符串；Rails不会尝试猜测或转换类型。

注意：在`params`中，诸如`[nil]`或`[nil, nil, ...]`之类的值会被默认替换为`[]`，出于安全原因。有关更多信息，请参阅[安全指南](security.html#unsafe-query-generation)。

要发送一个哈希，您需要在方括号中包含键名：

```html
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
```

当提交此表单时，`params[:client]`的值将是`{ "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } }`。请注意`params[:client][:address]`中的嵌套哈希。

`params`对象的行为类似于哈希，但允许您在键中交替使用符号和字符串。

### JSON参数

如果您的应用程序公开了API，您可能会接受JSON格式的参数。如果请求的"Content-Type"头设置为"application/json"，Rails将自动将参数加载到`params`哈希中，您可以像通常一样访问它们。

例如，如果您发送了以下JSON内容：

```json
{ "company": { "name": "acme", "address": "123 Carrot Street" } }
```

您的控制器将接收到`params[:company]`，其值为`{ "name" => "acme", "address" => "123 Carrot Street" }`。

此外，如果您在初始化程序中打开了`config.wrap_parameters`或在控制器中调用了[`wrap_parameters`][]，您可以安全地省略JSON参数中的根元素。在这种情况下，参数将被克隆并用基于控制器名称选择的键进行包装。因此，上述JSON请求可以写成：

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

假设您将数据发送到`CompaniesController`，那么它将被包装在`:company`键中，如下所示：
```ruby
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: "123 Carrot Street" } }
```

您可以通过查阅[API文档](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)来自定义键的名称或要包装的特定参数。

注意：对于解析XML参数的支持已被提取到名为`actionpack-xml_parser`的gem中。


### 路由参数

`params`哈希将始终包含`:controller`和`:action`键，但您应该使用[`controller_name`][]和[`action_name`][]方法来访问这些值。路由定义的任何其他参数，例如`:id`，也将可用。例如，考虑一个客户列表，列表可以显示活动或非活动客户。我们可以添加一个捕获"pretty" URL中的`:status`参数的路由：

```ruby
get '/clients/:status', to: 'clients#index', foo: 'bar'
```

在这种情况下，当用户打开URL`/clients/active`时，`params[:status]`将被设置为"active"。当使用此路由时，`params[:foo]`也将被设置为"bar"，就像它是在查询字符串中传递的一样。您的控制器还将接收到`params[:action]`为"index"和`params[:controller]`为"clients"。


### `default_url_options`

您可以通过在控制器中定义一个名为`default_url_options`的方法来为URL生成设置全局默认参数。这样的方法必须返回一个带有所需默认值的哈希，其键必须是符号：

```ruby
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

这些选项将用作生成URL的起点，因此可能会被传递给`url_for`调用的选项覆盖。

如果您在`ApplicationController`中定义了`default_url_options`，如上面的示例中所示，这些默认值将用于所有URL生成。该方法也可以在特定控制器中定义，这样它只会影响在那里生成的URL。

在给定的请求中，实际上并不会为每个生成的URL调用该方法。出于性能原因，返回的哈希被缓存，并且每个请求最多只有一个调用。

### 强参数

使用强参数，Action Controller参数在未经许可之前禁止用于Active Model的批量赋值。这意味着您必须对要允许进行批量更新的属性做出明确的决策。这是一种更好的安全实践，有助于防止意外允许用户更新敏感的模型属性。

此外，参数可以被标记为必需的，并将通过预定义的抛出/捕获流程流动，如果没有传递所有必需的参数，则会返回400 Bad Request错误。

```ruby
class PeopleController < ActionController::Base
  # 这将引发ActiveModel::ForbiddenAttributesError异常，
  # 因为它在没有明确许可的情况下使用了批量赋值。
  def create
    Person.create(params[:person])
  end

  # 只要参数中有一个person键，这将通过，否则它将引发一个
  # ActionController::ParameterMissing异常，该异常将被
  # ActionController::Base捕获并转换为400 Bad Request错误。
  def update
    person = current_account.people.find(params[:id])
    person.update!(person_params)
    redirect_to person
  end

  private
    # 使用私有方法封装可允许的参数只是一个好的模式，
    # 因为您可以在create和update之间重用相同的许可列表。
    # 此外，您可以使用特定用户的检查可允许的属性来专门化此方法。
    def person_params
      params.require(:person).permit(:name, :age)
    end
end
```

#### 允许的标量值

调用[`permit`][]如下所示：

```ruby
params.permit(:id)
```

如果指定的键（`:id`）出现在`params`中并且具有允许的标量值，则允许其包含。否则，该键将被过滤掉，因此无法注入数组、哈希或任何其他对象。

允许的标量类型包括`String`、`Symbol`、`NilClass`、`Numeric`、`TrueClass`、`FalseClass`、`Date`、`Time`、`DateTime`、`StringIO`、`IO`、`ActionDispatch::Http::UploadedFile`和`Rack::Test::UploadedFile`。

要声明`params`中的值必须是允许的标量值数组，请将键映射到一个空数组：

```ruby
params.permit(id: [])
```

有时候声明哈希参数或其内部结构的有效键是不可能或不方便的。只需映射到一个空哈希：

```ruby
params.permit(preferences: {})
```

但要小心，因为这会打开任意输入的大门。在这种情况下，`permit`确保返回结构中的值是允许的标量，并过滤掉其他任何内容。
为了允许整个参数哈希，可以使用[`permit!`][]方法：

```ruby
params.require(:log_entry).permit!
```

这将标记`:log_entry`参数哈希及其任何子哈希为允许，并且不检查允许的标量，任何内容都被接受。在使用`permit!`时要非常小心，因为它将允许所有当前和未来的模型属性进行批量赋值。

#### 嵌套参数

您还可以在嵌套参数上使用`permit`，例如：

```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

此声明允许`name`、`emails`和`friends`属性。预期`emails`将是一个允许的标量值数组，而`friends`将是一个具有特定属性的资源数组：它们应该具有一个`name`属性（允许任何标量值），一个`hobbies`属性作为允许的标量值数组，以及一个`family`属性，该属性限制为具有一个`name`（这里也允许任何允许的标量值）。

#### 更多示例

您可能还想在`new`操作中使用允许的属性。这会引发一个问题，即在调用`new`时，通常无法对根键使用[`require`][]，因为它不存在：

```ruby
# 使用`fetch`，您可以提供一个默认值并从那里使用Strong Parameters API。
params.fetch(:blog, {}).permit(:title, :author)
```

模型类方法`accepts_nested_attributes_for`允许您更新和删除关联记录。这基于`id`和`_destroy`参数：

```ruby
# 允许:id和:_destroy
params.require(:author).permit(:name, books_attributes: [:title, :id, :_destroy])
```

具有整数键的哈希被视为不同，您可以将属性声明为直接子项。当您将`accepts_nested_attributes_for`与`has_many`关联结合使用时，会得到这些类型的参数：

```ruby
# 允许以下数据：
# {"book" => {"title" => "Some Book",
#             "chapters_attributes" => { "1" => {"title" => "First Chapter"},
#                                        "2" => {"title" => "Second Chapter"}}}}

params.require(:book).permit(:title, chapters_attributes: [:title])
```

想象一个场景，您有表示产品名称的参数，以及与该产品关联的任意数据的哈希，并且您希望允许产品名称属性以及整个数据哈希：

```ruby
def product_params
  params.require(:product).permit(:name, data: {})
end
```

#### 超出Strong Parameters的范围

Strong Parameters API是根据最常见的用例设计的。它不是为了解决所有参数过滤问题而设计的银弹。但是，您可以轻松地将API与自己的代码混合使用，以适应您的情况。

会话
-------

您的应用程序为每个用户创建一个会话，您可以在其中存储少量数据，这些数据将在请求之间保持。会话仅在控制器和视图中可用，并且可以使用多种不同的存储机制之一：

* [`ActionDispatch::Session::CookieStore`][] - 在客户端上存储所有内容。
* [`ActionDispatch::Session::CacheStore`][] - 将数据存储在Rails缓存中。
* [`ActionDispatch::Session::MemCacheStore`][] - 将数据存储在memcached集群中（这是一种传统实现；请考虑改用`CacheStore`）。
* [`ActionDispatch::Session::ActiveRecordStore`][activerecord-session_store] - 使用Active Record将数据存储在数据库中（需要[`activerecord-session_store`][activerecord-session_store] gem）。
* 自定义存储或由第三方gem提供的存储

所有会话存储都使用cookie存储每个会话的唯一ID（您必须使用cookie，Rails不允许您将会话ID作为URL参数传递，因为这样不够安全）。

对于大多数存储，此ID用于在服务器上查找会话数据，例如在数据库表中。有一个例外情况，即默认和推荐的会话存储 - CookieStore - 它将所有会话数据存储在cookie本身中（如果需要，仍然可以使用ID）。这样做的优点是非常轻量级，并且在新应用程序中使用会话时不需要任何设置。 cookie数据经过加密签名，以使其防篡改。它还进行了加密，因此任何可以访问它的人都无法读取其内容（如果已编辑，Rails将不接受它）。

CookieStore可以存储大约4 kB的数据 - 远少于其他存储方式 - 但通常足够使用。无论应用程序使用哪种会话存储，都不建议存储大量数据在会话中。特别是应避免在会话中存储复杂对象（如模型实例），因为服务器可能无法在请求之间重新组装它们，这将导致错误。
如果您的用户会话不存储关键数据或不需要长时间存在（例如，如果您只是使用Flash进行消息传递），您可以考虑使用`ActionDispatch::Session::CacheStore`。这将使用您为应用程序配置的缓存实现来存储会话。这样做的优点是您可以使用现有的缓存基础架构来存储会话，而无需进行任何额外的设置或管理。当然，缺点是会话是短暂的，可能随时消失。

在[安全指南](security.html)中了解更多关于会话存储的信息。

如果您需要不同的会话存储机制，可以在初始化器中进行更改：

```ruby
Rails.application.config.session_store :cache_store
```

有关更多信息，请参阅配置指南中的[`config.session_store`](configuring.html#config-session-store)。

Rails在签名会话数据时设置了会话键（cookie的名称）。您也可以在初始化器中更改这些键：

```ruby
# 修改此文件时请确保重新启动服务器。
Rails.application.config.session_store :cookie_store, key: '_your_app_session'
```

您还可以传递一个`:domain`键，并指定cookie的域名：

```ruby
# 修改此文件时请确保重新启动服务器。
Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: ".example.com"
```

Rails在`config/credentials.yml.enc`中为`CookieStore`设置了用于签名会话数据的密钥。您可以使用`bin/rails credentials:edit`进行更改。

```yaml
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# 用作Rails中所有MessageVerifiers的基本密钥，包括用于保护cookie的密钥。
secret_key_base: 492f...
```

注意：当使用`CookieStore`时更改`secret_key_base`将使所有现有会话失效。



### 访问会话

在控制器中，您可以通过`session`实例方法访问会话。

注意：会话是惰性加载的。如果您在操作的代码中不访问会话，它们将不会被加载。因此，您永远不需要禁用会话，只需不访问它们即可。

会话值以键/值对的形式存储，类似于哈希：

```ruby
class ApplicationController < ActionController::Base
  private
    # 通过存储在键为:current_user_id的会话中的ID查找用户
    # 这是处理Rails应用程序中用户登录的常见方法；登录设置会话值，
    # 登出则删除它。
    def current_user
      @_current_user ||= session[:current_user_id] &&
        User.find_by(id: session[:current_user_id])
    end
end
```

要将某些内容存储在会话中，只需像哈希一样将其分配给键：

```ruby
class LoginsController < ApplicationController
  # "创建"登录，也就是"登录用户"
  def create
    if user = User.authenticate(params[:username], params[:password])
      # 将用户ID保存在会话中，以便在后续请求中使用
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end
end
```

要从会话中删除某些内容，请删除键/值对：

```ruby
class LoginsController < ApplicationController
  # "删除"登录，也就是"注销用户"
  def destroy
    # 从会话中删除用户ID
    session.delete(:current_user_id)
    # 清除缓存的当前用户
    @_current_user = nil
    redirect_to root_url, status: :see_other
  end
end
```

要重置整个会话，请使用[`reset_session`][]。


### 闪存

闪存是会话的一个特殊部分，每个请求都会清除它。这意味着存储在其中的值只在下一个请求中可用，这对于传递错误消息等非常有用。

可以通过[`flash`][]方法访问闪存。与会话一样，闪存被表示为一个哈希。

让我们以注销操作为例。控制器可以发送一条消息，在下一个请求中将其显示给用户：

```ruby
class LoginsController < ApplicationController
  def destroy
    session.delete(:current_user_id)
    flash[:notice] = "您已成功注销。"
    redirect_to root_url, status: :see_other
  end
end
```

请注意，还可以在重定向中分配闪存消息。您可以分配`:notice`、`:alert`或通用的`:flash`：

```ruby
redirect_to root_url, notice: "您已成功注销。"
redirect_to root_url, alert: "您被困在这里了！"
redirect_to root_url, flash: { referral_code: 1234 }
```

`destroy`操作将重定向到应用程序的`root_url`，其中将显示该消息。请注意，完全由下一个操作决定前一个操作在闪存中放入的内容将如何处理（如果有的话）。按照惯例，在应用程序的布局中显示闪存中的任何错误警报或通知：

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

这样，如果一个动作设置了一个通知或警告消息，布局将自动显示它。

您可以传递会话可以存储的任何内容；您不仅限于通知和警告：

```erb
<% if flash[:just_signed_up] %>
  <p class="welcome">欢迎来到我们的网站！</p>
<% end %>
```

如果您希望将闪存值传递到另一个请求中，请使用 [`flash.keep`][]：

```ruby
class MainController < ApplicationController
  # 假设此操作对应于 root_url，但您希望将此处的所有请求重定向到 UsersController#index。
  # 如果一个操作设置了闪存并重定向到这里，当另一个重定向发生时，值通常会丢失，但您可以使用 'keep' 来使其持久化到另一个请求。
  def index
    # 将持久化所有闪存值。
    flash.keep

    # 您还可以使用一个键来仅保留某种类型的值。
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```


#### `flash.now`

默认情况下，将值添加到闪存中将使它们在下一个请求中可用，但有时您可能希望在同一个请求中访问这些值。例如，如果 `create` 操作未能保存资源，并且您直接渲染 `new` 模板，那么这不会导致新的请求，但您可能仍然希望使用闪存显示消息。为此，您可以像使用普通的闪存一样使用 [`flash.now`][]：

```ruby
class ClientsController < ApplicationController
  def create
    @client = Client.new(client_params)
    if @client.save
      # ...
    else
      flash.now[:error] = "无法保存客户"
      render action: "new"
    end
  end
end
```


Cookies
-------

您的应用程序可以在客户端上存储少量数据 - 称为 cookie - 这些数据将在请求和会话之间持久保存。Rails 通过 [`cookies`][] 方法轻松访问 cookie，它 - 就像 `session` 一样 - 的工作方式类似于哈希：

```ruby
class CommentsController < ApplicationController
  def new
    # 如果评论者的姓名已存储在 cookie 中，则自动填充评论者的姓名
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:notice] = "感谢您的评论！"
      if params[:remember_name]
        # 记住评论者的姓名。
        cookies[:commenter_name] = @comment.author
      else
        # 删除评论者的姓名 cookie（如果有）。
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

请注意，虽然对于会话值，您可以将键设置为 `nil`，以删除 cookie 值，但您应该使用 `cookies.delete(:key)`。

Rails 还提供了一个签名 cookie 存储和一个加密 cookie 存储，用于存储敏感数据。签名 cookie 存储在 cookie 值上附加了一个加密签名，以保护其完整性。加密 cookie 存储在签名的基础上还对值进行了加密，以防止最终用户读取它们。有关更多详细信息，请参阅 [API 文档](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html)。

这些特殊的 cookie 存储使用序列化器将分配的值序列化为字符串，并在读取时将其反序列化为 Ruby 对象。您可以通过 [`config.action_dispatch.cookies_serializer`][] 指定要使用的序列化器。

新应用程序的默认序列化器是 `:json`。请注意，JSON 对于往返 Ruby 对象的支持有限。例如，`Date`、`Time` 和 `Symbol` 对象（包括 `Hash` 键）将被序列化和反序列化为 `String`：

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

如果您需要存储这些或更复杂的对象，您可能需要在后续请求中手动转换它们的值。

如果您使用 cookie 会话存储，上述内容也适用于 `session` 和 `flash` 哈希。


Rendering
---------

ActionController 使渲染 HTML、XML 或 JSON 数据变得轻松。如果您使用脚手架生成了一个控制器，它可能如下所示：

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

您可能会注意到上面的代码中我们使用的是 `render xml: @users`，而不是 `render xml: @users.to_xml`。如果对象不是字符串，那么 Rails 将自动为我们调用 `to_xml`。
您可以在[布局和渲染指南](layouts_and_rendering.html)中了解更多关于渲染的信息。

过滤器
-------

过滤器是在控制器动作之前、之后或周围运行的方法。

过滤器是继承的，因此如果您在`ApplicationController`上设置了一个过滤器，它将在应用程序中的每个控制器上运行。

"before"过滤器通过[`before_action`][]进行注册。它们可以停止请求周期。一个常见的"before"过滤器是要求用户登录才能运行动作的过滤器。您可以这样定义过滤器方法：

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private
    def require_login
      unless logged_in?
        flash[:error] = "您必须登录才能访问此部分"
        redirect_to new_login_url # 停止请求周期
      end
    end
end
```

该方法只是将错误消息存储在闪存中，并在用户未登录时重定向到登录表单。如果"before"过滤器渲染或重定向，动作将不会运行。如果在该过滤器之后还有其他过滤器计划运行，它们也将被取消。

在此示例中，过滤器被添加到`ApplicationController`中，因此应用程序中的所有控制器都会继承它。这将使应用程序中的所有内容都要求用户登录才能使用。出于明显的原因（用户首先无法登录！），并不是所有控制器或动作都需要这样做。您可以使用[`skip_before_action`][]阻止此过滤器在特定动作之前运行：

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

现在，`LoginsController`的`new`和`create`动作将像以前一样工作，而无需用户登录。`：only`选项用于仅跳过这些动作的过滤器，还有一个`：except`选项可以反过来使用。这些选项也可以在添加过滤器时使用，因此您可以添加仅对选定动作运行的过滤器。

注意：多次使用不同选项调用相同的过滤器将不起作用，因为最后一个过滤器定义将覆盖之前的定义。


### After过滤器和Around过滤器

除了"before"过滤器之外，您还可以在动作执行后或动作之前和之后运行过滤器。

"after"过滤器通过[`after_action`][]进行注册。它们与"before"过滤器类似，但由于动作已经运行，它们可以访问即将发送给客户端的响应数据。显然，"after"过滤器无法阻止动作运行。请注意，"after"过滤器仅在成功执行动作时执行，而在请求周期中引发异常时不执行。

"around"过滤器通过[`around_action`][]进行注册。它们负责通过yield运行其关联的动作，类似于Rack中间件的工作方式。

例如，在具有批准工作流程的网站中，管理员可以通过在事务中应用更改来轻松预览它们：

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

请注意，"around"过滤器还包装了渲染。特别是在上面的示例中，如果视图本身从数据库中读取数据（例如通过作用域），它将在事务中执行，并因此呈现数据以供预览。

您可以选择不yield并自己构建响应，这样动作将不会运行。


### 使用过滤器的其他方法

虽然使用私有方法并使用`before_action`、`after_action`或`around_action`将其添加是使用过滤器的最常见方法，但还有两种其他方法可以实现相同的功能。

第一种方法是直接在`*_action`方法中使用块。该块接收控制器作为参数。上面的`require_login`过滤器可以重写为使用块的方式：

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless controller.send(:logged_in?)
      flash[:error] = "您必须登录才能访问此部分"
      redirect_to new_login_url
    end
  end
end
```

请注意，此情况下的过滤器使用`send`，因为`logged_in?`方法是私有的，并且过滤器不在控制器的范围内运行。这不是推荐的实现此特定过滤器的方式，但在更简单的情况下，它可能是有用的。
特别是对于`around_action`，该块还会在`action`中产生：

```ruby
around_action { |_controller, action| time(&action) }
```

第二种方法是使用一个类（实际上，任何响应正确方法的对象都可以）来处理过滤。这在更复杂的情况下非常有用，无法使用其他两种方法以可读和可重用的方式实现。例如，您可以再次重写登录过滤器以使用一个类：

```ruby
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.before(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "You must be logged in to access this section"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

同样，这对于此过滤器来说不是一个理想的示例，因为它不在控制器的范围内运行，而是将控制器作为参数传递。过滤器类必须实现与过滤器相同名称的方法，因此对于`before_action`过滤器，类必须实现一个`before`方法，依此类推。`around`方法必须`yield`以执行操作。

请求伪造保护
--------------------------

跨站点请求伪造是一种攻击类型，其中一个站点欺骗用户在另一个站点上发出请求，可能在用户不知情或未经许可的情况下添加、修改或删除该站点上的数据。

避免这种情况的第一步是确保所有“破坏性”操作（创建、更新和删除）只能通过非GET请求访问。如果您遵循RESTful约定，您已经在做到这一点。然而，恶意站点仍然可以很容易地向您的站点发送非GET请求，这就是请求伪造保护的作用。顾名思义，它保护免受伪造请求的攻击。

这样做的方法是在每个请求中添加一个只有您的服务器知道的不可猜测的令牌。这样，如果请求没有正确的令牌，将拒绝访问。

如果您生成这样的表单：

```erb
<%= form_with model: @user do |form| %>
  <%= form.text_field :username %>
  <%= form.text_field :password %>
<% end %>
```

您将看到令牌作为隐藏字段添加：

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- fields -->
</form>
```

Rails会将此令牌添加到使用[表单助手](form_helpers.html)生成的每个表单中，因此大多数情况下您不必担心它。如果您手动编写表单或需要出于其他原因添加令牌，可以通过`form_authenticity_token`方法获得：

`form_authenticity_token`生成一个有效的身份验证令牌。这在Rails没有自动添加它的地方非常有用，比如在自定义Ajax调用中。

[安全指南](security.html)中有更多相关信息，以及在开发Web应用程序时应该注意的许多其他安全问题。

请求和响应对象
--------------------------------

在每个控制器中，有两个访问器方法指向与当前执行的请求周期相关联的请求和响应对象。[`request`][]方法包含[`ActionDispatch::Request`][]的实例，而[`response`][]方法返回一个表示将发送回客户端的响应对象。


### `request`对象

请求对象包含有关从客户端发出的请求的许多有用信息。要获取可用方法的完整列表，请参阅[Rails API文档](https://api.rubyonrails.org/classes/ActionDispatch/Request.html)和[Rack文档](https://www.rubydoc.info/github/rack/rack/Rack/Request)。您可以在此对象上访问的属性包括：

| `request`的属性                           | 目的                                                                             |
| ----------------------------------------- | -------------------------------------------------------------------------------- |
| `host`                                    | 用于此请求的主机名。                                                             |
| `domain(n=2)`                             | 主机名的前`n`个段，从右侧开始（TLD）。                                           |
| `format`                                  | 客户端请求的内容类型。                                                           |
| `method`                                  | 请求所使用的HTTP方法。                                                           |
| `get?`、`post?`、`patch?`、`put?`、`delete?`、`head?` | 如果HTTP方法是GET/POST/PATCH/PUT/DELETE/HEAD，则返回true。   |
| `headers`                                 | 返回包含与请求关联的标头的哈希。                                                 |
| `port`                                    | 用于请求的端口号（整数）。                                                       |
| `protocol`                                | 返回包含使用的协议加上“：//”的字符串，例如“http://”。                            |
| `query_string`                            | URL的查询字符串部分，即“？”后面的所有内容。                                      |
| `remote_ip`                               | 客户端的IP地址。                                                                 |
| `url`                                     | 用于请求的完整URL。                                                              |
#### `path_parameters`、`query_parameters` 和 `request_parameters`

Rails会将请求中的所有参数收集到`params`哈希中，无论它们是作为查询字符串的一部分还是作为请求体的一部分发送的。请求对象有三个访问器，根据参数的来源不同，可以访问这些参数。[`query_parameters`][]哈希包含作为查询字符串的一部分发送的参数，而[`request_parameters`][]哈希包含作为请求体的一部分发送的参数。[`path_parameters`][]哈希包含被路由识别为属于导致此特定控制器和动作的路径的一部分的参数。


### `response` 对象

通常不直接使用响应对象，而是在执行操作和渲染要发送回用户的数据时构建响应对象，但有时（例如在后过滤器中）直接访问响应对象可能很有用。其中一些访问器方法也有设置器，允许您更改它们的值。要获取可用方法的完整列表，请参阅[Rails API文档](https://api.rubyonrails.org/classes/ActionDispatch/Response.html)和[Rack文档](https://www.rubydoc.info/github/rack/rack/Rack/Response)。

| `response` 的属性 | 目的                                                                                               |
| ----------------- | -------------------------------------------------------------------------------------------------- |
| `body`            | 这是发送回客户端的数据字符串。通常是HTML。                                                         |
| `status`          | 响应的HTTP状态码，例如200表示成功的请求，404表示文件未找到。                                         |
| `location`        | 客户端被重定向到的URL（如果有）。                                                                   |
| `content_type`    | 响应的内容类型。                                                                                   |
| `charset`         | 响应使用的字符集。默认为"utf-8"。                                                                   |
| `headers`         | 响应使用的头部。                                                                                   |

#### 设置自定义头部

如果要为响应设置自定义头部，则可以使用`response.headers`。头部属性是一个将头部名称映射到其值的哈希，Rails会自动设置其中一些头部。如果要添加或更改头部，只需将其分配给`response.headers`，如下所示：

```ruby
response.headers["Content-Type"] = "application/pdf"
```

注意：在上述情况下，直接使用`content_type`设置器更合理。

HTTP身份验证
--------------------

Rails提供了三种内置的HTTP身份验证机制：

* 基本身份验证（Basic Authentication）
* 摘要身份验证（Digest Authentication）
* 令牌身份验证（Token Authentication）

### HTTP基本身份验证

HTTP基本身份验证是一种由大多数浏览器和其他HTTP客户端支持的身份验证方案。例如，考虑一个只有在浏览器的HTTP基本对话框中输入用户名和密码后才能访问的管理部分。只需使用一个方法[`http_basic_authenticate_with`][]即可使用内置的身份验证。

```ruby
class AdminsController < ApplicationController
  http_basic_authenticate_with name: "humbaba", password: "5baa61e4"
end
```

有了这个设置，您可以创建从`AdminsController`继承的命名空间控制器。该过滤器将对这些控制器中的所有操作运行，使用HTTP基本身份验证保护它们。


### HTTP摘要身份验证

HTTP摘要身份验证优于基本身份验证，因为它不需要客户端在网络上发送未加密的密码（尽管在HTTPS上，HTTP基本身份验证是安全的）。在Rails中使用摘要身份验证只需要使用一个方法[`authenticate_or_request_with_http_digest`][]。

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

如上例所示，`authenticate_or_request_with_http_digest`块只接受一个参数 - 用户名。块返回密码。从`authenticate_or_request_with_http_digest`返回`false`或`nil`将导致身份验证失败。


### HTTP令牌身份验证

HTTP令牌身份验证是一种在HTTP `Authorization`头部中使用Bearer令牌的方案。有许多可用的令牌格式，描述它们超出了本文档的范围。

例如，假设您想要使用预先发行的身份验证令牌来执行身份验证和访问。在Rails中实现令牌身份验证只需要使用一个方法[`authenticate_or_request_with_http_token`][]。

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

如上例所示，`authenticate_or_request_with_http_token`块接受两个参数 - 令牌和包含从HTTP `Authorization`头部解析的选项的`Hash`。如果身份验证成功，块应返回`true`。在其中返回`false`或`nil`将导致身份验证失败。
流媒体和文件下载
----------------------------

有时您可能希望将文件发送给用户，而不是呈现HTML页面。Rails中的所有控制器都有[`send_data`][]和[`send_file`][]方法，它们都可以将数据流式传输到客户端。`send_file`是一个方便的方法，允许您提供磁盘上的文件名，并为您流式传输该文件的内容。

要将数据流式传输到客户端，请使用`send_data`：

```ruby
require "prawn"
class ClientsController < ApplicationController
  # 生成包含客户端信息的PDF文档并返回。用户将以文件下载的形式获得PDF。
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
        text "电子邮件：#{client.email}"
      end.render
    end
end
```

上面示例中的`download_pdf`操作将调用一个实际生成PDF文档并将其作为字符串返回的私有方法。然后，该字符串将作为文件下载流式传输到客户端，并向用户建议一个文件名。有时在向用户流式传输文件时，您可能不希望他们下载该文件。以图像为例，图像可以嵌入到HTML页面中。要告诉浏览器文件不应该被下载，您可以将`:disposition`选项设置为"inline"。此选项的相反和默认值为"attachment"。

### 发送文件

如果要发送已经存在于磁盘上的文件，请使用`send_file`方法。

```ruby
class ClientsController < ApplicationController
  # 流式传输已经生成并存储在磁盘上的文件。
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

这将以每次4KB的块读取和流式传输文件，避免一次性将整个文件加载到内存中。您可以使用`:stream`选项关闭流式传输，或使用`:buffer_size`选项调整块大小。

如果未指定`:type`，则将从`:filename`中指定的文件扩展名猜测出类型。如果未为扩展名注册内容类型，则将使用`application/octet-stream`。

警告：当使用来自客户端的数据（params、cookies等）来定位磁盘上的文件时，请小心，因为这是一种安全风险，可能允许某人访问他们不应该访问的文件。

提示：如果可以将静态文件保留在Web服务器上的公共文件夹中，而不是通过Rails流式传输静态文件，这是不推荐的。让用户直接使用Apache或其他Web服务器下载文件会更高效，避免不必要地通过整个Rails堆栈进行请求。

### RESTful下载

虽然`send_data`工作正常，但如果您正在创建一个RESTful应用程序，通常不需要为文件下载创建单独的操作。在REST术语中，上述示例中的PDF文件可以被视为客户端资源的另一种表示形式。Rails提供了一种简洁的方法来进行“RESTful”下载。以下是如何重写示例，使PDF下载成为`show`操作的一部分，而无需流式传输：

```ruby
class ClientsController < ApplicationController
  # 用户可以请求将此资源作为HTML或PDF接收。
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

为了使此示例工作，您必须将PDF MIME类型添加到Rails中。可以通过将以下行添加到文件`config/initializers/mime_types.rb`来完成：

```ruby
Mime::Type.register "application/pdf", :pdf
```

注意：配置文件不会在每个请求上重新加载，因此必须重新启动服务器才能使其更改生效。

现在，用户可以通过在URL中添加“.pdf”来请求获取客户端的PDF版本：

```
GET /clients/1.pdf
```

### 实时流式传输任意数据

Rails允许您流式传输的不仅仅是文件。实际上，您可以在响应对象中流式传输任何您想要的内容。[`ActionController::Live`][]模块允许您与浏览器建立持久连接。使用此模块，您将能够在特定时间点向浏览器发送任意数据。
#### 添加实时流媒体

在控制器类中包含`ActionController::Live`将为控制器中的所有动作提供流数据的能力。您可以像这样混入模块：

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

上述代码将与浏览器保持持久连接，并发送100条消息`"hello world\n"`，每隔一秒发送一条。

上述示例中有几个要注意的地方。我们需要确保关闭响应流。忘记关闭流将导致套接字永远保持打开状态。在写入响应流之前，我们还必须将内容类型设置为`text/event-stream`。这是因为在响应已提交（当`response.committed?`返回真值时）后，无法再写入标头，而在`write`或`commit`响应流时会发生提交。

#### 示例用法

假设您正在制作一个卡拉OK机，用户想要获取特定歌曲的歌词。每首`歌曲`有一定数量的行，每行需要`num_beats`的时间来完成演唱。

如果我们想以卡拉OK的方式返回歌词（只在歌手完成前一行时发送下一行），我们可以使用`ActionController::Live`如下所示：

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

上述代码在歌手完成前一行后才发送下一行。

#### 流媒体注意事项

流式传输任意数据是一种非常强大的工具。如前面的示例所示，您可以选择何时以及何种方式通过响应流发送数据。但是，您还应注意以下几点：

* 每个响应流都会创建一个新的线程，并从原始线程复制线程本地变量。拥有太多的线程本地变量可能会对性能产生负面影响。同样，大量的线程也可能影响性能。
* 如果未关闭响应流，将使相应的套接字永远保持打开状态。确保在使用响应流时调用`close`。
* WEBrick服务器会缓冲所有响应，因此包含`ActionController::Live`将无法正常工作。您必须使用不会自动缓冲响应的Web服务器。

日志过滤
-------------

Rails在`log`文件夹中为每个环境保留一个日志文件。这些日志文件在调试应用程序时非常有用，但在实时应用程序中，您可能不希望将每个信息都存储在日志文件中。

### 参数过滤

您可以通过将敏感的请求参数附加到应用程序配置中的[`config.filter_parameters`][]来过滤日志文件中的参数。这些参数将在日志中标记为[FILTERED]。

```ruby
config.filter_parameters << :password
```

注意：提供的参数将通过部分匹配正则表达式进行过滤。Rails会在适当的初始化器（`initializers/filter_parameter_logging.rb`）中添加一系列默认过滤器，包括`:passw`、`:secret`和`:token`，以处理典型应用程序参数，如`password`、`password_confirmation`和`my_token`。

### 重定向过滤

有时，希望从日志文件中过滤掉应用程序重定向到的一些敏感位置。您可以使用`config.filter_redirect`配置选项来实现这一点：

```ruby
config.filter_redirect << 's3.amazonaws.com'
```

您可以将其设置为字符串、正则表达式或两者的数组。

```ruby
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

匹配的URL将被标记为“[FILTERED]”。

救援
------

很可能您的应用程序会包含错误或引发需要处理的异常。例如，如果用户访问数据库中不存在的资源，Active Record将引发`ActiveRecord::RecordNotFound`异常。

Rails默认的异常处理对所有异常显示“500 Server Error”消息。如果请求是在本地进行的，将显示一个漂亮的回溯和一些附加信息，以便您可以找出出了什么问题并处理它。如果请求是远程的，Rails将只向用户显示一个简单的“500 Server Error”消息，或者如果存在路由错误或找不到记录，则显示“404 Not Found”。有时，您可能希望自定义如何捕获这些错误以及如何向用户显示它们。在Rails应用程序中有几个级别的异常处理可用：
### 默认的500和404模板

默认情况下，在生产环境中，应用程序将呈现404或500错误消息。在开发环境中，所有未处理的异常都会被简单地引发。这些消息包含在公共文件夹中的静态HTML文件中，分别为`404.html`和`500.html`。您可以自定义这些文件以添加一些额外的信息和样式，但请记住它们是静态HTML；即您不能在其中使用ERB、SCSS、CoffeeScript或布局。

### `rescue_from`

如果您想在捕获错误时做一些更复杂的操作，可以使用[`rescue_from`][]，它可以处理整个控制器及其子类中的某种类型（或多种类型）的异常。

当`rescue_from`指令捕获到异常时，异常对象将传递给处理程序。处理程序可以是一个方法或传递给`:with`选项的`Proc`对象。您还可以直接使用块而不是显式的`Proc`对象。

以下是如何使用`rescue_from`拦截所有`ActiveRecord::RecordNotFound`错误并对其进行处理的示例。

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

当然，这个示例并不复杂，也没有改进默认的异常处理，但一旦您可以捕获所有这些异常，您就可以自由地对它们进行任何操作。例如，您可以创建自定义异常类，在用户无法访问应用程序的某个部分时抛出这些异常类：

```ruby
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private
    def user_not_authorized
      flash[:error] = "您无权访问此部分。"
      redirect_back(fallback_location: root_path)
    end
end

class ClientsController < ApplicationController
  # 检查用户是否具有正确的授权以访问客户端。
  before_action :check_authorization

  # 注意操作不必担心所有授权相关的事情。
  def edit
    @client = Client.find(params[:id])
  end

  private
    # 如果用户未经授权，只需抛出异常。
    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

警告：使用`Exception`或`StandardError`与`rescue_from`会导致严重的副作用，因为它会阻止Rails正确处理异常。因此，除非有充分的理由，否则不建议这样做。

注意：在生产环境中运行时，所有`ActiveRecord::RecordNotFound`错误都会呈现404错误页面。除非您需要自定义行为，否则不需要处理此错误。

注意：某些异常只能从`ApplicationController`类中进行救援，因为它们在控制器初始化之前引发，而操作得到执行。

强制使用HTTPS协议
--------------------

如果您希望确保只能通过HTTPS与您的控制器进行通信，您应该通过在环境配置中启用[`ActionDispatch::SSL`][]中间件来实现。

内置的健康检查端点
------------------------------

Rails还提供了一个内置的健康检查端点，可通过`/up`路径访问。如果应用程序在没有异常的情况下启动，该端点将返回200状态码，否则返回500状态码。

在生产环境中，许多应用程序需要向上报告其状态，无论是向一个当事情出错时会通知工程师的运行时间监视器，还是用于确定Pod健康状况的负载均衡器或Kubernetes控制器。这个健康检查被设计为一种一刀切，适用于许多情况。

虽然任何新生成的Rails应用程序都将在`/up`处进行健康检查，但您可以在您的"config/routes.rb"中将路径配置为任何您想要的内容：

```ruby
Rails.application.routes.draw do
  get "healthz" => "rails/health#show", as: :rails_health_check
end
```

现在，健康检查将通过`/healthz`路径访问。

注意：此端点不反映您应用程序的所有依赖项（如数据库或Redis集群）的状态。如果您有特定的应用程序需求，请将"rails/health#show"替换为您自己的控制器操作。

请仔细考虑您想要检查的内容，因为这可能导致您的应用程序由于第三方服务出现故障而被重新启动。理想情况下，您应该设计您的应用程序以优雅地处理这些故障。
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
