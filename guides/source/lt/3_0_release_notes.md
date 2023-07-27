**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: dd2584972aa8eae419ed5d55a287e27d
Ruby on Rails 3.0 Išleidimo pastabos
===============================

Rails 3.0 yra žirgeliai ir vaivorykštės! Jis jums pagamins vakarienę ir sulankys jūsų skalbinius. Jūs stebėsitės, kaip gyvenimas buvo įmanomas prieš jį atvykus. Tai geriausia Rails versija, kurią mes kada nors padarėme!

Bet rimtai, tai tikrai geras dalykas. Čia yra visos geriausios idėjos, kurias perėmėme iš Merb komandos, kai jie prisijungė prie šventės ir atnešė fokusą į framework'ų agnostiškumą, plonesnę ir greitesnę vidinę struktūrą bei keletą skanių API. Jei persikeliat iš Merb 1.x į Rails 3.0, turėtumėte daug ką atpažinti. Jei persikeliat iš Rails 2.x, jums tai taip pat patiks.

Net jei jums nerūpi jokie mūsų vidiniai patobulinimai, Rails 3.0 jus džiugins. Mes turime daug naujų funkcijų ir patobulintų API. Niekuomet nebuvo geresnis laikas būti Rails programuotoju. Kai kurie išryškinimai yra:

* Visiškai naujas maršrutizatorius su pabrėžimu ant RESTful deklaracijų
* Naujas Action Mailer API, modeliuotas pagal Action Controller (dabar be kančios siunčiant daugialypius pranešimus!)
* Naujas Active Record grandinės užklausų kalba, paremta reliacinės algebros
* Neintruziniai JavaScript pagalbininkai su draiveriais Prototype, jQuery ir daugiau (pabaiga inline JS)
* Aiškus priklausomybių valdymas su Bundler

Be to, mes stengėmės pasenusius API pakeisti su gražiais įspėjimais. Tai reiškia, kad galite perkelti savo esamą aplikaciją į Rails 3, nereikia iš karto persirašyti viso seno kodo pagal naujausias geriausias praktikas.

Šios išleidimo pastabos apima pagrindinius atnaujinimus, bet neįtraukia kiekvienos mažos klaidos taisymo ir pakeitimo. Rails 3.0 susideda iš beveik 4 000 įsipareigojimų, kuriuos padarė daugiau nei 250 autorių! Jei norite pamatyti viską, patikrinkite [įsipareigojimų sąrašą](https://github.com/rails/rails/commits/3-0-stable) pagrindiniame Rails saugykloje GitHub.

--------------------------------------------------------------------------------

Norėdami įdiegti Rails 3:

```bash
# Jei jūsų sąranka to reikalauja, naudokite sudo
$ gem install rails
```


Atnaujinimas į Rails 3
--------------------

Jei atnaujinat esamą aplikaciją, gerai būtų turėti gerą testų padengimą prieš pradedant. Taip pat pirmiausia atnaujinkite iki Rails 2.3.5 ir įsitikinkite, kad jūsų aplikacija veikia kaip tikėtasi, prieš bandant atnaujinti į Rails 3. Tada atkreipkite dėmesį į šiuos pakeitimus:

### Rails 3 reikalauja bent Ruby 1.8.7

Rails 3.0 reikalauja Ruby 1.8.7 arba naujesnės versijos. Visos ankstesnės Ruby versijos oficialiai nebepalaikomos ir jums reikėtų atnaujinti kuo greičiau. Rails 3.0 taip pat yra suderinamas su Ruby 1.9.2.

PATARIMAS: Atkreipkite dėmesį, kad Ruby 1.8.7 p248 ir p249 turi maršalizavimo klaidas, kurios sukelia Rails 3.0 sutrikimus. Ruby Enterprise Edition turi šias klaidas ištaisytas nuo 1.8.7-2010.02 versijos. Dėl 1.9 versijos, Ruby 1.9.1 nėra naudojamas, nes jis tiesiog iššoka klaidas su Rails 3.0, todėl jei norite naudoti Rails 3 su 1.9.x, naudokite 1.9.2 versiją.

### Rails aplikacijos objektas

Kaip dalis pagrindų, skirtų palaikyti kelias Rails aplikacijas tame pačiame procese, Rails 3 įveda aplikacijos objekto sąvoką. Aplikacijos objektas laiko visus aplikacijos specifinius konfigūracijas ir yra labai panašus į `config/environment.rb` iš ankstesnių Rails versijų.

Kiekvienai Rails aplikacijai dabar turi būti atitinkamas aplikacijos objektas. Aplikacijos objektas yra apibrėžtas `config/application.rb`. Jei atnaujinat esamą aplikaciją į Rails 3, turite pridėti šį failą ir perkelti tinkamas konfigūracijas iš `config/environment.rb` į `config/application.rb`.

### script/* pakeista į script/rails

Naujasis `script/rails` pakeičia visus skriptus, kurie buvo `script` kataloge. Tačiau jūs nenaudojate `script/rails` tiesiogiai, `rails` komanda aptinka, kad ji yra kviečiama iš Rails aplikacijos šakninio katalogo ir paleidžia skriptą už jus. Numatytas naudojimas yra:

```bash
$ rails console                      # vietoj script/console
$ rails g scaffold post title:string # vietoj script/generate scaffold post title:string
```

Paleiskite `rails --help` norėdami pamatyti visų galimybių sąrašą.

### Priklausomybės ir config.gem

`config.gem` metodas yra panaikintas ir pakeistas naudojant `bundler` ir `Gemfile`, žr. [Gems'ų Vendorinimas](#vendoring-gems) žemiau.

### Atnaujinimo procesas

Norint padėti su atnaujinimo procesu, sukurtas įskiepis pavadinimu [Rails Upgrade](https://github.com/rails/rails_upgrade), kuris dalinai automatizuoja jį.

Tiesiog įdiekite įskiepį, tada paleiskite `rake rails:upgrade:check`, kad patikrintumėte savo aplikaciją dėl dalių, kurios turi būti atnaujintos (su nuorodomis į informaciją, kaip jas atnaujinti). Taip pat jis siūlo užduotį, kuri pagal jūsų esamus `config.gem` iškvietimus sugeneruoja `Gemfile`, ir užduotį, kuri pagal jūsų esamą maršrutų failą sugeneruoja naują maršrutų failą. Norėdami gauti įskiepį, tiesiog paleiskite šią komandą:
```bash
$ ruby script/plugin install git://github.com/rails/rails_upgrade.git
```

Galite pamatyti, kaip tai veikia, adresu [Rails Upgrade yra dabar oficialus įskiepis](http://omgbloglol.com/post/364624593/rails-upgrade-is-now-an-official-plugin)

Be Rails Upgrade įrankio, jei jums reikia daugiau pagalbos, yra žmonių IRC ir [rubyonrails-talk](https://discuss.rubyonrails.org/c/rubyonrails-talk), kurie tikriausiai daro tą patį dalyką ir gali patirti tuos pačius sunkumus. Būkite tikri, kad rašysite savo patirtis, kai atnaujinate, kad kiti galėtų pasinaudoti jūsų žiniomis!

Kuriamas „Rails 3.0“ programa
--------------------------------

```bash
# Jums turėtų būti įdiegtas „rails“ RubyGem
$ rails new myapp
$ cd myapp
```

### Gems prekyba

Dabar „Rails“ naudoja `Gemfile` programos šaknies aplankui, kad nustatytų jums reikalingas „gems“, kad jūsų programa galėtų paleisti. Šis `Gemfile` apdorojamas naudojant [Bundler](https://github.com/bundler/bundler), kuris tada įdiegia visus jūsų priklausomybes. Jis netgi gali įdiegti visas priklausomybes vietiniame jūsų programos aplankale, kad ji nebūtų priklausoma nuo sistemos „gems“.

Daugiau informacijos: - [bundler homepage](https://bundler.io/)

### Gyvenimas ant krašto

`Bundler` ir `Gemfile` leidžia lengvai užšaldyti jūsų „Rails“ programą naudojant naują specialųjį `bundle` komandą, todėl `rake freeze` nebėra aktualus ir buvo pašalintas.

Jei norite tiesiogiai įtraukti iš „Git“ saugyklos, galite perduoti `--edge` žymą:

```bash
$ rails new myapp --edge
```

Jei turite vietinį „Rails“ saugyklos kopiją ir norite sukurti programą, naudodami ją, galite perduoti `--dev` žymą:

```bash
$ ruby /path/to/rails/bin/rails new myapp --dev
```

„Rails“ architektūros pokyčiai
---------------------------

Yra šeši pagrindiniai pokyčiai „Rails“ architektūroje.

### Railties persiuvimas

Railties buvo atnaujintas, kad suteiktų nuoseklią įskiepių API visai „Rails“ platformai, taip pat visiškai perrašyti generatoriai ir „Rails“ ryšiai, rezultatas yra tas, kad dabar programuotojai gali prisijungti prie bet kurios svarbios generatorių ir programos pagrindo stadijos nuosekliai, apibrėžtu būdu.

### Visi „Rails“ pagrindiniai komponentai yra atskirti

Su „Merb“ ir „Rails“ sujungimu vienas iš didžiųjų darbų buvo pašalinti glaudų ryšį tarp „Rails“ pagrindinių komponentų. Tai dabar pasiekta, ir visi „Rails“ pagrindiniai komponentai dabar naudoja tą pačią API, kurią galite naudoti kurdami įskiepius. Tai reiškia, kad bet kurį įskiepį, kurį sukursite, arba bet kurį pagrindinio komponento pakeitimą (pvz., „DataMapper“ ar „Sequel“), galima pasiekti visas funkcijas, prie kurių „Rails“ pagrindiniai komponentai turi prieigą, ir išplėsti bei patobulinti pagal poreikį.

Daugiau informacijos: - [The Great Decoupling](http://yehudakatz.com/2009/07/19/rails-3-the-great-decoupling/)


### Aktyvaus modelio abstrakcija

Dalis pagrindinių komponentų atskyrimo buvo ištraukti visi ryšiai su „Active Record“ iš „Action Pack“. Tai dabar yra baigta. Visi nauji ORM įskiepiai dabar tiesiog turi įgyvendinti „Active Model“ sąsajas, kad veiktų sklandžiai su „Action Pack“.

Daugiau informacijos: - [Make Any Ruby Object Feel Like ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### Valdiklio abstrakcija

Kitas didelis pagrindinių komponentų atskyrimo dalykas buvo sukurti bazinį viršklasę, kuri yra atskirta nuo HTTP sąvokų, kad galėtų tvarkyti rodinio vaizdus ir kt. Šio „AbstractController“ sukūrimas leido labai supaprastinti „ActionController“ ir „ActionMailer“, pašalinant bendrą kodą iš visų šių bibliotekų ir perkeldant jį į abstraktų valdiklį.

Daugiau informacijos: - [Rails Edge Architecture](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Arel integracija

[Arel](https://github.com/brynary/arel) (arba „Active Relation“) tapo pagrindu „Active Record“ ir dabar yra būtinas „Rails“. Arel teikia SQL abstrakciją, kuri supaprastina „Active Record“ ir suteikia pagrindą sąryšio funkcionalumui „Active Record“.

Daugiau informacijos: - [Why I wrote Arel](https://web.archive.org/web/20120718093140/http://magicscalingsprinkles.wordpress.com/2010/01/28/why-i-wrote-arel/)


### Pašto ištraukimas

Veiksmų siuntėjas nuo pat pradžių turėjo beveik visus pašto žinučių susijusius funkcionalumus, įskaitant netgi tarpines analizės priemones ir pristatymo bei gavimo agentus, visi tai papildomai turi „TMail“ pardavinėjimą šaltinio medžio medžiagoje. 3 versija tai pakeičia, visi pašto žinučių susiję funkcionalumai išskiriami į [Mail](https://github.com/mikel/mail) įskiepį. Tai vėl sumažina kodo dublikavimą ir padeda sukurti aiškias ribas tarp „Action Mailer“ ir pašto analizatoriaus.

Daugiau informacijos: - [New Action Mailer API in Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)


Dokumentacija
-------------

Dokumentacija „Rails“ medžio yra atnaujinama su visais API pakeitimais, be to, [Rails Edge vadovai](https://edgeguides.rubyonrails.org/) yra atnaujinami vienas po kito, atspindintys „Rails 3.0“ pakeitimus. Vadovai adresu [guides.rubyonrails.org](https://guides.rubyonrails.org/) vis dėlto ir toliau turės tik stabilios versijos „Rails“ (šiuo metu 2.3.5 versijos, kol bus išleistas 3.0).

Daugiau informacijos: - [Rails Documentation Projects](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)
Tarptautinės sertifikavimo institucijos
--------------------

Rails 3 buvo atliktas didelis darbas, susijęs su I18n palaikymu, įskaitant naujausią [I18n](https://github.com/svenfuchs/i18n) biblioteką, kuri suteikia daug greičio patobulinimų.

* I18n funkcionalumas gali būti pridėtas prie bet kurio objekto, įtraukiant `ActiveModel::Translation` ir `ActiveModel::Validations`. Taip pat yra `errors.messages` atsarginė vertimų funkcija.
* Atributai gali turėti numatytuosius vertimus.
* Formos siuntimo žymės automatiškai paima teisingą būseną (Sukurti arba Atnaujinti), priklausomai nuo objekto būsenos, ir taip pat paima teisingą vertimą.
* Etiketės su I18n dabar veikia, tiesiog perduodant atributo pavadinimą.

Daugiau informacijos: - [Rails 3 I18n pakeitimai](http://blog.plataformatec.com.br/2010/02/rails-3-i18n-changes/)


Railties
--------

Atskiriant pagrindinius Rails karkaso komponentus, Railties buvo atliktas didelis peržiūrėjimas, siekiant padaryti sąsajas su karkaso komponentais, moduliais ar įskiepiais kuo paprastesnes ir plėtojamas:

* Kiekviena programa dabar turi savo vardų erdvę, programa pradedama su `YourAppName.boot`, pavyzdžiui, tai padaro sąveiką su kitomis programomis daug paprastesnę.
* Visa, kas yra `Rails.root/app`, dabar pridedama prie krovimo kelio, todėl galite sukurti `app/observers/user_observer.rb` ir Rails ją įkels be jokių modifikacijų.
* Rails 3.0 dabar teikia `Rails.config` objektą, kuris suteikia centralizuotą visų rūšių Rails konfigūracijos parinkčių saugyklą.

    Programos generavimas gavo papildomus parametrus, leidžiančius praleisti test-unit, Active Record, Prototype ir Git diegimą. Taip pat buvo pridėta nauja `--dev` parametras, kuris nustato programą su `Gemfile`, nurodančiu jūsų Rails kopijos vietą (kurią nustato kelias iki `rails` vykdomojo failo). Daugiau informacijos rasite `rails --help`.

Railties generatoriai buvo labai atidžiai peržiūrėti Rails 3.0, pagrindiniai pokyčiai:

* Generatoriai buvo visiškai peržiūrėti ir yra nekompatibilūs atgal.
* Rails šablonų API ir generatorių API buvo sujungti (jie yra tokie patys kaip anksčiau).
* Generatoriai daugiau neįkeliami iš specialių kelių, jie tiesiog randami Ruby krovimo kelyje, todėl kviečiant `rails generate foo` bus ieškoma `generators/foo_generator`.
* Nauji generatoriai suteikia kablys, todėl bet kokia šablonų sistema, ORM, testavimo karkasas gali lengvai prisijungti.
* Nauji generatoriai leidžia perrašyti šablonus, padėdami kopiją į `Rails.root/lib/templates`.
* Taip pat pateikiamas `Rails::Generators::TestCase`, kad galėtumėte kurti savo generatorius ir juos testuoti.

Taip pat buvo peržiūrėti Railties generatorių sugeneruoti rodiniai:

* Rodiniai dabar naudoja `div` žymes, o ne `p` žymes.
* Sugeneruoti pastoliai dabar naudoja `_form` dalinius, o ne dubliuotą kodą redagavimo ir naujų rodinių.
* Pastoliai formos dabar naudoja `f.submit`, kuris grąžina "Create ModelName" arba "Update ModelName", priklausomai nuo perduoto objekto būsenos.

Galiausiai keletas patobulinimų buvo pridėta prie rake užduočių:

* Pridėtas `rake db:forward`, leidžiantis atlikti migracijas atskirai arba grupėmis.
* Pridėtas `rake routes CONTROLLER=x`, leidžiantis peržiūrėti maršrutus tik vienam valdikliui.

Railties dabar pasenusios:

* `RAILS_ROOT` vietoj `Rails.root`,
* `RAILS_ENV` vietoj `Rails.env`, ir
* `RAILS_DEFAULT_LOGGER` vietoj `Rails.logger`.

`PLUGIN/rails/tasks` ir `PLUGIN/tasks` daugiau neįkeliami, visos užduotys dabar turi būti `PLUGIN/lib/tasks`.

Daugiau informacijos:

* [Rails 3 generatorių atradimas](http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators)
* [Rails modulis (Rails 3)](http://quaran.to/blog/2010/02/03/the-rails-module/)

Veiksmų paketas
-----------

Veiksmų pakete buvo įvykdyti svarbūs vidiniai ir išoriniai pokyčiai.


### Abstraktusis valdiklis

Abstraktusis valdiklis išskiria bendrus Action Controller dalis į perpanaudojamą modulį, kurį gali naudoti bet kokia biblioteka šablonų atvaizdavimui, dalinių atvaizdavimui, pagalbininkams, vertimams, žurnalavimui, bet kuriai užklausos ir atsakymo ciklo daliai. Šis abstraktumas leido `ActionMailer::Base` dabar tiesiog paveldėti iš `AbstractController` ir tiesiog apgaubti Rails DSL ant Mail gem.

Tai taip pat suteikė galimybę išvalyti Action Controller, išskirdami tai, kas galėjo supaprastinti kodą.

Tačiau reikia pažymėti, kad Abstraktusis valdiklis nėra vartotojui skirtas API, jūs jo nepasieksite savo kasdieninio Rails naudojimo metu.

Daugiau informacijos: - [Rails Edge architektūra](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Action Controller

* `application_controller.rb` dabar pagal nutylėjimą turi įjungtą `protect_from_forgery`.
* `cookie_verifier_secret` buvo pasenusi ir dabar vietoj to ji priskiriama per `Rails.application.config.cookie_secret` ir perkeliama į atskirą failą: `config/initializers/cookie_verification_secret.rb`.
* `session_store` buvo konfigūruojamas `ActionController::Base.session`, o dabar jis perkeltas į `Rails.application.config.session_store`. Numatytieji parametrai nustatomi `config/initializers/session_store.rb`.
* `cookies.secure` leidžia nustatyti užšifruotas reikšmes slapukuose su `cookie.secure[:key] => value`.
* `cookies.permanent` leidžia nustatyti nuolatines reikšmes slapukų maiše `cookie.permanent[:key] => value`, kurios kelia išimtis, jei patikrinimo klaidos pasirašytose reikšmėse.
* Dabar galite perduoti `:notice => 'Tai yra žinutė'` arba `:alert => 'Kažkas nutiko negerai'` į `format` iškvietimą `respond_to` bloke. `flash[]` maišas vis dar veikia kaip anksčiau.
* Jūsų valdikliams dabar pridėtas `respond_with` metodas, supaprastinantis senąjį `format` bloką.
* Pridėtas `ActionController::Responder`, leidžiantis jums lankstumą, kaip generuojami jūsų atsakymai.
Nebenaudojami:

* `filter_parameter_logging` yra nebenaudojamas, vietoje jo naudokite `config.filter_parameters << :password`.

Daugiau informacijos:

* [Renderinimo parinktys „Rails 3“](https://blog.engineyard.com/2010/render-options-in-rails-3)
* [Tris priežastys mėgti ActionController::Responder](https://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder)


### Veiksmo išsiuntimas

Veiksmo išsiuntimas yra naujas „Rails 3.0“ ir suteikia naują, švaresnę maršrutizavimo įgyvendinimą.

* Didelis maršrutizatoriaus valymas ir perirašymas, „Rails“ maršrutizatorius dabar yra „rack_mount“ su „Rails DSL“ viršuje, tai yra atskiras programinės įrangos gabalas.
* Kiekvienos aplikacijos apibrėžti maršrutai dabar yra pavadinimo erdvėje jūsų „Application“ modulyje, tai yra:

    ```ruby
    # Vietoje:

    ActionController::Routing::Routes.draw do |map|
      map.resources :posts
    end

    # Darykite:

    AppName::Application.routes do
      resources :posts
    end
    ```

* Pridėta `match` metodas maršrutizatoriui, taip pat galite perduoti bet kurį „Rack“ programą prie atitinkamo maršruto.
* Pridėtas `constraints` metodas maršrutizatoriui, leidžiantis apsaugoti maršrutus su apibrėžtomis apribojimais.
* Pridėtas `scope` metodas maršrutizatoriui, leidžiantis priskirti maršrutus skirtingoms kalboms ar skirtingiems veiksmams, pavyzdžiui:

    ```ruby
    scope 'es' do
      resources :projects, :path_names => { :edit => 'cambiar' }, :path => 'proyecto'
    end

    # Suteikia jums redagavimo veiksmą su /es/proyecto/1/cambiar
    ```

* Pridėtas `root` metodas maršrutizatoriui kaip trumpinys `match '/', :to => path`.
* Galite perduoti pasirinktinius segmentus į atitikmenį, pavyzdžiui `match "/:controller(/:action(/:id))(.:format)"`, kiekvienas skliaustelis segmentas yra pasirenkamas.
* Maršrutai gali būti išreikšti per blokus, pavyzdžiui galite iškviesti `controller :home { match '/:action' }`.

Pastaba. Senojo stiliaus „map“ komandos vis dar veikia kaip anksčiau su atgalinio suderinamumo sluoksniu, tačiau tai bus pašalinta 3.1 versijoje.

Nebenaudojami

* Visiems ne-REST aplikacijų „catch all“ maršrutams (`/:controller/:action/:id`) dabar yra užkomentuoti.
* Maršrutai `:path_prefix` daugiau neegzistuoja, o `:name_prefix` dabar automatiškai prideda "_" pabaigoje esančią reikšmę.

Daugiau informacijos:
* [„Rails 3“ maršrutizatorius: „Rack it Up“](http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/)
* [Peržiūrėti maršrutus „Rails 3“](https://medium.com/fusion-of-thoughts/revamped-routes-in-rails-3-b6d00654e5b0)
* [Bendriniai veiksmai „Rails 3“](http://yehudakatz.com/2009/12/20/generic-actions-in-rails-3/)


### Veiksmo rodinys

#### Neintruzinis „JavaScript“

Veiksmo rodinio pagalbininkuose buvo atliktas didelis perirašymas, įgyvendinant neintruzinį „JavaScript“ (UJS) kodus ir pašalinant senus vidinius AJAX komandų kodų fragmentus. Tai leidžia „Rails“ naudoti bet kurį suderinamą UJS tvarkytuvą, kad įgyvendintų UJS kodus pagalbininkuose.

Tai reiškia, kad visi ankstesni `remote_<method>` pagalbininkai buvo pašalinti iš „Rails“ branduolio ir perkelti į [Prototype Legacy Helper](https://github.com/rails/prototype_legacy_helper). Norėdami gauti UJS kodus į savo HTML, dabar perduodate `:remote => true`. Pavyzdžiui:

```ruby
form_for @post, :remote => true
```

Sukuria:

```html
<form action="http://host.com" id="create-post" method="post" data-remote="true">
```

#### Pagalbininkai su blokais

Pagalbininkai, pvz., `form_for` ar `div_for`, kurie įterpia turinį iš bloko, dabar naudoja `<%=`:

```html+erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

Jūsų patys pagalbininkai tokiu būdu turi grąžinti eilutę, o ne papildyti išvesties buferį rankomis.

Pagalbininkai, kurie daro kažką kita, pvz., `cache` ar `content_for`, nėra paveikti šiuo pakeitimu, jiems vis dar reikalingas `&lt;%` kaip anksčiau.

#### Kiti pakeitimai

* Jums nebeprireiks iškviesti `h(string)` norint išvengti HTML išvesties pabėgimo, tai dabar įjungta pagal numatytuosius nustatymus visuose rodinio šablonuose. Jei norite neapdoroto eilutės, iškvieskite `raw(string)`.
* Pagalbininkai dabar pagal numatytuosius nustatymus išveda HTML5.
* Formos žymos pagalbininkas dabar ištraukia reikšmes iš I18n su viena reikšme, todėl `f.label :name` ištrauks `:name` vertimą.
* I18n pasirinkimo žyma dabar turėtų būti :en.helpers.select, o ne :en.support.select.
* Jums nebeprireiks įdėti minuso ženklo į Ruby interpoliacijos pabaigą ERB šablone, norint pašalinti HTML išvestyje esančią paskutinę kėlimo į naują eilutę simbolį.
* Pridėtas `grouped_collection_select` pagalbininkas veiksmo rodinyje.
* Pridėtas `content_for?`, leidžiantis patikrinti, ar rodinyje yra turinio prieš atvaizduojant.
* perduodant `:value => nil` formos pagalbininkams, lauko `value` atributas bus nustatytas į `nil`, o ne naudojant numatytąją reikšmę
* perduodant `:id => nil` formos pagalbininkams, šie laukai bus atvaizduojami be `id` atributo
* perduodant `:alt => nil` `image_tag`, `img` žymė bus atvaizduojama be `alt` atributo

Aktyvus modelis
------------

Aktyvus modelis yra naujas „Rails 3.0“. Jis suteikia abstrakcijos lygmenį bet kokioms ORM bibliotekoms naudoti sąveikai su „Rails“, įgyvendinant aktyvaus modelio sąsają.
### ORM Abstrakcija ir Action Pack sąsaja

Viena iš pagrindinių komponentų atjungimo buvo visų ryšių su Active Record ištraukimas iš Action Pack. Tai dabar yra baigta. Visi nauji ORM įskiepiai dabar tiesiog turi įgyvendinti Active Model sąsajas, kad veiktų sklandžiai su Action Pack.

Daugiau informacijos: - [Padarykite bet kurį Ruby objektą jaustis kaip ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### Validacijos

Validacijos buvo perkeltos iš Active Record į Active Model, suteikiant sąsają validacijoms, kurios veikia visose ORM bibliotekose „Rails 3“.

* Dabar yra `validates :attribute, options_hash` trumpinys, leidžiantis perduoti parinktis visoms validates klasės metodams, galite perduoti daugiau nei vieną parinktį validacijos metode.
* `validates` metodas turi šias parinktis:
    * `:acceptance => Boolean`.
    * `:confirmation => Boolean`.
    * `:exclusion => { :in => Enumerable }`.
    * `:inclusion => { :in => Enumerable }`.
    * `:format => { :with => Regexp, :on => :create }`.
    * `:length => { :maximum => Fixnum }`.
    * `:numericality => Boolean`.
    * `:presence => Boolean`.
    * `:uniqueness => Boolean`.

PASTABA: Visi „Rails“ versijos 2.3 stiliaus validacijos metodai vis dar palaikomi „Rails 3.0“, naujas validates metodas yra skirtas papildomai padėti jūsų modelio validacijoms, o ne pakeisti esamą API.

Taip pat galite perduoti validavimo objektą, kurį tada galite pernaudoti tarp objektų, kurie naudoja Active Model:

```ruby
class TitleValidator < ActiveModel::EachValidator
  Titles = ['Mr.', 'Mrs.', 'Dr.']
  def validate_each(record, attribute, value)
    unless Titles.include?(value)
      record.errors[attribute] << 'turi būti galiojantis pavadinimas'
    end
  end
end
```

```ruby
class Person
  include ActiveModel::Validations
  attr_accessor :title
  validates :title, :presence => true, :title => true
end

# Arba Active Record

class Person < ActiveRecord::Base
  validates :title, :presence => true, :title => true
end
```

Taip pat yra palaikymas introspekcijai:

```ruby
User.validators
User.validators_on(:login)
```

Daugiau informacijos:

* [Seksuali validacija „Rails 3“](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)
* [„Rails 3“ validacijos paaiškinimas](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)


Active Record
-------------

Active Record gavo daug dėmesio „Rails 3.0“, įskaitant abstrakciją į Active Model, visišką užklausos sąsajos atnaujinimą naudojant Arel, validacijos atnaujinimus ir daugybę patobulinimų ir pataisymų. Visas „Rails“ 2.x API bus naudojamas per suderinamumo sluoksnį, kuris bus palaikomas iki 3.1 versijos.


### Užklausos sąsaja

Active Record, naudodamas Arel, dabar grąžina ryšius savo pagrindiniais metodais. Esamas „Rails 2.3.x“ API vis dar palaikomas ir nebus pasenus iki „Rails 3.1“ ir nebus pašalintas iki „Rails 3.2“, tačiau naujame API pateikiamos šios naujos sąsajos, kurios visos grąžina ryšius, leidžiant juos sujungti:

* `where` - nurodo sąlygas ryšiui, kuris grąžinamas.
* `select` - pasirinkite, kokius modelių atributus norite gauti iš duomenų bazės.
* `group` - grupuoja ryšį pagal pateiktą atributą.
* `having` - nurodo išraišką, apribojančią grupės ryšius (GROUP BY sąlyga).
* `joins` - sujungia ryšį su kita lentele.
* `clause` - nurodo išraišką, apribojančią sujungimo ryšius (JOIN sąlyga).
* `includes` - įtraukia kitus iš anksto įkeltus ryšius.
* `order` - rūšiuoja ryšį pagal pateiktą išraišką.
* `limit` - apriboja ryšį iki nurodyto įrašų skaičiaus.
* `lock` - užrakina iš duomenų bazės grąžinamus įrašus.
* `readonly` - grąžina duomenų kopiją, skirtą tik skaitymui.
* `from` - suteikia galimybę pasirinkti ryšius iš daugiau nei vienos lentelės.
* `scope` - (ankstesnis `named_scope`) grąžina ryšius ir gali būti sujungtas su kitais ryšių metodais.
* `with_scope` - ir `with_exclusive_scope` dabar taip pat grąžina ryšius ir gali būti sujungti.
* `default_scope` - taip pat veikia su ryšiais.

Daugiau informacijos:

* [Active Record užklausos sąsaja](http://m.onkey.org/2010/1/22/active-record-query-interface)
* [Leiskite savo SQL Growl „Rails 3“](http://hasmanyquestions.wordpress.com/2010/01/17/let-your-sql-growl-in-rails-3/)


### Patobulinimai

* Pridėtas `:destroyed?` prie Active Record objektų.
* Pridėtas `:inverse_of` prie Active Record asociacijų, leidžiantis gauti jau įkeltos asociacijos egzempliorių, nesinaudojant duomenų baze.


### Pataisos ir pasenusios funkcijos

Be to, daug pataisymų buvo atlikti Active Record šakoje:

* Palaikomas SQLite 2 palaikymas buvo pakeistas į SQLite 3.
* MySQL palaikymas stulpelių tvarkai.
* PostgreSQL adapteris buvo ištaisytas, kad nebūtų įterpiami neteisingi `TIME ZONE` reikšmės.
* Palaikomi keli schemų pavadinimai „PostgreSQL“ lentelėse.
* „PostgreSQL“ palaikymas XML duomenų tipo stulpeliui.
* `table_name` dabar yra talpinamas kešo atmintyje.
* Taip pat buvo atlikta daug darbo su „Oracle“ adapteriu, įskaitant daugybę klaidų taisymų.
Taip pat yra šie pasenusių funkcijų:

* `named_scope` klasėje Active Record yra pasenusi ir pervadinta į `scope`.
* `scope` metodams turėtumėte naudoti ryšio metodus, o ne `:conditions => {}` paieškos metodą, pavyzdžiui `scope :since, lambda {|time| where("created_at > ?", time) }`.
* `save(false)` yra pasenusi, naudokite `save(:validate => false)`.
* Active Record klaidų pranešimai turi būti pakeisti iš :en.activerecord.errors.template į `:en.errors.template`.
* `model.errors.on` yra pasenusi, naudokite `model.errors[]`
* validates_presence_of => validates... :presence => true
* `ActiveRecord::Base.colorize_logging` ir `config.active_record.colorize_logging` yra pasenusi, naudokite `Rails::LogSubscriber.colorize_logging` arba `config.colorize_logging`

PASTABA: Nors būsenos mašinos įgyvendinimas buvo įtrauktas į Active Record edge jau kelis mėnesius, jis buvo pašalintas iš Rails 3.0 versijos.

Active Resource
---------------

Active Resource taip pat buvo išskirtas į Active Model, leidžiantis naudoti Active Resource objektus su Action Pack be jokių problemų.

* Pridėtos validacijos per Active Model.
* Pridėtos stebėjimo kablys.
* HTTP įgaliotinės palaikymas.
* Pridėta palaikymas skaidraus autentifikavimo.
* Modelio pavadinimas perkeltas į Active Model.
* Active Resource atributai pakeisti į Hash su abipuse prieiga.
* Pridėti `first`, `last` ir `all` sinonimai ekvivalentiškiems paieškos apribojimams.
* `find_every` dabar nebegrąžina `ResourceNotFound` klaidos, jei nieko nerasta.
* Pridėtas `save!`, kuris iškelia `ResourceInvalid` klaidą, jei objektas nėra `valid?`.
* Pridėti `update_attribute` ir `update_attributes` Active Resource modeliams.
* Pridėtas `exists?`.
* Pervadintas `SchemaDefinition` į `Schema` ir `define_schema` į `schema`.
* Naudokite Active Resources `formatą` vietoje nuotolinės klaidos `content-type`.
* Naudokite `instance_eval` schemos blokui.
* Taisyti `ActiveResource::ConnectionError#to_s`, kai `@response` neatsako į #code arba #message, tvarko Ruby 1.9 suderinamumą.
* Pridėta palaikymas klaidoms JSON formatu.
* Užtikrinti, kad `load` veiktų su skaitiniais masyvais.
* Pripažįsta 410 atsakymą iš nuotolinio resurso kaip ištrintą resursą.
* Pridėta galimybė nustatyti SSL parinktis Active Resource ryšiams.
* Nustatant ryšio laiko limitą, taip pat veikia `Net::HTTP` `open_timeout`.

Pasenusių funkcijų:

* `save(false)` yra pasenusi, naudokite `save(:validate => false)`.
* Ruby 1.9.2: `URI.parse` ir `.decode` yra pasenusios ir nebebus naudojamos bibliotekoje.

Active Support
--------------

Buvo atliktas didelis darbas Active Support, kad jis būtų lengvai pasirenkamas, tai yra, jums nebūtina reikalauti visos Active Support bibliotekos, kad gautumėte jos dalis. Tai leidžia įvairioms pagrindinėms Rails komponentams veikti lengviau.

Štai pagrindiniai pokyčiai Active Support:

* Didelis bibliotekos valymas, pašalinant nenaudojamus metodus.
* Active Support daugiau nebeprideda TZInfo, Memcache Client ir Builder bibliotekų. Jos visos įtrauktos kaip priklausomybės ir įdiegiamos naudojant `bundle install` komandą.
* Saugūs buferiai įgyvendinti `ActiveSupport::SafeBuffer`.
* Pridėti `Array.uniq_by` ir `Array.uniq_by!`.
* Pašalintas `Array#rand` ir atgalinė `Array#sample` iš Ruby 1.9.
* Taisytas klaidos `TimeZone.seconds_to_utc_offset` grąžinant neteisingą reikšmę.
* Pridėtas `ActiveSupport::Notifications` middleware.
* `ActiveSupport.use_standard_json_time_format` dabar pagal nutylėjimą yra true.
* `ActiveSupport.escape_html_entities_in_json` dabar pagal nutylėjimą yra false.
* `Integer#multiple_of?` priima nulį kaip argumentą, jei priėmėjas yra nulis, grąžina false.
* `string.chars` pervadintas į `string.mb_chars`.
* `ActiveSupport::OrderedHash` dabar gali būti deserializuojamas per YAML.
* Pridėtas SAX-based parseris XmlMini, naudojant LibXML ir Nokogiri.
* Pridėtas `Object#presence`, kuris grąžina objektą, jei jis yra `#present?`, kitu atveju grąžina `nil`.
* Pridėtas `String#exclude?` pagrindinis išplėtimas, kuris grąžina priešingybę `#include?`.
* Pridėtas `to_i` `DateTime` klasei `ActiveSupport`, kad `to_yaml` teisingai veiktų modeliams su `DateTime` atributais.
* Pridėtas `Enumerable#exclude?`, kad būtų galima lyginti su `Enumerable#include?` ir išvengti `!x.include?`.
* Perjungti į numatytąjį XSS apsaugos režimą „rails“.
* Palaikoma giluminė sujungimo funkcija `ActiveSupport::HashWithIndifferentAccess`.
* `Enumerable#sum` dabar veikia su visais numeruojamaisiais, net jei jie nereaguoja į `:size`.
* `inspect` nulio ilgio trukme grąžina „0 sekundės“, o ne tuščią eilutę.
* Pridėti `element` ir `collection` į `ModelName`.
* `String#to_time` ir `String#to_datetime` tvarko trupmenines sekundes.
* Pridėta palaikymas naujiems aplinkos filtrų objektams, kurie atsako į `:before` ir `:after`, naudojami prieš ir po kablys.
* `ActiveSupport::OrderedHash#to_a` metodas grąžina surikiuotą masyvų rinkinį. Atitinka Ruby 1.9 `Hash#to_a`.
* `MissingSourceFile` egzistuoja kaip konstanta, bet dabar ji lygi `LoadError`.
* Pridėtas `Class#class_attribute`, kad būtų galima deklaruoti klasės lygio atributą, kurio reikšmė yra paveldima ir perrašoma po klasėmis.
* Galiausiai pašalintas `DeprecatedCallbacks` iš `ActiveRecord::Associations`.
* `Object#metaclass` dabar yra `Kernel#singleton_class`, kad atitiktų Ruby.
Šie metodai buvo pašalinti, nes jie dabar yra prieinami Ruby 1.8.7 ir 1.9 versijose.

* `Integer#even?` ir `Integer#odd?`
* `String#each_char`
* `String#start_with?` ir `String#end_with?` (3-as asmuo lieka)
* `String#bytesize`
* `Object#tap`
* `Symbol#to_proc`
* `Object#instance_variable_defined?`
* `Enumerable#none?`

Saugumo patikrinimas REXML lieka Active Support, nes ankstyvosios Ruby 1.8.7 versijos vis dar jo reikalauja. Active Support žino, ar jį reikia taikyti ar ne.

Šie metodai buvo pašalinti, nes jie daugiau nenaudojami karkase:

* `Kernel#daemonize`
* `Object#remove_subclasses_of` `Object#extend_with_included_modules_from`, `Object#extended_by`
* `Class#remove_class`
* `Regexp#number_of_captures`, `Regexp.unoptionalize`, `Regexp.optionalize`, `Regexp#number_of_captures`


Action Mailer
-------------

Action Mailer gavo naują API, kur TMail buvo pakeistas nauju [Mail](https://github.com/mikel/mail) elektroninės pašto biblioteka. Pati Action Mailer buvo beveik visiškai perrašyta, kuriai buvo pakeista praktiškai kiekviena eilutė kodo. Rezultatas yra tas, kad Action Mailer dabar tiesiog paveldi iš Abstract Controller ir apgaubia Mail biblioteką Rails DSL. Tai žymiai sumažina kodo kiekį ir kitų bibliotekų dubliavimą Action Mailer.

* Visi pašto siuntėjai dabar pagal nutylėjimą yra `app/mailers` aplankale.
* Dabar galima siųsti el. laiškus naudojant naują API su trimis metodais: `attachments`, `headers` ir `mail`.
* Action Mailer dabar natūraliai palaiko vidinius priedus naudodama `attachments.inline` metodą.
* Action Mailer el. laiškų metodai dabar grąžina `Mail::Message` objektus, kurie gali būti išsiųsti naudojant `deliver` pranešimą.
* Visi pristatymo metodai dabar yra abstrahuoti į Mail biblioteką.
* Pašto pristatymo metodas gali priimti raktų ir reikšmių porų hainą, kurie yra visiškai galiojantys pašto antraštės laukams.
* `mail` pristatymo metodas veikia panašiai kaip Action Controller `respond_to`, ir galite aiškiai arba neaiškiai atvaizduoti šablonus. Action Mailer pagal poreikį pavers el. laišką daugialypiu laišku.
* Galite perduoti proc į `format.mime_type` kvietimus laiško bloke ir aiškiai atvaizduoti tam tikrus teksto tipus, arba pridėti išdėstymus ar skirtingus šablonus. `render` kvietimas proc viduje yra iš Abstract Controller ir palaiko tas pačias parinktis.
* Tai, kas buvo pašto siuntėjo vienetų testai, buvo perkelti į funkcinius testus.
* Action Mailer dabar visą automatinį antraščių laukų ir kūnų kodavimą perduoda Mail bibliotekai.
* Action Mailer automatiškai koduoja el. laiškų kūnus ir antraštes už jus

Nebenaudojami:

* `:charset`, `:content_type`, `:mime_version`, `:implicit_parts_order` yra visi pasenusių `ActionMailer.default :key => value` stiliaus deklaracijų naudojimo vietose.
* Mailer dinaminiai `create_method_name` ir `deliver_method_name` yra pasenusi, tiesiog iškvieskite `method_name`, kuris dabar grąžina `Mail::Message` objektą.
* `ActionMailer.deliver(message)` yra pasenusi, tiesiog iškvieskite `message.deliver`.
* `template_root` yra pasenusi, perduokite parinktis į `render` kvietimą proc viduje iš `format.mime_type` metodo laiško generavimo bloke.
* `body` metodas, skirtas apibrėžti objekto kūno kintamuosius, yra pasenusi (`body {:ivar => value}`), tiesiog deklaruokite objekto kintamuosius tiesiogiai metode ir jie bus prieinami šablone.
* Siuntėjai esantys `app/models` aplankale yra pasenusi, naudokite `app/mailers` aplankalą.

Daugiau informacijos:

* [Naujas Action Mailer API Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)
* [Nauja Ruby Mail biblioteka](http://lindsaar.net/2010/1/23/mail-gem-version-2-released)


Autoriai
-------

Žr. [visą sąrašą Rails prisidėjusių asmenų](https://contributors.rubyonrails.org/), kurie daugybę valandų skyrė Rails 3 kūrimui. Kudos visiems jiems.

Rails 3.0 išleidimo pastabas sudarė [Mikel Lindsaar](http://lindsaar.net).
