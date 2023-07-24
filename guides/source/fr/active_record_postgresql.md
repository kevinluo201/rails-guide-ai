**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9a8daf85251d1a12237dd39a65eed51a
Active Record et PostgreSQL
============================

Ce guide couvre l'utilisation spécifique de PostgreSQL avec Active Record.

Après avoir lu ce guide, vous saurez :

* Comment utiliser les types de données de PostgreSQL.
* Comment utiliser des clés primaires UUID.
* Comment inclure des colonnes non-clés dans les index.
* Comment utiliser des clés étrangères différables.
* Comment utiliser des contraintes uniques.
* Comment implémenter des contraintes d'exclusion.
* Comment implémenter une recherche en texte intégral avec PostgreSQL.
* Comment sauvegarder vos modèles Active Record avec des vues de base de données.

--------------------------------------------------------------------------------

Pour utiliser l'adaptateur PostgreSQL, vous devez avoir au moins la version 9.3 installée. Les anciennes versions ne sont pas prises en charge.

Pour commencer avec PostgreSQL, consultez le [guide de configuration de Rails](configuring.html#configuring-a-postgresql-database). Il décrit comment configurer correctement Active Record pour PostgreSQL.

Types de données
---------

PostgreSQL propose plusieurs types de données spécifiques. Voici une liste des types pris en charge par l'adaptateur PostgreSQL.

### Bytea

* [définition du type](https://www.postgresql.org/docs/current/static/datatype-binary.html)
* [fonctions et opérateurs](https://www.postgresql.org/docs/current/static/functions-binarystring.html)

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
# Utilisation
data = File.read(Rails.root + "tmp/output.pdf")
Document.create payload: data
```

### Array

* [définition du type](https://www.postgresql.org/docs/current/static/arrays.html)
* [fonctions et opérateurs](https://www.postgresql.org/docs/current/static/functions-array.html)

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
# Utilisation
Book.create title: "Brave New World",
            tags: ["fantasy", "fiction"],
            ratings: [4, 5]

## Livres pour un seul tag
Book.where("'fantasy' = ANY (tags)")

## Livres pour plusieurs tags
Book.where("tags @> ARRAY[?]::varchar[]", ["fantasy", "fiction"])

## Livres avec 3 notes ou plus
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [définition du type](https://www.postgresql.org/docs/current/static/hstore.html)
* [fonctions et opérateurs](https://www.postgresql.org/docs/current/static/hstore.html#id-1.11.7.26.5)

NOTE : Vous devez activer l'extension `hstore` pour utiliser hstore.

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
irb> Profile.create(settings: { "color" => "blue", "resolution" => "800x600" })

irb> profile = Profile.first
irb> profile.settings
=> {"color"=>"blue", "resolution"=>"800x600"}

irb> profile.settings = {"color" => "yellow", "resolution" => "1280x1024"}
irb> profile.save!

irb> Profile.where("settings->'color' = ?", "yellow")
=> #<ActiveRecord::Relation [#<Profile id: 1, settings: {"color"=>"yellow", "resolution"=>"1280x1024"}>]>
```

### JSON et JSONB

* [définition du type](https://www.postgresql.org/docs/current/static/datatype-json.html)
* [fonctions et opérateurs](https://www.postgresql.org/docs/current/static/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
# ... pour le type de données json :
create_table :events do |t|
  t.json 'payload'
end
# ... ou pour le type de données jsonb :
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
irb> Event.create(payload: { kind: "user_renamed", change: ["jack", "john"]})

irb> event = Event.first
irb> event.payload
=> {"kind"=>"user_renamed", "change"=>["jack", "john"]}

## Requête basée sur un document JSON
# L'opérateur -> renvoie le type JSON d'origine (qui peut être un objet), tandis que ->> renvoie du texte
irb> Event.where("payload->>'kind' = ?", "user_renamed")
```

### Types de plage

* [définition du type](https://www.postgresql.org/docs/current/static/rangetypes.html)
* [fonctions et opérateurs](https://www.postgresql.org/docs/current/static/functions-range.html)

Ce type est mappé sur des objets [`Range`](https://ruby-doc.org/core-2.7.0/Range.html) en Ruby.

```ruby
# db/migrate/20130923065404_create_events.rb
create_table :events do |t|
  t.daterange 'duration'
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(duration: Date.new(2014, 2, 11)..Date.new(2014, 2, 12))

irb> event = Event.first
irb> event.duration
=> Tue, 11 Feb 2014...Thu, 13 Feb 2014

## Tous les événements à une date donnée
irb> Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## Travailler avec les bornes de la plage
irb> event = Event.select("lower(duration) AS starts_at").select("upper(duration) AS ends_at").first

irb> event.starts_at
=> Tue, 11 Feb 2014
irb> event.ends_at
=> Thu, 13 Feb 2014
```

### Types composites

* [définition du type](https://www.postgresql.org/docs/current/static/rowtypes.html)

Actuellement, il n'y a pas de support spécial pour les types composites. Ils sont mappés sur des colonnes de texte normales :

```sql
CREATE TYPE full_address AS
(
  city VARCHAR(90),
  street VARCHAR(90)
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
irb> Contact.create address: "(Paris,Champs-Élysées)"
irb> contact = Contact.first
irb> contact.address
=> "(Paris,Champs-Élysées)"
irb> contact.address = "(Paris,Rue Basse)"
irb> contact.save!
```

### Types énumérés

* [définition du type](https://www.postgresql.org/docs/current/static/datatype-enum.html)

Le type peut être mappé comme une colonne de texte normale, ou comme un [`ActiveRecord::Enum`](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

```ruby
# db/migrate/20131220144913_create_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  create_table :articles do |t|
    t.enum :status, enum_type: :article_status, default: "draft", null: false
  end
end
```

Vous pouvez également créer un type enum et ajouter une colonne enum à une table existante :

```ruby
# db/migrate/20230113024409_add_status_to_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  add_column :articles, :status, :enum, enum_type: :article_status, default: "draft", null: false
end
```

Les migrations ci-dessus sont réversibles, mais vous pouvez définir des méthodes `#up` et `#down` séparées si nécessaire. Assurez-vous de supprimer toutes les colonnes ou tables qui dépendent du type enum avant de le supprimer :

```ruby
def down
  drop_table :articles

  # OU : remove_column :articles, :status
  drop_enum :article_status
end
```

La déclaration d'un attribut enum dans le modèle ajoute des méthodes d'aide et empêche l'assignation de valeurs invalides aux instances de la classe :

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  enum status: {
    draft: "draft", published: "published", archived: "archived"
  }, _prefix: true
end
```

```irb
irb> article = Article.create
irb> article.status
=> "draft" # statut par défaut de PostgreSQL, tel que défini dans la migration ci-dessus

irb> article.status_published!
irb> article.status
=> "published"

irb> article.status_archived?
=> false

irb> article.status = "deleted"
ArgumentError: 'deleted' n'est pas un statut valide
```

Pour renommer l'enum, vous pouvez utiliser `rename_enum` en mettant à jour toute utilisation du modèle :

```ruby
# db/migrate/20150718144917_rename_article_status.rb
def change
  rename_enum :article_status, to: :article_state
end
```

Pour ajouter une nouvelle valeur, vous pouvez utiliser `add_enum_value` :

```ruby
# db/migrate/20150720144913_add_new_state_to_articles.rb
def up
  add_enum_value :article_state, "archived", # sera à la fin après published
  add_enum_value :article_state, "in review", before: "published"
  add_enum_value :article_state, "approved", after: "in review"
end
```

REMARQUE : Les valeurs enum ne peuvent pas être supprimées, ce qui signifie également que `add_enum_value` est irréversible. Vous pouvez lire pourquoi [ici](https://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com).

Pour renommer une valeur, vous pouvez utiliser `rename_enum_value` :

```ruby
# db/migrate/20150722144915_rename_article_state.rb
def change
  rename_enum_value :article_state, from: "archived", to: "deleted"
end
```

Astuce : pour afficher toutes les valeurs de tous les enums que vous avez, vous pouvez exécuter cette requête dans la console `bin/rails db` ou `psql` :

```sql
SELECT n.nspname AS enum_schema,
       t.typname AS enum_name,
       e.enumlabel AS enum_value
  FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
```

### UUID

* [définition du type](https://www.postgresql.org/docs/current/static/datatype-uuid.html)
* [fonction de génération pgcrypto](https://www.postgresql.org/docs/current/static/pgcrypto.html)
* [fonctions de génération uuid-ossp](https://www.postgresql.org/docs/current/static/uuid-ossp.html)

REMARQUE : Si vous utilisez une version de PostgreSQL antérieure à 13.0, vous devrez peut-être activer des extensions spéciales pour utiliser les UUID. Activez l'extension `pgcrypto` (PostgreSQL >= 9.4) ou l'extension `uuid-ossp` (pour les versions antérieures).

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

Vous pouvez utiliser le type `uuid` pour définir des références dans les migrations :

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

Consultez [cette section](#uuid-primary-keys) pour plus de détails sur l'utilisation des UUID en tant que clé primaire.

### Types de chaînes de bits

* [définition du type](https://www.postgresql.org/docs/current/static/datatype-bit.html)
* [fonctions et opérateurs](https://www.postgresql.org/docs/current/static/functions-bitstring.html)

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

### Types d'adresse réseau

* [définition du type](https://www.postgresql.org/docs/current/static/datatype-net-types.html)

Les types `inet` et `cidr` sont mappés sur des objets Ruby [`IPAddr`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ipaddr/rdoc/IPAddr.html). Le type `macaddr` est mappé sur un texte normal.

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

### Types géométriques

* [définition du type](https://www.postgresql.org/docs/current/static/datatype-geometric.html)

Tous les types géométriques, à l'exception des points, sont mappés sur du texte normal. Un point est converti en un tableau contenant les coordonnées `x` et `y`.

### Interval

* [définition du type](https://www.postgresql.org/docs/current/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
* [fonctions et opérateurs](https://www.postgresql.org/docs/current/static/functions-datetime.html)

Ce type est mappé sur des objets [`ActiveSupport::Duration`](https://api.rubyonrails.org/classes/ActiveSupport/Duration.html).

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

UUID Primary Keys
-----------------

REMARQUE : Vous devez activer l'extension `pgcrypto` (uniquement PostgreSQL >= 9.4) ou `uuid-ossp` pour générer des UUID aléatoires.
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

NOTE: `gen_random_uuid()` (from `pgcrypto`) is assumed if no `:default` option
was passed to `create_table`.

To use the Rails model generator for a table using UUID as the primary key, pass
`--primary-key-type=uuid` to the model generator.

For example:

```bash
$ rails generate model Device --primary-key-type=uuid kind:string
```

When building a model with a foreign key that will reference this UUID, treat
`uuid` as the native field type, for example:

```bash
$ rails generate model Case device_id:uuid
```

Indexation
--------

* [création d'index](https://www.postgresql.org/docs/current/sql-createindex.html)

PostgreSQL inclut une variété d'options d'index. Les options suivantes sont
prises en charge par l'adaptateur PostgreSQL en plus des
[options d'index courantes](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index)

### Include

Lors de la création d'un nouvel index, des colonnes non clés peuvent être incluses avec l'option `:include`.
Ces clés ne sont pas utilisées dans les analyses d'index pour la recherche, mais peuvent être lues lors d'une analyse
uniquement de l'index sans avoir à visiter la table associée.

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id.rb

add_index :users, :email, include: :id
```

Plusieurs colonnes sont prises en charge:

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id_and_created_at.rb

add_index :users, :email, include: [:id, :created_at]
```

Colonnes générées
-----------------

NOTE: Les colonnes générées sont prises en charge depuis la version 12.0 de PostgreSQL.

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users do |t|
  t.string :name
  t.virtual :name_upcased, type: :string, as: 'upper(name)', stored: true
end

# app/models/user.rb
class User < ApplicationRecord
end

# Utilisation
user = User.create(name: 'John')
User.last.name_upcased # => "JOHN"
```

Clés étrangères différables
-----------------------

* [contraintes de table clés étrangères](https://www.postgresql.org/docs/current/sql-set-constraints.html)

Par défaut, les contraintes de table dans PostgreSQL sont vérifiées immédiatement après chaque instruction. Il n'est pas possible de créer des enregistrements où l'enregistrement référencé n'est pas encore dans la table référencée. Il est possible d'exécuter cette vérification d'intégrité plus tard lorsque la transaction est validée en ajoutant `DEFERRABLE` à la définition de la clé étrangère. Rails expose cette fonctionnalité de PostgreSQL en ajoutant la clé `:deferrable` aux options `foreign_key` dans les méthodes `add_reference` et `add_foreign_key`.

Un exemple de ceci est la création de dépendances circulaires dans une transaction même si vous avez créé des clés étrangères:

```ruby
add_reference :person, :alias, foreign_key: { deferrable: :deferred }
add_reference :alias, :person, foreign_key: { deferrable: :deferred }
```

Si la référence a été créée avec l'option `foreign_key: true`, la transaction suivante échouerait lors de l'exécution de la première instruction `INSERT`. Cependant, elle ne échoue pas lorsque l'option `deferrable: :deferred` est définie.

```ruby
ActiveRecord::Base.connection.transaction do
  person = Person.create(id: SecureRandom.uuid, alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

Lorsque l'option `:deferrable` est définie sur `:immediate`, laissez les clés étrangères conserver le comportement par défaut de vérification de la contrainte immédiatement, mais permettez de différer manuellement les vérifications en utilisant `SET CONSTRAINTS ALL DEFERRED` dans une transaction. Cela provoquera la vérification des clés étrangères lorsque la transaction est validée:

```ruby
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL DEFERRED")
  person = Person.create(alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

Par défaut, `:deferrable` est `false` et la contrainte est toujours vérifiée immédiatement.

Contrainte unique
-----------------

* [contraintes uniques](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS)

```ruby
# db/migrate/20230422225213_create_items.rb
create_table :items do |t|
  t.integer :position, null: false
  t.unique_key [:position], deferrable: :immediate
end
```

Si vous souhaitez modifier un index unique existant pour le rendre différable, vous pouvez utiliser `:using_index` pour créer des contraintes uniques différables.

```ruby
add_unique_key :items, deferrable: :deferred, using_index: "index_items_on_position"
```

Comme les clés étrangères, les contraintes uniques peuvent être différées en définissant `:deferrable` sur `:immediate` ou `:deferred`. Par défaut, `:deferrable` est `false` et la contrainte est toujours vérifiée immédiatement.

Contraintes d'exclusion
---------------------

* [contraintes d'exclusion](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION)

```ruby
# db/migrate/20131220144913_create_products.rb
create_table :products do |t|
  t.integer :price, null: false
  t.daterange :availability_range, null: false

  t.exclusion_constraint "price WITH =, availability_range WITH &&", using: :gist, name: "price_check"
end
```

Comme les clés étrangères, les contraintes d'exclusion peuvent être différées en définissant `:deferrable` sur `:immediate` ou `:deferred`. Par défaut, `:deferrable` est `false` et la contrainte est toujours vérifiée immédiatement.

Recherche en texte intégral
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
# Utilisation
Document.create(title: "Chats et Chiens", body: "sont gentils!")

## tous les documents correspondant à 'chat & chien'
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "chat & chien")
```

En option, vous pouvez stocker le vecteur en tant que colonne générée automatiquement (à partir de PostgreSQL 12.0) :

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body

  t.virtual :textsearchable_index_col,
            type: :tsvector, as: "to_tsvector('english', title || ' ' || body)", stored: true
end

add_index :documents, :textsearchable_index_col, using: :gin, name: 'documents_idx'

# Utilisation
Document.create(title: "Chats et Chiens", body: "sont gentils!")

## tous les documents correspondant à 'chat & chien'
Document.where("textsearchable_index_col @@ to_tsquery(?)", "chat & chien")
```

Vues de base de données
--------------

* [création de vue](https://www.postgresql.org/docs/current/static/sql-createview.html)

Imaginez que vous devez travailler avec une base de données héritée contenant la table suivante :

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

Cette table ne suit pas du tout les conventions de Rails.
Parce que les vues simples de PostgreSQL sont modifiables par défaut,
nous pouvons l'envelopper comme suit :

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
irb> first = Article.create! title: "L'hiver arrive", status: "publié", published_at: Il y a 1 an
irb> second = Article.create! title: "Préparez-vous", status: "brouillon", published_at: Il y a 1 mois

irb> Article.count
=> 2
irb> first.archive!
irb> Article.count
=> 1
```

NOTE : Cette application ne s'intéresse qu'aux `Articles` non archivés. Une vue permet également d'ajouter des conditions pour exclure directement les `Articles` archivés.

Sauvegardes de structure
--------------

Si votre `config.active_record.schema_format` est `:sql`, Rails appellera `pg_dump` pour générer une sauvegarde de structure.

Vous pouvez utiliser `ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags` pour configurer `pg_dump`.
Par exemple, pour exclure les commentaires de votre sauvegarde de structure, ajoutez ceci à un initialiseur :

```ruby
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
```
