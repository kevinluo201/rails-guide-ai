**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f6b613040c7aed4c76b6648b6fd963cf
Action View 概述
====================

阅读本指南后，您将了解以下内容：

* Action View 是什么以及如何在 Rails 中使用它。
* 如何最佳地使用模板、局部视图和布局。
* 如何使用本地化视图。

--------------------------------------------------------------------------------

什么是 Action View？
--------------------

在 Rails 中，Web 请求由 [Action Controller](action_controller_overview.html) 和 Action View 处理。通常，Action Controller 负责与数据库通信并在必要时执行 CRUD 操作。然后，Action View 负责编译响应。

Action View 模板使用嵌入的 Ruby 代码和 HTML 标签编写。为了避免在模板中添加样板代码，几个辅助类提供了表单、日期和字符串的常见行为。随着应用程序的发展，添加新的辅助类也很容易。

注意：Action View 的某些功能与 Active Record 相关联，但这并不意味着 Action View 依赖于 Active Record。Action View 是一个独立的包，可以与任何类型的 Ruby 库一起使用。

使用 Action View 和 Rails
----------------------------

对于每个控制器，在 `app/views` 目录中都有一个相关联的目录，其中包含构成与该控制器关联的视图的模板文件。这些文件用于显示每个控制器操作所生成的视图。

让我们来看看在使用脚手架生成器创建新资源时，Rails 默认会做什么：

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

Rails 中有一个视图的命名约定。通常，视图与关联的控制器操作共享名称，如上所示。
例如，`articles_controller.rb` 的 index 控制器操作将使用 `app/views/articles` 目录中的 `index.html.erb` 视图文件。
返回给客户端的完整 HTML 是由此 ERB 文件、包装它的布局模板以及视图可能引用的所有局部视图组成的。在本指南中，您将找到关于这三个组件的更详细的文档。

如前所述，最终的 HTML 输出是由三个 Rails 元素组成的：`模板`、`局部视图` 和 `布局`。
以下是对它们的简要概述。

模板
---------

Action View 模板可以以多种方式编写。如果模板文件具有 `.erb` 扩展名，则使用 ERB（嵌入式 Ruby）和 HTML 的混合。如果模板文件具有 `.builder` 扩展名，则使用 `Builder::XmlMarkup` 库。

Rails 支持多个模板系统，并使用文件扩展名来区分它们。例如，使用 ERB 模板系统的 HTML 文件将具有 `.html.erb` 作为文件扩展名。

### ERB

在 ERB 模板中，可以使用 `<% %>` 和 `<%= %>` 标签包含 Ruby 代码。`<% %>` 标签用于执行不返回任何内容的 Ruby 代码，例如条件、循环或块，而 `<%= %>` 标签用于输出。

考虑以下名称循环：

```html+erb
<h1>所有人的姓名</h1>
<% @people.each do |person| %>
  姓名： <%= person.name %><br>
<% end %>
```

该循环使用常规嵌入标签（`<% %>`）设置，并使用输出嵌入标签（`<%= %>`）插入名称。请注意，这不仅仅是一种用法建议：常规输出函数（如 `print` 和 `puts`）不会在 ERB 模板中呈现到视图中。因此，以下写法是错误的：

```html+erb
<%# 错误 %>
你好，<% puts "Frodo" %>
```

要去除前导和尾随空格，可以在 `<%` 和 `%>` 之间交替使用 `<%-` `-%>`。

### Builder

Builder 模板是 ERB 的一种更加程序化的替代方案。它们特别适用于生成 XML 内容。带有 `.builder` 扩展名的模板会自动提供一个名为 `xml` 的 XmlMarkup 对象。

以下是一些基本示例：

```ruby
xml.em("强调")
xml.em { xml.b("强调和加粗") }
xml.a("链接", "href" => "https://rubyonrails.org")
xml.target("name" => "编译", "option" => "快速")
```

它将生成以下内容：

```html
<em>强调</em>
<em><b>强调和加粗</b></em>
<a href="https://rubyonrails.org">链接</a>
<target option="快速" name="编译" />
```

带有块的任何方法都将被视为带有嵌套标记的 XML 标记。例如，以下内容：
```ruby
xml.div {
  xml.h1(@person.name)
  xml.p(@person.bio)
}
```

将会生成类似以下的内容：

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>A product of Danish Design during the Winter of '79...</p>
</div>
```

下面是一个在Basecamp上实际使用的完整RSS示例：

```ruby
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@feed_title)
    xml.link(@url)
    xml.description "Basecamp: Recent items"
    xml.language "en-us"
    xml.ttl "40"

    for item in @recent_items
      xml.item do
        xml.title(item_title(item))
        xml.description(item_description(item)) if item_description(item)
        xml.pubDate(item_pubDate(item))
        xml.guid(@person.firm.account.url + @recent_items.url(item))
        xml.link(@person.firm.account.url + @recent_items.url(item))
        xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
      end
    end
  end
end
```

### Jbuilder

[Jbuilder](https://github.com/rails/jbuilder)是由Rails团队维护并包含在默认的Rails `Gemfile`中的一个gem。它类似于Builder，但用于生成JSON，而不是XML。

如果你没有安装它，可以将以下内容添加到你的`Gemfile`中：

```ruby
gem 'jbuilder'
```

一个名为`json`的Jbuilder对象会自动在具有`.jbuilder`扩展名的模板中提供。

以下是一个基本示例：

```ruby
json.name("Alex")
json.email("alex@example.com")
```

将会生成：

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

请参阅[Jbuilder文档](https://github.com/rails/jbuilder#jbuilder)了解更多示例和信息。

### 模板缓存

默认情况下，Rails会将每个模板编译为一个方法来进行渲染。在开发环境中，当你修改一个模板时，Rails会检查文件的修改时间并重新编译它。

局部模板
--------

局部模板 - 通常称为"局部" - 是将渲染过程分解为更可管理的块的另一种方法。使用局部模板，您可以从模板中提取代码片段到单独的文件中，并在整个模板中重复使用它们。

### 渲染局部模板

要在视图的一部分中渲染局部模板，可以在视图中使用`render`方法：

```erb
<%= render "menu" %>
```

这将在正在渲染的视图中的该点渲染一个名为`_menu.html.erb`的文件。请注意前面的下划线字符：局部模板以前导下划线命名，以区别于常规视图，即使在引用它们时不使用下划线。即使从另一个文件夹中引入局部模板，这个规则也适用：

```erb
<%= render "shared/menu" %>
```

这段代码将从`app/views/shared/_menu.html.erb`中引入局部模板。

### 使用局部模板简化视图

使用局部模板的一种方式是将它们视为子程序的等效物；一种将细节从视图中移出的方法，以便更容易理解正在发生的事情。例如，您可能有一个如下所示的视图：

```html+erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "shared/footer" %>
```

在这里，`_ad_banner.html.erb`和`_footer.html.erb`局部模板可以包含在应用程序中许多页面之间共享的内容。当您专注于特定页面时，您不需要看到这些部分的细节。

### `render`不带`partial`和`locals`选项

在上面的示例中，`render`接受了2个选项：`partial`和`locals`。但是，如果这些是您想要传递的唯一选项，您可以跳过使用这些选项。例如，不使用：

```erb
<%= render partial: "product", locals: { product: @product } %>
```

您也可以这样做：

```erb
<%= render "product", product: @product %>
```

### `as`和`object`选项

默认情况下，`ActionView::Partials::PartialRenderer`将其对象放在与模板同名的局部变量中。因此，给定：

```erb
<%= render partial: "product" %>
```

在`_product`局部模板中，我们将在局部变量`product`中得到`@product`，就好像我们写了：

```erb
<%= render partial: "product", locals: { product: @product } %>
```

`object`选项可以用于直接指定要渲染到局部模板中的对象；当模板的对象在其他地方时（例如在不同的实例变量或局部变量中）很有用。

例如，不使用：

```erb
<%= render partial: "product", locals: { product: @item } %>
```

我们可以这样做：

```erb
<%= render partial: "product", object: @item %>
```

使用`as`选项，我们可以为该局部变量指定一个不同的名称。例如，如果我们希望它是`item`而不是`product`，我们可以这样做：

```erb
<%= render partial: "product", object: @item, as: "item" %>
```

这相当于
```erb
<%= render partial: "product", locals: { item: @item } %>
```

### 渲染集合

通常，模板需要遍历一个集合，并为集合中的每个元素渲染一个子模板。这个模式已经被实现为一个方法，它接受一个数组，并为数组中的每个元素渲染一个局部模板。

所以，渲染所有产品的例子：

```erb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

可以简化为一行代码：

```erb
<%= render partial: "product", collection: @products %>
```

当使用集合调用局部模板时，局部模板的各个实例可以通过一个以局部模板命名的变量访问正在渲染的集合成员。在这个例子中，局部模板是 `_product`，在其中，您可以引用 `product` 来获取正在渲染的集合成员。

您可以使用一种简写语法来渲染集合。假设 `@products` 是一个 `Product` 实例的集合，您可以简单地写下以下代码以获得相同的结果：

```erb
<%= render @products %>
```

Rails 通过查看集合中的模型名称来确定要使用的局部模板的名称，在这种情况下是 `Product`。实际上，您甚至可以使用这种简写来渲染由不同模型的实例组成的集合，Rails 将为集合的每个成员选择适当的局部模板。

### 间隔模板

您还可以通过使用 `:spacer_template` 选项来指定在主要局部模板的实例之间渲染第二个局部模板：

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails 将在每对 `_product` 局部模板之间渲染 `_product_ruler` 局部模板（不传递任何数据给它）。

### 严格的局部变量

默认情况下，模板将接受任何 `locals` 作为关键字参数。要定义模板接受的 `locals`，请添加一个 `locals` 魔术注释：

```erb
<%# locals: (message:) -%>
<%= message %>
```

也可以提供默认值：

```erb
<%# locals: (message: "Hello, world!") -%>
<%= message %>
```

或者可以完全禁用 `locals`：

```erb
<%# locals: () %>
```

布局
-------

布局可以用于在 Rails 控制器操作的结果周围呈现一个常见的视图模板。通常，Rails 应用程序将有几个布局，页面将在其中呈现。例如，一个站点可能为已登录用户和市场或销售站点分别有一个布局。已登录用户布局可能包括顶级导航，应该在许多控制器操作中存在。SaaS 应用程序的销售布局可能包括诸如“定价”和“联系我们”页面的顶级导航。您期望每个布局都有不同的外观和感觉。您可以在[布局和渲染](https://guides.rubyonrails.org/layouts_and_rendering.html)指南中详细了解布局。

### 局部布局

局部可以应用自己的布局。这些布局与应用于控制器操作的布局不同，但它们的工作方式类似。

假设我们在页面上显示一篇文章，应该将其包装在一个 `div` 中以进行显示。首先，我们将创建一个新的 `Article`：

```ruby
Article.create(body: 'Partial Layouts are cool!')
```

在 `show` 模板中，我们将渲染 `_article` 局部模板并应用 `box` 布局：

**articles/show.html.erb**

```erb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

`box` 布局只是将 `_article` 局部模板包装在一个 `div` 中：

**articles/_box.html.erb**

```html+erb
<div class='box'>
  <%= yield %>
</div>
```

请注意，局部布局可以访问传递给 `render` 调用的局部变量 `article`。但是，与应用程序范围的布局不同，局部布局仍然具有下划线前缀。

您还可以在局部布局中呈现代码块，而不是调用 `yield`。例如，如果我们没有 `_article` 局部模板，我们可以这样做：

**articles/show.html.erb**

```html+erb
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

假设我们使用上面的相同 `_box` 局部模板，这将产生与前一个示例相同的输出。

视图路径
----------

在渲染响应时，控制器需要解析不同视图的位置。默认情况下，它只查找 `app/views` 目录中的视图。
我们可以通过使用`prepend_view_path`和`append_view_path`方法来添加其他位置，并在解析路径时给它们特定的优先级。

### Prepend View Path

例如，当我们想要将视图放在不同的子域目录中时，这将非常有帮助。

我们可以这样做：

```ruby
prepend_view_path "app/views/#{request.subdomain}"
```

然后，Action View在解析视图时将首先查找此目录。

### Append View Path

类似地，我们可以追加路径：

```ruby
append_view_path "app/views/direct"
```

这将在查找路径的末尾添加`app/views/direct`。

Helpers
-------

Rails提供了许多与Action View一起使用的辅助方法。这些方法包括用于：

* 格式化日期、字符串和数字
* 创建HTML链接到图像、视频、样式表等...
* 清理内容
* 创建表单
* 本地化内容

您可以在[Action View Helpers Guide](action_view_helpers.html)和[Action View Form Helpers Guide](form_helpers.html)中了解更多有关辅助方法的信息。

本地化视图
---------------

Action View具有根据当前区域设置渲染不同模板的能力。

例如，假设您有一个`ArticlesController`，其中包含一个show动作。默认情况下，调用此动作将渲染`app/views/articles/show.html.erb`。但是，如果您设置`I18n.locale = :de`，那么将渲染`app/views/articles/show.de.html.erb`。如果不存在本地化模板，则将使用未装饰的版本。这意味着您不需要为所有情况提供本地化视图，但如果可用，它们将被优先选择和使用。

您可以使用相同的技术来本地化公共目录中的救援文件。例如，设置`I18n.locale = :de`并创建`public/500.de.html`和`public/404.de.html`将允许您拥有本地化的救援页面。

由于Rails不限制您用于设置I18n.locale的符号，因此您可以利用此系统根据您喜欢的任何内容显示不同的内容。例如，假设您有一些“专家”用户应该看到与“普通”用户不同的页面。您可以将以下内容添加到`app/controllers/application_controller.rb`中：

```ruby
before_action :set_expert_locale

def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
```

然后，您可以创建特殊视图，例如`app/views/articles/show.expert.html.erb`，只会显示给专家用户。

您可以在此处阅读有关Rails国际化（I18n）API的更多信息[i18n.html](i18n.html)。
