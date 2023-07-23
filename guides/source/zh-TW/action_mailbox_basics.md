**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a547b83b6f036a8e81899330fd515663
Action Mailbox基礎知識
=====================

本指南提供了一切您需要開始接收應用程式郵件的資訊。

閱讀本指南後，您將了解：

* 如何在Rails應用程式中接收郵件。
* 如何配置Action Mailbox。
* 如何生成和路由郵件到郵箱。
* 如何測試收到的郵件。

--------------------------------------------------------------------------------

什麼是Action Mailbox？
-----------------------

Action Mailbox將傳入的郵件路由到類似控制器的郵箱中，以在Rails中進行處理。它內置了用於Mailgun、Mandrill、Postmark和SendGrid的入口。您還可以通過內置的Exim、Postfix和Qmail入口直接處理傳入郵件。

傳入的郵件使用Active Record轉換為"InboundEmail"記錄，並具有生命週期追踪功能，通過Active Storage將原始郵件存儲在雲存儲中，並具有默認啟用的負責任的數據處理。

這些傳入的郵件使用Active Job異步路由到一個或多個專用郵箱，這些郵箱能夠直接與您的域模型的其餘部分進行交互。

## 設置

安裝所需的"InboundEmail"遷移並確保Active Storage已設置：

```bash
$ bin/rails action_mailbox:install
$ bin/rails db:migrate
```

## 配置

### Exim

告訴Action Mailbox接受來自SMTP中繼的郵件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

生成一個強密碼，Action Mailbox可以使用它來驗證對中繼入口的請求。

使用`bin/rails credentials:edit`將密碼添加到應用程式的加密憑證中，位置在`action_mailbox.ingress_password`下，Action Mailbox將自動找到它：

```yaml
action_mailbox:
  ingress_password: ...
```

或者，將密碼提供給`RAILS_INBOUND_EMAIL_PASSWORD`環境變量。

配置Exim將傳入的郵件導向到`bin/rails action_mailbox:ingress:exim`，並提供中繼入口的`URL`和之前生成的`INGRESS_PASSWORD`。如果您的應用程式位於`https://example.com`，完整的命令如下所示：

```bash
$ bin/rails action_mailbox:ingress:exim URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun

提供Action Mailbox您的Mailgun簽名密鑰（您可以在Mailgun的"Settings -> Security & Users -> API security"下找到）以便它可以驗證對Mailgun入口的請求。

使用`bin/rails credentials:edit`將您的簽名密鑰添加到應用程式的加密憑證中，位置在`action_mailbox.mailgun_signing_key`下，Action Mailbox將自動找到它：

```yaml
action_mailbox:
  mailgun_signing_key: ...
```

或者，將您的簽名密鑰提供給`MAILGUN_INGRESS_SIGNING_KEY`環境變量。

告訴Action Mailbox接受來自Mailgun的郵件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mailgun
```

[配置Mailgun](https://documentation.mailgun.com/en/latest/user_manual.html#receiving-forwarding-and-storing-messages)將傳入的郵件轉發到`/rails/action_mailbox/mailgun/inbound_emails/mime`。如果您的應用程式位於`https://example.com`，您將指定完整的URL`https://example.com/rails/action_mailbox/mailgun/inbound_emails/mime`。

### Mandrill

提供Action Mailbox您的Mandrill API金鑰，以便它可以驗證對Mandrill入口的請求。

使用`bin/rails credentials:edit`將您的API金鑰添加到應用程式的加密憑證中，位置在`action_mailbox.mandrill_api_key`下，Action Mailbox將自動找到它：

```yaml
action_mailbox:
  mandrill_api_key: ...
```

或者，將您的API金鑰提供給`MANDRILL_INGRESS_API_KEY`環境變量。

告訴Action Mailbox接受來自Mandrill的郵件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mandrill
```

[配置Mandrill](https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview)將傳入的郵件路由到`/rails/action_mailbox/mandrill/inbound_emails`。如果您的應用程式位於`https://example.com`，您將指定完整的URL`https://example.com/rails/action_mailbox/mandrill/inbound_emails`。

### Postfix

告訴Action Mailbox接受來自SMTP中繼的郵件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

生成一個強密碼，Action Mailbox可以使用它來驗證對中繼入口的請求。

使用`bin/rails credentials:edit`將密碼添加到應用程式的加密憑證中，位置在`action_mailbox.ingress_password`下，Action Mailbox將自動找到它：

```yaml
action_mailbox:
  ingress_password: ...
```

或者，將密碼提供給`RAILS_INBOUND_EMAIL_PASSWORD`環境變量。

[配置Postfix](https://serverfault.com/questions/258469/how-to-configure-postfix-to-pipe-all-incoming-email-to-a-script)將傳入的郵件導向到`bin/rails action_mailbox:ingress:postfix`，並提供Postfix入口的`URL`和之前生成的`INGRESS_PASSWORD`。如果您的應用程式位於`https://example.com`，完整的命令如下所示：

```bash
$ bin/rails action_mailbox:ingress:postfix URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Postmark

告訴Action Mailbox接受來自Postmark的郵件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :postmark
```

生成一個強密碼，Action Mailbox可以使用它來驗證對Postmark入口的請求。

使用`bin/rails credentials:edit`將密碼添加到應用程式的加密憑證中，位置在`action_mailbox.ingress_password`下，Action Mailbox將自動找到它：

```yaml
action_mailbox:
  ingress_password: ...
```

或者，將密碼提供給`RAILS_INBOUND_EMAIL_PASSWORD`環境變量。

[配置Postmark入站webhook](https://postmarkapp.com/manual#configure-your-inbound-webhook-url)將傳入的郵件轉發到`/rails/action_mailbox/postmark/inbound_emails`，並使用用戶名`actionmailbox`和之前生成的密碼。如果您的應用程式位於`https://example.com`，您將使用以下完整的URL配置Postmark：
```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/postmark/inbound_emails
```

注意：在配置Postmark入站Webhook時，請務必勾選標記為**“在JSON有效載荷中包含原始電子郵件內容”**。
Action Mailbox需要原始電子郵件內容才能正常運作。

### Qmail

告訴Action Mailbox接受來自SMTP中繼的電子郵件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

生成一個強密碼，Action Mailbox可以用來驗證對中繼入口的請求。

使用`bin/rails credentials:edit`將密碼添加到應用程序的加密憑據中，
位置為`action_mailbox.ingress_password`，Action Mailbox會自動找到它：

```yaml
action_mailbox:
  ingress_password: ...
```

或者，將密碼提供給`RAILS_INBOUND_EMAIL_PASSWORD`環境變量。

配置Qmail將入站電子郵件導向到`bin/rails action_mailbox:ingress:qmail`，
提供中繼入口的`URL`和之前生成的`INGRESS_PASSWORD`。
如果您的應用程序位於`https://example.com`，完整的命令如下所示：

```bash
$ bin/rails action_mailbox:ingress:qmail URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### SendGrid

告訴Action Mailbox接受來自SendGrid的電子郵件：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
```

生成一個強密碼，Action Mailbox可以用來驗證對SendGrid入口的請求。

使用`bin/rails credentials:edit`將密碼添加到應用程序的加密憑據中，
位置為`action_mailbox.ingress_password`，Action Mailbox會自動找到它：

```yaml
action_mailbox:
  ingress_password: ...
```

或者，將密碼提供給`RAILS_INBOUND_EMAIL_PASSWORD`環境變量。

[配置SendGrid Inbound Parse](https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/)
將入站電子郵件轉發到`/rails/action_mailbox/sendgrid/inbound_emails`，
使用用戶名`actionmailbox`和之前生成的密碼。如果您的應用程序位於`https://example.com`，
您將使用以下URL配置SendGrid：

```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/sendgrid/inbound_emails
```

注意：在配置SendGrid Inbound Parse webhook時，請務必勾選標記為**“發布原始的完整MIME郵件。”** Action Mailbox需要原始MIME郵件才能正常運作。

## 示例

配置基本路由：

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing(/^save@/i     => :forwards)
  routing(/@replies\./i => :replies)
end
```

然後設置一個郵箱：

```bash
# 生成新的郵箱
$ bin/rails generate mailbox forwards
```

```ruby
# app/mailboxes/forwards_mailbox.rb
class ForwardsMailbox < ApplicationMailbox
  # Callbacks specify prerequisites to processing
  before_processing :require_projects

  def process
    # Record the forward on the one project, or…
    if forwarder.projects.one?
      record_forward
    else
      # …involve a second Action Mailer to ask which project to forward into.
      request_forwarding_project
    end
  end

  private
    def require_projects
      if forwarder.projects.none?
        # Use Action Mailers to bounce incoming emails back to sender – this halts processing
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

## InboundEmail的銷毀

默認情況下，成功處理的InboundEmail將在30天後被銷毀。
這樣可以確保在用戶可能取消帳戶或刪除內容後，您不會隨意保留他們的數據。
這意味著在處理電子郵件後，您應該提取所有所需的數據並將其轉換為應用程序端的域模型和內容。
InboundEmail只是在系統中保留額外的時間以提供調試和取證選項。

實際的銷毀是通過`IncinerationJob`完成的，該作業在[`config.action_mailbox.incinerate_after`][]時間後運行。
默認情況下，此值設置為`30.days`，但您可以在production.rb配置文件中更改它。
（請注意，這種遠期銷毀排程依賴於您的作業隊列能夠保留作業那麼長的時間。）

## 在開發中使用Action Mailbox

在開發中，測試傳入的電子郵件而不實際發送和接收真實的電子郵件是很有幫助的。
為此，有一個控制器掛載在`/rails/conductor/action_mailbox/inbound_emails`，
它提供了系統中所有InboundEmail的索引，它們的處理狀態以及創建新InboundEmail的表單。

## 測試郵箱

示例：

```ruby
class ForwardsMailboxTest < ActionMailbox::TestCase
  test "directly recording a client forward for a forwarder and forwardee corresponding to one project" do
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

請參考[ActionMailbox::TestHelper API](https://api.rubyonrails.org/classes/ActionMailbox/TestHelper.html)以獲取更多測試輔助方法。
```
[`config.action_mailbox.incinerate_after`]: configuring.html#config-action-mailbox-incinerate-after
