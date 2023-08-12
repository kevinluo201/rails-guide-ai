**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9a8daf85251d1a12237dd39a65eed51a
Active RecordとPostgreSQL
============================

このガイドでは、Active RecordのPostgreSQL固有の使用方法について説明します。

このガイドを読み終えると、以下のことがわかります。

* PostgreSQLのデータ型の使用方法
* UUIDプライマリキーの使用方法
* インデックスに非キーカラムを含める方法
* 遅延可能な外部キーの使用方法
* 一意制約の使用方法
* 排他制約の実装方法
* PostgreSQLを使用した全文検索の実装方法
* Active Recordモデルをデータベースビューでバックアップする方法

--------------------------------------------------------------------------------

PostgreSQLアダプタを使用するには、少なくともバージョン9.3が必要です。古いバージョンはサポートされていません。

PostgreSQLを使用するための準備は、[Railsガイドの設定](configuring.html#configuring-a-postgresql-database)を参照してください。これには、Active RecordをPostgreSQLに適切に設定する方法が記載されています。

データ型
---------

PostgreSQLにはいくつかの特定のデータ型があります。以下は、PostgreSQLアダプタでサポートされているタイプのリストです。

### Bytea

* [タイプの定義](https://www.postgresql.org/docs/current/static/datatype-binary.html)
* [関数と演算子](https://www.postgresql.org/docs/current/static/functions-binarystring.html)

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
# 使用方法
data = File.read(Rails.root + "tmp/output.pdf")
Document.create payload: data
```

### 配列

* [タイプの定義](https://www.postgresql.org/docs/current/static/arrays.html)
* [関数と演算子](https://www.postgresql.org/docs/current/static/functions-array.html)

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
# 使用方法
Book.create title: "Brave New World",
            tags: ["fantasy", "fiction"],
            ratings: [4, 5]

## 単一のタグに関連する本
Book.where("'fantasy' = ANY (tags)")

## 複数のタグに関連する本
Book.where("tags @> ARRAY[?]::varchar[]", ["fantasy", "fiction"])

## 評価が3以上の本
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [タイプの定義](https://www.postgresql.org/docs/current/static/hstore.html)
* [関数と演算子](https://www.postgresql.org/docs/current/static/hstore.html#id-1.11.7.26.5)

注意: hstoreを使用するには、`hstore`拡張機能を有効にする必要があります。

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

### JSONとJSONB

* [タイプの定義](https://www.postgresql.org/docs/current/static/datatype-json.html)
* [関数と演算子](https://www.postgresql.org/docs/current/static/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
# ... for json datatype:
create_table :events do |t|
  t.json 'payload'
end
# ... or for jsonb datatype:
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

## JSONドキュメントに基づくクエリ
# ->演算子は元のJSON型（オブジェクトである場合があります）を返し、->>はテキストを返します
irb> Event.where("payload->>'kind' = ?", "user_renamed")
```

### 範囲型

* [タイプの定義](https://www.postgresql.org/docs/current/static/rangetypes.html)
* [関数と演算子](https://www.postgresql.org/docs/current/static/functions-range.html)

このタイプは、Rubyの[`Range`](https://ruby-doc.org/core-2.7.0/Range.html)オブジェクトにマップされます。

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

## 特定の日付のすべてのイベント
irb> Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## 範囲の境界値を使用する
irb> event = Event.select("lower(duration) AS starts_at").select("upper(duration) AS ends_at").first

irb> event.starts_at
=> Tue, 11 Feb 2014
irb> event.ends_at
=> Thu, 13 Feb 2014
```

### 複合型

* [タイプの定義](https://www.postgresql.org/docs/current/static/rowtypes.html)

現在、複合型に対する特別なサポートはありません。これらは通常のテキスト列にマップされます。

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

### 列挙型

* [型の定義](https://www.postgresql.org/docs/current/static/datatype-enum.html)

この型は通常のテキスト列としてマッピングすることもできますし、[`ActiveRecord::Enum`](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html)にマッピングすることもできます。

```ruby
# db/migrate/20131220144913_create_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  create_table :articles do |t|
    t.enum :status, enum_type: :article_status, default: "draft", null: false
  end
end
```

既存のテーブルに列挙型を作成し、列挙型の列を追加することもできます。

```ruby
# db/migrate/20230113024409_add_status_to_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  add_column :articles, :status, :enum, enum_type: :article_status, default: "draft", null: false
end
```

上記のマイグレーションはどちらも逆に実行することができますが、必要に応じて別々の `#up` メソッドと `#down` メソッドを定義することもできます。列挙型に依存する列やテーブルを削除する前に、列挙型を削除してください。

```ruby
def down
  drop_table :articles

  # OR: remove_column :articles, :status
  drop_enum :article_status
end
```

モデルで列挙属性を宣言すると、ヘルパーメソッドが追加され、クラスのインスタンスに無効な値が割り当てられないようになります。

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
=> "draft" # マイグレーションで定義されたデフォルトのステータス

irb> article.status_published!
irb> article.status
=> "published"

irb> article.status_archived?
=> false

irb> article.status = "deleted"
ArgumentError: 'deleted' は有効なステータスではありません
```

列挙型の名前を変更するには、`rename_enum` を使用し、モデルの使用方法も更新してください。

```ruby
# db/migrate/20150718144917_rename_article_status.rb
def change
  rename_enum :article_status, to: :article_state
end
```

新しい値を追加するには、`add_enum_value` を使用します。

```ruby
# db/migrate/20150720144913_add_new_state_to_articles.rb
def up
  add_enum_value :article_state, "archived", # "published" の後に追加されます
  add_enum_value :article_state, "in review", before: "published"
  add_enum_value :article_state, "approved", after: "in review"
end
```

注意: 列挙値は削除できないため、`add_enum_value` は元に戻すことができません。詳細については、[こちら](https://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com)を参照してください。

値の名前を変更するには、`rename_enum_value` を使用します。

```ruby
# db/migrate/20150722144915_rename_article_state.rb
def change
  rename_enum_value :article_state, from: "archived", to: "deleted"
end
```

ヒント: すべての列挙型の値を表示するには、`bin/rails db` または `psql` コンソールで次のクエリを実行します。

```sql
SELECT n.nspname AS enum_schema,
       t.typname AS enum_name,
       e.enumlabel AS enum_value
  FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
```

### UUID

* [型の定義](https://www.postgresql.org/docs/current/static/datatype-uuid.html)
* [pgcrypto ジェネレータ関数](https://www.postgresql.org/docs/current/static/pgcrypto.html)
* [uuid-ossp ジェネレータ関数](https://www.postgresql.org/docs/current/static/uuid-ossp.html)

注意: PostgreSQL のバージョン 13.0 より前を使用している場合、UUID を使用するために特別な拡張機能を有効にする必要がある場合があります。`pgcrypto` 拡張機能 (PostgreSQL >= 9.4) または `uuid-ossp` 拡張機能 (それ以前のリリース用) を有効にしてください。

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

マイグレーションで参照を定義するために `uuid` 型を使用することもできます。

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

UUID を主キーとして使用する詳細については、[このセクション](#uuid-primary-keys)を参照してください。

### ビット文字列型

* [型の定義](https://www.postgresql.org/docs/current/static/datatype-bit.html)
* [関数と演算子](https://www.postgresql.org/docs/current/static/functions-bitstring.html)

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

### ネットワークアドレスの種類

* [型の定義](https://www.postgresql.org/docs/current/static/datatype-net-types.html)

`inet` と `cidr` の型は Ruby の [`IPAddr`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ipaddr/rdoc/IPAddr.html) オブジェクトにマッピングされます。`macaddr` 型は通常のテキストにマッピングされます。

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

### 幾何学的な型

* [型の定義](https://www.postgresql.org/docs/current/static/datatype-geometric.html)

`points` を除くすべての幾何学的な型は通常のテキストにマッピングされます。ポイントは `x` と `y` 座標を含む配列にキャストされます。

### インターバル

* [型の定義](https://www.postgresql.org/docs/current/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
* [関数と演算子](https://www.postgresql.org/docs/current/static/functions-datetime.html)

この型は [`ActiveSupport::Duration`](https://api.rubyonrails.org/classes/ActiveSupport/Duration.html) オブジェクトにマッピングされます。

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

UUID プライマリキー
-----------------

注意: ランダムな UUID を生成するには、`pgcrypto` (PostgreSQL >= 9.4 のみ) または `uuid-ossp` 拡張機能を有効にする必要があります。

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

注意: `create_table` に `:default` オプションが渡されなかった場合、`gen_random_uuid()` (`pgcrypto` から) が使用されることを想定しています。

UUID をプライマリキーとして使用するテーブルのモデルジェネレータを使用するには、モデルジェネレータに `--primary-key-type=uuid` を渡します。

例:

```bash
$ rails generate model Device --primary-key-type=uuid kind:string
```

この UUID を参照する外部キーを持つモデルを作成する場合、`uuid` をネイティブのフィールドタイプとして扱います。

例:

```bash
$ rails generate model Case device_id:uuid
```

インデックスの作成
--------

* [インデックスの作成](https://www.postgresql.org/docs/current/sql-createindex.html)

PostgreSQL にはさまざまなインデックスオプションがあります。以下のオプションは、PostgreSQL アダプタによってサポートされています。また、[一般的なインデックスオプション](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index)に加えて、`:include` オプションもサポートされています。

### Include

新しいインデックスを作成する際、キー以外の列を `:include` オプションで含めることができます。これらのキーは検索のためのインデックススキャンでは使用されませんが、関連するテーブルを訪問せずにインデックスのみのスキャン中に読み取ることができます。

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id.rb

add_index :users, :email, include: :id
```

複数の列もサポートされています。

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id_and_created_at.rb

add_index :users, :email, include: [:id, :created_at]
```

生成されたカラム
-----------------

注意: 生成されたカラムは PostgreSQL のバージョン 12.0 以降でサポートされています。

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users do |t|
  t.string :name
  t.virtual :name_upcased, type: :string, as: 'upper(name)', stored: true
end

# app/models/user.rb
class User < ApplicationRecord
end

# 使用方法
user = User.create(name: 'John')
User.last.name_upcased # => "JOHN"
```

延期可能な外部キー
-----------------------

* [外部キーテーブル制約](https://www.postgresql.org/docs/current/sql-set-constraints.html)

デフォルトでは、PostgreSQL のテーブル制約は各ステートメントの直後にチェックされます。これにより、参照されるテーブルにまだ参照されるレコードが存在しないレコードを作成することは意図的に許可されません。ただし、`DEFERRABLE` を外部キーの定義に追加することで、この整合性チェックをトランザクションがコミットされる時点で遅延させることができます。デフォルトですべてのチェックを遅延させるには、`DEFERRABLE INITIALLY DEFERRED` に設定することができます。Rails は `add_reference` メソッドと `add_foreign_key` メソッドの `foreign_key` オプションに `:deferrable` キーを追加することで、この PostgreSQL の機能を公開しています。

例として、外部キーを作成してもトランザクション内で循環参照を作成する場合を考えてみましょう。外部キーが作成されている場合、次のトランザクションは最初の `INSERT` ステートメントを実行する際に失敗します。ただし、`deferrable: :deferred` オプションが設定されている場合は失敗しません。
```ruby
ActiveRecord::Base.connection.transaction do
  person = Person.create(id: SecureRandom.uuid, alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

`:deferrable`オプションが`:immediate`に設定されている場合、外部キーはデフォルトの動作で制約をすぐにチェックするようにしますが、トランザクション内で`SET CONSTRAINTS ALL DEFERRED`を使用して手動でチェックを遅延させることができます。これにより、トランザクションがコミットされるときに外部キーがチェックされます。

```ruby
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL DEFERRED")
  person = Person.create(alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

デフォルトでは、`:deferrable`は`false`であり、制約は常にすぐにチェックされます。

一意制約
-----------------

* [一意制約](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS)

```ruby
# db/migrate/20230422225213_create_items.rb
create_table :items do |t|
  t.integer :position, null: false
  t.unique_key [:position], deferrable: :immediate
end
```

既存の一意なインデックスを遅延可能に変更する場合は、`using_index`を使用して遅延可能な一意制約を作成できます。

```ruby
add_unique_key :items, deferrable: :deferred, using_index: "index_items_on_position"
```

外部キーと同様に、一意制約は`:deferrable`を`:immediate`または`:deferred`に設定することで遅延させることができます。デフォルトでは、`:deferrable`は`false`であり、制約は常にすぐにチェックされます。

除外制約
---------------------

* [除外制約](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION)

```ruby
# db/migrate/20131220144913_create_products.rb
create_table :products do |t|
  t.integer :price, null: false
  t.daterange :availability_range, null: false

  t.exclusion_constraint "price WITH =, availability_range WITH &&", using: :gist, name: "price_check"
end
```

外部キーと同様に、除外制約は`:deferrable`を`:immediate`または`:deferred`に設定することで遅延させることができます。デフォルトでは、`:deferrable`は`false`であり、制約は常にすぐにチェックされます。

全文検索
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

オプションで、ベクトルを自動生成されたカラムとして保存することもできます（PostgreSQL 12.0以降）。

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

データベースビュー
--------------

* [ビューの作成](https://www.postgresql.org/docs/current/static/sql-createview.html)

次のテーブルを含むレガシーデータベースで作業する必要があると想像してください。

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

このテーブルはRailsの規則に全く従っていません。
単純なPostgreSQLビューはデフォルトで更新可能なため、次のようにラップできます。

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

注意：このアプリケーションはアーカイブされていない`Articles`にのみ関心があります。ビューはまた、アーカイブされた`Articles`を直接除外するための条件を設定することもできます。

構造ダンプ
--------------

`config.active_record.schema_format`が`:sql`の場合、Railsは構造ダンプを生成するために`pg_dump`を呼び出します。
`ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags`を使用して、`pg_dump`を設定できます。
たとえば、構造ダンプからコメントを除外するには、次のようにイニシャライザに追加します：

```ruby
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
```
