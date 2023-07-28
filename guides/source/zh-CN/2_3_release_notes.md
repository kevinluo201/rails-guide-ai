**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 77b47af4826df984dead9f6263cfd135
Ruby on Rails 2.3 发布说明
===============================

Rails 2.3 提供了各种新的和改进的功能，包括全面的 Rack 集成，对 Rails 引擎的支持进行了更新，Active Record 的嵌套事务，动态和默认作用域，统一的渲染，更高效的路由，应用程序模板和静默回溯。这个列表涵盖了主要的升级内容，但不包括每一个小的错误修复和更改。如果你想查看所有内容，请查看 GitHub 上主要 Rails 仓库的 [提交列表](https://github.com/rails/rails/commits/2-3-stable) 或者查看各个 Rails 组件的 `CHANGELOG` 文件。

--------------------------------------------------------------------------------

应用程序架构
------------------------

Rails 应用程序的架构有两个主要变化：完全集成了[Rack](https://rack.github.io/)模块化的 Web 服务器接口，并重新支持了 Rails 引擎。

### Rack 集成

Rails 现在已经摆脱了它的 CGI 过去，到处都使用 Rack。这需要并导致了大量的内部更改（但如果你使用 CGI，不用担心；Rails 现在通过代理接口支持 CGI）。尽管如此，这对于 Rails 内部来说是一个重大的变化。升级到 2.3 版本后，你应该在本地环境和生产环境上进行测试。一些需要测试的内容包括：

* 会话（Sessions）
* Cookie
* 文件上传
* JSON/XML API

以下是与 Rack 相关的更改摘要：

* `script/server` 已经切换到使用 Rack，这意味着它支持任何兼容 Rack 的服务器。`script/server` 还会加载 rackup 配置文件（如果存在的话）。默认情况下，它会查找 `config.ru` 文件，但你可以使用 `-c` 开关来覆盖。
* FCGI 处理程序经过 Rack 处理。
* `ActionController::Dispatcher` 维护自己的默认中间件栈。中间件可以注入、重新排序和删除。栈在启动时编译成链表。你可以在 `environment.rb` 中配置中间件栈。
* 添加了 `rake middleware` 任务来检查中间件栈。这对于调试中间件栈的顺序非常有用。
* 集成测试运行器已经修改为执行整个中间件和应用程序栈。这使得集成测试非常适合测试 Rack 中间件。
* `ActionController::CGIHandler` 是一个兼容旧版 CGI 的 Rack 包装器。`CGIHandler` 用于接收旧版 CGI 对象，并将其环境信息转换为 Rack 兼容的形式。
* `CgiRequest` 和 `CgiResponse` 已被移除。
* 会话存储现在是延迟加载的。如果在请求期间从未访问会话对象，则不会尝试加载会话数据（解析 cookie、从 memcache 加载数据或查找 Active Record 对象）。
* 在测试中，你不再需要使用 `CGI::Cookie.new` 来设置 cookie 值。将 `String` 值分配给 `request.cookies["foo"]` 现在会按预期设置 cookie。
* `CGI::Session::CookieStore` 已被替换为 `ActionController::Session::CookieStore`。
* `CGI::Session::MemCacheStore` 已被替换为 `ActionController::Session::MemCacheStore`。
* `CGI::Session::ActiveRecordStore` 已被替换为 `ActiveRecord::SessionStore`。
* 你仍然可以使用 `ActionController::Base.session_store = :active_record_store` 来更改会话存储。
* 默认会话选项仍然使用 `ActionController::Base.session = { :key => "..." }` 设置。但是，`：session_domain` 选项已更名为 `:domain`。
* 通常包装整个请求的互斥锁已经移动到中间件 `ActionController::Lock` 中。
* `ActionController::AbstractRequest` 和 `ActionController::Request` 已合并。新的 `ActionController::Request` 继承自 `Rack::Request`。这会影响测试请求中对 `response.headers['type']` 的访问。请改用 `response.content_type`。
* 如果已加载 `ActiveRecord`，则会自动将 `ActiveRecord::QueryCache` 中间件插入到中间件栈中。该中间件设置并刷新每个请求的 Active Record 查询缓存。
* Rails 路由器和控制器类遵循 Rack 规范。你可以直接调用控制器，例如 `SomeController.call(env)`。路由器将路由参数存储在 `rack.routing_args` 中。
* `ActionController::Request` 继承自 `Rack::Request`。
* 不再使用 `config.action_controller.session = { :session_key => 'foo', ...`，而是使用 `config.action_controller.session = { :key => 'foo', ...`。
* 使用 `ParamsParser` 中间件预处理任何 XML、JSON 或 YAML 请求，以便在任何 `Rack::Request` 对象之后可以正常读取它们。

### 对 Rails 引擎的更新支持

经过一些版本的升级，Rails 2.3 为 Rails 引擎（可以嵌入到其他应用程序中的 Rails 应用程序）提供了一些新功能。首先，引擎中的路由文件现在会自动加载和重新加载，就像你的 `routes.rb` 文件一样（这也适用于其他插件中的路由文件）。其次，如果你的插件有一个 app 文件夹，那么 app/[models|controllers|helpers] 将自动添加到 Rails 的加载路径中。引擎现在还支持添加视图路径，Action Mailer 和 Action View 也将使用引擎和其他插件的视图。
文档
-------------

[Ruby on Rails指南](https://guides.rubyonrails.org/)项目已经为Rails 2.3发布了几个额外的指南。此外，[单独的网站](https://edgeguides.rubyonrails.org/)维护了Edge Rails指南的更新副本。其他文档工作包括重新启动[Rails wiki](http://newwiki.rubyonrails.org/)和早期计划的Rails书籍。

* 更多信息：[Rails文档项目](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)

Ruby 1.9.1支持
------------------

无论您在运行Ruby 1.8还是现在发布的Ruby 1.9.1，Rails 2.3都应该通过自己的所有测试。但是，您应该知道，迁移到1.9.1需要检查所有数据适配器、插件和其他代码，以确保与Ruby 1.9.1兼容，以及Rails核心。

Active Record
-------------

Rails 2.3在Active Record中引入了许多新功能和错误修复。亮点包括嵌套属性、嵌套事务、动态和默认作用域以及批处理。

### 嵌套属性

Active Record现在可以直接更新嵌套模型上的属性，只要您告诉它这样做：

```ruby
class Book < ActiveRecord::Base
  has_one :author
  has_many :pages

  accepts_nested_attributes_for :author, :pages
end
```

打开嵌套属性会启用许多功能：自动（和原子）保存记录及其关联的子记录、子记录感知验证和支持嵌套表单（稍后讨论）。

您还可以使用`:reject_if`选项指定通过嵌套属性添加的任何新记录的要求：

```ruby
accepts_nested_attributes_for :author,
  :reject_if => proc { |attributes| attributes['name'].blank? }
```

* 主要贡献者：[Eloy Duran](http://superalloy.nl/)
* 更多信息：[嵌套模型表单](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)

### 嵌套事务

Active Record现在支持嵌套事务，这是一个备受请求的功能。现在，您可以编写如下代码：

```ruby
User.transaction do
  User.create(:username => 'Admin')
  User.transaction(:requires_new => true) do
    User.create(:username => 'Regular')
    raise ActiveRecord::Rollback
  end
end

User.find(:all)  # => 仅返回Admin
```

嵌套事务允许您回滚内部事务，而不影响外部事务的状态。如果要嵌套事务，必须显式添加`:requires_new`选项；否则，嵌套事务只是父事务的一部分（就像在Rails 2.2上目前的情况一样）。在底层，嵌套事务使用[保存点](http://rails.lighthouseapp.com/projects/8994/tickets/383)，因此它们甚至在没有真正嵌套事务的数据库上也受到支持。在测试期间，还有一些魔法使这些事务与事务性固定装置良好地配合。

* 主要贡献者：[Jonathan Viney](http://www.workingwithrails.com/person/4985-jonathan-viney)和[Hongli Lai](http://izumi.plan99.net/blog/)

### 动态作用域

您已经了解了Rails中的动态查找器（允许您即兴编写方法，例如`find_by_color_and_flavor`）和命名作用域（允许您将可重用的查询条件封装到友好的名称中，例如`currently_active`）。现在，您可以使用动态作用域方法。这个想法是组合语法，允许即兴过滤和方法链接。例如：

```ruby
Order.scoped_by_customer_id(12)
Order.scoped_by_customer_id(12).find(:all,
  :conditions => "status = 'open'")
Order.scoped_by_customer_id(12).scoped_by_status("open")
```

使用动态作用域不需要定义任何内容：它们只是起作用。

* 主要贡献者：[Yaroslav Markin](http://evilmartians.com/)
* 更多信息：[Edge Rails中的新功能：动态作用域方法](http://archives.ryandaigle.com/articles/2008/12/29/what-s-new-in-edge-rails-dynamic-scope-methods)

### 默认作用域

Rails 2.3将引入与命名作用域类似的_默认作用域_的概念，但适用于模型内的所有命名作用域或查找方法。例如，您可以编写`default_scope :order => 'name ASC'`，每次从该模型检索记录时，它们都会按名称排序（除非您覆盖该选项）。

* 主要贡献者：Paweł Kondzior
* 更多信息：[Edge Rails中的新功能：默认作用域](http://archives.ryandaigle.com/articles/2008/11/18/what-s-new-in-edge-rails-default-scoping)

### 批处理

现在，您可以使用`find_in_batches`从Active Record模型中处理大量记录，而对内存的压力较小：

```ruby
Customer.find_in_batches(:conditions => {:active => true}) do |customer_group|
  customer_group.each { |customer| customer.update_account_balance! }
end
```

您可以将大多数`find`选项传递给`find_in_batches`。但是，您无法指定记录返回的顺序（它们将始终按照主键的升序返回，主键必须是整数），也不能使用`:limit`选项。相反，使用`:batch_size`选项，默认为1000，设置每个批次返回的记录数。

新的`find_each`方法提供了`find_in_batches`的包装器，返回单个记录，查找本身是按批次进行的（默认为1000）：

```ruby
Customer.find_each do |customer|
  customer.update_account_balance!
end
```
请注意，您应该只在批处理中使用此方法：对于少量记录（少于1000条），您应该使用常规的查找方法和自己的循环。

* 更多信息（在此时方便的方法被称为`each`）：
    * [Rails 2.3：批量查找](http://afreshcup.com/2009/02/23/rails-23-batch-finding/)
    * [Edge Rails的新功能：批量查找](http://archives.ryandaigle.com/articles/2009/2/23/what-s-new-in-edge-rails-batched-find)

### 回调的多个条件

在使用Active Record回调时，您现在可以将`：if`和`：unless`选项组合在同一个回调中，并提供多个条件作为数组：

```ruby
before_save :update_credit_rating, :if => :active,
  :unless => [:admin, :cash_only]
```
* 主要贡献者：L. Caviola

### 带有having的查找

Rails现在在查找（以及`has_many`和`has_and_belongs_to_many`关联）上有一个`：having`选项，用于在分组查找中过滤记录。对于具有丰富SQL背景的人来说，这允许基于分组结果进行过滤：

```ruby
developers = Developer.find(:all, :group => "salary",
  :having => "sum(salary) > 10000", :select => "salary")
```

* 主要贡献者：[Emilio Tagua](https://github.com/miloops)

### 重新连接MySQL连接

MySQL支持在其连接中重新连接标志-如果设置为true，则客户端将在连接丢失的情况下尝试重新连接到服务器，而不是放弃。您现在可以在`database.yml`中为MySQL连接设置`reconnect = true`，以从Rails应用程序获得此行为。默认值为`false`，因此现有应用程序的行为不会改变。

* 主要贡献者：[Dov Murik](http://twitter.com/dubek)
* 更多信息：
    * [控制自动重新连接行为](http://dev.mysql.com/doc/refman/5.6/en/auto-reconnect.html)
    * [重新审视MySQL自动重新连接](http://groups.google.com/group/rubyonrails-core/browse_thread/thread/49d2a7e9c96cb9f4)

### 其他Active Record更改

* 从`has_and_belongs_to_many`预加载的生成SQL中删除了额外的`AS`，使其在某些数据库上工作得更好。
* `ActiveRecord::Base#new_record?`现在在面对现有记录时返回`false`而不是`nil`。
* 修复了某些`has_many :through`关联中引用表名的错误。
* 现在可以为`updated_at`时间戳指定特定的时间戳：`cust = Customer.create(:name => "ABC Industries", :updated_at => 1.day.ago)`
* 在`find_by_attribute!`调用失败时提供更好的错误消息。
* Active Record的`to_xml`支持通过添加`：camelize`选项变得更加灵活。
* 修复了取消`before_update`或`before_create`中回调的错误。
* 添加了通过JDBC测试数据库的Rake任务。
* `validates_length_of`将在使用`：in`或`：within`选项时使用自定义错误消息（如果提供了）。
* 选择的范围计数现在可以正常工作，因此您可以执行诸如`Account.scoped(:select => "DISTINCT credit_limit").count`之类的操作。
* `ActiveRecord::Base#invalid?`现在与`ActiveRecord::Base#valid?`相反。

Action Controller
-----------------

Action Controller在此版本中对渲染进行了一些重大更改，以及在路由和其他领域的改进。

### 统一渲染

`ActionController::Base#render`在决定要渲染的内容方面更加智能。现在，您只需告诉它要渲染什么，并期望得到正确的结果。在旧版本的Rails中，您经常需要提供显式信息来进行渲染：

```ruby
render :file => '/tmp/random_file.erb'
render :template => 'other_controller/action'
render :action => 'show'
```

现在在Rails 2.3中，您只需提供要渲染的内容：

```ruby
render '/tmp/random_file.erb'
render 'other_controller/action'
render 'show'
render :show
```

Rails根据要渲染的内容中是否有前导斜杠、嵌入斜杠或没有斜杠来选择文件、模板和操作。请注意，当渲染操作时，您还可以使用符号代替字符串。其他渲染样式（`：inline`、`：text`、`：update`、`：nothing`、`：json`、`：xml`、`：js`）仍需要显式选项。

### 应用控制器重命名

如果您是一直对`application.rb`的特殊命名感到困扰的人，请欢呼！在Rails 2.3中，它已经被重新命名为`application_controller.rb`。此外，还有一个新的rake任务`rake rails:update:application_controller`可以自动为您执行此操作-它将作为正常的`rake rails:update`过程的一部分运行。

* 更多信息：
    * [Application.rb的消亡](https://afreshcup.com/home/2008/11/17/rails-2x-the-death-of-applicationrb)
    * [Edge Rails的新功能：Application.rb的二元性不再存在](http://archives.ryandaigle.com/articles/2008/11/19/what-s-new-in-edge-rails-application-rb-duality-is-no-more)

### HTTP摘要身份验证支持

Rails现在内置了对HTTP摘要身份验证的支持。要使用它，您可以调用`authenticate_or_request_with_http_digest`，并提供一个返回用户密码的块（然后将其哈希化并与传输的凭据进行比较）：

```ruby
class PostsController < ApplicationController
  Users = {"dhh" => "secret"}
  before_filter :authenticate

  def secret
    render :text => "Password Required!"
  end

  private
  def authenticate
    realm = "Application"
    authenticate_or_request_with_http_digest(realm) do |name|
      Users[name]
    end
  end
end
```
* 主要贡献者：[Gregg Kellogg](http://www.kellogg-assoc.com/)
* 更多信息：[Edge Rails中的新功能：HTTP摘要认证](http://archives.ryandaigle.com/articles/2009/1/30/what-s-new-in-edge-rails-http-digest-authentication)

### 更高效的路由

Rails 2.3中有几个重要的路由变化。`formatted_`路由助手已经被移除，而是使用将`:format`作为选项传入。这样可以将任何资源的路由生成过程减少50%，并且可以节省大量内存（在大型应用程序上可达100MB）。如果您的代码使用了`formatted_`助手，它们目前仍然可以工作，但这种行为已被弃用，如果您使用新的标准重写这些路由，您的应用程序将更高效。另一个重大变化是Rails现在支持多个路由文件，不仅仅是`routes.rb`。您可以使用`RouteSet#add_configuration_file`随时引入更多路由，而无需清除当前加载的路由。虽然这个变化对于引擎最有用，但您可以在任何需要批量加载路由的应用程序中使用它。

* 主要贡献者：[Aaron Batalion](http://blog.hungrymachine.com/)

### 基于Rack的延迟加载会话

一个重大变化是将Action Controller会话存储的基础下沉到Rack级别。这涉及到了大量的代码工作，但对于您的Rails应用程序来说应该是完全透明的（作为额外的好处，一些关于旧的CGI会话处理程序的糟糕补丁被删除了）。然而，这仍然是一个重要的变化，因为非Rails Rack应用程序可以访问与您的Rails应用程序相同的会话存储处理程序（因此也可以访问相同的会话）。此外，会话现在是延迟加载的（与框架的其余部分的加载改进保持一致）。这意味着如果您不想要会话，您不再需要显式禁用它们；只需不引用它们，它们就不会加载。

### MIME类型处理变化

Rails中处理MIME类型的代码有几个变化。首先，`MIME::Type`现在实现了`=~`运算符，当您需要检查是否存在具有同义词的类型时，可以使代码更清晰：

```ruby
if content_type && Mime::JS =~ content_type
  # 做一些很酷的事情
end

Mime::JS =~ "text/javascript"        => true
Mime::JS =~ "application/javascript" => true
```

另一个变化是框架现在在各个位置检查JavaScript时使用`Mime::JS`，使其能够干净地处理这些替代项。

* 主要贡献者：[Seth Fitzsimmons](http://www.workingwithrails.com/person/5510-seth-fitzsimmons)

### `respond_to`的优化

在Rails 2.3中，通过Rails-Merb团队合并的一些成果，包括了对`respond_to`方法的一些优化。`respond_to`方法在许多Rails应用程序中被广泛使用，允许您的控制器根据传入请求的MIME类型以不同的格式呈现结果。通过消除对`method_missing`的调用以及一些性能分析和调整，我们看到在一个简单的`respond_to`中切换三种格式的情况下，每秒服务的请求数提高了8%。最好的部分是，您的应用程序的代码不需要任何更改就可以利用这个加速。

### 改进的缓存性能

Rails现在在每个请求中保留了一个本地缓存，从远程缓存存储中读取，减少了不必要的读取，提高了网站性能。虽然最初这项工作仅限于`MemCacheStore`，但它适用于任何实现了所需方法的远程存储。

* 主要贡献者：[Nahum Wild](http://www.motionstandingstill.com/)

### 本地化视图

现在Rails可以根据您设置的区域设置提供本地化视图。例如，假设您有一个`Posts`控制器，其中有一个`show`动作。默认情况下，它将渲染`app/views/posts/show.html.erb`。但是如果您设置了`I18n.locale = :da`，它将渲染`app/views/posts/show.da.html.erb`。如果本地化模板不存在，将使用未装饰的版本。Rails还包括`I18n#available_locales`和`I18n::SimpleBackend#available_locales`，它们返回当前Rails项目中可用的翻译数组。

此外，您可以使用相同的方案本地化公共目录中的救援文件：例如`public/500.da.html`或`public/404.en.html`。

### 部分范围的翻译

翻译API的变化使得在局部视图中编写关键翻译更加简单和不重复。如果您从`people/index.html.erb`模板中调用`translate(".foo")`，实际上将调用`I18n.translate("people.index.foo")`。如果您不在键前面加上句点，则API不会进行范围限定，与以前一样。
### 其他Action Controller的变化

* ETag处理已经进行了一些清理：当响应没有正文或者发送文件时，Rails将跳过发送ETag头。
* Rails检查IP欺骗的事实对于与手机进行大量流量的网站可能是一个麻烦，因为它们的代理通常没有正确设置。如果你是这种情况，你现在可以设置`ActionController::Base.ip_spoofing_check = false`来完全禁用检查。
* `ActionController::Dispatcher`现在实现了自己的中间件堆栈，可以通过运行`rake middleware`来查看。
* Cookie会话现在具有持久的会话标识符，并与服务器端存储的API兼容。
* 现在可以在`send_file`和`send_data`的`:type`选项中使用符号，例如：`send_file("fabulous.png", :type => :png)`。
* `map.resources`的`:only`和`:except`选项不再被嵌套资源继承。
* 捆绑的memcached客户端已更新到1.6.4.99版本。
* `expires_in`、`stale?`和`fresh_when`方法现在接受一个`:public`选项，以便与代理缓存良好配合使用。
* `:requirements`选项现在可以与其他RESTful成员路由正常工作。
* 浅层路由现在正确地尊重命名空间。
* `polymorphic_url`更好地处理具有不规则复数名称的对象。

Action View
-----------

Rails 2.3中的Action View引入了嵌套模型表单、对`render`的改进、对日期选择助手的灵活提示以及资产缓存的加速等功能。

### 嵌套对象表单

只要父模型接受子对象的嵌套属性（如Active Record部分所讨论的），您可以使用`form_for`和`field_for`创建嵌套表单。这些表单可以任意嵌套，允许您在单个视图上编辑复杂的对象层次结构而不需要过多的代码。例如，给定以下模型：

```ruby
class Customer < ActiveRecord::Base
  has_many :orders

  accepts_nested_attributes_for :orders, :allow_destroy => true
end
```

您可以在Rails 2.3中编写以下视图：

```html+erb
<% form_for @customer do |customer_form| %>
  <div>
    <%= customer_form.label :name, 'Customer Name:' %>
    <%= customer_form.text_field :name %>
  </div>

  <!-- 在customer_form构建器实例上调用fields_for。
   对于orders集合的每个成员，都会调用该块。 -->
  <% customer_form.fields_for :orders do |order_form| %>
    <p>
      <div>
        <%= order_form.label :number, 'Order Number:' %>
        <%= order_form.text_field :number %>
      </div>

  <!-- 模型中的allow_destroy选项启用了子记录的删除。 -->
      <% unless order_form.object.new_record? %>
        <div>
          <%= order_form.label :_delete, 'Remove:' %>
          <%= order_form.check_box :_delete %>
        </div>
      <% end %>
    </p>
  <% end %>

  <%= customer_form.submit %>
<% end %>
```

* 主要贡献者：[Eloy Duran](http://superalloy.nl/)
* 更多信息：
    * [嵌套模型表单](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)
    * [complex-form-examples](https://github.com/alloy/complex-form-examples)
    * [Edge Rails中的新功能：嵌套对象表单](http://archives.ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes)

### 智能渲染局部视图

`render`方法多年来一直在变得更加智能，现在它变得更加智能了。如果您有一个对象或集合以及一个合适的局部视图，并且命名匹配，您现在可以直接渲染对象，事情就会起作用。例如，在Rails 2.3中，这些渲染调用将在视图中起作用（假设命名合理）：

```ruby
# 等同于 render :partial => 'articles/_article',
# :object => @article
render @article

# 等同于 render :partial => 'articles/_article',
# :collection => @articles
render @articles
```

* 更多信息：[Edge Rails中的新功能：render不再需要高维护性](http://archives.ryandaigle.com/articles/2008/11/20/what-s-new-in-edge-rails-render-stops-being-high-maintenance)

### 日期选择助手的提示

在Rails 2.3中，您可以为各种日期选择助手（`date_select`、`time_select`和`datetime_select`）提供自定义提示，就像使用集合选择助手一样。您可以提供一个提示字符串或一个包含各个组件的提示字符串的哈希。您也可以将`:prompt`设置为`true`以使用自定义通用提示：

```ruby
select_datetime(DateTime.now, :prompt => true)

select_datetime(DateTime.now, :prompt => "Choose date and time")

select_datetime(DateTime.now, :prompt =>
  {:day => 'Choose day', :month => 'Choose month',
   :year => 'Choose year', :hour => 'Choose hour',
   :minute => 'Choose minute'})
```

* 主要贡献者：[Sam Oliver](http://samoliver.com/)

### 资产标签时间戳缓存

您可能熟悉Rails将时间戳添加到静态资产路径作为“缓存破坏器”的做法。这有助于确保在服务器上更改这些静态资产（如图像和样式表）时，不会从用户的浏览器缓存中提供过时的副本。现在，您可以使用Action View的`cache_asset_timestamps`配置选项修改此行为。如果启用缓存，则Rails将在首次提供资产时计算时间戳，并保存该值。这意味着更少的（昂贵的）文件系统调用来提供静态资产，但这也意味着您不能在服务器运行时修改任何资产，并期望客户端能够接收到更改。


### 将资产主机作为对象

在边缘Rails中，资产主机更加灵活，可以将资产主机声明为一个特定的对象，该对象响应调用。这使您能够在资产主机中实现任何复杂的逻辑。

* 更多信息：[asset-hosting-with-minimum-ssl](https://github.com/dhh/asset-hosting-with-minimum-ssl/tree/master)

### grouped_options_for_select助手方法

Action View已经有了一堆助手来帮助生成选择控件，但现在又多了一个：`grouped_options_for_select`。它接受一个字符串数组或哈希，并将它们转换为用`optgroup`标签包装的`option`标签字符串。例如：

```ruby
grouped_options_for_select([["Hats", ["Baseball Cap","Cowboy Hat"]]],
  "Cowboy Hat", "Choose a product...")
```

返回

```html
<option value="">Choose a product...</option>
<optgroup label="Hats">
  <option value="Baseball Cap">Baseball Cap</option>
  <option selected="selected" value="Cowboy Hat">Cowboy Hat</option>
</optgroup>
```

### 表单选择助手的禁用选项标签

表单选择助手（如`select`和`options_for_select`）现在支持`：disabled`选项，该选项可以接受一个值或一个要在生成的标签中禁用的值数组：

```ruby
select(:post, :category, Post::CATEGORIES, :disabled => 'private')
```

返回

```html
<select name="post[category]">
<option>story</option>
<option>joke</option>
<option>poem</option>
<option disabled="disabled">private</option>
</select>
```

您还可以使用匿名函数在运行时确定哪些选项来自集合将被选中和/或禁用：

```ruby
options_from_collection_for_select(@product.sizes, :name, :id, :disabled => lambda{|size| size.out_of_stock?})
```

* 主要贡献者：[Tekin Suleyman](http://tekin.co.uk/)
* 更多信息：[New in rails 2.3 - disabled option tags and lambdas for selecting and disabling options from collections](https://tekin.co.uk/2009/03/new-in-rails-23-disabled-option-tags-and-lambdas-for-selecting-and-disabling-options-from-collections)

### 关于模板加载的说明

Rails 2.3包括在任何特定环境中启用或禁用缓存模板的功能。缓存模板可以提高速度，因为在渲染时它们不会检查新的模板文件，但这也意味着您无法在不重新启动服务器的情况下“即时”替换模板。

在大多数情况下，您希望在生产中打开模板缓存，您可以在`production.rb`文件中进行设置：

```ruby
config.action_view.cache_template_loading = true
```

这行代码将在新的Rails 2.3应用程序中默认为您生成。如果您从较旧版本的Rails升级，Rails将默认在生产和测试中缓存模板，但在开发中不缓存。

### 其他Action View更改

* CSRF保护的令牌生成已经简化；现在Rails使用由`ActiveSupport::SecureRandom`生成的简单随机字符串，而不是处理会话ID。
* `auto_link`现在正确地将选项（如`：target`和`：class`）应用于生成的电子邮件链接。
* `autolink`助手已经重构，使其更加简洁和直观。
* 即使URL中有多个查询参数，`current_page?`现在也可以正常工作。

Active Support
--------------

Active Support有一些有趣的更改，包括引入`Object#try`。

### Object#try

很多人已经采用了使用try()在对象上尝试操作的概念。在视图中特别有帮助，您可以通过编写代码如`<%= @person.try(:name) %>`来避免nil检查。现在，它已经完全集成到Rails中。在Rails中实现时，它会在私有方法上引发`NoMethodError`，如果对象为nil，则始终返回nil。

* 更多信息：[try()](http://ozmm.org/posts/try.html)

### Object#tap回溯

`Object#tap`是[Ruby 1.9](http://www.ruby-doc.org/core-1.9/classes/Object.html#M000309)和1.8.7的一个补充，类似于Rails已经有一段时间的`returning`方法：它会传递给一个块，然后返回传递的对象。现在，Rails还包括了在旧版本的Ruby中提供此功能的代码。

### XMLmini的可交换解析器

通过允许您交换不同的解析器，Active Support对XML解析的支持更加灵活。默认情况下，它使用标准的REXML实现，但您可以轻松地为自己的应用程序指定更快的LibXML或Nokogiri实现，前提是您安装了相应的gem：

```ruby
XmlMini.backend = 'LibXML'
```

* 主要贡献者：[Bart ten Brinke](http://www.movesonrails.com/)
* 主要贡献者：[Aaron Patterson](http://tenderlovemaking.com/)

### TimeWithZone的分数秒

`Time`和`TimeWithZone`类包括一个`xmlschema`方法，以返回一个XML友好的字符串表示时间。从Rails 2.3开始，`TimeWithZone`支持与`Time`相同的参数，用于指定返回字符串的小数秒部分的位数：

```ruby
Time.zone.now.xmlschema(6) # => "2009-01-16T13:00:06.13653Z"
```
* 主要贡献者：[Nicholas Dainty](http://www.workingwithrails.com/person/13536-nicholas-dainty)

### JSON键名引用

如果您在“json.org”网站上查看规范，您会发现JSON结构中的所有键名都必须是字符串，并且必须用双引号引用。从Rails 2.3开始，我们在这里做了正确的事情，即使是数字键名也是如此。

### 其他Active Support的更改

* 您可以使用`Enumerable#none?`来检查没有任何元素与提供的块匹配。
* 如果您正在使用Active Support的[委托](https://afreshcup.com/home/2008/10/19/coming-in-rails-22-delegate-prefixes)，新的`:allow_nil`选项允许您在目标对象为nil时返回`nil`而不是引发异常。
* `ActiveSupport::OrderedHash`：现在实现了`each_key`和`each_value`。
* `ActiveSupport::MessageEncryptor`提供了一种简单的方法来加密信息，以便存储在不受信任的位置（如cookies）中。
* Active Support的`from_xml`不再依赖于XmlSimple。相反，Rails现在包含了自己的XmlMini实现，只包含所需的功能。这使得Rails可以摆脱一直携带的XmlSimple的捆绑副本。
* 如果您记忆了一个私有方法，结果现在将是私有的。
* `String#parameterize`接受一个可选的分隔符：`"Quick Brown Fox".parameterize('_') => "quick_brown_fox"`。
* `number_to_phone`现在接受7位数的电话号码。
* `ActiveSupport::Json.decode`现在处理`\u0000`样式的转义序列。

Railties
--------

除了上面提到的Rack更改之外，Railties（Rails本身的核心代码）还有许多重大更改，包括Rails Metal、应用程序模板和安静的回溯。

### Rails Metal

Rails Metal是一种在Rails应用程序内部提供超快速端点的新机制。Metal类绕过路由和Action Controller，为您提供原始速度（当然会牺牲Action Controller中的所有内容）。这是在最近的基础工作的基础上构建的，使Rails成为一个具有暴露中间件堆栈的Rack应用程序。Metal端点可以从您的应用程序或插件中加载。

* 更多信息：
    * [介绍Rails Metal](https://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal)
    * [Rails Metal：具有Rails功能的微框架](http://soylentfoo.jnewland.com/articles/2008/12/16/rails-metal-a-micro-framework-with-the-power-of-rails-m)
    * [Metal：在Rails应用程序中超快速的端点](http://www.railsinside.com/deployment/180-metal-super-fast-endpoints-within-your-rails-apps.html)
    * [Edge Rails中的新功能：Rails Metal](http://archives.ryandaigle.com/articles/2008/12/18/what-s-new-in-edge-rails-rails-metal)

### 应用程序模板

Rails 2.3集成了Jeremy McAnally的[rg](https://github.com/jm/rg)应用程序生成器。这意味着我们现在在Rails中内置了基于模板的应用程序生成；如果您在每个应用程序中都包含一组插件（以及许多其他用例），您只需设置一次模板，然后在运行`rails`命令时可以一次又一次地使用它。还有一个rake任务可以将模板应用于现有应用程序：

```bash
$ rake rails:template LOCATION=~/template.rb
```

这将在现有项目的代码之上叠加模板的更改。

* 主要贡献者：[Jeremy McAnally](http://www.jeremymcanally.com/)
* 更多信息：[Rails模板](http://m.onkey.org/2008/12/4/rails-templates)

### 更安静的回溯

在thoughtbot的[Quiet Backtrace](https://github.com/thoughtbot/quietbacktrace)插件的基础上，它允许您有选择地从`Test::Unit`回溯中删除行，Rails 2.3在核心中实现了`ActiveSupport::BacktraceCleaner`和`Rails::BacktraceCleaner`。这支持过滤器（对回溯行执行基于正则表达式的替换）和静音器（完全删除回溯行）。Rails会自动添加静音器以消除新应用程序中的最常见噪音，并构建一个`config/backtrace_silencers.rb`文件来保存您自己的添加。此功能还可以从回溯中的任何gem中实现更漂亮的打印。

### 在开发模式下使用延迟加载/自动加载加快启动时间

为了确保只在实际需要时将Rails（及其依赖项）的部分加载到内存中，进行了大量的工作。核心框架 - Active Support、Active Record、Action Controller、Action Mailer和Action View - 现在使用`autoload`来延迟加载它们的各个类。这项工作应该有助于减少内存占用并提高整体的Rails性能。

您还可以通过使用新的`preload_frameworks`选项来指定核心库是否应在启动时自动加载。默认情况下，这个选项是`false`，所以Rails会逐个部分地自动加载自己，但在某些情况下，您仍然需要一次性加载所有内容 - Passenger和JRuby都希望看到所有的Rails一起加载。

### 重写rake gem任务

各种<code>rake gem</code>任务的内部结构已经得到了大幅修订，以使系统在各种情况下更好地工作。gem系统现在知道开发和运行时依赖关系之间的区别，具有更强大的解压系统，在查询gem状态时提供更好的信息，并且在从头开始引入事物时不太容易出现“鸡生蛋”依赖问题。还修复了在JRuby下使用gem命令和尝试引入已经供应的gem的外部副本的依赖项的问题。
* 主要贡献者：[David Dollar](http://www.workingwithrails.com/person/12240-david-dollar)

### 其他Railties更改

* 更新和扩展了将CI服务器更新为构建Rails的说明。
* 内部Rails测试已从`Test::Unit::TestCase`切换到`ActiveSupport::TestCase`，Rails核心需要使用Mocha进行测试。
* 默认的`environment.rb`文件已经简化。
* dbconsole脚本现在可以使用全数字密码而不会崩溃。
* `Rails.root`现在返回一个`Pathname`对象，这意味着您可以直接使用`join`方法来[清理现有代码](https://afreshcup.wordpress.com/2008/12/05/a-little-rails_root-tidiness/)，该代码使用`File.join`。
* 默认情况下，不再在每个Rails应用程序中生成处理CGI和FCGI调度的/public目录中的各种文件（如果需要，仍然可以通过在运行`rails`命令时添加`--with-dispatchers`或稍后使用`rake rails:update:generate_dispatchers`来获取它们）。
* Rails指南已从AsciiDoc转换为Textile标记。
* 清理了脚手架视图和控制器。
* `script/server`现在接受`--path`参数，以从特定路径挂载Rails应用程序。
* 如果缺少任何配置的gem，gem rake任务将跳过加载大部分环境。这应该解决许多“鸡生蛋”问题，其中rake gems:install无法运行，因为缺少gem。
* 现在只解压缩一次gem。这修复了使用只读权限打包的gem（例如hoe）的问题。

已弃用
----------

此版本中有一些旧代码已弃用：

* 如果您是（相当罕见的）依赖于inspector、reaper和spawner脚本的Rails开发人员之一，您需要知道这些脚本不再包含在核心Rails中。如果您需要它们，您可以通过[irs_process_scripts](https://github.com/rails/irs_process_scripts)插件获取副本。
* `render_component`在Rails 2.3中从“已弃用”变为“不存在”。如果您仍然需要它，可以安装[render_component插件](https://github.com/rails/render_component/tree/master)。
* 已删除对Rails组件的支持。
* 如果您是那些习惯于运行`script/performance/request`以基于集成测试查看性能的人之一，您需要学习一个新技巧：该脚本现在已从核心Rails中删除。有一个新的request_profiler插件，您可以安装它以获得完全相同的功能。
* `ActionController::Base#session_enabled?`已弃用，因为现在会延迟加载会话。
* `protect_from_forgery`的`：digest`和`：secret`选项已弃用且无效。
* 已删除一些集成测试助手。`response.headers["Status"]`和`headers["Status"]`将不再返回任何内容。Rack不允许在返回头中使用“Status”。但是，您仍然可以使用`status`和`status_message`助手。`response.headers["cookie"]`和`headers["cookie"]`将不再返回任何CGI cookie。您可以检查`headers["Set-Cookie"]`以查看原始cookie头，或使用`cookies`助手获取发送到客户端的cookie的哈希。
* `formatted_polymorphic_url`已弃用。请改用带有`:format`的`polymorphic_url`。
* `ActionController::Response#set_cookie`中的`:http_only`选项已重命名为`:httponly`。
* `to_sentence`的`:connector`和`:skip_last_comma`选项已被`:words_connector`、`:two_words_connector`和`:last_word_connector`选项替换。
* 使用空的`file_field`控件提交多部分表单以前会将空字符串提交给控制器。现在由于Rack的多部分解析器与旧的Rails解析器之间的差异，它会提交一个nil。

致谢
-------

发布说明由[Mike Gunderloy](http://afreshcup.com)编写。这个版本的Rails 2.3发布说明是基于Rails 2.3的RC2编译的。
