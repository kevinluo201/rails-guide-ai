**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9a8daf85251d1a12237dd39a65eed51a
Active Record 和 PostgreSQL
============================

本指南介紹了 Active Record 在 PostgreSQL 中的特定用法。

閱讀完本指南後，您將了解：

* 如何使用 PostgreSQL 的數據類型。
* 如何使用 UUID 主鍵。
* 如何在索引中包含非鍵列。
* 如何使用延遲外鍵。
* 如何使用唯一約束。
* 如何實現排除約束。
* 如何使用 PostgreSQL 實現全文搜索。
* 如何使用數據庫視圖支持 Active Record 模型。

--------------------------------------------------------------------------------

要使用 PostgreSQL 适配器，您需要安装至少 9.3 版本的 PostgreSQL。不支持旧版本。

要开始使用 PostgreSQL，请查看
[配置 Rails 指南](configuring.html#configuring-a-postgresql-database)。
它描述了如何正确设置 Active Record 以使用 PostgreSQL。

數據類型
---------

PostgreSQL 提供了一些特定的數據類型。以下是 PostgreSQL 适配器支持的類型列表。

### Bytea

* [類型定義](https://www.postgresql.org/docs/current/static/datatype-binary.html)
* [函數和操作符](https://www.postgresql.org/docs/current/static/functions-binarystring.html)

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

### Array

* [類型定義](https://www.postgresql.org/docs/current/static/arrays.html)
* [函數和操作符](https://www.postgresql.org/docs/current/static/functions-array.html)

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

## 單個標籤的書籍
Book.where("'fantasy' = ANY (tags)")

## 多個標籤的書籍
Book.where("tags @> ARRAY[?]::varchar[]", ["fantasy", "fiction"])

## 有 3 個或更多評分的書籍
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [類型定義](https://www.postgresql.org/docs/current/static/hstore.html)
* [函數和操作符](https://www.postgresql.org/docs/current/static/hstore.html#id-1.11.7.26.5)

注意：您需要启用 `hstore` 擴展才能使用 hstore。

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

### JSON 和 JSONB

* [類型定義](https://www.postgresql.org/docs/current/static/datatype-json.html)
* [函數和操作符](https://www.postgresql.org/docs/current/static/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
# ... for json 數據類型：
create_table :events do |t|
  t.json 'payload'
end
# ... 或者 for jsonb 數據類型：
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

## 基於 JSON 文檔的查詢
# -> 運算符返回原始的 JSON 類型（可能是對象），而 ->> 返回文本
irb> Event.where("payload->>'kind' = ?", "user_renamed")
```

### 範圍類型

* [類型定義](https://www.postgresql.org/docs/current/static/rangetypes.html)
* [函數和操作符](https://www.postgresql.org/docs/current/static/functions-range.html)

此類型映射到 Ruby [`Range`](https://ruby-doc.org/core-2.7.0/Range.html) 對象。

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

## 指定日期的所有事件
irb> Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## 使用範圍邊界
irb> event = Event.select("lower(duration) AS starts_at").select("upper(duration) AS ends_at").first

irb> event.starts_at
=> Tue, 11 Feb 2014
irb> event.ends_at
=> Thu, 13 Feb 2014
```

### 複合類型

* [類型定義](https://www.postgresql.org/docs/current/static/rowtypes.html)

目前對於複合類型沒有特殊的支持。它們映射為普通的文本列：

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

### 枚舉類型

* [類型定義](https://www.postgresql.org/docs/current/static/datatype-enum.html)

該類型可以映射為普通的文本列，或者映射為 [`ActiveRecord::Enum`](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html)。

```ruby
# db/migrate/20131220144913_create_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  create_table :articles do |t|
    t.enum :status, enum_type: :article_status, default: "draft", null: false
  end
end
```
您還可以創建一個枚舉類型並將枚舉列添加到現有表中：

```ruby
# db/migrate/20230113024409_add_status_to_articles.rb
def change
  create_enum :article_status, ["draft", "published", "archived"]

  add_column :articles, :status, :enum, enum_type: :article_status, default: "draft", null: false
end
```

上述遷移都是可逆的，但如果需要，您可以定義單獨的 `#up` 和 `#down` 方法。在刪除枚舉類型之前，請確保刪除依賴於該枚舉類型的任何列或表：

```ruby
def down
  drop_table :articles

  # OR: remove_column :articles, :status
  drop_enum :article_status
end
```

在模型中聲明枚舉屬性會添加輔助方法並防止將無效值分配給該類的實例：

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
=> "draft" # 默認狀態來自 PostgreSQL，如上面的遷移中定義的

irb> article.status_published!
irb> article.status
=> "published"

irb> article.status_archived?
=> false

irb> article.status = "deleted"
ArgumentError: 'deleted' 不是有效的狀態
```

要重命名枚舉，可以使用 `rename_enum` 並更新任何模型使用情況：

```ruby
# db/migrate/20150718144917_rename_article_status.rb
def change
  rename_enum :article_status, to: :article_state
end
```

要添加新值，可以使用 `add_enum_value`：

```ruby
# db/migrate/20150720144913_add_new_state_to_articles.rb
def up
  add_enum_value :article_state, "archived", # 將位於 published 之後
  add_enum_value :article_state, "in review", before: "published"
  add_enum_value :article_state, "approved", after: "in review"
end
```

注意：無法刪除枚舉值，這也意味著 `add_enum_value` 是不可逆的。您可以在[此處](https://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com)閱讀原因。

要重命名值，可以使用 `rename_enum_value`：

```ruby
# db/migrate/20150722144915_rename_article_state.rb
def change
  rename_enum_value :article_state, from: "archived", to: "deleted"
end
```

提示：要顯示所有枚舉的所有值，可以在 `bin/rails db` 或 `psql` 控制台中調用此查詢：

```sql
SELECT n.nspname AS enum_schema,
       t.typname AS enum_name,
       e.enumlabel AS enum_value
  FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
```

UUID

* [類型定義](https://www.postgresql.org/docs/current/static/datatype-uuid.html)
* [pgcrypto 生成函數](https://www.postgresql.org/docs/current/static/pgcrypto.html)
* [uuid-ossp 生成函數](https://www.postgresql.org/docs/current/static/uuid-ossp.html)

注意：如果您使用的是早於 13.0 版本的 PostgreSQL，您可能需要啟用特殊擴展來使用 UUID。啟用 `pgcrypto` 擴展（PostgreSQL >= 9.4）或 `uuid-ossp` 擴展（更早的版本）。

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

您可以使用 `uuid` 類型在遷移中定義引用：

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

有關使用 UUID 作為主鍵的詳細信息，請參見[此部分](#uuid-primary-keys)。

位串類型

* [類型定義](https://www.postgresql.org/docs/current/static/datatype-bit.html)
* [函數和運算符](https://www.postgresql.org/docs/current/static/functions-bitstring.html)

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

網絡地址類型

* [類型定義](https://www.postgresql.org/docs/current/static/datatype-net-types.html)

`inet` 和 `cidr` 類型被映射為 Ruby [`IPAddr`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ipaddr/rdoc/IPAddr.html) 對象。`macaddr` 類型被映射為普通文本。

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

幾何類型

* [類型定義](https://www.postgresql.org/docs/current/static/datatype-geometric.html)

除了 `points` 之外的所有幾何類型都被映射為普通文本。點被轉換為包含 `x` 和 `y` 坐標的數組。

間隔

* [類型定義](https://www.postgresql.org/docs/current/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
* [函數和運算符](https://www.postgresql.org/docs/current/static/functions-datetime.html)

此類型被映射為 [`ActiveSupport::Duration`](https://api.rubyonrails.org/classes/ActiveSupport/Duration.html) 對象。

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

UUID 主鍵
----------

注意：您需要啟用 `pgcrypto`（僅限 PostgreSQL >= 9.4）或 `uuid-ossp` 擴展來生成隨機 UUID。
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

注意：如果在`create_table`中沒有傳遞`:default`選項，則假設使用`pgcrypto`中的`gen_random_uuid()`。

若要使用Rails模型生成器創建使用UUID作為主鍵的表，請將`--primary-key-type=uuid`傳遞給模型生成器。

例如：

```bash
$ rails generate model Device --primary-key-type=uuid kind:string
```

在建立引用此UUID的外鍵的模型時，將`uuid`視為本地字段類型，例如：

```bash
$ rails generate model Case device_id:uuid
```

索引
--------

* [索引創建](https://www.postgresql.org/docs/current/sql-createindex.html)

PostgreSQL包含各種索引選項。除了[常見的索引選項](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index)外，PostgreSQL適配器還支持以下選項。

### 包含

在創建新索引時，可以使用`:include`選項包含非鍵列。這些鍵不用於搜索索引掃描，但可以在僅索引掃描期間讀取，而無需訪問相關聯的表。

```ruby
# db/migrate/20131220144913_add_index_users_on_email_include_id.rb

add_index :users, :email, include: :id
```

支持多個列：

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

# 使用方法
user = User.create(name: 'John')
User.last.name_upcased # => "JOHN"
```

可延遲的外鍵
-----------------------

* [外鍵表約束](https://www.postgresql.org/docs/current/sql-set-constraints.html)

預設情況下，PostgreSQL中的表約束在每個語句之後立即進行檢查。它有意不允許創建引用表中尚未存在的引用記錄的記錄。但是，可以通過在外鍵定義中添加`DEFERRABLE`來在事務提交時稍後運行此完整性檢查。要默認推遲所有檢查，可以將其設置為`DEFERRABLE INITIALLY DEFERRED`。Rails通過在`add_reference`和`add_foreign_key`方法的`foreign_key`選項中添加`:deferrable`鍵來公開此PostgreSQL功能。

一個例子是即使創建了外鍵，也可以在事務中創建循環依賴關係，只需添加`deferrable: :deferred`選項。

```ruby
add_reference :person, :alias, foreign_key: { deferrable: :deferred }
add_reference :alias, :person, foreign_key: { deferrable: :deferred }
```

如果使用`foreign_key: true`選項創建了引用，則在執行第一個`INSERT`語句時，以下事務將失敗。但是，如果設置了`deferrable: :deferred`選項，則不會失敗。

```ruby
ActiveRecord::Base.connection.transaction do
  person = Person.create(id: SecureRandom.uuid, alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

當`deferrable`選項設置為`immediate`時，讓外鍵保持默認行為，即立即檢查約束，但允許在事務中手動推遲檢查，使用`SET CONSTRAINTS ALL DEFERRED`。這將導致在提交事務時檢查外鍵：

```ruby
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL DEFERRED")
  person = Person.create(alias_id: SecureRandom.uuid, name: "John Doe")
  Alias.create(id: person.alias_id, person_id: person.id, name: "jaydee")
end
```

默認情況下，`:deferrable`為`false`，約束始終立即檢查。

唯一約束
-----------------

* [唯一約束](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS)

```ruby
# db/migrate/20230422225213_create_items.rb
create_table :items do |t|
  t.integer :position, null: false
  t.unique_key [:position], deferrable: :immediate
end
```

如果要將現有的唯一索引更改為可推遲，可以使用`:using_index`創建可推遲的唯一約束。

```ruby
add_unique_key :items, deferrable: :deferred, using_index: "index_items_on_position"
```

與外鍵一樣，通過將`:deferrable`設置為`immediate`或`deferred`，可以推遲唯一約束。默認情況下，`:deferrable`為`false`，約束始終立即檢查。

排除約束
---------------------

* [排除約束](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION)

```ruby
# db/migrate/20131220144913_create_products.rb
create_table :products do |t|
  t.integer :price, null: false
  t.daterange :availability_range, null: false

  t.exclusion_constraint "price WITH =, availability_range WITH &&", using: :gist, name: "price_check"
end
```

與外鍵一樣，通過將`:deferrable`設置為`immediate`或`deferred`，可以推遲排除約束。默認情況下，`:deferrable`為`false`，約束始終立即檢查。

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
# 使用方法
Document.create(title: "貓和狗", body: "很可愛！")

## 所有符合 '貓和狗' 的文件
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "貓 & 狗")
```

可選地，您可以將向量存儲為自動生成的列（從 PostgreSQL 12.0 開始）：

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body

  t.virtual :textsearchable_index_col,
            type: :tsvector, as: "to_tsvector('english', title || ' ' || body)", stored: true
end

add_index :documents, :textsearchable_index_col, using: :gin, name: 'documents_idx'

# 使用方法
Document.create(title: "貓和狗", body: "很可愛！")

## 所有符合 '貓和狗' 的文件
Document.where("textsearchable_index_col @@ to_tsquery(?)", "貓 & 狗")
```

數據庫視圖
--------------

* [視圖創建](https://www.postgresql.org/docs/current/static/sql-createview.html)

假設您需要使用包含以下表的舊版數據庫進行工作：

```
rails_pg_guide=# \d "TBL_ART"
                                        表格 "public.TBL_ART"
   列名   |            類型             |                         修飾符
------------+-----------------------------+------------------------------------------------------------
 INT_ID     | 整數                        | 非空默認值 nextval('"TBL_ART_INT_ID_seq"'::regclass)
 STR_TITLE  | 字符串                      |
 STR_STAT   | 字符串                      | 默認值 'draft'::字符
 DT_PUBL_AT | 沒有時區的時間戳             |
 BL_ARCH    | 布爾值                      | 默認值 false
索引：
    "TBL_ART_pkey" 主鍵, btree ("INT_ID")
```

該表格完全不符合 Rails 的慣例。
由於簡單的 PostgreSQL 視圖默認是可更新的，
我們可以將其封裝如下：

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
irb> first = Article.create! title: "冬天來了", status: "已發布", published_at: 1.year.ago
irb> second = Article.create! title: "做好準備", status: "草稿", published_at: 1.month.ago

irb> Article.count
=> 2
irb> first.archive!
irb> Article.count
=> 1
```

注意：此應用程序僅關注未存檔的 `文章`。視圖還允許條件，因此我們可以直接排除已存檔的 `文章`。

結構備份
--------------

如果您的 `config.active_record.schema_format` 是 `:sql`，Rails 將調用 `pg_dump` 生成結構備份。

您可以使用 `ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags` 配置 `pg_dump`。
例如，要從結構備份中排除註釋，請將以下代碼添加到初始化程序中：

```ruby
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
```

