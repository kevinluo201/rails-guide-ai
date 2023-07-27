**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b2cb0ab668ead9e8bd48cbd1bcac9b59
Aktyvusis įrašas: pagrindai
====================

Šis vadovas yra įvadas į aktyvųjį įrašą.

Po šio vadovo perskaitymo jūs žinosite:

* Kas yra objektų-relacinių atvaizdavimų ir aktyvaus įrašo naudojimas „Rails“.
* Kaip aktyvusis įrašas telpa į modelio-peržiūros-valdiklio paradigma.
* Kaip naudoti aktyvaus įrašo modelius, kad manipuliuotumėte duomenimis, saugomais reliacinėje duomenų bazėje.
* Aktyvaus įrašo schemos pavadinimo konvencijos.
* Duomenų bazės migracijų, patikrinimų, atgalinių iškvietimų ir asociacijų sąvokos.

--------------------------------------------------------------------------------

Kas yra aktyvusis įrašas?
----------------------

Aktyvusis įrašas yra M „MVC“ - modelis - tai sistemos sluoksnis, atsakingas už verslo duomenis ir logiką. Aktyvusis įrašas palengvina verslo objektų kūrimą ir naudojimą, kurių duomenys reikalauja nuolatinio saugojimo duomenų bazėje. Tai yra aktyvaus įrašo modelio įgyvendinimas, kuris pats yra objektų-relacinių atvaizdavimo sistemos aprašymas.

### Aktyvaus įrašo modelis

[Aktyvus įrašas buvo aprašytas Martinu Fowleriu][MFAR] jo knygoje „Enterprise Application Architecture Patterns“. Aktyvusis įrašas, objektai neša tiek nuolatinius duomenis, tiek elgesį, kuris veikia su šiais duomenimis. Aktyvusis įrašas mano, kad užtikrinant duomenų prieigos logiką kaip dalį objekto, tai išmokys šio objekto naudotojus, kaip rašyti ir skaityti iš duomenų bazės.

### Objektų-relacinių atvaizdavimas

[Objektų-relacinių atvaizdavimas][ORM], dažnai vadinamas jo santrumpa ORM, yra technika, kuri jungia aplikacijos turtingus objektus su lentelėmis reliacinėje duomenų bazės valdymo sistemoje. Naudojant ORM, aplikacijos objektų savybės ir ryšiai gali būti lengvai saugomi ir išgauti iš duomenų bazės, nerašant SQL užklausų tiesiogiai ir mažiau bendrojo duomenų bazės prieigos kodo.

Pastaba: Pagrindinė žinių apie reliacines duomenų bazes (RDBMS) ir struktūrizuotą užklausų kalbą (SQL) yra naudinga, norint visiškai suprasti aktyvųjį įrašą. Norėdami sužinoti daugiau, kreipkitės į [šį vadovą][sqlcourse] (arba [šį][rdbmsinfo]) arba studijuokite juos kitaip.

### Aktyvusis įrašas kaip ORM pagrindas

Aktyvusis įrašas suteikia mums keletą mechanizmų, svarbiausias iš jų yra galimybė:

* Repristatyti modelius ir jų duomenis.
* Repristatyti ryšius tarp šių modelių.
* Repristatyti paveldėjimo hierarchijas per susijusius modelius.
* Patikrinti modelius prieš juos išsaugant duomenų bazėje.
* Atlikti duomenų bazės operacijas objektiškai.

Konvencija prieš konfigūraciją aktyviame įraše
----------------------------------------------

Rašant programas naudojant kitas programavimo kalbas ar karkasus, gali būti būtina parašyti daug konfigūracijos kodo. Tai ypač pasakytina apie ORM karkasus apskritai. Tačiau, jei laikotės „Rails“ priimtų konvencijų, kuriant aktyvaus įrašo modelius, jums reikės parašyti labai mažai konfigūracijos (kai kuriuose atveju visai nereikia konfigūracijos). Idėja yra ta, kad jei dažniausiai konfigūruojate savo programas ta pačiai būdu, tai turėtų būti numatytasis būdas. Taigi, aiški konfigūracija būtų reikalinga tik tuomet, kai negalite laikytis standartinės konvencijos.

### Pavadinimo konvencijos

Pagal numatytuosius nustatymus aktyvusis įrašas naudoja kai kurias pavadinimo konvencijas, kad sužinotų, kaip sukurti atitinkamą modelio ir duomenų bazės lentelės atvaizdavimą. „Rails“ daugins jūsų klasės pavadinimus, kad rastų atitinkamą duomenų bazės lentelę. Taigi, klasės „Book“ atveju turėtumėte turėti duomenų bazės lentelę, vadinamą **books**. „Rails“ dauginimo mechanizmai yra labai galingi, galintys dauginti (ir vienaskaitinti) tiek reguliarius, tiek nereguliarius žodžius. Naudojant iš dviejų ar daugiau žodžių sudarytus klasės pavadinimus, modelio klasės pavadinimas turėtų sekti „Ruby“ konvencijas, naudojant „CamelCase“ formą, o lentelės pavadinimas turi naudoti „snake_case“ formą. Pavyzdžiai:

* Modelio klasė - Vienaskaita su kiekvieno žodžio pirmąja raide didžiąja (pvz., `BookClub`).
* Duomenų bazės lentelė - Daugiskaita su pabraukimais tarp žodžių (pvz., `book_clubs`).

| Modelio / Klasės pavadinimas | Lentelės / Schemos pavadinimas |
| --------------------------- | ----------------------------- |
| `Article`                   | `articles`                    |
| `LineItem`                  | `line_items`                  |
| `Deer`                      | `deers`                       |
| `Mouse`                     | `mice`                        |
| `Person`                    | `people`                      |

### Schemos konvencijos

Aktyvusis įrašas naudoja pavadinimo konvencijas duomenų bazės lentelėse esančioms stulpelių, priklausomai nuo šių stulpelių paskirties.

* **Užsienio raktai** - Šie laukai turėtų būti pavadinti pagal šabloną
  `singularized_table_name_id` (pvz., `item_id`, `order_id`). Tai yra
  laukai, kuriuos aktyvusis įrašas ieškos, kai kuriate asociacijas tarp
  savo modelių.
* **Pagrindiniai raktai** - Pagal numatytuosius nustatymus aktyvusis įrašas naudos sveikųjų skaičių stulpelį, pavadintą `id`, kaip lentelės pagrindinį raktą (`bigint` „PostgreSQL“ ir „MySQL“ atveju, `integer` „SQLite“ atveju). Naudojant [aktyvaus įrašo migracijas](active_record_migrations.html) savo lentelėms kurti, šis stulpelis bus automatiškai sukurtas.
Taip pat yra keletas pasirinktinų stulpelių pavadinimų, kurie prideda papildomas funkcijas Active Record objektams:

* `created_at` - Automatiškai nustatomas į dabartinę datą ir laiką, kai įrašas pirmą kartą sukurtas.
* `updated_at` - Automatiškai nustatomas į dabartinę datą ir laiką, kai įrašas yra sukurtas arba atnaujinamas.
* `lock_version` - Prideda [optimistinį užrakinimą](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html) modeliui.
* `type` - Nurodo, kad modelis naudoja [vieno lentelės paveldėjimą](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance).
* `(sąjungos_pavadinimas)_type` - Saugo tipą [polimorfinėms sąsajoms](association_basics.html#polymorphic-associations).
* `(lentelės_pavadinimas)_count` - Naudojamas kaupiant priklausančių objektų skaičių sąsajose. Pavyzdžiui, `comments_count` stulpelis `Article` klasėje, kuri turi daug `Comment` objektų, kaupia esamų komentarų skaičių kiekvienam straipsniui.

PASTABA: Nors šie stulpelių pavadinimai yra pasirinktiniai, jie iš tikrųjų yra rezervuoti Active Record. Venkite rezervuotų žodžių, nebent norite papildomos funkcionalumo. Pavyzdžiui, `type` yra rezervuotas žodis, naudojamas nurodyti lentelę, naudojant vieno lentelės paveldėjimą (STI). Jei nenaudojate STI, pabandykite panašų žodį, pvz., "context", kuris vis tiek gali tiksliai apibūdinti modeliuojamus duomenis.

Kuriant Active Record modelius
-----------------------------

Generuojant aplikaciją, `app/models/application_record.rb` bus sukurtas abstraktus `ApplicationRecord` klasės failas. Tai yra pagrindinė klasė visiems aplikacijos modeliams ir tai, kas paverčia įprastą Ruby klasę į Active Record modelį.

Norėdami sukurti Active Record modelius, paveldėkite `ApplicationRecord` klasę ir jūs galite pradėti:

```ruby
class Product < ApplicationRecord
end
```

Tai sukurs `Product` modelį, susiejantį su `products` lentele duomenų bazėje. Taip padarydami, turėsite galimybę susieti kiekvieno įrašo stulpelius šios lentelės su jūsų modelio objektų atributais. Pavyzdžiui, jei `products` lentele buvo sukurta naudojant SQL (arba vieną iš jo plėtinių) užklausą, panašią į šią:

```sql
CREATE TABLE products (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
);
```

Pateikta schemoje deklaruojama lentele su dviem stulpeliais: `id` ir `name`. Kiekvienas šios lentelės įrašas atitinka tam tikrą produktą su šiais du parametrais. Taigi, galėtumėte rašyti kodą, panašų į šį:

```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

Perrašant pavadinimo konvencijas
--------------------------------

Ką daryti, jei norite naudoti kitą pavadinimo konvenciją arba norite naudoti savo Rails aplikaciją su sena duomenų baze? Nėra problema, galite lengvai perrašyti numatytąsias konvencijas.

Kadangi `ApplicationRecord` paveldi iš `ActiveRecord::Base`, jūsų aplikacijos modeliams bus prieinama daug naudingų metodų. Pavyzdžiui, galite naudoti `ActiveRecord::Base.table_name=` metodą, kad priderintumėte naudojamą lentelės pavadinimą:

```ruby
class Product < ApplicationRecord
  self.table_name = "my_products"
end
```

Tai padarius, turėsite rankiniu būdu apibrėžti klasės pavadinimą, kuri talpina fiktyvius duomenis (`my_products.yml`), naudodami `set_fixture_class` metodą savo testų aprašyme:

```ruby
# test/models/product_test.rb
class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
  # ...
end
```

Taip pat galima perrašyti stulpelį, kuris turėtų būti naudojamas kaip lentelės pirminis raktas, naudojant `ActiveRecord::Base.primary_key=` metodą:

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

PASTABA: **Active Record nepalaiko naudoti ne pirminio rakto stulpelius, kurie vadinasi `id`.**

PASTABA: Jei bandysite sukurti stulpelį, kuris vadinasi `id` ir nėra pirminis raktas, Rails metuose, pvz., migracijose, bus išmetama klaida, tokia kaip:
`you can't redefine the primary key column 'id' on 'my_products'.`
`To define a custom primary key, pass { id: false } to create_table.`

CRUD: Duomenų skaitymas ir rašymas
------------------------------

CRUD yra akronimas, kuris apibūdina keturis veiksmus, kuriuos naudojame dirbdami su duomenimis: **C**reate (kurti), **R**ead (skaityti), **U**pdate (atnaujinti) ir **D**elete (trinti). Active Record automatiškai sukuria metodus, leidžiančius aplikacijai skaityti ir manipuliuoti duomenimis, saugomais lentelėse.

### Kurti

Active Record objektai gali būti sukurti iš hash'o, bloko arba jų atributai gali būti nustatomi rankiniu būdu po sukūrimo. `new` metodas grąžins naują objektą, o `create` grąžins objektą ir jį išsaugos duomenų bazėje.

Pavyzdžiui, turint modelį `User` su atributais `name` ir `occupation`, `create` metodo iškvietimas sukurs ir išsaugos naują įrašą duomenų bazėje:

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```
Naudodami `new` metodą, galite sukurti objektą, nesaugodami jo:

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

Iškvietus `user.save`, įrašas bus įrašytas į duomenų bazę.

Galiausiai, jei pateikiamas blokas, tiek `create`, tiek `new` perduos naują
objektą tam blokui inicializuoti, tačiau tik `create` išsaugos
gaunamą objektą į duomenų bazę:

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### Skaityti

Active Record teikia gausią API, skirtą duomenų prieigai prie duomenų bazės. Žemiau
pateikiami keli pavyzdžiai, kaip naudoti skirtingus duomenų prieigos metodus, kuriuos teikia Active Record.

```ruby
# grąžinti kolekciją su visais vartotojais
users = User.all
```

```ruby
# grąžinti pirmą vartotoją
user = User.first
```

```ruby
# grąžinti pirmą vartotoją, vardu David
david = User.find_by(name: 'David')
```

```ruby
# rasti visus vartotojus, kurių vardas David ir profesija Code Artist, ir surūšiuoti pagal sukūrimo datą atvirkštine tvarka
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

Daugiau informacijos apie užklausas į Active Record modelį galite rasti [Active Record
Query Interface](active_record_querying.html) vadove.

### Atnaujinti

Gavus Active Record objektą, galima modifikuoti jo atributus
ir jį išsaugoti į duomenų bazę.

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

Trumpinys šiam veiksmui yra naudoti hash'ą, kuriame atributai yra susieti su norimu
reikšme, pavyzdžiui:

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

Tai yra naudinga, kai reikia atnaujinti kelis atributus vienu metu.

Jei norite atnaujinti kelis įrašus masiškai **be iškvietimo atgalinio kvietimo ar
tikrinimo**, galite tiesiogiai atnaujinti duomenų bazę naudodami `update_all`:

```ruby
User.update_all max_login_attempts: 3, must_change_password: true
```

### Ištrinti

Taip pat, gavus Active Record objektą, jį galima sunaikinti, tai pašalins
jį iš duomenų bazės.

```ruby
user = User.find_by(name: 'David')
user.destroy
```

Jei norite ištrinti kelis įrašus masiškai, galite naudoti `destroy_by`
arba `destroy_all` metodą:

```ruby
# rasti ir ištrinti visus vartotojus, kurių vardas David
User.destroy_by(name: 'David')

# ištrinti visus vartotojus
User.destroy_all
```

Validacijos
-----------

Active Record leidžia jums patikrinti modelio būseną prieš jį įrašant
į duomenų bazę. Yra keletas metodų, kuriuos galite naudoti, kad patikrintumėte
savo modelius ir patikrintumėte, ar atributo reikšmė nėra tuščia, yra unikali ir
dar nėra duomenų bazėje, atitinka tam tikrą formatą ir daugiau.

Metodai, tokie kaip `save`, `create` ir `update`, patikrina modelį prieš jį išsaugant
į duomenų bazę. Kai modelis yra neteisingas, šie metodai grąžina `false` ir jokie
duomenų bazės veiksmai nevykdomi. Visi šie metodai turi bang priešininkus
(tai yra, `save!`, `create!` ir `update!`), kurie yra griežtesni, nes jie
kelia `ActiveRecord::RecordInvalid` išimtį, kai validacija nesėkminga.
Greitas pavyzdys:

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> user = User.new
irb> user.save
=> false
irb> user.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

Daugiau apie validacijas galite sužinoti [Active Record Validations
guide](active_record_validations.html).

Atgaliniai kvietimai
---------

Active Record atgaliniai kvietimai leidžia pridėti kodą prie tam tikrų modelio
gyvavimo ciklo įvykių. Tai leidžia pridėti elgseną prie modelių,
kai šie įvykiai įvyksta, pvz., kai sukuriamas naujas
įrašas, jis atnaujinamas, sunaikinamas ir t.t.

```ruby
class User < ApplicationRecord
  after_create :log_new_user

  private
    def log_new_user
      puts "A new user was registered"
    end
end
```

```irb
irb> @user = User.create
A new user was registered
```

Daugiau apie atgalinius kvietimus galite sužinoti [Active Record Callbacks
guide](active_record_callbacks.html).

Migracijos
----------

Rails suteikia patogų būdą valdyti duomenų bazės schemos pakeitimus naudojant
migracijas. Migracijos yra rašomos domeno specifiniu kalbos ir saugomos
failuose, kurie vykdomi prieš bet kurią duomenų bazę, kurią palaiko Active Record.

Čia yra migracija, kuri sukuria naują lentelę, vadinamą `publications`:

```ruby
class CreatePublications < ActiveRecord::Migration[7.1]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.references :publisher, polymorphic: true
      t.boolean :single_issue

      t.timestamps
    end
  end
end
```

Reikia pažymėti, kad aukščiau pateiktas kodas yra nepriklausomas nuo duomenų bazės: jis veiks MySQL,
PostgreSQL, SQLite ir kitose duomenų bazėse.

Rails seka, kurios migracijos buvo įrašytos į duomenų bazę ir jas saugo
šalia esančioje lentelėje toje pačioje duomenų bazėje, vadinamoje `schema_migrations`.
Norint paleisti migraciją ir sukurti lentelę, reikia paleisti `bin/rails db:migrate`, o norint atšaukti migraciją ir ištrinti lentelę, `bin/rails db:rollback`.

Daugiau informacijos apie migracijas galite rasti [Active Record Migrations
gide](active_record_migrations.html).

Asociacijos
------------

Active Record asociacijos leidžia apibrėžti ryšius tarp modelių. Asociacijos gali būti naudojamos aprašyti vienas-prie-vieno, vienas-prie-daug ir daug-prie-daug ryšius. Pavyzdžiui, ryšį "Autorius turi daug Knygų" galima apibrėžti taip:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

Autoriaus klasėje dabar yra metodai, skirti pridėti ir pašalinti knygas iš autoriaus ir daugiau.

Daugiau informacijos apie asociacijas galite rasti [Active Record Associations
gide](association_basics.html).
[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[MFAR]: https://www.martinfowler.com/eaaCatalog/activeRecord.html
[ORM]: https://en.wikipedia.org/wiki/Object-relational_mapping
[sqlcourse]: https://www.khanacademy.org/computing/computer-programming/sql
[rdbmsinfo]: https://www.devart.com/what-is-rdbms/
