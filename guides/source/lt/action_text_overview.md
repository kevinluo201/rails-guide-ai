**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a4b9132308ed3786777061bd137af660
Action Text apžvalga
====================

Šis vadovas suteikia jums viską, ko jums reikia pradėti tvarkyti turtingą teksto turinį.

Po šio vadovo perskaitymo žinosite:

* Kaip konfigūruoti Action Text.
* Kaip tvarkyti turtingą teksto turinį.
* Kaip stilizuoti turtingą teksto turinį ir priedus.

--------------------------------------------------------------------------------

Kas yra Action Text?
--------------------

Action Text įtraukia turtingą teksto turinį ir redagavimą į „Rails“. Tai apima
[Trix redaktorių](https://trix-editor.org), kuris tvarko viską nuo formato
iki nuorodų, citatų, sąrašų, įterptų vaizdų ir galerijų.
Trix redaktoriaus sugeneruotas turtingas teksto turinys yra išsaugomas savo
RichText modelyje, kuris yra susijęs su bet kuriuo esamu „Active Record“ modeliu aplikacijoje.
Visi įterpti vaizdai (ar kiti priedai) automatiškai saugomi naudojant
Active Storage ir susiję su įtrauktu RichText modeliu.

## Trix palyginimas su kitais turtingo teksto redaktoriais

Dauguma WYSIWYG redaktorių yra apvalkalai aplink HTML „contenteditable“ ir „execCommand“ sąsajas,
sukurtas „Microsoft“ siekiant palaikyti gyvą tinklalapių redagavimą „Internet Explorer 5.5“ naršyklėje,
ir [galiausiai atvirkščiai inžinerija](https://blog.whatwg.org/the-road-to-html-5-contenteditable#history)
ir nukopijuota kitų naršyklių.

Kadangi šios sąsajos niekada nebuvo visiškai nurodytos arba aprašytos,
ir kadangi WYSIWYG HTML redaktoriai yra labai apimtys, kiekvienas
naršyklės įgyvendinimas turi savo klaidų ir ypatybių rinkinį,
o „JavaScript“ programuotojai turi išspręsti nesuderinamumus.

Trix šiuos nesuderinamumus apeina, laikydamas „contenteditable“
kaip įvedimo / išvedimo įrenginį: kai įvestis pasiekia redaktorių, Trix konvertuoja tą įvestį
į redagavimo operaciją savo vidiniame dokumento modelyje, tada vėl atvaizduoja
tą dokumentą atgal į redaktorių. Tai suteikia Trix visišką kontrolę, ką
vyksta po kiekvieno klavišo paspaudimo, ir išvengia poreikio naudoti execCommand visiškai.

## Įdiegimas

Paleiskite `bin/rails action_text:install`, kad pridėtumėte „Yarn“ paketą ir nukopijuotumėte reikalingą migraciją. Taip pat, jums reikia sukonfigūruoti „Active Storage“ įterptiems vaizdams ir kitiems priedams. Prašome kreiptis į [„Active Storage“ apžvalgą](active_storage_overview.html) vadovą.

PASTABA: „Action Text“ naudoja daugiareikšmiškus ryšius su `action_text_rich_texts` lentele, kad ją galima būtų bendrinti su visais modeliais, turinčiais turtingo teksto atributus. Jei jūsų modeliai su „Action Text“ turiniu naudoja UUID reikšmes identifikatoriams, visi modeliai, naudojantys „Action Text“ atributus, turės naudoti UUID reikšmes savo unikaliems identifikatoriams. Sukurtai „Action Text“ migracijai taip pat reikės atnaujinti `:record` `references` eilutę, nurodydami `type: :uuid`.

Po įdiegimo baigimo „Rails“ programoje turėtų būti šie pakeitimai:

1. Abi „trix“ ir „@rails/actiontext“ turi būti reikalaujamos jūsų „JavaScript“ įėjimo taške.

    ```js
    // application.js
    import "trix"
    import "@rails/actiontext"
    ```

2. „trix“ stiliaus lapas bus įtrauktas kartu su „Action Text“ stiliais jūsų `application.css` faile.

## Kuriamas turtingas teksto turinys

Pridėkite turtingo teksto lauką esamam modeliui:

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  has_rich_text :content
end
```

arba pridėkite turtingo teksto lauką, kuriant naują modelį naudojant:

```bash
$ bin/rails generate model Message content:rich_text
```

PASTABA: jums nereikia pridėti `content` lauko į savo `messages` lentelę.

Tada naudokite [`rich_text_area`], kad nurodytumėte šį lauką modelio formoje:

```erb
<%# app/views/messages/_form.html.erb %>
<%= form_with model: message do |form| %>
  <div class="field">
    <%= form.label :content %>
    <%= form.rich_text_area :content %>
  </div>
<% end %>
```

Ir galiausiai, atvaizduokite išvalytą turtingą tekstą puslapyje:

```erb
<%= @message.content %>
```

PASTABA: Jei `content` lauke yra pridėtas ištekėjusi ištekla, ji gali būti neteisingai rodoma, nebent
jūsų mašinoje yra įdiegta *libvips/libvips42* paketas.
Patikrinkite jų [įdiegimo dokumentaciją](https://www.libvips.org/install.html), kaip jį gauti.

Norėdami priimti turtingą teksto turinį, jums tereikia leisti nurodytą atributą:

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create! params.require(:message).permit(:title, :content)
    redirect_to message
  end
end
```


## Turtingo teksto turinio atvaizdavimas

Pagal numatymą, „Action Text“ turtingas teksto turinys bus atvaizduojamas viduje elemento su
`.trix-content` klasės:

```html+erb
<%# app/views/layouts/action_text/contents/_content.html.erb %>
<div class="trix-content">
  <%= yield %>
</div>
```

Šios klasės elementai, taip pat „Action Text“ redaktorius, yra stilizuojami
[`trix` stiliaus lapu](https://unpkg.com/trix/dist/trix.css).
Norėdami pateikti savo stilius, pašalinkite `= require trix` eilutę iš
`app/assets/stylesheets/actiontext.css` stiliaus lapo, sukurti instaliuojant.

Norėdami pritaikyti HTML, atvaizduojamą aplink turtingą teksto turinį, redaguokite
`app/views/layouts/action_text/contents/_content.html.erb` išdėstymą, sukurtą
instaliuojant.

Norėdami pritaikyti HTML, atvaizduojamą įterptiems vaizdams ir kitiems priedams (žinomiems
kaip „blobs“), redaguokite `app/views/active_storage/blobs/_blob.html.erb` šabloną
sukurtą instaliuojant.
### Priedų atvaizdavimas

Be priedų, įkeltų per Active Storage, Action Text gali įterpti bet ką, kas gali būti išspręsta naudojant [Signed GlobalID](https://github.com/rails/globalid#signed-global-ids).

Action Text atvaizduoja įterptus `<action-text-attachment>` elementus išsprendžiant jų `sgid` atributą į egzempliorių. Išspręstas egzempliorius perduodamas
[`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render) funkcijai. Gautas HTML įterpiamas kaip `<action-text-attachment>`
elemento palikuonis.

Pavyzdžiui, apsvarstykime `User` modelį:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar
end

user = User.find(1)
user.to_global_id.to_s #=> gid://MyRailsApp/User/1
user.to_signed_global_id.to_s #=> BAh7CEkiCG…
```

Toliau apsvarstykime turtingo teksto turinį, kuriame įterptas `<action-text-attachment>`
elementas, kuris nuorodoje naudoja `User` egzemplioriaus pasirašytą GlobalID:

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>.</p>
```

Action Text išsprendžia "BAh7CEkiCG…" eilutę, kad gautų `User`
egzempliorių. Toliau apsvarstykime aplikacijos `users/user` dalinį:

```html+erb
<%# app/views/users/_user.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Action Text atvaizduojamas HTML atrodytų kaip:

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"><span><img src="..."> Jane Doe</span></action-text-attachment>.</p>
```

Norint atvaizduoti kitą dalinį, apibrėžkite `User#to_attachable_partial_path`:

```ruby
class User < ApplicationRecord
  def to_attachable_partial_path
    "users/attachable"
  end
end
```

Tada apibrėžkite tą dalinį. `User` egzempliorius bus prieinamas kaip `user`
dalies lokalusis kintamasis:

```html+erb
<%# app/views/users/_attachable.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Jei Action Text negali išspręsti `User` egzemplioriaus (pvz., jei
įrašas buvo ištrintas), tuomet bus atvaizduojamas numatytasis dalinis.

Rails teikia globalų dalinį, skirtą praleistų priedų atvaizdavimui. Šis dalinis yra įdiegtas
jūsų aplikacijoje `views/action_text/attachables/missing_attachable` ir gali
būti keičiamas, jei norite atvaizduoti kitą HTML.

Norint atvaizduoti kitą praleistą priedo dalinį, apibrėžkite klasės lygio
`to_missing_attachable_partial_path` metodą:

```ruby
class User < ApplicationRecord
  def self.to_missing_attachable_partial_path
    "users/missing_attachable"
  end
end
```

Tada apibrėžkite tą dalinį.

```html+erb
<%# app/views/users/missing_attachable.html.erb %>
<span>Ištrintas vartotojas</span>
```

Norint integruoti su Action Text `<action-text-attachment>` elemento atvaizdavimu, klasė turi:

* įtraukti `ActionText::Attachable` modulį
* įgyvendinti `#to_sgid(**options)` (prieinamą per [`GlobalID::Identification` concern][global-id])
* (neprivaloma) apibrėžti `#to_attachable_partial_path`
* (neprivaloma) apibrėžti klasės lygio metodą `#to_missing_attachable_partial_path` praleistų įrašų tvarkymui

Pagal numatytuosius nustatymus visi `ActiveRecord::Base` palikuonys įtraukia
[`GlobalID::Identification` concern][global-id], ir todėl
yra suderinami su `ActionText::Attachable`.


## Išvengti N+1 užklausų

Jei norite iš anksto įkelti priklausomą `ActionText::RichText` modelį, priimant, kad jūsų turtingo teksto laukas vadinamas `content`, galite naudoti vardintąjį tašką:

```ruby
Message.all.with_rich_text_content # Iš anksto įkelkite kūną be priedų.
Message.all.with_rich_text_content_and_embeds # Iš anksto įkelkite tiek kūną, tiek priedus.
```

## API / Backend plėtra

1. Atskiram galinės dalies API (pvz., naudojant JSON) reikalingas atskiras galinės dalies taškas failų įkėlimui, kuris sukuria `ActiveStorage::Blob` ir grąžina jo `attachable_sgid`:

    ```json
    {
      "attachable_sgid": "BAh7CEkiCG…"
    }
    ```

2. Paimkite tą `attachable_sgid` ir paprašykite savo priekinės dalies įterpti jį turtingame tekste naudojant `<action-text-attachment>` žymą:

    ```html
    <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>
    ```

Tai pagrįsta Basecamp, todėl jei vis dar negalite rasti to, ko ieškote, patikrinkite šį [Basecamp dokumentą](https://github.com/basecamp/bc3-api/blob/master/sections/rich_text.md).
[`rich_text_area`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area
[global-id]: https://github.com/rails/globalid#usage
