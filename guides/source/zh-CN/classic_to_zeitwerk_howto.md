**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9c6201fd526077579ef792e0c4e2150d
Classic to Zeitwerk HOWTO
=========================

本指南记录了如何将Rails应用程序从“classic”模式迁移到“zeitwerk”模式。

阅读完本指南后，您将了解：

* 什么是“classic”和“zeitwerk”模式
* 为什么要从“classic”切换到“zeitwerk”
* 如何激活“zeitwerk”模式
* 如何验证应用程序是否在“zeitwerk”模式下运行
* 如何验证命令行中的项目加载是否正常
* 如何验证测试套件中的项目加载是否正常
* 如何处理可能的边缘情况
* 您可以利用的Zeitwerk中的新功能

--------------------------------------------------------------------------------

什么是“classic”和“zeitwerk”模式？
--------------------------------------------------------

从一开始，一直到Rails 5，Rails使用了Active Support中实现的自动加载器。这个自动加载器被称为“classic”，在Rails 6.x中仍然可用。Rails 7不再包含这个自动加载器。

从Rails 6开始，Rails使用一种新的更好的自动加载方式，它委托给[Zeitwerk](https://github.com/fxn/zeitwerk) gem。这就是“zeitwerk”模式。默认情况下，加载6.0和6.1框架默认值的应用程序在“zeitwerk”模式下运行，这是Rails 7中唯一可用的模式。


为什么要从“classic”切换到“zeitwerk”？
----------------------------------------

“classic”自动加载器非常有用，但是在某些情况下，它存在一些[问题](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#common-gotchas)，使得自动加载有时变得有些棘手和令人困惑。Zeitwerk就是为了解决这个问题而开发的，还有其他一些[动机](https://github.com/fxn/zeitwerk#motivation)。

升级到Rails 6.x时，强烈建议切换到“zeitwerk”模式，因为它是一个更好的自动加载器，“classic”模式已经被弃用。

Rails 7结束了过渡期，不再包含“classic”模式。

我很害怕
-----------

不用担心 :).

Zeitwerk的设计目标是尽可能与经典自动加载器兼容。如果您的应用程序今天能够正确自动加载，那么切换应该很容易。许多项目，无论大小，都报告了非常顺利的切换过程。

本指南将帮助您自信地更改自动加载器。

如果您遇到任何您不知道如何解决的情况，请随时在[`rails/rails`](https://github.com/rails/rails/issues/new)中提出问题，并标记[`@fxn`](https://github.com/fxn)。


如何激活“zeitwerk”模式
-------------------------------

### 运行Rails 5.x或更早版本的应用程序

在运行6.0之前的Rails版本的应用程序中，不可用“zeitwerk”模式。您至少需要运行Rails 6.0。

### 运行Rails 6.x的应用程序

在运行Rails 6.x的应用程序中，有两种情况。

如果应用程序正在加载Rails 6.0或6.1的框架默认值，并且正在运行“classic”模式，则必须手动退出。您必须有类似于以下内容的内容：

```ruby
# config/application.rb
config.load_defaults 6.0
config.autoloader = :classic # 删除此行
```

如上所述，只需删除覆盖，`zeitwerk`模式是默认模式。

另一方面，如果应用程序正在加载旧的框架默认值，则需要显式启用“zeitwerk”模式：

```ruby
# config/application.rb
config.load_defaults 5.2
config.autoloader = :zeitwerk
```

### 运行Rails 7的应用程序

在Rails 7中，只有“zeitwerk”模式，您不需要做任何操作来启用它。

实际上，在Rails 7中，setter `config.autoloader=` 甚至不存在。如果`config/application.rb`中使用了它，请删除该行。


如何验证应用程序是否在“zeitwerk”模式下运行？
------------------------------------------------------

要验证应用程序是否在“zeitwerk”模式下运行，请执行以下操作：

```
bin/rails runner 'p Rails.autoloaders.zeitwerk_enabled?'
```

如果打印出`true`，则启用了“zeitwerk”模式。


我的应用程序是否符合Zeitwerk约定？
-----------------------------------------------------

### config.eager_load_paths

符合性测试仅适用于急切加载的文件。因此，为了验证Zeitwerk的符合性，建议将所有自动加载路径都放在急切加载路径中。

默认情况下已经是这样，但是如果项目配置了自定义的自动加载路径，就像这样：

```ruby
config.autoload_paths << "#{Rails.root}/extras"
```

它们不会被急切加载，也不会被验证。将它们添加到急切加载路径很容易：

```ruby
config.autoload_paths << "#{Rails.root}/extras"
config.eager_load_paths << "#{Rails.root}/extras"
```

### zeitwerk:check

一旦启用了“zeitwerk”模式并且仔细检查了急切加载路径的配置，请运行：

```
bin/rails zeitwerk:check
```

成功的检查结果如下：

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

根据应用程序的配置，可能会有其他输出，但是最后的“All is good!”是您要寻找的。
如果在前一节中解释的双重检查确定实际上需要在急加载路径之外设置一些自定义自动加载路径，任务将会检测并警告它们。然而，如果测试套件成功加载这些文件，那就没问题了。

现在，如果有任何一个文件没有定义预期的常量，任务将会告诉你。它会逐个文件进行检查，因为如果它继续进行，加载一个文件失败可能会导致其他与我们要运行的检查无关的失败，错误报告会令人困惑。

如果报告了一个常量，请修复该特定常量，然后再次运行任务。重复此过程，直到获得"All is good!"。

以以下为例：

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
expected file app/models/vat.rb to define constant Vat
```

VAT是欧洲的一种税收。文件`app/models/vat.rb`定义了`VAT`，但自动加载程序期望的是`Vat`，为什么？

### 首字母缩略词

这是您可能遇到的最常见的差异类型，它与首字母缩略词有关。让我们了解为什么会出现这个错误消息。

经典的自动加载程序能够自动加载`VAT`，因为它的输入是缺失常量的名称`VAT`，在其上调用`underscore`，得到`vat`，然后查找名为`vat.rb`的文件。它可以工作。

新的自动加载程序的输入是文件系统。给定文件`vat.rb`，Zeitwerk在`vat`上调用`camelize`，得到`Vat`，并期望该文件定义常量`Vat`。这就是错误消息的含义。

修复这个问题很简单，您只需要告诉inflector关于这个首字母缩略词：

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "VAT"
end
```

这样做会全局影响Active Support的词形变化。这可能没问题，但如果您愿意，您也可以将覆盖项传递给自动加载程序使用的词形变化器：

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.inflector.inflect("vat" => "VAT")
```

通过这个选项，您可以更好地控制，因为只有名为`vat.rb`的文件或名为`vat`的目录才会被词形变化为`VAT`。名为`vat_rules.rb`的文件不受影响，可以很好地定义`VatRules`。如果项目存在这种命名不一致的情况，这可能很方便。

有了这个设置，检查通过了！

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

一切正常后，建议在测试套件中继续验证项目。[_在测试套件中检查Zeitwerk的兼容性_](#check-zeitwerk-compliance-in-the-test-suite)部分解释了如何做到这一点。

### 关注点

您可以从具有`concerns`子目录的标准结构中进行自动加载和急加载，如下所示：

```
app/models
app/models/concerns
```

默认情况下，`app/models/concerns`属于自动加载路径，因此它被认为是一个根目录。因此，默认情况下，`app/models/concerns/foo.rb`应该定义`Foo`，而不是`Concerns::Foo`。

如果您的应用程序使用`Concerns`作为命名空间，您有两个选择：

1. 从这些类和模块中删除`Concerns`命名空间，并更新客户端代码。
2. 通过从自动加载路径中删除`app/models/concerns`来保持现状：

  ```ruby
  # config/initializers/zeitwerk.rb
  ActiveSupport::Dependencies.
    autoload_paths.
    delete("#{Rails.root}/app/models/concerns")
  ```

### 在自动加载路径中包含`app`

一些项目希望像`app/api/base.rb`这样的文件定义`API::Base`，并将`app`添加到自动加载路径中以实现这一目的。

由于Rails会自动将`app`的所有子目录（有几个例外）添加到自动加载路径中，因此我们有了另一种情况，其中存在嵌套的根目录，类似于`app/models/concerns`的情况。然而，这种设置不再起作用。

但是，您可以保持该结构，只需在初始化程序中从自动加载路径中删除`app/api`：

```ruby
# config/initializers/zeitwerk.rb
ActiveSupport::Dependencies.
  autoload_paths.
  delete("#{Rails.root}/app/api")
```

请注意，没有要自动加载/急加载的文件的子目录。例如，如果应用程序具有用于[ActiveAdmin](https://activeadmin.info/)的资源的`app/admin`，则需要忽略它们。对于`assets`和其他类似的目录也是如此：

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.ignore(
  "app/admin",
  "app/assets",
  "app/javascripts",
  "app/views"
)
```

如果没有进行这样的配置，应用程序将急加载这些目录。会因为其文件没有定义常量而出错，例如，会定义一个`Views`模块，这是一个不需要的副作用。

正如您所看到的，将`app`包含在自动加载路径中在技术上是可能的，但有点棘手。

### 自动加载的常量和显式命名空间

如果一个命名空间在文件中被定义，就像这里的`Hotel`一样：
```
app/models/hotel.rb         # 定义Hotel。
app/models/hotel/pricing.rb # 定义Hotel::Pricing。
```

必须使用`class`或`module`关键字来设置`Hotel`常量。例如：

```ruby
class Hotel
end
```

是正确的。

像

```ruby
Hotel = Class.new
```

或者

```ruby
Hotel = Struct.new
```

这样的替代方法是不可行的，子对象如`Hotel::Pricing`将无法找到。

这个限制只适用于显式的命名空间。没有定义命名空间的类和模块可以使用这些习惯用法来定义。

### 一个文件，一个常量（在同一个顶级命名空间）

在`classic`模式下，你可以在同一个顶级命名空间下定义多个常量并进行重新加载。例如，给定以下代码：

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

虽然`Bar`无法自动加载，但自动加载`Foo`会将`Bar`标记为已自动加载。

在`zeitwerk`模式下不是这样的，你需要将`Bar`移动到它自己的文件`bar.rb`中。一个文件，一个顶级常量。

这只影响与上面示例中相同顶级命名空间的常量。内部类和模块没有问题。例如，考虑以下代码：

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

如果应用程序重新加载`Foo`，它也会重新加载`Foo::InnerClass`。

### `config.autoload_paths`中的通配符

注意配置中使用通配符的情况，例如：

```ruby
config.autoload_paths += Dir["#{config.root}/extras/**/"]
```

`config.autoload_paths`的每个元素都应该表示顶级命名空间（`Object`）。这样是行不通的。

要解决这个问题，只需删除通配符：

```ruby
config.autoload_paths << "#{config.root}/extras"
```

### 对引擎中的类和模块进行装饰

如果你的应用程序对引擎中的类或模块进行装饰，那么很可能在某个地方做了类似以下的操作：

```ruby
config.to_prepare do
  Dir.glob("#{Rails.root}/app/overrides/**/*_override.rb").sort.each do |override|
    require_dependency override
  end
end
```

这需要进行更新：你需要告诉`main`自动加载器忽略覆盖目录，并且需要使用`load`来加载它们。类似以下代码：

```ruby
overrides = "#{Rails.root}/app/overrides"
Rails.autoloaders.main.ignore(overrides)
config.to_prepare do
  Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
    load override
  end
end
```

### `before_remove_const`

Rails 3.1 添加了对`before_remove_const`回调的支持，如果一个类或模块响应了这个方法并且即将重新加载，就会调用该回调。这个回调一直没有被记录下来，你的代码很可能不会使用它。

然而，如果确实使用了它，你可以将以下代码重写为：

```ruby
class Country < ActiveRecord::Base
  def self.before_remove_const
    expire_redis_cache
  end
end
```

如下所示：

```ruby
# config/initializers/country.rb
if Rails.application.config.reloading_enabled?
  Rails.autoloaders.main.on_unload("Country") do |klass, _abspath|
    klass.expire_redis_cache
  end
end
```

### Spring和`test`环境

如果有代码发生更改，Spring会重新加载应用程序代码。在`test`环境中，你需要启用重新加载才能正常工作：

```ruby
# config/environments/test.rb
config.cache_classes = false
```

或者，从Rails 7.1开始：

```ruby
# config/environments/test.rb
config.enable_reloading = true
```

否则，你会得到以下错误：

```
reloading is disabled because config.cache_classes is true
```

或者

```
reloading is disabled because config.enable_reloading is false
```

这不会对性能产生影响。

### Bootsnap

请确保至少依赖于Bootsnap 1.4.4。


在测试套件中检查Zeitwerk的兼容性
-------------------------------------------

在迁移过程中，`zeitwerk:check`任务非常方便。一旦项目符合要求，建议自动化进行此检查。为了做到这一点，只需急切加载应用程序，这正是`zeitwerk:check`所做的。

### 持续集成

如果项目已经使用了持续集成，建议在其中运行测试套件时急切加载应用程序。如果由于某种原因无法急切加载应用程序，你肯定希望在持续集成中发现，而不是在生产环境中发现，对吧？

持续集成通常会设置一些环境变量来指示测试套件正在运行。例如，可以使用`CI`：

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

从Rails 7开始，默认情况下，新生成的应用程序已经配置成这样。

### 纯净的测试套件

如果项目没有持续集成，你仍然可以通过调用`Rails.application.eager_load!`来在测试套件中急切加载：

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "eager loads all files without errors" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk compliance" do
  it "eager loads all files without errors" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

删除所有`require`调用
--------------------------

根据我的经验，项目通常不会这样做。但我见过几个项目这样做，也听说过其他几个项目这样做。
在Rails应用程序中，您只能使用`require`来加载来自`lib`或第三方（如gem依赖项或标准库）的代码。**绝不能使用`require`来加载可自动加载的应用程序代码**。在`classic`模式中，可以在[此处](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#autoloading-and-require)查看为什么这是一个坏主意。

```ruby
require "nokogiri" # 正确
require "net/http" # 正确
require "user"     # 错误，请删除此行（假设是app/models/user.rb）
```

请删除所有此类`require`调用。

可以利用的新功能
------------------

### 删除`require_dependency`调用

已经使用Zeitwerk消除了所有已知的`require_dependency`用例。您应该在项目中使用grep命令并删除它们。

如果您的应用程序使用单表继承，请参阅自动加载和重新加载常量（Zeitwerk模式）指南中的[单表继承部分](autoloading_and_reloading_constants.html#single-table-inheritance)。

### 类和模块定义中现在可以使用限定名称

现在，您可以在类和模块定义中稳健地使用常量路径：

```ruby
# 此类主体中的自动加载与Ruby语义匹配。
class Admin::UsersController < ApplicationController
  # ...
end
```

需要注意的是，根据执行顺序，经典自动加载程序有时可以自动加载`Foo::Wadus`：

```ruby
class Foo::Bar
  Wadus
end
```

这不符合Ruby语义，因为`Foo`不在嵌套中，并且在`zeitwerk`模式下根本不起作用。如果遇到这种特殊情况，您可以使用限定名称`Foo::Wadus`：

```ruby
class Foo::Bar
  Foo::Wadus
end
```

或者将`Foo`添加到嵌套中：

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

### 线程安全性无处不在

在`classic`模式下，常量自动加载不是线程安全的，尽管Rails已经采取了锁定措施，例如使Web请求线程安全。

在`zeitwerk`模式下，常量自动加载是线程安全的。例如，您现在可以在由`runner`命令执行的多线程脚本中自动加载。

### 预加载和自动加载一致

在`classic`模式下，如果`app/models/foo.rb`定义了`Bar`，您将无法自动加载该文件，但是预加载将起作用，因为它会盲目地递归加载文件。如果您首先进行预加载测试，然后执行时自动加载可能会导致错误。

在`zeitwerk`模式下，这两种加载模式是一致的，它们在相同的文件中失败和出错。
