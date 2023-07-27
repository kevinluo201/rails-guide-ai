**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: df23e2b31bd56973a30f38f5a1c29b52
Ruby on Rails 5.0 Išleidimo pastabos
=====================================

Svarbiausi dalykai Rails 5.0 versijoje:

* Action Cable
* Rails API
* Active Record atributų API
* Testų paleidyklė
* Išskirtinai naudojamas `rails` CLI vietoje Rake
* Sprockets 3
* Turbolinks 5
* Reikalingas Ruby 2.2.2+

Šiose išleidimo pastabose aptariami tik pagrindiniai pokyčiai. Norėdami sužinoti apie įvairius klaidų taisymus ir pokyčius, prašome kreiptis į pakeitimų žurnalus arba peržiūrėti [pakeitimų sąrašą](https://github.com/rails/rails/commits/5-0-stable) pagrindiniame Rails saugykloje GitHub'e.

--------------------------------------------------------------------------------

Atnaujinimas iki Rails 5.0
--------------------------

Jei atnaujinote esamą programą, gerai būtų turėti gerą testų padengimą prieš pradedant. Taip pat pirmiausia turėtumėte atnaujinti iki Rails 4.2, jei dar to nepadarėte, ir įsitikinti, kad jūsų programa vis dar veikia kaip tikimasi, prieš bandant atnaujinti iki Rails 5.0. Atnaujinimo metu reikėtų atkreipti dėmesį į keletą dalykų, kuriuos galima rasti
[Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0)
gide.

Pagrindinės funkcijos
---------------------

### Action Cable

Action Cable yra nauja Rails 5.0 versijoje. Ji be problemų integruoja
[WebSockets](https://en.wikipedia.org/wiki/WebSocket) su jūsų
Rails programa.

Action Cable leidžia rašyti realaus laiko funkcijas Ruby kalba
taip pat, kaip ir visą kitą jūsų Rails programą, tuo pačiu būdama
efektyvi ir plečiama. Tai yra visapusiškas sprendimas, kuris teikia tiek
klientinės pusės JavaScript karkasą, tiek serverinės pusės Ruby karkasą. Jūs
turite prieigą prie viso savo domeno modelio, kuris yra parašytas su Active Record arba jūsų pasirinktu ORM.

Daugiau informacijos rasite [Action Cable apžvalgoje](action_cable_overview.html).

### API programos

Rails dabar gali būti naudojamas kurti API programoms. Tai naudinga, jei norite kurti ir teikti API, panašius į [Twitter](https://dev.twitter.com) ar [GitHub](https://developer.github.com) API, kurie gali būti naudojami tiek viešai, tiek pritaikytoms programoms.

Galite sukurti naują api Rails programą naudodami:

```bash
$ rails new my_api --api
```

Tai padarys tris pagrindines veiklas:

- Konfigūruos jūsų programą pradėti su mažesniu middleware rinkiniu nei įprasta. Konkrečiai, pagal numatytuosius nustatymus ji neįtrauks jokio middleware, kuris daugiausia naudojamas naršyklės programoms (pvz., slapukų palaikymas).
- Padarys, kad `ApplicationController` paveldėtų `ActionController::API`, o ne `ActionController::Base`. Kaip ir su middleware, tai paliks bet kokius Action Controller modulius, kurie teikia funkcionalumą, daugiausia naudojamą naršyklės programoms.
- Konfigūruos generatorius praleisti generuojant vaizdus, pagalbininkus ir išteklius, kai kuriate naują išteklių resursą.
Ši programa teikia pagrindą API'ams,
kurie gali būti [konfigūruojami, kad įtrauktų funkcionalumą](api_app.html) pagal programos poreikius.

Daugiau informacijos rasite [Naudodami "Rails" tik API programoms](api_app.html) vadove.

### Active Record atributų API

Apibrėžia atributą su tipu modelyje. Jei reikia, jis perrašys esamų atributų tipą.
Tai leidžia kontroliuoti, kaip reikšmės yra konvertuojamos į SQL ir atvirkščiai, kai priskiriamos modeliui.
Tai taip pat keičia elgesį su reikšmėmis, perduotomis į `ActiveRecord::Base.where`, leidžiant naudoti mūsų domeno objektus daugelyje Active Record, nereikiant remtis įgyvendinimo detalėmis ar "monkey patching".

Kai kuriuos dalykus, kuriuos galima pasiekti:

- Galima perrašyti Active Record aptiktą tipą.
- Taip pat galima nurodyti numatytąją reikšmę.
- Atributai gali neturėti duomenų bazės stulpelio.

```ruby
# db/schema.rb
create_table :store_listings, force: true do |t|
  t.decimal :price_in_cents
  t.string :my_string, default: "original default"
end
```

```ruby
# app/models/store_listing.rb
class StoreListing < ActiveRecord::Base
end
```

```ruby
store_listing = StoreListing.new(price_in_cents: '10.1')

# prieš tai
store_listing.price_in_cents # => BigDecimal.new(10.1)
StoreListing.new.my_string # => "original default"

class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer # pasirinktinis tipas
  attribute :my_string, :string, default: "new default" # numatytoji reikšmė
  attribute :my_default_proc, :datetime, default: -> { Time.now } # numatytoji reikšmė
  attribute :field_without_db_column, :integer, array: true
end

# po to
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes # => {field_without_db_column: [1, 2, 3]}
```

**Kuriamas pasirinktinis tipas:**

Galite apibrėžti savo pasirinktinius tipus, jei jie atitinka
reikšmės tipo apibrėžtus metodus. Jūsų tipo objektui bus iškviestas metodas `deserialize` arba
`cast`, su neapdorota duomenų bazės ar valdiklių įvestimi. Tai naudinga, pavyzdžiui, atliekant pasirinktinį konvertavimą,
pvz., pinigų duomenims.

**Užklausos:**

Kai iškviečiama `ActiveRecord::Base.where`, ji
naudos modelio klasėje apibrėžtą tipą, kad konvertuotų reikšmę į SQL,
iškviesdama `serialize` jūsų tipo objekte.

Tai suteikia objektams galimybę nurodyti, kaip konvertuoti reikšmes vykdant SQL užklausas.
**Nešvarus stebėjimas:**

Atributo tipas gali keisti, kaip vykdomas nešvarus stebėjimas.

Išsamią informaciją rasite
[dokumentacijoje](https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html).


### Testavimo vykdytojas

Naujas testavimo vykdytojas buvo pristatytas, siekiant pagerinti galimybes vykdyti testus iš „Rails“.
Norėdami naudoti šį testavimo vykdytoją, tiesiog įveskite `bin/rails test`.

Testavimo vykdytojas yra įkvėptas iš `RSpec`, `minitest-reporters`, `maxitest` ir kitų.
Jis apima šiuos pastebimus patobulinimus:

- Paleiskite vieną testą, naudodami testo eilės numerį.
- Paleiskite kelis testus, nurodydami testų eilės numerį.
- Gerinti klaidų pranešimus, kurie taip pat palengvina klaidingų testų pakartotiną vykdymą.
- Greitai nutraukite naudojant `-f` parinktį, kad sustabdytumėte testus nedelsiant, kai atsiranda klaida,
vietoj laukimo, kol bus baigtas visų testų rinkinys.
- Atidėti testo rezultatų išvestį iki viso testų vykdymo pabaigos, naudojant `-d` parinktį.
- Pilnas išimčių takelio išvestis naudojant `-b` parinktį.
- Integruota su minitest, leidžianti naudoti parinktis, pvz., `-s` testavimo sėklos duomenims,
`-n` paleisti konkretų testą pagal pavadinimą, `-v` geresnei išsamioms išvestims ir t.t.
- Spalvota testavimo išvestis.

Railties
--------

Išsamius pakeitimus žr. [Changelog][railties].

### Pašalinimai

*   Pašalintas derinimo palaikymas, naudokite „byebug“. „debugger“ nepalaikomas
    Ruby
    2.2. ([commit](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))

*   Pašalintos pasenusios „test:all“ ir „test:all:db“ užduotys.
    ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   Pašalintas pasenusios „Rails::Rack::LogTailer“.
    ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   Pašalinta pasenusioji „RAILS_CACHE“ konstanta.
    ([commit](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   Pašalinta pasenusioji „serve_static_assets“ konfigūracija.
    ([commit](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   Pašalintos dokumentacijos užduotys „doc:app“, „doc:rails“ ir „doc:guides“.
    ([commit](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   Pašalintas „Rack::ContentLength“ tarpinė programinė įranga iš numatytosios
    eilės. ([Commit](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### Pasenusios funkcijos

*   Pasenusi „config.static_cache_control“, naudokite
    „config.public_file_server.headers“.
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   Pasenusi „config.serve_static_files“, naudokite „config.public_file_server.enabled“.
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*   Pasenusios užduotys „rails“ užduočių srities vietoje „app“ srities.
    (pvz., „rails:update“ ir „rails:template“ užduotys pervadintos į „app:update“ ir „app:template“.)
    ([Pull Request](https://github.com/rails/rails/pull/23439))

### Pastebimi pakeitimai

*   Pridėtas „Rails“ testavimo vykdytojas `bin/rails test`.
    ([Pull Request](https://github.com/rails/rails/pull/19216))

*   Naujai sukurtos programos ir įskiepiai gauna „README.md“ failą „Markdown“ formatu.
    ([commit](https://github.com/rails/rails/commit/89a12c931b1f00b90e74afffcdc2fc21f14ca663),
     [Pull Request](https://github.com/rails/rails/pull/22068))

*   Pridėta „bin/rails restart“ užduotis, skirta paleisti „Rails“ programą palietus „tmp/restart.txt“.
    ([Pull Request](https://github.com/rails/rails/pull/18965))

*   Pridėta „bin/rails initializers“ užduotis, skirta išspausdinti visus apibrėžtus pradinės būsenos nustatymus
    ta tvarka, kuria jie yra kviečiami „Rails“.
    ([Pull Request](https://github.com/rails/rails/pull/19323))
*   Pridėtas `bin/rails dev:cache` komanda, leidžianti įjungti arba išjungti talpinimą vystymo režime.
    ([Pull Request](https://github.com/rails/rails/pull/20961))

*   Pridėtas `bin/update` skriptas, skirtas automatiškai atnaujinti vystymo aplinką.
    ([Pull Request](https://github.com/rails/rails/pull/20972))

*   Peradresuoti Rake užduotis per `bin/rails`.
    ([Pull Request](https://github.com/rails/rails/pull/22457),
     [Pull Request](https://github.com/rails/rails/pull/22288))

*   Naujos programos generuojamos su įvykių pagrindu failų stebėjimu įjungtu
    Linux ir macOS sistemose. Šią funkciją galima išjungti perduodant
    `--skip-listen` generatoriui.
    ([commit](https://github.com/rails/rails/commit/de6ad5665d2679944a9ee9407826ba88395a1003),
    [commit](https://github.com/rails/rails/commit/94dbc48887bf39c241ee2ce1741ee680d773f202))

*   Generuojant programas, yra galimybė nurodyti, kad produkcijos režime žurnalas būtų išvedamas į STDOUT naudojant aplinkos kintamąjį `RAILS_LOG_TO_STDOUT`.
    ([Pull Request](https://github.com/rails/rails/pull/23734))

*   Naujoms programoms įjungtas HSTS su IncludeSubdomains antraštė.
    ([Pull Request](https://github.com/rails/rails/pull/23852))

*   Programos generatorius rašo naują failą `config/spring.rb`, kuris praneša
    Spring'ui stebėti papildomus bendrus failus.
    ([commit](https://github.com/rails/rails/commit/b04d07337fd7bc17e88500e9d6bcd361885a45f8))

*   Pridėtas `--skip-action-mailer` pasirinkimas, leidžiantis praleisti Action Mailer generuojant naują programą.
    ([Pull Request](https://github.com/rails/rails/pull/18288))

*   Pašalintas `tmp/sessions` katalogas ir su juo susijusi aiškinamoji rake užduotis.
    ([Pull Request](https://github.com/rails/rails/pull/18314))

*   Pakeistas `scaffold` generatoriaus sugeneruotas `_form.html.erb` failas, kad būtų naudojami vietiniai kintamieji.
    ([Pull Request](https://github.com/rails/rails/pull/13434))

*   Išjungtas klasės automatinis įkėlimas produkcijos aplinkoje.
    ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

Action Pack
-----------

Išsamesnė informacija apie pakeitimus pateikiama [Changelog][action-pack] dokumente.

### Pašalinimai

*   Pašalintas `ActionDispatch::Request::Utils.deep_munge`.
    ([commit](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   Pašalintas `ActionController::HideActions`.
    ([Pull Request](https://github.com/rails/rails/pull/18371))

*   Pašalintos `respond_to` ir `respond_with` laikinosios metodų versijos, ši funkcionalumas
    buvo perkeltas į
    [responders](https://github.com/plataformatec/responders) biblioteką.
    ([commit](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   Pašalintos pasenusios patikros failai.
    ([commit](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   Pašalintas pasenusias eilutes naudojimas URL pagalbininkuose.
    ([commit](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   Pašalintas pasenusias `only_path` parinktis `*_path` pagalbininkuose.
    ([commit](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))

*   Pašalintas pasenusias `NamedRouteCollection#helpers` funkcionalumas.
    ([commit](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*   Pašalintas pasenusias galimybė nurodyti maršrutus su `:to` parinktimi, kuri neapima `#`.
    ([commit](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   Pašalinta pasenusias `ActionDispatch::Response#to_ary` funkcionalumas.
    ([commit](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   Pašalinta pasenusias `ActionDispatch::Request#deep_munge` funkcionalumas.
    ([commit](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   Pašalinta pasenusias
    `ActionDispatch::Http::Parameters#symbolized_path_parameters` funkcionalumas.
    ([commit](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   Pašalinta pasenusias `use_route` parinktis valdiklio testuose.
    ([commit](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   Pašalinti `assigns` ir `assert_template` metodai. Abi funkcijos buvo perkeltos
    į
    [rails-controller-testing](https://github.com/rails/rails-controller-testing)
    biblioteką.
    ([Pull Request](https://github.com/rails/rails/pull/20138))

### Pasenusios funkcijos

*   Pasenusios visos `*_filter` atgalinio iškvietimo funkcijos, naudoti `*_action` atgalinio iškvietimo funkcijas.
    ([Pull Request](https://github.com/rails/rails/pull/18410))

*   Pasenusios `*_via_redirect` integracinio testo metodai. Po užklausos iškvietimo, norint pasiekti tą patį elgesį, reikia naudoti `follow_redirect!` rankiniu būdu.
    ([Pull Request](https://github.com/rails/rails/pull/18693))

*   Pasenusios `AbstractController#skip_action_callback` funkcijos, naudoti atskiras
    skip_callback metodus.
    ([Pull Request](https://github.com/rails/rails/pull/19060))

*   Pasenusios `:nothing` parinktis `render` metode.
    ([Pull Request](https://github.com/rails/rails/pull/20336))

*   Pasenusios pirmo parametro perdavimas kaip `Hash` ir numatytoji būsenos kodo reikšmė `head` metode.
    ([Pull Request](https://github.com/rails/rails/pull/20407))
*   Pasenus naudoti eilutes arba simbolius kaip tarpinio klasės pavadinimus. Vietoj to naudokite klasės pavadinimus.
    ([commit](https://github.com/rails/rails/commit/83b767ce))

*   Pasenus pasiekti MIME tipus per konstantas (pvz., `Mime::HTML`). Vietoj to naudokite indeksavimo operatorių su simboliu (pvz., `Mime[:html]`).
    ([Pull Request](https://github.com/rails/rails/pull/21869))

*   Pasenus `redirect_to :back`, naudokite `redirect_back`, kuris priima privalomą `fallback_location` argumentą, taip pašalindamas `RedirectBackError` galimybę.
    ([Pull Request](https://github.com/rails/rails/pull/22506))

*   `ActionDispatch::IntegrationTest` ir `ActionController::TestCase` pasenusių pozicinių argumentų vietoje naudokite raktažodžių argumentus.
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   Pasenusių `:controller` ir `:action` kelio parametrų.
    ([Pull Request](https://github.com/rails/rails/pull/23980))

*   Pasenusas `env` metodas valdiklio egzemplioriuose.
    ([commit](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   `ActionDispatch::ParamsParser` pasenusi ir pašalinta iš tarpinio paketo. Norėdami konfigūruoti parametrų analizatorius, naudokite `ActionDispatch::Request.parameter_parsers=`.
    ([commit](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1),
    [commit](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))

### Svarbūs pakeitimai

*   Pridėtas `ActionController::Renderer` norint atvaizduoti bet kokius šablonus už valdiklio veiksmų ribų.
    ([Pull Request](https://github.com/rails/rails/pull/18546))

*   Perėjimas prie raktažodžių argumentų sintaksės `ActionController::TestCase` ir `ActionDispatch::Integration` HTTP užklausos metodams.
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   Pridėtas `http_cache_forever` prie Action Controller, kad galėtume talpinti atsakymą, kuris niekada nebaigiasi.
    ([Pull Request](https://github.com/rails/rails/pull/18394))

*   Suteikta draugiškesnė prieiga prie užklausos variantų.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   Veiksmams be atitinkamų šablonų, vietoj klaidos iškėlimo, atvaizduojamas `head :no_content`.
    ([Pull Request](https://github.com/rails/rails/pull/19377))

*   Pridėta galimybė perrašyti numatytąjį formos kūrėją valdikliui.
    ([Pull Request](https://github.com/rails/rails/pull/19736))

*   Pridėta API tik programoms palaikymo galimybė.
    `ActionController::API` pridedama kaip `ActionController::Base` pakeitimas šios rūšies programoms.
    ([Pull Request](https://github.com/rails/rails/pull/19832))

*   `ActionController::Parameters` daugiau neįgyvendina `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/20868))

*   Padaryta lengviau įjungti `config.force_ssl` ir `config.ssl_options`, padarant juos mažiau pavojingus ir lengviau išjungiamus.
    ([Pull Request](https://github.com/rails/rails/pull/21520))

*   Pridėta galimybė grąžinti bet kokius antraščius į `ActionDispatch::Static`.
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   Pakeistas `protect_from_forgery` pridėjimo numatytasis įjungimas į `false`.
    ([commit](https://github.com/rails/rails/commit/39794037817703575c35a75f1961b01b83791191))

*   `ActionController::TestCase` bus perkelta į savo paties juvelyrinę medžiagą „Rails“ 5.1 versijoje. Vietoj to naudokite `ActionDispatch::IntegrationTest`.
    ([commit](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d))

*   Pagal numatytuosius nustatymus „Rails“ generuoja silpnus ETag'us.
    ([Pull Request](https://github.com/rails/rails/pull/17573))

*   Valdiklio veiksmai be aiškios `render` iškvietimo ir be atitinkamų šablonų vietoj klaidos iškėlimo automatiškai atvaizduojami `head :no_content`.
    (Pull Request [1](https://github.com/rails/rails/pull/19377),
    [2](https://github.com/rails/rails/pull/23827))

*   Pridėta paraiška dėl formos CSRF žetonų.
    ([Pull Request](https://github.com/rails/rails/pull/22275))

*   Pridėtas užklausos kodavimas ir atsakymo analizė integracijos testams.
    ([Pull Request](https://github.com/rails/rails/pull/21671))

*   Pridėtas `ActionController#helpers`, kad gautumėte prieigą prie vaizdo konteksto valdiklio lygyje.
    ([Pull Request](https://github.com/rails/rails/pull/24866))
*   Atmestos "flash" pranešimai pašalinami prieš saugant į sesiją.
    ([Pull Request](https://github.com/rails/rails/pull/18721))

*   Pridėta palaikymas perduoti įrašų kolekciją `fresh_when` ir `stale?`.
    ([Pull Request](https://github.com/rails/rails/pull/18374))

*   `ActionController::Live` tapo `ActiveSupport::Concern`. Tai reiškia, kad jis negali būti tiesiog įtrauktas į kitus modulius be išplėtimo su `ActiveSupport::Concern` arba `ActionController::Live` neveiks produkcijoje. Kai kurie žmonės taip pat gali naudoti kitą modulį, kad įtrauktų tam tikrą `Warden`/`Devise` autentifikavimo nesėkmės tvarkymo kodą, nes tarpinės programinės įrangos negali užfiksuoti `:warden`, išmetamą išvesties gijos, kuri yra atvejis, naudojant `ActionController::Live`.
    ([Daugiau informacijos šiame klausime](https://github.com/rails/rails/issues/25581))

*   Įvesti `Response#strong_etag=` ir `#weak_etag=` ir analogiški parametrai `fresh_when` ir `stale?`.
    ([Pull Request](https://github.com/rails/rails/pull/24387))

Veiksmų rodinys
-------------

Išsamūs pakeitimai rasomi [Changelog][action-view].

### Pašalinimai

*   Pašalintas pasenusių `AbstractController::Base::parent_prefixes`.
    ([commit](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

*   Pašalintas `ActionView::Helpers::RecordTagHelper`, ši funkcionalumas
    buvo išskirtas į
    [record_tag_helper](https://github.com/rails/record_tag_helper) gemą.
    ([Pull Request](https://github.com/rails/rails/pull/18411))

*   Pašalinta `:rescue_format` parinktis `translate` pagalbininkui, nes ji daugiau
    nepalaikoma I18n.
    ([Pull Request](https://github.com/rails/rails/pull/20019))

### Svarbūs pakeitimai

*   Pakeistas numatytasis šablonų tvarkyklė iš `ERB` į `Raw`.
    ([commit](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

*   Kolekcijos rodinys gali talpinti ir gauti kelis dalinius iš karto.
    ([Pull Request](https://github.com/rails/rails/pull/18948),
    [commit](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

*   Pridėta ženklų atitikimo išplėstinėms priklausomybėms.
    ([Pull Request](https://github.com/rails/rails/pull/20904))

*   `disable_with` tampa numatytuoju elgesiu pateikimo žymėms. Išjungia mygtuką pateikimo metu, kad būtų išvengta dvigubo pateikimo.
    ([Pull Request](https://github.com/rails/rails/pull/21135))

*   Dalinio šablono pavadinimas nebūtinai turi būti galiojantis Ruby identifikatorius.
    ([commit](https://github.com/rails/rails/commit/da9038e))

*   `datetime_tag` pagalbininkas dabar generuoja įvesties žymė su tipu `datetime-local`.
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   Leidžiama naudoti blokus, renderinant su `render partial:` pagalbininku.
    ([Pull Request](https://github.com/rails/rails/pull/17974))

Veiksmų paštas
-------------

Išsamūs pakeitimai rasomi [Changelog][action-mailer].

### Pašalinimai

*   Pašalinti pasenusių `*_path` pagalbininkai el. pašto rodiniuose.
    ([commit](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

*   Pašalinti pasenusi `deliver` ir `deliver!` metodai.
    ([commit](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### Svarbūs pakeitimai

*   Šablonų paieška dabar atsižvelgia į numatytąją lokalę ir I18n atsarginius.
    ([commit](https://github.com/rails/rails/commit/ecb1981b))

*   Pridėtas `_mailer` priesaga el. pašto rodiniams, sukurtiems per generatorių, laikantis to paties
    pavadinimo konvencijos, kuri naudojama kontroleriuose ir darbuose.
    ([Pull Request](https://github.com/rails/rails/pull/18074))

*   Pridėti `assert_enqueued_emails` ir `assert_no_enqueued_emails`.
    ([Pull Request](https://github.com/rails/rails/pull/18403))

*   Pridėta `config.action_mailer.deliver_later_queue_name` konfigūracija, nustatanti
    pašto eilės pavadinimą.
    ([Pull Request](https://github.com/rails/rails/pull/18587))

*   Pridėtas fragmentų talpinimas veiksmų pašto rodiniuose.
    Pridėta nauja konfigūracijos parinktis `config.action_mailer.perform_caching`, nustatanti,
    ar šablonai turėtų atlikti talpinimą ar ne.
    ([Pull Request](https://github.com/rails/rails/pull/22825))
Aktyvusis įrašas
-------------

Išsamius pakeitimus rasite [Changelog][active-record].

### Pašalinimai

*   Pašalinta pasenusi elgsena, leidžianti perduoti įdėtus masyvus kaip užklausos reikšmes. ([Pull Request](https://github.com/rails/rails/pull/17919))

*   Pašalinta pasenusi `ActiveRecord::Tasks::DatabaseTasks#load_schema` funkcija. Ši funkcija buvo pakeista `ActiveRecord::Tasks::DatabaseTasks#load_schema_for`. ([commit](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))

*   Pašalintas pasenusi `serialized_attributes`. ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*   Pašalintas pasenusi automatinis skaitiklių kešavimas `has_many :through`. ([commit](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

*   Pašalinta pasenusi `sanitize_sql_hash_for_conditions`. ([commit](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

*   Pašalinta pasenusi `Reflection#source_macro`. ([commit](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

*   Pašalinti pasenusi `symbolized_base_class` ir `symbolized_sti_name`. ([commit](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

*   Pašalinta pasenusi `ActiveRecord::Base.disable_implicit_join_references=` funkcija. ([commit](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

*   Pašalintas pasenusi prisijungimo specifikacijos prieiga naudojant eilutės priėjimą. ([commit](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

*   Pašalintas pasenusi palaikymas išankstiniam įkėlimui priklausomų asociacijų. ([commit](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

*   Pašalintas pasenusi palaikymas PostgreSQL intervalams su ekskliuzyviais apatiniais ribomis. ([commit](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

*   Pašalinta pasenusi klaidos išmetimo funkcija keičiant ryšį su kešuotu Arel. Vietoj to kyla `ImmutableRelation` klaida. ([commit](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

*   Pašalintas `ActiveRecord::Serialization::XmlSerializer` iš pagrindinio kodo. Ši funkcija buvo išskirta į [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) paketą. ([Pull Request](https://github.com/rails/rails/pull/21161))

*   Pašalintas palaikymas senam `mysql` duomenų bazės adapteriui iš pagrindinio kodo. Dauguma vartotojų turėtų galėti naudoti `mysql2`. Jis bus konvertuotas į atskirą paketą, kai rasime kas jį prižiūrėtų. ([Pull Request 1](https://github.com/rails/rails/pull/22642), [Pull Request 2](https://github.com/rails/rails/pull/22715))

*   Pašalintas palaikymas `protected_attributes` paketui. ([commit](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

*   Pašalintas palaikymas PostgreSQL versijoms žemesnėms nei 9.1. ([Pull Request](https://github.com/rails/rails/pull/23434))

*   Pašalintas palaikymas `activerecord-deprecated_finders` paketui. ([commit](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

*   Pašalinta `ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES` konstanta. ([commit](https://github.com/rails/rails/commit/a502703c3d2151d4d3b421b29fefdac5ad05df61))

### Pasenusios funkcijos

*   Paseninta klasės perduodamo kaip reikšmės užklausoje funkcionalumas. Vartotojai turėtų perduoti eilutes vietoj to. ([Pull Request](https://github.com/rails/rails/pull/17916))

*   Paseninta `false` grąžinimas kaip būdas sustabdyti Active Record atgalinį iškvietimų grandinę. Rekomenduojamas būdas yra `throw(:abort)`. ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Paseninta `ActiveRecord::Base.errors_in_transactional_callbacks=` funkcija. ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

*   Paseninta `Relation#uniq` funkcija, naudokite `Relation#distinct` vietoj to. ([commit](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

*   Pasenintas PostgreSQL `:point` tipas naudai naujo, kuris grąžins `Point` objektus vietoj `Array`. ([Pull Request](https://github.com/rails/rails/pull/20448))

*   Pasenintas asociacijos perkrovimas perduodant teisingą argumentą asociacijos funkcijai. ([Pull Request](https://github.com/rails/rails/pull/20888))

*   Paseninti asociacijos `restrict_dependent_destroy` klaidų raktai naudai naujų raktų pavadinimų. ([Pull Request](https://github.com/rails/rails/pull/20668))

*   Sinchronizuota `#tables` funkcijos elgsena. ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Pasenintos `SchemaCache#tables`, `SchemaCache#table_exists?` ir `SchemaCache#clear_table_cache!` funkcijos naudai jų naujų duomenų šaltinių atitikmenims. ([Pull Request](https://github.com/rails/rails/pull/21715))

*   Paseninta `connection.tables` funkcija SQLite3 ir MySQL adapteriuose. ([Pull Request](https://github.com/rails/rails/pull/21601))
*   Pasenus argumentus į `#tables` metodą pažymėta kaip pasenusią - kai kurie adapterių (mysql2, sqlite3) `#tables` metodas grąžindavo tiek lentelės, tiek vaizdus, tuo tarpu kiti (postgresql) grąžindavo tik lentelės. Norint padaryti jų veikimą nuosekliu, ateityje `#tables` grąžins tik lentelės.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Pasenusią `table_exists?` metodą - `#table_exists?` metodas tikrino tiek lentelės, tiek vaizdus. Norint padaryti jų veikimą nuosekliu su `#tables`, ateityje `#table_exists?` tikrins tik lentelės.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Pasenusią `offset` argumento perdavimą į `find_nth`. Prašome naudoti `offset` metodą vietoje.
    ([Pull Request](https://github.com/rails/rails/pull/22053))

*   Pasenusius `{insert|update|delete}_sql` metodus `DatabaseStatements`. Vietoje jų naudokite `{insert|update|delete}` viešuosius metodus.
    ([Pull Request](https://github.com/rails/rails/pull/23086))

*   Pasenusią `use_transactional_fixtures` naudojimą, pakeista į `use_transactional_tests` dėl aiškumo.
    ([Pull Request](https://github.com/rails/rails/pull/19282))

*   Pasenusią stulpelio perdavimą į `ActiveRecord::Connection#quote`.
    ([commit](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

*   Pridėta `end` parinktis `find_in_batches`, kuri papildo `start` parametrą ir nurodo, kur sustabdyti partijų apdorojimą.
    ([Pull Request](https://github.com/rails/rails/pull/12257))


### Svarbūs pakeitimai

*   Pridėta `foreign_key` parinktis `references` kuriant lentelę.
    ([commit](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

*   Naujos atributų API.
    ([commit](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

*   Pridėta `:_prefix`/`:_suffix` parinktis `enum` apibrėžime.
    ([Pull Request](https://github.com/rails/rails/pull/19813),
     [Pull Request](https://github.com/rails/rails/pull/20999))

*   Pridėtas `#cache_key` metodas `ActiveRecord::Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/20884))

*   Pakeistas numatytasis `null` reikšmė `timestamps` į `false`.
    ([commit](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

*   Pridėtas `ActiveRecord::SecureToken` modelyje, skirtas apgaubti unikalių atributų žymėjimo generavimą naudojant `SecureRandom`.
    ([Pull Request](https://github.com/rails/rails/pull/18217))

*   Pridėta `:if_exists` parinktis `drop_table`.
    ([Pull Request](https://github.com/rails/rails/pull/18597))

*   Pridėtas `ActiveRecord::Base#accessed_fields`, kuris gali būti naudojamas greitai nustatyti, kurie laukai buvo nuskaityti iš modelio, kai norite tik išrinkti reikalingus duomenis iš duomenų bazės.
    ([commit](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

*   Pridėtas `#or` metodas `ActiveRecord::Relation`, leidžiantis naudoti ARBA operatorių, kad sudėtų WHERE arba HAVING sąlygas.
    ([commit](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

*   Pridėtas `ActiveRecord::Base.suppress`, kad bloke būtų išsaugotas gavėjas.
    ([Pull Request](https://github.com/rails/rails/pull/18910))

*   `belongs_to` dabar pagal numatymą sukels validacijos klaidą, jei asociacija nėra pateikta. Galite tai išjungti kiekvienai asociacijai naudodami `optional: true`. Taip pat pasenusi `required` parinktis pakeista į `optional` `belongs_to`.
    ([Pull Request](https://github.com/rails/rails/pull/18937))

*   Pridėta `config.active_record.dump_schemas` parinktis, skirta konfigūruoti `db:structure:dump` veikimą.
    ([Pull Request](https://github.com/rails/rails/pull/19347))

*   Pridėta `config.active_record.warn_on_records_fetched_greater_than` parinktis.
    ([Pull Request](https://github.com/rails/rails/pull/18846))

*   Pridėta natyvioji JSON duomenų tipo palaikymas MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/21110))
*   Pridėta palaikymo galimybė PostgreSQL duomenų bazėje ištrinti indeksus tuo pačiu metu.
    ([Pull Request](https://github.com/rails/rails/pull/21317))

*   Pridėtos `#views` ir `#view_exists?` metodai prisijungimo adapteriuose.
    ([Pull Request](https://github.com/rails/rails/pull/21609))

*   Pridėtas `ActiveRecord::Base.ignored_columns` metodas, kuris padaro tam tikrus stulpelius nematomus Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/21720))

*   Pridėti `connection.data_sources` ir `connection.data_source_exists?` metodai. Šie metodai nustato, kokios sąsajos gali būti naudojamos kaip pagrindas Active Record modeliams (dažniausiai tai yra lentelės ir vaizdai).
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   Leidžiama fiktyvių duomenų failuose nustatyti modelio klasę YAML faile.
    ([Pull Request](https://github.com/rails/rails/pull/20574))

*   Pridėta galimybė numatyti `uuid` kaip pirminį raktą generuojant duomenų bazės migracijas.
    ([Pull Request](https://github.com/rails/rails/pull/21762))

*   Pridėti `ActiveRecord::Relation#left_joins` ir `ActiveRecord::Relation#left_outer_joins` metodai.
    ([Pull Request](https://github.com/rails/rails/pull/12071))

*   Pridėti `after_{create,update,delete}_commit` atgaliniai kvietimai.
    ([Pull Request](https://github.com/rails/rails/pull/22516))

*   Versijuojama API, kuris pateikiamas migracijų klasėms, taip galime pakeisti parametrų numatytuosius nustatymus, nesulaužant esamų migracijų ar verčiant jas per deprecijos ciklą.
    ([Pull Request](https://github.com/rails/rails/pull/21538))

*   `ApplicationRecord` yra nauja viršklas visiems programos modeliams, analogiška programos valdikliams, kurie paveldi `ApplicationController` vietoj `ActionController::Base`. Tai suteikia programoms vieną vietą, kur konfigūruoti visoje programoje bendrą modelio elgesį.
    ([Pull Request](https://github.com/rails/rails/pull/22567))

*   Pridėti ActiveRecord `#second_to_last` ir `#third_to_last` metodai.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   Pridėta galimybė anotuoti duomenų bazės objektus (lenteles, stulpelius, indeksus) su komentarais, saugomais duomenų bazės metaduomenyse PostgreSQL ir MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/22911))

*   Pridėta paruoštų teiginių palaikymo galimybė `mysql2` adapteriui, naudojant mysql2 0.4.4+ versiją. Anksčiau tai buvo palaikoma tik pasenusiame `mysql` adapterio versijoje. Norėdami įjungti, nustatykite `prepared_statements: true` `config/database.yml` faile.
    ([Pull Request](https://github.com/rails/rails/pull/23461))

*   Pridėta galimybė iškviesti `ActionRecord::Relation#update` metodą su sąryšio objektais, kuris vykdys validacijas ir atgalinius kvietimus visiems sąryšio objektams.
    ([Pull Request](https://github.com/rails/rails/pull/11898))

*   Pridėtas `:touch` parametras `save` metode, kad įrašai galėtų būti išsaugoti be laiko žymėjimo atnaujinimo.
    ([Pull Request](https://github.com/rails/rails/pull/18225))

*   Pridėta išraiškų indeksų ir operatorių klasių palaikymo galimybė PostgreSQL.
    ([commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))

*   Pridėtas `:index_errors` parametras, kuris prideda indeksus prie įdėtų atributų klaidų.
    ([Pull Request](https://github.com/rails/rails/pull/19686))

*   Pridėta palaikymo galimybė dvipusiams sunaikinimo priklausomybėms.
    ([Pull Request](https://github.com/rails/rails/pull/18548))

*   Pridėtas palaikymo galimybė `after_commit` atgaliniams kvietimams transakciniuose testuose.
    ([Pull Request](https://github.com/rails/rails/pull/18458))

*   Pridėtas `foreign_key_exists?` metodas, kuris patikrina, ar užsienio raktas egzistuoja lentelėje ar ne.
    ([Pull Request](https://github.com/rails/rails/pull/18662))

*   Pridėtas `:time` parametras `touch` metode, kad būtų galima pakeisti įrašų laiką į kitą nei dabartinį laiką.
    ([Pull Request](https://github.com/rails/rails/pull/18956))
*   Pakeisti transakcijos atgalinio iškvietimo funkciją, kad nebūtų slopinami klaidos.
    Prieš šį pakeitimą, bet kokios klaidos, iškeltos transakcijos atgalinio iškvietimo funkcijoje,
    buvo pagauti ir spausdinami žurnale, nebent naudojote (naujai pasenusią) `raise_in_transactional_callbacks = true` parinktį.

    Dabar šios klaidos nebėra pagautos ir tiesiog kyla, atitinkant kitų atgalinių iškvietimų elgesį.
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

Aktyvus modelis
------------

Išsamių pakeitimų informacijai žiūrėkite [Changelog][active-model].

### Pašalinimai

*   Pašalintas pasenusių `ActiveModel::Dirty#reset_#{attribute}` ir
    `ActiveModel::Dirty#reset_changes` metodų palaikymas.
    ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

*   Pašalinta XML serializacija. Ši funkcija buvo išskirta į
    [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) gemą.
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   Pašalintas `ActionController::ModelNaming` modulis.
    ([Pull Request](https://github.com/rails/rails/pull/18194))

### Pasenusios funkcijos

*   Pasenusi grąžinimo `false` reikšmė kaip būdas sustabdyti Aktyvaus modelio ir
    `ActiveModel::Validations` atgalinio iškvietimo grandinę. Rekomenduojama naudoti
    `throw(:abort)`. ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Pasenusių `ActiveModel::Errors#get`, `ActiveModel::Errors#set` ir
    `ActiveModel::Errors#[]=` metodų, turinčių nesuderintą elgesį, palaikymas nutrauktas.
    ([Pull Request](https://github.com/rails/rails/pull/18634))

*   Pasenusi `:tokenizer` parinktis `validates_length_of` metode, naudojant paprastą Ruby.
    ([Pull Request](https://github.com/rails/rails/pull/19585))

*   Pasenusių `ActiveModel::Errors#add_on_empty` ir `ActiveModel::Errors#add_on_blank`
    funkcijų palaikymas be pakeitimo.
    ([Pull Request](https://github.com/rails/rails/pull/18996))

### Pastebimi pakeitimai

*   Pridėtas `ActiveModel::Errors#details` metodas, skirtas nustatyti, kuris tikrinimas nepavyko.
    ([Pull Request](https://github.com/rails/rails/pull/18322))

*   Išskirtas `ActiveRecord::AttributeAssignment` į `ActiveModel::AttributeAssignment`
    leidžiant jį naudoti kaip įtraukiamą modulį bet kuriam objektui.
    ([Pull Request](https://github.com/rails/rails/pull/10776))

*   Pridėti `ActiveModel::Dirty#[attr_name]_previously_changed?` ir
    `ActiveModel::Dirty#[attr_name]_previous_change` metodai, gerinant prieigą
    prie įrašytų pakeitimų po modelio išsaugojimo.
    ([Pull Request](https://github.com/rails/rails/pull/19847))

*   Patikrinti keli kontekstai `valid?` ir `invalid?` metoduose vienu metu.
    ([Pull Request](https://github.com/rails/rails/pull/21069))

*   Pakeistas `validates_acceptance_of` priimti `true` kaip numatytąją reikšmę
    be `1`.
    ([Pull Request](https://github.com/rails/rails/pull/18439))

Aktyvus darbas
-----------

Išsamių pakeitimų informacijai žiūrėkite [Changelog][active-job].

### Pastebimi pakeitimai

*   `ActiveJob::Base.deserialize` deleguoja darbo klasės funkcijai. Tai leidžia darbams
    pridedant bet kokius metaduomenis, kai jie yra serializuojami, ir juos nuskaitant atliekant
    darbus.
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*   Pridėta galimybė konfigūruoti eilės adapterį pagal darbą, neįtakojant vienas kitą.
    ([Pull Request](https://github.com/rails/rails/pull/16992))

*   Sugeneruotas darbas dabar pagal numatytuosius nustatymus paveldi iš `app/jobs/application_job.rb`.
    ([Pull Request](https://github.com/rails/rails/pull/19034))

*   Leidžiama `DelayedJob`, `Sidekiq`, `qu`, `que` ir `queue_classic` pranešti
    darbo ID atgal į `ActiveJob::Base` kaip `provider_job_id`.
    ([Pull Request](https://github.com/rails/rails/pull/20064),
     [Pull Request](https://github.com/rails/rails/pull/20056),
     [commit](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

*   Įgyvendintas paprastas `AsyncJob` procesorius ir susijęs `AsyncAdapter`, kuris
    eilėje deda darbus į `concurrent-ruby` gijų grupę.
    ([Pull Request](https://github.com/rails/rails/pull/21257))

*   Pakeistas numatytasis adapteris iš tiesioginio į asinchroninį. Tai geresnis numatytasis nustatymas,
    nes testai tuomet neteisingai nesiremia įvykių vykdymo sinchroniškumu.
    ([commit](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))
Aktyvusis palaikymas
--------------

Išsamesnės informacijos apie pakeitimus rasite [Changelog][active-support].

### Pašalinimai

*   Pašalintas pasenusi `ActiveSupport::JSON::Encoding::CircularReferenceError`.
    ([commit](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

*   Pašalinti pasenusių metodų `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=`
    ir `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string`.
    ([commit](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

*   Pašalintas pasenusi `ActiveSupport::SafeBuffer#prepend`.
    ([commit](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

*   Pašalinti pasenusių metodų iš `Kernel`. `silence_stderr`, `silence_stream`,
    `capture` ir `quietly`.
    ([commit](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

*   Pašalintas pasenusi `active_support/core_ext/big_decimal/yaml_conversions`
    failas.
    ([commit](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

*   Pašalinti pasenusių metodų `ActiveSupport::Cache::Store.instrument` ir
    `ActiveSupport::Cache::Store.instrument=`.
    ([commit](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

*   Pašalintas pasenusi `Class#superclass_delegating_accessor`.
    Vietoj to naudokite `Class#class_attribute`.
    ([Pull Request](https://github.com/rails/rails/pull/16938))

*   Pašalintas pasenusi `ThreadSafe::Cache`. Vietoj to naudokite `Concurrent::Map`.
    ([Pull Request](https://github.com/rails/rails/pull/21679))

*   Pašalintas `Object#itself`, nes jis įgyvendintas Ruby 2.2.
    ([Pull Request](https://github.com/rails/rails/pull/18244))

### Pasenusių funkcijų žymėjimai

*   Pasenęs `MissingSourceFile`, naudokite `LoadError` vietoj.
    ([commit](https://github.com/rails/rails/commit/734d97d2))

*   Pasenęs `alias_method_chain`, naudokite `Module#prepend`, kuris buvo įvestas
    Ruby 2.0.
    ([Pull Request](https://github.com/rails/rails/pull/19434))

*   Pasenęs `ActiveSupport::Concurrency::Latch`, naudokite
    `Concurrent::CountDownLatch` iš concurrent-ruby.
    ([Pull Request](https://github.com/rails/rails/pull/20866))

*   Pasenęs `:prefix` parametras `number_to_human_size` metode, be pakeitimo.
    ([Pull Request](https://github.com/rails/rails/pull/21191))

*   Pasenęs `Module#qualified_const_`, naudokite įdiegtus
    `Module#const_` metodus.
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*   Pasenęs eilutės perdavimas, nenaudokite eilutės apibrėžiantys atgalinio iškvietimo.
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*   Pasenęs `ActiveSupport::Cache::Store#namespaced_key`,
    `ActiveSupport::Cache::MemCachedStore#escape_key` ir
    `ActiveSupport::Cache::FileStore#key_file_path`.
    Vietoj to naudokite `normalize_key`.
    ([Pull Request](https://github.com/rails/rails/pull/22215),
     [commit](https://github.com/rails/rails/commit/a8f773b0))

*   Pasenęs `ActiveSupport::Cache::LocaleCache#set_cache_value`, naudokite `write_cache_value`.
    ([Pull Request](https://github.com/rails/rails/pull/22215))

*   Pasenęs argumentų perdavimas `assert_nothing_raised`.
    ([Pull Request](https://github.com/rails/rails/pull/23789))

*   Pasenęs `Module.local_constants`, naudokite `Module.constants(false)`.
    ([Pull Request](https://github.com/rails/rails/pull/23936))


### Svarbūs pakeitimai

*   Pridėti `#verified` ir `#valid_message?` metodai `ActiveSupport::MessageVerifier`.
    ([Pull Request](https://github.com/rails/rails/pull/17727))

*   Pakeistas būdas, kaip galima sustabdyti atgalinio iškvietimo grandines. Nuo šiol
    pageidautina sustabdyti atgalinio iškvietimo grandinę išreiškiant `throw(:abort)`.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Naujas konfigūracijos parametras
    `config.active_support.halt_callback_chains_on_return_false`, skirtas nurodyti,
    ar ActiveRecord, ActiveModel ir ActiveModel::Validations atgalinio iškvietimo
    grandinės gali būti sustabdytos grąžinant `false` 'before' atgalinio iškvietimo metu.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Pakeistas numatytasis testų tvarka iš `:sorted` į `:random`.
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

*   Pridėti `#on_weekend?`, `#on_weekday?`, `#next_weekday`, `#prev_weekday` metodai `Date`,
    `Time` ir `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335),
     [Pull Request](https://github.com/rails/rails/pull/23687))

*   Pridėtas `same_time` parametras `#next_week` ir `#prev_week` metodams `Date`, `Time`
    ir `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   Pridėti `#prev_day` ir `#next_day` metodai, kurie yra analogai `#yesterday` ir
    `#tomorrow` metodams `Date`, `Time` ir `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   Pridėtas `SecureRandom.base58` funkcionalumas, skirtas generuoti atsitiktinius base58 eilučių.
    ([commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b))

*   Pridėtas `file_fixture` į `ActiveSupport::TestCase`.
    Tai suteikia paprastą mechanizmą, skirtą pasiekti pavyzdinius failus jūsų testavimo atvejuose.
    ([Pull Request](https://github.com/rails/rails/pull/18658))

*   Pridėtas `#without` metodas `Enumerable` ir `Array`, skirtas grąžinti kopiją
    išvardijimo be nurodytų elementų.
    ([Pull Request](https://github.com/rails/rails/pull/19157))
*   Pridėtas `ActiveSupport::ArrayInquirer` ir `Array#inquiry`.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   Pridėtas `ActiveSupport::TimeZone#strptime` metodas, leidžiantis analizuoti laikus, tarsi jie būtų iš tam tikros laiko juostos.
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

*   Pridėti `Integer#positive?` ir `Integer#negative?` užklausos metodai, panašūs į `Integer#zero?`.
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

*   Pridėtas `ActiveSupport::OrderedOptions` gauti metodų bang versijas, kurios iškels `KeyError`, jei reikšmė yra `.blank?`.
    ([Pull Request](https://github.com/rails/rails/pull/20208))

*   Pridėtas `Time.days_in_year` metodas, grąžinantis dienų skaičių duotam metams arba dabartiniam metui, jei nėra argumento.
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

*   Pridėtas įvykių stebėtojas failams, kuris asinchroniškai aptinka pakeitimus programos šaltinių kode, maršrutuose, lokalėse ir kt.
    ([Pull Request](https://github.com/rails/rails/pull/22254))

*   Pridėtas `thread_m/cattr_accessor/reader/writer` metodų rinkinys, skirtas deklaruoti klasės ir modulio kintamuosius, kurie gyvena per giją.
    ([Pull Request](https://github.com/rails/rails/pull/22630))

*   Pridėti `Array#second_to_last` ir `Array#third_to_last` metodai.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   Paskelbti `ActiveSupport::Executor` ir `ActiveSupport::Reloader` API, leidžiantys komponentams ir bibliotekoms valdyti ir dalyvauti vykdant programos kodą ir programos perkrovimo procesą.
    ([Pull Request](https://github.com/rails/rails/pull/23807))

*   `ActiveSupport::Duration` dabar palaiko ISO8601 formatavimą ir analizavimą.
    ([Pull Request](https://github.com/rails/rails/pull/16917))

*   `ActiveSupport::JSON.decode` dabar palaiko ISO8601 vietinių laikų analizavimą, kai įjungtas `parse_json_times`.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   `ActiveSupport::JSON.decode` dabar grąžina `Date` objektus datų eilutėms.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   Pridėta galimybė `TaggedLogging` leisti žurnalistams būti sukuriamiems kelis kartus, kad jie nesidalintų žymėmis tarpusavyje.
    ([Pull Request](https://github.com/rails/rails/pull/9065))

Kreditai
-------

Žiūrėkite
[pilną sąrašą Rails prisidėjusių asmenų](https://contributors.rubyonrails.org/), kurie daugelį valandų skyrė kurti Rails, stabilų ir patikimą karkasą. Dėkojame jiems visiems.
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
