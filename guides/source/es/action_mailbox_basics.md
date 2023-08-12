**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a547b83b6f036a8e81899330fd515663
Conceptos básicos de Action Mailbox
=====================

Esta guía te proporciona todo lo que necesitas para comenzar a recibir correos electrónicos en tu aplicación.

Después de leer esta guía, sabrás:

* Cómo recibir correos electrónicos dentro de una aplicación Rails.
* Cómo configurar Action Mailbox.
* Cómo generar y enrutar correos electrónicos a un buzón.
* Cómo probar correos electrónicos entrantes.

--------------------------------------------------------------------------------

¿Qué es Action Mailbox?
-----------------------

Action Mailbox enruta correos electrónicos entrantes a buzones similares a controladores para su procesamiento en Rails. Viene con ingresos para Mailgun, Mandrill, Postmark y SendGrid. También puedes manejar correos entrantes directamente a través de los ingresos integrados de Exim, Postfix y Qmail.

Los correos electrónicos entrantes se convierten en registros de `InboundEmail` utilizando Active Record y cuentan con seguimiento del ciclo de vida, almacenamiento del correo electrónico original en almacenamiento en la nube a través de Active Storage y manejo responsable de datos con incineración activada por defecto.

Estos correos electrónicos entrantes se enrutan de forma asíncrona utilizando Active Job a uno o varios buzones dedicados, que son capaces de interactuar directamente con el resto de tu modelo de dominio.

## Configuración

Instala las migraciones necesarias para `InboundEmail` y asegúrate de que Active Storage esté configurado:

```bash
$ bin/rails action_mailbox:install
$ bin/rails db:migrate
```

## Configuración(duplicated)

### Exim

Indica a Action Mailbox que acepte correos electrónicos de un retransmisor SMTP:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Genera una contraseña segura que Action Mailbox pueda usar para autenticar las solicitudes al ingreso de retransmisión.

Usa `bin/rails credentials:edit` para agregar la contraseña a las credenciales cifradas de tu aplicación en `action_mailbox.ingress_password`, donde Action Mailbox la encontrará automáticamente:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativamente, proporciona la contraseña en la variable de entorno `RAILS_INBOUND_EMAIL_PASSWORD`.

Configura Exim para que envíe correos electrónicos entrantes a `bin/rails action_mailbox:ingress:exim`, proporcionando la `URL` del ingreso de retransmisión y la `INGRESS_PASSWORD` que generaste anteriormente. Si tu aplicación viviera en `https://example.com`, el comando completo se vería así:

```bash
$ bin/rails action_mailbox:ingress:exim URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun

Proporciona a Action Mailbox tu clave de firma de Mailgun (que puedes encontrar en Configuración -> Seguridad y usuarios -> Seguridad de API en Mailgun), para que pueda autenticar las solicitudes al ingreso de Mailgun.

Usa `bin/rails credentials:edit` para agregar tu clave de firma a las credenciales cifradas de tu aplicación en `action_mailbox.mailgun_signing_key`, donde Action Mailbox la encontrará automáticamente:

```yaml
action_mailbox:
  mailgun_signing_key: ...
```

Alternativamente, proporciona tu clave de firma en la variable de entorno `MAILGUN_INGRESS_SIGNING_KEY`.

Indica a Action Mailbox que acepte correos electrónicos de Mailgun:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mailgun
```

[Configura Mailgun](https://documentation.mailgun.com/en/latest/user_manual.html#receiving-forwarding-and-storing-messages) para que reenvíe correos electrónicos entrantes a `/rails/action_mailbox/mailgun/inbound_emails/mime`. Si tu aplicación viviera en `https://example.com`, especificarías la URL completamente calificada `https://example.com/rails/action_mailbox/mailgun/inbound_emails/mime`.

### Mandrill

Proporciona a Action Mailbox tu clave de API de Mandrill, para que pueda autenticar las solicitudes al ingreso de Mandrill.

Usa `bin/rails credentials:edit` para agregar tu clave de API a las credenciales cifradas de tu aplicación en `action_mailbox.mandrill_api_key`, donde Action Mailbox la encontrará automáticamente:

```yaml
action_mailbox:
  mandrill_api_key: ...
```

Alternativamente, proporciona tu clave de API en la variable de entorno `MANDRILL_INGRESS_API_KEY`.

Indica a Action Mailbox que acepte correos electrónicos de Mandrill:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mandrill
```

[Configura Mandrill](https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview) para que enrute correos electrónicos entrantes a `/rails/action_mailbox/mandrill/inbound_emails`. Si tu aplicación viviera en `https://example.com`, especificarías la URL completamente calificada `https://example.com/rails/action_mailbox/mandrill/inbound_emails`.

### Postfix

Indica a Action Mailbox que acepte correos electrónicos de un retransmisor SMTP:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Genera una contraseña segura que Action Mailbox pueda usar para autenticar las solicitudes al ingreso de retransmisión.

Usa `bin/rails credentials:edit` para agregar la contraseña a las credenciales cifradas de tu aplicación en `action_mailbox.ingress_password`, donde Action Mailbox la encontrará automáticamente:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativamente, proporciona la contraseña en la variable de entorno `RAILS_INBOUND_EMAIL_PASSWORD`.

[Configura Postfix](https://serverfault.com/questions/258469/how-to-configure-postfix-to-pipe-all-incoming-email-to-a-script) para que envíe correos electrónicos entrantes a `bin/rails action_mailbox:ingress:postfix`, proporcionando la `URL` del ingreso de Postfix y la `INGRESS_PASSWORD` que generaste anteriormente. Si tu aplicación viviera en `https://example.com`, el comando completo se vería así:

```bash
$ bin/rails action_mailbox:ingress:postfix URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Postmark

Indica a Action Mailbox que acepte correos electrónicos de Postmark:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :postmark
```

Genera una contraseña segura que Action Mailbox pueda usar para autenticar las solicitudes al ingreso de Postmark.

Usa `bin/rails credentials:edit` para agregar la contraseña a las credenciales cifradas de tu aplicación en `action_mailbox.ingress_password`, donde Action Mailbox la encontrará automáticamente:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativamente, proporciona la contraseña en la variable de entorno `RAILS_INBOUND_EMAIL_PASSWORD`.

[Configura el webhook de entrada de Postmark](https://postmarkapp.com/manual#configure-your-inbound-webhook-url) para que reenvíe correos electrónicos entrantes a `/rails/action_mailbox/postmark/inbound_emails` con el nombre de usuario `actionmailbox` y la contraseña que generaste anteriormente. Si tu aplicación viviera en `https://example.com`, configurarías Postmark con la siguiente URL completamente calificada:
```
https://actionmailbox:CONTRASEÑA@example.com/rails/action_mailbox/postmark/inbound_emails
```

NOTA: Al configurar tu webhook de entrada de Postmark, asegúrate de marcar la casilla que dice **"Incluir contenido de correo electrónico sin procesar en la carga útil JSON"**. Action Mailbox necesita el contenido de correo electrónico sin procesar para funcionar.

### Qmail

Indica a Action Mailbox que acepte correos electrónicos de un retransmisor SMTP:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Genera una contraseña segura que Action Mailbox pueda usar para autenticar las solicitudes al retransmisor de entrada.

Usa `bin/rails credentials:edit` para agregar la contraseña a las credenciales cifradas de tu aplicación en `action_mailbox.ingress_password`, donde Action Mailbox la encontrará automáticamente:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativamente, proporciona la contraseña en la variable de entorno `RAILS_INBOUND_EMAIL_PASSWORD`.

Configura Qmail para redirigir los correos electrónicos entrantes a `bin/rails action_mailbox:ingress:qmail`,
proporcionando la `URL` del retransmisor de entrada y la `INGRESS_PASSWORD` que
generaste anteriormente. Si tu aplicación se encuentra en `https://example.com`, el
comando completo se vería así:

```bash
$ bin/rails action_mailbox:ingress:qmail URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### SendGrid

Indica a Action Mailbox que acepte correos electrónicos de SendGrid:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
```

Genera una contraseña segura que Action Mailbox pueda usar para autenticar las solicitudes al retransmisor de SendGrid.

Usa `bin/rails credentials:edit` para agregar la contraseña a las credenciales cifradas de tu aplicación en `action_mailbox.ingress_password`,
donde Action Mailbox la encontrará automáticamente:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativamente, proporciona la contraseña en la variable de entorno `RAILS_INBOUND_EMAIL_PASSWORD`.

[Configura el análisis de entrada de SendGrid](https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/)
para redirigir los correos electrónicos entrantes a
`/rails/action_mailbox/sendgrid/inbound_emails` con el nombre de usuario `actionmailbox`
y la contraseña que generaste anteriormente. Si tu aplicación se encuentra en `https://example.com`,
configura SendGrid con la siguiente URL:

```
https://actionmailbox:CONTRASEÑA@example.com/rails/action_mailbox/sendgrid/inbound_emails
```

NOTA: Al configurar tu webhook de análisis de entrada de SendGrid, asegúrate de marcar la casilla que dice **“Publicar el mensaje MIME completo sin procesar.”**. Action Mailbox necesita el mensaje MIME completo sin procesar para funcionar.

## Ejemplos

Configura enrutamiento básico:

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing(/^save@/i     => :forwards)
  routing(/@replies\./i => :replies)
end
```

Luego configura un buzón:

```bash
# Genera un nuevo buzón
$ bin/rails generate mailbox forwards
```

```ruby
# app/mailboxes/forwards_mailbox.rb
class ForwardsMailbox < ApplicationMailbox
  # Los callbacks especifican los requisitos previos para el procesamiento
  before_processing :require_projects

  def process
    # Registra el reenvío en el proyecto correspondiente, o...
    if forwarder.projects.one?
      record_forward
    else
      # ...involucra a un segundo Action Mailer para preguntar en qué proyecto se debe reenviar.
      request_forwarding_project
    end
  end

  private
    def require_projects
      if forwarder.projects.none?
        # Usa Action Mailers para rebotar los correos electrónicos entrantes de vuelta al remitente, esto detiene el procesamiento
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

## Incineración de InboundEmails

Por defecto, un InboundEmail que ha sido procesado correctamente se incinerará después de 30 días. Esto asegura que no estés conservando los datos de las personas sin motivo después de que hayan cancelado sus cuentas o eliminado su contenido. La intención es que después de procesar un correo electrónico, hayas extraído todos los datos necesarios y los hayas convertido en modelos de dominio y contenido en tu lado de la aplicación. El InboundEmail simplemente permanece en el sistema durante un tiempo adicional para proporcionar opciones de depuración y forenses.

La incineración real se realiza a través del `IncinerationJob` que está programado para ejecutarse después de [`config.action_mailbox.incinerate_after`][]. Este valor está configurado de forma predeterminada en `30.days`, pero puedes cambiarlo en tu archivo de configuración production.rb. (Ten en cuenta que esta programación de incineración a largo plazo depende de que tu cola de trabajos pueda mantener los trabajos durante ese tiempo).

## Trabajando con Action Mailbox en desarrollo

Es útil poder probar correos electrónicos entrantes en desarrollo sin enviar ni recibir correos electrónicos reales. Para lograr esto, hay un controlador conductor montado en `/rails/conductor/action_mailbox/inbound_emails`,
que te proporciona un índice de todos los InboundEmails en el sistema, su estado de procesamiento y un formulario para crear un nuevo InboundEmail también.

## Pruebas de buzones

Ejemplo:

```ruby
class ForwardsMailboxTest < ActionMailbox::TestCase
  test "grabar directamente un reenvío de cliente para un remitente y destinatario correspondientes a un proyecto" do
    assert_difference -> { people(:david).buckets.first.recordings.count } do
      receive_inbound_email_from_mail \
        to: 'save@example.com',
        from: people(:david).email_address,
        subject: "Fwd: Actualización de estado?",
        body: <<~BODY
          --- Begin forwarded message ---
          From: Frank Holland <frank@microsoft.com>

          ¿Cuál es el estado?
        BODY
    end

    recording = people(:david).buckets.first.recordings.last
    assert_equal people(:david), recording.creator
    assert_equal "Actualización de estado?", recording.forward.subject
    assert_match "¿Cuál es el estado?", recording.forward.content.to_s
  end
end
```

Consulta la [API de ActionMailbox::TestHelper](https://api.rubyonrails.org/classes/ActionMailbox/TestHelper.html) para obtener más métodos de ayuda para pruebas.
```
[`config.action_mailbox.incinerate_after`]: configuring.html#config-action-mailbox-incinerate-after
