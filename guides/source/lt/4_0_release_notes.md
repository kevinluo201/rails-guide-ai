**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b21dbc892c0a841f1bc1fafdf5ee0126
Ruby on Rails 4.0 Išleidimo pastabos
===============================

Svarbiausios naujovės Rails 4.0:

* Pageidaujamas Ruby 2.0; reikalingas 1.9.3+
* Stiprūs parametrai
* Turbolinks
* Rusiško lėlių talpinimas

Šios išleidimo pastabos apima tik pagrindinius pokyčius. Norėdami sužinoti apie įvairius klaidų taisymus ir pokyčius, prašome kreiptis į pakeitimų žurnalus arba peržiūrėti [pakeitimų sąrašą](https://github.com/rails/rails/commits/4-0-stable) pagrindiniame Rails saugykloje GitHub.

--------------------------------------------------------------------------------

Atnaujinimas iki Rails 4.0
----------------------

Jei atnaujinote esamą programą, prieš pradedant gerai būtų turėti geras testavimo galimybes. Taip pat pirmiausia turėtumėte atnaujinti iki Rails 3.2, jei dar to nedarėte, ir įsitikinti, kad jūsų programa vis dar veikia kaip tikėtasi, prieš bandant atnaujinti iki Rails 4.0. Atnaujinimo metu reikėtų atkreipti dėmesį į keletą dalykų, kuriuos galima rasti [Ruby on Rails atnaujinimo](upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0) vadove.

Rails 4.0 programos kūrimas
--------------------------------

```bash
# Turite įdiegtą 'rails' RubyGem
$ rails new myapp
$ cd myapp
```

### Gems'ų pardavimas

Rails dabar naudoja `Gemfile` programos šakninėje direktorijoje, kad nustatytų jums reikalingus gems'us, kad jūsų programa galėtų paleisti. Šis `Gemfile` apdorojamas naudojant [Bundler](https://github.com/carlhuda/bundler) gem'ą, kuris tada įdiegia visus jūsų priklausomybes. Jis netgi gali įdiegti visas priklausomybes vietiniame jūsų programos aplanke, kad ji nebūtų priklausoma nuo sistemos gems'ų.

Daugiau informacijos: [Bundler pagrindinis puslapis](https://bundler.io)

### Gyvenimas ant krašto

`Bundler` ir `Gemfile` padaro jūsų Rails programos užšaldymą labai paprastą su nauju specialiu `bundle` komanda. Jei norite tiesiogiai iš Git saugyklos įdiegti, galite perduoti `--edge` parametrą:

```bash
$ rails new myapp --edge
```

Jei turite vietinę Rails saugyklą ir norite sukurti programą naudodami ją, galite perduoti `--dev` parametrą:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

Pagrindinės funkcijos
--------------

[![Rails 4.0](images/4_0_release_notes/rails4_features.png)](https://guides.rubyonrails.org/images/4_0_release_notes/rails4_features.png)

### Atnaujinimas

* **Ruby 1.9.3** ([pakeitimas](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)) - Pageidaujamas Ruby 2.0; reikalingas 1.9.3+
* **[Nauja pasenusių funkcijų politika](https://www.youtube.com/watch?v=z6YgD6tVPQs)** - Pasenusios funkcijos yra įspėjimai Rails 4.0 ir bus pašalintos Rails 4.1.
* **ActionPack puslapio ir veiksmo talpinimas** ([pakeitimas](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)) - Puslapio ir veiksmo talpinimas išskirtas į atskirą gem'ą. Puslapio ir veiksmo talpinimas reikalauja per daug rankinio įsikišimo (rankinio talpinimo atnaujinant pagrindinius modelio objektus). Vietoj to naudokite rusiško lėlių talpinimą.
* **ActiveRecord stebėtojai** ([pakeitimas](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)) - Stebėtojai išskirti į atskirą gem'ą. Stebėtojai reikalingi tik puslapio ir veiksmo talpinimui ir gali sukelti spageti kodo rašymą.
* **ActiveRecord sesijos saugykla** ([pakeitimas](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)) - ActiveRecord sesijos saugykla išskirta į atskirą gem'ą. Sesijų saugojimas SQL yra brangus. Vietoj to naudokite slapukų sesijas, memcache sesijas arba pasirinktinę sesijos saugyklą.
* **ActiveModel masinio priskyrimo apsauga** ([pakeitimas](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)) - Rails 3 masinio priskyrimo apsauga yra pasenusi. Vietoj to naudokite stiprius parametrus.
* **ActiveResource** ([pakeitimas](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)) - ActiveResource išskirtas į atskirą gem'ą. ActiveResource nebuvo plačiai naudojamas.
* **vendor/plugins pašalintas** ([pakeitimas](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)) - Naudokite `Gemfile` valdyti įdiegtus gem'us.
### ActionPack

* **Stipriosios parametrai** ([commit](https://github.com/rails/rails/commit/a8f6d5c6450a7fe058348a7f10a908352bb6c7fc)) - Leidžiama atnaujinti modelio objektus tik su leidžiamais parametrais (`params.permit(:title, :text)`).
* **Maršruto susirūpinimai** ([commit](https://github.com/rails/rails/commit/0dd24728a088fcb4ae616bb5d62734aca5276b1b)) - Maršruto DSL, išskiriant bendrus submaršrutus (`comments` iš `/posts/1/comments` ir `/videos/1/comments`).
* **ActionController::Live** ([commit](https://github.com/rails/rails/commit/af0a9f9eefaee3a8120cfd8d05cbc431af376da3)) - Srautinė JSON su `response.stream`.
* **Deklaratyvūs ETag'ai** ([commit](https://github.com/rails/rails/commit/ed5c938fa36995f06d4917d9543ba78ed506bb8d)) - Pridedami kontrolerio lygio ETag'ai, kurie bus dalis veiksmo ETag'o skaičiavimo.
* **[Rusų lėlių talpinimas](https://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)** ([commit](https://github.com/rails/rails/commit/4154bf012d2bec2aae79e4a49aa94a70d3e91d49)) - Talpinami lizdinių rodinių dalys. Kiekviena dalis pasibaigia pagal priklausomybių rinkinį (talpinimo raktą). Talpinimo raktas paprastai yra šablono versijos numeris ir modelio objektas.
* **Turbolinks** ([commit](https://github.com/rails/rails/commit/e35d8b18d0649c0ecc58f6b73df6b3c8d0c6bb74)) - Tarnaukite tik vieną pradinį HTML puslapį. Kai vartotojas pereina į kitą puslapį, naudokite pushState, kad atnaujintumėte URL ir naudokite AJAX, kad atnaujintumėte pavadinimą ir kūną.
* **Atskirti ActionView nuo ActionController** ([commit](https://github.com/rails/rails/commit/78b0934dd1bb84e8f093fb8ef95ca99b297b51cd)) - ActionView buvo atskirta nuo ActionPack ir bus perkelta į atskirą gemą „Rails 4.1“.
* **Nepriklausyti nuo ActiveModel** ([commit](https://github.com/rails/rails/commit/166dbaa7526a96fdf046f093f25b0a134b277a68)) - ActionPack daugiau neprisideda nuo ActiveModel.

### Bendras

 * **ActiveModel::Model** ([commit](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)) - `ActiveModel::Model`, mišinys, leidžiantis normaliems Ruby objektams dirbti su ActionPack iškart (pvz., `form_for`).
 * **Nauja taikinio API** ([commit](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)) - Taikiniai visada turi naudoti iškviečiamuosius.
 * **Schemos talpinimo išmetimas** ([commit](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)) - Siekiant pagerinti „Rails“ paleidimo laiką, vietoj schemos tiesioginio įkėlimo iš duomenų bazės, įkelkite schemą iš išmetimo failo.
 * **Paramos nustatant transakcijos izoliacijos lygį** ([commit](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)) - Pasirinkite, ar svarbiau yra pasikartojantys skaitymai ar pagerinta našumas (mažiau užrakinimo).
 * **Dalli** ([commit](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)) - Naudokite Dalli memcache klientą memcache saugyklai.
 * **Pranešimų pradžia ir pabaiga** ([commit](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)) - „Active Support“ instrumentacija praneša prenumeratoriams apie pradžios ir pabaigos pranešimus.
 * **Numatytasis gijų saugumas** ([commit](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)) - „Rails“ gali veikti gijomis pagrįstose programų serveriose be papildomo konfigūravimo.

PASTABA: Patikrinkite, ar naudojami jūsų naudojami gemai yra gijų saugūs.

 * **PATCH veiksmas** ([commit](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)) - „Rails“ atveju, PATCH pakeičia PUT. PATCH naudojamas daliniam išteklių atnaujinimui.

### Saugumas

* **Atitikimas neaptinka visų** ([commit](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)) - Maršruto DSL, atitikimas reikalauja nurodyti HTTP veiksmą ar veiksmus.
* **HTML simboliai pagal nutylėjimą išvengiami** ([commit](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)) - Eilutės, atvaizduojamos erb, išvengiamos, nebent apgaubtos `raw` arba iškviestas `html_safe`.
* **Nauji saugumo antraštės** ([commit](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)) - „Rails“ siunčia šias antraštes su kiekvienu HTTP užklausos: `X-Frame-Options` (neleidžia paspaudimų apgaulingumui, draudžia naršyklei įterpti puslapį į rėmelį), `X-XSS-Protection` (prašo naršyklei sustabdyti scenarijaus įterpimą) ir `X-Content-Type-Options` (neleidžia naršyklei atverti jpeg kaip exe).
Savybių išgavimas į gemus
---------------------------

Rails 4.0 versijoje kelios savybės buvo išgautos į gemus. Norėdami atkurti funkcionalumą, tiesiog pridėkite išgautus gemus į savo `Gemfile`.

* Hash-based & Dinaminiai paieškos metodai ([GitHub](https://github.com/rails/activerecord-deprecated_finders))
* Masinio priskyrimo apsauga Active Record modeliuose ([GitHub](https://github.com/rails/protected_attributes), [Pull Request](https://github.com/rails/rails/pull/7251))
* ActiveRecord::SessionStore ([GitHub](https://github.com/rails/activerecord-session_store), [Pull Request](https://github.com/rails/rails/pull/7436))
* Active Record Observers ([GitHub](https://github.com/rails/rails-observers), [Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2))
* Active Resource ([GitHub](https://github.com/rails/activeresource), [Pull Request](https://github.com/rails/rails/pull/572), [Blog](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource))
* Action Caching ([GitHub](https://github.com/rails/actionpack-action_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Page Caching ([GitHub](https://github.com/rails/actionpack-page_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Sprockets ([GitHub](https://github.com/rails/sprockets-rails))
* Veikimo testai ([GitHub](https://github.com/rails/rails-perftest), [Pull Request](https://github.com/rails/rails/pull/8876))

Dokumentacija
-------------

* Gidai yra persirašyti naudojant GitHub Flavored Markdown.

* Gidai turi atsakingą dizainą.

Railties
--------

Išsamesnių pakeitimų informacijai žiūrėkite [Changelog](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md).

### Pastebimi pakeitimai

* Nauji testavimo vietos `test/models`, `test/helpers`, `test/controllers` ir `test/mailers`. Taip pat pridėtos atitinkamos rake užduotys. ([Pull Request](https://github.com/rails/rails/pull/7878))

* Jūsų programos vykdomieji failai dabar yra `bin/` kataloge. Paleiskite `rake rails:update:bin`, kad gautumėte `bin/bundle`, `bin/rails` ir `bin/rake`.

* Gijų saugumas įjungtas pagal numatytuosius nustatymus.

* Galimybė naudoti pasirinktinį kūrėją, perduodant `--builder` (arba `-b`) į `rails new`, pašalinta. Svarstykite naudoti aplikacijos šablonus vietoj to. ([Pull Request](https://github.com/rails/rails/pull/9401))

### Pasenusios funkcijos

* `config.threadsafe!` pasenusi, naudokite `config.eager_load`, kuris suteikia išsamesnį valdymą, ką reikia įkelti iš anksto.

* `Rails::Plugin` panaikinta. Vietoj įkelkite įskiepius į `vendor/plugins` naudodami gemus arba bundler su keliu arba git priklausomybėmis.

Action Mailer
-------------

Išsamesnių pakeitimų informacijai žiūrėkite [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionmailer/CHANGELOG.md).

### Pastebimi pakeitimai

### Pasenusios funkcijos

Active Model
------------

Išsamesnių pakeitimų informacijai žiūrėkite [Changelog](https://github.com/rails/rails/blob/4-0-stable/activemodel/CHANGELOG.md).

### Pastebimi pakeitimai

* Pridėtas `ActiveModel::ForbiddenAttributesProtection`, paprastas modulis, skirtas apsaugoti atributus nuo masinio priskyrimo, kai perduodami neleidžiami atributai.

* Pridėtas `ActiveModel::Model`, mišinys, leidžiantis Ruby objektams veikti su Action Pack iškart.

### Pasenusios funkcijos

Active Support
--------------

Išsamesnių pakeitimų informacijai žiūrėkite [Changelog](https://github.com/rails/rails/blob/4-0-stable/activesupport/CHANGELOG.md).

### Pastebimi pakeitimai

* Pakeistas pasenusių `memcache-client` gemo naudojimas į `dalli` `ActiveSupport::Cache::MemCacheStore`.

* Optimizuotas `ActiveSupport::Cache::Entry`, kad būtų sumažintas atminties ir apdorojimo našumo sąnaudos.

* Inflekcijos dabar gali būti apibrėžiamos pagal lokalę. `singularize` ir `pluralize` priima papildomą argumentą - lokalę.

* `Object#try` dabar grąžins `nil`, o ne iškels `NoMethodError`, jei gavimo objektas neįgyvendina metodo, tačiau vis tiek galite gauti senąjį elgesį naudodami naują `Object#try!`.
* `String#to_date` dabar iškelia `ArgumentError: invalid date` vietoje `NoMethodError: undefined method 'div' for nil:NilClass`
  kai pateikiamas neteisingas data. Dabar tai yra tas pats kaip ir `Date.parse`, ir ji priima daugiau neteisingų datų nei 3.x versija, pvz.:

    ```ruby
    # ActiveSupport 3.x
    "asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
    "333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

    # ActiveSupport 4
    "asdf".to_date # => ArgumentError: invalid date
    "333".to_date # => Pen, 2013 m. lapkričio 29 d.
    ```

### Pasenusios funkcijos

* Pasenusi `ActiveSupport::TestCase#pending` funkcija, naudokite `skip` iš minitest vietoje.

* `ActiveSupport::Benchmarkable#silence` funkcija pasenusi dėl jos trūkumo gijų saugumui. Ji bus pašalinta be pakeitimo Rails 4.1 versijoje.

* `ActiveSupport::JSON::Variable` yra pasenusi. Apibrėžkite savo `#as_json` ir `#encode_json` metodus, skirtus tinkintiems JSON eilučių literalomis.

* Pasenusi suderinamumo funkcija `Module#local_constant_names`, naudokite `Module#local_constants` vietoje (kuris grąžina simbolius).

* `ActiveSupport::BufferedLogger` yra pasenusi. Naudokite `ActiveSupport::Logger` arba žurnalistą iš Ruby standartinės bibliotekos.

* Pasenusi `assert_present` ir `assert_blank` funkcijos, naudokite `assert object.blank?` ir `assert object.present?` vietoje.

Veiksmų paketas
-----------

Išsamesnius pakeitimus žr. [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md).

### Svarbūs pakeitimai

* Pakeista išimčių puslapių stiliaus plėtinio režime. Be to, visuose išimčių puslapiuose taip pat rodoma kodo eilutė ir fragmentas, kuris sukėlė išimtį.

### Pasenusios funkcijos


Aktyvusis įrašas
-------------

Išsamesnius pakeitimus žr. [Changelog](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md).

### Svarbūs pakeitimai

* Gerinamos būdai rašyti `change` migracijas, todėl senosios `up` ir `down` metodai nebėra būtini.

    * `drop_table` ir `remove_column` metodai dabar yra atvirkštiniai, jei pateikiama reikalinga informacija.
      `remove_column` metodas anksčiau priimdavo kelis stulpelių pavadinimus; vietoje to naudokite `remove_columns` (kuris negali būti atstatytas).
      `change_table` metodas taip pat yra atvirkštinis, jei jo bloke nėra kviečiami `remove`, `change` ar `change_default` metodai.

    * Naujas `reversible` metodas leidžia nurodyti kodą, kuris bus vykdomas migracijos metu į priekį arba atgal.
      Žr. [Migracijos vadovą](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#using-reversible)

    * Naujas `revert` metodas atstatys visą migraciją arba duotą bloką.
      Jei migruojama atgal, duota migracija / blokas bus vykdomas įprastai.
      Žr. [Migracijos vadovą](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#reverting-previous-migrations)

* Pridedama palaikymas PostgreSQL masyvo tipo. Bet koks duomenų tipas gali būti naudojamas sukurti masyvo stulpelį, su visišku migracijos ir schemos išmetimo palaikymu.
* Pridėkite `Relation#load` metodą, skirtą išreiškiamai įkelti įrašą ir grąžinti `self`.

* `Model.all` dabar grąžina `ActiveRecord::Relation`, o ne įrašų masyvą. Jei tikrai norite gauti masyvą, naudokite `Relation#to_a`. Kai kuriuose konkrečiuose atvejuose tai gali sukelti sutrikimus atnaujinant.

* Pridėtas `ActiveRecord::Migration.check_pending!`, kuris iškelia klaidą, jei yra laukiančių migracijų.

* Pridėta palaikymas pasirinktiniams koduotojams `ActiveRecord::Store`. Dabar galite nustatyti savo pasirinktinį koduotoją taip:

        store :settings, accessors: [ :color, :homepage ], coder: JSON

* `mysql` ir `mysql2` prisijungimai pagal nutylėjimą nustato `SQL_MODE=STRICT_ALL_TABLES`, kad būtų išvengta tylaus duomenų praradimo. Tai galima išjungti nurodant `strict: false` savo `database.yml`.

* Pašalintas IdentityMap.

* Pašalintas automatinis EXPLAIN užklausų vykdymas. Parinktis `active_record.auto_explain_threshold_in_seconds` daugiau nenaudojama ir turėtų būti pašalinta.

* Pridedamas `ActiveRecord::NullRelation` ir `ActiveRecord::Relation#none`, įgyvendinantys null objekto modelį `Relation` klasėje.

* Pridėtas `create_join_table` migracijos pagalbininkas, skirtas sukurti HABTM jungimo lenteles.

* Leidžiama kurti PostgreSQL hstore įrašus.

### Pasenusios funkcijos

* Pasenusi senojo stiliaus hash pagrindu paremta paieškos API. Tai reiškia, kad metodai, kurie anksčiau priėmė "paieškos parinktis", to jau nebedaro.

* Visi dinaminiai metodai, išskyrus `find_by_...` ir `find_by_...!`, yra pasenusi. Čia pateikiama, kaip galite pertvarkyti kodą:

      * `find_all_by_...` galima pertvarkyti naudojant `where(...)`.
      * `find_last_by_...` galima pertvarkyti naudojant `where(...).last`.
      * `scoped_by_...` galima pertvarkyti naudojant `where(...)`.
      * `find_or_initialize_by_...` galima pertvarkyti naudojant `find_or_initialize_by(...)`.
      * `find_or_create_by_...` galima pertvarkyti naudojant `find_or_create_by(...)`.
      * `find_or_create_by_...!` galima pertvarkyti naudojant `find_or_create_by!(...)`.

Ačiū
-------

Žr. [visą sąrašą Rails prisidėjusių asmenų](https://contributors.rubyonrails.org/) už daugelį valandų, kurias jie praleido kurdami Rails, stabilų ir patikimą karkasą. Kudos visiems jiems.
