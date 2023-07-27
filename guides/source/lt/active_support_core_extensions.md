**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fdd2e5c41171c61b555549ced4d68a82
Aktyvusis palaikymas - pagrindiniai plėtiniai
==============================================

Aktyvusis palaikymas yra Ruby on Rails komponentas, atsakingas už Ruby kalbos plėtinius ir įrankius.

Jis siūlo geresnį kalbos lygmenį, skirtą tiek Rails aplikacijų kūrimui, tiek paties Ruby on Rails kūrimui.

Po šio vadovo perskaitymo, jūs žinosite:

* Kas yra pagrindiniai plėtiniai.
* Kaip įkelti visus plėtinius.
* Kaip pasirinkti tik tuos plėtinius, kuriuos norite.
* Kokius plėtinius teikia Aktyvusis palaikymas.

--------------------------------------------------------------------------------

Kaip įkelti pagrindinius plėtinius
----------------------------------

### Stand-alone Aktyvusis palaikymas

Norint turėti kuo mažesnį numatytąjį atminties našumą, Aktyvusis palaikymas numatytai įkelia minimalias priklausomybes. Jis yra padalintas į mažas dalis, todėl galima įkelti tik norimus plėtinius. Taip pat yra patogūs įėjimo taškai, skirti įkelti susijusius plėtinius vienu metu, netgi viską.

Taigi, po paprasto `require`:

```ruby
require "active_support"
```

bus įkelti tik Aktyvusiojo palaikymo pagrindiniai plėtiniai.

#### Pasirinktinio apibrėžimo pasirinkimas

Šis pavyzdys parodo, kaip įkelti [`Hash#with_indifferent_access`][Hash#with_indifferent_access]. Šis plėtinys leidžia konvertuoti `Hash` į [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess], kuris leidžia prieigą prie raktų kaip prie simbolių arba kaip prie eilučių.

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

Kiekvienam vienam kaip pagrindinio plėtinio apibrėžtam metodui šiame vadove yra pastaba, kur nurodoma, kur toks metodas yra apibrėžtas. `with_indifferent_access` atveju pastaba skaitoma taip:

PASTABA: Apibrėžta `active_support/core_ext/hash/indifferent_access.rb`.

Tai reiškia, kad jūs galite tai įkelti taip:

```ruby
require "active_support"
require "active_support/core_ext/hash/indifferent_access"
```

Aktyvusis palaikymas buvo kruopščiai peržiūrėtas, todėl pasirinkus failą, įkeliamos tik griežtai reikalingos priklausomybės, jei tokių yra.

#### Grupuotų pagrindinių plėtinių įkėlimas

Kitas lygis yra tiesiog įkelti visus `Hash` plėtinius. Taisyklės pagalba, `SomeClass` plėtiniai yra pasiekiami vienu metu, įkeliant `active_support/core_ext/some_class`.

Taigi, norint įkelti visus `Hash` plėtinius (įskaitant `with_indifferent_access`):

```ruby
require "active_support"
require "active_support/core_ext/hash"
```

#### Visų pagrindinių plėtinių įkėlimas

Galbūt norėsite tiesiog įkelti visus pagrindinius plėtinius, tam yra failas:

```ruby
require "active_support"
require "active_support/core_ext"
```

#### Viso Aktyvaus palaikymo įkėlimas

Ir galiausiai, jei norite turėti visą Aktyvųjį palaikymą, tiesiog naudokite:

```ruby
require "active_support/all"
```

Tai net neįkelia viso Aktyvaus palaikymo į atmintį iš karto, iš tikrųjų, kai kurie dalykai yra sukonfigūruoti per `autoload`, todėl jie įkeliami tik naudojant.

### Aktyvusis palaikymas Ruby on Rails aplikacijoje

Ruby on Rails aplikacija įkelia visą Aktyvųjį palaikymą, nebent [`config.active_support.bare`][] yra `true`. Tokiu atveju aplikacija įkelia tik tai, ką pati sistema pasirenka savo poreikiams, ir vis tiek gali pasirinkti pati, kaip paaiškinta ankstesniame skyriuje.


Plėtiniai visiems objektams
---------------------------

### `blank?` ir `present?`

Rails aplikacijoje šie reikšmės laikomos tuščiomis:

* `nil` ir `false`,

* eilutės, sudarytos tik iš tarpų (žr. pastabą žemiau),

* tuščios masyvai ir žodynai, ir

* bet koks kitas objektas, kuris atsako į `empty?` ir yra tuščias.

INFORMACIJA: Eilučių predikatas naudoja Unikodo sąmoningą simbolių klasę `[:space:]`, todėl pavyzdžiui U+2029 (pastraipos skirtukas) laikomas tarpais.
ĮSPĖJIMAS: Atkreipkite dėmesį, kad čia nėra paminėti skaičiai. Ypač, 0 ir 0.0 **nėra** tušti.

Pavyzdžiui, ši `ActionController::HttpAuthentication::Token::ControllerMethods` klasės metodas naudoja [`blank?`][Object#blank?] tikrinimui, ar yra pateiktas ženklas:

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

Metodas [`present?`][Object#present?] yra ekvivalentus `!blank?`. Šis pavyzdys paimtas iš `ActionDispatch::Http::Cache::Response` klasės:

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  # ...
end
```

PASTABA: Apibrėžta `active_support/core_ext/object/blank.rb` faile.


### `presence`

[`presence`][Object#presence] metodas grąžina savo gavėją, jei `present?`, ir `nil` kitu atveju. Tai naudinga idiomoms, panašioms į šią:

```ruby
host = config[:host].presence || 'localhost'
```

PASTABA: Apibrėžta `active_support/core_ext/object/blank.rb` faile.


### `duplicable?`

Nuo Ruby 2.5 dauguma objektų gali būti kopijuojami naudojant `dup` arba `clone`:

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (allocator undefined for Method)
```

Active Support teikia [`duplicable?`][Object#duplicable?] metodą, skirtą užklausti objektą apie tai:

```ruby
"foo".duplicable?           # => true
"".duplicable?              # => true
Rational(1).duplicable?     # => true
Complex(1).duplicable?      # => true
1.method(:+).duplicable?    # => false
```

ĮSPĖJIMAS: Bet kuri klasė gali neleisti kopijavimo pašalinant `dup` ir `clone` arba iškeliant iš jų išimtis. Todėl tik `rescue` gali pasakyti, ar duotas objektas yra kopijuojamas. `duplicable?` priklauso nuo aukščiau pateiktos sąrašo, bet jis yra daug greitesnis nei `rescue`. Jį naudokite tik jei žinote, kad aukščiau pateiktas sąrašas pakanka jūsų naudojimo atveju.

PASTABA: Apibrėžta `active_support/core_ext/object/duplicable.rb` faile.


### `deep_dup`

[`deep_dup`][Object#deep_dup] metodas grąžina gilų norimo objekto kopiją. Paprastai, kai kopijuojate objektą, kuris turi kitus objektus, Ruby jų nekopijuoja, todėl sukuria paviršinę objekto kopiją. Jei turite masyvą su eilute, pavyzdžiui, tai atrodytų taip:

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# objektas buvo nukopijuotas, todėl elementas buvo pridėtas tik prie kopijos
array     # => ['string']
duplicate # => ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# pirmas elementas nebuvo nukopijuotas, jis bus pakeistas abiejuose masyvuose
array     # => ['foo']
duplicate # => ['foo', 'another-string']
```

Kaip matote, nukopijuojant `Array` objektą, gavome kitą objektą, todėl galime jį modifikuoti ir originalus objektas liks nepakeistas. Tačiau tai netaikoma masyvo elementams. Kadangi `dup` nekopijuoja giliai, eilutė masyve vis dar yra tas pats objektas.

Jei jums reikia gilos objekto kopijos, turėtumėte naudoti `deep_dup`. Štai pavyzdys:

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     # => ['string']
duplicate # => ['foo']
```

Jei objektas negali būti kopijuojamas, `deep_dup` tiesiog jį grąžins:

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

PASTABA: Apibrėžta `active_support/core_ext/object/deep_dup.rb` faile.


### `try`

Kai norite iškviesti metodą objekte tik tuo atveju, jei jis nėra `nil`, paprasčiausias būdas tai pasiekti yra naudojant sąlyginės instrukcijas, kurios prideda nereikalingą šlamšą. Alternatyva yra naudoti [`try`][Object#try]. `try` yra panašus į `Object#public_send`, tik grąžina `nil`, jei yra išsiųstas į `nil`.
Štai pavyzdys:

```ruby
# be try
unless @number.nil?
  @number.next
end

# su try
@number.try(:next)
```

Kitas pavyzdys yra šis kodas iš `ActiveRecord::ConnectionAdapters::AbstractAdapter`, kur `@logger` gali būti `nil`. Matote, kad kodas naudoja `try` ir vengia nereikalingo patikrinimo.

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try` taip pat gali būti iškviestas be argumentų, bet su bloku, kuris bus vykdomas tik tada, jei objektas nėra `nil`:

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

Atkreipkite dėmesį, kad `try` praryja nėra-metodo klaidas ir grąžina `nil` vietoj to. Jei norite apsisaugoti nuo klaidų rašyme, naudokite [`try!`][Object#try!]:

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

Pastaba: Apibrėžta `active_support/core_ext/object/try.rb`.


### `class_eval(*args, &block)`

Galite įvertinti kodą bet kurio objekto vienintelės klasės kontekste naudodami [`class_eval`][Kernel#class_eval]:

```ruby
class Proc
  def bind(object)
    block, time = self, Time.current
    object.class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end
```

Pastaba: Apibrėžta `active_support/core_ext/kernel/singleton_class.rb`.


### `acts_like?(duck)`

Metodas [`acts_like?`][Object#acts_like?] suteikia galimybę patikrinti, ar tam tikra klasė elgiasi kaip kita klasė pagal paprastą konvenciją: klasė, kuri teikia tą pačią sąsają kaip `String`, apibrėžia

```ruby
def acts_like_string?
end
```

tai tik žymeklis, jos kūnas ar grąžinimo reikšmė nėra svarbūs. Tada kliento kodas gali užklausti, ar tam tikra klasė yra tinkama šiam tipui:

```ruby
some_klass.acts_like?(:string)
```

Rails turi klases, kurios elgiasi kaip `Date` ar `Time` ir laikosi šio kontrakto.

Pastaba: Apibrėžta `active_support/core_ext/object/acts_like.rb`.


### `to_param`

Visi objektai Rails atsako į metodą [`to_param`][Object#to_param], kuris turėtų grąžinti kažką, kas juos atstovauja kaip reikšmes užklausos eilutėje arba URL fragmentuose.

Pagal numatytuosius nustatymus `to_param` tiesiog iškviečia `to_s`:

```ruby
7.to_param # => "7"
```

`to_param` grąžinimo reikšmė **neturėtų** būti pabėgta:

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

Kelių klasės Rails perrašo šį metodą.

Pavyzdžiui, `nil`, `true` ir `false` grąžina save. [`Array#to_param`][Array#to_param] iškviečia `to_param` ant elementų ir sujungia rezultatą su "/":

```ruby
[0, true, String].to_param # => "0/true/String"
```

Ypatingai, Rails maršrutizavimo sistema iškviečia `to_param` ant modelių, kad gautų reikšmę `:id` vietos rezervuotajam žymekliui. `ActiveRecord::Base#to_param` grąžina modelio `id`, bet galite pervardyti šį metodą savo modeliuose. Pavyzdžiui, turint

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

gauname:

```ruby
user_path(@user) # => "/users/357-john-smith"
```

ĮSPĖJIMAS. Valdikliai turi žinoti apie bet kokį `to_param` pervardijimą, nes kai toks užklaustas užklausas, "357-john-smith" yra `params[:id]` reikšmė.

Pastaba: Apibrėžta `active_support/core_ext/object/to_param.rb`.


### `to_query`

Metodas [`to_query`][Object#to_query] sukuria užklausos eilutę, kuri susieja tam tikrą `key` su `to_param` grąžinimo reikšme. Pavyzdžiui, turint šią `to_param` apibrėžtį:

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

gauname:

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

Šis metodas pabėga viską, kas reikalinga, tiek raktui, tiek reikšmei:

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

todėl jo išvestis yra paruošta naudoti užklausos eilutėje.
Masyvai grąžina rezultatą, taikant `to_query` kiekvienam elementui su `key[]` kaip raktu, ir sujungia rezultatą su "&":

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

Taip pat, hash'ai taip pat gali būti panaudojami su `to_query`, bet su kitokia sintakse. Jei nėra perduodamo argumento, kvietimas generuoja surūšiuotą raktų/vertės priskyrimų seriją, kviečiant `to_query(key)` jo reikšmes. Tada rezultatas sujungiamas su "&":

```ruby
{ c: 3, b: 2, a: 1 }.to_query # => "a=1&b=2&c=3"
```

Metodas [`Hash#to_query`][Hash#to_query] priima pasirinktiną vardų erdvę raktams:

```ruby
{ id: 89, name: "John Smith" }.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

PASTABA: Apibrėžta `active_support/core_ext/object/to_query.rb`.


### `with_options`

Metodas [`with_options`][Object#with_options] suteikia būdą išskirti bendrus parametrus iš eilės metodų kvietimų.

Turint numatytąjį parametrų hash'ą, `with_options` perduoda proxy objektą į bloką. Bloke, metodai, iškviesti per proxy, perduodami gavėjui su sujungtais parametrais. Pavyzdžiui, galite atsikratyti dublikavimo:

```ruby
class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

šitaip:

```ruby
class Account < ApplicationRecord
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end
```

Toks idiomas taip pat gali perduoti _grupavimą_ skaitytojui. Pavyzdžiui, sakykite, norite išsiųsti naujienlaiškį, kurio kalba priklauso nuo vartotojo. Kažkur pašto siuntėjime galėtumėte grupuoti lokalės priklausančius dalykus šitaip:

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

PATARIMAS: Kadangi `with_options` perduoda kvietimus gavėjui, jie gali būti įdėti vienas į kitą. Kiekvienas įdėjimo lygis sujungs paveldėtus numatytuosius parametrus, be savųjų.

PASTABA: Apibrėžta `active_support/core_ext/object/with_options.rb`.


### JSON palaikymas

Active Support teikia geresnį `to_json` įgyvendinimą nei įprastai `json` gembė Ruby objektams. Tai yra todėl, kad kai kurie klasės, pvz., `Hash` ir `Process::Status`, reikalauja specialaus tvarkymo, kad būtų gautas tinkamas JSON atvaizdavimas.

PASTABA: Apibrėžta `active_support/core_ext/object/json.rb`.

### Egzemplioriaus kintamieji

Active Support teikia keletą metodų, palengvinančių prieigą prie egzemplioriaus kintamųjų.

#### `instance_values`

Metodas [`instance_values`][Object#instance_values] grąžina hash'ą, kuris susieja egzemplioriaus kintamųjų pavadinimus be "@" su atitinkamomis reikšmėmis. Raktai yra eilutės:

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

PASTABA: Apibrėžta `active_support/core_ext/object/instance_variables.rb`.


#### `instance_variable_names`

Metodas [`instance_variable_names`][Object#instance_variable_names] grąžina masyvą. Kiekvienas pavadinimas įtraukia "@" ženklą.

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

PASTABA: Apibrėžta `active_support/core_ext/object/instance_variables.rb`.


### Klaidų ir išimčių slopinimas

Metodai [`silence_warnings`][Kernel#silence_warnings] ir [`enable_warnings`][Kernel#enable_warnings] pakeičia `$VERBOSE` reikšmę atitinkamai per jų bloką ir po to ją atstatydina:

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

Klaidų slopinimas taip pat yra įmanomas naudojant [`suppress`][Kernel#suppress]. Šis metodas priima bet kokį išimčių klasės skaičių. Jei išimtis iškyla vykdant bloką ir yra `kind_of?` bet kurio iš argumentų, `suppress` ją sugauna ir grąžina tyliai. Kitu atveju išimtis nėra sugaunama:
```ruby
# Jei naudotojas yra užrakintas, padidinimas yra prarandamas, tai nėra didelė problema.
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

PASTABA: Apibrėžta `active_support/core_ext/kernel/reporting.rb`.


### `in?`

Predikatas [`in?`][Object#in?] patikrina, ar objektas yra įtrauktas į kitą objektą. Jei perduotas argumentas neatitinka `include?` metodo, bus iškelta `ArgumentError` išimtis.

`in?` pavyzdžiai:

```ruby
1.in?([1, 2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

PASTABA: Apibrėžta `active_support/core_ext/object/inclusion.rb`.


Plėtiniai `Module`
------------------

### Atributai

#### `alias_attribute`

Modelio atributai turi skaitytuvo, rašytojo ir predikato metodus. Galite sukurti modelio atributą, kuriam visi trys metodai yra apibrėžti naudojant [`alias_attribute`][Module#alias_attribute] metodą. Kaip ir kituose sinonimų kūrimo metodų atveju, naujas pavadinimas yra pirmas argumentas, o senas pavadinimas yra antras (vienas mnemoninis būdas yra tai, kad jie eina tokiu pačiu tvarka, kaip ir priskyrimo atveju):

```ruby
class User < ApplicationRecord
  # Galite kreiptis į el. pašto stulpelį kaip "login".
  # Tai gali būti prasminga autentifikacijos kodo atveju.
  alias_attribute :login, :email
end
```

PASTABA: Apibrėžta `active_support/core_ext/module/aliasing.rb`.


#### Vidiniai atributai

Kai apibrėžiate atributą klasėje, kuri skirta paveldėti, pavadinimo susidūrimai yra rizika. Tai yra ypatingai svarbu bibliotekoms.

Active Support apibrėžia makrokomandas [`attr_internal_reader`][Module#attr_internal_reader], [`attr_internal_writer`][Module#attr_internal_writer] ir [`attr_internal_accessor`][Module#attr_internal_accessor]. Jos elgiasi kaip jų įmontuoti Ruby `attr_*` atitikmenys, išskyrus tai, kad jos pavadina pagrindinį egzemplioriaus kintamąjį taip, kad susidūrimai būtų mažiau tikėtini.

Makrokomanda [`attr_internal`][Module#attr_internal] yra sinonimas `attr_internal_accessor`:

```ruby
# biblioteka
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# kliento kodas
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

Ankstesniame pavyzdyje gali būti atvejis, kai `:log_level` nepriklauso bibliotekos viešajai sąsajai ir jis naudojamas tik vystymui. Kliento kodas, nežinodamas apie galimą konfliktą, paveldi ir apibrėžia savo `:log_level`. Dėka `attr_internal` nėra susidūrimo.

Pagal numatytuosius nustatymus vidinio egzemplioriaus kintamasis vadinamas su priešakyje esančiu pabraukimu, pvz., `@_log_level` aukščiau pateiktame pavyzdyje. Tai galima konfigūruoti naudojant `Module.attr_internal_naming_format`, galite perduoti bet kokį `sprintf` tipo formatavimo eilutę su priešakyje esančiu `@` ir kur nors esančiu `%s`, kur bus įdėtas pavadinimas. Numatytasis yra `"@_%s"`.

Rails naudoja vidinius atributus keliuose vietose, pavyzdžiui, rodiniams:

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

PASTABA: Apibrėžta `active_support/core_ext/module/attr_internal.rb`.


#### Modulio atributai

Makrokomandos [`mattr_reader`][Module#mattr_reader], [`mattr_writer`][Module#mattr_writer] ir [`mattr_accessor`][Module#mattr_accessor] yra tokios pačios kaip ir klasės `cattr_*` makrokomandos. Iš tikrųjų, `cattr_*` makrokomandos yra tik sinonimai `mattr_*` makrokomandoms. Žr. [Klasės atributai](#klasės-atributai).

Pavyzdžiui, Active Storage žurnalo API yra generuojama naudojant `mattr_accessor`:

```ruby
module ActiveStorage
  mattr_accessor :logger
end
```

PASTABA: Apibrėžta `active_support/core_ext/module/attribute_accessors.rb`.


### Tėvai

#### `module_parent`

Įdėtame vardiniame modulyje esančio [`module_parent`][Module#module_parent] metodas grąžina modulį, kuriame yra atitinkantis konstanta:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent # => X::Y
M.module_parent       # => X::Y
```

Jei modulis yra anoniminis arba priklauso viršutinei lygybei, `module_parent` grąžina `Object`.
ĮSPĖJIMAS: Atkreipkite dėmesį, kad šiuo atveju `module_parent_name` grąžina `nil`.

PASTABA: Apibrėžta `active_support/core_ext/module/introspection.rb` faile.


#### `module_parent_name`

Metodas [`module_parent_name`][Module#module_parent_name] sujungtoje vardų modulyje grąžina visiškai kvalifikuotą modulio pavadinimą, kuris yra jo atitinkamo kintamojo viduje:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent_name # => "X::Y"
M.module_parent_name       # => "X::Y"
```

Viršutiniu lygiu arba anoniminiuose moduliuose `module_parent_name` grąžina `nil`.

ĮSPĖJIMAS: Atkreipkite dėmesį, kad šiuo atveju `module_parent` grąžina `Object`.

PASTABA: Apibrėžta `active_support/core_ext/module/introspection.rb` faile.


#### `module_parents`

Metodas [`module_parents`][Module#module_parents] iškviečia `module_parent` gavėją ir juda aukštyn, kol pasiekiamas `Object`. Šis grandinė grąžinama masyve, nuo apačios iki viršaus:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parents # => [X::Y, X, Object]
M.module_parents       # => [X::Y, X, Object]
```

PASTABA: Apibrėžta `active_support/core_ext/module/introspection.rb` faile.


### Anoniminiai

Modulis gali turėti arba neturėti pavadinimo:

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

Galite patikrinti, ar modulis turi pavadinimą naudodami predikatą [`anonymous?`][Module#anonymous?]:

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

Atkreipkite dėmesį, kad būti nepasiekiamam nereiškia būti anonimiškam:

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

tačiau anoniminis modulis apibrėžiamas pagal apibrėžimą yra nepasiekiamas.

PASTABA: Apibrėžta `active_support/core_ext/module/anonymous.rb` faile.


### Metodų Delegavimas

#### `delegate`

Makro [`delegate`][Module#delegate] siūlo paprastą būdą persiųsti metodus.

Pavyzdžiui, įsivaizduokite, kad vartotojai tam tikroje aplikacijoje turi prisijungimo informaciją `User` modelyje, o vardą ir kitus duomenis atskirame `Profile` modelyje:

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

Su tokia konfigūracija vartotojo vardą galite gauti per jų profilį, `user.profile.name`, tačiau būtų patogu vis tiek galėti tiesiogiai pasiekti tokius atributus:

```ruby
class User < ApplicationRecord
  has_one :profile

  def name
    profile.name
  end
end
```

Tai daro `delegate` už jus:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate :name, to: :profile
end
```

Tai yra trumpesnis ir aiškesnis.

Metodas turi būti viešas tikslui.

`delegate` makras priima kelis metodus:

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

Kai įterpiamas į eilutę, `:to` parinktis turėtų tapti išraiška, kuri įvertina metodui persiųstą objektą. Paprastai tai yra eilutė arba simbolis. Tokia išraiška įvertinama gavėjo kontekste:

```ruby
# persiunčia į Rails konstantą
delegate :logger, to: :Rails

# persiunčia į gavėjo klasę
delegate :table_name, to: :class
```

ĮSPĖJIMAS: Jei `:prefix` parinktis yra `true`, tai yra mažiau universalu, žr. žemiau.

Pagal numatytuosius nustatymus, jei delegavimas sukelia `NoMethodError` ir tikslas yra `nil`, išimtis yra perduodama. Galite paprašyti, kad vietoj to būtų grąžinamas `nil` naudojant `:allow_nil` parinktį:

```ruby
delegate :name, to: :profile, allow_nil: true
```

Su `:allow_nil` kvietimas `user.name` grąžina `nil`, jei vartotojas neturi profilio.

`prefix` parinktis prideda priešdėlį prie sugeneruoto metodo pavadinimo. Tai gali būti patogu, pavyzdžiui, gauti geresnį pavadinimą:
```ruby
delegate :gatvė, to: :adresas, prefix: true
```

Ankstesnis pavyzdys generuoja `adresas_gatvė` vietoje `gatvė`.

ĮSPĖJIMAS: Kadangi šiuo atveju sugeneruoto metodo pavadinimas sudarytas iš tikslinio objekto ir tikslinio metodo pavadinimų, `:to` parinktis turi būti metodo pavadinimas.

Taip pat galima konfigūruoti pasirinktinį priešdėlį:

```ruby
delegate :dydis, to: :priedas, prefix: :avataras
```

Ankstesniame pavyzdyje makro generuoja `avataras_dydis` vietoje `dydis`.

Parinktis `:private` keičia metodų matomumo sritį:

```ruby
delegate :gimimo_data, to: :profilis, private: true
```

Perduodami metodai pagal numatytuosius nustatymus yra vieši. Norėdami tai pakeisti, perduokite `private: true`.

PASTABA: Apibrėžta `active_support/core_ext/module/delegation.rb`


#### `delegate_missing_to`

Įsivaizduokite, kad norite perduoti viską, kas trūksta iš `Vartotojo` objekto, į `Profilio` objektą. [`delegate_missing_to`][Module#delegate_missing_to] makras leidžia jums tai įgyvendinti lengvai:

```ruby
class Vartotojas < ApplicationRecord
  has_one :profilis

  delegate_missing_to :profilis
end
```

Tikslas gali būti bet kas, kas gali būti iškviesta objekte, pvz., objekto kintamieji, metodai, konstantos ir kt. Tik vieši tikslinio objekto metodai yra perduodami.

PASTABA: Apibrėžta `active_support/core_ext/module/delegation.rb`.


### Metodų persikūrimas

Yra atvejų, kai jums reikia apibrėžti metodą su `define_method`, bet nežinote, ar toks metodas jau egzistuoja. Jei taip, išspausdinamas įspėjimas, jei jie yra įjungti. Tai nėra didelė problema, bet ir nešvaru.

Metodas [`redefine_method`][Module#redefine_method] užkerta kelią galimam įspėjimui, pašalindamas esamą metodą, jei reikia.

Taip pat galite naudoti [`silence_redefinition_of_method`][Module#silence_redefinition_of_method], jei norite apibrėžti
pakeitimo metodą patys (pavyzdžiui, naudojant `delegate`).

PASTABA: Apibrėžta `active_support/core_ext/module/redefine_method.rb`.


Plėtiniai `Class`
---------------------

### Klasės atributai

#### `class_attribute`

Metodas [`class_attribute`][Class#class_attribute] deklaruoja vieną ar daugiau paveldimų klasės atributų, kurie gali būti perrašomi bet kurioje hierarchijos lygyje.

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

Pavyzdžiui, `ActionMailer::Base` apibrėžia:

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

Jie taip pat gali būti pasiekiami ir perrašomi objekto lygyje.

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1, ateina iš A
a2.x # => 2, perrašyta a2
```

Rašytojo objekto metodo generavimą galima išvengti nustatant parinktį `:instance_writer` į `false`.

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false, default: "my"
  end
end
```

Modeliui gali būti naudinga ši parinktis kaip būdas užkirsti kelią masiniam priskyrimui nustatant atributą.

Skaitytojo objekto metodo generavimą galima išvengti nustatant parinktį `:instance_reader` į `false`.

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

Patogumui `class_attribute` taip pat apibrėžia objekto predikatą, kuris yra dvigubas neigimas to, ką grąžina objekto skaitytuvas. Pavyzdžiuose jis būtų pavadintas `x?`.
Kai `:instance_reader` yra `false`, egzemplioriaus predikatas grąžina `NoMethodError`, kaip ir skaitymo metodas.

Jei nenorite egzemplioriaus predikato, perduokite `instance_predicate: false`, ir jis nebus apibrėžtas.

PASTABA: Apibrėžta `active_support/core_ext/class/attribute.rb`.


#### `cattr_reader`, `cattr_writer` ir `cattr_accessor`

Makro [`cattr_reader`][Module#cattr_reader], [`cattr_writer`][Module#cattr_writer] ir [`cattr_accessor`][Module#cattr_accessor] yra analogiški savo `attr_*` atitikmenims, bet skirti klasėms. Jie inicializuoja klasės kintamąjį į `nil`, jei jis dar neegzistuoja, ir generuoja atitinkamus klasės metodus, skirtus jį pasiekti:

```ruby
class MysqlAdapter < AbstractAdapter
  # Generuoja klasės metodus, skirtus pasiekti @@emulate_booleans.
  cattr_accessor :emulate_booleans
end
```

Taip pat, galite perduoti bloką `cattr_*`, kad nustatytumėte atributą su numatyta reikšme:

```ruby
class MysqlAdapter < AbstractAdapter
  # Generuoja klasės metodus, skirtus pasiekti @@emulate_booleans su numatyta reikšme true.
  cattr_accessor :emulate_booleans, default: true
end
```

Taip pat yra sukuriami egzemplioriaus metodai patogumui, jie yra tiesiog peržiūros į klasės atributą. Taigi, egzemplioriai gali keisti klasės atributą, bet negali jį perrašyti, kaip tai atsitinka su `class_attribute` (žr. aukščiau). Pavyzdžiui, turint

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

mes galime pasiekti `field_error_proc` per peržiūras.

Skaitymo egzemplioriaus metodo generavimą galima išvengti nustatant `:instance_reader` į `false`, o rašymo egzemplioriaus metodo generavimą galima išvengti nustatant `:instance_writer` į `false`. Abu metodai gali būti išvengti nustatant `:instance_accessor` į `false`. Visais atvejais reikšmė turi būti tiksliai `false`, o ne bet kokia klaidinga reikšmė.

```ruby
module A
  class B
    # Nebus sugeneruotas first_name egzemplioriaus skaitytuvas.
    cattr_accessor :first_name, instance_reader: false
    # Nebus sugeneruotas last_name= egzemplioriaus rašytojas.
    cattr_accessor :last_name, instance_writer: false
    # Nebus sugeneruotas surname egzemplioriaus skaitytuvas arba surname= rašytojas.
    cattr_accessor :surname, instance_accessor: false
  end
end
```

Modeliui gali būti naudinga nustatyti `:instance_accessor` į `false` kaip būdą užkirsti kelią masiniam priskyrimui nustatyti atributą.

PASTABA: Apibrėžta `active_support/core_ext/module/attribute_accessors.rb`.


### Subklasės ir palikuonys

#### `subclasses`

Metodas [`subclasses`][Class#subclasses] grąžina gavėjo subklases:

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

Nenurodoma, kokia tvarka šios klasės yra grąžinamos.

PASTABA: Apibrėžta `active_support/core_ext/class/subclasses.rb`.


#### `descendants`

Metodas [`descendants`][Class#descendants] grąžina visas klases, kurios yra `<` nei gavėjas:

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

Nenurodoma, kokia tvarka šios klasės yra grąžinamos.

PASTABA: Apibrėžta `active_support/core_ext/class/subclasses.rb`.


Plėtiniai `String`
------------------

### Išvesties saugumas

#### Motyvacija

Duomenų įterpimas į HTML šablonus reikalauja papildomos priežiūros. Pavyzdžiui, negalite tiesiog įterpti `@review.title` į HTML puslapį. Vienas dalykas, jei apžvalgos pavadinimas yra "Flanagan & Matz rules!", išvestis nebus gerai suformuota, nes ampersandas turi būti pakeisti į "&amp;amp;". Be to, priklausomai nuo programos, tai gali būti didelė saugumo spraga, nes vartotojai gali įterpti kenksmingą HTML, nustatydami rankų darbo apžvalgos pavadinimą. Daugiau informacijos apie rizikas dėl tarp svetainių skriptų galite rasti [Saugumo vadove](security.html#cross-site-scripting-xss).
#### Saugūs eilutės

Active Support turi sąvoką _(html) saugios_ eilutės. Saugi eilutė yra žymima kaip įterpiama į HTML be jokio pakeitimo. Ji yra patikima, nepriklausomai nuo to, ar ji buvo išvengta ar ne.

Pagal nutylėjimą eilutės laikomos _nesaugiomis_:

```ruby
"".html_safe? # => false
```

Galite gauti saugią eilutę iš esamos naudodami [`html_safe`][String#html_safe] metodą:

```ruby
s = "".html_safe
s.html_safe? # => true
```

Svarbu suprasti, kad `html_safe` nevykdo jokio išvengimo, tai tik patvirtinimas:

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

Jūsų atsakomybė užtikrinti, kad `html_safe` būtų tinkamai naudojamas tam tikroje eilutėje.

Jei pridedate prie saugios eilutės, arba vietiniu būdu naudojant `concat`/`<<`, arba su `+`, rezultatas yra saugi eilutė. Nesaugūs argumentai yra išvengiami:

```ruby
"".html_safe + "<" # => "&lt;"
```

Saugūs argumentai yra tiesiog pridedami:

```ruby
"".html_safe + "<".html_safe # => "<"
```

Šių metodų neturėtumėte naudoti įprastose peržiūrose. Nesaugios reikšmės automatiškai yra išvengiamos:

```erb
<%= @review.title %> <%# gerai, išvengiama, jei reikia %>
```

Norėdami įterpti kažką tiesiogiai, naudokite [`raw`][] pagalbininką, o ne kviesdami `html_safe`:

```erb
<%= raw @cms.current_template %> <%# įterpia @cms.current_template kaip yra %>
```

arba, ekvivalentiškai, naudokite `<%==`:

```erb
<%== @cms.current_template %> <%# įterpia @cms.current_template kaip yra %>
```

`raw` pagalbininkas jums kviečia `html_safe`:

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

PASTABA: Apibrėžta `active_support/core_ext/string/output_safety.rb`.


#### Transformacija

Taisyklės pagalba, išskyrus galbūt sujungimą, kaip paaiškinta aukščiau, bet koks metodas, kuris gali pakeisti eilutę, suteikia jums nesaugią eilutę. Tai yra `downcase`, `gsub`, `strip`, `chomp`, `underscore`, ir kt.

Atveju, kai vietinio pakeitimo, pvz., `gsub!`, gavėjas pats tampa nesaugus.

INFORMACIJA: Saugumo bitas visada yra prarandamas, nepriklausomai nuo to, ar pakeitimas iš tikrųjų kažką pakeitė.

#### Konversija ir koercija

Kviečiant `to_s` ant saugios eilutės grąžinama saugi eilutė, bet koercija su `to_str` grąžina nesaugią eilutę.

#### Kopijavimas

Kviečiant `dup` arba `clone` ant saugių eilučių gaunamos saugios eilutės.

### `remove`

Metodas [`remove`][String#remove] pašalins visus šablonus:

```ruby
"Hello World".remove(/Hello /) # => "World"
```

Taip pat yra destruktyvi versija `String#remove!`.

PASTABA: Apibrėžta `active_support/core_ext/string/filters.rb`.


### `squish`

Metodas [`squish`][String#squish] pašalina pradines ir galines tarpus, ir pakeičia tarpus su vienu tarpeliu:

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

Taip pat yra destruktyvi versija `String#squish!`.

Atkreipkite dėmesį, kad jis tvarko tiek ASCII, tiek Unikodo tarpus.

PASTABA: Apibrėžta `active_support/core_ext/string/filters.rb`.


### `truncate`

Metodas [`truncate`][String#truncate] grąžina kopiją, kurios ilgis yra sumažintas iki nurodyto `length`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

Elipsė gali būti pritaikyta su `:omission` parinktimi:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

Ypač svarbu pastebėti, kad sutrumpinimas atsižvelgia į išvengimo eilutės ilgį.

Prašykite `:separator`, kad sutrumpintumėte eilutę natūraliame pertraukime:
```ruby
"Oh dear! Oh dear! Aš pavėluosiu!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! Aš pavėluosiu!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

Parametras `:separator` gali būti reguliariosios išraiškos objektas:

```ruby
"Oh dear! Oh dear! Aš pavėluosiu!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

Pirmuose pavyzdžiuose "dear" yra pjaunama pirmiausia, bet tada `:separator` tai neleidžia.

PASTABA: Apibrėžta `active_support/core_ext/string/filters.rb`.


### `truncate_bytes`

Metodas [`truncate_bytes`][String#truncate_bytes] grąžina kopiją savo gavėjo, sumažintą iki daugiausiai `bytesize` baitų:

```ruby
"👍👍👍👍".truncate_bytes(15)
# => "👍👍👍…"
```

Elipsė gali būti pritaikyta su `:omission` parametru:

```ruby
"👍👍👍👍".truncate_bytes(15, omission: "🖖")
# => "👍👍🖖"
```

PASTABA: Apibrėžta `active_support/core_ext/string/filters.rb`.


### `truncate_words`

Metodas [`truncate_words`][String#truncate_words] grąžina kopiją savo gavėjo, sumažintą po tam tikro žodžių skaičiaus:

```ruby
"Oh dear! Oh dear! Aš pavėluosiu!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

Elipsė gali būti pritaikyta su `:omission` parametru:

```ruby
"Oh dear! Oh dear! Aš pavėluosiu!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

Prašome perduoti `:separator`, kad sutrumpintumėte eilutę natūraliame pertraukime:

```ruby
"Oh dear! Oh dear! Aš pavėluosiu!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! Aš pavėluosiu..."
```

Parametras `:separator` gali būti reguliariosios išraiškos objektas:

```ruby
"Oh dear! Oh dear! Aš pavėluosiu!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

PASTABA: Apibrėžta `active_support/core_ext/string/filters.rb`.


### `inquiry`

Metodas [`inquiry`][String#inquiry] konvertuoja eilutę į `StringInquirer` objektą, padarant lygybės tikrinimą gražesnį.

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

PASTABA: Apibrėžta `active_support/core_ext/string/inquiry.rb`.


### `starts_with?` ir `ends_with?`

Active Support apibrėžia 3-as asmenies sinonimus `String#start_with?` ir `String#end_with?`:

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```

PASTABA: Apibrėžta `active_support/core_ext/string/starts_ends_with.rb`.

### `strip_heredoc`

Metodas [`strip_heredoc`][String#strip_heredoc] pašalina įdėtą tekstą.

Pavyzdžiui:

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    This command does such and such.

    Supported options are:
      -h         This message
      ...
  USAGE
end
```

vartotojas matytų naudojimo pranešimą, išlygintą su kairiuoju kraštu.

Techniškai, jis ieško mažiausiai įdėtoje eilutėje visoje eilutėje ir pašalina
tokio kiekio pradinius tuščius tarpus.

PASTABA: Apibrėžta `active_support/core_ext/string/strip.rb`.


### `indent`

Metodas [`indent`][String#indent] įtraukia eilutes gavėjui:

```ruby
<<EOS.indent(2)
def some_method
  some_code
end
EOS
# =>
  def some_method
    some_code
  end
```

Antrasis argumentas, `indent_string`, nurodo, kokį įtraukimo simbolį naudoti. Numatytoji reikšmė yra `nil`, kuri nurodo metodui padaryti išsilavinimą, žiūrint į pirmą įdėtąją eilutę, ir jei jos nėra, naudoti tarpą.

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

Nors `indent_string` paprastai yra vienas tarpas ar tabuliacija, jis gali būti bet koks simbolis.

Trečiasis argumentas, `indent_empty_lines`, yra žymeklis, kuris nurodo, ar tuščios eilutės turėtų būti įtrauktos. Numatytoji reikšmė yra false.

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

Metodas [`indent!`][String#indent!] atlieka įtraukimą vietoje.

PASTABA: Apibrėžta `active_support/core_ext/string/indent.rb`.
### Prieiga

#### `at(position)`

[`at`][String#at] metodas grąžina eilutės simbolį, esantį pozicijoje `position`:

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

PASTABA: Apibrėžta `active_support/core_ext/string/access.rb` faile.


#### `from(position)`

[`from`][String#from] metodas grąžina eilutės dalį, pradedant nuo pozicijos `position`:

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

PASTABA: Apibrėžta `active_support/core_ext/string/access.rb` faile.


#### `to(position)`

[`to`][String#to] metodas grąžina eilutės dalį iki pozicijos `position`:

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

PASTABA: Apibrėžta `active_support/core_ext/string/access.rb` faile.


#### `first(limit = 1)`

[`first`][String#first] metodas grąžina eilutės dalį, kuri sudaryta iš pirmųjų `limit` simbolių.

Kviečiant `str.first(n)` metodą, jei `n` > 0, tai yra ekvivalentu `str.to(n-1)`, o jei `n` == 0, grąžinama tuščia eilutė.

PASTABA: Apibrėžta `active_support/core_ext/string/access.rb` faile.


#### `last(limit = 1)`

[`last`][String#last] metodas grąžina eilutės dalį, kuri sudaryta iš paskutinių `limit` simbolių.

Kviečiant `str.last(n)` metodą, jei `n` > 0, tai yra ekvivalentu `str.from(-n)`, o jei `n` == 0, grąžinama tuščia eilutė.

PASTABA: Apibrėžta `active_support/core_ext/string/access.rb` faile.


### Linksniai

#### `pluralize`

[`pluralize`][String#pluralize] metodas grąžina savo argumento daugiskaitą:

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

Kaip rodo ankstesnis pavyzdys, Active Support žino keletą nereguliarių daugiskaitos formų ir neskaitomų daiktavardžių. Įdiegtos taisyklės gali būti išplėstos `config/initializers/inflections.rb` faile. Šis failas pagal numatytuosius nustatymus yra generuojamas `rails new` komandos ir turi instrukcijas komentarų pavidalu.

`pluralize` metodas taip pat gali priimti pasirinktinį `count` parametrą. Jei `count == 1`, grąžinama vienaskaita forma. Kitais `count` reikšmės atvejais grąžinama daugiskaita forma:

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

Active Record naudoja šį metodą, kad apskaičiuotų numatytąją lentelės pavadinimą, kuris atitinka modelį:

```ruby
# active_record/model_schema.rb
def undecorated_table_name(model_name)
  table_name = model_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb` faile.


#### `singularize`

[`singularize`][String#singularize] metodas yra `pluralize` metodo atvirkštinė funkcija:

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

Asociacijos naudoja šį metodą, kad apskaičiuotų atitinkamo numatomo susijusio klasės pavadinimą:

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb` faile.


#### `camelize`

[`camelize`][String#camelize] metodas grąžina savo argumentą camel case formato eilute:

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

Taisyklės pagalba galima manyti, kad šis metodas transformuoja kelius į Ruby klasės ar modulio pavadinimus, kur slash'ai atskiria vardų erdves:

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

Pavyzdžiui, Action Pack naudoja šį metodą, kad įkeltų klasę, kuri teikia tam tikrą sesijos saugyklą:

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize` metodas priima pasirinktinį argumentą, kuris gali būti `:upper` (numatytasis) arba `:lower`. Su paskutiniuoju mažinamas pirmasis raidė:

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

Tai gali būti naudinga skaičiuoti metodų pavadinimus kalboje, kuri laikosi šios konvencijos, pavyzdžiui, JavaScript.

INFO: Taisyklės pagalba galite manyti, kad `camelize` yra `underscore` atvirkštinė funkcija, nors yra atvejų, kai tai netaikoma: `"SSLError".underscore.camelize` grąžina `"SslError"`. Norint palaikyti tokias situacijas, Active Support leidžia nurodyti akronimus `config/initializers/inflections.rb`:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize` yra sinonimas [`camelcase`][String#camelcase].

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `underscore`

Metodas [`underscore`][String#underscore] veikia atvirkščiai, iš camel case pavadinimų gaunant kelius:

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

Taip pat pakeičia "::" į "/":

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

ir supranta mažąsias raides pradžioje:

```ruby
"visualEffect".underscore # => "visual_effect"
```

`underscore` nepriima jokių argumentų.

Rails naudoja `underscore` gauti mažąsias raides kontrolerio klasėms:

```ruby
# actionpack/lib/abstract_controller/base.rb
def controller_path
  @controller_path ||= name.delete_suffix("Controller").underscore
end
```

Pavyzdžiui, ši reikšmė yra ta, kurią gaunate `params[:controller]`.

INFO: Taisyklės pagalba galite manyti, kad `underscore` yra `camelize` atvirkštinė funkcija, nors yra atvejų, kai tai netaikoma. Pavyzdžiui, `"SSLError".underscore.camelize` grąžina `"SslError"`.

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `titleize`

Metodas [`titleize`][String#titleize] didina raides gavėjo žodyje:

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize` yra sinonimas [`titlecase`][String#titlecase].

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `dasherize`

Metodas [`dasherize`][String#dasherize] pakeičia pabraukimus gavėjo brūkšneliais:

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

Modelių XML serijizatorius naudoja šį metodą, kad pakeistų mazgų pavadinimus brūkšneliais:

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `demodulize`

Duodamas eilutės su kvalifikuotu konstantos pavadinimu, [`demodulize`][String#demodulize] grąžina tikrą konstantos pavadinimą, t. y. dešinįjį jos dalį:

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""
```

Pavyzdžiui, Active Record naudoja šį metodą, kad apskaičiuotų counter cache stulpelio pavadinimą:

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `deconstantize`

Duodamas eilutės su kvalifikuota konstantos nuoroda, [`deconstantize`][String#deconstantize] pašalina dešinę dalį, paliekant konstantos konteinerio pavadinimą:

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `parameterize`

Metodas [`parameterize`][String#parameterize] normalizuoja gavėją taip, kad jį būtų galima naudoti gražiuose URL.

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

Norint išlaikyti eilutės raidžių dydį, nustatykite `preserve_case` argumentą į true. Pagal nutylėjimą, `preserve_case` yra nustatytas į false.

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

Norint naudoti pasirinktinį skyriklį, pakeiskite `separator` argumentą.

```ruby
"John Smith".parameterize(separator: "_") # => "john_smith"
"Kurt Gödel".parameterize(separator: "_") # => "kurt_godel"
```

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `tableize`

Metodas [`tableize`][String#tableize] yra `underscore` sekantis `pluralize`.

```ruby
"Person".tableize      # => "people"
"Invoice".tableize     # => "invoices"
"InvoiceLine".tableize # => "invoice_lines"
```

Taisyklės pagalba, `tableize` grąžina lentelės pavadinimą, kuris atitinka duotą modelį paprastais atvejais. Tikra implementacija Active Record nėra tiesiog `tableize`, nes ji taip pat demodulizuoja klasės pavadinimą ir patikrina kelias parinktis, kurios gali paveikti grąžinamą eilutę.

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `classify`

Metodas [`classify`][String#classify] yra `tableize` atvirkštinis metodas. Jis grąžina klasės pavadinimą, kuris atitinka lentelės pavadinimą:

```ruby
"people".classify        # => "Person"
"invoices".classify      # => "Invoice"
"invoice_lines".classify # => "InvoiceLine"
```

Metodas supranta kvalifikuotus lentelės pavadinimus:

```ruby
"highrise_production.companies".classify # => "Company"
```

Atkreipkite dėmesį, kad `classify` grąžina klasės pavadinimą kaip eilutę. Galite gauti faktinį klasės objektą, iškviesdami `constantize` ant jo, kaip paaiškinta toliau.

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `constantize`

Metodas [`constantize`][String#constantize] išsprendžia konstantos nuorodos išraišką savo gavėjui:

```ruby
"Integer".constantize # => Integer

module M
  X = 1
end
"M::X".constantize # => 1
```

Jeigu eilutė neišsiskiria į jokią žinomą konstantą ar jos turinys neteisingas konstantos pavadinimas, `constantize` iškelia `NameError`.

Konstantos pavadinimo išsprendimas pagal `constantize` visada prasideda nuo viršutinio lygio `Object`, net jei nėra pirminio "::".

```ruby
X = :in_Object
module M
  X = :in_M

  X                 # => :in_M
  "::X".constantize # => :in_Object
  "X".constantize   # => :in_Object (!)
end
```

Taigi, tai apskritai nėra ekvivalentu tam, ką Ruby darytų tame pačiame taške, jei būtų įvertinta tikra konstanta.

Pašto testavimo atvejai gauna testuojamą paštą iš testo klasės pavadinimo naudodami `constantize`:

```ruby
# action_mailer/test_case.rb
def determine_default_mailer(name)
  name.delete_suffix("Test").constantize
rescue NameError => e
  raise NonInferrableMailerError.new(name)
end
```

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `humanize`

Metodas [`humanize`][String#humanize] keičia atributo pavadinimą, kad jis būtų tinkamas rodyti galutiniam vartotojui.

Konkrečiai, jis atlieka šiuos keitimus:

  * Taiko žmogiškus linksniavimo taisykles argumentui.
  * Pašalina pradinius pabraukimus, jei tokie yra.
  * Pašalina "_id" priesagą, jei tokia yra.
  * Pakeičia pabraukimus tarp žodžių tarpu, jei tokie yra.
  * Mažina visus žodžius, išskyrus akronimus.
  * Didina pirmąjį žodį.

Pirmojo žodžio didinimas gali būti išjungtas nustatant `:capitalize` parinktį į `false` (pagal nutylėjimą `true`).

```ruby
"name".humanize                         # => "Name"
"author_id".humanize                    # => "Author"
"author_id".humanize(capitalize: false) # => "author"
"comments_count".humanize               # => "Comments count"
"_id".humanize                          # => "Id"
```

Jei "SSL" būtų apibrėžtas kaip akronimas:

```ruby
'ssl_error'.humanize # => "SSL error"
```

Pagalbinis metodas `full_messages` naudoja `humanize` kaip atsarginę galimybę įtraukti atributo pavadinimus:

```ruby
def full_messages
  map { |attribute, message| full_message(attribute, message) }
end

def full_message
  # ...
  attr_name = attribute.to_s.tr('.', '_').humanize
  attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
  # ...
end
```

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `foreign_key`

Metodas [`foreign_key`][String#foreign_key] iš klasės pavadinimo suteikia svetimos rakto stulpelio pavadinimą. Tam jis demodulizuoja, pabraukia ir prideda "_id":

```ruby
"User".foreign_key           # => "user_id"
"InvoiceLine".foreign_key    # => "invoice_line_id"
"Admin::Session".foreign_key # => "session_id"
```
Pereikškite klaidingą argumentą, jei nenorite pabraukti "_id":

```ruby
"User".foreign_key(false) # => "userid"
```

Asociacijos naudoja šią metodą, kad nustatytų užsienio raktus, pavyzdžiui, `has_one` ir `has_many` tai daro:

```ruby
# active_record/associations.rb
foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
```

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `upcase_first`

Metodas [`upcase_first`][String#upcase_first] didina pirmąjį simbolį:

```ruby
"employee salary".upcase_first # => "Employee salary"
"".upcase_first                # => ""
```

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `downcase_first`

Metodas [`downcase_first`][String#downcase_first] paverčia pirmąjį simbolį mažosiomis raidėmis:

```ruby
"If I had read Alice in Wonderland".downcase_first # => "if I had read Alice in Wonderland"
"".downcase_first                                  # => ""
```

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


### Konversijos

#### `to_date`, `to_time`, `to_datetime`

Metodai [`to_date`][String#to_date], [`to_time`][String#to_time] ir [`to_datetime`][String#to_datetime] yra praktiški apvalkalai aplink `Date._parse`:

```ruby
"2010-07-27".to_date              # => Tue, 27 Jul 2010
"2010-07-27 23:37:00".to_time     # => 2010-07-27 23:37:00 +0200
"2010-07-27 23:37:00".to_datetime # => Tue, 27 Jul 2010 23:37:00 +0000
```

`to_time` priima pasirenkamą argumentą `:utc` arba `:local`, nurodantį, kurią laiko juostą norite gauti:

```ruby
"2010-07-27 23:42:00".to_time(:utc)   # => 2010-07-27 23:42:00 UTC
"2010-07-27 23:42:00".to_time(:local) # => 2010-07-27 23:42:00 +0200
```

Numatytasis yra `:local`.

Norėdami gauti daugiau informacijos, kreipkitės į `Date._parse` dokumentaciją.

INFO: Visi trys grąžina `nil` tuščiems gavėjams.

PASTABA: Apibrėžta `active_support/core_ext/string/conversions.rb`.


Plėtiniai `Symbol` tipo objektams
----------------------

### `starts_with?` ir `ends_with?`

Active Support apibrėžia 3-as asmenies sinonimus `Symbol#start_with?` ir `Symbol#end_with?`:

```ruby
:foo.starts_with?("f") # => true
:foo.ends_with?("o")   # => true
```

PASTABA: Apibrėžta `active_support/core_ext/symbol/starts_ends_with.rb`.

Plėtiniai `Numeric` tipo objektams
-----------------------

### Baitai

Visi skaičiai atsako į šiuos metodus:

* [`bytes`][Numeric#bytes]
* [`kilobytes`][Numeric#kilobytes]
* [`megabytes`][Numeric#megabytes]
* [`gigabytes`][Numeric#gigabytes]
* [`terabytes`][Numeric#terabytes]
* [`petabytes`][Numeric#petabytes]
* [`exabytes`][Numeric#exabytes]

Jie grąžina atitinkamą baitų kiekį, naudodami konversijos faktorių 1024:

```ruby
2.kilobytes   # => 2048
3.megabytes   # => 3145728
3.5.gigabytes # => 3758096384.0
-4.exabytes   # => -4611686018427387904
```

Vienaskaitos formos yra sinonimai, todėl galite sakyti:

```ruby
1.megabyte # => 1048576
```

PASTABA: Apibrėžta `active_support/core_ext/numeric/bytes.rb`.


### Laikas

Šie metodai:

* [`seconds`][Numeric#seconds]
* [`minutes`][Numeric#minutes]
* [`hours`][Numeric#hours]
* [`days`][Numeric#days]
* [`weeks`][Numeric#weeks]
* [`fortnights`][Numeric#fortnights]

leidžia deklaruoti ir skaičiuoti laiką, pvz., `45.minutes + 2.hours + 4.weeks`. Jų grąžinamos reikšmės taip pat gali būti pridėtos arba atimtos nuo laiko objektų.

Šiuos metodus galima derinti su [`from_now`][Duration#from_now], [`ago`][Duration#ago] ir kt., norint gauti tikslų datų skaičiavimą. Pavyzdžiui:

```ruby
# ekvivalentu Time.current.advance(days: 1)
1.day.from_now

# ekvivalentu Time.current.advance(weeks: 2)
2.weeks.from_now

# ekvivalentu Time.current.advance(days: 4, weeks: 5)
(4.days + 5.weeks).from_now
```

ĮSPĖJIMAS. Kitoms trukmėms, prašome kreiptis į `Integer` laiko plėtinius.

PASTABA: Apibrėžta `active_support/core_ext/numeric/time.rb`.


### Formatavimas

Leidžia formatuoti skaičius įvairiais būdais.

Gauti skaičiaus simbolių eilutės atitikmenį kaip telefono numerį:

```ruby
5551234.to_fs(:phone)
# => 555-1234
1235551234.to_fs(:phone)
# => 123-555-1234
1235551234.to_fs(:phone, area_code: true)
# => (123) 555-1234
1235551234.to_fs(:phone, delimiter: " ")
# => 123 555 1234
1235551234.to_fs(:phone, area_code: true, extension: 555)
# => (123) 555-1234 x 555
1235551234.to_fs(:phone, country_code: 1)
# => +1-123-555-1234
```

Gauti skaičiaus simbolių eilutės atitikmenį kaip valiutą:

```ruby
1234567890.50.to_fs(:currency)                 # => $1,234,567,890.50
1234567890.506.to_fs(:currency)                # => $1,234,567,890.51
1234567890.506.to_fs(:currency, precision: 3)  # => $1,234,567,890.506
```
Sukurkite skaičiaus eilutinį atvaizdavimą kaip procentą:

```ruby
100.to_fs(:percentage)
# => 100.000%
100.to_fs(:percentage, precision: 0)
# => 100%
1000.to_fs(:percentage, delimiter: '.', separator: ',')
# => 1.000,000%
302.24398923423.to_fs(:percentage, precision: 5)
# => 302.24399%
```

Sukurkite skaičiaus eilutinį atvaizdavimą su skirtukais:

```ruby
12345678.to_fs(:delimited)                     # => 12,345,678
12345678.05.to_fs(:delimited)                  # => 12,345,678.05
12345678.to_fs(:delimited, delimiter: ".")     # => 12.345.678
12345678.to_fs(:delimited, delimiter: ",")     # => 12,345,678
12345678.05.to_fs(:delimited, separator: " ")  # => 12,345,678 05
```

Sukurkite skaičiaus eilutinį atvaizdavimą su apvalinimu:

```ruby
111.2345.to_fs(:rounded)                     # => 111.235
111.2345.to_fs(:rounded, precision: 2)       # => 111.23
13.to_fs(:rounded, precision: 5)             # => 13.00000
389.32314.to_fs(:rounded, precision: 0)      # => 389
111.2345.to_fs(:rounded, significant: true)  # => 111
```

Sukurkite skaičiaus eilutinį atvaizdavimą kaip skaitytino baitų skaičiaus:

```ruby
123.to_fs(:human_size)                  # => 123 Baitai
1234.to_fs(:human_size)                 # => 1.21 KB
12345.to_fs(:human_size)                # => 12.1 KB
1234567.to_fs(:human_size)              # => 1.18 MB
1234567890.to_fs(:human_size)           # => 1.15 GB
1234567890123.to_fs(:human_size)        # => 1.12 TB
1234567890123456.to_fs(:human_size)     # => 1.1 PB
1234567890123456789.to_fs(:human_size)  # => 1.07 EB
```

Sukurkite skaičiaus eilutinį atvaizdavimą kaip skaitytino žodžiais:

```ruby
123.to_fs(:human)               # => "123"
1234.to_fs(:human)              # => "1.23 Tūkstantis"
12345.to_fs(:human)             # => "12.3 Tūkstantis"
1234567.to_fs(:human)           # => "1.23 Milijonas"
1234567890.to_fs(:human)        # => "1.23 Milijardas"
1234567890123.to_fs(:human)     # => "1.23 Trilijonas"
1234567890123456.to_fs(:human)  # => "1.23 Kvadrilijonas"
```

Pastaba: Apibrėžta `active_support/core_ext/numeric/conversions.rb`.

Plėtiniai `Integer` tipui
-----------------------

### `multiple_of?`

Metodas [`multiple_of?`][Integer#multiple_of?] patikrina, ar sveikasis skaičius yra argumento daugiklis:

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

Pastaba: Apibrėžta `active_support/core_ext/integer/multiple.rb`.


### `ordinal`

Metodas [`ordinal`][Integer#ordinal] grąžina eilutę su skaitmeniu ir atitinkančiu priesaga:

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

Pastaba: Apibrėžta `active_support/core_ext/integer/inflections.rb`.


### `ordinalize`

Metodas [`ordinalize`][Integer#ordinalize] grąžina eilutę su skaitmeniu ir atitinkančiu priesaga. Palyginimui, `ordinal` metodas grąžina **tik** priesagos eilutę.

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

Pastaba: Apibrėžta `active_support/core_ext/integer/inflections.rb`.


### Laikas

Šie metodai:

* [`months`][Integer#months]
* [`years`][Integer#years]

leidžia deklaruoti ir skaičiuoti laiką, pvz., `4.months + 5.years`. Jų grąžinamos reikšmės taip pat gali būti pridėtos arba atimtos nuo laiko objektų.

Šiuos metodus galima derinti su [`from_now`][Duration#from_now], [`ago`][Duration#ago] ir pan., siekiant tikslaus datos skaičiavimo. Pavyzdžiui:

```ruby
# ekvivalentu Time.current.advance(months: 1)
1.month.from_now

# ekvivalentu Time.current.advance(years: 2)
2.years.from_now

# ekvivalentu Time.current.advance(months: 4, years: 5)
(4.months + 5.years).from_now
```

ĮSPĖJIMAS. Kitoms trukmėms kreipkitės į `Numeric` laiko plėtinius.

Pastaba: Apibrėžta `active_support/core_ext/integer/time.rb`.


Plėtiniai `BigDecimal` tipui
--------------------------

### `to_s`

Metodas `to_s` numatytuoju parametru naudoja "F" formatą. Tai reiškia, kad paprastas `to_s` iškvietimas grąžins slankiojo kablelio atvaizdavimą, o ne inžinerinį įrašą:

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

Vis dar galima naudoti inžinerinį įrašą:

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

Plėtiniai `Enumerable` tipui
--------------------------

### `sum`

Metodas [`sum`][Enumerable#sum] sudeda elementus iš eilės:
```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

Sudėtis priima tik elementus, kurie gali atlikti veiksmą `+`:

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{ a: 1, b: 2, c: 3 }.sum          # => [:a, 1, :b, 2, :c, 3]
```

Tuščios kolekcijos suma pagal nutylėjimą yra nulis, tačiau tai galima keisti:

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

Jeigu yra pateiktas blokas, `sum` tampa iteratoriumi, kuris grąžina kolekcijos elementus ir sudeda grąžintas reikšmes:

```ruby
(1..5).sum { |n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

Tuščios gavėjo sumos taip pat galima keisti šioje formoje:

```ruby
[].sum(1) { |n| n**3 } # => 1
```

PASTABA: Apibrėžta `active_support/core_ext/enumerable.rb`.


### `index_by`

Metodas [`index_by`][Enumerable#index_by] sugeneruoja raktų ir reikšmių poras, kur raktai yra kažkokio raktinio žodžio pagal indeksą.

Jis peržiūri kolekciją ir perduoda kiekvieną elementą blokui. Elementas bus raktas, grąžintas bloko:

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

ĮSPĖJIMAS. Raktai paprastai turėtų būti unikalūs. Jei blokas grąžina tą pačią reikšmę skirtingiems elementams, tokiu atveju nebus sukurtas joks rinkinys šiam raktui. Laimi paskutinis elementas.

PASTABA: Apibrėžta `active_support/core_ext/enumerable.rb`.


### `index_with`

Metodas [`index_with`][Enumerable#index_with] sugeneruoja raktų ir reikšmių poras, kur raktai yra kolekcijos elementai. Reikšmė
yra arba perduotas numatytasis arba grąžinamas bloke.

```ruby
post = Post.new(title: "hey there", body: "what's up?")

%i( title body ).index_with { |attr_name| post.public_send(attr_name) }
# => { title: "hey there", body: "what's up?" }

WEEKDAYS.index_with(Interval.all_day)
# => { monday: [ 0, 1440 ], … }
```

PASTABA: Apibrėžta `active_support/core_ext/enumerable.rb`.


### `many?`

Metodas [`many?`][Enumerable#many?] yra trumpinys `collection.size > 1`:

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

Jeigu yra pateiktas pasirinktinis blokas, `many?` atsižvelgia tik į tuos elementus, kurie grąžina `true`:

```ruby
@see_more = videos.many? { |video| video.category == params[:category] }
```

PASTABA: Apibrėžta `active_support/core_ext/enumerable.rb`.


### `exclude?`

Predikatas [`exclude?`][Enumerable#exclude?] patikrina, ar duotas objektas **ne** priklauso kolekcijai. Tai yra įprasto `include?` neigimas:

```ruby
to_visit << node if visited.exclude?(node)
```

PASTABA: Apibrėžta `active_support/core_ext/enumerable.rb`.


### `including`

Metodas [`including`][Enumerable#including] grąžina naują kolekciją, kuri įtraukia perduotus elementus:

```ruby
[ 1, 2, 3 ].including(4, 5)                    # => [ 1, 2, 3, 4, 5 ]
["David", "Rafael"].including %w[ Aaron Todd ] # => ["David", "Rafael", "Aaron", "Todd"]
```

PASTABA: Apibrėžta `active_support/core_ext/enumerable.rb`.


### `excluding`

Metodas [`excluding`][Enumerable#excluding] grąžina kopiją kolekcijos su pašalintais nurodytais elementais:

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
```

`excluding` yra sinonimas [`without`][Enumerable#without].

PASTABA: Apibrėžta `active_support/core_ext/enumerable.rb`.


### `pluck`

Metodas [`pluck`][Enumerable#pluck] išskiria nurodytą raktą iš kiekvieno elemento:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pluck(:id, :name) # => [[1, "David"], [2, "Rafael"]]
```

PASTABA: Apibrėžta `active_support/core_ext/enumerable.rb`.


### `pick`

Metodas [`pick`][Enumerable#pick] ištraukia nurodytą raktą iš pirmojo elemento:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pick(:name) # => "David"
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pick(:id, :name) # => [1, "David"]
```

PASTABA: Apibrėžta `active_support/core_ext/enumerable.rb`.


Plėtiniai `Array`
---------------------

### Prieiga

Active Support papildo masyvų API, kad būtų lengviau pasiekti tam tikrus jų elementus. Pavyzdžiui, [`to`][Array#to] grąžina submasyvą, kuris apima elementus iki nurodyto indekso:

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

Panašiai, [`from`][Array#from] grąžina užpakalį nuo nurodyto indekso iki galo. Jei indeksas yra didesnis nei masyvo ilgis, grąžinamas tuščias masyvas.

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

Metodas [`including`][Array#including] grąžina naują masyvą, kuriame yra nurodyti elementai:

```ruby
[ 1, 2, 3 ].including(4, 5)          # => [ 1, 2, 3, 4, 5 ]
[ [ 0, 1 ] ].including([ [ 1, 0 ] ]) # => [ [ 0, 1 ], [ 1, 0 ] ]
```

Metodas [`excluding`][Array#excluding] grąžina kopiją masyvo, išskyrus nurodytus elementus.
Tai yra `Enumerable#excluding` optimizacija, kuri naudoja `Array#-`
vietoje `Array#reject` dėl našumo priežasčių.

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
[ [ 0, 1 ], [ 1, 0 ] ].excluding([ [ 1, 0 ] ])                  # => [ [ 0, 1 ] ]
```

Metodai [`second`][Array#second], [`third`][Array#third], [`fourth`][Array#fourth] ir [`fifth`][Array#fifth] grąžina atitinkamą elementą, taip pat [`second_to_last`][Array#second_to_last] ir [`third_to_last`][Array#third_to_last] (`first` ir `last` yra įdiegti). Dėka socialinio išmintingumo ir teigiamo konstruktyvumo visur, [`forty_two`][Array#forty_two] taip pat yra prieinamas.

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

PASTABA: Apibrėžta `active_support/core_ext/array/access.rb`.


### Ištraukimas

Metodas [`extract!`][Array#extract!] pašalina ir grąžina elementus, kuriems blokas grąžina teisingą reikšmę.
Jei nėra nurodytas blokas, grąžinamas vietoj to yra Enumeratorius.

```ruby
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
numbers # => [0, 2, 4, 6, 8]
```

PASTABA: Apibrėžta `active_support/core_ext/array/extract.rb`.


### Parinkčių ištraukimas

Kai paskutinis argumentas metodo iškvietime yra hash'as, išskyrus galbūt `&block` argumentą, Ruby leidžia jums praleisti skliaustus:

```ruby
User.exists?(email: params[:email])
```

Toks sintaksinis cukrus dažnai naudojamas Rails'e, kad būtų išvengta pozicinių argumentų, kai jų būtų per daug, o vietoj to siūlomi sąsajos, kurios imituoja vardinius parametrus. Ypač idiomatiška yra naudoti užbaigtinį hash'ą parinktims.

Jei metodas tikisi kintamo skaičiaus argumentų ir jo deklaracijoje naudoja `*`, tokiame parinkčių hash'as tampa argumentų masyvo elementu, kur jis praranda savo vaidmenį.

Tokiu atveju galite suteikti parinkčių hash'ui išskirtinį apdorojimą naudodami [`extract_options!`][Array#extract_options!]. Šis metodas patikrina masyvo paskutinio elemento tipą. Jei tai yra hash'as, jis išimamas ir grąžinamas, kitu atveju grąžinamas tuščias hash'as.
Pavyzdžiui, pažvelkime į `caches_action` valdiklio makro apibrėžimą:

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  # ...
end
```

Šis metodas priima bet kokį veiksmo pavadinimų skaičių ir pasirinktiną raktų hash'ą kaip paskutinį argumentą. Iškvietus `extract_options!` gaunate raktų hash'ą ir pašalinamas iš `actions` paprastu ir aiškiu būdu.

PASTABA: Apibrėžta `active_support/core_ext/array/extract_options.rb`.


### Konvertavimai

#### `to_sentence`

Metodas [`to_sentence`][Array#to_sentence] paverčia masyvą į eilutę, kurioje išvardijami jo elementai:

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

Šis metodas priima tris pasirinktinius parametrus:

* `:two_words_connector`: Naudojama masyvams, turintiems 2 elementus. Numatytasis yra " and ".
* `:words_connector`: Naudojama sujungti masyvo elementus, turinčius 3 ar daugiau elementų, išskyrus paskutinius du. Numatytasis yra ", ".
* `:last_word_connector`: Naudojama sujungti paskutinius masyvo elementus, turinčius 3 ar daugiau elementų. Numatytasis yra ", and ".

Šių parametrų numatytieji nustatymai gali būti lokalizuoti, jų raktai yra:

| Parametras                  | I18n raktas                                |
| --------------------------- | ------------------------------------------ |
| `:two_words_connector`      | `support.array.two_words_connector`        |
| `:words_connector`          | `support.array.words_connector`            |
| `:last_word_connector`      | `support.array.last_word_connector`        |

PASTABA: Apibrėžta `active_support/core_ext/array/conversions.rb`.


#### `to_fs`

Metodas [`to_fs`][Array#to_fs] pagal numatytuosius nustatymus veikia kaip `to_s`.

Tačiau, jei masyvas turi elementus, kurie gali atsakyti į `id`, simbolis
`:db` gali būti perduotas kaip argumentas. Tai dažnai naudojama su
Active Record objektų kolekcijomis. Grąžinamos eilutės yra:

```ruby
[].to_fs(:db)            # => "null"
[user].to_fs(:db)        # => "8456"
invoice.lines.to_fs(:db) # => "23,567,556,12"
```

Pavyzdžio aukščiau esantys sveikieji skaičiai turėtų būti gauti iš atitinkamų `id` iškvietimų.

PASTABA: Apibrėžta `active_support/core_ext/array/conversions.rb`.


#### `to_xml`

Metodas [`to_xml`][Array#to_xml] grąžina eilutę, kuri yra jo gavėjo XML atvaizdavimas:

```ruby
Contributor.limit(2).order(:rank).to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors type="array">
#   <contributor>
#     <id type="integer">4356</id>
#     <name>Jeremy Kemper</name>
#     <rank type="integer">1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id type="integer">4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank type="integer">2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

Tam jis išsiunčia `to_xml` kiekvienam elementui iš eilės ir surinkia rezultatus po šakniniu mazgu. Visi elementai turi atsakyti į `to_xml`, kitu atveju iškeliama išimtis.

Numatytasis šakninio elemento pavadinimas yra pirmojo elemento klasės pavadinimo su pabraukimu ir brūkšneliu daugiskaita, jei likusieji elementai priklauso tam pačiam tipui (patikrinama su `is_a?`) ir jie nėra hash'ai. Pavyzdyje aukščiau tai yra "contributors".

Jei yra bent vienas elementas, kuris nepriklauso pirmojo elemento tipui, šakninis mazgas tampa "objects":

```ruby
[Contributor.first, Commit.first].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <id type="integer">4583</id>
#     <name>Aaron Batalion</name>
#     <rank type="integer">53</rank>
#     <url-id>aaron-batalion</url-id>
#   </object>
#   <object>
#     <author>Joshua Peek</author>
#     <authored-timestamp type="datetime">2009-09-02T16:44:36Z</authored-timestamp>
#     <branch>origin/master</branch>
#     <committed-timestamp type="datetime">2009-09-02T16:44:36Z</committed-timestamp>
#     <committer>Joshua Peek</committer>
#     <git-show nil="true"></git-show>
#     <id type="integer">190316</id>
#     <imported-from-svn type="boolean">false</imported-from-svn>
#     <message>Kill AMo observing wrap_with_notifications since ARes was only using it</message>
#     <sha1>723a47bfb3708f968821bc969a9a3fc873a3ed58</sha1>
#   </object>
# </objects>
```
Jei gavėjas yra maišų masyvas, pagrindinis elementas pagal numatytuosius nustatymus taip pat yra "objects":

```ruby
[{ a: 1, b: 2 }, { c: 3 }].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <b type="integer">2</b>
#     <a type="integer">1</a>
#   </object>
#   <object>
#     <c type="integer">3</c>
#   </object>
# </objects>
```

ĮSPĖJIMAS. Jei kolekcija yra tuščia, pagal numatytuosius nustatymus pagrindinis elementas yra "nil-classes". Tai yra gudrybė, pavyzdžiui, aukščiau pateikto kontributorių sąrašo pagrindinis elementas nebūtų "contributors", jei kolekcija būtų tuščia, bet "nil-classes". Galite naudoti `:root` parinktį, kad būtų užtikrintas nuoseklus pagrindinis elementas.

Vaikų mazgų pavadinimas pagal numatytuosius nustatymus yra pagrindinio mazgo pavadinimas vienaskaita. Aukščiau pateiktuose pavyzdžiuose matėme "contributor" ir "object". `:children` parinktis leidžia nustatyti šiuos mazgų pavadinimus.

Numatytasis XML kūrėjas yra naujas `Builder::XmlMarkup` egzempliorius. Galite konfigūruoti savo kūrėją per `:builder` parinktį. Metodas taip pat priima parinktis, pvz., `:dasherize` ir kt., kurios perduodamos kūrėjui:

```ruby
Contributor.limit(2).order(:rank).to_xml(skip_types: true)
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors>
#   <contributor>
#     <id>4356</id>
#     <name>Jeremy Kemper</name>
#     <rank>1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id>4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank>2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

PASTABA: Apibrėžta `active_support/core_ext/array/conversions.rb`.


### Apvyniojimas

Metodas [`Array.wrap`][Array.wrap] apvynioja savo argumentą į masyvą, nebent jis jau yra masyvas (arba panašus į masyvą).

Konkrečiai:

* Jei argumentas yra `nil`, grąžinamas tuščias masyvas.
* Kitu atveju, jei argumentas gali būti iššauktas `to_ary`, jis iššaukiamas, ir jei `to_ary` grąžinimo reikšmė nėra `nil`, ji grąžinama.
* Kitu atveju, grąžinamas masyvas su argumentu kaip vieninteliu elementu.

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

Šis metodas panašus į `Kernel#Array` tikslais, tačiau yra kai kurie skirtumai:

* Jei argumentas gali būti iššauktas `to_ary`, metodas yra iššaukiamas. `Kernel#Array` tęsia bandymą iššaukti `to_a`, jei grąžinta reikšmė yra `nil`, bet `Array.wrap` iš karto grąžina masyvą su argumentu kaip vieninteliu elementu.
* Jei grąžinta reikšmė iš `to_ary` nėra nei `nil`, nei `Array` objektas, `Kernel#Array` iškelia išimtį, o `Array.wrap` to nedaro, ji tiesiog grąžina reikšmę.
* Jei argumentas neatsako į `to_ary`, ji nekviečia `to_a` ir grąžina masyvą su argumentu kaip vieninteliu elementu.

Ypač verta palyginti paskutinį punktą kai kuriems išvardijimams:

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

Taip pat yra susijusi idiomatika, kuri naudoja splat operatorių:

```ruby
[*object]
```

PASTABA: Apibrėžta `active_support/core_ext/array/wrap.rb`.


### Kopijavimas

Metodas [`Array#deep_dup`][Array#deep_dup] dubliuoja save ir visus objektus viduje
rekursyviai su Active Support metodu `Object#deep_dup`. Tai veikia kaip `Array#map`, siunčiant `deep_dup` metodą kiekvienam objektui viduje.

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

PASTABA: Apibrėžta `active_support/core_ext/object/deep_dup.rb`.
### Grupavimas

#### `in_groups_of(skaičius, užpildyti = nil)`

Metodas [`in_groups_of`][Array#in_groups_of] padalina masyvą į nuoseklius grupes, kurių dydis yra nurodytas. Jis grąžina masyvą su grupėmis:

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

arba perduoda jas vieną po kito, jei perduodamas blokas:

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

Pirmas pavyzdys parodo, kaip `in_groups_of` užpildo paskutinę grupę tiek `nil` elementais, kiek reikia, kad būtų pasiektas pageidaujamas dydis. Galite pakeisti šį užpildymo reikšmę naudodami antrąjį pasirinktinį argumentą:

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

Ir galite pasakyti metodui, kad paskutinė grupė neturi būti užpildyta, perduodant `false`:

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

Dėl to `false` negali būti naudojama kaip užpildymo reikšmė.

PASTABA: Apibrėžta `active_support/core_ext/array/grouping.rb`.


#### `in_groups(skaičius, užpildyti = nil)`

Metodas [`in_groups`][Array#in_groups] padalina masyvą į tam tikrą grupių skaičių. Metodas grąžina masyvą su grupėmis:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

arba perduoda jas vieną po kito, jei perduodamas blokas:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) { |group| p group }
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

Aukščiau pateikti pavyzdžiai rodo, kad `in_groups` užpildo kai kurias grupes papildomu `nil` elementu, jei reikia. Grupė gali gauti ne daugiau kaip vieną šio papildomo elemento, jei toks yra. Ir grupės, kuriose jie yra, visada yra paskutinės.

Galite pakeisti šią užpildymo reikšmę naudodami antrąjį pasirinktinį argumentą:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

Ir galite pasakyti metodui, kad mažesnės grupės neturi būti užpildytos, perduodant `false`:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

Dėl to `false` negali būti naudojama kaip užpildymo reikšmė.

PASTABA: Apibrėžta `active_support/core_ext/array/grouping.rb`.


#### `split(reikšmė = nil)`

Metodas [`split`][Array#split] padalina masyvą pagal skyriklį ir grąžina rezultatą.

Jei perduodamas blokas, skyrikliai yra tie masyvo elementai, kuriems blokas grąžina `true`:

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

Kitu atveju, argumentas, kuris pagal nutylėjimą yra `nil`, yra skyriklis:

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

PATARIMAS: Pastebėkite ankstesniame pavyzdyje, kad iš eilės esantys skyrikliai rezultuoja tuščius masyvus.

PASTABA: Apibrėžta `active_support/core_ext/array/grouping.rb`.


Plėtiniai `Hash` tipo objektui
--------------------

### Konversijos

#### `to_xml`

Metodas [`to_xml`][Hash#to_xml] grąžina eilutę, kurią sudaro jo gavėjo XML reprezentacija:

```ruby
{ foo: 1, bar: 2 }.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```
Tam, kad tai padarytumėte, metodas kartojasi per poras ir sukuria priklausomas nuo _reikšmių_ mazgas. Turint porą `key`, `value`:

* Jei `value` yra hash, vykdomas rekursinis kvietimas su `key` kaip `:root`.

* Jei `value` yra masyvas, vykdomas rekursinis kvietimas su `key` kaip `:root`, ir `key` vienaskaitinė forma kaip `:children`.

* Jei `value` yra kviečiamas objektas, jis turi tikėtis vieno ar dviejų argumentų. Priklausomai nuo argumentų skaičiaus, kviečiamas objektas yra iškviečiamas su `options` hash kaip pirmu argumentu su `key` kaip `:root`, ir `key` vienaskaitinė forma kaip antru argumentu. Jo grąžinimo reikšmė tampa nauju mazgu.

* Jei `value` atsako į `to_xml`, kviečiamas metodas su `key` kaip `:root`.

* Kitu atveju, sukuriamas mazgas su `key` kaip žyma ir `value` teksto mazgu kaip jo teksto reprezentacija. Jei `value` yra `nil`, pridedamas atributas "nil" su reikšme "true". Jei neegzistuoja `:skip_types` parinktis ir ji yra true, taip pat pridedamas atributas "type" pagal šią sąrašą:

```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "symbol",
  "Integer"    => "integer",
  "BigDecimal" => "decimal",
  "Float"      => "float",
  "TrueClass"  => "boolean",
  "FalseClass" => "boolean",
  "Date"       => "date",
  "DateTime"   => "datetime",
  "Time"       => "datetime"
}
```

Pagal numatytuosius nustatymus šakninis mazgas yra "hash", bet tai galima konfigūruoti naudojant `:root` parinktį.

Numatytasis XML kūrėjas yra naujas `Builder::XmlMarkup` objekto egzempliorius. Galite konfigūruoti savo kūrėją naudojant `:builder` parinktį. Metodas taip pat priima parinktis, pvz., `:dasherize` ir kt., kurios perduodamos kūrėjui.

PASTABA: Apibrėžta `active_support/core_ext/hash/conversions.rb` faile.


### Sujungimas

Ruby turi įmontuotą `Hash#merge` metodą, kuris sujungia du hash'us:

```ruby
{ a: 1, b: 1 }.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support apibrėžia keletą papildomų būdų, kaip sujungti hash'us, kas gali būti patogu.

#### `reverse_merge` ir `reverse_merge!`

Atveju, kai įvyksta susidūrimas, `merge` metode laimi argumento hash'o raktas. Galite palaikyti parinkčių hash'us su numatytosiomis reikšmėmis kompaktiškai naudodami šią idiomą:

```ruby
options = { length: 30, omission: "..." }.merge(options)
```

Active Support apibrėžia [`reverse_merge`][Hash#reverse_merge] atveju, jei pageidaujate šios alternatyvios sintaksės:

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

Taip pat yra bang versija [`reverse_merge!`][Hash#reverse_merge!], kuri atlieka sujungimą vietoje:

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

ĮSPĖJIMAS. Atkreipkite dėmesį, kad `reverse_merge!` gali pakeisti hash'ą iškvietėjoje, kas gali būti gera arba ne.

PASTABA: Apibrėžta `active_support/core_ext/hash/reverse_merge.rb` faile.


#### `reverse_update`

Metodas [`reverse_update`][Hash#reverse_update] yra sinonimas `reverse_merge!`, kuris buvo paaiškintas aukščiau.

ĮSPĖJIMAS. Atkreipkite dėmesį, kad `reverse_update` neturi bang simbolio.

PASTABA: Apibrėžta `active_support/core_ext/hash/reverse_merge.rb` faile.


#### `deep_merge` ir `deep_merge!`

Kaip matote ankstesniame pavyzdyje, jei raktas yra rastas abiejuose hash'uose, reikšmė iš argumento hash'o laimi.

Active Support apibrėžia [`Hash#deep_merge`][Hash#deep_merge]. Gilyn sujungiant, jei raktas yra rastas abiejuose hash'uose ir jų reikšmės yra vėl hash'ai, tada jų sujungimas tampa rezultuojančio hash'o reikšme:

```ruby
{ a: { b: 1 } }.deep_merge(a: { c: 2 })
# => {:a=>{:b=>1, :c=>2}}
```
Metodas `deep_merge!` atlieka gilų sujungimą vietoje.

PASTABA: Apibrėžta `active_support/core_ext/hash/deep_merge.rb`.


### Gilus kopijavimas

Metodas `Hash#deep_dup` dubliuoja save ir visus raktus bei reikšmes
rekursyviai naudojant Active Support metodo `Object#deep_dup`. Jis veikia kaip `Enumerator#each_with_object`, siunčiant `deep_dup` metodą kiekvienam porai viduje.

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

PASTABA: Apibrėžta `active_support/core_ext/object/deep_dup.rb`.


### Darbas su raktų

#### `except` ir `except!`

Metodas `except` grąžina raktus, esančius argumentų sąraše, pašalintus iš hash, jei jie yra:

```ruby
{ a: 1, b: 2 }.except(:a) # => {:b=>2}
```

Jei gavėjas atsako į `convert_key`, metodas yra iškviestas kiekvienam iš argumentų. Tai leidžia `except` gerai veikti su hash, kuris turi abejotiną prieigą, pavyzdžiui:

```ruby
{ a: 1 }.with_indifferent_access.except(:a)  # => {}
{ a: 1 }.with_indifferent_access.except("a") # => {}
```

Taip pat yra bang variantas `except!`, kuris pašalina raktus vietoje.

PASTABA: Apibrėžta `active_support/core_ext/hash/except.rb`.


#### `stringify_keys` ir `stringify_keys!`

Metodas `stringify_keys` grąžina hash, kuriame yra raktų, esančių gavėjui, sustringifikuota versija. Tai daroma siunčiant jiems `to_s`:

```ruby
{ nil => nil, 1 => 1, a: :a }.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

Atveju, kai yra raktų susidūrimas, reikšmė bus naujausia įterpta į hash:

```ruby
{ "a" => 1, a: 2 }.stringify_keys
# Rezultatas bus
# => {"a"=>2}
```

Šis metodas gali būti naudingas, pavyzdžiui, lengvai priimti tiek simbolius, tiek eilutes kaip parinktis. Pavyzdžiui, `ActionView::Helpers::FormHelper` apibrėžia:

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  # ...
end
```

Antra eilutė saugiai gali pasiekti "type" raktą ir leisti vartotojui perduoti `:type` arba "type".

Taip pat yra bang variantas `stringify_keys!`, kuris vietoje sustringifikuoti raktus.

Be to, galima naudoti `deep_stringify_keys` ir `deep_stringify_keys!`, kad sustringifikuotumėte visus raktus duotame hashe ir visuose jame įdėtuose hashuose. Pavyzdys rezultato yra:

```ruby
{ nil => nil, 1 => 1, nested: { a: 3, 5 => 5 } }.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

PASTABA: Apibrėžta `active_support/core_ext/hash/keys.rb`.


#### `symbolize_keys` ir `symbolize_keys!`

Metodas `symbolize_keys` grąžina hash, kuriame yra simbolizuota raktų versija gavėjui, kai tai įmanoma. Tai daroma siunčiant jiems `to_sym`:

```ruby
{ nil => nil, 1 => 1, "a" => "a" }.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

ĮSPĖJIMAS. Pastaba, kad ankstesniame pavyzdyje buvo simbolizuotas tik vienas raktas.

Atveju, kai yra raktų susidūrimas, reikšmė bus naujausia įterpta į hash:

```ruby
{ "a" => 1, a: 2 }.symbolize_keys
# => {:a=>2}
```

Šis metodas gali būti naudingas, pavyzdžiui, lengvai priimti tiek simbolius, tiek eilutes kaip parinktis. Pavyzdžiui, `ActionText::TagHelper` apibrėžia
```ruby
def rich_text_area_tag(name, value = nil, options = {})
  options = options.symbolize_keys

  options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
  # ...
end
```

Trečioji eilutė saugiai gali pasiekti `:input` raktą ir leisti vartotojui perduoti tiek `:input`, tiek "input".

Taip pat yra bang variantas [`symbolize_keys!`][Hash#symbolize_keys!], kuris simbolizuoja raktus vietoje.

Be to, galima naudoti [`deep_symbolize_keys`][Hash#deep_symbolize_keys] ir [`deep_symbolize_keys!`][Hash#deep_symbolize_keys!], kad simbolizuotumėte visus raktus duotame haeše ir visuose jame įdėtuose haešuose. Pavyzdys rezultato yra:

```ruby
{ nil => nil, 1 => 1, "nested" => { "a" => 3, 5 => 5 } }.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

PASTABA: Apibrėžta `active_support/core_ext/hash/keys.rb`.


#### `to_options` ir `to_options!`

Metodai [`to_options`][Hash#to_options] ir [`to_options!`][Hash#to_options!] yra `symbolize_keys` ir `symbolize_keys!` sinonimai, atitinkamai.

PASTABA: Apibrėžta `active_support/core_ext/hash/keys.rb`.


#### `assert_valid_keys`

Metodas [`assert_valid_keys`][Hash#assert_valid_keys] priima bet kokį skaičių argumentų ir patikrina, ar gavėjas neturi jokių raktų, kurie nėra išvardyti. Jei taip, išmetamas `ArgumentError`.

```ruby
{ a: 1 }.assert_valid_keys(:a)  # praeina
{ a: 1 }.assert_valid_keys("a") # ArgumentError
```

Active Record nepriima nežinomų parinkčių, kuriant asociacijas, pavyzdžiui. Jis įgyvendina šią kontrolę naudodamas `assert_valid_keys`.

PASTABA: Apibrėžta `active_support/core_ext/hash/keys.rb`.


### Darbas su reikšmėmis

#### `deep_transform_values` ir `deep_transform_values!`

Metodas [`deep_transform_values`][Hash#deep_transform_values] grąžina naują haešą, kuriame visos reikšmės konvertuojamos naudojant bloko operaciją. Tai apima reikšmes iš pagrindinio haešo ir visų įdėtų haešų ir masyvų.

```ruby
hash = { person: { name: 'Rob', age: '28' } }

hash.deep_transform_values { |value| value.to_s.upcase }
# => {person: {name: "ROB", age: "28"}}
```

Taip pat yra bang variantas [`deep_transform_values!`][Hash#deep_transform_values!], kuris sunaikina visus reikšmes, naudodamas bloko operaciją.

PASTABA: Apibrėžta `active_support/core_ext/hash/deep_transform_values.rb`.


### Pjovimas

Metodas [`slice!`][Hash#slice!] pakeičia haešą tik su duotais raktais ir grąžina haešą, kuriame yra pašalinti raktų ir reikšmių poros.

```ruby
hash = { a: 1, b: 2 }
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

PASTABA: Apibrėžta `active_support/core_ext/hash/slice.rb`.


### Ištraukimas

Metodas [`extract!`][Hash#extract!] pašalina ir grąžina raktų ir reikšmių poras, atitinkančias duotus raktus.

```ruby
hash = { a: 1, b: 2 }
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

Metodas `extract!` grąžina tą pačią `Hash` klasės subklasę, kuri yra gavėjas.

```ruby
hash = { a: 1, b: 2 }.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

PASTABA: Apibrėžta `active_support/core_ext/hash/slice.rb`.


### Nesvarbus prieiga

Metodas [`with_indifferent_access`][Hash#with_indifferent_access] grąžina [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] iš savo gavėjo:

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

PASTABA: Apibrėžta `active_support/core_ext/hash/indifferent_access.rb`.


Plėtiniai `Regexp`
------------------

### `multiline?`

Metodas [`multiline?`][Regexp#multiline?] nurodo, ar reguliariam išraiškai yra nustatytas `/m` vėliavėlė, tai yra, ar taškas atitinka naujas eilutes.

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails naudoja šį metodą tik vienoje vietoje, taip pat maršrutizavimo kode. Daugeilinės reguliariosios išraiškos maršrutams yra draudžiamos, ir ši vėliavėlė palengvina šio apribojimo taikymą.

```ruby
def verify_regexp_requirements(requirements)
  # ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option is not allowed in routing requirements: #{requirement.inspect}"
  end
  # ...
end
```
PASTABA: Apibrėžta `active_support/core_ext/regexp.rb`.


Plėtiniai `Range`
---------------------

### `to_fs`

Active Support apibrėžia `Range#to_fs` kaip alternatyvą `to_s`, kuri supranta pasirinktinį formato argumentą. Šiuo metu palaikomas tik neprivalomas formatas `:db`:

```ruby
(Date.today..Date.tomorrow).to_fs
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_fs(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

Kaip pavyzdys iliustruoja, `:db` formatas generuoja `BETWEEN` SQL sąlygą. Tai naudojama Active Record, palaikant intervalo reikšmes sąlygose.

PASTABA: Apibrėžta `active_support/core_ext/range/conversions.rb`.

### `===` ir `include?`

Metodai `Range#===` ir `Range#include?` nurodo, ar tam tikra reikšmė patenka tarp duotų intervalo galų:

```ruby
(2..3).include?(Math::E) # => true
```

Active Support išplečia šiuos metodus, kad argumentas galėtų būti kitas intervalas. Tokiu atveju tikriname, ar argumento intervalo galai priklauso pačiam intervalui:

```ruby
(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false
(1..10) === (3..11) # => false
(1...9) === (3..9)  # => false

(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false
(1..10).include?(3..11) # => false
(1...9).include?(3..9)  # => false
```

PASTABA: Apibrėžta `active_support/core_ext/range/compare_range.rb`.

### `overlap?`

Metodas [`Range#overlap?`][Range#overlap?] nurodo, ar duotiems intervalams yra ne tuščias sankirta:

```ruby
(1..10).overlap?(7..11)  # => true
(1..10).overlap?(0..7)   # => true
(1..10).overlap?(11..27) # => false
```

PASTABA: Apibrėžta `active_support/core_ext/range/overlap.rb`.


Plėtiniai `Date`
--------------------

### Skaičiavimai

INFO: Šie skaičiavimo metodai turi ribines sąlygas 1582 m. spalio mėnesį, nes dienos nuo 5 iki 14 tiesiog neegzistuoja. Šiame vadove jų elgsenos aplink tas dienas nėra aprašyta dėl trumpumo, tačiau pakanka pasakyti, kad jie daro tai, ko tikėtumėte. Tai reiškia, kad `Date.new(1582, 10, 4).tomorrow` grąžina `Date.new(1582, 10, 15)` ir taip toliau. Norėdami sužinoti tikėtiną elgseną, patikrinkite `test/core_ext/date_ext_test.rb` Active Support testų rinkinyje.

#### `Date.current`

Active Support apibrėžia [`Date.current`][Date.current] kaip šiandienos datą dabarties laiko juostoje. Tai panašu į `Date.today`, tačiau jis gerbia vartotojo laiko juostą, jei ji nustatyta. Taip pat apibrėžia [`Date.yesterday`][Date.yesterday] ir [`Date.tomorrow`][Date.tomorrow], taip pat [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?], [`future?`][DateAndTime::Calculations#future?], [`on_weekday?`][DateAndTime::Calculations#on_weekday?] ir [`on_weekend?`][DateAndTime::Calculations#on_weekend?], visi jie yra susiję su `Date.current`.

Lyginant datas naudojant metodus, kurie gerbia vartotojo laiko juostą, įsitikinkite, kad naudojate `Date.current`, o ne `Date.today`. Yra atvejų, kai vartotojo laiko juosta gali būti ateityje, palyginti su sistemos laiko juosta, kurią pagal nutylėjimą naudoja `Date.today`. Tai reiškia, kad `Date.today` gali būti lygus `Date.yesterday`.

PASTABA: Apibrėžta `active_support/core_ext/date/calculations.rb`.


#### Pavadinimai datoms

##### `beginning_of_week`, `end_of_week`

Metodai [`beginning_of_week`][DateAndTime::Calculations#beginning_of_week] ir [`end_of_week`][DateAndTime::Calculations#end_of_week] grąžina savaitės pradžios ir pabaigos datą atitinkamai. Savaitės pradžia priklauso nuo pirmadienio, bet tai gali būti pakeista perduodant argumentą, nustatant gijos vietinį `Date.beginning_of_week` arba [`config.beginning_of_week`][].

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

`beginning_of_week` yra sinonimas [`at_beginning_of_week`][DateAndTime::Calculations#at_beginning_of_week] ir `end_of_week` yra sinonimas [`at_end_of_week`][DateAndTime::Calculations#at_end_of_week].

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb`.


##### `monday`, `sunday`

Metodai [`monday`][DateAndTime::Calculations#monday] ir [`sunday`][DateAndTime::Calculations#sunday] grąžina ankstesnį pirmadienį ir kitą sekmadienį atitinkamai.
```ruby
date = Date.new(2010, 6, 7)
date.months_ago(3)   # => Thu, 07 Mar 2010
date.months_since(3) # => Mon, 07 Sep 2010
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2012, 3, 31).months_ago(1)     # => Thu, 29 Feb 2012
Date.new(2012, 1, 31).months_since(1)   # => Wed, 29 Feb 2012
```

[`last_month`][DateAndTime::Calculations#last_month] is short-hand for `#months_ago(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.


##### `weeks_ago`, `weeks_since`

The methods [`weeks_ago`][DateAndTime::Calculations#weeks_ago] and [`weeks_since`][DateAndTime::Calculations#weeks_since] work analogously for weeks:

```ruby
date = Date.new(2010, 6, 7)
date.weeks_ago(2)   # => Mon, 24 May 2010
date.weeks_since(2) # => Mon, 21 Jun 2010
```

[`last_week`][DateAndTime::Calculations#last_week] is short-hand for `#weeks_ago(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.


##### `days_ago`, `days_since`

The methods [`days_ago`][DateAndTime::Calculations#days_ago] and [`days_since`][DateAndTime::Calculations#days_since] work analogously for days:

```ruby
date = Date.new(2010, 6, 7)
date.days_ago(5)   # => Wed, 02 Jun 2010
date.days_since(5) # => Sat, 12 Jun 2010
```

[`yesterday`][DateAndTime::Calculations#yesterday] is short-hand for `#days_ago(1)`, and [`tomorrow`][DateAndTime::Calculations#tomorrow] is short-hand for `#days_since(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.
```
```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sek, 28 Vas 2010
Date.new(2010, 4, 30).months_since(2) # => Tre, 30 Bir 2010
```

Jei tokios dienos nėra, grąžinamas atitinkamo mėnesio paskutinė diena:

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sek, 28 Vas 2010
Date.new(2009, 12, 31).months_since(2) # => Sek, 28 Vas 2010
```

[`last_month`][DateAndTime::Calculations#last_month] yra trumpinys `#months_ago(1)`.

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb`.


##### `weeks_ago`

Metodas [`weeks_ago`][DateAndTime::Calculations#weeks_ago] veikia analogiškai savaitėms:

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Pirm, 17 Geg 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Pirm, 10 Geg 2010
```

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb`.


##### `advance`

Bendriausias būdas pereiti prie kitų dienų yra [`advance`][Date#advance]. Šis metodas priima maišą su raktiniais žodžiais `:years`, `:months`, `:weeks`, `:days`, ir grąžina datą, kuri yra tiek pat priekyje, kiek nurodyti raktiniai žodžiai:

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Pirm, 20 Bir 2011
date.advance(months: 2, days: -2) # => Tre, 04 Rgp 2010
```

Pastaba, kad padidinimai gali būti neigiami.

PASTABA: Apibrėžta `active_support/core_ext/date/calculations.rb`.


#### Komponentų keitimas

Metodas [`change`][Date#change] leidžia gauti naują datą, kuri yra tokia pati kaip gavėjas, išskyrus nurodytus metus, mėnesį ar dieną:

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Tre, 23 Lap 2011
```

Šis metodas netoleruoja neegzistuojančių datų, jei keitimas yra netinkamas, išmetamas `ArgumentError`:

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: negaliojanti data
```

PASTABA: Apibrėžta `active_support/core_ext/date/calculations.rb`.


#### Trukmės

Prie datų galima pridėti arba iš jų atimti [`Duration`][ActiveSupport::Duration] objektus:

```ruby
d = Date.current
# => Pirm, 09 Rgp 2010
d + 1.year
# => Antr, 09 Rgp 2011
d - 3.hours
# => Sek, 08 Rgp 2010 21:00:00 UTC +00:00
```

Jie verčiami į kvietimus `since` arba `advance`. Pavyzdžiui, čia gauname teisingą peršokimą kalendoriaus reformoje:

```ruby
Date.new(1582, 10, 4) + 1.day
# => Pen, 15 Spa 1582
```


#### Laiko žymos

INFO: Jei įmanoma, šie metodai grąžina `Time` objektą, kitu atveju - `DateTime`. Jei nustatyta, jie gerbia vartotojo laiko juostą.

##### `beginning_of_day`, `end_of_day`

Metodas [`beginning_of_day`][Date#beginning_of_day] grąžina laiko žymą dienos pradžioje (00:00:00):

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Pirm Jun 07 00:00:00 +0200 2010
```

Metodas [`end_of_day`][Date#end_of_day] grąžina laiko žymą dienos pabaigoje (23:59:59):

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Pirm Jun 07 23:59:59 +0200 2010
```

`beginning_of_day` yra sinonimas [`at_beginning_of_day`][Date#at_beginning_of_day], [`midnight`][Date#midnight], [`at_midnight`][Date#at_midnight].

PASTABA: Apibrėžta `active_support/core_ext/date/calculations.rb`.


##### `beginning_of_hour`, `end_of_hour`

Metodas [`beginning_of_hour`][DateTime#beginning_of_hour] grąžina laiko žymą valandos pradžioje (hh:00:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Pirm Jun 07 19:00:00 +0200 2010
```

Metodas [`end_of_hour`][DateTime#end_of_hour] grąžina laiko žymą valandos pabaigoje (hh:59:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Pirm Jun 07 19:59:59 +0200 2010
```

`beginning_of_hour` yra sinonimas [`at_beginning_of_hour`][DateTime#at_beginning_of_hour].

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.

##### `beginning_of_minute`, `end_of_minute`

Metodas [`beginning_of_minute`][DateTime#beginning_of_minute] grąžina laiko žymą minutės pradžioje (hh:mm:00):
```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Pirmadienis, birželio 07 19:55:00 +0200 2010
```

Metodas [`end_of_minute`][DateTime#end_of_minute] grąžina laiko žymą minutės pabaigoje (hh:mm:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Pirmadienis, birželio 07 19:55:59 +0200 2010
```

`beginning_of_minute` yra sinonimas [`at_beginning_of_minute`][DateTime#at_beginning_of_minute].

INFO: `beginning_of_hour`, `end_of_hour`, `beginning_of_minute` ir `end_of_minute` yra įgyvendinti `Time` ir `DateTime`, bet **ne** `Date`, nes neturi prasmės prašyti valandos ar minutės pradžios ar pabaigos `Date` egzemplioriuje.

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


##### `ago`, `since`

Metodas [`ago`][Date#ago] priima sekundžių skaičių kaip argumentą ir grąžina laiko žymą tiek sekundžių atgal nuo vidurnakčio:

```ruby
date = Date.current # => Penktadienis, birželio 11 2010
date.ago(1)         # => Ketvirtadienis, birželio 10 2010 23:59:59 EDT -04:00
```

Panašiai, [`since`][Date#since] juda į priekį:

```ruby
date = Date.current # => Penktadienis, birželio 11 2010
date.since(1)       # => Penktadienis, birželio 11 2010 00:00:01 EDT -04:00
```

PASTABA: Apibrėžta `active_support/core_ext/date/calculations.rb`.


Plėtiniai `DateTime`
------------------------

ĮSPĖJIMAS: `DateTime` nežino DST taisyklių, todėl kai kurie iš šių metodų turi ribinius atvejus, kai vyksta DST keitimas. Pavyzdžiui, [`seconds_since_midnight`][DateTime#seconds_since_midnight] gali negrąžinti tikro kiekio tokiame dieną.

### Skaičiavimai

Klasė `DateTime` yra `Date` po-klasė, todėl įkelus `active_support/core_ext/date/calculations.rb` paveldite šiuos metodus ir jų sinonimus, išskyrus tai, kad jie visada grąžins datetimes.

Šie metodai yra įgyvendinti, todėl **nereikia** įkelti `active_support/core_ext/date/calculations.rb` šiems:

* [`beginning_of_day`][DateTime#beginning_of_day] / [`midnight`][DateTime#midnight] / [`at_midnight`][DateTime#at_midnight] / [`at_beginning_of_day`][DateTime#at_beginning_of_day]
* [`end_of_day`][DateTime#end_of_day]
* [`ago`][DateTime#ago]
* [`since`][DateTime#since] / [`in`][DateTime#in]

Kita vertus, [`advance`][DateTime#advance] ir [`change`][DateTime#change] taip pat yra apibrėžti ir palaiko daugiau parinkčių, jie yra aprašyti žemiau.

Šie metodai yra įgyvendinti tik `active_support/core_ext/date_time/calculations.rb`, nes jie turi prasmę tik naudojant `DateTime` egzempliorių:

* [`beginning_of_hour`][DateTime#beginning_of_hour] / [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]
* [`end_of_hour`][DateTime#end_of_hour]


#### Pavadinimai laikui

##### `DateTime.current`

Active Support apibrėžia [`DateTime.current`][DateTime.current] būti kaip `Time.now.to_datetime`, išskyrus tai, kad jis gerbia vartotojo laiko juostą, jei apibrėžta. Egzemplioriaus predikatai [`past?`][DateAndTime::Calculations#past?] ir [`future?`][DateAndTime::Calculations#future?] yra apibrėžti atsižvelgiant į `DateTime.current`.

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


#### Kiti plėtiniai

##### `seconds_since_midnight`

Metodas [`seconds_since_midnight`][DateTime#seconds_since_midnight] grąžina sekundžių skaičių nuo vidurnakčio:

```ruby
now = DateTime.current     # => Pirmadienis, birželio 07 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


##### `utc`

Metodas [`utc`][DateTime#utc] suteikia jums tą patį datetime gavėjo išreikštą UTC laiku.

```ruby
now = DateTime.current # => Pirmadienis, birželio 07 2010 19:27:52 -0400
now.utc                # => Pirmadienis, birželio 07 2010 23:27:52 +0000
```

Šis metodas taip pat yra sinonimas [`getutc`][DateTime#getutc].

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


##### `utc?`

Predikatas [`utc?`][DateTime#utc?] sako, ar gavėjas turi UTC kaip laiko juostą:

```ruby
now = DateTime.now # => Pirmadienis, birželio 07 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


##### `advance`

Bendriausias būdas pereiti prie kito datetime yra [`advance`][DateTime#advance]. Šis metodas priima maišą su raktiniais žodžiais `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes` ir `:seconds`, ir grąžina datetime, pažengusį tiek, kiek dabartiniai raktai nurodo.
```ruby
d = DateTime.current
# => Ket, 05 Rugpjūtis 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => An, 06 Rugsėjis 2011 12:34:32 +0000
```

Ši metodas pirmiausia apskaičiuoja paskirties datą, perduodamas `:years`, `:months`, `:weeks` ir `:days` į `Date#advance`, kuris yra aprašytas aukščiau. Po to, jis sureguliuoja laiką, iškviesdamas [`since`][DateTime#since] su sekundžių skaičiumi, kurį reikia pridėti. Ši tvarka yra svarbi, kita tvarka duotų skirtingas datos ir laiko reikšmes kai kuriuose ribiniuose atvejuose. Pavyzdys `Date#advance` taikomas ir galime jį išplėsti, kad parodytume tvarkos svarbą, susijusią su laiko elementais.

Jei pirmiausia perkeltume datos elementus (kurie taip pat turi santykinę tvarką, kaip jau buvo aprašyta), o po to laiko elementus, gautume, pavyzdžiui, šią skaičiavimą:

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sek, 28 Vasaris 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Pir, 29 Kovas 2010 00:00:00 +0000
```

bet jei juos apskaičiuotume kitaip, rezultatas būtų skirtingas:

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Ket, 01 Balandis 2010 00:00:00 +0000
```

ĮSPĖJIMAS: Kadangi `DateTime` nėra DST informacijos turintis, galite patekti į neegzistuojančią laiko tašką be jokio įspėjimo ar klaidos pranešimo.

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


#### Komponentų keitimas

Metodas [`change`][DateTime#change] leidžia gauti naują datą ir laiką, kuris yra tas pats kaip ir pradinis, išskyrus duotus parametrus, kurie gali apimti `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start`:

```ruby
now = DateTime.current
# => An, 08 Birželis 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Tre, 08 Birželis 2011 01:56:22 -0600
```

Jei valandos yra nustatytos į nulį, tai taip pat taikoma minutėms ir sekundėms (jei jos neturi nustatytų reikšmių):

```ruby
now.change(hour: 0)
# => An, 08 Birželis 2010 00:00:00 +0000
```

Panašiai, jei minutės yra nustatytos į nulį, tai taip pat taikoma sekundėms (jei jos neturi nustatytos reikšmės):

```ruby
now.change(min: 0)
# => An, 08 Birželis 2010 01:00:00 +0000
```

Šis metodas netoleruoja neegzistuojančių datų, jei keitimas yra netinkamas, iškeliama `ArgumentError`:

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: negaliojanti data
```

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


#### Trukmės

[`Duration`][ActiveSupport::Duration] objektai gali būti pridėti arba atimti iš datų ir laikų:

```ruby
now = DateTime.current
# => Pir, 09 Rugpjūtis 2010 23:15:17 +0000
now + 1.year
# => An, 09 Rugpjūtis 2011 23:15:17 +0000
now - 1.week
# => Pir, 02 Rugpjūtis 2010 23:15:17 +0000
```

Jie verčiami į `since` arba `advance` iškvietimus. Pavyzdžiui, čia gauname teisingą perėjimą kalendoriaus reformoje:

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Pen, 15 Spalis 1582 00:00:00 +0000
```

`Time` plėtinių
--------------------

### Skaičiavimai

Jie yra analogiški. Prašome kreiptis į jų dokumentaciją aukščiau ir atkreipti dėmesį į šias skirtumus:

* [`change`][Time#change] priima papildomą `:usec` parametrą.
* `Time` supranta DST, todėl gaunate teisingus DST skaičiavimus, kaip šiuo atveju

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# Barselonoje, 2010/03/28 02:00 +0100 tampa 2010/03/28 03:00 +0200 dėl DST.
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Sek Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Sek Mar 28 03:00:00 +0200 2010
```
* Jei [`since`][Time#since] arba [`ago`][Time#ago] nukelia į laiką, kuris negali būti išreikštas su `Time`, grąžinamas `DateTime` objektas.

#### `Time.current`

Active Support apibrėžia [`Time.current`][Time.current] kaip šiandien esantį laiką dabartinėje laiko juostoje. Tai panašu į `Time.now`, tačiau tai gerbia vartotojo laiko juostą, jei ji yra apibrėžta. Taip pat apibrėžiami [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?] ir [`future?`][DateAndTime::Calculations#future?] metodai, visi jie susiję su `Time.current`.

Lyginant laiką naudojant metodus, kurie gerbia vartotojo laiko juostą, įsitikinkite, kad naudojate `Time.current` vietoje `Time.now`. Yra atvejų, kai vartotojo laiko juosta gali būti ateityje, palyginti su sistemos laiko juosta, kurią pagal nutylėjimą naudoja `Time.now`. Tai reiškia, kad `Time.now.to_date` gali būti lygus `Date.yesterday`.

PASTABA: Apibrėžta `active_support/core_ext/time/calculations.rb` faile.

#### `all_day`, `all_week`, `all_month`, `all_quarter` ir `all_year`

Metodas [`all_day`][DateAndTime::Calculations#all_day] grąžina intervalą, kuris atitinka visą šios dienos laiką.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

Analogiškai, [`all_week`][DateAndTime::Calculations#all_week], [`all_month`][DateAndTime::Calculations#all_month], [`all_quarter`][DateAndTime::Calculations#all_quarter] ir [`all_year`][DateAndTime::Calculations#all_year] visi turi tikslą generuoti laiko intervalus.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_week
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Sun, 15 Aug 2010 23:59:59 UTC +00:00
now.all_week(:sunday)
# => Sun, 16 Sep 2012 00:00:00 UTC +00:00..Sat, 22 Sep 2012 23:59:59 UTC +00:00
now.all_month
# => Sat, 01 Aug 2010 00:00:00 UTC +00:00..Tue, 31 Aug 2010 23:59:59 UTC +00:00
now.all_quarter
# => Thu, 01 Jul 2010 00:00:00 UTC +00:00..Thu, 30 Sep 2010 23:59:59 UTC +00:00
now.all_year
# => Fri, 01 Jan 2010 00:00:00 UTC +00:00..Fri, 31 Dec 2010 23:59:59 UTC +00:00
```

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb` faile.

#### `prev_day`, `next_day`

[`prev_day`][Time#prev_day] ir [`next_day`][Time#next_day] grąžina laiką prieš tai arba po to esančią dieną:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_day               # => 2010-05-07 00:00:00 +0900
t.next_day               # => 2010-05-09 00:00:00 +0900
```

PASTABA: Apibrėžta `active_support/core_ext/time/calculations.rb` faile.

#### `prev_month`, `next_month`

[`prev_month`][Time#prev_month] ir [`next_month`][Time#next_month] grąžina laiką su tuo pačiu dienos numeriu praėjusį arba ateinantį mėnesį:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_month             # => 2010-04-08 00:00:00 +0900
t.next_month             # => 2010-06-08 00:00:00 +0900
```

Jei tokios dienos nėra, grąžinamas atitinkamo mėnesio paskutinė diena:

```ruby
Time.new(2000, 5, 31).prev_month # => 2000-04-30 00:00:00 +0900
Time.new(2000, 3, 31).prev_month # => 2000-02-29 00:00:00 +0900
Time.new(2000, 5, 31).next_month # => 2000-06-30 00:00:00 +0900
Time.new(2000, 1, 31).next_month # => 2000-02-29 00:00:00 +0900
```

PASTABA: Apibrėžta `active_support/core_ext/time/calculations.rb` faile.

#### `prev_year`, `next_year`

[`prev_year`][Time#prev_year] ir [`next_year`][Time#next_year] grąžina laiką su tuo pačiu dienos/mėnesio numeriu praėjusiais arba ateinančiais metais:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_year              # => 2009-05-08 00:00:00 +0900
t.next_year              # => 2011-05-08 00:00:00 +0900
```

Jei data yra vasario 29 diena perkeliamaisiais metais, gaunate vasario 28 dieną:

```ruby
t = Time.new(2000, 2, 29) # => 2000-02-29 00:00:00 +0900
t.prev_year               # => 1999-02-28 00:00:00 +0900
t.next_year               # => 2001-02-28 00:00:00 +0900
```
PASTABA: Apibrėžta faile `active_support/core_ext/time/calculations.rb`.


#### `prev_quarter`, `next_quarter`

[`prev_quarter`][DateAndTime::Calculations#prev_quarter] ir [`next_quarter`][DateAndTime::Calculations#next_quarter] grąžina datą su tuo pačiu dienos numeriu ankstesniame arba kitame ketvirtyje:

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 +0300
t.prev_quarter             # => 2010-02-08 00:00:00 +0200
t.next_quarter             # => 2010-08-08 00:00:00 +0300
```

Jei tokios dienos nėra, grąžinamas atitinkamo mėnesio paskutinė diena:

```ruby
Time.local(2000, 7, 31).prev_quarter  # => 2000-04-30 00:00:00 +0300
Time.local(2000, 5, 31).prev_quarter  # => 2000-02-29 00:00:00 +0200
Time.local(2000, 10, 31).prev_quarter # => 2000-07-31 00:00:00 +0300
Time.local(2000, 11, 31).next_quarter # => 2001-03-01 00:00:00 +0200
```

`prev_quarter` yra sinonimas [`last_quarter`][DateAndTime::Calculations#last_quarter].

PASTABA: Apibrėžta faile `active_support/core_ext/date_and_time/calculations.rb`.


### Laiko konstruktorius

Active Support apibrėžia [`Time.current`][Time.current] kaip `Time.zone.now`, jei yra apibrėžta vartotojo laiko juosta, ir kaip `Time.now`, jei nėra:

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

Analogiškai `DateTime`, [`past?`][DateAndTime::Calculations#past?] ir [`future?`][DateAndTime::Calculations#future?] predikatai yra susiję su `Time.current`.

Jei konstruojamas laikas yra už ribų, kurias palaiko `Time` vykdymo platforma, mikrosekundės yra atmestos ir grąžinamas `DateTime` objektas.

#### Trukmės

Laikui galima pridėti ir iš jo atimti [`Duration`][ActiveSupport::Duration] objektus:

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
# => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

Jie verčiami į `since` arba `advance` kvietimus. Pavyzdžiui, čia gauname teisingą peršokimą kalendoriaus reformoje:

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

`File` plėtiniai
--------------------

### `atomic_write`

Naudojant klasės metodo [`File.atomic_write`][File.atomic_write] galima įrašyti į failą taip, kad joks skaitytojas nematytų pusiau įrašyto turinio.

Failo pavadinimas perduodamas kaip argumentas, o metodas grąžina failo rankeną, atidarytą rašymui. Baigus vykdyti bloką, `atomic_write` uždaro failo rankeną ir atlieka savo darbą.

Pavyzdžiui, Action Pack naudoja šį metodą, norėdama įrašyti turtų kašės failus, pvz., `all.css`:

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

Tam `atomic_write` sukuria laikiną failą. Tai yra failas, į kurį bloko kode iš tikrųjų rašoma. Baigus darbą, laikinas failas pervadinamas, kas POSIX sistemose yra atomiška operacija. Jei tikslinis failas egzistuoja, `atomic_write` jį perrašo ir išlaiko savininkus ir teises. Tačiau yra keletas atvejų, kai `atomic_write` negali pakeisti failo savininko ar teisių, ši klaida yra aptinkama ir praleidžiama, tikintis, kad vartotojas/operacinė sistema užtikrins, kad failas būtų pasiekiamas procesams, kurie jo reikia.

PASTABA. Dėl `atomic_write` atliekamo chmod veiksmo, jei tiksliniame faile yra nustatytas ACL, šis ACL bus perskaičiuotas/modifikuotas.

ĮSPĖJIMAS. Atkreipkite dėmesį, kad negalima pridėti su `atomic_write`.

Pagalbiniai failai rašomi į standartinį laikinų failų katalogą, bet galite perduoti jūsų pasirinktą katalogą kaip antrą argumentą.

PASTABA: Apibrėžta faile `active_support/core_ext/file/atomic.rb`.


`NameError` plėtiniai
-------------------------
Aktyvusis palaikymas prideda [`missing_name?`][NameError#missing_name?] prie `NameError`, kuris patikrina, ar išimtis buvo iškelta dėl pateikto vardo.

Vardas gali būti pateiktas kaip simbolis arba eilutė. Simbolis yra tikrinamas su grynuoju konstantos vardu, o eilutė - su visiškai kvalifikuotu konstantos vardu.

PATARIMAS: Simbolis gali reikšti visiškai kvalifikuotą konstantos vardą, pvz., `:"ActiveRecord::Base"`, todėl simboliams apibrėžtas elgesys yra patogumo sumetimais, o ne dėl techninių priežasčių.

Pavyzdžiui, kai veiksmas `ArticlesController` yra iškviestas, „Rails“ optimistiškai bando naudoti `ArticlesHelper`. Tai nesvarbu, kad pagalbinės modulio nėra, todėl jei išimtis dėl tos konstantos vardo yra iškelta, ji turėtų būti nutildyta. Tačiau gali būti atvejis, kad `articles_helper.rb` iškelia `NameError` dėl faktiškai nežinomos konstantos. Tai turėtų būti pakartotinai iškelta. Metodas `missing_name?` suteikia galimybę atskirti abu atvejus:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

PASTABA: Apibrėžta `active_support/core_ext/name_error.rb` faile.


Plėtiniai `LoadError`
-------------------------

Aktyvusis palaikymas prideda [`is_missing?`][LoadError#is_missing?] prie `LoadError`.

Duodamas kelio pavadinimas, `is_missing?` patikrina, ar išimtis buvo iškelta dėl to konkretaus failo (išskyrus galbūt ".rb" plėtinį).

Pavyzdžiui, kai veiksmas `ArticlesController` yra iškviestas, „Rails“ bando įkelti `articles_helper.rb`, bet to failo gali nebūti. Tai gerai, pagalbinis modulis nėra privalomas, todėl „Rails“ nutildyja įkėlimo klaidą. Tačiau gali būti atvejis, kad pagalbinis modulis egzistuoja ir savo ruožtu reikalauja kito trūkstamo bibliotekos. Tokiu atveju „Rails“ turi pakartotinai iškelti išimtį. Metodas `is_missing?` suteikia galimybę atskirti abu atvejus:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

PASTABA: Apibrėžta `active_support/core_ext/load_error.rb` faile.


Plėtiniai `Pathname`
-------------------------

### `existence`

[`existence`][Pathname#existence] metodas grąžina gavėją, jei nurodytas failas egzistuoja, kitu atveju grąžina `nil`. Tai naudinga idiomams, panašiems į šį:

```ruby
content = Pathname.new("file").existence&.read
```

PASTABA: Apibrėžta `active_support/core_ext/pathname/existence.rb` faile.
[`config.active_support.bare`]: configuring.html#config-active-support-bare
[Object#blank?]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[Object#present?]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[Object#presence]: https://api.rubyonrails.org/classes/Object.html#method-i-presence
[Object#duplicable?]: https://api.rubyonrails.org/classes/Object.html#method-i-duplicable-3F
[Object#deep_dup]: https://api.rubyonrails.org/classes/Object.html#method-i-deep_dup
[Object#try]: https://api.rubyonrails.org/classes/Object.html#method-i-try
[Object#try!]: https://api.rubyonrails.org/classes/Object.html#method-i-try-21
[Kernel#class_eval]: https://api.rubyonrails.org/classes/Kernel.html#method-i-class_eval
[Object#acts_like?]: https://api.rubyonrails.org/classes/Object.html#method-i-acts_like-3F
[Array#to_param]: https://api.rubyonrails.org/classes/Array.html#method-i-to_param
[Object#to_param]: https://api.rubyonrails.org/classes/Object.html#method-i-to_param
[Hash#to_query]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_query
[Object#to_query]: https://api.rubyonrails.org/classes/Object.html#method-i-to_query
[Object#with_options]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[Object#instance_values]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_values
[Object#instance_variable_names]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_variable_names
[Kernel#enable_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-enable_warnings
[Kernel#silence_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-silence_warnings
[Kernel#suppress]: https://api.rubyonrails.org/classes/Kernel.html#method-i-suppress
[Object#in?]: https://api.rubyonrails.org/classes/Object.html#method-i-in-3F
[Module#alias_attribute]: https://api.rubyonrails.org/classes/Module.html#method-i-alias_attribute
[Module#attr_internal]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal
[Module#attr_internal_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_accessor
[Module#attr_internal_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_reader
[Module#attr_internal_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_writer
[Module#mattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_accessor
[Module#mattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_reader
[Module#mattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_writer
[Module#module_parent]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent
[Module#module_parent_name]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent_name
[Module#module_parents]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parents
[Module#anonymous?]: https://api.rubyonrails.org/classes/Module.html#method-i-anonymous-3F
[Module#delegate]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate
[Module#delegate_missing_to]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate_missing_to
[Module#redefine_method]: https://api.rubyonrails.org/classes/Module.html#method-i-redefine_method
[Module#silence_redefinition_of_method]: https://api.rubyonrails.org/classes/Module.html#method-i-silence_redefinition_of_method
[Class#class_attribute]: https://api.rubyonrails.org/classes/Class.html#method-i-class_attribute
[Module#cattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_accessor
[Module#cattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_reader
[Module#cattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_writer
[Class#subclasses]: https://api.rubyonrails.org/classes/Class.html#method-i-subclasses
[Class#descendants]: https://api.rubyonrails.org/classes/Class.html#method-i-descendants
[`raw`]: https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-raw
[String#html_safe]: https://api.rubyonrails.org/classes/String.html#method-i-html_safe
[String#remove]: https://api.rubyonrails.org/classes/String.html#method-i-remove
[String#squish]: https://api.rubyonrails.org/classes/String.html#method-i-squish
[String#truncate]: https://api.rubyonrails.org/classes/String.html#method-i-truncate
[String#truncate_bytes]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_bytes
[String#truncate_words]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_words
[String#inquiry]: https://api.rubyonrails.org/classes/String.html#method-i-inquiry
[String#strip_heredoc]: https://api.rubyonrails.org/classes/String.html#method-i-strip_heredoc
[String#indent!]: https://api.rubyonrails.org/classes/String.html#method-i-indent-21
[String#indent]: https://api.rubyonrails.org/classes/String.html#method-i-indent
[String#at]: https://api.rubyonrails.org/classes/String.html#method-i-at
[String#from]: https://api.rubyonrails.org/classes/String.html#method-i-from
[String#to]: https://api.rubyonrails.org/classes/String.html#method-i-to
[String#first]: https://api.rubyonrails.org/classes/String.html#method-i-first
[String#last]: https://api.rubyonrails.org/classes/String.html#method-i-last
[String#pluralize]: https://api.rubyonrails.org/classes/String.html#method-i-pluralize
[String#singularize]: https://api.rubyonrails.org/classes/String.html#method-i-singularize
[String#camelcase]: https://api.rubyonrails.org/classes/String.html#method-i-camelcase
[String#camelize]: https://api.rubyonrails.org/classes/String.html#method-i-camelize
[String#underscore]: https://api.rubyonrails.org/classes/String.html#method-i-underscore
[String#titlecase]: https://api.rubyonrails.org/classes/String.html#method-i-titlecase
[String#titleize]: https://api.rubyonrails.org/classes/String.html#method-i-titleize
[String#dasherize]: https://api.rubyonrails.org/classes/String.html#method-i-dasherize
[String#demodulize]: https://api.rubyonrails.org/classes/String.html#method-i-demodulize
[String#deconstantize]: https://api.rubyonrails.org/classes/String.html#method-i-deconstantize
[String#parameterize]: https://api.rubyonrails.org/classes/String.html#method-i-parameterize
[String#tableize]: https://api.rubyonrails.org/classes/String.html#method-i-tableize
[String#classify]: https://api.rubyonrails.org/classes/String.html#method-i-classify
[String#constantize]: https://api.rubyonrails.org/classes/String.html#method-i-constantize
[String#humanize]: https://api.rubyonrails.org/classes/String.html#method-i-humanize
[String#foreign_key]: https://api.rubyonrails.org/classes/String.html#method-i-foreign_key
[String#upcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-upcase_first
[String#downcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-downcase_first
[String#to_date]: https://api.rubyonrails.org/classes/String.html#method-i-to_date
[String#to_datetime]: https://api.rubyonrails.org/classes/String.html#method-i-to_datetime
[String#to_time]: https://api.rubyonrails.org/classes/String.html#method-i-to_time
[Numeric#bytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-bytes
[Numeric#exabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-exabytes
[Numeric#gigabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-gigabytes
[Numeric#kilobytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-kilobytes
[Numeric#megabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-megabytes
[Numeric#petabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-petabytes
[Numeric#terabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-terabytes
[Duration#ago]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-ago
[Duration#from_now]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-from_now
[Numeric#days]: https://api.rubyonrails.org/classes/Numeric.html#method-i-days
[Numeric#fortnights]: https://api.rubyonrails.org/classes/Numeric.html#method-i-fortnights
[Numeric#hours]: https://api.rubyonrails.org/classes/Numeric.html#method-i-hours
[Numeric#minutes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-minutes
[Numeric#seconds]: https://api.rubyonrails.org/classes/Numeric.html#method-i-seconds
[Numeric#weeks]: https://api.rubyonrails.org/classes/Numeric.html#method-i-weeks
[Integer#multiple_of?]: https://api.rubyonrails.org/classes/Integer.html#method-i-multiple_of-3F
[Integer#ordinal]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinal
[Integer#ordinalize]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinalize
[Integer#months]: https://api.rubyonrails.org/classes/Integer.html#method-i-months
[Integer#years]: https://api.rubyonrails.org/classes/Integer.html#method-i-years
[Enumerable#sum]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-sum
[Enumerable#index_by]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_by
[Enumerable#index_with]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_with
[Enumerable#many?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-many-3F
[Enumerable#exclude?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-exclude-3F
[Enumerable#including]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-including
[Enumerable#excluding]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-excluding
[Enumerable#without]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-without
[Enumerable#pluck]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pluck
[Enumerable#pick]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pick
[Array#excluding]: https://api.rubyonrails.org/classes/Array.html#method-i-excluding
[Array#fifth]: https://api.rubyonrails.org/classes/Array.html#method-i-fifth
[Array#forty_two]: https://api.rubyonrails.org/classes/Array.html#method-i-forty_two
[Array#fourth]: https://api.rubyonrails.org/classes/Array.html#method-i-fourth
[Array#from]: https://api.rubyonrails.org/classes/Array.html#method-i-from
[Array#including]: https://api.rubyonrails.org/classes/Array.html#method-i-including
[Array#second]: https://api.rubyonrails.org/classes/Array.html#method-i-second
[Array#second_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-second_to_last
[Array#third]: https://api.rubyonrails.org/classes/Array.html#method-i-third
[Array#third_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-third_to_last
[Array#to]: https://api.rubyonrails.org/classes/Array.html#method-i-to
[Array#extract!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract-21
[Array#extract_options!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract_options-21
[Array#to_sentence]: https://api.rubyonrails.org/classes/Array.html#method-i-to_sentence
[Array#to_fs]: https://api.rubyonrails.org/classes/Array.html#method-i-to_fs
[Array#to_xml]: https://api.rubyonrails.org/classes/Array.html#method-i-to_xml
[Array.wrap]: https://api.rubyonrails.org/classes/Array.html#method-c-wrap
[Array#deep_dup]: https://api.rubyonrails.org/classes/Array.html#method-i-deep_dup
[Array#in_groups_of]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups_of
[Array#in_groups]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups
[Array#split]: https://api.rubyonrails.org/classes/Array.html#method-i-split
[Hash#to_xml]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_xml
[Hash#reverse_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge-21
[Hash#reverse_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge
[Hash#reverse_update]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_update
[Hash#deep_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge-21
[Hash#deep_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge
[Hash#deep_dup]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_dup
[Hash#except!]: https://api.rubyonrails.org/classes/Hash.html#method-i-except-21
[Hash#except]: https://api.rubyonrails.org/classes/Hash.html#method-i-except
[Hash#deep_stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys-21
[Hash#deep_stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys
[Hash#stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys-21
[Hash#stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys
[Hash#deep_symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys-21
[Hash#deep_symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys
[Hash#symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys-21
[Hash#symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys
[Hash#to_options!]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options-21
[Hash#to_options]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options
[Hash#assert_valid_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-assert_valid_keys
[Hash#deep_transform_values!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values-21
[Hash#deep_transform_values]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values
[Hash#slice!]: https://api.rubyonrails.org/classes/Hash.html#method-i-slice-21
[Hash#extract!]: https://api.rubyonrails.org/classes/Hash.html#method-i-extract-21
[ActiveSupport::HashWithIndifferentAccess]: https://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html
[Hash#with_indifferent_access]: https://api.rubyonrails.org/classes/Hash.html#method-i-with_indifferent_access
[Regexp#multiline?]: https://api.rubyonrails.org/classes/Regexp.html#method-i-multiline-3F
[Range#overlap?]: https://api.rubyonrails.org/classes/Range.html#method-i-overlaps-3F
[Date.current]: https://api.rubyonrails.org/classes/Date.html#method-c-current
[Date.tomorrow]: https://api.rubyonrails.org/classes/Date.html#method-c-tomorrow
[Date.yesterday]: https://api.rubyonrails.org/classes/Date.html#method-c-yesterday
[DateAndTime::Calculations#future?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-future-3F
[DateAndTime::Calculations#on_weekday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekday-3F
[DateAndTime::Calculations#on_weekend?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekend-3F
[DateAndTime::Calculations#past?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-past-3F
[`config.beginning_of_week`]: configuring.html#config-beginning-of-week
[DateAndTime::Calculations#at_beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_week
[DateAndTime::Calculations#at_end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_week
[DateAndTime::Calculations#beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_week
[DateAndTime::Calculations#end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_week
[DateAndTime::Calculations#monday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-monday
[DateAndTime::Calculations#sunday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-sunday
[Date.beginning_of_week]: https://api.rubyonrails.org/classes/Date.html#method-c-beginning_of_week
[DateAndTime::Calculations#last_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_week
[DateAndTime::Calculations#next_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_week
[DateAndTime::Calculations#prev_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_week
[DateAndTime::Calculations#at_beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_month
[DateAndTime::Calculations#at_end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_month
[DateAndTime::Calculations#beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_month
[DateAndTime::Calculations#end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_month
[DateAndTime::Calculations#quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-quarter
[DateAndTime::Calculations#at_beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_quarter
[DateAndTime::Calculations#at_end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_quarter
[DateAndTime::Calculations#beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_quarter
[DateAndTime::Calculations#end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_quarter
[DateAndTime::Calculations#at_beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_year
[DateAndTime::Calculations#at_end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_year
[DateAndTime::Calculations#beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_year
[DateAndTime::Calculations#end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_year
[DateAndTime::Calculations#last_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_year
[DateAndTime::Calculations#years_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_ago
[DateAndTime::Calculations#years_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_since
[DateAndTime::Calculations#last_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_month
[DateAndTime::Calculations#months_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_ago
[DateAndTime::Calculations#months_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_since
[DateAndTime::Calculations#weeks_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-weeks_ago
[Date#advance]: https://api.rubyonrails.org/classes/Date.html#method-i-advance
[Date#change]: https://api.rubyonrails.org/classes/Date.html#method-i-change
[ActiveSupport::Duration]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html
[Date#at_beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-at_beginning_of_day
[Date#at_midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-at_midnight
[Date#beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-beginning_of_day
[Date#end_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-end_of_day
[Date#midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-midnight
[DateTime#at_beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_minute
[DateTime#beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_minute
[DateTime#end_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_minute
[Date#ago]: https://api.rubyonrails.org/classes/Date.html#method-i-ago
[Date#since]: https://api.rubyonrails.org/classes/Date.html#method-i-since
[DateTime#ago]: https://api.rubyonrails.org/classes/DateTime.html#method-i-ago
[DateTime#at_beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_day
[DateTime#at_beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_hour
[DateTime#at_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_midnight
[DateTime#beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_day
[DateTime#beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_hour
[DateTime#end_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_day
[DateTime#end_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_hour
[DateTime#in]: https://api.rubyonrails.org/classes/DateTime.html#method-i-in
[DateTime#midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-midnight
[DateTime.current]: https://api.rubyonrails.org/classes/DateTime.html#method-c-current
[DateTime#seconds_since_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-seconds_since_midnight
[DateTime#getutc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-getutc
[DateTime#utc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc
[DateTime#utc?]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc-3F
[DateTime#advance]: https://api.rubyonrails.org/classes/DateTime.html#method-i-advance
[DateTime#since]: https://api.rubyonrails.org/classes/DateTime.html#method-i-since
[DateTime#change]: https://api.rubyonrails.org/classes/DateTime.html#method-i-change
[Time#ago]: https://api.rubyonrails.org/classes/Time.html#method-i-ago
[Time#change]: https://api.rubyonrails.org/classes/Time.html#method-i-change
[Time#since]: https://api.rubyonrails.org/classes/Time.html#method-i-since
[DateAndTime::Calculations#next_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_day-3F
[DateAndTime::Calculations#prev_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_day-3F
[DateAndTime::Calculations#today?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-today-3F
[DateAndTime::Calculations#tomorrow?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-tomorrow-3F
[DateAndTime::Calculations#yesterday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-yesterday-3F
[DateAndTime::Calculations#all_day]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_day
[DateAndTime::Calculations#all_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_month
[DateAndTime::Calculations#all_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_quarter
[DateAndTime::Calculations#all_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_week
[DateAndTime::Calculations#all_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_year
[Time.current]: https://api.rubyonrails.org/classes/Time.html#method-c-current
[Time#next_day]: https://api.rubyonrails.org/classes/Time.html#method-i-next_day
[Time#prev_day]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_day
[Time#next_month]: https://api.rubyonrails.org/classes/Time.html#method-i-next_month
[Time#prev_month]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_month
[Time#next_year]: https://api.rubyonrails.org/classes/Time.html#method-i-next_year
[Time#prev_year]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_year
[DateAndTime::Calculations#last_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_quarter
[DateAndTime::Calculations#next_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_quarter
[DateAndTime::Calculations#prev_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_quarter
[File.atomic_write]: https://api.rubyonrails.org/classes/File.html#method-c-atomic_write
[NameError#missing_name?]: https://api.rubyonrails.org/classes/NameError.html#method-i-missing_name-3F
[LoadError#is_missing?]: https://api.rubyonrails.org/classes/LoadError.html#method-i-is_missing-3F
[Pathname#existence]: https://api.rubyonrails.org/classes/Pathname.html#method-i-existence
