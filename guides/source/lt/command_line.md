**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 7dbd0564d604e07d111b2a827bef559f
Rails Komandinė eilutė
======================

Po šio vadovo perskaitymo, žinosite:

* Kaip sukurti „Rails“ aplikaciją.
* Kaip generuoti modelius, kontrolerius, duomenų bazės migracijas ir vienetinius testus.
* Kaip paleisti vystymo serverį.
* Kaip eksperimentuoti su objektais per interaktyviąją skalę.

--------------------------------------------------------------------------------

PASTABA: Šis vadovas priklauso nuo to, kad turite pagrindinius „Rails“ žinias, perskaitę [Pradžios vadovą su „Rails“](getting_started.html).

„Rails“ aplikacijos kūrimas
--------------------

Pirmiausia, naudodami „rails new“ komandą, sukursime paprastą „Rails“ aplikaciją.

Šią aplikaciją naudosime žaidimui ir visų komandose aprašytų komandų atradimui.

INFORMACIJA: Jei dar neturite, įdiekite „rails“ juostelę įvedę „gem install rails“.

### `rails new`

Pirmasis argumentas, kurį perduosime „rails new“ komandai, yra aplikacijos pavadinimas.

```bash
$ rails new my_app
     create
     create  README.md
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

„Rails“ sukonfigūruos daugybę dalykų, atrodo, kad tokiai mažai komandai! Turime visą „Rails“ katalogo struktūrą su visu kodu, kurį reikia paleisti mūsų paprastai aplikacijai iškart.

Jei norite praleisti kai kurias failų generavimą arba praleisti kai kurias bibliotekas, galite pridėti bet kurį iš šių argumentų prie savo „rails new“ komandos:

| Argumentas                | Aprašymas                                                 |
| ----------------------- | ----------------------------------------------------------- |
| `--skip-git`            | Praleisti git init, .gitignore ir .gitattributes               |
| `--skip-docker`         | Praleisti Dockerfile, .dockerignore ir bin/docker-entrypoint    |
| `--skip-keeps`          | Praleisti šaltinio kontrolės .keep failus                             |
| `--skip-action-mailer`  | Praleisti Action Mailer failus                                    |
| `--skip-action-mailbox` | Praleisti Action Mailbox gem                                     |
| `--skip-action-text`    | Praleisti Action Text gem                                        |
| `--skip-active-record`  | Praleisti Active Record failus                                    |
| `--skip-active-job`     | Praleisti Active Job                                             |
| `--skip-active-storage` | Praleisti Active Storage failus                                   |
| `--skip-action-cable`   | Praleisti Action Cable failus                                     |
| `--skip-asset-pipeline` | Praleisti Asset Pipeline                                         |
| `--skip-javascript`     | Praleisti JavaScript failus                                       |
| `--skip-hotwire`        | Praleisti Hotwire integraciją                                    |
| `--skip-jbuilder`       | Praleisti jbuilder gem                                           |
| `--skip-test`           | Praleisti testinius failus                                             |
| `--skip-system-test`    | Praleisti sistemos testinius failus                                      |
| `--skip-bootsnap`       | Praleisti bootsnap gem                                           |

Tai tik keletas „rails new“ priimamų parinkčių. Visą parinkčių sąrašą galite pamatyti įvedę „rails new --help“.

### Iš anksto sukonfigūruokite kitą duomenų bazę

Kuriant naują „Rails“ aplikaciją, galite nurodyti, kokios duomenų bazės jūsų aplikacija naudos. Tai sutaupys jums kelias minutes ir žinoma, daug klavišų.

Pažiūrėkime, ką mums padarys „--database=postgresql“ parinktis:

```bash
$ rails new petstore --database=postgresql
      create
      create  app/controllers
      create  app/helpers
...
```

Pažiūrėkime, ką įdėjo į mūsų `config/database.yml`:

```yaml
# PostgreSQL. Palaikomos 9.3 ir naujesnės versijos.
#
# Įdiekite pg tvarkyklę:
#   gem install pg
# „macOS“ su „Homebrew“:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# „Windows“:
#   gem install pg
#       Pasirinkite win32 versiją.
#       Įdiekite „PostgreSQL“ ir įtraukite jo /bin katalogą į savo kelią.
#
# Konfigūruojama naudojant Gemfile
# gem "pg"
#
default: &default
  adapter: postgresql
  encoding: unicode

  # Dėl jungčių kaupimo išsamiosios informacijos žr. „Rails“ konfigūracijos vadovą
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: petstore_development
...
```

Tai sugeneravo duomenų bazės konfigūraciją, atitinkančią mūsų pasirinktą „PostgreSQL“.

Pagrindinės komandinės eilutės funkcijos
-------------------

Yra keletas komandų, kurios yra absoliučiai būtinos jūsų kasdieniam „Rails“ naudojimui. Pagal tai, kiek tikriausiai jas naudosite, jos yra:

* `bin/rails console`
* `bin/rails server`
* `bin/rails test`
* `bin/rails generate`
* `bin/rails db:migrate`
* `bin/rails db:create`
* `bin/rails routes`
* `bin/rails dbconsole`
* `rails new app_name`

Galite gauti sąrašą jums prieinamų „rails“ komandų, kuris dažnai priklauso nuo jūsų esamo katalogo, įvedę `rails --help`. Kiekviena komanda turi aprašymą ir turėtų padėti jums rasti tai, ko jums reikia.

```bash
$ rails --help
Naudota:
  bin/rails KOMANDA [parinktys]

Turite nurodyti komandą. Dažniausiai naudojamos komandos yra:

  generate     Generuoti naują kodą (trumpinys: "g")
  console      Paleisti „Rails“ konsolę (trumpinys: "c")
  server       Paleisti „Rails“ serverį (trumpinys: "s")
  ...

Visos komandos gali būti paleistos su -h (arba --help) daugiau informacijos.

Be šių komandų, yra:
about                               Išvardinti visų „Rails“ versijas ...
assets:clean[keep]                  Pašalinti senus sukompiliuotus išteklius
assets:clobber                      Pašalinti sukompiliuotus išteklius
assets:environment                  Įkelti išteklių kompiliavimo aplinką
assets:precompile                   Sukompiliuoti visus išteklius ...
...
db:fixtures:load                    Įkelti fiktyvius duomenis į ...
db:migrate                          Migruoti duomenų bazę ...
db:migrate:status                   Rodyti migracijų būseną
db:rollback                         Sugrąžinti schemą ...
db:schema:cache:clear               Išvalyti db/schema_cache.yml failą
db:schema:cache:dump                Sukurti db/schema_cache.yml failą
db:schema:dump                      Sukurti duomenų bazės schemos failą (arba db/schema.rb arba db/structure.sql ...
db:schema:load                      Įkelti duomenų bazės schemos failą (arba db/schema.rb arba db/structure.sql ...
db:seed                             Įkelti sėklos duomenis ...
db:version                          Gauti dabartinę schemos ...
...
restart                             Paleisti programą palietus ...
tmp:create                          Sukurti tmp katalogus ...
```
### `bin/rails server`

Komanda `bin/rails server` paleidžia interneto serverį, vadinamą Puma, kuris yra įdiegtas kartu su Rails. Jį naudosite kiekvieną kartą, kai norėsite pasiekti savo programą per interneto naršyklę.

Be jokio papildomo darbo, `bin/rails server` paleis mūsų naują švytinčią Rails programą:

```bash
$ cd my_app
$ bin/rails server
=> Booting Puma
=> Rails 7.0.0 aplikacija pradedama veikti kūrimo režime
=> Daugiau paleidimo parinkčių rasite, paleidus `bin/rails server --help`
Puma pradedama vienoje veiksenoje...
* Versija 3.12.1 (ruby 2.5.7-p206), kodinis pavadinimas: Llamas in Pajamas
* Minimalus gijų skaičius: 5, maksimalus gijų skaičius: 5
* Aplinka: kūrimo režimas
* Klausiama tcp://localhost:3000
Norėdami sustabdyti, naudokite Ctrl-C
```

Vykdydami tik tris komandas, sukūrėme Rails serverį, klausantį 3000-ojo prievado. Eikite į naršyklę ir atidarykite [http://localhost:3000](http://localhost:3000), pamatysite veikiančią pagrindinę Rails programą.

INFO: Taip pat galite naudoti aliasą "s" paleisti serverį: `bin/rails s`.

Serverį galima paleisti kitame prievade naudojant `-p` parinktį. Numatytąją kūrimo aplinką galima pakeisti naudojant `-e` parinktį.

```bash
$ bin/rails server -e production -p 4000
```

Parinktis `-b` pririša Rails prie nurodyto IP, numatytasis yra localhost. Serverį galite paleisti kaip daemoną, perduodant `-d` parinktį.

### `bin/rails generate`

Komanda `bin/rails generate` naudoja šablonus, kad sukurtų daugybę dalykų. Paleidus `bin/rails generate` be jokių papildomų argumentų, bus pateikiamas galimų generatorių sąrašas:

INFO: Taip pat galite naudoti aliasą "g" paleisti generatoriaus komandą: `bin/rails g`.

```bash
$ bin/rails generate
Naudojimas:
  bin/rails generate GENERATOR [args] [options]

...
...

Pasirinkite generatorių iš sąrašo.

Rails:
  assets
  channel
  controller
  generator
  ...
  ...
```

Pastaba: Galite įdiegti daugiau generatorių per generatorių juvelyrinius paketus, dalis išplėtiklių, kuriuos tikrai įdiegsite, ir netgi galite kurti savo.

Generatorių naudojimas sutaupys jums daug laiko, rašant **boilerplate** kodą, kodą, būtiną programai veikti.

Sukurkime savo kontrolerį naudodami kontrolerio generatorių. Bet kokią komandą galime naudoti? Paklauskime generatoriaus:

INFO: Visiems Rails konsolės įrankiams yra pagalbos tekstas. Kaip ir daugeliui *nix įrankių, galite pabandyti pridėti `--help` arba `-h` į pabaigą, pavyzdžiui, `bin/rails server --help`.

```bash
$ bin/rails generate controller
Naudojimas:
  bin/rails generate controller NAME [action action] [options]

...
...

Aprašymas:
    ...

    Norėdami sukurti kontrolerį modulyje, nurodykite kontrolerio pavadinimą kaip kelią, pvz., 'parentinis_modulis/kontrolerio_pavadinimas'.

    ...

Pavyzdys:
    `bin/rails generate controller CreditCards open debit credit close`

    Kreditinės kortelės kontroleris su URL, pvz., /credit_cards/debit.
        Kontroleris: app/controllers/credit_cards_controller.rb
        Testas:       test/controllers/credit_cards_controller_test.rb
        Vaizdai:      app/views/credit_cards/debit.html.erb [...]
        Pagalbininkas:     app/helpers/credit_cards_helper.rb
```

Kontrolerio generatorius tikisi parametrų formos `generate controller KontrolerioPavadinimas veiksmas1 veiksmas2`. Sukurkime `Greetings` kontrolerį su veiksmu **hello**, kuris pasakys mums kažką malonaus.

```bash
$ bin/rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get 'greetings/hello'
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke    test_unit
```

Ką visa tai sukūrė? Užtikrino, kad mūsų programoje būtų daugybė katalogų ir sukūrė kontrolerio failą, vaizdo failą, funkcinių testų failą, pagalbininką vaizdui, JavaScript failą ir stiliaus lapą.

Peržiūrėkite kontrolerį ir šiek tiek jį modifikuokite (faile `app/controllers/greetings_controller.rb`):

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Sveiki, kaip sekasi?"
  end
end
```

Tada vaizdą, kad parodytume mūsų žinutę (faile `app/views/greetings/hello.html.erb`):

```erb
<h1>Pasveikinimas Jums!</h1>
<p><%= @message %></p>
```

Paleiskite serverį naudodami `bin/rails server`.

```bash
$ bin/rails server
=> Booting Puma...
```

URL bus [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello).

INFO: Su įprasta, paprasta Rails programa, jūsų URL dažniausiai bus pagal šabloną http://(hostas)/(kontroleris)/(veiksmas), o URL, pvz., http://(hostas)/(kontroleris) pasieks to kontrolerio **index** veiksmą.

Rails turi generatorių duomenų modeliams taip pat.

```bash
$ bin/rails generate model
Naudojimas:
  bin/rails generate model NAME [laukas[:tipas][:indeksas] laukas[:tipas][:indeksas]] [options]

...

ActiveRecord parinktys:
      [--migration], [--no-migration]        # Nurodo, kada generuoti migraciją
                                             # Numatytasis: true

...

Aprašymas:
    Generuoja naują modelį. Pervadinkite modelio pavadinimą, arba
    CamelCased arba under_scored, ir pasirinktinai nurodykite atributų porų sąrašą kaip argumentus.

...
```

Pastaba: Laukų tipų `type` parametrui galite rasti sąrašą [API dokumentacijoje](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column) `SchemaStatements` modulio `add_column` metodo. Parametras `index` generuoja atitinkamą indeksą stulpeliui.
Tačiau vietoj tiesioginio modelio generavimo (ką padarysime vėliau), sukursime šabloną. **Šablonas** (angl. scaffold) „Rails“ yra visiškas modelio, duomenų bazės migracijos šiam modeliui, valdiklio, skirta jį manipuliuoti, rodymo ir manipuliavimo duomenimis vaizdai, ir testų rinkinys kiekvienam iš šių elementų.

Sukursime paprastą išteklių pavadinimu „HighScore“, kuris sektų mūsų aukščiausius rezultatus žaidimuose, kuriuos žaidžiame.

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20190416145729_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    create      test/system/high_scores_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke      test_unit
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    create      app/views/high_scores/_high_score.json.jbuilder
```

Generatorius sukuria modelį, rodymo vaizdus, valdiklį, **išteklių** maršrutą ir duomenų bazės migraciją (kuri sukuria `high_scores` lentelę) „HighScore“. Taip pat pridedami testai šiems elementams.

Migracija reikalauja, kad atliktume **migraciją**, t. y. paleistume šiek tiek „Ruby“ kodo (iš aukščiau pateikto išvesties failo `20190416145729_create_high_scores.rb`), kad pakeistume duomenų bazės schemą. Kurią duomenų bazę? „SQLite3“ duomenų bazę, kurią „Rails“ sukurs jums, kai paleisime komandą `bin/rails db:migrate`. Apie šią komandą kalbėsime daugiau žemiau.

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFORMACIJA: Pašnekėkime apie vienetinius testus. Vienetiniai testai yra kodas, kuris testuoja ir daro teiginius apie kodą. Vienetiniame teste imame nedidelę kodo dalį, tarkime, modelio metodą, ir testuojame jo įvestis ir išvestis. Vienetiniai testai yra jūsų draugas. Kuo greičiau susitaikysite su tuo, kad jūsų gyvenimo kokybė žymiai padidės, kai vienetiniais testais testuosite savo kodą, tuo geriau. Rimtai. Apsilankykite [testavimo vadove](testing.html) ir gaukite išsamų
peržiūrą vienetinio testavimo.

Pažiūrėkime, kokį sąsają sukūrė „Rails“.

```bash
$ bin/rails server
```

Eikite į naršyklę ir atidarykite [http://localhost:3000/high_scores](http://localhost:3000/high_scores), dabar galime kurti naujus aukščiausius rezultatus (55,160 „Space Invaders“ žaidime!)

### `bin/rails console`

`console` komanda leidžia sąveikauti su savo „Rails“ programa iš komandinės eilutės. „bin/rails console“ naudoja IRB, todėl jei jį naudojote anksčiau, jausitės kaip namie. Tai naudinga, norint išbandyti greitas idėjas su kodu ir keisti duomenis serverio pusėje, nesiliečiant su svetaine.

INFORMACIJA: Taip pat galite naudoti aliasą „c“, kad iškviestumėte konsolę: `bin/rails c`.

Galite nurodyti aplinką, kurioje turėtų veikti `console` komanda.

```bash
$ bin/rails console -e staging
```

Jei norite išbandyti kodą, nepakeisdami jokių duomenų, tai galite padaryti, iškviesdami `bin/rails console --sandbox`.

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 7.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### `app` ir `helper` objektai

`bin/rails console` viduje turite prieigą prie `app` ir `helper` egzempliorių.

Su metodu `app` galite pasiekti pavadintus maršruto pagalbininkus ir atlikti užklausas.

```irb
irb> app.root_path
=> "/"

irb> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

Su metodu `helper` galima pasiekti „Rails“ ir jūsų programos pagalbinius metodus.

```irb
irb> helper.time_ago_in_words 30.days.ago
=> "apie 1 mėnesį"

irb> helper.my_custom_helper
=> "mano pagalbinis metodas"
```

### `bin/rails dbconsole`

`bin/rails dbconsole` nustato, kurią duomenų bazę naudojate ir įeina į ją komandinės eilutės sąsają (ir taip pat nustato komandinės eilutės parametrus, kuriuos reikia jai duoti!). Ji palaiko „MySQL“ (įskaitant „MariaDB“), „PostgreSQL“ ir „SQLite3“.

INFORMACIJA: Taip pat galite naudoti aliasą „db“, kad iškviestumėte dbconsole: `bin/rails db`.

Jei naudojate kelias duomenų bazes, `bin/rails dbconsole` pagal numatytuosius nustatymus prisijungs prie pagrindinės duomenų bazės. Galite nurodyti, prie kurios duomenų bazės prisijungti, naudodami `--database` arba `--db`:

```bash
$ bin/rails dbconsole --database=animals
```

### `bin/rails runner`

`runner` neinteraktyviai vykdo „Ruby“ kodą „Rails“ kontekste. Pavyzdžiui:

```bash
$ bin/rails runner "Model.long_running_method"
```

INFORMACIJA: Taip pat galite naudoti aliasą „r“, kad iškviestumėte runner: `bin/rails r`.

Galite nurodyti aplinką, kurioje turėtų veikti `runner` komanda, naudodami `-e` perjungiklį.

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```

Jūs netgi galite vykdyti „Ruby“ kodą, parašytą faile su paleidėju.

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `bin/rails destroy`

Galiausiai, pagalvokite apie „destroy“ kaip apie „generate“ priešingybę. Ji nustatys, ką „generate“ padarė ir atšauks tai.

INFORMACIJA: Taip pat galite naudoti aliasą „d“, kad iškviestumėte „destroy“ komandą: `bin/rails d`.

```bash
$ bin/rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```

```bash
$ bin/rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

### `bin/rails about`

`bin/rails about` pateikia informaciją apie „Ruby“, „RubyGems“, „Rails“, „Rails“ subkomponentus, jūsų aplikacijos aplanką, dabartinį „Rails“ aplinkos pavadinimą, jūsų aplikacijos duomenų bazės adapterį ir schemos versiją. Tai naudinga, kai jums reikia paprašyti pagalbos, patikrinti, ar saugumo atnaujinimas gali jus paveikti arba kai jums reikia kelių statistikos duomenų apie esamą „Rails“ diegimą.

```bash
$ bin/rails about
Apie jūsų aplikacijos aplinką
Rails versija             7.0.0
Ruby versija              2.7.0 (x86_64-linux)
RubyGems versija          2.7.3
Rack versija              2.0.4
JavaScript vykdymo aplinka        Node.js (V8)
Tarpinė programinė įranga:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Aplikacijos šaknis          /home/foobar/my_app
Aplinkos pavadinimas               development
Duomenų bazės adapteris          sqlite3
Duomenų bazės schemos versija   20180205173523
```

### `bin/rails assets:`

Jūs galite išankstiniu būdu sukompiliuoti `app/assets` turinį naudodami `bin/rails assets:precompile` ir pašalinti senesnius sukompiliuotus turinius naudodami `bin/rails assets:clean`. `assets:clean` komanda leidžia atlikti palaipsniui vykdomus diegimus, kai nauji turiniai vis dar yra susieti su senaisiais turiniais.

Jei norite visiškai išvalyti `public/assets`, galite naudoti `bin/rails assets:clobber`.

### `bin/rails db:`

Dažniausiai naudojamos `db:` „Rails“ srities komandos yra `migrate` ir `create`, ir verta išbandyti visas migracijos „Rails“ komandas (`up`, `down`, `redo`, `reset`). `bin/rails db:version` yra naudinga, kai atsiranda problemų, nes ji parodo dabartinę duomenų bazės versiją.

Daugiau informacijos apie migracijas galite rasti [Migracijų](active_record_migrations.html) vadove.

### `bin/rails notes`

`bin/rails notes` ieško jūsų kodo komentarų, prasidedančių tam tikru raktažodžiu. Informaciją apie naudojimą galite rasti `bin/rails notes --help`.

Pagal numatytuosius nustatymus, jis ieškos `app`, `config`, `db`, `lib` ir `test` kataloguose esančių `FIXME`, `OPTIMIZE` ir `TODO` anotacijų turinčių failų su `.builder`, `.rb`, `.rake`, `.yml`, `.yaml`, `.ruby`, `.css`, `.js` ir `.erb` plėtiniais.

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

#### Anotacijos

Galite perduoti konkretias anotacijas, naudodami `--annotations` argumentą. Pagal numatytuosius nustatymus, jis ieškos `FIXME`, `OPTIMIZE` ir `TODO`.
Atkreipkite dėmesį, kad anotacijos skiriasi pagal didžiąsias ir mažąsias raides.

```bash
$ bin/rails notes --annotations FIXME RELEASE
app/controllers/admin/users_controller.rb:
  * [101] [RELEASE] We need to look at this before next release
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 17] [FIXME]
```

#### Žymos

Galite pridėti daugiau numatytųjų žymių, kurių ieškoma, naudodami `config.annotations.register_tags`. Jis priima žymių sąrašą.

```ruby
config.annotations.register_tags("DEPRECATEME", "TESTME")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] do A/B testing on this
  * [ 42] [TESTME] this needs more functional tests
  * [132] [DEPRECATEME] ensure this method is deprecated in next release
```

#### Katalogai

Galite pridėti daugiau numatytųjų katalogų, iš kurių ieškoma, naudodami `config.annotations.register_directories`. Jis priima katalogų pavadinimų sąrašą.

```ruby
config.annotations.register_directories("spec", "vendor")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```

#### Plėtiniai

Galite pridėti daugiau numatytųjų failų plėtinių, iš kurių ieškoma, naudodami `config.annotations.register_extensions`. Jis priima plėtinių sąrašą su atitinkamais reguliariaisiais išraiškomis, kad jie būtų atitinkami.

```ruby
config.annotations.register_extensions("scss", "sass") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/assets/stylesheets/application.css.sass:
  * [ 34] [TODO] Use pseudo element for this class

app/assets/stylesheets/application.css.scss:
  * [  1] [TODO] Split into multiple components

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```
### `bin/rails routes`

`bin/rails routes` pateiks visus apibrėžtus maršrutus, tai yra naudinga norint rasti maršrutų problemas savo programoje arba gauti gerą apžvalgą apie URL adresus programoje, su kuria norite susipažinti.

### `bin/rails test`

INFORMACIJA: Geras aprašymas vienetinio testavimo Rails programose pateiktas [Vadove testuojant Rails programą](testing.html)

Rails turi testavimo pagrindą, vadinamą minitest. Rails stabilumas priklauso nuo testų naudojimo. Komandos, prieinamos `test:` srities, padeda paleisti skirtingus testus, kuriuos tikėtina rašysite.

### `bin/rails tmp:`

`Rails.root/tmp` katalogas yra, kaip ir *nix /tmp katalogas, laikinas failų laikymo vieta, tokia kaip procesų ID failai ir talpyklos veiksmai.

`tmp:` srities komandos padės jums išvalyti ir sukurti `Rails.root/tmp` katalogą:

* `bin/rails tmp:cache:clear` išvalo `tmp/cache`.
* `bin/rails tmp:sockets:clear` išvalo `tmp/sockets`.
* `bin/rails tmp:screenshots:clear` išvalo `tmp/screenshots`.
* `bin/rails tmp:clear` išvalo visus talpyklos, jungtukų ir ekrano kopijų failus.
* `bin/rails tmp:create` sukuria tmp katalogus talpyklai, jungtukams ir procesų ID.

### Įvairūs

* `bin/rails initializers` išspausdina visus apibrėžtus pradinėjus tvarka, kuria jie yra kviečiami Rails.
* `bin/rails middleware` išvardina Rack tarpinės programinės įrangos paketo, įjungtos jūsų programai.
* `bin/rails stats` puikiai tinka peržiūrėti statistiką apie jūsų kodą, rodyti dalykus, tokius kaip KLOC (tūkstančiai kodo eilučių) ir jūsų kodo ir testų santykį.
* `bin/rails secret` suteiks jums pseudo-atsitiktinį raktą, kurį galite naudoti savo sesijos slaptajam raktui.
* `bin/rails time:zones:all` išvardina visas laiko juostas, kurias Rails žino.

### Individualios Rake užduotys

Individualios rake užduotys turi `.rake` plėtinį ir yra dedamos į `Rails.root/lib/tasks`. Šias individualias rake užduotis galite sukurti naudodami `bin/rails generate task` komandą.

```ruby
desc "Aš esu trumpas, bet išsamus aprašymas mano nuostabiai užduočiai"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # Visas jūsų stebuklas čia
  # Leidžiama bet kokia teisinga Ruby kalbos sintaksė
end
```

Norėdami perduoti argumentus savo individualiai rake užduočiai:

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

Užduočių grupavimui galite naudoti vardų erdves:

```ruby
namespace :db do
  desc "Ši užduotis nieko nedaro"
  task :nothing do
    # Iš tikrųjų, nieko
  end
end
```

Užduočių kvietimas atrodo taip:

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # visą argumentų eilutę reikia cituoti
$ bin/rails "task_name[value 1,value2,value3]" # atskirkite kelis argumentus kableliu
$ bin/rails db:nothing
```

Jei norite sąveikauti su savo programos modeliais, atlikti duomenų bazės užklausas ir t.t., jūsų užduotis turėtų priklausyti nuo `environment` užduoties, kuri įkelia jūsų programos kodą.

```ruby
task task_that_requires_app_code: [:environment] do
  User.create!
end
```
