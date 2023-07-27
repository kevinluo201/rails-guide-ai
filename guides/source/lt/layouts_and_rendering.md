**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 02f663dc709da76ced45deb2ba800a78
Maketavimas ir atvaizdavimas „Rails“
===================================

Šiame vadove aptariamos pagrindinės „Action Controller“ ir „Action View“ maketavimo funkcijos.

Po šios vadovėlio perskaitymo žinosite:

* Kaip naudoti į „Rails“ įdiegtus įvairius atvaizdavimo metodus.
* Kaip kurti maketus su keliais turinio skyriais.
* Kaip naudoti dalinius atvaizdus, siekiant sumažinti pasikartojimą peržiūrose.
* Kaip naudoti įdėtus maketus (priklausomus šablonus).

--------------------------------------------------------------------------------

Apžvalga: kaip dalių suderinamumas
----------------------------------

Šiame vadove dėmesys skiriamas valdiklio ir peržiūros sąveikai modelio-peržiūros-valdiklio trikampyje. Kaip žinote, valdiklis atsakingas už viso proceso, susijusio su užklausos tvarkymu „Rails“, orkestravimą, nors paprastai jis perduoda bet kokį sunkų kodą modeliui. Tačiau, kai ateina laikas atsiųsti atsaką vartotojui, valdiklis perduoda reikalus peržiūrai. Šiame vadove nagrinėjamas būtent šis perduodimas.

Iš esmės tai apima sprendimą, ką siųsti kaip atsaką ir kvietimą tinkamai metodui, kuris sukurtų tą atsaką. Jei atsakas yra visiškai išplėstas peržiūros langas, „Rails“ taip pat atlieka papildomą darbą, kad apgaubtų peržiūrą maketu ir galbūt įtrauktų dalinius peržiūras. Vėliau šiame vadove pamatysite visas šias kelias.

Atsakų kūrimas
---------------

Iš valdiklio perspektyvos yra trys būdai sukurti HTTP atsaką:

* Iškviesti [`render`][controller.render], kad sukurtumėte visą atsaką, kurį siųsti naršyklei
* Iškviesti [`redirect_to`][] norint siųsti naršyklei HTTP peradresavimo būsenos kodą
* Iškviesti [`head`][] norint sukurti atsaką, kuris sudarytas tik iš HTTP antraščių, kurias siųsti naršyklei


### Numatytasis atvaizdavimas: konvencija virš konfigūracijos veikimo

Esate girdėję, kad „Rails“ skatina „konvenciją virš konfigūracijos“. Numatytasis atvaizdavimas yra puikus šios taisyklės pavyzdys. Pagal numatymą „Rails“ valdikliai automatiškai atvaizduoja peržiūras, kurių pavadinimai atitinka galiojančius maršrutus. Pavyzdžiui, jei jūsų `BooksController` klasėje yra šis kodas:

```ruby
class BooksController < ApplicationController
end
```

Ir šis jūsų maršrutų failas:

```ruby
resources :books
```

Ir turite peržiūros failą `app/views/books/index.html.erb`:

```html+erb
<h1>Knygos greitai bus!</h1>
```

„Rails“ automatiškai atvaizduos `app/views/books/index.html.erb`, kai naršysite adresu `/books`, ir ekrane matysite „Knygos greitai bus!“.

Tačiau ateinančios peržiūros langas yra tik minimaliai naudingas, todėl greitai sukursite savo `Book` modelį ir pridėsite indekso veiksmą prie `BooksController`:

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

Atkreipkite dėmesį, kad indekso veiksmo pabaigoje neturime aiškaus atvaizdavimo, vadovaujantis „konvencija virš konfigūracijos“ principu. Taisyklė yra tokia, jei veiksmo pabaigoje iš esmės nieko neatskleidžiate, „Rails“ automatiškai ieškos `action_name.html.erb` šablono valdiklio peržiūros kelyje ir jį atvaizduos. Taigi šiuo atveju „Rails“ atvaizduos `app/views/books/index.html.erb` failą.

Jei norime peržiūroje rodyti visų knygų savybes, tai galime padaryti naudodami ERB šabloną, panašų į šį:

```html+erb
<h1>Knygų sąrašas</h1>

<table>
  <thead>
    <tr>
      <th>Pavadinimas</th>
      <th>Turinys</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Rodyti", book %></td>
        <td><%= link_to "Redaguoti", edit_book_path(book) %></td>
        <td><%= link_to "Naikinti", book, data: { turbo_method: :delete, turbo_confirm: "Ar tikrai?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "Nauja knyga", new_book_path %>
```

PASTABA: Tikras atvaizdavimas atliekamas naudojant modulio [`ActionView::Template::Handlers`](https://api.rubyonrails.org/classes/ActionView/Template/Handlers.html) įdėtus klases. Šiame vadove nėra nagrinėjamas šis procesas, tačiau svarbu žinoti, kad jūsų peržiūros failo plėtinys kontroliuoja šablono tvarkyklės pasirinkimą.

### Naudodami `render`

Dažniausiai valdiklio [`render`][controller.render] metodas atlieka pagrindinį darbą, atvaizduodamas jūsų programos turinį naršyklės naudojimui. Yra įvairių būdų pritaikyti `render` veikimą. Galite atvaizduoti numatytąją peržiūrą „Rails“ šablonui arba konkretų šabloną, arba failą, arba įterptą kodą, arba visai nieko. Galite atvaizduoti tekstą, JSON ar XML. Taip pat galite nurodyti atvaizduojamo atsakymo turinio tipą arba HTTP būsenos kodą.

PATARIMAS: Jei norite pamatyti tikslų `render` iškvietimo rezultatą, nereikalaudami jo tikrinti naršyklėje, galite iškviesti `render_to_string`. Šis metodas priima tiksliai tuos pačius parametrus kaip ir `render`, bet grąžina eilutę, o ne siunčia atsaką atgal į naršyklę.
#### Vaizdo atvaizdavimas veiksmo

Jei norite atvaizduoti vaizdą, kuris atitinka kitą šablono šablono toje pačioje kontroleryje, galite naudoti `render` su vaizdo pavadinimu:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

Jei `update` iškvietimas nepavyksta, šio kontrolerio `update` veiksmas atvaizduos `edit.html.erb` šabloną, priklausančią tam pačiam kontroleriui.

Jei norite, galite naudoti simbolį vietoj eilutės, kad nurodytumėte veiksmą, kurį norite atvaizduoti:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit, status: :unprocessable_entity
  end
end
```

#### Vaizdo atvaizdavimas iš kito kontrolerio veiksmo

Ką daryti, jei norite atvaizduoti šablono iš visiškai skirtingo kontrolerio nei tas, kuriame yra veiksmo kodas? Tai taip pat galite padaryti su `render`, kuris priima visą kelią (atitinkamai `app/views`) šablono atvaizdavimui. Pavyzdžiui, jei vykdote kodą `AdminProductsController`, kuris yra `app/controllers/admin`, galite atvaizduoti veiksmo rezultatus šablonui `app/views/products` šiuo būdu:

```ruby
render "products/show"
```

Rails žino, kad šis vaizdas priklauso kitam kontroleriui dėl įterpto pasvirimo ženklo eilutėje. Jei norite būti aiškesni, galite naudoti `:template` parinktį (kuri buvo privaloma Rails 2.2 ir ankstesnėse versijose):

```ruby
render template: "products/show"
```

#### Apvyniojimas

Aukščiau aprašyti du būdai atvaizduoti (atvaizduoti kito veiksmo šabloną tame pačiame kontroleryje ir atvaizduoti kito veiksmo šabloną kitame kontroleryje) iš tikrųjų yra tų pačių operacijų variantai.

Iš tikrųjų, `BooksController` klasėje, `update` veiksme, kai norime atvaizduoti redagavimo šabloną, jei knyga nesėkmingai atnaujinama, visi šie `render` iškvietimai atvaizduos `edit.html.erb` šabloną `views/books` kataloge:

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

Kurį naudoti, tai tik stiliaus ir konvencijos klausimas, bet taisyklė yra naudoti paprasčiausią, bet prasmingiausią kodui, kurį rašote.

#### Naudodami `render` su `:inline`

`Render` metodas gali visiškai atsisakyti vaizdo, jei norite naudoti `:inline` parinktį, kad dalį ERB pateiktumėte kaip metodo iškvietimo dalį. Tai yra visiškai teisinga:

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

ĮSPĖJIMAS: Yra labai mažai geros priežasties naudoti šią parinktį. ERB maišymas į jūsų kontrolerius pažeidžia Rails MVC orientaciją ir padarys sunkiau kitoms programuotojams sekti jūsų projekto logiką. Vietoj to naudokite atskirą erb vaizdą.

Pagal numatytuosius nustatymus, įterpimo atvaizdavimas naudoja ERB. Galite priversti jį naudoti Builder su `:type` parinktimi:

```ruby
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```

#### Teksto atvaizdavimas

Galite siųsti gryną tekstą - be jokio žymėjimo - atgal į naršyklę, naudodami `:plain` parinktį `render`:

```ruby
render plain: "OK"
```

PATARIMAS: Grynasis tekstas yra naudingiausias, kai reaguojate į Ajax arba interneto paslaugų užklausas, kurios tikisi kažko kito nei tinkamas HTML.

Pastaba: Pagal numatytuosius nustatymus, jei naudojate `:plain` parinktį, tekstas atvaizduojamas be naudojant esamą išdėstymą. Jei norite, kad „Rails“ įdėtų tekstą į esamą išdėstymą, turite pridėti `layout: true` parinktį ir naudoti `.text.erb` plėtinį išdėstymo failui.

#### HTML atvaizdavimas

Galite siųsti HTML eilutę atgal į naršyklę, naudodami `:html` parinktį `render`:

```ruby
render html: helpers.tag.strong('Not Found')
```

PATARIMAS: Tai naudinga, kai atvaizduojate mažą HTML kodo fragmentą. Tačiau jei žymėjimas yra sudėtingas, galbūt norėsite jį perkelti į šablonų failą.

Pastaba: Naudodami `html:` parinktį, jei eilutė nėra sudaryta iš `html_safe`-sąmoningų API, HTML entitetai bus pakeisti.

#### JSON atvaizdavimas

JSON yra „JavaScript“ duomenų formatas, kurį naudoja daugelis „Ajax“ bibliotekų. „Rails“ turi įdiegtą palaikymą, skirtą objektų konvertavimui į JSON ir šio JSON atvaizdavimui naršyklėje:

```ruby
render json: @product
```

PATARIMAS: Jums nereikia iškviesti `to_json` objekte, kurį norite atvaizduoti. Jei naudojate `:json` parinktį, `render` automatiškai iškvies `to_json` už jus.
#### XML atvaizdavimas

Rails taip pat turi įdiegtą palaikymą objektų konvertavimui į XML ir šio XML atvaizdavimui grąžinant skambinančiajai pusei:

```ruby
render xml: @product
```

PATARIMAS: Jums nereikia iškviesti `to_xml` metodo objekte, kurį norite atvaizduoti. Jei naudojate `:xml` parinktį, `render` automatiškai iškvies `to_xml` už jus.

#### Paprasto JavaScript atvaizdavimas

Rails gali atvaizduoti paprastą JavaScript:

```ruby
render js: "alert('Sveiki, Rails');"
```

Tai siųs pateiktą eilutę naršyklei su `text/javascript` MIME tipu.

#### Neapdoroto turinio atvaizdavimas

Galite siųsti neapdorotą turinį naršyklei, nustatydami `:body` parinktį `render` metode, be nustatant jokio turinio tipo:

```ruby
render body: "neapdorotas"
```

PATARIMAS: Šią parinktį turėtumėte naudoti tik tada, jei jums nerūpi atsakymo turinio tipas. Daugumai atvejų būtų tinkamesnis `:plain` arba `:html`.

PASTABA: Jei neperrašote, jūsų atsakymas, grąžintas naudojant šią atvaizdavimo parinktį, bus `text/plain`, nes tai yra numatytasis turinio tipas veiksmo perdavimo atveju.

#### Neapdoroto failo atvaizdavimas

Rails gali atvaizduoti neapdorotą failą iš absoliučios kelio. Tai naudinga sąlygiškai atvaizduoti statinius failus, pvz., klaidų puslapius.

```ruby
render file: "#{Rails.root}/public/404.html", layout: false
```

Tai atvaizduoja neapdorotą failą (jis nepalaiko ERB ar kitų apdorojimo priemonių). Pagal numatytuosius nustatymus jis atvaizduojamas esamoje išdėstyme.

ĮSPĖJIMAS: Naudodami `:file` parinktį kartu su naudotojo įvestimi, gali kilti saugumo problemų, nes puolėjas galėtų naudoti šį veiksmą, norėdamas pasiekti jūsų failų sistemoje esančius saugumo jautrius failus.

PATARIMAS: `send_file` dažnai yra greitesnė ir geresnė parinktis, jei nereikia išdėstymo.

#### Objektų atvaizdavimas

Rails gali atvaizduoti objektus, kurie atsako į `:render_in` metodą.

```ruby
render MyRenderable.new
```

Tai iškviečia `render_in` metodą pateiktame objekte su esamu rodinio kontekstu.

Taip pat galite pateikti objektą naudodami `:renderable` parinktį `render` metode:

```ruby
render renderable: MyRenderable.new
```

#### Parinktys `render` metode

Kviečiant [`render`][controller.render] metodą, paprastai priimamos šešios parinktys:

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`
* `:variants`

##### `:content_type` parinktis

Pagal numatytuosius nustatymus, Rails aptarnaus atvaizdavimo operacijos rezultatus su MIME turinio tipu `text/html` (arba `application/json`, jei naudojate `:json` parinktį, arba `application/xml` naudojant `:xml` parinktį). Yra atvejų, kai norėtumėte tai pakeisti, ir tai galite padaryti nustatydami `:content_type` parinktį:

```ruby
render template: "feed", content_type: "application/rss"
```

##### `:layout` parinktis

Su dauguma `render` parinkčių, atvaizduotas turinys rodomas kaip esamo išdėstymo dalis. Apie išdėstymus ir kaip juos naudoti sužinosite vėliau šiame vadove.

Galite naudoti `:layout` parinktį, kad Rails naudotų konkretų failą kaip esamo veiksmo išdėstymą:

```ruby
render layout: "special_layout"
```

Taip pat galite pasakyti Rails, kad atvaizduotų be jokio išdėstymo:

```ruby
render layout: false
```

##### `:location` parinktis

Galite naudoti `:location` parinktį, kad nustatytumėte HTTP `Location` antraštę:

```ruby
render xml: photo, location: photo_url(photo)
```

##### `:status` parinktis

Rails automatiškai sugeneruos atsakymą su teisingu HTTP būsenos kodu (daugumoje atvejų tai yra `200 OK`). Galite naudoti `:status` parinktį, kad tai pakeistumėte:

```ruby
render status: 500
render status: :forbidden
```

Rails supranta tiek skaitinius būsenos kodus, tiek žemiau pateiktus simbolius.

| Atsakymo klasė     | HTTP būsenos kodas | Simbolis                          |
| ------------------- | ---------------- | -------------------------------- |
| **Informacinis**   | 100              | :continue                        |
|                     | 101              | :switching_protocols             |
|                     | 102              | :processing                      |
| **Sėkmė**         | 200              | :ok                              |
|                     | 201              | :created                         |
|                     | 202              | :accepted                        |
|                     | 203              | :non_authoritative_information   |
|                     | 204              | :no_content                      |
|                     | 205              | :reset_content                   |
|                     | 206              | :partial_content                 |
|                     | 207              | :multi_status                    |
|                     | 208              | :already_reported                |
|                     | 226              | :im_used                         |
| **Nukreipimas**     | 300              | :multiple_choices                |
|                     | 301              | :moved_permanently               |
|                     | 302              | :found                           |
|                     | 303              | :see_other                       |
|                     | 304              | :not_modified                    |
|                     | 305              | :use_proxy                       |
|                     | 307              | :temporary_redirect              |
|                     | 308              | :permanent_redirect              |
| **Kliento klaida**    | 400              | :bad_request                     |
|                     | 401              | :unauthorized                    |
|                     | 402              | :payment_required                |
|                     | 403              | :forbidden                       |
|                     | 404              | :not_found                       |
|                     | 405              | :method_not_allowed              |
|                     | 406              | :not_acceptable                  |
|                     | 407              | :proxy_authentication_required   |
|                     | 408              | :request_timeout                 |
|                     | 409              | :conflict                        |
|                     | 410              | :gone                            |
|                     | 411              | :length_required                 |
|                     | 412              | :precondition_failed             |
|                     | 413              | :payload_too_large               |
|                     | 414              | :uri_too_long                    |
|                     | 415              | :unsupported_media_type          |
|                     | 416              | :range_not_satisfiable           |
|                     | 417              | :expectation_failed              |
|                     | 421              | :misdirected_request             |
|                     | 422              | :unprocessable_entity            |
|                     | 423              | :locked                          |
|                     | 424              | :failed_dependency               |
|                     | 426              | :upgrade_required                |
|                     | 428              | :precondition_required           |
|                     | 429              | :too_many_requests               |
|                     | 431              | :request_header_fields_too_large |
|                     | 451              | :unavailable_for_legal_reasons   |
| **Serverio klaida**    | 500              | :internal_server_error           |
|                     | 501              | :not_implemented                 |
|                     | 502              | :bad_gateway                     |
|                     | 503              | :service_unavailable             |
|                     | 504              | :gateway_timeout                 |
|                     | 505              | :http_version_not_supported      |
|                     | 506              | :variant_also_negotiates         |
|                     | 507              | :insufficient_storage            |
|                     | 508              | :loop_detected                   |
|                     | 510              | :not_extended                    |
|                     | 511              | :network_authentication_required |
PASTABA: Jei bandysite atvaizduoti turinį kartu su ne-turinio būsenos kodu (100-199, 204, 205 arba 304), jis bus pašalintas iš atsakymo.

##### `:formats` parinktis

Rails naudoja formą, nurodytą užklausoje (arba `:html` pagal numatytuosius nustatymus). Galite tai pakeisti, perduodant `:formats` parinktį su simboliu arba masyvu:

```ruby
render formats: :xml
render formats: [:json, :xml]
```

Jei šablonas su nurodytu formatu neegzistuoja, iškeliama klaida `ActionView::MissingTemplate`.

##### `:variants` parinktis

Tai nurodo Rails ieškoti šablono variantų to paties formato. Galite nurodyti variantų sąrašą, perduodant `:variants` parinktį su simboliu arba masyvu.

Pavyzdys:

```ruby
# iškviesta HomeController#index
render variants: [:mobile, :desktop]
```

Su šiais variantais Rails ieškos šių šablonų rinkinio ir naudos pirmąjį, kuris egzistuoja.

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

Jei šablonas su nurodytu formatu neegzistuoja, iškeliama klaida `ActionView::MissingTemplate`.

Vietoje varianto nustatymo renderinimo metu, jį taip pat galite nustatyti užklausos objekte savo valdiklio veiksmo metu.

```ruby
def index
  request.variant = determine_variant
end

  private
    def determine_variant
      variant = nil
      # kodas, kuris nustato naudotinus variantus
      variant = :mobile if session[:use_mobile]

      variant
    end
```

#### Ieškant išdėstymo

Norėdami rasti dabartinį išdėstymą, Rails pirmiausia ieško failo `app/views/layouts`, kurio bazinis pavadinimas yra toks pat kaip ir valdiklio. Pavyzdžiui, atvaizduojant veiksmus iš `PhotosController` klasės, bus naudojamas `app/views/layouts/photos.html.erb` (arba `app/views/layouts/photos.builder`). Jei nėra tokio valdiklio specifinio išdėstymo, Rails naudos `app/views/layouts/application.html.erb` arba `app/views/layouts/application.builder`. Jei nėra `.erb` išdėstymo, Rails naudos `.builder` išdėstymą, jei toks egzistuoja. Rails taip pat suteikia keletą būdų tiksliau priskirti konkretų išdėstymą atskiriems valdikliams ir veiksmams.

##### Išdėstymo nustatymas valdikliams

Galite perrašyti numatytuosius išdėstymo konvencijas savo valdikliuose naudodami [`layout`][] deklaraciją. Pavyzdžiui:

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

Su šia deklaracija, visi `ProductsController` atvaizduojami rodiniai naudos `app/views/layouts/inventory.html.erb` kaip savo išdėstymą.

Norėdami priskirti konkretų išdėstymą visai programai, naudokite `layout` deklaraciją savo `ApplicationController` klasėje:

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

Su šia deklaracija, visi programos rodiniai naudos `app/views/layouts/main.html.erb` kaip savo išdėstymą.

##### Išdėstymo pasirinkimas vykdymo metu

Galite naudoti simbolį, kad atidėtumėte išdėstymo pasirinkimą iki užklausos apdorojimo:

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end
end
```

Dabar, jei dabartinis vartotojas yra specialus vartotojas, jis gaus specialų išdėstymą, peržiūrėdamas produktą.

Netgi galite naudoti įterptinį metodą, pvz., `Proc`, kad nustatytumėte išdėstymą. Pavyzdžiui, jei perduodate `Proc` objektą, blokas, kurį duodate `Proc`, bus duotas `controller` egzemplioriui, todėl išdėstymas gali būti nustatomas pagal dabartinę užklausą:

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### Sąlyginiai išdėstymai

Valdiklio lygyje nurodyti išdėstymai palaiko `:only` ir `:except` parinktis. Šios parinktys priima metodų pavadinimą arba metodų pavadinimų masyvą, atitinkančių metodus valdiklyje:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

Su šia deklaracija, `product` išdėstymas bus naudojamas visiems, išskyrus `rss` ir `index` metodus.

##### Išdėstymo paveldėjimas

Išdėstymo deklaracijos kaskadinamos žemyn hierarchijoje, ir specifinės išdėstymo deklaracijos visada perrašo bendresnes. Pavyzdžiui:

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `articles_controller.rb`

    ```ruby
    class ArticlesController < ApplicationController
    end
    ```

* `special_articles_controller.rb`

    ```ruby
    class SpecialArticlesController < ArticlesController
      layout "special"
    end
    ```

* `old_articles_controller.rb`

    ```ruby
    class OldArticlesController < SpecialArticlesController
      layout false

      def show
        @article = Article.find(params[:id])
      end

      def index
        @old_articles = Article.older
        render layout: "old"
      end
      # ...
    end
    ```

Šioje programoje:

* Bendrai, rodiniai bus atvaizduojami pagal `main` išdėstymą
* `ArticlesController#index` naudos `main` išdėstymą
* `SpecialArticlesController#index` naudos `special` išdėstymą
* `OldArticlesController#show` nebus naudojamas joks išdėstymas
* `OldArticlesController#index` naudos `old` išdėstymą
##### Šablonų paveldėjimas

Panašiai kaip ir išdėstymo paveldėjimo logika, jei šablonas ar dalis nerandama konvenciniame kelyje, valdiklis ieškos šablono ar dalies, kurį reikia atvaizduoti, jo paveldėjimo grandinėje. Pavyzdžiui:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
end
```

```ruby
# app/controllers/admin_controller.rb
class AdminController < ApplicationController
end
```

```ruby
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < AdminController
  def index
  end
end
```

`admin/products#index` veiksmo paieškos tvarka bus:

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

Tai padaro `app/views/application/` puikiu vietu bendriems daliniams, kurie gali būti atvaizduojami ERB kaip toks:

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
Šiame sąraše nėra jokių elementų <em>dar</em>.
```

#### Dvigubo atvaizdavimo klaidų išvengimas

Anksčiau ar vėliau, dauguma „Rails“ programuotojų matys klaidos pranešimą „Vienu veiksmu galima atvaizduoti arba nukreipti tik kartą“. Nors tai gali būti erzinantis, tai relativiai lengva ištaisyti. Paprastai tai atsitinka dėl pagrindinio supratimo apie tai, kaip veikia `render` funkcija.

Pavyzdžiui, šis kodas sukels klaidą:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

Jei `@book.special?` įvertinimas yra `true`, „Rails“ pradės atvaizdavimo procesą, kad įdėtų `@book` kintamąjį į `special_show` rodinį. Tačiau tai _ne_ sustabdys likusio kodo vykdymo `show` veiksme, ir kai „Rails“ pasieks veiksmo pabaigą, jis pradės atvaizduoti `regular_show` rodinį - ir išmes klaidą. Sprendimas yra paprastas: įsitikinkite, kad vienoje kodo eigoje yra tik vienas `render` arba `redirect` kvietimas. Vienas dalykas, kuris gali padėti, yra `return`. Štai patobulinta metodo versija:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
    return
  end
  render action: "regular_show"
end
```

Atkreipkite dėmesį, kad neaiškus `render`, atliekamas `ActionController`, nustato, ar buvo iškviestas `render`, todėl šis kodas veiks be klaidų:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

Tai atvaizduos knygą su nustatyta `special?` reikšme naudojant `special_show` šabloną, o kitos knygos bus atvaizduojamos naudojant numatytąjį `show` šabloną.

### Nukreipimas naudojant `redirect_to`

Kitas būdas tvarkyti grąžinimo atsakus į HTTP užklausą yra naudojant [`redirect_to`][]. Kaip matėte, `render` nurodo „Rails“, kurį rodinį (ar kitą turinį) naudoti atsakui konstruoti. `redirect_to` metodas daro visiškai kitą dalyką: jis praneša naršyklei, kad ji turi siųsti naują užklausą kitam URL. Pavyzdžiui, galite nukreipti iš bet kurio kodo vietos į jūsų programoje esančių nuotraukų indeksą šiuo kvietimu:

```ruby
redirect_to photos_url
```

Galite naudoti [`redirect_back`][], kad grąžintumėte vartotoją į puslapį, iš kurio jis tik ką atėjo. Ši vieta gaunama iš `HTTP_REFERER` antraštės, kurią naršyklė ne visada nustato, todėl turite nurodyti `fallback_location`, kurį naudoti šiuo atveju.

```ruby
redirect_back(fallback_location: root_path)
```

PASTABA: `redirect_to` ir `redirect_back` nebaigia ir nedelsiai grąžina vykdymą iš metodo, bet tiesiog nustato HTTP atsakus. Po jų vykdomi teiginiai. Jei reikia, galite sustabdyti naudodami aiškų `return` arba kitą stabdymo mechanizmą.


#### Skirtingas nukreipimo būsenos kodas

„Rails“ naudoja HTTP būsenos kodą 302, laikiną nukreipimą, kai iškviečiate `redirect_to`. Jei norite naudoti kitą būsenos kodą, pvz., 301, nuolatinį nukreipimą, galite naudoti `:status` parinktį:

```ruby
redirect_to photos_path, status: 301
```

Kaip ir `:status` parinktis `render` funkcijai, `:status` parinktis `redirect_to` priima tiek skaitines, tiek simbolines antraštės žymėjimus.

#### Skirtumas tarp `render` ir `redirect_to`

Kartais neįgudę programuotojai mano, kad `redirect_to` yra rūšis `goto` komandos, perkeliančios vykdymą iš vienos vietos į kitą jūsų „Rails“ kode. Tai _neteisinga_. Jūsų kodas sustoja ir laukia naujos užklausos iš naršyklės. Tiesiog atsitinka, kad jūs pasakėte naršyklei, kokią užklausą ji turėtų atlikti toliau, siųsdami atgal HTTP 302 būsenos kodą.

Norėdami pamatyti skirtumą, apsvarstykite šiuos veiksmus:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

Su šiuo kodu forma, tikriausiai atsiras problema, jei `@book` kintamasis yra `nil`. Atminkite, kad `render :action` nevykdo jokio kodo tiksliniame veiksme, todėl niekas nesukonfigūruos `@books` kintamojo, kurio tikriausiai reikės `index` rodiniui. Vienas būdas tai ištaisyti yra nukreipti vietoj atvaizdavimo:
```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

Su šiuo kodu naršyklė atliks naują užklausą indekso puslapiui, vyks `index` metodo kodas ir viskas bus gerai.

Vienintelis šio kodo trūkumas yra tai, kad jis reikalauja kelionės į naršyklę: naršyklė paprašė parodyti veiksmą su `/books/1` ir valdiklis nustato, kad knygų nėra, todėl valdiklis išsiunčia 302 nukreipimo atsaką į naršyklę, nurodydamas jam eiti į `/books/`, naršyklė tai padaro ir siunčia naują užklausą atgal į valdiklį, šį kartą jau prašydama `index` veiksmo, valdiklis tada gauna visas knygas duomenų bazėje ir atvaizduoja indekso šabloną, siunčiant jį atgal į naršyklę, kuri jį rodo ekrane.

Nors mažame taikyme šis papildomas delsimas gali nebūti problema, tai verta apsvarstyti, jei reikia greito atsako laiko. Galime parodyti vieną būdą tai tvarkyti su sukonstruotu pavyzdžiu:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "Jūsų knyga nerasta"
    render "index"
  end
end
```

Tai aptiktų, kad nėra knygų su nurodytu ID, užpildytų `@books` kintamąjį visomis knygomis modelyje ir tiesiogiai atvaizduotų `index.html.erb` šabloną, grąžindamas jį naršyklei su informaciniu pranešimu, kuris pasakytų vartotojui, kas nutiko.

### Naudodami `head` norint sukurti tik antraštes

[`head`][] metodas gali būti naudojamas siųsti naršyklei tik antraštes turinčius atsakymus. `head` metodas priima skaičių arba simbolį (žr. [nuorodų lentelę](#the-status-option)), kuris nurodo HTTP būsenos kodą. Parametrai interpretuojami kaip antraščių pavadinimų ir reikšmių hainas. Pavyzdžiui, galite grąžinti tik klaidos antraštę:

```ruby
head :bad_request
```

Tai sukurtų šią antraštę:

```http
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Arba galite naudoti kitas HTTP antraštes, kad perduotumėte kitą informaciją:

```ruby
head :created, location: photo_path(@photo)
```

Kas sukurtų:

```http
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Maketavimo išdėstymas
-------------------

Kai „Rails“ atvaizduoja rodinį kaip atsaką, jis tai daro derindamas rodinį su esamu išdėstymu, naudodamas taisykles, kurios buvo aptartos anksčiau šiame vadove. Išdėstyme turite tris įrankius, skirtus sujungti skirtingus išvesties gabalus, kad sudarytumėte visą atsaką:

* Turtų žymos
* `yield` ir [`content_for`][]
* Daliniai

### Turtų žymių pagalbininkai

Turtų žymių pagalbininkai teikia metodus, skirtus generuoti HTML, kuris susieja rodinius su kanalais, „JavaScript“, stiliaus lapais, vaizdais, vaizdo įrašais ir garso įrašais. „Rails“ yra šeši turtų žymių pagalbininkai:

* [`auto_discovery_link_tag`][]
* [`javascript_include_tag`][]
* [`stylesheet_link_tag`][]
* [`image_tag`][]
* [`video_tag`][]
* [`audio_tag`][]

Galite naudoti šias žymes išdėstyme ar kituose rodiniuose, nors `auto_discovery_link_tag`, `javascript_include_tag` ir `stylesheet_link_tag` dažniausiai naudojami išdėstymo `<head>` skyriuje.

ĮSPĖJIMAS: Turtų žymių pagalbininkai _ne_ patikrina, ar turinys yra nurodytose vietose; jie tiesiog priima, kad žinote, ką darote, ir generuoja nuorodą.

#### Kanalų susiejimas su `auto_discovery_link_tag`

[`auto_discovery_link_tag`][] pagalbininkas sukuria HTML, kurį dauguma naršyklių ir kanalų skaitytuvų gali naudoti, kad aptiktų RSS, Atom ar JSON kanalų buvimą. Jis priima nuorodos tipo (`:rss`, `:atom` ar `:json`), nuorodų generavimui perduodamų parinkčių hainą ir žymos parinkčių hainą:

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS kanalas"}) %>
```

`auto_discovery_link_tag` yra trys žymos parinktys:

* `:rel` nurodo `rel` reikšmę nuorodoje. Numatytoji reikšmė yra „alternate“.
* `:type` nurodo aiškų MIME tipą. „Rails“ automatiškai sugeneruos tinkamą MIME tipą.
* `:title` nurodo nuorodos pavadinimą. Numatytoji reikšmė yra didžiosiomis raidėmis rašytas `:type` pavadinimas, pvz., „ATOM“ arba „RSS“.
#### Susiejimas su JavaScript failais naudojant `javascript_include_tag`

[`javascript_include_tag`][] pagalbininkas grąžina HTML `script` žymą kiekvienam pateiktam šaltiniui.

Jei naudojate „Rails“ su įjungtu [Asset Pipeline](asset_pipeline.html), šis pagalbininkas sugeneruos nuorodą į `/assets/javascripts/`, o ne į `public/javascripts`, kuris buvo naudojamas ankstesnėse „Rails“ versijose. Ši nuoroda tada yra aptarnaujama turinio kanalu.

JavaScript failas „Rails“ aplikacijoje ar „Rails“ variklyje yra vienoje iš trijų vietų: `app/assets`, `lib/assets` arba `vendor/assets`. Šios vietos išsamiai paaiškinamos [Asset Organization](asset_pipeline.html#asset-organization) skyriuje „Asset Pipeline Guide“.

Galite nurodyti visą kelią, susijusį su dokumento šaknimi, arba URL, jei pageidaujate. Pavyzdžiui, norėdami susieti su JavaScript failu, kuris yra kataloge, vadinamame `javascripts`, esančiame viename iš `app/assets`, `lib/assets` ar `vendor/assets`, tai padarytumėte taip:

```erb
<%= javascript_include_tag "main" %>
```

Tada „Rails“ išvestų `script` žymą, panašią į šią:

```html
<script src='/assets/main.js'></script>
```

Užklausa šiam turiniui tada yra aptarnaujama „Sprockets“ grotuvu.

Norėdami įtraukti kelis failus, pvz., `app/assets/javascripts/main.js` ir `app/assets/javascripts/columns.js`, tuo pačiu metu:

```erb
<%= javascript_include_tag "main", "columns" %>
```

Norėdami įtraukti `app/assets/javascripts/main.js` ir `app/assets/javascripts/photos/columns.js`:

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

Norėdami įtraukti `http://example.com/main.js`:

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### Susiejimas su CSS failais naudojant `stylesheet_link_tag`

[`stylesheet_link_tag`][] pagalbininkas grąžina HTML `<link>` žymą kiekvienam pateiktam šaltiniui.

Jei naudojate „Rails“ su įjungtu „Asset Pipeline“, šis pagalbininkas sugeneruos nuorodą į `/assets/stylesheets/`. Ši nuoroda tada yra apdorojama „Sprockets“ grotuvu. Stilių lapo failas gali būti saugomas vienoje iš trijų vietų: `app/assets`, `lib/assets` arba `vendor/assets`.

Galite nurodyti visą kelią, susijusį su dokumento šaknimi, arba URL. Pavyzdžiui, norėdami susieti su stilių lapo failu, kuris yra kataloge, vadinamame `stylesheets`, esančiame viename iš `app/assets`, `lib/assets` ar `vendor/assets`, tai padarytumėte taip:

```erb
<%= stylesheet_link_tag "main" %>
```

Norėdami įtraukti `app/assets/stylesheets/main.css` ir `app/assets/stylesheets/columns.css`:

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

Norėdami įtraukti `app/assets/stylesheets/main.css` ir `app/assets/stylesheets/photos/columns.css`:

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

Norėdami įtraukti `http://example.com/main.css`:

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

Pagal numatytuosius nustatymus, `stylesheet_link_tag` sukuria nuorodas su `rel="stylesheet"`. Galite pakeisti šį numatytąjį nustatymą, nurodydami tinkamą parinktį (`:rel`):

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### Susiejimas su paveikslėliais naudojant `image_tag`

[`image_tag`][] pagalbininkas sukuria HTML `<img />` žymą nurodytam failui. Pagal numatytuosius nustatymus failai įkeliami iš `public/images`.

ĮSPĖJIMAS: Atkreipkite dėmesį, kad turite nurodyti paveikslėlio plėtinį.

```erb
<%= image_tag "header.png" %>
```

Galite nurodyti kelią į paveikslėlį, jei norite:

```erb
<%= image_tag "icons/delete.gif" %>
```

Galite nurodyti papildomų HTML parinkčių raktų rinkinį:

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

Galite nurodyti alternatyvų tekstą paveikslėliui, kuris bus naudojamas, jei vartotojas naršyklėje išjungė paveikslėlius. Jei nepateikiate alternatyvaus teksto aiškiai, jis pagal numatytuosius nustatymus bus failo pavadinimas, didžiosiomis raidėmis ir be plėtinio. Pavyzdžiui, šie du paveikslėlio žymos grąžintų tą patį kodą:

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

Taip pat galite nurodyti specialų dydžio žymą, formatu "{plotis}x{aukštis}":

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

Be aukščiau minėtų specialių žymių, galite nurodyti paskutinį standartinių HTML parinkčių raktų rinkinį, pvz., `:class`, `:id` arba `:name`:

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### Susiejimas su vaizdo įrašais naudojant `video_tag`

[`video_tag`][] pagalbininkas sukuria HTML5 `<video>` žymą nurodytam failui. Pagal numatytuosius nustatymus failai įkeliami iš `public/videos`.

```erb
<%= video_tag "movie.ogg" %>
```

Sukuria

```erb
<video src="/videos/movie.ogg" />
```

Kaip ir `image_tag`, galite nurodyti kelią, arba absoliutų, arba santykinį `public/videos` katalogo atžvilgiu. Be to, galite nurodyti `size: "#{plotis}x#{aukštis}"` parinktį, kaip ir `image_tag`. Vaizdo žymos taip pat gali turėti bet kurias HTML parinktis, nurodytas pabaigoje (`id`, `class` ir kt.).

Vaizdo žyma taip pat palaiko visus `<video>` HTML parinktis per HTML parinkčių raktų rinkinį, įskaitant:

* `poster: "image_name.png"`, suteikia vaizdą, kuris bus rodomas vietoje vaizdo, kol jis pradeda groti.
* `autoplay: true`, pradeda groti vaizdą įkeliant puslapį.
* `loop: true`, kartojasi vaizdas, kai jis pasiekia pabaigą.
* `controls: true`, suteikia naršyklės pateiktus valdiklius, kad vartotojas galėtų sąveikauti su vaizdu.
* `autobuffer: true`, vaizdas iš anksto įkeliamas vartotojui įkeliant puslapį.
Jūs taip pat galite nurodyti kelis vaizdo įrašus, kuriuos norite paleisti, perduodami vaizdo įrašų masyvą į `video_tag`:

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

Tai sukurs:

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### Nuoroda į garso failus naudojant `audio_tag`

[`audio_tag`][] pagalbininkas sukuria HTML5 `<audio>` žymą nurodytam failui. Pagal numatytuosius nustatymus failai įkeliami iš `public/audios`.

```erb
<%= audio_tag "music.mp3" %>
```

Galite pateikti kelią į garso failą, jei norite:

```erb
<%= audio_tag "music/first_song.mp3" %>
```

Taip pat galite pateikti papildomų parinkčių raktų rinkinį, pvz., `:id`, `:class`, ir kt.

Kaip ir `video_tag`, `audio_tag` turi specialias parinktis:

* `autoplay: true`, pradeda groti garso failą įkeliant puslapį
* `controls: true`, suteikia naršyklės teikiamus valdiklius, kad vartotojas galėtų sąveikauti su garso failu.
* `autobuffer: true`, garso failas bus iš anksto įkeltas vartotojui įkeliant puslapį.

### Supratimas apie `yield`

Išdėstymo kontekste `yield` nurodo vietą, kurioje turinys iš vaizdo turėtų būti įterptas. Paprasčiausias būdas tai padaryti yra turėti vieną `yield`, į kurį įterpiamas viso šiuo metu atvaizduojamo vaizdo turinys:

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

Taip pat galite sukurti išdėstymą su keliais `yield` regionais:

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

Pagrindinė vaizdo dalis visada bus atvaizduojama bevardžiame `yield`. Norėdami atvaizduoti turinį įvardintame `yield`, naudokite `content_for` metodą.

### Naudodami `content_for` metodą

[`content_for`][] metodas leidžia įterpti turinį į vardintą `yield` bloką jūsų išdėstyme. Pavyzdžiui, šis vaizdas veiktų su ką tik matytu išdėstymu:

```html+erb
<% content_for :head do %>
  <title>Paprastas puslapis</title>
<% end %>

<p>Sveiki, "Rails"!</p>
```

Šio puslapio atvaizdavimo rezultatas su pateiktu išdėstymu būtų šis HTML:

```html+erb
<html>
  <head>
  <title>Paprastas puslapis</title>
  </head>
  <body>
  <p>Sveiki, "Rails"!</p>
  </body>
</html>
```

`content_for` metodas labai naudingas, kai jūsų išdėstyme yra atskiri regionai, tokie kaip šoninės juostos ir poraštės, į kurias turėtų būti įterpti jų pačių turinio blokai. Tai taip pat naudinga įterpti žymes, kurios įkelia puslapio specifinius JavaScript ar CSS failus į pats išdėstymo antraštės dalį.

### Naudodami dalinius šablonus

Dalinių šablonų - paprastai tiesiog vadinamų "dalimis" - yra dar vienas įrankis, skirtas padalinti atvaizdavimo procesą į lengviau valdomus gabalus. Su dalimi galite perkelti kodo, skirtą konkretaus atsakymo dalies atvaizdavimui, į savo atskirą failą.

#### Dalinių pavadinimai

Norėdami atvaizduoti dalį kaip dalį vaizdo, naudokite [`render`][view.render] metodą vaizde:

```html+erb
<%= render "menu" %>
```

Tai atvaizduos failą, pavadinimu `_menu.html.erb`, toje vietoje, kurioje atvaizduojamas šis vaizdas. Pastebėkite pradžioje esantį pabraukimo ženklą: dalys yra pavadinamos su pradiniu pabraukimo ženklu, kad jas būtų galima atskirti nuo įprastų vaizdų, nors joms nurodoma be pabraukimo ženklo. Tai taip pat galioja net tada, kai įkeliate dalį iš kitos aplanko:

```html+erb
<%= render "shared/menu" %>
```

Tas kodas įkelia dalį iš `app/views/shared/_menu.html.erb`.


#### Dalinių naudojimas, siekiant supaprastinti vaizdus

Vienas būdas naudoti dalis yra traktuoti jas kaip subrutinas: kaip būdą perkelti detales iš vaizdo, kad galėtumėte lengviau suprasti, kas vyksta. Pavyzdžiui, jūsų vaizdas galėtų atrodyti taip:

```erb
<%= render "shared/ad_banner" %>

<h1>Produktai</h1>

<p>Čia yra keletas mūsų puikių produktų:</p>
...

<%= render "shared/footer" %>
```

Čia `_ad_banner.html.erb` ir `_footer.html.erb` dalys galėtų turėti turinį, kuris bendrinamas daugelyje jūsų programos puslapių. Kai koncentruojatės į konkretų puslapį, jums nereikia matyti šių dalių detalių.

Kaip matyta ankstesniuose šio vadovo skyriuose, `yield` yra labai galingas įrankis, skirtas išvalyti jūsų išdėstymus. Atminkite, kad tai yra grynasis "Ruby", todėl jį galite naudoti beveik visur. Pavyzdžiui, galime jį naudoti, siekdami sumažinti formos išdėstymo apibrėžimus keliose panašiose išteklių apibrėžimuose:

* `users/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Vardas turi būti: <%= form.text_field :name_contains %>
      </p>
    <% end %>
    ```

* `roles/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Pavadinimas turi būti: <%= form.text_field :title_contains %>
      </p>
    <% end %>
    ```
* `shared/_search_filters.html.erb`

    ```html+erb
    <%= form_with model: search do |form| %>
      <h1>Paieškos forma:</h1>
      <fieldset>
        <%= yield form %>
      </fieldset>
      <p>
        <%= form.submit "Ieškoti" %>
      </p>
    <% end %>
    ```

PATARIMAS: Jei turinys bendras visose jūsų programos puslapiuose, galite tiesiogiai naudoti dalinius iš maketų.

#### Dalinių maketai

Daliniui galima naudoti savo maketo failą, kaip ir peržiūrai. Pavyzdžiui, galite iškviesti dalinį taip:

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

Tai ieškos dalinio pavadinimu `_link_area.html.erb` ir jį atvaizduos naudodamas maketą `_graybar.html.erb`. Atkreipkite dėmesį, kad dalinių maketams taikoma taisyklė dėl priešakyje esančio pabraukimo, kaip ir įprastiems daliniams, ir jie dedami į tą pačią aplanką su daliniu, kuriam jie priklauso (ne į pagrindinį `layouts` aplanką).

Taip pat atkreipkite dėmesį, kad būtina aiškiai nurodyti `:partial`, kai perduodamos papildomos parinktys, pvz., `:layout`.

#### Vietinės kintamosios perdavimas

Taip pat galite perduoti vietines kintamąsias į dalinius, padarant juos dar galingesnius ir lankstesnius. Pavyzdžiui, galite naudoti šią techniką, kad sumažintumėte dublikavimą tarp naujo ir redagavimo puslapių, išlaikant šiek tiek skirtingo turinio:

* `new.html.erb`

    ```html+erb
    <h1>Nauja zona</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>Redaguojama zona</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```html+erb
    <%= form_with model: zone do |form| %>
      <p>
        <b>Zonos pavadinimas</b><br>
        <%= form.text_field :name %>
      </p>
      <p>
        <%= form.submit %>
      </p>
    <% end %>
    ```

Nors tas pats dalinis bus atvaizduojamas abiejuose rodiniuose, veiksmo rodinio `submit` pagalbininkas grąžins "Sukurti zoną" naujam veiksmui ir "Atnaujinti zoną" redagavimo veiksmui.

Norėdami perduoti vietinę kintamąją tik tam tikrais atvejais, naudokite `local_assigns`.

* `index.html.erb`

    ```erb
    <%= render user.articles %>
    ```

* `show.html.erb`

    ```erb
    <%= render article, full: true %>
    ```

* `_article.html.erb`

    ```erb
    <h2><%= article.title %></h2>

    <% if local_assigns[:full] %>
      <%= simple_format article.body %>
    <% else %>
      <%= truncate article.body %>
    <% end %>
    ```

Taip galima naudoti dalinį be visų vietinių kintamųjų deklaravimo.

Kiekvienas dalinis taip pat turi vietinę kintamąją su tuo pačiu pavadinimu kaip dalinis (be priešakyje esančio pabraukimo). Į šią vietinę kintamąją galite perduoti objektą per `:object` parinktį:

```erb
<%= render partial: "customer", object: @new_customer %>
```

Daliniui `customer` šaltinyje, `customer` kintamasis bus nuoroda į `@new_customer` iš pagrindinio rodinio.

Jei turite modelio pavyzdį, kurį norite atvaizduoti dalinyje, galite naudoti trumpinį sintaksę:

```erb
<%= render @customer %>
```

Priimant, kad `@customer` kintamasis yra `Customer` modelio pavyzdys, tai naudos `_customer.html.erb` jį atvaizduoti ir perduos vietinę kintamąją `customer` į dalinį, kuriame bus nuoroda į `@customer` kintamąjį pagrindiniame rodinyje.

#### Rodomų kolekcijų atvaizdavimas

Daliniai yra labai naudingi atvaizduojant kolekcijas. Kai perduodate kolekciją į dalinį per `:collection` parinktį, dalinis bus įterptas kiekvienam kolekcijos nariui:

* `index.html.erb`

    ```html+erb
    <h1>Produktai</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>Produkto pavadinimas: <%= product.name %></p>
    ```

Kai dalinis yra iškviestas su daugiskaitos kolekcija, tada atskiriems dalinio pavyzdžiams prieinama kolekcijos narys per kintamąjį, kurio pavadinimas atitinka dalinio pavadinimą. Šiuo atveju dalinis yra `_product`, ir `_product` dalinyje galite naudoti `product`, kad gautumėte atvaizduojamą pavyzdį.

Yra ir trumpinys šiam tikslui. Priimant, kad `@products` yra `Product` pavyzdžių kolekcija, galite tiesiog parašyti tai `index.html.erb`, kad gautumėte tą patį rezultatą:

```html+erb
<h1>Produktai</h1>
<%= render @products %>
```

Rails nustato dalinio pavadinimą, žiūrėdamas modelio pavadinimą kolekcijoje. Iš tikrųjų, netgi galite sukurti heterogeninę kolekciją ir atvaizduoti ją šiuo būdu, ir Rails pasirinks tinkamą dalinį kiekvienam kolekcijos nariui:

* `index.html.erb`

    ```html+erb
    <h1>Kontaktai</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    ```

* `customers/_customer.html.erb`

    ```html+erb
    <p>Klientas: <%= customer.name %></p>
    ```

* `employees/_employee.html.erb`

    ```html+erb
    <p>Darbuotojas: <%= employee.name %></p>
    ```

Šiuo atveju Rails naudos kliento arba darbuotojo dalinius, kaip tinkama kiekvienam kolekcijos nariui.
Jei kolekcija yra tuščia, `render` grąžins `nil`, todėl paprasta pateikti alternatyvų turinį.

```html+erb
<h1>Produktai</h1>
<%= render(@products) || "Nėra produktų." %>
```

#### Vietinės kintamosios

Norėdami naudoti pasirinktinį vietinį kintamąjį daliniame, nurodykite `:as` parinktį dalinio iškvietime:

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

Padarius šį pakeitimą, dalinio viduje galite pasiekti `@products` kolekcijos egzempliorių kaip `item` vietinį kintamąjį.

Taip pat galite perduoti bet kokias vietines kintamąsias bet kuriam daliniui, kurį renderinate, naudodami `locals: {}` parinktį:

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "Produktų puslapis"} %>
```

Šiuo atveju dalinis turės prieigą prie vietinės kintamosios `title` su reikšme "Produktų puslapis".

#### Skaitiklio kintamieji

Rails taip pat suteikia skaitiklio kintamąjį daliniui, kurį iškviečia kolekcija. Kintamasis vadinamas dalinio pavadinimu, prie kurio pridedamas `_counter`. Pavyzdžiui, renderinant kolekciją `@products`, dalinis `_product.html.erb` gali pasiekti kintamąjį `product_counter`. Kintamasis indeksuoja, kiek kartų dalinis buvo renderintas uždarame rodinyje, pradedant nuo `0` reikšmės pirmajam renderinimui.

```erb
# index.html.erb
<%= render partial: "product", collection: @products %>
```

```erb
# _product.html.erb
<%= product_counter %> # 0 pirmam produktui, 1 antram produktui...
```

Tai taip pat veikia, kai dalinio pavadinimas yra pakeičiamas naudojant `as:` parinktį. Taigi, jei naudojote `as: :item`, skaitiklio kintamasis būtų `item_counter`.

#### Tarpiklio šablonai

Taip pat galite nurodyti antrą dalinį, kuris bus renderinamas tarp pagrindinių dalinių, naudodami `:spacer_template` parinktį:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails renderins `_product_ruler` dalinį (be jam perduodamų duomenų) tarp kiekvienos poros `_product` dalinių.

#### Kolekcijos dalinio išdėstymai

Renderinant kolekcijas taip pat galima naudoti `:layout` parinktį:

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

Dalinio išdėstymas bus renderinamas kartu su daliniu kiekvienam elementui kolekcijoje. Esamieji objektas ir objekt_counter kintamieji taip pat bus prieinami išdėstyme, taip pat kaip ir dalinyje.

### Naudojant įdėtus išdėstymus

Gali būti, kad jūsų programa reikalauja išdėstymo, kuris šiek tiek skiriasi nuo įprasto programos išdėstymo, kad palaikytų vieną konkretų valdiklį. Vietoje pagrindinio išdėstymo kartojimo ir redagavimo, tai galite pasiekti naudodami įdėtus išdėstymus (kartais vadinamus sub-šablonais). Štai pavyzdys:

Tarkime, turite šį `ApplicationController` išdėstymą:

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "Puslapio pavadinimas" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">Viršutinio meniu elementai čia</div>
      <div id="menu">Meniu elementai čia</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

Puslapiuose, kurie generuojami naudojant `NewsController`, norite paslėpti viršutinį meniu ir pridėti dešinį meniu:

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">Dešinio meniu elementai čia</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

Tai viskas. Nauji rodiniai naudos naują išdėstymą, paslėpdami viršutinį meniu ir pridedami naują dešinį meniu "content" div'e.

Šia technika galima pasiekti panašių rezultatų su skirtingais sub-šablonų schemomis. Atkreipkite dėmesį, kad nėra ribos įdėtų lygių. Vienas gali naudoti `ActionView::render` metodą per `render template: 'layouts/news'`, kad pagrindytų naują išdėstymą pagal News išdėstymą. Jei esate tikri, kad nenaudosite sub-šablono `News` išdėstymo, galite pakeisti `content_for?(:news_content) ? yield(:news_content) : yield` tiesiog `yield`.
[controller.render]: https://api.rubyonrails.org/classes/ActionController/Rendering.html#method-i-render
[`redirect_to`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to
[`head`]: https://api.rubyonrails.org/classes/ActionController/Head.html#method-i-head
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`redirect_back`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_back
[`content_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for
[`auto_discovery_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-auto_discovery_link_tag
[`javascript_include_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-javascript_include_tag
[`stylesheet_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-stylesheet_link_tag
[`image_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag
[`video_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-video_tag
[`audio_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-audio_tag
[view.render]: https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render
