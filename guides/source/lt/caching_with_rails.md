**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bef23603f5d822054701f5cbf2578d95
Podėliavimas su Rails: Apžvalga
===============================

Šis vadovas yra įvadas į jūsų Rails aplikacijos pagreitinimą naudojant podėliavimą.

Podėliavimas reiškia saugoti turinį, kuris yra generuojamas per užklausos-atsakymo ciklą ir jį naudoti, kai atsakoma į panašias užklausas.

Podėliavimas dažnai yra efektyviausias būdas pagerinti aplikacijos veikimą. Naudojant podėliavimą, svetainės, veikiančios viename serveryje su viena duomenų baze, gali išlaikyti tūkstančius vienu metu prisijungusių vartotojų apkrovą.

Rails pateikia rinkinį podėliavimo funkcijų iš anksto. Šis vadovas jums parodys kiekvienos iš jų apimtį ir tikslą. Išmanydami šias technikas, jūsų Rails aplikacijos gali aptarnauti milijonus peržiūrų be per didelių atsakymo laikų ar serverio sąskaitų.

Po šio vadovo perskaitymo, jūs žinosite:

* Fragmento ir rusiško lėlių podėliavimą.
* Kaip valdyti podėliavimo priklausomybes.
* Alternatyvius podėliavimo saugyklų tipus.
* Sąlyginės GET parametrų palaikymą.

--------------------------------------------------------------------------------

Pagrindinis podėliavimas
------------------------

Tai yra įvadas į tris podėliavimo technikas: puslapio, veiksmo ir fragmento podėliavimą. Pagal numatytuosius nustatymus, Rails pateikia fragmento podėliavimą. Norėdami naudoti puslapio ir veiksmo podėliavimą, jums reikės pridėti `actionpack-page_caching` ir `actionpack-action_caching` į savo `Gemfile`.

Pagal numatytuosius nustatymus, podėliavimas yra įjungtas tik jūsų produkcinėje aplinkoje. Galite išbandyti podėliavimą vietiniame kompiuteryje paleisdami `rails dev:cache` arba nustatydami [`config.action_controller.perform_caching`][] reikšmę į `true` `config/environments/development.rb` faile.

PASTABA: Pakeitus `config.action_controller.perform_caching` reikšmę, tai turės poveikį tik Action Controller teikiamam podėliavimui. Pavyzdžiui, tai neturės įtakos žemam lygio podėliavimui, kurį aptariame [žemiau](#žemo-lygio-podėliavimas).


### Puslapio podėliavimas

Puslapio podėliavimas yra Rails mechanizmas, leidžiantis užklausai, skirtai sugeneruotam puslapiui, būti patenkintai interneto serverio (pvz., Apache ar NGINX) be poreikio eiti per visą Rails paketą. Nors tai yra labai greita, tai negali būti taikoma visoms situacijoms (pvz., puslapiams, reikalaujantiems autentifikacijos). Taip pat, nes interneto serveris aptarnauja failą tiesiogiai iš failų sistemos, jums reikės įgyvendinti podėlio galiojimą.

INFORMACIJA: Puslapio podėliavimas buvo pašalintas iš Rails 4. Žr. [actionpack-page_caching gemą](https://github.com/rails/actionpack-page_caching).

### Veiksmo podėliavimas

Puslapio podėliavimas negali būti naudojamas veiksmams, kuriuose yra prieš filtro - pavyzdžiui, puslapiams, reikalaujantiems autentifikacijos. Čia įsikiša Veiksmo podėliavimas. Veiksmo podėliavimas veikia kaip Puslapio podėliavimas, išskyrus tai, kad įeinanti interneto užklausa pasiekia Rails paketą, kad prieš filtrai galėtų būti vykdomi prieš podėlį aptarnaujant. Tai leidžia vykdyti autentifikaciją ir kitus apribojimus, tuo pačiu metu aptarnaujant rezultatą iš podėlio kopijos.

INFORMACIJA: Veiksmo podėliavimas buvo pašalintas iš Rails 4. Žr. [actionpack-action_caching gemą](https://github.com/rails/actionpack-action_caching). Žr. [DHH raktinio podėlio galiojimo apžvalgą](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works) dėl naujo pageidaujamo metodo.

### Fragmento podėliavimas

Dinaminės interneto aplikacijos paprastai kuria puslapius su įvairiais komponentais, kurių ne visi turi tokius pačius podėlio savybes. Kai skirtingi puslapio dalys turi būti podėliuojamos ir galiojamos atskirai, galite naudoti Fragmento podėliavimą.

Fragmento podėliavimas leidžia apgaubti dalį rodinio logikos podėlio bloku ir aptarnauti jį iš podėlio saugyklos, kai ateina kitas užklausos.

Pavyzdžiui, jei norėtumėte podėliuoti kiekvieną produktą puslapyje, galėtumėte naudoti šį kodą:

```html+erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

Kai jūsų aplikacija gauna pirmą užklausą į šį puslapį, Rails įrašys naują podėlio įrašą su unikaliu raktu. Raktas atrodo kažkaip taip:

```
views/products/index:bea67108094918eeba42cd4a6e786901/products/1
```

Viduryje esantis simbolių eilutė yra šablono medžio skaitinė reikšmė. Tai yra maišos reikšmė, apskaičiuota pagal rodinio fragmento turinio, kurį jūs podėliuojate. Jei pakeisite rodinio fragmentą (pvz., HTML keičiasi), maišos reikšmė pasikeis, galiojant esamam failui.

Podėlio įraše saugoma podėlio versija, gauta iš produkto įrašo. Kai produktas yra paliestas, podėlio versija keičiasi, ir bet kokie podėliuoti fragmentai, kuriuose yra ankstesnė versija, yra ignoruojami.

PATARIMAS: Podėlio saugyklos, pvz., Memcached, automatiškai ištrins senus podėlio failus.

Jei norite podėliuoti fragmentą pagal tam tikras sąlygas, galite naudoti `cache_if` arba `cache_unless`:

```erb
<% cache_if admin?, product do %>
  <%= render product %>
<% end %>
```

#### Rinkinio podėliavimas

`render` pagalbininkas taip pat gali podėliuoti atskirus šablonus, kurie yra sugeneruojami rinkiniui. Jis netgi gali pagerinti ankstesnį pavyzdį su `each`, skaitant visus podėlio šablonus iš karto, o ne vieną po kito. Tai padaroma perduodant `cached: true`, kai renderinamas rinkinys:
```html+erb
<%= render partial: 'products/product', collection: @products, cached: true %>
```

Visi iš anksto užregistruoti šablonai bus gauti vienu metu, kuris leis greičiau atvaizduoti puslapį. Be to, šablonai, kurie dar nėra užregistruoti, bus įrašyti į talpyklą ir bus gauti kartu su kitu atvaizdavimu.

### Rusiško lėlių talpinimas

Galite norėti įdėti talpyklą į kitą talpyklą. Tai vadinama rusišku lėlių talpinimu.

Rusiško lėlių talpinimo privalumas yra tas, kad jei vienas produktas yra atnaujinamas, visi kiti vidiniai fragmentai gali būti pernaudojami, kai atnaujinamas išorinis fragmentas.

Kaip paaiškinta ankstesniame skyriuje, užregistruotas failas pasibaigs, jei `updated_at` reikšmė pasikeis tam tikram įrašui, nuo kurio priklauso užregistruotas failas. Tačiau tai nesibaigs jokios talpyklos, į kurią įterptas fragmentas.

Pavyzdžiui, turime šį rodinį:

```erb
<% cache product do %>
  <%= render product.games %>
<% end %>
```

Kuris savo ruožtu atvaizduoja šį rodinį:

```erb
<% cache game do %>
  <%= render game %>
<% end %>
```

Jei bet kuri game atributas pasikeis, `updated_at` reikšmė bus nustatyta į dabartinį laiką, taip pasibaigiant talpyklai. Tačiau, nes `updated_at` nebus pakeistas produktų objekte, talpykla nesibaigs ir jūsų programa bus naudojama pasenusi informacija. Norint tai ištaisyti, susieję modelius sujungiame su `touch` metodu:

```ruby
class Product < ApplicationRecord
  has_many :games
end

class Game < ApplicationRecord
  belongs_to :product, touch: true
end
```

Nustatę `touch` į `true`, bet kokia veikla, kuri pakeičia `updated_at` žaidimo įrašui, taip pat pakeis jį susijusiam produktui, taip pasibaigiant talpyklai.

### Bendrinė dalinio talpinimas

Įmanoma dalintis daliniais ir susijusia talpykla tarp failų su skirtingais MIME tipais. Pavyzdžiui, bendrinis dalinio talpinimas leidžia šablonų kūrėjams dalintis daliniu tarp HTML ir JavaScript failų. Kai šablonai yra surinkti šablonų išieškotojo failų keliuose, jie apima tik šablono kalbos plėtinį, o ne MIME tipą. Dėl šios priežasties šablonai gali būti naudojami keliose MIME tipose. Abi HTML ir JavaScript užklausos atsakys į šį kodą:

```ruby
render(partial: 'hotels/hotel', collection: @hotels, cached: true)
```

Bus įkeltas failas pavadinimu `hotels/hotel.erb`.

Kitas variantas yra įtraukti visą dalinio failo pavadinimą, kurį norite atvaizduoti.

```ruby
render(partial: 'hotels/hotel.html.erb', collection: @hotels, cached: true)
```

Bus įkeltas failas pavadinimu `hotels/hotel.html.erb` bet kuriame failo MIME type, pavyzdžiui, galėtumėte įtraukti šį dalinį į JavaScript failą.

### Priklausomybių valdymas

Norėdami teisingai atšaukti talpyklą, turite tinkamai apibrėžti talpyklos priklausomybes. „Rails“ yra pakankamai protingas, kad galėtų tvarkyti dažnai pasitaikančius atvejus, todėl jums nereikia nieko nurodyti. Tačiau kartais, pvz., jei dirbate su tinkintais pagalbininkais, turite aiškiai juos apibrėžti.

#### Neaiškios priklausomybės

Dauguma šablonų priklausomybių gali būti išvestos iš „render“ iškvietimų šablone. Štai keli „ActionView::Digestor“ žino, kaip dekoduoti pavyzdžiai:

```ruby
render partial: "comments/comment", collection: commentable.comments
render "comments/comments"
render 'comments/comments'
render('comments/comments')

render "header" verčia render("comments/header")

render(@topic)         verčia render("topics/topic")
render(topics)         verčia render("topics/topic")
render(message.topics) verčia render("topics/topic")
```

Kita vertus, kai kurie iškvietimai turi būti pakeisti, kad talpykla tinkamai veiktų. Pavyzdžiui, jei perduodate tinkintą kolekciją, turėsite pakeisti:

```ruby
render @project.documents.where(published: true)
```

į:

```ruby
render partial: "documents/document", collection: @project.documents.where(published: true)
```

#### Aiškios priklausomybės

Kartais turėsite šablonų priklausomybes, kurios visiškai negali būti išvestos. Tai paprastai yra atvejis, kai atvaizduojama pagalba. Štai pavyzdys:

```html+erb
<%= render_sortable_todolists @project.todolists %>
```

Turėsite naudoti specialų komentaro formatą, kad tai pažymėtumėte:

```html+erb
<%# Šablono priklausomybė: todolists/todolist %>
<%= render_sortable_todolists @project.todolists %>
```

Kai kuriais atvejais, pvz., naudojant vieno lentelės paveldėjimo sąranką, galite turėti daug aiškių priklausomybių. Vietoje kiekvieno šablono rašymo galite naudoti ženklą, kad atitiktų bet kurį šablono kataloge:

```html+erb
<%# Šablono priklausomybė: events/* %>
<%= render_categorizable_events @person.events %>
```

Dėl kolekcijos talpinimo, jei dalinio šablonas neprasideda švariu talpyklos iškvietimu, vis tiek galite naudotis kolekcijos talpinimu pridedami specialų komentaro formatą bet kurioje šablone, pvz.:

```html+erb
<%# Šablono kolekcija: notification %>
<% my_helper_that_calls_cache(some_arg, notification) do %>
  <%= notification.name %>
<% end %>
```
#### Išorinės priklausomybės

Jei naudojate pagalbinį metodą, pavyzdžiui, viduje talpyklos bloko, ir tada atnaujinote tą pagalbinį metodą, taip pat turėsite atnaujinti talpyklą. Nėra svarbu, kaip tai padarysite, bet šablonų failo MD5 turi pasikeisti. Vienas rekomenduojamas būdas yra tiesiog būti aiškus komentare, pavyzdžiui:

```html+erb
<%# Pagalbinės priklausomybės atnaujintos: 2015 m. liepos 28 d., 19 val. %>
<%= some_helper_method(person) %>
```

### Žemo lygio talpinimas

Kartais jums reikia talpinti tam tikrą reikšmę ar užklausos rezultatą, o ne talpinti rodinio fragmentus. „Rails“ talpinimo mechanizmas puikiai tinka saugoti bet kokius serijinius duomenis.

Efektyviausias būdas įgyvendinti žemo lygio talpinimą yra naudojant `Rails.cache.fetch` metodą. Šis metodas atlieka tiek skaitymą, tiek rašymą į talpyklą. Jei perduodamas tik vienas argumentas, gaunamas raktas ir grąžinama reikšmė iš talpyklos. Jei perduodamas blokas, šis blokas bus vykdomas, jei talpykloje nėra duomenų. Bloko grąžinimo reikšmė bus įrašyta į talpyklą pagal nurodytą talpyklos raktą, ir ši grąžinimo reikšmė bus grąžinta. Jei talpykloje yra duomenų, grąžinama talpykloje esanti reikšmė be bloko vykdymo.

Svarstykite šį pavyzdį. Programoje yra „Product“ modelis su egzemplioriaus metodu, kuris ieško produkto kainos konkuruojančioje svetainėje. Šio metodo grąžinami duomenys būtų puikūs žemo lygio talpinimui:

```ruby
class Product < ApplicationRecord
  def competing_price
    Rails.cache.fetch("#{cache_key_with_version}/competing_price", expires_in: 12.hours) do
      Competitor::API.find_price(id)
    end
  end
end
```

PASTABA: Pastebėkite, kad šiame pavyzdyje naudojome `cache_key_with_version` metodą, todėl gautas talpyklos raktas bus kažkas panašaus į `products/233-20140225082222765838000/competing_price`. `cache_key_with_version` sugeneruoja eilutę, remdamasi modelio klasės pavadinimu, `id` ir `updated_at` atributais. Tai yra įprasta konvencija ir turi naudą, kadangi talpykla tampa nebegaliojančia, kai produktas yra atnaujinamas. Bendrai tariant, naudojant žemo lygio talpinimą, reikia sugeneruoti talpyklos raktą.

#### Venkite „Active Record“ objektų egzempliorių talpinimo

Svarstykite šį pavyzdį, kuriame talpinama „Active Record“ objektų sąrašo, kuris atstovauja super vartotojams, talpykloje:

```ruby
# super_admins yra brangi SQL užklausa, todėl jos nevykdykite per dažnai
Rails.cache.fetch("super_admin_users", expires_in: 12.hours) do
  User.super_admins.to_a
end
```

Turėtumėte __vengti__ šio modelio. Kodėl? Nes egzempliorius gali pasikeisti. Producijos aplinkoje jo atributai gali skirtis arba įrašas gali būti ištrintas. O kūrimo metu tai veikia nepatikimai su talpyklų saugyklomis, kurios perkrauna kodą, kai atliekate pakeitimus.

Vietoj to, talpinkite ID ar kitą primityvų duomenų tipą. Pavyzdžiui:

```ruby
# super_admins yra brangi SQL užklausa, todėl jos nevykdykite per dažnai
ids = Rails.cache.fetch("super_admin_user_ids", expires_in: 12.hours) do
  User.super_admins.pluck(:id)
end
User.where(id: ids).to_a
```

### SQL talpinimas

Užklausos talpinimas yra „Rails“ funkcija, kuri talpina kiekvienos užklausos grąžinamą rezultatų rinkinį. Jei „Rails“ vėl susiduria su ta pačia užklausa toje pačioje užklausos metu, jis naudos talpykloje esantį rezultatų rinkinį, o ne vykdys užklausą duomenų bazėje.

Pavyzdžiui:

```ruby
class ProductsController < ApplicationController
  def index
    # Vykdome užklausą
    @products = Product.all

    # ...

    # Vėl vykdome tą pačią užklausą
    @products = Product.all
  end
end
```

Antrą kartą, kai ta pati užklausa vykdoma duomenų bazėje, ji iš tikrųjų nebus vykdoma duomenų bazėje. Pirmą kartą rezultatas grąžinamas iš užklausos ir saugomas užklausos talpykloje (atmintyje), o antrą kartą jis gaunamas iš atminties.

Tačiau svarbu pažymėti, kad užklausos talpyklos yra sukuriamos veiksmo pradžioje ir sunaikinamos veiksmo pabaigoje, todėl jos išlieka tik veiksmo trukmės metu. Jei norite saugoti užklausos rezultatus ilgalaikiu būdu, galite tai padaryti naudodami žemo lygio talpinimą.

Talpyklos saugyklos
------------

„Rails“ teikia skirtingas saugyklos talpykloje esantiems duomenims (išskyrus SQL ir puslapio talpinimą).

### Konfigūracija

Galite nustatyti savo programos numatytąją talpyklos saugyklą, nustatydami `config.cache_store` konfigūracijos parinktį. Kiti parametrai gali būti perduodami kaip argumentai talpyklos saugyklos konstruktoriui:

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

Alternatyviai, galite nustatyti `ActionController::Base.cache_store` už konfigūracijos bloko ribų.

Galite pasiekti talpyklą, iškviesdami `Rails.cache`.

#### Ryšio baseino parinktys

Pagal numatymą [`:mem_cache_store`](#activesupport-cache-memcachestore) ir
[`:redis_cache_store`](#activesupport-cache-rediscachestore) yra sukonfigūruotos naudoti
ryšio baseiną. Tai reiškia, kad jei naudojate Puma ar kitą gijinį serverį,
galite turėti kelias gijas, vykdančias užklausas į talpyklos saugyklą tuo pačiu metu.
Jei norite išjungti ryšių kaupimą, nustatykite `:pool` parinktį kaip `false`, konfigūruodami talpyklą:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

Taip pat galite perrašyti numatytuosius kaupimo nustatymus, pateikdami atskiras parinktis `:pool` parinktyje:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: { size: 32, timeout: 1 }
```

* `:size` - Ši parinktis nustato ryšių skaičių vienam procesui (numatytoji reikšmė yra 5).

* `:timeout` - Ši parinktis nustato laukimo sekundes ryšiui (numatytoji reikšmė yra 5). Jei per laukimo laikotarpį nėra prieinamo ryšio, bus iškelta `Timeout::Error` klaida.

### `ActiveSupport::Cache::Store`

[`ActiveSupport::Cache::Store`][] suteikia pagrindą sąveikai su talpykla „Rails“. Tai yra abstrakti klasė, ir jos negalima naudoti atskirai. Vietoj to, turite naudoti konkretų klasės įgyvendinimą, susietą su saugojimo varikliu. „Rails“ pristato keletą įgyvendinimų, aprašytų žemiau.

Pagrindiniai API metodai yra [`read`][ActiveSupport::Cache::Store#read], [`write`][ActiveSupport::Cache::Store#write], [`delete`][ActiveSupport::Cache::Store#delete], [`exist?`][ActiveSupport::Cache::Store#exist?] ir [`fetch`][ActiveSupport::Cache::Store#fetch].

Talpyklos saugojimo konstruktoriui perduodamos parinktys bus laikomos numatytosiomis parinktimis atitinkamiems API metodams.


### `ActiveSupport::Cache::MemoryStore`

[`ActiveSupport::Cache::MemoryStore`][] laiko įrašus atmintyje toje pačioje „Ruby“ procese. Talpyklos
saugojimo dydis yra ribotas, nurodant `:size` parinktį
pradinėje funkcijoje (numatytoji reikšmė yra 32 MB). Kai talpykla viršija nustatytą dydį, vyksta
valymas ir pašalinami mažiausiai naudojami įrašai.

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

Jei naudojate kelis „Ruby on Rails“ serverio procesus (kas yra
atvejis, jei naudojate „Phusion Passenger“ arba „puma“ klasterizuotą režimą), tada jūsų „Rails“ serverio
procesų egzemplioriai negalės dalintis talpyklos duomenimis. Ši talpykla
nėra tinkama dideliems programų diegimams. Tačiau ji gali
gerai veikti mažose, mažai lankomose svetainėse su tik keletu serverio procesų,
taip pat plėtros ir testavimo aplinkose.

Naujiems „Rails“ projektams numatytasis įgyvendinimas yra naudojamas vystymo aplinkoje.

PASTABA: Naudodami `:memory_store`, procesai nesidalins talpyklos duomenimis,
tai neleis rankiniu būdu skaityti, rašyti arba panaikinti talpyklą per „Rails“ konsolę.


### `ActiveSupport::Cache::FileStore`

[`ActiveSupport::Cache::FileStore`][] naudoja failų sistemą įrašams saugoti. Nurodykite kelią į katalogą, kuriame bus saugomi saugojimo failai, inicializuojant talpyklą.

```ruby
config.cache_store = :file_store, "/path/to/cache/directory"
```

Šiai talpyklai kelios serverio procesai tame pačiame prietaise gali dalintis
talpykla. Ši talpykla yra tinkama mažai ir vidutinės apimties svetainėms,
kurios aptarnaujamos vienoje ar dviejose prietaisų. Skirtinguose prietaisuose veikiantys serverio procesai
galėtų dalintis talpykla, naudodami bendrą failų sistemą, tačiau ši sąranka nerekomenduojama.

Kadangi talpykla augs, kol bus užpildytas diskas, rekomenduojama
periodiškai išvalyti senus įrašus.

Tai yra numatytasis talpyklos įgyvendinimas (esant `"#{root}/tmp/cache/"`), jei
nėra pateikta aiški `config.cache_store`.


### `ActiveSupport::Cache::MemCacheStore`

[`ActiveSupport::Cache::MemCacheStore`][] naudoja Dangos `memcached` serverį, kad suteiktų centralizuotą talpyklą jūsų programai. „Rails“ pagal numatymą naudoja įtrauktą `dalli` grotelę. Tai šiuo metu populiariausia talpyklos įgyvendinimas produktų svetainėms. Jis gali būti naudojamas suteikiant vieną bendrą talpyklų klasterį su labai dideliu našumu ir atsparumu.

Inicializuojant talpyklą, turėtumėte nurodyti visų memcached serverių adresus savo klasteryje arba užtikrinti, kad būtų tinkamai nustatyta `MEMCACHE_SERVERS` aplinkos kintamoji.

```ruby
config.cache_store = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
```

Jei nenurodoma nei viena, jis priims, kad memcached veikia „localhost“ numatytuoju prievadu (`127.0.0.1:11211`), tačiau tai nėra idealus sąranka didesnėms svetainėms.

```ruby
config.cache_store = :mem_cache_store # Atsarginė vertė bus $MEMCACHE_SERVERS, tada 127.0.0.1:11211
```

Peržiūrėkite [`Dalli::Client` dokumentaciją](https://www.rubydoc.info/gems/dalli/Dalli/Client#initialize-instance_method) palaikomoms adreso tipams.

Šiai talpyklai [`write`][ActiveSupport::Cache::MemCacheStore#write] (ir `fetch`) metodas priima papildomas parinktis, kurios naudojasi memcached specifinėmis funkcijomis.


### `ActiveSupport::Cache::RedisCacheStore`

[`ActiveSupport::Cache::RedisCacheStore`][] naudoja „Redis“ palaikymą automatiniam išmetimui
pasiekus maksimalią atmintį, leidžiant jai elgtis panašiai kaip „Memcached“ talpyklos serveris.

Diegimo pastaba: „Redis“ pagal numatymą nebaigia galiojimo laiko, todėl atidžiai naudokite
skirtą „Redis“ talpyklą. Neužpildykite savo nuolatinio „Redis“ serverio
nestabiliais talpyklos duomenimis! Išsamiai perskaitykite
[Redis talpyklos serverio diegimo vadovą](https://redis.io/topics/lru-cache).

Tik talpyklai skirtame „Redis“ serveryje nustatykite `maxmemory-policy` vienam iš „allkeys“ variantų.
„Redis“ 4+ palaiko mažiausiai dažnai naudojamą išmetimą (`allkeys-lfu`), puikus
numatytasis pasirinkimas. „Redis“ 3 ir ankstesnės versijos turėtų naudoti mažiausiai neseniai naudojamą išmetimą (`allkeys-lru`).
Nustatykite talpyklos skaitymo ir rašymo laiko limitus santykinai mažus. Dažnai atkurti talpykloje saugomą reikšmę yra greičiau nei laukti ilgiau nei sekundę, kad ją gautumėte. Skaitymo ir rašymo laiko limitai pagal nutylėjimą yra 1 sekundė, bet juos galima nustatyti dar mažesnius, jei jūsų tinklas yra nuolat mažo delsimo.

Pagal nutylėjimą, jei ryšys su Redis nutrūksta per užklausą, talpyklos saugojimas nebandys vėl prisijungti. Jei dažnai patiriate atsijungimus, galite įjungti prisijungimo bandymus.

Talpyklos skaitymas ir rašymas niekada nekelia išimčių; jie tiesiog grąžina `nil`, elgdamiesi taip, tarsi talpykloje nieko nebūtų. Norėdami įvertinti, ar jūsų talpykla sukelia išimtis, galite nurodyti `error_handler`, kuris praneš apie išimtis rinkimo paslaugai. Jis turi priimti tris raktažodžius: `method`, talpyklos saugojimo metodą, kuris buvo iš pradžių iškviestas; `returning`, grąžintą reikšmę vartotojui, paprastai `nil`; ir `exception`, išimtį, kuri buvo išgelbėta.

Norėdami pradėti, pridėkite redis juostelę prie savo Gemfile:

```ruby
gem 'redis'
```

Galų gale, pridėkite konfigūraciją atitinkamame `config/environments/*.rb` faile:

```ruby
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
```

Sudėtingesnė, gamybinė Redis talpyklos saugykla gali atrodyti taip:

```ruby
cache_servers = %w(redis://cache-01:6379/0 redis://cache-02:6379/0)
config.cache_store = :redis_cache_store, { url: cache_servers,

  connect_timeout:    30,  # Numatytasis yra 20 sekundės
  read_timeout:       0.2, # Numatytasis yra 1 sekundė
  write_timeout:      0.2, # Numatytasis yra 1 sekundė
  reconnect_attempts: 1,   # Numatytasis yra 0

  error_handler: -> (method:, returning:, exception:) {
    # Praneškite apie klaidas "Sentry" kaip įspėjimus
    Sentry.capture_exception exception, level: 'warning',
      tags: { method: method, returning: returning }
  }
}
```


### `ActiveSupport::Cache::NullStore`

[`ActiveSupport::Cache::NullStore`][] yra apribota kiekvienai interneto užklausai ir valo saugomas reikšmes užklausos pabaigoje. Ji skirta naudoti vystymo ir testavimo aplinkose. Tai gali būti labai naudinga, kai turite kodą, kuris tiesiogiai sąveikauja su `Rails.cache`, bet talpykla trukdo matyti kodų pakeitimų rezultatus.

```ruby
config.cache_store = :null_store
```


### Individualios talpyklos saugyklos

Galite sukurti savo individualią talpyklos saugyklą, tiesiog išplėsdami `ActiveSupport::Cache::Store` ir įgyvendindami atitinkamus metodus. Taip galite į savo „Rails“ programą įtraukti bet kurią talpinimo technologiją.

Norėdami naudoti individualią talpyklos saugyklą, tiesiog nustatykite talpyklos saugyklą kaip naują savo individualios klasės egzempliorių.

```ruby
config.cache_store = MyCacheStore.new
```

Talpyklos raktai
----------

Talpykloje naudojami raktai gali būti bet koks objektas, kuris atsako į `cache_key` arba `to_param` metodus. Jei norite generuoti individualius raktus, savo klasėse galite įgyvendinti `cache_key` metodą. „Active Record“ sugeneruos raktus pagal klasės pavadinimą ir įrašo ID.

Galite naudoti raktus kaip reikšmių talpyklos raktus.

```ruby
# Tai yra teisėtas talpyklos raktas
Rails.cache.read(site: "mysite", owners: [owner_1, owner_2])
```

Raktai, kuriuos naudojate `Rails.cache`, nebus tokie patys kaip tie, kurie iš tikrųjų naudojami saugojimo variklyje. Jie gali būti modifikuojami su pavadinimo erdve arba keičiami, kad atitiktų technologijos pagrindo apribojimus. Tai reiškia, pavyzdžiui, kad negalite išsaugoti reikšmių su `Rails.cache` ir tada bandyti ištraukti jas su `dalli` juostele. Tačiau taip pat nereikia nerimauti dėl viršijimo „memcached“ dydžio ribos arba pažeidimo sintaksės taisyklių.

Sąlyginio GET palaikymas
-----------------------

Sąlyginis GET yra „HTTP“ specifikacijos funkcija, kuri leidžia interneto serveriams pranešti naršyklėms, kad atsakymas į GET užklausą nepasikeitė nuo paskutinės užklausos ir gali būti saugiai paimtas iš naršyklės talpyklos.

Jie veikia naudojant `HTTP_IF_NONE_MATCH` ir `HTTP_IF_MODIFIED_SINCE` antraštes, kad perduotų atgal ir į priekį unikalų turinio identifikatorių ir laiko žymą, kada turinys buvo paskutinį kartą pakeistas. Jei naršyklė atlieka užklausą, kurioje turinio identifikatorius (ETag) arba paskutinio pakeitimo laiko žyma atitinka serverio versiją, tada serveriui tereikia grąžinti tuščią atsakymą su nekeista būsena.

Tai yra serverio (t. y. mūsų) atsakomybė ieškoti paskutinio pakeitimo laiko žymos ir if-none-match antraštės ir nustatyti, ar grąžinti visą atsakymą. Su sąlyginio-get palaikymu „Rails“ tai yra gana paprasta užduotis:

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    # Jei užklausa yra pasenusi pagal nurodytą laiko žymą ir etag reikšmę
    # (t. y. ją reikia iš naujo apdoroti), tada vykdykite šį bloką
    if stale?(last_modified: @product.updated_at.utc, etag: @product.cache_key_with_version)
      respond_to do |wants|
        # ... įprasta atsakymo apdorojimas
      end
    end

    # Jei užklausa yra nauja (t. y. ji nepakeista), tada jums nereikia nieko daryti.
    # Numatytasis renderis tai patikrina naudodamas parametrus,
    # naudotus ankstesniam stale? iškvietimui, ir automatiškai siunčia
    # :not_modified. Tai viskas, jūs baigėte.
  end
end
```
Vietoj parinkčių hash galite tiesiogiai perduoti modelį. „Rails“ naudos „updated_at“ ir „cache_key_with_version“ metodus nustatant „last_modified“ ir „etag“:

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    if stale?(@product)
      respond_to do |wants|
        # ... įprasta atsakymo apdorojimo logika
      end
    end
  end
end
```

Jei neturite jokio specialaus atsakymo apdorojimo ir naudojate numatytąjį atvaizdavimo mechanizmą (t. y. nenaudojate „respond_to“ arba pačių kviečiate „render“), tada turite lengvą pagalbininką „fresh_when“:

```ruby
class ProductsController < ApplicationController
  # Jei užklausa yra nauja, tai automatiškai bus grąžintas :not_modified,
  # o jei ji yra pasenusi, bus atvaizduotas numatytasis šablonas (product.*).

  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, etag: @product
  end
end
```

Kartais norime talpinti atsakymą, pvz., statinį puslapį, kuris niekada nesibaigia. Tam pasiekti galime naudoti „http_cache_forever“ pagalbininką, ir taip naršyklė ir tarpinės atmintys jį talpins amžinai.

Pagal numatytuosius nustatymus talpinami atsakymai bus privačūs, talpinami tik vartotojo naršyklėje. Norint leisti tarpinėms atmintims talpinti atsakymą, nustatykite „public: true“, nurodydami, kad jos gali aptarnauti talpintą atsakymą visiems vartotojams.

Naudodami šį pagalbininką, „last_modified“ antraštė bus nustatyta į „Time.new(2011, 1, 1).utc“, o „expires“ antraštė bus nustatyta į 100 metų.

ĮSPĖJIMAS: Šią metodą naudokite atsargiai, nes naršyklės/tarpinės atmintys negalės atšaukti talpinto atsakymo, nebent naršyklės talpyklą būtų priverstinai išvalyta.

```ruby
class HomeController < ApplicationController
  def index
    http_cache_forever(public: true) do
      render
    end
  end
end
```

### Stiprūs prieš silpnus ETag

Pagal numatytuosius nustatymus „Rails“ generuoja silpnus ETag. Silpni ETag leidžia semantiškai ekvivalentiškiems atsakymams turėti tą pačią ETag, net jei jų kūnai nesutampa tiksliai. Tai naudinga, kai norime, kad puslapis nebūtų pergeneruojamas dėl nedidelių pakeitimų atsakymo kūne.

Silpni ETag turi pradžioje „W/“, kad juos būtų galima atskirti nuo stiprių ETag.

```
W/"618bbc92e2d35ea1945008b42799b0e7" → Silpnas ETag
"618bbc92e2d35ea1945008b42799b0e7" → Stiprus ETag
```

Skirtingai nei silpnas ETag, stiprus ETag reiškia, kad atsakymas turi būti tiksliai tas pats ir baitais identiškas. Tai naudinga, kai darome diapazono užklausas didelio vaizdo ar PDF failo viduje. Kai kurios CDN palaiko tik stiprius ETag, pvz., „Akamai“. Jei absoliučiai reikia generuoti stiprų ETag, tai galima padaryti taip.

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, strong_etag: @product
  end
end
```

Stiprų ETag taip pat galite nustatyti tiesiogiai atsakyme.

```ruby
response.strong_etag = response.body # => "618bbc92e2d35ea1945008b42799b0e7"
```

Talpinimas vystymo metu
-----------------------

Dažnai norime patikrinti savo programos talpinimo strategiją vystymo metu. „Rails“ teikia „rails“ komandą „dev:cache“, skirtą lengvai įjungti/išjungti talpinimą.

```bash
$ bin/rails dev:cache
Vystymo režimas dabar talpinamas.
$ bin/rails dev:cache
Vystymo režimas nebėra talpinamas.
```

Pagal numatytuosius nustatymus, kai vystymo režimo talpinimas yra *išjungtas*, „Rails“ naudoja
[`:null_store`](#activesupport-cache-nullstore).

Nuorodos
--------

* [DHH straipsnis apie raktų pagrindu galiojimo pabaigą](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
* [Ryan Bates „Railscast“ apie talpinimo santraukas](http://railscasts.com/episodes/387-cache-digests)
[`config.action_controller.perform_caching`]: configuring.html#config-action-controller-perform-caching
[`ActiveSupport::Cache::Store`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
[ActiveSupport::Cache::Store#delete]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-delete
[ActiveSupport::Cache::Store#exist?]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-exist-3F
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#read]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-read
[ActiveSupport::Cache::Store#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-write
[`ActiveSupport::Cache::MemoryStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[`ActiveSupport::Cache::FileStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[`ActiveSupport::Cache::MemCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemCacheStore#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html#method-i-write
[`ActiveSupport::Cache::RedisCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[`ActiveSupport::Cache::NullStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/NullStore.html
