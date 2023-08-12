**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a547b83b6f036a8e81899330fd515663
Action Mailbox 기본 사항
=====================

이 가이드는 애플리케이션으로 이메일을 수신하는 데 필요한 모든 정보를 제공합니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다.

* Rails 애플리케이션에서 이메일을 수신하는 방법.
* Action Mailbox를 구성하는 방법.
* 이메일을 생성하고 라우팅하여 메일박스로 전송하는 방법.
* 수신 이메일을 테스트하는 방법.

--------------------------------------------------------------------------------

Action Mailbox란 무엇인가?
-----------------------

Action Mailbox는 Rails에서 처리하기 위해 컨트롤러와 유사한 메일박스로 들어오는 이메일을 라우팅합니다. Mailgun, Mandrill, Postmark 및 SendGrid용 인그레스가 함께 제공됩니다. 내장된 Exim, Postfix 및 Qmail 인그레스를 통해 직접 인바운드 메일을 처리할 수도 있습니다.

인바운드 이메일은 Active Record를 사용하여 `InboundEmail` 레코드로 변환되며, 라이프사이클 추적, 원본 이메일의 클라우드 스토리지에 대한 Active Storage를 통한 저장 및 기본적으로 활성화된 데이터 처리 기능을 제공합니다.

이러한 인바운드 이메일은 Active Job을 사용하여 비동기적으로 하나 이상의 전용 메일박스로 라우팅되며, 이 메일박스는 도메인 모델의 나머지 부분과 직접 상호 작용할 수 있습니다.

## 설정

`InboundEmail`에 필요한 마이그레이션을 설치하고 Active Storage가 설정되었는지 확인하십시오.

```bash
$ bin/rails action_mailbox:install
$ bin/rails db:migrate
```

## 구성

### Exim

Action Mailbox가 SMTP 릴레이에서 이메일을 수락하도록 지정하십시오.

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Action Mailbox가 릴레이 인그레스로의 요청을 인증하는 데 사용할 수 있는 강력한 암호를 생성하십시오.

`bin/rails credentials:edit`를 사용하여 암호를 응용 프로그램의 암호화된 자격 증명에 `action_mailbox.ingress_password`로 추가하십시오. Action Mailbox가 자동으로 찾을 수 있도록 합니다.

```yaml
action_mailbox:
  ingress_password: ...
```

또는 `RAILS_INBOUND_EMAIL_PASSWORD` 환경 변수에 암호를 제공하십시오.

Exim을 구성하여 인바운드 이메일을 `bin/rails action_mailbox:ingress:exim`으로 파이프하도록 설정하십시오. 릴레이 인그레스의 `URL` 및 이전에 생성한 `INGRESS_PASSWORD`를 제공하십시오. 애플리케이션이 `https://example.com`에 위치한다면, 전체 명령은 다음과 같을 것입니다.

```bash
$ bin/rails action_mailbox:ingress:exim URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun

Action Mailbox에게 Mailgun 서명 키를 제공하십시오 (Mailgun의 설정 -> 보안 및 사용자 -> API 보안에서 찾을 수 있음) 이를 통해 Mailgun 인그레스로의 요청을 인증할 수 있습니다.

`bin/rails credentials:edit`를 사용하여 응용 프로그램의 암호화된 자격 증명에 서명 키를 추가하십시오. Action Mailbox가 자동으로 찾을 수 있도록 합니다. `action_mailbox.mailgun_signing_key` 아래에 추가하십시오.

```yaml
action_mailbox:
  mailgun_signing_key: ...
```

또는 `MAILGUN_INGRESS_SIGNING_KEY` 환경 변수에 서명 키를 제공하십시오.

Action Mailbox가 Mailgun에서 이메일을 수락하도록 지정하십시오.

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mailgun
```

[Mailgun을 구성](https://documentation.mailgun.com/en/latest/user_manual.html#receiving-forwarding-and-storing-messages)하여 인바운드 이메일을 `/rails/action_mailbox/mailgun/inbound_emails/mime`로 전달하도록 설정하십시오. 애플리케이션이 `https://example.com`에 위치한다면, 완전한 URL `https://example.com/rails/action_mailbox/mailgun/inbound_emails/mime`을 지정해야 합니다.

### Mandrill

Action Mailbox에게 Mandrill API 키를 제공하십시오. 이를 통해 Mandrill 인그레스로의 요청을 인증할 수 있습니다.

`bin/rails credentials:edit`를 사용하여 응용 프로그램의 암호화된 자격 증명에 API 키를 추가하십시오. Action Mailbox가 자동으로 찾을 수 있도록 합니다. `action_mailbox.mandrill_api_key` 아래에 추가하십시오.

```yaml
action_mailbox:
  mandrill_api_key: ...
```

또는 `MANDRILL_INGRESS_API_KEY` 환경 변수에 API 키를 제공하십시오.

Action Mailbox가 Mandrill에서 이메일을 수락하도록 지정하십시오.

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mandrill
```

[Mandrill을 구성](https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview)하여 인바운드 이메일을 `/rails/action_mailbox/mandrill/inbound_emails`로 라우팅하도록 설정하십시오. 애플리케이션이 `https://example.com`에 위치한다면, 완전한 URL `https://example.com/rails/action_mailbox/mandrill/inbound_emails`을 지정해야 합니다.

### Postfix

Action Mailbox가 SMTP 릴레이에서 이메일을 수락하도록 지정하십시오.

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Action Mailbox가 릴레이 인그레스로의 요청을 인증하는 데 사용할 수 있는 강력한 암호를 생성하십시오.

`bin/rails credentials:edit`를 사용하여 암호를 응용 프로그램의 암호화된 자격 증명에 `action_mailbox.ingress_password`로 추가하십시오. Action Mailbox가 자동으로 찾을 수 있도록 합니다.

```yaml
action_mailbox:
  ingress_password: ...
```

또는 `RAILS_INBOUND_EMAIL_PASSWORD` 환경 변수에 암호를 제공하십시오.

[Postfix를 구성](https://serverfault.com/questions/258469/how-to-configure-postfix-to-pipe-all-incoming-email-to-a-script)하여 인바운드 이메일을 `bin/rails action_mailbox:ingress:postfix`로 파이프하도록 설정하십시오. 이전에 생성한 `INGRESS_PASSWORD`와 Postfix 인그레스의 `URL`을 제공하십시오. 애플리케이션이 `https://example.com`에 위치한다면, 전체 명령은 다음과 같을 것입니다.

```bash
$ bin/rails action_mailbox:ingress:postfix URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Postmark

Action Mailbox가 Postmark에서 이메일을 수락하도록 지정하십시오.

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :postmark
```

Action Mailbox가 Postmark 인그레스로의 요청을 인증할 수 있도록 강력한 암호를 생성하십시오.

`bin/rails credentials:edit`를 사용하여 암호를 응용 프로그램의 암호화된 자격 증명에 `action_mailbox.ingress_password`로 추가하십시오. Action Mailbox가 자동으로 찾을 수 있도록 합니다.

```yaml
action_mailbox:
  ingress_password: ...
```

또는 `RAILS_INBOUND_EMAIL_PASSWORD` 환경 변수에 암호를 제공하십시오.

[Postmark 인바운드 웹훅을 구성](https://postmarkapp.com/manual#configure-your-inbound-webhook-url)하여 인바운드 이메일을 `/rails/action_mailbox/postmark/inbound_emails`로 전달하도록 설정하십시오. 사용자 이름 `actionmailbox`와 이전에 생성한 암호를 사용하십시오. 애플리케이션이 `https://example.com`에 위치한다면, 다음과 같은 완전한 URL로 Postmark을 구성해야 합니다.
```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/postmark/inbound_emails
```

참고: Postmark 인바운드 웹훅을 구성할 때, **"JSON 페이로드에 원시 이메일 콘텐츠 포함"**란에 체크해야 합니다. Action Mailbox는 작동하기 위해 원시 이메일 콘텐츠가 필요합니다.

### Qmail

Action Mailbox가 SMTP 릴레이에서 이메일을 수락하도록 지정하십시오:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Action Mailbox가 릴레이 인그레스로의 요청을 인증하기 위해 사용할 수 있는 강력한 비밀번호를 생성하십시오.

`bin/rails credentials:edit`를 사용하여 비밀번호를 응용 프로그램의 암호화된 자격 증명에 `action_mailbox.ingress_password`로 추가하십시오. Action Mailbox가 자동으로 찾을 수 있도록 합니다:

```yaml
action_mailbox:
  ingress_password: ...
```

또는 `RAILS_INBOUND_EMAIL_PASSWORD` 환경 변수에 비밀번호를 제공하십시오.

Qmail을 구성하여 들어오는 이메일을 `bin/rails action_mailbox:ingress:qmail`로 파이프하십시오. 릴레이 인그레스의 `URL`과 이전에 생성한 `INGRESS_PASSWORD`를 제공하십시오. 응용 프로그램이 `https://example.com`에 위치한다면, 전체 명령은 다음과 같습니다:

```bash
$ bin/rails action_mailbox:ingress:qmail URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### SendGrid

Action Mailbox가 SendGrid에서 이메일을 수락하도록 지정하십시오:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
```

Action Mailbox가 SendGrid 인그레스로의 요청을 인증하기 위해 사용할 수 있는 강력한 비밀번호를 생성하십시오.

`bin/rails credentials:edit`를 사용하여 비밀번호를 응용 프로그램의 암호화된 자격 증명에 `action_mailbox.ingress_password`로 추가하십시오. Action Mailbox가 자동으로 찾을 수 있도록 합니다:

```yaml
action_mailbox:
  ingress_password: ...
```

또는 `RAILS_INBOUND_EMAIL_PASSWORD` 환경 변수에 비밀번호를 제공하십시오.

[SendGrid Inbound Parse를 구성](https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/)하여 들어오는 이메일을 `/rails/action_mailbox/sendgrid/inbound_emails`로 전달하십시오. 사용자 이름은 `actionmailbox`이고 이전에 생성한 비밀번호를 사용하십시오. 응용 프로그램이 `https://example.com`에 위치한다면, SendGrid를 다음 URL로 구성하십시오:

```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/sendgrid/inbound_emails
```

참고: SendGrid Inbound Parse 웹훅을 구성할 때, **"원시, 전체 MIME 메시지 게시"**란에 체크해야 합니다. Action Mailbox는 작동하기 위해 원시 MIME 메시지가 필요합니다.

## 예제

기본 라우팅을 구성하십시오:

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing(/^save@/i     => :forwards)
  routing(/@replies\./i => :replies)
end
```

그런 다음 메일박스를 설정하십시오:

```bash
# 새 메일박스 생성
$ bin/rails generate mailbox forwards
```

```ruby
# app/mailboxes/forwards_mailbox.rb
class ForwardsMailbox < ApplicationMailbox
  # 처리 전 사전 요구 사항을 지정하는 콜백
  before_processing :require_projects

  def process
    # 하나의 프로젝트에 대한 전달 기록 또는...
    if forwarder.projects.one?
      record_forward
    else
      # ...어떤 프로젝트로 전달할지 묻기 위해 두 번째 Action Mailer를 사용합니다.
      request_forwarding_project
    end
  end

  private
    def require_projects
      if forwarder.projects.none?
        # Action Mailers를 사용하여 들어오는 이메일을 발신자에게 다시 보냅니다 - 이는 처리를 중단합니다.
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

## InboundEmail의 소각

기본적으로 성공적으로 처리된 InboundEmail은 30일 후에 소각됩니다. 이렇게 함으로써 사용자가 계정을 취소하거나 콘텐츠를 삭제한 후에도 데이터를 무작위로 보관하지 않도록 합니다. 응용 프로그램의 한쪽에서 도메인 모델과 콘텐츠로 모든 필요한 데이터를 추출하고 변환한 후에도 InboundEmail은 시스템에 그대로 남아 있으며 디버깅 및 포렌식 옵션을 제공합니다.

실제 소각은 [`config.action_mailbox.incinerate_after`][] 시간 후에 실행되는 `IncinerationJob`를 통해 수행됩니다. 이 값은 기본적으로 `30.days`로 설정되어 있지만, production.rb 구성에서 변경할 수 있습니다. (이러한 멀리 미래의 소각 스케줄링은 작업 큐가 해당 기간 동안 작업을 보유할 수 있는지에 의존합니다.)


## 개발 중에 Action Mailbox 사용하기

실제 이메일을 보내고 받지 않고도 개발 중에 들어오는 이메일을 테스트하는 것이 도움이 됩니다. 이를 위해 `/rails/conductor/action_mailbox/inbound_emails`에 마운트된 conductor 컨트롤러가 있습니다. 이 컨트롤러는 시스템의 모든 InboundEmail, 처리 상태 및 새로운 InboundEmail을 생성하는 양식을 제공합니다.

## 메일박스 테스트

예제:

```ruby
class ForwardsMailboxTest < ActionMailbox::TestCase
  test "forwarder 및 forwardee가 하나의 프로젝트에 해당하는 클라이언트 전달을 직접 기록하는 것" do
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

추가 테스트 도우미 메서드에 대해서는 [ActionMailbox::TestHelper API](https://api.rubyonrails.org/classes/ActionMailbox/TestHelper.html)를 참조하십시오.
```
[`config.action_mailbox.incinerate_after`]: configuring.html#config-action-mailbox-incinerate-after
