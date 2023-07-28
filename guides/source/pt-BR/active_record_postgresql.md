**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9a8daf85251d1a12237dd39a65eed51a
Active Record e PostgreSQL
============================

Este guia aborda o uso específico do Active Record com o PostgreSQL.

Após ler este guia, você saberá:

* Como usar os tipos de dados do PostgreSQL.
* Como usar chaves primárias UUID.
* Como incluir colunas não-chave em índices.
* Como usar chaves estrangeiras adiáveis.
* Como usar restrições únicas.
* Como implementar restrições de exclusão.
* Como implementar busca em texto completo com o PostgreSQL.
* Como usar visualizações de banco de dados para respaldar seus modelos do Active Record.

--------------------------------------------------------------------------------

Para usar o adaptador do PostgreSQL, você precisa ter pelo menos a versão 9.3 instalada. Versões mais antigas não são suportadas.

Para começar com o PostgreSQL, dê uma olhada no [guia de configuração do Rails](configuring.html#configuring-a-postgresql-database). Ele descreve como configurar corretamente o Active Record para o PostgreSQL.

Tipos de dados
--------------

O PostgreSQL oferece uma série de tipos de dados específicos. A seguir está uma lista de tipos suportados pelo adaptador do PostgreSQL.

### Bytea

* [definição do tipo](https://www.postgresql.org/docs/current/static/datatype-binary.html)
* [funções e operadores](https://www.postgresql.org/docs/current/static/functions-binarystring.html)

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

* [definição do tipo](https://www.postgresql.org/docs/current/static/arrays.html)
* [funções e operadores](https://www.postgresql.org/docs/current/static/functions-array.html)

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

## Livros para uma única tag
Book.where("'fantasy' = ANY (tags)")

## Livros para várias tags
Book.where("tags @> ARRAY[?]::varchar[]", ["fantasy", "fiction"])

## Livros com 3 ou mais avaliações
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [definição do tipo](https://www.postgresql.org/docs/current/static/hstore.html)
* [funções e operadores](https://www.postgresql.org/docs/current/static/hstore.html#id-1.11.7.26.5)

NOTA: Você precisa habilitar a extensão `hstore` para usar o hstore.

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

### JSON e JSONB

* [definição do tipo](https://www.postgresql.org/docs/current/static/datatype-json.html)
* [funções e operadores](https://www.postgresql.org/docs/current/static/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
# ... para o tipo de dados json:
create_table :events do |t|
  t.json 'payload'
end
# ... ou para o tipo de dados jsonb:
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

## Consulta baseada em documento JSON
# O operador -> retorna o tipo JSON original (que pode ser um objeto), enquanto ->> retorna texto
irb> Event.where("payload->>'kind' = ?", "user_renamed")
```

### Tipos de Intervalo

* [definição do tipo](https://www.postgresql.org/docs/current/static/rangetypes.html)
* [funções e operadores](https://www.postgresql.org/docs/current/static/functions-range.html)

Este tipo é mapeado para objetos [`Range`](https://ruby-doc.org/core-2.7.0/Range.html) do Ruby.

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

## Todos os eventos em uma determinada data
irb> Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## Trabalhando com limites de intervalo
irb> event = Event.select("lower(duration) AS starts_at").select("upper(duration) AS ends_at").first

irb> event.starts_at
=> Tue, 11 Feb 2014
irb> event.ends_at
=> Thu, 13 Feb 2014
```

### Tipos Compostos

* [definição do tipo](https://www.postgresql.org/docs/current/static/rowtypes.html)

Atualmente, não há suporte especial para tipos compostos. Eles são mapeados para colunas de texto normais:

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

### Tipos Enumerados

* [definição do tipo](https://www.postgresql.org/docs/current/static/datatype-enum.html)

O tipo pode ser mapeado como uma coluna de texto normal ou para um [`ActiveRecord::Enum`](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

```ruby
# db/migrate/20131220144913_create_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  create_table :articles do |t|
    t.enum :status, enum_type: :article_status, default: "draft", null: false
  end
end
```

Você também pode criar um tipo enum e adicionar uma coluna enum a uma tabela existente:

```ruby
# db/migrate/20230113024409_add_status_to_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  add_column :articles, :status, :enum, enum_type: :article_status, default: "draft", null: false
end
```

As migrações acima são reversíveis, mas você pode definir métodos separados `#up` e `#down` se necessário. Certifique-se de remover quaisquer colunas ou tabelas que dependam do tipo enum antes de removê-lo:

```ruby
def down
  drop_table :articles

  # OU: remove_column :articles, :status
  drop_enum :article_status
end
```

A declaração de um atributo enum no modelo adiciona métodos auxiliares e impede que valores inválidos sejam atribuídos às instâncias da classe:

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
=> "draft" # status padrão do PostgreSQL, conforme definido na migração acima

irb> article.status_published!
irb> article.status
=> "published"

irb> article.status_archived?
=> false

irb> article.status = "deleted"
ArgumentError: 'deleted' não é um status válido
```

Para renomear o enum, você pode usar `rename_enum` juntamente com a atualização de qualquer uso do modelo:

```ruby
# db/migrate/20150718144917_rename_article_status.rb
def change
  rename_enum :article_status, to: :article_state
end
```

Para adicionar um novo valor, você pode usar `add_enum_value`:

```ruby
# db/migrate/20150720144913_add_new_state_to_articles.rb
def up
  add_enum_value :article_state, "archived", # será colocado no final após published
  add_enum_value :article_state, "in review", before: "published"
  add_enum_value :article_state, "approved", after: "in review"
end
```

NOTA: Os valores do enum não podem ser removidos, o que também significa que `add_enum_value` é irreversível. Você pode ler o motivo [aqui](https://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com).

Para renomear um valor, você pode usar `rename_enum_value`:

```ruby
# db/migrate/20150722144915_rename_article_state.rb
def change
  rename_enum_value :article_state, from: "archived", to: "deleted"
end
```

Dica: para mostrar todos os valores de todos os enums que você possui, você pode executar esta consulta no console `bin/rails db` ou `psql`:

```sql
SELECT n.nspname AS enum_schema,
       t.typname AS enum_name,
       e.enumlabel AS enum_value
  FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
```

### UUID

* [definição do tipo](https://www.postgresql.org/docs/current/static/datatype-uuid.html)
* [função geradora pgcrypto](https://www.postgresql.org/docs/current/static/pgcrypto.html)
* [funções geradoras uuid-ossp](https://www.postgresql.org/docs/current/static/uuid-ossp.html)

NOTA: Se você estiver usando o PostgreSQL anterior à versão 13.0, talvez seja necessário habilitar extensões especiais para usar UUIDs. Habilite a extensão `pgcrypto` (PostgreSQL >= 9.4) ou a extensão `uuid-ossp` (para versões anteriores).

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

Você pode usar o tipo `uuid` para definir referências em migrações:

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

Consulte [esta seção](#uuid-primary-keys) para obter mais detalhes sobre o uso de UUIDs como chave primária.

### Tipos de Bit String

* [definição do tipo](https://www.postgresql.org/docs/current/static/datatype-bit.html)
* [funções e operadores](https://www.postgresql.org/docs/current/static/functions-bitstring.html)

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

### Tipos de Endereço de Rede

* [definição do tipo](https://www.postgresql.org/docs/current/static/datatype-net-types.html)

Os tipos `inet` e `cidr` são mapeados para objetos Ruby [`IPAddr`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ipaddr/rdoc/IPAddr.html). O tipo `macaddr` é mapeado para texto normal.

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

### Tipos Geométricos

* [definição do tipo](https://www.postgresql.org/docs/current/static/datatype-geometric.html)

Todos os tipos geométricos, com exceção de `points`, são mapeados para texto normal. Um ponto é convertido em uma matriz contendo as coordenadas `x` e `y`.

### Intervalo

* [definição do tipo](https://www.postgresql.org/docs/current/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
* [funções e operadores](https://www.postgresql.org/docs/current/static/functions-datetime.html)

Este tipo é mapeado para objetos [`ActiveSupport::Duration`](https://api.rubyonrails.org/classes/ActiveSupport/Duration.html).

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

Chaves Primárias UUID
---------------------

NOTA: Você precisa habilitar a extensão `pgcrypto` (apenas PostgreSQL >= 9.4) ou `uuid-ossp` para gerar UUIDs aleatórios.
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

NOTA: `gen_random_uuid()` (de `pgcrypto`) é assumido se nenhuma opção `:default` foi passada para `create_table`.

Para usar o gerador de modelo do Rails para uma tabela usando UUID como chave primária, passe `--primary-key-type=uuid` para o gerador de modelo.

Por exemplo:

```bash
$ rails generate model Device --primary-key-type=uuid kind:string
```

Ao criar um modelo com uma chave estrangeira que fará referência a este UUID, trate `uuid` como o tipo de campo nativo, por exemplo:

```bash
$ rails generate model Case device_id:uuid
```

Indexação
--------

* [criação de índice](https://www.postgresql.org/docs/current/sql-createindex.html)

O PostgreSQL inclui uma variedade de opções de índice. As seguintes opções são suportadas pelo adaptador PostgreSQL, além das [opções comuns de índice](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index)

### Include

Ao criar um novo índice, colunas não-chave podem ser incluídas com a opção `:include`. Essas chaves não são usadas em varreduras de índice para pesquisa, mas podem ser lidas durante uma varredura somente de índice sem precisar visitar a tabela associada.

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id.rb

add_index :users, :email, include: :id
```

Múltiplas colunas são suportadas:

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id_and_created_at.rb

add_index :users, :email, include: [:id, :created_at]
```

Colunas Geradas
-----------------

NOTA: Colunas geradas são suportadas desde a versão 12.0 do PostgreSQL.

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

Chaves Estrangeiras Adiáveis
-----------------------

* [restrições de tabela de chave estrangeira](https://www.postgresql.org/docs/current/sql-set-constraints.html)

Por padrão, as restrições de tabela no PostgreSQL são verificadas imediatamente após cada instrução. Intencionalmente, não permite criar registros em que o registro referenciado ainda não esteja na tabela referenciada. É possível executar essa verificação de integridade posteriormente, quando a transação é confirmada, adicionando `DEFERRABLE` à definição da chave estrangeira. Para adiar todas as verificações por padrão, pode ser definido como `DEFERRABLE INITIALLY DEFERRED`. O Rails expõe esse recurso do PostgreSQL adicionando a chave `:deferrable` às opções `foreign_key` nos métodos `add_reference` e `add_foreign_key`.

Um exemplo disso é criar dependências circulares em uma transação, mesmo se você tiver criado chaves estrangeiras:

```ruby
add_reference :person, :alias, foreign_key: { deferrable: :deferred }
add_reference :alias, :person, foreign_key: { deferrable: :deferred }
```

Se a referência foi criada com a opção `foreign_key: true`, a seguinte transação falharia ao executar a primeira instrução `INSERT`. No entanto, não falha quando a opção `deferrable: :deferred` é definida.

```ruby
ActiveRecord::Base.connection.transaction do
  person = Person.create(id: SecureRandom.uuid, alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

Quando a opção `:deferrable` é definida como `:immediate`, permite que as chaves estrangeiras mantenham o comportamento padrão de verificar a restrição imediatamente, mas permite adiar manualmente as verificações usando `SET CONSTRAINTS ALL DEFERRED` dentro de uma transação. Isso fará com que as chaves estrangeiras sejam verificadas quando a transação for confirmada:

```ruby
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL DEFERRED")
  person = Person.create(alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

Por padrão, `:deferrable` é `false` e a restrição é sempre verificada imediatamente.

Restrição Única
-----------------

* [restrições únicas](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS)

```ruby
# db/migrate/20230422225213_create_items.rb
create_table :items do |t|
  t.integer :position, null: false
  t.unique_key [:position], deferrable: :immediate
end
```

Se você deseja alterar um índice único existente para adiável, pode usar `:using_index` para criar restrições únicas adiáveis.

```ruby
add_unique_key :items, deferrable: :deferred, using_index: "index_items_on_position"
```

Assim como as chaves estrangeiras, as restrições únicas podem ser adiadas definindo `:deferrable` como `:immediate` ou `:deferred`. Por padrão, `:deferrable` é `false` e a restrição é sempre verificada imediatamente.

Restrições de Exclusão
---------------------

* [restrições de exclusão](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION)

```ruby
# db/migrate/20131220144913_create_products.rb
create_table :products do |t|
  t.integer :price, null: false
  t.daterange :availability_range, null: false

  t.exclusion_constraint "price WITH =, availability_range WITH &&", using: :gist, name: "price_check"
end
```

Assim como as chaves estrangeiras, as restrições de exclusão podem ser adiadas definindo `:deferrable` como `:immediate` ou `:deferred`. Por padrão, `:deferrable` é `false` e a restrição é sempre verificada imediatamente.

Pesquisa de Texto Completo
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
Document.create(title: "Gatos e Cachorros", body: "são legais!")

## todos os documentos que correspondem a 'gato & cachorro'
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "gato & cachorro")
```

Opcionalmente, você pode armazenar o vetor como uma coluna gerada automaticamente (a partir do PostgreSQL 12.0):

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
Document.create(title: "Gatos e Cachorros", body: "são legais!")

## todos os documentos que correspondem a 'gato & cachorro'
Document.where("textsearchable_index_col @@ to_tsquery(?)", "gato & cachorro")
```

Visualizações de Banco de Dados
--------------

* [criação de visualização](https://www.postgresql.org/docs/current/static/sql-createview.html)

Imagine que você precise trabalhar com um banco de dados legado que contenha a seguinte tabela:

```
rails_pg_guide=# \d "TBL_ART"
                                        Tabela "public.TBL_ART"
   Coluna    |            Tipo             |                         Modificadores
------------+-----------------------------+------------------------------------------------------------
 INT_ID     | integer                     | not null default nextval('"TBL_ART_INT_ID_seq"'::regclass)
 STR_TITLE  | character varying           |
 STR_STAT   | character varying           | default 'draft'::character varying
 DT_PUBL_AT | timestamp without time zone |
 BL_ARCH    | boolean                     | default false
Índices:
    "TBL_ART_pkey" PRIMARY KEY, btree ("INT_ID")
```

Essa tabela não segue as convenções do Rails.
Como as visualizações simples do PostgreSQL são atualizáveis por padrão,
podemos envolvê-la da seguinte maneira:

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
irb> first = Article.create! title: "O inverno está chegando", status: "publicado", published_at: 1.ano.atras
irb> second = Article.create! title: "Prepare-se", status: "rascunho", published_at: 1.mês.atras

irb> Article.count
=> 2
irb> first.archive!
irb> Article.count
=> 1
```

NOTA: Esta aplicação só se preocupa com `Artigos` não arquivados. Uma visualização também
permite condições para que possamos excluir diretamente os `Artigos` arquivados.

Despejos de Estrutura
--------------

Se o `config.active_record.schema_format` for `:sql`, o Rails chamará `pg_dump` para gerar um
despejo de estrutura.

Você pode usar `ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags` para configurar o `pg_dump`.
Por exemplo, para excluir comentários do despejo de estrutura, adicione isso a um inicializador:

```ruby
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
```
