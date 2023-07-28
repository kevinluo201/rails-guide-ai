**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 320082396ef549e27ab4cb837ec975dd
Active Record回调
=======================

本指南将教你如何钩入Active Record对象的生命周期。

阅读完本指南后，你将会了解：

* 在Active Record对象的生命周期中发生的某些事件
* 如何创建回调方法以响应对象生命周期中的事件。
* 如何创建封装回调的常见行为的特殊类。

--------------------------------------------------------------------------------

对象生命周期
---------------------

在Rails应用程序的正常运行过程中，对象可能会被创建、更新和销毁。Active Record提供了钩子函数来控制你的应用程序及其数据。

回调允许你在对象状态改变之前或之后触发逻辑。

```ruby
class Baby < ApplicationRecord
  after_create -> { puts "Congratulations!" }
end
```

```irb
irb> @baby = Baby.create
Congratulations!
```

正如你将看到的，有许多生命周期事件，你可以选择在这些事件之前、之后甚至在它们周围进行钩入。

回调概述
------------------

回调是在对象生命周期的某些时刻被调用的方法。通过回调，可以编写在Active Record对象被创建、保存、更新、删除、验证或从数据库加载时运行的代码。

### 注册回调

为了使用可用的回调，你需要注册它们。你可以将回调实现为普通方法，并使用宏风格的类方法将它们注册为回调：

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  private
    def ensure_login_has_a_value
      if login.blank?
        self.login = email unless email.blank?
      end
    end
end
```

宏风格的类方法也可以接收一个块。如果你的块内的代码非常简短，可以考虑使用这种风格，因为它可以适应一行：

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

或者，你可以将一个proc传递给回调以触发它。

```ruby
class User < ApplicationRecord
  before_create ->(user) { user.name = user.login.capitalize if user.name.blank? }
end
```

最后，你可以定义自己的自定义回调对象，我们将在下面更详细地介绍它 [below](#callback-classes)。

```ruby
class User < ApplicationRecord
  before_create MaybeAddName
end

class MaybeAddName
  def self.before_create(record)
    if record.name.blank?
      record.name = record.login.capitalize
    end
  end
end
```

回调也可以注册为仅在某些生命周期事件上触发，这样可以完全控制回调触发的时间和上下文。

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on也可以接收一个数组
  after_validation :set_location, on: [ :create, :update ]

  private
    def normalize_name
      self.name = name.downcase.titleize
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

将回调方法声明为私有是一种良好的实践。如果将其公开，它们可以从模型之外调用，违反了对象封装的原则。

警告。在回调中避免调用`update`、`save`或其他会对对象产生副作用的方法。例如，在回调中不要调用`update(attribute: "value")`。这可能会改变模型的状态，并可能导致提交过程中出现意外的副作用。相反，你可以在`before_create` / `before_update`或更早的回调中直接安全地赋值（例如，`self.attribute = "value"`）。

可用的回调
-------------------

下面是所有可用的Active Record回调的列表，按照它们在相应操作期间将被调用的顺序列出：

### 创建对象

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


### 更新对象

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


警告。`after_save`在创建和更新时都会运行，但总是在更具体的`after_create`和`after_update`回调之后运行，无论宏调用的顺序如何。

### 销毁对象

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]


注意：`before_destroy`回调应该放在`dependent: :destroy`关联之前（或使用`prepend: true`选项），以确保它们在`dependent: :destroy`删除记录之前执行。

警告。`after_commit`提供的保证与`after_save`、`after_update`和`after_destroy`提供的保证非常不同。例如，如果在`after_save`中发生异常，事务将被回滚，数据将不会被持久化。而在`after_commit`中发生的任何事情都可以保证事务已经完成，并且数据已经持久化到数据库中。更多关于[事务回调](#transaction-callbacks)的内容请参见下文。
### `after_initialize` 和 `after_find`

每当实例化一个 Active Record 对象时，[`after_initialize`][] 回调函数将被调用，无论是直接使用 `new` 还是从数据库加载记录。这可以避免直接覆盖 Active Record 的 `initialize` 方法。

从数据库加载记录时，[`after_find`][] 回调函数将被调用。如果同时定义了 `after_initialize` 和 `after_find`，则 `after_find` 将在 `after_initialize` 之前被调用。

注意：`after_initialize` 和 `after_find` 回调函数没有对应的 `before_*` 回调函数。

它们可以像其他 Active Record 回调函数一样进行注册。

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "你已经初始化了一个对象！"
  end

  after_find do |user|
    puts "你已经找到了一个对象！"
  end
end
```

```irb
irb> User.new
你已经初始化了一个对象！
=> #<User id: nil>

irb> User.first
你已经找到了一个对象！
你已经初始化了一个对象！
=> #<User id: 1>
```


### `after_touch`

[`after_touch`][] 回调函数将在每次触发 Active Record 对象的 touch 时被调用。

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "你已经触摸了一个对象"
  end
end
```

```irb
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
你已经触摸了一个对象
=> true
```

它可以与 `belongs_to` 一起使用：

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    puts '一本书被触摸了'
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      puts '书籍/图书馆被触摸了'
    end
end
```

```irb
irb> @book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @book.touch # 触发 @book.library.touch
一本书被触摸了
书籍/图书馆被触摸了
=> true
```


运行回调函数
-----------------

以下方法会触发回调函数：

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `destroy_by`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update`
* `update!`
* `valid?`

此外，`after_find` 回调函数会被以下查找方法触发：

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

每当类的新对象被初始化时，`after_initialize` 回调函数都会被触发。

注意：`find_by_*` 和 `find_by_*!` 方法是为每个属性自动生成的动态查找器。了解更多信息，请参阅[动态查找器部分](active_record_querying.html#dynamic-finders)。

跳过回调函数
------------------

与验证类似，也可以通过以下方法跳过回调函数：

* `decrement!`
* `decrement_counter`
* `delete`
* `delete_all`
* `delete_by`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `touch_all`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`
* `upsert`
* `upsert_all`

但是，应谨慎使用这些方法，因为重要的业务规则和应用程序逻辑可能保存在回调函数中。在不了解潜在影响的情况下绕过它们可能导致无效的数据。

停止执行
-----------------

当您开始为模型注册新的回调函数时，它们将被排队等待执行。此队列将包括模型的所有验证、注册的回调函数和要执行的数据库操作。

整个回调链被包装在一个事务中。如果任何回调函数引发异常，执行链将停止并发出 ROLLBACK。要有意停止链，请使用：

```ruby
throw :abort
```

警告。任何不是 `ActiveRecord::Rollback` 或 `ActiveRecord::RecordInvalid` 的异常都将在回调链停止后由 Rails 重新引发。此外，可能会破坏不希望 `save` 和 `update`（通常尝试返回 `true` 或 `false`）引发异常的代码。

注意：如果在 `after_destroy`、`before_destroy` 或 `around_destroy` 回调函数中引发 `ActiveRecord::RecordNotDestroyed`，它将不会被重新引发，并且 `destroy` 方法将返回 `false`。

关联回调函数
--------------------

回调函数通过模型关系工作，甚至可以通过模型关系定义。假设一个用户有多篇文章的示例。如果用户被销毁，用户的文章应该被销毁。让我们通过与 `Article` 模型的关系来向 `User` 模型添加一个 `after_destroy` 回调函数：

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts '文章被销毁'
  end
end
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
文章被销毁
=> #<User id: 1>
```
条件回调
---------------------

与验证类似，我们也可以根据给定的谓词来决定是否调用回调方法。我们可以使用`:if`和`:unless`选项来实现这一点，这两个选项可以接受一个符号、一个`Proc`或一个数组。

当您想要指定在什么条件下应该调用回调时，可以使用`:if`选项。如果您想要指定在什么条件下不应该调用回调，则可以使用`:unless`选项。

### 使用符号的`:if`和`:unless`

您可以将`:if`和`:unless`选项与与回调之前要调用的谓词方法名称相对应的符号关联起来。

使用`:if`选项时，如果谓词方法返回`false`，则回调不会被执行；使用`:unless`选项时，如果谓词方法返回`true`，则回调不会被执行。这是最常见的选项。

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

使用这种形式的注册，还可以注册多个不同的谓词，以检查是否应该执行回调。我们将在下面介绍这个[below](#multiple-callback-conditions)。

### 使用`Proc`的`:if`和`:unless`

可以将`:if`和`:unless`与`Proc`对象关联起来。这个选项最适合编写短的验证方法，通常是一行代码：

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

由于`Proc`在对象的上下文中进行评估，因此也可以这样写：

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```

### 多个回调条件

`:if`和`:unless`选项还可以接受一个`Proc`数组或方法名符号的数组：

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

您可以在条件列表中轻松包含一个`Proc`：

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, Proc.new { untrusted_author? }]
end
```

### 同时使用`:if`和`:unless`

回调可以在同一声明中混合使用`:if`和`:unless`：

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: Proc.new { forum.parental_control? },
    unless: Proc.new { author.trusted? }
end
```

只有当所有的`:if`条件都为`true`且所有的`:unless`条件都为`false`时，回调才会运行。

回调类
----------------

有时，您编写的回调方法可能足够有用，可以被其他模型重用。Active Record允许创建封装回调方法的类，以便可以重用它们。

下面是一个示例，我们创建了一个类，其中包含一个`after_destroy`回调，用于处理文件系统上被丢弃的文件的清理。这个行为可能不仅适用于我们的`PictureFile`模型，我们可能希望共享它，所以将其封装到一个单独的类中是一个好主意。这样做将使测试该行为和更改它变得更容易。

```ruby
class FileDestroyerCallback
  def after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

当在类内部声明时，上述回调方法将接收模型对象作为参数。这将适用于任何使用类的模型：

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback.new
end
```

请注意，我们需要实例化一个新的`FileDestroyerCallback`对象，因为我们将回调声明为实例方法。如果回调使用了实例化对象的状态，这将特别有用。然而，通常更合理的做法是将回调声明为类方法：

```ruby
class FileDestroyerCallback
  def self.after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

当以这种方式声明回调方法时，在我们的模型中不需要实例化一个新的`FileDestroyerCallback`对象。

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback
end
```

您可以在回调类中声明任意数量的回调。

事务回调
---------------------

### 处理一致性

在数据库事务完成后，还会触发两个额外的回调：[`after_commit`][]和[`after_rollback`][]。这些回调与`after_save`回调非常相似，只是它们在数据库更改提交或回滚之后才执行。当您的Active Record模型需要与不属于数据库事务的外部系统交互时，它们非常有用。
例如，考虑前面的示例，其中`PictureFile`模型在对应的记录被销毁后需要删除文件。如果在调用`after_destroy`回调后引发任何异常并且事务回滚，文件将被删除，模型将处于不一致的状态。例如，假设下面的代码中的`picture_file_2`无效且`save!`方法引发错误。

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

通过使用`after_commit`回调，我们可以解决这个问题。

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

注意：`:on`选项指定回调将在何时触发。如果不提供`:on`选项，则回调将对每个操作都触发。

### 上下文很重要

由于在创建、更新或删除时仅使用`after_commit`回调是常见的，因此为这些操作提供了别名：

* [`after_create_commit`][]
* [`after_update_commit`][]
* [`after_destroy_commit`][]

```ruby
class PictureFile < ApplicationRecord
  after_destroy_commit :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

警告：当事务完成时，将为在该事务中创建、更新或删除的所有模型调用`after_commit`或`after_rollback`回调。但是，如果在这些回调之一中引发异常，异常将上升，并且不会执行任何剩余的`after_commit`或`after_rollback`方法。因此，如果回调代码可能引发异常，则需要在回调中捕获并处理它，以允许其他回调运行。

警告：在`after_commit`或`after_rollback`回调中执行的代码本身不包含在事务中。

警告：同时使用相同方法名的`after_create_commit`和`after_update_commit`将只允许最后定义的回调生效，因为它们都内部别名为`after_commit`，这会覆盖先前定义的具有相同方法名的回调。

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'User was saved to database'
    end
end
```

```irb
irb> @user = User.create # 不打印任何内容

irb> @user.save # 更新@user
User was saved to database
```

### `after_save_commit`

还有[`after_save_commit`][]，它是同时使用`after_commit`回调进行创建和更新的别名：

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'User was saved to database'
    end
end
```

```irb
irb> @user = User.create # 创建一个User
User was saved to database

irb> @user.save # 更新@user
User was saved to database
```

### 事务性回调顺序

当定义多个事务性的`after_`回调（`after_commit`、`after_rollback`等）时，它们的顺序将与定义时相反。

```ruby
class User < ActiveRecord::Base
  after_commit { puts("this actually gets called second") }
  after_commit { puts("this actually gets called first") }
end
```

注意：这也适用于所有`after_*_commit`变体，例如`after_destroy_commit`。
[`after_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_create
[`after_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_commit
[`after_rollback`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_rollback
[`after_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_save
[`after_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-after_validation
[`around_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_create
[`around_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_save
[`before_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_create
[`before_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_save
[`before_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-before_validation
[`after_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_update
[`around_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_update
[`before_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_update
[`after_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_destroy
[`around_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_destroy
[`before_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_destroy
[`after_find`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_find
[`after_initialize`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_initialize
[`after_touch`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_touch
[`after_create_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_create_commit
[`after_destroy_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_destroy_commit
[`after_save_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_save_commit
[`after_update_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_update_commit
