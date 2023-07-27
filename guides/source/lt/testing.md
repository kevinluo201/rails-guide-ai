**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 6da9945dc313b748574b8aca256f1435
Rails aplikacijų testavimas
==========================

Šiame vadove aptariamos įdiegtos mechanizmai „Rails“ aplikacijų testavimui.

Po šio vadovo perskaitymo žinosite:

* „Rails“ testavimo terminologiją.
* Kaip rašyti vienetinius, funkcinės, integracinės ir sistemos testus savo aplikacijai.
* Kitus populiarius testavimo metodus ir įskiepius.

--------------------------------------------------------------------------------

Kodėl rašyti testus savo „Rails“ aplikacijoms?
--------------------------------------------

„Rails“ labai supaprastina testų rašymą. Jis pradeda generuoti testų kodą, kai kuriate savo modelius ir valdiklius.

Paleidę savo „Rails“ testus galite užtikrinti, kad jūsų kodas atitinka norimą funkcionalumą net po didelių kodų pertvarkymų.

„Rails“ testai taip pat gali simuliuoti naršyklės užklausas, todėl galite testuoti savo aplikacijos atsaką, neturėdami testuoti per naršyklę.

Įvadas į testavimą
-----------------------

Testavimo palaikymas buvo įtrauktas į „Rails“ nuo pat pradžių. Tai nebuvo „o! pridėkime palaikymą testams, nes jie nauji ir stilingi“ epifanija.

### „Rails“ pasiruošęs testavimui nuo pat pradžių

„Rails“ jums sukuria `test` katalogą, kai tik sukuriate „Rails“ projektą naudodami `rails new` _application_name_. Jei išvardinsite šio katalogo turinį, pamatysite:

```bash
$ ls -F test
application_system_test_case.rb  controllers/                     helpers/                         mailers/                         system/
channels/                        fixtures/                        integration/                     models/                          test_helper.rb
```

`helpers`, `mailers` ir `models` katalogai skirti laikyti testus, atitinkamai, rodinių pagalbininkams, pašto siuntėjams ir modeliams. `channels` katalogas skirtas laikyti testus, skirtus „Action Cable“ ryšiui ir kanalams. `controllers` katalogas skirtas laikyti testus, skirtus valdikliams, maršrutams ir rodiniams. `integration` katalogas skirtas laikyti testus, skirtus sąveikai tarp valdiklių.

Sistemos testų katalogas laiko sistemos testus, kurie naudojami visapusiškam naršyklės testavimui. Sistemos testai leidžia jums testuoti savo aplikaciją taip, kaip ją patiria jūsų vartotojai, ir padeda jums testuoti savo „JavaScript“. Sistemos testai paveldi iš „Capybara“ ir atlieka naršyklės testus jūsų aplikacijai.

Testiniai duomenys yra būdas organizuoti testavimo duomenis; jie yra `fixtures` kataloge.

Kai pirmą kartą generuojamas susijęs testas, taip pat bus sukurtas `jobs` katalogas.

`test_helper.rb` failas laiko numatytąją konfigūraciją jūsų testams.

`application_system_test_case.rb` laiko numatytąją konfigūraciją jūsų sistemos testams.

### Testavimo aplinka

Pagal numatytuosius nustatymus kiekviena „Rails“ aplikacija turi tris aplinkas: vystymo, testavimo ir produkto.

Kiekvienos aplinkos konfigūraciją galima keisti panašiai. Šiuo atveju galime keisti mūsų testavimo aplinką, keisdami parinktis, esančias `config/environments/test.rb`.

PASTABA: Jūsų testai vykdomi pagal `RAILS_ENV=test`.

### „Rails“ susitinka su „Minitest“

Jeigu prisimenate, mes naudojome `bin/rails generate model` komandą
[Pradedant su „Rails“](getting_started.html) vadove. Mes sukūrėme pirmąjį
modelį, ir tarp kitų dalykų jis sukūrė testo šablonus `test` kataloge:

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

Numatytasis testo šablonas `test/models/article_test.rb` atrodo taip:

```ruby
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

Eilutė po eilutės šio failo nagrinėjimas padės jums susiorientuoti „Rails“ testavimo kodo ir terminologijos atžvilgiu.

```ruby
require "test_helper"
```

Įtraukdami šį failą, `test_helper.rb`, įkeliamas numatytasis konfigūravimas, skirtas paleisti mūsų testus. Mes įtrauksime šį failą į visus rašomus testus, todėl visiems mūsų testams bus prieinami šiame faile pridėti metodai.

```ruby
class ArticleTest < ActiveSupport::TestCase
```

`ArticleTest` klasė apibrėžia _testo atvejį_, nes ji paveldi iš `ActiveSupport::TestCase`. `ArticleTest` taigi turi visus iš `ActiveSupport::TestCase` paveldėtus metodus. Vėliau šiame vadove pamatysime keletą iš jų.

Bet koks metodas, apibrėžtas klasėje, paveldėtoje iš `Minitest::Test`
(kuri yra `ActiveSupport::TestCase` superklasė) ir prasidedantis su `test_`, paprasčiausiai vadinamas testu. Taigi, metodai, apibrėžti kaip `test_password` ir `test_valid_password`, yra teisėti testo pavadinimai ir yra automatiškai vykdomi, kai vykdomas testo atvejis.
Rails taip pat prideda `test` metodą, kuris priima testo pavadinimą ir bloką. Jis generuoja įprastinį `Minitest::Unit` testą, kurio metodų pavadinimai pradeda nuo `test_`. Taigi, jums nereikia rūpintis metodų pavadinimais, ir galite parašyti kažką tokio:

```ruby
test "tiesa" do
  assert true
end
```

Tai apytiksliai tas pats, kas rašyti tai:

```ruby
def test_tiesa
  assert true
end
```

Nors vis tiek galite naudoti įprastus metodų apibrėžimus, naudojant `test` makro leidžia rašyti aiškesnį testo pavadinimą.

PASTABA: Metodo pavadinimas generuojamas pakeičiant tarpus brūkšneliais. Rezultatas neturi būti galiojantis Ruby identifikatorius - pavadinimas gali turėti skyrybos ženklų ir t.t. Tai yra todėl, kad Ruby techniškai bet koks eilutė gali būti metodo pavadinimu. Tai gali reikalauti `define_method` ir `send` iškvietimų, kad veiktų tinkamai, tačiau formaliai pavadinimui yra mažai apribojimų.

Toliau pažvelkime į pirmąją mūsų patikrinimą:

```ruby
assert true
```

Patikrinimas yra kodo eilutė, kuri vertina objektą (arba išraišką) pagal tikėtus rezultatus. Pavyzdžiui, patikrinimas gali patikrinti:

* ar ši vertė = ta vertė?
* ar šis objektas yra tuščias?
* ar ši kodo eilutė išmeta išimtį?
* ar vartotojo slaptažodis yra ilgesnis nei 5 simboliai?

Kiekvienas testas gali turėti vieną ar daugiau patikrinimų, be jokių apribojimų, kiek patikrinimų leidžiama. Tik kai visi patikrinimai sėkmingi, testas bus sėkmingas.

#### Jūsų pirmas nesėkmingas testas

Norėdami pamatyti, kaip pranešama apie nesėkmingą testą, galite pridėti nesėkmingą testą prie `article_test.rb` testo atvejo.

```ruby
test "neturėtų išsaugoti straipsnio be pavadinimo" do
  article = Article.new
  assert_not article.save
end
```

Paleiskime šį naujai pridėtą testą (kur `6` yra eilutės numeris, kurioje apibrėžiamas testas).

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 44656

# Running:

F

Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Expected true to be nil or false


bin/rails test test/models/article_test.rb:6



Finished in 0.023918s, 41.8090 runs/s, 41.8090 assertions/s.

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
```

Išvestyje `F` žymi nesėkmę. Galite pamatyti atitinkamą seką, rodomą po `Failure`, kartu su nesėkmingo testo pavadinimu. Keli kitos eilutės yra steko sekos, po to yra pranešimas, kuriame paminėta tikroji ir tikėtina reikšmė, kurią nurodo patikrinimas. Numatyti patikrinimo pranešimai suteikia pakankamai informacijos, kad padėtų nustatyti klaidą. Norint padaryti patikrinimo nesėkmės pranešimą aiškesnį, kiekvienas patikrinimas suteikia pasirinktinį pranešimo parametrą, kaip parodyta čia:

```ruby
test "neturėtų išsaugoti straipsnio be pavadinimo" do
  article = Article.new
  assert_not article.save, "Išsaugotas straipsnis be pavadinimo"
end
```

Paleidus šį testą, rodomas draugiškesnis patikrinimo pranešimas:

```
Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Išsaugotas straipsnis be pavadinimo
```

Dabar, norint, kad šis testas būtų sėkmingas, galime pridėti modelio lygio tikrinimą _title_ laukui.

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

Dabar testas turėtų būti sėkmingas. Patikrinkime paleidę testą dar kartą:

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 31252

# Running:

.

Finished in 0.027476s, 36.3952 runs/s, 36.3952 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

Dabar, jei pastebėjote, mes pirmiausia parašėme testą, kuris nepavyksta norimai funkcionalumui, tada parašėme kodą, kuris prideda funkcionalumą, ir galiausiai užtikrinome, kad mūsų testas būtų sėkmingas. Šis požiūris į programinės įrangos kūrimą vadinamas [_Test-Driven Development_ (TDD)](http://c2.com/cgi/wiki?TestDrivenDevelopment).

#### Kaip atrodo klaida

Norėdami pamatyti, kaip pranešama apie klaidą, čia yra testas, kuriame yra klaida:

```ruby
test "turėtų pranešti apie klaidą" do
  # some_undefined_variable nėra apibrėžta kitur testo atveju
  some_undefined_variable
  assert true
end
```
Dabar konsolėje galite pamatyti dar daugiau išvesties išvykstant testus:

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1808

# Running:

.E

Klaida:
ArticleTest#test_should_report_error:
NameError: kintamasis arba metodas 'some_undefined_variable' nėra apibrėžtas #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9



Baigta per 0.040609s, 49.2500 vykdymų/s, 24.6250 tikrinimų/s.

2 vykdymai, 1 tikrinimas, 0 nesėkmės, 1 klaida, 0 praleidimai
```

Pastebėkite 'E' išvestyje. Tai žymi testą su klaida.

PASTABA: Kiekvieno testo metodo vykdymas sustoja, kai randama klaida arba tikrinimo nesėkmė, o testų rinkinys tęsiasi su kitu metodu. Visi testo metodai vykdomi atsitiktine tvarka. [`config.active_support.test_order`][] parinktis gali būti naudojama konfigūruoti testų tvarką.

Kai testas nepavyksta, jums pateikiamas atitinkamas atgalinės sekos žemėlapis. Pagal numatytuosius nustatymus „Rails“ filtruoja tą atgalinės sekos žemėlapį ir spausdina tik jūsų programai svarbias eilutes. Tai pašalina pagrindinio pagrindo triukšmą ir padeda sutelkti dėmesį į jūsų kodą. Tačiau yra situacijų, kai norite pamatyti visą atgalinės sekos žemėlapį. Nustatykite `-b` (arba `--backtrace`) argumentą, kad įgalintumėte šį veiksmą:

```bash
$ bin/rails test -b test/models/article_test.rb
```

Jei norime, kad šis testas pavyktų, galime jį pakeisti naudodami `assert_raises` taip:

```ruby
test "should report error" do
  # some_undefined_variable kitur testo atveju nėra apibrėžtas
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

Šis testas dabar turėtų pavykti.


### Prieinami tikrinimai

Jau matėte keletą prieinamų tikrinimų. Tikrinimai yra testavimo darbininkai. Jie yra tie, kurie iš tikrųjų atlieka patikrinimus, kad būtų užtikrinta, jog viskas vyksta kaip planuota.

Čia pateikiamas ištraukos iš tikrinimų, kuriuos galite naudoti su
[`Minitest`](https://github.com/minitest/minitest), pagal nutylėjimą naudojamu testavimo biblioteka
naudojama „Rails“. `[msg]` parametras yra pasirinktinis eilutės žinutė, kurią galite
nurodyti, kad padarytumėte aiškesnes testo nesėkmės žinutes.

| Tikrinimas                                                        | Tikslas |
| ---------------------------------------------------------------- | ------- |
| `assert( test, [msg] )`                                          | Užtikrina, kad `test` būtų teisingas.|
| `assert_not( test, [msg] )`                                      | Užtikrina, kad `test` būtų neteisingas.|
| `assert_equal( expected, actual, [msg] )`                        | Užtikrina, kad `expected == actual` būtų teisinga.|
| `assert_not_equal( expected, actual, [msg] )`                    | Užtikrina, kad `expected != actual` būtų teisinga.|
| `assert_same( expected, actual, [msg] )`                         | Užtikrina, kad `expected.equal?(actual)` būtų teisinga.|
| `assert_not_same( expected, actual, [msg] )`                     | Užtikrina, kad `expected.equal?(actual)` būtų neteisinga.|
| `assert_nil( obj, [msg] )`                                       | Užtikrina, kad `obj.nil?` būtų teisinga.|
| `assert_not_nil( obj, [msg] )`                                   | Užtikrina, kad `obj.nil?` būtų neteisinga.|
| `assert_empty( obj, [msg] )`                                     | Užtikrina, kad `obj` yra `empty?`.|
| `assert_not_empty( obj, [msg] )`                                 | Užtikrina, kad `obj` nėra `empty?`.|
| `assert_match( regexp, string, [msg] )`                          | Užtikrina, kad eilutė atitinka reguliariąją išraišką.|
| `assert_no_match( regexp, string, [msg] )`                       | Užtikrina, kad eilutė neatitinka reguliariąją išraišką.|
| `assert_includes( collection, obj, [msg] )`                      | Užtikrina, kad `obj` yra `collection`.|
| `assert_not_includes( collection, obj, [msg] )`                  | Užtikrina, kad `obj` nėra `collection`.|
| `assert_in_delta( expected, actual, [delta], [msg] )`            | Užtikrina, kad skaičiai `expected` ir `actual` yra vienas kitam arti `delta`.|
| `assert_not_in_delta( expected, actual, [delta], [msg] )`        | Užtikrina, kad skaičiai `expected` ir `actual` nėra vienas kitam arti `delta`.|
| `assert_in_epsilon ( expected, actual, [epsilon], [msg] )`       | Užtikrina, kad skaičiai `expected` ir `actual` turi santykinį klaidą mažesnę nei `epsilon`.|
| `assert_not_in_epsilon ( expected, actual, [epsilon], [msg] )`   | Užtikrina, kad skaičiai `expected` ir `actual` turi santykinį klaidą, kuri nėra mažesnė nei `epsilon`.|
| `assert_throws( symbol, [msg] ) { block }`                       | Užtikrina, kad duotas blokas išmeta simbolį.|
| `assert_raises( exception1, exception2, ... ) { block }`         | Užtikrina, kad duotas blokas iškelia vieną iš duotų išimčių.|
| `assert_instance_of( class, obj, [msg] )`                        | Užtikrina, kad `obj` yra `class` pavyzdys.|
| `assert_not_instance_of( class, obj, [msg] )`                    | Užtikrina, kad `obj` nėra `class` pavyzdys.|
| `assert_kind_of( class, obj, [msg] )`                            | Užtikrina, kad `obj` yra `class` pavyzdys arba jam paveldima.|
| `assert_not_kind_of( class, obj, [msg] )`                        | Užtikrina, kad `obj` nėra `class` pavyzdys ir jam nėra paveldima.|
| `assert_respond_to( obj, symbol, [msg] )`                        | Užtikrina, kad `obj` atsako į `symbol`.|
| `assert_not_respond_to( obj, symbol, [msg] )`                    | Užtikrina, kad `obj` neatstoja `symbol`.|
| `assert_operator( obj1, operator, [obj2], [msg] )`               | Užtikrina, kad `obj1.operator(obj2)` yra teisinga.|
| `assert_not_operator( obj1, operator, [obj2], [msg] )`           | Užtikrina, kad `obj1.operator(obj2)` yra neteisinga.|
| `assert_predicate ( obj, predicate, [msg] )`                     | Užtikrina, kad `obj.predicate` yra teisinga, pvz., `assert_predicate str, :empty?`|
| `assert_not_predicate ( obj, predicate, [msg] )`                 | Užtikrina, kad `obj.predicate` yra neteisinga, pvz., `assert_not_predicate str, :empty?`|
| `flunk( [msg] )`                                                 | Užtikrina nesėkmę. Tai naudinga, norint aiškiai pažymėti testą, kuris dar nėra baigtas.|
Aukščiau pateikti teiginiai yra tik dalis teiginių, kuriuos palaiko minitest. Išsamią ir naujausią sąrašą galite rasti [Minitest API dokumentacijoje](http://docs.seattlerb.org/minitest/), konkrečiai [`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html).

Dėl testavimo pagrindo modularumo, galima kurti savo teiginius. Iš tikrųjų, tai yra tai, ką daro "Rails". Jis įtraukia keletą specializuotų teiginių, kad jums būtų lengviau.

PASTABA: Savo teiginių kūrimas yra sudėtinga tema, kurią šiame vadove aptarti neketiname.

### "Rails" konkretūs teiginiai

"Rails" į minitest pagrindą prideda savo pritaikytų teiginių:

| Teiginys                                                                         | Tikslas |
| --------------------------------------------------------------------------------- | ------- |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | Patikrinti skaitinį skirtumą tarp išraiškos grąžinimo vertės kaip rezultato, kuris yra vertinamas per perduodamą bloką.|
| [`assert_no_difference(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | Patvirtina, kad skaitinės išraiškos vertė nepasikeitė prieš ir po perduoto bloko iškvietimo.|
| [`assert_changes(expressions, message = nil, from:, to:, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes) | Patikrinti, ar išraiškos vertė pasikeitė po perduoto bloko iškvietimo.|
| [`assert_no_changes(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes) | Patikrinti, ar išraiškos vertė nepasikeitė po perduoto bloko iškvietimo.|
| [`assert_nothing_raised { block }`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised) | Užtikrina, kad pateiktas blokas neperskeltų jokių išimčių.|
| [`assert_recognizes(expected_options, path, extras={}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | Patvirtina, kad nurodyto kelio maršrutizavimas buvo tvarkingas ir kad analizuoti parametrai (duoti expected_options hae) atitinka kelią. Iš esmės, tai patvirtina, kad "Rails" atpažįsta maršrutą, kurį nurodo expected_options.|
| [`assert_generates(expected_path, options, defaults={}, extras = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | Patvirtina, kad pateikti parametrai gali būti naudojami generuoti pateiktą kelią. Tai yra atvirkštinis veiksmas nei assert_recognizes. "Extras" parametras naudojamas nurodyti papildomų užklausos parametrų pavadinimus ir reikšmes, kurios būtų užklausos eilutėje. "Message" parametras leidžia nurodyti pasirinktinį klaidos pranešimą, jei patikrinimas nepavyksta.|
| [`assert_response(type, message = nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | Patvirtina, kad atsakas turi tam tikrą būsenos kodą. Galite nurodyti `:success`, jei norite nurodyti 200-299, `:redirect`, jei norite nurodyti 300-399, `:missing`, jei norite nurodyti 404, arba `:error`, jei norite atitikti 500-599 intervalą. Taip pat galite perduoti konkretų būsenos numerį arba jo simbolinį ekvivalentą. Daugiau informacijos rasite [visų būsenos kodų](https://rubydoc.info/gems/rack/Rack/Utils#HTTP_STATUS_CODES-constant) ir jų [atitikmenų](https://rubydoc.info/gems/rack/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant) sąraše.|
| [`assert_redirected_to(options = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | Patvirtina, kad atsakas yra peradresuojamas į URL, atitinkantį nurodytus parametrus. Taip pat galite perduoti pavadinimus turinčius maršrutus, pvz., `assert_redirected_to root_path`, ir "Active Record" objektus, pvz., `assert_redirected_to @article`.|

Kitame skyriuje pamatysite, kaip naudoti kai kuriuos iš šių teiginių.

### Trumpas pastebėjimas apie testavimo atvejus

Visi pagrindiniai teiginiai, tokie kaip `assert_equal`, apibrėžti `Minitest::Assertions`, taip pat yra prieinami klasėse, kurias naudojame savo testavimo atvejuose. Iš tikrųjų, "Rails" suteikia šias klases, kurias galite paveldėti:

* [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](https://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::IntegrationTest`](https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActionDispatch::SystemTestCase`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](https://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

Kiekviena iš šių klasių įtraukia `Minitest::Assertions`, leidžiant mums naudoti visus pagrindinius teiginius savo testuose.

PASTABA: Daugiau informacijos apie `Minitest` rasite [jo dokumentacijoje](http://docs.seattlerb.org/minitest).

### "Rails" testų paleidimas

Visus testus galime paleisti vienu metu naudodami `bin/rails test` komandą.

Arba galime paleisti vieną testų failą perduodami `bin/rails test` komandai failo pavadinimą, kuriame yra testavimo atvejai.

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1559

# Running:

..

Finished in 0.027034s, 73.9810 runs/s, 110.9715 assertions/s.

2 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

Tai paleis visus testo metodus iš testavimo atvejo.
Norint paleisti tam tikrą testo metodą iš testo atvejo, galite nurodyti `-n` arba `--name` žymeklį ir testo metodo pavadinimą.

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Vykdomi parametrai: -n test_the_truth --seed 43583

# Vykdoma:

.

Baigti testai per 0.009064 s, 110.3266 testai/s, 110.3266 patvirtinimai/s.

1 testas, 1 patvirtinimas, 0 nesėkmės, 0 klaidos, 0 praleidimai
```

Taip pat galite paleisti testą tam tikroje eilutėje nurodydami eilutės numerį.

```bash
$ bin/rails test test/models/article_test.rb:6 # paleisti konkretų testą ir eilutę
```

Taip pat galite paleisti visą testų katalogą nurodydami katalogo kelią.

```bash
$ bin/rails test test/controllers # paleisti visus testus iš konkretaus katalogo
```

Testų vykdyklė taip pat teikia daug kitų funkcijų, pvz., greito nesėkmės atveju, atidėti testo rezultatų išvestį iki testo vykdymo pabaigos ir t.t. Patikrinkite testų vykdyklės dokumentaciją kaip nurodyta žemiau:

```bash
$ bin/rails test -h
Naudojimas: rails test [parametrai] [failai arba katalogai]

Vieną testą galite paleisti pridedant eilutės numerį prie failo pavadinimo:

    bin/rails test test/models/user_test.rb:27

Galite paleisti kelis failus ir katalogus vienu metu:

    bin/rails test test/controllers test/integration/login_test.rb

Pagal numatytuosius nustatymus testų nesėkmės ir klaidos pranešamos tiesiogiai vykdymo metu.

minitest parametrai:
    -h, --help                       Rodyti šią pagalbą.
        --no-plugins                 Apeiti minitest įskiepių automatinį įkėlimą (arba nustatyti $MT_NO_PLUGINS).
    -s, --seed SEED                  Nustato atsitiktinį sėklą. Taip pat per aplinką. Pvz.: SEED=n rake
    -v, --verbose                    Išsamus. Rodyti progreso informaciją apie failų apdorojimą.
    -n, --name PATTERN               Filtruoti pagal /regexp/ arba eilutę.
        --exclude PATTERN            Pašalinti /regexp/ arba eilutę iš vykdymo.

Žinomi plėtiniai: rails, pride
    -w, --warnings                   Paleisti su įjungtomis Ruby įspėjimais
    -e, --environment ENV            Paleisti testus ENV aplinkoje
    -b, --backtrace                  Rodyti visą atkarpą
    -d, --defer-output               Išvesti testų nesėkmes ir klaidas po testo vykdymo
    -f, --fail-fast                  Nutraukti testo vykdymą pirmoje nesėkmėje arba klaidoje
    -c, --[no-]color                 Įjungti spalvą išvestyje
    -p, --pride                      Pasididžiuokite savo testavimo pasiekimais!
```

### Testų vykdymas nuolatinėje integracijoje (CI)

Norint paleisti visus testus nuolatinėje integracijos aplinkoje, jums tereikia vieno komandos:

```bash
$ bin/rails test
```

Jei naudojate [Sistemos testus](#sistemos-testavimas), `bin/rails test` jų nevykdys, nes jie gali būti lėti. Norėdami juos taip pat paleisti, pridėkite dar vieną CI žingsnį, kuris paleidžia `bin/rails test:system`, arba pakeiskite pirmąjį žingsnį į `bin/rails test:all`, kuris paleidžia visus testus, įskaitant sistemos testus.

Lygiagretus testavimas
----------------

Lygiagretus testavimas leidžia jums lygiagrečiai vykdyti testų rinkinį. Nors numatytasis būdas yra kurti procesus naudojant Ruby DRb sistemą, taip pat palaikomas gijų naudojimas. Lygiagretus testavimas sumažina laiką, kurį užtrunka viso testų rinkinio vykdymas.

### Lygiagretus testavimas naudojant procesus

Numatytasis lygiagretinimo būdas yra kurti procesus naudojant Ruby DRb sistemą. Procesai yra kuriama pagal pateiktų darbuotojų skaičių. Numatytasis skaičius yra faktinis branduolių skaičius jūsų mašinoje, bet jį galima pakeisti perduodant skaičių parallelize metodui.

Norėdami įgalinti lygiagretinimą, pridėkite šį kodą į savo `test_helper.rb`:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

Perduodamas darbuotojų skaičius yra procesų kūrimo skaičius. Galite norėti lygiagrečiai vykdyti vietinį testų rinkinį kitaip nei CI, todėl aplinkos kintamasis suteikiamas galimybę lengvai keisti darbuotojų skaičių, kurį testų vykdymas turėtų naudoti:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

Lygiagretinant testus, Active Record automatiškai tvarko duomenų bazės kūrimą ir schemos įkėlimą į duomenų bazę kiekvienam procesui. Duomenų bazės bus papildytos numeriu, atitinkančiu darbuotoją. Pavyzdžiui, jei turite 2 darbuotojus, testai sukurs `test-database-0` ir `test-database-1` atitinkamai.
Jei perduodamų darbuotojų skaičius yra 1 ar mažesnis, procesai nebus šakojami ir testai nebus parallelizuojami, o testai naudos originalią `test-database` duomenų bazę.

Pateikiami du kablys, vienas veikia, kai procesas yra šakojamas, o kitas veikia prieš uždarant šakotą procesą. Tai gali būti naudinga, jei jūsų programa naudoja kelias duomenų bazes arba atlieka kitus uždavinius, priklausančius nuo darbuotojų skaičiaus.

`parallelize_setup` metodas yra iškviečiamas tuoj pat po proceso šakojimo. `parallelize_teardown` metodas yra iškviečiamas tuoj pat prieš procesų uždarymą.

```ruby
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # duomenų bazių nustatymas
  end

  parallelize_teardown do |worker|
    # duomenų bazių valymas
  end

  parallelize(workers: :number_of_processors)
end
```

Šie metodai nėra reikalingi ir neprieinami naudojant parallelizuotą testavimą su gijomis.

### Parallelizuotas testavimas su gijomis

Jei norite naudoti gijas arba naudojate JRuby, pateikiama paralelizavimo su gijomis parinktis. Gijų paralelizatorius remiasi Minitest `Parallel::Executor`.

Norėdami pakeisti paralelizavimo metodą naudoti gijas vietoj šakojimo, įkelkite šį kodą į savo `test_helper.rb`

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)
end
```

Iš JRuby ar TruffleRuby sugeneruotos "Rails" programos automatiškai įtraukia `with: :threads` parinktį.

Darbuotojų skaičius, perduotas `parallelize` metodui, nustato testų gijų skaičių. Galbūt norėsite skirtingai parallelizuoti vietinį testų rinkinį ir CI, todėl pateikiama aplinkos kintamoji, leidžianti lengvai keisti darbuotojų skaičių testų vykdymui:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

### Testavimas su parallelizuotais sandoriais

"Rails" automatiškai apgaubia bet kurį testo atvejį duomenų bazės sandoriu, kuris yra atšaukiamas po testo pabaigos. Tai padaro testo atvejus nepriklausomus vienas nuo kito, o duomenų bazės pakeitimai matomi tik viename teste.

Kai norite testuoti kodą, kuris vykdo parallelizuotus sandorius gijose, sandoriai gali blokuoti vienas kitą, nes jie jau yra įdėti į testo sandorį.

Galite išjungti sandorius testo atvejo klasėje, nustatydami `self.use_transactional_tests = false`:

```ruby
class WorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "parallelizuoti sandoriai" do
    # paleiskite kelias gijas, kurios kuria sandorius
  end
end
```

PASTABA: Išjungus sandorių testus, turite išvalyti bet kokius duomenis, kuriuos testai sukuria, nes pakeitimai po testo pabaigos nebus automatiškai atšaukti.

### Sluoksnis, skirtas testų parallelizavimo slenkstui

Testų vykdymas paralleliai sukelia papildomą apkrovą, susijusią su duomenų bazės nustatymu ir fiktyvių duomenų įkėlimu. Dėl šios priežasties "Rails" nevykdo parallelizuotų vykdymų, kuriuose dalyvauja mažiau nei 50 testų.

Galite konfigūruoti šį slenkstį savo `test.rb`:

```ruby
config.active_support.test_parallelization_threshold = 100
```

Taip pat nustatant parallelizavimą testo atvejo lygyje:

```ruby
class ActiveSupport::TestCase
  parallelize threshold: 100
end
```

Testinė duomenų bazė
-----------------

Beveik kiekviena "Rails" programa labai sąveikauja su duomenų baze, todėl jūsų testai taip pat turės sąveikauti su duomenų baze. Norėdami rašyti efektyvius testus, turėsite suprasti, kaip nustatyti šią duomenų bazę ir ją užpildyti pavyzdiniais duomenimis.

Pagal numatytuosius nustatymus kiekviena "Rails" programa turi tris aplinkas: vystymąsi, testavimą ir produkciją. Kiekvienai iš jų duomenų bazė yra konfigūruojama `config/database.yml`.

Atskira testinė duomenų bazė leidžia jums izoliuotai nustatyti ir sąveikauti su testiniais duomenimis. Taip jūsų testai gali drąsiai manipuliuoti testiniais duomenimis, nesijaudindami dėl duomenų vystymo ar produkcijos duomenų bazėse.

### Testinės duomenų bazės schemos palaikymas

Norėdami paleisti savo testus, jūsų testinė duomenų bazė turės turėti dabartinę struktūrą. Testo pagalbininkas patikrina, ar jūsų testinė duomenų bazė turi nepatvirtintų migracijų. Jis bandys įkelti jūsų `db/schema.rb` arba `db/structure.sql` į testinę duomenų bazę. Jei migracijos dar nepatvirtintos, bus iškelta klaida. Paprastai tai reiškia, kad jūsų schema nėra visiškai migruota. Paleidus migracijas prieš vystymo duomenų bazę (`bin/rails db:migrate`), schema bus atnaujinta.
PASTABA: Jei buvo atlikti pakeitimai esamoms migracijoms, testinė duomenų bazė turi būti atstatyta. Tai galima padaryti vykdant `bin/rails db:test:prepare`.

### Apie fiktyvius duomenis

Norint gauti gerus testus, reikia apgalvoti testinių duomenų nustatymą. „Rails“ galima tai padaryti apibrėžiant ir pritaikant fiktyvius duomenis. Išsamią dokumentaciją rasite [Fiktyvių duomenų API dokumentacijoje](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### Kas yra fiktyvūs duomenys?

Fiktyvūs duomenys yra sudėtingas žodis, reiškiantis pavyzdinius duomenis. Fiktyvūs duomenys leidžia užpildyti jūsų testinę duomenų bazę su iš anksto nustatytais duomenimis prieš paleidžiant testus. Fiktyvūs duomenys yra nepriklausomi nuo duomenų bazės ir parašyti YAML formatu. Kiekvienam modeliui yra vienas failas.

PASTABA: Fiktyvūs duomenys nėra skirti kurti visus objektus, kurių jums reikia testuose, ir geriausiai tvarkomi, kai naudojami tik numatytieji duomenys, kurie gali būti pritaikyti bendrai atvejai.

Fiktyvius duomenis rasite savo `test/fixtures` kataloge. Paleidus `bin/rails generate model`, kuriant naują modelį, „Rails“ automatiškai sukuria fiktyvius duomenis šiame kataloge.

#### YAML

YAML formatuoti fiktyvūs duomenys yra draugiškas žmogui būdas aprašyti pavyzdinius duomenis. Tokio tipo fiktyvūs duomenys turi **.yml** failo plėtinį (pvz., `users.yml`).

Štai pavyzdinis YAML fiktyvų duomenų failas:

```yaml
# štai ir aš, YAML komentaras!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Sistemos kūrimas

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: žmogus su klaviatūra
```

Kiekvienam fiktyviam duomeniui suteikiamas pavadinimas, po to seka įtrauktų raktų ir reikšmių sąrašas, atskirtas dvitaškiais. Įrašai paprastai yra atskirti tuščia eilute. Komentarus galite įterpti į fiktyvų duomenų failą naudodami # simbolį pirmame stulpelyje.

Jei dirbate su [asociacijomis](/association_basics.html), galite apibrėžti nuorodos mazgą tarp dviejų skirtingų fiktyvių duomenų. Štai pavyzdys su `belongs_to`/`has_many` asociacija:

```yaml
# test/fixtures/categories.yml
about:
  name: Apie
```

```yaml
# test/fixtures/articles.yml
first:
  title: Sveiki atvykę į „Rails“!
  category: about
```

```yaml
# test/fixtures/action_text/rich_texts.yml
first_content:
  record: first (Article)
  name: turinys
  body: <div>Sveiki, iš <strong>fiktyvaus duomenų failo</strong></div>
```

Pastebėkite, kad `first` straipsnio `category` raktas, randamas `fixtures/articles.yml`, turi reikšmę `about`, o `first_content` įrašo `record` raktas, randamas `fixtures/action_text/rich_texts.yml`, turi reikšmę `first (Article)`. Tai užuotinuoja „Active Record“ įkelti kategoriją `about`, randamą `fixtures/categories.yml`, pirmajam atvejui, ir „Action Text“ įkelti straipsnį `first`, randamą `fixtures/articles.yml`, antrajam atvejui.

PASTABA: Norint, kad asociacijos viena kitą nuorodytų pagal pavadinimą, galite naudoti fiktyvų pavadinimą, vietoj to, kad nurodytumėte `id:` atributą asocijuotuose fiktyviuose duomenyse. „Rails“ automatiškai priskirs pagrindinį raktą, kad būtų išlaikytas nuoseklumas tarp paleidimų. Daugiau informacijos apie šią asociacijos elgseną galite rasti [Fiktyvių duomenų API dokumentacijoje](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### Failo prikabos fiktyvūs duomenys

Kaip ir kiti „Active Record“ palaikomi modeliai, „Active Storage“ prikabos įrašai paveldi iš „ActiveRecord::Base“ pavyzdžių ir todėl gali būti užpildyti fiktyviais duomenimis.

Pavyzdžiui, turime „Article“ modelį, kuris turi susijusį paveikslėlį kaip „thumbnail“ prikabą, kartu su fiktyviais duomenimis YAML formatu:

```ruby
class Article
  has_one_attached :thumbnail
end
```

```yaml
# test/fixtures/articles.yml
first:
  title: Straipsnis
```

Tarkime, kad yra [image/png][] koduotas failas `test/fixtures/files/first.png`. Šie YAML fiktyvūs įrašai sukurs susijusius `ActiveStorage::Blob` ir `ActiveStorage::Attachment` įrašus:

```yaml
# test/fixtures/active_storage/blobs.yml
first_thumbnail_blob: <%= ActiveStorage::FixtureSet.blob filename: "first.png" %>
```

```yaml
# test/fixtures/active_storage/attachments.yml
first_thumbnail_attachment:
  name: thumbnail
  record: first (Article)
  blob: first_thumbnail_blob
```


#### ERB

ERB leidžia įterpti „Ruby“ kodą į šablonus. YAML fiktyvų duomenų formatas yra apdorojamas su ERB, kai „Rails“ įkelia fiktyvius duomenis. Tai leidžia naudoti „Ruby“ pagalbą generuojant pavyzdinius duomenis. Pavyzdžiui, šis kodas sugeneruoja tūkstantį vartotojų:

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```
#### Veikiantys fiksuojamieji duomenys

Pagal numatytuosius nustatymus "Rails" automatiškai įkelia visus fiksuojamuosius duomenis iš `test/fixtures` katalogo. Įkėlimas apima tris žingsnius:

1. Pašalinti bet kokius esamus duomenis iš lentelės, atitinkančios fiksuojamąjį duomenį
2. Įkelti fiksuojamąjį duomenį į lentelę
3. Iškrauti fiksuojamąjį duomenį į metodą, jei norite prie jo tiesiogiai prieiti

PATARIMAS: Norėdami pašalinti esamus duomenis iš duomenų bazės, "Rails" bando išjungti nuorodinės vientisumo trigerius (tokius kaip užsienio raktai ir patikros apribojimai). Jei paleidžiant testus gaunate erzinančius leidimo klaidas, įsitikinkite, kad duomenų bazės naudotojas turi teisę išjungti šiuos trigerius testavimo aplinkoje. (PostgreSQL duomenų bazėje visi trigerius gali išjungti tik super naudotojai. Daugiau informacijos apie PostgreSQL leidimus galite rasti [čia](https://www.postgresql.org/docs/current/sql-altertable.html)).

#### Fiksuojamieji duomenys yra aktyvūs įrašų objektai

Fiksuojamieji duomenys yra "Active Record" objektų pavyzdžiai. Kaip minėta 3 punkte aukščiau, galite tiesiogiai pasiekti objektą, nes jis automatiškai yra prieinamas kaip metodas, kurio taikymo sritis yra vietinė testo atvejo. Pavyzdžiui:

```ruby
# tai grąžins "User" objektą, kuris atitinka fiksuojamąjį duomenį su pavadinimu "david"
users(:david)

# tai grąžins "david" savybę, vadinamą "id"
users(:david).id

# taip pat galima pasiekti metodus, kurie yra prieinami "User" klasėje
david = users(:david)
david.call(david.partner)
```

Norėdami gauti kelis fiksuojamuosius duomenis vienu metu, galite perduoti sąrašą su fiksuojamųjų duomenų pavadinimais. Pavyzdžiui:

```ruby
# tai grąžins masyvą, kuriame bus fiksuojamieji duomenys "david" ir "steve"
users(:david, :steve)
```


Modelio testavimas
-------------

Modelio testai naudojami testuoti jūsų aplikacijos įvairius modelius.

"Rails" modelio testai saugomi `test/models` kataloge. "Rails" teikia generatorių, kuris sukurs modelio testo struktūrą jums.

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

Modelio testai neturi savo superklasės, kaip `ActionMailer::TestCase`. Vietoj to, jie paveldi [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html).

Sistemos testavimas
--------------

Sistemos testai leidžia jums testuoti vartotojų sąveiką su jūsų aplikacija, vykdyti testus
realiame arba begaliniame naršyklėje. Sistemos testai naudoja "Capybara" pagrindu.

Norėdami sukurti "Rails" sistemos testus, naudokite `test/system` katalogą savo
aplikacijoje. "Rails" teikia generatorių, kuris sukurs sistemos testo struktūrą jums.

```bash
$ bin/rails generate system_test users
      invoke test_unit
      create test/system/users_test.rb
```

Štai kaip atrodo naujai sukurtas sistemos testas:

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
end
```

Pagal numatytuosius nustatymus sistemos testai vykdomi naudojant "Selenium" draiverį, naudojant "Chrome"
naršyklę ir ekrano dydžiu 1400x1400. Kitame skyriuje paaiškinama, kaip
pakeisti numatytuosius nustatymus.

### Numatytųjų nustatymų keitimas

"Rails" labai paprastai keičia numatytuosius sistemos testų nustatymus. Visi
sąranka yra paslėpta, todėl galite sutelkti dėmesį į savo testų rašymą.

Kai generuojate naują aplikaciją arba šabloną, `application_system_test_case.rb` failas
sukuriamas testų kataloge. Čia turėtų būti visi sistemos testų konfigūracijos nustatymai.

Jei norite pakeisti numatytuosius nustatymus, galite pakeisti tai, kuo sistemos
testai yra "valdomi". Tarkime, norite pakeisti "Selenium" draiverį į
"Cuprite". Pirmiausia pridėkite `cuprite` giją į savo `Gemfile`. Tada savo
`application_system_test_case.rb` faile atlikite šiuos veiksmus:

```ruby
require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
```

Vairuotojo pavadinimas yra privalomas argumentas `driven_by`. Galimi pasirinktiniai argumentai,
kurie gali būti perduoti `driven_by`, yra `:using` naršyklės (tai bus naudojama tik
"Selenium"), `:screen_size` norint pakeisti ekrano dydį
ekranų nuotraukoms ir `:options`, kurie gali būti naudojami nustatyti vairuotojo palaikomus parametrus.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```
Jei norite naudoti be galvos naršyklę, galite naudoti "Headless Chrome" arba "Headless Firefox", pridedant `headless_chrome` arba `headless_firefox` į `:using` argumentą.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

Jei norite naudoti nuotolinę naršyklę, pvz.,
[Headless Chrome Docker](https://github.com/SeleniumHQ/docker-selenium),
turite pridėti nuotolinį `url` per `options`.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  options = ENV["SELENIUM_REMOTE_URL"].present? ? { url: ENV["SELENIUM_REMOTE_URL"] } : {}
  driven_by :selenium, using: :headless_chrome, options: options
end
```

Tokiu atveju, daugiau nereikalingas `webdrivers` gembė. Jį galite visiškai pašalinti arba pridėti `require:` opciją `Gemfile`.

```ruby
# ...
group :test do
  gem "webdrivers", require: !ENV["SELENIUM_REMOTE_URL"] || ENV["SELENIUM_REMOTE_URL"].empty?
end
```

Dabar turėtumėte gauti ryšį su nuotoline naršykle.

```bash
$ SELENIUM_REMOTE_URL=http://localhost:4444/wd/hub bin/rails test:system
```

Jei jūsų testuojama aplikacija taip pat veikia nuotoliniame režime, pvz., Docker konteineryje,
Capybara reikia daugiau informacijos apie tai, kaip
[skambinti nuotoliniams serveriams](https://github.com/teamcapybara/capybara#calling-remote-servers).

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  def setup
    Capybara.server_host = "0.0.0.0" # susieti su visais sąsajomis
    Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}" if ENV["SELENIUM_REMOTE_URL"].present?
    super
  end
  # ...
end
```

Dabar turėtumėte gauti ryšį su nuotoline naršykle ir serveriu, nepriklausomai nuo to,
ar jis veikia Docker konteineryje ar CI.

Jei jūsų Capybara konfigūracija reikalauja daugiau nustatymų nei pateikia Rails, šią
papildomą konfigūraciją galima pridėti į `application_system_test_case.rb`
failą.

Papildomus nustatymus rasite [Capybara dokumentacijoje](https://github.com/teamcapybara/capybara#setup).

### Screenshot Helper

`ScreenshotHelper` yra pagalbinė priemonė, skirta užfiksuoti jūsų testų ekrano kopijas.
Tai gali būti naudinga, norint peržiūrėti naršyklę, kai testas nepavyksta, arba
vėliau peržiūrėti ekrano kopijas, norint atlikti klaidų šalinimą.

Pateikiami du metodai: `take_screenshot` ir `take_failed_screenshot`.
`take_failed_screenshot` automatiškai įtraukiamas į `before_teardown` viduje
Rails.

`take_screenshot` pagalbinis metodas gali būti įtrauktas bet kur jūsų testuose,
norint užfiksuoti naršyklės ekrano kopiją.

### Sistemos testo įgyvendinimas

Dabar pridėsime sistemos testą į mūsų tinklaraščio aplikaciją. Demonstruosime
sistemos testo rašymą, apsilankydami indekso puslapyje ir sukurdami naują tinklaraščio straipsnį.

Jei naudojote šablonų generatorių, jums automatiškai buvo sukurtas sistemos testo šablonas. Jei nenaudojote šablono generatoriaus, pradėkite nuo sistemos testo šablono sukūrimo.

```bash
$ bin/rails generate system_test articles
```

Jis turėjo sukurti testo failo šabloną. Su ankstesnio komandos rezultatu turėtumėte matyti:

```
      invoke  test_unit
      create    test/system/articles_test.rb
```

Dabar atidarykime tą failą ir parašykime pirmąjį patikrinimą:

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "viewing the index" do
    visit articles_path
    assert_selector "h1", text: "Articles"
  end
end
```

Testas turėtų matyti, kad straipslių indekso puslapyje yra `h1` ir sėkmingai pereiti.

Paleiskite sistemos testus.

```bash
$ bin/rails test:system
```

PASTABA: Pagal numatytuosius nustatymus, paleidus `bin/rails test` nebus paleisti jūsų sistemos testai.
Įsitikinkite, kad paleidote `bin/rails test:system`, kad juos iš tikrųjų paleistumėte.
Taip pat galite paleisti `bin/rails test:all`, kad paleistumėte visus testus, įskaitant sistemos testus.

#### Straipslių sistemos testo kūrimas

Dabar išbandykime srauto kūrimo naujam straipsniui mūsų tinklaraštyje.

```ruby
test "should create Article" do
  visit articles_path

  click_on "New Article"

  fill_in "Title", with: "Creating an Article"
  fill_in "Body", with: "Created this article successfully!"

  click_on "Create Article"

  assert_text "Creating an Article"
end
```

Pirmas žingsnis yra iškviesti `visit articles_path`. Tai nukreips testą į
straipslių indekso puslapį.

Tada `click_on "New Article"` ras "New Article" mygtuką indekso puslapyje. Tai nukreips naršyklę į `/articles/new`.

Tada testas užpildys straipsnio pavadinimo ir turinio laukus nurodytu
tekstu. Užpildžius laukus, paspaudžiamas "Create Article", kuris sukurs naują straipsnį duomenų bazėje.
Mes busime nukreipti atgal į straipsnių indekso puslapį ir ten patikrinsime, ar naujo straipsnio pavadinimo tekstas yra straipsnių indekso puslapyje.

#### Testavimas su keliais ekrano dydžiais

Jei norite testuoti mobilius dydžius kartu su staliniais dydžiais, galite sukurti kitą klasę, kuri paveldi iš `ActionDispatch::SystemTestCase` ir ją naudoti savo testų rinkinyje. Šiame pavyzdyje sukuriamas failas, vadinamas `mobile_system_test_case.rb`, kuris yra sukurtas `/test` kataloge su šia konfigūracija.

```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

Norėdami naudoti šią konfigūraciją, sukurkite testą `test/system`, kuris paveldi iš `MobileSystemTestCase`. Dabar galite testuoti savo programą naudodami kelias skirtingas konfigūracijas.

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase
  test "lankantis indekse" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### Toliau eikime

Sistemos testavimo grožis yra tas, kad jis panašus į integracinį testavimą,
kuris testuoja vartotojo sąveiką su jūsų valdikliu, modeliu ir rodiniu, bet
sistemos testavimas yra daug patikimesnis ir iš tikrųjų testuoja jūsų programą taip,
tarsi ją naudotų tikras vartotojas. Toliau galite testuoti bet ką, ką pats vartotojas
darytų jūsų programoje, pvz., komentuoti, trinti straipsnius,
publikuoti juodraščius ir t.t.

Integracinis testavimas
-------------------

Integraciniai testai naudojami testuoti, kaip įvairios jūsų programos dalys sąveikauja. Jie dažniausiai naudojami testuoti svarbius darbo procesus jūsų programoje.

Kuriant integracinius testus „Rails“, naudojame `test/integration` katalogą savo programai. „Rails“ teikia generatorių, kuris sukurs mums integracinio testo pagrindo struktūrą.

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

Štai kaip atrodo naujai sugeneruotas integracinio testo pagrindas:

```ruby
require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

Čia testas paveldi iš `ActionDispatch::IntegrationTest`. Tai suteikia mums papildomų pagalbinių funkcijų, kurias galime naudoti savo integraciniuose testuose.

### Pagalbinės funkcijos, prieinamos integraciniams testams

Be įprastų testavimo pagalbinių funkcijų, paveldėjus iš `ActionDispatch::IntegrationTest` turime papildomų pagalbinių funkcijų, kurias galime naudoti rašydami integracinius testus. Trumpai susipažinkime su trimis pagalbinių funkcijų kategorijomis, iš kurių galime pasirinkti.

Norint dirbti su integracinio testo vykdytoju, žr. [`ActionDispatch::Integration::Runner`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html).

Atliekant užklausas, turėsime [`ActionDispatch::Integration::RequestHelpers`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html), kurias galime naudoti.

Jei reikia modifikuoti sesiją ar integracinio testo būseną, pažiūrėkite į [`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html).

### Integracinio testo įgyvendinimas

Pridėkime integracinį testą į mūsų tinklaraščio programą. Pradėsime nuo pagrindinio darbo proceso, kuris apima naujo tinklaraščio straipsnio sukūrimą, kad patikrintume, ar viskas veikia tinkamai.

Pradėkime nuo integracinio testo pagrindo sugeneravimo:

```bash
$ bin/rails generate integration_test blog_flow
```

Turėtų būti sukurtas testo failo šablonas. Su ankstesniojo komandos rezultatu turėtume matyti:

```
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

Dabar atidarykime tą failą ir parašykime pirmąjį tvirtinimą:

```ruby
require "test_helper"

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

Pažiūrėsime į `assert_select`, kad užklaustume užklausos rezultato HTML „Testing Views“ skyriuje apačioje. Jis naudojamas testuoti mūsų užklausos atsaką, tvirtinant pagrindinių HTML elementų buvimą ir jų turinį.

Aplankydami šakninį kelias, turėtume matyti, kad `welcome/index.html.erb` yra atvaizduojamas rodinyje. Taigi šis tvirtinimas turėtų būti sėkmingas.

#### Straipsnių kūrimo integracija

Kaip dėl mūsų galimybės sukurti naują straipsnį savo tinklaraštyje ir pamatyti rezultatų straipsnį.

```ruby
test "can create an article" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "can create", body: "article successfully." } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "Title:\n  can create"
end
```
Suskaidykime šį testą, kad galėtume jį suprasti.

Pradėkime nuo `:new` veiksmo iškvietimo mūsų Straipsniai valdiklyje. Šis atsakas turėtų būti sėkmingas.

Po to siunčiame POST užklausą į mūsų Straipsniai valdiklio `:create` veiksmą:

```ruby
post "/articles",
  params: { article: { title: "can create", body: "article successfully." } }
assert_response :redirect
follow_redirect!
```

Dvi eilutės po užklausos skirtos tvarkyti peradresavimui, kurį nustatėme kuriant naują straipsnį.

PASTABA: Nepamirškite iškviesti `follow_redirect!`, jei planuojate atlikti kitas užklausas po peradresavimo.

Galiausiai galime patvirtinti, kad mūsų atsakas buvo sėkmingas ir naujas straipsnis yra matomas puslapyje.

#### Eiti toliau

Mums pavyko sėkmingai ištestuoti labai mažą darbo eigą, apsilankant mūsų tinklaraštyje ir kuriant naują straipsnį. Jei norėtume eiti toliau, galėtume pridėti testus komentarams, straipsnių šalinimui arba komentarų redagavimui. Integraciniai testai yra puiki vieta eksperimentuoti su visokiomis naudojimo atvejais mūsų programoms.

Funkciniai testai jūsų valdikliams
-------------------------------------

Rails aplinkoje valdiklių veiksmų testavimas yra funkcinių testų rašymo forma. Atsiminkite, kad jūsų valdikliai tvarko įeinančias interneto užklausas į jūsų programą ir galiausiai atsako su sugeneruota peržiūros forma. Rašydami funkcinius testus, jūs testuojate, kaip jūsų veiksmai tvarko užklausas ir tikėtiną rezultatą ar atsaką, kai kuriais atvejais tai yra HTML peržiūros forma.

### Ką įtraukti į savo funkcinius testus

Turėtumėte testuoti tokius dalykus kaip:

* ar interneto užklausa buvo sėkminga?
* ar vartotojas buvo peradresuotas į tinkamą puslapį?
* ar vartotojas sėkmingai autentifikuotas?
* ar tinkamoje peržiūros formoje vartotojui buvo rodomas tinkamas pranešimas?
* ar atsakyme buvo rodoma teisinga informacija?

Paprastiausias būdas pamatyti funkcinius testus veikime yra generuoti valdiklį naudojant scaffold generatorių:

```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

Tai sugeneruos valdiklio kodą ir testus `Article` resursui. Galite pažvelgti į failą `articles_controller_test.rb` `test/controllers` kataloge.

Jei jau turite valdiklį ir norite tik sugeneruoti testų struktūros kodą
kiekvienam iš septynių numatytų veiksmų, galite naudoti šią komandą:

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

Pažvelkime į vieną tokių testų, `test_should_get_index` iš failo `articles_controller_test.rb`.

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

`test_should_get_index` teste, Rails simuliuoja užklausą veiksmui, vadinamam `index`, įsitikindamas, kad užklausa buvo sėkminga
ir taip pat užtikrina, kad buvo sugeneruota tinkama atsakymo forma.

`get` metodas paleidžia interneto užklausą ir rezultatus užpildo į `@response`. Jis gali priimti iki 6 argumentų:

* Valdiklio veiksmo URI, kurį užklausiate.
  Tai gali būti eilutės arba maršruto pagalbininko (pvz., `articles_url`) forma.
* `params`: parinktis su užklausos parametrų maišu, kurį perduoti veiksmui
  (pvz., užklausos eilutės parametrai arba straipsnio kintamieji).
* `headers`: nustatant antraštės, kurios bus perduotos su užklausa.
* `env`: tinkinamai pritaikant užklausos aplinką.
* `xhr`: ar užklausa yra Ajax užklausa ar ne. Galima nustatyti `true`, jei norite pažymėti užklausą kaip Ajax.
* `as`: užklausos kodavimui su skirtingu turinio tipu.

Visi šie raktiniai argumentai yra neprivalomi.

Pavyzdys: Iškviečiant pirmojo `Article` `:show` veiksmą ir perduodant `HTTP_REFERER` antraštę:

```ruby
get article_url(Article.first), headers: { "HTTP_REFERER" => "http://example.com/home" }
```
Kitas pavyzdys: Iškviesti `:update` veiksmą paskutiniam `Article`, perduodant naują tekstą `title` `params`, kaip Ajax užklausa:

```ruby
patch article_url(Article.last), params: { article: { title: "atnaujinta" } }, xhr: true
```

Dar vienas pavyzdys: Iškviesti `:create` veiksmą, kad sukurtum naują straipsnį, perduodant tekstą `title` `params`, kaip JSON užklausa:

```ruby
post articles_path, params: { article: { title: "Ahoy!" } }, as: :json
```

PASTABA: Jei bandysite paleisti `test_should_create_article` testą iš `articles_controller_test.rb`, jis nepavyks dėl naujai pridėtos modelio lygio patikros ir tai yra teisinga.

Pakeiskime `test_should_create_article` testą `articles_controller_test.rb`, kad visi mūsų testai pavyktų:

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { body: "Rails yra nuostabus!", title: "Sveiki Rails" } }
  end

  assert_redirected_to article_path(Article.last)
end
```

Dabar galite bandyti paleisti visus testus ir jie turėtų pavykti.

PASTABA: Jei sekėte žingsnius [Pagrindinė autentifikacija](getting_started.html#basic-authentication) skyriuje, jums reikės pridėti autorizaciją prie kiekvieno užklausos antraštės, kad visi testai pavyktų:

```ruby
post articles_url, params: { article: { body: "Rails yra nuostabus!", title: "Sveiki Rails" } }, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
```

### Galimi užklausų tipai funkciniuose testuose

Jei esate susipažinęs su HTTP protokolu, žinosite, kad `get` yra vienas iš užklausų tipų. Rails funkciniuose testuose yra palaikomi 6 užklausų tipai:

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

Visi užklausų tipai turi atitinkamus metodus, kuriuos galite naudoti. Tipiškoje C.R.U.D. aplikacijoje dažniau naudosite `get`, `post`, `put` ir `delete`.

PASTABA: Funkciniai testai neįsitikina, ar nurodytas užklausos tipas yra priimtas veiksmui, mums labiau rūpi rezultatas. Užklausų testai egzistuoja šiam tikslui, kad jūsų testai būtų tikslingesni.

### Testuojant XHR (Ajax) užklausas

Norėdami testuoti Ajax užklausas, galite nurodyti `xhr: true` parinktį `get`, `post`, `patch`, `put` ir `delete` metodams. Pavyzdžiui:

```ruby
test "ajax užklausa" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal "labas pasauli", @response.body
  assert_equal "text/javascript", @response.media_type
end
```

### Trys Apokalipsės Hash'ai

Po to, kai užklausa yra padaryta ir apdorota, turėsite 3 Hash objektus, paruoštus naudoti:

* `cookies` - Visi nustatyti slapukai
* `flash` - Visi objektai, gyvenantys flash
* `session` - Visi objektai, gyvenantys sesijos kintamuosiuose

Kaip ir su įprastais Hash objektais, galite pasiekti reikšmes, nurodydami raktus eilutėmis. Taip pat galite pasiekti jas pagal simbolio pavadinimą. Pavyzdžiui:

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### Prieinami objektai

**Po** užklausos padarymo, funkciniuose testuose taip pat turite prieigą prie trijų objektų:

* `@controller` - Užklausą apdorojantis valdiklis
* `@request` - Užklausos objektas
* `@response` - Atsakymo objektas


```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Straipsniai", @response.body
  end
end
```

### Antraštės ir CGI kintamieji

[HTTP antraštės](https://tools.ietf.org/search/rfc2616#section-5.3)
ir
[CGI kintamieji](https://tools.ietf.org/search/rfc3875#section-4.1)
gali būti perduodami kaip antraštės:

```ruby
# nustatoma HTTP antraštė
get articles_url, headers: { "Content-Type": "text/plain" } # simuliuoti užklausą su pasirinkta antraštė

# nustatoma CGI kintamasis
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # simuliuoti užklausą su pasirinktu aplinkos kintamuoju
```

### Testuojant `flash` pranešimus

Jei prisimenate iš ankstesnių skyrių, vienas iš Trijų Apokalipsės Hash'ų buvo `flash`.

Norime pridėti `flash` pranešimą į mūsų tinklaraščio aplikaciją, kai kas nors sėkmingai sukuria naują straipsnį.

Pradėkime pridėdami šią patikrą į mūsų `test_should_create_article` testą:
```ruby
test "turėtų sukurti straipsnį" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { title: "Koks nors pavadinimas" } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal "Straipsnis buvo sėkmingai sukurtas.", flash[:notice]
end
```

Jei dabar paleisime testą, turėtume pamatyti klaidą:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 32266

# Running:

F

Finished in 0.114870s, 8.7055 runs/s, 34.8220 assertions/s.

  1) Failure:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- expected
+++ actual
@@ -1 +1 @@
-"Article was successfully created."
+nil

1 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

Dabar įgyvendinkime "flash" pranešimą mūsų valdiklyje. Mūsų `:create` veiksmas turėtų atrodyti taip:

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = "Straipsnis buvo sėkmingai sukurtas."
    redirect_to @article
  else
    render "new"
  end
end
```

Dabar, jei paleisime testus, turėtume matyti, kad jie sėkmingai įvyksta:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 18981

# Running:

.

Finished in 0.081972s, 12.1993 runs/s, 48.7972 assertions/s.

1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### Viską sudedame kartu

Šiuo metu mūsų straipsnių valdiklis testuoja `:index`, `:new` ir `:create` veiksmus. Kaip dėl egzistuojančių duomenų tvarkymo?

Parašykime testą `:show` veiksmui:

```ruby
test "turėtų rodyti straipsnį" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

Atsiminkime iš ankstesnės diskusijos apie fiktyvius duomenis, kad `articles()` metodas suteiks mums prieigą prie mūsų straipsnių fiktyvių duomenų.

Kaip dėl egzistuojančio straipsnio ištrynimo?

```ruby
test "turėtų ištrinti straipsnį" do
  article = articles(:one)
  assert_difference("Article.count", -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

Taip pat galime pridėti testą egzistuojančio straipsnio atnaujinimui.

```ruby
test "turėtų atnaujinti straipsnį" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "atnaujinta" } }

  assert_redirected_to article_path(article)
  # Atnaujintų duomenų gavimui ir patikrinimui, kad pavadinimas būtų atnaujintas, reikia perkrauti asociaciją.
  article.reload
  assert_equal "atnaujinta", article.title
end
```

Pastebėkite, kad pradedame matyti pasikartojimą šiuose trijuose testuose, jie visi naudoja tą patį straipsnio fiktyvų duomenų rinkinį. Galime sumažinti šį pasikartojimą naudodami `setup` ir `teardown` metodus, kurie yra pateikiami `ActiveSupport::Callbacks`.

Mūsų testas dabar turėtų atrodyti kaip šis. Kol kas praleiskime kitus testus, kad būtų trumpesnis kodas.

```ruby
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # iškviečiamas prieš kiekvieną testą
  setup do
    @article = articles(:one)
  end

  # iškviečiamas po kiekvieno testo
  teardown do
    # jei valdiklis naudoja talpyklą, gali būti gerai ją išvalyti po to
    Rails.cache.clear
  end

  test "turėtų rodyti straipsnį" do
    # Perpanaudojame @article kintamąjį iš setup
    get article_url(@article)
    assert_response :success
  end

  test "turėtų ištrinti straipsnį" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "turėtų atnaujinti straipsnį" do
    patch article_url(@article), params: { article: { title: "atnaujinta" } }

    assert_redirected_to article_path(@article)
    # Atnaujintų duomenų gavimui ir patikrinimui, kad pavadinimas būtų atnaujintas, reikia perkrauti asociaciją.
    @article.reload
    assert_equal "atnaujinta", @article.title
  end
end
```

Panašiai kaip ir kituose "Rails" kintamųjų, `setup` ir `teardown` metodus galima naudoti perduodant bloką, lambda arba metodo pavadinimą kaip simbolį.

### Testavimo pagalbininkai

Norint išvengti kodo pasikartojimo, galite pridėti savo testavimo pagalbinius metodus.
Pavyzdžiui, prisijungimo pagalbininkas gali būti geras pavyzdys:

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "turėtų rodyti profilį" do
    # pagalbinis metodas dabar gali būti naudojamas iš bet kurio valdiklio testo
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

#### Naudojant atskirus failus

Jei pastebite, kad jūsų pagalbiniai metodai užkrauna `test_helper.rb` failą, galite juos išskaidyti į atskirus failus.
Vienas geras vietos juos saugoti yra `test/lib` arba `test/test_helpers`.
```ruby
# test/test_helpers/multiple_assertions.rb
module MultipleAssertions
  def assert_multiple_of_forty_two(number)
    assert (number % 42 == 0), "tikėtasi, kad #{number} bus daugiklis iš 42"
  end
end
```

Šie pagalbininkai gali būti išreiškiamai reikalaujami ir įtraukiami, kaip reikia

```ruby
require "test_helper"
require "test_helpers/multiple_assertions"

class NumberTest < ActiveSupport::TestCase
  include MultipleAssertions

  test "420 yra daugiklis iš keturiasdešimt du" do
    assert_multiple_of_forty_two 420
  end
end
```

arba jie gali toliau būti įtraukiami tiesiogiai į atitinkamas pagrindines klases

```ruby
# test/test_helper.rb
require "test_helpers/sign_in_helper"

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

#### Greitai reikalaujant pagalbinių priemonių

Galite rasti patogu greitai reikalauti pagalbinių priemonių `test_helper.rb`, kad jūsų testų failai turėtų neaiškų prieigą prie jų. Tai galima padaryti naudojant globbing, kaip parodyta žemiau

```ruby
# test/test_helper.rb
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }
```

Tai turi trūkumą, kad padidėja paleidimo laikas, palyginti su rankiniu būdu reikalaujant tik reikalingų failų jūsų atskiruose testuose.

Maršrutų testavimas
--------------

Kaip ir viskas kitas jūsų „Rails“ programoje, galite testuoti savo maršrutus. Maršruto testai yra `test/controllers/` aplanke arba yra dalis kontrolerio testų.

PASTABA: Jei jūsų programa turi sudėtingus maršrutus, „Rails“ teikia keletą naudingų pagalbinių priemonių jų testavimui.

Daugiau informacijos apie maršruto tikrinimo teiginius, kurie yra prieinami „Rails“, rasite API dokumentacijoje [`ActionDispatch::Assertions::RoutingAssertions`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html).

Peržiūrėti testavimą
-------------

Testuojant atsaką į jūsų užklausą, patikrinant pagrindinių HTML elementų buvimą ir jų turinį, yra paprastas būdas testuoti jūsų programos rodinius. Kaip ir maršruto testai, peržiūros testai yra `test/controllers/` aplanke arba yra dalis kontrolerio testų. `assert_select` metodas leidžia jums užklausti atsakos HTML elementus naudojant paprastą, tačiau galingą sintaksę.

Yra du `assert_select` formos:

`assert_select(selector, [equality], [message])` užtikrina, kad pasirinktų elementų per selektorių būtų patenkinta lygybės sąlyga. Selektorius gali būti CSS selektoriaus išraiška (tekstas) arba išraiška su pakeitimo reikšmėmis.

`assert_select(element, selector, [equality], [message])` užtikrina, kad pasirinktų elementų per selektorių būtų patenkinta lygybės sąlyga, pradedant nuo _elemento_ („Nokogiri::XML::Node“ arba „Nokogiri::XML::NodeSet“) ir jo palikuonių.

Pavyzdžiui, galite patikrinti atsakos antraštės elemento turinį su:

```ruby
assert_select "title", "Sveiki atvykę į „Rails“ testavimo vadovą"
```

Taip pat galite naudoti įdėtus `assert_select` blokus gilesniam tyrimui.

Šiame pavyzdyje vidinis `assert_select` blokas `li.menu_item` vykdomas
viduje išorinio bloko pasirinktų elementų kolekcijos:

```ruby
assert_select "ul.navigation" do
  assert_select "li.menu_item"
end
```

Pasirinktų elementų kolekcija gali būti peržiūrima, kad `assert_select` būtų galima atskirai iškviesti kiekvienam elementui.

Pavyzdžiui, jei atsakyme yra du surikiuoti sąrašai, kiekvienas su keturiais įdėtais sąrašo elementais, tada šie testai abu bus sėkmingi.

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

Šis teiginys yra gana galingas. Daugiau pažangių naudojimo būdų rasite jo [dokumentacijoje](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb).

### Papildomi rodinio pagrindu teiginiai

Yra daugiau teiginių, kurie daugiausia naudojami testuojant rodinius:

| Teiginys                                                 | Tikslas |
| --------------------------------------------------------- | ------- |
| `assert_select_email`                                     | Leidžia jums daryti teiginius el. laiško kūne. |
| `assert_select_encoded`                                   | Leidžia jums daryti teiginius užkoduotam HTML. Tai daroma atkoduojant kiekvieno elemento turinį ir tada kviečiant bloką su visais atkoduotais elementais.|
| `css_select(selector)` arba `css_select(element, selector)` | Grąžina masyvą, kuriame yra visi selektoriaus pasirinkti elementai. Antrame variante jis pirmiausia atitinka pagrindinį _elementą_ ir bando atitikti _selektoriaus_ išraišką bet kuriam jo vaikui. Jei nėra atitikimų, abu variantai grąžina tuščią masyvą.|
Štai pavyzdys, kaip naudoti `assert_select_email`:

```ruby
assert_select_email do
  assert_select "small", "Norėdami atsisakyti, prašome paspausti „Atsisakyti prenumeratos“ nuorodą."
end
```

Testavimo pagalbininkai
-----------------------

Pagalbininkas yra paprastas modulis, kuriame galite apibrėžti metodus, kurie yra prieinami jūsų rodiniuose.

Norėdami testuoti pagalbininkus, jums tereikia patikrinti, ar pagalbinio metodo išvestis atitinka tai, ką tikėtumėte. Pagalbininkų susiję testai yra išdėstyti `test/helpers` kataloge.

Turint šį pagalbininką:

```ruby
module UsersHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

Galime patikrinti šio metodo išvestį taip:

```ruby
class UsersHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

Be to, kadangi testo klasė išplečia `ActionView::TestCase`, jūs turite prieigą prie „Rails“ pagalbinių metodų, tokių kaip `link_to` arba `pluralize`.

Pašto siuntėjų testavimas
------------------------

Pašto siuntėjų klasės testavimui reikia tam tikrų specifinių įrankių, kad būtų atliktas kruopštus darbas.

### Laikyti paštininką kontroliuojamą

Jūsų pašto siuntėjų klasės - kaip ir kiekviena kitą jūsų „Rails“ programos dalis - turėtų būti patikrintos, kad jos veiktų kaip tikėtasi.

Jūsų pašto siuntėjų klasės testavimo tikslai yra užtikrinti, kad:

* elektroninės pašto žinutės būtų apdorojamos (sukuriamos ir siunčiamos)
* elektroninės pašto žinutės turinys būtų teisingas (tema, siuntėjas, turinys ir kt.)
* tinkamos elektroninės pašto žinutės būtų siunčiamos tinkamu laiku

#### Iš visų pusių

Yra du pašto siuntėjų testavimo aspektai: vienetų testai ir funkcinių testų. Vienetų testuose paleidžiate pašto siuntėją izoliacijoje su griežtai kontroliuojamais įvesties duomenimis ir palyginatį išvestį su žinoma reikšme (fiktyviu). Funkciniuose testuose jūs ne taip labai tikrinat pašto siuntėjo smulkmenas; vietoj to mes tikriname, ar mūsų valdikliai ir modeliai naudoja pašto siuntėją tinkamu būdu. Jūs testuojate, kad tinkama elektroninė pašto žinutė buvo išsiųsta tinkamu laiku.

### Vienetų testavimas

Norėdami patikrinti, ar jūsų pašto siuntėjas veikia kaip tikėtasi, galite naudoti vienetų testus, kad palygintumėte pašto siuntėjo faktinį rezultatą su iš anksto parašytais pavyzdžiais.

#### Atkeršyti fiktyvams

Vienetų testavimui pašto siuntėjui naudojamos fiktyvios reikšmės, kurios pateikia pavyzdį, kaip turėtų atrodyti išvestis. Kadangi tai yra pavyzdinės elektroninės pašto žinutės, o ne aktyviosios įrašo duomenys, kaip kiti fiktyviniai duomenys, jos laikomos atskirame aplankale, atskirame nuo kitų fiktyvinių duomenų. Aplanko pavadinimas `test/fixtures` tiesiogiai atitinka pašto siuntėjo pavadinimą. Taigi, jei pašto siuntėjo pavadinimas yra `UserMailer`, fiktyviniai duomenys turėtų būti laikomi `test/fixtures/user_mailer` aplanke.

Jei sukūrėte savo pašto siuntėją, generatorius nesukuria fiktyvinių duomenų šablonų pašto siuntėjo veiksmams. Turėsite patys sukurti tuos failus, kaip aprašyta aukščiau.

#### Pagrindinė testo byla

Štai vienetų testas, skirtas patikrinti pašto siuntėją pavadinimu `UserMailer`, kurio veiksmas `invite` naudojamas siųsti pakvietimą draugui. Tai yra pritaikyta versija generatoriaus sukurtos pagrindinės testo, skirtos `invite` veiksmui.

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Sukurkite el. pašto žinutę ir ją saugokite tolimesniam tikrinimui
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # Išsiųskite el. pašto žinutę, tada patikrinkite, ar ji buvo įtraukta į eilę
    assert_emails 1 do
      email.deliver_now
    end

    # Patikrinkite, ar išsiųstos el. pašto žinutės turinys atitinka tai, ką tikimės
    assert_equal ["me@example.com"], email.from
    assert_equal ["friend@example.com"], email.to
    assert_equal "Jūs buvote pakviestas iš me@example.com", email.subject
    assert_equal read_fixture("invite").join, email.body.to_s
  end
end
```

Teste mes sukuriam el. pašto žinutę ir saugome grąžintą objektą kintamajame `email`. Tada užtikriname, kad ji buvo išsiųsta (pirmasis tikrinimas), tada, antrame tikrinime, užtikriname, kad el. pašto žinutė tikrai turi tai, ką tikimės. Pagalbinis metodas `read_fixture` naudojamas nuskaityti šio failo turinį.
PASTABA: `email.body.to_s` yra naudojama, kai yra tik vienas (HTML arba tekstas) dalis. Jei pašto siuntėjas pateikia abu, galite savo fiktyvą išbandyti su konkrečiomis dalimis naudodami `email.text_part.body.to_s` arba `email.html_part.body.to_s`.

Čia yra `invite` fiktyvo turinys:

```
Sveikas drauge@example.com,

Jūs buvote pakviestas.

Linkiu geros dienos!
```

Tai yra tinkamas laikas šiek tiek daugiau sužinoti apie testų rašymą savo pašto siuntėjams. Eilutė `ActionMailer::Base.delivery_method = :test` faile `config/environments/test.rb` nustato pristatymo būdą į testo režimą, todėl el. laiškai iš tikrųjų nebus išsiųsti (naudinga, norint išvengti vartotojų siunčiant šlamšto laiškus testuojant), o vietoj to jie bus pridėti prie masyvo (`ActionMailer::Base.deliveries`).

PASTABA: `ActionMailer::Base.deliveries` masyvas automatiškai nėra išvalomas `ActionMailer::TestCase` ir `ActionDispatch::IntegrationTest` testuose. Jei norite turėti švarų sąrašą už šių testų atvejų ribų, galite jį išvalyti rankiniu būdu naudodami: `ActionMailer::Base.deliveries.clear`

#### Išbandyti užsakytus el. laiškus

Galite naudoti `assert_enqueued_email_with` tvirtinimą, kad patvirtintumėte, jog el. laiškas buvo užsakytas su visais tikėtais pašto siuntėjo metodo argumentais ir/arba parametrizuotais pašto siuntėjo parametrais. Tai leidžia atitiktiems el. laiškams, kurie buvo užsakomi naudojant `deliver_later` metodą.

Kaip ir su pagrindiniu testo atveju, mes sukuriam el. laišką ir saugome grąžintą objektą kintamajame `email`. Šie pavyzdžiai apima argumentų ir/arba parametrų perdavimo variantus.

Šis pavyzdys patvirtins, kad el. laiškas buvo užsakytas su teisingais argumentais:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Sukurkite el. laišką ir saugokite jį tolimesnėms tvirtinimams
    email = UserMailer.create_invite("me@example.com", "friend@example.com")

    # Patikrinkite, ar el. laiškas buvo užsakytas su teisingais argumentais
    assert_enqueued_email_with UserMailer, :create_invite, args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

Šis pavyzdys patvirtins, kad pašto siuntėjas buvo užsakytas su teisingais pašto siuntėjo metodo vardinių argumentų pavadinimais, perduodant argumentų raktus kaip `args`:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Sukurkite el. laišką ir saugokite jį tolimesnėms tvirtinimams
    email = UserMailer.create_invite(from: "me@example.com", to: "friend@example.com")

    # Patikrinkite, ar el. laiškas buvo užsakytas su teisingais vardinių argumentų pavadinimais
    assert_enqueued_email_with UserMailer, :create_invite, args: [{ from: "me@example.com",
                                                                    to: "friend@example.com" }] do
      email.deliver_later
    end
  end
end
```

Šis pavyzdys patvirtins, kad parametrizuotas pašto siuntėjas buvo užsakytas su teisingais parametrais ir argumentais. Pašto siuntėjo parametrai perduodami kaip `params`, o pašto siuntėjo metodo argumentai - kaip `args`:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Sukurkite el. laišką ir saugokite jį tolimesnėms tvirtinimams
    email = UserMailer.with(all: "good").create_invite("me@example.com", "friend@example.com")

    # Patikrinkite, ar el. laiškas buvo užsakytas su teisingais pašto siuntėjo parametrais ir argumentais
    assert_enqueued_email_with UserMailer, :create_invite, params: { all: "good" },
                                                           args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

Šis pavyzdys parodo alternatyvų būdą patikrinti, ar parametrizuotas pašto siuntėjas buvo užsakytas su teisingais parametrais:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Sukurkite el. laišką ir saugokite jį tolimesnėms tvirtinimams
    email = UserMailer.with(to: "friend@example.com").create_invite

    # Patikrinkite, ar el. laiškas buvo užsakytas su teisingais pašto siuntėjo parametrais
    assert_enqueued_email_with UserMailer.with(to: "friend@example.com"), :create_invite do
      email.deliver_later
    end
  end
end
```

### Funkcinis ir sisteminis testavimas

Vienetinis testavimas leidžia mums testuoti el. laiško atributus, o funkcinis ir sisteminis testavimas leidžia mums patikrinti, ar vartotojų sąveikos tinkamai sukelia el. laiško pristatymą. Pavyzdžiui, galite patikrinti, ar pakvietimo draugui operacija tinkamai siunčia el. laišką:

```ruby
# Integracinis testas
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    # Patvirtina skirtumą ActionMailer::Base.deliveries
    assert_emails 1 do
      post invite_friend_url, params: { email: "friend@example.com" }
    end
  end
end
```

```ruby
# Sisteminis testas
require "test_helper"

class UsersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "pakviesti draugą" do
    visit invite_users_url
    fill_in "El. paštas", with: "friend@example.com"
    assert_emails 1 do
      click_on "Pakviesti"
    end
  end
end
```
PASTABA: `assert_emails` metodas nėra susietas su konkretaus pristatymo metodo ir veiks su elektroniniais laiškais, pristatomais naudojant `deliver_now` arba `deliver_later` metodą. Jei norime aiškiai patikrinti, ar laiškas buvo įtrauktas į eilę, galime naudoti `assert_enqueued_email_with` ([pavyzdžiai aukščiau](#testing-enqueued-emails)) arba `assert_enqueued_emails` metodus. Daugiau informacijos galima rasti [dokumentacijoje čia](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html).

Darbo testavimas
------------

Kadangi jūsų adaptuoti darbai gali būti įtraukti į skirtingus jūsų programos lygius,
jums reikės testuoti tiek patį darbą (jo elgesį, kai jis įtraukiamas į eilę),
tiek ir kitus elementus, kurie jį teisingai įtraukia į eilę.

### Pagrindinė testo atvejo

Pagal nutylėjimą, generuojant darbą, taip pat bus sugeneruotas susijęs testas
pagal nutylėjimą esančiame `test/jobs` kataloge. Štai pavyzdinis testas su sąskaitos darbu:

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "that account is charged" do
    BillingJob.perform_now(account, product)
    assert account.reload.charged_for?(product)
  end
end
```

Šis testas yra gana paprastas ir tik patvirtina, kad darbas atliko tikėtą darbą.

### Individualios patikros ir darbo testavimas kituose komponentuose

Active Job yra pritaikytas su daugybe individualių patikrų, kurios gali būti naudojamos testų mažinimui. Pilną galimų patikrų sąrašą rasite API dokumentacijoje [`ActiveJob::TestHelper`](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html).

Gera praktika užtikrinti, kad jūsų darbai būtų teisingai įtraukiami arba atliekami
ten, kur juos iškviečiate (pvz., savo valdikliuose). Tai yra būtent ten,
kur Active Job teikiamos individualios patikros yra labai naudingos. Pavyzdžiui,
modelyje galite patvirtinti, kad darbas buvo įtrauktas:

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "billing job scheduling" do
    assert_enqueued_with(job: BillingJob) do
      product.charge(account)
    end
    assert_not account.reload.charged_for?(product)
  end
end
```

Numatytasis adapteris, `:test`, nevykdo darbų, kai jie yra įtraukiami į eilę.
Turite jam pasakyti, kada norite, kad darbai būtų atlikti:

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "billing job scheduling" do
    perform_enqueued_jobs(only: BillingJob) do
      product.charge(account)
    end
    assert account.reload.charged_for?(product)
  end
end
```

Visi anksčiau atlikti ir įtraukti darbai yra išvalomi prieš bet kokį testą,
todėl saugiai galite manyti, kad jokie darbai jau nebuvo vykdyti kiekviename testo kontekste.

Action Cable testavimas
--------------------

Kadangi Action Cable naudojamas skirtinguose jūsų programos lygiuose,
jums reikės testuoti tiek kanalus, ryšio klases patį, tiek ir kitus
elementus, kurie transliuoja teisingus pranešimus.

### Ryšio testo atvejis

Pagal nutylėjimą, generuojant naują Rails programą su Action Cable, taip pat bus sugeneruotas testas pagrindinei ryšio klasei (`ApplicationCable::Connection`) esančiam `test/channels/application_cable` kataloge.

Ryšio testai siekia patikrinti, ar ryšio identifikatoriai tinkamai priskiriami
arba ar bet kokie netinkami ryšio užklausų yra atmetami. Štai pavyzdys:

```ruby
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with params" do
    # Simuliuojame ryšio atidarymą, iškviečiant `connect` metodą
    connect params: { user_id: 42 }

    # Ryšio objektą galite pasiekti per `connection` testuose
    assert_equal connection.user_id, "42"
  end

  test "rejects connection without params" do
    # Naudokite `assert_reject_connection` patikrinimą, kad
    # patvirtintumėte, kad ryšys yra atmestas
    assert_reject_connection { connect }
  end
end
```

Taip pat galite nurodyti užklausos slapukus taip pat, kaip tai darote integraciniuose testuose:

```ruby
test "connects with cookies" do
  cookies.signed[:user_id] = "42"

  connect

  assert_equal connection.user_id, "42"
end
```

Daugiau informacijos rasite API dokumentacijoje [`ActionCable::Connection::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html).

### Kanalo testo atvejis

Pagal nutylėjimą, generuojant kanalą, taip pat bus sugeneruotas susijęs testas
pagal nutylėjimą esančiame `test/channels` kataloge. Štai pavyzdinis testas su pokalbių kanalu:

```ruby
require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  test "subscribes and stream for room" do
    # Simuliuojame prenumeratos sukūrimą, iškviečiant `subscribe`
    subscribe room: "15"

    # Kanalą galite pasiekti per `subscription` testuose
    assert subscription.confirmed?
    assert_has_stream "chat_15"
  end
end
```
Šis testas yra gana paprastas ir tik patvirtina, kad kanalas užsiprenumeruoja ryšį į konkretų srautą.

Taip pat galite nurodyti pagrindinius ryšio identifikatorius. Štai pavyzdinis testas su interneto pranešimų kanalu:

```ruby
require "test_helper"

class WebNotificationsChannelTest < ActionCable::Channel::TestCase
  test "užsiprenumeruoja ir srautui naudotojui" do
    stub_connection current_user: users(:john)

    subscribe

    assert_has_stream_for users(:john)
  end
end
```

Daugiau informacijos rasite API dokumentacijoje [`ActionCable::Channel::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html).

### Individualūs patvirtinimai ir transliacijų testavimas kituose komponentuose

Action Cable yra įdiegta su daugybe individualių patvirtinimų, kurie gali būti naudojami, norint sumažinti testų apimtį. Visą galimų patvirtinimų sąrašą rasite API dokumentacijoje [`ActionCable::TestHelper`](https://api.rubyonrails.org/classes/ActionCable/TestHelper.html).

Gera praktika yra užtikrinti, kad teisingas pranešimas būtų transliuojamas kituose komponentuose (pvz., jūsų valdikliuose). Tai yra būtent ten, kur Action Cable teikiami individualūs patvirtinimai yra labai naudingi. Pavyzdžiui, modelyje:

```ruby
require "test_helper"

class ProductTest < ActionCable::TestCase
  test "transliuojamas būsena po apmokejimo" do
    assert_broadcast_on("products:#{product.id}", type: "charged") do
      product.charge(account)
    end
  end
end
```

Jei norite patikrinti transliavimą, atliktą naudojant `Channel.broadcast_to`, turėtumėte naudoti `Channel.broadcasting_for`, kad generuotumėte pagrindinio srauto pavadinimą:

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end
```

```ruby
# test/jobs/chat_relay_job_test.rb
require "test_helper"

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "transliuojamas pranešimas į kambarį" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "Sveiki!") do
      ChatRelayJob.perform_now(room, "Sveiki!")
    end
  end
end
```

Eager Loading testavimas
---------------------

Įprastai programos neaktyvuojamos `development` arba `test` aplinkose, kad pagreitintų veikimą. Tačiau jos aktyvuojamos `production` aplinkoje.

Jei dėl kokios nors priežasties projektas negali įkelti tam tikro failo, geriau tai nustatyti prieš diegiant į `production`, ar ne?

### Nuolatinis integravimas

Jei jūsų projekte yra nuolatinis integravimas, aktyvusis įkėlimas CI yra paprastas būdas užtikrinti, kad programa būtų aktyvuojama.

Įprastai CI nustato tam tikrą aplinkos kintamąjį, nurodantį, kad testų rinkinys vykdomas ten. Pavyzdžiui, tai gali būti `CI`:

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

Pradedant nuo Rails 7, naujai sukurtos programos yra konfigūruojamos pagal šį numatytąjį būdą.

### Paprasti testų rinkiniai

Jei jūsų projekte nėra nuolatinio integravimo, vis tiek galite aktyvuoti programą testų rinkinyje, iškviesdami `Rails.application.eager_load!`:

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "aktyvuoja visus failus be klaidų" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk atitikimas" do
  it "aktyvuoja visus failus be klaidų" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

Papildomi testavimo ištekliai
----------------------------

### Laiko priklausomo kodo testavimas

Rails teikia įmontuotas pagalbines metodus, kurie leidžia patikrinti, ar jūsų laiko priklausomas kodas veikia kaip tikėtasi.

Štai pavyzdys, naudojantis [`travel_to`][travel_to] pagalbine:

```ruby
# Tarkime, kad vartotojas gali dovanoti po mėnesio nuo registracijos.
user = User.create(name: "Gaurish", activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?

travel_to Date.new(2004, 11, 24) do
  # Viduje `travel_to` bloko `Date.current` yra stubbed
  assert_equal Date.new(2004, 10, 24), user.activation_date
  assert user.applicable_for_gifting?
end

# Pakeitimas buvo matomas tik `travel_to` bloke.
assert_equal Date.new(2004, 10, 24), user.activation_date
```

Daugiau informacijos apie galimus laiko pagalbinius metodus rasite [`ActiveSupport::Testing::TimeHelpers`][time_helpers_api] API dokumentacijoje.
[`config.active_support.test_order`]: configuring.html#config-active-support-test-order
[image/png]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types
[travel_to]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to
[time_helpers_api]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html
