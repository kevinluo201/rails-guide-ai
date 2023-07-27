**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 8e409a33cc6caed27c82b91e6adad6c7
Aktyvios užduoties pagrindai
=================

Šis vadovas suteiks jums visą informaciją, kurią reikia pradėti kurti,
įtraukti ir vykdyti fono užduotis.

Po šio vadovo perskaitymo, jūs žinosite:

* Kaip kurti užduotis.
* Kaip įtraukti užduotis.
* Kaip vykdyti užduotis fone.
* Kaip siųsti el. laiškus iš savo aplikacijos asinchroniškai.

--------------------------------------------------------------------------------

Kas yra Aktyvi užduotis?
-------------------

Aktyvi užduotis yra karkasas, skirtas deklaruoti užduotis ir paleisti jas įvairiose
eilių užpakaliniuose. Šios užduotys gali būti viskas, nuo reguliariai planuojamų
valymo procedūrų iki sąskaitų apmokestinimo ar siuntimo. Iš tikrųjų, tai gali būti bet kas,
kas gali būti suskaldyta į mažas darbo vienetas ir vykdoma lygiagrečiai.


Aktyvios užduoties tikslas
-----------------------------

Pagrindinis tikslas yra užtikrinti, kad visos „Rails“ programos turėtų užduočių infrastruktūrą
vietoje. Tada galėsime turėti karkaso funkcijas ir kitas juvelyrikas, kurios bus paremtos tuo,
nereikės rūpintis API skirtumais tarp įvairių užduočių vykdytojų, tokių kaip
„Delayed Job“ ir „Resque“. Eilių užpakalio pasirinkimas tampa daugiau operacinės
svarbos klausimu. Be to, galėsite tarp jų perjungti, nereikės persirašyti
jūsų užduočių.

PASTABA: „Rails“ pagal numatytuosius nustatymus yra asinchroninės eilių įgyvendinimo versija, kuri
vykdo užduotis su vidinės gijos baseinu. Užduotys bus vykdomos asinchroniškai, bet bet kokie
užduotys eilėje bus prarandamos paleidus iš naujo.


Užduoties kūrimas
--------------

Šiame skyriuje pateikiamas palaipsniui vadovas, kaip sukurti užduotį ir įtraukti ją.

### Sukurkite užduotį

Aktyvi užduotis teikia „Rails“ generatorių, skirtą kurti užduotis. Šis kodas sukurs
užduotį „app/jobs“ aplanke (su pridėtu testo atveju „test/jobs“ aplanke):

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

Taip pat galite sukurti užduotį, kuri bus vykdoma tam tikroje eilėje:

```bash
$ bin/rails generate job guests_cleanup --queue urgent
```

Jei nenorite naudoti generatoriaus, galite sukurti savo failą „app/jobs“ aplanke,
tik įsitikinkite, kad jis paveldi iš „ApplicationJob“.

Taip atrodo užduotis:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # Padarykite kažką vėliau
  end
end
```

Atkreipkite dėmesį, kad galite apibrėžti „perform“ su tiek argumentų, kiek norite.

Jei jau turite abstrakčią klasę ir jos pavadinimas skiriasi nuo „ApplicationJob“, galite perduoti
„--parent“ parinktį, kad nurodytumėte, kad norite kitos abstrakčios klasės:

```bash
$ bin/rails generate job process_payment --parent=payment_job
```

```ruby
class ProcessPaymentJob < PaymentJob
  queue_as :default

  def perform(*args)
    # Padarykite kažką vėliau
  end
end
```

### Įtraukite užduotį

Įtraukite užduotį naudodami [`perform_later`][] ir, pagal poreikį, [`set`][]. Taip:

```ruby
# Įtraukite užduotį, kuri bus vykdoma, kai tik eilių sistema bus
# laisva.
GuestsCleanupJob.perform_later guest
```

```ruby
# Įtraukite užduotį, kuri bus vykdoma rytoj vidurdienį.
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
```

```ruby
# Įtraukite užduotį, kuri bus vykdoma po 1 savaitės.
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

```ruby
# `perform_now` ir `perform_later` iškvies `perform` viduje, todėl
# galite perduoti tiek argumentų, kiek apibrėžta antrame.
GuestsCleanupJob.perform_later(guest1, guest2, filter: 'some_filter')
```

Tai viskas!


Užduoties vykdymas
-------------

Norint įtraukti ir vykdyti užduotis gamyboje, turite nustatyti eilių užpakalį,
tai yra, turite nuspręsti, kurią trečiosios šalies eilių biblioteką „Rails“ turėtų naudoti.
„Rails“ pats suteikia tik vidinę eilių sistemą, kuri laiko užduotis tik atmintyje.
Jei procesas sutrinka arba mašina iš naujo paleidžiama, tada visos neišspręstos užduotys prarandamos
su numatytuoju asinchroniniu užpakalio adapteriu. Tai gali būti tinkama mažesnėms programoms arba nesvarbioms užduotims, bet dauguma
gamintojo programų turės pasirinkti nuolatinį užpakalį.

### Užpakalniai

Aktyvioje užduotyje yra įdiegti adapteriai daugeliui eilių užpakalinių („Sidekiq“,
„Resque“, „Delayed Job“ ir kt.). Norėdami gauti naujausią adapterių sąrašą,
žiūrėkite API dokumentaciją [`ActiveJob::QueueAdapters`][].


### Nustatykite užpakalnį

Galite lengvai nustatyti savo eilių užpakalnį naudodami [`config.active_job.queue_adapter`]:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Įsitikinkite, kad adapterio juvelyras yra jūsų Gemfile
    # ir laikykitės adapterio konkretaus diegimo
    # ir diegimo instrukcijų.
    config.active_job.queue_adapter = :sidekiq
  end
end
```

Taip pat galite konfigūruoti savo užpakalnį pagal užduotį:

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  # ...
end

# Dabar jūsų užduotis naudos „resque“ kaip savo užpakalnio eilės adapterį, pakeisdama tai,
# kas buvo sukonfigūruota „config.active_job.queue_adapter“.
```
### Pradedant Backend

Kadangi darbai vyksta lygiagrečiai su jūsų „Rails“ programa, dauguma eilės bibliotekų
reikalauja, kad paleistumėte bibliotekos specifinę eilės paslaugą (be
jūsų „Rails“ programos paleidimo), kad darbų apdorojimas veiktų. Norėdami sužinoti,
kaip paleisti eilės backend'ą, žiūrėkite bibliotekos
dokumentaciją.

Čia yra nebaigtas dokumentacijos sąrašas:

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)
- [Que](https://github.com/que-rb/que#additional-rails-specific-setup)
- [Good Job](https://github.com/bensheldon/good_job#readme)

Eilės
------

Dauguma adapterių palaiko kelias eiles. Su „Active Job“ galite suplanuoti
darbą paleisti tam tikroje eilėje naudodami [`queue_as`][]:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

Galite pridėti eilės pavadinimo priešdėlį visiems savo darbams naudodami
[`config.active_job.queue_name_prefix`][] `application.rb` faile:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# Dabar jūsų darbas bus paleistas eilėje production_low_priority jūsų
# produkcinėje aplinkoje ir eilėje staging_low_priority
# jūsų staging aplinkoje
```

Taip pat galite konfigūruoti priešdėlį pagal darbą.

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  self.queue_name_prefix = nil
  # ...
end

# Dabar jūsų darbo eilės pavadinimas nebus priešdėlis, pakeisdamas tai,
# kas buvo sukonfigūruota `config.active_job.queue_name_prefix`.
```

Numatytasis eilės pavadinimo priešdėlio skyriklis yra '\_'. Tai galima pakeisti nustatant
[`config.active_job.queue_name_delimiter`][] `application.rb` faile:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = '.'
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# Dabar jūsų darbas bus paleistas eilėje production.low_priority jūsų
# produkcinėje aplinkoje ir eilėje staging_low_priority
# jūsų staging aplinkoje
```

Jei norite turėti daugiau kontrolės, kuriame darbe bus paleistas darbas, galite perduoti `:queue`
parametrą į `set`:

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

Norėdami kontroliuoti eilę iš darbo lygio, galite perduoti bloką į `queue_as`. Blokas
bus vykdomas darbo kontekste (todėl jis gali pasiekti `self.arguments`),
ir jis turi grąžinti eilės pavadinimą:

```ruby
class ProcessVideoJob < ApplicationJob
  queue_as do
    video = self.arguments.first
    if video.owner.premium?
      :premium_videojobs
    else
      :videojobs
    end
  end

  def perform(video)
    # Daryti kažką su vaizdo įrašu
  end
end
```

```ruby
ProcessVideoJob.perform_later(Video.last)
```

PASTABA: Įsitikinkite, kad jūsų eilės backend'as „klausosi“ jūsų eilės pavadinimo. Kai kuriems
backend'ams reikia nurodyti klausomų eilių sąrašą.


Atgalinio iškvietimo funkcijos
---------

„Active Job“ suteikia „hooks“, skirtus aktyvuoti logiką darbo gyvavimo ciklo metu. Kaip ir
kiti „Rails“ „callbacks“, galite įgyvendinti „callbacks“ kaip įprastus metodus
ir naudoti makro stiliaus klasės metodus, kad juos užregistruotumėte kaip „callbacks“:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # Daryti kažką vėliau
  end

  private
    def around_cleanup
      # Daryti kažką prieš vykdymą
      yield
      # Daryti kažką po vykdymo
    end
end
```

Makro stiliaus klasės metodai taip pat gali priimti bloką. Svarstykite naudoti šį
stilių, jei jūsų bloko viduje esantis kodas yra tokio trumpas, kad telpa vienoje eilutėje.
Pavyzdžiui, galėtumėte siųsti metrikas kiekvienam užduočiui įtrauktam į eilę:

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| $statsd.increment "#{job.class.name.underscore}.enqueue" }
end
```

### Galimi „callbacks“

* [`before_enqueue`][]
* [`around_enqueue`][]
* [`after_enqueue`][]
* [`before_perform`][]
* [`around_perform`][]
* [`after_perform`][]


Veiksmų laiškai
------------

Vienas iš dažniausių darbų modernioje internetinėje aplikacijoje yra el. laiškų siuntimas išorėje
užklausos-atsakymo ciklo, kad vartotojas neturėtų laukti. „Active Job“
yra integruotas su „Action Mailer“, todėl galite lengvai siųsti el. laiškus asinchroniškai:

```ruby
# Jei norite išsiųsti laišką dabar, naudokite #deliver_now
UserMailer.welcome(@user).deliver_now

# Jei norite išsiųsti laišką per „Active Job“, naudokite #deliver_later
UserMailer.welcome(@user).deliver_later
```

PASTABA: Naudoti asinchroninę eilę iš „Rake“ užduoties (pvz., norint
išsiųsti laišką naudojant `.deliver_later`) paprastai neveiks, nes „Rake“
greičiausiai baigs darbą, prieš apdorodamas bet kurį/iš visų
`.deliver_later` laiškus. Norint išvengti šios problemos, naudokite
`.deliver_now` arba paleiskite nuolatinę eilę vystymo metu.


Tarptautinės funkcijos
--------------------

Kiekvienas darbas naudoja `I18n.locale`, nustatytą darbo sukūrimo metu. Tai naudinga, jei siunčiate
el. laiškus asinchroniškai:

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # Laiškas bus lokalizuotas esperanto kalba.
```


Palaikomi argumentų tipai
----------------------------
ActiveJob pagal numatytuosius parametrus palaiko šiuos argumentų tipus:

  - Pagrindiniai tipai (`NilClass`, `String`, `Integer`, `Float`, `BigDecimal`, `TrueClass`, `FalseClass`)
  - `Symbol`
  - `Date`
  - `Time`
  - `DateTime`
  - `ActiveSupport::TimeWithZone`
  - `ActiveSupport::Duration`
  - `Hash` (Raktai turėtų būti `String` arba `Symbol` tipo)
  - `ActiveSupport::HashWithIndifferentAccess`
  - `Array`
  - `Range`
  - `Module`
  - `Class`

### GlobalID

Active Job palaiko [GlobalID](https://github.com/rails/globalid/blob/master/README.md) parametrams. Tai leidžia perduoti gyvus
Active Record objektus į jūsų darbą, o ne klasės/id poras, kurias tada reikia rankiniu būdu deserializuoti. Anksčiau darbai atrodė taip:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

Dabar galite tiesiog tai padaryti:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

Tai veikia su bet kuria klase, kuri maišo `GlobalID::Identification`, kuri
pagal numatytuosius nustatymus yra maišoma į Active Record klases.

### Serializeriai

Galite išplėsti palaikomų argumentų tipų sąrašą. Jums tiesiog reikia apibrėžti savo serializerį:

```ruby
# app/serializers/money_serializer.rb
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  # Patikrina, ar argumentas turėtų būti serializuojamas šiuo serializeriu.
  def serialize?(argument)
    argument.is_a? Money
  end

  # Konvertuoja objektą į paprastesnį atstovą, naudojant palaikomus objektų tipus.
  # Rekomenduojamas atstovas yra `Hash` su tam tikru raktu. Raktai gali būti tik pagrindinių tipų.
  # Turėtumėte iškviesti `super`, kad pridėtumėte pasirinktinį serializerio tipą į `Hash`.
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  # Konvertuoja serializuotą reikšmę į tinkamą objektą.
  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end
end
```

ir pridėkite šį serializerį į sąrašą:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

Atkreipkite dėmesį, kad inicializacijos metu nepalaikomas automatinis kodų pakrovimas. Todėl rekomenduojama
nustatyti, kad serializeriai būtų įkelti tik vieną kartą, pvz., pakeičiant `config/application.rb` taip:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.autoload_once_paths << Rails.root.join('app', 'serializers')
  end
end
```

Išimtys
----------

Darbo vykdymo metu iškeltos išimtys gali būti apdorotos naudojant
[`rescue_from`][]:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # Kažką daryti su išimtimi
  end

  def perform
    # Kažką daryti vėliau
  end
end
```

Jei darbo išimtis nėra išgelbėta, tuomet darbas vadinamas "nepavykęs".


### Nepavykusių darbų pakartojimas arba atsisakymas

Nepavykusio darbo nebus pakartojama, nebent kitaip konfigūruota.

Galima pakartoti arba atsisakyti nepavykusį darbą naudojant [`retry_on`] arba
[`discard_on`], atitinkamai. Pavyzdžiui:

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # numatytasis laukimo laikas yra 3 sekundės, 5 bandymai

  discard_on ActiveJob::DeserializationError

  def perform(*args)
    # Gali sukelti CustomAppException arba ActiveJob::DeserializationError
  end
end
```


### Deserializacija

GlobalID leidžia serializuoti visus perduotus Active Record objektus į `#perform`.

Jei perduotas įrašas yra ištrintas po to, kai darbas yra įtrauktas į eilę, bet prieš tai yra iškviesta `#perform`
metodas, Active Job iškels [`ActiveJob::DeserializationError`][]
išimtį.


Darbo testavimas
--------------

Išsamią instrukciją, kaip testuoti savo darbus, rasite
[testavimo vadove](testing.html#testing-jobs).

Derinimas
---------

Jei jums reikia pagalbos nustatant, iš kur ateina darbai, galite įjungti [išsamų žurnalavimą](debugging_rails_applications.html#verbose-enqueue-logs).
[`perform_later`]: https://api.rubyonrails.org/classes/ActiveJob/Enqueuing/ClassMethods.html#method-i-perform_later
[`set`]: https://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html#method-i-set
[`ActiveJob::QueueAdapters`]: https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html
[`config.active_job.queue_adapter`]: configuring.html#config-active-job-queue-adapter
[`config.active_job.queue_name_delimiter`]: configuring.html#config-active-job-queue-name-delimiter
[`config.active_job.queue_name_prefix`]: configuring.html#config-active-job-queue-name-prefix
[`queue_as`]: https://api.rubyonrails.org/classes/ActiveJob/QueueName/ClassMethods.html#method-i-queue_as
[`before_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_enqueue
[`around_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_enqueue
[`after_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_enqueue
[`before_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_perform
[`around_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_perform
[`after_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_perform
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`discard_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-discard_on
[`retry_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
[`ActiveJob::DeserializationError`]: https://api.rubyonrails.org/classes/ActiveJob/DeserializationError.html
