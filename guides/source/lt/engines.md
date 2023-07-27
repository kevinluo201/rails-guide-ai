**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2aedcd7fcf6f0b83538e8a8220d38afd
Pradėkime su varikliais
============================

Šiame vadove sužinosite apie variklius ir kaip juos galima naudoti, kad suteiktumėte papildomą funkcionalumą savo pagrindinėms programoms per aiškią ir labai lengvai naudojamą sąsają.

Po šio vadovo perskaitymo žinosite:

* Kas sudaro variklį.
* Kaip sukurti variklį.
* Kaip kurti funkcijas varikliui.
* Kaip prijungti variklį prie programos.
* Kaip perrašyti variklio funkcionalumą programoje.
* Kaip išvengti "Rails" karkasų įkėlimo naudojant įkėlimo ir konfigūracijos "hooks".

--------------------------------------------------------------------------------

Kas yra varikliai?
-----------------

Varikliai gali būti laikomi miniatiūrinėmis programomis, kurios suteikia funkcionalumą savo pagrindinėms programoms. "Rails" programa iš tikrųjų yra tik "supertankinis" variklis, kurio `Rails::Application` klasė paveldi daugelį savo elgsenos iš `Rails::Engine`.

Todėl varikliai ir programos gali būti laikomi beveik tuo pačiu dalyku, tik su subtiliais skirtumais, kaip matysite per šį vadovą. Varikliai ir programos taip pat dalinasi bendra struktūra.

Varikliai taip pat yra glaudžiai susiję su įskiepiais. Abu dalinasi bendra `lib` katalogo struktūra ir abu yra generuojami naudojant `rails plugin new` generatorių. Skirtumas yra tas, kad variklis yra laikomas "pilnu įskiepiu" pagal "Rails" (kaip nurodo `--full` parinktis, kuri perduodama generatoriaus komandai). Čia mes iš tikrųjų naudosime `--mountable` parinktį, kuri įtraukia visus `--full` funkcionalumus ir dar daugiau. Šiame vadove šiuos "pilnuosius įskiepius" paprasčiausiai vadinsime "varikliais". Variklis **gali** būti įskiepis, ir įskiepis **gali** būti variklis.

Variklis, kuris bus sukurtas šiame vadove, bus vadinamas "blorgh". Šis variklis suteiks savo pagrindinėms programoms tinklaraščio funkcionalumą, leisiantį kurti naujus straipsnius ir komentarus. Šio vadovo pradžioje dirbsite tik variklyje, bet vėlesniais skyriais pamatysite, kaip jį prijungti prie programos.

Varikliai taip pat gali būti izoliuoti nuo savo pagrindinių programų. Tai reiškia, kad programa gali turėti maršruto pagalbininko, pvz., `articles_path`, ir naudoti variklį, kuris taip pat suteikia maršrutą, taip pat vadinamą `articles_path`, ir šie du maršrutai nesikibs. Be to, valdikliai, modeliai ir lentelių pavadinimai taip pat yra sudėtiniai. Vėliau šiame vadove pamatysite, kaip tai padaryti.

Svarbu visada prisiminti, kad programa **visada** turi pirmenybę prieš variklius. Programa yra objektas, kuris galutinai nusprendžia, kas vyksta jos aplinkoje. Variklis turėtų tik pagerinti programą, o ne drastiškai ją keisti.

Norėdami pamatyti kitų variklių demonstracijas, apsilankykite
[Devise](https://github.com/plataformatec/devise), variklis, kuris suteikia
autentifikaciją pagrindinėms programoms, arba
[Thredded](https://github.com/thredded/thredded), variklis, kuris suteikia forumo
funkcionalumą. Taip pat yra [Spree](https://github.com/spree/spree), kuris
suteikia elektroninės prekybos platformą, ir
[Refinery CMS](https://github.com/refinery/refinerycms), CMS variklis.

Galų gale, varikliai nebūtų buvę įmanomi be James Adam, Piotr Sarnacki, "Rails" branduolio komandos ir kitų žmonių darbo. Jei kada nors susitiksite su jais, nepamirškite padėkoti!

Variklio generavimas
--------------------

Norėdami sukurti variklį, turėsite paleisti įskiepio generatorių ir perduoti jam tinkamas parinktis. "Blorgh" pavyzdžiui, turėsite sukurti "mountable" variklį, paleisdami šią komandą terminalo lange:

```bash
$ rails plugin new blorgh --mountable
```

Visą parinkčių sąrašą įskiepio generatoriui galite pamatyti įvedę:

```bash
$ rails plugin --help
```

`--mountable` parinktis praneša generatoriui, kad norite sukurti "mountable" ir vardų erdve izoliuotą variklį. Šis generatorius suteiks tą pačią skeleto struktūrą kaip ir `--full` parinktis. `--full` parinktis praneša generatoriui, kad norite sukurti variklį, įskaitant skeleto struktūrą, kuri suteikia šiuos dalykus:

  * `app` katalogo medį
  * `config/routes.rb` failą:

    ```ruby
    Rails.application.routes.draw do
    end
    ```

  * Failą `lib/blorgh/engine.rb`, kuris funkcionalumu yra identiškas įprastos "Rails" programos `config/application.rb` failui:

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
      end
    end
    ```

`--mountable` parinktis pridės prie `--full` parinkties:

  * Turtinio manifestų failus (`blorgh_manifest.js` ir `application.css`)
  * Vardų erdve izoliuotą `ApplicationController` šabloną
  * Vardų erdve izoliuotą `ApplicationHelper` šabloną
  * Variklio išdėstymo rodinio šabloną
  * Vardų erdve izoliuotą `config/routes.rb` failą:
```ruby
Blorgh::Engine.routes.draw do
end
```

* Vardų erdvės izoliacija `lib/blorgh/engine.rb`:

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

Be to, `--mountable` parinktis nurodo generatoriui, kad jis įdiegtų variklį
viduje tuščiojo testinio taikomojo programa, esančioje `test/dummy`, pridedant
šį kodą į tuščiosios taikomosios programos maršrutų failą, esantį
`test/dummy/config/routes.rb`:

```ruby
mount Blorgh::Engine => "/blorgh"
```

### Viduje variklio

#### Svarbūs failai

Šio visiškai naujo variklio katalogo šaknyje yra `blorgh.gemspec` failas. Vėliau,
kai įtrauksite variklį į programą, tai padarysite su šia eilute `Gemfile` faile:

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

Nepamirškite paleisti `bundle install` kaip įprasta. Nurodydami jį kaip juvelyrinį
įrašą `Gemfile` faile, Juvelyras jį įkels kaip tokį, analizuodamas šį `blorgh.gemspec` failą
ir reikalaudamas `lib` kataloge esančio failo, vadinamo `lib/blorgh.rb`. Šis
failas reikalauja `blorgh/engine.rb` failo (randamo `lib/blorgh/engine.rb`)
ir apibrėžia pagrindinį modulį, vadinamą `Blorgh`.

```ruby
require "blorgh/engine"

module Blorgh
end
```

PATARIMAS: Kai kurie varikliai šiame faile pasirenka įdėti globalias konfigūracijos parinktis
savo varikliui. Tai yra santykinai gera idėja, todėl jei norite pasiūlyti
konfigūracijos parinktis, jūsų variklio `module` apibrėžimo vieta tam yra
tobula. Įdėkite metodus į modulį ir jums viskas bus gerai.

`lib/blorgh/engine.rb` faile yra variklio pagrindinė klasė:

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

Paveldėdama iš `Rails::Engine` klasės, ši juvelyrinė praneša Rails, kad
nurodytoje vietoje yra variklis ir jis teisingai įdiegs variklį
viduje programos, atliekant užduotis, tokias kaip pridėti variklio `app` katalogą
prie kelių, skirtų modeliams, pašto siuntėjams, valdikliams ir rodiniams.

Čia ypatingą pastebėjimą vertas `isolate_namespace` metodas. Šis kvietimas yra
atsakingas už valdiklių, modelių, maršrutų ir kitų dalykų izoliavimą į
savo pačių vardų erdvę, atskirai nuo panašių komponentų programoje.
Be to, yra galimybė, kad variklio komponentai gali "pratekti"
į programą, sukeldami nepageidaujamą sutrikimą, arba svarbūs variklio
komponentai gali būti perrašyti programoje panašiais pavadinimais.
Vienas iš tokių konfliktų pavyzdžių yra pagalbinės funkcijos. Neiškvietus
`isolate_namespace`, variklio pagalbinės funkcijos būtų įtrauktos į programos
valdiklius.

PASTABA: Labai **rekomenduojama** palikti `isolate_namespace` eilutę
`Engine` klasės apibrėžime. Be jos, variklio sukurtos klasės **gali**
sukelti konfliktą su programa.

Kas reiškia ši vardų erdvės izoliacija yra tai, kad modelis, sukurtas
kviečiant `bin/rails generate model`, pvz., `bin/rails generate model article`, nebus vadinamas `Article`, bet
bus vadinamas `Blorgh::Article`. Be to, modelio lentelė bus vadinama
`blorgh_articles`, o ne tiesiog `articles`. Panašiai kaip modelio vardų erdvė,
valdiklis, vadinamas `ArticlesController`, tampa `Blorgh::ArticlesController`, o to valdiklio rodiniai nebus
`app/views/articles`, bet `app/views/blorgh/articles`. Pašto siuntėjai, darbai
ir pagalbinės funkcijos taip pat yra vardų erdvėje.

Galiausiai, maršrutai taip pat bus izoliuoti variklyje. Tai viena iš svarbiausių
vardų erdvės dalis ir apie tai bus kalbama vėliau
[Maršrutai](#maršrutai) šio vadovo skyriuje.

#### `app` katalogas

`app` kataloge yra įprasti `assets`, `controllers`, `helpers`,
`jobs`, `mailers`, `models` ir `views` katalogai, su kuriais turėtumėte susipažinti
iš programos. Mes išsamiau pažvelgsime į modelius vėlesniame skyriuje, kai rašysime variklį.

`app/assets` kataloge yra `images` ir
`stylesheets` katalogai, kurie, vėlgi, turėtų būti jums pažįstami dėl jų
panašumo į programą. Vienintelis skirtumas čia yra tai, kad kiekvienas
katalogas turi poapvalį katalogą su variklio pavadinimu. Kadangi šis variklis
bus vardų erdvėje, taip pat turėtų būti ir jo turinys.

`app/controllers` kataloge yra `blorgh` katalogas, kuriame
yra failas, vadinamas `application_controller.rb`. Šis failas suteiks bet
kokį bendrą funkcionalumą variklio valdikliams. `blorgh` katalogas
yra vieta, kur bus kiti variklio valdikliai. Juos dedant į
šią vardų erdvę, užkertate kelią galimam konfliktui su
identiškai pavadintais valdikliais kituose varikliuose ar netgi programoje.

PASTABA: Variklio `ApplicationController` klasė pavadinta taip pat kaip ir
Rails programa, kad būtų lengviau konvertuoti programas į variklius.
PASTABA: Jei pagrindinė programa veikia `classic` režimu, gali atsitikti situacija, kai jūsų variklio valdiklis paveldi iš pagrindinės programos valdiklio, o ne iš jūsų variklio programos valdiklio. Geriausias būdas tai išvengti yra perjungti į `zeitwerk` režimą pagrindinėje programoje. Kitu atveju, naudokite `require_dependency`, kad būtų užtikrinta, jog bus įkeltas variklio programos valdiklis. Pavyzdžiui:

```ruby
# TIK REIKALINGA `classic` REŽIME.
require_dependency "blorgh/application_controller"

module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

ĮSPĖJIMAS: Nenaudokite `require`, nes tai sugadins automatinį klasės perkrovimą vystymo aplinkoje - naudojant `require_dependency` užtikrinama, kad klasės būtų įkeltos ir iškrautos tinkamu būdu.

Tiksliai taip pat kaip `app/controllers`, rasite `blorgh` subkatalogą `app/helpers`, `app/jobs`, `app/mailers` ir `app/models` kataloguose, kuriuose yra susijęs `application_*.rb` failas bendroms funkcijoms rinkti. Įdedant savo failus į šį subkatalogą ir naudojant objektų vardų erdvę, užkertate kelią galimam susidūrimui su vienodais pavadinimais elementais kituose varikliuose ar netgi programoje.

Galų gale, `app/views` kataloge yra `layouts` aplankas, kuriame yra failas `blorgh/application.html.erb`. Šis failas leidžia nurodyti variklio išdėstymą. Jei šis variklis bus naudojamas kaip autonomiškas variklis, tuomet bet kokias pritaikymo išdėstymo pasirinkimas galėsite pridėti į šį failą, o ne į programos `app/views/layouts/application.html.erb` failą.

Jei nenorite primesti išdėstymo variklio naudotojams, galite ištrinti šį failą ir nurodyti kitą išdėstymą variklio valdikliuose.

#### `bin` katalogas

Šis katalogas turi vieną failą, `bin/rails`, kuris leidžia naudoti `rails` subkomandas ir generatorius taip pat kaip ir programoje. Tai reiškia, kad galėsite labai lengvai generuoti naujus valdiklius ir modelius šiam varikliui, vykdant tokius komandas:

```bash
$ bin/rails generate model
```

Žinoma, atsiminkite, kad viskas, kas yra sugeneruota šiomis komandomis variklyje, kuriame `Engine` klasėje yra `isolate_namespace`, bus vardų erdvėje.

#### `test` katalogas

`test` katalogas yra vieta, kurioje bus talpinami variklio testai. Norint ištestuoti variklį, jame yra sumažinta „Rails“ programa, įterpta į `test/dummy`. Ši programa prijungs variklį prie `test/dummy/config/routes.rb` failo:

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

Šis kodas prijungs variklį prie kelio `/blorgh`, kuris padarys jį pasiekiamą tik per programą šiuo keliu.

Testų kataloge yra `test/integration` katalogas, kuriame turėtų būti talpinami variklio integracijos testai. Taip pat galima sukurti kitus katalogus `test` kataloge. Pavyzdžiui, galite sukurti `test/models` katalogą savo modelių testams.

Variklio funkcionalumo teikimas
------------------------------

Šiame vadove aptariamas variklis suteikia galimybę pateikti straipsnius ir komentuoti funkcionalumą ir seką panašią į [Pradžios vadovą](getting_started.html), su kai kuriomis naujomis niuansais.

PASTABA: Šiame skyriuje įsitikinkite, kad komandas vykdote `blorgh` variklio katalogo šakninėje direktorijoje.

### Straipsnio resurso generavimas

Pirmas dalykas, kurį reikia sugeneruoti tinklaraščio varikliui, yra `Article` modelis ir susijęs valdiklis. Norėdami tai greitai sugeneruoti, galite naudoti „Rails“ šablonų generatorių.

```bash
$ bin/rails generate scaffold article title:string text:text
```

Ši komanda išves šią informaciją:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_articles.rb
create    app/models/blorgh/article.rb
invoke    test_unit
create      test/models/blorgh/article_test.rb
create      test/fixtures/blorgh/articles.yml
invoke  resource_route
 route    resources :articles
invoke  scaffold_controller
create    app/controllers/blorgh/articles_controller.rb
invoke    erb
create      app/views/blorgh/articles
create      app/views/blorgh/articles/index.html.erb
create      app/views/blorgh/articles/edit.html.erb
create      app/views/blorgh/articles/show.html.erb
create      app/views/blorgh/articles/new.html.erb
create      app/views/blorgh/articles/_form.html.erb
invoke    test_unit
create      test/controllers/blorgh/articles_controller_test.rb
create      test/system/blorgh/articles_test.rb
invoke    helper
create      app/helpers/blorgh/articles_helper.rb
invoke      test_unit
```

Pirmas dalykas, kurį šablonų generatorius daro, yra „active_record“ generatoriaus iškvietimas, kuris sugeneruoja migraciją ir modelį resursui. Tačiau atkreipkite dėmesį, kad migracija vadinasi `create_blorgh_articles`, o ne įprastai `create_articles`. Tai yra dėl `isolate_namespace` metodo, kuris yra iškviestas `Blorgh::Engine` klasės apibrėžime. Modelis čia taip pat yra vardų erdvėje, jis yra dedamas į `app/models/blorgh/article.rb`, o ne į `app/models/article.rb`, dėl `isolate_namespace` iškvietimo `Engine` klasėje.

Toliau yra iškviečiamas `test_unit` generatorius šiam modeliui, kuris sugeneruoja modelio testą `test/models/blorgh/article_test.rb` (o ne `test/models/article_test.rb`) ir fiktyvų duomenų rinkinį `test/fixtures/blorgh/articles.yml` (o ne `test/fixtures/articles.yml`).

Po to į `config/routes.rb` failą variklio resursui įterpiama eilutė. Ši eilutė yra tiesiog `resources :articles`, paverčiant `config/routes.rb` failą variklio atveju į šį kodą:
```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

Pastaba čia yra ta, kad maršrutai yra nubraižomi ant `Blorgh::Engine` objekto, o ne ant `YourApp::Application` klasės. Tai padaryta tam, kad maršrutai būtų apriboti tik prie paties variklio ir galėtų būti prijungti prie tam tikros vietos, kaip parodyta [testų katalogo](#test-directory) skyriuje. Tai taip pat sukuria izoliuotus variklio maršrutus nuo tų maršrutų, kurie yra programoje. Šio vadovo [Maršrutai](#routes) skyrius tai išsamiai aprašo.

Toliau yra iškviečiamas `scaffold_controller` generatorius, kuris generuoja kontrolerį, vadinamą `Blorgh::ArticlesController` (esantį `app/controllers/blorgh/articles_controller.rb`) ir susijusius jo rodinius `app/views/blorgh/articles`. Šis generatorius taip pat generuoja testus kontroleriui (`test/controllers/blorgh/articles_controller_test.rb` ir `test/system/blorgh/articles_test.rb`) ir pagalbininką (`app/helpers/blorgh/articles_helper.rb`).

Viskas, ką šis generatorius sukūrė, yra tvarkingai sudėliota pagal vardų erdvę. Kontrolerio klasė apibrėžiama `Blorgh` modulyje:

```ruby
module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

PASTABA: `ArticlesController` klasė paveldi `Blorgh::ApplicationController`, o ne programos `ApplicationController`.

Pagalbininkas `app/helpers/blorgh/articles_helper.rb` taip pat yra vardų erdvėje:

```ruby
module Blorgh
  module ArticlesHelper
    # ...
  end
end
```

Tai padeda išvengti konfliktų su kitu varikliu ar programu, kurie taip pat gali turėti straipsnio išteklių.

Galite pamatyti, ką variklis turi iki šiol, paleisdami `bin/rails db:migrate` šakninėje variklio vietoje, kad paleistumėte scaffold generatoriaus sugeneruotą migraciją, ir tada paleisdami `bin/rails server` `test/dummy`. Kai atidarote `http://localhost:3000/blorgh/articles`, pamatysite numatytąjį scaffold, kuris buvo sugeneruotas. Paspauskite aplink! Jūs tik ką sugeneravote savo pirmąjį variklio pirmąsias funkcijas.

Jei norite žaisti konsolėje, `bin/rails console` taip pat veiks kaip Rails programa. Atminkite: `Article` modelis yra vardų erdvėje, todėl norėdami jį paminėti, turite jį pavadinti kaip `Blorgh::Article`.

```irb
irb> Blorgh::Article.find(1)
=> #<Blorgh::Article id: 1 ...>
```

Vienintelis dalykas, kurį reikia padaryti, yra tai, kad šio variklio `articles` ištekliui turėtų būti šakninė vieta. Kai kas nors eina į šakninį kelią, kuriame yra prijungtas variklis, jiems turėtų būti rodomas straipsnių sąrašas. Tai galima padaryti, jei į `config/routes.rb` failą įterpiamas šis eilutės:

```ruby
root to: "articles#index"
```

Dabar žmonės turės eiti tik į variklio šaknį, kad pamatytų visus straipsnius, o ne lankytis `/articles`. Tai reiškia, kad vietoj `http://localhost:3000/blorgh/articles`, jums tereikia eiti į `http://localhost:3000/blorgh` dabar.

### Generuojant komentarų išteklius

Dabar, kai variklis gali kurti naujus straipsnius, prasminga pridėti ir komentarų funkcionalumą. Tam reikės sugeneruoti komentarų modelį, komentarų kontrolerį ir tada modifikuoti straipsnių scaffold, kad būtų rodomi komentarai ir leidžiama žmonėms kurti naujus.

Iš variklio šaknies paleiskite modelio generatorių. Pasakykite jam sugeneruoti `Comment` modelį, susijusią lentelę turinčią dvi stulpelius: `article_id` sveikąjį skaičių ir `text` teksto stulpelį.

```bash
$ bin/rails generate model Comment article_id:integer text:text
```

Tai išves šį rezultatą:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_comments.rb
create    app/models/blorgh/comment.rb
invoke    test_unit
create      test/models/blorgh/comment_test.rb
create      test/fixtures/blorgh/comments.yml
```

Šis generatoriaus kvietimas sugeneruos tik būtinus modelio failus, kurie jam reikalingi, vardų erdvėje sudėliodamas failus po `blorgh` direktorija ir sukurdamas modelio klasę, vadinamą `Blorgh::Comment`. Dabar paleiskite migraciją, kad sukurtumėte mūsų `blorgh_comments` lentelę:

```bash
$ bin/rails db:migrate
```

Kad parodytumėte komentarus straipsnyje, redaguokite `app/views/blorgh/articles/show.html.erb` ir prieš "Redaguoti" nuorodą įdėkite šią eilutę:

```html+erb
<h3>Komentarai</h3>
<%= render @article.comments %>
```

Ši eilutė reikalauja, kad `Blorgh::Article` modelyje būtų apibrėžtas `has_many` asociacija komentarams, kurios šiuo metu nėra. Norėdami apibrėžti ją, atidarykite `app/models/blorgh/article.rb` ir į modelį įdėkite šią eilutę:

```ruby
has_many :comments
```

Modelis taps tokiu:

```ruby
module Blorgh
  class Article < ApplicationRecord
    has_many :comments
  end
end
```

PASTABA: Kadangi `has_many` yra apibrėžtas klasėje, kuri yra `Blorgh` modulyje, „Rails“ žinos, kad norite naudoti `Blorgh::Comment` modelį šiems objektams, todėl nereikia čia nurodyti `:class_name` parinkties.

Toliau turi būti forma, kad būtų galima kurti komentarus straipsnyje. Norėdami tai padaryti, po `render @article.comments` iškvieskite šią eilutę `app/views/blorgh/articles/show.html.erb`:

```erb
<%= render "blorgh/comments/form" %>
```

Toliau, ši eilutė iškviečianti šį dalinį turėtų egzistuoti. Sukurkite naują direktoriją `app/views/blorgh/comments` ir jame naują failą, vadinamą `_form.html.erb`, kuriame būtų šis turinys, kad būtų sukurtas reikalingas dalinis:
```html+erb
<h3>Naujas komentaras</h3>
<%= form_with model: [@article, @article.comments.build] do |form| %>
  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>
  <%= form.submit %>
<% end %>
```

Kai ši forma yra pateikiama, ji bandys atlikti `POST` užklausą į maršrutą `/articles/:article_id/comments` viduje variklio. Šiuo metu šis maršrutas neegzistuoja, bet jį galima sukurti pakeičiant `resources :articles` eilutę `config/routes.rb` į šias eilutes:

```ruby
resources :articles do
  resources :comments
end
```

Tai sukuria įdėtą maršrutą komentarams, kuris yra reikalingas formai.

Dabar maršrutas egzistuoja, bet kontroleris, į kurį eina šis maršrutas, neegzistuoja. Norėdami jį sukurti, paleiskite šią komandą iš variklio šaknies:

```bash
$ bin/rails generate controller comments
```

Tai sukurs šias dalis:

```
create  app/controllers/blorgh/comments_controller.rb
invoke  erb
 exist    app/views/blorgh/comments
invoke  test_unit
create    test/controllers/blorgh/comments_controller_test.rb
invoke  helper
create    app/helpers/blorgh/comments_helper.rb
invoke    test_unit
```

Forma atliks `POST` užklausą į `/articles/:article_id/comments`, kuris atitiks `create` veiksmą `Blorgh::CommentsController`. Šis veiksmas turi būti sukurtas, tai galima padaryti įdedant šias eilutes į klasės apibrėžimą `app/controllers/blorgh/comments_controller.rb`:

```ruby
def create
  @article = Article.find(params[:article_id])
  @comment = @article.comments.create(comment_params)
  flash[:notice] = "Komentaras buvo sukurtas!"
  redirect_to articles_path
end

private
  def comment_params
    params.require(:comment).permit(:text)
  end
```

Tai yra paskutinis žingsnis, reikalingas, kad naujo komentaro forma veiktų. Tačiau komentarų rodymas dar nėra visiškai teisingas. Jei dabar sukurtumėte komentarą, pamatytumėte šią klaidą:

```
Trūksta dalinio blorgh/comments/_comment su {:handlers=>[:erb, :builder],
:formats=>[:html], :locale=>[:en, :en]}. Ieškoma:   *
"/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"   *
"/Users/ryan/Sites/side_projects/blorgh/app/views"
```

Variklis negali rasti dalinio, reikalingo komentarų atvaizdavimui. „Rails“ ieško pirmiausia aplikacijos (`test/dummy`) `app/views` kataloge, o tada variklio `app/views` kataloge. Kai jis negali rasti, jis išmeta šią klaidą. Variklis žino, kad ieško `blorgh/comments/_comment`, nes gauna modelio objektą iš `Blorgh::Comment` klasės.

Šis dalinis bus atsakingas tik už komentaro teksto atvaizdavimą. Sukurkite naują failą `app/views/blorgh/comments/_comment.html.erb` ir įdėkite į jį šią eilutę:

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

`comment_counter` vietinė kintamąji mums suteikiama `<%= render @article.comments %>` iškvietimo, kuris ją automatiškai apibrėžia ir padidina skaitiklį, kai jis iteruoja per kiekvieną komentarą. Šiame pavyzdyje ji naudojama, kad parodytų mažą numerį šalia kiekvieno komentaro, kai jis yra sukurtas.

Tai užbaigia komentarų funkciją tinklaraščio variklyje. Dabar laikas jį naudoti aplikacijoje.

Prijungimas prie aplikacijos
---------------------------

Variklio naudojimas aplikacijoje yra labai paprastas. Šiame skyriuje aprašoma, kaip prijungti variklį prie aplikacijos ir pradinės sąrankos, taip pat kaip susieti variklį su aplikacijos teikiamu `User` klasės, kad būtų galima suteikti straipsniams ir komentarams variklyje priklausomybę.

### Variklio prijungimas

Pirmiausia, variklis turi būti nurodytas aplikacijos `Gemfile`. Jei neturite tinkamos aplikacijos, kurioje tai išbandyti, sukurkite ją naudodami `rails new` komandą už variklio katalogo ribų, pavyzdžiui:

```bash
$ rails new unicorn
```

Paprastai, variklio nurodymas `Gemfile` būtų atliekamas kaip įprastas, kasdieninis perlaidas.

```ruby
gem 'devise'
```

Tačiau, nes kuriate `blorgh` variklį savo kompiuteryje, turėsite nurodyti `:path` parinktį savo `Gemfile`:

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

Tada paleiskite `bundle`, kad įdiegtumėte perlaidą.

Kaip jau buvo aprašyta anksčiau, įdedant perlaidą į `Gemfile`, ji bus įkeliama, kai įkeliamas „Rails“. Ji pirmiausia reikalauja `lib/blorgh.rb` iš variklio, tada `lib/blorgh/engine.rb`, kuris yra failas, apibrėžiantis pagrindines variklio funkcionalumo dalis.

Kad variklio funkcionalumas būtų pasiekiamas iš aplikacijos, jis turi būti prijungtas prie aplikacijos `config/routes.rb` failo:

```ruby
mount Blorgh::Engine, at: "/blog"
```

Ši eilutė prijungs variklį prie aplikacijos `/blog` maršruto. Jis bus pasiekiamas adresu `http://localhost:3000/blog`, kai aplikacija veiks su `bin/rails server`.

Pastaba: Kiti varikliai, pvz., „Devise“, tai padaro šiek tiek kitaip, nurodydami jums nurodyti pasirinktinius pagalbininkus (pvz., `devise_for`) maršrutuose. Šie pagalbininkai daro tiksliai tą patį, prijungdami variklio funkcionalumo dalis prie iš anksto apibrėžto kelio, kuris gali būti tinkinamas.
### Variklio nustatymas

Variklyje yra migracijos `blorgh_articles` ir `blorgh_comments` lentelėms, kurios turi būti sukurtos programos duomenų bazėje, kad variklio modeliai galėtų jas teisingai užklausti. Norėdami nukopijuoti šias migracijas į programą, paleiskite šią komandą iš programos šaknies:

```bash
$ bin/rails blorgh:install:migrations
```

Jei turite kelis variklius, kuriems reikia nukopijuoti migracijas, naudokite `railties:install:migrations` vietoj to:

```bash
$ bin/rails railties:install:migrations
```

Galite nurodyti pasirinktinį migracijų šaltinio variklyje kelią, nurodydami MIGRATIONS_PATH.

```bash
$ bin/rails railties:install:migrations MIGRATIONS_PATH=db_blourgh
```

Jei turite kelias duomenų bazes, taip pat galite nurodyti tikslinę duomenų bazę, nurodydami DATABASE.

```bash
$ bin/rails railties:install:migrations DATABASE=animals
```

Ši komanda, paleista pirmą kartą, nukopijuos visas migracijas iš variklio. Paleidus antrą kartą, ji nukopijuos tik migracijas, kurios dar nebuvo nukopijuotos. Pirmojo paleidimo metu ši komanda išves kažką panašaus į tai:

```
Nukopijuota migracija [timestamp_1]_create_blorgh_articles.blorgh.rb iš blorgh
Nukopijuota migracija [timestamp_2]_create_blorgh_comments.blorgh.rb iš blorgh
```

Pirmasis laiko žymėjimas (`[timestamp_1]`) bus dabartinis laikas, o antrasis laiko žymėjimas (`[timestamp_2]`) bus dabartinis laikas plius viena sekundė. Tai padaryta tam, kad variklio migracijos būtų vykdomos po bet kokių esamų programos migracijų.

Norėdami paleisti šias migracijas kontekste programos, tiesiog paleiskite `bin/rails db:migrate`. Pasiekus variklį per `http://localhost:3000/blog`, straipsniai bus tušti. Tai yra dėl to, kad lentele, sukurta programoje, skiriasi nuo lenteles, sukurtoje variklyje. Drąsiai žaiskite su naujai prijungtu varikliu. Pastebėsite, kad jis yra tas pats, kaip ir kai jis buvo tik variklis.

Jei norite paleisti migracijas tik iš vieno variklio, tai galite padaryti nurodydami `SCOPE`:

```bash
$ bin/rails db:migrate SCOPE=blorgh
```

Tai gali būti naudinga, jei norite atšaukti variklio migracijas prieš jį pašalinant. Norėdami atšaukti visas migracijas iš blorgh variklio, galite paleisti kodą, panašų į šį:

```bash
$ bin/rails db:migrate SCOPE=blorgh VERSION=0
```

### Naudodami klasę, pateiktą programoje

#### Naudodami modelį, pateiktą programoje

Kuriant variklį, gali prireikti naudoti konkretesnes klases iš programos, kad būtų užtikrintas ryšys tarp variklio ir programos dalių. Pavyzdžiui, `blorgh` variklyje straipsniai ir komentarai gali turėti autorių.

Tipinė programa gali turėti `User` klasę, kuri būtų naudojama autoriams atstovauti straipsniui ar komentarui. Tačiau gali būti atvejų, kai programa šią klasę vadina kitaip, pvz., `Person`. Dėl šios priežasties variklis neturėtų standartiškai įkoduoti asociacijų tik tam tikrai `User` klasei.

Norint išlaikyti paprastumą šiuo atveju, programoje turėsime klasę, vadinamą `User`, kuri atstovaus programos vartotojams (apie tai kalbėsime vėliau, kaip tai padaryti konfigūruojama). Ją galima generuoti naudojant šią komandą programoje:

```bash
$ bin/rails generate model user name:string
```

Čia reikia paleisti `bin/rails db:migrate` komandą, kad užtikrintumėte, jog programa turi `users` lentelę ateities naudojimui.

Taip pat, siekiant išlaikyti paprastumą, straipsnių formoje bus naujas teksto laukas, vadinamas `author_name`, kuriame vartotojai gali įvesti savo vardą. Tada variklis šį vardą paims ir jį arba sukurs naują `User` objektą, arba ras jau esantį tokiu pačiu vardu. Tada variklis susieja straipsnį su rastu arba sukurtu `User` objektu.

Pirmiausia, `author_name` teksto laukas turi būti pridėtas prie `app/views/blorgh/articles/_form.html.erb` dalinio variklyje. Tai galima pridėti virš `title` lauko šiuo kodu:

```html+erb
<div class="field">
  <%= form.label :author_name %><br>
  <%= form.text_field :author_name %>
</div>
```

Toliau turime atnaujinti `Blorgh::ArticlesController#article_params` metodą, kad leistų naują formos parametrą:

```ruby
def article_params
  params.require(:article).permit(:title, :text, :author_name)
end
```

Tada `Blorgh::Article` modelyje turėtų būti kodas, kuris konvertuoja `author_name` lauką į tikrą `User` objektą ir susieja jį kaip straipsnio `author`, prieš straipsnis išsaugomas. Taip pat reikės nustatyti `attr_accessor` šiam laukui, kad būtų apibrėžti jo nustatymo ir gavimo metodai.

Tam visam reikės pridėti `attr_accessor` `author_name`, asociaciją su autoriu ir `before_validation` iškvietimą į `app/models/blorgh/article.rb`. Kol kas asociacija su autoriu bus standartiškai įkoduota į `User` klasę.
```ruby
attr_accessor :author_name
belongs_to :author, class_name: "User"

before_validation :set_author

private
  def set_author
    self.author = User.find_or_create_by(name: author_name)
  end
```

Nustatant `author` asociacijos objektą su `User` klase, užtikrinamas ryšys tarp variklio ir programos. Turi būti būdas susieti įrašus `blorgh_articles` lentelėje su įrašais `users` lentelėje. Kadangi asociacija vadinama `author`, `blorgh_articles` lentelėje turi būti pridėta `author_id` stulpelis.

Norint sukurti šį naują stulpelį, paleiskite šią komandą variklyje:

```bash
$ bin/rails generate migration add_author_id_to_blorgh_articles author_id:integer
```

PASTABA: Dėl migracijos pavadinimo ir stulpelio specifikacijos po jo, „Rails“ automatiškai žinos, kad norite pridėti stulpelį į konkretų lentelę ir įrašys tai į migraciją už jus. Jums nereikia jam nieko daugiau pasakyti.

Šią migraciją reikia paleisti programoje. Tam ją reikia nukopijuoti naudojant šią komandą:

```bash
$ bin/rails blorgh:install:migrations
```

Pastebėkite, kad čia buvo nukopijuota tik _viena_ migracija. Tai todėl, kad pirmą kartą paleidus šią komandą buvo nukopijuotos pirmos dvi migracijos.

```
PASTABA Migracija [timestamp]_create_blorgh_articles.blorgh.rb iš blorgh buvo praleista. Migracija su tuo pačiu pavadinimu jau egzistuoja.
PASTABA Migracija [timestamp]_create_blorgh_comments.blorgh.rb iš blorgh buvo praleista. Migracija su tuo pačiu pavadinimu jau egzistuoja.
Nukopijuota migracija [timestamp]_add_author_id_to_blorgh_articles.blorgh.rb iš blorgh
```

Paleiskite migraciją naudodami:

```bash
$ bin/rails db:migrate
```

Dabar, turint visus reikiamus elementus, vyks veiksmas, kuris susieja autorių - kurį atstovauja įrašas `users` lentelėje - su straipsniu, kurį atstovauja variklio `blorgh_articles` lentelė.

Galų gale, straipsnio puslapyje turėtų būti rodomas autoriaus vardas. Į `app/views/blorgh/articles/show.html.erb` failą įterpkite šį kodą virš „Title“ išvesties:

```html+erb
<p>
  <b>Author:</b>
  <%= @article.author.name %>
</p>
```

#### Naudoti programos teikiamą valdiklį

Kadangi „Rails“ valdikliai paprastai bendrina kodą, pvz., autentifikacijai ir sesijos kintamųjų naudojimui, pagal nutylėjimą jie paveldi iš `ApplicationController`. Tačiau „Rails“ varikliai yra skirti veikti nepriklausomai nuo pagrindinės programos, todėl kiekvienas variklis gauna savo ribotą `ApplicationController`. Šis vardų erdvė užkerta kelią kodo susidūrimams, tačiau dažnai variklio valdikliai turi prieigą prie pagrindinės programos `ApplicationController` metodų. Paprastas būdas suteikti šią prieigą yra pakeisti variklio ribotą `ApplicationController`, kad jis paveldėtų pagrindinės programos `ApplicationController`. Mūsų „Blorgh“ varikliui tai būtų padaryta pakeičiant `app/controllers/blorgh/application_controller.rb` failą į šią formą:

```ruby
module Blorgh
  class ApplicationController < ::ApplicationController
  end
end
```

Pagal nutylėjimą variklio valdikliai paveldi iš `Blorgh::ApplicationController`. Taigi, po šio pakeitimo jie turės prieigą prie pagrindinės programos `ApplicationController`, tarsi jie būtų dalis pagrindinės programos.

Šis pakeitimas reikalauja, kad variklis būtų paleistas iš „Rails“ programos, turinčios `ApplicationController`.

### Variklio konfigūravimas

Šiame skyriuje aprašoma, kaip padaryti `User` klasę konfigūruojamą, o po to pateikiami bendri variklio konfigūravimo patarimai.

#### Konfigūracijos nustatymų nustatymas programoje

Kitas žingsnis yra padaryti programoje atstovaujančią `User` klasę konfigūruojamą varikliui. Tai yra todėl, kad ši klasė gali ne visada būti `User`, kaip jau buvo paaiškinta. Norint padaryti šį nustatymą konfigūruojamą, variklyje bus nustatymas, vadinamas `author_class`, kuris bus naudojamas nurodyti, kuri klasė atstovauja vartotojams programoje.

Norint apibrėžti šį konfigūracijos nustatymą, variklio `Blorgh` modulyje reikia naudoti `mattr_accessor`. Į `lib/blorgh.rb` failą variklyje įterpkite šią eilutę:

```ruby
mattr_accessor :author_class
```

Šis metodas veikia kaip jo brolių, `attr_accessor` ir `cattr_accessor`, bet suteikia nustatymo ir gavimo metodą modulyje su nurodytu pavadinimu. Norint jį naudoti, jį reikia paminėti naudojant `Blorgh.author_class`.

Kitas žingsnis yra perjungti `Blorgh::Article` modelį į šį naują nustatymą. Pakeiskite `belongs_to` asociaciją šiame modele (`app/models/blorgh/article.rb`) į šį kodą:

```ruby
belongs_to :author, class_name: Blorgh.author_class
```

`set_author` metodas `Blorgh::Article` modelyje taip pat turėtų naudoti šią klasę:

```ruby
self.author = Blorgh.author_class.constantize.find_or_create_by(name: author_name)
```

Norint išvengti nuolatinio `constantize` kvietimo `author_class` rezultate, galima perrašyti `author_class` gavimo metodą `Blorgh` modulyje `lib/blorgh.rb` faile, kad visada būtų iškviečiamas `constantize` su išsaugota reikšme prieš grąžinant rezultatą:
```ruby
def self.author_class
  @@author_class.constantize
end
```

Tai paverstų aukščiau pateiktą kodą `set_author` į tai:

```ruby
self.author = Blorgh.author_class.find_or_create_by(name: author_name)
```

Rezultatas būtų šiek tiek trumpesnis ir aiškesnis savo veikimo požiūriu. `author_class` metodas visada turėtų grąžinti `Class` objektą.

Kadangi pakeitėme `author_class` metodą, kad jis grąžintų `Class` objektą vietoje `String`, taip pat turime modifikuoti `belongs_to` apibrėžimą `Blorgh::Article` modelyje:

```ruby
belongs_to :author, class_name: Blorgh.author_class.to_s
```

Kad nustatytumėte šią konfigūracijos nuostatą programoje, reikėtų naudoti inicializatorių. Naudojant inicializatorių, konfigūracija bus nustatyta prieš pradedant programą ir iškvies variklio modelius, kurie gali priklausyti nuo šios konfigūracijos nuostatos.

Sukurkite naują inicializatorių `config/initializers/blorgh.rb` programoje, kurioje įdiegtas `blorgh` variklis, ir įrašykite į jį šią informaciją:

```ruby
Blorgh.author_class = "User"
```

ĮSPĖJIMAS: Labai svarbu čia naudoti `String` klasės versiją, o ne patį klasę. Jei naudotumėte klasę, „Rails“ bandytų įkelti tą klasę ir tada nuorodą į susijusią lentelę. Tai gali sukelti problemų, jei lentelė dar neegzistuoja. Todėl turėtumėte naudoti `String` ir tada konvertuoti į klasę, naudojant `constantize` variklyje vėliau.

Bandykite sukurti naują straipsnį. Matysite, kad tai veikia taip pat kaip ir anksčiau, tik šį kartą variklis naudoja konfigūracijos nuostatą `config/initializers/blorgh.rb`, kad sužinotų, kokia yra klasė.

Dabar nėra griežtų priklausomybių nuo to, kokia yra klasė, tik nuo to, kokios turi būti klasės API. Variklis tiesiog reikalauja, kad ši klasė apibrėžtų `find_or_create_by` metodą, kuris grąžintų objektą tos klasės, kuris bus susietas su straipsniu, kai jis bus sukurtas. Žinoma, šis objektas turėtų turėti kažkokį identifikatorių, pagal kurį jį galima būtų paminėti.

#### Bendra variklio konfigūracija

Variklyje gali atsirasti laikas, kai norėsite naudoti dalykus, tokius kaip inicializatoriai, internacionalizacija ar kitos konfigūracijos parinktys. Puikūs naujienos yra tai, kad tai visiškai įmanoma, nes „Rails“ variklis dalinasi daug tokių pačių funkcijų kaip ir „Rails“ programa. Iš tikrųjų, „Rails“ programos funkcionalumas iš tikrųjų yra daugiau nei tai, ką teikia varikliai!

Jei norite naudoti inicializatorių - kodą, kuris turėtų būti paleidžiamas prieš įkeliant variklį - vieta jam yra `config/initializers` aplanke. Šio katalogo funkcionalumas paaiškinamas [Inicializatorių skyriuje](configuring.html#initializers) Konfigūravimo vadove ir veikia taip pat kaip ir `config/initializers` katalogas programoje. Taip pat galioja ir jei norite naudoti standartinį inicializatorių.

Lokalėms tiesiog įdėkite lokalės failus į `config/locales` aplanką, taip pat kaip ir programoje.

Variklio testavimas
-------------------

Kai generuojamas variklis, jame yra sukurtas mažesnis „dummy“ programa, esanti viduje `test/dummy`. Ši programa naudojama kaip montavimo taškas varikliui, kad būtų labai paprasta testuoti variklį. Galite išplėsti šią programą, generuodami kontrolerius, modelius ar vaizdus iš šio katalogo ir tada naudoti juos savo variklio testavimui.

`test` katalogą reikėtų traktuoti kaip įprastą „Rails“ testavimo aplinką, leidžiančią atlikti vienetinius, funkcinius ir integracinius testus.

### Funkciniai testai

Reikėtų atsižvelgti į tai, kad rašant funkcinius testus, testai bus vykdomi programoje - `test/dummy` programoje - o ne jūsų variklyje. Tai susiję su testavimo aplinkos sąranka; variklis reikalauja programos kaip pagrindo testuoti pagrindinę savo funkcionalumą, ypač kontrolerius. Tai reiškia, kad jei norėtumėte padaryti įprastą `GET` į kontrolerį kontrolerio funkciniame teste, panašiai kaip čia:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def test_index
      get foos_url
      # ...
    end
  end
end
```

Tai gali neveikti teisingai. Tai yra dėl to, kad programa nežino, kaip nukreipti šiuos užklausimus į variklį, nebent aiškiai pasakytumėte **kaip**. Tam reikia nustatyti `@routes` kintamąjį, kuris yra variklio maršrutų rinkinio, savo sąrankos kode:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_index
      get foos_url
      # ...
    end
  end
end
```
Tai praneša programai, kad vis tiek norite atlikti `GET` užklausą į šio valdiklio `index` veiksmą, bet norite naudoti variklio maršrutą, o ne programos.

Tai taip pat užtikrina, kad variklio URL pagalbininkai veiktų kaip tikimasi jūsų testuose.

Variklio funkcionalumo gerinimas
------------------------------

Šiame skyriuje paaiškinama, kaip pridėti ir (arba) perrašyti variklio MVC funkcionalumą pagrindinėje „Rails“ programoje.

### Perrašyti modelius ir valdiklius

Variklio modelius ir valdiklius galima atidaryti pagrindinėje programoje, kad juos išplėstų ar dekoruotų.

Perrašymai gali būti organizuojami atskirame kataloge `app/overrides`, kuris yra ignoruojamas automatinio įkėlimo metu, ir įkraunamas „to_prepare“ atgaliniame iškvietime:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        load override
      end
    end
  end
end
```

#### Atidaryti esamus klases naudojant `class_eval`

Pavyzdžiui, norint perrašyti variklio modelį

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    # ...
  end
end
```

tiesiog sukuriama byla, kuri _atidaro_ tą klasę:

```ruby
# MyApp/app/overrides/models/blorgh/article_override.rb
Blorgh::Article.class_eval do
  # ...
end
```

Labai svarbu, kad perrašymas _atidarytų_ klasę ar modulį. Naudoti `class` ar `module` raktažodžius apibrėžtų juos, jei jie dar nebuvo atmintyje, kas būtų neteisinga, nes apibrėžimas yra variklyje. Naudodami `class_eval`, kaip parodyta aukščiau, užtikrinsite, kad atidarote.

#### Atidaryti esamus klases naudojant ActiveSupport::Concern

Naudoti `Class#class_eval` yra puikus paprastų pakeitimų atveju, bet sudėtingesniems klasės modifikacijoms galbūt norėsite apsvarstyti [`ActiveSupport::Concern`](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html) naudojimą.
ActiveSupport::Concern valdo priklausomų modulių ir klasių įkėlimo tvarką vykdymo metu, leisdama jums žymiai moduliarizuoti kodą.

**Pridedant** `Article#time_since_created` ir **perrašant** `Article#summary`:

```ruby
# MyApp/app/models/blorgh/article.rb

class Blorgh::Article < ApplicationRecord
  include Blorgh::Concerns::Models::Article

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    include Blorgh::Concerns::Models::Article
  end
end
```

```ruby
# Blorgh/lib/concerns/models/article.rb

module Blorgh::Concerns::Models::Article
  extend ActiveSupport::Concern

  # `included do` causes the block to be evaluated in the context
  # in which the module is included (i.e. Blorgh::Article),
  # rather than in the module itself.
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_validation :set_author

    private
      def set_author
        self.author = User.find_or_create_by(name: author_name)
      end
  end

  def summary
    "#{title}"
  end

  module ClassMethods
    def some_class_method
      'some class method string'
    end
  end
end
```

### Automatinis įkėlimas ir varikliai

Daugiau informacijos apie automatinį įkėlimą ir variklius rasite [Automatinio įkėlimo ir konstantų perkrovos](autoloading_and_reloading_constants.html#autoloading-and-engines) vadove.

### Perrašyti rodinius

Kai „Rails“ ieško rodinio, kurį reikia atvaizduoti, jis pirmiausia pažiūrės į programos `app/views` katalogą. Jei jis jo ten neranda, jis patikrins visų variklių `app/views` katalogus, turinčius šį katalogą.

Kai programa prašo atvaizduoti `Blorgh::ArticlesController` indekso veiksmo rodinį, ji pirmiausia ieškos kelio `app/views/blorgh/articles/index.html.erb` programoje. Jei jo neranda, ji pažiūrės variklyje.

Jūs galite perrašyti šį rodinį programoje, tiesiog sukurdami naują bylą `app/views/blorgh/articles/index.html.erb`. Tada galite visiškai pakeisti tai, ką šis rodinys paprastai išvestų.

Pabandykite tai dabar, sukurdami naują bylą `app/views/blorgh/articles/index.html.erb` ir į ją įdėkite šį turinį:

```html+erb
<h1>Articles</h1>
<%= link_to "New Article", new_article_path %>
<% @articles.each do |article| %>
  <h2><%= article.title %></h2>
  <small>By <%= article.author %></small>
  <%= simple_format(article.text) %>
  <hr>
<% end %>
```

### Maršrutai

Pagal nutylėjimą variklio maršrutai yra izoliuoti nuo programos. Tai padaro `isolate_namespace` iškvietimas `Engine` klasėje. Tai iš esmės reiškia, kad programa ir jos varikliai gali turėti identiškai pavadintus maršrutus ir jie nesikibs.

Variklio maršrutai yra nubraižomi `Engine` klasėje `config/routes.rb`, taip:

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

Turint izoliuotus maršrutus, jei norite nuorodą į variklio sritį iš programos, turėsite naudoti variklio maršruto peržiūros metodą. Paprastų maršruto metodų, pvz., `articles_path`, iškvietimai gali patekti į nepageidaujamas vietas, jei tiek programa, tiek variklis turi tokią pagalbininko apibrėžimą.

Pavyzdžiui, šis pavyzdys eitų į programos `articles_path`, jei šablonas būtų atvaizduojamas iš programos, arba į variklio `articles_path`, jei jis būtų atvaizduojamas iš variklio:
```erb
<%= link_to "Blog straipsniai", articles_path %>
```

Norint, kad šis maršrutas visada naudotų variklio `articles_path` maršruto pagalbinės
metodo, turime iškviesti metodą variklio pavadinimu, kuris dalinasi tuo pačiu vardu
kaip variklis.

```erb
<%= link_to "Blog straipsniai", blorgh.articles_path %>
```

Jei norite panašiu būdu nuorodą į aplikaciją variklyje, naudokite
`main_app` pagalbininką:

```erb
<%= link_to "Pagrindinis", main_app.root_path %>
```

Jei tai būtų naudojama variklyje, tai **visada** eitų į
aplikacijos šaknį. Jei paliktumėte `main_app` "maršruto pagalbininko"
metodo iškvietimą, tai galėtų potencialiai eiti į variklio ar aplikacijos šaknį,
priklausomai nuo to, iš kurio buvo iškviestas.

Jei šablone, kuris yra sugeneruotas iš variklio, bandoma naudoti vieną iš
aplikacijos maršruto pagalbinių metodus, tai gali sukelti neapibrėžtą metodo iškvietimą.
Jei susiduriate su tokia problema, įsitikinkite, kad nesistengiate iškviesti
aplikacijos maršruto metodus be `main_app` prefikso iš variklio viduje.

### Turtai

Turtai variklyje veikia taip pat kaip ir pilnoje aplikacijoje. Kadangi
variklio klasė paveldi `Rails::Engine`, aplikacija žinos, kad
turėtų ieškoti turtų variklio `app/assets` ir `lib/assets` kataloguose.

Kaip ir visi kiti variklio komponentai, turai turėtų būti vardų erdvėje.
Tai reiškia, kad jei turite turą pavadinimu `style.css`, jis turėtų būti padėtas
`app/assets/stylesheets/[variklio pavadinimas]/style.css`, o ne
`app/assets/stylesheets/style.css`. Jei šis turtas neturi vardų erdvės, yra
galimybė, kad pagrindinė aplikacija gali turėti identiškai pavadinimą turą,
tokiu atveju aplikacijos turtas turėtų būti pirmenybė ir variklio turas
būtų ignoruojamas.

Įsivaizduokite, kad turite turą, esantį
`app/assets/stylesheets/blorgh/style.css`. Norėdami įtraukti šį turą į
aplikaciją, tiesiog naudokite `stylesheet_link_tag` ir nurodykite turą, tarsi jis
būtų variklyje:

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

Taip pat galite nurodyti šiuos turus kaip kitų turų priklausomybes, naudodami Turtų
Srauto reikalavimo deklaracijas apdorotuose failuose:

```css
/*
 *= require blorgh/style
 */
```

INFO. Atminkite, kad norėdami naudoti kalbas kaip Sass ar CoffeeScript,
turėtumėte pridėti atitinkamą biblioteką į savo variklio `.gemspec` failą.

### Atskiri turtai ir išankstinis kompiliavimas

Yra situacijų, kai pagrindinė aplikacija nereikalauja variklio turto.
Pavyzdžiui, sakykime, kad sukūrėte administravimo funkcionalumą,
kuris egzistuoja tik jūsų varikliui. Tokiu atveju pagrindinei aplikacijai nereikia
reikalauti `admin.css` ar `admin.js`. Tik variklio administravimo išdėstymui reikia
šių turų. Nėra prasmės pagrindinei aplikacijai įtraukti
`"blorgh/admin.css"` į jos stilių lapus. Tokioje situacijoje turėtumėte
aiškiai apibrėžti šiuos turus išankstiniam kompiliavimui. Tai pasako Sprockets pridėti
variklio turus, kai yra paleidžiamas `bin/rails assets:precompile`.

Galite apibrėžti turus išankstiniam kompiliavimui `engine.rb`:

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile += %w( admin.js admin.css )
end
```

Daugiau informacijos skaitykite [Turtų Srauto vadove](asset_pipeline.html).

### Kiti priklausomybės nuo gemo

Gemo priklausomybės variklyje turėtų būti nurodytos `.gemspec` faile
variklio šakniniame kataloge. Priežastis yra ta, kad variklis gali būti įdiegtas kaip
gemas. Jei priklausomybės būtų nurodytos `Gemfile`, jos nebūtų
pripažįstamos kaip tradicinio gemo diegimo ir todėl jos nebūtų įdiegtos,
sukeldamos variklio veikimo sutrikimus.

Norėdami nurodyti priklausomybę, kuri turėtų būti įdiegta kartu su varikliu per
tradicinį `gem install`, nurodykite ją `.gemspec` faile variklyje
`Gem::Specification` bloke:

```ruby
s.add_dependency "moo"
```

Norėdami nurodyti priklausomybę, kuri turėtų būti įdiegta tik kaip vystymo
priklausomybė aplikacijos, nurodykite ją taip:

```ruby
s.add_development_dependency "moo"
```

Abu šios rūšies priklausomybės bus įdiegtos, kai bus paleistas `bundle install`
aplikacijoje. Gemui skirtos vystymo priklausomybės bus naudojamos tik
kai vykdomas variklio vystymas ir testai.

Atkreipkite dėmesį, jei norite iš karto reikalauti priklausomybių, kai yra
reikalaujama variklio, turėtumėte reikalauti jų prieš variklio inicializavimą. Pavyzdžiui:

```ruby
require "other_engine/engine"
require "yet_another_engine/engine"

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```

Įkėlimo ir konfigūracijos kabliukai
----------------------------

Rails kodas dažnai gali būti paminėtas aplikacijos įkėlimo metu. Rails yra atsakingas už šių karkasų įkėlimo tvarką, todėl įkeliant karkasus, pvz., `ActiveRecord::Base`, per anksti, pažeidžiate neaiškų sutartį, kurią jūsų aplikacija turi su Rails. Be to, įkeliant kodą, pvz., `ActiveRecord::Base`, paleidus aplikaciją, įkeliate visus karkasus, kurie gali sulėtinti paleidimo laiką ir sukelti konfliktus su įkėlimo tvarka ir aplikacijos paleidimu.
Įkrovimo ir konfigūracijos kablys yra API, leidžiantis jums įsikišti į šį inicializavimo procesą, nesutrikdant įkrovos sutarties su „Rails“. Tai taip pat sumažins paleidimo našumo degradaciją ir išvengs konfliktų.

### Vengti įkrauti „Rails“ karkasus

Kadangi „Ruby“ yra dinaminė kalba, tam tikras kodas sukelia įvairių „Rails“ karkasų įkrovą. Pavyzdžiui, pažiūrėkite į šį fragmentą:

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

Šis fragmentas reiškia, kad įkeliant šį failą jis susidurs su `ActiveRecord::Base`. Šis susidūrimas verčia „Ruby“ ieškoti tos konstantos apibrėžimo ir ją reikalauti. Tai sukelia viso „Active Record“ karkaso įkrovą paleidimo metu.

`ActiveSupport.on_load` yra mechanizmas, kurį galima naudoti, kad kodas būtų įkrautas tik tada, kai jis iš tikrųjų reikalingas. Pavyzdžiui, aukščiau pateiktas fragmentas gali būti pakeistas į:

```ruby
ActiveSupport.on_load(:active_record) do
  include MyActiveRecordHelper
end
```

Šis naujas fragmentas įtrauks `MyActiveRecordHelper` tik tada, kai bus įkeltas `ActiveRecord::Base`.

### Kada yra kviečiami kablys?

„Rails“ karkase šie kablys yra kviečiami, kai įkeliamas konkretus biblioteka. Pavyzdžiui, įkeliant `ActionController::Base`, kviečiamas `:action_controller_base` kablys. Tai reiškia, kad visi `ActiveSupport.on_load` kvietimai su `:action_controller_base` kabliukais bus kviečiami `ActionController::Base` kontekste (tai reiškia, kad `self` bus `ActionController::Base`).

### Kodas keičiantis naudojant įkrovimo kablys

Kodui keisti paprastai nėra sudėtinga. Jei turite kodą, kuris kreipiasi į „Rails“ karkasą, pvz., `ActiveRecord::Base`, galite apgaubti tą kodą įkrovimo kabliu.

**Kvietimų į `include` keitimas**

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

tampa

```ruby
ActiveSupport.on_load(:active_record) do
  # čia self atitinka ActiveRecord::Base,
  # todėl galime iškviesti .include
  include MyActiveRecordHelper
end
```

**Kvietimų į `prepend` keitimas**

```ruby
ActionController::Base.prepend(MyActionControllerHelper)
```

tampa

```ruby
ActiveSupport.on_load(:action_controller_base) do
  # čia self atitinka ActionController::Base,
  # todėl galime iškviesti .prepend
  prepend MyActionControllerHelper
end
```

**Kvietimų į klasės metodus keitimas**

```ruby
ActiveRecord::Base.include_root_in_json = true
```

tampa

```ruby
ActiveSupport.on_load(:active_record) do
  # čia self atitinka ActiveRecord::Base
  self.include_root_in_json = true
end
```

### Galimi įkrovimo kabliai

Tai yra įkrovimo kabliai, kuriuos galite naudoti savo kode. Norėdami įsikišti į vienos iš šių klasės inicializavimo procesą, naudokite prieinamą kabliuką.

| Klasė                                | Kablys                              |
| -------------------------------------| ------------------------------------ |
| `ActionCable`                        | `action_cable`                       |
| `ActionCable::Channel::Base`         | `action_cable_channel`               |
| `ActionCable::Connection::Base`      | `action_cable_connection`            |
| `ActionCable::Connection::TestCase`  | `action_cable_connection_test_case`  |
| `ActionController::API`              | `action_controller_api`              |
| `ActionController::API`              | `action_controller`                  |
| `ActionController::Base`             | `action_controller_base`             |
| `ActionController::Base`             | `action_controller`                  |
| `ActionController::TestCase`         | `action_controller_test_case`        |
| `ActionDispatch::IntegrationTest`    | `action_dispatch_integration_test`   |
| `ActionDispatch::Response`           | `action_dispatch_response`           |
| `ActionDispatch::Request`            | `action_dispatch_request`            |
| `ActionDispatch::SystemTestCase`     | `action_dispatch_system_test_case`   |
| `ActionMailbox::Base`                | `action_mailbox`                     |
| `ActionMailbox::InboundEmail`        | `action_mailbox_inbound_email`       |
| `ActionMailbox::Record`              | `action_mailbox_record`              |
| `ActionMailbox::TestCase`            | `action_mailbox_test_case`           |
| `ActionMailer::Base`                 | `action_mailer`                      |
| `ActionMailer::TestCase`             | `action_mailer_test_case`            |
| `ActionText::Content`                | `action_text_content`                |
| `ActionText::Record`                 | `action_text_record`                 |
| `ActionText::RichText`               | `action_text_rich_text`              |
| `ActionText::EncryptedRichText`      | `action_text_encrypted_rich_text`    |
| `ActionView::Base`                   | `action_view`                        |
| `ActionView::TestCase`               | `action_view_test_case`              |
| `ActiveJob::Base`                    | `active_job`                         |
| `ActiveJob::TestCase`                | `active_job_test_case`               |
| `ActiveRecord::Base`                 | `active_record`                      |
| `ActiveRecord::TestFixtures`         | `active_record_fixtures`             |
| `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter`    | `active_record_postgresqladapter`    |
| `ActiveRecord::ConnectionAdapters::Mysql2Adapter`        | `active_record_mysql2adapter`        |
| `ActiveRecord::ConnectionAdapters::TrilogyAdapter`       | `active_record_trilogyadapter`       |
| `ActiveRecord::ConnectionAdapters::SQLite3Adapter`       | `active_record_sqlite3adapter`       |
| `ActiveStorage::Attachment`          | `active_storage_attachment`          |
| `ActiveStorage::VariantRecord`       | `active_storage_variant_record`      |
| `ActiveStorage::Blob`                | `active_storage_blob`                |
| `ActiveStorage::Record`              | `active_storage_record`              |
| `ActiveSupport::TestCase`            | `active_support_test_case`           |
| `i18n`                               | `i18n`                               |

### Galimi konfigūracijos kabliai

Konfigūracijos kabliai neįsikiša į jokį konkretų karkasą, bet veikia visos programos kontekste.

| Kablys                 | Naudojimo atvejis                                                                 |
| ---------------------- | --------------------------------------------------------------------------------- |
| `before_configuration` | Pirmas konfigūruojamas blokas, kuris bus paleistas. Kviečiamas prieš paleidžiant bet kokius inicializatorius.           |
| `before_initialize`    | Antras konfigūruojamas blokas, kuris bus paleistas. Kviečiamas prieš inicializuojant karkasus.             |
| `before_eager_load`    | Trečias konfigūruojamas blokas, kuris bus paleistas. Nevykdomas, jei [`config.eager_load`][] nustatytas kaip `false`. |
| `after_initialize`     | Paskutinis konfigūruojamas blokas, kuris bus paleistas. Kviečiamas po karkasų inicializavimo.                |

Konfigūracijos kablius galima iškviesti „Engine“ klasėje.

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    config.before_configuration do
      puts 'Aš esu kviečiamas prieš bet kokius inicializatorius'
    end
  end
end
```
[`config.eager_load`]: configuring.html#config-eager-load
