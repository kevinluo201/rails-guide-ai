**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 95d91c83726e012162afc60c78688099
Ruby on Rails 4.1 Išleidimo pastabos
===============================

Svarbiausios naujovos Rails 4.1 versijoje:

* Spring aplikacijos įkroviklis
* `config/secrets.yml`
* Action Pack variantai
* Action Mailer peržiūros

Šiose išleidimo pastabose aptariamos tik pagrindinės naujovos. Norėdami sužinoti apie įvairius klaidų taisymus ir pakeitimus, prašome kreiptis į pakeitimų žurnalus arba peržiūrėti [pakeitimų sąrašą](https://github.com/rails/rails/commits/4-1-stable) pagrindiniame Rails saugykloje GitHub'e.

--------------------------------------------------------------------------------

Atnaujinimas iki Rails 4.1
----------------------

Jei atnaujinote esamą aplikaciją, gerai būtų turėti gerą testų padengimą prieš pradedant. Taip pat pirmiausia turėtumėte atnaujinti iki Rails 4.0, jei dar to nedarėte, ir įsitikinti, kad jūsų aplikacija veikia kaip tikėtasi, prieš bandant atnaujinti iki Rails 4.1. Atnaujinimo metu reikėtų atkreipti dėmesį į keletą dalykų, kuriuos galima rasti [Ruby on Rails atnaujinimo](upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1) vadove.

Pagrindinės funkcijos
--------------

### Spring aplikacijos įkroviklis

Spring yra Rails aplikacijos įkroviklis. Jis pagreitina plėtrą, paliekant aplikaciją veikiančią fone, todėl jums nereikia jos paleisti kiekvieną kartą, kai vykdote testą, rake užduotį ar migraciją.

Naujos Rails 4.1 aplikacijos bus pristatomos su "springified" binstubais. Tai reiškia, kad `bin/rails` ir `bin/rake` automatiškai pasinaudos įkrautomis spring aplinkomis.

**Vykdyti rake užduotis:**

```bash
$ bin/rake test:models
```

**Vykdyti Rails komandą:**

```bash
$ bin/rails console
```

**Spring introspekcija:**

```bash
$ bin/spring status
Spring veikia:

 1182 spring server | my_app | pradėtas prieš 29 min.
 3656 spring app    | my_app | pradėtas prieš 23 sek. | testavimo režimas
 3746 spring app    | my_app | pradėtas prieš 10 sek. | plėtros režimas
```

Norėdami pamatyti visas galimas funkcijas, žiūrėkite [Spring README](https://github.com/rails/spring/blob/master/README.md).

Norėdami sužinoti, kaip perkelti esamas aplikacijas naudoti šią funkciją, žiūrėkite [Ruby on Rails atnaujinimo](upgrading_ruby_on_rails.html#spring) vadovą.

### `config/secrets.yml`

Rails 4.1 generuoja naują `secrets.yml` failą `config` aplanke. Pagal numatytuosius nustatymus, šis failas turi aplikacijos `secret_key_base`, tačiau jame taip pat galima saugoti kitus paslaptis, pvz., prieigos raktus prie išorinių API.

Šiame faile pridėtos paslaptys pasiekiamos per `Rails.application.secrets`. Pavyzdžiui, turint šį `config/secrets.yml`:

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

`Rails.application.secrets.some_api_key` grąžina `SOMEKEY` vystymo aplinkoje.

Norėdami sužinoti, kaip perkelti esamas aplikacijas naudoti šią funkciją, žiūrėkite [Ruby on Rails atnaujinimo](upgrading_ruby_on_rails.html#config-secrets-yml) vadovą.

### Action Pack variantai

Dažnai norime atvaizduoti skirtingus HTML/JSON/XML šablonus telefonams, planšetėms ir stalinėms naršyklėms. Variantai tai padaro lengva.

Užklausos variantas yra užklausos formato specializacija, pvz., `:tablet`, `:phone` ar `:desktop`.

Variantą galite nustatyti `before_action`:

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

Atsakykite į variantus veiksmuose taip pat, kaip atsakytumėte į formatus:

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # atvaizduoja app/views/projects/show.html+tablet.erb
    html.phone { extra_setup; render ... }
  end
end
```

Pateikite atskirus šablonus kiekvienam formatai ir variantui:

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

Variantų apibrėžimą taip pat galite supaprastinti naudodami įterptinį sintaksę:

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```
### Veiksmų laiškų peržiūros

Veiksmų laiškų peržiūros suteikia galimybę peržiūrėti, kaip atrodo laiškai, aplankant
specialų URL, kuris juos atvaizduoja.

Jūs įgyvendinate peržiūros klasę, kurios metodai grąžina laiško objektą, kurį norite
patikrinti:

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

Peržiūra yra pasiekiamas adresu http://localhost:3000/rails/mailers/notifier/welcome,
o jų sąrašas - adresu http://localhost:3000/rails/mailers.

Pagal numatytuosius nustatymus, šios peržiūros klasės yra laikomos `test/mailers/previews`.
Tai galima konfigūruoti naudojant `preview_path` parinktį.

Žr. jos
[dokumentaciją](https://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails)
išsamiam aprašymui.

### Aktyvių įrašų enumai

Deklaruokite enum atributą, kurio reikšmės atitinka skaičius duomenų bazėje, bet
gali būti užklausiamos pagal pavadinimą.

```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => Visi archyvuoti pokalbiai

Conversation.statuses # => { "active" => 0, "archived" => 1 }
```

Žr. jos
[dokumentaciją](https://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html)
išsamiam aprašymui.

### Pranešimų patikrinimo priemonės

Pranešimų patikrinimo priemonės gali būti naudojamos generuoti ir patikrinti parašytus pranešimus. Tai gali
būti naudinga saugiai perduoti jautrią informaciją, pvz., prisimink mane žetonus ir
draugus.

Metodas `Rails.application.message_verifier` grąžina naują pranešimų patikrinimo priemonę,
kuri parašo pranešimus naudojant iš `secret_key_base` ir duotą
pranešimų patikrinimo priemonės pavadinimą išvestą raktą:

```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# iškelia ActiveSupport::MessageVerifier::InvalidSignature klaidą
```

### Modulio#concerning

Natūralus, mažai ceremonijų būdas atskirti atsakomybes klasėje:

```ruby
class Todo < ActiveRecord::Base
  concerning :EventTracking do
    included do
      has_many :events
    end

    def latest_event
      # ...
    end

    private
      def some_internal_method
        # ...
      end
  end
end
```

Šis pavyzdys yra ekvivalentus `EventTracking` modulio apibrėžimui tiesiogiai,
išplėčiant jį su `ActiveSupport::Concern` ir tada įmaišant į
`Todo` klasę.

Žr. jos
[dokumentaciją](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html)
išsamiam aprašymui ir numatytiesiems naudojimo atvejams.

### CSRF apsauga nuo nuotolinės `<script>` žymės

Tarp svetainių užklausų sukčiavimo (CSRF) apsauga dabar taip pat apima GET užklausas su
JavaScript atsakymais. Tai neleidžia trečiosioms šalims nuorodinti
jūsų JavaScript URL ir bandyti jį paleisti, kad išgautų jautrią informaciją.

Tai reiškia, kad bet kuris jūsų testas, kuris pasiekia `.js` URL, dabar nepavyks CSRF apsauga,
jei jie nenaudoja `xhr`. Atnaujinkite savo testus, kad būtų aišku, jog tikimasi
XmlHttpRequests. Vietoje `post :create, format: :js`, pakeiskite į aiškų
`xhr :post, :create, format: :js`.


Railties
--------

Išsamūs pakeitimai pateikti
[Changelog](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md)
.

### Pašalinimai

* Pašalintas `update:application_controller` rake užduotis.

* Pašalintas pasenusių `Rails.application.railties.engines`.

* Pašalintas pasenusių `threadsafe!` iš Rails konfigūracijos.

* Pašalintas pasenusių `ActiveRecord::Generators::ActiveModel#update_attributes` naudai
  `ActiveRecord::Generators::ActiveModel#update`.

* Pašalintas pasenusių `config.whiny_nils` parinktis.

* Pašalintos pasenusios rake užduotys testams vykdyti: `rake test:uncommitted` ir
  `rake test:recent`.

### Pastebimi pakeitimai

* [Spring aplikacijos
  prikrovimas](https://github.com/rails/spring) dabar yra
  įdiegtas pagal numatytuosius nustatymus naujoms aplikacijoms. Jis naudoja `Gemfile` plėtros grupę,
  todėl nebus įdiegtas
  produkcijoje. ([Pull Request](https://github.com/rails/rails/pull/12958))

* `BACKTRACE` aplinkos kintamasis, skirtas rodyti nesufiltruotas grįžtines nuorodas testo
  nesėkmėms. ([Commit](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553))

* Prieinama `MiddlewareStack#unshift` aplinkos konfigūracijai.
  ([Pull Request](https://github.com/rails/rails/pull/12479))

* Pridėtas `Application#message_verifier` metodas, skirtas grąžinti pranešimų
  patikrinimo priemonę. ([Pull Request](https://github.com/rails/rails/pull/12995))

* `test_help.rb` failas, kurį reikalauja numatytasis sugeneruotas testo
  pagalbininkas, automatiškai atnaujina jūsų testų duomenų bazę su
  `db/schema.rb` (arba `db/structure.sql`). Jis iškelia klaidą, jei
  schemos perkrovimas neišsprendžia visų laukiančių migracijų. Atsisakykite
  su `config.active_record.maintain_test_schema = false`. ([Pull
  Request](https://github.com/rails/rails/pull/13528))
* Pristatoma `Rails.gem_version` kaip patogus metodas, grąžinantis `Gem::Version.new(Rails.version)`, siūlantis patikimesnį būdą atlikti versijų palyginimą. ([Pull Request](https://github.com/rails/rails/pull/14103))


Action Pack
-----------

Išsamių pakeitimų informacijai žiūrėkite
[Changelog](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md).

### Pašalinimai

* Pašalintas pasenusiųjų "Rails" aplikacijų atsarginis planas integraciniam testavimui, nustatykite
  `ActionDispatch.test_app` vietoj to.

* Pašalintas pasenusi `page_cache_extension` konfigūracijos parametras.

* Pašalintas pasenusi `ActionController::RecordIdentifier`, naudokite
  `ActionView::RecordIdentifier` vietoj to.

* Pašalinti pasenusiųjų konstantų iš veiksmų valdiklio sąrašas:

| Pašalinta                           | Naujas                            |
|:-----------------------------------|:--------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### Svarbūs pakeitimai

* `protect_from_forgery` taip pat neleidžia kirsti peržiūros `<script>` žymas.
  Atnaujinkite savo testus, kad naudotumėte `xhr :get, :foo, format: :js` vietoj
  `get :foo, format: :js`.
  ([Pull Request](https://github.com/rails/rails/pull/13345))

* `#url_for` priima raktų rinkinį su parinktimis masyve. ([Pull Request](https://github.com/rails/rails/pull/9599))

* Pridėtas `session#fetch` metodas, kuris veikia panašiai kaip
  [Hash#fetch](https://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch),
  išskyrus tai, kad grąžinama reikšmė visada įrašoma į seansą. ([Pull Request](https://github.com/rails/rails/pull/12692))

* Visiškai atskirta veiksmų peržiūra nuo veiksmų
  paketo. ([Pull Request](https://github.com/rails/rails/pull/11032))

* Užregistruojamos giliai keičiamos rakto reikšmės.
  ([Pull Request](https://github.com/rails/rails/pull/13813))

* Naujas konfigūracijos parametras `config.action_dispatch.perform_deep_munge`, leidžiantis išjungti
  parametrų "gilią keitimą", kuris buvo naudojamas siekiant išspręsti saugumo pažeidimo
  CVE-2013-0155 problemą. ([Pull Request](https://github.com/rails/rails/pull/13188))

* Naujas konfigūracijos parametras `config.action_dispatch.cookies_serializer`, skirtas nurodyti
  serijalizatorių pasirašytoms ir užšifruotoms slapukų talpykloms. (Pull Requests
  [1](https://github.com/rails/rails/pull/13692),
  [2](https://github.com/rails/rails/pull/13945) /
  [Daugiau informacijos](upgrading_ruby_on_rails.html#cookies-serializer))

* Pridėti `render :plain`, `render :html` ir `render
  :body`. ([Pull Request](https://github.com/rails/rails/pull/14062) /
  [Daugiau informacijos](upgrading_ruby_on_rails.html#rendering-content-from-string))


Action Mailer
-------------

Išsamių pakeitimų informacijai žiūrėkite
[Changelog](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md).

### Svarbūs pakeitimai

* Pridėta pašto peržiūros funkcija, pagrįsta 37 Signals mail_view
  gem. ([Commit](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261))

* Instrumentuojama veiksmų pašto žinučių generavimas. Sugaištas laikas, reikalingas
  žinutės generavimui, yra įrašomas į žurnalą. ([Pull Request](https://github.com/rails/rails/pull/12556))


Active Record
-------------

Išsamių pakeitimų informacijai žiūrėkite
[Changelog](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md).

### Pašalinimai

* Pašalintas pasenusiųjų `SchemaCache` metodų, kuriems buvo perduodamas `nil`, palaikymas:
  `primary_keys`, `tables`, `columns` ir `columns_hash`.

* Pašalintas pasenusi bloko filtras iš `ActiveRecord::Migrator#migrate`.

* Pašalintas pasenusi `String` konstruktorius iš `ActiveRecord::Migrator`.

* Pašalintas pasenusi `scope` naudojimas be perduodamo iškviečiamojo objekto.

* Pašalintas pasenusi `transaction_joinable=` metodas, naudokite `begin_transaction`
  su `:joinable` parinktimi.

* Pašalintas pasenusi `decrement_open_transactions` metodas.

* Pašalintas pasenusi `increment_open_transactions` metodas.

* Pašalintas pasenusi `PostgreSQLAdapter#outside_transaction?`
  metodas. Vietoj to galite naudoti `#transaction_open?`.

* Pašalintas pasenusi `ActiveRecord::Fixtures.find_table_name`, naudokite
  `ActiveRecord::Fixtures.default_fixture_model_name` vietoj to.

* Pašalintas pasenusi `columns_for_remove` iš `SchemaStatements`.

* Pašalintas pasenusi `SchemaStatements#distinct` metodas.

* Perkeltas pasenusi `ActiveRecord::TestCase` į "Rails" testų
  rinkinį. Klasė daugiau nėra vieša ir naudojama tik vidinėms
  "Rails" testams.

* Pašalinta palaikymo užbaigimo parinktis `:restrict` asociacijose.

* Pašalintos palaikymo parinktys `:delete_sql`, `:insert_sql`, `:finder_sql`
  ir `:counter_sql` asociacijose.

* Pašalintas pasenusi `type_cast_code` metodas iš `Column`.

* Pašalintas pasenusi `ActiveRecord::Base#connection` metodas.
  Įsitikinkite, kad jį pasiekiate per klasę.

* Pašalintas pasenusi įspėjimas dėl `auto_explain_threshold_in_seconds`.

* Pašalinta pasenusi `:distinct` parinktis iš `Relation#count`.

* Pašalinti pasenusi metodai `partial_updates`, `partial_updates?` ir
  `partial_updates=`.

* Pašalintas pasenusi metodas `scoped`.

* Pašalintas pasenusi metodas `default_scopes?`.

* Pašalintos neaiškios sąsajos nuorodos, kurios buvo pasenusios nuo 4.0.
* Pašalinta `activerecord-deprecated_finders` kaip priklausomybė.
  Daugiau informacijos rasite [gem README](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders).

* Pašalintas `implicit_readonly` naudojimas. Prašome naudoti `readonly` metodą
  aiškiai pažymėti įrašus kaip `readonly`. ([Pull Request](https://github.com/rails/rails/pull/10769))

### Pasenusios funkcijos

* Pasenusas `quoted_locking_column` metodas, kuris niekur nenaudojamas.

* Pasenusas `ConnectionAdapters::SchemaStatements#distinct`,
  nes jis daugiau nenaudojamas viduje. ([Pull Request](https://github.com/rails/rails/pull/10556))

* Pasenusos `rake db:test:*` užduotys, nes testavimo duomenų bazė dabar
  automatiškai prižiūrima. Žr. railties išleidimo pastabas. ([Pull
  Request](https://github.com/rails/rails/pull/13528))

* Pasenusos nenaudojamos `ActiveRecord::Base.symbolized_base_class`
  ir `ActiveRecord::Base.symbolized_sti_name` be
  pakeitimo. [Commit](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)

### Svarbūs pakeitimai

* Numatytieji apribojimai daugiau nebus perrašomi sujungtomis sąlygomis.

  Prieš šį pakeitimą, kai apibrėždavote `default_scope` modelyje,
  jis buvo perrašomas sujungtomis sąlygomis tame pačiame lauke. Dabar jis
  yra sujungiamas kaip bet koks kitas rėmelis. [Daugiau informacijos](upgrading_ruby_on_rails.html#changes-on-default-scopes).

* Pridėtas `ActiveRecord::Base.to_param` patogiam "gražių" URL, gautų iš
  modelio atributo arba
  metodo. ([Pull Request](https://github.com/rails/rails/pull/12891))

* Pridėtas `ActiveRecord::Base.no_touching`, kuris leidžia ignoruoti prisilietimą prie
  modelių. ([Pull Request](https://github.com/rails/rails/pull/12772))

* Suvienodintas `MysqlAdapter` ir `Mysql2Adapter` boolean tipo keitimas.
  `type_cast` grąžins `1` `true` ir `0` `false`. ([Pull Request](https://github.com/rails/rails/pull/12425))

* `.unscope` dabar pašalina sąlygas, nurodytas
  `default_scope`. ([Commit](https://github.com/rails/rails/commit/94924dc32baf78f13e289172534c2e71c9c8cade))

* Pridėtas `ActiveRecord::QueryMethods#rewhere`, kuris perrašys esamą,
  pavadintą sąlygą. ([Commit](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2))

* Išplėstas `ActiveRecord::Base#cache_key`, kad priimtų pasirinktinį aukščiausio laiko žymės
  atributų sąrašą. ([Commit](https://github.com/rails/rails/commit/e94e97ca796c0759d8fcb8f946a3bbc60252d329))

* Pridėtas `ActiveRecord::Base#enum` atributų, kurie žemėlapyje atitinka sveikus skaičius,
  deklaravimui pagal pavadinimą. ([Commit](https://github.com/rails/rails/commit/db41eb8a6ea88b854bf5cd11070ea4245e1639c5))

* Tipo keitimas JSON reikšmėms rašant, kad reikšmė būtų suderinta su skaitymu
  iš duomenų bazės. ([Pull Request](https://github.com/rails/rails/pull/12643))

* Tipo keitimas hstore reikšmėms rašant, kad reikšmė būtų suderinta
  su skaitymu iš duomenų bazės. ([Commit](https://github.com/rails/rails/commit/5ac2341fab689344991b2a4817bd2bc8b3edac9d))

* `next_migration_number` pasiekiamas trečiųjų šalių
  generatoriams. ([Pull Request](https://github.com/rails/rails/pull/12407))

* Kvietimas `update_attributes` dabar išmes `ArgumentError`, kai
  gauna `nil` argumentą. Konkrečiau, jis išmes klaidą, jei
  argumentas, kurį jis gauna, neatitinka `stringify_keys`. ([Pull Request](https://github.com/rails/rails/pull/9860))

* `CollectionAssociation#first`/`#last` (pvz., `has_many`) naudoja `LIMIT` užklausą
  gauti rezultatus, o ne įkelti visą
  kolekciją. ([Pull Request](https://github.com/rails/rails/pull/12137))

* `inspect` veiksmas ant Active Record modelio klasės nepradės naujos
  ryšio. Tai reiškia, kad kviečiant `inspect`, kai nėra duomenų bazės,
  nebesukels išimties. ([Pull Request](https://github.com/rails/rails/pull/11014))

* Pašalinti stulpelių apribojimai `count`, leisti duomenų bazės iškelti klaidą, jei SQL yra
  neteisingas. ([Pull Request](https://github.com/rails/rails/pull/10710))

* Rails dabar automatiškai aptinka atvirkštines asociacijas. Jei nenurodote
  `:inverse_of` parinkties asociacijoje, tada Active Record pagal heuristiką spės atvirkštinę asociaciją. ([Pull Request](https://github.com/rails/rails/pull/10886))

* Tvarkyti pavadinimai ActiveRecord::Relation. Naudojant simbolius,
  ActiveRecord dabar verčia pavadinimus į tikrąjį stulpelio
  pavadinimą, naudojamą duomenų bazėje. ([Pull Request](https://github.com/rails/rails/pull/7839))

* ERB fixture failuose nebevertinamas pagrindinio
  objekto kontekste. Pagalbiniai metodai, naudojami keliems fixture'ams, turėtų būti apibrėžti moduliuose,
  įtrauktose į `ActiveRecord::FixtureSet.context_class`. ([Pull Request](https://github.com/rails/rails/pull/13022))

* Nesukurti arba ištrinti testavimo duomenų bazės, jei RAILS_ENV yra nurodytas
  aiškiai. ([Pull Request](https://github.com/rails/rails/pull/13629))

* `Relation` daugiau neturi mutatoriaus metodų, pvz., `#map!` ir `#delete_if`. Prieš naudojant šiuos metodus, konvertuokite
  į `Array`, iškviesdami `#to_a`. ([Pull Request](https://github.com/rails/rails/pull/13314))
* `find_in_batches`, `find_each`, `Result#each` ir `Enumerable#index_by` dabar grąžina `Enumerator`, kuris gali apskaičiuoti savo dydį. ([Pull Request](https://github.com/rails/rails/pull/13938))

* `scope`, `enum` ir asociacijos dabar iškelia klaidą dėl "pavojingų" pavadinimų konfliktų. ([Pull Request](https://github.com/rails/rails/pull/13450), [Pull Request](https://github.com/rails/rails/pull/13896))

* `second` iki `fifth` metodai veikia kaip `first` paieškos funkcija. ([Pull Request](https://github.com/rails/rails/pull/13757))

* `touch` dabar iškviečia `after_commit` ir `after_rollback` callback'us. ([Pull Request](https://github.com/rails/rails/pull/12031))

* Įgalinti dalinės indeksus `sqlite >= 3.8.0`. ([Pull Request](https://github.com/rails/rails/pull/13350))

* `change_column_null` dabar gali būti atšaukiamas. ([Commit](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96))

* Pridėtas vėliavėlė, kuri išjungia schemos iškrovimą po migracijos. Naujiems programų diegimams, pagal nutylėjimą, ši vėliavėlė yra nustatyta kaip `false` produkcijos aplinkoje. ([Pull Request](https://github.com/rails/rails/pull/13948))

Active Model
------------

Išsamūs pakeitimai galima rasti
[Changelog](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md)
puslapyje.

### Pasenusios funkcijos

* Pasenusi `Validator#setup` funkcija. Dabar tai turi būti atliekama rankiniu būdu validatoriaus konstruktoriuje. ([Commit](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a))

### Svarbūs pakeitimai

* Pridėtos naujos API funkcijos `reset_changes` ir `changes_applied` `ActiveModel::Dirty` klasėje, kurios valdo pakeitimų būseną.

* Galimybė nurodyti kelis kontekstus, kai apibrėžiama validacija. ([Pull Request](https://github.com/rails/rails/pull/13754))

* `attribute_changed?` dabar priima hash'ą, kuris patikrina, ar atributas buvo pakeistas `:from` ir/arba `:to` tam tikrai reikšmei. ([Pull Request](https://github.com/rails/rails/pull/13131))


Active Support
--------------

Išsamūs pakeitimai galima rasti
[Changelog](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md)
puslapyje.

### Pašalinimai

* Pašalinta `MultiJSON` priklausomybė. Dėl to, `ActiveSupport::JSON.decode` funkcija daugiau negali priimti parametrų hash'ui `MultiJSON`. ([Pull Request](https://github.com/rails/rails/pull/10576) / [Daugiau informacijos](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Pašalinta palaikymas `encode_json` kablysai, naudojamiems kodo objektų kodavimui į JSON formatą. Ši funkcija buvo išskirta į [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) priklausomybę. ([Susijęs Pull Request](https://github.com/rails/rails/pull/12183) / [Daugiau informacijos](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Pašalinta pasenusi `ActiveSupport::JSON::Variable` be pakeitimo.

* Pašalintas pasenusi `String#encoding_aware?` pagrindinių plėtinių (`core_ext/string/encoding`).

* Pašalintas pasenusi `Module#local_constant_names` funkcija, naudojant `Module#local_constants` funkciją.

* Pašalintas pasenusi `DateTime.local_offset` funkcija, naudojant `DateTime.civil_from_format` funkciją.

* Pašalintos pasenusios `Logger` pagrindinės plėtinės (`core_ext/logger.rb`).

* Pašalintos pasenusios `Time#time_with_datetime_fallback`, `Time#utc_time` ir `Time#local_time` funkcijos, naudojant `Time#utc` ir `Time#local` funkcijas.

* Pašalinta pasenusi `Hash#diff` funkcija be pakeitimo.

* Pašalinta pasenusi `Date#to_time_in_current_zone` funkcija, naudojant `Date#in_time_zone` funkciją.

* Pašalinta pasenusi `Proc#bind` funkcija be pakeitimo.

* Pašalintos pasenusios `Array#uniq_by` ir `Array#uniq_by!` funkcijos, naudokite natyvias `Array#uniq` ir `Array#uniq!` funkcijas.

* Pašalinta pasenusi `ActiveSupport::BasicObject` klasė, naudokite `ActiveSupport::ProxyObject` klasę.

* Pašalintas pasenusi `BufferedLogger`, naudokite `ActiveSupport::Logger` klasę.

* Pašalintos pasenusios `assert_present` ir `assert_blank` funkcijos, naudokite `assert object.blank?` ir `assert object.present?` funkcijas.

* Pašalinta pasenusi `#filter` funkcija filtravimo objektams, naudokite atitinkamą funkciją (pvz., `#before` funkciją prieš filtro funkciją).

* Pašalintas 'cow' => 'kine' nereguliarus kreipinys iš numatytų kreipinių. ([Commit](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9))

### Pasenusios funkcijos

* Pasenusi `Numeric#{ago,until,since,from_now}` funkcija, vartotojas turi aiškiai konvertuoti reikšmę į AS::Duration, pvz., `5.ago` => `5.seconds.ago` ([Pull Request](https://github.com/rails/rails/pull/12389))

* Pasenusi `active_support/core_ext/object/to_json` reikalavimo kelio dalis. Vietoje to reikia naudoti `active_support/core_ext/object/json`. ([Pull Request](https://github.com/rails/rails/pull/12203))

* Pasenusi `ActiveSupport::JSON::Encoding::CircularReferenceError` funkcija. Ši funkcija buvo išskirta į [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) priklausomybę. ([Pull Request](https://github.com/rails/rails/pull/12785) / [Daugiau informacijos](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Pasenusi `ActiveSupport.encode_big_decimal_as_string` parinktis. Ši funkcija buvo išskirta į [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) priklausomybę. ([Pull Request](https://github.com/rails/rails/pull/13060) / [Daugiau informacijos](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Pasenusi `BigDecimal` objekto serializacija. ([Pull Request](https://github.com/rails/rails/pull/13911))

### Svarbūs pakeitimai

* `ActiveSupport` JSON koduotojas buvo perdaromas naudojant JSON priklausomybę, o ne vykdant paprastą kodavimą naudojant tik Ruby kalbą. ([Pull Request](https://github.com/rails/rails/pull/12183) / [Daugiau informacijos](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Pakeista suderinamumas su JSON priklausomybe. ([Pull Request](https://github.com/rails/rails/pull/12862) / [Daugiau informacijos](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Pridėtos `ActiveSupport::Testing::TimeHelpers#travel` ir `#travel_to` funkcijos. Šios funkcijos pakeičia dabartinį laiką į nurodytą laiką ar trukmę, keičiant `Time.now` ir `Date.today` funkcijas.
* Pridėtas `ActiveSupport::Testing::TimeHelpers#travel_back` metodas. Šis metodas grąžina dabartinį laiką į pradinę būseną, pašalindamas `travel` ir `travel_to` metodų pridėtas stub'us. ([Pull Request](https://github.com/rails/rails/pull/13884))

* Pridėtas `Numeric#in_milliseconds` metodas, pavyzdžiui, `1.hour.in_milliseconds`, kad galėtume jį naudoti JavaScript funkcijose, pvz., `getTime()`. ([Commit](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643))

* Pridėti `Date#middle_of_day`, `DateTime#middle_of_day` ir `Time#middle_of_day` metodai. Taip pat pridėti `midday`, `noon`, `at_midday`, `at_noon` ir `at_middle_of_day` kaip sinonimai. ([Pull Request](https://github.com/rails/rails/pull/10879))

* Pridėti `Date#all_week/month/quarter/year` metodai, skirti generuoti datos intervalus. ([Pull Request](https://github.com/rails/rails/pull/9685))

* Pridėti `Time.zone.yesterday` ir `Time.zone.tomorrow` metodai. ([Pull Request](https://github.com/rails/rails/pull/12822))

* Pridėtas `String#remove(pattern)` metodas, kaip trumpinys dažnai naudojamam `String#gsub(pattern,'')` modeliui. ([Commit](https://github.com/rails/rails/commit/5da23a3f921f0a4a3139495d2779ab0d3bd4cb5f))

* Pridėti `Hash#compact` ir `Hash#compact!` metodai, skirti pašalinti elementus su `nil` reikšme iš hash'o. ([Pull Request](https://github.com/rails/rails/pull/13632))

* `blank?` ir `present?` grąžina vienetinius objektus. ([Commit](https://github.com/rails/rails/commit/126dc47665c65cd129967cbd8a5926dddd0aa514))

* Numatytasis `I18n.enforce_available_locales` konfigūracijos parametras yra `true`, tai reiškia, kad `I18n` užtikrins, jog visi jam perduoti lokalės būtų deklaruotos `available_locales` sąraše. ([Pull Request](https://github.com/rails/rails/pull/13341))

* Įvestas `Module#concerning`: natūralus, paprastas būdas atskirti atsakomybes klasėje. ([Commit](https://github.com/rails/rails/commit/1eee0ca6de975b42524105a59e0521d18b38ab81))

* Pridėtas `Object#presence_in` metodas, supaprastinantis leistinų reikšmių pridėjimą į sąrašą. ([Commit](https://github.com/rails/rails/commit/4edca106daacc5a159289eae255207d160f22396))


Autoriai
-------

Peržiūrėkite [visą sąrašą žmonių, prisidėjusių prie Rails](https://contributors.rubyonrails.org/), kurie daug valandų skyrė kurti Rails, stabilų ir patikimą karkasą. Šlovė jiems visiems.
