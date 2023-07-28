**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bef23603f5d822054701f5cbf2578d95
Rails缓存：概述
================

本指南是关于如何使用缓存来加速Rails应用程序的介绍。

缓存是指在请求-响应周期中生成的内容，并在响应类似请求时重复使用。

缓存通常是提升应用程序性能最有效的方法。通过缓存，运行在单个服务器上且使用单个数据库的网站可以承受数千个并发用户的负载。

Rails提供了一套开箱即用的缓存功能。本指南将教会您每个功能的范围和目的。掌握这些技术，您的Rails应用程序可以在没有过高响应时间或服务器费用的情况下提供数百万次的视图。

阅读完本指南后，您将了解：

* 片段缓存和俄罗斯套娃缓存。
* 如何管理缓存依赖关系。
* 替代缓存存储。
* 支持条件GET。

--------------------------------------------------------------------------------

基本缓存
-------------

这是对三种缓存技术的介绍：页面缓存、操作缓存和片段缓存。默认情况下，Rails提供片段缓存。要使用页面缓存和操作缓存，您需要在`Gemfile`中添加`actionpack-page_caching`和`actionpack-action_caching`。

默认情况下，缓存仅在生产环境中启用。您可以通过运行`rails dev:cache`或在`config/environments/development.rb`中将[`config.action_controller.perform_caching`][]设置为`true`来在本地测试缓存。

注意：更改`config.action_controller.perform_caching`的值只会影响Action Controller提供的缓存。例如，它不会影响我们在下面介绍的低级缓存。

### 页面缓存

页面缓存是Rails的一种机制，允许由Web服务器（如Apache或NGINX）直接提供生成的页面的请求，而无需经过整个Rails堆栈。虽然这非常快速，但不能应用于每种情况（例如需要身份验证的页面）。此外，由于Web服务器直接从文件系统中提供文件，您需要实现缓存过期。

信息：页面缓存已从Rails 4中删除。请参阅[actionpack-page_caching gem](https://github.com/rails/actionpack-page_caching)。

### 操作缓存

页面缓存无法用于具有前置过滤器的操作，例如需要身份验证的页面。这就是操作缓存的用途。操作缓存的工作方式与页面缓存类似，只是传入的Web请求会命中Rails堆栈，以便在提供缓存之前可以对其运行前置过滤器。这允许在仍然提供缓存副本的输出结果时运行身份验证和其他限制。

信息：操作缓存已从Rails 4中删除。请参阅[actionpack-action_caching gem](https://github.com/rails/actionpack-action_caching)。请参阅[DHH的基于键的缓存过期概述](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)以了解新的首选方法。

### 片段缓存

动态Web应用程序通常使用多种组件构建页面，其中不是所有组件都具有相同的缓存特性。当页面的不同部分需要单独缓存和过期时，可以使用片段缓存。

片段缓存允许将视图逻辑的片段包装在缓存块中，并在下一个请求到达时从缓存存储中提供。

例如，如果您想要在页面上缓存每个产品，可以使用以下代码：

```html+erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

当您的应用程序首次接收到对此页面的请求时，Rails将使用唯一键写入新的缓存条目。键的样子如下：

```
views/products/index:bea67108094918eeba42cd4a6e786901/products/1
```

中间的字符串是模板树摘要。它是根据您正在缓存的视图片段的内容计算出的哈希摘要。如果更改视图片段（例如，HTML更改），摘要将更改，从而使现有文件过期。

缓存条目中存储了一个基于产品记录的缓存版本。当产品被触碰时，缓存版本会更改，并且会忽略包含先前版本的任何缓存片段。

提示：像Memcached这样的缓存存储将自动删除旧的缓存文件。

如果您想在特定条件下缓存片段，可以使用`cache_if`或`cache_unless`：

```erb
<% cache_if admin?, product do %>
  <%= render product %>
<% end %>
```

#### 集合缓存

`render`助手还可以缓存为集合渲染的单个模板。它甚至可以通过在渲染集合时传递`cached: true`来一次性读取所有缓存模板，而不是逐个读取。
```html+erb
<%= render partial: 'products/product', collection: @products, cached: true %>
```

所有之前渲染的缓存模板将一次性获取，速度更快。此外，尚未缓存的模板将被写入缓存，并在下一次渲染时进行多次获取。

### 俄罗斯套娃缓存

您可能希望将缓存片段嵌套在其他缓存片段中。这被称为俄罗斯套娃缓存。

俄罗斯套娃缓存的优点是，如果单个产品被更新，重新生成外部片段时可以重用所有其他内部片段。

如前一节所述，如果缓存文件直接依赖的记录的`updated_at`值发生更改，缓存文件将过期。但是，这不会使嵌套在其中的任何缓存片段过期。

例如，考虑以下视图：

```erb
<% cache product do %>
  <%= render product.games %>
<% end %>
```

然后渲染此视图：

```erb
<% cache game do %>
  <%= render game %>
<% end %>
```

如果更改了game的任何属性，则`updated_at`值将设置为当前时间，从而使缓存过期。但是，由于product对象的`updated_at`不会更改，因此该缓存不会过期，您的应用程序将提供过时的数据。为了解决这个问题，我们使用`touch`方法将模型绑定在一起：

```ruby
class Product < ApplicationRecord
  has_many :games
end

class Game < ApplicationRecord
  belongs_to :product, touch: true
end
```

将`touch`设置为`true`，任何更改game记录的`updated_at`的操作也会更改关联的product的`updated_at`，从而使缓存过期。

### 共享局部缓存

可以在具有不同MIME类型的文件之间共享局部和相关的缓存。例如，共享局部缓存允许模板编写者在HTML和JavaScript文件之间共享一个局部。当模板在模板解析器文件路径中收集时，它们只包括模板语言扩展名，而不包括MIME类型。因此，模板可以用于多个MIME类型。HTML和JavaScript请求都将响应以下代码：

```ruby
render(partial: 'hotels/hotel', collection: @hotels, cached: true)
```

将加载名为`hotels/hotel.erb`的文件。

另一种选择是包含要渲染的局部的完整文件名。

```ruby
render(partial: 'hotels/hotel.html.erb', collection: @hotels, cached: true)
```

将在任何文件MIME类型中加载名为`hotels/hotel.html.erb`的文件，例如您可以在JavaScript文件中包含此局部。

### 管理依赖关系

为了正确地使缓存失效，您需要正确定义缓存依赖关系。Rails足够聪明，可以处理常见情况，因此您不必指定任何内容。但是，有时，当您处理自定义帮助程序时，您需要显式定义它们。

#### 隐式依赖关系

大多数模板依赖关系可以从模板本身中的`render`调用中推导出来。以下是`ActionView::Digestor`知道如何解码的一些`render`调用的示例：

```ruby
render partial: "comments/comment", collection: commentable.comments
render "comments/comments"
render 'comments/comments'
render('comments/comments')

render "header" 转换为 render("comments/header")

render(@topic)         转换为 render("topics/topic")
render(topics)         转换为 render("topics/topic")
render(message.topics) 转换为 render("topics/topic")
```

另一方面，有些调用需要更改以使缓存正常工作。例如，如果您传递了自定义集合，您需要更改：

```ruby
render @project.documents.where(published: true)
```

为：

```ruby
render partial: "documents/document", collection: @project.documents.where(published: true)
```

#### 显式依赖关系

有时您会有无法推导出的模板依赖关系。当渲染发生在帮助程序中时，通常就是这种情况。以下是一个示例：

```html+erb
<%= render_sortable_todolists @project.todolists %>
```

您需要使用特殊的注释格式来调用它们：

```html+erb
<%# Template Dependency: todolists/todolist %>
<%= render_sortable_todolists @project.todolists %>
```

在某些情况下，例如单表继承设置，您可能有一堆显式依赖关系。您可以使用通配符来匹配目录中的任何模板，而不是将每个模板都写出来：

```html+erb
<%# Template Dependency: events/* %>
<%= render_categorizable_events @person.events %>
```

对于集合缓存，如果局部模板不以干净的缓存调用开头，您仍然可以通过在模板中的任何位置添加特殊的注释格式来受益于集合缓存，例如：

```html+erb
<%# Template Collection: notification %>
<% my_helper_that_calls_cache(some_arg, notification) do %>
  <%= notification.name %>
<% end %>
```
#### 外部依赖

如果您在缓存块内使用一个辅助方法，然后更新该辅助方法，您还必须同时更新缓存。如何更新并不重要，但模板文件的MD5必须更改。一个建议是在注释中明确说明，比如：

```html+erb
<%# Helper Dependency Updated: Jul 28, 2015 at 7pm %>
<%= some_helper_method(person) %>
```

### 低级缓存

有时候您需要缓存特定的值或查询结果，而不是缓存视图片段。Rails的缓存机制非常适合存储任何可序列化的信息。

实现低级缓存的最有效方法是使用`Rails.cache.fetch`方法。该方法既可以读取也可以写入缓存。当只传递一个参数时，会获取键并返回缓存中的值。如果传递了一个块，那么在缓存未命中时将执行该块。块的返回值将被写入缓存，并返回该返回值。如果缓存命中，则返回缓存的值而不执行块。

考虑以下示例。一个应用程序有一个`Product`模型，该模型具有一个实例方法，该方法在竞争网站上查找产品的价格。该方法返回的数据非常适合低级缓存：

```ruby
class Product < ApplicationRecord
  def competing_price
    Rails.cache.fetch("#{cache_key_with_version}/competing_price", expires_in: 12.hours) do
      Competitor::API.find_price(id)
    end
  end
end
```

注意：请注意，在此示例中，我们使用了`cache_key_with_version`方法，因此生成的缓存键将类似于`products/233-20140225082222765838000/competing_price`。`cache_key_with_version`基于模型的类名、`id`和`updated_at`属性生成一个字符串。这是一种常见的约定，并且具有在产品更新时使缓存失效的好处。通常情况下，当您使用低级缓存时，需要生成一个缓存键。

#### 避免缓存Active Record对象的实例

考虑以下示例，它将表示超级用户的Active Record对象列表存储在缓存中：

```ruby
# super_admins是一个昂贵的SQL查询，所以不要经常运行它
Rails.cache.fetch("super_admin_users", expires_in: 12.hours) do
  User.super_admins.to_a
end
```

您应该__避免__这种模式。为什么呢？因为实例可能会发生变化。在生产环境中，它的属性可能不同，或者记录可能已被删除。在开发环境中，它与在更改时重新加载代码的缓存存储一起工作不可靠。

相反，缓存ID或其他原始数据类型。例如：

```ruby
# super_admins是一个昂贵的SQL查询，所以不要经常运行它
ids = Rails.cache.fetch("super_admin_user_ids", expires_in: 12.hours) do
  User.super_admins.pluck(:id)
end
User.where(id: ids).to_a
```

### SQL缓存

查询缓存是Rails的一个功能，它缓存每个查询返回的结果集。如果对于同一个请求，Rails再次遇到相同的查询，它将使用缓存的结果集而不是再次对数据库运行查询。

例如：

```ruby
class ProductsController < ApplicationController
  def index
    # 运行一个查询
    @products = Product.all

    # ...

    # 再次运行相同的查询
    @products = Product.all
  end
end
```

第二次对数据库运行相同的查询时，实际上不会再次访问数据库。第一次查询返回的结果将存储在查询缓存中（内存中），第二次查询将从内存中获取。

然而，需要注意的是查询缓存在动作开始时创建，在动作结束时销毁，因此仅在动作的持续时间内存在。如果您希望以更持久的方式存储查询结果，可以使用低级缓存。

缓存存储
------------

Rails提供了不同的存储方式来存储缓存数据（除了SQL和页面缓存）。

### 配置

您可以通过设置`config.cache_store`配置选项来设置应用程序的默认缓存存储。其他参数可以作为缓存存储的构造函数的参数传递：

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

或者，您可以在配置块之外设置`ActionController::Base.cache_store`。

您可以通过调用`Rails.cache`来访问缓存。

#### 连接池选项

默认情况下，[`:mem_cache_store`](#activesupport-cache-memcachestore)和
[`:redis_cache_store`](#activesupport-cache-rediscachestore)配置为使用连接池。这意味着如果您使用Puma或其他多线程服务器，可以同时有多个线程对缓存存储执行查询。
如果要禁用连接池，请在配置缓存存储时将`:pool`选项设置为`false`：

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

您还可以通过向`:pool`选项提供单独的选项来覆盖默认的连接池设置：

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: { size: 32, timeout: 1 }
```

* `:size` - 此选项设置每个进程的连接数（默认为5）。

* `:timeout` - 此选项设置等待连接的秒数（默认为5）。如果在超时时间内没有可用的连接，将引发`Timeout::Error`。

### `ActiveSupport::Cache::Store`

[`ActiveSupport::Cache::Store`][] 提供了在Rails中与缓存交互的基础。这是一个抽象类，不能单独使用。相反，您必须使用与存储引擎绑定的具体实现类。Rails附带了几个实现，下面有文档记录。

主要的API方法是[`read`][ActiveSupport::Cache::Store#read]、[`write`][ActiveSupport::Cache::Store#write]、[`delete`][ActiveSupport::Cache::Store#delete]、[`exist?`][ActiveSupport::Cache::Store#exist?]和[`fetch`][ActiveSupport::Cache::Store#fetch]。

传递给缓存存储构造函数的选项将被视为适用于相应API方法的默认选项。

### `ActiveSupport::Cache::MemoryStore`

[`ActiveSupport::Cache::MemoryStore`][] 将条目保存在内存中的同一个Ruby进程中。缓存存储通过将`：size`选项发送到初始化器来指定有界大小（默认为32Mb）。当缓存超过分配的大小时，将进行清理并删除最近最少使用的条目。

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

如果您运行多个Ruby on Rails服务器进程（如果使用Phusion Passenger或puma集群模式），那么您的Rails服务器进程实例将无法共享缓存数据。这种缓存存储不适用于大型应用部署。但是，对于只有几个服务器进程的小型低流量站点以及开发和测试环境，它可以很好地工作。

新的Rails项目默认在开发环境中使用此实现。

注意：由于使用`:memory_store`时进程不会共享缓存数据，因此无法通过Rails控制台手动读取、写入或过期缓存。

### `ActiveSupport::Cache::FileStore`

[`ActiveSupport::Cache::FileStore`][] 使用文件系统存储条目。在初始化缓存时，必须指定存储文件将存储的目录路径。

```ruby
config.cache_store = :file_store, "/path/to/cache/directory"
```

使用此缓存存储，同一主机上的多个服务器进程可以共享缓存。这种缓存存储适用于在一个或两个主机上提供低到中等流量的站点。在不推荐的情况下，运行在不同主机上的服务器进程可以通过使用共享文件系统来共享缓存。

由于缓存会增长直到磁盘满，建议定期清除旧条目。

如果没有显式提供`config.cache_store`，则这是默认的缓存存储实现（位于`"#{root}/tmp/cache/"`）。

### `ActiveSupport::Cache::MemCacheStore`

[`ActiveSupport::Cache::MemCacheStore`][] 使用Danga的`memcached`服务器为应用程序提供集中式缓存。Rails默认使用捆绑的`dalli` gem。这是目前用于生产网站的最流行的缓存存储。它可以用于提供具有非常高性能和冗余的单个共享缓存集群。

在初始化缓存时，应指定集群中所有memcached服务器的地址，或确保已正确设置`MEMCACHE_SERVERS`环境变量。

```ruby
config.cache_store = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
```

如果都没有指定，它将假设memcached在默认端口上的本地主机上运行（`127.0.0.1:11211`），但这对于较大的站点来说不是理想的设置。

```ruby
config.cache_store = :mem_cache_store # 将回退到$MEMCACHE_SERVERS，然后是127.0.0.1:11211
```

有关支持的地址类型，请参阅[`Dalli::Client`文档](https://www.rubydoc.info/gems/dalli/Dalli/Client#initialize-instance_method)。

此缓存上的[`write`][ActiveSupport::Cache::MemCacheStore#write]（和`fetch`）方法接受利用特定于memcached的功能的其他选项。

### `ActiveSupport::Cache::RedisCacheStore`

[`ActiveSupport::Cache::RedisCacheStore`][] 利用Redis在达到最大内存时自动驱逐的支持，使其表现得像一个Memcached缓存服务器。

部署注意事项：Redis默认不会过期键，因此请注意使用专用的Redis缓存服务器。不要用易失性缓存数据填满持久性Redis服务器！请详细阅读[Redis缓存服务器设置指南](https://redis.io/topics/lru-cache)。

对于仅用于缓存的Redis服务器，请将`maxmemory-policy`设置为allkeys的变体之一。Redis 4+支持最不常用的驱逐（`allkeys-lfu`），这是一个很好的默认选择。Redis 3及更早版本应使用最近最少使用的驱逐（`allkeys-lru`）。
将缓存读取和写入超时设置得相对较低。重新生成缓存值通常比等待超过一秒来检索它要快。读取和写入超时默认为1秒，但如果您的网络延迟始终较低，可以将其设置得更低。

默认情况下，如果连接在请求期间失败，缓存存储将不会尝试重新连接到Redis。如果您经常遇到断开连接的情况，可以启用重新连接尝试。

缓存读取和写入不会引发异常；它们只会返回`nil`，表现得就像缓存中没有任何内容一样。为了判断您的缓存是否遇到异常，您可以提供一个`error_handler`来报告给异常收集服务。它必须接受三个关键字参数：`method`，最初调用的缓存存储方法；`returning`，通常为`nil`的返回给用户的值；以及`exception`，被捕获的异常。

要开始使用，请将redis gem添加到您的Gemfile中：

```ruby
gem 'redis'
```

最后，在相关的`config/environments/*.rb`文件中添加配置：

```ruby
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
```

一个更复杂的生产Redis缓存存储可能如下所示：

```ruby
cache_servers = %w(redis://cache-01:6379/0 redis://cache-02:6379/0)
config.cache_store = :redis_cache_store, { url: cache_servers,

  connect_timeout:    30,  # 默认为20秒
  read_timeout:       0.2, # 默认为1秒
  write_timeout:      0.2, # 默认为1秒
  reconnect_attempts: 1,   # 默认为0

  error_handler: -> (method:, returning:, exception:) {
    # 将错误报告给Sentry作为警告
    Sentry.capture_exception exception, level: 'warning',
      tags: { method: method, returning: returning }
  }
}
```


### `ActiveSupport::Cache::NullStore`

[`ActiveSupport::Cache::NullStore`][]是针对每个Web请求的，它会在请求结束时清除存储的值。它适用于开发和测试环境。当您的代码直接与`Rails.cache`交互，但缓存干扰了查看代码更改结果时，它非常有用。

```ruby
config.cache_store = :null_store
```


### 自定义缓存存储

您可以通过简单地扩展`ActiveSupport::Cache::Store`并实现相应的方法来创建自己的自定义缓存存储。这样，您可以将任意数量的缓存技术集成到您的Rails应用程序中。

要使用自定义缓存存储，只需将缓存存储设置为您自定义类的新实例。

```ruby
config.cache_store = MyCacheStore.new
```

缓存键
----------

缓存中使用的键可以是任何响应`cache_key`或`to_param`的对象。如果需要生成自定义键，您可以在您的类上实现`cache_key`方法。Active Record将根据类名和记录ID生成键。

您可以使用哈希和值数组作为缓存键。

```ruby
# 这是一个合法的缓存键
Rails.cache.read(site: "mysite", owners: [owner_1, owner_2])
```

您在`Rails.cache`上使用的键与实际用于存储引擎的键不同。它们可能会被修改为带有命名空间或符合技术后端约束的形式。这意味着，例如，您不能使用`Rails.cache`保存值，然后尝试使用`dalli` gem提取它们。但是，您也不需要担心超过memcached大小限制或违反语法规则。

条件GET支持
-----------------------

条件GET是HTTP规范的一项功能，它提供了一种方式，让Web服务器告诉浏览器，GET请求的响应自上次请求以来没有发生变化，可以安全地从浏览器缓存中获取。

它们通过使用`HTTP_IF_NONE_MATCH`和`HTTP_IF_MODIFIED_SINCE`头部来传递唯一的内容标识符和内容上次更改的时间戳来工作。如果浏览器发出的请求中的内容标识符（ETag）或上次修改时间戳与服务器的版本匹配，则服务器只需发送一个空响应和未修改状态。

查找上次修改时间戳和if-none-match头部，并确定是否发送完整响应是服务器（即我们）的责任。在Rails中，通过条件GET支持，这是一个相当简单的任务：

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    # 如果请求根据给定的时间戳和带版本的etag值（即需要重新处理）是陈旧的，则执行此块
    if stale?(last_modified: @product.updated_at.utc, etag: @product.cache_key_with_version)
      respond_to do |wants|
        # ... 正常的响应处理
      end
    end

    # 如果请求是新鲜的（即未修改），则您不需要做任何事情。默认的渲染使用上一次调用stale?时使用的参数来检查这一点，并自动发送一个:not_modified。所以，你完成了。
  end
end
```
除了选项哈希，您还可以直接传递一个模型。Rails将使用`updated_at`和`cache_key_with_version`方法来设置`last_modified`和`etag`：

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    if stale?(@product)
      respond_to do |wants|
        # ... 正常的响应处理
      end
    end
  end
end
```

如果您没有任何特殊的响应处理，并且正在使用默认的渲染机制（即没有使用`respond_to`或调用自己的渲染），那么您可以使用`fresh_when`这个简单的辅助方法：

```ruby
class ProductsController < ApplicationController
  # 如果请求是新鲜的，将自动发送一个:not_modified，如果过期了，则渲染默认模板（product.*）。

  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, etag: @product
  end
end
```

有时我们希望缓存响应，例如静态页面，永远不会过期。为了实现这一点，我们可以使用`http_cache_forever`辅助方法，这样浏览器和代理服务器将无限期地缓存它。

默认情况下，缓存的响应将是私有的，仅在用户的Web浏览器上缓存。要允许代理服务器缓存响应，请设置`public: true`以指示它们可以将缓存的响应提供给所有用户。

使用这个辅助方法，`last_modified`头部被设置为`Time.new(2011, 1, 1).utc`，`expires`头部被设置为100年。

警告：请谨慎使用此方法，因为浏览器/代理服务器无法使缓存的响应失效，除非强制清除浏览器缓存。

```ruby
class HomeController < ApplicationController
  def index
    http_cache_forever(public: true) do
      render
    end
  end
end
```

### 强ETag与弱ETag

Rails默认生成弱ETag。弱ETag允许语义上等效的响应具有相同的ETag，即使它们的主体不完全匹配。当我们不希望页面在响应主体的微小变化时重新生成时，这是有用的。

弱ETag以`W/`开头以区分它们与强ETag。

```
W/"618bbc92e2d35ea1945008b42799b0e7" → 弱ETag
"618bbc92e2d35ea1945008b42799b0e7" → 强ETag
```

与弱ETag不同，强ETag意味着响应应该完全相同，逐字节相同。在对大型视频或PDF文件进行范围请求时非常有用。一些CDN仅支持强ETag，如Akamai。如果您绝对需要生成强ETag，可以按以下方式进行。

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, strong_etag: @product
  end
end
```

您还可以直接在响应上设置强ETag。

```ruby
response.strong_etag = response.body # => "618bbc92e2d35ea1945008b42799b0e7"
```

在开发中进行缓存
------------------

在开发模式下，通常希望测试应用程序的缓存策略。Rails提供了`dev:cache`命令来轻松切换缓存开/关。

```bash
$ bin/rails dev:cache
Development mode is now being cached.
$ bin/rails dev:cache
Development mode is no longer being cached.
```

默认情况下，当开发模式缓存关闭时，Rails使用[`:null_store`](#activesupport-cache-nullstore)。

参考资料
----------

* [DHH关于基于键的过期文章](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
* [Ryan Bates的关于缓存摘要的Railscast](http://railscasts.com/episodes/387-cache-digests)
[`config.action_controller.perform_caching`]: configuring.html#config-action-controller-perform-caching
[`ActiveSupport::Cache::Store`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
[ActiveSupport::Cache::Store#delete]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-delete
[ActiveSupport::Cache::Store#exist?]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-exist-3F
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#read]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-read
[ActiveSupport::Cache::Store#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-write
[`ActiveSupport::Cache::MemoryStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[`ActiveSupport::Cache::FileStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[`ActiveSupport::Cache::MemCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemCacheStore#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html#method-i-write
[`ActiveSupport::Cache::RedisCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[`ActiveSupport::Cache::NullStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/NullStore.html
