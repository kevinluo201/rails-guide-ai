**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9a8daf85251d1a12237dd39a65eed51a
Active Record和PostgreSQL
============================

本指南介绍了Active Record在PostgreSQL中的特定用法。

阅读本指南后，您将了解：

* 如何使用PostgreSQL的数据类型。
* 如何使用UUID主键。
* 如何在索引中包含非键列。
* 如何使用可延迟的外键。
* 如何使用唯一约束。
* 如何实现排除约束。
* 如何在PostgreSQL中实现全文搜索。
* 如何使用数据库视图支持Active Record模型。

--------------------------------------------------------------------------------

要使用PostgreSQL适配器，您需要安装至少9.3版本。不支持旧版本。

要开始使用PostgreSQL，请查看
[配置Rails指南](configuring.html#configuring-a-postgresql-database)。
它描述了如何正确设置Active Record以使用PostgreSQL。

数据类型
---------

PostgreSQL提供了许多特定的数据类型。以下是PostgreSQL适配器支持的类型列表。

### Bytea

* [类型定义](https://www.postgresql.org/docs/current/static/datatype-binary.html)
* [函数和操作符](https://www.postgresql.org/docs/current/static/functions-binarystring.html)

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
# 用法
data = File.read(Rails.root + "tmp/output.pdf")
Document.create payload: data
```

### 数组

* [类型定义](https://www.postgresql.org/docs/current/static/arrays.html)
* [函数和操作符](https://www.postgresql.org/docs/current/static/functions-array.html)

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
# 用法
Book.create title: "Brave New World",
            tags: ["fantasy", "fiction"],
            ratings: [4, 5]

## 单个标签的书籍
Book.where("'fantasy' = ANY (tags)")

## 多个标签的书籍
Book.where("tags @> ARRAY[?]::varchar[]", ["fantasy", "fiction"])

## 有3个或更多评级的书籍
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [类型定义](https://www.postgresql.org/docs/current/static/hstore.html)
* [函数和操作符](https://www.postgresql.org/docs/current/static/hstore.html#id-1.11.7.26.5)

注意：您需要启用`hstore`扩展来使用hstore。

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

### JSON和JSONB

* [类型定义](https://www.postgresql.org/docs/current/static/datatype-json.html)
* [函数和操作符](https://www.postgresql.org/docs/current/static/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
# ... for json数据类型：
create_table :events do |t|
  t.json 'payload'
end
# ... 或者 for jsonb数据类型：
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

## 基于JSON文档的查询
# ->操作符返回原始的JSON类型（可能是对象），而->>返回文本
irb> Event.where("payload->>'kind' = ?", "user_renamed")
```

### 范围类型

* [类型定义](https://www.postgresql.org/docs/current/static/rangetypes.html)
* [函数和操作符](https://www.postgresql.org/docs/current/static/functions-range.html)

此类型映射到Ruby的[`Range`](https://ruby-doc.org/core-2.7.0/Range.html)对象。

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

## 给定日期的所有事件
irb> Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## 使用范围边界
irb> event = Event.select("lower(duration) AS starts_at").select("upper(duration) AS ends_at").first

irb> event.starts_at
=> Tue, 11 Feb 2014
irb> event.ends_at
=> Thu, 13 Feb 2014
```

### 复合类型

* [类型定义](https://www.postgresql.org/docs/current/static/rowtypes.html)

目前没有对复合类型提供特殊支持。它们被映射为普通的文本列：

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

### 枚举类型

* [类型定义](https://www.postgresql.org/docs/current/static/datatype-enum.html)

该类型可以映射为普通的文本列，或者映射为[`ActiveRecord::Enum`](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html)。

```ruby
# db/migrate/20131220144913_create_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  create_table :articles do |t|
    t.enum :status, enum_type: :article_status, default: "draft", null: false
  end
end
```
您还可以创建枚举类型并向现有表添加枚举列：

```ruby
# db/migrate/20230113024409_add_status_to_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  add_column :articles, :status, :enum, enum_type: :article_status, default: "draft", null: false
end
```

上述迁移都是可逆的，但如果需要，您可以定义单独的`#up`和`#down`方法。在删除枚举类型之前，请确保删除依赖于该枚举类型的任何列或表：

```ruby
def down
  drop_table :articles

  # OR: remove_column :articles, :status
  drop_enum :article_status
end
```

在模型中声明枚举属性会添加辅助方法，并防止将无效值分配给类的实例：

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
=> "draft" # 默认状态来自 PostgreSQL，如上面的迁移中定义的

irb> article.status_published!
irb> article.status
=> "published"

irb> article.status_archived?
=> false

irb> article.status = "deleted"
ArgumentError: 'deleted' 不是一个有效的状态
```

要重命名枚举，可以使用`rename_enum`，并更新任何模型使用：

```ruby
# db/migrate/20150718144917_rename_article_status.rb
def change
  rename_enum :article_status, to: :article_state
end
```

要添加新值，可以使用`add_enum_value`：

```ruby
# db/migrate/20150720144913_add_new_state_to_articles.rb
def up
  add_enum_value :article_state, "archived", # 在 published 之后
  add_enum_value :article_state, "in review", before: "published"
  add_enum_value :article_state, "approved", after: "in review"
end
```

注意：无法删除枚举值，这也意味着`add_enum_value`是不可逆的。您可以在[这里](https://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com)了解原因。

要重命名值，可以使用`rename_enum_value`：

```ruby
# db/migrate/20150722144915_rename_article_state.rb
def change
  rename_enum_value :article_state, from: "archived", to: "deleted"
end
```

提示：要显示所有枚举值，可以在`bin/rails db`或`psql`控制台中调用此查询：

```sql
SELECT n.nspname AS enum_schema,
       t.typname AS enum_name,
       e.enumlabel AS enum_value
  FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
```

### UUID

* [类型定义](https://www.postgresql.org/docs/current/static/datatype-uuid.html)
* [pgcrypto 生成函数](https://www.postgresql.org/docs/current/static/pgcrypto.html)
* [uuid-ossp 生成函数](https://www.postgresql.org/docs/current/static/uuid-ossp.html)

注意：如果您使用的是早于 13.0 版本的 PostgreSQL，则可能需要启用特殊扩展来使用 UUID。启用 `pgcrypto` 扩展（PostgreSQL >= 9.4）或 `uuid-ossp` 扩展（更早版本）。

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

您可以使用`uuid`类型在迁移中定义引用：

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

有关使用 UUID 作为主键的详细信息，请参见[此部分](#uuid-primary-keys)。

### 位字符串类型

* [类型定义](https://www.postgresql.org/docs/current/static/datatype-bit.html)
* [函数和操作符](https://www.postgresql.org/docs/current/static/functions-bitstring.html)

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

### 网络地址类型

* [类型定义](https://www.postgresql.org/docs/current/static/datatype-net-types.html)

`inet` 和 `cidr` 类型映射到 Ruby [`IPAddr`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ipaddr/rdoc/IPAddr.html) 对象。`macaddr` 类型映射为普通文本。

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

### 几何类型

* [类型定义](https://www.postgresql.org/docs/current/static/datatype-geometric.html)

除了 `points` 之外，所有几何类型都映射为普通文本。点被转换为包含 `x` 和 `y` 坐标的数组。

### 间隔

* [类型定义](https://www.postgresql.org/docs/current/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
* [函数和操作符](https://www.postgresql.org/docs/current/static/functions-datetime.html)

此类型映射为 [`ActiveSupport::Duration`](https://api.rubyonrails.org/classes/ActiveSupport/Duration.html) 对象。

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

UUID 主键
---------

注意：您需要启用 `pgcrypto`（仅适用于 PostgreSQL >= 9.4）或 `uuid-ossp` 扩展来生成随机 UUID。
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

注意：如果在`create_table`中没有传递`:default`选项，则假定使用`pgcrypto`中的`gen_random_uuid()`。

要使用Rails模型生成器为使用UUID作为主键的表，将`--primary-key-type=uuid`传递给模型生成器。

例如：

```bash
$ rails generate model Device --primary-key-type=uuid kind:string
```

在构建一个具有引用此UUID的外键的模型时，将`uuid`视为本机字段类型，例如：

```bash
$ rails generate model Case device_id:uuid
```

索引
--------

* [索引创建](https://www.postgresql.org/docs/current/sql-createindex.html)

PostgreSQL包括各种索引选项。除了[常见的索引选项](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index)之外，PostgreSQL适配器还支持以下选项。

### Include

在创建新索引时，可以使用`:include`选项包含非键列。这些键不用于搜索索引扫描，但可以在只读索引扫描期间读取，而无需访问关联表。

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id.rb

add_index :users, :email, include: :id
```

支持多个列：

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id_and_created_at.rb

add_index :users, :email, include: [:id, :created_at]
```

生成列
-----------------

注意：自PostgreSQL 12.0版本起支持生成列。

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users do |t|
  t.string :name
  t.virtual :name_upcased, type: :string, as: 'upper(name)', stored: true
end

# app/models/user.rb
class User < ApplicationRecord
end

# 用法
user = User.create(name: 'John')
User.last.name_upcased # => "JOHN"
```

可延迟的外键
-----------------------

* [外键表约束](https://www.postgresql.org/docs/current/sql-set-constraints.html)

默认情况下，PostgreSQL中的表约束在每个语句之后立即进行检查。它有意不允许创建引用表中尚不存在的记录。但是，可以通过在外键定义中添加`DEFERRABLE`来在事务提交时稍后运行此完整性检查。要默认推迟所有检查，可以将其设置为`DEFERRABLE INITIALLY DEFERRED`。Rails通过在`add_reference`和`add_foreign_key`方法的`foreign_key`选项中添加`:deferrable`键来公开此PostgreSQL功能。

一个例子是在事务中创建循环依赖关系，即使已创建了外键：

```ruby
add_reference :person, :alias, foreign_key: { deferrable: :deferred }
add_reference :alias, :person, foreign_key: { deferrable: :deferred }
```

如果使用`foreign_key: true`选项创建了引用，则在执行第一个`INSERT`语句时，以下事务将失败。但是，如果设置了`deferrable: :deferred`选项，则不会失败。

```ruby
ActiveRecord::Base.connection.transaction do
  person = Person.create(id: SecureRandom.uuid, alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

当将`:deferrable`选项设置为`:immediate`时，让外键保持默认行为，即立即检查约束，但允许在事务中手动推迟检查，使用`SET CONSTRAINTS ALL DEFERRED`。这将导致在提交事务时检查外键：

```ruby
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL DEFERRED")
  person = Person.create(alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

默认情况下，`:deferrable`为`false`，约束始终立即检查。

唯一约束
-----------------

* [唯一约束](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS)

```ruby
# db/migrate/20230422225213_create_items.rb
create_table :items do |t|
  t.integer :position, null: false
  t.unique_key [:position], deferrable: :immediate
end
```

如果要将现有的唯一索引更改为可延迟的，可以使用`:using_index`创建可延迟的唯一约束。

```ruby
add_unique_key :items, deferrable: :deferred, using_index: "index_items_on_position"
```

与外键一样，通过将`:deferrable`设置为`:immediate`或`:deferred`，可以推迟唯一约束。默认情况下，`:deferrable`为`false`，约束始终立即检查。

排除约束
---------------------

* [排除约束](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION)

```ruby
# db/migrate/20131220144913_create_products.rb
create_table :products do |t|
  t.integer :price, null: false
  t.daterange :availability_range, null: false

  t.exclusion_constraint "price WITH =, availability_range WITH &&", using: :gist, name: "price_check"
end
```

与外键一样，通过将`:deferrable`设置为`:immediate`或`:deferred`，可以推迟排除约束。默认情况下，`:deferrable`为`false`，约束始终立即检查。

全文搜索
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
# 用法
Document.create(title: "猫和狗", body: "很好！")

## 所有匹配 '猫和狗' 的文档
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "猫 & 狗")
```

可选地，您可以将向量存储为自动生成的列（从 PostgreSQL 12.0 开始）：

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body

  t.virtual :textsearchable_index_col,
            type: :tsvector, as: "to_tsvector('english', title || ' ' || body)", stored: true
end

add_index :documents, :textsearchable_index_col, using: :gin, name: 'documents_idx'

# 用法
Document.create(title: "猫和狗", body: "很好！")

## 所有匹配 '猫和狗' 的文档
Document.where("textsearchable_index_col @@ to_tsquery(?)", "猫 & 狗")
```

数据库视图
--------------

* [视图创建](https://www.postgresql.org/docs/current/static/sql-createview.html)

假设您需要使用以下表与遗留数据库进行交互：

```
rails_pg_guide=# \d "TBL_ART"
                                        表 "public.TBL_ART"
   列名   |            类型             |                         修饰符
------------+-----------------------------+------------------------------------------------------------
 INT_ID     | integer                     | not null default nextval('"TBL_ART_INT_ID_seq"'::regclass)
 STR_TITLE  | character varying           |
 STR_STAT   | character varying           | default 'draft'::character varying
 DT_PUBL_AT | timestamp without time zone |
 BL_ARCH    | boolean                     | default false
Indexes:
    "TBL_ART_pkey" PRIMARY KEY, btree ("INT_ID")
```

该表完全不符合 Rails 的约定。
由于简单的 PostgreSQL 视图默认是可更新的，
我们可以进行如下包装：

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
irb> first = Article.create! title: "冬天来了", status: "已发布", published_at: 1.year.ago
irb> second = Article.create! title: "做好准备", status: "草稿", published_at: 1.month.ago

irb> Article.count
=> 2
irb> first.archive!
irb> Article.count
=> 1
```

注意：此应用程序只关心未归档的 `Articles`。视图还允许添加条件，以便直接排除已归档的 `Articles`。

结构转储
--------------

如果您的 `config.active_record.schema_format` 是 `:sql`，Rails 将调用 `pg_dump` 来生成结构转储。

您可以使用 `ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags` 来配置 `pg_dump`。
例如，要从结构转储中排除注释，请将以下内容添加到初始化程序：

```ruby
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
```
