**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 29fda46e32914456eb8369ab3f2cb7d6
Ruby on Rails 2.2 Išleidimo Pastabos
====================================

Rails 2.2 pristato keletą naujų ir patobulintų funkcijų. Šis sąrašas apima pagrindinius atnaujinimus, tačiau neįtraukia kiekvienos mažos klaidos taisymo ir pakeitimo. Jei norite pamatyti viską, peržiūrėkite [įsipareigojimų sąrašą](https://github.com/rails/rails/commits/2-2-stable) pagrindiniame Rails saugykloje GitHub.

Kartu su Rails, 2.2 žymi [Ruby on Rails vadovų](https://guides.rubyonrails.org/) pradžią, tai yra nuolatinio [Rails vadovų hackfest](http://hackfest.rubyonrails.org/guide) rezultatas. Ši svetainė teiks aukštos kokybės dokumentaciją apie pagrindines Rails funkcijas.

--------------------------------------------------------------------------------

Infrastruktūra
--------------

Rails 2.2 yra svarbus išleidimas infrastruktūrai, kuri palaiko Rails veikimą ir ryšį su likusiu pasauliu.

### Internacionalizacija

Rails 2.2 suteikia paprastą internacionalizacijos (arba i18n, tiems iš jūsų, kurie pavargo nuo rašymo) sistemą.

* Pagrindiniai prisidėjusieji: Rails i18 komanda
* Daugiau informacijos:
    * [Oficiali Rails i18 svetainė](http://rails-i18n.org)
    * [Pagaliau. Ruby on Rails tarptautiškas](https://web.archive.org/web/20140407075019/http://www.artweb-design.de/2008/7/18/finally-ruby-on-rails-gets-internationalized)
    * [Rails lokalizavimas: demonstracinė programa](https://github.com/clemens/i18n_demo_app)

### Suderinamumas su Ruby 1.9 ir JRuby

Kartu su gijų saugumu, buvo atlikta daug darbo, kad Rails gerai veiktų su JRuby ir ateinančiu Ruby 1.9. Kadangi Ruby 1.9 yra judantis tikslas, paleidus edge Rails ant edge Ruby vis dar yra rizikinga, tačiau Rails yra pasiruošęs pereiti prie Ruby 1.9, kai šis bus išleistas.

Dokumentacija
-------------

Rails vidinė dokumentacija, pateikta kaip kodo komentarai, buvo patobulinta daugelyje vietų. Be to, [Ruby on Rails vadovų](https://guides.rubyonrails.org/) projektas yra autoritetingas šaltinis informacijai apie pagrindinius Rails komponentus. Pirmame oficialiame išleidime Vadovų puslapyje yra:

* [Pradėkite su Rails](getting_started.html)
* [Rails duomenų bazės migracijos](active_record_migrations.html)
* [Active Record asociacijos](association_basics.html)
* [Active Record užklausų sąsaja](active_record_querying.html)
* [Maketavimas ir atvaizdavimas Rails](layouts_and_rendering.html)
* [Veiksmo vaizdo formos pagalbininkai](form_helpers.html)
* [Rails maršrutizavimas iš išorės į vidų](routing.html)
* [Veiksmo valdiklio apžvalga](action_controller_overview.html)
* [Rails talpinimas](caching_with_rails.html)
* [Vadovas testuoti Rails aplikacijas](testing.html)
* [Rails aplikacijų apsauga](security.html)
* [Rails aplikacijų derinimas](debugging_rails_applications.html)
* [Pagrindai kuriant Rails įskiepius](plugins.html)

Iš viso vadovai suteikia dešimtis tūkstančių žodžių vadovavimo pradedantiesiems ir vidutinio lygio Rails programuotojams.

Jei norite generuoti šiuos vadovus vietiniame aplinkos, savo programoje:

```bash
$ rake doc:guides
```

Tai padės vadovus įdėti į `Rails.root/doc/guides`, ir galėsite pradėti naršyti, atidarę `Rails.root/doc/guides/index.html` savo mėgstamame naršyklės.

* Pagrindiniai indėliai nuo [Xavier Noria](http://advogato.org/person/fxn/diary.html) ir [Hongli Lai](http://izumi.plan99.net/blog/).
* Daugiau informacijos:
    * [Rails vadovų hackfest](http://hackfest.rubyonrails.org/guide)
    * [Padėkite pagerinti Rails dokumentaciją Git šakoje](https://weblog.rubyonrails.org/2008/5/2/help-improve-rails-documentation-on-git-branch)

Geresnis integravimas su HTTP: Iš anksto ETag palaikymas
--------------------------------------------------------

Palaikant ETag ir paskutinio modifikavimo laiko žymę HTTP antraštėse, Rails dabar gali grąžinti tuščią atsakymą, jei gauna užklausą dėl išteklio, kuris neseniai nebuvo modifikuotas. Tai leidžia patikrinti, ar reikia iš viso siųsti atsakymą.

```ruby
class ArticlesController < ApplicationController
  def show_with_respond_to_block
    @article = Article.find(params[:id])

    # Jei užklausa siunčia antraštės, kurios skiriasi nuo stale? pateiktų parinkčių, tada
    # užklausa iš tikrųjų yra pasenusi ir bus paleistas respond_to blokas (ir parinktys
    # stale? iškvietime bus nustatytos atsakyme).
    #
    # Jei užklausos antraštės atitinka, tada užklausa yra nauja ir respond_to blokas
    # nebus paleistas. Vietoj to, vyks numatytas atvaizdavimas, kuris patikrins paskutinio modifikavimo
    # ir etag antraštes ir nustatys, kad reikia siųsti tik "304 Not Modified" vietoje
    # atvaizdavimo šablono.
    if stale?(:last_modified => @article.published_at.utc, :etag => @article)
      respond_to do |wants|
        # įprastas atsakymo apdorojimas
      end
    end
  end

  def show_with_implied_render
    @article = Article.find(params[:id])

    # Nustato atsakymo antraštes ir patikrina jas pagal užklausą, jei užklausa yra pasenusi
    # (t. y. nėra atitikmens nei etag, nei paskutinio modifikavimo), tada vyksta numatytas šablono atvaizdavimas.
    # Jei užklausa yra nauja, tada numatytas atvaizdavimas grąžins "304 Not Modified"
    # vietoje atvaizdavimo šablono.
    fresh_when(:last_modified => @article.published_at.utc, :etag => @article)
  end
end
```

Gijų saugumas
-------------

Darbas, atliktas siekiant padaryti Rails gijų saugumą, įgyvendinamas Rails 2.2. Priklausomai nuo jūsų interneto serverio infrastruktūros, tai reiškia, kad galite tvarkyti daugiau užklausų su mažesniu Rails kopijų skaičiumi atmintyje, kas leidžia pagerinti serverio veikimą ir padidinti daugelio branduolių naudojimą.
Norint įjungti daugiajų gijų dispečerizavimą jūsų aplikacijos produkcinėje versijoje, pridėkite šią eilutę į `config/environments/production.rb` failą:

```ruby
config.threadsafe!
```

* Daugiau informacijos:
    * [Thread safety for your Rails](http://m.onkey.org/2008/10/23/thread-safety-for-your-rails)
    * [Thread safety project announcement](https://weblog.rubyonrails.org/2008/8/16/josh-peek-officially-joins-the-rails-core)
    * [Q/A: What Thread-safe Rails Means](http://blog.headius.com/2008/08/qa-what-thread-safe-rails-means.html)

Active Record
-------------

Yra dvi didelės naujovės, apie kurias verta kalbėti: transakciniai migracijos ir duomenų bazės transakcijos su bendra naudojimo sąrašu. Taip pat yra nauja (ir švaresnė) sąlygų sintaksė jungimo lentelėms, taip pat keletas mažesnių patobulinimų.

### Transakcinės migracijos

Istoriniu požiūriu, daugiausiai problemų kėlė daugiausiai žingsnių turinčios Rails migracijos. Jei migracijos metu įvykdantys veiksmai kėlė klaidų, viskas, kas buvo prieš klaidą, pakeitė duomenų bazę, o viskas, kas buvo po klaidos, nebuvo taikoma. Be to, migracijos versija buvo saugoma kaip įvykdyta, todėl po klaidos jos negalima tiesiog paleisti iš naujo naudojant `rake db:migrate:redo`. Transakcinės migracijos tai keičia, apgaubdamos migracijos žingsnius DDL transakcija, todėl jei nors vienas iš jų nepavyksta, visa migracija yra atšaukiama. Rails 2.2 versijoje transakcinės migracijos yra palaikomos PostgreSQL duomenų bazėje. Kodas yra plėtojamas ir kitoms duomenų bazėms ateityje - IBM jau praplėtė jį, kad palaikytų DB2 adapterį.

* Pagrindinis prisidėjusysis: [Adam Wiggins](http://about.adamwiggins.com/)
* Daugiau informacijos:
    * [DDL Transactions](http://adam.heroku.com/past/2008/9/3/ddl_transactions/)
    * [A major milestone for DB2 on Rails](http://db2onrails.com/2008/11/08/a-major-milestone-for-db2-on-rails/)

### Ryšių sąrašai

Ryšių sąrašuose dabar galima nurodyti sąlygas naudojant hash'ą. Tai labai padeda, jei reikia užklausų per sudėtingus junginius.

```ruby
class Photo < ActiveRecord::Base
  belongs_to :product
end

class Product < ActiveRecord::Base
  has_many :photos
end

# Gaukite visus produktus su nuotraukomis, kurios neturi autorių teisių:
Product.all(:joins => :photos, :conditions => { :photos => { :copyright => false }})
```

* Daugiau informacijos:
    * [What's New in Edge Rails: Easy Join Table Conditions](http://archives.ryandaigle.com/articles/2008/7/7/what-s-new-in-edge-rails-easy-join-table-conditions)

### Nauji dinaminiai paieškos metodai

Active Record dinaminių paieškos metodų šeimai buvo pridėta du naujų rinkinių.

#### `find_last_by_attribute`

`find_last_by_attribute` metodas yra ekvivalentiškas `Model.last(:conditions => {:attribute => value})`

```ruby
# Gaukite paskutinį vartotoją, kuris užsiregistravo iš Londono
User.find_last_by_city('London')
```

* Pagrindinis prisidėjusysis: [Emilio Tagua](http://www.workingwithrails.com/person/9147-emilio-tagua)

#### `find_by_attribute!`

Naujoji `find_by_attribute!` bang! versija yra ekvivalentiška `Model.first(:conditions => {:attribute => value}) || raise ActiveRecord::RecordNotFound`. Vietoj `nil` grąžinimo, jei nėra atitinkančio įrašo, šis metodas iškelia išimtį, jei atitinkamo įrašo neranda.

```ruby
# Iškelkite ActiveRecord::RecordNotFound išimtį, jei 'Moby' dar nėra užsiregistravęs!
User.find_by_name!('Moby')
```

* Pagrindinis prisidėjusysis: [Josh Susser](http://blog.hasmanythrough.com)

### Ryšių asociacijos laikosi privačių/apsaugotų apimčių

Active Record asociacijų proxy dabar laikosi metodų apimties, kurie yra perduoti perduotam objektui. Anksčiau (atlikus User has_one :account) `@user.account.private_method` iškviestų privačų metodą susijusiame Account objekte. Tai neveikia Rails 2.2; jei jums reikia šios funkcionalumo, turėtumėte naudoti `@user.account.send(:private_method)` (arba padaryti metodą viešą, o ne privačią ar apsaugotą). Atkreipkite dėmesį, jei keičiate `method_missing`, taip pat turėtumėte keisti `respond_to`, kad būtų atitinkamas elgesys, kad asociacijos veiktų normaliai.

* Pagrindinis prisidėjusysis: Adam Milligan
* Daugiau informacijos:
    * [Rails 2.2 Change: Private Methods on Association Proxies are Private](http://afreshcup.com/2008/10/24/rails-22-change-private-methods-on-association-proxies-are-private/)

### Kiti Active Record pakeitimai

* `rake db:migrate:redo` dabar priima pasirinktinį VERSION, kad būtų galima nukreipti tam tikrą migraciją
* Nustatykite `config.active_record.timestamped_migrations = false`, kad migracijos turėtų skaitmeninį prefiksą, o ne UTC laiko žymą.
* Skaitiklio talpyklos stulpeliai (ryšiams, deklaruotiems su `:counter_cache => true`) daugiau nebeturi būti inicializuojami nuliu.
* `ActiveRecord::Base.human_name` skirtas tarptautiškai suprantamam modelio pavadinimo žmogiškam vertimui

Action Controller
-----------------

Valdiklio pusėje yra keletas pakeitimų, kurie padės sutvarkyti jūsų maršrutus. Taip pat yra keletas vidinių pakeitimų maršrutų variklyje, kad būtų sumažintas atminties naudojimas sudėtingose aplikacijose.
### Paviršutiniškas maršruto įdėjimas

Paviršutiniškas maršruto įdėjimas suteikia sprendimą gerai žinomam sunkumui naudojant giliai įdėtas išteklius. Naudojant paviršutinišką įdėjimą, jums tereikia pateikti pakankamai informacijos, kad galėtumėte unikaliai nustatyti išteklių, su kuriais norite dirbti, identifikatorių.

```ruby
map.resources :publishers, :shallow => true do |publisher|
  publisher.resources :magazines do |magazine|
    magazine.resources :photos
  end
end
```

Tai leis atpažinti (tarp kitų) šiuos maršrutus:

```
/publishers/1           ==> publisher_path(1)
/publishers/1/magazines ==> publisher_magazines_path(1)
/magazines/2            ==> magazine_path(2)
/magazines/2/photos     ==> magazines_photos_path(2)
/photos/3               ==> photo_path(3)
```

* Pagrindinis bendradarbis: [S. Brent Faulkner](http://www.unwwwired.net/)
* Daugiau informacijos:
    * [Rails maršrutizavimas iš išorės į vidų](routing.html#nested-resources)
    * [Kas naujo Edge Rails: paviršutiniški maršrutai](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-shallow-routes)

### Metodų masyvai nariui ar kolekcijai maršrutuose

Dabar galite pateikti metodų masyvą naujiems nariams ar kolekcijoms maršrutuose. Tai pašalina nemalonumus, kai turite apibrėžti maršrutą kaip priimantį bet kokį veiksmą, kai jums reikia, kad jis tvarkytų daugiau nei vieną. Su Rails 2.2 tai yra teisėtas maršruto deklaravimas:

```ruby
map.resources :photos, :collection => { :search => [:get, :post] }
```

* Pagrindinis bendradarbis: [Brennan Dunn](http://brennandunn.com/)

### Išteklių su konkrečiais veiksmais

Pagal numatymą, naudojant `map.resources` norint sukurti maršrutą, Rails generuoja maršrutus septyniems numatytiesiems veiksmams (index, show, create, new, edit, update ir destroy). Tačiau kiekvienas šis maršrutas užima atmintį jūsų programoje ir sukelia papildomą maršrutizavimo logikos generavimą Rails. Dabar galite naudoti `:only` ir `:except` parinktis, kad tiksliai nustatytumėte maršrutus, kuriuos Rails generuos ištekliams. Galite pateikti vieną veiksmą, veiksmų masyvą arba specialias `:all` ar `:none` parinktis. Šios parinktys paveldimos iš įdėtų išteklių.

```ruby
map.resources :photos, :only => [:index, :show]
map.resources :products, :except => :destroy
```

* Pagrindinis bendradarbis: [Tom Stuart](http://experthuman.com/)

### Kitos veiksmo kontrolerio pakeitimai

* Dabar galite lengvai [rodyti tinkintą klaidų puslapį](http://m.onkey.org/2008/7/20/rescue-from-dispatching), kai maršrutuojant užklausą iškyla išimtys.
* HTTP Accept antraštė dabar yra išjungta pagal numatymą. Turėtumėte naudoti formatuotus URL (pvz., `/customers/1.xml`), norėdami nurodyti norimą formatą. Jei jums reikia Accept antraščių, galite juos įjungti su `config.action_controller.use_accept_header = true`.
* Matavimo skaičiai dabar pranešami milisekundėmis, o ne mažais sekundžių trupmenomis.
* Rails dabar palaiko tik HTTP tik slapukus (ir naudoja juos sesijoms), kurie padeda sumažinti kai kuriuos naujesnių naršyklių kryžminio skriptavimo rizikos veiksnius.
* `redirect_to` dabar visiškai palaiko URI schemą (pvz., galite nukreipti į svn`ssh: URI).
* `render` dabar palaiko `:js` parinktį, kad galėtumėte atvaizduoti paprastą vanilinį JavaScript su tinkamu MIME tipu.
* Užklausos suklastojimo apsauga buvo sustiprinta, taikoma tik HTML formatuotų turinio užklausoms.
* Polimorfiniai URL elgiasi protingiau, jei perduotas parametras yra null. Pavyzdžiui, iškvietus `polymorphic_path([@project, @date, @area])` su null data, gausite `project_area_path`.

Veiksmo rodinys
-----------

* `javascript_include_tag` ir `stylesheet_link_tag` palaiko naują `:recursive` parinktį, kurią galima naudoti kartu su `:all`, kad galėtumėte įkelti visą failų medį viena kodo eilute.
* Įtraukta Prototype JavaScript biblioteka buvo atnaujinta iki 1.6.0.3 versijos.
* `RJS#page.reload` - per JavaScript perkrauna naršyklės dabartinę vietą
* `atom_feed` pagalbininkas dabar priima `:instruct` parinktį, leidžiančią įterpti XML apdorojimo instrukcijas.

Veiksmo paštas
-------------

Veiksmo paštas dabar palaiko pašto išdėstymus. Galite padaryti savo HTML laiškus tokiais pat gražiais kaip naršyklės rodiniai, pateikdami tinkamai pavadintą išdėstymą - pavyzdžiui, `CustomerMailer` klasė tikisi naudoti `layouts/customer_mailer.html.erb`.

* Daugiau informacijos:
    * [Kas naujo Edge Rails: Pašto išdėstymai](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-mailer-layouts)

Veiksmo paštas dabar siūlo įdiegtą palaikymą GMail SMTP serveriams, automatiškai įjungiant STARTTLS. Tai reikalauja, kad būtų įdiegta Ruby 1.8.7.

Aktyvus palaikymas
--------------

Aktyvus palaikymas dabar siūlo įdiegtą memoizaciją „Rails“ programoms, `each_with_object` metodą, prefikso palaikymą delegatuose ir kitus naujus pagalbinius metodus.

### Memoizacija

Memoizacija yra modelio, kuris vieną kartą inicializuojamas ir tada jo reikšmė yra saugoma pakartotiniam naudojimui, modelis. Tikriausiai naudojote šį modelį savo programose:

```ruby
def full_name
  @full_name ||= "#{first_name} #{last_name}"
end
```

Memoizacija leidžia jums tvarkyti šią užduotį deklaratyviai:

```ruby
extend ActiveSupport::Memoizable

def full_name
  "#{first_name} #{last_name}"
end
memoize :full_name
```

Kitos memoizacijos funkcijos apima `unmemoize`, `unmemoize_all` ir `memoize_all`, kad įjungtumėte arba išjungtumėte memoizaciją.
* Pagrindinis prisidėjusio asmenys: [Josh Peek](http://joshpeek.com/)
* Daugiau informacijos:
    * [Kas naujo Edge Rails: Paprasta memoizacija](http://archives.ryandaigle.com/articles/2008/7/16/what-s-new-in-edge-rails-memoization)
    * [Memo-kas? Memoizacijos vadovas](http://www.railway.at/articles/2008/09/20/a-guide-to-memoization)

### each_with_object

`each_with_object` metodas suteikia alternatyvą `inject` metodui, naudojant metodą, kuris buvo atgalinės suderinamumo su Ruby 1.9. Jis iteruoja per kolekciją, perduodamas esamą elementą ir memo į bloką.

```ruby
%w(foo bar).each_with_object({}) { |str, hsh| hsh[str] = str.upcase } # => {'foo' => 'FOO', 'bar' => 'BAR'}
```

Pagrindinis prisidėjusio asmuo: [Adam Keys](http://therealadam.com/)

### Delegatai su prefiksu

Jei deleguojate elgesį iš vienos klasės į kitą, dabar galite nurodyti prefiksą, kuris bus naudojamas identifikuoti deleguotus metodus. Pavyzdžiui:

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => true
end
```

Tai sukurs deleguotus metodus `vendor#account_email` ir `vendor#account_password`. Taip pat galite nurodyti pasirinktinį prefiksą:

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => :owner
end
```

Tai sukurs deleguotus metodus `vendor#owner_email` ir `vendor#owner_password`.

Pagrindinis prisidėjusio asmuo: [Daniel Schierbeck](http://workingwithrails.com/person/5830-daniel-schierbeck)

### Kiti Active Support pakeitimai

* Išsamūs atnaujinimai `ActiveSupport::Multibyte`, įskaitant Ruby 1.9 suderinamumo pataisymus.
* Pridėtas `ActiveSupport::Rescuable`, leidžiantis bet kuriai klasei įtraukti `rescue_from` sintaksę.
* `past?`, `today?` ir `future?` `Date` ir `Time` klasėms, siekiant palengvinti datos/laiko palyginimus.
* `Array#second` iki `Array#fifth` kaip sinonimai `Array#[1]` iki `Array#[4]`
* `Enumerable#many?` apibrėžti `collection.size > 1`
* `Inflector#parameterize` sukuria URL tinkamą versiją išvesties, naudojimui `to_param`.
* `Time#advance` pripažįsta dalines dienas ir savaites, todėl galite daryti `1.7.weeks.ago`, `1.5.hours.since`, ir t.t.
* Įtraukta TzInfo biblioteka buvo atnaujinta iki 0.3.12 versijos.
* `ActiveSupport::StringInquirer` suteikia jums gražų būdą patikrinti lygybę simboliuose: `ActiveSupport::StringInquirer.new("abc").abc? => true`

Railties
--------

Railties (paties Rails pagrindinio kodo) didžiausi pokyčiai yra `config.gems` mechanizme.

### config.gems

Norint išvengti diegimo problemų ir padaryti Rails aplikacijas labiau savarankiškas, galima įdėti kopijas visų jūsų Rails aplikacijos reikalingų gemų į `/vendor/gems`. Ši galimybė pasirodė pirmą kartą Rails 2.1 versijoje, tačiau ji yra daug lankstesnė ir patikimesnė Rails 2.2 versijoje, tvarkant sudėtingas priklausomybes tarp gemų. Gemų valdymas Rails apima šias komandas:

* `config.gem _gem_name_` jūsų `config/environment.rb` faile
* `rake gems` išvardinti visus sukonfigūruotus gemus, taip pat ar jie (ir jų priklausomybės) yra įdiegti, užšaldyti arba pagrindinės (pagrindinės gemai yra tie, kurie įkeliami prieš vykdant gemų priklausomybių kodą; tokie gemai negali būti užšaldyti)
* `rake gems:install` įdiegti trūkstamus gemus į kompiuterį
* `rake gems:unpack` įdėti kopiją reikalingų gemų į `/vendor/gems`
* `rake gems:unpack:dependencies` gauti kopijas reikalingų gemų ir jų priklausomybių į `/vendor/gems`
* `rake gems:build` sukurti trūkstamus natyvius plėtinius
* `rake gems:refresh_specs` atnaujinti su Rails 2.1 sukurtus vendor gemus pagal Rails 2.2 saugojimo būdą

Galite išpakuoti arba įdiegti vieną gemą, nurodydami `GEM=_gem_name_` komandų eilutėje.

* Pagrindinis prisidėjusio asmuo: [Matt Jones](https://github.com/al2o3cr)
* Daugiau informacijos:
    * [Kas naujo Edge Rails: Gemų priklausomybės](http://archives.ryandaigle.com/articles/2008/4/1/what-s-new-in-edge-rails-gem-dependencies)
    * [Rails 2.1.2 ir 2.2RC1: Atnaujinkite savo RubyGems](https://afreshcup.com/home/2008/10/25/rails-212-and-22rc1-update-your-rubygems)
    * [Išsamus aptarimas Lighthouse](http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1128)

### Kiti Railties pakeitimai

* Jei esate [Thin](http://code.macournoyer.com/thin/) serverio gerbėjas, džiaugsitės žinodami, kad `script/server` dabar tiesiogiai palaiko Thin.
* `script/plugin install &lt;plugin&gt; -r &lt;revision&gt;` dabar veikia su git pagrįstais, taip pat su svn pagrįstais įskiepiais.
* `script/console` dabar palaiko `--debugger` parinktį
* Instrukcijos, kaip nustatyti nuolatinio integravimo serverį, kad galėtumėte kurti patį Rails, yra įtrauktos į Rails šaltinio kodą
* `rake notes:custom ANNOTATION=MYFLAG` leidžia išvardinti pasirinktines anotacijas.
* Apvyniotas `Rails.env` su `StringInquirer`, todėl galite daryti `Rails.env.development?`
* Norint išvengti pasenusių įspėjimų ir tinkamai tvarkyti gemų priklausomybes, Rails dabar reikalauja rubygems 1.3.1 arba naujesnės versijos.

Pasenusi
----------

Šioje versijoje yra keletas pasenusio kodo:

* `Rails::SecretKeyGenerator` buvo pakeistas į `ActiveSupport::SecureRandom`
* `render_component` yra pasenusi. Yra [render_components įskiepis](https://github.com/rails/render_component/tree/master) jei jums reikia šios funkcionalumo.
* Neaiškios vietinės priskyrimo dalys, kai atvaizduojami daliniai, yra pasenusios.

    ```ruby
    def partial_with_implicit_local_assignment
      @customer = Customer.new("Marcel")
      render :partial => "customer"
    end
    ```

    Anksčiau pateiktas kodas prieinamas vietinės kintamajai, vadinamai `customer`, daliniame 'customer'. Dabar turėtumėte aiškiai perduoti visus kintamuosius per `:locals` maišą.
* `country_select` buvo pašalintas. Daugiau informacijos ir įskiepio pakeitimo galite rasti [deprecijavimo puslapyje](http://www.rubyonrails.org/deprecation/list-of-countries).
* `ActiveRecord::Base.allow_concurrency` daugiau neturi jokio poveikio.
* `ActiveRecord::Errors.default_error_messages` buvo deprecijuotas naudai `I18n.translate('activerecord.errors.messages')`.
* `%s` ir `%d` interpoliacijos sintaksė tarptautiniam naudojimui yra deprecijuota.
* `String#chars` buvo deprecijuotas naudai `String#mb_chars`.
* Laikotarpiai su trupmeniniais mėnesiais arba trupmeniniais metais yra deprecijuoti. Vietoj to naudokite Ruby pagrindinį `Date` ir `Time` klasės skaičiavimą.
* `Request#relative_url_root` yra deprecijuotas. Vietoj to naudokite `ActionController::Base.relative_url_root`.

Kreditai
-------

Išleidimo pastabos sudarytos [Mike Gunderloy](http://afreshcup.com)
