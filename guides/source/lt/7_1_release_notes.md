**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 82080185bf1d0c30f22fa131b42e4187
Ruby on Rails 7.1 Išleidimo pastabos
=====================================

Svarbiausi dalykai Rails 7.1:

--------------------------------------------------------------------------------

Atnaujinimas iki Rails 7.1
--------------------------

Jei atnaujinote esamą aplikaciją, gerai būtų turėti gerą testavimo padengimą prieš pradedant. Taip pat pirmiausia turėtumėte atnaujinti iki Rails 7.0, jei dar to nedarėte, ir įsitikinti, kad jūsų aplikacija vis dar veikia kaip tikimasi, prieš bandant atnaujinti iki Rails 7.1. Atnaujinimo metu reikėtų atkreipti dėmesį į keletą dalykų, kuriuos galima rasti
[Ruby on Rails atnaujinimo](upgrading_ruby_on_rails.html#upgrading-from-rails-7-0-to-rails-7-1)
gide.

Svarbiausi funkcionalumai
-------------------------

Railties
--------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][railties] puslapyje.

### Pašalinimai

### Pasenusios funkcijos

### Pastebimi pakeitimai

Action Cable
------------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][action-cable] puslapyje.

### Pašalinimai

### Pasenusios funkcijos

### Pastebimi pakeitimai

Action Pack
-----------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][action-pack] puslapyje.

### Pašalinimai

*   Pašalintas pasenusio elgesio `Request#content_type`

*   Pašalinta pasenusi galimybė priskirti vieną reikšmę `config.action_dispatch.trusted_proxies`.

*   Pašalintas pasenusias `poltergeist` ir `webkit` (capybara-webkit) tvarkyklų registravimas sisteminiams testams.

### Pasenusios funkcijos

*   Pasenusi `config.action_dispatch.return_only_request_media_type_on_content_type`.

*   Pasenusi `AbstractController::Helpers::MissingHelperError`

*   Pasenusi `ActionDispatch::IllegalStateError`.

### Pastebimi pakeitimai

Action View
-----------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][action-view] puslapyje.

### Pašalinimai

*   Pašalinta pasenusi konstanta `ActionView::Path`.

*   Pašalinta pasenusi palaikymo galimybė perduoti objekto kintamuosius kaip vietinius kintamuosius dalinėms.

### Pasenusios funkcijos

### Pastebimi pakeitimai

Action Mailer
-------------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][action-mailer] puslapyje.

### Pašalinimai

### Pasenusios funkcijos

### Pastebimi pakeitimai

Active Record
-------------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][active-record] puslapyje.

### Pašalinimai

*   Pašalintas palaikymas `ActiveRecord.legacy_connection_handling`.

*   Pašalinti pasenusių `ActiveRecord::Base` konfigūracijos pasiekimo metodai

*   Pašalintas palaikymas `:include_replicas` parametrui `configs_for`. Vietoje to naudokite `:include_hidden`.

*   Pašalinta pasenusi `config.active_record.partial_writes`.

*   Pašalintas pasenusi `Tasks::DatabaseTasks.schema_file_type`.

### Pasenusios funkcijos

### Pastebimi pakeitimai

Active Storage
--------------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][active-storage] puslapyje.

### Pašalinimai

*   Pašalintos pasenusios numatytosios turinio tipų reikšmės Active Storage konfigūracijose.

*   Pašalinti pasenusi `ActiveStorage::Current#host` ir `ActiveStorage::Current#host=` metodai.

*   Pašalintas pasenusi elgesys priskiriant priejų kolekcijai. Vietoje to, kolekcija dabar yra pakeičiama.

*   Pašalinti pasenusi `purge` ir `purge_later` metodai iš prisegimų asociacijos.

### Pasenusios funkcijos

### Pastebimi pakeitimai

Active Model
------------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][active-model] puslapyje.

### Pašalinimai

### Pasenusios funkcijos

### Pastebimi pakeitimai

Active Support
--------------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][active-support] puslapyje.

### Pašalinimai

*   Pašalintas pasenusio `Enumerable#sum` perrašymas.

*   Pašalintas pasenusio `ActiveSupport::PerThreadRegistry`.

*   Pašalinta pasenusi galimybė perduoti formatą `#to_s` metode `Array`, `Range`, `Date`, `DateTime`, `Time`,
    `BigDecimal`, `Float` ir `Integer` klasėse.

*   Pašalintas pasenusio `ActiveSupport::TimeWithZone.name` perrašymas.

*   Pašalintas `active_support/core_ext/uri` failas.

*   Pašalintas `active_support/core_ext/range/include_time_with_zone` failas.

*   Pašalinta objektų automatinė konvertavimas į `String` naudojant `ActiveSupport::SafeBuffer`.

*   Pašalinta palaikymo galimybė generuoti neteisingus RFC 4122 UUID, kai nurodomas vardų sritis, kuri nėra viena iš
    `Digest::UUID` apibrėžtų konstantų.

### Pasenusios funkcijos

*   Pasenusi `config.active_support.disable_to_s_conversion`.

*   Pasenusi `config.active_support.remove_deprecated_time_with_zone_name`.

*   Pasenusi `config.active_support.use_rfc4122_namespaced_uuids`.

### Pastebimi pakeitimai

Active Job
----------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][active-job] puslapyje.

### Pašalinimai

### Pasenusios funkcijos

### Pastebimi pakeitimai

Action Text
----------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][action-text] puslapyje.

### Pašalinimai

### Pasenusios funkcijos

### Pastebimi pakeitimai

Action Mailbox
----------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][action-mailbox] puslapyje.

### Pašalinimai

### Pasenusios funkcijos

### Pastebimi pakeitimai

Ruby on Rails vadovai
---------------------

Išsamesnės pakeitimų informacijos galite rasti [Changelog][guides] puslapyje.

### Pastebimi pakeitimai

Autoriai
--------

Peržiūrėkite
[pilną sąrašą prisidėjusių prie Rails žmonių](https://contributors.rubyonrails.org/)
už daugelį valandų, kurias jie praleido kurdami Rails, stabilų ir patikimą
karkasą. Pagarba visiems jiems.

[railties]:       https://github.com/rails/rails/blob/main/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/main/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/main/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/main/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/main/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/main/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/main/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/main/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/main/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/main/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/main/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/main/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/main/actionmailbox/CHANGELOG.md
