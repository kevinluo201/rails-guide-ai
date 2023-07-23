**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 390d20a8bee6232c0ffa7faeb0e9d8e8
Action Mailer 基礎知識
====================

本指南提供了您需要開始從應用程序發送電子郵件以及 Action Mailer 的許多內部知識。它還涵蓋了如何測試您的郵件發送器。

閱讀本指南後，您將了解：

* 如何在 Rails 應用程序中發送電子郵件。
* 如何生成和編輯 Action Mailer 類和郵件視圖。
* 如何配置 Action Mailer 以適應您的環境。
* 如何測試您的 Action Mailer 類。

--------------------------------------------------------------------------------

什麼是 Action Mailer？
----------------------

Action Mailer 允許您使用郵件發送器類和視圖從應用程序發送電子郵件。

### 郵件發送器類似於控制器

它們繼承自 [`ActionMailer::Base`][] 並位於 `app/mailers` 目錄下。郵件發送器類似於控制器的工作方式。以下是一些相似之處的例子。郵件發送器具有：

* 動作，以及相應的視圖，出現在 `app/views` 目錄下。
* 在視圖中可以訪問的實例變量。
* 可以使用佈局和局部視圖。
* 可以訪問 params 哈希。

發送郵件
--------------

本節將提供一個逐步指南，以創建郵件發送器及其視圖。

### 生成郵件發送器的步驟

#### 創建郵件發送器

```bash
$ bin/rails generate mailer User
create  app/mailers/user_mailer.rb
create  app/mailers/application_mailer.rb
invoke  erb
create    app/views/user_mailer
create    app/views/layouts/mailer.text.erb
create    app/views/layouts/mailer.html.erb
invoke  test_unit
create    test/mailers/user_mailer_test.rb
create    test/mailers/previews/user_mailer_preview.rb
```

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout 'mailer'
end
```

```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
end
```

如您所見，您可以像使用其他 Rails 生成器一樣生成郵件發送器。

如果您不想使用生成器，您可以在 `app/mailers` 目錄下創建自己的文件，只需確保它繼承自 `ActionMailer::Base`：

```ruby
class MyMailer < ActionMailer::Base
end
```

#### 編輯郵件發送器

郵件發送器具有稱為 "動作" 的方法，它們使用視圖來結構化其內容。控制器生成像 HTML 這樣的內容以返回給客戶端，而郵件發送器創建一個要通過電子郵件發送的消息。

`app/mailers/user_mailer.rb` 包含一個空的郵件發送器：

```ruby
class UserMailer < ApplicationMailer
end
```

讓我們添加一個名為 `welcome_email` 的方法，該方法將向用戶的註冊電子郵件地址發送一封電子郵件：

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: '歡迎來到我的網站')
  end
end
```

以下是前面方法中呈現的項目的快速解釋。有關所有可用選項的完整列表，請查看下面的完整的 Action Mailer 可設置屬性列表部分。

* [`default`][] 方法為此郵件發送器中發送的所有郵件設置默認值。在這種情況下，我們使用它來為此類中的所有消息設置 `:from` 標頭值。這可以在每封郵件上進行覆蓋。
* [`mail`][] 方法創建實際的電子郵件消息。我們使用它來指定每封郵件的 `:to` 和 `:subject` 標頭的值。

#### 創建郵件發送器視圖

在 `app/views/user_mailer/` 目錄下創建一個名為 `welcome_email.html.erb` 的文件。這將是用於電子郵件的模板，以 HTML 格式化：
```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>歡迎來到 example.com，<%= @user.name %></h1>
    <p>
      您已成功註冊 example.com，
      您的使用者名稱是：<%= @user.login %>.<br>
    </p>
    <p>
      要登入網站，只需點擊此連結：<%= @url %>.
    </p>
    <p>感謝您的加入，祝您有美好的一天！</p>
  </body>
</html>
```

讓我們也為這封郵件添加一個純文字部分。並非所有的客戶端都支援 HTML 郵件，所以最佳做法是同時發送純文字和 HTML 郵件。為此，在 `app/views/user_mailer/` 中創建一個名為 `welcome_email.text.erb` 的文件：

```erb
歡迎來到 example.com，<%= @user.name %>
===============================================

您已成功註冊 example.com，
您的使用者名稱是：<%= @user.login %>.

要登入網站，只需點擊此連結：<%= @url %>.

感謝您的加入，祝您有美好的一天！
```

現在當您調用 `mail` 方法時，Action Mailer 將檢測到這兩個模板（純文字和 HTML），並自動生成一封 `multipart/alternative` 郵件。

#### 調用 Mailer

Mailer 實際上只是另一種渲染視圖的方式。它們不是通過 HTTP 協議渲染視圖並發送，而是通過電子郵件協議發送。因此，當用戶成功創建時，最好的做法是讓控制器告訴 Mailer 發送一封郵件。

設置這一點很簡單。

首先，讓我們創建一個 `User` 脚手架：

```bash
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

現在我們有了一個可以使用的用戶模型，我們將編輯 `app/controllers/users_controller.rb` 文件，使其在用戶成功保存後指示 `UserMailer` 發送一封郵件，方法是在創建操作中編輯並在用戶成功保存後插入一個對 `UserMailer.with(user: @user).welcome_email` 的調用。

我們將使用 [`deliver_later`][] 將郵件排入發送隊列，它是由 Active Job 支持的。這樣，控制器操作可以繼續執行，而不需要等待發送完成。

```ruby
class UsersController < ApplicationController
  # ...

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # 告訴 UserMailer 在保存後發送歡迎郵件
        UserMailer.with(user: @user).welcome_email.deliver_later

        format.html { redirect_to(@user, notice: 'User was successfully created.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # ...
end
```

注意：Active Job 的默認行為是通過 `:async` 適配器執行作業。因此，您可以使用 `deliver_later` 非同步地發送郵件。
Active Job 的默認適配器使用一個進程內的線程池運行作業。它非常適合開發/測試環境，因為它不需要任何外部基礎設施，但它不適合生產環境，因為它在重新啟動時會丟棄未完成的作業。
如果您需要一個持久的後端，您需要使用具有持久後端的 Active Job 適配器（如 Sidekiq、Resque 等）。

如果您想立即發送郵件（例如從 cronjob 中），只需調用 [`deliver_now`][]：

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```

任何傳遞給 [`with`][] 的鍵值對都會成為郵件動作的 `params`。因此，`with(user: @user, account: @user.account)` 會在郵件動作中使 `params[:user]` 和 `params[:account]` 可用，就像控制器的 params 一樣。

`welcome_email` 方法返回一個 [`ActionMailer::MessageDelivery`][] 物件，然後可以告訴它 `deliver_now` 或 `deliver_later` 來發送郵件。`ActionMailer::MessageDelivery` 物件是 [`Mail::Message`][] 的封裝。如果你想檢查、修改或對 `Mail::Message` 物件進行其他操作，可以使用 `ActionMailer::MessageDelivery` 物件上的 [`message`][] 方法來訪問它。

### 自動編碼標頭值

Action Mailer 處理標頭和內容中的多字節字符的自動編碼。

對於更複雜的例子，例如定義替代字符集或自編碼文本，請參考 [Mail](https://github.com/mikel/mail) 函式庫。

### Action Mailer 方法的完整列表

只需要三個方法就可以發送幾乎任何郵件消息：

* [`headers`][] - 指定郵件上的任何標頭。可以傳遞一個鍵值對的哈希，或者可以調用 `headers[:field_name] = 'value'`。
* [`attachments`][] - 允許將附件添加到郵件中。例如，`attachments['file-name.jpg'] = File.read('file-name.jpg')`。
* [`mail`][] - 創建實際的郵件本身。可以將標頭作為哈希傳遞給 `mail` 方法作為參數。`mail` 方法將根據定義的郵件模板創建一封郵件，可以是純文本或多部分。

#### 添加附件

Action Mailer 很容易添加附件。

* 傳遞文件名和內容給 Action Mailer，[Mail gem](https://github.com/mikel/mail) 會自動猜測 `mime_type`，設置 `encoding`，並創建附件。

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

  當觸發 `mail` 方法時，它將發送一封帶有附件的多部分郵件，正確地嵌套在 `multipart/mixed` 的頂層，第一部分是包含純文本和 HTML 郵件消息的 `multipart/alternative`。

注意：Mail 會自動對附件進行 Base64 編碼。如果你想要其他的編碼方式，請對內容進行編碼，並將編碼後的內容和編碼方式作為 `Hash` 傳遞給 `attachments` 方法。

* 傳遞文件名並指定標頭和內容給 Action Mailer 和 Mail，它們將使用你傳遞的設置。

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: encoded_content
    }
    ```

注意：如果指定了編碼，Mail 將假設你的內容已經編碼，並且不會嘗試對其進行 Base64 編碼。

#### 創建內嵌附件

Action Mailer 3.0 簡化了內嵌附件的操作，這在 3.0 之前的版本中需要進行很多操作。

* 首先，告訴 Mail 將附件轉換為內嵌附件，只需在 Mailer 內的 attachments 方法上調用 `#inline`：

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* 然後在視圖中，你可以將 `attachments` 視為哈希並指定要顯示的附件，調用 `url` 方法並將結果傳遞給 `image_tag` 方法：

```html+erb
<p>你好，這是我們的圖片</p>

<%= image_tag attachments['image.jpg'].url %>
```

* 由於這是對 `image_tag` 的標準呼叫，你可以在附件 URL 後面傳入一個選項哈希，就像對其他圖片一樣：

```html+erb
<p>你好，這是我們的圖片</p>

<%= image_tag attachments['image.jpg'].url, alt: '我的照片', class: 'photos' %>
```

#### 發送郵件給多個收件人

可以通過將郵件地址列表設置為 `:to` 鍵，一次性向一個或多個收件人發送郵件（例如，通知所有管理員有新的註冊）。郵件地址列表可以是一個郵件地址數組，也可以是一個以逗號分隔的郵件地址字符串。

```ruby
class AdminMailer < ApplicationMailer
  default to: -> { Admin.pluck(:email) },
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "新用戶註冊：#{@user.email}")
  end
end
```

同樣的格式也可以用於設置副本（Cc：）和密件副本（Bcc：）收件人，分別使用 `:cc` 和 `:bcc` 鍵。

#### 發送帶有名稱的郵件

有時候，當收件人收到郵件時，你希望顯示人名而不僅僅是他們的郵件地址。你可以使用 [`email_address_with_name`][] 來實現：

```ruby
def welcome_email
  @user = params[:user]
  mail(
    to: email_address_with_name(@user.email, @user.name),
    subject: '歡迎來到我們的網站'
  )
end
```

同樣的技巧也可以用於指定發件人名稱：

```ruby
class UserMailer < ApplicationMailer
  default from: email_address_with_name('notification@example.com', 'Example Company Notifications')
end
```

如果名稱是空字符串，則只返回地址。

### 郵件視圖

郵件視圖位於 `app/views/name_of_mailer_class` 目錄中。郵件視圖之所以被類所知，是因為它的名稱與郵件方法相同。在上面的例子中，`welcome_email` 方法的郵件視圖將位於 `app/views/user_mailer/welcome_email.html.erb`（HTML 版本）和 `welcome_email.text.erb`（純文本版本）。

要更改操作的默認郵件視圖，你可以這樣做：

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: '歡迎來到我們的網站',
         template_path: 'notifications',
         template_name: 'another')
  end
end
```

在這種情況下，它將在 `app/views/notifications` 中尋找名為 `another` 的模板。你還可以為 `template_path` 指定一個路徑數組，它們將按順序搜索。

如果你想要更靈活，你還可以傳遞一個塊並渲染特定的模板，甚至在不使用模板文件的情況下渲染內聯或純文本：

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: '歡迎來到我們的網站') do |format|
      format.html { render 'another_template' }
      format.text { render plain: 'Render text' }
    end
  end
end
```

這將為 HTML 部分渲染模板 `another_template.html.erb`，並使用渲染的文本作為文本部分。渲染命令與 Action Controller 中使用的命令相同，因此你可以使用所有相同的選項，例如 `:text`、`:inline` 等。

如果你想要渲染位於默認的 `app/views/mailer_name/` 目錄之外的模板，你可以應用 [`prepend_view_path`][]，像這樣：
```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # 這將嘗試載入 "custom/path/to/mailer/view/welcome_email" 模板
  def welcome_email
    # ...
  end
end
```

您也可以考慮使用 [`append_view_path`][] 方法。


#### 快取 Mailer 視圖

您可以像在應用程式視圖中一樣，在 Mailer 視圖中使用 [`cache`][] 方法進行片段快取。

```html+erb
<% cache do %>
  <%= @company.name %>
<% end %>
```

要使用此功能，您需要在應用程式中進行配置：

```ruby
config.action_mailer.perform_caching = true
```

片段快取也支援多部分郵件。詳細了解快取的資訊，請參閱 [Rails 快取指南](caching_with_rails.html)。


### Action Mailer 佈局

就像控制器視圖一樣，您也可以有 Mailer 佈局。佈局名稱需要與您的 Mailer 相同，例如 `user_mailer.html.erb` 和 `user_mailer.text.erb`，這樣 Mailer 才能自動識別它們為佈局。

要使用不同的檔案，請在您的 Mailer 中調用 [`layout`][]：

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # 使用 awesome.(html|text).erb 作為佈局
end
```

就像控制器視圖一樣，使用 `yield` 在佈局中呈現視圖。

您還可以在格式區塊內的渲染呼叫中傳遞 `layout: 'layout_name'` 選項，以指定不同格式的不同佈局：

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

如果存在，將使用 `my_layout.html.erb` 檔案呈現 HTML 部分，並使用通常的 `user_mailer.text.erb` 檔案呈現文本部分。


### 預覽郵件

Action Mailer 預覽提供了一種通過訪問特殊 URL 來查看郵件外觀的方法。在上面的例子中，`UserMailer` 的預覽類應該被命名為 `UserMailerPreview`，並位於 `test/mailers/previews/user_mailer_preview.rb`。要查看 `welcome_email` 的預覽，實現一個同名的方法並調用 `UserMailer.welcome_email`：

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

然後，預覽將在 <http://localhost:3000/rails/mailers/user_mailer/welcome_email> 中可用。

如果您在 `app/views/user_mailer/welcome_email.html.erb` 或郵件本身中進行了更改，它將自動重新載入和渲染，以便您可以立即看到新的樣式。預覽列表也可在 <http://localhost:3000/rails/mailers> 中找到。

預設情況下，這些預覽類位於 `test/mailers/previews`。可以使用 `preview_paths` 選項進行配置。例如，如果您想將 `lib/mailer_previews` 添加到其中，可以在 `config/application.rb` 中進行配置：

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### 在 Action Mailer 視圖中生成 URL

與控制器不同，Mailer 實例沒有關於傳入請求的任何上下文，因此您需要自己提供 `:host` 參數。

由於 `:host` 通常在整個應用程式中保持一致，您可以在 `config/application.rb` 中全局配置它：

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```

由於這種行為，您無法在郵件內部使用任何 `*_path` 輔助方法。相反，您需要使用相關的 `*_url` 輔助方法。例如，不要使用

```html+erb
<%= link_to 'welcome', welcome_path %>
```

而應使用：

```html+erb
<%= link_to 'welcome', welcome_url %>
```

通過使用完整的 URL，您的連結現在將在郵件中正常工作。
#### 使用 `url_for` 生成 URL

在模板中，[`url_for`][] 默認生成完整的 URL。

如果你沒有全局配置 `:host` 選項，請確保將其傳遞給 `url_for`。


```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```


#### 使用命名路由生成 URL

郵件客戶端沒有網絡上下文，因此路徑沒有基本 URL 來形成完整的網址。因此，您應該始終使用命名路由助手的 `*_url` 變體。

如果你沒有全局配置 `:host` 選項，請確保將其傳遞給 URL 助手。

```erb
<%= user_url(@user, host: 'example.com') %>
```

注意：非 `GET` 鏈接需要 [rails-ujs](https://github.com/rails/rails/blob/main/actionview/app/assets/javascripts) 或 [jQuery UJS](https://github.com/rails/jquery-ujs)，並且在郵件模板中無法工作。它們將導致普通的 `GET` 請求。

### 在 Action Mailer 視圖中添加圖片

與控制器不同，郵件程序實例沒有關於傳入請求的任何上下文，因此您需要自己提供 `:asset_host` 參數。

由於 `:asset_host` 通常在整個應用程序中保持一致，您可以在 `config/application.rb` 中全局配置它：

```ruby
config.asset_host = 'http://example.com'
```

現在，您可以在電子郵件中顯示圖片。

```html+erb
<%= image_tag 'image.jpg' %>
```

### 發送多部分郵件

如果您對同一個操作有不同的模板，Action Mailer 將自動發送多部分郵件。因此，對於我們的 `UserMailer` 示例，如果在 `app/views/user_mailer` 中有 `welcome_email.text.erb` 和 `welcome_email.html.erb`，Action Mailer 將自動發送一封多部分郵件，其中 HTML 和文本版本被設置為不同的部分。

插入部分的順序由 `ActionMailer::Base.default` 方法中的 `:parts_order` 確定。

### 使用動態傳遞選項發送郵件

如果您希望在發送郵件時覆蓋默認的傳遞選項（例如 SMTP 憑據），可以在郵件程序操作中使用 `delivery_method_options` 進行設置。

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = user_url(@user)
    delivery_options = { user_name: params[:company].smtp_user,
                         password: params[:company].smtp_password,
                         address: params[:company].smtp_host }
    mail(to: @user.email,
         subject: "Please see the Terms and Conditions attached",
         delivery_method_options: delivery_options)
  end
end
```

### 發送無模板渲染的郵件

有時您可能希望跳過模板渲染步驟，並將郵件正文作為字符串提供。您可以使用 `:body` 選項來實現這一點。在這種情況下，不要忘記添加 `:content_type` 選項。否則，Rails 將默認為 `text/plain`。

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email,
         body: params[:email_body],
         content_type: "text/html",
         subject: "Already rendered!")
  end
end
```

Action Mailer 回調
-----------------------

Action Mailer 允許您指定 [`before_action`][]、[`after_action`][] 和 [`around_action`][] 來配置消息，以及 [`before_deliver`][]、[`after_deliver`][] 和 [`around_deliver`][] 來控制發送。

* 回調可以使用塊或郵件程序類中的方法符號指定，類似於控制器。

* 您可以使用 `before_action` 來設置實例變量、使用默認值填充郵件對象，或插入默認標頭和附件。

```ruby
class InvitationsMailer < ApplicationMailer
  before_action :set_inviter_and_invitee
  before_action { @account = params[:inviter].account }

  default to:       -> { @invitee.email_address },
          from:     -> { common_address(@inviter) },
          reply_to: -> { @inviter.email_address_with_name }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end

  def project_invitation
    @project    = params[:project]
    @summarizer = ProjectInvitationSummarizer.new(@project.bucket)

    mail subject: "#{@inviter.name.familiar} added you to a project in Basecamp (#{@account.name})"
  end

  private
    def set_inviter_and_invitee
      @inviter = params[:inviter]
      @invitee = params[:invitee]
    end
end
```
* 您可以使用 `after_action` 來進行類似於 `before_action` 的設置，但是使用郵件發送操作中設置的實例變量。

* 使用 `after_action` 回調還可以通過更新 `mail.delivery_method.settings` 來覆蓋郵件發送方法的設置。

```ruby
class UserMailer < ApplicationMailer
  before_action { @business, @user = params[:business], params[:user] }

  after_action :set_delivery_options,
               :prevent_delivery_to_guests,
               :set_business_headers

  def feedback_message
  end

  def campaign_message
  end

  private
    def set_delivery_options
      # 在這裡，您可以訪問郵件實例、@business 和 @user 實例變量
      if @business && @business.has_smtp_settings?
        mail.delivery_method.settings.merge!(@business.smtp_settings)
      end
    end

    def prevent_delivery_to_guests
      if @user && @user.guest?
        mail.perform_deliveries = false
      end
    end

    def set_business_headers
      if @business
        headers["X-SMTPAPI-CATEGORY"] = @business.code
      end
    end
end
```

* 您可以使用 `after_delivery` 來記錄郵件的發送。

* 郵件回調如果將 body 設置為非 nil 值，則會中止進一步的處理。`before_deliver` 可以使用 `throw :abort` 中止。

使用 Action Mailer 助手
---------------------------

Action Mailer 繼承自 `AbstractController`，因此您可以使用大多數與 Action Controller 相同的助手。

還有一些 Action Mailer 特定的助手方法可在 [`ActionMailer::MailHelper`][] 中使用。例如，這些方法允許您在視圖中使用 [`mailer`][MailHelper#mailer] 訪問郵件實例，並使用 [`message`][MailHelper#message] 訪問郵件消息：

```erb
<%= stylesheet_link_tag mailer.name.underscore %>
<h1><%= message.subject %></h1>
```

Action Mailer 配置
---------------------------

以下配置選項最好在環境文件（environment.rb、production.rb 等）中進行設置：

| 配置 | 描述 |
|---------------|-------------|
|`logger`|如果可用，生成有關郵件運行的信息。可以設置為 `nil` 以禁用日誌記錄。與 Ruby 自帶的 `Logger` 和 `Log4r` 日誌記錄器兼容。|
|`smtp_settings`|允許對 `:smtp` 發送方法進行詳細配置：<ul><li>`:address` - 允許您使用遠程郵件服務器。只需將其從默認的 `"localhost"` 設置更改即可。</li><li>`:port` - 如果您的郵件服務器不運行在 25 端口上，您可以更改它。</li><li>`:domain` - 如果您需要指定 HELO 域，可以在此處設置。</li><li>`:user_name` - 如果您的郵件服務器需要身份驗證，請在此設置用戶名。</li><li>`:password` - 如果您的郵件服務器需要身份驗證，請在此設置密碼。</li><li>`:authentication` - 如果您的郵件服務器需要身份驗證，您需要在此處指定身份驗證類型。這是一個符號，可以是 `:plain`（以明文形式發送密碼）、`:login`（以 Base64 編碼形式發送密碼）或 `:cram_md5`（結合了 Challenge/Response 機制以交換信息和使用加密的 Message Digest 5 算法對重要信息進行哈希）之一。</li><li>`:enable_starttls` - 在連接到 SMTP 服務器時使用 STARTTLS，如果不支持則失敗。默認為 `false`。</li><li>`:enable_starttls_auto` - 檢測您的 SMTP 服務器是否啟用了 STARTTLS，並開始使用它。默認為 `true`。</li><li>`:openssl_verify_mode` - 在使用 TLS 時，您可以設置 OpenSSL 如何檢查證書。如果您需要驗證自簽名和/或通配符證書，這非常有用。您可以使用 OpenSSL 驗證常量的名稱（'none' 或 'peer'）或直接使用常量（`OpenSSL::SSL::VERIFY_NONE` 或 `OpenSSL::SSL::VERIFY_PEER`）。</li><li>`:ssl/:tls` - 啟用 SMTP 連接使用 SMTP/TLS（SMTPS：SMTP 通過直接 TLS 連接）</li><li>`:open_timeout` - 嘗試打開連接時等待的秒數。</li><li>`:read_timeout` - 等待讀取（read(2) 調用）超時的秒數。</li></ul>|
|`sendmail_settings`|允許您覆蓋 `:sendmail` 發送方法的選項：<ul><li>`:location` - sendmail 可執行文件的位置。默認為 `/usr/sbin/sendmail`。</li><li>`:arguments` - 要傳遞給 sendmail 的命令行參數。默認為 `["-i"]`。</li></ul>|
|`raise_delivery_errors`|如果郵件發送失敗，是否應該引發錯誤。只有在外部郵件服務器配置為立即發送時才有效。默認為 `true`。|
|`delivery_method`|定義一種發送方法。可能的值有：<ul><li>`:smtp`（默認），可以通過使用 [`config.action_mailer.smtp_settings`][] 進行配置。</li><li>`:sendmail`，可以通過使用 [`config.action_mailer.sendmail_settings`][] 進行配置。</li><li>`:file`：將郵件保存到文件中；可以通過使用 `config.action_mailer.file_settings` 進行配置。</li><li>`:test`：將郵件保存到 `ActionMailer::Base.deliveries` 數組中。</li></ul>更多信息請參見 [API 文檔](https://api.rubyonrails.org/classes/ActionMailer/Base.html)。|
|`perform_deliveries`|確定在調用 Mail 消息的 `deliver` 方法時是否實際執行發送操作。默認為執行，但可以關閉以幫助功能測試。如果此值為 `false`，即使 `delivery_method` 為 `:test`，`deliveries` 數組也不會被填充。|
|`deliveries`|保留通過 Action Mailer 使用 `:test` 發送方法發送的所有郵件的數組。對於單元測試和功能測試非常有用。|
|`delivery_job`|與 `deliver_later` 一起使用的作業類。默認為 `ActionMailer::MailDeliveryJob`。|
|`deliver_later_queue_name`|與默認 `delivery_job` 一起使用的隊列名稱。默認為默認的 Active Job 隊列。|
|`default_options`|允許您為 `mail` 方法的選項（`:from`、`:reply_to` 等）設置默認值。|
有關可能的配置的完整說明，請參閱我們的《配置Rails應用指南》中的[配置Action Mailer](configuring.html#configuring-action-mailer)部分。

### Action Mailer配置示例

例如，將以下內容添加到適當的`config/environments/$RAILS_ENV.rb`文件中：

```ruby
config.action_mailer.delivery_method = :sendmail
# 默認值：
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: %w[ -i ]
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = { from: 'no-reply@example.com' }
```

### Gmail的Action Mailer配置

Action Mailer使用[Mail gem](https://github.com/mikel/mail)並接受類似的配置。將以下內容添加到`config/environments/$RAILS_ENV.rb`文件中以通過Gmail發送郵件：

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:         'smtp.gmail.com',
  port:            587,
  domain:          'example.com',
  user_name:       '<username>',
  password:        '<password>',
  authentication:  'plain',
  enable_starttls: true,
  open_timeout:    5,
  read_timeout:    5 }
```

如果您使用的是舊版本的Mail gem（2.6.x或更早版本），請使用`enable_starttls_auto`而不是`enable_starttls`。

注意：Google會封鎖它認為不安全的應用程序的登錄。您可以在[這裡](https://www.google.com/settings/security/lesssecureapps)更改Gmail設置以允許登錄嘗試。如果您的Gmail帳戶啟用了雙重驗證，則需要設置[應用密碼](https://myaccount.google.com/apppasswords)並使用該密碼代替常規密碼。

郵件測試
--------------

您可以在[測試指南](testing.html#testing-your-mailers)中找到有關如何測試郵件的詳細說明。

攔截和觀察郵件
-------------------

Action Mailer提供了對Mail觀察者和攔截器方法的鉤子。這些方法允許您註冊在每封發送的郵件的郵件傳遞生命週期中調用的類。

### 攔截郵件

攔截器允許您在將郵件交給傳遞代理之前對郵件進行修改。攔截器類必須實現`::delivering_email(message)`方法，在郵件發送之前調用該方法。

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

在攔截器能夠正常工作之前，您需要使用`interceptors`配置選項註冊它。您可以在初始化文件（例如`config/initializers/mail_interceptors.rb`）中進行此操作：

```ruby
Rails.application.configure do
  if Rails.env.staging?
    config.action_mailer.interceptors = %w[SandboxEmailInterceptor]
  end
end
```

注意：上面的示例使用了一個名為“staging”的自定義環境，用於類似於生產環境但用於測試目的的服務器。您可以閱讀有關自定義Rails環境的更多信息，請參閱[創建Rails環境](configuring.html#creating-rails-environments)。

### 觀察郵件

觀察者允許您在郵件發送後訪問郵件消息。觀察者類必須實現`:delivered_email(message)`方法，在郵件發送後調用該方法。

```ruby
class EmailDeliveryObserver
  def self.delivered_email(message)
    EmailDelivery.log(message)
  end
end
```

與攔截器類似，您必須使用`observers`配置選項註冊觀察者。您可以在初始化文件（例如`config/initializers/mail_observers.rb`）中進行此操作：

```ruby
Rails.application.configure do
  config.action_mailer.observers = %w[EmailDeliveryObserver]
end
```
[`ActionMailer::Base`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html
[`default`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-c-default
[`mail`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-mail
[`ActionMailer::MessageDelivery`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html
[`deliver_later`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_later
[`deliver_now`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_now
[`Mail::Message`]: https://api.rubyonrails.org/classes/Mail/Message.html
[`message`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-message
[`with`]: https://api.rubyonrails.org/classes/ActionMailer/Parameterized/ClassMethods.html#method-i-with
[`attachments`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-attachments
[`headers`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-headers
[`email_address_with_name`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-email_address_with_name
[`append_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-append_view_path
[`prepend_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-prepend_view_path
[`cache`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CacheHelper.html#method-i-cache
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`url_for`]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`after_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-after_deliver
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`around_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-around_deliver
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`before_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-before_deliver
[`ActionMailer::MailHelper`]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html
[MailHelper#mailer]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-mailer
[MailHelper#message]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-message
[`config.action_mailer.sendmail_settings`]: configuring.html#config-action-mailer-sendmail-settings
[`config.action_mailer.smtp_settings`]: configuring.html#config-action-mailer-smtp-settings
