**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 516604959485cfefb0e0d775d767699b
Aktyvusis įrašo asociacijos
==========================

Šiame vadove aptariamos aktyviojo įrašo asociacijos.

Po šio vadovo perskaitymo žinosite, kaip:

* Deklaruoti asociacijas tarp aktyviojo įrašo modelių.
* Suprasti įvairius aktyviojo įrašo asociacijų tipus.
* Naudoti modeliams pridėtus metodus, sukurdami asociacijas.

--------------------------------------------------------------------------------

Kodėl asociacijos?
-----------------

Rails aplinkoje _asociacija_ yra ryšys tarp dviejų aktyviojo įrašo modelių. Kodėl mums reikia asociacijų tarp modelių? Nes jos supaprastina ir palengvina bendrus veiksmus jūsų kode.

Pavyzdžiui, pagalvokite apie paprastą Rails aplikaciją, kurioje yra modelis autoriai ir modelis knygos. Kiekvienas autorius gali turėti daug knygų.

Be asociacijų, modelių deklaracijos atrodytų taip:

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

Dabar, jei norėtume pridėti naują knygą esamam autorius, turėtume tai padaryti taip:

```ruby
@book = Book.create(published_at: Time.now, author_id: @author.id)
```

Arba pagalvokite apie autoriaus ištrynimą ir užtikrinimą, kad visos jo knygos taip pat būtų ištrintos:

```ruby
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

Naudojant aktyviojo įrašo asociacijas, galime supaprastinti šiuos - ir kitus - veiksmus, deklaratyviai pranešdami Rails, kad tarp dviejų modelių yra ryšys. Čia yra peržiūrėtas kodas, skirtas autorių ir knygų nustatymui:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Padarius šį pakeitimą, naujos knygos sukūrimas tam tikram autorius tampa paprastesnis:

```ruby
@book = @author.books.create(published_at: Time.now)
```

Autoriaus ir visų jo knygų ištrynimas yra *daug* paprastesnis:

```ruby
author.destroy
```

Norėdami sužinoti daugiau apie skirtingus asociacijų tipus, perskaitykite šio vadovo kitą skyrių. Toliau pateikiami keletas patarimų ir gudrybių, kaip dirbti su asociacijomis, o po to - išsamus nuorodų ir parinkčių sąrašas asociacijoms Rails.

Asociacijų tipai
-------------------------

Rails palaiko šešis asociacijų tipus, kiekvienas su tam tikru naudojimo atveju.

Štai visų palaikomų tipų sąrašas su nuoroda į jų API dokumentaciją, kurioje galite rasti išsamesnės informacijos apie tai, kaip juos naudoti, jų metodo parametrus ir kt.

* [`belongs_to`][]
* [`has_one`][]
* [`has_many`][]
* [`has_many :through`][`has_many`]
* [`has_one :through`][`has_one`]
* [`has_and_belongs_to_many`][]

Asociacijos yra įgyvendinamos naudojant makro stiliaus iškvietimus, todėl galite deklaratyviai pridėti funkcijas prie savo modelių. Pavyzdžiui, deklaruodami, kad vienas modelis `priklauso` kitam, jūs nurodote Rails, kad tarp dviejų modelių egzempliorių bus išlaikoma [Pagrindinio rakto](https://en.wikipedia.org/wiki/Primary_key)-[Užsienio rakto](https://en.wikipedia.org/wiki/Foreign_key) informacija, ir taip pat gaunate keletą naudingų metodų, pridėtų prie jūsų modelio.

Šio vadovo likusioje dalyje sužinosite, kaip deklaruoti ir naudoti įvairias asociacijų formas. Bet pirmiausia trumpas įvadas į situacijas, kuriose tinkamas kiekvienos asociacijos tipas.


### `belongs_to` asociacija

[`belongs_to`][] asociacija sukuria ryšį su kitu modeliu, kad kiekvienas deklaruojančio modelio egzempliorius "priklauso" vienam kito modelio egzemplioriui. Pavyzdžiui, jei jūsų aplikacija apima autorius ir knygas, ir kiekviena knyga gali būti priskirta tik vienam autorius, knygos modelį galėtumėte deklaruoti taip:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

![belongs_to asociacijos diagrama](images/association_basics/belongs_to.png)

PASTABA: `belongs_to` asociacijos _turi_ naudoti vienaskaitos formą. Jei pirmiau pateiktame pavyzdyje `Book` modelyje `author` asociacijai būtų naudojama daugiskaitos forma ir bandoma sukurti egzempliorių naudojant `Book.create(authors: author)`, būtumėte informuotas apie "neinicijuotą konstantą Book::Authors". Tai yra todėl, kad Rails automatiškai nustato klasės pavadinimą iš asociacijos pavadinimo. Jei asociacijos pavadinimas būtų neteisingai daugiskaitinė, tuomet ir nustatytas klasės pavadinimas būtų neteisingai daugiskaitinis.

Atitinkama migracija galėtų atrodyti taip:

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

Kai naudojamas vienas, `belongs_to` sukuria vienkrypčią vienas-į-vieną sąsają. Todėl kiekviena knyga pirmiau pateiktame pavyzdyje "žino" savo autorių, bet autoriai nežino apie savo knygas.
Norėdami nustatyti [abipusį ryšį](#abipusiai-ryšiai) - naudokite `belongs_to` kartu su `has_one` arba `has_many` kitame modelyje, šiuo atveju Autoriaus modelyje.

`belongs_to`, jei nustatoma, kad `optional` yra `true`, neužtikrina nuorodos nuoseklumo, todėl priklausomai nuo naudojimo atvejo, galbūt taip pat reikės pridėti duomenų bazės lygmens užsienio rakto apribojimą nuorodos stulpelyje, panašiai kaip čia:
```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```

### `has_one` asociacija

[`has_one`][] asociacija nurodo, kad vienas kitas modelis turi nuorodą į šį modelį. Šis modelis gali būti gautas per šią asociaciją.

Pavyzdžiui, jei kiekvienas tiekėjas jūsų programoje turi tik vieną sąskaitą, tiekėjo modelį galėtumėte apibrėžti taip:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

Pagrindinis skirtumas nuo `belongs_to` yra tas, kad nuorodos stulpelis `supplier_id` yra kitame lauke:

![has_one asociacijos diagrama](images/association_basics/has_one.png)

Atitinkanti migracija galėtų atrodyti taip:

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end
  end
end
```

Priklausomai nuo naudojimo atvejo, gali prireikti sukurti unikalų indeksą ir/arba
užsienio rakto apribojimą tiekėjo stulpeliui sąskaitų lentelėje. Tokiu atveju, stulpelio apibrėžimas galėtų atrodyti taip:

```ruby
create_table :accounts do |t|
  t.belongs_to :supplier, index: { unique: true }, foreign_key: true
  # ...
end
```

Ši sąsaja gali būti [dvikryptė](#dvikryptės-asociacijos), kai naudojama kartu su `belongs_to` kitame modelyje.

### `has_many` asociacija

[`has_many`][] asociacija panaši į `has_one`, bet nurodo vieno į daugelį ryšį su kitu modeliu. Dažnai šią asociaciją rasite "kitoje pusėje" esančią `belongs_to` asociaciją. Ši asociacija nurodo, kad kiekvienas modelio atvejis turi nulį arba daugiau kitų modelio atvejų. Pavyzdžiui, programoje, kurioje yra autoriai ir knygos, autoriaus modelį galėtumėte apibrėžti taip:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

PASTABA: Kito modelio pavadinimas daugiskaitinamas, kai deklaruojama `has_many` asociacija.

![has_many asociacijos diagrama](images/association_basics/has_many.png)

Atitinkanti migracija galėtų atrodyti taip:

```ruby
class CreateAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

Priklausomai nuo naudojimo atvejo, paprastai gerai būtų sukurti neunikalų indeksą ir galbūt
užsienio rakto apribojimą autoriaus stulpeliui knygų lentelėje:

```ruby
create_table :books do |t|
  t.belongs_to :author, index: true, foreign_key: true
  # ...
end
```

### `has_many :through` asociacija

[`has_many :through`][`has_many`] asociacija dažnai naudojama nustatyti daugybės su kitu modeliu ryšį. Ši asociacija nurodo, kad deklaruojantis modelis gali būti suderintas su nuliu arba daugiau kitų modelio atvejų, einant _per_ trečią modelį. Pavyzdžiui, pagalvokite apie medicinos praktiką, kur pacientai užsiregistruoja pas gydytojus. Atitinkamos asociacijos deklaracijos galėtų atrodyti taip:

```ruby
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :physician
  belongs_to :patient
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end
```

![has_many :through asociacijos diagrama](images/association_basics/has_many_through.png)

Atitinkanti migracija galėtų atrodyti taip:

```ruby
class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :physicians do |t|
      t.string :name
      t.timestamps
    end

    create_table :patients do |t|
      t.string :name
      t.timestamps
    end

    create_table :appointments do |t|
      t.belongs_to :physician
      t.belongs_to :patient
      t.datetime :appointment_date
      t.timestamps
    end
  end
end
```

Jungiamų modelių kolekciją galima valdyti naudojant [`has_many` asociacijos metodus](#has-many-asociacijos-referencija).
Pavyzdžiui, jei priskiriate:

```ruby
physician.patients = patients
```

Tada nauji jungiamų modelių objektai automatiškai sukuriami naujai susietiems objektams.
Jei kai kurie, kurie anksčiau egzistavo, dabar trūksta, tada jų jungtys automatiškai ištrinamos.

ĮSPĖJIMAS: Jungiamų modelių automatinis trynimas yra tiesioginis, jokie trynimo atgaliniai iškvietimai nėra paleidžiami.

`has_many :through` asociacija taip pat naudinga nustatant "trumpinius" perrišimus per įdėtus `has_many` asociacijas. Pavyzdžiui, jei dokumentas turi daug skyrių, o skyrius turi daug paragrafų, kartais norėsite gauti paprastą paragrafų kolekciją dokumente. Tai galėtumėte nustatyti taip:

```ruby
class Document < ApplicationRecord
  has_many :sections
  has_many :paragraphs, through: :sections
end

class Section < ApplicationRecord
  belongs_to :document
  has_many :paragraphs
end

class Paragraph < ApplicationRecord
  belongs_to :section
end
```

Nurodžius `through: :sections`, „Rails“ dabar supras:

```ruby
@document.paragraphs
```

### `has_one :through` asociacija

[`has_one :through`][`has_one`] asociacija nustato vieno į vieną ryšį su kitu modeliu. Ši asociacija nurodo, kad deklaruojantis modelis gali būti suderintas su vienu kitu modelio atveju, einant _per_ trečią modelį.
Pavyzdžiui, jei kiekvienas tiekėjas turi vieną sąskaitą, o kiekviena sąskaita yra susijusi su viena sąskaitos istorija, tada tiekėjo modelis galėtų atrodyti taip:
```ruby
class Supplier < ApplicationRecord
  has_one :account
  has_one :account_history, through: :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  has_one :account_history
end

class AccountHistory < ApplicationRecord
  belongs_to :account
end
```

![has_one :through Association Diagram](images/association_basics/has_one_through.png)

Atitinkantis migracijos kodas gali atrodyti taip:

```ruby
class CreateAccountHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account
      t.integer :credit_rating
      t.timestamps
    end
  end
end
```

### `has_and_belongs_to_many` asociacija

[`has_and_belongs_to_many`][] asociacija sukuria tiesioginį daugiau į daugiau ryšį su kitu modeliu, be tarpinio modelio.
Ši asociacija nurodo, kad kiekvienas deklaruojančio modelio atvejis nurodo nulį ar daugiau kito modelio atvejų.
Pavyzdžiui, jei jūsų programa apima montavimus ir dalis, kur kiekvienas montavimas turi daug dalies ir kiekviena dalis yra daug montavimų, galite deklaruoti modelius taip:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

![has_and_belongs_to_many Association Diagram](images/association_basics/habtm.png)

Atitinkantis migracijos kodas gali atrodyti taip:

```ruby
class CreateAssembliesAndParts < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies do |t|
      t.string :name
      t.timestamps
    end

    create_table :parts do |t|
      t.string :part_number
      t.timestamps
    end

    create_table :assemblies_parts, id: false do |t|
      t.belongs_to :assembly
      t.belongs_to :part
    end
  end
end
```

### Pasirinkimas tarp `belongs_to` ir `has_one`

Jei norite nustatyti vieno į vieną ryšį tarp dviejų modelių, turėsite pridėti `belongs_to` vienam ir `has_one` kitam. Kaip žinote, kuris yra kuris?

Skirtumas yra tai, kur dedate svetimąjį raktą (jis eina į lentelę, skirtą klasės, deklaruojančios `belongs_to` asociaciją), tačiau taip pat turėtumėte apgalvoti ir duomenų tikrosios reikšmės. `has_one` ryšys sako, kad vienas iš kažko yra jūsų - tai yra, kad kažkas rodo atgal į jus. Pavyzdžiui, daugiau prasmės pasakyti, kad tiekėjas turi sąskaitą, nei kad sąskaita turi tiekėją. Tai rodo, kad teisingi ryšiai yra tokie:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

Atitinkantis migracijos kodas gali atrodyti taip:

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.bigint  :supplier_id
      t.string  :account_number
      t.timestamps
    end

    add_index :accounts, :supplier_id
  end
end
```

PASTABA: Naudodami `t.bigint :supplier_id` padarote aiškų ir aiškų svetimojo rakto pavadinimą. Esamose „Rails“ versijose galite paslėpti šį įgyvendinimo detalių naudojant `t.references :supplier` vietoj to.

### Pasirinkimas tarp `has_many :through` ir `has_and_belongs_to_many`

„Rails“ siūlo dvi skirtingas būdas nurodyti daug į daug ryšį tarp modelių. Pirmasis būdas yra naudoti `has_and_belongs_to_many`, kuris leidžia jums tiesiogiai nustatyti asociaciją:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Antrasis būdas nurodyti daug į daug ryšį yra naudoti `has_many :through`. Tai sukuria asociaciją netiesiogiai, per jungiamąjį modelį:

```ruby
class Assembly < ApplicationRecord
  has_many :manifests
  has_many :parts, through: :manifests
end

class Manifest < ApplicationRecord
  belongs_to :assembly
  belongs_to :part
end

class Part < ApplicationRecord
  has_many :manifests
  has_many :assemblies, through: :manifests
end
```

Paprastiausias taisyklės ženklas yra tai, kad turėtumėte nustatyti `has_many :through` ryšį, jei norite dirbti su ryšio modeliu kaip su nepriklausoma vienete. Jei jums nereikia nieko daryti su ryšio modeliu, galbūt paprasčiau nustatyti `has_and_belongs_to_many` ryšį (nors turėsite prisiminti sukurti jungiamąją lentelę duomenų bazėje).

Turėtumėte naudoti `has_many :through`, jei jums reikia validacijų, atgalinių iškvietimų ar papildomų atributų jungiamajame modelyje.

### Polimorfiniai ryšiai

Šiek tiek pažangesnis asociacijų variantas yra _polimorfinis ryšys_. Su polimorfiniais ryšiais modelis gali priklausyti daugiau nei vienam kitam modeliui, vienoje asociacijoje. Pavyzdžiui, galite turėti paveikslėlio modelį, kuris priklauso arba darbuotojo modeliui, arba produkto modeliui. Čia pateikiama, kaip tai galėtų būti deklaruota:

```ruby
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end
```

Galite manyti, kad polimorfinis `belongs_to` deklaravimas nustato sąsają, kurią gali naudoti bet kuris kitas modelis. Iš `Employee` modelio atvejo galite gauti paveikslėlių kolekciją: `@employee.pictures`.
Panašiai, galite gauti `@product.pictures`.

Jei turite `Picture` modelio egzempliorių, galite pasiekti jo tėvą per `@picture.imageable`. Norint tai veiktų, modelyje, kuris deklaruoja polimorfinį sąsają, reikia nurodyti tiek užsienio rakto stulpelį, tiek tipo stulpelį:

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string  :name
      t.bigint  :imageable_id
      t.string  :imageable_type
      t.timestamps
    end

    add_index :pictures, [:imageable_type, :imageable_id]
  end
end
```

Šią migraciją galima supaprastinti naudojant `t.references` formą:

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true
      t.timestamps
    end
  end
end
```

![Polimorfinės sąsajos diagrama](images/association_basics/polymorphic.png)

### Savęs jungtys

Projektuojant duomenų modelį, kartais rasite modelį, kuris turėtų sąryšį su savimi. Pavyzdžiui, galite norėti saugoti visus darbuotojus viename duomenų bazės modelyje, bet galėti sekti ryšius, pvz., tarp vadovo ir pavaldinių. Tokią situaciją galima modeliuoti naudojant savęs jungtis:

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true
end
```

Naudojant šią konfigūraciją, galite gauti `@employee.subordinates` ir `@employee.manager`.

Migracijos/schemos metu modeliui patiems pridėsite nuorodų stulpelį.

```ruby
class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :manager, foreign_key: { to_table: :employees }
      t.timestamps
    end
  end
end
```

PASTABA: `to_table` parametras, perduodamas `foreign_key` ir kt., paaiškinamas [`SchemaStatements#add_reference`][connection.add_reference].

Patarimai, gudrybės ir įspėjimai
--------------------------------

Štai keletas dalykų, kuriuos turėtumėte žinoti, kad efektyviai naudotumėte Active Record sąsajas savo „Rails“ programose:

* Kešavimo valdymas
* Vengiant pavadinimų konfliktų
* Schemos atnaujinimas
* Sąsajos apimties valdymas
* Dviejų krypčių sąsajos

### Kešavimo valdymas

Visi sąsajų metodai yra pagrįsti kešavimu, kuris leidžia išsaugoti naujausio užklausos rezultatą tolimesnėms operacijoms. Kešas netgi bendrinamas tarp metodų. Pavyzdžiui:

```ruby
# gauna knygas iš duomenų bazės
author.books.load

# naudoja kešuotą knygų kopiją
author.books.size

# naudoja kešuotą knygų kopiją
author.books.empty?
```

Bet ką daryti, jei norite atnaujinti kešą, nes duomenys gali būti pakeisti kitos programos dalies? Tiesiog iškvieskite `reload` sąsajoje:

```ruby
# gauna knygas iš duomenų bazės
author.books.load

# naudoja kešuotą knygų kopiją
author.books.size

# atmeta kešuotą knygų kopiją ir grįžta prie duomenų bazės
author.books.reload.empty?
```

### Vengiant pavadinimų konfliktų

Negalite laisvai naudoti bet kokio pavadinimo savo sąsajoms. Kadangi sąsajos sukūrimas prideda to pavadinimo metodą modelyje, bloga mintis suteikti sąsajai pavadinimą, kuris jau naudojamas `ActiveRecord::Base` egzemplioriaus metode. Sąsajos metodas pakeistų pagrindinį metodą ir sugadintų dalykus. Pavyzdžiui, `attributes` ar `connection` yra blogi pavadinimai sąsajoms.

### Schemos atnaujinimas

Sąsajos yra labai naudingos, bet jos nėra magiškos. Jūs atsakingas už duomenų bazės schemos palaikymą, kad ji atitiktų jūsų sąsajas. Praktiškai tai reiškia dvi dalykas, priklausomai nuo to, kokias sąsajas kuriate. `belongs_to` sąsajoms reikia sukurti užsienio raktus, o `has_and_belongs_to_many` sąsajoms reikia sukurti atitinkamą jungiamąją lentelę.

#### Užsienio raktų sukūrimas `belongs_to` sąsajoms

Kai deklaruoju `belongs_to` sąsają, reikia sukurti užsienio raktus, kaip tinkama. Pavyzdžiui, apsvarstykite šį modelį:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Ši deklaracija turi būti palaikyta atitinkamu užsienio rakto stulpeliu knygų lentelėje. Visiškai naujai lentelės migracija galėtų atrodyti taip:

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.datetime   :published_at
      t.string     :book_number
      t.references :author
    end
  end
end
```

O esamai lentelės migracija galėtų atrodyti taip:

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[7.1]
  def change
    add_reference :books, :author
  end
end
```

PASTABA: Jei norite [užtikrinti referencinį vientisumą duomenų bazės lygmeniu][foreign_keys], prie „reference“ stulpelių deklaracijų viršuje pridėkite `foreign_key: true` parametrą.

#### Jungiamųjų lentelių sukūrimas `has_and_belongs_to_many` sąsajoms

Jei kuriate `has_and_belongs_to_many` sąsają, turite išreiškiai sukurti jungiamąją lentelę. Jei jungiamosios lentelės pavadinimas nėra nurodytas naudojant `:join_table` parametrą, „Active Record“ sukuria pavadinimą, naudodamas klasės pavadinimų leksikografinę tvarką. Taigi sąsaja tarp autoriaus ir knygos modelių suteiks numatytąjį jungiamosios lentelės pavadinimą „authors_books“, nes „a“ lenkia „b“ leksikografinėje tvarkoje.
ĮSPĖJIMAS: Modelių pavadinimų pirmenybės nustatomos naudojant `String` tipo `<=>` operatorių. Tai reiškia, kad jei eilutės yra skirtingo ilgio ir jos yra lygios iki trumpiausio ilgio, ilgesnė eilutė laikoma aukštesne nei trumpesnė pagal leksikografinę tvarką. Pavyzdžiui, tikėtasi, kad lentelės "paper_boxes" ir "papers" generuos jungiamosios lentelės pavadinimą "papers_paper_boxes" dėl pavadinimo "paper_boxes" ilgio, tačiau iš tikrųjų generuojamas jungiamosios lentelės pavadinimas yra "paper_boxes_papers" (nes pabraukimas '\_' leksikografiškai _mažesnis_ nei 's' daugelyje koduotės sistemų).

Kokiu būdu būtų pavadintas, jungiamąją lentelę reikia sukurti rankiniu būdu naudojant tinkamą migraciją. Pavyzdžiui, apsvarstykime šiuos ryšius:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Šiems ryšiams reikia sukurti migraciją, kuri sukuria `assemblies_parts` lentelę. Ši lentelė turėtų būti sukurta be pirminio rakto:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.bigint :assembly_id
      t.bigint :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end
```

Mes perduodame `id: false` į `create_table`, nes ši lentelė neatitinka modelio. Tai reikalinga, kad sąryšis veiktų tinkamai. Jei pastebite keistą elgesį `has_and_belongs_to_many` sąryšyje, pvz., sugadintus modelio ID ar išimtis dėl konfliktuojančių ID, tikėtina, kad pamiršote šį dalyką.

Paprastumui taip pat galite naudoti metodą `create_join_table`:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :assemblies, :parts do |t|
      t.index :assembly_id
      t.index :part_id
    end
  end
end
```

### Valdant sąryšio apimtį

Pagal numatytuosius nustatymus sąryšiai ieško objektų tik esamo modulio apimtyje. Tai gali būti svarbu, kai deklaruoji Active Record modelius modulyje. Pavyzdžiui:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end

    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

Tai veiks gerai, nes tiek `Supplier`, tiek `Account` klasės yra apibrėžtos toje pačioje apimtyje. Tačiau šis pavyzdys _neveiks_, nes `Supplier` ir `Account` yra apibrėžti skirtingose apimtyse:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

Norėdami susieti modelį su modeliu kitame vardų erdvėje, turite nurodyti visą klasės pavadinimą sąryšio deklaracijoje:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account,
        class_name: "MyApplication::Billing::Account"
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier,
        class_name: "MyApplication::Business::Supplier"
    end
  end
end
```

### Dvigubi sąryšiai

Įprasta, kad sąryšiai veikia dviem kryptimis, reikalaujant deklaracijos dviejuose skirtinguose modeliuose:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Active Record automatiškai bandys nustatyti, kad šie du modeliai turi dvikryptį sąryšį pagal sąryšio pavadinimą. Ši informacija leidžia Active Record:

* Išvengti nereikalingų užklausų jau įkeltiems duomenims:

    ```irb
    irb> author = Author.first
    irb> author.books.all? do |book|
    irb>   book.author.equal?(author) # Papildomos užklausos čia nevykdomos
    irb> end
    => true
    ```

* Išvengti nesuderinamų duomenų (kadangi įkelta tik viena `Author` objekto kopija):

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Pakeistas pavadinimas"
    irb> author.name == book.author.name
    => true
    ```

* Automatiškai išsaugoti sąryšius daugiau atvejų:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => true
    ```

* Patikrinti sąryšio [buvimą](active_record_validations.html#presence) ir [nebuvimą](active_record_validations.html#absence) daugiau atvejų:

    ```irb
    irb> book = Book.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => true
    ```

Active Record automatiškai atpažįsta daugumą sąryšių su standartiniais pavadinimais. Tačiau dvikryptiems sąryšiams, kuriuose yra `:through` arba `:foreign_key` parinktys, automatinis atpažinimas neveiks.

Papildomai, automatinis atpažinimas neveiks, jei priešingame sąryšio objekte yra pasirinkti pasirinktiniai ribojimai arba jei pats sąryšis turi pasirinktinius ribojimus, nebent [`config.active_record.automatic_scope_inversing`][] nustatymas būtų nustatytas kaip true (numatytasis naujiems programoms).

Pavyzdžiui, apsvarstykime šiuos modelių deklaravimus:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Dėl `:foreign_key` parinkties Active Record nebeautomatiškai atpažins dvikryptį sąryšį. Tai gali sukelti problemų jūsų programoje:
* Vykdant nereikalingus užklausimus tais pačiais duomenimis (šiuo atveju sukeliant N+1 užklausas):

    ```irb
    irb> author = Author.first
    irb> author.books.any? do |book|
    irb>   book.author.equal?(author) # Šis vykdo autoriaus užklausą kiekvienam knygai
    irb> end
    => false
    ```

* Nuorodų į modelį, turintį nesuderintus duomenis:

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Pakeistas vardas"
    irb> author.name == book.author.name
    => false
    ```

* Nepavyksta automatiškai įrašyti susijusių objektų:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => false
    ```

* Nepavyksta patikrinti, ar objektas yra privalomas arba nebūtinas:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Autorius turi egzistuoti"]
    ```

Active Record teikia `:inverse_of` parinktį, leidžiančią aiškiai nurodyti abipusius ryšius:

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Įtraukus `:inverse_of` parinktį `has_many` asociacijos deklaracijoje,
Active Record dabar atpažįsta abipusį ryšį ir elgiasi kaip pirmiau pateiktuose pavyzdžiuose.


Išsamus asociacijų aprašymas
------------------------------

Šiose sekcijose pateikiami kiekvieno tipo asociacijos detalės, įskaitant pridedamus metodus ir parinktis, kurias galite naudoti deklaruodami asociaciją.

### `belongs_to` asociacijos aprašymas

Duomenų bazės terminais, `belongs_to` asociacija reiškia, kad šio modelio lentelėje yra stulpelis, kuris atitinka nuorodą į kitą lentelę.
Tai gali būti naudojama nustatyti vieno į vieną arba vieno į daugelį ryšius, priklausomai nuo nustatymo.
Jei kito klasės lentelėje nuoroda yra vieno į vieną ryšį, tada turėtumėte naudoti `has_one` vietoj to.

#### Metodai, pridedami `belongs_to`

Kai deklaruoji `belongs_to` asociaciją, deklaruojančiajai klasei automatiškai pridedami 8 metodai, susiję su asociacija:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`
* `association_changed?`
* `association_previously_changed?`

Visuose šiuose metodųose `association` yra pakeičiama simboliu, kuris yra pirmasis argumentas `belongs_to`. Pavyzdžiui, turint deklaraciją:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Kiekvienas `Book` modelio objektas turės šiuos metodus:

* `author`
* `author=`
* `build_author`
* `create_author`
* `create_author!`
* `reload_author`
* `reset_author`
* `author_changed?`
* `author_previously_changed?`

PASTABA: Inicializuojant naują `has_one` arba `belongs_to` asociaciją, reikia naudoti `build_` prefiksą, kad sukurtumėte asociaciją, o ne `association.build` metodą, kuris būtų naudojamas `has_many` arba `has_and_belongs_to_many` asociacijoms. Norint sukurti vieną, naudokite `create_` prefiksą.

##### `association`

`association` metodas grąžina susijusį objektą, jei toks yra. Jei susijęs objektas nerastas, grąžinamas `nil`.

```ruby
@author = @book.author
```

Jei susijęs objektas jau buvo gautas iš duomenų bazės šiam objektui, bus grąžinta talpykloje esanti versija. Norint pakeisti šį elgesį (ir priversti perskaityti iš duomenų bazės), iškviečiama `#reload_association` ant pagrindinio objekto.

```ruby
@author = @book.reload_author
```

Norint iškrauti talpykloje esančią susijusio objekto versiją - tai sukels naują užklausą į duomenų bazę - iškviečiama `#reset_association` ant pagrindinio objekto.

```ruby
@book.reset_author
```

##### `association=(associate)`

`association=` metodas priskiria susijusį objektą šiam objektui. Užkulisiuose tai reiškia ištraukti pagrindinės rakto reikšmę iš susijusio objekto ir nustatyti šio objekto užsienio rakto reikšmę ta pačia verte.

```ruby
@book.author = @author
```

##### `build_association(attributes = {})`

`build_association` metodas grąžina naują susijusio tipo objektą. Šis objektas bus sukuriamas iš perduotų atributų, ir bus nustatytas ryšys per šio objekto užsienio rakto reikšmę, bet susijęs objektas _nebus_ dar išsaugotas.

```ruby
@author = @book.build_author(author_number: 123,
                             author_name: "John Doe")
```

##### `create_association(attributes = {})`

`create_association` metodas grąžina naują susijusio tipo objektą. Šis objektas bus sukuriamas iš perduotų atributų, bus nustatytas ryšys per šio objekto užsienio rakto reikšmę ir, kai jis praeis visus nurodytus patikrinimus asocijuotame modele, susijęs objektas _bus_ išsaugotas.

```ruby
@author = @book.create_author(author_number: 123,
                              author_name: "John Doe")
```

##### `create_association!(attributes = {})`

Daro tą patį, kaip ir `create_association` aukščiau, bet jei įrašas yra netinkamas, iškelia `ActiveRecord::RecordInvalid` išimtį.

##### `association_changed?`

`association_changed?` metodas grąžina `true`, jei naujas susijęs objektas buvo priskirtas ir užsienio rakto reikšmė bus atnaujinta kitame įraše.
```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.author_changed? # => true

@book.save!
@book.author_changed? # => false
```

##### `association_previously_changed?`

`association_previously_changed?` metodas grąžina `true`, jei ankstesnis įrašas atnaujintas ir asociacija nukreipiama į naują asocijuotą objektą.

```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_previously_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.save!
@book.author_previously_changed? # => true
```

#### `belongs_to` parinktys

Nors „Rails“ naudoja protingus numatytuosius nustatymus, kurie daugeliu atvejų veiks gerai, gali būti situacijų, kai norite pritaikyti `belongs_to` asociacijos nuorodos elgesį. Tokias pritaikymus galima lengvai atlikti, perduodant parinktis ir apribojimus, kai kuriate asociaciją. Pavyzdžiui, ši asociacija naudoja dvi tokiąsias parinktis:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at,
    counter_cache: true
end
```

[`belongs_to`][] asociacija palaiko šias parinktis:

* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:primary_key`
* `:inverse_of`
* `:polymorphic`
* `:touch`
* `:validate`
* `:optional`

##### `:autosave`

Jei nustatote `:autosave` parinktį į `true`, „Rails“ išsaugos visus įkeltus asociacijos narius ir sunaikins tuos narius, kurie pažymėti sunaikinimui, kai išsaugosite pagrindinį objektą. Nustatant `:autosave` į `false`, tai nėra tas pats kaip nustatyti `:autosave` parinktį. Jei `:autosave` parinktis nenurodyta, tuomet nauji susiję objektai bus išsaugoti, tačiau atnaujinti susiję objektai nebus išsaugoti.

##### `:class_name`

Jei kitos modelio pavadinimas negali būti išvestas iš asociacijos pavadinimo, galite naudoti `:class_name` parinktį, kad nurodytumėte modelio pavadinimą. Pavyzdžiui, jei knyga priklauso autorui, bet autorių turinčio modelio tikras pavadinimas yra `Patron`, tai galite nustatyti taip:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron"
end
```

##### `:counter_cache`

`:counter_cache` parinktis gali būti naudojama, norint efektyviau rasti priklausančių objektų skaičių. Pagalvokime apie šiuos modelius:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :books
end
```

Su šiais deklaracijomis, `@author.books.size` 
užklausa reikalauja duomenų bazės skambučio, kad būtų atlikta `COUNT(*)` užklausa. Norint išvengti šio skambučio, galite pridėti skaitiklio talpyklą prie _priklausančio_ modelio:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end

class Author < ApplicationRecord
  has_many :books
end
```

Su šia deklaracija „Rails“ laikys talpyklos reikšmę naujausia ir grąžins ją kaip atsakymą į `size` metodą.

Nors `:counter_cache` parinktis yra nurodyta modelyje, kuriame yra `belongs_to` deklaracija, faktinis stulpelis turi būti pridėtas prie _susijusio_ (`has_many`) modelio. Pavyzdžiui, turėtumėte pridėti stulpelį, pavadinimu `books_count`, prie `Author` modelio.

Galite pakeisti numatytąjį stulpelio pavadinimą, nurodydami pasirinktinį stulpelio pavadinimą `counter_cache` deklaracijoje, o ne `true`. Pavyzdžiui, norint naudoti `count_of_books` vietoje `books_count`:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: :count_of_books
end

class Author < ApplicationRecord
  has_many :books
end
```

PASTABA: `:counter_cache` parinktį reikia nurodyti tik asociacijos `belongs_to` pusėje.

Skaitiklio talpyklos stulpeliai pridedami prie savininko modelio sąrašo tik skaitymo tikslais per `attr_readonly`.

Jei dėl kokios nors priežasties pakeičiate savininko modelio pirminio rakto reikšmę ir nepakeičiate suskaičiuotų modelių užsienio raktų, tuomet skaitiklio talpykla gali turėti pasenusią informaciją. Kitaip tariant, visi palikti modeliai vis tiek bus skaičiuojami kaip priklausantys skaitikliui. Norėdami ištaisyti pasenusią skaitiklio talpyklą, naudokite [`reset_counters`][].


##### `:dependent`

Jei nustatote `:dependent` parinktį į:

* `:destroy`, kai objektas yra sunaikinamas, `destroy` bus iškviestas jo susijusiems objektams.
* `:delete`, kai objektas yra sunaikinamas, visi jo susiję objektai bus tiesiogiai ištrinti iš duomenų bazės, neskambinant jų `destroy` metode.
* `:destroy_async`: kai objektas yra sunaikinamas, į eilę bus įtrauktas `ActiveRecord::DestroyAssociationAsyncJob` darbas, kuris iškvies sunaikinimą jo susijusiuose objektuose. Tam veikti turi būti sukonfigūruotas „Active Job“. Nenaudokite šios parinkties, jei asociacija yra remiama užsienio rakto apribojimais jūsų duomenų bazėje. Užsienio rakto apribojimo veiksmai vyks toje pačioje transakcijoje, kurioje bus ištrintas savininkas.
ĮSPĖJIMAS: Negalite nurodyti šios parinkties `belongs_to` asociacijai, kuri yra susijusi su `has_many` asociacija kitoje klasėje. Tai gali sukelti paliktus įrašus duomenų bazėje.

##### `:foreign_key`

Pagal konvenciją, „Rails“ priima, kad stulpelis, naudojamas šio modelio užsienio rakto laikymui, yra asociacijos pavadinimas su pridėtu priesaga `_id`. `:foreign_key` parinktis leidžia tiesiogiai nustatyti užsienio rakto pavadinimą:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                      foreign_key: "patron_id"
end
```

PATARIMAS: Nepaisant to, „Rails“ jums nesukurs užsienio rakto stulpelių. Jums reikia aiškiai juos apibrėžti kaip savo migracijos dalį.

##### `:primary_key`

Pagal konvenciją, „Rails“ priima, kad `id` stulpelis naudojamas kaip pagrindinio rakto laikymui savo lentelėse. `:primary_key` parinktis leidžia nurodyti kitą stulpelį.

Pavyzdžiui, turime `users` lentelę su `guid` kaip pagrindiniu raktu. Jei norime atskiro `todos` lenteles, kurioje būtų laikomas užsienio raktas `user_id` `guid` stulpelyje, galime naudoti `primary_key` parinktį, kad tai pasiektume taip:

```ruby
class User < ApplicationRecord
  self.primary_key = 'guid' # pagrindinis raktas yra guid, o ne id
end

class Todo < ApplicationRecord
  belongs_to :user, primary_key: 'guid'
end
```

Kai vykdome `@user.todos.create`, tada `@todo` įrašas turės savo `user_id` reikšmę kaip `@user` `guid` reikšmę.

##### `:inverse_of`

`:inverse_of` parinktis nurodo `has_many` arba `has_one` asociacijos pavadinimą, kuris yra šios asociacijos atvirkštinis. Daugiau informacijos rasite [dvikrypės asociacijos](#bi-directional-associations) skyriuje.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:polymorphic`

Pereinant `true` į `:polymorphic` parinktį, nurodoma, kad tai yra polimorfinė asociacija. Polimorfinės asociacijos buvo išsamiai aptartos <a href="#polymorphic-associations">ankstesniame šio vadovo skyriuje</a>.

##### `:touch`

Jei nustatote `:touch` parinktį kaip `true`, tada susijusio objekto `updated_at` arba `updated_on` laiko žymeklis bus nustatytas į dabartinį laiką, kai šis objektas yra išsaugomas arba naikinamas:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: true
end

class Author < ApplicationRecord
  has_many :books
end
```

Šiuo atveju išsaugojus arba sunaikinus knygą, atnaujinamas laiko žymeklis susijusiam autorui. Taip pat galite nurodyti konkretų laiko žymeklio atributą, kurį norite atnaujinti:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at
end
```

##### `:validate`

Jei nustatote `:validate` parinktį kaip `true`, tada nauji susiję objektai bus patikrinami, kai išsaugosite šį objektą. Pagal numatytuosius nustatymus tai yra `false`: nauji susiję objektai nebus patikrinami, kai išsaugosite šį objektą.

##### `:optional`

Jei nustatote `:optional` parinktį kaip `true`, tada susijusio objekto buvimas nebus patikrinamas. Pagal numatytuosius nustatymus ši parinktis yra nustatyta kaip `false`.

#### `belongs_to` užklausos

Gali būti atvejų, kai norite tinkinti `belongs_to` užklausą. Tokius tinkinimus galima atlikti naudojant užklausos bloką. Pavyzdžiui:

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

Užklausos bloke galite naudoti bet kurį iš standartinių [užklausų metodų](active_record_querying.html). Apie juos bus aptarta žemiau:

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

`where` metodas leidžia nurodyti sąlygas, kurias turi atitikti susijęs objektas.

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

##### `includes`

Galite naudoti `includes` metodą, kad nurodytumėte antrinio lygio asociacijas, kurios turėtų būti įkeltos kartu su šia asociacija. Pavyzdžiui, apsvarstykite šiuos modelius:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

Jei dažnai gaunate autorius tiesiogiai iš skyrių (`@chapter.book.author`), galite padaryti savo kodą šiek tiek efektyvesnį, įtraukdami autorius į asociaciją nuo skyrių iki knygų:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book, -> { includes :author }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

PASTABA: Nereikia naudoti `includes` tiesioginėms asociacijoms - tai yra, jei turite `Book belongs_to :author`, tada autorius automatiškai įkeliamas, kai jis reikalingas.

##### `readonly`

Jei naudojate `readonly`, tada susijęs objektas bus tik skaitymui, kai jis gaunamas per asociaciją.
##### `select`

`select` metodas leidžia perrašyti SQL `SELECT` sakinį, kuris naudojamas gauti duomenis apie susijusį objektą. Pagal numatytuosius nustatymus, „Rails“ gauna visus stulpelius.

PATARIMAS: Jei naudojate `select` metodą su `belongs_to` asociacija, taip pat turėtumėte nustatyti `:foreign_key` parinktį, kad būtų garantuojami teisingi rezultatai.

#### Ar egzistuoja susiję objektai?

Galite patikrinti, ar egzistuoja susiję objektai, naudodami `association.nil?` metodą:

```ruby
if @book.author.nil?
  @msg = "Šiai knygai nerastas autorius"
end
```

#### Kada objektai yra išsaugomi?

Objekto priskyrimas `belongs_to` asociacijai _ne_ automatiškai išsaugo objektą. Taip pat nėra išsaugomas susijęs objektas.

### `has_one` asociacijos nuoroda

`has_one` asociacija sukuria vieno į vieną atitikmenį su kitu modeliu. Duomenų bazės terminais tai reiškia, kad kitas klasėje yra užsienio raktas. Jei šioje klasėje yra užsienio raktas, tuomet turėtumėte naudoti `belongs_to` vietoj to.

#### `has_one` pridėti metodai

Kai deklaruoji `has_one` asociaciją, deklaruojančiai klasei automatiškai pridedami 6 su asociacija susiję metodai:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`

Visuose šiuose metodųose `association` pakeičiamas simboliu, perduotu kaip pirmasis argumentas `has_one`. Pavyzdžiui, turint deklaraciją:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

Kiekvienas `Supplier` modelio objektas turės šiuos metodus:

* `account`
* `account=`
* `build_account`
* `create_account`
* `create_account!`
* `reload_account`
* `reset_account`

PASTABA: Inicializuojant naują `has_one` ar `belongs_to` asociaciją, turite naudoti `build_` prefiksą, kad sukurtumėte asociaciją, o ne `association.build` metodą, kuris būtų naudojamas `has_many` ar `has_and_belongs_to_many` asociacijoms. Norėdami sukurti vieną, naudokite `create_` prefiksą.

##### `association`

`association` metodas grąžina susijusį objektą, jei toks yra. Jei susijęs objektas nerastas, grąžinamas `nil`.

```ruby
@account = @supplier.account
```

Jei susijęs objektas jau buvo gautas iš duomenų bazės šiam objektui, grąžinama talpyklos versija. Norėdami pakeisti šį veikimą (ir priversti duomenų bazės skaitymą), iškvieskite `#reload_association` ant pagrindinio objekto.

```ruby
@account = @supplier.reload_account
```

Norėdami iškrauti talpyklos versiją susijusio objekto - priversti kitą prieigą, jei yra, užklausti ją iš duomenų bazės - iškvieskite `#reset_association` ant pagrindinio objekto.

```ruby
@supplier.reset_account
```

##### `association=(associate)`

`association=` metodas priskiria susijusį objektą šiam objektui. Užkulisiuose tai reiškia ištraukti pagrindinį raktą iš šio objekto ir nustatyti susijusio objekto užsienio raktą ta pačia reikšme.

```ruby
@supplier.account = @account
```

##### `build_association(attributes = {})`

`build_association` metodas grąžina naują susijusio tipo objektą. Šis objektas bus sukuriamas iš perduotų atributų, ir per jo užsienio raktą bus nustatytas ryšys, tačiau susijęs objektas _dar nebus_ išsaugotas.

```ruby
@account = @supplier.build_account(terms: "Net 30")
```

##### `create_association(attributes = {})`

`create_association` metodas grąžina naują susijusio tipo objektą. Šis objektas bus sukuriamas iš perduotų atributų, per jo užsienio raktą bus nustatytas ryšys, ir, kai jis praeis visus nurodytus asocijuoto modelio tikrinimus, susijęs objektas _bus_ išsaugotas.

```ruby
@account = @supplier.create_account(terms: "Net 30")
```

##### `create_association!(attributes = {})`

Daro tą patį kaip ir `create_association` aukščiau, bet iškelia `ActiveRecord::RecordInvalid` išimtį, jei įrašas yra netinkamas.

#### `has_one` parinktys

Nors „Rails“ naudoja protingus numatytuosius nustatymus, kurie gerai veiks daugumoje situacijų, gali būti atvejų, kai norite tinkinti `has_one` asociacijos nuorodos veikimą. Tokias tinkinimus galima lengvai atlikti perduodant parinktis, kuriant asociaciją. Pavyzdžiui, ši asociacija naudoja dvi tokiąsias parinktis:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing", dependent: :nullify
end
```

[`has_one`][] asociacija palaiko šias parinktis:

* `:as`
* `:autosave`
* `:class_name`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:touch`
* `:validate`

##### `:as`

Nustatant `:as` parinktį, nurodoma, kad tai yra polimorfinė asociacija. Polimorfinės asociacijos buvo išsamiai aptartos [ankstesniame šio vadovo skyriuje](#polimorfinės-asociacijos).

##### `:autosave`

Jei nustatote `:autosave` parinktį į `true`, „Rails“ išsaugos visus įkeltus asociacijos narius ir sunaikins tuos narius, kurie pažymėti sunaikinimui, kai išsaugosite pagrindinį objektą. Nustatant `:autosave` į `false` nėra tas pats kaip nepriskirti `:autosave` parinkties. Jei `:autosave` parinktis nėra nurodyta, tuomet nauji susiję objektai bus išsaugomi, bet atnaujinti susiję objektai nebus išsaugomi.
##### `:class_name`

Jei kito modelio pavadinimas negali būti išvestas iš asociacijos pavadinimo, galite naudoti `:class_name` parinktį, kad pateiktumėte modelio pavadinimą. Pavyzdžiui, jei tiekėjas turi sąskaitą, bet faktinė sąskaitų modelio pavadinimas yra `Billing`, tai galėtumėte tai nustatyti taip:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing"
end
```

##### `:dependent`

Valdo, kas nutiks susijusiam objektui, kai jo savininkas bus sunaikintas:

* `:destroy` sukelia susijusiam objektui taip pat būti sunaikintam
* `:delete` sukelia susijusiam objektui būti ištrintam tiesiogiai iš duomenų bazės (todėl atgaliniai kvietimai nebus vykdomi)
* `:destroy_async`: kai objektas yra sunaikinamas, į eilę įdedamas `ActiveRecord::DestroyAssociationAsyncJob` darbas, kuris iškvies sunaikinimą jo susijusiems objektams. Norint, kad tai veiktų, reikia nustatyti veikimą su Active Job. Nenaudokite šios parinkties, jei asociacija yra pagrįsta užsienio raktų apribojimais jūsų duomenų bazėje. Užsienio raktų apribojimo veiksmai vyks toje pačioje transakcijoje, kuri ištrins savininką.
* `:nullify` sukelia užsienio rakto nustatymą į `NULL`. Polimorfinio tipo stulpelis taip pat tampa `NULL` polimorfinėse asociacijose. Atgaliniai kvietimai nebus vykdomi.
* `:restrict_with_exception` sukelia `ActiveRecord::DeleteRestrictionError` išimtį, jei yra susijęs įrašas
* `:restrict_with_error` sukelia klaidą savininkui, jei yra susijęs objektas

Svarbu nenustatyti arba palikti `:nullify` parinktį toms asociacijoms, kurios turi `NOT NULL` duomenų bazės apribojimus. Jei nenustatysite `dependent` kaip `destroy` tokioms asociacijoms, nebegalėsite pakeisti susijusio objekto, nes pradinio susijusio objekto užsienio rakto reikšmė bus nustatyta į neleistiną `NULL` reikšmę.

##### `:foreign_key`

Pagal nutylėjimą, Rails priima, kad stulpelis, naudojamas laikyti užsienio raktą kito modelio, yra šio modelio pavadinimas su pridėtu priesaga `_id`. `:foreign_key` parinktis leidžia tiesiogiai nustatyti užsienio rakto pavadinimą:

```ruby
class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
end
```

PATARIMAS: Bet kuriuo atveju, Rails jums nesukurs užsienio rakto stulpelių. Jums reikia aiškiai juos apibrėžti kaip savo migracijos dalį.

##### `:inverse_of`

`:inverse_of` parinktis nurodo `belongs_to` asociacijos pavadinimą, kuris yra šios asociacijos atvirkštinė. Daugiau informacijos rasite [dvikrypės asociacijos](#bi-directional-associations) skyriuje.

```ruby
class Supplier < ApplicationRecord
  has_one :account, inverse_of: :supplier
end

class Account < ApplicationRecord
  belongs_to :supplier, inverse_of: :account
end
```

##### `:primary_key`

Pagal nutylėjimą, Rails priima, kad stulpelis, naudojamas laikyti šio modelio pirminį raktą, yra `id`. Galite pakeisti tai ir aiškiai nurodyti pirminį raktą naudodami `:primary_key` parinktį.

##### `:source`

`:source` parinktis nurodo šaltinio asociacijos pavadinimą `has_one :through` asociacijai.

##### `:source_type`

`:source_type` parinktis nurodo šaltinio asociacijos tipą `has_one :through` asociacijai, kuri eina per polimorfinę asociaciją.

```ruby
class Author < ApplicationRecord
  has_one :book
  has_one :hardback, through: :book, source: :format, source_type: "Hardback"
  has_one :dust_jacket, through: :hardback
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Paperback < ApplicationRecord; end

class Hardback < ApplicationRecord
  has_one :dust_jacket
end

class DustJacket < ApplicationRecord; end
```

##### `:through`

`:through` parinktis nurodo sujungimo modelį, per kurį atliekamas užklausos vykdymas. `has_one :through` asociacijos buvo išsamiai aptartos [ankstesniame šio vadovo skyriuje](#the-has-one-through-association).

##### `:touch`

Jei nustatote `:touch` parinktį kaip `true`, tada susijusio objekto `updated_at` arba `updated_on` laiko žymeklis bus nustatytas į dabartinį laiką, kai šis objektas yra išsaugomas arba sunaikinamas:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: true
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

Šiuo atveju, išsaugojus arba sunaikinus tiekėją, bus atnaujintas susijusios sąskaitos laiko žymeklis. Taip pat galite nurodyti konkretų laiko žymeklio atributą, kurį norite atnaujinti:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: :suppliers_updated_at
end
```

##### `:validate`

Jei nustatote `:validate` parinktį kaip `true`, tada nauji susiję objektai bus patikrinami, kai išsaugosite šį objektą. Pagal nutylėjimą tai yra `false`: nauji susiję objektai nebus patikrinami, kai išsaugosite šį objektą.

#### `has_one` užklausoms

Gali būti atvejų, kai norite pritaikyti užklausą, naudojamą `has_one`. Tokias individualias pritaikymo galimybes galima pasiekti naudojant užklausos bloką. Pavyzdžiui:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```
Galite naudoti bet kurį iš standartinių [užklausos metodų](active_record_querying.html) viduje `scope` bloko. Žemiau aptariami šie metodai:

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

`where` metodas leidžia nurodyti sąlygas, kurias turi atitikti susijęs objektas.

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where "confirmed = 1" }
end
```

##### `includes`

Galite naudoti `includes` metodą, norėdami nurodyti antrinio lygio susijimus, kurie turėtų būti užkraunami kartu su šiuo susijimu. Pavyzdžiui, apsvarstykite šiuos modelius:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

Jei dažnai gaunate atstovus tiesiogiai iš tiekėjų (`@supplier.account.representative`), galite padaryti savo kodą šiek tiek efektyvesnį, įtraukdami atstovus į susijimą nuo tiekėjų iki sąskaitų:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { includes :representative }
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

##### `readonly`

Jei naudojate `readonly` metodą, tada susijęs objektas bus tik skaitymui, kai jis gaunamas per susijimą.

##### `select`

`select` metodas leidžia perrašyti SQL `SELECT` sakinį, kuris naudojamas gauti duomenis apie susijusį objektą. Pagal numatytuosius nustatymus, „Rails“ gauna visus stulpelius.

#### Ar egzistuoja susiję objektai?

Galite patikrinti, ar egzistuoja susiję objektai, naudodami `association.nil?` metodą:

```ruby
if @supplier.account.nil?
  @msg = "Šiam tiekėjui nerasta sąskaita"
end
```

#### Kada objektai yra išsaugomi?

Kai priskiriate objektą `has_one` susijimui, tas objektas automatiškai išsaugomas (norint atnaujinti jo užsienio raktą). Be to, bet koks pakeistas objektas taip pat automatiškai išsaugomas, nes jo užsienio raktas taip pat pasikeis.

Jei vienas iš šių išsaugojimų nepavyksta dėl validacijos klaidų, tuomet priskyrimo sakinys grąžina `false`, o pati priskyrimo operacija yra atšaukiama.

Jei pagrindinis objektas (tas, kuris deklaruoja `has_one` susijimą) nėra išsaugotas (tai yra, `new_record?` grąžina `true`), tada vaikiniai objektai nėra išsaugomi. Jie bus automatiškai išsaugomi, kai pagrindinis objektas bus išsaugotas.

Jei norite priskirti objektą `has_one` susijimui be išsaugojimo, naudokite `build_association` metodą.

### `has_many` Susijimo nuoroda

`has_many` susijimas sukuria vieno į daugelio santykį su kitu modeliu. Duomenų bazės terminais šis susijimas reiškia, kad kitas klasės objektas turės užsienio raktą, kuris rodo į šios klasės objektus.

#### `has_many` Pridedami metodai

Kai deklaruoja `has_many` susijimą, deklaruojančiai klasei automatiškai pridedami 17 susiję metodai:

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

Visuose šiuose metodųose `collection` pakeičiamas simboliu, perduotu kaip pirmasis argumentas `has_many`, o `collection_singular` pakeičiamas vienaskaitine šio simbolio versija. Pavyzdžiui, turint deklaraciją:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

Kiekvienas `Author` modelio objektas turės šiuos metodus:

```ruby
books
books<<(object, ...)
books.delete(object, ...)
books.destroy(object, ...)
books=(objects)
book_ids
book_ids=(ids)
books.clear
books.empty?
books.size
books.find(...)
books.where(...)
books.exists?(...)
books.build(attributes = {}, ...)
books.create(attributes = {})
books.create!(attributes = {})
books.reload
```

##### `collection`

`collection` metodas grąžina sąryšį su visais susijusiais objektais. Jei nėra susijusių objektų, grąžinamas tuščias sąryšis.

```ruby
@books = @author.books
```

##### `collection<<(object, ...)`

[`collection<<`][] metodas prideda vieną arba daugiau objektų į sąryšį, nustatant jų užsienio raktus į skambinančio modelio pirminį raktą.

```ruby
@author.books << @book1
```

##### `collection.delete(object, ...)`

[`collection.delete`][] metodas pašalina vieną arba daugiau objektų iš sąryšio, nustatant jų užsienio raktus į `NULL`.

```ruby
@author.books.delete(@book1)
```

ĮSPĖJIMAS: Be to, objektai bus sunaikinti, jei jie susiję su `dependent: :destroy`, ir ištrinti, jei jie susiję su `dependent: :delete_all`.

##### `collection.destroy(object, ...)`

[`collection.destroy`][] metodas pašalina vieną arba daugiau objektų iš sąryšio, vykdant `destroy` kiekvienam objektui.

```ruby
@author.books.destroy(@book1)
```

ĮSPĖJIMAS: Objektai _visada_ bus pašalinti iš duomenų bazės, ignoruojant `:dependent` parinktį.

##### `collection=(objects)`

`collection=` metodas padaro sąryšį turintį tik pateiktus objektus, pridedant ir pašalinant, kaip tinkama. Pakeitimai išlieka duomenų bazėje.
##### `collection_singular_ids`

`collection_singular_ids` metodas grąžina objektų kolekcijos id masyvą.

```ruby
@book_ids = @author.book_ids
```

##### `collection_singular_ids=(ids)`

`collection_singular_ids=` metodas padaro, kad kolekcija turėtų tik tuos objektus, kurie yra identifikuojami pagal pateiktus pirminio rakto reikšmes, pridedant ir ištrinant pagal poreikį. Pakeitimai yra išsaugomi duomenų bazėje.

##### `collection.clear`

`collection.clear` metodas pašalina visus objektus iš kolekcijos pagal nustatytą strategiją, kurią nurodo `dependent` parinktis. Jei parinktis nenurodyta, naudojama numatytoji strategija. Numatytoji strategija `has_many :through` asociacijoms yra `delete_all`, o `has_many` asociacijoms - nustatyti užsienio raktus į `NULL`.

```ruby
@author.books.clear
```

ĮSPĖJIMAS: Objektai bus ištrinti, jei jie susiję su `dependent: :destroy` arba `dependent: :destroy_async`, taip pat kaip ir su `dependent: :delete_all`.

##### `collection.empty?`

`collection.empty?` metodas grąžina `true`, jei kolekcija neapima jokių susijusių objektų.

```erb
<% if @author.books.empty? %>
  Nerasta jokių knygų
<% end %>
```

##### `collection.size`

`collection.size` metodas grąžina objektų skaičių kolekcijoje.

```ruby
@book_count = @author.books.size
```

##### `collection.find(...)`

`collection.find` metodas randa objektus kolekcijos lentelėje.

```ruby
@available_book = @author.books.find(1)
```

##### `collection.where(...)`

`collection.where` metodas randa objektus kolekcijoje pagal pateiktas sąlygas, tačiau objektai yra įkraunami tinginiškai, tai reiškia, kad duomenų bazė yra užklausinėjama tik tada, kai prieinami objektai.

```ruby
@available_books = author.books.where(available: true) # Dar nėra užklausos
@available_book = @available_books.first # Dabar bus užklausta duomenų bazė
```

##### `collection.exists?(...)`

`collection.exists?` metodas patikrina, ar kolekcijos lentelėje yra objektas, atitinkantis pateiktas sąlygas.

##### `collection.build(attributes = {})`

`collection.build` metodas grąžina vieną arba masyvą naujų asocijuotos rūšies objektų. Objektai bus sukuriami iš perduotų atributų, ir bus sukurtas ryšys per jų užsienio raktą, tačiau susiję objektai dar _nebus_ išsaugoti.

```ruby
@book = author.books.build(published_at: Time.now,
                            book_number: "A12345")

@books = author.books.build([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create(attributes = {})`

`collection.create` metodas grąžina vieną arba masyvą naujų asocijuotos rūšies objektų. Objektai bus sukuriami iš perduotų atributų, bus sukurtas ryšys per jų užsienio raktą, ir, kai jie praeis visus asocijuoto modelio nurodytus patikrinimus, susijęs objektas _bus_ išsaugotas.

```ruby
@book = author.books.create(published_at: Time.now,
                             book_number: "A12345")

@books = author.books.create([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create!(attributes = {})`

Daro tą patį, kas ir `collection.create` aukščiau, tačiau iškelia `ActiveRecord::RecordInvalid` išimtį, jei įrašas yra netinkamas.

##### `collection.reload`

`collection.reload` metodas grąžina visų susijusių objektų sąryšį, priverčiant duomenų bazės skaitymą. Jei nėra susijusių objektų, grąžinamas tuščias sąryšis.

```ruby
@books = author.books.reload
```

#### `has_many` parinktys

Nors „Rails“ naudoja protingus numatytuosius nustatymus, kurie daugumai situacijų veiks gerai, gali būti atvejų, kai norite tinkinti `has_many` asociacijos elgesį. Tokius tinkinimus galima lengvai atlikti perduodant parinktis kuriant asociaciją. Pavyzdžiui, ši asociacija naudoja dvi tokių parinkčių:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :delete_all, validate: false
end
```

`has_many` asociacija palaiko šias parinktis:

* `:as`
* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:validate`

##### `:as`

Nustatant `:as` parinktį, nurodoma, kad tai yra polimorfinė asociacija, kaip aptarta [ankstesniame šio vadovo skyriuje](#polimorfinės-asociacijos).

##### `:autosave`

Jei nustatote `:autosave` parinktį į `true`, „Rails“ išsaugos visus įkrautos asociacijos narius ir sunaikins tuos narius, kurie pažymėti sunaikinimui, kai išsaugosite pagrindinį objektą. Nustatant `:autosave` į `false` nėra tas pats kaip nenurodyti `:autosave` parinkties. Jei `:autosave` parinktis nėra nurodyta, tuomet nauji susiję objektai bus išsaugoti, tačiau atnaujinti susiję objektai nebus išsaugoti.

##### `:class_name`

Jei kito modelio pavadinimas negali būti išvestas iš asociacijos pavadinimo, galite naudoti `:class_name` parinktį, kad nurodytumėte modelio pavadinimą. Pavyzdžiui, jei autorius turi daug knygų, bet knygų modelio tikras pavadinimas yra `Transaction`, tai galėtumėte tai padaryti taip:

```ruby
class Author < ApplicationRecord
  has_many :books, class_name: "Transaction"
end
```
##### `:counter_cache`

Šią parinktį galima naudoti, norint konfigūruoti pasirinktiną `:counter_cache` pavadinimą. Šią parinktį reikia naudoti tik tada, kai pasirinkote savo `:counter_cache` pavadinimą [priklauso_sąjungai](#options-for-belongs-to).

##### `:dependent`

Valdo, kas vyksta su susijusiais objektais, kai jų savininkas yra sunaikintas:

* `:destroy` sukelia visus susijusius objektus taip pat būti sunaikinti
* `:delete_all` sukelia visus susijusius objektus būti ištrinti tiesiogiai iš duomenų bazės (todėl grįžtamieji kvietimai nebus vykdomi)
* `:destroy_async`: kai objektas yra sunaikintas, į eilę įtraukiamas `ActiveRecord::DestroyAssociationAsyncJob` darbas, kuris sunaikins susijusius objektus. Tam, kad tai veiktų, reikia nustatyti aktyvų darbą.
* `:nullify` sukelia, kad užsienio raktas būtų nustatytas į `NULL`. Polimorfinio tipo stulpelis taip pat tampa nustatytas į `NULL` polimorfinėse sąjungose. Grįžtamieji kvietimai nevykdomi.
* `:restrict_with_exception` sukelia `ActiveRecord::DeleteRestrictionError` išimtį, jei yra susijusių įrašų
* `:restrict_with_error` sukelia klaidą savininkui, jei yra susijusių objektų

`:destroy` ir `:delete_all` parinktys taip pat veikia `collection.delete` ir `collection=` metodų semantiką, sunaikindamos susijusius objektus, kai jie pašalinami iš kolekcijos.

##### `:foreign_key`

Pagal nutylėjimą, „Rails“ priima, kad stulpelis, naudojamas kitame modelyje esančiam užsienio raktui laikyti, yra šio modelio pavadinimas su pridėtu priesaga `_id`. `:foreign_key` parinktis leidžia tiesiogiai nustatyti užsienio rakto pavadinimą:

```ruby
class Author < ApplicationRecord
  has_many :books, foreign_key: "cust_id"
end
```

PATARIMAS: Bet kuriuo atveju „Rails“ jums nesukurs užsienio rakto stulpelių. Jums reikia aiškiai juos apibrėžti kaip savo migracijos dalį.

##### `:inverse_of`

`:inverse_of` parinktis nurodo atvirkštinį šios sąjungos `priklaukiančios_sąjungos` pavadinimą. Daugiau informacijos rasite [dvikrypčių sąjungų](#bi-directional-associations) skyriuje.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:primary_key`

Pagal nutylėjimą, „Rails“ priima, kad asociacijos pagrindinio rakto laikyti stulpelis yra `id`. Galite perrašyti tai ir aiškiai nurodyti pagrindinį raktą naudodami `:primary_key` parinktį.

Tarkime, kad `users` lentelėje yra `id` kaip pagrindinis raktas, bet taip pat yra `guid` stulpelis. Reikalavimas yra tas, kad `todos` lentelėje `guid` stulpelio reikšmė turėtų būti laikoma užsienio raktu, o ne `id` reikšme. Tai galima pasiekti taip:

```ruby
class User < ApplicationRecord
  has_many :todos, primary_key: :guid
end
```

Dabar, jei vykdysime `@todo = @user.todos.create`, tada `@todo` įrašo `user_id` reikšmė bus `@user` `guid` reikšmė.

##### `:source`

`:source` parinktis nurodo šaltinio sąjungos pavadinimą `has_many :through` sąjungai. Šią parinktį reikia naudoti tik tada, kai šaltinio sąjungos pavadinimas negali būti automatiškai nustatytas iš sąjungos pavadinimo.

##### `:source_type`

`:source_type` parinktis nurodo šaltinio sąjungos tipą `has_many :through` sąjungai, kuri eina per polimorfinę sąjungą.

```ruby
class Author < ApplicationRecord
  has_many :books
  has_many :paperbacks, through: :books, source: :format, source_type: "Paperback"
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Hardback < ApplicationRecord; end
class Paperback < ApplicationRecord; end
```

##### `:through`

`:through` parinktis nurodo jungiamą modelį, per kurį atliekamas užklausos vykdymas. `has_many :through` sąjungos suteikia būdą įgyvendinti daugybės į daugelį santykių, kaip aptarta [šiame gidui](#the-has-many-through-association), pavyzdžiui.

##### `:validate`

Jei nustatysite `:validate` parinktį į `false`, tada nauji susiję objektai nebus tikrinami, kai išsaugosite šį objektą. Pagal nutylėjimą tai yra `true`: nauji susiję objektai bus tikrinami, kai išsaugomas šis objektas.

#### Užklausos `has_many` riboms

Gali būti atvejų, kai norite tinkinti užklausą, naudojamą `has_many`. Tokias tinkinimus galima atlikti naudojant ribos bloką. Pavyzdžiui:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { where processed: true }
end
```

Ribų bloke galite naudoti bet kurį iš standartinių [užklausų metodų](active_record_querying.html). Apie juos aptariami žemiau:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

`where` metodas leidžia nurodyti sąlygas, kurias turi atitikti susijęs objektas.

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where "confirmed = 1" },
    class_name: "Book"
end
```
Taip pat galite nustatyti sąlygas naudodami hash'ą:

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where confirmed: true },
    class_name: "Book"
end
```

Jei naudojate hash'o stiliaus `where` parinktį, tada įrašų kūrimas per šią asociaciją bus automatiškai apribotas naudojant hash'ą. Šiuo atveju, naudojant `author.confirmed_books.create` arba `author.confirmed_books.build`, bus sukurti knygos, kuriose patvirtintas stulpelis turi reikšmę `true`.

##### `extending`

`extending` metodas nurodo vardintą modulį, kuris išplečia asociacijos tarpininką. Asociacijos plėtinių aprašymas išsamiai aptariamas [vėliau šiame vadove](#association-extensions).

##### `group`

`group` metodas nurodo atributo pavadinimą, pagal kurį rezultatų rinkinys bus sugrupuotas, naudojant `GROUP BY` sąlygą paieškos SQL užklausoje.

```ruby
class Author < ApplicationRecord
  has_many :chapters, -> { group 'books.id' },
                      through: :books
end
```

##### `includes`

Galite naudoti `includes` metodą, norėdami nurodyti antrinio lygio asociacijas, kurios turėtų būti iš anksto įkeltos, kai naudojama ši asociacija. Pavyzdžiui, apsvarstykite šiuos modelius:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

Jei dažnai gaunate skyrius tiesiogiai iš autorių (`author.books.chapters`), galite padaryti savo kodą šiek tiek efektyvesnį, įtraukdami skyrius į asociaciją nuo autorių iki knygų:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { includes :chapters }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

##### `limit`

`limit` metodas leidžia apriboti visų objektų, kurie bus gauti per asociaciją, skaičių.

```ruby
class Author < ApplicationRecord
  has_many :recent_books,
    -> { order('published_at desc').limit(100) },
    class_name: "Book"
end
```

##### `offset`

`offset` metodas leidžia nurodyti pradinį poslinkį, skirtą objektų gavimui per asociaciją. Pavyzdžiui, `-> { offset(11) }` praleis pirmuosius 11 įrašų.

##### `order`

`order` metodas nurodo tvarką, kuria bus gaunami susiję objektai (naudojant sintaksę, kurią naudoja SQL `ORDER BY` sąlyga).

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order "date_confirmed DESC" }
end
```

##### `readonly`

Jei naudojate `readonly` metodą, tada gauti asocijuoti objektai bus tik skaityti.

##### `select`

`select` metodas leidžia perrašyti SQL `SELECT` sąlygą, kurią naudoja duomenų apie susijusius objektus gavimui. Pagal numatytuosius nustatymus, „Rails“ gauna visus stulpelius.

ĮSPĖJIMAS: Jei nurodote savo `select`, įsitikinkite, kad įtraukiate pagrindinio rakto ir užsienio rakto stulpelius susijusio modelio. Jei to nepadarysite, „Rails“ išmes klaidą.

##### `distinct`

Naudokite `distinct` metodą, kad kolekcija būtų laisva nuo dublikatų. Tai daugiausia naudinga kartu su `:through` parinktimi.

```ruby
class Person < ApplicationRecord
  has_many :readings
  has_many :articles, through: :readings
end
```

```irb
irb> person = Person.create(name: 'John')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 5, name: "a1">, #<Article id: 5, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 12, person_id: 5, article_id: 5>, #<Reading id: 13, person_id: 5, article_id: 5>]
```

Pirmiau pateiktu atveju yra du skaitymai, o `person.articles` išveda abu, nors šie įrašai rodo į tą pačią straipsnį.

Dabar nustatysime `distinct`:

```ruby
class Person
  has_many :readings
  has_many :articles, -> { distinct }, through: :readings
end
```

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 7, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 16, person_id: 7, article_id: 7>, #<Reading id: 17, person_id: 7, article_id: 7>]
```

Pirmiau pateiktu atveju vis dar yra du skaitymai. Tačiau `person.articles` rodo tik vieną straipsnį, nes kolekcija įkelia tik unikalius įrašus.

Jei norite užtikrinti, kad įterpiant visi įrašai išsaugotame asociacijoje būtų unikalūs (kad galėtumėte būti tikri, kad tikrinant asociaciją niekada nerasite dublikatinių įrašų), turėtumėte pridėti unikalų indeksą paties lentelėje. Pavyzdžiui, jei turite lentelę pavadinimu `readings` ir norite užtikrinti, kad straipsniai gali būti pridėti prie asmens tik vieną kartą, galite pridėti šį kodą migracijoje:

```ruby
add_index :readings, [:person_id, :article_id], unique: true
```
Kai turite šį unikalų indeksą, bandant pridėti straipsnį prie žmogaus du kartus, bus iškelta `ActiveRecord::RecordNotUnique` klaida:

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
ActiveRecord::RecordNotUnique
```

Atkreipkite dėmesį, kad patikrinimas dėl unikalumo naudojant kažką panašaus į `include?` yra priklausomas nuo varžybų sąlygų. Nenagrinėkite `include?` naudoti siekiant užtikrinti asociacijos išskirtinumą. Pavyzdžiui, naudojant aukščiau pateiktą straipsnio pavyzdį, toks kodas būtų varžantis, nes keli naudotojai galėtų tai bandyti tuo pačiu metu:

```ruby
person.articles << article unless person.articles.include?(article)
```

#### Kada objektai yra išsaugomi?

Kai priskiriate objektą `has_many` asociacijai, tas objektas automatiškai išsaugomas (norint atnaujinti jo svetainės raktą). Jei priskiriate kelis objektus vienu teiginio, visi jie yra išsaugomi.

Jei bet kuris iš šių išsaugojimų nepavyksta dėl validacijos klaidų, tada priskyrimo teiginys grąžina `false`, o pats priskyrimas yra atšaukiamas.

Jei pagrindinis objektas (tas, kuris deklaruoja `has_many` asociaciją) yra neišsaugotas (tai yra, `new_record?` grąžina `true`), tada vaikų objektai nėra išsaugomi, kai jie yra pridedami. Visi neišsaugoti asociacijos nariai automatiškai bus išsaugomi, kai bus išsaugotas pagrindinis objektas.

Jei norite priskirti objektą `has_many` asociacijai, nesaugodami objekto, naudokite `collection.build` metodą.

### `has_and_belongs_to_many` asociacijos nuoroda

`has_and_belongs_to_many` asociacija sukuria daugybės su kitu modeliu ryšį. Duomenų bazės sąlygomis tai susieja dvi klases per tarpinę jungiamąją lentelę, kurioje yra svetainės raktai, rodantys į kiekvieną iš klasių.

#### `has_and_belongs_to_many` pridėti metodai

Kai deklaruoja `has_and_belongs_to_many` asociaciją, deklaruojančiai klasei automatiškai pridedami keletas su asociacija susijusių metodų:

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

Visuose šiuose metodųose `collection` yra pakeičiama simboliu, perduotu kaip pirmasis argumentas `has_and_belongs_to_many`, o `collection_singular` yra pakeičiama vienaskaitos versija to simbolio. Pavyzdžiui, turint deklaraciją:

```ruby
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Kiekvienas `Part` modelio egzempliorius turės šiuos metodus:

```ruby
assemblies
assemblies<<(object, ...)
assemblies.delete(object, ...)
assemblies.destroy(object, ...)
assemblies=(objects)
assembly_ids
assembly_ids=(ids)
assemblies.clear
assemblies.empty?
assemblies.size
assemblies.find(...)
assemblies.where(...)
assemblies.exists?(...)
assemblies.build(attributes = {}, ...)
assemblies.create(attributes = {})
assemblies.create!(attributes = {})
assemblies.reload
```

##### Papildomi stulpelių metodai

Jei `has_and_belongs_to_many` asociacijos jungiamoji lentelė turi papildomų stulpelių, virš dviejų svetainių raktų, šie stulpeliai bus pridėti kaip atributai į įrašus, gaunamus per tą asociaciją. Grąžinami įrašai su papildomais atributais visada bus tik skaitymui, nes „Rails“ negali išsaugoti pakeitimų šiems atributams.

ĮSPĖJIMAS: Papildomų atributų naudojimas jungiamosiose lentelėse `has_and_belongs_to_many` asociacijoje yra pasenusi. Jei jums reikia tokio sudėtingo elgesio lentelėje, kuri jungia du modelius daugybės su daugybe santykiu, turėtumėte naudoti `has_many :through` asociaciją vietoj `has_and_belongs_to_many`.

##### `collection`

`collection` metodas grąžina visų susijusių objektų sąryšį. Jei nėra susijusių objektų, grąžinamas tuščias sąryšis.

```ruby
@assemblies = @part.assemblies
```

##### `collection<<(object, ...)`

[`collection<<`][] metodas prideda vieną ar daugiau objektų į sąryšį, sukurdamas įrašus jungiamojoje lentelėje.

```ruby
@part.assemblies << @assembly1
```

PASTABA: Šis metodas yra sinonimas `collection.concat` ir `collection.push`.

##### `collection.delete(object, ...)`

[`collection.delete`][] metodas pašalina vieną ar daugiau objektų iš sąryšio, ištrindamas įrašus jungiamojoje lentelėje. Tai neapima objektų naikinimo.

```ruby
@part.assemblies.delete(@assembly1)
```

##### `collection.destroy(object, ...)`

[`collection.destroy`][] metodas pašalina vieną ar daugiau objektų iš sąryšio, ištrindamas įrašus jungiamojoje lentelėje. Tai neapima objektų naikinimo.

```ruby
@part.assemblies.destroy(@assembly1)
```

##### `collection=(objects)`

`collection=` metodas padaro sąryšį turintį tik pateiktus objektus, pridedant ir pašalinant pagal poreikį. Pakeitimai yra išsaugomi duomenų bazėje.

##### `collection_singular_ids`

`collection_singular_ids` metodas grąžina masyvą, kuriame yra objektų sąryšio identifikatoriai.

```ruby
@assembly_ids = @part.assembly_ids
```

##### `collection_singular_ids=(ids)`

`collection_singular_ids=` metodas padaro sąryšį turintį tik objektus, kurie yra nurodyti pagal pateiktus pirminio rakto reikšmes, pridedant ir pašalinant pagal poreikį. Pakeitimai yra išsaugomi duomenų bazėje.
##### `collection.clear`

Metodas [`collection.clear`][] pašalina visus objektus iš kolekcijos, ištrindamas eilutes iš jungiamosios lentelės. Tai nesunaikina susijusių objektų.

##### `collection.empty?`

Metodas [`collection.empty?`][] grąžina `true`, jei kolekcija neapima jokių susijusių objektų.

```html+erb
<% if @part.assemblies.empty? %>
  Šis komponentas nenaudojamas jokiose montavimuose
<% end %>
```

##### `collection.size`

Metodas [`collection.size`][] grąžina objektų skaičių kolekcijoje.

```ruby
@assembly_count = @part.assemblies.size
```

##### `collection.find(...)`

Metodas [`collection.find`][] randa objektus kolekcijos lentelėje.

```ruby
@assembly = @part.assemblies.find(1)
```

##### `collection.where(...)`

Metodas [`collection.where`][] randa objektus kolekcijoje pagal pateiktas sąlygas, tačiau objektai yra įkraunami tinginiu būdu, tai reiškia, kad duomenų bazė yra užklausiama tik tada, kai prieiga prie objektų yra atliekama.

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

##### `collection.exists?(...)`

Metodas [`collection.exists?`][] patikrina, ar kolekcijos lentelėje yra objektas, atitinkantis pateiktas sąlygas.

##### `collection.build(attributes = {})`

Metodas [`collection.build`][] grąžina naują susijusio tipo objektą. Šis objektas bus sukurtas iš perduotų atributų, ir bus sukurtas ryšys per jungiamąją lentelę, tačiau susijęs objektas dar _nebus_ išsaugotas.

```ruby
@assembly = @part.assemblies.build({ assembly_name: "Transmisijos korpusas" })
```

##### `collection.create(attributes = {})`

Metodas [`collection.create`][] grąžina naują susijusio tipo objektą. Šis objektas bus sukurtas iš perduotų atributų, bus sukurtas ryšys per jungiamąją lentelę ir, kai jis praeis visus susijusio modelio nustatytus patikrinimus, susijęs objektas _bus_ išsaugotas.

```ruby
@assembly = @part.assemblies.create({ assembly_name: "Transmisijos korpusas" })
```

##### `collection.create!(attributes = {})`

Atlieka tą patį kaip ir `collection.create`, tačiau iškelia `ActiveRecord::RecordInvalid` išimtį, jei įrašas yra netinkamas.

##### `collection.reload`

Metodas [`collection.reload`][] grąžina visus susijusius objektus kaip Reliaciją, priverčiant duomenų bazės skaitymą. Jei nėra susijusių objektų, grąžinama tuščia Reliacija.

```ruby
@assemblies = @part.assemblies.reload
```

#### Galimybės `has_and_belongs_to_many`

Nors „Rails“ naudoja protingus numatytuosius nustatymus, kurie daugeliu atvejų veiks gerai, gali būti situacijų, kai norite tinkinti `has_and_belongs_to_many` asociacijos elgesį. Tokius tinkinimus galima lengvai atlikti, perduodant parinktis kuriant asociaciją. Pavyzdžiui, ši asociacija naudoja dvi tokių parinkčių:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { readonly },
                                       autosave: true
end
```

[`has_and_belongs_to_many`][] asociacija palaiko šias parinktis:

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
* `:validate`

##### `:association_foreign_key`

Pagal nutylėjimą „Rails“ priima, kad stulpelis jungiamojoje lentelėje, naudojamas laikyti užsienio rakto, rodančio į kitą modelį, yra to modelio pavadinimas su pridėtu priesaga `_id`. Parinktis `:association_foreign_key` leidžia nustatyti užsienio rakto pavadinimą tiesiogiai:

PATARIMAS: Parinktys `:foreign_key` ir `:association_foreign_key` yra naudingos, kai sukuriamas daug į daug paties sąsajos ryšys. Pavyzdžiui:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:autosave`

Jei nustatote parinktį `:autosave` į `true`, „Rails“ išsaugos visus įkeltus asociacijos narius ir sunaikins narius, kurie pažymėti sunaikinimui, kai išsaugosite pagrindinį objektą. Nustatant `:autosave` į `false`, tai nėra tas pats kaip nepasirinkus `:autosave` parinkties. Jei `:autosave` parinktis nėra nurodyta, tada nauji susiję objektai bus išsaugoti, tačiau atnaujinti susiję objektai nebus išsaugoti.

##### `:class_name`

Jei kito modelio pavadinimas negali būti išvestas iš asociacijos pavadinimo, galite naudoti `:class_name` parinktį, kad nurodytumėte modelio pavadinimą. Pavyzdžiui, jei daliui priklauso daug montavimų, bet faktinis modelio, kuriame yra montavimai, pavadinimas yra `Gadget`, tai galėtumėte tai nustatyti taip:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```

##### `:foreign_key`

Pagal nutylėjimą „Rails“ priima, kad stulpelis jungiamojoje lentelėje, naudojamas laikyti užsienio rakto, rodančio į šį modelį, yra šio modelio pavadinimas su pridėta priesaga `_id`. Parinktis `:foreign_key` leidžia nustatyti užsienio rakto pavadinimą tiesiogiai:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:join_table`

Jei numatytasis jungiamojo lenteles pavadinimas, pagrįstas leksikografiniu tvarka, nėra tai, ko norite, galite naudoti `:join_table` parinktį, kad pakeistumėte numatytąjį pavadinimą.
##### `:validate`

Jei nustatote `:validate` parinktį kaip `false`, tada nauji susiję objektai nebus patikrinami, kai tik išsaugosite šį objektą. Pagal numatytuosius nustatymus tai yra `true`: nauji susiję objektai bus patikrinami, kai šis objektas bus išsaugotas.

#### Scopes for `has_and_belongs_to_many`

Gali būti atvejų, kai norite tinkinti užklausą, kurią naudoja `has_and_belongs_to_many`. Tokias tinkinimus galima pasiekti per rėmų bloką. Pavyzdžiui:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

Rėmų bloke galite naudoti bet kurį iš standartinių [užklausos metodų](active_record_querying.html). Apie šiuos aptariami žemiau:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

`where` metodas leidžia nurodyti sąlygas, kurias turi atitikti susijęs objektas.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

Sąlygas taip pat galite nustatyti naudodami hash'ą:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

Jei naudojate hash'o stiliaus `where`, tada įrašų kūrimas per šią asociaciją automatiškai bus apribotas naudojant hash'ą. Šiuo atveju, naudojant `@parts.assemblies.create` arba `@parts.assemblies.build`, bus sukurtos montavimo vienetų, kurių `factory` stulpelis turi reikšmę "Seattle".

##### `extending`

`extending` metodas nurodo vardintą modulį, kuris išplečia asociacijos proxy. Apie asociacijos išplėtimus išsamiau kalbama [vėliau šiame vadove](#association-extensions).

##### `group`

`group` metodas nurodo atributo pavadinimą, pagal kurį rezultatų rinkinys bus sugrupuotas, naudojant `GROUP BY` klauzulę užklausos SQL.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```

##### `includes`

Galite naudoti `includes` metodą, norėdami nurodyti antrinio lygio asociacijas, kurios turėtų būti įkeltos iš anksto, kai naudojama ši asociacija.

##### `limit`

`limit` metodas leidžia apriboti visų objektų, kurie bus gauti per asociaciją, skaičių.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```

##### `offset`

`offset` metodas leidžia nurodyti pradžios nuokrypį, skirtą objektams gauti per asociaciją. Pavyzdžiui, jei nustatote `offset(11)`, tai praleis pirmuosius 11 įrašų.

##### `order`

`order` metodas nurodo tvarką, kuria bus gauti susiję objektai (naudojant sintaksę, kurią naudoja SQL `ORDER BY` klauzulė).

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```

##### `readonly`

Jei naudojate `readonly` metodą, tada susiję objektai bus tik skaitymui, kai jie bus gaunami per asociaciją.

##### `select`

`select` metodas leidžia perrašyti SQL `SELECT` klauzulę, kuri naudojama gauti duomenis apie susijusius objektus. Pagal numatytuosius nustatymus, „Rails“ gauna visus stulpelius.

##### `distinct`

Naudokite `distinct` metodą, norėdami pašalinti dublikatus iš kolekcijos.

#### Kada objektai yra išsaugomi?

Kai priskiriate objektą `has_and_belongs_to_many` asociacijai, tas objektas automatiškai išsaugomas (norint atnaujinti jungiamąją lentelę). Jei vienoje instrukcijoje priskiriate kelis objektus, jie visi išsaugomi.

Jei vienas iš šių išsaugojimų nepavyksta dėl validacijos klaidų, tada priskyrimo instrukcija grąžina `false`, o pati priskyrimas yra atšaukiamas.

Jei pagrindinis objektas (tas, kuris deklaruoja `has_and_belongs_to_many` asociaciją) nėra išsaugotas (tai yra, `new_record?` grąžina `true`), tada pridedant juos, vaikiniai objektai nebus išsaugomi. Visi nesaugomi asociacijos nariai automatiškai bus išsaugomi, kai bus išsaugotas pagrindinis objektas.

Jei norite priskirti objektą `has_and_belongs_to_many` asociacijai, nesaugodami objekto, naudokite `collection.build` metodą.

### Asociacijos atgalinimo iškvietimai

Įprasti atgalinimo iškvietimai susijungia su aktyviųjų įrašų objektų gyvavimo ciklu, leisdami jums dirbti su šiais objektais įvairiais momentais. Pavyzdžiui, galite naudoti `:before_save` atgalinimo iškvietimą, kad prieš išsaugant objektą kažkas įvyktų.

Asociacijos atgalinimo iškvietimai panašūs į įprastus atgalinimo iškvietimus, tačiau jie yra suaktyvinti kolekcijos gyvavimo ciklo įvykiais. Yra keturi galimi asociacijos atgalinimo iškvietimai:

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

Asociacijos atgalinimo iškvietimus apibrėžiate pridedant parinktis prie asociacijos deklaracijos. Pavyzdžiui:

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_credit_limit

  def check_credit_limit(book)
    # ...
  end
end
```

„Rails“ perduoda pridedamą arba pašalinamą objektą atgalinio iškvietimo funkcijai.
Jūs galite sudėti atgalinį iškvietimą vienam įvykiui, perduodant juos kaip masyvą:

```ruby
class Author < ApplicationRecord
  has_many :books,
    before_add: [:check_credit_limit, :calculate_shipping_charges]

  def check_credit_limit(book)
    # ...
  end

  def calculate_shipping_charges(book)
    # ...
  end
end
```

Jei `before_add` atgalinis iškvietimas išmeta `:abort`, objektas nebus pridėtas prie kolekcijos. Panašiai, jei `before_remove` atgalinis iškvietimas išmeta `:abort`, objektas nebus pašalintas iš kolekcijos:

```ruby
# knyga nebus pridėta, jei pasiektas limitas
def check_credit_limit(book)
  throw(:abort) if limit_reached?
end
```

PASTABA: Šie atgaliniai iškvietimai yra iškviesti tik tada, kai susiję objektai yra pridedami arba pašalinami per asociacijos kolekciją:

```ruby
# Iškviečia `before_add` atgalinį iškvietimą
author.books << book
author.books = [book, book2]

# Neiškviečia `before_add` atgalinio iškvietimo
book.update(author_id: 1)
```

### Asociacijos plėtra

Jūs nesate apribotas tik tuo, ką „Rails“ automatiškai įtraukia į asociacijos tarpininko objektus. Taip pat galite plėsti šiuos objektus per anonimines modulius, pridedant naujų paieškos, kūrėjų ar kitų metodų. Pavyzdžiui:

```ruby
class Author < ApplicationRecord
  has_many :books do
    def find_by_book_prefix(book_number)
      find_by(category_id: book_number[0..2])
    end
  end
end
```

Jei turite plėtinį, kurį norite naudoti daugelyje asociacijų, galite naudoti pavadintą plėtinio modulį. Pavyzdžiui:

```ruby
module FindRecentExtension
  def find_recent
    where("created_at > ?", 5.days.ago)
  end
end

class Author < ApplicationRecord
  has_many :books, -> { extending FindRecentExtension }
end

class Supplier < ApplicationRecord
  has_many :deliveries, -> { extending FindRecentExtension }
end
```

Plėtiniai gali kreiptis į asociacijos tarpininko vidaus veiksmus naudodami šiuos tris `proxy_association` priėjimo atributus:

* `proxy_association.owner` grąžina objektą, kuris yra dalis asociacijos.
* `proxy_association.reflection` grąžina atspindį, kuris aprašo asociaciją.
* `proxy_association.target` grąžina susijusį objektą `belongs_to` arba `has_one`, arba susijusių objektų kolekciją `has_many` arba `has_and_belongs_to_many`.

### Asociacijos ribojimas naudojant asociacijos savininką

Asociacijos savininkas gali būti perduotas kaip vienas argumentas į ribos bloką situacijose, kai jums reikia dar didesnės kontrolės per asociacijos ribą. Tačiau, kaip pastaba, asociacijos išankstinis įkėlimas nebebus įmanomas.

```ruby
class Supplier < ApplicationRecord
  has_one :account, ->(supplier) { where active: supplier.active? }
end
```

Vieno lentelės paveldėjimas (STI)
------------------------------

Kartais norite bendrinti laukus ir elgesį tarp skirtingų modelių. Tarkime, turime modelius „Car“, „Motorcycle“ ir „Bicycle“. Norėsime bendrinti „color“ ir „price“ laukus bei kai kuriuos metodus visiems šiems modeliams, tačiau turėti specifinį elgesį kiekvienam iš jų ir atskirus valdiklius.

Pirma, sugeneruokime pagrindinį „Vehicle“ modelį:

```bash
$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}
```

Ar pastebėjote, kad pridedame „type“ lauką? Kadangi visi modeliai bus išsaugomi vienoje duomenų bazės lentelėje, „Rails“ šiame stulpelyje išsaugos modelio, kuris yra išsaugomas, pavadinimą. Mūsų pavyzdyje tai gali būti „Car“, „Motorcycle“ arba „Bicycle“. STI neveiks be „type“ lauko lentelėje.

Toliau sugeneruosime „Car“ modelį, kuris paveldės iš „Vehicle“. Tai galime padaryti naudodami `--parent=PARENT` parinktį, kuri sugeneruos modelį, paveldintą iš nurodyto tėvo ir be atitinkamos migracijos (kadangi lentelė jau egzistuoja).

Pavyzdžiui, sugeneruoti „Car“ modelį:

```bash
$ bin/rails generate model car --parent=Vehicle
```

Sugeneruotas modelis atrodys taip:

```ruby
class Car < Vehicle
end
```

Tai reiškia, kad visi „Vehicle“ pridėti elgesiai taip pat yra prieinami ir „Car“, kaip asociacijos, vieši metodai ir kt.

Sukūrus automobilį, jis bus išsaugotas „vehicles“ lentelėje su „Car“ kaip „type“ lauku:

```ruby
Car.create(color: 'Red', price: 10000)
```

sukurs šį SQL:

```sql
INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

Užklausiant automobilių įrašus, bus ieškoma tik automobilių:

```ruby
Car.all
```

vykdys užklausą kaip:

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```

Paveldėtų tipų delegavimas
----------------

[`Vieno lentelės paveldėjimas (STI)`](#vieno-lentelės-paveldėjimas-sti) geriausiai veikia, kai yra mažai skirtumo tarp po-klasių ir jų atributų, bet apima visus atributus, kuriuos reikia sukurti vienoje lentelėje.

Šio metodo trūkumas yra tai, kad tai sukelia papildomą apkrovą šiai lentelėje. Kadangi ji netgi apima atributus, kurie yra specifiniai po-klasei ir nenaudojami nieko kito.

Šiame pavyzdyje yra du „Active Record“ modeliai, kurie paveldi iš tos pačios „Entry“ klasės, kurioje yra „subject“ atributas.
```ruby
# Schema: entries[ id, type, subject, created_at, updated_at]
class Entry < ApplicationRecord
end

class Comment < Entry
end

class Message < Entry
end
```

Deleguotosios rūšys išsprendžia šią problemą, naudojant `delegated_type`.

Norint naudoti deleguotas rūšis, turime modeliuoti duomenis tam tikru būdu. Reikalavimai yra šie:

* Yra viršklas, kuri saugo bendras savybes tarp visų po-klasių savo lentelėje.
* Kiekviena po-klasė turi paveldėti iš virš-klasės ir turės atskirą lentelę bet kokioms papildomoms savitoms savybėms.

Tai pašalina poreikį apibrėžti atributus vienoje lentelėje, kurie nenorimai bendrinami tarp visų po-klasių.

Norėdami pritaikyti tai mūsų pavyzdyje aukščiau, turime atnaujinti savo modelius.
Pirma, sugeneruokime pagrindinį `Entry` modelį, kuris veiks kaip mūsų virš-klasė:

```bash
$ bin/rails generate model entry entryable_type:string entryable_id:integer
```

Tada sugeneruosime naujus `Message` ir `Comment` modelius delegavimui:

```bash
$ bin/rails generate model message subject:string body:string
$ bin/rails generate model comment content:string
```

Paleidus generatorius, turėtume gauti modelius, kurie atrodo taip:

```ruby
# Schema: entries[ id, entryable_type, entryable_id, created_at, updated_at ]
class Entry < ApplicationRecord
end

# Schema: messages[ id, subject, body, created_at, updated_at ]
class Message < ApplicationRecord
end

# Schema: comments[ id, content, created_at, updated_at ]
class Comment < ApplicationRecord
end
```

### Deklaruokite `delegated_type`

Pirma, virš-klasėje `Entry` deklaruokite `delegated_type`.

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
end
```

Parametras `entryable` nurodo lauką, kurį naudosime delegavimui, ir įtraukia rūšis `Message` ir `Comment` kaip delegato klases.

Klasė `Entry` turi laukus `entryable_type` ir `entryable_id`. Tai yra laukas su `_type`, `_id` priesaga, pridėta prie pavadinimo `entryable` `delegated_type` apibrėžime.
`entryable_type` saugo delegato po-klasės pavadinimą, o `entryable_id` saugo delegato po-klasės įrašo id.

Toliau turime apibrėžti modulį, kad įgyvendintume tuos deleguotus tipus, deklaruodami `as: :entryable` parametrą `has_one` asociacijai.

```ruby
module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

Tada įtraukite sukurtą modulį į savo po-klasę.

```ruby
class Message < ApplicationRecord
  include Entryable
end

class Comment < ApplicationRecord
  include Entryable
end
```

Baigus šią apibrėžimą, mūsų `Entry` delegatorius dabar teikia šiuos metodus:

| Metodas | Grąžinimas |
|---|---|
| `Entry#entryable_class` | Message arba Comment |
| `Entry#entryable_name` | "message" arba "comment" |
| `Entry.messages` | `Entry.where(entryable_type: "Message")` |
| `Entry#message?` | Grąžina true, kai `entryable_type == "Message"` |
| `Entry#message` | Grąžina message įrašą, kai `entryable_type == "Message"`, kitu atveju `nil` |
| `Entry#message_id` | Grąžina `entryable_id`, kai `entryable_type == "Message"`, kitu atveju `nil` |
| `Entry.comments` | `Entry.where(entryable_type: "Comment")` |
| `Entry#comment?` | Grąžina true, kai `entryable_type == "Comment"` |
| `Entry#comment` | Grąžina comment įrašą, kai `entryable_type == "Comment"`, kitu atveju `nil` |
| `Entry#comment_id` | Grąžina `entryable_id`, kai `entryable_type == "Comment"`, kitu atveju `nil` |

### Objekto kūrimas

Kuriant naują `Entry` objektą, galime tuo pačiu metu nurodyti `entryable` po-klasę.

```ruby
Entry.create! entryable: Message.new(subject: "hello!")
```

### Papildomo delegavimo pridėjimas

Galime išplėsti mūsų `Entry` delegatorių ir toliau pagerinti, apibrėždami `delegates` ir naudodami polimorfizmą po-klasėms.
Pavyzdžiui, deleguoti `title` metodą iš `Entry` į jo po-klases:

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ]
  delegates :title, to: :entryable
end

class Message < ApplicationRecord
  include Entryable

  def title
    subject
  end
end

class Comment < ApplicationRecord
  include Entryable

  def title
    content.truncate(20)
  end
end
```
[`belongs_to`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
[`has_and_belongs_to_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_and_belongs_to_many
[`has_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many
[`has_one`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one
[connection.add_reference]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[foreign_keys]: active_record_migrations.html#foreign-keys
[`config.active_record.automatic_scope_inversing`]: configuring.html#config-active-record-automatic-scope-inversing
[`reset_counters`]: https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-reset_counters
[`collection<<`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-3C-3C
[`collection.build`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-build
[`collection.clear`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-clear
[`collection.create`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create
[`collection.create!`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create-21
[`collection.delete`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-delete
[`collection.destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-destroy
[`collection.empty?`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-empty-3F
[`collection.exists?`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F
[`collection.find`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-find
[`collection.reload`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-reload
[`collection.size`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-size
[`collection.where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
