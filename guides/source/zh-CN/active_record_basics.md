**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b2cb0ab668ead9e8bd48cbd1bcac9b59
Active Record 基础知识
====================

本指南是 Active Record 的介绍。

阅读本指南后，您将了解：

* 什么是对象关系映射和 Active Record，以及它们在 Rails 中的使用方式。
* Active Record 如何适应模型-视图-控制器范式。
* 如何使用 Active Record 模型来操作存储在关系数据库中的数据。
* Active Record 模式命名约定。
* 数据库迁移、验证、回调和关联的概念。

--------------------------------------------------------------------------------

什么是 Active Record？
----------------------

Active Record 是 [MVC][] 中的 M，即模型，它是系统的一层，负责表示业务数据和逻辑。Active Record 便于创建和使用需要持久存储到数据库的业务对象。它是 Active Record 模式的一种实现，而 Active Record 模式本身是对象关系映射系统的描述。

### Active Record 模式

[Active Record 是由 Martin Fowler 在他的书《企业应用架构模式》中描述的][MFAR]。在 Active Record 中，对象既包含持久数据，也包含操作该数据的行为。Active Record 认为，将数据访问逻辑作为对象的一部分，可以教育使用该对象的用户如何向数据库写入和读取数据。

### 对象关系映射

对象关系映射（Object Relational Mapping），通常简称为 ORM，是一种将应用程序的丰富对象与关系数据库管理系统中的表相连接的技术。使用 ORM，应用程序中的对象的属性和关系可以轻松地存储和检索数据库，而无需直接编写 SQL 语句，并且减少了整体的数据库访问代码。

注意：了解关系数据库管理系统（RDBMS）和结构化查询语言（SQL）的基本知识有助于充分理解 Active Record。如果您想要了解更多，请参考[这个教程][sqlcourse]（或[这个教程][rdbmsinfo]），或通过其他方式学习它们。

### Active Record 作为 ORM 框架

Active Record 提供了几种机制，其中最重要的是能够：

* 表示模型及其数据。
* 表示这些模型之间的关联。
* 通过相关模型表示继承层次结构。
* 在将模型持久化到数据库之前进行验证。
* 以面向对象的方式执行数据库操作。

Active Record 中的约定优于配置
----------------------------------------------

在使用其他编程语言或框架编写应用程序时，可能需要编写大量的配置代码。对于 ORM 框架来说，这一点尤其正确。然而，如果您遵循 Rails 采用的约定，创建 Active Record 模型时将几乎不需要编写任何配置（在某些情况下甚至不需要配置）。这个想法是，如果您大部分时间都按照相同的方式配置应用程序，那么这应该是默认的方式。因此，只有在无法遵循标准约定的情况下才需要显式配置。

### 命名约定

默认情况下，Active Record 使用一些命名约定来确定模型和数据库表之间的映射关系应该如何创建。Rails 会将您的类名复数化以找到相应的数据库表。所以，对于一个名为 `Book` 的类，您应该有一个名为 **books** 的数据库表。Rails 的复数化机制非常强大，能够复数化（和单数化）常规和不规则的单词。当使用由两个或多个单词组成的类名时，模型类名应遵循 Ruby 的约定，使用 CamelCase 形式，而表名必须使用 snake_case 形式。例如：

* 模型类 - 单数形式，每个单词的首字母大写（例如，`BookClub`）。
* 数据库表 - 复数形式，单词之间用下划线分隔（例如，`book_clubs`）。

| 模型 / 类名       | 表 / 架构名 |
| ---------------- | -------------- |
| `Article`        | `articles`     |
| `LineItem`       | `line_items`   |
| `Deer`           | `deers`        |
| `Mouse`          | `mice`         |
| `Person`         | `people`       |

### 架构约定

Active Record 使用命名约定来命名数据库表中的列，具体取决于这些列的用途。

* **外键** - 这些字段的命名应遵循 `单数形式的表名_id` 的模式（例如，`item_id`、`order_id`）。这些是 Active Record 在创建模型之间的关联时要查找的字段。
* **主键** - 默认情况下，Active Record 将使用一个名为 `id` 的整数列作为表的主键（对于 PostgreSQL 和 MySQL 是 `bigint`，对于 SQLite 是 `integer`）。当使用 [Active Record 迁移](active_record_migrations.html) 创建表时，该列将自动创建。
还有一些可选的列名，可以为Active Record实例添加额外的功能：

* `created_at` - 在记录首次创建时自动设置为当前日期和时间。
* `updated_at` - 在记录创建或更新时自动设置为当前日期和时间。
* `lock_version` - 为模型添加[乐观锁定](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html)。
* `type` - 指定模型使用[单表继承](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance)。
* `(association_name)_type` - 存储[多态关联](association_basics.html#polymorphic-associations)的类型。
* `(table_name)_count` - 用于缓存关联对象的数量。例如，一个`Article`类中有多个`Comment`实例，可以使用`comments_count`列来缓存每篇文章的评论数量。

注意：虽然这些列名是可选的，但它们实际上是Active Record保留的。除非您需要额外的功能，否则应避免使用保留关键字。例如，`type`是一个保留关键字，用于指定使用单表继承（STI）的表。如果您不使用STI，可以尝试使用类似的关键字，如“context”，它可能仍然准确地描述您建模的数据。

创建Active Record模型
-----------------------------

在生成应用程序时，会在`app/models/application_record.rb`中创建一个抽象的`ApplicationRecord`类。这是应用程序中所有模型的基类，它将普通的Ruby类转换为Active Record模型。

要创建Active Record模型，请将其作为`ApplicationRecord`类的子类，并且您可以开始使用：

```ruby
class Product < ApplicationRecord
end
```

这将创建一个`Product`模型，将其映射到数据库中的`products`表。通过这样做，您还可以将该表中每一行的列与模型实例的属性进行映射。假设`products`表是使用SQL（或其扩展之一）语句创建的，如下所示：

```sql
CREATE TABLE products (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
);
```

上面的模式声明了一个具有两列`id`和`name`的表。该表的每一行表示具有这两个参数的某个产品。因此，您可以编写以下代码：

```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

覆盖命名约定
---------------------------------

如果您需要遵循不同的命名约定或需要使用遗留数据库与Rails应用程序配合使用，也没有问题，您可以轻松地覆盖默认约定。

由于`ApplicationRecord`继承自`ActiveRecord::Base`，您的应用程序模型将具有许多有用的方法。例如，您可以使用`ActiveRecord::Base.table_name=`方法自定义要使用的表名：

```ruby
class Product < ApplicationRecord
  self.table_name = "my_products"
end
```

如果这样做，您将需要在测试定义中使用`set_fixture_class`方法手动定义托管夹具（`my_products.yml`）的类名：

```ruby
# test/models/product_test.rb
class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
  # ...
end
```

还可以使用`ActiveRecord::Base.primary_key=`方法覆盖应用作为表的主键的列：

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

注意：**Active Record不支持使用非主键列命名为`id`。**

注意：如果尝试创建一个不是主键的名为`id`的列，Rails将在迁移期间抛出错误，例如：`you can't redefine the primary key column 'id' on 'my_products'.` `To define a custom primary key, pass { id: false } to create_table.`

CRUD：读取和写入数据
------------------------------

CRUD是我们用于操作数据的四个动词的首字母缩写：**C**reate（创建）、**R**ead（读取）、**U**pdate（更新）和**D**elete（删除）。Active Record会自动创建方法，允许应用程序读取和操作存储在表中的数据。

### 创建

可以从哈希、块或在创建后手动设置其属性来创建Active Record对象。`new`方法将返回一个新对象，而`create`方法将返回该对象并将其保存到数据库中。

例如，给定一个具有`name`和`occupation`属性的`User`模型，`create`方法调用将创建并保存一个新记录到数据库中：

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```
使用`new`方法可以实例化一个对象而不保存它：

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

调用`user.save`将记录提交到数据库。

最后，如果提供了一个块，`create`和`new`都会将新对象提供给该块进行初始化，而只有`create`会将结果对象持久化到数据库：

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### 读取

Active Record提供了一个丰富的API来访问数据库中的数据。以下是Active Record提供的一些不同数据访问方法的示例。

```ruby
# 返回包含所有用户的集合
users = User.all
```

```ruby
# 返回第一个用户
user = User.first
```

```ruby
# 返回名为David的第一个用户
david = User.find_by(name: 'David')
```

```ruby
# 查找所有名为David且职业为Code Artist的用户，并按创建时间的倒序排序
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

您可以在[Active Record查询接口](active_record_querying.html)指南中了解更多关于查询Active Record模型的信息。

### 更新

一旦检索到一个Active Record对象，就可以修改其属性并将其保存到数据库中。

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

一个简写方式是使用将属性名称映射到所需值的哈希，如下所示：

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

当一次更新多个属性时，这非常有用。

如果您想要批量更新多个记录**而不触发回调或验证**，可以直接使用`update_all`来更新数据库：

```ruby
User.update_all max_login_attempts: 3, must_change_password: true
```

### 删除

同样，一旦检索到一个Active Record对象，就可以销毁它，从数据库中删除它。

```ruby
user = User.find_by(name: 'David')
user.destroy
```

如果您想要批量删除多个记录，可以使用`destroy_by`或`destroy_all`方法：

```ruby
# 查找并删除所有名为David的用户
User.destroy_by(name: 'David')

# 删除所有用户
User.destroy_all
```

验证
-----------

Active Record允许您在将模型写入数据库之前验证模型的状态。有几种方法可以检查您的模型并验证属性值是否为空、唯一且不在数据库中、遵循特定格式等等。

`save`、`create`和`update`等方法在将模型持久化到数据库之前对其进行验证。当模型无效时，这些方法返回`false`，并且不执行任何数据库操作。所有这些方法都有一个bang对应方法（即`save!`、`create!`和`update!`），它们更严格，当验证失败时会引发`ActiveRecord::RecordInvalid`异常。下面是一个快速示例：

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> user = User.new
irb> user.save
=> false
irb> user.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

您可以在[Active Record验证指南](active_record_validations.html)中了解更多关于验证的信息。

回调
---------

Active Record回调允许您将代码附加到模型生命周期中的某些事件上。这使您可以通过在事件发生时透明地执行代码来为模型添加行为，例如创建新记录、更新记录、删除记录等等。

```ruby
class User < ApplicationRecord
  after_create :log_new_user

  private
    def log_new_user
      puts "A new user was registered"
    end
end
```

```irb
irb> @user = User.create
A new user was registered
```

您可以在[Active Record回调指南](active_record_callbacks.html)中了解更多关于回调的信息。

迁移
----------

Rails提供了一种方便的方式来通过迁移管理对数据库模式的更改。迁移是用特定领域语言编写的，并存储在针对Active Record支持的任何数据库执行的文件中。

下面是一个创建名为`publications`的新表的迁移示例：

```ruby
class CreatePublications < ActiveRecord::Migration[7.1]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.references :publisher, polymorphic: true
      t.boolean :single_issue

      t.timestamps
    end
  end
end
```

请注意，上述代码是与数据库无关的：它可以在MySQL、PostgreSQL、SQLite和其他数据库中运行。

Rails会跟踪已提交到数据库的迁移，并将它们存储在同一数据库中的一个相邻表中，该表称为`schema_migrations`。
要运行迁移并创建表，您需要运行 `bin/rails db:migrate`，
要回滚并删除表，需要运行 `bin/rails db:rollback`。

您可以在[Active Record 迁移指南](active_record_migrations.html)中了解更多关于迁移的信息。

关联关系
------------

Active Record 关联关系允许您定义模型之间的关系。
关联关系可以用来描述一对一、一对多和多对多的关系。例如，一个“作者有多本书”的关系可以定义如下：

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

现在，Author 类有了添加和删除书籍的方法，以及更多功能。

您可以在[Active Record 关联关系指南](association_basics.html)中了解更多关于关联关系的信息。
[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[MFAR]: https://www.martinfowler.com/eaaCatalog/activeRecord.html
[ORM]: https://en.wikipedia.org/wiki/Object-relational_mapping
[sqlcourse]: https://www.khanacademy.org/computing/computer-programming/sql
[rdbmsinfo]: https://www.devart.com/what-is-rdbms/
