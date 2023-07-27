**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 975163c53746728404fb3a3658fbd0f6
Veiksmo peržiūros formos pagalbininkai
========================

Formos interneto programose yra būtinas sąsajos elementas, skirtas naudotojo įvestims. Tačiau formos žymėjimas gali greitai tapti nuobodus rašyti ir palaikyti dėl poreikio tvarkyti formos valdymo pavadinimus ir jų daugybę atributų. "Rails" pašalina šią sudėtingumą, teikdamas peržiūros pagalbininkus, skirtus generuoti formos žymėjimą. Tačiau, kadangi šie pagalbininkai turi skirtingus naudojimo atvejus, programuotojai turi žinoti skirtumus tarp pagalbinių metodų, prieš juos naudojant.

Po šio vadovo perskaitymo jūs žinosite:

* Kaip sukurti paieškos formas ir panašias bendros paskirties formas, kurios nereprezentuoja jokio konkretaus modelio jūsų aplikacijoje.
* Kaip sukurti modelio centrinės formos, skirtos kurti ir redaguoti konkretaus duomenų bazės įrašus.
* Kaip generuoti pasirinkimo laukus iš įvairių duomenų tipų.
* Kokius datos ir laiko pagalbininkus teikia "Rails".
* Kas skiria failo įkėlimo formą.
* Kaip siųsti formas į išorinius išteklius ir nurodyti nustatymą "authenticity_token".
* Kaip kurti sudėtingas formas.

--------------------------------------------------------------------------------

PASTABA: Šis vadovas nėra skirtas visiems galimiems formos pagalbininkams ir jų argumentams išsamiai aprašyti. Visų galimų pagalbinių priemonių išsamiam aprašymui apsilankykite [Rails API dokumentacijoje](https://api.rubyonrails.org/classes/ActionView/Helpers.html).

Darbas su pagrindinėmis formomis
------------------------

Pagrindinė formos pagalbininkė yra [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with).

```erb
<%= form_with do |form| %>
  Formos turinys
<% end %>
```

Kai jis yra iškviestas be argumentų, kaip šiuo atveju, jis sukuria formos žymą, kurią pateikus ji bus išsiųsta į dabartinį puslapį. Pavyzdžiui, jei dabartinis puslapis yra pagrindinis puslapis, sugeneruotas HTML atrodo taip:

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  Formos turinys
</form>
```

Pastebėsite, kad HTML yra `input` elementas su tipo `hidden`. Šis `input` yra svarbus, nes ne-GET formos negali būti sėkmingai išsiųstos be jo.
Paslėptas įvesties elementas su pavadinimu `authenticity_token` yra "Rails" saugumo funkcija, vadinama **cross-site request forgery protection** (apsaugą nuo kryžminio svetainių užklausų sukčiavimo), ir formos pagalbininkai jį generuoja kiekvienai ne-GET formai (jei ši saugumo funkcija yra įjungta). Apie tai galite sužinoti daugiau [Saugių "Rails" aplikacijų](security.html#cross-site-request-forgery-csrf) vadove.

### Bendrosios paieškos forma

Viena iš paprasčiausių internete matomų formų yra paieškos forma. Ši forma apima:

* formos elementą su "GET" metodu,
* etiketę įvesties laukui,
* teksto įvesties elementą ir
* pateikimo elementą.

Norėdami sukurti šią formą, naudosime `form_with` ir formos kūrėjo objektą, kurį jis grąžina. Taip:

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Ieškoti:" %>
  <%= form.text_field :query %>
  <%= form.submit "Ieškoti" %>
<% end %>
```

Tai sugeneruos šį HTML:

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Ieškoti:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Ieškoti" data-disable-with="Ieškoti" />
</form>
```

PATARIMAS: Pervadindami `url: mano_nurodytas_kelias` į `form_with` pasakote formai, kur išsiųsti užklausą. Tačiau, kaip paaiškinama žemiau, formai taip pat galite perduoti "Active Record" objektus.

PATARIMAS: Kiekvienai formos įvesties reikšmei yra sugeneruojamas ID atributas iš jos pavadinimo (`"query"` pavyzdžiuose aukščiau). Šie ID gali būti labai naudingi CSS stiliui ar formos valdiklių manipuliavimui su JavaScript.

SVARBU: Paieškos formoms naudokite "GET" kaip metodą. Tai leidžia naudotojams įrašyti konkretų paieškos rezultatą ir grįžti prie jo. Iš esmės "Rails" skatina naudoti tinkamą HTTP veiksmo veiksmą.

### Pagalbininkai formos elementams generuoti

`form_with` grąžinamas formos kūrėjo objektas teikia daugybę pagalbinių metodų, skirtų generuoti formos elementus, tokius kaip teksto laukai, žymimieji langeliai ir radijo mygtukai. Pirmasis parametras šiems metodams visada yra įvesties pavadinimas. Kai forma yra pateikiama, pavadinimas bus perduotas kartu su forma duomenimis ir pasieks `params` kontroleryje su naudotojo įvesta reikšme šiam laukui. Pavyzdžiui, jei formoje yra `<%= form.text_field :query %>`, tuomet galėsite gauti šio lauko reikšmę kontroleryje su `params[:query]`.
Kai pavadinate įvestis, „Rails“ naudoja tam tikras konvencijas, kurios leidžia pateikti parametrus su ne skalinių reikšmių, pvz., masyvų arba žodynų, kurie taip pat bus pasiekiami „params“. Apie juos galite sužinoti daugiau [Suprantant parametrų pavadinimo konvencijas](#suprantant-parametrų-pavadinimo-konvencijas) šio vadovo skyriuje. Išsamesnė informacija apie šių pagalbininkų tikslų naudojimą pateikta [API dokumentacijoje](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).

#### Žymimieji langeliai

Žymimieji langeliai yra formos valdikliai, kurie leidžia vartotojui pasirinkti arba išjungti rinkinį parinkčių:

```erb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "Aš turiu šunį" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "Aš turiu katę" %>
```

Tai generuoja šį rezultatą:

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">Aš turiu šunį</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">Aš turiu katę</label>
```

Pirmasis parametras [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) yra įvesties pavadinimas. Žymimųjų langelių reikšmės (reikšmės, kurios bus prieinamos „params“) gali būti nurodytos naudojant trečiąjį ir ketvirtąjį parametrus. Išsamesnę informaciją rasite API dokumentacijoje.

#### Radijo mygtukai

Radijo mygtukai, nors ir panašūs į žymimuosius langelius, yra valdikliai, kurie nurodo rinkinį parinkčių, kurios yra tarpusavyje išskiriamos (t. y. vartotojas gali pasirinkti tik vieną):

```erb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "Aš esu jaunesnis nei 21" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "Aš esu vyresnis nei 21" %>
```

Rezultatas:

```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">Aš esu jaunesnis nei 21</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">Aš esu vyresnis nei 21</label>
```

Antrasis parametras [`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) yra įvesties reikšmė. Kadangi šie du radijo mygtukai bendrai naudoja tą patį pavadinimą (`age`), vartotojas galės pasirinkti tik vieną iš jų, o `params[:age]` bus `"child"` arba `"adult"`.

PASTABA: Visada naudokite žymes žymimiesiems langeliams ir radijo mygtukams. Jos sieja tekstą su konkretesne parinktimi ir, išplečiant paspaudimo sritį, palengvina vartotojams paspausti įvestis.

### Kiti naudingi pagalbininkai

Kiti verti paminėjimo formos valdikliai yra teksto srities, paslėptosios srities, slaptažodžio srities, skaičiaus srities, datos ir laiko srities ir daugelis kitų:

```erb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```

Rezultatas:

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```

Paslėptosios srities įvestys nėra rodomos vartotojui, bet vietoj to laiko duomenis kaip bet kuri tekstinė įvestis. Juose esančios reikšmės gali būti keičiamos naudojant „JavaScript“.

Svarbu: Paieškos, telefono, datos, laiko, spalvos, datos ir laiko, mėnesio, savaitės, URL, el. pašto, skaičiaus ir intervalo įvestys yra HTML5 valdikliai. Jei norite, kad jūsų programa turėtų nuoseklią patirtį senesniuose naršyklėse, jums reikės HTML5 polifilo (teikiamo CSS ir/arba JavaScript). Tikrai [nėra trūkumo sprendimų šiai problemai spręsti](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills), nors šiuo metu populiarus įrankis yra [Modernizr](https://modernizr.com/), kuris suteikia paprastą būdą pridėti funkcionalumą pagal aptiktas HTML5 funkcijas.
Patarimas: Jei naudojate slaptažodžio įvedimo laukus (bet kokiu tikslu), galbūt norėsite sukonfigūruoti savo programą, kad šie parametrai nebūtų įrašomi į žurnalą. Apie tai galite sužinoti [Securing Rails Applications](security.html#logging) vadove.

Dirbant su modelio objektais
--------------------------

### Formos susiejimas su objektu

`form_with` metodo `:model` argumentas leidžia susieti formos kūrėjo objektą su modelio objektu. Tai reiškia, kad forma bus apribota šiuo modelio objektu, o formos laukai bus užpildyti reikšmėmis iš šio modelio objekto.

Pavyzdžiui, jei turime `@article` modelio objektą:

```ruby
@article = Article.find(42)
# => #<Article id: 42, title: "My Title", body: "My Body">
```

Tokia forma:

```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

Generuos:

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="My Title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    My Body
  </textarea>
  <input type="submit" name="commit" value="Update Article" data-disable-with="Update Article">
</form>
```

Čia yra keletas dalykų, kuriuos reikia pastebėti:

* Formos `action` automatiškai užpildoma tinkama `@article` reikšme.
* Formos laukai automatiškai užpildomi atitinkamomis reikšmėmis iš `@article`.
* Formos laukų pavadinimai apriboti su `article[...]`. Tai reiškia, kad `params[:article]` bus maišas, kuriame bus visų šių laukų reikšmės. Daugiau apie įvesties pavadinimų svarbą galite paskaityti šio vadovo [Understanding Parameter Naming Conventions](#understanding-parameter-naming-conventions) skyriuje.
* Pateikimo mygtukui automatiškai priskiriama tinkama teksto reikšmė.

Patarimas: Paprastai jūsų įvestys atitiks modelio atributus. Tačiau tai nėra būtina! Jei turite kitos informacijos, kurią reikia, galite ją įtraukti į formą, kaip ir atributus, ir pasiekti ją per `params[:article][:my_nifty_non_attribute_input]`.

#### `fields_for` pagalbininkas

[`fields_for`][] pagalbininkas sukuria panašų susiejimą, bet be `<form>` žymės generavimo. Tai gali būti naudojama generuoti laukus papildomiems modelio objektams toje pačioje formoje. Pavyzdžiui, jei turite `Person` modelį su susijusiu `ContactDetail` modeliu, galite sukurti vieną formą abiem taip:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

Tai generuos šį rezultatą:

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

`fields_for` grąžinamas objektas yra formos kūrėjas, panašus į `form_with` grąžinamą objektą.


### Remiantis įrašo identifikacija

Straipsnio modelis yra tiesiogiai prieinamas programos naudotojams, todėl, vadovaujantis geriausiomis Rails kūrimo praktikomis, jį turėtumėte paskelbti **resursu**:

```ruby
resources :articles
```

Patarimas: Resurso paskelbimas turi keletą šalutinių pasekmių. Daugiau informacijos apie resursų nustatymą ir naudojimą galite rasti [Rails Routing from the Outside In](routing.html#resource-routing-the-rails-default) vadove.

Dirbant su RESTful resursais, naudojant **įrašo identifikaciją**, `form_with` kvietimai gali būti žymiai paprastesni. Trumpai tariant, galite tiesiog perduoti modelio egzempliorių ir leisti Rails nustatyti modelio pavadinimą ir kitus parametrus. Šiuose dviejuose pavyzdžiuose ilgas ir trumpas stilius turi tą patį rezultatą:

```ruby
## Naujo straipsnio kūrimas
# ilgas stilius:
form_with(model: @article, url: articles_path)
# trumpas stilius:
form_with(model: @article)

## Esamo straipsnio redagavimas
# ilgas stilius:
form_with(model: @article, url: article_path(@article), method: "patch")
# trumpas stilius:
form_with(model: @article)
```

Pastebėkite, kaip trumpojo stiliaus `form_with` kvietimas yra patogus ir tas pats, nepriklausomai nuo to, ar įrašas yra naujas, ar jau egzistuoja. Įrašo identifikacija pakankamai protinga, kad nustatytų, ar įrašas yra naujas, klausdamas `record.persisted?`. Ji taip pat pasirenka teisingą maršrutą pateikimui ir pavadinimą pagal objekto klasę.
Jei turite [vienintelį išteklių](routing.html#singular-resources), jums reikės paskambinti `resource` ir `resolve`, kad jis veiktų su `form_with`:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

ĮSPĖJIMAS: Kai naudojate STI (vienintelės lentelės paveldėjimą) su savo modeliais, negalite pasikliauti įrašo identifikacija po klasės, jei tik jų tėvų klasė yra deklaruota kaip išteklius. Turėsite nurodyti `:url` ir `:scope` (modelio pavadinimą) aiškiai.

#### Susidūrimas su vardų erdvėmis

Jei sukūrėte vardų erdvės maršrutus, `form_with` taip pat turi patogų trumpinį. Jei jūsų programoje yra administratoriaus vardų erdvė, tada

```ruby
form_with model: [:admin, @article]
```

sukurs formą, kurią pateikia `ArticlesController` viduje admin vardų erdvės (pateikiant `admin_article_path(@article)` atnaujinimo atveju). Jei turite kelias vardų erdves, sintaksė yra panaši:

```ruby
form_with model: [:admin, :management, @article]
```

Daugiau informacijos apie „Rails“ maršrutizavimo sistemą ir susijusias konvencijas rasite [„Rails Routing from the Outside In“](routing.html) vadove.

### Kaip veikia formos su PATCH, PUT arba DELETE metodais?

„Rails“ karkasas skatina jūsų programų RESTful projektavimą, tai reiškia, kad be „GET“ ir „POST“ užklausų, daugiausia naudosite „PATCH“, „PUT“ ir „DELETE“ užklausas. Tačiau dauguma naršyklių _nepalaiko_ kitų nei „GET“ ir „POST“ metodų naudojimo formų pateikimo.

„Rails“ šią problemą sprendžia imituodamas kitus metodus per POST su paslėptu įvesties lauku, kurio pavadinimas yra `"_method"`, kuris nustatomas atitinkamai:

```ruby
form_with(url: search_path, method: "patch")
```

Išvestis:

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->
</form>
```

Analizuojant pateiktus duomenis, „Rails“ atsižvelgs į specialųjį `_method` parametrą ir elgsis taip, tarsi HTTP metodas būtų tas, kuris nurodytas jame (šiuo pavyzdžiu - „PATCH“).

Rodydami formą, pateikimo mygtukai gali perrašyti nurodytą `method` atributą naudojant `formmethod:` raktažodį:

```erb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Delete", formmethod: :delete, data: { confirm: "Are you sure?" } %>
  <%= form.button "Update" %>
<% end %>
```

Panašiai kaip `<form>` elementai, dauguma naršyklių _nepalaiko_ formos metodų perrašymo, nurodytų per [formmethod][] kitais nei „GET“ ir „POST“ metodais.

„Rails“ šią problemą sprendžia imituodamas kitus metodus per POST, naudodamas [formmethod][], [value][button-value] ir [name][button-name] atributų kombinaciją:

```html
<form accept-charset="UTF-8" action="/posts/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->

  <button type="submit" formmethod="post" name="_method" value="delete" data-confirm="Are you sure?">Delete</button>
  <button type="submit" name="button">Update</button>
</form>
```


Lengvai kuriamos pasirinkimo laukai
-----------------------------

HTML pasirinkimo laukams reikalingas didelis žymėjimas - vienas `<option>` elementas kiekvienai galimybei pasirinkti. Todėl „Rails“ teikia pagalbines funkcijas, kurios sumažina šį naštą.

Pavyzdžiui, sakykime, turime sąrašą miestų, iš kurio vartotojas gali pasirinkti. Galime naudoti [`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select) pagalbininką taip:

```erb
<%= form.select :city, ["Berlin", "Chicago", "Madrid"] %>
```

Išvestis:

```html
<select name="city" id="city">
  <option value="Berlin">Berlin</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```

Taip pat galime nurodyti `<option>` reikšmes, kurios skiriasi nuo jų žymėjimo:

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
```

Išvestis:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

Taip vartotojas matys pilną miesto pavadinimą, bet `params[:city]` bus viena iš `"BE"`, `"CHI"` arba `"MD"`.

Galiausiai galime nurodyti numatytąjį pasirinkimą pasirinkimo laukui naudodami `:selected` argumentą:

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]], selected: "CHI" %>
```

Išvestis:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

### Pasirinkimo grupės

Kai kuriais atvejais norime pagerinti vartotojo patirtį, grupuodami susijusias galimybes. Tai galime padaryti perduodami `Hash` (arba palyginamą `Array`) į `select`:
```erb
<%= form.select :city,
      {
        "Europa" => [ ["Berlynas", "BE"], ["Madridas", "MD"] ],
        "Šiaurės Amerika" => [ ["Čikaga", "CHI"] ],
      },
      selected: "CHI" %>
```

Rezultatas:

```html
<select name="city" id="city">
  <optgroup label="Europa">
    <option value="BE">Berlynas</option>
    <option value="MD">Madridas</option>
  </optgroup>
  <optgroup label="Šiaurės Amerika">
    <option value="CHI" selected="selected">Čikaga</option>
  </optgroup>
</select>
```

### Pasirinkimo laukai ir modelio objektai

Kaip ir kiti formos valdikliai, pasirinkimo lauką galima susieti su modelio atributu. Pavyzdžiui, jei turime `@person` modelio objektą:

```ruby
@person = Person.new(city: "MD")
```

Ši forma:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["Berlynas", "BE"], ["Čikaga", "CHI"], ["Madridas", "MD"]] %>
<% end %>
```

Išveda pasirinkimo lauką:

```html
<select name="person[city]" id="person_city">
  <option value="BE">Berlynas</option>
  <option value="CHI">Čikaga</option>
  <option value="MD" selected="selected">Madridas</option>
</select>
```

Pastebėkite, kad tinkama parinktis automatiškai pažymėta `selected="selected"`. Kadangi šis pasirinkimo laukas buvo susietas su modeliu, nereikėjo nurodyti `:selected` argumento!

### Laiko juosta ir šalies pasirinkimas

Norint pasinaudoti laiko juostos palaikymu „Rails“, reikia paklausti vartotojų, kuriame laiko juostoje jie yra. Tai reikalauja sugeneruoti pasirinkimo galimybes iš iš anksto apibrėžtų [`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html) objektų sąrašo, tačiau galite tiesiog naudoti [`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select) pagalbininką, kuris tai jau apgaubia:

```erb
<%= form.time_zone_select :time_zone %>
```

„Rails“ _anksčiau_ turėjo `country_select` pagalbininką, skirtą šalių pasirinkimui, tačiau jis buvo išskirtas į [country_select įskiepį](https://github.com/stefanpenner/country_select).

Naudojant datos ir laiko formos pagalbinius elementus
--------------------------------

Jei nenorite naudoti HTML5 datos ir laiko įvesties, „Rails“ teikia alternatyvius datos ir laiko formos pagalbinius elementus, kurie atvaizduoja paprastus pasirinkimo laukus. Šie pagalbiniai elementai atvaizduoja pasirinkimo lauką kiekvienam laiko komponentui (pvz., metai, mėnuo, diena ir kt.). Pavyzdžiui, jei turime `@person` modelio objektą:

```ruby
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

Ši forma:

```erb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

Išveda pasirinkimo laukus:

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">Sausis</option>
  <option value="2">Vasaris</option>
  <option value="3">Kovas</option>
  <option value="4">Balandis</option>
  <option value="5">Gegužė</option>
  <option value="6">Birželis</option>
  <option value="7">Liepa</option>
  <option value="8">Rugpjūtis</option>
  <option value="9">Rugsėjis</option>
  <option value="10">Spalis</option>
  <option value="11">Lapkritis</option>
  <option value="12" selected="selected">Gruodis</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1</option>
  ...
  <option value="21" selected="selected">21</option>
  ...
  <option value="31">31</option>
</select>
```

Pastebėkite, kad pateikiant formą, `params` maiše nebus vieno vertės, kurią sudarytų visas datos laukas. Vietoj to, bus keletas vertės su specialiais pavadinimais, pvz., `"birth_date(1i)"`. „Active Record“ žino, kaip sudėti šiuos specialiai pavadintus laukus į visą datą ar laiką, remiantis modelio atributo deklaruota tipu. Taigi galime perduoti `params[:person]` į `Person.new` arba `Person#update`, kaip ir darytume, jei forma naudotų vieną lauką, kuris atstovautų visai datai.

Be [`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select) pagalbininko, „Rails“ teikia [`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select) ir [`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select).

### Pasirinkimo laukai atskiriems laiko komponentams

„Rails“ taip pat teikia pagalbinius elementus, skirtus atskiriems laiko komponentams atvaizduoti: [`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year), [`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month), [`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day), [`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour), [`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute) ir [`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second). Šie pagalbiniai elementai yra „nuogi“ metodai, tai reiškia, kad jie nėra iškviesti ant formos kūrėjo objekto. Pavyzdžiui:

```erb
<%= select_year 1999, prefix: "party" %>
```

Išveda pasirinkimo lauką:

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

Kiekvienam iš šių pagalbinių elementų galite nurodyti datą ar laiko objektą kaip numatytąją vertę, o tinkamas laiko komponentas bus išskirtas ir naudojamas. 

Pasirinkimas iš bet kokių objektų kolekcijos
----------------------------------------------
Kartais norime sugeneruoti pasirinkimų rinkinį iš bet kokių objektų kolekcijos. Pavyzdžiui, jei turime `City` modelį ir atitinkamą `belongs_to :city` asociaciją:

```ruby
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```

```ruby
City.order(:name).map { |city| [city.name, city.id] }
# => [["Berlinas", 3], ["Čikaga", 1], ["Madridas", 2]]
```

Tada galime leisti vartotojui pasirinkti miestą iš duomenų bazės naudojant šią formą:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

PASTABA: Atvaizduojant lauką `belongs_to` asociacijai, turite nurodyti užsienio rakto pavadinimą (`city_id` pavyzdyje aukščiau), o ne paties asociacijos pavadinimą.

Tačiau „Rails“ teikia pagalbinius metodus, kurie generuoja pasirinkimus iš kolekcijos, nereikalaujant išreiškiamai ją iteruoti. Šie pagalbiniai metodai nustato kiekvieno objekto kolekcijoje vertę ir teksto žymėjimą, iškviesdami nurodytus metodus.

### `collection_select` pagalbinis metodas

Norėdami sugeneruoti pasirinkimo langelį, galime naudoti [`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select):

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

Išvestis:

```html
<select name="person[city_id]" id="person_city_id">
  <option value="3">Berlinas</option>
  <option value="1">Čikaga</option>
  <option value="2">Madridas</option>
</select>
```

PASTABA: Naudojant `collection_select`, pirmiausia nurodome vertės metodą (`:id` pavyzdyje aukščiau), o antra - teksto žymėjimo metodą (`:name` pavyzdyje aukščiau). Tai priešinga tvarka nei nurodomi pasirinkimai naudojant `select` pagalbinį metodą, kur teksto žymėjimas eina pirmas, o vertė - antras.

### `collection_radio_buttons` pagalbinis metodas

Norėdami sugeneruoti rinkinį radijo mygtukų, galime naudoti [`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons):

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

Išvestis:

```html
<input type="radio" name="person[city_id]" value="3" id="person_city_id_3">
<label for="person_city_id_3">Berlinas</label>

<input type="radio" name="person[city_id]" value="1" id="person_city_id_1">
<label for="person_city_id_1">Čikaga</label>

<input type="radio" name="person[city_id]" value="2" id="person_city_id_2">
<label for="person_city_id_2">Madridas</label>
```

### `collection_check_boxes` pagalbinis metodas

Norėdami sugeneruoti žymėjimo langelius - pavyzdžiui, palaikyti `has_and_belongs_to_many` asociaciją - galime naudoti [`collection_check_boxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes):

```erb
<%= form.collection_check_boxes :interest_ids, Interest.order(:name), :id, :name %>
```

Išvestis:

```html
<input type="checkbox" name="person[interest_id][]" value="3" id="person_interest_id_3">
<label for="person_interest_id_3">Inžinerija</label>

<input type="checkbox" name="person[interest_id][]" value="4" id="person_interest_id_4">
<label for="person_interest_id_4">Matematika</label>

<input type="checkbox" name="person[interest_id][]" value="1" id="person_interest_id_1">
<label for="person_interest_id_1">Mokslas</label>

<input type="checkbox" name="person[interest_id][]" value="2" id="person_interest_id_2">
<label for="person_interest_id_2">Technologija</label>
```

Failų įkėlimas
---------------

Daugelis užduočių apima failo įkėlimą, ar tai būtų asmenio nuotrauka ar CSV failas, kuriame yra duomenų, skirtų apdoroti. Failo įkėlimo laukai gali būti atvaizduojami naudojant [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) pagalbinį metodą.

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

Svarbiausia atsiminti, kad sugeneruotos formos `enctype` atributas **turi** būti nustatytas kaip "multipart/form-data". Tai automatiškai atliekama naudojant `file_field` viduje `form_with`. Taip pat galite nustatyti atributą rankiniu būdu:

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :picture %>
<% end %>
```

Atkreipkite dėmesį, kad, vadovaujantis `form_with` konvencijomis, laukų pavadinimai šiuose dviejuose formose taip pat skirsis. Tai reiškia, kad pirmos formos lauko pavadinimas bus `person[picture]` (pasiekiamas per `params[:person][:picture]`), o antros formos lauko pavadinimas bus tiesiog `picture` (pasiekiamas per `params[:picture]`).

### Kas yra įkelta

Objektas `params` maiše yra [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html) pavyzdys. Šis fragmentas įrašo įkeltą failą `#{Rails.root}/public/uploads` aplanko po to pačiu pavadinimu kaip ir originalus failas.

```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

Kai failas yra įkeltas, yra daugybė potencialių užduočių, pradedant nuo to, kur saugoti failus (diske, „Amazon S3“ ir kt.), susiejant juos su modeliais, keičiant paveikslėlių failų dydį ir generuojant miniatiūras ir kt. [Active Storage](active_storage_overview.html) skirtas padėti šioms užduotims.
Formų kūrimo adaptavimas
-------------------------

`form_with` ir `fields_for` grąžinamas objektas yra [`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html) klasės objektas. Formų kūrėjai apibrėžia formos elementų atvaizdavimo logiką vienam objektui. Nors galite rašyti pagalbines funkcijas formoms kaip įprasta, taip pat galite sukurti `ActionView::Helpers::FormBuilder` klasės paveldėjimą ir ten pridėti pagalbines funkcijas. Pavyzdžiui,

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

gali būti pakeistas į

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

apibrėžiant `LabellingFormBuilder` klasę panašiai kaip ši:

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    label(attribute) + super
  end
end
```

Jei dažnai naudojate šį kodą, galite apibrėžti `labeled_form_with` pagalbinę funkciją, kuri automatiškai pritaikys `builder: LabellingFormBuilder` parinktį:

```ruby
def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
  options[:builder] = LabellingFormBuilder
  form_with model: model, scope: scope, url: url, format: format, **options, &block
end
```

Formų kūrėjas taip pat nusprendžia, kas vyksta, kai rašote:

```erb
<%= render partial: f %>
```

Jei `f` yra `ActionView::Helpers::FormBuilder` klasės objektas, tai atvaizduos `form` dalinį, nustatant dalinio objektą kaip formos kūrėją. Jei formos kūrėjas yra `LabellingFormBuilder` klasės objektas, tai bus atvaizduojamas `labelling_form` dalinis.

Parametrų pavadinimų konvencijų supratimas
------------------------------------------

Formų reikšmės gali būti tiesiogiai `params` hash'o viršuje arba gali būti įdėtos į kitą hash'ą. Pavyzdžiui, standartinėje `create` veiksmo funkcijoje, skirtai `Person` modeliui, `params[:person]` paprastai yra hash'as, kuriame yra visi žmogaus sukūrimui skirti atributai. `params` hash'as taip pat gali turėti masyvus, masyvus iš hash'ų ir t.t.

Pagrindinėje HTML formos struktūroje nėra jokios struktūruotos informacijos, viskas, ką jos generuoja, yra pavadinimo-reikšmės poros, kur poros yra paprastos eilutės. Masyvai ir hash'ai, kuriuos matote savo programoje, yra rezultatas tam tikrų parametrų pavadinimų konvencijų, kurias naudoja Rails.

### Pagrindinės struktūros

Dvi pagrindinės struktūros yra masyvai ir hash'ai. Hash'ai atitinka sintaksę, naudojamą prieigai prie `params` hash'o reikšmių. Pavyzdžiui, jei forma yra:

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

`params` hash'e bus

```ruby
{ 'person' => { 'name' => 'Henry' } }
```

ir `params[:person][:name]` gaus pateiktą reikšmę valdiklyje.

Hash'ai gali būti bet kokiu lygiu įdėti vienas į kitą, pavyzdžiui:

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

sukurs `params` hash'ą

```ruby
{ 'person' => { 'address' => { 'city' => 'New York' } } }
```

Įprastai Rails ignoruoja pasikartojančius parametrų pavadinimus. Jei parametrų pavadinimas baigiasi tuščiu laužtinių skliaustų rinkiniu `[]`, jie bus kaupiami masyve. Jei norite, kad vartotojai galėtų įvesti kelis telefono numerius, galite į formą įdėti šį kodą:

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

Tai sukurs `params[:person][:phone_number]` masyvą, kuriame bus įvesti telefono numeriai.

### Jų derinimas

Galime derinti šiuos du konceptus. Vienas hash'o elementas gali būti masyvas, kaip ir ankstesniame pavyzdyje, arba galite turėti masyvą iš hash'ų. Pavyzdžiui, forma gali leisti jums sukurti bet kokį adresų skaičių, kartojant šį formos fragmentą

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

Tai sukurs `params[:person][:addresses]` masyvą iš hash'ų su raktiniais žodžiais `line1`, `line2` ir `city`.

Tačiau yra apribojimas: nors hash'us galima bet kokiu lygiu įdėti vieną į kitą, leidžiama tik viena "masyvų lygio" lygi. Masyvus paprastai galima pakeisti hash'ais; pavyzdžiui, vietoj modelio objektų masyvo galima turėti modelio objektų hash'ą, kurio raktai yra jų id, masyvo indeksas arba kitas parametras.
ĮSPĖJIMAS: Masyvo parametrai nesiderina su `check_box` pagalbininku. Pagal HTML specifikaciją, nepažymėti žymimieji langeliai neišsiunčia jokios reikšmės. Tačiau dažnai patogu, kad žymimasis langelis visada išsiųstų reikšmę. `check_box` pagalbininkas tai imituoja, sukurdamas pagalbinį paslėptą įvesties lauką su tuo pačiu pavadinimu. Jei žymimasis langelis nepažymėtas, siunčiamas tik paslėptas įvesties laukas, o jei pažymėtas, siunčiami abu, tačiau žymimojo langelio siunčiama reikšmė turi pirmenybę.

### `fields_for` pagalbininko `:index` parinktis

Tarkime, norime atvaizduoti formą su kiekvieno asmens adreso laukų rinkiniu. [`fields_for`][] pagalbininkas su savo `:index` parinktimi gali padėti:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

Priimant, kad asmuo turi dvi adresus su ID 23 ir 45, aukščiau pateikta forma panašiai atvaizduotų rezultatą:

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

Tai sukels `params` maišos objektą, kuris atrodo taip:

```ruby
{
  "person" => {
    "name" => "Bob",
    "address" => {
      "23" => {
        "city" => "Paris"
      },
      "45" => {
        "city" => "London"
      }
    }
  }
}
```

Visi formos įvesties laukai susiejami su `"person"` maišos objektu, nes mes iškvietėme `fields_for` su `person_form` formos kūrėju. Taip pat, nurodydami `index: address.id`, mes atvaizdavome kiekvieno miesto įvesties lauko `name` atributą kaip `person[address][#{address.id}][city]`, o ne `person[address][city]`. Taip mes galime nustatyti, kurie Adreso įrašai turėtų būti modifikuoti apdorojant `params` maišą.

Galite perduoti kitus svarbius skaičius ar eilutes per `:index` parinktį. Netgi galite perduoti `nil`, kuris sukurs masyvo parametrą.

Norėdami sukurti sudėtingesnius įdėjimus, galite aiškiai nurodyti įvesties lauko pavadinimo pradžią. Pavyzdžiui:

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

sukurs įvesties laukus kaip:

```html
<input id="person_address_primary_23_city" name="person[address][primary][23][city]" type="text" value="Paris" />
```

Taip pat galite perduoti `:index` parinktį tiesiogiai pagalbininkams, tokiems kaip `text_field`, bet paprastai mažiau kartojama nurodyti tai formos kūrėjo lygyje nei atskiruose įvesties laukuose.

Bendrai kalbant, galutinis įvesties lauko pavadinimas bus `fields_for` / `form_with` suteikto pavadinimo, `:index` parinkties reikšmės ir atributo pavadinimo sujungimas.

Galų gale, kaip sutrumpinimą, vietoj `:index` nurodymo ID (pvz., `index: address.id`), galite pridėti `"[]"` prie pateikto pavadinimo. Pavyzdžiui:

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

sukuria visiškai tą patį rezultatą kaip ir mūsų pradinis pavyzdys.

Formos į išorinius išteklius
---------------------------

Rails formos pagalbininkai taip pat gali būti naudojami formos kūrimui, skirtam duomenims siųsti į išorinį išteklių. Tačiau kartais gali būti būtina nustatyti `authenticity_token` ištekliui; tai galima padaryti perduodant `authenticity_token: 'your_external_token'` parametrą `form_with` parinktims:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  Formos turinys
<% end %>
```

Kartais siunčiant duomenis į išorinį išteklių, pvz., mokėjimo šliuzą, formoje galima naudoti tik tam tikrus laukus, kurie yra apriboti išorinio API. Tokiu atveju gali būti nepageidautina generuoti `authenticity_token`. Norėdami nesiųsti žetono, tiesiog perduokite `false` `:authenticity_token` parinkčiai:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  Formos turinys
<% end %>
```
Kompleksinių formų kūrimas
----------------------

Daugelis programų išauga iš paprastų formų, kurios redaguoja vieną objektą. Pavyzdžiui, kuriant `Person` (asmenį), galite norėti leisti vartotojui (tame pačiame forme) sukurti kelis adresų įrašus (namas, darbas ir kt.). Vėliau redaguojant tą asmenį, vartotojas turėtų galėti pridėti, pašalinti arba pakeisti adresus pagal poreikį.

### Modelio konfigūravimas

Active Record teikia modelio lygio palaikymą naudojant [`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for) metodą:

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses
end

class Address < ApplicationRecord
  belongs_to :person
end
```

Tai sukuria `addresses_attributes=` metodą `Person` modelyje, kuris leidžia jums kurti, atnaujinti ir (neprivalomai) naikinti adresus.

### Įdėti formą

Ši forma leidžia vartotojui sukurti `Person` ir susijusius adresus.

```html+erb
<%= form_with model: @person do |form| %>
  Adresai:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```


Kai asociacija priima įdėtas atributus, `fields_for` atvaizduoja savo bloką kiekvienam asociacijos elementui. Ypač, jei asmuo neturi adresų, nieko neatvaizduoja. Dažnas modelio kūrėjo modelis yra sukurti vieną ar daugiau tuščių vaikų, kad vartotojui būtų rodomas bent vienas laukų rinkinys. Pavyzdys žemiau rezultatuose rodo 2 adresų laukų rinkinius naujo asmens formoje.

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```

`fields_for` grąžina formos kūrėją. Parametrų pavadinimas bus tai, ko `accepts_nested_attributes_for` tikisi. Pavyzdžiui, kuriant vartotoją su 2 adresais, pateikti parametrai atrodytų taip:

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

Raktažodžių reikšmės `:addresses_attributes` raktų yra nesvarbios; tačiau jos turi būti sveikųjų skaičių eilutės ir skirtingos kiekvienam adresui.

Jei susijęs objektas jau yra išsaugotas, `fields_for` automatiškai sugeneruoja paslėptą įvestį su išsaugoto įrašo `id`. Tai galima išjungti, perduodant `include_id: false` į `fields_for`.

### Valdiklis

Kaip įprasta, jums reikia
[paskelbti leidžiamus parametrus](action_controller_overview.html#strong-parameters) valdiklyje,
prieš juos perduodant modeliui:

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### Objektų šalinimas

Galite leisti vartotojams ištrinti susijusius objektus, perduodami `allow_destroy: true` į `accepts_nested_attributes_for`

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

Jei objekto atributų maišas turi raktą `_destroy` su reikšme, kuri vertinama kaip `true` (pvz., 1, '1', true arba 'true'), tada objektas bus sunaikintas.
Ši forma leidžia vartotojams pašalinti adresus:

```erb
<%= form_with model: @person do |form| %>
  Adresai:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

Nepamirškite atnaujinti leidžiamų parametrų valdiklyje, kad būtų įtrauktas
laukas `_destroy`:

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### Tuščių įrašų prevencija

Daugeliu atvejų naudinga ignoruoti laukų rinkinius, kuriuos vartotojas neįvedė. Tai galima valdyti, perduodant `:reject_if` funkciją į `accepts_nested_attributes_for`. Ši funkcija bus iškviesta su kiekvienu atributų maišu, pateiktu formos. Jei funkcija grąžina `true`, tada Active Record nekuria susijusio objekto tam maišui. Pavyzdys žemiau bandys sukurti adresą tik tada, kai nustatytas `kind` atributas.
```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda { |attributes| attributes['kind'].blank? }
end
```

Norint patogumo vietoj to galite perduoti simbolį `:all_blank`, kuris sukurs proc, kuris atmetys įrašus, kuriuose visi atributai yra tušti, išskyrus bet kokį `_destroy` reikšmę.

### Laukų pridėjimas dinamiškai

Vietoje to, kad iš anksto atvaizduotumėte kelis laukų rinkinius, galite norėti pridėti juos tik tada, kai vartotojas paspaudžia mygtuką "Pridėti naują adresą". "Rails" šiam tikslui nepateikia jokios įdiegto palaikymo. Generuodami naujus laukų rinkinius, turite užtikrinti, kad susijusio masyvo raktas būtų unikalus - dabartinė JavaScript datos reikšmė (milisekundės nuo [epochos](https://en.wikipedia.org/wiki/Unix_time)) yra paplitęs pasirinkimas.

Naudodami žymos pagalbininkus be formos kūrėjo
--------------------------------------------

Jei norite atvaizduoti formos laukus ne formos kūrėjo kontekste, "Rails" teikia žymos pagalbininkus bendriems formos elementams. Pavyzdžiui, [`check_box_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-check_box_tag):

```erb
<%= check_box_tag "accept" %>
```

Išvestis:

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

Bendrai, šie pagalbininkai turi tą patį pavadinimą kaip ir jų formos kūrėjo atitikmenys, tik su `_tag` priesaga. Visą sąrašą rasite [`FormTagHelper` API dokumentacijoje](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).

Naudodami `form_tag` ir `form_for`
----------------------------------

Prieš pristatant `form_with` "Rails" 5.1 versijoje, jo funkcionalumas buvo padalintas tarp [`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag) ir [`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for). Abi funkcijos dabar yra švelniai pasenusios. Dokumentacija apie jų naudojimą gali būti rasta [šio vadovo senesnėse versijose](https://guides.rubyonrails.org/v5.2/form_helpers.html).
[`fields_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for
[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-formmethod
[button-name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-name
[button-value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-value
