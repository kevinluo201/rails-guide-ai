**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c1e56036aa9fd68276daeec5a9407096
在Rails中使用JavaScript
=====================

本指南介绍了将JavaScript功能集成到Rails应用程序中的选项，包括使用外部JavaScript包的选项以及如何在Rails中使用Turbo。

阅读本指南后，您将了解：

* 如何在不需要Node.js、Yarn或JavaScript打包工具的情况下使用Rails。
* 如何使用import maps、esbuild、rollup或webpack来打包JavaScript创建新的Rails应用程序。
* Turbo是什么，以及如何使用它。
* 如何使用Rails提供的Turbo HTML助手。

--------------------------------------------------------------------------------

导入映射
-----------

[导入映射](https://github.com/rails/importmap-rails)允许您使用逻辑名称直接从浏览器导入JavaScript模块，这些逻辑名称与版本化文件相对应。从Rails 7开始，导入映射是默认选项，允许任何人在不需要转译或打包的情况下构建现代JavaScript应用程序。

使用导入映射的应用程序不需要[Node.js](https://nodejs.org/en/)或[Yarn](https://yarnpkg.com/)。如果您计划使用`importmap-rails`来管理JavaScript依赖项，那么无需安装Node.js或Yarn。

使用导入映射时，无需单独的构建过程，只需使用`bin/rails server`启动服务器即可。

### 安装importmap-rails

对于新应用程序，Rails 7+会自动包含Rails的Importmap，但您也可以在现有应用程序中手动安装它：

```bash
$ bin/bundle add importmap-rails
```

运行安装任务：

```bash
$ bin/rails importmap:install
```

### 使用importmap-rails添加NPM包

要将新包添加到使用import map的应用程序中，请从终端运行`bin/importmap pin`命令：

```bash
$ bin/importmap pin react react-dom
```

然后，像往常一样将包导入到`application.js`中：

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

使用JavaScript打包工具添加NPM包
--------

导入映射是新Rails应用程序的默认选项，但如果您更喜欢传统的JavaScript打包，可以使用您选择的[esbuild](https://esbuild.github.io/)、[webpack](https://webpack.js.org/)或[rollup.js](https://rollupjs.org/guide/en/)创建新的Rails应用程序。

要在新的Rails应用程序中使用打包工具而不是导入映射，请将`—javascript`或`-j`选项传递给`rails new`：

```bash
$ rails new my_new_app --javascript=webpack
或
$ rails new my_new_app -j webpack
```

这些打包选项都带有简单的配置，并通过[jsbundling-rails](https://github.com/rails/jsbundling-rails) gem与资产管道集成。

使用打包选项时，使用`bin/dev`启动Rails服务器并构建开发环境的JavaScript。

### 安装Node.js和Yarn

如果您在Rails应用程序中使用JavaScript打包工具，则必须安装Node.js和Yarn。

在[Node.js网站](https://nodejs.org/en/download/)上找到安装说明，并使用以下命令验证其是否正确安装：

```bash
$ node --version
```

您的Node.js运行时版本应该被打印出来。确保它大于`8.16.0`。

要安装Yarn，请按照[Yarn网站](https://classic.yarnpkg.com/en/docs/install)上的安装说明进行操作。运行此命令应该打印出Yarn的版本：

```bash
$ yarn --version
```

如果它显示类似于`1.22.0`的内容，则Yarn已正确安装。

在导入映射和JavaScript打包工具之间进行选择
-----------------------------------------------------

创建新的Rails应用程序时，您需要在导入映射和JavaScript打包解决方案之间进行选择。每个应用程序都有不同的要求，您应该在选择JavaScript选项之前仔细考虑您的要求，因为对于大型复杂应用程序来说，从一种选项迁移到另一种选项可能是耗时的。

导入映射是默认选项，因为Rails团队相信导入映射在减少复杂性、改善开发人员体验和提供性能增益方面的潜力。

对于许多应用程序，特别是那些主要依赖[Hotwire](https://hotwired.dev/)堆栈满足其JavaScript需求的应用程序，导入映射将是长期的正确选择。您可以在此处阅读有关在Rails 7中将导入映射设置为默认选项的原因的更多信息[here](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b)。

其他应用程序可能仍需要传统的JavaScript打包工具。表明您应该选择传统打包工具的要求包括：

* 如果您的代码需要转译步骤，例如JSX或TypeScript。
* 如果您需要使用包含CSS或依赖于[Webpack加载器](https://webpack.js.org/loaders/)的JavaScript库。
* 如果您确信需要[tree-shaking](https://webpack.js.org/guides/tree-shaking/)。
* 如果您将通过[cssbundling-rails gem](https://github.com/rails/cssbundling-rails)安装Bootstrap、Bulma、PostCSS或Dart CSS，除了Tailwind和Sass之外，此gem提供的所有选项都会在`rails new`中自动为您安装`esbuild`，如果您没有在`rails new`中指定其他选项。
Turbo
-----

无论您选择使用导入映射还是传统的打包工具，Rails都附带了[Turbo](https://turbo.hotwired.dev/)，可以加快应用程序的速度，同时大大减少您需要编写的JavaScript代码量。

Turbo使您的服务器能够直接传递HTML，作为传统前端框架的替代方案，将Rails应用程序的服务器端减少到几乎只是一个JSON API。

### Turbo Drive

[Turbo Drive](https://turbo.hotwired.dev/handbook/drive)通过避免在每次导航请求时进行完整页面的拆除和重建来加快页面加载速度。 Turbo Drive是对Turbolinks的改进和替代。

### Turbo Frames

[Turbo Frames](https://turbo.hotwired.dev/handbook/frames)允许在请求时更新页面的预定义部分，而不影响页面的其他内容。

您可以使用Turbo Frames构建无需任何自定义JavaScript的原地编辑，延迟加载内容，并轻松创建服务器渲染的选项卡界面。

Rails提供了HTML辅助程序，通过[turbo-rails](https://github.com/hotwired/turbo-rails) gem来简化Turbo Frames的使用。

使用这个gem，您可以使用`turbo_frame_tag`辅助程序将Turbo Frame添加到您的应用程序中，如下所示：

```erb
<%= turbo_frame_tag dom_id(post) do %>
  <div>
     <%= link_to post.title, post_path(post) %>
  </div>
<% end %>
```

### Turbo Streams

[Turbo Streams](https://turbo.hotwired.dev/handbook/streams)将页面更改作为包装在自执行的`<turbo-stream>`元素中的HTML片段传递。 Turbo Streams允许您通过WebSockets广播其他用户所做的更改，并在表单提交后更新页面的部分内容，而无需进行完整的页面加载。

Rails通过[turbo-rails](https://github.com/hotwired/turbo-rails) gem提供了HTML和服务器端辅助程序，以简化Turbo Streams的使用。

使用这个gem，您可以从控制器操作中呈现Turbo Streams：

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Rails将自动查找`.turbo_stream.erb`视图文件，并在找到时呈现该视图。

Turbo Stream响应也可以在控制器操作中内联呈现：

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream { render turbo_stream: turbo_stream.prepend('posts', partial: 'post') }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

最后，Turbo Streams可以从模型或后台作业中使用内置辅助程序启动。这些广播可以用于通过WebSocket连接向所有用户更新内容，保持页面内容的新鲜度，使您的应用程序栩栩如生。

要从模型中广播Turbo Stream，请结合模型回调使用以下方式：

```ruby
class Post < ApplicationRecord
  after_create_commit { broadcast_append_to('posts') }
end
```

在应该接收更新的页面上设置WebSocket连接，如下所示：

```erb
<%= turbo_stream_from "posts" %>
```

替代Rails/UJS功能
----------------------------------------

Rails 6附带了一个名为UJS（Unobtrusive JavaScript）的工具。 UJS允许开发人员覆盖`<a>`标签的HTTP请求方法，在执行操作之前添加确认对话框等功能。在Rails 7之前，UJS是默认选项，但现在建议使用Turbo。

### 方法

点击链接始终会导致HTTP GET请求。如果您的应用程序是[RESTful](https://en.wikipedia.org/wiki/Representational_State_Transfer)，某些链接实际上是在服务器上更改数据的操作，并且应该使用非GET请求执行。 `data-turbo-method`属性允许使用显式方法（例如“post”，“put”或“delete”）标记此类链接。

Turbo将扫描应用程序中的`<a>`标签，查找`turbo-method`数据属性，并在存在时使用指定的方法，覆盖默认的GET操作。

例如：

```erb
<%= link_to "Delete post", post_path(post), data: { turbo_method: "delete" } %>
```

这将生成：

```html
<a data-turbo-method="delete" href="...">Delete post</a>
```

更改链接的方法的`data-turbo-method`的替代方法是使用Rails的`button_to`辅助程序。出于可访问性原因，对于任何非GET操作，实际按钮和表单更可取。

### 确认

您可以通过在链接和表单上添加`data-turbo-confirm`属性来向用户请求额外的确认。在单击链接或提交表单时，用户将看到一个包含属性文本的JavaScript `confirm()`对话框。如果用户选择取消，则不执行操作。

例如，使用`link_to`辅助程序：

```erb
<%= link_to "Delete post", post_path(post), data: { turbo_method: "delete", turbo_confirm: "Are you sure?" } %>
```

这将生成：

```html
<a href="..." data-turbo-confirm="Are you sure?" data-turbo-method="delete">Delete post</a>
```
当用户点击“删除帖子”链接时，将弹出一个“确定要删除吗？”的确认对话框。

该属性也可以与`button_to`助手一起使用，但必须添加到`button_to`助手内部渲染的表单中：

```erb
<%= button_to "删除帖子", post, method: :delete, form: { data: { turbo_confirm: "确定要删除吗？" } } %>
```

### Ajax请求

从JavaScript发起非GET请求时，需要添加`X-CSRF-Token`头。没有这个头部，请求将不会被Rails接受。

注意：Rails需要此令牌来防止跨站请求伪造（CSRF）攻击。在[安全指南](security.html#cross-site-request-forgery-csrf)中了解更多信息。

[Rails Request.JS](https://github.com/rails/request.js)封装了添加Rails所需的请求头的逻辑。只需从包中导入`FetchRequest`类，并实例化它，传递请求方法、URL和选项，然后调用`await request.perform()`并对响应进行处理。

例如：

```javascript
import { FetchRequest } from '@rails/request.js'

....

async myMethod () {
  const request = new FetchRequest('post', 'localhost:3000/posts', {
    body: JSON.stringify({ name: 'Request.JS' })
  })
  const response = await request.perform()
  if (response.ok) {
    const body = await response.text
  }
}
```

当使用其他库进行Ajax调用时，需要自己将安全令牌添加为默认头部。要获取令牌，请查看应用视图中由[`csrf_meta_tags`][]打印的`<meta name='csrf-token' content='THE-TOKEN'>`标签。可以这样做：

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
