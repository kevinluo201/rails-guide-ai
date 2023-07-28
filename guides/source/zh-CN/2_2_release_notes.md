**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 29fda46e32914456eb8369ab3f2cb7d6
Ruby on Rails 2.2 发布说明
===============================

Rails 2.2 提供了几个新的和改进的功能。这个列表涵盖了主要的升级内容，但不包括每一个小的错误修复和更改。如果你想查看所有内容，请查看 GitHub 上主要 Rails 存储库的 [提交列表](https://github.com/rails/rails/commits/2-2-stable)。

除了 Rails，2.2 还标志着 [Ruby on Rails Guides](https://guides.rubyonrails.org/) 的发布，这是持续进行中的 [Rails Guides hackfest](http://hackfest.rubyonrails.org/guide) 的第一个成果。该网站将提供 Rails 主要功能的高质量文档。

--------------------------------------------------------------------------------

基础设施
--------------

Rails 2.2 对保持 Rails 运行和与世界其他部分连接的基础设施进行了重要的更新。

### 国际化

Rails 2.2 提供了一个简单的国际化系统（或者对于那些厌倦了打字的人来说，叫做 i18n）。

* 主要贡献者：Rails i18 团队
* 更多信息：
    * [官方 Rails i18n 网站](http://rails-i18n.org)
    * [终于，Ruby on Rails 实现了国际化](https://web.archive.org/web/20140407075019/http://www.artweb-design.de/2008/7/18/finally-ruby-on-rails-gets-internationalized)
    * [本地化 Rails：演示应用程序](https://github.com/clemens/i18n_demo_app)

### 与 Ruby 1.9 和 JRuby 的兼容性

除了线程安全性，还进行了大量工作，使得 Rails 在 JRuby 和即将发布的 Ruby 1.9 上能够良好运行。由于 Ruby 1.9 是一个不断变化的目标，运行最新版的 Rails 在最新版的 Ruby 上仍然是一个试错的过程，但是当后者发布时，Rails 已经准备好过渡到 Ruby 1.9。

文档
-------------

Rails 的内部文档，以代码注释的形式，在许多地方得到了改进。此外，[Ruby on Rails Guides](https://guides.rubyonrails.org/) 项目是关于主要 Rails 组件信息的权威来源。在其首次正式发布中，Guides 页面包括：

* [Rails 入门指南](getting_started.html)
* [Rails 数据库迁移](active_record_migrations.html)
* [Active Record 关联](association_basics.html)
* [Active Record 查询接口](active_record_querying.html)
* [Rails 中的布局和渲染](layouts_and_rendering.html)
* [Action View 表单助手](form_helpers.html)
* [从外部了解 Rails 路由](routing.html)
* [Action Controller 概述](action_controller_overview.html)
* [Rails 缓存](caching_with_rails.html)
* [Rails 应用程序测试指南](testing.html)
* [保护 Rails 应用程序](security.html)
* [调试 Rails 应用程序](debugging_rails_applications.html)
* [创建 Rails 插件的基础知识](plugins.html)

总的来说，这些指南为初学者和中级 Rails 开发人员提供了数以万计的指导词。

如果你想在应用程序内部生成这些指南：

```bash
$ rake doc:guides
```

这将把指南放在 `Rails.root/doc/guides` 中，你可以通过在你喜欢的浏览器中打开 `Rails.root/doc/guides/index.html` 来开始浏览。

* 主要贡献者：[Xavier Noria](http://advogato.org/person/fxn/diary.html) 和 [Hongli Lai](http://izumi.plan99.net/blog/)
* 更多信息：
    * [Rails Guides hackfest](http://hackfest.rubyonrails.org/guide)
    * [在 Git 分支上改进 Rails 文档的帮助](https://weblog.rubyonrails.org/2008/5/2/help-improve-rails-documentation-on-git-branch)

更好地与 HTTP 集成：开箱即用的 ETag 支持
----------------------------------------------------------

支持在 HTTP 标头中使用 ETag 和上次修改时间戳意味着如果 Rails 收到一个对最近未修改的资源的请求，它现在可以发送一个空响应。这使得你可以检查是否需要发送响应。

```ruby
class ArticlesController < ApplicationController
  def show_with_respond_to_block
    @article = Article.find(params[:id])

    # 如果请求发送的标头与 stale? 方法提供的选项不同，那么请求确实是过期的，respond_to 块将被触发（并且 stale? 调用的选项将设置在响应中）。
    #
    # 如果请求标头匹配，那么请求是新鲜的，respond_to 块不会被触发。相反，将发生默认渲染，它将检查上次修改和 ETag 标头，并得出只需要发送 "304 Not Modified" 而不是渲染模板。
    if stale?(:last_modified => @article.published_at.utc, :etag => @article)
      respond_to do |wants|
        # 正常的响应处理
      end
    end
  end

  def show_with_implied_render
    @article = Article.find(params[:id])

    # 设置响应标头并将其与请求进行比较，如果请求是过期的（即 etag 或 last-modified 没有匹配），那么默认渲染模板将发生。
    # 如果请求是新鲜的，那么默认渲染将返回 "304 Not Modified" 而不是渲染模板。
    fresh_when(:last_modified => @article.published_at.utc, :etag => @article)
  end
end
```

线程安全性
-------------

使 Rails 线程安全的工作正在 Rails 2.2 中推出。根据你的 Web 服务器基础设施，这意味着你可以处理更多请求，使用更少的 Rails 副本在内存中，从而提高服务器性能并更好地利用多个核心。
要在应用程序的生产模式中启用多线程调度，请在`config/environments/production.rb`中添加以下行：

```ruby
config.threadsafe!
```

* 更多信息：
    * [Thread safety for your Rails](http://m.onkey.org/2008/10/23/thread-safety-for-your-rails)
    * [Thread safety project announcement](https://weblog.rubyonrails.org/2008/8/16/josh-peek-officially-joins-the-rails-core)
    * [Q/A: What Thread-safe Rails Means](http://blog.headius.com/2008/08/qa-what-thread-safe-rails-means.html)

Active Record
-------------

这里有两个重要的新增功能需要讨论：事务性迁移和数据库连接池事务。还有一种更清晰的语法用于连接表条件，以及许多较小的改进。

### 事务性迁移

历史上，多步骤的Rails迁移一直是一个麻烦的问题。如果在迁移过程中出现问题，错误之前的所有更改都会改变数据库，错误之后的所有更改都不会应用。此外，迁移版本被存储为已执行，这意味着在修复问题后无法简单地通过`rake db:migrate:redo`重新运行迁移。事务性迁移通过将迁移步骤包装在DDL事务中来改变这一点，因此如果任何步骤失败，整个迁移都会被撤消。在Rails 2.2中，事务性迁移在PostgreSQL上得到了支持。该代码将来可以扩展到其他数据库类型，并且IBM已经扩展它以支持DB2适配器。

* 主要贡献者：[Adam Wiggins](http://about.adamwiggins.com/)
* 更多信息：
    * [DDL Transactions](http://adam.heroku.com/past/2008/9/3/ddl_transactions/)
    * [A major milestone for DB2 on Rails](http://db2onrails.com/2008/11/08/a-major-milestone-for-db2-on-rails/)

### 连接池

连接池允许Rails在一个数据库连接池中分发数据库请求，该连接池将增长到最大大小（默认为5，但您可以在`database.yml`中添加一个`pool`键来调整此值）。这有助于消除支持许多并发用户的应用程序中的瓶颈。还有一个`wait_timeout`，默认为5秒。如果需要，`ActiveRecord::Base.connection_pool`可以直接访问连接池。

```yaml
development:
  adapter: mysql
  username: root
  database: sample_development
  pool: 10
  wait_timeout: 10
```

* 主要贡献者：[Nick Sieger](http://blog.nicksieger.com/)
* 更多信息：
    * [What's New in Edge Rails: Connection Pools](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-connection-pools)

### 连接表条件的哈希

现在可以使用哈希指定连接表的条件。如果需要在复杂的连接中查询，这将非常有帮助。

```ruby
class Photo < ActiveRecord::Base
  belongs_to :product
end

class Product < ActiveRecord::Base
  has_many :photos
end

# 获取所有具有无版权照片的产品：
Product.all(:joins => :photos, :conditions => { :photos => { :copyright => false }})
```

* 更多信息：
    * [What's New in Edge Rails: Easy Join Table Conditions](http://archives.ryandaigle.com/articles/2008/7/7/what-s-new-in-edge-rails-easy-join-table-conditions)

### 新的动态查找器

Active Record的动态查找器系列中添加了两组新方法。

#### `find_last_by_attribute`

`find_last_by_attribute`方法等同于`Model.last(:conditions => {:attribute => value})`

```ruby
# 获取最后一个来自伦敦注册的用户
User.find_last_by_city('London')
```

* 主要贡献者：[Emilio Tagua](http://www.workingwithrails.com/person/9147-emilio-tagua)

#### `find_by_attribute!`

`find_by_attribute!`的新版本是`Model.first(:conditions => {:attribute => value}) || raise ActiveRecord::RecordNotFound`。如果找不到匹配的记录，这个方法不会返回`nil`，而是会引发异常。

```ruby
# 如果'Moby'尚未注册，则引发ActiveRecord::RecordNotFound异常！
User.find_by_name!('Moby')
```

* 主要贡献者：[Josh Susser](http://blog.hasmanythrough.com)

### 关联关系尊重私有/受保护范围

Active Record关联代理现在尊重代理对象上方法的范围。以前（假设User has_one :account），`@user.account.private_method`会调用关联的Account对象上的私有方法。在Rails 2.2中，这将失败；如果您需要此功能，应该使用`@user.account.send(:private_method)`（或将方法从私有或受保护更改为公共）。请注意，如果您覆盖了`method_missing`，您还应该覆盖`respond_to`以匹配行为，以使关联正常工作。

* 主要贡献者：Adam Milligan
* 更多信息：
    * [Rails 2.2 Change: Private Methods on Association Proxies are Private](http://afreshcup.com/2008/10/24/rails-22-change-private-methods-on-association-proxies-are-private/)

### 其他Active Record更改

* `rake db:migrate:redo`现在接受一个可选的VERSION，以将特定迁移目标重新执行
* 设置`config.active_record.timestamped_migrations = false`，以便迁移具有数字前缀而不是UTC时间戳。
* 计数缓存列（对于使用`counter_cache => true`声明的关联）不再需要初始化为零。
* `ActiveRecord::Base.human_name`用于对模型名称进行国际化感知的人性化翻译

Action Controller
-----------------

在控制器方面，有几个变化可以帮助整理您的路由。路由引擎中还有一些内部变化，以降低复杂应用程序的内存使用。
### 浅层嵌套路由

浅层嵌套路由提供了解决使用深层嵌套资源的难题的方法。使用浅层嵌套，您只需要提供足够的信息来唯一标识您想要处理的资源。

```ruby
map.resources :publishers, :shallow => true do |publisher|
  publisher.resources :magazines do |magazine|
    magazine.resources :photos
  end
end
```

这将使得以下路由可以被识别：

```
/publishers/1           ==> publisher_path(1)
/publishers/1/magazines ==> publisher_magazines_path(1)
/magazines/2            ==> magazine_path(2)
/magazines/2/photos     ==> magazines_photos_path(2)
/photos/3               ==> photo_path(3)
```

* 主要贡献者：[S. Brent Faulkner](http://www.unwwwired.net/)
* 更多信息：
    * [从外部了解Rails路由](routing.html#nested-resources)
    * [Edge Rails的新功能：浅层路由](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-shallow-routes)

### 成员或集合路由的方法数组

现在，您可以为新的成员或集合路由提供一个方法数组。这样，当您需要处理多个动词时，您不再需要将路由定义为接受任何动词。在Rails 2.2中，这是一个合法的路由声明：

```ruby
map.resources :photos, :collection => { :search => [:get, :post] }
```

* 主要贡献者：[Brennan Dunn](http://brennandunn.com/)

### 具有特定动作的资源

默认情况下，当您使用`map.resources`创建路由时，Rails会为七个默认动作（index、show、create、new、edit、update和destroy）生成路由。但是，每个路由在应用程序中占用内存，并导致Rails生成额外的路由逻辑。现在，您可以使用`:only`和`:except`选项来精确控制Rails为资源生成的路由。您可以提供单个动作、动作数组或特殊的`:all`或`:none`选项。这些选项会被嵌套资源继承。

```ruby
map.resources :photos, :only => [:index, :show]
map.resources :products, :except => :destroy
```

* 主要贡献者：[Tom Stuart](http://experthuman.com/)

### 其他动作控制器的变化

* 现在，您可以轻松地为路由请求时引发的异常显示[自定义错误页面](http://m.onkey.org/2008/7/20/rescue-from-dispatching)。
* 默认情况下，禁用了HTTP Accept头。您应该优先使用格式化的URL（例如`/customers/1.xml`）来指示您想要的格式。如果您需要Accept头，可以使用`config.action_controller.use_accept_header = true`将其打开。
* 基准测试的数字现在以毫秒为单位报告，而不是秒的小小部分。
* Rails现在支持仅HTTP的Cookie（并将其用于会话），这有助于减轻新版本浏览器中的一些跨站脚本风险。
* `redirect_to`现在完全支持URI方案（因此，例如，您可以重定向到svn`ssh: URI）。
* `render`现在支持`:js`选项，以使用正确的MIME类型呈现纯粹的JavaScript。
* 请求伪造保护现在仅适用于HTML格式的内容请求。
* 如果传递的参数为nil，多态URL将更加合理。例如，使用nil日期调用`polymorphic_path([@project, @date, @area])`将给出`project_area_path`。

Action View
-----------

* `javascript_include_tag`和`stylesheet_link_tag`支持一个新的`:recursive`选项，与`:all`一起使用，以便您可以使用一行代码加载整个文件树。
* 包含的Prototype JavaScript库已升级到1.6.0.3版本。
* `RJS#page.reload`通过JavaScript重新加载浏览器的当前位置
* `atom_feed`助手现在接受一个`:instruct`选项，让您插入XML处理指令。

Action Mailer
-------------

Action Mailer现在支持邮件布局。您可以通过提供一个适当命名的布局（例如，`CustomerMailer`类希望使用`layouts/customer_mailer.html.erb`）使您的HTML邮件与浏览器视图一样漂亮。

* 更多信息：
    * [Edge Rails的新功能：邮件布局](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-mailer-layouts)

Action Mailer现在通过自动启用STARTTLS来支持GMail的SMTP服务器。这需要安装Ruby 1.8.7。

Active Support
--------------

Active Support现在为Rails应用程序提供了内置的记忆化、`each_with_object`方法、委托的前缀支持和其他各种新的实用方法。

### 记忆化

记忆化是一种模式，它初始化一个方法一次，然后将其值存储起来以供重复使用。您可能在自己的应用程序中使用过这种模式：

```ruby
def full_name
  @full_name ||= "#{first_name} #{last_name}"
end
```

记忆化使您可以以声明性的方式处理此任务：

```ruby
extend ActiveSupport::Memoizable

def full_name
  "#{first_name} #{last_name}"
end
memoize :full_name
```

记忆化的其他特性包括`unmemoize`、`unmemoize_all`和`memoize_all`，用于打开或关闭记忆化。
* 主要贡献者：[Josh Peek](http://joshpeek.com/)
* 更多信息：
    * [Edge Rails的新功能：简单的记忆化](http://archives.ryandaigle.com/articles/2008/7/16/what-s-new-in-edge-rails-memoization)
    * [记忆化指南](http://www.railway.at/articles/2008/09/20/a-guide-to-memoization)

### each_with_object

`each_with_object`方法提供了一个替代`inject`的方法，使用了从Ruby 1.9中回溯的方法。它遍历一个集合，将当前元素和记忆传递给块。

```ruby
%w(foo bar).each_with_object({}) { |str, hsh| hsh[str] = str.upcase } # => {'foo' => 'FOO', 'bar' => 'BAR'}
```

主要贡献者：[Adam Keys](http://therealadam.com/)

### 带前缀的委托

如果你从一个类委托行为到另一个类，现在你可以指定一个前缀来标识被委托的方法。例如：

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => true
end
```

这将生成委托方法`vendor#account_email`和`vendor#account_password`。你也可以指定一个自定义前缀：

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => :owner
end
```

这将生成委托方法`vendor#owner_email`和`vendor#owner_password`。

主要贡献者：[Daniel Schierbeck](http://workingwithrails.com/person/5830-daniel-schierbeck)

### 其他Active Support的变化

* 对`ActiveSupport::Multibyte`进行了广泛更新，包括Ruby 1.9的兼容性修复。
* 添加了`ActiveSupport::Rescuable`，允许任何类混入`rescue_from`语法。
* `Date`和`Time`类的`past?`、`today?`和`future?`方法，用于方便地进行日期/时间比较。
* `Array#second`到`Array#fifth`作为`Array#[1]`到`Array#[4]`的别名
* `Enumerable#many?`用于封装`collection.size > 1`
* `Inflector#parameterize`生成一个URL可用的版本，用于`to_param`。
* `Time#advance`可以识别小数天和周，所以你可以使用`1.7.weeks.ago`、`1.5.hours.since`等等。
* 包含的TzInfo库已升级到0.3.12版本。
* `ActiveSupport::StringInquirer`提供了一种漂亮的方式来测试字符串的相等性：`ActiveSupport::StringInquirer.new("abc").abc? => true`

Railties
--------

在Railties（Rails核心代码）中，最大的变化在于`config.gems`机制。

### config.gems

为了避免部署问题并使Rails应用程序更加自包含，可以将Rails应用程序所需的所有gem的副本放在`/vendor/gems`中。这个功能首次出现在Rails 2.1中，但在Rails 2.2中更加灵活和健壮，处理了gem之间的复杂依赖关系。Rails中的gem管理包括以下命令：

* 在`config/environment.rb`文件中使用`config.gem _gem_name_`
* 使用`rake gems`列出所有配置的gem，以及它们（和它们的依赖项）是否已安装、冻结或框架（框架gem是在执行gem依赖代码之前由Rails加载的gem；这样的gem不能被冻结）
* 使用`rake gems:install`将缺失的gem安装到计算机上
* 使用`rake gems:unpack`将所需的gem的副本放置在`/vendor/gems`中
* 使用`rake gems:unpack:dependencies`将所需的gem及其依赖项的副本放置在`/vendor/gems`中
* 使用`rake gems:build`构建任何缺失的本地扩展
* 使用`rake gems:refresh_specs`将使用Rails 2.1创建的vendored gem与Rails 2.2的存储方式保持一致

可以通过在命令行上指定`GEM=_gem_name_`来解压或安装单个gem。

* 主要贡献者：[Matt Jones](https://github.com/al2o3cr)
* 更多信息：
    * [Edge Rails的新功能：Gem依赖关系](http://archives.ryandaigle.com/articles/2008/4/1/what-s-new-in-edge-rails-gem-dependencies)
    * [Rails 2.1.2和2.2RC1：更新你的RubyGems](https://afreshcup.com/home/2008/10/25/rails-212-and-22rc1-update-your-rubygems)
    * [Lighthouse上的详细讨论](http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1128)

### 其他Railties的变化

* 如果你是[Thin](http://code.macournoyer.com/thin/) web服务器的粉丝，你会很高兴知道`script/server`现在直接支持Thin。
* `script/plugin install &lt;plugin&gt; -r &lt;revision&gt;`现在可以与基于git和svn的插件一起使用。
* `script/console`现在支持`--debugger`选项
* 在Rails源码中包含了设置连续集成服务器来构建Rails本身的说明
* `rake notes:custom ANNOTATION=MYFLAG`允许你列出自定义注释。
* 将`Rails.env`封装在`StringInquirer`中，这样你就可以使用`Rails.env.development?`
* 为了消除弃用警告并正确处理gem依赖关系，Rails现在需要rubygems 1.3.1或更高版本。

已弃用
----------

在这个版本中，一些旧代码已被弃用：

* `Rails::SecretKeyGenerator`已被`ActiveSupport::SecureRandom`取代
* `render_component`已被弃用。如果你需要这个功能，可以使用[render_components插件](https://github.com/rails/render_component/tree/master)。
* 渲染局部视图时的隐式局部变量赋值已被弃用。

    ```ruby
    def partial_with_implicit_local_assignment
      @customer = Customer.new("Marcel")
      render :partial => "customer"
    end
    ```

    以前的代码在局部视图'customer'中提供了一个名为`customer`的局部变量。现在你应该通过`:locals`哈希显式传递所有变量。
* `country_select` 已被移除。请查看[弃用页面](http://www.rubyonrails.org/deprecation/list-of-countries)获取更多信息和插件替代方案。
* `ActiveRecord::Base.allow_concurrency` 不再起作用。
* `ActiveRecord::Errors.default_error_messages` 已被弃用，推荐使用 `I18n.translate('activerecord.errors.messages')`。
* 国际化的 `%s` 和 `%d` 插值语法已被弃用。
* `String#chars` 已被弃用，推荐使用 `String#mb_chars`。
* 弃用了小数月份或小数年份的持续时间。请使用 Ruby 的核心 `Date` 和 `Time` 类进行计算。
* `Request#relative_url_root` 已被弃用。请使用 `ActionController::Base.relative_url_root` 代替。

致谢
-------

发布说明由 [Mike Gunderloy](http://afreshcup.com) 编写
