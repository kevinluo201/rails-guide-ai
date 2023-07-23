**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0651830a9dc9cbd4e8a1fddab047c719
建立和自訂 Rails 產生器和模板
==============================

Rails 產生器是提升工作流程的重要工具。透過本指南，您將學習如何建立產生器並自訂現有的產生器。

閱讀完本指南後，您將了解：

* 如何查看應用程式中可用的產生器。
* 如何使用模板建立產生器。
* Rails 在呼叫產生器之前如何搜尋產生器。
* 如何透過覆寫產生器模板自訂您的腳手架。
* 如何透過覆寫產生器自訂您的腳手架。
* 如何使用回退以避免覆寫大量的產生器。
* 如何建立應用程式模板。

--------------------------------------------------------------------------------

初次接觸
--------

當您使用 `rails` 命令建立應用程式時，實際上是在使用一個 Rails 產生器。接著，您可以透過呼叫 `bin/rails generate` 來取得所有可用的產生器清單：

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

注意：建立 Rails 應用程式時，我們使用全域的 `rails` 命令，該命令使用透過 `gem install rails` 安裝的 Rails 版本。當在應用程式目錄中時，我們使用 `bin/rails` 命令，該命令使用應用程式所附帶的 Rails 版本。

您將取得一個包含 Rails 所有產生器的清單。要查看特定產生器的詳細描述，請使用 `--help` 選項呼叫該產生器。例如：

```bash
$ bin/rails generate scaffold --help
```

建立您的第一個產生器
--------------------

產生器是建立在 [Thor](https://github.com/rails/thor) 之上的，它提供了強大的選項解析功能和一個很棒的檔案操作 API。

讓我們建立一個產生器，該產生器會在 `config/initializers` 目錄下建立一個名為 `initializer.rb` 的初始化檔案。第一步是在 `lib/generators/initializer_generator.rb` 建立一個檔案，內容如下：

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # 在此加入初始化內容
    RUBY
  end
end
```

我們的新產生器非常簡單：它繼承自 [`Rails::Generators::Base`][]，並有一個方法定義。當產生器被呼叫時，產生器中的每個公開方法都會按照定義的順序依序執行。我們的方法呼叫了 [`create_file`][]，該方法會在指定的目的地建立一個具有指定內容的檔案。

要呼叫我們的新產生器，執行以下命令：

```bash
$ bin/rails generate initializer
```

在繼續之前，讓我們看看我們的新產生器的描述：

```bash
$ bin/rails generate initializer --help
```

通常情況下，Rails 能夠根據產生器的命名空間（例如 `ActiveRecord::Generators::ModelGenerator`）推斷出一個良好的描述，但在這種情況下無法推斷。我們可以以兩種方式解決這個問題。第一種方式是在產生器內部呼叫 [`desc`][] 來添加描述：

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "This generator creates an initializer file at config/initializers"
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # 在此加入初始化內容
    RUBY
  end
end
```

現在，我們可以透過在新產生器上呼叫 `--help` 來看到新描述。

第二種添加描述的方式是在與產生器相同目錄下建立一個名為 `USAGE` 的檔案。我們將在下一步中執行這個方式。


使用產生器建立產生器
-------------------

產生器本身也有一個產生器。讓我們刪除我們的 `InitializerGenerator`，並使用 `bin/rails generate generator` 來生成一個新的產生器：

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

這是剛剛生成的產生器：

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
end
```

首先，請注意這個產生器繼承自 [`Rails::Generators::NamedBase`][] 而不是 `Rails::Generators::Base`。這意味著我們的產生器期望至少一個參數，該參數將是初始化檔案的名稱，並且可以透過 `name` 在我們的程式中使用。

我們可以透過檢查新產生器的描述來確認這一點：

```bash
$ bin/rails generate initializer --help
Usage:
  bin/rails generate initializer NAME [options]
```

此外，請注意產生器有一個名為 [`source_root`][] 的類別方法。此方法指向我們的模板位置（如果有的話）。預設情況下，它指向剛剛建立的 `lib/generators/initializer/templates` 目錄。

為了理解產生器模板的工作原理，讓我們建立一個檔案 `lib/generators/initializer/templates/initializer.rb`，內容如下：

```ruby
# 在此加入初始化內容
```

並讓產生器在被呼叫時複製此模板：
```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

現在讓我們運行我們的生成器：

```bash
$ bin/rails generate initializer core_extensions
      create  config/initializers/core_extensions.rb

$ cat config/initializers/core_extensions.rb
# 在這裡添加初始化內容
```

我們可以看到[`copy_file`][]創建了`config/initializers/core_extensions.rb`，並將模板的內容複製到其中。（在目標路徑中使用的`file_name`方法是從`Rails::Generators::NamedBase`繼承的。）

生成器命令行選項
------------------------------

生成器可以使用[`class_option`][]支持命令行選項。例如：

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  class_option :scope, type: :string, default: "app"
end
```

現在我們的生成器可以使用`--scope`選項調用：

```bash
$ bin/rails generate initializer theme --scope dashboard
```

選項值可以通過[`options`][]在生成器方法中訪問：

```ruby
def copy_initializer_file
  @scope = options["scope"]
end
```


生成器解析
--------------------

在解析生成器的名稱時，Rails會使用多個文件名查找生成器。例如，當您運行`bin/rails generate initializer core_extensions`時，Rails會嘗試按順序加載以下每個文件，直到找到一個：

* `rails/generators/initializer/initializer_generator.rb`
* `generators/initializer/initializer_generator.rb`
* `rails/generators/initializer_generator.rb`
* `generators/initializer_generator.rb`

如果找不到任何一個文件，將引發錯誤。

我們將生成器放在應用程序的`lib/`目錄中，因為該目錄在`$LOAD_PATH`中，因此允許Rails找到並加載該文件。

覆蓋Rails生成器模板
------------------------------------

Rails在解析生成器模板文件時還會在多個位置查找。其中之一是應用程序的`lib/templates/`目錄。這種行為允許我們覆蓋Rails內置生成器使用的模板。例如，我們可以覆蓋[scaffold controller模板][]或[scaffold view模板][]。

為了看到這一點，讓我們創建一個`lib/templates/erb/scaffold/index.html.erb.tt`文件，內容如下：

```erb
<%% @<%= plural_table_name %>.count %> <%= human_name.pluralize %>
```

請注意，該模板是一個ERB模板，用於呈現_另一個_ERB模板。因此，在_生成器_模板中，任何應出現在_生成的_模板中的`<%`都必須作為`<%%`進行轉義。

現在讓我們運行Rails內置的scaffold生成器：

```bash
$ bin/rails generate scaffold Post title:string
      ...
      create      app/views/posts/index.html.erb
      ...
```

`app/views/posts/index.html.erb`的內容如下：

```erb
<% @posts.count %> Posts
```

[scaffold controller模板]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt
[scaffold view模板]: https://github.com/rails/rails/tree/main/railties/lib/rails/generators/erb/scaffold/templates

覆蓋Rails生成器
---------------------------

可以通過[`config.generators`][]配置Rails內置生成器，包括完全覆蓋某些生成器。

首先，讓我們更仔細地看一下scaffold生成器的工作原理。

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

從輸出中，我們可以看到scaffold生成器調用其他生成器，例如`scaffold_controller`生成器。其中一些生成器也會調用其他生成器。特別是`scaffold_controller`生成器調用了幾個其他生成器，包括`helper`生成器。

讓我們使用新生成器覆蓋內置的`helper`生成器。我們將生成器命名為`my_helper`：

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/rails/my_helper_generator_test.rb
```

在`lib/generators/rails/my_helper/my_helper_generator.rb`中，我們將定義生成器如下：

```ruby
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<~RUBY
      module #{class_name}Helper
        # 我在幫助！
      end
    RUBY
  end
end
```

最後，我們需要告訴Rails使用`my_helper`生成器而不是內置的`helper`生成器。為此，我們使用`config.generators`。在`config/application.rb`中，讓我們添加：

```ruby
config.generators do |g|
  g.helper :my_helper
end
```

現在，如果我們再次運行scaffold生成器，我們可以看到`my_helper`生成器的效果：

```bash
$ bin/rails generate scaffold Article body:text
      ...
      invoke  scaffold_controller
      ...
      invoke    my_helper
      create      app/helpers/articles_helper.rb
      ...
```

注意：您可能會注意到內置的`helper`生成器的輸出中包含“invoke test_unit”，而`my_helper`的輸出中沒有。儘管`helper`生成器不會默認生成測試，但它提供了使用[`hook_for`][]生成測試的鉤子。我們可以在`MyHelperGenerator`類中包含`hook_for :test_framework, as: :helper`來完成相同的操作。有關更多信息，請參閱`hook_for`文檔。


### 生成器回退

覆蓋特定生成器的另一種方法是使用_回退_。回退允許生成器命名空間委派給另一個生成器命名空間。
例如，假設我們想要覆蓋 `test_unit:model` 產生器，使用我們自己的 `my_test_unit:model` 產生器，但我們不想替換所有其他的 `test_unit:*` 產生器，例如 `test_unit:controller`。

首先，我們在 `lib/generators/my_test_unit/model/model_generator.rb` 中創建 `my_test_unit:model` 產生器：

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

接下來，我們使用 `config.generators` 將 `test_framework` 產生器配置為 `my_test_unit`，但我們還配置了一個後備，以便任何缺少的 `my_test_unit:*` 產生器都解析為 `test_unit:*`：

```ruby
config.generators do |g|
  g.test_framework :my_test_unit, fixture: false
  g.fallbacks[:my_test_unit] = :test_unit
end
```

現在，當我們運行 scaffold 產生器時，我們可以看到 `my_test_unit` 已經取代了 `test_unit`，但只有模型測試受到影響：

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

應用程式模板
---------------------

應用程式模板是一種特殊類型的產生器。它們可以使用所有的[產生器輔助方法](#generator-helper-methods)，但是它們是以 Ruby 腳本的形式而不是 Ruby 類的形式編寫的。以下是一個示例：

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

首先，模板會詢問用戶是否要安裝 Devise。如果用戶回答 "yes"（或 "y"），模板會將 Devise 添加到 `Gemfile`，並要求用戶指定 Devise 使用者模型的名稱（默認為 `User`）。稍後，在運行 `bundle install` 之後，如果指定了 Devise 模型，模板將運行 Devise 產生器和 `rails db:migrate`。最後，模板將使用 `git add` 和 `git commit` 提交整個應用程式目錄。

我們可以通過將 `-m` 選項傳遞給 `rails new` 命令來在生成新的 Rails 應用程式時運行我們的模板：

```bash
$ rails new my_cool_app -m path/to/template.rb
```

或者，我們可以在現有應用程式中使用 `bin/rails app:template` 命令運行我們的模板：

```bash
$ bin/rails app:template LOCATION=path/to/template.rb
```

模板也不需要存儲在本地 - 您可以指定 URL 而不是路徑：

```bash
$ rails new my_cool_app -m http://example.com/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

產生器輔助方法
------------------------

Thor 通過 [`Thor::Actions`][] 提供了許多產生器輔助方法，例如：

* [`copy_file`][]
* [`create_file`][]
* [`gsub_file`][]
* [`insert_into_file`][]
* [`inside`][]

除了這些方法，Rails 還通過 [`Rails::Generators::Actions`][] 提供了許多輔助方法，例如：

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
