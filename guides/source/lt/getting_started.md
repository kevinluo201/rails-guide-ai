**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2cf37358fedc8b51ed3ab7f408ecfc76
Pradėkite su Rails
==========================

Šis vadovas aprėpia pradinius žingsnius, kuriant ir paleidžiant Ruby on Rails.

Po šio vadovo perskaitymo, jūs žinosite:

* Kaip įdiegti Rails, sukurti naują Rails aplikaciją ir prijungti ją prie duomenų bazės.
* Bendrą Rails aplikacijos išdėstymą.
* Pagrindinius MVC (Modelis, Vaizdas, Valdiklis) ir RESTful dizaino principus.
* Kaip greitai generuoti pradines Rails aplikacijos dalis.

--------------------------------------------------------------------------------

Vadovo prielaidos
-----------------

Šis vadovas skirtas pradedantiesiems, kurie nori pradėti kurti Rails aplikaciją nuo nulio. Jis nenumato, kad jūs turite ankstesnį patirtį su Rails.

Rails yra internetinės aplikacijos karkasas, veikiantis Ruby programavimo kalboje. Jei neturite ankstesnės patirties su Ruby, jums gali būti labai sunku iš karto pradėti mokytis Rails. Yra keletas atrinktų internetinių išteklių sąrašų, skirtų Ruby mokymuisi:

* [Oficiali Ruby programavimo kalbos svetainė](https://www.ruby-lang.org/en/documentation/)
* [Nemokamų programavimo knygų sąrašas](https://github.com/EbookFoundation/free-programming-books/blob/master/books/free-programming-books-langs.md#ruby)

Atkreipkite dėmesį, kad kai kurie ištekliai, nors ir puikūs, apima senesnes Ruby versijas ir gali neįtraukti kai kurių sintaksės, kurią matysite kasdieninėje Rails plėtros veikloje.

Kas yra Rails?
--------------

Rails yra internetinės aplikacijos kūrimo karkasas, parašytas Ruby programavimo kalba. Jis yra skirtas palengvinti internetinių aplikacijų programavimą, padarant prielaidas apie tai, ko kiekvienam programuotojui reikia pradėti. Tai leidžia rašyti mažiau kodo, tuo pačiu atliekant daugiau nei daugelis kitų kalbų ir karkasų.
Patyrę Rails programuotojai taip pat praneša, kad tai daro internetinės aplikacijos kūrimą smagesnį.

Rails yra nuomonės turinti programa. Ji daro prielaidą, kad yra "geriausias" būdas daryti dalykus ir yra skirta skatinti šį būdą - ir kai kuriomis atvejais atskirti nuo alternatyvų. Jei išmoksite "Rails būdą", tikriausiai pastebėsite didelį produktyvumo padidėjimą. Jei toliau laikysitės senų įpročių iš kitų kalbų savo Rails plėtros metu ir bandysite naudoti modelius, kuriuos išmokote kitur, jūs galite turėti mažiau malonią patirtį.

Rails filosofija apima dvi pagrindines gaires:

* **Nepakartokite savęs:** DRY yra programinės įrangos kūrimo principas, kuris teigia, kad "kiekvienas žinių gabalas turi turėti vienintelį, aiškų, autoritetinį atvaizdą sistemoje". Nesikartodami rašydami tą pačią informaciją daug kartų, mūsų kodas yra lengviau palaikomas, plėtojamas ir mažiau klaidų.
* **Konvencija virš konfigūracijos:** Rails turi nuomonę apie geriausią būdą daryti daugelį dalykų internetinėje aplikacijoje ir pagal nutylėjimą naudoja šį konvencijų rinkinį, o ne reikalauja nurodyti smulkmenų per begalinius konfigūracijos failus.

Naujos Rails projekto sukūrimas
----------------------------

Geriausias būdas perskaityti šį vadovą yra sekti jį žingsnis po žingsnio. Visi žingsniai yra būtini šios pavyzdinės aplikacijos paleidimui ir nereikia jokio papildomo kodo ar žingsnių.

Sekdami šiuo vadovu, sukursite Rails projektą, vadinamą "blog", (labai) paprastą tinklaraštį. Prieš pradedant kurti aplikaciją, turite įsitikinti, kad jau įdiegėte patį Rails.

Pastaba: Žemiau pateikti pavyzdžiai naudoja `$` simbolį, kad reprezentuotų jūsų terminalo įspėjimą UNIX tipo OS, nors jis gali būti pritaikytas kitaip. Jei naudojate Windows, jūsų įspėjimas atrodys kažkaip panašiai į `C:\source_code>`.

### Rails įdiegimas

Prieš įdiegdami Rails, turėtumėte patikrinti, ar jūsų sistema turi tinkamus priklausomybes. Tai apima:

* Ruby
* SQLite3

#### Ruby įdiegimas

Atidarykite komandinės eilutės langą. macOS atidarykite Terminal.app; Windows pasirinkite "Run" iš savo Start meniu ir įveskite `cmd.exe`. Bet kokie komandos, prasidedantys dolerio ženklu `$`, turėtų būti vykdomi komandinėje eilutėje. Patikrinkite, ar jau įdiegėte naujausią Ruby versiją:

```bash
$ ruby --version
ruby 2.7.0
```

Rails reikalauja Ruby versijos 2.7.0 arba naujesnės. Rekomenduojama naudoti naujausią Ruby versiją.
Jei grąžintas versijos numeris yra mažesnis nei šis skaičius (pvz., 2.3.7 arba 1.8.7), turėsite įdiegti naują Ruby kopiją.

Norėdami įdiegti Rails Windows, pirmiausia turite įdiegti [Ruby Installer](https://rubyinstaller.org/).

Daugiau įdiegimo metodų daugumai operacinėms sistemoms galite rasti
[ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/).

#### SQLite3 įdiegimas

Jums taip pat reikės įdiegti SQLite3 duomenų bazę.
Daugelis populiarių UNIX tipo operacinių sistemų turi tinkamą SQLite3 versiją.
Kiti gali rasti įdiegimo instrukcijas [SQLite3 svetainėje](https://www.sqlite.org).
Patikrinkite, ar jis įdiegtas teisingai ir yra jūsų apkrovos `PATH`:

```bash
$ sqlite3 --version
```

Programa turėtų pranešti savo versiją.

#### Rails diegimas

Norėdami įdiegti Rails, naudokite `gem install` komandą, kurią teikia RubyGems:

```bash
$ gem install rails
```

Norėdami patikrinti, ar viskas įdiegta teisingai, turėtumėte galėti paleisti šią komandą naujame terminalo lange:

```bash
$ rails --version
```

Jei jis rodo kažką panašaus į "Rails 7.0.0", galite tęsti.

### Sukurkite tinklaraščio aplikaciją

Rails turi keletą generatorių scenarijų, kurie yra skirti palengvinti jūsų plėtros gyvenimą, sukurdami viską, kas reikalinga pradėti dirbti tam tikrą užduotį. Vienas iš jų yra naujo aplikacijos generatorius, kuris suteiks jums šviežios Rails aplikacijos pagrindą, kad neturėtumėte rašyti jos patys.

Norėdami naudoti šį generatorių, atidarykite terminalą, pereikite į katalogą, kuriame turite teises kurti failus, ir paleiskite:

```bash
$ rails new blog
```

Tai sukurs Rails aplikaciją, vadinamą Blog, `blog` kataloge ir įdiegs `Gemfile` jau minėtus priklausomybių paketus naudojant `bundle install`.

PATARIMAS: Galite pamatyti visus komandų eilutės parametrus, kuriuos priima Rails aplikacijos generatorius, paleisdami `rails new --help`.

Po to, kai sukūrėte tinklaraščio aplikaciją, perjunkite į jos aplanką:

```bash
$ cd blog
```

`blog` kataloge bus keletas sukurtų failų ir aplankų, sudarančių Rails aplikacijos struktūrą. Dauguma darbo šiame vadove vyks `app` aplanke, tačiau čia yra pagrindinė informacija apie kiekvieno iš pagal nutylėjimą sukurtų failų ir aplankų funkciją:

| Failas/Aplankas | Paskirtis |
| ----------- | ------- |
|app/|Aplankas, kuriame yra jūsų aplikacijos kontroleriai, modeliai, rodiniai, pagalbininkai, pašto siuntėjai, kanalai, darbo vietos ir ištekliai. Daugiau dėmesio šiame vadove skirsite šiam aplankui.|
|bin/|Aplankas, kuriame yra `rails` scenarijus, kuris paleidžia jūsų aplikaciją, ir gali būti kiti scenarijai, kuriuos naudojate savo aplikacijos diegimui, atnaujinimui, išdėstymui ar paleidimui.|
|config/|Aplankas, kuriame yra konfigūracija jūsų aplikacijos maršrutams, duomenų bazėms ir kt. Apie tai išsamiau kalbama [Konfigūruojant Rails aplikacijas](configuring.html).|
|config.ru|Rack konfigūracija Rack pagrindiniams serveriams, naudojamiems paleisti aplikaciją. Daugiau informacijos apie Rack rasite [Rack svetainėje](https://rack.github.io/).|
|db/|Aplankas, kuriame yra jūsų esama duomenų bazės schema ir duomenų bazės migracijos.|
|Gemfile<br>Gemfile.lock|Šie failai leidžia nurodyti, kokios priklausomybės nuo paketų reikalingos jūsų Rails aplikacijai. Šiuos failus naudoja Bundler paketas. Daugiau informacijos apie Bundler rasite [Bundler svetainėje](https://bundler.io).|
|lib/|Išplėstiniai moduliai jūsų aplikacijai.|
|log/|Aplikacijos žurnalo failai.|
|public/|Aplankas, kuriame yra statiniai failai ir sukompiliuoti ištekliai. Paleidus jūsų aplikaciją, šis aplankas bus prieinamas kaip yra.|
|Rakefile|Šis failas randa ir įkelia užduotis, kurias galima paleisti iš komandinės eilutės. Užduočių apibrėžimai yra apibrėžti visuose Rails komponentuose. Vietoj `Rakefile` keitimo, savo užduotis turėtumėte pridėti pridedant failus į savo aplikacijos `lib/tasks` aplanką.|
|README.md|Tai trumpas jūsų aplikacijos instrukcijų vadovas. Šį failą turėtumėte redaguoti, kad kitiems žmonėms būtų aišku, ką jūsų aplikacija daro, kaip ją sukonfigūruoti ir t. t.|
|storage/|Active Storage failai disko paslaugai. Apie tai išsamiau kalbama [Active Storage apžvalgoje](active_storage_overview.html).|
|test/|Vienetų testai, fiktyvūs duomenys ir kitos testavimo priemonės. Apie tai išsamiau kalbama [Rails aplikacijų testavime](testing.html).|
|tmp/|Laikini failai (pvz., talpyklos ir pid failai).|
|vendor/|Vieta visam trečiųjų šalių kodui. Tipiškoje Rails aplikacijoje tai apima pardavimo paketus.|
|.gitattributes|Šis failas nurodo metaduomenis tam tikriems keliose git saugykloje. Šie metaduomenys gali būti naudojami git ir kitomis priemonėmis, kad pagerintų jų veikimą. Daugiau informacijos rasite [gitattributes dokumentacijoje](https://git-scm.com/docs/gitattributes).|
|.gitignore|Šis failas nurodo git, kurie failai (ar šablonai) turėtų būti ignoruojami. Daugiau informacijos apie failų ignoravimą rasite [GitHub - Ignoring files](https://help.github.com/articles/ignoring-files).|
|.ruby-version|Šis failas nurodo numatytąją Ruby versiją.|

Sveiki, Rails!
-------------

Pradėkime nuo to, kad greitai atvaizduotume tekstą ekrane. Tam reikia paleisti savo Rails aplikacijos serverį.

### Paleidimas

Iš tikrųjų jau turite veikiančią Rails aplikaciją. Norėdami ją pamatyti, turite paleisti interneto serverį savo plėtros mašinoje. Tai galite padaryti paleisdami šią komandą `blog` aplanke:

```bash
$ bin/rails server
```
PATARIMAS: Jei naudojate "Windows" operacinę sistemą, skriptus reikia perduoti tiesiogiai "Ruby" interpretatoriui, pvz., `ruby bin\rails server`.

PATARIMAS: "JavaScript" turinio suspaudimui reikalingas "JavaScript" vykdymo laikas jūsų sistemoje, o jo nebuvimo atveju suspaudimo metu bus rodoma "execjs" klaida. Paprastai "macOS" ir "Windows" jau turi įdiegtą "JavaScript" vykdymo laiką. "therubyrhino" yra rekomenduojamas vykdymo laikas "JRuby" naudotojams ir jis pagal numatymą pridedamas į "Gemfile" programose, kurios yra sukuriamos naudojant "JRuby". Galite išsiaiškinti visus palaikomus vykdymo laikus [ExecJS](https://github.com/rails/execjs#readme) svetainėje.

Tai paleis "Puma", naršyklės serverį, kuris yra numatytas "Rails". Norėdami pamatyti savo programą veikiantį, atidarykite naršyklės langą ir eikite į adresą <http://localhost:3000>. Turėtumėte pamatyti numatytąjį "Rails" informacijos puslapį:

![Rails paleidimo puslapio ekrano kopija](images/getting_started/rails_welcome.png)

Kai norite sustabdyti naršyklės serverį, spustelėkite Ctrl+C terminalo lange, kuriame jis veikia. Vystymo aplinkoje "Rails" paprastai nereikalauja paleisti serverio iš naujo; pakeitimai, kuriuos atliekate failuose, bus automatiškai aptinkami serverio.

"Rails" paleidimo puslapis yra naujos "Rails" programos "smoke test": jis užtikrina, kad jūsų programinė įranga būtų tinkamai sukonfigūruota, kad galėtų aptarnauti puslapį.

### Pasakykite "Sveiki", "Rails"

Norėdami gauti pranešimą "Sveiki", "Rails", jums reikia sukurti bent jau *maršrutą*, *valdiklį* su *veiksmu* ir *vaizdą*. Maršrutas susieja užklausą su valdiklio veiksmu. Valdiklio veiksmas atlieka reikalingą darbą, kad apdorotų užklausą ir paruoštų bet kokius duomenis vaizdui. Vaizdas rodo duomenis norimu formatu.

Implementacijos požiūriu: Maršrutai yra taisyklės, parašytos "Ruby" [DSL (Domain-Specific Language)](https://en.wikipedia.org/wiki/Domain-specific_language) kalba. Valdikliai yra "Ruby" klasės, o jų viešieji metodai yra veiksmai. O vaizdai yra šablonai, paprastai parašyti mišiniu iš HTML ir "Ruby".

Pradėkime pridedant maršrutą į mūsų maršrutų failą `config/routes.rb`, viršuje esančią `Rails.application.routes.draw` bloke:

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # Daugiau informacijos apie šio failo DSL rasite adresu https://guides.rubyonrails.org/routing.html
end
```

Pirmiau pateiktas maršrutas nurodo, kad `GET /articles` užklausos yra susiejamos su `ArticlesController` `index` veiksmu.

Norėdami sukurti `ArticlesController` ir jo `index` veiksmą, paleisime valdiklio generatorių (su `--skip-routes` parinktimi, nes jau turime tinkamą maršrutą):

```bash
$ bin/rails generate controller Articles index --skip-routes
```

"Rails" sukurs kelis failus:

```
create  app/controllers/articles_controller.rb
invoke  erb
create    app/views/articles
create    app/views/articles/index.html.erb
invoke  test_unit
create    test/controllers/articles_controller_test.rb
invoke  helper
create    app/helpers/articles_helper.rb
invoke    test_unit
```

Svarbiausias iš jų yra valdiklio failas `app/controllers/articles_controller.rb`. Pažiūrėkime į jį:

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```

`index` veiksmas yra tuščias. Kai veiksmas neišreiškiamai sugeneruoja vaizdą (arba kitaip sukelia HTTP atsaką), "Rails" automatiškai sugeneruos vaizdą, kuris atitinka valdiklio ir veiksmo pavadinimą. Konvencija virš konfigūracijos! Vaizdai yra rasti `app/views` kataloge. Taigi `index` veiksmas pagal numatymą sugeneruos `app/views/articles/index.html.erb` vaizdą.

Atidarykime `app/views/articles/index.html.erb` ir pakeiskime jo turinį į:

```html
<h1>Sveiki, Rails!</h1>
```

Jei anksčiau sustabdėte naršyklės serverį, kad paleistumėte valdiklio generatorių, paleiskite jį iš naujo su komanda `bin/rails server`. Dabar apsilankykite adresu <http://localhost:3000/articles> ir pamatysite mūsų tekstą!

### Nustatyti programos pagrindinį puslapį

Šiuo metu, <http://localhost:3000> vis dar rodo puslapį su "Ruby on Rails" logotipu. Norėdami taip pat rodyti mūsų "Sveiki, Rails!" tekstą adresu <http://localhost:3000>, pridėsime maršrutą, kuris susieja mūsų programos *šakninį kelią* su tinkamu valdikliu ir veiksmu.

Atidarykime `config/routes.rb` ir pridėkime šį `root` maršrutą viršuje esančiam `Rails.application.routes.draw` blokui:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

Dabar, kai apsilankysime adresu <http://localhost:3000>, galėsime pamatyti mūsų "Sveiki, Rails!" tekstą, patvirtinant, kad `root` maršrutas taip pat yra susietas su `ArticlesController` `index` veiksmu.

PATARIMAS: Norėdami sužinoti daugiau apie maršrutavimą, žiūrėkite [Rails maršrutavimas iš išorės](routing.html).

Automatinis įkėlimas
-----------

"Rails" programos **nenaudoja** `require` funkcijos programos kodo įkėlimui.

Galbūt pastebėjote, kad `ArticlesController` paveldi `ApplicationController`, tačiau `app/controllers/articles_controller.rb` faile nėra nieko panašaus į

```ruby
require "application_controller" # NEDARYKITE TAIP.
```

Programos klasės ir moduliai yra prieinami visur, jums nereikia ir **neturėtumėte** įkelti nieko iš `app` naudojant `require`. Ši funkcija vadinama _automatiniu įkėlimu_, ir apie ją galite sužinoti daugiau [_Automatinis įkėlimas ir konstantų perkrovimas_](autoloading_and_reloading_constants.html) puslapyje.
Jums reikia tik `require` iškvietimų dviems naudojimo atvejams:

* Įkelti failus iš `lib` direktorijos.
* Įkelti `Gemfile` faile esančias priklausomybes, kurios turi `require: false` nustatymą.

MVC ir Jūs
-----------

Iki šiol mes aptarėme maršrutus, kontrolerius, veiksmus ir rodinius. Visi šie
yra tipiniai internetinės programos dalys, kurios seka [MVC (Model-View-Controller)](
https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) modelį.
MVC yra projektavimo modelis, kuris padalina programos atsakomybes
tam, kad būtų lengviau suprasti. „Rails“ šį projektavimo modelį laikosi pagal konvenciją.

Kadangi turime kontrolerį ir rodinį, leiskite generuoti kitą
dalį: modelį.

### Modelio generavimas

*Modelis* yra „Ruby“ klasė, kuri naudojama duomenims reprezentuoti. Be to, modeliai
gali sąveikauti su programos duomenų baze per „Rails“ funkciją, vadinamą
*Active Record*.

Norėdami apibrėžti modelį, naudosime modelio generatorių:

```bash
$ bin/rails generate model Article title:string body:text
```

PASTABA: Modelio pavadinimai yra **vienaskaitiniai**, nes sukuriamas modelis reprezentuoja
vieną duomenų įrašą. Norint lengviau prisiminti šią konvenciją, galima pagalvoti,
kaip būtų iškviečiamas modelio konstruktorius: norime rašyti `Article.new(...)`, o **ne**
`Articles.new(...)`.

Tai sukurs keletą failų:

```
invoke  active_record
create    db/migrate/<timestamp>_create_articles.rb
create    app/models/article.rb
invoke    test_unit
create      test/models/article_test.rb
create      test/fixtures/articles.yml
```

Dviem failams, į kuriuos sutelksime dėmesį, yra migracijos failas
(`db/migrate/<timestamp>_create_articles.rb`) ir modelio failas
(`app/models/article.rb`).

### Duomenų bazės migracijos

*Migracijos* naudojamos keisti programos duomenų bazės struktūrą. „Rails“ programose migracijos yra rašomos „Ruby“ kalba, kad jos būtų
nepriklausomos nuo duomenų bazės.

Pažvelkime į naujo migracijos failo turinį:

```ruby
class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

Iškvietimas `create_table` nurodo, kaip turėtų būti sukurta `articles` lentelė.
Pagal numatytuosius nustatymus, `create_table` metodas prideda `id` stulpelį kaip
auto-incrementing pagrindinį raktą. Taigi, pirmas įrašas lentelėje turės
`id` reikšmę 1, kitas įrašas turės `id` reikšmę 2 ir t. t.

Blokui `create_table` viduje apibrėžiami du stulpeliai: `title` ir
`body`. Juos pridėjo generatorius, nes juos įtraukėme į savo
generavimo komandą (`bin/rails generate model Article title:string body:text`).

Blokui paskutinėje eilutėje yra iškvietimas `t.timestamps`. Šis metodas apibrėžia
dar du stulpelius, vadinamus `created_at` ir `updated_at`. Kaip matysime,
„Rails“ juos valdys už mus, nustatys reikšmes, kai sukursime ar atnaujinsime
modelio objektą.

Paleiskime migraciją su šia komanda:

```bash
$ bin/rails db:migrate
```

Komanda rodo, kad lentelė buvo sukurta:

```
==  CreateArticles: migrating ===================================
-- create_table(:articles)
   -> 0.0018s
==  CreateArticles: migrated (0.0018s) ==========================
```

PATARIMAS: Norėdami sužinoti daugiau apie migracijas, žr. [Active Record migracijas](
active_record_migrations.html).

Dabar galime sąveikauti su lentele, naudodami mūsų modelį.

### Modelio naudojimas sąveikai su duomenų baze

Norėdami šiek tiek pasidžiaugti savo modeliu, naudosime „Rails“ funkciją, vadinamą
*konsolė*. Konsolė yra interaktyvi programavimo aplinka, panaši į `irb`, bet
ji taip pat automatiškai įkelia „Rails“ ir mūsų programos kodą.

Paleiskime konsolę šia komanda:

```bash
$ bin/rails console
```

Turėtumėte pamatyti `irb` įspėjimą:

```irb
Loading development environment (Rails 7.0.0)
irb(main):001:0>
```

Šiuo įspėjimu galime sukurti naują `Article` objektą:

```irb
irb> article = Article.new(title: "Hello Rails", body: "I am on Rails!")
```

Svarbu pažymėti, kad mes tik *inicijavome* šį objektą. Šis objektas
dar nėra išsaugotas duomenų bazėje. Jis yra prieinamas tik konsolėje
šiuo metu. Norėdami išsaugoti objektą duomenų bazėje, turime iškviesti [`save`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save) metodą:

```irb
irb> article.save
(0.1ms)  begin transaction
Article Create (0.4ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "Hello Rails"], ["body", "I am on Rails!"], ["created_at", "2020-01-18 23:47:30.734416"], ["updated_at", "2020-01-18 23:47:30.734416"]]
(0.9ms)  commit transaction
=> true
```

Pirmiau pateiktame rezultate matome `INSERT INTO "articles" ...` duomenų bazės užklausą. Tai
rodo, kad straipsnis buvo įterptas į mūsų lentelę. Jei vėl pažvelgsime į
`article` objektą, pamatysime, kad įvyko kažkas įdomaus:

```irb
irb> article
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```
`id`, `created_at` ir `updated_at` atributai objekte dabar yra nustatyti.
Tai padarė Rails, kai išsaugojome objektą.

Kai norime gauti šį straipsnį iš duomenų bazės, galime iškviesti [`find`](
https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find)
modelyje ir perduoti `id` kaip argumentą:

```irb
irb> Article.find(1)
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

Ir kai norime gauti visus straipsnius iš duomenų bazės, galime iškviesti [`all`](
https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all)
modelyje:

```irb
irb> Article.all
=> #<ActiveRecord::Relation [#<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">]>
```

Ši metodas grąžina [`ActiveRecord::Relation`](
https://api.rubyonrails.org/classes/ActiveRecord/Relation.html) objektą, kurį
galite laikyti kaip galingą masyvą.

PATARIMAS: Norėdami sužinoti daugiau apie modelius, žiūrėkite [Active Record Basics](
active_record_basics.html) ir [Active Record Query Interface](
active_record_querying.html).

Modeliai yra paskutinė MVC puzzle dalis. Toliau mes sujungsime visas dalis kartu.

### Straipsnių sąrašo rodymas

Grįžkime į mūsų valdiklį `app/controllers/articles_controller.rb` ir
pakeiskime `index` veiksmą, kad gautume visus straipsnius iš duomenų bazės:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

Valdiklio objekto kintamieji gali būti pasiekiami per vaizdą. Tai reiškia, kad
mes galime naudoti `@articles` `app/views/articles/index.html.erb` faile. Atidarykime
tą failą ir pakeiskime jo turinį į:

```html+erb
<h1>Straipsniai</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

Aukštyje esantis kodas yra HTML ir *ERB* mišinys. ERB yra šablonų sistema, kuri
vertina Ruby kodą, įterptą į dokumentą. Čia galime matyti du ERB žymių tipus: `<% %>`
ir `<%= %>`. `<% %>` žymė reiškia "įvertink įterptą Ruby kodą". `<%= %>` žymė reiškia
"įvertink įterptą Ruby kodą ir išvesk jo grąžinamą reikšmę". Bet ką galite rašyti
įprasto Ruby programoje, gali būti įdėta į šias ERB žymes, nors paprastai geriausia
laikytis ERB žymių turinio trumpumo dėl skaitymo patogumo.

Kadangi mes nenorime išvesti `@articles.each` grąžinamos reikšmės, mes esame
apgaubę tą kodą `<% %>`. Bet, kadangi mes *norime* išvesti `article.title` grąžinamą
reikšmę (kiekvienam straipsniui), mes esame apgaubę tą kodą `<%= %>`.

Galime pamatyti galutinį rezultatą apsilankydami <http://localhost:3000>. (Atminkite, kad
turi būti paleistas `bin/rails server`!) Čia yra kas vyksta, kai tai darome:

1. Naršyklė siunčia užklausą: `GET http://localhost:3000`.
2. Mūsų Rails aplikacija gauna šią užklausą.
3. Rails maršrutizatorius priskiria šakninį maršrutą `index` veiksmui `ArticlesController`.
4. `index` veiksmas naudoja `Article` modelį, kad gautų visus straipsnius iš duomenų bazės.
5. Rails automatiškai atvaizduoja `app/views/articles/index.html.erb` vaizdą.
6. Vaizde esantis ERB kodas yra įvertinamas, kad būtų išvestas HTML.
7. Serveris siunčia atsakymą, kuriame yra HTML, atgal į naršyklę.

Mes sujungėme visus MVC gabalus ir turime pirmąjį valdiklio veiksmą! Toliau pereisime prie antro veiksmo.

CRUDit kur tai reikalinga
--------------------------

Beveik visos interneto programos apima [CRUD (Create, Read, Update, and Delete)](
https://en.wikipedia.org/wiki/Create,_read,_update,_and_delete) operacijas. Jūs
netgi galite pastebėti, kad dauguma jūsų programos darbo yra CRUD. Rails
pripažįsta tai ir teikia daug funkcijų, kurios padeda supaprastinti CRUD operacijas.

Pradėkime tyrinėti šias funkcijas, pridedant daugiau funkcionalumo į mūsų
programą.

### Vieno straipsnio rodymas

Šiuo metu turime vaizdą, kuriame sąrašuojami visi straipsniai mūsų duomenų bazėje. Pridėkime naują vaizdą, kuriame būtų rodomas vieno straipsnio pavadinimas ir turinys.

Pradedame pridedant naują maršrutą, kuri priskiria naują valdiklio veiksmą (kurį
mes pridėsime toliau). Atidarykite `config/routes.rb` ir įterpkite paskutinį rodyklės maršrutą:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

Naujas maršrutas yra dar vienas `get` maršrutas, bet jo kelyje yra kažkas papildomo:
`:id`. Tai nurodo maršruto *parametrą*. Maršruto parametras užfiksuoja užklausos kelio segmentą
ir įdeda tuos reikšmes į `params` Hash, kuris pasiekiamas valdiklio veiksmo. Pavyzdžiui, apdorojant
užklausą kaip `GET http://localhost:3000/articles/1`, `1` būtų užfiksuota kaip reikšmė
`:id`, kuri tada būtų pasiekiamas kaip `params[:id]` `ArticlesController` `show` veiksme.
Pridėkime dabar `show` veiksmą, po `index` veiksmo `app/controllers/articles_controller.rb`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

`show` veiksmas iškviečia `Article.find` ([minėta anksčiau](#using-a-model-to-interact-with-the-database)) su pagautu ID iš maršruto parametro. Gautas straipsnis saugomas `@article` kintamajame, todėl jis pasiekiamas per rodinį. Pagal nutylėjimą, `show` veiksmas atvaizduos `app/views/articles/show.html.erb`.

Sukurkime `app/views/articles/show.html.erb` su šiuo turiniu:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

Dabar galime pamatyti straipsnį, kai aplankome <http://localhost:3000/articles/1>!

Baigiant, pridėkime patogų būdą pereiti į straipsnio puslapį. Nuorodą į kiekvieno straipsnio pavadinimą `app/views/articles/index.html.erb` priešime sujungsime su jo puslapiu:

```html+erb
<h1>Straipsniai</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

### Resursinė maršrutizacija

Iki šiol aptarėme CRUD "R" (Read) dalį. Vėliau aptarsime "C" (Create), "U" (Update) ir "D" (Delete) dalis. Kaip galbūt jau supratote, tai padarysime pridedami naujus maršrutus, valdiklio veiksmus ir rodinius. Kai turime tokią maršrutų, valdiklio veiksmų ir rodinių kombinaciją, kurie kartu atlieka CRUD operacijas su viena entitete, tai vadinsime šią entitetą *resursu*. Pavyzdžiui, mūsų programoje straipsnis yra resursas.

Rails teikia maršrutų metodą, vadinamą [`resources`](
https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources), kuris susieja visus konvencinius maršrutus kolekcijai resursų, pvz., straipsniams. Taigi, prieš tęsdami "C", "U" ir "D" dalis, pakeiskime dvi `get` maršrutus `config/routes.rb` faile į `resources`:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

Galime patikrinti, kokius maršrutus susieja paleidę komandą `bin/rails routes`:

```bash
$ bin/rails routes
      Prefix Verb   URI Pattern                  Controller#Action
        root GET    /                            articles#index
    articles GET    /articles(.:format)          articles#index
 new_article GET    /articles/new(.:format)      articles#new
     article GET    /articles/:id(.:format)      articles#show
             POST   /articles(.:format)          articles#create
edit_article GET    /articles/:id/edit(.:format) articles#edit
             PATCH  /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
```

`resources` metodas taip pat sukuria URL ir kelio pagalbinės metodus, kuriais galime užtikrinti, kad mūsų kodas nepriklauso nuo konkretaus maršrutų konfigūracijos. "Prefix" stulpelyje esantys reikšmės kartu su priesaga `_url` arba `_path` sudaro šių pagalbinių metodų pavadinimus. Pavyzdžiui, `article_path` pagalbinis metodas grąžina `"/articles/#{article.id}"`, kai jam paduodamas straipsnis. Galime jį naudoti, tvarkant nuorodas `app/views/articles/index.html.erb`:

```html+erb
<h1>Straipsniai</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

Tačiau dar žingsnį toliau galime eiti naudodami [`link_to`](
https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to) pagalbinį metodą. `link_to` pagalbinis metodas sugeneruoja nuorodą, kurioje pirmasis argumentas yra nuorodos tekstas, o antrasis argumentas yra nuorodos paskirtis. Jei antrąjį argumentą perduodame modelio objektui, `link_to` iškvies tinkamą kelio pagalbinį metodą, kad konvertuotų objektą į kelią. Pavyzdžiui, jei perduodame straipsnį, `link_to` iškvies `article_path`. Taigi `app/views/articles/index.html.erb` tampa:

```html+erb
<h1>Straipsniai</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

Puiku!

PATARIMAS: Norėdami sužinoti daugiau apie maršrutizavimą, žiūrėkite [Rails maršrutizavimas iš išorės](
routing.html).

### Naujo straipsnio kūrimas

Dabar pereiname prie CRUD "C" (Create) dalies. Paprastai interneto programose naujo resurso kūrimas yra daugiažingsnis procesas. Pirmiausia, naudotojas prašo užpildyti formą. Tada naudotojas pateikia formą. Jei nėra klaidų, tada resursas yra sukurtas ir rodomas kažkoks patvirtinimas. Kitu atveju, forma vėl rodoma su klaidų pranešimais ir procesas kartojamas.

Rails programoje šie žingsniai konvencionaliai yra tvarkomi valdiklio `new` ir `create` veiksmais. Pridėkime tipinę šių veiksmų įgyvendinimą į `app/controllers/articles_controller.rb`, po `show` veiksmo:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

`new` veiksmas sukuria naują straipsnį, bet jį neišsaugo. Šis straipsnis bus naudojamas rodinyje, kuriant formą. Pagal nutylėjimą, `new` veiksmas atvaizduos `app/views/articles/new.html.erb`, kurį sukursime toliau.
`create` veiksmas sukuria naują straipsnį su pavadinimo ir turinio reikšmėmis ir bandys jį išsaugoti. Jei straipsnis sėkmingai išsaugotas, veiksmas nukreips naršyklę į straipsnio puslapį adresu `"http://localhost:3000/articles/#{@article.id}"`.
Kitu atveju, veiksmas vėl rodo formą, atvaizduodamas `app/views/articles/new.html.erb` su statuso kodu [422 Negalima vienetas](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/422).
Čia pavadinimas ir turinys yra fiktyvios reikšmės. Po to, kai sukursime formą, grįšime ir pakeisime šias reikšmes.

PASTABA: [`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to)
nukreips naršyklę į naują užklausą,
o [`render`](https://api.rubyonrails.org/classes/AbstractController/Rendering.html#method-i-render)
atvaizduoja nurodytą vaizdą esamai užklausai.
Svarbu naudoti `redirect_to` po duomenų bazės ar programos būsenos pakeitimo.
Kitu atveju, jei vartotojas atnaujins puslapį, naršyklė padarys tą pačią užklausą ir pakeitimas bus kartojamas.

#### Naudodami formos kūrėją

Naudosime „Rails“ funkciją, vadinamą *formos kūrėju*, kad sukurtume savo formą. Naudodami
formos kūrėją, galime parašyti minimalų kodą, kad gautume formą, kuri yra
visiškai sukonfigūruota ir atitinka „Rails“ konvencijas.

Sukurkime `app/views/articles/new.html.erb` su šia turiniu:

```html+erb
<h1>Naujas straipsnis</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

[`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)
pagalbinės funkcijos metodas sukuria formos kūrėją. `form_with` bloke kviečiame
`label` ir `text_field` metodus iš formos kūrėjo, kad gautume tinkamus formos elementus.

Gautas rezultatas iš mūsų `form_with` kvietimo atrodys taip:

```html
<form action="/articles" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="...">

  <div>
    <label for="article_title">Pavadinimas</label><br>
    <input type="text" name="article[title]" id="article_title">
  </div>

  <div>
    <label for="article_body">Turinys</label><br>
    <textarea name="article[body]" id="article_body"></textarea>
  </div>

  <div>
    <input type="submit" name="commit" value="Sukurti straipsnį" data-disable-with="Sukurti straipsnį">
  </div>
</form>
```

PATARIMAS: Norėdami sužinoti daugiau apie formos kūrėjus, žr. [Veiksmo vaizdo formos pagalbininkai](
form_helpers.html).

#### Naudodami stipriuosius parametrus

Pateikti formos duomenys yra įdedami į `params` objektą, kartu su užfiksuotais maršruto
parametrais. Taigi, `create` veiksmas gali pasiekti pateiktą pavadinimą per
`params[:article][:title]` ir pateiktą turinį per `params[:article][:body]`.
Galėtume perduoti šias reikšmes atskirai į `Article.new`, bet tai būtų
daug žodžių ir gali būti klaidinga. Ir tai dar labiau pablogės, pridėjus daugiau
laukų.

Vietoj to, perduosime vieną `Hash`, kuriame bus šios reikšmės. Tačiau vis tiek turime
nurodyti, kokios reikšmės yra leidžiamos tame `Hash`. Kitu atveju, kenksmingas vartotojas
galėtų pateikti papildomus formos laukus ir perrašyti privačią informaciją. Iš tikrųjų,
jei perduosime neatfiltruotą `params[:article]` `Hash` tiesiogiai į `Article.new`,
„Rails“ mums praneš apie šią problemą, iškeliant `ForbiddenAttributesError`.
Todėl naudosime „Rails“ funkciją, vadinamą *stipriaisiais parametrais*, kad filtruotume `params`.
Galima tai laikyti kaip [stiprųjį tipavimą](https://en.wikipedia.org/wiki/Strong_and_weak_typing)
`params` atžvilgiu.

Pridėkime privačią metodą į `app/controllers/articles_controller.rb` apačią, kuris filtruos `params`. Ir pakeiskime `create` veiksmą,
kad jis jį naudotų:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

PATARIMAS: Norėdami sužinoti daugiau apie stipriuosius parametrus, žr. [Veiksmo kontrolerio apžvalga §
Stiprieji parametrai](action_controller_overview.html#strong-parameters).

#### Validacija ir klaidų pranešimų rodymas

Kaip matėme, resurso kūrimas yra daugiaužimtis procesas. Neleistinos
vartotojo įvesties tvarkymas yra dar vienas to proceso žingsnis. „Rails“ suteikia funkciją, vadinamą
*validacijomis*, kad padėtų mums susidoroti su neleistina vartotojo įvestimi. Validacijos yra taisyklės,
kurios yra tikrinamos prieš išsaugant modelio objektą. Jei patikrinimai nepavyksta, išsaugojimas bus nutrauktas,
ir atitinkami klaidų pranešimai bus pridėti prie modelio objekto `errors` atributo.

Pridėkime keletą validacijų į mūsų modelį `app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Pirma validacija nurodo, kad `title` reikšmė turi būti pateikta. Kadangi
`title` yra eilutė, tai reiškia, kad `title` reikšmė turi turėti bent vieną
nebaltąjį simbolį.

Antra validacija nurodo, kad `body` reikšmė taip pat turi būti pateikta.
Be to, ji nurodo, kad `body` reikšmė turi būti bent 10 simbolių ilgio.

PASTABA: Galbūt klausiatės, kur yra apibrėžti `title` ir `body` atributai.
„Active Record“ automatiškai apibrėžia modelio atributus kiekvienam lentelės stulpeliui,
todėl jums nereikia deklaruoti šių atributų savo modelio faile.
Su mūsų patvirtinimais vietose, pakeiskime `app/views/articles/new.html.erb` failą, kad rodytų bet kokius klaidų pranešimus `title` ir `body`:

```html+erb
<h1>Naujas straipsnis</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

[`full_messages_for`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_messages_for)
metodas grąžina vartotojui draugiškus klaidų pranešimus nurodytam atributui. Jei nėra klaidų šiam atributui, masyvas bus tuščias.

Norint suprasti, kaip visa tai veikia kartu, pažvelkime į `new` ir `create` kontrolerio veiksmus:

```ruby
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
```

Kai aplankome <http://localhost:3000/articles/new>, `GET /articles/new`
užklausa yra susiejama su `new` veiksmu. `new` veiksmas nesistengia išsaugoti
`@article`. Todėl validacijos nėra tikrinamos ir nebus klaidų pranešimų.

Kai pateikiame formą, `POST /articles` užklausa yra susiejama su `create`
veiksmu. `create` veiksmas *bando* išsaugoti `@article`. Todėl validacijos *yra*
tikrinamos. Jei kuri nors validacija nepavyksta, `@article` nebus išsaugotas ir
`app/views/articles/new.html.erb` bus rodomas su klaidų pranešimais.

PATARIMAS: Norėdami sužinoti daugiau apie validacijas, žiūrėkite [Active Record Validations](
active_record_validations.html). Norėdami sužinoti daugiau apie validacijos klaidų pranešimus,
žiūrėkite [Active Record Validations § Darbas su validacijos klaidomis](
active_record_validations.html#working-with-validation-errors).

#### Baigimas

Dabar galime sukurti straipsnį, aplankydami <http://localhost:3000/articles/new>.
Baigiant darbą, pridėkime nuorodą į šį puslapį apačioje
`app/views/articles/index.html.erb`:

```html+erb
<h1>Straipsniai</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "Naujas straipsnis", new_article_path %>
```

### Straipsnio atnaujinimas

Mes jau aptarėme CRUD "CR" dalį. Dabar eikime prie "U" (Atnaujinimas). Resurso atnaujinimas yra labai panašus į resurso kūrimą. Abu procesai yra daugiausiai etapai. Pirmiausia, vartotojas prašo formos redaguoti duomenis. Tada vartotojas pateikia formą. Jei nėra klaidų, tada resursas yra atnaujinamas. Kitu atveju, forma vėl rodoma su klaidų pranešimais ir procesas kartojamas.

Šie žingsniai konvencionaliai yra tvarkomi per kontrolerio `edit` ir `update` veiksmus. Pridėkime tipinį šių veiksmų įgyvendinimą į `app/controllers/articles_controller.rb`, po `create` veiksmo:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

Pastebėkite, kaip `edit` ir `update` veiksmai panašūs į `new` ir `create` veiksmus.

`edit` veiksmas gauna straipsnį iš duomenų bazės ir jį saugo `@article`, kad jis galėtų būti naudojamas kuriant formą. Pagal numatytuosius nustatymus, `edit` veiksmas rodo `app/views/articles/edit.html.erb`.

`update` veiksmas (vėl) gauna straipsnį iš duomenų bazės ir bandys jį atnaujinti su pateikta forma, kurią filtruoja `article_params`. Jei nėra jokių validacijos klaidų ir atnaujinimas pavyksta, veiksmas nukreipia naršyklę į straipsnio puslapį. Kitu atveju, veiksmas vėl rodo formą - su klaidų pranešimais - per `app/views/articles/edit.html.erb`.

#### Dalijimosi vaizdo kodo naudojimas naudojant dalis

Mūsų `edit` forma atrodys taip pat kaip ir `new` forma. Net kodas bus tas pats, dėka "Rails" formos kūrėjo ir resursų maršrutizavimo. Formos kūrėjas automatiškai konfigūruoja formą, kad ji atliktų tinkamą užklausos rūšį, remiantis tuo, ar modelio objektas buvo anksčiau išsaugotas.

Kadangi kodas bus tas pats, išskirsime jį į bendrą vaizdą, vadinamą *dalimi*. Sukurkime `app/views/articles/_form.html.erb` su šiais turiniais:

```html+erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```
Pirmiau pateiktas kodas yra tas pats kaip ir mūsų forma `app/views/articles/new.html.erb`, išskyrus tai, kad visi `@article` pasikartojimai buvo pakeisti į `article`. Kadangi daliniai yra bendrinis kodas, geriausia praktika yra tai, kad jie nepriklauso nuo konkrečių kintamųjų, nustatytų valdiklio veiksmo. Vietoj to, perduosime straipsnį dalinei kaip vietinį kintamąjį.

Atnaujinkime `app/views/articles/new.html.erb`, kad naudotų dalinį per [`render`](
https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render):

```html+erb
<h1>Naujas straipsnis</h1>

<%= render "form", article: @article %>
```

PASTABA: Dalinio failo pavadinimas turi būti pradėtas **su** pabraukimu, pvz.
`_form.html.erb`. Tačiau jį renderinant, jis yra paminėtas **be** pabraukimo, pvz.
`render "form"`.

Ir dabar, sukursime labai panašų `app/views/articles/edit.html.erb`:

```html+erb
<h1>Redaguoti straipsnį</h1>

<%= render "form", article: @article %>
```

PATARIMAS: Norėdami sužinoti daugiau apie dalinius, žr. [Išdėstymai ir atvaizdavimas „Rails“ § Naudoti dalinius](layouts_and_rendering.html#using-partials).

#### Baigiant

Dabar galime atnaujinti straipsnį apsilankydami jo redagavimo puslapyje, pvz.
<http://localhost:3000/articles/1/edit>. Baigiant, pridėkime nuorodą į redagavimo
puslapį apačioje `app/views/articles/show.html.erb`:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Redaguoti", edit_article_path(@article) %></li>
</ul>
```

### Straipsnio trynimas

Galų gale, pasiekėme „D“ (Trinti) CRUD. Resurso trynimas yra paprastesnis
procesas nei kūrimas ar atnaujinimas. Jis reikalauja tik maršruto ir valdiklio
veiksmo. Ir mūsų resursinė maršrutizacija (`resources :articles`) jau teikia
maršrutą, kuris susiejamas su `destroy` veiksmu `ArticlesController`.

Taigi, pridėkime įprastą `destroy` veiksmą į `app/controllers/articles_controller.rb`,
po `update` veiksmo:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

`destroy` veiksmas gauna straipsnį iš duomenų bazės ir iškviečia [`destroy`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy)
metodą. Tada jis nukreipia naršyklę į pagrindinį puslapį su statuso kodu
[303 See Other](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/303).

Pasirinkome nukreipti į pagrindinį puslapį, nes tai yra pagrindinis mūsų prieigos
taškas straipsniams. Tačiau kitais atvejais galite nuspręsti nukreipti į
pvz. `articles_path`.

Dabar pridėkime nuorodą apačioje `app/views/articles/show.html.erb`, kad galėtume
ištrinti straipsnį iš jo pačio puslapio:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Redaguoti", edit_article_path(@article) %></li>
  <li><%= link_to "Ištrinti", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Ar tikrai?"
                  } %></li>
</ul>
```

Pirmiau pateiktame kode naudojame `data` parinktį, kad nustatytume „Destroy“ nuorodos
`data-turbo-method` ir `data-turbo-confirm` HTML atributus. Abu šie atributai yra
susieti su [Turbo](https://turbo.hotwired.dev/), kuris yra įtrauktas pagal
numatytuosius nustatymus naujuose „Rails“ programose. `data-turbo-method="delete"`
sukels `DELETE` užklausą vietoje `GET` užklausos. `data-turbo-confirm="Ar tikrai?"`
sukels patvirtinimo dialogo langą, kai paspaudžiama nuoroda. Jei vartotojas atšaukia
dialogą, užklausa bus nutraukta.

Ir tai viskas! Dabar galime sąrašuoti, rodyti, kurti, atnaujinti ir trinti straipsnius!
InCRUDable!

Antrinio modelio pridėjimas
---------------------------

Atėjo laikas pridėti antrinį modelį į programą. Antrasis modelis bus skirtas
komentarams straipsniuose tvarkyti.

### Modelio generavimas

Matysime tą patį generatorių, kurį naudojome anksčiau, kai kūrėme
`Article` modelį. Šį kartą sukursime `Comment` modelį, kuriame bus saugoma
nuoroda į straipsnį. Paleiskite šią komandą terminalo lange:

```bash
$ bin/rails generate model Comment commenter:string body:text article:references
```

Ši komanda sugeneruos keturis failus:

| Failas                                         | Paskirtis                                                                                             |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| db/migrate/20140120201010_create_comments.rb   | Migracija, skirta sukurti komentarų lentelę duomenų bazėje (Jūsų pavadinime bus kitokia laiko žymė)    |
| app/models/comment.rb                          | Komentaro modelis                                                                                     |
| test/models/comment_test.rb                    | Testavimo pagalba komentaro modeliui                                                                   |
| test/fixtures/comments.yml                     | Pavyzdiniai komentarai testavimui                                                                      |

Pirmiausia, pažiūrėkite į `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

Tai labai panašu į `Article` modelį, kurį matėte anksčiau. Skirtumas
yra eilutė `belongs_to :article`, kuri nustato „Active Record“ _asociaciją_.
Apie asociacijas sužinosite šio vadovo kitame skyriuje.
(`:references`) raktažodis, naudojamas shell komandoje, yra specialus modelio duomenų tipas.
Tai sukuria naują stulpelį jūsų duomenų bazės lentelėje su pateiktu modelio pavadinimu, prie kurio pridedamas `_id`
ir gali laikyti sveikus skaičius. Norėdami geriau suprasti, analizuokite
`db/schema.rb` failą po migracijos paleidimo.

Be modelio, „Rails“ taip pat sukūrė migraciją, kad sukurtų atitinkamą duomenų bazės lentelę:

```ruby
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

`t.references` eilutė sukuria sveikąjį stulpelį, vadinamą `article_id`, indeksą
jam ir užsienio raktų apribojimą, rodantį į `articles` lentelės `id` stulpelį. Tęskite ir paleiskite migraciją:

```bash
$ bin/rails db:migrate
```

„Rails“ pakankamai protingas, kad vykdytų tik migracijas, kurios dar nebuvo
paleistos dabartinėje duomenų bazėje, todėl šiuo atveju matysite tik:

```
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```

### Modelių susiejimas

„Active Record“ asociacijos leidžia lengvai nurodyti ryšį tarp dviejų
modelių. Komentarų ir straipsnių atveju galėtumėte aprašyti
ryšius taip:

* Kiekvienas komentaras priklauso vienam straipsniui.
* Vienas straipsnis gali turėti daug komentarų.

Iš tikrųjų tai labai arti sintaksės, kurią „Rails“ naudoja, kad nurodytų šį
asociaciją. Jau matėte eilutę kodo viduje `Comment` modelyje
(app/models/comment.rb), kuri nurodo, kad kiekvienas komentaras priklauso straipsniui:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

Turėsite redaguoti `app/models/article.rb`, kad pridėtumėte asociacijos kitą pusę:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Šios dvi deklaracijos įgalina daug automatinės veiklos. Pavyzdžiui, jei
turite egzempliorių `@article`, kuriame yra straipsnis, galite gauti
visus komentarus, priklausančius tam straipsniui, kaip masyvą naudodami
`@article.comments`.

PATARIMAS: Daugiau informacijos apie „Active Record“ asociacijas rasite [„Active Record“
asociacijų](association_basics.html) vadove.

### Komentarų maršruto pridėjimas

Kaip ir su `articles` valdikliu, turėsime pridėti maršrutą, kad „Rails“
žinotų, kur norime eiti, kad pamatytume `comments`. Vėl atidarykite
`config/routes.rb` failą ir jį redaguokite taip:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

Tai sukuria `comments` kaip _sugrupuotą resursą_ `articles` viduje. Tai
yra dar viena dalis, kuri užfiksuoja hierarchinį ryšį tarp
straipsnių ir komentarų.

PATARIMAS: Daugiau informacijos apie maršrutizavimą rasite [„Rails“ maršrutizavimo](routing.html)
vadove.

### Valdiklio generavimas

Turėdami modelį, galite atkreipti dėmesį į atitinkamą valdiklio sukūrimą.
Vėl naudosime tą patį generatorių, kurį naudojome anksčiau:

```bash
$ bin/rails generate controller Comments
```

Tai sukuria tris failus ir vieną tuščią katalogą:

| Failas/Katalogas                             | Paskirtis                                |
| -------------------------------------------- | ---------------------------------------- |
| app/controllers/comments_controller.rb       | Komentarų valdiklis                      |
| app/views/comments/                          | Valdiklio rodiniai saugomi čia           |
| test/controllers/comments_controller_test.rb | Valdiklio testas                         |
| app/helpers/comments_helper.rb               | Rodinio pagalbinis failas                |

Kaip ir su bet kuriu tinklaraščiu, mūsų skaitytojai sukurs savo komentarus tiesiogiai po
straipsnio perskaitymo ir pridėję savo komentarą, bus nukreipti atgal
į straipsnio rodinio puslapį, kad pamatytų savo komentarą sąraše. Dėl šios priežasties
`CommentsController` yra skirtas suteikti metodą komentarų kūrimui ir šlamšto komentarų trynimui, kai jie atkeliauja.

Taigi, pirma, sukonfigūruosime straipsnio rodinio šabloną
(`app/views/articles/show.html.erb`), kad galėtume sukurti naują komentarą:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Tai prideda formą į `Article` rodinio puslapį, kuri sukuria naują komentarą,
kviečiant `CommentsController` `create` veiksmą. Čia `form_with` kvietimas naudoja
masyvą, kuris sukurs sugrupuotą maršrutą, pvz., `/articles/1/comments`.
Prijunkime `create` metodą `app/controllers/comments_controller.rb`:

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

Čia matysite šiek tiek daugiau sudėtingumo nei straipsnių valdiklyje. Tai yra šalutinis efektas, kurį sukėlė jūsų sukurtas įdėklas. Kiekvienas komentaro užklausa turi sekti straipsnį, prie kurio pridedamas komentaras, todėl pradinis kvietimas `find` metode `Article` modelyje gauna klausiamą straipsnį.

Be to, kodas pasinaudoja kai kuriomis asociacijos metodais. Mes naudojame `create` metodą `@article.comments` objekte, kad sukurtume ir išsaugotume komentarą. Tai automatiškai susieja komentarą su tuo konkretaus straipsnio objektu.

Kai sukūrėme naują komentarą, nukreipiame vartotoją atgal į pradinį straipsnį naudodami `article_path(@article)` pagalbinį metodą. Kaip jau matėme, tai iškviečia `show` veiksmą `ArticlesController`, kuris vėlgi atvaizduoja `show.html.erb` šabloną. Čia norime, kad komentaras būtų rodomas, todėl pridėkime jį prie `app/views/articles/show.html.erb`.

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Redaguoti", edit_article_path(@article) %></li>
  <li><%= link_to "Naikinti", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Ar tikrai?"
                  } %></li>
</ul>

<h2>Komentarai</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>Komentuotojas:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Komentaras:</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>Pridėti komentarą:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Dabar galite pridėti straipsnius ir komentarus į savo tinklaraštį ir matyti juos tinkamuose vietose.

![Straipsnis su komentarais](images/getting_started/article_with_comments.png)

Refaktorizavimas
-----------

Dabar, kai turime veikiančius straipsnius ir komentarus, pažvelkime į `app/views/articles/show.html.erb` šabloną. Jis tampa ilgas ir neįmanomas. Galime naudoti dalinius šablonus, kad jį sutvarkytume.

### Dalinių kolekcijų atvaizdavimas

Pirmiausia, sukursime dalinį šabloną komentarų atvaizdavimui. Sukurkite failą `app/views/comments/_comment.html.erb` ir įrašykite į jį šį kodą:

```html+erb
<p>
  <strong>Komentuotojas:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Komentaras:</strong>
  <%= comment.body %>
</p>
```

Tada galite pakeisti `app/views/articles/show.html.erb` šabloną taip:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Redaguoti", edit_article_path(@article) %></li>
  <li><%= link_to "Naikinti", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Ar tikrai?"
                  } %></li>
</ul>

<h2>Komentarai</h2>
<%= render @article.comments %>

<h2>Pridėti komentarą:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Tai dabar atvaizduos dalinį šabloną `app/views/comments/_comment.html.erb` vieną kartą kiekvienam komentarui, esančiam `@article.comments` kolekcijoje. Kai `render` metodas iteruoja per `@article.comments` kolekciją, jis priskiria kiekvieną komentarą vietinei kintamajai, pavadintai taip pat kaip dalinis šablonas, šiuo atveju `comment`, kuris tada yra prieinamas daliniame šablone.

### Dalinio formos atvaizdavimas

Taip pat perkelsime naujo komentaro sekciją į atskirą dalinį šabloną. Vėlgi, sukuriame failą `app/views/comments/_form.html.erb`, kuriame yra šis kodas:

```html+erb
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Tada pakeiskime `app/views/articles/show.html.erb` šabloną taip:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Redaguoti", edit_article_path(@article) %></li>
  <li><%= link_to "Naikinti", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Ar tikrai?"
                  } %></li>
</ul>

<h2>Komentarai</h2>
<%= render @article.comments %>

<h2>Pridėti komentarą:</h2>
<%= render 'comments/form' %>
```

Antrasis `render` tiesiog nurodo dalinį šabloną, kurį norime atvaizduoti, `comments/form`. „Rails“ pakankamai protingas, kad pastebėtų šioje eilutėje esantį pasvirąjį brūkšnį ir suprastų, kad norite atvaizduoti `_form.html.erb` failą `app/views/comments` kataloge.

`@article` objektas yra prieinamas visiems daliniams šablonams, kurie yra atvaizduojami peržiūros metu, nes jį apibrėžėme kaip objekto kintamąjį.

### Naudojant susirūpinimus

Susirūpinimai yra būdas padaryti didelius valdiklius ar modelius lengviau suprasti ir tvarkyti. Tai taip pat turi privalumą, kai kelios modeliai (arba valdikliai) dalijasi tais pačiais susirūpinimais. Susirūpinimai yra įgyvendinami naudojant modulius, kuriuose yra metodai, atitinkantys gerai apibrėžtą modelio ar valdiklio funkcionalumo dalį. Kitose kalbose moduliai dažnai žinomi kaip mišiniai.
Galite naudoti susirūpinimus savo valdiklyje arba modelyje taip pat, kaip naudotumėte bet kurį modulį. Kai pirmą kartą sukūrėte savo programą su `rails new blog`, kartu su kitais buvo sukurti du aplankai `app/`:

```
app/controllers/concerns
app/models/concerns
```

Pavyzdyje žemiau įgyvendinsime naują funkciją mūsų tinklaraščiui, kuris gautų naudos naudojant susirūpinimus. Tada sukursime susirūpinimą ir pertvarkysime kodą, kad jį naudotume, padarant kodą saugesnį ir lengviau palaikomą.

Tinklaraščio straipsnis gali turėti įvairių būsenų - pavyzdžiui, jis gali būti matomas visiems (t.y. `public`), arba tik autoriui (t.y. `private`). Jis taip pat gali būti paslėptas visiems, bet vis tiek pasiekiamas (t.y. `archived`). Komentarai taip pat gali būti paslėpti arba matomi. Tai galima atvaizduoti naudojant `status` stulpelį kiekviename modelyje.

Pirmiausia, paleiskime šias migracijas, kad pridėtume `status` į `Articles` ir `Comments`:

```bash
$ bin/rails generate migration AddStatusToArticles status:string
$ bin/rails generate migration AddStatusToComments status:string
```

Tada atnaujinkime duomenų bazę sukurtais migracijomis:

```bash
$ bin/rails db:migrate
```

Norėdami pasirinkti būseną esamiems straipsniams ir komentarams, galite pridėti numatytąją reikšmę sukurtų migracijų failams, pridėdami `default: "public"` parinktį ir paleisdami migracijas dar kartą. Taip pat galite iškviesti `Article.update_all(status: "public")` ir `Comment.update_all(status: "public")` per `rails console`.


PATARIMAS: Norėdami sužinoti daugiau apie migracijas, žr. [Active Record migracijas](
active_record_migrations.html).

Taip pat turime leisti `:status` raktą kaip dalį stipriųjų parametrų, `app/controllers/articles_controller.rb`:

```ruby

  private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
```

ir `app/controllers/comments_controller.rb`:

```ruby

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

Po to, `article` modelyje, paleidus migraciją, kad pridėtume `status` stulpelį naudojant `bin/rails db:migrate` komandą, pridėtume:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

ir `Comment` modelyje:

```ruby
class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

Tada, mūsų `index` veiksmo šablone (`app/views/articles/index.html.erb`) naudotume `archived?` metodą, kad nebūtų rodomas joks straipsnis, kuris yra archyvuotas:

```html+erb
<h1>Straipsniai</h1>

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "Naujas straipsnis", new_article_path %>
```

Panašiai, mūsų komentaro daliniame rodinyje (`app/views/comments/_comment.html.erb`) naudotume `archived?` metodą, kad nebūtų rodomas joks komentaras, kuris yra archyvuotas:

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Komentuotojas:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Komentaras:</strong>
    <%= comment.body %>
  </p>
<% end %>
```

Tačiau jei vėl pažvelgsite į mūsų modelius, pamatysite, kad logika yra dubliuota. Jei ateityje padidinsime savo tinklaraščio funkcionalumą - pavyzdžiui, įtrauksime privačius pranešimus - galime vėl rasti save dubliuojant logiką. Tai yra vieta, kur naudingi susirūpinimai.

Susirūpinimas yra atsakingas tik už modelio atsakomybės fokusu; mūsų susirūpinimo metoduose visi susiję su modelio matomumu. Pavadinkime savo naują susirūpinimą (modulį) `Visible`. Galime sukurti naują failą `app/models/concerns` aplankale, vadinamą `visible.rb`, ir saugoti visus dubliuotus metodus, kurie buvo modeliuose.

`app/models/concerns/visible.rb`

```ruby
module Visible
  def archived?
    status == 'archived'
  end
end
```

Galime pridėti savo būsenos patikrinimą prie susirūpinimo, bet tai šiek tiek sudėtingesnis procesas, nes patikrinimai yra metodai, kurie yra kviečiami klasės lygyje. `ActiveSupport::Concern` ([API vadovas](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)) suteikia paprastesnį būdą juos įtraukti:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  def archived?
    status == 'archived'
  end
end
```

Dabar galime pašalinti dubliuotą logiką iš kiekvieno modelio ir vietoj to įtraukti mūsų naują `Visible` modulį:


`app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

ir `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  include Visible

  belongs_to :article
end
```
Klasės metodai taip pat gali būti pridėti prie susirūpinimų. Jei norime rodyti viešų straipsnių ar komentarų skaičių pagrindiniame puslapyje, galime pridėti klasės metodą prie Visible kaip parodyta žemiau:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      where(status: 'public').count
    end
  end

  def archived?
    status == 'archived'
  end
end
```

Tada peržiūroje jį galite iškviesti kaip bet kurį klasės metodą:

```html+erb
<h1>Straipsniai</h1>

Mūsų tinklaraštyje yra <%= Article.public_count %> straipsniai ir skaičiuojama!

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "Naujas straipsnis", new_article_path %>
```

Baigiant, pridėsime pasirinkimo laukelį formoms ir leisime vartotojui pasirinkti būseną, kai jis kuria naują straipsnį ar skelbia naują komentarą. Taip pat galime nurodyti numatytąją būseną kaip `public`. `app/views/articles/_form.html.erb` faile galime pridėti:

```html+erb
<div>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</div>
```

ir `app/views/comments/_form.html.erb` faile:

```html+erb
<p>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</p>
```

Komentarų trynimas
-----------------

Kitas svarbus tinklaraščio funkcionalumas yra galimybė ištrinti šlamšto komentarus. Tam reikia įgyvendinti nuorodą peržiūroje ir `destroy` veiksmą `CommentsController`.

Taigi, pirmiausia pridėkime trynimo nuorodą į `app/views/comments/_comment.html.erb` dalinį:

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Komentuotojas:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Komentaras:</strong>
    <%= comment.body %>
  </p>

  <p>
    <%= link_to "Ištrinti komentarą", [comment.article, comment], data: {
                  turbo_method: :delete,
                  turbo_confirm: "Ar tikrai?"
                } %>
  </p>
<% end %>
```

Paspaudus šią naują "Ištrinti komentarą" nuorodą, bus išsiųstas `DELETE /articles/:article_id/comments/:id` užklausa į `CommentsController`, kuris galės rasti komentarą, kurį norime ištrinti. Taigi, pridėkime `destroy` veiksmą į mūsų kontrolerį (`app/controllers/comments_controller.rb`):

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), status: :see_other
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
end
```

`destroy` veiksmas ras straipsnį, kurį žiūrime, rasi komentarą `@article.comments` kolekcijoje ir jį pašalins iš duomenų bazės, o tada nukreips mus į straipsnio rodinio veiksmą.

### Susijusių objektų trynimas

Jei ištrinsite straipsnį, taip pat reikės ištrinti susijusius komentarus, kitaip jie tiesiog užims vietą duomenų bazėje. „Rails“ leidžia naudoti asociacijos `dependent` parinktį, kad tai pasiektumėte. Pakeiskite `Article` modelį, `app/models/article.rb`, kaip parodyta žemiau:

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Saugumas
--------

### Pagrindinė autentifikacija

Jei savo tinklaraštį paskelbtumėte internete, bet kas galėtų pridėti, redaguoti ir ištrinti straipsnius arba ištrinti komentarus.

„Rails“ teikia HTTP autentifikacijos sistemą, kuri puikiai veiks šioje situacijoje.

`ArticlesController` mums reikia būdo blokuoti prieigą prie įvairių veiksmų, jei asmuo nėra autentifikuotas. Čia galime naudoti „Rails“ `http_basic_authenticate_with` metodą, kuris leidžia prieigą prie reikiamo veiksmo, jei tas metodas tai leidžia.

Norėdami naudoti autentifikacijos sistemą, ją nurodome mūsų `ArticlesController` viršuje, `app/controllers/articles_controller.rb`. Mūsų atveju norime, kad vartotojas būtų autentifikuotas kiekviename veiksme, išskyrus `index` ir `show`, todėl parašome taip:

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # snippet for brevity
```

Taip pat norime leisti tik autentifikuotiems vartotojams ištrinti komentarus, todėl `CommentsController` (`app/controllers/comments_controller.rb`) parašome:

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # snippet for brevity
```

Dabar, jei bandysite sukurti naują straipsnį, jums bus pateiktas pagrindinės HTTP autentifikacijos iššūkis:

![Pagrindinės HTTP autentifikacijos iššūkis](images/getting_started/challenge.png)

Įvedus teisingą naudotojo vardą ir slaptažodį, jūs liksite autentifikuotas, kol bus reikalaujamas kitas naudotojo vardas ir slaptažodis arba naršyklė bus uždaryta.
Kiti autentifikavimo metodai yra prieinami "Rails" programoms. Dvi populiarios autentifikavimo papildymo "Rails" yra [Devise](https://github.com/plataformatec/devise) ir [Authlogic](https://github.com/binarylogic/authlogic) gem, kartu su kitais.

### Kiti saugumo apsvarstymai

Saugumas, ypač interneto programose, yra plačiai ir išsamiai nagrinėjama sritis. "Rails" programos saugumas yra išsamiau aptartas [Ruby on Rails saugumo vadove](security.html).

Kas toliau?
------------

Dabar, kai matėte savo pirmąją "Rails" programą, galite ją atnaujinti ir eksperimentuoti savarankiškai.

Atminkite, kad jums nereikia visko daryti be pagalbos. Jei jums reikia pagalbos pradėti dirbti su "Rails", drąsiai kreipkitės į šiuos pagalbos šaltinius:

* [Ruby on Rails vadovai](index.html)
* [Ruby on Rails pašto sąrašas](https://discuss.rubyonrails.org/c/rubyonrails-talk)

Konfigūracijos klaidos
---------------------

Paprastiausias būdas dirbti su "Rails" yra saugoti visus išorinius duomenis kaip UTF-8. Jei to nedarote, "Ruby" bibliotekos ir "Rails" dažnai gali konvertuoti jūsų natyvius duomenis į UTF-8, tačiau tai ne visada veikia patikimai, todėl geriau užtikrinti, kad visi išoriniai duomenys būtų UTF-8.

Jei šioje srityje padarėte klaidą, dažniausias simptomas yra juodas deimantas su klausimo ženklu viduje, atsirandantis naršyklėje. Kitas dažnas simptomas yra simboliai, tokie kaip "Ã¼", atsirandantys vietoj "ü". "Rails" ėmėsi keleto vidinių veiksmų, kad būtų sumažintos šių problemų dažniausios priežastys, kurias galima automatiškai aptikti ir ištaisyti. Tačiau, jei turite išorinių duomenų, kurie nėra saugomi kaip UTF-8, tai kartais gali sukelti šių problemų, kurias "Rails" negali automatiškai aptikti ir ištaisyti.

Dvi labai dažnos duomenų, kurie nėra UTF-8, šaltiniai:

* Jūsų teksto redaktorius: Dauguma teksto redaktorių (pvz., TextMate) pagal nutylėjimą išsaugo failus kaip UTF-8. Jei jūsų teksto redaktorius to nedaro, tai gali lemti specialių simbolių, kuriuos įvedate į savo šablonus (pvz., é), atsiradimą naršyklėje kaip deimantas su klausimo ženklu viduje. Tai taip pat taikoma jūsų i18n vertimo failams. Dauguma redaktorių, kurie jau nenumato UTF-8 kaip numatytąjį (pvz., kai kurios "Dreamweaver" versijos), siūlo būdą pakeisti numatytąjį į UTF-8. Padarykite tai.
* Jūsų duomenų bazė: "Rails" pagal nutylėjimą konvertuoja duomenis iš jūsų duomenų bazės į UTF-8 ribose. Tačiau, jei jūsų duomenų bazė viduje nenaudoja UTF-8, ji gali nepavykti saugoti visus simbolius, kuriuos įveda jūsų vartotojai. Pavyzdžiui, jei jūsų duomenų bazė viduje naudoja "Latin-1", o jūsų vartotojas įveda rusų, hebrajų ar japonų simbolį, duomenys bus visam laikui prarasti, kai jie patenka į duomenų bazę. Jei įmanoma, naudokite UTF-8 kaip vidinį duomenų bazės saugojimo formatą.
