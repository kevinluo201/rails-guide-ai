**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b093936da01fde14532f4cead51234e1
Aktyvusis palaikymo instrumentavimas
==============================

Aktyvusis palaikymas yra pagrindinės „Rails“ dalis, kuri teikia „Ruby“ kalbos plėtinius, įrankius ir kitus dalykus. Vienas iš jų yra instrumentavimo API, kurį galima naudoti programoje, kad būtų galima matuoti tam tikrus veiksmus, vykstančius „Ruby“ kode, pvz., tokius, kurie vyksta „Rails“ programoje ar paties karkaso viduje. Tačiau jis nėra ribotas tik „Rails“. Jei norite, jį galima naudoti nepriklausomai kituose „Ruby“ scenarijuose.

Šiame vadove sužinosite, kaip naudoti „Aktyvaus palaikymo“ instrumentavimo API, kad matuotumėte įvykius „Rails“ ir kitame „Ruby“ kode.

Po šios vadovėlio perskaitymo žinosite:

* Ką gali suteikti instrumentavimas.
* Kaip pridėti prenumeratorių į kablys.
* Kaip peržiūrėti laiko matavimus iš instrumentavimo naršyklėje.
* Kablys „Rails“ karkase instrumentavimui.
* Kaip sukurti pasirinktinį instrumentavimo įgyvendinimą.

--------------------------------------------------------------------------------

Įvadas į instrumentavimą
-------------------------------

Aktyvaus palaikymo teikiamas instrumentavimo API leidžia programuotojams kurti kablys, į kuriuos gali įsikišti kiti programuotojai. „Rails“ karkase yra [kelios tokių](#rails-framework-hooks). Šiuo API programuotojai gali pasirinkti, kada būti informuoti, kai tam tikri įvykiai įvyksta jų programoje ar kitame „Ruby“ kode.

Pavyzdžiui, yra [kablys](#sql-active-record), kuris teikiamas „Active Record“ ir kuris yra iškviestas kiekvieną kartą, kai „Active Record“ naudoja SQL užklausą duomenų bazėje. Šį kablys galima **prenumeruoti** ir jį galima naudoti, kad būtų stebimas užklausų skaičius tam tikro veiksmo metu. Yra [kitas kablys](#process-action-action-controller), kuris apima veiksmo valdiklio veiksmo apdorojimą. Jis galėtų būti naudojamas, pavyzdžiui, stebint, kiek laiko užtrunka konkretus veiksmas.

Netgi galite [sukurti savo įvykius](#creating-custom-events) savo programoje, kuriuos vėliau galite prenumeruoti.

Prenumeruoti įvykį
-----------------------

Prenumeruoti įvykį yra lengva. Naudokite [`ActiveSupport::Notifications.subscribe`][] su bloku, kad
klausytumėte bet kokios pranešimo.

Blokas gauna šiuos argumentus:

* Įvykio pavadinimas
* Laikas, kada prasidėjo
* Laikas, kada baigėsi
* Unikalus instrumento ID, kuris paleido įvykį
* Įvykio duomenys

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # jūsų asmeniniai dalykai
  Rails.logger.info "#{name} Gavau! (prasidėjo: #{started}, baigėsi: #{finished})" # process_action.action_controller Gavau (prasidėjo: 2019-05-05 13:43:57 -0800, baigėsi: 2019-05-05 13:43:58 -0800)
end
```

Jei jums rūpi tikslumas `started` ir `finished` skaičiuojant tikslų praėjusį laiką, tada naudokite [`ActiveSupport::Notifications.monotonic_subscribe`][]. Pateiktas blokas gautų tuos pačius argumentus kaip ir aukščiau, bet `started` ir `finished` turės reikšmes su tikslia monotoniška laiku, o ne sienos laiku.

```ruby
ActiveSupport::Notifications.monotonic_subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # jūsų asmeniniai dalykai
  Rails.logger.info "#{name} Gavau! (prasidėjo: #{started}, baigėsi: #{finished})" # process_action.action_controller Gavau (prasidėjo: 1560978.425334, baigėsi: 1560979.429234)
end
```

Apibrėžti visus tuos bloko argumentus kiekvieną kartą gali būti nuobodu. Galite lengvai sukurti [`ActiveSupport::Notifications::Event`][]
iš bloko argumentų taip:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (milisekundėmis)
  event.payload   # => {:extra=>informacija}

  Rails.logger.info "#{event} Gavau!"
end
```

Taip pat galite perduoti bloką, kuris priima tik vieną argumentą, ir jis gaus įvykio objektą:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |event|
  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (milisekundėmis)
  event.payload   # => {:extra=>informacija}

  Rails.logger.info "#{event} Gavau!"
end
```

Taip pat galite prenumeruoti įvykius, atitinkančius reguliariąją išraišką. Tai leidžia prenumeruoti
kelis įvykius vienu metu. Taip prenumeruoti viską iš `ActionController`:

```ruby
ActiveSupport::Notifications.subscribe(/action_controller/) do |*args|
  # tikrinti visus ActionController įvykius
end
```


Peržiūrėkite instrumentavimo laikus naršyklėje
-------------------------------------------------

„Rails“ įgyvendina [Server Timing](https://www.w3.org/TR/server-timing/) standartą, kad laiko informacija būtų prieinama naršyklėje. Norėdami tai įjungti, redaguokite savo aplinkos konfigūraciją (dažniausiai `development.rb`, nes tai dažniausiai naudojama vystymui), kad būtų įtraukta ši informacija:

```ruby
  config.server_timing = true
```

Kai konfigūracija sukonfigūruota (įskaitant serverio paleidimą iš naujo), galite eiti į naršyklės kūrėjo įrankių skydelį, tada pasirinkti Tinklas ir perkrauti savo puslapį. Tada galite pasirinkti bet kurį užklausą į savo „Rails“ serverį ir matysite serverio laiko matavimus laiko matavimo skirtuke. Norėdami pamatyti pavyzdį, kaip tai padaryti, žr. [Firefox dokumentaciją](https://firefox-source-docs.mozilla.org/devtools-user/network_monitor/request_details/index.html#server-timing).

„Rails“ karkaso kablys
---------------------

„Ruby on Rails“ karkase yra keletas kablys, skirtų įprastiniams įvykiams. Šie įvykiai ir jų duomenys yra išsamiau aprašyti žemiau.
### Veiksmo valdiklis

#### `start_processing.action_controller`

| Raktas        | Reikšmė                                                   |
| ------------- | --------------------------------------------------------- |
| `:controller` | Valdiklio pavadinimas                                     |
| `:action`     | Veiksmas                                                  |
| `:params`     | Užklausos parametrų maišas be jokių filtruotų parametrų    |
| `:headers`    | Užklausos antraštės                                       |
| `:format`     | html/js/json/xml ir t.t.                                  |
| `:method`     | HTTP užklausos veiksmažodis                               |
| `:path`       | Užklausos kelias                                          |

```ruby
{
  controller: "PostsController",
  action: "new",
  params: { "action" => "new", "controller" => "posts" },
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts/new"
}
```

#### `process_action.action_controller`

| Raktas             | Reikšmė                                                   |
| --------------- | --------------------------------------------------------- |
| `:controller`   | Valdiklio pavadinimas                                     |
| `:action`       | Veiksmas                                                  |
| `:params`       | Užklausos parametrų maišas be jokių filtruotų parametrų    |
| `:headers`      | Užklausos antraštės                                       |
| `:format`       | html/js/json/xml ir t.t.                                  |
| `:method`       | HTTP užklausos veiksmažodis                               |
| `:path`         | Užklausos kelias                                          |
| `:request`      | [`ActionDispatch::Request`][] objektas                    |
| `:response`     | [`ActionDispatch::Response`][] objektas                   |
| `:status`       | HTTP būsenos kodas                                        |
| `:view_runtime` | Laikas, praleistas peržiūrint vaizdą, milisekundėmis       |
| `:db_runtime`   | Laikas, praleistas vykdant duomenų bazės užklausas, milisekundėmis |

```ruby
{
  controller: "PostsController",
  action: "index",
  params: {"action" => "index", "controller" => "posts"},
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts",
  request: #<ActionDispatch::Request:0x00007ff1cb9bd7b8>,
  response: #<ActionDispatch::Response:0x00007f8521841ec8>,
  status: 200,
  view_runtime: 46.848,
  db_runtime: 0.157
}
```

#### `send_file.action_controller`

| Raktas     | Reikšmė                     |
| ------- | ------------------------- |
| `:path` | Pilnas kelias į failą     |

Skambinantysis gali pridėti papildomus raktus.

#### `send_data.action_controller`

`ActionController` nepateikia jokios specifinės informacijos apie duomenų siuntimą. Visi parametrai perduodami kaip yra.

#### `redirect_to.action_controller`

| Raktas         | Reikšmė                                    |
| ----------- | ---------------------------------------- |
| `:status`   | HTTP atsakymo kodas                      |
| `:location` | Nuoroda, į kurią nukreipiama              |
| `:request`  | [`ActionDispatch::Request`][] objektas    |

```ruby
{
  status: 302,
  location: "http://localhost:3000/posts/new",
  request: <ActionDispatch::Request:0x00007ff1cb9bd7b8>
}
```

#### `halted_callback.action_controller`

| Raktas       | Reikšmė                         |
| --------- | ----------------------------- |
| `:filter` | Filtras, kuris sustabdė veiksmą |

```ruby
{
  filter: ":halting_filter"
}
```

#### `unpermitted_parameters.action_controller`

| Raktas           | Reikšmė                                                                         |
| ------------- | ----------------------------------------------------------------------------- |
| `:keys`       | Neleistini raktai                                                              |
| `:context`    | Maišas su šiais raktas: `:controller`, `:action`, `:params`, `:request` |

### Veiksmo valdiklis — Talpinimas

#### `write_fragment.action_controller`

| Raktas    | Reikšmė            |
| ------ | ---------------- |
| `:key` | Pilnas raktas |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `read_fragment.action_controller`

| Raktas    | Reikšmė            |
| ------ | ---------------- |
| `:key` | Pilnas raktas |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `expire_fragment.action_controller`

| Raktas    | Reikšmė            |
| ------ | ---------------- |
| `:key` | Pilnas raktas |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `exist_fragment?.action_controller`

| Raktas    | Reikšmė            |
| ------ | ---------------- |
| `:key` | Pilnas raktas |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### Veiksmo perdavimas

#### `process_middleware.action_dispatch`

| Raktas           | Reikšmė                  |
| ------------- | ---------------------- |
| `:middleware` | Tarpininko pavadinimas |

#### `redirect.action_dispatch`

| Raktas         | Reikšmė                                    |
| ----------- | ---------------------------------------- |
| `:status`   | HTTP atsakymo kodas                      |
| `:location` | Nuoroda, į kurią nukreipiama              |
| `:request`  | [`ActionDispatch::Request`][] objektas    |

#### `request.action_dispatch`

| Raktas         | Reikšmė                                    |
| ----------- | ---------------------------------------- |
| `:request`  | [`ActionDispatch::Request`][] objektas    |

### Veiksmo vaizdas

#### `render_template.action_view`

| Raktas           | Reikšmė                              |
| ------------- | ---------------------------------- |
| `:identifier` | Pilnas kelias į šabloną            |
| `:layout`     | Taikomas išdėstymas                 |
| `:locals`     | Vietiniai kintamieji perduodami šablonui |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/index.html.erb",
  layout: "layouts/application",
  locals: { foo: "bar" }
}
```

#### `render_partial.action_view`

| Raktas           | Reikšmė                              |
| ------------- | ---------------------------------- |
| `:identifier` | Pilnas kelias į šabloną            |
| `:locals`     | Vietiniai kintamieji perduodami šablonui |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_form.html.erb",
  locals: { foo: "bar" }
}
```

#### `render_collection.action_view`

| Raktas           | Reikšmė                                 |
| ------------- | ------------------------------------- |
| `:identifier` | Pilnas kelias į šabloną               |
| `:count`      | Kolekcijos dydis                      |
| `:cache_hits` | Dalinių, gautų iš talpyklos, skaičius |

`:cache_hits` raktas įtraukiamas tik tada, jei kolekcija yra talpinama su `cached: true`.
```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_post.html.erb",
  count: 3,
  cache_hits: 0
}
```

#### `render_layout.action_view`

| Raktas        | Reikšmė                   |
| ------------- | ------------------------- |
| `:identifier` | Pilnas kelias iki šablono |


```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/layouts/application.html.erb"
}
```


### Active Record

#### `sql.active_record`

| Raktas               | Reikšmė                                            |
| -------------------- | -------------------------------------------------- |
| `:sql`               | SQL užklausa                                       |
| `:name`              | Operacijos pavadinimas                             |
| `:connection`        | Ryšio objektas                                     |
| `:binds`             | Susiejimo parametrai                               |
| `:type_casted_binds` | Susiejimo parametrai su konvertuotomis reikšmėmis |
| `:statement_name`    | SQL užklausos pavadinimas                          |
| `:cached`            | `true`, jei naudojamos talpyklos užklausos         |

Adapteriai taip pat gali pridėti savo duomenis.

```ruby
{
  sql: "SELECT \"posts\".* FROM \"posts\" ",
  name: "Post Load",
  connection: <ActiveRecord::ConnectionAdapters::SQLite3Adapter:0x00007f9f7a838850>,
  binds: [<ActiveModel::Attribute::WithCastValue:0x00007fe19d15dc00>],
  type_casted_binds: [11],
  statement_name: nil
}
```

#### `strict_loading_violation.active_record`

Šis įvykis išskiriamas tik tada, kai [`config.active_record.action_on_strict_loading_violation`][] yra nustatytas į `:log`.

| Raktas        | Reikšmė                                                     |
| ------------- | ----------------------------------------------------------- |
| `:owner`      | Modelis su įjungtu `strict_loading`                          |
| `:reflection` | Susiejimo atspindys, kuris bandė įkelti duomenis              |


#### `instantiation.active_record`

| Raktas            | Reikšmė                                      |
| ----------------- | -------------------------------------------- |
| `:record_count`   | Sukurtų įrašų skaičius                       |
| `:class_name`     | Įrašo klasė                                 |

```ruby
{
  record_count: 1,
  class_name: "User"
}
```

### Action Mailer

#### `deliver.action_mailer`

| Raktas                | Reikšmė                                                   |
| --------------------- | --------------------------------------------------------- |
| `:mailer`             | Pašto siuntimo klasės pavadinimas                          |
| `:message_id`         | Pranešimo ID, sugeneruotas naudojant Mail gemą             |
| `:subject`            | Pranešimo tema                                            |
| `:to`                 | Gavėjo adresas (-ai)                                      |
| `:from`               | Siuntėjo adresas                                          |
| `:bcc`                | BCC adresas (-ai)                                         |
| `:cc`                 | CC adresas (-ai)                                          |
| `:date`               | Pranešimo data                                            |
| `:mail`               | Pranešimo užkoduota forma                                 |
| `:perform_deliveries` | Ar vykdomas šio pranešimo siuntimas                        |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails vadovai",
  to: ["users@rails.com", "dhh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "...", # supaprastinimui praleidžiama
  perform_deliveries: true
}
```

#### `process.action_mailer`

| Raktas        | Reikšmė                      |
| ------------- | ---------------------------- |
| `:mailer`     | Pašto siuntimo klasės pavadinimas |
| `:action`     | Veiksmas                     |
| `:args`       | Argumentai                   |

```ruby
{
  mailer: "Notification",
  action: "welcome_email",
  args: []
}
```

### Active Support — Talpinimas

#### `cache_read.active_support`

| Raktas             | Reikšmė                  |
| ------------------ | ------------------------ |
| `:key`             | Raktas naudojamas talpykloje |
| `:store`           | Talpyklos klasės pavadinimas |
| `:hit`             | Ar šis skaitymas yra atitikimas |
| `:super_operation` | `:fetch`, jei skaitymas atliekamas su [`fetch`][ActiveSupport::Cache::Store#fetch] |

#### `cache_read_multi.active_support`

| Raktas             | Reikšmė                  |
| ------------------ | ------------------------ |
| `:key`             | Raktai naudojami talpykloje |
| `:store`           | Talpyklos klasės pavadinimas |
| `:hits`            | Atitikimų raktai talpykloje |
| `:super_operation` | `:fetch_multi`, jei skaitymas atliekamas su [`fetch_multi`][ActiveSupport::Cache::Store#fetch_multi] |

#### `cache_generate.active_support`

Šis įvykis išskiriamas tik tada, kai [`fetch`][ActiveSupport::Cache::Store#fetch] yra iškviestas su bloku.

| Raktas      | Reikšmė                  |
| ---------- | ------------------------ |
| `:key`     | Raktas naudojamas talpykloje |
| `:store`   | Talpyklos klasės pavadinimas |

Pasirinktys, perduotos `fetch` metodui, bus sujungtos su duomenimis rašant į talpyklą.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_fetch_hit.active_support`

Šis įvykis išskiriamas tik tada, kai [`fetch`][ActiveSupport::Cache::Store#fetch] yra iškviestas su bloku.

| Raktas      | Reikšmė                  |
| ---------- | ------------------------ |
| `:key`     | Raktas naudojamas talpykloje |
| `:store`   | Talpyklos klasės pavadinimas |

Pasirinktys, perduotos `fetch` metodui, bus sujungtos su duomenimis.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write.active_support`

| Raktas      | Reikšmė                  |
| ---------- | ------------------------ |
| `:key`     | Raktas naudojamas talpykloje |
| `:store`   | Talpyklos klasės pavadinimas |

Talpyklos gali pridėti savo duomenis taip pat.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write_multi.active_support`

| Raktas      | Reikšmė                                |
| ---------- | ------------------------------------ |
| `:key`     | Raktai ir reikšmės įrašytos į talpyklą |
| `:store`   | Talpyklos klasės pavadinimas          |
#### `cache_increment.active_support`

Šis įvykis yra iššaukiamas tik naudojant [`MemCacheStore`][ActiveSupport::Cache::MemCacheStore]
arba [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore].

| Raktas    | Reikšmė                 |
| --------- | ----------------------- |
| `:key`    | Raktas naudojamas saugykloje   |
| `:store`  | Saugyklos klasės pavadinimas |
| `:amount` | Padidinimo suma        |

```ruby
{
  key: "alus-buteliuose",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 99
}
```

#### `cache_decrement.active_support`

Šis įvykis yra iššaukiamas tik naudojant Memcached arba Redis saugyklas.

| Raktas    | Reikšmė                 |
| --------- | ----------------------- |
| `:key`    | Raktas naudojamas saugykloje   |
| `:store`  | Saugyklos klasės pavadinimas |
| `:amount` | Suma, kurią reikia sumažinti        |

```ruby
{
  key: "alus-buteliuose",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 1
}
```

#### `cache_delete.active_support`

| Raktas    | Reikšmė                 |
| --------- | ----------------------- |
| `:key`    | Raktas naudojamas saugykloje   |
| `:store`  | Saugyklos klasės pavadinimas |

```ruby
{
  key: "sudėtingo-skaiciavimo-pavadinimas",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_delete_multi.active_support`

| Raktas    | Reikšmė                 |
| --------- | ----------------------- |
| `:key`    | Raktai naudojami saugykloje  |
| `:store`  | Saugyklos klasės pavadinimas |

#### `cache_delete_matched.active_support`

Šis įvykis yra iššaukiamas tik naudojant [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore],
[`FileStore`][ActiveSupport::Cache::FileStore] arba [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Raktas    | Reikšmė                 |
| --------- | ----------------------- |
| `:key`    | Raktų šablonas        |
| `:store`  | Saugyklos klasės pavadinimas |

```ruby
{
  key: "įrašai/*",
  store: "ActiveSupport::Cache::RedisCacheStore"
}
```

#### `cache_cleanup.active_support`

Šis įvykis yra iššaukiamas tik naudojant [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Raktas    | Reikšmė                                         |
| --------- | --------------------------------------------- |
| `:store`  | Saugyklos klasės pavadinimas                       |
| `:size`   | Įrašų skaičius saugykloje prieš valymą |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  size: 9001
}
```

#### `cache_prune.active_support`

Šis įvykis yra iššaukiamas tik naudojant [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Raktas    | Reikšmė                                         |
| --------- | --------------------------------------------- |
| `:store`  | Saugyklos klasės pavadinimas                       |
| `:key`    | Tikslinis saugyklos dydis baitais          |
| `:from`   | Saugyklos dydis prieš valymą baitais     |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  key: 5000,
  from: 9001
}
```

#### `cache_exist?.active_support`

| Raktas    | Reikšmė                 |
| --------- | ----------------------- |
| `:key`    | Raktas naudojamas saugykloje   |
| `:store`  | Saugyklos klasės pavadinimas |

```ruby
{
  key: "sudėtingo-skaiciavimo-pavadinimas",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```


### Active Support — Pranešimai

#### `message_serializer_fallback.active_support`

| Raktas             | Reikšmė                         |
| --------------- | ----------------------------- |
| `:serializer`   | Pagrindinis (numatytasis) serializatorius |
| `:fallback`     | Atsarginis (faktinis) serializatorius  |
| `:serialized`   | Serializuotas eilutė             |
| `:deserialized` | Deserializuota reikšmė            |

```ruby
{
  serializer: :json_allow_marshal,
  fallback: :marshal,
  serialized: "\x04\b{\x06I\"\nHello\x06:\x06ETI\"\nWorld\x06;\x00T",
  deserialized: { "Hello" => "World" },
}
```

### Active Job

#### `enqueue_at.active_job`

| Raktas          | Reikšmė                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Eilės adapterio objektas, apdorojantis darbą |
| `:job`       | Darbo objektas                             |

#### `enqueue.active_job`

| Raktas          | Reikšmė                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Eilės adapterio objektas, apdorojantis darbą |
| `:job`       | Darbo objektas                             |

#### `enqueue_retry.active_job`

| Raktas          | Reikšmė                                  |
| ------------ | -------------------------------------- |
| `:job`       | Darbo objektas                             |
| `:adapter`   | Eilės adapterio objektas, apdorojantis darbą |
| `:error`     | Klaida, dėl kurios buvo bandyta darbą pakartoti        |
| `:wait`      | Laiko tarpas tarp pakartojimo                 |

#### `enqueue_all.active_job`

| Raktas          | Reikšmė                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Eilės adapterio objektas, apdorojantis darbą |
| `:jobs`      | Darbų objektų masyvas                |

#### `perform_start.active_job`

| Raktas          | Reikšmė                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Eilės adapterio objektas, apdorojantis darbą |
| `:job`       | Darbo objektas                             |

#### `perform.active_job`

| Raktas           | Reikšmė                                         |
| ------------- | --------------------------------------------- |
| `:adapter`    | Eilės adapterio objektas, apdorojantis darbą        |
| `:job`        | Darbo objektas                                    |
| `:db_runtime` | Laikas, praleistas vykdant duomenų bazės užklausas ms |

#### `retry_stopped.active_job`

| Raktas          | Reikšmė                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Eilės adapterio objektas, apdorojantis darbą |
| `:job`       | Darbo objektas                             |
| `:error`     | Klaida, dėl kurios buvo bandyta darbą pakartoti        |

#### `discard.active_job`

| Raktas          | Reikšmė                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Eilės adapterio objektas, apdorojantis darbą |
| `:job`       | Darbo objektas                             |
| `:error`     | Klaida, dėl kurios darbas buvo atmestas      |
### Veiksmo kabelis

#### `perform_action.action_cable`

| Raktas           | Reikšmė                    |
| ---------------- | ------------------------- |
| `:channel_class` | Kanalo klasės pavadinimas |
| `:action`        | Veiksmas                  |
| `:data`          | Duomenų maišos reikšmė    |

#### `transmit.action_cable`

| Raktas           | Reikšmė                    |
| ---------------- | ------------------------- |
| `:channel_class` | Kanalo klasės pavadinimas |
| `:data`          | Duomenų maišos reikšmė    |
| `:via`           | Per                       |

#### `transmit_subscription_confirmation.action_cable`

| Raktas           | Reikšmė                    |
| ---------------- | ------------------------- |
| `:channel_class` | Kanalo klasės pavadinimas |

#### `transmit_subscription_rejection.action_cable`

| Raktas           | Reikšmė                    |
| ---------------- | ------------------------- |
| `:channel_class` | Kanalo klasės pavadinimas |

#### `broadcast.action_cable`

| Raktas           | Reikšmė                |
| ---------------- | -------------------- |
| `:broadcasting` | Vardintas transliavimas |
| `:message`      | Pranešimo maišos reikšmė |
| `:coder`        | Koduotojas             |

### Aktyvus saugojimas

#### `preview.active_storage`

| Raktas          | Reikšmė              |
| --------------- | ------------------- |
| `:key`          | Saugus ženklas       |

#### `transform.active_storage`

#### `analyze.active_storage`

| Raktas          | Reikšmė                          |
| --------------- | ------------------------------ |
| `:analyzer`     | Analizatoriaus pavadinimas, pvz., ffprobe |

### Aktyvus saugojimas - Saugojimo paslauga

#### `service_upload.active_storage`

| Raktas          | Reikšmė                        |
| --------------- | ---------------------------- |
| `:key`          | Saugus ženklas                 |
| `:service`      | Paslaugos pavadinimas          |
| `:checksum`     | Patikrinti vientisumą          |

#### `service_streaming_download.active_storage`

| Raktas          | Reikšmė              |
| --------------- | ------------------- |
| `:key`          | Saugus ženklas       |
| `:service`      | Paslaugos pavadinimas |

#### `service_download_chunk.active_storage`

| Raktas          | Reikšmė                          |
| --------------- | ------------------------------ |
| `:key`          | Saugus ženklas                   |
| `:service`      | Paslaugos pavadinimas            |
| `:range`        | Bandytas skaityti baitų intervalas |

#### `service_download.active_storage`

| Raktas          | Reikšmė              |
| --------------- | ------------------- |
| `:key`          | Saugus ženklas       |
| `:service`      | Paslaugos pavadinimas |

#### `service_delete.active_storage`

| Raktas          | Reikšmė              |
| --------------- | ------------------- |
| `:key`          | Saugus ženklas       |
| `:service`      | Paslaugos pavadinimas |

#### `service_delete_prefixed.active_storage`

| Raktas          | Reikšmė              |
| --------------- | ------------------- |
| `:prefix`       | Raktų priešdėlis    |
| `:service`      | Paslaugos pavadinimas |

#### `service_exist.active_storage`

| Raktas          | Reikšmė                      |
| --------------- | -------------------------- |
| `:key`          | Saugus ženklas               |
| `:service`      | Paslaugos pavadinimas        |
| `:exist`        | Failas arba maiša egzistuoja arba ne |

#### `service_url.active_storage`

| Raktas          | Reikšmė              |
| --------------- | ------------------- |
| `:key`          | Saugus ženklas       |
| `:service`      | Paslaugos pavadinimas |
| `:url`          | Sugeneruotas URL     |

#### `service_update_metadata.active_storage`

Šis įvykis išskiriamas tik naudojant Google Cloud Storage paslaugą.

| Raktas             | Reikšmė                            |
| ------------------ | -------------------------------- |
| `:key`             | Saugus ženklas                     |
| `:service`         | Paslaugos pavadinimas              |
| `:content_type`    | HTTP `Content-Type` laukas        |
| `:disposition`     | HTTP `Content-Disposition` laukas |

### Veiksmo pašto dėžutė

#### `process.action_mailbox`

| Raktas              | Reikšmė                                                  |
| ------------------- | ------------------------------------------------------- |
| `:mailbox`          | Pašto dėžutės klasės pavyzdys, paveldintis iš [`ActionMailbox::Base`][] |
| `:inbound_email`    | Maišos su duomenimis apie apdorojamą gautą el. laišką |

```ruby
{
  mailbox: #<RepliesMailbox:0x00007f9f7a8388>,
  inbound_email: {
    id: 1,
    message_id: "0CB459E0-0336-41DA-BC88-E6E28C697DDB@37signals.com",
    status: "processing"
  }
}
```

### Railties

#### `load_config_initializer.railties`

| Raktas              | Reikšmė                                                 |
| ------------------- | ------------------------------------------------------ |
| `:initializer`      | Įkelto inicializatoriaus kelias `config/initializers` |

### Rails

#### `deprecation.rails`

| Raktas                    | Reikšmė                                                  |
| ------------------------- | ------------------------------------------------------- |
| `:message`                | Nebenaudojimo įspėjimas                                 |
| `:callstack`              | Iš kur kilo nebenaudojimas                              |
| `:gem_name`               | Gem pavadinimas, pranešantis apie nebenaudojimą          |
| `:deprecation_horizon`    | Versija, kurioje nebenaudojama elgsena bus pašalinta     |

Išimtys
----------

Jei bet kurioje instrumentacijoje įvyksta išimtis, įvykio duomenyse bus įtraukta
informacija apie tai.

| Raktas                 | Reikšmė                                                           |
| ---------------------- | ------------------------------------------------------------------ |
| `:exception`           | Masyvas, turintis du elementus. Išimties klasės pavadinimas ir pranešimas |
| `:exception_object`    | Išimties objektas                                                  |

Sukurti pasirinktinus įvykius
----------------------

Pridėti savo įvykius taip pat yra lengva. Aktyvusis palaikymas atliks visą
sunkų darbą už jus. Tiesiog iškvieskite [`ActiveSupport::Notifications.instrument`][] su `name`, `payload` ir bloku.
Pranešimas bus išsiųstas po to, kai blokas grąžins rezultatą. Aktyvusis palaikymas sugeneruos pradžios ir pabaigos laikus,
ir pridės instrumentuotojo unikalų ID. Visi į `instrument` išsiųsti duomenys bus
pateks į pranešimo duomenis.
Štai pavyzdys:

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data do
  # čia atlikite savo individualius veiksmus
end
```

Dabar galite klausytis šio įvykio naudodami:

```ruby
ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

Taip pat galite iškviesti `instrument` be bloko. Tai leidžia jums pasinaudoti instrumentavimo infrastruktūra kitais pranešimų naudojimo būdais.

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data

ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

Kurdami savo įvykius, turėtumėte laikytis "Rails" konvencijų. Formatas yra: `įvykis.biblioteka`.
Jei jūsų programa siunčia "Tweet'us", turėtumėte sukurti įvykį pavadinimu `tweet.twitter`.
[`ActiveSupport::Notifications::Event`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications/Event.html
[`ActiveSupport::Notifications.monotonic_subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-monotonic_subscribe
[`ActiveSupport::Notifications.subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-subscribe
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`ActionDispatch::Response`]: https://api.rubyonrails.org/classes/ActionDispatch/Response.html
[`config.active_record.action_on_strict_loading_violation`]: configuring.html#config-active-record-action-on-strict-loading-violation
[ActiveSupport::Cache::FileStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[ActiveSupport::Cache::MemCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemoryStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[ActiveSupport::Cache::RedisCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#fetch_multi]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch_multi
[`ActionMailbox::Base`]: https://api.rubyonrails.org/classes/ActionMailbox/Base.html
[`ActiveSupport::Notifications.instrument`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-instrument
