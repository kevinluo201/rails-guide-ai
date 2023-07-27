**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b550120024fb17dc176480922543264e
Rails pluginų pagrindai
====================================

Rails pluginas yra arba išplėtimas, arba modifikacija pagrindiniam karkasui. Pluginai suteikia:

* Būdą, kaip programuotojai gali dalintis naujausiomis idėjomis, nepažeisdami stabilios kodų bazės.
* Segmentuotą architektūrą, kad kodavimo vienetai galėtų būti taisomi ar atnaujinami pagal savo išleidimo tvarkaraštį.
* Išėjimą pagrindiniams kūrėjams, kad jie neturėtų įtraukti kiekvienos naujos funkcijos po saule.

Po šio vadovo perskaitymo jūs žinosite:

* Kaip sukurti pluginą nuo nulio.
* Kaip rašyti ir vykdyti plugino testus.

Šis vadovas aprašo, kaip sukurti testuojamą pluginą, kuris:

* Išplės pagrindines Ruby klases, tokiu kaip Hash ir String.
* Pridės metodus prie `ApplicationRecord` pagal `acts_as` pluginų tradiciją.
* Suteiks jums informaciją, kur įdėti generatorius į jūsų pluginą.

Šio vadovo tikslais, tarkime, kad esate uolus paukščių stebėtojas.
Jūsų mėgstamiausias paukštis yra Yaffle, ir norite sukurti pluginą, kuris leistų kitiems programuotojams pasidalinti Yaffle
gerumu.

--------------------------------------------------------------------------------

Sąranka
-----

Šiuo metu Rails pluginai kuriami kaip gembai, _gemified pluginai_. Juos galima dalintis tarp
skirtingų Rails aplikacijų naudojant RubyGems ir Bundler, jei norite.

### Sugeneruokite Gemified Pluginą

Rails turi `rails plugin new` komandą, kuri sukuria
skeletą bet kokio tipo Rails plėtros kūrimui, su galimybe
vykdyti integracinius testus naudojant tuščią Rails aplikaciją. Sukurkite savo
pluginą su šia komanda:

```bash
$ rails plugin new yaffle
```

Norėdami pamatyti naudojimą ir parinktis, paprašykite pagalbos:

```bash
$ rails plugin new --help
```

Testuojant Jūsų Naujai Sugeneruotą Pluginą
-----------------------------------

Eikite į katalogą, kuriame yra pluginas, ir redaguokite `yaffle.gemspec` failą,
pakeisdami visas eilutes, kuriose yra `TODO` reikšmės:

```ruby
spec.homepage    = "http://example.com"
spec.summary     = "Yaffle santrauka."
spec.description = "Yaffle aprašymas."

...

spec.metadata["source_code_uri"] = "http://example.com"
spec.metadata["changelog_uri"] = "http://example.com"
```

Tada paleiskite `bundle install` komandą.

Dabar galite paleisti testus naudodami `bin/test` komandą, ir turėtumėte pamatyti:

```bash
$ bin/test
...
1 vykdymas, 1 tikrinimas, 0 nesėkmės, 0 klaidos, 0 praleidimai
```

Tai jums pasakys, kad viskas buvo tinkamai sugeneruota ir jūs galite pradėti pridėti funkcionalumą.

Pagrindinių Klasės Išplėtimas
----------------------

Šiame skyriuje bus paaiškinta, kaip pridėti metodą prie String, kuris bus prieinamas bet kurioje jūsų Rails aplikacijoje.

Šiame pavyzdyje pridėsite metodą prie String, kuris vadinasi `to_squawk`. Pradėkite nuo naujo testo failo su keliais tikrinimais:

```ruby
# yaffle/test/core_ext_test.rb

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase
  def test_to_squawk_prepends_the_word_squawk
    assert_equal "squawk! Hello World", "Hello World".to_squawk
  end
end
```

Paleiskite `bin/test` komandą, kad paleistumėte testą. Šis testas turėtų nepavykti, nes mes dar neįgyvendinome `to_squawk` metodo:

```bash
$ bin/test
E

Klaida:
CoreExtTest#test_to_squawk_prepends_the_word_squawk:
NoMethodError: undefined method `to_squawk' for "Hello World":String


bin/test /path/to/yaffle/test/core_ext_test.rb:4

.

Baigta per 0.003358s, 595.6483 vykdymai/s, 297.8242 tikrinimai/s.
2 vykdymai, 1 tikrinimas, 0 nesėkmės, 1 klaida, 0 praleidimai
```

Puiku - dabar jūs esate pasiruošę pradėti kūrimą.

`lib/yaffle.rb` faile pridėkite `require "yaffle/core_ext"`:

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"

module Yaffle
  # Jūsų kodas čia...
end
```

Galų gale, sukurkite `core_ext.rb` failą ir pridėkite `to_squawk` metodą:

```ruby
# yaffle/lib/yaffle/core_ext.rb

class String
  def to_squawk
    "squawk! #{self}".strip
  end
end
```

Norėdami patikrinti, ar jūsų metodas daro tai, ką sako, paleiskite vienetų testus su `bin/test` iš savo plugino katalogo.

```
$ bin/test
...
2 vykdymai, 2 tikrinimai, 0 nesėkmės, 0 klaidos, 0 praleidimai
```

Norėdami tai pamatyti veikiant, pereikite į `test/dummy` katalogą, paleiskite `bin/rails console` ir pradėkite čiulbėti:

```irb
irb> "Hello World".to_squawk
=> "squawk! Hello World"
```

Pridėkite "acts_as" metodą prie Active Record
----------------------------------------

Pluginuose dažnai naudojamas modeliams pridėti `acts_as_something` metodas. Šiuo atveju jūs
norite parašyti metodą, vadinamą `acts_as_yaffle`, kuris pridės `squawk` metodą prie jūsų Active Record modelių.

Pradėkite nuo to, kad sukonfigūruosite savo failus taip, kad turėtumėte:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
end
```

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"
require "yaffle/acts_as_yaffle"

module Yaffle
  # Jūsų kodas čia...
end
```

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
  end
end
```
### Pridėti klasės metodą

Šis įskiepis tikisi, kad jūs jau pridėjote metodą į savo modelį, kurio pavadinimas yra `last_squawk`. Tačiau įskiepio naudotojai gali jau būti apibrėžę savo modelyje metodą, kurio pavadinimas yra `last_squawk`, kurį jie naudoja kažkam kitam. Šis įskiepis leis pakeisti pavadinimą pridedant klasės metodą, kurio pavadinimas yra `yaffle_text_field`.

Pradėkite nuo parašymo nepavykusio testo, kuris rodo norimą elgesį:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end
end
```

Paleidus `bin/test`, turėtumėte matyti šį rezultatą:

```bash
$ bin/test
# Running:

..E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NameError: uninitialized constant ActsAsYaffleTest::Wickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NameError: uninitialized constant ActsAsYaffleTest::Hickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4



Finished in 0.004812s, 831.2949 runs/s, 415.6475 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

Tai mums sako, kad neturime reikiamų modelių (Hickwall ir Wickwall), kuriuos bandome testuoti. Savo "dummy" Rails aplikacijoje galime lengvai sukurti šiuos modelius, paleisdami šiuos komandas iš `test/dummy` direktorijos:

```bash
$ cd test/dummy
$ bin/rails generate model Hickwall last_squawk:string
$ bin/rails generate model Wickwall last_squawk:string last_tweet:string
```

Dabar galite sukurti reikiamus duomenų bazės lentelius savo testavimo duomenų bazėje, nueidami į savo dummy aplikaciją ir migravę duomenų bazę. Pirmiausia paleiskite:

```bash
$ cd test/dummy
$ bin/rails db:migrate
```

Kol esate čia, pakeiskite Hickwall ir Wickwall modelius, kad jie žinotų, kad jie turėtų elgtis kaip yaffles.

```ruby
# test/dummy/app/models/hickwall.rb

class Hickwall < ApplicationRecord
  acts_as_yaffle
end
```

```ruby
# test/dummy/app/models/wickwall.rb

class Wickwall < ApplicationRecord
  acts_as_yaffle yaffle_text_field: :last_tweet
end
```

Taip pat pridėsime kodą, skirtą apibrėžti `acts_as_yaffle` metodą.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Tada galite grįžti į savo įskiepio pagrindinį katalogą (`cd ../..`) ir paleisti testus naudodami `bin/test`.

```bash
$ bin/test
# Running:

.E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974ebbe9d8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4

E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974eb8cfc8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

.

Finished in 0.008263s, 484.0999 runs/s, 242.0500 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

Vis artėjame... Dabar įgyvendinsime `acts_as_yaffle` metodo kodą, kad testai praeitų.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Paleiskite `bin/test` paskutinį kartą ir turėtumėte matyti, kad visi testai praeina:

```bash
$ bin/test
...
4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### Pridėti objekto metodą

Šis įskiepis pridės metodą, vadinamą 'squawk', bet kuriam Active Record objektui, kuris iškviečia `acts_as_yaffle`. 'squawk' metodas tiesiog nustatys vieno iš laukų duomenų bazėje reikšmę.

Pradėkite nuo parašymo nepavykusio testo, kuris rodo norimą elgesį:

```ruby
# yaffle/test/acts_as_yaffle_test.rb
require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end

  def test_hickwalls_squawk_should_populate_last_squawk
    hickwall = Hickwall.new
    hickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", hickwall.last_squawk
  end

  def test_wickwalls_squawk_should_populate_last_tweet
    wickwall = Wickwall.new
    wickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", wickwall.last_tweet
  end
end
```

Paleiskite testą, kad įsitikintumėte, kad paskutiniai du testai nepavyksta su klaida, kuriame yra "NoMethodError: undefined method \`squawk'", tada atnaujinkite `acts_as_yaffle.rb` taip:

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    included do
      def squawk(string)
        write_attribute(self.class.yaffle_text_field, string.to_squawk)
      end
    end

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Paleiskite `bin/test` dar kartą ir turėtumėte matyti:

```bash
$ bin/test
...
6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

PASTABA: `write_attribute` naudojimas modelyje laukui rašyti yra tik vienas pavyzdys, kaip įskiepis gali sąveikauti su modeliu ir ne visada bus tinkamas naudoti. Pavyzdžiui, galite taip pat naudoti:
```ruby
send("#{self.class.yaffle_text_field}=", string.to_squawk)
```

Generatoriai
----------

Generatoriai gali būti įtraukti į jūsų juostą paprasčiausiai sukurdami juos jūsų įskiepio `lib/generators` kataloge. Daugiau informacijos apie generatorių kūrimą galima rasti [Generatorių vadove](generators.html).

Jūsų Juostos Publikavimas
-------------------

Juostos įskiepiai, kurie yra šiuo metu kuriami, gali būti lengvai bendrinami iš bet kurios Git saugyklos. Norėdami pasidalinti Yaffle juosta su kitais, tiesiog įsitikinkite, kad kodas yra įtrauktas į Git saugyklą (pvz., GitHub) ir pridėkite eilutę į norimoje aplikacijoje esančią `Gemfile`:

```ruby
gem "yaffle", git: "https://github.com/rails/yaffle.git"
```

Paleidus `bundle install`, jūsų juostos funkcionalumas bus prieinamas aplikacijai.

Kai juosta yra pasiruošusi būti bendrinama kaip oficiali versija, ji gali būti publikuojama [RubyGems](https://rubygems.org).

Alternatyviai, galite pasinaudoti Bundlerio Rake užduotimis. Visą sąrašą galite pamatyti naudodami šią komandą:

```bash
$ bundle exec rake -T

$ bundle exec rake build
# Sukuria yaffle-0.1.0.gem failą pkg aplanke

$ bundle exec rake install
# Sukuria ir įdiegia yaffle-0.1.0.gem sisteminiuose įskiepiuose

$ bundle exec rake release
# Sukuria žymą v0.1.0, sukuria ir išsiunčia yaffle-0.1.0.gem į Rubygems
```

Daugiau informacijos apie juostų publikavimą RubyGems galite rasti čia: [Juostų publikavimas](https://guides.rubygems.org/publishing).

RDoc Dokumentacija
------------------

Kai jūsų juosta yra stabilizuota ir jūs esate pasiruošę ją diegti, padarykite malonumą kitiems ir ją dokumentuokite! Laimei, dokumentacija jūsų juostai rašyti yra lengva.

Pirmas žingsnis yra atnaujinti README failą su išsamią informaciją apie tai, kaip naudoti jūsų juostą. Kelios svarbios dalykų, kurias reikia įtraukti, yra:

* Jūsų vardas
* Kaip įdiegti
* Kaip pridėti funkcionalumą prie aplikacijos (kelios pavyzdinės bendros naudojimo situacijos)
* Įspėjimai, pastabos ar patarimai, kurie gali padėti vartotojams ir sutaupyti jiems laiko

Kai jūsų README yra tvirtas, peržiūrėkite ir pridėkite RDoc komentarus visiems metodams, kuriuos programuotojai naudos. Taip pat paprasta pridėti `# :nodoc:` komentarus tiems kodo dalims, kurios nėra įtrauktos į viešąją API.

Kai jūsų komentarai yra pasiruošę, nueikite į savo juostos katalogą ir paleiskite:

```bash
$ bundle exec rake rdoc
```

### Nuorodos

* [RubyGem kūrimas naudojant Bundler](https://github.com/radar/guides/blob/master/gem-development.md)
* [Naudojant .gemspecs kaip numatyta](https://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)
* [Gemspec nuoroda](https://guides.rubygems.org/specification-reference/)
