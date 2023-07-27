**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 67ad41dc27cc9079db9a7e31dffa5aac
Kelių duomenų bazių naudojimas su Active Record
=====================================

Šiame vadove aprašoma, kaip naudoti kelias duomenų bazes savo „Rails“ aplikacijoje.

Po šios vadovėlio perskaitymo žinosite:

* Kaip nustatyti savo aplikaciją kelias duomenų bazes.
* Kaip veikia automatinis prisijungimo keitimas.
* Kaip naudoti horizontalųjį skaidymą kelias duomenų bazes.
* Kokie funkcionalumai yra palaikomi ir kas dar yra darbo eigą.

--------------------------------------------------------------------------------

Kai aplikacija tampa populiaresnė ir daugiau naudojama, jums reikės padidinti aplikacijos mastą,
kad galėtumėte palaikyti naujus vartotojus ir jų duomenis. Vienas būdas, kaip jūsų aplikacija gali
reikalauti didinti mastą, yra duomenų bazės lygmeniu. „Rails“ dabar palaiko kelias duomenų bazes,
todėl jums nereikia saugoti visų duomenų vienoje vietoje.

Šiuo metu palaikomi šie funkcionalumai:

* Kelios rašytojo duomenų bazės ir kiekvienai replika
* Automatinis prisijungimo keitimas modeliui, su kuriuo dirbate
* Automatinis perjungimas tarp rašytojo ir replikos pagal HTTP veiksmą ir naujausius įrašus
* „Rails“ užduotys, skirtos sukurti, ištrinti, migruoti ir bendrauti su kelias duomenų bazes

Šiuo metu nepalaikomi šie funkcionalumai:

* Replikų apkrovos balansavimas

## Aplikacijos nustatymas

Nors „Rails“ stengiasi atlikti didžiąją darbo dalį už jus, vis tiek turėsite atlikti keletą žingsnių,
kad paruoštumėte savo aplikaciją kelias duomenų bazes.

Tarkime, turime aplikaciją su viena rašytojo duomenų baze ir turime pridėti naują duomenų bazę
kai kurioms naujoms lentelėms, kurias pridedame. Naujos duomenų bazės pavadinimas bus
"animals".

`database.yml` atrodo taip:

```yaml
production:
  database: my_primary_database
  adapter: mysql2
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
```

Pridėkime repliką prie pirmos konfigūracijos ir antrą duomenų bazę, vadinamą animals, ir repliką
tam taip pat. Norėdami tai padaryti, turime pakeisti mūsų `database.yml` iš 2 lygių
į 3 lygių konfigūraciją.

Jei pateikiama pirminė konfigūracija, ji bus naudojama kaip „numatytoji“ konfigūracija. Jei
nėra konfigūracijos, pavadinimu „primary“, „Rails“ naudos pirmąją konfigūraciją kaip numatytąją
kiekvienam aplinkai. Numatytosios konfigūracijos naudos numatytuosius „Rails“ failų pavadinimus. Pavyzdžiui,
pirminės konfigūracijos naudos `schema.rb` schemos failui, o visi kiti įrašai
naudos `[CONFIGURATION_NAMESPACE]_schema.rb` failo pavadinimą.

```yaml
production:
  primary:
    database: my_primary_database
    username: root
    password: <%= ENV['ROOT_PASSWORD'] %>
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    username: root_readonly
    password: <%= ENV['ROOT_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
  animals:
    database: my_animals_database
    username: animals_root
    password: <%= ENV['ANIMALS_ROOT_PASSWORD'] %>
    adapter: mysql2
    migrations_paths: db/animals_migrate
  animals_replica:
    database: my_animals_database
    username: animals_readonly
    password: <%= ENV['ANIMALS_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
```

Naudodami kelias duomenų bazes, yra keletas svarbių nustatymų.

Pirma, `primary` ir `primary_replica` duomenų bazės pavadinimas turėtų būti tas pats, nes jose yra
tokie patys duomenys. Taip pat taip yra su `animals` ir `animals_replica`.

Antra, rašytojų ir replikų vartotojų vardai turėtų skirtis, o
replikos vartotojo duomenų bazės leidimai turėtų būti nustatyti tik skaitymui, o ne rašymui.

Naudodami replikos duomenų bazę, replikai `database.yml` turite pridėti `replica: true` įrašą. Tai
todėl, kad „Rails“ kitaip nežino, kuris yra replika
ir kuris yra rašytojas. „Rails“ nevykdys tam tikrų užduočių, pvz., migracijų, replikose.

Galų gale, naujoms rašytojo duomenų bazėms turite nustatyti `migrations_paths` į katalogą,
kuriame saugosite migracijas tam duomenų bazei. Daugiau apie `migrations_paths`
žiūrėkite šiame vadove vėliau.

Dabar, kai turime naują duomenų bazę, nustatysime prisijungimo modelį. Norėdami naudoti
naują duomenų bazę, turime sukurti naują abstrakčią klasę ir prisijungti prie animals duomenų bazių.

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals, reading: :animals_replica }
end
```

Tada turime atnaujinti `ApplicationRecord`, kad jis žinotų apie mūsų naują repliką.

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }
end
```

Jei naudojate skirtingai pavadintą klasę savo aplikacijos įrašui, turite
nustatyti `primary_abstract_class`, kad „Rails“ žinotų, su kurią klasę `ActiveRecord::Base`
turėtų bendrinti prisijungimą.

```ruby
class PrimaryApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

Klasės, kurios prisijungia prie pagrindinės/pagrindinės_replica, gali paveldėti iš jūsų pagrindinės abstrakčios
klasės kaip įprastos „Rails“ aplikacijos:
```ruby
class Person < ApplicationRecord
end
```

Pagal numatytuosius nustatymus "Rails" tikisi, kad pagrindiniam ir replikos duomenų bazės vaidmenims bus naudojami `writing` ir `reading` vardai atitinkamai. Jei turite seną sistemą, jau gali būti nustatyti vaidmenys, kurių nenorite keisti. Tokiu atveju galite nustatyti naują vaidmens pavadinimą savo programos konfigūracijoje.

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

Svarbu prisijungti prie duomenų bazės viename modelyje ir tada paveldėti iš to modelio lentelėms, o ne prisijungti prie tos pačios duomenų bazės kelių atskirų modelių. Duomenų bazės klientai turi ribą, kiek gali būti atidarytų ryšių, ir jei tai padarysite, tai padaugins turimus ryšius, nes "Rails" naudoja modelio klasės pavadinimą kaip prisijungimo specifikacijos pavadinimą.

Turint `database.yml` ir naują modelį, laikas sukurti duomenų bazes. "Rails" 6.0 pristato visus reikalingus užduotis, kad galėtumėte naudoti kelias duomenų bazes "Rails".

Galite paleisti `bin/rails -T`, kad pamatytumėte visas galimas komandas. Turėtumėte pamatyti šias komandas:

```bash
$ bin/rails -T
bin/rails db:create                          # Sukurti duomenų bazę iš DATABASE_URL arba config/database.yml esančiai ...
bin/rails db:create:animals                  # Sukurti animals duomenų bazę esamam aplinkos
bin/rails db:create:primary                  # Sukurti pagrindinę duomenų bazę esamam aplinkos
bin/rails db:drop                            # Ištrinti duomenų bazę iš DATABASE_URL arba config/database.yml esančiai ...
bin/rails db:drop:animals                    # Ištrinti animals duomenų bazę esamam aplinkos
bin/rails db:drop:primary                    # Ištrinti pagrindinę duomenų bazę esamam aplinkos
bin/rails db:migrate                         # Migruoti duomenų bazę (parametrai: VERSION=x, VERBOSE=false, SCOPE=blog)
bin/rails db:migrate:animals                 # Migruoti animals duomenų bazę esamam aplinkos
bin/rails db:migrate:primary                 # Migruoti pagrindinę duomenų bazę esamam aplinkos
bin/rails db:migrate:status                  # Rodyti migracijų būseną
bin/rails db:migrate:status:animals          # Rodyti migracijų būseną animals duomenų bazėje
bin/rails db:migrate:status:primary          # Rodyti migracijų būseną pagrindinėje duomenų bazėje
bin/rails db:reset                           # Ištrinti ir sukurti visas duomenų bazes pagal jų schemą esamai aplinkai ir įkelti pradinius duomenis
bin/rails db:reset:animals                   # Ištrinti ir sukurti animals duomenų bazę pagal jos schemą esamai aplinkai ir įkelti pradinius duomenis
bin/rails db:reset:primary                   # Ištrinti ir sukurti pagrindinę duomenų bazę pagal jos schemą esamai aplinkai ir įkelti pradinius duomenis
bin/rails db:rollback                        # Sugrąžinti schemą į ankstesnę versiją (nurodykite žingsnius su STEP=n)
bin/rails db:rollback:animals                # Sugrąžinti animals duomenų bazę esamai aplinkai (nurodykite žingsnius su STEP=n)
bin/rails db:rollback:primary                # Sugrąžinti pagrindinę duomenų bazę esamai aplinkai (nurodykite žingsnius su STEP=n)
bin/rails db:schema:dump                     # Sukurti duomenų bazės schemos failą (arba db/schema.rb arba db/structure.sql  ...
bin/rails db:schema:dump:animals             # Sukurti duomenų bazės schemos failą (arba db/schema.rb arba db/structure.sql  ...
bin/rails db:schema:dump:primary             # Sukurti db/schema.rb failą, kuris yra suderinamas su bet kuria palaikoma DB  ...
bin/rails db:schema:load                     # Įkelti duomenų bazės schemos failą (arba db/schema.rb arba db/structure.sql  ...
bin/rails db:schema:load:animals             # Įkelti duomenų bazės schemos failą (arba db/schema.rb arba db/structure.sql  ...
bin/rails db:schema:load:primary             # Įkelti duomenų bazės schemos failą (arba db/schema.rb arba db/structure.sql  ...
bin/rails db:setup                           # Sukurti visas duomenų bazes, įkelti visas schemas ir inicijuoti pradinius duomenis (naudokite db:reset, jei norite pirmiausia ištrinti visas duomenų bazes)
bin/rails db:setup:animals                   # Sukurti animals duomenų bazę, įkelti schemą ir inicijuoti pradinius duomenis (naudokite db:reset:animals, jei norite pirmiausia ištrinti duomenų bazę)
bin/rails db:setup:primary                   # Sukurti pagrindinę duomenų bazę, įkelti schemą ir inicijuoti pradinius duomenis (naudokite db:reset:primary, jei norite pirmiausia ištrinti duomenų bazę)
```

Paleidus komandą, pvz., `bin/rails db:create`, bus sukuriamos tiek pagrindinės, tiek animals duomenų bazės. Atkreipkite dėmesį, kad nėra komandos, skirtos duomenų bazės vartotojams sukurti, ir tai turėsite padaryti rankiniu būdu, kad galėtumėte palaikyti tik skaitymui skirtus vartotojus savo replikoms. Jei norite sukurti tik animals duomenų bazę, galite paleisti `bin/rails db:create:animals`.

## Prisijungimas prie duomenų bazės be schemos ir migracijų valdymo

Jei norite prisijungti prie išorinės duomenų bazės be jokio duomenų bazės valdymo, pvz., schemos valdymo, migracijų, pradinių duomenų ir t.t., galite nustatyti konfigūracijos parinktį `database_tasks: false` kiekvienai duomenų bazei. Pagal numatytuosius nustatymus ji yra nustatyta kaip `true`.

```yaml
production:
  primary:
    database: my_database
    adapter: mysql2
  animals:
    database: my_animals_database
    adapter: mysql2
    database_tasks: false
```

## Generatoriai ir migracijos

Migracijos keliamos į atskirus aplankus, kurie prasideda duomenų bazės konfigūracijos raktažodžiu.
Jums taip pat reikia nustatyti `migrations_paths` duomenų bazės konfigūracijose, kad praneštumėte „Rails“, kur rasti migracijas.

Pavyzdžiui, „animals“ duomenų bazė ieškos migracijų „db/animals_migrate“ kataloge, o „primary“ ieškos „db/migrate“. Dabar „Rails“ generatoriai priima `--database` parinktį, kad sugeneruotų failą teisingame kataloge. Komandą galima paleisti taip:

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

Jei naudojate „Rails“ generatorius, šablonų ir modelių generatoriai jums sukurs abstrakčią klasę. Tiesiog perduokite duomenų bazės raktą komandų eilutėje.

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

Bus sukurtas klasė su duomenų bazės pavadinimu ir `Record`. Šiuo pavyzdžiu duomenų bazė yra „Animals“, todėl gauname `AnimalsRecord`:

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

Sugeneruotas modelis automatiškai paveldės iš `AnimalsRecord`.

```ruby
class Dog < AnimalsRecord
end
```

PASTABA: Kadangi „Rails“ nežino, kuri duomenų bazė yra rašytojo replika, po to, kai baigsite, turėsite pridėti tai prie abstrakčios klasės.

„Rails“ sugeneruos naują klasę tik vieną kartą. Ji nebus perrašyta naujomis šablonais arba ištrinta, jei šablonas bus ištrintas.

Jei jau turite abstrakčią klasę, kurios pavadinimas skiriasi nuo `AnimalsRecord`, galite perduoti `--parent` parinktį, kad nurodytumėte, kad norite naudoti kitą abstrakčią klasę:

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

Tai praleis `AnimalsRecord` generavimą, nes nurodėte „Rails“, kad norite naudoti kitą pagrindinę klasę.

## Automatinio vaidmens perjungimo aktyvavimas

Galų gale, norėdami naudoti tik skaitymo repliką savo programoje, turėsite aktyvuoti tarpinįjį programinės įrangos sluoksnį automatiniam perjungimui.

Automatinis perjungimas leidžia programai perjungti nuo rašytojo iki replikos arba nuo replikos iki rašytojo pagal HTTP veiksmą ir tai, ar neseniai buvo atliktas rašymas prašančiojo naudotojo.

Jei programa gauna POST, PUT, DELETE arba PATCH užklausą, programa automatiškai rašys į rašytojo duomenų bazę. Nurodytu laiko tarpotarpyje po rašymo programa skaitys iš pagrindinės duomenų bazės. Jei užklausa yra GET arba HEAD, programa skaitys iš replikos, nebent buvo neseniai rašymo.

Norėdami aktyvuoti automatinio ryšio perjungimo tarpinįjį programinės įrangos sluoksnį, galite paleisti automatinio keitimo generatorių:

```bash
$ bin/rails g active_record:multi_db
```

Tada atkomentuokite šias eilutes:

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

„Rails“ garantuoja „skaityk savo rašymą“ ir nusiųs jūsų GET arba HEAD užklausą rašytojui, jei ji yra per `delay` langą. Pagal numatytuosius nustatymus, vėlavimas nustatytas į 2 sekundes. Turėtumėte tai pakeisti pagal savo duomenų bazės infrastruktūrą. „Rails“ negarantuoja „skaityk neseniai rašymą“ kitiems naudotojams per vėlavimo langą ir nusiųs GET ir HEAD užklausas replikoms, nebent jos neseniai rašė.

„Rails“ automatinis ryšio perjungimas yra santykinai primityvus ir sąmoningai nedaro daug. Tikslas yra sistema, kuri demonstruoja, kaip atlikti automatinį ryšio perjungimą, kuris būtų pakankamai lankstus, kad jį galėtų pritaikyti programų kūrėjai.

„Rails“ sąranka leidžia lengvai keisti, kaip vyksta perjungimas ir pagal kokių parametrų jis vyksta. Tarkime, norite naudoti slapuką vietoj sesijos, kad nuspręstumėte, kada keisti ryšį. Galite parašyti savo klasę:

```ruby
class MyCookieResolver << ActiveRecord::Middleware::DatabaseSelector::Resolver
  def self.call(request)
    new(request.cookies)
  end

  def initialize(cookies)
    @cookies = cookies
  end

  attr_reader :cookies

  def last_write_timestamp
    self.class.convert_timestamp_to_time(cookies[:last_write])
  end

  def update_last_write_timestamp
    cookies[:last_write] = self.class.convert_time_to_timestamp(Time.now)
  end

  def save(response)
  end
end
```

Tada perduokite jį tarpinės programinės įrangos sluoksniui:

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## Naudojimas su rankiniu ryšio perjungimu

Yra atvejų, kai norite, kad jūsų programa prisijungtų prie rašytojo ar replikos, o automatinis ryšio perjungimas nėra tinkamas. Pavyzdžiui, galite žinoti, kad tam tikrai užklausai visada norite nusiųsti užklausą replikai, net kai esate POST užklausos kelyje.

Tam „Rails“ teikia `connected_to` metodą, kuris perjungs prie reikiamo ryšio.
```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # visi kodai šiame bloke bus prijungti prie skaitymo vaidmens
end
```

"Vaidmuo" `connected_to` iškvietime ieško ryšių, kurie yra prijungti prie to
ryšio tvarkyklės (arba vaidmens). `reading` ryšio tvarkyklė turės visus ryšius,
kurie buvo prijungti naudojant `connects_to` su vaidmens pavadinimu `reading`.

Atkreipkite dėmesį, kad `connected_to` su vaidmeniu ieškos esamo ryšio ir jį pakeis,
naudodamas ryšio specifikacijos pavadinimą. Tai reiškia, kad jei perduodate nežinomą vaidmenį,
pvz., `connected_to(role: :nonexistent)`, gausite klaidą, kuri sako
`ActiveRecord::ConnectionNotEstablished (No connection pool for 'ActiveRecord::Base' found for the 'nonexistent' role.)`

Jei norite, kad „Rails“ užtikrintų, jog vykdomos užklausos būtų tik skaitymui, perduokite `prevent_writes: true`.
Tai tiesiog neleidžia siųsti į duomenų bazę užklausų, kurios atrodo kaip rašymas.
Taip pat turėtumėte sukonfigūruoti savo replikos duomenų bazę, kad ji veiktų tik skaitymui.

```ruby
ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
  # „Rails“ patikrins kiekvieną užklausą, kad įsitikintų, jog tai yra skaitymo užklausa
end
```

## Horizontalus fragmentavimas

Horizontalus fragmentavimas yra būdas padalinti duomenų bazę, kad sumažintumėte eilučių skaičių kiekviename
duomenų bazės serveryje, tačiau išlaikyti tą pačią schemą visuose „fragmentuose“. Tai dažnai vadinama „daugiabučiu“ fragmentavimu.

„Rails“ API, skirtas horizontaliam fragmentavimui palaikyti, yra panašus į daugelio duomenų bazės / vertikalaus
fragmentavimo API, kuris egzistuoja nuo „Rails“ 6.0.

Fragmentai yra deklaruojami trijų lygių konfigūracijoje taip:

```yaml
production:
  primary:
    database: my_primary_database
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    adapter: mysql2
    replica: true
  primary_shard_one:
    database: my_primary_shard_one
    adapter: mysql2
  primary_shard_one_replica:
    database: my_primary_shard_one
    adapter: mysql2
    replica: true
```

Tada modeliai yra prijungiami prie `connects_to` API naudojant `shards` raktą:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

Nereikia naudoti `default` kaip pirmo fragmento pavadinimo. „Rails“ priims, kad pirmas
fragmento pavadinimas `connects_to` haešoje yra „numatytasis“ ryšys. Šis ryšys naudojamas
viduje įkelti tipų duomenis ir kitą informaciją, kurios schemos yra tokios pačios visuose fragmentuose.

Tada modeliai gali rankiniu būdu keisti ryšius naudodami `connected_to` API. Jei
naudojamas fragmentavimas, turi būti perduodami tiek „vaidmuo“, tiek „fragmentas“:

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # Sukuria įrašą fragmente pavadinimu ":default"
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # Negali rasti įrašo, nes jis neegzistuoja, nes buvo sukurtas
                   # fragmente pavadinimu ":default".
end
```

Horizontalaus fragmentavimo API taip pat palaiko skaitymo replikas. Galite keisti
vaidmenį ir fragmentą naudodami `connected_to` API.

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Ieškoti įrašo iš pirmo fragmento skaitymo replikos
end
```

## Automatinio fragmento keitimo aktyvinimas

Programos gali automatiškai keisti fragmentus užklausos pagalba, naudodamos pateiktą
tarpinį programinės įrangos.

„ShardSelector“ tarpinė programa suteikia pagrindą automatiškam
fragmentų keitimui. „Rails“ suteikia pagrindinį pagrindą nustatyti, kurį
fragmentą keisti ir leidžia programoms rašyti pasirinktines strategijas
keitimui, jei reikia.

„ShardSelector“ priima rinkinį parinkčių (kol kas palaikoma tik „lock“)
kurias tarpinė programa gali naudoti keisti elgesį. „lock“
pagal numatytuosius nustatymus yra „true“ ir uždraus užklausai keisti fragmentus,
kai jis yra bloke. Jei „lock“ yra „false“, tada fragmentų keitimas bus leidžiamas.
Nuomininko pagrindu fragmentavimui „lock“ visada turėtų būti „true“, kad būtų išvengta programos
kodo klaidingai keičiant nuomininkus.

Taip pat galima naudoti tą patį generatorių kaip ir duomenų bazės parinkikliui sugeneruoti failą
automatiniam fragmentų keitimui:

```bash
$ bin/rails g active_record:multi_db
```

Tada faile reikia atkomentuoti šiuos dalykus:

```ruby
Rails.application.configure do
  config.active_record.shard_selector = { lock: true }
  config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end
```

Programos turi pateikti kodą sprendikliui, nes jis priklauso nuo programos
specifinių modelių. Pavyzdinis sprendiklio kodas atrodytų taip:

```ruby
config.active_record.shard_resolver = ->(request) {
  subdomain = request.subdomain
  tenant = Tenant.find_by_subdomain!(subdomain)
  tenant.shard
}
```

## Detalus duomenų bazės ryšio keitimas

„Rails“ 6.1 versijoje galima keisti ryšius vienos duomenų bazės vietoje
visų duomenų bazių globaliai.

Naudojant detalų duomenų bazės ryšio keitimą, bet kuri abstrakti ryšio klasė
galės keisti ryšius, nepaveikiant kitų ryšių. Tai
naudinga, jei norite, kad jūsų `AnimalsRecord` užklausos skaitytų iš replikos,
užtikrinant, kad jūsų `ApplicationRecord` užklausos eitų į pagrindinį ryšį.
```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # Skaito iš animals_replica
  Person.first  # Skaito iš pagrindinės
end
```

Taip pat galima keisti ryšius granuliariai šerdims.

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # Skaito iš shard_one_replica. Jei nėra ryšio su shard_one_replica,
  # bus iškelta ConnectionNotEstablished klaida
  Person.first # Skaito iš pagrindinio rašytojo
end
```

Norint pakeisti tik pagrindinę duomenų bazės klasterį, naudokite `ApplicationRecord`:

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Skaito iš primary_shard_one_replica
  Dog.first # Skaito iš animals_primary
end
```

`ActiveRecord::Base.connected_to` išlaiko galimybę globaliai keisti ryšius.

### Susijungimų sujungimas tarp duomenų bazių

Nuo Rails 7.0+, Active Record turi parinktį, kuri leidžia tvarkyti susijungimus, kurie atlieka
sujungimą per kelias duomenų bazes. Jei turite "has many through" arba "has one through" susijungimą,
kuriame norite išjungti sujungimą ir atlikti 2 ar daugiau užklausų, perduokite `disable_joins: true` parinktį.

Pavyzdžiui:

```ruby
class Dog < AnimalsRecord
  has_many :treats, through: :humans, disable_joins: true
  has_many :humans

  has_one :home
  has_one :yard, through: :home, disable_joins: true
end

class Home
  belongs_to :dog
  has_one :yard
end

class Yard
  belongs_to :home
end
```

Anksčiau, jei būtų iškviečiama `@dog.treats` be `disable_joins` arba `@dog.yard` be `disable_joins`,
būtų iškelta klaida, nes duomenų bazės negali tvarkyti sujungimų tarp klasterių. Su
`disable_joins` parinktimi, Rails sugeneruos kelias atskiras užklausas,
kad išvengtų bandymo atlikti sujungimą tarp klasterių. Aukščiau pateikiamam susijungimui, `@dog.treats` sugeneruos
šią SQL užklausą:

```sql
SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
```

O `@dog.yard` sugeneruos šią SQL užklausą:

```sql
SELECT "home"."id" FROM "homes" WHERE "homes"."dog_id" = ? [["dog_id", 1]]
SELECT "yards".* FROM "yards" WHERE "yards"."home_id" = ? [["home_id", 1]]
```

Šiai parinkčiai yra keletas svarbių dalykų, kuriuos reikia žinoti:

1. Gali būti veikimo pasekmės, nes dabar bus atlikta dvi ar daugiau užklausų (priklauso
   nuo susijungimo), o ne sujungimas. Jei `humans` lentelės užklausa grąžintų daug ID,
   `treats` užklausa gali perduoti per daug ID.
2. Kadangi nebevykdomi sujungimai, užklausa su rikiavimu ar limitu bus rūšiuojama atmintyje,
   nes iš vienos lentelės tvarka negali būti taikoma kitai lentelės.
3. Ši nustatymą reikia pridėti prie visų susijungimų, kuriuose norite išjungti sujungimą.
   Rails negali atspėti šito, nes susijungimo įkėlimas yra tingus, norint įkelti `treats` `@dog.treats`
   Rails jau turi žinoti, kokią SQL užklausą reikia sugeneruoti.

### Schemos talpinimas

Jei norite įkelti schemos talpyklą kiekvienai duomenų bazei, turite nustatyti `schema_cache_path` kiekvienoje duomenų bazės konfigūracijoje ir nustatyti `config.active_record.lazily_load_schema_cache = true` savo programos konfigūracijoje. Atkreipkite dėmesį, kad tai bus tingiai įkelti talpyklą, kai bus nustatytos duomenų bazės ryšiai.

## Apribojimai

### Replicų apkrovos balansavimas

Rails taip pat nepalaiko automatinio replikų apkrovos balansavimo. Tai labai
priklauso nuo jūsų infrastruktūros. Galbūt ateityje įgyvendinsime pagrindinį, primityvų replikų apkrovos balansavimą,
bet didelio masto programai tai turėtų būti kažkas, ką jūsų programa
tvarko už Rails ribų.
