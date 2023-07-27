**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a547b83b6f036a8e81899330fd515663
Veiksmų pašto dėžutės pagrindai
=====================

Šis vadovas suteiks jums visą informaciją, kurią reikia pradėti gauti
el. laiškus į jūsų programą.

Po šio vadovo perskaitymo, jūs žinosite:

* Kaip gauti el. laiškus savo „Rails“ programoje.
* Kaip konfigūruoti „Action Mailbox“.
* Kaip generuoti ir maršrutizuoti el. laiškus į pašto dėžutę.
* Kaip testuoti gautus el. laiškus.

--------------------------------------------------------------------------------

Kas yra „Action Mailbox“?
-----------------------

„Action Mailbox“ maršrutizuoja gautus el. laiškus į kontrolerio panašias pašto dėžutes,
kurios yra apdorojamos „Rails“. Jis siunčia laiškus per Mailgun, Mandrill, Postmark
ir SendGrid. Taip pat galite tiesiogiai tvarkyti gautus laiškus naudodami įmontuotus Exim,
Postfix ir Qmail įėjimus.

Gauti el. laiškai yra paverčiami į „InboundEmail“ įrašus naudojant „Active Record“
ir turi gyvavimo ciklo sekimą, originalių laiškų saugojimą debesų saugykloje
naudojant „Active Storage“ ir atsakingą duomenų tvarkymą su
numatytuoju sunaikinimu.

Šie gauti el. laiškai yra maršrutizuojami asinchroniškai naudojant „Active Job“ į vieną arba
kelias specialias pašto dėžutes, kurios gali tiesiogiai bendrauti
su jūsų domeno modeliu.

## Nustatymas

Įdiekite migracijas, reikalingas „InboundEmail“, ir įsitikinkite, kad „Active Storage“ yra sukonfigūruotas:

```bash
$ bin/rails action_mailbox:install
$ bin/rails db:migrate
```

## Konfigūracija

### Exim

Pasakykite „Action Mailbox“, kad priimtų laiškus iš SMTP peradresavimo:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Sugeneruokite stiprų slaptažodį, kurį „Action Mailbox“ galės naudoti autentifikuoti užklausas į peradresavimo įėjimą.

Naudokite `bin/rails credentials:edit`, kad pridėtumėte slaptažodį prie jūsų programos užšifruotų kredencialių pagal
`action_mailbox.ingress_password`, kur „Action Mailbox“ jį automatiškai ras:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternatyviai, pateikite slaptažodį `RAILS_INBOUND_EMAIL_PASSWORD` aplinkos kintamajame.

Sukonfigūruokite Exim, kad perduotų gautus laiškus į `bin/rails action_mailbox:ingress:exim`,
nurodydami peradresavimo įėjimo „URL“ ir jau anksčiau sugeneruotą `INGRESS_PASSWORD`. Jei jūsų programa būtų `https://example.com`, 
visas komandos pavyzdys atrodytų taip:

```bash
$ bin/rails action_mailbox:ingress:exim URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun

Pateikite „Action Mailbox“ jūsų
Mailgun pasirašymo raktą (kurį galite rasti nustatymuose -> Sauga ir vartotojai -> API sauga „Mailgun“),
kad jis galėtų autentifikuoti užklausas į „Mailgun“ įėjimą.

Naudokite `bin/rails credentials:edit`, kad pridėtumėte savo pasirašymo raktą prie jūsų programos
užšifruotų kredencialių pagal `action_mailbox.mailgun_signing_key`,
kur „Action Mailbox“ jį automatiškai ras:

```yaml
action_mailbox:
  mailgun_signing_key: ...
```

Alternatyviai, pateikite savo pasirašymo raktą `MAILGUN_INGRESS_SIGNING_KEY` aplinkos kintamajame.

Pasakykite „Action Mailbox“, kad priimtų laiškus iš „Mailgun“:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mailgun
```

[Nuostatykite „Mailgun“](https://documentation.mailgun.com/en/latest/user_manual.html#receiving-forwarding-and-storing-messages)
peradresuoti gautus laiškus į `/rails/action_mailbox/mailgun/inbound_emails/mime`.
Jei jūsų programa būtų `https://example.com`, jūs nurodytumėte
visiškai kvalifikuotą „URL“ `https://example.com/rails/action_mailbox/mailgun/inbound_emails/mime`.

### Mandrill

Pateikite „Action Mailbox“ savo Mandrill API raktą, kad jis galėtų autentifikuoti užklausas į
Mandrill įėjimą.

Naudokite `bin/rails credentials:edit`, kad pridėtumėte savo API raktą prie jūsų programos
užšifruotų kredencialių pagal `action_mailbox.mandrill_api_key`,
kur „Action Mailbox“ jį automatiškai ras:

```yaml
action_mailbox:
  mandrill_api_key: ...
```

Alternatyviai, pateikite savo API raktą `MANDRILL_INGRESS_API_KEY` aplinkos kintamajame.

Pasakykite „Action Mailbox“, kad priimtų laiškus iš Mandrill:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :mandrill
```

[Nuostatykite Mandrill](https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview)
peradresuoti gautus laiškus į `/rails/action_mailbox/mandrill/inbound_emails`.
Jei jūsų programa būtų `https://example.com`, jūs nurodytumėte
visiškai kvalifikuotą „URL“ `https://example.com/rails/action_mailbox/mandrill/inbound_emails`.

### Postfix

Pasakykite „Action Mailbox“, kad priimtų laiškus iš SMTP peradresavimo:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Sugeneruokite stiprų slaptažodį, kurį „Action Mailbox“ galės naudoti autentifikuoti užklausas į peradresavimo įėjimą.

Naudokite `bin/rails credentials:edit`, kad pridėtumėte slaptažodį prie jūsų programos užšifruotų kredencialių pagal
`action_mailbox.ingress_password`, kur „Action Mailbox“ jį automatiškai ras:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternatyviai, pateikite slaptažodį `RAILS_INBOUND_EMAIL_PASSWORD` aplinkos kintamajame.

[Sukonfigūruokite Postfix](https://serverfault.com/questions/258469/how-to-configure-postfix-to-pipe-all-incoming-email-to-a-script)
perduoti gautus laiškus į `bin/rails action_mailbox:ingress:postfix`, nurodydami
Postfix įėjimo „URL“ ir jau anksčiau sugeneruotą `INGRESS_PASSWORD`. Jei jūsų programa būtų `https://example.com`, 
visas komandos pavyzdys atrodytų taip:

```bash
$ bin/rails action_mailbox:ingress:postfix URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Postmark

Pasakykite „Action Mailbox“, kad priimtų laiškus iš Postmark:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :postmark
```

Sugeneruokite stiprų slaptažodį, kurį „Action Mailbox“ galės naudoti autentifikuoti
užklausas į Postmark įėjimą.

Naudokite `bin/rails credentials:edit`, kad pridėtumėte slaptažodį prie jūsų programos
užšifruotų kredencialių pagal `action_mailbox.ingress_password`,
kur „Action Mailbox“ jį automatiškai ras:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternatyviai, pateikite slaptažodį `RAILS_INBOUND_EMAIL_PASSWORD`
aplinkos kintamajame.

[Nuostatykite Postmark įeinančią webhooks](https://postmarkapp.com/manual#configure-your-inbound-webhook-url)
peradresuoti gautus laiškus į `/rails/action_mailbox/postmark/inbound_emails` su vartotojo vardu `actionmailbox`
ir jau anksčiau sugeneruotu slaptažodžiu. Jei jūsų programa būtų `https://example.com`, jūs
konfigūruotumėte Postmark su šiuo visiškai kvalifikuotu „URL“:
```
https://actionmailbox:SLAPTAŽODIS@example.com/rails/action_mailbox/postmark/inbound_emails
```

PASTABA: Konfigūruojant Postmark įeinamąjį webhook'ą, įsitikinkite, kad pažymėtas langelis **"Įtraukti žalią el. pašto turinį JSON pakete"**. Action Mailbox reikia žalio el. pašto turinio, kad galėtų veikti.

### Qmail

Nurodykite Action Mailbox priimti el. laiškus iš SMTP peradresavimo:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :relay
```

Sukurkite stiprų slaptažodį, kurį Action Mailbox galės naudoti autentifikuoti užklausas į peradresavimo įėjimą.

Naudokite `bin/rails credentials:edit`, kad pridėtumėte slaptažodį prie jūsų programos užšifruotų kredencialių po `action_mailbox.ingress_password`, kur Action Mailbox jį automatiškai ras:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternatyviai, slaptažodį galite nurodyti `RAILS_INBOUND_EMAIL_PASSWORD` aplinkos kintamajame.

Konfigūruokite Qmail perduoti įeinamuosius el. laiškus į `bin/rails action_mailbox:ingress:qmail`,
nurodydami peradresavimo įėjimo `URL` ir anksčiau sugeneruotą `INGRESS_PASSWORD`. Jei jūsų programa būtų `https://example.com`, visiškas komandos pavyzdys atrodytų taip:

```bash
$ bin/rails action_mailbox:ingress:qmail URL=https://example.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### SendGrid

Nurodykite Action Mailbox priimti el. laiškus iš SendGrid:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
```

Sukurkite stiprų slaptažodį, kurį Action Mailbox galės naudoti autentifikuoti užklausas į SendGrid įėjimą.

Naudokite `bin/rails credentials:edit`, kad pridėtumėte slaptažodį prie jūsų programos užšifruotų kredencialių po `action_mailbox.ingress_password`, kur Action Mailbox jį automatiškai ras:

```yaml
action_mailbox:
  ingress_password: ...
```

Alternatyviai, slaptažodį galite nurodyti `RAILS_INBOUND_EMAIL_PASSWORD` aplinkos kintamajame.

[Nuostatų SendGrid Inbound Parse](https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/)
peradresuoti įeinamuosius el. laiškus į
`/rails/action_mailbox/sendgrid/inbound_emails` su vartotojo vardu `actionmailbox`
ir anksčiau sugeneruotu slaptažodžiu. Jei jūsų programa būtų `https://example.com`,
SendGrid konfigūracija atrodytų taip:

```
https://actionmailbox:SLAPTAŽODIS@example.com/rails/action_mailbox/sendgrid/inbound_emails
```

PASTABA: Konfigūruojant SendGrid Inbound Parse webhook'ą, įsitikinkite, kad pažymėtas langelis **“Siųsti žalią, visą MIME žinutę.”** Action Mailbox reikia žalios MIME žinutės, kad galėtų veikti.

## Pavyzdžiai

Konfigūruokite pagrindinį maršrutizavimą:

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing(/^save@/i     => :forwards)
  routing(/@replies\./i => :replies)
end
```

Tada sukurkite pašto dėžutę:

```bash
# Generuoti naują pašto dėžutę
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

## InboundEmails sunaikinimas

Pagal numatytuosius nustatymus, sėkmingai apdorotas InboundEmail bus sunaikintas po 30 dienų. Tai užtikrina, kad nebeturėsite žmonių duomenų, kai jie galbūt atšauks savo paskyras arba ištrins savo turinį. Tikslas yra tai, kad po el. laiško apdorojimo turėtumėte išgauti visus reikalingus duomenis ir juos paversti domeno modeliais ir turiniu jūsų programos pusėje. InboundEmail tiesiog lieka sistemoje papildomam laikui, kad būtų galima atlikti derinimo ir tyrimo veiksmus.

Tikras sunaikinimas atliekamas naudojant `IncinerationJob`, kuris yra suplanuotas paleisti po [`config.action_mailbox.incinerate_after`][] laiko. Ši vertė pagal numatytuosius nustatymus yra `30.days`, bet galite ją pakeisti savo production.rb konfigūracijoje. (Atkreipkite dėmesį, kad tolimojoje ateityje suplanuotas sunaikinimas priklauso nuo jūsų darbo eilės galimybės laikyti užduotis tiek ilgai.)


## Darbas su Action Mailbox kūrimo metu

Naudinga galėti testuoti įeinančius el. laiškus kūrimo metu, nesiunčiant ir negavus tikrų el. laiškų. Tam yra konduktorius valdiklis, įdiegtas adresu `/rails/conductor/action_mailbox/inbound_emails`,
kuris suteikia jums visų InboundEmail sistemose sąrašą, jų apdorojimo būseną ir formą naujam InboundEmail kūrimui.

## Pašto dėžučių testavimas

Pavyzdys:

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

Norėdami gauti daugiau informacijos apie testavimo pagalbinės funkcijos, žiūrėkite [ActionMailbox::TestHelper API](https://api.rubyonrails.org/classes/ActionMailbox/TestHelper.html).
```
[`config.action_mailbox.incinerate_after`]: configuring.html#config-action-mailbox-incinerate-after
