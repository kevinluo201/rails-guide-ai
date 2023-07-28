**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0651830a9dc9cbd4e8a1fddab047c719
创建和自定义Rails生成器和模板
==============================

Rails生成器是改善工作流程的重要工具。通过本指南，您将学习如何创建生成器并自定义现有生成器。

阅读本指南后，您将了解以下内容：

* 如何查看应用程序中可用的生成器。
* 如何使用模板创建生成器。
* Rails在调用生成器之前如何搜索生成器。
* 如何通过覆盖生成器模板来自定义脚手架。
* 如何通过覆盖生成器来自定义脚手架。
* 如何使用回退来避免覆盖大量生成器。
* 如何创建应用程序模板。

--------------------------------------------------------------------------------

首次接触
-------

使用`rails`命令创建应用程序时，实际上是使用了一个Rails生成器。之后，您可以通过调用`bin/rails generate`来获取所有可用生成器的列表：

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

注意：要创建Rails应用程序，我们使用`rails`全局命令，该命令使用通过`gem install rails`安装的Rails版本。在应用程序目录中，我们使用`bin/rails`命令，该命令使用与应用程序捆绑的Rails版本。

您将获得一个包含Rails提供的所有生成器的列表。要查看特定生成器的详细描述，请使用`--help`选项调用生成器。例如：

```bash
$ bin/rails generate scaffold --help
```

创建您的第一个生成器
-------------------

生成器是基于[Thor](https://github.com/rails/thor)构建的，它提供了强大的选项解析和用于操作文件的API。

让我们构建一个生成器，它在`config/initializers`目录下创建一个名为`initializer.rb`的初始化文件。第一步是在`lib/generators/initializer_generator.rb`中创建一个文件，内容如下：

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # 在这里添加初始化内容
    RUBY
  end
end
```

我们的新生成器非常简单：它继承自[`Rails::Generators::Base`][]，并且有一个方法定义。当调用生成器时，生成器中的每个公共方法按照定义的顺序依次执行。我们的方法调用了[`create_file`][]，它将在给定的目标位置创建一个具有给定内容的文件。

要调用我们的新生成器，我们运行：

```bash
$ bin/rails generate initializer
```

在继续之前，让我们看一下我们的新生成器的描述：

```bash
$ bin/rails generate initializer --help
```

如果生成器有命名空间，例如`ActiveRecord::Generators::ModelGenerator`，Rails通常能够推导出一个好的描述，但在这种情况下不能。我们可以通过两种方式解决这个问题。第一种方式是在生成器内部调用[`desc`][]来添加描述：

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "This generator creates an initializer file at config/initializers"
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # 在这里添加初始化内容
    RUBY
  end
end
```

现在，我们可以通过在新生成器上调用`--help`来看到新的描述。

添加描述的第二种方式是在与生成器相同的目录中创建一个名为`USAGE`的文件。我们将在下一步中执行此操作。


使用生成器创建生成器
-------------------

生成器本身也有一个生成器。让我们删除我们的`InitializerGenerator`，并使用`bin/rails generate generator`来生成一个新的生成器：

```bash
$ rm lib/generators/initializer_generator.rb

$ bin/rails generate generator initializer
      create  lib/generators/initializer
      create  lib/generators/initializer/initializer_generator.rb
      create  lib/generators/initializer/USAGE
      create  lib/generators/initializer/templates
      invoke  test_unit
      create    test/lib/generators/initializer_generator_test.rb
```

这是刚刚创建的生成器：

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
end
```

首先，注意生成器继承自[`Rails::Generators::NamedBase`][]，而不是`Rails::Generators::Base`。这意味着我们的生成器期望至少一个参数，该参数将是初始化程序的名称，并且可以通过`name`在我们的代码中使用。

我们可以通过检查新生成器的描述来看到这一点：

```bash
$ bin/rails generate initializer --help
Usage:
  bin/rails generate initializer NAME [options]
```

另外，请注意生成器有一个名为[`source_root`][]的类方法。此方法指向我们的模板的位置（如果有）。默认情况下，它指向刚刚创建的`lib/generators/initializer/templates`目录。

为了理解生成器模板的工作原理，让我们创建文件`lib/generators/initializer/templates/initializer.rb`，内容如下：

```ruby
# 在这里添加初始化内容
```

并且让我们更改生成器以在调用时复制此模板：
```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

现在让我们运行我们的生成器：

```bash
$ bin/rails generate initializer core_extensions
      create  config/initializers/core_extensions.rb

$ cat config/initializers/core_extensions.rb
# 在这里添加初始化内容
```

我们可以看到[`copy_file`][]创建了`config/initializers/core_extensions.rb`并将模板的内容复制到了其中。（在目标路径中使用的`file_name`方法是从`Rails::Generators::NamedBase`继承而来的。）

生成器命令行选项
------------------------------

生成器可以使用[`class_option`][]来支持命令行选项。例如：

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  class_option :scope, type: :string, default: "app"
end
```

现在我们的生成器可以使用`--scope`选项调用：

```bash
$ bin/rails generate initializer theme --scope dashboard
```

选项的值可以通过[`options`][]在生成器方法中访问：

```ruby
def copy_initializer_file
  @scope = options["scope"]
end
```


生成器解析
--------------------

在解析生成器名称时，Rails会使用多个文件名来查找生成器。例如，当你运行`bin/rails generate initializer core_extensions`时，Rails会按顺序尝试加载以下每个文件，直到找到一个为止：

* `rails/generators/initializer/initializer_generator.rb`
* `generators/initializer/initializer_generator.rb`
* `rails/generators/initializer_generator.rb`
* `generators/initializer_generator.rb`

如果找不到任何一个文件，将会引发错误。

我们将生成器放在应用程序的`lib/`目录中，因为该目录在`$LOAD_PATH`中，这样Rails就可以找到并加载该文件。

覆盖Rails生成器模板
------------------------------------

Rails在解析生成器模板文件时也会查找多个位置。其中之一是应用程序的`lib/templates/`目录。这个行为允许我们覆盖Rails内置生成器使用的模板。例如，我们可以覆盖[scaffold controller模板][]或[scaffold视图模板][]。

为了看到这个过程，让我们创建一个`lib/templates/erb/scaffold/index.html.erb.tt`文件，内容如下：

```erb
<%% @<%= plural_table_name %>.count %> <%= human_name.pluralize %>
```

注意，模板是一个ERB模板，用于渲染_另一个_ERB模板。因此，在_生成器_模板中，任何应该出现在_结果_模板中的`<%`必须转义为`<%%`。

现在让我们运行Rails内置的scaffold生成器：

```bash
$ bin/rails generate scaffold Post title:string
      ...
      create      app/views/posts/index.html.erb
      ...
```

`app/views/posts/index.html.erb`的内容是：

```erb
<% @posts.count %> Posts
```

[scaffold controller模板]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt
[scaffold视图模板]: https://github.com/rails/rails/tree/main/railties/lib/rails/generators/erb/scaffold/templates

覆盖Rails生成器
---------------------------

可以通过[`config.generators`][]配置Rails内置生成器，包括完全覆盖某些生成器。

首先，让我们更详细地了解scaffold生成器的工作原理。

```bash
$ bin/rails generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20230518000000_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      invoke  resource_route
       route    resources :users
      invoke  scaffold_controller
      create    app/controllers/users_controller.rb
      invoke    erb
      create      app/views/users
      create      app/views/users/index.html.erb
      create      app/views/users/edit.html.erb
      create      app/views/users/show.html.erb
      create      app/views/users/new.html.erb
      create      app/views/users/_form.html.erb
      create      app/views/users/_user.html.erb
      invoke    resource_route
      invoke    test_unit
      create      test/controllers/users_controller_test.rb
      create      test/system/users_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke      test_unit
      invoke    jbuilder
      create      app/views/users/index.json.jbuilder
      create      app/views/users/show.json.jbuilder
```

从输出中，我们可以看到scaffold生成器调用了其他生成器，比如`scaffold_controller`生成器。而其中一些生成器也会调用其他生成器。特别是`scaffold_controller`生成器调用了几个其他生成器，包括`helper`生成器。

让我们用一个新的生成器覆盖内置的`helper`生成器。我们将生成器命名为`my_helper`：

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/rails/my_helper_generator_test.rb
```

在`lib/generators/rails/my_helper/my_helper_generator.rb`中，我们将定义生成器如下：

```ruby
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<~RUBY
      module #{class_name}Helper
        # 我在帮助！
      end
    RUBY
  end
end
```

最后，我们需要告诉Rails使用`my_helper`生成器而不是内置的`helper`生成器。为此，我们使用`config.generators`。在`config/application.rb`中，让我们添加：

```ruby
config.generators do |g|
  g.helper :my_helper
end
```

现在，如果我们再次运行scaffold生成器，我们会看到`my_helper`生成器的效果：

```bash
$ bin/rails generate scaffold Article body:text
      ...
      invoke  scaffold_controller
      ...
      invoke    my_helper
      create      app/helpers/articles_helper.rb
      ...
```

注意：你可能会注意到内置的`helper`生成器的输出中包含了"invoke test_unit"，而`my_helper`的输出中没有。尽管`helper`生成器默认不生成测试，但它提供了一个使用[`hook_for`][]的钩子来生成测试的方法。我们可以在`MyHelperGenerator`类中包含`hook_for :test_framework, as: :helper`来实现相同的功能。有关更多信息，请参阅`hook_for`文档。


### 生成器回退

覆盖特定生成器的另一种方法是使用_回退_。回退允许一个生成器命名空间委托给另一个生成器命名空间。
例如，假设我们想要覆盖`test_unit:model`生成器，使用我们自己的`my_test_unit:model`生成器，但我们不想替换所有其他的`test_unit:*`生成器，比如`test_unit:controller`。

首先，我们在`lib/generators/my_test_unit/model/model_generator.rb`中创建`my_test_unit:model`生成器：

```ruby
module MyTestUnit
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def do_different_stuff
      say "Doing different stuff..."
    end
  end
end
```

接下来，我们使用`config.generators`将`test_framework`生成器配置为`my_test_unit`，但我们还配置了一个回退，以便任何缺失的`my_test_unit:*`生成器都解析为`test_unit:*`：

```ruby
config.generators do |g|
  g.test_framework :my_test_unit, fixture: false
  g.fallbacks[:my_test_unit] = :test_unit
end
```

现在，当我们运行脚手架生成器时，我们可以看到`my_test_unit`已经替换了`test_unit`，但只有模型测试受到了影响：

```bash
$ bin/rails generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20230518000000_create_comments.rb
      create    app/models/comment.rb
      invoke    my_test_unit
    Doing different stuff...
      invoke  resource_route
       route    resources :comments
      invoke  scaffold_controller
      create    app/controllers/comments_controller.rb
      invoke    erb
      create      app/views/comments
      create      app/views/comments/index.html.erb
      create      app/views/comments/edit.html.erb
      create      app/views/comments/show.html.erb
      create      app/views/comments/new.html.erb
      create      app/views/comments/_form.html.erb
      create      app/views/comments/_comment.html.erb
      invoke    resource_route
      invoke    my_test_unit
      create      test/controllers/comments_controller_test.rb
      create      test/system/comments_test.rb
      invoke    helper
      create      app/helpers/comments_helper.rb
      invoke      my_test_unit
      invoke    jbuilder
      create      app/views/comments/index.json.jbuilder
      create      app/views/comments/show.json.jbuilder
```

应用模板
---------------------

应用模板是一种特殊类型的生成器。它们可以使用所有的[生成器辅助方法](#generator-helper-methods)，但是它们是以Ruby脚本的形式编写，而不是以Ruby类的形式。下面是一个示例：

```ruby
# template.rb

if yes?("Would you like to install Devise?")
  gem "devise"
  devise_model = ask("What would you like the user model to be called?", default: "User")
end

after_bundle do
  if devise_model
    generate "devise:install"
    generate "devise", devise_model
    rails_command "db:migrate"
  end

  git add: ".", commit: %(-m 'Initial commit')
end
```

首先，模板询问用户是否要安装Devise。如果用户回答“是”（或“y”），模板将Devise添加到`Gemfile`，并询问Devise用户模型的名称（默认为`User`）。稍后，在运行了`bundle install`之后，模板将运行Devise生成器和`rails db:migrate`（如果指定了Devise模型）。最后，模板将`git add`和`git commit`整个应用目录。

我们可以通过在`rails new`命令中传递`-m`选项来在生成新的Rails应用程序时运行我们的模板：

```bash
$ rails new my_cool_app -m path/to/template.rb
```

或者，我们可以在现有应用程序中使用`bin/rails app:template`来运行我们的模板：

```bash
$ bin/rails app:template LOCATION=path/to/template.rb
```

模板也不需要存储在本地 - 您可以指定一个URL而不是路径：

```bash
$ rails new my_cool_app -m http://example.com/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

生成器辅助方法
------------------------

Thor通过[`Thor::Actions`][]提供了许多生成器辅助方法，例如：

* [`copy_file`][]
* [`create_file`][]
* [`gsub_file`][]
* [`insert_into_file`][]
* [`inside`][]

除了这些方法，Rails还通过[`Rails::Generators::Actions`][]提供了许多辅助方法，例如：

* [`environment`][]
* [`gem`][]
* [`generate`][]
* [`git`][]
* [`initializer`][]
* [`lib`][]
* [`rails_command`][]
* [`rake`][]
* [`route`][]
[`Rails::Generators::Base`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html
[`Thor::Actions`]: https://www.rubydoc.info/gems/thor/Thor/Actions
[`create_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#create_file-instance_method
[`desc`]: https://www.rubydoc.info/gems/thor/Thor#desc-class_method
[`Rails::Generators::NamedBase`]: https://api.rubyonrails.org/classes/Rails/Generators/NamedBase.html
[`copy_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#copy_file-instance_method
[`source_root`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-source_root
[`class_option`]: https://www.rubydoc.info/gems/thor/Thor/Base/ClassMethods#class_option-instance_method
[`options`]: https://www.rubydoc.info/gems/thor/Thor/Base#options-instance_method
[`config.generators`]: configuring.html#configuring-generators
[`hook_for`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-hook_for
[`Rails::Generators::Actions`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html
[`environment`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-environment
[`gem`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-gem
[`generate`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-generate
[`git`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-git
[`gsub_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#gsub_file-instance_method
[`initializer`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-initializer
[`insert_into_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#insert_into_file-instance_method
[`inside`]: https://www.rubydoc.info/gems/thor/Thor/Actions#inside-instance_method
[`lib`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-lib
[`rails_command`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rails_command
[`rake`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rake
[`route`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-route
