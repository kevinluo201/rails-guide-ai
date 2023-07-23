**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 311d5225fa32d069369256501f31c507
Active Record Migrations
========================

遷移是Active Record的一個功能，它允許您隨著時間演進您的數據庫架構。與純SQL編寫架構修改不同，遷移允許您使用Ruby DSL來描述對表的更改。

閱讀本指南後，您將了解：

* 您可以使用的生成器。
* Active Record提供的操作數據庫的方法。
* 操縱遷移和架構的Rails命令。
* 遷移與`schema.rb`的關係。

--------------------------------------------------------------------------------

遷移概述
------------------

遷移是一種方便的方式，以一致的方式[隨著時間改變您的數據庫架構](https://en.wikipedia.org/wiki/Schema_migration)。它們使用Ruby DSL，因此您不必手動編寫SQL，使得您的架構和更改與數據庫無關。

您可以將每個遷移視為數據庫的新“版本”。架構一開始是空的，每個遷移都會修改它以添加或刪除表、列或條目。Active Record知道如何沿著這個時間線更新您的架構，將其從歷史上的任何一點帶到最新版本。Active Record還會更新您的`db/schema.rb`文件，以匹配數據庫的最新結構。

以下是一個遷移的示例：

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

此遷移添加了一個名為`products`的表，其中包含一個名為`name`的字符串列和一個名為`description`的文本列。還將隱式添加一個名為`id`的主鍵列，因為它是所有Active Record模型的默認主鍵。`timestamps`宏添加了兩個列，`created_at`和`updated_at`。如果存在這些特殊列，Active Record會自動管理它們。

請注意，我們定義了我們希望在時間推移中發生的更改。在運行此遷移之前，將不會有表。之後，表將存在。Active Record也知道如何撤消此遷移：如果我們回滾此遷移，它將刪除該表。

在支持更改架構的語句的事務的數據庫上，每個遷移都包裹在一個事務中。如果數據庫不支持此功能，則當遷移失敗時，部分成功的部分將不會回滾。您將需要手動回滾所做的更改。

注意：某些查詢無法在事務中運行。如果您的適配器支持DDL事務，則可以使用`disable_ddl_transaction!`來禁用它們以進行單個遷移。

### 實現不可逆轉的操作

如果您希望遷移執行某些Active Record不知道如何撤消的操作，可以使用`reversible`：

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

此遷移將`price`列的類型更改為字符串，或者在撤消遷移時更改為整數。請注意傳遞給`direction.up`和`direction.down`的塊。

或者，您可以使用`up`和`down`代替`change`：

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

INFO：有關[`reversible`](#using-reversible)的更多信息稍後。

生成遷移
----------------------

### 創建獨立遷移

遷移以文件的形式存儲在`db/migrate`目錄中，每個遷移類都有一個文件。文件的名稱的形式為`YYYYMMDDHHMMSS_create_products.rb`，即UTC時間戳識別遷移，後跟下劃線，後跟遷移的名稱。遷移類的名稱（CamelCased版本）應與文件名的後半部分匹配。例如，`20080906120000_create_products.rb`應定義類`CreateProducts`，`20080906120001_add_details_to_products.rb`應定義`AddDetailsToProducts`。Rails使用此時間戳來確定應該運行哪個遷移以及以什麼順序運行，因此如果您從另一個應用程序複製遷移或自己生成文件，請注意其在順序中的位置。

當然，計算時間戳並不好玩，因此Active Record提供了一個生成器來為您處理它：

```bash
$ bin/rails generate migration AddPartNumberToProducts
```

這將創建一個名稱適當的空遷移：

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
  end
end
```

這個生成器可以做比在文件名前加上時間戳更多的事情。
根據命名慣例和額外（可選）的參數，它還可以開始填充遷移。

### 添加新列

如果遷移名稱的形式為“AddColumnToTable”或“RemoveColumnFromTable”，並且後面跟著一個列名和類型的列表，則會創建一個包含適當的[`add_column`][]和[`remove_column`][]語句的遷移。

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

這將生成以下遷移：

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
  end
end
```

如果您想在新列上添加索引，也可以這樣做。

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

這將生成適當的[`add_column`][]和[`add_index`][]語句：

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

您**不限於**一個自動生成的列。例如：

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

將生成一個模式遷移，將兩個額外的列添加到“products”表中。

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

### 刪除列

同樣，您可以從命令行生成刪除列的遷移：

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

這將生成適當的[`remove_column`][]語句：

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :part_number, :string
  end
end
```

### 創建新表

如果遷移名稱的形式為“CreateXXX”，後面跟著一個列名和類型的列表，則會生成一個創建表XXX並列出列的遷移。例如：

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```

生成

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

與往常一樣，為您生成的只是一個起點。
您可以通過編輯`db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb`文件來添加或刪除其中的內容。

### 使用引用創建關聯

此外，生成器還接受`references`（也可用作`belongs_to`）作為列類型。例如，

```bash
$ bin/rails generate migration AddUserRefToProducts user:references
```

生成以下[`add_reference`][]調用：

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

此遷移將創建一個`user_id`列。[References](#references)是一種簡寫，用於創建列、索引、外鍵，甚至是多態關聯列。

還有一個生成器，如果名稱中包含`JoinTable`，將生成連接表：

```bash
$ bin/rails generate migration CreateJoinTableCustomerProduct customer product
```

將生成以下遷移：

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


### 模型生成器

模型、資源和脚手架生成器將生成適用於添加新模型的遷移。此遷移已包含創建相關表的指令。如果告訴Rails您想要的列，則還將創建添加這些列的語句。例如，運行：

```bash
$ bin/rails generate model Product name:string description:text
```

這將創建以下遷移：

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

您可以附加任意多個列名/類型對。

### 傳遞修飾符

某些常用的[type modifiers](#column-modifiers)可以直接在命令行上傳遞。它們用花括號括起來，跟在字段類型後面：

例如，運行：

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

將生成以下遷移：

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

提示：查看生成器的幫助輸出（`bin/rails generate --help`）以獲取更多詳細信息。

編寫遷移
------------------

一旦使用其中一個生成器創建了遷移，就該開始工作了！

### 創建表

[`create_table`][]方法是最基本的方法之一，但大多數情況下，它將從使用模型、資源或脚手架生成器生成。一個典型的用法是
```ruby
create_table :products do |t|
  t.string :name
end
```

這個方法創建了一個名為 `products` 的表，其中包含一個名為 `name` 的列。

默認情況下，`create_table` 會隱式地為您創建一個名為 `id` 的主鍵列。您可以使用 `:primary_key` 選項更改列的名稱，或者如果您不想要主鍵，可以傳遞 `id: false` 選項。

如果您需要傳遞特定於數據庫的選項，可以將 SQL 片段放在 `:options` 選項中。例如：

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

這將在用於創建表的 SQL 語句中附加 `ENGINE=BLACKHOLE`。

可以通過將 `index: true` 或選項哈希傳遞給 `:index` 選項，在 `create_table` 塊中創建在創建的列上的索引：

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

此外，您可以使用 `:comment` 選項傳遞任何表的描述，該描述將存儲在數據庫本身中，並且可以使用數據庫管理工具（如 MySQL Workbench 或 PgAdmin III）查看。對於具有大型數據庫的應用程序，強烈建議在遷移中指定注釋，因為它有助於人們理解數據模型並生成文檔。目前，只有 MySQL 和 PostgreSQL 适配器支持注释。

### 創建連接表

遷移方法 [`create_join_table`][] 創建了一個 HABTM（has and belongs to many）連接表。一個典型的用法是：

```ruby
create_join_table :products, :categories
```

此遷移將創建一個名為 `categories_products` 的表，其中包含兩個列，分別為 `category_id` 和 `product_id`。

這些列的 `:null` 選項默認為 `false`，這意味著您必須提供值才能將記錄保存到此表中。可以通過指定 `:column_options` 選項來覆蓋此行為：

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

默認情況下，連接表的名稱來自於 `create_join_table` 提供的前兩個參數的聯集，按字母順序排列。

要自定義表的名稱，請提供 `:table_name` 選項：

```ruby
create_join_table :products, :categories, table_name: :categorization
```

這將確保連接表的名稱為 `categorization`。

此外，`create_join_table` 接受一個塊，您可以在其中添加索引（默認情況下不創建）或任何其他額外的列。

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```

### 修改表

如果您想要直接更改現有的表，可以使用 [`change_table`][]。

它的使用方式與 `create_table` 類似，但是在塊內部生成的對象可以訪問一些特殊的函數，例如：

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

此遷移將刪除 `description` 和 `name` 列，創建一個名為 `part_number` 的新字符串列並在其上添加索引。最後，它將 `upccode` 列重命名為 `upc_code`。

### 修改列

與我們之前介紹的 `remove_column` 和 `add_column` 方法類似，Rails 還提供了 [`change_column`][] 遷移方法。

```ruby
change_column :products, :part_number, :text
```

這將把 `products` 表上的 `part_number` 列更改為 `:text` 字段。

注意：`change_column` 命令是**不可逆的**。您應該提供自己的可逆遷移，就像我們之前討論的那樣。

除了 `change_column`，[`change_column_null`][] 和 [`change_column_default`][] 方法專門用於更改列的空值約束和默認值。

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

這將把 `products` 表上的 `:name` 字段設置為 `NOT NULL` 列，並將 `:approved` 字段的默認值從 true 更改為 false。這些更改只會應用於未來的事務，不會應用於任何現有的記錄。

當將空值約束設置為 true 時，這意味著該列將接受空值，否則將應用 `NOT NULL` 約束，並且必須傳遞值以將記錄持久化到數據庫。

注意：您也可以將上述 `change_column_default` 遷移寫成 `change_column_default :products, :approved, false`，但與前面的示例不同，這將使您的遷移不可逆。

### 列修飾符

在創建或更改列時可以應用列修飾符：

* `comment`      為列添加注釋。
* `collation`    指定 `string` 或 `text` 列的排序規則。
* `default`      允許在列上設置默認值。請注意，如果您使用動態值（例如日期），則默認值只會在第一次計算（即遷移應用的日期）時計算。對於 `NULL`，請使用 `nil`。
* `limit`        設置 `string` 列的最大字符數和 `text/binary/integer` 列的最大字節數。
* `null`         允許或禁止列中的 `NULL` 值。
* `precision`    指定 `decimal/numeric/datetime/time` 列的精度。
* `scale`        指定 `decimal` 和 `numeric` 列的縮放，表示小數點後的位數。
注意：對於`add_column`或`change_column`，沒有添加索引的選項。
必須使用`add_index`單獨添加索引。

某些適配器可能支持其他選項；請參閱適配器特定的API文檔以獲取更多信息。

注意：在生成遷移時無法通過命令行指定`null`和`default`。

### 引用

`add_reference`方法允許創建一個適當命名的列，作為一個或多個關聯之間的連接。

```ruby
add_reference :users, :role
```

此遷移將在users表中創建一個role_id列。它還會為此列創建一個索引，除非使用`index: false`選項明確指示不創建索引。

INFO：參見[Active Record關聯][]指南以瞭解更多信息。

`add_belongs_to`方法是`add_reference`的別名。

```ruby
add_belongs_to :taggings, :taggable, polymorphic: true
```

polymorphic選項將在taggings表上創建兩個列，可用於多態關聯：taggable_type和taggable_id。

INFO：請參閱此指南以瞭解更多關於[多態關聯][]的信息。

可以使用`foreign_key`選項創建外鍵。

```ruby
add_reference :users, :role, foreign_key: true
```

有關更多`add_reference`選項，請訪問[API文檔](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference)。

引用也可以被刪除：

```ruby
remove_reference :products, :user, foreign_key: true, index: false
```

[Active Record關聯]: association_basics.html
[多態關聯]: association_basics.html#polymorphic-associations

### 外鍵

雖然不是必需的，但您可能希望添加外鍵約束以[保證參照完整性](#active-record-and-referential-integrity)。

```ruby
add_foreign_key :articles, :authors
```

此[`add_foreign_key`][]調用將向articles表添加一個新約束。該約束保證在authors表中存在一行，其中id列與articles.author_id匹配。

如果無法從to_table名稱推斷出from_table列名，則可以使用`:column`選項。如果參考的主鍵不是`:id`，則使用`:primary_key`選項。

例如，要在articles.reviewer上添加一個參考authors.email的外鍵：

```ruby
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

這將向articles表添加一個約束，保證在authors表中存在一行，其中email列與articles.reviewer字段匹配。

`add_foreign_key`還支持其他選項，如`name`、`on_delete`、`if_not_exists`、`validate`和`deferrable`。

外鍵也可以使用[`remove_foreign_key`][]刪除：

```ruby
# 讓Active Record自動確定列名
remove_foreign_key :accounts, :branches

# 刪除特定列的外鍵
remove_foreign_key :accounts, column: :owner_id
```

注意：Active Record僅支持單列外鍵。使用組合外鍵需要使用`execute`和`structure.sql`。請參見[模式轉儲和您](#schema-dumping-and-you)。

### 當助手不夠用時

如果Active Record提供的助手不夠用，可以使用[`execute`][]方法執行任意SQL語句：

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

有關各個方法的更多詳細信息和示例，請查看API文檔。

特別是[`ActiveRecord::ConnectionAdapters::SchemaStatements`][]的文檔，該文檔提供了在`change`、`up`和`down`方法中可用的方法。

有關`create_table`生成的對象可用的方法，請參見[`ActiveRecord::ConnectionAdapters::TableDefinition`][]。

有關`change_table`生成的對象，請參見[`ActiveRecord::ConnectionAdapters::Table`][]。

### 使用`change`方法

`change`方法是編寫遷移的主要方式。它適用於大多數情況，其中Active Record知道如何自動撤消遷移的操作。以下是`change`支持的一些操作：

* [`add_check_constraint`][]
* [`add_column`][]
* [`add_foreign_key`][]
* [`add_index`][]
* [`add_reference`][]
* [`add_timestamps`][]
* [`change_column_comment`][]（必須提供`:from`和`:to`選項）
* [`change_column_default`][]（必須提供`:from`和`:to`選項）
* [`change_column_null`][]
* [`change_table_comment`][]（必須提供`:from`和`:to`選項）
* [`create_join_table`][]
* [`create_table`][]
* `disable_extension`
* [`drop_join_table`][]
* [`drop_table`][]（必須提供一個塊）
* `enable_extension`
* [`remove_check_constraint`][]（必須提供約束表達式）
* [`remove_column`][]（必須提供一個類型）
* [`remove_columns`][]（必須提供`:type`選項）
* [`remove_foreign_key`][]（必須提供第二個表）
* [`remove_index`][]
* [`remove_reference`][]
* [`remove_timestamps`][]
* [`rename_column`][]
* [`rename_index`][]
* [`rename_table`][]

只要塊只調用可逆操作，像上面列出的那些，[`change_table`][]也是可逆的。

如果提供列類型作為第三個參數，`remove_column`是可逆的。還要提供原始列選項，否則Rails無法在回滾時完全重新創建列：

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

如果您需要使用任何其他方法，應該使用`reversible`或編寫`up`和`down`方法，而不是使用`change`方法。
### 使用 `reversible`

複雜的遷移可能需要進行處理，而 Active Record 不知道如何進行反向操作。您可以使用 [`reversible`][] 來指定在運行遷移時要執行的操作，以及在還原遷移時要執行的其他操作。例如：

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # 創建一個分銷商視圖
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

使用 `reversible` 將確保指令按照正確的順序執行。如果上述示例遷移被還原，則 `down` 區塊將在移除 `home_page_url` 列和重命名 `email_address` 列之後以及在刪除 `distributors` 表之前運行。


### 使用 `up`/`down` 方法

您還可以使用舊的遷移方式，即使用 `up` 和 `down` 方法，而不是使用 `change` 方法。

`up` 方法應該描述您想要對模式進行的轉換，而遷移的 `down` 方法應該還原 `up` 方法所做的轉換。換句話說，如果您執行 `up`，然後執行 `down`，數據庫模式應該保持不變。

例如，如果您在 `up` 方法中創建了一個表，則應該在 `down` 方法中刪除該表。最好按照 `up` 方法中進行轉換的相反順序進行操作。`reversible` 部分中的示例等效於：

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # 創建一個分銷商視圖
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

### 拋出錯誤以防止還原

有時候，您的遷移可能會執行一些無法還原的操作；例如，它可能會刪除某些數據。

在這種情況下，您可以在 `down` 區塊中引發 `ActiveRecord::IrreversibleMigration`。

如果有人嘗試還原您的遷移，將顯示一條錯誤消息，說明無法執行還原操作。

### 還原先前的遷移

您可以使用 Active Record 的回滾遷移功能，使用 [`revert`][] 方法：

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

`revert` 方法還接受一個指令塊，用於反轉操作。這對於還原先前遷移的選定部分可能很有用。

例如，假設 `ExampleMigration` 已經提交，並且後來決定不再需要 Distributors 視圖。

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.1]
  def change
    revert do
      # 從 ExampleMigration 中複製的代碼
      reversible do |direction|
        direction.up do
          # 創建一個分銷商視圖
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

      # 其餘的遷移是正確的
    end
  end
end
```

同樣的遷移也可以不使用 `revert` 來編寫，但這將涉及更多的步驟：

1. 反轉 `create_table` 和 `reversible` 的順序。
2. 將 `create_table` 替換為 `drop_table`。
3. 最後，將 `up` 替換為 `down`，反之亦然。

這些都由 `revert` 處理。

運行遷移
------------------

Rails 提供了一組命令來運行特定的遷移集。

您可能會使用的第一個與遷移相關的 Rails 命令可能是 `bin/rails db:migrate`。在最基本的形式中，它只運行尚未運行的所有遷移的 `change` 或 `up` 方法。如果沒有這樣的遷移，它將退出。它將按照遷移的日期順序運行這些遷移。

請注意，運行 `db:migrate` 命令還會調用 `db:schema:dump` 命令，該命令將更新您的 `db/schema.rb` 文件以匹配數據庫的結構。

如果指定了目標版本，Active Record 將運行所需的遷移（change、up、down），直到達到指定的版本。版本是遷移文件名的數字前綴。例如，要遷移到版本 20080906120000，運行：
```bash
$ bin/rails db:migrate VERSION=20080906120000
```

如果版本20080906120000大於當前版本（即向上遷移），則會運行所有遷移，直到並包括20080906120000的`change`（或`up`）方法，並且不會執行任何後續遷移。如果向下遷移，則會運行所有遷移的`down`方法，直到但不包括20080906120000。

### 回滾

常見的任務是回滾最後一個遷移。例如，如果在其中犯了一個錯誤並希望更正它，而不是追踪與上一個遷移相關聯的版本號，您可以運行：

```bash
$ bin/rails db:rollback
```

這將回滾最新的遷移，通過還原`change`方法或運行`down`方法。如果您需要撤消多個遷移，可以提供`STEP`參數：

```bash
$ bin/rails db:rollback STEP=3
```

將回滾最後3個遷移。

`db:migrate:redo`命令是回滾然後再次遷移的快捷方式。與`db:rollback`命令一樣，如果您需要回退多個版本，可以使用`STEP`參數，例如：

```bash
$ bin/rails db:migrate:redo STEP=3
```

這兩個Rails命令不會執行`db:migrate`無法執行的任何操作。它們只是為了方便起見，因為您不需要明確指定要遷移到的版本。

### 設置數據庫

`bin/rails db:setup`命令將創建數據庫，加載模式，並使用種子數據進行初始化。

### 重置數據庫

`bin/rails db:reset`命令將刪除數據庫並重新設置。這在功能上等同於`bin/rails db:drop db:setup`。

注意：這與運行所有遷移不同。它只會使用當前的`db/schema.rb`或`db/structure.sql`文件的內容。如果無法回滾遷移，`bin/rails db:reset`可能無法幫助您。要了解有關轉儲模式的更多信息，請參閱[轉儲模式和您][]部分。

[轉儲模式和您]: #轉儲模式和您

### 運行特定的遷移

如果需要運行特定的遷移（向上或向下），可以使用`db:migrate:up`和`db:migrate:down`命令。只需指定相應的版本，將調用相應遷移的`change`、`up`或`down`方法，例如：

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

運行此命令將執行具有版本“20080906120000”的遷移的`change`方法（或`up`方法）。

首先，此命令將檢查遷移是否存在以及是否已執行，如果是，則不執行任何操作。

如果指定的版本不存在，Rails將拋出異常。

```bash
$ bin/rails db:migrate VERSION=zomg
rails aborted!
ActiveRecord::UnknownMigrationVersionError:

找不到版本號為zomg的遷移。
```

### 在不同環境中運行遷移

默認情況下，運行`bin/rails db:migrate`將在`development`環境中運行。

要在其他環境中運行遷移，可以在運行命令時使用`RAILS_ENV`環境變量指定它。例如，要在`test`環境中運行遷移，可以運行：

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### 更改遷移運行的輸出

默認情況下，遷移會告訴您它們正在做什麼以及花費了多少時間。創建表並添加索引的遷移可能會產生以下輸出：

```
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

遷移提供了幾種方法來控制所有這些：

| 方法                     | 目的
| -------------------------- | -------
| [`suppress_messages`][]    | 接受一個塊作為參數，並抑制塊生成的任何輸出。
| [`say`][]                  | 接受一個消息參數，並將其原樣輸出。可以傳遞第二個布爾參數來指定是否縮進。
| [`say_with_time`][]        | 輸出文本以及運行其塊所花費的時間。如果塊返回一個整數，它會假設它是受影響的行數。

例如，請參考以下遷移：

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

這將生成以下輸出：

```
==  CreateProducts: migrating =================================================
-- 建立一個表
   -> 並建立一個索引！
-- 等待一會兒
   -> 10.0013秒
   -> 250行
==  CreateProducts: migrated (10.0054秒) =======================================
```

如果你不想讓Active Record輸出任何內容，可以運行`bin/rails db:migrate VERBOSE=false`來抑制所有輸出。

更改現有的遷移
----------------------------

有時候在編寫遷移時會犯錯。如果你已經運行了遷移，那麼你不能只是編輯遷移並重新運行遷移：Rails認為已經運行了遷移，所以在運行`bin/rails db:migrate`時不會執行任何操作。你必須回滾遷移（例如使用`bin/rails db:rollback`），編輯你的遷移，然後運行`bin/rails db:migrate`來運行修正後的版本。

一般來說，編輯現有的遷移不是一個好主意。這會給你和你的同事帶來額外的工作，如果現有版本的遷移已經在生產機器上運行，還會引起嚴重的問題。

相反，你應該編寫一個新的遷移來執行你需要的更改。編輯一個尚未提交到源代碼控制（或者更一般地說，尚未在開發機器之外傳播）的新生成的遷移是相對無害的。

在編寫新遷移時，`revert`方法可以幫助你撤銷之前的遷移的全部或部分（參見[撤銷之前的遷移][]）。

[撤銷之前的遷移]: #撤銷之前的遷移

模式轉儲和你
----------------------

### 模式文件的用途是什麼？

遷移雖然強大，但並不是你的數據庫模式的權威來源。**你的數據庫仍然是真實的來源。**

默認情況下，Rails會生成`db/schema.rb`，試圖捕獲當前數據庫模式的狀態。

通過使用`bin/rails db:schema:load`加載模式文件，創建應用程序數據庫的新實例往往比重播整個遷移歷史更快且更不容易出錯。
如果這些遷移使用了變化的外部依賴或依賴於與遷移分開演進的應用程序代碼，[舊的遷移][]可能無法正確應用。

如果你想快速查看Active Record對象具有哪些屬性，模式文件也很有用。這些信息不在模型的代碼中，而且通常分散在多個遷移中，但是這些信息在模式文件中得到了很好的總結。

[舊的遷移]: #舊的遷移

### 模式轉儲的類型

Rails生成的模式轉儲的格式由[`config.active_record.schema_format`][]設置控制，該設置在`config/application.rb`中定義。默認情況下，格式為`:ruby`，或者可以設置為`:sql`。

#### 使用默認的`:ruby`模式

當選擇`:ruby`時，模式存儲在`db/schema.rb`中。如果你查看這個文件，你會發現它看起來非常像一個非常大的遷移：

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

在很多方面，這正是它的本質。這個文件是通過檢查數據庫並使用`create_table`、`add_index`等來表達其結構而創建的。

#### 使用`:sql`模式轉儲

然而，`db/schema.rb`無法表達數據庫可能支持的一切，比如觸發器、序列、存儲過程等。

雖然遷移可以使用`execute`來創建Ruby遷移DSL不支持的數據庫結構，但是這些結構可能無法被模式轉儲器重新構建。

如果你使用這些功能，應該將模式格式設置為`:sql`，以獲得一個準確的模式文件，可以用於創建新的數據庫實例。

當模式格式設置為`:sql`時，數據庫結構將使用特定於數據庫的工具轉儲到`db/structure.sql`中。例如，對於PostgreSQL，使用`pg_dump`工具。對於MySQL和MariaDB，此文件將包含各個表的`SHOW CREATE TABLE`的輸出。

要從`db/structure.sql`加載模式，運行`bin/rails db:schema:load`。加載此文件是通過執行其中包含的SQL語句來完成的。根據定義，這將創建數據庫結構的完美副本。

### 模式轉儲和源代碼控制
由於架構文件通常用於創建新的資料庫，強烈建議將您的架構文件檢入源代碼控制。

當兩個分支修改架構時，可能會在您的架構文件中發生合併衝突。要解決這些衝突，運行 `bin/rails db:migrate` 重新生成架構文件。

資訊：新生成的 Rails 應用程式已經包含在 git 樹中的遷移文件夾，所以您只需要確保添加任何新的遷移並提交它們。

Active Record 和參照完整性
---------------------------------------

Active Record 的方式聲稱智能應該存在於模型中，而不是數據庫中。因此，不建議使用觸發器或約束等將部分智能推回數據庫的功能。

通過 `validates :foreign_key, uniqueness: true` 等驗證，模型可以強制執行數據完整性。關聯中的 `:dependent` 選項允許模型在父對象被刪除時自動刪除子對象。就像在應用程序級別操作的任何內容一樣，這些無法保證參照完整性，因此有些人會在數據庫中使用[外鍵約束][]來增強它們。

儘管 Active Record 不提供直接使用此類功能的所有工具，但可以使用 `execute` 方法來執行任意的 SQL。

[外鍵約束]: #foreign-keys

遷移和種子數據
------------------------

Rails 遷移功能的主要目的是使用一致的過程發出修改架構的命令。遷移還可以用於添加或修改數據。這在現有的無法銷毀和重建的資料庫（例如生產資料庫）中非常有用。

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

在創建數據庫後添加初始數據，Rails 具有內置的 'seeds' 功能，可以加快此過程。這在開發和測試環境中經常重新加載數據庫或為生產環境設置初始數據時特別有用。

要開始使用此功能，打開 `db/seeds.rb` 文件並添加一些 Ruby 代碼，然後運行 `bin/rails db:seed`。

注意：此處的代碼應該是幂等的，以便可以在任何環境的任何時間點執行。

```ruby
["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
  MovieGenre.find_or_create_by!(name: genre_name)
end
```

這通常是設置空白應用程式的數據庫的更清晰的方式。

舊的遷移
--------------

`db/schema.rb` 或 `db/structure.sql` 是您的資料庫當前狀態的快照，也是重建該資料庫的權威來源。這使得可以刪除或修剪舊的遷移文件。

當您刪除 `db/migrate/` 目錄中的遷移文件時，任何在這些文件仍然存在時運行 `bin/rails db:migrate` 的環境將在內部的 Rails 數據庫表 `schema_migrations` 中保留對特定環境的遷移時間戳的引用。此表用於跟踪特定環境中是否已執行遷移。

如果運行 `bin/rails db:migrate:status` 命令，該命令會顯示每個遷移的狀態（已上或已下），您應該會看到在 `db/migrate/` 目錄中找不到的已刪除遷移文件旁邊顯示 `********** NO FILE **********`。

### 來自引擎的遷移

然而，[引擎][] 有一個注意事項。從引擎安裝遷移的 Rake 任務是幂等的，這意味著無論調用多少次，它們都會產生相同的結果。由於先前安裝而存在於父應用程序中的遷移將被跳過，並且缺少的遷移將以新的時間戳複製。如果刪除了舊的引擎遷移並再次運行安裝任務，您將獲得具有新時間戳的新文件，並且 `db:migrate` 將嘗試再次運行它們。

因此，通常希望保留來自引擎的遷移。它們有一個特殊的註釋，如下所示：

```ruby
# This migration comes from blorgh (originally 20210621082949)
```

 [引擎]: engines.html
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
