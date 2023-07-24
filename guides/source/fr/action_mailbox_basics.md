**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a547b83b6f036a8e81899330fd515663
Action Mailbox Basics
=====================

Ce guide vous fournit tout ce dont vous avez besoin pour commencer à recevoir des emails dans votre application.

Après avoir lu ce guide, vous saurez :

* Comment recevoir des emails dans une application Rails.
* Comment configurer Action Mailbox.
* Comment générer et router des emails vers une boîte aux lettres.
* Comment tester les emails entrants.

--------------------------------------------------------------------------------

Qu'est-ce qu'Action Mailbox ?
-----------------------

Action Mailbox route les emails entrants vers des boîtes aux lettres similaires à des contrôleurs pour les traiter dans Rails. Il est livré avec des entrées pour Mailgun, Mandrill, Postmark et SendGrid. Vous pouvez également gérer les emails entrants directement via les entrées intégrées Exim, Postfix et Qmail.

Les emails entrants sont transformés en enregistrements `InboundEmail` en utilisant Active Record et disposent d'un suivi du cycle de vie, d'un stockage de l'email d'origine sur un stockage cloud via Active Storage, et d'une gestion responsable des données avec une incinération activée par défaut.

Ces emails entrants sont routés de manière asynchrone en utilisant Active Job vers une ou plusieurs boîtes aux lettres dédiées, qui sont capables d'interagir directement avec le reste de votre modèle de domaine.

## Configuration

Installez les migrations nécessaires pour `InboundEmail` et assurez-vous que Active Storage est configuré :

```bash
$ bin/rails action_mailbox:install
$ bin/rails db:migrate
```

### Exim

Indiquez à Action Mailbox d'accepter les emails d'un relais SMTP :

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Générez un mot de passe fort que Action Mailbox peut utiliser pour authentifier les requêtes vers l'entrée du relais.

Utilisez `bin/rails credentials:edit` pour ajouter le mot de passe aux credentials chiffrés de votre application sous `action_mailbox.ingress_password`, où Action Mailbox le trouvera automatiquement :

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativement, fournissez le mot de passe dans la variable d'environnement `RAILS_INBOUND_EMAIL_PASSWORD`.

Configurez Exim pour rediriger les emails entrants vers `bin/rails action_mailbox:ingress:exim`, en fournissant l'URL de l'entrée du relais et le `INGRESS_PASSWORD` que vous avez précédemment généré. Si votre application se trouve à `https://example.com`, la commande complète ressemblerait à ceci :

```bash
$ bin/rails action_mailbox:ingress:exim URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun

Donnez à Action Mailbox votre clé de signature Mailgun (que vous pouvez trouver dans Paramètres -> Sécurité et utilisateurs -> Sécurité de l'API dans Mailgun), afin qu'il puisse authentifier les requêtes vers l'entrée Mailgun.

Utilisez `bin/rails credentials:edit` pour ajouter votre clé de signature à vos credentials chiffrés de l'application sous `action_mailbox.mailgun_signing_key`, où Action Mailbox la trouvera automatiquement :

```yaml
action_mailbox:
  mailgun_signing_key: ...
```

Alternativement, fournissez votre clé de signature dans la variable d'environnement `MAILGUN_INGRESS_SIGNING_KEY`.

Indiquez à Action Mailbox d'accepter les emails de Mailgun :

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mailgun
```

[Configurez Mailgun](https://documentation.mailgun.com/en/latest/user_manual.html#receiving-forwarding-and-storing-messages) pour rediriger les emails entrants vers `/rails/action_mailbox/mailgun/inbound_emails/mime`. Si votre application se trouve à `https://example.com`, vous spécifierez l'URL complète `https://example.com/rails/action_mailbox/mailgun/inbound_emails/mime`.

### Mandrill

Donnez à Action Mailbox votre clé d'API Mandrill, afin qu'il puisse authentifier les requêtes vers l'entrée Mandrill.

Utilisez `bin/rails credentials:edit` pour ajouter votre clé d'API à vos credentials chiffrés de l'application sous `action_mailbox.mandrill_api_key`, où Action Mailbox la trouvera automatiquement :

```yaml
action_mailbox:
  mandrill_api_key: ...
```

Alternativement, fournissez votre clé d'API dans la variable d'environnement `MANDRILL_INGRESS_API_KEY`.

Indiquez à Action Mailbox d'accepter les emails de Mandrill :

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mandrill
```

[Configurez Mandrill](https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview) pour rediriger les emails entrants vers `/rails/action_mailbox/mandrill/inbound_emails`. Si votre application se trouve à `https://example.com`, vous spécifierez l'URL complète `https://example.com/rails/action_mailbox/mandrill/inbound_emails`.

### Postfix

Indiquez à Action Mailbox d'accepter les emails d'un relais SMTP :

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Générez un mot de passe fort que Action Mailbox peut utiliser pour authentifier les requêtes vers l'entrée du relais.

Utilisez `bin/rails credentials:edit` pour ajouter le mot de passe aux credentials chiffrés de votre application sous `action_mailbox.ingress_password`, où Action Mailbox le trouvera automatiquement :

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativement, fournissez le mot de passe dans la variable d'environnement `RAILS_INBOUND_EMAIL_PASSWORD`.

[Configurez Postfix](https://serverfault.com/questions/258469/how-to-configure-postfix-to-pipe-all-incoming-email-to-a-script) pour rediriger les emails entrants vers `bin/rails action_mailbox:ingress:postfix`, en fournissant l'URL de l'entrée Postfix et le `INGRESS_PASSWORD` que vous avez précédemment généré. Si votre application se trouve à `https://example.com`, la commande complète ressemblerait à ceci :

```bash
$ bin/rails action_mailbox:ingress:postfix URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Postmark

Indiquez à Action Mailbox d'accepter les emails de Postmark :

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :postmark
```

Générez un mot de passe fort que Action Mailbox peut utiliser pour authentifier les requêtes vers l'entrée Postmark.

Utilisez `bin/rails credentials:edit` pour ajouter le mot de passe aux credentials chiffrés de votre application sous `action_mailbox.ingress_password`, où Action Mailbox le trouvera automatiquement :

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativement, fournissez le mot de passe dans la variable d'environnement `RAILS_INBOUND_EMAIL_PASSWORD`.

[Configurez le webhook entrant de Postmark](https://postmarkapp.com/manual#configure-your-inbound-webhook-url) pour rediriger les emails entrants vers `/rails/action_mailbox/postmark/inbound_emails` avec le nom d'utilisateur `actionmailbox` et le mot de passe que vous avez précédemment généré. Si votre application se trouve à `https://example.com`, vous configurerez Postmark avec l'URL complète suivante :
```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/postmark/inbound_emails
```

REMARQUE: Lors de la configuration de votre webhook d'entrée Postmark, assurez-vous de cocher la case intitulée **"Inclure le contenu brut de l'e-mail dans la charge utile JSON"**. Action Mailbox a besoin du contenu brut de l'e-mail pour fonctionner.

### Qmail

Indiquez à Action Mailbox d'accepter les e-mails d'un relais SMTP :

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Générez un mot de passe fort que Action Mailbox peut utiliser pour authentifier les demandes vers le relais d'entrée.

Utilisez `bin/rails credentials:edit` pour ajouter le mot de passe aux informations d'identification chiffrées de votre application sous `action_mailbox.ingress_password`, où Action Mailbox le trouvera automatiquement :

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativement, fournissez le mot de passe dans la variable d'environnement `RAILS_INBOUND_EMAIL_PASSWORD`.

Configurez Qmail pour rediriger les e-mails entrants vers `bin/rails action_mailbox:ingress:qmail`, en fournissant l'URL du relais d'entrée et le `INGRESS_PASSWORD` que vous avez généré précédemment. Si votre application se trouve à l'adresse `https://example.com`, la commande complète ressemblerait à ceci :

```bash
$ bin/rails action_mailbox:ingress:qmail URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### SendGrid

Indiquez à Action Mailbox d'accepter les e-mails de SendGrid :

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
```

Générez un mot de passe fort que Action Mailbox peut utiliser pour authentifier les demandes vers le relais SendGrid.

Utilisez `bin/rails credentials:edit` pour ajouter le mot de passe aux informations d'identification chiffrées de votre application sous `action_mailbox.ingress_password`, où Action Mailbox le trouvera automatiquement :

```yaml
action_mailbox:
  ingress_password: ...
```

Alternativement, fournissez le mot de passe dans la variable d'environnement `RAILS_INBOUND_EMAIL_PASSWORD`.

[Configurez l'analyse entrante de SendGrid](https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/) pour rediriger les e-mails entrants vers `/rails/action_mailbox/sendgrid/inbound_emails` avec le nom d'utilisateur `actionmailbox` et le mot de passe que vous avez généré précédemment. Si votre application se trouve à l'adresse `https://example.com`, vous configurerez SendGrid avec l'URL suivante :

```
https://actionmailbox:PASSWORD@example.com/rails/action_mailbox/sendgrid/inbound_emails
```

REMARQUE: Lors de la configuration de votre webhook d'analyse entrante SendGrid, assurez-vous de cocher la case intitulée **"Poster le message MIME brut complet."** Action Mailbox a besoin du message MIME brut pour fonctionner.

## Exemples

Configurez un routage de base :

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing(/^save@/i     => :forwards)
  routing(/@replies\./i => :replies)
end
```

Ensuite, configurez une boîte aux lettres :

```bash
# Générer une nouvelle boîte aux lettres
$ bin/rails generate mailbox forwards
```

```ruby
# app/mailboxes/forwards_mailbox.rb
class ForwardsMailbox < ApplicationMailbox
  # Les rappels spécifient les prérequis pour le traitement
  before_processing :require_projects

  def process
    # Enregistrer la redirection sur le projet unique, ou...
    if forwarder.projects.one?
      record_forward
    else
      # ...impliquer un deuxième Action Mailer pour demander dans quel projet rediriger.
      request_forwarding_project
    end
  end

  private
    def require_projects
      if forwarder.projects.none?
        # Utiliser Action Mailers pour renvoyer les e-mails entrants à l'expéditeur - cela interrompt le traitement
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

## Incinération des InboundEmails

Par défaut, un InboundEmail qui a été traité avec succès sera incinéré après 30 jours. Cela garantit que vous ne conservez pas les données des personnes de manière imprudente après qu'elles aient peut-être annulé leur compte ou supprimé leur contenu. L'intention est qu'après avoir traité un e-mail, vous devriez avoir extrait toutes les données dont vous aviez besoin et les avoir transformées en modèles de domaine et en contenu de votre côté de l'application. L'InboundEmail reste simplement dans le système pendant un certain temps pour fournir des options de débogage et de recherche.

L'incinération réelle est effectuée via le `IncinerationJob` qui est planifié pour s'exécuter après [`config.action_mailbox.incinerate_after`][]. Cette valeur est par défaut définie sur `30.days`, mais vous pouvez la modifier dans votre fichier de configuration production.rb. (Notez que cette planification d'incinération à long terme dépend de votre file d'attente de tâches pouvant conserver les tâches pendant cette durée.)

## Travailler avec Action Mailbox en développement

Il est utile de pouvoir tester les e-mails entrants en développement sans envoyer ni recevoir de vrais e-mails. Pour cela, il y a un contrôleur conductor monté à l'adresse `/rails/conductor/action_mailbox/inbound_emails`, qui vous donne un index de tous les InboundEmails du système, leur état de traitement, ainsi qu'un formulaire pour créer un nouveau InboundEmail.

## Tester les boîtes aux lettres

Exemple :

```ruby
class ForwardsMailboxTest < ActionMailbox::TestCase
  test "enregistrer directement une redirection client pour un expéditeur et un destinataire correspondant à un projet" do
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

Veuillez vous référer à l'API [ActionMailbox::TestHelper](https://api.rubyonrails.org/classes/ActionMailbox/TestHelper.html) pour plus de méthodes d'aide aux tests.
[`config.action_mailbox.incinerate_after`]: configuring.html#config-action-mailbox-incinerate-after
