**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9a8daf85251d1a12237dd39a65eed51a
Active Record와 PostgreSQL
============================

이 가이드는 Active Record의 PostgreSQL 특정 사용법을 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* PostgreSQL의 데이터 타입을 사용하는 방법.
* UUID 기본 키를 사용하는 방법.
* 인덱스에 비-키 열을 포함하는 방법.
* 지연 가능한 외래 키를 사용하는 방법.
* 고유 제약 조건을 사용하는 방법.
* 배제 제약 조건을 구현하는 방법.
* PostgreSQL을 사용하여 전체 텍스트 검색을 구현하는 방법.
* 데이터베이스 뷰를 사용하여 Active Record 모델을 지원하는 방법.

--------------------------------------------------------------------------------

PostgreSQL 어댑터를 사용하려면 적어도 9.3 버전 이상이 설치되어 있어야 합니다. 이전 버전은 지원되지 않습니다.

PostgreSQL을 사용하기 위해 [Rails 가이드를 설정하는 방법](configuring.html#configuring-a-postgresql-database)을 살펴보세요. 이 가이드에서는 PostgreSQL에 대해 Active Record를 올바르게 설정하는 방법을 설명합니다.

데이터 타입
---------

PostgreSQL은 여러 가지 특정 데이터 타입을 제공합니다. 다음은 PostgreSQL 어댑터에서 지원하는 타입 목록입니다.

### Bytea

* [타입 정의](https://www.postgresql.org/docs/current/static/datatype-binary.html)
* [함수 및 연산자](https://www.postgresql.org/docs/current/static/functions-binarystring.html)

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
# 사용법
data = File.read(Rails.root + "tmp/output.pdf")
Document.create payload: data
```

### Array

* [타입 정의](https://www.postgresql.org/docs/current/static/arrays.html)
* [함수 및 연산자](https://www.postgresql.org/docs/current/static/functions-array.html)

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
# 사용법
Book.create title: "Brave New World",
            tags: ["fantasy", "fiction"],
            ratings: [4, 5]

## 단일 태그에 대한 책
Book.where("'fantasy' = ANY (tags)")

## 여러 태그에 대한 책
Book.where("tags @> ARRAY[?]::varchar[]", ["fantasy", "fiction"])

## 3개 이상의 평점을 가진 책
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [타입 정의](https://www.postgresql.org/docs/current/static/hstore.html)
* [함수 및 연산자](https://www.postgresql.org/docs/current/static/hstore.html#id-1.11.7.26.5)

참고: hstore를 사용하려면 `hstore` 확장 기능을 활성화해야 합니다.

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

### JSON 및 JSONB

* [타입 정의](https://www.postgresql.org/docs/current/static/datatype-json.html)
* [함수 및 연산자](https://www.postgresql.org/docs/current/static/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
# ... json 데이터 타입의 경우:
create_table :events do |t|
  t.json 'payload'
end
# ... 또는 jsonb 데이터 타입의 경우:
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

## JSON 문서를 기반으로 쿼리
# -> 연산자는 원래의 JSON 타입(객체일 수도 있음)을 반환하며, ->>는 텍스트를 반환합니다.
irb> Event.where("payload->>'kind' = ?", "user_renamed")
```

### 범위 타입

* [타입 정의](https://www.postgresql.org/docs/current/static/rangetypes.html)
* [함수 및 연산자](https://www.postgresql.org/docs/current/static/functions-range.html)

이 타입은 Ruby [`Range`](https://ruby-doc.org/core-2.7.0/Range.html) 객체로 매핑됩니다.

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

## 특정 날짜에 대한 모든 이벤트
irb> Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## 범위 경계 처리
irb> event = Event.select("lower(duration) AS starts_at").select("upper(duration) AS ends_at").first

irb> event.starts_at
=> Tue, 11 Feb 2014
irb> event.ends_at
=> Thu, 13 Feb 2014
```

### 복합 타입

* [타입 정의](https://www.postgresql.org/docs/current/static/rowtypes.html)

현재 복합 타입에 대한 특별한 지원은 없습니다. 이들은 일반 텍스트 열로 매핑됩니다:

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

### 열거형 타입

* [타입 정의](https://www.postgresql.org/docs/current/static/datatype-enum.html)

이 타입은 일반 텍스트 열로 매핑되거나 [`ActiveRecord::Enum`](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html)으로 매핑될 수 있습니다.

```ruby
# db/migrate/20131220144913_create_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  create_table :articles do |t|
    t.enum :status, enum_type: :article_status, default: "draft", null: false
  end
end
```

기존 테이블에 열거형 타입을 만들고 열거형 열을 추가할 수도 있습니다.

```ruby
# db/migrate/20230113024409_add_status_to_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  add_column :articles, :status, :enum, enum_type: :article_status, default: "draft", null: false
end
```

위의 마이그레이션은 모두 되돌릴 수 있지만 필요한 경우 별도의 `#up` 및 `#down` 메서드를 정의할 수 있습니다. 열거형 타입에 의존하는 열 또는 테이블을 삭제하기 전에 제거해야 합니다.

```ruby
def down
  drop_table :articles

  # OR: remove_column :articles, :status
  drop_enum :article_status
end
```

모델에서 열거형 속성을 선언하면 도우미 메서드가 추가되고 잘못된 값이 클래스의 인스턴스에 할당되지 않도록 방지됩니다.

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
=> "draft" # PostgreSQL에서 정의된 기본 상태

irb> article.status_published!
irb> article.status
=> "published"

irb> article.status_archived?
=> false

irb> article.status = "deleted"
ArgumentError: 'deleted'은(는) 유효한 상태가 아닙니다.
```

열거형을 이름을 변경하려면 `rename_enum`을 사용하고 모델 사용을 업데이트해야 합니다.

```ruby
# db/migrate/20150718144917_rename_article_status.rb
def change
  rename_enum :article_status, to: :article_state
end
```

새 값을 추가하려면 `add_enum_value`를 사용할 수 있습니다.

```ruby
# db/migrate/20150720144913_add_new_state_to_articles.rb
def up
  add_enum_value :article_state, "archived", # published 뒤에 위치합니다.
  add_enum_value :article_state, "in review", before: "published"
  add_enum_value :article_state, "approved", after: "in review"
end
```

참고: 열거형 값은 삭제할 수 없으므로 `add_enum_value`는 되돌릴 수 없습니다. 자세한 내용은 [여기](https://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com)를 참조하십시오.

값의 이름을 변경하려면 `rename_enum_value`를 사용할 수 있습니다.

```ruby
# db/migrate/20150722144915_rename_article_state.rb
def change
  rename_enum_value :article_state, from: "archived", to: "deleted"
end
```

힌트: 모든 열거형의 모든 값을 표시하려면 `bin/rails db` 또는 `psql` 콘솔에서 다음 쿼리를 호출할 수 있습니다.

```sql
SELECT n.nspname AS enum_schema,
       t.typname AS enum_name,
       e.enumlabel AS enum_value
  FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
```

### UUID

* [타입 정의](https://www.postgresql.org/docs/current/static/datatype-uuid.html)
* [pgcrypto 생성 함수](https://www.postgresql.org/docs/current/static/pgcrypto.html)
* [uuid-ossp 생성 함수](https://www.postgresql.org/docs/current/static/uuid-ossp.html)

참고: PostgreSQL 13.0 이전 버전을 사용하는 경우 UUID를 사용하려면 특수한 확장 기능을 활성화해야 할 수 있습니다. `pgcrypto` 확장 기능을 활성화하십시오 (PostgreSQL >= 9.4) 또는 `uuid-ossp` 확장 기능을 활성화하십시오 (이전 버전에 대해서도).

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

마이그레이션에서 참조를 정의하기 위해 `uuid` 타입을 사용할 수 있습니다.

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

UUID를 기본 키로 사용하는 방법에 대한 자세한 내용은 [이 섹션](#uuid-primary-keys)을 참조하십시오.

### 비트 문자열 타입

* [타입 정의](https://www.postgresql.org/docs/current/static/datatype-bit.html)
* [함수 및 연산자](https://www.postgresql.org/docs/current/static/functions-bitstring.html)

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

### 네트워크 주소 유형

* [유형 정의](https://www.postgresql.org/docs/current/static/datatype-net-types.html)

`inet` 및 `cidr` 유형은 Ruby [`IPAddr`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ipaddr/rdoc/IPAddr.html) 객체로 매핑됩니다. `macaddr` 유형은 일반 텍스트로 매핑됩니다.

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

### 기하학적 유형

* [유형 정의](https://www.postgresql.org/docs/current/static/datatype-geometric.html)

`points`를 제외한 모든 기하학적 유형은 일반 텍스트로 매핑됩니다. 점은 `x` 및 `y` 좌표를 포함하는 배열로 캐스팅됩니다.

### 간격

* [유형 정의](https://www.postgresql.org/docs/current/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
* [함수 및 연산자](https://www.postgresql.org/docs/current/static/functions-datetime.html)

이 유형은 [`ActiveSupport::Duration`](https://api.rubyonrails.org/classes/ActiveSupport/Duration.html) 객체로 매핑됩니다.

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

UUID 기본 키
-----------------

참고: 무작위 UUID를 생성하려면 `pgcrypto` (PostgreSQL >= 9.4 만 해당) 또는 `uuid-ossp` 확장을 활성화해야 합니다.

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

참고: `:default` 옵션이 `create_table`에 전달되지 않은 경우 `gen_random_uuid()` (pgcrypto에서)로 가정됩니다.

UUID를 기본 키로 사용하는 테이블에 대해 Rails 모델 생성기를 사용하려면 모델 생성기에 `--primary-key-type=uuid`를 전달하십시오.

예를 들어:

```bash
$ rails generate model Device --primary-key-type=uuid kind:string
```

이 UUID를 참조하는 외래 키를 사용하여 모델을 빌드할 때 `uuid`를 기본 필드 유형으로 처리하십시오.

예:

```bash
$ rails generate model Case device_id:uuid
```

인덱싱
--------

* [인덱스 생성](https://www.postgresql.org/docs/current/sql-createindex.html)

PostgreSQL에는 다양한 인덱스 옵션이 포함되어 있습니다. 다음 옵션은 PostgreSQL 어댑터에서 [일반 인덱스 옵션](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index)과 함께 지원됩니다.

### Include

새 인덱스를 생성할 때 `:include` 옵션으로 키가 아닌 열을 포함할 수 있습니다. 이러한 키는 검색을 위한 인덱스 스캔에서 사용되지 않지만, 관련 테이블을 방문하지 않고 인덱스 전용 스캔 중에 읽을 수 있습니다.

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id.rb

add_index :users, :email, include: :id
```

여러 열을 지원합니다.

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id_and_created_at.rb

add_index :users, :email, include: [:id, :created_at]
```

생성된 열
-----------------

참고: 생성된 열은 PostgreSQL 버전 12.0부터 지원됩니다.

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users do |t|
  t.string :name
  t.virtual :name_upcased, type: :string, as: 'upper(name)', stored: true
end

# app/models/user.rb
class User < ApplicationRecord
end

# 사용법
user = User.create(name: 'John')
User.last.name_upcased # => "JOHN"
```

지연 가능한 외래 키
-----------------------

* [외래 키 테이블 제약 조건](https://www.postgresql.org/docs/current/sql-set-constraints.html)

기본적으로 PostgreSQL의 테이블 제약 조건은 각 문장 후에 즉시 확인됩니다. 이는 참조된 테이블에 참조된 레코드가 아직 없는 레코드를 생성하는 것을 허용하지 않습니다. 그러나 `DEFERRABLE`을 외래 키 정의에 추가하여 트랜잭션이 커밋될 때 이 무결성 검사를 나중에 실행할 수 있습니다. 모든 검사를 기본적으로 지연시키려면 `DEFERRABLE INITIALLY DEFERRED`로 설정할 수 있습니다. Rails는 `add_reference` 및 `add_foreign_key` 메서드의 `foreign_key` 옵션에 `:deferrable` 키를 추가하여 이 PostgreSQL 기능을 노출시킵니다.

예를 들어, 외래 키를 만들면서 트랜잭션에서 원형 종속성을 생성할 수 있습니다.

```ruby
add_reference :person, :alias, foreign_key: { deferrable: :deferred }
add_reference :alias, :person, foreign_key: { deferrable: :deferred }
```

참조가 `foreign_key: true` 옵션으로 생성된 경우 첫 번째 `INSERT` 문을 실행할 때 다음 트랜잭션은 실패합니다. 그러나 `deferrable: :deferred` 옵션이 설정된 경우 실패하지 않습니다.
```ruby
ActiveRecord::Base.connection.transaction do
  person = Person.create(id: SecureRandom.uuid, alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

`:deferrable` 옵션을 `:immediate`로 설정하면 외래 키는 제약 조건을 즉시 확인하는 기본 동작을 유지하면서 트랜잭션 내에서 수동으로 확인을 지연시킬 수 있습니다. 이렇게 하면 트랜잭션이 커밋될 때 외래 키가 확인됩니다:

```ruby
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL DEFERRED")
  person = Person.create(alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

기본적으로 `:deferrable`은 `false`이며 제약 조건은 항상 즉시 확인됩니다.

고유 제약 조건
-----------------

* [고유 제약 조건](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS)

```ruby
# db/migrate/20230422225213_create_items.rb
create_table :items do |t|
  t.integer :position, null: false
  t.unique_key [:position], deferrable: :immediate
end
```

기존의 고유 인덱스를 지연 가능하도록 변경하려면 `:using_index`를 사용하여 지연 가능한 고유 제약 조건을 생성할 수 있습니다.

```ruby
add_unique_key :items, deferrable: :deferred, using_index: "index_items_on_position"
```

외래 키와 마찬가지로 고유 제약 조건은 `:deferrable`을 `:immediate` 또는 `:deferred`로 설정하여 지연시킬 수 있습니다. 기본적으로 `:deferrable`은 `false`이며 제약 조건은 항상 즉시 확인됩니다.

배제 제약 조건
---------------------

* [배제 제약 조건](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION)

```ruby
# db/migrate/20131220144913_create_products.rb
create_table :products do |t|
  t.integer :price, null: false
  t.daterange :availability_range, null: false

  t.exclusion_constraint "price WITH =, availability_range WITH &&", using: :gist, name: "price_check"
end
```

외래 키와 마찬가지로 배제 제약 조건은 `:deferrable`을 `:immediate` 또는 `:deferred`로 설정하여 지연시킬 수 있습니다. 기본적으로 `:deferrable`은 `false`이며 제약 조건은 항상 즉시 확인됩니다.

전체 텍스트 검색
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
# 사용법
Document.create(title: "Cats and Dogs", body: "are nice!")

## 'cat & dog'와 일치하는 모든 문서
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "cat & dog")
```

선택적으로, PostgreSQL 12.0부터 자동으로 생성된 열로 벡터를 저장할 수 있습니다:

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body

  t.virtual :textsearchable_index_col,
            type: :tsvector, as: "to_tsvector('english', title || ' ' || body)", stored: true
end

add_index :documents, :textsearchable_index_col, using: :gin, name: 'documents_idx'

# 사용법
Document.create(title: "Cats and Dogs", body: "are nice!")

## 'cat & dog'와 일치하는 모든 문서
Document.where("textsearchable_index_col @@ to_tsquery(?)", "cat & dog")
```

데이터베이스 뷰
--------------

* [뷰 생성](https://www.postgresql.org/docs/current/static/sql-createview.html)

다음과 같은 테이블이 포함된 레거시 데이터베이스에서 작업해야 한다고 가정해보십시오:

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

이 테이블은 전혀 Rails 규칙을 따르지 않습니다. 간단한 PostgreSQL 뷰는 기본적으로 업데이트 가능하므로 다음과 같이 래핑할 수 있습니다:

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

참고: 이 애플리케이션은 아카이브되지 않은 `Articles`에만 관심이 있습니다. 뷰는 조건을 설정하여 아카이브된 `Articles`를 직접 제외할 수도 있습니다.

구조 덤프
--------------

`config.active_record.schema_format`이 `:sql`인 경우 Rails는 구조 덤프를 생성하기 위해 `pg_dump`를 호출합니다.
`ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags`를 사용하여 `pg_dump`를 구성할 수 있습니다.
예를 들어, 구조 덤프에서 주석을 제외하려면 다음을 초기화 파일에 추가하십시오:

```ruby
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
```
