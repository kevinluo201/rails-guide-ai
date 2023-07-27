**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c7252bf18650c5a9a85fc144305c4615
Ruby on Rails 5.2 Išleidimo pastabos
===============================

Svarbiausi dalykai Rails 5.2:

* Active Storage
* Redis Cache Store
* HTTP/2 Early Hints
* Credentials
* Content Security Policy

Šiose išleidimo pastabose aptariami tik pagrindiniai pokyčiai. Norėdami sužinoti apie įvairius klaidų taisymus ir pokyčius, prašome kreiptis į pakeitimų žurnalus arba peržiūrėti [pakeitimų sąrašą](https://github.com/rails/rails/commits/5-2-stable) pagrindiniame Rails saugykloje GitHub.

--------------------------------------------------------------------------------

Atnaujinimas iki Rails 5.2
----------------------

Jei atnaujinote esamą programą, gerai būtų turėti geras testavimo padengimo galimybes prieš pradedant. Taip pat pirmiausia turėtumėte atnaujinti iki Rails 5.1, jei dar to nedarėte, ir įsitikinti, kad jūsų programa vis dar veikia kaip tikėtasi, prieš bandant atnaujinti iki Rails 5.2. Atnaujinimo metu reikėtų atkreipti dėmesį į tam tikrus dalykus, kuriuos galima rasti [Ruby on Rails atnaujinimo](upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2) vadove.

Pagrindinės funkcijos
--------------

### Active Storage

[Pakeitimų užklausa](https://github.com/rails/rails/pull/30020)

[Active Storage](https://github.com/rails/rails/tree/5-2-stable/activestorage)
palengvina failų įkėlimą į debesų saugyklos paslaugą, tokias kaip
Amazon S3, Google Cloud Storage arba Microsoft Azure Storage, ir prideda
tuos failus prie Active Record objektų. Tai apima vietinės disko pagrindu veikiančią paslaugą
vystymui ir testavimui ir palaiko failų kopijavimą į pagalbines
paslaugas atsarginėms kopijoms ir migracijoms. 
Apie Active Storage daugiau galite sužinoti
[Active Storage apžvalgoje](active_storage_overview.html) vadove.

### Redis Cache Store

[Pakeitimų užklausa](https://github.com/rails/rails/pull/31134)

Rails 5.2 turi įmontuotą Redis kešo saugyklą.
Apie tai daugiau galite sužinoti
[Rails kešavimas: Apžvalga](caching_with_rails.html#activesupport-cache-rediscachestore)
vadove.

### HTTP/2 Early Hints

[Pakeitimų užklausa](https://github.com/rails/rails/pull/30744)

Rails 5.2 palaiko [HTTP/2 Early Hints](https://tools.ietf.org/html/rfc8297).
Norėdami įjungti Early Hints serverį, paleiskite `--early-hints`
komandą `bin/rails server`.

### Credentials

[Pakeitimų užklausa](https://github.com/rails/rails/pull/30067)

Pridėtas `config/credentials.yml.enc` failas, skirtas saugoti produkcijos programos paslaptis.
Tai leidžia išsaugoti bet kokias autentifikacijos prieigos duomenis trečiųjų šalių paslaugoms
tiesiogiai saugykloje, užšifruotus naudojant `config/master.key` failo arba
`RAILS_MASTER_KEY` aplinkos kintamojo raktą.
Tai galiausiai pakeis `Rails.application.secrets` ir užšifruotas
paslaptis, pristatytas Rails 5.1.
Be to, Rails 5.2
[atveria API pagrindinėms Credentials](https://github.com/rails/rails/pull/30940),
taigi galite lengvai tvarkyti kitas užšifruotas konfigūracijas, raktus ir failus.
Apie tai daugiau galite sužinoti
[Saugant Rails programas](security.html#custom-credentials)
vadove.

### Content Security Policy

[Pakeitimų užklausa](https://github.com/rails/rails/pull/31162)

Rails 5.2 turi naują DSL, kuris leidžia konfigūruoti
[Turinio saugumo politiką](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)
jūsų programai. Galite konfigūruoti globalią numatytąją politiką ir tada
perrašyti ją pagal išteklių bazę ir net naudoti lambda funkcijas, kad įterptumėte per užklausą
reikšmes į antraštės dalį, pvz., sąskaitos subdomenus daugiamandatėje programoje.
Apie tai daugiau galite sužinoti
[Saugant Rails programas](security.html#content-security-policy)
vadove.
Railties
--------

Išsamius pakeitimus rasite [Changelog][railties] puslapyje.

### Pasenusios funkcijos

*   Pasenusi `capify!` metodo naudojimas generatoriuose ir šablonuose.
    ([Pull Request](https://github.com/rails/rails/pull/29493))

*   Pasenusi aplinkos pavadinimo perduodimas kaip įprastas argumentas
    `rails dbconsole` ir `rails console` komandoms. Vietoj to turėtų būti naudojama
    `-e` parinktis.
    ([Commit](https://github.com/rails/rails/commit/48b249927375465a7102acc71c2dfb8d49af8309))

*   Pasenusi `Rails::Application` paveldėjimo naudojimas paleidžiant Rails serverį.
    ([Pull Request](https://github.com/rails/rails/pull/30127))

*   Pasenusi `after_bundle` atgalinis iškvietimas Rails plugin šablonuose.
    ([Pull Request](https://github.com/rails/rails/pull/29446))

### Svarbūs pakeitimai

*   Pridėtas bendras skyrius `config/database.yml`, kuris bus įkeltas visoms aplinkoms.
    ([Pull Request](https://github.com/rails/rails/pull/28896))

*   Pridėtas `railtie.rb` į plugin generatorių.
    ([Pull Request](https://github.com/rails/rails/pull/29576))

*   Išvalomi ekrano kopijų failai `tmp:clear` užduotyje.
    ([Pull Request](https://github.com/rails/rails/pull/29534))

*   Praleidžiami nenaudojami komponentai paleidžiant `bin/rails app:update`.
    Jei pradinės programos generavimo metu buvo praleisti Action Cable, Active Record ir kt.,
    atnaujinimo užduotis taip pat laikosi tų praleidimų.
    ([Pull Request](https://github.com/rails/rails/pull/29645))

*   Leidžiama perduoti pasirinktinį prisijungimo pavadinimą `rails dbconsole`
    komandai naudojant 3 lygių duomenų bazės konfigūraciją.
    Pavyzdys: `bin/rails dbconsole -c replica`.
    ([Commit](https://github.com/rails/rails/commit/1acd9a6464668d4d54ab30d016829f60b70dbbeb))

*   Teisingai išplečiami aplinkos pavadinimo trumpiniai vykdant `console`
    ir `dbconsole` komandas.
    ([Commit](https://github.com/rails/rails/commit/3777701f1380f3814bd5313b225586dec64d4104))

*   Pridedamas `bootsnap` į numatytąjį `Gemfile`.
    ([Pull Request](https://github.com/rails/rails/pull/29313))

*   Palaikoma `-` kaip platformos nepriklausomas būdas vykdyti scenarijų iš standartinio įvesties srauto naudojant
    `rails runner`
    ([Pull Request](https://github.com/rails/rails/pull/26343))

*   Pridedama `ruby x.x.x` versija į `Gemfile` ir sukuriamas `.ruby-version`
    pagrindinis failas, kuriame yra dabartinė Ruby versija, kai kuriamos naujos Rails programos.
    ([Pull Request](https://github.com/rails/rails/pull/30016))

*   Pridedama `--skip-action-cable` parinktis plugin generatoriui.
    ([Pull Request](https://github.com/rails/rails/pull/30164))

*   Pridedama `git_source` į `Gemfile` plugin generatoriui.
    ([Pull Request](https://github.com/rails/rails/pull/30110))

*   Praleidžiami nenaudojami komponentai paleidžiant `bin/rails` Rails pluginui.
    ([Commit](https://github.com/rails/rails/commit/62499cb6e088c3bc32a9396322c7473a17a28640))

*   Optimizuojama generatoriaus veiksmų įdėjimo įterpimo.
    ([Pull Request](https://github.com/rails/rails/pull/30166))

*   Optimizuojama maršrutų įdėjimo įterpimo.
    ([Pull Request](https://github.com/rails/rails/pull/30241))

*   Pridedama `--skip-yarn` parinktis plugin generatoriui.
    ([Pull Request](https://github.com/rails/rails/pull/30238))

*   Palaikomi keli versijų argumentai `gem` metodo Generators.
    ([Pull Request](https://github.com/rails/rails/pull/30323))

*   Išvestas `secret_key_base` iš programos pavadinimo vystymo ir testavimo
    aplinkose.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Pridedamas `mini_magick` į numatytąjį `Gemfile` kaip komentaras.
    ([Pull Request](https://github.com/rails/rails/pull/30633))

*   `rails new` ir `rails plugin new` pagal numatytuosius nustatymus gauna `Active Storage`.
    Pridėta galimybė praleisti `Active Storage` naudojant `--skip-active-storage`
    ir tai automatiškai daroma, kai naudojamas `--skip-active-record`.
    ([Pull Request](https://github.com/rails/rails/pull/30101))

Action Cable
------------

Išsamius pakeitimus rasite [Changelog][action-cable] puslapyje.
### Pašalinimai

*   Pašalintas pasenusių įvykių redis adapteris.
    ([Commit](https://github.com/rails/rails/commit/48766e32d31651606b9f68a16015ad05c3b0de2c))

### Pastebimi pakeitimai

*   Pridėta palaikymo `host`, `port`, `db` ir `password` parinktys cable.yml
    ([Pull Request](https://github.com/rails/rails/pull/29528))

*   Maišyti ilgi srauto identifikatoriai naudojant PostgreSQL adapterį.
    ([Pull Request](https://github.com/rails/rails/pull/29297))

Veiksmų paketas
-----------

Išsamesnių pakeitimų žr. [Changelog][action-pack].

### Pašalinimai

*   Pašalintas pasenusių `ActionController::ParamsParser::ParseError`.
    ([Commit](https://github.com/rails/rails/commit/e16c765ac6dcff068ff2e5554d69ff345c003de1))

### Pasenusių funkcijų pažymėjimai

*   Pažymėti `#success?`, `#missing?` ir `#error?` sinonimai
    `ActionDispatch::TestResponse`.
    ([Pull Request](https://github.com/rails/rails/pull/30104))

### Pastebimi pakeitimai

*   Pridėtas palaikymas perdirbamiems talpyklos raktams su fragmentų talpinimu.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Pakeistas fragmentų talpyklos raktų formatas, kad būtų lengviau atsekti raktų
    keitimąsi.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   AEAD užšifruoti slapukai ir seansai su GCM.
    ([Pull Request](https://github.com/rails/rails/pull/28132))

*   Numatytuoju būdu apsaugoti nuo padirbimo.
    ([Pull Request](https://github.com/rails/rails/pull/29742))

*   Priversti pasirašytus/užšifruotus slapukus pasibaigti serveryje.
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   Slapukų `:expires` parinktis palaiko `ActiveSupport::Duration` objektą.
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   Naudoti Capybara registruotą `:puma` serverio konfigūraciją.
    ([Pull Request](https://github.com/rails/rails/pull/30638))

*   Supaprastinti slapukų middleware su raktų keitimo palaikymu.
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   Pridėti galimybę įjungti ankstyvus užuominas HTTP/2.
    ([Pull Request](https://github.com/rails/rails/pull/30744))

*   Pridėti galimybę naudoti headless chrome sisteminiuose testuose.
    ([Pull Request](https://github.com/rails/rails/pull/30876))

*   Pridėta `:allow_other_host` parinktis `redirect_back` metode.
    ([Pull Request](https://github.com/rails/rails/pull/30850))

*   Padaryti, kad `assert_recognizes` apdorotų prijungtas variklius.
    ([Pull Request](https://github.com/rails/rails/pull/22435))

*   Pridėta DSL konfigūruoti Content-Security-Policy antraštę.
    ([Pull Request](https://github.com/rails/rails/pull/31162),
    [Commit](https://github.com/rails/rails/commit/619b1b6353a65e1635d10b8f8c6630723a5a6f1a),
    [Commit](https://github.com/rails/rails/commit/4ec8bf68ff92f35e79232fbd605012ce1f4e1e6e))

*   Registruoti dažniausiai naudojamus garso/vaizdo/šriftų MIME tipus,
    palaikomus moderniuose naršyklėse.
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   Pakeistas numatytasis sistemos testų ekrano išvesties formatas iš `inline` į `simple`.
    ([Commit](https://github.com/rails/rails/commit/9d6e288ee96d6241f864dbf90211c37b14a57632))

*   Pridėta galimybė naudoti headless firefox sisteminiuose testuose.
    ([Pull Request](https://github.com/rails/rails/pull/31365))

*   Pridėti saugūs `X-Download-Options` ir `X-Permitted-Cross-Domain-Policies`
    į numatytas antraštes.
    ([Commit](https://github.com/rails/rails/commit/5d7b70f4336d42eabfc403e9f6efceb88b3eff44))

*   Pakeisti sistemos testai, kad Puma būtų numatytasis serveris tik tada, kai
    vartotojas nenurodė kitokio serverio rankiniu būdu.
    ([Pull Request](https://github.com/rails/rails/pull/31384))

*   Pridėta `Referrer-Policy` antraštė į numatytas antraštes.
    ([Commit](https://github.com/rails/rails/commit/428939be9f954d39b0c41bc53d85d0d106b9d1a1))

*   Sutampa su `Hash#each` elgesiu `ActionController::Parameters#each`.
    ([Pull Request](https://github.com/rails/rails/pull/27790))

*   Pridėta palaikymas automatiniam nonce generavimui Rails UJS.
    ([Commit](https://github.com/rails/rails/commit/b2f0a8945956cd92dec71ec4e44715d764990a49))

*   Atnaujinta numatytoji HSTS max-age reikšmė iki 31536000 sekundžių (1 metai),
    kad atitiktų https://hstspreload.org/ minimalų max-age reikalavimą.
    ([Commit](https://github.com/rails/rails/commit/30b5f469a1d30c60d1fb0605e84c50568ff7ed37))

*   Pridėtas sinoniminis metodas `to_hash` `to_h` `cookies`.
    Pridėtas sinoniminis metodas `to_h` `to_hash` `session`.
    ([Commit](https://github.com/rails/rails/commit/50a62499e41dfffc2903d468e8b47acebaf9b500))

Veiksmų peržiūra
-----------

Išsamesnių pakeitimų žr. [Changelog][action-view].
### Pašalinimai

*   Pašalintas pasenusi Erubis ERB tvarkytuvas.
    ([Commit](https://github.com/rails/rails/commit/7de7f12fd140a60134defe7dc55b5a20b2372d06))

### Pasenusi funkcionalumas

*   Pasenusas `image_alt` pagalbininkas, kuris buvo naudojamas pridėti numatytąjį alt tekstą paveikslėliams, kurie buvo sugeneruoti naudojant `image_tag`.
    ([Pull Request](https://github.com/rails/rails/pull/30213))

### Svarbūs pakeitimai

*   Pridėtas `:json` tipas `auto_discovery_link_tag`, kad būtų palaikomi
    [JSON srautai](https://jsonfeed.org/version/1).
    ([Pull Request](https://github.com/rails/rails/pull/29158))

*   Pridėta `srcset` parinktis `image_tag` pagalbininkui.
    ([Pull Request](https://github.com/rails/rails/pull/29349))

*   Ištaisytos problemos su `field_error_proc`, apgaubiančiu `optgroup` ir
    pasirinkimo dalininku `option`.
    ([Pull Request](https://github.com/rails/rails/pull/31088))

*   Pakeistas `form_with` generuoti id pagal numatytuosius nustatymus.
    ([Commit](https://github.com/rails/rails/commit/260d6f112a0ffdbe03e6f5051504cb441c1e94cd))

*   Pridėtas `preload_link_tag` pagalbininkas.
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   Leidžiama naudoti iškviečiamuosius objektus kaip grupės metodus grupuotuose pasirinkimuose.
    ([Pull Request](https://github.com/rails/rails/pull/31578))

Veiksmų siuntėjas
-------------

Išsamesnių pakeitimų žr. [Changelog][action-mailer].

### Svarbūs pakeitimai

*   Leidžiama veiksmų siuntėjo klasėms konfigūruoti pristatymo darbą.
    ([Pull Request](https://github.com/rails/rails/pull/29457))

*   Pridėtas `assert_enqueued_email_with` testavimo pagalbininkas.
    ([Pull Request](https://github.com/rails/rails/pull/30695))

Aktyvusis įrašas
-------------

Išsamesnių pakeitimų žr. [Changelog][active-record].

### Pašalinimai

*   Pašalintas pasenusi `#migration_keys`.
    ([Pull Request](https://github.com/rails/rails/pull/30337))

*   Pašalintas pasenusi palaikymas `quoted_id`, kai konvertuojamas
    Aktyvaus įrašo objektas.
    ([Commit](https://github.com/rails/rails/commit/82472b3922bda2f337a79cef961b4760d04f9689))

*   Pašalinta pasenusi argumento `default` parametrizacija `index_name_exists?`.
    ([Commit](https://github.com/rails/rails/commit/8f5b34df81175e30f68879479243fbce966122d7))

*   Pašalintas pasenusi palaikymas perduoti klasę `:class_name`
    asociacijose.
    ([Commit](https://github.com/rails/rails/commit/e65aff70696be52b46ebe57207ebd8bb2cfcdbb6))

*   Pašalinti pasenusi metodai `initialize_schema_migrations_table` ir
    `initialize_internal_metadata_table`.
    ([Commit](https://github.com/rails/rails/commit/c9660b5777707658c414b430753029cd9bc39934))

*   Pašalintas pasenusi metodas `supports_migrations?`.
    ([Commit](https://github.com/rails/rails/commit/9438c144b1893f2a59ec0924afe4d46bd8d5ffdd))

*   Pašalintas pasenusi metodas `supports_primary_key?`.
    ([Commit](https://github.com/rails/rails/commit/c56ff22fc6e97df4656ddc22909d9bf8b0c2cbb1))

*   Pašalintas pasenusi metodas
    `ActiveRecord::Migrator.schema_migrations_table_name`.
    ([Commit](https://github.com/rails/rails/commit/7df6e3f3cbdea9a0460ddbab445c81fbb1cfd012))

*   Pašalintas pasenusi argumentas `name` iš `#indexes`.
    ([Commit](https://github.com/rails/rails/commit/d6b779ecebe57f6629352c34bfd6c442ac8fba0e))

*   Pašalinti pasenusi argumentai iš `#verify!`.
    ([Commit](https://github.com/rails/rails/commit/9c6ee1bed0292fc32c23dc1c68951ae64fc510be))

*   Pašalinta pasenusi konfigūracija `.error_on_ignored_order_or_limit`.
    ([Commit](https://github.com/rails/rails/commit/e1066f450d1a99c9a0b4d786b202e2ca82a4c3b3))

*   Pašalintas pasenusi metodas `#scope_chain`.
    ([Commit](https://github.com/rails/rails/commit/ef7784752c5c5efbe23f62d2bbcc62d4fd8aacab))

*   Pašalintas pasenusi metodas `#sanitize_conditions`.
    ([Commit](https://github.com/rails/rails/commit/8f5413b896099f80ef46a97819fe47a820417bc2))

### Pasenusi funkcionalumas

*   Pasenusas `supports_statement_cache?`.
    ([Pull Request](https://github.com/rails/rails/pull/28938))

*   Pasenusas argumentų ir bloko perdavimas tuo pačiu metu `count` ir `sum` funkcijoms `ActiveRecord::Calculations`.
    ([Pull Request](https://github.com/rails/rails/pull/29262))

*   Pasenusas delegavimas į `arel` `Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/29619))

*   Pasenusas `set_state` metodas `TransactionState`.
    ([Commit](https://github.com/rails/rails/commit/608ebccf8f6314c945444b400a37c2d07f21b253))

*   Pasenusas `expand_hash_conditions_for_aggregates` be pakeitimo.
    ([Commit](https://github.com/rails/rails/commit/7ae26885d96daee3809d0bd50b1a440c2f5ffb69))

### Svarbūs pakeitimai

*   Kvietus dinaminį fiktyviųjų duomenų gavimo metodą be argumentų, dabar jis grąžina visus šio tipo fiktyvius duomenis. Anksčiau šis metodas visada grąžindavo tuščią masyvą.
    ([Pull Request](https://github.com/rails/rails/pull/28692))

*   Ištaisytas nesuderinamumas su pakeistomis atributų reikšmėmis, kai perrašomas
    Aktyvaus įrašo atributo skaitytuvas.
    ([Pull Request](https://github.com/rails/rails/pull/28661))

*   Palaikoma mažėjanti tvarka MySQL indeksams.
    ([Pull Request](https://github.com/rails/rails/pull/28773))

*   Ištaisytas `bin/rails db:forward` pirmos migracijos veikimas.
    ([Commit](https://github.com/rails/rails/commit/b77d2aa0c336492ba33cbfade4964ba0eda3ef84))

*   Sukeliamas klaidos pranešimas `UnknownMigrationVersionError` perkeldžiant migracijas,
    kai dabartinė migracija neegzistuoja.
    ([Commit](https://github.com/rails/rails/commit/bb9d6eb094f29bb94ef1f26aa44f145f17b973fe))
*   Pagerbti `SchemaDumper.ignore_tables` rake užduotyse duomenų bazės struktūros iškrovimui.
    ([Pull Request](https://github.com/rails/rails/pull/29077))

*   Pridėti `ActiveRecord::Base#cache_version` palaikymą, kad būtų galima naudoti perdirbtinas talpyklos raktus naudojant naujus versijuotus įrašus `ActiveSupport::Cache`. Tai taip pat reiškia, kad `ActiveRecord::Base#cache_key` dabar grąžins stabilų raktą, kuriame nebebus laiko žymės.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Neleisti sukurti parametrų, jei konvertuota reikšmė yra `nil`.
    ([Pull Request](https://github.com/rails/rails/pull/29282))

*   Naudojamas masinis įterpimas, kad būtų pagerinta veiksmingumas įterpiant fiktyvius duomenis.
    ([Pull Request](https://github.com/rails/rails/pull/29504))

*   Sujungiant dvi sąryšius, kurie atstovauja įterptiems sąryšiams, nebesikeičia sujungimai sujungto sąryšio į kairįjį išorinį sujungimą.
    ([Pull Request](https://github.com/rails/rails/pull/27063))

*   Taisomas transakcijų taikymas vaikinėms transakcijoms.
    Anksčiau, jei turėjote įterptą transakciją ir išorinė transakcija buvo atšaukta, įrašas iš vidinės transakcijos vis tiek buvo žymimas kaip išsaugotas. Tai buvo ištaisyta taikant tėvų transakcijos būseną vaikinėms transakcijoms, kai tėvų transakcija yra atšaukiama. Tai teisingai pažymi įrašus iš vidinės transakcijos kaip ne išsaugotas.
    ([Commit](https://github.com/rails/rails/commit/0237da287eb4c507d10a0c6d94150093acc52b03))

*   Taisomas ankstyvasis įkelimas / užkrovimas asociacijos su sąlyga, įskaitant sujungimus.
    ([Pull Request](https://github.com/rails/rails/pull/29413))

*   Neleisti `sql.active_record` pranešimų prenumeratorių klaidų konvertuoti į `ActiveRecord::StatementInvalid` išimtis.
    ([Pull Request](https://github.com/rails/rails/pull/29692))

*   Praleisti užklausos talpinimą dirbant su įrašų grupėmis (`find_each`, `find_in_batches`, `in_batches`).
    ([Commit](https://github.com/rails/rails/commit/b83852e6eed5789b23b13bac40228e87e8822b4d))

*   Pakeisti sqlite3 boolean serijavimą naudojant 1 ir 0.
    SQLite natūraliai atpažįsta 1 ir 0 kaip tiesą ir netiesą, bet anksčiau serijavo 't' ir 'f'.
    ([Pull Request](https://github.com/rails/rails/pull/29699))

*   Reikšmės, sukonstruotos naudojant daugiausiai parametrų priskyrimą, dabar naudos po tipo konvertavimo reikšmę, kad būtų rodomos vieno lauko formos įvestyse.
    ([Commit](https://github.com/rails/rails/commit/1519e976b224871c7f7dd476351930d5d0d7faf6))

*   `ApplicationRecord` daugiau nebus generuojamas generuojant modelius. Jei jums reikia jį sukurti, galite tai padaryti naudodami `rails g application_record`.
    ([Pull Request](https://github.com/rails/rails/pull/29916))

*   `Relation#or` dabar priima du sąryšius, kurių `references` reikšmės skiriasi tik, nes `references` gali būti neaiškiai iškviesta naudojant `where`.
    ([Commit](https://github.com/rails/rails/commit/ea6139101ccaf8be03b536b1293a9f36bc12f2f7))

*   Naudojant `Relation#or`, išskirkite bendras sąlygas ir padėkite jas prieš OR sąlygą.
    ([Pull Request](https://github.com/rails/rails/pull/29950))

*   Pridėti `binary` fiktyvaus pagalbinio metodo.
    ([Pull Request](https://github.com/rails/rails/pull/30073))

*   Automatiškai atspėkite atvirkštinį ryšį STI.
    ([Pull Request](https://github.com/rails/rails/pull/23425))

*   Pridėti naują klaidos klasę `LockWaitTimeout`, kuri bus iškelta, kai viršytas laiko limitas laukiant užrakto.
    ([Pull Request](https://github.com/rails/rails/pull/30360))
* Atnaujinti `sql.active_record` instrumentavimo duomenų pavadinimus, kad jie būtų aiškesni.
    ([Pull Request](https://github.com/rails/rails/pull/30619))

* Naudojamas nurodytas algoritmas, pašalinant indeksą iš duomenų bazės.
    ([Pull Request](https://github.com/rails/rails/pull/24199))

* Perduodant `Set` objektą `Relation#where` metodui, elgesys dabar yra toks pat kaip ir perduodant masyvą.
    ([Commit](https://github.com/rails/rails/commit/9cf7e3494f5bd34f1382c1ff4ea3d811a4972ae2))

* PostgreSQL `tsrange` dabar išlaiko poantrojo tikslumo duomenis.
    ([Pull Request](https://github.com/rails/rails/pull/30725))

* Sukeliamas klaidos pranešimas, kai `lock!` metodas yra iškviestas ant modifikuoto įrašo.
    ([Commit](https://github.com/rails/rails/commit/63cf15877bae859ff7b4ebaf05186f3ca79c1863))

* Ištaisyta klaida, kai indekso stulpelių tvarka nebuvo įrašoma į `db/schema.rb` failą naudojant SQLite adapterį.
    ([Pull Request](https://github.com/rails/rails/pull/30970))

* Ištaisytas `bin/rails db:migrate` su nurodytu `VERSION`.
    `bin/rails db:migrate` su tuščiu VERSION elgiasi kaip ir be VERSION.
    Tikrinamas `VERSION` formato tinkamumas: leidžiamas migracijos versijos numeris arba migracijos failo pavadinimas.
    Klaida išmetama, jei `VERSION` formatas yra netinkamas.
    Klaida išmetama, jei tikslinė migracija neegzistuoja.
    ([Pull Request](https://github.com/rails/rails/pull/30714))

* Pridėta nauja klaidos klasė `StatementTimeout`, kuri bus iškeliama, kai viršytas užklausos vykdymo laikas.
    ([Pull Request](https://github.com/rails/rails/pull/31129))

* `update_all` metodas dabar prieš perduodant reikšmes į `Type#serialize` metodą, perduoda jas į `Type#cast` metodą. Tai reiškia, kad `update_all(foo: 'true')` tinkamai išsaugos boolean reikšmę.
    ([Commit](https://github.com/rails/rails/commit/68fe6b08ee72cc47263e0d2c9ff07f75c4b42761))

* Reikalinga aiškiai pažymėti, kai naudojami neapdoroti SQL fragmentai užklausos metoduose.
    ([Commit](https://github.com/rails/rails/commit/a1ee43d2170dd6adf5a9f390df2b1dde45018a48),
    [Commit](https://github.com/rails/rails/commit/e4a921a75f8702a7dbaf41e31130fe884dea93f9))

* Pridėtas `#up_only` metodas duomenų bazės migracijoms, skirtas kodui, kuris yra aktualus tik migracijos metu, pvz., naujo stulpelio užpildymui.
    ([Pull Request](https://github.com/rails/rails/pull/31082))

* Pridėta nauja klaidos klasė `QueryCanceled`, kuri bus iškeliama, kai užklausa yra nutraukiama dėl vartotojo prašymo.
    ([Pull Request](https://github.com/rails/rails/pull/31235))

* Neleidžiama apibrėžti sąlygų, kurios konfliktuoja su `Relation` klasės egzemplioriaus metodais.
    ([Pull Request](https://github.com/rails/rails/pull/31179))

* Pridėta palaikymo PostgreSQL operatorių klasių `add_index` metode.
    ([Pull Request](https://github.com/rails/rails/pull/19090))

* Registruojami duomenų bazės užklausų kviečiantys elementai.
    ([Pull Request](https://github.com/rails/rails/pull/26815),
    [Pull Request](https://github.com/rails/rails/pull/31519),
    [Pull Request](https://github.com/rails/rails/pull/31690))

* Atšaukiami atributo metodai paveldėtuose objektuose, kai atnaujinami stulpelių informacijos duomenys.
    ([Pull Request](https://github.com/rails/rails/pull/31475))

* Naudojamas subselect metodas `delete_all` su `limit` arba `offset`.
    ([Commit](https://github.com/rails/rails/commit/9e7260da1bdc0770cf4ac547120c85ab93ff3d48))

* Ištaisyta nesuderinamumas su `first(n)` metodu, naudojant `limit()`.
    `first(n)` ieškiklis dabar atsižvelgia į `limit()`, tai padaro jį suderinamą su `relation.to_a.first(n)` elgesiu ir taip pat su `last(n)` elgesiu.
    ([Pull Request](https://github.com/rails/rails/pull/27597))

* Ištaisyta klaida su įeinamaisiais `has_many :through` asociacijomis nepersistuotuose tėviniuose objektuose.
    ([Commit](https://github.com/rails/rails/commit/027f865fc8b262d9ba3ee51da3483e94a5489b66))

* Atsižvelgiama į asociacijos sąlygas, kai trinami per sąlygą susieti įrašai.
    ([Commit](https://github.com/rails/rails/commit/ae48c65e411e01c1045056562319666384bb1b63))

* Neleidžiama keisti sunaikinto objekto po `save` ar `save!` iškvietimo.
    ([Commit](https://github.com/rails/rails/commit/562dd0494a90d9d47849f052e8913f0050f3e494))
*   Ištaisyti ryšio sujungimo problemą naudojant `left_outer_joins`.
    ([Pull Request](https://github.com/rails/rails/pull/27860))

*   Palaikymas PostgreSQL užsienio lentelėms.
    ([Pull Request](https://github.com/rails/rails/pull/31549))

*   Išvalyti transakcijos būseną, kai Active Record objektas yra kopijuojamas.
    ([Pull Request](https://github.com/rails/rails/pull/31751))

*   Ištaisyti neplėtojimo problemą, kai perduodamas masyvo objektas kaip argumentas
    where metodui naudojant `composed_of` stulpelį.
    ([Pull Request](https://github.com/rails/rails/pull/31724))

*   Padaryti, kad `reflection.klass` mestų išimtį, jei `polymorphic?` nebūtų naudojamas neteisingai.
    ([Commit](https://github.com/rails/rails/commit/63fc1100ce054e3e11c04a547cdb9387cd79571a))

*   Ištaisyti `#columns_for_distinct` MySQL ir PostgreSQL, kad
    `ActiveRecord::FinderMethods#limited_ids_for` naudotų teisingus pirminio rakto reikšmes,
    net jei `ORDER BY` stulpeliai apima kitos lentelės pirminį raktą.
    ([Commit](https://github.com/rails/rails/commit/851618c15750979a75635530200665b543561a44))

*   Ištaisyti `dependent: :destroy` problemą has_one/belongs_to ryšyje, kai
    tevo klasė buvo ištrinama, kai vaikas nebuvo.
    ([Commit](https://github.com/rails/rails/commit/b0fc04aa3af338d5a90608bf37248668d59fc881))

*   Neveikiančios duomenų bazės ryšiai (ankstesni tik palikti ryšiai) dabar
    periodiškai yra pašalinami jungčių baseino valykle.
    ([Commit](https://github.com/rails/rails/pull/31221/commits/9027fafff6da932e6e64ddb828665f4b01fc8902))

Active Model
------------

Išsamesniam pakeitimų sąrašui žiūrėkite [Changelog][active-model].

### Pastebimi pakeitimai

*   Ištaisyti metodai `#keys`, `#values` `ActiveModel::Errors`.
    Pakeistas `#keys`, kad grąžintų tik tuos raktus, kuriuose nėra tuščių pranešimų.
    Pakeistas `#values`, kad grąžintų tik ne tuščias reikšmes.
    ([Pull Request](https://github.com/rails/rails/pull/28584))

*   Pridėtas metodas `#merge!` `ActiveModel::Errors`.
    ([Pull Request](https://github.com/rails/rails/pull/29714))

*   Leidžiama perduoti Proc arba Symbol parametrą ilgio tikrinimo nustatymams.
    ([Pull Request](https://github.com/rails/rails/pull/30674))

*   Įvykdyti `ConfirmationValidator` tikrinimą, kai `_confirmation` reikšmė
    yra `false`.
    ([Pull Request](https://github.com/rails/rails/pull/31058))

*   Modeliai, naudojantys atributų API su proc numatytuoju nustatymu, dabar gali būti serijamuojami.
    ([Commit](https://github.com/rails/rails/commit/0af36c62a5710e023402e37b019ad9982e69de4b))

*   Nesugadinti visų daugybinių `:includes` su nustatymais serijavime.
    ([Commit](https://github.com/rails/rails/commit/853054bcc7a043eea78c97e7705a46abb603cc44))

Active Support
--------------

Išsamesniam pakeitimų sąrašui žiūrėkite [Changelog][active-support].

### Pašalinimai

*   Pašalintas pasenusių `:if` ir `:unless` eilučių filtravimo naudojant stringą pasirinkimas.
    ([Commit](https://github.com/rails/rails/commit/c792354adcbf8c966f274915c605c6713b840548))

*   Pašalintas pasenusių `halt_callback_chains_on_return_false` pasirinkimas.
    ([Commit](https://github.com/rails/rails/commit/19fbbebb1665e482d76cae30166b46e74ceafe29))

### Pasenusios funkcijos

*   Pasenusas `Module#reachable?` metodas.
    ([Pull Request](https://github.com/rails/rails/pull/30624))

*   Pasenusas `secrets.secret_token`.
    ([Commit](https://github.com/rails/rails/commit/fbcc4bfe9a211e219da5d0bb01d894fcdaef0a0e))

### Pastebimi pakeitimai

*   Pridėtas `fetch_values` metodas `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28316))

*   Pridėta palaikymas `:offset` parametrui `Time#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   Pridėtas palaikymas `:offset` ir `:zone`
    `ActiveSupport::TimeWithZone#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   Pridėti gem pavadinimas ir pasenusios funkcijos laikotarpis į pranešimus apie pasenusias funkcijas.
    ([Pull Request](https://github.com/rails/rails/pull/28800))

*   Pridėtas palaikymas versijoms skirtoms kešo įrašams. Tai leidžia kešo saugykloms
    pernaudoti kešo raktus, labai taupant vietą dažnai keičiamose situacijose.
    Veikia kartu su `#cache_key` ir `#cache_version` atskyrimu Active Record ir jo naudojimu
    Action Pack fragmentų kešavime.
    ([Pull Request](https://github.com/rails/rails/pull/29092))
*   Pridėkite `ActiveSupport::CurrentAttributes`, kad būtų galima naudoti gijos izoliuotą atributų vienintelę. Pagrindinis naudojimo atvejis yra visų užklausos atributų lengvas prieinamumas visam sistemai.
    ([Pull Request](https://github.com/rails/rails/pull/29180))

*   `#singularize` ir `#pluralize` dabar gerbia neįskaitomus skaičius nurodytai lokalėjai.
    ([Commit](https://github.com/rails/rails/commit/352865d0f835c24daa9a2e9863dcc9dde9e5371a))

*   Pridėkite numatytąją parinktį `class_attribute`.
    ([Pull Request](https://github.com/rails/rails/pull/29270))

*   Pridėkite `Date#prev_occurring` ir `Date#next_occurring`, kad grąžintumėte nurodytą kitą/antrą atsitiktinę savaitės dieną.
    ([Pull Request](https://github.com/rails/rails/pull/26600))

*   Pridėkite numatytąją parinktį modulio ir klasės atributo prieigos metodams.
    ([Pull Request](https://github.com/rails/rails/pull/29294))

*   Cache: `write_multi`.
    ([Pull Request](https://github.com/rails/rails/pull/29366))

*   Numatytoji `ActiveSupport::MessageEncryptor` naudoja AES 256 GCM šifravimą.
    ([Pull Request](https://github.com/rails/rails/pull/29263))

*   Pridėkite `freeze_time` pagalbininką, kuris užšaldytų laiką testuose į `Time.now`.
    ([Pull Request](https://github.com/rails/rails/pull/29681))

*   Padarykite `Hash#reverse_merge!` tvarką nuoseklią su `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28077))

*   Pridėkite paskirties ir galiojimo palaikymą `ActiveSupport::MessageVerifier` ir `ActiveSupport::MessageEncryptor`.
    ([Pull Request](https://github.com/rails/rails/pull/29892))

*   Atnaujinkite `String#camelize`, kad būtų pateikiamas atsakymas, kai perduodama neteisinga parinktis.
    ([Pull Request](https://github.com/rails/rails/pull/30039))

*   `Module#delegate_missing_to` dabar iškelia `DelegationError`, jei tikslas yra `nil`, panašiai kaip `Module#delegate`.
    ([Pull Request](https://github.com/rails/rails/pull/30191))

*   Pridėkite `ActiveSupport::EncryptedFile` ir `ActiveSupport::EncryptedConfiguration`.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Pridėkite `config/credentials.yml.enc`, kad būtų galima saugoti produkcinės programos paslaptis.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Pridėkite raktų keitimo palaikymą `MessageEncryptor` ir `MessageVerifier`.
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   Grąžinkite `HashWithIndifferentAccess` egzempliorių iš `HashWithIndifferentAccess#transform_keys`.
    ([Pull Request](https://github.com/rails/rails/pull/30728))

*   `Hash#slice` dabar naudoja Ruby 2.5+ įdiegtą apibrėžimą, jei jis yra apibrėžtas.
    ([Commit](https://github.com/rails/rails/commit/01ae39660243bc5f0a986e20f9c9bff312b1b5f8))

*   `IO#to_json` dabar grąžina `to_s` atvaizdavimą, o ne bandymą konvertuoti į masyvą. Tai ištaiso klaidą, kai `IO#to_json` iškeltų `IOError`, kai jis būtų iškviestas su negalima objektu.
    ([Pull Request](https://github.com/rails/rails/pull/30953))

*   Pridėkite tą patį metodo parašą `Time#prev_day` ir `Time#next_day`, atitinkamai su `Date#prev_day`, `Date#next_day`. Leidžia perduoti argumentą `Time#prev_day` ir `Time#next_day`.
    ([Commit](https://github.com/rails/rails/commit/61ac2167eff741bffb44aec231f4ea13d004134e))

*   Pridėkite tą patį metodo parašą `Time#prev_month` ir `Time#next_month`, atitinkamai su `Date#prev_month`, `Date#next_month`. Leidžia perduoti argumentą `Time#prev_month` ir `Time#next_month`.
    ([Commit](https://github.com/rails/rails/commit/f2c1e3a793570584d9708aaee387214bc3543530))

*   Pridėkite tą patį metodo parašą `Time#prev_year` ir `Time#next_year`, atitinkamai su `Date#prev_year`, `Date#next_year`. Leidžia perduoti argumentą `Time#prev_year` ir `Time#next_year`.
    ([Commit](https://github.com/rails/rails/commit/ee9d81837b5eba9d5ec869ae7601d7ffce763e3e))

*   Ištaisykite akronimų palaikymą `humanize`.
    ([Commit](https://github.com/rails/rails/commit/0ddde0a8fca6a0ca3158e3329713959acd65605d))

*   Leiskite naudoti `Range#include?` su TWZ intervalais.
    ([Pull Request](https://github.com/rails/rails/pull/31081))

*   Cache: Numatytoji savybių suspaudimo įjungimo reikšmė yra > 1 kB.
    ([Pull Request](https://github.com/rails/rails/pull/31147))

*   Redis kešo saugykla.
    ([Pull Request](https://github.com/rails/rails/pull/31134),
    [Pull Request](https://github.com/rails/rails/pull/31866))

*   Tvarkykite `TZInfo::AmbiguousTime` klaidas.
    ([Pull Request](https://github.com/rails/rails/pull/31128))

*   MemCacheStore: Palaikykite laikinąjį skaitiklį.
    ([Commit](https://github.com/rails/rails/commit/b22ee64b5b30c6d5039c292235e10b24b1057f6d))

*   Padarykite, kad `ActiveSupport::TimeZone.all` grąžintų tik laiko juostas, kurios yra `ActiveSupport::TimeZone::MAPPING`.
    ([Pull Request](https://github.com/rails/rails/pull/31176))
*   Pakeistas `ActiveSupport::SecurityUtils.secure_compare` numatytasis elgesys, kad netekti informacijos apie ilgio net ir kintamo ilgio eilutės. Pervadintas senas `ActiveSupport::SecurityUtils.secure_compare` į `fixed_length_secure_compare` ir pradėta kelti `ArgumentError` klaida, jei perduotų eilučių ilgiai neatitinka.
    ([Pull Request](https://github.com/rails/rails/pull/24510))

*   Naudojamas SHA-1 algoritmas, kad būtų sugeneruojami nesvarbūs skaitmeniniai raktai, pvz., ETag antraštė.
    ([Pull Request](https://github.com/rails/rails/pull/31289),
    [Pull Request](https://github.com/rails/rails/pull/31651))

*   `assert_changes` visada tikrins, ar išraiška pasikeitė, nepriklausomai nuo `from:` ir `to:` argumentų kombinacijų.
    ([Pull Request](https://github.com/rails/rails/pull/31011))

*   Pridėtas trūkstamas instrumentavimas `read_multi` metodui `ActiveSupport::Cache::Store`.
    ([Pull Request](https://github.com/rails/rails/pull/30268))

*   Palaikomas `hash` kaip pirmasis argumentas `assert_difference` metode. Tai leidžia nurodyti kelis skaitinius skirtumus tame pačiame tikrinime.
    ([Pull Request](https://github.com/rails/rails/pull/31600))

*   Podėlio: MemCache ir Redis `read_multi` ir `fetch_multi` pagreitinimas. Pirmiausia skaitykite iš vietinės atmintinės podėlio, o tik tada kreipkitės į pagrindinį serverį.
    ([Commit](https://github.com/rails/rails/commit/a2b97e4ffef971607a1be8fc7909f099b6840f36))

Active Job
----------

Išsamius pakeitimus žiūrėkite [Changelog][active-job].

### Pastebimi pakeitimai

*   Leidžiama perduoti bloką į `ActiveJob::Base.discard_on`, kad būtų galima pasirinktinai tvarkyti atmetamus darbus.
    ([Pull Request](https://github.com/rails/rails/pull/30622))

Ruby on Rails vadovai
--------------------

Išsamius pakeitimus žiūrėkite [Changelog][guides].

### Pastebimi pakeitimai

*   Pridėtas [Gijų ir kodo vykdymas Rails](threading_and_code_execution.html) vadovas.
    ([Pull Request](https://github.com/rails/rails/pull/27494))

*   Pridėtas [Active Storage apžvalga](active_storage_overview.html) vadovas.
    ([Pull Request](https://github.com/rails/rails/pull/31037))

Autoriai
-------

Žiūrėkite [visą sąrašą žmonių, prisidėjusių prie Rails](https://contributors.rubyonrails.org/), kurie daug valandų skyrė kurti Rails, stabilų ir patikimą karkasą. Jie visi nusipelno pagyrimo.
[active-support]: https://github.com/rails/rails/blob/5-2-stable/activesupport/CHANGELOG.md
