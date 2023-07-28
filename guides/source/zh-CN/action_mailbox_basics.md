**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a547b83b6f036a8e81899330fd515663
Action Mailbox基础知识
=====================

本指南为您提供了开始接收应用程序的电子邮件所需的所有内容。

阅读本指南后，您将了解：

* 如何在Rails应用程序中接收电子邮件。
* 如何配置Action Mailbox。
* 如何生成和路由电子邮件到邮箱。
* 如何测试传入的电子邮件。

--------------------------------------------------------------------------------

什么是Action Mailbox？
-----------------------

Action Mailbox将传入的电子邮件路由到类似控制器的邮箱中，以在Rails中进行处理。它附带了用于Mailgun、Mandrill、Postmark和SendGrid的入口。您还可以通过内置的Exim、Postfix和Qmail入口直接处理传入的邮件。

传入的电子邮件使用Active Record转换为"InboundEmail"记录，并具有生命周期跟踪、通过Active Storage在云存储上存储原始电子邮件以及默认启用的负责任的数据处理。

这些传入的电子邮件使用Active Job异步路由到一个或多个专用邮箱，这些邮箱能够直接与您的域模型的其余部分进行交互。

## 设置

安装所需的"InboundEmail"迁移并确保设置好Active Storage：

```bash
$ bin/rails action_mailbox:install
$ bin/rails db:migrate
```

## 配置

### Exim

告诉Action Mailbox接受来自SMTP中继的电子邮件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

生成一个强密码，Action Mailbox可以使用该密码对中继入口的请求进行身份验证。

使用`bin/rails credentials:edit`将密码添加到应用程序的加密凭据中，位置为`action_mailbox.ingress_password`，Action Mailbox将自动找到它：

```yaml
action_mailbox:
  ingress_password: ...
```

或者，将密码提供给`RAILS_INBOUND_EMAIL_PASSWORD`环境变量。

配置Exim将传入的电子邮件导向`bin/rails action_mailbox:ingress:exim`，提供中继入口的`URL`和之前生成的`INGRESS_PASSWORD`。如果您的应用程序位于`https://example.com`，完整的命令如下所示：

```bash
$ bin/rails action_mailbox:ingress:exim URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun

将您的Mailgun签名密钥（可以在Mailgun的设置->安全性和用户->API安全性下找到）提供给Action Mailbox，以便它可以对Mailgun入口的请求进行身份验证。

使用`bin/rails credentials:edit`将您的签名密钥添加到应用程序的加密凭据中，位置为`action_mailbox.mailgun_signing_key`，Action Mailbox将自动找到它：

```yaml
action_mailbox:
  mailgun_signing_key: ...
```

或者，将您的签名密钥提供给`MAILGUN_INGRESS_SIGNING_KEY`环境变量。

告诉Action Mailbox接受来自Mailgun的电子邮件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mailgun
```

[配置Mailgun](https://documentation.mailgun.com/en/latest/user_manual.html#receiving-forwarding-and-storing-messages)将传入的电子邮件转发到`/rails/action_mailbox/mailgun/inbound_emails/mime`。如果您的应用程序位于`https://example.com`，您将指定完全限定的URL`https://example.com/rails/action_mailbox/mailgun/inbound_emails/mime`。

### Mandrill

将您的Mandrill API密钥提供给Action Mailbox，以便它可以对Mandrill入口的请求进行身份验证。

使用`bin/rails credentials:edit`将您的API密钥添加到应用程序的加密凭据中，位置为`action_mailbox.mandrill_api_key`，Action Mailbox将自动找到它：

```yaml
action_mailbox:
  mandrill_api_key: ...
```

或者，将您的API密钥提供给`MANDRILL_INGRESS_API_KEY`环境变量。

告诉Action Mailbox接受来自Mandrill的电子邮件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mandrill
```

[配置Mandrill](https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview)将传入的电子邮件路由到`/rails/action_mailbox/mandrill/inbound_emails`。如果您的应用程序位于`https://example.com`，您将指定完全限定的URL`https://example.com/rails/action_mailbox/mandrill/inbound_emails`。

### Postfix

告诉Action Mailbox接受来自SMTP中继的电子邮件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

生成一个强密码，Action Mailbox可以使用该密码对中继入口的请求进行身份验证。

使用`bin/rails credentials:edit`将密码添加到应用程序的加密凭据中，位置为`action_mailbox.ingress_password`，Action Mailbox将自动找到它：

```yaml
action_mailbox:
  ingress_password: ...
```

或者，将密码提供给`RAILS_INBOUND_EMAIL_PASSWORD`环境变量。

[配置Postfix](https://serverfault.com/questions/258469/how-to-configure-postfix-to-pipe-all-incoming-email-to-a-script)将传入的电子邮件导向`bin/rails action_mailbox:ingress:postfix`，提供之前生成的Postfix入口的`URL`和`INGRESS_PASSWORD`。如果您的应用程序位于`https://example.com`，完整的命令如下所示：

```bash
$ bin/rails action_mailbox:ingress:postfix URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Postmark

告诉Action Mailbox接受来自Postmark的电子邮件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :postmark
```

生成一个强密码，Action Mailbox可以使用该密码对Postmark入口的请求进行身份验证。

使用`bin/rails credentials:edit`将密码添加到应用程序的加密凭据中，位置为`action_mailbox.ingress_password`，Action Mailbox将自动找到它：

```yaml
action_mailbox:
  ingress_password: ...
```

或者，将密码提供给`RAILS_INBOUND_EMAIL_PASSWORD`环境变量。

[配置Postmark入站Webhook](https://postmarkapp.com/manual#configure-your-inbound-webhook-url)将传入的电子邮件转发到`/rails/action_mailbox/postmark/inbound_emails`，用户名为`actionmailbox`，密码为之前生成的密码。如果您的应用程序位于`https://example.com`，您将使用以下完全限定的URL配置Postmark：
```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/postmark/inbound_emails
```

注意：在配置Postmark入站Webhook时，请确保勾选标有**“在JSON负载中包含原始电子邮件内容”**的框。
Action Mailbox需要原始电子邮件内容才能正常工作。

### Qmail

告诉Action Mailbox从SMTP中继接受电子邮件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

生成一个强密码，用于Action Mailbox对中继入口的请求进行身份验证。

使用`bin/rails credentials:edit`将密码添加到应用程序的加密凭据中，
位置为`action_mailbox.ingress_password`，Action Mailbox将自动找到它：

```yaml
action_mailbox:
  ingress_password: ...
```

或者，将密码提供给`RAILS_INBOUND_EMAIL_PASSWORD`环境变量。

配置Qmail将入站电子邮件导入到`bin/rails action_mailbox:ingress:qmail`，
提供中继入口的`URL`和之前生成的`INGRESS_PASSWORD`。如果您的应用程序位于`https://example.com`，
完整的命令如下所示：

```bash
$ bin/rails action_mailbox:ingress:qmail URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### SendGrid

告诉Action Mailbox从SendGrid接受电子邮件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
```

生成一个强密码，用于Action Mailbox对SendGrid入口的请求进行身份验证。

使用`bin/rails credentials:edit`将密码添加到应用程序的加密凭据中，
位置为`action_mailbox.ingress_password`，Action Mailbox将自动找到它：

```yaml
action_mailbox:
  ingress_password: ...
```

或者，将密码提供给`RAILS_INBOUND_EMAIL_PASSWORD`环境变量。

[配置SendGrid Inbound Parse](https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/)
将入站电子邮件转发到
`/rails/action_mailbox/sendgrid/inbound_emails`，用户名为`actionmailbox`，
密码为之前生成的密码。如果您的应用程序位于`https://example.com`，
您将使用以下URL配置SendGrid：

```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/sendgrid/inbound_emails
```

注意：在配置SendGrid Inbound Parse webhook时，请确保勾选标有**“发布原始的完整MIME消息。”**的框。
Action Mailbox需要原始MIME消息才能正常工作。

## 示例

配置基本路由：

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing(/^save@/i     => :forwards)
  routing(/@replies\./i => :replies)
end
```

然后设置一个邮箱：

```bash
# 生成新的邮箱
$ bin/rails generate mailbox forwards
```

```ruby
# app/mailboxes/forwards_mailbox.rb
class ForwardsMailbox < ApplicationMailbox
  # 回调指定处理的先决条件
  before_processing :require_projects

  def process
    # 在一个项目上记录转发，或者…
    if forwarder.projects.one?
      record_forward
    else
      # …涉及第二个Action Mailer，询问要转发到哪个项目。
      request_forwarding_project
    end
  end

  private
    def require_projects
      if forwarder.projects.none?
        # 使用Action Mailers将传入的电子邮件反弹回发件人 - 这会停止处理
        bounce_with Forwards::BounceMailer.no_projects(inbound_email, forwarder: forwarder)
      end
    end

    def record_forward
      forwarder.forwards.create subject: mail.subject, content: mail.content
    end

    def request_forwarding_project
      Forwards::RoutingMailer.choose_project(inbound_email, forwarder: forwarder).deliver_now
    end

    def forwarder
      @forwarder ||= User.find_by(email_address: mail.from)
    end
end
```

## InboundEmail的销毁

默认情况下，成功处理的InboundEmail将在30天后销毁。
这样可以确保在用户可能取消账户或删除内容后，您不会随意保留他们的数据。
这意味着在处理电子邮件后，您应该提取所需的所有数据并将其转换为应用程序一侧的领域模型和内容。
InboundEmail只是在系统中保留额外的时间以提供调试和取证选项。

实际的销毁是通过预定运行`IncinerationJob`来完成的，
该作业在[`config.action_mailbox.incinerate_after`][]时间后运行。
默认情况下，此值设置为`30.days`，但您可以在production.rb配置文件中进行更改。
（请注意，这种远期销毁调度依赖于您的作业队列能够保持那么长时间的作业。）


## 在开发中使用Action Mailbox

在开发中，能够测试传入的电子邮件而不实际发送和接收真实电子邮件非常有帮助。
为此，有一个控制器挂载在`/rails/conductor/action_mailbox/inbound_emails`，
它提供了系统中所有InboundEmail的索引，它们的处理状态以及创建新InboundEmail的表单。

## 测试邮箱

示例：

```ruby
class ForwardsMailboxTest < ActionMailbox::TestCase
  test "直接为一个项目对应的转发者和被转发者记录客户端转发" do
    assert_difference -> { people(:david).buckets.first.recordings.count } do
      receive_inbound_email_from_mail \
        to: 'save@example.com',
        from: people(:david).email_address,
        subject: "Fwd: Status update?",
        body: <<~BODY
          --- Begin forwarded message ---
          From: Frank Holland <frank@microsoft.com>

          What's the status?
        BODY
    end

    recording = people(:david).buckets.first.recordings.last
    assert_equal people(:david), recording.creator
    assert_equal "Status update?", recording.forward.subject
    assert_match "What's the status?", recording.forward.content.to_s
  end
end
```

请参阅[ActionMailbox::TestHelper API](https://api.rubyonrails.org/classes/ActionMailbox/TestHelper.html)以获取更多测试助手方法。
```
[`config.action_mailbox.incinerate_after`]: configuring.html#config-action-mailbox-incinerate-after
