**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 1d652e6ccda9c901ca3f6a003c95f83e
Ruby on Rails 6.1 Išleidimo pastabos
===============================

Svarbiausios naujovės Rails 6.1:

* Duomenų bazės jungčių keitimas pagal duomenų bazę
* Horizontalus fragmentavimas
* Griežtas ryšių įkėlimas
* Deleguoti tipai
* Asinchroninis asociacijų naikinimas

Šiose išleidimo pastabose aptariamos tik pagrindinės naujovės. Norėdami sužinoti apie įvairius klaidų taisymus ir pakeitimus, prašome kreiptis į pakeitimų žurnalus arba peržiūrėti [pakeitimų sąrašą](https://github.com/rails/rails/commits/6-1-stable) pagrindiniame Rails saugykloje GitHub.

--------------------------------------------------------------------------------

Atnaujinimas į Rails 6.1
----------------------

Jei atnaujinote esamą programą, gerai būtų turėti geras testavimo padengimo galimybes prieš pradedant. Taip pat pirmiausia turėtumėte atnaujinti iki Rails 6.0, jei dar to nedarėte, ir įsitikinti, kad jūsų programa veikia kaip tikėtasi, prieš bandant atnaujinti į Rails 6.1. Atnaujinimo metu reikėtų atkreipti dėmesį į keletą dalykų, kuriuos galima rasti
[Ruby on Rails atnaujinimo](upgrading_ruby_on_rails.html#upgrading-from-rails-6-0-to-rails-6-1)
gide.

Pagrindinės funkcijos
--------------

### Duomenų bazės jungčių keitimas pagal duomenų bazę

Rails 6.1 suteikia galimybę [keisti jungtis pagal duomenų bazę](https://github.com/rails/rails/pull/40370). 6.0 versijoje, jei perjungėte į `reading` vaidmenį, visos duomenų bazės jungtys taip pat perjungė į skaitymo vaidmenį. Dabar 6.1 versijoje, jei nustatysite `legacy_connection_handling` reikšmę į `false` savo konfigūracijoje, Rails leis jums perjungti jungtis tik vienai duomenų bazei, iškviesdami `connected_to` atitinkamam abstrakčiajam klasei.

### Horizontalus fragmentavimas

Rails 6.0 suteikė galimybę funkcinės fragmentacijos (kelios fragmentacijos, skirtingos schemos) jūsų duomenų bazėje, tačiau negalėjo palaikyti horizontalaus fragmentavimo (ta pati schema, kelios fragmentacijos). Rails negalėjo palaikyti horizontalaus fragmentavimo, nes Active Record modeliai galėjo turėti tik vieną ryšį per vaidmenį per klasę. Tai dabar ištaisyta ir [horizontalus fragmentavimas](https://github.com/rails/rails/pull/38531) su Rails yra galimas.

### Griežtas ryšių įkėlimas

[Griežtas ryšių įkėlimas](https://github.com/rails/rails/pull/37400) leidžia užtikrinti, kad visi jūsų ryšiai būtų įkelti iš anksto ir sustabdyti N+1 problemą prieš ją įvykdant.

### Deleguoti tipai

[Deleguoti tipai](https://github.com/rails/rails/pull/39341) yra alternatyva vienos lentelės paveldėjimui. Tai padeda atvaizduoti klasės hierarchijas, leidžiant, kad viršklas būtų konkreti klasė, kurią atstovauja jos pačios lentelė. Kiekvienai po-klasei yra skirta savo lentelė papildomiems atributams.

### Asinchroninis asociacijų naikinimas

[Asinchroninis asociacijų naikinimas](https://github.com/rails/rails/pull/40157) suteikia galimybę programoms naikinti asociacijas fone. Tai padeda išvengti laiko limitų ir kitų našumo problemų jūsų programoje naikinant duomenis.
Railties
--------

Išsamius pakeitimus rasite [Changelog][railties] puslapyje.

### Pašalinimai

*   Pašalinti pasenusi `rake notes` užduotys.

*   Pašalintas pasenusi `connection` parametras iš `rails dbconsole` komandos.

*   Pašalinta pasenusi `SOURCE_ANNOTATION_DIRECTORIES` aplinkos kintamojo palaikymas `rails notes`.

*   Pašalintas pasenusi `server` argumentas iš `rails server` komandos.

*   Pašalintas pasenusi palaikymas naudoti `HOST` aplinkos kintamąjį, nurodantį serverio IP.

*   Pašalintos pasenusios `rake dev:cache` užduotys.

*   Pašalintos pasenusios `rake routes` užduotys.

*   Pašalintos pasenusios `rake initializers` užduotys.

### Pasenusių funkcijų pažymėjimai

### Svarbūs pakeitimai

Action Cable
------------

Išsamius pakeitimus rasite [Changelog][action-cable] puslapyje.

### Pašalinimai

### Pasenusių funkcijų pažymėjimai

### Svarbūs pakeitimai

Action Pack
-----------

Išsamius pakeitimus rasite [Changelog][action-pack] puslapyje.

### Pašalinimai

*   Pašalintas pasenusi `ActionDispatch::Http::ParameterFilter`.

*   Pašalintas pasenusi `force_ssl` kontrolerio lygyje.

### Pasenusių funkcijų pažymėjimai

*   Pažymėta kaip pasenusi `config.action_dispatch.return_only_media_type_on_content_type`.

### Svarbūs pakeitimai

*   Pakeista `ActionDispatch::Response#content_type` funkcija, kad grąžintų visą Content-Type antraštę.

Action View
-----------

Išsamius pakeitimus rasite [Changelog][action-view] puslapyje.

### Pašalinimai

*   Pašalintas pasenusi `escape_whitelist` iš `ActionView::Template::Handlers::ERB`.

*   Pašalintas pasenusi `find_all_anywhere` iš `ActionView::Resolver`.

*   Pašalintas pasenusi `formats` iš `ActionView::Template::HTML`.

*   Pašalintas pasenusi `formats` iš `ActionView::Template::RawFile`.

*   Pašalintas pasenusi `formats` iš `ActionView::Template::Text`.

*   Pašalintas pasenusi `find_file` iš `ActionView::PathSet`.

*   Pašalintas pasenusi `rendered_format` iš `ActionView::LookupContext`.

*   Pašalintas pasenusi `find_file` iš `ActionView::ViewPaths`.

*   Pašalintas pasenusi palaikymas perduoti objektą, kuris nėra `ActionView::LookupContext`, kaip pirmą argumentą
    `ActionView::Base#initialize` funkcijoje.

*   Pašalintas pasenusi `format` argumentas `ActionView::Base#initialize` funkcijoje.

*   Pašalintas pasenusi `ActionView::Template#refresh` funkcija.

*   Pašalintas pasenusi `ActionView::Template#original_encoding` funkcija.

*   Pašalintas pasenusi `ActionView::Template#variants` funkcija.

*   Pašalintas pasenusi `ActionView::Template#formats` funkcija.

*   Pašalintas pasenusi `ActionView::Template#virtual_path=` funkcija.

*   Pašalintas pasenusi `ActionView::Template#updated_at` funkcija.

*   Pašalintas pasenusi `updated_at` argumentas, reikalingas `ActionView::Template#initialize` funkcijai.

*   Pašalintas pasenusi `ActionView::Template.finalize_compiled_template_methods` funkcija.

*   Pašalintas pasenusi `config.action_view.finalize_compiled_template_methods` palaikymas.

*   Pašalintas pasenusi palaikymas iškviesti `ActionView::ViewPaths#with_fallback` su bloku.

*   Pašalintas pasenusi palaikymas perduoti absoliučius kelius `render template:`.

*   Pašalintas pasenusi palaikymas perduoti santykinius kelius `render file:`.

*   Pašalintas palaikymas šablonų tvarkyklėms, kurios nepriima dviejų argumentų.

*   Pašalintas pasenusi šablonų argumentas `ActionView::Template::PathResolver` funkcijoje.

*   Pašalintas pasenusi palaikymas iškviesti privačias funkcijas iš objekto kai kuriuose vaizdo pagalbininkuose.

### Pasenusių funkcijų pažymėjimai

### Svarbūs pakeitimai

*   Reikalaujama, kad `ActionView::Base` paveldėjimą atlikusios klasės įgyvendintų `#compiled_method_container` funkciją.

*   Privalomas `locals` argumentas `ActionView::Template#initialize` funkcijoje.
* `javascript_include_tag` ir `stylesheet_link_tag` turtiniai pagalbos elementai generuoja `Link` antraštę, kuri suteikia moderniems naršyklėms užuominas apie išankstinį turtų įkėlimą. Tai galima išjungti nustatant `config.action_view.preload_links_header` reikšmę į `false`.

Veiksmų siuntėjas
-------------

Išsamioms pakeitimams žiūrėkite [Changelog][action-mailer].

### Pašalinimai

* Pašalintas pasenusi `ActionMailer::Base.receive` naudojimas, naudojant [Action Mailbox](https://github.com/rails/rails/tree/6-1-stable/actionmailbox).

### Pasenusių funkcijų pažymėjimai

### Svarbūs pakeitimai

Aktyvusis įrašas
-------------

Išsamioms pakeitimams žiūrėkite [Changelog][active-record].

### Pašalinimai

* Pašalintos pasenusios funkcijos iš `ActiveRecord::ConnectionAdapters::DatabaseLimits`.

    `column_name_length`
    `table_name_length`
    `columns_per_table`
    `indexes_per_table`
    `columns_per_multicolumn_index`
    `sql_query_length`
    `joins_per_query`

* Pašalintas pasenusi `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_multi_insert?`.

* Pašalintas pasenusi `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_foreign_keys_in_create?`.

* Pašalintas pasenusi `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_ranges?`.

* Pašalintos pasenusios `ActiveRecord::Base#update_attributes` ir `ActiveRecord::Base#update_attributes!`.

* Pašalintas pasenusi `migrations_path` argumentas `ActiveRecord::ConnectionAdapter::SchemaStatements#assume_migrated_upto_version` metode.

* Pašalintas pasenusi `config.active_record.sqlite3.represent_boolean_as_integer`.

* Pašalintos pasenusios funkcijos iš `ActiveRecord::DatabaseConfigurations`.

    `fetch`
    `each`
    `first`
    `values`
    `[]=`

* Pašalintas pasenusi `ActiveRecord::Result#to_hash` metodas.

* Pašalintas pasenusi parametrų perdavimo nepriklausomam SQL naudojimui `ActiveRecord::Relation` metodų metu palaikymas.

### Pasenusių funkcijų pažymėjimai

* Pažymėtas pasenusi `ActiveRecord::Base.allow_unsafe_raw_sql`.

* Pažymėtas pasenusi `database` argumentas `connected_to` metode.

* Pažymėtas pasenusi `connection_handlers`, kai `legacy_connection_handling` nustatytas kaip false.

### Svarbūs pakeitimai

* MySQL: Unikalumo tikrinimas dabar atsižvelgia į numatytąją duomenų bazės lygiavimą, pagal numatytąjį nustatymą nebenaudojamas jautrusis raidžių palyginimas.

* `relation.create` daugiau neleidžia klasės lygio užklausų metodams patekti prie srities inicializavimo bloko ir atgalinio iškvietimo metu.

    Prieš tai:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => nil
    end
    ```

    Po to:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => #<User name: "David", ...>
    end
    ```

* Vardinių sričių grandinė daugiau neleidžia klasės lygio užklausų metodams patekti prie srities.

    ```ruby
    class User < ActiveRecord::Base
      scope :david, -> { User.where(name: "David") }
    end
    ```

    Prieš tai:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'John' AND name = 'David'
    ```

    Po to:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'David'
    ```

* `where.not` dabar generuoja NAND predikatus, o ne NOR.

    Prieš tai:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE name != 'Jon' AND role != 'admin'
    ```

    Po to:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE NOT (name = 'Jon' AND role = 'admin')
    ```

* Norint naudoti naująją duomenų bazės ryšio tvarkymą, programos turi pakeisti `legacy_connection_handling` į false ir pašalinti pasenusius prieigos metodus `connection_handlers`. Vieši metodai `connects_to` ir `connected_to` nereikalauja jokių pakeitimų.
Aktyvus saugojimas
--------------

Išsamius pakeitimus žiūrėkite [Changelog][active-storage].

### Pašalinimai

*   Pašalintas pasenusi palaikymas perduoti `:combine_options` operacijas į `ActiveStorage::Transformers::ImageProcessing`.

*   Pašalintas pasenusi `ActiveStorage::Transformers::MiniMagickTransformer`.

*   Pašalintas pasenusi `config.active_storage.queue`.

*   Pašalintas pasenusi `ActiveStorage::Downloading`.

### Pasenusi funkcionalumas

*   Pasenusa `Blob.create_after_upload` funkcija pakeista į `Blob.create_and_upload`.
    ([Pull Request](https://github.com/rails/rails/pull/34827))

### Svarbūs pakeitimai

*   Pridėta `Blob.create_and_upload` funkcija, skirta sukurti naują blob ir įkelti duotą `io`
    į paslaugą.
    ([Pull Request](https://github.com/rails/rails/pull/34827))
*   Pridėta `ActiveStorage::Blob#service_name` stulpelis. Po atnaujinimo reikalinga paleisti migraciją. Paleiskite `bin/rails app:update`, kad būtų sugeneruota migracija.

Aktyvus modelis
------------

Išsamius pakeitimus žiūrėkite [Changelog][active-model].

### Pašalinimai

### Pasenusi funkcionalumas

### Svarbūs pakeitimai

*   Aktyvaus modelio klaidos dabar yra objektai, turintys sąsają, leidžiančią jūsų programai lengviau tvarkyti ir sąveikauti su modelių metu iškeltomis klaidomis.
    [Ši funkcija](https://github.com/rails/rails/pull/32313) apima užklausos sąsają, leidžia
    tiksliau testuoti ir gauti klaidos informaciją.

Aktyvus palaikymas
--------------

Išsamius pakeitimus žiūrėkite [Changelog][active-support].

### Pašalinimai

*   Pašalintas pasenusi atsarginis `I18n.default_locale` naudojimas, kai `config.i18n.fallbacks` yra tuščias.

*   Pašalinta pasenusi `LoggerSilence` konstanta.

*   Pašalinta pasenusi `ActiveSupport::LoggerThreadSafeLevel#after_initialize` funkcija.

*   Pašalintos pasenusios `Module#parent_name`, `Module#parent` ir `Module#parents` funkcijos.

*   Pašalintas pasenusi failas `active_support/core_ext/module/reachable`.

*   Pašalintas pasenusi failas `active_support/core_ext/numeric/inquiry`.

*   Pašalintas pasenusi failas `active_support/core_ext/array/prepend_and_append`.

*   Pašalintas pasenusi failas `active_support/core_ext/hash/compact`.

*   Pašalintas pasenusi failas `active_support/core_ext/hash/transform_values`.

*   Pašalintas pasenusi failas `active_support/core_ext/range/include_range`.

*   Pašalintos pasenusios `ActiveSupport::Multibyte::Chars#consumes?` ir `ActiveSupport::Multibyte::Chars#normalize` funkcijos.

*   Pašalintos pasenusios `ActiveSupport::Multibyte::Unicode.pack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.unpack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.normalize`,
    `ActiveSupport::Multibyte::Unicode.downcase`,
    `ActiveSupport::Multibyte::Unicode.upcase` ir `ActiveSupport::Multibyte::Unicode.swapcase` funkcijos.

*   Pašalinta pasenusi `ActiveSupport::Notifications::Instrumenter#end=` funkcija.

### Pasenusi funkcionalumas

*   Pasenusa `ActiveSupport::Multibyte::Unicode.default_normalization_form` funkcija.

### Svarbūs pakeitimai

Aktyvus darbas
----------

Išsamius pakeitimus žiūrėkite [Changelog][active-job].

### Pašalinimai

### Pasenusi funkcionalumas

*   Pasenusa `config.active_job.return_false_on_aborted_enqueue` funkcija.

### Svarbūs pakeitimai

*   Grąžinti `false`, kai darbo įtraukimas į eilę yra nutrauktas.

Veiksmo tekstas
----------

Išsamius pakeitimus žiūrėkite [Changelog][action-text].

### Pašalinimai

### Pasenusi funkcionalumas

### Svarbūs pakeitimai

*   Pridėta funkcija, patvirtinanti turtingojo teksto turinio buvimą, pridedant `?` po
    turtingojo teksto atributo pavadinimo.
    ([Pull Request](https://github.com/rails/rails/pull/37951))

*   Pridėtas `fill_in_rich_text_area` sistemos testo pagalbininkas, skirtas rasti trix
    redaktorių ir užpildyti jį duotu HTML turiniu.
    ([Pull Request](https://github.com/rails/rails/pull/35885))

*   Pridėta `ActionText::FixtureSet.attachment` funkcija, skirta generuoti
    `<action-text-attachment>` elementus duomenų bazės fiksuose.
    ([Pull Request](https://github.com/rails/rails/pull/40289))

Veiksmo pašto dėžutė
----------

Išsamius pakeitimus žiūrėkite [Changelog][action-mailbox].
### Pašalinimai

### Nustatymų pasenusių funkcijų

*   Nustatyti `Rails.application.credentials.action_mailbox.api_key` ir `MAILGUN_INGRESS_API_KEY` kaip pasenusius, naudoti `Rails.application.credentials.action_mailbox.signing_key` ir `MAILGUN_INGRESS_SIGNING_KEY` vietoje.

### Svarbūs pakeitimai

Ruby on Rails vadovai
--------------------

Išsamesnius pakeitimus žiūrėkite [Keitimų žurnale][guides].

### Svarbūs pakeitimai

Autoriai
-------

Žiūrėkite [pilną sąrašą prisidėjusių prie Rails](https://contributors.rubyonrails.org/) žmonių, kurie daug valandų skyrė kurti Rails, stabilų ir patikimą karkasą. Jie visi nusipelno pagyrimo.

[railties]:       https://github.com/rails/rails/blob/6-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-1-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/6-1-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-1-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-1-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-1-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/6-1-stable/actionmailbox/CHANGELOG.md
