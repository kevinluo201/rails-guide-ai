**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e9aa14ccbfd8f02fea6c1b061215332c
Ruby on Rails 7.0 Išleidimo Pastabos
=====================================

Svarbiausi dalykai Rails 7.0:

* Reikalingas Ruby 2.7.0+ versija, rekomenduojama naudoti Ruby 3.0+ versiją

--------------------------------------------------------------------------------

Atnaujinimas į Rails 7.0
------------------------

Jei atnaujinote esamą aplikaciją, gerai būtų turėti gerą testavimo padengimą prieš pradedant. Taip pat, prieš bandant atnaujinti į Rails 7.0, pirmiausia atnaujinkite į Rails 6.1, jei dar to nedarėte, ir įsitikinkite, kad jūsų aplikacija veikia kaip tikėtasi. Atnaujinimo metu reikėtų atkreipti dėmesį į keletą dalykų, kuriuos galima rasti
[Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0)
gairėse.

Pagrindinės funkcijos
--------------------

Railties
--------

Išsamesnę informaciją apie pakeitimus rasite [Changelog][railties] puslapyje.

### Pašalinimai

* Pašalintas pasenusi `config` `dbconsole`.

### Pasenusi funkcija

### Svarbūs pakeitimai

* Sprockets dabar yra pasirinktinis priklausomybės įrašas

    Gemas `rails` daugiau nebesiremia `sprockets-rails`. Jei jūsų aplikacija vis dar naudoja Sprockets,
    įsitikinkite, kad pridėjote `sprockets-rails` į savo Gemfile.

    ```
    gem "sprockets-rails"
    ```

Action Cable
------------

Išsamesnę informaciją apie pakeitimus rasite [Changelog][action-cable] puslapyje.

### Pašalinimai

### Pasenusi funkcija

### Svarbūs pakeitimai

Action Pack
-----------

Išsamesnę informaciją apie pakeitimus rasite [Changelog][action-pack] puslapyje.

### Pašalinimai

* Pašalintas pasenusi `ActionDispatch::Response.return_only_media_type_on_content_type`.

* Pašalintas pasenusi `Rails.config.action_dispatch.hosts_response_app`.

* Pašalintas pasenusi `ActionDispatch::SystemTestCase#host!`.

* Pašalintas pasenusi parametrų perdavimo palaikymas `fixture_file_upload` funkcijai, kai kelias yra nurodomas atsižvelgiant į `fixture_path`.

### Pasenusi funkcija

### Svarbūs pakeitimai

Action View
-----------

Išsamesnę informaciją apie pakeitimus rasite [Changelog][action-view] puslapyje.

### Pašalinimai

* Pašalintas pasenusi `Rails.config.action_view.raise_on_missing_translations`.

### Pasenusi funkcija

### Svarbūs pakeitimai

* `button_to` funkcija dabar automatiškai nustato HTTP veiksmą [method] pagal Active Record objektą, jei objektas naudojamas formuoti URL

    ```ruby
    button_to("Do a POST", [:do_post_action, Workshop.find(1)])
    # Prieš tai
    #=>   <input type="hidden" name="_method" value="post" autocomplete="off" />
    # Po to
    #=>   <input type="hidden" name="_method" value="patch" autocomplete="off" />
    ```

Action Mailer
-------------

Išsamesnę informaciją apie pakeitimus rasite [Changelog][action-mailer] puslapyje.

### Pašalinimai

* Pašalinti pasenusi `ActionMailer::DeliveryJob` ir `ActionMailer::Parameterized::DeliveryJob`
    naudai `ActionMailer::MailDeliveryJob`.

### Pasenusi funkcija

### Svarbūs pakeitimai

Active Record
-------------

Išsamesnę informaciją apie pakeitimus rasite [Changelog][active-record] puslapyje.

### Pašalinimai

* Pašalintas pasenusi `database` parametras iš `connected_to` funkcijos.

* Pašalintas pasenusi `ActiveRecord::Base.allow_unsafe_raw_sql`.

* Pašalintas pasenusi `:spec_name` parametras iš `configs_for` funkcijos.

* Pašalintas pasenusi palaikymas YAML užkrauti `ActiveRecord::Base` objektą naudojant Rails 4.2 ir 4.1 formatus.

* Pašalintas pasenusi įspėjimas, kai PostgreSQL duomenų bazėje naudojamas `:interval` stulpelis.

    Dabar intervalo stulpeliai grąžins `ActiveSupport::Duration` objektus vietoje eilučių.

    Norint išlaikyti senąjį elgesį, galite pridėti šią eilutę į savo modelį:

    ```ruby
    attribute :column, :string
    ```

* Pašalintas pasenusi palaikymas išspręsti ryšį naudojant `"primary"` kaip ryšio specifikacijos pavadinimą.

* Pašalintas pasenusi palaikymas cituoti `ActiveRecord::Base` objektus.

* Pašalintas pasenusi palaikymas konvertuoti į duomenų bazės reikšmes `ActiveRecord::Base` objektus.

* Pašalintas pasenusi palaikymas perduoti stulpelį į `type_cast` funkciją.

* Pašalintas pasenusi `DatabaseConfig#config` funkcija.

* Pašalintos pasenusios rake užduotys:

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

* Pašalintas pasenusi palaikymas `Model.reorder(nil).first` funkcijai, skirtai ieškoti naudojant nedeterministinį rikiavimą.

* Pašalinti pasenusi `environment` ir `name` argumentai iš `Tasks::DatabaseTasks.schema_up_to_date?` funkcijos.

* Pašalintas pasenusi `Tasks::DatabaseTasks.dump_filename` funkcija.

* Pašalintas pasenusi `Tasks::DatabaseTasks.schema_file` funkcija.

* Pašalintas pasenusi `Tasks::DatabaseTasks.spec` funkcija.

* Pašalintas pasenusi `Tasks::DatabaseTasks.current_config` funkcija.

* Pašalintas pasenusi `ActiveRecord::Connection#allowed_index_name_length` funkcija.

* Pašalintas pasenusi `ActiveRecord::Connection#in_clause_length` funkcija.

* Pašalintas pasenusi `ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name` funkcija.

* Pašalintas pasenusi `ActiveRecord::Base.connection_config` funkcija.

* Pašalintas pasenusi `ActiveRecord::Base.arel_attribute` funkcija.

* Pašalintas pasenusi `ActiveRecord::Base.configurations.default_hash` funkcija.

* Pašalintas pasenusi `ActiveRecord::Base.configurations.to_h` funkcija.

* Pašalintos pasenusios `ActiveRecord::Result#map!` ir `ActiveRecord::Result#collect!` funkcijos.

* Pašalinta pasenusi `ActiveRecord::Base#remove_connection` funkcija.

### Pasenusi funkcija

* Pasenusi `Tasks::DatabaseTasks.schema_file_type` funkcija.

### Svarbūs pakeitimai

* Atšaukti transakciją, jei blokas grąžina rezultatą anksčiau nei tikėtasi.

    Prieš šį pakeitimą, kai transakcijos blokas grąžindavo rezultatą anksti, transakcija būdavo įvykdyta.

    Problema buvo ta, kad laiko limitai, pasiekiami transakcijos bloke, taip pat darė nebaigtą transakciją įvykdytą, todėl tam, kad išvengtumėte šios klaidos, transakcijos blokas yra atšaukiamas.

* Sąlygų sujungimas toje pačioje stulpelyje daugiau nebeturės abiejų sąlygų, ir bus vienodai pakeistas naujausia sąlyga.

    ```ruby
    # Rails 6.1 (IN sąlyga pakeičiama sujungimo pusės lygybės sąlyga)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    # Rails 6.1 (abi konfliktinės sąlygos egzistuoja, pasenusi)
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => []
    # Rails 6.1 su rewhere, kad pereitumėte prie Rails 7.0 elgesio
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob), rewhere: true) # => [bob]
    # Rails 7.0 (taip pat elgesys su IN sąlyga, sujungimo pusės sąlyga vienodai pakeičiama)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => [bob]
    ```
Aktyvus saugojimas
--------------

Išsamius pokyčius žr. [Pakeitimų žurnalą][active-storage].

### Pašalinimai

### Pasenusios funkcijos

### Svarbūs pokyčiai

Aktyvus modelis
------------

Išsamius pokyčius žr. [Pakeitimų žurnalą][active-model].

### Pašalinimai

*   Pašalintas pasenusių `ActiveModel::Errors` egzempliorių sąrašavimas kaip Hash.

*   Pašalintas pasenusi `ActiveModel::Errors#to_h`.

*   Pašalintas pasenusi `ActiveModel::Errors#slice!`.

*   Pašalintas pasenusi `ActiveModel::Errors#values`.

*   Pašalintas pasenusi `ActiveModel::Errors#keys`.

*   Pašalintas pasenusi `ActiveModel::Errors#to_xml`.

*   Pašalinta pasenusi palaikymo klaidų sujungimo funkcija `ActiveModel::Errors#messages`.

*   Pašalinta pasenusi palaikymo klaidų išvalymo funkcija `ActiveModel::Errors#messages`.

*   Pašalinta pasenusi palaikymo klaidų šalinimo funkcija `ActiveModel::Errors#messages`.

*   Pašalinta palaikymo klaidų priskyrimo funkcija `ActiveModel::Errors#messages`.

*   Pašalintas palaikymas Marshal ir YAML užkrautiems Rails 5.x klaidų formatams.

*   Pašalintas palaikymas Marshal užkrautiems Rails 5.x `ActiveModel::AttributeSet` formatams.

### Pasenusios funkcijos

### Svarbūs pokyčiai

Aktyvus palaikymas
--------------

Išsamius pokyčius žr. [Pakeitimų žurnalą][active-support].

### Pašalinimai

*   Pašalintas pasenusi `config.active_support.use_sha1_digests`.

*   Pašalintas pasenusi `URI.parser`.

*   Pašalintas palaikymas naudoti `Range#include?` funkciją tikrinti, ar reikšmė yra įtraukta į datos laiko intervalą.

*   Pašalintas pasenusi `ActiveSupport::Multibyte::Unicode.default_normalization_form`.

### Pasenusios funkcijos

*   Pasenkinimas formatui perduoti `#to_s` funkcijai, naudojant `#to_fs` funkciją `Array`, `Range`, `Date`, `DateTime`, `Time`,
    `BigDecimal`, `Float` ir `Integer` klasėse.

    Šis pasenkinimas leidžia Rails programai pasinaudoti Ruby 3.1
    [optimizacija](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44), kuri pagreitina
    kai kurių objektų interpoliavimą.

    Naujos programos šiose klasėse neturės perrašytos `#to_s` funkcijos, esamos programos gali naudoti
    `config.active_support.disable_to_s_conversion`.

### Svarbūs pokyčiai

Aktyvus darbas
----------

Išsamius pokyčius žr. [Pakeitimų žurnalą][active-job].

### Pašalinimai

*   Pašalinta pasenusi elgsena, kuri nebaigė `after_enqueue`/`after_perform` atgalinių iškvietimų, kai ankstesnis
    atgalinis iškvietimas buvo sustabdytas naudojant `throw :abort`.

*   Pašalinta pasenusi `:return_false_on_aborted_enqueue` parinktis.

### Pasenusios funkcijos

*   Pasenkinimas `Rails.config.active_job.skip_after_callbacks_if_terminated`.

### Svarbūs pokyčiai

Veiksmo tekstas
----------

Išsamius pokyčius žr. [Pakeitimų žurnalą][action-text].

### Pašalinimai

### Pasenusios funkcijos

### Svarbūs pokyčiai

Veiksmo pašto dėžutė
----------

Išsamius pokyčius žr. [Pakeitimų žurnalą][action-mailbox].

### Pašalinimai

*   Pašalintas pasenusi `Rails.application.credentials.action_mailbox.mailgun_api_key`.

*   Pašalinta pasenusi aplinkos kintamojo `MAILGUN_INGRESS_API_KEY`.

### Pasenusios funkcijos

### Svarbūs pokyčiai

Ruby on Rails vadovai
--------------------

Išsamius pokyčius žr. [Pakeitimų žurnalą][guides].

### Svarbūs pokyčiai

Autoriai
-------

Žr.
[pilną sąrašą prisidėjusių prie Rails žmonių](https://contributors.rubyonrails.org/)
už daugybę valandų, kurias jie praleido kurdami stabilų ir patikimą Rails karkasą. Pagarba visiems jiems.

[railties]:       https://github.com/rails/rails/blob/7-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/7-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/7-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/7-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/7-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/7-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/7-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/7-0-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/7-0-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/7-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/7-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/7-0-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/7-0-stable/actionmailbox/CHANGELOG.md
