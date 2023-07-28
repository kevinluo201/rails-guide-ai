**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 390d20a8bee6232c0ffa7faeb0e9d8e8
Action Mailer基础知识
====================

本指南为您提供了一切开始从应用程序发送电子邮件所需的内容，以及Action Mailer的许多内部知识。它还涵盖了如何测试您的邮件发送器。

阅读本指南后，您将了解：

* 如何在Rails应用程序中发送电子邮件。
* 如何生成和编辑Action Mailer类和邮件发送器视图。
* 如何为您的环境配置Action Mailer。
* 如何测试您的Action Mailer类。

--------------------------------------------------------------------------------

什么是Action Mailer？
----------------------

Action Mailer允许您使用邮件发送器类和视图从应用程序发送电子邮件。

### 邮件发送器类类似于控制器

它们继承自[`ActionMailer::Base`][]，并位于`app/mailers`目录中。邮件发送器类的工作方式也与控制器非常相似。以下是一些相似之处的示例。邮件发送器类具有：

* 动作，以及在`app/views`中显示的相关视图。
* 在视图中可访问的实例变量。
* 使用布局和局部视图的能力。
* 访问params哈希的能力。


发送电子邮件
--------------

本节将提供逐步指南，以创建一个邮件发送器及其视图。

### 生成邮件发送器的步骤

#### 创建邮件发送器

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

如您所见，您可以像使用其他Rails生成器一样生成邮件发送器。

如果您不想使用生成器，您可以在`app/mailers`中创建自己的文件，只需确保它继承自`ActionMailer::Base`：

```ruby
class MyMailer < ActionMailer::Base
end
```

#### 编辑邮件发送器

邮件发送器具有称为“动作”的方法，并使用视图来组织其内容。控制器生成HTML等内容以发送回客户端，而邮件发送器则创建一条通过电子邮件发送的消息。
`app/mailers/user_mailer.rb` 包含一个空的邮件发送器：

```ruby
class UserMailer < ApplicationMailer
end
```

让我们添加一个名为 `welcome_email` 的方法，用于向用户的注册邮箱发送邮件：

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: '欢迎来到我的网站')
  end
end
```

下面是对上述方法中的项目的简要解释。有关所有可用选项的完整列表，请查看下面的完整的 Action Mailer 用户可设置属性列表部分。

* [`default`][] 方法为此邮件发送器中发送的所有邮件设置默认值。在这种情况下，我们使用它来为此类中的所有消息设置 `:from` 标头的值。这可以在每个邮件的基础上进行覆盖。
* [`mail`][] 方法创建实际的电子邮件消息。我们使用它来指定每个邮件的 `:to` 和 `:subject` 等标头的值。


#### 创建一个邮件模板视图

在 `app/views/user_mailer/` 中创建一个名为 `welcome_email.html.erb` 的文件。这将是用于电子邮件的模板，以 HTML 格式化：

```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>欢迎来到 example.com，<%= @user.name %></h1>
    <p>
      您已成功注册 example.com，
      您的用户名是： <%= @user.login %>。<br>
    </p>
    <p>
      要登录网站，请点击此链接： <%= @url %>。
    </p>
    <p>感谢您的加入，祝您有美好的一天！</p>
  </body>
</html>
```

我们还要为此电子邮件创建一个纯文本部分。并非所有客户端都喜欢 HTML 邮件，因此发送两者是最佳实践。为此，请在 `app/views/user_mailer/` 中创建一个名为 `welcome_email.text.erb` 的文件：

```erb
欢迎来到 example.com，<%= @user.name %>
===============================================

您已成功注册 example.com，
您的用户名是： <%= @user.login %>。

要登录网站，请点击此链接： <%= @url %>。

感谢您的加入，祝您有美好的一天！
```
当您现在调用`mail`方法时，Action Mailer将检测到两个模板（文本和HTML），并自动生成一个`multipart/alternative`邮件。

#### 调用 Mailer

Mailer实际上只是另一种渲染视图的方式。它们不是通过HTTP协议渲染视图并发送，而是通过电子邮件协议发送。因此，当成功创建用户时，让控制器告诉Mailer发送电子邮件是有意义的。

设置这个很简单。

首先，让我们创建一个`User`脚手架：

```bash
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

现在我们有一个可以使用的用户模型，我们将编辑`app/controllers/users_controller.rb`文件，通过编辑create操作并在用户成功保存后插入一个调用`UserMailer.with(user: @user).welcome_email`的方式，来指示`UserMailer`向新创建的用户发送电子邮件。

我们将使用[`deliver_later`][]将电子邮件加入发送队列，它是由Active Job支持的。这样，控制器操作可以继续进行，而不需要等待发送完成。

```ruby
class UsersController < ApplicationController
  # ...

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # 告诉UserMailer在保存后发送欢迎电子邮件
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

注意：Active Job的默认行为是通过`：async`适配器执行作业。因此，您可以使用`deliver_later`异步发送电子邮件。Active Job的默认适配器使用进程内线程池运行作业。它非常适合开发/测试环境，因为它不需要任何外部基础设施，但它不适合生产环境，因为它在重新启动时会丢弃待处理的作业。如果您需要持久的后端，您需要使用具有持久后端的Active Job适配器（如Sidekiq、Resque等）。
如果您想立即发送电子邮件（例如从cronjob），只需调用[`deliver_now`][]：

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```

传递给[`with`][]的任何键值对都将成为邮件动作的`params`。因此，`with(user: @user, account: @user.account)`将使`params[:user]`和`params[:account]`在邮件动作中可用。就像控制器有params一样。

`welcome_email`方法返回一个[`ActionMailer::MessageDelivery`][]对象，然后可以告诉它`deliver_now`或`deliver_later`以发送自身。`ActionMailer::MessageDelivery`对象是[`Mail::Message`][]的包装器。如果您想检查、更改或对`Mail::Message`对象执行其他操作，可以使用`ActionMailer::MessageDelivery`对象上的[`message`][]方法访问它。

### 自动编码标题值

Action Mailer处理标题和正文中的多字节字符的自动编码。

有关更复杂的示例，例如定义替代字符集或首先进行自编码文本，请参阅[Mail](https://github.com/mikel/mail)库。

### Action Mailer方法的完整列表

您只需要使用三个方法就可以发送几乎任何电子邮件消息：

* [`headers`][] - 指定您想要的电子邮件上的任何标题。您可以传递一个标题字段名称和值对的哈希，或者您可以调用`headers[:field_name] = 'value'`。
* [`attachments`][] - 允许您向电子邮件添加附件。例如，`attachments['file-name.jpg'] = File.read('file-name.jpg')`。
* [`mail`][] - 创建实际的电子邮件本身。您可以将标题作为哈希传递给`mail`方法作为参数。`mail`将根据您定义的电子邮件模板创建电子邮件 - 纯文本或多部分。

#### 添加附件

Action Mailer非常容易添加附件。

* 传递文件名和内容给Action Mailer和[Mail gem](https://github.com/mikel/mail)，它将自动猜测`mime_type`，设置`encoding`并创建附件。
```ruby
attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
```

当触发`mail`方法时，它将发送一个带有附件的多部分电子邮件，顶层为`multipart/mixed`，第一部分为包含纯文本和HTML电子邮件消息的`multipart/alternative`。

注意：Mail将自动对附件进行Base64编码。如果您想要其他内容，请对内容进行编码，并将编码后的内容和编码传递给`attachments`方法的`Hash`。

* 传递文件名并指定标题和内容，Action Mailer和Mail将使用您传递的设置。

```ruby
encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
attachments['filename.jpg'] = {
  mime_type: 'application/gzip',
  encoding: 'SpecialEncoding',
  content: encoded_content
}
```

注意：如果您指定了编码，Mail将假定您的内容已经编码，并且不会尝试对其进行Base64编码。

#### 创建内联附件

Action Mailer 3.0使内联附件（在3.0之前的版本中需要进行大量的修改）变得更简单和轻松，正如它们应该的那样。

* 首先，要告诉Mail将附件转换为内联附件，只需在Mailer中的attachments方法上调用`#inline`：

```ruby
def welcome
  attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
end
```

* 然后在视图中，您可以将`attachments`作为哈希引用，并指定要显示的附件，调用其上的`url`，然后将结果传递给`image_tag`方法：

```html+erb
<p>Hello there, this is our image</p>

<%= image_tag attachments['image.jpg'].url %>
```

* 由于这是对`image_tag`的标准调用，您可以在附件URL之后传递一个选项哈希，就像对任何其他图像一样：

```html+erb
<p>Hello there, this is our image</p>

<%= image_tag attachments['image.jpg'].url, alt: 'My Photo', class: 'photos' %>
```

#### 发送邮件给多个收件人

可以在一封电子邮件中向一个或多个收件人发送邮件（例如，通知所有管理员有新的注册），方法是将电子邮件列表设置为`:to`键。电子邮件列表可以是一个包含电子邮件地址的数组，也可以是一个用逗号分隔的地址的字符串。
```ruby
class AdminMailer < ApplicationMailer
  default to: -> { Admin.pluck(:email) },
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "新用户注册: #{@user.email}")
  end
end
```

可以使用相同的格式来设置抄送（Cc:）和密件抄送（Bcc:）收件人，分别使用`:cc`和`:bcc`键。

#### 带有名称的发送邮件

有时候，当收件人收到邮件时，您希望显示该人的名称而不仅仅是他们的电子邮件地址。您可以使用[`email_address_with_name`][]来实现：

```ruby
def welcome_email
  @user = params[:user]
  mail(
    to: email_address_with_name(@user.email, @user.name),
    subject: '欢迎来到我的超棒网站'
  )
end
```

相同的技术也适用于指定发件人名称：

```ruby
class UserMailer < ApplicationMailer
  default from: email_address_with_name('notification@example.com', 'Example Company Notifications')
end
```

如果名称为空字符串，则只返回地址。


### 邮件视图

邮件视图位于`app/views/name_of_mailer_class`目录中。邮件视图之所以被类所知，是因为它的名称与邮件方法相同。在上面的示例中，`welcome_email`方法的邮件视图将位于`app/views/user_mailer/welcome_email.html.erb`（HTML版本）和`welcome_email.text.erb`（纯文本版本）中。

要更改操作的默认邮件视图，可以执行以下操作：

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: '欢迎来到我的超棒网站',
         template_path: 'notifications',
         template_name: 'another')
  end
end
```

在这种情况下，它将在`app/views/notifications`目录下查找名称为`another`的模板。您还可以为`template_path`指定一个路径数组，它们将按顺序进行搜索。

如果您想要更多的灵活性，还可以传递一个块并渲染特定的模板，甚至可以渲染内联或文本，而无需使用模板文件：

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: '欢迎来到我的超棒网站') do |format|
      format.html { render 'another_template' }
      format.text { render plain: '渲染文本' }
    end
  end
end
```
这将为HTML部分渲染模板'another_template.html.erb'，并使用渲染后的文本作为文本部分。渲染命令与Action Controller中使用的相同，因此您可以使用所有相同的选项，例如`:text`，`:inline`等。

如果您想要渲染位于默认的`app/views/mailer_name/`目录之外的模板，可以使用[`prepend_view_path`][]，如下所示：

```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # 这将尝试加载"custom/path/to/mailer/view/welcome_email"模板
  def welcome_email
    # ...
  end
end
```

您还可以考虑使用[`append_view_path`][]方法。


#### 缓存Mailer视图

您可以像在应用程序视图中一样，在Mailer视图中使用[`cache`][]方法进行片段缓存。

```html+erb
<% cache do %>
  <%= @company.name %>
<% end %>
```

要使用此功能，您需要使用以下配置应用程序：

```ruby
config.action_mailer.perform_caching = true
```

片段缓存也支持多部分邮件。有关缓存的更多信息，请阅读[Rails缓存指南](caching_with_rails.html)。


### Action Mailer布局

就像控制器视图一样，您也可以拥有Mailer布局。布局名称需要与您的Mailer相同，例如`user_mailer.html.erb`和`user_mailer.text.erb`，以便被您的Mailer自动识别为布局。

要使用不同的文件，请在您的Mailer中调用[`layout`][]：

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # 使用awesome.(html|text).erb作为布局
end
```

就像控制器视图一样，使用`yield`在布局中渲染视图。

您还可以在格式块内的渲染调用中传递`layout: 'layout_name'`选项，以指定不同格式的不同布局：

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

如果存在的话，将使用`my_layout.html.erb`文件渲染HTML部分，并使用通常的`user_mailer.text.erb`文件渲染文本部分。
### 预览邮件

Action Mailer 预览提供了一种通过访问特殊的 URL 来查看邮件外观的方式。在上面的示例中，`UserMailer` 的预览类应该被命名为 `UserMailerPreview`，并且位于 `test/mailers/previews/user_mailer_preview.rb` 文件中。要查看 `welcome_email` 的预览，请实现一个同名的方法并调用 `UserMailer.welcome_email`：

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

然后，预览将在 <http://localhost:3000/rails/mailers/user_mailer/welcome_email> 上可用。

如果你在 `app/views/user_mailer/welcome_email.html.erb` 或邮件本身中进行了更改，它将自动重新加载和渲染，以便你可以立即看到新的样式。预览列表也可以在 <http://localhost:3000/rails/mailers> 上找到。

默认情况下，这些预览类位于 `test/mailers/previews` 目录下。可以使用 `preview_paths` 选项进行配置。例如，如果你想要将 `lib/mailer_previews` 添加到其中，可以在 `config/application.rb` 中进行配置：

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### 在 Action Mailer 视图中生成 URL

与控制器不同，邮件实例没有关于传入请求的任何上下文，因此你需要自己提供 `:host` 参数。

由于 `:host` 通常在整个应用程序中是一致的，你可以在 `config/application.rb` 中全局配置它：

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```

由于这种行为，你不能在邮件中使用任何 `*_path` 辅助方法。相反，你需要使用相关的 `*_url` 辅助方法。例如，不要使用：

```html+erb
<%= link_to 'welcome', welcome_path %>
```

而是需要使用：

```html+erb
<%= link_to 'welcome', welcome_url %>
```

通过使用完整的 URL，你的链接现在将在邮件中起作用。

#### 使用 `url_for` 生成 URL

[`url_for`][] 在模板中默认生成完整的 URL。

如果你没有全局配置 `:host` 选项，请确保将其传递给 `url_for`。

```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```
#### 使用命名路由生成URL

电子邮件客户端没有Web上下文，因此路径没有基本URL来形成完整的Web地址。因此，您应该始终使用命名路由助手的`*_url`变体。

如果您没有全局配置`：host`选项，请确保将其传递给URL助手。

```erb
<%= user_url(@user, host: 'example.com') %>
```

注意：非`GET`链接需要[rails-ujs](https://github.com/rails/rails/blob/main/actionview/app/assets/javascripts)或[jQuery UJS](https://github.com/rails/jquery-ujs)，并且在邮件模板中无法工作。它们将导致正常的`GET`请求。

### 在Action Mailer视图中添加图像

与控制器不同，邮件实例没有关于传入请求的任何上下文，因此您需要自己提供`：asset_host`参数。

由于`：asset_host`通常在整个应用程序中保持一致，您可以在`config/application.rb`中全局配置它：

```ruby
config.asset_host = 'http://example.com'
```

现在，您可以在电子邮件中显示图像。

```html+erb
<%= image_tag 'image.jpg' %>
```

### 发送多部分邮件

如果对于同一个操作有不同的模板，Action Mailer将自动发送多部分邮件。因此，对于我们的`UserMailer`示例，如果在`app/views/user_mailer`中有`welcome_email.text.erb`和`welcome_email.html.erb`，Action Mailer将自动发送一个多部分邮件，并将HTML和文本版本设置为不同的部分。

插入部分的顺序由`ActionMailer::Base.default`方法中的`:parts_order`确定。

### 使用动态传递选项发送电子邮件

如果您希望在发送电子邮件时覆盖默认的传递选项（例如SMTP凭据），可以在邮件操作中使用`delivery_method_options`来实现。

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = user_url(@user)
    delivery_options = { user_name: params[:company].smtp_user,
                         password: params[:company].smtp_password,
                         address: params[:company].smtp_host }
    mail(to: @user.email,
         subject: "请查看附带的条款和条件",
         delivery_method_options: delivery_options)
  end
end
```

### 发送没有模板渲染的电子邮件

可能有情况下，您希望跳过模板渲染步骤，并将电子邮件正文作为字符串提供。您可以使用`：body`选项来实现这一点。在这种情况下，请不要忘记添加`：content_type`选项。否则，Rails将默认为`text/plain`。
```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email,
         body: params[:email_body],
         content_type: "text/html",
         subject: "已经渲染！")
  end
end
```

Action Mailer 回调
-----------------------

Action Mailer 允许您指定 [`before_action`][], [`after_action`][] 和 [`around_action`][] 来配置消息，以及 [`before_deliver`][], [`after_deliver`][] 和 [`around_deliver`][] 来控制传递。

* 回调可以使用块或邮件类中的方法符号来指定，类似于控制器。

* 您可以使用 `before_action` 来设置实例变量，使用默认值填充邮件对象，或插入默认标头和附件。

```ruby
class InvitationsMailer < ApplicationMailer
  before_action :set_inviter_and_invitee
  before_action { @account = params[:inviter].account }

  default to:       -> { @invitee.email_address },
          from:     -> { common_address(@inviter) },
          reply_to: -> { @inviter.email_address_with_name }

  def account_invitation
    mail subject: "#{@inviter.name} 邀请您加入他们的 Basecamp（#{@account.name})"
  end

  def project_invitation
    @project    = params[:project]
    @summarizer = ProjectInvitationSummarizer.new(@project.bucket)

    mail subject: "#{@inviter.name.familiar} 邀请您加入 Basecamp 中的项目（#{@account.name})"
  end

  private
    def set_inviter_and_invitee
      @inviter = params[:inviter]
      @invitee = params[:invitee]
    end
end
```

* 您可以使用 `after_action` 来执行与 `before_action` 类似的设置，但使用在邮件动作中设置的实例变量。

* 使用 `after_action` 回调还可以通过更新 `mail.delivery_method.settings` 来覆盖传递方法设置。

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
      # 在此处您可以访问邮件实例、@business 和 @user 实例变量
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

* 您可以使用 `after_delivery` 来记录消息的传递。

* 如果将 body 设置为非 nil 值，则邮件回调会中止进一步处理。`before_deliver` 可以使用 `throw :abort` 中止。
使用Action Mailer Helpers
---------------------------

Action Mailer继承自`AbstractController`，因此您可以像在Action Controller中一样访问大多数相同的辅助方法。

还有一些Action Mailer特定的辅助方法可在[`ActionMailer::MailHelper`][]中使用。例如，这些方法允许您在视图中使用[`mailer`][MailHelper#mailer]访问邮件实例，并使用[`message`][MailHelper#message]访问消息：

```erb
<%= stylesheet_link_tag mailer.name.underscore %>
<h1><%= message.subject %></h1>
```


Action Mailer配置
---------------------------

以下配置选项最好在环境文件（environment.rb，production.rb等）中进行设置。

| 配置 | 描述 |
|---------------|-------------|
|`logger`|如果可用，生成有关邮件运行的信息。可以将其设置为`nil`以禁用日志记录。与Ruby自带的`Logger`和`Log4r`日志记录器兼容。|
|`smtp_settings`|允许对`:smtp`传递方式进行详细配置：<ul><li>`:address` - 允许您使用远程邮件服务器。只需将其从默认的`"localhost"`设置更改即可。</li><li>`:port` - 如果您的邮件服务器不在25号端口上运行，可以进行更改。</li><li>`:domain` - 如果需要指定HELO域，可以在此处进行设置。</li><li>`:user_name` - 如果您的邮件服务器需要身份验证，请在此设置中设置用户名。</li><li>`:password` - 如果您的邮件服务器需要身份验证，请在此设置中设置密码。</li><li>`:authentication` - 如果您的邮件服务器需要身份验证，您需要在此处指定身份验证类型。这是一个符号，可以是`:plain`（以明文发送密码），`:login`（以Base64编码发送密码）或`:cram_md5`（将挑战/响应机制与密码哈希的密码学消息摘要5算法相结合）。</li><li>`:enable_starttls` - 在连接到SMTP服务器时使用STARTTLS，并在不支持时失败。默认为`false`。</li><li>`:enable_starttls_auto` - 检测SMTP服务器中是否启用了STARTTLS，并开始使用它。默认为`true`。</li><li>`:openssl_verify_mode` - 在使用TLS时，您可以设置OpenSSL如何检查证书。如果需要验证自签名和/或通配符证书，这非常有用。您可以使用OpenSSL验证常量的名称（'none'或'peer'）或直接使用常量（`OpenSSL::SSL::VERIFY_NONE`或`OpenSSL::SSL::VERIFY_PEER`）。</li><li>`:ssl/:tls` - 启用SMTP连接使用SMTP/TLS（SMTPS：SMTP通过直接TLS连接）</li><li>`:open_timeout` - 尝试打开连接时等待的秒数。</li><li>`:read_timeout` - 等待超时的秒数，直到读取（2）调用。</li></ul>|
|`sendmail_settings`|允许您覆盖`：sendmail`传递方式的选项。<ul><li>`:location` - sendmail可执行文件的位置。默认为`/usr/sbin/sendmail`。</li><li>`:arguments` - 要传递给sendmail的命令行参数。默认为`["-i"]`。</li></ul>|
|`raise_delivery_errors`|如果电子邮件发送失败，是否应该引发错误。仅在外部电子邮件服务器配置为立即传递时有效。默认为`true`。|
|`delivery_method`|定义传递方式。可能的值为：<ul><li>`:smtp`（默认），可以通过使用[`config.action_mailer.smtp_settings`][]进行配置。</li><li>`:sendmail`，可以通过使用[`config.action_mailer.sendmail_settings`][]进行配置。</li><li>`:file`：将电子邮件保存到文件中；可以通过使用`config.action_mailer.file_settings`进行配置。</li><li>`:test`：将电子邮件保存到`ActionMailer::Base.deliveries`数组中。</li></ul>有关更多信息，请参阅[API文档](https://api.rubyonrails.org/classes/ActionMailer/Base.html)。|
|`perform_deliveries`|确定在调用Mail消息的`deliver`方法时是否实际执行传递。默认情况下，会执行传递，但可以关闭以帮助功能测试。如果此值为`false`，即使`delivery_method`为`:test`，`deliveries`数组也不会被填充。|
|`deliveries`|保留通过Action Mailer使用`：test`传递方式发送的所有电子邮件的数组。对于单元测试和功能测试非常有用。|
|`delivery_job`|与`deliver_later`一起使用的作业类。默认为`ActionMailer::MailDeliveryJob`。|
|`deliver_later_queue_name`|与默认`delivery_job`一起使用的队列的名称。默认为默认的Active Job队列。|
|`default_options`|允许您为`mail`方法选项（`:from`，`:reply_to`等）设置默认值。|
有关可能配置的完整写作，请参阅我们的《配置Rails应用程序指南》中的[配置Action Mailer](configuring.html#configuring-action-mailer)部分。

### Action Mailer配置示例

例如，将以下内容添加到适当的`config/environments/$RAILS_ENV.rb`文件中：

```ruby
config.action_mailer.delivery_method = :sendmail
# 默认值为：
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: %w[ -i ]
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = { from: 'no-reply@example.com' }
```

### Gmail的Action Mailer配置

Action Mailer使用[Mail gem](https://github.com/mikel/mail)并接受类似的配置。将以下内容添加到`config/environments/$RAILS_ENV.rb`文件中以通过Gmail发送邮件：

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

如果您使用的是旧版本的Mail gem（2.6.x或更早版本），请使用`enable_starttls_auto`而不是`enable_starttls`。

注意：Google会[阻止](https://support.google.com/accounts/answer/6010255)来自其认为不安全的应用程序的登录。您可以在[此处](https://www.google.com/settings/security/lesssecureapps)更改Gmail设置以允许尝试登录。如果您的Gmail帐户启用了两步验证，则需要设置一个[应用程序密码](https://myaccount.google.com/apppasswords)并使用该密码代替常规密码。

邮件发送测试
--------------

您可以在[测试指南](testing.html#testing-your-mailers)中找到有关如何测试邮件发送的详细说明。

拦截和观察邮件
-------------------

Action Mailer提供了对Mail观察者和拦截器方法的钩子。这些方法允许您注册在每封发送的电子邮件的邮件传递生命周期中调用的类。

### 拦截邮件

拦截器允许您在将电子邮件交给传递代理之前对其进行修改。拦截器类必须实现`::delivering_email(message)`方法，在发送电子邮件之前将调用该方法。

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

在拦截器能够发挥作用之前，您需要使用`interceptors`配置选项进行注册。您可以在初始化文件（例如`config/initializers/mail_interceptors.rb`）中执行此操作。
```ruby
Rails.application.configure do
  if Rails.env.staging?
    config.action_mailer.interceptors = %w[SandboxEmailInterceptor]
  end
end
```

注意：上面的示例使用了一个名为“staging”的自定义环境，用于类似生产环境但用于测试目的的服务器。您可以阅读[创建Rails环境](configuring.html#creating-rails-environments)以获取有关自定义Rails环境的更多信息。

### 观察邮件

观察者允许您在邮件发送后访问邮件消息。观察者类必须实现`:delivered_email(message)`方法，在邮件发送后将被调用。

```ruby
class EmailDeliveryObserver
  def self.delivered_email(message)
    EmailDelivery.log(message)
  end
end
```

与拦截器类似，您必须使用`observers`配置选项注册观察者。
您可以在初始化文件中进行此操作，例如`config/initializers/mail_observers.rb`：

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
