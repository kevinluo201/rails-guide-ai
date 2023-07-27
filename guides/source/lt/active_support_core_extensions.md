**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fdd2e5c41171c61b555549ced4d68a82
Aktyvusis palaikymas - pagrindinė Ruby on Rails komponentė, atsakinga už Ruby kalbos plėtinius ir įrankius.

Jis siūlo geresnį pagrindinį lygį, skirtą tiek Rails aplikacijų kūrimui, tiek paties Ruby on Rails kūrimui.

Po šio vadovo perskaitymo, jūs žinosite:

* Kas yra pagrindiniai plėtiniai.
* Kaip įkelti visus plėtinius.
* Kaip pasirinkti tik tuos plėtinius, kuriuos norite.
* Kokių plėtinių teikia Active Support.

--------------------------------------------------------------------------------

Kaip įkelti pagrindinius plėtinius
---------------------------

### Atskiras Active Support

Norint turėti kuo mažesnį numatytąjį pėdsaką, Active Support pagal numatytuosius nustatymus įkelia mažiausiai priklausomybių. Jis yra padalintas į mažas dalis, kad būtų galima įkelti tik norimus plėtinius. Taip pat yra keli patogūs įėjimo taškai, skirti įkelti susijusius plėtinius vienu metu, netgi viską.

Taigi, po paprasto `require`:

```ruby
require "active_support"
```

bus įkelti tik Active Support pagrindinės plėtiniai.

#### Pasirinkto apibrėžimo įkėlimas

Šis pavyzdys rodo, kaip įkelti [`Hash#with_indifferent_access`][Hash#with_indifferent_access]. Šis plėtinys leidžia konvertuoti `Hash` į [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess], kuris leidžia prieigą prie raktų kaip prie simbolių arba eilučių.

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

Kiekvienam vienam kaip pagrindinė plėtinio metodas šiame vadove turi pastabą, kur nurodoma, kur toks metodas yra apibrėžtas. `with_indifferent_access` atveju pastaba skamba taip:

PASTABA: Apibrėžta `active_support/core_ext/hash/indifferent_access.rb`.

Tai reiškia, kad jį galite įkelti taip:

```ruby
require "active_support"
require "active_support/core_ext/hash/indifferent_access"
```

Active Support buvo atidžiai peržiūrėtas, kad įkeliant failą būtų įkeltos tik būtinos priklausomybės, jei tokių yra.

#### Grupuotų pagrindinių plėtinių įkėlimas

Kitas lygis yra tiesiog įkelti visus `Hash` plėtinius. Taisyklės pagalba, `SomeClass` plėtiniai yra prieinami vienu metu, įkeliant `active_support/core_ext/some_class`.

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

#### Viso Active Support įkėlimas

Ir galiausiai, jei norite turėti visą Active Support, tiesiog naudokite:

```ruby
require "active_support/all"
```

Tai net neįkelia viso Active Support į atmintį iš karto, iš tikrųjų, kai kurie dalykai yra sukonfigūruoti per `autoload`, todėl jie įkeliami tik jei naudojami.

### Active Support naudojimas Ruby on Rails aplikacijoje

Ruby on Rails aplikacija įkelia visą Active Support, nebent [`config.active_support.bare`][] yra `true`. Tokiu atveju aplikacija įkelia tik tai, ką pagrindinė sistema pasirenka savo poreikiams, ir vis tiek gali pasirinkti pati save bet kokiu granuliariu lygiu, kaip paaiškinta ankstesniame skyriuje.


Plėtiniai visiems objektams
-------------------------

### `blank?` ir `present?`

Rails aplikacijoje šie reikšmės laikomos tuščiomis:

* `nil` ir `false`,

* eilutės, sudarytos tik iš tarpų (žr. pastabą žemiau),

* tuščios masyvai ir hash'ai, ir

* bet koks kitas objektas, kuris atsako į `empty?` ir yra tuščias.

INFO: Eilučių predikatas naudoja Unicode sąmoningą simbolių klasę `[:space:]`, todėl pvz., U+2029 (pastraipos skirtukas) laikomas tarpais.

ĮSPĖJIMAS: Atkreipkite dėmesį, kad nėra paminėti skaičiai. Ypač, 0 ir 0.0 **nėra** tušti.

Pavyzdžiui, šis metodas iš `ActionController::HttpAuthentication::Token::ControllerMethods` naudoja [`blank?`][Object#blank?] tikrinimui, ar yra pateiktas ženklas:

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

Metodas [`present?`][Object#present?] yra ekvivalentas `!blank?`. Šis pavyzdys paimtas iš `ActionDispatch::Http::Cache::Response`:

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  # ...
end
```

PASTABA: Apibrėžta `active_support/core_ext/object/blank.rb`.


### `presence`

[`presence`][Object#presence] metodas grąžina savo gavėją, jei `present?`, ir `nil` kitu atveju. Jis naudingas šiam idiomui:
```ruby
host = config[:host].presence || 'localhost'
```

PASTABA: Apibrėžta `active_support/core_ext/object/blank.rb`.


### `duplicable?`

Nuo Ruby 2.5 dauguma objektų gali būti kopijuojami naudojant `dup` arba `clone`:

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (allocator undefined for Method)
```

Active Support teikia [`duplicable?`][Object#duplicable?] metodą, kuris leidžia patikrinti, ar objektas gali būti kopijuojamas:

```ruby
"foo".duplicable?           # => true
"".duplicable?              # => true
Rational(1).duplicable?     # => true
Complex(1).duplicable?      # => true
1.method(:+).duplicable?    # => false
```

ĮSPĖJIMAS: Bet kuri klasė gali neleisti kopijavimo pašalindama `dup` ir `clone` arba iškeliant išimtis iš jų. Todėl tik `rescue` gali pasakyti, ar konkretus objektas gali būti kopijuojamas. `duplicable?` priklauso nuo aukščiau pateiktos sąrašo, tačiau jis yra daug greitesnis nei `rescue`. Jį naudokite tik jei žinote, kad aukščiau pateiktas sąrašas pakanka jūsų atveju.

PASTABA: Apibrėžta `active_support/core_ext/object/duplicable.rb`.


### `deep_dup`

[`deep_dup`][Object#deep_dup] metodas grąžina gilų objekto kopiją. Paprastai, kai kopijuojate objektą, kuris turi kitus objektus, Ruby jų nekopijuoja, todėl sukuria paviršinę objekto kopiją. Jei turite masyvą su eilute, pavyzdžiui, tai atrodytų taip:

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

Kaip matote, nukopijavus `Array` objektą, gavome kitą objektą, todėl galime jį modifikuoti ir originalus objektas liks nepakeistas. Tačiau tai netaikoma masyvo elementams. Kadangi `dup` nekopijuoja giliai, eilutė masyve vis tiek yra tas pats objektas.

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

PASTABA: Apibrėžta `active_support/core_ext/object/deep_dup.rb`.


### `try`

Kai norite iškviesti metodą objekte tik jei jis nėra `nil`, paprasčiausias būdas tai padaryti yra naudoti sąlyginį sakinį, kuris prideda nereikalingą šlamšą. Alternatyva yra naudoti [`try`][Object#try]. `try` yra panašus į `Object#public_send`, tačiau grąžina `nil`, jei jis yra išsiųstas į `nil`.

Štai pavyzdys:

```ruby
# be try
unless @number.nil?
  @number.next
end

# su try
@number.try(:next)
```

Kitas pavyzdys yra šis kodas iš `ActiveRecord::ConnectionAdapters::AbstractAdapter`, kur `@logger` gali būti `nil`. Matote, kad kodas naudoja `try` ir išvengia nereikalingo patikrinimo.

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try` taip pat gali būti iškviestas be argumentų, bet su bloku, kuris bus vykdomas tik jei objektas nėra `nil`:

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

Atkreipkite dėmesį, kad `try` praryja neegzistuojančių metodų klaidas ir grąžina `nil`. Jei norite apsisaugoti nuo klaidų, naudokite [`try!`][Object#try!]:

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

PASTABA: Apibrėžta `active_support/core_ext/object/try.rb`.


### `class_eval(*args, &block)`

Galite įvertinti kodą bet kurio objekto vienkartėje klasėje naudodami [`class_eval`][Kernel#class_eval]:

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

PASTABA: Apibrėžta `active_support/core_ext/kernel/singleton_class.rb`.


### `acts_like?(duck)`

Metodas [`acts_like?`][Object#acts_like?] suteikia galimybę patikrinti, ar tam tikra klasė elgiasi kaip kita klasė, remiantis paprasta konvencija: klasė, kuri teikia tą patį sąsają kaip ir `String`, apibrėžia
```ruby
def acts_like_string?
end
```

tai tik žymeklis, jo kūnas ar grąžinimo reikšmė yra nereikšmingi. Tada kliento kodas gali užklausti, ar objektas elgiasi kaip eilutė:

```ruby
some_klass.acts_like?(:string)
```

Rails turi klases, kurios elgiasi kaip `Date` ar `Time` ir laikosi šio kontrakto.

PASTABA: Apibrėžta `active_support/core_ext/object/acts_like.rb`.


### `to_param`

Visi objektai Rails atsako į metodą [`to_param`][Object#to_param], kuris turėtų grąžinti kažką, kas juos atstovauja kaip reikšmes užklausos eilutėje arba URL fragmentuose.

Pagal numatytuosius nustatymus `to_param` tiesiog iškviečia `to_s`:

```ruby
7.to_param # => "7"
```

`to_param` grąžinimo reikšmė **neturėtų** būti išvengta:

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

Kelių klasės objektai Rails perrašo šį metodą.

Pavyzdžiui, `nil`, `true` ir `false` grąžina patys save. [`Array#to_param`][Array#to_param] iškviečia `to_param` kiekvienam elementui ir sujungia rezultatą su "/":

```ruby
[0, true, String].to_param # => "0/true/String"
```

Ypatingai, Rails maršrutizavimo sistema iškviečia `to_param` modeliuose, kad gautų reikšmę `:id` vietos rezervuotajam žymekliui. `ActiveRecord::Base#to_param` grąžina modelio `id`, bet galite pervardyti šį metodą savo modeliuose. Pavyzdžiui, turint

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

ĮSPĖJIMAS. Valdikliai turi žinoti apie bet kokį `to_param` pervardijimą, nes kai toks užklaustis ateina, "357-john-smith" yra `params[:id]` reikšmė.

PASTABA: Apibrėžta `active_support/core_ext/object/to_param.rb`.


### `to_query`

[`to_query`][Object#to_query] metodas sukuria užklausos eilutę, kuri susieja tam tikrą `key` su `to_param` grąžinimo reikšme. Pavyzdžiui, turint šią `to_param` apibrėžtį:

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

Šis metodas išvengia visko, kas reikalinga, tiek raktui, tiek reikšmei:

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

todėl jo išvestis yra paruošta naudoti užklausos eilutėje.

Masyvai grąžina `to_query` rezultatą, taikydami `to_query` kiekvienam elementui su `key[]` kaip raktu, ir sujungia rezultatą su "&":

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

Hash'ai taip pat atsako į `to_query`, bet su kitokia signatūra. Jei nėra perduodamas argumentas, skambutis generuoja surūšiuotą raktų/vertės priskyrimų seriją, iškviečiant `to_query(key)` jo reikšmes. Tada jis sujungia rezultatą su "&":

```ruby
{ c: 3, b: 2, a: 1 }.to_query # => "a=1&b=2&c=3"
```

Metodas [`Hash#to_query`][Hash#to_query] priima pasirinktinį vardų sritį raktams:

```ruby
{ id: 89, name: "John Smith" }.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

PASTABA: Apibrėžta `active_support/core_ext/object/to_query.rb`.


### `with_options`

Metodas [`with_options`][Object#with_options] suteikia būdą išskirti bendrus nustatymus serijai metodų kvietimų.

Turint numatytąjį nustatymų maišą, `with_options` perduoda proxy objektą į bloką. Bloke, metodai, iškviesti per proxy, perduodami gavėjui su sujungtais nustatymais. Pavyzdžiui, galite atsikratyti dublikavimo:

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

Toks idiomas gali taip pat perduoti _grupavimą_ skaitytojui. Pavyzdžiui, sakykite, norite išsiųsti naujienlaiškį, kurio kalba priklauso nuo vartotojo. Kažkur pašto siuntėjime galėtumėte grupuoti lokalės priklausomas dalis taip:

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

PATARIMAS: Kadangi `with_options` perduoda skambučius gavėjui, jie gali būti įdėti vienas į kitą. Kiekvienas įdėjimo lygis pridės paveldėtus numatytuosius nustatymus, be savųjų.

PASTABA: Apibrėžta `active_support/core_ext/object/with_options.rb`.


### JSON palaikymas

Active Support teikia geresnį `to_json` įgyvendinimą nei įprastai `json` gemo teikia Ruby objektams. Tai yra todėl, kad kai kurios klasės, pvz., `Hash` ir `Process::Status`, reikalauja specialaus tvarkymo, kad būtų galima gauti tinkamą JSON atvaizdavimą.
PASTABA: Apibrėžta `active_support/core_ext/object/json.rb`.

### Egzemplioriaus kintamieji

Active Support teikia keletą metodų, palengvinančių prieigą prie egzemplioriaus kintamųjų.

#### `instance_values`

Metodas [`instance_values`][Object#instance_values] grąžina `Hash` objektą, kuriame atitinkamai priskiriami egzemplioriaus kintamųjų pavadinimai be "@" simbolio ir jų reikšmės. Raktai yra eilutės:

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

Metodas [`instance_variable_names`][Object#instance_variable_names] grąžina masyvą. Kiekvienas pavadinimas įtraukia "@" simbolį.

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

PASTABA: Apibrėžta `active_support/core_ext/object/instance_variables.rb`.


### Klaidų ir išimčių nutildymas

Metodai [`silence_warnings`][Kernel#silence_warnings] ir [`enable_warnings`][Kernel#enable_warnings] keičia `$VERBOSE` reikšmę atitinkamai per jų bloko vykdymo laikotarpį ir po to ją atstatydami:

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

Išimčių nutildymas taip pat yra įmanomas naudojant [`suppress`][Kernel#suppress]. Šis metodas priima bet kokį išimčių klasės skaičių. Jei bloko vykdymo metu iškyla išimtis ir ji yra `kind_of?` bet kurio iš argumentų, `suppress` ją užfiksuoja ir nutyli. Kitu atveju išimtis nėra užfiksuojama:

```ruby
# Jei vartotojas yra užrakintas, padidinimas yra prarandamas, tai nėra didelė problema.
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

Modelio atributai turi skaitytuvą, rašytuvą ir predikatą. Galite sukurti modelio atributą, kuriam visi trys metodai yra apibrėžti naudojant [`alias_attribute`][Module#alias_attribute]. Kaip ir kituose atributų vardų keitimo metodų atveju, naujas vardas yra pirmasis argumentas, o senas vardas yra antrasis (vienas mnemoninis būdas yra tai, kad jie eina tokiu pačiu tvarka, kaip ir priskyrimo atveju):

```ruby
class User < ApplicationRecord
  # Galite kreiptis į el. pašto stulpelį kaip į "prisijungimą".
  # Tai gali būti reikšminga autentifikacijos kodo atveju.
  alias_attribute :login, :email
end
```

PASTABA: Apibrėžta `active_support/core_ext/module/aliasing.rb`.


#### Vidiniai atributai

Kai apibrėžiate atributą klasėje, kuri skirta paveldėti, pavadinimo susidūrimai yra rizika. Tai ypač svarbu bibliotekoms.

Active Support apibrėžia makrokomandas [`attr_internal_reader`][Module#attr_internal_reader], [`attr_internal_writer`][Module#attr_internal_writer] ir [`attr_internal_accessor`][Module#attr_internal_accessor]. Jos elgiasi kaip įprastos Ruby `attr_*` makrokomandos, išskyrus tai, kad jos pavadina pagrindinį egzemplioriaus kintamąjį taip, kad susidūrimai būtų mažiau tikėtini.

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

Ankstesniame pavyzdyje gali būti atvejis, kai `:log_level` nepriklauso bibliotekos viešajai sąsajai ir jis naudojamas tik plėtotei. Kliento kodas, nežinodamas apie galimą konfliktą, paveldi ir apibrėžia savo `:log_level`. Dėka `attr_internal` nėra susidūrimo.

Pagal numatytuosius nustatymus vidinio egzemplioriaus kintamojo pavadinimas prasideda priešingu brūkšniu, `@_log_level` pavyzdyje. Tai galima konfigūruoti naudojant `Module.attr_internal_naming_format`, galite perduoti bet kokį `sprintf` tipo formatavimo eilutę su pirmais `@` ir kur nors `%s`, kur bus įdėtas pavadinimas. Numatytasis yra `"@_%s"`.

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

Makrokomandos [`mattr_reader`][Module#mattr_reader], [`mattr_writer`][Module#mattr_writer] ir [`mattr_accessor`][Module#mattr_accessor] yra tokios pačios kaip ir `cattr_*` makrokomandos, apibrėžtos klasėms. Iš tikrųjų, `cattr_*` makrokomandos yra tik sinonimai `mattr_*` makrokomandoms. Žr. [Klasės atributai](#klasės-atributai).
Pavyzdžiui, API žurnalo Active Storage yra sugeneruotas naudojant `mattr_accessor`:

```ruby
module ActiveStorage
  mattr_accessor :logger
end
```

PASTABA: Apibrėžta `active_support/core_ext/module/attribute_accessors.rb`.


### Tėvai

#### `module_parent`

Metodas [`module_parent`][Module#module_parent] įdėtame varduojamame modulyje grąžina modulį, kuris turi atitinkamą konstantą:

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

PASTABA: Apibrėžta `active_support/core_ext/module/introspection.rb`.


#### `module_parent_name`

Metodas [`module_parent_name`][Module#module_parent_name] įdėtame varduojamame modulyje grąžina visiškai kvalifikuotą modulio, turinčio atitinkamą konstantą, pavadinimą:

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

Viršutiniams arba anoniminiams moduliams `module_parent_name` grąžina `nil`.

ĮSPĖJIMAS: Atkreipkite dėmesį, kad šiuo atveju `module_parent` grąžina `Object`.

PASTABA: Apibrėžta `active_support/core_ext/module/introspection.rb`.


#### `module_parents`

Metodas [`module_parents`][Module#module_parents] iškviečia `module_parent` gavėją ir juda aukštyn, kol pasiekiamas `Object`. Grandinė grąžinama masyve, nuo apačios iki viršaus:

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

PASTABA: Apibrėžta `active_support/core_ext/module/introspection.rb`.


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

Galite patikrinti, ar modulis turi pavadinimą naudodami predikato [`anonymous?`][Module#anonymous?]:

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

Atkreipkite dėmesį, kad nepasiekiamumas nereiškia, kad modulis yra anoniminis:

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

tačiau anoniminis modulis yra nepasiekiamas pagal apibrėžtį.

PASTABA: Apibrėžta `active_support/core_ext/module/anonymous.rb`.


### Metodų Delegavimas

#### `delegate`

Makro [`delegate`][Module#delegate] siūlo paprastą būdą perduoti metodus.

Pavyzdžiui, įsivaizduokite, kad vartotojai tam tikroje programoje turi prisijungimo informaciją `User` modelyje, bet vardą ir kitus duomenis atskirame `Profile` modelyje:

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

Su tokia konfigūracija vartotojo vardą galite gauti per jų profilį, `user.profile.name`, bet būtų patogu vis tiek galėti tiesiogiai pasiekti tokią atributą:

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

Kai interpoliuojamas į eilutę, `:to` parinktis turėtų tapti išraiška, kuri vertinama į objektą, kuriam yra perduodamas metodas. Paprastai tai yra eilutė arba simbolis. Tokia išraiška vertinama gavėjo kontekste:

```ruby
# perduoda Rails konstantai
delegate :logger, to: :Rails

# perduoda gavėjo klasės
delegate :table_name, to: :class
```

ĮSPĖJIMAS: Jei `:prefix` parinktis yra `true`, tai yra mažiau bendrinė, žr. žemiau.

Pagal numatytuosius nustatymus, jei perduodamas metodas sukelia `NoMethodError` ir tikslas yra `nil`, išimtis perduodama. Galite paprašyti, kad būtų grąžintas `nil` su `:allow_nil` parinktimi:

```ruby
delegate :name, to: :profile, allow_nil: true
```

Su `:allow_nil` skambutis `user.name` grąžina `nil`, jei vartotojas neturi profilio.

`prefix` parinktis prideda priešdėlį prie sugeneruoto metodo pavadinimo. Tai gali būti patogu, pavyzdžiui, gauti geresnį pavadinimą:

```ruby
delegate :street, to: :address, prefix: true
```

Ankstesnis pavyzdys generuoja `address_street` vietoje `street`.
ĮSPĖJIMAS: Kadangi šiuo atveju sugeneruoto metodo pavadinimas sudarytas iš tikslaus objekto ir tikslaus metodo pavadinimų, `:to` parinktis turi būti metodo pavadinimas.

Taip pat galima konfigūruoti pasirinktinį priešdėlį:

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

Ankstesniame pavyzdyje makro sugeneruoja `avatar_size` vietoje `size`.

Parinktis `:private` keičia metodų matomumą:

```ruby
delegate :date_of_birth, to: :profile, private: true
```

Deleguojami metodai pagal numatytuosius nustatymus yra vieši. Norėdami tai pakeisti, perduokite `private: true`.

PASTABA: Apibrėžta `active_support/core_ext/module/delegation.rb`


#### `delegate_missing_to`

Įsivaizduokite, kad norite deleguoti viską, kas trūksta iš `User` objekto, į `Profile`. [`delegate_missing_to`][Module#delegate_missing_to] makras leidžia jums tai įgyvendinti lengvai:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate_missing_to :profile
end
```

Tikslas gali būti bet kas, ką galima iškviesti objekte, pvz., objekto kintamieji, metodai, konstantos ir kt. Deleguojami tik tikslo vieši metodai.

PASTABA: Apibrėžta `active_support/core_ext/module/delegation.rb`.


### Metodų persikūrimas

Yra atvejų, kai jums reikia apibrėžti metodą su `define_method`, bet nežinote, ar toks metodas su tokiu pavadinimu jau egzistuoja. Jei taip, išspausdinamas įspėjimas, jei jie yra įjungti. Tai nėra didelė problema, bet tai nėra ir tvarkinga.

Metodas [`redefine_method`][Module#redefine_method] užkerta kelią tokiam potencialiam įspėjimui, pašalindamas esamą metodą, jei reikia.

Taip pat galite naudoti [`silence_redefinition_of_method`][Module#silence_redefinition_of_method], jei norite apibrėžti pakeitimo metodą patys (pavyzdžiui, naudojant `delegate`).

PASTABA: Apibrėžta `active_support/core_ext/module/redefine_method.rb`.


Plėtiniai `Class` klasėje
---------------------

### Klasės atributai

#### `class_attribute`

Metodas [`class_attribute`][Class#class_attribute] deklaruoja vieną ar daugiau paveldimų klasės atributų, kurie gali būti perrašomi bet kuriame hierarchijos lygyje.

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

Modeliui ši parinktis gali būti naudinga, kaip būdas užkirsti kelią masiniam priskyrimui nustatyti atributą.

Skaitytojo objekto metodo generavimą galima išvengti nustatant parinktį `:instance_reader` į `false`.

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

Dėl patogumo `class_attribute` taip pat apibrėžia objekto predikatą, kuris yra dvigubas neigimas to, ką grąžina objekto skaitytuvas. Pavyzdžiuose jis būtų pavadintas `x?`.

Kai `:instance_reader` yra `false`, objekto predikatas grąžina `NoMethodError`, kaip ir skaitytuvo metodas.

Jei nenorite objekto predikato, perduokite `instance_predicate: false`, ir jis nebus apibrėžtas.

PASTABA: Apibrėžta `active_support/core_ext/class/attribute.rb`.


#### `cattr_reader`, `cattr_writer` ir `cattr_accessor`

Makrosai [`cattr_reader`][Module#cattr_reader], [`cattr_writer`][Module#cattr_writer] ir [`cattr_accessor`][Module#cattr_accessor] yra analogiški `attr_*` atitinkamams makrams, bet skirti klasėms. Jie inicializuoja klasės kintamąjį į `nil`, jei jis dar neegzistuoja, ir generuoja atitinkamus klasės metodus, kad jį pasiektų:

```ruby
class MysqlAdapter < AbstractAdapter
  # Generuoja klasės metodus, skirtus pasiekti @@emulate_booleans.
  cattr_accessor :emulate_booleans
end
```

Taip pat galite perduoti bloką `cattr_*`, kad nustatytumėte atributą su numatytuoju reikšme:

```ruby
class MysqlAdapter < AbstractAdapter
  # Generuoja klasės metodus, skirtus pasiekti @@emulate_booleans su numatytąja reikšme true.
  cattr_accessor :emulate_booleans, default: true
end
```
Papildomai yra sukuriami objekto metodai, kurie yra tik proxy prie klasės atributo. Taigi, objektai gali keisti klasės atributą, bet negali jį perrašyti, kaip tai vyksta su `class_attribute` (žr. aukščiau). Pavyzdžiui, turint

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

mes galime pasiekti `field_error_proc` per vaizdus.

Skaitymo objekto metodo generavimą galima išvengti nustatant `:instance_reader` į `false`, o rašymo objekto metodo generavimą galima išvengti nustatant `:instance_writer` į `false`. Abiejų metodų generavimą galima išvengti nustatant `:instance_accessor` į `false`. Visais atvejais reikšmė turi būti tiksliai `false`, o ne bet kokia klaidinga reikšmė.

```ruby
module A
  class B
    # Nebus sugeneruotas first_name skaitymo objekto metodas.
    cattr_accessor :first_name, instance_reader: false
    # Nebus sugeneruotas last_name= rašymo objekto metodas.
    cattr_accessor :last_name, instance_writer: false
    # Nebus sugeneruoti surname skaitymo objekto ir surname= rašymo objekto metodai.
    cattr_accessor :surname, instance_accessor: false
  end
end
```

Modeliui gali būti naudinga nustatyti `:instance_accessor` į `false`, kaip būdą apsaugoti nuo masinio priskyrimo atributui.

PASTABA: Apibrėžta `active_support/core_ext/module/attribute_accessors.rb`.


### Subklasės ir Palikuonys

#### `subclasses`

[`subclasses`][Class#subclasses] metodas grąžina gavėjo subklases:

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

Šių klasių grąžinimo tvarka nėra nurodyta.

PASTABA: Apibrėžta `active_support/core_ext/class/subclasses.rb`.


#### `descendants`

[`descendants`][Class#descendants] metodas grąžina visas klases, kurios yra `<` negu gavėjas:

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

Šių klasių grąžinimo tvarka nėra nurodyta.

PASTABA: Apibrėžta `active_support/core_ext/class/subclasses.rb`.


Plėtiniai `String` klasei
----------------------

### Išvesties saugumas

#### Motyvacija

Duomenų įterpimas į HTML šablonus reikalauja papildomos priežiūros. Pavyzdžiui, negalima tiesiog įterpti `@review.title` į HTML puslapį. Vienas iš priežasčių yra tai, kad jei apžvalgos pavadinimas yra "Flanagan & Matz rules!", išvestis nebus gerai suformuota, nes ampersandas turi būti pakeisti į "&amp;amp;". Be to, priklausomai nuo programos, tai gali būti didelė saugumo spraga, nes vartotojai gali įterpti kenksmingą HTML, nustatydami savo rankų darbo apžvalgos pavadinimą. Daugiau informacijos apie šios rizikos kryžminį skriptavimą rasite [Saugumo vadove](security.html#cross-site-scripting-xss).

#### Saugūs eilutės

Active Support turi _(html) saugaus_ eilučių sąvoką. Saugi eilutė yra žymima kaip įterpiama į HTML kaip yra. Ji yra patikima, nepriklausomai nuo to, ar ji buvo pakeista ar ne.

Pagal nutylėjimą eilutės laikomos _nesaugiomis_:

```ruby
"".html_safe? # => false
```

Galite gauti saugią eilutę iš esamos naudodami [`html_safe`][String#html_safe] metodą:

```ruby
s = "".html_safe
s.html_safe? # => true
```

Svarbu suprasti, kad `html_safe` neatlieka jokio pakeitimo, tai tik patvirtinimas:

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

Jūsų atsakomybė užtikrinti, kad `html_safe` būtų tinkamai naudojamas tam tikroje eilutėje.

Jei pridedate prie saugios eilutės, arba vietoje su `concat`/`<<`, arba su `+`, rezultatas yra saugi eilutė. Nesaugūs argumentai yra pakeičiami:

```ruby
"".html_safe + "<" # => "&lt;"
```

Saugūs argumentai yra tiesiog pridedami:

```ruby
"".html_safe + "<".html_safe # => "<"
```

Šių metodų neturėtų būti naudojama įprastose peržiūrose. Nesaugios reikšmės automatiškai yra pakeičiamos:

```erb
<%= @review.title %> <%# gerai, jei reikia pakeisti %>
```
Norint įterpti kažką verbatim, naudokite [`raw`][] pagalbininką, o ne `html_safe` funkciją:

```erb
<%= raw @cms.current_template %> <%# įterpia @cms.current_template kaip yra %>
```

arba, ekvivalentiškai, naudokite `<%==`:

```erb
<%== @cms.current_template %> <%# įterpia @cms.current_template kaip yra %>
```

`raw` pagalbininkas automatiškai iškviečia `html_safe` funkciją:

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

PASTABA: Apibrėžta `active_support/core_ext/string/output_safety.rb` faile.


#### Transformacija

Taisyklės pagalba, išskyrus galbūt konkatenaciją, kaip paaiškinta aukščiau, bet kokia funkcija, kuri gali pakeisti eilutę, suteikia jums nesaugią eilutę. Tai gali būti `downcase`, `gsub`, `strip`, `chomp`, `underscore`, ir t.t.

Atveju, kai vietoje transformacijos naudojama `gsub!`, pats objektas tampa nesaugus.

INFORMACIJA: Saugumo bitas visada prarandamas, nepriklausomai nuo to, ar transformacija iš tikrųjų kažką pakeitė.

#### Konversija ir Koercija

Kviečiant `to_s` funkciją saugioje eilutėje, grąžinama saugi eilutė, tačiau koercija su `to_str` grąžina nesaugią eilutę.

#### Kopijavimas

Kviečiant `dup` arba `clone` funkciją saugiose eilutėse gaunamos saugios eilutės.

### `remove`

[`remove`](String#remove) funkcija pašalins visus šablono pasikartojimus:

```ruby
"Hello World".remove(/Hello /) # => "World"
```

Taip pat yra destruktyvioji versija `String#remove!`.

PASTABA: Apibrėžta `active_support/core_ext/string/filters.rb` faile.


### `squish`

[`squish`](String#squish) funkcija pašalina pradines ir galines tarpus, ir pakeičia tarpus su vienu tarpeliu:

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

Taip pat yra destruktyvioji versija `String#squish!`.

Reikia pažymėti, kad ji tvarko tiek ASCII, tiek Unicode tarpus.

PASTABA: Apibrėžta `active_support/core_ext/string/filters.rb` faile.


### `truncate`

[`truncate`](String#truncate) funkcija grąžina kopiją, kurios ilgis yra apribotas iki nurodyto `length`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

Elipsės gali būti pritaikytos su `:omission` parametru:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

Reikia atkreipti dėmesį, kad apribojimas atsižvelgia į elipsės eilutės ilgį.

Prašant `:separator` parametrą, eilutė bus apribota natūraliame pertraukime:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

`:separator` parametras gali būti reguliarioji išraiška:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

Pirmuose pavyzdžiuose "dear" yra pjaunama pirmiausia, bet tada `:separator` parametras tai neleidžia.

PASTABA: Apibrėžta `active_support/core_ext/string/filters.rb` faile.


### `truncate_bytes`

[`truncate_bytes`](String#truncate_bytes) funkcija grąžina kopiją, kurios ilgis yra apribotas iki nurodyto baitų skaičiaus `bytesize`:

```ruby
"👍👍👍👍".truncate_bytes(15)
# => "👍👍👍…"
```

Elipsės gali būti pritaikytos su `:omission` parametru:

```ruby
"👍👍👍👍".truncate_bytes(15, omission: "🖖")
# => "👍👍🖖"
```

PASTABA: Apibrėžta `active_support/core_ext/string/filters.rb` faile.


### `truncate_words`

[`truncate_words`](String#truncate_words) funkcija grąžina kopiją, kurios ilgis yra apribotas iki nurodyto žodžių skaičiaus:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

Elipsės gali būti pritaikytos su `:omission` parametru:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

Prašant `:separator` parametrą, eilutė bus apribota natūraliame pertraukime:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! I shall be late..."
```

`:separator` parametras gali būti reguliarioji išraiška:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

PASTABA: Apibrėžta `active_support/core_ext/string/filters.rb` faile.


### `inquiry`

[`inquiry`](String#inquiry) funkcija konvertuoja eilutę į `StringInquirer` objektą, padarant lyginimo tikrinimus gražesnius.

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

PASTABA: Apibrėžta `active_support/core_ext/string/inquiry.rb` faile.


### `starts_with?` ir `ends_with?`

Active Support apibrėžia trečiosios asmenies sinonimus `String#start_with?` ir `String#end_with?` funkcijoms:

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```
PASTABA: Apibrėžta `active_support/core_ext/string/starts_ends_with.rb`.

### `strip_heredoc`

Metodas [`strip_heredoc`][String#strip_heredoc] pašalina įtrauką heredoc'e.

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

Techniškai, jis ieško mažiausiai įtrauktos eilutės visame tekste ir pašalina
tokio dydžio pradines tuščias vietas.

PASTABA: Apibrėžta `active_support/core_ext/string/strip.rb`.


### `indent`

Metodas [`indent`][String#indent] įtraukia eilutes gavėjyje:

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

Antrasis argumentas, `indent_string`, nurodo, kokį įtraukos simbolį naudoti. Numatytasis reikšmė yra `nil`, kas reiškia, kad metodas padarys išvadą, žiūrėdamas į pirmą įtrauktą eilutę, ir jei jos nėra, naudos tarpą.

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

Nors `indent_string` paprastai yra vienas tarpas ar tabuliacija, jis gali būti bet koks simbolių eilutė.

Trečiasis argumentas, `indent_empty_lines`, yra žymeklis, kuris nurodo, ar tuščios eilutės turėtų būti įtrauktos. Numatytoji reikšmė yra falsa.

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

Metodas [`indent!`][String#indent!] atlieka įtrauką vietoje.

PASTABA: Apibrėžta `active_support/core_ext/string/indent.rb`.


### Prieiga

#### `at(position)`

Metodas [`at`][String#at] grąžina simbolį eilutėje, esančioje pozicijoje `position`:

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

PASTABA: Apibrėžta `active_support/core_ext/string/access.rb`.


#### `from(position)`

Metodas [`from`][String#from] grąžina eilutės dalį, pradedant nuo pozicijos `position`:

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

PASTABA: Apibrėžta `active_support/core_ext/string/access.rb`.


#### `to(position)`

Metodas [`to`][String#to] grąžina eilutės dalį iki pozicijos `position`:

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

PASTABA: Apibrėžta `active_support/core_ext/string/access.rb`.


#### `first(limit = 1)`

Metodas [`first`][String#first] grąžina eilutės dalį, kurią sudaro pirmi `limit` simboliai.

Kvietimas `str.first(n)` yra ekvivalentus `str.to(n-1)`, jei `n` > 0, ir grąžina tuščią eilutę, jei `n` == 0.

PASTABA: Apibrėžta `active_support/core_ext/string/access.rb`.


#### `last(limit = 1)`

Metodas [`last`][String#last] grąžina eilutės dalį, kurią sudaro paskutiniai `limit` simboliai.

Kvietimas `str.last(n)` yra ekvivalentus `str.from(-n)`, jei `n` > 0, ir grąžina tuščią eilutę, jei `n` == 0.

PASTABA: Apibrėžta `active_support/core_ext/string/access.rb`.


### Inflekcijos

#### `pluralize`

Metodas [`pluralize`][String#pluralize] grąžina savo gavėjo daugiskaitą:

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

Kaip rodo ankstesnis pavyzdys, Active Support žino keletą nereguliarių daugiskaitos formų ir neskaitomų daiktavardžių. Įdiegtos taisyklės gali būti išplėstos `config/initializers/inflections.rb`. Šis failas yra numatytasis, kurį generuoja `rails new` komanda ir turi instrukcijas komentarų pavidalu.

`pluralize` taip pat gali priimti pasirinktinį `count` parametrą. Jei `count == 1`, bus grąžinama vienaskaitos forma. Kitais `count` reikšmės atvejais bus grąžinama daugiskaitos forma:

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

PASTABA: Apibrėžta `active_support/core_ext/string/inflections.rb`.


#### `singularize`

Metodas [`singularize`][String#singularize] yra `pluralize` atvirkštis:

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
PASTABA: Apibrėžta faile `active_support/core_ext/string/inflections.rb`.


#### `camelize`

Metodas [`camelize`][String#camelize] grąžina savo gavėją kaip camel case:

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

Taisyklės pagalba galite manyti, kad šis metodas paverčia kelius į Ruby klasės ar modulio pavadinimus, kurie yra atskirti pasvirais brūkšniais:

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

`camelize` priima pasirinktinį argumentą, kuris gali būti `:upper` (numatytasis) arba `:lower`. Su paskutiniu pirmoji raidė tampa mažosiomis:

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

Tai gali būti naudinga skaičiuoti metodų pavadinimus kalboje, kuri laikosi šios konvencijos, pvz., JavaScript.

INFORMACIJA: Taisyklės pagalba galite manyti, kad `camelize` yra `underscore` atvirkštinis metodas, nors yra atvejų, kai tai ne taip: `"SSLError".underscore.camelize` grąžina `"SslError"`. Norint palaikyti tokias situacijas, Active Support leidžia nurodyti akronimus `config/initializers/inflections.rb` faile:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize` yra sinonimas [`camelcase`][String#camelcase].

PASTABA: Apibrėžta faile `active_support/core_ext/string/inflections.rb`.


#### `underscore`

Metodas [`underscore`][String#underscore] veikia atvirkščiai, iš camel case paverčia į kelius:

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

Taip pat pakeičia "::" į "/":

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

ir supranta eilutes, kurios prasideda mažąja raide:

```ruby
"visualEffect".underscore # => "visual_effect"
```

`underscore` nepriima jokių argumentų.

Rails naudoja `underscore` gauti mažosiomis raides pavadinimą valdiklio klasėms:

```ruby
# actionpack/lib/abstract_controller/base.rb
def controller_path
  @controller_path ||= name.delete_suffix("Controller").underscore
end
```

Pavyzdžiui, toks reikšmė yra ta, kurią gaunate `params[:controller]`.

INFORMACIJA: Taisyklės pagalba galite manyti, kad `underscore` yra `camelize` atvirkštinis metodas, nors yra atvejų, kai tai ne taip. Pavyzdžiui, `"SSLError".underscore.camelize` grąžina `"SslError"`.

PASTABA: Apibrėžta faile `active_support/core_ext/string/inflections.rb`.


#### `titleize`

Metodas [`titleize`][String#titleize] didžiosiomis raidėmis rašo žodžius gavėje:

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize` yra sinonimas [`titlecase`][String#titlecase].

PASTABA: Apibrėžta faile `active_support/core_ext/string/inflections.rb`.


#### `dasherize`

Metodas [`dasherize`][String#dasherize] pakeičia pasviruosius brūkšnius gavėje į brūkšnelius:

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

Modelių XML serijizatorius naudoja šį metodą, kad pakeistų mazgų pavadinimus į brūkšnelius:

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

PASTABA: Apibrėžta faile `active_support/core_ext/string/inflections.rb`.


#### `demodulize`

Duodant eilutę su kvalifikuotu konstantos pavadinimu, [`demodulize`][String#demodulize] grąžina pačią konstantos pavadinimo dalį, t. y. dešinęjąją dalį:

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

PASTABA: Apibrėžta faile `active_support/core_ext/string/inflections.rb`.


#### `deconstantize`

Duodant eilutę su kvalifikuota konstantos nuoroda, [`deconstantize`][String#deconstantize] pašalina dešinęjąją dalį, paliekant konstantos konteinerio pavadinimą:

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

PASTABA: Apibrėžta faile `active_support/core_ext/string/inflections.rb`.


#### `parameterize`

Metodas [`parameterize`][String#parameterize] normalizuoja savo gavėją taip, kad jis galėtų būti naudojamas gražioms URL.

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

Norint išlaikyti eilutės raidžių dydį, nustatykite `preserve_case` argumentą į true. Numatytuoju atveju `preserve_case` yra nustatytas į false.

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

Norint naudoti pasirinktinį skyriklį, pakeiskite `separator` argumentą.
```ruby
"Employee Salary".downcase_first # => "employee Salary"
"".downcase_first                # => ""
```

NOTE: Defined in `active_support/core_ext/string/inflections.rb`.
```ruby
123.to_fs(:human)                  # => "123"
1234.to_fs(:human)                 # => "1.23 thousand"
12345.to_fs(:human)                # => "12.3 thousand"
1234567.to_fs(:human)              # => "1.23 million"
1234567890.to_fs(:human)           # => "1.23 billion"
1234567890123.to_fs(:human)        # => "1.23 trillion"
1234567890123456.to_fs(:human)     # => "1.23 quadrillion"
1234567890123456789.to_fs(:human)  # => "1.23 quintillion"
```

NOTE: Defined in `active_support/core_ext/numeric/conversions.rb`.
```ruby
123.to_fs(:human)               # => "123"
1234.to_fs(:human)              # => "1.23 Tūkstantis"
12345.to_fs(:human)             # => "12.3 Tūkstantis"
1234567.to_fs(:human)           # => "1.23 Milijonas"
1234567890.to_fs(:human)        # => "1.23 Milijardas"
1234567890123.to_fs(:human)     # => "1.23 Trilijonas"
1234567890123456.to_fs(:human)  # => "1.23 Kvadrilijonas"
```

PASTABA: Apibrėžta `active_support/core_ext/numeric/conversions.rb`.

Plėtiniai `Integer`
-----------------------

### `multiple_of?`

Metodas [`multiple_of?`][Integer#multiple_of?] patikrina, ar sveikasis skaičius yra argumento daugiklis:

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

PASTABA: Apibrėžta `active_support/core_ext/integer/multiple.rb`.


### `ordinal`

Metodas [`ordinal`][Integer#ordinal] grąžina eilės skaitvardį, atitinkantį sveikąjį skaičių:

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

PASTABA: Apibrėžta `active_support/core_ext/integer/inflections.rb`.


### `ordinalize`

Metodas [`ordinalize`][Integer#ordinalize] grąžina eilės skaitvardį, atitinkantį sveikąjį skaičių. Palyginimui, `ordinal` metodas grąžina **tik** skaitvardžio galūnę.

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

PASTABA: Apibrėžta `active_support/core_ext/integer/inflections.rb`.


### Laikas

Šie metodai:

* [`months`][Integer#months]
* [`years`][Integer#years]

leidžia deklaruoti ir skaičiuoti laiką, pvz., `4.months + 5.years`. Jų grąžinimo reikšmės taip pat gali būti pridėtos arba atimtos nuo laiko objektų.

Šiuos metodus galima derinti su [`from_now`][Duration#from_now], [`ago`][Duration#ago] ir kt., siekiant tikslaus datos skaičiavimo. Pavyzdžiui:

```ruby
# ekvivalentu Time.current.advance(months: 1)
1.month.from_now

# ekvivalentu Time.current.advance(years: 2)
2.years.from_now

# ekvivalentu Time.current.advance(months: 4, years: 5)
(4.months + 5.years).from_now
```

ĮSPĖJIMAS. Kitoms trukmėms kreipkitės į `Numeric` laiko plėtinius.

PASTABA: Apibrėžta `active_support/core_ext/integer/time.rb`.


Plėtiniai `BigDecimal`
--------------------------

### `to_s`

Metodas `to_s` numato numatytąjį specifikatorių "F". Tai reiškia, kad paprastas `to_s` iškvietimas grąžins slankiojo kablelio reprezentaciją, o ne inžinerinę notaciją:

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

Vis dar palaikoma inžinerinė notacija:

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

Plėtiniai `Enumerable`
--------------------------

### `sum`

Metodas [`sum`][Enumerable#sum] sudeda elementus iš sąrašo:

```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

Sudėtis veikia tik su elementais, kurie gali atlikti sudėties operaciją `+`:

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{ a: 1, b: 2, c: 3 }.sum          # => [:a, 1, :b, 2, :c, 3]
```

Tuščio sąrašo suma pagal numatytuosius nustatymus yra nulis, tačiau tai galima keisti:

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

Jeigu yra pateiktas blokas, `sum` tampa iteratoriumi, kuris grąžina sąrašo elementus ir sudeda grąžintas reikšmes:

```ruby
(1..5).sum { |n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

Tuščio sąrašo suma taip pat gali būti keičiama šioje formoje:

```ruby
[].sum(1) { |n| n**3 } # => 1
```

PASTABA: Apibrėžta `active_support/core_ext/enumerable.rb`.


### `index_by`

Metodas [`index_by`][Enumerable#index_by] sugeneruoja raktų sąrašą su sąrašo elementais.

Jis peržiūri sąrašą ir perduoda kiekvieną elementą blokui. Elementas bus raktas, grąžintas bloko:

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

ĮSPĖJIMAS. Raktai paprastai turėtų būti unikalūs. Jei blokas grąžina tą pačią reikšmę skirtingiems elementams, raktų sąrašas nebus sukurtas. Laimi paskutinis elementas.

PASTABA: Apibrėžta `active_support/core_ext/enumerable.rb`.


### `index_with`

Metodas [`index_with`][Enumerable#index_with] sugeneruoja raktų sąrašą su sąrašo elementais. Reikšmė yra nurodyta numatytuoju arba grąžinama bloke.

```ruby
post = Post.new(title: "hey there", body: "what's up?")

%i( title body ).index_with { |attr_name| post.public_send(attr_name) }
# => { title: "hey there", body: "what's up?" }

WEEKDAYS.index_with(Interval.all_day)
# => { monday: [ 0, 1440 ], … }
```
PASTABA: Apibrėžta faile `active_support/core_ext/enumerable.rb`.


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

PASTABA: Apibrėžta faile `active_support/core_ext/enumerable.rb`.


### `exclude?`

Predikatas [`exclude?`][Enumerable#exclude?] patikrina, ar duotas objektas **ne** priklauso kolekcijai. Tai yra įprasto `include?` neigimas:

```ruby
to_visit << node if visited.exclude?(node)
```

PASTABA: Apibrėžta faile `active_support/core_ext/enumerable.rb`.


### `including`

Metodas [`including`][Enumerable#including] grąžina naują išskaičiuojamąjį, kuris įtraukia perduotus elementus:

```ruby
[ 1, 2, 3 ].including(4, 5)                    # => [ 1, 2, 3, 4, 5 ]
["David", "Rafael"].including %w[ Aaron Todd ] # => ["David", "Rafael", "Aaron", "Todd"]
```

PASTABA: Apibrėžta faile `active_support/core_ext/enumerable.rb`.


### `excluding`

Metodas [`excluding`][Enumerable#excluding] grąžina kopiją išskaičiuojamojo su pašalintais nurodytais elementais:

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
```

`excluding` yra sinonimas [`without`][Enumerable#without].

PASTABA: Apibrėžta faile `active_support/core_ext/enumerable.rb`.


### `pluck`

Metodas [`pluck`][Enumerable#pluck] išskiria duotą raktą iš kiekvieno elemento:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pluck(:id, :name) # => [[1, "David"], [2, "Rafael"]]
```

PASTABA: Apibrėžta faile `active_support/core_ext/enumerable.rb`.


### `pick`

Metodas [`pick`][Enumerable#pick] išskiria duotą raktą iš pirmojo elemento:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pick(:name) # => "David"
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pick(:id, :name) # => [1, "David"]
```

PASTABA: Apibrėžta faile `active_support/core_ext/enumerable.rb`.


Plėtiniai `Array`
---------------------

### Prieiga

Active Support papildo masyvų API, kad būtų lengviau juos pasiekti. Pavyzdžiui, [`to`][Array#to] grąžina submasyvą, kuris apima elementus iki perduoto indekso:

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

Panašiai, [`from`][Array#from] grąžina užpakalį nuo perduoto indekso iki galo. Jei indeksas yra didesnis nei masyvo ilgis, grąžinamas tuščias masyvas.

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

Metodas [`including`][Array#including] grąžina naują masyvą, kuris įtraukia perduotus elementus:

```ruby
[ 1, 2, 3 ].including(4, 5)          # => [ 1, 2, 3, 4, 5 ]
[ [ 0, 1 ] ].including([ [ 1, 0 ] ]) # => [ [ 0, 1 ], [ 1, 0 ] ]
```

Metodas [`excluding`][Array#excluding] grąžina kopiją masyvo be nurodytų elementų.
Tai yra `Enumerable#excluding` optimizacija, kuri naudoja `Array#-`
vietoje `Array#reject` dėl veikimo priežasčių.

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
[ [ 0, 1 ], [ 1, 0 ] ].excluding([ [ 1, 0 ] ])                  # => [ [ 0, 1 ] ]
```

Metodai [`second`][Array#second], [`third`][Array#third], [`fourth`][Array#fourth] ir [`fifth`][Array#fifth] grąžina atitinkamą elementą, taip pat kaip [`second_to_last`][Array#second_to_last] ir [`third_to_last`][Array#third_to_last] (`first` ir `last` yra įprasti). Dėka socialinės išminties ir teigiamo konstruktyvumo visur, taip pat yra prieinamas [`forty_two`][Array#forty_two].

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

PASTABA: Apibrėžta faile `active_support/core_ext/array/access.rb`.


### Išskyrimas

Metodas [`extract!`][Array#extract!] pašalina ir grąžina elementus, kuriems blokas grąžina `true` reikšmę.
Jeigu nėra pateiktas blokas, vietoj to grąžinamas `Enumerator`.

```ruby
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
numbers # => [0, 2, 4, 6, 8]
```
PASTABA: Apibrėžta `active_support/core_ext/array/extract.rb`.


### Parinkčių išskyrimas

Kai paskutinis argumentas metodų iškvietime yra maišos objektas, išskyrus `&block` argumentą, Ruby leidžia jums praleisti skliaustus:

```ruby
User.exists?(email: params[:email])
```

Tokį sintaksinį cukrų dažnai naudojama „Rails“ aplinkoje, kad būtų išvengta pozicinių argumentų, kai jų yra per daug, o vietoj to siūlomos sąsajos, kurios imituoja vardinius parametrus. Ypač įprasta naudoti paskutinį maišos objektą parinktims.

Tačiau, jei metodas tikisi kintamo skaičiaus argumentų ir jo deklaracijoje naudoja `*`, toks parinkčių maišas tampa argumentų masyvo elementu, kur praranda savo vaidmenį.

Tokiais atvejais galite maišo objektui suteikti išskirtinį apdorojimą naudodami [`extract_options!`][Array#extract_options!]. Šis metodas patikrina masyvo paskutinio elemento tipą. Jei tai yra maiša, jis jį išima ir grąžina, kitu atveju grąžina tuščią maišą.

Pavyzdžiui, pažvelkime į `caches_action` valdiklio makro apibrėžimą:

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  # ...
end
```

Šis metodas priima bet kokį veiksmų pavadinimų skaičių ir pasirinktinį parinkčių maišą kaip paskutinį argumentą. Iškvietus `extract_options!` gausite parinkčių maišą ir jį pašalinsite iš `actions` paprastu ir aiškiu būdu.

PASTABA: Apibrėžta `active_support/core_ext/array/extract_options.rb`.


### Konversijos

#### `to_sentence`

Metodas [`to_sentence`][Array#to_sentence] paverčia masyvą į eilutę, kuriame išvardijami jo elementai:

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

Šis metodas priima tris parinktis:

* `:two_words_connector`: Kas naudojama dviejų elementų masyvams. Numatytasis reikšmė yra " and ".
* `:words_connector`: Kas naudojama sujungti masyvo elementus, kai jų yra 3 ar daugiau, išskyrus paskutinius du. Numatytasis reikšmė yra ", ".
* `:last_word_connector`: Kas naudojama sujungti paskutinius masyvo elementus, kai jų yra 3 ar daugiau. Numatytasis reikšmė yra ", and ".

Šių parinkčių numatytosios reikšmės gali būti lokalizuotos, jų raktai yra:

| Parinktis                 | I18n raktas                                |
| ------------------------- | ------------------------------------------ |
| `:two_words_connector`    | `support.array.two_words_connector`        |
| `:words_connector`        | `support.array.words_connector`            |
| `:last_word_connector`    | `support.array.last_word_connector`        |

PASTABA: Apibrėžta `active_support/core_ext/array/conversions.rb`.


#### `to_fs`

Metodas [`to_fs`][Array#to_fs] pagal numatytuosius nustatymus veikia kaip `to_s`.

Tačiau, jei masyvas turi elementus, kurie atsako į `id`, gali būti perduotas simbolis
`:db` kaip argumentas. Tai dažniausiai naudojama su
„Active Record“ objektų kolekcijomis. Grąžinamos eilutės yra:

```ruby
[].to_fs(:db)            # => "null"
[user].to_fs(:db)        # => "8456"
invoice.lines.to_fs(:db) # => "23,567,556,12"
```

Pavyzdžio viršuje esantys sveikieji skaičiai turėtų būti gauti iš atitinkamų `id` iškvietimų.

PASTABA: Apibrėžta `active_support/core_ext/array/conversions.rb`.


#### `to_xml`

Metodas [`to_xml`][Array#to_xml] grąžina eilutę, kuriame yra jo gavėjo XML atvaizdavimas:

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

Tam jis siunčia `to_xml` kiekvienam elementui iš eilės ir renka rezultatus po šakninio mazgo. Visi elementai turi atsakyti į `to_xml`, kitu atveju iškeliama išimtis.

Numatytasis šakninio elemento pavadinimas yra pirmojo elemento klasės pavadinimo su pabraukimu ir brūkšneliu daugiskaita, jei likusieji elementai priklauso tam pačiam tipui (patikrinama su `is_a?`) ir jie nėra maišos objektai. Pavyzdyje tai yra „contributors“.

Jei yra bent vienas elementas, kuris nepriklauso pirmojo elemento tipui, šakninis mazgas tampa „objects“:
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

Jei gavėjas yra halių masyvas, pagrindinis elementas pagal numatytuosius nustatymus taip pat yra "objects":

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

ĮSPĖJIMAS. Jei kolekcija yra tuščia, pagrindinis elementas pagal numatytuosius nustatymus yra "nil-classes". Tai yra gudrybė, pavyzdžiui, aukščiau pateikto kontributorių sąrašo pagrindinis elementas nebūtų "contributors", jei kolekcija būtų tuščia, bet "nil-classes". Galite naudoti `:root` parinktį, kad užtikrintumėte nuoseklų pagrindinį elementą.

Vaikų mazgų pavadinimas pagal numatytuosius nustatymus yra pagrindinio mazgo pavadinimas, kuris yra pavienis. Pavyzdžiuose aukščiau matėme "contributor" ir "object". Parinktis `:children` leidžia nustatyti šiuos mazgų pavadinimus.

Numatytasis XML kūrėjas yra naujas `Builder::XmlMarkup` egzempliorius. Galite konfigūruoti savo kūrėją naudodami `:builder` parinktį. Metodas taip pat priima parinktis, pvz., `:dasherize` ir kt., kurios yra perduodamos kūrėjui:

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
* Kitu atveju, jei argumentas gali atlikti `to_ary`, jis yra iškviestas, ir jei `to_ary` grąžinimo reikšmė nėra `nil`, ji yra grąžinama.
* Kitu atveju, grąžinamas masyvas su argumentu kaip vieninteliu elementu.

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

Šis metodas panašus tikslui į `Kernel#Array`, tačiau yra keletas skirtumų:

* Jei argumentas gali atlikti `to_ary`, metodas yra iškviečiamas. `Kernel#Array` tęsia bandymą išbandyti `to_a`, jei grąžinta reikšmė yra `nil`, bet `Array.wrap` iš karto grąžina masyvą su argumentu kaip vieninteliu elementu.
* Jei grąžinta reikšmė iš `to_ary` nėra nei `nil`, nei `Array` objektas, `Kernel#Array` iškelia išimtį, o `Array.wrap` to nedaro, ji tiesiog grąžina reikšmę.
* Jei argumentas negali atlikti `to_ary`, ji nekviečia `to_a`, jei argumentas negali atlikti `to_ary`, ji grąžina masyvą su argumentu kaip vieninteliu elementu.

Ypač verta palyginti paskutinį punktą kai kuriems skaičiuojamiems objektams:

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
rekursyviai naudojant Active Support metodo `Object#deep_dup`. Tai veikia kaip `Array#map`, siunčiant `deep_dup` metodą kiekvienam objektui viduje.

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

PASTABA: Apibrėžta `active_support/core_ext/object/deep_dup.rb`.


### Grupavimas

#### `in_groups_of(number, fill_with = nil)`

Metodas [`in_groups_of`][Array#in_groups_of] padalina masyvą į nuoseklius grupes tam tikro dydžio. Grąžinamas masyvas su grupėmis:

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

arba grąžina juos vienu metu, jei perduodamas blokas:

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

Pirmasis pavyzdys parodo, kaip `in_groups_of` užpildo paskutinę grupę tiek `nil` elementais, kiek reikia, kad būtų pasiektas norimas dydis. Galite pakeisti šį užpildymo reikšmę naudodami antrąjį pasirinktinį argumentą:

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

Ir galite nurodyti metodui, kad paskutinė grupė nebūtų užpildyta, perduodant `false`:

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

Dėl to `false` negali būti naudojama kaip užpildymo reikšmė.

PASTABA: Apibrėžta `active_support/core_ext/array/grouping.rb`.


#### `in_groups(number, fill_with = nil)`

Metodas [`in_groups`][Array#in_groups] padalina masyvą į tam tikrą grupių skaičių. Metodas grąžina masyvą su grupėmis:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

arba grąžina juos vienu metu, jei perduodamas blokas:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) { |group| p group }
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

Aukščiau pateikti pavyzdžiai rodo, kad `in_groups` užpildo kai kurias grupes su papildomu `nil` elementu, jei reikia. Grupė gali gauti daugiausia vieną šio papildomo elemento, jei toks yra. Ir grupės, kuriose jie yra, visada yra paskutinės.

Galite pakeisti šią užpildymo reikšmę naudodami antrąjį pasirinktinį argumentą:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

Ir galite nurodyti metodui, kad mažesnės grupės nebūtų užpildytos, perduodant `false`:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

Dėl to `false` negali būti naudojama kaip užpildymo reikšmė.

PASTABA: Apibrėžta `active_support/core_ext/array/grouping.rb`.


#### `split(value = nil)`

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


`Hash` plėtiniai
--------------------

### Konversijos

#### `to_xml`

Metodas [`to_xml`][Hash#to_xml] grąžina eilutę, kuriame yra jo gavėjo XML reprezentacija:

```ruby
{ foo: 1, bar: 2 }.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```

Tam tikslui metodas eina per poras ir kuria priklauso nuo _reikšmių_. Turint porą `key`, `value`:

* Jei `value` yra `Hash`, vykdomas rekursyvus kvietimas su `key` kaip `:root`.

* Jei `value` yra masyvas, vykdomas rekursyvus kvietimas su `key` kaip `:root`, ir `key` vienaskaitinė kaip `:children`.

* Jei `value` yra iškviečiamas objektas, jis turi tikėtis vieno ar dviejų argumentų. Priklausomai nuo aukščio, iškviečiamas objektas su `options` maišu kaip pirmuoju argumentu, kuriame `key` yra `:root`, ir `key` vienaskaitinė kaip antruoju argumentu. Jo grąžinimo reikšmė tampa nauju mazgu.

* Jei `value` atsako į `to_xml`, vykdomas metodas su `key` kaip `:root`.

* Kitu atveju, sukuriamas mazgas su `key` kaip žyma ir `value` teksto mazgu su teksto reprezentacija. Jei `value` yra `nil`, pridedamas atributas "nil", nustatytas į "true". Jei nėra pasirinkimo `:skip_types` ir jis yra tiesa, taip pat pridedamas atributas "type" pagal šią atitikmenų schemą:
```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "simbolis",
  "Integer"    => "sveikasis skaičius",
  "BigDecimal" => "skaičius su fiksuotu tikslumu",
  "Float"      => "slankiojo kablelio skaičius",
  "TrueClass"  => "logine reikšmė",
  "FalseClass" => "logine reikšmė",
  "Date"       => "data",
  "DateTime"   => "datos ir laiko reikšmė",
  "Time"       => "datos ir laiko reikšmė"
}
```

Pagal numatytąjį šakninis mazgas yra "hash", tačiau tai galima konfigūruoti naudojant `:root` parinktį.

Numatytasis XML kūrėjas yra naujas `Builder::XmlMarkup` objektas. Galite konfigūruoti savo kūrėją naudodami `:builder` parinktį. Metodas taip pat priima parinktis, pvz., `:dasherize`, kurios yra perduodamos kūrėjui.

PASTABA: Apibrėžta `active_support/core_ext/hash/conversions.rb` faile.


### Sujungimas

Ruby turi įmontuotą `Hash#merge` metodą, kuris sujungia du masyvus:

```ruby
{ a: 1, b: 1 }.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support apibrėžia keletą būdų, kaip sujungti masyvus, kas gali būti patogu.

#### `reverse_merge` ir `reverse_merge!`

Atveju, kai yra konfliktas, `merge` metode laimi argumento masyvo raktas. Galite palaikyti parinkčių masyvus su numatytosiomis reikšmėmis kompaktišku būdu naudojant šią idiomą:

```ruby
options = { length: 30, omission: "..." }.merge(options)
```

Active Support apibrėžia [`reverse_merge`][Hash#reverse_merge] atveju, jei pageidaujate naudoti šią alternatyvią sintaksę:

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

Taip pat yra bang versija [`reverse_merge!`][Hash#reverse_merge!], kuri atlieka sujungimą vietoje:

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

ĮSPĖJIMAS. Atkreipkite dėmesį, kad `reverse_merge!` gali pakeisti masyvą iškviečiančiame metode, kas gali būti gera arba bloga idėja.

PASTABA: Apibrėžta `active_support/core_ext/hash/reverse_merge.rb` faile.


#### `reverse_update`

Metodas [`reverse_update`][Hash#reverse_update] yra sinonimas `reverse_merge!`, kuris buvo paaiškintas aukščiau.

ĮSPĖJIMAS. Atkreipkite dėmesį, kad `reverse_update` neturi bang simbolio.

PASTABA: Apibrėžta `active_support/core_ext/hash/reverse_merge.rb` faile.


#### `deep_merge` ir `deep_merge!`

Kaip matote ankstesniame pavyzdyje, jei raktas yra rastas abiejuose masyvuose, reikšmė iš argumento masyvo laimi.

Active Support apibrėžia [`Hash#deep_merge`][Hash#deep_merge]. Giliame sujungime, jei raktas yra rastas abiejuose masyvuose ir jų reikšmės yra vėl masyvai, tada jų _sujungimas_ tampa rezultuojančio masyvo reikšme:

```ruby
{ a: { b: 1 } }.deep_merge(a: { c: 2 })
# => {:a=>{:b=>1, :c=>2}}
```

Metodas [`deep_merge!`][Hash#deep_merge!] atlieka gilų sujungimą vietoje.

PASTABA: Apibrėžta `active_support/core_ext/hash/deep_merge.rb` faile.


### Gili kopija

Metodas [`Hash#deep_dup`][Hash#deep_dup] dubliuoja patį save ir visus raktus bei reikšmes
viduje rekursyviai naudojant Active Support metodo `Object#deep_dup`. Tai veikia kaip `Enumerator#each_with_object`, siunčiant `deep_dup` metodą kiekvienai porai viduje.

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

PASTABA: Apibrėžta `active_support/core_ext/object/deep_dup.rb` faile.


### Darbas su raktų

#### `except` ir `except!`

Metodas [`except`][Hash#except] grąžina masyvą, iš kurio pašalinti argumentų sąraše esančius raktus, jei jie yra:

```ruby
{ a: 1, b: 2 }.except(:a) # => {:b=>2}
```

Jei gavėjas gali atlikti `convert_key` metodą, šis metodas yra iškviestas kiekvienam argumentui. Tai leidžia `except` metodui veikti su masyvais, kurie turi abejonių dėl prieigos, pvz.,:

```ruby
{ a: 1 }.with_indifferent_access.except(:a)  # => {}
{ a: 1 }.with_indifferent_access.except("a") # => {}
```

Taip pat yra bang variantas [`except!`][Hash#except!], kuris pašalina raktus vietoje.

PASTABA: Apibrėžta `active_support/core_ext/hash/except.rb` faile.


#### `stringify_keys` ir `stringify_keys!`

Metodas [`stringify_keys`][Hash#stringify_keys] grąžina masyvą, kuriame yra raktų stringifikuota versija gavėjui. Tai padaro siunčiant `to_s` jiems:

```ruby
{ nil => nil, 1 => 1, a: :a }.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

Atveju, kai yra raktų susidūrimas, reikšmė bus ta, kuri buvo paskutinė įterpta į masyvą:

```ruby
{ "a" => 1, a: 2 }.stringify_keys
# Rezultatas bus
# => {"a"=>2}
```
Šis metodas gali būti naudingas, pavyzdžiui, norint lengvai priimti tiek simbolius, tiek eilutes kaip parinktis. Pavyzdžiui, `ActionView::Helpers::FormHelper` apibrėžia:

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  # ...
end
```

Antra eilutė saugiai gali pasiekti "type" raktą ir leisti vartotojui perduoti tiek `:type`, tiek "type".

Yra ir bang variantas [`stringify_keys!`][Hash#stringify_keys!], kuris vietoje stringifikuojama raktus.

Be to, galima naudoti [`deep_stringify_keys`][Hash#deep_stringify_keys] ir [`deep_stringify_keys!`][Hash#deep_stringify_keys!], kad stringifikuotumėte visus raktus duotame haše ir visuose jame įdėtuose hašuose. Pavyzdys rezultato yra:

```ruby
{ nil => nil, 1 => 1, nested: { a: 3, 5 => 5 } }.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

PASTABA: Apibrėžta `active_support/core_ext/hash/keys.rb`.


#### `symbolize_keys` ir `symbolize_keys!`

Metodas [`symbolize_keys`][Hash#symbolize_keys] grąžina hašą, kuriame raktai yra simbolizuoti, jei tai įmanoma. Tai daroma siunčiant jiems `to_sym`:

```ruby
{ nil => nil, 1 => 1, "a" => "a" }.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

ĮSPĖJIMAS. Pastaba, kad ankstesniame pavyzdyje buvo simbolizuotas tik vienas raktas.

Atveju, kai yra raktų susidūrimas, reikšmė bus ta, kuri buvo neseniai įdėta į hašą:

```ruby
{ "a" => 1, a: 2 }.symbolize_keys
# => {:a=>2}
```

Šis metodas gali būti naudingas, pavyzdžiui, norint lengvai priimti tiek simbolius, tiek eilutes kaip parinktis. Pavyzdžiui, `ActionText::TagHelper` apibrėžia

```ruby
def rich_text_area_tag(name, value = nil, options = {})
  options = options.symbolize_keys

  options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
  # ...
end
```

Trečioji eilutė saugiai gali pasiekti `:input` raktą ir leisti vartotojui perduoti tiek `:input`, tiek "input".

Yra ir bang variantas [`symbolize_keys!`][Hash#symbolize_keys!], kuris simbolizuoja raktus vietoje.

Be to, galima naudoti [`deep_symbolize_keys`][Hash#deep_symbolize_keys] ir [`deep_symbolize_keys!`][Hash#deep_symbolize_keys!], kad simbolizuotumėte visus raktus duotame haše ir visuose jame įdėtuose hašuose. Pavyzdys rezultato yra:

```ruby
{ nil => nil, 1 => 1, "nested" => { "a" => 3, 5 => 5 } }.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

PASTABA: Apibrėžta `active_support/core_ext/hash/keys.rb`.


#### `to_options` ir `to_options!`

Metodai [`to_options`][Hash#to_options] ir [`to_options!`][Hash#to_options!] yra sinonimai `symbolize_keys` ir `symbolize_keys!` atitinkamai.

PASTABA: Apibrėžta `active_support/core_ext/hash/keys.rb`.


#### `assert_valid_keys`

Metodas [`assert_valid_keys`][Hash#assert_valid_keys] priima bet kokį skaičių argumentų ir patikrina, ar priėmėjas neturi jokių raktų, kurie nėra sąraše. Jei taip, išmetamas `ArgumentError`.

```ruby
{ a: 1 }.assert_valid_keys(:a)  # praeina
{ a: 1 }.assert_valid_keys("a") # ArgumentError
```

Active Record nepriima nežinomų parinkčių, kuriant asociacijas, pavyzdžiui. Tai įgyvendina kontrolę per `assert_valid_keys`.

PASTABA: Apibrėžta `active_support/core_ext/hash/keys.rb`.


### Darbas su reikšmėmis

#### `deep_transform_values` ir `deep_transform_values!`

Metodas [`deep_transform_values`][Hash#deep_transform_values] grąžina naują hašą, kuriame visos reikšmės yra konvertuojamos naudojant bloko operaciją. Tai apima reikšmes iš šakninio hašo ir visų įdėtų hašų ir masyvų.

```ruby
hash = { person: { name: 'Rob', age: '28' } }

hash.deep_transform_values { |value| value.to_s.upcase }
# => {person: {name: "ROB", age: "28"}}
```

Yra ir bang variantas [`deep_transform_values!`][Hash#deep_transform_values!], kuris sunaikina visus reikšmes, naudodamas bloko operaciją.

PASTABA: Apibrėžta `active_support/core_ext/hash/deep_transform_values.rb`.


### Išpjovimas

Metodas [`slice!`][Hash#slice!] pakeičia hašą tik su duotais raktais ir grąžina hašą, kuriame yra pašalinti raktų/vertės poros.

```ruby
hash = { a: 1, b: 2 }
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

PASTABA: Apibrėžta `active_support/core_ext/hash/slice.rb`.


### Ištraukimas

Metodas [`extract!`][Hash#extract!] pašalina ir grąžina raktų/vertės poras, atitinkančias duotus raktus.

```ruby
hash = { a: 1, b: 2 }
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

Metodas `extract!` grąžina tą pačią `Hash` klasės subklasę, kokia yra priėmėjas.
```ruby
hash = { a: 1, b: 2 }.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

PASTABA: Apibrėžta `active_support/core_ext/hash/slice.rb`.


### Neatskiriamas prieiga

Metodas [`with_indifferent_access`][Hash#with_indifferent_access] grąžina [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] iš savo gavėjo:

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

PASTABA: Apibrėžta `active_support/core_ext/hash/indifferent_access.rb`.


Plėtiniai `Regexp`
----------------------

### `multiline?`

Metodas [`multiline?`][Regexp#multiline?] nurodo, ar reguliariam išraiškai yra nustatytas `/m` vėliavėlė, t. y. ar taškas atitinka naujas eilutes.

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails naudoja šį metodą tik vienoje vietoje, taip pat maršrutizavimo kode. Daugiainės eilutės reguliariosios išraiškos maršrutų reikalavimams yra draudžiamos, o ši vėliavėlė palengvina šios sąlygos taikymą.

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

Active Support apibrėžia `Range#to_fs` kaip alternatyvą `to_s`, kuri supranta pasirinktinį formato argumentą. Šiuo metu palaikomas tik neprivalomas `:db` formatas:

```ruby
(Date.today..Date.tomorrow).to_fs
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_fs(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

Kaip pavyzdys iliustruoja, `:db` formatas generuoja `BETWEEN` SQL sąlygą. Tai naudojama Active Record, palaikant diapazono reikšmes sąlygose.

PASTABA: Apibrėžta `active_support/core_ext/range/conversions.rb`.

### `===` ir `include?`

Metodai `Range#===` ir `Range#include?` nurodo, ar tam tikra reikšmė patenka tarp duotų intervalo galų:

```ruby
(2..3).include?(Math::E) # => true
```

Active Support išplečia šiuos metodus, kad argumentas galėtų būti ir kitas intervalas. Tokiu atveju patikriname, ar argumento intervalo galai patenka į patį gavėjo intervalą:

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

INFO: Šie skaičiavimo metodai turi ribinius atvejus 1582 m. spalio mėnesį, nes dienos 5..14 tiesiog neegzistuoja. Šis vadovas dėl konspekto neaprašo jų elgesio šiuose dienose, tačiau pakanka pasakyti, kad jie daro tai, ko tikėtasi. Tai reiškia, kad `Date.new(1582, 10, 4).tomorrow` grąžina `Date.new(1582, 10, 15)` ir t. t. Norėdami sužinoti tikėtiną elgesį, patikrinkite `test/core_ext/date_ext_test.rb` Active Support testų rinkinyje.

#### `Date.current`

Active Support apibrėžia [`Date.current`][Date.current] kaip šiandienos datą esamoje laiko juostoje. Tai yra kaip `Date.today`, tik jei apibrėžta naudotojo laiko juosta, ji ją gerbia. Taip pat apibrėžia [`Date.yesterday`][Date.yesterday] ir [`Date.tomorrow`][Date.tomorrow], ir instancijos predikatus [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?], [`future?`][DateAndTime::Calculations#future?], [`on_weekday?`][DateAndTime::Calculations#on_weekday?] ir [`on_weekend?`][DateAndTime::Calculations#on_weekend?], visi jie yra susiję su `Date.current`.

Lyginant datas naudojant metodus, kurie gerbia naudotojo laiko juostą, įsitikinkite, kad naudojate `Date.current`, o ne `Date.today`. Yra atvejų, kai naudotojo laiko juosta gali būti ateityje, palyginti su sistemos laiko juosta, kurią pagal numatytuosius nustatymus naudoja `Date.today`. Tai reiškia, kad `Date.today` gali būti lygus `Date.yesterday`.

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

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb` faile.


##### `monday`, `sunday`

Metodai [`monday`][DateAndTime::Calculations#monday] ir [`sunday`][DateAndTime::Calculations#sunday] grąžina ankstesnio pirmadienio ir kitos sekmadienio datą atitinkamai.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.monday                     # => Mon, 03 May 2010
d.sunday                     # => Sun, 09 May 2010

d = Date.new(2012, 9, 10)    # => Mon, 10 Sep 2012
d.monday                     # => Mon, 10 Sep 2012

d = Date.new(2012, 9, 16)    # => Sun, 16 Sep 2012
d.sunday                     # => Sun, 16 Sep 2012
```

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb` faile.


##### `prev_week`, `next_week`

Metodas [`next_week`][DateAndTime::Calculations#next_week] priima simbolį su savaitės dienos pavadinimu anglų kalba (pagal nutylėjimą yra gijos vietinės [`Date.beginning_of_week`][Date.beginning_of_week] arba [`config.beginning_of_week`][], arba `:monday`) ir grąžina atitinkamą datą.

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.next_week              # => Mon, 10 May 2010
d.next_week(:saturday)   # => Sat, 15 May 2010
```

Metodas [`prev_week`][DateAndTime::Calculations#prev_week] yra analogiškas:

```ruby
d.prev_week              # => Mon, 26 Apr 2010
d.prev_week(:saturday)   # => Sat, 01 May 2010
d.prev_week(:friday)     # => Fri, 30 Apr 2010
```

`prev_week` yra sinonimas [`last_week`][DateAndTime::Calculations#last_week].

Abu metodai `next_week` ir `prev_week` veikia kaip tikėtasi, kai nustatyti `Date.beginning_of_week` arba `config.beginning_of_week`.

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb` faile.


##### `beginning_of_month`, `end_of_month`

Metodai [`beginning_of_month`][DateAndTime::Calculations#beginning_of_month] ir [`end_of_month`][DateAndTime::Calculations#end_of_month] grąžina mėnesio pradžios ir pabaigos datą atitinkamai:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_month     # => Sat, 01 May 2010
d.end_of_month           # => Mon, 31 May 2010
```

`beginning_of_month` yra sinonimas [`at_beginning_of_month`][DateAndTime::Calculations#at_beginning_of_month], o `end_of_month` yra sinonimas [`at_end_of_month`][DateAndTime::Calculations#at_end_of_month].

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb` faile.


##### `quarter`, `beginning_of_quarter`, `end_of_quarter`

Metodas [`quarter`][DateAndTime::Calculations#quarter] grąžina gavėjo kalendorinio metų ketvirtį:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.quarter                # => 2
```

Metodai [`beginning_of_quarter`][DateAndTime::Calculations#beginning_of_quarter] ir [`end_of_quarter`][DateAndTime::Calculations#end_of_quarter] grąžina ketvirčio pradžios ir pabaigos datą atitinkamai gavėjo kalendorinio metų:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_quarter   # => Thu, 01 Apr 2010
d.end_of_quarter         # => Wed, 30 Jun 2010
```

`beginning_of_quarter` yra sinonimas [`at_beginning_of_quarter`][DateAndTime::Calculations#at_beginning_of_quarter], o `end_of_quarter` yra sinonimas [`at_end_of_quarter`][DateAndTime::Calculations#at_end_of_quarter].

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb` faile.


##### `beginning_of_year`, `end_of_year`

Metodai [`beginning_of_year`][DateAndTime::Calculations#beginning_of_year] ir [`end_of_year`][DateAndTime::Calculations#end_of_year] grąžina metų pradžios ir pabaigos datą atitinkamai:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_year      # => Fri, 01 Jan 2010
d.end_of_year            # => Fri, 31 Dec 2010
```

`beginning_of_year` yra sinonimas [`at_beginning_of_year`][DateAndTime::Calculations#at_beginning_of_year], o `end_of_year` yra sinonimas [`at_end_of_year`][DateAndTime::Calculations#at_end_of_year].

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb` faile.


#### Kiti datos skaičiavimai

##### `years_ago`, `years_since`

Metodas [`years_ago`][DateAndTime::Calculations#years_ago] priima metų skaičių ir grąžina tą pačią datą tiek metų atgal:

```ruby
date = Date.new(2010, 6, 7)
date.years_ago(10) # => Wed, 07 Jun 2000
```

[`years_since`][DateAndTime::Calculations#years_since] juda į priekį laike:

```ruby
date = Date.new(2010, 6, 7)
date.years_since(10) # => Sun, 07 Jun 2020
```

Jei tokia diena neegzistuoja, grąžinama atitinkamo mėnesio paskutinė diena:

```ruby
Date.new(2012, 2, 29).years_ago(3)     # => Sat, 28 Feb 2009
Date.new(2012, 2, 29).years_since(3)   # => Sat, 28 Feb 2015
```

[`last_year`][DateAndTime::Calculations#last_year] yra trumpinys `#years_ago(1)`.

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb` faile.


##### `months_ago`, `months_since`

Metodai [`months_ago`][DateAndTime::Calculations#months_ago] ir [`months_since`][DateAndTime::Calculations#months_since] veikia analogiškai mėnesiams:

```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sun, 28 Feb 2010
Date.new(2010, 4, 30).months_since(2) # => Wed, 30 Jun 2010
```

Jei tokia diena neegzistuoja, grąžinama atitinkamo mėnesio paskutinė diena:

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sun, 28 Feb 2010
Date.new(2009, 12, 31).months_since(2) # => Sun, 28 Feb 2010
```

[`last_month`][DateAndTime::Calculations#last_month] yra trumpinys `#months_ago(1)`.
PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb`.


##### `weeks_ago`

Metodas [`weeks_ago`][DateAndTime::Calculations#weeks_ago] veikia analogiškai savaitėms:

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Mon, 17 May 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Mon, 10 May 2010
```

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb`.


##### `advance`

Bendriausias būdas pereiti prie kitų dienų yra [`advance`][Date#advance]. Šis metodas priima maišą su raktų `:years`, `:months`, `:weeks`, `:days` ir grąžina datą, kuri yra tiek pat pažengusi, kiek nurodyti raktai:

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Mon, 20 Jun 2011
date.advance(months: 2, days: -2) # => Wed, 04 Aug 2010
```

Pastaba ankstesniame pavyzdyje, kad padidinimai gali būti neigiami.

PASTABA: Apibrėžta `active_support/core_ext/date/calculations.rb`.


#### Komponentų keitimas

Metodas [`change`][Date#change] leidžia gauti naują datą, kuri yra tokia pati kaip gavėjas, išskyrus nurodytus metus, mėnesį ar dieną:

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Wed, 23 Nov 2011
```

Šis metodas netoleruoja neegzistuojančių datų, jei keitimas yra neteisingas, išmetamas `ArgumentError`:

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: invalid date
```

PASTABA: Apibrėžta `active_support/core_ext/date/calculations.rb`.


#### Trukmės

[`Duration`][ActiveSupport::Duration] objektai gali būti pridėti arba atimti iš datų:

```ruby
d = Date.current
# => Mon, 09 Aug 2010
d + 1.year
# => Tue, 09 Aug 2011
d - 3.hours
# => Sun, 08 Aug 2010 21:00:00 UTC +00:00
```

Jie verčiami į `since` arba `advance` kvietimus. Pavyzdžiui, čia gauname teisingą kalendoriaus reformos šuolį:

```ruby
Date.new(1582, 10, 4) + 1.day
# => Fri, 15 Oct 1582
```


#### Laiko žymos

INFO: Jei įmanoma, šie metodai grąžina `Time` objektą, kitu atveju `DateTime`. Jei nustatyta, jie gerbia naudotojo laiko juostą.

##### `beginning_of_day`, `end_of_day`

Metodas [`beginning_of_day`][Date#beginning_of_day] grąžina laiko žymą dienos pradžioje (00:00:00):

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Mon Jun 07 00:00:00 +0200 2010
```

Metodas [`end_of_day`][Date#end_of_day] grąžina laiko žymą dienos pabaigoje (23:59:59):

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Mon Jun 07 23:59:59 +0200 2010
```

`beginning_of_day` yra sinonimas [`at_beginning_of_day`][Date#at_beginning_of_day], [`midnight`][Date#midnight], [`at_midnight`][Date#at_midnight].

PASTABA: Apibrėžta `active_support/core_ext/date/calculations.rb`.


##### `beginning_of_hour`, `end_of_hour`

Metodas [`beginning_of_hour`][DateTime#beginning_of_hour] grąžina laiko žymą valandos pradžioje (hh:00:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Mon Jun 07 19:00:00 +0200 2010
```

Metodas [`end_of_hour`][DateTime#end_of_hour] grąžina laiko žymą valandos pabaigoje (hh:59:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Mon Jun 07 19:59:59 +0200 2010
```

`beginning_of_hour` yra sinonimas [`at_beginning_of_hour`][DateTime#at_beginning_of_hour].

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.

##### `beginning_of_minute`, `end_of_minute`

Metodas [`beginning_of_minute`][DateTime#beginning_of_minute] grąžina laiko žymą minutės pradžioje (hh:mm:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Mon Jun 07 19:55:00 +0200 2010
```

Metodas [`end_of_minute`][DateTime#end_of_minute] grąžina laiko žymą minutės pabaigoje (hh:mm:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Mon Jun 07 19:55:59 +0200 2010
```

`beginning_of_minute` yra sinonimas [`at_beginning_of_minute`][DateTime#at_beginning_of_minute].

INFO: `beginning_of_hour`, `end_of_hour`, `beginning_of_minute` ir `end_of_minute` yra įgyvendinti `Time` ir `DateTime`, bet **ne** `Date`, nes neturi prasmės prašyti valandos ar minutės pradžios ar pabaigos `Date` egzemplioriuje.

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


##### `ago`, `since`

Metodas [`ago`][Date#ago] priima sekundžių skaičių kaip argumentą ir grąžina laiko žymą tiek sekundžių praeityje nuo vidurnakčio:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.ago(1)         # => Thu, 10 Jun 2010 23:59:59 EDT -04:00
```

Panašiai, [`since`][Date#since] juda į priekį:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.since(1)       # => Fri, 11 Jun 2010 00:00:01 EDT -04:00
```
PASTABA: Apibrėžta `active_support/core_ext/date/calculations.rb`.


Plėtiniai `DateTime`
------------------------

ĮSPĖJIMAS: `DateTime` nėra informuotas apie DST taisykles, todėl kai vyksta DST keitimas, kai kurie iš šių metodų turi ribines sąlygas. Pavyzdžiui, [`seconds_since_midnight`][DateTime#seconds_since_midnight] gali grąžinti netikrą kiekį tokią dieną.

### Skaičiavimai

Klasė `DateTime` yra `Date` po-klasė, todėl įkeliant `active_support/core_ext/date/calculations.rb`, paveldite šiuos metodus ir jų sinonimus, išskyrus tai, kad jie visada grąžins datetimes.

Šie metodai yra perkelti, todėl **ne**reikia įkelti `active_support/core_ext/date/calculations.rb` šiems:

* [`beginning_of_day`][DateTime#beginning_of_day] / [`midnight`][DateTime#midnight] / [`at_midnight`][DateTime#at_midnight] / [`at_beginning_of_day`][DateTime#at_beginning_of_day]
* [`end_of_day`][DateTime#end_of_day]
* [`ago`][DateTime#ago]
* [`since`][DateTime#since] / [`in`][DateTime#in]

Kita vertus, [`advance`][DateTime#advance] ir [`change`][DateTime#change] taip pat yra apibrėžti ir palaiko daugiau parinkčių, jie yra aprašyti žemiau.

Šie metodai yra apibrėžti tik `active_support/core_ext/date_time/calculations.rb`, nes jie turi prasmę tik naudojant `DateTime` egzempliorių:

* [`beginning_of_hour`][DateTime#beginning_of_hour] / [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]
* [`end_of_hour`][DateTime#end_of_hour]


#### Pavadinami Datetime'ai

##### `DateTime.current`

Active Support apibrėžia [`DateTime.current`][DateTime.current] kaip `Time.now.to_datetime`, išskyrus tai, kad jis gerbia naudotojo laiko juostą, jei apibrėžta. Egzemplioriaus predikatai [`past?`][DateAndTime::Calculations#past?] ir [`future?`][DateAndTime::Calculations#future?] yra apibrėžti atsižvelgiant į `DateTime.current`.

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


#### Kiti plėtiniai

##### `seconds_since_midnight`

Metodas [`seconds_since_midnight`][DateTime#seconds_since_midnight] grąžina sekundžių skaičių nuo vidurnakčio:

```ruby
now = DateTime.current     # => Mon, 07 Jun 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


##### `utc`

Metodas [`utc`][DateTime#utc] suteikia jums tą patį datetime gavėjo išreikštą UTC.

```ruby
now = DateTime.current # => Mon, 07 Jun 2010 19:27:52 -0400
now.utc                # => Mon, 07 Jun 2010 23:27:52 +0000
```

Šis metodas taip pat yra sinonimas [`getutc`][DateTime#getutc].

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


##### `utc?`

Predikatas [`utc?`][DateTime#utc?] nurodo, ar gavėjas turi UTC kaip savo laiko juostą:

```ruby
now = DateTime.now # => Mon, 07 Jun 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


##### `advance`

Bendriausias būdas pereiti prie kito datetime yra [`advance`][DateTime#advance]. Šis metodas gauna maišą su raktiniais žodžiais `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes` ir `:seconds`, ir grąžina datetime, kuris yra pažengęs tiek, kiek dabartiniai raktiniai žodžiai nurodo.

```ruby
d = DateTime.current
# => Thu, 05 Aug 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => Tue, 06 Sep 2011 12:34:32 +0000
```

Šis metodas pirmiausia apskaičiuoja paskirties datą, perduodamas `:years`, `:months`, `:weeks` ir `:days` į `Date#advance`, kuris yra aprašytas aukščiau. Po to jis sureguliuoja laiką, iškviesdamas [`since`][DateTime#since] su sekundžių skaičiumi, kurį reikia pažengti. Ši tvarka yra svarbi, skirtinga tvarka duotų skirtingus datetimes kai kuriuose ribiniuose atvejuose. Pavyzdys `Date#advance` taikomas, ir galime jį išplėsti, kad parodytume tvarkos svarbą, susijusią su laiko bitais.

Jei pirmiausia perkelsime datos bitus (kurie taip pat turi santykinę tvarką, kaip ir anksčiau aprašyta), o tada laiko bitus, gauname pavyzdžiui šį skaičiavimą:

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sun, 28 Feb 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Mon, 29 Mar 2010 00:00:00 +0000
```

bet jei juos apskaičiuotume atvirkščiai, rezultatas būtų skirtingas:

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Thu, 01 Apr 2010 00:00:00 +0000
```

ĮSPĖJIMAS: Kadangi `DateTime` nėra DST informuotas, galite patekti į neegzistuojantį laiko tašką be jokio įspėjimo ar klaidos, kuri jums tai praneštų.

PASTABA: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


#### Komponentų keitimas

Metodas [`change`][DateTime#change] leidžia gauti naują datetime, kuris yra tas pats kaip gavėjas, išskyrus duotus parametrus, kurie gali apimti `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start`:

```ruby
now = DateTime.current
# => Tue, 08 Jun 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Wed, 08 Jun 2011 01:56:22 -0600
```
Jei valandos yra nustatytos į nulį, tai ir minutės bei sekundės taip pat yra nustatytos į nulį (jei nėra nurodytų reikšmių):

```ruby
now.change(hour: 0)
# => Tue, 08 Jun 2010 00:00:00 +0000
```

Panašiai, jei minutės yra nustatytos į nulį, tai ir sekundės taip pat yra nustatytos į nulį (jei nėra nurodytos reikšmės):

```ruby
now.change(min: 0)
# => Tue, 08 Jun 2010 01:00:00 +0000
```

Šis metodas nėra tolerantiškas neteisingoms datoms, jei pakeitimas yra neteisingas, išmetamas `ArgumentError`:

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: invalid date
```

Pastaba: Apibrėžta `active_support/core_ext/date_time/calculations.rb`.


#### Trukmės

[`Duration`][ActiveSupport::Duration] objektai gali būti pridėti arba atimti nuo datos ir laiko:

```ruby
now = DateTime.current
# => Mon, 09 Aug 2010 23:15:17 +0000
now + 1.year
# => Tue, 09 Aug 2011 23:15:17 +0000
now - 1.week
# => Mon, 02 Aug 2010 23:15:17 +0000
```

Jie verčiami į `since` arba `advance` kvietimus. Pavyzdžiui, čia gauname teisingą perėjimą kalendoriuje:

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Fri, 15 Oct 1582 00:00:00 +0000
```

Plėtiniai `Time`
--------------------

### Skaičiavimai

Jie yra analogiški. Prašome kreiptis į jų dokumentaciją aukščiau ir atsižvelgti į šias skirtumus:

* [`change`][Time#change] priima papildomą `:usec` parinktį.
* `Time` supranta DST, todėl gaunate teisingus DST skaičiavimus kaip ir

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# Barselonoje, 2010/03/28 02:00 +0100 tampa 2010/03/28 03:00 +0200 dėl DST.
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Sun Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Sun Mar 28 03:00:00 +0200 2010
```

* Jei [`since`][Time#since] arba [`ago`][Time#ago] pereina į laiką, kuris negali būti išreikštas su `Time`, grąžinamas `DateTime` objektas.


#### `Time.current`

Active Support apibrėžia [`Time.current`][Time.current] kaip šiandienos datą dabarties laiko juostoje. Tai yra kaip `Time.now`, tik jis gerbia vartotojo laiko juostą, jei ji yra nustatyta. Taip pat apibrėžia [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?] ir [`future?`][DateAndTime::Calculations#future?] objekto predikatus, visi jie yra susiję su `Time.current`.

Lyginant laiką naudojant metodus, kurie gerbia vartotojo laiko juostą, įsitikinkite, kad naudojate `Time.current`, o ne `Time.now`. Yra atvejų, kai vartotojo laiko juosta gali būti ateityje, palyginti su sistemos laiko juosta, kurią pagal nutylėjimą naudoja `Time.now`. Tai reiškia, kad `Time.now.to_date` gali būti lygus `Date.yesterday`.

Pastaba: Apibrėžta `active_support/core_ext/time/calculations.rb`.


#### `all_day`, `all_week`, `all_month`, `all_quarter` ir `all_year`

Metodas [`all_day`][DateAndTime::Calculations#all_day] grąžina intervalą, kuris atitinka visą šios dienos laikotarpį.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

Analogiškai, [`all_week`][DateAndTime::Calculations#all_week], [`all_month`][DateAndTime::Calculations#all_month], [`all_quarter`][DateAndTime::Calculations#all_quarter] ir [`all_year`][DateAndTime::Calculations#all_year] visi atlieka laiko intervalų generavimo funkciją.

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

Pastaba: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb`.


#### `prev_day`, `next_day`

[`prev_day`][Time#prev_day] ir [`next_day`][Time#next_day] grąžina laiką paskutinėje arba kitą dieną:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_day               # => 2010-05-07 00:00:00 +0900
t.next_day               # => 2010-05-09 00:00:00 +0900
```

Pastaba: Apibrėžta `active_support/core_ext/time/calculations.rb`.


#### `prev_month`, `next_month`

[`prev_month`][Time#prev_month] ir [`next_month`][Time#next_month] grąžina laiką su tuo pačiu dienos numeriu paskutinėje arba kitą mėnesį:
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

PASTABA: Apibrėžta `active_support/core_ext/time/calculations.rb`.


#### `prev_year`, `next_year`

[`prev_year`][Time#prev_year] ir [`next_year`][Time#next_year] grąžina laiką su tą pačią diena/mėnesiu praėjusiais arba ateinančiais metais:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_year              # => 2009-05-08 00:00:00 +0900
t.next_year              # => 2011-05-08 00:00:00 +0900
```

Jei data yra vasario 29 diena keliamaisiais metais, gausite vasario 28 dieną:

```ruby
t = Time.new(2000, 2, 29) # => 2000-02-29 00:00:00 +0900
t.prev_year               # => 1999-02-28 00:00:00 +0900
t.next_year               # => 2001-02-28 00:00:00 +0900
```

PASTABA: Apibrėžta `active_support/core_ext/time/calculations.rb`.


#### `prev_quarter`, `next_quarter`

[`prev_quarter`][DateAndTime::Calculations#prev_quarter] ir [`next_quarter`][DateAndTime::Calculations#next_quarter] grąžina datą su ta pačia diena ankstesniame arba kitame ketvirtyje:

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 +0300
t.prev_quarter             # => 2010-02-08 00:00:00 +0200
t.next_quarter             # => 2010-08-08 00:00:00 +0300
```

Jei tokios dienos nėra, grąžinama atitinkamo mėnesio paskutinė diena:

```ruby
Time.local(2000, 7, 31).prev_quarter  # => 2000-04-30 00:00:00 +0300
Time.local(2000, 5, 31).prev_quarter  # => 2000-02-29 00:00:00 +0200
Time.local(2000, 10, 31).prev_quarter # => 2000-07-31 00:00:00 +0300
Time.local(2000, 11, 31).next_quarter # => 2001-03-01 00:00:00 +0200
```

`prev_quarter` yra sinonimas [`last_quarter`][DateAndTime::Calculations#last_quarter].

PASTABA: Apibrėžta `active_support/core_ext/date_and_time/calculations.rb`.


### Laiko konstruktorius

Active Support apibrėžia [`Time.current`][Time.current] kaip `Time.zone.now`, jei yra apibrėžta vartotojo laiko juosta, ir kaip `Time.now`, jei nėra:

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

Analogiškai `DateTime`, [`past?`][DateAndTime::Calculations#past?] ir [`future?`][DateAndTime::Calculations#future?] predikatai yra santykiniai `Time.current`.

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

Naudojant klasės metodą [`File.atomic_write`][File.atomic_write], galima įrašyti į failą taip, kad joks skaitytuvas nematytų pusiau įrašyto turinio.

Failo pavadinimas perduodamas kaip argumentas, o metodas grąžina failo rankeną, atidarytą rašymui. Baigus vykdyti bloką, `atomic_write` uždaro failo rankeną ir baigia savo darbą.

Pavyzdžiui, Action Pack naudoja šį metodą rašyti turtų kešo failus, pvz., `all.css`:

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

Tam `atomic_write` sukuria laikiną failą. Tai yra failas, į kurį kodas bloke iš tikrųjų rašo. Baigus, laikinas failas pervadinamas, kas POSIX sistemose yra atomiška operacija. Jei tikslinis failas egzistuoja, `atomic_write` jį perrašo ir išlaiko savininkus ir leidimus. Tačiau yra keletas atvejų, kai `atomic_write` negali pakeisti failo savininko ar leidimų, ši klaida yra sužinoma ir praleidžiama, tikintis, kad vartotojas/byla sistema užtikrins, kad failas būtų pasiekiamas procesams, kurie jo reikia.

PASTABA. Dėl chmod operacijos, kurią atlieka `atomic_write`, jei tiksliniame faile yra ACL, šis ACL bus perskaičiuotas/modifikuotas.
```
ĮSPĖJIMAS. Atkreipkite dėmesį, kad negalite pridėti su `atomic_write`.

Pagalbinis failas rašomas standartinėje laikinų failų direktorijoje, tačiau galite perduoti norimą direktoriją kaip antrąjį argumentą.

PASTABA: Apibrėžta `active_support/core_ext/file/atomic.rb`.


Plėtiniai `NameError`
-------------------------

Active Support prideda [`missing_name?`][NameError#missing_name?] prie `NameError`, kuris patikrina, ar išimtis buvo iškelta dėl perduoto pavadinimo.

Pavadinimas gali būti pateiktas kaip simbolis arba eilutė. Simbolis yra tikrinamas su grynuoju konstantos pavadinimu, o eilutė - su visiškai kvalifikuotu konstantos pavadinimu.

PATARIMAS: Simbolis gali reikšti visiškai kvalifikuotą konstantos pavadinimą, pvz., `:"ActiveRecord::Base"`, todėl simboliams apibrėžtas elgesys yra patogumo sumetimais, o ne techniškai privalomas.

Pavyzdžiui, kai `ArticlesController` veiksmas yra iškviestas, „Rails“ optimistiškai bando naudoti `ArticlesHelper`. Tai nėra problema, jei pagalbinės modulio nėra, todėl jei išimtis dėl to konstantos pavadinimo yra iškelta, ji turėtų būti nutylėta. Tačiau gali būti atvejis, kad `articles_helper.rb` iškelia `NameError` dėl faktiškai nežinomos konstantos. Tai turėtų būti iškelta iš naujo. Metodas `missing_name?` suteikia galimybę atskirti abu atvejus:

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

PASTABA: Apibrėžta `active_support/core_ext/name_error.rb`.


Plėtiniai `LoadError`
-------------------------

Active Support prideda [`is_missing?`][LoadError#is_missing?] prie `LoadError`.

Duodamas kelio pavadinimas, `is_missing?` patikrina, ar išimtis buvo iškelta dėl to konkretaus failo (išskyrus galbūt ".rb" plėtinį).

Pavyzdžiui, kai `ArticlesController` veiksmas yra iškviestas, „Rails“ bando įkelti `articles_helper.rb`, bet to failo gali nebūti. Tai nėra problema, pagalbinis modulis nėra privalomas, todėl „Rails“ nutyla įkėlimo klaidą. Tačiau gali būti atvejis, kad pagalbinis modulis egzistuoja ir savo ruožtu reikalauja kito trūkstamo bibliotekos. Tokiu atveju „Rails“ turi iškelti išimtį iš naujo. Metodas `is_missing?` suteikia galimybę atskirti abu atvejus:

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

PASTABA: Apibrėžta `active_support/core_ext/load_error.rb`.


Plėtiniai `Pathname`
-------------------------

### `existence`

Metodas [`existence`][Pathname#existence] grąžina gavėją, jei nurodytas failas egzistuoja, kitu atveju grąžina `nil`. Tai naudinga šiam idiomui:

```ruby
content = Pathname.new("file").existence&.read
```

PASTABA: Apibrėžta `active_support/core_ext/pathname/existence.rb`.
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
