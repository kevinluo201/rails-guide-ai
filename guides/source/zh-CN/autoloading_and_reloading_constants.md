**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f53b3a12c263256fbbe154cfc8b2f4d
自动加载和重新加载常量
=======================

本指南记录了`zeitwerk`模式下自动加载和重新加载的工作原理。

阅读本指南后，您将了解以下内容：

* 相关的Rails配置
* 项目结构
* 自动加载、重新加载和急加载
* 单表继承
* 以及更多

--------------------------------------------------------------------------------

介绍
----

INFO. 本指南记录了Rails应用程序中的自动加载、重新加载和急加载。

在普通的Ruby程序中，您需要显式加载定义类和模块的文件。例如，以下控制器引用了`ApplicationController`和`Post`，您通常会为它们发出`require`调用：

```ruby
# 不要这样做。
require "application_controller"
require "post"
# 不要这样做。

class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

但在Rails应用程序中，应用程序的类和模块可以在任何地方使用，无需`require`调用：

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

如果需要，Rails会自动为您加载它们。这得益于Rails为您设置的一对[Zeitwerk](https://github.com/fxn/zeitwerk)加载器，它们提供了自动加载、重新加载和急加载的功能。

另一方面，这些加载器不管理其他任何内容。特别是，它们不管理Ruby标准库、gem依赖、Rails组件本身，甚至（默认情况下）不管理应用程序的`lib`目录。这些代码必须像往常一样加载。

项目结构
--------

在Rails应用程序中，文件名必须与它们定义的常量匹配，目录充当命名空间。

例如，文件`app/helpers/users_helper.rb`应该定义`UsersHelper`，文件`app/controllers/admin/payments_controller.rb`应该定义`Admin::PaymentsController`。

默认情况下，Rails配置了Zeitwerk，使用`String#camelize`来推断文件名。例如，它期望`app/controllers/users_controller.rb`定义常量`UsersController`，因为`"users_controller".camelize`返回的就是这个值。

下面的“自定义推断”部分记录了覆盖此默认值的方法。

请参阅[Zeitwerk文档](https://github.com/fxn/zeitwerk#file-structure)了解更多详细信息。

config.autoload_paths
---------------------

我们将要自动加载和（可选）重新加载其内容的应用程序目录列表称为_自动加载路径_。例如，`app/models`。这些目录代表根命名空间：`Object`。

INFO. Zeitwerk文档中将自动加载路径称为_根目录_，但在本指南中我们将使用“自动加载路径”。

在自动加载路径中，文件名必须与它们定义的常量匹配，如[此处](https://github.com/fxn/zeitwerk#file-structure)所述。

默认情况下，应用程序的自动加载路径包括在应用程序启动时存在的`app`的所有子目录 ---除了`assets`、`javascript`和`views`--- 以及它可能依赖的引擎的自动加载路径。

例如，如果`UsersHelper`在`app/helpers/users_helper.rb`中实现，那么该模块是可自动加载的，您不需要（也不应该）为其编写`require`调用：

```bash
$ bin/rails runner 'p UsersHelper'
UsersHelper
```

Rails会自动将`app`下的自定义目录添加到自动加载路径中。例如，如果您的应用程序有`app/presenters`，您无需进行任何配置即可自动加载presenters；它可以直接使用。

默认自动加载路径的数组可以通过在`config/application.rb`或`config/environments/*.rb`中将其推入`config.autoload_paths`来扩展。例如：

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_paths << "#{root}/extras"
  end
end
```

此外，引擎可以在引擎类的主体和它们自己的`config/environments/*.rb`中推入。

WARNING. 请不要修改`ActiveSupport::Dependencies.autoload_paths`；更改自动加载路径的公共接口是`config.autoload_paths`。

WARNING: 在应用程序启动时，不能在自动加载路径中自动加载代码。特别是在`config/initializers/*.rb`中直接加载。请查看下面的[_应用程序启动时的自动加载_](#autoloading-when-the-application-boots)以了解有效的方法。

自动加载路径由`Rails.autoloaders.main`自动加载器管理。

config.autoload_lib(ignore:)
----------------------------

默认情况下，`lib`目录不属于应用程序或引擎的自动加载路径。

配置方法`config.autoload_lib`将`lib`目录添加到`config.autoload_paths`和`config.eager_load_paths`中。它必须在`config/application.rb`或`config/environments/*.rb`中调用，并且对于引擎不可用。

通常，`lib`目录下有一些子目录不应由自动加载器管理。请在`ignore`关键字参数中传递相对于`lib`的名称。例如：

```ruby
config.autoload_lib(ignore: %w(assets tasks))
```

为什么？虽然`assets`和`tasks`与常规代码共享`lib`目录，但它们的内容不应自动加载或急加载。`Assets`和`Tasks`在这里不是Ruby命名空间。如果有生成器，也是一样的：
```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

在7.1之前，`config.autoload_lib`是不可用的，但只要应用程序使用Zeitwerk，您仍然可以模拟它：

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.main.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

config.autoload_once_paths
--------------------------

您可能希望能够自动加载类和模块而无需重新加载它们。`autoload_once_paths`配置存储可以自动加载但不会重新加载的代码。

默认情况下，此集合为空，但您可以通过将其推送到`config.autoload_once_paths`来扩展它。您可以在`config/application.rb`或`config/environments/*.rb`中这样做。例如：

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_once_paths << "#{root}/app/serializers"
  end
end
```

此外，引擎可以在引擎类的主体和它们自己的`config/environments/*.rb`中推送。

INFO. 如果将`app/serializers`推送到`config.autoload_once_paths`，Rails将不再将其视为自动加载路径，尽管它是`app`下的自定义目录。此设置覆盖了该规则。

这对于在重新加载后仍然存在的位置缓存的类和模块非常重要，例如Rails框架本身。

例如，Active Job序列化器存储在Active Job内部：

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

而Active Job本身在重新加载时不会重新加载，只有应用程序和引擎代码在自动加载路径中的代码会重新加载。

使`MoneySerializer`可重新加载将会很困惑，因为重新加载编辑后的版本对存储在Active Job中的类对象没有任何影响。实际上，如果`MoneySerializer`是可重新加载的，在Rails 7开始，此类初始化程序将引发`NameError`。

另一个用例是引擎装饰框架类：

```ruby
initializer "decorate ActionController::Base" do
  ActiveSupport.on_load(:action_controller_base) do
    include MyDecoration
  end
end
```

在那里，初始化程序运行时由`MyDecoration`存储的模块对象成为`ActionController::Base`的祖先，并且重新加载`MyDecoration`是没有意义的，它不会影响该祖先链。

可以在`config/initializers`中自动加载一次路径中的类和模块。因此，使用该配置，以下内容有效：

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

INFO：从技术上讲，您可以在运行`：bootstrap_hook`之后的任何初始化程序中自动加载由`once`自动加载程序管理的类和模块。

自动加载一次路径由`Rails.autoloaders.once`管理。

config.autoload_lib_once(ignore:)
---------------------------------

`config.autoload_lib_once`方法类似于`config.autoload_lib`，只是它将`lib`添加到`config.autoload_once_paths`而不是`config.autoload_paths`。它必须从`config/application.rb`或`config/environments/*.rb`中调用，对于引擎不可用。

通过调用`config.autoload_lib_once`，可以自动加载`lib`中的类和模块，甚至可以从应用程序初始化程序中进行加载，但不会重新加载。

在7.1之前，`config.autoload_lib_once`是不可用的，但只要应用程序使用Zeitwerk，您仍然可以模拟它：

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_once_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.once.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

$LOAD_PATH{#load_path}
----------

默认情况下，自动加载路径会添加到`$LOAD_PATH`中。但是，Zeitwerk在内部使用绝对文件名，并且您的应用程序不应为可自动加载的文件发出`require`调用，因此实际上不需要这些目录。您可以使用此标志选择退出：

```ruby
config.add_autoload_paths_to_load_path = false
```

这可能会加快合法的`require`调用，因为查找次数较少。此外，如果您的应用程序使用[Bootsnap](https://github.com/Shopify/bootsnap)，这将使库免于构建不必要的索引，从而降低内存使用。

此标志不会影响`lib`目录，它始终会添加到`$LOAD_PATH`中。

重新加载
---------

如果自动加载路径中的应用程序文件发生更改，Rails会自动重新加载类和模块。

更具体地说，如果Web服务器正在运行并且应用程序文件已被修改，则Rails会在处理下一个请求之前卸载由`main`自动加载程序管理的所有自动加载的常量。这样，在该请求期间使用的应用程序类或模块将再次自动加载，从而获取文件系统中的当前实现。

可以启用或禁用重新加载。控制此行为的设置是[`config.enable_reloading`][]，在`development`模式下默认为`true`，在`production`模式下默认为`false`。为了向后兼容，Rails还支持`config.cache_classes`，它等效于`!config.enable_reloading`。

Rails默认使用事件驱动的文件监视器来检测文件更改。可以将其配置为通过遍历自动加载路径来检测文件更改。这由[`config.file_watcher`][]设置控制。

在Rails控制台中，无论`config.enable_reloading`的值如何，都不会激活文件监视器。这是因为通常在控制台会话中重新加载代码会很困惑。与单个请求类似，通常希望控制台会话由一组一致且不变的应用程序类和模块提供服务。
然而，您可以在控制台中执行`reload!`来强制重新加载：

```irb
irb(main):001:0> User.object_id
=> 70136277390120
irb(main):002:0> reload!
Reloading...
=> true
irb(main):003:0> User.object_id
=> 70136284426020
```

如您所见，在重新加载后，存储在`User`常量中的类对象发生了变化。


### 重新加载和过时对象

非常重要的一点是，Ruby没有一种真正重新加载内存中的类和模块，并在它们已经被使用的所有地方都反映出来的方法。从技术上讲，“卸载”`User`类意味着通过`Object.send(:remove_const, "User")`删除`User`常量。

例如，看看这个Rails控制台会话：

```irb
irb> joe = User.new
irb> reload!
irb> alice = User.new
irb> joe.class == alice.class
=> false
```

`joe`是原始`User`类的一个实例。当重新加载时，`User`常量会评估为一个不同的、重新加载的类。`alice`是新加载的`User`的一个实例，但`joe`不是——他的类是过时的。您可以重新定义`joe`，启动一个IRB子会话，或者只需启动一个新的控制台，而不是调用`reload!`。

您可能会在一个不重新加载的地方子类化可重新加载的类时遇到这个陷阱的另一种情况：

```ruby
# lib/vip_user.rb
class VipUser < User
end
```

如果重新加载`User`，由于`VipUser`没有重新加载，`VipUser`的超类是原始的过时类对象。

底线是：**不要缓存可重新加载的类或模块**。

## 应用程序启动时的自动加载

在启动过程中，应用程序可以从`autoload_once_paths`中的路径进行自动加载，这些路径由`once`自动加载器管理。请参阅上面的[`config.autoload_once_paths`](#config-autoload-once-paths)部分。

但是，您不能从`autoload_paths`中的路径进行自动加载，这些路径由`main`自动加载器管理。这适用于`config/initializers`中的代码以及应用程序或引擎的初始化器。

为什么呢？初始化器只在应用程序启动时运行一次。它们不会在重新加载时再次运行。如果初始化器使用了可重新加载的类或模块，对它们的编辑将不会反映在初始代码中，从而变得过时。因此，在初始化期间引用可重新加载的常量是不允许的。

让我们看看应该做什么。

### 用例1：在启动期间加载可重新加载的代码

#### 在启动和每次重新加载时自动加载

假设`ApiGateway`是一个可重新加载的类，您需要在应用程序启动时配置其端点：

```ruby
# config/initializers/api_gateway_setup.rb
ApiGateway.endpoint = "https://example.com" # NameError
```

初始化器不能引用可重新加载的常量，您需要将其包装在一个`to_prepare`块中，该块在启动时和每次重新加载后运行：

```ruby
# config/initializers/api_gateway_setup.rb
Rails.application.config.to_prepare do
  ApiGateway.endpoint = "https://example.com" # CORRECT
end
```

注意：出于历史原因，此回调可能会运行两次。它执行的代码必须是幂等的。

#### 仅在启动时自动加载

可重新加载的类和模块也可以在`after_initialize`块中进行自动加载。这些块在启动时运行，但在重新加载时不会再次运行。在某些特殊情况下，这可能是您想要的。

预检查是这种情况的一个用例：

```ruby
# config/initializers/check_admin_presence.rb
Rails.application.config.after_initialize do
  unless Role.where(name: "admin").exists?
    abort "The admin role is not present, please seed the database."
  end
end
```

### 用例2：在启动期间加载保持缓存的代码

某些配置接受类或模块对象，并将其存储在不重新加载的位置。重要的是，这些对象不能重新加载，因为对它们的编辑不会反映在这些缓存的过时对象中。

一个例子是中间件：

```ruby
config.middleware.use MyApp::Middleware::Foo
```

当您重新加载时，中间件堆栈不受影响，因此将`MyApp::Middleware::Foo`设置为可重新加载会令人困惑。对其实现的更改将不会产生任何效果。

另一个例子是Active Job序列化器：

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

在初始化期间，无论`MoneySerializer`评估为什么，它都会被推送到自定义序列化器中，并且在重新加载时保持不变。

还有一个例子是railties或引擎通过包含模块来装饰框架类。例如，[`turbo-rails`](https://github.com/hotwired/turbo-rails)以这种方式装饰`ActiveRecord::Base`：

```ruby
initializer "turbo.broadcastable" do
  ActiveSupport.on_load(:active_record) do
    include Turbo::Broadcastable
  end
end
```

这将在`ActiveRecord::Base`的祖先链中添加一个模块对象。如果重新加载，对`Turbo::Broadcastable`的更改将不会产生任何效果，祖先链仍将具有原始的模块对象。

推论：这些类或模块**不能重新加载**。

在启动期间引用这些类或模块的最简单方法是将它们定义在不属于自动加载路径的目录中。例如，`lib`是一个惯用的选择。它默认不属于自动加载路径，但它属于`$LOAD_PATH`。只需执行常规的`require`来加载它。
如上所述，另一个选项是在自动加载一次路径和自动加载中定义它们的目录。有关详细信息，请查看[config.autoload_once_paths](#config-autoload-once-paths)部分。

### 用例3：为引擎配置应用程序类

假设一个引擎使用可重新加载的应用程序类来建模用户，并为其配置了一个配置点：

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = User # NameError
end
```

为了与可重新加载的应用程序代码良好配合，引擎需要应用程序配置该类的名称：

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = "User" # OK
end
```

然后，在运行时，`config.user_model.constantize`将给出当前的类对象。

急切加载
-------------

在类似生产环境的环境中，最好在应用程序启动时加载所有应用程序代码。急切加载将所有内容放入内存中，以便立即响应请求，并且还支持[写时复制](https://en.wikipedia.org/wiki/Copy-on-write)。

急切加载由标志[`config.eager_load`]控制，默认情况下在除`production`以外的所有环境中禁用。当执行Rake任务时，`config.eager_load`被[`config.rake_eager_load`]覆盖，默认值为`false`。因此，默认情况下，在生产环境中，Rake任务不会急切加载应用程序。

文件的急切加载顺序是未定义的。

在急切加载期间，Rails调用`Zeitwerk::Loader.eager_load_all`。这确保了由Zeitwerk管理的所有gem依赖项也会被急切加载。

单表继承
------------------------

单表继承与延迟加载不兼容：Active Record必须了解STI层次结构才能正常工作，但是在延迟加载时，类只会在需要时加载！

为了解决这个根本性的不匹配，我们需要预加载STI。有几种选项可以实现这一点，具有不同的权衡。让我们来看看它们。

### 选项1：启用急切加载

预加载STI的最简单方法是通过设置：

```ruby
config.eager_load = true
```

在`config/environments/development.rb`和`config/environments/test.rb`中。

这很简单，但可能代价高昂，因为它会在启动时和每次重新加载时急切加载整个应用程序。然而，对于小型应用程序来说，这种权衡可能是值得的。

### 选项2：预加载折叠目录

将定义层次结构的文件存储在一个专用目录中，这在概念上也是有意义的。该目录不是用来表示命名空间的，它的唯一目的是将STI分组：

```
app/models/shapes/shape.rb
app/models/shapes/circle.rb
app/models/shapes/square.rb
app/models/shapes/triangle.rb
```

在这个例子中，我们仍然希望`app/models/shapes/circle.rb`定义`Circle`，而不是`Shapes::Circle`。这可能是您个人偏好的简化事物的方式，也避免了现有代码库中的重构。Zeitwerk的[折叠](https://github.com/fxn/zeitwerk#collapsing-directories)功能允许我们这样做：

```ruby
# config/initializers/preload_stis.rb

shapes = "#{Rails.root}/app/models/shapes"
Rails.autoloaders.main.collapse(shapes) # 不是命名空间。

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir(shapes)
  end
end
```

在这个选项中，我们在启动时急切加载这几个文件，即使未使用STI也会重新加载。然而，除非您的应用程序有很多STI，否则这不会有任何可衡量的影响。

INFO：`Zeitwerk::Loader#eager_load_dir`方法是在Zeitwerk 2.6.2中添加的。对于旧版本，仍然可以列出`app/models/shapes`目录，并在其内容上调用`require_dependency`。

WARNING：如果从STI中添加、修改或删除模型，重新加载将按预期工作。但是，如果在应用程序中添加了一个新的独立的STI层次结构，您将需要编辑初始化程序并重新启动服务器。

### 选项3：预加载常规目录

与上一个选项类似，但该目录被认为是一个命名空间。也就是说，`app/models/shapes/circle.rb`应该定义`Shapes::Circle`。

对于这个选项，初始化程序是相同的，只是没有配置折叠：

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/shapes")
  end
end
```

相同的权衡。

### 选项4：从数据库预加载类型

在这个选项中，我们不需要以任何方式组织文件，但是会访问数据库：

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    types = Shape.unscoped.select(:type).distinct.pluck(:type)
    types.compact.each(&:constantize)
  end
end
```

WARNING：即使表中没有所有类型，STI也能正常工作，但是`subclasses`或`descendants`等方法将不会返回缺失的类型。

WARNING：如果从STI中添加、修改或删除模型，重新加载将按预期工作。但是，如果在应用程序中添加了一个新的独立的STI层次结构，您将需要编辑初始化程序并重新启动服务器。
自定义词形变化
-----------------------

默认情况下，Rails使用`String#camelize`来确定给定文件或目录名应该定义哪个常量。例如，`posts_controller.rb`应该定义`PostsController`，因为`"posts_controller".camelize`返回的结果是这样的。

可能有某些特定的文件或目录名不按照您的要求进行词形变化。例如，默认情况下，`html_parser.rb`应该定义`HtmlParser`。如果您更喜欢类名为`HTMLParser`，有几种方法可以自定义此操作。

最简单的方法是定义首字母缩略词：

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "HTML"
  inflect.acronym "SSL"
end
```

这样做会全局影响Active Support的词形变化。在某些应用程序中可能没问题，但您也可以通过将一组覆盖项传递给默认的词形变化器，来独立自定义如何对单个基本名称进行词形变化：

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

尽管如此，这种技术仍然依赖于`String#camelize`，因为默认的词形变化器会使用它作为后备。如果您不想依赖Active Support的词形变化，并且对词形变化有绝对控制，可以将词形变化器配置为`Zeitwerk::Inflector`的实例：

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector = Zeitwerk::Inflector.new
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

没有全局配置可以影响这些实例；它们是确定性的。

您甚至可以定义一个自定义的词形变化器以获得完全的灵活性。请查看[Zeitwerk文档](https://github.com/fxn/zeitwerk#custom-inflector)以获取更多详细信息。

### 词形变化自定义应放在何处？

如果应用程序不使用`once`自动加载器，则上述代码片段可以放在`config/initializers`目录中。例如，对于Active Support的用例，可以放在`config/initializers/inflections.rb`中，对于其他用例，可以放在`config/initializers/zeitwerk.rb`中。

使用`once`自动加载器的应用程序必须将此配置从`config/application.rb`文件中的应用程序类主体中移动或加载，因为`once`自动加载器在引导过程的早期使用词形变化器。

自定义命名空间
-----------------

如上所述，自动加载路径表示顶级命名空间：`Object`。

例如，考虑`app/services`目录。默认情况下，此目录不会被自动生成，但如果存在，Rails会自动将其添加到自动加载路径中。

默认情况下，文件`app/services/users/signup.rb`应该定义`Users::Signup`，但如果您希望整个子树位于`Services`命名空间下，该怎么办呢？在默认设置下，可以通过创建一个子目录`app/services/services`来实现这一目标。

然而，根据您的喜好，这可能不符合您的期望。您可能更喜欢`app/services/users/signup.rb`简单地定义`Services::Users::Signup`。

Zeitwerk支持[自定义根命名空间](https://github.com/fxn/zeitwerk#custom-root-namespaces)来解决这个问题，您可以自定义`main`自动加载器来实现：

```ruby
# config/initializers/autoloading.rb

# 命名空间必须存在。
#
# 在此示例中，我们在现场定义了模块。也可以在其他地方创建并在此处使用普通的`require`加载其定义。
# 无论如何，`push_dir`都需要一个类或模块对象。
module Services; end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/services", namespace: Services)
```

Rails < 7.1不支持此功能，但您仍然可以在同一文件中添加此额外代码并使其正常工作：

```ruby
# 适用于运行在Rails < 7.1上的应用程序的额外代码。
app_services_dir = "#{Rails.root}/app/services" # 必须是字符串
ActiveSupport::Dependencies.autoload_paths.delete(app_services_dir)
Rails.application.config.watchable_dirs[app_services_dir] = [:rb]
```

自定义命名空间也适用于`once`自动加载器。然而，由于`once`自动加载器在引导过程的早期设置，因此无法在应用程序初始化器中进行配置。请将其放在`config/application.rb`中。

自动加载和引擎
-----------------------

引擎在父应用程序的上下文中运行，其代码由父应用程序进行自动加载、重新加载和急切加载。如果应用程序以`zeitwerk`模式运行，则引擎代码由`zeitwerk`模式加载。如果应用程序以`classic`模式运行，则引擎代码由`classic`模式加载。

当Rails启动时，引擎目录会添加到自动加载路径中，从自动加载器的角度来看，没有区别。自动加载器的主要输入是自动加载路径，它们是应用程序源树还是某个引擎源树的成员，这是无关紧要的。

例如，此应用程序使用[Devise](https://github.com/heartcombo/devise)：

```
% bin/rails runner 'pp ActiveSupport::Dependencies.autoload_paths'
[".../app/controllers",
 ".../app/controllers/concerns",
 ".../app/helpers",
 ".../app/models",
 ".../app/models/concerns",
 ".../gems/devise-4.8.0/app/controllers",
 ".../gems/devise-4.8.0/app/helpers",
 ".../gems/devise-4.8.0/app/mailers"]
 ```

如果引擎控制其父应用程序的自动加载模式，则可以像往常一样编写引擎。
然而，如果一个引擎支持Rails 6或Rails 6.1，并且不能控制其父应用程序，则必须准备在`classic`或`zeitwerk`模式下运行。需要考虑以下几点：

1. 如果`classic`模式需要一个`require_dependency`调用来确保某个常量在某个时刻被加载，请编写它。虽然`zeitwerk`不需要它，但它不会有任何问题，在`zeitwerk`模式下也可以工作。

2. `classic`模式下使用下划线命名常量（"User" -> "user.rb"），而`zeitwerk`模式下使用驼峰命名文件（"user.rb" -> "User"）。它们在大多数情况下是一致的，但如果有连续的大写字母序列，如"HTMLParser"，它们就不一致了。保持兼容的最简单方法是避免使用这样的名称。在这种情况下，选择"HtmlParser"。

3. 在`classic`模式下，文件`app/model/concerns/foo.rb`可以同时定义`Foo`和`Concerns::Foo`。在`zeitwerk`模式下，只有一种选择：它必须定义`Foo`。为了保持兼容，请定义`Foo`。

测试
-------

### 手动测试

任务`zeitwerk:check`检查项目树是否遵循预期的命名约定，对于手动检查非常方便。例如，如果你正在从`classic`模式迁移到`zeitwerk`模式，或者如果你正在修复某些问题：

```
% bin/rails zeitwerk:check
请稍等，我正在急切加载应用程序。
一切正常！
```

根据应用程序配置的不同，可能会有其他输出，但你要找的是最后的"All is good!"。

### 自动化测试

在测试套件中验证项目的急切加载是否正确是一个好的实践。

这涵盖了Zeitwerk命名规范的合规性和其他可能的错误情况。请查看[_Testing Rails Applications_](testing.html)指南中关于测试急切加载的[部分](testing.html#testing-eager-loading)。

故障排除
---------------

跟踪加载程序的活动的最佳方法是检查它们的活动。

最简单的方法是在加载框架默认值后，在`config/application.rb`中包含以下代码：

```ruby
Rails.autoloaders.log!
```

这将在标准输出中打印跟踪信息。

如果你更喜欢将日志记录到文件中，请进行以下配置：

```ruby
Rails.autoloaders.logger = Logger.new("#{Rails.root}/log/autoloading.log")
```

当`config/application.rb`执行时，Rails日志记录器尚不可用。如果你更喜欢使用Rails日志记录器，请在初始化程序中进行以下配置：

```ruby
# config/initializers/log_autoloaders.rb
Rails.autoloaders.logger = Rails.logger
```

Rails.autoloaders
-----------------

管理应用程序的Zeitwerk实例可通过以下方式访问：

```ruby
Rails.autoloaders.main
Rails.autoloaders.once
```

谓词

```ruby
Rails.autoloaders.zeitwerk_enabled?
```

在Rails 7应用程序中仍然可用，并返回`true`。
[`config.enable_reloading`]: configuring.html#config-enable-reloading
[`config.file_watcher`]: configuring.html#config-file-watcher
[`config.eager_load`]: configuring.html#config-eager-load
[`config.rake_eager_load`]: configuring.html#config-rake-eager-load
