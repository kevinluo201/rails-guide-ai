**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2aedcd7fcf6f0b83538e8a8220d38afd
使用引擎入门
============================

在本指南中，您将学习有关引擎的知识，以及如何通过一个干净且非常易于使用的界面为其主机应用程序提供附加功能。

阅读本指南后，您将了解：

* 引擎的特点。
* 如何生成引擎。
* 如何为引擎构建功能。
* 如何将引擎挂接到应用程序中。
* 如何在应用程序中覆盖引擎功能。
* 如何使用加载和配置钩子避免加载Rails框架。

--------------------------------------------------------------------------------

什么是引擎？
-----------------

引擎可以被视为为其主机应用程序提供功能的微型应用程序。Rails应用程序实际上只是一个“超级”引擎，其中`Rails::Application`类继承了大部分行为从`Rails::Engine`继承而来。

因此，引擎和应用程序可以被认为几乎是相同的东西，只是有细微的差别，正如您在本指南中所看到的。引擎和应用程序还共享一个共同的结构。

引擎与插件也密切相关。两者共享一个共同的`lib`目录结构，并且都是使用`rails plugin new`生成器生成的。不同之处在于，引擎被Rails认为是一个“完整的插件”（如生成器命令中传递的`--full`选项所示）。在本指南中，我们将使用`--mountable`选项，它包括了`--full`的所有功能，以及更多功能。本指南将在整个过程中简称这些“完整的插件”为“引擎”。引擎**可以**是插件，插件**可以**是引擎。

本指南中将创建的引擎将被称为“blorgh”。该引擎将为其主机应用程序提供博客功能，允许创建新文章和评论。在本指南的开始阶段，您将仅在引擎本身中工作，但在后面的部分中，您将看到如何将其挂接到应用程序中。

引擎还可以与其主机应用程序隔离。这意味着应用程序可以使用由路由助手（例如`articles_path`）提供的路径，并使用同样被称为`articles_path`的引擎提供的路径，而两者不会冲突。除此之外，控制器、模型和表名也是有命名空间的。您将在本指南的后面看到如何做到这一点。

始终要牢记的重要一点是，应用程序应始终优先于其引擎。应用程序是在其环境中拥有最终决定权的对象。引擎只应增强应用程序，而不应对其进行重大更改。

要查看其他引擎的演示，请查看[Devise](https://github.com/plataformatec/devise)，这是一个为其父应用程序提供身份验证功能的引擎，或者[Thredded](https://github.com/thredded/thredded)，这是一个提供论坛功能的引擎。还有提供电子商务平台的[Spree](https://github.com/spree/spree)，以及一个CMS引擎[Refinery CMS](https://github.com/refinery/refinerycms)。

最后，引擎的实现离不开James Adam、Piotr Sarnacki、Rails核心团队和其他许多人的工作。如果您有机会遇到他们，请不要忘记说声谢谢！

生成一个引擎
--------------------

要生成一个引擎，您需要运行插件生成器并根据需要传递选项。对于“blorgh”示例，您需要创建一个“可挂载”的引擎，在终端中运行以下命令：

```bash
$ rails plugin new blorgh --mountable
```

可以通过输入以下命令查看插件生成器的所有选项列表：

```bash
$ rails plugin --help
```

`--mountable`选项告诉生成器您要创建一个“可挂载”和命名空间隔离的引擎。此生成器将提供与`--full`选项相同的骨架结构。`--full`选项告诉生成器您要创建一个引擎，包括提供以下内容的骨架结构：

  * 一个`app`目录树
  * 一个`config/routes.rb`文件：

    ```ruby
    Rails.application.routes.draw do
    end
    ```

  * 一个位于`lib/blorgh/engine.rb`的文件，其功能与标准Rails应用程序的`config/application.rb`文件相同：

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
      end
    end
    ```

`--mountable`选项将添加到`--full`选项中：

  * 资源清单文件（`blorgh_manifest.js`和`application.css`）
  * 命名空间的`ApplicationController`存根
  * 命名空间的`ApplicationHelper`存根
  * 引擎的布局视图模板
  * 在`config/routes.rb`中进行命名空间隔离：
```ruby
Blorgh::Engine.routes.draw do
end
```

* 将命名空间隔离到 `lib/blorgh/engine.rb`：

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

此外，`--mountable` 选项告诉生成器将引擎挂载到位于 `test/dummy` 的虚拟测试应用程序中，通过在虚拟应用程序的路由文件 `test/dummy/config/routes.rb` 中添加以下内容：

```ruby
mount Blorgh::Engine => "/blorgh"
```

### 引擎内部

#### 关键文件

在这个全新引擎目录的根目录下有一个 `blorgh.gemspec` 文件。当你稍后将引擎包含到应用程序中时，你将在 Rails 应用程序的 `Gemfile` 中使用以下行：

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

不要忘记像往常一样运行 `bundle install`。通过在 `Gemfile` 中指定它作为一个 gem，Bundler 将以此方式加载它，解析 `blorgh.gemspec` 文件并要求 `lib` 目录中的 `lib/blorgh.rb` 文件。这个文件要求 `blorgh/engine.rb` 文件（位于 `lib/blorgh/engine.rb`），并定义了一个名为 `Blorgh` 的基础模块。

```ruby
require "blorgh/engine"

module Blorgh
end
```

提示：一些引擎选择使用这个文件来放置引擎的全局配置选项。这是一个相对不错的主意，所以如果你想提供配置选项，你的引擎的 `module` 定义的文件非常适合。将方法放在模块内，你就可以开始使用了。

在 `lib/blorgh/engine.rb` 中是引擎的基类：

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

通过继承 `Rails::Engine` 类，这个 gem 通知 Rails 在指定的路径上有一个引擎，并将正确地将引擎挂载到应用程序中，执行诸如将引擎的 `app` 目录添加到模型、邮件、控制器和视图的加载路径等任务。

这里特别需要注意的是 `isolate_namespace` 方法。这个调用负责将控制器、模型、路由和其他东西隔离到它们自己的命名空间中，远离应用程序中的类似组件。如果没有这个方法，引擎的组件可能会“泄漏”到应用程序中，导致不必要的干扰，或者重要的引擎组件可能会被应用程序中同名的东西覆盖。其中一个冲突的例子是辅助方法。如果不调用 `isolate_namespace`，引擎的辅助方法将包含在应用程序的控制器中。

注意：强烈建议将 `isolate_namespace` 行保留在 `Engine` 类定义中。如果没有它，生成在引擎中的类可能会与应用程序发生冲突。

命名空间的隔离意味着通过调用 `bin/rails generate model` 生成的模型（例如 `bin/rails generate model article`）不会被称为 `Article`，而是被命名空间化并称为 `Blorgh::Article`。此外，模型的表也被命名空间化，变为 `blorgh_articles`，而不仅仅是 `articles`。类似于模型命名空间化，称为 `ArticlesController` 的控制器变为 `Blorgh::ArticlesController`，该控制器的视图不再位于 `app/views/articles`，而是位于 `app/views/blorgh/articles`。邮件、作业和辅助方法也被命名空间化。

最后，路由也将在引擎内部隔离。这是命名空间的最重要部分之一，将在本指南的 [路由](#routes) 部分中讨论。

#### `app` 目录

在 `app` 目录中有标准的 `assets`、`controllers`、`helpers`、`jobs`、`mailers`、`models` 和 `views` 目录，你应该对这些目录很熟悉，因为它们与应用程序非常相似。我们将在后面的部分中更详细地了解模型，当我们编写引擎时。

在 `app/assets` 目录中，有 `images` 和 `stylesheets` 目录，你也应该对它们很熟悉，因为它们与应用程序非常相似。然而，这里的一个区别是，每个目录都包含一个带有引擎名称的子目录。因为这个引擎将被命名空间化，它的资产也应该是如此。

在 `app/controllers` 目录中，有一个名为 `blorgh` 的目录，其中包含一个名为 `application_controller.rb` 的文件。这个文件将为引擎的控制器提供任何通用功能。`blorgh` 目录是引擎的其他控制器所在的地方。通过将它们放在这个命名空间目录中，可以防止它们可能与其他引擎或甚至应用程序中具有相同名称的控制器发生冲突。

注意：引擎中的 `ApplicationController` 类的命名方式与 Rails 应用程序相同，以便更容易将应用程序转换为引擎。
注意：如果父应用程序以“classic”模式运行，则可能会遇到以下情况：您的引擎控制器继承自主应用程序控制器，而不是您的引擎应用程序控制器。防止这种情况发生的最佳方法是在父应用程序中切换到“zeitwerk”模式。否则，使用`require_dependency`确保加载引擎的应用程序控制器。例如：

```ruby
# 仅在“classic”模式下需要。
require_dependency "blorgh/application_controller"

module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

警告：不要使用`require`，因为它会破坏开发环境中的类自动重新加载 - 使用`require_dependency`可以确保类以正确的方式加载和卸载。

与`app/controllers`一样，您会在`app/helpers`、`app/jobs`、`app/mailers`和`app/models`目录下找到一个名为`blorgh`的子目录，其中包含用于收集常见功能的关联`application_*.rb`文件。通过将文件放在此子目录下并对对象进行命名空间处理，可以防止它们与其他引擎或甚至应用程序中具有相同名称的元素发生冲突。

最后，`app/views`目录包含一个`layouts`文件夹，其中包含一个位于`blorgh/application.html.erb`的文件。此文件允许您为引擎指定布局。如果此引擎将用作独立引擎，则应将任何自定义内容添加到此文件的布局中，而不是应用程序的`app/views/layouts/application.html.erb`文件。

如果您不想强制用户使用引擎的布局，则可以删除此文件并在引擎的控制器中引用不同的布局。

#### `bin`目录

此目录包含一个文件`bin/rails`，它使您能够像在应用程序中一样使用`rails`子命令和生成器。这意味着您可以通过运行以下命令轻松生成此引擎的新控制器和模型：

```bash
$ bin/rails generate model
```

当然，请记住，使用这些命令在具有`Engine`类中的`isolate_namespace`的引擎内生成的任何内容都将被命名空间化。

#### `test`目录

`test`目录是用于引擎测试的位置。为了测试引擎，其中嵌入了一个简化版的Rails应用程序，位于`test/dummy`目录中。此应用程序将在`test/dummy/config/routes.rb`文件中挂载引擎：

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

此行将引擎挂载在路径`/blorgh`上，这将使其仅通过应用程序在该路径上可访问。

在`test`目录中，还有一个`test/integration`目录，用于放置引擎的集成测试。还可以在`test`目录中创建其他目录。例如，您可能希望为模型测试创建一个`test/models`目录。

提供引擎功能
------------------------------

本指南涵盖的引擎提供了提交文章和评论功能，并遵循与[入门指南](getting_started.html)类似的线索，但有一些新的变化。

注意：对于本节，请确保在`blorgh`引擎目录的根目录中运行命令。

### 生成文章资源

为博客引擎生成的第一件事是`Article`模型和相关控制器。为了快速生成它们，可以使用Rails的脚手架生成器。

```bash
$ bin/rails generate scaffold article title:string text:text
```

此命令将输出以下信息：

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_articles.rb
create    app/models/blorgh/article.rb
invoke    test_unit
create      test/models/blorgh/article_test.rb
create      test/fixtures/blorgh/articles.yml
invoke  resource_route
 route    resources :articles
invoke  scaffold_controller
create    app/controllers/blorgh/articles_controller.rb
invoke    erb
create      app/views/blorgh/articles
create      app/views/blorgh/articles/index.html.erb
create      app/views/blorgh/articles/edit.html.erb
create      app/views/blorgh/articles/show.html.erb
create      app/views/blorgh/articles/new.html.erb
create      app/views/blorgh/articles/_form.html.erb
invoke    test_unit
create      test/controllers/blorgh/articles_controller_test.rb
create      test/system/blorgh/articles_test.rb
invoke    helper
create      app/helpers/blorgh/articles_helper.rb
invoke      test_unit
```

脚手架生成器首先调用`active_record`生成器，生成资源的迁移和模型。请注意，这里的迁移被称为`create_blorgh_articles`，而不是通常的`create_articles`。这是由于在`Blorgh::Engine`类的定义中调用了`isolate_namespace`方法。这里的模型也有命名空间，放置在`app/models/blorgh/article.rb`而不是`app/models/article.rb`，这是由于`Engine`类中的`isolate_namespace`调用。

接下来，为该模型调用了`test_unit`生成器，生成了一个模型测试文件`test/models/blorgh/article_test.rb`（而不是`test/models/article_test.rb`）和一个夹具文件`test/fixtures/blorgh/articles.yml`（而不是`test/fixtures/articles.yml`）。

之后，在引擎的`config/routes.rb`文件中插入了一个资源行。这行代码只是`resources :articles`，将引擎的`config/routes.rb`文件变为以下内容：
```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

请注意，路由是在`Blorgh::Engine`对象上绘制的，而不是在`YourApp::Application`类上。这样做是为了将引擎路由限制在引擎本身内，并可以在[test directory](#test-directory)部分所示的特定位置挂载。它还使得引擎的路由与应用程序内的路由相互隔离。本指南的[Routes](#routes)部分对此进行了详细描述。

接下来，调用`scaffold_controller`生成器，生成一个名为`Blorgh::ArticlesController`的控制器（位于`app/controllers/blorgh/articles_controller.rb`），以及相关的视图（位于`app/views/blorgh/articles`）。此生成器还为控制器生成了测试文件（`test/controllers/blorgh/articles_controller_test.rb`和`test/system/blorgh/articles_test.rb`）和一个辅助器（`app/helpers/blorgh/articles_helper.rb`）。

生成器创建的所有内容都被很好地命名空间化。控制器的类定义在`Blorgh`模块内：

```ruby
module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

注意：`ArticlesController`类继承自`Blorgh::ApplicationController`，而不是应用程序的`ApplicationController`。

`app/helpers/blorgh/articles_helper.rb`中的辅助器也被命名空间化：

```ruby
module Blorgh
  module ArticlesHelper
    # ...
  end
end
```

这有助于防止与其他可能也有文章资源的引擎或应用程序发生冲突。

您可以通过在引擎的根目录下运行`bin/rails db:migrate`来运行由scaffold生成器生成的迁移，并在`test/dummy`中运行`bin/rails server`来查看引擎目前的状态。当您打开`http://localhost:3000/blorgh/articles`时，您将看到生成的默认脚手架。随便点击一下！您刚刚生成了您的第一个引擎的第一个功能。

如果您更喜欢在控制台中玩耍，`bin/rails console`也可以像Rails应用程序一样工作。请记住：`Article`模型是命名空间的，所以要引用它，您必须将其称为`Blorgh::Article`。

```irb
irb> Blorgh::Article.find(1)
=> #<Blorgh::Article id: 1 ...>
```

最后一件事是，该引擎的`articles`资源应该是引擎的根。当有人访问引擎挂载的根路径时，应该显示文章列表。如果将以下行插入到引擎的`config/routes.rb`文件中，就可以实现这一点：

```ruby
root to: "articles#index"
```

现在，人们只需要访问引擎的根目录即可查看所有文章，而不是访问`/articles`。这意味着，不再需要访问`http://localhost:3000/blorgh/articles`，现在只需要访问`http://localhost:3000/blorgh`。

### 生成评论资源

现在，引擎可以创建新文章，添加评论功能也是很合理的。为此，您需要生成一个评论模型、一个评论控制器，然后修改文章脚手架以显示评论并允许人们创建新评论。

从引擎根目录运行模型生成器。告诉它生成一个名为`Comment`的模型，相关的表格有两列：一个`article_id`整数列和一个`text`文本列。

```bash
$ bin/rails generate model Comment article_id:integer text:text
```

这将输出以下内容：

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_comments.rb
create    app/models/blorgh/comment.rb
invoke    test_unit
create      test/models/blorgh/comment_test.rb
create      test/fixtures/blorgh/comments.yml
```

此生成器调用将仅生成所需的模型文件，将文件命名空间化为`blorgh`目录，并创建一个名为`Blorgh::Comment`的模型类。现在运行迁移以创建我们的`blorgh_comments`表：

```bash
$ bin/rails db:migrate
```

要在文章上显示评论，请编辑`app/views/blorgh/articles/show.html.erb`，并在“Edit”链接之前添加以下行：

```html+erb
<h3>Comments</h3>
<%= render @article.comments %>
```

此行需要在`Blorgh::Article`模型上定义一个`has_many`关联的评论，但目前还没有。要定义一个，打开`app/models/blorgh/article.rb`，并将以下行添加到模型中：

```ruby
has_many :comments
```

将模型变为以下内容：

```ruby
module Blorgh
  class Article < ApplicationRecord
    has_many :comments
  end
end
```

注意：由于`has_many`定义在`Blorgh`模块内的类内部，Rails将知道您希望为这些对象使用`Blorgh::Comment`模型，因此在这里不需要使用`:class_name`选项指定。

接下来，需要一个表单，以便在文章上创建评论。要添加这个，请在`app/views/blorgh/articles/show.html.erb`中的`render @article.comments`调用下面添加以下行：

```erb
<%= render "blorgh/comments/form" %>
```

接下来，需要存在这一行将呈现的部分。在`app/views/blorgh/comments`中创建一个新目录，并在其中创建一个名为`_form.html.erb`的新文件，其中包含以下内容以创建所需的部分：
```html+erb
<h3>新评论</h3>
<%= form_with model: [@article, @article.comments.build] do |form| %>
  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>
  <%= form.submit %>
<% end %>
```

当提交这个表单时，它将尝试执行一个 `POST` 请求到引擎内的 `/articles/:article_id/comments` 路由。目前这个路由不存在，但可以通过将 `config/routes.rb` 中的 `resources :articles` 行更改为以下行来创建它：

```ruby
resources :articles do
  resources :comments
end
```

这将创建一个嵌套的评论路由，这是表单所需的。

现在路由已经存在，但是该路由指向的控制器还不存在。要创建它，请从引擎根目录运行以下命令：

```bash
$ bin/rails generate controller comments
```

这将生成以下内容：

```
create  app/controllers/blorgh/comments_controller.rb
invoke  erb
 exist    app/views/blorgh/comments
invoke  test_unit
create    test/controllers/blorgh/comments_controller_test.rb
invoke  helper
create    app/helpers/blorgh/comments_helper.rb
invoke    test_unit
```

该表单将向 `/articles/:article_id/comments` 发送一个 `POST` 请求，这将与 `Blorgh::CommentsController` 中的 `create` 动作对应。这个动作需要被创建，可以通过将以下行放在 `app/controllers/blorgh/comments_controller.rb` 中的类定义内来完成：

```ruby
def create
  @article = Article.find(params[:article_id])
  @comment = @article.comments.create(comment_params)
  flash[:notice] = "评论已创建！"
  redirect_to articles_path
end

private
  def comment_params
    params.require(:comment).permit(:text)
  end
```

这是使新评论表单工作所需的最后一步。然而，显示评论的方式还不完全正确。如果你现在创建一个评论，你会看到以下错误：

```
找不到部分 blorgh/comments/_comment with {:handlers=>[:erb, :builder],
:formats=>[:html], :locale=>[:en, :en]}。在以下位置查找：   *
"/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"   *
"/Users/ryan/Sites/side_projects/blorgh/app/views"
```

引擎无法找到用于渲染评论的部分视图。Rails 首先查找应用程序（`test/dummy`）的 `app/views` 目录，然后查找引擎的 `app/views` 目录。当找不到时，就会抛出这个错误。引擎知道要查找 `blorgh/comments/_comment`，因为它接收到的模型对象来自 `Blorgh::Comment` 类。

这个部分视图将负责仅渲染评论文本。在 `app/views/blorgh/comments/_comment.html.erb` 中创建一个新文件，并将以下行放入其中：

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

`comment_counter` 局部变量是由 `<%= render @article.comments %>` 调用提供的，它会自动定义并在迭代每个评论时递增计数器。在这个示例中，它用于在每个评论旁边显示一个小数字。

这完成了博客引擎的评论功能。现在是时候在应用程序中使用它了。

接入应用程序
---------------------------

在应用程序中使用引擎非常简单。本节介绍如何将引擎挂载到应用程序中，并提供初始设置，以及将引擎链接到应用程序提供的 `User` 类，为引擎中的文章和评论提供所有权。

### 挂载引擎

首先，需要在应用程序的 `Gemfile` 中指定引擎。如果没有一个方便的应用程序来测试这个，可以使用 `rails new` 命令在引擎目录之外生成一个应用程序，像这样：

```bash
$ rails new unicorn
```

通常，在 `Gemfile` 中指定引擎会像指定普通的日常 gem 一样进行。

```ruby
gem 'devise'
```

然而，因为你是在本地开发 `blorgh` 引擎，所以需要在 `Gemfile` 中指定 `:path` 选项：

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

然后运行 `bundle` 安装 gem。

如前所述，通过将 gem 放在 `Gemfile` 中，它将在加载 Rails 时被加载。它首先会从引擎中的 `lib/blorgh.rb` 加载，然后加载 `lib/blorgh/engine.rb`，这个文件定义了引擎的主要功能。

为了使引擎的功能在应用程序中可访问，需要在应用程序的 `config/routes.rb` 文件中挂载它：

```ruby
mount Blorgh::Engine, at: "/blog"
```

这行代码将在应用程序中的 `/blog` 处挂载引擎。当应用程序使用 `bin/rails server` 运行时，它将在 `http://localhost:3000/blog` 处访问。

注意：其他引擎（如 Devise）处理方式略有不同，它会让你在路由中指定自定义帮助方法（如 `devise_for`）。这些帮助方法的作用完全相同，将引擎的功能的一部分挂载到预定义的路径上，这些路径可以自定义。
### 引擎设置

引擎包含了 `blorgh_articles` 和 `blorgh_comments` 表的迁移，需要在应用程序的数据库中创建这些表，以便引擎的模型可以正确地查询它们。要将这些迁移复制到应用程序中，请从应用程序的根目录运行以下命令：

```bash
$ bin/rails blorgh:install:migrations
```

如果您有多个需要复制迁移的引擎，请改用 `railties:install:migrations`：

```bash
$ bin/rails railties:install:migrations
```

您可以通过指定 MIGRATIONS_PATH 来在源引擎中指定自定义路径以用于迁移。

```bash
$ bin/rails railties:install:migrations MIGRATIONS_PATH=db_blourgh
```

如果您有多个数据库，还可以通过指定 DATABASE 来指定目标数据库。

```bash
$ bin/rails railties:install:migrations DATABASE=animals
```

第一次运行此命令时，将复制所有迁移文件。下次运行时，只会复制尚未复制的迁移文件。第一次运行此命令将输出如下内容：

```
从 blorgh 复制迁移文件 [timestamp_1]_create_blorgh_articles.blorgh.rb
从 blorgh 复制迁移文件 [timestamp_2]_create_blorgh_comments.blorgh.rb
```

第一个时间戳（`[timestamp_1]`）将是当前时间，第二个时间戳（`[timestamp_2]`）将是当前时间加一秒。这样做的原因是为了确保引擎的迁移在应用程序中的任何现有迁移之后运行。

要在应用程序的上下文中运行这些迁移，请简单地运行 `bin/rails db:migrate`。当通过 `http://localhost:3000/blog` 访问引擎时，文章将为空。这是因为应用程序内创建的表与引擎内创建的表不同。请随意尝试使用新挂载的引擎。您会发现它与之前只是一个引擎时完全相同。

如果您只想运行一个引擎的迁移，可以通过指定 `SCOPE` 来实现：

```bash
$ bin/rails db:migrate SCOPE=blorgh
```

如果您想在删除引擎之前还原引擎的所有迁移，可以运行以下代码：

```bash
$ bin/rails db:migrate SCOPE=blorgh VERSION=0
```

### 使用应用程序提供的类

#### 使用应用程序提供的模型

当创建一个引擎时，可能希望使用应用程序中的特定类来提供引擎的各个部分与应用程序的各个部分之间的链接。对于 `blorgh` 引擎来说，让文章和评论具有作者是很有意义的。

一个典型的应用程序可能有一个 `User` 类，用于表示文章或评论的作者。但是也可能存在这样一种情况，应用程序将此类命名为其他名称，比如 `Person`。因此，引擎不应为 `User` 类硬编码关联。

为了保持简单，在这种情况下，应用程序将有一个名为 `User` 的类，用于表示应用程序的用户（我们将在后面进一步讨论如何使其可配置）。可以使用以下命令在应用程序内生成该类：

```bash
$ bin/rails generate model user name:string
```

在此处需要运行 `bin/rails db:migrate` 命令，以确保我们的应用程序具有 `users` 表供将来使用。

另外，为了简单起见，文章表单将添加一个名为 `author_name` 的新文本字段，用户可以选择在其中输入他们的姓名。然后，引擎将获取此姓名并将其转换为一个新的 `User` 对象，或者查找已经具有该姓名的对象。然后，引擎将将文章与找到或创建的 `User` 对象关联起来。

首先，需要在引擎内的 `app/views/blorgh/articles/_form.html.erb` 部分添加 `author_name` 文本字段。可以使用以下代码将其添加到 `title` 字段之前：

```html+erb
<div class="field">
  <%= form.label :author_name %><br>
  <%= form.text_field :author_name %>
</div>
```

接下来，我们需要更新 `Blorgh::ArticlesController#article_params` 方法，以允许新的表单参数：

```ruby
def article_params
  params.require(:article).permit(:title, :text, :author_name)
end
```

然后，`Blorgh::Article` 模型应该有一些代码，将 `author_name` 字段转换为实际的 `User` 对象，并在保存文章之前将其关联为该文章的 `author`。还需要为此字段设置 `attr_accessor`，以便为其定义设置器和获取器方法。

为了做到这一点，您需要在 `app/models/blorgh/article.rb` 中添加 `author_name` 的 `attr_accessor`，作者的关联以及 `before_validation` 调用。目前，`author` 关联将硬编码为 `User` 类。
```ruby
module Blorgh
  mattr_accessor :author_class

  def self.author_class
    @@author_class
  end
end
```

Now, the `author_class` configuration setting can be customized in the application's
`config/initializers/blorgh.rb` file:

```ruby
Blorgh.author_class = "CustomUser"
```

This allows the `User` class to be replaced with a custom user class in the application.

#### General Configuration Tips

Here are some general tips for configuring the Blorgh engine:

- To override the engine's views, create a directory structure in the application's
  `app/views` directory that matches the engine's directory structure. For example,
  to override the `show.html.erb` view in the `app/views/blorgh/articles` directory,
  create a `blorgh` directory inside `app/views` and then a `articles` directory inside
  `app/views/blorgh`. Place the overridden view file in this directory.

- To override the engine's controllers, create a directory structure in the application's
  `app/controllers` directory that matches the engine's directory structure. For example,
  to override the `ArticlesController` in the `app/controllers/blorgh` directory, create
  a `blorgh` directory inside `app/controllers` and place the overridden controller file
  in this directory.

- To override the engine's models, create a directory structure in the application's
  `app/models` directory that matches the engine's directory structure. For example,
  to override the `Article` model in the `app/models/blorgh` directory, create a `blorgh`
  directory inside `app/models` and place the overridden model file in this directory.

- To override the engine's routes, define the routes in the application's `config/routes.rb`
  file using the `mount` method. For example, to override the engine's routes for articles,
  add the following code to the `config/routes.rb` file:

  ```ruby
  mount Blorgh::Engine, at: "/blog"
  ```

  This will mount the engine at the specified path, overriding the default engine routes.

- To override the engine's controllers, models, or other classes, create a file with the
  same name and location as the engine's file, and define the class with the same name.
  For example, to override the `ArticlesController` in the `app/controllers/blorgh` directory,
  create a file at `app/controllers/blorgh/articles_controller.rb` and define the `ArticlesController`
  class in this file.
```ruby
def self.author_class
  @@author_class.constantize
end
```

这将把上述代码转换为`set_author`的以下形式：

```ruby
self.author = Blorgh.author_class.find_or_create_by(name: author_name)
```

结果是更简短，行为更隐式。`author_class`方法应始终返回一个`Class`对象。

由于我们将`author_class`方法更改为返回`Class`而不是`String`，因此还必须修改`Blorgh::Article`模型中的`belongs_to`定义：

```ruby
belongs_to :author, class_name: Blorgh.author_class.to_s
```

要在应用程序中设置此配置设置，应使用初始化程序。通过使用初始化程序，配置将在应用程序启动之前设置，并调用引擎的模型，这些模型可能依赖于此配置设置的存在。

在安装了`blorgh`引擎的应用程序中的`config/initializers/blorgh.rb`中创建一个新的初始化程序，并将以下内容放入其中：

```ruby
Blorgh.author_class = "User"
```

警告：在这里非常重要的是使用类的`String`版本，而不是类本身。如果使用类，Rails将尝试加载该类，然后引用相关的表。如果表尚不存在，这可能会导致问题。因此，应使用`String`，然后在引擎中使用`constantize`将其转换为类。

继续尝试创建新文章。您将看到它与以前完全相同的方式工作，只是这次引擎使用`config/initializers/blorgh.rb`中的配置设置来了解类是什么。

现在没有严格依赖于类是什么，只有类的API必须是什么。引擎只需要这个类定义一个`find_or_create_by`方法，该方法返回一个该类的对象，以便在创建文章时与之关联。当然，这个对象应该有某种标识符，可以通过它来引用。

#### 通用引擎配置

在引擎内部，可能会有一些希望使用的配置选项，例如初始化程序、国际化或其他配置选项。好消息是，这些都是完全可能的，因为Rails引擎与Rails应用程序共享许多相同的功能。实际上，Rails应用程序的功能实际上是由引擎提供的功能的超集！

如果要使用初始化程序 - 在引擎加载之前应运行的代码 - 可以将其放在`config/initializers`文件夹中。该目录的功能在配置指南的[初始化程序部分](configuring.html#initializers)中有解释，并且与应用程序内部的`config/initializers`目录完全相同。如果要使用标准初始化程序，也是一样的。

对于本地化，只需将本地化文件放在`config/locales`目录中，就像在应用程序中一样。

测试引擎
-----------------

当生成引擎时，会在其中创建一个较小的虚拟应用程序，位于`test/dummy`。该应用程序用作引擎的挂载点，使测试引擎变得非常简单。您可以通过从该目录中生成控制器、模型或视图来扩展该应用程序，然后使用它们来测试引擎。

`test`目录应该像一个典型的Rails测试环境一样对待，允许进行单元测试、功能测试和集成测试。

### 功能测试

在编写功能测试时，值得考虑的一个问题是测试将在一个应用程序上运行 - `test/dummy`应用程序 - 而不是您的引擎上。这是由于测试环境的设置; 引擎需要一个应用程序作为主机来测试其主要功能，特别是控制器。这意味着，如果您在控制器的功能测试中像这样对控制器进行典型的`GET`请求：

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def test_index
      get foos_url
      # ...
    end
  end
end
```

它可能无法正常工作。这是因为应用程序不知道如何将这些请求路由到引擎，除非您明确告诉它**如何**。为此，您必须在设置代码中将`@routes`实例变量设置为引擎的路由集：

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_index
      get foos_url
      # ...
    end
  end
end
```
这告诉应用程序仍然要执行对此控制器的`index`操作的`GET`请求，但要使用引擎的路由来实现，而不是应用程序的路由。

这还确保引擎的URL助手在测试中按预期工作。

改进引擎功能
------------------------------

本节介绍如何在主要的Rails应用程序中添加和/或覆盖引擎的MVC功能。

### 覆盖模型和控制器

可以通过父应用程序重新打开引擎模型和控制器以进行扩展或装饰。

覆盖可以组织在一个专用目录`app/overrides`中，该目录被自动加载器忽略，并在`to_prepare`回调中预加载：

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        load override
      end
    end
  end
end
```

#### 使用`class_eval`重新打开现有类

例如，为了覆盖引擎模型

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    # ...
  end
end
```

只需创建一个重新打开该类的文件：

```ruby
# MyApp/app/overrides/models/blorgh/article_override.rb
Blorgh::Article.class_eval do
  # ...
end
```

重要的是，覆盖要重新打开类或模块。如果使用`class`或`module`关键字定义它们，会在内存中不存在时定义它们，这是不正确的，因为定义位于引擎中。如上所示使用`class_eval`确保重新打开。

#### 使用ActiveSupport::Concern重新打开现有类

使用`Class#class_eval`对于简单的调整非常好，但对于更复杂的类修改，您可能希望考虑使用[`ActiveSupport::Concern`](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)。ActiveSupport::Concern在运行时管理相互关联的依赖模块和类的加载顺序，允许您显着模块化代码。

**添加**`Article#time_since_created`和**覆盖**`Article#summary`：

```ruby
# MyApp/app/models/blorgh/article.rb

class Blorgh::Article < ApplicationRecord
  include Blorgh::Concerns::Models::Article

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    include Blorgh::Concerns::Models::Article
  end
end
```

```ruby
# Blorgh/lib/concerns/models/article.rb

module Blorgh::Concerns::Models::Article
  extend ActiveSupport::Concern

  # `included do`使块在模块被包含的上下文中（即Blorgh::Article）中求值，
  # 而不是在模块本身中求值。
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_validation :set_author

    private
      def set_author
        self.author = User.find_or_create_by(name: author_name)
      end
  end

  def summary
    "#{title}"
  end

  module ClassMethods
    def some_class_method
      'some class method string'
    end
  end
end
```

### 自动加载和引擎

有关自动加载和引擎的更多信息，请参阅[自动加载和重新加载常量](autoloading_and_reloading_constants.html#autoloading-and-engines)指南。


### 覆盖视图

当Rails查找要渲染的视图时，它首先会在应用程序的`app/views`目录中查找。如果在该目录中找不到视图，它将在具有此目录的所有引擎的`app/views`目录中查找。

当应用程序被要求渲染`Blorgh::ArticlesController`的index操作的视图时，它首先会查找路径`app/views/blorgh/articles/index.html.erb`。如果找不到，它将在引擎内部查找。

您可以通过在应用程序中创建一个新文件`app/views/blorgh/articles/index.html.erb`来覆盖此视图。然后，您可以完全更改此视图通常会输出的内容。

现在尝试通过在`app/views/blorgh/articles/index.html.erb`中创建一个新文件，并将以下内容放入其中：

```html+erb
<h1>Articles</h1>
<%= link_to "New Article", new_article_path %>
<% @articles.each do |article| %>
  <h2><%= article.title %></h2>
  <small>By <%= article.author %></small>
  <%= simple_format(article.text) %>
  <hr>
<% end %>
```

### 路由

引擎内部的路由默认情况下与应用程序隔离。这是通过`Engine`类中的`isolate_namespace`调用完成的。这实际上意味着应用程序及其引擎可以具有相同名称的路由，它们不会冲突。

引擎内部的路由在`config/routes.rb`中的`Engine`类上绘制，如下所示：

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

通过具有这样的隔离路由，如果您希望从应用程序内部链接到引擎的某个区域，您将需要使用引擎的路由代理方法。对于正常的路由方法调用，如`articles_path`，如果应用程序和引擎都定义了这样的助手，它可能最终会转到不希望的位置。

例如，如果该模板是从应用程序渲染的，则以下示例将转到应用程序的`articles_path`，如果它是从引擎渲染的，则转到引擎的`articles_path`：
```erb
<%= link_to "博客文章", articles_path %>
```

为了使这个路由始终使用引擎的`articles_path`路由辅助方法，我们必须在与引擎同名的路由代理方法上调用该方法。

```erb
<%= link_to "博客文章", blorgh.articles_path %>
```

如果您希望以类似的方式引用引擎内的应用程序，请使用`main_app`辅助方法：

```erb
<%= link_to "首页", main_app.root_path %>
```

如果您在引擎内部的模板中使用了应用程序的路由辅助方法，可能会导致未定义的方法调用。如果遇到此问题，请确保在引擎内部使用`main_app`前缀调用应用程序的路由方法。

### 资源

引擎内的资源与完整应用程序的工作方式完全相同。因为引擎类继承自`Rails::Engine`，所以应用程序将知道在引擎的`app/assets`和`lib/assets`目录中查找资源。

与引擎的其他组件一样，资源应该进行命名空间处理。这意味着如果您有一个名为`style.css`的资源，它应该放在`app/assets/stylesheets/[engine name]/style.css`，而不是`app/assets/stylesheets/style.css`。如果此资源没有命名空间，可能会导致主机应用程序具有相同名称的资源，这种情况下应用程序的资源将优先，并且引擎的资源将被忽略。

假设您确实有一个位于`app/assets/stylesheets/blorgh/style.css`的资源。要在应用程序中包含此资源，只需使用`stylesheet_link_tag`，并将资源引用为在引擎内部的方式：

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

您还可以在处理的文件中使用Asset Pipeline的require语句将这些资源指定为其他资源的依赖项：

```css
/*
 *= require blorgh/style
 */
```

INFO. 请记住，为了使用Sass或CoffeeScript等语言，您应该将相关库添加到引擎的`.gemspec`文件中。

### 分离资源和预编译

在某些情况下，主机应用程序不需要引擎的资源。例如，假设您创建了一个仅适用于引擎的管理功能。在这种情况下，主机应用程序不需要引入`admin.css`或`admin.js`。只有宝石的管理布局需要这些资源。在主机应用程序的样式表中包含`"blorgh/admin.css"`是没有意义的。在这种情况下，您应该明确地为预编译定义这些资源。这告诉Sprockets在触发`bin/rails assets:precompile`时添加引擎的资源。

您可以在`engine.rb`中定义预编译的资源：

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile += %w( admin.js admin.css )
end
```

有关更多信息，请阅读[Asset Pipeline指南](asset_pipeline.html)。

### 其他宝石依赖项

引擎内的宝石依赖项应该在引擎根目录下的`.gemspec`文件中指定。原因是引擎可以作为宝石安装。如果依赖项在`Gemfile`中指定，传统的宝石安装将无法识别这些依赖项，因此它们将不会被安装，导致引擎功能失效。

要指定应在传统的`gem install`期间与引擎一起安装的依赖项，请在引擎的`.gemspec`文件中的`Gem::Specification`块内指定：

```ruby
s.add_dependency "moo"
```

要指定只应作为应用程序的开发依赖项安装的依赖项，请像这样指定：

```ruby
s.add_development_dependency "moo"
```

在应用程序内运行`bundle install`时，这两种类型的依赖项都将被安装。宝石的开发依赖项仅在运行引擎的开发和测试时使用。

请注意，如果您希望在引擎被引入时立即要求依赖项，您应该在引擎的初始化之前要求它们。例如：

```ruby
require "other_engine/engine"
require "yet_another_engine/engine"

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```

加载和配置钩子
----------------------------

Rails代码通常可以在应用程序加载时引用。Rails负责这些框架的加载顺序，因此如果您过早地加载了诸如`ActiveRecord::Base`之类的框架，就违反了应用程序与Rails之间的隐式契约。此外，通过在应用程序启动时加载诸如`ActiveRecord::Base`之类的代码，您将加载整个框架，这可能会减慢启动时间，并可能导致加载顺序和应用程序启动的冲突。
加载和配置钩子是允许您在不违反Rails加载合同的情况下钩入此初始化过程的API。这也将减轻启动性能下降和避免冲突。

### 避免加载Rails框架

由于Ruby是一种动态语言，某些代码会导致不同的Rails框架加载。例如，考虑以下代码片段：

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

这段代码意味着当加载此文件时，它会遇到`ActiveRecord::Base`。这个遇到会导致Ruby寻找该常量的定义并加载它。这会导致整个Active Record框架在启动时被加载。

`ActiveSupport.on_load`是一种机制，可以延迟加载代码直到实际需要为止。上面的代码片段可以改为：

```ruby
ActiveSupport.on_load(:active_record) do
  include MyActiveRecordHelper
end
```

这个新的代码片段只会在加载`ActiveRecord::Base`时包含`MyActiveRecordHelper`。

### 何时调用钩子？

在Rails框架中，这些钩子在加载特定库时被调用。例如，当加载`ActionController::Base`时，将调用`:action_controller_base`钩子。这意味着所有带有`：action_controller_base`钩子的`ActiveSupport.on_load`调用将在`ActionController::Base`的上下文中调用（这意味着`self`将是一个`ActionController::Base`）。

### 修改代码以使用加载钩子

修改代码通常很简单。如果您有一行代码引用了一个Rails框架，比如`ActiveRecord::Base`，您可以将该代码包装在一个加载钩子中。

**修改对`include`的调用**

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

变成

```ruby
ActiveSupport.on_load(:active_record) do
  # 这里的self指的是ActiveRecord::Base，
  # 所以我们可以调用.include
  include MyActiveRecordHelper
end
```

**修改对`prepend`的调用**

```ruby
ActionController::Base.prepend(MyActionControllerHelper)
```

变成

```ruby
ActiveSupport.on_load(:action_controller_base) do
  # 这里的self指的是ActionController::Base，
  # 所以我们可以调用.prepend
  prepend MyActionControllerHelper
end
```

**修改对类方法的调用**

```ruby
ActiveRecord::Base.include_root_in_json = true
```

变成

```ruby
ActiveSupport.on_load(:active_record) do
  # 这里的self指的是ActiveRecord::Base
  self.include_root_in_json = true
end
```

### 可用的加载钩子

以下是您可以在自己的代码中使用的加载钩子。要钩入以下类之一的初始化过程，请使用可用的钩子。

| 类                                  | 钩子                                |
| ------------------------------------| ----------------------------------- |
| `ActionCable`                       | `action_cable`                      |
| `ActionCable::Channel::Base`        | `action_cable_channel`              |
| `ActionCable::Connection::Base`     | `action_cable_connection`           |
| `ActionCable::Connection::TestCase` | `action_cable_connection_test_case` |
| `ActionController::API`             | `action_controller_api`             |
| `ActionController::API`             | `action_controller`                 |
| `ActionController::Base`            | `action_controller_base`            |
| `ActionController::Base`            | `action_controller`                 |
| `ActionController::TestCase`        | `action_controller_test_case`       |
| `ActionDispatch::IntegrationTest`   | `action_dispatch_integration_test`  |
| `ActionDispatch::Response`          | `action_dispatch_response`          |
| `ActionDispatch::Request`           | `action_dispatch_request`           |
| `ActionDispatch::SystemTestCase`    | `action_dispatch_system_test_case`  |
| `ActionMailbox::Base`               | `action_mailbox`                    |
| `ActionMailbox::InboundEmail`       | `action_mailbox_inbound_email`      |
| `ActionMailbox::Record`             | `action_mailbox_record`             |
| `ActionMailbox::TestCase`           | `action_mailbox_test_case`          |
| `ActionMailer::Base`                | `action_mailer`                     |
| `ActionMailer::TestCase`            | `action_mailer_test_case`           |
| `ActionText::Content`               | `action_text_content`               |
| `ActionText::Record`                | `action_text_record`                |
| `ActionText::RichText`              | `action_text_rich_text`             |
| `ActionText::EncryptedRichText`     | `action_text_encrypted_rich_text`   |
| `ActionView::Base`                  | `action_view`                       |
| `ActionView::TestCase`              | `action_view_test_case`             |
| `ActiveJob::Base`                   | `active_job`                        |
| `ActiveJob::TestCase`               | `active_job_test_case`              |
| `ActiveRecord::Base`                | `active_record`                     |
| `ActiveRecord::TestFixtures`        | `active_record_fixtures`            |
| `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter`   | `active_record_postgresqladapter`   |
| `ActiveRecord::ConnectionAdapters::Mysql2Adapter`       | `active_record_mysql2adapter`       |
| `ActiveRecord::ConnectionAdapters::TrilogyAdapter`      | `active_record_trilogyadapter`      |
| `ActiveRecord::ConnectionAdapters::SQLite3Adapter`      | `active_record_sqlite3adapter`      |
| `ActiveStorage::Attachment`         | `active_storage_attachment`         |
| `ActiveStorage::VariantRecord`      | `active_storage_variant_record`     |
| `ActiveStorage::Blob`               | `active_storage_blob`               |
| `ActiveStorage::Record`             | `active_storage_record`             |
| `ActiveSupport::TestCase`           | `active_support_test_case`          |
| `i18n`                              | `i18n`                              |

### 可用的配置钩子

配置钩子不钩入任何特定的框架，而是在整个应用程序的上下文中运行。

| 钩子                  | 用例                                                                                   |
| ---------------------- | -------------------------------------------------------------------------------------- |
| `before_configuration` | 第一个可配置块运行。在运行任何初始化程序之前调用。                                       |
| `before_initialize`    | 第二个可配置块运行。在框架初始化之前调用。                                             |
| `before_eager_load`    | 第三个可配置块运行。如果[`config.eager_load`][]设置为false，则不运行。                     |
| `after_initialize`     | 最后一个可配置块运行。在框架初始化之后调用。                                            |

配置钩子可以在Engine类中调用。

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    config.before_configuration do
      puts '在任何初始化程序之前调用我'
    end
  end
end
```
[`config.eager_load`]: configuring.html#config-eager-load
