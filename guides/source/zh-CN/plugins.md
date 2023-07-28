**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b550120024fb17dc176480922543264e
创建Rails插件的基础知识
=======================

Rails插件是核心框架的扩展或修改。插件提供：

* 开发人员共享前沿思想的方式，而不会影响稳定的代码库。
* 分段架构，使得可以根据自己的发布计划修复或更新代码单元。
* 核心开发人员的出口，使得他们不必包含每个新功能。

阅读本指南后，您将了解：

* 如何从头开始创建插件。
* 如何编写和运行插件的测试。

本指南描述了如何构建一个测试驱动的插件，该插件将：

* 扩展核心Ruby类，如Hash和String。
* 在`ApplicationRecord`中添加方法，以传统的`acts_as`插件为例。
* 提供有关在插件中放置生成器的信息。

为了本指南的目的，假设您是一位狂热的观鸟者。您最喜欢的鸟是Yaffle，您想创建一个插件，让其他开发人员分享Yaffle的优点。

--------------------------------------------------------------------------------

设置
----

目前，Rails插件被构建为gem，即_gemified plugins_。如果需要，可以使用RubyGems和Bundler在不同的Rails应用程序之间共享它们。

### 生成一个Gemified插件

Rails附带了一个`rails plugin new`命令，它创建了一个骨架，用于开发任何类型的Rails扩展，并能够使用虚拟的Rails应用程序运行集成测试。使用以下命令创建您的插件：

```bash
$ rails plugin new yaffle
```

通过请求帮助来查看用法和选项：

```bash
$ rails plugin new --help
```

测试您新生成的插件
----------------

导航到包含插件的目录，并编辑`yaffle.gemspec`以替换任何具有`TODO`值的行：

```ruby
spec.homepage    = "http://example.com"
spec.summary     = "Summary of Yaffle."
spec.description = "Description of Yaffle."

...

spec.metadata["source_code_uri"] = "http://example.com"
spec.metadata["changelog_uri"] = "http://example.com"
```

然后运行`bundle install`命令。

现在，您可以使用`bin/test`命令运行测试，您应该会看到：

```bash
$ bin/test
...
1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

这将告诉您一切都生成正确，并且您已经准备好开始添加功能了。

扩展核心类
----------

本节将解释如何向String添加一个在您的Rails应用程序中任何地方都可用的方法。

在这个示例中，您将向String添加一个名为`to_squawk`的方法。首先，创建一个带有几个断言的新测试文件：

```ruby
# yaffle/test/core_ext_test.rb

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase
  def test_to_squawk_prepends_the_word_squawk
    assert_equal "squawk! Hello World", "Hello World".to_squawk
  end
end
```

运行`bin/test`来运行测试。这个测试应该失败，因为我们还没有实现`to_squawk`方法：

```bash
$ bin/test
E

Error:
CoreExtTest#test_to_squawk_prepends_the_word_squawk:
NoMethodError: undefined method `to_squawk' for "Hello World":String


bin/test /path/to/yaffle/test/core_ext_test.rb:4

.

Finished in 0.003358s, 595.6483 runs/s, 297.8242 assertions/s.
2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

太好了 - 现在您已经准备好开始开发了。

在`lib/yaffle.rb`中添加`require "yaffle/core_ext"`：

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"

module Yaffle
  # Your code goes here...
end
```

最后，创建`core_ext.rb`文件并添加`to_squawk`方法：

```ruby
# yaffle/lib/yaffle/core_ext.rb

class String
  def to_squawk
    "squawk! #{self}".strip
  end
end
```

为了测试您的方法是否按照其所说的那样工作，请使用插件目录中的`bin/test`运行单元测试。

```
$ bin/test
...
2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

要看到这个方法的效果，请切换到`test/dummy`目录，启动`bin/rails console`，然后开始发出叫声：

```irb
irb> "Hello World".to_squawk
=> "squawk! Hello World"
```

向Active Record添加一个"acts_as"方法
----------------------------------

插件中的一个常见模式是向模型添加一个名为`acts_as_something`的方法。在这种情况下，您想编写一个名为`acts_as_yaffle`的方法，该方法将向您的Active Record模型添加一个`squawk`方法。

首先，设置您的文件，以便您有：

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
end
```

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"
require "yaffle/acts_as_yaffle"

module Yaffle
  # Your code goes here...
end
```

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
  end
end
```
### 添加一个类方法

该插件期望您已经在模型中添加了一个名为`last_squawk`的方法。然而，插件用户可能已经在他们的模型中定义了一个名为`last_squawk`的方法，用于其他用途。该插件允许通过添加一个名为`yaffle_text_field`的类方法来更改名称。

首先，编写一个失败的测试来展示您想要的行为：

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end
end
```

当您运行`bin/test`时，您应该看到以下内容：

```bash
$ bin/test
# Running:

..E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NameError: uninitialized constant ActsAsYaffleTest::Wickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NameError: uninitialized constant ActsAsYaffleTest::Hickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4



Finished in 0.004812s, 831.2949 runs/s, 415.6475 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

这告诉我们我们没有我们正在尝试测试的必要模型（Hickwall和Wickwall）。我们可以通过从“dummy”Rails应用程序中运行以下命令来轻松生成这些模型：

```bash
$ cd test/dummy
$ bin/rails generate model Hickwall last_squawk:string
$ bin/rails generate model Wickwall last_squawk:string last_tweet:string
```

现在，您可以通过导航到虚拟应用程序并迁移数据库来在测试数据库中创建必要的数据库表。首先运行：

```bash
$ cd test/dummy
$ bin/rails db:migrate
```

当您在这里时，更改Hickwall和Wickwall模型，以便它们知道它们应该像yaffles一样运作。

```ruby
# test/dummy/app/models/hickwall.rb

class Hickwall < ApplicationRecord
  acts_as_yaffle
end
```

```ruby
# test/dummy/app/models/wickwall.rb

class Wickwall < ApplicationRecord
  acts_as_yaffle yaffle_text_field: :last_tweet
end
```

我们还将添加代码来定义`acts_as_yaffle`方法。

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

然后，您可以返回到插件的根目录（`cd ../..`）并使用`bin/test`重新运行测试。

```bash
$ bin/test
# Running:

.E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974ebbe9d8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4

E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974eb8cfc8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

.

Finished in 0.008263s, 484.0999 runs/s, 242.0500 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

越来越接近了...现在我们将实现`acts_as_yaffle`方法的代码以使测试通过。

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

当您运行`bin/test`时，您应该看到所有测试都通过：

```bash
$ bin/test
...
4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### 添加一个实例方法

该插件将在调用`acts_as_yaffle`的任何Active Record对象上添加一个名为'squawk'的方法。'squawk'方法将简单地设置数据库中的一个字段的值。

首先，编写一个失败的测试来展示您想要的行为：

```ruby
# yaffle/test/acts_as_yaffle_test.rb
require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end

  def test_hickwalls_squawk_should_populate_last_squawk
    hickwall = Hickwall.new
    hickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", hickwall.last_squawk
  end

  def test_wickwalls_squawk_should_populate_last_tweet
    wickwall = Wickwall.new
    wickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", wickwall.last_tweet
  end
end
```

运行测试以确保最后两个测试失败，并出现包含"NoMethodError: undefined method \`squawk'"的错误，然后将`acts_as_yaffle.rb`更新如下：

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    included do
      def squawk(string)
        write_attribute(self.class.yaffle_text_field, string.to_squawk)
      end
    end

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

最后再次运行`bin/test`，您应该看到：

```bash
$ bin/test
...
6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

注意：使用`write_attribute`将字段写入模型中只是插件与模型交互的一种示例，并不总是适合使用的正确方法。例如，您还可以使用：
```ruby
send("#{self.class.yaffle_text_field}=", string.to_squawk)
```

生成器
----------

生成器可以通过在插件的 `lib/generators` 目录中创建它们来包含在您的 gem 中。有关生成器创建的更多信息可以在 [生成器指南](generators.html) 中找到。

发布您的 Gem
-------------------

目前正在开发中的 Gem 插件可以轻松地从任何 Git 仓库共享。要与其他人共享 Yaffle gem，只需将代码提交到 Git 仓库（如 GitHub），并在相关应用程序的 `Gemfile` 中添加一行：

```ruby
gem "yaffle", git: "https://github.com/rails/yaffle.git"
```

运行 `bundle install` 后，您的 gem 功能将可供应用程序使用。

当 gem 准备好作为正式版本共享时，可以将其发布到 [RubyGems](https://rubygems.org)。

或者，您可以从 Bundler 的 Rake 任务中受益。您可以使用以下命令查看完整列表：

```bash
$ bundle exec rake -T

$ bundle exec rake build
# 将 yaffle-0.1.0.gem 构建到 pkg 目录中

$ bundle exec rake install
# 将 yaffle-0.1.0.gem 构建并安装到系统 gem 中

$ bundle exec rake release
# 创建标签 v0.1.0，并将 yaffle-0.1.0.gem 构建并推送到 Rubygems
```

有关将 gem 发布到 RubyGems 的更多信息，请参阅：[发布您的 gem](https://guides.rubygems.org/publishing)。

RDoc 文档
------------------

一旦您的插件稳定下来，并且您准备部署，为其他人提供帮助并为其编写文档！幸运的是，为插件编写文档很容易。

第一步是使用详细信息更新 README 文件，说明如何使用您的插件。包括以下几点是很重要的：

* 您的姓名
* 如何安装
* 如何将功能添加到应用程序（常见用例的几个示例）
* 可能有助于用户并节省时间的警告、注意事项或提示

一旦您的 README 文件完善，继续并为开发人员将使用的所有方法添加 RDoc 注释。通常还会在不包含在公共 API 中的代码部分添加 `# :nodoc:` 注释。

一旦您的注释准备就绪，请导航到插件目录并运行：

```bash
$ bundle exec rake rdoc
```

### 参考资料

* [使用 Bundler 开发 RubyGem](https://github.com/radar/guides/blob/master/gem-development.md)
* [按预期使用 .gemspecs](https://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)
* [Gemspec 参考](https://guides.rubygems.org/specification-reference/)
