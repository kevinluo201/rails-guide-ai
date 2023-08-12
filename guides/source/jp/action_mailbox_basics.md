**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a547b83b6f036a8e81899330fd515663
Action Mailboxの基本
=====================

このガイドでは、アプリケーションでメールを受信するために必要なすべての情報を提供します。

このガイドを読み終えると、以下のことがわかります。

* Railsアプリケーション内でメールを受信する方法
* Action Mailboxの設定方法
* メールを生成してメールボックスにルーティングする方法
* 受信メールのテスト方法

--------------------------------------------------------------------------------

Action Mailboxとは何ですか？
-----------------------

Action Mailboxは、Railsで処理するために、コントローラのようなメールボックスに受信メールをルーティングします。Mailgun、Mandrill、Postmark、SendGrid用のイングレスが付属しています。また、組み込みのExim、Postfix、Qmailイングレスを使用して直接受信メールを処理することもできます。

受信メールは、Active Recordを使用して`InboundEmail`レコードに変換され、ライフサイクルのトラッキング、オリジナルのメールのクラウドストレージへの保存（Active Storageを使用）、データの責任ある処理などの機能が備わっています。

これらの受信メールは、Active Jobを使用して非同期に1つまたは複数の専用のメールボックスにルーティングされ、そのメールボックスは直接ドメインモデルの他の部分と対話することができます。

## セットアップ

`InboundEmail`に必要なマイグレーションをインストールし、Active Storageが設定されていることを確認します。

```bash
$ bin/rails action_mailbox:install
$ bin/rails db:migrate
```

## 設定

### Exim

Action MailboxがSMTPリレーからメールを受け入れるように指示します。

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Action Mailboxがリレーイングレスへのリクエストを認証するために使用できる強力なパスワードを生成します。

`bin/rails credentials:edit`を使用して、パスワードをアプリケーションの暗号化された資格情報の`action_mailbox.ingress_password`の下に追加します。Action Mailboxは自動的にそれを見つけます。

```yaml
action_mailbox:
  ingress_password: ...
```

または、`RAILS_INBOUND_EMAIL_PASSWORD`環境変数でパスワードを指定します。

Eximを設定して、インバウンドメールを`bin/rails action_mailbox:ingress:exim`にパイプします。リレーイングレスの`URL`と先ほど生成した`INGRESS_PASSWORD`を指定します。アプリケーションが`https://example.com`に存在する場合、完全なコマンドは次のようになります。

```bash
$ bin/rails action_mailbox:ingress:exim URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun

Action MailboxにMailgunの署名キー（Mailgunの設定->セキュリティとユーザー->APIセキュリティの下で見つけることができます）を提供して、Mailgunイングレスへのリクエストを認証できるようにします。

`bin/rails credentials:edit`を使用して、署名キーをアプリケーションの暗号化された資格情報の`action_mailbox.mailgun_signing_key`の下に追加します。Action Mailboxは自動的にそれを見つけます。

```yaml
action_mailbox:
  mailgun_signing_key: ...
```

または、`MAILGUN_INGRESS_SIGNING_KEY`環境変数で署名キーを指定します。

Action MailboxがMailgunからのメールを受け入れるように指示します。

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mailgun
```

[Mailgunを設定](https://documentation.mailgun.com/en/latest/user_manual.html#receiving-forwarding-and-storing-messages)して、インバウンドメールを`/rails/action_mailbox/mailgun/inbound_emails/mime`に転送します。アプリケーションが`https://example.com`に存在する場合、完全修飾URL `https://example.com/rails/action_mailbox/mailgun/inbound_emails/mime` を指定します。

### Mandrill

Action MailboxにMandrillのAPIキーを提供して、Mandrillイングレスへのリクエストを認証できるようにします。

`bin/rails credentials:edit`を使用して、APIキーをアプリケーションの暗号化された資格情報の`action_mailbox.mandrill_api_key`の下に追加します。Action Mailboxは自動的にそれを見つけます。

```yaml
action_mailbox:
  mandrill_api_key: ...
```

または、`MANDRILL_INGRESS_API_KEY`環境変数でAPIキーを指定します。

Action MailboxがMandrillからのメールを受け入れるように指示します。

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mandrill
```

[Mandrillを設定](https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview)して、インバウンドメールを`/rails/action_mailbox/mandrill/inbound_emails`にルーティングします。アプリケーションが`https://example.com`に存在する場合、完全修飾URL `https://example.com/rails/action_mailbox/mandrill/inbound_emails` を指定します。

### Postfix

Action MailboxがSMTPリレーからメールを受け入れるように指示します。

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Action Mailboxがリレーイングレスへのリクエストを認証するために使用できる強力なパスワードを生成します。

`bin/rails credentials:edit`を使用して、パスワードをアプリケーションの暗号化された資格情報の`action_mailbox.ingress_password`の下に追加します。Action Mailboxは自動的にそれを見つけます。

```yaml
action_mailbox:
  ingress_password: ...
```

または、`RAILS_INBOUND_EMAIL_PASSWORD`環境変数でパスワードを指定します。

[Postfixを設定](https://serverfault.com/questions/258469/how-to-configure-postfix-to-pipe-all-incoming-email-to-a-script)して、インバウンドメールを`bin/rails action_mailbox:ingress:postfix`にパイプします。Postfixイングレスの`URL`と先ほど生成した`INGRESS_PASSWORD`を指定します。アプリケーションが`https://example.com`に存在する場合、完全なコマンドは次のようになります。

```bash
$ bin/rails action_mailbox:ingress:postfix URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Postmark

Action MailboxがPostmarkからのメールを受け入れるように指示します。

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :postmark
```

Action MailboxがPostmarkイングレスへのリクエストを認証するために使用できる強力なパスワードを生成します。

`bin/rails credentials:edit`を使用して、パスワードをアプリケーションの暗号化された資格情報の`action_mailbox.ingress_password`の下に追加します。Action Mailboxは自動的にそれを見つけます。

```yaml
action_mailbox:
  ingress_password: ...
```

または、`RAILS_INBOUND_EMAIL_PASSWORD`環境変数でパスワードを指定します。

[Postmarkのインバウンドウェブフックを設定](https://postmarkapp.com/manual#configure-your-inbound-webhook-url)して、インバウンドメールを`/rails/action_mailbox/postmark/inbound_emails`に転送します。ユーザ名には`actionmailbox`を、先ほど生成したパスワードを使用します。アプリケーションが`https://example.com`に存在する場合、次の完全修飾URLでPostmarkを設定します。
```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/postmark/inbound_emails
```

注意：Postmarkのインバウンドウェブフックを設定する際には、**「JSONペイロードに生のメールコンテンツを含める」**というチェックボックスをオンにしてください。
Action Mailboxは生のメールコンテンツが必要です。

### Qmail

Action MailboxがSMTPリレーからのメールを受け入れるように設定します：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Action Mailboxがリレーイングレスへのリクエストを認証するために使用できる強力なパスワードを生成します。

`bin/rails credentials:edit`を使用して、パスワードをアプリケーションの暗号化された資格情報の`action_mailbox.ingress_password`の下に追加します。Action Mailboxは自動的にそれを見つけます：

```yaml
action_mailbox:
  ingress_password: ...
```

または、`RAILS_INBOUND_EMAIL_PASSWORD`環境変数でパスワードを指定します。

Qmailを設定して、インバウンドメールを`bin/rails action_mailbox:ingress:qmail`にパイプします。リレーイングレスの`URL`と先に生成した`INGRESS_PASSWORD`を指定します。アプリケーションが`https://example.com`に存在する場合、完全なコマンドは次のようになります：

```bash
$ bin/rails action_mailbox:ingress:qmail URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### SendGrid

Action MailboxがSendGridからのメールを受け入れるように設定します：

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
```

Action MailboxがSendGridイングレスへのリクエストを認証するために使用できる強力なパスワードを生成します。

`bin/rails credentials:edit`を使用して、パスワードをアプリケーションの暗号化された資格情報の`action_mailbox.ingress_password`の下に追加します。Action Mailboxは自動的にそれを見つけます：

```yaml
action_mailbox:
  ingress_password: ...
```

または、`RAILS_INBOUND_EMAIL_PASSWORD`環境変数でパスワードを指定します。

[SendGrid Inbound Parseを設定](https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/)して、インバウンドメールを`/rails/action_mailbox/sendgrid/inbound_emails`に転送します。ユーザ名は`actionmailbox`、先に生成したパスワードを使用します。アプリケーションが`https://example.com`に存在する場合、SendGridを次のURLで設定します：

```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/sendgrid/inbound_emails
```

注意：SendGrid Inbound Parseウェブフックを設定する際には、**「生の完全なMIMEメッセージを投稿する」**というチェックボックスをオンにしてください。Action Mailboxは生のMIMEメッセージが必要です。

## 例

基本的なルーティングを設定します：

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing(/^save@/i     => :forwards)
  routing(/@replies\./i => :replies)
end
```

次に、メールボックスを設定します：

```bash
# 新しいメールボックスを生成します
$ bin/rails generate mailbox forwards
```

```ruby
# app/mailboxes/forwards_mailbox.rb
class ForwardsMailbox < ApplicationMailbox
  # 処理の前提条件を指定するコールバック
  before_processing :require_projects

  def process
    # 1つのプロジェクトに対する転送を記録するか、...
    if forwarder.projects.one?
      record_forward
    else
      # ...2番目のAction Mailerを使用して、どのプロジェクトに転送するかを問い合わせます。
      request_forwarding_project
    end
  end

  private
    def require_projects
      if forwarder.projects.none?
        # Action Mailersを使用して、受信したメールを送信元に返送します - これにより処理が停止します
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

## InboundEmailの消去

デフォルトでは、正常に処理されたInboundEmailは30日後に消去されます。これにより、アカウントをキャンセルしたりコンテンツを削除したりした後も、データを適切に保持しないようになります。目的は、メールを処理した後、必要なデータを抽出してドメインモデルとコンテンツに変換し、アプリケーションの側で使用することです。InboundEmailは単にデバッグとフォレンジックのオプションを提供するためにシステムに残ります。

実際の消去は、[`config.action_mailbox.incinerate_after`][]時間後に実行される`IncinerationJob`によって行われます。この値はデフォルトで`30.days`に設定されていますが、production.rbの設定で変更することができます。（この遠い未来の消去スケジューリングは、ジョブキューがそのような長い時間ジョブを保持できることを前提としています。）

## 開発中のAction Mailboxの使用

実際のメールの送受信なしで開発中に受信メールをテストすることは役立ちます。そのために、`/rails/conductor/action_mailbox/inbound_emails`にマウントされたコンダクターコントローラーがあります。このコントローラーでは、システム内のすべてのInboundEmail、処理の状態、および新しいInboundEmailを作成するためのフォームが表示されます。

## メールボックスのテスト

例：

```ruby
class ForwardsMailboxTest < ActionMailbox::TestCase
  test "直接クライアントの転送を記録する（1つのプロジェクトに対応する転送元と転送先）" do
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

詳細なテストヘルパーメソッドについては、[ActionMailbox::TestHelper API](https://api.rubyonrails.org/classes/ActionMailbox/TestHelper.html)を参照してください。
```
[`config.action_mailbox.incinerate_after`]: configuring.html#config-action-mailbox-incinerate-after
