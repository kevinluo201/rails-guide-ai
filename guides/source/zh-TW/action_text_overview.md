**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a4b9132308ed3786777061bd137af660
Action Text 概述
====================

本指南提供了一切你需要開始處理豐富文本內容的資訊。

閱讀完本指南後，你將會知道：

* 如何配置 Action Text。
* 如何處理豐富文本內容。
* 如何為豐富文本內容和附件設定樣式。

--------------------------------------------------------------------------------

什麼是 Action Text？
--------------------

Action Text 將豐富文本內容和編輯功能帶到了 Rails。它包含了 [Trix 編輯器](https://trix-editor.org)，該編輯器可以處理從格式設定到連結、引用、列表、嵌入圖片和圖庫等所有內容。Trix 編輯器生成的豐富文本內容會保存在自己的 RichText 模型中，並與應用程序中的任何現有 Active Record 模型關聯。任何嵌入的圖片（或其他附件）都會使用 Active Storage 自動保存並與包含的 RichText 模型關聯。

## Trix 與其他豐富文本編輯器的比較

大多數所謂的所見即所得（WYSIWYG）編輯器都是對 HTML 的 `contenteditable` 和 `execCommand` API 的封裝，這些 API 是由微軟設計的，用於支持在 Internet Explorer 5.5 中編輯網頁的功能，並且後來被其他瀏覽器[逆向工程](https://blog.whatwg.org/the-road-to-html-5-contenteditable#history)和複製。

由於這些 API 從未完全指定或記錄，且由於所見即所得 HTML 編輯器的範圍非常廣泛，每個瀏覽器的實現都有自己的一套錯誤和怪癖，JavaScript 開發人員必須解決這些不一致性。

Trix 通過將 contenteditable 視為一個輸入/輸出設備來避免這些不一致性：當輸入進入編輯器時，Trix 將該輸入轉換為對其內部文檔模型的編輯操作，然後將該文檔重新渲染回編輯器。這使得 Trix 可以完全控制每次按鍵後發生的事情，並且完全避免使用 execCommand。

## 安裝

運行 `bin/rails action_text:install` 以添加 Yarn 套件並複製必要的遷移文件。同時，你需要為嵌入的圖片和其他附件設置 Active Storage。請參考 [Active Storage 概述](active_storage_overview.html) 指南。
注意：Action Text使用多態關聯與`action_text_rich_texts`表格，以便可以與所有具有富文本屬性的模型共享。如果使用UUID值作為標識符的Action Text內容模型，則所有使用Action Text屬性的模型都需要使用UUID值作為其唯一標識符。Action Text生成的遷移還需要更新，以在`：record` `references`行中指定`type: :uuid`。

安裝完成後，Rails應用程序應該有以下更改：

1. 在JavaScript入口點中需要引入`trix`和`@rails/actiontext`。

    ```js
    // application.js
    import "trix"
    import "@rails/actiontext"
    ```

2. `trix`樣式表將與Action Text樣式一起包含在`application.css`文件中。

## 創建富文本內容

為現有模型添加富文本字段：

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  has_rich_text :content
end
```

或者在創建新模型時添加富文本字段：

```bash
$ bin/rails generate model Message content:rich_text
```

注意：不需要在`messages`表格中添加`content`字段。

然後在模型的表單中使用[`rich_text_area`]來引用該字段：

```erb
<%# app/views/messages/_form.html.erb %>
<%= form_with model: message do |form| %>
  <div class="field">
    <%= form.label :content %>
    <%= form.rich_text_area :content %>
  </div>
<% end %>
```

最後，在頁面上顯示經過過濾的富文本：

```erb
<%= @message.content %>
```

注意：如果`content`字段中有附加的資源，除非在本地安裝了*libvips/libvips42*套件，否則可能無法正確顯示。請查看它們的[安裝文檔](https://www.libvips.org/install.html)以獲取相關信息。

要接受富文本內容，您只需要允許引用的屬性：

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create! params.require(:message).permit(:title, :content)
    redirect_to message
  end
end
```
## 渲染豐富文本內容

預設情況下，Action Text 將在具有 `.trix-content` 類別的元素內渲染豐富文本內容：

```html+erb
<%# app/views/layouts/action_text/contents/_content.html.erb %>
<div class="trix-content">
  <%= yield %>
</div>
```

具有此類別的元素以及 Action Text 編輯器的樣式由 [`trix` 樣式表](https://unpkg.com/trix/dist/trix.css) 定義。
如果要提供自己的樣式，請從安裝程式建立的 `app/assets/stylesheets/actiontext.css` 樣式表中刪除 `= require trix` 行。

要自訂豐富文本內容周圍的 HTML 渲染，請編輯安裝程式建立的 `app/views/layouts/action_text/contents/_content.html.erb` 佈局。

要自訂嵌入圖像和其他附件（稱為 blobs）的 HTML 渲染，請編輯安裝程式建立的 `app/views/active_storage/blobs/_blob.html.erb` 模板。

### 渲染附件

除了透過 Active Storage 上傳的附件外，Action Text 還可以嵌入任何可以由 [Signed GlobalID](https://github.com/rails/globalid#signed-global-ids) 解析的內容。

Action Text 通過將嵌入的 `<action-text-attachment>` 元素的 `sgid` 屬性解析為實例來渲染。
一旦解析完成，該實例將傳遞給 [`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render)。
渲染結果的 HTML 將作為 `<action-text-attachment>` 元素的子元素嵌入其中。

例如，考慮一個 `User` 模型：

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar
end

user = User.find(1)
user.to_global_id.to_s #=> gid://MyRailsApp/User/1
user.to_signed_global_id.to_s #=> BAh7CEkiCG…
```

接下來，考慮一些嵌入了 `<action-text-attachment>` 元素的豐富文本內容，該元素引用了 `User` 實例的已簽署 GlobalID：

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>.</p>
```

Action Text 使用 "BAh7CEkiCG…" 字串解析 `User` 實例。
接下來，考慮應用程式的 `users/user` 偏好：

```html+erb
<%# app/views/users/_user.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Action Text 渲染的結果 HTML 會類似於：

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"><span><img src="..."> Jane Doe</span></action-text-attachment>.</p>
```

要渲染不同的偏好，請定義 `User#to_attachable_partial_path`：

```ruby
class User < ApplicationRecord
  def to_attachable_partial_path
    "users/attachable"
  end
end
```

然後聲明該偏好。`User` 實例將作為 `user` 偏好區域變數可用：

```html+erb
<%# app/views/users/_attachable.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```
如果Action Text無法解析`User`實例（例如，如果該記錄已被刪除），則將呈現一個默認的回退部分。

Rails為缺少附件提供了一個全局部分。此部分安裝在應用程序的`views/action_text/attachables/missing_attachable`中，如果您想呈現不同的HTML，可以對其進行修改。

要呈現不同的缺少附件部分，請定義一個類級的`to_missing_attachable_partial_path`方法：

```ruby
class User < ApplicationRecord
  def self.to_missing_attachable_partial_path
    "users/missing_attachable"
  end
end
```

然後聲明該部分。

```html+erb
<%# app/views/users/missing_attachable.html.erb %>
<span>已刪除的用戶</span>
```

要與Action Text `<action-text-attachment>`元素呈現集成，類必須：

* 包含`ActionText::Attachable`模塊
* 實現`#to_sgid(**options)`（通過[`GlobalID::Identification`關注點][global-id]提供）
* （可選）聲明`#to_attachable_partial_path`
* （可選）聲明一個類級方法`#to_missing_attachable_partial_path`來處理缺少的記錄

默認情況下，所有的`ActiveRecord::Base`子類都混入了[`GlobalID::Identification`關注點][global-id]，因此與`ActionText::Attachable`兼容。

## 避免N+1查詢

如果您希望預加載相關的`ActionText::RichText`模型，假設您的富文本字段名為`content`，您可以使用命名範圍：

```ruby
Message.all.with_rich_text_content # 預加載不包含附件的內容。
Message.all.with_rich_text_content_and_embeds # 預加載包含內容和附件。
```

## API / 後端開發

1. 後端API（例如，使用JSON）需要一個單獨的端點來上傳文件，該端點創建一個`ActiveStorage::Blob`並返回其`attachable_sgid`：

    ```json
    {
      "attachable_sgid": "BAh7CEkiCG…"
    }
    ```

2. 使用`<action-text-attachment>`標籤，將`attachable_sgid`插入到富文本內容中，並要求前端執行此操作：

    ```html
    <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>
    ```

這是基於Basecamp的，所以如果您仍然找不到您要尋找的內容，請查看此[Basecamp文檔](https://github.com/basecamp/bc3-api/blob/master/sections/rich_text.md)。
[`rich_text_area`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area
[global-id]: https://github.com/rails/globalid#usage
