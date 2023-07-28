**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a4b9132308ed3786777061bd137af660
Action Text概述
====================

本指南为您提供了一切所需，以开始处理富文本内容。

阅读本指南后，您将了解：

* 如何配置Action Text。
* 如何处理富文本内容。
* 如何为富文本内容和附件设置样式。

--------------------------------------------------------------------------------

什么是Action Text？
--------------------

Action Text为Rails带来了富文本内容和编辑功能。它包括[Trix编辑器](https://trix-editor.org)，该编辑器可以处理从格式设置到链接、引用、列表、嵌入图像和图库的所有内容。Trix编辑器生成的富文本内容保存在其自己的RichText模型中，该模型与应用程序中的任何现有Active Record模型相关联。任何嵌入的图像（或其他附件）都会自动使用Active Storage存储，并与包含的RichText模型相关联。

## Trix与其他富文本编辑器的比较

大多数所见即所得（WYSIWYG）编辑器都是HTML的`contenteditable`和`execCommand` API的包装器，由Microsoft设计用于支持在Internet Explorer 5.5中实时编辑网页，并且最终被其他浏览器[逆向工程](https://blog.whatwg.org/the-road-to-html-5-contenteditable#history)并复制。

由于这些API从未完全指定或记录，并且由于所见即所得HTML编辑器的范围非常广泛，每个浏览器的实现都有自己的一套错误和怪异行为，JavaScript开发人员需要解决这些不一致之处。

Trix通过将contenteditable视为输入/输出设备来避开这些不一致之处：当输入到达编辑器时，Trix将该输入转换为对其内部文档模型的编辑操作，然后将该文档重新呈现到编辑器中。这使得Trix可以完全控制每个按键后发生的情况，并且完全避免使用execCommand。

## 安装

运行`bin/rails action_text:install`来添加Yarn包并复制必要的迁移文件。此外，您需要为嵌入的图像和其他附件设置Active Storage。请参考[Active Storage概述](active_storage_overview.html)指南。

注意：Action Text使用多态关系与`action_text_rich_texts`表共享，以便可以与具有富文本属性的所有模型共享。如果使用UUID值作为标识符的模型使用Action Text内容，则所有使用Action Text属性的模型都需要使用UUID值作为其唯一标识符。生成的Action Text迁移还需要更新以指定`:record` `references`行的`type: :uuid`。

安装完成后，Rails应用程序应具有以下更改：

1. 在JavaScript入口点中，应同时引入`trix`和`@rails/actiontext`。

    ```js
    // application.js
    import "trix"
    import "@rails/actiontext"
    ```

2. `trix`样式表将与Action Text样式一起包含在`application.css`文件中。

## 创建富文本内容

向现有模型添加富文本字段：

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  has_rich_text :content
end
```

或者在创建新模型时添加富文本字段：

```bash
$ bin/rails generate model Message content:rich_text
```

注意：您不需要在`messages`表中添加`content`字段。

然后在模型的表单中使用[`rich_text_area`]引用该字段：

```erb
<%# app/views/messages/_form.html.erb %>
<%= form_with model: message do |form| %>
  <div class="field">
    <%= form.label :content %>
    <%= form.rich_text_area :content %>
  </div>
<% end %>
```

最后，在页面上显示经过过滤的富文本内容：

```erb
<%= @message.content %>
```

注意：如果`content`字段中有附加资源，除非您在本地计算机上安装了*libvips/libvips42*软件包，否则可能无法正确显示。请查阅他们的[安装文档](https://www.libvips.org/install.html)以获取详细信息。

要接受富文本内容，您只需要允许引用的属性：

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create! params.require(:message).permit(:title, :content)
    redirect_to message
  end
end
```


## 渲染富文本内容

默认情况下，Action Text将在具有`.trix-content`类的元素内呈现富文本内容：

```html+erb
<%# app/views/layouts/action_text/contents/_content.html.erb %>
<div class="trix-content">
  <%= yield %>
</div>
```

具有此类的元素以及Action Text编辑器都受[`trix`样式表](https://unpkg.com/trix/dist/trix.css)的样式控制。如果要提供自己的样式，请从安装程序创建的`app/assets/stylesheets/actiontext.css`样式表中删除`= require trix`行。

要自定义富文本内容周围呈现的HTML，请编辑安装程序创建的`app/views/layouts/action_text/contents/_content.html.erb`布局。

要自定义嵌入图像和其他附件（称为blob）的呈现的HTML，请编辑安装程序创建的`app/views/active_storage/blobs/_blob.html.erb`模板。
### 渲染附件

除了通过Active Storage上传的附件外，Action Text还可以嵌入任何可以由[签名的GlobalID](https://github.com/rails/globalid#signed-global-ids)解析的内容。

Action Text通过将嵌入的`<action-text-attachment>`元素的`sgid`属性解析为一个实例来渲染它们。一旦解析完成，该实例将被传递给[`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render)。生成的HTML将作为`<action-text-attachment>`元素的子元素嵌入其中。

例如，考虑一个`User`模型：

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar
end

user = User.find(1)
user.to_global_id.to_s #=> gid://MyRailsApp/User/1
user.to_signed_global_id.to_s #=> BAh7CEkiCG…
```

接下来，考虑一些包含引用`User`实例的签名GlobalID的`<action-text-attachment>`元素的富文本内容：

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>.</p>
```

Action Text使用"BAh7CEkiCG…"字符串来解析`User`实例。接下来，考虑应用程序的`users/user`局部视图：

```html+erb
<%# app/views/users/_user.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Action Text渲染的结果HTML将类似于：

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"><span><img src="..."> Jane Doe</span></action-text-attachment>.</p>
```

要渲染不同的局部视图，请定义`User#to_attachable_partial_path`：

```ruby
class User < ApplicationRecord
  def to_attachable_partial_path
    "users/attachable"
  end
end
```

然后声明该局部视图。`User`实例将作为`user`局部变量可用：

```html+erb
<%# app/views/users/_attachable.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

如果Action Text无法解析`User`实例（例如，记录已被删除），则会渲染默认的回退局部视图。

Rails提供了一个用于缺失附件的全局局部视图。该局部视图在应用程序的`views/action_text/attachables/missing_attachable`中安装，并且可以根据需要进行修改以渲染不同的HTML。

要渲染不同的缺失附件局部视图，请定义一个类级别的`to_missing_attachable_partial_path`方法：

```ruby
class User < ApplicationRecord
  def self.to_missing_attachable_partial_path
    "users/missing_attachable"
  end
end
```

然后声明该局部视图。

```html+erb
<%# app/views/users/missing_attachable.html.erb %>
<span>Deleted user</span>
```

要与Action Text的`<action-text-attachment>`元素渲染集成，一个类必须：

* 包含`ActionText::Attachable`模块
* 实现`#to_sgid(**options)`（通过[`GlobalID::Identification` concern][global-id]提供）
* （可选）声明`#to_attachable_partial_path`
* （可选）声明一个处理缺失记录的类级别方法`#to_missing_attachable_partial_path`

默认情况下，所有的`ActiveRecord::Base`子类都混入了[`GlobalID::Identification` concern][global-id]，因此与`ActionText::Attachable`兼容。

## 避免N+1查询

如果您希望预加载相关的`ActionText::RichText`模型，假设您的富文本字段名为`content`，您可以使用命名作用域：

```ruby
Message.all.with_rich_text_content # 预加载正文，不包括附件。
Message.all.with_rich_text_content_and_embeds # 预加载正文和附件。
```

## API / 后端开发

1. 后端API（例如，使用JSON）需要一个单独的端点来上传文件，创建一个`ActiveStorage::Blob`并返回其`attachable_sgid`：

    ```json
    {
      "attachable_sgid": "BAh7CEkiCG…"
    }
    ```

2. 使用`<action-text-attachment>`标签将`attachable_sgid`插入富文本内容中，要求前端执行此操作：

    ```html
    <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>
    ```

这是基于Basecamp的，所以如果您仍然找不到您要找的内容，请查看此[Basecamp文档](https://github.com/basecamp/bc3-api/blob/master/sections/rich_text.md)。
[`rich_text_area`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area
[global-id]: https://github.com/rails/globalid#usage
