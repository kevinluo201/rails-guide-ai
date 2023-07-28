**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fb66c6f4aafffdb8f8d44e8a2076c9b0
从外部开始的Rails路由
====================

本指南涵盖了Rails路由的用户界面功能。

阅读本指南后，您将了解：

* 如何解释`config/routes.rb`中的代码。
* 如何构建自己的路由，使用首选的资源风格或`match`方法。
* 如何声明路由参数，这些参数传递给控制器动作。
* 如何使用路由助手自动创建路径和URL。
* 创建约束和挂载Rack端点等高级技术。

--------------------------------------------------------------------------------

Rails路由器的目的
-------------------

Rails路由器识别URL并将其分派给控制器的动作或Rack应用程序。它还可以生成路径和URL，避免在视图中硬编码字符串的需要。

### 将URL连接到代码

当您的Rails应用程序接收到传入请求时：

```
GET /patients/17
```

它会要求路由器将其与控制器动作匹配。如果第一个匹配的路由是：

```ruby
get '/patients/:id', to: 'patients#show'
```

请求将被分派到`patients`控制器的`show`动作，并在`params`中传递`{ id: '17' }`。

注意：Rails在这里使用snake_case作为控制器名称，如果您有一个多个单词的控制器，比如`MonsterTrucksController`，您可以使用`monster_trucks#show`作为示例。

### 从代码生成路径和URL

您还可以生成路径和URL。如果上面的路由修改为：

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

并且您的应用程序在控制器中包含以下代码：

```ruby
@patient = Patient.find(params[:id])
```

以及在相应的视图中包含以下内容：

```erb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

那么路由器将生成路径`/patients/17`。这减少了视图的脆弱性，并使您的代码更容易理解。请注意，路由助手中不需要指定id。

### 配置Rails路由器

您的应用程序或引擎的路由位于文件`config/routes.rb`中，通常如下所示：

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

由于这是一个常规的Ruby源文件，您可以使用它的所有功能来帮助您定义路由，但是要小心变量名，因为它们可能与路由器的DSL方法冲突。

注意：包装您的路由定义的`Rails.application.routes.draw do ... end`块是必需的，以建立路由器DSL的范围，不能删除。

资源路由：Rails的默认设置
-----------------------------------

资源路由允许您快速声明给定资源控制器的所有常见路由。对[`resources`][]的单个调用可以声明您的`index`、`show`、`new`、`edit`、`create`、`update`和`destroy`动作所需的所有路由。


### Web上的资源

浏览器通过使用特定的HTTP方法（如`GET`、`POST`、`PATCH`、`PUT`和`DELETE`）请求URL来向Rails请求页面。每种方法都是对资源执行操作的请求。资源路由将多个相关请求映射到单个控制器中的动作。

当您的Rails应用程序接收到传入请求时：

```
DELETE /photos/17
```

它会要求路由器将其映射到控制器动作。如果第一个匹配的路由是：

```ruby
resources :photos
```

Rails将将该请求分派到`photos`控制器的`destroy`动作，并在`params`中传递`{ id: '17' }`。

### CRUD、动词和动作

在Rails中，资源路由提供了HTTP动词和URL到控制器动作的映射。按照惯例，每个动作还映射到数据库中的特定CRUD操作。路由文件中的单个条目，例如：

```ruby
resources :photos
```

在您的应用程序中创建了七个不同的路由，都映射到`Photos`控制器：

| HTTP动词 | 路径             | 控制器#动作 | 用于                                         |
| --------- | ---------------- | ----------------- | -------------------------------------------- |
| GET       | /photos          | photos#index      | 显示所有照片的列表                 |
| GET       | /photos/new      | photos#new        | 返回用于创建新照片的HTML表单 |
| POST      | /photos          | photos#create     | 创建新照片                           |
| GET       | /photos/:id      | photos#show       | 显示特定照片                     |
| GET       | /photos/:id/edit | photos#edit       | 返回用于编辑照片的HTML表单      |
| PATCH/PUT | /photos/:id      | photos#update     | 更新特定照片                      |
| DELETE    | /photos/:id      | photos#destroy    | 删除特定照片                      |
注意：由于路由器使用HTTP动词和URL来匹配入站请求，因此四个URL映射到了七个不同的操作。

注意：Rails路由按照它们被指定的顺序进行匹配，所以如果你在`resources :photos`上方有一个`get 'photos/poll'`，那么`resources`行的`show`操作的路由将在`get`行之前匹配。要解决这个问题，将`get`行**移到**`resources`行之前，这样它将首先匹配。

### 路径和URL辅助方法

创建一个资源路由还将向应用程序的控制器公开一些辅助方法。以`resources :photos`为例：

* `photos_path`返回`/photos`
* `new_photo_path`返回`/photos/new`
* `edit_photo_path(:id)`返回`/photos/:id/edit`（例如，`edit_photo_path(10)`返回`/photos/10/edit`）
* `photo_path(:id)`返回`/photos/:id`（例如，`photo_path(10)`返回`/photos/10`）

每个辅助方法都有一个对应的`_url`辅助方法（例如`photos_url`），它返回以当前主机、端口和路径前缀为前缀的相同路径。

提示：要查找路由的路由辅助方法名称，请参见下面的[列出现有路由](#列出现有路由)。

### 同时定义多个资源

如果你需要为多个资源创建路由，可以通过一次调用`resources`来节省一些输入：

```ruby
resources :photos, :books, :videos
```

这与以下代码完全相同：

```ruby
resources :photos
resources :books
resources :videos
```

### 单数资源

有时，你有一个资源，客户端总是查找它而不引用ID。例如，你希望`/profile`始终显示当前登录用户的个人资料。在这种情况下，你可以使用单数资源将`/profile`（而不是`/profile/:id`）映射到`show`操作：

```ruby
get 'profile', to: 'users#show'
```

将`String`传递给`to:`将期望一个`controller#action`格式。当使用`Symbol`时，`to:`选项应该替换为`action:`。当使用没有`#`的`String`时，`to:`选项应该替换为`controller:`：

```ruby
get 'profile', action: :show, controller: 'users'
```

这个资源路由：

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

在你的应用程序中创建了六个不同的路由，都映射到`Geocoders`控制器：

| HTTP动词 | 路径                 | 控制器#操作        | 用于                                       |
| --------- | -------------------- | ----------------- | ------------------------------------------ |
| GET       | /geocoder/new        | geocoders#new     | 返回用于创建地理编码器的HTML表单           |
| POST      | /geocoder            | geocoders#create  | 创建新的地理编码器                         |
| GET       | /geocoder            | geocoders#show    | 显示唯一的地理编码器资源                   |
| GET       | /geocoder/edit       | geocoders#edit    | 返回用于编辑地理编码器的HTML表单           |
| PATCH/PUT | /geocoder            | geocoders#update  | 更新唯一的地理编码器资源                   |
| DELETE    | /geocoder            | geocoders#destroy | 删除地理编码器资源                         |

注意：因为你可能希望将同一个控制器用于单数路由（`/account`）和复数路由（`/accounts/45`），单数资源映射到复数控制器。因此，例如，`resource :photo`和`resources :photos`会创建映射到同一个控制器（`PhotosController`）的单数和复数路由。

单数资源路由生成以下辅助方法：

* `new_geocoder_path`返回`/geocoder/new`
* `edit_geocoder_path`返回`/geocoder/edit`
* `geocoder_path`返回`/geocoder`

注意：调用`resolve`对于通过[记录标识](form_helpers.html#relying-on-record-identification)将`Geocoder`实例转换为路由是必要的。

与复数资源一样，以`_url`结尾的相同辅助方法也会包括主机、端口和路径前缀。

### 控制器命名空间和路由

你可能希望将一组控制器组织在一个命名空间下。最常见的情况是，你可能会将一些管理控制器分组到一个`Admin::`命名空间下，并将这些控制器放在`app/controllers/admin`目录下。你可以使用[`namespace`][]块来路由到这样的一组控制器：

```ruby
namespace :admin do
  resources :articles, :comments
end
```

这将为每个`articles`和`comments`控制器创建一些路由。对于`Admin::ArticlesController`，Rails将创建：

| HTTP动词 | 路径                       | 控制器#操作           | 命名路由辅助方法           |
| --------- | -------------------------- | --------------------- | -------------------------- |
| GET       | /admin/articles            | admin/articles#index  | admin_articles_path        |
| GET       | /admin/articles/new        | admin/articles#new    | new_admin_article_path     |
| POST      | /admin/articles            | admin/articles#create | admin_articles_path        |
| GET       | /admin/articles/:id        | admin/articles#show   | admin_article_path(:id)    |
| GET       | /admin/articles/:id/edit   | admin/articles#edit   | edit_admin_article_path(:id)|
| PATCH/PUT | /admin/articles/:id        | admin/articles#update | admin_article_path(:id)    |
| DELETE    | /admin/articles/:id        | admin/articles#destroy| admin_article_path(:id)    |
如果您希望将`/articles`（不带前缀`/admin`）路由到`Admin::ArticlesController`，您可以使用[`scope`][]块指定模块：

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

这也可以用于单个路由：

```ruby
resources :articles, module: 'admin'
```

如果您希望将`/admin/articles`路由到`ArticlesController`（不带`Admin::`模块前缀），您可以使用`scope`块指定路径：

```ruby
scope '/admin' do
  resources :articles, :comments
end
```

这也可以用于单个路由：

```ruby
resources :articles, path: '/admin/articles'
```

在这两种情况下，命名路由助手与不使用`scope`时保持相同。在最后一种情况下，以下路径映射到`ArticlesController`：

| HTTP方法 | 路径                     | 控制器#动作           | 命名路由助手          |
| --------- | ------------------------ | -------------------- | ---------------------- |
| GET       | /admin/articles          | articles#index       | articles_path          |
| GET       | /admin/articles/new      | articles#new         | new_article_path       |
| POST      | /admin/articles          | articles#create      | articles_path          |
| GET       | /admin/articles/:id      | articles#show        | article_path(:id)      |
| GET       | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id) |
| PATCH/PUT | /admin/articles/:id      | articles#update      | article_path(:id)      |
| DELETE    | /admin/articles/:id      | articles#destroy     | article_path(:id)      |

提示：如果您需要在`namespace`块内使用不同的控制器命名空间，可以指定绝对控制器路径，例如：`get '/foo', to: '/foo#index'`。


### 嵌套资源

通常会有逻辑上属于其他资源的子资源。例如，假设您的应用程序包括以下模型：

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

嵌套路由允许您在路由中捕获此关系。在这种情况下，您可以包含以下路由声明：

```ruby
resources :magazines do
  resources :ads
end
```

除了杂志的路由之外，此声明还将路由广告到`AdsController`。广告URL需要一个杂志：

| HTTP方法 | 路径                                 | 控制器#动作 | 用于                                                                       |
| --------- | ------------------------------------ | ----------------- | -------------------------------------------------------------------------- |
| GET       | /magazines/:magazine_id/ads          | ads#index         | 显示特定杂志的所有广告列表                                                |
| GET       | /magazines/:magazine_id/ads/new      | ads#new           | 返回用于创建属于特定杂志的新广告的HTML表单                                 |
| POST      | /magazines/:magazine_id/ads          | ads#create        | 创建属于特定杂志的新广告                                                   |
| GET       | /magazines/:magazine_id/ads/:id      | ads#show          | 显示属于特定杂志的特定广告                                                 |
| GET       | /magazines/:magazine_id/ads/:id/edit | ads#edit          | 返回用于编辑属于特定杂志的广告的HTML表单                                   |
| PATCH/PUT | /magazines/:magazine_id/ads/:id      | ads#update        | 更新属于特定杂志的特定广告                                                 |
| DELETE    | /magazines/:magazine_id/ads/:id      | ads#destroy       | 删除属于特定杂志的特定广告                                                 |

这也将创建诸如`magazine_ads_url`和`edit_magazine_ad_path`之类的路由助手。这些助手以Magazine的实例作为第一个参数（`magazine_ads_url(@magazine)`）。

#### 嵌套的限制

如果需要，您可以将资源嵌套在其他嵌套资源中。例如：

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

深度嵌套的资源很快变得繁琐。在这种情况下，例如，应用程序将识别以下路径：

```
/publishers/1/magazines/2/photos/3
```

相应的路由助手将是`publisher_magazine_photo_url`，您需要在所有三个级别指定对象。实际上，这种情况足够令人困惑，以至于[Jamis Buck的一篇流行文章](http://weblog.jamisbuck.org/2007/2/5/nesting-resources)提出了一个关于良好Rails设计的经验法则：

提示：资源嵌套不应超过1级。

#### 浅层嵌套

避免深层嵌套（如上所述）的一种方法是在父级下生成集合操作，以便了解层次结构，但不嵌套成员操作。换句话说，只构建具有唯一标识资源的最少信息的路由，如下所示：

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

这个想法在描述性路由和深层嵌套之间取得了平衡。存在一种简写语法可以通过`shallow`选项实现这一目标：

```ruby
resources :articles do
  resources :comments, shallow: true
end
```
这将生成与第一个示例完全相同的路由。您还可以在父资源中指定`:shallow`选项，这样所有嵌套资源都将是浅层的：

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

这里的articles资源将生成以下路由：

| HTTP方法 | 路径                                         | 控制器#动作 | 命名路由助手             |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_comment_path        |
| GET       | /comments/:id(.:format)                      | comments#show     | comment_path             |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | comment_path             |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | comment_path             |
| GET       | /articles/:article_id/quotes(.:format)       | quotes#index      | article_quotes_path      |
| POST      | /articles/:article_id/quotes(.:format)       | quotes#create     | article_quotes_path      |
| GET       | /articles/:article_id/quotes/new(.:format)   | quotes#new        | new_article_quote_path   |
| GET       | /quotes/:id/edit(.:format)                   | quotes#edit       | edit_quote_path          |
| GET       | /quotes/:id(.:format)                        | quotes#show       | quote_path               |
| PATCH/PUT | /quotes/:id(.:format)                        | quotes#update     | quote_path               |
| DELETE    | /quotes/:id(.:format)                        | quotes#destroy    | quote_path               |
| GET       | /articles/:article_id/drafts(.:format)       | drafts#index      | article_drafts_path      |
| POST      | /articles/:article_id/drafts(.:format)       | drafts#create     | article_drafts_path      |
| GET       | /articles/:article_id/drafts/new(.:format)   | drafts#new        | new_article_draft_path   |
| GET       | /drafts/:id/edit(.:format)                   | drafts#edit       | edit_draft_path          |
| GET       | /drafts/:id(.:format)                        | drafts#show       | draft_path               |
| PATCH/PUT | /drafts/:id(.:format)                        | drafts#update     | draft_path               |
| DELETE    | /drafts/:id(.:format)                        | drafts#destroy    | draft_path               |
| GET       | /articles(.:format)                          | articles#index    | articles_path            |
| POST      | /articles(.:format)                          | articles#create   | articles_path            |
| GET       | /articles/new(.:format)                      | articles#new      | new_article_path         |
| GET       | /articles/:id/edit(.:format)                 | articles#edit     | edit_article_path        |
| GET       | /articles/:id(.:format)                      | articles#show     | article_path             |
| PATCH/PUT | /articles/:id(.:format)                      | articles#update   | article_path             |
| DELETE    | /articles/:id(.:format)                      | articles#destroy  | article_path             |

DSL的[`shallow`][]方法创建了一个作用域，在其中每个嵌套都是浅层的。这将生成与前一个示例相同的路由：

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

`scope`有两个选项可以自定义浅层路由。`:shallow_path`在成员路径前加上指定的参数：

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

这里的comments资源将生成以下路由：

| HTTP方法 | 路径                                         | 控制器#动作 | 命名路由助手             |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /sekret/comments/:id/edit(.:format)          | comments#edit     | edit_comment_path        |
| GET       | /sekret/comments/:id(.:format)               | comments#show     | comment_path             |
| PATCH/PUT | /sekret/comments/:id(.:format)               | comments#update   | comment_path             |
| DELETE    | /sekret/comments/:id(.:format)               | comments#destroy  | comment_path             |

`:shallow_prefix`选项将指定的参数添加到命名路由助手中：

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

这里的comments资源将生成以下路由：

| HTTP方法 | 路径                                         | 控制器#动作 | 命名路由助手          |
| --------- | -------------------------------------------- | ----------------- | --------------------------- |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path       |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path       |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path    |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_sekret_comment_path    |
| GET       | /comments/:id(.:format)                      | comments#show     | sekret_comment_path         |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | sekret_comment_path         |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | sekret_comment_path         |


### 路由关注点

路由关注点允许您声明可以在其他资源和路由中重复使用的常见路由。要定义一个关注点，请使用[`concern`][]块：

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

这些关注点可以在资源中使用，以避免代码重复并在路由之间共享行为：

```ruby
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

以上等同于：

```ruby
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```
您还可以通过调用[`concerns`][]在任何地方使用它们。例如，在`scope`或`namespace`块中：

```ruby
namespace :articles do
  concerns :commentable
end
```


### 从对象创建路径和URL

除了使用路由助手之外，Rails还可以根据参数数组创建路径和URL。例如，假设您有以下路由集合：

```ruby
resources :magazines do
  resources :ads
end
```

当使用`magazine_ad_path`时，您可以传递`Magazine`和`Ad`的实例，而不是数字ID：

```erb
<%= link_to '广告详情', magazine_ad_path(@magazine, @ad) %>
```

您还可以使用[`url_for`][ActionView::RoutingUrlFor#url_for]与一组对象，Rails会自动确定您想要的路由：

```erb
<%= link_to '广告详情', url_for([@magazine, @ad]) %>
```

在这种情况下，Rails会看到`@magazine`是`Magazine`，`@ad`是`Ad`，因此会使用`magazine_ad_path`助手。在`link_to`等助手中，您可以只指定对象，而不是完整的`url_for`调用：

```erb
<%= link_to '广告详情', [@magazine, @ad] %>
```

如果您只想链接到杂志：

```erb
<%= link_to '杂志详情', @magazine %>
```

对于其他操作，您只需要将动作名称插入数组的第一个元素：

```erb
<%= link_to '编辑广告', [:edit, @magazine, @ad] %>
```

这使您可以将模型的实例视为URL，并且是使用资源风格的关键优势。


### 添加更多的RESTful操作

您不仅限于RESTful路由默认创建的七个路由。如果需要，您可以添加适用于集合或集合中的单个成员的其他路由。

#### 添加成员路由

要添加成员路由，只需在资源块中添加一个[`member`][]块：

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

这将识别`/photos/1/preview`的GET请求，并路由到`PhotosController`的`preview`动作，其中资源ID值传递给`params[:id]`。它还将创建`preview_photo_url`和`preview_photo_path`助手。

在成员路由的块中，每个路由名称指定将被识别的HTTP动词。您可以在这里使用[`get`][]、[`patch`][]、[`put`][]、[`post`][]或[`delete`][]。如果没有多个`member`路由，您还可以将`：on`传递给路由，消除块：

```ruby
resources :photos do
  get 'preview', on: :member
end
```

您可以省略`：on`选项，这将创建相同的成员路由，只是资源ID值将在`params[:photo_id]`而不是`params[:id]`中可用。路由助手也将从`preview_photo_url`和`preview_photo_path`重命名为`photo_preview_url`和`photo_preview_path`。


#### 添加集合路由

要添加集合路由，使用[`collection`][]块：

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

这将使Rails能够识别诸如`/photos/search`的GET请求，并路由到`PhotosController`的`search`动作。它还将创建`search_photos_url`和`search_photos_path`路由助手。

与成员路由一样，您可以将`：on`传递给路由：

```ruby
resources :photos do
  get 'search', on: :collection
end
```

注意：如果您使用符号作为第一个位置参数来定义其他资源路由，请注意它与使用字符串不等效。符号推断控制器动作，而字符串推断路径。


#### 添加其他新操作的路由

要使用`：on`快捷方式添加替代的新操作：

```ruby
resources :comments do
  get 'preview', on: :new
end
```

这将使Rails能够识别诸如`/comments/new/preview`的GET请求，并路由到`CommentsController`的`preview`动作。它还将创建`preview_new_comment_url`和`preview_new_comment_path`路由助手。

提示：如果您发现自己向资源路由添加了许多额外的操作，那么是时候停下来问问自己是否正在掩盖另一个资源的存在了。

非资源路由
----------

除了资源路由之外，Rails还对将任意URL路由到操作提供了强大的支持。在这里，您不会得到由资源路由自动生成的路由组。相反，您在应用程序中单独设置每个路由。

虽然通常应该使用资源路由，但仍然有许多地方适合使用更简单的路由。如果将应用程序的每个部分都强行塞入资源路由中，那是没有必要的。
特别是简单路由使得将旧的URL映射到新的Rails操作非常容易。

### 绑定参数

当设置一个常规路由时，你提供一系列符号，Rails将这些符号映射到传入的HTTP请求的各个部分。例如，考虑以下路由：

```ruby
get 'photos(/:id)', to: 'photos#display'
```

如果一个传入请求`/photos/1`被该路由处理（因为它没有匹配到文件中的任何先前路由），那么结果将是调用`PhotosController`的`display`操作，并将最终参数`"1"`作为`params[:id]`可用。这个路由还将将传入请求`/photos`路由到`PhotosController#display`，因为`:id`是一个可选参数，用括号表示。

### 动态片段

你可以在常规路由中设置任意多个动态片段。任何片段都将作为`params`的一部分可用于操作。如果你设置了这个路由：

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

传入路径`/photos/1/2`将被分派到`PhotosController`的`show`操作。`params[:id]`将是`"1"`，`params[:user_id]`将是`"2"`。

提示：默认情况下，动态片段不接受点号 - 这是因为点号用作格式化路由的分隔符。如果你需要在动态片段中使用点号，请添加一个覆盖此行为的约束 - 例如，`id: /[^\/]+/`允许除斜杠之外的任何字符。

### 静态片段

在创建路由时，你可以通过不在片段前面添加冒号来指定静态片段：

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

这个路由将响应路径`/photos/1/with_user/2`。在这种情况下，`params`将是`{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`。

### 查询字符串

`params`还将包括查询字符串中的任何参数。例如，使用这个路由：

```ruby
get 'photos/:id', to: 'photos#show'
```

传入路径`/photos/1?user_id=2`将被分派到`Photos`控制器的`show`操作。`params`将是`{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`。

### 定义默认值

你可以通过为`:defaults`选项提供一个哈希来在路由中定义默认值。这甚至适用于你没有指定为动态片段的参数。例如：

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails将匹配`photos/12`到`PhotosController`的`show`操作，并将`params[:format]`设置为`"jpg"`。

你还可以使用[`defaults`][]块来为多个项定义默认值：

```ruby
defaults format: :json do
  resources :photos
end
```

注意：你不能通过查询参数覆盖默认值 - 这是出于安全原因。唯一可以被覆盖的默认值是URL路径中的动态片段。

### 命名路由

你可以使用`:as`选项为任何路由指定一个名称：

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

这将在你的应用程序中创建`logout_path`和`logout_url`作为命名路由助手。调用`logout_path`将返回`/exit`。

你还可以使用这个方法来覆盖资源定义的路由方法，将自定义路由放在资源定义之前，像这样：

```ruby
get ':username', to: 'users#show', as: :user
resources :users
```

这将定义一个`user_path`方法，它将在控制器、助手和视图中可用，它将转到一个如`/bob`的路由。在`UsersController`的`show`操作中，`params[:username]`将包含用户的用户名。如果你不想将参数名设置为`:username`，可以在路由定义中更改`:username`。

### HTTP动词约束

通常，你应该使用[`get`][]、[`post`][]、[`put`][]、[`patch`][]和[`delete`][]方法来限制路由到特定的动词。你可以使用[`match`][]方法和`:via`选项一次匹配多个动词：

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

你可以使用`via: :all`将所有动词匹配到特定的路由：

```ruby
match 'photos', to: 'photos#show', via: :all
```

注意：将`GET`和`POST`请求都路由到单个操作具有安全性问题。通常情况下，除非有充分的理由，否则应避免将所有动词路由到一个操作。

注意：Rails中的`GET`不会检查CSRF令牌。你不应该从`GET`请求中写入数据库，有关更多信息，请参阅CSRF对策的[安全指南](security.html#csrf-countermeasures)。
### 分段约束

您可以使用`:constraints`选项来强制动态段的格式：

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

这个路由将匹配路径如`/photos/A12345`，但不匹配`/photos/893`。您可以使用更简洁的方式表达相同的路由：

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints`接受正则表达式，但不能使用正则表达式锚点。例如，以下路由将无效：

```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

但是请注意，您不需要使用锚点，因为所有路由都在开头和结尾处锚定。

例如，以下路由将允许具有以数字开头的`to_param`值（如`1-hello-world`）的`articles`和以字母开头且不以数字开头的`to_param`值（如`david`）共享根命名空间：

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### 基于请求的约束

您还可以根据返回`String`的[Request对象](action_controller_overview.html#the-request-object)上的任何方法来约束路由。

您可以像指定段约束一样指定基于请求的约束：

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

您还可以使用[`constraints`][]块来指定约束：

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

注意：请求约束通过调用与哈希键同名的[Request对象](action_controller_overview.html#the-request-object)上的方法，并将返回值与哈希值进行比较来工作。因此，约束值应与相应的Request对象方法返回类型匹配。例如：`constraints: { subdomain: 'api' }`将与预期的`api`子域匹配。但是，使用符号`constraints: { subdomain: :api }`将不会匹配，因为`request.subdomain`返回的是字符串`'api'`。

注意：对于`format`约束有一个例外：虽然它是Request对象上的一个方法，但它也是每个路径上的隐式可选参数。段约束优先，并且只有在通过哈希强制执行时，`format`约束才会被应用。例如，`get 'foo', constraints: { format: 'json' }`将匹配`GET  /foo`，因为默认情况下格式是可选的。但是，您可以[使用lambda](#advanced-constraints)，如`get 'foo', constraints: lambda { |req| req.format == :json }`，这样路由将只匹配显式的JSON请求。


### 高级约束

如果您有更复杂的约束，可以提供一个响应`matches?`的对象，Rails将使用该对象。假设您想将受限制列表中的所有用户路由到`RestrictedListController`，您可以这样做：

```ruby
class RestrictedListConstraint
  def initialize
    @ips = RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: RestrictedListConstraint.new
end
```

您还可以将约束指定为lambda：

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

`matches?`方法和lambda都将`request`对象作为参数。

#### 块形式的约束

您可以以块形式指定约束。这在需要将相同规则应用于多个路由时非常有用。例如：

```ruby
class RestrictedListConstraint
  # ...与上面的示例相同
end

Rails.application.routes.draw do
  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

您也可以使用`lambda`：

```ruby
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

### 路由全局匹配和通配符段

路由全局匹配是一种指定特定参数应与路由的所有剩余部分匹配的方法。例如：

```ruby
get 'photos/*other', to: 'photos#unknown'
```

这个路由将匹配`photos/12`或`/photos/long/path/to/12`，将`params[:other]`设置为`"12"`或`"long/path/to/12"`。以星号为前缀的段被称为“通配符段”。

通配符段可以出现在路由的任何位置。例如：

```ruby
get 'books/*section/:title', to: 'books#show'
```

将匹配`books/some/section/last-words-a-memoir`，`params[:section]`等于`'some/section'`，`params[:title]`等于`'last-words-a-memoir'`。

从技术上讲，一个路由甚至可以有多个通配符段。匹配器以直观的方式将段分配给参数。例如：

```ruby
get '*a/foo/*b', to: 'test#index'
```

将匹配`zoo/woo/foo/bar/baz`，`params[:a]`等于`'zoo/woo'`，`params[:b]`等于`'bar/baz'`。
注意：通过请求`'/foo/bar.json'`，你的`params[:pages]`将等于`'foo/bar'`，请求格式为JSON。如果你想要恢复旧的3.0.x行为，你可以像这样提供`format: false`：

```ruby
get '*pages', to: 'pages#show', format: false
```

注意：如果你想要使格式段成为必需的，不能省略，你可以像这样提供`format: true`：

```ruby
get '*pages', to: 'pages#show', format: true
```

### 重定向

你可以使用路由器中的[`redirect`][]助手将任何路径重定向到另一个路径：

```ruby
get '/stories', to: redirect('/articles')
```

你还可以在重定向的路径中重用匹配的动态段：

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

你还可以为`redirect`提供一个块，该块接收符号化的路径参数和请求对象：

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

请注意，默认的重定向是301“永久移动”重定向。请记住，某些Web浏览器或代理服务器会缓存这种类型的重定向，使旧页面无法访问。你可以使用`:status`选项来更改响应状态：

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

在所有这些情况下，如果你不提供前导主机（`http://www.example.com`），Rails将从当前请求中获取这些详细信息。


### 路由到Rack应用程序

在匹配器中，你可以指定任何[Rack应用程序](rails_on_rack.html)作为端点，而不是像`'articles#index'`这样的字符串，它对应于`ArticlesController`中的`index`操作：

```ruby
match '/application.js', to: MyRackApp, via: :all
```

只要`MyRackApp`响应`call`并返回`[status, headers, body]`，路由器就无法区分Rack应用程序和操作之间的区别。这是使用`via: :all`的适当用法，因为你希望允许Rack应用程序根据需要处理所有动词。

注意：对于好奇的人来说，`'articles#index'`实际上扩展为`ArticlesController.action(:index)`，它返回一个有效的Rack应用程序。

注意：由于procs/lambdas是响应`call`的对象，你可以内联实现非常简单的路由（例如用于健康检查）：<br>`get '/health', to: ->(env) { [204, {}, ['']] }`

如果你将Rack应用程序指定为匹配器的端点，请记住接收应用程序中的路由将保持不变。对于以下路由，你的Rack应用程序应该期望路由为`/admin`：

```ruby
match '/admin', to: AdminApp, via: :all
```

如果你希望Rack应用程序在根路径接收请求，而不是其他路径，请使用[`mount`][]：

```ruby
mount AdminApp, at: '/admin'
```


### 使用`root`

你可以使用[`root`][]方法指定Rails应该将`'/'`路由到哪里：

```ruby
root to: 'pages#main'
root 'pages#main' # 上述的快捷方式
```

你应该将`root`路由放在文件的顶部，因为它是最常用的路由，应该首先匹配。

注意：`root`路由只将`GET`请求路由到操作。

你还可以在命名空间和作用域中使用`root`。例如：

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```


### Unicode字符路由

你可以直接指定Unicode字符路由。例如：

```ruby
get 'こんにちは', to: 'welcome#index'
```

### 直接路由

你可以通过调用[`direct`][]直接创建自定义URL助手。例如：

```ruby
direct :homepage do
  "https://rubyonrails.org"
end

# >> homepage_url
# => "https://rubyonrails.org"
```

块的返回值必须是`url_for`方法的有效参数。因此，你可以传递有效的字符串URL、哈希、数组、Active Model实例或Active Model类。

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```


### 使用`resolve`

[`resolve`][]方法允许自定义模型的多态映射。例如：

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_with model: @basket do |form| %>
  <!-- basket form -->
<% end %>
```

这将生成单数URL`/basket`，而不是通常的`/baskets/:id`。


自定义资源路由
------------------------------

虽然[`resources`][]生成的默认路由和助手通常可以满足你的需求，但你可能想以某种方式自定义它们。Rails允许你自定义资源助手的几乎所有通用部分。
### 指定要使用的控制器

`:controller` 选项允许您明确指定要用于资源的控制器。例如：

```ruby
resources :photos, controller: 'images'
```

将识别以 `/photos` 开头的路径，但路由到 `Images` 控制器：

| HTTP 方法 | 路径             | 控制器#动作     | 命名路由助手       |
| --------- | ---------------- | --------------- | ------------------ |
| GET       | /photos          | images#index    | photos_path        |
| GET       | /photos/new      | images#new      | new_photo_path     |
| POST      | /photos          | images#create   | photos_path        |
| GET       | /photos/:id      | images#show     | photo_path(:id)    |
| GET       | /photos/:id/edit | images#edit     | edit_photo_path(:id) |
| PATCH/PUT | /photos/:id      | images#update   | photo_path(:id)    |
| DELETE    | /photos/:id      | images#destroy  | photo_path(:id)    |

注意：使用 `photos_path`、`new_photo_path` 等来生成此资源的路径。

对于命名空间控制器，您可以使用目录表示法。例如：

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

这将路由到 `Admin::UserPermissions` 控制器。

注意：仅支持目录表示法。使用 Ruby 常量表示法（例如 `controller: 'Admin::UserPermissions'`）指定控制器可能会导致路由问题，并产生警告。

### 指定约束条件

您可以使用 `:constraints` 选项来指定对隐式 `id` 的所需格式。例如：

```ruby
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

此声明将约束 `:id` 参数与提供的正则表达式匹配。因此，在这种情况下，路由器将不再将 `/photos/1` 匹配到此路由。而是 `/photos/RR27` 会匹配。

您可以使用块形式来指定应用于多个路由的单个约束条件：

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

注意：当然，您可以在此上下文中使用非资源路由中可用的更高级约束条件。

提示：默认情况下，`:id` 参数不接受点号 - 这是因为点号用作格式化路由的分隔符。如果您需要在 `:id` 中使用点号，请添加一个覆盖此行为的约束条件 - 例如 `id: /[^\/]+/` 允许除斜杠以外的任何字符。

### 覆盖命名路由助手

`:as` 选项允许您覆盖命名路由助手的常规命名。例如：

```ruby
resources :photos, as: 'images'
```

将识别以 `/photos` 开头的路径，并将请求路由到 `PhotosController`，但使用 `:as` 选项的值来命名助手。

| HTTP 方法 | 路径             | 控制器#动作     | 命名路由助手       |
| --------- | ---------------- | --------------- | ------------------ |
| GET       | /photos          | photos#index    | images_path        |
| GET       | /photos/new      | photos#new      | new_image_path     |
| POST      | /photos          | photos#create   | images_path        |
| GET       | /photos/:id      | photos#show     | image_path(:id)    |
| GET       | /photos/:id/edit | photos#edit     | edit_image_path(:id) |
| PATCH/PUT | /photos/:id      | photos#update   | image_path(:id)    |
| DELETE    | /photos/:id      | photos#destroy  | image_path(:id)    |

### 覆盖 `new` 和 `edit` 段

`:path_names` 选项允许您覆盖路径中自动生成的 `new` 和 `edit` 段：

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

这将导致路由识别以下路径：

```
/photos/make
/photos/1/change
```

注意：此选项不会更改实际的动作名称。两个显示的路径仍将路由到 `new` 和 `edit` 动作。

提示：如果您希望统一更改所有路由的此选项，可以使用作用域，如下所示：

```ruby
scope path_names: { new: 'make' } do
  # 其他路由
end
```

### 给命名路由助手添加前缀

您可以使用 `:as` 选项为 Rails 为路由生成的命名路由助手添加前缀。使用此选项可防止使用路径范围的路由之间发生名称冲突。例如：

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

这将更改 `/admin/photos` 的路由助手，从 `photos_path`、`new_photos_path` 等变为 `admin_photos_path`、`new_admin_photo_path` 等。如果在作用域为 `resources :photos` 的情况下没有添加 `as: 'admin_photos'`，非作用域的 `resources :photos` 将没有任何路由助手。

要为一组路由助手添加前缀，请在 `scope` 中使用 `:as`：

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

与之前一样，这将将 `/admin` 作用域的资源助手更改为 `admin_photos_path` 和 `admin_accounts_path`，并允许非作用域资源使用 `photos_path` 和 `accounts_path`。
注意：`namespace`作用域将自动添加`：as`以及`：module`和`：path`前缀。

#### 参数作用域

您可以在路由前面加上一个命名参数：

```ruby
scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
  resources :articles
end
```

这将为您提供诸如`/1/articles/9`之类的路径，并允许您在控制器、助手和视图中将路径的`account_id`部分引用为`params[:account_id]`。

它还将生成以`account_`为前缀的路径和URL助手，您可以像预期的那样将对象传递给它们：

```ruby
account_article_path(@account, @article) # => /1/article/9
url_for([@account, @article])            # => /1/article/9
form_with(model: [@account, @article])   # => <form action="/1/article/9" ...>
```

我们正在[使用约束](#segment-constraints)来限制作用域仅匹配类似ID的字符串。您可以更改约束以适应您的需求，或者完全省略它。`：as`选项也不是严格要求的，但是如果没有它，Rails在评估`url_for([@account, @article])`或依赖于`url_for`的其他助手（如[`form_with`][]）时将引发错误。


### 限制创建的路由

默认情况下，Rails为应用程序中的每个RESTful路由创建七个默认操作（`index`、`show`、`new`、`create`、`edit`、`update`和`destroy`）的路由。您可以使用`：only`和`：except`选项来微调此行为。`：only`选项告诉Rails仅创建指定的路由：

```ruby
resources :photos, only: [:index, :show]
```

现在，对`/photos`的`GET`请求将成功，但对`/photos`的`POST`请求（通常会路由到`create`操作）将失败。

`：except`选项指定Rails不应创建的路由或路由列表：

```ruby
resources :photos, except: :destroy
```

在这种情况下，Rails将创建所有正常的路由，除了`destroy`的路由（对`/photos/:id`的`DELETE`请求）。

提示：如果您的应用程序有许多RESTful路由，使用`：only`和`：except`仅生成您实际需要的路由可以减少内存使用并加快路由过程。

### 翻译路径

使用`scope`，我们可以修改`resources`生成的路径名称：

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

Rails现在创建到`CategoriesController`的路由。

| HTTP动词 | 路径                       | 控制器#操作  | 命名路由助手      |
| --------- | -------------------------- | ------------------ | ----------------------- |
| GET       | /kategorien                | categories#index   | categories_path         |
| GET       | /kategorien/neu            | categories#new     | new_category_path       |
| POST      | /kategorien                | categories#create  | categories_path         |
| GET       | /kategorien/:id            | categories#show    | category_path(:id)      |
| GET       | /kategorien/:id/bearbeiten | categories#edit    | edit_category_path(:id) |
| PATCH/PUT | /kategorien/:id            | categories#update  | category_path(:id)      |
| DELETE    | /kategorien/:id            | categories#destroy | category_path(:id)      |

### 覆盖单数形式

如果要覆盖资源的单数形式，您应该通过[`inflections`][]向变形器添加其他规则：

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```


### 在嵌套资源中使用`:as`

`：as`选项会覆盖嵌套路由助手中自动生成的资源名称。例如：

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

这将创建诸如`magazine_periodical_ads_url`和`edit_magazine_periodical_ad_path`之类的路由助手。

### 覆盖命名路由参数

`：param`选项会覆盖默认的资源标识符`：id`（用于生成路由的[动态段](routing.html#dynamic-segments)的名称）。您可以在控制器中使用`params[<:param>]`访问该段。

```ruby
resources :videos, param: :identifier
```

```
    videos GET  /videos(.:format)                  videos#index
           POST /videos(.:format)                  videos#create
 new_video GET  /videos/new(.:format)              videos#new
edit_video GET  /videos/:identifier/edit(.:format) videos#edit
```

```ruby
Video.find_by(identifier: params[:identifier])
```

您可以覆盖关联模型的`ActiveRecord::Base#to_param`来构建URL：

```ruby
class Video < ApplicationRecord
  def to_param
    identifier
  end
end
```

```ruby
video = Video.find_by(identifier: "Roman-Holiday")
edit_video_path(video) # => "/videos/Roman-Holiday/edit"
```

将*非常*大的路由文件拆分为多个小文件
-------------------------------------------------------

如果您在一个具有数千个路由的大型应用程序中工作，单个`config/routes.rb`文件可能会变得笨重且难以阅读。

Rails提供了一种使用[`draw`][]宏将一个庞大的单个`routes.rb`文件拆分为多个小文件的方法。

您可以有一个包含所有管理员区域路由的`admin.rb`路由文件，另一个用于API相关资源的`api.rb`文件，等等。

```ruby
# config/routes.rb

Rails.application.routes.draw do
  get 'foo', to: 'foo#bar'

  draw(:admin) # 将加载位于`config/routes/admin.rb`的另一个路由文件
end
```
```ruby
# config/routes/admin.rb

namespace :admin do
  resources :comments
end
```

在`Rails.application.routes.draw`块内部调用`draw(:admin)`将尝试加载与给定参数相同名称的路由文件（在此示例中为`admin.rb`）。该文件需要位于`config/routes`目录或任何子目录中（例如`config/routes/admin.rb`或`config/routes/external/admin.rb`）。

您可以在`admin.rb`路由文件中使用常规的路由DSL，但**不应该**像在主`config/routes.rb`文件中那样将其包围在`Rails.application.routes.draw`块中。

### 除非确实需要，否则不要使用此功能

拥有多个路由文件会使发现和理解变得更加困难。对于大多数应用程序，即使是具有几百个路由的应用程序，开发人员使用单个路由文件更容易。Rails路由DSL已经提供了一种使用`namespace`和`scope`以有组织的方式拆分路由的方法。

检查和测试路由
-----------------------------

Rails提供了用于检查和测试路由的工具。

### 列出现有路由

要获取应用程序中可用路由的完整列表，请在服务器以**开发**环境运行时在浏览器中访问<http://localhost:3000/rails/info/routes>。您还可以在终端中执行`bin/rails routes`命令以生成相同的输出。

这两种方法都会按照`config/routes.rb`中的顺序列出所有路由。对于每个路由，您将看到：

* 路由名称（如果有）
* 使用的HTTP动词（如果路由不响应所有动词）
* 要匹配的URL模式
* 路由的路由参数

例如，这是一个RESTful路由的`bin/rails routes`输出的一小部分：

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

您还可以使用`--expanded`选项打开扩展表格格式模式。

```bash
$ bin/rails routes --expanded

--[ Route 1 ]----------------------------------------------------
Prefix            | users
Verb              | GET
URI               | /users(.:format)
Controller#Action | users#index
--[ Route 2 ]----------------------------------------------------
Prefix            |
Verb              | POST
URI               | /users(.:format)
Controller#Action | users#create
--[ Route 3 ]----------------------------------------------------
Prefix            | new_user
Verb              | GET
URI               | /users/new(.:format)
Controller#Action | users#new
--[ Route 4 ]----------------------------------------------------
Prefix            | edit_user
Verb              | GET
URI               | /users/:id/edit(.:format)
Controller#Action | users#edit
```

您可以使用grep选项搜索路由：-g。这将输出部分匹配URL辅助方法名称、HTTP动词或URL路径的任何路由。

```bash
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

如果只想看到映射到特定控制器的路由，可以使用-c选项。

```bash
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

提示：如果将终端窗口扩大到输出行不换行，您会发现`bin/rails routes`的输出更易读。

### 测试路由

路由应该包含在您的测试策略中（就像应用程序的其余部分一样）。Rails提供了三个内置的断言，旨在使测试路由更简单：

* [`assert_generates`][]
* [`assert_recognizes`][]
* [`assert_routing`][]


#### `assert_generates`断言

[`assert_generates`][]断言特定的选项生成特定的路径，并且可以与默认路由或自定义路由一起使用。例如：

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### `assert_recognizes`断言

[`assert_recognizes`][]是`assert_generates`的反向操作。它断言给定的路径被识别，并将其路由到应用程序中的特定位置。例如：

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

您可以提供`:method`参数来指定HTTP动词：

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### `assert_routing`断言

[`assert_routing`][]断言双向路由：它测试路径生成选项，并且选项生成路径。因此，它结合了`assert_generates`和`assert_recognizes`的功能：

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```

[`resources`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
[`namespace`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-namespace
[`scope`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-scope
[`shallow`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-shallow
[`concern`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concern
[`concerns`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concerns
[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`delete`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-delete
[`get`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-get
[`member`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-member
[`patch`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-patch
[`post`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-post
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`collection`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-collection
[`defaults`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-defaults
[`match`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-match
[`constraints`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints
[`redirect`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Redirection.html#method-i-redirect
[`mount`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-mount
[`root`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-root
[`direct`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-direct
[`resolve`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve
[`form_with`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[`inflections`]: https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-inflections
[`draw`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-draw
[`assert_generates`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates
[`assert_recognizes`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes
[`assert_routing`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_routing
