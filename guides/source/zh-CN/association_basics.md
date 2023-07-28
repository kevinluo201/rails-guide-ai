**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 516604959485cfefb0e0d775d767699b
Active Record关联
=================

本指南介绍了Active Record的关联功能。

阅读完本指南后，您将了解如何：

* 声明Active Record模型之间的关联。
* 理解各种类型的Active Record关联。
* 通过创建关联来使用添加到模型的方法。

--------------------------------------------------------------------------------

为什么需要关联？
-----------------

在Rails中，_关联_是两个Active Record模型之间的连接。为什么我们需要模型之间的关联？因为它们可以使代码中的常见操作更简单、更容易。

例如，考虑一个包含作者模型和图书模型的简单Rails应用程序。每个作者可以有多本图书。

如果没有关联，模型的声明将如下所示：

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

现在，假设我们想为现有作者添加一本新书。我们需要这样做：

```ruby
@book = Book.create(published_at: Time.now, author_id: @author.id)
```

或者考虑删除一个作者，并确保其所有图书也被删除：

```ruby
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

通过Active Record关联，我们可以通过声明告诉Rails这两个模型之间存在连接，从而简化这些操作和其他操作。下面是设置作者和图书的修订代码：

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

通过这个改变，为特定作者创建一本新书更容易：

```ruby
@book = @author.books.create(published_at: Time.now)
```

删除一个作者及其所有图书更容易：

```ruby
author.destroy
```

要了解更多关联类型的信息，请阅读本指南的下一节。然后是一些关于使用关联的技巧和技巧，然后是Rails中关联的方法和选项的完整参考。

关联的类型
-------------------------

Rails支持六种类型的关联，每种类型都有特定的用例。

下面是所有支持的类型的列表，以及它们的API文档的链接，以获取有关如何使用它们、它们的方法参数等更详细的信息。

* [`belongs_to`][]
* [`has_one`][]
* [`has_many`][]
* [`has_many :through`][`has_many`]
* [`has_one :through`][`has_one`]
* [`has_and_belongs_to_many`][]

关联是使用宏样式调用来实现的，因此您可以声明性地向模型添加功能。例如，通过声明一个模型`belongs_to`另一个模型，您指示Rails在这两个模型的实例之间维护[主键](https://en.wikipedia.org/wiki/Primary_key)-[外键](https://en.wikipedia.org/wiki/Foreign_key)信息，并且您还可以获得一些添加到模型的实用方法。

在本指南的其余部分，您将学习如何声明和使用各种形式的关联。但首先，快速介绍每种关联类型适用的情况。

### `belongs_to`关联

[`belongs_to`][]关联建立了与另一个模型的连接，以便声明模型的每个实例“属于”另一个模型的一个实例。例如，如果您的应用程序包括作者和图书，并且每本图书可以分配给一个作者，您可以这样声明图书模型：

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

![belongs_to关联图](images/association_basics/belongs_to.png)

注意：`belongs_to`关联必须使用单数形式。如果在上面的示例中，`Book`模型的`author`关联使用了复数形式，并尝试通过`Book.create(authors: author)`创建实例，您将收到“未初始化的常量Book::Authors”的错误。这是因为Rails会自动从关联名称推断类名。如果关联名称错误地使用了复数形式，那么推断出的类名也会错误地使用复数形式。

相应的迁移可能如下所示：

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

当单独使用`belongs_to`时，它会产生一个单向的一对一连接。因此，上面示例中的每本书“知道”它的作者，但作者不知道他们的书籍。
要设置[双向关联](#双向关联) - 在另一个模型上使用`belongs_to`与`has_one`或`has_many`结合使用，此处为Author模型。
```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```

### `has_one` 关联

[`has_one`][] 关联表示另一个模型对该模型有一个引用。可以通过该关联获取该模型。

例如，如果应用程序中的每个供应商只有一个帐户，可以这样声明供应商模型：

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

与 `belongs_to` 的主要区别是链接列 `supplier_id` 位于另一个表中：

![has_one 关联图](images/association_basics/has_one.png)

相应的迁移可能如下所示：

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end
  end
end
```

根据用例的不同，您可能还需要在帐户表的供应商列上创建唯一索引和/或外键约束。在这种情况下，列定义可能如下所示：

```ruby
create_table :accounts do |t|
  t.belongs_to :supplier, index: { unique: true }, foreign_key: true
  # ...
end
```

当与其他模型上的 `belongs_to` 结合使用时，此关系可以是[双向的](#双向关联)。

### `has_many` 关联

[`has_many`][] 关联类似于 `has_one`，但表示与另一个模型的一对多连接。通常，您会在 `belongs_to` 关联的“另一侧”找到此关联。此关联表示模型的每个实例都可以有零个或多个另一个模型的实例。例如，在包含作者和书籍的应用程序中，可以这样声明作者模型：

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

注意：声明 `has_many` 关联时，另一个模型的名称会被复数化。

![has_many 关联图](images/association_basics/has_many.png)

相应的迁移可能如下所示：

```ruby
class CreateAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

根据用例，通常最好为书籍表的作者列创建一个非唯一索引，并可选地为其创建一个外键约束：

```ruby
create_table :books do |t|
  t.belongs_to :author, index: true, foreign_key: true
  # ...
end
```

### `has_many :through` 关联

[`has_many :through`][`has_many`] 关联通常用于建立与另一个模型的多对多连接。此关联表示声明模型可以通过第三个模型进行匹配，与另一个模型的零个或多个实例相关联。例如，考虑一个医疗实践，患者预约看医生。相关的关联声明可能如下所示：

```ruby
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :physician
  belongs_to :patient
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end
```

![has_many :through 关联图](images/association_basics/has_many_through.png)

相应的迁移可能如下所示：

```ruby
class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :physicians do |t|
      t.string :name
      t.timestamps
    end

    create_table :patients do |t|
      t.string :name
      t.timestamps
    end

    create_table :appointments do |t|
      t.belongs_to :physician
      t.belongs_to :patient
      t.datetime :appointment_date
      t.timestamps
    end
  end
end
```

通过 [`has_many` 关联方法](#has-many-association-reference)，可以管理连接模型的集合。
例如，如果您分配：

```ruby
physician.patients = patients
```

那么新的连接模型将自动为新关联的对象创建。
如果以前存在的一些对象现在缺失，则它们的连接行将自动删除。

警告：连接模型的自动删除是直接的，不会触发销毁回调。

`has_many :through` 关联还可用于通过嵌套的 `has_many` 关联设置“快捷方式”。例如，如果一个文档有多个部分，一个部分有多个段落，有时您可能希望获取文档中所有段落的简单集合。可以这样设置：

```ruby
class Document < ApplicationRecord
  has_many :sections
  has_many :paragraphs, through: :sections
end

class Section < ApplicationRecord
  belongs_to :document
  has_many :paragraphs
end

class Paragraph < ApplicationRecord
  belongs_to :section
end
```

通过指定 `through: :sections`，Rails 现在可以理解：

```ruby
@document.paragraphs
```

### `has_one :through` 关联

[`has_one :through`][`has_one`] 关联建立了与另一个模型的一对一连接。此关联表示声明模型可以通过第三个模型进行匹配，与另一个模型的一个实例相关联。
例如，如果每个供应商都有一个帐户，并且每个帐户与一个帐户历史相关联，则供应商模型可能如下所示：
```ruby
class Supplier < ApplicationRecord
  has_one :account
  has_one :account_history, through: :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  has_one :account_history
end

class AccountHistory < ApplicationRecord
  belongs_to :account
end
```

![has_one :through Association Diagram](images/association_basics/has_one_through.png)

相应的迁移可能如下所示：

```ruby
class CreateAccountHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account
      t.integer :credit_rating
      t.timestamps
    end
  end
end
```

### `has_and_belongs_to_many` 关联

[`has_and_belongs_to_many`][] 关联创建了一个直接的多对多连接，没有中间模型。
这个关联表示声明模型的每个实例都指向另一个模型的零个或多个实例。
例如，如果你的应用程序包括组装和零件，每个组装有多个零件，每个零件出现在多个组装中，你可以这样声明模型：

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

![has_and_belongs_to_many 关联图](images/association_basics/habtm.png)

相应的迁移可能如下所示：

```ruby
class CreateAssembliesAndParts < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies do |t|
      t.string :name
      t.timestamps
    end

    create_table :parts do |t|
      t.string :part_number
      t.timestamps
    end

    create_table :assemblies_parts, id: false do |t|
      t.belongs_to :assembly
      t.belongs_to :part
    end
  end
end
```

### 选择 `belongs_to` 和 `has_one` 之间的关系

如果你想在两个模型之间建立一对一关系，你需要在一个模型中添加 `belongs_to`，在另一个模型中添加 `has_one`。你如何知道哪个是哪个？

区别在于你在哪里放置外键（它放在声明 `belongs_to` 关联的类的表上），但你也应该考虑数据的实际含义。`has_one` 关系表示你拥有某个东西 - 也就是说，某个东西指向你。例如，说供应商拥有一个账户比说账户拥有一个供应商更有意义。这意味着正确的关系是这样的：

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

相应的迁移可能如下所示：

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.bigint  :supplier_id
      t.string  :account_number
      t.timestamps
    end

    add_index :accounts, :supplier_id
  end
end
```

注意：使用 `t.bigint :supplier_id` 可以使外键命名明显和明确。在当前版本的 Rails 中，你可以使用 `t.references :supplier` 来抽象掉这个实现细节。

### 选择 `has_many :through` 和 `has_and_belongs_to_many` 之间的关系

Rails 提供了两种不同的方式来声明模型之间的多对多关系。第一种方式是使用 `has_and_belongs_to_many`，它允许你直接建立关联：

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

声明多对多关系的第二种方式是使用 `has_many :through`。这样可以通过一个关联模型间接建立关联：

```ruby
class Assembly < ApplicationRecord
  has_many :manifests
  has_many :parts, through: :manifests
end

class Manifest < ApplicationRecord
  belongs_to :assembly
  belongs_to :part
end

class Part < ApplicationRecord
  has_many :manifests
  has_many :assemblies, through: :manifests
end
```

简单的经验法则是，如果你需要将关联模型作为独立实体进行操作，那么应该设置一个 `has_many :through` 关系。如果你不需要对关联模型进行任何操作，那么建立一个 `has_and_belongs_to_many` 关系可能更简单（尽管你需要记住在数据库中创建连接表）。

如果你需要在关联模型上进行验证、回调或添加额外属性，应该使用 `has_many :through`。

### 多态关联

关联的一个稍微高级的变化是 _多态关联_。使用多态关联，一个模型可以属于多个其他模型，而且只有一个关联。例如，你可能有一个属于员工模型或产品模型的图片模型。下面是如何声明这个关联：

```ruby
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end
```

你可以将多态 `belongs_to` 声明视为设置一个任何其他模型都可以使用的接口。从 `Employee` 模型的实例中，你可以检索图片的集合：`@employee.pictures`。
同样，您可以检索`@product.pictures`。

如果您有一个`Picture`模型的实例，您可以通过`@picture.imageable`访问其父级。为了使其工作，您需要在声明多态接口的模型中声明外键列和类型列：

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string  :name
      t.bigint  :imageable_id
      t.string  :imageable_type
      t.timestamps
    end

    add_index :pictures, [:imageable_type, :imageable_id]
  end
end
```

通过使用`t.references`形式，可以简化此迁移：

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true
      t.timestamps
    end
  end
end
```

![多态关联图](images/association_basics/polymorphic.png)

### 自连接

在设计数据模型时，有时会发现一个模型应该与自身有关系。例如，您可能希望将所有员工存储在单个数据库模型中，但能够追踪诸如经理和下属之间的关系。可以使用自连接关联来建模这种情况：

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true
end
```

通过这种设置，您可以检索`@employee.subordinates`和`@employee.manager`。

在您的迁移/模式中，您将向模型本身添加一个引用列。

```ruby
class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :manager, foreign_key: { to_table: :employees }
      t.timestamps
    end
  end
end
```

注意：传递给`foreign_key`的`to_table`选项等更多选项在[`SchemaStatements#add_reference`][connection.add_reference]中有解释。


提示、技巧和警告
--------------------------

以下是您在Rails应用程序中有效使用Active Record关联的一些要点：

* 控制缓存
* 避免名称冲突
* 更新模式
* 控制关联范围
* 双向关联

### 控制缓存

所有关联方法都是基于缓存构建的，它保持最近查询的结果可用于进一步操作。缓存甚至在方法之间共享。例如：

```ruby
# 从数据库检索书籍
author.books.load

# 使用缓存的书籍副本
author.books.size

# 使用缓存的书籍副本
author.books.empty?
```

但是，如果您想重新加载缓存，因为数据可能已被应用程序的其他部分更改，只需在关联上调用`reload`：

```ruby
# 从数据库检索书籍
author.books.load

# 使用缓存的书籍副本
author.books.size

# 丢弃缓存的书籍副本并返回数据库
author.books.reload.empty?
```

### 避免名称冲突

您不能自由地为关联使用任何名称。因为创建关联会向模型添加具有该名称的方法，所以给关联一个已经用于`ActiveRecord::Base`的实例方法的名称是一个坏主意。关联方法将覆盖基本方法并导致错误。例如，`attributes`或`connection`是关联的坏名称。

### 更新模式

关联非常有用，但它们并不是魔法。您负责维护数据库模式以匹配关联。实际上，这意味着根据您创建的关联类型，有两件事情需要做。对于`belongs_to`关联，您需要创建外键；对于`has_and_belongs_to_many`关联，您需要创建适当的连接表。

#### 为`belongs_to`关联创建外键

当您声明`belongs_to`关联时，您需要根据需要创建外键。例如，考虑以下模型：

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

此声明需要在books表中创建相应的外键列。对于全新的表，迁移可能如下所示：

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.datetime   :published_at
      t.string     :book_number
      t.references :author
    end
  end
end
```

而对于现有表，可能如下所示：

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[7.1]
  def change
    add_reference :books, :author
  end
end
```

注意：如果您希望在数据库级别[强制执行引用完整性][foreign_keys]，请将`foreign_key: true`选项添加到上述“引用”列声明中。


#### 为`has_and_belongs_to_many`关联创建连接表

如果您创建了一个`has_and_belongs_to_many`关联，您需要显式创建连接表。除非使用`：join_table`选项显式指定连接表的名称，否则Active Record将使用类名的词法顺序创建名称。因此，作者和书籍模型之间的连接将给出默认连接表名称“authors_books”，因为在词法排序中，“a”优于“b”。
警告：模型名称之间的优先级是使用`String`的`<=>`运算符计算的。这意味着如果字符串的长度不同，并且在比较到最短长度时字符串相等，则较长的字符串被认为比较短的字符串具有更高的词法优先级。例如，人们期望表格"paper_boxes"和"papers"生成一个连接表名称为"papers_paper_boxes"，因为名称"paper_boxes"的长度较长，但实际上生成的连接表名称是"paper_boxes_papers"（因为在常见编码中下划线'\_'在字典顺序上小于's'）。

无论名称如何，您都必须手动生成具有适当迁移的连接表。例如，考虑以下关联：

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

这些关联需要通过迁移来创建`assemblies_parts`表。该表应该创建时没有主键：

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.bigint :assembly_id
      t.bigint :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end
```

我们在`create_table`中传递`id: false`，因为该表不表示一个模型。这对于关联的正常工作是必需的。如果您在`has_and_belongs_to_many`关联中观察到任何奇怪的行为，比如混乱的模型ID或关于冲突ID的异常，那么很可能是忘记了这一点。

为了简化起见，您还可以使用`create_join_table`方法：

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :assemblies, :parts do |t|
      t.index :assembly_id
      t.index :part_id
    end
  end
end
```

### 控制关联作用域

默认情况下，关联只在当前模块的作用域内查找对象。当您在一个模块内声明Active Record模型时，这可能很重要。例如：

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end

    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

这将正常工作，因为`Supplier`和`Account`类都在同一个作用域内定义。但是以下情况将不起作用，因为`Supplier`和`Account`在不同的作用域中定义：

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

要将模型与不同命名空间中的模型关联起来，您必须在关联声明中指定完整的类名：

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account,
        class_name: "MyApplication::Billing::Account"
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier,
        class_name: "MyApplication::Business::Supplier"
    end
  end
end
```

### 双向关联

关联通常在两个方向上工作，需要在两个不同的模型上声明：

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Active Record将尝试根据关联名称自动识别这两个模型共享的双向关联。这个信息允许Active Record：

* 避免对已加载数据进行不必要的查询：

    ```irb
    irb> author = Author.first
    irb> author.books.all? do |book|
    irb>   book.author.equal?(author) # 这里不会执行额外的查询
    irb> end
    => true
    ```

* 避免不一致的数据（因为只加载了一个`Author`对象的副本）：

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Changed Name"
    irb> author.name == book.author.name
    => true
    ```

* 在更多情况下自动保存关联：

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => true
    ```

* 在更多情况下验证关联的[存在](active_record_validations.html#presence)和[不存在](active_record_validations.html#absence)：

    ```irb
    irb> book = Book.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => true
    ```

Active Record支持对大多数具有标准名称的关联进行自动识别。但是，包含`：through`或`：foreign_key`选项的双向关联将不会自动识别。

在相反关联上的自定义作用域也会阻止自动识别，就像在关联本身上的自定义作用域一样，除非将[`config.active_record.automatic_scope_inversing`][]设置为true（新应用程序的默认设置）。

例如，考虑以下模型声明：

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

由于`：foreign_key`选项，Active Record将不再自动识别双向关联。这可能会导致应用程序：
* 对相同数据执行不必要的查询（在这个例子中导致N+1查询）：

    ```irb
    irb> author = Author.first
    irb> author.books.any? do |book|
    irb>   book.author.equal?(author) # 这会为每本书执行一次作者查询
    irb> end
    => false
    ```

* 引用具有不一致数据的模型的多个副本：

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Changed Name"
    irb> author.name == book.author.name
    => false
    ```

* 未能自动保存关联：

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => false
    ```

* 未能验证存在或不存在：

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    ```

Active Record 提供了 `:inverse_of` 选项，因此您可以显式声明双向关联：

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

通过在 `has_many` 关联声明中包含 `:inverse_of` 选项，Active Record 现在将识别双向关联，并像上面的初始示例一样运行。

详细的关联参考
------------------------------

以下部分详细介绍了每种类型的关联，包括它们添加的方法以及在声明关联时可以使用的选项。

### `belongs_to` 关联参考

从数据库的角度来看，`belongs_to` 关联表示该模型的表包含一个表示对另一个表的引用的列。
这可以用于建立一对一或一对多的关系，具体取决于设置。
如果另一个类的表在一对一关系中包含引用，则应使用 `has_one`。

#### `belongs_to` 添加的方法

当您声明 `belongs_to` 关联时，声明类会自动获得与关联相关的 8 个方法：

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`
* `association_changed?`
* `association_previously_changed?`

在所有这些方法中，`association` 都会被替换为作为 `belongs_to` 的第一个参数传递的符号。例如，给定以下声明：

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

`Book` 模型的每个实例都会有这些方法：

* `author`
* `author=`
* `build_author`
* `create_author`
* `create_author!`
* `reload_author`
* `reset_author`
* `author_changed?`
* `author_previously_changed?`

注意：当初始化一个新的 `has_one` 或 `belongs_to` 关联时，您必须使用 `build_` 前缀来构建关联，而不是用于 `has_many` 或 `has_and_belongs_to_many` 关联的 `association.build` 方法。要创建一个，使用 `create_` 前缀。

##### `association`

`association` 方法返回关联的对象（如果有）。如果没有找到关联的对象，则返回 `nil`。

```ruby
@author = @book.author
```

如果已经从数据库中检索到此对象的关联对象，则会返回缓存的版本。要覆盖此行为（并强制进行数据库读取），在父对象上调用 `#reload_association`。

```ruby
@author = @book.reload_author
```

要卸载关联对象的缓存版本（导致下一次访问（如果有）从数据库查询它），请在父对象上调用 `#reset_association`。

```ruby
@book.reset_author
```

##### `association=(associate)`

`association=` 方法将关联的对象分配给此对象。在幕后，这意味着从关联对象中提取主键，并将该对象的外键设置为相同的值。

```ruby
@book.author = @author
```

##### `build_association(attributes = {})`

`build_association` 方法返回关联类型的新对象。此对象将从传递的属性实例化，并将通过此对象的外键设置链接，但关联对象尚未保存。

```ruby
@author = @book.build_author(author_number: 123,
                             author_name: "John Doe")
```

##### `create_association(attributes = {})`

`create_association` 方法返回关联类型的新对象。此对象将从传递的属性实例化，并将通过此对象的外键设置链接，并且一旦通过关联模型上指定的所有验证，关联对象将被保存。

```ruby
@author = @book.create_author(author_number: 123,
                              author_name: "John Doe")
```

##### `create_association!(attributes = {})`

与上面的 `create_association` 相同，但如果记录无效，则引发 `ActiveRecord::RecordInvalid`。

##### `association_changed?`

`association_changed?` 方法返回 true，如果已分配新的关联对象，并且外键将在下一次保存时更新。
```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.author_changed? # => true

@book.save!
@book.author_changed? # => false
```

##### `association_previously_changed?`

`association_previously_changed?`方法在前一次保存更新关联引用到一个新的关联对象时返回true。

```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_previously_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.save!
@book.author_previously_changed? # => true
```

#### `belongs_to`的选项

虽然Rails使用智能默认值在大多数情况下都能很好地工作，但有时您可能想要自定义`belongs_to`关联引用的行为。通过在创建关联时传递选项和作用域块，可以轻松实现这些自定义。例如，以下关联使用了两个这样的选项：

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at,
    counter_cache: true
end
```

[`belongs_to`][]关联支持以下选项：

* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:primary_key`
* `:inverse_of`
* `:polymorphic`
* `:touch`
* `:validate`
* `:optional`

##### `:autosave`

如果将`autosave`选项设置为`true`，则在保存父对象时，Rails将保存任何已加载的关联成员，并销毁标记为销毁的成员。将`autosave`设置为`false`并不等同于不设置`autosave`选项。如果不存在`autosave`选项，则会保存新的关联对象，但不会保存已更新的关联对象。

##### `:class_name`

如果其他模型的名称无法从关联名称中推断出来，可以使用`class_name`选项提供模型名称。例如，如果一本书属于一个作者，但包含作者的实际模型的名称是`Patron`，则可以这样设置：

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron"
end
```

##### `:counter_cache`

`counter_cache`选项可用于提高查找所属对象数量的效率。考虑以下模型：

```ruby
class Book < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :books
end
```

使用这些声明，要求`author.books.size`的值需要调用数据库执行`COUNT(*)`查询。为了避免这个调用，可以在所属模型上添加一个计数器缓存：

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end

class Author < ApplicationRecord
  has_many :books
end
```

使用这个声明，Rails将保持缓存值的最新状态，并在`size`方法的响应中返回该值。

虽然`counter_cache`选项是在包含`belongs_to`声明的模型上指定的，但实际的列必须添加到关联的（`has_many`）模型中。在上面的例子中，您需要向`Author`模型添加一个名为`books_count`的列。

您可以通过在`counter_cache`声明中指定自定义列名而覆盖默认列名，而不是使用`true`。例如，使用`count_of_books`代替`books_count`：

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: :count_of_books
end

class Author < ApplicationRecord
  has_many :books
end
```

注意：只需要在关联的`belongs_to`一侧指定`counter_cache`选项。

通过`attr_readonly`，计数器缓存列将添加到所有者模型的只读属性列表中。

如果由于某种原因更改所有者模型的主键的值，并且没有更新计数模型的外键，则计数器缓存可能具有过时的数据。换句话说，任何孤立的模型仍然会计入计数器。要修复过时的计数器缓存，请使用[`reset_counters`][]。

##### `:dependent`

如果将`dependent`选项设置为：

* `:destroy`，当对象被销毁时，将在其关联对象上调用`destroy`。
* `:delete`，当对象被销毁时，将直接从数据库中删除其所有关联对象，而不调用其`destroy`方法。
* `:destroy_async`：当对象被销毁时，将会排队一个`ActiveRecord::DestroyAssociationAsyncJob`作业，该作业将在其关联对象上调用`destroy`。必须设置Active Job才能使用此选项。如果关联由数据库中的外键约束支持，请不要使用此选项。外键约束操作将在删除所有者的同一事务中发生。
警告：不应在与另一个类上的`has_many`关联相连接的`belongs_to`关联上指定此选项。这样做可能导致数据库中的孤立记录。

##### `:foreign_key`

按照惯例，Rails假设用于保存此模型上的外键的列名是关联名称加上后缀`_id`。`:foreign_key`选项允许您直接设置外键的名称：

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                      foreign_key: "patron_id"
end
```

提示：无论如何，Rails都不会为您创建外键列。您需要在迁移的一部分中明确定义它们。

##### `:primary_key`

按照惯例，Rails假设`id`列用于保存其表的主键。`:primary_key`选项允许您指定不同的列。

例如，假设我们有一个具有`guid`作为主键的`users`表。如果我们想要一个单独的`todos`表来保存`guid`列中的外键`user_id`，那么我们可以使用`primary_key`来实现：

```ruby
class User < ApplicationRecord
  self.primary_key = 'guid' # 主键是guid而不是id
end

class Todo < ApplicationRecord
  belongs_to :user, primary_key: 'guid'
end
```

当我们执行`@user.todos.create`时，`@todo`记录的`user_id`值将是`@user`的`guid`值。

##### `:inverse_of`

`:inverse_of`选项指定与此关联相反的`has_many`或`has_one`关联的名称。有关详细信息，请参见[双向关联](#bi-directional-associations)部分。

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:polymorphic`

将`true`传递给`:polymorphic`选项表示这是一个多态关联。多态关联在本指南的[多态关联](#polymorphic-associations)部分中有详细讨论。

##### `:touch`

如果将`:touch`选项设置为`true`，则在保存或删除此对象时，关联对象上的`updated_at`或`updated_on`时间戳将设置为当前时间：

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: true
end

class Author < ApplicationRecord
  has_many :books
end
```

在这种情况下，保存或删除一本书将更新关联作者上的时间戳。您还可以指定要更新的特定时间戳属性：

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at
end
```

##### `:validate`

如果将`:validate`选项设置为`true`，则在保存此对象时，新的关联对象将进行验证。默认情况下，此选项为`false`：在保存此对象时，不会验证新的关联对象。

##### `:optional`

如果将`:optional`选项设置为`true`，则不会验证关联对象的存在。默认情况下，此选项设置为`false`。

#### `belongs_to`的作用域

有时您可能希望自定义`belongs_to`使用的查询。可以通过作用域块来实现此类自定义。例如：

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

您可以在作用域块中使用任何标准的[查询方法](active_record_querying.html)。下面讨论了以下方法：

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

`where`方法允许您指定关联对象必须满足的条件。

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

##### `includes`

您可以使用`includes`方法来指定在使用此关联时应预加载的二级关联。例如，考虑以下模型：

```ruby
class Chapter < ApplicationRecord
  belongs_to :book
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

如果您经常直接从章节中检索作者（`@chapter.book.author`），那么您可以通过在章节到书籍的关联中包含作者来使代码更高效：

```ruby
class Chapter < ApplicationRecord
  belongs_to :book, -> { includes :author }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

注意：对于直接关联，无需使用`includes` - 也就是说，如果您有`Book belongs_to :author`，则在需要时会自动预加载作者。

##### `readonly`

如果使用`readonly`，则通过关联检索到的关联对象将为只读。


##### `select`

`select` 方法允许你覆盖用于检索关联对象数据的 SQL `SELECT` 子句。默认情况下，Rails 检索所有列。

提示：如果你在 `belongs_to` 关联上使用 `select` 方法，你还应该设置 `:foreign_key` 选项以确保正确的结果。

#### 是否存在任何关联对象？

你可以使用 `association.nil?` 方法来查看是否存在任何关联对象：

```ruby
if @book.author.nil?
  @msg = "找不到此书的作者"
end
```

#### 对象何时保存？

将对象分配给 `belongs_to` 关联不会自动保存对象。它也不会保存关联对象。

### `has_one` 关联参考

`has_one` 关联创建与另一个模型的一对一匹配。在数据库术语中，此关联表示另一个类包含外键。如果此类包含外键，则应该使用 `belongs_to`。

#### `has_one` 添加的方法

当声明 `has_one` 关联时，声明类会自动获得与关联相关的 6 个方法：

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`

在所有这些方法中，`association` 都会被替换为作为第一个参数传递给 `has_one` 的符号。例如，给定以下声明：

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

`Supplier` 模型的每个实例都会有这些方法：

* `account`
* `account=`
* `build_account`
* `create_account`
* `create_account!`
* `reload_account`
* `reset_account`

注意：当初始化一个新的 `has_one` 或 `belongs_to` 关联时，你必须使用 `build_` 前缀来构建关联，而不是用于 `has_many` 或 `has_and_belongs_to_many` 关联的 `association.build` 方法。要创建一个关联对象，使用 `create_` 前缀。

##### `association`

`association` 方法返回关联对象（如果有）。如果没有找到关联对象，则返回 `nil`。

```ruby
@account = @supplier.account
```

如果已经从数据库中检索到此对象的关联对象，则会返回缓存的版本。要覆盖此行为（并强制进行数据库读取），在父对象上调用 `#reload_association`。

```ruby
@account = @supplier.reload_account
```

要卸载关联对象的缓存版本（强制下一次访问（如果有）从数据库查询它），在父对象上调用 `#reset_association`。

```ruby
@supplier.reset_account
```

##### `association=(associate)`

`association=` 方法将关联对象分配给此对象。在幕后，这意味着从此对象中提取主键，并将关联对象的外键设置为相同的值。

```ruby
@supplier.account = @account
```

##### `build_association(attributes = {})`

`build_association` 方法返回关联类型的新对象。此对象将从传递的属性实例化，并通过其外键设置链接，但关联对象尚未保存。

```ruby
@account = @supplier.build_account(terms: "Net 30")
```

##### `create_association(attributes = {})`

`create_association` 方法返回关联类型的新对象。此对象将从传递的属性实例化，并通过其外键设置链接，并且一旦通过关联模型上指定的所有验证，关联对象将被保存。

```ruby
@account = @supplier.create_account(terms: "Net 30")
```

##### `create_association!(attributes = {})`

与上面的 `create_association` 相同，但如果记录无效，则引发 `ActiveRecord::RecordInvalid`。

#### `has_one` 的选项

虽然 Rails 使用智能默认值，在大多数情况下都能很好地工作，但有时你可能想要自定义 `has_one` 关联参考的行为。通过在创建关联时传递选项，可以轻松实现这些自定义。例如，此关联使用了两个选项：

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing", dependent: :nullify
end
```

[`has_one`][] 关联支持以下选项：

* `:as`
* `:autosave`
* `:class_name`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:touch`
* `:validate`

##### `:as`

设置 `:as` 选项表示这是一个多态关联。多态关联在本指南的[前面部分](#polymorphic-associations)中有详细讨论。

##### `:autosave`

如果将 `:autosave` 选项设置为 `true`，Rails 将在保存父对象时保存任何已加载的关联成员，并销毁标记为销毁的成员。将 `:autosave` 设置为 `false` 不等同于不设置 `:autosave` 选项。如果不存在 `:autosave` 选项，则新的关联对象将被保存，但更新的关联对象将不会被保存。
##### `:class_name`

如果其他模型的名称不能从关联名称中推导出来，您可以使用`:class_name`选项来提供模型名称。例如，如果供应商有一个账户，但包含账户的实际模型名称是`Billing`，您可以这样设置：

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing"
end
```

##### `:dependent`

控制当所有者被销毁时，关联对象会发生什么：

* `:destroy`会导致关联对象也被销毁
* `:delete`会直接从数据库中删除关联对象（因此回调不会执行）
* `:destroy_async`：当对象被销毁时，会排队一个`ActiveRecord::DestroyAssociationAsyncJob`作业，该作业将调用其关联对象的销毁方法。必须设置Active Job才能使其工作。如果关联由数据库中的外键约束支持，请不要使用此选项。外键约束操作将在删除所有者的同一事务中发生。
* `:nullify`会将外键设置为`NULL`。在多态关联中，多态类型列也会被设置为`NULL`。不会执行回调。
* `:restrict_with_exception`会在存在关联记录时引发`ActiveRecord::DeleteRestrictionError`异常
* `:restrict_with_error`会在所有者上添加错误，如果存在关联对象

对于那些具有`NOT NULL`数据库约束的关联，不设置或保留`:nullify`选项是必要的。如果不将`dependent`设置为销毁此类关联，您将无法更改关联对象，因为初始关联对象的外键将被设置为不允许的`NULL`值。

##### `:foreign_key`

按照惯例，Rails假设用于保存其他模型上的外键的列名是该模型的名称加上后缀`_id`。`:foreign_key`选项允许您直接设置外键的名称：

```ruby
class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
end
```

提示：无论如何，Rails都不会为您创建外键列。您需要在迁移的一部分中明确定义它们。

##### `:inverse_of`

`:inverse_of`选项指定与此关联相反的`belongs_to`关联的名称。有关更多详细信息，请参见[双向关联](#bi-directional-associations)部分。

```ruby
class Supplier < ApplicationRecord
  has_one :account, inverse_of: :supplier
end

class Account < ApplicationRecord
  belongs_to :supplier, inverse_of: :account
end
```

##### `:primary_key`

按照惯例，Rails假设用于保存此模型的主键的列是`id`。您可以通过`:primary_key`选项覆盖这一点并明确指定主键。

##### `:source`

`:source`选项指定`has_one :through`关联的源关联名称。

##### `:source_type`

`:source_type`选项指定通过多态关联进行的`has_one :through`关联的源关联类型。

```ruby
class Author < ApplicationRecord
  has_one :book
  has_one :hardback, through: :book, source: :format, source_type: "Hardback"
  has_one :dust_jacket, through: :hardback
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Paperback < ApplicationRecord; end

class Hardback < ApplicationRecord
  has_one :dust_jacket
end

class DustJacket < ApplicationRecord; end
```

##### `:through`

`:through`选项指定一个联接模型，通过该模型执行查询。关于`has_one :through`关联的详细讨论可以在[本指南的前面部分](#the-has-one-through-association)找到。

##### `:touch`

如果将`:touch`选项设置为`true`，那么在保存或销毁此对象时，关联对象上的`updated_at`或`updated_on`时间戳将被设置为当前时间：

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: true
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

在这种情况下，保存或销毁供应商将更新关联账户上的时间戳。您还可以指定要更新的特定时间戳属性：

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: :suppliers_updated_at
end
```

##### `:validate`

如果将`:validate`选项设置为`true`，则在保存此对象时，新的关联对象将被验证。默认情况下，这是`false`：在保存此对象时，新的关联对象不会被验证。

#### `has_one`的作用域

有时您可能希望自定义`has_one`使用的查询。可以通过作用域块来实现这样的自定义。例如：

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```
您可以在作用域块中使用任何标准的[查询方法](active_record_querying.html)。以下是讨论的几种方法：

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

`where`方法允许您指定关联对象必须满足的条件。

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where "confirmed = 1" }
end
```

##### `includes`

您可以使用`includes`方法来指定在使用此关联时应预加载的二级关联。例如，考虑以下模型：

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

如果您经常直接从供应商检索代表（`@supplier.account.representative`），则可以通过在供应商到帐户的关联中包含代表来使代码更高效：

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { includes :representative }
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

##### `readonly`

如果使用`readonly`方法，则通过关联检索到的关联对象将为只读。

##### `select`

`select`方法允许您覆盖用于检索关联对象的SQL `SELECT`子句。默认情况下，Rails检索所有列。

#### 是否存在任何关联对象？

您可以使用`association.nil?`方法来查看是否存在任何关联对象：

```ruby
if @supplier.account.nil?
  @msg = "No account found for this supplier"
end
```

#### 何时保存对象？

当您将对象分配给`has_one`关联时，该对象会自动保存（以更新其外键）。此外，任何被替换的对象也会自动保存，因为其外键也会更改。

如果由于验证错误而导致这些保存之一失败，则赋值语句将返回`false`，并且赋值本身将被取消。

如果父对象（声明`has_one`关联的对象）未保存（即`new_record?`返回`true`），则子对象不会保存。它们将在父对象保存时自动保存。

如果要将对象分配给`has_one`关联而不保存该对象，请使用`build_association`方法。

### `has_many`关联参考

`has_many`关联创建与另一个模型的一对多关系。在数据库术语中，此关联表示另一个类将具有引用到此类实例的外键。

#### `has_many`添加的方法

当声明`has_many`关联时，声明类会自动获得与关联相关的17个方法：

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

在所有这些方法中，`collection`将被替换为传递给`has_many`的第一个参数的符号，`collection_singular`将被替换为该符号的单数形式。例如，给定以下声明：

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

`Author`模型的每个实例将具有以下方法：

```ruby
books
books<<(object, ...)
books.delete(object, ...)
books.destroy(object, ...)
books=(objects)
book_ids
book_ids=(ids)
books.clear
books.empty?
books.size
books.find(...)
books.where(...)
books.exists?(...)
books.build(attributes = {}, ...)
books.create(attributes = {})
books.create!(attributes = {})
books.reload
```

##### `collection`

`collection`方法返回与所有关联对象相关的关系。如果没有关联对象，则返回一个空的关系。

```ruby
@books = @author.books
```

##### `collection<<(object, ...)`

[`collection<<`][]方法通过将其外键设置为调用模型的主键，将一个或多个对象添加到集合中。

```ruby
@author.books << @book1
```

##### `collection.delete(object, ...)`

[`collection.delete`][]方法通过将其外键设置为`NULL`，从集合中删除一个或多个对象。

```ruby
@author.books.delete(@book1)
```

警告：如果与`dependent: :destroy`相关联，对象将被销毁；如果与`dependent: :delete_all`相关联，对象将被删除。

##### `collection.destroy(object, ...)`

[`collection.destroy`][]方法通过在每个对象上运行`destroy`，从集合中删除一个或多个对象。

```ruby
@author.books.destroy(@book1)
```

警告：对象将始终从数据库中删除，忽略`dependent`选项。

##### `collection=(objects)`

`collection=`方法通过适当地添加和删除来使集合仅包含提供的对象。更改将持久保存到数据库中。
##### `collection_singular_ids`

`collection_singular_ids` 方法返回集合中对象的 id 数组。

```ruby
@book_ids = @author.book_ids
```

##### `collection_singular_ids=(ids)`

`collection_singular_ids=` 方法通过添加和删除适当的方式，使集合仅包含由提供的主键值标识的对象。更改将持久化到数据库中。

##### `collection.clear`

[`collection.clear`][] 方法根据 `dependent` 选项指定的策略从集合中移除所有对象。如果没有给出选项，则遵循默认策略。`has_many :through` 关联的默认策略是 `delete_all`，而 `has_many` 关联的默认策略是将外键设置为 `NULL`。

```ruby
@author.books.clear
```

警告：如果对象与 `dependent: :destroy` 或 `dependent: :destroy_async` 相关联，它们将被删除，就像 `dependent: :delete_all` 一样。

##### `collection.empty?`

[`collection.empty?`][] 方法在集合不包含任何关联对象时返回 `true`。

```erb
<% if @author.books.empty? %>
  未找到书籍
<% end %>
```

##### `collection.size`

[`collection.size`][] 方法返回集合中的对象数量。

```ruby
@book_count = @author.books.size
```

##### `collection.find(...)`

[`collection.find`][] 方法在集合的表中查找对象。

```ruby
@available_book = @author.books.find(1)
```

##### `collection.where(...)`

[`collection.where`][] 方法根据提供的条件在集合中查找对象，但对象是惰性加载的，这意味着只有在访问对象时才会查询数据库。

```ruby
@available_books = author.books.where(available: true) # 还没有查询
@available_book = @available_books.first # 现在将查询数据库
```

##### `collection.exists?(...)`

[`collection.exists?`][] 方法检查集合的表中是否存在满足提供的条件的对象。

##### `collection.build(attributes = {})`

[`collection.build`][] 方法返回关联类型的一个或多个新对象。对象将从传递的属性实例化，并创建通过它们的外键的链接，但关联对象尚未保存。

```ruby
@book = author.books.build(published_at: Time.now,
                            book_number: "A12345")

@books = author.books.build([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create(attributes = {})`

[`collection.create`][] 方法返回关联类型的一个或多个新对象。对象将从传递的属性实例化，并创建通过它们的外键的链接，并且一旦通过关联模型上指定的所有验证，关联对象将被保存。

```ruby
@book = author.books.create(published_at: Time.now,
                             book_number: "A12345")

@books = author.books.create([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create!(attributes = {})`

与上面的 `collection.create` 相同，但如果记录无效，则引发 `ActiveRecord::RecordInvalid`。

##### `collection.reload`

[`collection.reload`][] 方法返回所有关联对象的关系，强制进行数据库读取。如果没有关联对象，则返回一个空的关系。

```ruby
@books = author.books.reload
```

#### `has_many` 的选项

虽然 Rails 使用智能默认值，在大多数情况下都能很好地工作，但有时您可能希望自定义 `has_many` 关联引用的行为。通过在创建关联时传递选项，可以轻松实现这些自定义。例如，此关联使用了两个这样的选项：

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :delete_all, validate: false
end
```

[`has_many`][] 关联支持以下选项：

* `:as`
* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:validate`

##### `:as`

设置 `:as` 选项表示这是一个多态关联，如[本指南前面所讨论的](#polymorphic-associations)。

##### `:autosave`

如果将 `:autosave` 选项设置为 `true`，Rails 将在保存父对象时保存任何加载的关联成员，并销毁标记为删除的成员。将 `:autosave` 设置为 `false` 不等同于不设置 `:autosave` 选项。如果不存在 `:autosave` 选项，则会保存新的关联对象，但不会保存已更新的关联对象。

##### `:class_name`

如果其他模型的名称无法从关联名称推导出来，可以使用 `:class_name` 选项提供模型名称。例如，如果作者有多本书，但包含书籍的实际模型的名称是 `Transaction`，可以这样设置：

```ruby
class Author < ApplicationRecord
  has_many :books, class_name: "Transaction"
end
```
##### `:counter_cache`

此选项可用于配置自定义的 `:counter_cache` 名称。只有在自定义了 [belongs_to 关联](#options-for-belongs-to) 的 `:counter_cache` 名称时才需要使用此选项。

##### `:dependent`

控制当所有者对象被销毁时，关联对象会发生什么：

* `:destroy` 导致所有关联对象也被销毁
* `:delete_all` 直接从数据库中删除所有关联对象（因此不会执行回调）
* `:destroy_async`：当对象被销毁时，会排队一个 `ActiveRecord::DestroyAssociationAsyncJob` 作业，该作业将调用其关联对象的 destroy 方法。必须设置 Active Job 才能使其工作。
* `:nullify` 将外键设置为 `NULL`。对于多态关联，多态类型列也将被设置为 null。不执行回调。
* `:restrict_with_exception` 如果存在任何关联记录，则引发 `ActiveRecord::DeleteRestrictionError` 异常
* `:restrict_with_error` 如果存在任何关联对象，则向所有者添加错误

`:destroy` 和 `:delete_all` 选项还会影响 `collection.delete` 和 `collection=` 方法的语义，当从集合中移除对象时，它们会销毁关联对象。

##### `:foreign_key`

按照约定，Rails 假设在其他模型上用于保存外键的列的名称是该模型的名称加上后缀 `_id`。`:foreign_key` 选项允许您直接设置外键的名称：

```ruby
class Author < ApplicationRecord
  has_many :books, foreign_key: "cust_id"
end
```

提示：无论如何，Rails 都不会为您创建外键列。您需要在迁移的一部分中明确定义它们。

##### `:inverse_of`

`:inverse_of` 选项指定与此关联相反的 `belongs_to` 关联的名称。有关更多详细信息，请参见[双向关联](#bi-directional-associations)部分。

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:primary_key`

按照约定，Rails 假设用于保存关联的主键的列是 `id`。您可以使用 `:primary_key` 选项覆盖此设置并显式指定主键。

假设 `users` 表的主键是 `id`，但它还有一个 `guid` 列。要求是 `todos` 表应将 `guid` 列的值作为外键，而不是 `id` 值。可以通过以下方式实现：

```ruby
class User < ApplicationRecord
  has_many :todos, primary_key: :guid
end
```

现在，如果我们执行 `@todo = @user.todos.create`，那么 `@todo` 记录的 `user_id` 值将是 `@user` 的 `guid` 值。

##### `:source`

`:source` 选项指定 `has_many :through` 关联的源关联名称。只有当源关联的名称无法从关联名称自动推断出来时，才需要使用此选项。

##### `:source_type`

`:source_type` 选项指定通过多态关联进行的 `has_many :through` 关联的源关联类型。

```ruby
class Author < ApplicationRecord
  has_many :books
  has_many :paperbacks, through: :books, source: :format, source_type: "Paperback"
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Hardback < ApplicationRecord; end
class Paperback < ApplicationRecord; end
```

##### `:through`

`:through` 选项指定一个连接模型，通过该模型执行查询。`has_many :through` 关联提供了一种实现多对多关系的方法，如[本指南前面讨论的](#the-has-many-through-association)。

##### `:validate`

如果将 `:validate` 选项设置为 `false`，则每当保存此对象时，新的关联对象将不会进行验证。默认情况下，此值为 `true`：保存此对象时，新的关联对象将进行验证。

#### `has_many` 的作用域

有时您可能希望自定义 `has_many` 使用的查询。可以通过作用域块来实现此类自定义。例如：

```ruby
class Author < ApplicationRecord
  has_many :books, -> { where processed: true }
end
```

您可以在作用域块中使用任何标准的[查询方法](active_record_querying.html)。以下是讨论的一些方法：

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

`where` 方法允许您指定关联对象必须满足的条件。

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where "confirmed = 1" },
    class_name: "Book"
end
```
您还可以通过哈希设置条件：

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where confirmed: true },
    class_name: "Book"
end
```

如果您使用哈希风格的`where`选项，那么通过该关联创建的记录将自动使用哈希进行范围限定。在这种情况下，使用`author.confirmed_books.create`或`author.confirmed_books.build`将创建`confirmed`列值为`true`的书籍。

##### `extending`

`extending`方法指定要扩展关联代理的命名模块。关联扩展在本指南的后面部分详细讨论。

##### `group`

`group`方法提供一个属性名称，用于使用`GROUP BY`子句在查找器SQL中对结果集进行分组。

```ruby
class Author < ApplicationRecord
  has_many :chapters, -> { group 'books.id' },
                      through: :books
end
```

##### `includes`

您可以使用`includes`方法指定在使用此关联时应预加载的二级关联。例如，考虑以下模型：

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

如果您经常直接从作者中检索章节（`author.books.chapters`），那么通过在从作者到书籍的关联中包含章节，可以使您的代码更加高效：

```ruby
class Author < ApplicationRecord
  has_many :books, -> { includes :chapters }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

##### `limit`

`limit`方法允许您限制通过关联获取的对象的总数。

```ruby
class Author < ApplicationRecord
  has_many :recent_books,
    -> { order('published_at desc').limit(100) },
    class_name: "Book"
end
```

##### `offset`

`offset`方法允许您指定通过关联获取对象的起始偏移量。例如，`-> { offset(11) }`将跳过前11条记录。

##### `order`

`order`方法指定关联对象接收的顺序（使用SQL `ORDER BY`子句的语法）。

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order "date_confirmed DESC" }
end
```

##### `readonly`

如果使用`readonly`方法，则通过关联检索的关联对象将为只读。

##### `select`

`select`方法允许您覆盖用于检索关联对象数据的SQL `SELECT`子句。默认情况下，Rails检索所有列。

警告：如果指定自己的`select`，请确保包括关联模型的主键和外键列。如果不包括，Rails将抛出错误。

##### `distinct`

使用`distinct`方法使集合中不包含重复项。这在与`：through`选项一起使用时非常有用。

```ruby
class Person < ApplicationRecord
  has_many :readings
  has_many :articles, through: :readings
end
```

```irb
irb> person = Person.create(name: 'John')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 5, name: "a1">, #<Article id: 5, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 12, person_id: 5, article_id: 5>, #<Reading id: 13, person_id: 5, article_id: 5>]
```

在上述情况下，有两个读物，`person.articles`将它们都显示出来，即使这些记录指向同一篇文章。

现在让我们设置`distinct`：

```ruby
class Person
  has_many :readings
  has_many :articles, -> { distinct }, through: :readings
end
```

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 7, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 16, person_id: 7, article_id: 7>, #<Reading id: 17, person_id: 7, article_id: 7>]
```

在上述情况下，仍然有两个读物。但是，`person.articles`只显示一篇文章，因为集合仅加载唯一的记录。

如果您希望确保在插入时，持久化关联中的所有记录都是唯一的（以便您可以确保在检查关联时永远不会找到重复的记录），您应该在表本身上添加唯一索引。例如，如果您有一个名为`readings`的表，并且希望确保文章只能添加到一个人一次，您可以在迁移中添加以下内容：

```ruby
add_index :readings, [:person_id, :article_id], unique: true
```
一旦您拥有了这个唯一索引，尝试将文章添加到一个人两次将会引发`ActiveRecord::RecordNotUnique`错误：

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
ActiveRecord::RecordNotUnique
```

请注意，使用`include?`来检查唯一性存在竞争条件。不要尝试使用`include?`来强制关联中的唯一性。例如，使用上面的文章示例，以下代码将存在竞争条件，因为多个用户可能同时尝试执行此操作：

```ruby
person.articles << article unless person.articles.include?(article)
```

#### 对象何时保存？

当您将一个对象分配给`has_many`关联时，该对象会自动保存（以更新其外键）。如果您在一条语句中分配多个对象，则它们都会被保存。

如果由于验证错误而导致任何保存失败，则赋值语句将返回`false`，并且赋值本身将被取消。

如果父对象（声明`has_many`关联的对象）未保存（即`new_record?`返回`true`），则在添加它们时不会保存子对象。当父对象保存时，所有未保存的关联成员将自动保存。

如果您想将一个对象分配给`has_many`关联而不保存该对象，请使用`collection.build`方法。

### `has_and_belongs_to_many`关联参考

`has_and_belongs_to_many`关联创建了与另一个模型的多对多关系。在数据库术语中，这通过一个包含指向每个类的外键的中间连接表将两个类关联起来。

#### `has_and_belongs_to_many`添加的方法

当您声明一个`has_and_belongs_to_many`关联时，声明类会自动获得与关联相关的几个方法：

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

在所有这些方法中，`collection`被替换为作为`has_and_belongs_to_many`的第一个参数传递的符号，并且`collection_singular`被替换为该符号的单数形式。例如，给定以下声明：

```ruby
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

`Part`模型的每个实例都将具有这些方法：

```ruby
assemblies
assemblies<<(object, ...)
assemblies.delete(object, ...)
assemblies.destroy(object, ...)
assemblies=(objects)
assembly_ids
assembly_ids=(ids)
assemblies.clear
assemblies.empty?
assemblies.size
assemblies.find(...)
assemblies.where(...)
assemblies.exists?(...)
assemblies.build(attributes = {}, ...)
assemblies.create(attributes = {})
assemblies.create!(attributes = {})
assemblies.reload
```

##### 附加列方法

如果`has_and_belongs_to_many`关联的连接表除了两个外键之外还有其他列，则这些列将作为属性添加到通过该关联检索的记录中。带有附加属性返回的记录始终是只读的，因为Rails无法保存对这些属性的更改。

警告：在`has_and_belongs_to_many`关联的连接表上使用额外属性已被弃用。如果您需要在连接两个模型的多对多关系的表上使用此类复杂行为，应该使用`has_many :through`关联而不是`has_and_belongs_to_many`。

##### `collection`

`collection`方法返回与所有关联对象相关的关系。如果没有关联对象，则返回一个空的关系。

```ruby
@assemblies = @part.assemblies
```

##### `collection<<(object, ...)`

[`collection<<`][]方法通过在连接表中创建记录将一个或多个对象添加到集合中。

```ruby
@part.assemblies << @assembly1
```

注意：此方法别名为`collection.concat`和`collection.push`。

##### `collection.delete(object, ...)`

[`collection.delete`][]方法通过在连接表中删除记录来从集合中删除一个或多个对象。这不会销毁对象。

```ruby
@part.assemblies.delete(@assembly1)
```

##### `collection.destroy(object, ...)`

[`collection.destroy`][]方法通过在连接表中删除记录来从集合中删除一个或多个对象。这不会销毁对象。

```ruby
@part.assemblies.destroy(@assembly1)
```

##### `collection=(objects)`

`collection=`方法使集合仅包含提供的对象，通过适当地添加和删除。更改将持久保存到数据库中。

##### `collection_singular_ids`

`collection_singular_ids`方法返回集合中对象的id数组。

```ruby
@assembly_ids = @part.assembly_ids
```

##### `collection_singular_ids=(ids)`

`collection_singular_ids=`方法使集合仅包含由提供的主键值标识的对象，通过适当地添加和删除。更改将持久保存到数据库中。
##### `collection.clear`

[`collection.clear`][] 方法通过从连接表中删除行来从集合中删除每个对象。这不会销毁关联的对象。

##### `collection.empty?`

[`collection.empty?`][] 方法如果集合不包含任何关联对象，则返回 `true`。

```html+erb
<% if @part.assemblies.empty? %>
  This part is not used in any assemblies
<% end %>
```

##### `collection.size`

[`collection.size`][] 方法返回集合中对象的数量。

```ruby
@assembly_count = @part.assemblies.size
```

##### `collection.find(...)`

[`collection.find`][] 方法在集合的表中查找对象。

```ruby
@assembly = @part.assemblies.find(1)
```

##### `collection.where(...)`

[`collection.where`][] 方法根据提供的条件在集合中查找对象，但是对象是惰性加载的，这意味着只有在访问对象时才会查询数据库。

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

##### `collection.exists?(...)`

[`collection.exists?`][] 方法检查集合的表中是否存在满足提供条件的对象。

##### `collection.build(attributes = {})`

[`collection.build`][] 方法返回关联类型的新对象。该对象将从传递的属性实例化，并创建通过连接表的链接，但关联对象尚未保存。

```ruby
@assembly = @part.assemblies.build({ assembly_name: "Transmission housing" })
```

##### `collection.create(attributes = {})`

[`collection.create`][] 方法返回关联类型的新对象。该对象将从传递的属性实例化，并创建通过连接表的链接，并且一旦通过关联模型上指定的所有验证，关联对象将被保存。

```ruby
@assembly = @part.assemblies.create({ assembly_name: "Transmission housing" })
```

##### `collection.create!(attributes = {})`

与 `collection.create` 相同，但如果记录无效，则引发 `ActiveRecord::RecordInvalid`。

##### `collection.reload`

[`collection.reload`][] 方法返回所有关联对象的关系，强制进行数据库读取。如果没有关联对象，则返回一个空的关系。

```ruby
@assemblies = @part.assemblies.reload
```

#### `has_and_belongs_to_many` 的选项

虽然 Rails 使用智能默认值，在大多数情况下都能很好地工作，但有时您可能希望自定义 `has_and_belongs_to_many` 关联引用的行为。通过在创建关联时传递选项，可以轻松实现这些自定义。例如，此关联使用了两个选项：

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { readonly },
                                       autosave: true
end
```

[`has_and_belongs_to_many`][] 关联支持以下选项：

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
* `:validate`

##### `:association_foreign_key`

按照约定，Rails 假设连接表中用于保存指向其他模型的外键的列是该模型的名称加上后缀 `_id`。`association_foreign_key` 选项允许您直接设置外键的名称：

提示：在设置多对多自连接时，`foreign_key` 和 `association_foreign_key` 选项非常有用。例如：

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:autosave`

如果将 `:autosave` 选项设置为 `true`，Rails 将保存任何加载的关联成员，并销毁标记为销毁的成员，每当保存父对象时。将 `:autosave` 设置为 `false` 不等同于不设置 `:autosave` 选项。如果不存在 `:autosave` 选项，则新的关联对象将被保存，但更新的关联对象将不会被保存。

##### `:class_name`

如果无法从关联名称推导出其他模型的名称，可以使用 `:class_name` 选项提供模型名称。例如，如果一个零件有多个组装件，但包含组装件的实际模型的名称是 `Gadget`，则可以这样设置：

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```

##### `:foreign_key`

按照约定，Rails 假设连接表中用于保存指向此模型的外键的列是该模型的名称加上后缀 `_id`。`foreign_key` 选项允许您直接设置外键的名称：

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:join_table`

如果基于词法顺序的默认连接表名称不是您想要的名称，可以使用 `:join_table` 选项覆盖默认值。
##### `:validate`

如果将 `:validate` 选项设置为 `false`，那么每当保存此对象时，新的关联对象将不会被验证。默认情况下，这是 `true`：当保存此对象时，新的关联对象将被验证。

#### `has_and_belongs_to_many` 的作用域

有时您可能希望自定义 `has_and_belongs_to_many` 使用的查询。可以通过作用域块来实现这样的自定义。例如：

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

您可以在作用域块中使用任何标准的[查询方法](active_record_querying.html)。下面讨论了以下方法：

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

`where` 方法允许您指定关联对象必须满足的条件。

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

您还可以通过哈希设置条件：

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

如果使用哈希样式的 `where`，则通过此关联创建记录将自动使用哈希进行作用域限定。在这种情况下，使用 `@parts.assemblies.create` 或 `@parts.assemblies.build` 将创建 `factory` 列的值为 "Seattle" 的组装件。

##### `extending`

`extending` 方法指定要扩展关联代理的命名模块。关联扩展在[本指南的后面](#association-extensions)详细讨论。

##### `group`

`group` 方法提供一个属性名称，用于使用 `GROUP BY` 子句在查找器 SQL 中对结果集进行分组。

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```

##### `includes`

您可以使用 `includes` 方法指定在使用此关联时应预加载的二级关联。

##### `limit`

`limit` 方法允许您限制通过关联获取的对象的总数。

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```

##### `offset`

`offset` 方法允许您指定通过关联获取对象的起始偏移量。例如，如果设置 `offset(11)`，它将跳过前11条记录。

##### `order`

`order` 方法指定将接收到的关联对象的顺序（使用 SQL `ORDER BY` 子句使用的语法）。

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```

##### `readonly`

如果使用 `readonly` 方法，则在通过关联检索时，关联对象将为只读。

##### `select`

`select` 方法允许您覆盖用于检索关联对象的 SQL `SELECT` 子句。默认情况下，Rails 检索所有列。

##### `distinct`

使用 `distinct` 方法从集合中删除重复项。

#### 何时保存对象？

当将对象分配给 `has_and_belongs_to_many` 关联时，该对象会自动保存（以更新连接表）。如果在一个语句中分配多个对象，则它们都会保存。

如果由于验证错误而导致其中任何一个保存失败，则赋值语句将返回 `false`，并且赋值本身将被取消。

如果父对象（声明 `has_and_belongs_to_many` 关联的对象）未保存（即 `new_record?` 返回 `true`），则在添加它们时不会保存子对象。当保存父对象时，所有未保存的关联成员将自动保存。

如果要将对象分配给 `has_and_belongs_to_many` 关联而不保存对象，请使用 `collection.build` 方法。

### 关联回调

普通回调钩子进入 Active Record 对象的生命周期，允许您在各个点上使用这些对象。例如，您可以使用 `:before_save` 回调在对象保存之前触发某些操作。

关联回调类似于普通回调，但它们是由集合的生命周期中的事件触发的。有四个可用的关联回调：

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

您可以通过向关联声明添加选项来定义关联回调。例如：

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_credit_limit

  def check_credit_limit(book)
    # ...
  end
end
```

Rails将被添加或删除的对象传递给回调函数。
您可以将回调堆叠在单个事件上，通过将它们作为数组传递：

```ruby
class Author < ApplicationRecord
  has_many :books,
    before_add: [:check_credit_limit, :calculate_shipping_charges]

  def check_credit_limit(book)
    # ...
  end

  def calculate_shipping_charges(book)
    # ...
  end
end
```

如果`before_add`回调抛出`:abort`，对象将不会被添加到集合中。同样，如果`before_remove`回调抛出`:abort`，对象将不会从集合中移除：

```ruby
# 如果达到了限制，书籍将不会被添加
def check_credit_limit(book)
  throw(:abort) if limit_reached?
end
```

注意：这些回调仅在通过关联集合添加或删除关联对象时调用：

```ruby
# 触发`before_add`回调
author.books << book
author.books = [book, book2]

# 不触发`before_add`回调
book.update(author_id: 1)
```

### 关联扩展

您不仅限于Rails自动构建到关联代理对象中的功能。您还可以通过匿名模块扩展这些对象，添加新的查找器、创建器或其他方法。例如：

```ruby
class Author < ApplicationRecord
  has_many :books do
    def find_by_book_prefix(book_number)
      find_by(category_id: book_number[0..2])
    end
  end
end
```

如果您有一个应该由许多关联共享的扩展，您可以使用一个命名扩展模块。例如：

```ruby
module FindRecentExtension
  def find_recent
    where("created_at > ?", 5.days.ago)
  end
end

class Author < ApplicationRecord
  has_many :books, -> { extending FindRecentExtension }
end

class Supplier < ApplicationRecord
  has_many :deliveries, -> { extending FindRecentExtension }
end
```

扩展可以使用`proxy_association`访问器的这三个属性引用关联代理的内部：

* `proxy_association.owner`返回关联所属的对象。
* `proxy_association.reflection`返回描述关联的反射对象。
* `proxy_association.target`返回`belongs_to`或`has_one`的关联对象，或者返回`has_many`或`has_and_belongs_to_many`的关联对象集合。

### 使用关联所有者进行关联范围限定

在需要对关联范围进行更多控制的情况下，可以将关联所有者作为单个参数传递给作用域块。但是，请注意，将不再能够预加载关联。

```ruby
class Supplier < ApplicationRecord
  has_one :account, ->(supplier) { where active: supplier.active? }
end
```

单表继承（STI）
------------------------------

有时，您可能希望在不同的模型之间共享字段和行为。假设我们有Car、Motorcycle和Bicycle模型。我们希望为它们所有的模型共享`color`和`price`字段以及一些方法，但是对于每个模型都有一些特定的行为和分离的控制器。

首先，让我们生成基础的Vehicle模型：

```bash
$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}
```

您是否注意到我们添加了一个"type"字段？由于所有模型将保存在单个数据库表中，Rails将在此列中保存正在保存的模型的名称。在我们的示例中，可以是"Car"、"Motorcycle"或"Bicycle"。如果表中没有"type"字段，STI将无法工作。

接下来，我们将生成从Vehicle继承的Car模型。为此，我们可以使用`--parent=PARENT`选项，它将生成一个从指定父类继承且没有相应迁移的模型（因为表已经存在）。

例如，要生成Car模型：

```bash
$ bin/rails generate model car --parent=Vehicle
```

生成的模型将如下所示：

```ruby
class Car < Vehicle
end
```

这意味着Vehicle添加的所有行为对于Car也是可用的，例如关联、公共方法等。

创建一辆汽车将在`vehicles`表中保存它，并将"Car"作为`type`字段：

```ruby
Car.create(color: 'Red', price: 10000)
```

将生成以下SQL：

```sql
INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

查询汽车记录将仅搜索车辆类型为汽车的记录：

```ruby
Car.all
```

将运行类似于以下的查询：

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```

委托类型
----------------

[`单表继承（STI）`](#单表继承sti)在子类和其属性之间的差异很小，并且包括您需要创建单个表的所有子类的所有属性时效果最好。

这种方法的缺点是会导致表的膨胀。因为它甚至会包括只有特定子类使用的属性。

在下面的示例中，有两个继承自相同"Entry"类的Active Record模型，该类包括`subject`属性。
```ruby
# Schema: entries[ id, type, subject, created_at, updated_at]
class Entry < ApplicationRecord
end

class Comment < Entry
end

class Message < Entry
end
```

委托类型通过 `delegated_type` 解决了这个问题。

为了使用委托类型，我们必须以特定的方式对数据进行建模。要求如下：

* 有一个超类，它在其表中存储所有子类之间共享的属性。
* 每个子类必须继承自超类，并且将为其特定的任何其他属性拥有一个单独的表。

这样就不需要在一个表中定义意外共享在所有子类之间的属性。

为了将其应用到上面的示例中，我们需要重新生成我们的模型。
首先，让我们生成作为超类的基本 `Entry` 模型：

```bash
$ bin/rails generate model entry entryable_type:string entryable_id:integer
```

然后，我们将为委托生成新的 `Message` 和 `Comment` 模型：

```bash
$ bin/rails generate model message subject:string body:string
$ bin/rails generate model comment content:string
```

运行生成器后，我们应该得到以下模型：

```ruby
# Schema: entries[ id, entryable_type, entryable_id, created_at, updated_at ]
class Entry < ApplicationRecord
end

# Schema: messages[ id, subject, body, created_at, updated_at ]
class Message < ApplicationRecord
end

# Schema: comments[ id, content, created_at, updated_at ]
class Comment < ApplicationRecord
end
```

### 声明 `delegated_type`

首先，在超类 `Entry` 中声明一个 `delegated_type`。

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
end
```

`entryable` 参数指定用于委托的字段，并将 `Message` 和 `Comment` 作为委托类包含其中。

`Entry` 类有 `entryable_type` 和 `entryable_id` 字段。这是在 `delegated_type` 定义中将名称 `entryable` 添加了 `_type`、`_id` 后缀的字段。
`entryable_type` 存储委托对象的子类名称，`entryable_id` 存储委托对象子类的记录 id。

接下来，我们必须定义一个模块来实现这些委托类型，通过在 `has_one` 关联中声明 `as: :entryable` 参数。

```ruby
module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

然后在子类中包含创建的模块。

```ruby
class Message < ApplicationRecord
  include Entryable
end

class Comment < ApplicationRecord
  include Entryable
end
```

完成这个定义后，我们的 `Entry` 委托者现在提供以下方法：

| 方法 | 返回值 |
|---|---|
| `Entry#entryable_class` | Message 或 Comment |
| `Entry#entryable_name` | "message" 或 "comment" |
| `Entry.messages` | `Entry.where(entryable_type: "Message")` |
| `Entry#message?` | 当 `entryable_type == "Message"` 时返回 true |
| `Entry#message` | 当 `entryable_type == "Message"` 时返回消息记录，否则返回 `nil` |
| `Entry#message_id` | 当 `entryable_type == "Message"` 时返回 `entryable_id`，否则返回 `nil` |
| `Entry.comments` | `Entry.where(entryable_type: "Comment")` |
| `Entry#comment?` | 当 `entryable_type == "Comment"` 时返回 true |
| `Entry#comment` | 当 `entryable_type == "Comment"` 时返回评论记录，否则返回 `nil` |
| `Entry#comment_id` | 当 `entryable_type == "Comment"` 时返回 `entryable_id`，否则返回 `nil` |

### 对象创建

在创建新的 `Entry` 对象时，我们可以同时指定 `entryable` 子类。

```ruby
Entry.create! entryable: Message.new(subject: "hello!")
```

### 添加进一步的委托

我们可以扩展我们的 `Entry` 委托者，并通过定义 `delegates` 并使用多态性到子类来增强它。
例如，将 `Entry` 的 `title` 方法委托给其子类：

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ]
  delegates :title, to: :entryable
end

class Message < ApplicationRecord
  include Entryable

  def title
    subject
  end
end

class Comment < ApplicationRecord
  include Entryable

  def title
    content.truncate(20)
  end
end
```

[`belongs_to`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
[`has_and_belongs_to_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_and_belongs_to_many
[`has_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many
[`has_one`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one
[connection.add_reference]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[foreign_keys]: active_record_migrations.html#foreign-keys
[`config.active_record.automatic_scope_inversing`]: configuring.html#config-active-record-automatic-scope-inversing
[`reset_counters`]: https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-reset_counters
[`collection<<`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-3C-3C
[`collection.build`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-build
[`collection.clear`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-clear
[`collection.create`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create
[`collection.create!`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create-21
[`collection.delete`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-delete
[`collection.destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-destroy
[`collection.empty?`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-empty-3F
[`collection.exists?`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F
[`collection.find`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-find
[`collection.reload`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-reload
[`collection.size`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-size
[`collection.where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
