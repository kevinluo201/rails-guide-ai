**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37d2486eee8522a64c5f97f86900b8a6
Veiksmų peržiūros pagalbininkai
====================

Po šio vadovo perskaitymo žinosite:

* Kaip formatuoti datos, eilutes ir skaičius
* Kaip sukurti nuorodas į paveikslėlius, vaizdo įrašus, stilių lapus ir kt.
* Kaip apsaugoti turinį
* Kaip lokalizuoti turinį

--------------------------------------------------------------------------------

Veiksmų peržiūros teikiamų pagalbinių priemonių apžvalga
-------------------------------------------

WIP: Čia nėra išvardintos visos pagalbinės priemonės. Visą sąrašą rasite [API dokumentacijoje](https://api.rubyonrails.org/classes/ActionView/Helpers.html)

Šiame sąraše pateikiama tik trumpa pagalbinių priemonių, kurias teikia veiksmų peržiūra, apžvalga. Rekomenduojama perskaityti [API dokumentaciją](https://api.rubyonrails.org/classes/ActionView/Helpers.html), kurioje išsamiau aprašytos visos pagalbinės priemonės, tačiau tai turėtų būti geras pradžios taškas.

### AssetTagHelper

Šis modulis teikia metodus, skirtus generuoti HTML, kuris susieja peržiūras su turiniais, tokius kaip paveikslėliai, JavaScript failai, stiliaus lapai ir srautai.

Pagal numatymą „Rails“ susieja šiuos turinius su esamu prieglobos serveryje viešajame aplanke, tačiau galite nurodyti „Rails“ susieti turinius iš atskiro turinių serverio, nustatydami [`config.asset_host`][] programos konfigūracijoje, paprastai `config/environments/production.rb`. Pavyzdžiui, sakykime, jūsų turinio prieglobos serverio adresas yra `assets.example.com`:

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```


#### auto_discovery_link_tag

Grąžina nuorodos žymą, kurią naršyklės ir srautų skaitytuvai gali naudoti automatiškai aptikti RSS, Atom arba JSON srautą.

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS srautas" })
# => <link rel="alternate" type="application/rss+xml" title="RSS srautas" href="http://www.example.com/feed.rss" />
```

#### image_path

Apskaičiuoja kelio taką iki paveikslėlio turinio `app/assets/images` aplanke. Pilni keliai nuo dokumento šaknies bus perduoti. Viduje naudojamas `image_tag` norint sukurti paveikslėlio kelią.

```ruby
image_path("edit.png") # => /assets/edit.png
```

Jei `config.assets.digest` nustatytas kaip `true`, prie failo pavadinimo bus pridėtas piršto atspaudas.

```ruby
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

Apskaičiuoja URL adresą iki paveikslėlio turinio `app/assets/images` aplanke. Viduje bus iškviestas `image_path` ir sujungtas su jūsų dabartiniu prieglobos serveriu arba turinio prieglobos serveriu.

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

Grąžina HTML paveikslėlio žymą šaltiniui. Šaltinis gali būti pilnas kelias arba failas, esantis jūsų `app/assets/images` aplanke.

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

Grąžina HTML skripto žymą kiekvienam pateiktam šaltiniui. Galite perduoti JavaScript failo pavadinimą (`.js` plėtinys nėra privalomas), esantį jūsų `app/assets/javascripts` aplanke, norint įtraukti į dabartinį puslapį, arba galite perduoti pilną kelią, susijusį su jūsų dokumento šakne.

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

Apskaičiuoja kelio taką iki JavaScript turinio `app/assets/javascripts` aplanke. Jei šaltinio failo pavadinime nėra plėtinio, bus pridėtas `.js`. Pilni keliai nuo dokumento šaknies bus perduoti. Viduje naudojamas `javascript_include_tag` norint sukurti skripto kelią.

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

Apskaičiuoja URL adresą iki JavaScript turinio `app/assets/javascripts` aplanke. Viduje bus iškviestas `javascript_path` ir sujungtas su jūsų dabartiniu prieglobos serveriu arba turinio prieglobos serveriu.

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

Grąžina stiliaus lapo žymą, skirtą pateikti nurodytiems šaltiniams. Jei nenurodytas plėtinys, automatiškai bus pridėtas `.css`.

```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" rel="stylesheet" />
```

#### stylesheet_path

Apskaičiuoja kelio taką iki stiliaus lapo turinio `app/assets/stylesheets` aplanke. Jei šaltinio failo pavadinime nėra plėtinio, bus pridėtas `.css`. Pilni keliai nuo dokumento šaknies bus perduoti. Viduje naudojamas `stylesheet_link_tag` norint sukurti stiliaus lapo kelią.

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

Apskaičiuoja URL adresą iki stiliaus lapo turinio `app/assets/stylesheets` aplanke. Viduje bus iškviestas `stylesheet_path` ir sujungtas su jūsų dabartiniu prieglobos serveriu arba turinio prieglobos serveriu.

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

Ši pagalbinė priemonė padeda lengvai sukurti Atom srautą. Štai pilnas naudojimo pavyzdys:

**config/routes.rb**

```ruby
resources :articles
```

**app/controllers/articles_controller.rb**

```ruby
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```ruby
atom_feed do |feed|
  feed.title("Straipsnių indeksas")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

### BenchmarkHelper

#### benchmark

Leidžia matuoti šablone vykdomo bloko vykdymo laiką ir rezultatą įrašyti į žurnalą. Apvyniokite šį bloką aplink brangius veiksmus ar galimus darbotvarkės taškus, kad gautumėte laiko rodiklį operacijai.
```html+erb
<% benchmark "Apdoroti duomenų failus" do %>
  <%= expensive_files_operation %>
<% end %>
```

Tai pridėtų kažką panašaus į "Apdoroti duomenų failus (0.34523)" į žurnalą, kurį galite naudoti palyginimui optimizuojant savo kodą.

### CacheHelper

#### cache

Metodas, skirtas talpinti dalis peržiūros, o ne visą veiksmą ar puslapį. Ši technika naudinga talpinant meniu, naujienų temų sąrašus, statinius HTML fragmentus ir t.t. Šis metodas priima bloką, kuriame yra turinys, kurį norite talpinti. Daugiau informacijos rasite `AbstractController::Caching::Fragments`.

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

`capture` metodas leidžia išgauti dalį šablono į kintamąjį. Tada šį kintamąjį galite naudoti bet kurioje šablono ar maketo vietoje.

```html+erb
<% @greeting = capture do %>
  <p>Sveiki! Dabartinė data ir laikas: <%= Time.now %></p>
<% end %>
```

Išgautas kintamasis gali būti naudojamas bet kur kitur.

```html+erb
<html>
  <head>
    <title>Sveiki!</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### content_for

Kviečiant `content_for`, bloko žymės žymės dalis saugoma identifikatoriui vėlesniam naudojimui. Galite padaryti kitus kvietimus saugotam turiniui kituose šablonuose ar maketuose, perduodant identifikatorių kaip argumentą `yield`.

Pavyzdžiui, tarkime, turime standartinį aplikacijos maketą, bet taip pat yra speciali puslapis, kuriam reikalingas tam tikras JavaScript, kurio kitos svetainės dalys nereikia. Galime naudoti `content_for`, kad šis JavaScript būtų įtrauktas į mūsų specialų puslapį, nepadidinant kitos svetainės.

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>Sveiki!</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Sveiki! Dabartinė data ir laikas: <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>Tai yra specialus puslapis.</p>

<% content_for :special_script do %>
  <script>alert('Labas!')</script>
<% end %>
```

### DateHelper

#### distance_of_time_in_words

Praneša apie apytikslį laiko intervalą tarp dviejų `Time` ar `Date` objektų arba sveikųjų skaičių sekundėmis. Jei norite gauti išsamesnes apytikslės vertinimo reikšmes, nustatykite `include_seconds` į `true`.

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => mažiau nei minutė
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => mažiau nei 20 sekundžių
```

#### time_ago_in_words

Panašiai kaip `distance_of_time_in_words`, bet `to_time` fiksuotas į `Time.now`.

```ruby
time_ago_in_words(3.minutes.from_now) # => 3 minutes
```

### DebugHelper

Grąžina `pre` žymę, kurioje yra YAML išspausdintas objektas. Tai sukuria labai skaitymą būdą patikrinti objektą.

```ruby
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1, 2, 3] }
debug(my_hash)
```

```html
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

### FormHelper

Formos pagalbininkai skirti palengvinti darbą su modeliais, palyginti su naudojant tik standartinius HTML elementus, teikiant rinkinį metodų formų kūrimui pagal jūsų modelius. Šis pagalbininkas generuoja HTML formų kodą, teikdamas metodą kiekvienai įvesties rūšiai (pvz., tekstui, slaptažodžiui, pasirinkimui ir t.t.). Kai forma yra pateikiama (t.y., kai naudotojas spusteli pateikimo mygtuką arba forma.pateikti yra iškviesta per JavaScript), formos įvestys bus supakuotos į params objektą ir perduotos kontroleriui.

Daugiau apie formos pagalbininkus galite sužinoti [Action View Form Helpers vadove](form_helpers.html).

### JavaScriptHelper

Suteikia funkcionalumą dirbti su JavaScript savo rodiniuose.

#### escape_javascript

Pakeičia kirtiklius, viengubas ir dvigubas kabutes JavaScript segmentams.

#### javascript_tag

Grąžina JavaScript žymą, apgaubiančią pateiktą kodą.

```ruby
javascript_tag "alert('Viskas gerai')"
```

```html
<script>
//<![CDATA[
alert('Viskas gerai')
//]]>
</script>
```

### NumberHelper

Suteikia metodus skaičių formatavimui į formatuotus eilutes. Yra metodai telefono numeriams, valiutai, procentams, tikslumui, poziciniam žymėjimui ir failo dydžiui.

#### number_to_currency

Formatuoja skaičių į valiutos eilutę (pvz., $13.65).

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### number_to_human

Gražiai spausdina (formatuoja ir apytiksliai) skaičių, kad jį būtų lengviau skaityti naudotojams; naudinga skaičiams, kurie gali tapti labai dideli.

```ruby
number_to_human(1234)    # => 1.23 Tūkstantis
number_to_human(1234567) # => 1.23 Milijonas
```

#### number_to_human_size

Formatuoja baitus į suprantamesnį atvaizdavimą; naudinga pranešant failų dydžius naudotojams.

```ruby
number_to_human_size(1234)    # => 1.21 KB
number_to_human_size(1234567) # => 1.18 MB
```

#### number_to_percentage

Formatuoja skaičių kaip procentinę eilutę.
```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

Formuoja numerį į telefono numerį (pagal nutylėjimą - JAV).

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

Formuoja numerį su grupuotais tūkstančiais naudojant skyriklį.

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

Formuoja numerį su nurodytu `precision` lygiu, kuris pagal nutylėjimą yra 3.

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

SanitizeHelper modulis teikia rinkinį metodų teksto valymui nuo nepageidaujamų HTML elementų.

#### sanitize

Šis sanitize pagalbininkas užkoduoja visas žymes ir pašalina visas savybes, kurios nėra išvardytos.

```ruby
sanitize @article.body
```

Jei perduodami `:attributes` arba `:tags` parametrai, leidžiamos tik nurodytos savybės ir žymės, o nieko kito.

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

Norint pakeisti numatytuosius parametrus daugkartiniam naudojimui, pvz., pridėti lentelės žymes prie numatytųjų:

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

Valo CSS kodo bloką.

#### strip_links(html)

Pašalina visus nuorodų žymes iš teksto, paliekant tik nuorodos tekstą.

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('emails to <a href="mailto:me@email.com">me@email.com</a>.')
# => emails to me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visit</a>.')
# => Blog: Visit.
```

#### strip_tags(html)

Pašalina visus HTML žymes iš teksto, įskaitant komentarus.
Ši funkcija veikia naudojant rails-html-sanitizer gemą.

```ruby
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!
```

```ruby
strip_tags("<b>Bold</b> no more!  <a href='more.html'>See more</a>")
# => Bold no more!  See more
```

NB: Išvestis gali vis dar turėti neištrintus '<', '>', '&' simbolius, kurie gali painioti naršykles.

### UrlHelper

Suteikia metodus, skirtus kurti nuorodas ir gauti URL, priklausančius maršrutizavimo posistemai.

#### url_for

Grąžina URL, pagal pateiktus `options`.

##### Pavyzdžiai

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

Nuoroda į URL, gautą iš `url_for`. Daugiausia naudojama
kurti RESTful resursų nuorodas, kurios šiuo pavyzdžiu sumažėja
iki modelių perdavimo `link_to`.

**Pavyzdžiai**

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>
```

Taip pat galite naudoti bloką, jei jūsų nuorodos tikslas negali tilpti į pavadinimo parametrą. ERB pavyzdys:

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
<% end %>
```

rezultatas būtų:

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Check it out!</span>
</a>
```

Daugiau informacijos rasite [API dokumentacijoje](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)

#### button_to

Generuoja formą, kuri siunčiama į perduotą URL. Formoje yra pateikimo mygtukas
su nurodytu `name` reikšme.

##### Pavyzdžiai

```html+erb
<%= button_to "Sign in", sign_in_path %>
```

apie tai būtų išvestis kažkas panašaus į:

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

Daugiau informacijos rasite [API dokumentacijoje](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)

### CsrfHelper

Grąžina meta žymes "csrf-param" ir "csrf-token" su kryžminio svetainės
užklausos sukčiavimo apsaugos parametro ir žetono pavadinimu atitinkamai.

```html
<%= csrf_meta_tags %>
```

PASTABA: Įprastos formos generuoja paslėptus laukus, todėl jos nenaudoja šių žymių. Daugiau
informacijos rasite [Rails saugumo vadove](security.html#cross-site-request-forgery-csrf).
[`config.asset_host`]: configuring.html#config-asset-host
