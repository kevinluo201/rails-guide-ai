**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 30550ed8fa3c0983f3d99a0e91571a98
Ruby on Rails 3.2 Išleidimo pastabos
===============================

Svarbiausi dalykai Rails 3.2:

* Greitesnis vystymo režimas
* Naujas maršrutizavimo variklis
* Automatinis užklausų aiškinimas
* Pažymėtas žurnalo įrašymas

Šiose išleidimo pastabose aptariami tik pagrindiniai pokyčiai. Norėdami sužinoti apie įvairius klaidų taisymus ir pokyčius, kreipkitės į pokyčių žurnalus arba peržiūrėkite [įsipareigojimų sąrašą](https://github.com/rails/rails/commits/3-2-stable) pagrindiniame „Rails“ saugykloje „GitHub“.

--------------------------------------------------------------------------------

Atnaujinimas iki Rails 3.2
----------------------

Jei atnaujinote esamą programą, prieš pradedant gerai būtų turėti geras testavimo padengimo. Taip pat pirmiausia atnaujinkite iki Rails 3.1, jei dar to nepadaryte, ir įsitikinkite, kad jūsų programa vis dar veikia kaip tikėtasi, prieš bandydami atnaujinti iki Rails 3.2. Tada atkreipkite dėmesį į šiuos pokyčius:

### Rails 3.2 reikalauja bent Ruby 1.8.7

Rails 3.2 reikalauja Ruby 1.8.7 arba naujesnės versijos. Visų ankstesnių Ruby versijų palaikymas oficialiai nutrauktas ir turėtumėte atnaujinti kuo greičiau. Rails 3.2 taip pat yra suderinamas su Ruby 1.9.2.

PATARIMAS: Atkreipkite dėmesį, kad Ruby 1.8.7 p248 ir p249 turi maršrutizavimo klaidas, kurios sukelia „Rails“ sutrikimus. „Ruby Enterprise Edition“ šias klaidas turi ištaisytas nuo 1.8.7-2010.02 išleidimo. Kalbant apie 1.9 versiją, Ruby 1.9.1 negalima naudoti, nes ji tiesiog iškrenta, todėl jei norite naudoti 1.9.x, pereikite prie 1.9.2 arba 1.9.3, kad plauktumėte sklandžiai.

### Kas atnaujinti savo programose

* Atnaujinkite savo `Gemfile` priklausomybę nuo
    * `rails = 3.2.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

* Rails 3.2 pasenina `vendor/plugins` ir Rails 4.0 jas visiškai pašalins. Galite pradėti keisti šiuos įskiepius išskleisdami juos kaip juvelyrinius akmenis ir pridedami juos į savo `Gemfile`. Jei nuspręsite nekeisti jų į juvelyrinius akmenis, galite juos perkelti, pavyzdžiui, į `lib/my_plugin/*` ir pridėti tinkamą pradinį nustatymą `config/initializers/my_plugin.rb`.

* Yra keletas naujų konfigūracijos pakeitimų, kuriuos norėtumėte pridėti `config/environments/development.rb`:

    ```ruby
    # Išimtis dėl masinio priskyrimo apsaugos „Active Record“ modeliams
    config.active_record.mass_assignment_sanitizer = :strict

    # Įrašykite užklausos planą užklausoms, kurios užtrunka ilgiau nei tai (veikia
    # su „SQLite“, „MySQL“ ir „PostgreSQL“)
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    `mass_assignment_sanitizer` konfigūraciją taip pat reikia pridėti `config/environments/test.rb`:

    ```ruby
    # Išimtis dėl masinio priskyrimo apsaugos „Active Record“ modeliams
    config.active_record.mass_assignment_sanitizer = :strict
    ```

### Kas atnaujinti savo varikliuose

Pakeiskite kodą po komentaro `script/rails` šiuo turiniu:

```ruby
ENGINE_ROOT = File.expand_path('../..', __FILE__)
ENGINE_PATH = File.expand_path('../../lib/your_engine_name/engine', __FILE__)

require "rails/all"
require "rails/engine/commands"
```

Rails 3.2 programos kūrimas
--------------------------------

```bash
# Turite įdiegtą „rails“ RubyGem
$ rails new myapp
$ cd myapp
```

### Gems prekyba

Rails dabar naudoja `Gemfile` programos šakninėje direktorijoje, kad nustatytų jums reikalingus juvelyrinius akmenis, kad jūsų programa pradėtų veikti. Šį `Gemfile` apdoroja [Bundler](https://github.com/carlhuda/bundler) juvelyrinis akmuo, kuris tada įdiegia visus jūsų priklausomybes. Jis netgi gali įdiegti visas priklausomybes vietiniuose jūsų programos juvelyriniuose akmenyse, kad ji nebūtų priklausoma nuo sistemos juvelyrinių akmenų.

Daugiau informacijos: [Bundler pagrindinis puslapis](https://bundler.io/)

### Gyvenimas ant krašto

`Bundler` ir `Gemfile` leidžia lengvai užšaldyti jūsų „Rails“ programą su nauju skirtu `bundle` komandos. Jei norite susieti tiesiai iš „Git“ saugyklos, galite perduoti `--edge` vėliavą:

```bash
$ rails new myapp --edge
```

Jei turite vietinę „Rails“ saugyklą ir norite sukurti programą naudodami ją, galite perduoti `--dev` vėliavą:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

Pagrindinės funkcijos
--------------

### Greitesnis vystymo režimas ir maršrutizavimas

Rails 3.2 turi vystymo režimą, kuris pastebimai greitesnis. Įkvėptas [Active Reload](https://github.com/paneq/active_reload), „Rails“ perkrauna klases tik tada, kai failai iš tikrųjų keičiasi. Naudojant didesnes programas, nauda yra dramatiška. Maršrutų atpažinimas taip pat tapo žymiai greitesnis dėka naujojo [Journey](https://github.com/rails/journey) variklio.

### Automatinis užklausų aiškinimas

Rails 3.2 turi puikią funkciją, kuri paaiškina užklausas, kurias generuoja Arel, apibrėžiant „explain“ metodą „ActiveRecord::Relation“. Pavyzdžiui, galite paleisti kažką panašaus į `puts Person.active.limit(5).explain` ir paaiškinti užklausą, kurią Arel sukuria. Tai leidžia patikrinti tinkamus indeksus ir tolesnius optimizavimus.

Užklausos, kurios trunka ilgiau nei pusę sekundės, *automatiškai* paaiškinamos vystymo režime. Žinoma, šis slenkstis gali būti pakeistas.

### Pažymėtas žurnalo įrašymas
Vykstant daugiausiai naudotojų, daugiausiai paskyrų taikomai programai, labai padeda galimybė filtruoti žurnalą pagal tai, kas ką padarė. TaggedLogging Active Support padeda tai padaryti, pažymėdama žurnalo eilutes su subdomenais, užklausos ID ir viskuo, kas padeda derinti tokių programų derinimą.

Dokumentacija
-------------

Nuo 3.2 versijos „Rails“ vadovai yra prieinami „Kindle“ ir nemokamoms „Kindle Reading“ programoms „iPad“, „iPhone“, „Mac“, „Android“ ir kt.

Railties
--------

* Pagreitinkite plėtrą tik tada, kai priklausomybės failai pasikeitė. Tai galima išjungti nustatant `config.reload_classes_only_on_change` į `false`.

* Naujos programos konfigūracijos failuose aplinkose gaukite vėliavą `config.active_record.auto_explain_threshold_in_seconds`. Su reikšme `0.5` `development.rb` ir užkomentuota `production.rb`. Nėra paminėta `test.rb`.

* Pridėtas `config.exceptions_app`, nustatantis išimčių programa, kurią kviečia „ShowException“ tarpinė, kai įvyksta išimtis. Numatytasis variantas yra `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

* Pridėta „DebugExceptions“ tarpinė, kurioje yra iš „ShowExceptions“ tarpinės išskirtos funkcijos.

* Rodykite prijungtų variklių maršrutus „rake routes“.

* Leiskite pakeisti railties įkėlimo tvarką su `config.railties_order`, pavyzdžiui:

    ```ruby
    config.railties_order = [Blog::Engine, :main_app, :all]
    ```

* „Scaffold“ API užklausoms be turinio grąžina 204 „No Content“. Tai leidžia „scaffold“ iškart veikti su „jQuery“.

* Atnaujinkite `Rails::Rack::Logger` tarpinę, kad būtų taikomi bet kokie žymės, nustatytos `config.log_tags`, `ActiveSupport::TaggedLogging`. Tai leidžia lengvai pažymėti žurnalo eilutes su derinimo informacija, pvz., subdomenu ir užklausos ID - abiem labai naudinga derinant daugiausiai naudotojų gamybos programas.

* Numatytosios parinktys „rails new“ gali būti nustatytos „~/.railsrc“. Galite nurodyti papildomus komandų eilutės argumentus, kurie bus naudojami kiekvieną kartą, kai vykdomas „rails new“, `.railsrc` konfigūracijos faile savo namų kataloge.

* Pridėtas aliasas „d“ „destroy“. Tai taip pat veikia varikliams.

* Atributai „scaffold“ ir modelio generatoriuose pagal nutylėjimą yra eilutė. Tai leidžia štai ką: `bin/rails g scaffold Post title body:text author`

* Leiskite „scaffold/model/migration“ generatoriams priimti „index“ ir „uniq“ modifikatorius. Pavyzdžiui,

    ```bash
    bin/rails g scaffold Post title:string:index author:uniq price:decimal{7,2}
    ```

    sukurs indeksus „title“ ir „author“, o pastarasis bus unikalus indeksas. Kai kurie tipai, pvz., skaičiai, priima pasirinktinius parametrus. Pavyzdžiui, „price“ bus skaitinė stulpelis, kurio tikslumas ir mastelis nustatyti atitinkamai 7 ir 2.

* „Turn gem“ pašalintas iš numatytosios „Gemfile“.

* Pašalintas senas įskiepio generatorius „rails generate plugin“, naudojant „rails plugin new“ komandą.

* Pašalintas senas „config.paths.app.controller“ API, naudojant „config.paths["app/controller"]“.

### Pasenusios funkcijos

* „Rails::Plugin“ pasenusi ir bus pašalinta „Rails 4.0“. Vietoje įskiepių pridėkite į „vendor/plugins“ naudokite juostas arba „bundler“ su kelio arba „git“ priklausomybėmis.

Veiksmų siuntėjas
-------------

* Atnaujinta „mail“ versija iki 2.4.0.

* Pašalinta sena „Action Mailer“ API, kuris buvo pasenusi nuo „Rails 3.0“.

Veiksmų paketas
-----------

### Veiksmų valdiklis

* Padarykite „ActiveSupport::Benchmarkable“ numatytąjį modulį „ActionController::Base“, kad „#benchmark“ metodas vėl būtų prieinamas valdiklio kontekste, kaip buvo anksčiau.

* Pridėta „:gzip“ parinktis „caches_page“. Numatytąją parinktį galima konfigūruoti globaliai naudojant „page_cache_compression“.

* „Rails“ dabar naudos jūsų numatytąjį maketą (pvz., „layouts/application“), kai nurodote maketą su „:only“ ir „:except“ sąlygomis, ir šios sąlygos nepavyksta.

    ```ruby
    class CarsController
      layout 'single_car', :only => :show
    end
    ```

    „Rails“ naudos „layouts/single_car“, kai užklausa ateina į „:show“ veiksmą, ir naudos „layouts/application“ (arba „layouts/cars“, jei egzistuoja), kai užklausa ateina į kitus veiksmus.

* „form_for“ pakeistas naudoti „#{action}_#{as}“ kaip CSS klasę ir ID, jei pateikta „:as“ parinktis. Ankstesnės versijos naudojo „#{as}_#{action}“.

* „ActionController::ParamsWrapper“ ant „Active Record“ modelių dabar apgaubia tik „attr_accessible“ atributus, jei jie buvo nustatyti. Jei ne, apgaubiami tik atributai, grąžinami klasės metodo „attribute_names“. Tai ištaisys apgaubimo įdėjimą į „attr_accessible“ įdėjus juos.

* Žurnalas „Filter chain halted as CALLBACKNAME rendered or redirected“ kiekvieną kartą, kai prieš tai vykdomas iškvietimas sustabdo.

* „ActionDispatch::ShowExceptions“ pertvarkytas. Valdiklis atsakingas už išimtis. Galima perrašyti „show_detailed_exceptions?“ valdikliuose, kad būtų nurodytos užklausos, kuriose turėtų būti pateikta derinimo informacija apie klaidas.

* Atsakikliai dabar grąžina 204 „No Content“ užklausoms be atsakymo kūno (kaip naujame „scaffold“).

* „ActionController::TestCase“ slapukai pertvarkyti. Testų atvejams slapukus priskirti dabar turėtų naudoti „cookies[]“
```ruby
cookies[:email] = 'user@example.com'
get :index
assert_equal 'user@example.com', cookies[:email]
```

Norint išvalyti slapukus, naudokite `clear`.

```ruby
cookies.clear
get :index
assert_nil cookies[:email]
```

Dabar mes nebesirašome HTTP_COOKIE ir slapukų dėžutė išlieka tarp užklausų, todėl jei norite manipuliuoti aplinka savo testui, tai turite padaryti prieš sukurdami slapukų dėžutę.

* `send_file` dabar atspėja MIME tipo išplėtimą, jei `:type` nenurodytas.

* Pridėti MIME tipo įrašai PDF, ZIP ir kitoms formatams.

* Leidžiama `fresh_when/stale?` priimti įrašą vietoj parinkčių maišos.

* Pakeistas įspėjimo lygis dėl trūkstamo CSRF žetono iš `:debug` į `:warn`.

* Turtiniai elementai turėtų pagal nutylėjimą naudoti užklausos protokolą arba pagal nutylėjimą būti santykiniai, jei nėra užklausos.

#### Pasenusios funkcijos

* Pasenusi numatoma išdėstymo paieška kontroleriuose, kurių tėvas turėjo aiškiai nustatytą išdėstymą:

```ruby
class ApplicationController
  layout "application"
end

class PostsController < ApplicationController
end
```

Pavyzdyje aukščiau, `PostsController` daugiau neautomatiškai ieškos išdėstymo. Jei jums reikia šios funkcionalumo, galite pašalinti `layout "application"` iš `ApplicationController` arba aiškiai nustatyti jį kaip `nil` `PostsController`.

* Pasenusi `ActionController::UnknownAction` vietoj `AbstractController::ActionNotFound`.

* Pasenusi `ActionController::DoubleRenderError` vietoj `AbstractController::DoubleRenderError`.

* Pasenusi `method_missing` vietoj `action_missing` dėl trūkstamų veiksmų.

* Pasenusi `ActionController#rescue_action`, `ActionController#initialize_template_class` ir `ActionController#assign_shortcuts`.

### Veiksmo išsiuntimas

* Pridėta `config.action_dispatch.default_charset` konfigūruoti numatytąjį koduotę `ActionDispatch::Response`.

* Pridėtas `ActionDispatch::RequestId` tarpinė programinė įranga, kuri padaro unikalų X-Request-Id antraštę prieinamą atsakymui ir įgalina `ActionDispatch::Request#uuid` metodą. Tai lengva sekimo užklausoms nuo pradžios iki pabaigos ir atskirų užklausų identifikavimui mišriose žurnalo rinkiniuose, pvz., Syslog.

* `ShowExceptions` tarpinė programinė įranga dabar priima išimčių programą, kuri atsakinga už išimtį, kai programa nepavyksta. Programa yra kviečiama su išimties kopija `env["action_dispatch.exception"]` ir su `PATH_INFO` pertvarkytu į statuso kodą.

* Leidžiama konfigūruoti gelbėjimo atsakus per railtie, kaip `config.action_dispatch.rescue_responses`.

#### Pasenusios funkcijos

* Pasenusi galimybė nustatyti numatytąją koduotę kontrolerio lygyje, naudokite naują `config.action_dispatch.default_charset` vietoj.

### Veiksmo rodinys

* Pridėta `button_tag` parametrų palaikymas `ActionView::Helpers::FormBuilder`. Šis parametrų palaikymas imituoja numatytąjį `submit_tag` elgesį.

```erb
<%= form_for @post do |f| %>
  <%= f.button %>
<% end %>
```

* Datos pagalbininkai priima naują parametrą `:use_two_digit_numbers => true`, kuris atvaizduoja mėnesių ir dienų pasirinkimo laukus su pradine nuliu be keičiant atitinkamus reikšmes. Pavyzdžiui, tai naudinga rodyti ISO 8601 stiliaus datas, pvz., '2011-08-01'.

* Galite nurodyti formos vardų erdvę, kad užtikrintumėte formos elementų id atributų unikalumą. Sugeneruotame HTML id prieš žymeklį bus pridėtas pabraukimas.

```erb
<%= form_for(@offer, :namespace => 'namespace') do |f| %>
  <%= f.label :version, 'Version' %>:
  <%= f.text_field :version %>
<% end %>
```

* `select_year` parinkčių skaičių riba apribota iki 1000. Nurodykite `:max_years_allowed` parinktį, kad nustatytumėte savo ribą.

* `content_tag_for` ir `div_for` dabar gali priimti įrašų kolekciją. Taip pat jie perduos įrašą kaip pirmąjį argumentą, jei jūs nustatysite priėmimo argumentą savo bloke. Taigi, vietoj to, kad tai padarytumėte:

```ruby
@items.each do |item|
  content_tag_for(:li, item) do
    Title: <%= item.title %>
  end
end
```

Galite tai padaryti:

```ruby
content_tag_for(:li, @items) do |item|
  Title: <%= item.title %>
end
```

* Pridėtas `font_path` pagalbinis metodas, kuris apskaičiuoja šrifto turinio kelią `public/fonts`.

#### Pasenusios funkcijos

* Perduoti formatą arba tvarkyklę į `render :template` ir panašius, pvz., `render :template => "foo.html.erb"`, yra pasenusi. Vietoj to, galite nurodyti `:handlers` ir `:formats` tiesiogiai kaip parinktis: `render :template => "foo", :formats => [:html, :js], :handlers => :erb`.

### Sprockets

* Pridėta konfigūracijos parinktis `config.assets.logger`, skirta valdyti Sprockets žurnalavimą. Nustatykite ją kaip `false`, jei norite išjungti žurnalavimą, ir kaip `nil`, jei norite naudoti numatytąjį `Rails.logger`.

Aktyvus įrašas
--------------

* Loginių stulpelių su 'on' ir 'ON' reikšmėmis tipo keitimas į `true`.

* Kai `timestamps` metodas sukuria `created_at` ir `updated_at` stulpelius, pagal nutylėjimą jie tampa neprivalomais.

* Įgyvendintas `ActiveRecord::Relation#explain`.

* Įgyvendintas `ActiveRecord::Base.silence_auto_explain`, kuris leidžia vartotojui selektyviai išjungti automatinį EXPLAIN bloke.

* Įgyvendintas automatinis EXPLAIN žurnalavimas lėtoms užklausoms. Naujas konfigūracijos parametras `config.active_record.auto_explain_threshold_in_seconds` nustato, kas laikoma lėta užklausa. Nustatant jį kaip `nil`, ši funkcija išjungiama. Numatytieji parametrai yra 0.5 vystymo režime ir `nil` testo ir produkcijos režimuose. Rails 3.2 šią funkciją palaiko SQLite, MySQL (mysql2 adapteris) ir PostgreSQL.
* Pridėtas `ActiveRecord::Base.store` metodas, skirtas deklaruoti paprastus vieno stulpelio raktų/vertės saugyklas.

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [ :color, :homepage ]
    end

    u = User.new(color: 'black', homepage: '37signals.com')
    u.color                          # Prieigos metodas saugomai atributui
    u.settings[:country] = 'Denmark' # Bet koks atributas, net jei nenurodytas prieigos metodu
    ```

* Pridėta galimybė vykdyti migracijas tik tam tikrame kontekste, tai leidžia vykdyti migracijas tik iš vieno modulio (pavyzdžiui, atšaukti pakeitimus iš modulio, kuris turi būti pašalintas).

    ```
    rake db:migrate SCOPE=blog
    ```

* Migracijos, nukopijuotos iš modulių, dabar turi modulio pavadinimą, pavyzdžiui `01_create_posts.blog.rb`.

* Įgyvendintas `ActiveRecord::Relation#pluck` metodas, kuris grąžina masyvą su stulpelių reikšmėmis tiesiogiai iš pagrindinės lentelės. Tai taip pat veikia su serializuotais atributais.

    ```ruby
    Client.where(:active => true).pluck(:id)
    # SELECT id from clients where active = 1
    ```

* Sugeneruoti asociacijų metodai yra sukurti atskirame modulyje, kad būtų galima juos perrašyti ir sudėti. Jei klasės pavadinimas yra MyModel, tai modulis vadinamas `MyModel::GeneratedFeatureMethods`. Jis įtraukiamas į modelio klasę tuoj po `generated_attributes_methods` modulio, kuris yra apibrėžtas Active Model, todėl asociacijų metodai perrašo atributų metodus su tuo pačiu pavadinimu.

* Pridėtas `ActiveRecord::Relation#uniq` metodas, skirtas generuoti unikalius užklausas.

    ```ruby
    Client.select('DISTINCT name')
    ```

    ..gali būti parašytas taip:

    ```ruby
    Client.select(:name).uniq
    ```

    Tai taip pat leidžia atšaukti unikalumą užklausoje:

    ```ruby
    Client.select(:name).uniq.uniq(false)
    ```

* Palaikomas indekso rūšiavimo tvarka SQLite, MySQL ir PostgreSQL adapteriuose.

* Leidžiama `:class_name` parinktis asociacijoms priimti simbolį, be eilutės. Tai padaryta siekiant išvengti pradedančiųjų painiavos ir siekiant išlaikyti nuoseklumą, nes kitos parinktys, pvz., `:foreign_key`, jau leidžia simbolį arba eilutę.

    ```ruby
    has_many :clients, :class_name => :Client # Atkreipkite dėmesį, kad simbolis turi būti didžiosiomis raidėmis
    ```

* Vystymo režime `db:drop` taip pat ištrina testų duomenų bazę, kad būtų simetriška su `db:create`.

* Mažinant unikalumo tikrinimą, nenaudojamas LOWER MySQL, jei stulpelis jau naudoja nesvarbu didžiąsias ir mažąsias raides.

* Transakcijos fiksuoti įrenginių sąrašą. Galite testuoti modelius skirtingose duomenų bazės jungtyse, nes išjungti transakcijų fiksuotus įrenginius.

* Pridėti `first_or_create`, `first_or_create!`, `first_or_initialize` metodai Active Record. Tai geresnis požiūris nei senieji `find_or_create_by` dinaminiai metodai, nes aiškiai nurodomi argumentai, kurie naudojami ieškant įrašo ir kurie naudojami jį sukurti.

    ```ruby
    User.where(:first_name => "Scarlett").first_or_create!(:last_name => "Johansson")
    ```

* Pridėtas `with_lock` metodas Active Record objektams, kuris pradeda transakciją, užrakina objektą (pesimistiškai) ir perduoda blokui. Metodas priima vieną (neprivalomą) parametrą ir perduoda jį `lock!` metodui.

    Tai leidžia rašyti šį kodą:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        transaction do
          lock!
          # ... atšaukimo logika
        end
      end
    end
    ```

    kaip:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        with_lock do
          # ... atšaukimo logika
        end
      end
    end
    ```

### Pasenusios funkcijos

* Automatinis ryšių uždarymas gijose yra pasenusi. Pavyzdžiui, šis kodas yra pasenusi:

    ```ruby
    Thread.new { Post.find(1) }.join
    ```

    Jis turėtų būti pakeistas, kad duomenų bazės ryšys būtų uždarytas gijos pabaigoje:

    ```ruby
    Thread.new {
      Post.find(1)
      Post.connection.close
    }.join
    ```

    Tik žmonės, kurie savo programos kode kuria gijas, turėtų rūpintis šiuo pakeitimu.

* `set_table_name`, `set_inheritance_column`, `set_sequence_name`, `set_primary_key`, `set_locking_column` metodai yra pasenusi. Vietoj jų naudokite priskyrimo metodus. Pavyzdžiui, vietoj `set_table_name` naudokite `self.table_name=`.

    ```ruby
    class Project < ActiveRecord::Base
      self.table_name = "project"
    end
    ```

    Arba apibrėžkite savo `self.table_name` metodą:

    ```ruby
    class Post < ActiveRecord::Base
      def self.table_name
        "special_" + super
      end
    end

    Post.table_name # => "special_posts"
    ```

Active Model
------------

* Pridėtas `ActiveModel::Errors#added?` metodas, skirtas patikrinti, ar konkretus klaidos pranešimas buvo pridėtas.

* Pridėta galimybė apibrėžti griežtąsias validacijas su `strict => true`, kurios visada išmeta išimtį, jei nepavyksta.

* Pateikiamas `mass_assignment_sanitizer` kaip paprastas API, skirtas pakeisti valymo elgseną. Taip pat palaikomi tiek `:logger` (numatytasis), tiek `:strict` valymo elgsenos variantai.

### Pasenusios funkcijos

* Pasenusi `define_attr_method` funkcija `ActiveModel::AttributeMethods`, nes ji egzistavo tik tam, kad palaikytų `set_table_name` tipo metodus Active Record, kurie patys yra pasenusi.

* Pasenusi `Model.model_name.partial_path` funkcija pakeista į `model.to_partial_path`. 

Active Resource
---------------

* Peradresavimo atsakymai: 303 See Other ir 307 Temporary Redirect dabar elgiasi kaip 301 Moved Permanently ir 302 Found.

Active Support
--------------

* Pridėtas `ActiveSupport:TaggedLogging`, kuris gali apgaubti bet kurį standartinį `Logger` klasę ir suteikti žymėjimo galimybes.

    ```ruby
    Logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    Logger.tagged("BCX") { Logger.info "Stuff" }
    # Įrašo žinutę "[BCX] Stuff"

    Logger.tagged("BCX", "Jason") { Logger.info "Stuff" }
    # Įrašo žinutę "[BCX] [Jason] Stuff"

    Logger.tagged("BCX") { Logger.tagged("Jason") { Logger.info "Stuff" } }
    # Įrašo žinutę "[BCX] [Jason] Stuff"
    ```
* `beginning_of_week` metodas `Date`, `Time` ir `DateTime` klasėse priima neprivalomą argumentą, kuris nurodo savaitės pradžios dieną.

* `ActiveSupport::Notifications.subscribed` suteikia galimybę prenumeruoti įvykius vykstant bloke.

* Apibrėžti nauji metodai `Module#qualified_const_defined?`, `Module#qualified_const_get` ir `Module#qualified_const_set`, kurie yra analogiški atitinkamiems metodams standartinėje API, bet priima kvalifikuotus konstantų pavadinimus.

* Pridėtas `#deconstantize` metodas, kuris papildo `#demodulize` metodą inflekcijose. Tai pašalina dešinįjį segmentą kvalifikuotame konstantos pavadinime.

* Pridėtas `safe_constantize` metodas, kuris konstantizuoja eilutę, bet grąžina `nil`, o ne iškelia išimtį, jei konstanta (ar jos dalis) neegzistuoja.

* `ActiveSupport::OrderedHash` dabar pažymėtas kaip išskleidžiamas, naudojant `Array#extract_options!`.

* Pridėtas `Array#prepend` kaip sinonimas `Array#unshift` ir `Array#append` kaip sinonimas `Array#<<`.

* Tuščios eilutės apibrėžimas Ruby 1.9 buvo išplėstas iki Unikodo tarpų. Be to, Ruby 1.8 atveju ideografinė erdvė U+3000 laikoma tarpu.

* Inflektorius supranta akronimus.

* Pridėti `Time#all_day`, `Time#all_week`, `Time#all_quarter` ir `Time#all_year` kaip būdas generuoti intervalus.

    ```ruby
    Event.where(:created_at => Time.now.all_week)
    Event.where(:created_at => Time.now.all_day)
    ```

* Pridėtas `instance_accessor: false` pasirinkimas `Class#cattr_accessor` ir panašiems metodams.

* `ActiveSupport::OrderedHash` dabar turi skirtingą elgesį `#each` ir `#each_pair` metodams, kai perduodamas blokas su splat parametrais.

* Pridėtas `ActiveSupport::Cache::NullStore` naudojimui vystyme ir testavime.

* Pašalintas `ActiveSupport::SecureRandom` naudai `SecureRandom` iš standartinės bibliotekos.

### Pasenusios funkcijos

* `ActiveSupport::Base64` pasenusi naudai `::Base64`.

* `ActiveSupport::Memoizable` pasenusi naudai Ruby memoization šablonui.

* `Module#synchronize` pasenusi be pakeitimo. Prašome naudoti monitorių iš Ruby standartinės bibliotekos.

* `ActiveSupport::MessageEncryptor#encrypt` ir `ActiveSupport::MessageEncryptor#decrypt` pasenusios.

* `ActiveSupport::BufferedLogger#silence` pasenusi. Jei norite nutildyti žurnalą tam tikram blokui, pakeiskite žurnalo lygį tam blokui.

* `ActiveSupport::BufferedLogger#open_log` pasenusi. Šis metodas neturėjo būti viešas iš pradžių.

* `ActiveSupport::BufferedLogger` elgesys, kai automatiškai sukuriamas katalogas jūsų žurnalo failui, pasenusi. Prašome įsitikinti, kad sukūrėte katalogą jūsų žurnalo failui prieš jį sukurdami.

* `ActiveSupport::BufferedLogger#auto_flushing` pasenusi. Nustatykite sinchronizacijos lygį pagrindiniam failo valdikliui taip. Arba sureguliuokite savo failų sistemą. Dabar valdo išplėstinės sistemos talpykla.

    ```ruby
    f = File.open('foo.log', 'w')
    f.sync = true
    ActiveSupport::BufferedLogger.new f
    ```

* `ActiveSupport::BufferedLogger#flush` pasenusi. Nustatykite sinchronizaciją savo failo valdiklyje arba sureguliuokite savo failų sistemą.

Autoriai
-------

Žr. [visą sąrašą Rails prisidėjusių asmenų](http://contributors.rubyonrails.org/), kurie daug valandų skyrė Rails, stabiliai ir patikimai veikiančiam karkasui, sukurti. Jie visi nusipelno pagyrimo.

Rails 3.2 išleidimo pastabas sudarė [Vijay Dev](https://github.com/vijaydev).
