**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37d2486eee8522a64c5f97f86900b8a6
Action View Helpers
====================

阅读完本指南后，您将了解以下内容：

* 如何格式化日期、字符串和数字
* 如何链接到图像、视频、样式表等...
* 如何对内容进行清理
* 如何本地化内容

--------------------------------------------------------------------------------

Action View 提供的 Helper 概述
-------------------------------------------

WIP：这里没有列出所有的 Helper。完整列表请参阅 [API 文档](https://api.rubyonrails.org/classes/ActionView/Helpers.html)

以下仅是 Action View 中可用 Helper 的简要概述。建议您查阅 [API 文档](https://api.rubyonrails.org/classes/ActionView/Helpers.html)，其中详细介绍了所有的 Helper，但这应该是一个很好的起点。

### AssetTagHelper

该模块提供了一些方法，用于生成将视图链接到图像、JavaScript 文件、样式表和 feeds 等资源的 HTML。

默认情况下，Rails 将链接这些资源到当前主机的 public 文件夹中，但您可以通过在应用程序配置中设置 [`config.asset_host`][] 来指示 Rails 链接到来自专用资源服务器的资源，通常在 `config/environments/production.rb` 中设置。例如，假设您的资源主机是 `assets.example.com`：

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```


#### auto_discovery_link_tag

返回一个链接标签，供浏览器和 feed 阅读器用于自动检测 RSS、Atom 或 JSON feed。

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

#### image_path

计算 `app/assets/images` 目录中图像资源的路径。完整路径将通过文档根传递。`image_tag` 内部使用此方法构建图像路径。

```ruby
image_path("edit.png") # => /assets/edit.png
```

如果将 `config.assets.digest` 设置为 true，则会在文件名中添加指纹。

```ruby
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

计算 `app/assets/images` 目录中图像资源的 URL。这将内部调用 `image_path` 并与当前主机或资源主机合并。

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

返回源的 HTML 图像标签。源可以是完整路径，也可以是存在于 `app/assets/images` 目录中的文件。

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

为提供的每个源返回一个 HTML 脚本标签。您可以传递存在于 `app/assets/javascripts` 目录中的 JavaScript 文件的文件名（`.js` 扩展名是可选的）以包含到当前页面中，或者您可以传递相对于文档根的完整路径。

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

计算 `app/assets/javascripts` 目录中 JavaScript 资源的路径。如果源文件名没有扩展名，将添加 `.js`。完整路径将通过文档根传递。`javascript_include_tag` 内部使用此方法构建脚本路径。

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

计算 `app/assets/javascripts` 目录中 JavaScript 资源的 URL。这将内部调用 `javascript_path` 并与当前主机或资源主机合并。

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

为指定的源返回一个样式表链接标签。如果不指定扩展名，将自动添加 `.css`。

```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" rel="stylesheet" />
```

#### stylesheet_path

计算 `app/assets/stylesheets` 目录中样式表资源的路径。如果源文件名没有扩展名，将添加 `.css`。完整路径将通过文档根传递。`stylesheet_link_tag` 内部使用此方法构建样式表路径。

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

计算 `app/assets/stylesheets` 目录中样式表资源的 URL。这将内部调用 `stylesheet_path` 并与当前主机或资源主机合并。

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

该 Helper 使构建 Atom feed 变得简单。以下是一个完整的使用示例：

**config/routes.rb**

```ruby
resources :articles
```

**app/controllers/articles_controller.rb**

```ruby
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```ruby
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

### BenchmarkHelper

#### benchmark

允许您测量模板中块的执行时间，并将结果记录到日志中。将此块包装在昂贵的操作或可能成为瓶颈的操作周围，以获取操作的时间读数。
```html+erb
<% benchmark "处理数据文件" do %>
  <%= expensive_files_operation %>
<% end %>
```

这将在日志中添加类似于"处理数据文件 (0.34523)"的内容，您可以使用这个时间来比较优化代码时的时间。

### CacheHelper

#### cache

这是一个用于缓存视图片段而不是整个操作或页面的方法。这种技术对于缓存菜单、新闻主题列表、静态HTML片段等片段非常有用。该方法接受一个包含您希望缓存的内容的块。有关更多信息，请参见`AbstractController::Caching::Fragments`。

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

`capture`方法允许您将模板的一部分提取到一个变量中。然后您可以在模板或布局的任何地方使用这个变量。

```html+erb
<% @greeting = capture do %>
  <p>欢迎！现在的日期和时间是 <%= Time.now %></p>
<% end %>
```

然后可以在其他地方使用捕获的变量。

```html+erb
<html>
  <head>
    <title>欢迎！</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### content_for

调用`content_for`将一块标记存储在一个标识符中以供以后使用。您可以通过将标识符作为参数传递给`yield`来在其他模板或布局中调用存储的内容。

例如，假设我们有一个标准的应用程序布局，但也有一个特殊的页面需要特定的JavaScript，而其他页面不需要。我们可以使用`content_for`在特殊页面上包含这个JavaScript，而不会使其他页面变得臃肿。

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>欢迎！</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>欢迎！现在的日期和时间是 <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>这是一个特殊页面。</p>

<% content_for :special_script do %>
  <script>alert('你好！')</script>
<% end %>
```

### DateHelper

#### distance_of_time_in_words

报告两个时间或日期对象或整数之间的大致时间间隔，单位为秒。如果要获得更详细的近似值，请将`include_seconds`设置为true。

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => 少于一分钟
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => 少于20秒
```

#### time_ago_in_words

类似于`distance_of_time_in_words`，但`to_time`固定为`Time.now`。

```ruby
time_ago_in_words(3.minutes.from_now) # => 3分钟
```

### DebugHelper

返回一个使用YAML转储的对象的`pre`标签。这样可以以非常可读的方式检查对象。

```ruby
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1, 2, 3] }
debug(my_hash)
```

```html
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

### FormHelper

表单助手旨在通过提供一组基于模型的方法来创建表单，使得与模型一起工作比仅使用标准HTML元素更容易。该助手生成表单的HTML，为每种类型的输入（例如文本、密码、选择等）提供一个方法。当提交表单（即用户点击提交按钮或通过JavaScript调用form.submit）时，表单输入将被捆绑到params对象中并传递回控制器。

您可以在[Action View Form Helpers Guide](form_helpers.html)中了解更多关于表单助手的信息。

### JavaScriptHelper

提供在视图中使用JavaScript的功能。

#### escape_javascript

为JavaScript段落转义回车符和单引号和双引号。

#### javascript_tag

返回包装提供的代码的JavaScript标签。

```ruby
javascript_tag "alert('一切都很好')"
```

```html
<script>
//<![CDATA[
alert('一切都很好')
//]]>
</script>
```

### NumberHelper

提供将数字转换为格式化字符串的方法。提供了电话号码、货币、百分比、精度、位置表示法和文件大小的方法。

#### number_to_currency

将数字格式化为货币字符串（例如$13.65）。

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### number_to_human

将数字格式化为更易读的形式，以便用户更容易阅读；对于可能非常大的数字很有用。

```ruby
number_to_human(1234)    # => 1.23 Thousand
number_to_human(1234567) # => 1.23 Million
```

#### number_to_human_size

将字节大小格式化为更易理解的表示形式；对于向用户报告文件大小很有用。

```ruby
number_to_human_size(1234)    # => 1.21 KB
number_to_human_size(1234567) # => 1.18 MB
```

#### number_to_percentage

将数字格式化为百分比字符串。
```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

将数字格式化为电话号码（默认为美国）。

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

使用分隔符对数字进行分组，以千为单位。

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

使用指定的`precision`级别格式化数字，默认为3。

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

SanitizeHelper模块提供了一组方法，用于清除文本中不需要的HTML元素。

#### sanitize

此sanitize助手将对所有标签进行HTML编码，并删除除特定允许的属性之外的所有属性。

```ruby
sanitize @article.body
```

如果传递了`:attributes`或`:tags`选项，则只允许提到的属性和标签，其他内容将被删除。

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

要更改多个用途的默认值，例如将table标签添加到默认值中：

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

清除CSS代码块。

#### strip_links(html)

从文本中删除所有链接标签，只保留链接文本。

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('emails to <a href="mailto:me@email.com">me@email.com</a>.')
# => emails to me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visit</a>.')
# => Blog: Visit.
```

#### strip_tags(html)

从html中删除所有HTML标签，包括注释。
此功能由rails-html-sanitizer gem提供支持。

```ruby
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!
```

```ruby
strip_tags("<b>Bold</b> no more!  <a href='more.html'>See more</a>")
# => Bold no more!  See more
```

注意：输出可能仍然包含未转义的'<'，'>'和'&'字符，并可能使浏览器混淆。

### UrlHelper

提供了一些方法来创建链接和获取依赖于路由子系统的URL。

#### url_for

返回提供的`options`集合的URL。

##### 示例

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

在底层使用`url_for`派生出一个URL。主要用于创建RESTful资源链接，对于此示例，可以将模型传递给`link_to`。

**示例**

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>
```

如果链接目标无法适应名称参数，则也可以使用块。 ERB示例：

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
<% end %>
```

将输出：

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Check it out!</span>
</a>
```

有关更多信息，请参见[API文档](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)

#### button_to

生成一个提交到传递的URL的表单。该表单具有一个值为`name`的提交按钮。

##### 示例

```html+erb
<%= button_to "Sign in", sign_in_path %>
```

大致输出如下：

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

有关更多信息，请参见[API文档](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)

### CsrfHelper

返回带有跨站请求伪造保护参数和令牌的元标签"csrf-param"和"csrf-token"的名称。

```html
<%= csrf_meta_tags %>
```

注意：常规表单生成隐藏字段，因此不使用这些标签。有关详细信息，请参见[Rails安全指南](security.html#cross-site-request-forgery-csrf)。
[`config.asset_host`]: configuring.html#config-asset-host
