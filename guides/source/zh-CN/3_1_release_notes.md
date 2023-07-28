**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: da25f37b5b3eddff86c5b5b2cd24007f
Ruby on Rails 3.1 发布说明
===============================

Rails 3.1 的亮点：

* 流式传输
* 可逆迁移
* 资源管道
* jQuery 作为默认的 JavaScript 库

这些发布说明仅涵盖了主要更改。要了解各种错误修复和更改，请参考更改日志或查看 GitHub 上主要 Rails 存储库中的[提交列表](https://github.com/rails/rails/commits/3-1-stable)。

--------------------------------------------------------------------------------

升级到 Rails 3.1
----------------------

如果您正在升级现有应用程序，在进行升级之前，最好有很好的测试覆盖率。您还应该首先升级到 Rails 3，以防您还没有，并确保您的应用程序在尝试更新到 Rails 3.1 之前仍然按预期运行。然后请注意以下更改：

### Rails 3.1 需要至少 Ruby 1.8.7

Rails 3.1 需要 Ruby 1.8.7 或更高版本。官方已经正式放弃了对所有先前的 Ruby 版本的支持，您应尽早升级。Rails 3.1 也与 Ruby 1.9.2 兼容。

提示：请注意，Ruby 1.8.7 p248 和 p249 存在导致 Rails 崩溃的序列化错误。然而，Ruby Enterprise Edition 自 1.8.7-2010.02 版本以来已经修复了这些错误。在 1.9 方面，Ruby 1.9.1 无法使用，因为它会直接崩溃，所以如果您想使用 1.9.x，请选择 1.9.2 版本以确保顺利进行。

### 应用程序中需要更新的内容

以下更改是为了将您的应用程序升级到 Rails 3.1.3，即 Rails 的最新 3.1.x 版本。

#### Gemfile

对您的 `Gemfile` 进行以下更改。

```ruby
gem 'rails', '= 3.1.3'
gem 'mysql2'

# 为新的资源管道所需
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# jQuery 是 Rails 3.1 的默认 JavaScript 库
gem 'jquery-rails'
```

#### config/application.rb

* 资源管道需要以下添加：

    ```ruby
    config.assets.enabled = true
    config.assets.version = '1.0'
    ```

* 如果您的应用程序使用 "/assets" 路由来访问资源，您可能需要更改用于资源的前缀以避免冲突：

    ```ruby
    # 默认为 '/assets'
    config.assets.prefix = '/asset-files'
    ```

#### config/environments/development.rb

* 删除 RJS 设置 `config.action_view.debug_rjs = true`。

* 如果您启用了资源管道，请添加以下内容。

    ```ruby
    # 不压缩资源
    config.assets.compress = false

    # 展开加载资源的行
    config.assets.debug = true
    ```

#### config/environments/production.rb

* 同样，下面的大部分更改是为了资源管道。您可以在[资源管道](asset_pipeline.html)指南中了解更多信息。

    ```ruby
    # 压缩 JavaScript 和 CSS
    config.assets.compress = true

    # 如果预编译的资源丢失，不要回退到资源管道
    config.assets.compile = false

    # 为资源 URL 生成摘要
    config.assets.digest = true

    # 默认为 Rails.root.join("public/assets")
    # config.assets.manifest = YOUR_PATH

    # 预编译其他资源（application.js、application.css 和所有非 JS/CSS 文件已经添加）
    # config.assets.precompile `= %w( admin.js admin.css )


    # 强制通过 SSL 访问应用程序，使用 Strict-Transport-Security，并使用安全的 cookie。
    # config.force_ssl = true
    ```

#### config/environments/test.rb

```ruby
# 为测试配置静态资源服务器，使用 Cache-Control 提高性能
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

#### config/initializers/wrap_parameters.rb

* 如果您希望将参数封装到嵌套的哈希中，请添加此文件并包含以下内容。这在新应用程序中默认启用。

    ```ruby
    # 修改此文件后请务必重新启动服务器。
    # 此文件包含 ActionController::ParamsWrapper 的设置，默认情况下启用。

    # 启用 JSON 的参数封装。您可以通过将 :format 设置为空数组来禁用此功能。
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters :format => [:json]
    end

    # 默认情况下禁用 JSON 中的根元素。
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
    ```

#### 从视图中的资源助手引用中删除 :cache 和 :concat 选项

* 使用资源管道时，不再使用 :cache 和 :concat 选项，请从视图中删除这些选项。

创建一个 Rails 3.1 应用程序
--------------------------------

```bash
# 您应该已经安装了 'rails' RubyGem
$ rails new myapp
$ cd myapp
```

### 存储 Gems

Rails 现在在应用程序根目录中使用 `Gemfile` 来确定您的应用程序启动所需的 Gems。这个 `Gemfile` 由 [Bundler](https://github.com/carlhuda/bundler) gem 处理，然后安装所有依赖项。它甚至可以将所有依赖项本地安装到您的应用程序中，以便它不依赖于系统 Gems。
更多信息：- [bundler主页](https://bundler.io/)

### 生活在边缘

`Bundler`和`Gemfile`通过新的专用`bundle`命令使冻结Rails应用程序变得非常简单。如果您想直接从Git存储库进行捆绑，可以使用`--edge`标志：

```bash
$ rails new myapp --edge
```

如果您有Rails存储库的本地检出，并希望使用它生成应用程序，可以使用`--dev`标志：

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

Rails架构变化
---------------------------

### 资源管道

Rails 3.1中的主要变化是资源管道。它使CSS和JavaScript成为一流的代码元素，并实现了适当的组织，包括在插件和引擎中使用。

资源管道由[Sprockets](https://github.com/rails/sprockets)提供支持，并在[资源管道](asset_pipeline.html)指南中进行了介绍。

### HTTP流

HTTP流是Rails 3.1中的另一个新变化。这使得浏览器可以在服务器仍在生成响应时下载样式表和JavaScript文件。这需要Ruby 1.9.2，是可选的，并且还需要Web服务器的支持，但是NGINX和Unicorn的流行组合已经准备好利用它。

### 默认的JS库现在是jQuery

jQuery是随Rails 3.1一起提供的默认JavaScript库。但是如果您使用Prototype，切换很简单。

```bash
$ rails new myapp -j prototype
```

### 身份映射

Rails 3.1中的Active Record具有身份映射。身份映射会保留先前实例化的记录，并在再次访问时返回与记录关联的对象。身份映射在每个请求的基础上创建，并在请求完成时刷新。

Rails 3.1默认关闭身份映射。

Railties
--------

* jQuery是新的默认JavaScript库。

* jQuery和Prototype不再是供应商提供的，现在由`jquery-rails`和`prototype-rails`宝石提供。

* 应用程序生成器接受一个`-j`选项，可以是任意字符串。如果传递了"foo"，则会将"foo-rails"宝石添加到`Gemfile`中，并且应用程序JavaScript清单需要"foo"和"foo_ujs"。目前只有"prototype-rails"和"jquery-rails"存在，并通过资源管道提供这些文件。

* 生成应用程序或插件会运行`bundle install`，除非指定了`--skip-gemfile`或`--skip-bundle`。

* 控制器和资源生成器现在会自动产生资产存根（可以使用`--skip-assets`关闭此功能）。如果这些库可用，这些存根将使用CoffeeScript和Sass。

* 脚手架和应用程序生成器在Ruby 1.9上运行时使用Ruby 1.9风格的哈希。要生成旧风格的哈希，可以传递`--old-style-hash`。

* 脚手架控制器生成器为JSON创建格式块，而不是XML。

* Active Record日志记录定向到STDOUT，并在控制台中显示。

* 添加了`config.force_ssl`配置，它加载`Rack::SSL`中间件并强制所有请求在HTTPS协议下。

* 添加了`rails plugin new`命令，它生成带有gemspec、测试和用于测试的虚拟应用程序的Rails插件。

* 默认中间件堆栈中添加了`Rack::Etag`和`Rack::ConditionalGet`。

* 默认中间件堆栈中添加了`Rack::Cache`。

* 引擎进行了重大更新-您可以将它们挂载在任何路径上，启用资源，运行生成器等。

Action Pack
-----------

### Action Controller

* 如果无法验证CSRF令牌的真实性，将发出警告。

* 在控制器中指定`force_ssl`以强制浏览器通过HTTPS协议传输数据。要限制到特定操作，可以使用`:only`或`:except`。

* 在日志中，从请求路径中过滤掉`config.filter_parameters`中指定的敏感查询字符串参数。

* 从查询字符串中删除返回`to_param`为`nil`的URL参数。

* 添加了`ActionController::ParamsWrapper`，将参数包装成嵌套哈希，并在新应用程序的JSON请求中默认启用。可以在`config/initializers/wrap_parameters.rb`中进行自定义。

* 添加了`config.action_controller.include_all_helpers`。默认情况下，在`ActionController::Base`中执行`helper :all`，默认包含所有帮助程序。将`include_all_helpers`设置为`false`将只包含`application_helper`和与控制器对应的帮助程序（例如，foo_controller的foo_helper）。

* `url_for`和命名的URL助手现在接受`：subdomain`和`：domain`作为选项。
* 添加了`Base.http_basic_authenticate_with`方法，可以通过一个类方法调用来进行简单的HTTP基本身份验证。

    ```ruby
    class PostsController < ApplicationController
      USER_NAME, PASSWORD = "dhh", "secret"

      before_filter :authenticate, :except => [ :index ]

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end

      private
        def authenticate
          authenticate_or_request_with_http_basic do |user_name, password|
            user_name == USER_NAME && password == PASSWORD
          end
        end
    end
    ```

    现在可以写成

    ```ruby
    class PostsController < ApplicationController
      http_basic_authenticate_with :name => "dhh", :password => "secret", :except => :index

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end
    end
    ```

* 添加了流式支持，可以通过以下方式启用：

    ```ruby
    class PostsController < ActionController::Base
      stream
    end
    ```

    你可以使用`:only`或者`:except`来限制它只在某些动作中使用。请阅读[`ActionController::Streaming`](https://api.rubyonrails.org/v3.1.0/classes/ActionController/Streaming.html)中的文档获取更多信息。

* 重定向路由方法现在也接受一个选项哈希，该哈希只会改变URL中的特定部分，或者接受一个可以调用的对象，允许重定向被重复使用。

### Action Dispatch

* `config.action_dispatch.x_sendfile_header`现在默认为`nil`，`config/environments/production.rb`没有为其设置任何特定的值。这允许服务器通过`X-Sendfile-Type`来设置它。

* `ActionDispatch::MiddlewareStack`现在使用组合而不是继承，不再是一个数组。

* 添加了`ActionDispatch::Request.ignore_accept_header`来忽略接受头。

* 默认堆栈中添加了`Rack::Cache`。

* 将etag的责任从`ActionDispatch::Response`移动到了中间件堆栈中。

* 依赖于`Rack::Session`存储API以在Ruby世界中更兼容。这是不兼容的，因为`Rack::Session`期望`#get_session`接受四个参数，并且需要`#destroy_session`而不仅仅是`#destroy`。

* 模板查找现在在继承链中搜索更远的位置。

### Action View

* 在`form_tag`中添加了一个`:authenticity_token`选项，用于自定义处理或通过传递`:authenticity_token => false`来省略令牌。

* 创建了`ActionView::Renderer`并为`ActionView::Context`指定了API。

* 在Rails 3.1中禁止了原地`SafeBuffer`的变异。

* 添加了HTML5的`button_tag`辅助方法。

* `file_field`会自动将`multipart => true`添加到封闭的表单中。

* 添加了一种方便的方式，可以从`data`哈希选项中生成HTML5的data-*属性：

    ```ruby
    tag("div", :data => {:name => 'Stephen', :city_state => %w(Chicago IL)})
    # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
    ```

    键会被转换为破折号形式。值会被JSON编码，除了字符串和符号。

* `csrf_meta_tag`被重命名为`csrf_meta_tags`，并为向后兼容性添加了`csrf_meta_tag`的别名。

* 旧的模板处理程序API已被弃用，新的API只需要模板处理程序响应`call`方法。

* rhtml和rxml最终被移除作为模板处理程序。

* `config.action_view.cache_template_loading`被重新引入，可以决定是否缓存模板。

* 提交表单辅助方法不再生成id为"object_name_id"的id。

* 允许`FormHelper#form_for`直接通过选项指定`:method`，而不是通过`html`哈希。例如，`form_for(@post, remote: true, method: :delete)`代替`form_for(@post, remote: true, html: { method: :delete })`。

* 提供了`JavaScriptHelper#j()`作为`JavaScriptHelper#escape_javascript()`的别名。这取代了JSON gem在使用JavaScriptHelper时添加的`Object#j()`方法。

* 允许在日期时间选择器中使用AM/PM格式。

* `auto_link`已从Rails中移除，并提取到[rails_autolink gem](https://github.com/tenderlove/rails_autolink)中。

Active Record
-------------

* 添加了一个类方法`pluralize_table_names`，用于单独模型的单数/复数表名的转换。以前只能通过`ActiveRecord::Base.pluralize_table_names`全局设置所有模型。

    ```ruby
    class User < ActiveRecord::Base
      self.pluralize_table_names = false
    end
    ```

* 添加了对单数关联属性的块设置。该块将在实例初始化后调用。

    ```ruby
    class User < ActiveRecord::Base
      has_one :account
    end

    user.build_account{ |a| a.credit_limit = 100.0 }
    ```

* 添加了`ActiveRecord::Base.attribute_names`，返回属性名称列表。如果模型是抽象的或表不存在，则返回一个空数组。

* CSV Fixture已被弃用，并将在Rails 3.2.0中删除支持。

* `ActiveRecord#new`，`ActiveRecord#create`和`ActiveRecord#update_attributes`都接受第二个哈希作为选项，允许您指定在分配属性时要考虑哪个角色。这是基于Active Model的新的批量赋值功能构建的：
```ruby
class Post < ActiveRecord::Base
  attr_accessible :title
  attr_accessible :title, :published_at, :as => :admin
end

Post.new(params[:post], :as => :admin)
```

* `default_scope` 现在可以接受一个块、lambda 或者任何其他响应 call 方法的对象进行延迟评估。

* 默认作用域现在在最后可能的时刻进行评估，以避免出现创建隐式包含默认作用域的作用域的问题，这样就无法通过 Model.unscoped 来摆脱它。

* PostgreSQL 适配器仅支持 PostgreSQL 版本 8.2 及更高版本。

* `ConnectionManagement` 中间件已更改为在 rack body 刷新后清理连接池。

* 在 Active Record 上添加了一个 `update_column` 方法。这个新方法会跳过验证和回调，直接更新对象上的给定属性。除非你确定不想执行任何回调，包括修改 `updated_at` 列的操作，否则建议使用 `update_attributes` 或 `update_attribute`。它不应该在新记录上调用。

* 带有 `:through` 选项的关联现在可以使用任何关联作为 through 或 source 关联，包括其他具有 `:through` 选项和 `has_and_belongs_to_many` 关联的关联。

* 当前数据库连接的配置现在可以通过 `ActiveRecord::Base.connection_config` 访问。

* 除非同时提供 limits 和 offsets，否则 COUNT 查询中将移除 limits 和 offsets。

```ruby
People.limit(1).count           # => 'SELECT COUNT(*) FROM people'
People.offset(1).count          # => 'SELECT COUNT(*) FROM people'
People.limit(1).offset(1).count # => 'SELECT COUNT(*) FROM people LIMIT 1 OFFSET 1'
```

* `ActiveRecord::Associations::AssociationProxy` 已被拆分。现在有一个负责操作关联的 `Association` 类（和子类），以及一个独立的、薄包装的 `CollectionProxy`，用于代理集合关联。这样可以避免命名空间污染，分离关注点，并允许进一步的重构。

* 单数关联（`has_one`、`belongs_to`）不再有代理，而是直接返回关联的记录或 `nil`。这意味着你不应该使用未记录的方法，如 `bob.mother.create`，而应该使用 `bob.create_mother`。

* 支持在 `has_many :through` 关联上使用 `:dependent` 选项。出于历史和实际原因，`association.delete(*records)` 的默认删除策略是 `:delete_all`，尽管对于常规的 has_many，默认策略是 `:nullify`。此外，这仅在源反射是 belongs_to 的情况下才起作用。对于其他情况，你应该直接修改通过关联。

* `has_and_belongs_to_many` 和 `has_many :through` 的 `association.destroy` 的行为已更改。从现在开始，“destroy”或“delete”关联将被视为“摆脱链接”，而不是（必要地）“摆脱关联记录”。

* 以前，`has_and_belongs_to_many.destroy(*records)` 会销毁记录本身，但不会删除联接表中的任何记录。现在，它会删除联接表中的记录。

* 以前，`has_many_through.destroy(*records)` 会销毁记录本身和联接表中的记录。[注意：这并不总是这样；Rails 的早期版本只删除记录本身。]现在，它只会销毁联接表中的记录。

* 请注意，这个改变在一定程度上是不兼容的，但不幸的是，在改变之前没有办法“弃用”它。这个改变是为了在不同类型的关联中保持“destroy”或“delete”的含义一致。如果你想销毁记录本身，可以使用 `records.association.each(&:destroy)`。

* 在 `change_table` 中添加 `:bulk => true` 选项，以使用单个 ALTER 语句定义的所有模式更改。

```ruby
change_table(:users, :bulk => true) do |t|
  t.string :company_name
  t.change :birthdate, :datetime
end
```

* 不再支持在 `has_and_belongs_to_many` 联接表上访问属性。应该使用 `has_many :through`。

* 为 `has_one` 和 `belongs_to` 关联添加了一个 `create_association!` 方法。

* 迁移现在是可逆的，这意味着 Rails 将找出如何反转你的迁移。要使用可逆迁移，只需定义 `change` 方法。

```ruby
class MyMigration < ActiveRecord::Migration
  def change
    create_table(:horses) do |t|
      t.column :content, :text
      t.column :remind_at, :datetime
    end
  end
end
```

* 有些事情无法自动反转。如果你知道如何反转这些事情，应该在迁移中定义 `up` 和 `down`。如果在 change 中定义了无法反转的内容，当执行向下迁移时将引发 `IrreversibleMigration` 异常。

* 迁移现在使用实例方法而不是类方法：
```ruby
class FooMigration < ActiveRecord::Migration
  def up # 不是 self.up
    # ...
  end
end
```

* 从模型和构造迁移生成器（例如，add_name_to_users）生成的迁移文件使用可逆迁移的 `change` 方法，而不是普通的 `up` 和 `down` 方法。

* 删除了对关联的字符串 SQL 条件进行插值的支持。现在应该使用 proc。

```ruby
has_many :things, :conditions => 'foo = #{bar}'          # 之前
has_many :things, :conditions => proc { "foo = #{bar}" } # 之后
```

在 proc 内部，`self` 是关联所有者的对象，除非你正在急加载关联，此时 `self` 是关联所在的类。

在 proc 内部，可以使用任何“正常”的条件，所以下面的代码也可以工作：

```ruby
has_many :things, :conditions => proc { ["foo = ?", bar] }
```

* 之前，在 `has_and_belongs_to_many` 关联的 `:insert_sql` 和 `:delete_sql` 上允许调用 'record' 来获取正在插入或删除的记录。现在将其作为参数传递给 proc。

* 添加了 `ActiveRecord::Base#has_secure_password`（通过 `ActiveModel::SecurePassword`）来封装使用 BCrypt 加密和加盐的简单密码使用。

```ruby
# Schema: User(name:string, password_digest:string, password_salt:string)
class User < ActiveRecord::Base
  has_secure_password
end
```

* 当生成模型时，默认情况下会为 `belongs_to` 或 `references` 列添加 `add_index`。

* 设置 `belongs_to` 对象的 id 将更新对该对象的引用。

* `ActiveRecord::Base#dup` 和 `ActiveRecord::Base#clone` 的语义已更改，以更接近普通的 Ruby dup 和 clone 语义。

* 调用 `ActiveRecord::Base#clone` 将导致记录的浅复制，包括复制冻结状态。不会调用任何回调。

* 调用 `ActiveRecord::Base#dup` 将复制记录，包括调用 after initialize 钩子。不会复制冻结状态，并且所有关联将被清除。复制的记录将返回 `true` 作为 `new_record?`，具有 `nil` 的 id 字段，并且可以保存。

* 查询缓存现在与预编译语句一起工作，应用程序无需进行任何更改。

Active Model
------------

* `attr_accessible` 接受一个选项 `:as` 来指定一个角色。

* `InclusionValidator`、`ExclusionValidator` 和 `FormatValidator` 现在接受一个选项，可以是 proc、lambda 或任何响应 `call` 的对象。此选项将以当前记录作为参数调用，并返回一个响应 `include?` 的对象（对于 `InclusionValidator` 和 `ExclusionValidator`），或返回一个正则表达式对象（对于 `FormatValidator`）。

* 添加了 `ActiveModel::SecurePassword`，以封装使用 BCrypt 加密和加盐的简单密码使用。

* `ActiveModel::AttributeMethods` 允许按需定义属性。

* 添加了对选择性启用和禁用观察者的支持。

* 不再支持备用的 `I18n` 命名空间查找。

Active Resource
---------------

* 所有请求的默认格式已更改为 JSON。如果要继续使用 XML，则需要在类中设置 `self.format = :xml`。例如，

```ruby
class User < ActiveResource::Base
  self.format = :xml
end
```

Active Support
--------------

* `ActiveSupport::Dependencies` 现在在 `load_missing_constant` 中找到现有常量时引发 `NameError`。

* 添加了一个新的报告方法 `Kernel#quietly`，可以同时静音 `STDOUT` 和 `STDERR`。

* 添加了 `String#inquiry` 作为将字符串转换为 `StringInquirer` 对象的便捷方法。

* 添加了 `Object#in?`，用于测试一个对象是否包含在另一个对象中。

* `LocalCache` 策略现在是一个真正的中间件类，不再是匿名类。

* 引入了 `ActiveSupport::Dependencies::ClassCache` 类，用于保存可重新加载的类的引用。

* `ActiveSupport::Dependencies::Reference` 已重构，以直接利用新的 `ClassCache`。

* 在 Ruby 1.8 中，将 `Range#cover?` 作为 `Range#include?` 的别名进行回退。

* 在 Date/DateTime/Time 中添加了 `weeks_ago` 和 `prev_week`。

* 在 `ActiveSupport::Dependencies.remove_unloadable_constants!` 中添加了 `before_remove_const` 回调。

弃用：

* `ActiveSupport::SecureRandom` 已弃用，推荐使用 Ruby 标准库中的 `SecureRandom`。

Credits
-------

有关为 Rails 做出贡献的许多人的完整列表，请参阅 [Rails 的完整贡献者列表](https://contributors.rubyonrails.org/)。向他们所有人致以赞扬。

Rails 3.1 发布说明由 [Vijay Dev](https://github.com/vijaydev) 编写。
