**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a547b83b6f036a8e81899330fd515663
Noções básicas do Action Mailbox
=====================

Este guia fornece tudo o que você precisa para começar a receber emails em sua aplicação.

Após ler este guia, você saberá:

* Como receber emails em uma aplicação Rails.
* Como configurar o Action Mailbox.
* Como gerar e rotear emails para uma caixa de correio.
* Como testar emails recebidos.

--------------------------------------------------------------------------------

O que é o Action Mailbox?
-----------------------

O Action Mailbox roteia emails recebidos para caixas de correio semelhantes a controladores para processamento no Rails. Ele é fornecido com entradas para Mailgun, Mandrill, Postmark e SendGrid. Você também pode lidar com emails de entrada diretamente por meio das entradas integradas Exim, Postfix e Qmail.

Os emails de entrada são convertidos em registros `InboundEmail` usando o Active Record e possuem rastreamento do ciclo de vida, armazenamento do email original em armazenamento em nuvem por meio do Active Storage e manipulação responsável de dados com incineração ativada por padrão.

Esses emails de entrada são roteados de forma assíncrona usando o Active Job para uma ou várias caixas de correio dedicadas, que são capazes de interagir diretamente com o restante do seu modelo de domínio.

## Configuração

Instale as migrações necessárias para `InboundEmail` e certifique-se de que o Active Storage esteja configurado:

```bash
$ bin/rails action_mailbox:install
$ bin/rails db:migrate
```

## Configuração(duplicated)

### Exim

Informe ao Action Mailbox para aceitar emails de um relé SMTP:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Gere uma senha forte que o Action Mailbox possa usar para autenticar solicitações para a entrada do relé.

Use `bin/rails credentials:edit` para adicionar a senha às credenciais criptografadas de sua aplicação em `action_mailbox.ingress_password`, onde o Action Mailbox a encontrará automaticamente:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativamente, forneça a senha na variável de ambiente `RAILS_INBOUND_EMAIL_PASSWORD`.

Configure o Exim para encaminhar emails de entrada para `bin/rails action_mailbox:ingress:exim`, fornecendo a `URL` da entrada do relé e a `INGRESS_PASSWORD` que você gerou anteriormente. Se sua aplicação estiver em `https://example.com`, o comando completo seria assim:

```bash
$ bin/rails action_mailbox:ingress:exim URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun

Forneça ao Action Mailbox sua chave de assinatura do Mailgun (que você pode encontrar em Configurações -> Segurança e usuários -> Segurança da API no Mailgun), para que ele possa autenticar solicitações para a entrada do Mailgun.

Use `bin/rails credentials:edit` para adicionar sua chave de assinatura às credenciais criptografadas de sua aplicação em `action_mailbox.mailgun_signing_key`, onde o Action Mailbox a encontrará automaticamente:

```yaml
action_mailbox:
  mailgun_signing_key: ...
```

Alternativamente, forneça sua chave de assinatura na variável de ambiente `MAILGUN_INGRESS_SIGNING_KEY`.

Informe ao Action Mailbox para aceitar emails do Mailgun:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mailgun
```

[Configure o Mailgun](https://documentation.mailgun.com/en/latest/user_manual.html#receiving-forwarding-and-storing-messages) para encaminhar emails de entrada para `/rails/action_mailbox/mailgun/inbound_emails/mime`. Se sua aplicação estiver em `https://example.com`, você especificaria a URL completa `https://example.com/rails/action_mailbox/mailgun/inbound_emails/mime`.

### Mandrill

Forneça ao Action Mailbox sua chave de API do Mandrill, para que ele possa autenticar solicitações para a entrada do Mandrill.

Use `bin/rails credentials:edit` para adicionar sua chave de API às credenciais criptografadas de sua aplicação em `action_mailbox.mandrill_api_key`, onde o Action Mailbox a encontrará automaticamente:

```yaml
action_mailbox:
  mandrill_api_key: ...
```

Alternativamente, forneça sua chave de API na variável de ambiente `MANDRILL_INGRESS_API_KEY`.

Informe ao Action Mailbox para aceitar emails do Mandrill:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mandrill
```

[Configure o Mandrill](https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview) para rotear emails de entrada para `/rails/action_mailbox/mandrill/inbound_emails`. Se sua aplicação estiver em `https://example.com`, você especificaria a URL completa `https://example.com/rails/action_mailbox/mandrill/inbound_emails`.

### Postfix

Informe ao Action Mailbox para aceitar emails de um relé SMTP:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Gere uma senha forte que o Action Mailbox possa usar para autenticar solicitações para a entrada do relé.

Use `bin/rails credentials:edit` para adicionar a senha às credenciais criptografadas de sua aplicação em `action_mailbox.ingress_password`, onde o Action Mailbox a encontrará automaticamente:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativamente, forneça a senha na variável de ambiente `RAILS_INBOUND_EMAIL_PASSWORD`.

[Configure o Postfix](https://serverfault.com/questions/258469/how-to-configure-postfix-to-pipe-all-incoming-email-to-a-script) para encaminhar emails de entrada para `bin/rails action_mailbox:ingress:postfix`, fornecendo a `URL` da entrada do Postfix e a `INGRESS_PASSWORD` que você gerou anteriormente. Se sua aplicação estiver em `https://example.com`, o comando completo seria assim:

```bash
$ bin/rails action_mailbox:ingress:postfix URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Postmark

Informe ao Action Mailbox para aceitar emails do Postmark:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :postmark
```

Gere uma senha forte que o Action Mailbox possa usar para autenticar solicitações para a entrada do Postmark.

Use `bin/rails credentials:edit` para adicionar a senha às credenciais criptografadas de sua aplicação em `action_mailbox.ingress_password`, onde o Action Mailbox a encontrará automaticamente:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativamente, forneça a senha na variável de ambiente `RAILS_INBOUND_EMAIL_PASSWORD`.

[Configure o webhook de entrada do Postmark](https://postmarkapp.com/manual#configure-your-inbound-webhook-url) para encaminhar emails de entrada para `/rails/action_mailbox/postmark/inbound_emails` com o nome de usuário `actionmailbox` e a senha que você gerou anteriormente. Se sua aplicação estiver em `https://example.com`, você configuraria o Postmark com a seguinte URL completa:
```
https://actionmailbox:SENHA@example.com/rails/action_mailbox/postmark/inbound_emails
```

NOTA: Ao configurar seu webhook de entrada do Postmark, certifique-se de marcar a caixa rotulada **"Incluir conteúdo de e-mail bruto na carga JSON"**.
O Action Mailbox precisa do conteúdo bruto do e-mail para funcionar.

### Qmail

Informe ao Action Mailbox para aceitar e-mails de um relé SMTP:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Gere uma senha forte que o Action Mailbox possa usar para autenticar solicitações ao relé de entrada.

Use `bin/rails credentials:edit` para adicionar a senha às credenciais criptografadas do seu aplicativo em `action_mailbox.ingress_password`, onde o Action Mailbox encontrará automaticamente:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativamente, forneça a senha na variável de ambiente `RAILS_INBOUND_EMAIL_PASSWORD`.

Configure o Qmail para encaminhar e-mails de entrada para `bin/rails action_mailbox:ingress:qmail`,
fornecendo a `URL` do relé de entrada e a `INGRESS_PASSWORD` que você
gerou anteriormente. Se o seu aplicativo estiver em `https://example.com`, o
comando completo ficaria assim:

```bash
$ bin/rails action_mailbox:ingress:qmail URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### SendGrid

Informe ao Action Mailbox para aceitar e-mails do SendGrid:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
```

Gere uma senha forte que o Action Mailbox possa usar para autenticar
solicitações ao ingresso do SendGrid.

Use `bin/rails credentials:edit` para adicionar a senha às credenciais criptografadas do seu aplicativo em `action_mailbox.ingress_password`,
onde o Action Mailbox encontrará automaticamente:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativamente, forneça a senha na variável de ambiente `RAILS_INBOUND_EMAIL_PASSWORD`.

[Configure o Parse de Entrada do SendGrid](https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/)
para encaminhar e-mails de entrada para
`/rails/action_mailbox/sendgrid/inbound_emails` com o nome de usuário `actionmailbox`
e a senha que você gerou anteriormente. Se o seu aplicativo estiver em `https://example.com`,
você configuraria o SendGrid com a seguinte URL:

```
https://actionmailbox:SENHA@example.com/rails/action_mailbox/sendgrid/inbound_emails
```

NOTA: Ao configurar seu webhook de Parse de Entrada do SendGrid, certifique-se de marcar a caixa rotulada **"Postar a mensagem MIME bruta e completa."**. O Action Mailbox precisa da mensagem MIME bruta para funcionar.

## Exemplos

Configure o roteamento básico:

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing(/^save@/i     => :forwards)
  routing(/@replies\./i => :replies)
end
```

Em seguida, configure uma caixa de correio:

```bash
# Gerar nova caixa de correio
$ bin/rails generate mailbox forwards
```

```ruby
# app/mailboxes/forwards_mailbox.rb
class ForwardsMailbox < ApplicationMailbox
  # Os callbacks especificam os pré-requisitos para o processamento
  before_processing :require_projects

  def process
    # Registre o encaminhamento em um projeto, ou...
    if forwarder.projects.one?
      record_forward
    else
      # ...envolva um segundo Action Mailer para perguntar em qual projeto encaminhar.
      request_forwarding_project
    end
  end

  private
    def require_projects
      if forwarder.projects.none?
        # Use Action Mailers para devolver e-mails recebidos ao remetente - isso interrompe o processamento
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

## Incineração de InboundEmails

Por padrão, um InboundEmail que foi processado com sucesso será
incinerado após 30 dias. Isso garante que você não esteja retendo dados das pessoas
desnecessariamente após elas terem cancelado suas contas ou excluído seus
conteúdos. A intenção é que, depois de processar um e-mail, você tenha
extraído todos os dados necessários e os transformado em modelos de domínio e conteúdo
no seu lado da aplicação. O InboundEmail simplesmente permanece no sistema
por mais algum tempo para fornecer opções de depuração e forense.

A incineração real é feita por meio do `IncinerationJob` que é agendado
para ser executado após [`config.action_mailbox.incinerate_after`][]. Esse valor é
por padrão definido como `30.days`, mas você pode alterá-lo na configuração do seu production.rb. (Observe que o agendamento de incineração para o futuro distante depende da sua fila de jobs ser capaz de manter os jobs por tanto tempo.)

## Trabalhando com o Action Mailbox no Desenvolvimento

É útil poder testar e-mails recebidos no desenvolvimento sem realmente
enviar e receber e-mails reais. Para isso, há um controlador conductor
montado em `/rails/conductor/action_mailbox/inbound_emails`,
que fornece um índice de todos os InboundEmails no sistema, seu
estado de processamento e um formulário para criar um novo InboundEmail também.

## Testando Caixas de Correio

Exemplo:

```ruby
class ForwardsMailboxTest < ActionMailbox::TestCase
  test "gravando diretamente um encaminhamento de cliente para um remetente e destinatário correspondente a um projeto" do
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

Consulte a [API do ActionMailbox::TestHelper](https://api.rubyonrails.org/classes/ActionMailbox/TestHelper.html) para obter mais métodos auxiliares de teste.
```
[`config.action_mailbox.incinerate_after`]: configuring.html#config-action-mailbox-incinerate-after
