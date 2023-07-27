**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f6b613040c7aed4c76b6648b6fd963cf
Veiksmo peržiūros apžvalga
====================

Perskaitę šį vadovą, žinosite:

* Kas yra Action View ir kaip jį naudoti su „Rails“.
* Kaip geriausia naudoti šablonus, dalinius ir išdėstymus.
* Kaip naudoti lokalizuotus rodinius.

--------------------------------------------------------------------------------

Kas yra Action View?
--------------------

„Rails“ programoje interneto užklausos apdorojamos naudojant [Action Controller](action_controller_overview.html) ir Action View. Paprastai Action Controller yra susijęs su duomenų bazės sąveika ir atlieka CRUD veiksmus, jei reikia. Tada Action View atsakingas už atsakymo sudarymą.

Action View šablonai rašomi naudojant įterptą Ruby kodą, sumaišytą su HTML žymėmis. Norint išvengti šablonų užteršimo pagrindiniu kodu, kelios pagalbinės klasės teikia bendrą elgesį formoms, datoms ir eilutėms. Taip pat lengva pridėti naujus pagalbinius įrankius prie jūsų programos, kai ji tobulėja.

PASTABA: Kai kurie Action View funkcionalumai yra susiję su Active Record, tačiau tai nereiškia, kad Action View priklauso nuo Active Record. Action View yra nepriklausomas paketas, kurį galima naudoti su bet kokiomis Ruby bibliotekomis.

Naudodami Action View su „Rails“
----------------------------

Kiekvienam valdikliui yra susijusi direktorija `app/views` direktorijoje, kurioje yra šablonų failai, sudarantys su tuo valdikliu susijusius rodinius. Šie failai naudojami rodiniui, kuris gaunamas iš kiekvieno valdiklio veiksmo, atvaizduoti.

Pažiūrėkime, ką „Rails“ pagal nutylėjimą daro, kai sukuriamas naujas išteklius naudojant šablonų generatorių:

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

„Rails“ yra vardų konvencija rodiniams. Paprastai rodiniai dalina savo pavadinimą su susijusiu valdiklio veiksmu, kaip matote aukščiau.
Pavyzdžiui, `articles_controller.rb` indekso valdiklio veiksmas naudos `index.html.erb` šablonų failą `app/views/articles` direktorijoje.
Visas HTML, grąžinamas klientui, sudaro šio ERB failo, jį apgaubiančio išdėstymo šablono ir visų dalinių, į kurias gali nuorodą rodinys, kombinacija. Šiame vadove rasite išsamesnę dokumentaciją apie šiuos tris komponentus.

Kaip minėta, galutinis HTML išvestis yra trijų „Rails“ elementų - šablonų, dalinių ir išdėstymų - kompozicija.
Žemiau pateikiama trumpa kiekvieno iš jų apžvalga.

Šablonai
---------

Action View šablonus galima rašyti keliais būdais. Jei šablonų failas turi `.erb` plėtinį, jis naudoja sumaištį iš ERB (įterpto Ruby) ir HTML. Jei šablonų failas turi `.builder` plėtinį, naudojama `Builder::XmlMarkup` biblioteka.

„Rails“ palaiko kelias šablonų sistemas ir naudoja failo plėtinį, kad jas atskirtų. Pavyzdžiui, HTML failas, naudojantis ERB šablonų sistemą, turės `.html.erb` kaip failo plėtinį.

### ERB

ERB šablone galima įtraukti Ruby kodą naudojant `<% %>` ir `<%= %>` žymes. `<% %>` žymės naudojamos vykdyti Ruby kodą, kuris nieko negrąžina, pvz., sąlygas, ciklus ar blokus, o `<%= %>` žymės naudojamos, kai norite gauti išvestį.

Pavyzdžiui, apsvarstykite šį ciklą vardams:

```html+erb
<h1>Visų žmonių vardai</h1>
<% @people.each do |person| %>
  Vardas: <%= person.name %><br>
<% end %>
```

Ciklas sukuriamas naudojant įprastas įterpimo žymes (`<% %>`) ir vardas įterpiamas naudojant išvesties įterpimo žymes (`<%= %>`). Atkreipkite dėmesį, kad tai ne tik naudojimo rekomendacija: įprastos išvesties funkcijos, pvz., `print` ir `puts`, nebus atvaizduojamos šablonui su ERB šablonais. Taigi tai būtų neteisinga:

```html+erb
<%# NETEISINGA %>
Sveiki, pone. <% puts "Frodo" %>
```

Norint slopinti pradines ir galines tarpines tarpas, galite naudoti `<%-` `-%>` kaip `<%` ir `%>`.

### Builder

Builder šablonai yra programiškai orientuotas variantas ERB. Jie ypač naudingi generuojant XML turinį. Šablonams su `.builder` plėtiniu automatiškai prieinamas XmlMarkup objektas, vardu `xml`.

Štai keletas pagrindinių pavyzdžių:

```ruby
xml.em("paryškintas")
xml.em { xml.b("paryškintas ir storas") }
xml.a("Nuoroda", "href" => "https://rubyonrails.org")
xml.target("name" => "kompiliuoti", "option" => "greitai")
```

kas sukurtų:

```html
<em>paryškintas</em>
<em><b>paryškintas ir storas</b></em>
<a href="https://rubyonrails.org">Nuoroda</a>
<target option="greitai" name="kompiliuoti" />
```

Bet kuri metodas su bloku bus laikomas XML žyma su įterptu žymėjimu bloke. Pavyzdžiui, šis:
```ruby
xml.div {
  xml.h1(@person.name)
  xml.p(@person.bio)
}
```

sukurtų kažką panašaus į:

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>A product of Danish Design during the Winter of '79...</p>
</div>
```

Žemiau yra pilnas RSS pavyzdys, kuris buvo naudojamas Basecamp:

```ruby
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@feed_title)
    xml.link(@url)
    xml.description "Basecamp: Naujausi elementai"
    xml.language "en-us"
    xml.ttl "40"

    for item in @recent_items
      xml.item do
        xml.title(item_title(item))
        xml.description(item_description(item)) if item_description(item)
        xml.pubDate(item_pubDate(item))
        xml.guid(@person.firm.account.url + @recent_items.url(item))
        xml.link(@person.firm.account.url + @recent_items.url(item))
        xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
      end
    end
  end
end
```

### Jbuilder

[Jbuilder](https://github.com/rails/jbuilder) yra "gem", kurį palaiko Rails komanda ir jis yra įtrauktas į numatytąjį Rails `Gemfile`. Jis panašus į Builder, bet naudojamas generuoti JSON, o ne XML.

Jei neturite jo, galite pridėti šį kodą į savo `Gemfile`:

```ruby
gem 'jbuilder'
```

Jbuilder objektas, pavadinimu `json`, automatiškai tampa prieinamas šablonams su `.jbuilder` plėtiniu.

Štai pagrindinis pavyzdys:

```ruby
json.name("Alex")
json.email("alex@example.com")
```

sukurtų:

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

Daugiau pavyzdžių ir informacijos rasite [Jbuilder dokumentacijoje](https://github.com/rails/jbuilder#jbuilder).

### Šablonų kešavimas

Pagal numatymą, Rails kompiliuos kiekvieną šabloną į metodą, kad jį galėtų atvaizduoti. Vystymo aplinkoje, kai keičiate šabloną, Rails patikrins failo modifikavimo laiką ir jį iš naujo sukompiliuos.

Dalys
--------

Dalinius šablonus - paprastai vadinamus "dalimis" - galima naudoti, norint padalinti atvaizdavimo procesą į lengviau valdomas dalis. Su dalimis galite išskirti kodo gabalus iš savo šablonų į atskirus failus ir juos perpanaudoti visuose šablonuose.

### Dalinių šablonų atvaizdavimas

Norėdami atvaizduoti dalinį kaip dalį šablono, naudokite `render` metodą šablone:

```erb
<%= render "menu" %>
```

Tai atvaizduos failą, pavadinimu `_menu.html.erb`, šablono vietoje, kuris yra atvaizduojamas. Pastebėkite priešakyje esantį pabraukimo ženklą: daliniai yra pavadinti su priešakyje esančiu pabraukimo ženklu, kad juos būtų galima atskirti nuo įprastų šablonų, nors jie yra paminėti be pabraukimo ženklo. Tai taip pat galioja net tuomet, kai dalį ištraukiate iš kitos aplanko:

```erb
<%= render "shared/menu" %>
```

Tas kodas įtrauks dalinį iš `app/views/shared/_menu.html.erb`.

### Daliniais supaprastinami šablonai

Vienas būdas naudoti dalis yra traktuoti jas kaip subrutinas; tai būdas iškelti detales iš šablono, kad galėtumėte lengviau suprasti, kas vyksta. Pavyzdžiui, galite turėti šabloną, kuris atrodo taip:

```html+erb
<%= render "shared/ad_banner" %>

<h1>Produktai</h1>

<p>Čia yra keletas mūsų puikių produktų:</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "shared/footer" %>
```

Čia `_ad_banner.html.erb` ir `_footer.html.erb` daliniai gali turėti turinį, kuris bendrinamas daugelyje jūsų aplikacijos puslapių. Jums nereikia matyti šių skyrių detalių, kai sutelkiate dėmesį į konkretų puslapį.

### `render` be `partial` ir `locals` parametrų

Pirmiau pateiktame pavyzdyje `render` priima 2 parametrus: `partial` ir `locals`. Bet jei norite perduoti tik šiuos parametrus, galite nejuo naudotis. Pavyzdžiui, vietoj:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

Galite naudoti:

```erb
<%= render "product", product: @product %>
```

### `as` ir `object` parametrai

Pagal numatymą, `ActionView::Partials::PartialRenderer` turi savo objektą vietiniame kintamajame, turinčiame tą patį pavadinimą kaip šablonas. Taigi, turint:

```erb
<%= render partial: "product" %>
```

daliniame `_product` mes gausime `@product` vietiniame kintamajame `product`, tarsi būtume parašę:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

`object` parametrą galima naudoti, norint tiesiogiai nurodyti, kuris objektas yra atvaizduojamas dalinyje; tai naudinga, kai šablono objektas yra kitur (pvz., skirtingame objekto kintamajame arba vietiniame kintamajame).

Pavyzdžiui, vietoj:

```erb
<%= render partial: "product", locals: { product: @item } %>
```

darytume:

```erb
<%= render partial: "product", object: @item %>
```

Naudojant `as` parametrą, galime nurodyti kitą pavadinimą šiam vietiniam kintamajam. Pavyzdžiui, jei norėtume, kad jis būtų `item`, o ne `product`, darytume:

```erb
<%= render partial: "product", object: @item, as: "item" %>
```

Tai yra ekvivalentu
```erb
<%= render partial: "product", locals: { item: @item } %>
```

### Rodomi kolekcijos

Dažnai šablonui reikės iteruoti per kolekciją ir atvaizduoti sub-šabloną kiekvienam elementui. Šis modelis yra įgyvendintas kaip vienas metodas, kuris priima masyvą ir atvaizduoja dalinį šabloną kiekvienam masyvo elementui.

Taigi, šis pavyzdys, skirtas visiems produktams atvaizduoti:

```erb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

gali būti parašytas vienoje eilutėje:

```erb
<%= render partial: "product", collection: @products %>
```

Kai dalinis yra iškviečiamas su kolekcija, atskiriems dalinio atvejams prieiga prie atvaizduojamos kolekcijos nario suteikiama per kintamąjį, kurio pavadinimas yra dalinio pavadinimas. Šiuo atveju dalinis yra `_product`, o jame galite naudoti `product`, kad gautumėte atvaizduojamą kolekcijos narį.

Galite naudoti trumpą sintaksę, skirtą kolekcijų atvaizdavimui. Tarkime, kad `@products` yra `Product` objektų kolekcija, galite tiesiog parašyti šį kodą, kad gautumėte tą patį rezultatą:

```erb
<%= render @products %>
```

Rails nustato dalinio pavadinimą, žiūrėdamas modelio pavadinimą kolekcijoje, šiuo atveju `Product`. Iš tikrųjų, netgi galite atvaizduoti kolekciją, sudarytą iš skirtingų modelių objektų, naudodami šią trumpą sintaksę, ir Rails pasirinks tinkamą dalinį kiekvienam kolekcijos nariui.

### Tarpiklio šablonai

Taip pat galite nurodyti antrą dalinį, kuris bus atvaizduojamas tarp pagrindinių dalinių, naudodami `:spacer_template` parinktį:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails atvaizduos `_product_ruler` dalinį (be perduodamų duomenų) tarp kiekvienos `_product` dalinės poros.

### Griežtos vietinės reikšmės

Pagal numatytuosius nustatymus šablonai priims bet kokias vietines reikšmes kaip raktinius argumentus. Norėdami apibrėžti, kokias vietines reikšmes šablonas priima, pridėkite `locals` magišką komentarą:

```erb
<%# locals: (message:) -%>
<%= message %>
```

Numatytosios reikšmės taip pat gali būti pateiktos:

```erb
<%# locals: (message: "Hello, world!") -%>
<%= message %>
```

Arba vietinės reikšmės gali būti visiškai išjungtos:

```erb
<%# locals: () %>
```

Maketai
-------

Maketos gali būti naudojamos atvaizduoti bendrą vaizdo šabloną aplink Rails kontrolerio veiksmų rezultatus. Paprastai Rails aplikacijoje bus keletas maketų, kuriuose bus atvaizduojamos puslapiai. Pavyzdžiui, svetainėje gali būti vienas maketas prisijungusiems vartotojams ir kitas rinkodaros ar pardavimų svetainės puslapiams. Prisijungusių vartotojų maketas gali apimti viršutinį lygio naršymą, kuris turėtų būti matomas daugelyje kontrolerio veiksmų. SaaS aplikacijos pardavimų maketas gali apimti viršutinį lygio naršymą, skirtą dalykams, tokiam kaip "Kainos" ir "Susisiekite su mumis" puslapiai. Kiekvienam maketui tikėtumėte turėti skirtingą išvaizdą ir jausmą. Daugiau informacijos apie maketus galite rasti [Maketų ir atvaizdavimo Rails](layouts_and_rendering.html) vadove.

### Dalinių maketai

Daliniai gali turėti savo maketus. Šie maketai skiriasi nuo tų, kurie taikomi kontrolerio veiksmui, tačiau jie veikia panašiu būdu.

Tarkime, kad rodome straipsnį puslapyje, kuris turėtų būti apgaubtas `div` tikslais. Pirmiausia sukursime naują `Article`:

```ruby
Article.create(body: 'Daliniai maketai yra šaunūs!')
```

`show` šablone atvaizduosime `_article` dalinį, apgaubtą `box` maketu:

**articles/show.html.erb**

```erb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

`box` maketas tiesiog apgaubia `_article` dalinį `div`:

**articles/_box.html.erb**

```html+erb
<div class='box'>
  <%= yield %>
</div>
```

Atkreipkite dėmesį, kad dalinio maketas turi prieigą prie vietinio `article` kintamojo, kuris buvo perduotas `render` iškvietime. Tačiau, skirtingai nuo visoje aplikacijoje naudojamų maketų, dalinių maketai vis dar turi priešdėlį `_`.

Taip pat galite atvaizduoti kodo bloką dalinio makete, vietoj to, kad būtų iškviesta `yield`. Pavyzdžiui, jei neturėtume `_article` dalinio, galėtume tai padaryti:

**articles/show.html.erb**

```html+erb
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

Tarkime, kad naudojame tą patį `_box` dalinį, kaip ir ankstesniame pavyzdyje, tai gautume tą patį rezultatą. 

Vaizdo keliai
----------

Atvaizduojant atsaką, kontroleris turi nustatyti, kur yra skirtingi vaizdai. Pagal numatytuosius nustatymus jis žiūri tik į `app/views` katalogą.
Mes galime pridėti kitas vietas ir suteikti jiems tam tikrą pirmenybę, kai išsprendžiame kelius naudodami `prepend_view_path` ir `append_view_path` metodus.

### Pridėti peržiūros kelią

Tai gali būti naudinga, pavyzdžiui, kai norime įdėti peržiūras į kitą aplanką subdomenams.

Tai galime padaryti naudodami:

```ruby
prepend_view_path "app/views/#{request.subdomain}"
```

Tada Action View pirmiausia ieškos šiame aplanke, kai išsprendžia peržiūras.

### Pridėti peržiūros kelią

Panašiai, galime pridėti kelius:

```ruby
append_view_path "app/views/direct"
```

Tai pridės `app/views/direct` į paieškos kelio pabaigą.

Pagalbinės funkcijos
-------

Rails teikia daug pagalbinių metodų, skirtų naudoti su Action View. Tai apima metodus, skirtus:

* Datos, eilučių ir skaičių formatavimui
* Kūrimui HTML nuorodas į paveikslėlius, vaizdo įrašus, stilių lapus ir kt.
* Turinio dezinfekavimui
* Formų kūrimui
* Turinio lokalizavimui

Daugiau apie pagalbinius metodus galite sužinoti [Action View Helpers
Gidą](action_view_helpers.html) ir [Action View Form Helpers
Gidą](form_helpers.html).

Lokalizuotos peržiūros
---------------

Action View gali atvaizduoti skirtingus šablonus priklausomai nuo dabartinės lokalės.

Pavyzdžiui, tarkime, turite `ArticlesController` su rodyti veiksmu. Pagal numatytuosius nustatymus, šio veiksmo iškvietimas atvaizduos `app/views/articles/show.html.erb`. Bet jei nustatysite `I18n.locale = :de`, tada bus atvaizduotas `app/views/articles/show.de.html.erb`. Jei lokalizuotas šablonas nėra, bus naudojamas neapipavidalintas versijos. Tai reiškia, kad nereikia pateikti lokalizuotų peržiūrų visais atvejais, bet jos bus pirmenybės ir naudojamos, jei yra.

Galite naudoti tą patį metodą, kad lokalizuotumėte gelbėjimo failus savo viešajame aplanke. Pavyzdžiui, nustatant `I18n.locale = :de` ir sukūrus `public/500.de.html` ir `public/404.de.html`, galėsite turėti lokalizuotus gelbėjimo puslapius.

Kadangi „Rails“ neapriboja simbolių, kuriuos naudojate nustatydami I18n.locale, galite pasinaudoti šia sistema, kad rodytumėte skirtingą turinį, priklausomai nuo bet ko, kas jums patinka. Pavyzdžiui, tarkime, turite kai kuriuos „ekspertus“, kurie turėtų matyti skirtingus puslapius nei „normalūs“ vartotojai. Galėtumėte pridėti šį kodą į `app/controllers/application_controller.rb`:

```ruby
before_action :set_expert_locale

def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
```

Tada galėtumėte sukurti specialias peržiūras, pvz., `app/views/articles/show.expert.html.erb`, kurios būtų rodomos tik ekspertams.

Daugiau apie „Rails“ tarptautinės lokalizacijos (I18n) API galite skaityti [čia](i18n.html).
