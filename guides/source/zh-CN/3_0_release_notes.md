**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: dd2584972aa8eae419ed5d55a287e27d
Ruby on Rails 3.0 发布说明
===============================

Rails 3.0 是小马和彩虹！它会为你做饭和叠衣服。你会想知道在它到来之前生活是如何可能的。这是我们做过的最好的 Rails 版本！

但是现在说正经的，这真的是很棒的东西。我们从 Merb 团队加入并注重框架的不可知性、更轻、更快的内部以及一些好用的 API 中带来了所有好的想法。如果你从 Merb 1.x 转到 Rails 3.0，你应该会认出很多东西。如果你从 Rails 2.x 转过来，你也会喜欢它的。

即使你对我们的内部清理一点兴趣都没有，Rails 3.0 也会让你喜欢。我们有一堆新功能和改进的 API。现在是成为 Rails 开发者的最佳时机。一些亮点包括：

* 全新的路由器，强调 RESTful 声明
* 基于 Action Controller 模型的新 Action Mailer API（现在不再痛苦地发送多部分消息！）
* 基于关系代数的可链接查询语言的新 Active Record
* 无侵入的 JavaScript 助手，支持 Prototype、jQuery 等驱动程序（不再内联 JS）
* 使用 Bundler 进行显式依赖管理

除此之外，我们尽力弃用旧的 API 并给出友好的警告。这意味着你可以将现有的应用程序迁移到 Rails 3，而不需要立即将所有旧代码重写为最新的最佳实践。

这些发布说明涵盖了主要的升级内容，但不包括每个小的错误修复和更改。Rails 3.0 由250多位作者的近4000次提交组成！如果你想看到所有内容，请查看 GitHub 上主要 Rails 存储库中的[提交列表](https://github.com/rails/rails/commits/3-0-stable)。

--------------------------------------------------------------------------------

安装 Rails 3：

```bash
# 如果你的设置需要，使用 sudo
$ gem install rails
```


升级到 Rails 3
--------------------

如果你正在升级现有的应用程序，在进行升级之前最好有良好的测试覆盖率。你还应该先升级到 Rails 2.3.5，并确保你的应用程序仍然按预期运行，然后再尝试更新到 Rails 3。然后注意以下更改：

### Rails 3 需要至少 Ruby 1.8.7

Rails 3.0 需要 Ruby 1.8.7 或更高版本。官方已经正式停止对所有之前的 Ruby 版本的支持，你应该尽早升级。Rails 3.0 也与 Ruby 1.9.2 兼容。

提示：请注意，Ruby 1.8.7 p248 和 p249 存在序列化错误，会导致 Rails 3.0 崩溃。Ruby Enterprise Edition 自 1.8.7-2010.02 版本以来已经修复了这些问题。在 1.9 方面，Ruby 1.9.1 无法使用，因为它在 Rails 3.0 上直接崩溃，所以如果你想在 1.9.x 上使用 Rails 3，请使用 1.9.2 以获得顺利的体验。

### Rails 应用程序对象

作为支持在同一进程中运行多个 Rails 应用程序的基础工作的一部分，Rails 3 引入了应用程序对象的概念。应用程序对象保存所有应用程序特定的配置，与之前版本的 Rails 中的 `config/environment.rb` 非常相似。

现在每个 Rails 应用程序都必须有一个对应的应用程序对象。应用程序对象在 `config/application.rb` 中定义。如果你正在将现有应用程序升级到 Rails 3，你必须添加这个文件，并将适当的配置从 `config/environment.rb` 移动到 `config/application.rb`。

### script/* 替换为 script/rails

新的 `script/rails` 替换了以前在 `script` 目录中的所有脚本。但你不直接运行 `script/rails`，`rails` 命令会检测到它在 Rails 应用程序的根目录中被调用，并为你运行脚本。使用方法如下：

```bash
$ rails console                      # 替代 script/console
$ rails g scaffold post title:string # 替代 script/generate scaffold post title:string
```

运行 `rails --help` 查看所有选项的列表。

### 依赖和 config.gem

`config.gem` 方法已经被移除，取而代之的是使用 `bundler` 和 `Gemfile`，请参阅下面的[管理 Gems](#vendoring-gems)。

### 升级过程

为了帮助升级过程，创建了一个名为 [Rails Upgrade](https://github.com/rails/rails_upgrade) 的插件来自动化部分过程。

只需安装插件，然后运行 `rake rails:upgrade:check` 来检查你的应用程序是否需要更新的部分（并提供链接以获取有关如何更新的信息）。它还提供了一个任务，根据当前的 `config.gem` 调用生成一个 `Gemfile`，以及根据当前的路由文件生成一个新的路由文件的任务。要获取插件，只需运行以下命令：
```bash
$ ruby script/plugin install git://github.com/rails/rails_upgrade.git
```

您可以在[Rails Upgrade is now an Official Plugin](http://omgbloglol.com/post/364624593/rails-upgrade-is-now-an-official-plugin)中看到它的工作示例。

除了Rails Upgrade工具之外，如果您需要更多帮助，IRC和[rubyonrails-talk](https://discuss.rubyonrails.org/c/rubyonrails-talk)上的人可能正在做同样的事情，可能会遇到相同的问题。请务必在升级时记录您自己的经验，以便其他人可以从您的知识中受益！

创建Rails 3.0应用程序
--------------------------------

```bash
# 您应该已经安装了'rails' RubyGem
$ rails new myapp
$ cd myapp
```

### 供应商化的Gems

Rails现在在应用程序根目录中使用`Gemfile`来确定您的应用程序启动所需的gems。这个`Gemfile`由[Bundler](https://github.com/bundler/bundler)处理，然后安装所有依赖项。它甚至可以将所有依赖项本地安装到您的应用程序中，以便它不依赖于系统gems。

更多信息：- [bundler主页](https://bundler.io/)

### 生活在边缘

`Bundler`和`Gemfile`使得通过新的专用`bundle`命令冻结您的Rails应用程序变得非常容易，因此`rake freeze`不再相关并已被删除。

如果您想直接从Git存储库进行捆绑，可以使用`--edge`标志：

```bash
$ rails new myapp --edge
```

如果您有一个Rails存储库的本地检出，并希望使用它生成一个应用程序，可以使用`--dev`标志：

```bash
$ ruby /path/to/rails/bin/rails new myapp --dev
```

Rails架构变化
---------------------------

Rails的架构发生了六个重大变化。

### Railties重新构建

Railties已更新，为整个Rails框架提供了一致的插件API，以及生成器和Rails绑定的完全重写，结果是开发人员现在可以以一种一致、定义明确的方式钩入生成器和应用程序框架的任何重要阶段。

### 所有Rails核心组件解耦

在合并Merb和Rails时，一个重要的任务是消除Rails核心组件之间的紧密耦合。现在已经实现了这一点，所有Rails核心组件现在都使用您可以用于开发插件的相同API。这意味着您制作的任何插件，或者任何核心组件替换（如DataMapper或Sequel）都可以访问Rails核心组件具有的所有功能，并随意扩展和增强。

更多信息：- [The Great Decoupling](http://yehudakatz.com/2009/07/19/rails-3-the-great-decoupling/)


### Active Model抽象

解耦核心组件的一部分是从Action Pack中提取出所有与Active Record的关联。这一工作现在已经完成。所有新的ORM插件现在只需要实现Active Model接口，就可以与Action Pack无缝配合使用。

更多信息：- [Make Any Ruby Object Feel Like ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### 控制器抽象

解耦核心组件的另一个重要部分是创建一个与HTTP概念分离的基类，以处理视图的渲染等。创建`AbstractController`允许大大简化`ActionController`和`ActionMailer`，从所有这些库中删除公共代码，并将其放入Abstract Controller中。

更多信息：- [Rails Edge Architecture](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Arel集成

[Arel](https://github.com/brynary/arel)（或Active Relation）已成为Active Record的基础，现在在Rails中是必需的。Arel提供了一个简化Active Record的SQL抽象，并为Active Record中的关系功能提供了基础。

更多信息：- [Why I wrote Arel](https://web.archive.org/web/20120718093140/http://magicscalingsprinkles.wordpress.com/2010/01/28/why-i-wrote-arel/)


### 邮件提取

Action Mailer自从诞生以来就有猴子补丁、预解析器，甚至是交付和接收代理，所有这些都是在源代码树中供应商化的TMail。版本3通过将所有与电子邮件消息相关的功能抽象出来到[Mail](https://github.com/mikel/mail) gem中来改变这一点。这再次减少了代码重复，并帮助创建Action Mailer和电子邮件解析器之间的可定义边界。

更多信息：- [New Action Mailer API in Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)


文档
-------------

Rails树中的文档正在更新以反映所有API更改，此外，[Rails Edge Guides](https://edgeguides.rubyonrails.org/)正在逐一更新以反映Rails 3.0中的更改。然而，[guides.rubyonrails.org](https://guides.rubyonrails.org/)上的指南将继续只包含稳定版本的Rails（目前为2.3.5版本，直到发布3.0版本）。

更多信息：- [Rails Documentation Projects](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)
国际化
--------------------

在Rails 3中，已经完成了大量的I18n支持工作，包括最新的[I18n](https://github.com/svenfuchs/i18n) gem提供了许多速度改进。

* 任何对象都可以添加I18n行为 - 只需包含`ActiveModel::Translation`和`ActiveModel::Validations`即可将I18n行为添加到任何对象中。还有一个`errors.messages`的回退选项用于翻译。
* 属性可以有默认的翻译。
* 表单提交标签会根据对象状态自动获取正确的状态（创建或更新），并获取正确的翻译。
* 使用I18n的标签现在只需传递属性名称即可。

更多信息：- [Rails 3 I18n变更](http://blog.plataformatec.com.br/2010/02/rails-3-i18n-changes/)


Railties
--------

随着主要的Rails框架的解耦，Railties经历了巨大的改进，以使框架、引擎或插件的链接变得更加简单和可扩展：

* 每个应用程序现在都有自己的命名空间，例如使用`YourAppName.boot`启动应用程序，这样与其他应用程序的交互变得更加容易。
* 现在将`Rails.root/app`下的所有内容都添加到加载路径中，因此您可以创建`app/observers/user_observer.rb`，Rails将在不进行任何修改的情况下加载它。
* Rails 3.0现在提供了一个`Rails.config`对象，它提供了所有种类的Rails全局配置选项的中央存储库。

应用程序生成增加了额外的标志，允许您跳过安装test-unit、Active Record、Prototype和Git。还添加了一个新的`--dev`标志，它将应用程序设置为使用`Gemfile`指向您的Rails检出（由`rails`二进制文件的路径确定）。有关更多信息，请参阅`rails --help`。

在Rails 3.0中，Railties生成器得到了大量的关注，基本上：

* 生成器已经完全重写，不再向后兼容。
* Rails模板API和生成器API合并为一个（与前者相同）。
* 生成器不再从特殊路径加载，它们只是在Ruby加载路径中找到，因此调用`rails generate foo`将查找`generators/foo_generator`。
* 新的生成器提供了钩子，因此任何模板引擎、ORM、测试框架都可以轻松地插入其中。
* 新的生成器允许您通过将副本放置在`Rails.root/lib/templates`中来覆盖模板。
* 还提供了`Rails::Generators::TestCase`，因此您可以创建自己的生成器并对其进行测试。

此外，Railties生成的视图也进行了一些改进：

* 视图现在使用`div`标签而不是`p`标签。
* 生成的脚手架现在使用`_form`局部视图，而不是在编辑和新建视图中重复的代码。
* 脚手架表单现在使用`f.submit`，根据传入的对象的状态返回"Create ModelName"或"Update ModelName"。

最后，rake任务也进行了一些增强：

* 添加了`rake db:forward`，允许您逐个或按组向前滚动迁移。
* 添加了`rake routes CONTROLLER=x`，允许您只查看一个控制器的路由。

Railties现在弃用了：

* `RAILS_ROOT`，使用`Rails.root`代替，
* `RAILS_ENV`，使用`Rails.env`代替，以及
* `RAILS_DEFAULT_LOGGER`，使用`Rails.logger`代替。

不再加载`PLUGIN/rails/tasks`和`PLUGIN/tasks`，现在所有任务都必须在`PLUGIN/lib/tasks`中。

更多信息：

* [探索Rails 3生成器](http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators)
* [Rails模块（在Rails 3中）](http://quaran.to/blog/2010/02/03/the-rails-module/)

Action Pack
-----------

在Action Pack中发生了重大的内部和外部变化。


### 抽象控制器

抽象控制器将Action Controller的通用部分提取出来，形成一个可重用的模块，任何库都可以使用该模块来渲染模板、渲染局部视图、辅助方法、翻译、日志记录以及请求响应周期的任何部分。这种抽象使得`ActionMailer::Base`现在只需继承自`AbstractController`，并将Rails DSL包装到Mail gem中。

它还提供了一个机会来清理Action Controller的代码，将可以简化的部分抽象出来。

但请注意，抽象控制器不是面向用户的API，在日常使用Rails时不会遇到它。

更多信息：- [Rails Edge架构](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Action Controller

* `application_controller.rb`现在默认启用了`protect_from_forgery`。
* `cookie_verifier_secret`已被弃用，现在通过`Rails.application.config.cookie_secret`分配，并移动到自己的文件中：`config/initializers/cookie_verification_secret.rb`。
* `session_store`在`ActionController::Base.session`中配置，现在移动到`Rails.application.config.session_store`。默认设置在`config/initializers/session_store.rb`中。
* `cookies.secure`允许您在cookie中设置加密值，例如`cookie.secure[:key] => value`。
* `cookies.permanent`允许您在cookie哈希中设置永久值，例如`cookie.permanent[:key] => value`，如果验证失败，则对签名值引发异常。
* 现在可以在`respond_to`块内的`format`调用中传递`:notice => 'This is a flash message'`或`:alert => 'Something went wrong'`。`flash[]`哈希仍然像以前一样工作。
* 现在在控制器中添加了`respond_with`方法，简化了古老的`format`块。
* 添加了`ActionController::Responder`，允许您灵活地生成响应。
弃用：

* `filter_parameter_logging` 已弃用，推荐使用 `config.filter_parameters << :password`。

更多信息：

* [Rails 3 中的渲染选项](https://blog.engineyard.com/2010/render-options-in-rails-3)
* [喜爱 ActionController::Responder 的三个原因](https://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder)


### Action Dispatch

Action Dispatch 是 Rails 3.0 中的新功能，提供了一个更清晰的路由实现。

* 对路由器进行了大规模的清理和重写，Rails 路由器现在是 `rack_mount`，在其上面有一个 Rails DSL，它是一个独立的软件。
* 每个应用程序定义的路由现在都在你的 Application 模块中进行命名空间划分，例如：

    ```ruby
    # 之前是：

    ActionController::Routing::Routes.draw do |map|
      map.resources :posts
    end

    # 现在是：

    AppName::Application.routes do
      resources :posts
    end
    ```

* 在路由器中添加了 `match` 方法，你还可以将任何 Rack 应用程序传递给匹配的路由。
* 在路由器中添加了 `constraints` 方法，允许你使用定义的约束条件保护路由器。
* 在路由器中添加了 `scope` 方法，允许你为不同的语言或不同的操作命名空间划分路由，例如：

    ```ruby
    scope 'es' do
      resources :projects, :path_names => { :edit => 'cambiar' }, :path => 'proyecto'
    end

    # 这样可以得到编辑操作的路径为 /es/proyecto/1/cambiar
    ```

* 在路由器中添加了 `root` 方法，作为 `match '/', :to => path` 的快捷方式。
* 你可以将可选的片段传递给匹配方法，例如 `match "/:controller(/:action(/:id))(.:format)"`，每个括号中的片段都是可选的。
* 路由可以通过块来表示，例如你可以调用 `controller :home { match '/:action' }`。

注意：旧的 `map` 命令仍然像以前一样工作，有一个向后兼容层，但这将在 3.1 版本中被移除。

弃用：

* 非 REST 应用程序的 catch all 路由 (`/:controller/:action/:id`) 现在已被注释掉。
* 路由中的 `:path_prefix` 不再存在，`:name_prefix` 现在会自动在给定的值后面添加 "_"。

更多信息：
* [Rails 3 路由器：Rack it Up](http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/)
* [Rails 3 中的改进路由](https://medium.com/fusion-of-thoughts/revamped-routes-in-rails-3-b6d00654e5b0)
* [Rails 3 中的通用操作](http://yehudakatz.com/2009/12/20/generic-actions-in-rails-3/)


### Action View

#### 非侵入式 JavaScript

在 Action View 辅助方法中进行了重大改写，实现了非侵入式 JavaScript (UJS) 钩子，并删除了旧的内联 AJAX 命令。这使得 Rails 可以使用任何符合 UJS 驱动程序的 UJS 钩子来实现辅助方法中的 UJS 钩子。

这意味着所有以前的 `remote_<method>` 辅助方法已从 Rails 核心中删除，并放入了 [Prototype Legacy Helper](https://github.com/rails/prototype_legacy_helper) 中。要在 HTML 中使用 UJS 钩子，现在可以传递 `:remote => true`。例如：

```ruby
form_for @post, :remote => true
```

生成的 HTML 为：

```html
<form action="http://host.com" id="create-post" method="post" data-remote="true">
```

#### 带有块的辅助方法

像 `form_for` 或 `div_for` 这样从块中插入内容的辅助方法现在使用 `<%=`：

```html+erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

你自己的这类辅助方法应该返回一个字符串，而不是手动追加到输出缓冲区。

像 `cache` 或 `content_for` 这样做其他操作的辅助方法不受此更改的影响，它们仍然需要使用 `<%`。

#### 其他更改

* 你不再需要调用 `h(string)` 来转义 HTML 输出，它在所有视图模板中默认开启。如果你想要未转义的字符串，可以调用 `raw(string)`。
* 辅助方法现在默认输出 HTML5。
* 表单标签辅助方法现在使用单个值从 I18n 中获取值，所以 `f.label :name` 将获取 `:name` 的翻译。
* I18n 中的选择标签现在应该是 :en.helpers.select，而不是 :en.support.select。
* 你不再需要在 ERB 模板中的 Ruby 插值的末尾加上减号来删除 HTML 输出中的尾随换行符。
* 在 Action View 中添加了 `grouped_collection_select` 辅助方法。
* 添加了 `content_for?`，允许你在渲染之前检查视图中是否存在内容。
* 将 `:value => nil` 传递给表单辅助方法将会将字段的 `value` 属性设置为 nil，而不是使用默认值。
* 将 `:id => nil` 传递给表单辅助方法将会导致这些字段不带有 `id` 属性进行渲染。
* 将 `:alt => nil` 传递给 `image_tag` 将会导致 `img` 标签不带有 `alt` 属性进行渲染。

Active Model
------------

Active Model 是 Rails 3.0 中的新功能。它提供了一个抽象层，供任何 ORM 库使用以与 Rails 交互，通过实现 Active Model 接口。
### ORM抽象和Action Pack接口

将核心组件解耦的一部分是从Action Pack中提取出与Active Record的所有关联。这一步已经完成。现在，所有新的ORM插件只需要实现Active Model接口，就可以与Action Pack无缝配合使用。

更多信息：- [使任何Ruby对象感觉像ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### 验证

验证已从Active Record移动到Active Model，为在Rails 3中跨ORM库工作的验证提供了一个接口。

* 现在有一个`validates :attribute, options_hash`的快捷方法，允许您为所有验证类方法传递选项，您可以向验证方法传递多个选项。
* `validates`方法有以下选项：
    * `:acceptance => Boolean`。
    * `:confirmation => Boolean`。
    * `:exclusion => { :in => Enumerable }`。
    * `:inclusion => { :in => Enumerable }`。
    * `:format => { :with => Regexp, :on => :create }`。
    * `:length => { :maximum => Fixnum }`。
    * `:numericality => Boolean`。
    * `:presence => Boolean`。
    * `:uniqueness => Boolean`。

注意：Rails版本2.3样式的验证方法在Rails 3.0中仍然受支持，新的validates方法被设计为在模型验证中提供额外的帮助，而不是替代现有的API。

您还可以传递一个验证器对象，然后可以在使用Active Model的对象之间重用它：

```ruby
class TitleValidator < ActiveModel::EachValidator
  Titles = ['Mr.', 'Mrs.', 'Dr.']
  def validate_each(record, attribute, value)
    unless Titles.include?(value)
      record.errors[attribute] << '必须是有效的头衔'
    end
  end
end
```

```ruby
class Person
  include ActiveModel::Validations
  attr_accessor :title
  validates :title, :presence => true, :title => true
end

# 或者对于Active Record

class Person < ActiveRecord::Base
  validates :title, :presence => true, :title => true
end
```

还支持自省：

```ruby
User.validators
User.validators_on(:login)
```

更多信息：

* [Rails 3中的Sexy验证](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)
* [解释Rails 3验证](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)


Active Record
-------------

Active Record在Rails 3.0中受到了很多关注，包括抽象为Active Model，使用Arel进行查询接口的完全更新，验证更新以及许多增强和修复。所有的Rails 2.x API都可以通过兼容层来使用，该兼容层将在3.1版本之前得到支持。


### 查询接口

Active Record现在通过使用Arel，在其核心方法上返回关系。Rails 2.3.x中的现有API仍然受支持，并且在Rails 3.1之前不会被弃用，在Rails 3.2之前不会被删除，但是新的API提供了以下新方法，它们都返回关系，可以将它们链接在一起：

* `where` - 在关系上提供条件，返回什么。
* `select` - 选择要从数据库中返回的模型的属性。
* `group` - 将关系分组在提供的属性上。
* `having` - 提供限制组关系的表达式（GROUP BY约束）。
* `joins` - 将关系与另一个表连接。
* `clause` - 提供限制连接关系的表达式（JOIN约束）。
* `includes` - 包含其他预加载的关系。
* `order` - 根据提供的表达式对关系进行排序。
* `limit` - 将关系限制为指定的记录数。
* `lock` - 锁定从表返回的记录。
* `readonly` - 返回数据的只读副本。
* `from` - 提供一种从多个表中选择关系的方法。
* `scope` - （以前是`named_scope`）返回关系，并可以与其他关系方法链接在一起。
* `with_scope` - 和`with_exclusive_scope`现在也返回关系，因此可以链接在一起。
* `default_scope` - 也适用于关系。

更多信息：

* [Active Record查询接口](http://m.onkey.org/2010/1/22/active-record-query-interface)
* [在Rails 3中让你的SQL Growl](http://hasmanyquestions.wordpress.com/2010/01/17/let-your-sql-growl-in-rails-3/)


### 增强功能

* 在Active Record对象中添加了`:destroyed?`。
* 在Active Record关联中添加了`:inverse_of`，允许您在不访问数据库的情况下获取已加载关联的实例。


### 补丁和弃用

此外，Active Record分支中进行了许多修复：

* 放弃了对SQLite 2的支持，转而支持SQLite 3。
* MySQL支持列顺序。
* 修复了PostgreSQL适配器的`TIME ZONE`支持，因此不再插入不正确的值。
* 为PostgreSQL的表名支持多个模式。
* PostgreSQL支持XML数据类型列。
* `table_name`现在已缓存。
* 对Oracle适配器也进行了大量工作，修复了许多错误。
以及以下的弃用：

* 在Active Record类中，`named_scope`已被弃用并更名为`scope`。
* 在`scope`方法中，应该使用关系方法而不是`:conditions => {}`查找方法，例如`scope :since, lambda {|time| where("created_at > ?", time) }`。
* `save(false)`已被弃用，推荐使用`save(:validate => false)`。
* Active Record的I18n错误消息应从`:en.activerecord.errors.template`更改为`:en.errors.template`。
* `model.errors.on`已被弃用，推荐使用`model.errors[]`。
* `validates_presence_of` => `validates... :presence => true`
* `ActiveRecord::Base.colorize_logging`和`config.active_record.colorize_logging`已被弃用，推荐使用`Rails::LogSubscriber.colorize_logging`或`config.colorize_logging`

注意：尽管在Active Record的最新版本中已经实现了状态机，但它已从Rails 3.0版本中移除。


Active Resource
---------------

Active Resource也被提取到Active Model中，使您可以无缝地在Action Pack中使用Active Resource对象。

* 通过Active Model添加了验证功能。
* 添加了观察钩子。
* 支持HTTP代理。
* 添加了对摘要认证的支持。
* 将模型命名移到Active Model中。
* 将Active Resource属性更改为具有无差别访问的哈希。
* 为等效的查找范围添加了`first`，`last`和`all`别名。
* 如果没有返回任何内容，`find_every`现在不会返回`ResourceNotFound`错误。
* 添加了`save!`，除非对象是`valid?`，否则会引发`ResourceInvalid`。
* 在Active Resource模型中添加了`update_attribute`和`update_attributes`。
* 添加了`exists?`。
* 将`SchemaDefinition`重命名为`Schema`，将`define_schema`重命名为`schema`。
* 使用Active Resources的`format`而不是远程错误的`content-type`加载错误。
* 在模式块中使用`instance_eval`。
* 修复了当`@response`不响应#code或#message时，`ActiveResource::ConnectionError#to_s`的错误，处理了Ruby 1.9的兼容性。
* 添加了对JSON格式错误的支持。
* 确保`load`与数字数组一起工作。
* 将来自远程资源的410响应识别为资源已被删除。
* 在Active Resource连接上添加了设置SSL选项的能力。
* 设置连接超时也会影响`Net::HTTP`的`open_timeout`。

弃用：

* `save(false)`已被弃用，推荐使用`save(:validate => false)`。
* Ruby 1.9.2：`URI.parse`和`.decode`已被弃用，并且不再在库中使用。


Active Support
--------------

在Active Support中进行了大量努力，使其可以进行选择性挑选，也就是说，您不再需要引入整个Active Support库来获取其中的一部分。这使得Rails的各个核心组件可以更加精简运行。

以下是Active Support的主要变化：

* 对库进行了大量清理，删除了未使用的方法。
* Active Support不再提供TZInfo、Memcache Client和Builder的版本。这些都作为依赖项包含在内，并通过`bundle install`命令安装。
* 在`ActiveSupport::SafeBuffer`中实现了安全缓冲区。
* 添加了`Array.uniq_by`和`Array.uniq_by!`。
* 删除了`Array#rand`，并从Ruby 1.9中回溯了`Array#sample`。
* 修复了`TimeZone.seconds_to_utc_offset`返回错误值的错误。
* 添加了`ActiveSupport::Notifications`中间件。
* `ActiveSupport.use_standard_json_time_format`现在默认为true。
* `ActiveSupport.escape_html_entities_in_json`现在默认为false。
* `Integer#multiple_of?`接受零作为参数，除非接收者为零，否则返回false。
* `string.chars`已更名为`string.mb_chars`。
* `ActiveSupport::OrderedHash`现在可以通过YAML进行反序列化。
* 使用LibXML和Nokogiri为XmlMini添加了基于SAX的解析器。
* 添加了`Object#presence`，如果对象是`#present?`，则返回对象，否则返回`nil`。
* 添加了`String#exclude?`核心扩展，返回`#include?`的相反结果。
* 在`ActiveSupport`中为`DateTime`添加了`to_i`，以便在具有`DateTime`属性的模型上正确使用`to_yaml`。
* 添加了`Enumerable#exclude?`，以实现与`Enumerable#include?`的一致性，并避免使用`!x.include?`。
* 切换到默认启用的XSS转义。
* 在`ActiveSupport::HashWithIndifferentAccess`中支持深度合并。
* `Enumerable#sum`现在适用于所有可枚举对象，即使它们不响应`:size`。
* 长度为零的持续时间的`inspect`返回'0 seconds'而不是空字符串。
* 在`ModelName`中添加了`element`和`collection`。
* `String#to_time`和`String#to_datetime`处理小数秒。
* 为响应`：before`和`：after`的around过滤器对象添加了对新回调的支持，用于before和after回调。
* `ActiveSupport::OrderedHash#to_a`方法返回一组有序的数组。与Ruby 1.9的`Hash#to_a`匹配。
* `MissingSourceFile`存在作为一个常量，但现在只等于`LoadError`。
* 添加了`Class#class_attribute`，以便能够声明一个类级别的属性，其值是可继承的，并且可以被子类覆盖。
* 最终删除了`ActiveRecord::Associations`中的`DeprecatedCallbacks`。
* `Object#metaclass`现在是`Kernel#singleton_class`，以与Ruby匹配。
以下方法已被移除，因为它们现在在Ruby 1.8.7和1.9中可用。

* `Integer#even?` 和 `Integer#odd?`
* `String#each_char`
* `String#start_with?` 和 `String#end_with?`（第三人称别名仍保留）
* `String#bytesize`
* `Object#tap`
* `Symbol#to_proc`
* `Object#instance_variable_defined?`
* `Enumerable#none?`

REXML的安全补丁仍然保留在Active Support中，因为早期的Ruby 1.8.7补丁级别仍然需要它。Active Support知道是否需要应用该补丁。

以下方法已被移除，因为它们在框架中不再使用：

* `Kernel#daemonize`
* `Object#remove_subclasses_of` `Object#extend_with_included_modules_from`, `Object#extended_by`
* `Class#remove_class`
* `Regexp#number_of_captures`, `Regexp.unoptionalize`, `Regexp.optionalize`, `Regexp#number_of_captures`


Action Mailer
-------------

Action Mailer使用新的API，将TMail替换为新的[Mail](https://github.com/mikel/mail)作为邮件库。Action Mailer本身经历了几乎完全的重写，几乎每一行代码都有所改动。结果是，Action Mailer现在只是继承自Abstract Controller，并在Rails DSL中包装Mail gem。这大大减少了Action Mailer中的代码量和其他库的重复。

* 所有邮件现在默认放在`app/mailers`中。
* 现在可以使用三个方法`attachments`、`headers`和`mail`使用新的API发送电子邮件。
* Action Mailer现在原生支持使用`attachments.inline`方法进行内联附件。
* Action Mailer的发送方法现在返回`Mail::Message`对象，可以通过发送`deliver`消息来发送邮件。
* 所有的传递方法现在都抽象到Mail gem中。
* 邮件传递方法可以接受一个包含所有有效邮件头字段及其值对的哈希。
* `mail`传递方法的行为类似于Action Controller的`respond_to`，可以显式或隐式地渲染模板。Action Mailer会根据需要将电子邮件转换为多部分电子邮件。
* 可以将proc传递给邮件块中的`format.mime_type`调用，显式地渲染特定类型的文本，或添加布局或不同的模板。proc中的`render`调用来自Abstract Controller，并支持相同的选项。
* 原来的邮件单元测试已移动到功能测试中。
* Action Mailer现在将所有标题字段和正文的自动编码委托给Mail Gem。
* Action Mailer将自动为您编码电子邮件正文和标题。

弃用：

* `:charset`、`:content_type`、`:mime_version`、`:implicit_parts_order`都已弃用，推荐使用`ActionMailer.default :key => value`样式的声明。
* 邮件动态`create_method_name`和`deliver_method_name`已弃用，只需调用`method_name`，它现在返回一个`Mail::Message`对象。
* 弃用`ActionMailer.deliver(message)`，只需调用`message.deliver`。
* 弃用`template_root`，将选项传递给`mail`生成块内的`format.mime_type`方法中的渲染调用。
* 弃用使用`body`方法定义实例变量（`body {:ivar => value}`），只需直接在方法中声明实例变量，它们将在视图中可用。
* 弃用将邮件放在`app/models`中，改用`app/mailers`。

更多信息：

* [Rails 3中的新Action Mailer API](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)
* [Ruby的新Mail Gem](http://lindsaar.net/2010/1/23/mail-gem-version-2-released)


贡献者
-------

请参阅[Rails的完整贡献者列表](https://contributors.rubyonrails.org/)，感谢那些花费了很多时间制作Rails 3的人。向他们致敬。

Rails 3.0发布说明由[Mikel Lindsaar](http://lindsaar.net)编写。
