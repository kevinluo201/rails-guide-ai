**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fb66c6f4aafffdb8f8d44e8a2076c9b0
Rails maršrutizavimas iš išorės į vidų
=======================================

Šiame vadove aptariamos vartotojui matomos funkcijos, susijusios su Rails maršrutizavimu.

Po šio vadovo perskaitymo žinosite:

* Kaip interpretuoti kodą `config/routes.rb`.
* Kaip sukurti savo maršrutus, naudojant pageidaujamą resursų stilių arba `match` metodą.
* Kaip nurodyti maršruto parametrus, kurie perduodami kontrolerio veiksmams.
* Kaip automatiškai kurti kelius ir URL naudojant maršruto pagalbininkus.
* Pažengusias technikas, tokius kaip apribojimų kūrimas ir Rack taškų montavimas.

--------------------------------------------------------------------------------

Rails maršrutizatoriaus paskirtis
---------------------------------

Rails maršrutizatorius atpažįsta URL ir nukreipia juos į kontrolerio veiksmą arba į Rack aplikaciją. Jis taip pat gali generuoti kelius ir URL, taip išvengiant būtinybės įkoduoti eilutes į savo rodiniuose.

### Sujungimas tarp URL ir kodo

Kai jūsų Rails aplikacija gauna įeinantį užklausos adresu:

```
GET /patients/17
```

ji prašo maršrutizatoriaus susieti jį su kontrolerio veiksmu. Jei pirmasis atitinkantis maršrutas yra:

```ruby
get '/patients/:id', to: 'patients#show'
```

užklausa nukreipiama į `patients` kontrolerio `show` veiksmą su `{ id: '17' }` `params`.

PASTABA: Čia Rails naudoja snake_case kontrolerio pavadinimams, jei turite kontrolerį su keliais žodžiais, pvz., `MonsterTrucksController`, norėsite naudoti `monster_trucks#show`, pavyzdžiui.

### Kelio ir URL generavimas iš kodo

Taip pat galite generuoti kelius ir URL. Jei maršrutas aukščiau modifikuojamas taip:

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

ir jūsų aplikacijoje yra šis kodas kontroleryje:

```ruby
@patient = Patient.find(params[:id])
```

ir šis atitinkamas rodinyje:

```erb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

tada maršrutizatorius sugeneruos kelią `/patients/17`. Tai sumažina jūsų rodinio trapumą ir padaro kodą lengviau suprantamą. Reikia pažymėti, kad maršruto pagalbininkui nereikia nurodyti id.

### Rails maršrutizatoriaus konfigūravimas

Jūsų aplikacijos arba variklio maršrutai yra saugomi faile `config/routes.rb` ir paprastai atrodo taip:

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

Kadangi tai yra įprastas Ruby šaltinio failas, galite naudoti visas jo funkcijas, kad padėtumėte apibrėžti savo maršrutus, tačiau atsargiai su kintamųjų pavadinimais, nes jie gali susidurti su maršrutizatoriaus DSL metodais.

PASTABA: `Rails.application.routes.draw do ... end` blokas, kuris apgaubia jūsų maršruto apibrėžimus, yra būtinas, kad nustatytų maršrutizatoriaus DSL apimtį ir jo negalima ištrinti.

Resursų maršrutizavimas: Rails numatytasis
-------------------------------------------

Resursų maršrutizavimas leidžia greitai nurodyti visus bendrus maršrutus tam tikram resursui. Vienas [`resources`][] kvietimas gali nurodyti visus būtinus maršrutus jūsų `index`, `show`, `new`, `edit`, `create`, `update` ir `destroy` veiksmams.


### Resursai internete

Naršyklės prašo puslapių iš Rails, pateikdamos užklausą URL adresu, naudodamos tam tikrą HTTP metodą, pvz., `GET`, `POST`, `PATCH`, `PUT` ir `DELETE`. Kiekvienas metodas yra užklausa atlikti veiksmą su resursu. Resurso maršrutas susieja kelis susijusius užklausas su veiksmais viename kontroleryje.

Kai jūsų Rails aplikacija gauna įeinantį užklausos adresu:

```
DELETE /photos/17
```

ji prašo maršrutizatoriaus susieti jį su kontrolerio veiksmu. Jei pirmasis atitinkantis maršrutas yra:

```ruby
resources :photos
```

Rails nukreiptų tą užklausą į `photos` kontrolerio `destroy` veiksmą su `{ id: '17' }` `params`.

CRUD, veiksmai ir veiksmai

Rails, resursinis maršrutas suteikia atitikimą tarp HTTP veiksmų ir URL adresų bei kontrolerio veiksmų. Pagal konvenciją, kiekvienas veiksmas taip pat atitinka konkretų CRUD operaciją duomenų bazėje. Vienas įrašas maršruto faile, pvz.,:

```ruby
resources :photos
```

sukuria septynis skirtingus maršrutus jūsų aplikacijoje, visi susieti su `Photos` kontroleriu:

| HTTP veiksmas | Kelias            | Kontrolerio#Veiksmas | Naudojamas tam, kad                            |
| ------------- | ----------------- | -------------------- | ----------------------------------------------- |
| GET           | /photos           | photos#index         | rodyti visų nuotraukų sąrašą                    |
| GET           | /photos/new       | photos#new           | grąžinti HTML formą naujos nuotraukos kūrimui   |
| POST          | /photos           | photos#create        | sukurti naują nuotrauką                          |
| GET           | /photos/:id       | photos#show          | rodyti konkretią nuotrauką                       |
| GET           | /photos/:id/edit  | photos#edit          | grąžinti HTML formą nuotraukos redagavimui      |
| PATCH/PUT     | /photos/:id       | photos#update        | atnaujinti konkretią nuotrauką                   |
| DELETE        | /photos/:id       | photos#destroy       | ištrinti konkretią nuotrauką                     |
PASTABA: Kadangi maršrutizatorius naudoja HTTP veiksmą ir URL, kad atitiktų įeinančius užklausas, keturi URL'ai atitinka septynis skirtingus veiksmus.

PASTABA: „Rails“ maršrutai yra atitinkami pagal nurodytą tvarką, todėl jei turite „resources :photos“ virš „get 'photos/poll'“, „show“ veiksmo maršrutas „resources“ eilutėje bus atitinkamas prieš „get“ eilutę. Norėdami tai ištaisyti, perkėlkite „get“ eilutę **virš** „resources“ eilutės, kad ji būtų pirmiausia atitinkama.

### Kelio ir URL pagalbininkai

Kuriant išteklių maršrutą, taip pat bus prieinami keletas pagalbininkų jūsų programos kontroleriams. Jei naudojate „resources :photos“:

* `photos_path` grąžina `/photos`
* `new_photo_path` grąžina `/photos/new`
* `edit_photo_path(:id)` grąžina `/photos/:id/edit` (pvz., `edit_photo_path(10)` grąžina `/photos/10/edit`)
* `photo_path(:id)` grąžina `/photos/:id` (pvz., `photo_path(10)` grąžina `/photos/10`)

Kiekvienas iš šių pagalbininkų turi atitinkamą `_url` pagalbininką (pvz., `photos_url`), kuris grąžina tą patį kelią, papildytą esamu prievadu, portu ir kelio prievadu.

PATARIMAS: Norėdami rasti maršruto pagalbininkų pavadinimus savo maršrutams, žr. [Esamų maršrutų sąrašas](#listing-existing-routes) žemiau.

### Keliant kelis išteklius tuo pačiu metu

Jei norite sukurti maršrutus daugiau nei vienam ištekliui, galite sutaupyti šiek tiek rašymo, apibrėždami juos visus vienu metu, paskambinus `resources`:

```ruby
resources :photos, :books, :videos
```

Tai veikia taip pat kaip:

```ruby
resources :photos
resources :books
resources :videos
```

### Vienas išteklius

Kartais turite išteklių, kuriuos klientai visada ieško be nurodant ID. Pavyzdžiui, norite, kad `/profile` visada rodytų dabartinio prisijungusio naudotojo profilį. Šiuo atveju galite naudoti vienintelį išteklių, kad susietumėte `/profile` (o ne `/profile/:id`) su „show“ veiksmu:

```ruby
get 'profile', to: 'users#show'
```

Perduodant `String` į `to:`, tikimasi formato `controller#action`. Naudojant `Symbol`, `to:` parinktis turėtų būti pakeista į `action:`. Naudojant `String` be `#`, `to:` parinktis turėtų būti pakeista į `controller:`:

```ruby
get 'profile', action: :show, controller: 'users'
```

Šis išteklių maršrutas:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

sukuria šešis skirtingus maršrutus jūsų programoje, visi susieti su „Geocoders“ kontroleriu:

| HTTP veiksmas | Kelias              | Kontrolerio#Veiksmas | Naudojama                                      |
| ------------- | ------------------- | -------------------- | ---------------------------------------------- |
| GET           | /geocoder/new       | geocoders#new        | grąžinti HTML formą, skirtą geokoderio kūrimui |
| POST          | /geocoder           | geocoders#create     | sukurti naują geokoderį                        |
| GET           | /geocoder           | geocoders#show       | rodyti vienintelį geokoderio išteklius         |
| GET           | /geocoder/edit      | geocoders#edit       | grąžinti HTML formą, skirtą geokoderio redagavimui |
| PATCH/PUT     | /geocoder           | geocoders#update     | atnaujinti vienintelį geokoderio išteklius      |
| DELETE        | /geocoder           | geocoders#destroy    | ištrinti geokoderio išteklius                   |

PASTABA: Kadangi norėtumėte naudoti tą patį kontrolerį vieninteliam maršrutui (`/account`) ir daugiskaitos maršrutui (`/accounts/45`), vienintelio išteklio maršrutai susieja su daugiskaitos kontroleriais. Taigi, pavyzdžiui, `resource :photo` ir `resources :photos` sukuria tiek vienintelį, tiek daugiskaitos maršrutus, kurie susieja su tuo pačiu kontroleriu (`PhotosController`).

Vienintelio išteklio maršrutas generuoja šiuos pagalbininkus:

* `new_geocoder_path` grąžina `/geocoder/new`
* `edit_geocoder_path` grąžina `/geocoder/edit`
* `geocoder_path` grąžina `/geocoder`

PASTABA: Skambutis „resolve“ yra būtinas, norint konvertuoti „Geocoder“ pavyzdžius į maršrutus per [įrašo identifikavimą](form_helpers.html#relying-on-record-identification).

Kaip ir daugiskaitos ištekliais, tie patys pagalbininkai, baigiantys `_url`, taip pat įtraukia prievadą, portą ir kelio prievadą.

### Kontrolerio vardai ir maršrutizavimas

Galite norėti suskirstyti kontrolerius į tam tikrą vardų erdvę. Dažniausiai galite sugrupuoti keletą administravimo kontrolerių pagal „Admin::“ erdvę ir šiuos kontrolerius padėti „app/controllers/admin“ kataloge. Galite nukreipti į tokią grupę naudodami [`namespace`][] bloką:

```ruby
namespace :admin do
  resources :articles, :comments
end
```

Tai sukurs keletą maršrutų kiekvienam `articles` ir `comments` kontroleriui. „Admin::ArticlesController“ atveju „Rails“ sukurs:

| HTTP veiksmas | Kelias                          | Kontrolerio#Veiksmas      | Vardintas maršruto pagalbininkas |
| ------------- | ------------------------------- | ------------------------- | --------------------------------- |
| GET           | /admin/articles                 | admin/articles#index     | admin_articles_path              |
| GET           | /admin/articles/new             | admin/articles#new       | new_admin_article_path           |
| POST          | /admin/articles                 | admin/articles#create    | admin_articles_path              |
| GET           | /admin/articles/:id             | admin/articles#show      | admin_article_path(:id)          |
| GET           | /admin/articles/:id/edit        | admin/articles#edit      | edit_admin_article_path(:id)     |
| PATCH/PUT     | /admin/articles/:id             | admin/articles#update    | admin_article_path(:id)          |
| DELETE        | /admin/articles/:id             | admin/articles#destroy   | admin_article_path(:id)          |
Jei norite maršrutizuoti `/articles` (be prefikso `/admin`) į `Admin::ArticlesController`, galite nurodyti modulį naudodami [`scope`][] bloką:

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

Tai taip pat galima padaryti vienam maršrutui:

```ruby
resources :articles, module: 'admin'
```

Jei norite maršrutizuoti `/admin/articles` į `ArticlesController` (be `Admin::` modulio prefikso), galite nurodyti kelią naudodami `scope` bloką:

```ruby
scope '/admin' do
  resources :articles, :comments
end
```

Tai taip pat galima padaryti vienam maršrutui:

```ruby
resources :articles, path: '/admin/articles'
```

Abiem atvejais vardinti maršruto pagalbininkai lieka tokie patys, kaip jei nebūtumėte naudoję `scope`. Paskutiniu atveju šie keliai susieja su `ArticlesController`:

| HTTP veiksmas | Kelias                    | Valdiklis#Veiksmas   | Vardintas maršruto pagalbininkas |
| ------------- | ------------------------ | -------------------- | ---------------------- |
| GET           | /admin/articles          | articles#index       | articles_path          |
| GET           | /admin/articles/new      | articles#new         | new_article_path       |
| POST          | /admin/articles          | articles#create      | articles_path          |
| GET           | /admin/articles/:id      | articles#show        | article_path(:id)      |
| GET           | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id) |
| PATCH/PUT     | /admin/articles/:id      | articles#update      | article_path(:id)      |
| DELETE        | /admin/articles/:id      | articles#destroy     | article_path(:id)      |

PATARIMAS: Jei norite naudoti kitą valdiklio vardų erdvę `namespace` bloke, galite nurodyti absoliutų valdiklio kelią, pvz.: `get '/foo', to: '/foo#index'`.


### Įdėti resursai

Daugelis resursų logiškai yra kitų resursų vaikai. Pavyzdžiui, tarkime, jūsų programa apima šiuos modelius:

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

Įdėti maršrutai leidžia jums užfiksuoti šią sąsają maršrutavime. Šiuo atveju galėtumėte įtraukti šį maršruto deklaravimą:

```ruby
resources :magazines do
  resources :ads
end
```

Be maršrutų žurnalų, šis deklaravimas taip pat nukreips skelbimus į `AdsController`. Skelbimų URL reikalauja žurnalo:

| HTTP veiksmas | Kelias                                 | Valdiklis#Veiksmas | Naudojama                                                               |
| ------------- | -------------------------------------- | ----------------- | ----------------------------------------------------------------------- |
| GET           | /magazines/:magazine_id/ads             | ads#index         | rodyti visų skelbimų sąrašą tam tikram žurnalui                          |
| GET           | /magazines/:magazine_id/ads/new         | ads#new           | grąžinti HTML formą naujo skelbimo kūrimui, priklausančio tam tikram žurnalui |
| POST          | /magazines/:magazine_id/ads             | ads#create        | sukurti naują skelbimą, priklausančią tam tikram žurnalui                 |
| GET           | /magazines/:magazine_id/ads/:id         | ads#show          | rodyti konkretų skelbimą, priklausančią tam tikram žurnalui               |
| GET           | /magazines/:magazine_id/ads/:id/edit    | ads#edit          | grąžinti HTML formą skelbimo redagavimui, priklausančio tam tikram žurnalui |
| PATCH/PUT     | /magazines/:magazine_id/ads/:id         | ads#update        | atnaujinti konkretų skelbimą, priklausančią tam tikram žurnalui           |
| DELETE        | /magazines/:magazine_id/ads/:id         | ads#destroy       | ištrinti konkretų skelbimą, priklausančią tam tikram žurnalui             |

Tai taip pat sukurs maršruto pagalbinius įrankius, tokius kaip `magazine_ads_url` ir `edit_magazine_ad_path`. Šie pagalbininkai priima Magazine objektą kaip pirmąjį parametrą (`magazine_ads_url(@magazine)`).

#### Apribojimai dėl įdėjimo

Galite įdėti resursus į kitus įdėtus resursus, jei norite. Pavyzdžiui:

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

Giliai įdėti resursai greitai tampa nepatogūs. Šiuo atveju, pavyzdžiui, programa atpažintų kelius, tokius kaip:

```
/publishers/1/magazines/2/photos/3
```

Atitinkamasis maršruto pagalbininkas būtų `publisher_magazine_photo_url`, reikalaujantis nurodyti objektus visuose trijuose lygiuose. Iš tiesų, ši situacija yra pakankamai paini, kad [populiarus straipsnis, parašytas Jamis Buck](http://weblog.jamisbuck.org/2007/2/5/nesting-resources) siūlo taisyklę gero Rails dizaino atžvilgiu:

PATARIMAS: Resursai neturėtų būti įdėti daugiau nei 1 lygio gylį.

#### Paviršutiniškas įdėjimas

Vienas būdas išvengti gilaus įdėjimo (kaip rekomenduota aukščiau) yra generuoti kolekcijos veiksmus, apribotus pagal tėvą, kad gautumėte hierarchijos supratimą, bet nenestumėte narių veiksmų. Kitais žodžiais, tik sukurti maršrutus su minimalia informacija, reikalinga unikaliai identifikuoti resursą, pavyzdžiui:

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

Ši idėja sudaro pusiausvyrą tarp aprašomų maršrutų ir gilaus įdėjimo. Egzistuoja trumpesnė sintaksė, skirta pasiekti tik tai, naudojant `:shallow` parinktį:

```ruby
resources :articles do
  resources :comments, shallow: true
end
```
Tai sugeneruos tuos pačius maršrutus kaip ir pirmas pavyzdys. Taip pat galite nurodyti `:shallow` parinktį tėviniame resurse, kuriuo atveju visi įdėti resursai bus paviršutiniški:

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

Straipsnių resursas čia turės šiuos sugeneruotus maršrutus:

| HTTP veiksmas | Kelias                                        | Valdiklis#Veiksmas | Pavadinimo pagalbininkas |
| ------------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET           | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST          | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET           | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET           | /comments/:id/edit(.:format)                 | comments#edit     | edit_comment_path        |
| GET           | /comments/:id(.:format)                      | comments#show     | comment_path             |
| PATCH/PUT     | /comments/:id(.:format)                      | comments#update   | comment_path             |
| DELETE        | /comments/:id(.:format)                      | comments#destroy  | comment_path             |
| GET           | /articles/:article_id/quotes(.:format)       | quotes#index      | article_quotes_path      |
| POST          | /articles/:article_id/quotes(.:format)       | quotes#create     | article_quotes_path      |
| GET           | /articles/:article_id/quotes/new(.:format)   | quotes#new        | new_article_quote_path   |
| GET           | /quotes/:id/edit(.:format)                   | quotes#edit       | edit_quote_path          |
| GET           | /quotes/:id(.:format)                        | quotes#show       | quote_path               |
| PATCH/PUT     | /quotes/:id(.:format)                        | quotes#update     | quote_path               |
| DELETE        | /quotes/:id(.:format)                        | quotes#destroy    | quote_path               |
| GET           | /articles/:article_id/drafts(.:format)       | drafts#index      | article_drafts_path      |
| POST          | /articles/:article_id/drafts(.:format)       | drafts#create     | article_drafts_path      |
| GET           | /articles/:article_id/drafts/new(.:format)   | drafts#new        | new_article_draft_path   |
| GET           | /drafts/:id/edit(.:format)                   | drafts#edit       | edit_draft_path          |
| GET           | /drafts/:id(.:format)                        | drafts#show       | draft_path               |
| PATCH/PUT     | /drafts/:id(.:format)                        | drafts#update     | draft_path               |
| DELETE        | /drafts/:id(.:format)                        | drafts#destroy    | draft_path               |
| GET           | /articles(.:format)                          | articles#index    | articles_path            |
| POST          | /articles(.:format)                          | articles#create   | articles_path            |
| GET           | /articles/new(.:format)                      | articles#new      | new_article_path         |
| GET           | /articles/:id/edit(.:format)                 | articles#edit     | edit_article_path        |
| GET           | /articles/:id(.:format)                      | articles#show     | article_path             |
| PATCH/PUT     | /articles/:id(.:format)                      | articles#update   | article_path             |
| DELETE        | /articles/:id(.:format)                      | articles#destroy  | article_path             |

DSL [`shallow`][] metodas sukuria ribą, kurioje kiekvienas įdėjimas yra paviršutiniškas. Tai sugeneruoja tuos pačius maršrutus kaip ir ankstesnis pavyzdys:

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

Yra du `scope` variantai, skirti tinkinti paviršutiniškus maršrutus. `:shallow_path` priešdėlio nustatymas sukuria narių kelius su nurodytu parametru:

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

Komentarų resursui čia bus sugeneruoti šie maršrutai:

| HTTP veiksmas | Kelias                                        | Valdiklis#Veiksmas | Pavadinimo pagalbininkas |
| ------------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET           | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST          | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET           | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET           | /sekret/comments/:id/edit(.:format)          | comments#edit     | edit_comment_path        |
| GET           | /sekret/comments/:id(.:format)               | comments#show     | comment_path             |
| PATCH/PUT     | /sekret/comments/:id(.:format)               | comments#update   | comment_path             |
| DELETE        | /sekret/comments/:id(.:format)               | comments#destroy  | comment_path             |

`shallow_prefix` parinktis prideda nurodytą parametrą prie pavadinimo pagalbininkų:

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

Komentarų resursui čia bus sugeneruoti šie maršrutai:

| HTTP veiksmas | Kelias                                        | Valdiklis#Veiksmas | Pavadinimo pagalbininkas  |
| ------------- | -------------------------------------------- | ----------------- | --------------------------- |
| GET           | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path       |
| POST          | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path       |
| GET           | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path    |
| GET           | /comments/:id/edit(.:format)                 | comments#edit     | edit_sekret_comment_path    |
| GET           | /comments/:id(.:format)                      | comments#show     | sekret_comment_path         |
| PATCH/PUT     | /comments/:id(.:format)                      | comments#update   | sekret_comment_path         |
| DELETE        | /comments/:id(.:format)                      | comments#destroy  | sekret_comment_path         |


### Maršrutų susirūpinimai

Maršrutų susirūpinimai leidžia apibrėžti bendrus maršrutus, kurie gali būti perpanaudojami kituose resursuose ir maršrutuose. Norėdami apibrėžti susirūpinimą, naudokite [`concern`][] bloką:

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

Šie susirūpinimai gali būti naudojami resursuose, kad išvengtumėte kodo dubliavimo ir dalintumėtės elgesiu tarp maršrutų:

```ruby
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

Tai yra ekvivalentu:

```ruby
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```
Jūs taip pat galite naudoti juos bet kur, iškviesdami [`concerns`][]. Pavyzdžiui, `scope` ar `namespace` bloke:

```ruby
namespace :articles do
  concerns :commentable
end
```


### Kelio ir URL kūrimas iš objektų

Be maršrutų pagalbininkų naudojimo, „Rails“ taip pat gali sukurti kelius ir URL iš parametrų masyvo. Pavyzdžiui, jei turite šią maršrutų rinkinį:

```ruby
resources :magazines do
  resources :ads
end
```

Naudojant `magazine_ad_path`, galite perduoti `Magazine` ir `Ad` objektų pavyzdžius vietoje skaitinių ID:

```erb
<%= link_to 'Reklamos informacija', magazine_ad_path(@magazine, @ad) %>
```

Taip pat galite naudoti [`url_for`][ActionView::RoutingUrlFor#url_for] su objektų rinkiniu, ir „Rails“ automatiškai nustatys, kurį maršrutą norite:

```erb
<%= link_to 'Reklamos informacija', url_for([@magazine, @ad]) %>
```

Šiuo atveju „Rails“ pamatys, kad `@magazine` yra `Magazine` ir `@ad` yra `Ad`, todėl naudos `magazine_ad_path` pagalbininką. Pagalbininkuose, tokiose kaip `link_to`, vietoje viso `url_for` iškvietimo galite nurodyti tik objektą:

```erb
<%= link_to 'Reklamos informacija', [@magazine, @ad] %>
```

Jei norite susieti tik su žurnalu:

```erb
<%= link_to 'Žurnalo informacija', @magazine %>
```

Kitoms veiksmams tiesiog turite įterpti veiksmo pavadinimą kaip pirmą masyvo elementą:

```erb
<%= link_to 'Redaguoti reklamą', [:edit, @magazine, @ad] %>
```

Tai leidžia traktuoti modelių pavyzdžius kaip URL ir yra pagrindinis privalumas naudojant išteklių stilių.


### Papildomų RESTful veiksmų pridėjimas

Nesate apribotas tik septyniais numatytuoju būdu sukurtais RESTful maršrutais. Jei norite, galite pridėti papildomus maršrutus, kurie taikomi rinkinio nariams arba atskiriems rinkinio nariams.

#### Nario maršrutų pridėjimas

Norėdami pridėti nario maršrutą, tiesiog įtraukite [`member`][] bloką į išteklių bloką:

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

Tai leis atpažinti `/photos/1/preview` su GET ir nukreipti į `PhotosController` „preview“ veiksmą, perduodant išteklių ID reikšmę `params[:id]`. Tai taip pat sukurs `preview_photo_url` ir `preview_photo_path` pagalbinius metodus.

Nario maršrutų bloke kiekvieno maršruto pavadinimas nurodo HTTP veiksmą, kuris bus atpažintas. Čia galite naudoti [`get`][], [`patch`][], [`put`][], [`post`][] arba [`delete`][]. Jei neturite kelių `member` maršrutų, taip pat galite perduoti `:on` į maršrutą, pašalindami bloką:

```ruby
resources :photos do
  get 'preview', on: :member
end
```

Galite palikti `:on` parinktį, tai sukurs tą patį nario maršrutą, tik išteklių ID reikšmė bus prieinama `params[:photo_id]` vietoje `params[:id]`. Maršruto pagalbininkai taip pat bus pervadinti iš `preview_photo_url` ir `preview_photo_path` į `photo_preview_url` ir `photo_preview_path`.


#### Rinkinio maršrutų pridėjimas

Norėdami pridėti maršrutą į rinkinį, naudokite [`collection`][] bloką:

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

Tai leis „Rails“ atpažinti kelius, tokius kaip `/photos/search` su GET ir nukreipti į `PhotosController` „search“ veiksmą. Tai taip pat sukurs `search_photos_url` ir `search_photos_path` maršruto pagalbinius metodus.

Kaip ir su nario maršrutais, galite perduoti `:on` į maršrutą:

```ruby
resources :photos do
  get 'search', on: :collection
end
```

PASTABA: Jei apibrėžiate papildomus išteklių maršrutus su simboliu kaip pirmuoju poziciniu argumentu, būkite atsargūs, kad tai nėra lygiaverčiai naudojant eilutę. Simboliai nurodo valdiklio veiksmus, o eilutės nurodo kelius.


#### Maršrutų pridėjimas naujiems veiksmams

Norėdami pridėti alternatyvų naują veiksmą naudodami `:on` sutrumpinimą:

```ruby
resources :comments do
  get 'preview', on: :new
end
```

Tai leis „Rails“ atpažinti kelius, tokius kaip `/comments/new/preview` su GET ir nukreipti į `CommentsController` „preview“ veiksmą. Tai taip pat sukurs `preview_new_comment_url` ir `preview_new_comment_path` maršruto pagalbinius metodus.

PATARIMAS: Jei pastebite, kad pridedate daugybę papildomų veiksmų prie išteklių maršruto, laikas sustoti ir paklausti savęs, ar neslėpiate kito ištekliaus buvimo.

Nesąveikaujančių maršrutų
------------------------

Be išteklių maršrutų, „Rails“ taip pat turi galingą palaikymą maršrutams, kurie nukreipia bet kokius URL į veiksmus. Čia jūs negausite automatiškai sugeneruotų maršrutų grupių, kurias suteikia išteklių maršrutavimas. Vietoj to, kiekvieną maršrutą nustatote atskirai savo programoje.

Nors paprastai turėtumėte naudoti išteklių maršrutavimą, vis tiek yra daug vietų, kur paprastesnis maršrutavimas yra tinkamesnis. Nėra jokio poreikio bandyti priderinti kiekvieną jūsų programos gabalą prie išteklių pagrindo, jei tai nėra tinkama.
Ypač paprastas maršrutizavimas labai lengvai leidžia susieti senus URL su naujomis Rails veiksmų funkcijomis.

### Susieti parametrai

Nustatydami įprastą maršrutą, pateikiate simbolių seką, kuriuos Rails susieja su įeinančio HTTP užklausos dalimis. Pavyzdžiui, apsvarstykite šį maršrutą:

```ruby
get 'photos(/:id)', to: 'photos#display'
```

Jei šis maršrutas apdoroja įeinančią užklausą `/photos/1` (nes jis neatitiko jokio ankstesnio maršruto failo), rezultatas bus `PhotosController` veiksmo `display` iškvietimas ir galutinio parametro `"1"` prieinamumas kaip `params[:id]`. Šis maršrutas taip pat nukreips įeinančią užklausą `/photos` į `PhotosController#display`, nes `:id` yra pasirenkamas parametras, pažymėtas skliaustais.

### Dinaminiai segmentai

Įprastame maršrute galite nustatyti tiek dinaminių segmentų, kiek norite. Bet kuris segmentas bus prieinamas veiksmui kaip dalis `params`. Jei nustatysite šį maršrutą:

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

Įeinančiam keliui `/photos/1/2` bus išsiųsta `PhotosController` veiksmui `show`. `params[:id]` bus `"1"`, o `params[:user_id]` bus `"2"`.

PATARIMAS: Pagal nutylėjimą dinaminiai segmentai nepriima taškų - tai dėl to, kad taškas naudojamas formatuotų maršrutų atskyrimui. Jei norite naudoti tašką dinaminiame segmente, pridėkite apribojimą, kuris pakeis tai - pavyzdžiui, `id: /[^\/]+/` leidžia bet ką, išskyrus pasvirąją brūkšnį.

### Statiški segmentai

Kuriant maršrutą, galite nurodyti statinius segmentus, neprikreipdami dvitaškio prie segmento:

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

Šis maršrutas atsakytų į kelius, tokius kaip `/photos/1/with_user/2`. Šiuo atveju `params` būtų `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### Užklausos eilutė

`params` taip pat bus įtraukti visi parametrai iš užklausos eilutės. Pavyzdžiui, su šiuo maršrutu:

```ruby
get 'photos/:id', to: 'photos#show'
```

Įeinančiam keliui `/photos/1?user_id=2` bus išsiųsta `Photos` kontrolerio `show` veiksmui. `params` bus `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### Numatytieji nustatymai

Maršrute galite nustatyti numatytuosius nustatymus, pateikdami `:defaults` parinktį kaip hash'ą. Tai taip pat taikoma parametrams, kuriuos nenustatote kaip dinaminius segmentus. Pavyzdžiui:

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails atitiktų `photos/12` `PhotosController` `show` veiksmą ir nustatytų `params[:format]` kaip `"jpg"`.

Taip pat galite naudoti [`defaults`][] bloką, kad apibrėžtumėte numatytuosius nustatymus keliems elementams:

```ruby
defaults format: :json do
  resources :photos
end
```

PASTABA: Negalite perrašyti numatytųjų nustatymų per užklausos parametrus - tai saugumo sumetimais. Galima perrašyti tik dinaminius segmentus pakeičiant URL kelio dalį.

### Maršrutų pavadinimai

Galite nurodyti pavadinimą bet kuriam maršrutui naudodami `:as` parinktį:

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

Tai sukurs `logout_path` ir `logout_url` kaip pavadinimų maršrutų pagalbininkus jūsų aplikacijoje. Iškvietus `logout_path`, bus grąžintas `/exit`

Taip pat galite tai naudoti, kad perrašytumėte resursų apibrėžtus maršrutų metodus, įdėdami pasirinktinius maršrutus prieš apibrėžiant resursą, panašiai kaip šis:

```ruby
get ':username', to: 'users#show', as: :user
resources :users
```

Tai apibrėš `user_path` metodą, kuris bus prieinamas kontroleriuose, pagalbininkuose ir rodiniuose, ir kuris nueis į maršrutą, pvz., `/bob`. `UsersController` `show` veiksmo viduje `params[:username]` bus vartotojo vardas. Jei nenorite, kad jūsų parametras būtų `:username`, pakeiskite `:username` maršruto apibrėžime.

### HTTP veiksmo apribojimai

Bendrai, turėtumėte naudoti [`get`][], [`post`][], [`put`][], [`patch`][] ir [`delete`][] metodus, kad apribotumėte maršrutą iki tam tikro veiksmo. Galite naudoti [`match`][] metodą su `:via` parinktimi, kad sutaptų su keliais veiksmais vienu metu:

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

Galite sutapti visus veiksmus su tam tikru maršrutu naudodami `via: :all`:

```ruby
match 'photos', to: 'photos#show', via: :all
```

PASTABA: Tiek `GET`, tiek `POST` užklausas nukreipti į vieną veiksmą turi saugumo padarinių. Bendrai, turėtumėte vengti visų veiksmų nukreipimo į veiksmą, nebent turite geros priežasties.

PASTABA: Rails `GET` nebus tikrinamas dėl CSRF žetono. Niekada neturėtumėte rašyti į duomenų bazę iš `GET` užklausų, daugiau informacijos rasite [saugumo vadove](security.html#csrf-countermeasures) apie CSRF priemonės.
### Segmentų apribojimai

Galite naudoti `:constraints` parinktį, kad nustatytumėte dinaminio segmento formatą:

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

Šis maršrutas atitiktų takus, tokius kaip `/photos/A12345`, bet ne `/photos/893`. Galite trumpiau išreikšti tą patį maršrutą taip:

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` priima reguliariuosius išraiškas su apribojimu, kad negalima naudoti reguliariųjų išraiškų pradžios ir pabaigos ženklų. Pavyzdžiui, šis maršrutas neveiks:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

Tačiau atkreipkite dėmesį, kad jums nereikia naudoti ženklų, nes visi maršrutai yra pririšti pradžioje ir pabaigoje.

Pavyzdžiui, šie maršrutai leistų `articles` su `to_param` reikšmėmis, pvz., `1-hello-world`, kurios visada prasideda skaičiumi, ir `users` su `to_param` reikšmėmis, pvz., `david`, kurios niekada neprasideda skaičiumi, dalintis šaknies vardų erdve:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### Užklausos pagrindu apribojimai

Taip pat galite apriboti maršrutą pagal bet kurį [Užklausos objekto](action_controller_overview.html#the-request-object) metodą, kuris grąžina `String` tipo reikšmę.

Užklausos pagrindu apribojimą nurodote taip pat, kaip nurodytumėte segmento apribojimą:

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

Taip pat galite nurodyti apribojimus naudodami [`constraints`][] bloką:

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

PASTABA: Užklausos apribojimai veikia iškviečiant metodo pavadinimą, kuris yra tas pats kaip ir raktas maiše, ir tada lyginant grąžinimo reikšmę su maišo reikšme. Todėl apribojimo reikšmės turėtų atitikti atitinkamo Užklausos objekto metodo grąžinimo tipą. Pavyzdžiui: `constraints: { subdomain: 'api' }` atitiks `api` subdomeną, kaip ir tikėtasi. Tačiau naudojant simbolį `constraints: { subdomain: :api }` neveiks, nes `request.subdomain` grąžina `'api'` kaip `String`.

PASTABA: Yra išimtis `format` apribojimui: nors tai yra metodo Užklausos objekte, tai taip pat yra neprivalomas nevardiniame kiekviename taku. Segmento apribojimai turi pirmenybę, o `format` apribojimas taikomas tik tada, kai jis yra priverstinis per maišą. Pavyzdžiui, `get 'foo', constraints: { format: 'json' }` atitiks `GET  /foo`, nes pagal numatytuosius nustatymus formatas yra neprivalomas. Tačiau galite [naudoti lambda](#advanced-constraints), kaip `get 'foo', constraints: lambda { |req| req.format == :json }`, ir maršrutas atitiks tik aiškias JSON užklausas.


### Išplėstiniai apribojimai

Jei turite sudėtingesnį apribojimą, galite pateikti objektą, kuris atsako į `matches?` ir kurį „Rails“ turėtų naudoti. Tarkime, norėdami nukreipti visus vartotojus iš ribotos sąrašo į `RestrictedListController`. Galite tai padaryti taip:

```ruby
class RestrictedListConstraint
  def initialize
    @ips = RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: RestrictedListConstraint.new
end
```

Taip pat galite nurodyti apribojimus kaip lambda:

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

Tie patys `matches?` metodas ir lambda gauna `request` objektą kaip argumentą.

#### Apribojimai bloko formoje

Galite nurodyti apribojimus bloko formoje. Tai naudinga, kai reikia taikyti tą patį taisyklę keliems maršrutams. Pavyzdžiui:

```ruby
class RestrictedListConstraint
  # ...Tas pats kaip ir aukščiau pavyzdyje
end

Rails.application.routes.draw do
  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

Taip pat galite naudoti `lambda`:

```ruby
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

### Maršruto globbingas ir ženklų segmentai

Maršruto globbingas yra būdas nurodyti, kad tam tikras parametras turėtų atitikti visus likusius maršruto dalis. Pavyzdžiui:

```ruby
get 'photos/*other', to: 'photos#unknown'
```

Šis maršrutas atitiktų `photos/12` arba `/photos/long/path/to/12`, nustatant `params[:other]` į `"12"` arba `"long/path/to/12"`. Ženklais, pradėtais žvaigždute, segmentai vadinami „ženklų segmentais“.

Ženklų segmentai gali pasirodyti bet kur maršrute. Pavyzdžiui:

```ruby
get 'books/*section/:title', to: 'books#show'
```

atitiktų `books/some/section/last-words-a-memoir` su `params[:section]` lygiu `'some/section'`, ir `params[:title]` lygiu `'last-words-a-memoir'`.

Techniškai maršrutas gali turėti net daugiau nei vieną ženklų segmentą. Deriklio priskyrimas parametrams vyksta intuityviai. Pavyzdžiui:

```ruby
get '*a/foo/*b', to: 'test#index'
```

atitiktų `zoo/woo/foo/bar/baz` su `params[:a]` lygiu `'zoo/woo'`, ir `params[:b]` lygiu `'bar/baz'`.
PASTABA: Užklausus `'/foo/bar.json'`, jūsų `params[:pages]` bus lygus `'foo/bar'` su JSON užklausos formatu. Jei norite atkurti senąjį 3.0.x elgesį, galite nurodyti `format: false` taip:

```ruby
get '*pages', to: 'pages#show', format: false
```

PASTABA: Jei norite padaryti formato segmentą privalomą, kad jis negalėtų būti praleistas, galite nurodyti `format: true` taip:

```ruby
get '*pages', to: 'pages#show', format: true
```

### Nukreipimas

Galite nukreipti bet kurį maršrutą į kitą maršrutą naudodami [`redirect`][] pagalbininką savo maršruteryje:

```ruby
get '/stories', to: redirect('/articles')
```

Taip pat galite pernaudoti dinaminius segmentus iš atitikimo maršruto nukreipimui į:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

Taip pat galite pateikti bloką `redirect`, kuris gauna simbolizuotus kelio parametrus ir užklausos objektą:

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

Atkreipkite dėmesį, kad numatytasis nukreipimas yra 301 "Perkelta nuolat" nukreipimas. Atminkite, kad kai kurios naršyklės ar tarpinės serveriai gali talpinti šio tipo nukreipimą, darydami senąją puslapį nepasiekiamą. Galite naudoti `:status` parinktį, norėdami pakeisti atsakymo būseną:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

Visais šiais atvejais, jei nenurodysite pirminio priimančiojo (`http://www.example.com`), „Rails“ gaus šiuos duomenis iš esamos užklausos.


### Maršrutavimas į „Rack“ programas

Vietoj eilutės kaip `'articles#index'`, kuri atitinka `index` veiksmą `ArticlesController`, galite nurodyti bet kurią [Rack programa](rails_on_rack.html) kaip atitikimo tašką:

```ruby
match '/application.js', to: MyRackApp, via: :all
```

Kol tik `MyRackApp` atsako į `call` ir grąžina `[status, headers, body]`, maršrutizatorius nežinos skirtumo tarp „Rack“ programos ir veiksmo. Tai yra tinkamas `via: :all` naudojimas, nes norėsite leisti savo „Rack“ programai tvarkyti visas veiksmus, kaip ji laiko tinkamu.

PASTABA: Smalsuoliams, `'articles#index'` iš tikrųjų išplečia `ArticlesController.action(:index)`, kuris grąžina tinkamą „Rack“ programą.

PASTABA: Kadangi proc/lambda yra objektai, kurie atsako į `call`, galite įgyvendinti labai paprastus maršrutus (pvz., sveikatos patikrinimui) tiesiogiai:<br>`get '/health', to: ->(env) { [204, {}, ['']] }`

Jei nurodote „Rack“ programą kaip atitikimo tašką, atkreipkite dėmesį, kad maršrutas nebus pakeistas gavusioje programoje. Su šiuo maršrutu jūsų „Rack“ programa turėtų tikėtis maršruto `/admin`:

```ruby
match '/admin', to: AdminApp, via: :all
```

Jei norite, kad jūsų „Rack“ programa gautų užklausas šakninėje vietoje, naudokite [`mount`][]:

```ruby
mount AdminApp, at: '/admin'
```


### Naudodami `root`

Galite nurodyti, ką „Rails“ turėtų maršrutizuoti `'/'` naudodami [`root`][] metodą:

```ruby
root to: 'pages#main'
root 'pages#main' # trumpinys aukščiau minėtam
```

`root` maršrutas turėtų būti įrašytas viršuje, nes jis yra populiariausias maršrutas ir turėtų būti pirmiausiai atitinkamas.

PASTABA: `root` maršrutas maršrutizuoja tik `GET` užklausas į veiksmą.

Taip pat galite naudoti `root` viduje vardų erdvių ir ribų. Pavyzdžiui:

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```


### Unikodo simbolių maršrutai

Galite tiesiogiai nurodyti unikodo simbolių maršrutus. Pavyzdžiui:

```ruby
get 'こんにちは', to: 'welcome#index'
```

### Tiesioginiai maršrutai

Galite tiesiogiai sukurti pasirinktinius URL pagalbininkus, tiesiog iškviesdami [`direct`][]. Pavyzdžiui:

```ruby
direct :homepage do
  "https://rubyonrails.org"
end

# >> homepage_url
# => "https://rubyonrails.org"
```

Blokui grąžintas rezultatas turi būti tinkamas `url_for` metodo argumentas. Taigi, galite perduoti tinkamą eilutės URL, maišą, masyvą, aktyvaus modelio egzempliorių ar aktyvaus modelio klasę.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```


### Naudodami `resolve`

[`resolve`][] metodas leidžia tinkinti modelių polimorfinį atvaizdavimą. Pavyzdžiui:

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_with model: @basket do |form| %>
  <!-- krepšelio forma -->
<% end %>
```

Tai sugeneruos vienintelį URL `/basket` vietoj įprasto `/baskets/:id`.


Tinkinimas resursinių maršrutų
------------------------------

Nors [`resources`][] sugeneruoti numatytieji maršrutai ir pagalbininkai jums dažniausiai bus tinkami, gali prireikti juos tinkinti. „Rails“ leidžia tinkinti beveik bet kurį resursinių pagalbininkų bendrą dalį.
### Kontrolerio nurodymas naudoti

`:controller` parinktis leidžia aiškiai nurodyti kontrolerį, kurį naudoti resursui. Pavyzdžiui:

```ruby
resources :photos, controller: 'images'
```

atpažins įeinančius kelius, prasidedančius nuo `/photos`, bet nukreips į `Images` kontrolerį:

| HTTP veiksmas | Kelias            | Kontrolerio#Veiksmas | Pavadinimo Kelio Pagalbininkas |
| ------------- | ----------------- | -------------------- | ------------------------------ |
| GET           | /photos           | images#index         | photos_path                    |
| GET           | /photos/new       | images#new           | new_photo_path                 |
| POST          | /photos           | images#create        | photos_path                    |
| GET           | /photos/:id       | images#show          | photo_path(:id)                |
| GET           | /photos/:id/edit  | images#edit          | edit_photo_path(:id)           |
| PATCH/PUT     | /photos/:id       | images#update        | photo_path(:id)                |
| DELETE        | /photos/:id       | images#destroy       | photo_path(:id)                |

PASTABA: Naudokite `photos_path`, `new_photo_path` ir t.t. generuojant kelius šiam resursui.

Kai naudojami pavadinimų erdvės kontroleriai, galite naudoti katalogo žymėjimą. Pavyzdžiui:

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

Tai nukreips į `Admin::UserPermissions` kontrolerį.

PASTABA: Palaikomas tik katalogo žymėjimas. Nurodant kontrolerį su Ruby konstantos žymėjimu (pvz., `controller: 'Admin::UserPermissions'`) gali kilti maršrutizavimo problemų ir gali būti išspausdinama įspėjimas.

### Apribojimų nurodymas

Galite naudoti `:constraints` parinktį, kad nurodytumėte reikalingą formatą neapibrėžtam `id`. Pavyzdžiui:

```ruby
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

Šis deklaravimas apriboja `:id` parametrą atitikti pateiktą reguliariojo išraiškos reikšmę. Taigi šiuo atveju maršrutizatorius nebeatpažintų `/photos/1` šiam maršrutui. Vietoj to, `/photos/RR27` atitiktų.

Galite nurodyti vieną apribojimą, taikomą keliems maršrutams, naudodami bloko formą:

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

PASTABA: Žinoma, šiame kontekste galite naudoti sudėtingesnius apribojimus, kurie yra galimi neresursiniuose maršrutuose.

PATARIMAS: Pagal numatymą `:id` parametras nepriima taškų - tai todėl, kad taškas naudojamas formatuotų maršrutų skirtuku. Jei norite naudoti tašką `:id`, pridėkite apribojimą, kuris pakeičia tai - pavyzdžiui, `id: /[^\/]+/` leidžia naudoti bet ką, išskyrus pasvirąją brūkšnį.

### Pavadinimo Kelio Pagalbininkų perrašymas

`:as` parinktis leidžia perrašyti įprastą pavadinimą pavadinimo kelio pagalbininkams. Pavyzdžiui:

```ruby
resources :photos, as: 'images'
```

atpažins įeinančius kelius, prasidedančius nuo `/photos`, ir nukreips užklausas į `PhotosController`, bet naudos `:as` parinkties reikšmę pavadinimo pagalbininkams pavadinti.

| HTTP veiksmas | Kelias            | Kontrolerio#Veiksmas | Pavadinimo Kelio Pagalbininkas |
| ------------- | ----------------- | -------------------- | ------------------------------ |
| GET           | /photos           | photos#index         | images_path                    |
| GET           | /photos/new       | photos#new           | new_image_path                 |
| POST          | /photos           | photos#create        | images_path                    |
| GET           | /photos/:id       | photos#show          | image_path(:id)                |
| GET           | /photos/:id/edit  | photos#edit          | edit_image_path(:id)           |
| PATCH/PUT     | /photos/:id       | photos#update        | image_path(:id)                |
| DELETE        | /photos/:id       | photos#destroy       | image_path(:id)                |

### `new` ir `edit` segmentų perrašymas

`:path_names` parinktis leidžia perrašyti automatiškai sugeneruotus `new` ir `edit` segmentus keliuose:

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

Tai sukeltų maršrutizatoriui atpažinti kelius, tokius kaip:

```
/photos/make
/photos/1/change
```

PASTABA: Ši parinktis nepakeičia faktinių veiksmų pavadinimų. Abu parodyti keliai vis tiek nukreips į `new` ir `edit` veiksmus.

PATARIMAS: Jei pastebite, kad norite vienodai pakeisti šią parinktį visiems savo maršrutams, galite naudoti apimtį, kaip parodyta žemiau:

```ruby
scope path_names: { new: 'make' } do
  # likusios jūsų maršrutai
end
```

### Pavadinimo Kelio Pagalbininkų priešdėlis

`:as` parinktį galite naudoti, kad priešdėliuotumėte pavadinimo kelio pagalbininkus, kuriuos „Rails“ generuoja maršrutui. Naudokite šią parinktį, kad išvengtumėte pavadinimų konfliktų tarp maršrutų, naudojančių kelio apimtį. Pavyzdžiui:

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

Tai pakeičia `/admin/photos` maršrutų pagalbinius įrankius nuo `photos_path`,
`new_photos_path`, ir t.t. į `admin_photos_path`, `new_admin_photo_path`,
ir t.t. Be `as: 'admin_photos` pridėjimo prie apimto `resources
:photos`, neapimto `resources :photos` nebus jokių maršruto pagalbinių įrankių.

Norėdami priešdėlį pridėti prie grupės maršruto pagalbinių įrankių, naudokite `:as` su `scope`:

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

Kaip ir anksčiau, tai pakeičia `/admin` apimtų resursų pagalbinius įrankius į
`admin_photos_path` ir `admin_accounts_path`, ir leidžia neapimtiems
resursams naudoti `photos_path` ir `accounts_path`.
PASTABA: `namespace` sritis automatiškai pridės `:as` taip pat ir `:module` bei `:path` prefiksus.

#### Parametriniai srities

Galite priešdėti maršrutus su varduoto parametru:

```ruby
scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
  resources :articles
end
```

Tai suteiks jums kelius, tokius kaip `/1/articles/9` ir leis jums nuorodą į kelio `account_id` dalį kaip `params[:account_id]` valdikliuose, pagalbininkuose ir rodiniuose.

Tai taip pat generuos kelio ir URL pagalbinius įrankius, prie kurių galite perduoti savo objektus kaip tikėtasi:

```ruby
account_article_path(@account, @article) # => /1/article/9
url_for([@account, @article])            # => /1/article/9
form_with(model: [@account, @article])   # => <form action="/1/article/9" ...>
```

Mes [naudojame apribojimą](#segment-constraints), kad apribotume sritį tik atitikti ID tipo eilutes. Galite pakeisti apribojimą pagal savo poreikius arba jį visiškai pamiršti. `:as` parinktis taip pat nėra griežtai būtina, tačiau be jos, „Rails“ iškels klaidą vertindamas `url_for([@account, @article])` ar kitus pagalbinius, kurie priklauso nuo `url_for`, tokius kaip [`form_with`][].

### Sukurtų maršrutų apribojimas

Pagal numatytuosius nustatymus „Rails“ sukuria maršrutus septynioms numatytoms veiksmų (`index`, `show`, `new`, `create`, `edit`, `update` ir `destroy`) kiekvienam RESTful maršrutui jūsų programoje. Galite naudoti `:only` ir `:except` parinktis, kad šį elgesį derintumėte. `:only` parinktis nurodo „Rails“, kad sukurtų tik nurodytus maršrutus:

```ruby
resources :photos, only: [:index, :show]
```

Dabar `GET` užklausa į `/photos` pavyks, bet `POST` užklausa į `/photos` (kuri paprastai būtų nukreipta į `create` veiksmą) nepavyks.

`:except` parinktis nurodo maršrutą ar maršrutų sąrašą, kurių „Rails“ neturėtų kurti:

```ruby
resources :photos, except: :destroy
```

Šiuo atveju „Rails“ sukurs visus įprastus maršrutus, išskyrus maršrutą `destroy` (a `DELETE` užklausa į `/photos/:id`).

PATARIMAS: Jei jūsų programoje yra daug RESTful maršrutų, naudojant `:only` ir `:except` tik tam tikrus reikalingus maršrutus galite sumažinti atminties naudojimą ir pagreitinti maršrutizavimo procesą.

### Išversti keliai

Naudodami `scope`, galime keisti `resources` sugeneruojamų kelio pavadinimus:

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

Dabar „Rails“ sukurs maršrutus į `CategoriesController`.

| HTTP veiksmas | Kelias                      | Valdiklis#Veiksmas | Pavadinimo pagalbininkas |
| ------------- | -------------------------- | ------------------ | ----------------------- |
| GET           | /kategorien                 | categories#index   | categories_path         |
| GET           | /kategorien/neu             | categories#new     | new_category_path       |
| POST          | /kategorien                 | categories#create  | categories_path         |
| GET           | /kategorien/:id             | categories#show    | category_path(:id)      |
| GET           | /kategorien/:id/bearbeiten  | categories#edit    | edit_category_path(:id) |
| PATCH/PUT     | /kategorien/:id             | categories#update  | category_path(:id)      |
| DELETE        | /kategorien/:id             | categories#destroy | category_path(:id)      |

### Vienaskaitos formos perrašymas

Jei norite perrašyti resurso vienaskaitos formą, turėtumėte pridėti papildomas taisykles į inflektorių per [`inflections`][]:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```

### Naudodami `:as` įterptuose resursuose

`as` parinktis perrašo automatiškai sugeneruotą resurso pavadinimą įterptuose maršruto pagalbiniuose įrankiuose. Pavyzdžiui:

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

Tai sukurs maršruto pagalbinius įrankius, tokius kaip `magazine_periodical_ads_url` ir `edit_magazine_periodical_ad_path`.

### Perrašant pavadinimo pagalbinius parametrus

`:param` parinktis perrašo numatytąjį resurso identifikatorių `:id` (dinaminio segmento [naudojamo generuojant maršrutus](routing.html#dynamic-segments) pavadinimą). Jūs galite pasiekti tą segmentą iš savo valdiklio naudodami `params[<:param>]`.

```ruby
resources :videos, param: :identifier
```

```
    videos GET  /videos(.:format)                  videos#index
           POST /videos(.:format)                  videos#create
 new_video GET  /videos/new(.:format)              videos#new
edit_video GET  /videos/:identifier/edit(.:format) videos#edit
```

```ruby
Video.find_by(identifier: params[:identifier])
```

Galite perrašyti asocijuoto modelio `ActiveRecord::Base#to_param` metodą, kad sukurtumėte URL:

```ruby
class Video < ApplicationRecord
  def to_param
    identifier
  end
end
```

```ruby
video = Video.find_by(identifier: "Roman-Holiday")
edit_video_path(video) # => "/videos/Roman-Holiday/edit"
```

Labai didelio maršruto failo padalijimas į kelis mažus
-------------------------------------------------------

Jei dirbate didelėje programoje su tūkstančiais maršrutų, vienas `config/routes.rb` failas gali tapti nepatogus ir sunkiai skaitomas.

„Rails“ siūlo būdą padalinti didžiulį vienintelį `routes.rb` failą į kelis mažus naudojant [`draw`][] makrą.

Galite turėti `admin.rb` maršrutą, kuriame yra visi maršrutai administravimo sričiai, kitą `api.rb` failą, skirtą API susijusiems ištekliams ir t.t.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  get 'foo', to: 'foo#bar'

  draw(:admin) # Įkelia kitą maršruto failą, esantį `config/routes/admin.rb`
end
```
```ruby
# config/routes/admin.rb

namespace :admin do
  resources :comments
end
```

Kviečiant `draw(:admin)` viduje `Rails.application.routes.draw` bloko pati išbandys įkelti maršruto failą, kuris turi tokį patį pavadinimą kaip pateiktas argumentas (`admin.rb` šiuo pavyzdžiu).
Failas turi būti rastas `config/routes` kataloge arba bet kurioje sub-kataloge (pvz., `config/routes/admin.rb` arba `config/routes/external/admin.rb`).

Galite naudoti įprastą maršrutizavimo DSL `admin.rb` maršrutų faile, bet **neturėtumėte** apgaubti jo `Rails.application.routes.draw` bloku, kaip padarėte pagrindiniame `config/routes.rb` faile.


### Nenaudokite šios funkcijos, nebent tikrai jums reikia

Turint kelis maršruto failus, išsiaiškinimas ir supratimas tampa sunkesni. Daugumai programų - net ir tiems, kuriuose yra kelios šimtos maršrutų - lengviau programuotojams turėti vieną maršruto failą. "Rails" maršrutizavimo DSL jau siūlo būdą išskaidyti maršrutus organizuotu būdu naudojant `namespace` ir `scope`.


Maršrutų tikrinimas ir testavimas
-----------------------------

"Rails" siūlo priemones maršrutams tikrinti ir testuoti.

### Esamų maršrutų sąrašas

Norėdami gauti visą galimų maršrutų sąrašą savo aplikacijoje, aplankykite <http://localhost:3000/rails/info/routes> savo naršyklėje, kai jūsų serveris veikia **development** aplinkoje. Taip pat galite vykdyti `bin/rails routes` komandą terminale, kad gautumėte tą patį rezultatą.

Abu metodai pateiks visus jūsų maršrutus, ta pačia tvarka, kaip jie atrodo `config/routes.rb` faile. Kiekvienam maršrutui matysite:

* Maršruto pavadinimą (jei yra)
* HTTP veiksmą (jei maršrutas nereaguoja į visus veiksmus)
* URL šabloną, kuris turi būti atitinkamas
* Maršruto maršrutizavimo parametrus

Pavyzdžiui, čia yra nedidelė dalis `bin/rails routes` rezultato RESTful maršrutui:

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

Taip pat galite naudoti `--expanded` parinktį, kad įjungtumėte išplėstinį lentelės formato režimą.

```bash
$ bin/rails routes --expanded

--[ Maršrutas 1 ]----------------------------------------------------
Prefiksas          | users
Veiksmas           | GET
URI                | /users(.:format)
Valdiklis#Veiksmas | users#index
--[ Maršrutas 2 ]----------------------------------------------------
Prefiksas          |
Veiksmas           | POST
URI                | /users(.:format)
Valdiklis#Veiksmas | users#create
--[ Maršrutas 3 ]----------------------------------------------------
Prefiksas          | new_user
Veiksmas           | GET
URI                | /users/new(.:format)
Valdiklis#Veiksmas | users#new
--[ Maršrutas 4 ]----------------------------------------------------
Prefiksas          | edit_user
Veiksmas           | GET
URI                | /users/:id/edit(.:format)
Valdiklis#Veiksmas | users#edit
```

Galite ieškoti savo maršrutų naudodami `grep` parinktį. Tai išves bet kokius maršrutus, kurie iš dalies atitinka URL pagalbinio metodo pavadinimą, HTTP veiksmą ar URL kelią.

```bash
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

Jei norite pamatyti tik tuos maršrutus, kurie susiejami su tam tikru valdikliu, yra parinktis `-c`.

```bash
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

PATARIMAS: `bin/rails routes` rezultatas bus daug skaitytinesnis, jei išplėsite terminalo langą, kol eilutės nebesisuktels. 

### Maršrutų testavimas

Maršrutai turėtų būti įtraukti į jūsų testavimo strategiją (kaip ir visą jūsų aplikaciją). "Rails" siūlo tris įmontuotas patikrinimo funkcijas, skirtas palengvinti maršrutų testavimą:

* [`assert_generates`][]
* [`assert_recognizes`][]
* [`assert_routing`][]


#### `assert_generates` patikrinimas

[`assert_generates`][] patikrina, kad konkretus parametrų rinkinys generuoja konkretų kelią ir gali būti naudojamas su numatytomis maršrutais arba pasirinktiniais maršrutais. Pavyzdžiui:

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### `assert_recognizes` patikrinimas

[`assert_recognizes`][] yra `assert_generates` atvirkštinis. Jis patikrina, kad tam tikras kelias yra atpažįstamas ir nukreipiamas į konkretų vietą jūsų aplikacijoje. Pavyzdžiui:

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

Galite nurodyti `:method` argumentą, kad nurodytumėte HTTP veiksmą:

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### `assert_routing` patikrinimas

[`assert_routing`][] patikrinimas patikrina maršrutą abiem kryptimis: jis testuoja, ar kelias generuoja parametrus, ir ar parametrai generuoja kelią. Taigi, jis sujungia `assert_generates` ir `assert_recognizes` funkcijas:

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```

[`resources`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
[`namespace`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-namespace
[`scope`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-scope
[`shallow`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-shallow
[`concern`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concern
[`concerns`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concerns
[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`delete`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-delete
[`get`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-get
[`member`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-member
[`patch`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-patch
[`post`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-post
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`collection`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-collection
[`defaults`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-defaults
[`match`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-match
[`constraints`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints
[`redirect`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Redirection.html#method-i-redirect
[`mount`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-mount
[`root`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-root
[`direct`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-direct
[`resolve`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve
[`form_with`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[`inflections`]: https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-inflections
[`draw`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-draw
[`assert_generates`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates
[`assert_recognizes`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes
[`assert_routing`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_routing
