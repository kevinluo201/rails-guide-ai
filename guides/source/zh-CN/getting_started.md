**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2cf37358fedc8b51ed3ab7f408ecfc76
Rails 入门指南
==========================

本指南介绍了如何开始使用 Ruby on Rails。

阅读本指南后，您将了解：

* 如何安装 Rails，创建一个新的 Rails 应用程序，并将应用程序连接到数据库。
* Rails 应用程序的一般布局。
* MVC（模型、视图、控制器）和 RESTful 设计的基本原则。
* 如何快速生成 Rails 应用程序的起始部分。

--------------------------------------------------------------------------------

指南假设
-----------------

本指南适用于想要从零开始创建 Rails 应用程序的初学者。它不假设您具有任何关于 Rails 的先前经验。

Rails 是一个运行在 Ruby 编程语言上的 Web 应用程序框架。如果您之前没有使用过 Ruby，直接学习 Rails 可能会有很大的学习曲线。有几个经过策划的在线资源列表可供学习 Ruby：

* [官方 Ruby 编程语言网站](https://www.ruby-lang.org/en/documentation/)
* [免费编程书籍列表](https://github.com/EbookFoundation/free-programming-books/blob/master/books/free-programming-books-langs.md#ruby)

请注意，尽管某些资源仍然很好，但它们涵盖的是较旧的 Ruby 版本，可能不包括您在日常 Rails 开发中会遇到的某些语法。

什么是 Rails？
--------------

Rails 是用 Ruby 编程语言编写的 Web 应用程序开发框架。它旨在通过对每个开发者需要的内容进行假设，使编写 Web 应用程序变得更加容易。它允许您用更少的代码完成比其他语言和框架更多的工作。经验丰富的 Rails 开发者还表示，它使 Web 应用程序开发更加有趣。

Rails 是一种有主见的软件。它假设有一种“最佳”方法来做事，并旨在鼓励这种方法 - 在某些情况下，它还会阻止其他选择。如果您学习“Rails 的方式”，您可能会发现生产力大大提高。如果您坚持将其他语言的旧习惯带到 Rails 开发中，并尝试使用在其他地方学到的模式，您可能会有一种不太愉快的体验。

Rails 的理念包括两个主要指导原则：

* **不要重复自己（DRY）：** DRY 是软件开发的原则，它指出“系统中的每个知识片段必须具有单一、明确、权威的表示”。通过不重复编写相同的信息，我们的代码更易于维护、扩展和更少出错。
* **约定优于配置（Convention Over Configuration）：** Rails 对 Web 应用程序中许多事情的最佳实践有自己的看法，并默认使用这套约定，而不是要求您通过无休止的配置文件来指定细节。

创建一个新的 Rails 项目
----------------------------

阅读本指南的最佳方式是逐步跟随。所有步骤都是运行此示例应用程序所必需的，不需要额外的代码或步骤。

按照本指南的步骤，您将创建一个名为 `blog` 的 Rails 项目，一个（非常）简单的博客。在开始构建应用程序之前，您需要确保已安装了 Rails 本身。

注意：下面的示例使用 `$` 表示类 Unix 操作系统中的终端提示符，尽管可能已经自定义为显示不同的样式。如果您使用的是 Windows，您的提示符将类似于 `C:\source_code>`。

### 安装 Rails

在安装 Rails 之前，您应该检查系统是否已安装了必要的先决条件。这些条件包括：

* Ruby
* SQLite3

#### 安装 Ruby

打开命令行提示符。在 macOS 上打开 Terminal.app；在 Windows 上选择“运行”菜单，然后输入 `cmd.exe`。任何以美元符号 `$` 开头的命令都应在命令行中运行。验证您是否安装了当前版本的 Ruby：

```bash
$ ruby --version
ruby 2.7.0
```

Rails 需要 Ruby 版本 2.7.0 或更高。最好使用最新的 Ruby 版本。如果返回的版本号小于该数字（例如 2.3.7 或 1.8.7），您需要安装一个新的 Ruby 副本。

要在 Windows 上安装 Rails，您首先需要安装 [Ruby Installer](https://rubyinstaller.org/)。

有关大多数操作系统的更多安装方法，请参阅 [ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/)。

#### 安装 SQLite3

您还需要安装 SQLite3 数据库。许多流行的类 Unix 操作系统都附带了一个可接受的版本的 SQLite3。其他操作系统可以在 [SQLite3 网站](https://www.sqlite.org) 上找到安装说明。
验证是否已正确安装并在您的加载`PATH`中：

```bash
$ sqlite3 --version
```

程序应该报告其版本。

#### 安装Rails

要安装Rails，请使用RubyGems提供的`gem install`命令：

```bash
$ gem install rails
```

要验证是否已正确安装所有内容，您应该能够在新的终端中运行以下命令：

```bash
$ rails --version
```

如果显示类似于"Rails 7.0.0"的内容，则表示您已准备好继续。

### 创建博客应用程序

Rails带有一些称为生成器的脚本，旨在通过创建启动特定任务所需的一切来简化您的开发工作。其中之一是新应用程序生成器，它将为您提供一个全新的Rails应用程序的基础，以免您自己编写。

要使用此生成器，请打开终端，导航到您具有创建文件权限的目录，并运行：

```bash
$ rails new blog
```

这将在`blog`目录中创建一个名为Blog的Rails应用程序，并使用`bundle install`安装`Gemfile`中已经提到的gem依赖项。

提示：您可以通过运行`rails new --help`来查看Rails应用程序生成器接受的所有命令行选项。

创建博客应用程序后，切换到其文件夹：

```bash
$ cd blog
```

`blog`目录将包含许多生成的文件和文件夹，这些文件和文件夹构成了Rails应用程序的结构。本教程中的大部分工作将在`app`文件夹中进行，但以下是Rails默认创建的每个文件和文件夹的基本功能介绍：

| 文件/文件夹 | 功能 |
| ----------- | ------- |
|app/|包含应用程序的控制器、模型、视图、助手、邮件程序、通道、作业和资源。您将在本指南的其余部分中重点关注此文件夹。|
|bin/|包含启动应用程序的`rails`脚本，还可以包含用于设置、更新、部署或运行应用程序的其他脚本。|
|config/|包含应用程序的路由、数据库等配置。有关详细信息，请参阅[配置Rails应用程序](configuring.html)。|
|config.ru|用于启动应用程序的基于Rack的服务器的Rack配置。有关Rack的更多信息，请参阅[Rack网站](https://rack.github.io/)。|
|db/|包含当前数据库架构以及数据库迁移。|
|Gemfile<br>Gemfile.lock|这些文件允许您指定Rails应用程序所需的gem依赖项。这些文件由Bundler gem使用。有关Bundler的更多信息，请参阅[Bundler网站](https://bundler.io)。|
|lib/|应用程序的扩展模块。|
|log/|应用程序日志文件。|
|public/|包含静态文件和编译后的资源。当您的应用程序运行时，此目录将原样显示。|
|Rakefile|此文件用于定位并加载可以从命令行运行的任务。任务定义在Rails的各个组件中。您应该通过将文件添加到应用程序的`lib/tasks`目录来添加自己的任务，而不是更改`Rakefile`。|
|README.md|这是您的应用程序的简要说明手册。您应该编辑此文件以告诉其他人您的应用程序的功能、如何设置等等。|
|storage/|Disk Service的Active Storage文件。有关详细信息，请参阅[Active Storage概述](active_storage_overview.html)。|
|test/|单元测试、固定装置和其他测试设备。有关详细信息，请参阅[测试Rails应用程序](testing.html)。|
|tmp/|临时文件（如缓存和pid文件）。|
|vendor/|所有第三方代码的位置。在典型的Rails应用程序中，这包括供应商提供的gem。|
|.gitattributes|此文件为git存储库中的特定路径定义元数据。这些元数据可由git和其他工具用于增强其行为。有关详细信息，请参阅[gitattributes文档](https://git-scm.com/docs/gitattributes)。|
|.gitignore|此文件告诉git应忽略哪些文件（或模式）。有关忽略文件的更多信息，请参阅[GitHub - 忽略文件](https://help.github.com/articles/ignoring-files)。|
|.ruby-version|此文件包含默认的Ruby版本。|

你好，Rails！
-------------

首先，让我们快速在屏幕上显示一些文本。为此，您需要启动Rails应用程序服务器。

### 启动Web服务器

实际上，您已经拥有一个可用的Rails应用程序。要查看它，请在`blog`目录中运行以下命令：

```bash
$ bin/rails server
```
提示：如果您使用的是Windows系统，您需要直接将位于`bin`文件夹下的脚本传递给Ruby解释器，例如`ruby bin\rails server`。

提示：JavaScript资源压缩需要在系统上安装JavaScript运行时，如果没有运行时，将在资源压缩过程中出现`execjs`错误。通常，macOS和Windows都会预装JavaScript运行时。`therubyrhino`是JRuby用户推荐的运行时，并且默认添加到在JRuby下生成的应用程序的`Gemfile`中。您可以在[ExecJS](https://github.com/rails/execjs#readme)上查看所有支持的运行时。

这将启动Puma，这是Rails默认分发的Web服务器。要查看应用程序的运行情况，请打开浏览器窗口并导航到<http://localhost:3000>。您应该会看到Rails的默认信息页面：

![Rails启动页面截图](images/getting_started/rails_welcome.png)

当您想要停止Web服务器时，在运行它的终端窗口中按下Ctrl+C。在开发环境中，Rails通常不需要您重新启动服务器；您对文件所做的更改将自动被服务器接收。

Rails启动页面是新的Rails应用程序的“烟雾测试”：它确保您已经正确配置了软件以提供页面。

### 对Rails说“Hello”

要让Rails说“Hello”，您至少需要创建一个*路由*、一个*控制器*和一个*视图*。路由将请求映射到控制器的动作。控制器动作执行处理请求所需的工作，并准备视图所需的任何数据。视图以所需的格式显示数据。

在实现方面：路由是用Ruby编写的规则，称为[Ruby领域特定语言（DSL）](https://en.wikipedia.org/wiki/Domain-specific_language)。控制器是Ruby类，它们的公共方法是动作。视图是模板，通常由HTML和Ruby混合编写。

让我们首先在我们的路由文件`config/routes.rb`的`Rails.application.routes.draw`块的顶部添加一个路由：

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # 有关此文件中可用的DSL的详细信息，请参阅https://guides.rubyonrails.org/routing.html
end
```

上面的路由声明了将`GET /articles`请求映射到`ArticlesController`的`index`动作。

要创建`ArticlesController`及其`index`动作，我们将运行控制器生成器（使用`--skip-routes`选项，因为我们已经有了适当的路由）：

```bash
$ bin/rails generate controller Articles index --skip-routes
```

Rails将为您创建几个文件：

```
create  app/controllers/articles_controller.rb
invoke  erb
create    app/views/articles
create    app/views/articles/index.html.erb
invoke  test_unit
create    test/controllers/articles_controller_test.rb
invoke  helper
create    app/helpers/articles_helper.rb
invoke    test_unit
```

其中最重要的是控制器文件`app/controllers/articles_controller.rb`。让我们来看一下它：

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```

`index`动作是空的。当一个动作没有显式地渲染视图（或以其他方式触发HTTP响应）时，Rails将自动渲染与控制器和动作名称匹配的视图。约定优于配置！视图位于`app/views`目录中。因此，默认情况下，`index`动作将渲染`app/views/articles/index.html.erb`。

让我们打开`app/views/articles/index.html.erb`，并将其内容替换为：

```html
<h1>Hello, Rails!</h1>
```

如果您之前停止了Web服务器以运行控制器生成器，请使用`bin/rails server`重新启动它。现在访问<http://localhost:3000/articles>，可以看到我们的文本显示出来了！

### 设置应用程序主页

目前，<http://localhost:3000>仍然显示带有Ruby on Rails徽标的页面。让我们也在<http://localhost:3000>上显示我们的“Hello, Rails!”文本。为此，我们将添加一个路由，将应用程序的*根路径*映射到相应的控制器和动作。

让我们打开`config/routes.rb`，并在`Rails.application.routes.draw`块的顶部添加以下`root`路由：

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

现在当我们访问<http://localhost:3000>时，可以看到我们的“Hello, Rails!”文本，确认`root`路由也映射到`ArticlesController`的`index`动作。

提示：要了解更多关于路由的信息，请参阅[Rails Routing from the Outside In](routing.html)。

自动加载
-----------

Rails应用程序**不使用**`require`来加载应用程序代码。

您可能已经注意到`ArticlesController`继承自`ApplicationController`，但`app/controllers/articles_controller.rb`没有类似以下内容的代码：

```ruby
require "application_controller" # 不要这样做。
```

应用程序的类和模块在任何地方都可用，您不需要也**不应该**使用`require`加载`app`下的任何内容。这个功能被称为_自动加载_，您可以在[_Autoloading and Reloading Constants_](autoloading_and_reloading_constants.html)中了解更多相关信息。
你只需要使用`require`调用来满足两种情况：

* 加载`lib`目录下的文件。
* 加载在`Gemfile`中有`require: false`的gem依赖项。

MVC和你
-----------

到目前为止，我们已经讨论了路由、控制器、动作和视图。所有这些都是遵循[MVC（模型-视图-控制器）](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)模式的Web应用程序的典型组成部分。MVC是一种设计模式，将应用程序的责任划分为不同的部分，以便更容易理解。Rails按照这个约定遵循这种设计模式。

由于我们有一个控制器和一个视图可以使用，让我们生成下一个部分：一个模型。

### 生成模型

*模型*是一个用于表示数据的Ruby类。此外，模型可以通过Rails的一个名为*Active Record*的功能与应用程序的数据库进行交互。

要定义一个模型，我们将使用模型生成器：

```bash
$ bin/rails generate model Article title:string body:text
```

注意：模型名称是**单数**的，因为实例化的模型表示单个数据记录。为了记住这个约定，想象一下你如何调用模型的构造函数：我们想要写`Article.new(...)`，而不是`Articles.new(...)`。

这将创建几个文件：

```
invoke  active_record
create    db/migrate/<timestamp>_create_articles.rb
create    app/models/article.rb
invoke    test_unit
create      test/models/article_test.rb
create      test/fixtures/articles.yml
```

我们将重点关注两个文件：迁移文件（`db/migrate/<timestamp>_create_articles.rb`）和模型文件（`app/models/article.rb`）。

### 数据库迁移

*迁移*用于修改应用程序的数据库结构。在Rails应用程序中，迁移是用Ruby编写的，以便它们可以与数据库无关。

让我们来看看我们新迁移文件的内容：

```ruby
class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

对`create_table`的调用指定了如何构建`articles`表。默认情况下，`create_table`方法会添加一个`id`列作为自增的主键。因此，表中的第一条记录的`id`为1，下一条记录的`id`为2，依此类推。

在`create_table`的块内部，定义了两个列：`title`和`body`。这些列是由生成器添加的，因为我们在生成命令中包含了它们（`bin/rails generate model Article title:string body:text`）。

在块的最后一行是对`t.timestamps`的调用。这个方法定义了两个额外的列，名为`created_at`和`updated_at`。正如我们将看到的，Rails将为我们管理这些列，在创建或更新模型对象时设置值。

让我们使用以下命令运行我们的迁移：

```bash
$ bin/rails db:migrate
```

该命令将显示输出，指示表已创建：

```
==  CreateArticles: migrating ===================================
-- create_table(:articles)
   -> 0.0018s
==  CreateArticles: migrated (0.0018s) ==========================
```

提示：要了解更多关于迁移的信息，请参阅[Active Record迁移](active_record_migrations.html)。

现在我们可以使用我们的模型与表进行交互。

### 使用模型与数据库交互

为了玩弄一下我们的模型，我们将使用Rails的一个名为*控制台*的功能。控制台是一个交互式编码环境，就像`irb`一样，但它还会自动加载Rails和我们的应用程序代码。

让我们使用以下命令启动控制台：

```bash
$ bin/rails console
```

你应该看到一个类似于`irb`的提示符：

```irb
Loading development environment (Rails 7.0.0)
irb(main):001:0>
```

在这个提示符下，我们可以初始化一个新的`Article`对象：

```irb
irb> article = Article.new(title: "Hello Rails", body: "I am on Rails!")
```

重要的是要注意，我们只是*初始化*了这个对象。这个对象根本没有保存到数据库中。它只在控制台中的当前时刻可用。要将对象保存到数据库中，我们必须调用[`save`](https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save)方法：

```irb
irb> article.save
(0.1ms)  begin transaction
Article Create (0.4ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "Hello Rails"], ["body", "I am on Rails!"], ["created_at", "2020-01-18 23:47:30.734416"], ["updated_at", "2020-01-18 23:47:30.734416"]]
(0.9ms)  commit transaction
=> true
```

上面的输出显示了一个`INSERT INTO "articles" ...`的数据库查询。这表明文章已被插入到我们的表中。如果我们再次查看`article`对象，我们会发现有一些有趣的事情发生了：

```irb
irb> article
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```
对象的`id`、`created_at`和`updated_at`属性现在已经设置好了。当我们保存对象时，Rails会为我们完成这个操作。

当我们想要从数据库中获取这篇文章时，我们可以在模型上调用[`find`](
https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find)
方法，并将`id`作为参数传递进去：

```irb
irb> Article.find(1)
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

当我们想要从数据库中获取所有文章时，我们可以在模型上调用[`all`](
https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all)
方法：

```irb
irb> Article.all
=> #<ActiveRecord::Relation [#<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">]>
```

这个方法返回一个[`ActiveRecord::Relation`](
https://api.rubyonrails.org/classes/ActiveRecord/Relation.html)对象，你可以把它看作是一个功能强大的数组。

提示：要了解更多关于模型的内容，请参阅[Active Record基础知识](
active_record_basics.html)和[Active Record查询接口](
active_record_querying.html)。

模型是MVC拼图的最后一块。接下来，我们将把所有的部分连接在一起。

### 显示文章列表

让我们回到`app/controllers/articles_controller.rb`中的控制器，并将`index`动作修改为从数据库中获取所有文章：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

控制器实例变量可以在视图中访问。这意味着我们可以在`app/views/articles/index.html.erb`中引用`@articles`。让我们打开这个文件，并用以下内容替换它：

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

上面的代码是HTML和*ERB*的混合体。ERB是一个模板系统，它在文档中评估嵌入的Ruby代码。在这里，我们可以看到两种类型的ERB标签：`<% %>`和`<%= %>`。`<% %>`标签的意思是“评估封闭的Ruby代码”。`<%= %>`标签的意思是“评估封闭的Ruby代码，并输出它返回的值”。你可以在这些ERB标签中写任何你在普通Ruby程序中可以写的东西，尽管通常最好将ERB标签的内容保持简短，以提高可读性。

由于我们不想输出`@articles.each`返回的值，所以我们将该代码放在了`<% %>`中。但是，由于我们确实想要输出`article.title`的值（对于每篇文章），所以我们将该代码放在了`<%= %>`中。

我们可以通过访问<http://localhost:3000>来查看最终结果。（记得要运行`bin/rails server`！）当我们这样做时，会发生以下情况：

1. 浏览器发送请求：`GET http://localhost:3000`。
2. 我们的Rails应用程序接收到这个请求。
3. Rails路由器将根路由映射到`ArticlesController`的`index`动作。
4. `index`动作使用`Article`模型从数据库中获取所有文章。
5. Rails自动渲染`app/views/articles/index.html.erb`视图。
6. 视图中的ERB代码被评估为输出HTML。
7. 服务器将包含HTML的响应发送回浏览器。

我们已经将所有的MVC部分连接在一起，我们有了第一个控制器动作！接下来，我们将继续进行第二个动作。

在适当的地方进行CRUD操作
--------------------------

几乎所有的Web应用程序都涉及到[CRUD（创建、读取、更新和删除）](
https://en.wikipedia.org/wiki/Create,_read,_update,_and_delete)操作。你甚至可能发现，你的应用程序大部分工作都是CRUD。Rails意识到了这一点，并提供了许多功能来帮助简化执行CRUD操作的代码。

让我们通过为我们的应用程序添加更多功能来开始探索这些特性。

### 显示单篇文章

我们目前有一个视图，列出了数据库中的所有文章。让我们添加一个新的视图，显示单篇文章的标题和内容。

我们首先通过添加一个新的路由来映射到一个新的控制器动作（我们将在下一步中添加）来开始。打开`config/routes.rb`，并插入最后一个显示的路由：

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

新的路由是另一个`get`路由，但在路径中有一些额外的内容：`:id`。这表示一个路由*参数*。路由参数捕获请求路径的一个片段，并将该值放入`params`哈希中，控制器动作可以访问它。例如，当处理像`GET http://localhost:3000/articles/1`这样的请求时，`1`将被捕获为`:id`的值，然后在`ArticlesController`的`show`动作中可以通过`params[:id]`访问到它。
现在我们在`app/controllers/articles_controller.rb`的`index`操作下方添加`show`操作：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

`show`操作调用`Article.find`（之前提到过）并传入路由参数中捕获的ID。返回的文章存储在`@article`实例变量中，因此可以在视图中访问。默认情况下，`show`操作将渲染`app/views/articles/show.html.erb`。

让我们创建`app/views/articles/show.html.erb`，内容如下：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

现在当我们访问<http://localhost:3000/articles/1>时，可以看到文章！

最后，让我们添加一个方便的方式来访问文章页面。我们将在`app/views/articles/index.html.erb`中将每篇文章的标题链接到其页面：

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

### 资源路由

到目前为止，我们已经涵盖了CRUD中的“R”（读取）部分。我们最终将涵盖“C”（创建）、“U”（更新）和“D”（删除）部分。正如你可能已经猜到的那样，我们将通过添加新的路由、控制器操作和视图来完成这些操作。每当我们有这样一组路由、控制器操作和视图共同工作以在实体上执行CRUD操作时，我们称该实体为*资源*。例如，在我们的应用程序中，我们可以说一篇文章是一个资源。

Rails提供了一个名为[`resources`](https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources)的路由方法，用于映射一组资源（例如文章）的所有常规路由。因此，在继续进行“C”、“U”和“D”部分之前，让我们用`resources`替换`config/routes.rb`中的两个`get`路由：

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

我们可以通过运行`bin/rails routes`命令来查看映射的路由：

```bash
$ bin/rails routes
      Prefix Verb   URI Pattern                  Controller#Action
        root GET    /                            articles#index
    articles GET    /articles(.:format)          articles#index
 new_article GET    /articles/new(.:format)      articles#new
     article GET    /articles/:id(.:format)      articles#show
             POST   /articles(.:format)          articles#create
edit_article GET    /articles/:id/edit(.:format) articles#edit
             PATCH  /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
```

`resources`方法还设置了URL和路径辅助方法，我们可以使用这些方法来使我们的代码不依赖于特定的路由配置。上述“Prefix”列中的值加上后缀`_url`或`_path`形成这些辅助方法的名称。例如，`article_path`辅助方法在给定一篇文章时返回`"/articles/#{article.id}"`。我们可以使用它来整理`app/views/articles/index.html.erb`中的链接：

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

然而，我们将进一步使用[`link_to`](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)辅助方法。`link_to`辅助方法使用其第一个参数作为链接的文本，第二个参数作为链接的目标。如果我们将一个模型对象作为第二个参数传递给`link_to`，它将调用适当的路径辅助方法将对象转换为路径。例如，如果我们传递一篇文章，`link_to`将调用`article_path`。因此，`app/views/articles/index.html.erb`变为：

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

很好！

提示：要了解更多关于路由的信息，请参阅[Rails Routing from the Outside In](routing.html)。

### 创建新文章

现在我们转向CRUD中的“C”（创建）部分。通常，在Web应用程序中，创建新资源是一个多步骤的过程。首先，用户请求一个要填写的表单。然后，用户提交表单。如果没有错误，资源将被创建，并显示某种确认信息。否则，表单将被重新显示，显示错误消息，并重复该过程。

在Rails应用程序中，这些步骤通常由控制器的`new`和`create`操作处理。让我们在`app/controllers/articles_controller.rb`的`show`操作下方添加这些操作的典型实现：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

`new`操作实例化一个新的文章，但不保存它。在构建表单时，这篇文章将在视图中使用。默认情况下，`new`操作将渲染`app/views/articles/new.html.erb`，我们将在下一步创建。


`create`操作会使用标题和正文的值实例化一个新的文章，并尝试保存它。如果文章成功保存，操作会将浏览器重定向到文章页面，地址为`"http://localhost:3000/articles/#{@article.id}"`。否则，操作会通过渲染`app/views/articles/new.html.erb`重新显示表单，并返回状态码[422 Unprocessable Entity](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/422)。这里的标题和正文是虚拟值。在创建表单后，我们会回来修改这些值。

注意：[`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to)会导致浏览器发起新的请求，而[`render`](https://api.rubyonrails.org/classes/AbstractController/Rendering.html#method-i-render)会为当前请求渲染指定的视图。在修改数据库或应用程序状态后，使用`redirect_to`非常重要。否则，如果用户刷新页面，浏览器会发起相同的请求，并重复执行修改操作。

#### 使用表单构建器

我们将使用Rails的一个特性称为*表单构建器*来创建我们的表单。使用表单构建器，我们可以编写最少量的代码来输出一个完全配置并遵循Rails约定的表单。

让我们创建`app/views/articles/new.html.erb`，内容如下：

```html+erb
<h1>新文章</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

[`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)辅助方法实例化一个表单构建器。在`form_with`块中，我们调用表单构建器的[`label`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-label)和[`text_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_field)等方法来输出适当的表单元素。

`form_with`调用的结果输出如下：

```html
<form action="/articles" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="...">

  <div>
    <label for="article_title">标题</label><br>
    <input type="text" name="article[title]" id="article_title">
  </div>

  <div>
    <label for="article_body">正文</label><br>
    <textarea name="article[body]" id="article_body"></textarea>
  </div>

  <div>
    <input type="submit" name="commit" value="创建文章" data-disable-with="创建文章">
  </div>
</form>
```

提示：要了解更多关于表单构建器的信息，请参阅[Action View表单辅助方法](form_helpers.html)。

#### 使用Strong Parameters

提交的表单数据会与捕获的路由参数一起放入`params`哈希中。因此，`create`操作可以通过`params[:article][:title]`访问提交的标题，通过`params[:article][:body]`访问提交的正文。我们可以将这些值逐个传递给`Article.new`，但这样做会冗长且可能容易出错。随着添加更多字段，情况会变得更糟。

相反，我们将传递一个包含这些值的单个哈希。但是，我们仍然必须指定哪些值允许在该哈希中。否则，恶意用户可能提交额外的表单字段并覆盖私有数据。实际上，如果我们直接将未经过滤的`params[:article]`哈希传递给`Article.new`，Rails会引发`ForbiddenAttributesError`以警告我们这个问题。因此，我们将使用Rails的一个特性称为*Strong Parameters*来过滤`params`。可以将其视为`params`的[强类型](https://en.wikipedia.org/wiki/Strong_and_weak_typing)。

让我们在`app/controllers/articles_controller.rb`的底部添加一个名为`article_params`的私有方法来过滤`params`。并且让我们修改`create`方法来使用它：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

提示：要了解更多关于Strong Parameters的信息，请参阅[Action Controller概述 § Strong Parameters](action_controller_overview.html#strong-parameters)。

#### 验证和显示错误消息

正如我们所见，创建资源是一个多步骤的过程。处理无效的用户输入是这个过程的另一步。Rails提供了一个称为*验证*的特性来帮助我们处理无效的用户输入。验证是在保存模型对象之前检查的规则。如果任何检查失败，保存将被中止，并且适当的错误消息将被添加到模型对象的`errors`属性中。

让我们在`app/models/article.rb`中为我们的模型添加一些验证：

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

第一个验证声明了`title`值必须存在。因为`title`是一个字符串，这意味着`title`值必须包含至少一个非空白字符。

第二个验证声明了`body`值也必须存在。此外，它声明了`body`值必须至少为10个字符长。

注意：你可能想知道`title`和`body`属性在哪里定义。Active Record会自动为每个表列定义模型属性，因此你不必在模型文件中声明这些属性。
有了我们的验证，让我们修改`app/views/articles/new.html.erb`来显示`title`和`body`的任何错误消息：

```html+erb
<h1>新文章</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

[`full_messages_for`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_messages_for)方法返回指定属性的用户友好的错误消息数组。如果该属性没有错误，则数组为空。

为了理解所有这些是如何协同工作的，让我们再次看一下`new`和`create`控制器动作：

```ruby
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
```

当我们访问<http://localhost:3000/articles/new>时，`GET /articles/new`请求被映射到`new`动作。`new`动作不会尝试保存`@article`。因此，验证不会被检查，也不会有错误消息。

当我们提交表单时，`POST /articles`请求被映射到`create`动作。`create`动作会尝试保存`@article`。因此，验证会被检查。如果任何验证失败，`@article`将不会被保存，并且将使用错误消息渲染`app/views/articles/new.html.erb`。

提示：要了解更多关于验证的信息，请参阅[Active Record 验证](active_record_validations.html)。要了解更多关于验证错误消息的信息，请参阅[Active Record 验证 § 使用验证错误](active_record_validations.html#working-with-validation-errors)。

#### 完成

我们现在可以通过访问<http://localhost:3000/articles/new>来创建一篇文章。为了完成，让我们在`app/views/articles/index.html.erb`的底部添加一个链接到该页面的链接：

```html+erb
<h1>文章</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "新文章", new_article_path %>
```

### 更新文章

我们已经涵盖了CRUD的“CR”部分。现在让我们继续“U”（更新）。更新资源与创建资源非常相似。它们都是多步骤的过程。首先，用户请求一个编辑数据的表单。然后，用户提交表单。如果没有错误，资源就会被更新。否则，表单将被重新显示，带有错误消息，并且过程会重复。

这些步骤通常由控制器的`edit`和`update`动作处理。让我们在`app/controllers/articles_controller.rb`中的`create`动作下面添加这些动作的典型实现：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

注意`edit`和`update`动作与`new`和`create`动作的相似之处。

`edit`动作从数据库中获取文章，并将其存储在`@article`中，以便在构建表单时使用。默认情况下，`edit`动作将渲染`app/views/articles/edit.html.erb`。

`update`动作重新从数据库中获取文章，并尝试使用由`article_params`过滤的提交的表单数据进行更新。如果没有验证失败并且更新成功，动作将重定向浏览器到文章页面。否则，动作通过渲染`app/views/articles/edit.html.erb`重新显示表单 - 带有错误消息。

#### 使用局部视图共享视图代码

我们的`edit`表单将与`new`表单相同。甚至代码也将相同，这要归功于Rails表单构建器和资源路由。表单构建器会自动配置表单，以根据模型对象是否已经保存来进行适当类型的请求。

由于代码将相同，我们将把它提取到一个名为*局部视图*的共享视图中。让我们创建`app/views/articles/_form.html.erb`，内容如下：

```html+erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```
上述代码与我们在`app/views/articles/new.html.erb`中的表单相同，只是将所有的`@article`替换为`article`。
由于局部视图是共享的代码，最佳实践是它们不依赖于控制器动作设置的特定实例变量。相反，我们将文章作为局部变量传递给局部视图。

让我们更新`app/views/articles/new.html.erb`，通过[`render`](
https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render)使用局部视图：

```html+erb
<h1>新文章</h1>

<%= render "form", article: @article %>
```

注意：局部视图的文件名必须以下划线为前缀，例如`_form.html.erb`。但在渲染时，引用时不需要下划线，例如`render "form"`。

现在，让我们创建一个非常类似的`app/views/articles/edit.html.erb`：

```html+erb
<h1>编辑文章</h1>

<%= render "form", article: @article %>
```

提示：要了解有关局部视图的更多信息，请参阅[在Rails中使用布局和渲染 § 使用局部视图](layouts_and_rendering.html#using-partials)。

#### 完成

现在，我们可以通过访问其编辑页面来更新文章，例如<http://localhost:3000/articles/1/edit>。完成后，让我们在`app/views/articles/show.html.erb`底部添加一个链接到编辑页面的链接：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "编辑", edit_article_path(@article) %></li>
</ul>
```

### 删除文章

最后，我们来到了CRUD的“D”（删除）部分。删除资源的过程比创建或更新更简单。它只需要一个路由和一个控制器动作。而我们的资源路由（`resources :articles`）已经提供了路由，将`DELETE /articles/:id`请求映射到`ArticlesController`的`destroy`动作。

因此，让我们在`app/controllers/articles_controller.rb`中添加一个典型的`destroy`动作，在`update`动作之后：

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

`destroy`动作从数据库中获取文章，并在其上调用[`destroy`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy)。然后，它将浏览器重定向到根路径，并使用状态码[303 See Other](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/303)。

我们选择重定向到根路径，因为那是我们文章的主要访问点。但在其他情况下，您可能选择重定向到例如`articles_path`。

现在，让我们在`app/views/articles/show.html.erb`底部添加一个链接，以便我们可以从文章页面删除文章：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "编辑", edit_article_path(@article) %></li>
  <li><%= link_to "删除", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "确定要删除吗？"
                  } %></li>
</ul>
```

在上面的代码中，我们使用`data`选项来设置“删除”链接的`data-turbo-method`和`data-turbo-confirm` HTML属性。这两个属性都与默认情况下包含在新的Rails应用程序中的[Turbo](https://turbo.hotwired.dev/)相关联。`data-turbo-method="delete"`将使链接发出`DELETE`请求而不是`GET`请求。`data-turbo-confirm="确定要删除吗？"`将在单击链接时显示确认对话框。如果用户取消对话框，请求将被中止。

就是这样！我们现在可以列出、显示、创建、更新和删除文章了！CRUD完全搞定！

添加第二个模型
---------------------

现在是时候向应用程序添加第二个模型了。第二个模型将处理文章的评论。

### 生成模型

我们将看到与之前创建`Article`模型时使用的相同的生成器。这次我们将创建一个`Comment`模型来保存对文章的引用。在终端中运行以下命令：

```bash
$ bin/rails generate model Comment commenter:string body:text article:references
```

此命令将生成四个文件：

| 文件                                         | 用途                                                                                                  |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| db/migrate/20140120201010_create_comments.rb | 在数据库中创建评论表的迁移（您的名称将包含不同的时间戳）                                               |
| app/models/comment.rb                        | Comment模型                                                                                            |
| test/models/comment_test.rb                  | Comment模型的测试框架                                                                                  |
| test/fixtures/comments.yml                   | 用于测试的示例评论                                                                                      |

首先，看一下`app/models/comment.rb`：

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

这与之前看到的`Article`模型非常相似。不同之处在于`belongs_to :article`这一行，它设置了一个Active Record _关联_。您将在本指南的下一部分中了解一些关联的知识。
在shell命令中使用的(`:references`)关键字是模型的特殊数据类型。
它在数据库表上创建一个新的列，该列以提供的模型名称附加一个`_id`，可以保存整数值。为了更好地理解，请在运行迁移后分析`db/schema.rb`文件。

除了模型之外，Rails还创建了一个迁移来创建相应的数据库表：

```ruby
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

`t.references`行创建了一个名为`article_id`的整数列，为其创建了一个索引，并创建了一个外键约束，该约束指向`articles`表的`id`列。继续运行迁移：

```bash
$ bin/rails db:migrate
```

Rails足够智能，只会对当前数据库尚未运行的迁移进行执行，所以在这种情况下，你只会看到：

```
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```

### 关联模型

Active Record关联允许您轻松地声明两个模型之间的关系。
对于评论和文章，您可以这样写出关系：

* 每个评论属于一篇文章。
* 一篇文章可以有多个评论。

实际上，这非常接近Rails用于声明此关联的语法。您已经在`Comment`模型（app/models/comment.rb）中看到了使每个评论属于一篇文章的代码行：

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

您需要编辑`app/models/article.rb`以添加关联的另一侧：

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

这两个声明使许多自动行为成为可能。例如，如果您有一个包含文章的实例变量`@article`，您可以使用`@article.comments`将属于该文章的所有评论作为数组检索出来。

提示：有关Active Record关联的更多信息，请参阅[Active Record关联](association_basics.html)指南。

### 为评论添加路由

与`articles`控制器一样，我们需要添加一个路由，以便Rails知道我们想要导航到哪里查看`comments`。再次打开`config/routes.rb`文件，并进行如下编辑：

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

这将`comments`创建为`articles`的嵌套资源。这是捕获文章和评论之间的层次关系的另一部分。

提示：有关路由的更多信息，请参阅[Rails路由](routing.html)指南。

### 生成控制器

有了模型，您可以开始创建相应的控制器。同样，我们将使用之前使用的相同生成器：

```bash
$ bin/rails generate controller Comments
```

这将创建三个文件和一个空目录：

| 文件/目录                                      | 用途                                     |
| -------------------------------------------- | ---------------------------------------- |
| app/controllers/comments_controller.rb       | Comments控制器                           |
| app/views/comments/                          | 存储控制器的视图                         |
| test/controllers/comments_controller_test.rb | 控制器的测试                             |
| app/helpers/comments_helper.rb               | 视图帮助文件                             |

与任何博客一样，我们的读者将在阅读文章后直接创建评论，并在添加评论后返回文章显示页面以查看他们的评论。因此，我们的`CommentsController`用于提供创建评论和在其到达时删除垃圾评论的方法。

因此，首先，我们将在文章显示模板（`app/views/articles/show.html.erb`）上进行连接，以允许我们创建新评论：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

这在`Article`显示页面上添加了一个表单，通过调用`CommentsController`的`create`操作创建一个新评论。这里的`form_with`调用使用了一个数组，将构建一个嵌套路由，例如`/articles/1/comments`。
让我们在`app/controllers/comments_controller.rb`中连接`create`：

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

你会发现这里比文章控制器中的控制器复杂一些。这是你设置的嵌套的副作用。每个评论的请求都必须跟踪评论所附属的文章，因此需要调用`Article`模型的`find`方法来获取相关的文章。

此外，代码利用了一些关联的方法。我们使用`@article.comments`上的`create`方法来创建并保存评论。这将自动将评论链接到特定的文章。

一旦我们创建了新的评论，我们将用户重定向回原始文章，使用`article_path(@article)`助手方法。正如我们已经看到的，这将调用`ArticlesController`的`show`动作，进而渲染`show.html.erb`模板。这就是我们想要显示评论的地方，所以让我们将其添加到`app/views/articles/show.html.erb`中。

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Comments</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

现在你可以在博客中添加文章和评论，并在正确的位置显示它们。

![Article with Comments](images/getting_started/article_with_comments.png)

重构
-----------

现在我们已经让文章和评论正常工作了，让我们看看`app/views/articles/show.html.erb`模板。它变得又长又笨重。我们可以使用局部模板来简化它。

### 渲染局部集合

首先，我们将创建一个评论局部模板，用于显示文章的所有评论。创建文件`app/views/comments/_comment.html.erb`，并将以下内容放入其中：

```html+erb
<p>
  <strong>Commenter:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comment:</strong>
  <%= comment.body %>
</p>
```

然后，你可以将`app/views/articles/show.html.erb`更改为以下内容：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

现在，这将为`@article.comments`集合中的每个评论渲染一次局部模板。`render`方法遍历`@article.comments`集合时，它会将每个评论分配给一个名为局部模板的局部变量，本例中为`comment`，然后在局部模板中可用于显示。

### 渲染局部表单

我们还可以将新评论部分移动到自己的局部模板中。同样，你可以创建一个包含以下内容的文件`app/views/comments/_form.html.erb`：

```html+erb
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

然后，你可以将`app/views/articles/show.html.erb`更改为以下内容：

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= render 'comments/form' %>
```

第二个`render`只是定义了我们要渲染的局部模板，`comments/form`。Rails足够聪明，能够在该字符串中识别到斜杠，并意识到你想要渲染`app/views/comments`目录中的`_form.html.erb`文件。

`@article`对象对于在视图中渲染的任何局部模板都是可用的，因为我们将其定义为实例变量。

### 使用Concerns

Concerns是使大型控制器或模型更易于理解和管理的一种方法。这也具有当多个模型（或控制器）共享相同的Concerns时的可重用性优势。Concerns使用包含表示模型或控制器负责的功能的明确定义的方法的模块来实现。在其他语言中，模块通常被称为混入。
您可以像使用任何模块一样在控制器或模型中使用concerns。当您使用`rails new blog`创建应用程序时，除了其他文件夹外，还会在`app/`下创建两个文件夹：

```
app/controllers/concerns
app/models/concerns
```

在下面的示例中，我们将为博客实现一个新功能，该功能可以从使用concern中受益。然后，我们将创建一个concern，并重构代码以使用它，使代码更加DRY和可维护。

博客文章可能具有各种状态 - 例如，它可以对所有人可见（即`public`），或仅对作者可见（即`private`）。它也可以对所有人隐藏但仍可检索（即`archived`）。评论也可以类似地隐藏或可见。这可以使用每个模型中的`status`列来表示。

首先，让我们运行以下迁移以将`status`添加到`Articles`和`Comments`：

```bash
$ bin/rails generate migration AddStatusToArticles status:string
$ bin/rails generate migration AddStatusToComments status:string
```

然后，让我们使用生成的迁移更新数据库：

```bash
$ bin/rails db:migrate
```

要为现有文章和评论选择状态，您可以通过在生成的迁移文件中添加`default: "public"`选项来为其添加默认值，然后再次运行迁移。您还可以在rails控制台中调用`Article.update_all(status: "public")`和`Comment.update_all(status: "public")`。

提示：要了解有关迁移的更多信息，请参阅[Active Record Migrations](active_record_migrations.html)。

我们还必须将`：status`键作为强参数的一部分允许在`app/controllers/articles_controller.rb`中：

```ruby

  private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
```

以及在`app/controllers/comments_controller.rb`中：

```ruby

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

在`article`模型中，在使用`bin/rails db:migrate`命令运行迁移以添加`status`列之后，您将添加以下内容：

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

以及在`Comment`模型中：

```ruby
class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

然后，在我们的`index`操作模板（`app/views/articles/index.html.erb`）中，我们将使用`archived?`方法来避免显示任何已归档的文章：

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

类似地，在我们的评论局部视图（`app/views/comments/_comment.html.erb`）中，我们将使用`archived?`方法来避免显示任何已归档的评论：

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>
```

然而，如果您再次查看我们的模型，您会发现逻辑是重复的。如果在将来我们增加博客的功能 - 例如包括私人消息 - 我们可能会再次复制逻辑。这就是concerns派上用场的地方。

concerns只负责模型责任的一个专注子集；我们concern中的方法都与模型的可见性相关。让我们称之为`Visible`的新concern（模块）。我们可以在`app/models/concerns`中创建一个名为`visible.rb`的新文件，并将所有在模型中重复的状态方法存储在其中。

`app/models/concerns/visible.rb`

```ruby
module Visible
  def archived?
    status == 'archived'
  end
end
```

我们可以将状态验证添加到concern中，但这稍微复杂一些，因为验证是在类级别调用的方法。`ActiveSupport::Concern`（[API指南](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)）为我们提供了一种更简单的方式来包含它们：

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  def archived?
    status == 'archived'
  end
end
```

现在，我们可以从每个模型中删除重复的逻辑，并包含我们的新`Visible`模块：

在`app/models/article.rb`中：

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

以及在`app/models/comment.rb`中：

```ruby
class Comment < ApplicationRecord
  include Visible

  belongs_to :article
end
```
类方法也可以添加到concern中。如果我们想在主页上显示公共文章或评论的计数，可以像下面这样将一个类方法添加到Visible模块中：

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      where(status: 'public').count
    end
  end

  def archived?
    status == 'archived'
  end
end
```

然后在视图中，可以像调用任何类方法一样调用它：

```html+erb
<h1>文章</h1>

我们的博客有 <%= Article.public_count %> 篇文章，而且还在不断增加！

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "新文章", new_article_path %>
```

接下来，我们将在表单中添加一个选择框，让用户在创建新文章或发布新评论时选择状态。我们还可以将默认状态指定为“public”。在`app/views/articles/_form.html.erb`中，我们可以添加以下内容：

```html+erb
<div>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</div>
```

在`app/views/comments/_form.html.erb`中添加以下内容：

```html+erb
<p>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</p>
```

删除评论
-----------------

博客的另一个重要功能是能够删除垃圾评论。为了实现这个功能，我们需要在视图中实现一个链接，并在`CommentsController`中实现一个`destroy`操作。

首先，在`app/views/comments/_comment.html.erb`局部视图中添加删除链接：

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>评论者：</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>评论：</strong>
    <%= comment.body %>
  </p>

  <p>
    <%= link_to "删除评论", [comment.article, comment], data: {
                  turbo_method: :delete,
                  turbo_confirm: "确定要删除吗？"
                } %>
  </p>
<% end %>
```

点击这个新的“删除评论”链接将发送一个`DELETE /articles/:article_id/comments/:id`请求到我们的`CommentsController`，然后我们可以使用这个请求来找到要删除的评论。因此，让我们在控制器中添加一个`destroy`操作（`app/controllers/comments_controller.rb`）：

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), status: :see_other
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
end
```

`destroy`操作将找到我们正在查看的文章，然后在`@article.comments`集合中找到评论，并从数据库中删除它，然后将我们重定向到文章的显示操作。

### 删除关联对象

如果删除一篇文章，它关联的评论也需要被删除，否则它们将占据数据库中的空间。Rails允许您使用关联的`dependent`选项来实现这一点。修改Article模型（`app/models/article.rb`）如下：

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

安全性
--------

### 基本身份验证

如果您将博客发布到互联网上，任何人都可以添加、编辑和删除文章或删除评论。

Rails提供了一个HTTP身份验证系统，在这种情况下非常有用。

在`ArticlesController`中，我们需要一种方法来阻止未经身份验证的用户访问各种操作。在这里，我们可以使用Rails的`http_basic_authenticate_with`方法，如果该方法允许访问请求的操作，则允许访问。

为了使用身份验证系统，我们在`ArticlesController`的顶部（`app/controllers/articles_controller.rb`）指定它。在我们的情况下，我们希望用户在除了`index`和`show`之外的每个操作上进行身份验证，因此我们写下：

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # 省略部分代码
```

我们还希望只允许经过身份验证的用户删除评论，因此在`CommentsController`（`app/controllers/comments_controller.rb`）中，我们写下：

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # 省略部分代码
```

现在，如果您尝试创建一篇新文章，您将会看到一个基本的HTTP身份验证挑战：

![Basic HTTP Authentication Challenge](images/getting_started/challenge.png)

在输入正确的用户名和密码后，您将保持身份验证状态，直到需要不同的用户名和密码或关闭浏览器。
Rails应用程序还有其他身份验证方法可用。Rails的两个流行的身份验证插件是[Devise](https://github.com/plataformatec/devise)和[Authlogic](https://github.com/binarylogic/authlogic)，还有其他一些选择。

### 其他安全考虑

安全性，特别是在Web应用程序中，是一个广泛而详细的领域。有关Rails应用程序的安全性更详细的内容，请参阅[Ruby on Rails安全指南](security.html)。

接下来做什么？
------------

既然您已经看到了您的第一个Rails应用程序，您可以随意更新它并进行自己的实验。

请记住，您不必在没有帮助的情况下完成所有任务。在您需要Rails的帮助时，请随时参考以下支持资源：

* [Ruby on Rails指南](index.html)
* [Ruby on Rails邮件列表](https://discuss.rubyonrails.org/c/rubyonrails-talk)

配置注意事项
---------------------

使用Rails的最简单方法是将所有外部数据存储为UTF-8格式。如果您没有这样做，Ruby库和Rails通常可以将您的本地数据转换为UTF-8，但这并不总是可靠的，所以最好确保所有外部数据都是UTF-8格式的。

如果您在这个领域犯了一个错误，最常见的症状是浏览器中出现一个带有问号的黑色菱形。另一个常见的症状是出现类似于"Ã¼"而不是"ü"的字符。Rails采取了一些内部步骤来减轻这些问题的常见原因，这些原因可以被自动检测和纠正。然而，如果您有作为UTF-8存储的外部数据，它偶尔可能导致这些问题，这些问题无法被Rails自动检测和纠正。

两个非UTF-8格式的常见数据来源：

* 您的文本编辑器：大多数文本编辑器（如TextMate）默认将文件保存为UTF-8格式。如果您的文本编辑器没有这样做，这可能导致您在模板中输入的特殊字符（如é）在浏览器中显示为带有问号的菱形。这也适用于您的i18n翻译文件。大多数没有默认为UTF-8格式的编辑器（如某些版本的Dreamweaver）都提供了将默认格式更改为UTF-8的方法。请进行更改。
* 您的数据库：Rails默认将从数据库中获取的数据转换为UTF-8格式。然而，如果您的数据库内部不使用UTF-8格式，它可能无法存储用户输入的所有字符。例如，如果您的数据库内部使用的是Latin-1格式，并且用户输入了俄语、希伯来语或日语字符，那么一旦数据进入数据库，它将永远丢失。如果可能，请使用UTF-8作为数据库的内部存储格式。
