**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fe858c0828e87f595c5d8c23c4b6326e
Naudodami „Rails“ API programoms
================================

Šiame vadove sužinosite:

* Ką „Rails“ teikia API programoms
* Kaip konfigūruoti „Rails“, kad jis pradėtų veikti be naršyklės funkcijų
* Kaip nuspręsti, kokius tarpinės programinės įrangos komponentus norite įtraukti
* Kaip nuspręsti, kokius modulius naudoti savo valdiklyje

--------------------------------------------------------------------------------

Kas yra API programa?
---------------------

Tradiciškai, kai žmonės sakė, kad jie naudoja „Rails“ kaip „API“, jie turėjo omenyje
programiškai pasiekiamą API, kartu su savo internetinės programos. Pavyzdžiui, „GitHub“ teikia [API](https://developer.github.com), kurį
galite naudoti savo asmeniniuose klientuose.

Su kliento pusės karkasais atėjimu, vis daugiau programuotojų naudoja „Rails“
kurti pagrindinę dalį, kuri bendrinama tarp jų internetinės programos ir kitų natyvinių
programų.

Pavyzdžiui, „Twitter“ savo internetinėje
programoje naudoja savo [viešą API](https://developer.twitter.com/), kuri yra sukuriama kaip statinė svetainė, kuri naudoja JSON išteklius.

Vietoje to, kad „Rails“ generuotų HTML, kuris bendrauja su serveriu
per formą ir nuorodas, daugelis programuotojų savo internetinę programą
traktuoja kaip tik API klientą, kuris pristatomas kaip HTML su JavaScript, kuris naudoja JSON API.

Šiame vadove aprašoma, kaip sukurti „Rails“ programą, kuri teikia JSON išteklius API klientui,
įskaitant kliento pusės karkasus.

Kodėl naudoti „Rails“ JSON API?
-------------------------------

Pirma klausimas, kurį daugelis žmonių turi, galvodami apie JSON API kūrimą naudojant „Rails“, yra: „ar naudoti „Rails“ tik tam, kad išspausdintų JSON? Ar neturėčiau tiesiog naudoti kažko panašaus į „Sinatra“?“.

Labai paprastoms API tai gali būti tiesa. Tačiau net labai daug HTML turinčiose
programose, didžioji dalis programos logikos yra už žiūrimojo sluoksnio ribų.

Pagrindinė priežastis, kodėl daugelis žmonių naudoja „Rails“, yra tai, kad jis teikia numatytąjį rinkinį
parametrų, kurie leidžia programuotojams greitai pradėti dirbti, nereikalaujant priimti daugybės trivialių
sprendimų.

Pažvelkime į keletą dalykų, kuriuos „Rails“ numato iš anksto ir kurie vis dar yra taikomi API programoms.

Tvarkomi tarpinės programinės įrangos sluoksnyje:

- Persikrovimas: „Rails“ programos palaiko skaidrų persikrovimą. Tai veikia net jei
  jūsų programa tampa didelė ir kiekvienam užklausos persikrovimas tampa
  neįmanomas.
- Plėtojimo režimas: „Rails“ programos turi protingus numatytuosius nustatymus plėtojimui,
  padarant plėtojimą malonų, nesutrikdant gamybos metu našumo.
- Testavimo režimas: Taip pat kaip ir plėtojimo režimas.
- Žurnalavimas: „Rails“ programos žurnaloja kiekvieną užklausą, su tam tikru išsamumu
  atitinkamu dabartiniam režimui. „Rails“ žurnale plėtojimo metu yra informacija
  apie užklausos aplinką, duomenų bazės užklausas ir pagrindinę našumo
  informaciją.
- Saugumas: „Rails“ aptinka ir neleidžia [IP klastojimo
  atakoms](https://en.wikipedia.org/wiki/IP_address_spoofing) ir tvarko
  kriptografinius parašus [laiko
  atakose](https://en.wikipedia.org/wiki/Timing_attack) sąmoningas. Nežinote, kas
  yra IP klastojimo ataka ar laiko ataka? Būtent.
- Parametrų analizavimas: Norite nurodyti parametrus kaip JSON, o ne kaip
  URL užkoduotą eilutę? Nėra problema. „Rails“ jį jums iškoduos ir padarys
  jį prieinamą `params` kintamajame. Norite naudoti įdėtus URL užkoduotus parametrus? Tai
  taip pat veikia.
- Sąlyginiai GET užklausos: „Rails“ tvarko sąlyginę `GET` (`ETag` ir `Last-Modified`)
  apdorojimą užklausos antraštėse ir grąžina teisingas atsakymo antraštes ir būsenos
  kodą. Viskas, ką jums reikia padaryti, tai naudoti
  [`stale?`](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F)
  tikrinimą savo valdiklyje, ir „Rails“ visais HTTP detaliais užsiims už jus.
- HEAD užklausos: „Rails“ automatiškai konvertuos `HEAD` užklausas į `GET` užklausas,
  ir grąžins tik antraštes. Tai padaro, kad `HEAD` užklausa patikimai veiktų
  visose „Rails“ API.

Nors aišku, galėtumėte tai sukurti naudodami esamą „Rack“ tarpinės programinės įrangos sluoksnį,
šis sąrašas parodo, kad numatytasis „Rails“ tarpinės programinės įrangos rinkinys teikia daug
naudos, net jei jūs „tiesiog generuojate JSON“.

Tvarkoma „Action Pack“ sluoksnyje:

- Resursų maršrutizavimas: Jei kuriate RESTful JSON API, norite naudoti „Rails“ maršrutizatorių. Švarus ir konvencinis atvaizdavimas nuo HTTP iki valdiklių
  reiškia, kad nereikia gaišti laiko galvojant, kaip modeliuoti savo API pagal HTTP.
- URL generavimas: Maršrutizavimo atvirkštinė pusė yra URL generavimas. Geras HTTP pagrindu veikiantis API apima URL (žr. [„GitHub Gist API“](https://docs.github.com/en/rest/reference/gists)
  pavyzdį).
- Antraščių ir peradresavimo atsakymai: `head :no_content` ir
  `redirect_to user_url(current_user)` naudingi. Žinoma, galėtumėte rankiniu būdu
  pridėti atsakymo antraštes, bet kodėl?
- Talpinimas: „Rails“ teikia puslapio, veiksmo ir fragmento talpinimą. Fragmento talpinimas
  ypač naudingas, kuriant įdėtą JSON objektą.
- Pagrindinis, viršūninis ir žetonų autentifikavimas: „Rails“ iš karto palaiko tris HTTP autentifikavimo rūšis.
- Instrumentavimas: „Rails“ turi instrumentavimo API, kuris sukelia užregistruotus
  tvarkytojus įvairioms įvykių rūšims, pvz., veiksmo apdorojimui, failo siuntimui ar
  duomenims, peradresavimui ir duomenų bazės užklausoms. Kiekvieno įvykio duomenų srautas
  ateina su atitinkama informacija (veiksmo apdorojimo įvykiui, duomenų sraute yra
  valdiklis, veiksmas, parametrai, užklausos formatas, užklausos metodas ir
  užklausos pilnas kelias).
- Generatoriai: Dažnai patogu generuoti išteklių ir gauti savo modelį,
  valdiklį, testavimo šablonus ir maršrutus, kurie yra sukurti vienu komandos įvedimu,
  kad būtų galima juos toliau keisti. Taip pat ir migracijoms ir kt.
- Įskiepiai: Daugelis trečiųjų šalių bibliotekų palaiko „Rails“, kuris sumažina
  arba pašalina bibliotekos ir internetinio karkaso sąnaudas. Tai apima dalykus, tokie kaip numatytųjų generatorių perrašymas, papildomų Rake užduočių pridėjimas ir „Rails“ pasirinkimų laikymas (pvz., žurnalizatorius ir talpyklos pagrindas).
Žinoma, "Rails" paleidimo procesas taip pat sujungia visus užregistruotus komponentus.
Pavyzdžiui, "Rails" paleidimo procesas naudoja jūsų `config/database.yml` failą,
konfigūruojant "Active Record".

**Trumpa versija yra**: galbūt nesvarstėte, kurie "Rails" komponentai vis dar yra taikomi, net jei pašalinate rodinio sluoksnį, tačiau atsakymas iš esmės yra - dauguma jų.

Pagrindinė konfigūracija
-----------------------

Jei kuriate "Rails" aplikaciją, kuri pirmiausia bus API serveris,
galite pradėti su ribotesniu "Rails" rinkiniu ir pridėti funkcijas, kai reikia.

### Naujos aplikacijos kūrimas

Galite sukurti naują API "Rails" aplikaciją:

```bash
$ rails new my_api --api
```

Tai jums padarys tris pagrindines veiklas:

- Konfigūruos jūsų aplikaciją pradėti su ribotesniu middleware rinkiniu nei įprasta. Konkrečiai, pagal numatytuosius nustatymus ji neįtrauks jokio middleware, kuris yra pagrindinai naudingas naršyklės aplikacijoms (pvz., slapukų palaikymas).
- Padarys, kad `ApplicationController` paveldėtų `ActionController::API`, o ne `ActionController::Base`. Kaip ir su middleware, tai paliks bet kokius Action Controller modulius, kurie teikia funkcijas, daugiausia naudojamas naršyklės aplikacijoms.
- Konfigūruos generatorius praleisti generuojant rodinius, pagalbininkus ir išteklius, kai generuojate naują išteklių.

### Naujo ištekliaus generavimas

Norėdami pamatyti, kaip mūsų naujai sukurta API tvarko naujo ištekliaus generavimą, sukurkime naują grupės išteklių. Kiekviena grupė turės pavadinimą.

```bash
$ bin/rails g scaffold Group name:string
```

Prieš galėdami naudoti mūsų sugeneruotą kodą, turime atnaujinti duomenų bazės schemą.

```bash
$ bin/rails db:migrate
```

Dabar, jei atidarome `GroupsController`, turėtume pastebėti, kad su API "Rails" aplikacija mes rodoma tik JSON duomenis. Indeksų veiksmo metu užklausime `Group.all` ir priskirsime ją kintamajam, vadinamam `@groups`. Pervestas į `render` su `:json` parinktimi, grupės automatiškai bus rodomos kaip JSON.

```ruby
# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show update destroy ]

  # GET /groups
  def index
    @groups = Group.all

    render json: @groups
  end

  # GET /groups/1
  def show
    render json: @group
  end

  # POST /groups
  def create
    @group = Group.new(group_params)

    if @group.save
      render json: @group, status: :created, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name)
    end
end
```

Galų gale galime pridėti keletą grupių į mūsų duomenų bazę iš "Rails" konsolės:

```irb
irb> Group.create(name: "Rails Founders")
irb> Group.create(name: "Rails Contributors")
```

Turėdami kai kuriuos duomenis aplikacijoje, galime paleisti serverį ir aplankyti <http://localhost:3000/groups.json>, kad pamatytume mūsų JSON duomenis.

```json
[
{"id":1, "name":"Rails Founders", "created_at": ...},
{"id":2, "name":"Rails Contributors", "created_at": ...}
]
```

### Esamos aplikacijos keitimas

Jei norite paimti esamą aplikaciją ir ją paversti API aplikacija, perskaitykite
šiuos žingsnius.

`config/application.rb` faile, pridėkite šią eilutę virš `Application`
klasės apibrėžimo:

```ruby
config.api_only = true
```

`config/environments/development.rb` faile, nustatykite [`config.debug_exception_response_format`][]
konfigūruoti formatą, naudojamą atsakymuose, kai klaidos įvyksta vystymo režimu.

Norint atvaizduoti HTML puslapį su derinimo informacija, naudokite reikšmę `:default`.

```ruby
config.debug_exception_response_format = :default
```

Norint atvaizduoti derinimo informaciją išlaikant atsakymo formatą, naudokite reikšmę `:api`.

```ruby
config.debug_exception_response_format = :api
```

Pagal numatytuosius nustatymus, kai `config.api_only` nustatoma kaip `true`, `config.debug_exception_response_format` nustatoma kaip `:api`.

Galų gale, `app/controllers/application_controller.rb` faile, vietoj:

```ruby
class ApplicationController < ActionController::Base
end
```

padarykite:

```ruby
class ApplicationController < ActionController::API
end
```


Middleware pasirinkimas
--------------------

API aplikacija pagal numatytuosius nustatymus turi šiuos middleware:

- `ActionDispatch::HostAuthorization`
- `Rack::Sendfile`
- `ActionDispatch::Static`
- `ActionDispatch::Executor`
- `ActionDispatch::ServerTiming`
- `ActiveSupport::Cache::Strategy::LocalCache::Middleware`
- `Rack::Runtime`
- `ActionDispatch::RequestId`
- `ActionDispatch::RemoteIp`
- `Rails::Rack::Logger`
- `ActionDispatch::ShowExceptions`
- `ActionDispatch::DebugExceptions`
- `ActionDispatch::ActionableExceptions`
- `ActionDispatch::Reloader`
- `ActionDispatch::Callbacks`
- `ActiveRecord::Migration::CheckPending`
- `Rack::Head`
- `Rack::ConditionalGet`
- `Rack::ETag`

Daugiau informacijos apie juos rasite [vidinio middleware](rails_on_rack.html#internal-middleware-stack)
skyriuje "Rack" vadove. 

Kiti įskiepiai, įskaitant "Active Record", gali pridėti papildomų middleware. Bendrai, šie middleware yra neutralūs atžvilgiu jūsų kuriamos aplikacijos tipo ir tinka tik API tik "Rails" aplikacijoms.
Jūs galite gauti visų middleware sąrašą savo aplikacijoje naudodami:

```bash
$ bin/rails middleware
```

### Naudodami Rack::Cache

Kai naudojamas su Rails, `Rack::Cache` naudoja Rails talpyklą savo
entiteto ir metaduomenų talpykloms. Tai reiškia, kad jei naudojate memcache savo
Rails aplikacijai, pavyzdžiui, įmontuota HTTP talpykla naudos memcache.

Norėdami naudoti `Rack::Cache`, pirmiausia turite pridėti `rack-cache` gemą
į `Gemfile`, ir nustatyti `config.action_dispatch.rack_cache` į `true`.
Norėdami įgalinti jo funkcionalumą, norėsite naudoti `stale?` savo
valdiklyje. Čia pateikiamas `stale?` pavyzdys.

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

Kviečiant `stale?` bus palyginamas `If-Modified-Since` antraštė užklausoje
su `@post.updated_at`. Jei antraštė naujesnė nei paskutinė modifikacija, ši
veiksmas grąžins "304 Not Modified" atsaką. Kitu atveju, jis atvaizduos
atsaką ir į jį įtrauks `Last-Modified` antraštę.

Įprastai šis mechanizmas naudojamas atskirai kiekvienam klientui. `Rack::Cache`
leidžia mums bendrinti šį talpinimo mechanizmą tarp klientų. Galime įgalinti
talpinimą tarp klientų kviečiant `stale?`:

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end
end
```

Tai reiškia, kad `Rack::Cache` saugos `Last-Modified` reikšmę
URL adresui Rails talpykloje ir pridės `If-Modified-Since` antraštę bet kokiai
tolimesnei užklausai to pačio URL adreso.

Galima sakyti, kad tai yra puslapio talpinimas naudojant HTTP semantiką.

### Naudodami Rack::Sendfile

Kai naudojate `send_file` metodą viduje Rails valdiklio, jis nustato
`X-Sendfile` antraštę. `Rack::Sendfile` yra atsakingas už faktinį failo siuntimo
darbą.

Jei jūsų priekinio serverio palaiko pagreitintą failo siuntimą, `Rack::Sendfile`
perduos faktinį failo siuntimo darbą priekiniam serveriui.

Galite konfigūruoti antraštės pavadinimą, kurį jūsų priekinio serverio naudoja
šiam tikslui, naudodami [`config.action_dispatch.x_sendfile_header`][] tinkamoje
konfigūracijos failo aplinkoje.

Daugiau informacijos apie tai, kaip naudoti `Rack::Sendfile` su populiariais
priekiniais serveriais, rasite [Rack::Sendfile
dokumentacijoje](https://www.rubydoc.info/gems/rack/Rack/Sendfile).

Čia pateikiamos kai kurių populiarių serverių šios antraštės reikšmės, kai šie serveriai yra sukonfigūruoti
palaikyti pagreitintą failo siuntimą:

```ruby
# Apache ir lighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

Įsitikinkite, kad sukonfigūravote savo serverį, kad jis palaikytų šias parinktis, vadovaudamiesi
`Rack::Sendfile` dokumentacijoje pateiktais nurodymais.


### Naudodami ActionDispatch::Request

`ActionDispatch::Request#params` priims kliento parametrus JSON
formate ir prieinamus jūsų valdiklyje `params`.

Norėdami tai naudoti, jūsų klientui reikės pateikti užklausą su JSON koduotais parametrais
ir nurodyti `Content-Type` kaip `application/json`.

Čia pateikiamas pavyzdys naudojant jQuery:

```js
jQuery.ajax({
  type: 'POST',
  url: '/people',
  dataType: 'json',
  contentType: 'application/json',
  data: JSON.stringify({ person: { firstName: "Yehuda", lastName: "Katz" } }),
  success: function(json) { }
});
```

`ActionDispatch::Request` pamatys `Content-Type` ir jūsų parametrai
bus:

```ruby
{ person: { firstName: "Yehuda", lastName: "Katz" } }
```

### Naudodami sesijos middleware

Šie middleware, naudojami sesijų valdymui, yra neįtraukti į API aplikacijas, nes jos paprastai nenaudoja sesijų. Jei vienas iš jūsų API klientų yra naršyklė, galbūt norėsite pridėti vieną iš šių atgal:

- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

Būdas pridėti juos atgal yra toks, kad pagal numatytuosius nustatymus, jiems perduodami `session_options`
kai pridedami (įskaitant sesijos raktą), todėl negalite tiesiog pridėti `session_store.rb` inicializavimo failo, pridėti
`use ActionDispatch::Session::CookieStore` ir sesijos veikimas kaip įprasta. (Norint aiškiai pasakyti: sesijos
gali veikti, bet jūsų sesijos parinktys bus ignoruojamos - t. y. sesijos raktas bus numatytasis `_session_id`)

Vietoje inicializatoriaus, turėsite nustatyti atitinkamus nustatymus kažkur prieš jūsų middleware yra
sukurta (pvz., `config/application.rb`) ir perduoti juos pageidaujamam middleware, kaip čia:

```ruby
# Tai taip pat konfigūruoja session_options naudojimui žemiau
config.session_store :cookie_store, key: '_interslice_session'

# Reikalinga visiems sesijos valdymui (nesvarbu, kokio tipo session_store)
config.middleware.use ActionDispatch::Cookies

config.middleware.use config.session_store, config.session_options
```

### Kiti middleware

Rails pristato keletą kitų middleware, kuriuos galbūt norėsite naudoti
API aplikacijoje, ypač jei vienas iš jūsų API klientų yra naršyklė:

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`

Bet kurį iš šių middleware galima pridėti naudojant:

```ruby
config.middleware.use Rack::MethodOverride
```

### Middleware pašalinimas

Jei nenorite naudoti middleware, kuris yra įtrauktas pagal numatytuosius nustatymus API tik
middleware rinkinyje, jį galite pašalinti naudodami:
```ruby
config.middleware.delete ::Rack::Sendfile
```

Atkreipkite dėmesį, kad pašalinus šiuos middleware'us, bus pašalinta palaikymas tam tikroms funkcijoms veikiant Action Controller.

Pasirinkimas kontrolerio moduliams
---------------------------

API programa (naudojanti `ActionController::API`) pagal numatytuosius nustatymus turi šiuos kontrolerio modulius:

|   |   |
|---|---|
| `ActionController::UrlFor` | Leidžia naudoti `url_for` ir panašius pagalbininkus. |
| `ActionController::Redirecting` | Palaikymas `redirect_to`. |
| `AbstractController::Rendering` ir `ActionController::ApiRendering` | Pagrindinis atvaizdavimo palaikymas. |
| `ActionController::Renderers::All` | Palaikymas `render :json` ir panašiems veiksmams. |
| `ActionController::ConditionalGet` | Palaikymas `stale?`. |
| `ActionController::BasicImplicitRender` | Užtikrina tuščią atsaką, jei nėra aiškaus atsakymo. |
| `ActionController::StrongParameters` | Parametrų filtravimo palaikymas, derinant su Active Model masinio priskyrimo. |
| `ActionController::DataStreaming` | Palaikymas `send_file` ir `send_data`. |
| `AbstractController::Callbacks` | Palaikymas `before_action` ir panašiems pagalbininkams. |
| `ActionController::Rescue` | Palaikymas `rescue_from`. |
| `ActionController::Instrumentation` | Palaikymas veiksmų kontrolerio apibrėžtoms instrumentacijos kabliukams (daugiau informacijos apie tai rasite [instrumentacijos vadove](active_support_instrumentation.html#action-controller)). |
| `ActionController::ParamsWrapper` | Apvija parametrų hash į įdėtą hash'ą, todėl nereikia nurodyti šaknies elementų siunčiant POST užklausas, pvz. |
| `ActionController::Head` | Palaikymas grąžinti atsakymą be turinio, tik antraštėmis. |

Kiti įskiepiai gali pridėti papildomus modulius. Galite gauti visų modulių sąrašą, įtrauktų į `ActionController::API`, naudodami "rails console":

```irb
irb> ActionController::API.ancestors - ActionController::Metal.ancestors
=> [ActionController::API,
    ActiveRecord::Railties::ControllerRuntime,
    ActionDispatch::Routing::RouteSet::MountedHelpers,
    ActionController::ParamsWrapper,
    ... ,
    AbstractController::Rendering,
    ActionView::ViewPaths]
```

### Kitų modulių pridėjimas

Visi veiksmų kontrolerio moduliai žino apie savo priklausomus modulius, todėl galite laisvai įtraukti bet kokius modulius į savo kontrolerius, ir visi priklausomybės bus įtrauktos ir nustatytos.

Kai kuriuos dažnai naudojamus modulius, kuriuos galite pridėti:

- `AbstractController::Translation`: Palaikymas `l` ir `t` lokalizacijos ir vertimo metodams.
- Palaikymas pagrindiniam, viršutiniam arba žetono HTTP autentifikavimui:
  * `ActionController::HttpAuthentication::Basic::ControllerMethods`
  * `ActionController::HttpAuthentication::Digest::ControllerMethods`
  * `ActionController::HttpAuthentication::Token::ControllerMethods`
- `ActionView::Layouts`: Palaikymas išdėstymams atvaizduojant.
- `ActionController::MimeResponds`: Palaikymas `respond_to`.
- `ActionController::Cookies`: Palaikymas `cookies`, įskaitant palaikymą pasirašytiems ir užšifruotiems slapukams. Tai reikalauja slapukų middleware.
- `ActionController::Caching`: Palaikymas vaizdo talpinimui API kontroleryje. Atkreipkite dėmesį, kad turėsite rankiniu būdu nurodyti talpyklą kontroleryje, pavyzdžiui:

    ```ruby
    class ApplicationController < ActionController::API
      include ::ActionController::Caching
      self.cache_store = :mem_cache_store
    end
    ```

    "Rails" *nepereina* šios konfigūracijos automatiškai.

Geriausia vieta pridėti modulį yra jūsų `ApplicationController`, tačiau taip pat galite pridėti modulius prie atskirų kontrolerių.
[`config.debug_exception_response_format`]: configuring.html#config-debug-exception-response-format
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
