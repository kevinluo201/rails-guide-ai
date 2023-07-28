**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 02f663dc709da76ced45deb2ba800a78
Rails中的布局和渲染
=================

本指南介绍了Action Controller和Action View的基本布局功能。

阅读本指南后，您将了解：

* 如何使用Rails内置的各种渲染方法。
* 如何创建具有多个内容部分的布局。
* 如何使用局部视图来减少重复代码。
* 如何使用嵌套布局（子模板）。

--------------------------------------------------------------------------------

概述：各个部分的配合
---------------------

本指南重点介绍了模型-视图-控制器三角形中控制器和视图之间的交互。如您所知，控制器负责在Rails中处理请求的整个过程，尽管它通常将任何繁重的代码交给模型处理。但是，当需要向用户发送响应时，控制器将任务交给视图。这就是本指南的主题。

大致来说，这涉及决定应该发送什么作为响应，并调用适当的方法来创建该响应。如果响应是一个完整的视图，Rails还会做一些额外的工作，将视图包装在布局中，并可能引入局部视图。您将在本指南的后面看到所有这些路径。

创建响应
------------------

从控制器的角度来看，有三种方法可以创建HTTP响应：

* 调用[`render`][controller.render]创建要发送回浏览器的完整响应
* 调用[`redirect_to`][]向浏览器发送HTTP重定向状态码
* 调用[`head`][]创建仅由HTTP头组成的响应，发送回浏览器


### 默认渲染：约定优于配置

您可能听说过Rails提倡“约定优于配置”。默认渲染就是一个很好的例子。默认情况下，Rails中的控制器会自动渲染与有效路由对应的视图。例如，如果您在`BooksController`类中有以下代码：

```ruby
class BooksController < ApplicationController
end
```

并且在您的路由文件中有以下内容：

```ruby
resources :books
```

并且您有一个视图文件`app/views/books/index.html.erb`：

```html+erb
<h1>Books are coming soon!</h1>
```

当您导航到`/books`时，Rails将自动渲染`app/views/books/index.html.erb`，您将在屏幕上看到“Books are coming soon!”。

然而，即将推出的屏幕只是最基本的功能，因此您很快将创建您的`Book`模型，并将索引操作添加到`BooksController`中：

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

请注意，根据“约定优于配置”原则，在索引操作的末尾我们没有显式地进行渲染。规则是，如果您在控制器操作的末尾没有显式地渲染任何内容，Rails将自动查找控制器视图路径中的`action_name.html.erb`模板并进行渲染。因此，在这种情况下，Rails将渲染`app/views/books/index.html.erb`文件。

如果我们想在视图中显示所有书籍的属性，我们可以使用以下ERB模板：

```html+erb
<h1>Listing Books</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Show", book %></td>
        <td><%= link_to "Edit", edit_book_path(book) %></td>
        <td><%= link_to "Destroy", book, data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "New book", new_book_path %>
```

注意：实际的渲染是由模块[`ActionView::Template::Handlers`](https://api.rubyonrails.org/classes/ActionView/Template/Handlers.html)的嵌套类完成的。本指南不深入探讨该过程，但重要的是要知道您视图上的文件扩展名控制了模板处理程序的选择。

### 使用`render`

在大多数情况下，控制器的[`render`][controller.render]方法会为浏览器渲染您的应用程序的内容提供重要支持。有多种方法可以自定义`render`的行为。您可以渲染Rails模板的默认视图，或特定的模板，或文件，或内联代码，或根本不渲染。您可以渲染文本、JSON或XML。您还可以指定渲染响应的内容类型或HTTP状态。

提示：如果您想在不需要在浏览器中检查的情况下查看`render`调用的确切结果，可以调用`render_to_string`。此方法与`render`完全相同，但它返回一个字符串，而不是将响应发送回浏览器。
#### 渲染动作的视图

如果你想要在同一个控制器中渲染对应于不同模板的视图，你可以使用`render`和视图的名称：

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

如果`update`调用失败，调用该控制器中的`update`动作将渲染属于同一个控制器的`edit.html.erb`模板。

如果你愿意，你可以使用符号而不是字符串来指定要渲染的动作：

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit, status: :unprocessable_entity
  end
end
```

#### 从另一个控制器渲染动作的模板

如果你想要从包含动作代码的完全不同的控制器中渲染模板，你也可以使用`render`，它接受要渲染的模板的完整路径（相对于`app/views`）。例如，如果你在`app/controllers/admin`中运行`AdminProductsController`中的代码，你可以通过以下方式将动作的结果渲染到`app/views/products`中的模板：

```ruby
render "products/show"
```

Rails通过字符串中的斜杠字符知道该视图属于不同的控制器。如果你想明确指定，你可以使用`:template`选项（在Rails 2.2及更早版本中是必需的）：

```ruby
render template: "products/show"
```

#### 总结

上述两种渲染方式（渲染同一控制器中另一个动作的模板，以及渲染不同控制器中另一个动作的模板）实际上是相同操作的变体。

事实上，在`BooksController`类中，在我们希望在图书更新不成功时渲染编辑模板的更新动作中，以下所有的渲染调用都将渲染`views/books`目录中的`edit.html.erb`模板：

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

你使用哪种方式实际上是一种风格和约定的问题，但经验法则是使用对你正在编写的代码有意义的最简单的方式。

#### 使用`render`和`:inline`

如果你愿意在方法调用中使用`:inline`选项来提供ERB，`render`方法可以完全不使用视图。这是完全有效的：

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

警告：很少有好的理由使用这个选项。将ERB混合到你的控制器中会破坏Rails的MVC定位，并且会使其他开发人员更难以理解你的项目的逻辑。请使用单独的erb视图。

默认情况下，内联渲染使用ERB。你可以使用`:type`选项强制使用Builder：

```ruby
render inline: "xml.p {'可怕的编码实践！'}", type: :builder
```

#### 渲染文本

你可以使用`render`的`:plain`选项将纯文本（没有任何标记）发送回浏览器：

```ruby
render plain: "OK"
```

提示：渲染纯文本最有用的场景是响应期望不是正确HTML的Ajax或Web服务请求。

注意：默认情况下，如果使用`:plain`选项，文本将不使用当前布局进行渲染。如果你希望Rails将文本放入当前布局中，你需要添加`layout: true`选项，并为布局文件使用`.text.erb`扩展名。

#### 渲染HTML

你可以使用`render`的`:html`选项将HTML字符串发送回浏览器：

```ruby
render html: helpers.tag.strong('Not Found')
```

提示：当你渲染一个小片段的HTML代码时，这是很有用的。然而，如果标记是复杂的，你可能希望将其移动到一个模板文件中。

注意：使用`html:`选项时，如果字符串没有与`html_safe`兼容的API组合而成，HTML实体将被转义。

#### 渲染JSON

JSON是许多Ajax库使用的JavaScript数据格式。Rails内置支持将对象转换为JSON并将该JSON渲染回浏览器：

```ruby
render json: @product
```

提示：你不需要在要渲染的对象上调用`to_json`。如果使用`:json`选项，`render`将自动为你调用`to_json`。
#### 渲染XML

Rails还内置了将对象转换为XML并将该XML渲染回调用方的支持：

```ruby
render xml: @product
```

提示：您不需要在要渲染的对象上调用`to_xml`。如果使用`:xml`选项，`render`将自动为您调用`to_xml`。

#### 渲染原生JavaScript

Rails可以渲染原生JavaScript：

```ruby
render js: "alert('Hello Rails');"
```

这将使用`text/javascript`的MIME类型将提供的字符串发送到浏览器。

#### 渲染原始内容

您可以使用`render`的`:body`选项将原始内容发送回浏览器，而无需设置任何内容类型：

```ruby
render body: "raw"
```

提示：仅在您不关心响应的内容类型时才应使用此选项。大多数情况下，使用`:plain`或`:html`可能更合适。

注意：除非被覆盖，否则从此渲染选项返回的响应将是`text/plain`，因为这是Action Dispatch响应的默认内容类型。

#### 渲染原始文件

Rails可以从绝对路径渲染原始文件。这对于有条件地渲染静态文件（如错误页面）非常有用。

```ruby
render file: "#{Rails.root}/public/404.html", layout: false
```

这将渲染原始文件（不支持ERB或其他处理程序）。默认情况下，它在当前布局中呈现。

警告：在与用户输入组合使用`：file`选项会导致安全问题，因为攻击者可以使用此操作访问文件系统中的安全敏感文件。

提示：如果不需要布局，`send_file`通常是更快更好的选择。

#### 渲染对象

Rails可以渲染响应`：render_in`的对象。

```ruby
render MyRenderable.new
```

这将在提供的对象上使用当前视图上下文调用`render_in`。

您还可以使用`render`的`:renderable`选项提供对象：

```ruby
render renderable: MyRenderable.new
```

#### `render`的选项

对[`render`][controller.render]方法的调用通常接受六个选项：

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`
* `:variants`

##### `:content_type`选项

默认情况下，Rails将使用MIME内容类型`text/html`（如果使用`:json`选项，则为`application/json`，如果使用`:xml`选项，则为`application/xml`）提供渲染操作的结果。有时您可能希望更改此设置，可以通过设置`:content_type`选项来实现：

```ruby
render template: "feed", content_type: "application/rss"
```

##### `:layout`选项

对于大多数`render`选项，渲染的内容将作为当前布局的一部分显示。您将在本指南后面学习有关布局及其使用方法的更多信息。

您可以使用`:layout`选项告诉Rails使用特定文件作为当前操作的布局：

```ruby
render layout: "special_layout"
```

您还可以告诉Rails根本不使用布局进行渲染：

```ruby
render layout: false
```

##### `:location`选项

您可以使用`:location`选项设置HTTP `Location`头：

```ruby
render xml: photo, location: photo_url(photo)
```

##### `:status`选项

Rails将自动生成具有正确HTTP状态代码的响应（在大多数情况下，这是`200 OK`）。您可以使用`:status`选项更改此设置：

```ruby
render status: 500
render status: :forbidden
```

Rails可以理解数字状态代码和下面显示的相应符号。

| 响应类别           | HTTP状态代码 | 符号                             |
| ------------------- | ---------------- | -------------------------------- |
| **信息**   | 100              | :continue                        |
|                     | 101              | :switching_protocols             |
|                     | 102              | :processing                      |
| **成功**         | 200              | :ok                              |
|                     | 201              | :created                         |
|                     | 202              | :accepted                        |
|                     | 203              | :non_authoritative_information   |
|                     | 204              | :no_content                      |
|                     | 205              | :reset_content                   |
|                     | 206              | :partial_content                 |
|                     | 207              | :multi_status                    |
|                     | 208              | :already_reported                |
|                     | 226              | :im_used                         |
| **重定向**     | 300              | :multiple_choices                |
|                     | 301              | :moved_permanently               |
|                     | 302              | :found                           |
|                     | 303              | :see_other                       |
|                     | 304              | :not_modified                    |
|                     | 305              | :use_proxy                       |
|                     | 307              | :temporary_redirect              |
|                     | 308              | :permanent_redirect              |
| **客户端错误**    | 400              | :bad_request                     |
|                     | 401              | :unauthorized                    |
|                     | 402              | :payment_required                |
|                     | 403              | :forbidden                       |
|                     | 404              | :not_found                       |
|                     | 405              | :method_not_allowed              |
|                     | 406              | :not_acceptable                  |
|                     | 407              | :proxy_authentication_required   |
|                     | 408              | :request_timeout                 |
|                     | 409              | :conflict                        |
|                     | 410              | :gone                            |
|                     | 411              | :length_required                 |
|                     | 412              | :precondition_failed             |
|                     | 413              | :payload_too_large               |
|                     | 414              | :uri_too_long                    |
|                     | 415              | :unsupported_media_type          |
|                     | 416              | :range_not_satisfiable           |
|                     | 417              | :expectation_failed              |
|                     | 421              | :misdirected_request             |
|                     | 422              | :unprocessable_entity            |
|                     | 423              | :locked                          |
|                     | 424              | :failed_dependency               |
|                     | 426              | :upgrade_required                |
|                     | 428              | :precondition_required           |
|                     | 429              | :too_many_requests               |
|                     | 431              | :request_header_fields_too_large |
|                     | 451              | :unavailable_for_legal_reasons   |
| **服务器错误**    | 500              | :internal_server_error           |
|                     | 501              | :not_implemented                 |
|                     | 502              | :bad_gateway                     |
|                     | 503              | :service_unavailable             |
|                     | 504              | :gateway_timeout                 |
|                     | 505              | :http_version_not_supported      |
|                     | 506              | :variant_also_negotiates         |
|                     | 507              | :insufficient_storage            |
|                     | 508              | :loop_detected                   |
|                     | 510              | :not_extended                    |
|                     | 511              | :network_authentication_required |
注意：如果尝试渲染非内容状态码（100-199、204、205或304）的内容，它将从响应中删除。

##### `:formats`选项

Rails使用请求中指定的格式（默认为`:html`）。您可以通过传递符号或数组的`:formats`选项来更改这个格式：

```ruby
render formats: :xml
render formats: [:json, :xml]
```

如果不存在指定格式的模板，则会引发`ActionView::MissingTemplate`错误。

##### `:variants`选项

这告诉Rails查找相同格式的模板变体。您可以通过传递符号或数组的`:variants`选项来指定一系列变体。

以下是一个使用示例。

```ruby
# 在HomeController#index中调用
render variants: [:mobile, :desktop]
```

使用这组变体，Rails将查找以下一组模板，并使用存在的第一个模板。

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

如果不存在指定格式的模板，则会引发`ActionView::MissingTemplate`错误。

您还可以在控制器操作中的请求对象上设置变体，而不是在渲染调用中设置它。

```ruby
def index
  request.variant = determine_variant
end

private
  def determine_variant
    variant = nil
    # 一些确定要使用的变体的代码
    variant = :mobile if session[:use_mobile]

    variant
  end
```

#### 查找布局

要查找当前布局，Rails首先会查找与控制器相同基本名称的文件，位于`app/views/layouts`中。例如，从`PhotosController`类中呈现操作将使用`app/views/layouts/photos.html.erb`（或`app/views/layouts/photos.builder`）。如果没有这样的特定于控制器的布局，Rails将使用`app/views/layouts/application.html.erb`或`app/views/layouts/application.builder`。如果没有`.erb`布局，如果存在`.builder`布局，Rails将使用`.builder`布局。Rails还提供了几种更精确地为单个控制器和操作分配特定布局的方法。

##### 为控制器指定布局

您可以通过使用[`layout`][]声明在控制器中覆盖默认布局约定。例如：

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

使用此声明，由`ProductsController`呈现的所有视图将使用`app/views/layouts/inventory.html.erb`作为它们的布局。

要为整个应用程序分配特定的布局，请在`ApplicationController`类中使用`layout`声明：

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

使用此声明，整个应用程序中的所有视图将使用`app/views/layouts/main.html.erb`作为它们的布局。


##### 在运行时选择布局

您可以使用符号来推迟布局的选择，直到处理请求：

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end
end
```

现在，如果当前用户是特殊用户，在查看产品时将获得特殊布局。

您甚至可以使用内联方法，例如Proc，来确定布局。例如，如果传递了一个Proc对象，给定Proc的块将获得`controller`实例，因此可以根据当前请求确定布局：

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### 条件布局

在控制器级别指定的布局支持`：only`和`：except`选项。这些选项接受方法名或方法名数组，与控制器内的方法名相对应：

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

使用此声明，`product`布局将用于除`rss`和`index`方法之外的所有内容。

##### 布局继承

布局声明在层次结构中向下级联，并且更具体的布局声明始终会覆盖更一般的布局声明。例如：

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `articles_controller.rb`

    ```ruby
    class ArticlesController < ApplicationController
    end
    ```

* `special_articles_controller.rb`

    ```ruby
    class SpecialArticlesController < ArticlesController
      layout "special"
    end
    ```

* `old_articles_controller.rb`

    ```ruby
    class OldArticlesController < SpecialArticlesController
      layout false

      def show
        @article = Article.find(params[:id])
      end

      def index
        @old_articles = Article.older
        render layout: "old"
      end
      # ...
    end
    ```

在这个应用程序中：

* 通常情况下，视图将在`main`布局中呈现
* `ArticlesController#index`将使用`main`布局
* `SpecialArticlesController#index`将使用`special`布局
* `OldArticlesController#show`将不使用任何布局
* `OldArticlesController#index`将使用`old`布局
##### 模板继承

与布局继承逻辑类似，如果在常规路径中找不到模板或部分，则控制器将在其继承链中查找要渲染的模板或部分。例如：

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
end
```

```ruby
# app/controllers/admin_controller.rb
class AdminController < ApplicationController
end
```

```ruby
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < AdminController
  def index
  end
end
```

`admin/products#index` 动作的查找顺序将是：

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

这使得 `app/views/application/` 成为共享部分的理想位置，可以在 ERB 中这样渲染：

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
这个列表中没有任何项目 <em>尚未</em>。
```

#### 避免双重渲染错误

迟早，大多数 Rails 开发人员都会看到错误消息 "Can only render or redirect once per action"。虽然这很烦人，但相对容易修复。通常，这是由于对 `render` 工作方式的基本误解而发生的。

例如，下面的代码将触发此错误：

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

如果 `@book.special?` 的计算结果为 `true`，Rails 将开始渲染过程，将 `@book` 变量转储到 `special_show` 视图中。但这不会阻止 `show` 动作中的其余代码运行，当 Rails 到达动作的末尾时，它将开始渲染 `regular_show` 视图 - 并抛出错误。解决方法很简单：确保在单个代码路径中只有一个对 `render` 或 `redirect` 的调用。`return` 可以帮助解决问题。下面是修补后的方法版本：

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
    return
  end
  render action: "regular_show"
end
```

请注意，由 ActionController 隐式执行的渲染会检测到是否调用了 `render`，因此以下代码将不会出现错误：

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

这将使用 `special_show` 模板渲染一个 `special?` 设置的书籍，而其他书籍将使用默认的 `show` 模板进行渲染。

### 使用 `redirect_to`

处理返回 HTTP 请求的另一种方法是使用 [`redirect_to`][]。正如您所见，`render` 告诉 Rails 在构建响应时使用哪个视图（或其他资源）。`redirect_to` 方法完全不同：它告诉浏览器发送一个新的请求以获取不同的 URL。例如，您可以从代码中的任何位置重定向到应用程序中照片的索引：

```ruby
redirect_to photos_url
```

您可以使用 [`redirect_back`][] 将用户返回到他们刚刚访问的页面。此位置从 `HTTP_REFERER` 标头中获取，但浏览器不能保证设置该标头，因此您必须提供 `fallback_location` 以在此情况下使用。

```ruby
redirect_back(fallback_location: root_path)
```

注意：`redirect_to` 和 `redirect_back` 不会停止并立即从方法执行返回，而只是设置 HTTP 响应。在方法中它们之后发生的语句将被执行。如果需要，您可以通过显式的 `return` 或其他停止机制来停止。

#### 获取不同的重定向状态码

当您调用 `redirect_to` 时，Rails 使用 HTTP 状态码 302（临时重定向）。如果您想使用不同的状态码，例如 301（永久重定向），可以使用 `:status` 选项：

```ruby
redirect_to photos_path, status: 301
```

与 `render` 的 `:status` 选项一样，`redirect_to` 的 `:status` 选项接受数字和符号标头指示。

#### `render` 和 `redirect_to` 的区别

有时，经验不足的开发人员将 `redirect_to` 视为一种在 Rails 代码中从一个地方移动执行到另一个地方的 `goto` 命令。这是 _不正确_ 的。您的代码停止运行并等待浏览器的新请求。只是您已经告诉浏览器它应该下一个发出什么请求，通过发送回一个 HTTP 302 状态码。

考虑以下动作以查看差异：

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

以这种形式的代码，如果 `@book` 变量为 `nil`，可能会出现问题。请记住，`render :action` 不会在目标动作中运行任何代码，因此不会设置 `index` 视图可能需要的 `@books` 变量。修复此问题的一种方法是重定向而不是渲染：
```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

使用这段代码，浏览器将发起一个新的请求来获取索引页面，`index`方法中的代码将运行，一切都会很好。

这段代码的唯一缺点是它需要往返到浏览器：浏览器请求了带有`/books/1`的show动作，控制器发现没有书籍，所以控制器向浏览器发送了一个302重定向响应，告诉它去`/books/`，浏览器遵循并发送一个新的请求回控制器，现在请求`index`动作，控制器然后获取数据库中的所有书籍并渲染索引模板，将其发送回浏览器，然后在屏幕上显示出来。

虽然在一个小型应用程序中，这种额外的延迟可能不是一个问题，但如果响应时间是一个问题，这是需要考虑的。我们可以通过一个假设的例子来演示处理这个问题的一种方式：

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "未找到您的书籍"
    render "index"
  end
end
```

这将检测到没有指定ID的书籍，使用模型中的所有书籍填充`@books`实例变量，然后直接渲染`index.html.erb`模板，将其返回给浏览器，并使用闪现警告消息告诉用户发生了什么。

### 使用`head`构建仅包含头部的响应

[`head`][]方法可以用于向浏览器发送仅包含头部的响应。`head`方法接受一个表示HTTP状态码的数字或符号（参见[参考表](#the-status-option)），选项参数被解释为一个包含头部名称和值的哈希。例如，您可以只返回一个错误头部：

```ruby
head :bad_request
```

这将产生以下头部：

```http
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

或者您可以使用其他HTTP头部传达其他信息：

```ruby
head :created, location: photo_path(@photo)
```

这将产生以下头部：

```http
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

布局结构
-------------------

当Rails将视图渲染为响应时，它会将视图与当前布局结合，使用在本指南前面介绍的查找当前布局的规则。在布局中，您可以使用三种工具来组合不同的输出部分以形成整体响应：

* 资源标签
* `yield`和[`content_for`][]
* 局部视图


### 资源标签助手

资源标签助手提供了用于生成HTML的方法，将视图链接到源、JavaScript、样式表、图像、视频和音频。Rails提供了六个资源标签助手：

* [`auto_discovery_link_tag`][]
* [`javascript_include_tag`][]
* [`stylesheet_link_tag`][]
* [`image_tag`][]
* [`video_tag`][]
* [`audio_tag`][]

您可以在布局或其他视图中使用这些标签，尽管`auto_discovery_link_tag`、`javascript_include_tag`和`stylesheet_link_tag`最常用于布局的`<head>`部分。

警告：资源标签助手不会验证指定位置的资源是否存在；它们只是假设您知道自己在做什么并生成链接。


#### 使用`auto_discovery_link_tag`链接到源

[`auto_discovery_link_tag`][]助手构建的HTML可以让大多数浏览器和订阅阅读器检测到RSS、Atom或JSON源的存在。它接受链接类型（`:rss`、`:atom`或`:json`）、传递给url_for的选项哈希和标签的选项哈希：

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS 源"}) %>
```

`auto_discovery_link_tag`有三个标签选项可用：

* `:rel`指定链接中的`rel`值。默认值为"alternate"。
* `:type`指定显式的MIME类型。Rails会自动生成适当的MIME类型。
* `:title`指定链接的标题。默认值为大写的`:type`值，例如"ATOM"或"RSS"。
#### 使用 `javascript_include_tag` 链接到 JavaScript 文件

[`javascript_include_tag`][] 助手为每个提供的源文件返回一个 HTML `script` 标签。

如果你正在使用启用了[Asset Pipeline](asset_pipeline.html)的 Rails，这个助手将生成一个链接到 `/assets/javascripts/` 而不是之前版本的 Rails 中使用的 `public/javascripts` 的链接。这个链接然后由 asset pipeline 提供。

Rails 应用程序或 Rails 引擎中的 JavaScript 文件可以放在三个位置之一：`app/assets`、`lib/assets` 或 `vendor/assets`。这些位置在[Asset Pipeline 指南的 Asset Organization 部分](asset_pipeline.html#asset-organization)中有详细解释。

你可以指定相对于文档根目录的完整路径，或者一个 URL。例如，要链接到一个位于 `app/assets`、`lib/assets` 或 `vendor/assets` 中的名为 `javascripts` 的目录中的 JavaScript 文件，你可以这样做：

```erb
<%= javascript_include_tag "main" %>
```

Rails 将输出一个类似于这样的 `script` 标签：

```html
<script src='/assets/main.js'></script>
```

对该资源的请求然后由 Sprockets gem 提供。

要同时包含多个文件，如 `app/assets/javascripts/main.js` 和 `app/assets/javascripts/columns.js`：

```erb
<%= javascript_include_tag "main", "columns" %>
```

要包含 `app/assets/javascripts/main.js` 和 `app/assets/javascripts/photos/columns.js`：

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

要包含 `http://example.com/main.js`：

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### 使用 `stylesheet_link_tag` 链接到 CSS 文件

[`stylesheet_link_tag`][] 助手为每个提供的源文件返回一个 HTML `<link>` 标签。

如果你正在使用启用了 "Asset Pipeline" 的 Rails，这个助手将生成一个链接到 `/assets/stylesheets/` 的链接。这个链接然后由 Sprockets gem 处理。样式表文件可以存储在 `app/assets`、`lib/assets` 或 `vendor/assets` 中。

你可以指定相对于文档根目录的完整路径，或者一个 URL。例如，要链接到一个位于 `app/assets`、`lib/assets` 或 `vendor/assets` 中的名为 `stylesheets` 的目录中的样式表文件，你可以这样做：

```erb
<%= stylesheet_link_tag "main" %>
```

要包含 `app/assets/stylesheets/main.css` 和 `app/assets/stylesheets/columns.css`：

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

要包含 `app/assets/stylesheets/main.css` 和 `app/assets/stylesheets/photos/columns.css`：

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

要包含 `http://example.com/main.css`：

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

默认情况下，`stylesheet_link_tag` 创建带有 `rel="stylesheet"` 的链接。你可以通过指定适当的选项 (`:rel`) 来覆盖这个默认值：

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### 使用 `image_tag` 链接到图像

[`image_tag`][] 助手根据指定的文件构建一个 HTML `<img />` 标签。默认情况下，文件从 `public/images` 加载。

警告：请注意，你必须指定图像的扩展名。

```erb
<%= image_tag "header.png" %>
```

如果你愿意，你可以提供图像的路径：

```erb
<%= image_tag "icons/delete.gif" %>
```

你可以提供一个包含额外 HTML 选项的哈希：

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

你可以为图像提供替代文本，如果用户在浏览器中关闭了图像，则会使用该替代文本。如果你没有明确指定 alt 文本，则默认为文件名，大写且没有扩展名。例如，这两个图像标签将返回相同的代码：

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

你还可以指定一个特殊的大小标签，格式为 "{width}x{height}"：

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

除了上述特殊标签之外，你还可以提供一个包含标准 HTML 选项的哈希，例如 `:class`、`:id` 或 `:name`：

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### 使用 `video_tag` 链接到视频

[`video_tag`][] 助手根据指定的文件构建一个 HTML5 `<video>` 标签。默认情况下，文件从 `public/videos` 加载。

```erb
<%= video_tag "movie.ogg" %>
```

生成

```erb
<video src="/videos/movie.ogg" />
```

和 `image_tag` 一样，你可以提供一个路径，可以是绝对路径，也可以是相对于 `public/videos` 目录的路径。此外，你可以像 `image_tag` 一样指定 `size: "#{width}x#{height}"` 选项。视频标签还可以使用最后指定的任何 HTML 选项（`id`、`class` 等）。

视频标签还通过 HTML 选项哈希支持所有 `<video>` HTML 选项，包括：

* `poster: "image_name.png"`，在视频开始播放之前提供一个图像。
* `autoplay: true`，在页面加载时开始播放视频。
* `loop: true`，视频播放到结束时循环播放。
* `controls: true`，提供浏览器提供的控件，供用户与视频交互。
* `autobuffer: true`，视频将在页面加载时预加载文件。
您还可以通过将视频数组传递给`video_tag`来指定要播放的多个视频：

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

这将生成：

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### 使用`audio_tag`链接到音频文件

[`audio_tag`][]助手构建一个HTML5 `<audio>`标签到指定的文件。默认情况下，文件从`public/audios`加载。

```erb
<%= audio_tag "music.mp3" %>
```

如果需要，您可以提供音频文件的路径：

```erb
<%= audio_tag "music/first_song.mp3" %>
```

您还可以提供其他选项的哈希，例如`：id`，`：class`等。

与`video_tag`类似，`audio_tag`具有特殊选项：

* `autoplay: true`，在页面加载时开始播放音频
* `controls: true`，提供浏览器提供的控件，供用户与音频交互。
* `autobuffer: true`，音频将在页面加载时为用户预加载文件。

### 理解`yield`

在布局的上下文中，`yield`标识应插入视图内容的部分。使用最简单的方法是只有一个`yield`，将正在渲染的视图的整个内容插入其中：

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

您还可以创建具有多个yield区域的布局：

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

视图的主体始终呈现为未命名的`yield`。要将内容呈现到命名的`yield`中，可以使用`content_for`方法。

### 使用`content_for`方法

[`content_for`][]方法允许您将内容插入到布局中命名的`yield`块中。例如，此视图将与刚才看到的布局一起工作：

```html+erb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

将此页面呈现到提供的布局的结果将是以下HTML：

```html+erb
<html>
  <head>
  <title>A simple page</title>
  </head>
  <body>
  <p>Hello, Rails!</p>
  </body>
</html>
```

当您的布局包含不同的区域（例如侧边栏和页脚），应该插入它们自己的内容块时，`content_for`方法非常有用。它还可用于将加载特定于页面的JavaScript或CSS文件的标签插入到通用布局的头部。

### 使用局部视图

局部模板 - 通常称为“局部视图” - 是将渲染过程分解为更可管理的块的另一种方法。使用局部视图，您可以将响应的特定部分的渲染代码移动到自己的文件中。

#### 命名局部视图

要将局部视图作为视图的一部分呈现，可以在视图中使用[`render`][view.render]方法：

```html+erb
<%= render "menu" %>
```

这将在正在呈现的视图中的该点呈现名为`_menu.html.erb`的文件。请注意前导下划线字符：局部视图以前导下划线命名，以区别于常规视图，即使在引用时不带下划线。即使从另一个文件夹中引入局部视图，这一点也是正确的：

```html+erb
<%= render "shared/menu" %>
```

该代码将从`app/views/shared/_menu.html.erb`中引入局部视图。


#### 使用局部视图简化视图

使用局部视图的一种方法是将它们视为子例程的等效物：一种将细节从视图中移出以便更容易理解正在发生的事情的方法。例如，您可能有一个如下所示的视图：

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

在这里，`_ad_banner.html.erb`和`_footer.html.erb`局部视图可以包含在应用程序中许多页面共享的内容。当您专注于特定页面时，您不需要看到这些部分的详细信息。

正如在本指南的前几节中所看到的，`yield`是一种非常强大的工具，可以清理布局。请记住，它是纯Ruby，因此几乎可以在任何地方使用它。例如，我们可以使用它来简化为几个相似资源定义表单布局：

* `users/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Name contains: <%= form.text_field :name_contains %>
      </p>
    <% end %>
    ```

* `roles/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Title contains: <%= form.text_field :title_contains %>
      </p>
    <% end %>
    ```
* `shared/_search_filters.html.erb`

    ```html+erb
    <%= form_with model: search do |form| %>
      <h1>搜索表单：</h1>
      <fieldset>
        <%= yield form %>
      </fieldset>
      <p>
        <%= form.submit "搜索" %>
      </p>
    <% end %>
    ```

提示：对于在应用程序的所有页面中共享的内容，您可以直接从布局中使用部分视图。

#### 部分视图布局

部分视图可以使用自己的布局文件，就像视图可以使用布局一样。例如，您可以像这样调用一个部分视图：

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

这将查找名为 `_link_area.html.erb` 的部分视图，并使用 `_graybar.html.erb` 布局文件进行渲染。请注意，部分视图的布局遵循与常规部分视图相同的下划线开头的命名规则，并且放置在与其所属的部分视图相同的文件夹中（而不是主 `layouts` 文件夹中）。

还要注意，当传递其他选项（如 `:layout`）时，需要显式指定 `:partial`。

#### 传递局部变量

您还可以将局部变量传递给部分视图，使其更加强大和灵活。例如，您可以使用此技术来减少新建和编辑页面之间的重复，同时仍保留一些不同的内容：

* `new.html.erb`

    ```html+erb
    <h1>新建区域</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>编辑区域</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```html+erb
    <%= form_with model: zone do |form| %>
      <p>
        <b>区域名称</b><br>
        <%= form.text_field :name %>
      </p>
      <p>
        <%= form.submit %>
      </p>
    <% end %>
    ```

尽管相同的部分视图将在两个视图中呈现，但 Action View 的 submit 助手将在新建操作中返回 "创建区域"，在编辑操作中返回 "更新区域"。

要在特定情况下将局部变量传递给部分视图，请使用 `local_assigns`。

* `index.html.erb`

    ```erb
    <%= render user.articles %>
    ```

* `show.html.erb`

    ```erb
    <%= render article, full: true %>
    ```

* `_article.html.erb`

    ```erb
    <h2><%= article.title %></h2>

    <% if local_assigns[:full] %>
      <%= simple_format article.body %>
    <% else %>
      <%= truncate article.body %>
    <% end %>
    ```

这样可以在不需要声明所有局部变量的情况下使用部分视图。

每个部分视图还具有与部分视图同名的局部变量（去掉前导下划线）。您可以通过 `:object` 选项将对象传递给此局部变量：

```erb
<%= render partial: "customer", object: @new_customer %>
```

在 `customer` 部分视图中，`customer` 变量将引用父视图中的 `@new_customer`。

如果您有一个要渲染到部分视图中的模型实例，可以使用简写语法：

```erb
<%= render @customer %>
```

假设 `@customer` 实例变量包含 `Customer` 模型的一个实例，这将使用 `_customer.html.erb` 进行渲染，并将局部变量 `customer` 传递到部分视图中，该局部变量将引用父视图中的 `@customer` 实例变量。

#### 渲染集合

部分视图在渲染集合时非常有用。当通过 `:collection` 选项将集合传递给部分视图时，部分视图将根据集合中的每个成员插入一次：

* `index.html.erb`

    ```html+erb
    <h1>产品</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>产品名称： <%= product.name %></p>
    ```

当使用复数形式的集合调用部分视图时，部分视图的各个实例可以通过与部分视图同名的变量访问正在渲染的集合成员。在这种情况下，部分视图是 `_product`，在 `_product` 部分视图中，您可以引用 `product` 来获取正在渲染的实例。

还有一种简写方式。假设 `@products` 是一个 `Product` 实例的集合，您可以在 `index.html.erb` 中简单地编写以下内容以产生相同的结果：

```html+erb
<h1>产品</h1>
<%= render @products %>
```

Rails通过查看集合中的模型名称来确定要使用的部分视图的名称。实际上，您甚至可以创建一个异构集合，并以这种方式进行渲染，Rails将为集合的每个成员选择适当的部分视图：

* `index.html.erb`

    ```html+erb
    <h1>联系人</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    ```

* `customers/_customer.html.erb`

    ```html+erb
    <p>客户： <%= customer.name %></p>
    ```

* `employees/_employee.html.erb`

    ```html+erb
    <p>员工： <%= employee.name %></p>
    ```

在这种情况下，Rails将根据集合的每个成员选择适当的 customer 或 employee 部分视图。
如果集合为空，`render` 将返回 nil，因此提供替代内容应该相当简单。

```html+erb
<h1>产品</h1>
<%= render(@products) || "没有可用的产品。" %>
```

#### 本地变量

要在局部模板中使用自定义的本地变量名称，请在调用局部模板时指定 `:as` 选项：

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

通过这个更改，您可以在局部模板中将 `@products` 集合的实例作为 `item` 本地变量访问。

您还可以通过 `locals: {}` 选项将任意本地变量传递给要渲染的任何局部模板：

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "产品页面"} %>
```

在这种情况下，局部模板将可以访问一个名为 `title` 的本地变量，其值为 "产品页面"。

#### 计数变量

Rails 还在由集合调用的局部模板中提供了一个计数变量。该变量的名称是局部模板的标题后跟 `_counter`。例如，当渲染集合 `@products` 时，局部模板 `_product.html.erb` 可以访问变量 `product_counter`。该变量索引了局部模板在封闭视图中渲染的次数，从第一次渲染开始，初始值为 `0`。

```erb
# index.html.erb
<%= render partial: "product", collection: @products %>
```

```erb
# _product.html.erb
<%= product_counter %> # 第一个产品为 0，第二个产品为 1...
```

当使用 `as:` 选项更改局部模板名称时，此方法也适用。因此，如果您使用了 `as: :item`，计数变量将为 `item_counter`。

#### 间隔模板

您还可以使用 `:spacer_template` 选项在主要局部模板的实例之间指定要渲染的第二个局部模板：

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails 将在每对 `_product` 局部模板之间渲染 `_product_ruler` 局部模板（不传递任何数据给它）。

#### 集合局部模板布局

在渲染集合时，还可以使用 `:layout` 选项：

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

布局将与集合中的每个项目的局部模板一起渲染。当前对象和 object_counter 变量也将在布局中可用，就像它们在局部模板中一样。

### 使用嵌套布局

您可能会发现您的应用程序需要一个与常规应用程序布局略有不同的布局，以支持一个特定的控制器。您可以通过使用嵌套布局（有时称为子模板）来实现这一点，而不是重复主布局并进行编辑。下面是一个示例：

假设您有以下 `ApplicationController` 布局：

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "页面标题" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">这里是顶部菜单项</div>
      <div id="menu">这里是菜单项</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

在由 `NewsController` 生成的页面上，您想要隐藏顶部菜单并添加一个右侧菜单：

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">这里是右侧菜单项</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

就是这样。新闻视图将使用新的布局，隐藏顶部菜单并在 "content" div 中添加一个新的右侧菜单。

使用这种技术可以使用不同的子模板方案获得类似的结果。请注意，嵌套级别没有限制。可以使用 `ActionView::render` 方法通过 `render template: 'layouts/news'` 在 News 布局上构建一个新布局。如果您确定不会对 `News` 布局进行子模板化，可以将 `content_for?(:news_content) ? yield(:news_content) : yield` 替换为 `yield`。
[controller.render]: https://api.rubyonrails.org/classes/ActionController/Rendering.html#method-i-render
[`redirect_to`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to
[`head`]: https://api.rubyonrails.org/classes/ActionController/Head.html#method-i-head
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`redirect_back`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_back
[`content_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for
[`auto_discovery_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-auto_discovery_link_tag
[`javascript_include_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-javascript_include_tag
[`stylesheet_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-stylesheet_link_tag
[`image_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag
[`video_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-video_tag
[`audio_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-audio_tag
[view.render]: https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render
