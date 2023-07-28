**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 975163c53746728404fb3a3658fbd0f6
Action View表单助手
========================

Web应用程序中的表单是用户输入的重要界面。然而，由于需要处理表单控件命名及其众多属性的需要，表单标记很快就会变得乏味且难以维护。Rails通过提供用于生成表单标记的视图助手来消除这种复杂性。然而，由于这些助手具有不同的用例，开发人员在使用之前需要了解助手方法之间的区别。

阅读本指南后，您将了解到：

* 如何创建搜索表单和类似的通用表单，这些表单不代表应用程序中的任何特定模型。
* 如何创建以模型为中心的表单，用于创建和编辑特定的数据库记录。
* 如何从多种类型的数据生成选择框。
* Rails提供了哪些日期和时间助手。
* 文件上传表单的不同之处。
* 如何将表单提交到外部资源并指定设置`authenticity_token`。
* 如何构建复杂的表单。

--------------------------------------------------------------------------------

注意：本指南不旨在完整记录所有可用的表单助手及其参数。请访问[Rails API文档](https://api.rubyonrails.org/classes/ActionView/Helpers.html)以获取所有可用助手的完整参考。

处理基本表单
------------------------

主要的表单助手是[`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)。

```erb
<%= form_with do |form| %>
  表单内容
<% end %>
```

当像这样调用时，它会创建一个表单标记，当提交时，将POST到当前页面。例如，假设当前页面是主页，则生成的HTML将如下所示：

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  表单内容
</form>
```

您会注意到HTML包含一个类型为`hidden`的`input`元素。这个`input`很重要，因为没有它，非GET表单无法成功提交。
名为`authenticity_token`的隐藏输入元素是Rails的一个安全特性，称为**跨站请求伪造保护**，表单助手会为每个非GET表单生成它（前提是启用了此安全特性）。您可以在[Securing Rails Applications](security.html#cross-site-request-forgery-csrf)指南中了解更多信息。

### 通用搜索表单

Web上最基本的表单之一是搜索表单。该表单包含：

* 一个使用"GET"方法的表单元素，
* 一个输入的标签，
* 一个文本输入元素，以及
* 一个提交元素。

要创建此表单，您将使用`form_with`和它产生的表单构建器对象。如下所示：

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Search for:" %>
  <%= form.text_field :query %>
  <%= form.submit "Search" %>
<% end %>
```

这将生成以下HTML：

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Search for:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Search" data-disable-with="Search" />
</form>
```

提示：将`url: my_specified_path`传递给`form_with`告诉表单在哪里进行请求。然而，如下所述，您也可以将Active Record对象传递给表单。

提示：对于每个表单输入，都会根据其名称生成一个ID属性（在上面的示例中为`"query"`）。这些ID对于使用CSS样式或使用JavaScript操作表单控件非常有用。

重要提示：对于搜索表单，请使用"GET"作为方法。这允许用户将特定的搜索添加到书签并返回。更一般地，Rails鼓励您使用正确的HTTP动词执行操作。

### 用于生成表单元素的助手

`form_with`产生的表单构建器对象提供了许多助手方法，用于生成文本字段、复选框和单选按钮等表单元素。这些方法的第一个参数始终是输入的名称。
当提交表单时，名称将与表单数据一起传递，并通过用户为该字段输入的值传递到控制器的`params`中。例如，如果表单包含`<%= form.text_field :query %>`，那么您可以在控制器中使用`params[:query]`获取此字段的值。

在命名输入时，Rails使用某些约定，使得可以提交具有非标量值（如数组或哈希）的参数，这些参数也可以在`params`中访问。您可以在本指南的[理解参数命名约定](#understanding-parameter-naming-conventions)部分中了解更多信息。有关这些助手的详细用法，请参阅[API文档](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)。
#### 复选框

复选框是表单控件，允许用户选择或取消一组选项：

```erb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "我有一只狗" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "我有一只猫" %>
```

生成的HTML代码如下：

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">我有一只狗</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">我有一只猫</label>
```

[`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box)的第一个参数是输入框的名称。复选框的值（在`params`中显示的值）可以使用第三个和第四个参数进行指定。详细信息请参阅API文档。

#### 单选按钮

单选按钮与复选框类似，但是单选按钮是互斥的（即用户只能选择其中一个）：

```erb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "我年龄小于21岁" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "我年龄超过21岁" %>
```

输出结果：

```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">我年龄小于21岁</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">我年龄超过21岁</label>
```

[`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button)的第二个参数是输入框的值。由于这两个单选按钮共享相同的名称（`age`），用户只能选择其中一个，`params[:age]`将包含`"child"`或`"adult"`。

注意：始终为复选框和单选按钮使用标签。它们将文本与特定选项关联起来，并通过扩大可点击区域，使用户更容易点击输入框。

### 其他有用的辅助方法

其他值得一提的表单控件包括文本区域、隐藏字段、密码字段、数字字段、日期和时间字段等等：

```erb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```

输出结果：

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```

隐藏字段不会显示给用户，而是像任何文本输入框一样保存数据。其中的值可以使用JavaScript进行更改。

重要提示：搜索、电话、日期、时间、颜色、日期时间、月份、周、URL、电子邮件、数字和范围输入框是HTML5控件。如果您的应用程序需要在旧浏览器中具有一致的体验，您将需要一个HTML5 polyfill（由CSS和/或JavaScript提供）。关于此问题，有[很多解决方案](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills)，目前比较流行的工具是[Modernizr](https://modernizr.com/)，它提供了一种根据检测到的HTML5功能添加功能的简单方法。

提示：如果您使用密码输入字段（无论用途如何），您可能希望配置应用程序以防止记录这些参数。您可以在[Securing Rails Applications](security.html#logging)指南中了解更多信息。

处理模型对象
--------------------------

### 将表单绑定到对象

`form_with`的`:model`参数允许我们将表单构建器对象绑定到模型对象。这意味着表单将针对该模型对象进行作用域限定，并且表单字段将使用该模型对象的值进行填充。

例如，如果我们有一个`@article`模型对象：

```ruby
@article = Article.find(42)
# => #<Article id: 42, title: "My Title", body: "My Body">
```

以下表单：

```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

输出结果：

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="My Title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    My Body
  </textarea>
  <input type="submit" name="commit" value="Update Article" data-disable-with="Update Article">
</form>
```
这里有几个需要注意的地方：

* 表单的 `action` 属性会自动填充适当的值为 `@article`。
* 表单字段会自动填充为 `@article` 对应的值。
* 表单字段的名称会被限定在 `article[...]` 下。这意味着 `params[:article]` 将是一个包含所有这些字段值的哈希。你可以在本指南的 [理解参数命名约定](#understanding-parameter-naming-conventions) 章节中了解更多关于输入名称的重要性。
* 提交按钮会自动获得适当的文本值。

提示：按照惯例，你的输入字段应该与模型属性一致。但这并非必须！如果你需要其他信息，你可以像处理属性一样将其包含在表单中，并通过 `params[:article][:my_nifty_non_attribute_input]` 访问。

#### `fields_for` 辅助方法

[`fields_for`][] 辅助方法创建了一个类似的绑定，但不会渲染 `<form>` 标签。这可以用于在同一个表单中渲染其他模型对象的字段。例如，如果你有一个 `Person` 模型和一个关联的 `ContactDetail` 模型，你可以像这样创建一个包含两者的单个表单：

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

这将产生以下输出：

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

`fields_for` 返回的对象是一个表单构建器，与 `form_with` 返回的对象类似。

### 依赖记录标识

`Article` 模型直接对应应用程序的用户可用，所以 - 遵循 Rails 开发的最佳实践 - 你应该将其声明为**资源**：

```ruby
resources :articles
```

提示：声明资源会产生一些副作用。请参阅 [Rails 外部路由指南](routing.html#resource-routing-the-rails-default) 了解有关设置和使用资源的更多信息。

在处理 RESTful 资源时，如果依赖**记录标识**，`form_with` 的调用会变得更加简单。简而言之，你只需要传递模型实例，Rails 就会自动确定模型名称和其他信息。在以下两个示例中，长式和短式的调用方式都会得到相同的结果：

```ruby
## 创建新文章
# 长式：
form_with(model: @article, url: articles_path)
# 短式：
form_with(model: @article)

## 编辑现有文章
# 长式：
form_with(model: @article, url: article_path(@article), method: "patch")
# 短式：
form_with(model: @article)
```

请注意，短式的 `form_with` 调用方式非常方便，无论记录是新的还是已存在。记录标识会智能地判断记录是否为新记录，通过调用 `record.persisted?` 方法。它还会选择正确的提交路径和基于对象类的名称。

如果你有一个[单数资源](routing.html#singular-resources)，你需要调用 `resource` 和 `resolve` 使其与 `form_with` 协同工作：

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

警告：当你在模型中使用 STI（单表继承）时，如果只有父类被声明为资源，你不能依赖记录标识来处理子类。你需要显式地指定 `:url` 和 `:scope`（模型名称）。

#### 处理命名空间

如果你创建了命名空间路由，`form_with` 也有一个简便的方式处理。如果你的应用程序有一个 `admin` 命名空间，那么

```ruby
form_with model: [:admin, @article]
```

将创建一个提交到 `admin` 命名空间下的 `ArticlesController` 的表单（在更新时提交到 `admin_article_path(@article)`）。如果你有多层命名空间，语法类似：

```ruby
form_with model: [:admin, :management, @article]
```

有关 Rails 路由系统和相关约定的更多信息，请参阅 [Rails 外部路由指南](routing.html)。

### PATCH、PUT 或 DELETE 方法的表单如何工作？

Rails 框架鼓励你的应用程序遵循 RESTful 设计，这意味着你将会频繁使用 "PATCH"、"PUT" 和 "DELETE" 请求（除了 "GET" 和 "POST"）。然而，大多数浏览器在提交表单时**不支持**除 "GET" 和 "POST" 之外的方法。

Rails 通过在名为 `"_method"` 的隐藏输入字段中设置所需方法来解决这个问题，从而模拟其他方法的提交：

```ruby
form_with(url: search_path, method: "patch")
```

输出：

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->
</form>
```
在解析POST数据时，Rails会考虑特殊的`_method`参数，并将其视为内部指定的HTTP方法（在此示例中为“PATCH”）。

在渲染表单时，提交按钮可以通过`formmethod:`关键字覆盖声明的`method`属性：

```erb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Delete", formmethod: :delete, data: { confirm: "Are you sure?" } %>
  <%= form.button "Update" %>
<% end %>
```

与`<form>`元素类似，大多数浏览器不支持通过[formmethod][]覆盖通过[formmethod][]声明的表单方法，除了“GET”和“POST”。

Rails通过结合[formmethod][]、[value][button-value]和[name][button-name]属性来模拟POST上的其他方法来解决此问题：

```html
<form accept-charset="UTF-8" action="/posts/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->

  <button type="submit" formmethod="post" name="_method" value="delete" data-confirm="Are you sure?">Delete</button>
  <button type="submit" name="button">Update</button>
</form>
```


轻松创建选择框
-----------------------------

在HTML中，选择框需要大量的标记 - 每个选项都需要一个`<option>`元素。因此，Rails提供了帮助方法来减轻这个负担。

例如，假设我们有一个城市列表供用户选择。我们可以使用[`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select)帮助方法，如下所示：

```erb
<%= form.select :city, ["Berlin", "Chicago", "Madrid"] %>
```

输出：

```html
<select name="city" id="city">
  <option value="Berlin">Berlin</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```

我们还可以指定与标签不同的`<option>`值：

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
```

输出：

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

这样，用户将看到完整的城市名称，但`params[:city]`将是`"BE"`、`"CHI"`或`"MD"`之一。

最后，我们可以使用`selected:`参数为选择框指定默认选择：

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]], selected: "CHI" %>
```

输出：

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

### 选项组

在某些情况下，我们可能希望通过将相关选项分组来改善用户体验。我们可以通过将`Hash`（或可比较的`Array`）传递给`select`来实现：

```erb
<%= form.select :city,
      {
        "Europe" => [ ["Berlin", "BE"], ["Madrid", "MD"] ],
        "North America" => [ ["Chicago", "CHI"] ],
      },
      selected: "CHI" %>
```

输出：

```html
<select name="city" id="city">
  <optgroup label="Europe">
    <option value="BE">Berlin</option>
    <option value="MD">Madrid</option>
  </optgroup>
  <optgroup label="North America">
    <option value="CHI" selected="selected">Chicago</option>
  </optgroup>
</select>
```

### 选择框和模型对象

与其他表单控件一样，选择框可以绑定到模型属性。例如，如果我们有一个像这样的`@person`模型对象：

```ruby
@person = Person.new(city: "MD")
```

以下表单：

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
<% end %>
```

输出一个选择框：

```html
<select name="person[city]" id="person_city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD" selected="selected">Madrid</option>
</select>
```

注意，适当的选项会自动标记为`selected="selected"`。由于此选择框绑定到模型，我们不需要指定`:selected`参数！

### 时区和国家选择

要在Rails中利用时区支持，您必须询问用户所在的时区。为此，您需要从预定义的[`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html)对象列表生成选择选项，但您可以直接使用已经封装了此功能的[`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select)帮助方法：

```erb
<%= form.time_zone_select :time_zone %>
```

Rails曾经有一个用于选择国家的`country_select`帮助方法，但现在已经提取到了[country_select插件](https://github.com/stefanpenner/country_select)中。

使用日期和时间表单帮助方法
--------------------------------

如果您不希望使用HTML5日期和时间输入，Rails提供了替代的日期和时间表单帮助方法，用于渲染普通的选择框。这些帮助方法为每个时间组件（例如年、月、日等）渲染一个选择框。例如，如果我们有一个像这样的`@person`模型对象：

```ruby
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

以下表单：

```erb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

输出选择框：

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">January</option>
  <option value="2">February</option>
  <option value="3">March</option>
  <option value="4">April</option>
  <option value="5">May</option>
  <option value="6">June</option>
  <option value="7">July</option>
  <option value="8">August</option>
  <option value="9">September</option>
  <option value="10">October</option>
  <option value="11">November</option>
  <option value="12" selected="selected">December</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1</option>
  ...
  <option value="21" selected="selected">21</option>
  ...
  <option value="31">31</option>
</select>
```
请注意，当表单提交时，`params` 哈希中不会有包含完整日期的单个值。相反，会有几个具有特殊名称（如 `"birth_date(1i)"`）的值。Active Record 知道如何将这些特殊命名的值组合成完整的日期或时间，基于模型属性的声明类型。因此，我们可以像使用单个字段表示完整日期的表单一样，将 `params[:person]` 传递给 `Person.new` 或 `Person#update`。

除了 [`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select) 助手之外，Rails 还提供了 [`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select) 和 [`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select)。

### 为单个时间组件渲染选择框

Rails 还提供了用于为单个时间组件渲染选择框的助手：[`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year)、[`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month)、[`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day)、[`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour)、[`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute) 和 [`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second)。这些助手是“裸”方法，意味着它们不是在表单构建器实例上调用的。例如：

```erb
<%= select_year 1999, prefix: "party" %>
```

输出一个选择框，如下所示：

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

对于这些助手的每一个，您可以指定一个日期或时间对象作为默认值，将提取并使用适当的时间组件。

从任意对象集合中选择
----------------------------------------------

有时，我们希望从一个任意对象集合中生成一组选择项。例如，如果我们有一个 `City` 模型和相应的 `belongs_to :city` 关联：

```ruby
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```

```ruby
City.order(:name).map { |city| [city.name, city.id] }
# => [["Berlin", 3], ["Chicago", 1], ["Madrid", 2]]
```

然后，我们可以使用以下表单允许用户从数据库中选择一个城市：

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

注意：当渲染 `belongs_to` 关联的字段时，必须指定外键的名称（在上面的示例中为 `city_id`），而不是关联本身的名称。

但是，Rails 提供了一些助手，可以从集合中生成选择项，而无需显式迭代。这些助手通过调用集合中每个对象的指定方法来确定每个选择项的值和文本标签。

### `collection_select` 助手

要生成一个选择框，我们可以使用 [`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select)：

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

输出：

```html
<select name="person[city_id]" id="person_city_id">
  <option value="3">Berlin</option>
  <option value="1">Chicago</option>
  <option value="2">Madrid</option>
</select>
```

注意：使用 `collection_select`，我们首先指定值方法（在上面的示例中为 `:id`），然后是文本标签方法（在上面的示例中为 `:name`）。这与为 `select` 助手指定选择项时使用的顺序相反，其中文本标签在前，值在后。

### `collection_radio_buttons` 助手

要生成一组单选按钮，我们可以使用 [`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons)：

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

输出：

```html
<input type="radio" name="person[city_id]" value="3" id="person_city_id_3">
<label for="person_city_id_3">Berlin</label>

<input type="radio" name="person[city_id]" value="1" id="person_city_id_1">
<label for="person_city_id_1">Chicago</label>

<input type="radio" name="person[city_id]" value="2" id="person_city_id_2">
<label for="person_city_id_2">Madrid</label>
```

### `collection_check_boxes` 助手

要生成一组复选框（例如，支持 `has_and_belongs_to_many` 关联），我们可以使用 [`collection_check_boxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes)：

```erb
<%= form.collection_check_boxes :interest_ids, Interest.order(:name), :id, :name %>
```

输出：

```html
<input type="checkbox" name="person[interest_id][]" value="3" id="person_interest_id_3">
<label for="person_interest_id_3">Engineering</label>

<input type="checkbox" name="person[interest_id][]" value="4" id="person_interest_id_4">
<label for="person_interest_id_4">Math</label>

<input type="checkbox" name="person[interest_id][]" value="1" id="person_interest_id_1">
<label for="person_interest_id_1">Science</label>

<input type="checkbox" name="person[interest_id][]" value="2" id="person_interest_id_2">
<label for="person_interest_id_2">Technology</label>
```

上传文件
---------------

常见的任务是上传某种类型的文件，无论是一个人的图片还是包含要处理的数据的 CSV 文件。可以使用 [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) 助手来渲染文件上传字段。

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

在处理文件上传时最重要的是，渲染的表单的 `enctype` 属性**必须**设置为 "multipart/form-data"。如果在 `form_with` 中使用 `file_field`，这将自动完成。您也可以手动设置该属性：

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :picture %>
<% end %>
```

请注意，根据 `form_with` 的约定，上述两个表单中的字段名称也会有所不同。也就是说，第一个表单中的字段名称将是 `person[picture]`（可以通过 `params[:person][:picture]` 访问），而第二个表单中的字段名称将只是 `picture`（可以通过 `params[:picture]` 访问）。
### 上传的内容

`params` 哈希中的对象是 [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html) 的实例。以下代码片段将上传的文件保存在 `#{Rails.root}/public/uploads` 目录下，文件名与原始文件相同。

```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

一旦文件上传完成，就有许多潜在的任务，包括文件存储位置（磁盘、Amazon S3 等）、与模型关联、调整图像文件大小、生成缩略图等。[Active Storage](active_storage_overview.html) 旨在帮助处理这些任务。

自定义表单构建器
-------------------------

`form_with` 和 `fields_for` 生成的对象是 [`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html) 的实例。表单构建器封装了为单个对象显示表单元素的概念。除了可以按照通常的方式编写表单帮助方法外，还可以创建 `ActionView::Helpers::FormBuilder` 的子类，并在其中添加帮助方法。例如，

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

可以替换为

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

通过定义类似以下内容的 `LabellingFormBuilder` 类：

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    label(attribute) + super
  end
end
```

如果经常重用这个类，可以定义一个 `labeled_form_with` 帮助方法，自动应用 `builder: LabellingFormBuilder` 选项：

```ruby
def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
  options[:builder] = LabellingFormBuilder
  form_with model: model, scope: scope, url: url, format: format, **options, &block
end
```

所使用的表单构建器还决定了当执行以下操作时会发生什么：

```erb
<%= render partial: f %>
```

如果 `f` 是 `ActionView::Helpers::FormBuilder` 的实例，那么这将渲染 `form` 部分，将部分的对象设置为表单构建器。如果表单构建器是 `LabellingFormBuilder` 类的实例，则会渲染 `labelling_form` 部分。

理解参数命名约定
------------------------------------------

表单中的值可以位于 `params` 哈希的顶层，也可以嵌套在另一个哈希中。例如，在 Person 模型的标准 `create` 操作中，`params[:person]` 通常是一个包含要创建的 person 的所有属性的哈希。`params` 哈希还可以包含数组、哈希的数组等等。

从根本上说，HTML 表单不知道任何结构化数据，它们只生成名称-值对，其中对是普通字符串。你在应用程序中看到的数组和哈希是 Rails 使用的一些参数命名约定的结果。

### 基本结构

两个基本结构是数组和哈希。哈希反映了访问 `params` 中的值所使用的语法。例如，如果一个表单包含：

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

`params` 哈希将包含

```ruby
{ 'person' => { 'name' => 'Henry' } }
```

而 `params[:person][:name]` 将在控制器中检索提交的值。

哈希可以嵌套任意多层，例如：

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

将导致 `params` 哈希为

```ruby
{ 'person' => { 'address' => { 'city' => 'New York' } } }
```

通常情况下，Rails 会忽略重复的参数名称。如果参数名称以一对空方括号 `[]` 结尾，则它们将累积在一个数组中。如果你希望用户能够输入多个电话号码，可以在表单中添加以下内容：

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

这将导致 `params[:person][:phone_number]` 是一个包含输入的电话号码的数组。

### 结合使用

我们可以混合使用这两个概念。哈希的一个元素可以是一个数组，就像前面的例子中一样，或者可以是一个哈希的数组。例如，一个表单可以通过重复以下表单片段来创建任意数量的地址：

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

这将导致 `params[:person][:addresses]` 是一个包含具有 `line1`、`line2` 和 `city` 键的哈希的数组。

然而，有一个限制：虽然哈希可以任意嵌套，但只允许一级的 "数组性"。数组通常可以被哈希替代；例如，可以使用哈希将模型对象的数组替换为以其 id、数组索引或其他参数为键的模型对象的哈希。
警告：数组参数与`check_box`辅助程序不兼容。根据HTML规范，未选中的复选框不会提交任何值。然而，复选框始终提交一个值通常是很方便的。`check_box`辅助程序通过创建一个同名的辅助隐藏输入来模拟这一点。如果复选框未选中，则只提交隐藏输入，如果选中，则两者都提交，但复选框提交的值优先。

### `fields_for`辅助程序的`:index`选项

假设我们想要渲染一个表单，其中包含每个人的一组地址字段。[`fields_for`][]辅助程序及其`:index`选项可以帮助实现：

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

假设该人有两个ID为23和45的地址，上述表单将渲染类似以下的输出：

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

这将导致一个类似以下的`params`哈希：

```ruby
{
  "person" => {
    "name" => "Bob",
    "address" => {
      "23" => {
        "city" => "Paris"
      },
      "45" => {
        "city" => "London"
      }
    }
  }
}
```

所有表单输入都映射到`"person"`哈希，因为我们在`person_form`表单构建器上调用了`fields_for`。另外，通过指定`index: address.id`，我们将每个城市输入的`name`属性呈现为`person[address][#{address.id}][city]`，而不是`person[address][city]`。因此，我们能够确定在处理`params`哈希时应该修改哪些地址记录。

您可以通过`:index`选项传递其他重要的数字或字符串。您甚至可以传递`nil`，这将生成一个数组参数。

要创建更复杂的嵌套，您可以显式指定输入名称的前导部分。例如：

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

将创建类似以下的输入：

```html
<input id="person_address_primary_23_city" name="person[address][primary][23][city]" type="text" value="Paris" />
```

您还可以直接向诸如`text_field`之类的辅助程序传递`:index`选项，但通常在表单构建器级别指定这一点比在单个输入字段上指定更少重复。

一般来说，最终的输入名称将是`fields_for` / `form_with`给定的名称、`:index`选项值和属性名称的连接。

最后，作为一种快捷方式，您可以在`:index`（例如`index: address.id`）中指定一个ID，然后将`"[]"`附加到给定的名称。例如：

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

将产生与我们原始示例完全相同的输出。

用于外部资源的表单
---------------------------

Rails的表单辅助程序也可以用于构建用于向外部资源提交数据的表单。但是，有时需要为资源设置一个`authenticity_token`；可以通过将`authenticity_token: 'your_external_token'`参数传递给`form_with`选项来实现：

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  表单内容
<% end %>
```

有时，在向外部资源（如支付网关）提交数据时，表单中可以使用的字段受到外部API的限制，生成`authenticity_token`可能是不可取的。要不发送令牌，只需将`false`传递给`:authenticity_token`选项：

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  表单内容
<% end %>
```

构建复杂表单
----------------------

许多应用程序超出了编辑单个对象的简单表单。例如，当创建一个`Person`时，您可能希望允许用户（在同一个表单上）创建多个地址记录（家庭、工作等）。当稍后编辑该人时，用户应该能够根据需要添加、删除或修改地址。

### 配置模型

Active Record通过[`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for)方法提供了模型级别的支持：

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses
end

class Address < ApplicationRecord
  belongs_to :person
end
```

这在`Person`上创建了一个`addresses_attributes=`方法，允许您创建、更新和（可选地）销毁地址。
### 嵌套表单

以下表单允许用户创建一个`Person`及其关联的地址。

```html+erb
<%= form_with model: @person do |form| %>
  地址：
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

当关联接受嵌套属性时，`fields_for`为每个关联的元素渲染其块。特别地，如果一个人没有地址，它将不会渲染任何内容。一个常见的模式是控制器构建一个或多个空的子对象，以便至少向用户显示一个字段集。下面的示例将在新的人员表单上渲染2组地址字段。

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```

`fields_for`生成一个表单构建器。参数的名称将是`accepts_nested_attributes_for`所期望的名称。例如，当创建一个具有2个地址的用户时，提交的参数将如下所示：

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

`addresses_attributes`哈希中键的实际值并不重要；但是它们需要是整数的字符串，并且对于每个地址都不同。

如果关联对象已保存，`fields_for`会自动生成一个带有保存记录的`id`的隐藏输入。您可以通过将`include_id: false`传递给`fields_for`来禁用此功能。

### 控制器

通常，在将参数传递给模型之前，您需要在控制器中[声明允许的参数](action_controller_overview.html#strong-parameters)：

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### 删除对象

您可以通过将`allow_destroy: true`传递给`accepts_nested_attributes_for`来允许用户删除关联对象。

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

如果对象的属性哈希包含带有求值为`true`（例如1、'1'、true或'true'）的`_destroy`键，则该对象将被销毁。此表单允许用户删除地址：

```erb
<%= form_with model: @person do |form| %>
  地址：
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

不要忘记在控制器中更新允许的参数，以包括`_destroy`字段：

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### 防止空记录

通常，忽略用户未填写的字段集是很有用的。您可以通过将`reject_if` proc传递给`accepts_nested_attributes_for`来控制此行为。此proc将使用表单提交的每个属性哈希调用。如果proc返回`true`，则Active Record将不会为该哈希构建关联对象。下面的示例仅在设置了`kind`属性时尝试构建地址。

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda { |attributes| attributes['kind'].blank? }
end
```

为了方便起见，您可以传递符号`:all_blank`，它将创建一个proc，该proc将拒绝所有属性为空的记录，但不包括`_destroy`的任何值。

### 动态添加字段

与其提前渲染多组字段，您可能希望仅在用户点击“添加新地址”按钮时才添加它们。Rails没有提供任何内置支持。在生成新的字段集时，您必须确保关联数组的键是唯一的 - 当前的JavaScript日期（自[纪元](https://en.wikipedia.org/wiki/Unix_time)以来的毫秒数）是一个常见的选择。

在没有表单构建器上下文的情况下使用标签助手
----------------------------------------

如果您需要在表单构建器的上下文之外渲染表单字段，Rails提供了常见表单元素的标签助手。例如，[`check_box_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-check_box_tag)：

```erb
<%= check_box_tag "accept" %>
```

输出：

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

通常，这些助手的名称与它们的表单构建器对应项相同，只是添加了`_tag`后缀。有关完整列表，请参阅[`FormTagHelper` API文档](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)。
使用`form_tag`和`form_for`
-------------------------------

在Rails 5.1之前，`form_with`被引入之前，其功能被分为[`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag)和[`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for)。现在两者都已被软弃用。关于它们的使用方法可以在[本指南的旧版本](https://guides.rubyonrails.org/v5.2/form_helpers.html)中找到文档。
[`fields_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for
[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-formmethod
[button-name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-name
[button-value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-value
