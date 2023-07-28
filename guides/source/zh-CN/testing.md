**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 6da9945dc313b748574b8aca256f1435
测试Rails应用程序
==========================

本指南介绍了Rails中用于测试应用程序的内置机制。

阅读本指南后，您将了解以下内容：

* Rails测试术语。
* 如何为应用程序编写单元测试、功能测试、集成测试和系统测试。
* 其他流行的测试方法和插件。

--------------------------------------------------------------------------------

为什么要为您的Rails应用程序编写测试？
--------------------------------------------

Rails使编写测试变得非常容易。在创建模型和控制器时，它会生成测试代码的框架。

通过运行Rails测试，您可以确保您的代码在进行一些重大代码重构后仍符合所需的功能。

Rails测试还可以模拟浏览器请求，因此您可以在不通过浏览器测试的情况下测试应用程序的响应。

测试简介
-----------------------

测试支持从一开始就被纳入了Rails的框架中。这不是一个“哦！让我们添加对运行测试的支持，因为它们是新的和酷的”顿悟。

### Rails从一开始就为测试设置好了

使用`rails new` _application_name_命令创建Rails项目时，Rails会为您创建一个`test`目录。如果列出此目录的内容，则会看到：

```bash
$ ls -F test
application_system_test_case.rb  controllers/                     helpers/                         mailers/                         system/
channels/                        fixtures/                        integration/                     models/                          test_helper.rb
```

`helpers`、`mailers`和`models`目录分别用于保存视图助手、邮件和模型的测试。`channels`目录用于保存Action Cable连接和通道的测试。`controllers`目录用于保存控制器、路由和视图的测试。`integration`目录用于保存控制器之间的交互测试。

系统测试目录用于进行应用程序的完整浏览器测试。系统测试允许您以用户体验的方式测试应用程序，并帮助您测试JavaScript。系统测试继承自Capybara，并为您的应用程序执行浏览器测试。

夹具是组织测试数据的一种方式；它们位于`fixtures`目录中。

当首次生成关联测试时，还将创建一个`jobs`目录。

`test_helper.rb`文件保存了测试的默认配置。

`application_system_test_case.rb`保存了系统测试的默认配置。

### 测试环境

默认情况下，每个Rails应用程序都有三个环境：开发环境、测试环境和生产环境。

每个环境的配置可以类似地进行修改。在这种情况下，我们可以通过更改`config/environments/test.rb`中的选项来修改我们的测试环境。

注意：您的测试是在`RAILS_ENV=test`下运行的。

### Rails遇见Minitest

如果您还记得，在[开始使用Rails](getting_started.html)指南中，我们使用了`bin/rails generate model`命令。我们创建了我们的第一个模型，其中包括在`test`目录中创建的测试存根：

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

`test/models/article_test.rb`中的默认测试存根如下所示：

```ruby
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

逐行检查此文件将帮助您了解Rails测试代码和术语。

```ruby
require "test_helper"
```

通过引入此文件`test_helper.rb`，加载了运行我们的测试的默认配置。我们将在编写的所有测试中包含此文件，因此此文件中添加的任何方法都可用于我们的所有测试。

```ruby
class ArticleTest < ActiveSupport::TestCase
```

`ArticleTest`类定义了一个_测试用例_，因为它继承自`ActiveSupport::TestCase`。因此，`ArticleTest`具有`ActiveSupport::TestCase`提供的所有方法。在本指南的后面部分，我们将看到它给我们提供的一些方法。

在从`Minitest::Test`（`ActiveSupport::TestCase`的超类）继承的类中定义的任何以`test_`开头的方法都被简单地称为测试。因此，以`test_password`和`test_valid_password`定义的方法是合法的测试名称，并且在运行测试用例时会自动运行。

Rails还添加了一个`test`方法，它接受一个测试名称和一个代码块。它生成一个普通的`Minitest::Unit`测试，其中方法名以`test_`为前缀。因此，您不必担心命名方法，您可以编写类似于以下内容的代码：

```ruby
test "the truth" do
  assert true
end
```

这与编写以下内容几乎相同：
```ruby
def test_the_truth
  assert true
end
```

尽管您仍然可以使用常规的方法定义，但使用`test`宏可以使测试名称更易读。

注意：方法名称是通过将空格替换为下划线来生成的。结果不需要是有效的Ruby标识符，因为在Ruby中，技术上任何字符串都可以是方法名。这可能需要使用`define_method`和`send`调用才能正常工作，但从形式上讲，对名称的限制很少。

接下来，让我们看一下我们的第一个断言：

```ruby
assert true
```

断言是一行代码，用于评估对象（或表达式）的预期结果。例如，断言可以检查：

* 这个值是否等于那个值？
* 这个对象是否为空？
* 这行代码是否抛出异常？
* 用户的密码是否大于5个字符？

每个测试可能包含一个或多个断言，对允许的断言数量没有限制。只有当所有断言都成功时，测试才会通过。

#### 第一个失败的测试

为了查看测试失败的报告，您可以将一个失败的测试添加到`article_test.rb`测试用例中。

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save
end
```

让我们运行这个新添加的测试（其中`6`是定义测试的行号）。

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 44656

# Running:

F

Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Expected true to be nil or false


bin/rails test test/models/article_test.rb:6



Finished in 0.023918s, 41.8090 runs/s, 41.8090 assertions/s.

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
```

在输出中，`F`表示失败。您可以看到在“Failure”下显示的相应跟踪，以及失败测试的名称。接下来的几行包含堆栈跟踪，后面是一条消息，其中提到了断言的实际值和预期值。默认的断言消息提供了足够的信息来帮助定位错误。为了使断言失败消息更易读，每个断言都提供了一个可选的消息参数，如下所示：

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save, "Saved the article without a title"
end
```

运行此测试将显示更友好的断言消息：

```
Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Saved the article without a title
```

现在，为了使这个测试通过，我们可以为_title_字段添加一个模型级别的验证。

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

现在测试应该通过。让我们再次运行测试来验证：

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 31252

# Running:

.

Finished in 0.027476s, 36.3952 runs/s, 36.3952 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

现在，如果您注意到，我们首先编写了一个测试，该测试对所需的功能失败，然后我们编写了一些代码来添加功能，最后我们确保我们的测试通过。这种软件开发方法被称为“测试驱动开发”（Test-Driven Development，TDD）。

#### 错误的样子

为了查看错误的报告方式，这里有一个包含错误的测试：

```ruby
test "should report error" do
  # some_undefined_variable在测试用例中没有定义
  some_undefined_variable
  assert true
end
```

现在您可以在控制台中看到更多的输出结果：

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1808

# Running:

.E

Error:
ArticleTest#test_should_report_error:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9



Finished in 0.040609s, 49.2500 runs/s, 24.6250 assertions/s.

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

注意输出中的'E'。它表示一个带有错误的测试。

注意：每个测试方法的执行在遇到任何错误或断言失败时立即停止，并且测试套件继续执行下一个方法。所有测试方法以随机顺序执行。[`config.active_support.test_order`][]选项可用于配置测试顺序。

当测试失败时，会显示相应的回溯信息。默认情况下，Rails会过滤掉回溯信息，并且只会打印与您的应用程序相关的行。这消除了框架噪音，并有助于专注于您的代码。但是，在某些情况下，您可能希望查看完整的回溯信息。设置`-b`（或`--backtrace`）参数以启用此行为：
```bash
$ bin/rails test -b test/models/article_test.rb
```

如果我们希望这个测试通过，我们可以修改它使用`assert_raises`，像这样：

```ruby
test "should report error" do
  # some_undefined_variable在测试用例中没有定义
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

现在这个测试应该通过了。


### 可用的断言

到目前为止，您已经对一些可用的断言有了一瞥。断言是测试的工作蜜蜂。它们是实际执行检查以确保事情按计划进行的工具。

下面是您可以在Rails中使用的[`Minitest`](https://github.com/minitest/minitest)的一些断言的摘录。`[msg]`参数是一个可选的字符串消息，您可以指定它以使测试失败消息更清晰。

| 断言                                                             | 目的 |
| ---------------------------------------------------------------- | ------- |
| `assert( test, [msg] )`                                          | 确保`test`为真。|
| `assert_not( test, [msg] )`                                      | 确保`test`为假。|
| `assert_equal( expected, actual, [msg] )`                        | 确保`expected == actual`为真。|
| `assert_not_equal( expected, actual, [msg] )`                    | 确保`expected != actual`为真。|
| `assert_same( expected, actual, [msg] )`                         | 确保`expected.equal?(actual)`为真。|
| `assert_not_same( expected, actual, [msg] )`                     | 确保`expected.equal?(actual)`为假。|
| `assert_nil( obj, [msg] )`                                       | 确保`obj.nil?`为真。|
| `assert_not_nil( obj, [msg] )`                                   | 确保`obj.nil?`为假。|
| `assert_empty( obj, [msg] )`                                     | 确保`obj`是`empty?`。|
| `assert_not_empty( obj, [msg] )`                                 | 确保`obj`不是`empty?`。|
| `assert_match( regexp, string, [msg] )`                          | 确保字符串与正则表达式匹配。|
| `assert_no_match( regexp, string, [msg] )`                       | 确保字符串不与正则表达式匹配。|
| `assert_includes( collection, obj, [msg] )`                      | 确保`obj`在`collection`中。|
| `assert_not_includes( collection, obj, [msg] )`                  | 确保`obj`不在`collection`中。|
| `assert_in_delta( expected, actual, [delta], [msg] )`            | 确保数字`expected`和`actual`在`delta`范围内。|
| `assert_not_in_delta( expected, actual, [delta], [msg] )`        | 确保数字`expected`和`actual`不在`delta`范围内。|
| `assert_in_epsilon ( expected, actual, [epsilon], [msg] )`       | 确保数字`expected`和`actual`的相对误差小于`epsilon`。|
| `assert_not_in_epsilon ( expected, actual, [epsilon], [msg] )`   | 确保数字`expected`和`actual`的相对误差不小于`epsilon`。|
| `assert_throws( symbol, [msg] ) { block }`                       | 确保给定的块抛出符号。|
| `assert_raises( exception1, exception2, ... ) { block }`         | 确保给定的块引发给定的异常之一。|
| `assert_instance_of( class, obj, [msg] )`                        | 确保`obj`是`class`的一个实例。|
| `assert_not_instance_of( class, obj, [msg] )`                    | 确保`obj`不是`class`的一个实例。|
| `assert_kind_of( class, obj, [msg] )`                            | 确保`obj`是`class`的一个实例或者是它的子类。|
| `assert_not_kind_of( class, obj, [msg] )`                        | 确保`obj`不是`class`的一个实例，也不是它的子类。|
| `assert_respond_to( obj, symbol, [msg] )`                        | 确保`obj`响应`symbol`。|
| `assert_not_respond_to( obj, symbol, [msg] )`                    | 确保`obj`不响应`symbol`。|
| `assert_operator( obj1, operator, [obj2], [msg] )`               | 确保`obj1.operator(obj2)`为真。|
| `assert_not_operator( obj1, operator, [obj2], [msg] )`           | 确保`obj1.operator(obj2)`为假。|
| `assert_predicate ( obj, predicate, [msg] )`                     | 确保`obj.predicate`为真，例如`assert_predicate str, :empty?`|
| `assert_not_predicate ( obj, predicate, [msg] )`                 | 确保`obj.predicate`为假，例如`assert_not_predicate str, :empty?`|
| `flunk( [msg] )`                                                 | 强制失败。这对于明确标记尚未完成的测试非常有用。|

上述是minitest支持的一部分断言。有关详尽且更为最新的列表，请查看[Minitest API文档](http://docs.seattlerb.org/minitest/)，特别是[`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html)。

由于测试框架的模块化特性，您可以创建自己的断言。事实上，这正是Rails所做的。它包含了一些专门的断言，以使您的生活更轻松。

注意：创建自己的断言是一个我们在本教程中不涉及的高级主题。

### Rails特定的断言

Rails为`minitest`框架添加了一些自定义断言：
| 断言                                                                                   | 目的                                                         |
| -------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | 测试表达式的返回值在调用块后的差异。                                          |
| [`assert_no_difference(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | 断言在调用传入的块之前和之后，评估表达式的数值结果没有发生变化。 |
| [`assert_changes(expressions, message = nil, from:, to:, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes) | 测试在调用传入的块后，评估表达式的结果是否发生了变化。                 |
| [`assert_no_changes(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes) | 测试在调用传入的块后，评估表达式的结果是否没有发生变化。                 |
| [`assert_nothing_raised { block }`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised) | 确保给定的块不会引发任何异常。                                   |
| [`assert_recognizes(expected_options, path, extras={}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | 断言给定路径的路由处理正确，并且解析的选项（在expected_options哈希中给出）与路径匹配。基本上，它断言Rails能够识别给定的路由。 |
| [`assert_generates(expected_path, options, defaults={}, extras = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | 断言提供的选项可以用于生成提供的路径。这是assert_recognizes的反向操作。extras参数用于告诉请求查询字符串中的其他请求参数的名称和值。message参数允许您为断言失败指定自定义错误消息。 |
| [`assert_response(type, message = nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | 断言响应具有特定的状态码。您可以指定`:success`表示200-299，`:redirect`表示300-399，`:missing`表示404，或`:error`表示500-599。您还可以传递显式状态码或其符号等效项。有关更多信息，请参阅[状态码的完整列表](https://rubydoc.info/gems/rack/Rack/Utils#HTTP_STATUS_CODES-constant)以及它们的[映射](https://rubydoc.info/gems/rack/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant)如何工作。 |
| [`assert_redirected_to(options = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | 断言响应是重定向到与给定选项匹配的URL。您还可以传递命名路由，例如`assert_redirected_to root_path`，以及Active Record对象，例如`assert_redirected_to @article`。|

您将在下一章中看到这些断言的使用方法。

### 关于测试用例的简要说明

我们在自己的测试用例中使用的所有基本断言，如`assert_equal`，都可以在我们使用的类中使用。实际上，Rails为您提供了以下类供您继承：

* [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](https://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::IntegrationTest`](https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActionDispatch::SystemTestCase`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](https://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

这些类中的每一个都包含`Minitest::Assertions`，允许我们在测试中使用所有基本断言。

注意：有关`Minitest`的更多信息，请参阅[其文档](http://docs.seattlerb.org/minitest)。

### Rails测试运行器

我们可以使用`bin/rails test`命令一次运行所有测试。

或者，我们可以通过将`bin/rails test`命令传递给包含测试用例的文件名来运行单个测试文件。

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1559

# Running:

..

Finished in 0.027034s, 73.9810 runs/s, 110.9715 assertions/s.

2 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

这将运行测试用例中的所有测试方法。

您还可以通过提供`-n`或`--name`标志和测试方法的名称来运行测试用例中的特定测试方法。

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Run options: -n test_the_truth --seed 43583

# Running:

.

Finished tests in 0.009064s, 110.3266 tests/s, 110.3266 assertions/s.

1 tests, 1 assertions, 0 failures, 0 errors, 0 skips
```

您还可以通过提供行号来运行特定行的测试。

```bash
$ bin/rails test test/models/article_test.rb:6 # 运行特定的测试和行
```

您还可以通过提供目录的路径来运行整个测试目录。

```bash
$ bin/rails test test/controllers # 运行特定目录中的所有测试
```

测试运行器还提供了许多其他功能，如快速失败、在测试运行结束后延迟测试输出等。请查看测试运行器的文档，如下所示：

```bash
$ bin/rails test -h
Usage: rails test [options] [files or directories]

You can run a single test by appending a line number to a filename:

    bin/rails test test/models/user_test.rb:27

You can run multiple files and directories at the same time:

    bin/rails test test/controllers test/integration/login_test.rb

By default test failures and errors are reported inline during a run.

minitest options:
    -h, --help                       Display this help.
        --no-plugins                 Bypass minitest plugin auto-loading (or set $MT_NO_PLUGINS).
    -s, --seed SEED                  Sets random seed. Also via env. Eg: SEED=n rake
    -v, --verbose                    Verbose. Show progress processing files.
    -n, --name PATTERN               Filter run on /regexp/ or string.
        --exclude PATTERN            Exclude /regexp/ or string from run.

Known extensions: rails, pride
    -w, --warnings                   Run with Ruby warnings enabled
    -e, --environment ENV            Run tests in the ENV environment
    -b, --backtrace                  Show the complete backtrace
    -d, --defer-output               Output test failures and errors after the test run
    -f, --fail-fast                  Abort test run on first failure or error
    -c, --[no-]color                 Enable color in the output
    -p, --pride                      Pride. Show your testing pride!
```
### 在持续集成（CI）中运行测试

在CI环境中运行所有测试，只需要一个命令：

```bash
$ bin/rails test
```

如果你正在使用[系统测试](#system-testing)，`bin/rails test`不会运行它们，因为它们可能会很慢。要同时运行它们，可以添加另一个CI步骤来运行`bin/rails test:system`，或者将第一个步骤更改为`bin/rails test:all`，它会运行包括系统测试在内的所有测试。

并行测试
----------------

并行测试允许你将测试套件并行化。默认的方法是使用Ruby的DRb系统进行进程分叉，也支持线程。并行运行测试可以减少整个测试套件运行所需的时间。

### 使用进程进行并行测试

默认的并行化方法是使用Ruby的DRb系统进行进程分叉。进程的分叉基于提供的工作进程数。默认值是您所在机器的实际核心数，但可以通过传递给parallelize方法的数字进行更改。

要启用并行化，请将以下内容添加到您的`test_helper.rb`文件中：

```ruby
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

传递的工作进程数是进程将被分叉的次数。您可能希望在本地测试套件和CI中使用不同的并行化方式，因此提供了一个环境变量，以便能够轻松更改测试运行所使用的工作进程数：

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

在并行化测试时，Active Record会自动处理为每个进程创建数据库并将模式加载到数据库中。数据库将以与工作进程相对应的数字作为后缀。例如，如果您有2个工作进程，测试将分别创建`test-database-0`和`test-database-1`。

如果传递的工作进程数为1或更少，进程将不会被分叉，测试将不会并行化，并且测试将使用原始的`test-database`数据库。

提供了两个钩子，一个在进程分叉时运行，一个在分叉的进程关闭之前运行。如果您的应用程序使用多个数据库或执行依赖于工作进程数的其他任务，这些钩子可能会很有用。

`parallelize_setup`方法在进程分叉后立即调用。`parallelize_teardown`方法在进程关闭之前调用。

```ruby
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # 设置数据库
  end

  parallelize_teardown do |worker|
    # 清理数据库
  end

  parallelize(workers: :number_of_processors)
end
```

在使用线程进行并行测试时，不需要也不可用这些方法。

### 使用线程进行并行测试

如果您更喜欢使用线程或者正在使用JRuby，提供了一个线程并行化选项。线程并行化是由Minitest的`Parallel::Executor`支持的。

要将并行化方法更改为使用线程而不是进程，请在您的`test_helper.rb`文件中添加以下内容：

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)
end
```

从JRuby或TruffleRuby生成的Rails应用程序将自动包含`with: :threads`选项。

传递给`parallelize`的工作进程数确定测试将使用的线程数。您可能希望在本地测试套件和CI中使用不同的并行化方式，因此提供了一个环境变量，以便能够轻松更改测试运行所使用的工作进程数：

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

### 测试并行事务

Rails会自动将任何测试用例包装在一个数据库事务中，在测试完成后回滚。这使得测试用例彼此独立，并且对数据库的更改仅在单个测试中可见。

当您想要测试在线程中运行并行事务的代码时，事务可能会相互阻塞，因为它们已经嵌套在测试事务下。

您可以通过设置`self.use_transactional_tests = false`来禁用测试用例类中的事务：

```ruby
class WorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "parallel transactions" do
    # 启动一些创建事务的线程
  end
end
```

注意：在禁用事务测试时，您必须清理测试创建的任何数据，因为更改不会在测试完成后自动回滚。

### 并行化测试的阈值

并行化测试会增加数据库设置和装载fixture的开销。因此，Rails不会并行化涉及少于50个测试的执行。

您可以在您的`test.rb`中配置此阈值：
```ruby
config.active_support.test_parallelization_threshold = 100
```

同时，在测试用例级别设置并行化：

```ruby
class ActiveSupport::TestCase
  parallelize threshold: 100
end
```

测试数据库
-----------------

几乎每个Rails应用程序都与数据库有密切的交互，因此您的测试也需要与数据库进行交互。为了编写高效的测试，您需要了解如何设置这个数据库并用示例数据填充它。

默认情况下，每个Rails应用程序都有三个环境：开发环境、测试环境和生产环境。每个环境的数据库在`config/database.yml`中进行配置。

专用的测试数据库允许您在隔离环境中设置和操作测试数据。这样，您的测试可以自信地操纵测试数据，而不必担心开发或生产数据库中的数据。

### 维护测试数据库模式

为了运行测试，您的测试数据库需要具有当前的结构。测试助手会检查您的测试数据库是否有任何未完成的迁移。它会尝试将`db/schema.rb`或`db/structure.sql`加载到测试数据库中。如果仍有未完成的迁移，将会引发错误。通常，这表示您的模式尚未完全迁移。运行迁移以更新开发数据库的模式（`bin/rails db:migrate`）。

注意：如果对现有迁移进行了修改，则需要重建测试数据库。可以通过执行`bin/rails db:test:prepare`来完成。

### 关于固定数据的要点

为了进行良好的测试，您需要考虑设置测试数据。在Rails中，您可以通过定义和自定义固定数据来处理这个问题。您可以在[固定数据API文档](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)中找到全面的文档。

#### 什么是固定数据？

固定数据是指示例数据的一种高级词汇。固定数据允许您在测试运行之前使用预定义的数据填充测试数据库。固定数据与数据库无关，并以YAML格式编写。每个模型对应一个文件。

注意：固定数据不是为了创建测试所需的每个对象而设计的，最好只在应用于常见情况的默认数据时使用。

您可以在`test/fixtures`目录下找到固定数据。当您运行`bin/rails generate model`创建一个新模型时，Rails会自动在此目录中创建固定数据存根。

#### YAML

YAML格式的固定数据是一种人性化的描述示例数据的方式。这种类型的固定数据具有**.yml**文件扩展名（例如`users.yml`）。

以下是一个示例的YAML固定数据文件：

```yaml
# 瞧！我是一个YAML注释！
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: 系统开发

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: 键盘上的家伙
```

每个固定数据都有一个名称，后面是一个缩进的冒号分隔的键/值对列表。记录通常由空行分隔。您可以使用#字符在固定数据文件中添加注释，#字符位于第一列。

如果您正在使用[关联](/association_basics.html)，您可以在两个不同的固定数据之间定义一个引用节点。以下是一个具有`belongs_to`/`has_many`关联的示例：

```yaml
# test/fixtures/categories.yml
about:
  name: 关于
```

```yaml
# test/fixtures/articles.yml
first:
  title: 欢迎来到Rails！
  category: about
```

```yaml
# test/fixtures/action_text/rich_texts.yml
first_content:
  record: first (Article)
  name: content
  body: <div>Hello, from <strong>a fixture</strong></div>
```

请注意，`fixtures/articles.yml`中的`first`文章的`category`键的值为`about`，而`fixtures/action_text/rich_texts.yml`中的`first_content`条目的`record`键的值为`first (Article)`。这提示Active Record为前者加载`fixtures/categories.yml`中找到的Category `about`，为后者加载`fixtures/articles.yml`中找到的Article `first`。

注意：为了使关联通过名称相互引用，您可以使用固定数据的名称而不是在关联的固定数据上指定`id:`属性。Rails将自动分配一个主键，以便在运行之间保持一致。有关此关联行为的更多信息，请阅读[固定数据API文档](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)。

#### 文件附件固定数据

与其他基于Active Record的模型一样，Active Storage附件记录继承自ActiveRecord::Base实例，因此可以通过固定数据进行填充。

考虑一个`Article`模型，它具有一个关联的图像作为`thumbnail`附件，以及固定数据YAML：

```ruby
class Article
  has_one_attached :thumbnail
end
```

```yaml
# test/fixtures/articles.yml
first:
  title: 一篇文章
```

假设在`test/fixtures/files/first.png`路径下有一个编码为[image/png][]的文件，以下的YAML fixture条目将生成相关的`ActiveStorage::Blob`和`ActiveStorage::Attachment`记录：

```yaml
# test/fixtures/active_storage/blobs.yml
first_thumbnail_blob: <%= ActiveStorage::FixtureSet.blob filename: "first.png" %>
```

```yaml
# test/fixtures/active_storage/attachments.yml
first_thumbnail_attachment:
  name: thumbnail
  record: first (Article)
  blob: first_thumbnail_blob
```


#### ERB'in It Up

ERB允许您在模板中嵌入Ruby代码。当Rails加载fixtures时，YAML fixture格式将通过ERB进行预处理。这使您可以使用Ruby来生成一些示例数据。例如，以下代码生成了一千个用户：

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```

#### Fixtures in Action

Rails默认会自动加载`test/fixtures`目录下的所有fixtures。加载过程包括三个步骤：

1. 从与fixture对应的表中删除任何现有数据
2. 将fixture数据加载到表中
3. 将fixture数据转储到一个方法中，以便您可以直接访问它

提示：为了从数据库中删除现有数据，Rails尝试禁用引用完整性触发器（如外键和检查约束）。如果在运行测试时遇到烦人的权限错误，请确保数据库用户在测试环境中有权限禁用这些触发器。（在PostgreSQL中，只有超级用户才能禁用所有触发器。在此处阅读有关PostgreSQL权限的更多信息：https://www.postgresql.org/docs/current/sql-altertable.html）。

#### Fixtures are Active Record Objects

Fixtures是Active Record的实例。如上所述，在第3点中，您可以直接访问该对象，因为它会自动作为一个方法可在测试用例的本地范围内使用。例如：

```ruby
# 这将返回名为david的fixture的User对象
users(:david)

# 这将返回名为david的fixture的id属性
users(:david).id

# 还可以访问User类上可用的方法
david = users(:david)
david.call(david.partner)
```

要一次获取多个fixtures，可以传入一个fixture名称列表。例如：

```ruby
# 这将返回一个包含fixtures david和steve的数组
users(:david, :steve)
```


模型测试
-------------

模型测试用于测试应用程序的各种模型。

Rails模型测试存储在`test/models`目录下。Rails提供了一个生成器来为您创建模型测试的框架。

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

模型测试没有像`ActionMailer::TestCase`那样有自己的超类。相反，它们继承自[`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)。

系统测试
--------------

系统测试允许您测试用户与应用程序的交互，可以在真实浏览器或无头浏览器中运行测试。系统测试在幕后使用Capybara。

要创建Rails系统测试，您可以使用应用程序中的`test/system`目录。Rails提供了一个生成器来为您创建系统测试的框架。

```bash
$ bin/rails generate system_test users
      invoke test_unit
      create test/system/users_test.rb
```

下面是一个新生成的系统测试的示例：

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
end
```

默认情况下，系统测试使用Selenium驱动程序，在Chrome浏览器中运行，并且屏幕大小为1400x1400。下一节将解释如何更改默认设置。

### 更改默认设置

Rails使得更改系统测试的默认设置非常简单。所有的设置都被抽象出来，所以您可以专注于编写测试。

当您生成一个新的应用程序或脚手架时，会在测试目录中创建一个`application_system_test_case.rb`文件。这是您的系统测试的所有配置应该放置的地方。

如果您想要更改默认设置，可以更改系统测试的“驱动程序”。假设您想要将驱动程序从Selenium更改为Cuprite。首先在`Gemfile`中添加`cuprite` gem。然后在您的`application_system_test_case.rb`文件中执行以下操作：

```ruby
require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
```

驱动程序名称是`driven_by`的必需参数。可以传递给`driven_by`的可选参数有`：using`用于浏览器（这仅适用于Selenium），`：screen_size`用于更改截图的屏幕大小，以及`：options`用于设置驱动程序支持的选项。
```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```

如果你想使用无头浏览器，你可以通过在 `:using` 参数中添加 `headless_chrome` 或 `headless_firefox` 来使用 Headless Chrome 或 Headless Firefox。

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

如果你想使用远程浏览器，例如 [Headless Chrome in Docker](https://github.com/SeleniumHQ/docker-selenium)，你需要通过 `options` 添加远程 `url`。

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  options = ENV["SELENIUM_REMOTE_URL"].present? ? { url: ENV["SELENIUM_REMOTE_URL"] } : {}
  driven_by :selenium, using: :headless_chrome, options: options
end
```

在这种情况下，不再需要 `webdrivers` gem。你可以完全删除它，或者在 `Gemfile` 中添加 `require:` 选项。

```ruby
# ...
group :test do
  gem "webdrivers", require: !ENV["SELENIUM_REMOTE_URL"] || ENV["SELENIUM_REMOTE_URL"].empty?
end
```

现在你应该能够连接到远程浏览器。

```bash
$ SELENIUM_REMOTE_URL=http://localhost:4444/wd/hub bin/rails test:system
```

如果你的测试应用程序也在远程运行，例如 Docker 容器，Capybara 需要更多关于如何调用远程服务器的信息。

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  def setup
    Capybara.server_host = "0.0.0.0" # 绑定到所有接口
    Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}" if ENV["SELENIUM_REMOTE_URL"].present?
    super
  end
  # ...
end
```

现在，无论浏览器和服务器是否在 Docker 容器或 CI 中运行，你都应该能够连接到远程浏览器和服务器。

如果你的 Capybara 配置需要比 Rails 提供的更多设置，可以将这些额外的配置添加到 `application_system_test_case.rb` 文件中。

请参阅 [Capybara 的文档](https://github.com/teamcapybara/capybara#setup) 获取其他设置。

### Screenshot Helper

`ScreenshotHelper` 是一个帮助类，用于捕获测试的屏幕截图。这对于在测试失败时查看浏览器的状态或以后调试时查看屏幕截图非常有帮助。

提供了两个方法：`take_screenshot` 和 `take_failed_screenshot`。`take_failed_screenshot` 会自动在 Rails 的 `before_teardown` 中调用。

`take_screenshot` 帮助方法可以在测试的任何地方包含，用于捕获浏览器的屏幕截图。

### 实现系统测试

现在我们将在博客应用程序中添加一个系统测试。我们将演示通过访问首页并创建一篇新的博客文章来编写系统测试。

如果你使用了脚手架生成器，它会自动为你创建一个系统测试的框架。如果你没有使用脚手架生成器，请先创建一个系统测试的框架。

```bash
$ bin/rails generate system_test articles
```

它应该已经为我们创建了一个测试文件占位符。使用上述命令的输出，你应该看到：

```
      invoke  test_unit
      create    test/system/articles_test.rb
```

现在让我们打开这个文件并编写我们的第一个断言：

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "viewing the index" do
    visit articles_path
    assert_selector "h1", text: "Articles"
  end
end
```

该测试应该检查文章索引页面上是否有一个 `h1` 标签，并通过测试。

运行系统测试。

```bash
$ bin/rails test:system
```

注意：默认情况下，运行 `bin/rails test` 不会运行系统测试。确保运行 `bin/rails test:system` 来实际运行它们。你也可以运行 `bin/rails test:all` 来运行所有测试，包括系统测试。

#### 创建文章系统测试

现在让我们测试在博客中创建一篇新文章的流程。

```ruby
test "should create Article" do
  visit articles_path

  click_on "New Article"

  fill_in "Title", with: "Creating an Article"
  fill_in "Body", with: "Created this article successfully!"

  click_on "Create Article"

  assert_text "Creating an Article"
end
```

第一步是调用 `visit articles_path`。这将使测试进入文章索引页面。

然后，`click_on "New Article"` 将在索引页面上找到 "New Article" 按钮。这将重定向浏览器到 `/articles/new`。

然后，测试将使用指定的文本填写文章的标题和内容。一旦字段填写完毕，点击 "Create Article"，这将发送一个 POST 请求来在数据库中创建新文章。

我们将被重定向回文章索引页面，并在那里断言新文章的标题文本是否在文章索引页面上。

#### 测试多个屏幕尺寸

如果你想在测试桌面尺寸之外还要测试移动尺寸，你可以创建另一个继承自 `ActionDispatch::SystemTestCase` 的类，并在测试套件中使用它。在这个例子中，我们在 `/test` 目录中创建了一个名为 `mobile_system_test_case.rb` 的文件，并进行了以下配置。
```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

要使用这个配置，创建一个继承自`MobileSystemTestCase`的测试，放在`test/system`目录下。
现在，您可以使用多个不同的配置来测试您的应用程序。

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase
  test "访问首页" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### 进一步

系统测试的美妙之处在于它类似于集成测试，它测试用户与控制器、模型和视图的交互，但系统测试更加强大，实际上测试您的应用程序，就像真正的用户在使用它一样。未来，您可以测试用户在应用程序中执行的任何操作，例如评论、删除文章、发布草稿文章等。

集成测试
-------------------

集成测试用于测试应用程序中各个部分的交互。它们通常用于测试应用程序中的重要工作流程。

对于创建Rails集成测试，我们使用应用程序的`test/integration`目录。Rails提供了一个生成器来为我们创建集成测试的框架。

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

这是一个新生成的集成测试的样子：

```ruby
require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

这里的测试继承自`ActionDispatch::IntegrationTest`。这使得我们在集成测试中可以使用一些额外的辅助方法。

### 集成测试可用的辅助方法

除了标准的测试辅助方法之外，继承自`ActionDispatch::IntegrationTest`还提供了一些额外的辅助方法供我们在集成测试中使用。让我们简要介绍一下这三类辅助方法。

要了解有关集成测试运行器的信息，请参阅[`ActionDispatch::Integration::Runner`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html)。

在执行请求时，我们可以使用[`ActionDispatch::Integration::RequestHelpers`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html)。

如果我们需要修改会话或集成测试的状态，请查看[`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html)。

### 实施集成测试

让我们为我们的博客应用程序添加一个集成测试。我们将从创建一个新的博客文章的基本工作流开始，以验证一切是否正常工作。

我们首先生成集成测试的框架：

```bash
$ bin/rails generate integration_test blog_flow
```

它应该为我们创建了一个测试文件的占位符。使用上一个命令的输出，我们应该看到：

```
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

现在让我们打开那个文件并写下我们的第一个断言：

```ruby
require "test_helper"

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "可以看到欢迎页面" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

我们将在下面的"测试视图"部分中查看`assert_select`，以查询请求的结果HTML。它用于通过断言关键HTML元素及其内容的存在来测试我们请求的响应。

当我们访问根路径时，我们应该看到`welcome/index.html.erb`渲染为视图。所以这个断言应该通过。

#### 创建文章集成

我们如何测试在我们的博客中创建一个新文章并查看结果文章。

```ruby
test "可以创建一篇文章" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "可以创建", body: "成功创建文章。" } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "Title:\n  可以创建"
end
```

让我们分解这个测试，以便我们可以理解它。

我们首先调用我们的Articles控制器上的`:new`动作。这个响应应该是成功的。

在此之后，我们向Articles控制器的`:create`动作发出一个post请求：

```ruby
post "/articles",
  params: { article: { title: "可以创建", body: "成功创建文章。" } }
assert_response :redirect
follow_redirect!
```

请求之后的两行是用来处理我们在创建新文章时设置的重定向。

注意：如果您计划在重定向后进行后续请求，请不要忘记调用`follow_redirect!`。

最后，我们可以断言我们的响应是成功的，我们的新文章在页面上可读。

#### 进一步

我们成功地测试了访问博客和创建新文章的一个非常小的工作流程。如果我们想进一步，我们可以为评论、删除文章或编辑评论添加测试。集成测试是一个很好的地方，可以尝试各种用例来测试我们应用程序的各种用途。
控制器的功能测试
-------------------

在Rails中，测试控制器的各种操作是一种编写功能测试的形式。请记住，您的控制器处理应用程序的传入Web请求，并最终以渲染的视图作为响应。在编写功能测试时，您正在测试操作如何处理请求以及预期的结果或响应，有时是HTML视图。

### 功能测试中应包含的内容

您应该测试以下内容：

* 网络请求是否成功？
* 用户是否被重定向到正确的页面？
* 用户是否成功通过身份验证？
* 视图中是否向用户显示了适当的消息？
* 响应中是否显示了正确的信息？

查看功能测试的最简单方法是使用脚手架生成器生成一个控制器：

```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

这将为`Article`资源生成控制器代码和测试。您可以查看`test/controllers`目录中的`articles_controller_test.rb`文件。

如果您已经有一个控制器，只想为每个默认操作生成测试脚手架代码，可以使用以下命令：

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

让我们来看一个这样的测试，`articles_controller_test.rb`文件中的`test_should_get_index`。

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

在`test_should_get_index`测试中，Rails模拟了对名为`index`的操作的请求，确保请求成功，并确保生成了正确的响应体。

`get`方法发起网络请求并将结果填充到`@response`中。它可以接受最多6个参数：

* 您正在请求的控制器操作的URI。可以是字符串形式或路由助手（例如`articles_url`）。
* `params`：选项，包含要传递给操作的请求参数的哈希（例如查询字符串参数或文章变量）。
* `headers`：用于设置将随请求传递的标头。
* `env`：用于根据需要自定义请求环境。
* `xhr`：请求是否为Ajax请求。可以将其设置为true以标记请求为Ajax请求。
* `as`：用于使用不同的内容类型对请求进行编码。

所有这些关键字参数都是可选的。

示例：调用第一个`Article`的`show`操作，并传入一个`HTTP_REFERER`标头：

```ruby
get article_url(Article.first), headers: { "HTTP_REFERER" => "http://example.com/home" }
```

另一个示例：调用最后一个`Article`的`update`操作，并在`params`中传入`title`的新文本，作为Ajax请求：

```ruby
patch article_url(Article.last), params: { article: { title: "updated" } }, xhr: true
```

再来一个示例：调用`create`操作以创建一个新文章，并在`params`中传入`title`的文本，作为JSON请求：

```ruby
post articles_path, params: { article: { title: "Ahoy!" } }, as: :json
```

注意：如果您尝试运行`articles_controller_test.rb`中的`test_should_create_article`测试，由于新增的模型级验证，测试将失败，这是正确的。

让我们修改`articles_controller_test.rb`中的`test_should_create_article`测试，以使所有测试都通过：

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }
  end

  assert_redirected_to article_path(Article.last)
end
```

现在，您可以尝试运行所有测试，它们应该都通过。

注意：如果您按照[基本身份验证](getting_started.html#basic-authentication)部分的步骤进行操作，您需要在每个请求标头中添加授权信息，以使所有测试都通过：

```ruby
post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
```

### 功能测试中可用的请求类型

如果您熟悉HTTP协议，您将知道`get`是一种请求类型。Rails功能测试支持6种请求类型：

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

所有请求类型都有相应的方法可供使用。在典型的C.R.U.D.应用程序中，您将更频繁地使用`get`，`post`，`put`和`delete`。
注意：功能测试不验证操作是否接受指定的请求类型，我们更关心结果。请求测试用例存在于这种情况下，以使您的测试更有目的性。

### 测试XHR（Ajax）请求

要测试Ajax请求，您可以在`get`，`post`，`patch`，`put`和`delete`方法中指定`xhr: true`选项。例如：

```ruby
test "ajax request" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal "hello world", @response.body
  assert_equal "text/javascript", @response.media_type
end
```

### 末日的三个哈希

在请求已经被发出并处理后，您将拥有3个准备好使用的哈希对象：

* `cookies` - 设置的任何cookie
* `flash` - 存储在flash中的任何对象
* `session` - 存储在会话变量中的任何对象

与普通的哈希对象一样，您可以通过字符串引用键来访问值。您也可以通过符号名称引用它们。例如：

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### 可用的实例变量

在发出请求**之后**，您的功能测试中还可以访问三个实例变量：

* `@controller` - 处理请求的控制器
* `@request` - 请求对象
* `@response` - 响应对象


```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Articles", @response.body
  end
end
```

### 设置头部和CGI变量

可以将[HTTP头部](https://tools.ietf.org/search/rfc2616#section-5.3)和[CGI变量](https://tools.ietf.org/search/rfc3875#section-4.1)作为头部传递：

```ruby
# 设置HTTP头部
get articles_url, headers: { "Content-Type": "text/plain" } # 模拟带有自定义头部的请求

# 设置CGI变量
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # 模拟带有自定义环境变量的请求
```

### 测试`flash`通知

如果您还记得之前的内容，末日的三个哈希之一是`flash`。

我们希望在成功创建新文章时，向我们的博客应用程序添加一个`flash`消息。

让我们首先将此断言添加到我们的`test_should_create_article`测试中：

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { title: "Some title" } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal "Article was successfully created.", flash[:notice]
end
```

如果我们现在运行测试，应该会看到一个失败：

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 32266

# Running:

F

Finished in 0.114870s, 8.7055 runs/s, 34.8220 assertions/s.

  1) Failure:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- expected
+++ actual
@@ -1 +1 @@
-"Article was successfully created."
+nil

1 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

现在让我们在控制器中实现flash消息。我们的`:create`动作现在应该如下所示：

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = "Article was successfully created."
    redirect_to @article
  else
    render "new"
  end
end
```

现在，如果我们运行测试，应该会看到它通过：

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 18981

# Running:

.

Finished in 0.081972s, 12.1993 runs/s, 48.7972 assertions/s.

1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### 将其整合起来

此时，我们的Articles控制器测试了`:index`以及`:new`和`:create`动作。那么如何处理现有数据呢？

让我们为`:show`动作编写一个测试：

```ruby
test "should show article" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

还记得我们之前在固定装置上讨论的吗，`articles()`方法将使我们能够访问我们的Articles装置数据。

那么如何删除现有的文章？

```ruby
test "should destroy article" do
  article = articles(:one)
  assert_difference("Article.count", -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

我们还可以添加一个测试来更新现有的文章。

```ruby
test "should update article" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "updated" } }

  assert_redirected_to article_path(article)
  # 重新加载关联以获取更新的数据，并断言标题已更新。
  article.reload
  assert_equal "updated", article.title
end
```

请注意，这三个测试中开始出现了一些重复，它们都访问相同的文章装置数据。我们可以通过使用`ActiveSupport::Callbacks`提供的`setup`和`teardown`方法来消除这种重复。

现在，我们的测试应该如下所示。暂时忽略其他测试，为了简洁起见，我们将它们省略了。
```ruby
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # 在每个测试之前调用
  setup do
    @article = articles(:one)
  end

  # 在每个测试之后调用
  teardown do
    # 当控制器使用缓存时，最好在之后重置缓存
    Rails.cache.clear
  end

  test "should show article" do
    # 重用来自 setup 的 @article 实例变量
    get article_url(@article)
    assert_response :success
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "should update article" do
    patch article_url(@article), params: { article: { title: "updated" } }

    assert_redirected_to article_path(@article)
    # 重新加载关联以获取更新的数据并断言标题已更新
    @article.reload
    assert_equal "updated", @article.title
  end
end
```

与 Rails 中的其他回调类似，`setup` 和 `teardown` 方法也可以通过传递块、lambda 或方法名作为符号来使用。

### 测试助手(duplicated)

为了避免代码重复，您可以添加自己的测试助手。
登录助手可以作为一个很好的例子：

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "should show profile" do
    # 现在助手可以在任何控制器测试用例中重用
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

#### 使用单独的文件

如果您发现助手在 `test_helper.rb` 中杂乱无章，您可以将它们提取到单独的文件中。
一个好的存储位置是 `test/lib` 或 `test/test_helpers`。

```ruby
# test/test_helpers/multiple_assertions.rb
module MultipleAssertions
  def assert_multiple_of_forty_two(number)
    assert (number % 42 == 0), "expected #{number} to be a multiple of 42"
  end
end
```

然后可以根据需要显式地引入这些助手并包含它们

```ruby
require "test_helper"
require "test_helpers/multiple_assertions"

class NumberTest < ActiveSupport::TestCase
  include MultipleAssertions

  test "420 is a multiple of forty two" do
    assert_multiple_of_forty_two 420
  end
end
```

或者可以直接包含到相关的父类中

```ruby
# test/test_helper.rb
require "test_helpers/sign_in_helper"

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

#### 预先引入助手

您可能会发现在 `test_helper.rb` 中预先引入助手很方便，这样您的测试文件就可以隐式地访问它们。可以使用 globbing 来实现这一点，如下所示

```ruby
# test/test_helper.rb
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }
```

这样做的缺点是会增加启动时间，而不是在每个测试中手动引入必要的文件。

测试路由
--------------

与 Rails 应用程序中的其他内容一样，您可以测试路由。路由测试位于 `test/controllers/` 中，或者是控制器测试的一部分。

注意：如果您的应用程序具有复杂的路由，Rails 提供了许多有用的辅助方法来测试它们。

有关 Rails 中可用的路由断言的更多信息，请参阅 [`ActionDispatch::Assertions::RoutingAssertions`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html) 的 API 文档。

测试视图
-------------

通过断言关键 HTML 元素及其内容的存在来测试请求的响应是测试应用程序视图的常见方法。与路由测试类似，视图测试位于 `test/controllers/` 中，或者是控制器测试的一部分。`assert_select` 方法允许您使用简单而强大的语法查询响应的 HTML 元素。

`assert_select` 有两种形式：

`assert_select(selector, [equality], [message])` 通过选择器确保所选元素满足等式条件。选择器可以是 CSS 选择器表达式（字符串）或带有替换值的表达式。

`assert_select(element, selector, [equality], [message])` 通过选择器从 _element_（`Nokogiri::XML::Node` 或 `Nokogiri::XML::NodeSet` 的实例）及其后代开始，确保所选元素满足等式条件。

例如，您可以使用以下代码验证响应中标题元素的内容：

```ruby
assert_select "title", "Welcome to Rails Testing Guide"
```

您还可以使用嵌套的 `assert_select` 块进行更深入的调查。

在下面的示例中，内部的 `assert_select` 用于在外部块选择的元素集合中运行：

```ruby
assert_select "ul.navigation" do
  assert_select "li.menu_item"
end
```

可以遍历所选元素的集合，以便可以为每个元素单独调用 `assert_select`。

例如，如果响应包含两个有四个嵌套列表元素的有序列表，则以下测试都将通过。

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

这个断言非常强大。要了解更高级的用法，请参考它的[文档](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb)。

### 额外的基于视图的断言

还有一些主要用于测试视图的断言：

| 断言                                                         | 目的                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `assert_select_email`                                         | 允许你对电子邮件的正文进行断言。                               |
| `assert_select_encoded`                                       | 允许你对编码的HTML进行断言。它通过对每个元素进行解码，然后使用所有未编码的元素调用块来实现。 |
| `css_select(selector)` 或 `css_select(element, selector)`     | 返回由_selector_选择的所有元素的数组。在第二种变体中，它首先匹配基本_element_，然后尝试在其任何子元素上匹配_selector_表达式。如果没有匹配项，两种变体都返回一个空数组。 |

这是使用`assert_select_email`的示例：

```ruby
assert_select_email do
  assert_select "small", "Please click the 'Unsubscribe' link if you want to opt-out."
end
```

测试助手
---------------

助手只是一个简单的模块，您可以在视图中定义可用的方法。

为了测试助手，您只需要检查助手方法的输出是否与您期望的一致。与助手相关的测试位于`test/helpers`目录下。

假设我们有以下助手：

```ruby
module UsersHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

我们可以像这样测试这个方法的输出：

```ruby
class UsersHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

此外，由于测试类扩展自`ActionView::TestCase`，您可以访问Rails的助手方法，如`link_to`或`pluralize`。

测试您的邮件发送器
--------------------

测试邮件发送器类需要一些特定的工具来完成彻底的工作。

### 保持邮递员的检查

您的邮件发送器类 - 就像您的Rails应用程序的其他部分一样 - 应该经过测试以确保它们按预期工作。

测试邮件发送器类的目标是确保：

* 邮件正在被处理（创建和发送）
* 邮件内容是正确的（主题、发件人、正文等）
* 正确的邮件在正确的时间发送

#### 从各个方面来看

测试邮件发送器有两个方面，即单元测试和功能测试。在单元测试中，您以严格控制的输入在隔离环境中运行邮件发送器，并将输出与已知值（固定装置）进行比较。在功能测试中，您不太关注邮件发送器产生的细节；相反，我们测试控制器和模型是否正确使用邮件发送器。您测试以证明正确的邮件在正确的时间发送。

### 单元测试

为了测试您的邮件发送器是否按预期工作，您可以使用单元测试将邮件发送器的实际结果与预先编写的示例进行比较。

#### 复仇的固定装置

为了进行邮件发送器的单元测试，固定装置用于提供输出应该是什么样子的示例。因为这些是示例邮件，而不是像其他固定装置那样的Active Record数据，所以它们被保留在与其他固定装置不同的子目录中。`test/fixtures`目录中的子目录的名称直接对应于邮件发送器的名称。因此，对于名为`UserMailer`的邮件发送器，固定装置应该位于`test/fixtures/user_mailer`目录中。

如果您生成了邮件发送器，生成器不会为邮件发送器的操作创建存根固定装置。您需要按照上述说明自己创建这些文件。

#### 基本测试用例

这是一个单元测试，用于测试名为`UserMailer`的邮件发送器的`invite`操作，该操作用于向朋友发送邀请。这是根据为`invite`操作生成器创建的基本测试的调整版本。

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 创建电子邮件并将其存储以进行进一步的断言
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # 发送电子邮件，然后测试它是否已排队
    assert_emails 1 do
      email.deliver_now
    end

    # 测试发送的电子邮件的正文是否包含我们期望的内容
    assert_equal ["me@example.com"], email.from
    assert_equal ["friend@example.com"], email.to
    assert_equal "You have been invited by me@example.com", email.subject
    assert_equal read_fixture("invite").join, email.body.to_s
  end
end
```
在测试中，我们创建了邮件并将返回的对象存储在`email`变量中。然后，我们确保它已发送（第一个断言），然后在第二批断言中，我们确保邮件确实包含我们期望的内容。辅助函数`read_fixture`用于从文件中读取内容。

注意：当只有一个（HTML或文本）部分存在时，`email.body.to_s`存在。如果邮件提供了两者，您可以使用`email.text_part.body.to_s`或`email.html_part.body.to_s`针对特定部分测试您的fixture。

这是`invite` fixture的内容：

```
Hi friend@example.com,

You have been invited.

Cheers!
```

现在是时候更多地了解如何为您的邮件编写测试了。在`config/environments/test.rb`中的`ActionMailer::Base.delivery_method = :test`行将传递方式设置为测试模式，因此邮件实际上不会被发送（在测试期间避免向用户发送垃圾邮件），而是会附加到一个数组（`ActionMailer::Base.deliveries`）中。

注意：`ActionMailer::Base.deliveries`数组仅在`ActionMailer::TestCase`和`ActionDispatch::IntegrationTest`测试中自动重置。如果您想在这些测试用例之外拥有一个干净的状态，可以使用`ActionMailer::Base.deliveries.clear`手动重置它。

#### 测试已入队的邮件

您可以使用`assert_enqueued_email_with`断言来确认邮件已使用预期的邮件方法参数和/或参数化的邮件参数入队。这允许您匹配使用`deliver_later`方法入队的任何邮件。

与基本测试用例一样，我们创建邮件并将返回的对象存储在`email`变量中。以下示例包括传递参数和/或参数的变化。

此示例将断言邮件已使用正确的参数入队：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 创建邮件并存储以进行进一步的断言
    email = UserMailer.create_invite("me@example.com", "friend@example.com")

    # 测试邮件是否已使用正确的参数入队
    assert_enqueued_email_with UserMailer, :create_invite, args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

此示例将断言已使用正确的邮件方法命名参数入队的邮件：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 创建邮件并存储以进行进一步的断言
    email = UserMailer.create_invite(from: "me@example.com", to: "friend@example.com")

    # 测试邮件是否已使用正确的命名参数入队
    assert_enqueued_email_with UserMailer, :create_invite, args: [{ from: "me@example.com",
                                                                    to: "friend@example.com" }] do
      email.deliver_later
    end
  end
end
```

此示例将断言已使用正确的参数和邮件方法参数入队的参数化邮件。邮件参数作为`params`传递，邮件方法参数作为`args`传递：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 创建邮件并存储以进行进一步的断言
    email = UserMailer.with(all: "good").create_invite("me@example.com", "friend@example.com")

    # 测试邮件是否已使用正确的邮件参数和参数入队
    assert_enqueued_email_with UserMailer, :create_invite, params: { all: "good" },
                                                           args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

此示例展示了测试参数化邮件已使用正确参数入队的另一种方法：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 创建邮件并存储以进行进一步的断言
    email = UserMailer.with(to: "friend@example.com").create_invite

    # 测试邮件是否已使用正确的邮件参数入队
    assert_enqueued_email_with UserMailer.with(to: "friend@example.com"), :create_invite do
      email.deliver_later
    end
  end
end
```

### 功能和系统测试

单元测试允许我们测试邮件的属性，而功能和系统测试允许我们测试用户交互是否适当地触发邮件的发送。例如，您可以检查邀请朋友操作是否适当地发送了一封邮件：

```ruby
# 集成测试
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    # 断言ActionMailer::Base.deliveries的差异
    assert_emails 1 do
      post invite_friend_url, params: { email: "friend@example.com" }
    end
  end
end
```

```ruby
# 系统测试
require "test_helper"

class UsersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "inviting a friend" do
    visit invite_users_url
    fill_in "Email", with: "friend@example.com"
    assert_emails 1 do
      click_on "Invite"
    end
  end
end
```

注意：`assert_emails`方法不与特定的传递方法绑定，可以与使用`deliver_now`或`deliver_later`方法发送的邮件一起使用。如果我们明确希望断言邮件已入队，可以使用`assert_enqueued_email_with`（[上面的示例](#testing-enqueued-emails)）或`assert_enqueued_emails`方法。更多信息可以在[此处的文档](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html)中找到。
测试工作
------------

由于您的自定义作业可以在应用程序中的不同级别排队，因此您需要测试作业本身（它们在排队时的行为）以及其他实体是否正确地将它们排队。

### 基本测试用例

默认情况下，当您生成一个作业时，一个关联的测试也会生成在`test/jobs`目录下。以下是一个带有计费作业的示例测试：

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "账户已收费" do
    BillingJob.perform_now(account, product)
    assert account.reload.charged_for?(product)
  end
end
```

这个测试非常简单，只断言作业是否按预期工作。

### 自定义断言和在其他组件中测试作业

Active Job附带了一系列自定义断言，可以用来减少测试的冗长性。有关可用断言的完整列表，请参阅[`ActiveJob::TestHelper`](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html)的API文档。

确保作业在调用它们的地方（例如在控制器内部）正确地排队或执行是一个好习惯。这正是Active Job提供的自定义断言非常有用的地方。例如，在模型内部，您可以确认作业是否已排队：

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "计费作业调度" do
    assert_enqueued_with(job: BillingJob) do
      product.charge(account)
    end
    assert_not account.reload.charged_for?(product)
  end
end
```

默认适配器`：test`在作业排队时不执行作业。您必须告诉它何时执行作业：

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "计费作业调度" do
    perform_enqueued_jobs(only: BillingJob) do
      product.charge(account)
    end
    assert account.reload.charged_for?(product)
  end
end
```

在任何测试运行之前，之前执行和排队的所有作业都会被清除，因此您可以安全地假设在每个测试范围内尚未执行任何作业。

测试Action Cable
--------------------

由于Action Cable在应用程序的不同级别上使用，因此您需要测试通道、连接类本身以及其他实体是否广播正确的消息。

### 连接测试用例

默认情况下，当您使用Action Cable生成新的Rails应用程序时，基本连接类（`ApplicationCable::Connection`）的测试也会生成在`test/channels/application_cable`目录下。

连接测试旨在检查连接的标识是否被正确分配，或者是否拒绝了任何不正确的连接请求。以下是一个示例：

```ruby
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "带参数连接" do
    # 通过调用`connect`方法模拟连接打开
    connect params: { user_id: 42 }

    # 您可以通过测试中的`connection`访问Connection对象
    assert_equal connection.user_id, "42"
  end

  test "拒绝没有参数的连接" do
    # 使用`assert_reject_connection`匹配器来验证连接是否被拒绝
    assert_reject_connection { connect }
  end
end
```

您还可以以与集成测试相同的方式指定请求cookie：

```ruby
test "带cookie连接" do
  cookies.signed[:user_id] = "42"

  connect

  assert_equal connection.user_id, "42"
end
```

有关更多信息，请参阅[`ActionCable::Connection::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html)的API文档。

### 通道测试用例

默认情况下，当您生成一个通道时，一个关联的测试也会生成在`test/channels`目录下。以下是一个带有聊天通道的示例测试：

```ruby
require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  test "订阅并为房间流" do
    # 通过调用`subscribe`模拟订阅创建
    subscribe room: "15"

    # 您可以通过测试中的`subscription`访问Channel对象
    assert subscription.confirmed?
    assert_has_stream "chat_15"
  end
end
```

这个测试非常简单，只断言通道将连接订阅到特定的流。

您还可以指定底层连接标识符。以下是一个带有Web通知通道的示例测试：

```ruby
require "test_helper"

class WebNotificationsChannelTest < ActionCable::Channel::TestCase
  test "订阅并为用户流" do
    stub_connection current_user: users(:john)

    subscribe

    assert_has_stream_for users(:john)
  end
end
```

有关更多信息，请参阅[`ActionCable::Channel::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html)的API文档。

### 自定义断言和在其他组件中测试广播

Action Cable附带了一系列自定义断言，可以用来减少测试的冗长性。有关可用断言的完整列表，请参阅[`ActionCable::TestHelper`](https://api.rubyonrails.org/classes/ActionCable/TestHelper.html)的API文档。

确保正确的消息已在其他组件（例如在控制器内部）中广播是一个好习惯。这正是Action Cable提供的自定义断言非常有用的地方。例如，在模型内部：
```ruby
require "test_helper"

class ProductTest < ActionCable::TestCase
  test "充值后广播状态" do
    assert_broadcast_on("products:#{product.id}", type: "charged") do
      product.charge(account)
    end
  end
end
```

如果你想测试使用`Channel.broadcast_to`进行的广播，你应该使用`Channel.broadcasting_for`来生成底层流名称：

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end
```

```ruby
# test/jobs/chat_relay_job_test.rb
require "test_helper"

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "向房间广播消息" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "Hi!") do
      ChatRelayJob.perform_now(room, "Hi!")
    end
  end
end
```

测试急加载
---------------------

通常，应用程序在`development`或`test`环境中不会进行急加载以加快速度。但在`production`环境中会进行急加载。

如果项目中的某个文件由于某种原因无法加载，最好在部署到生产环境之前检测到它，对吧？

### 持续集成

如果您的项目已经有了持续集成，那么在持续集成中进行急加载是一种简单的方法来确保应用程序进行急加载。

持续集成通常会设置一些环境变量来指示测试套件正在运行。例如，可以是`CI`：

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

从Rails 7开始，新生成的应用程序默认配置为这种方式。

### 纯净的测试套件

如果您的项目没有持续集成，您仍然可以通过调用`Rails.application.eager_load!`来在测试套件中进行急加载：

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "急加载所有文件时不会出错" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk compliance" do
  it "急加载所有文件时不会出错" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

其他测试资源
----------------------------

### 测试与时间相关的代码

Rails提供了内置的辅助方法，使您能够断言您的时间敏感代码是否按预期工作。

以下示例使用了[`travel_to`][travel_to]辅助方法：

```ruby
# 假设用户在注册后一个月有资格赠送。
user = User.create(name: "Gaurish", activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?

travel_to Date.new(2004, 11, 24) do
  # 在`travel_to`块内，`Date.current`被存根
  assert_equal Date.new(2004, 10, 24), user.activation_date
  assert user.applicable_for_gifting?
end

# 更改只在`travel_to`块内可见。
assert_equal Date.new(2004, 10, 24), user.activation_date
```

有关可用时间辅助方法的更多信息，请参阅[`ActiveSupport::Testing::TimeHelpers`][time_helpers_api] API参考。
[`config.active_support.test_order`]: configuring.html#config-active-support-test-order
[image/png]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types
[travel_to]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to
[time_helpers_api]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html
