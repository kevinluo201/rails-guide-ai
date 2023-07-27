**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 48f8290cbf9190673c32a3eb9777acba
Rails ant Rack
=============

Šis vadovas aprėpia Rails integraciją su Rack ir sąveiką su kitais Rack komponentais.

Po šio vadovo perskaitymo, žinosite:

* Kaip naudoti Rack Middlewares savo Rails aplikacijose.
* Action Pack vidinį Middleware sąrašą.
* Kaip apibrėžti pasirinktinį Middleware sąrašą.

--------------------------------------------------------------------------------

ĮSPĖJIMAS: Šis vadovas priklauso nuo Rack protokolo ir Rack sąvokų, tokias kaip middleware, URL žemėlapiai ir `Rack::Builder`, veikimo žinios.

Įvadas į Rack
--------------------

Rack teikia minimalią, modulinę ir pritaikomą sąsają, skirtą interneto aplikacijų kūrimui Ruby kalba. Supaprastinant HTTP užklausas ir atsakymus taip paprastai, kaip įmanoma, jis suvienija ir sutraukia API interneto serveriams, interneto karkasams ir programinei įrangai tarp jų (vadinamai middleware) į vieną metodų iškvietimą.

Rack veikimo paaiškinimas nėra šio vadovo tikslas. Jei nesuprantate Rack pagrindų, turėtumėte perskaityti [Šaltiniai](#resources) skyrių žemiau.

Rails ant Rack
-------------

### Rails aplikacijos Rack objektas

`Rails.application` yra pagrindinis Rack aplikacijos objektas Rails aplikacijoje. Bet koks Rack suderinamas interneto serveris turėtų naudoti `Rails.application` objektą, kad aptarnautų Rails aplikaciją.

### `bin/rails server`

`bin/rails server` atlieka pagrindinį darbą - sukuria `Rack::Server` objektą ir paleidžia interneto serverį.

Taip `bin/rails server` sukuria `Rack::Server` objekto instanciją:

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

`Rails::Server` paveldi iš `Rack::Server` ir iškviečia `Rack::Server#start` metodą taip:

```ruby
class Server < ::Rack::Server
  def start
    # ...
    super
  end
end
```

### `rackup`

Norėdami naudoti `rackup` vietoj Rails `bin/rails server`, galite įdėti šį kodą į savo Rails aplikacijos šakninio katalogo `config.ru` failą:

```ruby
# Rails.root/config.ru
require_relative "config/environment"
run Rails.application
```

Ir paleisti serverį:

```bash
$ rackup config.ru
```

Norėdami sužinoti daugiau apie skirtingus `rackup` pasirinkimus, galite paleisti:

```bash
$ rackup --help
```

### Vystymas ir automatinis perkrovimas

Middleware yra įkraunamos tik vieną kartą ir nėra stebimos pokyčiams. Norėdami, kad pakeitimai būtų atspindėti veikiančioje aplikacijoje, turėsite paleisti serverį iš naujo.

Action Dispatcher Middleware sąrašas
----------------------------------

Daugelis Action Dispatcher vidinių komponentų yra įgyvendinti kaip Rack middleware. `Rails::Application` naudoja `ActionDispatch::MiddlewareStack` kombinuoti įvairius vidinius ir išorinius middleware į pilną Rails Rack aplikaciją.

PASTABA: `ActionDispatch::MiddlewareStack` yra Rails atitikmuo `Rack::Builder`, bet jis yra sukurtas, kad atitiktų Rails reikalavimus ir būtų lankstesnis ir turėtų daugiau funkcijų.

### Middleware sąrašo tikrinimas

Rails turi patogią komandą, skirtą tikrinti naudojamą middleware sąrašą:

```bash
$ bin/rails middleware
```

Naujai sugeneruotai Rails aplikacijai tai gali atrodyti kaip:

```ruby
use ActionDispatch::HostAuthorization
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
use ActionDispatch::ServerTiming
use ActiveSupport::Cache::Strategy::LocalCache::Middleware
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use ActionDispatch::RemoteIp
use Sprockets::Rails::QuietAssets
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use WebConsole::Middleware
use ActionDispatch::DebugExceptions
use ActionDispatch::ActionableExceptions
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::Migration::CheckPending
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ContentSecurityPolicy::Middleware
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
use Rack::TempfileReaper
run MyApp::Application.routes
```

Čia pateikiami numatyti middleware (ir kiti) yra apibendrinti [Vidiniai middleware](#internal-middleware-stack) skyriuje žemiau.

### Middleware sąrašo konfigūravimas

Rails teikia paprastą konfigūracijos sąsają [`config.middleware`][] pridėti, pašalinti ir modifikuoti middleware sąraše esančius middleware per `application.rb` arba aplinkos specifinį konfigūracijos failą `environments/<environment>.rb`.


#### Middleware pridėjimas

Galite pridėti naują middleware į middleware sąrašą naudodami vieną iš šių metodų:

* `config.middleware.use(new_middleware, args)` - Prideda naują middleware į middleware sąrašo apačią.

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - Prideda naują middleware prieš nurodytą esamą middleware middleware sąraše.

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - Prideda naują middleware po nurodyto esamo middleware middleware sąraše.

```ruby
# config/application.rb

# Pridėti Rack::BounceFavicon apačioje
config.middleware.use Rack::BounceFavicon

# Pridėti Lifo::Cache po ActionDispatch::Executor.
# Pervesti { page_cache: false } argumentą į Lifo::Cache.
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### Middleware pakeitimas

Galite pakeisti esamą middleware middleware sąraše naudodami `config.middleware.swap`.

```ruby
# config/application.rb

# Pakeisti ActionDispatch::ShowExceptions į Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### Middleware perkėlimas

Galite perkelti esamą middleware middleware sąraše naudodami `config.middleware.move_before` ir `config.middleware.move_after`.

```ruby
# config/application.rb

# Perkelti ActionDispatch::ShowExceptions prieš Lifo::ShowExceptions
config.middleware.move_before Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

```ruby
# config/application.rb

# Perkelti ActionDispatch::ShowExceptions po Lifo::ShowExceptions
config.middleware.move_after Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

#### Middleware pašalinimas
Pridėkite šias eilutes į savo programos konfigūraciją:

```ruby
# config/application.rb
config.middleware.delete Rack::Runtime
```

Dabar, jei patikrinsite tarpinio programinio įrankio paketą, pastebėsite, kad `Rack::Runtime` joje nėra.

```bash
$ bin/rails middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
...
run Rails.application.routes
```

Jei norite pašalinti sesijos susijusią tarpinę programinę įrangą, atlikite šiuos veiksmus:

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash
```

Ir norint pašalinti naršyklės susijusią tarpinę programinę įrangą:

```ruby
# config/application.rb
config.middleware.delete Rack::MethodOverride
```

Jei norite, kad būtų iškelta klaida, kai bandysite pašalinti neegzistuojantį elementą, naudokite `delete!` vietoj to.

```ruby
# config/application.rb
config.middleware.delete! ActionDispatch::Executor
```

### Vidinė tarpinės programinės įrangos paketo struktūra

Daugelis Action Controller funkcionalumo yra įgyvendinama kaip tarpinės programinės įrangos. Šiame sąraše paaiškinama kiekvienos iš jų paskirtis:

**`ActionDispatch::HostAuthorization`**

* Apsaugo nuo DNS peradresavimo atakų, išreiškiamai leidžiant užklausas siųsti tik tam tikriems serveriams. Konfigūracijos instrukcijos rasite [konfigūracijos vadove](configuring.html#actiondispatch-hostauthorization).

**`Rack::Sendfile`**

* Nustato serverio specifinį X-Sendfile antraštę. Konfigūruokite tai naudodami [`config.action_dispatch.x_sendfile_header`][] parinktį.

**`ActionDispatch::Static`**

* Naudojama aptarnauti statinius failus iš viešojo katalogo. Išjungiama, jei [`config.public_file_server.enabled`][] yra `false`.

**`Rack::Lock`**

* Nustato `env["rack.multithread"]` vėliavą į `false` ir apgaubia programą Mutex.

**`ActionDispatch::Executor`**

* Naudojama gijų saugiam kodo perkrovimui vystymosi metu.

**`ActionDispatch::ServerTiming`**

* Nustato [`Server-Timing`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server-Timing) antraštę, kurioje yra veikimo metrikos užklausai.

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* Naudojama atminties kešavimui. Šis kešas nėra gijų saugus.

**`Rack::Runtime`**

* Nustato X-Runtime antraštę, kurioje yra laikas (sekundėmis), kurį užtrunka vykdyti užklausą.

**`Rack::MethodOverride`**

* Leidžia pakeisti metodą, jei nustatytas `params[:_method]`. Tai yra tarpinė programa, kuri palaiko PUT ir DELETE HTTP metodo tipus.

**`ActionDispatch::RequestId`**

* Prieinama unikali `X-Request-Id` antraštė, kurią galima naudoti atsakyme, ir įgalina `ActionDispatch::Request#request_id` metodą.

**`ActionDispatch::RemoteIp`**

* Tikrina IP sukčiavimo atakas.

**`Sprockets::Rails::QuietAssets`**

* Slopina žurnalo išvestį dėl turinio užklausų.

**`Rails::Rack::Logger`**

* Praneša žurnalo failams, kad užklausa prasidėjo. Baigus užklausą, išvalo visus žurnalus.

**`ActionDispatch::ShowExceptions`**

* Išgelbsti bet kokią išimtį, grąžintą programos, ir iškviečia išimčių programą, kuri ją supakuos vartotojui tinkamu formatu.

**`ActionDispatch::DebugExceptions`**

* Atsakinga už išimčių žurnalavimą ir derinimo puslapio rodomąjį puslapį, jei užklausa yra vietinė.

**`ActionDispatch::ActionableExceptions`**

* Suteikia būdą iškviesti veiksmus iš „Rails“ klaidų puslapių.

**`ActionDispatch::Reloader`**

* Suteikia pasirengimo ir valymo atgalinio iškvietimo funkcijas, skirtas padėti perkrauti kodą vystymosi metu.

**`ActionDispatch::Callbacks`**

* Suteikia atgalinio iškvietimo funkcijas, kurios bus vykdomos prieš ir po užklausos išsiuntimo.

**`ActiveRecord::Migration::CheckPending`**

* Patikrina laukiančias migracijas ir iškelia `ActiveRecord::PendingMigrationError`, jei yra laukiančių migracijų.

**`ActionDispatch::Cookies`**

* Nustato slapukus užklausai.

**`ActionDispatch::Session::CookieStore`**

* Atsakinga už sesijos saugojimą slapukuose.

**`ActionDispatch::Flash`**

* Nustato blykstės raktus. Prieinama tik jei [`config.session_store`][] nustatytas į tam tikrą reikšmę.

**`ActionDispatch::ContentSecurityPolicy::Middleware`**

* Suteikia DSL, skirtą konfigūruoti „Content-Security-Policy“ antraštę.

**`Rack::Head`**

* Konvertuoja HEAD užklausas į `GET` užklausas ir aptarnauja jas kaip tokias.

**`Rack::ConditionalGet`**

* Prideda palaikymą „Sąlyginiam `GET`“, kad serveris atsakytų niekuo, jei puslapis nebuvo pakeistas.

**`Rack::ETag`**

* Prideda ETag antraštę visiems tekstinio tipo kūnams. ETag naudojami, kad patikrintų kešą.

**`Rack::TempfileReaper`**

* Valo laikinus failus, naudotus buferiuoti daugialypėms užklausoms.

PATARIMAS: Galite naudoti bet kurias iš aukščiau paminėtų tarpinių programų savo pasirinktame Rack pakete.

Ištekliai
---------

### Rack mokymasis

* [Oficiali Rack svetainė](https://rack.github.io)
* [Rack pristatymas](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### Tarpinės programinės įrangos supratimas

* [Railscast apie Rack tarpines programinės įrangos](http://railscasts.com/episodes/151-rack-middleware)
[`config.middleware`]: configuring.html#config-middleware
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.session_store`]: configuring.html#config-session-store
