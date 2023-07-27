**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3529115f04b9d5fe01401105d9c154e2
Veiksmų valdiklio apžvalga
==========================

Šiame vadove sužinosite, kaip veikia valdikliai ir kaip jie įsijungia į jūsų programos užklausos ciklą.

Po šio vadovo perskaitymo žinosite, kaip:

* Sekti užklausos srautą per valdiklį.
* Apriboti parametrus, perduodamus į jūsų valdiklį.
* Saugoti duomenis sesijoje ar slapuku ir kodėl.
* Dirbti su filtrais, vykdyti kodą užklausos apdorojimo metu.
* Naudoti veiksmų valdiklio įdiegtą HTTP autentifikaciją.
* Tiesiogiai srauti duomenis į vartotojo naršyklę.
* Filtruoti jautrius parametrus, kad jie nesimatytų programos žurnale.
* Tvarkyti išimtis, kurios gali kilti per užklausos apdorojimą.
* Naudoti įdiegtą sveikatos tikrinimo galutinį tašką apkrovos balansuotojams ir veikimo laiko stebėjimo priemonėms.

--------------------------------------------------------------------------------

Ką daro valdiklis?
--------------------------

Veiksmų valdiklis yra C [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) modelyje. Kai maršrutizatorius nustato, kurį valdiklį naudoti užklausai, valdiklis yra atsakingas už užklausos supratimą ir tinkamo išvesties generavimą. Laimei, veiksmų valdiklis atlieka daugumą pagrindinio darbo ir naudoja protingas konvencijas, kad tai būtų kuo paprastesnis.

Daugeliui įprastų [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer) programų valdiklis gaus užklausą (tai jums, kaip programuotojui, nematomas), iš modelio gaus arba išsaugos duomenis ir naudos rodinį, kad sukurtų HTML išvestį. Jei jūsų valdiklis turi daryti kažką kitaip, tai nėra problema, tai tik įprastas valdiklio darbo būdas.

Valdiklį galima laikyti tarpininku tarp modelių ir rodinių. Jis padaro modelio duomenis prieinamus rodiniui, kad jis galėtų rodyti tuos duomenis vartotojui, ir jis išsaugo arba atnaujina vartotojo duomenis modelyje.

PASTABA: Daugiau informacijos apie maršrutizavimo procesą rasite [Rails maršrutizavimas iš išorės į vidų](routing.html).

Valdiklio pavadinimo konvencija
----------------------------

Rails valdiklių pavadinimo konvencija palieka pirmenybę paskutinio žodžio daugiskaitai, nors tai nėra griežtai privaloma (pvz., `ApplicationController`). Pavyzdžiui, `ClientsController` yra pageidautinas nei `ClientController`, `SiteAdminsController` yra pageidautinas nei `SiteAdminController` arba `SitesAdminsController`, ir taip toliau.

Laikantis šios konvencijos, galėsite naudoti numatytuosius maršruto generatorius (pvz., `resources`, ir pan.) be poreikio kiekvieną `:path` ar `:controller` kvalifikuoti, ir išlaikysite vardintų maršruto pagalbininkų naudojimą vienodą visoje jūsų programoje. Daugiau informacijos rasite [Dizainai ir atvaizdavimo vadove](layouts_and_rendering.html).

PASTABA: Valdiklio pavadinimo konvencija skiriasi nuo modelių pavadinimo konvencijos, kurie turi būti pavadinti vienaskaitos forma.


Metodai ir veiksmai
-------------------

Valdiklis yra Ruby klasė, kuri paveldi `ApplicationController` ir turi metodus kaip bet kuri kita klasė. Kai jūsų programa gauna užklausą, maršrutizavimas nustatys, kurį valdiklį ir veiksmą paleisti, tada Rails sukurs to valdiklio egzempliorių ir paleis metodą, turintį tokį patį pavadinimą kaip veiksmas.

```ruby
class ClientsController < ApplicationController
  def new
  end
end
```

Pavyzdžiui, jei vartotojas eina į `/clients/new` jūsų programoje, kad pridėtų naują klientą, Rails sukurs `ClientsController` egzempliorių ir iškviestų jo `new` metodą. Atkreipkite dėmesį, kad tuščias metodas iš pavyzdžio viršuje veiktų gerai, nes Rails pagal numatymą atvaizduos `new.html.erb` rodinį, nebent veiksmas sako kitaip. Sukurdamas naują `Client`, `new` metodas gali padaryti `@client` egzempliorinį kintamąjį prieinamą rodinyje:

```ruby
def new
  @client = Client.new
end
```

[Layouts and Rendering Guide](layouts_and_rendering.html) tai išsamiau paaiškina.

`ApplicationController` paveldi [`ActionController::Base`][], kuris apibrėžia keletą naudingų metodų. Šiame vadove bus aptariami kai kurie iš jų, bet jei jums smalsu, ką ten yra, galite pamatyti visus juos [API dokumentacijoje](https://api.rubyonrails.org/classes/ActionController.html) arba pačiame šaltinyje.

Kaip veiksmai gali būti iškviesti tik vieši metodai. Geriausia praktika yra sumažinti metodų matomumą (naudojant `private` arba `protected`), kurie nėra skirti veiksmams, pvz., pagalbiniai metodai arba filtrai.

ĮSPĖJIMAS: Kai kurie metodo pavadinimai yra rezervuoti veiksmų valdiklyje. Atsitiktinai juos pervardyti kaip veiksmus ar net kaip pagalbinius metodus gali sukelti `SystemStackError`. Jei savo valdiklius apribosite tik RESTful [Resursų maršrutizavimo][] veiksmais, neturėtumėte dėl to nerimauti.

PASTABA: Jei turite naudoti rezervuotą metodą kaip veiksmo pavadinimą, vienas būdas tai apeiti yra naudoti tinkintą maršrutą, kad susietumėte rezervuotą metodo pavadinimą su savo nerezervuotu veiksmo metodu.
[Resursų maršrutizavimas]: routing.html#resource-routing-the-rails-default

Parametrai
----------

Jūs tikriausiai norėsite pasiekti duomenis, kuriuos siunčia vartotojas arba kitus parametrus savo valdiklio veiksmuose. Yra du rūšių parametrų, galimų interneto programoje. Pirmieji yra parametrai, siunčiami kaip URL dalis, vadinami užklausos eilutės parametrais. Užklausos eilutė yra viskas po "?" URL. Antrasis parametro tipas paprastai vadinamas POST duomenimis. Ši informacija paprastai gaunama iš HTML formos, kurią užpildė vartotojas. Jis vadinamas POST duomenimis, nes jį galima siųsti tik kaip dalį HTTP POST užklausos. „Rails“ nesiskiria tarp užklausos eilutės parametrų ir POST parametrų, ir abu yra prieinami jūsų valdiklio [`params`][] maiše:

```ruby
class ClientsController < ApplicationController
  # Šis veiksmas naudoja užklausos eilutės parametrus, nes jis vykdomas
  # pagal HTTP GET užklausą, tačiau tai nesukelia jokios įtakos
  # kaip pasiekti parametrus. URL šiam veiksmui atrodytų taip, kad būtų išvardyti aktyvuoti
  # klientai: /clients?status=activated
  def index
    if params[:status] == "activated"
      @clients = Client.activated
    else
      @clients = Client.inactivated
    end
  end

  # Šis veiksmas naudoja POST parametrus. Jie tikriausiai ateina
  # iš HTML formos, kurią pateikė vartotojas. Šiam RESTful užklausos veiksmui URL bus "/clients",
  # o duomenys bus siunčiami kaip užklausos kūno dalis.
  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client
    else
      # Šis kodas perrašo numatytąjį atvaizdavimo elgesį, kuris
      # būtų buvęs atvaizduoti "create" rodinį.
      render "new"
    end
  end
end
```


### Maišo ir masyvo parametrai

`params` maišas nėra apribotas vienmačiais raktų ir reikšmių. Jame gali būti įdėti įdėti įdėti masyvai ir maišai. Norėdami išsiųsti reikšmių masyvą, prie rakto pavadinimo pridėkite tuščią porą laužtinių skliaustų "[]":

```
GET /clients?ids[]=1&ids[]=2&ids[]=3
```

PASTABA: Šio pavyzdžio tikras URL bus koduotas kaip "/clients?ids%5b%5d=1&ids%5b%5d=2&ids%5b%5d=3", nes "[" ir "]" simboliai URL nėra leidžiami. Daugumą laiko jums nereikia dėl to nerimauti, nes naršyklė jį užkoduos už jus, o „Rails“ jį automatiškai iškoduos, tačiau jei kada nors turėsite siųsti tas užklausas į serverį rankiniu būdu, turėtumėte tai prisiminti.

`params[:ids]` reikšmė dabar bus `["1", "2", "3"]`. Atkreipkite dėmesį, kad parametrų reikšmės visada yra eilutės; „Rails“ nebandys atspėti arba pakeisti tipo.

PASTABA: Reikšmės, tokios kaip `[nil]` arba `[nil, nil, ...]` `params` yra pakeičiamos
su `[]` saugumo sumetimais pagal numatytuosius nustatymus. Daugiau informacijos rasite [Saugumo vadove](security.html#unsafe-query-generation).

Norėdami išsiųsti maišą, įtraukite rakto pavadinimą į laužtinius skliaustus:

```html
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
```

Kai ši forma yra pateikiama, `params[:client]` reikšmė bus `{ "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } }`. Atkreipkite dėmesį į maišo maišą `params[:client][:address]`.

`params` objektas veikia kaip maišas, bet leidžia jums naudoti simbolius ir eilutes kaip raktus.

### JSON parametrai

Jei jūsų programa atskleidžia API, tikriausiai priimsite parametrus JSON formatu. Jei jūsų užklausos "Content-Type" antraštė nustatyta kaip "application/json", „Rails“ automatiškai įkelia parametrus į `params` maišą, kurį galite pasiekti kaip įprastai.

Todėl, pavyzdžiui, jei siunčiate šį JSON turinį:

```json
{ "company": { "name": "acme", "address": "123 Carrot Street" } }
```

Jūsų valdiklis gaus `params[:company]` kaip `{ "name" => "acme", "address" => "123 Carrot Street" }`.

Taip pat, jei jūs įjungėte `config.wrap_parameters` savo inicializacijoje arba iškvietėte [`wrap_parameters`][] savo valdiklyje, galite saugiai praleisti šakninį elementą JSON parametre. Šiuo atveju parametrai bus klonuojami ir apgaubiami raktu, pasirenkamu pagal jūsų valdiklio pavadinimą. Taigi, aukščiau pateiktą JSON užklausą galima parašyti taip:

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

Ir, priimant, kad duomenis siunčiate į `CompaniesController`, jie būtų apgaubti `:company` raktu taip:
```ruby
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: "123 Carrot Street" } }
```

Galite tinkinti rakto pavadinimą arba konkretų parametrą, kurį norite apgaubti, pasikonsultavę su [API dokumentacija](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)

PASTABA: Parametrų išanalizavimo palaikymas XML formatu buvo išskirtas į vadinamąjį `actionpack-xml_parser` gemą.


### Maršrutizavimo parametrai

`params` hash visada turės `:controller` ir `:action` rakto pavadinimus, tačiau geriau naudoti [`controller_name`][] ir [`action_name`][] metodus, kad pasiektumėte šias reikšmes. Bet kokie kiti maršrutizavimo apibrėžti parametrai, pvz., `:id`, taip pat bus prieinami. Pavyzdžiui, pagalvokime apie klientų sąrašą, kuriame sąraše gali būti rodomi aktyvūs arba neaktyvūs klientai. Galime pridėti maršrutą, kuris sugauna `:status` parametrą "gražiuoju" URL:

```ruby
get '/clients/:status', to: 'clients#index', foo: 'bar'
```

Šiuo atveju, kai vartotojas atidaro URL `/clients/active`, `params[:status]` bus nustatytas kaip "active". Kai naudojamas šis maršrutas, `params[:foo]` taip pat bus nustatytas kaip "bar", tarsi jis būtų perduotas užklausos eilutėje. Jūsų valdiklis taip pat gaus `params[:action]` kaip "index" ir `params[:controller]` kaip "clients".


### `default_url_options`

Galite nustatyti globalius numatytuosius parametrus URL generavimui, apibrėždami `default_url_options` metodą savo valdiklyje. Toks metodas turi grąžinti hash su norimais numatytuoju parametrais, kurių raktai turi būti simboliai:

```ruby
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

Šie parametrai bus naudojami kaip pradinė taško generuojant URL, todėl yra galimybė, kad jie bus perrašyti perduodant `url_for` iškvietimus.

Jei `default_url_options` apibrėžiate `ApplicationController`, kaip pavyzdyje aukščiau, šie numatytieji parametrai bus naudojami visiems URL generavimui. Šis metodas taip pat gali būti apibrėžtas konkrečiame valdiklyje, tada jis veikia tik generuojant URL šiame valdiklyje.

Konkretaus užklausos metu metodas iš tikrųjų nėra iškviečiamas kiekvienam sugeneruotam URL. Dėl našumo priežasčių grąžintas hash yra talpinamas talpykloje ir yra ne daugiau kaip vienas iškvietimas per užklausą.

### Stiprūs parametrai

Naudojant stipriuosius parametrus, veiksmo valdiklio parametrai yra draudžiami naudoti masiniam modelio priskyrimui, kol jie nebus leidžiami. Tai reiškia, kad turėsite sąmoningai nuspręsti, kurie atributai bus leidžiami masiniam atnaujinimui. Tai yra geresnė saugumo praktika, padedanti išvengti atsitiktinio vartotojų leidimo atnaujinti jautrius modelio atributus.

Be to, parametrai gali būti pažymėti kaip privalomi ir eiti per iš anksto apibrėžtą pakėlimo/gaudymo srautą, kuris rezultuos 400 blogo užklausos grąžinimu, jei nebus perduoti visi reikalingi parametrai.

```ruby
class PeopleController < ActionController::Base
  # Tai sukels ActiveModel::ForbiddenAttributesError išimtį,
  # nes naudojamas masinis priskyrimas be aiškaus leidimo
  # žingsnio.
  def create
    Person.create(params[:person])
  end

  # Tai sėkmingai įvyks, jei parametruose yra raktas "person",
  # kitu atveju tai sukels ActionController::ParameterMissing išimtį,
  # kuri bus sugauta ActionController::Base ir paversta 400 blogos
  # užklausos klaida.
  def update
    person = current_account.people.find(params[:id])
    person.update!(person_params)
    redirect_to person
  end

  private
    # Naudojant privačiąją metodą, kad apriboti leidžiamus parametrus,
    # yra geras modelis, nes galėsite perpanaudoti tą patį
    # leidžiamų atributų sąrašą tarp create ir update. Taip pat galite
    # specializuoti šį metodą su leidžiamų atributų tikrinimu pagal vartotoją.
    def person_params
      params.require(:person).permit(:name, :age)
    end
end
```

#### Leidžiami skalariški reikšmės

Kviečiant [`permit`][] taip:

```ruby
params.permit(:id)
```

leidžia nurodytą raktą (`:id`) įtraukti, jei jis yra `params` ir
jame yra leidžiama skalariška reikšmė. Kitu atveju, raktas bus
filtruojamas, todėl masyvai, hash'ai ar bet kokie kiti objektai negali būti
įterpti.

Leidžiamos skalariškos reikšmės yra `String`, `Symbol`, `NilClass`,
`Numeric`, `TrueClass`, `FalseClass`, `Date`, `Time`, `DateTime`,
`StringIO`, `IO`, `ActionDispatch::Http::UploadedFile` ir
`Rack::Test::UploadedFile`.

Norint nurodyti, kad reikšmė `params` turi būti masyvas iš leidžiamų
skalariškų reikšmių, priskirkite raktą tuščiam masyvui:

```ruby
params.permit(id: [])
```

Kartais neįmanoma arba nepatogu nurodyti hash parametro ar jo vidinės struktūros galiojančius raktus. Tiesiog priskirkite tuščiam hash'ui:

```ruby
params.permit(preferences: {})
```

tačiau būkite atsargūs, nes tai atveria duris bet kokiam įvesties duomeniui. Šiuo atveju, `permit` užtikrina, kad grąžinamoje struktūroje būtų leidžiamos skalariškos reikšmės ir filtruojamos visos kitos reikšmės.
Visiems parametrų maišams leidžiama naudoti [`permit!`][] metodą:

```ruby
params.require(:log_entry).permit!
```

Tai pažymi `:log_entry` parametrų maišą ir bet kurį jo sub-maišą kaip leistiną ir ne tikrina leistinų skalarių, priimami visi. Naudojant `permit!` reikia labai atsargiai, nes tai leis masiškai priskirti visus dabartinius ir ateities modelio atributus.


#### Įdėti parametrai

Taip pat galite naudoti `permit` su įdėtais parametrais, pvz .:

```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

Šis deklaravimas leidžia `name`, `emails` ir `friends` atributus. Tikimasi, kad `emails` bus leistinų skalarių reikšmių masyvas, o `friends` bus leistinų atributų resursų masyvas: jie turėtų turėti `name` atributą (leidžiamos bet kokios leistinos skalarių reikšmės), `hobbies` atributą kaip leistinų skalarių reikšmių masyvą ir `family` atributą, kuris yra apribotas turėti `name` (čia taip pat leidžiamos bet kokios leistinos skalarių reikšmės).

#### Daugiau pavyzdžių

Galite taip pat naudoti leistinus atributus savo `new` veiksmui. Tai kelia problemą, kad negalite naudoti [`require`][] šakninės rakto, nes įprastai ji neegzistuoja, kai iškviečiamas `new`:

```ruby
# naudodami `fetch` galite nurodyti numatytąją reikšmę ir naudoti
# Strong Parameters API iš ten.
params.fetch(:blog, {}).permit(:title, :author)
```

Modelio klasės metodas `accepts_nested_attributes_for` leidžia atnaujinti ir naikinti susijusius įrašus. Tai pagrįsta `id` ir `_destroy` parametrais:

```ruby
# leisti :id ir :_destroy
params.require(:author).permit(:name, books_attributes: [:title, :id, :_destroy])
```

Su sveikais skaičiais raktais maišai yra tvarkomi kitaip, ir galite deklaruoti atributus, tarsi jie būtų tiesioginiai vaikai. Tokius parametrus gaunate, kai naudojate `accepts_nested_attributes_for` kartu su `has_many` asociacija:

```ruby
# Leisti šiuos duomenis:
# {"book" => {"title" => "Some Book",
#             "chapters_attributes" => { "1" => {"title" => "First Chapter"},
#                                        "2" => {"title" => "Second Chapter"}}}}

params.require(:book).permit(:title, chapters_attributes: [:title])
```

Įsivaizduokite scenarijų, kai turite parametrus, kurie atitinka produkto pavadinimą, ir maišą su bet kokiomis produkto susijusiomis duomenų reikšmėmis, ir norite leisti produkto pavadinimo atributą ir taip pat visą duomenų maišą:

```ruby
def product_params
  params.require(:product).permit(:name, data: {})
end
```


#### Už ribų Strong Parameters

Stiprųjį parametrų API sukūrė dažniausiai pasitaikančioms naudojimo atvejams. Jis nėra skirtas visiems jūsų parametrų filtravimo problemoms spręsti. Tačiau galite lengvai derinti API su savo kodu, kad prisitaikytumėte prie savo situacijos.

Sesija
-------

Jūsų programoje kiekvienam vartotojui yra sesija, kurioje galite saugoti nedidelius kiekius duomenų, kurie bus išsaugoti tarp užklausų. Sesija yra prieinama tik kontroleryje ir peržiūroje ir gali naudoti vieną iš kelių skirtingų saugojimo mechanizmų:

* [`ActionDispatch::Session::CookieStore`][] - Visus duomenis saugo klientas.
* [`ActionDispatch::Session::CacheStore`][] - Duomenis saugo „Rails“ talpykla.
* [`ActionDispatch::Session::MemCacheStore`][] - Duomenis saugo „memcached“ klasteris (ši yra senesnė įgyvendinimas; verta naudoti „CacheStore“ vietoj to).
* [`ActionDispatch::Session::ActiveRecordStore`][activerecord-session_store] -
  Duomenis saugo duomenų bazė, naudojant „Active Record“ (reikalauja
  [`activerecord-session_store`][activerecord-session_store] grotelės)
* Pasirinktinis saugojimo būdas arba trečiųjų šalių grotelės teikiamas saugojimo būdas

Visos sesijos saugyklos naudoja slapuką, kad būtų saugomas unikalus sesijos ID (negalite perduoti sesijos ID URL, nes tai mažiau saugu).

Daugeliui saugyklų šis ID naudojamas ieškant sesijos duomenų serveryje, pvz., duomenų bazės lentelėje. Yra viena išimtis, tai yra numatytoji ir rekomenduojama sesijos saugykla - „CookieStore“, kuri saugo visus sesijos duomenis pačiame slapuke (ID vis tiek yra prieinamas, jei jums reikia). Tai turi pranašumą, kad yra labai lengvas ir naujoje programoje nereikia jokios sąrankos, kad būtų naudojama sesija. Slapuko duomenys yra šifruojami, kad būtų užtikrinta jų nekintamumas. Jie taip pat yra užšifruoti, todėl niekas, turintis prieigą prie jų, negali perskaityti jų turinio („Rails“ jų nepriims, jei jie bus redaguoti).

„CookieStore“ gali saugoti apie 4 kB duomenų - daug mažiau nei kiti - bet tai paprastai pakanka. Nepriklauso nuo to, kurią sesijos saugyklą naudoja jūsų programa, rekomenduojama vengti saugoti didelius duomenų kiekius sesijoje. Ypač turėtumėte vengti saugoti sudėtingus objektus (tokius kaip modelio egzemplioriai) sesijoje, nes serveris gali nepavykti juos suderinti tarp užklausų, kas sukels klaidą.
Jei jūsų vartotojo sesijos nekrauna kritinių duomenų arba nereikia ilgai laikyti (pavyzdžiui, jei naudojate "flash" pranešimams), galite apsvarstyti naudoti `ActionDispatch::Session::CacheStore`. Tai leis saugoti sesijas naudojant jūsų programai sukonfigūruotą talpyklą. Tai turi privalumų, nes galite naudoti esamą talpyklų infrastruktūrą sesijų saugojimui be papildomo sąrankos ar administravimo. Žinoma, trūkumas yra tas, kad sesijos bus laikinos ir gali išnykti bet kuriuo metu.

Daugiau informacijos apie sesijų saugojimą rasite [Saugumo vadove](security.html).

Jei jums reikia kitokio sesijų saugojimo mechanizmo, galite jį pakeisti inicializavimo metu:

```ruby
Rails.application.config.session_store :cache_store
```

Daugiau informacijos rasite [`config.session_store`](configuring.html#config-session-store) konfigūracijos vadove.

Rails nustato sesijos raktą (slapuko pavadinimą), kai pasirašo sesijos duomenis. Juos taip pat galima pakeisti inicializavimo metu:

```ruby
# Įsitikinkite, kad perkraunate serverį, kai keičiate šį failą.
Rails.application.config.session_store :cookie_store, key: '_your_app_session'
```

Taip pat galite perduoti `:domain` raktą ir nurodyti slapuko domeno pavadinimą:

```ruby
# Įsitikinkite, kad perkraunate serverį, kai keičiate šį failą.
Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: ".example.com"
```

Rails nustato (naudojant `CookieStore`) paslėptą raktą, naudojamą sesijos duomenų pasirašymui `config/credentials.yml.enc`. Jį galima pakeisti naudojant `bin/rails credentials:edit`.

```yaml
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# Naudojamas kaip pagrindinis paslėptas raktas visiems MessageVerifiers
# Rails, įskaitant slapukus apsaugančią raktą.
secret_key_base: 492f...
```

PASTABA: Keičiant `secret_key_base`, naudojant `CookieStore`, bus nebegaliojantys visi esami seansai.



### Prieiga prie sesijos

Savo valdiklyje galite pasiekti sesiją per `session` objekto metodą.

PASTABA: Sesijos yra tingiai įkraunamos. Jei jūsų veiksmo kode nenaudojate sesijų, jos nebus įkraunamos. Todėl jums niekada nereikės išjungti sesijų, tiesiog jų nepasiekimas atliks darbą.

Sesijos reikšmės saugomos naudojant raktų/vertės poras kaip hash'ą:

```ruby
class ApplicationController < ActionController::Base
  private
    # Suranda vartotoją su ID, saugomu sesijoje su raktu
    # :current_user_id Tai paprastas būdas tvarkyti vartotojo prisijungimą
    # Rails programoje; prisijungimas nustato sesijos reikšmę ir
    # atsijungimas ją pašalina.
    def current_user
      @_current_user ||= session[:current_user_id] &&
        User.find_by(id: session[:current_user_id])
    end
end
```

Norėdami kažką saugoti sesijoje, tiesiog priskirkite tai rakto vertei kaip hash'e:

```ruby
class LoginsController < ApplicationController
  # "Sukurkite" prisijungimą, t. y. "prisijunkite vartotoją"
  def create
    if user = User.authenticate(params[:username], params[:password])
      # Įrašykite vartotojo ID į sesiją, kad jį galėtumėte naudoti
      # kituose užklausuose
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end
end
```

Norėdami pašalinti kažką iš sesijos, ištrinkite rakto/vertės porą:

```ruby
class LoginsController < ApplicationController
  # "Ištrinkite" prisijungimą, t. y. "atsijunkite nuo vartotojo"
  def destroy
    # Pašalinkite vartotojo ID iš sesijos
    session.delete(:current_user_id)
    # Išvalykite memoizuotą dabartinį vartotoją
    @_current_user = nil
    redirect_to root_url, status: :see_other
  end
end
```

Norėdami atkurti visą sesiją, naudokite [`reset_session`][].


### "Flash"

"Flash" yra speciali sesijos dalis, kuri yra išvaloma su kiekviena užklausa. Tai reiškia, kad ten saugomos vertės bus prieinamos tik kitame užklausos etape, kas yra naudinga perduoti klaidų pranešimus ir kt.

"Flash" pasiekiamas per [`flash`][] metodą. Kaip ir sesija, "flash" yra pateikiamas kaip hash'as.

Paimkime atsijungimo veiksmą kaip pavyzdį. Valdiklis gali siųsti pranešimą, kuris bus rodomas vartotojui kitame užklausos etape:

```ruby
class LoginsController < ApplicationController
  def destroy
    session.delete(:current_user_id)
    flash[:notice] = "Jūs sėkmingai atsijungėte."
    redirect_to root_url, status: :see_other
  end
end
```

Reikėtų pažymėti, kad taip pat galima priskirti "flash" pranešimą kaip dalį peradresavimo. Galite priskirti `:notice`, `:alert` arba bendro naudojimo `:flash`:

```ruby
redirect_to root_url, notice: "Jūs sėkmingai atsijungėte."
redirect_to root_url, alert: "Jūs užstrigate čia!"
redirect_to root_url, flash: { referral_code: 1234 }
```

"Destroy" veiksmas peradresuoja į programos `root_url`, kur pranešimas bus rodomas. Reikėtų pažymėti, kad visiškai priklauso nuo kitos veiksmo, ką, jei visai, jis padarys su tuo, ką ankstesnis veiksmas įdėjo į "flash". Įprasta rodyti bet kokius klaidų pranešimus ar pastabas iš "flash" programos išdėstyme:
```erb
<html>
  <!-- <head/> -->
  <body>
    <% flash.each do |name, msg| -%>
      <%= content_tag :div, msg, class: name %>
    <% end -%>

    <!-- more content -->
  </body>
</html>
```

Taip padaryta, jei veiksmas nustato pranešimą arba įspėjimą, maketas jį automatiškai rodo.

Galite perduoti bet ką, ką sesija gali saugoti; jūs nesate apribotas tik pranešimais ir įspėjimais:

```erb
<% if flash[:just_signed_up] %>
  <p class="welcome">Sveiki atvykę į mūsų svetainę!</p>
<% end %>
```

Jei norite, kad flash reikšmė būtų perduota kitam užklausimui, naudokite [`flash.keep`][]:

```ruby
class MainController < ApplicationController
  # Tarkime, šis veiksmas atitinka root_url, bet norite,
  # kad visos užklausos čia būtų nukreiptos į UsersController#index.
  # Jei veiksmas nustato flash ir nukreipia čia, reikšmės
  # paprastai būtų prarandamos, kai vyksta kitas nukreipimas, bet jūs
  # galite naudoti 'keep', kad jis išliktų kitai užklausai.
  def index
    # Išlaikys visus flash reikšmes.
    flash.keep

    # Taip pat galite naudoti raktą, kad išlaikytumėte tik tam tikrą reikšmę.
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```


#### `flash.now`

Pagal numatytuosius nustatymus, pridedant reikšmes prie flash, jos bus prieinamos kitai užklausai, bet kartais norite prieiti prie tų reikšmių toje pačioje užklausoje. Pavyzdžiui, jei `create` veiksmas nepavyksta išsaugoti išteklių ir tiesiogiai atvaizduojate `new` šabloną, tai nesukels naujos užklausos, bet vis tiek norite rodyti pranešimą naudojant flash. Tam galite naudoti [`flash.now`][] taip pat, kaip naudojate įprastą `flash`:

```ruby
class ClientsController < ApplicationController
  def create
    @client = Client.new(client_params)
    if @client.save
      # ...
    else
      flash.now[:error] = "Nepavyko išsaugoti kliento"
      render action: "new"
    end
  end
end
```


Slapukai
-------

Jūsų programa gali saugoti mažas duomenų dalis kliente - vadinamus slapukais - kurie bus išsaugoti tarp užklausų ir netgi sesijų. „Rails“ lengvai prieiga prie slapukų per [`cookies`][] metodą, kuris - panašiai kaip ir `session` - veikia kaip hiešutė:

```ruby
class CommentsController < ApplicationController
  def new
    # Automatiškai užpildykite komentuotojo vardą, jei jis buvo saugomas slapuke
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:notice] = "Ačiū už jūsų komentarą!"
      if params[:remember_name]
        # Išsaugokite komentuotojo vardą.
        cookies[:commenter_name] = @comment.author
      else
        # Ištrinkite slapuką komentuotojo vardo, jei toks yra.
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

Atkreipkite dėmesį, kad, nors sesijos reikšmėms galite nustatyti raktą į `nil`, norėdami ištrinti slapuko reikšmę, turėtumėte naudoti `cookies.delete(:key)`.

„Rails“ taip pat teikia pasirašytą slapuko talpyklą ir užšifruotą slapuko talpyklą, skirtą jautrių duomenų saugojimui.
Pasirašytas slapuko talpykla prideda kriptografinį parašą prie slapuko reikšmių, kad būtų apsaugota jų vientisumas. Užšifruota slapuko talpykla šifravimo metu prideda reikšmes, kad jos negalėtų būti perskaitytos naudotojo.
Daugiau informacijos rasite [API dokumentacijoje](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html).

Šios specialios slapukų talpyklos naudoja serijalizatorių, kad serijalizuotų priskirtas reikšmes į eilutes ir juos deserializuotų į „Ruby“ objektus skaitymo metu. Galite nurodyti, kurį serijalizatorių naudoti per [`config.action_dispatch.cookies_serializer`][].

Numatytasis serijalizatorius naujoms programoms yra `:json`. Būkite atsargūs, kad „JSON“ ribotai palaiko „Ruby“ objektų apskritai. Pavyzdžiui, `Date`, `Time` ir
`Symbol` objektai (įskaitant `Hash` raktus) bus serijalizuojami ir deserializuojami į `String`:

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

Jei norite saugoti šiuos ar sudėtingesnius objektus, galite turėti rankiniu būdu
konvertuoti jų reikšmes, kai jas skaitote kitose užklausose.

Jei naudojate slapuko sesijos talpyklą, tai taikoma ir `session` ir
`flash` hiešutėms.
Daugiau informacijos apie vaizdavimą rasite [Maketų ir vaizdavimo vadove](layouts_and_rendering.html).

Filtrai
-------

Filtrai yra metodai, kurie vykdomi "prieš", "po" arba "apie" valdiklio veiksmą.

Filtrai paveldimi, todėl jei nustatote filtrą "ApplicationController", jis bus vykdomas visuose jūsų programos valdikliuose.

"prieš" filtrai yra registruojami naudojant [`before_action`][]. Jie gali sustabdyti užklausos ciklą. Dažnas "prieš" filtras yra toks, kuris reikalauja, kad vartotojas būtų prisijungęs, kad veiksmas būtų vykdomas. Filtrą galite apibrėžti šiuo būdu:

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private
    def require_login
      unless logged_in?
        flash[:error] = "Norint pasiekti šį skyrių, turite būti prisijungęs"
        redirect_to new_login_url # sustabdo užklausos ciklą
      end
    end
end
```

Metodas tiesiog saugo klaidos pranešimą atmintyje ir nukreipia į prisijungimo formą, jei vartotojas nėra prisijungęs. Jei "prieš" filtras vaizduoja arba nukreipia, veiksmas nebus vykdomas. Jei po to yra planuojami vykdyti papildomi filtrai, jie taip pat bus atšaukti.

Šiame pavyzdyje filtras pridedamas prie `ApplicationController`, todėl jį paveldi visi valdikliai programoje. Tai reiškia, kad viskas programoje reikalauja, kad vartotojas būtų prisijungęs, kad ją naudotų. Dėl akivaizdžių priežasčių (vartotojas iš pradžių negalėtų prisijungti!), ne visi valdikliai ar veiksmai turėtų tai reikalauti. Galite užkirsti kelią šiam filtrui vykdyti prieš tam tikrus veiksmus naudodami [`skip_before_action`][]:

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

Dabar `LoginsController` `new` ir `create` veiksmai veiks kaip anksčiau, nereikalaujant, kad vartotojas būtų prisijungęs. `:only` parinktis naudojama šiam filtrui praleisti tik šiuos veiksmus, taip pat yra `:except` parinktis, kuri veikia kitaip. Šias parinktis galima naudoti ir pridedant filtrus, taigi galite pridėti filtrą, kuris vykdomas tik pasirinktiems veiksmams iš pradžių.

PASTABA: Skambinant to paties filtro kelis kartus su skirtingomis parinktimis, tai neveiks,
nes paskutinė filtro apibrėžtis perrašys ankstesnes.

### Po filtrai ir Apie filtrai

Be "prieš" filtrų, taip pat galite vykdyti filtrus po veiksmo vykdymo arba tiek prieš, tiek po.

"po" filtrai yra registruojami naudojant [`after_action`][]. Jie panašūs į "prieš" filtrus, bet kadangi veiksmas jau buvo vykdytas, jie turi prieigą prie atsakymo duomenų, kurie bus siunčiami klientui. Aišku, "po" filtrai negali sustabdyti veiksmo vykdymo. Atkreipkite dėmesį, kad "po" filtrai vykdomi tik po sėkmingo veiksmo, bet nekyla išimtis užklausos cikle.

"apie" filtrai yra registruojami naudojant [`around_action`][]. Jie atsakingi už savo susijusius veiksmus paleidimą, naudojant `yield`, panašiai kaip veikia Rack tarpinės programinės įrangos.

Pavyzdžiui, svetainėje, kurioje pakeitimai turi patvirtinimo darbo eigos, administratorius galėtų juos lengvai peržiūrėti, taikydamas juos per transakciją:

```ruby
class ChangesController < ApplicationController
  around_action :wrap_in_transaction, only: :show

  private
    def wrap_in_transaction
      ActiveRecord::Base.transaction do
        begin
          yield
        ensure
          raise ActiveRecord::Rollback
        end
      end
    end
end
```

Atkreipkite dėmesį, kad "apie" filtras taip pat apgaubia vaizdavimą. Ypač pavyzdyje, jei pats vaizdas skaito iš duomenų bazės (pvz., per apimtį), jis tai padarys transakcijoje ir taip pateiks duomenis peržiūrai.

Galite nuspręsti nevykdyti `yield` ir patys sukurti atsakymą, tuo atveju veiksmas nebus vykdomas.

### Kitos būdai naudoti filtrus

Nors paprasčiausias būdas naudoti filtrus yra kurti privačius metodus ir naudoti `before_action`, `after_action` ar `around_action`, yra dar du būdai tai padaryti.

Pirmasis būdas yra tiesiogiai naudoti bloką su `*_action` metodais. Blokas gauna valdiklį kaip argumentą. Viršuje pateiktas `require_login` filtras galėtų būti pertvarkytas naudojant bloką:

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless controller.send(:logged_in?)
      flash[:error] = "Norint pasiekti šį skyrių, turite būti prisijungęs"
      redirect_to new_login_url
    end
  end
end
```

Atkreipkite dėmesį, kad šiuo atveju filtras naudoja `send`, nes `logged_in?` metodas yra privatus, o filtras nevykdomas valdiklio kontekste. Tai nėra rekomenduojamas būdas įgyvendinti šį konkretų filtrą, bet paprastesniais atvejais tai gali būti naudinga.
Konkrečiai `around_action` blokas taip pat grąžina `action`:

```ruby
around_action { |_controller, action| time(&action) }
```

Antrasis būdas yra naudoti klasę (iš tikrųjų, bet koks objektas, kuris atsako į tinkamus metodus, tiks) filtravimui tvarkyti. Tai naudinga sudėtingesniems atvejams, kurie negali būti įgyvendinti naudojant kitus du metodus suprantamu ir perpanaudojamu būdu. Pavyzdžiui, galite dar kartą parašyti prisijungimo filtrą, kad naudotų klasę:

```ruby
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.before(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "You must be logged in to access this section"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

Vėlgi, tai nėra idealus pavyzdys šiam filtrui, nes jis nėra vykdomas kontrolerio kontekste, bet gauna kontrolerį kaip argumentą. Filtravimo klasė turi įgyvendinti metodą su tuo pačiu pavadinimu kaip ir filtras, todėl `before_action` filtrui klasė turi įgyvendinti `before` metodą ir t.t. `around` metodas turi `yield` norint vykdyti veiksmą.

Užklausos suklastojimo apsauga
--------------------------

Tarp svetainių užklausos suklastojimas yra ataka, kurioje svetainė apgaudinėja naudotoją, kad jis atliktų užklausas kitose svetainėse, galbūt pridedant, keičiant arba trinant duomenis šioje svetainėje be naudotojo žinios ar leidimo.

Pirmasis žingsnis, siekiant to išvengti, yra užtikrinti, kad visos "naikinančios" veiksmų (kūrimas, atnaujinimas ir trynimas) galima pasiekti tik naudojant ne-GET užklausas. Jei laikotės RESTful konvencijų, jau tai darote. Tačiau kenksminga svetainė vis tiek gali lengvai siųsti ne-GET užklausą į jūsų svetainę, ir tai yra vieta, kur atsiranda užklausos suklastojimo apsauga. Kaip jau minima pavadinime, ji apsaugo nuo suklastotų užklausų.

Tai daroma pridedant neįspėjamą žymą, kurią žino tik jūsų serveris, prie kiekvienos užklausos. Taip, jei užklausa ateina be tinkamos žymos, ji bus uždrausta.

Jei sukuriate formą taip:

```erb
<%= form_with model: @user do |form| %>
  <%= form.text_field :username %>
  <%= form.text_field :password %>
<% end %>
```

Matysite, kaip žyma pridedama kaip paslėptas laukas:

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- fields -->
</form>
```

Rails prideda šią žymą prie kiekvienos formos, kuri yra generuojama naudojant [formos pagalbininkus](form_helpers.html), todėl daugumą laiko jums nereikia dėl to jaudintis. Jei rašote formą rankiniu būdu arba turite pridėti žymą dėl kitos priežasties, ji yra pasiekiamas per metodą `form_authenticity_token`:

`form_authenticity_token` generuoja tinkamą autentifikacijos žymą. Tai naudinga vietose, kur Rails jos automatiškai neprideda, pvz., pasirinktiniuose Ajax kvietimuose.

[Daugiau apie tai galite rasti Saugumo vadove](security.html), taip pat daugiau apie kitas saugumo problemas, kurias turėtumėte žinoti kuriant internetinę programą.

Užklausos ir atsakymo objektai
--------------------------------

Kiekvienoje kontroleryje yra du pasiekimo metodai, rodantys užklausos ir atsakymo objektus, susijusius su vykdoma užklausos ciklu. [`request`][] metodas yra [`ActionDispatch::Request`][] objekto pavyzdys, o [`response`][] metodas grąžina atsakymo objektą, kuris bus siunčiamas klientui.


### `request` objektas

Užklausos objektas turi daug naudingos informacijos apie užklausą, kuri ateina iš kliento. Norėdami gauti visą galimų metodų sąrašą, žiūrėkite [Rails API dokumentaciją](https://api.rubyonrails.org/classes/ActionDispatch/Request.html) ir [Rack dokumentaciją](https://www.rubydoc.info/github/rack/rack/Rack/Request). Tarp savybių, prieinamų šiame objekte, yra:

| `request` savybės                     | Paskirtis                                                                          |
| ----------------------------------------- | -------------------------------------------------------------------------------- |
| `host`                                    | Šios užklausos naudojamas kompiuterio vardas.                                              |
| `domain(n=2)`                             | Šio kompiuterio vardo pirmieji `n` segmentai, pradedant nuo dešinės (TLD).            |
| `format`                                  | Kliento užklausoje nurodytas turinio tipas.                                        |
| `method`                                  | Užklausai naudotas HTTP metodas.                                            |
| `get?`, `post?`, `patch?`, `put?`, `delete?`, `head?` | Grąžina `true`, jei HTTP metodas yra GET/POST/PATCH/PUT/DELETE/HEAD.   |
| `headers`                                 | Grąžina raktų rinkinį, kuriame yra užklausai priskirti antraštės.               |
| `port`                                    | Užklausai naudotas prievadas (sveikasis skaičius).                                  |
| `protocol`                                | Grąžina eilutę, kurią sudaro naudotas protokolas ir "://", pvz., "http://". |
| `query_string`                            | URL užklausos eilutės dalis, t. y. viskas po "?".                    |
| `remote_ip`                               | Kliento IP adresas.                                                    |
| `url`                                     | Visas URL, naudotas užklausai.                                             |
#### `path_parameters`, `query_parameters` ir `request_parameters`

Rails renka visus parametrus, siunčiamus kartu su užklausa, `params` hash'e, nepriklausomai nuo to, ar jie siunčiami kaip dalis užklausos eilutės, ar kaip dalis pranešimo kūno. Užklausos objektas turi tris prieigos metodus, kurie suteikia prieigą prie šių parametrų pagal tai, iš kur jie kilo. [`query_parameters`][] hash'as yra parametrai, kurie buvo siunčiami kaip dalis užklausos eilutės, o [`request_parameters`][] hash'as yra parametrai, siunčiami kaip dalis pranešimo kūno. [`path_parameters`][] hash'as yra parametrai, kurie buvo pripažinti maršrutizavimo metu kaip esantys šio konkretaus valdiklio ir veiksmo kelyje.

### `response` objektas

Įprastai tiesiogiai nenaudojamas atsakymo objektas yra sukuriamas vykdant veiksmą ir atvaizduojant duomenis, kurie siunčiami atgal naudotojui, bet kartais - pavyzdžiui, po filtru - gali būti naudinga tiesiogiai pasiekti atsakymą. Kai kurių šių prieigos metodų taip pat yra nustatymo metodai, leidžiantys pakeisti jų reikšmes. Norėdami gauti visą galimų metodų sąrašą, žiūrėkite [Rails API dokumentaciją](https://api.rubyonrails.org/classes/ActionDispatch/Response.html) ir [Rack dokumentaciją](https://www.rubydoc.info/github/rack/rack/Rack/Response).

| `response` savybė | Tikslas                                                                                              |
| ----------------- | ---------------------------------------------------------------------------------------------------- |
| `body`            | Tai yra duomenų eilutė, siunčiama klientui. Dažniausiai tai yra HTML.                                   |
| `status`          | HTTP būsenos kodas atsakui, pvz., 200 sėkmingai užklausai arba 404, jei failas nerastas.                |
| `location`        | URL, į kurį klientas nukreipiamas, jei toks yra.                                                       |
| `content_type`    | Atsakymo turinio tipas.                                                                              |
| `charset`         | Atsakymui naudojamas simbolių rinkinys. Numatytasis yra "utf-8".                                        |
| `headers`         | Atsakymui naudojami antraštės.                                                                        |

#### Nustatant pasirinktines antraštes

Jei norite nustatyti pasirinktines antraštes atsakymui, tuomet `response.headers` yra tinkamas vieta tai padaryti. Antraštės atributas yra hash'as, kuris susieja antraščių pavadinimus su jų reikšmėmis, ir Rails automatiškai nustato kai kurias iš jų. Jei norite pridėti ar pakeisti antraštę, tiesiog priskirkite ją `response.headers` taip:

```ruby
response.headers["Content-Type"] = "application/pdf"
```

PASTABA: Aukščiau pateiktu atveju daugiau prasmės turėtų naudoti `content_type` nustatymo metodą.

HTTP autentifikacija
--------------------

Rails turi tris įdiegtus HTTP autentifikacijos mechanizmus:

* Pagrindinė autentifikacija
* Skaidri autentifikacija
* Žetonų autentifikacija

### Pagrindinė autentifikacija

Pagrindinė autentifikacija yra autentifikacijos schema, kurią palaiko dauguma naršyklių ir kitų HTTP klientų. Pavyzdžiui, pagalvokite apie administravimo skyrių, kuris bus prieinamas tik įvedus vartotojo vardą ir slaptažodį į naršyklės pagrindinio HTTP dialogo langą. Norint naudoti įdiegtą autentifikaciją, tereikia naudoti vieną metodą, [`http_basic_authenticate_with`][].

```ruby
class AdminsController < ApplicationController
  http_basic_authenticate_with name: "humbaba", password: "5baa61e4"
end
```

Turint tai, galite kurti vardų erdvinės valdiklius, kurie paveldi iš `AdminsController`. Filtras bus taikomas visiems veiksmams šiuose valdikliuose, apsaugant juos pagrindine HTTP autentifikacija.

### Skaidri autentifikacija

Skaidri autentifikacija yra geresnė nei pagrindinė autentifikacija, nes ji nereikalauja, kad klientas siųstų neužšifruotą slaptažodį per tinklą (nors pagrindinė autentifikacija yra saugi naudojant HTTPS). Skaidrios autentifikacijos naudojimui su Rails tereikia naudoti vieną metodą, [`authenticate_or_request_with_http_digest`][].

```ruby
class AdminsController < ApplicationController
  USERS = { "lifo" => "world" }

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_digest do |username|
        USERS[username]
      end
    end
end
```

Kaip matyti pavyzdyje aukščiau, `authenticate_or_request_with_http_digest` blokas priima tik vieną argumentą - vartotojo vardą. O blokas grąžina slaptažodį. Grąžinant `false` arba `nil` iš `authenticate_or_request_with_http_digest` sukels autentifikacijos nesėkmę.

### Žetonų autentifikacija

Žetonų autentifikacija yra schema, leidžianti naudoti žetonų autentifikaciją HTTP `Authorization` antraštėje. Yra daug žetonų formatų, ir jų aprašymas yra už šio dokumento ribų.

Pavyzdžiui, jei norite naudoti iš anksto išduotą autentifikacijos žetoną autentifikacijai ir prieigai, žetonų autentifikacijos įgyvendinimui su Rails tereikia naudoti vieną metodą, [`authenticate_or_request_with_http_token`][].

```ruby
class PostsController < ApplicationController
  TOKEN = "secret"

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
    end
end
```

Kaip matyti pavyzdyje aukščiau, `authenticate_or_request_with_http_token` blokas priima du argumentus - žetoną ir `Hash` su parinktimis, kurios buvo išanalizuotos iš HTTP `Authorization` antraštės. Blokas turėtų grąžinti `true`, jei autentifikacija sėkminga. Grąžinant `false` arba `nil` sukels autentifikacijos nesėkmę.
Srautinė perdavimas ir failų atsisiuntimai
----------------------------

Kartais norite siųsti failą vartotojui, o ne atvaizduoti HTML puslapį. Visi „Rails“ valdikliai turi [`send_data`][] ir [`send_file`][] metodus, kurie abu srautina duomenis į klientą. `send_file` yra patogus metodas, leidžiantis nurodyti failo pavadinimą diske, o jis srautins failo turinį už jus.

Norėdami srautinti duomenis į klientą, naudokite `send_data`:

```ruby
require "prawn"
class ClientsController < ApplicationController
  # Generuoja PDF dokumentą su informacija apie klientą ir
  # grąžina jį. Vartotojas gaus PDF kaip failo atsisiuntimą.
  def download_pdf
    client = Client.find(params[:id])
    send_data generate_pdf(client),
              filename: "#{client.name}.pdf",
              type: "application/pdf"
  end

  private
    def generate_pdf(client)
      Prawn::Document.new do
        text client.name, align: :center
        text "Adresas: #{client.address}"
        text "El. paštas: #{client.email}"
      end.render
    end
end
```

Pirmiau pateikto pavyzdžio `download_pdf` veiksmas iškvies privačią metodą, kuris iš tikrųjų generuos PDF dokumentą ir grąžins jį kaip eilutę. Ši eilutė tada bus srautinama į klientą kaip failo atsisiuntimas, o vartotojui bus siūlomas failo pavadinimas. Kartais siunčiant failus vartotojui, gali būti norima, kad jie neatidarytų failo. Pavyzdžiui, tai galioja vaizdams, kurie gali būti įterpti į HTML puslapius. Norėdami nurodyti naršyklei, kad failas nėra skirtas atsisiuntimui, galite nustatyti `:disposition` parinktį į "inline". Priešingas ir numatytasis šios parinkties vertė yra "attachment".


### Siuntimas failų

Jei norite siųsti failą, kuris jau yra diske, naudokite `send_file` metodą.

```ruby
class ClientsController < ApplicationController
  # Srautina failą, kuris jau buvo sugeneruotas ir saugomas diske.
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

Tai perskaitys ir srautins failą po 4 kB, vengiant viso failo vienu metu įkėlimo į atmintį. Galite išjungti srautinimą naudojant `:stream` parinktį arba reguliuoti bloko dydį naudojant `:buffer_size` parinktį.

Jei `:type` nenurodytas, jis bus spėjamas iš `:filename` nurodyto failo plėtinio. Jei turinio tipas nėra registruotas plėtinio atžvilgiu, bus naudojamas `application/octet-stream`.

ĮSPĖJIMAS: Būkite atsargūs, naudodami iš kliento gaunamus duomenis (parametrus, slapukus ir kt.), kad rastumėte failą diske, nes tai yra saugumo rizika, kuri gali leisti kam nors gauti prieigą prie failų, kuriems jie neturėtų turėti prieigos.

PATARIMAS: Jei galite, nerekomenduojama srautinti statinius failus per „Rails“, o geriau juos laikyti viešoje aplanke savo interneto serverio. Daug efektyviau leisti vartotojui tiesiogiai atsisiųsti failą naudojant „Apache“ ar kitą interneto serverį, kad užklausa nereikštų nereikalingo perėjimo per visą „Rails“ sistemą.

### RESTful atsisiuntimai

Nors `send_data` veikia gerai, jei kuriate RESTful aplikaciją, atskiri veiksmai failų atsisiuntimui paprastai nėra būtini. REST terminologijoje pavyzdžio PDF failą galima laikyti tiesiog kita kliento resurso reprezentacija. „Rails“ suteikia patogų būdą atlikti „RESTful“ atsisiuntimus. Taip galite perrašyti pavyzdį, kad PDF atsisiuntimas būtų dalis `show` veiksmo, be jokio srautinimo:

```ruby
class ClientsController < ApplicationController
  # Vartotojas gali paprašyti gauti šį išteklių kaip HTML arba PDF.
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

Kad šis pavyzdys veiktų, turite pridėti PDF MIME tipą prie „Rails“. Tai galima padaryti pridėjus šią eilutę į failą `config/initializers/mime_types.rb`:

```ruby
Mime::Type.register "application/pdf", :pdf
```

PASTABA: Konfigūracijos failai nėra perkraunami kiekvieną užklausą, todėl turite paleisti serverį, kad jų pakeitimai įsigaliotų.

Dabar vartotojas gali paprašyti gauti kliento PDF versiją, tiesiog pridėdamas ".pdf" prie URL:

```
GET /clients/1.pdf
```

### Tiesioginio duomenų srautinio perdavimo

„Rails“ leidžia srautinti ne tik failus. Iš tikrųjų, galite srautinti bet ką, ko norite, atsakymo objekte. [`ActionController::Live`][] modulis leidžia jums sukurti nuolatinį ryšį su naršykle. Naudodami šį modulį, galėsite siųsti bet kokius duomenis į naršyklę tam tikrais laiko momentais.
#### Tiesioginio srauto įtraukimas

Įtraukus `ActionController::Live` į savo valdiklio klasę, visi veiksmai valdiklyje įgis galimybę srauti duomenis. Galite įterpti modulį taip:

```ruby
class MyController < ActionController::Base
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    100.times {
      response.stream.write "hello world\n"
      sleep 1
    }
  ensure
    response.stream.close
  end
end
```

Pirmiau pateiktas kodas išlaikys nuolatinį ryšį su naršykle ir išsiųs 100 žinučių "hello world\n", kiekvieną sekundę viena nuo kitos.

Yra keletas dalykų, kuriuos reikia pastebėti pirmiau pateiktame pavyzdyje. Turime užtikrinti, kad uždarytume atsakymo srautą. Jei pamiršite uždaryti srautą, lizdas liks atviras amžinai. Taip pat turime nustatyti turinio tipą kaip `text/event-stream` prieš rašydami į atsakymo srautą. Tai dėl to, kad antraštės negali būti rašomos po to, kai atsakymas yra įvykdytas (kai `response.committed?` grąžina tiesą), kas įvyksta, kai rašote arba įvykdote atsakymo srautą.

#### Pavyzdinė naudojimo instrukcija

Tarkime, kad kuriate karaoke aparatą, ir vartotojas nori gauti tekstus tam tikrai dainai. Kiekviena "Daina" turi tam tikrą eilučių skaičių, o kiekviena eilutė užtrunka `num_beats` laiko, kol baigiasi dainavimas.

Jei norėtume grąžinti tekstus karaoke stiliaus (siųsti tik tada, kai dainininkas baigė ankstesnę eilutę), galėtume naudoti `ActionController::Live` taip:

```ruby
class LyricsController < ActionController::Base
  include ActionController::Live

  def show
    response.headers['Content-Type'] = 'text/event-stream'
    song = Song.find(params[:id])

    song.each do |line|
      response.stream.write line.lyrics
      sleep line.num_beats
    end
  ensure
    response.stream.close
  end
end
```

Pirmiau pateiktas kodas siunčia kitą eilutę tik tada, kai dainininkas baigė ankstesnę eilutę.

#### Srauto svarstymas

Srautinės bet kokios informacijos siuntimas yra labai galingas įrankis. Kaip parodyta ankstesniuose pavyzdžiuose, galite pasirinkti, kada ir ką siųsti per atsakymo srautą. Tačiau taip pat turėtumėte atkreipti dėmesį į šiuos dalykus:

* Kiekvienas atsakymo srautas sukuria naują giją ir nukopijuoja gijos vietines kintamąsias iš pradinės gijos. Turint per daug vietinių kintamųjų, gali būti neigiamai paveiktas našumas. Panašiai, didelis gijų skaičius taip pat gali trukdyti našumui.
* Neuždarius atsakymo srauto, atitinkamas lizdas liks atviras amžinai. Įsitikinkite, kad kiekvieną kartą naudojant atsakymo srautą iškviečiate `close` metodą.
* WEBrick serveriai saugo visus atsakymus buferiuose, todėl įtraukus `ActionController::Live` tai neveiks. Turite naudoti serverį, kuris automatiškai nebuferiuoja atsakymų.

Žurnalo filtravimas
-------------

Rails saugo žurnalo failą kiekvienai aplinkai `log` aplanke. Jie yra labai naudingi, kai derinate, kas iš tikrųjų vyksta jūsų programoje, tačiau gyvoje programoje galite nenorėti, kad visi informacija būtų saugoma žurnalo faile.

### Parametrų filtravimas

Galite filtruoti jautrius užklausos parametrus iš žurnalo failų, pridedami juos prie [`config.filter_parameters`][] programos konfigūracijoje. Šie parametrai bus pažymėti kaip [FILTERED] žurnale.

```ruby
config.filter_parameters << :password
```

PASTABA: Pateikti parametrai bus filtruojami pagal dalinį atitikimą reguliariam išraiškų reiškiniui. Rails prideda sąrašą numatytųjų filtrų, įskaitant `:passw`, `:secret` ir `:token`, atitinkamame inicializavime (`initializers/filter_parameter_logging.rb`), kad būtų galima tvarkyti tipiškus programos parametrus, tokius kaip `password`, `password_confirmation` ir `my_token`.


### Nukreipimų filtravimas

Kartais norite išfiltruoti iš žurnalo failų kai kurias jautrias vietas, į kurias jūsų programa nukreipia. Tai galite padaryti naudodami `config.filter_redirect` konfigūracijos parinktį:

```ruby
config.filter_redirect << 's3.amazonaws.com'
```

Galite nustatyti jį kaip eilutę, reguliariąją išraišką arba abiejų masyvą.

```ruby
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

Atitinkamos URL bus pažymėtos kaip '[FILTERED]'.

Gelbėjimas
------

Labai tikėtina, kad jūsų programa turės klaidų arba kitaip išmes išimtį, kurią reikia apdoroti. Pavyzdžiui, jei vartotojas paspaudžia nuorodą į ištrintą resursą duomenų bazėje, Active Record išmes `ActiveRecord::RecordNotFound` išimtį.

Rails numatytasis išimčių tvarkymas rodo "500 Serverio klaida" pranešimą visoms išimtims. Jei užklausa buvo padaryta vietiniame kompiuteryje, bus rodomas gražus atsekamumas ir papildoma informacija, kad galėtumėte sužinoti, kas nutiko ir kaip su tuo susidoroti. Jei užklausa buvo nuotoliniu būdu, Rails tiesiog rodo paprastą "500 Serverio klaida" pranešimą vartotojui arba "404 Nerasta", jei buvo maršruto klaida, arba negalima rasti įrašo. Kartais norėsite pritaikyti, kaip šios klaidos yra sugaunamos ir kaip jos rodomos vartotojui. Rails programoje yra keletas išimčių tvarkymo lygių:
### Numatytieji 500 ir 404 šablonai

Pagal numatytuosius nustatymus, produkcinėje aplinkoje programa atvaizduos arba 404, arba 500 klaidos pranešimą. Vystymo aplinkoje visi neatpažinti išimtys tiesiog bus iškeltos. Šie pranešimai yra saugomi statiniuose HTML failuose viešajame aplanke, `404.html` ir `500.html` atitinkamai. Galite pritaikyti šiuos failus, kad pridėtumėte papildomos informacijos ir stiliaus, tačiau prisiminkite, kad tai yra statiniai HTML failai; t.y. negalite naudoti ERB, SCSS, CoffeeScript ar maketų.

### `rescue_from`

Jei norite padaryti ką nors sudėtingesnio, kai gaunate klaidas, galite naudoti [`rescue_from`][], kuris tvarko tam tikro tipo (arba kelių tipų) išimtis visame valdiklyje ir jo povaldžiuose.

Kai įvyksta išimtis, kurią sugauna `rescue_from` direktyva, išimties objektas perduodamas tvarkytojui. Tvarkytojas gali būti metodas arba `Proc` objektas, perduotas `:with` parinktyje. Taip pat galite tiesiogiai naudoti bloką vietoj aiškaus `Proc` objekto.

Čia pateikiama, kaip galite naudoti `rescue_from` norėdami perimti visas `ActiveRecord::RecordNotFound` klaidas ir kažką su jomis daryti.

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

Žinoma, šis pavyzdys yra visiškai paprastas ir visiškai nepagerina numatytosios išimčių tvarkymo, tačiau kai jūs galite sugauti visas tas išimtis, galite daryti, ką tik norite su jomis. Pavyzdžiui, galite sukurti pasirinktines išimčių klases, kurios bus išmetamos, kai vartotojas neturi prieigos prie tam tikros jūsų programos dalies:

```ruby
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private
    def user_not_authorized
      flash[:error] = "Neturite prieigos prie šios dalies."
      redirect_back(fallback_location: root_path)
    end
end

class ClientsController < ApplicationController
  # Patikrinkite, ar vartotojas turi tinkamą autorizaciją, kad galėtų pasiekti klientus.
  before_action :check_authorization

  # Pastebėkite, kaip veiksmai neturi rūpintis visais autentifikavimo dalykais.
  def edit
    @client = Client.find(params[:id])
  end

  private
    # Jei vartotojas neturi teisės, tiesiog išmeskite išimtį.
    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

ĮSPĖJIMAS: Naudoti `rescue_from` su `Exception` arba `StandardError` sukeltų rimtų šalutinių poveikių, nes tai neleidžia „Rails“ tinkamai tvarkyti išimčių. Todėl nerekomenduojama taip daryti, nebent yra galinga priežastis.

PASTABA: Paleidus produkcinę aplinką, visos `ActiveRecord::RecordNotFound` klaidos atvaizduos 404 klaidos puslapį. Jei nereikia pasirinktinio elgesio, šioje situacijoje jums nereikia jų tvarkyti.

PASTABA: Kai vykdoma produkcinėje aplinkoje, tam tikros išimtys gali būti tvarkomos tik iš `ApplicationController` klasės, nes jos iškeliamos prieš valdiklio inicijavimą ir veiksmas vykdomas.

Priversti naudoti HTTPS protokolą
--------------------

Jei norite užtikrinti, kad ryšys su jūsų valdikliu būtų galimas tik naudojant HTTPS, tai galite padaryti, įjungdami [`ActionDispatch::SSL`][] tarpinę per [`config.force_ssl`][] savo aplinkos konfigūracijoje.


Įdiegtas sveikatos tikrinimo galutinis taškas
------------------------------

„Rails“ taip pat turi įdiegtą sveikatos tikrinimo galutinį tašką, kuris pasiekiamas adresu `/up`. Šis galutinis taškas grąžins 200 būsenos kodą, jei programa paleista be išimčių, ir 500 būsenos kodą kitais atvejais.

Produkcijoje daugelis programų privalo pranešti apie savo būseną, ar tai būtų veikimo laiko stebėjimo priemonė, kuri praneš inžinieriui, kai kas nors negerai, ar apkrovos balansuotojas ar „Kubernetes“ valdiklis, naudojamas nustatyti pod'o būseną. Šis sveikatos tikrinimas yra sukurtas taip, kad jis tiktų daugeliui situacijų.

Nors visos naujai sukurtos „Rails“ programos turės sveikatos tikrinimą adresu `/up`, galite konfigūruoti kelią, kurį norite, savo „config/routes.rb“:

```ruby
Rails.application.routes.draw do
  get "healthz" => "rails/health#show", as: :rails_health_check
end
```

Sveikatos tikrinimas dabar bus pasiekiamas per `/healthz` kelią.

PASTABA: Šis galutinis taškas neatspindi visų jūsų programos priklausomybių, pvz., duomenų bazės ar „redis“ klasterio, būsenos. Pakeiskite "rails/health#show" savo valdiklio veiksmu, jei jums reikia programos specifinių poreikių.

Atidžiai apsvarstykite, ką norite patikrinti, nes tai gali sukelti situacijas, kai jūsų programa paleidžiama iš naujo dėl trečiųjų šalių paslaugos gedimo. Geriausia, jei projektuosite savo programą taip, kad ji tinkamai tvarkytų šiuos gedimus.
[`ActionController::Base`]: https://api.rubyonrails.org/classes/ActionController/Base.html
[`params`]: https://api.rubyonrails.org/classes/ActionController/StrongParameters.html#method-i-params
[`wrap_parameters`]: https://api.rubyonrails.org/classes/ActionController/ParamsWrapper/Options/ClassMethods.html#method-i-wrap_parameters
[`controller_name`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-controller_name
[`action_name`]: https://api.rubyonrails.org/classes/AbstractController/Base.html#method-i-action_name
[`permit`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit
[`permit!`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit-21
[`require`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-require
[`ActionDispatch::Session::CookieStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CookieStore.html
[`ActionDispatch::Session::CacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CacheStore.html
[`ActionDispatch::Session::MemCacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/MemCacheStore.html
[activerecord-session_store]: https://github.com/rails/activerecord-session_store
[`reset_session`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-reset_session
[`flash`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/RequestMethods.html#method-i-flash
[`flash.keep`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-keep
[`flash.now`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-now
[`config.action_dispatch.cookies_serializer`]: configuring.html#config-action-dispatch-cookies-serializer
[`cookies`]: https://api.rubyonrails.org/classes/ActionController/Cookies.html#method-i-cookies
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`skip_before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-skip_before_action
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`request`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-request
[`response`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-response
[`path_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Http/Parameters.html#method-i-path_parameters
[`query_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-query_parameters
[`request_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-request_parameters
[`http_basic_authenticate_with`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic/ControllerMethods/ClassMethods.html#method-i-http_basic_authenticate_with
[`authenticate_or_request_with_http_digest`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Digest/ControllerMethods.html#method-i-authenticate_or_request_with_http_digest
[`authenticate_or_request_with_http_token`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token/ControllerMethods.html#method-i-authenticate_or_request_with_http_token
[`send_data`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_data
[`send_file`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file
[`ActionController::Live`]: https://api.rubyonrails.org/classes/ActionController/Live.html
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`config.force_ssl`]: configuring.html#config-force-ssl
[`ActionDispatch::SSL`]: https://api.rubyonrails.org/classes/ActionDispatch/SSL.html
