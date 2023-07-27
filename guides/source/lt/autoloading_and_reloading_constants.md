**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f53b3a12c263256fbbe154cfc8b2f4d
Automašinų įkėlimas ir perkrovimas
===================================

Šiame vadove aprašoma, kaip veikia automatinis įkėlimas ir perkrovimas „zeitwerk“ režimu.

Po šio vadovo perskaitymo žinosite:

* Susijusią „Rails“ konfigūraciją
* Projekto struktūrą
* Automatinį įkėlimą, perkrovimą ir ankstyvąjį įkėlimą
* Vienos lentelės paveldėjimą
* Ir daugiau

--------------------------------------------------------------------------------

Įvadas
-------

INFO. Šiame vadove aprašomas automatinis įkėlimas, perkrovimas ir ankstyvasis įkėlimas „Rails“ programose.

Paprastoje „Ruby“ programoje išreikštinai įkeliate failus, kurie apibrėžia klases ir modulius, kuriuos norite naudoti. Pavyzdžiui, šis valdiklis kreipiasi į „ApplicationController“ ir „Post“, ir įprastai jūs juos įkeliate naudodami „require“ iškvietimus:

```ruby
# NEDARYKITE TAIP.
require "application_controller"
require "post"
# NEDARYKITE TAIP.

class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Tačiau „Rails“ programose tai netaikoma, nes programos klasės ir moduliai yra prieinami visur be „require“ iškvietimų:

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

„Rails“ automatiškai įkelia juos už jus, jei reikia. Tai įmanoma dėka keleto [Zeitwerk](https://github.com/fxn/zeitwerk) įkėlimo priemonių, kurias „Rails“ nustato už jus, ir kurios suteikia automatinį įkėlimą, perkrovimą ir ankstyvąjį įkėlimą.

Kita vertus, šios įkėlimo priemonės nieko kito nevaldo. Ypač jos nevaldo „Ruby“ standartinės bibliotekos, priklausomybių nuo paketų, pačių „Rails“ komponentų ar net (pagal numatytuosius nustatymus) taikomojo „lib“ katalogo. Tokį kodą reikia įkelti kaip įprasta.


Projekto struktūra
------------------

„Rails“ programoje failų pavadinimai turi atitikti jų apibrėžiamus konstantas, o katalogai veikia kaip vardų erdvės.

Pavyzdžiui, failas „app/helpers/users_helper.rb“ turi apibrėžti „UsersHelper“, o failas „app/controllers/admin/payments_controller.rb“ turi apibrėžti „Admin::PaymentsController“.

Pagal numatytuosius nustatymus „Rails“ konfigūruoja „Zeitwerk“ taip, kad failų pavadinimai būtų suformuojami naudojant „String#camelize“. Pavyzdžiui, tikimasi, kad „app/controllers/users_controller.rb“ apibrėžia konstantą „UsersController“, nes tai grąžina „"users_controller".camelize“.

Skyriuje „Tinkinimas inflekcijos“ žemiau aprašomos būdai, kaip pakeisti šį numatytąjį nustatymą.

Prašome, peržiūrėkite [Zeitwerk dokumentaciją](https://github.com/fxn/zeitwerk#file-structure) norėdami gauti daugiau informacijos.

config.autoload_paths
---------------------

Mes vadiname programos katalogų sąrašą, kurių turinys turi būti automatiškai įkeliamas ir (pasirinktinai) perkraunamas, „automatiniais keliais“. Pavyzdžiui, „app/models“. Tokie katalogai atitinka šakninę vardų erdvę: „Object“.

INFO. „Zeitwerk“ dokumentacijoje šakninius katalogus vadina „root directories“, bet šiame vadove naudosime terminą „automatinis kelias“.

Automatinio kelio viduje failų pavadinimai turi atitikti jų apibrėžiamas konstantas, kaip aprašyta [čia](https://github.com/fxn/zeitwerk#file-structure).

Pagal numatytuosius nustatymus programos automatiniai keliai sudaro visų „app“ poaplankių sąrašą, kurie egzistuoja paleidus programą --- išskyrus „assets“, „javascript“ ir „views“ --- bei galimai priklausančių paketų automatiniai keliai.

Pavyzdžiui, jei „UsersHelper“ yra įgyvendintas „app/helpers/users_helper.rb“, modulis yra automatiškai įkeliamas, jums nereikia (ir neturėtumėte) rašyti „require“ iškvietimo:

```bash
$ bin/rails runner 'p UsersHelper'
UsersHelper
```

„Rails“ automatiškai prideda papildomus katalogus po „app“ prie automatinio kelio sąrašo. Pavyzdžiui, jei jūsų programa turi „app/presenters“, jums nereikia nieko konfigūruoti, kad galėtumėte automatiškai įkelti pristatymo klases; tai veikia iškart.

Masyvą su numatytųjų automatinio kelio kelių sąrašu galima išplėsti pridedant į „config.autoload_paths“, „config/application.rb“ arba „config/environments/*.rb“. Pavyzdžiui:

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_paths << "#{root}/extras"
  end
end
```

Taip pat, paketai gali pridėti savo kodus į paketo klasės kūną ir į savo pačių „config/environments/*.rb“.

ĮSPĖJIMAS. Prašome nekeisti „ActiveSupport::Dependencies.autoload_paths“; viešasis sąsaja, skirta keisti automatinio kelio kodus, yra „config.autoload_paths“.

ĮSPĖJIMAS: Paleidus programą, negalima automatiškai įkelti kodų automatinio kelio keliuose. Ypač tiesiogiai „config/initializers/*.rb“. Prašome peržiūrėti žemiau esantį skyrių „Automatinis įkėlimas, kai programa paleidžiama“ dėl galiojančių būdų tai padaryti.

Automatinius kelius valdo „Rails.autoloaders.main“ įkėlimo priemonė.

config.autoload_lib(ignore:)
----------------------------

Pagal numatytuosius nustatymus „lib“ katalogas nepriklauso nei programų, nei paketų automatinio kelio sąrašui.

Konfigūracijos metodas „config.autoload_lib“ prideda „lib“ katalogą prie „config.autoload_paths“ ir „config.eager_load_paths“. Jį reikia iškviesti iš „config/application.rb“ arba „config/environments/*.rb“, ir jis nėra prieinamas paketams.

Įprastai „lib“ turi poaplankius, kuriuos įkelėjai neturėtų valdyti automatinio kelio priemonės. Prašome, perduokite jų pavadinimus, atsižvelgiant į „lib“, reikalingą „ignore“ raktinį žodį. Pavyzdžiui:

```ruby
config.autoload_lib(ignore: %w(assets tasks))
```

Kodėl? Nors „assets“ ir „tasks“ dalinasi „lib“ katalogu su įprastu kodu, jų turinys nėra skirtas automatiniam įkėlimui ar ankstyvajam įkėlimui. „Assets“ ir „Tasks“ ten nėra „Ruby“ vardų erdvės. Taip pat ir su generatoriais, jei juos turite:
```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

`config.autoload_lib` nėra prieinamas iki 7.1 versijos, tačiau jį vis tiek galima emuliuoti, jei programa naudoja Zeitwerk:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.main.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

config.autoload_once_paths
--------------------------

Galbūt norėsite galėti automatiškai įkelti klases ir modulius be jų perkrovimo. `autoload_once_paths` konfigūracija saugo kodą, kuris gali būti automatiškai įkeltas, bet nebus perkrautas.

Pagal nutylėjimą, ši kolekcija yra tuščia, tačiau galite ją išplėsti, pridedant prie `config.autoload_once_paths`. Tai galima padaryti `config/application.rb` arba `config/environments/*.rb` failuose. Pavyzdžiui:

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_once_paths << "#{root}/app/serializers"
  end
end
```

Taip pat, moduliai gali būti pridedami į variklio klasės kūną ir į jų pačių `config/environments/*.rb` failus.

INFO. Jei `app/serializers` yra pridedamas prie `config.autoload_once_paths`, Rails daugiau nebesvarsto jo kaip automatinio įkėlimo kelio, nepaisant to, kad tai yra pasirinktinis katalogas po `app`. Šis nustatymas pakeičia taisyklę.

Tai yra svarbu klasėms ir moduliams, kurie yra talpinami vietose, kurios išlieka perkrovimų metu, pvz., patiems Rails pagrindui.

Pavyzdžiui, Active Job serializatoriai yra saugomi viduje Active Job:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

ir pati Active Job nėra perkraunama, kai yra atliekamas perkrovimas, tik aplikacijos ir variklių kodas, esantis automatinio įkėlimo keliuose, yra.

Būtų painu, jei `MoneySerializer` būtų perkraunamas, nes pakeisto versijos perkrovimas neturėtų jokio poveikio toje Active Job saugomoje klasės objekte. Iš tikrųjų, jei `MoneySerializer` būtų perkraunamas, pradedant nuo Rails 7, toks inicializatorius sukeltų `NameError`.

Kitas naudojimo atvejis yra, kai varikliai dekoruoja pagrindo klasės:

```ruby
initializer "decorate ActionController::Base" do
  ActiveSupport.on_load(:action_controller_base) do
    include MyDecoration
  end
end
```

Ten, modulio objektas, saugomas `MyDecoration` tuo metu, kai inicializatorius vykdomas, tampa `ActionController::Base` antenatu, ir `MyDecoration` perkrovimas yra beprasmis, jis neturės įtakos šiam antenatų grandinės.

Klases ir moduliai iš automatinio įkėlimo tik kartą kelių gali būti automatiškai įkelti `config/initializers`. Taigi, su šia konfigūracija tai veikia:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

INFO: Techniškai, galite automatiškai įkelti klases ir modulius, valdomus `once` automatinio įkėlimo priemonės, bet kokiu inicializatoriumi, kuris vykdomas po `:bootstrap_hook`.

Automatinio įkėlimo tik kartą keliai yra valdomi `Rails.autoloaders.once`.

config.autoload_lib_once(ignore:)
---------------------------------

`config.autoload_lib_once` metodas yra panašus į `config.autoload_lib`, išskyrus tai, kad jis prideda `lib` prie `config.autoload_once_paths` vietoj to. Jis turi būti iškviestas iš `config/application.rb` arba `config/environments/*.rb` failų ir nėra prieinamas varikliams.

Iškvietus `config.autoload_lib_once`, klasės ir moduliai `lib` gali būti automatiškai įkelti, net iš aplikacijos inicializatorių, bet nebus perkrauti.

`config.autoload_lib_once` nėra prieinamas iki 7.1 versijos, tačiau jį vis tiek galima emuliuoti, jei programa naudoja Zeitwerk:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_once_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.once.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

$LOAD_PATH{#load_path}
----------

Automatinio įkėlimo keliai pagal nutylėjimą yra pridedami prie `$LOAD_PATH`. Tačiau Zeitwerk viduje naudoja absoliučius failų pavadinimus, ir jūsų programa neturėtų naudoti `require` iškvietimų automatiškai įkeliamoms failams, todėl šie katalogai iš tikrųjų nėra reikalingi. Galite tai išjungti šiuo parametru:

```ruby
config.add_autoload_paths_to_load_path = false
```

Tai gali šiek tiek pagreitinti teisėtus `require` iškvietimus, nes yra mažiau paieškų. Be to, jei jūsų programa naudoja [Bootsnap](https://github.com/Shopify/bootsnap), tai leidžia bibliotekai išvengti nereikalingų indeksų kūrimo, taip sumažinant atminties naudojimą.

Šis parametras neturi įtakos `lib` katalogui, jis visada yra pridedamas prie `$LOAD_PATH`.

Perkrovimas
---------

Rails automatiškai perkrauna klases ir modulius, jei aplikacijos failai automatiškai įkeliami keliuose pasikeičia.

Tiksliau, jei veikia interneto serveris ir aplikacijos failai buvo pakeisti, Rails iškraipo visus automatiškai įkeliamus konstantas, valdomas pagrindinio automatinio įkėlimo priemonės, tiesiog prieš apdorojant kitą užklausą. Taip aplikacijos klasės ar moduliai, naudojami per tą užklausą, bus automatiškai įkeliami iš naujo, todėl bus naudojama jų dabartinė įgyvendinimo versija failų sistemoje.

Perkrovimas gali būti įjungtas arba išjungtas. Šį elgesį valdo [`config.enable_reloading`][] parametras, kuris `development` režime yra `true` pagal nutylėjimą, o `production` režime - `false` pagal nutylėjimą. Dėl suderinamumo su ankstesnėmis versijomis, Rails taip pat palaiko `config.cache_classes` parametrą, kuris yra ekvivalentus `!config.enable_reloading`.

Rails pagal nutylėjimą naudoja įvykių pagrindo failų stebėjimą, kad aptiktų failų pokyčius. Vietoj to, jis gali būti sukonfigūruotas aptikti failų pokyčius, pasivaikščiodamas automatinio įkėlimo keliais. Tai valdoma [`config.file_watcher`][] parametru.

Rails konsolėje nėra aktyvus failų stebėjimo mechanizmas, nepriklausomai nuo `config.enable_reloading` vertės. Tai todėl, kad, paprastai, būtų painu perkrauti kodą viduryje konsolės seanso. Panašiai kaip ir atskira užklausa, jūs paprastai norite, kad konsolės seansas būtų aptarnaujamas nuosekliu, nepasikeičiančiu aplikacijos klasių ir modulių rinkiniu.
Tačiau galite priversti atnaujinti konsolę, vykdydami `reload!`:

```irb
irb(main):001:0> User.object_id
=> 70136277390120
irb(main):002:0> reload!
Atnaujinama...
=> true
irb(main):003:0> User.object_id
=> 70136284426020
```

Kaip matote, po atnaujinimo `User` konstantoje saugomas klasės objektas yra skirtingas.


### Atnaujinimas ir pasenusių objektų problema

Labai svarbu suprasti, kad Ruby neturi būdo tikrai atnaujinti klasių ir modulių atmintyje ir tai atspindėti visur, kur jie jau naudojami. Techniškai, "iškraunant" `User` klasę reiškia pašalinti `User` konstantą naudojant `Object.send(:remove_const, "User")`.

Pavyzdžiui, pažiūrėkite į šią Rails konsolės sesiją:

```irb
irb> joe = User.new
irb> reload!
irb> alice = User.new
irb> joe.class == alice.class
=> false
```

`joe` yra originalios `User` klasės egzempliorius. Kai vyksta atnaujinimas, `User` konstanta tada įgyja kitą, atnaujintą klasę. `alice` yra naujai įkeltos `User` klasės egzempliorius, bet `joe` ne - jo klasė yra pasenusi. Galite iš naujo apibrėžti `joe`, pradėti IRB pose, arba tiesiog paleisti naują konsolę, vietoj to, kad būtų iškviestas `reload!`.

Kitas atvejis, kai galite rasti šią problemą, yra paveldėjimas iš atnaujinamų klasių vietose, kurios nėra atnaujinamos:

```ruby
# lib/vip_user.rb
class VipUser < User
end
```

jei `User` yra atnaujinama, o `VipUser` ne, tai `VipUser` viršklas yra originalus pasenusios klasės objektas.

Pagrindinė išvada: **nenaudokite talpykloje atnaujinamų klasių ar modulių**.

## Automatinis įkėlimas paleidus aplikaciją

Paleidžiant aplikaciją, ji gali automatiškai įkelti iš `autoload_once` kelių, kurie yra valdomi `once` įkėlėjo. Prašome patikrinti skyrių [`config.autoload_once_paths`](#config-autoload-once-paths) aukščiau.

Tačiau negalite automatiškai įkelti iš `autoload` kelių, kurie yra valdomi `main` įkėlėjo. Tai taikoma kodui `config/initializers` taip pat kaip aplikacijos arba variklių įkėlėjams.

Kodėl? Inicializatoriai veikia tik vieną kartą, kai aplikacija paleidžiama. Jie nebeveikia atnaujinimų metu. Jei inicializatorius naudoja atnaujinamą klasę ar modulį, jų redagavimai nebūtų atspindėti toje pradžios kode, todėl jie taptų pasenusi. Todėl atnaujinamų konstantų naudojimas inicializacijos metu yra draudžiamas.

Pažiūrėkime, ką daryti vietoj to.

### Antrasis naudojimo atvejis: Paleidus, įkelkite atnaujinamą kodą

#### Automatinis įkėlimas paleidus ir kiekvieną kartą atnaujinus

Pretenduokime, kad `ApiGateway` yra atnaujinama klasė ir jums reikia sukonfigūruoti jos galutinį tašką paleidus aplikaciją:

```ruby
# config/initializers/api_gateway_setup.rb
ApiGateway.endpoint = "https://example.com" # NameError
```

Inicializatoriai negali naudoti atnaujinamų konstantų, jums reikia apgaubti tai `to_prepare` bloku, kuris veikia paleidus ir po kiekvieno atnaujinimo:

```ruby
# config/initializers/api_gateway_setup.rb
Rails.application.config.to_prepare do
  ApiGateway.endpoint = "https://example.com" # CORRECT
end
```

PASTABA: Istorinių priežasčių dėka šis atgalinis skambutis gali paleisti du kartus. Jo vykdomas kodas turi būti idempotentinis.

#### Automatinis įkėlimas tik paleidus

Atnaujinamos klasės ir moduliai taip pat gali būti automatiškai įkelti `after_initialize` blokuose. Jie veikia paleidus, bet nebeveikia atnaujinus. Kai kuriais išskirtiniais atvejais tai gali būti tai, ko norite.

Tai gali būti naudinga priešskrydžio patikrinimams:

```ruby
# config/initializers/check_admin_presence.rb
Rails.application.config.after_initialize do
  unless Role.where(name: "admin").exists?
    abort "The admin role is not present, please seed the database."
  end
end
```

### Antrasis naudojimo atvejis: Paleidus, įkelkite kodą, kuris lieka talpykloje

Kai kurios konfigūracijos priima klasės ar modulio objektą ir jas saugo vietose, kurios nėra atnaujinamos. Svarbu, kad šios konstantos nebūtų atnaujinamos, nes redagavimai nebūtų atspindėti tų talpykloje esančių pasenusių objektų.

Vienas pavyzdys yra tarpinė programinė įranga:

```ruby
config.middleware.use MyApp::Middleware::Foo
```

Kai atnaujinote, tarpinės programinės įrangos eilutė nėra paveikta, todėl būtų painu, jei `MyApp::Middleware::Foo` būtų atnaujinamas. Jo įgyvendinimo pakeitimai neturėtų jokio poveikio.

Kitas pavyzdys yra Active Job serializatoriai:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

Kas tik `MoneySerializer` įvertina inicializacijos metu, tai yra įtraukiama į pasirinktinius serializatorius ir tas objektas lieka ten atnaujinus.

Dar vienas pavyzdys yra railties arba variklių dekoravimas karkaso klasių, įtraukiant modulius. Pavyzdžiui, [`turbo-rails`](https://github.com/hotwired/turbo-rails) dekoruoja `ActiveRecord::Base` taip:

```ruby
initializer "turbo.broadcastable" do
  ActiveSupport.on_load(:active_record) do
    include Turbo::Broadcastable
  end
end
```

Tai prideda modulio objektą prie `ActiveRecord::Base` paveldėjimo grandinės. Jei atnaujinamas `Turbo::Broadcastable`, pakeitimai neturės jokio poveikio, jei bus atnaujintas, paveldėjimo grandinė vis tiek turės originalų.

Išvada: Šios klasės ar moduliai **negali būti atnaujinami**.

Paprastiausias būdas nuorodoms į tuos klases ar modulius paleidimo metu yra juos apibrėžti kataloge, kuris nepriklauso autoload keliams. Pavyzdžiui, `lib` yra idiomatinis pasirinkimas. Jis pagal numatytuosius nustatymus nepriklauso autoload keliams, bet priklauso `$LOAD_PATH`. Tiesiog naudokite įprastinį `require` jį įkelti.
Kaip jau minėta, kita galimybė yra turėti katalogą, kuriame apibrėžti kelią ir autoload, įkeltą tik kartą. Išsamesnę informaciją rasite [skiltyje apie config.autoload_once_paths](#config-autoload-once-paths).

### Antra naudojimo atvejis: Konfigūruoti aplikacijos klases moduliams

Tarkime, kad modulis dirba su pakartotinai įkeliamu aplikacijos klasių modeliu, kuris modeliuoja vartotojus, ir turi konfigūracijos tašką tam:

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = User # NameError
end
```

Norint gerai veikti su pakartotinai įkeliamu aplikacijos kodu, modulis turi prašyti aplikacijų konfigūruoti tos klasės _vardą_:

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = "User" # OK
end
```

Tada paleidimo metu `config.user_model.constantize` suteikia jums esamą klasės objektą.

Greitoji įkėlimas
-----------------

Prodiukcijos panašiose aplinkose paprastai geriau įkelti visą aplikacijos kodą, kai aplikacija paleidžiama. Greitas įkėlimas viską į atmintį, kad būtų galima nedelsiant aptarnauti užklausas, taip pat yra [CoW](https://en.wikipedia.org/wiki/Copy-on-write)-draugiškas.

Greitąjį įkėlimą valdo [`config.eager_load`](#config-eager-load) vėliavėlė, kuri pagal numatytuosius nustatymus yra išjungta visose aplinkose, išskyrus `production`. Kai vykdomas Rake užduotis, `config.eager_load` yra perrašomas [`config.rake_eager_load`](#config-rake-eager-load), kuris pagal numatytuosius nustatymus yra `false`. Taigi, pagal numatytuosius nustatymus, prodiukcijos aplinkose Rake užduotys neįkelia aplikacijos greituoju būdu.

Failų, kurie yra greitai įkeliami, tvarka nėra apibrėžta.

Greitojo įkėlimo metu „Rails“ iškviečia `Zeitwerk::Loader.eager_load_all`. Tai užtikrina, kad visi „Zeitwerk“ valdomi priklausomybės būtų greitai įkelti taip pat.



Vienintelės lentelės paveldėjimas
------------------------

Vienintelės lentelės paveldėjimas nesiderina su tingiu įkėlimu: „Active Record“ turi žinoti apie STI hierarchijas, kad veiktų teisingai, bet tingiu įkeliant klasės tiksliai įkeliamos tik pagal poreikį!

Norint išspręsti šią pagrindinę nesuderinamumą, turime iš anksto įkelti STI. Yra keletas galimybių tai padaryti, su skirtingais kompromisais. Pažiūrėkime į jas.

### Galimybė 1: Įjungti greitąjį įkėlimą

Paprastiausias būdas iš anksto įkelti STI yra įjungti greitąjį įkėlimą, nustatant:

```ruby
config.eager_load = true
```

`config/environments/development.rb` ir `config/environments/test.rb` failuose.

Tai paprasta, bet gali būti brangu, nes tai greitai įkelia visą aplikaciją paleidimo metu ir kiekvieną kartą, kai ji yra perkraunama. Tačiau šis kompromisas gali būti vertas dėmesio mažoms aplikacijoms.

### Galimybė 2: Įkelti suspaustą katalogą

Laikykite failus, kurie apibrėžia hierarchiją, atskirame kataloge, kas konceptualiai taip pat yra prasminga. Katalogas neturi reikšti erdvės, jo vienintelis tikslas yra grupuoti STI:

```
app/models/shapes/shape.rb
app/models/shapes/circle.rb
app/models/shapes/square.rb
app/models/shapes/triangle.rb
```

Šiame pavyzdyje vis tiek norime, kad `app/models/shapes/circle.rb` apibrėžtų `Circle`, o ne `Shapes::Circle`. Tai gali būti jūsų asmeninė nuostata, kad išlaikytumėte paprastumą, ir taip pat išvengtumėte pertvarkymų esamuose kodų bazėse. „Zeitwerk“ [suglaudinimo](https://github.com/fxn/zeitwerk#collapsing-directories) funkcija leidžia mums tai padaryti:

```ruby
# config/initializers/preload_stis.rb

shapes = "#{Rails.root}/app/models/shapes"
Rails.autoloaders.main.collapse(shapes) # Ne erdvės.

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir(shapes)
  end
end
```

Šioje galimybėje mes iš anksto įkeliam šiuos kelis failus paleidimo metu ir perkrauname net jei STI nenaudojamas. Tačiau, nebent jūsų aplikacija turi daug STI, tai neturės jokio matomo poveikio.

INFO: Metodas `Zeitwerk::Loader#eager_load_dir` buvo pridėtas „Zeitwerk“ versijoje 2.6.2. Senesnėse versijose vis tiek galite išvardinti `app/models/shapes` katalogą ir iškviesti `require_dependency` jo turiniui.

ĮSPĖJIMAS: Jei modeliai yra pridedami, keičiami arba ištrinami iš STI, perkrovimas veikia kaip tikėtasi. Tačiau, jei aplikacijoje pridedama nauja atskira STI hierarchija, turėsite redaguoti inicializatorių ir paleisti serverį iš naujo.

### Galimybė 3: Įkelti įprastą katalogą

Panašu į ankstesnę galimybę, bet katalogas turi būti erdvės. Tai yra, tikimasi, kad `app/models/shapes/circle.rb` apibrėžs `Shapes::Circle`.

Šiam variantui inicializatorius yra tas pats, tik nėra konfigūruota suglaudinimas:

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/shapes")
  end
end
```

Tokie patys kompromisai.

### Galimybė 4: Įkelti tipus iš duomenų bazės

Šioje galimybėje mums nereikia organizuoti failų jokiais būdais, bet pasiekiame duomenų bazę:

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    types = Shape.unscoped.select(:type).distinct.pluck(:type)
    types.compact.each(&:constantize)
  end
end
```

ĮSPĖJIMAS: STI veiks teisingai net jei lentelėje nėra visų tipų, bet metodai kaip `subclasses` arba `descendants` negrąžins trūkstamų tipų.

ĮSPĖJIMAS: Jei modeliai yra pridedami, keičiami arba ištrinami iš STI, perkrovimas veikia kaip tikėtasi. Tačiau, jei aplikacijoje pridedama nauja atskira STI hierarchija, turėsite redaguoti inicializatorių ir paleisti serverį iš naujo.
Infleksijų pritaikymas pagal poreikį
-----------------------

Pagal numatytuosius nustatymus, „Rails“ naudoja `String#camelize` funkciją, kad žinotų, kurią konstantą turėtų apibrėžti tam tikras failas arba katalogo pavadinimas. Pavyzdžiui, „posts_controller.rb“ turėtų apibrėžti „PostsController“, nes tai grąžina `"posts_controller".camelize`.

Gali būti atvejų, kai tam tikras failo arba katalogo pavadinimas nėra inflektuojamas taip, kaip norite. Pavyzdžiui, pagal numatytuosius nustatymus „html_parser.rb“ turėtų apibrėžti „HtmlParser“. O jei norite, kad klasė būtų „HTMLParser“? Yra keletas būdų, kaip tai pritaikyti.

Paprastiausias būdas yra apibrėžti akronimus:

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "HTML"
  inflect.acronym "SSL"
end
```

Tai veikia kaip bendras „Active Support“ inflektavimas. Tai gali būti tinkama kai kuriems programoms, tačiau taip pat galite pritaikyti, kaip inflektuoti pavienius pagrindinius pavadinimus nepriklausomai nuo „Active Support“, perduodant kolekciją su perrašymais numatytiesiems inflektoriams:

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

Tačiau ši technika vis dar priklauso nuo `String#camelize`, nes tai yra tai, ką numatytieji inflektoriai naudoja kaip atsarginę galimybę. Jei norite visiškai nepriklausyti nuo „Active Support“ inflektavimo ir turėti absoliučią kontrolę, kaip inflektuoti, konfigūruokite inflektorius, kad jie būtų „Zeitwerk::Inflector“ pavyzdžiai:

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector = Zeitwerk::Inflector.new
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

Nėra globalios konfigūracijos, kuri galėtų paveikti šiuos pavyzdžius; jie yra nustatomi.

Netgi galite apibrėžti pasirinktinį inflektorį, kad gautumėte visišką lankstumą. Daugiau informacijos rasite [Zeitwerk dokumentacijoje](https://github.com/fxn/zeitwerk#custom-inflector).

### Kur turėtų būti inflektavimo pritaikymas?

Jei programa nenaudoja „once“ autoloaderio, aukščiau pateikti fragmentai gali būti įrašyti į `config/initializers`. Pavyzdžiui, „config/initializers/inflections.rb“ atveju, kai naudojamas „Active Support“, arba „config/initializers/zeitwerk.rb“ kitais atvejais.

Programos, naudojančios „once“ autoloaderį, turi perkelti arba įkelti šią konfigūraciją iš programos klasės kūno `config/application.rb`, nes „once“ autoloaderis naudoja inflektorius anksti paleidimo procese.

Pasirinktinės vardų erdvės
-----------------

Kaip matėme anksčiau, automatinio įkėlimo keliai atitinka viršutinę erdvę: „Object“.

Pavyzdžiui, apsvarstykime „app/services“. Šis katalogas pagal numatytuosius nustatymus nėra generuojamas, tačiau jei jis egzistuoja, „Rails“ automatiškai prideda jį prie automatinio įkėlimo kelių.

Pagal numatytuosius nustatymus, failas „app/services/users/signup.rb“ turėtų apibrėžti „Users::Signup“, bet ką, jei norite, kad visas šaknis būtų „Services“ erdvėje? Na, su numatytosiomis nustatymais tai galima pasiekti sukurdami subkatalogą: „app/services/services“.

Tačiau, priklausomai nuo jūsų skonio, tai gali neatrodyti tinkama jums. Galbūt norėtumėte, kad „app/services/users/signup.rb“ tiesiog apibrėžtų „Services::Users::Signup“.

„Zeitwerk“ palaiko [pasirinktines šaknines erdves](https://github.com/fxn/zeitwerk#custom-root-namespaces), kad būtų galima spręsti šį atvejį, ir galite pritaikyti pagrindinį įkėlėją, kad tai pasiektumėte:

```ruby
# config/initializers/autoloading.rb

# Erdvė turi egzistuoti.
#
# Šiame pavyzdyje modulį apibrėžiame vietoje. Jis taip pat gali būti sukurtas
# kitur, o jo apibrėžimas įkeltas čia su įprastiniu `require`. Bet kuriuo atveju,
# `push_dir` tikisi klasės arba modulio objekto.
module Services; end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/services", namespace: Services)
```

„Rails“ versijai < 7.1 ši funkcija nepalaikoma, tačiau vis tiek galite pridėti šį papildomą kodą į tą patį failą ir jis veiks:

```ruby
# Papildomas kodas programoms, veikiančioms su „Rails“ versija < 7.1.
app_services_dir = "#{Rails.root}/app/services" # turi būti eilutė
ActiveSupport::Dependencies.autoload_paths.delete(app_services_dir)
Rails.application.config.watchable_dirs[app_services_dir] = [:rb]
```

Pasirinktinės vardų erdvės taip pat palaikomos „once“ autoloaderiui. Tačiau, kadangi šis yra sukonfigūruotas anksti paleidimo procese, konfigūracijos negalima atlikti programos inicializavimo metu. Vietoj to, įrašykite ją į `config/application.rb`, pavyzdžiui.

Automatinis įkėlimas ir moduliai
-----------------------

Moduliai veikia pagrindinės programos kontekste, ir jų kodas yra automatiškai įkeliamas, perkraunamas ir įkeliamas pagrindinės programos. Jei programa veikia „zeitwerk“ režimu, modulio kodas yra įkeliamas „zeitwerk“ režimu. Jei programa veikia „classic“ režimu, modulio kodas yra įkeliamas „classic“ režimu.

Paleidus „Rails“, modulio katalogai yra pridedami prie automatinio įkėlimo kelių, ir automatinio įkėlimo požiūriu nėra jokios skirtumo. Automatinio įkėlimo pagrindiniai įvesties duomenys yra automatinio įkėlimo keliai, ir ar jie priklauso programos šaltinio medžiagai arba tam tikro modulio šaltinio medžiagai yra nereikšminga.

Pavyzdžiui, ši programa naudoja [Devise](https://github.com/heartcombo/devise):

```
% bin/rails runner 'pp ActiveSupport::Dependencies.autoload_paths'
[".../app/controllers",
 ".../app/controllers/concerns",
 ".../app/helpers",
 ".../app/models",
 ".../app/models/concerns",
 ".../gems/devise-4.8.0/app/controllers",
 ".../gems/devise-4.8.0/app/helpers",
 ".../gems/devise-4.8.0/app/mailers"]
 ```

Jei modulis kontroliuoja savo pagrindinės programos automatinio įkėlimo režimą, modulis gali būti rašomas kaip įprasta.
Tačiau jei variklis palaiko "Rails 6" arba "Rails 6.1" ir neturi kontrolės savo pagrindinės programos, jis turi būti pasiruošęs veikti tiek "classic" režime, tiek "zeitwerk" režime. Dėmesys turi būti skiriamas šiems dalykams:

1. Jei "classic" režimas reikalauja "require_dependency" iškvietimo, kad būtų užtikrinta, jog tam tikra konstanta bus įkelta tam tikru momentu, tai reikia įrašyti. Nors "zeitwerk" to nereikalauja, tai nepakenks, nes tai veiks ir "zeitwerk" režime.

2. "Classic" režime konstantos pavadinimai rašomi su pabraukimu ("User" -> "user.rb"), o "zeitwerk" režime pavadinimai rašomi kaip "camelCase" ("user.rb" -> "User"). Daugeliu atvejų jie sutampa, tačiau nesutampa, jei yra eilės iš eilės didžiosios raidės, pvz., "HTMLParser". Paprasčiausias būdas būti suderinamam yra vengti tokių pavadinimų. Šiuo atveju pasirinkite "HtmlParser".

3. "Classic" režime failas "app/model/concerns/foo.rb" gali apibrėžti tiek "Foo", tiek "Concerns::Foo". "Zeitwerk" režime yra tik viena galimybė: jis turi apibrėžti "Foo". Norint būti suderinamam, apibrėžkite "Foo".

Testavimas
----------

### Rankinis testavimas

Užduotis `zeitwerk:check` patikrina, ar projekto medis atitinka tikėtus pavadinimo konvencijas ir tai yra patogu atlikti rankinius patikrinimus. Pavyzdžiui, jei migruojate iš "classic" į "zeitwerk" režimą arba jei kažką taisote:

```
% bin/rails zeitwerk:check
Palaukite, aš įkeliu programą.
Viskas gerai!
```

Gali būti papildomų rezultatų, priklausomai nuo programos konfigūracijos, tačiau paskutinis "Viskas gerai!" yra tai, ko ieškote.

### Automatinis testavimas

Gera praktika yra patikrinti testų rinkinyje, ar projektas tinkamai įkeliamas.

Tai apima "Zeitwerk" pavadinimo atitikimą ir kitas galimas klaidų sąlygas. Prašome patikrinti [skyrių apie įkelimo testavimą](testing.html#testing-eager-loading) "Testing Rails Applications" vadove.

Problemų sprendimas
-------------------

Geriausias būdas sekti, ką įkėlėjai daro, yra ištirti jų veiklą.

Paprastiausias būdas tai padaryti yra įtraukti

```ruby
Rails.autoloaders.log!
```

į `config/application.rb` po įkeliant pagrindinius karkaso nustatymus. Tai atspausdins žymes į standartinį išvesties srautą.

Jei norite žurnalo įrašų įrašymo į failą, konfigūruokite taip:

```ruby
Rails.autoloaders.logger = Logger.new("#{Rails.root}/log/autoloading.log")
```

Kai `config/application.rb` vykdo, "Rails" žurnalo įrašyklė dar nėra pasiekiama. Jei norite naudoti "Rails" žurnalo įrašyklę, konfigūruokite šią nustatymą inicializavimo metu:

```ruby
# config/initializers/log_autoloaders.rb
Rails.autoloaders.logger = Rails.logger
```

Rails.autoloaders
-----------------

Jūsų programą valdančios "Zeitwerk" instancijos yra pasiekiamos:

```ruby
Rails.autoloaders.main
Rails.autoloaders.once
```

Predikatas

```ruby
Rails.autoloaders.zeitwerk_enabled?
```

vis dar yra prieinamas "Rails 7" programose ir grąžina `true`.
[`config.enable_reloading`]: configuring.html#config-enable-reloading
[`config.file_watcher`]: configuring.html#config-file-watcher
[`config.eager_load`]: configuring.html#config-eager-load
[`config.rake_eager_load`]: configuring.html#config-rake-eager-load
