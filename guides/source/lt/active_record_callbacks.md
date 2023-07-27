**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 320082396ef549e27ab4cb837ec975dd
Aktyviųjų įrašų atgaliniai kvietimai
=======================

Šis vadovas moko, kaip įsikišti į jūsų aktyviųjų įrašų objektų gyvavimo ciklo veikimą.

Po šio vadovo perskaitymo žinosite:

* Kai kurie įvykiai vyksta aktyviųjų įrašų objekto gyvavimo metu
* Kaip sukurti atgalinius kvietimus, kurie reaguotų į objekto gyvavimo ciklo įvykius.
* Kaip sukurti specialias klases, kurios apibrėžia bendrą elgesį jūsų atgaliniams kvietimams.

--------------------------------------------------------------------------------

Objekto gyvavimo ciklas
---------------------

Vykstant įprastam „Rails“ programos veikimui, objektai gali būti sukurti, atnaujinti ir sunaikinti. Aktyvusis įrašas suteikia galimybę įsikišti į šį *objekto gyvavimo ciklą*, kad galėtumėte valdyti savo programą ir jos duomenis.

Atgaliniai kvietimai leidžia jums paleisti logiką prieš arba po objekto būsenos pakeitimo.

```ruby
class Kūdikis < ApplicationRecord
  after_create -> { puts "Sveikiname!" }
end
```

```irb
irb> @baby = Baby.create
Sveikiname!
```

Kaip matysite, yra daug gyvavimo ciklo įvykių, ir galite pasirinkti prisijungti prie bet kurio iš jų, arba prieš juos, arba po jų.

Atgalinių kvietimų apžvalga
------------------

Atgaliniai kvietimai yra metodai, kurie yra iškviečiami tam tikru objekto gyvavimo ciklo momentu. Su atgaliniais kvietimais galima parašyti kodą, kuris bus vykdomas kiekvieną kartą, kai aktyvusis įrašo objektas yra sukurtas, išsaugotas, atnaujintas, ištrintas, patikrintas arba įkeltas iš duomenų bazės.

### Atgalinio kvietimo registracija

Norėdami naudoti galimus atgalinius kvietimus, turite juos užsiregistruoti. Galite įgyvendinti atgalinius kvietimus kaip įprastus metodus ir naudoti makro stiliaus klasės metodus, kad užsiregistruotumėte juos kaip atgalinius kvietimus:

```ruby
class Vartotojas < ApplicationRecord
  validates :prisijungimas, :el_paštas, presence: true

  before_validation :užtikrinkite_prisijungimą_turi_reikšmę

  private
    def užtikrinkite_prisijungimą_turi_reikšmę
      if prisijungimas.blank?
        self.prisijungimas = el_paštas unless el_paštas.blank?
      end
    end
end
```

Makro stiliaus klasės metodai taip pat gali priimti bloką. Svarstykite naudoti šį stilių, jei jūsų bloko viduje esantis kodas yra tokio trumpumo, kad jis telpa vienoje eilutėje:

```ruby
class Vartotojas < ApplicationRecord
  validates :prisijungimas, :el_paštas, presence: true

  before_create do
    self.vardas = prisijungimas.capitalize if vardas.blank?
  end
end
```

Alternatyviai galite perduoti proc objektą atgaliniam kvietimui, kuris bus iškviečiamas.

```ruby
class Vartotojas < ApplicationRecord
  before_create ->(vartotojas) { vartotojas.vardas = vartotojas.prisijungimas.capitalize if vartotojas.vardas.blank? }
end
```

Galiausiai galite apibrėžti savo atgalinį kvietimo objektą, apie kurį išsamiau kalbėsime vėliau [žemiau](#atgalinės-kvietimo-klasės).

```ruby
class Vartotojas < ApplicationRecord
  before_create MaybeAddName
end

class MaybeAddName
  def self.before_create(įrašas)
    if įrašas.vardas.blank?
      įrašas.vardas = įrašas.prisijungimas.capitalize
    end
  end
end
```

Atgaliniai kvietimai taip pat gali būti užregistruoti, kad būtų paleisti tik tam tikri gyvavimo ciklo įvykiai, tai leidžia visiškai kontroliuoti, kada ir kokiu kontekstu bus paleisti jūsų atgaliniai kvietimai.

```ruby
class Vartotojas < ApplicationRecord
  before_validation :normalizuok_vardą, on: :create

  # :on taip pat priima masyvą
  after_validation :nustatyk_vieta, on: [ :create, :update ]

  private
    def normalizuok_vardą
      self.vardas = vardas.downcase.titleize
    end

    def nustatyk_vieta
      self.vieta = LocationService.query(self)
    end
end
```

Laikoma geru būdu deklaruoti atgalinius kvietimus kaip privačius metodus. Jei jie lieka vieši, juos galima iškviesti iš modelio išorės ir pažeisti objekto uždarumo principą.

ĮSPĖJIMAS. Venkite kvietimų į `update`, `save` ar kitus metodus, kurie sukuria šalutinį poveikį objektui, savo atgaliniuose kvietimuose. Pavyzdžiui, nekvieskite `update(atributas: "reikšmė")` atgaliniame kvietime. Tai gali pakeisti modelio būseną ir gali sukelti netikėtus šalutinius poveikius vykdant įsipareigojimą. Vietoj to, galite saugiai priskirti reikšmes tiesiogiai (pavyzdžiui, `self.atributas = "reikšmė"`) `before_create` / `before_update` ar ankstesniuose atgaliniuose kvietimuose.

Galimi atgaliniai kvietimai
-------------------

Čia pateikiamas sąrašas su visais galimais aktyviųjų įrašų atgaliniais kvietimais, išvardytais tokia pačia tvarka, kaip jie bus iškviesti atitinkamų operacijų metu:

### Objekto sukūrimas

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


### Objekto atnaujinimas

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


ĮSPĖJIMAS. `after_save` vykdomas tiek kuriant, tiek atnaujinant, bet visada _po_ specifinių atgalinių kvietimų `after_create` ir `after_update`, nepriklausomai nuo to, kokia tvarka buvo vykdyti makro kvietimai.

### Objekto sunaikinimas

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]


PASTABA: `before_destroy` atgaliniai kvietimai turėtų būti įdėti prieš `dependent: :destroy` asociacijas (arba naudoti `prepend: true` parinktį), kad būtų užtikrinta, jog jie bus vykdomi prieš įrašai bus ištrinti pagal `dependent: :destroy`.

ĮSPĖJIMAS. `after_commit` suteikia labai skirtingas garantijas nei `after_save`, `after_update` ir `after_destroy`. Pavyzdžiui, jei `after_save` įvyksta išimtis, transakcija bus atšaukta ir duomenys nebus išsaugoti. O viskas, kas vyksta `after_commit`, gali garantuoti, kad transakcija jau baigta ir duomenys buvo išsaugoti duomenų bazėje. Daugiau informacijos apie [transakcinius atgalinius kvietimus](#transakcinių-kvietimų) žemiau.
### `after_initialize` ir `after_find`

Kiekvieną kartą, kai yra sukuriamas Active Record objektas, [`after_initialize`][] atgalinis kvietimas bus iškviestas, arba tiesiogiai naudojant `new`, arba kai įrašas yra įkeliamas iš duomenų bazės. Tai gali būti naudinga, norint išvengti būtinybės tiesiogiai perrašyti Active Record `initialize` metodą.

Įkeliant įrašą iš duomenų bazės, [`after_find`][] atgalinis kvietimas bus iškviestas. `after_find` yra iškviestas prieš `after_initialize`, jei abu yra apibrėžti.

PASTABA: `after_initialize` ir `after_find` atgaliniai kvietimai neturi `before_*` atitikmenų.

Jie gali būti užregistruoti taip pat kaip ir kiti Active Record atgaliniai kvietimai.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "Jūs sukūrėte objektą!"
  end

  after_find do |user|
    puts "Jūs radote objektą!"
  end
end
```

```irb
irb> User.new
Jūs sukūrėte objektą!
=> #<User id: nil>

irb> User.first
Jūs radote objektą!
Jūs sukūrėte objektą!
=> #<User id: 1>
```


### `after_touch`

[`after_touch`][] atgalinis kvietimas bus iškviestas, kai tik yra palietamas Active Record objektas.

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "Jūs palietėte objektą"
  end
end
```

```irb
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
Jūs palietėte objektą
=> true
```

Tai gali būti naudojama kartu su `belongs_to`:

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    puts 'Knyga buvo palietė'
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      puts 'Knyga/Biblioteka buvo palietė'
    end
end
```

```irb
irb> @book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @book.touch # iškviečia @book.library.touch
Knyga buvo palietė
Knyga/Biblioteka buvo palietė
=> true
```


Vykdomi atgaliniai kvietimai
-----------------

Šie metodai iškviečia atgalinius kvietimus:

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `destroy_by`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update`
* `update!`
* `valid?`

Be to, `after_find` atgalinis kvietimas yra iškviečiamas šių paieškos metodų:

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

`after_initialize` atgalinis kvietimas yra iškviečiamas kiekvieną kartą, kai yra sukuriamas naujas klasės objektas.

PASTABA: `find_by_*` ir `find_by_*!` metodai yra dinaminiai paieškos metodai, kurie automatiškai generuojami kiekvienam atributui. Sužinokite daugiau apie juos [Dinaminiai paieškos metodai](active_record_querying.html#dynamic-finders) skyriuje.

Atgalinių kvietimų praleidimas
------------------

Kaip ir su validacijomis, taip pat galima praleisti atgalinius kvietimus naudojant šiuos metodus:

* `decrement!`
* `decrement_counter`
* `delete`
* `delete_all`
* `delete_by`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `touch_all`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`
* `upsert`
* `upsert_all`

Tačiau šiuos metodus reikia naudoti atsargiai, nes svarbios verslo taisyklės ir programos logika gali būti laikomos atgaliniuose kvietimuose. Juos apeinant, nesuprasdami galimų padarinių, gali būti gauti netinkami duomenys.

Vykdomojo kodo sustabdymas
-----------------

Kai pradedate registruoti naujus atgalinius kvietimus savo modeliams, jie bus įtraukti į vykdymo eilę. Ši eilė apims visus modelio tikrinimus, užregistruotus atgalinius kvietimus ir duomenų bazės operaciją, kuri bus vykdoma.

Visa atgalinių kvietimų grandinė yra apgaubta transakcija. Jei bet kuris atgalinis kvietimas iškelia išimtį, vykdymo grandinė bus sustabdyta ir bus išduotas ROLLBACK. Norint sąmoningai sustabdyti grandinę, naudokite:

```ruby
throw :abort
```

ĮSPĖJIMAS. Bet kokia išimtis, kuri nėra `ActiveRecord::Rollback` arba `ActiveRecord::RecordInvalid`, bus iškelta iš naujo pagal „Rails“, kai atgalinė grandinė bus sustabdyta. Be to, tai gali sugadinti kodą, kuris nesitiki, kad metodai kaip `save` ir `update` (kurie įprastai bando grąžinti `true` arba `false`) iškels išimtį.

PASTABA: Jei `after_destroy`, `before_destroy` arba `around_destroy` atgaliniame kvietime iškyla `ActiveRecord::RecordNotDestroyed`, ji nebus iškelta iš naujo ir `destroy` metodas grąžins `false`.

Reliaciniai atgaliniai kvietimai
--------------------

Atgaliniai kvietimai veikia per modelio ryšius ir gali būti apibrėžti pagal juos. Pavyzdžiui, pagalvokime apie situaciją, kurioje vartotojas turi daug straipsnių. Vartotojo straipsniai turėtų būti sunaikinami, jei vartotojas yra sunaikinamas. Pridėkime `after_destroy` atgalinį kvietimą prie `User` modelio per jo ryšį su `Article` modeliu:

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Straipsnis sunaikintas'
  end
end
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
Straipsnis sunaikintas
=> #<User id: 1>
```
Sąlyginiai atgaliniai kvietimai
---------------------

Kaip ir su validacijomis, galime padaryti atgalinio kvietimo metodo iškvietimą sąlyginį, priklausomai nuo tam tikro predikato tenkinimo. Tai galime padaryti naudodami `:if` ir `:unless` parametrus, kurie gali priimti simbolį, `Proc` arba masyvą.

Galite naudoti `:if` parametrą, kai norite nurodyti, kada atgalinis kvietimas **turėtų** būti iškviestas. Jei norite nurodyti sąlygas, kada atgalinis kvietimas **neturėtų** būti iškviestas, galite naudoti `:unless` parametrą.

### Naudodami `:if` ir `:unless` su simboliu

Galite susieti `:if` ir `:unless` parametrus su simboliu, kuris atitinka predikato metodo pavadinimą, kuris bus iškviestas tiesiogiai prieš atgalinį kvietimą.

Naudodami `:if` parametrą, atgalinis kvietimas **nebus** vykdomas, jei predikato metodas grąžins **false**; naudojant `:unless` parametrą, atgalinis kvietimas **nebus** vykdomas, jei predikato metodas grąžins **true**. Tai yra dažniausiai naudojama parinktis.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

Naudojant šią registracijos formą taip pat galima užregistruoti kelis skirtingus predikatus, kurie turėtų būti iškviesti, norint patikrinti, ar atgalinis kvietimas turėtų būti vykdomas. Apie tai kalbėsime [žemiau](#multiple-callback-conditions).

### Naudodami `:if` ir `:unless` su `Proc`

Galima susieti `:if` ir `:unless` su `Proc` objektu. Ši parinktis geriausiai tinka rašant trumpus validacijos metodus, paprastai vienos eilutės:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

Kadangi `Proc` yra įvertinamas objekto kontekste, taip pat galima rašyti taip:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```

### Kelios atgalinio kvietimo sąlygos

`if` ir `unless` parametrai taip pat priima `Proc` arba metodo pavadinimų masyvą:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

Lengvai galite įtraukti `Proc` į sąlygų sąrašą:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, Proc.new { untrusted_author? }]
end
```

### Naudodami tiek `:if`, tiek `:unless`

Atgaliniai kvietimai gali derinti tiek `:if`, tiek `:unless` vienoje deklaracijoje:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: Proc.new { forum.parental_control? },
    unless: Proc.new { author.trusted? }
end
```

Atgalinis kvietimas vykdomas tik tada, kai visos `:if` sąlygos ir jokios `:unless` sąlygos neįvertintos kaip `true`.

Atgalinio kvietimo klasės
----------------

Kartais rašomi atgaliniai kvietimai bus pakankamai naudingi, kad juos galima būtų perpanaudoti kituose modeliuose. Active Record leidžia kurti klases, kurios apgaubia atgalinius kvietimus, kad juos būtų galima perpanaudoti.

Čia pateikiamas pavyzdys, kai sukuriamos klasės su `after_destroy` atgaliniu kvietimu, skirtu tvarkyti ištrintų failų valymą iš failų sistemos. Šis elgesys gali nebūti unikalus mūsų `PictureFile` modelyje ir galime norėti jį bendrinti, todėl gerai būtų tai apgaubti į atskirą klasę. Tai padarys testavimą ir pakeitimus šio elgesio labai lengvesnius.

```ruby
class FileDestroyerCallback
  def after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

Kai deklaruojama klasėje, kaip pavyzdžiui aukščiau, atgaliniai kvietimo metodai gaus modelio objektą kaip parametrą. Tai veiks bet kuriame modelyje, kuris naudoja klasę taip:

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback.new
end
```

Atkreipkite dėmesį, kad turėjome sukurti naują `FileDestroyerCallback` objektą, nes deklaravome atgalinį kvietimą kaip objekto metodo. Tai ypač naudinga, jei atgaliniai kvietimai naudoja sukurto objekto būseną. Tačiau dažnai bus prasmingiau deklaruoti atgalinius kvietimus kaip klasės metodus:

```ruby
class FileDestroyerCallback
  def self.after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

Kai atgalinio kvietimo metodas yra deklaruojamas šiuo būdu, mūsų modelyje nebereikės sukurti naujo `FileDestroyerCallback` objekto.

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback
end
```

Savo atgalinių kvietimų klasėse galite deklaruoti tiek kvietimų, kiek norite.

Transakcijos atgaliniai kvietimai
---------------------

### Užtikrinant nuoseklumą

Yra du papildomi atgaliniai kvietimai, kurie yra iškviečiami po duomenų bazės transakcijos užbaigimo: [`after_commit`][] ir [`after_rollback`][]. Šie atgaliniai kvietimai labai panašūs į `after_save` atgalinį kvietimą, išskyrus tai, kad jie nevykdomi, kol duomenų bazės pakeitimai yra patvirtinti arba atšaukti. Jie yra labiausiai naudingi, kai jūsų Active Record modeliams reikia sąveikauti su išorinėmis sistemomis, kurios nėra dalis duomenų bazės transakcijos.
Pavyzdžiui, apsvarstykime ankstesnį pavyzdį, kai modeliui `PictureFile` reikia ištrinti failą po susijusio įrašo sunaikinimo. Jei po `after_destroy` atkakliojo iškvietimo kyla išimtis ir transakcija grąžinama atgal, failas bus ištrintas, o modelis liks nesuderintas. Pavyzdžiui, tarkime, kad `picture_file_2` kode žemiau nėra galiojantis ir `save!` metodas iškelia klaidą.

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

Naudodami `after_commit` atkaklą galime tai apsvarstyti.

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

PASTABA: `:on` parametras nurodo, kada bus iškviečiamas atkaklis. Jei nepateikiate `:on` parametro, atkaklis bus iškviestas kiekvienai veiksmui.

### Kontekstas svarbus

Kadangi `after_commit` atkaklą dažniausiai naudojame tik su kūrimu, atnaujinimu ar ištrynimu, yra sinonimai šiems veiksmams:

* [`after_create_commit`][]
* [`after_update_commit`][]
* [`after_destroy_commit`][]

```ruby
class PictureFile < ApplicationRecord
  after_destroy_commit :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

ĮSPĖJIMAS. Kai transakcija baigiasi, `after_commit` arba `after_rollback` atkakliai yra iškviesti visiems modeliams, kurie buvo sukurti, atnaujinti ar ištrinti per tą transakciją. Tačiau, jei išimtis iškyla viename iš šių atkaklių, išimtis bus perduota aukštyn ir bet kokie likę `after_commit` arba `after_rollback` metodai nebus vykdomi. Todėl, jei jūsų atkaklio kodas gali sukelti išimtį, turėsite ją pagauti ir tvarkyti atkaklyje, kad leistumėte vykdyti kitus atkaklius.

ĮSPĖJIMAS. Kodas, vykdomas `after_commit` arba `after_rollback` atkakliuose, pats savaime nėra apgaubtas transakcija.

ĮSPĖJIMAS. Naudojant tiek `after_create_commit`, tiek `after_update_commit` su tuo pačiu metodo pavadinimu, veiks tik paskutinis apibrėžtas atkaklis, nes abu jie viduje yra sinonimai `after_commit`, kuris perrašo anksčiau apibrėžtus atkaklius su tuo pačiu metodo pavadinimu.

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'Vartotojas buvo išsaugotas duomenų bazėje'
    end
end
```

```irb
irb> @user = User.create # nieko nespausdina

irb> @user.save # atnaujinama @user
Vartotojas buvo išsaugotas duomenų bazėje
```

### `after_save_commit`

Taip pat yra [`after_save_commit`][], kuris yra sinonimas naudojant `after_commit` atkaklį tiek kūrimui, tiek atnaujinimui kartu:

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'Vartotojas buvo išsaugotas duomenų bazėje'
    end
end
```

```irb
irb> @user = User.create # kuriamas vartotojas
Vartotojas buvo išsaugotas duomenų bazėje

irb> @user.save # atnaujinama @user
Vartotojas buvo išsaugotas duomenų bazėje
```

### Transakcijų atkaklių tvarka

Kai apibrėžiame kelis transakcinius `after_` atkaklius (`after_commit`, `after_rollback`, ir t.t.), jų tvarka bus apversta nuo tos, kuri buvo apibrėžta.

```ruby
class User < ActiveRecord::Base
  after_commit { puts("tai iš tikrųjų bus iškviesta antra") }
  after_commit { puts("tai iš tikrųjų bus iškviesta pirmoji") }
end
```

PASTABA: Tai taikoma ir visiems `after_*_commit` variantams, pvz., `after_destroy_commit`.
[`after_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_create
[`after_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_commit
[`after_rollback`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_rollback
[`after_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_save
[`after_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-after_validation
[`around_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_create
[`around_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_save
[`before_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_create
[`before_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_save
[`before_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-before_validation
[`after_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_update
[`around_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_update
[`before_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_update
[`after_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_destroy
[`around_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_destroy
[`before_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_destroy
[`after_find`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_find
[`after_initialize`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_initialize
[`after_touch`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_touch
[`after_create_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_create_commit
[`after_destroy_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_destroy_commit
[`after_save_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_save_commit
[`after_update_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_update_commit
