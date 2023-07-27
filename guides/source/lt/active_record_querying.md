**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cc70f06da31561d3461720649cc42371
Aktyvusis įrašo užklausos sąsaja
=============================

Šiame vadove aprašomos skirtingos būdai gauti duomenis iš duomenų bazės naudojant Aktyvųjį įrašą.

Po šio vadovo perskaitymo jūs žinosite:

* Kaip rasti įrašus naudojant įvairius metodus ir sąlygas.
* Kaip nurodyti rikiavimą, gautų atributų, grupavimą ir kitas rastos įrašų savybes.
* Kaip naudoti ankstyvą užkrovimą, kad sumažintumėte duomenų gavimui reikalingų duomenų bazės užklausų skaičių.
* Kaip naudoti dinaminius paieškos metodus.
* Kaip naudoti metodų grandinėlę, kad kartu naudotumėte kelis Aktyvaus įrašo metodus.
* Kaip patikrinti, ar yra tam tikri įrašai.
* Kaip atlikti įvairius skaičiavimus su Aktyvaus įrašo modeliais.
* Kaip vykdyti EXPLAIN užklausas susijusias su ryšiais.

--------------------------------------------------------------------------------

Kas yra Aktyvaus įrašo užklausos sąsaja?
------------------------------------------

Jeigu įpratę naudoti grynąjį SQL užklausoms duomenų bazėje gauti, tuomet dažnai pastebėsite, kad „Rails“ turi geriau veikiančius būdus atlikti tas pačias operacijas. Aktyvusis įrašas jūsų apsaugo nuo būtinybės naudoti SQL daugumoje atvejų.

Aktyvusis įrašas atliks užklausas duomenų bazėje už jus ir yra suderinamas su dauguma duomenų bazės sistemų, įskaitant MySQL, MariaDB, PostgreSQL ir SQLite. Nepriklausomai nuo tos duomenų bazės sistemos, kurią naudojate, Aktyvaus įrašo metodo formatas visada bus tas pats.

Kodo pavyzdžiai šiame vadove bus susiję su vienu ar keliais šių modelių:

PATARIMAS: Visi toliau pateikti modeliai naudoja `id` kaip pirminį raktą, nebent kitaip nurodyta.

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

```ruby
class Book < ApplicationRecord
  belongs_to :supplier
  belongs_to :author
  has_many :reviews
  has_and_belongs_to_many :orders, join_table: 'books_orders'

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
  scope :out_of_print_and_expensive, -> { out_of_print.where('price > 500') }
  scope :costs_more_than, ->(amount) { where('price > ?', amount) }
end
```

```ruby
class Customer < ApplicationRecord
  has_many :orders
  has_many :reviews
end
```

```ruby
class Order < ApplicationRecord
  belongs_to :customer
  has_and_belongs_to_many :books, join_table: 'books_orders'

  enum :status, [:shipped, :being_packed, :complete, :cancelled]

  scope :created_before, ->(time) { where(created_at: ...time) }
end
```

```ruby
class Review < ApplicationRecord
  belongs_to :customer
  belongs_to :book

  enum :state, [:not_reviewed, :published, :hidden]
end
```

```ruby
class Supplier < ApplicationRecord
  has_many :books
  has_many :authors, through: :books
end
```

![Visų knygyno modelių diagrama](images/active_record_querying/bookstore_models.png)

Objektų gavimas iš duomenų bazės
------------------------------------

Norint gauti objektus iš duomenų bazės, Aktyvusis įrašas teikia kelis paieškos metodus. Kiekvienas paieškos metodas leidžia perduoti argumentus, kad atliktų tam tikras užklausas duomenų bazėje, nenaudojant grynojo SQL.

Šie metodai yra:

* [`annotate`][]
* [`find`][]
* [`create_with`][]
* [`distinct`][]
* [`eager_load`][]
* [`extending`][]
* [`extract_associated`][]
* [`from`][]
* [`group`][]
* [`having`][]
* [`includes`][]
* [`joins`][]
* [`left_outer_joins`][]
* [`limit`][]
* [`lock`][]
* [`none`][]
* [`offset`][]
* [`optimizer_hints`][]
* [`order`][]
* [`preload`][]
* [`readonly`][]
* [`references`][]
* [`reorder`][]
* [`reselect`][]
* [`regroup`][]
* [`reverse_order`][]
* [`select`][]
* [`where`][]

Paieškos metodai, kurie grąžina kolekciją, pvz., `where` ir `group`, grąžina [`ActiveRecord::Relation`][]. Metodai, kurie randa vieną įrašą, pvz., `find` ir `first`, grąžina vieną modelio objektą.

Pagrindinė `Model.find(options)` operacija gali būti apibendrinta taip:

* Konvertuoti pateiktus parametrus į ekvivalentinę SQL užklausą.
* Paleisti SQL užklausą ir gauti atitinkamus rezultatus iš duomenų bazės.
* Sukurti atitinkamų modelio objektų ekvivalentus kiekvienam gautam eilučių rezultatui.
* Paleisti `after_find` ir tada `after_initialize` atgalinius kvietimus, jei tokie yra.


### Vieno objekto gavimas

Aktyvusis įrašas teikia keletą skirtingų būdų gauti vieną objektą.

#### `find`

Naudodami [`find`][] metodą, galite gauti objektą, kuris atitinka nurodytą _pirminį raktą_ ir atitinka bet kokius pateiktus parametrus. Pavyzdžiui:
```irb
# Rasti klientą su pirminiu raktu (id) 10.
irb> customer = Customer.find(10)
=> #<Customer id: 10, first_name: "Ryan">
```

SQL ekvivalentas:

```sql
SELECT * FROM customers WHERE (customers.id = 10) LIMIT 1
```

`find` metodas išmes `ActiveRecord::RecordNotFound` išimtį, jei nėra atitinkančio įrašo.

Taip pat galite naudoti šį metodą ieškant kelių objektų. Iškvieskite `find` metodą ir perduokite masyvą su pirminiais raktas. Grąžinimas bus masyvas, kuriame bus visi atitinkantys įrašai pagal pateiktus pirminius raktus. Pavyzdžiui:

```irb
# Rasti klientus su pirminiais raktas 1 ir 10.
irb> customers = Customer.find([1, 10]) # ARBA Customer.find(1, 10)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 10, first_name: "Ryan">]
```

SQL ekvivalentas:

```sql
SELECT * FROM customers WHERE (customers.id IN (1,10))
```

ĮSPĖJIMAS: `find` metodas išmes `ActiveRecord::RecordNotFound` išimtį, jei nėra atitinkančio įrašo **visiems** pateiktiems pirminiams raktams.

#### `take`

[`take`][] metodas gauna įrašą be jokio numatomo rikiavimo. Pavyzdžiui:

```irb
irb> customer = Customer.take
=> #<Customer id: 1, first_name: "Lifo">
```

SQL ekvivalentas:

```sql
SELECT * FROM customers LIMIT 1
```

`take` metodas grąžina `nil`, jei nerandamas įrašas ir nebus išmesta jokia išimtis.

Galite perduoti skaitinį argumentą `take` metode, kad grąžintumėte iki tokių rezultatų skaičiaus. Pavyzdžiui:

```irb
irb> customers = Customer.take(2)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 220, first_name: "Sara">]
```

SQL ekvivalentas:

```sql
SELECT * FROM customers LIMIT 2
```

[`take!`][] metodas elgiasi taip pat kaip `take`, tik išmes `ActiveRecord::RecordNotFound` išimtį, jei nerandamas atitinkantis įrašas.

PATARIMAS: Gaunamas įrašas gali skirtis priklausomai nuo duomenų bazės variklio.


#### `first`

[`first`][] metodas randa pirmą įrašą pagal pirminį raktą (numatytąjį). Pavyzdžiui:

```irb
irb> customer = Customer.first
=> #<Customer id: 1, first_name: "Lifo">
```

SQL ekvivalentas:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 1
```

`first` metodas grąžina `nil`, jei nerandamas atitinkantis įrašas ir nebus išmesta jokia išimtis.

Jei jūsų [numatytasis apribojimas](active_record_querying.html#applying-a-default-scope) turi rikiavimo metodą, `first` grąžins pirmą įrašą pagal šį rikiavimą.

Galite perduoti skaitinį argumentą `first` metode, kad grąžintumėte iki tokių rezultatų skaičiaus. Pavyzdžiui:

```irb
irb> customers = Customer.first(3)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 2, first_name: "Fifo">, #<Customer id: 3, first_name: "Filo">]
```

SQL ekvivalentas:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 3
```

Kolekcijoje, kuri yra surikiuota naudojant `order`, `first` grąžins pirmą įrašą, surikiuotą pagal nurodytą atributą `order`.

```irb
irb> customer = Customer.order(:first_name).first
=> #<Customer id: 2, first_name: "Fifo">
```

SQL ekvivalentas:

```sql
SELECT * FROM customers ORDER BY customers.first_name ASC LIMIT 1
```

[`first!`][] metodas elgiasi taip pat kaip `first`, tik išmes `ActiveRecord::RecordNotFound` išimtį, jei nerandamas atitinkantis įrašas.


#### `last`

[`last`][] metodas randa paskutinį įrašą pagal pirminį raktą (numatytąjį). Pavyzdžiui:

```irb
irb> customer = Customer.last
=> #<Customer id: 221, first_name: "Russel">
```

SQL ekvivalentas:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 1
```

`last` metodas grąžina `nil`, jei nerandamas atitinkantis įrašas ir nebus išmesta jokia išimtis.

Jei jūsų [numatytasis apribojimas](active_record_querying.html#applying-a-default-scope) turi rikiavimo metodą, `last` grąžins paskutinį įrašą pagal šį rikiavimą.
Galite perduoti skaitinį argumentą į `last` metodą, kad gautumėte iki tokių rezultatų. Pavyzdžiui

```irb
irb> customers = Customer.last(3)
=> [#<Customer id: 219, first_name: "James">, #<Customer id: 220, first_name: "Sara">, #<Customer id: 221, first_name: "Russel">]
```

SQL ekvivalentas yra:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 3
```

Kolekcijoje, kuri yra surūšiuota naudojant `order`, `last` grąžins paskutinį įrašą, surūšiuotą pagal nurodytą atributą `order`.

```irb
irb> customer = Customer.order(:first_name).last
=> #<Customer id: 220, first_name: "Sara">
```

SQL ekvivalentas yra:

```sql
SELECT * FROM customers ORDER BY customers.first_name DESC LIMIT 1
```

[`last!`][] metodas elgiasi taip pat kaip `last`, išskyrus tai, kad jei nėra atitinkančio įrašo, jis iškelia `ActiveRecord::RecordNotFound` išimtį.


#### `find_by`

[`find_by`][] metodas randa pirmą atitinkantį sąlygas įrašą. Pavyzdžiui:

```irb
irb> Customer.find_by first_name: 'Lifo'
=> #<Customer id: 1, first_name: "Lifo">

irb> Customer.find_by first_name: 'Jon'
=> nil
```

Tai yra ekvivalentu:

```ruby
Customer.where(first_name: 'Lifo').take
```

SQL ekvivalentas yra:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Lifo') LIMIT 1
```

Atkreipkite dėmesį, kad šiame SQL nėra `ORDER BY`. Jei jūsų `find_by` sąlygos gali atitikti kelis įrašus, turėtumėte [taikyti rūšiavimą](#ordering), kad garantuotumėte nustatytą rezultatą.

[`find_by!`][] metodas elgiasi taip pat kaip `find_by`, išskyrus tai, kad jei nėra atitinkančio įrašo, jis iškelia `ActiveRecord::RecordNotFound` išimtį. Pavyzdžiui:

```irb
irb> Customer.find_by! first_name: 'does not exist'
ActiveRecord::RecordNotFound
```

Tai yra ekvivalentu:

```ruby
Customer.where(first_name: 'does not exist').take!
```


### Kelis objektus gaunant partijomis

Dažnai turime iteruoti per didelį įrašų rinkinį, pvz., kai siunčiame naujienlaiškį dideliam klientų skaičiui arba kai eksportuojame duomenis.

Tai gali atrodyti paprasta:

```ruby
# Tai gali sunaikinti per daug atminties, jei lentelė yra didelė.
Customer.all.each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Tačiau šis požiūris tampa vis labiau nepraktiškas, kai lentelės dydis didėja, nes `Customer.all.each` nurodo Active Record'ui gauti _visą lentelę_ vienu metu, sukurti modelio objektą kiekvienam įrašui ir tada laikyti visą modelių objektų masyvą atmintyje. Iš tikrųjų, jei turime didelį įrašų skaičių, visas kolekcijas gali viršyti prieinamos atminties kiekį.

Rails teikia dvi metodus, kurie sprendžia šią problemą, padalindami įrašus į atminties draugiškas partijas apdorojimui. Pirmasis metodas, `find_each`, gauna partiją įrašų ir tada atskirai perduoda _kiekvieną_ įrašą į bloką kaip modelį. Antrasis metodas, `find_in_batches`, gauna partiją įrašų ir tada visą partiją perduoda į bloką kaip modelių masyvą.

PATARIMAS: `find_each` ir `find_in_batches` metodai skirti naudoti didelio skaičiaus įrašų partijų apdorojimui, kurie negalėtų visi vienu metu tilpti atmintyje. Jei jums tiesiog reikia iteruoti per tūkstančius įrašų, paprasti find metodai yra pageidaujamas pasirinkimas.

#### `find_each`

[`find_each`][] metodas gauna įrašus partijomis ir tada atskirai perduoda kiekvieną į bloką. Šiame pavyzdyje `find_each` gauna klientus partijomis po 1000 ir juos atskirai perduoda į bloką:

```ruby
Customer.find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Šis procesas kartojamas, gaunant daugiau partijų, kaip reikia, kol visi įrašai bus apdoroti.

`find_each` veikia su modelio klasėmis, kaip matyti aukščiau, taip pat su sąryšiais:

```ruby
Customer.where(weekly_subscriber: true).find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

kol jie neturi rūšiavimo, nes metodas turi priversti tvarką
viduje, kad galėtų iteruoti.

Jei tvarka yra pateikta gavėjui, elgesys priklauso nuo vėliavos
[`config.active_record.error_on_ignored_order`][]. Jei ji yra true, iškeliamas `ArgumentError`,
kitu atveju tvarka yra ignoruojama ir išduodamas įspėjimas, kas yra
numatytasis. Tai gali būti pakeista naudojant parinktį `:error_on_ignore`, paaiškinta
žemiau.
##### Galimybės naudojant `find_each`

**`:batch_size`**

`batch_size` parametras leidžia nurodyti įrašų skaičių, kurie bus gaunami kiekviename grupės etape ir perduodami atskirai į bloką. Pavyzdžiui, norint gauti įrašus grupėmis po 5000:

```ruby
Customer.find_each(batch_size: 5000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:start`**

Pagal nutylėjimą, įrašai gaunami didėjimo tvarka pagal pagrindinį raktą. `start` parametras leidžia nurodyti pradinį ID, kai mažiausias ID nėra tas, kurio jums reikia. Tai būtų naudinga, pavyzdžiui, jei norėtumėte tęsti nutrauktą grupės proceso vykdymą, jei išsaugojote paskutinį apdoroto ID kaip kontrolinį tašką.

Pavyzdžiui, norint siųsti naujienlaiškius tik klientams, kurių pirminis raktas prasideda nuo 2000:

```ruby
Customer.find_each(start: 2000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:finish`**

Panašiai kaip `:start` parametras, `:finish` leidžia nurodyti paskutinį ID sekos, kai didžiausias ID nėra tas, kurio jums reikia. Tai būtų naudinga, pavyzdžiui, jei norėtumėte vykdyti grupės procesą naudodami įrašų po `:start` ir `:finish`.

Pavyzdžiui, norint siųsti naujienlaiškius tik klientams, kurių pirminis raktas prasideda nuo 2000 ir baigiasi 10000:

```ruby
Customer.find_each(start: 2000, finish: 10000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Kitas pavyzdys būtų, jei norėtumėte, kad kelios darbininkų grupės tvarkytų tą patį apdorojimo eilę. Kiekvienas darbininkas galėtų tvarkyti 10000 įrašų, nustatant tinkamus `:start` ir `:finish` parametrus kiekvienam darbininkui.

**`:error_on_ignore`**

Perrašo programos konfigūraciją, nurodydamas, ar turėtų būti iškelta klaida, kai užklausoje yra užsakymas.

**`:order`**

Nurodo pagrindinio rakto tvarką (gali būti `:asc` arba `:desc`). Pagal nutylėjimą nustatyta `:asc`.

```ruby
Customer.find_each(order: :desc) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

#### `find_in_batches`

[`find_in_batches`][] metodas panašus į `find_each`, nes abu gauna įrašų grupes. Skirtumas yra tas, kad `find_in_batches` perduoda _grupes_ į bloką kaip modelių masyvą, o ne atskirai. Pavyzdžiui, šis pavyzdys perduos blokui iki 1000 klientų masyvą kiekvieną kartą, o paskutinėje grupėje bus likę klientai:

```ruby
# Perduoti add_customers metodei po 1000 klientų masyvą.
Customer.find_in_batches do |customers|
  export.add_customers(customers)
end
```

`find_in_batches` veikia su modelių klasėmis, kaip matyti aukščiau, taip pat su sąryšiais:

```ruby
# Perduoti add_customers metodei po 1000 neseniai aktyvių klientų masyvą.
Customer.recently_active.find_in_batches do |customers|
  export.add_customers(customers)
end
```

kol jie neturi tvarkymo, nes metodas turi priverstinai nustatyti tvarką viduje, kad galėtų iteruoti.

##### Galimybės naudojant `find_in_batches`

`find_in_batches` metodas priima tas pačias galimybes kaip ir `find_each`:

**`:batch_size`**

Kaip ir `find_each` atveju, `batch_size` nustato, kiek įrašų bus gaunama kiekvienoje grupėje. Pavyzdžiui, norint gauti grupėmis po 2500 įrašus, galima nurodyti:

```ruby
Customer.find_in_batches(batch_size: 2500) do |customers|
  export.add_customers(customers)
end
```

**`:start`**

`start` parametras leidžia nurodyti pradinį ID, nuo kurio bus pasirinkti įrašai. Kaip jau minėta, pagal nutylėjimą įrašai gaunami didėjimo tvarka pagal pagrindinį raktą. Pavyzdžiui, norint gauti klientus, pradedant nuo ID: 5000 grupėmis po 2500 įrašų, galima naudoti šį kodą:

```ruby
Customer.find_in_batches(batch_size: 2500, start: 5000) do |customers|
  export.add_customers(customers)
end
```

**`:finish`**

`finish` parametras leidžia nurodyti paskutinį pasirinktų įrašų ID. Žemiau pateiktas kodas rodo klientų gavimo grupėmis pavyzdį, iki kliento su ID: 7000:

```ruby
Customer.find_in_batches(finish: 7000) do |customers|
  export.add_customers(customers)
end
```

**`:error_on_ignore`**

`error_on_ignore` parametras perrašo programos konfigūraciją, nurodydamas, ar turėtų būti iškelta klaida, kai užklausoje yra konkretus užsakymas.

Sąlygos
----------

[`where`][] metodas leidžia nurodyti sąlygas, ribojančias grąžinamus įrašus, atitinkančius `WHERE` dalį SQL užklausoje. Sąlygos gali būti nurodytos kaip eilutė, masyvas arba hieša.
### Grynųjų eilučių sąlygos

Jei norite pridėti sąlygas prie savo paieškos, galite tiesiog nurodyti jas ten, panašiai kaip `Book.where("title = 'Introduction to Algorithms'")`. Tai ras visus knygas, kurių `title` lauko reikšmė yra 'Introduction to Algorithms'.

ĮSPĖJIMAS: Savo sąlygas sudarydami kaip grynas eilutes, galite tapti pažeidžiami SQL injekcijos atakoms. Pavyzdžiui, `Book.where("title LIKE '%#{params[:title]}%'")` nėra saugu. Norėdami sužinoti pageidaujamą būdą tvarkyti sąlygas naudojant masyvą, žr. kitą skyrių.

### Masyvo sąlygos

Ką daryti, jei tas pavadinimas gali kisti, pavyzdžiui, kaip argumentas iš kur nors? Paieška tada turėtų atrodyti taip:

```ruby
Book.where("title = ?", params[:title])
```

Active Record pirmąjį argumentą priims kaip sąlygų eilutę, o bet kokie papildomi argumentai pakeis klausimų ženklus `(?)` jame.

Jei norite nurodyti kelias sąlygas:

```ruby
Book.where("title = ? AND out_of_print = ?", params[:title], false)
```

Šiame pavyzdyje pirmasis klausimo ženklas bus pakeistas `params[:title]` reikšme, o antrasis bus pakeistas `false` SQL atitikmeniu, kuris priklauso nuo adapterio.

Šis kodas yra labai pageidautinas:

```ruby
Book.where("title = ?", params[:title])
```

prieš šį kodą:

```ruby
Book.where("title = #{params[:title]}")
```

dėl argumentų saugumo. Tiesiogiai į sąlygų eilutę įdedant kintamąjį, kintamasis bus perduotas duomenų bazei **kaip yra**. Tai reiškia, kad tai bus neištrintas kintamasis tiesiogiai iš naudotojo, kuris gali turėti kenksmingų ketinimų. Jei tai padarysite, visą savo duomenų bazę padedate į riziką, nes kai naudotojas sužinos, kad jis gali išnaudoti jūsų duomenų bazę, jis gali padaryti beveik bet ką su ja. Niekada niekada tiesiogiai įdėkite savo argumentus į sąlygų eilutę.

PATARIMAS: Norėdami gauti daugiau informacijos apie SQL injekcijos pavojus, žr. [Ruby on Rails saugumo vadovą](security.html#sql-injection).

#### Vietos ženklų sąlygos

Panašiai kaip `(?)` parametrų pakeitimo stilius, sąlygų eilutėje taip pat galite nurodyti raktus kartu su atitinkančiu raktų/reikšmių maišu:

```ruby
Book.where("created_at >= :start_date AND created_at <= :end_date",
  { start_date: params[:start_date], end_date: params[:end_date] })
```

Tai padeda aiškiau skaityti, jei turite daugybę kintamųjų sąlygų.

#### Sąlygos, naudojančios `LIKE`

Nors sąlygų argumentai automatiškai išvengia SQL injekcijos, SQL `LIKE` ženklai (t.y. `%` ir `_`) **nebūna** išvengiami. Tai gali sukelti netikėtą elgesį, jei nesaugota reikšmė naudojama kaip argumentas. Pavyzdžiui:

```ruby
Book.where("title LIKE ?", params[:title] + "%")
```

Pirmiau pateiktame kode siekiama atitikti pavadinimus, kurie prasideda naudotojo nurodytu simbolių eilute. Tačiau bet kokie `%` ar `_` simboliai `params[:title]` bus laikomi vietos ženklais, dėl ko gali būti gauti netikėti užklausos rezultatai. Kai kuriomis aplinkybėmis tai taip pat gali neleisti duomenų bazei naudoti numatytosios indekso, dėl ko užklausa gali būti daug lėtesnė.

Norint išvengti šių problemų, naudokite [`sanitize_sql_like`][] norėdami išvengti vietos ženklų simbolių pateikimo atitinkamoje argumento dalyje:

```ruby
Book.where("title LIKE ?",
  Book.sanitize_sql_like(params[:title]) + "%")
```


### Maišos sąlygos

Active Record taip pat leidžia perduoti maišos sąlygas, kurios gali padidinti sąlygų sintaksės skaitymą. Su maišos sąlygomis perduodate maišą su laukų raktų ir reikšmių, kaip norite juos kvalifikuoti:

PASTABA: Su maišos sąlygomis galima tik lygybės, intervalo ir poaibio tikrinimas.

#### Lygybės sąlygos

```ruby
Book.where(out_of_print: true)
```

Tai sugeneruos SQL tokiu būdu:

```sql
SELECT * FROM books WHERE (books.out_of_print = 1)
```

Lauko pavadinimas taip pat gali būti eilutė:

```ruby
Book.where('out_of_print' => true)
```

Atveju, kai yra priklausomybės nuosavybė, asociacijos raktas gali būti naudojamas nurodyti modelį, jei kaip reikšmė naudojamas Active Record objektas. Šis metodas veikia ir su polimorfinėmis sąsajomis.
```ruby
author = Author.first
Book.where(author: author)
Author.joins(:books).where(books: { author: author })
```

#### Intervalo sąlygos

```ruby
Book.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
```

Tai ras visus vakar sukurtus knygas, naudojant `BETWEEN` SQL sakinį:

```sql
SELECT * FROM books WHERE (books.created_at BETWEEN '2008-12-21 00:00:00' AND '2008-12-22 00:00:00')
```

Tai demonstruoja trumpesnį sintaksę pavyzdžiams [Masyvo sąlygos](#array-conditions)

Pradžios ir pabaigos intervalai yra palaikomi ir gali būti naudojami norint sukurti mažesnių/didžiųjų nei sąlygas.

```ruby
Book.where(created_at: (Time.now.midnight - 1.day)..)
```

Tai sugeneruotų SQL kaip:

```sql
SELECT * FROM books WHERE books.created_at >= '2008-12-21 00:00:00'
```

#### Poaibio sąlygos

Jei norite rasti įrašus naudodami `IN` išraišką, galite perduoti masyvą į sąlygų maišą:

```ruby
Customer.where(orders_count: [1, 3, 5])
```

Šis kodas sugeneruos SQL kaip šis:

```sql
SELECT * FROM customers WHERE (customers.orders_count IN (1,3,5))
```

### NE sąlygos

`NOT` SQL užklausas galima sukurti naudojant [`where.not`][]:

```ruby
Customer.where.not(orders_count: [1, 3, 5])
```

Kitais žodžiais tariant, šią užklausą galima sugeneruoti iškviečiant `where` be argumento, tada nedelsiant grandinėlės su `not` perduodant `where` sąlygas. Tai sugeneruos SQL kaip šis:

```sql
SELECT * FROM customers WHERE (customers.orders_count NOT IN (1,3,5))
```

Jei užklausa turi maišos sąlygą su ne-nilinėmis reikšmėmis nullable stulpelyje, įrašai, kuriuose nullable stulpelyje yra `nil` reikšmės, nebus grąžinami. Pavyzdžiui:

```ruby
Customer.create!(nullable_country: nil)
Customer.where.not(nullable_country: "UK")
=> []
# Bet
Customer.create!(nullable_country: "UK")
Customer.where.not(nullable_country: nil)
=> [#<Customer id: 2, nullable_country: "UK">]
```


### ARBA sąlygos

`ARBA` sąlygos tarp dviejų sąryšių gali būti sukurtos iškviečiant [`or`][] ant pirmojo sąryšio ir perduodant antrąjį kaip argumentą.

```ruby
Customer.where(last_name: 'Smith').or(Customer.where(orders_count: [1, 3, 5]))
```

```sql
SELECT * FROM customers WHERE (customers.last_name = 'Smith' OR customers.orders_count IN (1,3,5))
```


### IR sąlygos

`IR` sąlygos gali būti sukurtos grandinėlės `where` sąlygomis.

```ruby
Customer.where(last_name: 'Smith').where(orders_count: [1, 3, 5])
```

```sql
SELECT * FROM customers WHERE customers.last_name = 'Smith' AND customers.orders_count IN (1,3,5)
```

`IR` sąlygos sąryšių tarpusavio sankirtai gali būti sukurtos iškviečiant [`and`][] ant pirmojo sąryšio ir perduodant antrąjį kaip argumentą.

```ruby
Customer.where(id: [1, 2]).and(Customer.where(id: [2, 3]))
```

```sql
SELECT * FROM customers WHERE (customers.id IN (1, 2) AND customers.id IN (2, 3))
```


Rūšiavimas
--------

Norint gauti įrašus iš duomenų bazės tam tikra tvarka, galite naudoti [`order`][] metodą.

Pavyzdžiui, jei gaunate įrašų rinkinį ir norite juos surūšiuoti didėjimo tvarka pagal `created_at` lauką savo lentelėje:

```ruby
Book.order(:created_at)
# ARBA
Book.order("created_at")
```

Taip pat galite nurodyti `ASC` arba `DESC`:

```ruby
Book.order(created_at: :desc)
# ARBA
Book.order(created_at: :asc)
# ARBA
Book.order("created_at DESC")
# ARBA
Book.order("created_at ASC")
```

Arba rūšiuoti pagal kelis laukus:

```ruby
Book.order(title: :asc, created_at: :desc)
# ARBA
Book.order(:title, created_at: :desc)
# ARBA
Book.order("title ASC, created_at DESC")
# ARBA
Book.order("title ASC", "created_at DESC")
```

Jei norite iškviesti `order` kelis kartus, tolesni užsakymai bus pridėti prie pirmojo:

```irb
irb> Book.order("title ASC").order("created_at DESC")
SELECT * FROM books ORDER BY title ASC, created_at DESC
```

ĮSPĖJIMAS: Daugumoje duomenų bazės sistemų, renkant laukus su `distinct` iš rezultatų rinkinio naudojant metodus kaip `select`, `pluck` ir `ids`; `order` metodas iškels `ActiveRecord::StatementInvalid` išimtį, nebent `order` klauzulėje naudojami laukai būtų įtraukti į pasirinkimo sąrašą. Kitame skyriuje pateikta informacija apie laukų pasirinkimą iš rezultatų rinkinio.

Konkrečių laukų pasirinkimas
-------------------------

Pagal numatytuosius nustatymus, `Model.find` pasirenka visus laukus iš rezultatų rinkinio naudodamas `select *`.

Norėdami pasirinkti tik dalį laukų iš rezultatų rinkinio, galite nurodyti pasirinktinį poaibį per [`select`][] metodą.

Pavyzdžiui, norint pasirinkti tik `isbn` ir `out_of_print` stulpelius:
```ruby
Book.select(:isbn, :out_of_print)
# ARBA
Book.select("isbn, out_of_print")
```

Šio find užklausos naudojamas SQL užklausos kodas bus panašus į:

```sql
SELECT isbn, out_of_print FROM books
```

Būkite atsargūs, nes tai taip pat reiškia, kad inicializuojate modelio objektą tik su laukais, kuriuos pasirinkote. Jei bandysite pasiekti lauką, kuris nėra inicializuotame įraše, gausite:

```
ActiveModel::MissingAttributeError: missing attribute '<attribute>' for Book
```

Kur `<attribute>` yra jūsų užklausos laukas. `id` metodas nekelia `ActiveRecord::MissingAttributeError`, todėl būkite atsargūs dirbdami su asociacijomis, nes jiems reikalingas `id` metodas, kad veiktų tinkamai.

Jei norite gauti tik vieną įrašą su unikaliu reikšme tam tikrame lauke, galite naudoti [`distinct`][]:

```ruby
Customer.select(:last_name).distinct
```

Tai sugeneruos SQL užklausą panašią į:

```sql
SELECT DISTINCT last_name FROM customers
```

Taip pat galite pašalinti unikalumo apribojimą:

```ruby
# Grąžina unikalius pavarde
query = Customer.select(:last_name).distinct

# Grąžina visas pavardes, net jei yra dublikatų
query.distinct(false)
```

Limitas ir Offsetas
----------------

Norėdami pritaikyti `LIMIT` SQL užklausai, kurią vykdo `Model.find`, galite nurodyti `LIMIT` naudodami [`limit`][] ir [`offset`][] metodus santykyje.

Galite naudoti `limit` norėdami nurodyti, kiek įrašų bus gaunama, ir naudoti `offset` norėdami nurodyti, kiek įrašų bus praleista prieš pradedant grąžinti įrašus. Pavyzdžiui

```ruby
Customer.limit(5)
```

grąžins ne daugiau kaip 5 klientus ir, nenurodant offseto, grąžins pirmuosius 5 lentelėje. SQL, kurį vykdo, atrodo taip:

```sql
SELECT * FROM customers LIMIT 5
```

Pridėjus `offset` prie to

```ruby
Customer.limit(5).offset(30)
```

grąžins ne daugiau kaip 5 klientus, pradedant nuo 31-ojo. SQL atrodo taip:

```sql
SELECT * FROM customers LIMIT 5 OFFSET 30
```

Grupavimas
--------

Norėdami pritaikyti `GROUP BY` klauzulę SQL užklausai, kurią vykdo finder, galite naudoti [`group`][] metodą.

Pavyzdžiui, jei norite rasti kolekciją datų, kada buvo sukurta užsakymų:

```ruby
Order.select("created_at").group("created_at")
```

Tai suteiks jums vieną `Order` objektą kiekvienai datai, kurioje duomenų bazėje yra užsakymų.

SQL, kuris būtų vykdomas, būtų panašus į tai:

```sql
SELECT created_at
FROM orders
GROUP BY created_at
```

### Grupuotų elementų suma

Norėdami gauti visų grupuotų elementų sumą vienoje užklausoje, iškvieskite [`count`][] po grupavimo.

```irb
irb> Order.group(:status).count
=> {"being_packed"=>7, "shipped"=>12}
```

SQL, kuris būtų vykdomas, būtų panašus į tai:

```sql
SELECT COUNT (*) AS count_all, status AS status
FROM orders
GROUP BY status
```


### HAVING sąlygos

SQL naudoja `HAVING` klauzulę, kad nurodytų sąlygas `GROUP BY` laukams. Galite pridėti `HAVING` klauzulę prie SQL užklausos, kurią vykdo `Model.find`, pridedant [`having`][] metodą prie find.

Pavyzdžiui:

```ruby
Order.select("created_at, sum(total) as total_price").
  group("created_at").having("sum(total) > ?", 200)
```

SQL, kuris būtų vykdomas, būtų panašus į tai:

```sql
SELECT created_at as ordered_date, sum(total) as total_price
FROM orders
GROUP BY created_at
HAVING sum(total) > 200
```

Tai grąžina datos ir visos kainos kiekvienam užsakymo objektui, sugrupuotam pagal dieną, kai jie buvo užsakyti, ir kai bendra suma yra daugiau nei 200 dolerių.

Prieinama `total_price` kiekvienam užsakymo objektui, grąžintam taip:

```ruby
big_orders = Order.select("created_at, sum(total) as total_price")
                  .group("created_at")
                  .having("sum(total) > ?", 200)

big_orders[0].total_price
# Grąžina bendrą kainą pirmam Order objektui
```

Perrašant sąlygas
---------------------

### `unscope`

Galite nurodyti tam tikras sąlygas, kurias norite pašalinti, naudodami [`unscope`][] metodą. Pavyzdžiui:

```ruby
Book.where('id > 100').limit(20).order('id desc').unscope(:order)
```

SQL, kuris būtų vykdomas:
```sql
SELECT * FROM books WHERE id > 100 LIMIT 20

-- Original query without `unscope`
SELECT * FROM books WHERE id > 100 ORDER BY id desc LIMIT 20
```

Taip pat galite pašalinti tam tikras `where` sąlygas. Pavyzdžiui, tai pašalins `id` sąlygą iš where sąlygos:

```ruby
Book.where(id: 10, out_of_print: false).unscope(where: :id)
# SELECT books.* FROM books WHERE out_of_print = 0
```

Sąryšis, kuris naudojo `unscope`, paveiks bet kurį sąryšį, į kurį jis yra sujungtas:

```ruby
Book.order('id desc').merge(Book.unscope(:order))
# SELECT books.* FROM books
```


### `only`

Taip pat galite perrašyti sąlygas naudodami [`only`][] metodą. Pavyzdžiui:

```ruby
Book.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

SQL, kuris būtų vykdomas:

```sql
SELECT * FROM books WHERE id > 10 ORDER BY id DESC

-- Original query without `only`
SELECT * FROM books WHERE id > 10 ORDER BY id DESC LIMIT 20
```


### `reselect`

[`reselect`][] metodas perrašo esamą select sakinį. Pavyzdžiui:

```ruby
Book.select(:title, :isbn).reselect(:created_at)
```

SQL, kuris būtų vykdomas:

```sql
SELECT books.created_at FROM books
```

Palyginkite tai su atveju, kai nenaudojamas `reselect` sakinys:

```ruby
Book.select(:title, :isbn).select(:created_at)
```

vykdomas SQL būtų:

```sql
SELECT books.title, books.isbn, books.created_at FROM books
```

### `reorder`

[`reorder`][] metodas perrašo numatytąjį rikiavimo tvarką. Pavyzdžiui, jei klasės apibrėžime yra šis kodas:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

Ir vykdote šį kodą:

```ruby
Author.find(10).books
```

SQL, kuris būtų vykdomas:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published DESC
```

Galite naudoti `reorder` sąlygą, kad nurodytumėte kitą būdą rikiuoti knygas:

```ruby
Author.find(10).books.reorder('year_published ASC')
```

SQL, kuris būtų vykdomas:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published ASC
```

### `reverse_order`

[`reverse_order`][] metodas apverčia rikiavimo sąlygą, jei ji yra nurodyta.

```ruby
Book.where("author_id > 10").order(:year_published).reverse_order
```

SQL, kuris būtų vykdomas:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY year_published DESC
```

Jei užklausoje nenurodyta rikiavimo sąlyga, `reverse_order` rikiuoja pagal pagrindinį raktą atvirkštine tvarka.

```ruby
Book.where("author_id > 10").reverse_order
```

SQL, kuris būtų vykdomas:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY books.id DESC
```

`reverse_order` metodas nepriima **jokių** argumentų.

### `rewhere`

[`rewhere`][] metodas perrašo esamą, pavadintą `where` sąlygą. Pavyzdžiui:

```ruby
Book.where(out_of_print: true).rewhere(out_of_print: false)
```

SQL, kuris būtų vykdomas:

```sql
SELECT * FROM books WHERE out_of_print = 0
```

Jei nenaudojamas `rewhere` sakinys, where sąlygos yra sujungiamos su AND:

```ruby
Book.where(out_of_print: true).where(out_of_print: false)
```

vykdomas SQL būtų:

```sql
SELECT * FROM books WHERE out_of_print = 1 AND out_of_print = 0
```



### `regroup`

[`regroup`][] metodas perrašo esamą, pavadintą `group` sąlygą. Pavyzdžiui:

```ruby
Book.group(:author).regroup(:id)
```

SQL, kuris būtų vykdomas:

```sql
SELECT * FROM books GROUP BY id
```

Jei nenaudojamas `regroup` sakinys, grupavimo sąlygos yra sujungiamos kartu:

```ruby
Book.group(:author).group(:id)
```

vykdomas SQL būtų:

```sql
SELECT * FROM books GROUP BY author, id
```



Null sąryšis
-------------

[`none`][] metodas grąžina grandinėlę, kurioje nėra įrašų. Bet kokie vėlesni sąlygos, pririšti prie grąžinto sąryšio, toliau generuos tuščius sąryšius. Tai naudinga scenarijuose, kai jums reikia grandinės atsako į metodą arba ribos, kuris gali grąžinti nulį rezultatų.

```ruby
Book.none # grąžina tuščią sąryšį ir nevykdo užklausų.
```
```ruby
# Pateiktas žemiau esantis highlighted_reviews metodas visada turėtų grąžinti Relation.
Book.first.highlighted_reviews.average(:rating)
# => Grąžina knygos vidutinį įvertinimą

class Book
  # Grąžina apžvalgas, jei jų yra bent 5,
  # kitu atveju laikoma, kad tai yra knyga be apžvalgų
  def highlighted_reviews
    if reviews.count > 5
      reviews
    else
      Review.none # Dar nepasiekė minimalaus ribinio taško
    end
  end
end
```

Nepakeičiant turinio

Nesikeičiantys objektai
----------------

Active Record teikia [`readonly`][] metodą, skirtą sąryšiui, kuris aiškiai neleidžia keisti grąžintų objektų. Bet koks bandymas pakeisti nekeičiamą įrašą nesėks, iškeldamas `ActiveRecord::ReadOnlyRecord` išimtį.

```ruby
customer = Customer.readonly.first
customer.visits += 1
customer.save
```

Kadangi `customer` yra aiškiai nustatytas kaip nekeičiamas objektas, aukščiau esantis kodas iškels `ActiveRecord::ReadOnlyRecord` išimtį, kai bus iškviestas `customer.save` su atnaujinta _visits_ reikšme.

Įrašų užrakinimas atnaujinimui
--------------------------

Užrakinimas yra naudingas, norint užkirsti kelią lenktynių sąlygoms atnaujinant įrašus duomenų bazėje ir užtikrinti atominius atnaujinimus.

Active Record teikia du užrakinimo mechanizmus:

* Optimistinis užrakinimas
* Pesimistinis užrakinimas

### Optimistinis užrakinimas

Optimistinis užrakinimas leidžia keliems naudotojams gauti prieigą prie to paties įrašo redagavimui ir priima minimalų konfliktų su duomenimis skaičių. Tai daroma tikrinant, ar kitas procesas padarė pakeitimus įraše nuo jo atidarymo. Jei taip atsitiko ir atnaujinimas yra ignoruojamas, iškels `ActiveRecord::StaleObjectError` išimtį.

**Optimistinio užrakinimo stulpelis**

Norint naudoti optimistinį užrakinimą, lentelėje turi būti stulpelis, vadinamas `lock_version`, kurio tipas yra sveikasis skaičius. Kiekvieną kartą, kai įrašas yra atnaujinamas, Active Record padidina `lock_version` stulpelį. Jei atnaujinimo užklausa yra pateikta su mažesne reikšme `lock_version` lauke, nei dabar yra `lock_version` stulpelyje duomenų bazėje, atnaujinimo užklausa nepavyks su `ActiveRecord::StaleObjectError`.

Pavyzdžiui:

```ruby
c1 = Customer.find(1)
c2 = Customer.find(1)

c1.first_name = "Sandra"
c1.save

c2.first_name = "Michael"
c2.save # Iškels ActiveRecord::StaleObjectError
```

Tuomet jūs esate atsakingi už konflikto sprendimą, pagauti išimtį ir atitinkamai atšaukti, sujungti ar kitaip taikyti reikalingą verslo logiką, kad išspręstumėte konfliktą.

Šį elgesį galima išjungti nustatant `ActiveRecord::Base.lock_optimistically = false`.

Norint pakeisti `lock_version` stulpelio pavadinimą, `ActiveRecord::Base` teikia klasės atributą, vadinamą `locking_column`:

```ruby
class Customer < ApplicationRecord
  self.locking_column = :lock_customer_column
end
```

### Pesimistinis užrakinimas

Pesimistinis užrakinimas naudoja užrakinimo mechanizmą, kurį teikia pagrindinė duomenų bazė. Naudojant `lock` kuriant sąryšį, gaunamas išskirtinis užraktas pasirinktoms eilutėms. Sąryšiai, naudojantys `lock`, paprastai yra apgaubti transakcija, kad būtų išvengta užstrigimo sąlygų.

Pavyzdžiui:

```ruby
Book.transaction do
  book = Book.lock.first
  book.title = 'Algoritmai, antroji leidimas'
  book.save!
end
```

Aukščiau esantis seansas sukuria šį MySQL pagrindiniam procesui SQL:

```sql
SQL (0.2ms)   BEGIN
Book Load (0.3ms)   SELECT * FROM books LIMIT 1 FOR UPDATE
Book Update (0.4ms)   UPDATE books SET updated_at = '2009-02-07 18:05:56', title = 'Algoritmai, antroji leidimas' WHERE id = 1
SQL (0.8ms)   COMMIT
```

Taip pat galite perduoti neapdorotą SQL `lock` metodui, kad leistumėte skirtingiems užrakinimo tipams. Pavyzdžiui, MySQL turi išraišką, vadinamą `LOCK IN SHARE MODE`, kurioje galite užrakinti įrašą, bet vis tiek leisti kitiems užklausoms jį skaityti. Norėdami nurodyti šią išraišką, tiesiog perduokite ją kaip užrakimo parinktį:

```ruby
Book.transaction do
  book = Book.lock("LOCK IN SHARE MODE").find(1)
  book.increment!(:views)
end
```

PASTABA: Pastebėkite, kad jūsų duomenų bazė turi palaikyti neapdorotą SQL, kurį perduodate `lock` metodui.

Jei jau turite savo modelio egzempliorių, galite pradėti transakciją ir įgyti užraktą vienu metu naudodami šį kodą:

```ruby
book = Book.first
book.with_lock do
  # Šis blokas yra iškviestas transakcijoje,
  # knyga jau užrakinta.
  book.increment!(:views)
end
```

Lentelių sujungimas
--------------

Aktyvusis įrašas teikia dvi paieškos metodus, skirtus nurodyti `JOIN` sąlygas rezultatuose SQL: `joins` ir `left_outer_joins`.
Nors `joins` turėtų būti naudojamas `INNER JOIN` arba pasirinktinėms užklausoms,
`left_outer_joins` naudojamas užklausoms, naudojant `LEFT OUTER JOIN`.

### `joins`

Yra keletas būdų naudoti [`joins`][] metodą.

#### Naudojant SQL fragmentą

Galite tiesiog pateikti neapdorotą SQL, nurodydami `JOIN` sąlygą `joins`:

```ruby
Author.joins("INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE")
```

Tai rezultatą SQL:

```sql
SELECT authors.* FROM authors INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE
```

#### Naudojant asociacijų masyvą/hašą

Aktyvusis įrašas leidžia naudoti modelyje apibrėžtų [asociacijų](association_basics.html) pavadinimus kaip trumpinį, nurodant `JOIN` sąlygas šioms asociacijoms naudojant `joins` metodą.

Visi šie pavyzdžiai naudos `INNER JOIN` ir gaus norimus prisijungimo užklausas:

##### Prisijungimas prie vienos asociacijos

```ruby
Book.joins(:reviews)
```

Tai rezultatą:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
```

Arba, anglų kalba: "grąžinti knygos objektą visoms knygoms su atsiliepimais". Atkreipkite dėmesį, kad matysite pasikartojančias knygas, jei knyga turi daugiau nei vieną atsiliepimą. Jei norite unikalių knygų, galite naudoti `Book.joins(:reviews).distinct`.

#### Prisijungimas prie kelių asociacijų

```ruby
Book.joins(:author, :reviews)
```

Tai rezultatą:

```sql
SELECT books.* FROM books
  INNER JOIN authors ON authors.id = books.author_id
  INNER JOIN reviews ON reviews.book_id = books.id
```

Arba, anglų kalba: "grąžinti visas knygas su jų autoriais, kurie turi bent vieną atsiliepimą". Vėlgi atkreipkite dėmesį, kad knygos su keliais atsiliepimais pasirodys kelis kartus.

##### Prisijungimas prie įdėtų asociacijų (vieno lygio)

```ruby
Book.joins(reviews: :customer)
```

Tai rezultatą:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
```

Arba, anglų kalba: "grąžinti visas knygas, kurios turi atsiliepimą iš kliento".

##### Prisijungimas prie įdėtų asociacijų (kelio lygių)

```ruby
Author.joins(books: [{ reviews: { customer: :orders } }, :supplier])
```

Tai rezultatą:

```sql
SELECT * FROM authors
  INNER JOIN books ON books.author_id = authors.id
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
  INNER JOIN orders ON orders.customer_id = customers.id
INNER JOIN suppliers ON suppliers.id = books.supplier_id
```

Arba, anglų kalba: "grąžinti visus autorius, kurie turi knygas su atsiliepimais _ir_ kurios buvo užsakytos kliento, ir tie knygų tiekėjai".

#### Nurodant sąlygas prisijungtose lentelėse

Galite nurodyti sąlygas prisijungtose lentelėse naudodami įprastines [masyvo](#array-conditions) ir [teksto](#pure-string-conditions) sąlygas. [Hašo sąlygos](#hash-conditions) suteikia specialią sintaksę, skirtą nurodyti sąlygas prisijungtoms lentelėms:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where('orders.created_at' => time_range).distinct
```

Tai ras visus klientus, kurie turi užsakymus, kurie buvo sukurta vakar, naudojant `BETWEEN` SQL išraišką, kad palygintumėte `created_at`.

Alternatyvi ir švaresnė sintaksė yra įdėti hašo sąlygas:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where(orders: { created_at: time_range }).distinct
```

Norint sudėtingesnių sąlygų arba norint pernaudoti esamą pavadintą diapazoną, galima naudoti [`merge`][]. Pirmiausia pridėkime naują pavadintą diapazoną prie `Order` modelio:

```ruby
class Order < ApplicationRecord
  belongs_to :customer

  scope :created_in_time_range, ->(time_range) {
    where(created_at: time_range)
  }
end
```

Dabar galime naudoti `merge` sujungti `created_in_time_range` diapazoną:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).merge(Order.created_in_time_range(time_range)).distinct
```

Tai ras visus klientus, kurie turi užsakymus, kurie buvo sukurta vakar, vėl naudojant `BETWEEN` SQL išraišką.

### `left_outer_joins`

Jei norite pasirinkti rinkinį įrašų, nepriklausomai nuo to, ar jie turi susijusius
įrašus, galite naudoti [`left_outer_joins`][] metodą.

```ruby
Customer.left_outer_joins(:reviews).distinct.select('customers.*, COUNT(reviews.*) AS reviews_count').group('customers.id')
```

Tai rezultatą:

```sql
SELECT DISTINCT customers.*, COUNT(reviews.*) AS reviews_count FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id GROUP BY customers.id
```
Kas reiškia: "grąžinti visus klientus su jų apžvalgų skaičiumi, nepriklausomai nuo to, ar jie turi apžvalgų ar ne"

### `where.associated` ir `where.missing`

`associated` ir `missing` užklausų metodai leidžia jums pasirinkti rinkinį įrašų pagal asociacijos buvimą ar nebuvimą.

Norėdami naudoti `where.associated`:

```ruby
Customer.where.associated(:reviews)
```

Gamina:

```sql
SELECT customers.* FROM customers
INNER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NOT NULL
```

Kas reiškia "grąžinti visus klientus, kurie yra pateikę bent vieną apžvalgą".

Norėdami naudoti `where.missing`:

```ruby
Customer.where.missing(:reviews)
```

Gamina:

```sql
SELECT customers.* FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NULL
```

Kas reiškia "grąžinti visus klientus, kurie nėra pateikę jokių apžvalgų".


Greitojo užkrovimo asociacijos
--------------------------

Greitoji užkrova yra mechanizmas, skirtas įkelti susijusių įrašų objektų, grąžintų `Model.find`, naudojant kuo mažiau užklausų.

### N + 1 užklausų problema

Apsvarstykite šį kodą, kuris randa 10 knygų ir spausdina jų autorių pavardes:

```ruby
books = Book.limit(10)

books.each do |book|
  puts book.author.last_name
end
```

Šis kodas iš pirmo žvilgsnio atrodo gerai. Tačiau problema yra bendrame vykdomų užklausų skaičiu. Aukščiau pateiktas kodas vykdo 1 (10 knygų radimui) + 10 (po vieną kiekvienai knygai, kad būtų įkeltas autorius) = **11** užklausų iš viso.

#### N + 1 užklausų problemos sprendimas

Active Record leidžia iš anksto nurodyti visas asociacijas, kurios bus įkeltos.

Metodai yra:

* [`includes`][]
* [`preload`][]
* [`eager_load`][]

### `includes`

Naudojant `includes`, Active Record užtikrina, kad visos nurodytos asociacijos būtų įkeltos naudojant mažiausią galimą užklausų skaičių.

Peržiūrint aukščiau pateiktą atvejį, naudojant `includes` metodą, galėtume perrašyti `Book.limit(10)` taip, kad būtų įkelti autoriai:

```ruby
books = Book.includes(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

Aukščiau pateiktas kodas vykdys tik **2** užklausas, priešingai nei **11** užklausos iš pradinio atvejo:

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.book_id IN (1,2,3,4,5,6,7,8,9,10)
```

#### Greitoji užkrova kelioms asociacijoms

Active Record leidžia greitai įkelti bet kokį asociacijų skaičių vienu `Model.find` kvietimu, naudojant masyvą, hash'ą arba įdėtą hash'ą iš masyvo/hash'o su `includes` metodu.

##### Kelios asociacijos masyve

```ruby
Customer.includes(:orders, :reviews)
```

Tai įkelia visus klientus ir susijusius užsakymus bei apžvalgas kiekvienam.

##### Įdėti asociacijų hash'ą

```ruby
Customer.includes(orders: { books: [:supplier, :author] }).find(1)
```

Tai randa klientą su id 1 ir greitai įkelia visus susijusius užsakymus jam, visų užsakymų knygas bei autorių ir tiekėją kiekvienai knygai.

#### Sąlygų nurodymas greitai įkeliamoms asociacijoms

Nors Active Record leidžia nurodyti sąlygas greitai įkeliamoms asociacijoms, kaip ir `joins`, rekomenduojama naudoti [joins](#joining-tables) vietoj to.

Tačiau, jei jums tai reikia padaryti, galite naudoti `where` kaip įprasta.

```ruby
Author.includes(:books).where(books: { out_of_print: true })
```

Tai sukurtų užklausą, kurią sudarytų `LEFT OUTER JOIN`, o `joins` metodas sukurtų užklausą, naudodamas `INNER JOIN` funkciją.

```sql
  SELECT authors.id AS t0_r0, ... books.updated_at AS t1_r5 FROM authors LEFT OUTER JOIN books ON books.author_id = authors.id WHERE (books.out_of_print = 1)
```

Jei nėra `where` sąlygos, tai sukurtų įprastą dviejų užklausų rinkinį.

PASTABA: Naudojant `where` taip, tai veiks tik tada, kai perduodate jam Hash. SQL fragmentams reikia naudoti `references`, kad būtų priverstinai įjungtos jungiamosios lentelės:

```ruby
Author.includes(:books).where("books.out_of_print = true").references(:books)
```

Jei šioje `includes` užklausoje nebuvo knygų jokiems autoriams, visi autoriai vis tiek būtų įkelti. Naudojant `joins` (INNER JOIN), jungimo sąlygos **turi** atitikti, kitaip nebus grąžinti jokie įrašai.
PASTABA: Jei asociacija yra įkeliama kaip dalis sujungimo, bet kokie laukai iš pasirinktosios užklausos nebus pateikti įkeltuose modeliuose.
Tai yra dėl to, kad neaišku, ar jie turėtų atsirasti tėvų įraše, ar vaikui.

### `preload`

Naudojant `preload`, Active Record įkelia kiekvieną nurodytą asociaciją naudodamas po vieną užklausą kiekvienai asociacijai.

Grįžtant prie N + 1 užklausų problemos, galėtume perrašyti `Book.limit(10)` taip, kad būtų įkelti autoriai:


```ruby
books = Book.preload(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

Pirmiau pateiktas kodas vykdys tik **2** užklausas, priešingai nei **11** užklausos iš pradinio atvejo:

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.book_id IN (1,2,3,4,5,6,7,8,9,10)
```

PASTABA: `preload` metodas naudoja masyvą, hash'ą arba įdėtą hash'ą/masyvą taip pat, kaip ir `includes` metodas, kad būtų galima įkelti bet kokį asociacijų skaičių su vienu `Model.find` iškvietimu. Tačiau, skirtingai nuo `includes` metodo, neįmanoma nurodyti sąlygų įkeltoms asociacijoms.

### `eager_load`

Naudojant `eager_load`, Active Record įkelia visas nurodytas asociacijas naudodamas `LEFT OUTER JOIN`.

Grįžtant prie atvejo, kai N + 1 užklausų buvo naudojamas `eager_load` metodas, galėtume perrašyti `Book.limit(10)` taip, kad būtų įkelti autoriai:

```ruby
books = Book.eager_load(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

Pirmiau pateiktas kodas vykdys tik **2** užklausas, priešingai nei **11** užklausos iš pradinio atvejo:

```sql
SELECT DISTINCT books.id FROM books LEFT OUTER JOIN authors ON authors.book_id = books.id LIMIT 10
SELECT books.id AS t0_r0, books.last_name AS t0_r1, ...
  FROM books LEFT OUTER JOIN authors ON authors.book_id = books.id
  WHERE books.id IN (1,2,3,4,5,6,7,8,9,10)
```

PASTABA: `eager_load` metodas naudoja masyvą, hash'ą arba įdėtą hash'ą/masyvą taip pat, kaip ir `includes` metodas, kad būtų galima įkelti bet kokį asociacijų skaičių su vienu `Model.find` iškvietimu. Taip pat, kaip ir `includes` metodas, galite nurodyti sąlygas įkeltoms asociacijoms.

### `strict_loading`

Įkėlimas gali užkirsti kelią N + 1 užklausoms, bet vis tiek gali būti tingiai įkeliamos kai kurios asociacijos. Norėdami užtikrinti, kad nebūtų tingiai įkeliamos jokios asociacijos, galite įjungti [`strict_loading`][].

Įjungus griežtą įkėlimo režimą sąryšyje, jei įrašas bandys tingiai įkelti asociaciją, bus iškelta `ActiveRecord::StrictLoadingViolationError` klaida:

```ruby
user = User.strict_loading.first
user.comments.to_a # iškelia ActiveRecord::StrictLoadingViolationError klaidą
```


Apribojimai
------

Apribojimai leidžia nurodyti dažnai naudojamas užklausas, kurias galima naudoti kaip metodų iškvietimus asociacijų objektuose ar modeliuose. Su šiais apribojimais galite naudoti visus anksčiau aptartus metodus, tokius kaip `where`, `joins` ir `includes`. Visi apribojimų kūnai turėtų grąžinti `ActiveRecord::Relation` arba `nil`, kad būtų galima iškviesti tolesnius metodus (tokius kaip kiti apribojimai).

Norėdami apibrėžti paprastą apribojimą, naudojame [`scope`][] metodą klasėje, perduodami užklausą, kurią norime paleisti, kai šis apribojimas yra iškviestas:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

Šį `out_of_print` apribojimą galime iškviesti arba iškvietus jį klasėje:

```irb
irb> Book.out_of_print
=> #<ActiveRecord::Relation> # visi nebeprodukuojami knygos
```

Arba asociacijoje, sudarytoje iš `Book` objektų:

```irb
irb> author = Author.first
irb> author.books.out_of_print
=> #<ActiveRecord::Relation> # visi nebeprodukuojami knygos, parašyti `author`
```

Apribojimai taip pat gali būti grandinami su apribojimais:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :out_of_print_and_expensive, -> { out_of_print.where("price > 500") }
end
```


### Argumentų perdavimas

Jūsų apribojimas gali priimti argumentus:

```ruby
class Book < ApplicationRecord
  scope :costs_more_than, ->(amount) { where("price > ?", amount) }
end
```

Iškvieskite apribojimą, tarsi tai būtų klasės metodas:

```irb
irb> Book.costs_more_than(100.10)
```

Tačiau tai tik dubliuoja funkcionalumą, kurį jums suteiktų klasės metodas.
```ruby
class Book < ApplicationRecord
  def self.costs_more_than(amount)
    where("price > ?", amount)
  end
end
```

Šie metodai vis tiek bus pasiekiami asociacijos objektuose:

```irb
irb> author.books.costs_more_than(100.10)
```

### Naudojant sąlygas

Jūsų riba gali naudoti sąlygas:

```ruby
class Order < ApplicationRecord
  scope :created_before, ->(time) { where(created_at: ...time) if time.present? }
end
```

Kaip ir kiti pavyzdžiai, tai veiks panašiai kaip klasės metodas.

```ruby
class Order < ApplicationRecord
  def self.created_before(time)
    where(created_at: ...time) if time.present?
  end
end
```

Tačiau yra vienas svarbus išlyga: riba visada grąžins `ActiveRecord::Relation` objektą, net jei sąlyga įvertinama kaip `false`, o klasės metodas grąžins `nil`. Tai gali sukelti `NoMethodError`, kai grandinėjami klasės metodai su sąlygomis, jei bet kurios sąlygos grąžina `false`.

### Taikant numatytąją ribą

Jei norime, kad riba būtų taikoma visiems užklausoms modelyje, galime naudoti [`default_scope`][] metodą pačiame modelyje.

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

Kai vykdomos užklausos šiame modelyje, SQL užklausa dabar atrodys kaip

```sql
SELECT * FROM books WHERE (out_of_print = false)
```

Jei su numatytąja riba reikia atlikti sudėtingesnių veiksmų, galite ją apibrėžti kaip klasės metodą:

```ruby
class Book < ApplicationRecord
  def self.default_scope
    # Turėtų grąžinti ActiveRecord::Relation.
  end
end
```

PASTABA: `default_scope` taip pat taikomas kuriant / konstruojant įrašą, kai ribos argumentai pateikiami kaip `Hash`. Tai netaikoma atnaujinant įrašą. Pvz.:

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

```irb
irb> Book.new
=> #<Book id: nil, out_of_print: false>
irb> Book.unscoped.new
=> #<Book id: nil, out_of_print: nil>
```

Atkreipkite dėmesį, kad, jei pateikta `Array` formatu, `default_scope` užklausos argumentai negali būti konvertuojami į `Hash` numatytosios savybės priskyrimui. Pvz.:

```ruby
class Book < ApplicationRecord
  default_scope { where("out_of_print = ?", false) }
end
```

```irb
irb> Book.new
=> #<Book id: nil, out_of_print: nil>
```


### Ribų sujungimas

Kaip ir `where` sąlygos, ribos yra sujungiamos naudojant `AND` sąlygas.

```ruby
class Book < ApplicationRecord
  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }

  scope :recent, -> { where(year_published: 50.years.ago.year..) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
end
```

```irb
irb> Book.out_of_print.old
SELECT books.* FROM books WHERE books.out_of_print = 'true' AND books.year_published < 1969
```

Galime maišyti `scope` ir `where` sąlygas, ir galutinė SQL užklausa turės visas sąlygas sujungtas su `AND`.

```irb
irb> Book.in_print.where(price: ...100)
SELECT books.* FROM books WHERE books.out_of_print = 'false' AND books.price < 100
```

Jei norime, kad paskutinė `where` sąlyga laimėtų, tada galima naudoti [`merge`][].

```irb
irb> Book.in_print.merge(Book.out_of_print)
SELECT books.* FROM books WHERE books.out_of_print = true
```

Viena svarbi išlyga yra ta, kad `default_scope` bus pridėtas prie `scope` ir `where` sąlygų.

```ruby
class Book < ApplicationRecord
  default_scope { where(year_published: 50.years.ago.year..) }

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

```irb
irb> Book.all
SELECT books.* FROM books WHERE (year_published >= 1969)

irb> Book.in_print
SELECT books.* FROM books WHERE (year_published >= 1969) AND books.out_of_print = false

irb> Book.where('price > 50')
SELECT books.* FROM books WHERE (year_published >= 1969) AND (price > 50)
```

Kaip matote, `default_scope` yra sujungiamas tiek `scope`, tiek `where` sąlygose.


### Visų ribų pašalinimas

Jei norime pašalinti ribas dėl bet kokios priežasties, galime naudoti [`unscoped`][] metodą. Tai ypač naudinga, jei modelyje nurodyta `default_scope` ir jis neturėtų būti taikomas šiai konkretiai užklausai.

```ruby
Book.unscoped.load
```
Šis metodas pašalina visą ribojimą ir atlieka įprastą užklausą lentelėje.

```irb
irb> Book.unscoped.all
SELECT books.* FROM books

irb> Book.where(out_of_print: true).unscoped.all
SELECT books.* FROM books
```

`unscoped` taip pat gali priimti bloką:

```irb
irb> Book.unscoped { Book.out_of_print }
SELECT books.* FROM books WHERE books.out_of_print
```


Dinaminiai paieškos metodai
---------------

Kiekvienam laukui (taip pat žinomam kaip atributui), kurį apibrėžiate savo lentelėje,
Active Record suteikia paieškos metodo. Jei pavyzdžiui jūsų `Customer` modelyje yra laukas `first_name`,
iš Active Record gausite nemokamą `find_by_first_name` metodo egzempliorių.
Jei jūsų `Customer` modelyje taip pat yra `locked` laukas, taip pat gausite `find_by_locked` metodą.

Galite nurodyti šauktuką (`!`) dinaminių paieškos metodų pabaigoje,
kad jie iškeltų `ActiveRecord::RecordNotFound` klaidą, jei jie negrąžintų jokių įrašų, pvz., `Customer.find_by_first_name!("Ryan")`

Jei norite rasti tiek pagal `first_name`, tiek pagal `orders_count`, galite sujungti šiuos paieškos metodus, tiesiog įvedant "`and`" tarp laukų.
Pavyzdžiui, `Customer.find_by_first_name_and_orders_count("Ryan", 5)`.

Enumeracijos
-----

Enumeracija leidžia apibrėžti atributo reikšmių masyvą ir jas pavadinti vardais. Tikroji duomenų bazėje saugoma reikšmė yra sveikasis skaičius, kuris buvo priskirtas vienai iš reikšmių.

Deklaruojant enumeraciją:

* Sukuriamos ribos, kurios gali būti naudojamos, norint rasti visus objektus, turinčius ar neturinčius vienos iš enumeracijos reikšmių
* Sukuriamas egzemplioriaus metodas, kuris gali būti naudojamas nustatyti, ar objektas turi tam tikrą enumeracijos reikšmę
* Sukuriamas egzemplioriaus metodas, kuris gali būti naudojamas pakeisti objekto enumeracijos reikšmę

visoms galimoms enumeracijos reikšmėms.

Pavyzdžiui, turint šią [`enum`][] deklaraciją:

```ruby
class Order < ApplicationRecord
  enum :status, [:shipped, :being_packaged, :complete, :cancelled]
end
```

Šios [ribos](#scopes) yra automatiškai sukurtos ir gali būti naudojamos, norint rasti visus objektus su arba be tam tikros `status` reikšmės:

```irb
irb> Order.shipped
=> #<ActiveRecord::Relation> # visi užsakymai su statusu == :shipped
irb> Order.not_shipped
=> #<ActiveRecord::Relation> # visi užsakymai su statusu != :shipped
```

Šie egzemplioriaus metodai yra automatiškai sukurti ir patikrina, ar modelyje yra tam tikra reikšmė `status` enumeracijai:

```irb
irb> order = Order.shipped.first
irb> order.shipped?
=> true
irb> order.complete?
=> false
```

Šie egzemplioriaus metodai yra automatiškai sukurti ir pirmiausia atnaujina `status` reikšmę į nurodytą reikšmę
ir tada patikrina, ar statusas sėkmingai nustatytas į reikšmę:

```irb
irb> order = Order.first
irb> order.shipped!
UPDATE "orders" SET "status" = ?, "updated_at" = ? WHERE "orders"."id" = ?  [["status", 0], ["updated_at", "2019-01-24 07:13:08.524320"], ["id", 1]]
=> true
```

Visą dokumentaciją apie enumeracijas galite rasti [čia](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).


Metodų grandinėlės supratimas
-----------------------------

Active Record šablonas įgyvendina [Metodų grandinėlę](https://en.wikipedia.org/wiki/Method_chaining),
kuri leidžia mums naudoti kelis Active Record metodus kartu paprastu ir aiškiu būdu.

Galite grandinėti metodus sakinio viduje, kai ankstesnis iškvietimas grąžina
[`ActiveRecord::Relation`][], pvz., `all`, `where` ir `joins`. Metodai, kurie grąžina
vieną objektą (žr. [Vieno objekto gavimo skyrių](#retrieving-a-single-object))
turi būti sakinio pabaigoje.

Štai keli pavyzdžiai. Šis vadovas neapims visų galimybių, tik keletą pavyzdžių.
Kai iškviečiamas Active Record metodas, užklausa nedelsiant nėra generuojama ir nesiunčiama į duomenų bazę.
Užklausa siunčiama tik tada, kai iš tikrųjų reikia duomenų. Taigi kiekvienas žemiau pateiktas pavyzdys generuoja vieną užklausą.

### Filtruotų duomenų gavimas iš kelių lentelių

```ruby
Customer
  .select('customers.id, customers.last_name, reviews.body')
  .joins(:reviews)
  .where('reviews.created_at > ?', 1.week.ago)
```

Rezultatas turėtų būti panašus į šį:

```sql
SELECT customers.id, customers.last_name, reviews.body
FROM customers
INNER JOIN reviews
  ON reviews.customer_id = customers.id
WHERE (reviews.created_at > '2019-01-08')
```
### Duomenų gavimas iš kelių lentelių

```ruby
Book
  .select('books.id, books.title, authors.first_name')
  .joins(:author)
  .find_by(title: 'Abstraction and Specification in Program Development')
```

Tai turėtų sugeneruoti:

```sql
SELECT books.id, books.title, authors.first_name
FROM books
INNER JOIN authors
  ON authors.id = books.author_id
WHERE books.title = $1 [["title", "Abstraction and Specification in Program Development"]]
LIMIT 1
```

PASTABA: Jei užklausa atitinka kelis įrašus, `find_by` gaus tik pirmąjį ir ignoruos kitus (žr. `LIMIT 1` užklausos dalį aukščiau).

Rasti arba sukurti naują objektą
--------------------------

Daugeliu atvejų jums gali prireikti rasti įrašą arba jį sukurti, jei jis neegzistuoja. Tai galite padaryti naudodami `find_or_create_by` ir `find_or_create_by!` metodus.

### `find_or_create_by`

[`find_or_create_by`][] metodas patikrina, ar įrašas su nurodytais atributais egzistuoja. Jei ne, tada yra iškviečiamas `create`. Pažiūrėkime pavyzdį.

Tarkime, norite rasti klientą vardu "Andy", ir jei tokio nėra, sukurti jį. Tai galite padaryti vykdant:

```irb
irb> Customer.find_or_create_by(first_name: 'Andy')
=> #<Customer id: 5, first_name: "Andy", last_name: nil, title: nil, visits: 0, orders_count: nil, lock_version: 0, created_at: "2019-01-17 07:06:45", updated_at: "2019-01-17 07:06:45">
```

Šio metodo sugeneruotas SQL atrodo taip:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO customers (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by` grąžina arba jau egzistuojantį įrašą, arba naują įrašą. Mūsų atveju mes neturėjome jau kliento vardu Andy, todėl įrašas yra sukurtas ir grąžintas.

Naujas įrašas gali nebūti išsaugotas duomenų bazėje; tai priklauso nuo to, ar validacijos buvo sėkmingos ar ne (kaip ir `create`).

Tarkime, norime nustatyti 'locked' atributą į `false`, jei kuriamas naujas įrašas, bet nenorime jo įtraukti į užklausą. Taigi norime rasti klientą vardu "Andy", arba jei tokio kliento nėra, sukurti klientą vardu "Andy", kuris nėra užrakintas.

Tai galime pasiekti dviem būdais. Pirmasis būdas yra naudoti `create_with`:

```ruby
Customer.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

Antrasis būdas yra naudoti bloką:

```ruby
Customer.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

Blokas bus vykdomas tik jei klientas yra kuriamas. Antrą kartą paleidus šį kodą, blokas bus ignoruojamas.


### `find_or_create_by!`

Taip pat galite naudoti [`find_or_create_by!`][], kad būtų iškelta išimtis, jei naujas įrašas yra netinkamas. Validacijos šiame vadove nėra aptariamos, bet leiskite tuo metu laikinai pridėti

```ruby
validates :orders_count, presence: true
```

į savo `Customer` modelį. Jei bandysite sukurti naują `Customer` be `orders_count` perdavimo, įrašas bus netinkamas ir bus iškelta išimtis:

```irb
irb> Customer.find_or_create_by!(first_name: 'Andy')
ActiveRecord::RecordInvalid: Validation failed: Orders count can’t be blank
```


### `find_or_initialize_by`

[`find_or_initialize_by`][] metodas veiks taip pat kaip `find_or_create_by`, bet jis iškvies `new` vietoje `create`. Tai reiškia, kad naujas modelio objektas bus sukurtas atmintyje, bet nebus išsaugotas duomenų bazėje. Tęsiant `find_or_create_by` pavyzdį, dabar norime kliento vardu 'Nina':

```irb
irb> nina = Customer.find_or_initialize_by(first_name: 'Nina')
=> #<Customer id: nil, first_name: "Nina", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

irb> nina.persisted?
=> false

irb> nina.new_record?
=> true
```

Kadangi objektas dar nėra saugomas duomenų bazėje, sugeneruotas SQL atrodo taip:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Nina') LIMIT 1
```

Kai norite jį išsaugoti duomenų bazėje, tiesiog iškvieskite `save`:

```irb
irb> nina.save
=> true
```


Ieškoma naudojant SQL
--------------

Jei norite naudoti savo SQL užklausą, norėdami rasti įrašus lentelėje, galite naudoti [`find_by_sql`][]. `find_by_sql` metodas grąžins objektų masyvą, net jei pagrindinė užklausa grąžina tik vieną įrašą. Pavyzdžiui, galite paleisti šią užklausą:
```irb
irb> Customer.find_by_sql("SELECT * FROM customers INNER JOIN orders ON customers.id = orders.customer_id ORDER BY customers.created_at desc")
=> [#<Customer id: 1, first_name: "Lucas" ...>, #<Customer id: 2, first_name: "Jan" ...>, ...]
```

`find_by_sql` suteikia jums paprastą būdą atlikti pasirinktinius užklausimus į duomenų bazę ir gauti sukuriamus objektus.


### `select_all`

`find_by_sql` turi artimą giminaitį, vadinamą [`connection.select_all`][]. `select_all` gaus
objektus iš duomenų bazės naudojant pasirinktinį SQL, kaip ir `find_by_sql`, bet jų neinicializuos.
Šis metodas grąžins `ActiveRecord::Result` klasės objektą, o iškvietus `to_a` šiam
objektui, grąžins masyvą, kuriame kiekvienas maišas nurodo įrašą.

```irb
irb> Customer.connection.select_all("SELECT first_name, created_at FROM customers WHERE id = '1'").to_a
=> [{"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"}, {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}]
```


### `pluck`

[`pluck`][] gali būti naudojamas pasirinkti reikšmę(-es) iš vardintos(-ų) stulpelio(-ių) esančio(-ių) dabartinėje sąryšyje. Jis priima stulpelių pavadinimų sąrašą kaip argumentą ir grąžina reikšmių masyvą iš nurodytų stulpelių su atitinkamais duomenų tipais.

```irb
irb> Book.where(out_of_print: true).pluck(:id)
SELECT id FROM books WHERE out_of_print = true
=> [1, 2, 3]

irb> Order.distinct.pluck(:status)
SELECT DISTINCT status FROM orders
=> ["shipped", "being_packed", "cancelled"]

irb> Customer.pluck(:id, :first_name)
SELECT customers.id, customers.first_name FROM customers
=> [[1, "David"], [2, "Fran"], [3, "Jose"]]
```

`pluck` leidžia pakeisti kodą, panašų į:

```ruby
Customer.select(:id).map { |c| c.id }
# arba
Customer.select(:id).map(&:id)
# arba
Customer.select(:id, :first_name).map { |c| [c.id, c.first_name] }
```

su:

```ruby
Customer.pluck(:id)
# arba
Customer.pluck(:id, :first_name)
```

Skirtingai nei `select`, `pluck` tiesiogiai konvertuoja duomenų bazės rezultatą į Ruby `Array`,
nekonstruodamas `ActiveRecord` objektų. Tai gali reikšti geresnę našumą didelėms ar dažnai vykdomoms užklausoms. Tačiau, bet kokie modelio metodo perrašymai
nebus prieinami. Pavyzdžiui:

```ruby
class Customer < ApplicationRecord
  def name
    "Aš esu #{first_name}"
  end
end
```

```irb
irb> Customer.select(:first_name).map &:name
=> ["Aš esu David", "Aš esu Jeremy", "Aš esu Jose"]

irb> Customer.pluck(:first_name)
=> ["David", "Jeremy", "Jose"]
```

Jūs nesate apribotas užklausos laukais iš vienos lentelės, galite užklausti ir iš kelių lentelių.

```irb
irb> Order.joins(:customer, :books).pluck("orders.created_at, customers.email, books.title")
```

Be to, skirtingai nuo `select` ir kitų `Relation` apribojimų, `pluck` iš karto
sukelia užklausą ir todėl negali būti sujungtas su kitais apribojimais, nors gali veikti su
jau anksčiau sukonstruotais apribojimais:

```irb
irb> Customer.pluck(:first_name).limit(1)
NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

irb> Customer.limit(1).pluck(:first_name)
=> ["David"]
```

PASTABA: Taip pat turėtumėte žinoti, kad naudojant `pluck` bus aktyvuojamas eager loading, jei sąryšio objektas turi include reikšmes, net jei eager loading nėra būtinas užklausai. Pavyzdžiui:

```irb
irb> assoc = Customer.includes(:reviews)
irb> assoc.pluck(:id)
SELECT "customers"."id" FROM "customers" LEFT OUTER JOIN "reviews" ON "reviews"."id" = "customers"."review_id"
```

Vienas būdas tai išvengti yra `unscope` includes:

```irb
irb> assoc.unscope(:includes).pluck(:id)
```


### `pick`

[`pick`][] gali būti naudojamas pasirinkti reikšmę(-es) iš vardintos(-ų) stulpelio(-ių) esančio(-ių) dabartinėje sąryšyje. Jis priima stulpelių pavadinimų sąrašą kaip argumentą ir grąžina pirmąją eilutę su nurodytomis stulpelių reikšmėmis ir atitinkamais duomenų tipais.
`pick` yra trumpinys `relation.limit(1).pluck(*column_names).first`, kuris yra naudingas, kai jau turite sąryšį, kuris yra apribotas vienai eilutei.

`pick` leidžia pakeisti kodą, panašų į:

```ruby
Customer.where(id: 1).pluck(:id).first
```

su:

```ruby
Customer.where(id: 1).pick(:id)
```


### `ids`

[`ids`][] gali būti naudojamas ištraukti visus ID iš sąryšio naudojant lentelės pirminį raktą.

```irb
irb> Customer.ids
SELECT id FROM customers
```

```ruby
class Customer < ApplicationRecord
  self.primary_key = "customer_id"
end
```

```irb
irb> Customer.ids
SELECT customer_id FROM customers
```


Objektų egzistavimas
--------------------

Jei tiesiog norite patikrinti objekto egzistavimą, yra metodas, vadinamas [`exists?`][].
Šis metodas užklaus duomenų bazę naudodamas tą pačią užklausą kaip ir `find`, bet vietoje grąžinimo
objekto ar objektų kolekcijos, jis grąžins `true` arba `false`.
```ruby
Customer.exists?(1)
```

`exists?` metodas taip pat priima kelis reikšmes, bet jo esmė yra ta, kad jis grąžins `true`, jei bet kuri iš tų įrašų egzistuoja.

```ruby
Customer.exists?(id: [1, 2, 3])
# arba
Customer.exists?(first_name: ['Jane', 'Sergei'])
```

Netgi galima naudoti `exists?` be jokių argumentų modelyje arba ryšyje.

```ruby
Customer.where(first_name: 'Ryan').exists?
```

Pirmiau pateikta užklausa grąžins `true`, jei bent vienas klientas turi `first_name` reikšmę 'Ryan', ir `false` kitu atveju.

```ruby
Customer.exists?
```

Pirmiau pateikta užklausa grąžins `false`, jei `customers` lentelė yra tuščia, ir `true` kitu atveju.

Taip pat galite naudoti `any?` ir `many?` norėdami patikrinti, ar modelyje ar ryšyje yra egzistavimo. `many?` naudos SQL `count` norėdama nustatyti, ar elementas egzistuoja.

```ruby
# per modelį
Order.any?
# SELECT 1 FROM orders LIMIT 1
Order.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders LIMIT 2)

# per vardintą ribą
Order.shipped.any?
# SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 1
Order.shipped.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 2)

# per ryšį
Book.where(out_of_print: true).any?
Book.where(out_of_print: true).many?

# per asociaciją
Customer.first.orders.any?
Customer.first.orders.many?
```


Skaičiavimai
------------

Šiame skyriuje [`count`][] naudojamas kaip pavyzdinis metodas, tačiau aprašyti pasirinkimai taikomi visiems poskyriams.

Visi skaičiavimo metodai veikia tiesiogiai modelyje:

```irb
irb> Customer.count
SELECT COUNT(*) FROM customers
```

Arba ryšyje:

```irb
irb> Customer.where(first_name: 'Ryan').count
SELECT COUNT(*) FROM customers WHERE (first_name = 'Ryan')
```

Taip pat galite naudoti įvairius paieškos metodus ryšyje, norėdami atlikti sudėtingus skaičiavimus:

```irb
irb> Customer.includes("orders").where(first_name: 'Ryan', orders: { status: 'shipped' }).count
```

Kas vykdo:

```sql
SELECT COUNT(DISTINCT customers.id) FROM customers
  LEFT OUTER JOIN orders ON orders.customer_id = customers.id
  WHERE (customers.first_name = 'Ryan' AND orders.status = 0)
```

tai priklauso nuo to, ar Order turi `enum status: [ :shipped, :being_packed, :cancelled ]`.

### `count`

Jei norite pamatyti, kiek įrašų yra jūsų modelio lentelėje, galite iškviesti `Customer.count`, o tai grąžins skaičių.
Jei norite būti konkrečesni ir rasti visus klientus su pavadinimu, esančiu duomenų bazėje, galite naudoti `Customer.count(:title)`.

Dėl pasirinkimų žr. pagrindinį skyrių, [Skaičiavimai](#skaičiavimai).

### `average`

Jei norite pamatyti tam tikro skaičiaus vidurkį vienoje iš savo lentelių, galite iškviesti [`average`][] metodą klasėje, kuri susijusi su lentele. Šis metodo kvietimas atrodys kaip:

```ruby
Order.average("subtotal")
```

Tai grąžins skaičių (galbūt slankiojo kablelio skaičių, pvz., 3.14159265), kuris atitinka lauko vidurkio reikšmę.

Dėl pasirinkimų žr. pagrindinį skyrių, [Skaičiavimai](#skaičiavimai).


### `minimum`

Jei norite rasti mažiausią reikšmę savo lentelėje, galite iškviesti [`minimum`][] metodą klasėje, kuri susijusi su lentele. Šis metodo kvietimas atrodys kaip:

```ruby
Order.minimum("subtotal")
```

Dėl pasirinkimų žr. pagrindinį skyrių, [Skaičiavimai](#skaičiavimai).


### `maximum`

Jei norite rasti didžiausią reikšmę savo lentelėje, galite iškviesti [`maximum`][] metodą klasėje, kuri susijusi su lentele. Šis metodo kvietimas atrodys kaip:

```ruby
Order.maximum("subtotal")
```

Dėl pasirinkimų žr. pagrindinį skyrių, [Skaičiavimai](#skaičiavimai).


### `sum`

Jei norite rasti lauko sumą visiems įrašams savo lentelėje, galite iškviesti [`sum`][] metodą klasėje, kuri susijusi su lentele. Šis metodo kvietimas atrodys kaip:

```ruby
Order.sum("subtotal")
```

Dėl pasirinkimų žr. pagrindinį skyrių, [Skaičiavimai](#skaičiavimai).


Vykdomas EXPLAIN
----------------

Galite vykdyti [`explain`][] užklausą ryšyje. Kiekvienai duomenų bazei skiriasi EXPLAIN išvestis.

Pavyzdžiui, vykdant

```ruby
Customer.where(id: 1).joins(:orders).explain
```
gali duoti

```
PAIŠKINKITE PASIRINKTI `customers`.* IŠ `customers` VIDINIO PRISIJUNGIMO `orders` ANT `orders`.`customer_id` = `customers`.`id` KUR `customers`.`id` = 1
+----+-------------+------------+-------+---------------+
| id | select_type | table      | type  | possible_keys |
+----+-------------+------------+-------+---------------+
|  1 | SIMPLE      | customers  | const | PRIMARY       |
|  1 | SIMPLE      | orders     | ALL   | NULL          |
+----+-------------+------------+-------+---------------+
+---------+---------+-------+------+-------------+
| key     | key_len | ref   | rows | Extra       |
+---------+---------+-------+------+-------------+
| PRIMARY | 4       | const |    1 |             |
| NULL    | NULL    | NULL  |    1 | Using where |
+---------+---------+-------+------+-------------+

2 eilutės nustatytos (0,00 s)
```

naudojant MySQL ir MariaDB.

Aktyvus įrašas atlieka gana spausdinimą, kuris imituoja atitinkamos duomenų bazės kiautą. Taigi, vykdant tokią patį užklausą su PostgreSQL adapteriu, gali duoti

```
PAIŠKINKITE PASIRINKTI "customers".* IŠ "customers" VIDINIO PRISIJUNGIMO "orders" ANT "orders"."customer_id" = "customers"."id" KUR "customers"."id" = $1 [["id", 1]]
                                  UŽKLAUSOS PLANAS
------------------------------------------------------------------------------
 Vidinis ciklas  (cost=4.33..20.85 rows=4 width=164)
    ->  Indekso skenavimas naudojant customers_pkey lentelėje customers  (cost=0.15..8.17 rows=1 width=164)
          Indekso sąlyga: (id = '1'::bigint)
    ->  Bitų krūva skenavimas naudojant orders lentelėje  (cost=4.18..12.64 rows=4 width=8)
          Patikrinkite sąlygą: (customer_id = '1'::bigint)
          ->  Bitų indekso skenavimas naudojant index_orders_on_customer_id  (cost=0.00..4.18 rows=4 width=0)
                Indekso sąlyga: (customer_id = '1'::bigint)
(7 eilutės)
```

Greitas įkėlimas gali sukelti daugiau nei vieną užklausą po dangteliu, o kai kurios užklausos gali reikėti ankstesnių užklausų rezultatų. Dėl to `explain` iš tikrųjų vykdo užklausą ir tada prašo užklausos planų. Pavyzdžiui,

```ruby
Customer.where(id: 1).includes(:orders).explain
```

gali duoti tai MySQL ir MariaDB:

```
PAIŠKINKITE PASIRINKTI `customers`.* IŠ `customers`  KUR `customers`.`id` = 1
+----+-------------+-----------+-------+---------------+
| id | select_type | table     | type  | possible_keys |
+----+-------------+-----------+-------+---------------+
|  1 | SIMPLE      | customers | const | PRIMARY       |
+----+-------------+-----------+-------+---------------+
+---------+---------+-------+------+-------+
| key     | key_len | ref   | rows | Extra |
+---------+---------+-------+------+-------+
| PRIMARY | 4       | const |    1 |       |
+---------+---------+-------+------+-------+

1 eilutė nustatyta (0,00 s)

PAIŠKINKITE PASIRINKTI `orders`.* IŠ `orders`  KUR `orders`.`customer_id` IN (1)
+----+-------------+--------+------+---------------+
| id | select_type | table  | type | possible_keys |
+----+-------------+--------+------+---------------+
|  1 | SIMPLE      | orders | ALL  | NULL          |
+----+-------------+--------+------+---------------+
+------+---------+------+------+-------------+
| key  | key_len | ref  | rows | Extra       |
+------+---------+------+------+-------------+
| NULL | NULL    | NULL |    1 | Using where |
+------+---------+------+------+-------------+


1 eilutė nustatyta (0,00 s)
```

ir gali duoti tai PostgreSQL:

```
  Customer Load (0.3ms)  SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1  [["id", 1]]
  Order Load (0.3ms)  SELECT "orders".* FROM "orders" WHERE "orders"."customer_id" = $1  [["customer_id", 1]]
=> PAIŠKINKITE PASIRINKTI "customers".* IŠ "customers" WHERE "customers"."id" = $1 [["id", 1]]
                                    UŽKLAUSOS PLANAS
----------------------------------------------------------------------------------
 Indekso skenavimas naudojant customers_pkey lentelėje customers  (cost=0.15..8.17 rows=1 width=164)
   Indekso sąlyga: (id = '1'::bigint)
(2 eilutės)
```


### Paaiškinimo parinktys

Duomenų bazėms ir adapteriams, kurie juos palaiko (šiuo metu PostgreSQL ir MySQL), galima perduoti parinktis, kad būtų suteikta gilesnė analizė.

Naudojant PostgreSQL, šis kodas:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze, :verbose)
```

duoda:

```sql
PAIŠKINKITE (ANALYZE, VERBOSE) PASIRINKTI "shop_accounts".* IŠ "shop_accounts" VIDINIO PRISIJUNGIMO "customers" ANT "customers"."id" = "shop_accounts"."customer_id" KUR "shop_accounts"."id" = $1 [["id", 1]]
                                                                   UŽKLAUSOS PLANAS
------------------------------------------------------------------------------------------------------------------------------------------------
 Vidinis ciklas  (cost=0.30..16.37 rows=1 width=24) (actual time=0.003..0.004 rows=0 loops=1)
   Output: shop_accounts.id, shop_accounts.customer_id, shop_accounts.customer_carrier_id
   Inner Unique: true
   ->  Indekso skenavimas naudojant shop_accounts_pkey lentelėje shop_accounts  (cost=0.15..8.17 rows=1 width=24) (actual time=0.003..0.003 rows=0 loops=1)
         Output: shop_accounts.id, shop_accounts.customer_id, shop_accounts.customer_carrier_id
         Indekso sąlyga: (shop_accounts.id = '1'::bigint)
   ->  Indekso tik skenavimas naudojant customers_pkey lentelėje customers  (cost=0.15..8.17 rows=1 width=8) (never executed)
         Output: customers.id
         Indekso sąlyga: (customers.id = shop_accounts.customer_id)
         Heap Fetches: 0
 Planning Time: 0.063 ms
 Execution Time: 0.011 ms
(12 eilučių)
```

Naudojant MySQL arba MariaDB, šis kodas:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze)
```

duoda:

```sql
ANALYZE PASIRINKTI `shop_accounts`.* IŠ `shop_accounts` VIDINIO PRISIJUNGIMO `customers` ANT `customers`.`id` = `shop_accounts`.`customer_id` KUR `shop_accounts`.`id` = 1
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | r_rows | filtered | r_filtered | Extra                          |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
|  1 | SIMPLE      | NULL  | NULL | NULL          | NULL | NULL    | NULL | NULL | NULL   | NULL     | NULL       | no matching row in const table |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
1 eilutė nustatyta (0,00 s)
```
PASTABA: PAIŠKINKITE ir ANALIZUOKITE parinktys skiriasi priklausomai nuo MySQL ir MariaDB versijų.
([MySQL 5.7][MySQL5.7-explain], [MySQL 8.0][MySQL8-explain], [MariaDB][MariaDB-explain])


### EXPLAIN rezultatų interpretavimas

EXPLAIN rezultatų interpretavimas yra už šio vadovo ribų. Šie nurodymai gali būti naudingi:

* SQLite3: [EXPLAIN QUERY PLAN](https://www.sqlite.org/eqp.html)

* MySQL: [EXPLAIN rezultatų formatas](https://dev.mysql.com/doc/refman/en/explain-output.html)

* MariaDB: [EXPLAIN](https://mariadb.com/kb/en/mariadb/explain/)

* PostgreSQL: [Naudojant EXPLAIN](https://www.postgresql.org/docs/current/static/using-explain.html)
[`ActiveRecord::Relation`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html
[`annotate`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-annotate
[`create_with`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-create_with
[`distinct`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-distinct
[`eager_load`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-eager_load
[`extending`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-extending
[`extract_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-extract_associated
[`find`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find
[`from`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-from
[`group`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-group
[`having`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-having
[`includes`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-includes
[`joins`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-joins
[`left_outer_joins`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-left_outer_joins
[`limit`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-limit
[`lock`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-lock
[`none`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-none
[`offset`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-offset
[`optimizer_hints`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-optimizer_hints
[`order`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-order
[`preload`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-preload
[`readonly`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-readonly
[`references`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-references
[`reorder`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reorder
[`reselect`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reselect
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`reverse_order`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reverse_order
[`select`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-select
[`where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
[`take`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-take
[`take!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-take-21
[`first`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first
[`first!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first-21
[`last`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-last
[`last!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-last-21
[`find_by`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_by
[`find_by!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_by-21
[`config.active_record.error_on_ignored_order`]: configuring.html#config-active-record-error-on-ignored-order
[`find_each`]: https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_each
[`find_in_batches`]: https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_in_batches
[`sanitize_sql_like`]: https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql_like
[`where.not`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods/WhereChain.html#method-i-not
[`or`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-or
[`and`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-and
[`count`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-count
[`unscope`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-unscope
[`only`]: https://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-only
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`strict_loading`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-strict_loading
[`scope`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-scope
[`default_scope`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-default_scope
[`merge`]: https://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-merge
[`unscoped`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-unscoped
[`enum`]: https://api.rubyonrails.org/classes/ActiveRecord/Enum.html#method-i-enum
[`find_or_create_by`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by
[`find_or_create_by!`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by-21
[`find_or_initialize_by`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_initialize_by
[`find_by_sql`]: https://api.rubyonrails.org/classes/ActiveRecord/Querying.html#method-i-find_by_sql
[`connection.select_all`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-select_all
[`pluck`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pluck
[`pick`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pick
[`ids`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-ids
[`exists?`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F
[`average`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-average
[`minimum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-minimum
[`maximum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-maximum
[`sum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-sum
[`explain`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-explain
[MySQL5.7-explain]: https://dev.mysql.com/doc/refman/5.7/en/explain.html
[MySQL8-explain]: https://dev.mysql.com/doc/refman/8.0/en/explain.html
[MariaDB-explain]: https://mariadb.com/kb/en/analyze-and-explain-statements/
