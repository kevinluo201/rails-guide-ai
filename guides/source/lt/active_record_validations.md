**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37dd3507f05f7787a794868a2619e6d5
Aktyvusis įrašo patikrinimas
=========================

Šis vadovas moko, kaip patikrinti objektų būseną prieš juos įrašant į duomenų bazę, naudojant Aktyvaus įrašo patikrinimo funkciją.

Po šio vadovo perskaitymo, žinosite:

* Kaip naudoti įdiegtus Aktyvaus įrašo patikrinimo pagalbininkus.
* Kaip sukurti savo paties patikrinimo metodus.
* Kaip dirbti su patikrinimo proceso sukurtomis klaidų žinutėmis.

--------------------------------------------------------------------------------

Patikrinimo apžvalga
--------------------

Štai labai paprasto patikrinimo pavyzdys:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

Kaip matote, mūsų patikrinimas leidžia mums sužinoti, kad mūsų `Person` objektas nėra galiojantis be `name` atributo. Antras `Person` objektas nebus išsaugotas į duomenų bazę.

Prieš pradedant detaliau nagrinėti, kalbėkime apie tai, kaip patikrinimai telpa į jūsų programos bendrą vaizdą.

### Kodėl naudoti patikrinimus?

Patikrinimai naudojami tam, kad būtų užtikrinta, jog į jūsų duomenų bazę būtų išsaugomi tik galiojantys duomenys. Pavyzdžiui, jūsų programai gali būti svarbu užtikrinti, kad kiekvienas vartotojas pateiktų galiojantį el. pašto adresą ir pašto adresą. Modelio lygio patikrinimai yra geriausias būdas užtikrinti, kad tik galiojantys duomenys būtų išsaugomi į jūsų duomenų bazę. Jie yra duomenų bazės nepriklausomi, negali būti apeiti naudotojų ir patogūs testuoti bei palaikyti. „Rails“ teikia įdiegtus pagalbinius įrankius bendriems poreikiams ir leidžia kurti savo patikrinimo metodus.

Yra keletas kitų būdų patikrinti duomenis prieš juos išsaugant į duomenų bazę, įskaitant natyvius duomenų bazės apribojimus, kliento pusės patikrinimus ir valdiklio lygio patikrinimus. Štai santrauka apie privalumus ir trūkumus:

* Duomenų bazės apribojimai ir/arba saugojami procedūros padaro patikrinimo mechanizmus priklausomus nuo duomenų bazės ir gali padaryti testavimą ir palaikymą sudėtingesnius. Tačiau, jei jūsų duomenų bazė naudojama kitų programų, gali būti gera idėja naudoti kai kuriuos apribojimus duomenų bazės lygmeniu. Be to, duomenų bazės lygio patikrinimai saugiai gali tvarkyti tam tikrus dalykus (pvz., unikalumą labai naudojamose lentelėse), kurie kitaip gali būti sunkiai įgyvendinami.
* Kliento pusės patikrinimai gali būti naudingi, bet paprastai yra nepatikimi, jei naudojami vieni. Jei jie įgyvendinami naudojant „JavaScript“, jie gali būti apeiti, jei naršyklėje naudotojas išjungia „JavaScript“. Tačiau, jei kombinuojami su kitomis technikomis, kliento pusės patikrinimas gali būti patogus būdas suteikti vartotojams nedelsiantinį atgalinį ryšį naudojant jūsų svetainę.
* Valdiklio lygio patikrinimai gali būti patrauklūs, bet dažnai tampa sunkiai valdomi ir sunkiai testuojami bei palaikomi. Kiek įmanoma, gerai būtų laikyti savo valdiklius paprastais, nes tai padarys jūsų programą malonų ilgalaikiam naudojimui.

Pasirinkite šiuos atvejus. „Rails“ komandos nuomone, modelio lygio patikrinimai yra tinkamiausi daugumoje atvejų.

### Kada vykdomas patikrinimas?

Yra du rūšių Aktyvaus įrašo objektai: tie, kurie atitinka eilutę jūsų duomenų bazėje, ir tie, kurie to nedaro. Kai sukuriate naują objektą, pavyzdžiui, naudodami `new` metodą, tas objektas dar nepriklauso duomenų bazei. Kai tik iškviečiate `save` šiam objektui, jis bus išsaugotas atitinkamoje duomenų bazės lentelėje. Aktyvusis įrašas naudoja `new_record?` objekto metodo, kad nustatytų, ar objektas jau yra duomenų bazėje ar ne. Apžvelkime šį Aktyvaus įrašo klasės pavyzdį:

```ruby
class Person < ApplicationRecord
end
```

Galime pamatyti, kaip tai veikia žiūrint į kelias `bin/rails console` išvestis:

```irb
irb> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>

irb> p.new_record?
=> true

irb> p.save
=> true

irb> p.new_record?
=> false
```

Naujo įrašo sukūrimas ir išsaugojimas siunčia SQL `INSERT` operaciją į duomenų bazę. Esamo įrašo atnaujinimas siunčia SQL `UPDATE` operaciją. Patikrinimai paprastai vykdomi prieš šias komandas siunčiant į duomenų bazę. Jei patikrinimai nepavyksta, objektas bus pažymėtas kaip negaliojantis ir Aktyvusis įrašas nevykdys `INSERT` ar `UPDATE` operacijos. Tai leidžia išvengti negaliojančio objekto saugojimo duomenų bazėje. Galite pasirinkti, kad tam tikri patikrinimai būtų vykdomi, kai objektas yra kuriamas, išsaugomas ar atnaujinamas.

DĖMESIO: Yra daug būdų pakeisti objekto būseną duomenų bazėje. Kai kurie metodai sukelia patikrinimus, bet kiti ne. Tai reiškia, kad galite išsaugoti objektą duomenų bazėje negaliojančioje būsenoje, jei nesate atsargūs.
Šie metodai sukelia validacijas ir objektą įrašo į duomenų bazę tik tada, jei objektas yra galiojantis:

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

Bang versijos (pvz., `save!`) iškelia išimtį, jei įrašas yra negaliojantis.
Ne-bang versijos to nedaro: `save` ir `update` grąžina `false`, o
`create` grąžina objektą.

### Validacijų praleidimas

Šie metodai praleidžia validacijas ir objektą įrašo į duomenų bazę, nepriklausomai nuo jo galiojimo. Jie turėtų būti naudojami atsargiai.

* `decrement!`
* `decrement_counter`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `toggle!`
* `touch`
* `touch_all`
* `update_all`
* `update_attribute`
* `update_column`
* `update_columns`
* `update_counters`
* `upsert`
* `upsert_all`

Reikia pažymėti, kad `save` taip pat gali praleisti validacijas, jei perduodamas `validate:
false` argumentas. Šią techniką reikia naudoti atsargiai.

* `save(validate: false)`

### `valid?` ir `invalid?`

Prieš įrašant Active Record objektą, „Rails“ vykdo jūsų validacijas.
Jei šios validacijos sukelia klaidų, „Rails“ neįrašo objekto.

Galite taip pat patys paleisti šias validacijas. [`valid?`][] paleidžia jūsų validacijas
ir grąžina `true`, jei objekte nerasta klaidų, ir `false` kitu atveju.
Kaip matėte aukščiau:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

Po to, kai Active Record atliko validacijas, bet kokie nesėkmės gali būti pasiektos
per [`errors`][] egzemplioriaus metodą, kuris grąžina klaidų kolekciją.
Pagal apibrėžimą, objektas yra galiojantis, jei ši kolekcija yra tuščia po paleidimo
validacijos.

Reikia pažymėti, kad sukurta objektas su `new` nepraneša klaidų
net jei jis techniškai yra negaliojantis, nes validacijos automatiškai vykdomos
tik tada, kai objektas yra išsaugotas, pvz., naudojant `create` arba `save` metodus.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> p = Person.new
=> #<Person id: nil, name: nil>
irb> p.errors.size
=> 0

irb> p.valid?
=> false
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p = Person.create
=> #<Person id: nil, name: nil>
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p.save
=> false

irb> p.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank

irb> Person.create!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

[`invalid?`][] yra `valid?` priešingybė. Jis paleidžia jūsų validacijas,
grąžindamas `true`, jei objekte buvo rasta klaidų, ir `false` kitu atveju.


### `errors[]`

Norėdami patikrinti, ar tam tikras objekto atributas yra galiojantis arba ne, galite
naudoti [`errors[:attribute]`][Errors#squarebrackets]. Tai grąžina visų
`:attribute` klaidų pranešimų masyvą. Jei nėra klaidų nurodytame
atribute, grąžinamas tuščias masyvas.

Šis metodas yra naudingas tik _po_ paleidimo validacijų, nes jis tik
tikrina klaidų kolekciją ir pats nevykdo validacijų. Jis
skiriasi nuo `ActiveRecord::Base#invalid?` metodo, kuris paaiškina aukščiau, nes
jis neįvertina objekto galiojimo kaip visumos. Jis tik patikrina
ar yra klaidų, rastų objekto atskirame atribute.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.new.errors[:name].any?
=> false
irb> Person.create.errors[:name].any?
=> true
```

Mes išsamiau aptarsime validacijos klaidas [Dirbant su validacijos
klaidomis](#dirbant-su-validacijos-klaidomis) skyriuje.


Validacijos pagalbininkai
------------------

Active Record siūlo daug iš anksto apibrėžtų validacijos pagalbininkų, kuriuos galite naudoti
tiesiogiai savo klasės apibrėžimuose. Šie pagalbininkai teikia bendras validacijos
taisykles. Kiekvieną kartą, kai validacija nesėkminga, klaida pridedama prie objekto `errors`
kolekcijos, ir tai susiję su tikrinamu atributu.

Kiekvienas pagalbininkas priima bet kokį atributo pavadinimų skaičių, todėl vienoje
kodo eilutėje galite pridėti tą pačią rūšies validaciją keliems atributams.

Visi jie priima `:on` ir `:message` parinktis, kurios nurodo, kada
validacija turėtų būti vykdoma ir kokį pranešimą reikėtų pridėti prie `errors`
kolekcijos, jei ji nesėkminga, atitinkamai. `:on` parinktis priima vieną iš reikšmių
`:create` arba `:update`. Kiekvienam validacijos pagalbininkui yra numatytas klaidos pranešimas.
Šie pranešimai naudojami, kai `:message` parinktis nėra nurodyta. Pažiūrėkime į kiekvieną iš prieinamų pagalbininkų.

INFORMACIJA: Norėdami pamatyti sąrašą prieinamų numatytųjų pagalbininkų, pažiūrėkite
[`ActiveModel::Validations::HelperMethods`][].
### `patvirtinimas`

Šis metodas patikrina, ar žymimasis langelis naudotojo sąsajoje buvo pažymėtas, kai forma buvo pateikta. Tai dažniausiai naudojama, kai naudotojui reikia sutikti su jūsų programos paslaugų sąlygomis, patvirtinti, kad buvo perskaitytas tam tikras tekstas arba bet kokia panaši sąvoka.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

Ši patikra atliekama tik tada, jei `terms_of_service` nėra `nil`.
Numatytasis klaidos pranešimas šiam pagalbininkui yra _"turi būti priimtas"_.
Taip pat galite perduoti pasirinktinį pranešimą per `message` parinktį.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: 'turi būti laikomasi' }
end
```

Taip pat gali būti naudojama `:accept` parinktis, kuri nustato leistinas reikšmes, kurios bus laikomos priimtinomis. Numatytasis variantas yra `['1', true]` ir gali būti lengvai pakeistas.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'taip' }
  validates :eula, acceptance: { accept: ['TEISINGA', 'priimta'] }
end
```

Ši validacija yra labai specifinė interneto programoms ir šis 'acceptance' nereikia įrašyti jokioje duomenų bazėje. Jei neturite lauko tam, pagalbininkas sukurs virtualų atributą. Jei laukas egzistuoja jūsų duomenų bazėje, `accept` parinktis turi būti nustatyta arba įtraukti `true`, kitaip validacija nebus vykdoma.

### `patvirtinimas`

Šį pagalbininką turėtumėte naudoti, kai turite du teksto laukus, kurie turėtų gauti tiksliai tą patį turinį. Pavyzdžiui, galite patvirtinti el. pašto adresą ar slaptažodį. Ši validacija sukuria virtualų atributą, kurio pavadinimas yra lauko, kurį reikia patvirtinti, pavadinimas su pridėtu "_confirmation".

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

Šablone galite naudoti kažką panašaus į

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

PASTABA: Ši patikra atliekama tik tada, jei `email_confirmation` nėra `nil`. Norėdami reikalauti patvirtinimo, įsitikinkite, kad pridėjote privalomą tikrinimą patvirtinimo atributui (apie tai daugiau žr. [vėliau](#privalumas) šiame vadove):

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

Taip pat yra `:case_sensitive` parinktis, kurią galite naudoti, norėdami nustatyti, ar patvirtinimo apribojimas bus didžiosios ir mažosios raidės jautrus ar ne. Ši parinktis pagal nutylėjimą yra `true`.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

Numatytasis klaidos pranešimas šiam pagalbininkui yra _"nesutampa su patvirtinimu"_. Taip pat galite perduoti pasirinktinį pranešimą per `message` parinktį.

Daugiausia naudojant šį tikrinimą, norėsite jį sujungti su `:if` parinktimi, kad patvirtinimo laukas "_confirmation" būtų tikrinamas tik tada, kai pradinis laukas pasikeitė ir **ne** kiekvieną kartą, kai įrašas išsaugomas. Daugiau apie [sąlyginį tikrinimą](#sąlyginis-tikrinimas) vėliau.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?
end
```

### `palyginimas`

Ši patikra patikrins palyginimą tarp dviejų palyginamų reikšmių.

```ruby
class Promotion < ApplicationRecord
  validates :end_date, comparison: { greater_than: :start_date }
end
```

Numatytasis klaidos pranešimas šiam pagalbininkui yra _"nepavyko palyginimas"_. Taip pat galite perduoti pasirinktinį pranešimą per `message` parinktį.

Visos šios parinktys yra palaikomos:

* `:greater_than` - Nurodo, kad reikšmė turi būti didesnė nei nurodyta reikšmė. Numatytasis klaidos pranešimas šiai parinkčiai yra _"turi būti didesnis nei %{count}"_.
* `:greater_than_or_equal_to` - Nurodo, kad reikšmė turi būti didesnė arba lygi nurodytai reikšmei. Numatytasis klaidos pranešimas šiai parinkčiai yra _"turi būti didesnis arba lygus %{count}"_.
* `:equal_to` - Nurodo, kad reikšmė turi būti lygi nurodytai reikšmei. Numatytasis klaidos pranešimas šiai parinkčiai yra _"turi būti lygus %{count}"_.
* `:less_than` - Nurodo, kad reikšmė turi būti mažesnė nei nurodyta reikšmė. Numatytasis klaidos pranešimas šiai parinkčiai yra _"turi būti mažesnis nei %{count}"_.
* `:less_than_or_equal_to` - Nurodo, kad reikšmė turi būti mažesnė arba lygi nurodytai reikšmei. Numatytasis klaidos pranešimas šiai parinkčiai yra _"turi būti mažesnis arba lygus %{count}"_.
* `:other_than` - Nurodo, kad reikšmė turi būti skirtinga nuo nurodytos reikšmės. Numatytasis klaidos pranešimas šiai parinkčiai yra _"turi būti skirtingas nei %{count}"_.

PASTABA: Validavimui reikalinga palyginimo parinktis. Kiekviena parinktis priima reikšmę, procedūrą arba simbolį. Bet kuri klasė, kuri įtraukia Comparable, gali būti palyginama.
### `formatas`

Šis pagalbinis įrankis patikrina atributų reikšmes, tikrinant, ar jos atitinka nurodytą reguliariąją išraišką, kuri yra nurodoma naudojant `:with` parinktį.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "leidžia tik raides" }
end
```

Atvirkščiai, naudojant `:without` parinktį, galite reikalauti, kad nurodytas atributas _nesutaptų_ su reguliariąja išraiška.

Abiem atvejais, pateikta `:with` arba `:without` parinktis turi būti reguliariąja išraiška arba proc arba lambda funkcija, kurią grąžina.

Numatytoji klaidos žinutė yra _"yra neteisinga"_.

ĮSPĖJIMAS. naudokite `\A` ir `\z` norėdami sutapti su eilutės pradžia ir pabaiga, `^` ir `$` sutampa su eilutės pradžia / pabaiga. Dėl dažno `^` ir `$` neteisingo naudojimo, jei naudojate bet kurį iš šių dviejų pririšiklių teikiamos reguliariosios išraiškos, turite perduoti `multiline: true` parinktį. Daugeliu atvejų turėtumėte naudoti `\A` ir `\z`.

### `įtraukimas`

Šis pagalbinis įrankis patikrina, ar atributų reikšmės yra įtrauktos į nurodytą rinkinį. Iš tikrųjų, šis rinkinys gali būti bet koks numeruojamas objektas.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} nėra leistinas dydis" }
end
```

`inclusion` pagalbinis įrankis turi `:in` parinktį, kuri priima priimtinų reikšmių rinkinį. `:in` parinktis turi sinonimą, vadinamą `:within`, kurį galite naudoti tuo pačiu tikslu, jei norite. Ankstesnis pavyzdys naudoja `:message` parinktį, kad parodytų, kaip galite įtraukti atributo reikšmę. Pilniems parinkčių nustatymams žr. [žinučių dokumentaciją](#message).

Numatytoji klaidos žinutė šiam pagalbiniam įrankiui yra _"nėra sąraše"_.

### `neįtraukimas`

`Įtraukimo` priešingybė yra... `neįtraukimas`!

Šis pagalbinis įrankis patikrina, ar atributų reikšmės nėra įtrauktos į nurodytą rinkinį. Iš tikrųjų, šis rinkinys gali būti bet koks numeruojamas objektas.

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} yra rezervuotas." }
end
```

`neįtraukimo` pagalbinis įrankis turi `:in` parinktį, kuri priima reikšmių rinkinį, kuris nebus priimtas patikrinamiems atributams. `:in` parinktis turi sinonimą, vadinamą `:within`, kurį galite naudoti tuo pačiu tikslu, jei norite. Šis pavyzdys naudoja `:message` parinktį, kad parodytų, kaip galite įtraukti atributo reikšmę. Pilniems žinutės argumento parinktims žr. [žinučių dokumentaciją](#message).

Numatytoji klaidos žinutė yra _"yra rezervuotas"_.

Alternatyviai tradiciniam numeruojamam objektui (pvz., masyvui) galite pateikti proc, lambda arba simbolį, kuris grąžina numeruojamą objektą. Jei numeruojamas objektas yra skaitinis, laiko arba datos laiko intervalas, testas atliekamas naudojant `Range#cover?`, kitu atveju naudojant `include?`. Naudojant proc arba lambda, validuojamas egzempliorius, kuris yra perduodamas kaip argumentas. 

### `ilgis`

Šis pagalbinis įrankis patikrina atributų reikšmių ilgį. Jis suteikia įvairių parinkčių, todėl galite nurodyti ilgio apribojimus skirtingais būdais:

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

Galimos ilgio apribojimo parinktys yra:

* `:minimum` - Atributas negali būti mažesnis nei nurodytas ilgis.
* `:maximum` - Atributas negali būti didesnis nei nurodytas ilgis.
* `:in` (arba `:within`) - Atributo ilgis turi būti įtrauktas į nurodytą intervalą. Šios parinkties reikšmė turi būti intervalas.
* `:is` - Atributo ilgis turi būti lygus nurodytai reikšmei.

Numatytosios klaidos žinutės priklauso nuo atliekamo ilgio patikrinimo tipo. Galite tinkinti šias žinutes, naudodami `:wrong_length`, `:too_long` ir `:too_short` parinktis ir `%{count}` kaip vietos rezervuotąjį ženklą, atitinkantį naudojamą ilgio apribojimą. Vis tiek galite naudoti `:message` parinktį, norėdami nurodyti klaidos žinutę.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "leidžiama daugiausiai %{count} simboliai" }
end
```

Atkreipkite dėmesį, kad numatytosios klaidos žinutės yra daugiskaitos (pvz., "yra per trumpas (minimumas yra %{count} simboliai)"). Dėl šios priežasties, kai `:minimum` yra 1, turėtumėte nurodyti tinkintą žinutę arba vietoj to naudoti `presence: true`. Kai `:in` ar `:within` turi apatinį ribą 1, turėtumėte arba nurodyti tinkintą žinutę, arba prieš `length` iškviesti `presence`.
PASTABA: Galima naudoti tik vieną apribojimo parinktį išskyrus `:minimum` ir `:maximum` parinktis, kurios gali būti derinamos kartu.

### `numericality`

Šis pagalbininkas patikrina, ar jūsų atributai turi tik skaitines reikšmes. Pagal nutylėjimą jis atitiks pasirinktinį ženklą, po kurio seka sveikasis arba slankiojo kablelio skaičius.

Norėdami nurodyti, kad leidžiamos tik sveikosios skaičių reikšmės, nustatykite `:only_integer` reikšmę į `true`. Tada jis naudos šią reguliariąją išraišką, kad patikrintų atributo reikšmę.

```ruby
/\A[+-]?\d+\z/
```

Kitu atveju jis bandys konvertuoti reikšmę į skaičių naudodamas `Float`. `Float` tipo reikšmės yra konvertuojamos į `BigDecimal` naudojant stulpelio tikslumo reikšmę arba maksimaliai 15 skaitmenų.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

Pagal nutylėjimą klaidos pranešimas dėl `:only_integer` yra _"turi būti sveikasis skaičius"_.

Be `:only_integer`, šis pagalbininkas taip pat priima `:only_numeric` parinktį, kuri nurodo, kad reikšmė turi būti `Numeric` tipo objektas ir bandys ją analizuoti, jei ji yra `String` tipo.

PASTABA: Pagal nutylėjimą `numericality` neleidžia `nil` reikšmių. Galite naudoti `allow_nil: true` parinktį, kad tai leistų. Atkreipkite dėmesį, kad `Integer` ir `Float` tipo stulpeliuose tuščios eilutės konvertuojamos į `nil` reikšmę.

Klaidos pranešimas pagal nutylėjimą, kai nėra nurodytų parinkčių, yra _"nėra skaičius"_.

Taip pat yra daug parinkčių, kurios gali būti naudojamos pridėti apribojimus priimtinoms reikšmėms:

* `:greater_than` - Nurodo, kad reikšmė turi būti didesnė nei nurodyta reikšmė. Klaidos pranešimas pagal nutylėjimą šiai parinkčiai yra _"turi būti didesnis nei %{count}"_.
* `:greater_than_or_equal_to` - Nurodo, kad reikšmė turi būti didesnė arba lygi nurodytai reikšmei. Klaidos pranešimas pagal nutylėjimą šiai parinkčiai yra _"turi būti didesnis arba lygus %{count}"_.
* `:equal_to` - Nurodo, kad reikšmė turi būti lygi nurodytai reikšmei. Klaidos pranešimas pagal nutylėjimą šiai parinkčiai yra _"turi būti lygus %{count}"_.
* `:less_than` - Nurodo, kad reikšmė turi būti mažesnė nei nurodyta reikšmė. Klaidos pranešimas pagal nutylėjimą šiai parinkčiai yra _"turi būti mažesnis nei %{count}"_.
* `:less_than_or_equal_to` - Nurodo, kad reikšmė turi būti mažesnė arba lygi nurodytai reikšmei. Klaidos pranešimas pagal nutylėjimą šiai parinkčiai yra _"turi būti mažesnis arba lygus %{count}"_.
* `:other_than` - Nurodo, kad reikšmė turi būti skirtinga nuo nurodytos reikšmės. Klaidos pranešimas pagal nutylėjimą šiai parinkčiai yra _"turi būti skirtingas nei %{count}"_.
* `:in` - Nurodo, kad reikšmė turi būti nurodytame diapazone. Klaidos pranešimas pagal nutylėjimą šiai parinkčiai yra _"turi būti diapazone %{count}"_.
* `:odd` - Nurodo, kad reikšmė turi būti nelyginis skaičius. Klaidos pranešimas pagal nutylėjimą šiai parinkčiai yra _"turi būti nelyginis"_.
* `:even` - Nurodo, kad reikšmė turi būti lyginis skaičius. Klaidos pranešimas pagal nutylėjimą šiai parinkčiai yra _"turi būti lyginis"_.

### `presence`

Šis pagalbininkas patikrina, ar nurodyti atributai nėra tušti. Jis naudoja [`Object#blank?`][] metodą, kad patikrintų, ar reikšmė yra `nil` arba tuščia eilutė, tai yra, eilutė, kuri yra tuščia arba susideda tik iš tarpų.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

Jei norite užtikrinti, kad asociacija yra pateikiama, turėsite patikrinti, ar pats asocijuotas objektas yra pateikiamas, o ne naudojamas svetainės raktas, skirtas susieti asociaciją. Taip pat yra patikrinama, ar ne tik svetainės raktas yra tuščias, bet ir ar nurodytas objektas egzistuoja.

```ruby
class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end
```

Norėdami patikrinti privalomų susijusių įrašų, jums reikia nurodyti `:inverse_of` parinktį asociacijai:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

PASTABA: Jei norite užtikrinti, kad asociacija būtų ne tik pateikiama, bet ir galiojanti, taip pat turite naudoti `validates_associated`. Daugiau informacijos
[žemiau](#validates-associated)

Jei patikrinate `has_one` arba `has_many` ryšiu susieto objekto pateikimą, bus patikrinta, ar objektas nėra `blank?` ir ar jis nėra `marked_for_destruction?`.

Kadangi `false.blank?` yra tiesa, jei norite patikrinti, ar yra pateikiama boolean tipo lauko reikšmė, turėtumėte naudoti vieną iš šių patikrinimų:

```ruby
# Reikšmė _turi būti_ true arba false
validates :boolean_field_name, inclusion: [true, false]
# Reikšmė _negali būti_ nil, tai yra, true arba false
validates :boolean_field_name, exclusion: [nil]
```
Naudodami vieną iš šių patvirtinimų, užtikrinsite, kad reikšmė NEBUS `nil`, kas daugeliu atvejų rezultuotų `NULL` reikšme.

Numatytasis klaidos pranešimas yra _"negali būti tuščias"_.


### `absence`

Šis pagalbininkas patikrina, ar nurodyti atributai yra nebuvę. Jis naudoja [`Object#present?`][] metodą, kad patikrintų, ar reikšmė nėra nei `nil`, nei tuščias eilutės simbolis, t. y. eilutė, kuri yra tuščia arba susideda tik iš tarpų.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

Jei norite būti tikri, kad asociacija yra nebuvusi, turite patikrinti, ar pati susijusi objektas yra nebuvęs, o ne naudojamas svetainės raktas, skirtas susieti asociaciją.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

Norėdami patikrinti asocijuotus įrašus, kurių nebuvimas yra būtinas, turite nurodyti `:inverse_of` parinktį asociacijai:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

PASTABA: Jei norite užtikrinti, kad asociacija būtų ir esanti, ir galiojanti, taip pat turite naudoti `validates_associated`. Daugiau informacijos
žr. [žemiau](#validates-associated)

Jei patikrinate objekto nebuvimą, susijusį per `has_one` arba
`has_many` ryšį, bus patikrinta, ar objektas nėra nei `present?`, nei
`marked_for_destruction?`.

Kadangi `false.present?` yra `false`, jei norite patikrinti, ar logikos laukas yra nebuvęs,
turėtumėte naudoti `validates :field_name, exclusion: { in: [true, false] }`.

Numatytasis klaidos pranešimas yra _"turi būti tuščias"_.


### `uniqueness`

Šis pagalbininkas patikrina, ar atributo reikšmė yra unikali tiesiog prieš
objektas bus išsaugotas.

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

Patikrinimas vyksta atliekant SQL užklausą į modelio lentelę,
ieškant esamo įrašo su ta pačia reikšme tame atribute.

Yra `:scope` parinktis, kurią galite naudoti, norėdami nurodyti vieną ar daugiau atributų,
kurie naudojami riboti unikalumo patikrinimą:

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "turėtų įvykti kartą per metus" }
end
```

ĮSPĖJIMAS. Šis patikrinimas nekuria unikalumo apribojimo
duomenų bazėje, todėl gali atsitikti, kad du skirtingi duomenų bazės ryšiai sukurs du
įrašus su ta pačia reikšme stulpelyje, kurį norite, kad būtų unikalus. Norėdami
išvengti to, turite sukurti unikalų indeksą tame stulpelyje savo duomenų bazėje.

Norėdami pridėti unikalumo duomenų bazės apribojimą savo duomenų bazėje, naudokite
[`add_index`][] teiginį migracijoje ir įtraukite `unique: true` parinktį.

Jei norite sukurti duomenų bazės apribojimą, kad būtų išvengta galimų pažeidimų
unikalumo patikrinimo, naudojant `:scope` parinktį, turite sukurti unikalų
indeksą abiejuose stulpeliuose savo duomenų bazėje. Daugiau informacijos
žr. [MySQL vadovą][] dėl kelių stulpelių indeksų arba [PostgreSQL vadovą][] dėl pavyzdžių
unikalumo apribojimų, kurie nurodo grupę stulpelių.

Taip pat yra `:case_sensitive` parinktis, kurią galite naudoti, nurodydami, ar
unikalumo apribojimas bus jautrus raidėms, nejautrus raidėms arba atitiks
numatytąją duomenų bazės susiejimą. Ši parinktis pagal numatymą atitinka numatytąją duomenų bazės
susiejimą.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

ĮSPĖJIMAS. Atkreipkite dėmesį, kad kai kurios duomenų bazės yra konfigūruotos atlikti
neišskiriamus paieškas.

Yra `:conditions` parinktis, kuria galite nurodyti papildomas sąlygas
`WHERE` SQL fragmentui, kad apribotumėte unikalumo apribojimo paiešką (pvz.
`sąlygos: -> { where(status: 'active') }`).

Numatytasis klaidos pranešimas yra _"jau buvo užimta"_.

Daugiau informacijos žr. [`validates_uniqueness_of`][].

[MySQL vadovas]: https://dev.mysql.com/doc/refman/en/multiple-column-indexes.html
[PostgreSQL vadovas]: https://www.postgresql.org/docs/current/static/ddl-constraints.html

### `validates_associated`

Turėtumėte naudoti šį pagalbininką, kai jūsų modelyje yra asociacijos, kurios visada turi
būti patikrintos. Kiekvieną kartą, kai bandysite išsaugoti savo objektą, bus iškviesta
`valid?` kiekvienam iš susijusių objektų.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

Šis patikrinimas veiks su visais asociacijos tipais.

ATSAKOMYBĖ: Nenaudokite `validates_associated` abiejose asociacijų galuose.
Jos viena kitą iškvies begalinį ciklą.

Numatytasis klaidos pranešimas [`validates_associated`][] yra _"yra neteisingas"_. Atkreipkite dėmesį,
kad kiekvienas susijęs objektas turės savo `errors` kolekciją; klaidos
neperduodamos į iškviečiantį modelį.

PASTABA: [`validates_associated`][] gali būti naudojamas tik su ActiveRecord objektais,
viskas iki šiol taip pat gali būti naudojama su bet kuriuo objektu, kuriame yra
[`ActiveModel::Validations`][].
### `validates_each`

Šis pagalbininkas patikrina atributus prieš bloką. Jis neturi iš anksto nustatyto patikrinimo funkcijos. Turėtumėte sukurti vieną naudodami bloką, ir kiekvienas [`validates_each`][] perduotas atributas bus patikrintas prieš jį.

Pavyzdyje, kurį matote žemiau, mes atmetame vardus ir pavardes, kurios prasideda mažąja raidė.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'turi prasidėti didžiąja raidė') if /\A[[:lower:]]/.match?(value)
  end
end
```

Bloke gaunamas įrašas, atributo pavadinimas ir atributo reikšmė.

Bloke galite daryti bet ką, norėdami patikrinti, ar duomenys yra teisingi. Jei patikrinimas nepavyksta, turėtumėte pridėti klaidą prie modelio, todėl jis tampa neteisingas.


### `validates_with`

Šis pagalbininkas perduoda įrašą atskiram klasės patikrinimui.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors.add :base, "Ši asmenybė yra pikta"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

`validates_with` neturi numatytojo klaidos pranešimo. Klaidas įrašui reikia pridėti rankiniu būdu į klaidų kolekciją, esančią patikrinimo klasėje.

PASTABA: Klaidos, pridėtos prie `record.errors[:base]`, susijusios su viso įrašo būsena.

Norėdami įgyvendinti `validate` metodą, metodo apibrėžime turite priimti `record` parametrą, kuris yra tikrinamas įrašas.

Jei norite pridėti klaidą konkrečiam atributui, perduokite jį kaip pirmąjį argumentą, pvz., `record.errors.add(:first_name, "prašome pasirinkti kitą vardą")`. Mes išsamiau aptarsime [validavimo klaidas][] vėliau.

```ruby
def validate(record)
  if record.some_field != "priimtina"
    record.errors.add :some_field, "šis laukas yra nepriimtinas"
  end
end
```

[`validates_with`][] pagalbininkas priima klasę arba klasės sąrašą, kurį naudoti patikrinimui.

```ruby
class Person < ApplicationRecord
  validates_with MyValidator, MyOtherValidator, on: :create
end
```

Kaip ir visi kiti patikrinimai, `validates_with` priima `:if`, `:unless` ir `:on` parinktis. Jei perduodate kitas parinktis, jas bus perduodamos patikrinimo klasei kaip `options`:

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| record.send(field) == "Evil" }
      record.errors.add :base, "Ši asmenybė yra pikta"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

Atkreipkite dėmesį, kad patikrintuvas bus inicializuotas *tik vieną kartą* visam programos gyvavimo ciklui, o ne kiekvienam patikrinimo paleidimui, todėl atsargiai naudokitės joje esančiomis objekto kintamomis.

Jei jūsų patikrinimas yra pakankamai sudėtingas, kad norėtumėte naudoti objekto kintamąsias, galite lengvai naudoti paprastą senąjį Ruby objektą:

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors.add :base, "Ši asmenybė yra pikta"
    end
  end

  # ...
end
```

Mes išsamiau aptarsime [papildomus patikrinimus](#atliekant-papildomus-patikrinimus) vėliau.

[validavimo klaidos](#dirbant-su-validavimo-klaidomis)

Bendri patikrinimo parinktys
-------------------------

Yra keletas bendrų parinkčių, kurias palaiko ką tik aptartos patikrinimo priemonės, dabar aptarsime kai kurias iš jų!

PASTABA: Ne visos šios parinktys palaikomos visais patikrinimo priemonėmis, prašome kreiptis į [`ActiveModel::Validations`][] API dokumentaciją.

Naudodami bet kurį iš ką tik minėtų patikrinimo metodus, yra ir bendrų parinkčių sąrašas, bendrai naudojamas su patikrinimo priemonėmis. Dabar aptarsime šias parinktis!

* [`:allow_nil`](#leisti-nil): Praleisti patikrinimą, jei atributas yra `nil`.
* [`:allow_blank`](#leisti-tuščią): Praleisti patikrinimą, jei atributas yra tuščias.
* [`:message`](#pranešimas): Nurodyti pasirinktinį klaidos pranešimą.
* [`:on`](#apie): Nurodyti kontekstus, kuriuose šis patikrinimas yra aktyvus.
* [`:strict`](#griežtas-patikrinimas): Iškelti išimtį, kai patikrinimas nepavyksta.
* [`:if` ir `:unless`](#sąlyginis-patikrinimas): Nurodyti, kada patikrinimas turėtų ar neturėtų įvykti.


### `:allow_nil`

`:allow_nil` parinktis praleidžia patikrinimą, kai tikrinama reikšmė yra `nil`.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} yra neteisingas dydis" }, allow_nil: true
end
```

```irb
irb> Coffee.create(size: nil).valid?
=> true
irb> Coffee.create(size: "mega").valid?
=> false
```

Dėl visų pasirinkimų, skirtų pranešimo argumentui, žr. [pranešimo dokumentaciją](#pranešimas).

### `:allow_blank`

`:allow_blank` parinktis panaši į `:allow_nil` parinktį. Ši parinktis leidžia patikrinimui praeiti, jei atributo reikšmė yra `blank?`, pvz., `nil` arba tuščias eilutė.

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end
```

```irb
irb> Topic.create(title: "").valid?
=> true
irb> Topic.create(title: nil).valid?
=> true
```

### `:message`
Kaip jau matėte, `:message` parinktis leidžia nurodyti pranešimą, kuris bus pridėtas prie `errors` kolekcijos, kai validacija nepavyks. Kai ši parinktis nenaudojama, Active Record naudos atitinkamą numatytąjį klaidos pranešimą kiekvienam validacijos pagalbininkui.

`:message` parinktis priima `String` arba `Proc` kaip savo reikšmę.

`String` `:message` reikšmė gali būti pasirinktinai sudaryta iš `%{value}`, `%{attribute}` ir `%{model}`, kurie bus dinamiškai pakeisti, kai validacija nepavyks. Šis pakeitimas atliekamas naudojant i18n gemą, ir vietos rezervavimo ženklai turi būti tiksliai atitinkantys, be jokių tarpų.

```ruby
class Person < ApplicationRecord
  # Kietas pranešimas
  validates :name, presence: { message: "turi būti pateiktas, prašome" }

  # Pranešimas su dinamine atributo reikšme. %{value} bus pakeistas
  # tikra atributo reikšme. %{attribute} ir %{model} taip pat yra prieinami.
  validates :age, numericality: { message: "%{value} atrodo neteisinga" }
end
```

`Proc` `:message` reikšmė gauna dvi argumentus: tikrinamas objektas ir `:model`, `:attribute` ir `:value` raktų-reikšmių porų maišą.

```ruby
class Person < ApplicationRecord
  validates :username,
    uniqueness: {
      # objektas = tikrinamas žmogaus objektas
      # duomenys = { model: "Person", attribute: "Username", value: <username> }
      message: ->(objektas, duomenys) do
        "Ei #{objektas.name}, #{duomenys[:value]} jau užimtas."
      end
    }
end
```

### `:on`

`:on` parinktis leidžia nurodyti, kada vykdoma validacija. Visų įdiegtų validacijos pagalbininkų numatytasis elgesys yra vykdyti ją išsaugojant (tie patys, kuriant naują įrašą, ir atnaujinant jį). Jei norite tai pakeisti, galite naudoti `on: :create`, kad validacija būtų vykdoma tik kuriant naują įrašą, arba `on: :update`, kad validacija būtų vykdoma tik atnaujinant įrašą.

```ruby
class Person < ApplicationRecord
  # bus galima atnaujinti el. paštą su pasikartojančia reikšme
  validates :email, uniqueness: true, on: :create

  # bus galima sukurti įrašą su ne skaitine amžiaus reikšme
  validates :age, numericality: true, on: :update

  # numatytasis (validuoja tiek kuriant, tiek atnaujinant)
  validates :name, presence: true
end
```

Taip pat galite naudoti `on:`, kad apibrėžtumėte pasirinktines kontekstus. Pasirinktiniai kontekstai turi būti iššaukiami iš anksto, perduodant konteksto pavadinimą `valid?`, `invalid?` arba `save`.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end
```

```irb
irb> person = Person.new(age: 'trisdešimt trys')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["jau yra užimtas"], :age=>["nėra skaičius"]}
```

`person.valid?(:account_setup)` vykdo abu tikrinimus, neišsaugodamas modelio. `person.save(context: :account_setup)` išsaugo `person` `account_setup` kontekste prieš išsaugojimą.

Taip pat priimtinas simbolių masyvo perdavimas.

```ruby
class Book
  include ActiveModel::Validations

  validates :title, presence: true, on: [:update, :ensure_title]
end
```

```irb
irb> book = Book.new(title: nil)
irb> book.valid?
=> true
irb> book.valid?(:ensure_title)
=> false
irb> book.errors.messages
=> {:title=>["negali būti tuščias"]}
```

Kai iššaukiama iš anksto nustatyta kontekstu, validacijos vykdomos tam kontekstui ir bet kurioms validacijoms _be_ konteksto.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end
```

```irb
irb> person = Person.new
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["jau yra užimtas"], :age=>["nėra skaičius"], :name=>["negali būti tuščias"]}
```

Daugiau `on:` naudojimo atvejų aptarsime [atgalinio iškvietimo vadove](active_record_callbacks.html).

Griežtos validacijos
------------------

Taip pat galite nurodyti, kad validacija būtų griežta ir iškeltų `ActiveModel::StrictValidationFailed` išimtį, kai objektas yra netinkamas.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end
```

```irb
irb> Person.new.valid?
ActiveModel::StrictValidationFailed: Vardas negali būti tuščias
```

Taip pat galima perduoti pasirinktinę išimtį `:strict` parinkčiai.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end
```

```irb
irb> Person.new.valid?
TokenGenerationException: Token negali būti tuščias
```

Sąlyginė validacija
----------------------

Kartais bus prasminga patikrinti objektą tik tada, kai tenkinamas tam tikras sąlyga. Tai galite padaryti naudodami `:if` ir `:unless` parinktis, kurios gali priimti simbolį, `Proc` arba masyvą. Galite naudoti `:if` parinktį, kai norite nurodyti, kada validacija **turėtų** įvykti. Alternatyviai, jei norite nurodyti, kada validacija **neturėtų** įvykti, galite naudoti `:unless` parinktį.
### Simbolio naudojimas su `:if` ir `:unless`

Galite susieti `:if` ir `:unless` parinktis su simboliu, kuris atitinka metodo pavadinimą, kuris bus iškviestas prieš vykstant patikrinimui. Tai yra dažniausiai naudojama parinktis.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### `:if` ir `:unless` naudojimas su `Proc`

Galima susieti `:if` ir `:unless` su `Proc` objektu, kuris bus iškviestas. `Proc` objekto naudojimas suteikia galimybę rašyti sąlygą vienoje eilutėje, o ne atskirame metode. Ši parinktis geriausiai tinka vienos eilutės kodui.

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

Kadangi `lambda` yra `Proc` tipo objektas, jį taip pat galima naudoti rašant sąlygą vienoje eilutėje, pasinaudojant sutrumpinta sintakse.

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### Grupavimo sąlyginės patikros

Kartais naudinga, kad kelios patikros naudotų vieną sąlygą. Tai galima lengvai pasiekti naudojant [`with_options`][].

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

Visos patikros, esančios `with_options` bloke, automatiškai praeina sąlygą `if: :is_admin?`


### Sąlyginių patikrų derinimas

Kita vertus, kai kelios sąlygos nusako, ar turėtų vykti patikra, galima naudoti `Array`. Be to, galite taikyti tiek `:if`, tiek `:unless` toje pačioje patikroje.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

Patikra vykdoma tik tada, kai visos `:if` sąlygos ir jokia `:unless` sąlyga neigiamai įvertinamos.

Atliekant individualias patikras
-----------------------------

Kai įprastos patikros pagalbininkai neatitinka jūsų poreikių, galite rašyti savo patikrinimo metodus arba patikrinimo metodus, kaip pageidaujate.

### Individualūs patikrinimo metodai

Individualūs patikrinimo metodai yra klasės, paveldinčios [`ActiveModel::Validator`][], objektai. Šios klasės turi įgyvendinti `validate` metodą, kuris priima įrašą kaip argumentą ir atlieka patikrinimą. Individualus patikrinimo metodas yra iškviečiamas naudojant `validates_with` metodą.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "Pateikite vardą, prasidedantį X, prašome!"
    end
  end
end

class Person < ApplicationRecord
  validates_with MyValidator
end
```

Paprastiausias būdas pridėti individualius patikrinimo metodus, skirtus tikrinti atskirus atributus, yra naudojant patogų [`ActiveModel::EachValidator`][]. Šiuo atveju individuali patikrinimo klasė turi įgyvendinti `validate_each` metodą, kuris priima tris argumentus: įrašą, atributą ir atributo reikšmę perduotame įraše.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless URI::MailTo::EMAIL_REGEXP.match?(value)
      record.errors.add attribute, (options[:message] || "nėra el. pašto adresas")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

Kaip parodyta pavyzdyje, galite taip pat derinti standartines patikras su savo individualiais patikrinimo metodais.


### Individualūs metodai

Taip pat galite kurti metodus, kurie patikrina jūsų modelių būseną ir prideda klaidas į `errors` kolekciją, kai jie yra netinkami. Tada turite užregistruoti šiuos metodus, naudodami [`validate`][] klasės metodą, perduodant simbolius, nurodančius patikrinimo metodų pavadinimus.

Vienam klasės metodui galite perduoti daugiau nei vieną simbolį, ir atitinkamos patikros bus vykdomos ta tvarka, kuria jos buvo užregistruotos.

`valid?` metodas patikrins, ar `errors` kolekcija yra tuščia, todėl jūsų individualūs patikrinimo metodai turėtų pridėti klaidas, kai norite, kad patikrinimas nepavyktų:

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "negali būti praeityje")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "negali būti didesnis nei bendra vertė")
    end
  end
end
```

Pagal numatytuosius nustatymus tokios patikros bus vykdomos kiekvieną kartą, kai iškviečiate `valid?` arba išsaugojate objektą. Tačiau taip pat galima kontroliuoti, kada vykdyti šias individualias patikras, suteikiant `:on` parinktį `validate` metode, su `:create` arba `:update`.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "nėra aktyvus") unless customer.active?
  end
end
```
Daugiau informacijos apie [`:on`](#on) rasite aukščiau esančiame skyriuje.

### Validatorių sąrašas

Jei norite sužinoti visus validacijos metodus tam tikram objektui, žvilgtelkite į `validators`.

Pavyzdžiui, jei turime šį modelį, kuriame naudojamas pasirinktinis ir įdiegtas validatorius:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, on: :create
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates_with MyOtherValidator, strict: true
end
```

Dabar galime naudoti `validators` "Person" modelyje, kad pamatytume visus validacijos metodus arba netikrintume konkretaus lauko naudojant `validators_on`.

```irb
irb> Person.validators
#=> [#<ActiveRecord::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={:on=>:create}>,
     #<MyOtherValidatorValidator:0x10b2f17d0
      @attributes=[:name], @options={:strict=>true}>,
     #<ActiveModel::Validations::FormatValidator:0x10b2f0f10
      @attributes=[:email],
      @options={:with=>URI::MailTo::EMAIL_REGEXP}>]
     #<MyOtherValidator:0x10b2f0948 @options={:strict=>true}>]

irb> Person.validators_on(:name)
#=> [#<ActiveModel::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={on: :create}>]
```


Darbas su validacijos klaidomis
------------------------------

Metodai [`valid?`][] ir [`invalid?`][] suteikia tik santraukos būseną apie validumą. Tačiau galite giliau įsikasti į kiekvieną atskirą klaidą, naudodami įvairius metodus iš kolekcijos [`errors`][].

Štai dažniausiai naudojami metodai. Norėdami pamatyti visus galimus metodus, kreipkitės į dokumentaciją [`ActiveModel::Errors`][].


### `errors`

Tai yra vartai, per kuriuos galite giliau įsikasti į kiekvienos klaidos detales.

Tai grąžina klasės `ActiveModel::Errors` pavyzdį, kuriame yra visos klaidos, kiekviena klaida yra vaizduojama [`ActiveModel::Error`][] objektu.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.full_messages
=> ["Name can’t be blank", "Name is too short (minimum is 3 characters)"]

irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors.full_messages
=> []

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.first.details
=> {:error=>:too_short, :count=>3}
```


### `errors[]`

[`errors[]`][Errors#squarebrackets] naudojamas, kai norite patikrinti klaidų pranešimus apie konkretų atributą. Tai grąžina masyvą su visais klaidų pranešimais, susijusiais su nurodytu atributu, kiekvienas pranešimas yra vienas klaidos pranešimas. Jei atributui nėra klaidų, grąžinamas tuščias masyvas.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors[:name]
=> []

irb> person = Person.new(name: "JD")
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["is too short (minimum is 3 characters)"]

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["can’t be blank", "is too short (minimum is 3 characters)"]
```

### `errors.where` ir klaidų objektas

Kartais mums gali prireikti daugiau informacijos apie kiekvieną klaidą, be jos pranešimo. Kiekviena klaida yra supakuota kaip `ActiveModel::Error` objektas, o [`where`][] metodas yra dažniausias būdas pasiekti jį.

`where` grąžina klaidų objektų masyvą, filtruotą pagal įvairias sąlygas.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

Galime filtruoti tik pagal `atributą`, perduodant jį kaip pirmąjį parametrą į `errors.where(:attr)`. Antrasis parametras naudojamas filtruoti norimą klaidos `tipą`, iškviečiant `errors.where(:attr, :type)`.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name)
=> [ ... ] # visos klaidos, susijusios su atributu :name

irb> person.errors.where(:name, :too_short)
=> [ ... ] # :too_short klaidos, susijusios su atributu :name
```

Galiausiai galime filtruoti pagal bet kokias `parinktis`, kurios gali egzistuoti tam tikro tipo klaidos objekte.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name, :too_short, minimum: 3)
=> [ ... ] # visos vardo klaidos, būnant per trumpam ir minimumas yra 2
```

Iš šių klaidų objektų galite gauti įvairią informaciją:

```irb
irb> error = person.errors.where(:name).last

irb> error.attribute
=> :name
irb> error.type
=> :too_short
irb> error.options[:count]
=> 3
```

Taip pat galite generuoti klaidos pranešimą:

```irb
irb> error.message
=> "is too short (minimum is 3 characters)"
irb> error.full_message
=> "Name is too short (minimum is 3 characters)"
```

Metodas [`full_message`][] sugeneruoja draugiškesnį vartotojui pranešimą, su didžiąja raidės pradžioje esančiu atributo pavadinimu. (Norėdami tinkinti `full_message` naudojamą formatą, žr. [I18n vadovą](i18n.html#active-model-methods).)


### `errors.add`

Metodas [`add`][] sukuria klaidos objektą, paimdamas `atributą`, klaidos `tipą` ir papildomą parinkčių maišą. Tai naudinga, rašant savo validatorių, nes leidžia apibrėžti labai specifines klaidos situacijas.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_plain, message: "is not cool enough"
  end
end
```
```irb
irb> person = Person.create
irb> person.errors.where(:name).first.type
=> :too_plain
irb> person.errors.where(:name).first.full_message
=> "Vardas nepakankamai įdomus"
```


### `errors[:base]`

Galite pridėti klaidas, kurios susijusios su objekto būsena kaip visuma, o ne
susijusios su konkrečiu atributu. Norėdami tai padaryti, turite naudoti `:base` kaip
atributą pridedant naują klaidą.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :base, :invalid, message: "Šis žmogus yra netinkamas, nes ..."
  end
end
```

```irb
irb> person = Person.create
irb> person.errors.where(:base).first.full_message
=> "Šis žmogus yra netinkamas, nes ..."
```

### `errors.size`

`size` metodas grąžina visų objekto klaidų skaičių.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.size
=> 2

irb> person = Person.new(name: "Andrea", email: "andrea@example.com")
irb> person.valid?
=> true
irb> person.errors.size
=> 0
```

### `errors.clear`

`clear` metodas naudojamas, kai norite išvalyti `errors`
kolekciją. Žinoma, iškvietus `errors.clear` netinkamam objektui, jis nebus
tapatybė: `errors` kolekcija bus tuščia, bet kitą kartą, kai iškviestumėte `valid?` ar bet kurį metodą, kuris bandytų išsaugoti šį objektą į
duomenų bazę, validacijos bus paleistos iš naujo. Jei viena iš validacijų nepavyks, `errors` kolekcija bus užpildyta iš naujo.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.empty?
=> false

irb> person.errors.clear
irb> person.errors.empty?
=> true

irb> person.save
=> false

irb> person.errors.empty?
=> false
```

Klaidų rodymas peržiūroje
-------------------------------------

Kai sukūrėte modelį ir pridėjote validacijas, jei šis modelis yra sukurtas per
internetinę formą, tikriausiai norite rodyti klaidos pranešimą, kai viena iš
validacijų nepavyksta.

Kadangi kiekviena programa tai tvarko skirtingai, „Rails“ neįtraukia jokių pagalbinių funkcijų, kurios padėtų jums tiesiogiai generuoti šiuos pranešimus. Tačiau, dėl gausybės metodų, kuriuos „Rails“ suteikia bendrai sąveikai su validacijomis, galite sukurti savo. Be to, generuojant skeletą, „Rails“ į `_form.html.erb` įdeda tam tikrą ERB kodą, kuris rodo visą klaidų sąrašą šiame modelyje.

Tarkime, turime modelį, kuris yra išsaugotas kintamajame `@article`, tai atrodo taip:

```html+erb
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "klaida") %> neleido išsaugoti šio straipsnio:</h2>

    <ul>
      <% @article.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

Be to, jei naudojate „Rails“ formos pagalbinius metodus, kai
validacijos klaida įvyksta lauke, jis sugeneruos papildomą `<div>` aplink
įrašą.

```html
<div class="field_with_errors">
  <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

Tuomet galite pritaikyti šį div pagal savo poreikius. Numatytasis skeletas, kurį
generuoja „Rails“, pavyzdžiui, prideda šį CSS taisyklę:

```css
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

Tai reiškia, kad bet koks laukas su klaida gali turėti 2 pikselių raudoną rėmelį.
[`errors`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-errors
[`invalid?`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-invalid-3F
[`valid?`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations.html#method-i-valid-3F
[Errors#squarebrackets]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-5B-5D
[`ActiveModel::Validations::HelperMethods`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html
[`Object#blank?`]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[`Object#present?`]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[`validates_uniqueness_of`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`validates_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_associated
[`validates_each`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_each
[`validates_with`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_with
[`ActiveModel::Validations`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html
[`with_options`]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[`ActiveModel::EachValidator`]: https://api.rubyonrails.org/classes/ActiveModel/EachValidator.html
[`ActiveModel::Validator`]: https://api.rubyonrails.org/classes/ActiveModel/Validator.html
[`validate`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate
[`ActiveModel::Errors`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html
[`ActiveModel::Error`]: https://api.rubyonrails.org/classes/ActiveModel/Error.html
[`full_message`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_message
[`where`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-where
[`add`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add
