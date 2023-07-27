**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3cf93e3667cdacd242332d2d352d53fa
Rails aplikacijų derinimas
============================

Šis vadovas pristato technikas, skirtas derinti Ruby on Rails aplikacijas.

Po šio vadovo perskaitymo žinosite:

* Derinimo tikslą.
* Kaip rasti problemas ir klaidas savo aplikacijoje, kurias jūsų testai neidentifikuoja.
* Skirtingus derinimo būdus.
* Kaip analizuoti steko seką.

--------------------------------------------------------------------------------

Vaizdo pagalbininkai derinimui
--------------------------

Viena iš dažnų užduočių yra tikrinti kintamojo turinį. Rails suteikia tris skirtingus būdus tai padaryti:

* `debug`
* `to_yaml`
* `inspect`

### `debug`

`debug` pagalbininkas grąžins \<pre> žymą, kuri atvaizduos objektą naudojant YAML formatą. Tai sugeneruos žmogui skaitymą informaciją iš bet kurio objekto. Pavyzdžiui, jei turite šį kodą peržiūroje:

```html+erb
<%= debug @article %>
<p>
  <b>Pavadinimas:</b>
  <%= @article.title %>
</p>
```

Matysite kažką panašaus į tai:

```yaml
--- !ruby/object Article
attributes:
  updated_at: 2008-09-05 22:55:47
  body: Tai yra labai naudingas vadovas derinant jūsų Rails aplikaciją.
  title: Rails derinimo vadovas
  published: t
  id: "1"
  created_at: 2008-09-05 22:55:47
attributes_cache: {}


Pavadinimas: Rails derinimo vadovas
```

### `to_yaml`

Alternatyviai, iškvietus `to_yaml` bet kuriam objektui, jis bus konvertuotas į YAML formatą. Šį konvertuotą objektą galite perduoti į `simple_format` pagalbininko metodą, kad formatuotumėte išvestį. Taip veikia `debug` pagalbininkas.

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>Pavadinimas:</b>
  <%= @article.title %>
</p>
```

Pirmiau pateiktas kodas atvaizduos kažką panašaus į tai:

```yaml
--- !ruby/object Article
attributes:
updated_at: 2008-09-05 22:55:47
body: Tai yra labai naudingas vadovas derinant jūsų Rails aplikaciją.
title: Rails derinimo vadovas
published: t
id: "1"
created_at: 2008-09-05 22:55:47
attributes_cache: {}

Pavadinimas: Rails derinimo vadovas
```

### `inspect`

Kitas naudingas metodas, skirtas rodyti objekto reikšmes, yra `inspect`, ypač dirbant su masyvais arba hash'ais. Tai atspausdins objekto reikšmę kaip eilutę. Pavyzdžiui:

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Pavadinimas:</b>
  <%= @article.title %>
</p>
```

Atvaizduos:

```
[1, 2, 3, 4, 5]

Pavadinimas: Rails derinimo vadovas
```

Žurnalizatorius
----------

Taip pat gali būti naudinga išsaugoti informaciją į žurnalo failus vykdymo metu. Rails palaiko atskirą žurnalo failą kiekvienam vykdymo aplinkos tipui.

### Kas yra žurnalizatorius?

Rails naudoja `ActiveSupport::Logger` klasę, kad rašytų žurnalo informaciją. Kitus žurnalizatorius, pvz., `Log4r`, taip pat galima pakeisti.

Galite nurodyti alternatyvų žurnalizatorių `config/application.rb` arba bet kuriame kitame aplinkos faile, pavyzdžiui:

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

Arba `Initializer` skyriuje pridėkite _bet kurį_ iš šių

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

PATARIMAS: Pagal numatytuosius nustatymus, kiekvienas žurnalas sukuriamas pagal `Rails.root/log/` ir žurnalo failas pavadintas pagal aplinką, kurioje vykdoma aplikacija.

### Žurnalo lygiai

Kai kas nors yra žurnaluojama, tai yra spausdinama į atitinkamą žurnalą, jei žinutės žurnalo lygis yra lygus arba didesnis nei konfigūruotas žurnalo lygis. Jei norite sužinoti dabartinį žurnalo lygį, galite iškviesti `Rails.logger.level` metodą.
Galimi žurnalo lygiai yra: `:debug`, `:info`, `:warn`, `:error`, `:fatal` ir `:unknown`, atitinkamai atitinkantys žurnalo lygio numerius nuo 0 iki 5. Norėdami pakeisti numatytąjį žurnalo lygį, naudokite

```ruby
config.log_level = :warn # bet kurioje aplinkos inicializavimo programoje arba
Rails.logger.level = 0 # bet kuriuo metu
```

Tai naudinga, kai norite žurnaluoti kūrimo arba etapų metu, nes užtvindote savo gamybos žurnalą nereikalinga informacija.

PATARIMAS: Numatytasis „Rails“ žurnalo lygis yra `:debug`. Tačiau numatytuoju sugeneruotuose `config/environments/production.rb` failuose jis nustatomas į `:info` `production` aplinkoje.

### Pranešimų siuntimas

Norėdami rašyti į dabartinį žurnalą, naudokite `logger.(debug|info|warn|error|fatal|unknown)` metodą iš valdiklio, modelio arba pašto siuntėjo:

```ruby
logger.debug "Asmens atributų maišos reikšmės: #{@person.attributes.inspect}"
logger.info "Apdorojama užklausa..."
logger.fatal "Baigiama programa, kilo neatkraunama klaida!!!"
```

Štai pavyzdys, kaip metodas instrumentuotas su papildomu žurnalo įrašymu:

```ruby
class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(article_params)
    logger.debug "Naujas straipsnis: #{@article.attributes.inspect}"
    logger.debug "Straipsnis turėtų būti tinkamas: #{@article.valid?}"

    if @article.save
      logger.debug "Straipsnis buvo išsaugotas ir dabar vartotojas bus nukreiptas..."
      redirect_to @article, notice: 'Straipsnis sėkmingai sukurtas.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ...

  private
    def article_params
      params.require(:article).permit(:title, :body, :published)
    end
end
```

Štai pavyzdys, kaip generuojamas žurnalas, kai vykdoma ši valdiklio veiksmas:

```
Pradėta POST "/articles" užklausa 127.0.0.1 adresui 2018-10-18 20:09:23 -0400
Apdorojama ArticlesController#create kaip HTML
  Parametrai: {"utf8"=>"✓", "authenticity_token"=>"XLveDrKzF1SwaiNRPTaMtkrsTzedtebPPkmxEFIU0ordLjICSnXsSNfrdMa4ccyBjuGwnnEiQhEoMN6H1Gtz3A==", "article"=>{"title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>"0"}, "commit"=>"Create Article"}
Naujas straipsnis: {"id"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>false, "created_at"=>nil, "updated_at"=>nil}
Straipsnis turėtų būti tinkamas: true
   (0.0ms)  begin transaction
  ↳ app/controllers/articles_controller.rb:31
  Article Create (0.5ms)  INSERT INTO "articles" ("title", "body", "published", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["title", "Debugging Rails"], ["body", "I'm learning how to print in logs."], ["published", 0], ["created_at", "2018-10-19 00:09:23.216549"], ["updated_at", "2018-10-19 00:09:23.216549"]]
  ↳ app/controllers/articles_controller.rb:31
   (2.3ms)  commit transaction
  ↳ app/controllers/articles_controller.rb:31
Straipsnis buvo išsaugotas ir dabar vartotojas bus nukreiptas...
Nukreipiama į http://localhost:3000/articles/1
Baigta 302 Found per 4ms (ActiveRecord: 0.8ms)
```

Pridedant papildomą žurnalo įrašymą, lengva ieškoti netikėto ar neįprasto elgesio žurnaluose. Jei pridedate papildomą žurnalo įrašymą, įsitikinkite, kad protingai naudojate žurnalo lygius, kad išvengtumėte savo gamybos žurnalų užpildymo bevertis informacija.

### Išsamūs užklausų žurnalai

Kai žiūrite į duomenų bazės užklausų išvestį žurnaluose, gali nebūti aišku, kodėl vienu metodų iškvietimu sukeliamos kelios duomenų bazės užklausos:

```
irb(main):001:0> Article.pamplemousse
  Article Load (0.4ms)  SELECT "articles".* FROM "articles"
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```
Paleidus `ActiveRecord.verbose_query_logs = true` `bin/rails console` seanso metu, kad įjungtumėte išsamius užklausų žurnalus ir paleidus metodą dar kartą, tampa aišku, kokia viena kodo eilutė generuoja visas šias atskiras duomenų bazės užklausas:

```
irb(main):003:0> Article.pamplemousse
  Article Load (0.2ms)  SELECT "articles".* FROM "articles"
  ↳ app/models/article.rb:5
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
  ↳ app/models/article.rb:6
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

Po kiekvienos duomenų bazės instrukcijos galite pamatyti rodykles, nurodančias konkretaus šaltinio failo pavadinimą (ir eilutės numerį), kuris sukėlė duomenų bazės užklausą. Tai gali padėti jums nustatyti ir išspręsti veikimo problemas, kurias sukelia N+1 užklausos: vienos duomenų bazės užklausos, kurios generuoja daugybę papildomų užklausų.

Išsamūs užklausų žurnalai yra įjungti pagal numatytuosius nustatymus vystymo aplinkos žurnaluose nuo Rails 5.2 versijos.

ĮSPĖJIMAS: Mes rekomenduojame nenaudoti šio nustatymo gamybos aplinkose. Jis remiasi Ruby `Kernel#caller` metodu, kuris dažnai skiria daug atminties, kad sugeneruotų metodų iškvietimų stekus. Vietoj to naudokite užklausų žurnalų žymes (žr. žemiau).

### Išsamūs užklausų įtraukimo žurnalai

Panašiai kaip ir "Išsamūs užklausų žurnalai" aukščiau, leidžia spausdinti metodų, kurie įtraukia fono darbus, šaltinių vietas.

Tai įjungta pagal numatytuosius nustatymus vystymo aplinkoje. Norėdami įjungti kitose aplinkose, pridėkite į `application.rb` arba bet kurį aplinkos inicijuotoją:

```rb
config.active_job.verbose_enqueue_logs = true
```

Kaip ir išsamūs užklausų žurnalai, tai nerekomenduojama naudoti gamybos aplinkose.

SQL užklausų komentarai
------------------

SQL instrukcijos gali būti komentuojamos žymėmis, kuriose yra vykdymo metu gauta informacija, pvz., valdiklio ar darbo pavadinimas, kad būtų galima atsekti problemiškas užklausas iki programos srities, kuri sukūrė šias instrukcijas. Tai naudinga, kai žurnaluojate lėtas užklausas (pvz., [MySQL](https://dev.mysql.com/doc/refman/en/slow-query-log.html), [PostgreSQL](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT)),
peržiūrite šiuo metu vykdomas užklausas arba naudojate galutinio taško sekimo įrankius.

Norėdami įjungti, pridėkite į `application.rb` arba bet kurį aplinkos inicijuotoją:

```rb
config.active_record.query_log_tags_enabled = true
```

Pagal numatytuosius nustatymus, įrašomi programos pavadinimas, valdiklio pavadinimas ir veiksmas arba darbo pavadinimas. Numatytasis formatas yra [SQLCommenter](https://open-telemetry.github.io/opentelemetry-sqlcommenter/). Pavyzdžiui:

```
Article Load (0.2ms)  SELECT "articles".* FROM "articles" /*application='Blog',controller='articles',action='index'*/

Article Update (0.3ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ? WHERE "posts"."id" = ? /*application='Blog',job='ImproveTitleJob'*/  [["title", "Improved Rails debugging guide"], ["updated_at", "2022-10-16 20:25:40.091371"], ["id", 1]]
```

[`ActiveRecord::QueryLogs`](https://api.rubyonrails.org/classes/ActiveRecord/QueryLogs.html) elgseną galima
modifikuoti, kad būtų įtraukta bet kokia informacija, padedanti sujungti SQL užklausą, pvz., užklausos ir darbo ID programos žurnaluose, paskyros ir nuomininko identifikatoriai ir t.t.

### Pažymėtos žurnalo įrašymo

Paleidžiant daugelio vartotojų, daugelio paskyrų programas, dažnai naudinga
galėti filtruoti žurnalus naudojant tam tikras taisykles. `TaggedLogging`
Active Support padeda tai padaryti, pridedant žymas prie žurnalo eilučių, pvz., subdomenų, užklausos ID ir bet kokios kitos informacijos, kuri padeda derinti tokių programų derinimą.
```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # Užregistruoja "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # Užregistruoja "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # Užregistruoja "[BCX] [Jason] Stuff"
```

### Žurnalo įtaka našumui

Žurnalo įrašymas visada turi nedidelę įtaką jūsų "Rails" programos našumui,
ypač kai įrašoma į diską. Be to, yra keletas niuansų:

Naudoti `:debug` lygį turės didesnį našumo nuostolį nei `:fatal`,
kadangi į žurnalo išvestį (pvz., į diską) yra vertinami ir rašomi daugiau eilučių.

Kitas potencialus pavojus yra per daug kvietimų į `Logger` savo kode:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

Pavyzdyje aukščiau bus našumo nuostolis, net jei leidžiamas
išvesties lygis neįtraukia derinimo. Priežastis yra ta, kad "Ruby" turi įvertinti
šias eilutes, įskaitant kiek sunkų `String` objektą ir kintamųjų derinimą.

Dėl šios priežasties rekomenduojama perduoti blokus žurnalo metodams, kadangi šie
yra vertinami tik tada, jei išvesties lygis yra tas pats arba įtrauktas į leidžiamą lygį
(t.y. tingus įkėlimas). Tas pats kodas perrašytas būtų:

```ruby
logger.debug { "Person attributes hash: #{@person.attributes.inspect}" }
```

Blokų turinys ir todėl eilučių derinimas yra vertinami tik tada,
kai įgalintas derinimas. Šis našumo taupymas tikrai
pastebimas tik su dideliais žurnalo kiekiais, bet tai gera praktika.

INFORMACIJA: Šiame skyriuje buvo parašyta [Jon Cairns Stack Overflow atsakyme](https://stackoverflow.com/questions/16546730/logging-in-rails-is-there-any-performance-hit/16546935#16546935)
ir jis yra licencijuotas pagal [cc by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

Derinimas su `debug` Gem'u
------------------------------

Kai jūsų kodas elgiasi netikėtais būdais, galite bandyti spausdinti į žurnalą arba
konsolę, kad nustatytumėte problemą. Deja, yra laikų, kai šis
klaidų sekimas nepadeda rasti problemos šaknies priežasties.
Kai jums iš tikrųjų reikia patekti į vykdomąjį šaltinio kodą, derinimo įrankis
yra jūsų geriausias draugas.

Derinimo įrankis taip pat gali jums padėti, jei norite sužinoti apie "Rails" šaltinio kodą,
bet nežinote, nuo ko pradėti. Tiesiog derinkite bet kokį užklausos į savo programą ir
naudokite šį vadovą, kad sužinotumėte, kaip pereiti nuo jūsų parašyto kodo į
pagrindinį "Rails" kodą.

"Rails" 7 įtraukia `debug` gem'ą į naujų CRuby sugeneruotų programų `Gemfile`.
Pagal numatytuosius nustatymus, jis yra pasirengęs `development` ir `test` aplinkose.
Norėdami sužinoti daugiau, patikrinkite jo [dokumentaciją](https://github.com/ruby/debug).

### Įeiti į derinimo seansą

Pagal numatytuosius nustatymus, derinimo seansas prasidės po to, kai yra reikalingas `debug` biblioteka, kas vyksta, kai paleidžiama jūsų programa. Bet nesijaudinkite, seansas nesutrikdys jūsų programos.

Norėdami įeiti į derinimo seansą, galite naudoti `binding.break` ir jo sinonimus: `binding.b` ir `debugger`. Šie pavyzdžiai naudos `debugger`:
```rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    debugger
  end
  # ...
end
```

Kai jūsų programa įvertins derinimo teiginį, ji įeis į derinimo sesiją:

```rb
Processing by PostsController#index as HTML
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  # ir 72 kadrų (naudokite `bt' komandą visiems kadrų)
(rdbg)
```

Derinimo sesiją galite baigti bet kuriuo metu ir tęsti programos vykdymą naudodami `continue` (arba `c`) komandą. Arba, norėdami baigti tiek derinimo sesiją, tiek ir programą, naudokite `quit` (arba `q`) komandą.

### Kontekstas

Įeinant į derinimo sesiją, galite įvesti Ruby kodą taip, tarsi būtumėte "Rails" konsolėje arba "IRB".

```rb
(rdbg) @posts    # ruby
[]
(rdbg) self
#<PostsController:0x0000000000aeb0>
(rdbg)
```

Taip pat galite naudoti `p` arba `pp` komandą, kad įvertintumėte Ruby išraiškas, kas yra naudinga, kai kintamojo pavadinimas sutampa su derinimo komanda.

```rb
(rdbg) p headers    # komanda
=> {"X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "X-Download-Options"=>"noopen", "X-Permitted-Cross-Domain-Policies"=>"none", "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg) pp headers    # komanda
{"X-Frame-Options"=>"SAMEORIGIN",
 "X-XSS-Protection"=>"1; mode=block",
 "X-Content-Type-Options"=>"nosniff",
 "X-Download-Options"=>"noopen",
 "X-Permitted-Cross-Domain-Policies"=>"none",
 "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg)
```

Be tiesioginio įvertinimo, derinimo priemonė taip pat padeda rinkti gausią informaciją naudojant įvairias komandas, pvz.:

- `info` (arba `i`) - Informacija apie dabartinį kadrą.
- `backtrace` (arba `bt`) - Atgalinė sekos (su papildoma informacija).
- `outline` (arba `o`, `ls`) - Galimi metodai, konstantos, vietinės kintamosios ir objekto kintamosios dabartiniame kontekste.

#### `info` komanda

`info` pateikia apžvalgą apie vietinių ir objekto kintamųjų reikšmes, matomas iš dabartinio kadro.

```rb
(rdbg) info    # komanda
%self = #<PostsController:0x0000000000af78>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fd91a037e38 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fd91a03ea08 @mon_data=#<Monitor:0x00007fd91a03e8c8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = []
@rendered_format = nil
```

#### `backtrace` komanda

Kai naudojama be jokių parinkčių, `backtrace` išvardija visus kadrus dėžėje:

```rb
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  #2    AbstractController::Base#process_action(method_name="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/base.rb:214
  #3    ActionController::Rendering#process_action(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/rendering.rb:53
  #4    block in process_action at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/callbacks.rb:221
  #5    block in run_callbacks at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:118
  #6    ActionText::Rendering::ClassMethods#with_renderer(renderer=#<PostsController:0x0000000000af78>) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/rendering.rb:20
  #7    block {|controller=#<PostsController:0x0000000000af78>, action=#<Proc:0x00007fd91985f1c0 /Users/st0012/...|} in <class:Engine> (4 levels) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/engine.rb:69
  #8    [C] BasicObject#instance_exec at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:127
  ..... ir daugiau
```

Kiekvienas kadras turi:

- Kadrą identifikuojantį numerį
- Skambinimo vietą
- Papildomą informaciją (pvz., bloko arba metodo argumentus)
Tai suteiks jums puikų supratimą apie tai, kas vyksta jūsų programoje. Tačiau tikriausiai pastebėsite, kad:

- Yra per daug rėmelių (dažniausiai 50+ "Rails" programoje).
- Dauguma rėmelių yra iš "Rails" ar kitų naudojamų bibliotekų.

`backtrace` komanda suteikia 2 parinktis, padedančias filtruoti rėmelius:

- `backtrace [num]` - rodo tik `num` rėmelius, pvz., `backtrace 10`.
- `backtrace /raštas/` - rodo tik rėmelius, kurių identifikatorius ar vieta atitinka raštą, pvz., `backtrace /ManoModelis/`.

Taip pat galima naudoti šias parinktis kartu: `backtrace [num] /raštas/`.

#### `outline` komanda

`outline` panaši į `pry` ir `irb` `ls` komandas. Ji parodys, kas yra pasiekiamo iš dabartinio taikinio, įskaitant:

- Vietinės kintamąsias
- Egzemplioriaus kintamąsias
- Klasės kintamąsias
- Metodus ir jų šaltinius

```rb
ActiveSupport::Configurable#metodai: config
AbstractController::Base#metodai:
  action_methods  action_name  action_name=  available_action?  controller_path  inspect
  response_body
ActionController::Metal#metodai:
  content_type       content_type=  controller_name  dispatch          headers
  location           location=      media_type       middleware_stack  middleware_stack=
  middleware_stack?  performed?     request          request=          reset_session
  response           response=      response_body=   response_code     session
  set_request!       set_response!  status           status=           to_a
ActionView::ViewPaths#metodai:
  _prefixes  any_templates?  append_view_path   details_for_lookup  formats     formats=  locale
  locale=    lookup_context  prepend_view_path  template_exists?    view_paths
AbstractController::Rendering#metodai: view_assigns

# .....

PostsController#metodai: create  destroy  edit  index  new  show  update
egzemplioriaus kintamieji:
  @_action_has_layout  @_action_name    @_config  @_lookup_context                      @_request
  @_response           @_response_body  @_routes  @marked_for_same_origin_verification  @posts
  @rendered_format
klasės kintamieji: @@raise_on_missing_translations  @@raise_on_open_redirects
```

### Pertraukos

Yra daug būdų įterpti ir aktyvuoti pertrauką derinimo priemonėje. Be tiesioginio derinimo teiginių (pvz., `debugger`) įterpimo į kodą, galite įterpti pertraukas naudodami komandas:

- `break` (arba `b`)
  - `break` - išvardina visas pertraukas
  - `break <num>` - nustato pertrauką esamo failo `num` eilutėje
  - `break <file:num>` - nustato pertrauką `file` faile `num` eilutėje
  - `break <Class#method>` arba `break <Class.method>` - nustato pertrauką `Class#method` arba `Class.method`
  - `break <expr>.<method>` - nustato pertrauką `<expr>` rezultato `<method>` metode.
- `catch <Exception>` - nustato pertrauką, kuri sustos, kai iškils `Exception`
- `watch <@ivar>` - nustato pertrauką, kuri sustos, kai pasikeis dabartinio objekto `@ivar` rezultatas (šis veiksmas yra lėtas)

Jas pašalinti galite naudodami:

- `delete` (arba `del`)
  - `delete` - ištrina visas pertraukas
  - `delete <num>` - ištrina pertrauką su id `num`

#### `break` komanda

**Nustatyti pertrauką nurodytoje eilutėje - pvz., `b 28`**

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # ir 72 rėmeliai (naudokite `bt' komandą visiems rėmeliams)
(rdbg) b 28    # pertraukos komanda
#0  BP - Eilutė  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (eilutė)
```
```rb
(rdbg) c    # tęsti komanda
[23, 32] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    23|   def create
    24|     @post = Post.new(post_params)
    25|     debugger
    26|
    27|     respond_to do |format|
=>  28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Įrašas sėkmingai sukurtas." }
    30|         format.json { render :show, status: :created, location: @post }
    31|       else
    32|         format.html { render :new, status: :unprocessable_entity }
=>#0    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  #1    ActionController::MimeResponds#respond_to(mimes=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/mime_responds.rb:205
  # ir 74 karkasai (naudokite `bt' komandą visiems karkasams)

Stabdyti pagal #0  BP - Eilutė  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (eilutė)
```

Nustatyti pertrauką tam tikro metodo iškvietime - pvz., `b @post.save`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Įrašas sėkmingai sukurtas." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # ir 72 karkasai (naudokite `bt' komandą visiems karkasams)
(rdbg) b @post.save    # pertraukimo komanda
#0  BP - Metodas  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43

```

```rb
(rdbg) c    # tęsti komanda
[39, 48] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb
    39|         SuppressorRegistry.suppressed[name] = previous_state
    40|       end
    41|     end
    42|
    43|     def save(**) # :nodoc:
=>  44|       SuppressorRegistry.suppressed[self.class.name] ? true : super
    45|     end
    46|
    47|     def save!(**) # :nodoc:
    48|       SuppressorRegistry.suppressed[self.class.name] ? true : super
=>#0    ActiveRecord::Suppressor#save(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:44
  #1    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  # ir 75 karkasai (naudokite `bt' komandą visiems karkasams)

Stabdyti pagal #0  BP - Metodas  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43
```

#### `catch` komanda

Stabdyti, kai iškyla išimtis - pvz., `catch ActiveRecord::RecordInvalid`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Įrašas sėkmingai sukurtas." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # ir 72 karkasai (naudokite `bt' komandą visiems karkasams)
(rdbg) catch ActiveRecord::RecordInvalid    # komanda
#1  BP - Catch  "ActiveRecord::RecordInvalid"
```

```rb
(rdbg) c    # tęsti komanda
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # ir 88 karkasai (naudokite `bt' komandą visiems karkasams)

Stabdyti pagal #1  BP - Catch  "ActiveRecord::RecordInvalid"
```

#### `watch` komanda

Stabdyti, kai pasikeičia objekto kintamasis - pvz., `watch @_response_body`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Įrašas sėkmingai sukurtas." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # ir 72 karkasai (naudokite `bt' komandą visiems karkasams)
(rdbg) watch @_response_body    # komanda
#0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =
```
```rb
(rdbg) c    # tęsti komanda
[173, 182] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb
   173|       body = [body] unless body.nil? || body.respond_to?(:each)
   174|       response.reset_body!
   175|       return unless body
   176|       response.body = body
   177|       super
=> 178|     end
   179|
   180|     # Tests if render or redirect has already happened.
   181|     def performed?
   182|       response_body || response.committed?
=>#0    ActionController::Metal#response_body=(body=["<html><body>You are being <a href=\"ht...) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb:178 #=> ["<html><body>You are being <a href=\"ht...
  #1    ActionController::Redirecting#redirect_to(options=#<Post id: 13, title: "qweqwe", content:..., response_options={:allow_other_host=>false}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/redirecting.rb:74
  # ir 82 rėmeliai (naudokite `bt' komandą visiems rėmeliams)

Stabdyti pagal #0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =  -> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
(rdbg)
```

#### Pertraukimo taško parinktys

Be skirtingų pertraukimo taškų tipų, taip pat galite nurodyti parinktis, kad pasiektumėte sudėtingesnes derinimo darbo eigos. Šiuo metu deriniklis palaiko 4 parinktis:

- `do: <cmd arba išraiška>` - kai pertraukimo taškas yra aktyvuojamas, vykdykite nurodytą komandą/išraišką ir tęskite programą:
  - `break Foo#bar do: bt` - kai yra iškviestas `Foo#bar`, spausdinti rėmelius
- `pre: <cmd arba išraiška>` - kai pertraukimo taškas yra aktyvuojamas, vykdykite nurodytą komandą/išraišką prieš stabdant:
  - `break Foo#bar pre: info` - kai yra iškviestas `Foo#bar`, spausdinti jo aplinkinius kintamuosius prieš stabdant.
- `if: <išraiška>` - pertraukimo taškas stabdo tik tada, jei `<išraiškos>` rezultatas yra teisingas:
  - `break Post#save if: params[:debug]` - stabdo `Post#save`, jei `params[:debug]` taip pat yra teisingas
- `path: <kelio_regexp>` - pertraukimo taškas stabdo tik tada, jei įvykis, kuris jį sukelia (pvz., metodo iškvietimas), įvyksta iš nurodyto kelio:
  - `break Post#save if: app/services/a_service` - stabdo `Post#save`, jei metodo iškvietimas vyksta toje pačioje vietoje, kurioje atitinka Ruby reguliariąją išraišką `/app\/services\/a_service/`.

Taip pat atkreipkite dėmesį, kad pirmosios 3 parinktys: `do:`, `pre:` ir `if:` taip pat yra prieinamos ir debug komandoms, apie kurias minėjome anksčiau. Pavyzdžiui:

```rb
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger(do: "info")
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # ir 72 rėmeliai (naudokite `bt' komandą visiems rėmeliams)
(rdbg:binding.break) info
%self = #<PostsController:0x00000000017480>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fce3ad336b8 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fce3ad397e8 @mon_data=#<Monitor:0x00007fce3ad396a8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = #<ActiveRecord::Relation [#<Post id: 2, title: "qweqwe", content: "qweqwe", created_at: "...
@rendered_format = nil
```

#### Programuokite savo derinimo darbo eigą

Su šiomis parinktimis galite sukurti savo derinimo darbo eigą vienoje eilutėje, pavyzdžiui:

```rb
def create
  debugger(do: "catch ActiveRecord::RecordInvalid do: bt 10")
  # ...
end
```

Tada deriniklis vykdys scenarijų ir įterpins pertraukimo tašką, kuris užfiksuoja `ActiveRecord::RecordInvalid` išimtį ir spausdins 10 rėmelių.
```rb
(rdbg:binding.break) catch ActiveRecord::RecordInvalid do: bt 10
#0  BP - Sustabdyti  "ActiveRecord::RecordInvalid"
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # ir 88 rėmeliai (naudokite `bt' komandą visiems rėmeliams)

Kai sustabdoma pertrauka yra aktyvuota, ji spausdins rėmelius

```rb
Stabdyti per #0  BP - Sustabdyti  "ActiveRecord::RecordInvalid"

(rdbg:catch) bt 10
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  #2    blokas save! at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/transactions.rb:302
```

Ši technika gali sutaupyti nuo pakartotinio rankinio įvedimo ir padaryti derinimo patirtį sklandesnę.

Daugiau komandų ir konfigūracijos parinkčių galite rasti jo [dokumentacijoje](https://github.com/ruby/debug).

Derinimas naudojant `web-console` Gemą
------------------------------------

Web Console yra panašus į `debug`, tačiau jis veikia naršyklėje. Galite užklausti konsolės peržiūros ar valdiklio kontekste bet kurioje puslapyje. Konsolė bus atvaizduojama šalia jūsų HTML turinio.

### Konsolė

Bet kurio valdiklio veiksmo ar peržiūros metu galite iškviesti konsolę, iškviesdami `console` metodą.

Pavyzdžiui, valdiklyje:

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

Arba peržiūroje:

```html+erb
<% console %>

<h2>Naujas įrašas</h2>
```

Tai atvaizduos konsolę jūsų peržiūroje. Jums nereikia rūpintis `console` iškvietimo vieta; ji nebus atvaizduojama jo iškvietimo vietoje, bet šalia jūsų HTML turinio.

Konsolė vykdo grynąjį Ruby kodą: galite apibrėžti ir sukurti pasirinktines klases, kurti naujus modelius ir tikrinti kintamuosius.

PASTABA: Užklausoje gali būti atvaizduojama tik viena konsolė. Kitu atveju `web-console` iškels klaidą antrajame `console` iškvietime.

### Kintamųjų tikrinimas

Galite iškviesti `instance_variables`, kad būtų išvardinti visi jūsų kontekste esantys objekto kintamieji. Jei norite išvardinti visus vietinius kintamuosius, tai galite padaryti naudodami `local_variables`.

### Nustatymai

* `config.web_console.allowed_ips`: Leidžiamas IPv4 arba IPv6 adresų ir tinklų sąrašas (numatytasis: `127.0.0.1/8, ::1`).
* `config.web_console.whiny_requests`: Užfiksuoti pranešimą, kai konsolės atvaizdavimas yra uždraustas (numatytasis: `true`).

Kadangi `web-console` nuotoliniu būdu vertina grynąjį Ruby kodą serveryje, nenaudokite jo produkcijoje.

Derinimas, naudojant atminties nutekėjimus
----------------------

Ruby programa (su ar be "Rails") gali nutekėti atmintis - arba Ruby kode, arba C kodo lygmeniu.

Šiame skyriuje sužinosite, kaip rasti ir ištaisyti tokius nutekėjimus, naudojant įrankius, pvz., Valgrind.

### Valgrind

[Valgrind](http://valgrind.org/) yra programa, skirta aptikti C pagrindu veikiančius atminties nutekėjimus ir gijų sąlygas.

Yra Valgrind įrankių, kurie gali automatiškai aptikti daugelį atminties valdymo ir gijų klaidų, ir išsamiai analizuoti jūsų programas. Pavyzdžiui, jei interpretatoriuje esantis C plėtinys iškviečia `malloc()`, bet tinkamai nekviečia `free()`, ši atmintis nebus prieinama iki to, kol programa baigs darbą.
Norint gauti daugiau informacijos apie tai, kaip įdiegti Valgrind ir naudoti su Ruby, žiūrėkite
[Valgrind and Ruby](https://blog.evanweaver.com/2008/02/05/valgrind-and-ruby/)
Evan Weaver straipsnį.

### Rasti atminties nutekėjimą

Yra puikus straipsnis apie atminties nutekėjimų aptikimą ir taisymą Derailed svetainėje, [kurį galite perskaityti čia](https://github.com/schneems/derailed_benchmarks#is-my-app-leaking-memory).


Įskiepiai klaidų paieškai
---------------------

Yra keletas Rails įskiepių, kurie padės jums rasti klaidas ir derinti jūsų
programą. Štai naudingų įskiepių sąrašas klaidų paieškai:

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master) Prideda užklausos
  kilmės sekimą į jūsų žurnalus.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master)
  Suteikia pašto objektą ir numatytąjį rinkinį šablonų, skirtų siųsti pašto
  pranešimus, kai įvyksta klaidos „Rails“ programoje.
* [Better Errors](https://github.com/charliesome/better_errors) Pakeičia
  standartinį „Rails“ klaidų puslapį nauju, kuriame yra daugiau kontekstinės informacijos,
  pvz., šaltinio kodo ir kintamųjų tikrinimas.
* [RailsPanel](https://github.com/dejan/rails_panel) „Chrome“ plėtinys „Rails“
  plėtotei, kuris pabaigs jūsų „development.log“ stebėjimą. Turėkite visą informaciją
  apie jūsų „Rails“ programos užklausas naršyklėje - „Developer Tools“ skydelyje.
  Suteikia informaciją apie db/rendering/viso laikus, parametrų sąrašą, sugeneruotus rodinius ir
  daugiau.
* [Pry](https://github.com/pry/pry) Alternatyva „IRB“ ir vykdomosios aplinkos kūrėjo konsolė.

Šaltiniai
----------

* [web-console Pagrindinis puslapis](https://github.com/rails/web-console)
* [debug pagrindinis puslapis](https://github.com/ruby/debug)
