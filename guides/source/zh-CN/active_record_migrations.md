**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 311d5225fa32d069369256501f31c507
Active Record迁移
========================

迁移是Active Record的一个功能，它允许您随着时间的推移演变数据库模式。与纯SQL编写模式修改不同，迁移允许您使用Ruby DSL来描述对表的更改。

阅读本指南后，您将了解：

* 您可以使用的生成器。
* Active Record提供的操作数据库的方法。
* 操纵迁移和模式的rails命令。
* 迁移与`schema.rb`的关系。

--------------------------------------------------------------------------------

迁移概述
------------------

迁移是一种方便的方式，以一致的方式[随着时间的推移修改数据库模式](https://en.wikipedia.org/wiki/Schema_migration)。它们使用Ruby DSL，因此您不必手动编写SQL，从而使您的模式和更改与数据库无关。

您可以将每个迁移视为数据库的新“版本”。模式最初为空，每个迁移都会修改它以添加或删除表、列或条目。Active Record知道如何沿着这个时间线更新您的模式，将其从历史上的任何一点带到最新版本。Active Record还将更新您的`db/schema.rb`文件，以匹配数据库的最新结构。

以下是一个迁移的示例：

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

此迁移添加了一个名为`products`的表，其中包含一个名为`name`的字符串列和一个名为`description`的文本列。还将隐式添加一个名为`id`的主键列，因为它是所有Active Record模型的默认主键。`timestamps`宏添加了两列`created_at`和`updated_at`。如果存在这些特殊列，Active Record会自动管理它们。

请注意，我们定义了我们希望在时间推移中发生的更改。在运行此迁移之前，将没有表。之后，表将存在。Active Record也知道如何撤销此迁移：如果我们回滚此迁移，它将删除该表。

在支持更改模式的事务的数据库上，每个迁移都包装在一个事务中。如果数据库不支持此功能，则当迁移失败时，成功部分将不会回滚。您将不得不手动回滚所做的更改。

注意：某些查询无法在事务中运行。如果您的适配器支持DDL事务，则可以使用`disable_ddl_transaction!`来禁用单个迁移的事务。

### 使不可逆变得可能

如果您希望迁移执行一些Active Record不知道如何撤销的操作，可以使用`reversible`：

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

此迁移将将`price`列的类型更改为字符串，或者在还原迁移时更改为整数。请注意传递给`direction.up`和`direction.down`的块。

或者，您可以使用`up`和`down`而不是`change`：

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

INFO: 更多关于[`reversible`](#using-reversible)的内容稍后介绍。

生成迁移
----------------------

### 创建独立的迁移

迁移以文件的形式存储在`db/migrate`目录中，每个迁移类一个文件。文件的名称格式为`YYYYMMDDHHMMSS_create_products.rb`，即标识迁移的UTC时间戳，后跟下划线和迁移的名称。迁移类的名称（CamelCased版本）应与文件名的后部相匹配。例如，`20080906120000_create_products.rb`应定义`CreateProducts`类，`20080906120001_add_details_to_products.rb`应定义`AddDetailsToProducts`。Rails使用此时间戳确定应该运行哪个迁移以及以什么顺序运行，因此如果您从另一个应用程序复制迁移或自己生成文件，请注意其在顺序中的位置。

当然，计算时间戳并不好玩，因此Active Record提供了一个生成器来为您处理：

```bash
$ bin/rails generate migration AddPartNumberToProducts
```
这将创建一个适当命名的空迁移：

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
  end
end
```

这个生成器不仅可以在文件名前加上时间戳，还可以根据命名约定和其他（可选）参数来填充迁移。

### 添加新列

如果迁移名称的形式为“AddColumnToTable”或“RemoveColumnFromTable”，后面跟着一列列名和类型，那么将创建一个包含适当的[`add_column`][]和[`remove_column`][]语句的迁移。

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

这将生成以下迁移：

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
  end
end
```

如果您想在新列上添加索引，也可以这样做。

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

这将生成适当的[`add_column`][]和[`add_index`][]语句：

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

您**不限于**一个自动生成的列。例如：

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

将生成一个模式迁移，向`products`表添加两个额外的列。

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

### 删除列

类似地，您可以从命令行生成一个删除列的迁移：

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

这将生成适当的[`remove_column`][]语句：

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :part_number, :string
  end
end
```

### 创建新表

如果迁移名称的形式为“CreateXXX”，后面跟着一列列名和类型，那么将生成一个创建表XXX的迁移，并列出所列的列。例如：

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

与往常一样，为您生成的只是一个起点。您可以通过编辑`db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb`文件来添加或删除内容。

### 使用引用创建关联

此外，生成器还接受`references`（也可用作`belongs_to`）作为列类型。例如，

```bash
$ bin/rails generate migration AddUserRefToProducts user:references
```

生成以下[`add_reference`][]调用：

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

此迁移将创建一个`user_id`列。[References](#references)是创建列、索引、外键甚至多态关联列的简写。

还有一个生成器，如果`JoinTable`是名称的一部分，它将生成连接表：

```bash
$ bin/rails generate migration CreateJoinTableCustomerProduct customer product
```

将生成以下迁移：

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

模型、资源和脚手架生成器将创建适用于添加新模型的迁移。此迁移已经包含了创建相关表的指令。如果告诉Rails您想要的列，那么还会创建添加这些列的语句。例如，运行：

```bash
$ bin/rails generate model Product name:string description:text
```

这将创建一个类似于以下的迁移：

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

您可以追加任意数量的列名/类型对。

### 传递修饰符

一些常用的[type modifiers](#column-modifiers)可以直接在命令行上传递。它们用花括号括起来，跟在字段类型后面：

例如，运行：

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

将生成一个类似于以下的迁移

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

提示：查看生成器的帮助输出（`bin/rails generate --help`）以获取更多详细信息。

编写迁移
------------------

一旦使用其中一个生成器创建了迁移，就可以开始工作了！

### 创建表

[`create_table`][]方法是最基本的方法之一，但大多数情况下，它将从使用模型、资源或脚手架生成器生成的迁移中为您生成。一个典型的用法是
```ruby
create_table :products do |t|
  t.string :name
end
```

该方法创建了一个名为`products`的表，其中包含一个名为`name`的列。

默认情况下，`create_table`会隐式地为您创建一个名为`id`的主键列。您可以使用`:primary_key`选项更改列的名称，或者如果您不想要主键列，可以传递`id: false`选项。

如果您需要传递特定于数据库的选项，可以在`:options`选项中放置一个SQL片段。例如：

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

这将在用于创建表的SQL语句中追加`ENGINE=BLACKHOLE`。

可以通过将`index: true`或选项哈希传递给`:index`选项，在`create_table`块中创建在创建的列上的索引：

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

此外，您还可以使用`：comment`选项传递任何表的描述，该描述将存储在数据库本身中，并可以使用数据库管理工具（如MySQL Workbench或PgAdmin III）查看。对于具有大型数据库的应用程序，强烈建议在迁移中指定注释，因为它有助于人们理解数据模型并生成文档。目前，只有MySQL和PostgreSQL适配器支持注释。

### 创建连接表

迁移方法[`create_join_table`]创建了一个HABTM（has and belongs to many）连接表。一个典型的用法是：

```ruby
create_join_table :products, :categories
```

此迁移将创建一个名为`categories_products`的表，其中包含两个名为`category_id`和`product_id`的列。

这些列的`：null`选项默认设置为`false`，这意味着您必须提供一个值才能将记录保存到该表中。可以通过指定`:column_options`选项来覆盖此设置：

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

默认情况下，连接表的名称来自于`create_join_table`提供的前两个参数的并集，按字母顺序排列。

要自定义表的名称，请提供一个`:table_name`选项：

```ruby
create_join_table :products, :categories, table_name: :categorization
```

这将确保连接表的名称为所请求的`categorization`。

此外，`create_join_table`接受一个块，您可以在其中添加索引（默认情况下不会创建）或任何其他所需的附加列。

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```

### 修改表

如果要直接更改现有表，可以使用[`change_table`]。

它的使用方式与`create_table`类似，但在块中产生的对象可以访问许多特殊函数，例如：

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

此迁移将删除`description`和`name`列，创建一个名为`part_number`的新字符串列，并在其上添加索引。最后，将`upccode`列重命名为`upc_code`。

### 修改列

与我们之前介绍的`remove_column`和`add_column`方法类似，Rails还提供了[`change_column`]迁移方法。

```ruby
change_column :products, :part_number, :text
```

这将把`products`表上的`part_number`列更改为`：text`字段。

注意：`change_column`命令是**不可逆转**的。您应该提供自己的`reversible`迁移，就像我们之前讨论的那样。

除了`change_column`之外，[`change_column_null`]和[`change_column_default`]方法专门用于更改列的null约束和默认值。

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

这将将`products`上的`:name`字段设置为`NOT NULL`列，并将`:approved`字段的默认值从true更改为false。这些更改仅适用于未来的事务，不适用于任何现有记录。

当将null约束设置为true时，这意味着该列将接受null值，否则将应用`NOT NULL`约束，并且必须传递一个值才能将记录持久化到数据库中。

注意：您也可以将上述`change_column_default`迁移写为`change_column_default :products, :approved, false`，但与前面的示例不同，这将使您的迁移不可逆转。

### 列修饰符

在创建或更改列时可以应用列修饰符：

* `comment`：为列添加注释。
* `collation`：为`string`或`text`列指定排序规则。
* `default`：允许在列上设置默认值。请注意，如果使用动态值（例如日期），则默认值仅在第一次计算（即应用迁移的日期）时计算。对于`NULL`，请使用`nil`。
* `limit`：设置`string`列的最大字符数和`text/binary/integer`列的最大字节数。
* `null`：允许或禁止列中的`NULL`值。
* `precision`：为`decimal/numeric/datetime/time`列指定精度。
* `scale`：为`decimal`和`numeric`列指定比例，表示小数点后的位数。
注意：对于`add_column`或`change_column`，没有添加索引的选项。
需要使用`add_index`单独添加索引。

某些适配器可能支持其他选项；有关详细信息，请参阅适配器特定的API文档。

注意：在生成迁移时无法通过命令行指定`null`和`default`。

### 引用

`add_reference`方法允许创建一个适当命名的列，作为一个或多个关联之间的连接。

```ruby
add_reference :users, :role
```

此迁移将在users表中创建一个role_id列。它还会为该列创建一个索引，除非使用`index: false`选项明确告知不创建索引。

INFO：还可以参考[Active Record关联][]指南以了解更多信息。

`add_belongs_to`方法是`add_reference`的别名。

```ruby
add_belongs_to :taggings, :taggable, polymorphic: true
```

polymorphic选项将在taggings表上创建两个列，用于多态关联：taggable_type和taggable_id。

INFO：请参阅此指南以了解有关[多态关联][]的更多信息。

可以使用foreign_key选项创建外键。

```ruby
add_reference :users, :role, foreign_key: true
```

有关更多`add_reference`选项，请访问[API文档](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference)。

还可以删除引用：

```ruby
remove_reference :products, :user, foreign_key: true, index: false
```

[Active Record关联]: association_basics.html
[多态关联]: association_basics.html#polymorphic-associations

### 外键

虽然不是必需的，但您可能希望添加外键约束以[保证引用完整性](#active-record-and-referential-integrity)。

```ruby
add_foreign_key :articles, :authors
```

此[`add_foreign_key`][]调用将向articles表添加一个新的约束。该约束确保authors表中存在一行，其中id列与articles.author_id匹配。

如果无法从to_table名称派生from_table列名，则可以使用:column选项。如果引用的主键不是:id，则使用:primary_key选项。

例如，要在articles.reviewer上添加一个引用authors.email的外键：

```ruby
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

这将向articles表添加一个约束，确保authors表中存在一行，其中email列与articles.reviewer字段匹配。

`add_foreign_key`还支持其他选项，例如name、on_delete、if_not_exists、validate和deferrable。

也可以使用[`remove_foreign_key`][]删除外键：

```ruby
# 让Active Record自动确定列名
remove_foreign_key :accounts, :branches

# 删除特定列的外键
remove_foreign_key :accounts, column: :owner_id
```

注意：Active Record仅支持单列外键。使用复合外键需要使用`execute`和`structure.sql`。请参阅[模式转储和您](#schema-dumping-and-you)。

### 当助手不足以满足需求时

如果Active Record提供的助手不足以满足需求，可以使用[`execute`][]方法执行任意SQL：

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

有关各个方法的更多详细信息和示例，请查阅API文档。

特别是[`ActiveRecord::ConnectionAdapters::SchemaStatements`][]的文档，该文档提供了在`change`、`up`和`down`方法中可用的方法。

有关`create_table`生成的对象可用的方法，请参阅[`ActiveRecord::ConnectionAdapters::TableDefinition`][]。

有关`change_table`生成的对象，请参阅[`ActiveRecord::ConnectionAdapters::Table`][]。

### 使用`change`方法

`change`方法是编写迁移的主要方式。它适用于大多数情况，其中Active Record知道如何自动反转迁移的操作。以下是`change`支持的一些操作：

* [`add_check_constraint`][]
* [`add_column`][]
* [`add_foreign_key`][]
* [`add_index`][]
* [`add_reference`][]
* [`add_timestamps`][]
* [`change_column_comment`][]（必须提供`:from`和`:to`选项）
* [`change_column_default`][]（必须提供`:from`和`:to`选项）
* [`change_column_null`][]
* [`change_table_comment`][]（必须提供`:from`和`:to`选项）
* [`create_join_table`][]
* [`create_table`][]
* `disable_extension`
* [`drop_join_table`][]
* [`drop_table`][]（必须提供一个块）
* `enable_extension`
* [`remove_check_constraint`][]（必须提供约束表达式）
* [`remove_column`][]（必须提供类型）
* [`remove_columns`][]（必须提供`:type`选项）
* [`remove_foreign_key`][]（必须提供第二个表）
* [`remove_index`][]
* [`remove_reference`][]
* [`remove_timestamps`][]
* [`rename_column`][]
* [`rename_index`][]
* [`rename_table`][]

只要块只调用可逆操作（如上述操作），[`change_table`][]也是可逆的。

如果提供列类型作为第三个参数，则`remove_column`是可逆的。还要提供原始列选项，否则Rails无法在回滚时精确地重新创建列：

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

如果要使用其他任何方法，应使用`reversible`或编写`up`和`down`方法，而不是使用`change`方法。
### 使用 `reversible`

复杂的迁移可能需要处理 Active Record 不知道如何反转的操作。您可以使用 [`reversible`][] 来指定在运行迁移时要执行的操作，以及在还原迁移时要执行的其他操作。例如：

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # 创建一个分销商视图
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

使用 `reversible` 将确保指令按正确的顺序执行。如果上述示例迁移被还原，`down` 块将在删除 `home_page_url` 列和重命名 `email_address` 列之后以及在删除 `distributors` 表之前运行。


### 使用 `up`/`down` 方法

您还可以使用旧的迁移方式，使用 `up` 和 `down` 方法代替 `change` 方法。

`up` 方法应该描述您想要对模式进行的转换，而迁移的 `down` 方法应该撤销 `up` 方法所做的转换。换句话说，如果您执行 `up`，然后执行 `down`，数据库模式应该保持不变。

例如，如果您在 `up` 方法中创建了一个表，那么在 `down` 方法中应该删除它。最好按照与 `up` 方法中进行转换的相反顺序执行转换。`reversible` 部分中的示例等效于：

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # 创建一个分销商视图
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

### 抛出错误以防止还原

有时，您的迁移可能会执行一些无法逆转的操作；例如，它可能会销毁一些数据。

在这种情况下，您可以在 `down` 块中引发 `ActiveRecord::IrreversibleMigration`。

如果有人尝试还原您的迁移，将显示一个错误消息，说明无法执行还原操作。

### 还原以前的迁移

您可以使用 Active Record 的回滚迁移能力，使用 [`revert`][] 方法来回滚迁移：

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

`revert` 方法还接受一组指令的块来进行反转。这对于还原以前迁移的选定部分可能很有用。

例如，假设 `ExampleMigration` 已经提交，并且后来决定不再需要 Distributors 视图。

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.1]
  def change
    revert do
      # 从 ExampleMigration 复制粘贴的代码
      reversible do |direction|
        direction.up do
          # 创建一个分销商视图
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

      # 迁移的其余部分是正确的
    end
  end
end
```

也可以不使用 `revert` 来编写相同的迁移，但是这将涉及几个额外的步骤：

1. 颠倒 `create_table` 和 `reversible` 的顺序。
2. 将 `create_table` 替换为 `drop_table`。
3. 最后，将 `up` 替换为 `down`，反之亦然。

这些都由 `revert` 处理。

运行迁移
------------------

Rails 提供了一组命令来运行特定的一组迁移。

您可能会使用的与迁移相关的第一个 Rails 命令可能是 `bin/rails db:migrate`。在其最基本的形式中，它只会运行尚未运行的所有迁移的 `change` 或 `up` 方法。如果没有这样的迁移，它将退出。它将按照迁移的日期顺序运行这些迁移。

请注意，运行 `db:migrate` 命令还会调用 `db:schema:dump` 命令，该命令将更新您的 `db/schema.rb` 文件以匹配数据库的结构。

如果指定了目标版本，Active Record 将运行所需的迁移（change、up、down），直到达到指定的版本。版本是迁移文件名的数字前缀。例如，要迁移到版本 20080906120000，请运行：
```bash
$ bin/rails db:migrate VERSION=20080906120000
```

如果版本号20080906120000大于当前版本（即向上迁移），这将运行所有迁移直到并包括20080906120000的`change`（或`up`）方法，并且不会执行任何后续迁移。如果向下迁移，则会运行所有迁移的`down`方法，直到但不包括20080906120000。

### 回滚

一个常见的任务是回滚最后一次迁移。例如，如果您在其中犯了一个错误并希望更正它。而不是追踪与上一个迁移相关联的版本号，您可以运行：

```bash
$ bin/rails db:rollback
```

这将回滚最新的迁移，通过还原`change`方法或运行`down`方法来实现。如果您需要撤消多个迁移，可以提供一个`STEP`参数：

```bash
$ bin/rails db:rollback STEP=3
```

将会回滚最后的3个迁移。

`db:migrate:redo`命令是回滚然后再次迁移的快捷方式。与`db:rollback`命令一样，如果您需要回退多个版本，可以使用`STEP`参数，例如：

```bash
$ bin/rails db:migrate:redo STEP=3
```

这两个rails命令并没有做任何`db:migrate`不能做的事情。它们只是为了方便起见，因为您不需要显式指定要迁移到的版本。

### 设置数据库

`bin/rails db:setup`命令将创建数据库，加载模式，并使用种子数据进行初始化。

### 重置数据库

`bin/rails db:reset`命令将删除数据库并重新设置。这在功能上等同于`bin/rails db:drop db:setup`。

注意：这与运行所有迁移不同。它只会使用当前的`db/schema.rb`或`db/structure.sql`文件的内容。如果无法回滚迁移，则`bin/rails db:reset`可能无法帮助您。要了解有关转储模式的更多信息，请参阅[模式转储和您][]部分。

[模式转储和您]: #模式转储和您

### 运行特定的迁移

如果您需要运行特定的迁移，可以使用`db:migrate:up`和`db:migrate:down`命令。只需指定相应的版本，相应的迁移将调用其`change`、`up`或`down`方法，例如：

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

通过运行此命令，将执行具有版本号“20080906120000”的迁移的`change`方法（或`up`方法）。

首先，此命令将检查迁移是否存在以及是否已执行，如果是，则不执行任何操作。

如果指定的版本不存在，Rails将抛出异常。

```bash
$ bin/rails db:migrate VERSION=zomg
rails aborted!
ActiveRecord::UnknownMigrationVersionError:

没有版本号为zomg的迁移。
```

### 在不同的环境中运行迁移

默认情况下，运行`bin/rails db:migrate`将在`development`环境中运行。

要针对其他环境运行迁移，可以在运行命令时使用`RAILS_ENV`环境变量指定。例如，要针对`test`环境运行迁移，可以运行：

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### 更改运行迁移的输出

默认情况下，迁移会告诉您它们正在做什么以及花费了多长时间。创建表并添加索引的迁移可能会产生以下输出：

```
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

迁移提供了几种方法来控制所有这些内容：

| 方法                     | 目的
| -------------------------- | -------
| [`suppress_messages`][]    | 接受一个块作为参数，并抑制块生成的任何输出。
| [`say`][]                  | 接受一个消息参数，并按原样输出。可以传递第二个布尔参数来指定是否缩进。
| [`say_with_time`][]        | 输出文本以及运行其块所花费的时间。如果块返回一个整数，它将假设它是受影响的行数。

例如，考虑以下迁移：

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

这将生成以下输出：

```
==  CreateProducts: 迁移 =================================================
-- 创建了一个表
   -> 和一个索引！
-- 等待一会儿
   -> 10.0013秒
   -> 250行
==  CreateProducts: 迁移完成 (10.0054秒) =======================================
```

如果你不想让Active Record输出任何内容，可以运行`bin/rails db:migrate VERBOSE=false`来抑制所有输出。

更改现有的迁移
----------------------------

偶尔在编写迁移时会犯错误。如果你已经运行了迁移，那么你不能只是编辑迁移然后再次运行迁移：Rails认为它已经运行了迁移，所以当你运行`bin/rails db:migrate`时什么都不会发生。你必须回滚迁移（例如使用`bin/rails db:rollback`），编辑你的迁移，然后运行`bin/rails db:migrate`来运行修正后的版本。

一般来说，编辑现有的迁移不是一个好主意。这会给你和你的同事增加额外的工作量，并且如果已经在生产机器上运行了迁移的现有版本，会引起严重的问题。

相反，你应该编写一个新的迁移来执行所需的更改。编辑一个尚未提交到源代码控制（或者更一般地说，尚未在开发机器之外传播）的新生成的迁移是相对无害的。

在编写新的迁移时，`revert`方法可以帮助你撤销以前的迁移的全部或部分内容（参见[撤销以前的迁移][]）。

[撤销以前的迁移]: #撤销以前的迁移

模式转储和你
----------------------

### 模式文件的作用是什么？

迁移虽然强大，但并不是数据库模式的权威来源。**你的数据库仍然是真相的来源。**

默认情况下，Rails会生成`db/schema.rb`，它试图捕捉当前数据库模式的状态。

通过使用`bin/rails db:schema:load`加载模式文件来创建应用程序数据库的新实例，通常比重新播放整个迁移历史更快且更不容易出错。如果这些迁移使用了不断变化的外部依赖项或依赖于与迁移分开演化的应用程序代码，[旧的迁移][]可能无法正确应用。

如果你想快速查看一个Active Record对象有哪些属性，模式文件也很有用。这些信息不在模型的代码中，而是经常分布在几个迁移中，但是这些信息在模式文件中得到了很好的总结。

[旧的迁移]: #旧的迁移

### 模式转储的类型

Rails生成的模式转储的格式由[`config.active_record.schema_format`][]设置在`config/application.rb`中控制。默认情况下，格式是`:ruby`，或者可以设置为`:sql`。

#### 使用默认的`:ruby`模式

当选择`:ruby`时，模式存储在`db/schema.rb`中。如果你查看这个文件，你会发现它看起来非常像一个非常大的迁移：

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

在很多方面，这正是它的本质。这个文件是通过检查数据库并使用`create_table`、`add_index`等来表达其结构而创建的。

#### 使用`:sql`模式转储

然而，`db/schema.rb`不能表达你的数据库可能支持的一切，比如触发器、序列、存储过程等。

虽然迁移可以使用`execute`来创建Ruby迁移DSL不支持的数据库结构，但是模式转储器可能无法重新构建这些结构。

如果你使用了这些功能，你应该将模式格式设置为`:sql`，以便获得一个准确的模式文件，用于创建新的数据库实例。

当模式格式设置为`:sql`时，数据库结构将使用特定于数据库的工具转储到`db/structure.sql`中。例如，对于PostgreSQL，使用`pg_dump`实用程序。对于MySQL和MariaDB，该文件将包含各个表的`SHOW CREATE TABLE`的输出。

要从`db/structure.sql`加载模式，请运行`bin/rails db:schema:load`。加载此文件是通过执行其中包含的SQL语句来完成的。根据定义，这将创建一个数据库结构的完美副本。

### 模式转储和源代码控制
由于模式文件通常用于创建新的数据库，强烈建议将模式文件提交到源代码控制中。

当两个分支修改模式时，可能会在模式文件中发生合并冲突。要解决这些冲突，请运行`bin/rails db:migrate`以重新生成模式文件。

信息：新生成的Rails应用程序已经包含在git树中的迁移文件夹，所以您只需要确保添加任何新的迁移并提交它们。

Active Record和引用完整性
---------------------------------------

Active Record的方式认为智能应该存在于模型中，而不是数据库中。因此，不建议使用触发器或约束等将一些智能推回到数据库中的功能。

例如`validates :foreign_key, uniqueness: true`这样的验证是模型强制执行数据完整性的一种方式。关联上的`:dependent`选项允许模型在父对象被销毁时自动销毁子对象。像任何在应用程序级别操作的东西一样，这些不能保证引用完整性，因此有些人会在数据库中使用[外键约束][]来增强它们。

尽管Active Record没有提供直接使用这些功能的所有工具，但可以使用`execute`方法来执行任意的SQL。

[外键约束]: #foreign-keys

迁移和种子数据
------------------------

Rails迁移功能的主要目的是使用一致的过程发出修改模式的命令。迁移还可以用于添加或修改数据。这在无法销毁和重新创建的现有数据库（例如生产数据库）中非常有用。

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

在创建数据库后添加初始数据，Rails具有内置的“种子”功能，可以加快这个过程。这在开发和测试环境中频繁重新加载数据库或为生产环境设置初始数据时特别有用。

要开始使用此功能，请打开`db/seeds.rb`文件并添加一些Ruby代码，然后运行`bin/rails db:seed`。

注意：此处的代码应该是幂等的，以便可以在任何环境的任何时间点执行。

```ruby
["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
  MovieGenre.find_or_create_by!(name: genre_name)
end
```

这通常是设置空白应用程序的数据库的更清晰的方法。

旧的迁移
--------------

`db/schema.rb`或`db/structure.sql`是数据库当前状态的快照，也是重建该数据库的权威来源。这使得可以删除或修剪旧的迁移文件。

当您删除`db/migrate/`目录中的迁移文件时，任何在这些文件仍然存在时运行`bin/rails db:migrate`的环境将在名为`schema_migrations`的内部Rails数据库表中保留对特定于它们的迁移时间戳的引用。此表用于跟踪特定环境中是否已执行迁移。

如果运行`bin/rails db:migrate:status`命令，该命令会显示每个迁移的状态（已上升或已下降），您应该会看到在`db/migrate/`目录中找不到的任何已删除的迁移文件旁边显示`********** NO FILE **********`。

### 来自引擎的迁移

然而，对于[引擎][Engines]，有一个注意事项。从引擎安装迁移的Rake任务是幂等的，这意味着无论调用多少次，它们都会产生相同的结果。由于先前安装导致父应用程序中存在的迁移将被跳过，并且缺失的迁移将以新的时间戳复制。如果删除了旧的引擎迁移并再次运行安装任务，则会获得带有新时间戳的新文件，并且`db:migrate`将尝试再次运行它们。

因此，通常希望保留来自引擎的迁移。它们有一个特殊的注释，如下所示：

```ruby
# This migration comes from blorgh (originally 20210621082949)
```

 [Engines]: engines.html
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
