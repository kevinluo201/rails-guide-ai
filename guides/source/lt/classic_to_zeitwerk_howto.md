**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9c6201fd526077579ef792e0c4e2150d
Klasikinio režimo pereinamasis prie Zeitwerk HOWTO
==================================================

Šis vadovas dokumentuoja, kaip perkelti „Rails“ programas iš „klasikinio“ į „Zeitwerk“ režimą.

Po šio vadovo perskaitymo žinosite:

* Kas yra „klasikinis“ ir „Zeitwerk“ režimai
* Kodėl persijungti nuo „klasikinio“ prie „Zeitwerk“
* Kaip aktyvuoti „Zeitwerk“ režimą
* Kaip patikrinti, ar jūsų programa veikia „Zeitwerk“ režime
* Kaip patikrinti, ar jūsų projektas teisingai įkeliamas komandinėje eilutėje
* Kaip patikrinti, ar jūsų projektas teisingai įkeliamas testų rinkinyje
* Kaip spręsti galimus ribinius atvejus
* Naujos funkcijos „Zeitwerk“, kurias galite naudoti

--------------------------------------------------------------------------------

Kas yra „klasikinis“ ir „Zeitwerk“ režimai?
--------------------------------------------------------

Nuo pat pradžių ir iki „Rails“ 5, „Rails“ naudojo „Active Support“ įgyvendintą automatinį įkėlimą. Šis automatinis įkėlimas žinomas kaip „klasikinis“ ir vis dar yra prieinamas „Rails“ 6.x. „Rails“ 7 šis automatinis įkėlimas daugiau neįtrauktas.

Pradedant nuo „Rails“ 6, „Rails“ pristato naują ir geresnį būdą automatiškai įkelti, kuris deleguoja į [Zeitwerk](https://github.com/fxn/zeitwerk) grotelę. Tai yra „Zeitwerk“ režimas. Pagal numatytuosius nustatymus, programos, įkeliančios 6.0 ir 6.1 versijos pagrindinius rėmus, veikia „Zeitwerk“ režime, ir tai yra vienintelis režimas, prieinamas „Rails“ 7.

Kodėl persijungti nuo „klasikinio“ prie „Zeitwerk“?
----------------------------------------

„Klasikinis“ automatinis įkėlimas buvo labai naudingas, bet turėjo keletą [probleminių](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#common-gotchas) dalykų, dėl kurių automatinis įkėlimas kartais buvo šiek tiek sudėtingas ir painus. „Zeitwerk“ buvo sukurtas tam, kad spręstų šią problemą, tarp kitų [motyvacijų](https://github.com/fxn/zeitwerk#motivation).

Kai atnaujinama į „Rails“ 6.x, labai rekomenduojama persijungti į „Zeitwerk“ režimą, nes tai yra geresnis automatinis įkėlimas, „klasikinio“ režimo naudojimas yra pasenus.

„Rails“ 7 baigia pereinamąjį laikotarpį ir neįtraukia „klasikinio“ režimo.

Aš bijau
-----------

Nebijok :).

„Zeitwerk“ buvo sukurtas taip, kad būtų kuo suderinamesnis su klasikiniu automatinio įkėlimo įrankiu. Jei jūsų veikianti programa šiandien teisingai įkelia, tikimybės, kad persijungimas bus lengvas. Daugelis projektų, didelių ir mažų, pranešė apie labai sklandžius persijungimus.

Šis vadovas padės jums pasitikėti automatinio įkėlimo įrankiu.

Jei dėl kokios nors priežasties susiduriate su situacija, kurios nežinote, kaip išspręsti, nebijokite [atidaryti problemos „rails/rails“](https://github.com/rails/rails/issues/new) ir pažymėti [`@fxn`](https://github.com/fxn).

Kaip aktyvuoti „Zeitwerk“ režimą
-------------------------------

### Programos, veikiančios su „Rails“ 5.x arba ankstesne versija

Programose, veikiančiose su „Rails“ versija ankstesne nei 6.0, „Zeitwerk“ režimas nėra prieinamas. Jums reikia būti bent „Rails“ 6.0.

### Programos, veikiančios su „Rails“ 6.x

Programose, veikiančiose su „Rails“ 6.x, yra du scenarijai.

Jei programa įkelia „Rails“ 6.0 arba 6.1 pagrindinius rėmus ir veikia „klasikiniame“ režime, ją reikia išjungti rankiniu būdu. Jums turi būti kažkas panašaus į tai:

```ruby
# config/application.rb
config.load_defaults 6.0
config.autoloader = :classic # IŠTRINKITE ŠĮ EILUTĘ
```

Kaip pastebėta, tiesiog ištrinkite perrašymą, „Zeitwerk“ režimas yra numatytasis.

Kita vertus, jei programa įkelia senus pagrindinius rėmus, jums reikia išjungti „Zeitwerk“ režimą:

```ruby
# config/application.rb
config.load_defaults 5.2
config.autoloader = :zeitwerk
```

### Programos, veikiančios su „Rails“ 7

„Rails“ 7 yra tik „Zeitwerk“ režimas, jums nereikia nieko daryti, kad jį įjungtumėte.

Iš tikrųjų, „config.autoloader =“ nustatymojo netgi neegzistuoja „config/application.rb“. Jei jis naudojamas, prašome ištrinti eilutę.

Kaip patikrinti, ar programa veikia „Zeitwerk“ režime?
------------------------------------------------------

Norėdami patikrinti, ar programa veikia „Zeitwerk“ režime, įvykdykite

```
bin/rails runner 'p Rails.autoloaders.zeitwerk_enabled?'
```

Jei tai spausdina „true“, „Zeitwerk“ režimas yra įjungtas.

Ar mano programa atitinka „Zeitwerk“ konvencijas?
-----------------------------------------------------

### config.eager_load_paths

Atitikties testas vykdomas tik užkraunant failus. Todėl norint patikrinti „Zeitwerk“ atitiktį, rekomenduojama visus automatinio įkėlimo kelius įtraukti į užkraunimo kelius.

Pagal numatytuosius nustatymus tai jau yra taip, bet jei projekte yra konfigūruoti papildomi automatinio įkėlimo keliai, panašūs į šiuos:

```ruby
config.autoload_paths << "#{Rails.root}/extras"
```

jie nėra užkraunami ir nebus patikrinti. Juos pridėti prie užkraunimo kelių yra lengva:

```ruby
config.autoload_paths << "#{Rails.root}/extras"
config.eager_load_paths << "#{Rails.root}/extras"
```

### zeitwerk:check

Kai įjungtas „Zeitwerk“ režimas ir patikrintas užkraunimo kelių konfigūravimas, paleiskite:

```
bin/rails zeitwerk:check
```

Sėkmingas patikrinimas atrodo taip:

```
% bin/rails zeitwerk:check
Palaukite, aš užkraunu programą.
Viskas gerai!
```

Gali būti papildomų rezultatų, priklausomai nuo programos konfigūracijos, bet paskutinė „Viskas gerai!“ yra tai, ko ieškote.
Jei dvigubas patikrinimas, paaiškintas ankstesniame skyriuje, nustatė, kad iš tikrųjų turi būti keli papildomi automatinio įkėlimo takai už automatinio įkėlimo takų ribų, užduotis juos aptiks ir įspės apie tai. Tačiau jei testų rinkinys sėkmingai įkelia tuos failus, tai gerai.

Dabar, jei yra bet koks failas, kuris nenustato tikėtinos konstantos, užduotis tai jums pasakys. Ji tai daro vienu failu vienu metu, nes jei ji judėtų toliau, vieno failo įkėlimo nesėkmė galėtų išplisti į kitas nesusijusias klaidas, susijusias su vykdomu patikrinimu, ir klaidų pranešimas būtų painus.

Jei pranešama apie vieną konstantą, ištaisykite tik tą ir paleiskite užduotį dar kartą. Kartokite, kol gausite "Viskas gerai!".

Pavyzdžiui:

```
% bin/rails zeitwerk:check
Palaukite, aš įkeliantis programą.
tikėtasi, kad failas app/models/vat.rb nustatys konstantą Vat
```

PVM yra Europos mokesčiai. Failas `app/models/vat.rb` nustato `VAT`, bet automatinis įkėlėjas tikisi `Vat`, kodėl?

### Akronimai

Tai yra dažniausia rūšis nesutapimų, su kuriomis galite susidurti, tai susiję su akronimais. Paaiškinkime, kodėl gauname tą klaidos pranešimą.

Klasikinis automatinis įkėlėjas gali automatiškai įkelti `VAT`, nes jo įvestis yra trūkstamos konstantos pavadinimas, `VAT`, jis iškviečia `underscore` funkciją, kuri grąžina `vat`, ir ieško failo, kuris vadinasi `vat.rb`. Tai veikia.

Naujojo automatinio įkėlėjo įvestis yra failų sistema. Duodamas failas `vat.rb`, Zeitwerk iškviečia `camelize` funkciją su `vat`, kuri grąžina `Vat`, ir tikisi, kad failas nustatys konstantą `Vat`. Tai sako klaidos pranešimas.

Tai lengva ištaisyti, jums tiesiog reikia pranešti inflektorui apie šį akronimą:

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "VAT"
end
```

Tai paveikia, kaip Active Support inflektuoja globaliai. Tai gali būti gerai, bet jei norite, galite taip pat perduoti perrašymus į automatinio įkėlėjo naudojamus inflektorius:

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.inflector.inflect("vat" => "VAT")
```

Turėdami šią parinktį, turite daugiau kontrolės, nes tik failai, kurie tiksliai vadina `vat.rb` arba tiksliai vadina `vat` direktorijas, bus inflektuojami kaip `VAT`. Failas, vadintas `vat_rules.rb`, tuo netrikdomas ir gali nustatyti `VatRules` visiškai gerai. Tai gali būti naudinga, jei projekte yra šios rūšies pavadinimo nesuderinamumų.

Turint tai vietoje, patikrinimas pavyksta!

```
% bin/rails zeitwerk:check
Palaukite, aš įkeliantis programą.
Viskas gerai!
```

Kai viskas gerai, rekomenduojama toliau patikrinti projektą testų rinkinyje. Skyriuje [_Patikrinkite Zeitwerk atitikimą testų rinkinyje_](#check-zeitwerk-compliance-in-the-test-suite) paaiškinama, kaip tai padaryti.

### Susirūpinimai

Galite automatiškai įkelti ir įkelti iš standartinės struktūros su `susirūpinimais` subdirektorijomis, pavyzdžiui

```
app/models
app/models/susirūpinimai
```

Pagal numatytuosius nustatymus `app/models/susirūpinimai` priklauso automatinio įkėlimo takams ir todėl laikoma šakniniu katalogu. Taigi, pagal numatytuosius nustatymus, `app/models/susirūpinimai/foo.rb` turėtų nustatyti `Foo`, o ne `Susirūpinimai::Foo`.

Jei jūsų programa naudoja `Susirūpinimai` kaip vardų erdvę, turite dvi galimybes:

1. Pašalinkite `Susirūpinimai` vardų erdvę iš tų klasių ir modulių ir atnaujinkite kliento kodą.
2. Palikite viską kaip yra, pašalindami `app/models/susirūpinimai` iš automatinio įkėlimo takų:

  ```ruby
  # config/initializers/zeitwerk.rb
  ActiveSupport::Dependencies.
    autoload_paths.
    delete("#{Rails.root}/app/models/susirūpinimai")
  ```

### `app` turėjimas automatinio įkėlimo takuose

Kai kurie projektai nori, kad kažkas panašaus į `app/api/base.rb` nustatytų `API::Base` ir prideda `app` į automatinio įkėlimo takus, kad tai pasiektų.

Kadangi „Rails“ automatiškai prideda visus `app` subdirektorijas į automatinio įkėlimo takus (su keliais išimtimis), turime dar vieną situaciją, kai yra įdėti įdėti šakniniai katalogai, panašūs į tai, kas vyksta su `app/models/susirūpinimai`. Taip nustatymas nebeveikia.

Tačiau galite išlaikyti tą struktūrą, tiesiog ištrindami `app/api` iš automatinio įkėlimo takų inicializavimo faile:

```ruby
# config/initializers/zeitwerk.rb
ActiveSupport::Dependencies.
  autoload_paths.
  delete("#{Rails.root}/app/api")
```

Būkite atsargūs dėl subdirektorijų, kuriuose nėra failų, kurie turi būti automatiškai įkeliami/įkraunami. Pavyzdžiui, jei programa turi `app/admin` su ištekliais skirtais [ActiveAdmin](https://activeadmin.info/), jums reikia jų ignoruoti. Taip pat ir `assets` ir panašiai:

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.ignore(
  "app/admin",
  "app/assets",
  "app/javascripts",
  "app/views"
)
```

Be to, programa įkraus tuos medžius. Klaidos pranešimas dėl `app/admin` būtų dėl to, kad jo failai nenustato konstantų, ir būtų apibrėžtas `Views` modulis, pavyzdžiui, kaip nepageidaujamas šalutinis poveikis.

Kaip matote, turėti `app` automatinio įkėlimo takuose yra techniškai įmanoma, bet šiek tiek sudėtinga.

### Automatiškai įkeliamos konstantos ir aiškios vardų erdvės

Jei vardų erdvė yra apibrėžta faile, kaip čia yra `Hotel`:

```
app/models/hotel.rb         # Apibrėžia viešbutį.
app/models/hotel/pricing.rb # Apibrėžia viešbučio kainodarą.
```

`Hotel` konstanta turi būti nustatyta naudojant `class` arba `module` raktažodžius. Pavyzdžiui:

```ruby
class Hotel
end
```

yra gerai.

Alternatyvos, tokios kaip

```ruby
Hotel = Class.new
```

arba

```ruby
Hotel = Struct.new
```

neveiks, vaikinės objektai, tokie kaip `Hotel::Pricing`, nebus rasti.

Šis apribojimas taikomas tik aiškioms vardų erdvėms. Klasės ir moduliai, kurie nenustato vardų erdvės, gali būti apibrėžti naudojant tuos idiomus.

### Vienas failas, viena konstanta (tame pačiame viršutiniame lygyje)

`Klasikinėje` veiksenos režime techniškai galėjote apibrėžti kelias konstantas tame pačiame viršutiniame lygyje ir visus jas perkrauti. Pavyzdžiui, turint

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

nors `Bar` negalėtų būti automatiškai įkeltas, įkeliant `Foo` pažymėtų `Bar` kaip įkeltą taip pat.

Tai netaikoma `zeitwerk` režime, jums reikia perkelti `Bar` į savo atskirą failą `bar.rb`. Vienas failas, viena viršutinio lygio konstanta.

Tai paveikia tik konstantas, esančias tame pačiame viršutiniame lygyje, kaip pavyzdyje aukščiau. Vidinės klasės ir moduliai yra gerai. Pavyzdžiui, apsvarstykite

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

Jei programa perkrauna `Foo`, ji taip pat perkraus `Foo::InnerClass`.

### Šablonai `config.autoload_paths`

Būkite atsargūs, konfigūracijose, kuriose naudojami šablonai, tokie kaip

```ruby
config.autoload_paths += Dir["#{config.root}/extras/**/"]
```

Kiekvienas `config.autoload_paths` elementas turėtų atstovauti viršutinei vardų erdvei (`Object`). Tai neveiks.

Norėdami tai ištaisyti, tiesiog pašalinkite šablonus:

```ruby
config.autoload_paths << "#{config.root}/extras"
```

### Klasės ir moduliai iš varikliukų dekoravimas

Jei jūsų programa dekoruoja klasės ar modulio iš variklio objektus, tikimybė, kad ji tai daro kažkur:

```ruby
config.to_prepare do
  Dir.glob("#{Rails.root}/app/overrides/**/*_override.rb").sort.each do |override|
    require_dependency override
  end
end
```

Tai turi būti atnaujinta: turite pranešti `pagrindiniam` įkėlėjui ignoruoti katalogą su perrašymais, ir juos turite įkelti naudojant `load`. Kažkas panašaus:

```ruby
overrides = "#{Rails.root}/app/overrides"
Rails.autoloaders.main.ignore(overrides)
config.to_prepare do
  Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
    load override
  end
end
```

### `before_remove_const`

Rails 3.1 pridėjo palaikymą `before_remove_const` atgaliniam iškvietimui, kuris buvo iškviečiamas, jei klasė ar modulis atsakė į šį metodą ir buvo perkrautas. Šis atgalinis iškvietimas liko kitaip nesudokumentuotas ir mažai tikėtina, kad jūsų kodas jį naudoja.

Tačiau, jei taip yra, galite pertvarkyti kažką panašaus į

```ruby
class Country < ActiveRecord::Base
  def self.before_remove_const
    expire_redis_cache
  end
end
```

kaip

```ruby
# config/initializers/country.rb
if Rails.application.config.reloading_enabled?
  Rails.autoloaders.main.on_unload("Country") do |klass, _abspath|
    klass.expire_redis_cache
  end
end
```

### Spring ir `test` aplinka

Spring perkrauna programos kodą, jei kažkas pasikeičia. `Test` aplinkoje jums reikia įjungti perkrovimą, kad tai veiktų:

```ruby
# config/environments/test.rb
config.cache_classes = false
```

arba, nuo Rails 7.1:

```ruby
# config/environments/test.rb
config.enable_reloading = true
```

Kitu atveju gausite:

```
perkrovimas išjungtas, nes config.cache_classes yra true
```

arba

```
perkrovimas išjungtas, nes config.enable_reloading yra false
```

Tai neturi jokio našumo nuostolio.

### Bootsnap

Įsitikinkite, kad priklausote bent jau nuo Bootsnap 1.4.4.


Patikrinkite `Zeitwerk` atitikimą testų rinkinyje
-------------------------------------------

Užduotis `zeitwerk:check` yra patogi migracijai. Kai projektas atitinka reikalavimus, rekomenduojama automatizuoti šią patikrą. Tam pakanka įkelti programą, tai ir daro `zeitwerk:check`.

### Nuolatinis integravimas

Jei jūsų projektas turi nuolatinį integravimą, gerai būtų įkelti programą, kai ten vyksta testų rinkinys. Jei dėl kokios nors priežasties programa negali būti nuolat įkelta, geriau žinoti tai nuolatinėje integracijoje nei gamyboje, ar ne?

Įprastai nuolatinės integracijos nustato tam tikrą aplinkos kintamąjį, nurodantį, kad testų rinkinys vyksta ten. Pavyzdžiui, tai gali būti `CI`:

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

Nuo Rails 7 pradžios, naujai sukuriamos programos yra tokiu būdu konfigūruojamos pagal numatytuosius nustatymus.

### Paprasti testų rinkiniai

Jei jūsų projektas neturi nuolatinės integracijos, vis tiek galite įkelti programą testų rinkinyje, iškviesdami `Rails.application.eager_load!`:

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "įkelia visus failus be klaidų" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk atitikimas" do
  it "įkelia visus failus be klaidų" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

Ištrinkite visus `require` iškvietimus
--------------------------

Iš mano patirties, projektai paprastai to nedaro. Bet aš mačiau keletą, ir girdėjau apie keletą kitų.
Rails aplikacijoje naudojamas `require` tik tam, kad įkeltų kodą iš `lib` arba iš trečiųjų šalių, tokias kaip priklausomybės nuo juvelyrinių akmenų ar standartinė biblioteka. **Niekada neįkelkite automatiškai įkeliamo aplikacijos kodo su `require`**. Žr., kodėl tai buvo bloga idėja, jau čia `classic` [čia](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#autoloading-and-require).

```ruby
require "nokogiri" # GERAI
require "net/http" # GERAI
require "user"     # BLOGAI, IŠTRINKITE TAI (tikimasi, kad tai app/models/user.rb)
```

Prašome ištrinti visas tokių tipo `require` iškvietimus.

Naujos funkcijos, kurias galite pasinaudoti
--------------------------------------------

### Ištrinkite `require_dependency` iškvietimus

Su Zeitwerk visi žinomi `require_dependency` naudojimo atvejai buvo pašalinti. Turėtumėte peržiūrėti projektą ir juos ištrinti.

Jei jūsų aplikacija naudoja vienos lentelės paveldėjimą, prašome peržiūrėti [Vienos lentelės paveldėjimo skyrių](autoloading_and_reloading_constants.html#single-table-inheritance) Automašinio įkelimo ir konstantų perkrovimo (Zeitwerk režimas) vadove.

### Kvalifikuoti vardai klasės ir modulio apibrėžimuose dabar yra galimi

Dabar galite tvirtai naudoti konstantų kelius klasės ir modulio apibrėžimuose:

```ruby
# Automatiškas įkėlimas šioje klasės kūne dabar atitinka Ruby semantiką.
class Admin::UsersController < ApplicationController
  # ...
end
```

Reikia atkreipti dėmesį, kad, priklausomai nuo vykdymo tvarkos, klasikinis automatiškas įkėlimas kartais galėjo įkelti `Foo::Wadus` šioje vietoje:

```ruby
class Foo::Bar
  Wadus
end
```

Tai neatitinka Ruby semantikos, nes `Foo` nėra įdėjime, ir visai neveiks `zeitwerk` režime. Jei rastumėte tokį kampinį atvejį, galite naudoti kvalifikuotą vardą `Foo::Wadus`:

```ruby
class Foo::Bar
  Foo::Wadus
end
```

arba pridėti `Foo` į įdėjimą:

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

### Gijų saugumas visur

`classic` režime konstantos automatiškai neįkeliamos saugios gijose, nors „Rails“ turi užraktus, pavyzdžiui, kad web užklausos būtų saugios gijose.

Konstantų automatiškas įkėlimas yra saugus gijose `zeitwerk` režime. Pavyzdžiui, dabar galite automatiškai įkelti daugiausiai gijų skriptus, vykdomus naudojant `runner` komandą.

### Ankstyvasis įkėlimas ir automatinis įkėlimas yra nuoseklūs

`classic` režime, jei `app/models/foo.rb` apibrėžia `Bar`, jūs negalėsite automatiškai įkelti to failo, bet ankstyvasis įkėlimas veiks, nes jis rekursyviai įkelia failus be jokio apmąstymo. Tai gali būti klaidų šaltinis, jei pirmiausia testuojate dalykus, ankstyvasis įkėlimas gali nesėkmingai vykdyti vėlesnį automatinį įkėlimą.

`zeitwerk` režime abu įkėlimo režimai yra nuoseklūs, jie klaidos ir klaidos tais pačiais failais.
