**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 311d5225fa32d069369256501f31c507
Aktyvusis įrašo migracijos
========================

Migracijos yra Active Record funkcija, leidžianti evoliucionuoti duomenų bazės schemą laikui bėgant. Vietoj to, kad rašytumėte schemos modifikacijas grynais SQL, migracijos leidžia jums naudoti Ruby DSL, kad aprašytumėte pakeitimus savo lentelėms.

Po šio vadovo perskaitymo, žinosite:

* Generatorius, kuriuos galite naudoti jų sukūrimui.
* Metodus, kuriuos Active Record teikia jūsų duomenų bazei manipuliuoti.
* Rails komandas, kurios manipuliuoja migracijomis ir jūsų schema.
* Kaip migracijos susijusios su `schema.rb`.

--------------------------------------------------------------------------------

Migracijų apžvalga
------------------

Migracijos yra patogus būdas [palaipsniui keisti duomenų bazės schemą](https://en.wikipedia.org/wiki/Schema_migration) nuosekliai. Jos naudoja Ruby DSL, todėl jums nereikia rašyti SQL ranka, leidžiant jūsų schemai ir pakeitimams būti nepriklausomiems nuo duomenų bazės.

Galite manyti, kad kiekviena migracija yra nauja duomenų bazės 'versija'. Pradžioje schema nieko neturi, o kiekviena migracija ją keičia, pridedant arba pašalindama lentelės, stulpelių ar įrašų. Active Record žino, kaip atnaujinti schemą pagal šį laiko juostą, nuo bet kurios istorijos taško iki naujausios versijos. Active Record taip pat atnaujins jūsų `db/schema.rb` failą, kad jis atitiktų jūsų duomenų bazės struktūros naujausią versiją.

Štai migracijos pavyzdys:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Ši migracija prideda lentelę, vadinamą `products`, su string tipo stulpeliu, vadinamu `name`, ir teksto tipo stulpeliu, vadinamu `description`. Primarinis raktas, vadinamas `id`, taip pat bus pridėtas neaiškiai, nes tai yra numatytasis pagrindinis raktas visiems Active Record modeliams. `timestamps` makras prideda du stulpelius, `created_at` ir `updated_at`. Šie specialūs stulpeliai automatiškai valdomi Active Record, jei jie egzistuoja.

Atkreipkite dėmesį, kad mes apibrėžiame pakeitimą, kurį norime, kad įvyktų ateityje. Prieš paleidžiant šią migraciją, lentelės nebus. Po jos lentelė egzistuos. Active Record taip pat žino, kaip atšaukti šią migraciją: jei atšauksime šią migraciją, ji pašalins lentelę.

Duomenų bazėse, kurios palaiko transakcijas su schemą keičiančiais teiginiais, kiekviena migracija yra apgaubta transakcija. Jei duomenų bazė nepalaiko to, tada, kai migracija nepavyksta, jos dalys, kurios pavyko, nebus atšauktos. Jums reikės rankiniu būdu atšaukti padarytus pakeitimus.

PASTABA: Yra tam tikrų užklausų, kurios negali būti vykdomos transakcijoje. Jei jūsų adapteris palaiko DDL transakcijas, galite naudoti `disable_ddl_transaction!` jas išjungti vienai migracijai.

### Padarant neišvengiamą įmanomą

Jei norite, kad migracija atliktų kažką, ką Active Record nežino, kaip atšaukti, galite naudoti `reversible`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      change_table :products do |t|
        direction.up   { t.change :price, :string }
        direction.down { t.change :price, :integer }
      end
    end
  end
end
```

Ši migracija pakeis `price` stulpelio tipą į stringą arba atgal į sveikąjį skaičių, kai migracija bus atšaukta. Pastebėkite bloką, kuris perduodamas `direction.up` ir `direction.down` atitinkamai.

Alternatyviai, galite naudoti `up` ir `down` vietoj `change`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def up
    change_table :products do |t|
      t.change :price, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :price, :integer
    end
  end
end
```

INFO: Daugiau apie [`reversible`](#using-reversible) vėliau.

Generuojant migracijas
----------------------

### Sukuriant atskirą migraciją

Migracijos yra saugomos kaip failai `db/migrate` kataloge, vienas migracijos klasės failas. Failo pavadinimas yra formos `YYYYMMDDHHMMSS_create_products.rb`, t. y. UTC laiko žymė, nurodanti migraciją, pasekta pabraukimo ir migracijos pavadinimo. Migracijos klasės pavadinimas (CamelCased versija) turėtų atitikti failo pavadinimo vėlesnę dalį. Pavyzdžiui, `20080906120000_create_products.rb` turėtų apibrėžti klasę `CreateProducts`, o `20080906120001_add_details_to_products.rb` turėtų apibrėžti `AddDetailsToProducts`. Rails naudoja šią laiko žymę, kad nustatytų, kuri migracija turėtų būti paleista ir kokia tvarka, todėl jei kopijuojate migraciją iš kitos programos arba generuojate failą patys, atkreipkite dėmesį į jo poziciją tvarkoje.

Žinoma, skaičiuoti laiko žymes nėra smagu, todėl Active Record teikia generatorių, kuris tai padarys už jus:

```bash
$ bin/rails generate migration AddPartNumberToProducts
```
Tai sukurs tinkamai pavadintą tuščią migraciją:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
  end
end
```

Šis generatorius gali padaryti daugiau nei tik pridėti laiko žymą prie failo pavadinimo.
Remiantis pavadinimo konvencijomis ir papildomais (neprivalomais) argumentais,
jis taip pat gali pradėti užpildyti migraciją.

### Pridedant naujas stulpelius

Jei migracijos pavadinimas yra formos "AddColumnToTable" arba
"RemoveColumnFromTable" ir po jo seka stulpelių pavadinimų ir
tipų sąrašas, bus sukurta migracija, kurioje bus tinkami [`add_column`][] ir
[`remove_column`][] teiginiai.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

Tai sukurs šią migraciją:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
  end
end
```

Jei norite pridėti indeksą naujam stulpeliui, taip pat galite tai padaryti.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

Tai sukurs tinkamus [`add_column`][] ir [`add_index`][] teiginius:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

Jūs **nepriklausote** nuo vieno stebuklingai sugeneruoto stulpelio. Pavyzdžiui:

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

Sukurs schemos migraciją, kuri pridės du papildomus
stulpelius į `products` lentelę.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

### Pašalinant stulpelius

Panašiai galite sukurti migraciją, skirtą pašalinti stulpelį iš komandinės eilutės:

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

Tai sukuria tinkamus [`remove_column`][] teiginius:

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :part_number, :string
  end
end
```

### Sukuriant naujas lentelės

Jei migracijos pavadinimas yra formos "CreateXXX" ir po jo seka sąrašas
stulpelių pavadinimų ir tipų, bus sugeneruota migracija, kurioje bus sukurta
lentelė XXX su nurodytais stulpeliais. Pavyzdžiui:

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```

sukuria

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :part_number

      t.timestamps
    end
  end
end
```

Kaip visada, tai, kas jums buvo sugeneruota, yra tik pradinis taškas.
Galite pridėti arba pašalinti iš jo, kaip norite, redaguodami
`db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb` failą.

### Sukuriant asociacijas naudojant nuorodas

Taip pat, generatorius priima stulpelio tipą `references` (taip pat galima
`belongs_to`). Pavyzdžiui,

```bash
$ bin/rails generate migration AddUserRefToProducts user:references
```

sukuria šį [`add_reference`][] kvietimą:

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

Ši migracija sukurs `user_id` stulpelį. [Nuorodos](#nuorodos) yra
trumpinys, skirtas kurti stulpelius, indeksus, užsienio raktus ar netgi polimorfinius
asociacijos stulpelius.

Taip pat yra generatorius, kuris sukurs jungiamąsias lenteles, jei `JoinTable` yra dalis pavadinimo:

```bash
$ bin/rails generate migration CreateJoinTableCustomerProduct customer product
```

sukurs šią migraciją:

```ruby
class CreateJoinTableCustomerProduct < ActiveRecord::Migration[7.1]
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
    end
  end
end
```


### Modelio generatoriai

Modelio, resurso ir scaffold generatoriai sukurs migracijas, tinkamas naujo modelio pridėjimui.
Ši migracija jau bus instrukcijos, skirtos sukurti atitinkamą lentelę. Jei pasakysite Rails, kokius stulpelius norite, tada bus sukurti ir teiginiai
pridėti šiuos stulpelius. Pavyzdžiui, paleidus:

```bash
$ bin/rails generate model Product name:string description:text
```

Tai sukurs migraciją, kuri atrodys taip:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Galite pridėti tiek stulpelio pavadinimo/ tipo porų, kiek norite.

### Perduodant modifikatorius

Kai kurie dažnai naudojami [tipo modifikatoriai](#stulpelio-modifikatoriai) gali būti perduodami tiesiogiai
komandinėje eilutėje. Jie yra apgaubti riestinėmis skliaustais ir seka po lauko tipo:

Pavyzdžiui, paleidus:

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

bus sukurta migracija, kuri atrodys taip

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

PATARIMAS: Peržiūrėkite generatoriaus pagalbos išvestį (`bin/rails generate --help`)
dėl išsamesnės informacijos.

Rašant migracijas
------------------

Kai sukūrėte migraciją naudodami vieną iš generatorių, laikas pradėti
dirbti!

### Lentelės kūrimas

[`create_table`][] metodas yra vienas iš pagrindinių, bet dažniausiai
bus sugeneruotas jums naudojant modelio, resurso ar scaffold generatorių. Tipiškas
naudojimas būtų
```ruby
create_table :products do |t|
  t.string :name
end
```

Šis metodas sukuria `products` lentelę su stulpeliu, vadinamu `name`.

Pagal numatytuosius nustatymus, `create_table` automatiškai sukurs pirminį raktą, vadinamą `id`. Galite pakeisti stulpelio pavadinimą naudojant `:primary_key` parinktį arba, jei nenorite pirminio rakto, galite perduoti parinktį `id: false`.

Jei norite perduoti duomenų bazės specifines parinktis, galite įdėti SQL fragmentą į `:options` parinktį. Pavyzdžiui:

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

Tai pridės `ENGINE=BLACKHOLE` prie SQL užklausos, skirtos sukurti lentelę.

Indeksas gali būti sukurtas ant stulpelių, sukurtų `create_table` bloke, perduodant `index: true` arba parinkčių maišą į `:index` parinktį:

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

Taip pat galite perduoti `:comment` parinktį su bet kokiu aprašymu lentelės, kuris bus saugomas pačioje duomenų bazėje ir galės būti peržiūrimas naudojant duomenų bazės administravimo įrankius, pvz., MySQL Workbench arba PgAdmin III. Labai rekomenduojama nurodyti komentarus migracijose didelių duomenų bazių programoms, nes tai padeda žmonėms suprasti duomenų modelį ir generuoti dokumentaciją. Šiuo metu komentarai palaikomi tik MySQL ir PostgreSQL adapteriais.


### Sukuriant jungiamąją lentelę

Migracijos metodas [`create_join_table`][] sukuria HABTM (turi ir priklauso daugeliui) jungiamąją lentelę. Tipiškas naudojimas būtų:

```ruby
create_join_table :products, :categories
```

Ši migracija sukurs `categories_products` lentelę su dviem stulpeliais, vadinamais `category_id` ir `product_id`.

Šie stulpeliai pagal numatytuosius nustatymus turi `:null` parinktį, nustatytą į `false`, tai reiškia, kad **turite** pateikti reikšmę, norėdami išsaugoti įrašą į šią lentelę. Tai galima pakeisti nurodant `:column_options` parinktį:

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

Pagal numatytuosius nustatymus, jungiamosios lentelės pavadinimas sudaromas iš pirmų dviejų `create_join_table` pateiktų argumentų, abėcėlės tvarka.

Norėdami tinkinti lentelės pavadinimą, nurodykite `:table_name` parinktį:

```ruby
create_join_table :products, :categories, table_name: :categorization
```

Tai užtikrins, kad jungiamosios lentelės pavadinimas bus `categorization`, kaip prašyta.

Taip pat, `create_join_table` priima bloką, kurį galite naudoti, norėdami pridėti indeksus (kurie pagal numatytuosius nustatymus nėra sukurti) arba bet kokius papildomus stulpelius, kuriuos pasirinksite.

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```


### Lentelių keitimas

Jei norite pakeisti esamą lentelę vietoje, yra [`change_table`][].

Jis naudojamas panašiai kaip `create_table`, tačiau objektas, kuris yra perduodamas bloke, turi prieigą prie kelių specialių funkcijų, pavyzdžiui:

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

Ši migracija pašalins `description` ir `name` stulpelius, sukurs naują `part_number` tekstinį stulpelį ir pridės indeksą. Galiausiai ji pervadins `upccode` stulpelį į `upc_code`.


### Stulpelių keitimas

Panašiai kaip `remove_column` ir `add_column` metodai, apie kuriuos mes kalbėjome [ankstesniame](#adding-new-columns) skyriuje, Rails taip pat teikia [`change_column`][] migracijos metodą.

```ruby
change_column :products, :part_number, :text
```

Tai pakeis `part_number` stulpelį produkto lentelėje į `:text` lauką.

PASTABA: `change_column` komanda yra **neatstatoma**. Turėtumėte pateikti savo `reversible` migraciją, kaip mes aptarėme [ankstesniame](#making-the-irreversible-possible) skyriuje.

Be `change_column`, [`change_column_null`][] ir [`change_column_default`][] metodai naudojami specifiškai keisti null apribojimą ir stulpelių numatytąsias reikšmes.

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

Tai nustato `:name` lauką produkto lentelėje kaip `NOT NULL` stulpelį ir numatytąją `:approved` lauko reikšmę nuo `true` iki `false`. Šie pakeitimai bus taikomi tik ateities transakcijoms, jokie esami įrašai netaikomi.

Nustatant null apribojimą kaip `true`, tai reiškia, kad stulpelis priims null reikšmę, kitaip taikomas `NOT NULL` apribojimas ir reikia perduoti reikšmę, norint išsaugoti įrašą duomenų bazėje.

PASTABA: Taip pat galėtumėte parašyti aukščiau pateiktą `change_column_default` migraciją kaip `change_column_default :products, :approved, false`, bet, skirtingai nei ankstesnis pavyzdys, tai padarytų jūsų migraciją neatstatomą.


### Stulpelių keitikliai

Stulpelių keitikliai gali būti taikomi kuriant ar keičiant stulpelį:

* `comment`      Prideda komentarą stulpeliui.
* `collation`    Nurodo `string` ar `text` stulpelio kolaciją.
* `default`      Leidžia nustatyti numatytąją reikšmę stulpeliui. Atkreipkite dėmesį, kad jei naudojate dinaminę reikšmę (pvz., datą), numatytasis bus apskaičiuotas tik pirmą kartą (t. y. migracijos taikymo dieną). Naudokite `nil` reikšmei `NULL`.
* `limit`        Nustato maksimalų simbolių skaičių `string` stulpeliui ir maksimalų baitų skaičių `text/binary/integer` stulpeliams.
* `null`         Leidžia arba neleidžia `NULL` reikšmes stulpelyje.
* `precision`    Nurodo `decimal/numeric/datetime/time` stulpelių tikslumą.
* `scale`        Nurodo `decimal` ir `numeric` stulpelių mastelį, kuris nurodo skaičių skaitmenų po kablelio skaičių.
PASTABA: `add_column` arba `change_column` metodu nėra galimybės pridėti indeksų.
Jie turi būti atskirai pridėti naudojant `add_index`.

Kai kurie adapteriai gali palaikyti papildomus parametrus; daugiau informacijos rasite adapterio specifinėje API dokumentacijoje.

PASTABA: `null` ir `default` negali būti nurodyti komandinėje eilutėje generuojant migracijas.

### Nuorodos

`add_reference` metodas leidžia sukurti tinkamai pavadintą stulpelį, veikiantį kaip ryšys tarp vienos ar kelių asociacijų.

```ruby
add_reference :users, :role
```

Ši migracija sukurs `role_id` stulpelį vartotojų lentelėje. Ji taip pat sukurs indeksą šiam stulpeliui, nebent bus aiškiai nurodyta, kad jo nereikia su `index: false` parametru.

INFORMACIJA: Daugiau informacijos rasite [Active Record Associations][] vadove.

`add_belongs_to` metodas yra sinonimas `add_reference`.

```ruby
add_belongs_to :taggings, :taggable, polymorphic: true
```

Polimorfinės parinkties atveju ši migracija sukurs du stulpelius taggings lentelėje, kurie gali būti naudojami polimorfiniams ryšiams: `taggable_type` ir `taggable_id`.

INFORMACIJA: Daugiau apie [polimorfines asociacijas][] sužinosite šiame vadove.

Užsienio raktas gali būti sukurtas naudojant `foreign_key` parinktį.

```ruby
add_reference :users, :role, foreign_key: true
```

Daugiau `add_reference` parinkčių rasite [API dokumentacijoje](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference).

Nuorodos taip pat gali būti pašalintos:

```ruby
remove_reference :products, :user, foreign_key: true, index: false
```

[Active Record Associations]: association_basics.html
[polimorfines asociacijas]: association_basics.html#polimorfines-asociacijos

### Užsienio raktai

Nors tai nėra būtina, galite norėti pridėti užsienio rakto apribojimus, kad
užtikrintumėte referencinę vientisumą.

```ruby
add_foreign_key :articles, :authors
```

Šis [`add_foreign_key`][] kvietimas prideda naują apribojimą į `articles` lentelę.
Apribojimas garantuoja, kad `authors` lentelėje egzistuoja eilutė, kurioje
`id` stulpelis atitinka `articles.author_id`.

Jei `from_table` stulpelio pavadinimas negali būti išvestas iš `to_table` pavadinimo,
galite naudoti `:column` parinktį. Jei nurodytas pagrindinio rakto stulpelis nėra `:id`, naudokite `:primary_key` parinktį.

Pavyzdžiui, norint pridėti užsienio raktą `articles.reviewer`, kuris rodo į `authors.email`:

```ruby
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

Tai pridės apribojimą į `articles` lentelę, kuris garantuos, kad `authors` lentelėje egzistuoja eilutė, kurioje `email` stulpelis atitinka `articles.reviewer` lauką.

`add_foreign_key` palaiko ir kitas parinktis, tokias kaip `name`, `on_delete`, `if_not_exists`, `validate` ir `deferrable`.

Užsienio raktai taip pat gali būti pašalinti naudojant [`remove_foreign_key`][]:

```ruby
# leisti Active Record nustatyti stulpelio pavadinimą
remove_foreign_key :accounts, :branches

# pašalinti užsienio raktą tam tikram stulpeliui
remove_foreign_key :accounts, column: :owner_id
```

PASTABA: Active Record palaiko tik vieno stulpelio užsienio raktus. Sudėtiniai užsienio raktai reikalauja `execute` ir `structure.sql`. Daugiau informacijos rasite
[Schema Dumping and You](#schema-dumping-and-you).

### Kai pagalbininkai nepakanka

Jei Active Record teikiami pagalbininkai nepakanka, galite naudoti [`execute`][]
metodą vykdyti bet kokį SQL užklausą:

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

Daugiau informacijos ir pavyzdžių apie atskirus metodus rasite API dokumentacijoje.

Ypač apie [`ActiveRecord::ConnectionAdapters::SchemaStatements`][] dokumentaciją, kuri pateikia metodus, prieinamus `change`, `up` ir `down` metodams.

Dėl metodų, prieinamų naudojant objektą, kurį grąžina `create_table`, žiūrėkite [`ActiveRecord::ConnectionAdapters::TableDefinition`][].

O dėl objekto, kurį grąžina `change_table`, žiūrėkite [`ActiveRecord::ConnectionAdapters::Table`][].

### Naudodami `change` metodą

`change` metodas yra pagrindinis būdas rašyti migracijas. Jis veikia daugumai atvejų, kai Active Record žino, kaip automatiškai atšaukti migracijos veiksmus. Žemiau pateikiami kai kurie veiksmai, kuriuos `change` palaiko:

* [`add_check_constraint`][]
* [`add_column`][]
* [`add_foreign_key`][]
* [`add_index`][]
* [`add_reference`][]
* [`add_timestamps`][]
* [`change_column_comment`][] (būtina nurodyti `:from` ir `:to` parinktis)
* [`change_column_default`][] (būtina nurodyti `:from` ir `:to` parinktis)
* [`change_column_null`][]
* [`change_table_comment`][] (būtina nurodyti `:from` ir `:to` parinktis)
* [`create_join_table`][]
* [`create_table`][]
* `disable_extension`
* [`drop_join_table`][]
* [`drop_table`][] (būtina pateikti bloką)
* `enable_extension`
* [`remove_check_constraint`][] (būtina pateikti apribojimo išraišką)
* [`remove_column`][] (būtina pateikti tipą)
* [`remove_columns`][] (būtina pateikti `:type` parinktį)
* [`remove_foreign_key`][] (būtina pateikti antrą lentelę)
* [`remove_index`][]
* [`remove_reference`][]
* [`remove_timestamps`][]
* [`rename_column`][]
* [`rename_index`][]
* [`rename_table`][]

[`change_table`][] taip pat yra atvirkštinis, jei bloke yra tik atvirkštiniai veiksmai, tokie kaip aukščiau išvardyti.

`remove_column` yra atvirkštinis, jei trečiu argumentu nurodote stulpelio tipą. Taip pat pateikite pradinius stulpelio parametrus, kitaip Rails negalės tiksliai atkurti stulpelio atšaukiant:

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

Jei ketinate naudoti kitus metodus, turėtumėte naudoti `reversible` arba rašyti `up` ir `down` metodus, o ne naudoti `change` metodą.
### Naudojant `reversible`

Sudėtingi migracijos gali reikalauti veiksmų, kurių Active Record nežino, kaip atšaukti. Galite naudoti [`reversible`][] norėdami nurodyti, ką daryti vykdant migraciją ir ką dar daryti atšaukiant ją. Pavyzdžiui:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # sukurti platintojų peržiūros
        execute <<-SQL
          CREATE VIEW distributors_view AS
          SELECT id, zipcode
          FROM distributors;
        SQL
      end
      direction.down do
        execute <<-SQL
          DROP VIEW distributors_view;
        SQL
      end
    end

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
end
```

Naudodami `reversible` užtikrinsite, kad instrukcijos būtų vykdomos tinkama tvarka. Jei ankstesnė migracija yra atšaukiama, `down` blokas bus vykdomas po `home_page_url` stulpelio pašalinimo ir `email_address` stulpelio pervadinimo ir tiesiog prieš `distributors` lentelės pašalinimą.


### Naudodami `up`/`down` metodus

Taip pat galite naudoti senąjį migracijos stilių, naudodami `up` ir `down` metodus vietoj `change` metodo.

`up` metodas turėtų aprašyti schemos transformaciją, kurią norite atlikti, o migracijos `down` metodas turėtų atšaukti transformacijas, atliktas `up` metodu. Kitais žodžiais tariant, duomenų bazės schema neturėtų pasikeisti, jei atliekate `up` ir po to `down`.

Pavyzdžiui, jei `up` metode sukuriate lentelę, `down` metode ją turėtumėte pašalinti. Geriausia atlikti transformacijas tiksliai atvirkštine tvarka, kuria jos buvo atlikta `up` metode. Pavyzdys `reversible` sekcijoje yra ekvivalentus:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # sukurti platintojų peržiūros
    execute <<-SQL
      CREATE VIEW distributors_view AS
      SELECT id, zipcode
      FROM distributors;
    SQL

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end

  def down
    rename_column :users, :email_address, :email
    remove_column :users, :home_page_url

    execute <<-SQL
      DROP VIEW distributors_view;
    SQL

    drop_table :distributors
  end
end
```

### Klaidos išmetimas, kad būtų užkirstas kelias atšaukimui

Kartais jūsų migracija atliks kažką, kas yra tiesiog neišvengiama; pavyzdžiui, ji gali sunaikinti tam tikrus duomenis.

Tokiu atveju savo `down` bloke galite iškelti `ActiveRecord::IrreversibleMigration` klaidą.

Jei kas nors bandys atšaukti jūsų migraciją, bus rodomas klaidos pranešimas, kad tai negalima padaryti.

### Ankstesnių migracijų atšaukimas

Galite naudoti Active Record galimybę atšaukti migracijas naudodami [`revert`][] metodą:

```ruby
require_relative "20121212123456_example_migration"

class FixupExampleMigration < ActiveRecord::Migration[7.1]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

`revert` metodas taip pat priima instrukcijų bloką, kurį reikia atšaukti. Tai gali būti naudinga atšaukti pasirinktas ankstesnių migracijų dalis.

Pavyzdžiui, įsivaizduokite, kad `ExampleMigration` yra įvykdyta ir vėliau nuspręsta, kad platintojų peržiūra nebėra reikalinga.

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.1]
  def change
    revert do
      # kopijuojamas kodas iš ExampleMigration
      reversible do |direction|
        direction.up do
          # sukurti platintojų peržiūros
          execute <<-SQL
            CREATE VIEW distributors_view AS
            SELECT id, zipcode
            FROM distributors;
          SQL
        end
        direction.down do
          execute <<-SQL
            DROP VIEW distributors_view;
          SQL
        end
      end

      # Likusi migracija buvo gerai
    end
  end
end
```

Ta pati migracija galėjo būti parašyta ir be `revert`, bet tai reikėjo keleto papildomų žingsnių:

1. Apversti `create_table` ir `reversible` tvarką.
2. Pakeisti `create_table` su `drop_table`.
3. Galiausiai pakeisti `up` su `down` ir atvirkščiai.

Visa tai padaro `revert`.


Migracijų vykdymas
------------------

Rails teikia rinkinį komandų, skirtų vykdyti tam tikras migracijų grupes.

Labiausiai paprasta migracijų susijusią Rails komandą, kurią naudosite, turbūt bus `bin/rails db:migrate`. Jos paprasčiausia forma ji tiesiog vykdo `change` arba `up` metodą visoms migracijoms, kurios dar nebuvo įvykdytos. Jei tokios migracijos nėra, ji išeina. Jos vykdymas vyksta pagal migracijos datos tvarką.

Atkreipkite dėmesį, kad vykdant `db:migrate` komandą taip pat įvykdoma `db:schema:dump` komanda, kuri atnaujina jūsų `db/schema.rb` failą, kad jis atitiktų jūsų duomenų bazės struktūrą.

Jei nurodote tikslinę versiją, Active Record vykdys reikiamas migracijas (change, up, down) iki pasiektos nurodytos versijos. Versija yra migracijos failo numeris. Pavyzdžiui, norint atlikti migraciją iki 20080906120000 versijos, vykdykite:
```bash
$ bin/rails db:migrate VERSION=20080906120000
```

Jei versija 20080906120000 yra didesnė nei dabartinė versija (t.y., ji migruoja aukštyn), tai bus paleistas `change` (arba `up`) metodas visose migracijose iki ir įskaitant 20080906120000, ir nebus vykdomos vėlesnės migracijos. Jei migracija vyksta žemyn, tai bus paleistas `down` metodas visose migracijose iki, bet neįskaitant 20080906120000.

### Atšaukimas

Daugelis užduočių yra atšaukti paskutinę migraciją. Pavyzdžiui, jei jūs padarėte klaidą ir norite ją ištaisyti. Vietoje to, kad surastumėte versijos numerį, susijusį su ankstesne migracija, galite paleisti:

```bash
$ bin/rails db:rollback
```

Tai atšauks paskutinę migraciją, arba grąžins `change` metodą arba paleis `down` metodą. Jei reikia atšaukti kelias migracijas, galite nurodyti `STEP` parametrą:

```bash
$ bin/rails db:rollback STEP=3
```

Bus atšauktos paskutinės 3 migracijos.

`db:migrate:redo` komanda yra trumpinys, skirtas atšaukti migraciją ir tada vėl ją migracijuoti. Kaip ir `db:rollback` komanda, galite naudoti `STEP` parametrą, jei norite grįžti daugiau nei vieną versiją atgal, pavyzdžiui:

```bash
$ bin/rails db:migrate:redo STEP=3
```

Šios Rails komandos nieko nedaro, ko negalėtumėte padaryti su `db:migrate`. Jos yra patogumui, nes jums nereikia išreiškiai nurodyti migracijos versijos, į kurią migracijuoti.

### Duomenų bazės sąranka

`bin/rails db:setup` komanda sukurs duomenų bazę, įkels schemą ir ją inicijuos pradiniais duomenimis.

### Duomenų bazės atstatymas

`bin/rails db:reset` komanda ištrins duomenų bazę ir ją vėl sukonfigūruos. Tai yra funkcionaliai ekvivalentu `bin/rails db:drop db:setup`.

PASTABA: Tai nėra tas pats kaip paleisti visas migracijas. Tai naudos tik dabartinio `db/schema.rb` arba `db/structure.sql` failo turinį. Jei migracija negali būti atšaukta, `bin/rails db:reset` jums gali nepadėti. Norėdami sužinoti daugiau apie schemos iškėlimą, žr. [Schema Dumping and You][] skyrių.

[Schema Dumping and You]: #schema-dumping-and-you

### Paleidimas konkrečioms migracijoms

Jei norite paleisti konkrečią migraciją aukštyn ar žemyn, `db:migrate:up` ir `db:migrate:down` komandos tai padarys. Tiesiog nurodykite atitinkamą versiją ir atitinkama migracija bus paleista jos `change`, `up` ar `down` metodas, pvz.:

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

Paleidus šią komandą, bus vykdomas `change` metodas (arba `up` metodas) migracijai su versija "20080906120000".

Pirma, ši komanda patikrins, ar migracija egzistuoja ir ar ji jau buvo atlikta, ir jei taip, nieko nebus padaryta.

Jei nurodyta versija neegzistuoja, Rails išmes išimtį.

```bash
$ bin/rails db:migrate VERSION=zomg
rails aborted!
ActiveRecord::UnknownMigrationVersionError:

No migration with version number zomg.
```

### Migracijų vykdymas skirtingose aplinkose

Pagal numatytuosius nustatymus paleidus `bin/rails db:migrate`, jis bus vykdomas `development` aplinkoje.

Norėdami paleisti migracijas kitose aplinkose, galite nurodyti ją naudodami `RAILS_ENV` aplinkos kintamąjį paleidžiant komandą. Pavyzdžiui, norėdami paleisti migracijas `test` aplinkoje, galite paleisti:

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### Migracijų vykdymo rezultatų keitimas

Pagal numatytuosius nustatymus migracijos tiksliai nurodo, ką jos daro ir kiek laiko tai užtrunka. Lentelės kūrimo ir indekso pridėjimo migracija gali sukurti tokius rezultatus

```
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

Migracijose yra kelios funkcijos, leidžiančios jums tai kontroliuoti:

| Metodas                    | Paskirtis
| -------------------------- | -------
| [`suppress_messages`][]    | Priima bloką kaip argumentą ir slopina bet kokį bloko generuojamą išvestį.
| [`say`][]                  | Priima žinutės argumentą ir ją išveda kaip yra. Antrasis boolean argumentas gali būti perduotas, norint nurodyti, ar įtraukti įtraukimą ar ne.
| [`say_with_time`][]        | Išveda tekstą kartu su tuo, kiek laiko užtruko jo blokas. Jei blokas grąžina sveikąjį skaičių, jis priima, kad tai yra paveiktų eilučių skaičius.

Pavyzdžiui, pažiūrėkite į šią migraciją:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    suppress_messages do
      create_table :products do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say "Created a table"

    suppress_messages { add_index :products, :name }
    say "and an index!", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end
```

Tai sukurs šią išvestį:

```
==  CreateProducts: migracija =================================================
-- Sukurta lentelė
   -> ir indeksas!
-- Laukiama kurį laiką
   -> 10.0013s
   -> 250 eilučių
==  CreateProducts: migruota (10.0054s) =======================================
```

Jei norite, kad Active Record nieko neišvestų, paleidus `bin/rails db:migrate
VERBOSE=false` visi išvesties pranešimai bus slopinami.


Keičiant esamas migracijas
----------------------------

Kartais rašant migraciją gali būti padaryta klaida. Jei jau paleidote migraciją,
tuomet negalite tiesiog redaguoti migracijos ir paleisti migracijos dar kartą:
Rails mano, kad migracija jau buvo paleista ir todėl nieko neveiks, kai paleisite
`bin/rails db:migrate`. Turite atšaukti migraciją (pavyzdžiui, naudodami `bin/rails db:rollback`),
redaguoti migraciją ir tada paleisti `bin/rails db:migrate`, kad būtų paleista
ištaisyta versija.

Bendrai, redaguoti esamas migracijas nėra gera idėja. Jūs sau ir savo bendradarbiams
sukursite papildomą darbą ir sukelsite didelius galvos skausmus,
jei esama migracijos versija jau buvo paleista ant produkcinės mašinos.

Vietoj to, turėtumėte parašyti naują migraciją, kuri atliks reikiamus pakeitimus.
Redaguoti naujai sugeneruotą migraciją, kuri dar nebuvo
įtraukta į šaltinio kontrolę (arba, apskritai, kuri dar nebuvo platinama
už jūsų vystymo mašinos ribų), yra santykinai nekenksminga.

`revert` metodas gali būti naudingas, rašant naują migraciją, kad atšauktumėte ankstesnes
migracijas visiškai arba iš dalies (žr. [Ankstesnių migracijų atšaukimas][] aukščiau).

[Ankstesnių migracijų atšaukimas]: #ankstesnių-migracijų-atšaukimas

Schema eksportavimas ir jūs
----------------------

### Kam skirti schemos failai?

Migracijos, nors ir galingos, nėra patikimas šaltinis jūsų
duomenų bazės schemai. **Jūsų duomenų bazė lieka tiesos šaltiniu.**

Pagal numatytuosius nustatymus, Rails generuoja `db/schema.rb`, kuris bando užfiksuoti
jūsų duomenų bazės schemos dabartinę būseną.

Paprastai yra greičiau ir mažiau klaidų padaryti naujos
jūsų programos duomenų bazės kopijos sukūrimą įkeliant schemos failą per `bin/rails db:schema:load`,
nei paleisti visą migracijų istoriją iš naujo.
[Seno migracijos][] gali nepavykti tinkamai taikyti, jei šios migracijos naudoja kintančias
išorines priklausomybes arba remiasi programos kodu, kuris vystosi atskirai nuo
jūsų migracijų.

Schemos failai taip pat naudingi, jei norite greitai peržiūrėti, kokias atributus turi
Active Record objektas. Ši informacija nėra modelio kode ir dažnai išsklaidyta
per kelias migracijas, tačiau informacija gražiai
suvokiama schemos faile.

[Seno migracijos]: #seno-migracijos

### Schemos eksportavimo tipai

Rails sugeneruojamo schemos eksportavimo formatą valdo
[`config.active_record.schema_format`][] nustatymas, apibrėžtas
`config/application.rb`. Pagal numatytuosius nustatymus formatas yra `:ruby`, arba galima
nustatyti `:sql`.

#### Naudojant numatytąjį `:ruby` schemą

Kai pasirenkamas `:ruby`, tada schema saugoma `db/schema.rb`. Jei pažvelgsite
į šį failą, pamatysite, kad jis labai panašus į vieną labai didelę migraciją:

```ruby
ActiveRecord::Schema[7.1].define(version: 2008_09_06_171750) do
  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "part_number"
  end
end
```

Daugeliu atvejų tai tiksliai tai ir yra. Šis failas yra sukurtas tikrinant
duomenų bazę ir jos struktūrą išreiškiant `create_table`, `add_index` ir t.t.

#### Naudojant `:sql` schemos eksportavimą

Tačiau `db/schema.rb` negali išreikšti visko, ką jūsų duomenų bazė gali palaikyti,
tokių kaip trigeriai, sekos, saugomosios procedūros ir t.t.

Nors migracijos gali naudoti `execute` norint sukurti duomenų bazės konstrukcijas, kurios nėra
palaikomos Ruby migracijų DSL, šios konstrukcijos gali nebūti
galima atkurti schemos eksportuotoju.

Jei naudojate tokius funkcionalumus, turėtumėte nustatyti schemos formatą kaip `:sql`,
kad gautumėte tikslų schemos failą, kuris yra naudingas naujų duomenų bazės
kopijų kūrimui.

Kai schemos formatas nustatytas kaip `:sql`, duomenų bazės struktūra bus eksportuojama
naudojant duomenų bazės specifinį įrankį į `db/structure.sql`. Pavyzdžiui, PostgreSQL,
naudojamas `pg_dump` įrankis. MySQL ir MariaDB šis failas
sudarys `SHOW CREATE TABLE` išvestį įvairioms lentelėms.

Schemos įkėlimui iš `db/structure.sql` paleiskite `bin/rails db:schema:load`.
Šio failo įkėlimas atliekamas vykdant jame esančius SQL teiginius. Pagal
apibrėžimą tai sukurs tobulą duomenų bazės struktūros kopiją.


### Schemos eksportavimas ir šaltinio kontrolė
Kadangi schemos failai dažnai naudojami kuriant naujas duomenų bazes, labai rekomenduojama įtraukti savo schemos failą į šaltinio kontrolę.

Sujungimo konfliktai gali atsirasti jūsų schemos faile, kai dvi šakos modifikuoja schemą. Norėdami išspręsti šiuos konfliktus, paleiskite `bin/rails db:migrate`, kad būtų sugeneruotas schemos failas.

INFORMACIJA: Naujai sukurti „Rails“ programos jau turės migracijų aplanką įtrauktą į „git“ medį, todėl jums tereikia įsitikinti, kad pridedate ir įtraukiate visas naujas migracijas.

Aktyvusis įrašas ir nuorodinė vientisumas
---------------------------------------

Aktyvusis įrašo būdas tvirtina, kad intelektas priklauso jūsų modeliams, o ne duomenų bazei. Todėl nerekomenduojama naudoti funkcijų, tokių kaip trigeriai ar apribojimai, kurie grąžina šiek tiek intelekto atgal į duomenų bazę.

Tikrinimai, tokie kaip `validates :foreign_key, uniqueness: true`, yra vienas būdas, kuriuo modeliai gali užtikrinti duomenų vientisumą. Asociacijų `:dependent` parinktis leidžia modeliams automatiškai naikinti vaikinius objektus, kai yra naikinamas tėvinis objektas. Kaip ir bet kas, kas veikia taikomojo lygio, šie negali garantuoti nuorodinio vientisumo, todėl kai kurie žmonės juos papildo [svetimų raktų apribojimais][] duomenų bazėje.

Nors Aktyvusis įrašas nepateikia visų įrankių, skirtų tiesiogiai dirbti su tokiomis funkcijomis, `execute` metodas gali būti naudojamas vykdyti bet kokį SQL.

[svetimų raktų apribojimais]: #svetimi-raktai

Migracijos ir pradiniai duomenys
--------------------------------

Pagrindinis „Rails“ migracijų funkcijos tikslas yra išduoti komandas, kurios modifikuoja schemą naudojant nuoseklų procesą. Migracijos taip pat gali būti naudojamos pridėti ar modifikuoti duomenis. Tai yra naudinga esančioje duomenų bazėje, kuri negali būti sunaikinta ir sukuriama iš naujo, pvz., produkcijos duomenų bazėje.

```ruby
class AddInitialProducts < ActiveRecord::Migration[7.1]
  def up
    5.times do |i|
      Product.create(name: "Product ##{i}", description: "A product.")
    end
  end

  def down
    Product.delete_all
  end
end
```

Norėdami pridėti pradinius duomenis po duomenų bazės sukūrimo, „Rails“ turi įdiegtą „seeds“ funkciją, kuri pagreitina procesą. Tai ypač naudinga dažnai perkraunant duomenų bazę vystymo ir testavimo aplinkose arba nustatant pradinius duomenis produkcijai.

Norėdami pradėti naudoti šią funkciją, atidarykite `db/seeds.rb` ir pridėkite keletą „Ruby“ kodo, tada paleiskite `bin/rails db:seed`.

PASTABA: Čia esantis kodas turėtų būti idempotentinis, kad jį būtų galima vykdyti bet kuriuo metu kiekvienoje aplinkoje.

```ruby
["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
  MovieGenre.find_or_create_by!(name: genre_name)
end
```

Tai paprastai yra daug švaresnis būdas nustatyti tuščios programos duomenų bazę.

Senos migracijos
---------------

`db/schema.rb` arba `db/structure.sql` yra jūsų duomenų bazės dabartinio būklės momentinė nuotrauka ir yra autoritetingas šaltinis, skirtas atkurti tą duomenų bazę. Tai leidžia ištrinti ar supjaustyti senus migracijų failus.

Kai ištrinate migracijos failus `db/migrate/` kataloge, bet kuri aplinka, kurioje buvo paleistas `bin/rails db:migrate`, kai tie failai dar egzistavo, turės nuorodą į migracijos laiko žymeklį, specifinį jiems, esantį vidinėje „Rails“ duomenų bazės lentelėje, vadinamoje `schema_migrations`. Ši lentelė naudojama sekti, ar migracijos buvo įvykdytos konkrečioje aplinkoje.

Jei paleisite komandą `bin/rails db:migrate:status`, kuri rodo kiekvienos migracijos būseną (įjungta arba išjungta), turėtumėte matyti `********** NO FILE **********` rodomą šalia bet kurio ištrinto migracijos failo, kuris buvo kartą įvykdytas konkrečioje aplinkoje, bet daugiau negali būti rastas `db/migrate/` kataloge.

### Migracijos iš modulių

Tačiau yra vienas dalykas, susijęs su [Moduliais][]. „Rake“ užduotys, skirtos įdiegti migracijas iš modulių, yra idempotentinės, tai reiškia, kad jos turės tą patį rezultatą, nepriklausomai nuo to, kiek kartų jas iškviečiate. Migracijos, esančios pagrindinėje programoje dėl ankstesnio įdiegimo, yra praleidžiamos, o trūkstamos kopijuojamos su nauju laiko žymekliu priekyje. Jei ištrinsite senas modulio migracijas ir vėl paleisite įdiegimo užduotį, gausite naujus failus su naujais laiko žymekliais, ir `db:migrate` bandys juos paleisti dar kartą.

Todėl paprastai norite išlaikyti migracijas, kilusias iš modulių. Jos turi specialų komentarą, panašų į šį:

```ruby
# Ši migracija yra iš blorgh (iš pradžių 20210621082949)
```

 [Moduliai]: moduliai.html
[`add_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`add_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[`remove_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_column
[`create_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_table
[`create_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_join_table
[`change_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table
[`change_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column
[`change_column_default`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_default
[`change_column_null`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_null
[`execute`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-execute
[`ActiveRecord::ConnectionAdapters::SchemaStatements`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
[`ActiveRecord::ConnectionAdapters::TableDefinition`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html
[`ActiveRecord::ConnectionAdapters::Table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html
[`add_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_check_constraint
[`add_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key
[`add_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_timestamps
[`change_column_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_comment
[`change_table_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table_comment
[`drop_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_join_table
[`drop_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_table
[`remove_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_check_constraint
[`remove_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key
[`remove_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_index
[`remove_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_reference
[`remove_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_timestamps
[`rename_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_column
[`remove_columns`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_columns
[`rename_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_index
[`rename_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_table
[`reversible`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-reversible
[`revert`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-revert
[`say`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say
[`say_with_time`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say_with_time
[`suppress_messages`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-suppress_messages
[`config.active_record.schema_format`]: configuring.html#config-active-record-schema-format
