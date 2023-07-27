**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b1c2c8ad5c4bacb2e3b92aa320c4da3d
Ruby on Rails 6.0 Išleidimo Pastabos
=====================================

Svarbiausi dalykai Rails 6.0 versijoje:

* Action Mailbox
* Action Text
* Parallel Testing
* Action Cable Testing

Šios išleidimo pastabos apima tik pagrindinius pokyčius. Norėdami sužinoti apie įvairius klaidų taisymus ir pokyčius, prašome kreiptis į pokyčių žurnalus arba peržiūrėti [pokyčių sąrašą](https://github.com/rails/rails/commits/6-0-stable) pagrindiniame Rails saugykloje GitHub.

--------------------------------------------------------------------------------

Atnaujinimas į Rails 6.0
------------------------

Jei atnaujinote esamą programą, gerai būtų turėti geras testavimo padengimo galimybes prieš pradedant. Taip pat pirmiausia turėtumėte atnaujinti iki Rails 5.2 versijos, jei dar to nepadarėte, ir įsitikinti, kad jūsų programa vis dar veikia kaip tikėtasi, prieš bandant atnaujinti į Rails 6.0. Atnaujinimo metu reikėtų atkreipti dėmesį į tam tikrus dalykus, kuriuos galima rasti [Atnaujinimo Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-2-to-rails-6-0) vadove.

Pagrindinės funkcijos
---------------------

### Action Mailbox

[Pull Request](https://github.com/rails/rails/pull/34786)

[Action Mailbox](https://github.com/rails/rails/tree/6-0-stable/actionmailbox) leidžia jums nukreipti gautus el. laiškus į kontrolerio panašius pašto dėžutes.
Apie Action Mailbox galite sužinoti daugiau [Action Mailbox Basics](action_mailbox_basics.html) vadove.

### Action Text

[Pull Request](https://github.com/rails/rails/pull/34873)

[Action Text](https://github.com/rails/rails/tree/6-0-stable/actiontext)
į Rails įtraukia turtingo teksto turinį ir redagavimą. Tai apima
[Trix redaktorių](https://trix-editor.org), kuris tvarko viską nuo formatavimo
iki nuorodų, citatų, sąrašų, įterptų vaizdų ir galerijų.
Trix redaktoriaus sugeneruotas turtingas teksto turinys yra išsaugomas savo
RichText modelyje, kuris yra susijęs su bet kuriuo esamu Active Record modeliu programoje.
Visi įterpti vaizdai (ar kiti priedai) automatiškai saugomi naudojant
Active Storage ir susijungia su įtrauktu RichText modeliu.

Apie Action Text galite sužinoti daugiau [Action Text Overview](action_text_overview.html) vadove.

### Parallel Testing

[Pull Request](https://github.com/rails/rails/pull/31900)

[Parallel Testing](testing.html#parallel-testing) leidžia jums padalinti
testų rinkinį į kelias dalis ir vykdyti jas vienu metu. Nors numatytasis būdas yra kurti naujus procesus, taip pat palaikomas gijų naudojimas. Testų vykdymas vienu metu sumažina viso testų rinkinio vykdymo laiką.

### Action Cable Testing

[Pull Request](https://github.com/rails/rails/pull/33659)

[Action Cable testavimo įrankiai](testing.html#testing-action-cable) leidžia jums testuoti
Action Cable funkcionalumą bet kuriuo lygmeniu: ryšiai, kanalai, transliacijos.

Railties
--------

Detalius pokyčius žiūrėkite [Changelog][railties].

### Pašalinimai

*   Pašalintas pasenusių `after_bundle` pagalbininkas vidiniuose įskiepių šablonuose.
    ([Commit](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

*   Pašalinta pasenusi parametrų `config.ru`, kuris naudoja programos
    klasę kaip `run` argumentą.
    ([Commit](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))
*   Pašalintas pasenusi `environment` argumentas iš `rails` komandų.
    ([Commit](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

*   Pašalintas pasenusi `capify!` metodas generatoriuose ir šablonuose.
    ([Commit](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

*   Pašalintas pasenusi `config.secret_token`.
    ([Commit](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### Pasenusi funkcionalumas

*   Pasenusi galimybė perduoti Rack serverio pavadinimą kaip įprastą argumentą `rails server` komandoje.
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   Pasenusi galimybė naudoti `HOST` aplinkos kintamąjį nurodyti serverio IP adresą.
    ([Pull Request](https://github.com/rails/rails/pull/32540))

*   Pasenusi galimybė pasiekti `config_for` grąžintus hash'us naudojant ne simbolius kaip raktus.
    ([Pull Request](https://github.com/rails/rails/pull/35198))

### Svarbūs pakeitimai

*   Pridėta aiški parinktis `--using` arba `-u` nurodyti serverį `rails server` komandoje.
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   Pridėta galimybė matyti `rails routes` rezultatus išplėstiniu formatu.
    ([Pull Request](https://github.com/rails/rails/pull/32130))

*   Paleidžiamas duomenų bazės seed užduotis naudojant inline Active Job adapterį.
    ([Pull Request](https://github.com/rails/rails/pull/34953))

*   Pridėta komanda `rails db:system:change` pakeisti aplikacijos duomenų bazę.
    ([Pull Request](https://github.com/rails/rails/pull/34832))

*   Pridėta `rails test:channels` komanda testuoti tik Action Cable kanalus.
    ([Pull Request](https://github.com/rails/rails/pull/34947))

*   Įvestas saugos mechanizmas nuo DNS rebinding atakų.
    ([Pull Request](https://github.com/rails/rails/pull/33145))

*   Pridėta galimybė nutraukti vykdymą klaidos atveju vykdant generatorių komandas.
    ([Pull Request](https://github.com/rails/rails/pull/34420))

*   Padarytas Webpacker numatytasis JavaScript kompiliatorius Rails 6 versijoje.
    ([Pull Request](https://github.com/rails/rails/pull/33079))

*   Pridėta galimybė naudoti kelis duomenų bazes `rails db:migrate:status` komandoje.
    ([Pull Request](https://github.com/rails/rails/pull/34137))

*   Pridėta galimybė naudoti skirtingus migracijų keliai iš kelių duomenų bazės generatoriuose.
    ([Pull Request](https://github.com/rails/rails/pull/34021))

*   Pridėta palaikymas daugiaaplinkos kredencialių.
    ([Pull Request](https://github.com/rails/rails/pull/33521))

*   Testų aplinkoje `null_store` tapo numatytuoju kešo saugyklos tipu.
    ([Pull Request](https://github.com/rails/rails/pull/33773))

Action Cable
------------

Išsamesnius pakeitimus žr. [Changelog][action-cable].

### Pašalinimai

*   Pakeisti `ActionCable.startDebugging()` ir `ActionCable.stopDebugging()`
    su `ActionCable.logger.enabled`.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

### Pasenusi funkcionalumas

*   Rails 6.0 versijoje nėra jokių pasenusių funkcionalumų Action Cable.

### Svarbūs pakeitimai

*   Pridėta palaikymas `channel_prefix` parinkčiai PostgreSQL prenumeratos adapteriuose
    `cable.yml` faile.
    ([Pull Request](https://github.com/rails/rails/pull/35276))

*   Leidžiama perduoti pasirinktinę konfigūraciją `ActionCable::Server::Base`.
    ([Pull Request](https://github.com/rails/rails/pull/34714))

*   Pridėti `:action_cable_connection` ir `:action_cable_channel` užkrovimo "hooks".
    ([Pull Request](https://github.com/rails/rails/pull/35094))

*   Pridėti `Channel::Base#broadcast_to` ir `Channel::Base.broadcasting_for`.
    ([Pull Request](https://github.com/rails/rails/pull/35021))

*   Uždaryti ryšį kviečiant `reject_unauthorized_connection` iš `ActionCable::Connection`.
    ([Pull Request](https://github.com/rails/rails/pull/34194))

*   Konvertuoti Action Cable JavaScript paketą iš CoffeeScript į ES2015 ir
    paskelbti šaltinio kodą npm platinime.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

*   Perkelti WebSocket adapterio ir logger adapterio konfigūraciją
    iš `ActionCable` savybių į `ActionCable.adapters`.
    ([Pull Request](https://github.com/rails/rails/pull/34370))
* Pridėkite `id` parinktį prie Redis adapterio, kad būtų galima atskirti Action Cable's Redis ryšius.
    ([Pull Request](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

Išsamius pakeitimus žiūrėkite [Changelog][action-pack].

### Pašalinimai

* Pašalintas pasenusiųjų `fragment_cache_key` pagalbininkas naudai `combined_fragment_cache_key`.
    ([Commit](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

* Pašalinti pasenusiųjų metodai `ActionDispatch::TestResponse`:
    `#success?` naudai `#successful?`, `#missing?` naudai `#not_found?`,
    `#error?` naudai `#server_error?`.
    ([Commit](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### Pasenusiųjų metodų naudojimas

* Pasenusi `ActionDispatch::Http::ParameterFilter` naudai `ActiveSupport::ParameterFilter`.
    ([Pull Request](https://github.com/rails/rails/pull/34039))

* Pasenusi valdiklio lygmens `force_ssl` naudai `config.force_ssl`.
    ([Pull Request](https://github.com/rails/rails/pull/32277))

### Svarbūs pakeitimai

* Pakeistas `ActionDispatch::Response#content_type` grąžinantis Content-Type antraštę kaip yra.
    ([Pull Request](https://github.com/rails/rails/pull/36034))

* Jei resurso parametras turi dvitaškį, iškeliamas `ArgumentError`.
    ([Pull Request](https://github.com/rails/rails/pull/35236))

* Leidžiama `ActionDispatch::SystemTestCase.driven_by` iškviesti su bloku,
    kad būtų galima nustatyti konkretaus naršyklės galimybes.
    ([Pull Request](https://github.com/rails/rails/pull/35081))

* Pridėtas `ActionDispatch::HostAuthorization` middleware, kuris apsaugo nuo DNS rebinding atakų.
    ([Pull Request](https://github.com/rails/rails/pull/33145))

* Leidžiama naudoti `parsed_body` `ActionController::TestCase`.
    ([Pull Request](https://github.com/rails/rails/pull/34717))

* Iškeliamas `ArgumentError`, kai tame pačiame kontekste yra kelios šaknies maršrutai
    be `as:` pavadinimo specifikacijų.
    ([Pull Request](https://github.com/rails/rails/pull/34494))

* Leidžiama naudoti `#rescue_from` parametrų analizės klaidoms tvarkyti.
    ([Pull Request](https://github.com/rails/rails/pull/34341))

* Pridėtas `ActionController::Parameters#each_value` parametrų peržiūrai.
    ([Pull Request](https://github.com/rails/rails/pull/33979))

* Koduojami Content-Disposition failų pavadinimai `send_data` ir `send_file`.
    ([Pull Request](https://github.com/rails/rails/pull/33829))

* Iškeliamas `ActionController::Parameters#each_key`.
    ([Pull Request](https://github.com/rails/rails/pull/33758))

* Pridedama paskirtis ir galiojimo metaduomenys į pasirašytus/užšifruotus slapukus,
    kad būtų užkirstas kelias kopijuoti slapuko reikšmę į kitą.
    ([Pull Request](https://github.com/rails/rails/pull/32937))

* Iškeliamas `ActionController::RespondToMismatchError` konfliktuojant `respond_to` iškvietimams.
    ([Pull Request](https://github.com/rails/rails/pull/33446))

* Pridėta aiški klaidų puslapių informacija, kai užklausos formatui trūksta šablonų.
    ([Pull Request](https://github.com/rails/rails/pull/29286))

* Įdiegta `ActionDispatch::DebugExceptions.register_interceptor`, būdas įsikišti į
    DebugExceptions ir apdoroti išimtį prieš ją atvaizduojant.
    ([Pull Request](https://github.com/rails/rails/pull/23868))

* Išvedama tik viena Content-Security-Policy nonce antraštės reikšmė užklausai.
    ([Pull Request](https://github.com/rails/rails/pull/32602))

* Pridėtas modulis specifiškai Rails numatytų antraščių konfigūracijai,
    kuris gali būti aiškiai įtrauktas į valdiklius.
    ([Pull Request](https://github.com/rails/rails/pull/32484))

* Pridėtas `#dig` į `ActionDispatch::Request::Session`.
    ([Pull Request](https://github.com/rails/rails/pull/32446))

Action View
-----------

Išsamius pakeitimus žiūrėkite [Changelog][action-view].

### Pašalinimai

* Pašalintas pasenusiųjų `image_alt` pagalbininkas.
    ([Commit](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f))

* Pašalintas tuščias `RecordTagHelper` modulis, iš kurio funkcionalumas
    jau buvo perkeltas į `record_tag_helper` gemą.
    ([Commit](https://github.com/rails/rails/commit/5c5ddd69b1e06fb6b2bcbb021e9b8dae17e7cb31))

### Pasenusiųjų metodų naudojimas

* Pasenusi `ActionView::Template.finalize_compiled_template_methods` be pakeitimo.
    ([Pull Request](https://github.com/rails/rails/pull/35036))
*   Pasenus `config.action_view.finalize_compiled_template_methods` be pakeitimo.
    ([Pull Request](https://github.com/rails/rails/pull/35036))

*   Pasenus privačių modelio metodų iškvietimą iš `options_from_collection_for_select` vaizdo pagalbininko.
    ([Pull Request](https://github.com/rails/rails/pull/33547))

### Svarbūs pakeitimai

*   Išvalyti Action View talpyklą tik vystymo režime, kai keičiamas failas, pagreitinant
    vystymo režimą.
    ([Pull Request](https://github.com/rails/rails/pull/35629))

*   Perkelti visus „Rails“ npm paketus į `@rails` sritį.
    ([Pull Request](https://github.com/rails/rails/pull/34905))

*   Priimti formatų tik iš registruotų MIME tipų.
    ([Pull Request](https://github.com/rails/rails/pull/35604), [Pull Request](https://github.com/rails/rails/pull/35753))

*   Pridėti išteklių paskirstymą šablonų ir dalinių atvaizdavimo serverio išvestyje.
    ([Pull Request](https://github.com/rails/rails/pull/34136))

*   Pridėti `year_format` parinktį `date_select` žymėje, leidžianti
    tinkinti metų pavadinimus.
    ([Pull Request](https://github.com/rails/rails/pull/32190))

*   Pridėti `nonce: true` parinktį `javascript_include_tag` pagalbininkui,
    palaikantį automatinį nonce generavimą saugumo politikos turiniui.
    ([Pull Request](https://github.com/rails/rails/pull/32607))

*   Pridėti `action_view.finalize_compiled_template_methods` konfigūraciją, kad būtų galima išjungti arba
    įjungti `ActionView::Template` finalizatorius.
    ([Pull Request](https://github.com/rails/rails/pull/32418))

*   Išskirti JavaScript `confirm` iškvietimą į savo, perrašomą metodą `rails_ujs`.
    ([Pull Request](https://github.com/rails/rails/pull/32404))

*   Pridėti `action_controller.default_enforce_utf8` konfigūracijos parinktį, skirtą tvarkyti
    UTF-8 kodavimo privalomumą. Pagal nutylėjimą tai yra `false`.
    ([Pull Request](https://github.com/rails/rails/pull/32125))

*   Pridėti I18n rakto stiliaus palaikymą lokalės rakto pateikimo žymėms.
    ([Pull Request](https://github.com/rails/rails/pull/26799))

Veiksmų siuntėjas
-------------

Išsamesnius pakeitimus žr. [Changelog][action-mailer].

### Pašalinimai

### Pasenusių funkcijų pranešimai

*   Pasenusi `ActionMailer::Base.receive` naudai Action Mailbox.
    ([Commit](https://github.com/rails/rails/commit/e3f832a7433a291a51c5df397dc3dd654c1858cb))

*   Pasenusi `DeliveryJob` ir `Parameterized::DeliveryJob` naudai
    `MailDeliveryJob`.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

### Svarbūs pakeitimai

*   Pridėti `MailDeliveryJob` pranešimų pristatymui, įskaitant ir parametrizuotus pranešimus.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

*   Leisti pasirinkti šablonų pavadinimą daugialypiams laiškams su blokais, o ne
    naudoti tik veiksmo pavadinimą.
    ([Pull Request](https://github.com/rails/rails/pull/22534))

*   Pridėti `perform_deliveries` į `deliver.action_mailer` pranešimo duomenis.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   Gerinti žurnalo pranešimą, kai `perform_deliveries` yra `false`, nurodant,
    kad laiškų siuntimas buvo praleistas.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   Leisti iškviesti `assert_enqueued_email_with` be bloko.
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   Atlikti laiškų pristatymo darbus eilėje esant `assert_emails` bloke.
    ([Pull Request](https://github.com/rails/rails/pull/32231))

*   Leisti `ActionMailer::Base` atšaukti stebėtojus ir perceptorius.
    ([Pull Request](https://github.com/rails/rails/pull/32207))

Aktyvus įrašas
-------------

Išsamesnius pakeitimus žr. [Changelog][active-record].

### Pašalinimai

*   Pašalinti pasenusį `#set_state` iš transakcijos objekto.
    ([Commit](https://github.com/rails/rails/commit/6c745b0c5152a4437163a67707e02f4464493983))

*   Pašalinti pasenusį `#supports_statement_cache?` iš duomenų bazės adapterių.
    ([Commit](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553))
*   Pašalintas pasenusi `#insert_fixtures` iš duomenų bazės adapterių.
    ([Commit](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece))

*   Pašalintas pasenusi `ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?`.
    ([Commit](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf))

*   Pašalinta galimybė perduoti stulpelio pavadinimą į `sum`, kai perduodamas blokas.
    ([Commit](https://github.com/rails/rails/commit/91ddb30083430622188d76eb9f29b78131df67f9))

*   Pašalinta galimybė perduoti stulpelio pavadinimą į `count`, kai perduodamas blokas.
    ([Commit](https://github.com/rails/rails/commit/67356f2034ab41305af7218f7c8b2fee2d614129))

*   Pašalinta galimybė deleguoti trūkstamus metodus iš sąryšio į Arel.
    ([Commit](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0))

*   Pašalinta galimybė deleguoti trūkstamus metodus iš sąryšio į klasės privačius metodus.
    ([Commit](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d))

*   Pašalinta galimybė nurodyti laiko žymės pavadinimą `#cache_key`.
    ([Commit](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea))

*   Pašalintas pasenusi `ActiveRecord::Migrator.migrations_path=`.
    ([Commit](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d))

*   Pašalintas pasenusi `expand_hash_conditions_for_aggregates`.
    ([Commit](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e))


### Pasenusi funkcionalumas

*   Pasenkinama neatitinkančių didžiosios ir mažosios raidės jautrios lyginimo sujungties validavimo funkcija.
    ([Commit](https://github.com/rails/rails/commit/9def05385f1cfa41924bb93daa187615e88c95b9))

*   Pasenkinama klasės lygio užklausų metodų naudojimas, jei gavėjo apimtis yra ištekliai.
    ([Pull Request](https://github.com/rails/rails/pull/35280))

*   Pasenkinama `config.active_record.sqlite3.represent_boolean_as_integer` nustatymo funkcija.
    ([Commit](https://github.com/rails/rails/commit/f59b08119bc0c01a00561d38279b124abc82561b))

*   Pasenkinama `migrations_paths` perdavimas į `connection.assume_migrated_upto_version`.
    ([Commit](https://github.com/rails/rails/commit/c1b14aded27e063ead32fa911aa53163d7cfc21a))

*   Pasenkinama `ActiveRecord::Result#to_hash` funkcija naudoti `ActiveRecord::Result#to_a` vietoje.
    ([Commit](https://github.com/rails/rails/commit/16510d609c601aa7d466809f3073ec3313e08937))

*   Pasenkinami metodai `DatabaseLimits`: `column_name_length`, `table_name_length`,
    `columns_per_table`, `indexes_per_table`, `columns_per_multicolumn_index`,
    `sql_query_length` ir `joins_per_query`.
    ([Commit](https://github.com/rails/rails/commit/e0a1235f7df0fa193c7e299a5adee88db246b44f))

*   Pasenkinami `update_attributes`/`!` metodai naudoti `update`/`!` vietoje.
    ([Commit](https://github.com/rails/rails/commit/5645149d3a27054450bd1130ff5715504638a5f5))

### Svarbūs pakeitimai

*   Padidintas `sqlite3` gemo minimalus versijos numeris iki 1.4.
    ([Pull Request](https://github.com/rails/rails/pull/35844))

*   Pridėtas `rails db:prepare` komandos variantas, kuris sukurs duomenų bazę, jei ji neegzistuoja, ir paleis jos migracijas.
    ([Pull Request](https://github.com/rails/rails/pull/35768))

*   Pridėtas `after_save_commit` atgalinis kvietimas kaip trumpinys `after_commit :hook, on: [ :create, :update ]`.
    ([Pull Request](https://github.com/rails/rails/pull/35804))

*   Pridėtas `ActiveRecord::Relation#extract_associated` metodas, skirtas ištraukti susijusius įrašus iš sąryšio.
    ([Pull Request](https://github.com/rails/rails/pull/35784))

*   Pridėtas `ActiveRecord::Relation#annotate` metodas, skirtas pridėti SQL komentarus prie ActiveRecord::Relation užklausų.
    ([Pull Request](https://github.com/rails/rails/pull/35617))

*   Pridėta galimybė nustatyti Optimizer Hints duomenų bazėse.
    ([Pull Request](https://github.com/rails/rails/pull/35615))

*   Pridėti `insert_all`/`insert_all!`/`upsert_all` metodai masiniam įrašų įterpimui.
    ([Pull Request](https://github.com/rails/rails/pull/35631))

*   Pridėta `rails db:seed:replant` komanda, kuri išvalo kiekvienos duomenų bazės lentelės duomenis
    esamam aplinkai ir įkelia sėklas.
    ([Pull Request](https://github.com/rails/rails/pull/34779))

*   Pridėtas `reselect` metodas, kuris yra trumpinys `unscope(:select).select(fields)`.
    ([Pull Request](https://github.com/rails/rails/pull/33611))

*   Pridėtos neigiamos sąlygos visiems enum reikšmėms.
    ([Pull Request](https://github.com/rails/rails/pull/35381))

*   Pridėti `#destroy_by` ir `#delete_by` metodai sąlyginiam pašalinimui.
    ([Pull Request](https://github.com/rails/rails/pull/35316))

*   Pridėta galimybė automatiškai keisti duomenų bazės ryšius.
    ([Pull Request](https://github.com/rails/rails/pull/35073))

*   Pridėta galimybė bloko vykdymo metu uždrausti rašymą į duomenų bazę.
    ([Pull Request](https://github.com/rails/rails/pull/34505))

*   Pridėta API, skirta keisti ryšius ir palaikyti kelias duomenų bazes.
    ([Pull Request](https://github.com/rails/rails/pull/34052))
*   Nustatyti laiko žymas su tikslumu kaip numatytąją reikšmę migracijoms.
    ([Pull Request](https://github.com/rails/rails/pull/34970))

*   Palaikyti `:size` parinktį, kad būtų galima keisti teksto ir blob dydį MySQL duomenų bazėje.
    ([Pull Request](https://github.com/rails/rails/pull/35071))

*   Nustatyti tiek užsienio rakto, tiek užsienio tipo stulpelius kaip NULL reikšmes polimorfinėms asociacijoms, naudojant `dependent: :nullify` strategiją.
    ([Pull Request](https://github.com/rails/rails/pull/28078))

*   Leisti perduoti leistiną `ActionController::Parameters` egzempliorių kaip argumentą į `ActiveRecord::Relation#exists?` metodą.
    ([Pull Request](https://github.com/rails/rails/pull/34891))

*   Pridėti palaikymą `#where` metode be galo ribų, kurios buvo įvestos Ruby 2.6 versijoje.
    ([Pull Request](https://github.com/rails/rails/pull/34906))

*   Nustatyti `ROW_FORMAT=DYNAMIC` kaip numatytąją reikšmę `create table` MySQL užklausose.
    ([Pull Request](https://github.com/rails/rails/pull/34742))

*   Pridėti galimybę išjungti `ActiveRecord.enum` sugeneruojamus ribojimus.
    ([Pull Request](https://github.com/rails/rails/pull/34605))

*   Padaryti neprivalomą rikiavimą konfigūruojamą stulpeliui.
    ([Pull Request](https://github.com/rails/rails/pull/34480))

*   Padidinti minimalią PostgreSQL versiją iki 9.3, panaikinant palaikymą 9.1 ir 9.2 versijoms.
    ([Pull Request](https://github.com/rails/rails/pull/34520))

*   Padaryti enum reikšmes užšaldytas ir iškelti klaidą, bandant jas keisti.
    ([Pull Request](https://github.com/rails/rails/pull/34517))

*   Padaryti `ActiveRecord::StatementInvalid` klaidų SQL užklausą atskiru klaidos atributu ir įtraukti SQL parametrus kaip atskirą klaidos atributą.
    ([Pull Request](https://github.com/rails/rails/pull/34468))

*   Pridėti `:if_not_exists` parinktį `create_table` metode.
    ([Pull Request](https://github.com/rails/rails/pull/31382))

*   Pridėti palaikymą kelioms duomenų bazėms `rails db:schema:cache:dump` ir `rails db:schema:cache:clear` komandose.
    ([Pull Request](https://github.com/rails/rails/pull/34181))

*   Pridėti palaikymą hash ir url konfigūracijoms `ActiveRecord::Base.connected_to` duomenų bazės hash'e.
    ([Pull Request](https://github.com/rails/rails/pull/34196))

*   Pridėti palaikymą numatytoms išraiškoms ir išraiškų indeksams MySQL duomenų bazėje.
    ([Pull Request](https://github.com/rails/rails/pull/34307))

*   Pridėti `index` parinktį `change_table` migracijų pagalbininkams.
    ([Pull Request](https://github.com/rails/rails/pull/23593))

*   Taisyti `transaction` atšaukimą migracijoms. Anksčiau, komandos viduje `transaction` atšaukimo migracijoje buvo vykdomos be atšaukimo. Šis pakeitimas tai taiso.
    ([Pull Request](https://github.com/rails/rails/pull/31604))

*   Leisti `ActiveRecord::Base.configurations=` nustatyti su simbolizuotu hash'u.
    ([Pull Request](https://github.com/rails/rails/pull/33968))

*   Taisyti skaitiklio kešavimą, kad atnaujintų tik tada, kai įrašas iš tikrųjų yra išsaugotas.
    ([Pull Request](https://github.com/rails/rails/pull/33913))

*   Pridėti išraiškų indeksų palaikymą SQLite adapteriui.
    ([Pull Request](https://github.com/rails/rails/pull/33874))

*   Leisti pakartotinai apibrėžti autosave atgalinio kvietimo metodus susijusiems įrašams.
    ([Pull Request](https://github.com/rails/rails/pull/33378))

*   Padidinti minimalią MySQL versiją iki 5.5.8.
    ([Pull Request](https://github.com/rails/rails/pull/33853))

*   Numatytoji MySQL simbolių rinkinio reikšmė pakeista į utf8mb4.
    ([Pull Request](https://github.com/rails/rails/pull/33608))

*   Pridėti galimybę filtruoti jautrią informaciją `#inspect` metode.
    ([Pull Request](https://github.com/rails/rails/pull/33756), [Pull Request](https://github.com/rails/rails/pull/34208))

*   Pakeisti `ActiveRecord::Base.configurations` grąžinti objektą vietoje hash'o.
    ([Pull Request](https://github.com/rails/rails/pull/33637))
*   Pridėkite duomenų bazės konfigūraciją, kad išjungtumėte patarimų užraktus.
    ([Pull Request](https://github.com/rails/rails/pull/33691))

*   Atnaujinkite SQLite3 adapterio `alter_table` metodą, kad atkurtumėte užsienio raktus.
    ([Pull Request](https://github.com/rails/rails/pull/33585))

*   Leiskite `:to_table` opcijai `remove_foreign_key` būti invertuojamai.
    ([Pull Request](https://github.com/rails/rails/pull/33530))

*   Ištaisykite numatytąją reikšmę MySQL laiko tipams su nurodytu tikslumu.
    ([Pull Request](https://github.com/rails/rails/pull/33280))

*   Ištaisykite `touch` opciją, kad elgtųsi nuosekliai su `Persistence#touch` metodu.
    ([Pull Request](https://github.com/rails/rails/pull/33107))

*   Iškelkite išimtį dėl pasikartojančių stulpelių apibrėžimų migracijose.
    ([Pull Request](https://github.com/rails/rails/pull/33029))

*   Padidinkite minimalią SQLite versiją iki 3.8.
    ([Pull Request](https://github.com/rails/rails/pull/32923))

*   Ištaisykite pagrindinius įrašus, kad nebebūtų išsaugomi su pasikartojančiais vaikų įrašais.
    ([Pull Request](https://github.com/rails/rails/pull/32952))

*   Užtikrinkite, kad `Associations::CollectionAssociation#size` ir `Associations::CollectionAssociation#empty?`
    naudotų įkeltų asociacijų id, jei jie yra.
    ([Pull Request](https://github.com/rails/rails/pull/32617))

*   Pridėkite palaikymą išankstiniam įkėlimui asociacijų polimorfinėse asociacijose, kai ne visi įrašai turi reikiamas asociacijas.
    ([Commit](https://github.com/rails/rails/commit/75ef18c67c29b1b51314b6c8a963cee53394080b))

*   Pridėkite `touch_all` metodą į `ActiveRecord::Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/31513))

*   Pridėkite `ActiveRecord::Base.base_class?` predikatą.
    ([Pull Request](https://github.com/rails/rails/pull/32417))

*   Pridėkite pasirinktinius prefikso / sufikso variantus `ActiveRecord::Store.store_accessor`.
    ([Pull Request](https://github.com/rails/rails/pull/32306))

*   Pridėkite `ActiveRecord::Base.create_or_find_by`/`!` metodą, skirtą susidoroti su SELECT/INSERT lenktynių sąlyga
    `ActiveRecord::Base.find_or_create_by`/`!` pagalba remiantis unikaliomis apribojimais duomenų bazėje.
    ([Pull Request](https://github.com/rails/rails/pull/31989))

*   Pridėkite `Relation#pick` kaip trumpinį vieno reikšmės plucks.
    ([Pull Request](https://github.com/rails/rails/pull/31941))

Aktyvus saugojimas
--------------

Išsamiems pakeitimams žiūrėkite [Changelog][active-storage].

### Pašalinimai

### Pasenusios funkcijos

*   Pasenusi `config.active_storage.queue` konfigūracija naudai `config.active_storage.queues.analysis`
    ir `config.active_storage.queues.purge`.
    ([Pull Request](https://github.com/rails/rails/pull/34838))

*   Pasenusi `ActiveStorage::Downloading` naudai `ActiveStorage::Blob#open`.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Pasenusi `mini_magick` tiesioginio naudojimo funkcija paveikslėlių variantams generuoti naudai
    `image_processing`.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

*   Pasenusi `:combine_options` funkcija Active Storage's ImageProcessing transformatoriuje
    be pakeitimo.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

### Pastebimi pakeitimai

*   Pridėkite palaikymą BMP paveikslėlių variantams generuoti.
    ([Pull Request](https://github.com/rails/rails/pull/36051))

*   Pridėkite palaikymą TIFF paveikslėlių variantams generuoti.
    ([Pull Request](https://github.com/rails/rails/pull/34824))

*   Pridėkite palaikymą progresyviems JPEG paveikslėlių variantams generuoti.
    ([Pull Request](https://github.com/rails/rails/pull/34455))

*   Pridėkite `ActiveStorage.routes_prefix` konfigūracijai, skirtai konfigūruoti Active Storage sugeneruotus maršrutus.
    ([Pull Request](https://github.com/rails/rails/pull/33883))

*   Generuokite 404 Not Found atsakymą `ActiveStorage::DiskController#show` metu, kai
    prašomas failas trūksta iš disko paslaugos.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   Iškelkite `ActiveStorage::FileNotFoundError` išimtį, kai prašomas failas trūksta
    `ActiveStorage::Blob#download` ir `ActiveStorage::Blob#open`.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   Pridėkite bendrą `ActiveStorage::Error` klasę, iš kurios paveldi Active Storage išimtys.
    ([Commit](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))

*   Išsaugokite įkeltus failus, priskirtus įrašui, į saugyklą, kai įrašas
    yra išsaugomas, o ne iš karto.
    ([Pull Request](https://github.com/rails/rails/pull/33303))
*   Galimai pakeisti esamas failus vietoj jų pridėjimo, kai priskiriamas prie priedų kolekcijos (pvz., `@user.update!(images: [ … ])`). Norint kontroliuoti šį veikimą, naudokite `config.active_storage.replace_on_assign_to_many`.
    ([Pull Request](https://github.com/rails/rails/pull/33303),
     [Pull Request](https://github.com/rails/rails/pull/36716))

*   Pridėta galimybė atspindėti apibrėžtus priedus naudojant esamą Active Record atspindžio mechanizmą.
    ([Pull Request](https://github.com/rails/rails/pull/33018))

*   Pridėtas `ActiveStorage::Blob#open`, kuris atsisiunčia laikinąjį failą į disko ir grąžina jį.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Palaikoma srautinė atsisiuntimo funkcija iš Google Cloud Storage. Reikalinga `google-cloud-storage` versija 1.11+.
    ([Pull Request](https://github.com/rails/rails/pull/32788))

*   Naudojama `image_processing` grotelė Active Storage variantams. Tai pakeičia tiesioginį `mini_magick` naudojimą.
    ([Pull Request](https://github.com/rails/rails/pull/32471))

Active Model
------------

Išsamesnė informacija pateikta [Changelog][active-model] puslapyje.

### Pašalinimai

### Pasenusios funkcijos

### Svarbūs pakeitimai

*   Pridėta konfigūracijos galimybė, kuri leidžia keisti `ActiveModel::Errors#full_message` formato nustatymus.
    ([Pull Request](https://github.com/rails/rails/pull/32956))

*   Pridėta palaikymo galimybė nustatyti atributo pavadinimą `has_secure_password`.
    ([Pull Request](https://github.com/rails/rails/pull/26764))

*   Pridėtas `#slice!` metodas `ActiveModel::Errors` klasei.
    ([Pull Request](https://github.com/rails/rails/pull/34489))

*   Pridėtas `ActiveModel::Errors#of_kind?` metodas, skirtas tikrinti, ar yra konkretus klaidos pranešimas.
    ([Pull Request](https://github.com/rails/rails/pull/34866))

*   Ištaisyta `ActiveModel::Serializers::JSON#as_json` metodo klaida, susijusi su laiko žymėmis.
    ([Pull Request](https://github.com/rails/rails/pull/31503))

*   Ištaisyta `numericality` tikrinimo funkcija, kad būtų naudojama reikšmė prieš tipo keitimą, išskyrus Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/33654))

*   Ištaisyta `numericality` lygybės tikrinimo funkcija su `BigDecimal` ir `Float` tipo reikšmėmis, paverčiant abu galus į `BigDecimal`.
    ([Pull Request](https://github.com/rails/rails/pull/32852))

*   Ištaisyta metų reikšmė, kai keičiamas daugialypis laikas.
    ([Pull Request](https://github.com/rails/rails/pull/34990))

*   Logiškai neteisingos boolean simbolių reikšmės konvertuojamos į `false`.
    ([Pull Request](https://github.com/rails/rails/pull/35794))

*   Teisingai grąžinama data konvertuojant parametrus `value_from_multiparameter_assignment` funkcijoje `ActiveModel::Type::Date`.
    ([Pull Request](https://github.com/rails/rails/pull/29651))

*   Klaidų vertimų gavimo metu, jei nėra konkretaus vertimo, naudojama pagrindinė lokalė, o ne `:errors` sritis.
    ([Pull Request](https://github.com/rails/rails/pull/35424))

Active Support
--------------

Išsamesnė informacija pateikta [Changelog][active-support] puslapyje.

### Pašalinimai

*   Pašalintas pasenusio `#acronym_regex` metodo iš `Inflections`.
    ([Commit](https://github.com/rails/rails/commit/0ce67d3cd6d1b7b9576b07fecae3dd5b422a5689))

*   Pašalintas pasenusio `Module#reachable?` metodas.
    ([Commit](https://github.com/rails/rails/commit/6eb1d56a333fd2015610d31793ed6281acd66551))

*   Pašalintas `` Kernel#` `` be jokio pakeitimo.
    ([Pull Request](https://github.com/rails/rails/pull/31253))

### Pasenusios funkcijos

*   Pasenusi galimybė naudoti neigiamus sveikuosius skaičius kaip argumentus `String#first` ir `String#last` funkcijose.
    ([Pull Request](https://github.com/rails/rails/pull/33058))

*   Pasenusi `ActiveSupport::Multibyte::Unicode#downcase/upcase/swapcase` funkcija, naudojant `String#downcase/upcase/swapcase` funkcijas.
    ([Pull Request](https://github.com/rails/rails/pull/34123))

*   Pasenusi `ActiveSupport::Multibyte::Unicode#normalize` ir `ActiveSupport::Multibyte::Chars#normalize` funkcijos, naudojant `String#unicode_normalize` funkciją.
    ([Pull Request](https://github.com/rails/rails/pull/34202))

*   Pasenusi `ActiveSupport::Multibyte::Chars.consumes?` funkcija, naudojant `String#is_utf8?` funkciją.
    ([Pull Request](https://github.com/rails/rails/pull/34215))

*   Pasenusios `ActiveSupport::Multibyte::Unicode#pack_graphemes(array)` ir `ActiveSupport::Multibyte::Unicode#unpack_graphemes(string)` funkcijos, naudojant `array.flatten.pack("U*")` ir `string.scan(/\X/).map(&:codepoints)` atitinkamai.
    ([Pull Request](https://github.com/rails/rails/pull/34254))
### Svarbūs pakeitimai

*   Pridėta palaikymas lygiagrečiam testavimui.
    ([Pull Request](https://github.com/rails/rails/pull/31900))

*   Užtikrinta, kad `String#strip_heredoc` išlaikytų užšaldytų eilučių būseną.
    ([Pull Request](https://github.com/rails/rails/pull/32037))

*   Pridėtas `String#truncate_bytes` metodas, skirtas sutrumpinti eilutę iki maksimalaus baitų dydžio,
    nesulaužant daugiabaitės simbolių ar grafemų grupių.
    ([Pull Request](https://github.com/rails/rails/pull/27319))

*   Pridėta `private` parinktis `delegate` metode, kad būtų galima deleguoti
    privačius metodus. Ši parinktis priima `true/false` reikšmes.
    ([Pull Request](https://github.com/rails/rails/pull/31944))

*   Pridėtas palaikymas vertimams per I18n `ActiveSupport::Inflector#ordinal`
    ir `ActiveSupport::Inflector#ordinalize`.
    ([Pull Request](https://github.com/rails/rails/pull/32168))

*   Pridėti `before?` ir `after?` metodai `Date`, `DateTime`,
    `Time` ir `TimeWithZone` klasėms.
    ([Pull Request](https://github.com/rails/rails/pull/32185))

*   Ištaisyta klaida, kai `URI.unescape` metodas nesugebėdavo tvarkytis su mišriais
    Unicode/escapintais simboliais.
    ([Pull Request](https://github.com/rails/rails/pull/32183))

*   Ištaisyta klaida, kai `ActiveSupport::Cache` labai padidindavo saugojimo
    dydį, kai buvo įjungtas suspaudimas.
    ([Pull Request](https://github.com/rails/rails/pull/32539))

*   Redis kešo saugykla: `delete_matched` daugiau neblokuoja Redis serverio.
    ([Pull Request](https://github.com/rails/rails/pull/32614))

*   Ištaisyta klaida, kai `ActiveSupport::TimeZone.all` metodas neveikdavo, kai trūko
    tzinfo duomenų bet kuriam laiko juostai, apibrėžtai `ActiveSupport::TimeZone::MAPPING`.
    ([Pull Request](https://github.com/rails/rails/pull/32613))

*   Pridėtas `Enumerable#index_with` metodas, kuris leidžia sukurti hash'ą iš iteruojamojo
    objekto su reikšme iš perduoto bloko arba numatyta argumentu.
    ([Pull Request](https://github.com/rails/rails/pull/32523))

*   Leidžiama naudoti `Range#===` ir `Range#cover?` metodus su `Range` argumentu.
    ([Pull Request](https://github.com/rails/rails/pull/32938))

*   Pridėtas raktų galiojimo laikas `increment/decrement` operacijoms RedisCacheStore.
    ([Pull Request](https://github.com/rails/rails/pull/33254))

*   Pridėtos CPU laiko, neaktyvaus laiko ir atminties paskyrimo funkcijos į žurnalo prenumeratoriaus įvykius.
    ([Pull Request](https://github.com/rails/rails/pull/33449))

*   Pridėtas palaikymas įvykio objektui Active Support pranešimų sistemoje.
    ([Pull Request](https://github.com/rails/rails/pull/33451))

*   Pridėtas palaikymas nekešuoti `nil` įrašų, įvedant naują parinktį `skip_nil`
    `ActiveSupport::Cache#fetch`.
    ([Pull Request](https://github.com/rails/rails/pull/25437))

*   Pridėtas `Array#extract!` metodas, kuris pašalina ir grąžina elementus, kuriems
    blokas grąžina teisingą reikšmę.
    ([Pull Request](https://github.com/rails/rails/pull/33137))

*   Išlaikoma HTML saugi eilutė HTML saugi po iškirpimo.
    ([Pull Request](https://github.com/rails/rails/pull/33808))

*   Pridėtas palaikymas konstantų automatiniam įkėlimui per žurnalavimą.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Apibrėžiamas `unfreeze_time` kaip `travel_back` sinonimas.
    ([Pull Request](https://github.com/rails/rails/pull/33813))

*   Pakeistas `ActiveSupport::TaggedLogging.new` metodas, kad grąžintų naują žurnalo egzempliorių
    vietoj mutacijos gautam egzemplioriui.
    ([Pull Request](https://github.com/rails/rails/pull/27792))

*   Traktuojami `#delete_prefix`, `#delete_suffix` ir `#unicode_normalize` metodai
    kaip ne HTML saugūs metodai.
    ([Pull Request](https://github.com/rails/rails/pull/33990))

*   Ištaisyta klaida, kai `#without` metodas `ActiveSupport::HashWithIndifferentAccess`
    neveikdavo su simboliniais argumentais.
    ([Pull Request](https://github.com/rails/rails/pull/34012))

*   Pervadintas `Module#parent`, `Module#parents` ir `Module#parent_name` į
    `module_parent`, `module_parents` ir `module_parent_name`.
    ([Pull Request](https://github.com/rails/rails/pull/34051))
*   Pridėkite `ActiveSupport::ParameterFilter`.
    ([Pull Request](https://github.com/rails/rails/pull/34039))

*   Ištaisykite klaidą, kai trukmė buvo apvalinama iki pilnos sekundės, kai prie trukmės buvo pridedamas slankiojo kablelio skaičius.
    ([Pull Request](https://github.com/rails/rails/pull/34135))

*   Padarykite `#to_options` sinonimu `#symbolize_keys` `ActiveSupport::HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/34360))

*   Nebekelkite išimties, jei tas pats blokas yra įtrauktas kelis kartus į Concern.
    ([Pull Request](https://github.com/rails/rails/pull/34553))

*   Išsaugokite raktų tvarką, perduotą `ActiveSupport::CacheStore#fetch_multi`.
    ([Pull Request](https://github.com/rails/rails/pull/34700))

*   Ištaisykite `String#safe_constantize`, kad neteiktų `LoadError` klaidos neteisingai rašant konstantos nuorodas.
    ([Pull Request](https://github.com/rails/rails/pull/34892))

*   Pridėkite `Hash#deep_transform_values` ir `Hash#deep_transform_values!`.
    ([Commit](https://github.com/rails/rails/commit/b8dc06b8fdc16874160f61dcf58743fcc10e57db))

*   Pridėkite `ActiveSupport::HashWithIndifferentAccess#assoc`.
    ([Pull Request](https://github.com/rails/rails/pull/35080))

*   Pridėkite `before_reset` atgalinį iškvietimą į `CurrentAttributes` ir apibrėžkite `after_reset` kaip `resets` sinonimą simetriškumui.
    ([Pull Request](https://github.com/rails/rails/pull/35063))

*   Peržiūrėkite `ActiveSupport::Notifications.unsubscribe`, kad teisingai tvarkytų Regex ar kitus daugelio šablonų prenumeratorius.
    ([Pull Request](https://github.com/rails/rails/pull/32861))

*   Pridėkite naują automatinio įkėlimo mechanizmą, naudojant Zeitwerk.
    ([Commit](https://github.com/rails/rails/commit/e53430fa9af239e21e11548499d814f540d421e5))

*   Pridėkite `Array#including` ir `Enumerable#including`, kad patogiai padidintumėte kolekciją.
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   Pervadinkite `Array#without` ir `Enumerable#without` į `Array#excluding` ir `Enumerable#excluding`. Seni metodo pavadinimai išlieka kaip sinonimai.
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   Pridėkite palaikymą tiekiant `locale` į `transliterate` ir `parameterize`.
    ([Pull Request](https://github.com/rails/rails/pull/35571))

*   Ištaisykite `Time#advance`, kad veiktų su datomis iki 1001-03-07.
    ([Pull Request](https://github.com/rails/rails/pull/35659))

*   Atnaujinkite `ActiveSupport::Notifications::Instrumenter#instrument`, kad leistų neperduoti bloko.
    ([Pull Request](https://github.com/rails/rails/pull/35705))

*   Naudokite silpnus nuorodas palikuonių sekiklyje, kad anoniminiai poaibio klasės būtų galima surinkti šiukšlių rinkime.
    ([Pull Request](https://github.com/rails/rails/pull/31442))

*   Iškvieskite testo metodus su `with_info_handler` metodu, kad leistų veikti minitest-hooks įskiepiui.
    ([Commit](https://github.com/rails/rails/commit/758ba117a008b6ea2d3b92c53b6a7a8d7ccbca69))

*   Išsaugokite `html_safe?` būseną `ActiveSupport::SafeBuffer#*`.
    ([Pull Request](https://github.com/rails/rails/pull/36012))

Aktyvus darbas
----------

Išsamesniam pakeitimų aprašymui žiūrėkite [Changelog][active-job].

### Pašalinimai

*   Pašalintas Qu gem palaikymas.
    ([Pull Request](https://github.com/rails/rails/pull/32300))

### Pasenusių funkcijų žymėjimai

### Pastebimi pakeitimai

*   Pridėtas palaikymas pasirinktiniams serijavimo būdams Active Job argumentams.
    ([Pull Request](https://github.com/rails/rails/pull/30941))

*   Pridėtas palaikymas vykdyti Active Job'us laiko juostose, kuriose jie buvo įtraukti.
    ([Pull Request](https://github.com/rails/rails/pull/32085))

*   Leidžiama perduoti kelias išimtis `retry_on`/`discard_on` metodams.
    ([Commit](https://github.com/rails/rails/commit/3110caecbebdad7300daaf26bfdff39efda99e25))

*   Leidžiama naudoti `assert_enqueued_with` ir `assert_enqueued_email_with` be bloko.
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   Apvyniokite pranešimus apie `enqueue` ir `enqueue_at` į `around_enqueue` atgalinį iškvietimą, o ne į `after_enqueue` atgalinį iškvietimą.
    ([Pull Request](https://github.com/rails/rails/pull/33171))

*   Leidžiama naudoti `perform_enqueued_jobs` be bloko.
    ([Pull Request](https://github.com/rails/rails/pull/33626))

*   Leidžiama naudoti `assert_performed_with` be bloko.
    ([Pull Request](https://github.com/rails/rails/pull/33635))

*   Pridėta `:queue` parinktis darbo patikrinimui ir pagalbinėms funkcijoms.
    ([Pull Request](https://github.com/rails/rails/pull/33635))
*   Pridėti kabliukai prie Active Job dėl bandymų ir atmetimų.
    ([Pull Request](https://github.com/rails/rails/pull/33751))

*   Pridėti būdą testuoti argumentų poaibį vykdant darbus.
    ([Pull Request](https://github.com/rails/rails/pull/33995))

*   Įtraukti deserializuotus argumentus į darbus, grąžinamus
    Active Job testavimo pagalbininkais.
    ([Pull Request](https://github.com/rails/rails/pull/34204))

*   Leisti Active Job tikrinimo pagalbininkams priimti Proc objektą
    `only` raktažodyje.
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   Išmesti mikrosekundes ir nanosekundes iš darbo argumentų tikrinimo pagalbininkuose.
    ([Pull Request](https://github.com/rails/rails/pull/35713))

Ruby on Rails vadovai
--------------------

Išsamesniam pakeitimų sąrašui žiūrėkite [Changelog][guides].

### Pastebimi pakeitimai

*   Pridėtas daugelio duomenų bazės su Active Record vadovas.
    ([Pull Request](https://github.com/rails/rails/pull/36389))

*   Pridėtas skyrius apie konstantų automatinio įkėlimo problemų
    sprendimą.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Pridėtas Action Mailbox Basics vadovas.
    ([Pull Request](https://github.com/rails/rails/pull/34812))

*   Pridėtas Action Text Overview vadovas.
    ([Pull Request](https://github.com/rails/rails/pull/34878))

Autoriai
-------

Žiūrėkite
[pilną Rails prisidėjusių asmenų sąrašą](https://contributors.rubyonrails.org/)
už daugybę žmonių, kurie daugybę valandų skyrė Rails, stabiliam ir patikimam
karkasui, kuris jis yra. Dėkojame visiems jiems.

[railties]:       https://github.com/rails/rails/blob/6-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-0-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-0-stable/activesupport/CHANGELOG.md
