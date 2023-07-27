**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9a8daf85251d1a12237dd39a65eed51a
Aktyvusis įrašas ir PostgreSQL
============================

Šiame vadove aptariamas aktyvaus įrašo specifinis naudojimas su PostgreSQL.

Po šio vadovo perskaitymo žinosite:

* Kaip naudoti PostgreSQL duomenų tipus.
* Kaip naudoti UUID pirmines raktus.
* Kaip įtraukti ne-raktinius stulpelius į indeksus.
* Kaip naudoti atidėtinus užsienio raktus.
* Kaip naudoti unikalius apribojimus.
* Kaip įgyvendinti išskirties apribojimus.
* Kaip įgyvendinti pilno teksto paiešką su PostgreSQL.
* Kaip palaikyti savo aktyvaus įrašo modelius su duomenų bazės rodiniais.

--------------------------------------------------------------------------------

Norėdami naudoti PostgreSQL adapterį, jums reikia bent 9.3 versijos įdiegti. Senesnės versijos nepalaikomos.

Norėdami pradėti naudoti PostgreSQL, peržiūrėkite
[Rails konfigūracijos vadovą](configuring.html#configuring-a-postgresql-database).
Jame aprašoma, kaip tinkamai sukonfigūruoti aktyvų įrašą PostgreSQL.

Duomenų tipai
---------

PostgreSQL siūlo keletą specifinių duomenų tipų. Štai sąrašas tipų, kurie yra palaikomi PostgreSQL adapteriu.

### Bytea

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/datatype-binary.html)
* [funkcijos ir operatoriai](https://www.postgresql.org/docs/current/static/functions-binarystring.html)

```ruby
# db/migrate/20140207133952_create_documents.rb
create_table :documents do |t|
  t.binary 'payload'
end
```

```ruby
# app/models/document.rb
class Document < ApplicationRecord
end
```

```ruby
# Naudojimas
data = File.read(Rails.root + "tmp/output.pdf")
Document.create payload: data
```

### Masyvas

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/arrays.html)
* [funkcijos ir operatoriai](https://www.postgresql.org/docs/current/static/functions-array.html)

```ruby
# db/migrate/20140207133952_create_books.rb
create_table :books do |t|
  t.string 'title'
  t.string 'tags', array: true
  t.integer 'ratings', array: true
end
add_index :books, :tags, using: 'gin'
add_index :books, :ratings, using: 'gin'
```

```ruby
# app/models/book.rb
class Book < ApplicationRecord
end
```

```ruby
# Naudojimas
Book.create title: "Brave New World",
            tags: ["fantazija", "fikcija"],
            ratings: [4, 5]

## Knygos su vienu žyma
Book.where("'fantazija' = ANY (tags)")

## Knygos su keliais žymomis
Book.where("tags @> ARRAY[?]::varchar[]", ["fantazija", "fikcija"])

## Knygos su 3 ar daugiau įvertinimų
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/hstore.html)
* [funkcijos ir operatoriai](https://www.postgresql.org/docs/current/static/hstore.html#id-1.11.7.26.5)

PASTABA: Norėdami naudoti hstore, turite įjungti `hstore` plėtinį.

```ruby
# db/migrate/20131009135255_create_profiles.rb
class CreateProfiles < ActiveRecord::Migration[7.0]
  enable_extension 'hstore' unless extension_enabled?('hstore')
  create_table :profiles do |t|
    t.hstore 'settings'
  end
end
```

```ruby
# app/models/profile.rb
class Profile < ApplicationRecord
end
```

```irb
irb> Profile.create(settings: { "spalva" => "mėlyna", "skiriamoji geba" => "800x600" })

irb> profile = Profile.first
irb> profile.settings
=> {"spalva"=>"mėlyna", "skiriamoji geba"=>"800x600"}

irb> profile.settings = {"spalva" => "geltona", "skiriamoji geba" => "1280x1024"}
irb> profile.save!

irb> Profile.where("settings->'spalva' = ?", "geltona")
=> #<ActiveRecord::Relation [#<Profile id: 1, settings: {"spalva"=>"geltona", "skiriamoji geba"=>"1280x1024"}>]>
```

### JSON ir JSONB

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/datatype-json.html)
* [funkcijos ir operatoriai](https://www.postgresql.org/docs/current/static/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
# ... for json duomenų tipą:
create_table :events do |t|
  t.json 'payload'
end
# ... arba jsonb duomenų tipą:
create_table :events do |t|
  t.jsonb 'payload'
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(payload: { rūšis: "vartotojo_pervadintas", pakeitimas: ["jack", "john"]})

irb> event = Event.first
irb> event.payload
=> {"rūšis"=>"vartotojo_pervadintas", "pakeitimas"=>["jack", "john"]}

## Užklausa pagal JSON dokumentą
# Operatorius -> grąžina pradinį JSON tipą (kuris gali būti objektas), o ->> grąžina tekstą
irb> Event.where("payload->>'rūšis' = ?", "vartotojo_pervadintas")
```

### Intervalo tipai

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/rangetypes.html)
* [funkcijos ir operatoriai](https://www.postgresql.org/docs/current/static/functions-range.html)

Šis tipas yra susietas su Ruby [`Interval`](https://ruby-doc.org/core-2.7.0/Range.html) objektais.

```ruby
# db/migrate/20130923065404_create_events.rb
create_table :events do |t|
  t.daterange 'trukmė'
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(trukmė: Date.new(2014, 2, 11)..Date.new(2014, 2, 12))

irb> event = Event.first
irb> event.trukmė
=> Tue, 11 Feb 2014...Thu, 13 Feb 2014

## Visi įvykiai tam tikrą dieną
irb> Event.where("trukmė @> ?::date", Date.new(2014, 2, 12))

## Darbas su intervalo ribomis
irb> event = Event.select("lower(trukmė) AS pradžia").select("upper(trukmė) AS pabaiga").first

irb> event.pradžia
=> Tue, 11 Feb 2014
irb> event.pabaiga
=> Thu, 13 Feb 2014
```

### Sudėtiniai tipai

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/rowtypes.html)

Šiuo metu nėra specialaus palaikymo sudėtiniams tipams. Jie yra susieti su
įprastais teksto stulpeliais:

```sql
CREATE TYPE pilnas_adresas AS
(
  miestas VARCHAR(90),
  gatvė VARCHAR(90)
);
```
```ruby
# db/migrate/20140207133952_create_contacts.rb
execute <<-SQL
  CREATE TYPE full_address AS
  (
    city VARCHAR(90),
    street VARCHAR(90)
  );
SQL
create_table :contacts do |t|
  t.column :address, :full_address
end
```

```ruby
# app/models/contact.rb
class Contact < ApplicationRecord
end
```

```irb
irb> Contact.create address: "(Paryžius,Champs-Élysées)"
irb> contact = Contact.first
irb> contact.address
=> "(Paryžius,Champs-Élysées)"
irb> contact.address = "(Paryžius,Rue Basse)"
irb> contact.save!
```

### Enumeruoti tipai

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/datatype-enum.html)

Tipą galima atvaizduoti kaip įprastą teksto stulpelį arba kaip [`ActiveRecord::Enum`](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

```ruby
# db/migrate/20131220144913_create_articles.rb
def change
  create_enum :article_status, ["juodraštis", "paskelbtas", "archyvuotas"]

  create_table :articles do |t|
    t.enum :status, enum_type: :article_status, default: "juodraštis", null: false
  end
end
```

Taip pat galite sukurti enum tipo ir pridėti enum stulpelį prie esamos lentelės:

```ruby
# db/migrate/20230113024409_add_status_to_articles.rb
def change
  create_enum :article_status, ["juodraštis", "paskelbtas", "archyvuotas"]

  add_column :articles, :status, :enum, enum_type: :article_status, default: "juodraštis", null: false
end
```

Abu migracijos yra atstatomos, tačiau jei reikia, galite apibrėžti atskirus `#up` ir `#down` metodus. Įsitikinkite, kad pašalinote visus stulpelius arba lentelės, kurie priklauso nuo enum tipo, prieš jį ištrindami:

```ruby
def down
  drop_table :articles

  # ARBA: remove_column :articles, :status
  drop_enum :article_status
end
```

Modelyje deklaruojant enum atributą, pridedami pagalbiniai metodai ir užkertamas kelias netinkamų reikšmių priskyrimui klasės egzemplioriams:

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  enum status: {
    juodraštis: "juodraštis", paskelbtas: "paskelbtas", archyvuotas: "archyvuotas"
  }, _prefix: true
end
```

```irb
irb> article = Article.create
irb> article.status
=> "juodraštis" # numatytoji būsena iš PostgreSQL, kaip apibrėžta migracijoje aukščiau

irb> article.status_paskelbtas!
irb> article.status
=> "paskelbtas"

irb> article.status_archyvuotas?
=> false

irb> article.status = "ištrintas"
ArgumentError: 'ištrintas' nėra galiojanti būsena
```

Norėdami pervardyti enum, galite naudoti `rename_enum` kartu su atnaujinimu bet kokio modelio naudojimo:

```ruby
# db/migrate/20150718144917_rename_article_status.rb
def change
  rename_enum :article_status, to: :article_state
end
```

Norėdami pridėti naują reikšmę, galite naudoti `add_enum_value`:

```ruby
# db/migrate/20150720144913_add_new_state_to_articles.rb
def up
  add_enum_value :article_state, "archyvuotas", # bus pabaigoje po paskelbto
  add_enum_value :article_state, "peržiūrimas", before: "paskelbtas"
  add_enum_value :article_state, "patvirtintas", after: "peržiūrimas"
end
```

PASTABA: Enum reikšmių negalima ištrinti, tai taip pat reiškia, kad `add_enum_value` yra neatsikratoma. Galite perskaityti kodėl [čia](https://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com).

Norėdami pervardyti reikšmę, galite naudoti `rename_enum_value`:

```ruby
# db/migrate/20150722144915_rename_article_state.rb
def change
  rename_enum_value :article_state, from: "archyvuotas", to: "ištrintas"
end
```

Patarimas: norėdami pamatyti visų jūsų turimų enum reikšmių sąrašą, galite iškviesti šią užklausą `bin/rails db` arba `psql` konsolėje:

```sql
SELECT n.nspname AS enum_schema,
       t.typname AS enum_name,
       e.enumlabel AS enum_value
  FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
```

### UUID

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/datatype-uuid.html)
* [pgcrypto generatoriaus funkcija](https://www.postgresql.org/docs/current/static/pgcrypto.html)
* [uuid-ossp generatoriaus funkcijos](https://www.postgresql.org/docs/current/static/uuid-ossp.html)

PASTABA: Jei naudojate PostgreSQL versiją ankstesnę nei 13.0, gali prireikti įjungti specialius plėtinius, kad galėtumėte naudoti UUID. Įjunkite `pgcrypto` plėtinį (PostgreSQL >= 9.4) arba `uuid-ossp` plėtinį (dar ankstesnėms versijoms).

```ruby
# db/migrate/20131220144913_create_revisions.rb
create_table :revisions do |t|
  t.uuid :identifier
end
```

```ruby
# app/models/revision.rb
class Revision < ApplicationRecord
end
```

```irb
irb> Revision.create identifier: "A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11"

irb> revision = Revision.first
irb> revision.identifier
=> "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
```

Migracijose galite naudoti `uuid` tipą, kad apibrėžtumėte nuorodas:

```ruby
# db/migrate/20150418012400_create_blog.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :posts, id: :uuid

create_table :comments, id: :uuid do |t|
  # t.belongs_to :post, type: :uuid
  t.references :post, type: :uuid
end
```

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments
end
```

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
end
```

Daugiau informacijos apie UUID naudojimą kaip pirminį raktą rasite [šiame skyriuje](#uuid-primary-keys).

### Bitų eilutės tipai

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/datatype-bit.html)
* [funkcijos ir operatoriai](https://www.postgresql.org/docs/current/static/functions-bitstring.html)

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users, force: true do |t|
  t.column :settings, "bit(8)"
end
```

```ruby
# app/models/user.rb
class User < ApplicationRecord
end
```

```irb
irb> User.create settings: "01010011"
irb> user = User.first
irb> user.settings
=> "01010011"
irb> user.settings = "0xAF"
irb> user.settings
=> "10101111"
irb> user.save!
```

### Tinklo adreso tipai

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/datatype-net-types.html)

Tipai `inet` ir `cidr` yra susiejami su Ruby
[`IPAddr`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ipaddr/rdoc/IPAddr.html)
objektais. `macaddr` tipas yra susiejamas su paprastu tekstu.

```ruby
# db/migrate/20140508144913_create_devices.rb
create_table(:devices, force: true) do |t|
  t.inet 'ip'
  t.cidr 'network'
  t.macaddr 'address'
end
```

```ruby
# app/models/device.rb
class Device < ApplicationRecord
end
```

```irb
irb> macbook = Device.create(ip: "192.168.1.12", network: "192.168.2.0/24", address: "32:01:16:6d:05:ef")

irb> macbook.ip
=> #<IPAddr: IPv4:192.168.1.12/255.255.255.255>

irb> macbook.network
=> #<IPAddr: IPv4:192.168.2.0/255.255.255.0>

irb> macbook.address
=> "32:01:16:6d:05:ef"
```

### Geometriniai tipai

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/datatype-geometric.html)

Visi geometriniai tipai, išskyrus `points`, yra susiejami su paprastu tekstu.
Taškas yra konvertuojamas į masyvą, kuriame yra `x` ir `y` koordinatės.

### Intervalas

* [tipo apibrėžimas](https://www.postgresql.org/docs/current/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
* [funkcijos ir operatoriai](https://www.postgresql.org/docs/current/static/functions-datetime.html)

Šis tipas yra susiejamas su [`ActiveSupport::Duration`](https://api.rubyonrails.org/classes/ActiveSupport/Duration.html) objektais.

```ruby
# db/migrate/20200120000000_create_events.rb
create_table :events do |t|
  t.interval 'duration'
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(duration: 2.days)

irb> event = Event.first
irb> event.duration
=> 2 days
```

UUID pagrindiniai raktai
------------------------

PASTABA: Norint generuoti atsitiktinius UUID, reikia įjungti `pgcrypto` (tik PostgreSQL >= 9.4) arba `uuid-ossp` plėtinį.

```ruby
# db/migrate/20131220144913_create_devices.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :devices, id: :uuid do |t|
  t.string :kind
end
```

```ruby
# app/models/device.rb
class Device < ApplicationRecord
end
```

```irb
irb> device = Device.create
irb> device.id
=> "814865cd-5a1d-4771-9306-4268f188fe9e"
```

PASTABA: Jei `:default` parinktis nebuvo perduota `create_table` metode, tuomet `gen_random_uuid()` (iš `pgcrypto`) yra numatytasis variantas.

Norint naudoti Rails modelio generatorių lentelėje, kurioje UUID yra pagrindinis raktas, reikia perduoti `--primary-key-type=uuid` modelio generatoriui.

Pavyzdžiui:

```bash
$ rails generate model Device --primary-key-type=uuid kind:string
```

Kuriant modelį su užsienio raktu, kuris rodo į šį UUID, `uuid` lauką reikia traktuoti kaip natyvų lauko tipą, pavyzdžiui:

```bash
$ rails generate model Case device_id:uuid
```

Indeksavimas
--------

* [indekso kūrimas](https://www.postgresql.org/docs/current/sql-createindex.html)

PostgreSQL turi įvairių indekso parinkčių. Šios parinktys yra palaikomos PostgreSQL adapterio, be
[bendrų indekso parinkčių](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index)

### Include

Kuriant naują indeksą, ne-raktiniai stulpeliai gali būti įtraukti naudojant `:include` parinktį.
Šie raktai nenaudojami indekso skenavimui ieškant, bet gali būti nuskaityti indekso
tik skenavimo metu, neapsilankant susijusioje lentelėje.

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id.rb

add_index :users, :email, include: :id
```

Palaikomi keli stulpeliai:

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id_and_created_at.rb

add_index :users, :email, include: [:id, :created_at]
```

Generuojami stulpeliai
-----------------

PASTABA: Generuojami stulpeliai palaikomi nuo PostgreSQL 12.0 versijos.

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users do |t|
  t.string :name
  t.virtual :name_upcased, type: :string, as: 'upper(name)', stored: true
end

# app/models/user.rb
class User < ApplicationRecord
end

# Naudojimas
user = User.create(name: 'John')
User.last.name_upcased # => "JOHN"
```

Atidėtiniai užsienio raktai
-----------------------

* [užsienio rakto lentelės apribojimai](https://www.postgresql.org/docs/current/sql-set-constraints.html)

Pagal numatytuosius nustatymus, PostgreSQL tikrina lentelės apribojimus iš karto po kiekvieno užklausos. Ji sąmoningai neleidžia kurti įrašų, kuriuose nėra nuorodos į susijusią lentelę. Tačiau galima paleisti šią vientisumo patikrą vėliau, kai sandoris yra įvykdomas, pridedant `DEFERRABLE` prie užsienio rakto apibrėžimo. Norint atidėti visus patikrinimus pagal numatytuosius nustatymus, galima nustatyti `DEFERRABLE INITIALLY DEFERRED`. Rails pateikia šią PostgreSQL funkciją, pridedant `:deferrable` raktą prie `foreign_key` parinkčių `add_reference` ir `add_foreign_key` metodų.

Vienas pavyzdys yra sukurti ciklinius priklausomybes sandorio metu, net jei sukūrėte užsienio raktus:

```ruby
add_reference :person, :alias, foreign_key: { deferrable: :deferred }
add_reference :alias, :person, foreign_key: { deferrable: :deferred }
```

Jei nuoroda buvo sukurta su `foreign_key: true` parinktimi, šis sandoris nepavyktų vykdant pirmąjį `INSERT` teiginį. Tačiau jis nepavyksta, kai nustatoma `deferrable: :deferred` parinktis.
```ruby
ActiveRecord::Base.connection.transaction do
  person = Person.create(id: SecureRandom.uuid, alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

Kai `:deferrable` parinktis nustatoma kaip `:immediate`, leidžiama užsienio raktams išlaikyti numatytąjį elgesį ir patikrinti apribojimus iš karto, tačiau leidžiama rankiniu būdu atidėti patikrinimus naudojant `SET CONSTRAINTS ALL DEFERRED` transakcijoje. Tai sukels užsienio raktų patikrinimą, kai transakcija bus įvykdyta:

```ruby
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL DEFERRED")
  person = Person.create(alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

Pagal numatytuosius nustatymus `:deferrable` yra `false` ir apribojimas visada tikrinamas iš karto.

Unikalus apribojimas
--------------------

* [unikalus apribojimai](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS)

```ruby
# db/migrate/20230422225213_create_items.rb
create_table :items do |t|
  t.integer :position, null: false
  t.unique_key [:position], deferrable: :immediate
end
```

Jei norite pakeisti esamą unikalų indeksą į atidėtinį, galite naudoti `:using_index`, kad sukurtumėte atidėtinus unikalius apribojimus.

```ruby
add_unique_key :items, deferrable: :deferred, using_index: "index_items_on_position"
```

Kaip ir užsienio raktai, unikalūs apribojimai gali būti atidėti, nustatant `:deferrable` kaip `:immediate` arba `:deferred`. Pagal numatytuosius nustatymus `:deferrable` yra `false` ir apribojimas visada tikrinamas iš karto.

Išskirties apribojimai
---------------------

* [išskirties apribojimai](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION)

```ruby
# db/migrate/20131220144913_create_products.rb
create_table :products do |t|
  t.integer :price, null: false
  t.daterange :availability_range, null: false

  t.exclusion_constraint "price WITH =, availability_range WITH &&", using: :gist, name: "price_check"
end
```

Kaip ir užsienio raktai, išskirties apribojimai gali būti atidėti, nustatant `:deferrable` kaip `:immediate` arba `:deferred`. Pagal numatytuosius nustatymus `:deferrable` yra `false` ir apribojimas visada tikrinamas iš karto.

Pilno teksto paieška
----------------

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body
end

add_index :documents, "to_tsvector('english', title || ' ' || body)", using: :gin, name: 'documents_idx'
```

```ruby
# app/models/document.rb
class Document < ApplicationRecord
end
```

```ruby
# Usage
Document.create(title: "Cats and Dogs", body: "are nice!")

## all documents matching 'cat & dog'
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "cat & dog")
```

Galite pasirinktinai saugoti vektorių kaip automatiškai sugeneruotą stulpelį (nuo PostgreSQL 12.0):

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body

  t.virtual :textsearchable_index_col,
            type: :tsvector, as: "to_tsvector('english', title || ' ' || body)", stored: true
end

add_index :documents, :textsearchable_index_col, using: :gin, name: 'documents_idx'

# Usage
Document.create(title: "Cats and Dogs", body: "are nice!")

## all documents matching 'cat & dog'
Document.where("textsearchable_index_col @@ to_tsquery(?)", "cat & dog")
```

Duomenų bazės rodiniai
--------------

* [rodinio kūrimas](https://www.postgresql.org/docs/current/static/sql-createview.html)

Įsivaizduokite, kad turite dirbti su sena duomenų baze, kurioje yra ši lentelė:

```
rails_pg_guide=# \d "TBL_ART"
                                        Table "public.TBL_ART"
   Column   |            Type             |                         Modifiers
------------+-----------------------------+------------------------------------------------------------
 INT_ID     | integer                     | not null default nextval('"TBL_ART_INT_ID_seq"'::regclass)
 STR_TITLE  | character varying           |
 STR_STAT   | character varying           | default 'draft'::character varying
 DT_PUBL_AT | timestamp without time zone |
 BL_ARCH    | boolean                     | default false
Indexes:
    "TBL_ART_pkey" PRIMARY KEY, btree ("INT_ID")
```

Ši lentelė visiškai neatitinka „Rails“ konvencijų.
Nes paprasti „PostgreSQL“ rodiniai pagal numatytuosius nustatymus gali būti atnaujinami,
mes jį apgaubėme taip:

```ruby
# db/migrate/20131220144913_create_articles_view.rb
execute <<-SQL
CREATE VIEW articles AS
  SELECT "INT_ID" AS id,
         "STR_TITLE" AS title,
         "STR_STAT" AS status,
         "DT_PUBL_AT" AS published_at,
         "BL_ARCH" AS archived
  FROM "TBL_ART"
  WHERE "BL_ARCH" = 'f'
SQL
```

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  self.primary_key = "id"
  def archive!
    update_attribute :archived, true
  end
end
```

```irb
irb> first = Article.create! title: "Winter is coming", status: "published", published_at: 1.year.ago
irb> second = Article.create! title: "Brace yourself", status: "draft", published_at: 1.month.ago

irb> Article.count
=> 2
irb> first.archive!
irb> Article.count
=> 1
```

PASTABA: Ši programa domina tik nearchyvuotus `Articles`. Rodinys taip pat
leidžia nustatyti sąlygas, todėl galime tiesiogiai pašalinti archyvuotus `Articles`.

Struktūros atvaizdavimas
--------------

Jei jūsų `config.active_record.schema_format` yra `:sql`, „Rails“ iškvies `pg_dump`, kad sukurtų
struktūros atvaizdą.
Galite naudoti `ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags` konfigūruoti `pg_dump`.
Pavyzdžiui, norint neįtraukti komentarų į struktūros iškrovimą, pridėkite tai prie inicializavimo:

```ruby
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
```
