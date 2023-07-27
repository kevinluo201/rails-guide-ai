**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4d8311a1435138a81e26a7e8f537dbde
Ruby on Rails 4.2 Išleidimo pastabos
====================================

Svarbiausi dalykai Rails 4.2:

* Active Job
* Asinchroninės pašto žinutės
* Adekvatus įrašas
* Web Console
* Užsienio raktų palaikymas

Šios išleidimo pastabos apima tik pagrindinius pokyčius. Norėdami sužinoti apie kitas funkcijas, klaidų taisymus ir pokyčius, prašome kreiptis į pakeitimų žurnalus arba peržiūrėti [pokyčių sąrašą](https://github.com/rails/rails/commits/4-2-stable) pagrindiniame Rails saugykloje GitHub.

--------------------------------------------------------------------------------

Atnaujinimas iki Rails 4.2
--------------------------

Jei atnaujinote esamą programą, gerai būtų turėti gerą testų padengimą prieš pradedant. Taip pat pirmiausia turėtumėte atnaujinti iki Rails 4.1, jei dar to nedarėte, ir įsitikinti, kad jūsų programa vis dar veikia kaip tikėtasi, prieš bandant atnaujinti iki Rails 4.2. Atnaujinimo metu reikia atkreipti dėmesį į keletą dalykų, kuriuos galima rasti vadove [Atnaujinimas Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2).

Pagrindinės funkcijos
---------------------

### Active Job

Active Job yra nauja platforma Rails 4.2. Tai yra bendras sąsajos sluoksnis virš eilės sistemų, tokios kaip [Resque](https://github.com/resque/resque), [Delayed Job](https://github.com/collectiveidea/delayed_job), [Sidekiq](https://github.com/mperham/sidekiq) ir kt.

Naudojant Active Job API parašyti darbai vykdomi bet kurioje palaikomoje eilėje dėka atitinkamų adapterių. Active Job jau yra sukonfigūruotas su įterptiniu vykdytoju, kuris iškart vykdo darbus.

Darbams dažnai reikia pateikti Active Record objektus kaip argumentus. Active Job perduoda objekto nuorodas kaip URI (uniform resource identifiers), o ne patį objektą. Naujoji [Global ID](https://github.com/rails/globalid) biblioteka sukuria URI ir ieško objektų, į kuriuos jos nukreipia. Perduodant Active Record objektus kaip darbo argumentus, tai veikia naudojant Global ID viduje.

Pavyzdžiui, jei `trashable` yra Active Record objektas, tada šis darbas veikia be jokio serializavimo:

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

Daugiau informacijos rasite vadove [Active Job Basics](active_job_basics.html).

### Asinchroninės pašto žinutės

Papildant Active Job, Action Mailer dabar turi `deliver_later` metodą, kuris siunčia pašto žinutes per eilę, todėl jis neblokuoja kontrolerio ar modelio, jei eilė yra asinchroninė (numatytasis įterptinės eilės blokuoja).

Išsiųsti pašto žinutes iš karto vis dar įmanoma naudojant `deliver_now`.

### Adekvatus įrašas

Adekvatus įrašas yra veikimo pagerinimų rinkinys Active Record, kuris padaro įprastus `find` ir `find_by` kvietimus bei kai kuriuos asociacijos užklausas iki 2 kartų greitesnius.

Tai veikia taip, kad įprastus SQL užklausas kaip paruoštus teiginius talpina į talpyklą ir vėliau panaudoja panašiuose kvietimuose, praleisdama didžiąją dalį užklausos generavimo darbo kituose kvietimuose. Daugiau informacijos rasite [Aaron Patterson tinklaraščio įraše](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html).

Active Record automatiškai pasinaudos šia funkcija palaikomose operacijose be jokio vartotojo dalyvavimo ar kodų pakeitimų. Štai keletas pavyzdžių palaikomų operacijų:

```ruby
Post.find(1)  # Pirmasis kvietimas generuoja ir talpina paruoštą teiginį
Post.find(2)  # Kituose kvietimuose naudojamas talpinamas paruoštas teiginys

Post.find_by_title('first post')
Post.find_by_title('second post')

Post.find_by(title: 'first post')
Post.find_by(title: 'second post')

post.comments
post.comments(true)
```

Svarbu paminėti, kad, kaip rodo aukščiau pateikti pavyzdžiai, paruošti teiginiai nekeliavo reikšmių, perduodamų metodų kvietimuose; jie turi vietoj jų vietos laikymo vietas.

Talpykla nenaudojama šiuose scenarijuose:
- Modelis turi numatytąjį apimtį
- Modelis naudoja vienos lentelės paveldėjimą
- `find` su sąrašu id, pvz .:

    ```ruby
    # nekešuota
    Post.find(1, 2, 3)
    Post.find([1,2])
    ```

- `find_by` su SQL fragmentais:

    ```ruby
    Post.find_by('published_at < ?', 2 savaitės.ago)
    ```

### Web Console

Naujos sukuriamos aplikacijos su Rails 4.2 dabar pagal numatymą turi [Web
Console](https://github.com/rails/web-console) gemą. Web Console prideda
interaktyvią Ruby konsolę kiekvienoje klaidos puslapyje ir teikia `console` rodinio
ir kontrolerio pagalbines funkcijas.

Interaktyvioji konsolė klaidos puslapiuose leidžia vykdyti kodą kontekste,
kurioje kilo išimtis. `console` pagalbininkas, jei jis yra iškviestas
bet kurioje rodinyje ar kontroleryje, paleidžia interaktyvią konsolę su galutiniu
kontekstu, kai atlikta atvaizdavimas.

### Užsienio rakto palaikymas

Migracijos DSL dabar palaiko užsienio raktų pridėjimą ir pašalinimą. Jie yra išmetami
į `schema.rb` taip pat. Šiuo metu tik `mysql`, `mysql2` ir `postgresql`
adapteriai palaiko užsienio raktus.

```ruby
# pridėti užsienio raktą į `articles.author_id`, kuris rodo į `authors.id`
add_foreign_key :articles, :authors

# pridėti užsienio raktą į `articles.author_id`, kuris rodo į `users.lng_id`
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# pašalinti užsienio raktą iš `accounts.branch_id`
remove_foreign_key :accounts, :branches

# pašalinti užsienio raktą iš `accounts.owner_id`
remove_foreign_key :accounts, column: :owner_id
```

Žr. API dokumentaciją apie
[add_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)
ir
[remove_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)
pilną aprašymą.


Nesuderinamumai
-----------------

Anksčiau pažymėta funkcionalumas buvo pašalintas. Prašome kreiptis į
atitinkamus komponentus dėl naujų pasenusiųjų šioje versijoje.

Šie pokyčiai gali reikalauti nedelsiant veiksmų po atnaujinimo.

### `render` su eilutės argumentu

Anksčiau, iškvietus `render "foo/bar"` kontrolerio veiksmo metu, tai buvo lygiavertė
`render file: "foo/bar"`. Rails 4.2 versijoje tai buvo pakeista ir dabar tai reiškia
`render template: "foo/bar"`. Jei norite atvaizduoti failą, prašome
pakeisti kodą ir naudoti aiškų formatą (`render file: "foo/bar"`) vietoj to.

### `respond_with` / Klasės lygio `respond_to`

`respond_with` ir atitinkamos klasės lygio `respond_to` buvo perkeltos
į [responders](https://github.com/plataformatec/responders) gemą. Norėdami
naudoti jį, pridėkite `gem 'responders', '~> 2.0'` į savo `Gemfile`:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

Egzemplioriaus lygio `respond_to` nėra paveikta:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

### Numatytasis prievadas `rails server`

Dėl pakeitimo Rack'e ([change in Rack](https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc)),
`rails server` dabar klausosi `localhost` vietoje `0.0.0.0` pagal numatymą. Tai
turėtų turėti minimalų poveikį įprastam vystymo procesui, nes tiek
http://127.0.0.1:3000, tiek http://localhost:3000 toliau veiks kaip anksčiau
jūsų pačio mašinoje.

Tačiau su šiuo pakeitimu jūs nebegalėsite pasiekti Rails
serverio iš kitos mašinos, pvz., jei jūsų vystymo aplinka
yra virtualioje mašinoje ir norite pasiekti ją iš pagrindinės mašinos.
Tokiu atveju, paleiskite serverį su `rails server -b 0.0.0.0`
kad atkurtumėte seną elgesį.

Tai padarius, įsitikinkite, kad tinkamai sukonfigūravote ugniasienę, kad tik
patikimos mašinos jūsų tinkle galėtų pasiekti jūsų vystymo serverį.
### Pakeisti `render` metodo statuso parinkties simboliai

Dėl [pakeitimo Rack](https://github.com/rack/rack/commit/be28c6a2ac152fe4adfbef71f3db9f4200df89e8) bibliotekoje, `render` metodui priimami simboliai `:status` parinkčiai buvo pakeisti:

- 306: `:reserved` buvo pašalintas.
- 413: `:request_entity_too_large` buvo pervadintas į `:payload_too_large`.
- 414: `:request_uri_too_long` buvo pervadintas į `:uri_too_long`.
- 416: `:requested_range_not_satisfiable` buvo pervadintas į `:range_not_satisfiable`.

Atkreipkite dėmesį, kad jei `render` funkcija yra iškviesta su nežinomu simboliu, atsakymo statusas bus nustatytas į 500.

### HTML Sanitizer

HTML Sanitizer buvo pakeistas nauju, patikimesniu, įgyvendinimu, kuris yra paremtas [Loofah](https://github.com/flavorjones/loofah) ir [Nokogiri](https://github.com/sparklemotion/nokogiri) bibliotekomis. Naujas Sanitizer yra saugesnis, o jo sanitarizacija yra galingesnė ir lankstesnė.

Dėl naujo algoritmo, sanitarizuotas rezultatas gali skirtis tam tikriems patologiniams įvesties duomenims.

Jei jums reikia tikslaus senojo Sanitizer rezultato, galite pridėti [rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer) gemą į `Gemfile`, kad gautumėte senąjį elgesį. Šis gemas nekelia deprecijos įspėjimų, nes jis yra pasirinktinis.

`rails-deprecated_sanitizer` bus palaikomas tik Rails 4.2; jis nebus palaikomas Rails 5.0.

Daugiau informacijos apie naujojo Sanitizer pakeitimus galite rasti [šiame blogo įraše](https://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/).

### `assert_select`

`assert_select` dabar yra paremtas [Nokogiri](https://github.com/sparklemotion/nokogiri) biblioteka. Dėl to, kai kurie anksčiau galioję selektoriai dabar nepalaikomi. Jei jūsų programa naudoja šiuos rašymus, jums reikės juos atnaujinti:

*   Reikšmės atributo selektoriuose gali prireikti cituoti, jei jose yra ne alfanumeriniai simboliai.

    ```ruby
    # anksčiau
    a[href=/]
    a[href$=/]

    # dabar
    a[href="/"]
    a[href$="/"]
    ```

*   Iš HTML šaltinio su netinkamai įdėtais elementais sudaryti DOM gali skirtis.

    Pavyzdžiui:

    ```ruby
    # turinys: <div><i><p></i></div>

    # anksčiau:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => false
    assert_select('i > p')    # => true

    # dabar:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => true
    assert_select('i > p')    # => false
    ```

*   Jei pasirinkti duomenys turi entitetus, anksčiau pasirinkta palyginimo reikšmė buvo neapdorota (pvz., `AT&amp;T`), o dabar ji yra apdorota (pvz., `AT&T`).

    ```ruby
    # turinys: <p>AT&amp;T</p>

    # anksčiau:
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # dabar:
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

Be to, pakeitėsi pakeitimų sintaksė.

Dabar turite naudoti `:match` CSS tipo selektorių:

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

Be to, kai sakinys nepavyksta, Regexp pakeitimai atrodo kitaip. Atkreipkite dėmesį, kaip `/hello/` čia:

```ruby
assert_select(":match('id', ?)", /hello/)
```

tampa `"(?-mix:hello)"`:

```
Expected at least 1 element matching "div:match('id', "(?-mix:hello)")", found 0..
Expected 0 to be >= 1.
```

Daugiau informacijos apie `assert_select` rasite [Rails Dom Testing](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b) dokumentacijoje.

Railties
--------

Išsamių pakeitimų informacijai žiūrėkite [Changelog][railties].

### Pašalinimai

*   `--skip-action-view` parinktis buvo pašalinta iš programos kūrėjo. ([Pull Request](https://github.com/rails/rails/pull/17042))

*   `rails application` komanda buvo pašalinta be pakeitimo. ([Pull Request](https://github.com/rails/rails/pull/11616))

### Depreciations

*   Pasenusi trūkstama `config.log_level` konfigūracija produkcinėse aplinkose. ([Pull Request](https://github.com/rails/rails/pull/16622))

*   Pasenusi `rake test:all` komanda pakeista į `rake test`, nes dabar ji paleidžia visus testus `test` aplanke. ([Pull Request](https://github.com/rails/rails/pull/17348))
*   Pasenktas `rake test:all:db` naudai `rake test:db`.
    ([Pull Request](https://github.com/rails/rails/pull/17348))

*   Pasenktas `Rails::Rack::LogTailer` be pakeitimo.
    ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### Svarbūs pakeitimai

*   Įtrauktas `web-console` į numatytąjį programos `Gemfile`.
    ([Pull Request](https://github.com/rails/rails/pull/11667))

*   Modelio generatoriui pridėta `required` parinktis asociacijoms.
    ([Pull Request](https://github.com/rails/rails/pull/16062))

*   Įvestas `x` vardų sritis, skirta apibrėžti pasirinktines konfigūracijos parinktis:

    ```ruby
    # config/environments/production.rb
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries  = 3
    config.x.super_debugger              = true
    ```

    Šios parinktys tada yra pasiekiamos per konfigūracijos objektą:

    ```ruby
    Rails.configuration.x.payment_processing.schedule # => :daily
    Rails.configuration.x.payment_processing.retries  # => 3
    Rails.configuration.x.super_debugger              # => true
    ```

    ([Commit](https://github.com/rails/rails/commit/611849772dd66c2e4d005dcfe153f7ce79a8a7db))

*   Įvestas `Rails::Application.config_for` metodas, skirtas įkelti konfigūraciją
    esamai aplinkai.

    ```yaml
    # config/exception_notification.yml
    production:
      url: http://127.0.0.1:8080
      namespace: my_app_production
    development:
      url: http://localhost:3001
      namespace: my_app_development
    ```

    ```ruby
    # config/environments/production.rb
    Rails.application.configure do
      config.middleware.use ExceptionNotifier, config_for(:exception_notification)
    end
    ```

    ([Pull Request](https://github.com/rails/rails/pull/16129))

*   Įvesta `--skip-turbolinks` parinktis programos generatoriuje, kad nebūtų generuojama
    turbolinks integracija.
    ([Commit](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

*   Įvestas `bin/setup` scenarijus kaip konvencija automatiniam programos nustatymo kodo
    paleidimui.
    ([Pull Request](https://github.com/rails/rails/pull/15189))

*   Pakeista numatytoji reikšmė `config.assets.digest` į `true` vystymo metu.
    ([Pull Request](https://github.com/rails/rails/pull/15155))

*   Įvestas API naujų plėtinių registravimui `rake notes`.
    ([Pull Request](https://github.com/rails/rails/pull/14379))

*   Įvestas `after_bundle` atgalinis kvietimas naudojimui Rails šablonuose.
    ([Pull Request](https://github.com/rails/rails/pull/16359))

*   Įvestas `Rails.gem_version` kaip patogus metodas grąžinti
    `Gem::Version.new(Rails.version)`.
    ([Pull Request](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

Išsamūs pakeitimai pateikiami [Changelog][action-pack].

### Pašalinimai

*   `respond_with` ir klasės lygio `respond_to` pašalinti iš Rails ir
    perkelti į `responders` gemą (versija 2.0). Norėdami toliau naudoti šias
    funkcijas, į savo `Gemfile` pridėkite `gem 'responders', '~> 2.0'`.
    ([Pull Request](https://github.com/rails/rails/pull/16526),
     [Daugiau informacijos](https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders))

*   Pašalintas pasenusių `AbstractController::Helpers::ClassMethods::MissingHelperError`
    naudai `AbstractController::Helpers::MissingHelperError`.
    ([Commit](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### Pasenusių funkcijų pažymėjimai

*   Pažymėta `only_path` parinktis `*_path` pagalbininkams.
    ([Commit](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9))

*   Pažymėta `assert_tag`, `assert_no_tag`, `find_tag` ir `find_all_tag` funkcijų
    pasenusių `assert_select` naudai.
    ([Commit](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

*   Pažymėta palaikymo pasenusiems maršrutizatoriaus `:to` parinkčių nustatymui simboliu arba
    eilute, kuri neapima `#` simbolio:

    ```ruby
    get '/posts', to: MyRackApp    => (Nereikia keisti)
    get '/posts', to: 'post#index' => (Nereikia keisti)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```

    ([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

*   Pažymėtas palaikymo eilučių raktams URL pagalbininkuose pasenusiems:

    ```ruby
    # blogai
    root_path('controller' => 'posts', 'action' => 'index')

    # gerai
    root_path(controller: 'posts', action: 'index')
    ```

    ([Pull Request](https://github.com/rails/rails/pull/17743))

### Svarbūs pakeitimai

*   Dokumentacijoje pašalinti `*_filter` metodų šeimos nariai. Jų
    naudojimas nerekomenduojamas, o vietoje jų rekomenduojami `*_action` metodai:

    ```
    after_filter          => after_action
    append_after_filter   => append_after_action
    append_around_filter  => append_around_action
    append_before_filter  => append_before_action
    around_filter         => around_action
    before_filter         => before_action
    prepend_after_filter  => prepend_after_action
    prepend_around_filter => prepend_around_action
    prepend_before_filter => prepend_before_action
    skip_after_filter     => skip_after_action
    skip_around_filter    => skip_around_action
    skip_before_filter    => skip_before_action
    skip_filter           => skip_action_callback
    ```

    Jei jūsų programa priklauso nuo šių metodų, turėtumėte naudoti
    pakeitimo `*_action` metodus. Šie metodai bus pažymėti kaip pasenusiems
    ateityje ir galiausiai bus pašalinti iš Rails.

    (Commit [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de),
    [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4))

*   `render nothing: true` arba `nil` kūno atvaizdavimas nebeprideda vieno
    tarpelio prie atsakymo kūno.
    ([Pull Request](https://github.com/rails/rails/pull/14883))
*   Dabar "Rails" automatiškai įtraukia šablono "digest" į ETag'us.
    ([Pull Request](https://github.com/rails/rails/pull/16527))

*   URL pagalbininkams perduodami segmentai dabar automatiškai išvengiami.
    ([Commit](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

*   Įvesta "always_permitted_parameters" parinktis, skirta konfigūruoti, kurie
    parametrai yra leidžiami globaliai. Šios konfigūracijos numatytasis reikšmė
    yra `['controller', 'action']`.
    ([Pull Request](https://github.com/rails/rails/pull/15933))

*   Pridėtas HTTP metodas `MKCALENDAR` iš [RFC 4791](https://tools.ietf.org/html/rfc4791).
    ([Pull Request](https://github.com/rails/rails/pull/15121))

*   `*_fragment.action_controller` pranešimuose dabar įtraukiamas kontrolerio
    ir veiksmo pavadinimas.
    ([Pull Request](https://github.com/rails/rails/pull/14137))

*   Gerintas maršruto klaidos puslapis su migloto atitikimo paieška maršrutams.
    ([Pull Request](https://github.com/rails/rails/pull/14619))

*   Pridėta parinktis, leidžianti išjungti CSRF nesėkmių žurnalo įrašymą.
    ([Pull Request](https://github.com/rails/rails/pull/14280))

*   Kai "Rails" serveris nustatomas aptarnauti statinius išteklius, gzip ištekliai dabar bus
    aptarnaujami, jei klientas tai palaiko ir diske yra iš anksto sugeneruotas gzip failas (`.gz`).
    Pagal nutylėjimą išteklių grandinė generuoja `.gz` failus visiems suspaudžiamiems ištekliams.
    Gzip failų aptarnavimas sumažina duomenų perdavimą ir pagreitina išteklių užklausas. Visada
    [naudokite CDN](https://guides.rubyonrails.org/v4.2/asset_pipeline.html#cdns), jei aptarnaujate
    išteklius iš savo "Rails" serverio produkcijoje.
    ([Pull Request](https://github.com/rails/rails/pull/16466))

*   Skambinant `process` pagalbininkams integracinėje teste, kelias turi turėti
    pirminį pasvirąjį brūkšnį. Anksčiau galėjote jį praleisti, tačiau tai buvo
    įgyvendinimo šalutinis produktas, o ne sąmoninga funkcija, pvz.:

    ```ruby
    test "list all posts" do
      get "/posts"
      assert_response :success
    end
    ```

Veiksmo rodinys
-----------

Išsamesniam pakeitimų sąrašui žiūrėkite [Changelog][action-view].

### Pasenusios funkcijos

*   Pasenusi `AbstractController::Base.parent_prefixes`.
    Keiskite `AbstractController::Base.local_prefixes`, kai norite pakeisti,
    kur rasti rodinius.
    ([Pull Request](https://github.com/rails/rails/pull/15026))

*   Pasenusi `ActionView::Digestor#digest(name, format, finder, options = {})`.
    Vietoj to argumentai turėtų būti perduodami kaip maišos objektas.
    ([Pull Request](https://github.com/rails/rails/pull/14243))

### Pastebimi pakeitimai

*   `render "foo/bar"` dabar išplečiamas į `render template: "foo/bar"`, o ne
    `render file: "foo/bar"`.
    ([Pull Request](https://github.com/rails/rails/pull/16888))

*   Formos pagalbininkai daugiau nekuria `<div>` elemento su įterptu CSS aplink
    paslėptus laukus.
    ([Pull Request](https://github.com/rails/rails/pull/14738))

*   Įvestas `#{partial_name}_iteration` specialus vietinis kintamasis, skirtas
    naudoti su daliniais, kurie yra rodomi su kolekcija. Jis suteikia prieigą
    prie dabartinės iteracijos būsenos per `index`, `size`, `first?` ir
    `last?` metodus.
    ([Pull Request](https://github.com/rails/rails/pull/7698))

*   Vietos I18n seka tą pačią konvenciją kaip ir `label` I18n.
    ([Pull Request](https://github.com/rails/rails/pull/16438))


Veiksmo paštas
-------------

Išsamesniam pakeitimų sąrašui žiūrėkite [Changelog][action-mailer].

### Pasenusios funkcijos

*   Pasenusi `*_path` pagalbininkai paštuose. Visada naudokite `*_url` pagalbininkus.
    ([Pull Request](https://github.com/rails/rails/pull/15840))

*   Pasenusi `deliver` / `deliver!`, naudokite `deliver_now` / `deliver_now!` vietoje.
    ([Pull Request](https://github.com/rails/rails/pull/16582))

### Pastebimi pakeitimai

*   `link_to` ir `url_for` pagal nutylėjimą šablonuose generuoja absoliučius URL,
    nebūtina perduoti `only_path: false`.
    ([Commit](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

*   Įvestas `deliver_later`, kuris įtraukia užduotį į programos eilę
    asinchroniniam el. pašto pristatymui.
    ([Pull Request](https://github.com/rails/rails/pull/16485))

*   Pridėta `show_previews` konfigūracijos parinktis, leidžianti įjungti el. pašto peržiūras
    ne tik vystymo aplinkoje.
    ([Pull Request](https://github.com/rails/rails/pull/15970))


Aktyvusis įrašas
-------------

Išsamesniam pakeitimų sąrašui žiūrėkite [Changelog][active-record].

### Pašalinimai

*   Pašalintas `cache_attributes` ir panašūs. Visi atributai yra talpinami talpykloje.
    ([Pull Request](https://github.com/rails/rails/pull/15429))

*   Pašalinta pasenusi `ActiveRecord::Base.quoted_locking_column` funkcija.
    ([Pull Request](https://github.com/rails/rails/pull/15612))

*   Pašalinta pasenusi `ActiveRecord::Migrator.proper_table_name` funkcija. Vietoj jos
    naudokite `proper_table_name` objekto metodo `ActiveRecord::Migration` vietoje.
    ([Pull Request](https://github.com/rails/rails/pull/15512))

*   Pašalintas nenaudojamas `:timestamp` tipas. Visais atvejais jis dabar automatiškai
    susiejamas su `:datetime`. Ištaisoma nesuderinamumas, kai stulpelių tipai yra siunčiami
    iš "Active Record" išorėje, pvz., XML serializacijai.
    ([Pull Request](https://github.com/rails/rails/pull/15184))
### Nusistatymai

*   Nustatytas klaidų slėpimas `after_commit` ir `after_rollback` viduje.
    ([Pull Request](https://github.com/rails/rails/pull/16537))

*   Nustatytas sugedęs palaikymas automatiniam skaitiklių talpyklų aptikimui
    `has_many :through` asociacijose. Vietoj to, turėtumėte rankiniu būdu nurodyti
    skaitiklių talpyklą `has_many` ir `belongs_to` asociacijose per
    perduodamus įrašus.
    ([Pull Request](https://github.com/rails/rails/pull/15754))

*   Nustatytas `Active Record` objektų perdavimas į `.find` arba `.exists?` kaip pasenusi. Pirmiausia turėtumėte paskambinti `id` objektams.
    (Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
    [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   Nustatytas nepilnavertis palaikymas `PostgreSQL` diapazono reikšmėms su išskiriančiais pradžiomis. Šiuo metu atitinkame `PostgreSQL` diapazonus su Ruby diapazonais. Šis konvertavimas
    nėra visiškai įmanomas, nes Ruby diapazonai nepalaiko išskiriančių pradžių.

    Dabartinis sprendimas pridėti pradžią nėra teisingas
    ir dabar yra pasenusi. Subtipams, kurių nežinome, kaip padidinti
    (pvz., `succ` nėra apibrėžtas), tai sukels `ArgumentError` išimtį diapazonams
    su išskiriančiomis pradžiomis.
    ([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   Nustatytas `DatabaseTasks.load_schema` kvietimas be ryšio. Vietoj to naudokite
    `DatabaseTasks.load_schema_current`.
    ([Commit](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   Nustatytas `sanitize_sql_hash_for_conditions` be pakeitimo. Naudojant
    `Relation` užklausoms ir atnaujinimams yra pageidautinas API.
    ([Commit](https://github.com/rails/rails/commit/d5902c9e))

*   Nustatytas `add_timestamps` ir `t.timestamps` be `:null`
    parinkties perdavimo. Numatytasis `null: true` pasikeis į `null: false` Rails 5 versijoje.
    ([Pull Request](https://github.com/rails/rails/pull/16481))

*   Nustatytas `Reflection#source_macro` be pakeitimo, nes jis daugiau nebenaudojamas
    `Active Record`.
    ([Pull Request](https://github.com/rails/rails/pull/16373))

*   Nustatytas `serialized_attributes` be pakeitimo.
    ([Pull Request](https://github.com/rails/rails/pull/15704))

*   Nustatytas `nil` grąžinimas iš `column_for_attribute`, kai stulpelis neegzistuoja. Tai grąžins nulio objektą Rails 5.0 versijoje.
    ([Pull Request](https://github.com/rails/rails/pull/15878))

*   Nustatytas `.joins`, `.preload` ir `.eager_load` naudojimas su asociacijomis
    priklausančiomis nuo objekto būsenos (t. y. tokiomis, kurios apibrėžtos su sąlyga, kuri
    priima argumentą) be pakeitimo.
    ([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### Svarbūs pakeitimai

*   `SchemaDumper` naudoja `force: :cascade` ant `create_table`. Tai leidžia
    perkrauti schemą, kai yra užsienio raktai.

*   Pridėta `:required` parinktis vienareikšmiams asociacijoms, kuri nustato
    būtinumo tikrinimą asociacijoje.
    ([Pull Request](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty` dabar aptinka vietos pakeitimus keičiantiems reikšmėms. Serializuotos atributai `Active Record` modeliuose nebėra išsaugomi, kai
    nepasikeičia. Tai taip pat veikia su kitais tipais, pvz., eilutės stulpeliais ir json
    stulpeliais `PostgreSQL`.
    (Pull Requests [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))

*   Įvestas `db:purge` Rake užduotis, skirta išvalyti duomenų bazę
    esamam aplinkai.
    ([Commit](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

*   Įvestas `ActiveRecord::Base#validate!`, kuris iškelia
    `ActiveRecord::RecordInvalid` išimtį, jei įrašas yra neteisingas.
    ([Pull Request](https://github.com/rails/rails/pull/8639))

*   Įvestas `validate` kaip sinonimas `valid?`.
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   `touch` dabar priima kelis atributus, kurie bus paliesti vienu metu.
    ([Pull Request](https://github.com/rails/rails/pull/14423))

*   `PostgreSQL` adapteris dabar palaiko `jsonb` duomenų tipą `PostgreSQL` 9.4+ versijoje.
    ([Pull Request](https://github.com/rails/rails/pull/16220))

*   `PostgreSQL` ir `SQLite` adapteriai nebededa numatytos 255
    simbolių ribos ant eilutės stulpelių.
    ([Pull Request](https://github.com/rails/rails/pull/14579))

*   Pridėta palaikymo `citext` stulpelio tipo `PostgreSQL` adapteryje.
    ([Pull Request](https://github.com/rails/rails/pull/12523))

*   Pridėta palaikymo vartotojo sukurtiems diapazono tipams `PostgreSQL` adapteryje.
    ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

*   `sqlite3:///some/path` dabar nusako absoliutų sistemos kelią
    `/some/path`. Naudojant reliatyvius kodus, naudokite `sqlite3:some/path`.
    (Anksčiau, `sqlite3:///some/path` nusakė reliatyvų kelią
    `some/path`. Šis elgesys buvo pasenusi nuo Rails 4.1).
    ([Pull Request](https://github.com/rails/rails/pull/14569))

*   Pridėtas palaikymas trupmeninėms sekundėms `MySQL` 5.6 ir naujesnėse versijose.
    (Pull Request [1](https://github.com/rails/rails/pull/8240),
    [2](https://github.com/rails/rails/pull/14359))
*   Pridėtas `ActiveRecord::Base#pretty_print` metodas, skirtas gražiam išvedimui modeliams.
    ([Pull Request](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload` dabar elgiasi taip pat kaip `m = Model.find(m.id)`,
    tai reiškia, kad ji nebeturi papildomų atributų iš pasirinktų `SELECT` užklausų.
    ([Pull Request](https://github.com/rails/rails/pull/15866))

*   `ActiveRecord::Base#reflections` dabar grąžina `Hash` su tekstiniais raktų pavadinimais, o ne simboliais.
    ([Pull Request](https://github.com/rails/rails/pull/17718))

*   `references` metodas migracijose dabar palaiko `type` parinktį, skirtą nurodyti užsienio rakto tipo (pvz., `:uuid`).
    ([Pull Request](https://github.com/rails/rails/pull/16231))

Active Model
------------

Išsamius pakeitimus žr. [Changelog][active-model].

### Pašalinimai

*   Pašalintas pasenusių `Validator#setup` metodo, be pakeitimo.
    ([Pull Request](https://github.com/rails/rails/pull/10716))

### Pasenusių funkcijų pranešimai

*   Pasenusi `reset_#{attribute}` funkcija pakeista į `restore_#{attribute}`.
    ([Pull Request](https://github.com/rails/rails/pull/16180))

*   Pasenusi `ActiveModel::Dirty#reset_changes` funkcija pakeista į
    `clear_changes_information`.
    ([Pull Request](https://github.com/rails/rails/pull/16180))

### Svarbūs pakeitimai

*   Įvestas `validate` kaip sinonimas `valid?` funkcijai.
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   Įvestas `restore_attributes` metodas `ActiveModel::Dirty` klasėje, skirtas atkurti
    pakeistus (nešvarius) atributus į jų ankstesnes reikšmes.
    (Pull Request [1](https://github.com/rails/rails/pull/14861),
    [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password` dabar leidžia tuščius slaptažodžius (t.y. slaptažodžius,
    kurie sudaryti tik iš tarpų) pagal nutylėjimą.
    ([Pull Request](https://github.com/rails/rails/pull/16412))

*   `has_secure_password` dabar patikrina, ar pateiktas slaptažodis yra mažiau nei 72
    simboliai, jei įgalintos validacijos.
    ([Pull Request](https://github.com/rails/rails/pull/15708))

Active Support
--------------

Išsamius pakeitimus žr. [Changelog][active-support].

### Pašalinimai

*   Pašalinti pasenusių `Numeric#ago`, `Numeric#until`, `Numeric#since`,
    `Numeric#from_now` funkcijų.
    ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   Pašalinti pasenusių eilučių bazės `ActiveSupport::Callbacks`.
    ([Pull Request](https://github.com/rails/rails/pull/15100))

### Pasenusių funkcijų pranešimai

*   Pasenusios `Kernel#silence_stderr`, `Kernel#capture` ir `Kernel#quietly` funkcijos
    be pakeitimo.
    ([Pull Request](https://github.com/rails/rails/pull/13392))

*   Pasenusi `Class#superclass_delegating_accessor` funkcija, naudokite
    `Class#class_attribute` vietoje.
    ([Pull Request](https://github.com/rails/rails/pull/14271))

*   Pasenusi `ActiveSupport::SafeBuffer#prepend!` funkcija, nes
    `ActiveSupport::SafeBuffer#prepend` dabar atlieka tą pačią funkciją.
    ([Pull Request](https://github.com/rails/rails/pull/14529))

### Svarbūs pakeitimai

*   Įvesta nauja konfigūracijos parinktis `active_support.test_order`, skirta
    nurodyti testų vykdymo tvarką. Ši parinktis dabar pagal nutylėjimą yra `:sorted`,
    bet nuo Rails 5.0 ji bus pakeista į `:random`.
    ([Commit](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   `Object#try` ir `Object#try!` dabar gali būti naudojamos be aiškaus gavėjo bloke.
    ([Commit](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830),
    [Pull Request](https://github.com/rails/rails/pull/17361))

*   `travel_to` testavimo pagalbininkas dabar nukerpia `usec` komponentą iki 0.
    ([Commit](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   Įvestas `Object#itself` kaip tapatybės funkcija.
    (Commit [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810),
    [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   `Object#with_options` dabar gali būti naudojama be aiškaus gavėjo bloke.
    ([Pull Request](https://github.com/rails/rails/pull/16339))

*   Įvestas `String#truncate_words` funkcija, skirta sutrumpinti eilutę pagal žodžių skaičių.
    ([Pull Request](https://github.com/rails/rails/pull/16190))

*   Pridėtos `Hash#transform_values` ir `Hash#transform_values!` funkcijos, skirtos supaprastinti
    dažną modelio reikšmių keitimo šabloną, kai raktai lieka tokie patys.
    ([Pull Request](https://github.com/rails/rails/pull/15819))

*   `humanize` inflektoriaus pagalbininkas dabar pašalina bet kokius pradinius pabraukimus.
    ([Commit](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   Įvestas `Concern#class_methods` kaip alternatyva
    `module ClassMethods`, taip pat `Kernel#concern` funkcija, skirta išvengti
    `module Foo; extend ActiveSupport::Concern; end` šabloninio kodo.
    ([Commit](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   Naujas [vadovas](autoloading_and_reloading_constants_classic_mode.html) apie konstantų automatinį įkėlimą ir perkrovimą.

Autoriai
-------

Žr.
[pilną Rails prisidėjusių asmenų sąrašą](https://contributors.rubyonrails.org/), kuris
apima daugybę žmonių, kurie daugybę valandų skyrė tam, kad Rails taptų stabilia ir patikima
karkasu, koks jis yra šiandien. Dėkojame visiems jiems.
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
