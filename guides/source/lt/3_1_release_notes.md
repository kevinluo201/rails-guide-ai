**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: da25f37b5b3eddff86c5b5b2cd24007f
Ruby on Rails 3.1 Išleidimo pastabos
===============================

Svarbiausi dalykai Rails 3.1:

* Srautinė transliacija
* Atvirkštiniai migracijos
* Turtų eilė
* jQuery kaip numatytasis JavaScript biblioteka

Šiose išleidimo pastabose aptariami tik pagrindiniai pokyčiai. Norėdami sužinoti apie įvairius klaidų taisymus ir pokyčius, kreipkitės į pakeitimų žurnalus arba peržiūrėkite [pakeitimų sąrašą](https://github.com/rails/rails/commits/3-1-stable) pagrindiniame Rails saugykloje GitHub.

--------------------------------------------------------------------------------

Atnaujinimas iki Rails 3.1
----------------------

Jei atnaujinote esamą programą, gerai būtų turėti gerą testų padengimą prieš pradedant. Taip pat pirmiausia atnaujinkite iki Rails 3, jei dar to nepadarėte, ir įsitikinkite, kad jūsų programa vis dar veikia kaip tikėtasi, prieš bandydami atnaujinti iki Rails 3.1. Tada atkreipkite dėmesį į šiuos pokyčius:

### Rails 3.1 reikalauja bent Ruby 1.8.7

Rails 3.1 reikalauja Ruby 1.8.7 arba naujesnės versijos. Visos ankstesnės Ruby versijos oficialiai nebepalaikomos, todėl turėtumėte atnaujinti kuo greičiau. Rails 3.1 taip pat yra suderinamas su Ruby 1.9.2.

PATARIMAS: Atkreipkite dėmesį, kad Ruby 1.8.7 p248 ir p249 turi maršrutizavimo klaidas, kurios sukelia Rails žlugimą. Ruby Enterprise Edition šias klaidas turi ištaisytas nuo 1.8.7-2010.02 versijos. Kalbant apie 1.9 versiją, Ruby 1.9.1 negalima naudoti, nes ji tiesiog išjungia programą, todėl jei norite naudoti 1.9.x, pasirinkite 1.9.2 versiją.

### Kas atnaujinti savo programose

Šie pokyčiai skirti atnaujinti jūsų programą iki Rails 3.1.3, naujausios 3.1.x versijos.

#### Gemfile

Atlikite šiuos pakeitimus savo `Gemfile`.

```ruby
gem 'rails', '= 3.1.3'
gem 'mysql2'

# Reikalinga naujai turto eilei
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# jQuery yra numatytoji JavaScript biblioteka Rails 3.1
gem 'jquery-rails'
```

#### config/application.rb

* Turto eilei reikalingi šie papildymai:

    ```ruby
    config.assets.enabled = true
    config.assets.version = '1.0'
    ```

* Jei jūsų programa naudoja "/assets" maršrutą resursui, galite pakeisti turto priešdėlį, kad išvengtumėte konfliktų:

    ```ruby
    # Numatytasis priešdėlis yra '/assets'
    config.assets.prefix = '/asset-files'
    ```

#### config/environments/development.rb

* Pašalinkite RJS nustatymą `config.action_view.debug_rjs = true`.

* Jei įjungėte turto eilę, pridėkite šiuos nustatymus.

    ```ruby
    # Nespausti turto
    config.assets.compress = false

    # Išskleisti eilutes, kurios įkelia turto
    config.assets.debug = true
    ```

#### config/environments/production.rb

* Vėlgi, dauguma žemiau pateiktų pakeitimų skirti turto eilei. Apie juos galite sužinoti daugiau [Turto eilės](asset_pipeline.html) vadove.

    ```ruby
    # Suspausti JavaScript ir CSS
    config.assets.compress = true

    # Jei praleistas išankstinio sukompiliuoto turto elementas, neprisijungti prie turto eilės
    config.assets.compile = false

    # Generuoti turto URL adresams
    config.assets.digest = true

    # Numatytasis kelias yra Rails.root.join("public/assets")
    # config.assets.manifest = YOUR_PATH

    # Sukompiliuoti papildomus turto elementus (application.js, application.css ir visi ne-JS/CSS jau pridėti)
    # config.assets.precompile `= %w( admin.js admin.css )


    # Priversti visą prieigą prie programos per SSL, naudoti Strict-Transport-Security ir saugius slapukus.
    # config.force_ssl = true
    ```

#### config/environments/test.rb

```ruby
# Konfigūruoti statinio turto serverį testams su Cache-Control dėl našumo
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

#### config/initializers/wrap_parameters.rb

* Jei norite apvynioti parametrus į įdėtą maišą, pridėkite šį failą su šiais turiniais. Naujose programose tai įjungta pagal numatymą.

    ```ruby
    # Būkite tikri, kad perkraunate serverį, kai keičiate šį failą.
    # Šis failas turi nustatymus ActionController::ParamsWrapper, kuris
    # įjungtas pagal numatymą.

    # Įjungti parametro apvyniojimą JSON. Tai galite išjungti nustatydami :format į tuščią masyvą.
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters :format => [:json]
    end

    # Pagal numatymą išjungti šaknies elementą JSON.
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
    ```

#### Pašalinti :cache ir :concat parinktis turto pagalbininkų nuorodose peržiūros

* Su turto eile :cache ir :concat parinktys daugiau nenaudojamos, ištrinkite šias parinktis iš savo peržiūros.

Rails 3.1 programos kūrimas
--------------------------------

```bash
# Turite įdiegtą 'rails' RubyGem
$ rails new myapp
$ cd myapp
```

### Gemų pardavimas

Rails dabar naudoja `Gemfile` programos šakninėje direktorijoje, kad nustatytų jums reikalingas programas, kad jūsų programa pradėtų veikti. Šį `Gemfile` apdoroja [Bundler](https://github.com/carlhuda/bundler) programa, kuri tada įdiegia visus jūsų priklausomybes. Ji netgi gali įdiegti visas priklausomybes vietiniame jūsų programos aplinkoje, kad ji nebūtų priklausoma nuo sistemos programų.
Daugiau informacijos: - [bundler pagrindinis puslapis](https://bundler.io/)

### Gyvenimas ant krašto

`Bundler` ir `Gemfile` padaro jūsų „Rails“ programos užšaldymą labai paprastą naudojant naująjį skirtąjį `bundle` komandą. Jei norite susieti tiesiai iš „Git“ saugyklos, galite perduoti `--edge` vėliavą:

```bash
$ rails new myapp --edge
```

Jei turite vietinį „Rails“ saugyklos iškėlimą ir norite sukurti programą naudodami jį, galite perduoti `--dev` vėliavą:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

„Rails“ architektūriniai pokyčiai
---------------------------

### Turtų eilė

Pagrindinis pokytis „Rails“ 3.1 yra turtų eilė. Tai padaro CSS ir JavaScript pirmos klasės kodo piliečiais ir leidžia tinkamai organizuoti, įskaitant naudojimą įskiepiuose ir varikliuose.

Turtų eilė veikia naudojant [Sprockets](https://github.com/rails/sprockets) ir aprašyta [Turtų eilės](asset_pipeline.html) vadove.

### HTTP srautas

HTTP srautas yra dar vienas pokytis, kuris yra naujas „Rails“ 3.1. Tai leidžia naršyklei atsisiųsti jūsų stilių lapus ir JavaScript failus, kol serveris vis dar generuoja atsaką. Tai reikalauja „Ruby“ 1.9.2, yra pasirinktinis ir taip pat reikalauja palaikymo iš interneto serverio, tačiau populiari kombinacija „NGINX“ ir „Unicorn“ yra pasiruošusi pasinaudoti tuo.

### Numatytasis JS biblioteka dabar yra „jQuery“

„jQuery“ yra numatytoji „JavaScript“ biblioteka, kurią siunčia „Rails“ 3.1. Bet jei naudojate „Prototype“, ją lengva pakeisti.

```bash
$ rails new myapp -j prototype
```

### Tapatumo žemėlapis

Aktyvusis įrašas turi tapatumo žemėlapį „Rails“ 3.1. Tapatumo žemėlapis saugo anksčiau sukurtus įrašus ir, jei vėl prieiga prie įrašo, grąžina su juo susietą objektą. Tapatumo žemėlapis sukuriamas pagal užklausą ir išvalomas užklausos pabaigoje.

„Rails“ 3.1 tapatumo žemėlapis yra išjungtas pagal numatymą.

Railties
--------

* „jQuery“ yra naujoji numatytoji „JavaScript“ biblioteka.

* „jQuery“ ir „Prototype“ daugiau nebus tiekiami ir nuo šiol bus teikiami per „jquery-rails“ ir „prototype-rails“ paketus.

* Programos kūrėjas priima pasirinktį `-j`, kuri gali būti bet koks eilutės. Jei perduodama "foo", į `Gemfile` pridedamas paketas "foo-rails", o programos „JavaScript“ manifeste reikalingi "foo" ir "foo_ujs". Šiuo metu yra tik "prototype-rails" ir "jquery-rails", kurie perduoda tuos failus per turtų eilę.

* Generuojant programą ar įskiepį, vykdomas `bundle install`, nebent nurodyta `--skip-gemfile` arba `--skip-bundle`.

* Valdiklio ir resurso generatoriai dabar automatiškai sukuria turtų šablonus (šį veiksmą galima išjungti naudojant `--skip-assets`). Šie šablonai naudoja „CoffeeScript“ ir „Sass“, jei šios bibliotekos yra prieinamos.

* „Scaffold“ ir programos generatoriai naudoja „Ruby“ 1.9 stiliaus maišą, jei vykdoma „Ruby“ 1.9. Norint sukurti senojo stiliaus maišą, galima perduoti `--old-style-hash`.

* „Scaffold“ valdiklio generatorius sukuria JSON formatui skirtą bloką, o ne XML.

* Aktyvaus įrašo žurnalavimas nukreipiamas į STDOUT ir rodomas konsolėje.

* Pridėta `config.force_ssl` konfigūracija, kuri įkelia `Rack::SSL` tarpinį programinės įrangos sluoksnį ir priverčia visus užklausas būti naudojant HTTPS protokolą.

* Pridėta `rails plugin new` komanda, kuri generuoja „Rails“ įskiepį su „gemspec“, testais ir bandymų programėle.

* Pridėta `Rack::Etag` ir `Rack::ConditionalGet` į numatytąjį tarpinį programinės įrangos sluoksnį.

* Pridėta `Rack::Cache` į numatytąjį tarpinį programinės įrangos sluoksnį.

* Varikliai gavo didelį atnaujinimą - juos galima montuoti bet kurioje vietoje, įjungti turtus, paleisti generatorius ir t.t.

Veiksmų paketas
-----------

### Veiksmų valdiklis

* Jei negalima patikrinti CSRF žetono autentiškumo, išspausdinamas įspėjimas.

* Norint priversti naršyklę perduoti duomenis per HTTPS protokolą tik tam tikrame valdiklyje, valdiklyje galima nurodyti `force_ssl`. Norint apriboti tik tam tikrus veiksmus, galima naudoti `:only` arba `:except`.

* Jautrūs užklausos eilutės parametrai, nurodyti `config.filter_parameters`, dabar bus pašalinti iš užklausos kelio žurnale.

* URL parametrai, kurie grąžina `nil` reikšmę `to_param`, dabar bus pašalinti iš užklausos eilutės.

* Pridėtas `ActionController::ParamsWrapper`, kuris apgaubia parametrus į įdėtą maišą ir numatytuoju būdu įjungiamas JSON užklausoms naujose programose. Tai galima pritaikyti pagal poreikį `config/initializers/wrap_parameters.rb` faile.

* Pridėtas `config.action_controller.include_all_helpers`. Numatytuoju būdu `helper :all` yra atliekamas `ActionController::Base`, kuris numatytuoju būdu įtraukia visus pagalbininkus. Nustatant `include_all_helpers` į `false`, bus įtraukiamas tik `application_helper` ir pagalbininkas, atitinkantis valdiklį (pvz., `foo_helper` valdikliui `foo_controller`).

* `url_for` ir pavadinti URL pagalbininkai dabar priima `:subdomain` ir `:domain` kaip parinktis.
* Pridėtas `Base.http_basic_authenticate_with` metodas, skirtas atlikti paprastą http pagrindinės autentifikacijos veiksmą vienu klasės metodo iškvietimu.

    ```ruby
    class PostsController < ApplicationController
      USER_NAME, PASSWORD = "dhh", "secret"

      before_filter :authenticate, :except => [ :index ]

      def index
        render :text => "Visi gali mane matyti!"
      end

      def edit
        render :text => "Aš prieinamas tik jei žinote slaptažodį"
      end

      private
        def authenticate
          authenticate_or_request_with_http_basic do |user_name, password|
            user_name == USER_NAME && password == PASSWORD
          end
        end
    end
    ```

    ..dabar gali būti parašytas taip

    ```ruby
    class PostsController < ApplicationController
      http_basic_authenticate_with :name => "dhh", :password => "secret", :except => :index

      def index
        render :text => "Visi gali mane matyti!"
      end

      def edit
        render :text => "Aš prieinamas tik jei žinote slaptažodį"
      end
    end
    ```

* Pridėta srauto palaikymo funkcija, ją galite įjungti naudodami:

    ```ruby
    class PostsController < ActionController::Base
      stream
    end
    ```

    Galite apriboti ją kai kuriems veiksmams naudodami `:only` arba `:except`. Daugiau informacijos rasite dokumentacijoje [`ActionController::Streaming`](https://api.rubyonrails.org/v3.1.0/classes/ActionController/Streaming.html).

* Nukreipimo maršruto metodas dabar taip pat priima raktų rinkinį, kuris pakeis tik klausimo URL dalis, arba objektą, kuris atsako į kvietimą, leidžiant pernaudoti nukreipimus.

### Veiksmo išsiuntimas

* `config.action_dispatch.x_sendfile_header` dabar pagal nutylėjimą yra `nil`, o `config/environments/production.rb` nenurodo jokios konkretaus vertės. Tai leidžia serveriams nustatyti ją per `X-Sendfile-Type`.

* `ActionDispatch::MiddlewareStack` dabar naudoja kompoziciją vietoj paveldėjimo ir nebėra masyvas.

* Pridėtas `ActionDispatch::Request.ignore_accept_header`, skirtas ignoruoti priėmimo antraštės.

* Pridėtas `Rack::Cache` į numatytąjį rinkinį.

* Perkelta etag atsakomybė nuo `ActionDispatch::Response` į middleware rinkinį.

* Pasitikima `Rack::Session` saugyklos API, siekiant didesnės suderinamumo visame Ruby pasaulyje. Tai yra atgalinės suderinamumo versija, nes `Rack::Session` tikisi, kad `#get_session` priims keturis argumentus ir reikalauja `#destroy_session` vietoj paprasto `#destroy`.

* Šablonų paieška dabar ieško aukščiau paveldėjimo grandinėje.

### Veiksmo rodinys

* Pridėta `:authenticity_token` parinktis `form_tag` funkcijai, skirtai pasirinktiniam tvarkymui arba praleidžiant žetoną perduodant `:authenticity_token => false`.

* Sukurtas `ActionView::Renderer` ir nurodyta `ActionView::Context` API.

* Vietoj `SafeBuffer` mutacijos yra draudžiama Rails 3.1.

* Pridėtas HTML5 `button_tag` pagalbininkas.

* `file_field` automatiškai prideda `:multipart => true` prie apgaubiančiojo formos.

* Pridėtas patogus idiomas, skirtas generuoti HTML5 `data-*` atributus žymėjimo pagalbininkuose iš `:data` parinkčių rinkinio:

    ```ruby
    tag("div", :data => {:name => 'Stephen', :city_state => %w(Chicago IL)})
    # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
    ```

Raktai yra su brūkšneliais. Reikšmės yra JSON koduotos, išskyrus eilutes ir simbolius.

* `csrf_meta_tag` pervadintas į `csrf_meta_tags` ir yra sinonimas `csrf_meta_tag` atgaliniam suderinamumui.

* Senoji šablonų tvarkyklės API yra pasenusi, o naujoji API tiesiog reikalauja, kad šablonų tvarkyklė atsakytų į kvietimą.

* rhtml ir rxml galiausiai pašalinti kaip šablonų tvarkyklės.

* `config.action_view.cache_template_loading` grąžinamas atgal, tai leidžia nuspręsti, ar šablonai turėtų būti talpinami talpykloje ar ne.

* Pateikimo formos pagalbininkas daugiau nebesukuria id "object_name_id".

* Leidžia `FormHelper#form_for` nurodyti `:method` kaip tiesioginę parinktį, o ne per `:html` raktų rinkinį. `form_for(@post, remote: true, method: :delete)` vietoj `form_for(@post, remote: true, html: { method: :delete })`.

* Pateiktas `JavaScriptHelper#j()` kaip sinonimas `JavaScriptHelper#escape_javascript()`. Tai pakeičia `Object#j()` metodą, kurį JSON gem prideda šablonuose naudojant JavaScriptHelper.

* Leidžia AM/PM formatą laiko pasirinkimo laukeliuose.

* `auto_link` pašalintas iš Rails ir išskirtas į [rails_autolink gem](https://github.com/tenderlove/rails_autolink)

Aktyvus įrašas
-------------

* Pridėtas klasės metodas `pluralize_table_names`, skirtas vienų modelių lentelių pavadinimų vienaskaitai/daugiskaitai. Anksčiau tai galėjo būti nustatyta tik globaliai visiems modeliams per `ActiveRecord::Base.pluralize_table_names`.

    ```ruby
    class User < ActiveRecord::Base
      self.pluralize_table_names = false
    end
    ```

* Pridėtas atributų nustatymas vienaskaitos asociacijoms. Blokas bus iškviestas po to, kai bus sukurta instancija.

    ```ruby
    class User < ActiveRecord::Base
      has_one :account
    end

    user.build_account{ |a| a.credit_limit = 100.0 }
    ```

* Pridėtas `ActiveRecord::Base.attribute_names`, skirtas grąžinti atributų pavadinimų sąrašą. Jei modelis yra abstraktus arba lentelė neegzistuoja, tai grąžins tuščią masyvą.

* CSV fiktyvai yra pasenusi ir palaikymas bus pašalintas iš Rails 3.2.0.

* `ActiveRecord#new`, `ActiveRecord#create` ir `ActiveRecord#update_attributes` visi priima antrąjį raktų rinkinį kaip parinktį, leidžiantį nurodyti, kurį vaidmenį naudoti priskiriant atributus. Tai yra pagrįsta Active Model naujomis masinio priskyrimo galimybėmis:
```ruby
class Post < ActiveRecord::Base
  attr_accessible :title
  attr_accessible :title, :published_at, :as => :admin
end

Post.new(params[:post], :as => :admin)
```

* `default_scope` dabar gali priimti bloką, lambda arba bet kokį kitą objektą, kuris atsako į skambinimą, kad būtų galima atidėti vertinimą.

* Numatytieji apribojimai dabar vertinami vėliausiu galimu momentu, kad būtų išvengta problemų, kai būtų sukurti apribojimai, kurie neaiškiai turėtų numatytąjį apribojimą, kurį būtų neįmanoma pašalinti naudojant Model.unscoped.

* PostgreSQL adapteris palaiko tik PostgreSQL 8.2 ir naujesnes versijas.

* `ConnectionManagement` middleware pakeistas, kad po "rack body" išvalytų ryšių pool'ą.

* Pridėtas `update_column` metodas Active Record. Šis naujas metodas atnaujina nurodytą atributą objekte, praleidžiant validacijas ir atgalinį skambinimą. Rekomenduojama naudoti `update_attributes` arba `update_attribute`, nebent esate tikri, kad nenorite vykdyti jokio skambinimo, įskaitant `updated_at` stulpelio modifikaciją. Jį negalima skambinti naujiems įrašams.

* Asociacijos su `:through` parinktimi dabar gali naudoti bet kurią asociaciją kaip per arba šaltinio asociaciją, įskaitant kitas asociacijas, kurios turi `:through` parinktį ir `has_and_belongs_to_many` asociacijas.

* Dabartinės duomenų bazės ryšio konfigūracija dabar pasiekiamas per `ActiveRecord::Base.connection_config`.

* limitai ir offset'ai yra pašalinami iš COUNT užklausų, nebent abu yra pateikti.

```ruby
People.limit(1).count           # => 'SELECT COUNT(*) FROM people'
People.offset(1).count          # => 'SELECT COUNT(*) FROM people'
People.limit(1).offset(1).count # => 'SELECT COUNT(*) FROM people LIMIT 1 OFFSET 1'
```

* `ActiveRecord::Associations::AssociationProxy` buvo padalintas. Dabar yra `Association` klasė (ir jos paveldėtos klasės), kurios atsakingos už asociacijų veikimą, ir atskiras, plonas apvalkalas, vadinamas `CollectionProxy`, kuris perduoda kolekcijos asociacijas. Tai užkerta kelią vardų erdvei, atskiria problemas ir leis tolesnius pertvarkymus.

* Viengubos asociacijos (`has_one`, `belongs_to`) nebėra apvalkalo ir tiesiog grąžina susijusį įrašą arba `nil`. Tai reiškia, kad neturėtumėte naudoti nesudokumentuotų metodų, pvz., `bob.mother.create` - naudokite `bob.create_mother` vietoj to.

* Palaikoma `:dependent` parinktis `has_many :through` asociacijose. Istorinių ir praktinių priežasčių dėka `:delete_all` yra numatytasis trynimo strategijos variantas, kurį naudoja `association.delete(*records)`, nepaisant to, kad numatytasis variantas yra `:nullify` paprastoms has_many asociacijoms. Taip pat tai veikia tik tuo atveju, jei šaltinio atspindys yra priklauso. Kitais atvejais turėtumėte tiesiogiai modifikuoti per asociaciją.

* `association.destroy` elgsena `has_and_belongs_to_many` ir `has_many :through` asociacijose pasikeitė. Nuo šiol 'destroy' arba 'delete' asociacijoje reiškia 'atleisti nuo nuorodos', o ne (būtinai) 'atleisti susijusius įrašus'.

* Anksčiau `has_and_belongs_to_many.destroy(*records)` sunaikindavo pačius įrašus. Ji nebeištrina jokių įrašų jungiamajame lentele. Dabar ji ištrina įrašus jungiamajame lentele.

* Anksčiau `has_many_through.destroy(*records)` sunaikindavo pačius įrašus ir įrašus jungiamajame lentele. [Pastaba: Tai ne visada buvo taip; ankstesnės Rails versijos tik ištrindavo pačius įrašus.] Dabar ji sunaikina tik įrašus jungiamajame lentele.

* Atkreipkite dėmesį, kad šis pakeitimas yra iš dalies nesuderinamas atgal, bet deja, nėra būdo jį 'paseninti' prieš jį pakeičiant. Pakeitimas daromas siekiant turėti nuoseklumą, kas reiškia 'destroy' arba 'delete' prasme skirtingose asociacijų tipuose. Jei norite sunaikinti pačius įrašus, galite tai padaryti `records.association.each(&:destroy)`.

* Pridėta `:bulk => true` parinktis `change_table`, kad visi schemos pakeitimai, apibrėžti naudojant vieną ALTER teiginį, būtų vykdomi.

```ruby
change_table(:users, :bulk => true) do |t|
  t.string :company_name
  t.change :birthdate, :datetime
end
```

* Pašalinta palaikymo galimybė pasiekti atributus `has_and_belongs_to_many` jungiamajame lentele. Turėtų būti naudojama `has_many :through`.

* Pridėtas `create_association!` metodas `has_one` ir `belongs_to` asociacijoms.

* Migracijos dabar yra atvirkštinės, tai reiškia, kad Rails nustatys, kaip atvirkščiai vykdyti jūsų migracijas. Norėdami naudoti atvirkštinės migracijas, tiesiog apibrėžkite `change` metodą.

```ruby
class MyMigration < ActiveRecord::Migration
  def change
    create_table(:horses) do |t|
      t.column :content, :text
      t.column :remind_at, :datetime
    end
  end
end
```

* Kai kurie dalykai negali būti automatiškai atvirkščiai jums. Jei žinote, kaip atvirkščiai vykdyti tuos dalykus, turėtumėte apibrėžti `up` ir `down` savo migracijoje. Jei apibrėžiate kažką change, kas negali būti atvirkščiai vykdoma, kai einama žemyn, bus iškelta `IrreversibleMigration` išimtis.

* Migracijos dabar naudoja objekto metodus, o ne klasės metodus:
```ruby
class FooMigration < ActiveRecord::Migration
  def up # Ne self.up
    # ...
  end
end
```

* Migracijos failai, sugeneruoti iš modelio ir konstruktyvios migracijos generatorių (pvz., add_name_to_users), naudoja atvirkštinės migracijos `change` metodą vietoj įprastų `up` ir `down` metodų.

* Panaikinta palaikymo galimybė interpoliuoti eilutės SQL sąlygas asociacijose. Vietoj to, turėtų būti naudojamas proc.

```ruby
has_many :things, :conditions => 'foo = #{bar}'          # anksčiau
has_many :things, :conditions => proc { "foo = #{bar}" } # dabar
```

Proce `self` yra objektas, kuris yra asociacijos savininkas, nebent kraunant asociaciją, tada `self` yra klasė, kurioje yra asociacija.

Proce galite naudoti bet kokias "normalias" sąlygas, todėl veiks ir šis variantas:

```ruby
has_many :things, :conditions => proc { ["foo = ?", bar] }
```

* Anksčiau `:insert_sql` ir `:delete_sql` `has_and_belongs_to_many` asociacijoje leido iškviesti 'record', kad gautumėte įterpiamą arba ištrinamą įrašą. Dabar tai perduodama kaip argumentas proc.

* Pridėtas `ActiveRecord::Base#has_secure_password` (per `ActiveModel::SecurePassword`), kad būtų galima paprastai naudoti slaptažodžius su BCrypt šifravimu ir druskos pridėjimu.

```ruby
# Schema: User(name:string, password_digest:string, password_salt:string)
class User < ActiveRecord::Base
  has_secure_password
end
```

* Sugeneruojant modelį pagal nutylėjimą pridedamas `add_index` `belongs_to` arba `references` stulpeliams.

* Nustatant `belongs_to` objekto id, atnaujinamas nuorodos į objektą.

* `ActiveRecord::Base#dup` ir `ActiveRecord::Base#clone` semantika pakeista, kad būtų panašesnė į įprastą Ruby `dup` ir `clone` semantiką.

* Iškvietus `ActiveRecord::Base#clone`, gausite paviršutinišką įrašo kopiją, įskaitant užšaldytą būseną. Nebus iškviečiami jokie atgalinio iškvietimo metodai.

* Iškvietus `ActiveRecord::Base#dup`, bus sukurtas įrašo dublikatas, įskaitant po inicializavimo kėlimo įvykdytus metodų iškvietimus. Užšaldyta būsena nebus nukopijuota, ir visos asociacijos bus išvalytos. Dublikatas grąžins `true` `new_record?` metode, turės `nil` id lauką ir bus išsaugojamas.

* Užklausos talpykla dabar veikia su paruoštomis užklausomis. Programose nereikia daryti jokių pakeitimų.

Active Model
------------

* `attr_accessible` priima `:as` parinktį, skirtą nurodyti vaidmenį.

* `InclusionValidator`, `ExclusionValidator` ir `FormatValidator` dabar priima parinktį, kuri gali būti proc, lambda arba bet kas, kas gali būti iškviestas. Ši parinktis bus iškviesta su dabartiniu įrašu kaip argumentu ir grąžins objektą, kuris gali būti iškviestas `include?` metodu `InclusionValidator` ir `ExclusionValidator` atveju, ir grąžins reguliariąją išraišką `FormatValidator` atveju.

* Pridėtas `ActiveModel::SecurePassword`, kad būtų galima paprastai naudoti slaptažodžius su BCrypt šifravimu ir druskos pridėjimu.

* `ActiveModel::AttributeMethods` leidžia apibrėžti atributus pagal poreikį.

* Pridėta palaikymo galimybė selektyviai įjungti ir išjungti stebėtojus.

* Nebepalaikoma alternatyvi `I18n` vardų erdvės paieška.

Active Resource
---------------

* Numatytasis formatas visoms užklausoms pakeistas į JSON. Jei norite toliau naudoti XML, turėsite nustatyti `self.format = :xml` klasėje. Pavyzdžiui,

```ruby
class User < ActiveResource::Base
  self.format = :xml
end
```

Active Support
--------------

* `ActiveSupport::Dependencies` dabar iškelia `NameError`, jei randa esamą konstantą `load_missing_constant` metode.

* Pridėtas naujas pranešimų metodas `Kernel#quietly`, kuris nutildys tiek `STDOUT`, tiek `STDERR`.

* Pridėtas `String#inquiry` kaip patogumo metodas, skirtas paversti eilutę į `StringInquirer` objektą.

* Pridėtas `Object#in?` metodas, skirtas patikrinti, ar objektas yra įtrauktas į kitą objektą.

* `LocalCache` strategija dabar yra tikras tarpinės programinės įrangos klasė, o ne anoniminė klasė.

* Įvesta `ActiveSupport::Dependencies::ClassCache` klasė, skirta laikyti nuorodas į pakartotinai įkeliamas klases.

* `ActiveSupport::Dependencies::Reference` buvo pertvarkytas, kad būtų tiesiogiai naudojama naujoji `ClassCache`.

* Atgalinio suderinamumo tikslais `Range#cover?` yra sinonimas `Range#include?` Ruby 1.8.

* Pridėti `weeks_ago` ir `prev_week` metodai `Date/DateTime/Time` klasėms.

* Pridėtas `before_remove_const` atgalinio iškvietimo metodas `ActiveSupport::Dependencies.remove_unloadable_constants!`.

Nebenaudojami:

* `ActiveSupport::SecureRandom` yra nebenaudojamas, naudojamas `SecureRandom` iš Ruby standartinės bibliotekos.

Autoriai
-------

Peržiūrėkite [visų Rails prisidėjusių asmenų sąrašą](https://contributors.rubyonrails.org/), kurie daug valandų skyrė Rails, stabiliam ir patikimam karkasui, kuris jis yra. Jie visi nusipelno pagyrimo.

Rails 3.1 išleidimo pastabas sudarė [Vijay Dev](https://github.com/vijaydev)
