**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9a8daf85251d1a12237dd39a65eed51a
Active Record y PostgreSQL
============================

Esta guía cubre el uso específico de Active Record con PostgreSQL.

Después de leer esta guía, sabrás:

* Cómo usar los tipos de datos de PostgreSQL.
* Cómo usar claves primarias UUID.
* Cómo incluir columnas no clave en índices.
* Cómo usar claves foráneas aplazables.
* Cómo usar restricciones únicas.
* Cómo implementar restricciones de exclusión.
* Cómo implementar búsqueda de texto completo con PostgreSQL.
* Cómo respaldar tus modelos de Active Record con vistas de base de datos.

--------------------------------------------------------------------------------

Para usar el adaptador de PostgreSQL, necesitas tener instalada al menos la versión 9.3. Las versiones anteriores no son compatibles.

Para comenzar con PostgreSQL, consulta la [guía de configuración de Rails](configuring.html#configuring-a-postgresql-database). Describe cómo configurar correctamente Active Record para PostgreSQL.

Tipos de datos
---------

PostgreSQL ofrece una serie de tipos de datos específicos. A continuación se muestra una lista de los tipos que son compatibles con el adaptador de PostgreSQL.

### Bytea

* [definición del tipo](https://www.postgresql.org/docs/current/static/datatype-binary.html)
* [funciones y operadores](https://www.postgresql.org/docs/current/static/functions-binarystring.html)

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
# Uso
data = File.read(Rails.root + "tmp/output.pdf")
Document.create payload: data
```

### Array

* [definición del tipo](https://www.postgresql.org/docs/current/static/arrays.html)
* [funciones y operadores](https://www.postgresql.org/docs/current/static/functions-array.html)

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
# Uso
Book.create title: "Brave New World",
            tags: ["fantasy", "fiction"],
            ratings: [4, 5]

## Libros para una sola etiqueta
Book.where("'fantasy' = ANY (tags)")

## Libros para varias etiquetas
Book.where("tags @> ARRAY[?]::varchar[]", ["fantasy", "fiction"])

## Libros con 3 o más calificaciones
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [definición del tipo](https://www.postgresql.org/docs/current/static/hstore.html)
* [funciones y operadores](https://www.postgresql.org/docs/current/static/hstore.html#id-1.11.7.26.5)

NOTA: Necesitas habilitar la extensión `hstore` para usar hstore.

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

### JSON y JSONB

* [definición del tipo](https://www.postgresql.org/docs/current/static/datatype-json.html)
* [funciones y operadores](https://www.postgresql.org/docs/current/static/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
# ... para el tipo de dato json:
create_table :events do |t|
  t.json 'payload'
end
# ... o para el tipo de dato jsonb:
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

## Consulta basada en el documento JSON
# El operador -> devuelve el tipo JSON original (que puede ser un objeto), mientras que ->> devuelve texto
irb> Event.where("payload->>'kind' = ?", "user_renamed")
```

### Tipos de rango

* [definición del tipo](https://www.postgresql.org/docs/current/static/rangetypes.html)
* [funciones y operadores](https://www.postgresql.org/docs/current/static/functions-range.html)

Este tipo se asigna a objetos Ruby [`Range`](https://ruby-doc.org/core-2.7.0/Range.html).

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

## Todos los eventos en una fecha determinada
irb> Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## Trabajando con límites de rango
irb> event = Event.select("lower(duration) AS starts_at").select("upper(duration) AS ends_at").first

irb> event.starts_at
=> Tue, 11 Feb 2014
irb> event.ends_at
=> Thu, 13 Feb 2014
```

### Tipos compuestos

* [definición del tipo](https://www.postgresql.org/docs/current/static/rowtypes.html)

Actualmente no hay soporte especial para tipos compuestos. Se asignan a columnas de texto normales:

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

### Tipos enumerados

* [definición del tipo](https://www.postgresql.org/docs/current/static/datatype-enum.html)

El tipo se puede asignar como una columna de texto normal o a un [`ActiveRecord::Enum`](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

```ruby
# db/migrate/20131220144913_create_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  create_table :articles do |t|
    t.enum :status, enum_type: :article_status, default: "draft", null: false
  end
end
```
También puedes crear un tipo de enumeración y agregar una columna de enumeración a una tabla existente:

```ruby
# db/migrate/20230113024409_add_status_to_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  add_column :articles, :status, :enum, enum_type: :article_status, default: "draft", null: false
end
```

Las migraciones anteriores son reversibles, pero puedes definir métodos separados `#up` y `#down` si es necesario. Asegúrate de eliminar cualquier columna o tabla que dependa del tipo de enumeración antes de eliminarlo:

```ruby
def down
  drop_table :articles

  # O: remove_column :articles, :status
  drop_enum :article_status
end
```

Declarar un atributo de enumeración en el modelo agrega métodos auxiliares y evita que se asignen valores no válidos a las instancias de la clase:

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
=> "draft" # estado predeterminado de PostgreSQL, como se define en la migración anterior

irb> article.status_published!
irb> article.status
=> "published"

irb> article.status_archived?
=> false

irb> article.status = "deleted"
ArgumentError: 'deleted' no es un estado válido
```

Para cambiar el nombre de la enumeración, puedes usar `rename_enum` junto con la actualización de cualquier uso del modelo:

```ruby
# db/migrate/20150718144917_rename_article_status.rb
def change
  rename_enum :article_status, to: :article_state
end
```

Para agregar un nuevo valor, puedes usar `add_enum_value`:

```ruby
# db/migrate/20150720144913_add_new_state_to_articles.rb
def up
  add_enum_value :article_state, "archived", # estará al final después de publicado
  add_enum_value :article_state, "in review", before: "published"
  add_enum_value :article_state, "approved", after: "in review"
end
```

NOTA: Los valores de enumeración no se pueden eliminar, lo que también significa que `add_enum_value` no se puede revertir. Puedes leer por qué [aquí](https://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com).

Para cambiar el nombre de un valor, puedes usar `rename_enum_value`:

```ruby
# db/migrate/20150722144915_rename_article_state.rb
def change
  rename_enum_value :article_state, from: "archived", to: "deleted"
end
```

Sugerencia: para mostrar todos los valores de todas las enumeraciones que tienes, puedes llamar a esta consulta en la consola `bin/rails db` o `psql`:

```sql
SELECT n.nspname AS enum_schema,
       t.typname AS enum_name,
       e.enumlabel AS enum_value
  FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
```

### UUID

* [definición del tipo](https://www.postgresql.org/docs/current/static/datatype-uuid.html)
* [función generadora pgcrypto](https://www.postgresql.org/docs/current/static/pgcrypto.html)
* [funciones generadoras uuid-ossp](https://www.postgresql.org/docs/current/static/uuid-ossp.html)

NOTA: Si estás utilizando PostgreSQL anterior a la versión 13.0, es posible que debas habilitar extensiones especiales para usar UUID. Habilita la extensión `pgcrypto` (PostgreSQL >= 9.4) o la extensión `uuid-ossp` (para versiones anteriores).

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

Puedes usar el tipo `uuid` para definir referencias en migraciones:

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

Consulta [esta sección](#uuid-primary-keys) para obtener más detalles sobre cómo usar UUID como clave primaria.

### Tipos de cadena de bits

* [definición del tipo](https://www.postgresql.org/docs/current/static/datatype-bit.html)
* [funciones y operadores](https://www.postgresql.org/docs/current/static/functions-bitstring.html)

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

### Tipos de dirección de red

* [definición del tipo](https://www.postgresql.org/docs/current/static/datatype-net-types.html)

Los tipos `inet` y `cidr` se asignan a objetos Ruby [`IPAddr`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ipaddr/rdoc/IPAddr.html). El tipo `macaddr` se asigna a texto normal.

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

### Tipos geométricos

* [definición del tipo](https://www.postgresql.org/docs/current/static/datatype-geometric.html)

Todos los tipos geométricos, con la excepción de los puntos, se asignan a texto normal. Un punto se convierte en una matriz que contiene las coordenadas `x` e `y`.

### Intervalo

* [definición del tipo](https://www.postgresql.org/docs/current/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
* [funciones y operadores](https://www.postgresql.org/docs/current/static/functions-datetime.html)

Este tipo se asigna a objetos [`ActiveSupport::Duration`](https://api.rubyonrails.org/classes/ActiveSupport/Duration.html).

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

Claves primarias UUID
-----------------

NOTA: Debes habilitar la extensión `pgcrypto` (solo PostgreSQL >= 9.4) o `uuid-ossp` para generar UUID aleatorios.
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

NOTA: Se asume que se utiliza `gen_random_uuid()` (de `pgcrypto`) si no se pasa la opción `:default` a `create_table`.

Para usar el generador de modelos de Rails para una tabla que utiliza UUID como clave primaria, se debe pasar `--primary-key-type=uuid` al generador de modelos.

Por ejemplo:

```bash
$ rails generate model Device --primary-key-type=uuid kind:string
```

Al construir un modelo con una clave externa que referencia a este UUID, se debe tratar `uuid` como el tipo de campo nativo, por ejemplo:

```bash
$ rails generate model Case device_id:uuid
```

Indexación
--------

* [creación de índices](https://www.postgresql.org/docs/current/sql-createindex.html)

PostgreSQL incluye una variedad de opciones de índice. Las siguientes opciones son compatibles con el adaptador de PostgreSQL además de las [opciones de índice comunes](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index).

### Include

Al crear un nuevo índice, se pueden incluir columnas que no son clave con la opción `:include`. Estas claves no se utilizan en las exploraciones de índice para la búsqueda, pero se pueden leer durante una exploración solo de índice sin tener que visitar la tabla asociada.

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id.rb

add_index :users, :email, include: :id
```

Se admiten múltiples columnas:

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id_and_created_at.rb

add_index :users, :email, include: [:id, :created_at]
```

Columnas Generadas
-----------------

NOTA: Las columnas generadas son compatibles desde la versión 12.0 de PostgreSQL.

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users do |t|
  t.string :name
  t.virtual :name_upcased, type: :string, as: 'upper(name)', stored: true
end

# app/models/user.rb
class User < ApplicationRecord
end

# Uso
user = User.create(name: 'John')
User.last.name_upcased # => "JOHN"
```

Claves Externas Deferibles
-----------------------

* [restricciones de tabla con claves externas](https://www.postgresql.org/docs/current/sql-set-constraints.html)

Por defecto, las restricciones de tabla en PostgreSQL se verifican inmediatamente después de cada declaración. No permite intencionalmente crear registros donde el registro referenciado aún no está en la tabla referenciada. Sin embargo, es posible ejecutar esta verificación de integridad más adelante cuando la transacción se confirma agregando `DEFERRABLE` a la definición de la clave externa. Para diferir todas las verificaciones de forma predeterminada, se puede establecer en `DEFERRABLE INITIALLY DEFERRED`. Rails expone esta característica de PostgreSQL agregando la clave `:deferrable` a las opciones de `foreign_key` en los métodos `add_reference` y `add_foreign_key`.

Un ejemplo de esto es crear dependencias circulares en una transacción incluso si se han creado claves externas:

```ruby
add_reference :person, :alias, foreign_key: { deferrable: :deferred }
add_reference :alias, :person, foreign_key: { deferrable: :deferred }
```

Si la referencia se creó con la opción `foreign_key: true`, la siguiente transacción fallaría al ejecutar la primera instrucción `INSERT`. Sin embargo, no falla cuando se establece la opción `deferrable: :deferred`.

```ruby
ActiveRecord::Base.connection.transaction do
  person = Person.create(id: SecureRandom.uuid, alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

Cuando la opción `:deferrable` se establece en `:immediate`, permite que las claves externas mantengan el comportamiento predeterminado de verificar la restricción inmediatamente, pero permite diferir manualmente las verificaciones utilizando `SET CONSTRAINTS ALL DEFERRED` dentro de una transacción. Esto hará que las claves externas se verifiquen cuando se confirme la transacción:

```ruby
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL DEFERRED")
  person = Person.create(alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

Por defecto, `:deferrable` es `false` y la restricción siempre se verifica inmediatamente.

Restricción Única
-----------------

* [restricciones únicas](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS)

```ruby
# db/migrate/20230422225213_create_items.rb
create_table :items do |t|
  t.integer :position, null: false
  t.unique_key [:position], deferrable: :immediate
end
```

Si se desea cambiar un índice único existente a diferible, se puede utilizar `:using_index` para crear restricciones únicas diferibles.

```ruby
add_unique_key :items, deferrable: :deferred, using_index: "index_items_on_position"
```

Al igual que las claves externas, las restricciones únicas se pueden diferir estableciendo `:deferrable` en `:immediate` o `:deferred`. Por defecto, `:deferrable` es `false` y la restricción siempre se verifica inmediatamente.

Restricciones de Exclusión
---------------------

* [restricciones de exclusión](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION)

```ruby
# db/migrate/20131220144913_create_products.rb
create_table :products do |t|
  t.integer :price, null: false
  t.daterange :availability_range, null: false

  t.exclusion_constraint "price WITH =, availability_range WITH &&", using: :gist, name: "price_check"
end
```

Al igual que las claves externas, las restricciones de exclusión se pueden diferir estableciendo `:deferrable` en `:immediate` o `:deferred`. Por defecto, `:deferrable` es `false` y la restricción siempre se verifica inmediatamente.

Búsqueda de Texto Completo
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
# Uso
Document.create(title: "Gatos y Perros", body: "son lindos!")

## todos los documentos que coinciden con 'gato y perro'
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "gato & perro")
```

Opcionalmente, puedes almacenar el vector como una columna generada automáticamente (a partir de PostgreSQL 12.0):

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body

  t.virtual :textsearchable_index_col,
            type: :tsvector, as: "to_tsvector('english', title || ' ' || body)", stored: true
end

add_index :documents, :textsearchable_index_col, using: :gin, name: 'documents_idx'

# Uso
Document.create(title: "Gatos y Perros", body: "son lindos!")

## todos los documentos que coinciden con 'gato y perro'
Document.where("textsearchable_index_col @@ to_tsquery(?)", "gato & perro")
```

Vistas de base de datos
--------------

* [creación de vistas](https://www.postgresql.org/docs/current/static/sql-createview.html)

Imagina que necesitas trabajar con una base de datos heredada que contiene la siguiente tabla:

```
rails_pg_guide=# \d "TBL_ART"
                                        Tabla "public.TBL_ART"
   Columna   |            Tipo             |                         Modificadores
------------+-----------------------------+------------------------------------------------------------
 INT_ID     | integer                     | not null default nextval('"TBL_ART_INT_ID_seq"'::regclass)
 STR_TITLE  | character varying           |
 STR_STAT   | character varying           | default 'draft'::character varying
 DT_PUBL_AT | timestamp without time zone |
 BL_ARCH    | boolean                     | default false
Índices:
    "TBL_ART_pkey" PRIMARY KEY, btree ("INT_ID")
```

Esta tabla no sigue las convenciones de Rails en absoluto.
Debido a que las vistas simples de PostgreSQL son actualizables por defecto,
podemos envolverla de la siguiente manera:

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
irb> first = Article.create! title: "Se acerca el invierno", status: "publicado", published_at: 1.año.ago
irb> second = Article.create! title: "Prepárate", status: "borrador", published_at: 1.mes.ago

irb> Article.count
=> 2
irb> first.archive!
irb> Article.count
=> 1
```

NOTA: Esta aplicación solo se preocupa por los `Artículos` no archivados. Una vista también
permite condiciones para excluir directamente los `Artículos` archivados.

Volcados de estructura
--------------

Si tu `config.active_record.schema_format` es `:sql`, Rails llamará a `pg_dump` para generar un
volcado de estructura.

Puedes usar `ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags` para configurar `pg_dump`.
Por ejemplo, para excluir comentarios de tu volcado de estructura, agrega esto a un inicializador:

```ruby
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
```
