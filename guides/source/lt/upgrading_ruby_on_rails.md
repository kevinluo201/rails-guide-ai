**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b95e1fead49349e056e5faed88aa5760
Ruby on Rails atnaujinimas
=======================

Šis vadovas pateikia žingsnius, kuriuos reikia atlikti, kai atnaujinamas jūsų programų versijos naujesne Ruby on Rails versija. Šie žingsniai taip pat yra prieinami atskiruose leidimo vadovuose.

--------------------------------------------------------------------------------

Bendrosios rekomendacijos
--------------

Prieš bandydami atnaujinti esamą programą, turėtumėte būti tikri, kad turite gera priežastį atnaujinti. Turite suderinti kelis veiksnius: poreikį naujiems funkcionalumams, vis sunkiau rasti palaikymą senam kodui ir turimus laiką bei įgūdžius, kad paminėtume tik kelis.

### Testavimo padengimas

Geriausias būdas įsitikinti, kad jūsų programa vis dar veikia po atnaujinimo, yra turėti gerą testavimo padengimą prieš pradedant procesą. Jei neturite automatizuotų testų, kurie išbandytų didžiąją jūsų programos dalį, turėsite skirti laiko rankiniu būdu išbandyti visas dalis, kurios pasikeitė. Rails atnaujinimo atveju tai reikš kiekvieną funkcionalumo dalį programoje. Padarykite sau paslaugą ir įsitikinkite, kad jūsų testavimo padengimas yra geras _prieš_ pradedant atnaujinimą.

### Ruby versijos

Rails paprastai išlieka arti naujausios išleistos Ruby versijos, kai ji išleidžiama:

* Rails 7 reikalauja Ruby 2.7.0 ar naujesnės versijos.
* Rails 6 reikalauja Ruby 2.5.0 ar naujesnės versijos.
* Rails 5 reikalauja Ruby 2.2.2 ar naujesnės versijos.

Gera mintis yra atnaujinti Ruby ir Rails atskirai. Pirmiausia atnaujinkite iki naujausios galimos Ruby versijos, o tada atnaujinkite Rails.

### Atnaujinimo procesas

Keičiant Rails versijas, geriausia judėti lėtai, po vieną mažą versiją, kad galėtumėte gerai išnaudoti pasenusių funkcijų įspėjimus. Rails versijų numeriai yra formato Major.Minor.Patch. Major ir Minor versijos gali keisti viešąją API, todėl tai gali sukelti klaidas jūsų programoje. Patch versijos apima tik klaidų taisymus ir nekeičia jokio viešojo API.

Procesas turėtų vykti taip:

1. Parašykite testus ir įsitikinkite, kad jie veikia.
2. Pakeiskite į naujausią patch versiją po esamos versijos.
3. Ištaisykite testus ir pasenusius funkcionalumus.
4. Pakeiskite į naujausią patch versiją po kitos mažesnės versijos.

Kartokite šį procesą, kol pasieksite norimą Rails versiją.

#### Judėjimas tarp versijų

Norėdami judėti tarp versijų:

1. Pakeiskite Rails versijos numerį `Gemfile` faile ir paleiskite `bundle update`.
2. Pakeiskite Rails JavaScript paketų versijas `package.json` faile ir paleiskite `yarn install`, jei naudojate Webpacker.
3. Paleiskite [Atnaujinimo užduotį](#the-update-task).
4. Paleiskite savo testus.

Visus išleistus Rails gemus galite rasti [čia](https://rubygems.org/gems/rails/versions).

### Atnaujinimo užduotis

Rails teikia `rails app:update` komandą. Po Rails versijos atnaujinimo
`Gemfile` faile, paleiskite šią komandą.
Tai padės jums sukurti naujus failus ir pakeisti senus failus interaktyvioje sesijoje.

```bash
$ bin/rails app:update
       exist  config
    conflict  config/application.rb
Overwrite /myapp/config/application.rb? (enter "h" for help) [Ynaqdh]
       force  config/application.rb
      create  config/initializers/new_framework_defaults_7_0.rb
...
```

Nepamirškite peržiūrėti skirtumo, kad pamatytumėte, ar buvo kokios nors netikėtos pakeitimų.

### Konfigūruoti pagrindinius nustatymus

Naujoji Rails versija gali turėti skirtingus konfigūracijos numatytuosius nustatymus nei ankstesnė versija. Tačiau, laikantis aukščiau aprašytų žingsnių, jūsų programa vis dar veiktų su konfigūracijos numatytuoju iš *ankstesnės* Rails versijos. Tai todėl, kad `config.load_defaults` reikšmė `config/application.rb` faile dar nebuvo pakeista.

Kad galėtumėte pereiti prie naujų numatytųjų nustatymų vieną po kito, atnaujinimo užduotis sukūrė failą `config/initializers/new_framework_defaults_X.Y.rb` (su norima Rails versija failo pavadinime). Naujus konfigūracijos numatytuosius nustatymus turėtumėte įgalinti iškomentuodami juos faile; tai galima padaryti palaipsniui per kelis diegimus. Kai jūsų programa pasiruošusi veikti su naujais numatytuoju nustatymais, galite pašalinti šį failą ir pakeisti `config.load_defaults` reikšmę.

Atnaujinimas nuo Rails 7.0 iki Rails 7.1
-------------------------------------

Daugiau informacijos apie pakeitimus, įvykdytus Rails 7.1, rasite [leidimo pastabose](7_1_release_notes.html).

### Automatinio įkėlimo keliai nebėra įkėlimo kelio

Pradedant nuo Rails 7.1, visi automatinio įkėlimo valdomi keliai nebebus pridėti prie `$LOAD_PATH`.
Tai reiškia, kad juos nebebus galima įkelti naudojant rankinį `require` kvietimą, o klasės ar modulio galima paminėti.

Sumažinant `$LOAD_PATH` dydį, pagreitėja `require` kvietimai programoms, kurios nenaudoja `bootsnap`, ir sumažinamas
`bootsnap` talpyklos dydis kitiems.
### `ActiveStorage::BaseController` daugiau neįtraukia srautinio susidomėjimo

Programos valdikliai, kurie paveldi iš `ActiveStorage::BaseController` ir naudoja srautinį perdavimą, kad įgyvendintų pasirinktinę failų aptarnavimo logiką, dabar turi aiškiai įtraukti `ActiveStorage::Streaming` modulį.

### `MemCacheStore` ir `RedisCacheStore` dabar pagal numatytuosius nustatymus naudoja ryšių kaupimą

`connection_pool` grotelė buvo pridėta kaip `activesupport` grotelės priklausomybė,
ir `MemCacheStore` bei `RedisCacheStore` dabar pagal numatytuosius nustatymus naudoja ryšių kaupimą.

Jei nenorite naudoti ryšių kaupimo, nustatydami `:pool` parinktį į `false`, kai
konfigūruojate talpyklą:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

Daugiau informacijos rasite [Rails talpyklos naudojimas](https://guides.rubyonrails.org/v7.1/caching_with_rails.html#connection-pool-options) vadove.

### `SQLite3Adapter` dabar sukonfigūruotas naudoti griežtą eilučių režimą

Griežto eilučių režimo naudojimas išjungia dvigubai cituojamas eilutės literas.

SQLite turi keletą ypatybių, susijusių su dvigubai cituojamomis eilutėmis.
Pirma jis bando laikyti dvigubai cituojamas eilutes identifikatorių pavadinimais, bet jei jų nėra
tada jis laiko juos eilutės literomis. Dėl šios priežasties klaidingi rašybos klaidos gali likti nepastebėtos.
Pavyzdžiui, galima sukurti indeksą neegzistuojančiam stulpeliui.
Daugiau informacijos rasite [SQLite dokumentacijoje](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted).

Jei nenorite naudoti `SQLite3Adapter` griežtame režime, galite išjungti šį veikimą:

```ruby
# config/application.rb
config.active_record.sqlite3_adapter_strict_strings_by_default = false
```

### Paramos daugeliui peržiūros kelių skirtiems `ActionMailer::Preview`

Parinktis `config.action_mailer.preview_path` yra pasenusi, jos vietoje naudokite `config.action_mailer.preview_paths`. Pridedant kelių šaltinių prie šios konfigūracijos parinkties, šie keliai bus naudojami ieškant pašto siuntėjo peržiūrų.

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### `config.i18n.raise_on_missing_translations = true` dabar kelia išimtis dėl bet kokio praleisto vertimo.

Anksčiau ji kėlė tik tuomet, kai buvo iškviesta peržiūra arba valdiklis. Dabar ji kels išimtį bet kuriuo metu, kai `I18n.t` pateikiamas nepripažintas raktas.

```ruby
# su config.i18n.raise_on_missing_translations = true

# peržiūroje arba valdiklyje:
t("missing.key") # kelia išimtį 7.0, kelia išimtį 7.1
I18n.t("missing.key") # nekėlė išimties 7.0, kelia išimtį 7.1

# bet kur:
I18n.t("missing.key") # nekėlė išimties 7.0, kelia išimtį 7.1
```

Jei nenorite tokio elgesio, galite nustatyti `config.i18n.raise_on_missing_translations = false`:

```ruby
# su config.i18n.raise_on_missing_translations = false

# peržiūroje arba valdiklyje:
t("missing.key") # nekėlė išimties 7.0, nekelia išimties 7.1
I18n.t("missing.key") # nekėlė išimties 7.0, nekelia išimties 7.1

# bet kur:
I18n.t("missing.key") # nekėlė išimties 7.0, nekelia išimties 7.1
```

Alternatyviai galite tinkinti `I18n.exception_handler`.
Daugiau informacijos rasite [i18n vadove](https://guides.rubyonrails.org/v7.1/i18n.html#using-different-exception-handlers).

Atnaujinimas nuo Rails 6.1 iki Rails 7.0
---------------------------------------

Daugiau informacijos apie pakeitimus, įvykdytus Rails 7.0, rasite [leidimo pastabose](7_0_release_notes.html).

### `ActionView::Helpers::UrlHelper#button_to` pakeitė elgesį

Pradedant nuo Rails 7.0, `button_to` atvaizduoja `form` žymą su `patch` HTTP veiksmu, jei naudojamas išsaugotas aktyvusis įrašo objektas, kuris naudojamas kurti mygtuko URL.
Norint išlaikyti esamą elgesį, svarbu aiškiai perduoti `method:` parinktį:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)], method: :post)
```

arba naudoti pagalbininką, kuris kuria URL:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", my_custom_post_action_on_workshop_workshop_path(Workshop.find(1)))
```

### Spring

Jei jūsų programa naudoja Spring, ją reikia atnaujinti bent iki 3.0.0 versijos. Kitu atveju gausite

```
undefined method `mechanism=' for ActiveSupport::Dependencies:Module
```

Taip pat įsitikinkite, kad [`config.cache_classes`][] yra nustatytas kaip `false` `config/environments/test.rb` faile.


### Sprockets dabar yra pasirenkama priklausomybė

Grotelė `rails` daugiau neprisijungia prie `sprockets-rails`. Jei jūsų programa vis dar turi naudoti Sprockets,
įsitikinkite, kad pridėjote `sprockets-rails` į savo Gemfile.

```ruby
gem "sprockets-rails"
```

### Programos turi veikti `zeitwerk` režimu

Programos, kurios vis dar veikia `classic` režime, turi persijungti į `zeitwerk` režimą. Prašome peržiūrėti [Classic to Zeitwerk HOWTO](https://guides.rubyonrails.org/v7.0/classic_to_zeitwerk_howto.html) vadovą, kad gautumėte daugiau informacijos.

### `config.autoloader=` nustatymas buvo ištrintas

Rails 7 nėra konfigūracijos taško, skirta nustatyti automatinio įkėlimo režimą, `config.autoloader=` buvo ištrintas. Jei jį turėjote nustatytą kaip `:zeitwerk` dėl bet kokios priežasties, tiesiog pašalinkite jį.

### `ActiveSupport::Dependencies` privati API buvo ištrintas

Ištrintas `ActiveSupport::Dependencies` privatus API. Tai apima metodus, tokius kaip `hook!`, `unhook!`, `depend_on`, `require_or_load`, `mechanism` ir daugelį kitų.

Keli išryškinimai:

* Jei naudojote `ActiveSupport::Dependencies.constantize` arba `ActiveSupport::Dependencies.safe_constantize`, tiesiog pakeiskite juos į `String#constantize` arba `String#safe_constantize`.

  ```ruby
  ActiveSupport::Dependencies.constantize("User") # DAUGIAU NEĮMANOMA
  "User".constantize # 👍
  ```

* Bet koks `ActiveSupport::Dependencies.mechanism` naudojimas, skaitytuvas ar rašytojas, turi būti pakeistas prieigomis prie `config.cache_classes` atitinkamai.

* Jei norite stebėti automatinio įkėlimo veiklą, `ActiveSupport::Dependencies.verbose=` daugiau negalioja, tiesiog įkelkite `Rails.autoloaders.log!` į `config/application.rb`.

Taip pat dingsta pagalbinės vidinės klasės ar moduliai, tokie kaip `ActiveSupport::Dependencies::Reference`, `ActiveSupport::Dependencies::Blamable` ir kiti.

### Automatinis įkėlimas inicializacijos metu

Programos, kurios automatiškai įkėlė pakartotinai įkeliamus konstantas inicializacijos metu, neesant `to_prepare` blokams, šios konstantos buvo iškraipytos ir buvo išspausdintas šis įspėjimas nuo Rails 6.0:

```
DEPRECATION WARNING: Initialization autoloaded the constant ....

Galimybė tai daryti yra pasenusi. Automatinis įkėlimas inicializacijos metu taps klaidos būsena ateities Rails versijose.

...
```

Jei vis dar gaunate šį įspėjimą žurnale, prašome patikrinti skyrių apie automatinį įkėlimą, kai programa paleidžiama [automatinio įkėlimo vadove](https://guides.rubyonrails.org/v7.0/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots). Kitu atveju, Rails 7 gausite `NameError`.

### Galimybė konfigūruoti `config.autoload_once_paths`

[`config.autoload_once_paths`][] gali būti nustatytas programos klasės kūno dalyje, apibrėžtoje `config/application.rb`, arba konfigūracijoje aplinkoms `config/environments/*`.

Panašiai, moduliai gali konfigūruoti tą kolekciją modulio klasės kūno dalyje arba konfigūracijoje aplinkoms.

Po to kolekcija yra užšaldoma ir galite automatiškai įkelti iš tų kelių. Ypač, galite automatiškai įkelti iš ten inicializacijos metu. Jais valdo `Rails.autoloaders.once` automatinis įkelėjas, kuris neperkrauna, tik automatiškai įkelia / greitai įkelia.

Jei konfigūravote šią nuostatą po aplinkų konfigūracijos apdorojimo ir gaunate `FrozenError`, tiesiog perkelskite kodą.

### `ActionDispatch::Request#content_type` dabar grąžina Content-Type antraštę kaip yra.

Anksčiau, `ActionDispatch::Request#content_type` grąžintas rezultatas NEbuvo sudarytas iš koduotės dalies.
Šis elgesys pakeistas grąžinant Content-Type antraštę, kurią sudaro koduotės dalis, kaip yra.

Jei norite tik MIME tipo, naudokite `ActionDispatch::Request#media_type` vietoj to.

Prieš tai:

```ruby
request = ActionDispatch::Request.new("CONTENT_TYPE" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv"
```

Po to:

```ruby
request = ActionDispatch::Request.new("Content-Type" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv; header=present; charset=utf-16"
request.media_type   #=> "text/csv"
```

### Raktų generatoriaus maišos klasės pakeitimas reikalauja slapukų keitiklio

Pagal nutylėjimą raktų generatoriaus maišos klasė keičiasi nuo SHA1 iki SHA256.
Tai turi pasekmių visiems sukuriamiems užšifruotiems pranešimams naudojant Rails, įskaitant
užšifruotus slapukus.

Norint galėti skaityti pranešimus naudojant seną maišos klasę, būtina
registruoti keitiklį. Nepavykus tai padaryti, gali būti, kad vartotojams bus anuliuoti jų sesijos
atnaujinimo metu.

Štai pavyzdys užšifruotų ir pasirašytų slapukų keitikliui:

```ruby
# config/initializers/cookie_rotator.rb
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    authenticated_encrypted_cookie_salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_cookie_salt = Rails.application.config.action_dispatch.signed_cookie_salt

    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    key_len = ActiveSupport::MessageEncryptor.key_len

    old_encrypted_secret = key_generator.generate_key(authenticated_encrypted_cookie_salt, key_len)
    old_signed_secret = key_generator.generate_key(signed_cookie_salt)

    cookies.rotate :encrypted, old_encrypted_secret
    cookies.rotate :signed, old_signed_secret
  end
end
```

### ActiveSupport::Digest maišos klasės keitimas į SHA256

Pagal nutylėjimą ActiveSupport::Digest maišos klasė keičiasi nuo SHA1 iki SHA256.
Tai turi pasekmių dalykams, pvz., Etags, kurie keisis, taip pat ir kešavimo raktams.
Šių raktų keitimas gali turėti įtakos kešavimo atitikimo rodikliui, todėl būkite atsargūs ir stebėkite
tai, kai atnaujinate į naują maišą.

### Naujas ActiveSupport::Cache serializavimo formatas

Buvo pristatytas greitesnis ir kompaktiškesnis serializavimo formatas.

Norėdami tai įjungti, turite nustatyti `config.active_support.cache_format_version = 7.0`:

```ruby
# config/application.rb

config.load_defaults 6.1
config.active_support.cache_format_version = 7.0
```

Arba tiesiog:

```ruby
# config/application.rb

config.load_defaults 7.0
```

Tačiau Rails 6.1 programos negali skaityti šio naujo serializavimo formato,
todėl, norint užtikrinti sklandų atnaujinimą, pirmiausia turite įdiegti savo Rails 7.0 atnaujinimą su
`config.active_support.cache_format_version = 6.1`, ir tik tada, kai visi Rails
procesai bus atnaujinti, galėsite nustatyti `config.active_support.cache_format_version = 7.0`.

Rails 7.0 gali skaityti abu formatus, todėl kešas nebus anuliuotas per
atnaujinimą.

### Active Storage vaizdo peržiūros vaizdo generavimas

Vaizdo peržiūros vaizdo generavimas dabar naudoja FFmpeg scenos pokyčių aptikimą, kad būtų galima generuoti
reikšmingesnius peržiūros vaizdus. Anksčiau būdavo naudojamas vaizdo pirmas kadras
ir tai sukeldavo problemas, jei vaizdas išnykdavo iš juodos. Šis pakeitimas reikalauja
FFmpeg v3.4+.

### Active Storage numatytasis varianto apdorojimo įrankis pakeistas į `:vips`

Naujoms programoms vaizdo transformacija naudos libvips vietoj ImageMagick. Tai sumažins
laiką, kurį užtrunka generuoti variantus, taip pat CPU ir atminties naudojimą, pagerinant atsaką
laikai programose, kurios remiasi Active Storage, kad aptarnautų savo vaizdus.

`:mini_magick` parinktis nėra pasenusi, todėl galite toliau ją naudoti.

Norint perkelti esamą programą į libvips, nustatykite:
```ruby
Rails.application.config.active_storage.variant_processor = :vips
```

Tada turėsite pakeisti esamą vaizdo transformacijos kodą į `image_processing` makro, ir pakeisti ImageMagick parinktis libvips parinktimis.

#### Pakeiskite resize su resize_to_limit

```diff
- variant(resize: "100x")
+ variant(resize_to_limit: [100, nil])
```

Jei to nepadarysite, pereinant prie vips, matysite šią klaidą: `no implicit conversion to float from string`.

#### Naudojant masyvą, kai apkirpti

```diff
- variant(crop: "1920x1080+0+0")
+ variant(crop: [0, 0, 1920, 1080])
```

Jei to nepadarysite, pereinant prie vips, matysite šią klaidą: `unable to call crop: you supplied 2 arguments, but operation needs 5`.

#### Prisitaikykite prie apkirpimo reikšmių:

Vips yra griežtesnis nei ImageMagick, kai kalbama apie apkirpimą:

1. Jis neapkirs, jei `x` ir/arba `y` yra neigiamos reikšmės. pvz.: `[-10, -10, 100, 100]`
2. Jis neapkirs, jei pozicija (`x` arba `y`) plius apkirpimo matmenys (`plotis`, `aukštis`) yra didesni nei paveikslėlis. pvz.: 125x125 paveikslėlis ir apkirpimas `[50, 50, 100, 100]`

Jei to nepadarysite, pereinant prie vips, matysite šią klaidą: `extract_area: bad extract area`

#### Pritaikykite fono spalvą, naudojamą `resize_and_pad`

Vips naudoja juodą kaip numatytąją fono spalvą `resize_and_pad`, o ne baltą kaip ImageMagick. Tai ištaisykite naudodami `background` parinktį:

```diff
- variant(resize_and_pad: [300, 300])
+ variant(resize_and_pad: [300, 300, background: [255]])
```

#### Pašalinkite bet kokį EXIF pagrįstą pasukimą

Vips automatiškai pasuka paveikslėlius naudodamas EXIF reikšmę apdorojant variantus. Jei buvote saugoję pasukimo reikšmes iš naudotojo įkeltų nuotraukų, kad galėtumėte pasukti su ImageMagick, turite tai liautis daryti:

```diff
- variant(format: :jpg, rotate: rotation_value)
+ variant(format: :jpg)
```

#### Pakeiskite monochrome į colourspace

Vips naudoja kitą parinktį, kad sukurtų monochrominius paveikslėlius:

```diff
- variant(monochrome: true)
+ variant(colourspace: "b-w")
```

#### Perjunkite į libvips parinktis paveikslėlių suspaudimui

JPEG

```diff
- variant(strip: true, quality: 80, interlace: "JPEG", sampling_factor: "4:2:0", colorspace: "sRGB")
+ variant(saver: { strip: true, quality: 80, interlace: true })
```

PNG

```diff
- variant(strip: true, quality: 75)
+ variant(saver: { strip: true, compression: 9 })
```

WEBP

```diff
- variant(strip: true, quality: 75, define: { webp: { lossless: false, alpha_quality: 85, thread_level: 1 } })
+ variant(saver: { strip: true, quality: 75, lossless: false, alpha_q: 85, reduction_effort: 6, smart_subsample: true })
```

GIF

```diff
- variant(layers: "Optimize")
+ variant(saver: { optimize_gif_frames: true, optimize_gif_transparency: true })
```

#### Diegimas į produkciją

Active Storage koduoja į nuotraukos URL sąrašą transformacijų, kurias reikia atlikti.
Jei jūsų programa talpina šiuos URL, po naujo kodo diegimo į produkciją jūsų paveikslėliai suges.
Dėl šios priežasties turite rankiniu būdu atnaujinti paveiktus talpyklos raktus.

Pavyzdžiui, jei jūsų rodinyje yra kažkas panašaus:

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= image_tag product.cover_photo.variant(resize: "200x") %>
  <% end %>
<% end %>
```

Galite atnaujinti talpyklą palietę produktą arba pakeisdami talpyklos raktą:

```erb
<% @products.each do |product| %>
  <% cache ["v2", product] do %>
    <%= image_tag product.cover_photo.variant(resize_to_limit: [200, nil]) %>
  <% end %>
<% end %>
```

### Rails versija dabar įtraukta į Active Record schemos iškėlimą

Rails 7.0 pakeitė kai kurių stulpelių tipų numatytąsias reikšmes. Kad išvengtumėte to, kad 6.1 versijos programa atnaujintų į 7.0
įkeliant dabartinę schemą naudojant naujas 7.0 numatytąsias reikšmes, Rails dabar įtraukia versiją į schemos iškėlimą.

Prieš pirmą kartą įkeliant schemą į Rails 7.0, įsitikinkite, kad paleidote `rails app:update`, kad būtų įtraukta schemos versija į schemos iškėlimą.

Schemos failas atrodys taip:

```ruby
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[6.1].define(version: 2022_01_28_123512) do
```
PASTABA: Pirmą kartą išmetus schemą su „Rails 7.0“, matysite daugybę pakeitimų šiam failui, įskaitant kai kurią stulpelių informaciją. Įsitikinkite, kad peržiūrite naujo schemos failo turinį ir jį įtraukiate į savo saugyklą.

Atnaujinimas nuo „Rails 6.0“ iki „Rails 6.1“
-------------------------------------

Daugiau informacijos apie „Rails 6.1“ pakeitimus rasite [leidimo pastabose](6_1_release_notes.html).

### `Rails.application.config_for` grąžinimo reikšmė nebeturi palaikyti prieigos su eilutės raktais.

Turint konfigūracijos failą, panašų į šį:

```yaml
# config/example.yml
development:
  options:
    key: value
```

```ruby
Rails.application.config_for(:example).options
```

Anksčiau tai grąžindavo „hash“, kurio reikšmes galėjote pasiekti su eilutės raktais. Tai buvo pasenusi nuo „6.0“ versijos ir dabar nebeveikia.

Jei vis dar norite pasiekti reikšmes su eilutės raktais, galite prie grąžinimo reikšmės iškvietimo „config_for“ pridėti „with_indifferent_access“, pvz.:

```ruby
Rails.application.config_for(:example).with_indifferent_access.dig('options', 'key')
```

### Atsakymo „Content-Type“ naudojant `respond_to#any`

Atsakyme grąžinamas „Content-Type“ antraštė gali skirtis nuo to, ką grąžino „Rails 6.0“, ypač jei jūsų programa naudoja `respond_to { |format| format.any }`. „Content-Type“ dabar bus pagrįstas nurodytu bloku, o ne užklausos formato.

Pavyzdys:

```ruby
def my_action
  respond_to do |format|
    format.any { render(json: { foo: 'bar' }) }
  end
end
```

```ruby
get('my_action.csv')
```

Anksčiau elgesys grąžindavo „text/csv“ atsakymo „Content-Type“, kuris yra neteisingas, nes yra atvaizduojamas JSON atsakymas. Dabartinis elgesys teisingai grąžina „application/json“ atsakymo „Content-Type“.

Jei jūsų programa priklauso nuo ankstesnio neteisingo elgesio, rekomenduojama nurodyti, kokius formatus priima jūsų veiksmas, t. y.

```ruby
format.any(:xml, :json) { render request.format.to_sym => @people }
```

### `ActiveSupport::Callbacks#halted_callback_hook` dabar gauna antrąjį argumentą

„Active Support“ leidžia perrašyti „halted_callback_hook“, kai koks nors „callback“ sustabdo grandinę. Šis metodas dabar gauna antrąjį argumentą, kuris yra sustabdyto „callback“ pavadinimas. Jei turite klases, kurios perrašo šį metodą, įsitikinkite, kad jis priima du argumentus. Atkreipkite dėmesį, kad tai yra pakeitimas, kuris nėra ankstesnio pasenusio laikotarpio (dėl našumo priežasčių).

Pavyzdys:

```ruby
class Book < ApplicationRecord
  before_save { throw(:abort) }
  before_create { throw(:abort) }

  def halted_callback_hook(filter, callback_name) # => Šis metodas dabar priima 2 argumentus vietoje 1
    Rails.logger.info("Knyga negalėjo būti #{callback_name}d")
  end
end
```

### Valdiklių „helper“ klasės metodas naudoja „String#constantize“

Konceptualiai, prieš „Rails 6.1“

```ruby
helper "foo/bar"
```

rezultavo

```ruby
require_dependency "foo/bar_helper"
module_name = "foo/bar_helper".camelize
module_name.constantize
```

Dabar jis daro tai:

```ruby
prefix = "foo/bar".camelize
"#{prefix}Helper".constantize
```

Šis pakeitimas yra suderinamas su ankstesnėmis versijomis daugumai programų, todėl jums nereikia nieko daryti.

Techniškai, tačiau, valdikliai galėjo sukonfigūruoti „helpers_path“, kad rodytų į katalogą „$LOAD_PATH“, kuris nebuvo įkeltas automatiškai. Šis naudojimo atvejis daugiau nebegalioja. Jei pagalbinė modulio dalis nėra automatiškai įkeliamas, programa privalo jį įkelti prieš iškviečiant „helper“.

### Nukreipimas į HTTPS iš HTTP dabar naudoja 308 HTTP būsenos kodą

Numatytasis HTTP būsenos kodas, naudojamas „ActionDispatch::SSL“ nukreipiant ne-GET/HEAD užklausas iš HTTP į HTTPS, buvo pakeistas į „308“, kaip apibrėžta https://tools.ietf.org/html/rfc7538.

### „Active Storage“ dabar reikalauja vaizdo apdorojimo

Apdorojant variantus „Active Storage“, dabar reikalingas [image_processing gem](https://github.com/janko/image_processing) vietoj tiesioginio „mini_magick“ naudojimo. „Image Processing“ pagal numatymą sukonfigūruotas naudoti „mini_magick“ užkulisiuose, todėl paprasčiausias būdas atnaujinti yra pakeisti „mini_magick“ gemą į „image_processing“ gemą ir įsitikinti, kad pašalintas „combine_options“ aiškus naudojimas, nes jis nebenaudojamas.

Dėl skaitomumo galite pakeisti tiesioginius „resize“ iškvietimus į „image_processing“ makro. Pavyzdžiui, vietoj:

```ruby
video.preview(resize: "100x100")
video.preview(resize: "100x100>")
video.preview(resize: "100x100^")
```

galite atitinkamai daryti:

```ruby
video.preview(resize_to_fit: [100, 100])
video.preview(resize_to_limit: [100, 100])
video.preview(resize_to_fill: [100, 100])
```

### Nauja „ActiveModel::Error“ klasė

Dabar klaidos yra naujos „ActiveModel::Error“ klasės egzemplioriai, su API pakeitimais. Kai kurie iš šių pakeitimų gali sukelti klaidas, priklausomai nuo to, kaip manipuliuojate klaidomis, o kiti spausdins pasenusius įspėjimus, kurie turi būti ištaisyti „Rails 7.0“.

Daugiau informacijos apie šį pakeitimą ir API pakeitimų detales rasite [šiame PR](https://github.com/rails/rails/pull/32313).

Atnaujinimas nuo „Rails 5.2“ iki „Rails 6.0“
-------------------------------------

Daugiau informacijos apie „Rails 6.0“ pakeitimus rasite [leidimo pastabose](6_0_release_notes.html).

### Naudodami „Webpacker“
[Webpacker](https://github.com/rails/webpacker)
yra numatytasis JavaScript kompiliatorius „Rails“ 6. Tačiau, jei atnaujinote programą, jis nebus įjungtas pagal numatytuosius nustatymus.
Jei norite naudoti „Webpacker“, įtraukite jį į savo Gemfile ir įdiekite:

```ruby
gem "webpacker"
```

```bash
$ bin/rails webpacker:install
```

### Priverstinis SSL

Kontrolerių „force_ssl“ metodas yra pasenus ir bus pašalintas
„Rails“ 6.1 versijoje. Rekomenduojama įjungti [`config.force_ssl`][] norint priversti HTTPS
ryšius visoje jūsų programoje. Jei reikia atleisti tam tikrus galutinius taškus
nuo peradresavimo, galite naudoti [`config.ssl_options`][] norėdami konfigūruoti šį elgesį.


### Tikslas ir galiojimo laikas dabar įterpti į pasirašytus ir užšifruotus slapukus, siekiant padidinti saugumą

Siekiant padidinti saugumą, „Rails“ įterpia tikslą ir galiojimo laiką į užšifruotą ar pasirašytą slapuko reikšmę.

Taip „Rails“ gali apginti nuo atakų, kurios bando nukopijuoti pasirašytos/užšifruotos slapuko reikšmę
ir naudoti ją kaip kitos slapuko reikšmę.

Šie nauji įterpti metaduomenys padaro tuos slapukus nesuderinamus su „Rails“ versijomis senesnėmis nei 6.0.

Jei norite, kad jūsų slapukai būtų skaityti „Rails“ 5.2 ir senesnėse versijose arba vis dar patvirtinate savo 6.0 diegimą ir norite
galėti atšaukti, nustatykite
`Rails.application.config.action_dispatch.use_cookies_with_metadata` į `false`.

### Visi „npm“ paketai perkelti į `@rails` sritį

Jei anksčiau įkėlėte „actioncable“, „activestorage“ ar „rails-ujs“ paketus per „npm/yarn“, turite atnaujinti šių
priklausomybių pavadinimus, prieš juos galėdami atnaujinti į `6.0.0`:

```
actioncable   → @rails/actioncable
activestorage → @rails/activestorage
rails-ujs     → @rails/ujs
```

### Veiksmų kanalo JavaScript API pakeitimai

Veiksmų kanalo JavaScript paketas buvo konvertuotas iš „CoffeeScript“
į ES2015, ir dabar mes publikuojame šaltinio kodą „npm“ platinime.

Šis leidimas apima keletą pakeitimų neprivalomoms veiksmų kanalo JavaScript API dalims:

- WebSocket adapterio ir žurnalo adapterio konfigūracija buvo perkelta
  iš `ActionCable` savybių į `ActionCable.adapters` savybes.
  Jei konfigūruojate šiuos adapterius, turėsite atlikti
  šiuos pakeitimus:

    ```diff
    -    ActionCable.WebSocket = MyWebSocket
    +    ActionCable.adapters.WebSocket = MyWebSocket
    ```

    ```diff
    -    ActionCable.logger = myLogger
    +    ActionCable.adapters.logger = myLogger
    ```

- `ActionCable.startDebugging()` ir `ActionCable.stopDebugging()`
  metodai buvo pašalinti ir pakeisti savybe
  `ActionCable.logger.enabled`. Jei naudojate šiuos metodus, jums
  reikės atlikti šiuos pakeitimus:

    ```diff
    -    ActionCable.startDebugging()
    +    ActionCable.logger.enabled = true
    ```

    ```diff
    -    ActionCable.stopDebugging()
    +    ActionCable.logger.enabled = false
    ```

### `ActionDispatch::Response#content_type` dabar grąžina „Content-Type“ antraštės reikšmę be pakeitimų

Anksčiau, `ActionDispatch::Response#content_type` grąžinimo reikšmė NĖRA apėmė koduotės dalies.
Šis elgesys pasikeitė, įtraukiant anksčiau praleistą koduotės dalį.

Jei norite tik MIME tipo, naudokite `ActionDispatch::Response#media_type` vietoj to.

Anksčiau:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present"
```

Po:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present; charset=utf-16"
resp.media_type   #=> "text/csv"
```

### Naujas `config.hosts` nustatymas

„Rails“ dabar turi naują `config.hosts` nustatymą saugumo tikslais. Šis nustatymas
numatytuoju atveju yra `localhost` vystyme. Jei vystyme naudojate kitus domenus
jums reikia juos leisti taip:

```ruby
# config/environments/development.rb

config.hosts << 'dev.myapp.com'
config.hosts << /[a-z0-9-]+\.myapp\.com/ # Galima naudoti ir reguliarius išraiškas
```

Kitoms aplinkoms `config.hosts` numatytuoju atveju yra tuščias, tai reiškia, kad „Rails“
nevaliduos šeimininko visai. Galite juos papildomai pridėti, jei norite
patikrinti jį produkcijoje.

### Automatinis įkėlimas

Numatytasis „Rails“ 6 konfigūracija

```ruby
# config/application.rb

config.load_defaults 6.0
```

įjungia `zeitwerk` automatinio įkėlimo režimą „CRuby“. Šiuo režimu automatinis įkėlimas, perkrovimas ir įkėlimas pagal poreikį yra valdomi [Zeitwerk](https://github.com/fxn/zeitwerk).

Jei naudojate numatytuosius nustatymus iš ankstesnės „Rails“ versijos, galite įjungti „zeitwerk“ taip:

```ruby
# config/application.rb

config.autoloader = :zeitwerk
```

#### Viešasis API

Bendrai, programos neturėtų naudoti Zeitwerk API tiesiogiai. „Rails“ nustato dalykus pagal esamą sutartį: `config.autoload_paths`, `config.cache_classes`, ir kt.

Nors programos turėtų laikytis tos sąsajos, faktinis Zeitwerk įkėlimo objektas gali būti pasiekiamas kaip

```ruby
Rails.autoloaders.main
```

Tai gali būti naudinga, jei reikia iš anksto įkelti vienos lentelės paveldėjimo (STI) klases arba konfigūruoti pasirinktinį inflektorius, pavyzdžiui.

#### Projekto struktūra

Jei atnaujinama programa tinkamai įkelia, projekto struktūra turėtų jau būti beveik suderinama. 

Tačiau „klasikinė“ režimas išvestų failo pavadinimus iš praleistų konstantų pavadinimų (`underscore`), o „zeitwerk“ režimas išvestų konstantų pavadinimus iš failo pavadinimų (`camelize`). Šie pagalbininkai ne visada yra vienas kitos atvirkštiniai, ypač jei yra akronimų. Pavyzdžiui, `"FOO".underscore` yra `"foo"`, bet `"foo".camelize` yra `"Foo"`, o ne `"FOO"`.
Suderinamumą galima patikrinti naudojant `zeitwerk:check` užduotį:

```bash
$ bin/rails zeitwerk:check
Palaukite, aš įkeliamas programos.
Viskas gerai!
```

#### require_dependency

Visi žinomi `require_dependency` naudojimo atvejai buvo pašalinti, jums reikėtų peržiūrėti projektą ir juos ištrinti.

Jei jūsų programa naudoja vienos lentelės paveldėjimą, žiūrėkite [Vienos lentelės paveldėjimo skyrių](autoloading_and_reloading_constants.html#single-table-inheritance) Autoloading and Reloading Constants (Zeitwerk Mode) vadove.

#### Kvalifikuoti pavadinimai klasėse ir moduliuose

Dabar galite tvirtai naudoti konstantų kelius klasėse ir moduliuose:

```ruby
# Autoloading šios klasės kūne dabar atitinka Ruby semantiką.
class Admin::UsersController < ApplicationController
  # ...
end
```

Reikia atkreipti dėmesį, kad priklausomai nuo vykdymo tvarkos, klasikinis autokroviklis kartais galėjo automatiškai įkelti `Foo::Wadus`:

```ruby
class Foo::Bar
  Wadus
end
```

Tai neatitinka Ruby semantikos, nes `Foo` nėra įdėjime, ir visiškai neveiks `zeitwerk` režime. Jei rastumėte tokį atvejį, galite naudoti kvalifikuotą pavadinimą `Foo::Wadus`:

```ruby
class Foo::Bar
  Foo::Wadus
end
```

arba pridėti `Foo` į įdėjimą:

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

#### Susirūpinimai

Galite automatiškai įkelti ir įkrauti iš standartinės struktūros, pavyzdžiui

```
app/models
app/models/concerns
```

Tuo atveju `app/models/concerns` laikoma šakniniu katalogu (nes ji priklauso autokrovimo keliams) ir ignoruojama kaip vardų erdvė. Taigi, `app/models/concerns/foo.rb` turėtų apibrėžti `Foo`, o ne `Concerns::Foo`.

`Concerns::` vardų erdvė veikė su klasikiniu autokrovikliu kaip šalutinis efektas, bet tai iš tikrųjų nebuvo numatyta elgsena. Programa, naudojanti `Concerns::`, turi pervadinti tuos metodus ir modulius, kad galėtų veikti `zeitwerk` režime.

#### `app` įkrovimo keliuose turėti

Kai kurie projektai nori, kad `app/api/base.rb` apibrėžtų `API::Base`, ir prideda `app` į įkrovimo kelius, kad tai pasiektų klasikiniame režime. Kadangi „Rails“ automatiškai prideda visus `app` poaplankius į įkrovimo kelius, turime dar vieną situaciją, kai yra įdėti įdėjimai su įdėjimais, todėl ši sąranka nebeveikia. Panašus principas, kurį paaiškinome aukščiau su `susirūpinimais`.

Jei norite išlaikyti tą struktūrą, turėsite ištrinti poaplankį iš įkrovimo kelių inicializavimo metu:

```ruby
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/api")
```

#### Automatiškai įkrauti konstantas ir aiškios vardų erdvės

Jei vardų erdvė yra apibrėžta faile, kaip čia yra `Hotel`:

```
app/models/hotel.rb         # Apibrėžia Hotel.
app/models/hotel/pricing.rb # Apibrėžia Hotel::Pricing.
```

`Hotel` konstanta turi būti nustatyta naudojant `class` arba `module` raktažodžius. Pavyzdžiui:

```ruby
class Hotel
end
```

yra gerai.

Alternatyvos, tokios kaip

```ruby
Hotel = Class.new
```

arba

```ruby
Hotel = Struct.new
```

neveiks, vaikinės objektai, tokie kaip `Hotel::Pricing`, nebus rasti.

Šis apribojimas taikomas tik aiškioms vardų erdvėms. Klasės ir moduliai, kurie neapibrėžia vardų erdvės, gali būti apibrėžti naudojant tuos idiomus.

#### Vienas failas, viena konstanta (tame pačiame viršutiniame lygyje)

Klasikiniame režime techniškai galėjote apibrėžti kelias konstantas tame pačiame viršutiniame lygyje ir visus juos perkrauti. Pavyzdžiui, turint

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

nors `Bar` negalėjo būti automatiškai įkeltas, automatiškai įkeliant `Foo`, `Bar` taip pat būtų pažymėtas kaip automatiškai įkeltas. Taip nėra `zeitwerk` režime, jums reikia perkelti `Bar` į savo atskirą failą `bar.rb`. Vienas failas, viena konstanta.

Tai taikoma tik konstantoms tame pačiame viršutiniame lygyje, kaip pavyzdyje aukščiau. Vidinės klasės ir moduliai yra geri. Pavyzdžiui, apsvarstykite

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

Jei programa perkrauna `Foo`, ji taip pat perkraus `Foo::InnerClass`.

#### Spring ir `test` aplinka

Spring perkrauna programos kodą, jei kažkas pasikeičia. `test` aplinkoje jums reikia įjungti perkrovimą, kad tai veiktų:

```ruby
# config/environments/test.rb

config.cache_classes = false
```

Kitu atveju gausite šią klaidą:

```
perkrovimas išjungtas, nes config.cache_classes yra true
```

#### Bootsnap

Bootsnap turi būti bent versijos 1.4.2.

Be to, Bootsnap turi išjungti iseq kešą dėl interpretatoriaus klaidos, jei naudojate „Ruby“ 2.5. Įsitikinkite, kad priklausote bent jau nuo Bootsnap 1.4.4.

#### `config.add_autoload_paths_to_load_path`

Naujoji konfigūracijos vieta [`config.add_autoload_paths_to_load_path`][] yra `true` pagal numatytuosius nustatymus, tačiau leidžia jums atsisakyti pridėti įkrovimo kelius į `$LOAD_PATH`.

Tai tinka daugumai programų, nes niekada neturėtumėte reikalauti failo `app/models`, pavyzdžiui, ir Zeitwerk viduje naudoja tik absoliučius failo pavadinimus.
Pasirinkdami "opt-out" galite optimizuoti `$LOAD_PATH` paieškas (mažiau katalogų, kuriuos reikia tikrinti) ir taip sutaupyti Bootsnap darbo ir atminties, nes nereikia sukurti indekso šiems katalogams.

#### Gijų saugumas

Klasikiniame režime konstantų automatinis įkėlimas nėra saugus gijoms, nors "Rails" turi užraktus, pavyzdžiui, kad padarytų interneto užklausas saugias gijoms, kai įgalintas automatinis įkėlimas, kaip tai yra įprasta vystymo aplinkoje.

`Zeitwerk` režime konstantų automatinis įkėlimas yra saugus gijoms. Pavyzdžiui, dabar galite automatiškai įkelti daugiausiai gijų vykdomus scenarijus, naudojamus `runner` komanda.

#### Globai `config.autoload_paths`

Atkreipkite dėmesį į konfigūracijas, tokias kaip

```ruby
config.autoload_paths += Dir["#{config.root}/lib/**/"]
```

Kiekvienas `config.autoload_paths` elementas turėtų atitikti viršutinį lygio vardų erdvės (`Object`) ir jie negali būti įdėti vienas į kitą (išskyrus aukščiau paaiškintus `concerns` katalogus).

Norėdami tai ištaisyti, tiesiog pašalinkite žvaigždutes:

```ruby
config.autoload_paths << "#{config.root}/lib"
```

#### Ankstyvasis įkėlimas ir automatinis įkėlimas yra nuoseklūs

Klasikiniame režime, jei `app/models/foo.rb` apibrėžia `Bar`, jūs negalėsite automatiškai įkelti to failo, bet ankstyvasis įkėlimas veiks, nes jis rekursyviai įkelia failus. Tai gali būti klaidų šaltinis, jei pirmiausia testuojate dalykus ankstyvuoju įkėlimu, vykdymas gali nepavykti vėliau automatinio įkėlimo metu.

`Zeitwerk` režime abu įkėlimo režimai yra nuoseklūs, jie klaidingi ir klaidingi tais pačiais failais.

#### Kaip naudoti klasikinį įkėlėją "Rails" 6

Programos gali įkelti "Rails" 6 numatytuosius nustatymus ir vis dar naudoti klasikinį įkėlėją, nustatydamos `config.autoloader` taip:

```ruby
# config/application.rb

config.load_defaults 6.0
config.autoloader = :classic
```

Naudojant klasikinį įkėlėją "Rails" 6 programoje rekomenduojama nustatyti vieningumo lygį 1 vystymo aplinkoje, interneto serveriams ir fono procesoriams dėl gijų saugumo problemų.

### "Active Storage" priskyrimo elgsenos pakeitimas

Su "Rails" 5.2 konfigūracijos numatytuoju nustatymu, priskiriant prie `has_many_attached` deklaruotos priedų kolekcijos, nauji failai yra pridedami:

```ruby
class User < ApplicationRecord
  has_many_attached :highlights
end

user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

Su "Rails" 6.0 konfigūracijos numatytuoju nustatymu, priskiriant prie `has_many_attached` deklaruotos priedų kolekcijos, esami failai yra pakeičiami vietoje to, kad būtų pridedami prie jų. Tai atitinka "Active Record" elgesį, kai priskiriama kolekcijos asociacija:

```ruby
user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 1
user.highlights.first.filename # => "town.jpg"
```

`#attach` gali būti naudojamas norint pridėti naujus priedus, nenaikinant esamų:

```ruby
blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.highlights.attach(blob)

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

Esamos programos gali įjungti šį naują elgesį nustatydamos [`config.active_storage.replace_on_assign_to_many`][] į `true`. Senas elgesys bus pasenus "Rails" 7.0 ir pašalintas "Rails" 7.1.

### Individualių išimčių tvarkymo programos

Netinkami `Accept` arba `Content-Type` užklausos antraštės dabar sukels išimtį. Numatytasis [`config.exceptions_app`][] ypač tvarko šią klaidą ir kompensuoja ją. Individualios išimčių programos taip pat turės tvarkyti šią klaidą, arba tokioms užklausoms "Rails" naudos atsarginę išimčių programą, kuri grąžins `500 Vidinės serverio klaidos` klaidą.

Atnaujinimas nuo "Rails" 5.1 iki "Rails" 5.2
--------------------------------------------

Norėdami gauti daugiau informacijos apie "Rails" 5.2 atliktus pakeitimus, žr. [leidimo pastabas](5_2_release_notes.html).

### Bootsnap

"Rails" 5.2 prideda "bootsnap" juostą [naujai sugeneruotame programos Gemfile](https://github.com/rails/rails/pull/29313).
`app:update` komanda ją nustato `boot.rb`. Jei norite ją naudoti, pridėkite ją į Gemfile:

```ruby
# Sumažina paleidimo laiką per kešavimą; reikalinga config/boot.rb
gem 'bootsnap', require: false
```

Kitu atveju pakeiskite `boot.rb`, kad nebūtų naudojamas "bootsnap".

### Galiojimo laikas pasirašytame arba užšifruotame slapukų yra įterptas į slapukų reikšmes

Dėl saugumo pagerinimo "Rails" dabar įterpia galiojimo informaciją taip pat į užšifruotus arba pasirašytus slapukus.

Ši nauja įterpta informacija padaro tuos slapukus nesuderinamus su "Rails" versijomis senesnėmis nei 5.2.

Jei jūsų slapukai turi būti skaityti 5.1 ir senesnėmis versijomis arba jei vis dar tikrinat savo 5.2 diegimą ir norite leisti atšaukimą, nustatykite
`Rails.application.config.action_dispatch.use_authenticated_cookie_encryption` į `false`.

Atnaujinimas nuo "Rails" 5.0 iki "Rails" 5.1
--------------------------------------------

Norėdami gauti daugiau informacijos apie "Rails" 5.1 atliktus pakeitimus, žr. [leidimo pastabas](5_1_release_notes.html).

### Viršutinė `HashWithIndifferentAccess` klasė yra minkštas pasenusi

Jei jūsų programa naudoja viršutinę `HashWithIndifferentAccess` klasę, turėtumėte palaipsniui perjungti savo kodą, kad vietoj to naudotumėte `ActiveSupport::HashWithIndifferentAccess`.
Tai tik minkštas pasenusis, tai reiškia, kad jūsų kodas šiuo metu nebus sugadintas ir nebus rodomas joks pasenusio naudojimo įspėjimas, bet ši konstanta bus pašalinta ateityje.

Taip pat, jei turite gana senus YAML dokumentus, kuriuose yra tokių objektų iškrovimai, gali prireikti juos įkelti ir iškrauti iš naujo, kad būtų užtikrinta, jog jie nurodo teisingą konstantą ir kad juos įkelti ateityje nesugadins.

### `application.secrets` dabar įkeliamos visos raktai kaip simboliai

Jei jūsų programa saugo sudėtingą konfigūraciją `config/secrets.yml`, visi raktai dabar įkeliami kaip simboliai, todėl prieiga naudojant eilutes turėtų būti pakeista.

Iš:

```ruby
Rails.application.secrets[:smtp_settings]["address"]
```

Į:

```ruby
Rails.application.secrets[:smtp_settings][:address]
```

### Pašalintas pasenusi palaikymas `:text` ir `:nothing` `render` funkcijoje

Jei jūsų valdikliai naudoja `render :text`, jie nebeveiks. Naujas būdas atvaizduoti tekstą su MIME tipo `text/plain` yra naudoti `render :plain`.

Panašiai, `render :nothing` taip pat pašalintas ir turėtumėte naudoti `head` metodą, kad siųstumėte atsakymus, kuriuose yra tik antraštės. Pavyzdžiui, `head :ok` siunčia 200 atsakymą be kūno, kuris bus atvaizduotas.

### Pašalintas pasenusi palaikymas `redirect_to :back`

Rails 5.0 versijoje `redirect_to :back` buvo pasenusi. Rails 5.1 versijoje ji buvo visiškai pašalinta.

Kaip alternatyvą, naudokite `redirect_back`. Svarbu pažymėti, kad `redirect_back` taip pat priima `fallback_location` parinktį, kuri bus naudojama, jei trūksta `HTTP_REFERER`.

```ruby
redirect_back(fallback_location: root_path)
```


Atnaujinimas nuo Rails 4.2 iki Rails 5.0
-------------------------------------

Daugiau informacijos apie pakeitimus, įvykdytus Rails 5.0, rasite [leidimo pastabose](5_0_release_notes.html).

### Reikalingas Ruby 2.2.2+ versija

Nuo Ruby on Rails 5.0 versijos, tik Ruby 2.2.2+ versija yra palaikoma.
Įsitikinkite, kad naudojate Ruby 2.2.2 versiją ar naujesnę, prieš tęsdami.

### Aktyvūs įrašų modeliai dabar paveldi nuo ApplicationRecord pagal numatytuosius nustatymus

Rails 4.2 versijoje Aktyvūs įrašų modeliai paveldi nuo `ActiveRecord::Base`. Rails 5.0 versijoje visi modeliai paveldi nuo `ApplicationRecord`.

`ApplicationRecord` yra naujas viršklas visiems programos modeliams, panašus į programos valdiklius, kurie paveldi nuo `ApplicationController`, o ne nuo `ActionController::Base`. Tai suteikia programoms vieną vietą, kur galima konfigūruoti visoje programoje taikomą modelio elgesį.

Kai atnaujinamas nuo Rails 4.2 iki Rails 5.0, jums reikia sukurti `application_record.rb` failą `app/models/` aplanke ir pridėti šią turinį:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

Tada įsitikinkite, kad visi jūsų modeliai paveldi nuo šio modelio.

### Sustabdantys atgalinės iškvietimo grandinės per `throw(:abort)`

Rails 4.2 versijoje, kai "before" iškvietimas grąžina `false` Aktyvūs įrašai ir Aktyvūs modeliai, tada visa iškvietimo grandinė yra sustabdoma. Kitaip tariant, sekantys "before" iškvietimai nevykdomi, ir taip pat nevykdoma veiksmas, apgaubtas iškvietimais.

Rails 5.0 versijoje, grąžinant `false` Aktyvūs įrašų ar Aktyvūs modelių iškvietime, nebus šio sustabdymo poveikio iškvietimo grandinei. Vietoj to, iškvietimo grandinės turi būti aiškiai sustabdomos, iškviečiant `throw(:abort)`.

Kai atnaujinamas nuo Rails 4.2 iki Rails 5.0, grąžinant `false` tokiuose iškvietimuose vis tiek sustabdys iškvietimo grandinę, bet gausite įspėjimą apie šį artėjantį pakeitimą.

Kai būsite pasiruošę, galite pasirinkti naują elgesį ir pašalinti įspėjimą apie pasenusį naudojimą, pridėdami šią konfigūraciją į savo `config/application.rb`:

```ruby
ActiveSupport.halt_callback_chains_on_return_false = false
```

Reikia pažymėti, kad ši parinktis neturės įtakos Aktyviosios paramos iškvietimams, nes jie niekada nesustabdė grandinės, kai buvo grąžinta bet kokia reikšmė.

Daugiau informacijos rasite [#17227](https://github.com/rails/rails/pull/17227).

### ActiveJob dabar paveldi nuo ApplicationJob pagal numatytuosius nustatymus

Rails 4.2 versijoje Aktyvusis darbas paveldi nuo `ActiveJob::Base`. Rails 5.0 versijoje šis elgesys pasikeitė ir dabar paveldi nuo `ApplicationJob`.

Kai atnaujinamas nuo Rails 4.2 iki Rails 5.0, jums reikia sukurti `application_job.rb` failą `app/jobs/` aplanke ir pridėti šią turinį:

```ruby
class ApplicationJob < ActiveJob::Base
end
```

Tada įsitikinkite, kad visos jūsų darbo klasės paveldi nuo šio modelio.

Daugiau informacijos rasite [#19034](https://github.com/rails/rails/pull/19034).

### Rails valdiklių testavimas

#### Kai kurių pagalbinių metodų išskyrimas į `rails-controller-testing`

`assigns` ir `assert_template` buvo išskirti į `rails-controller-testing` gemą. Norėdami toliau naudoti šiuos metodus savo valdiklių testuose, pridėkite `gem 'rails-controller-testing'` į savo `Gemfile`.

Jei naudojate RSpec testavimui, prašome peržiūrėti papildomą konfigūraciją, reikalingą šiam gemui, dokumentacijoje.

#### Naujas elgesys įkeliant failus

Jei jūsų testuose naudojate `ActionDispatch::Http::UploadedFile` įkeliant failus, turėsite pakeisti ir naudoti panašią `Rack::Test::UploadedFile` klasę.
Daugiau informacijos rasite čia: [#26404](https://github.com/rails/rails/issues/26404).

### Automatinis įkėlimas išjungtas po paleidimo produkcinėje aplinkoje

Automatinis įkėlimas dabar yra išjungtas po paleidimo produkcinėje aplinkoje pagal nutylėjimą.

Programos įkėlimas yra dalis paleidimo proceso, todėl viršutinio lygio konstantos yra gerai ir vis dar yra automatiškai įkeliamos, nereikia reikalauti jų failų.

Konstantos giliau esančiose vietose, kurios yra vykdomos tik vykdymo metu, pavyzdžiui, įprasti metodų kūnai, taip pat yra gerai, nes jų apibrėžimo failas bus įkeltas paleidžiant.

Daugumai programų šis pakeitimas nereikalauja jokių veiksmų. Tačiau labai retais atvejais, kai jūsų programa turi automatinį įkėlimą veikiant produkcinėje aplinkoje, nustatykite `Rails.application.config.enable_dependency_loading` reikšmę kaip `true`.

### XML serializacija

`ActiveModel::Serializers::Xml` iš Rails buvo išskirta į `activemodel-serializers-xml` juostelę. Norėdami toliau naudoti XML serializaciją savo programoje, į `Gemfile` pridėkite `gem 'activemodel-serializers-xml'`.

### Pašalinta palaikymas senam `mysql` duomenų bazės adapteriui

Rails 5 pašalina palaikymą senam `mysql` duomenų bazės adapteriui. Dauguma vartotojų turėtų galėti naudoti `mysql2` adapterį. Kai rasime žmogų, kuris jį prižiūrės, jis bus konvertuotas į atskirą juostelę.

### Pašalintas palaikymas `debugger`

`debugger` nėra palaikomas Ruby 2.2, kuris yra reikalingas Rails 5. Vietoje jo naudokite `byebug`.

### Naudokite `bin/rails` užduočių ir testų vykdymui

Rails 5 leidžia vykdyti užduotis ir testus per `bin/rails`, o ne rake. Dauguma šių pakeitimų yra lygiaverčiai rake, tačiau kai kurie buvo visiškai perkelti.

Norėdami naudoti naują testų paleidimo priemonę, tiesiog įveskite `bin/rails test`.

`rake dev:cache` dabar yra `bin/rails dev:cache`.

Paleiskite `bin/rails` savo programos šakninėje direktorijoje, kad pamatytumėte galimų komandų sąrašą.

### `ActionController::Parameters` daugiau neįgyvendina `HashWithIndifferentAccess`

Kviečiant `params` savo programoje dabar bus grąžinamas objektas, o ne hash'as. Jei jūsų parametrai jau yra leidžiami, jums nereikės daryti jokių pakeitimų. Jei naudojate `map` ir kitus metodus, kurie priklauso nuo galimybės skaityti hash'ą nepriklausomai nuo `permitted?`, turėsite atnaujinti savo programą, kad pirmiausia leistumėte ir tada konvertuotumėte į hash'ą.

```ruby
params.permit([:proceed_to, :return_to]).to_h
```

### `protect_from_forgery` dabar pagal nutylėjimą yra `prepend: false`

`protect_from_forgery` pagal nutylėjimą yra `prepend: false`, tai reiškia, kad jis bus įterptas į atgalinį iškvietimo grandinę tuo metu, kai jį iškviečiate savo programoje. Jei norite, kad `protect_from_forgery` visada būtų vykdomas pirmiausia, turėtumėte pakeisti savo programą, kad naudotų `protect_from_forgery prepend: true`.

### Numatytasis šablonų tvarkyklės yra RAW

Failai be šablonų tvarkyklės savo plėtinio bus atvaizduojami naudojant RAW tvarkyklę. Anksčiau Rails failus atvaizdavo naudodamas ERB šablonų tvarkyklę.

Jei nenorite, kad jūsų failas būtų tvarkomas per RAW tvarkyklę, turėtumėte pridėti plėtinį prie savo failo, kurį galima analizuoti atitinkama šablonų tvarkykle.

### Pridėtas šablonų priklausomybių žymėjimas su šablonų žymėjimu

Dabar galite naudoti šablonų priklausomybių žymėjimą su žymėjimu. Pavyzdžiui, jei apibrėžiate šablonus taip:

```erb
<% # Šablonų priklausomybė: recordings/threads/events/subscribers_changed %>
<% # Šablonų priklausomybė: recordings/threads/events/completed %>
<% # Šablonų priklausomybė: recordings/threads/events/uncompleted %>
```

Dabar galite vieną kartą panaudoti šablonų priklausomybę su žymėjimu.

```erb
<% # Šablonų priklausomybė: recordings/threads/events/* %>
```

### `ActionView::Helpers::RecordTagHelper` perkelta į išorinę juostelę (record_tag_helper)

`content_tag_for` ir `div_for` buvo pašalinti naudoti vietoj jų tiesiog `content_tag`. Norėdami toliau naudoti senesnius metodus, į `Gemfile` pridėkite `record_tag_helper` juostelę:

```ruby
gem 'record_tag_helper', '~> 1.0'
```

Daugiau informacijos rasite čia: [#18411](https://github.com/rails/rails/pull/18411).

### Pašalintas palaikymas `protected_attributes` juostelei

`protected_attributes` juostelė daugiau nėra palaikoma Rails 5.

### Pašalintas palaikymas `activerecord-deprecated_finders` juostelei

`activerecord-deprecated_finders` juostelė daugiau nėra palaikoma Rails 5.

### `ActiveSupport::TestCase` numatytasis testų tvarka dabar yra atsitiktinė

Paleidžiant testus jūsų programoje, numatytasis tvarka dabar yra `:random`, o ne `:sorted`. Naudokite šią konfigūracijos parinktį, kad ją grąžintumėte į `:sorted`.

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted
end
```

### `ActionController::Live` tapo `Concern`

Jei įtraukiate `ActionController::Live` į kitą modulį, kuris yra įtrauktas į jūsų valdiklį, tuomet taip pat turėtumėte išplėsti modulį su `ActiveSupport::Concern`. Alternatyviai, galite naudoti `self.included` kabliuką, kad įtrauktumėte `ActionController::Live` tiesiogiai į valdiklį, kai įtraukiamas `StreamingSupport`.

Tai reiškia, kad jei jūsų programa anksčiau turėjo savo srautų modulį, šis kodas produkcijoje nebeveiktų:
```ruby
# Tai yra sprendimas, kaip valdyti autentifikaciją su Warden/Devise srautinėse valdiklių klasėse.
# Daugiau informacijos: https://github.com/plataformatec/devise/issues/2332
# Kitas sprendimas, kaip siūloma tame straipsnyje, yra autentifikuoti maršruteryje
class StreamingSupport
  include ActionController::Live # tai neveiks produkcijoje su Rails 5
  # extend ActiveSupport::Concern # jei atkomentuosite šią eilutę.

  def process(name)
    super(name)
  rescue ArgumentError => e
    if e.message == 'uncaught throw :warden'
      throw :warden
    else
      raise e
    end
  end
end
```

### Nauji pagrindiniai nustatymai

#### Pagal nutylėjimą privalomas `belongs_to` ryšys

Dabar, jei `belongs_to` ryšys nėra nurodytas, pagal nutylėjimą bus iškelta validacijos klaida.

Tai gali būti išjungta kiekvienam ryšiui naudojant `optional: true` parametrą.

Šis nustatymas automatiškai įjungiamas naujuose projektuose. Jei jau esamas projektas
norėtų naudoti šią funkciją, ji turi būti įjungta inicializuojant:

```ruby
config.active_record.belongs_to_required_by_default = true
```

Šis nustatymas pagal nutylėjimą taikomas visiems modeliams, bet jį galima
pakeisti kiekvienam modeliui atskirai. Tai padės migruoti visus modelius, kad jų
ryšiai būtų privalomi pagal nutylėjimą.

```ruby
class Book < ApplicationRecord
  # modelis dar nėra pasiruošęs, kad jo ryšys būtų privalomas pagal nutylėjimą

  self.belongs_to_required_by_default = false
  belongs_to(:author)
end

class Car < ApplicationRecord
  # modelis pasiruošęs, kad jo ryšys būtų privalomas pagal nutylėjimą

  self.belongs_to_required_by_default = true
  belongs_to(:pilot)
end
```

#### CSRF žetonai kiekvienam formai atskirai

Rails 5 dabar palaiko CSRF žetonus kiekvienai formai atskirai, kad būtų apsisaugota nuo kodo įterpimo atakų su JavaScript sukurtomis formomis.
Įjungus šią parinktį, kiekviena jūsų aplikacijos forma turės savo unikalų CSRF žetoną, kuris bus specifinis tam veiksmui ir metodui.

```ruby
config.action_controller.per_form_csrf_tokens = true
```

#### Apgaudinėjimo apsauga su `Origin` tikrinimu

Dabar galite konfigūruoti savo aplikaciją, kad būtų tikrinama, ar HTTP `Origin` antraštė atitinka svetainės kilmę, kaip papildoma apgaulės apsauga nuo CSRF. Nustatykite šį parametrą `true` savo konfigūracijoje:

```ruby
config.action_controller.forgery_protection_origin_check = true
```

#### Galimybė konfigūruoti veiksmų siuntimo eilės pavadinimą Action Mailer

Numatytasis el. pašto siuntimo eilės pavadinimas yra `mailers`. Šis konfigūracijos parametras leidžia globaliai pakeisti eilės pavadinimą. Nustatykite šį parametrą savo konfigūracijoje:

```ruby
config.action_mailer.deliver_later_queue_name = :new_queue_name
```

#### Fragmentų talpinimas Action Mailer peržiūros

Nustatykite [`config.action_mailer.perform_caching`][] savo konfigūracijoje, kad nuspręstumėte, ar jūsų Action Mailer peržiūros turėtų palaikyti talpinimą.

```ruby
config.action_mailer.perform_caching = true
```

#### Konfigūruoti `db:structure:dump` išvesties formatą

Jei naudojate `schema_search_path` ar kitas PostgreSQL plėtinius, galite valdyti, kaip yra išvedama schema. Nustatykite `:all`, jei norite generuoti visus išvedimus, arba `:schema_search_path`, jei norite generuoti iš schema paieškos kelio.

```ruby
config.active_record.dump_schemas = :all
```

#### Konfigūruoti SSL parinktis, kad būtų įjungtas HSTS su subdomenais

Nustatykite šį parametrą savo konfigūracijoje, kad įjungtumėte HSTS naudojant subdomenus:

```ruby
config.ssl_options = { hsts: { subdomains: true } }
```

#### Išsaugoti gavėjo laiko juostą

Naudojant Ruby 2.4, galite išsaugoti gavėjo laiko juostą, kai kviečiate `to_time` metodą.

```ruby
ActiveSupport.to_time_preserves_timezone = false
```

### Pakeitimai su JSON/JSONB serializacija

Rails 5.0 pakeitė, kaip yra serializuojami ir deserializuojami JSON/JSONB atributai. Dabar, jei nustatote stulpelį lygų `String`, Active Record jį nebeverčia į `Hash`, o grąžina tik stringą. Tai netaikoma tik modelių sąveikai su kodu, bet ir veikia `:default` stulpelių nustatymus `db/schema.rb` faile. Rekomenduojama nustatyti stulpelius lygius `Hash`, o ne `String`, kuris automatiškai bus konvertuojamas į JSON stringą ir atvirkščiai.

Atnaujinimas nuo Rails 4.1 iki Rails 4.2
-------------------------------------

### Web Console

Pirmiausia, pridėkite `gem 'web-console', '~> 2.0'` į `:development` grupę savo `Gemfile` faile ir paleiskite `bundle install` (jį nebuvo įtraukta atnaujinus Rails). Kai jis bus įdiegtas, galite tiesiog įterpti konsolės pagalbos nuorodą (pvz., `<%= console %>`) į bet kurį norimą peržiūrėti puslapį. Konsolė taip pat bus prieinama kiekviename klaidos puslapyje, kurį peržiūrite savo vystymo aplinkoje.

### Responders

`respond_with` ir klasės lygio `respond_to` metodai buvo išskirti į `responders` grotelę. Norėdami ją naudoti, tiesiog pridėkite `gem 'responders', '~> 2.0'` į savo `Gemfile`. Skambučiai į `respond_with` ir `respond_to` (vėlgi, klasės lygiu) nebeveiks, jei neįtrauksite `responders` grotelės į savo priklausomybes.
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

Atvejis `respond_to` lygmenyje nėra paveiktas ir nereikalauja papildomo gemo:

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

Daugiau informacijos rasite čia: [#16526](https://github.com/rails/rails/pull/16526).

### Klaidų tvarkymas transakcijos atgalinio iškvietimo metu

Šiuo metu, Active Record slopina klaidas, kurios iškyla `after_rollback` arba `after_commit` iškvietimo metu ir tik jas išveda į žurnalą. Kitos Active Record iškvietimo metu klaidos elgsis normaliai.

Kai apibrėžiate `after_rollback` arba `after_commit` iškvietimą, gausite įspėjimą apie šį artėjantį pakeitimą. Kai būsite pasiruošę, galite pasirinkti naują elgesį ir pašalinti įspėjimą pridedant šią konfigūraciją į savo `config/application.rb`:

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

Daugiau informacijos rasite čia: [#14488](https://github.com/rails/rails/pull/14488) ir
[#16537](https://github.com/rails/rails/pull/16537).

### Testų eiliškumas

Rails 5.0 versijoje, testai pagal nutylėjimą bus vykdomi atsitiktine tvarka. Norint pasiruošti šiam pakeitimui, Rails 4.2 versijoje buvo įvesta nauja konfigūracijos parinktis `active_support.test_order`, skirta išreiškiamai nurodyti testų eiliškumą. Tai leidžia užrakinti esamą elgesį nustatant parinktį į `:sorted`, arba pasirinkti ateities elgesį nustatant parinktį į `:random`.

Jei nenurodote reikšmės šiai parinkčiai, bus išvestas įspėjimas apie pasenusį kodą. Norėdami to išvengti, pridėkite šią eilutę į savo testų aplinką:

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # arba `:random`, jei pageidaujate
end
```

### Serializuotos atributai

Kai naudojate pasirinktinį koduotoją (pvz., `serialize :metadata, JSON`), priskyrus `nil` serializuotam atributui, jis bus išsaugotas duomenų bazėje kaip `NULL`, o ne perduotas per koduotoją (pvz., `"null"`, naudojant `JSON` koduotoją).

### Produkcinio žurnalo lygis

Rails 5 versijoje, produkcinėje aplinkoje numatytasis žurnalo lygis bus pakeistas į `:debug` (nuo `:info`). Norint išlaikyti esamą numatytąjį lygį, pridėkite šią eilutę į savo `production.rb`:

```ruby
# Nustatykite į `:info`, jei norite išlaikyti esamą numatytąjį lygį, arba į `:debug`, jei norite pasirinkti ateities numatytąjį lygį.
config.log_level = :info
```

### `after_bundle` Rails šablonuose

Jei turite Rails šabloną, kuris prideda visus failus į versijų kontrolę, jis nepavyksta pridėti sugeneruotų binstubų, nes vykdomas prieš Bundler:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```

Dabar galite apgaubti `git` iškvietimus `after_bundle` bloku. Jis bus vykdomas po to, kai binstubai bus sugeneruoti.

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

### Rails HTML Sanitizer

Jūsų programose yra naujas pasirinkimas HTML fragmentų sanitarizavimui. Senasis html-scanner metodas dabar oficialiai yra pasenus ir palaikomas [`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer).

Tai reiškia, kad metodai `sanitize`, `sanitize_css`, `strip_tags` ir `strip_links` yra paremti nauja implementacija.

Šis naujas sanitarizatorius naudoja [Loofah](https://github.com/flavorjones/loofah) viduje. Loofah savo ruožtu naudoja Nokogiri, kuris apgaubia C ir Java parašytus XML analizatorius, todėl sanitarizavimas turėtų būti greitesnis, nepriklausomai nuo naudojamos Ruby versijos.

Naujoji versija atnaujina `sanitize`, todėl ji gali priimti `Loofah::Scrubber` objektą galingam valymui.
[Šiame puslapyje galite pamatyti keletą valyklų pavyzdžių](https://github.com/flavorjones/loofah#loofahscrubber).

Taip pat buvo pridėtos dvi naujos valyklės: `PermitScrubber` ir `TargetScrubber`.
Daugiau informacijos rasite [gem'o aprašyme](https://github.com/rails/rails-html-sanitizer).

`PermitScrubber` ir `TargetScrubber` dokumentacija paaiškina, kaip galite gauti visišką kontrolę, kada ir kaip elementai turi būti pašalinti.

Jei jūsų programa turi naudoti senąjį sanitarizatoriaus įgyvendinimą, įtraukite `rails-deprecated_sanitizer` į savo `Gemfile`:

```ruby
gem 'rails-deprecated_sanitizer'
```

### Rails DOM testavimas

[`TagAssertions` modulis](https://api.rubyonrails.org/v4.1/classes/ActionDispatch/Assertions/TagAssertions.html) (kuris apima metodus, pvz., `assert_tag`) [yra pasenus](https://github.com/rails/rails/blob/6061472b8c310158a2a2e8e9a6b81a1aef6b60fe/actionpack/lib/action_dispatch/testing/assertions/dom.rb) ir palaikomas `assert_select` metodais iš `SelectorAssertions` modulio, kuris buvo išskirtas į [rails-dom-testing gemą](https://github.com/rails/rails-dom-testing).

### Maskuoti autentiškumo žetonus

Norint apsisaugoti nuo SSL atakų, `form_authenticity_token` dabar yra maskuojamas, kad jis keistųsi su kiekvienu užklausimu. Taigi, žetonus tikrina išmaskuojant ir tada iššifruojant. Dėl šios priežasties, bet kokie strategijos, skirtos patikrinti užklausas iš ne-Rails formų, kurios priklausė nuo statinio sesijos CSRF žetono, turi tai atsižvelgti.
### Veiksmo siuntėjas

Anksčiau, iškvietus siuntėjo metodo metodą siuntėjo klasėje, atitinkantis egzemplioriaus metodas buvo vykdomas tiesiogiai. Su įvedimu į veiksmo darbą ir `#deliver_later`, tai nebėra tiesa. „Rails“ 4.2 versijoje egzemplioriaus metodų iškvietimas yra atidėtas, kol bus iškviestas `deliver_now` arba `deliver_later`. Pavyzdžiui:

```ruby
class Notifier < ActionMailer::Base
  def notify(user, ...)
    puts "Iškviesta"
    mail(to: user.email, ...)
  end
end
```

```ruby
mail = Notifier.notify(user, ...) # Notifier#notify šiuo metu dar nebuvo iškviestas
mail = mail.deliver_now           # Spausdinama "Iškviesta"
```

Tai neturėtų sukelti jokių pastebimų skirtumų daugumai programų. Tačiau, jei jums reikia, kad kai kurie ne siuntėjo metodai būtų vykdomi sinchroniškai ir anksčiau priklausėte nuo sinchroninio perduodimo elgesio, turėtumėte juos apibrėžti kaip klasės metodus tiesiogiai siuntėjo klasėje:

```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users, ...)
    users.each { |user| Notifier.notify(user, ...) }
  end
end
```

### Užsienio rakto palaikymas

Migracijos DSL buvo išplėstas, kad būtų galima apibrėžti užsienio rakto apibrėžimus. Jei naudojote „Foreigner“ grotelę, galbūt norėsite ją pašalinti. Atkreipkite dėmesį, kad „Rails“ užsienio rakto palaikymas yra „Foreigner“ poaibis. Tai reiškia, kad ne kiekvienas „Foreigner“ apibrėžimas gali būti visiškai pakeistas „Rails“ migracijos DSL atitikmeniu.

Migracijos procedūra yra tokia:

1. pašalinkite `gem "foreigner"` iš `Gemfile`.
2. paleiskite `bundle install`.
3. paleiskite `bin/rake db:schema:dump`.
4. įsitikinkite, kad `db/schema.rb` yra kiekvienas užsienio rakto apibrėžimas su reikalingais parametrais.

Atnaujinimas nuo „Rails“ 4.0 iki „Rails“ 4.1
-------------------------------------

### CSRF apsauga nuo nuotolinio `<script>` žymų

Arba "kodėl mano testai nepavyksta !!!?" arba "mano `<script>` valdiklis sugadintas !!"

Tarp svetainių užklausos suklastojimo (CSRF) apsauga dabar taip pat apima GET užklausas su JavaScript atsakymais. Tai neleidžia trečiosioms šalims nuotoliniu būdu nuorodyti jūsų JavaScript su `<script>` žyma, kad išgautų jautrią informaciją.

Tai reiškia, kad jūsų funkciniams ir integraciniams testams, kurie naudoja

```ruby
get :index, format: :js
```

dabar bus įjungta CSRF apsauga. Pakeiskite į

```ruby
xhr :get, :index, format: :js
```

norėdami aiškiai patikrinti `XmlHttpRequest`.

PASTABA: Jūsų pačių `<script>` žymos taip pat yra laikomos kryžminės kilmės ir pagal numatytuosius nustatymus blokuojamos. Jei tikrai norite įkelti JavaScript iš `<script>` žymų, dabar turite išimtinai praleisti CSRF apsaugą šiuose veiksmuose.

### Pavasaris

Jei norite naudoti „Spring“ kaip savo programos įkroviklį, turite:

1. Pridėkite `gem 'spring', group: :development` į savo `Gemfile`.
2. Įdiekite pavasarį naudodami `bundle install`.
3. Sugeneruokite pavasario binstubą naudodami `bundle exec spring binstub`.

PASTABA: Vartotojo apibrėžti rake užduotys pagal numatytuosius nustatymus bus vykdomos `development` aplinkoje. Jei norite, kad jie vyktų kitose aplinkose, pasitarkite su [Pavasario README](https://github.com/rails/spring#rake).

### `config/secrets.yml`

Jei norite naudoti naują `secrets.yml` konvenciją savo programos paslaptims saugoti, turite:

1. Sukurkite `secrets.yml` failą savo `config` aplanke su šiuo turiniu:

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. Naudokite esamą `secret_key_base` iš `secret_token.rb` inicializatoriaus, kad nustatytumėte `SECRET_KEY_BASE` aplinkos kintamąjį tiems vartotojams, kurie paleidžia „Rails“ programą gamyboje. Alternatyviai, galite tiesiog nukopijuoti esamą `secret_key_base` iš `secret_token.rb` inicializatoriaus į `secrets.yml` po `production` skyriaus, pakeisdami `<%= ENV["SECRET_KEY_BASE"] %>`.

3. Pašalinkite `secret_token.rb` inicializatorių.

4. Naudokite `rake secret`, kad sugeneruotumėte naujus raktus `development` ir `test` skyriams.

5. Paleiskite serverį iš naujo.

### Pakeitimai testavimo pagalbininkui

Jei jūsų testavimo pagalbininke yra iškvietimas
`ActiveRecord::Migration.check_pending!`, jį galima pašalinti. Tikrinimas
dabar atliekamas automatiškai, kai reikia `require "rails/test_help"`, nors
šios eilutės palikimas jūsų pagalbininke nėra jokiu būdu kenksmingas.

### Slapukų serializatorius

Prieš „Rails“ 4.1 sukurtos programos naudoja `Marshal` slapukų reikšmių serializavimui į
pasirašytus ir užšifruotus slapukų indus. Jei norite savo programoje naudoti naują `JSON` pagrindo formatą,
galite pridėti inicializavimo failą su šiuo turiniu:

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

Tai automatiškai migruos jūsų esamus `Marshal` serializuotus slapukus į
naują `JSON` pagrindo formatą.

Naudojant `:json` arba `:hybrid` serializatorių, turėtumėte atkreipti dėmesį, kad ne visi
Ruby objektai gali būti serializuojami kaip JSON. Pavyzdžiui, `Date` ir `Time` objektai
bus serializuojami kaip eilutės, o `Hash` raktai bus paversti į eilutes.

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
Rekomenduojama saugoti tik paprastus duomenis (tekstus ir skaičius) slapukuose. Jei turite saugoti sudėtingus objektus, turėsite rankiniu būdu konvertuoti juos skaitydami reikšmes kituose užklausų.

Jei naudojate slapuko sesijos saugyklą, tai taip pat taikoma `session` ir `flash` maišoms.

### Flash struktūros pakeitimai

Flash pranešimų raktai yra [normalizuojami į tekstus](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1). Juos vis tiek galima pasiekti naudojant simbolius arba tekstus. Peržiūrint flash, visada bus grąžinami tekstinių raktų:

```ruby
flash["tekstas"] = "tekstas"
flash[:simbolis] = "simbolis"

# Rails < 4.1
flash.keys # => ["tekstas", :simbolis]

# Rails >= 4.1
flash.keys # => ["tekstas", "simbolis"]
```

Įsitikinkite, kad lyginate Flash pranešimų raktus su tekstais.

### Pakeitimai JSON tvarkymui

Yra keletas pagrindinių pakeitimų, susijusių su JSON tvarkymu Rails 4.1.

#### MultiJSON pašalinimas

MultiJSON pasiekė savo [gyvavimo pabaigą](https://github.com/rails/rails/pull/10576)
ir buvo pašalintas iš Rails.

Jei jūsų aplikacija dabar priklauso nuo MultiJSON, turite keletą galimybių:

1. Pridėkite 'multi_json' į savo `Gemfile`. Atkreipkite dėmesį, kad tai ateityje gali nebeveikti.

2. Pakeiskite MultiJSON naudojimą, naudodami `obj.to_json` ir `JSON.parse(str)`.

ĮSPĖJIMAS: Paprasčiausiai nepakeiskite `MultiJson.dump` ir `MultiJson.load` į
`JSON.dump` ir `JSON.load`. Šie JSON gem'o API skirti serializuoti ir
deserializuoti bet kokius Ruby objektus ir paprastai yra [nesaugūs](https://ruby-doc.org/stdlib-2.2.2/libdoc/json/rdoc/JSON.html#method-i-load).

#### JSON gem'o suderinamumas

Istoriniu požiūriu, Rails turėjo kai kurių suderinamumo problemų su JSON gem'u. Naudojant
`JSON.generate` ir `JSON.dump` viduje Rails aplikacijos galėjo kilti
netikėtų klaidų.

Rails 4.1 ištaisė šias problemas, izoliuodamas savo koduotoją nuo JSON gem'o. JSON gem'o API veiks kaip įprasta, tačiau jie nebeturės prieigos prie jokių
Rails specifinių funkcijų. Pavyzdžiui:

```ruby
class FooBar
  def as_json(options = nil)
    { foo: 'bar' }
  end
end
```

```irb
irb> FooBar.new.to_json
=> "{\"foo\":\"bar\"}"
irb> JSON.generate(FooBar.new, quirks_mode: true)
=> "\"#<FooBar:0x007fa80a481610>\""
```

#### Naujas JSON koduotojas

JSON koduotojas Rails 4.1 buvo per naujo parašytas, kad būtų galima pasinaudoti JSON
gem'u. Daugeliui aplikacijų tai turėtų būti skaidrus pakeitimas. Tačiau,
peržiūrint koduotoją, buvo pašalintos šios funkcijos:

1. Ciklinės duomenų struktūros aptikimas
2. Paramos `encode_json` kabliuko
3. Galimybė koduoti `BigDecimal` objektus kaip skaičius, o ne tekstus

Jei jūsų aplikacija priklauso nuo vienos iš šių funkcijų, galite jas atkurti,
pridedami [`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder)
gem'ą į savo `Gemfile`.

#### Laiko objektų JSON atvaizdavimas

`#as_json` metodas objektams su laiko komponentu (`Time`, `DateTime`, `ActiveSupport::TimeWithZone`)
dabar pagal numatytuosius nustatymus grąžina milisekundžių tikslumą. Jei norite išlaikyti seną elgesį be milisekundžių
tikslumo, nustatykite šį parametrą inicializavimo faile:

```ruby
ActiveSupport::JSON::Encoding.time_precision = 0
```

### `return` naudojimas vidiniuose atgaliniuose iškvietimuose

Anksčiau, Rails leido vidiniuose atgaliniuose iškvietimuose naudoti `return` šitaip:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # BLOGAI
end
```

Šis elgesys niekada nebuvo numatytas. Dėl pakeitimo `ActiveSupport::Callbacks` viduje,
nuo Rails 4.1 tai nebeleidžiama. Naudoti `return` teiginys vidiniame atgaliniame iškvietime sukelia `LocalJumpError`
klaidą vykdant atgalinį iškvietimą.

Vidinius atgalinius iškvietimus su `return` galima pertvarkyti, kad grąžintų reikšmę:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # GERAI
end
```

Alternatyviai, jei norite naudoti `return`, rekomenduojama aiškiai apibrėžti
metodą:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # GERAI

  private
    def before_save_callback
      false
    end
end
```

Šis pakeitimas taikomas daugelyje vietų, kuriose naudojami atgaliniai iškvietimai Rails, įskaitant
Active Record ir Active Model atgalinius iškvietimus, taip pat filtrus Action
Controller'e (pvz., `before_action`).

Daugiau informacijos rasite [šiame pull request'e](https://github.com/rails/rails/pull/13271).

### Metodai, apibrėžti Active Record fiksuose

Rails 4.1 vertina kiekvieno fikso ERB atskirame kontekste, todėl pagalbiniai metodai,
apibrėžti fikse, nebus prieinami kituose fiksuose.

Pagalbiniai metodai, naudojami keliuose fiksuose, turėtų būti apibrėžti moduliuose,
įtrauktuose į naujai įvestą `ActiveRecord::FixtureSet.context_class`, `test_helper.rb` faile.

```ruby
module FixtureFileHelpers
  def file_sha(path)
    OpenSSL::Digest::SHA256.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

### I18n privalomos prieinamos lokalės

Rails 4.1 dabar pagal nutylėjimą I18n parinktis `enforce_available_locales` yra `true`. Tai
reiskia, kad jis užtikrins, kad visos jam perduotos lokalės būtų deklaruotos
`available_locales` sąraše.
Norint išjungti tai (ir leisti I18n priimti *bet kokią* lokalės parinktį), pridėkite šią konfigūraciją į savo aplikaciją:

```ruby
config.i18n.enforce_available_locales = false
```

Atkreipkite dėmesį, kad ši parinktis buvo pridėta kaip saugumo priemonė, užtikrinanti, kad vartotojo įvestis negali būti naudojama kaip lokalės informacija, nebent ji būtų iš anksto žinoma. Todėl rekomenduojama neišjungti šios parinkties, nebent turite rimtą priežastį tai padaryti.

### Mutatoriaus metodai, iškviesti iš sąryšio

`Sąryšis` daugiau neturi mutatoriaus metodų, tokio kaip `#map!` ir `#delete_if`. Prieš naudojant šiuos metodus, konvertuokite į `Masyvą`, iškviesdami `#to_a`.

Tai siekiama išvengti keistų klaidų ir painiavos kode, kuris tiesiogiai iškviečia mutatoriaus metodus iš `Sąryšio`.

```ruby
# Vietoje to
Author.where(name: 'Hank Moody').compact!

# Dabar turite tai padaryti
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
```

### Pakeitimai numatytuose ribose

Numatytosios ribos daugiau nebus perrašomos sujungtomis sąlygomis.

Anksčiau, kai apibrėžėte `numatytą ribą` modelyje, ji buvo perrašoma sujungtomis sąlygomis tame pačiame lauke. Dabar ji yra sujungta kaip bet kokia kita riba.

Anksčiau:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

Dabar:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

Norint gauti ankstesnį elgesį, reikia išaiškinti `numatytos ribos` sąlygą, naudojant `unscoped`, `unscope`, `rewhere` ar `except`.

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { unscope(where: :state).where(state: 'active') }
  scope :inactive, -> { rewhere state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

### Turinio atvaizdavimas iš eilutės

Rails 4.1 įveda `:plain`, `:html` ir `:body` parinktis `render` funkcijai. Šios parinktys dabar yra pageidaujamas būdas atvaizduoti eilutės pagrindu pagrįstą turinį, nes tai leidžia nurodyti, kokio turinio tipo norite, kad būtų siunčiamas atsakas.

* `render :plain` nustatys turinio tipą kaip `text/plain`
* `render :html` nustatys turinio tipą kaip `text/html`
* `render :body` *ne*nustatys turinio tipo antraštės.

Iš saugumo perspektyvos, jei nesitikite turėti jokio žymėjimo savo atsakymo kūne, turėtumėte naudoti `render :plain`, nes dauguma naršyklių automatiškai apsaugos nesaugų turinį atsakyme.

Mes planuojame pasenusią `render :text` funkcijos naudojimą ateityje. Todėl prašome pradėti naudoti tiksliau nurodytas `:plain`, `:html` ir `:body` parinktis. Naudoti `render :text` gali kelti saugumo riziką, nes turinys siunčiamas kaip `text/html`.

### PostgreSQL JSON ir hstore duomenų tipai

Rails 4.1 priskirs `json` ir `hstore` stulpelius kaip `Ruby Hash` su eilutėmis kaip raktai. Ankstesnėse versijose buvo naudojamas `HashWithIndifferentAccess`. Tai reiškia, kad simbolio prieiga nebepalaikoma. Taip pat taip yra su `store_accessors`, pagrįstais `json` ar `hstore` stulpeliais. Įsitikinkite, kad nuosekliai naudojate eilučių raktus.

### Aiškios bloko naudojimo `ActiveSupport::Callbacks` funkcijos

Rails 4.1 dabar tikisi, kad bus perduotas aiškus blokas, kai kviečiama `ActiveSupport::Callbacks.set_callback` funkcija. Šis pakeitimas kyla iš to, kad `ActiveSupport::Callbacks` buvo iš esmės pertvarkytas 4.1 versijai.

```ruby
# Anksčiau Rails 4.0
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# Dabar Rails 4.1
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

Atnaujinimas iš Rails 3.2 į Rails 4.0
-------------------------------------

Jei jūsų aplikacija šiuo metu yra bet kurioje senesnėje nei 3.2.x versijoje, turėtumėte atnaujinti ją iki Rails 3.2 prieš bandydami atnaujinti į Rails 4.0.

Šie pakeitimai skirti jūsų aplikacijos atnaujinimui į Rails 4.0.

### HTTP PATCH
Rails 4 dabar naudoja `PATCH` kaip pagrindinį HTTP veiksmą atnaujinimams, kai RESTful išteklius yra apibrėžti `config/routes.rb` faile. `update` veiksmas vis dar naudojamas, ir `PUT` užklausos vis dar bus nukreipiamos į `update` veiksmą. Taigi, jei naudojate tik standartinius RESTful maršrutus, nereikia daryti jokių pakeitimų:

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # Nereikia keisti; bus naudojamas PATCH, o PUT vis dar veiks.
  end
end
```

Tačiau turėsite atlikti pakeitimą, jei naudojate `form_for` norėdami atnaujinti išteklių kartu su pasirinktiniu maršrutu, naudojančiu `PUT` HTTP metodą:

```ruby
resources :users do
  put :update_name, on: :member
end
```

```erb
<%= form_for [ :update_name, @user ] do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update_name
    # Reikia pakeisti; form_for bandys naudoti neegzistuojantį PATCH maršrutą.
  end
end
```

Jei veiksmas nenaudojamas viešoje API ir galite pakeisti HTTP metodą, galite atnaujinti savo maršrutą, naudodami `patch` vietoje `put`:

```ruby
resources :users do
  patch :update_name, on: :member
end
```

`PUT` užklausos į `/users/:id` maršrutą "Rails 4" bus nukreipiamos į `update`, kaip ir iki šiol. Taigi, jei turite API, kuris gauna tikrus PUT užklausas, tai veiks. Maršrutizatorius taip pat nukreipia `PATCH` užklausas į `/users/:id` į `update` veiksmą.

Jei veiksmas naudojamas viešoje API ir negalite pakeisti naudojamo HTTP metodo, galite atnaujinti savo formą, naudodami `PUT` metodą:

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

Daugiau informacijos apie PATCH ir kodėl buvo padarytas šis pakeitimas rasite [šiame įraše](https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/) "Rails" tinklaraštyje.

#### Pastaba apie medijos tipus

`PATCH` veiksmo klaida [nurodo, kad su `PATCH` turėtų būti naudojamas "diff" medijos tipas](http://www.rfc-editor.org/errata_search.php?rfc=5789). Vienas iš tokių formatų yra [JSON Patch](https://tools.ietf.org/html/rfc6902). Nors "Rails" natūraliai nepalaiko JSON Patch, jį galima lengvai pridėti:

```ruby
# jūsų kontroleryje:
def update
  respond_to do |format|
    format.json do
      # atlikti dalinį atnaujinimą
      @article.update params[:article]
    end

    format.json_patch do
      # atlikti sudėtingą pakeitimą
    end
  end
end
```

```ruby
# config/initializers/json_patch.rb
Mime::Type.register 'application/json-patch+json', :json_patch
```

Kadangi JSON Patch neseniai tapo RFC, dar nėra daug puikių Ruby bibliotekų. Aaron Patterson'o
[hana](https://github.com/tenderlove/hana) yra viena iš tokių gemų, tačiau ji neturi
visiško palaikymo naujausiems specifikacijos pakeitimams.

### Gemfile

Rails 4.0 pašalino `assets` grupę iš `Gemfile`. Turėtumėte pašalinti tuos
eilutes iš savo `Gemfile` atnaujinimo metu. Taip pat turėtumėte atnaujinti savo aplikacijos
failą (esantį `config/application.rb`):

```ruby
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
```

### vendor/plugins

Rails 4.0 nebeturi palaikymo `vendor/plugins` aplankui. Turite pakeisti visus įskiepius, išskleisdami juos į gemus ir pridedami juos į savo `Gemfile`. Jei nenorite padaryti jų gemais, galite perkelti juos į, tarkime, `lib/my_plugin/*` ir pridėti atitinkamą inicializatorių `config/initializers/my_plugin.rb`.

### Active Record

* Rails 4.0 pašalino identifikavimo žemėlapį iš Active Record dėl [kai kurių nesuderinamumų su asociacijomis](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6). Jei jūs rankiniu būdu įjungėte jį savo aplikacijoje, turėsite pašalinti šią konfigūraciją, kuri daugiau neturi jokio poveikio: `config.active_record.identity_map`.

* `delete` metodas kolekcijos asociacijose dabar gali priimti `Integer` arba `String` argumentus kaip įrašų id, be įrašų, panašiai kaip ir `destroy` metodas. Anksčiau šie argumentai sukeldavo `ActiveRecord::AssociationTypeMismatch` klaidą. Nuo "Rails" 4.0 `delete` automatiškai bando rasti įrašus, atitinkančius duotus id, prieš juos ištrindamas.

* "Rails" 4.0 pakeitė `serialized_attributes` ir `attr_readonly` tik klasės metodais. Nereikėtų naudoti objekto metodų, nes jie dabar yra pasenusi. Jūs turėtumėte juos pakeisti naudodami klasės metodus, pvz., `self.serialized_attributes` į `self.class.serialized_attributes`.

* Naudodami numatytąjį koduotoją, priskyrus `nil` serializuotam atributui, jis bus išsaugotas
  į duomenų bazę kaip `NULL`, o ne perduodamas `nil` reikšmė YAML (`"--- \n...\n"`).
* Rails 4.0 pašalino `attr_accessible` ir `attr_protected` funkcijas, paliekant Strong Parameters. Galite naudoti [Protected Attributes gemą](https://github.com/rails/protected_attributes) sklandžiam atnaujinimo procesui.

* Jei nenaudojate Protected Attributes, galite pašalinti visas su šiuo gemu susijusias parinktis, pvz., `whitelist_attributes` arba `mass_assignment_sanitizer` parinktis.

* Rails 4.0 reikalauja, kad apribojimai naudotų iškviečiamą objektą, pvz., Proc arba lambda:

    ```ruby
      scope :active, where(active: true)

      # tampa
      scope :active, -> { where active: true }
    ```

* Rails 4.0 paseno `ActiveRecord::Fixtures` naudai, paliekant `ActiveRecord::FixtureSet`.

* Rails 4.0 paseno `ActiveRecord::TestCase` naudai, paliekant `ActiveSupport::TestCase`.

* Rails 4.0 paseno senojo stiliaus hash-based finder API. Tai reiškia, kad metodai, kurie anksčiau priėmė "finder options", to jau nebedaro. Pavyzdžiui, `Book.find(:all, conditions: { name: '1984' })` paseno, paliekant `Book.where(name: '1984')`

* Visi dinaminiai metodai, išskyrus `find_by_...` ir `find_by_...!`, paseno.
  Taip galite tvarkyti pokyčius:

      * `find_all_by_...`           tampa `where(...)`.
      * `find_last_by_...`          tampa `where(...).last`.
      * `scoped_by_...`             tampa `where(...)`.
      * `find_or_initialize_by_...` tampa `find_or_initialize_by(...)`.
      * `find_or_create_by_...`     tampa `find_or_create_by(...)`.

* Atkreipkite dėmesį, kad `where(...)` grąžina sąryšį, o ne masyvą, kaip senieji finderiai. Jei reikia masyvo, naudokite `where(...).to_a`.

* Šie ekvivalentūs metodai gali nevykdyti tos pačios SQL užklausos kaip ankstesnė implementacija.

* Norėdami vėl įgalinti senus finderius, galite naudoti [activerecord-deprecated_finders gemą](https://github.com/rails/activerecord-deprecated_finders).

* Rails 4.0 pakeitė numatytąjį jungiamąjį lentelę `has_and_belongs_to_many` ryšiams, pašalindamas bendrą priešdėlį iš antrosios lentelės pavadinimo. Bet kuris esamas `has_and_belongs_to_many` ryšys tarp modelių su bendru priešdėliu turi būti nurodytas su `join_table` parinktimi. Pavyzdžiui:

    ```ruby
    CatalogCategory < ActiveRecord::Base
      has_and_belongs_to_many :catalog_products, join_table: 'catalog_categories_catalog_products'
    end

    CatalogProduct < ActiveRecord::Base
      has_and_belongs_to_many :catalog_categories, join_table: 'catalog_categories_catalog_products'
    end
    ```

* Atkreipkite dėmesį, kad priešdėlis taip pat atsižvelgia į apribojimus, todėl `Catalog::Category` ir `Catalog::Product` arba `Catalog::Category` ir `CatalogProduct` ryšiai turi būti atnaujinti panašiai.

### Active Resource

Rails 4.0 išskyrė Active Resource į savo gemą. Jei vis dar reikalinga ši funkcija, galite pridėti [Active Resource gemą](https://github.com/rails/activeresource) į savo `Gemfile`.

### Active Model

* Rails 4.0 pakeitė, kaip klaidos pridedamos su `ActiveModel::Validations::ConfirmationValidator`. Dabar, kai patvirtinimo patikrinimai nepavyksta, klaida bus pridėta prie `:#{attribute}_confirmation`, o ne `attribute`.

* Rails 4.0 pakeitė `ActiveModel::Serializers::JSON.include_root_in_json` numatytąją reikšmę į `false`. Dabar Active Model Serializers ir Active Record objektai turi tą pačią numatytąją elgseną. Tai reiškia, kad galite užkomentuoti arba pašalinti šią parinktį iš `config/initializers/wrap_parameters.rb` failo:

    ```ruby
    # Disable root element in JSON by default.
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    ```

### Action Pack

* Rails 4.0 įveda `ActiveSupport::KeyGenerator` ir naudoja jį kaip pagrindą, iš kurio generuojami ir tikrinami pasirašyti slapukai (tarp kitų dalykų). Esami pasirašyti slapukai, sugeneruoti su Rails 3.x, bus automatiškai atnaujinti, jei paliksite esamą `secret_token` ir pridėsite naują `secret_key_base`.

    ```ruby
      # config/initializers/secret_token.rb
      Myapp::Application.config.secret_token = 'esamas paslėptas raktas'
      Myapp::Application.config.secret_key_base = 'naujas paslėptas raktas'
    ```

    Atkreipkite dėmesį, kad `secret_key_base` turėtumėte nustatyti tik tada, kai 100% jūsų vartotojų bazės naudoja Rails 4.x ir esate pakankamai tikri, kad nebereikės grįžti prie Rails 3.x. Tai yra dėl to, kad su nauju `secret_key_base` pagrįsti slapukai Rails 4.x nėra suderinami su Rails 3.x. Galite palikti esamą `secret_token`, nepasidaryti naujo `secret_key_base` ir ignoruoti pasenusius įspėjimus, kol esate pakankamai tikri, kad atnaujinimas yra kitaip baigtas.

    Jei priklausote nuo galimybės, kad išorinės programos ar JavaScript galėtų skaityti jūsų Rails programos pasirašytus sesijos slapukus (arba pasirašytus slapukus apskritai), neturėtumėte nustatyti `secret_key_base`, kol nesate atsijungę nuo šių susijusių dalykų.

* Rails 4.0 šifruoja turinį, esantį slapuko pagrindu paremtose sesijose, jei nustatytas `secret_key_base`. Rails 3.x pasirašė, bet nesifruoja, turinio, esančio slapuko pagrindu paremtose sesijose. Pasirašyti slapukai yra "saugūs", nes patvirtinama, kad jie buvo sugeneruoti jūsų programos ir yra apsaugoti nuo manipuliavimo. Tačiau turinys gali būti matomas galutinio vartotojo ir turinio šifravimas pašalina šį apribojimą/rišlumą be didelės veiklos šalutinės pasekmės.

    Prašome perskaityti [Pull Request #9978](https://github.com/rails/rails/pull/9978) dėl perėjimo prie šifruotų sesijos slapukų.

* Rails 4.0 pašalino `ActionController::Base.asset_path` parinktį. Naudokite turinio paleidimo funkciją.
* Rails 4.0 yra pasenusi `ActionController::Base.page_cache_extension` parinktis. Vietoj jos naudokite `ActionController::Base.default_static_extension`.

* Rails 4.0 pašalino veiksmų ir puslapių talpinimą iš Action Pack. Norėdami naudoti `caches_action`, turėsite pridėti `actionpack-action_caching` juostelę, o norėdami naudoti `caches_page`, turėsite pridėti `actionpack-page_caching` juostelę savo valdikliuose.

* Rails 4.0 pašalino XML parametrų analizatorių. Jei jums reikia šios funkcijos, turėsite pridėti `actionpack-xml_parser` juostelę.

* Rails 4.0 pakeitė numatytąjį `layout` paieškos rinkinį, naudojant simbolius arba funkcijas, kurios grąžina `nil`. Norėdami gauti "be išdėstymo" elgesį, grąžinkite `false` vietoje `nil`.

* Rails 4.0 pakeitė numatytąjį memcached klientą iš `memcache-client` į `dalli`. Norėdami atnaujinti, tiesiog pridėkite `gem 'dalli'` į savo `Gemfile`.

* Rails 4.0 pasenusių `dom_id` ir `dom_class` metodų valdikliuose (juose jie geri peržiūroje). Norėdami naudoti šią funkciją, turėsite įtraukti `ActionView::RecordIdentifier` modulį į valdiklius.

* Rails 4.0 pasenusi `:confirm` parinktis `link_to` pagalbininkui. Vietoj to turėtumėte pasikliauti duomenų atributu (pvz., `data: { confirm: 'Ar tikrai?' }`). Šis pasenusi taip pat liečia pagrįstus šiuo pagalbininku (pvz., `link_to_if` arba `link_to_unless`).

* Rails 4.0 pakeitė, kaip veikia `assert_generates`, `assert_recognizes` ir `assert_routing`. Dabar visi šie teiginiai iškelia `Assertion` vietoje `ActionController::RoutingError`.

* Rails 4.0 iškelia `ArgumentError`, jei yra apibrėžtos konfliktuojančios pavadinimo maršrutai. Tai gali būti sukelta iš anksto apibrėžtų pavadinimų maršrutų arba naudojant `resources` metodą. Štai du pavyzdžiai, kurie konfliktuoja su pavadinimu maršrutu `example_path`:

    ```ruby
    get 'one' => 'test#example', as: :example
    get 'two' => 'test#example', as: :example
    ```

    ```ruby
    resources :examples
    get 'clashing/:id' => 'test#example', as: :example
    ```

    Pirmuoju atveju galite tiesiog vengti naudoti tą patį pavadinimą keliose maršrutuose. Antruoju atveju galite naudoti `only` arba `except` parinktis, kurias teikia `resources` metodas, kad apribotumėte sukurtus maršrutus, kaip nurodyta [Maršrutų vadove](routing.html#restricting-the-routes-created).

* Rails 4.0 taip pat pakeitė, kaip yra piešiami unikodo simbolių maršrutai. Dabar galite tiesiogiai piešti unikodo simbolių maršrutus. Jei jau piešiate tokius maršrutus, turėsite juos pakeisti, pavyzdžiui:

    ```ruby
    get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
    ```

    tampa

    ```ruby
    get 'こんにちは', controller: 'welcome', action: 'index'
    ```

* Rails 4.0 reikalauja, kad maršrutai, naudojantys `match`, nurodytų užklausos metodą. Pavyzdžiui:

    ```ruby
      # Rails 3.x
      match '/' => 'root#index'

      # tampa
      match '/' => 'root#index', via: :get

      # arba
      get '/' => 'root#index'
    ```

* Rails 4.0 pašalino `ActionDispatch::BestStandardsSupport` tarpinį programinės įrangos sluoksnį, `<!DOCTYPE html>` jau sukelia standartų režimą pagal https://msdn.microsoft.com/en-us/library/jj676915(v=vs.85).aspx, o ChromeFrame antraštė buvo perkelta į `config.action_dispatch.default_headers`.

    Taip pat atsiminkite, kad turite pašalinti bet kokius nuorodas į tarpinę programinės įrangos iš jūsų programos kodo, pavyzdžiui:

    ```ruby
    # Iškelkite išimtį
    config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
    ```

    Taip pat patikrinkite savo aplinkos nustatymus dėl `config.action_dispatch.best_standards_support` ir pašalinkite jį, jei yra.

* Rails 4.0 leidžia konfigūruoti HTTP antraštes nustatant `config.action_dispatch.default_headers`. Numatytieji nustatymai yra šie:

    ```ruby
      config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block'
      }
    ```

    Atkreipkite dėmesį, kad jei jūsų programa priklauso nuo tam tikrų puslapių įkėlimo į `<frame>` arba `<iframe>`, tuomet gali prireikti išankstinio nustatymo `X-Frame-Options` į `ALLOW-FROM ...` arba `ALLOWALL`.

* Rails 4.0, kompiliuojant išteklius, nebesinukopijuoja automatiškai ne-JS/CSS išteklių iš `vendor/assets` ir `lib/assets`. Rails programų ir modulių kūrėjai turėtų dėti šiuos išteklius į `app/assets` arba konfigūruoti [`config.assets.precompile`][].

* Rails 4.0, kai veiksmas neapdoroja užklausos formato, iškelia `ActionController::UnknownFormat` išimtį. Pagal numatytuosius nustatymus, išimtis apdorojama atsakydama su 406 Not Acceptable, bet dabar galite perrašyti tai. Rails 3, visada grąžindavo 406 Not Acceptable. Nėra perrašymų.

* Rails 4.0, kai `ParamsParser` nepavyksta analizuoti užklausos parametrų, iškelia bendrą `ActionDispatch::ParamsParser::ParseError` išimtį. Norėdami tai apdoroti, turėsite pagauti šią išimtį, o ne žemąjį `MultiJson::DecodeError`, pavyzdžiui.

* Rails 4.0, kai varikliai pritvirtinti prie programos, kuri yra aptarnaujama iš URL priešdėlio, tinkamai įdėti `SCRIPT_NAME`. Jums nebeprireiks nustatyti `default_url_options[:script_name]`, kad išvengtumėte perrašytų URL priešdėlių.

* Rails 4.0 paseno `ActionController::Integration` naudai `ActionDispatch::Integration`.
* Rails 4.0 paseno `ActionController::IntegrationTest` naudai `ActionDispatch::IntegrationTest`.
* Rails 4.0 paseno `ActionController::PerformanceTest` naudai `ActionDispatch::PerformanceTest`.
* Rails 4.0 paseno `ActionController::AbstractRequest` naudai `ActionDispatch::Request`.
* Rails 4.0 paseno `ActionController::Request` naudai `ActionDispatch::Request`.
* Rails 4.0 paseno `ActionController::AbstractResponse` naudai `ActionDispatch::Response`.
* Rails 4.0 paseno `ActionController::Response` naudai `ActionDispatch::Response`.
* Rails 4.0 paseno `ActionController::Routing` naudai `ActionDispatch::Routing`.
### Aktyvusis palaikymas

Rails 4.0 pašalina `j` sinonimą `ERB::Util#json_escape`, nes `j` jau naudojamas `ActionView::Helpers::JavaScriptHelper#escape_javascript`.

#### Podėlio

Podėlio metodas pasikeitė tarp Rails 3.x ir 4.0. Turėtumėte [pakeisti podėlio vardų erdvę](https://guides.rubyonrails.org/v4.0/caching_with_rails.html#activesupport-cache-store) ir pradėti naudoti šaltą podėlį.

### Pagalbininkų įkėlimo tvarka

Pagalbininkų iš daugiau nei vienos direktorijos įkėlimo tvarka pasikeitė Rails 4.0. Anksčiau jie buvo surinkti ir tada surūšiuoti abėcėlės tvarka. Po atnaujinimo į Rails 4.0, pagalbininkai išlaikys įkeltų direktorijų tvarką ir bus surūšiuoti abėcėlės tvarka tik kiekvienoje direktorijoje. Jei nenaudojate `helpers_path` parametro, šis pakeitimas paveiks tik pagalbininkų įkėlimo būdą iš variklių. Jei priklausote nuo tvarkos, turėtumėte patikrinti, ar po atnaujinimo yra teisingi metodai. Jei norite pakeisti variklių įkėlimo tvarką, galite naudoti `config.railties_order=` metodą.

### Active Record Observer ir Action Controller Sweeper

`ActiveRecord::Observer` ir `ActionController::Caching::Sweeper` buvo išskirti į `rails-observers` juostą. Jei norite naudoti šias funkcijas, turėsite pridėti `rails-observers` juostą.

### sprockets-rails

* `assets:precompile:primary` ir `assets:precompile:all` buvo pašalinti. Vietoj jų naudokite `assets:precompile`.
* `config.assets.compress` parinktis turėtų būti pakeista į [`config.assets.js_compressor`][] pavyzdžiui:

    ```ruby
    config.assets.js_compressor = :uglifier
    ```


### sass-rails

* `asset-url` su dviem argumentais yra pasenusi. Pavyzdžiui: `asset-url("rails.png", image)` tampa `asset-url("rails.png")`.

Atnaujinimas nuo Rails 3.1 iki Rails 3.2
-------------------------------------

Jei jūsų programa šiuo metu yra bet kurio senesnio nei 3.1.x versijos Rails, turėtumėte atnaujinti iki Rails 3.1 prieš bandydami atnaujinti iki Rails 3.2.

Šie pakeitimai skirti jūsų programos atnaujinimui iki naujausios 3.2.x versijos Rails.

### Gemfile

Padarykite šiuos pakeitimus savo `Gemfile`.

```ruby
gem 'rails', '3.2.21'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

Jūsų vystymo aplinkai turėtumėte pridėti keletą naujų konfigūracijos nustatymų:

```ruby
# Išimtis, kai masinio priskyrimo apsauga aktyviems įrašams
config.active_record.mass_assignment_sanitizer = :strict

# Registruoti užklausos planą užklausoms, kurios užtrunka ilgiau nei tai (veikia
# su SQLite, MySQL ir PostgreSQL)
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

`mass_assignment_sanitizer` konfigūracijos nustatymą taip pat turėtumėte pridėti prie `config/environments/test.rb`:

```ruby
# Išimtis, kai masinio priskyrimo apsauga aktyviems įrašams
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

Rails 3.2 pasenina `vendor/plugins`, o Rails 4.0 jas visiškai pašalins. Nors tai nėra būtina kaip dalis Rails 3.2 atnaujinimo, galite pradėti keisti bet kokius įskiepius išskleisdami juos į juostas ir pridedami juos prie savo `Gemfile`. Jei nesutinkate juos padaryti juostomis, galite juos perkelti, pavyzdžiui, į `lib/my_plugin/*` ir pridėti atitinkamą pradinę konfigūraciją `config/initializers/my_plugin.rb`.

### Active Record

`belongs_to` iš `:dependent => :restrict` parinktis buvo pašalinta. Jei norite užkirsti kelią objekto trynimui, jei yra susijusių objektų, galite nustatyti `:dependent => :destroy` ir grąžinti `false` po patikrinimo, ar yra susijusių objektų iš bet kurio susijusio objekto trynimo atgalinių iškvietimų.

Atnaujinimas nuo Rails 3.0 iki Rails 3.1
-------------------------------------

Jei jūsų programa šiuo metu yra bet kurio senesnio nei 3.0.x versijos Rails, turėtumėte atnaujinti iki Rails 3.0 prieš bandydami atnaujinti iki Rails 3.1.

Šie pakeitimai skirti jūsų programos atnaujinimui iki Rails 3.1.12, paskutinės 3.1.x versijos Rails.

### Gemfile

Padarykite šiuos pakeitimus savo `Gemfile`.

```ruby
gem 'rails', '3.1.12'
gem 'mysql2'

# Reikalinga naujai aktyviosios juostos
group :assets do
  gem 'sass-rails',   '~> 3.1.7'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier',     '>= 1.0.3'
end

# jQuery yra numatytasis JavaScript biblioteka Rails 3.1
gem 'jquery-rails'
```

### config/application.rb

Aktyviosios juostos reikalauja šių papildymų:

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

Jei jūsų programa naudoja "/assets" maršrutą resursui, galite pakeisti naudojamą priešdėlį, kad išvengtumėte konfliktų:

```ruby
# Numatytasis priešdėlis yra '/assets'
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

Pašalinkite RJS nustatymą `config.action_view.debug_rjs = true`.

Jei įjungėte aktyviosios juostos, pridėkite šiuos nustatymus:

```ruby
# Nespausti aktyvųjų
config.assets.compress = false

# Išskleisti eilutes, kurios įkelia aktyvuosius
config.assets.debug = true
```

### config/environments/production.rb

Vėlgi, dauguma žemiau pateiktų pakeitimų skirti aktyviosios juostos. Daugiau informacijos apie tai galite rasti [Aktyviosios juostos](asset_pipeline.html) vadove.
```ruby
# Suspausti JavaScript ir CSS failus
config.assets.compress = true

# Neatstatyti į assets pipeline, jei praleistas sukompiliuotas failas
config.assets.compile = false

# Generuoti URL adresams šifravimo raktus
config.assets.digest = true

# Numatytasis kelias: Rails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# Sukompiliuoti papildomus failus (application.js, application.css, ir visi ne-JS/CSS failai jau pridėti)
# config.assets.precompile += %w( admin.js admin.css )

# Priversti visą programos prieigą per SSL, naudoti Strict-Transport-Security ir saugias slapukus.
# config.force_ssl = true
```

### config/environments/test.rb

Galite padėti testuoti našumą pridedant šiuos parametrus į testavimo aplinką:

```ruby
# Konfigūruoti statinio turinio serverį testams su Cache-Control parametru našumui
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=3600'
}
```

### config/initializers/wrap_parameters.rb

Pridėkite šį failą su šiuo turiniu, jei norite apgaubti parametrus į įdėtą raktų rinkinį. Tai įjungta pagal nutylėjimą naujose programose.

```ruby
# Įsitikinkite, kad perkraunate serverį, kai keičiate šį failą.
# Šis failas turi nustatymus ActionController::ParamsWrapper, kuris
# įjungtas pagal nutylėjimą.

# Įjungti parametrų įdėjimą į JSON. Galite tai išjungti nustatydami :format į tuščią masyvą.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# Pagal nutylėjimą išjungti šakninį elementą JSON.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

Turite pakeisti savo sesijos raktą į kažką naujo arba pašalinti visas sesijas:

```ruby
# config/initializers/session_store.rb
AppName::Application.config.session_store :cookie_store, key: 'KAŽKASNaujo'
```

arba

```bash
$ bin/rake db:sessions:clear
```

### Pašalinti :cache ir :concat parametrus iš asset helper funkcijų nuorodų peržiūroje

* Su Asset Pipeline :cache ir :concat parametrai daugiau nenaudojami, ištrinkite šiuos parametrus iš savo peržiūros failų.
[`config.cache_classes`]: configuring.html#config-cache-classes
[`config.autoload_once_paths`]: configuring.html#config-autoload-once-paths
[`config.force_ssl`]: configuring.html#config-force-ssl
[`config.ssl_options`]: configuring.html#config-ssl-options
[`config.add_autoload_paths_to_load_path`]: configuring.html#config-add-autoload-paths-to-load-path
[`config.active_storage.replace_on_assign_to_many`]: configuring.html#config-active-storage-replace-on-assign-to-many
[`config.exceptions_app`]: configuring.html#config-exceptions-app
[`config.action_mailer.perform_caching`]: configuring.html#config-action-mailer-perform-caching
[`config.assets.precompile`]: configuring.html#config-assets-precompile
[`config.assets.js_compressor`]: configuring.html#config-assets-js-compressor
