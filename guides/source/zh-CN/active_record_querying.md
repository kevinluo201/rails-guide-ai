**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cc70f06da31561d3461720649cc42371
Active Record查询接口
=============================

本指南介绍了使用Active Record从数据库中检索数据的不同方法。

阅读本指南后，您将了解到：

* 如何使用各种方法和条件查找记录。
* 如何指定找到的记录的顺序、检索属性、分组和其他属性。
* 如何使用急加载来减少数据检索所需的数据库查询次数。
* 如何使用动态查找方法。
* 如何使用方法链将多个Active Record方法一起使用。
* 如何检查特定记录的存在。
* 如何在Active Record模型上执行各种计算。
* 如何在关系上运行EXPLAIN。

--------------------------------------------------------------------------------

什么是Active Record查询接口？
------------------------------------------

如果您习惯使用原始SQL来查找数据库记录，那么您通常会发现在Rails中有更好的方法来执行相同的操作。在大多数情况下，Active Record可以使您免于使用SQL。

Active Record将为您执行数据库查询，并与大多数数据库系统兼容，包括MySQL、MariaDB、PostgreSQL和SQLite。无论您使用哪个数据库系统，Active Record的方法格式始终相同。

本指南中的代码示例将引用以下一个或多个模型：

提示：除非另有说明，以下所有模型都使用`id`作为主键。

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

```ruby
class Book < ApplicationRecord
  belongs_to :supplier
  belongs_to :author
  has_many :reviews
  has_and_belongs_to_many :orders, join_table: 'books_orders'

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
  scope :out_of_print_and_expensive, -> { out_of_print.where('price > 500') }
  scope :costs_more_than, ->(amount) { where('price > ?', amount) }
end
```

```ruby
class Customer < ApplicationRecord
  has_many :orders
  has_many :reviews
end
```

```ruby
class Order < ApplicationRecord
  belongs_to :customer
  has_and_belongs_to_many :books, join_table: 'books_orders'

  enum :status, [:shipped, :being_packed, :complete, :cancelled]

  scope :created_before, ->(time) { where(created_at: ...time) }
end
```

```ruby
class Review < ApplicationRecord
  belongs_to :customer
  belongs_to :book

  enum :state, [:not_reviewed, :published, :hidden]
end
```

```ruby
class Supplier < ApplicationRecord
  has_many :books
  has_many :authors, through: :books
end
```

![所有书店模型的图表](images/active_record_querying/bookstore_models.png)

从数据库中检索对象
------------------------------------

要从数据库中检索对象，Active Record提供了几种查找方法。每个查找方法允许您传入参数，以在不编写原始SQL的情况下执行特定的数据库查询。

这些方法包括：

* [`annotate`][]
* [`find`][]
* [`create_with`][]
* [`distinct`][]
* [`eager_load`][]
* [`extending`][]
* [`extract_associated`][]
* [`from`][]
* [`group`][]
* [`having`][]
* [`includes`][]
* [`joins`][]
* [`left_outer_joins`][]
* [`limit`][]
* [`lock`][]
* [`none`][]
* [`offset`][]
* [`optimizer_hints`][]
* [`order`][]
* [`preload`][]
* [`readonly`][]
* [`references`][]
* [`reorder`][]
* [`reselect`][]
* [`regroup`][]
* [`reverse_order`][]
* [`select`][]
* [`where`][]

返回集合的查找方法，如`where`和`group`，返回[`ActiveRecord::Relation`][]的实例。查找单个实体的方法，如`find`和`first`，返回模型的单个实例。

`Model.find(options)`的主要操作可以总结如下：

* 将提供的选项转换为等效的SQL查询。
* 执行SQL查询，并从数据库中检索相应的结果。
* 为每一行结果实例化适当模型的等效Ruby对象。
* 运行`after_find`，然后是`after_initialize`回调（如果有）。

### 检索单个对象

Active Record提供了几种检索单个对象的方法。

#### `find`

使用[`find`][]方法，您可以检索与任何提供的选项匹配的指定_主键_对应的对象。例如：

```irb
# 查找主键（id）为10的客户。
irb> customer = Customer.find(10)
=> #<Customer id: 10, first_name: "Ryan">
```

以上的SQL等效语句为：

```sql
SELECT * FROM customers WHERE (customers.id = 10) LIMIT 1
```

如果找不到匹配的记录，`find`方法将引发`ActiveRecord::RecordNotFound`异常。

您还可以使用此方法查询多个对象。调用`find`方法并传入一个主键数组。返回的将是一个包含所有匹配的记录的数组，供应用_主键_。例如：
```irb
# 查找主键为1和10的客户。
irb> customers = Customer.find([1, 10]) # 或者 Customer.find(1, 10)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 10, first_name: "Ryan">]
```

上述代码的SQL等效语句为：

```sql
SELECT * FROM customers WHERE (customers.id IN (1,10))
```

警告：如果没有找到与所有提供的主键匹配的记录，`find`方法将引发`ActiveRecord::RecordNotFound`异常。

#### `take`

[`take`][]方法可以检索一条记录，没有隐式排序。例如：

```irb
irb> customer = Customer.take
=> #<Customer id: 1, first_name: "Lifo">
```

上述代码的SQL等效语句为：

```sql
SELECT * FROM customers LIMIT 1
```

如果没有找到记录，`take`方法将返回`nil`，不会引发异常。

您可以传入一个数字参数给`take`方法，以返回指定数量的结果。例如：

```irb
irb> customers = Customer.take(2)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 220, first_name: "Sara">]
```

上述代码的SQL等效语句为：

```sql
SELECT * FROM customers LIMIT 2
```

[`take!`][]方法与`take`方法的行为完全相同，只是如果没有找到匹配的记录，它会引发`ActiveRecord::RecordNotFound`异常。

提示：检索到的记录可能因数据库引擎而异。

#### `first`

[`first`][]方法按照主键（默认）顺序查找第一条记录。例如：

```irb
irb> customer = Customer.first
=> #<Customer id: 1, first_name: "Lifo">
```

上述代码的SQL等效语句为：

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 1
```

如果没有找到匹配的记录，`first`方法将返回`nil`，不会引发异常。

如果您的[默认作用域](active_record_querying.html#applying-a-default-scope)包含一个order方法，`first`将根据此排序返回第一条记录。

您可以传入一个数字参数给`first`方法，以返回指定数量的结果。例如：

```irb
irb> customers = Customer.first(3)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 2, first_name: "Fifo">, #<Customer id: 3, first_name: "Filo">]
```

上述代码的SQL等效语句为：

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 3
```

在使用`order`进行排序的集合上，`first`将返回按指定属性进行排序的第一条记录。

```irb
irb> customer = Customer.order(:first_name).first
=> #<Customer id: 2, first_name: "Fifo">
```

上述代码的SQL等效语句为：

```sql
SELECT * FROM customers ORDER BY customers.first_name ASC LIMIT 1
```

[`first!`][]方法与`first`方法的行为完全相同，只是如果没有找到匹配的记录，它会引发`ActiveRecord::RecordNotFound`异常。

#### `last`

[`last`][]方法按照主键（默认）顺序查找最后一条记录。例如：

```irb
irb> customer = Customer.last
=> #<Customer id: 221, first_name: "Russel">
```

上述代码的SQL等效语句为：

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 1
```

如果没有找到匹配的记录，`last`方法将返回`nil`，不会引发异常。

如果您的[默认作用域](active_record_querying.html#applying-a-default-scope)包含一个order方法，`last`将根据此排序返回最后一条记录。

您可以传入一个数字参数给`last`方法，以返回指定数量的结果。例如：

```irb
irb> customers = Customer.last(3)
=> [#<Customer id: 219, first_name: "James">, #<Customer id: 220, first_name: "Sara">, #<Customer id: 221, first_name: "Russel">]
```

上述代码的SQL等效语句为：

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 3
```

在使用`order`进行排序的集合上，`last`将返回按指定属性进行排序的最后一条记录。

```irb
irb> customer = Customer.order(:first_name).last
=> #<Customer id: 220, first_name: "Sara">
```

上述代码的SQL等效语句为：

```sql
SELECT * FROM customers ORDER BY customers.first_name DESC LIMIT 1
```

[`last!`][]方法与`last`方法的行为完全相同，只是如果没有找到匹配的记录，它会引发`ActiveRecord::RecordNotFound`异常。

#### `find_by`

[`find_by`][]方法查找与某些条件匹配的第一条记录。例如：

```irb
irb> Customer.find_by first_name: 'Lifo'
=> #<Customer id: 1, first_name: "Lifo">

irb> Customer.find_by first_name: 'Jon'
=> nil
```

等效于以下代码：

```ruby
Customer.where(first_name: 'Lifo').take
```

上述代码的SQL等效语句为：

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Lifo') LIMIT 1
```

请注意，上述SQL中没有`ORDER BY`。如果您的`find_by`条件可以匹配多条记录，您应该[应用排序](#ordering)以确保确定性结果。

[`find_by!`][]方法的行为与`find_by`完全相同，唯一的区别是如果找不到匹配的记录，它会引发`ActiveRecord::RecordNotFound`异常。例如：

```irb
irb> Customer.find_by! first_name: 'does not exist'
ActiveRecord::RecordNotFound
```

这等同于编写以下代码：

```ruby
Customer.where(first_name: 'does not exist').take!
```


### 批量检索多个对象

我们经常需要迭代处理大量的记录，比如向一大批客户发送通讯，或者导出数据。

这种方法可能看起来很简单：

```ruby
# 如果表很大，这可能会消耗太多的内存。
Customer.all.each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

但是随着表的大小增加，这种方法变得越来越不实用，因为`Customer.all.each`指示Active Record在一次遍历中获取整个表，为每一行构建一个模型对象，然后将整个模型对象数组保存在内存中。实际上，如果我们有大量的记录，整个集合可能会超过可用的内存量。

Rails提供了两种方法来解决这个问题，将记录分成适合内存的批次进行处理。第一种方法是`find_each`，它检索一批记录，然后将每个记录作为模型对象逐个传递给块。第二种方法是`find_in_batches`，它检索一批记录，然后将整个批次作为模型对象数组传递给块。

提示：`find_each`和`find_in_batches`方法适用于批量处理大量记录的情况，这些记录无法一次性全部放入内存中。如果您只需要循环遍历一千条记录，常规的查找方法是首选的选项。

#### `find_each`

[`find_each`][]方法按批次检索记录，然后将每个记录作为模型对象逐个传递给块。在下面的示例中，`find_each`以每次1000条的批次检索客户记录，并逐个将它们传递给块：

```ruby
Customer.find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

这个过程会重复进行，根据需要获取更多的批次，直到处理完所有的记录。

`find_each`可以用于模型类，如上所示，也可以用于关联关系：

```ruby
Customer.where(weekly_subscriber: true).find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

只要它们没有排序，因为该方法需要在内部强制排序以进行迭代。

如果接收者中存在排序，则行为取决于标志[`config.active_record.error_on_ignored_order`][]。如果为true，则引发`ArgumentError`异常，否则忽略排序并发出警告，这是默认行为。可以使用选项`:error_on_ignore`覆盖此行为，下面会解释。

##### `find_each`的选项

**`:batch_size`**

`:batch_size`选项允许您指定每个批次要检索的记录数，在传递给块之前逐个传递。例如，要以每批5000条记录的方式检索记录：

```ruby
Customer.find_each(batch_size: 5000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:start`**

默认情况下，记录按照主键的升序进行获取。`start`选项允许您在最低ID不是您所需的ID时配置序列的第一个ID。例如，如果您想要恢复一个中断的批处理过程，只发送给从2000开始的客户：

```ruby
Customer.find_each(start: 2000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:finish`**

与`start`选项类似，`finish`选项允许您在最高ID不是您所需的ID时配置序列的最后一个ID。例如，如果您想要使用基于`start`和`finish`的记录子集运行批处理，只发送给从2000开始到10000的客户：

```ruby
Customer.find_each(start: 2000, finish: 10000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

另一个例子是如果您想要多个工作进程处理相同的处理队列。您可以通过为每个工作进程设置适当的`start`和`finish`选项，使每个工作进程处理10000条记录。

**`:error_on_ignore`**

覆盖应用程序配置，指定在关系中存在排序时是否应引发错误。

**`:order`**

指定主键的排序顺序（可以是`:asc`或`:desc`）。默认为`:asc`。
```ruby
Customer.find_each(order: :desc) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

#### `find_in_batches`

[`find_in_batches`][] 方法与 `find_each` 类似，都是检索记录的批处理方法。不同之处在于，`find_in_batches` 将批次作为模型数组传递给块，而不是逐个传递。以下示例将一次向提供的块传递最多 1000 个客户的数组，最后一个块包含任何剩余的客户：

```ruby
# 每次给 add_customers 传递一个包含 1000 个客户的数组。
Customer.find_in_batches do |customers|
  export.add_customers(customers)
end
```

`find_in_batches` 可以用于模型类，如上所示，也可以用于关系：

```ruby
# 每次给 add_customers 传递一个包含 1000 个最近活跃客户的数组。
Customer.recently_active.find_in_batches do |customers|
  export.add_customers(customers)
end
```

只要它们没有排序，因为该方法需要在内部强制排序以进行迭代。

##### `find_in_batches` 的选项

`find_in_batches` 方法接受与 `find_each` 相同的选项：

**`:batch_size`**

与 `find_each` 一样，`batch_size` 确定每个组中将检索多少条记录。例如，可以指定每次检索 2500 条记录的批次：

```ruby
Customer.find_in_batches(batch_size: 2500) do |customers|
  export.add_customers(customers)
end
```

**`:start`**

`start` 选项允许指定从哪个 ID 开始选择记录。如前所述，默认情况下，按照主键的升序获取记录。例如，要检索从 ID 5000 开始的客户，每次检索 2500 条记录，可以使用以下代码：

```ruby
Customer.find_in_batches(batch_size: 2500, start: 5000) do |customers|
  export.add_customers(customers)
end
```

**`:finish`**

`finish` 选项允许指定要检索的记录的结束 ID。下面的代码显示了按批次检索客户，直到 ID 为 7000 的客户：

```ruby
Customer.find_in_batches(finish: 7000) do |customers|
  export.add_customers(customers)
end
```

**`:error_on_ignore`**

`error_on_ignore` 选项覆盖应用程序配置，指定在关系中存在特定顺序时是否应引发错误。

条件
----------

[`where`][] 方法允许您指定条件以限制返回的记录，表示 SQL 语句的 `WHERE` 部分。条件可以指定为字符串、数组或哈希。

### 纯字符串条件

如果您想要在查找中添加条件，可以直接在其中指定它们，就像 `Book.where("title = 'Introduction to Algorithms'")` 一样。这将找到 `title` 字段值为 'Introduction to Algorithms' 的所有书籍。

警告：将自己的条件构建为纯字符串可能会使您容易受到 SQL 注入攻击。例如，`Book.where("title LIKE '%#{params[:title]}%'")` 是不安全的。有关使用数组处理条件的首选方法，请参阅下一节。

### 数组条件

现在，如果该标题可能会变化，比如来自某个地方的参数？则查找将采用以下形式：

```ruby
Book.where("title = ?", params[:title])
```

Active Record 将第一个参数视为条件字符串，任何其他参数都将替换其中的问号 `(?)`。

如果要指定多个条件：

```ruby
Book.where("title = ? AND out_of_print = ?", params[:title], false)
```

在此示例中，第一个问号将被 `params[:title]` 中的值替换，第二个问号将被 `false` 的 SQL 表示形式替换，具体取决于适配器。

以下代码非常可取：

```ruby
Book.where("title = ?", params[:title])
```

而不是这段代码：

```ruby
Book.where("title = #{params[:title]}")
```

因为它具有参数安全性。直接将变量放入条件字符串中将变量**原样**传递给数据库。这意味着它将是来自可能具有恶意意图的用户的未转义变量。如果这样做，您将使整个数据库处于风险之中，因为一旦用户发现他们可以利用您的数据库，他们可以对其进行任何操作。永远不要直接将参数放在条件字符串中。

提示：有关 SQL 注入的危险的更多信息，请参阅[Ruby on Rails 安全指南](security.html#sql-injection)。

#### 占位符条件

与参数的 `(?)` 替换样式类似，您还可以在条件字符串中指定键以及相应的键/值哈希：

```ruby
Book.where("created_at >= :start_date AND created_at <= :end_date",
  { start_date: params[:start_date], end_date: params[:end_date] })
```

如果有大量变量条件，这样做可以使代码更易读。

#### 使用 `LIKE` 的条件

尽管条件参数会自动转义以防止 SQL 注入，但 SQL 的 `LIKE` 通配符（即 `%` 和 `_`）**不会**被转义。如果在参数中使用未经过处理的值，可能会导致意外行为。例如：
```ruby
Book.order(:created_at).order(:title)
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY created_at ASC, title ASC
```

You can also use the `reorder` method to replace any existing order with a new one:

```ruby
Book.order(:created_at).reorder(:title)
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY title ASC
```

### Random Ordering

To retrieve records in a random order, you can use the `order` method with the `RANDOM()` function:

```ruby
Book.order("RANDOM()")
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY RANDOM()
```

### Reverse Ordering

To retrieve records in reverse order, you can use the `reverse_order` method:

```ruby
Book.order(:created_at).reverse_order
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY created_at DESC
```

### Custom Ordering

If you need to order records using a custom SQL expression, you can use the `order` method with a string argument:

```ruby
Book.order("CASE WHEN out_of_print = 'true' THEN 0 ELSE 1 END")
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY CASE WHEN out_of_print = 'true' THEN 0 ELSE 1 END
```

### Nulls Ordering

By default, `NULL` values are ordered last in ascending order and first in descending order. If you want to change this behavior, you can use the `nulls_first` or `nulls_last` methods:

```ruby
Book.order(:title).nulls_first
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY title ASC NULLS FIRST
```

```ruby
Book.order(:title).nulls_last
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY title ASC NULLS LAST
```

### Reversing Order

To reverse the order of a relation, you can use the `reverse` method:

```ruby
Book.order(:created_at).reverse
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY created_at DESC
```

### Limit and Offset

To limit the number of records returned from the database, you can use the `limit` method:

```ruby
Book.limit(10)
```

This will generate SQL like this:

```sql
SELECT * FROM books LIMIT 10
```

To skip a certain number of records and return the rest, you can use the `offset` method:

```ruby
Book.offset(5)
```

This will generate SQL like this:

```sql
SELECT * FROM books OFFSET 5
```

You can also chain `limit` and `offset` together:

```ruby
Book.limit(10).offset(5)
```

This will generate SQL like this:

```sql
SELECT * FROM books LIMIT 10 OFFSET 5
```

### Selecting Specific Fields

To select specific fields from the database, you can use the `select` method:

```ruby
Book.select(:title, :author)
```

This will generate SQL like this:

```sql
SELECT title, author FROM books
```

You can also use the `select` method with a string argument to select fields using custom SQL expressions:

```ruby
Book.select("title, author, COUNT(*) as count")
```

This will generate SQL like this:

```sql
SELECT title, author, COUNT(*) as count FROM books
```

### Distinct Records

To retrieve distinct records from the database, you can use the `distinct` method:

```ruby
Book.select(:author).distinct
```

This will generate SQL like this:

```sql
SELECT DISTINCT author FROM books
```

### Grouping Records

To group records together based on a specific field, you can use the `group` method:

```ruby
Book.group(:author)
```

This will generate SQL like this:

```sql
SELECT * FROM books GROUP BY author
```

You can also use the `group` method with multiple fields:

```ruby
Book.group(:author, :category)
```

This will generate SQL like this:

```sql
SELECT * FROM books GROUP BY author, category
```

### Having Conditions

To filter grouped records based on a condition, you can use the `having` method:

```ruby
Book.group(:author).having("COUNT(*) > 5")
```

This will generate SQL like this:

```sql
SELECT * FROM books GROUP BY author HAVING COUNT(*) > 5
```

You can also use the `having` method with a hash condition:

```ruby
Book.group(:author).having(count: 5..10)
```

This will generate SQL like this:

```sql
SELECT * FROM books GROUP BY author HAVING count BETWEEN 5 AND 10
```

### Joins

To join records from multiple tables, you can use the `joins` method:

```ruby
Book.joins(:author)
```

This will generate SQL like this:

```sql
SELECT * FROM books INNER JOIN authors ON authors.id = books.author_id
```

You can also specify the type of join to use:

```ruby
Book.joins("LEFT JOIN authors ON authors.id = books.author_id")
```

This will generate SQL like this:

```sql
SELECT * FROM books LEFT JOIN authors ON authors.id = books.author_id
```

### Eager Loading Associations

To eager load associations and avoid the N+1 query problem, you can use the `includes` method:

```ruby
Book.includes(:author)
```

This will generate SQL like this:

```sql
SELECT * FROM books LEFT OUTER JOIN authors ON authors.id = books.author_id
```

You can also specify multiple associations to eager load:

```ruby
Book.includes(:author, :category)
```

This will generate SQL like this:

```sql
SELECT * FROM books LEFT OUTER JOIN authors ON authors.id = books.author_id LEFT OUTER JOIN categories ON categories.id = books.category_id
```

### Preloading Associations

To preload associations and avoid the N+1 query problem, you can use the `preload` method:

```ruby
Book.preload(:author)
```

This will generate SQL like this:

```sql
SELECT * FROM books
SELECT * FROM authors WHERE authors.id IN (1, 2, 3, ...)
```

You can also specify multiple associations to preload:

```ruby
Book.preload(:author, :category)
```

This will generate SQL like this:

```sql
SELECT * FROM books
SELECT * FROM authors WHERE authors.id IN (1, 2, 3, ...)
SELECT * FROM categories WHERE categories.id IN (1, 2, 3, ...)
```

### References

When using the `includes` or `preload` methods with associations, you may need to use the `references` method to specify the table name:

```ruby
Book.includes(:author).references(:authors)
```

This will generate SQL like this:

```sql
SELECT * FROM books LEFT OUTER JOIN authors ON authors.id = books.author_id
```

### Locking Records

To lock records and prevent them from being modified by other transactions, you can use the `lock` method:

```ruby
Book.lock
```

This will generate SQL like this:

```sql
SELECT * FROM books FOR UPDATE
```

You can also specify the type of lock to use:

```ruby
Book.lock("LOCK IN SHARE MODE")
```

This will generate SQL like this:

```sql
SELECT * FROM books LOCK IN SHARE MODE
```

### Calculations

To perform calculations on records, you can use the `count`, `sum`, `average`, `minimum`, and `maximum` methods:

```ruby
Book.count
```

This will generate SQL like this:

```sql
SELECT COUNT(*) FROM books
```

```ruby
Book.sum(:price)
```

This will generate SQL like this:

```sql
SELECT SUM(price) FROM books
```

```ruby
Book.average(:rating)
```

This will generate SQL like this:

```sql
SELECT AVG(rating) FROM books
```

```ruby
Book.minimum(:published_at)
```

This will generate SQL like this:

```sql
SELECT MIN(published_at) FROM books
```

```ruby
Book.maximum(:published_at)
```

This will generate SQL like this:

```sql
SELECT MAX(published_at) FROM books
```

### Pluck

To retrieve a single column from the database, you can use the `pluck` method:

```ruby
Book.pluck(:title)
```

This will generate SQL like this:

```sql
SELECT title FROM books
```

You can also use the `pluck` method with multiple columns:

```ruby
Book.pluck(:title, :author)
```

This will generate SQL like this:

```sql
SELECT title, author FROM books
```

### Batches

To process records in batches, you can use the `find_each` or `find_in_batches` methods:

```ruby
Book.find_each do |book|
  # Process each book
end
```

This will retrieve records in batches of 1000 (by default) and yield each record to the block.

```ruby
Book.find_in_batches(batch_size: 500) do |books|
  # Process each batch of books
end
```

This will retrieve records in batches of 500 and yield each batch to the block.

### Query Methods

Active Record provides a set of query methods that can be used to build complex queries:

- `where`
- `not`
- `or`
- `and`
- `order`
- `reorder`
- `limit`
- `offset`
- `select`
- `distinct`
- `group`
- `having`
- `joins`
- `includes`
- `preload`
- `references`
- `lock`
- `count`
- `sum`
- `average`
- `minimum`
- `maximum`
- `pluck`
- `find_each`
- `find_in_batches`

These methods can be chained together to build powerful and flexible queries.
```irb
irb> Book.order("title ASC").order("created_at DESC")
SELECT * FROM books ORDER BY title ASC, created_at DESC
```

警告：在大多数数据库系统中，如果使用`select`、`pluck`和`ids`等方法从结果集中选择具有`distinct`的字段，则`order`方法将引发`ActiveRecord::StatementInvalid`异常，除非`order`子句中使用的字段包含在选择列表中。有关从结果集中选择字段的信息，请参阅下一节。

选择特定字段
-------------------------

默认情况下，`Model.find`使用`select *`从结果集中选择所有字段。

要仅从结果集中选择字段的子集，可以通过[`select`][]方法指定子集。

例如，要仅选择`isbn`和`out_of_print`列：

```ruby
Book.select(:isbn, :out_of_print)
# 或者
Book.select("isbn, out_of_print")
```

此查找调用使用的SQL查询将类似于：

```sql
SELECT isbn, out_of_print FROM books
```

请注意，这也意味着您只使用所选字段初始化了一个模型对象。如果尝试访问未在初始化记录中的字段，则会收到以下错误：

```
ActiveModel::MissingAttributeError: missing attribute '<attribute>' for Book
```

其中`<attribute>`是您要求的属性。`id`方法不会引发`ActiveRecord::MissingAttributeError`，因此在处理关联时要小心，因为它们需要`id`方法才能正常工作。

如果您只想在某个字段的唯一值中获取一条记录，可以使用[`distinct`][]：

```ruby
Customer.select(:last_name).distinct
```

这将生成类似于以下的SQL：

```sql
SELECT DISTINCT last_name FROM customers
```

您还可以删除唯一性约束：

```ruby
# 返回唯一的last_names
query = Customer.select(:last_name).distinct

# 返回所有的last_names，即使有重复
query.distinct(false)
```

限制和偏移
----------------

要在`Model.find`发出的SQL上应用`LIMIT`，可以在关系上使用[`limit`][]和[`offset`][]方法指定`LIMIT`。

您可以使用`limit`指定要检索的记录数，并使用`offset`指定在开始返回记录之前要跳过的记录数。例如

```ruby
Customer.limit(5)
```

将返回最多5个客户，因为它没有指定偏移量，它将返回表中的前5个客户。它执行的SQL如下所示：

```sql
SELECT * FROM customers LIMIT 5
```

在此基础上添加`offset`

```ruby
Customer.limit(5).offset(30)
```

将返回从第31个开始的最多5个客户。SQL如下所示：

```sql
SELECT * FROM customers LIMIT 5 OFFSET 30
```

分组
--------

要在查找器发出的SQL上应用`GROUP BY`子句，可以使用[`group`][]方法。

例如，如果要查找订单创建日期的集合：

```ruby
Order.select("created_at").group("created_at")
```

这将为数据库中存在订单的每个日期提供一个单独的`Order`对象。

执行的SQL将类似于：

```sql
SELECT created_at
FROM orders
GROUP BY created_at
```

### 分组项目的总数

要在单个查询中获取分组项目的总数，请在`group`之后调用[`count`][]。

```irb
irb> Order.group(:status).count
=> {"being_packed"=>7, "shipped"=>12}
```

执行的SQL将类似于：

```sql
SELECT COUNT (*) AS count_all, status AS status
FROM orders
GROUP BY status
```


### HAVING条件

SQL使用`HAVING`子句来指定对`GROUP BY`字段的条件。您可以通过在查找中添加[`having`][]方法来将`HAVING`子句添加到`Model.find`发出的SQL中。

例如：

```ruby
Order.select("created_at, sum(total) as total_price").
  group("created_at").having("sum(total) > ?", 200)
```

执行的SQL将类似于：

```sql
SELECT created_at as ordered_date, sum(total) as total_price
FROM orders
GROUP BY created_at
HAVING sum(total) > 200
```

这将返回每个订单对象的日期和总价格，按照它们被订购的日期分组，并且总价大于200美元。

您可以像这样访问返回的每个订单对象的`total_price`：

```ruby
big_orders = Order.select("created_at, sum(total) as total_price")
                  .group("created_at")
                  .having("sum(total) > ?", 200)

big_orders[0].total_price
# 返回第一个订单对象的总价格
```

覆盖条件
---------------------

### `unscope`

您可以使用[`unscope`][]方法指定要删除的某些条件。例如：
```ruby
Book.where('id > 100').limit(20).order('id desc').unscope(:order)
```

执行的 SQL 语句：

```sql
SELECT * FROM books WHERE id > 100 LIMIT 20

-- 没有 `unscope` 的原始查询
SELECT * FROM books WHERE id > 100 ORDER BY id desc LIMIT 20
```

你也可以取消特定的 `where` 子句。例如，这将从 where 子句中删除 `id` 条件：

```ruby
Book.where(id: 10, out_of_print: false).unscope(where: :id)
# SELECT books.* FROM books WHERE out_of_print = 0
```

使用了 `unscope` 的关系会影响到合并到其中的任何关系：

```ruby
Book.order('id desc').merge(Book.unscope(:order))
# SELECT books.* FROM books
```


### `only`

你也可以使用 [`only`][] 方法覆盖条件。例如：

```ruby
Book.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

执行的 SQL 语句：

```sql
SELECT * FROM books WHERE id > 10 ORDER BY id DESC

-- 没有 `only` 的原始查询
SELECT * FROM books WHERE id > 10 ORDER BY id DESC LIMIT 20
```


### `reselect`

[`reselect`][] 方法可以覆盖现有的 select 语句。例如：

```ruby
Book.select(:title, :isbn).reselect(:created_at)
```

执行的 SQL 语句：

```sql
SELECT books.created_at FROM books
```

与不使用 `reselect` 子句的情况进行比较：

```ruby
Book.select(:title, :isbn).select(:created_at)
```

执行的 SQL 语句：

```sql
SELECT books.title, books.isbn, books.created_at FROM books
```

### `reorder`

[`reorder`][] 方法可以覆盖默认的作用域顺序。例如，如果类定义包括以下内容：

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

并执行以下操作：

```ruby
Author.find(10).books
```

执行的 SQL 语句：

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published DESC
```

你可以使用 `reorder` 子句指定不同的排序方式：

```ruby
Author.find(10).books.reorder('year_published ASC')
```

执行的 SQL 语句：

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published ASC
```

### `reverse_order`

[`reverse_order`][] 方法会反转指定的排序子句。

```ruby
Book.where("author_id > 10").order(:year_published).reverse_order
```

执行的 SQL 语句：

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY year_published DESC
```

如果查询中没有指定排序子句，`reverse_order` 会按照主键的逆序进行排序。

```ruby
Book.where("author_id > 10").reverse_order
```

执行的 SQL 语句：

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY books.id DESC
```

`reverse_order` 方法不接受任何参数。

### `rewhere`

[`rewhere`][] 方法可以覆盖现有的命名 `where` 条件。例如：

```ruby
Book.where(out_of_print: true).rewhere(out_of_print: false)
```

执行的 SQL 语句：

```sql
SELECT * FROM books WHERE out_of_print = 0
```

如果没有使用 `rewhere` 子句，where 子句会进行 AND 运算：

```ruby
Book.where(out_of_print: true).where(out_of_print: false)
```

执行的 SQL 语句：

```sql
SELECT * FROM books WHERE out_of_print = 1 AND out_of_print = 0
```



### `regroup`

[`regroup`][] 方法可以覆盖现有的命名 `group` 条件。例如：

```ruby
Book.group(:author).regroup(:id)
```

执行的 SQL 语句：

```sql
SELECT * FROM books GROUP BY id
```

如果没有使用 `regroup` 子句，group 子句会合并在一起：

```ruby
Book.group(:author).group(:id)
```

执行的 SQL 语句：

```sql
SELECT * FROM books GROUP BY author, id
```



空关系
-------------

[`none`][] 方法返回一个可链式操作的空关系，没有记录。返回的关系链上的任何后续条件都将继续生成空关系。这在需要对可能返回零结果的方法或作用域进行链式响应的场景中非常有用。

```ruby
Book.none # 返回一个空的关系，并且不执行任何查询。
```

```ruby
# 下面的 highlighted_reviews 方法预期始终返回一个关系。
Book.first.highlighted_reviews.average(:rating)
# => 返回书籍的平均评分

class Book
  # 如果评论数大于 5，则返回评论，否则将其视为未评论的书籍
  def highlighted_reviews
    if reviews.count > 5
      reviews
    else
      Review.none # 还未达到最低阈值
    end
  end
end
```

只读对象
----------------

Active Record 在关系上提供了 [`readonly`][] 方法，用于明确禁止修改返回的任何对象。任何尝试修改只读记录的操作都将失败，并引发 `ActiveRecord::ReadOnlyRecord` 异常。
```ruby
customer = Customer.readonly.first
customer.visits += 1
customer.save
```

由于`customer`被显式设置为只读对象，上述代码在调用`customer.save`时，如果更新了_visits_的值，将会引发`ActiveRecord::ReadOnlyRecord`异常。

锁定记录以进行更新
------------------

锁定有助于防止在数据库中更新记录时出现竞争条件，并确保原子更新。

Active Record提供了两种锁定机制：

* 乐观锁定
* 悲观锁定

### 乐观锁定

乐观锁定允许多个用户访问同一条记录进行编辑，并假设数据冲突最少。它通过检查是否有其他进程在打开记录后对其进行了更改来实现。如果发生了这种情况并且更新被忽略，将抛出`ActiveRecord::StaleObjectError`异常。

**乐观锁定列**

为了使用乐观锁定，表需要有一个名为`lock_version`的整数类型列。每次记录更新时，Active Record都会递增`lock_version`列。如果更新请求中的`lock_version`字段的值低于数据库中`lock_version`列的当前值，则更新请求将失败，并引发`ActiveRecord::StaleObjectError`异常。

例如：

```ruby
c1 = Customer.find(1)
c2 = Customer.find(1)

c1.first_name = "Sandra"
c1.save

c2.first_name = "Michael"
c2.save # 引发ActiveRecord::StaleObjectError异常
```

然后，您需要通过捕获异常来处理冲突，并根据需要回滚、合并或应用解决冲突所需的业务逻辑。

可以通过设置`ActiveRecord::Base.lock_optimistically = false`来关闭此行为。

要覆盖`lock_version`列的名称，`ActiveRecord::Base`提供了一个名为`locking_column`的类属性：

```ruby
class Customer < ApplicationRecord
  self.locking_column = :lock_customer_column
end
```

### 悲观锁定

悲观锁定使用底层数据库提供的锁定机制。在构建关系时使用`lock`可以在所选行上获得独占锁。使用`lock`的关系通常在事务中包装，以防止死锁条件。

例如：

```ruby
Book.transaction do
  book = Book.lock.first
  book.title = 'Algorithms, second edition'
  book.save!
end
```

上述会话对于MySQL后端会产生以下SQL：

```sql
SQL (0.2ms)   BEGIN
Book Load (0.3ms)   SELECT * FROM books LIMIT 1 FOR UPDATE
Book Update (0.4ms)   UPDATE books SET updated_at = '2009-02-07 18:05:56', title = 'Algorithms, second edition' WHERE id = 1
SQL (0.8ms)   COMMIT
```

您还可以将原始SQL传递给`lock`方法，以允许不同类型的锁。例如，MySQL有一个名为`LOCK IN SHARE MODE`的表达式，您可以锁定记录但仍允许其他查询读取它。要指定此表达式，只需将其作为锁选项传递：

```ruby
Book.transaction do
  book = Book.lock("LOCK IN SHARE MODE").find(1)
  book.increment!(:views)
end
```

注意：您的数据库必须支持您传递给`lock`方法的原始SQL。

如果已经有一个模型实例，您可以使用以下代码一次性启动事务并获取锁定：

```ruby
book = Book.first
book.with_lock do
  # 此块在事务中调用，
  # book已经被锁定。
  book.increment!(:views)
end
```

连接表
------

Active Record提供了两个查找器方法来指定结果SQL上的`JOIN`子句：`joins`和`left_outer_joins`。
虽然`joins`应该用于`INNER JOIN`或自定义查询，但`left_outer_joins`用于使用`LEFT OUTER JOIN`的查询。

### `joins`

有多种方法可以使用[`joins`][]方法。

#### 使用字符串SQL片段

您可以直接提供指定`JOIN`子句的原始SQL给`joins`：

```ruby
Author.joins("INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE")
```

这将产生以下SQL：

```sql
SELECT authors.* FROM authors INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE
```

#### 使用命名关联的数组/哈希

Active Record允许您在使用`joins`方法时，使用模型上定义的关联的名称作为指定这些关联的`JOIN`子句的快捷方式。

以下所有方法都将使用`INNER JOIN`生成预期的连接查询：

##### 连接单个关联

```ruby
Book.joins(:reviews)
```

这将产生：

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
```

或者，用英语表达就是：“返回所有具有评论的书籍的Book对象”。请注意，如果一本书有多个评论，您将看到重复的书籍。如果要获取唯一的书籍，可以使用`Book.joins(:reviews).distinct`。
#### 加入多个关联

```ruby
Book.joins(:author, :reviews)
```

这将产生：

```sql
SELECT books.* FROM books
  INNER JOIN authors ON authors.id = books.author_id
  INNER JOIN reviews ON reviews.book_id = books.id
```

或者，用英文来说：“返回所有至少有一条评论的带有作者的书籍”。请注意，有多个评论的书籍会出现多次。

##### 加入嵌套关联（单层）

```ruby
Book.joins(reviews: :customer)
```

这将产生：

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
```

或者，用英文来说：“返回所有有顾客评论的书籍”。

##### 加入嵌套关联（多层）

```ruby
Author.joins(books: [{ reviews: { customer: :orders } }, :supplier])
```

这将产生：

```sql
SELECT * FROM authors
  INNER JOIN books ON books.author_id = authors.id
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
  INNER JOIN orders ON orders.customer_id = customers.id
INNER JOIN suppliers ON suppliers.id = books.supplier_id
```

或者，用英文来说：“返回所有有评论的书籍的作者，并且这些书籍被顾客订购过，以及这些书籍的供应商”。

#### 在加入的表上指定条件

您可以使用常规的[数组](#array-conditions)和[字符串](#pure-string-conditions)条件在加入的表上指定条件。[哈希条件](#hash-conditions)提供了一种特殊的语法来指定加入的表的条件：

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where('orders.created_at' => time_range).distinct
```

这将找到所有昨天创建订单的顾客，使用`BETWEEN` SQL表达式来比较`created_at`。

另一种更简洁的语法是嵌套哈希条件：

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where(orders: { created_at: time_range }).distinct
```

对于更高级的条件或者重用现有的命名作用域，可以使用[`merge`][]。首先，让我们在`Order`模型中添加一个新的命名作用域：

```ruby
class Order < ApplicationRecord
  belongs_to :customer

  scope :created_in_time_range, ->(time_range) {
    where(created_at: time_range)
  }
end
```

现在我们可以使用`merge`来合并`created_in_time_range`作用域：

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).merge(Order.created_in_time_range(time_range)).distinct
```

这将找到所有昨天创建订单的顾客，再次使用`BETWEEN` SQL表达式。

### `left_outer_joins`

如果您想选择一组记录，无论它们是否有关联记录，您可以使用[`left_outer_joins`][]方法。

```ruby
Customer.left_outer_joins(:reviews).distinct.select('customers.*, COUNT(reviews.*) AS reviews_count').group('customers.id')
```

这将产生：

```sql
SELECT DISTINCT customers.*, COUNT(reviews.*) AS reviews_count FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id GROUP BY customers.id
```

这意味着：“返回所有顾客及其评论数量，无论他们是否有任何评论”。

### `where.associated`和`where.missing`

`associated`和`missing`查询方法允许您根据关联的存在或缺失来选择一组记录。

使用`where.associated`：

```ruby
Customer.where.associated(:reviews)
```

产生：

```sql
SELECT customers.* FROM customers
INNER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NOT NULL
```

这意味着“返回至少有一条评论的所有顾客”。

使用`where.missing`：

```ruby
Customer.where.missing(:reviews)
```

产生：

```sql
SELECT customers.* FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NULL
```

这意味着“返回没有发表任何评论的所有顾客”。

预加载关联
--------------------------

预加载是使用尽可能少的查询来加载`Model.find`返回的对象的关联记录的机制。

### N + 1 查询问题

考虑以下代码，它查找10本书并打印它们作者的姓氏：

```ruby
books = Book.limit(10)

books.each do |book|
  puts book.author.last_name
end
```

这段代码乍一看没问题。但问题在于执行的查询总数。上述代码总共执行了 1 次（查找10本书）+ 10 次（每本书加载作者）= **11** 次查询。

#### 解决 N + 1 查询问题

Active Record 允许您提前指定将要加载的所有关联。

方法有：

* [`includes`][]
* [`preload`][]
* [`eager_load`][]

### `includes`

使用`includes`，Active Record 确保使用尽可能少的查询加载所有指定的关联。

使用`includes`方法重新审视上述情况，我们可以将`Book.limit(10)`重写为预加载作者：

```ruby
books = Book.includes(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```
上面的代码将执行**2**个查询，而原始情况下执行了**11**个查询：

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.book_id IN (1,2,3,4,5,6,7,8,9,10)
```

#### 预加载多个关联

Active Record允许您使用单个`Model.find`调用使用数组、哈希或嵌套的数组/哈希来预加载任意数量的关联。

##### 多个关联的数组

```ruby
Customer.includes(:orders, :reviews)
```

这将加载所有客户及其关联的每个订单和评论。

##### 嵌套关联的哈希

```ruby
Customer.includes(orders: { books: [:supplier, :author] }).find(1)
```

这将找到id为1的客户，并预加载其所有关联的订单、所有订单的书籍，以及每本书的作者和供应商。

#### 在预加载的关联上指定条件

尽管Active Record允许您像`joins`一样在预加载的关联上指定条件，但建议使用[joins](#joining-tables)代替。

但是如果必须这样做，您可以像平常一样使用`where`。

```ruby
Author.includes(:books).where(books: { out_of_print: true })
```

这将生成一个包含`LEFT OUTER JOIN`的查询，而`joins`方法将生成一个使用`INNER JOIN`函数的查询。

```sql
  SELECT authors.id AS t0_r0, ... books.updated_at AS t1_r5 FROM authors LEFT OUTER JOIN books ON books.author_id = authors.id WHERE (books.out_of_print = 1)
```

如果没有`where`条件，这将生成正常的两个查询集。

注意：只有在传递给`where`的参数是哈希时，才能像这样使用`where`。对于SQL片段，您需要使用`references`来强制连接的表：

```ruby
Author.includes(:books).where("books.out_of_print = true").references(:books)
```

在这种`includes`查询的情况下，如果没有任何作者的书籍，所有作者仍将被加载。通过使用`joins`（内连接），连接条件**必须**匹配，否则将不返回任何记录。

注意：如果一个关联作为连接的一部分被急加载，那么自定义选择子句中的任何字段都不会出现在加载的模型上。这是因为它们可能出现在父记录上，也可能出现在子记录上，所以是模棱两可的。

### `preload`

使用`preload`，Active Record使用每个关联一个查询来加载每个指定的关联。

重新访问N + 1查询问题，我们可以将`Book.limit(10)`重写为预加载作者：

```ruby
books = Book.preload(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

上面的代码将执行**2**个查询，而原始情况下执行了**11**个查询：

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.book_id IN (1,2,3,4,5,6,7,8,9,10)
```

注意：`preload`方法与`includes`方法一样，使用数组、哈希或嵌套的数组/哈希以与`Model.find`调用一样的方式加载任意数量的关联。然而，与`includes`方法不同的是，无法为预加载的关联指定条件。

### `eager_load`

使用`eager_load`，Active Record使用`LEFT OUTER JOIN`加载所有指定的关联。

重新访问N + 1查询问题，我们可以将`Book.limit(10)`重写为作者：

```ruby
books = Book.eager_load(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

上面的代码将执行**2**个查询，而原始情况下执行了**11**个查询：

```sql
SELECT DISTINCT books.id FROM books LEFT OUTER JOIN authors ON authors.book_id = books.id LIMIT 10
SELECT books.id AS t0_r0, books.last_name AS t0_r1, ...
  FROM books LEFT OUTER JOIN authors ON authors.book_id = books.id
  WHERE books.id IN (1,2,3,4,5,6,7,8,9,10)
```

注意：`eager_load`方法与`includes`方法一样，使用数组、哈希或嵌套的数组/哈希以与`Model.find`调用一样的方式加载任意数量的关联。而且，与`includes`方法一样，您可以为急加载的关联指定条件。

### `strict_loading`

急加载可以防止N + 1查询，但您可能仍然会惰性加载一些关联。为了确保没有关联被惰性加载，您可以启用[`strict_loading`][]。

通过在关系上启用严格加载模式，如果记录尝试惰性加载关联，则会引发`ActiveRecord::StrictLoadingViolationError`：

```ruby
user = User.strict_loading.first
user.comments.to_a # 引发ActiveRecord::StrictLoadingViolationError
```


作用域
------
作用域允许您指定常用的查询，这些查询可以在关联对象或模型上作为方法调用引用。通过这些作用域，您可以使用之前介绍的所有方法，例如`where`、`joins`和`includes`。所有作用域的主体应该返回一个`ActiveRecord::Relation`或`nil`，以允许进一步调用它的方法（例如其他作用域）。

要定义一个简单的作用域，我们在类内部使用[`scope`][]方法，传递在调用此作用域时要运行的查询：

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

要调用此`out_of_print`作用域，我们可以在类上调用它：

```irb
irb> Book.out_of_print
=> #<ActiveRecord::Relation> # 所有已绝版的书籍
```

或者在由`Book`对象组成的关联上调用它：

```irb
irb> author = Author.first
irb> author.books.out_of_print
=> #<ActiveRecord::Relation> # `author`的所有已绝版的书籍
```

作用域也可以在作用域内部进行链式调用：

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :out_of_print_and_expensive, -> { out_of_print.where("price > 500") }
end
```


### 传递参数

作用域可以接受参数：

```ruby
class Book < ApplicationRecord
  scope :costs_more_than, ->(amount) { where("price > ?", amount) }
end
```

调用作用域时，可以像调用类方法一样传递参数：

```irb
irb> Book.costs_more_than(100.10)
```

然而，这只是复制了类方法为您提供的功能。

```ruby
class Book < ApplicationRecord
  def self.costs_more_than(amount)
    where("price > ?", amount)
  end
end
```

这些方法仍然可以在关联对象上访问：

```irb
irb> author.books.costs_more_than(100.10)
```

### 使用条件

作用域可以使用条件：

```ruby
class Order < ApplicationRecord
  scope :created_before, ->(time) { where(created_at: ...time) if time.present? }
end
```

与其他示例一样，这将类似于类方法的行为。

```ruby
class Order < ApplicationRecord
  def self.created_before(time)
    where(created_at: ...time) if time.present?
  end
end
```

然而，有一个重要的注意事项：作用域始终会返回一个`ActiveRecord::Relation`对象，即使条件计算结果为`false`，而类方法会返回`nil`。如果任何条件返回`false`，这可能会导致在链接类方法时出现`NoMethodError`。

### 应用默认作用域

如果我们希望一个作用域应用于模型的所有查询，我们可以在模型本身中使用[`default_scope`][]方法。

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

当在此模型上执行查询时，SQL查询将如下所示：

```sql
SELECT * FROM books WHERE (out_of_print = false)
```

如果您需要对默认作用域进行更复杂的操作，您可以将其定义为类方法：

```ruby
class Book < ApplicationRecord
  def self.default_scope
    # 应该返回一个ActiveRecord::Relation。
  end
end
```

注意：当作用域参数以`Hash`形式给出时，在创建/构建记录时也会应用`default_scope`。但在更新记录时不会应用。例如：

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

```irb
irb> Book.new
=> #<Book id: nil, out_of_print: false>
irb> Book.unscoped.new
=> #<Book id: nil, out_of_print: nil>
```

请注意，当以`Array`格式给出时，`default_scope`查询参数无法转换为`Hash`以进行默认属性赋值。例如：

```ruby
class Book < ApplicationRecord
  default_scope { where("out_of_print = ?", false) }
end
```

```irb
irb> Book.new
=> #<Book id: nil, out_of_print: nil>
```


### 合并作用域

与`where`子句一样，作用域使用`AND`条件进行合并。

```ruby
class Book < ApplicationRecord
  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }

  scope :recent, -> { where(year_published: 50.years.ago.year..) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
end
```

```irb
irb> Book.out_of_print.old
SELECT books.* FROM books WHERE books.out_of_print = 'true' AND books.year_published < 1969
```

我们可以混合使用`scope`和`where`条件，最终的SQL将包含所有条件，并使用`AND`连接。

```irb
irb> Book.in_print.where(price: ...100)
SELECT books.* FROM books WHERE books.out_of_print = 'false' AND books.price < 100
```

如果我们确实希望最后一个`where`子句生效，则可以使用[`merge`][]。

```irb
irb> Book.in_print.merge(Book.out_of_print)
SELECT books.* FROM books WHERE books.out_of_print = true
```

一个重要的注意事项是，`default_scope`将在`scope`和`where`条件之前添加。


```ruby
class Book < ApplicationRecord
  default_scope { where(year_published: 50.years.ago.year..) }

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

```irb
irb> Book.all
SELECT books.* FROM books WHERE (year_published >= 1969)

irb> Book.in_print
SELECT books.* FROM books WHERE (year_published >= 1969) AND books.out_of_print = false

irb> Book.where('price > 50')
SELECT books.* FROM books WHERE (year_published >= 1969) AND (price > 50)
```

如上所示，`default_scope` 在 `scope` 和 `where` 条件中都被合并。

### 移除所有作用域

如果我们希望出于任何原因移除作用域，可以使用 [`unscoped`][] 方法。这在模型中指定了 `default_scope` 并且不应用于特定查询时非常有用。

```ruby
Book.unscoped.load
```

该方法移除所有作用域，并在表上执行普通查询。

```irb
irb> Book.unscoped.all
SELECT books.* FROM books

irb> Book.where(out_of_print: true).unscoped.all
SELECT books.* FROM books
```

`unscoped` 还可以接受一个块：

```irb
irb> Book.unscoped { Book.out_of_print }
SELECT books.* FROM books WHERE books.out_of_print
```

动态查找器
---------------

对于您在表中定义的每个字段（也称为属性），Active Record 都提供了一个查找器方法。例如，如果您的 `Customer` 模型上有一个名为 `first_name` 的字段，那么您可以从 Active Record 免费获得 `find_by_first_name` 实例方法。如果 `Customer` 模型上还有一个 `locked` 字段，您还可以获得 `find_by_locked` 方法。

您可以在动态查找器的末尾指定感叹号（`!`），以便在它们不返回任何记录时引发 `ActiveRecord::RecordNotFound` 错误，例如 `Customer.find_by_first_name!("Ryan")`。

如果您想通过 `first_name` 和 `orders_count` 进行查找，您可以通过在字段之间简单地键入 "`and`" 来将这些查找器链接在一起。例如，`Customer.find_by_first_name_and_orders_count("Ryan", 5)`。

枚举
-----

枚举允许您为属性定义一个值数组，并通过名称引用它们。存储在数据库中的实际值是映射到这些值之一的整数。

声明枚举将：

* 创建可用于查找具有或不具有枚举值之一的所有对象的作用域
* 创建一个实例方法，用于确定对象是否具有枚举的特定值
* 创建一个实例方法，用于更改对象的枚举值

对于枚举的所有可能值。

例如，给定此 [`enum`][] 声明：

```ruby
class Order < ApplicationRecord
  enum :status, [:shipped, :being_packaged, :complete, :cancelled]
end
```

这些 [作用域](#作用域) 将自动生成，并可用于查找具有或不具有 `status` 的特定值的所有对象：

```irb
irb> Order.shipped
=> #<ActiveRecord::Relation> # 所有状态为 :shipped 的订单
irb> Order.not_shipped
=> #<ActiveRecord::Relation> # 所有状态不为 :shipped 的订单
```

这些实例方法将自动生成，并查询模型是否具有 `status` 枚举的该值：

```irb
irb> order = Order.shipped.first
irb> order.shipped?
=> true
irb> order.complete?
=> false
```

这些实例方法将自动生成，并首先将 `status` 的值更新为指定的值，然后查询状态是否已成功设置为该值：

```irb
irb> order = Order.first
irb> order.shipped!
UPDATE "orders" SET "status" = ?, "updated_at" = ? WHERE "orders"."id" = ?  [["status", 0], ["updated_at", "2019-01-24 07:13:08.524320"], ["id", 1]]
=> true
```

有关枚举的完整文档可以在[此处](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html)找到。


理解方法链
-----------------------------

Active Record 模式实现了[方法链](https://en.wikipedia.org/wiki/Method_chaining)，允许我们以简单直接的方式在多个 Active Record 方法之间进行链式调用。

当前一个调用的方法返回一个 [`ActiveRecord::Relation`][]，如 `all`、`where` 和 `joins` 时，可以在语句中链式调用方法。返回单个对象的方法（参见[检索单个对象部分](#检索单个对象)）必须位于语句的末尾。

下面是一些示例。本指南不会涵盖所有可能性，只是提供一些示例。当调用 Active Record 方法时，查询不会立即生成并发送到数据库。只有在实际需要数据时才会发送查询。因此，下面的每个示例都生成一个查询。

### 从多个表中检索过滤数据
```ruby
Customer
  .select('customers.id, customers.last_name, reviews.body')
  .joins(:reviews)
  .where('reviews.created_at > ?', 1.week.ago)
```

结果应该如下所示：

```sql
SELECT customers.id, customers.last_name, reviews.body
FROM customers
INNER JOIN reviews
  ON reviews.customer_id = customers.id
WHERE (reviews.created_at > '2019-01-08')
```

### 从多个表中检索特定数据

```ruby
Book
  .select('books.id, books.title, authors.first_name')
  .joins(:author)
  .find_by(title: 'Abstraction and Specification in Program Development')
```

以上代码应该生成以下SQL语句：

```sql
SELECT books.id, books.title, authors.first_name
FROM books
INNER JOIN authors
  ON authors.id = books.author_id
WHERE books.title = $1 [["title", "Abstraction and Specification in Program Development"]]
LIMIT 1
```

注意：如果查询匹配多个记录，`find_by`方法将只获取第一个记录并忽略其他记录（参见上面的`LIMIT 1`语句）。

查找或创建新对象
--------------------------

通常情况下，您需要查找一条记录，如果不存在则创建。您可以使用`find_or_create_by`和`find_or_create_by!`方法来实现。

### `find_or_create_by`

[`find_or_create_by`][]方法会检查是否存在具有指定属性的记录。如果不存在，则调用`create`方法。让我们看一个例子。

假设您想要查找一个名为"Andy"的客户，如果不存在，则创建一个。您可以运行以下代码：

```irb
irb> Customer.find_or_create_by(first_name: 'Andy')
=> #<Customer id: 5, first_name: "Andy", last_name: nil, title: nil, visits: 0, orders_count: nil, lock_version: 0, created_at: "2019-01-17 07:06:45", updated_at: "2019-01-17 07:06:45">
```

该方法生成的SQL语句如下所示：

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO customers (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by`方法返回已存在的记录或新记录。在我们的例子中，我们没有名为Andy的客户，所以记录被创建并返回。

新记录可能没有保存到数据库中；这取决于验证是否通过（就像`create`方法一样）。

假设我们想要在创建新记录时将'locked'属性设置为`false`，但我们不想在查询中包含它。所以我们想要查找名为"Andy"的客户，如果该客户不存在，则创建一个名为"Andy"且未锁定的客户。

我们可以用两种方法实现。第一种方法是使用`create_with`：

```ruby
Customer.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

第二种方法是使用块：

```ruby
Customer.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

该块只在创建客户时执行。第二次运行此代码时，块将被忽略。


### `find_or_create_by!`

您还可以使用[`find_or_create_by!`][]方法，如果新记录无效，则引发异常。本指南不涵盖验证，但假设您暂时添加了以下代码到您的`Customer`模型中：

```ruby
validates :orders_count, presence: true
```

如果尝试创建一个没有传递`orders_count`的新`Customer`，记录将无效并引发异常：

```irb
irb> Customer.find_or_create_by!(first_name: 'Andy')
ActiveRecord::RecordInvalid: Validation failed: Orders count can’t be blank
```


### `find_or_initialize_by`

[`find_or_initialize_by`][]方法与`find_or_create_by`方法类似，但它会调用`new`方法而不是`create`方法。这意味着将在内存中创建一个新的模型实例，但不会保存到数据库中。继续使用`find_or_create_by`的示例，我们现在想要查找名为'Nina'的客户：

```irb
irb> nina = Customer.find_or_initialize_by(first_name: 'Nina')
=> #<Customer id: nil, first_name: "Nina", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

irb> nina.persisted?
=> false

irb> nina.new_record?
=> true
```

因为对象尚未存储在数据库中，所以生成的SQL语句如下所示：

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Nina') LIMIT 1
```

当您想要将其保存到数据库中时，只需调用`save`方法：

```irb
irb> nina.save
=> true
```


通过SQL查找
--------------

如果您想要在表中使用自己的SQL查找记录，可以使用[`find_by_sql`][]方法。`find_by_sql`方法将返回一个对象数组，即使底层查询只返回单个记录。例如，您可以运行以下查询：

```irb
irb> Customer.find_by_sql("SELECT * FROM customers INNER JOIN orders ON customers.id = orders.customer_id ORDER BY customers.created_at desc")
=> [#<Customer id: 1, first_name: "Lucas" ...>, #<Customer id: 2, first_name: "Jan" ...>, ...]
```

`find_by_sql`提供了一种简单的方法，可以自定义调用数据库并检索实例化对象。

### `select_all`

`find_by_sql`有一个紧密相关的方法叫做[`connection.select_all`][]。`select_all`将使用自定义的SQL从数据库中检索对象，但不会实例化它们。该方法将返回一个`ActiveRecord::Result`类的实例，调用该实例的`to_a`方法将返回一个哈希数组，其中每个哈希表示一条记录。

```irb
irb> Customer.connection.select_all("SELECT first_name, created_at FROM customers WHERE id = '1'").to_a
=> [{"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"}, {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}]
```


### `pluck`

[`pluck`][]可以用于从当前关系中选择指定列的值。它接受一个列名列表作为参数，并返回具有相应数据类型的指定列的值数组。

```irb
irb> Book.where(out_of_print: true).pluck(:id)
SELECT id FROM books WHERE out_of_print = true
=> [1, 2, 3]

irb> Order.distinct.pluck(:status)
SELECT DISTINCT status FROM orders
=> ["shipped", "being_packed", "cancelled"]

irb> Customer.pluck(:id, :first_name)
SELECT customers.id, customers.first_name FROM customers
=> [[1, "David"], [2, "Fran"], [3, "Jose"]]
```

`pluck`可以替代以下代码：

```ruby
Customer.select(:id).map { |c| c.id }
# 或者
Customer.select(:id).map(&:id)
# 或者
Customer.select(:id, :first_name).map { |c| [c.id, c.first_name] }
```

使用以下代码替代：

```ruby
Customer.pluck(:id)
# 或者
Customer.pluck(:id, :first_name)
```

与`select`不同，`pluck`直接将数据库结果转换为Ruby的`Array`，而不构造`ActiveRecord`对象。这可以提高大型或频繁运行查询的性能。但是，任何模型方法的重写将不可用。例如：

```ruby
class Customer < ApplicationRecord
  def name
    "I am #{first_name}"
  end
end
```

```irb
irb> Customer.select(:first_name).map &:name
=> ["I am David", "I am Jeremy", "I am Jose"]

irb> Customer.pluck(:first_name)
=> ["David", "Jeremy", "Jose"]
```

您不仅可以从单个表中查询字段，还可以查询多个表。

```irb
irb> Order.joins(:customer, :books).pluck("orders.created_at, customers.email, books.title")
```

此外，与`select`和其他`Relation`作用域不同，`pluck`会立即触发查询，因此无法与任何其他作用域链接，但可以与先前构造的作用域一起使用：

```irb
irb> Customer.pluck(:first_name).limit(1)
NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

irb> Customer.limit(1).pluck(:first_name)
=> ["David"]
```

注意：您还应该知道，如果关系对象包含include值，使用`pluck`将触发贪婪加载，即使对于查询来说贪婪加载是不必要的。例如：

```irb
irb> assoc = Customer.includes(:reviews)
irb> assoc.pluck(:id)
SELECT "customers"."id" FROM "customers" LEFT OUTER JOIN "reviews" ON "reviews"."id" = "customers"."review_id"
```

避免这种情况的一种方法是对includes使用`unscope`：

```irb
irb> assoc.unscope(:includes).pluck(:id)
```


### `pick`

[`pick`][]可以用于从当前关系中选择指定列的值。它接受一个列名列表作为参数，并返回具有相应数据类型的指定列的第一行值。
`pick`是`relation.limit(1).pluck(*column_names).first`的简写形式，当您已经有一个限制为一行的关系时，它非常有用。

`pick`可以替代以下代码：

```ruby
Customer.where(id: 1).pluck(:id).first
```

使用以下代码替代：

```ruby
Customer.where(id: 1).pick(:id)
```


### `ids`

[`ids`][]可以用于使用表的主键获取关系的所有ID。

```irb
irb> Customer.ids
SELECT id FROM customers
```

```ruby
class Customer < ApplicationRecord
  self.primary_key = "customer_id"
end
```

```irb
irb> Customer.ids
SELECT customer_id FROM customers
```


对象的存在性
--------------------

如果您只想检查对象是否存在，可以使用[`exists?`][]方法。该方法将使用与`find`相同的查询查询数据库，但不返回对象或对象集合，而是返回`true`或`false`。

```ruby
Customer.exists?(1)
```

`exists?`方法还接受多个值，但是它会在任何一个记录存在时返回`true`。

```ruby
Customer.exists?(id: [1, 2, 3])
# 或者
Customer.exists?(first_name: ['Jane', 'Sergei'])
```

在模型或关系上也可以使用`exists?`方法而不带任何参数。

```ruby
Customer.where(first_name: 'Ryan').exists?
```

以上代码在至少存在一个`first_name`为'Ryan'的客户时返回`true`，否则返回`false`。

```ruby
Customer.exists?
```

以上代码在`customers`表为空时返回`false`，否则返回`true`。

您还可以使用`any?`和`many?`在模型或关系上检查存在性。`many?`将使用SQL的`count`来确定项目是否存在。
```ruby
# 通过模型
Order.any?
# SELECT 1 FROM orders LIMIT 1
Order.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders LIMIT 2)

# 通过命名作用域
Order.shipped.any?
# SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 1
Order.shipped.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 2)

# 通过关联
Book.where(out_of_print: true).any?
Book.where(out_of_print: true).many?

# 通过关联
Customer.first.orders.any?
Customer.first.orders.many?
```


计算
------------

本节以`count`方法为例，但所描述的选项适用于所有子节。

所有计算方法都可以直接在模型上使用：

```irb
irb> Customer.count
SELECT COUNT(*) FROM customers
```

或者在关联上使用：

```irb
irb> Customer.where(first_name: 'Ryan').count
SELECT COUNT(*) FROM customers WHERE (first_name = 'Ryan')
```

您还可以在关联上使用各种查找方法进行复杂计算：

```irb
irb> Customer.includes("orders").where(first_name: 'Ryan', orders: { status: 'shipped' }).count
```

这将执行以下查询：

```sql
SELECT COUNT(DISTINCT customers.id) FROM customers
  LEFT OUTER JOIN orders ON orders.customer_id = customers.id
  WHERE (customers.first_name = 'Ryan' AND orders.status = 0)
```

假设Order具有`enum status: [ :shipped, :being_packed, :cancelled ]`。

### `count`

如果您想查看模型表中有多少条记录，可以调用`Customer.count`，它将返回数量。
如果您想更具体地查找数据库中存在标题的所有客户，可以使用`Customer.count(:title)`。

有关选项，请参见父节[计算](#计算)。

### `average`

如果您想查看表中某个数字的平均值，可以在与表相关的类上调用[`average`][]方法。此方法调用将类似于以下内容：

```ruby
Order.average("subtotal")
```

这将返回一个数字（可能是浮点数，如3.14159265），表示字段中的平均值。

有关选项，请参见父节[计算](#计算)。


### `minimum`

如果您想找到表中某个字段的最小值，可以在与表相关的类上调用[`minimum`][]方法。此方法调用将类似于以下内容：

```ruby
Order.minimum("subtotal")
```

有关选项，请参见父节[计算](#计算)。


### `maximum`

如果您想找到表中某个字段的最大值，可以在与表相关的类上调用[`maximum`][]方法。此方法调用将类似于以下内容：

```ruby
Order.maximum("subtotal")
```

有关选项，请参见父节[计算](#计算)。


### `sum`

如果您想找到表中所有记录的某个字段的总和，可以在与表相关的类上调用[`sum`][]方法。此方法调用将类似于以下内容：

```ruby
Order.sum("subtotal")
```

有关选项，请参见父节[计算](#计算)。


运行EXPLAIN
---------------

您可以在关联上运行[`explain`][]。每个数据库的EXPLAIN输出都不同。

例如，运行

```ruby
Customer.where(id: 1).joins(:orders).explain
```

可能会产生以下结果

```
EXPLAIN SELECT `customers`.* FROM `customers` INNER JOIN `orders` ON `orders`.`customer_id` = `customers`.`id` WHERE `customers`.`id` = 1
+----+-------------+------------+-------+---------------+
| id | select_type | table      | type  | possible_keys |
+----+-------------+------------+-------+---------------+
|  1 | SIMPLE      | customers  | const | PRIMARY       |
|  1 | SIMPLE      | orders     | ALL   | NULL          |
+----+-------------+------------+-------+---------------+
+---------+---------+-------+------+-------------+
| key     | key_len | ref   | rows | Extra       |
+---------+---------+-------+------+-------------+
| PRIMARY | 4       | const |    1 |             |
| NULL    | NULL    | NULL  |    1 | Using where |
+---------+---------+-------+------+-------------+

2 rows in set (0.00 sec)
```

在MySQL和MariaDB下。

Active Record执行了一个漂亮的打印，模拟了相应数据库shell的打印。因此，使用PostgreSQL适配器运行相同的查询将产生以下结果

```
EXPLAIN SELECT "customers".* FROM "customers" INNER JOIN "orders" ON "orders"."customer_id" = "customers"."id" WHERE "customers"."id" = $1 [["id", 1]]
                                  QUERY PLAN
------------------------------------------------------------------------------
 Nested Loop  (cost=4.33..20.85 rows=4 width=164)
    ->  Index Scan using customers_pkey on customers  (cost=0.15..8.17 rows=1 width=164)
          Index Cond: (id = '1'::bigint)
    ->  Bitmap Heap Scan on orders  (cost=4.18..12.64 rows=4 width=8)
          Recheck Cond: (customer_id = '1'::bigint)
          ->  Bitmap Index Scan on index_orders_on_customer_id  (cost=0.00..4.18 rows=4 width=0)
                Index Cond: (customer_id = '1'::bigint)
(7 rows)
```

贪婪加载可能在底层触发多个查询，并且某些查询可能需要先前查询的结果。因此，`explain`实际上会执行查询，然后请求查询计划。例如，
```ruby
Customer.where(id: 1).includes(:orders).explain
```

对于MySQL和MariaDB可能会产生以下结果：

```
EXPLAIN SELECT `customers`.* FROM `customers`  WHERE `customers`.`id` = 1
+----+-------------+-----------+-------+---------------+
| id | select_type | table     | type  | possible_keys |
+----+-------------+-----------+-------+---------------+
|  1 | SIMPLE      | customers | const | PRIMARY       |
+----+-------------+-----------+-------+---------------+
+---------+---------+-------+------+-------+
| key     | key_len | ref   | rows | Extra |
+---------+---------+-------+------+-------+
| PRIMARY | 4       | const |    1 |       |
+---------+---------+-------+------+-------+

1 row in set (0.00 sec)

EXPLAIN SELECT `orders`.* FROM `orders`  WHERE `orders`.`customer_id` IN (1)
+----+-------------+--------+------+---------------+
| id | select_type | table  | type | possible_keys |
+----+-------------+--------+------+---------------+
|  1 | SIMPLE      | orders | ALL  | NULL          |
+----+-------------+--------+------+---------------+
+------+---------+------+------+-------------+
| key  | key_len | ref  | rows | Extra       |
+------+---------+------+------+-------------+
| NULL | NULL    | NULL |    1 | Using where |
+------+---------+------+------+-------------+


1 row in set (0.00 sec)
```

对于PostgreSQL可能会产生以下结果：

```
  Customer Load (0.3ms)  SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1  [["id", 1]]
  Order Load (0.3ms)  SELECT "orders".* FROM "orders" WHERE "orders"."customer_id" = $1  [["customer_id", 1]]
=> EXPLAIN SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1 [["id", 1]]
                                    QUERY PLAN
----------------------------------------------------------------------------------
 Index Scan using customers_pkey on customers  (cost=0.15..8.17 rows=1 width=164)
   Index Cond: (id = '1'::bigint)
(2 rows)
```


### Explain选项

对于支持的数据库和适配器（目前是PostgreSQL和MySQL），可以传递选项以提供更深入的分析。

使用PostgreSQL，以下代码：

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze, :verbose)
```

会产生以下结果：

```sql
EXPLAIN (ANALYZE, VERBOSE) SELECT "shop_accounts".* FROM "shop_accounts" INNER JOIN "customers" ON "customers"."id" = "shop_accounts"."customer_id" WHERE "shop_accounts"."id" = $1 [["id", 1]]
                                                                   QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.30..16.37 rows=1 width=24) (actual time=0.003..0.004 rows=0 loops=1)
   Output: shop_accounts.id, shop_accounts.customer_id, shop_accounts.customer_carrier_id
   Inner Unique: true
   ->  Index Scan using shop_accounts_pkey on public.shop_accounts  (cost=0.15..8.17 rows=1 width=24) (actual time=0.003..0.003 rows=0 loops=1)
         Output: shop_accounts.id, shop_accounts.customer_id, shop_accounts.customer_carrier_id
         Index Cond: (shop_accounts.id = '1'::bigint)
   ->  Index Only Scan using customers_pkey on public.customers  (cost=0.15..8.17 rows=1 width=8) (never executed)
         Output: customers.id
         Index Cond: (customers.id = shop_accounts.customer_id)
         Heap Fetches: 0
 Planning Time: 0.063 ms
 Execution Time: 0.011 ms
(12 rows)
```

使用MySQL或MariaDB，以下代码：

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze)
```

会产生以下结果：

```sql
ANALYZE SELECT `shop_accounts`.* FROM `shop_accounts` INNER JOIN `customers` ON `customers`.`id` = `shop_accounts`.`customer_id` WHERE `shop_accounts`.`id` = 1
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | r_rows | filtered | r_filtered | Extra                          |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
|  1 | SIMPLE      | NULL  | NULL | NULL          | NULL | NULL    | NULL | NULL | NULL   | NULL     | NULL       | no matching row in const table |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
1 row in set (0.00 sec)
```

注意：EXPLAIN和ANALYZE选项在MySQL和MariaDB的版本之间有所不同。
（[MySQL 5.7][MySQL5.7-explain]，[MySQL 8.0][MySQL8-explain]，[MariaDB][MariaDB-explain]）


### 解释EXPLAIN

解释EXPLAIN的输出超出了本指南的范围。以下提示可能有所帮助：

* SQLite3：[EXPLAIN QUERY PLAN](https://www.sqlite.org/eqp.html)

* MySQL：[EXPLAIN Output Format](https://dev.mysql.com/doc/refman/en/explain-output.html)

* MariaDB：[EXPLAIN](https://mariadb.com/kb/en/mariadb/explain/)

* PostgreSQL：[Using EXPLAIN](https://www.postgresql.org/docs/current/static/using-explain.html)
[`ActiveRecord::Relation`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html
[`annotate`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-annotate
[`create_with`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-create_with
[`distinct`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-distinct
[`eager_load`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-eager_load
[`extending`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-extending
[`extract_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-extract_associated
[`find`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find
[`from`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-from
[`group`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-group
[`having`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-having
[`includes`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-includes
[`joins`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-joins
[`left_outer_joins`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-left_outer_joins
[`limit`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-limit
[`lock`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-lock
[`none`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-none
[`offset`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-offset
[`optimizer_hints`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-optimizer_hints
[`order`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-order
[`preload`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-preload
[`readonly`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-readonly
[`references`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-references
[`reorder`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reorder
[`reselect`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reselect
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`reverse_order`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reverse_order
[`select`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-select
[`where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
[`take`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-take
[`take!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-take-21
[`first`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first
[`first!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first-21
[`last`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-last
[`last!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-last-21
[`find_by`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_by
[`find_by!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_by-21
[`config.active_record.error_on_ignored_order`]: configuring.html#config-active-record-error-on-ignored-order
[`find_each`]: https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_each
[`find_in_batches`]: https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_in_batches
[`sanitize_sql_like`]: https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql_like
[`where.not`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods/WhereChain.html#method-i-not
[`or`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-or
[`and`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-and
[`count`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-count
[`unscope`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-unscope
[`only`]: https://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-only
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`strict_loading`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-strict_loading
[`scope`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-scope
[`default_scope`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-default_scope
[`merge`]: https://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-merge
[`unscoped`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-unscoped
[`enum`]: https://api.rubyonrails.org/classes/ActiveRecord/Enum.html#method-i-enum
[`find_or_create_by`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by
[`find_or_create_by!`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by-21
[`find_or_initialize_by`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_initialize_by
[`find_by_sql`]: https://api.rubyonrails.org/classes/ActiveRecord/Querying.html#method-i-find_by_sql
[`connection.select_all`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-select_all
[`pluck`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pluck
[`pick`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pick
[`ids`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-ids
[`exists?`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F
[`average`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-average
[`minimum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-minimum
[`maximum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-maximum
[`sum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-sum
[`explain`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-explain
[MySQL5.7-explain]: https://dev.mysql.com/doc/refman/5.7/en/explain.html
[MySQL8-explain]: https://dev.mysql.com/doc/refman/8.0/en/explain.html
[MariaDB-explain]: https://mariadb.com/kb/en/analyze-and-explain-statements/
