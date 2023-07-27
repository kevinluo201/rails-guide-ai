**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ddd82b1a207070829b1ec46e4bb40d80
Ruby on Rails 5.1 Išleidimo pastabos
=====================================

Svarbiausios naujovės Rails 5.1 versijoje:

* Yarn palaikymas
* Neprivalomas Webpack palaikymas
* jQuery nebėra numatytasis priklausomybė
* Sistemos testai
* Užšifruoti paslaptys
* Parametrizuoti pašto siuntėjai
* Tiesioginiai ir išspręsti maršrutai
* form_for ir form_tag sujungimas į form_with

Šiose išleidimo pastabose aptariamos tik pagrindinės naujovės. Norėdami sužinoti apie įvairius klaidų taisymus ir pakeitimus, prašome kreiptis į pakeitimų žurnalus arba peržiūrėti [pakeitimų sąrašą](https://github.com/rails/rails/commits/5-1-stable) pagrindiniame Rails saugykloje GitHub.

--------------------------------------------------------------------------------

Atnaujinimas į Rails 5.1
------------------------

Jei atnaujinote esamą programą, gerai būtų turėti gerą testavimo padengimą prieš pradedant. Taip pat pirmiausia turėtumėte atnaujinti iki Rails 5.0, jei dar to nepadarėte, ir įsitikinti, kad jūsų programa veikia kaip tikėtasi, prieš bandant atnaujinti į Rails 5.1. Atnaujinimo metu reikėtų atkreipti dėmesį į keletą dalykų, kuriuos galima rasti [Ruby on Rails atnaujinimo](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1) vadove.

Pagrindinės funkcijos
---------------------

### Yarn palaikymas

[Pakeitimo užklausa](https://github.com/rails/rails/pull/26836)

Rails 5.1 leidžia valdyti JavaScript priklausomybes iš npm per Yarn. Tai leis lengvai naudoti bibliotekas kaip React, VueJS ar bet kurią kitą biblioteką iš npm pasaulio. Yarn palaikymas yra integruotas su turinio paleidimo sistema, todėl visos priklausomybės veiks sklandžiai su Rails 5.1 programa.

### Neprivalomas Webpack palaikymas

[Pakeitimo užklausa](https://github.com/rails/rails/pull/27288)

Rails programos gali lengviau integruotis su [Webpack](https://webpack.js.org/), JavaScript turinio paleidimo įrankiu, naudojant naują [Webpacker](https://github.com/rails/webpacker) juostą. Generuojant naujas programas, galima naudoti `--webpack` vėliavą, kad įgalintumėte Webpack integraciją.

Tai yra visiškai suderinama su turinio paleidimo sistema, kurią galite toliau naudoti vaizdams, šriftams, garsams ir kitam turiniui. Galite netgi turėti tam tikrą JavaScript kodą, valdomą turinio paleidimo sistema, ir kitą kodą, apdorojamą per Webpack. Visa tai valdo Yarn, kuris yra įjungtas pagal numatytuosius nustatymus.

### jQuery nebėra numatytasis priklausomybė

[Pakeitimo užklausa](https://github.com/rails/rails/pull/27113)

Anksčiau versijose jQuery buvo reikalaujama pagal numatytuosius nustatymus, kad būtų galima naudoti funkcijas kaip `data-remote`, `data-confirm` ir kitas Rails "Unobtrusive JavaScript" paslaugas. Dabar tai nebėra būtina, nes UJS buvo perrašytas naudojant paprastą, natūralųjį JavaScript. Šis kodas dabar yra įtrauktas į Action View kaip `rails-ujs`.
Jei reikia, vis tiek galite naudoti jQuery, tačiau jis nebėra numatytasis.

### Sistemos testai

[Pasiūlymas](https://github.com/rails/rails/pull/26703)

Rails 5.1 turi įdiegtą palaikymą rašyti Capybara testus, naudojant
Sistemos testus. Jums nebėra reikalinga rūpintis Capybara ir
duomenų bazės valymo strategijomis šiems testams. Rails 5.1 teikia apvalkalą
testams paleisti „Chrome“ naršyklėje su papildomomis funkcijomis, pvz., nesėkmės
ekranų nuotraukos.

### Užšifruoti paslaptys

[Pasiūlymas](https://github.com/rails/rails/pull/28038)

Rails dabar leidžia tvarkyti programos paslaptis saugiu būdu,
inspiruotas [sekrets](https://github.com/ahoward/sekrets) grotelės.

Paleiskite `bin/rails secrets:setup`, kad sukurtumėte naują užšifruotų paslapčių failą. Tai
taip pat sugeneruos pagrindinį raktą, kuris turi būti saugomas už repozitorijos ribų. 
Patys paslapčių gali būti saugiai įtraukti į versijų kontrolės sistemą,
užšifruota forma.

Paslapčios bus iššifruojamos veikimo metu, naudojant raktą, saugomą arba
`RAILS_MASTER_KEY` aplinkos kintamajame, arba raktų faile.

### Parametrizuoti laiškai

[Pasiūlymas](https://github.com/rails/rails/pull/27825)

Leidžia nurodyti bendrus parametrus, naudojamus visiems metodams laiškų klasėje,
kad būtų galima dalintis objektų kintamaisiais, antraštimais ir kitais bendrais nustatymais.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name} pakvietė jus į savo Basecamp (#{@account.name})"
  end
end
```

```ruby
InvitationsMailer.with(inviter: person_a, invitee: person_b)
                 .account_invitation.deliver_later
```

### Tiesioginiai ir išsprendžiami maršrutai

[Pasiūlymas](https://github.com/rails/rails/pull/23138)

Rails 5.1 prideda dvi naujas metodus, `resolve` ir `direct`, maršrutizavimo
DSL. `resolve` metodas leidžia tinkinti modelių polimorfinį atvaizdavimą.

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_for @basket do |form| %>
  <!-- krepšelio forma -->
<% end %>
```

Tai sugeneruos vienintelį URL `/basket` vietoj įprasto `/baskets/:id`.

`direct` metodas leidžia kurti tinkintus URL pagalbininkus.

```ruby
direct(:homepage) { "https://rubyonrails.org" }

homepage_url # => "https://rubyonrails.org"
```

Bloko grąžinimo reikšmė turi būti tinkama argumentui `url_for`
metodui. Taigi, galite perduoti tinkamą eilutės URL, Hash, masyvą,
aktyvaus modelio objektą arba aktyvaus modelio klasę.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```
### form_for ir form_tag sujungimas į form_with

[Pull Request](https://github.com/rails/rails/pull/26976)

Iki Rails 5.1 buvo du sąsajos HTML formų tvarkymui:
`form_for` modelio instancijoms ir `form_tag` pasirinktoms URL.

Rails 5.1 sujungia šias sąsajas su `form_with` ir
gali generuoti formos žymes pagal URL, ribas ar modelius.

Naudojant tik URL:

```erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Sugeneruos %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

Pridedant ribą, įvesties laukų pavadinimai bus prefiksuoti:

```erb
<%= form_with scope: :post, url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Sugeneruos %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

Naudojant modelį, URL ir riba bus nustatomi automatiškai:

```erb
<%= form_with model: Post.new do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Sugeneruos %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

Esamas modelis sukuria atnaujinimo formą ir užpildo laukų reikšmes:

```erb
<%= form_with model: Post.first do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Sugeneruos %>

<form action="/posts/1" method="post" data-remote="true">
  <input type="hidden" name="_method" value="patch">
  <input type="text" name="post[title]" value="<the title of the post>">
</form>
```

Nesuderinamumai
-----------------

Šie pakeitimai gali reikalauti nedelsiant veiksmo po atnaujinimo.

### Transakciniai testai su keliais ryšiais

Transakciniai testai dabar apgaubia visas Active Record ryšius duomenų bazėje.

Kai testas sukuria papildomus gijas ir šios gijos gauna duomenų bazės ryšius,
šie ryšiai dabar yra tvarkomi specialiai:

Gijos bendrai naudoja vieną ryšį, kuris yra valdomoje transakcijoje.
Tai užtikrina, kad visos gijos matytų duomenų bazę toje pačioje būsenoje,
ignoruojant išorinę transakciją. Anksčiau tokiems papildomiems ryšiams
buvo neįmanoma matyti pavyzdinių eilučių, pavyzdžiui.

Kai gija patenka į vidinę transakciją, ji laikinai gauna
ekskluzyvų ryšio naudojimą, kad būtų išlaikyta izoliacija.

Jei jūsų testai dabar priklauso nuo atskiro,
nebūtinai transakcijos, ryšio gijoje, turėsite
perjungti į aiškesnį ryšio valdymą.

Jei jūsų testai sukuria gijas ir šios gijos sąveikauja,
naudodamos aiškias duomenų bazės transakcijas, šis pakeitimas
gali sukelti užstrigimus.
Paprastas būdas išjungti šį naują elgesį yra išjungti transakcinius testus visuose testavimo atvejuose, kuriuos tai veikia.

Railties
--------

Išsamius pakeitimus žr. [Changelog][railties].

### Pašalinimai

*   Pašalintas pasenusi `config.static_cache_control`.
    ([commit](https://github.com/rails/rails/commit/c861decd44198f8d7d774ee6a74194d1ac1a5a13))

*   Pašalintas pasenusi `config.serve_static_files`.
    ([commit](https://github.com/rails/rails/commit/0129ca2eeb6d5b2ea8c6e6be38eeb770fe45f1fa))

*   Pašalintas pasenusi failas `rails/rack/debugger`.
    ([commit](https://github.com/rails/rails/commit/7563bf7b46e6f04e160d664e284a33052f9804b8))

*   Pašalintos pasenusios užduotys: `rails:update`, `rails:template`, `rails:template:copy`,
    `rails:update:configs` ir `rails:update:bin`.
    ([commit](https://github.com/rails/rails/commit/f7782812f7e727178e4a743aa2874c078b722eef))

*   Pašalinta pasenusi `CONTROLLER` aplinkos kintamoji `routes` užduočiai.
    ([commit](https://github.com/rails/rails/commit/f9ed83321ac1d1902578a0aacdfe55d3db754219))

*   Pašalinta -j (--javascript) parinktis iš `rails new` komandos.
    ([Pull Request](https://github.com/rails/rails/pull/28546))

### Svarbūs pakeitimai

*   Pridėta bendra sekcija `config/secrets.yml`, kuri bus įkrauta visiems aplinkoms.
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   Konfigūracijos failas `config/secrets.yml` dabar įkeliamas su visais raktų simboliais.
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   Pašalintas jquery-rails iš numatytosios eilės. rails-ujs, kuris yra pristatomas
    su Action View, įtrauktas kaip numatytasis UJS adapteris.
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   Pridėta Yarn palaikymas naujose programose su yarn binstub ir package.json.
    ([Pull Request](https://github.com/rails/rails/pull/26836))

*   Pridėtas Webpack palaikymas naujose programose naudojant `--webpack` parinktį, kuri deleguos
    į rails/webpacker gemą.
    ([Pull Request](https://github.com/rails/rails/pull/27288))

*   Sukuriamas Git saugykla, kai generuojama nauja programa, jei nenurodyta `--skip-git` parinktis.
    ([Pull Request](https://github.com/rails/rails/pull/27632))

*   Pridėti užšifruoti paslaptys `config/secrets.yml.enc`.
    ([Pull Request](https://github.com/rails/rails/pull/28038))

*   Rodyti railtie klasės pavadinimą `rails initializers`.
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

Išsamius pakeitimus žr. [Changelog][action-cable].

### Svarbūs pakeitimai

*   Pridėta palaikymas `channel_prefix` Redis ir evented Redis adapteriams
    `cable.yml`, kad išvengtumėte pavadinimų susidūrimų naudojant tą patį Redis serverį
    su keliais taikomaisiais.
    ([Pull Request](https://github.com/rails/rails/pull/27425))

*   Pridėtas `ActiveSupport::Notifications` kabliuko transliavimo duomenims.
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

Išsamius pakeitimus žr. [Changelog][action-pack].

### Pašalinimai

*   Pašalintas nepalaikomas parametrų perduodimo būdas `#process`, `#get`, `#post`,
    `#patch`, `#put`, `#delete` ir `#head` metodams `ActionDispatch::IntegrationTest`
    ir `ActionController::TestCase` klasėse.
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

*   Pašalintas pasenusių `ActionDispatch::Callbacks.to_prepare` ir
    `ActionDispatch::Callbacks.to_cleanup` palaikymas.
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

*   Pašalinti pasenusių metodų, susijusių su valdiklio filtrų, palaikymas.
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

*   Pašalintas pasenusių `:text` ir `:nothing` parametrų palaikymas `render`.
    ([Commit](https://github.com/rails/rails/commit/79a5ea9eadb4d43b62afacedc0706cbe88c54496),
    [Commit](https://github.com/rails/rails/commit/57e1c99a280bdc1b324936a690350320a1cd8111))

*   Pašalintas pasenusi palaikymas `HashWithIndifferentAccess` metodams, kviečiant juos iš `ActionController::Parameters`.
    ([Commit](https://github.com/rails/rails/pull/26746/commits/7093ceb480ad6a0a91b511832dad4c6a86981b93))

### Pasenusių funkcijų pažymėjimai

*   Pažymėtas pasenusi `config.action_controller.raise_on_unfiltered_parameters`.
    Tai neturi jokio poveikio „Rails 5.1“.
    ([Commit](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### Svarbūs pakeitimai

*   Pridėti `direct` ir `resolve` metodai maršrutojimo DSL.
    ([Pull Request](https://github.com/rails/rails/pull/23138))
*   Pridėta nauja `ActionDispatch::SystemTestCase` klasė, skirta rašyti sistemos testus jūsų programose.
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

Išsamius pakeitimus žiūrėkite [Changelog][action-view].

### Pašalinimai

*   Pašalintas pasenusių `#original_exception` metodas `ActionView::Template::Error` klasėje.
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

*   Pašalinta `encode_special_chars` klaidingai pavadinta parinktis iš `strip_tags` metodo.
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### Pasenusi funkcionalumas

*   Pasenęs Erubis ERB tvarkytuvas pakeistas naudojant Erubi.
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### Svarbūs pakeitimai

*   Šiukšlių šablonų tvarkytuvas (numatytasis šablonų tvarkytuvas „Rails 5“) dabar išveda saugius HTML tekstus.
    ([commit](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

*   Pakeistas `datetime_field` ir `datetime_field_tag` generuojant `datetime-local` laukus.
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   Naujas „Builder“ stiliaus sintaksės variantas HTML žymėms (`tag.div`, `tag.br`, ir kt.).
    ([Pull Request](https://github.com/rails/rails/pull/25543))

*   Pridėtas `form_with` metodas, vienijantis `form_tag` ir `form_for` naudojimą.
    ([Pull Request](https://github.com/rails/rails/pull/26976))

*   Pridėta `check_parameters` parinktis `current_page?` metode.
    ([Pull Request](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

Išsamius pakeitimus žiūrėkite [Changelog][action-mailer].

### Svarbūs pakeitimai

*   Leidžiama nustatyti pasirinktinį turinio tipą, kai yra pridedami priedai ir kūnas nustatomas tiesiogiai.
    ([Pull Request](https://github.com/rails/rails/pull/27227))

*   Leidžiama perduoti lambda funkcijas kaip reikšmes `default` metode.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Pridėta parametrizuota kvietimo mailer'iams palaikymo galimybė, kad būtų galima bendrinti prieš filtrus ir numatytuosius nustatymus
    tarp skirtingų mailer'io veiksmų.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Įvykio `process.action_mailer` metode įeinantys argumentai perduodami mailer'io veiksmui po `args` raktazodžio.
    ([Pull Request](https://github.com/rails/rails/pull/27900))

Active Record
-------------

Išsamius pakeitimus žiūrėkite [Changelog][active-record].

### Pašalinimai

*   Pašalinta parametrų ir bloko perdavimo palaikymo galimybė `ActiveRecord::QueryMethods#select` metode.
    ([Commit](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

*   Pašalintos pasenusios `activerecord.errors.messages.restrict_dependent_destroy.one` ir
    `activerecord.errors.messages.restrict_dependent_destroy.many` i18n sritys.
    ([Commit](https://github.com/rails/rails/commit/00e3973a311))

*   Pašalintas pasenusios jėgos perkrovos argumentas vienam ir kolekcijos asociacijų skaitytuvams.
    ([Commit](https://github.com/rails/rails/commit/09cac8c67af))

*   Pašalinta palaikymo galimybė perduoti stulpelį į `#quote` metodą.
    ([Commit](https://github.com/rails/rails/commit/e646bad5b7c))

*   Pašalintas `name` argumentas iš `#tables` metodo.
    ([Commit](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

*   Pašalintas `#tables` ir `#table_exists?` metodų pasenusi elgsena, grąžinanti tik lentas, o ne vaizdus.
    ([Commit](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

*   Pašalintas pasenusių `original_exception` argumentas iš `ActiveRecord::StatementInvalid#initialize`
    ir `ActiveRecord::StatementInvalid#original_exception` metodų.
    ([Commit](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

*   Pašalinta palaikymo galimybė perduoti klasę kaip reikšmę užklausai.
    ([Commit](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

*   Pašalinta palaikymo galimybė užklausti naudojant kablelius LIMIT'e.
    ([Commit](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

*   Pašalintas `conditions` parametras iš `#destroy_all` metodo.
    ([Commit](https://github.com/rails/rails/commit/d31a6d1384cd740c8518d0bf695b550d2a3a4e9b))

*   Pašalintas `conditions` parametras iš `#delete_all` metodo.
    ([Commit](https://github.com/rails/rails/pull/27503/commits/e7381d289e4f8751dcec9553dcb4d32153bd922b))

*   Pašalintas `#load_schema_for` metodas, naudoti `#load_schema` metodą.
    ([Commit](https://github.com/rails/rails/commit/419e06b56c3b0229f0c72d3e4cdf59d34d8e5545))

*   Pašalinta `#raise_in_transactional_callbacks` konfigūracija.
    ([Commit](https://github.com/rails/rails/commit/8029f779b8a1dd9848fee0b7967c2e0849bf6e07))
*   Pašalinta pasenusi `#use_transactional_fixtures` konfigūracija.
    ([Commit](https://github.com/rails/rails/commit/3955218dc163f61c932ee80af525e7cd440514b3))

### Pasenusi funkcionalumas

*   Pasenęs `error_on_ignored_order_or_limit` vėliavėlė, naudoti
    `error_on_ignored_order` vietoje.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   Pasenęs `sanitize_conditions`, naudoti `sanitize_sql` vietoje.
    ([Pull Request](https://github.com/rails/rails/pull/25999))

*   Pasenęs `supports_migrations?` jungties adapteriuose.
    ([Pull Request](https://github.com/rails/rails/pull/28172))

*   Pasenęs `Migrator.schema_migrations_table_name`, naudoti `SchemaMigration.table_name` vietoje.
    ([Pull Request](https://github.com/rails/rails/pull/28351))

*   Pasenęs `#quoted_id` naudojimas citavime ir tipo keitime.
    ([Pull Request](https://github.com/rails/rails/pull/27962))

*   Pasenęs `default` argumento perdavimas į `#index_name_exists?`.
    ([Pull Request](https://github.com/rails/rails/pull/26930))

### Svarbūs pakeitimai

*   Pakeistas numatytasis pirminis raktas į BIGINT.
    ([Pull Request](https://github.com/rails/rails/pull/26266))

*   Pridėta palaikymas virtualiems/sugeneruotiems stulpeliams MySQL 5.7.5+ ir MariaDB 5.2.0+.
    ([Commit](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

*   Pridėtas palaikymas limitams masinio apdorojimo metu.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   Transakciniai testai dabar apgaubia visus Active Record ryšius duomenų bazėje.
    ([Pull Request](https://github.com/rails/rails/pull/28726))

*   Pagal nutylėjimą praleidžiami komentarai `mysqldump` komandos rezultatuose.
    ([Pull Request](https://github.com/rails/rails/pull/23301))

*   Ištaisytas `ActiveRecord::Relation#count`, kad būtų naudojamas Ruby `Enumerable#count` metodas
    įrašams skaičiuoti, kai perduodamas blokas kaip argumentas, o ne tyliai ignoruojamas
    perduotas blokas.
    ([Pull Request](https://github.com/rails/rails/pull/24203))

*   Pridėtas `"-v ON_ERROR_STOP=1"` vėliavėlė su `psql` komanda, kad nebūtų slopinami SQL klaidos.
    ([Pull Request](https://github.com/rails/rails/pull/24773))

*   Pridėtas `ActiveRecord::Base.connection_pool.stat`.
    ([Pull Request](https://github.com/rails/rails/pull/26988))

*   Klaida iškelia, kai tiesiogiai paveldima iš `ActiveRecord::Migration`.
    Nurodykite Rails versiją, kuriai migracija buvo parašyta.
    ([Commit](https://github.com/rails/rails/commit/249f71a22ab21c03915da5606a063d321f04d4d3))

*   Klaida iškelia, kai `through` asociacija turi dviprasmišką atspindį.
    ([Commit](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

Išsamūs pakeitimai pateikti [Changelog][active-model] faile.

### Pašalinimai

*   Pašalinti pasenusi metodai `ActiveModel::Errors`.
    ([commit](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

*   Pašalinta pasenusi `:tokenizer` parinktis ilgio tikrintuve.
    ([commit](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

*   Pašalintas pasenusi elgsenos, kai nutraukiamos atgalinės iškvietimų grandinės, kai grąžinimo reikšmė yra false.
    ([commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### Svarbūs pakeitimai

*   Originalus modelio atributui priskirtas tekstas dabar neteisingai nešaldomas.
    ([Pull Request](https://github.com/rails/rails/pull/28729))

Active Job
-----------

Išsamūs pakeitimai pateikti [Changelog][active-job] faile.

### Pašalinimai

*   Pašalinta pasenusi palaikymo galimybė perduoti adapterio klasę į `.queue_adapter`.
    ([commit](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   Pašalinta pasenusi `#original_exception` `ActiveJob::DeserializationError`.
    ([commit](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### Svarbūs pakeitimai

*   Pridėtas deklaratyvus išimčių valdymas per `ActiveJob::Base.retry_on` ir `ActiveJob::Base.discard_on`.
    ([Pull Request](https://github.com/rails/rails/pull/25991))

*   Perduodamas darbo pavyzdys, kad būtų galima pasiekti dalykus, pvz., `job.arguments`,
    po pasikartojimų nepavykusios papildomos logikos metu.
    ([commit](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

Active Support
--------------

Išsamūs pakeitimai pateikti [Changelog][active-support] faile.

### Pašalinimai

*   Pašalinta `ActiveSupport::Concurrency::Latch` klasė.
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   Pašalintas `halt_callback_chains_on_return_false`.
    ([Commit](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))
*   Pašalintas pasenusi elgsena, kuri stabdo atgalinius kvietimus, kai grąžinama false.
    ([Įsipareigojimas](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### Pasenusių funkcijų pašalinimas

*   Viršutinio lygio `HashWithIndifferentAccess` klasė buvo švelniai pasenusi,
    naudojant `ActiveSupport::HashWithIndifferentAccess` klasę.
    ([Pasiūlymas](https://github.com/rails/rails/pull/28157))

*   Pasenusi eilutės perdavimas `:if` ir `:unless` sąlyginėms parinktims `set_callback` ir `skip_callback`.
    ([Įsipareigojimas](https://github.com/rails/rails/commit/0952552))

### Svarbūs pakeitimai

*   Ištaisytas trukmės analizavimas ir kelionė, kad būtų išlaikytas nuoseklumas per DST pakeitimus.
    ([Įsipareigojimas](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [Pasiūlymas](https://github.com/rails/rails/pull/26597))

*   Atnaujintas Unicode iki 9.0.0 versijos.
    ([Pasiūlymas](https://github.com/rails/rails/pull/27822))

*   Pridėtos `Duration#before` ir `#after` kaip sinonimai `ago` ir `since`.
    ([Pasiūlymas](https://github.com/rails/rails/pull/27721))

*   Pridėtas `Module#delegate_missing_to` metodas, kuris perduoda metodo kvietimus,
    kurie nėra apibrėžti dabartiniam objektui, į peržiūros objektą.
    ([Pasiūlymas](https://github.com/rails/rails/pull/23930))

*   Pridėtas `Date#all_day` metodas, kuris grąžina intervalą, atitinkantį visą dabartinės datos ir laiko dieną.
    ([Pasiūlymas](https://github.com/rails/rails/pull/24930))

*   Įvesti `assert_changes` ir `assert_no_changes` metodai testams.
    ([Pasiūlymas](https://github.com/rails/rails/pull/25393))

*   `travel` ir `travel_to` metodai dabar iškeliauja į klaidą dėl įdėtų kvietimų.
    ([Pasiūlymas](https://github.com/rails/rails/pull/24890))

*   Atnaujintas `DateTime#change` metodas, kad būtų palaikomi `usec` ir `nsec`.
    ([Pasiūlymas](https://github.com/rails/rails/pull/28242))

Autoriai
-------

Peržiūrėkite
[pilną sąrašą asmenų, prisidėjusių prie Rails](https://contributors.rubyonrails.org/), kurie
daug valandų skyrė kurti Rails, stabilų ir patikimą
karkasą. Pagarba visiems jiems.

[railties]:       https://github.com/rails/rails/blob/5-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-1-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
