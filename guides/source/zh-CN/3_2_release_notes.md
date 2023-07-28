**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 30550ed8fa3c0983f3d99a0e91571a98
Ruby on Rails 3.2 发布说明
===============================

Rails 3.2 的亮点：

* 更快的开发模式
* 新的路由引擎
* 自动查询解释
* 标记日志

这些发布说明仅涵盖了主要更改。要了解各种错误修复和更改，请参考更改日志或查看 GitHub 上主要 Rails 存储库中的[提交列表](https://github.com/rails/rails/commits/3-2-stable)。

--------------------------------------------------------------------------------

升级到 Rails 3.2
----------------------

如果您正在升级现有应用程序，在进行升级之前最好有良好的测试覆盖率。如果您尚未升级到 Rails 3.1，请先升级到 Rails 3.1，并确保您的应用程序在预期的情况下运行正常，然后再尝试升级到 Rails 3.2。然后请注意以下更改：

### Rails 3.2 需要至少 Ruby 1.8.7

Rails 3.2 需要 Ruby 1.8.7 或更高版本。官方已经正式停止支持所有先前的 Ruby 版本，您应尽早升级。Rails 3.2 也与 Ruby 1.9.2 兼容。

提示：请注意，Ruby 1.8.7 p248 和 p249 存在导致 Rails 崩溃的序列化错误。自 1.8.7-2010.02 版以来，Ruby Enterprise Edition 已经修复了这些错误。在 1.9 版面前，Ruby 1.9.1 无法使用，因为它会直接导致段错误，所以如果您想使用 1.9.x，建议使用 1.9.2 或 1.9.3 版本。

### 应用程序中需要更新的内容

* 更新您的 `Gemfile` 以依赖于
    * `rails = 3.2.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

* Rails 3.2 弃用了 `vendor/plugins` 目录，Rails 4.0 将完全删除这些目录。您可以通过将这些插件提取为 gems 并将它们添加到您的 `Gemfile` 中来开始替换这些插件。如果您选择不将它们作为 gems 使用，您可以将它们移动到 `lib/my_plugin/*` 目录下，并在 `config/initializers/my_plugin.rb` 中添加适当的初始化器。

* 您需要在 `config/environments/development.rb` 中添加一些新的配置更改：

    ```ruby
    # 对于 Active Record 模型，对批量赋值保护引发异常
    config.active_record.mass_assignment_sanitizer = :strict

    # 记录查询计划，对于执行时间超过此阈值的查询（适用于 SQLite、MySQL 和 PostgreSQL）
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    `mass_assignment_sanitizer` 配置也需要在 `config/environments/test.rb` 中添加：

    ```ruby
    # 对于 Active Record 模型，对批量赋值保护引发异常
    config.active_record.mass_assignment_sanitizer = :strict
    ```

### 引擎中需要更新的内容

将 `script/rails` 中注释下方的代码替换为以下内容：

```ruby
ENGINE_ROOT = File.expand_path('../..', __FILE__)
ENGINE_PATH = File.expand_path('../../lib/your_engine_name/engine', __FILE__)

require "rails/all"
require "rails/engine/commands"
```

创建一个 Rails 3.2 应用程序
--------------------------------

```bash
# 您应该已经安装了 'rails' RubyGem
$ rails new myapp
$ cd myapp
```

### 管理 Gems

Rails 现在使用应用程序根目录中的 `Gemfile` 来确定您的应用程序启动所需的 gems。这个 `Gemfile` 由 [Bundler](https://github.com/carlhuda/bundler) gem 处理，然后安装所有的依赖项。它甚至可以将所有依赖项本地安装到您的应用程序中，这样它就不依赖于系统 gems。

更多信息：[Bundler 主页](https://bundler.io/)

### 实时更新

`Bundler` 和 `Gemfile` 使得使用新的专用 `bundle` 命令冻结 Rails 应用程序变得非常简单。如果您想直接从 Git 存储库进行捆绑，可以传递 `--edge` 标志：

```bash
$ rails new myapp --edge
```

如果您有一个本地的 Rails 存储库副本，并希望使用它生成应用程序，可以传递 `--dev` 标志：

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

主要功能
--------------

### 更快的开发模式和路由

Rails 3.2 提供了一个明显更快的开发模式。受 [Active Reload](https://github.com/paneq/active_reload) 的启发，Rails 仅在文件实际更改时重新加载类。在较大的应用程序上，性能提升非常显著。由于新的 [Journey](https://github.com/rails/journey) 引擎，路由识别速度也大大提高。

### 自动查询解释

Rails 3.2 提供了一个很好的功能，通过在 `ActiveRecord::Relation` 中定义一个 `explain` 方法来解释 Arel 生成的查询。例如，您可以运行类似 `puts Person.active.limit(5).explain` 的命令，然后解释 Arel 生成的查询。这样可以检查正确的索引和进一步的优化。

在开发模式下，自动解释运行时间超过半秒的查询。当然，这个阈值是可以更改的。

### 标记日志
在运行多用户、多账户应用程序时，通过过滤日志来查看谁做了什么是非常有帮助的。Active Support中的TaggedLogging可以通过给日志行添加子域、请求ID和其他任何有助于调试此类应用程序的内容来实现这一点。

文档
-------------

从Rails 3.2开始，Rails指南可在Kindle上使用，并可在iPad、iPhone、Mac、Android等设备上使用免费的Kindle阅读应用程序。

Railties
--------

* 通过仅在依赖文件更改时重新加载类来加快开发速度。可以通过将`config.reload_classes_only_on_change`设置为false来关闭此功能。

* 新应用程序在环境配置文件中获得一个名为`config.active_record.auto_explain_threshold_in_seconds`的标志。在`development.rb`中的值为`0.5`，在`production.rb`中被注释掉。在`test.rb`中没有提及。

* 添加了`config.exceptions_app`来设置异常应用程序，当发生异常时由`ShowException`中间件调用。默认为`ActionDispatch::PublicExceptions.new(Rails.public_path)`。

* 添加了一个`DebugExceptions`中间件，其中包含从`ShowExceptions`中间件中提取的功能。

* 在`rake routes`中显示已挂载引擎的路由。

* 允许使用`config.railties_order`更改railties的加载顺序，例如：

    ```ruby
    config.railties_order = [Blog::Engine, :main_app, :all]
    ```

* 对于没有内容的API请求，脚手架返回204 No Content。这使得脚手架可以直接与jQuery配合使用。

* 更新`Rails::Rack::Logger`中间件，将`config.log_tags`中设置的任何标签应用于`ActiveSupport::TaggedLogging`。这使得可以轻松地为日志行添加调试信息，如子域和请求ID，这在调试多用户生产应用程序时非常有帮助。

* 可以在`~/.railsrc`中设置`rails new`的默认选项。您可以在主目录中的`.railsrc`配置文件中指定要在每次运行`rails new`时使用的额外命令行参数。

* 为`destroy`添加了一个别名`d`。这对于引擎也适用。

* 脚手架和模型生成器的属性默认为字符串。这允许使用以下命令：`bin/rails g scaffold Post title body:text author`

* 允许脚手架/模型/迁移生成器接受“index”和“uniq”修饰符。例如，

    ```bash
    bin/rails g scaffold Post title:string:index author:uniq price:decimal{7,2}
    ```

    将为`title`和`author`创建索引，后者将是唯一索引。某些类型（如decimal）接受自定义选项。在示例中，`price`将是一个精度为7、比例为2的decimal列。

* 从默认的`Gemfile`中删除了turn gem。

* 删除了旧的插件生成器`rails generate plugin`，改用`rails plugin new`命令。

* 删除了旧的`config.paths.app.controller` API，改用`config.paths["app/controller"]`。

### 弃用

* `Rails::Plugin`已弃用，并将在Rails 4.0中删除。不要将插件添加到`vendor/plugins`中，而应使用路径或git依赖项的gems或bundler。

Action Mailer
-------------

* 将`mail`版本升级到2.4.0。

* 删除了自Rails 3.0以来已弃用的旧Action Mailer API。

Action Pack
-----------

### Action Controller

* 将`ActiveSupport::Benchmarkable`作为`ActionController::Base`的默认模块，因此`#benchmark`方法再次在控制器上下文中可用，就像以前一样。

* 在`caches_page`中添加了`:gzip`选项。可以使用`page_cache_compression`全局配置默认选项。

* 当使用`：only`和`：except`条件指定布局时，Rails现在将使用默认布局（例如“layouts/application”）。如果这些条件失败。

    ```ruby
    class CarsController
      layout 'single_car', :only => :show
    end
    ```

    当请求进入`：show`动作时，Rails将使用`layouts/single_car`，当请求进入其他任何动作时，将使用`layouts/application`（或`layouts/cars`，如果存在）。

* 如果提供了`:as`选项，`form_for`将使用`#{action}_#{as}`作为CSS类和id。早期版本使用`#{as}_#{action}`。

* 在Active Record模型上的`ActionController::ParamsWrapper`现在只包装`attr_accessible`属性，如果它们被设置。如果没有设置，只有由类方法`attribute_names`返回的属性将被包装。这通过将嵌套属性添加到`attr_accessible`来修复了嵌套属性的包装问题。

* 每次在回调之前中止时，记录“Filter chain halted as CALLBACKNAME rendered or redirected”。

* 重构了`ActionDispatch::ShowExceptions`。控制器负责选择是否显示异常。可以在控制器中重写`show_detailed_exceptions?`来指定哪些请求应在错误时提供调试信息。

* Responders现在对于没有响应体的API请求返回204 No Content（与新的脚手架一样）。

* 重构了`ActionController::TestCase`的cookies。现在，为测试用例分配cookies应该使用`cookies[]`
```ruby
cookies[:email] = 'user@example.com'
get :index
assert_equal 'user@example.com', cookies[:email]
```

要清除cookies，请使用`clear`。

```ruby
cookies.clear
get :index
assert_nil cookies[:email]
```

我们现在不再写出HTTP_COOKIE，cookie jar在请求之间是持久的，所以如果您需要在测试中操作环境，您需要在创建cookie jar之前进行操作。

* 如果没有提供`:type`，`send_file`现在会根据文件扩展名猜测MIME类型。

* 添加了PDF、ZIP和其他格式的MIME类型条目。

* 允许`fresh_when/stale?`接受一个记录而不是选项哈希。

* 将缺少CSRF令牌的警告日志级别从`:debug`更改为`:warn`。

* 默认情况下，资源应该使用请求协议，如果没有请求可用，则默认为相对路径。

#### 弃用

* 弃用了在父控制器中设置了显式布局的控制器中的隐含布局查找：

```ruby
class ApplicationController
  layout "application"
end

class PostsController < ApplicationController
end
```

在上面的示例中，`PostsController`将不再自动查找posts布局。如果您需要此功能，可以从`ApplicationController`中删除`layout "application"`，或在`PostsController`中将其明确设置为`nil`。

* 弃用了`ActionController::UnknownAction`，改用`AbstractController::ActionNotFound`。

* 弃用了`ActionController::DoubleRenderError`，改用`AbstractController::DoubleRenderError`。

* 弃用了`method_missing`，改用`action_missing`来处理缺少的操作。

* 弃用了`ActionController#rescue_action`、`ActionController#initialize_template_class`和`ActionController#assign_shortcuts`。

### Action Dispatch

* 添加`config.action_dispatch.default_charset`以配置`ActionDispatch::Response`的默认字符集。

* 添加了`ActionDispatch::RequestId`中间件，它将使唯一的X-Request-Id标头可用于响应，并启用`ActionDispatch::Request#uuid`方法。这使得在堆栈中从端到端跟踪请求变得容易，并且可以在混合日志（如Syslog）中识别单个请求。

* `ShowExceptions`中间件现在接受一个异常应用程序，该应用程序负责在应用程序失败时呈现异常。应用程序使用`env["action_dispatch.exception"]`中的异常副本调用，并将`PATH_INFO`重写为状态码。

* 允许通过railtie配置救援响应，如`config.action_dispatch.rescue_responses`。

#### 弃用

* 弃用了在控制器级别设置默认字符集的能力，改用新的`config.action_dispatch.default_charset`。

### Action View

* 在`ActionView::Helpers::FormBuilder`中添加了对`button_tag`的支持。此支持模仿了`submit_tag`的默认行为。

```erb
<%= form_for @post do |f| %>
  <%= f.button %>
<% end %>
```

* 日期助手接受一个新选项`:use_two_digit_numbers => true`，它会在月份和日期的选择框中添加前导零，而不改变相应的值。例如，这对于显示ISO 8601风格的日期（如'2011-08-01'）非常有用。

* 您可以为表单提供一个命名空间，以确保表单元素的id属性的唯一性。生成的HTML id上的命名空间属性将以下划线为前缀。

```erb
<%= form_for(@offer, :namespace => 'namespace') do |f| %>
  <%= f.label :version, 'Version' %>:
  <%= f.text_field :version %>
<% end %>
```

* 将`select_year`的选项数量限制为1000。通过传递`:max_years_allowed`选项来设置自己的限制。

* `content_tag_for`和`div_for`现在可以接受一组记录。如果在块中设置了接收参数，它还将将记录作为第一个参数传递。所以，不再需要这样做：

```ruby
@items.each do |item|
  content_tag_for(:li, item) do
    Title: <%= item.title %>
  end
end
```

可以这样做：

```ruby
content_tag_for(:li, @items) do |item|
  Title: <%= item.title %>
end
```

* 添加了`font_path`辅助方法，用于计算`public/fonts`中字体资源的路径。

#### 弃用

* 弃用了将格式或处理程序传递给`render :template`等的能力，改用直接提供`handlers`和`formats`作为选项：`render :template => "foo", :formats => [:html, :js], :handlers => :erb`。

### Sprockets

* 添加了一个配置选项`config.assets.logger`来控制Sprockets的日志记录。将其设置为`false`可关闭日志记录，将其设置为`nil`可默认使用`Rails.logger`。

Active Record
-------------

* 具有'on'和'ON'值的布尔列将被类型转换为true。

* 当`timestamps`方法创建`created_at`和`updated_at`列时，默认情况下将它们设置为非空。

* 实现了`ActiveRecord::Relation#explain`。

* 实现了`ActiveRecord::Base.silence_auto_explain`，允许用户在块内选择性地禁用自动EXPLAIN。

* 对于慢查询，实现了自动EXPLAIN日志记录。新的配置参数`config.active_record.auto_explain_threshold_in_seconds`确定什么被认为是慢查询。将其设置为nil将禁用此功能。在开发模式下，默认值为0.5，在测试和生产模式下为nil。Rails 3.2在SQLite、MySQL（mysql2适配器）和PostgreSQL中支持此功能。
* 添加了`ActiveRecord::Base.store`用于声明简单的单列键/值存储。

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [ :color, :homepage ]
    end

    u = User.new(color: 'black', homepage: '37signals.com')
    u.color                          # 存储属性的访问器
    u.settings[:country] = 'Denmark' # 任何属性，即使没有在访问器中指定
    ```

* 添加了只针对给定范围运行迁移的能力，这允许只从一个引擎运行迁移（例如，从需要删除的引擎中还原更改）。

    ```
    rake db:migrate SCOPE=blog
    ```

* 从引擎中复制的迁移现在以引擎的名称为范围，例如`01_create_posts.blog.rb`。

* 实现了`ActiveRecord::Relation#pluck`方法，直接从底层表中返回列值的数组。这也适用于序列化属性。

    ```ruby
    Client.where(:active => true).pluck(:id)
    # SELECT id from clients where active = 1
    ```

* 生成的关联方法被创建在一个单独的模块中，以允许重写和组合。对于一个名为MyModel的类，该模块的名称为`MyModel::GeneratedFeatureMethods`。它被立即包含到模型类中，在Active Model中定义的`generated_attributes_methods`模块之后，因此关联方法会覆盖同名的属性方法。

* 添加了`ActiveRecord::Relation#uniq`用于生成唯一查询。

    ```ruby
    Client.select('DISTINCT name')
    ```

    ..可以写成:

    ```ruby
    Client.select(:name).uniq
    ```

    这也允许在关系中撤销唯一性:

    ```ruby
    Client.select(:name).uniq.uniq(false)
    ```

* 在SQLite、MySQL和PostgreSQL适配器中支持索引排序顺序。

* 允许关联的`:class_name`选项接受一个符号，而不仅仅是一个字符串。这是为了避免混淆新手，并与其他选项（如`:foreign_key`）允许符号或字符串一致。

    ```ruby
    has_many :clients, :class_name => :Client # 注意符号需要大写
    ```

* 在开发模式中，`db:drop`也会删除测试数据库，以与`db:create`对称。

* 不区分大小写的唯一性验证在MySQL中避免了在列已经使用不区分大小写的排序规则时调用LOWER。

* 事务性固定装置登记所有活动数据库连接。您可以在不禁用事务性固定装置的情况下在不同的连接上测试模型。

* 在Active Record中添加了`first_or_create`、`first_or_create!`、`first_or_initialize`方法。这是比旧的`find_or_create_by`动态方法更好的方法，因为它更清楚地指定了用于查找记录和用于创建记录的参数。

    ```ruby
    User.where(:first_name => "Scarlett").first_or_create!(:last_name => "Johansson")
    ```

* 在Active Record对象中添加了`with_lock`方法，它启动一个事务，锁定对象（悲观锁），并传递给块。该方法接受一个（可选的）参数，并将其传递给`lock!`。

    这使得可以这样写：

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        transaction do
          lock!
          # ... 取消逻辑
        end
      end
    end
    ```

    如下所示：

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        with_lock do
          # ... 取消逻辑
        end
      end
    end
    ```

### 弃用

* 自动关闭线程中的连接已被弃用。例如，以下代码已被弃用：

    ```ruby
    Thread.new { Post.find(1) }.join
    ```

    应该将其更改为在线程结束时关闭数据库连接：

    ```ruby
    Thread.new {
      Post.find(1)
      Post.connection.close
    }.join
    ```

    只有在应用程序代码中生成线程的人需要担心这个变化。

* `set_table_name`、`set_inheritance_column`、`set_sequence_name`、`set_primary_key`、`set_locking_column`方法已被弃用。使用赋值方法代替。例如，使用`self.table_name=`代替`set_table_name`。

    ```ruby
    class Project < ActiveRecord::Base
      self.table_name = "project"
    end
    ```

    或者定义自己的`self.table_name`方法：

    ```ruby
    class Post < ActiveRecord::Base
      def self.table_name
        "special_" + super
      end
    end

    Post.table_name # => "special_posts"
    ```

Active Model
------------

* 添加了`ActiveModel::Errors#added?`方法，用于检查是否已添加了特定的错误。

* 添加了使用`strict => true`定义严格验证的能力，当验证失败时始终引发异常。

* 提供了`mass_assignment_sanitizer`作为一个易于使用的API来替换清理器行为。还支持`logger`（默认）和`strict`清理器行为。

### 弃用

* 在`ActiveModel::AttributeMethods`中弃用了`define_attr_method`，因为它只存在于支持Active Record中的`set_table_name`等方法，而这些方法本身已被弃用。

* 在`ActiveModel::Naming`中弃用了`Model.model_name.partial_path`，改用`model.to_partial_path`。

Active Resource
---------------

* 重定向响应：303 See Other和307 Temporary Redirect现在的行为类似于301 Moved Permanently和302 Found。

Active Support
--------------

* 添加了`ActiveSupport:TaggedLogging`，可以包装任何标准的`Logger`类以提供标记功能。

    ```ruby
    Logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    Logger.tagged("BCX") { Logger.info "Stuff" }
    # 记录 "[BCX] Stuff"

    Logger.tagged("BCX", "Jason") { Logger.info "Stuff" }
    # 记录 "[BCX] [Jason] Stuff"

    Logger.tagged("BCX") { Logger.tagged("Jason") { Logger.info "Stuff" } }
    # 记录 "[BCX] [Jason] Stuff"
    ```
* `Date`、`Time`和`DateTime`中的`beginning_of_week`方法接受一个可选参数，表示假定一周从哪一天开始。

* `ActiveSupport::Notifications.subscribed`提供了在块运行时订阅事件的功能。

* 定义了新的方法`Module#qualified_const_defined?`、`Module#qualified_const_get`和`Module#qualified_const_set`，它们类似于标准API中的相应方法，但接受限定的常量名称。

* 添加了`#deconstantize`，它与inflections中的`#demodulize`相对应。它从限定的常量名称中移除最右边的部分。

* 添加了`safe_constantize`，它将字符串转换为常量，但如果常量（或其中的一部分）不存在，则返回`nil`而不是引发异常。

* 当使用`Array#extract_options!`时，现在将`ActiveSupport::OrderedHash`标记为可提取。

* 添加了`Array#prepend`作为`Array#unshift`的别名，以及`Array#append`作为`Array#<<`的别名。

* 对于Ruby 1.9，空字符串的定义已扩展到Unicode空白字符。此外，在Ruby 1.8中，表意空格U`3000被视为空白字符。

* inflector理解首字母缩略词。

* 添加了`Time#all_day`、`Time#all_week`、`Time#all_quarter`和`Time#all_year`作为生成范围的方法。

    ```ruby
    Event.where(:created_at => Time.now.all_week)
    Event.where(:created_at => Time.now.all_day)
    ```

* 添加了`instance_accessor: false`作为`Class#cattr_accessor`和相关方法的选项。

* 当给定一个接受参数的块时，`ActiveSupport::OrderedHash`的`#each`和`#each_pair`现在具有不同的行为。

* 添加了`ActiveSupport::Cache::NullStore`，用于开发和测试。

* 删除了`ActiveSupport::SecureRandom`，改用标准库中的`SecureRandom`。

### 弃用

* 弃用了`ActiveSupport::Base64`，推荐使用`::Base64`。

* 弃用了`ActiveSupport::Memoizable`，推荐使用Ruby的记忆化模式。

* 弃用了`Module#synchronize`，没有替代方法。请使用Ruby标准库中的monitor。

* 弃用了`ActiveSupport::MessageEncryptor#encrypt`和`ActiveSupport::MessageEncryptor#decrypt`。

* 弃用了`ActiveSupport::BufferedLogger#silence`。如果要在某个块中禁止日志记录，请更改该块的日志级别。

* 弃用了`ActiveSupport::BufferedLogger#open_log`。这个方法本来就不应该是公开的。

* 弃用了`ActiveSupport::BufferedLogger`自动创建日志文件目录的行为。请确保在实例化之前创建日志文件的目录。

* 弃用了`ActiveSupport::BufferedLogger#auto_flushing`。要么在底层文件句柄上设置同步级别，要么调整文件系统。现在刷新由文件系统缓存控制。

    ```ruby
    f = File.open('foo.log', 'w')
    f.sync = true
    ActiveSupport::BufferedLogger.new f
    ```

* 弃用了`ActiveSupport::BufferedLogger#flush`。设置文件句柄的同步，或调整文件系统。

致谢
-------

请参阅[Rails的完整贡献者列表](http://contributors.rubyonrails.org/)，感谢那些花费了很多时间使Rails成为稳定和强大的框架的人。向他们致敬。

Rails 3.2发布说明由[Vijay Dev](https://github.com/vijaydev)编写。
