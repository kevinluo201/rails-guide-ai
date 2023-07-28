**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37dd3507f05f7787a794868a2619e6d5
Active Record验证
=========================

本指南教你如何使用Active Record的验证功能，在对象进入数据库之前验证其状态。

阅读完本指南后，你将了解：

* 如何使用内置的Active Record验证助手。
* 如何创建自定义的验证方法。
* 如何处理验证过程生成的错误消息。

--------------------------------------------------------------------------------

验证概述
--------------------

下面是一个非常简单的验证示例：

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

如你所见，我们的验证告诉我们，如果没有`name`属性，我们的`Person`对象是无效的。第二个`Person`对象将不会被保存到数据库中。

在深入了解更多细节之前，让我们先讨论验证在应用程序的整体架构中的位置。

### 为什么使用验证？

验证用于确保只有有效的数据保存到数据库中。例如，对于你的应用程序来说，确保每个用户提供有效的电子邮件地址和邮寄地址可能很重要。模型级别的验证是确保只有有效数据保存到数据库中的最佳方式。它们与数据库无关，无法被终端用户绕过，并且方便进行测试和维护。Rails提供了内置的助手来满足常见需求，并允许你创建自己的验证方法。

在将数据保存到数据库之前，还有其他几种验证数据的方法，包括原生数据库约束、客户端验证和控制器级别的验证。下面是一些优缺点的总结：

* 数据库约束和/或存储过程使验证机制与数据库相关，并可能使测试和维护更加困难。然而，如果你的数据库被其他应用程序使用，使用一些数据库级别的约束可能是一个好主意。此外，数据库级别的验证可以安全地处理一些其他方式难以实现的事情（例如在频繁使用的表中的唯一性）。
* 客户端验证可能很有用，但如果单独使用，通常不可靠。如果使用JavaScript实现，如果用户的浏览器关闭了JavaScript，那么客户端验证可能会被绕过。然而，如果与其他技术结合使用，客户端验证可以成为为用户提供即时反馈的便捷方式。
* 控制器级别的验证可能很诱人，但往往变得难以控制和维护。尽可能保持控制器简单是一个好主意，因为这将使你的应用程序在长期运行中更加愉快。

在特定情况下选择这些方法。Rails团队的观点是，在大多数情况下，模型级别的验证是最合适的。

### 何时进行验证？

有两种类型的Active Record对象：与数据库中的行对应的对象和不对应的对象。当你创建一个新对象时，例如使用`new`方法，该对象尚未属于数据库。一旦你调用`save`方法保存该对象，它将被保存到相应的数据库表中。Active Record使用`new_record?`实例方法来确定对象是否已经在数据库中。考虑以下Active Record类：

```ruby
class Person < ApplicationRecord
end
```

我们可以通过查看一些`bin/rails console`的输出来看看它是如何工作的：

```irb
irb> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>

irb> p.new_record?
=> true

irb> p.save
=> true

irb> p.new_record?
=> false
```

创建和保存新记录将向数据库发送一个SQL `INSERT`操作。更新现有记录将发送一个SQL `UPDATE`操作。通常在将这些命令发送到数据库之前运行验证。如果任何验证失败，对象将被标记为无效，Active Record将不执行`INSERT`或`UPDATE`操作。这样可以避免将无效对象存储到数据库中。你可以选择在创建、保存或更新对象时运行特定的验证。

注意：有很多方法可以改变数据库中对象的状态。有些方法会触发验证，但有些方法不会。这意味着如果不小心的话，可能会将一个无效的对象保存到数据库中。
以下方法会触发验证，并且只有在对象有效时才会将对象保存到数据库中：

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

感叹号版本（例如 `save!`）会在记录无效时引发异常。非感叹号版本则不会：`save` 和 `update` 返回 `false`，`create` 返回对象本身。

### 跳过验证

以下方法会跳过验证，并且无论对象是否有效都会将对象保存到数据库中。使用时应谨慎。

* `decrement!`
* `decrement_counter`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `toggle!`
* `touch`
* `touch_all`
* `update_all`
* `update_attribute`
* `update_column`
* `update_columns`
* `update_counters`
* `upsert`
* `upsert_all`

请注意，如果将 `save` 传递 `validate: false` 作为参数，它也可以跳过验证。这种技术应谨慎使用。

* `save(validate: false)`

### `valid?` 和 `invalid?`

在保存 Active Record 对象之前，Rails 会运行验证。如果这些验证产生任何错误，Rails 将不会保存该对象。

您也可以自行运行这些验证。[`valid?`][] 触发验证并返回 true（如果对象中没有错误），否则返回 false。如上所示：

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

在 Active Record 执行验证后，任何失败都可以通过 [`errors`][] 实例方法访问，它返回一个错误集合。根据定义，如果在运行验证后此集合为空，则对象有效。

请注意，使用 `new` 实例化的对象即使在技术上无效，也不会报告错误，因为验证仅在对象保存时才会自动运行，例如使用 `create` 或 `save` 方法。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> p = Person.new
=> #<Person id: nil, name: nil>
irb> p.errors.size
=> 0

irb> p.valid?
=> false
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p = Person.create
=> #<Person id: nil, name: nil>
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p.save
=> false

irb> p.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank

irb> Person.create!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

[`invalid?`][] 是 `valid?` 的反义词。它触发验证，如果对象中存在任何错误，则返回 true，否则返回 false。


### `errors[]`

要验证对象的特定属性是否有效，可以使用 [`errors[:attribute]`][Errors#squarebrackets]。它返回 `:attribute` 的所有错误消息的数组。如果指定属性上没有错误，则返回一个空数组。

此方法仅在运行验证后才有用，因为它仅检查错误集合，而不会触发验证本身。它与上面解释的 `ActiveRecord::Base#invalid?` 方法不同，因为它不验证对象的整体有效性。它只检查对象的单个属性上是否存在错误。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.new.errors[:name].any?
=> false
irb> Person.create.errors[:name].any?
=> true
```

我们将在 [处理验证错误](#working-with-validation-errors) 部分更详细地介绍验证错误。


验证助手
------------------

Active Record 提供了许多预定义的验证助手，您可以直接在类定义中使用。这些助手提供常见的验证规则。每当验证失败时，错误将添加到对象的 `errors` 集合中，并与正在验证的属性相关联。

每个助手都接受任意数量的属性名称，因此您可以通过一行代码将相同类型的验证添加到多个属性中。

它们都接受 `:on` 和 `:message` 选项，用于定义何时运行验证以及如果验证失败应将什么消息添加到 `errors` 集合中。`:on` 选项接受值 `:create` 或 `:update`。每个验证助手都有一个默认的错误消息。当未指定 `:message` 选项时，将使用这些消息。让我们看一下每个可用助手。

INFO: 要查看可用默认助手的列表，请参阅 [`ActiveModel::Validations::HelperMethods`][]。
### `接受`

该方法验证了在提交表单时用户界面上的复选框是否被选中。通常在用户需要同意应用程序的服务条款、确认已阅读某些文本或类似概念时使用。

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

只有当`terms_of_service`不为`nil`时才执行此检查。
该辅助方法的默认错误消息为_"必须接受"_。
您还可以通过`message`选项传递自定义消息。

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: '必须遵守' }
end
```

它还可以接收一个`：accept`选项，用于确定将被视为可接受的允许值。默认为`['1', true]`，可以轻松更改。

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: '是' }
  validates :eula, acceptance: { accept: ['TRUE', '已接受'] }
end
```

此验证非常特定于Web应用程序，此“接受”不需要在数据库中记录任何内容。如果您没有相应的字段，辅助方法将创建一个虚拟属性。如果字段确实存在于数据库中，则`accept`选项必须设置为或包含`true`，否则验证将不会运行。

### `确认`

当您有两个应该接收完全相同内容的文本字段时，应使用此辅助方法。例如，您可能希望确认电子邮件地址或密码。此验证将创建一个虚拟属性，其名称是必须与附加的“_confirmation”一起确认的字段的名称。

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

在视图模板中，您可以使用以下内容：

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

注意：只有当`email_confirmation`不为`nil`时才执行此检查。要求确认，请确保为确认属性添加存在性检查（我们将在本指南的稍后部分查看`存在性`）：

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

还有一个`:case_sensitive`选项，您可以使用它来定义确认约束是否区分大小写。此选项默认为true。

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

此辅助方法的默认错误消息为_"与确认不匹配"_。
您还可以通过`message`选项传递自定义消息。

通常，在使用此验证器时，您将希望将其与`：if`选项结合使用，以便仅在初始字段更改时验证“_confirmation”字段，而不是每次保存记录时都验证。稍后将详细介绍[条件验证](#conditional-validation)。

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?
end
```

### `比较`

此检查将验证任意两个可比较值之间的比较。

```ruby
class Promotion < ApplicationRecord
  validates :end_date, comparison: { greater_than: :start_date }
end
```

此辅助方法的默认错误消息为_"比较失败"_。
您还可以通过`message`选项传递自定义消息。

支持以下选项：

* `:greater_than` - 指定值必须大于提供的值。此选项的默认错误消息为_"必须大于%{count}"_。
* `:greater_than_or_equal_to` - 指定值必须大于或等于提供的值。此选项的默认错误消息为_"必须大于或等于%{count}"_。
* `:equal_to` - 指定值必须等于提供的值。此选项的默认错误消息为_"必须等于%{count}"_。
* `:less_than` - 指定值必须小于提供的值。此选项的默认错误消息为_"必须小于%{count}"_。
* `:less_than_or_equal_to` - 指定值必须小于或等于提供的值。此选项的默认错误消息为_"必须小于或等于%{count}"_。
* `:other_than` - 指定值必须不同于提供的值。此选项的默认错误消息为_"必须不同于%{count}"_。

注意：验证器需要提供一个比较选项。每个选项都接受一个值、proc或符号。任何包含Comparable的类都可以进行比较。
### `format`

该辅助函数通过测试属性值是否与给定的正则表达式匹配来验证属性的值，这个正则表达式是使用 `:with` 选项指定的。

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "只允许字母" }
end
```

相反地，通过使用 `:without` 选项，您可以要求指定的属性 _不_ 匹配正则表达式。

无论哪种情况，提供的 `:with` 或 `:without` 选项必须是一个正则表达式或返回一个正则表达式的 proc 或 lambda。

默认的错误消息是 _"无效"_。

警告：使用 `\A` 和 `\z` 来匹配字符串的开头和结尾，`^` 和 `$` 匹配行的开头和结尾。由于经常误用 `^` 和 `$`，如果在提供的正则表达式中使用了这两个锚点之一，您需要传递 `multiline: true` 选项。在大多数情况下，您应该使用 `\A` 和 `\z`。

### `inclusion`

该辅助函数验证属性的值是否包含在给定的集合中。实际上，这个集合可以是任何可枚举的对象。

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} 不是一个有效的尺寸" }
end
```

`inclusion` 辅助函数有一个 `:in` 选项，用于接收将被接受的值集合。`:in` 选项有一个别名叫做 `:within`，如果您愿意，您可以使用它来达到相同的目的。上面的示例使用 `:message` 选项来展示如何包含属性的值。有关完整的选项，请参阅[消息文档](#message)。

该辅助函数的默认错误消息是 _"不在列表中"_。

### `exclusion`

`inclusion` 的相反是... `exclusion`！

该辅助函数验证属性的值是否不包含在给定的集合中。实际上，这个集合可以是任何可枚举的对象。

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} 是保留的。" }
end
```

`exclusion` 辅助函数有一个 `:in` 选项，用于接收将不被接受的验证属性的值集合。`:in` 选项有一个别名叫做 `:within`，如果您愿意，您可以使用它来达到相同的目的。这个示例使用 `:message` 选项来展示如何包含属性的值。有关消息参数的完整选项，请参阅[消息文档](#message)。

该辅助函数的默认错误消息是 _"已保留"_。

除了传统的可枚举对象（如数组）之外，您还可以提供返回可枚举对象的 proc、lambda 或符号。如果可枚举对象是数字、时间或日期时间范围，则使用 `Range#cover?` 进行测试，否则使用 `include?`。当使用 proc 或 lambda 时，验证实例将作为参数传递。

### `length`

该辅助函数验证属性值的长度。它提供了多种选项，因此您可以以不同的方式指定长度约束：

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

可能的长度约束选项有：

* `:minimum` - 属性的长度不能少于指定的长度。
* `:maximum` - 属性的长度不能超过指定的长度。
* `:in`（或 `:within`）- 属性的长度必须包含在给定的区间内。该选项的值必须是一个范围。
* `:is` - 属性的长度必须等于给定的值。

默认的错误消息取决于正在执行的长度验证的类型。您可以使用 `:wrong_length`、`:too_long` 和 `:too_short` 选项以及 `%{count}` 作为占位符来自定义这些消息，用于对应于正在使用的长度约束的数字。您仍然可以使用 `:message` 选项来指定错误消息。

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} 个字符是允许的最大长度" }
end
```

请注意，默认的错误消息是复数的（例如，"太短（最少 %{count} 个字符）"）。因此，当 `:minimum` 为 1 时，您应该提供自定义消息或使用 `presence: true`。当 `:in` 或 `:within` 的下限为 1 时，您应该提供自定义消息或在 `length` 之前调用 `presence`。
注意：除了可以同时使用`：minimum`和`：maximum`选项之外，只能使用一个约束选项。

### `numericality`

该辅助方法验证属性只包含数字值。默认情况下，它将匹配一个可选的符号，后面跟着一个整数或浮点数。

要指定只允许整数，将`：only_integer`设置为`true`。然后它将使用以下正则表达式验证属性的值。

```ruby
/\A[+-]?\d+\z/
```

否则，它将尝试使用`Float`将值转换为数字。`Float`将使用列的精度值或最多15位数字转换为`BigDecimal`。

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

`：only_integer`的默认错误消息是“必须是整数”。

除了`：only_integer`，该辅助方法还接受`：only_numeric`选项，该选项指定值必须是`Numeric`的实例，并在值为`String`时尝试解析。

注意：默认情况下，`numericality`不允许`nil`值。您可以使用`allow_nil: true`选项来允许它。请注意，对于`Integer`和`Float`列，空字符串将转换为`nil`。

当未指定任何选项时，没有错误消息的默认值是“不是一个数字”。

还有许多选项可用于添加约束到可接受的值：

* `：greater_than` - 指定值必须大于提供的值。该选项的默认错误消息是“必须大于%{count}”。
* `：greater_than_or_equal_to` - 指定值必须大于或等于提供的值。该选项的默认错误消息是“必须大于或等于%{count}”。
* `：equal_to` - 指定值必须等于提供的值。该选项的默认错误消息是“必须等于%{count}”。
* `：less_than` - 指定值必须小于提供的值。该选项的默认错误消息是“必须小于%{count}”。
* `：less_than_or_equal_to` - 指定值必须小于或等于提供的值。该选项的默认错误消息是“必须小于或等于%{count}”。
* `：other_than` - 指定值必须不等于提供的值。该选项的默认错误消息是“必须不等于%{count}”。
* `：in` - 指定值必须在提供的范围内。该选项的默认错误消息是“必须在%{count}”。
* `：odd` - 指定值必须是奇数。该选项的默认错误消息是“必须是奇数”。
* `：even` - 指定值必须是偶数。该选项的默认错误消息是“必须是偶数”。

### `presence`

该辅助方法验证指定的属性不为空。它使用[`Object#blank?`][]方法来检查值是否为`nil`或空字符串，即空字符串或只包含空格的字符串。

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

如果要确保关联存在，您需要测试关联对象本身是否存在，而不是用于映射关联的外键。这样，不仅检查外键不为空，还检查引用的对象是否存在。

```ruby
class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end
```

为了验证需要存在的关联记录，必须为关联指定`：inverse_of`选项：

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

注意：如果要确保关联既存在又有效，还需要使用`validates_associated`。更多信息请参见下文。

如果验证通过`has_one`或`has_many`关系关联的对象的存在性，它将检查对象既不是`blank?`也不是`marked_for_destruction?`。

由于`false.blank?`为真，如果要验证布尔字段的存在性，应使用以下验证之一：

```ruby
# 值必须是true或false
validates :boolean_field_name, inclusion: [true, false]
# 值不能为nil，即true或false
validates :boolean_field_name, exclusion: [nil]
```
通过使用这些验证之一，您将确保值不会为`nil`，这在大多数情况下会导致`NULL`值。

默认的错误消息是 _"不能为空"_。

### `absence`

此辅助函数验证指定的属性是否不存在。它使用[`Object#present?`][]方法来检查值是否既不是`nil`也不是空字符串，即空字符串或只包含空格的字符串。

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

如果您想确保关联不存在，您需要测试关联对象本身是否不存在，而不是用于映射关联的外键。

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

为了验证所需的不存在的关联记录，您必须为关联指定`:inverse_of`选项：

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

注意：如果您想确保关联既存在又有效，您还需要使用`validates_associated`。更多信息请参见下文。

如果您验证通过`has_one`或`has_many`关系关联的对象的不存在，它将检查对象既不是`present?`也不是`marked_for_destruction?`。

由于`false.present?`是`false`，如果您想验证布尔字段的不存在，您应该使用`validates :field_name, exclusion: { in: [true, false] }`。

默认的错误消息是 _"必须为空"_。

### `uniqueness`

此辅助函数验证属性的值在对象保存之前是唯一的。

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

验证是通过在模型的表中执行SQL查询来进行的，搜索具有相同属性值的现有记录。

有一个`:scope`选项，您可以使用它来指定一个或多个用于限制唯一性检查的属性：

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "每年只能发生一次" }
end
```

警告。此验证不会在数据库中创建唯一性约束，因此可能会发生两个不同的数据库连接为您打算是唯一的列创建具有相同值的两个记录的情况。为了避免这种情况，您必须在数据库中为该列创建一个唯一索引。

为了在数据库上添加唯一性约束，请在迁移中使用[`add_index`][]语句，并包含`unique: true`选项。

如果您希望创建一个数据库约束来防止使用`：scope`选项可能违反唯一性验证的情况，您必须在数据库中为两个列创建一个唯一索引。有关多列索引的更多详细信息，请参见[MySQL手册][]，有关引用一组列的唯一约束的示例，请参见[PostgreSQL手册][]。

还有一个`:case_sensitive`选项，您可以使用它来定义唯一性约束是区分大小写、不区分大小写还是遵守默认数据库排序规则。此选项默认为遵守默认数据库排序规则。

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

警告。请注意，某些数据库已配置为执行不区分大小写的搜索。

还有一个`:conditions`选项，您可以将其指定为`WHERE` SQL片段，以限制唯一性约束的查找（例如`conditions: -> { where(status: 'active') }`）。

默认的错误消息是 _"已经被占用"_。

有关更多信息，请参见[`validates_uniqueness_of`][]。

[MySQL手册]: https://dev.mysql.com/doc/refman/en/multiple-column-indexes.html
[PostgreSQL手册]: https://www.postgresql.org/docs/current/static/ddl-constraints.html

### `validates_associated`

当您的模型具有始终需要验证的关联时，应使用此辅助函数。每次尝试保存对象时，将在每个关联对象上调用`valid?`。

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

此验证适用于所有关联类型。

注意：不要在关联的两端都使用`validates_associated`。它们会在无限循环中相互调用。

[`validates_associated`][]的默认错误消息是 _"无效"_. 请注意，每个关联对象都将包含自己的`errors`集合；错误不会冒泡到调用模型。

注意：[`validates_associated`][]只能与ActiveRecord对象一起使用，到目前为止，任何包括[`ActiveModel::Validations`][]的对象也可以使用上述所有内容。
### `validates_each`

该辅助函数根据一个块对属性进行验证。它没有预定义的验证函数。您应该使用一个块创建一个验证函数，并且每个传递给[`validates_each`][]的属性都将被测试。

在下面的示例中，我们将拒绝以小写字母开头的姓名和姓氏。

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, '必须以大写字母开头') if /\A[[:lower:]]/.match?(value)
  end
end
```

该块接收记录、属性名称和属性值。

您可以在块中执行任何您喜欢的操作来检查有效数据。如果验证失败，您应该向模型添加一个错误，从而使其无效。


### `validates_with`

该辅助函数将记录传递给一个单独的类进行验证。

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors.add :base, "这个人是邪恶的"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

`validates_with`没有默认的错误消息。您必须在验证器类中手动添加错误到记录的错误集合中。

注意：添加到`record.errors[:base]`的错误与记录作为一个整体的状态有关。

要实现validate方法，您必须在方法定义中接受一个`record`参数，该参数是要验证的记录。

如果要在特定属性上添加错误，请将其作为第一个参数传递，例如`record.errors.add(:first_name, "请另选一个名字")`。我们稍后将详细介绍[验证错误][]。

```ruby
def validate(record)
  if record.some_field != "acceptable"
    record.errors.add :some_field, "此字段不可接受"
  end
end
```

[`validates_with`][]辅助函数接受一个类或一组类用于验证。

```ruby
class Person < ApplicationRecord
  validates_with MyValidator, MyOtherValidator, on: :create
end
```

与所有其他验证一样，`validates_with`接受`:if`、`:unless`和`:on`选项。如果传递任何其他选项，它将将这些选项作为`options`发送给验证器类：

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| record.send(field) == "Evil" }
      record.errors.add :base, "这个人是邪恶的"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

请注意，验证器将在整个应用程序生命周期中仅初始化一次，而不是在每次验证运行时都初始化，因此在其中使用实例变量时要小心。

如果您的验证器足够复杂，需要使用实例变量，您可以轻松地使用一个普通的Ruby对象代替：

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors.add :base, "这个人是邪恶的"
    end
  end

  # ...
end
```

稍后我们将更详细地介绍[自定义验证](#执行自定义验证)。

[验证错误](#处理验证错误)

常见的验证选项
-------------------------

我们刚刚介绍的验证器支持几个常见选项，现在让我们详细介绍一些！

注意：并非所有这些选项都被每个验证器支持，请参阅[`ActiveModel::Validations`][]的API文档。

通过使用我们刚刚提到的任何验证方法，还有一些与验证器共享的常见选项。我们现在来介绍一下这些！

* [`:allow_nil`](#允许-nil)：如果属性为`nil`，则跳过验证。
* [`:allow_blank`](#允许-blank)：如果属性为空，则跳过验证。
* [`:message`](#消息)：指定自定义错误消息。
* [`:on`](#在)：指定此验证处于活动状态的上下文。
* [`:strict`](#严格验证)：验证失败时引发异常。
* [`:if`和`:unless`](#条件验证)：指定何时应进行验证或不进行验证。


### `:allow_nil`

`：allow_nil`选项在验证的值为`nil`时跳过验证。

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} 不是有效的尺寸" }, allow_nil: true
end
```

```irb
irb> Coffee.create(size: nil).valid?
=> true
irb> Coffee.create(size: "mega").valid?
=> false
```

有关message参数的完整选项，请参见[消息文档](#消息)。

### `:allow_blank`

`：allow_blank`选项类似于`：allow_nil`选项。如果属性的值为`blank?`，例如`nil`或空字符串，此选项将允许验证通过。

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end
```

```irb
irb> Topic.create(title: "").valid?
=> true
irb> Topic.create(title: nil).valid?
=> true
```

### `:message`
正如您已经看到的那样，`:message`选项允许您指定在验证失败时将添加到`errors`集合中的消息。当不使用此选项时，Active Record将为每个验证助手使用相应的默认错误消息。

`:message`选项接受`String`或`Proc`作为其值。

`String`类型的`:message`值可以选择包含`%{value}`、`%{attribute}`和`%{model}`中的任意/所有内容，这些内容在验证失败时将被动态替换。此替换是使用i18n gem完成的，占位符必须完全匹配，不允许有空格。

```ruby
class Person < ApplicationRecord
  # 固定的消息
  validates :name, presence: { message: "必须提供" }

  # 包含动态属性值的消息。%{value}将被替换为属性的实际值。%{attribute}和%{model}也可用。
  validates :age, numericality: { message: "%{value}似乎不正确" }
end
```

`Proc`类型的`:message`值接受两个参数：正在验证的对象和一个带有`：model`、`：attribute`和`：value`键值对的哈希。

```ruby
class Person < ApplicationRecord
  validates :username,
    uniqueness: {
      # object = 正在验证的person对象
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "嘿#{object.name}，#{data[:value]}已经被使用了。"
      end
    }
end
```

### `:on`

`:on`选项允许您指定验证应该发生的时间。所有内置的验证助手的默认行为是在保存时运行（在创建新记录和更新记录时都是如此）。如果您想要更改它，可以使用`on: :create`仅在创建新记录时运行验证，或者使用`on: :update`仅在更新记录时运行验证。

```ruby
class Person < ApplicationRecord
  # 可以使用重复的值更新电子邮件
  validates :email, uniqueness: true, on: :create

  # 可以使用非数字年龄创建记录
  validates :age, numericality: true, on: :update

  # 默认（在创建和更新时验证）
  validates :name, presence: true
end
```

您还可以使用`on:`来定义自定义上下文。自定义上下文需要通过将上下文的名称传递给`valid?`、`invalid?`或`save`来显式触发。

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end
```

```irb
irb> person = Person.new(age: 'thirty-three')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["已经被使用"], :age=>["不是一个数字"]}
```

`person.valid?(:account_setup)`在保存模型之前在`account_setup`上下文中执行两个验证。`person.save(context: :account_setup)`在保存之前在`account_setup`上下文中验证`person`。

传递一个符号数组也是可以接受的。

```ruby
class Book
  include ActiveModel::Validations

  validates :title, presence: true, on: [:update, :ensure_title]
end
```

```irb
irb> book = Book.new(title: nil)
irb> book.valid?
=> true
irb> book.valid?(:ensure_title)
=> false
irb> book.errors.messages
=> {:title=>["不能为空"]}
```

当由显式上下文触发时，将运行该上下文的验证，以及没有上下文的任何验证。

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end
```

```irb
irb> person = Person.new
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["已经被使用"], :age=>["不是一个数字"], :name=>["不能为空"]}
```

我们将在[回调指南](active_record_callbacks.html)中介绍更多关于`on:`的用例。

严格验证
------------------

您还可以指定验证为严格验证，并在对象无效时引发`ActiveModel::StrictValidationFailed`。

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end
```

```irb
irb> Person.new.valid?
ActiveModel::StrictValidationFailed: 名称不能为空
```

还可以将自定义异常传递给`:strict`选项。

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end
```

```irb
irb> Person.new.valid?
TokenGenerationException: 令牌不能为空
```

条件验证
----------------------

有时，只有在满足给定谓词时才对对象进行验证才有意义。您可以通过使用`:if`和`:unless`选项来实现这一点，这些选项可以接受一个符号、一个`Proc`或一个数组。当您希望指定验证**应该**发生的时间时，可以使用`:if`选项。或者，如果您希望指定验证**不应该**发生的时间，则可以使用`:unless`选项。
### 使用 `:if` 和 `:unless` 的符号

您可以将 `:if` 和 `:unless` 选项与一个与验证发生之前调用的方法名称相对应的符号关联起来。这是最常用的选项。

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### 使用 `:if` 和 `:unless` 的 Proc

可以将 `:if` 和 `:unless` 与将被调用的 `Proc` 对象关联起来。使用 `Proc` 对象可以让您编写内联条件，而不是单独的方法。这个选项最适合一行代码。

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

由于 `lambda` 是 `Proc` 的一种类型，因此也可以使用它来编写内联条件，以利用简化的语法。

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### 分组条件验证

有时候，有多个验证使用相同的条件是很有用的。可以使用 [`with_options`][] 轻松实现这一点。

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

`with_options` 块内的所有验证都将自动通过条件 `if: :is_admin?`。

### 组合验证条件

另一方面，当多个条件定义了验证是否应该发生时，可以使用 `Array`。此外，您可以将 `:if` 和 `:unless` 同时应用于同一个验证。

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

只有当所有 `:if` 条件都为 `true`，且所有 `:unless` 条件都为 `false` 时，验证才会运行。

执行自定义验证
-----------------------------

当内置的验证助手无法满足您的需求时，可以根据需要编写自己的验证器或验证方法。

### 自定义验证器

自定义验证器是继承自 [`ActiveModel::Validator`][] 的类。这些类必须实现 `validate` 方法，该方法接受一个记录作为参数，并对其进行验证。可以使用 `validates_with` 方法调用自定义验证器。

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "请提供以 X 开头的名称！"
    end
  end
end

class Person < ApplicationRecord
  validates_with MyValidator
end
```

验证单个属性的自定义验证器最简单的方法是使用方便的 [`ActiveModel::EachValidator`][]。在这种情况下，自定义验证器类必须实现一个 `validate_each` 方法，该方法接受三个参数：记录、要验证的属性和传递的实例中属性的值。

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless URI::MailTo::EMAIL_REGEXP.match?(value)
      record.errors.add attribute, (options[:message] || "不是有效的电子邮件")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

如示例所示，您还可以将标准验证与自定义验证器结合使用。

### 自定义方法

您还可以创建验证模型状态并在无效时向 `errors` 集合中添加错误的方法。然后，您可以使用 [`validate`][] 类方法注册这些方法，传递验证方法名称的符号。

每个类方法可以传递多个符号，相应的验证将按照注册的顺序运行。

`valid?` 方法将验证 `errors` 集合是否为空，因此当您希望验证失败时，自定义验证方法应将错误添加到其中：

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "不能是过去的日期")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "不能大于总价值")
    end
  end
end
```

默认情况下，这些验证将在每次调用 `valid?` 或保存对象时运行。但是，也可以通过给 `validate` 方法添加 `:on` 选项来控制何时运行这些自定义验证，可以选择 `:create` 或 `:update`。

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "不是活动的") unless customer.active?
  end
end
```
有关[`:on`](#on)的更多详细信息，请参见上面的部分。

### 列出验证器

如果您想找出给定对象的所有验证器，那么可以使用`validators`。

例如，如果我们有以下使用自定义验证器和内置验证器的模型：

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, on: :create
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates_with MyOtherValidator, strict: true
end
```

我们现在可以在"Person"模型上使用`validators`来列出所有验证器，或者使用`validators_on`来检查特定字段。

```irb
irb> Person.validators
#=> [#<ActiveRecord::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={:on=>:create}>,
     #<MyOtherValidatorValidator:0x10b2f17d0
      @attributes=[:name], @options={:strict=>true}>,
     #<ActiveModel::Validations::FormatValidator:0x10b2f0f10
      @attributes=[:email],
      @options={:with=>URI::MailTo::EMAIL_REGEXP}>]
     #<MyOtherValidator:0x10b2f0948 @options={:strict=>true}>]

irb> Person.validators_on(:name)
#=> [#<ActiveModel::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={on: :create}>]
```


处理验证错误
------------------------------

[`valid?`][]和[`invalid?`][]方法只提供了关于有效性的摘要状态。但是，您可以通过使用[`errors`][]集合中的各种方法来深入了解每个单独的错误。

以下是最常用的方法列表。有关所有可用方法的列表，请参阅[`ActiveModel::Errors`][]文档。


### `errors`

通过该方法，您可以深入了解每个错误的各种详细信息。

它返回一个包含所有错误的`ActiveModel::Errors`类的实例，每个错误由一个[`ActiveModel::Error`][]对象表示。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.full_messages
=> ["Name不能为空", "Name太短（最少为3个字符）"]

irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors.full_messages
=> []

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.first.details
=> {:error=>:too_short, :count=>3}
```


### `errors[]`

当您想要检查特定属性的错误消息时，可以使用[`errors[]`][Errors#squarebrackets]。它返回一个字符串数组，其中包含给定属性的所有错误消息，每个字符串表示一个错误消息。如果没有与属性相关的错误，则返回一个空数组。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors[:name]
=> []

irb> person = Person.new(name: "JD")
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["太短（最少为3个字符）"]

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["不能为空", "太短（最少为3个字符）"]
```

### `errors.where`和错误对象

有时，我们可能需要更多关于每个错误的信息，而不仅仅是错误消息。每个错误都封装为一个`ActiveModel::Error`对象，而[`where`][]方法是访问的最常用方式。

`where`方法返回一个由各种条件过滤的错误对象数组。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

我们可以通过将其作为第一个参数传递给`errors.where(:attr)`来仅过滤`attribute`。第二个参数用于通过调用`errors.where(:attr, :type)`来过滤我们想要的`type`错误。

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name)
=> [ ... ] # :name属性的所有错误

irb> person.errors.where(:name, :too_short)
=> [ ... ] # :name属性的:too_short错误
```

最后，我们可以根据给定类型的错误对象上可能存在的任何`options`进行过滤。

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name, :too_short, minimum: 3)
=> [ ... ] # 所有名称错误都太短，最小为2
```

您可以从这些错误对象中读取各种信息：

```irb
irb> error = person.errors.where(:name).last

irb> error.attribute
=> :name
irb> error.type
=> :too_short
irb> error.options[:count]
=> 3
```

您还可以生成错误消息：

```irb
irb> error.message
=> "太短（最少为3个字符）"
irb> error.full_message
=> "Name太短（最少为3个字符）"
```

[`full_message`][]方法生成一个更用户友好的消息，其中包含大写的属性名称作为前缀。（要自定义`full_message`使用的格式，请参见[I18n指南](i18n.html#active-model-methods)。）


### `errors.add`

[`add`][]方法通过获取`attribute`、错误`type`和其他选项哈希来创建错误对象。当编写自己的验证器时，这非常有用，因为它允许您定义非常具体的错误情况。

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_plain, message: "不够酷"
  end
end
```
```irb
irb> person = Person.create
irb> person.errors.where(:name).first.type
=> :too_plain
irb> person.errors.where(:name).first.full_message
=> "名字不够酷"
```


### `errors[:base]`

您可以添加与对象整体状态相关的错误，而不是与特定属性相关的错误。要做到这一点，您必须在添加新错误时使用 `:base` 作为属性。

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :base, :invalid, message: "这个人无效，因为..."
  end
end
```

```irb
irb> person = Person.create
irb> person.errors.where(:base).first.full_message
=> "这个人无效，因为..."
```

### `errors.size`

`size` 方法返回对象的错误总数。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.size
=> 2

irb> person = Person.new(name: "Andrea", email: "andrea@example.com")
irb> person.valid?
=> true
irb> person.errors.size
=> 0
```

### `errors.clear`

当您有意要清除 `errors` 集合时，可以使用 `clear` 方法。当然，在无效的对象上调用 `errors.clear` 不会使其变为有效：`errors` 集合现在将为空，但是下次调用 `valid?` 或任何尝试将此对象保存到数据库的方法时，验证将再次运行。如果任何验证失败，`errors` 集合将再次填充。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.empty?
=> false

irb> person.errors.clear
irb> person.errors.empty?
=> true

irb> person.save
=> false

irb> person.errors.empty?
=> false
```

在视图中显示验证错误
-------------------------------------

一旦您创建了一个模型并添加了验证，如果该模型是通过 Web 表单创建的，当其中一个验证失败时，您可能希望显示错误消息。

由于每个应用程序处理这种情况的方式不同，Rails 不包含任何视图助手来直接生成这些消息。但是，由于 Rails 提供了丰富的方法来与验证进行交互，您可以自己构建。此外，当生成一个脚手架时，Rails 会将一些 ERB 放入生成的 `_form.html.erb` 中，以显示该模型上的完整错误列表。

假设我们有一个已保存在名为 `@article` 的实例变量中的模型，它看起来像这样：

```html+erb
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> 阻止保存此文章：</h2>

    <ul>
      <% @article.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

此外，如果您使用 Rails 表单助手生成表单，当字段上发生验证错误时，它将在输入周围生成额外的 `<div>`。

```html
<div class="field_with_errors">
  <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

然后，您可以根据需要对此 div 进行样式设置。例如，Rails 生成的默认脚手架添加了以下 CSS 规则：

```css
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

这意味着任何带有错误的字段都会有一个 2 像素的红色边框。
[`errors`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-errors
[`invalid?`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-invalid-3F
[`valid?`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations.html#method-i-valid-3F
[Errors#squarebrackets]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-5B-5D
[`ActiveModel::Validations::HelperMethods`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html
[`Object#blank?`]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[`Object#present?`]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[`validates_uniqueness_of`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`validates_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_associated
[`validates_each`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_each
[`validates_with`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_with
[`ActiveModel::Validations`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html
[`with_options`]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[`ActiveModel::EachValidator`]: https://api.rubyonrails.org/classes/ActiveModel/EachValidator.html
[`ActiveModel::Validator`]: https://api.rubyonrails.org/classes/ActiveModel/Validator.html
[`validate`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate
[`ActiveModel::Errors`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html
[`ActiveModel::Error`]: https://api.rubyonrails.org/classes/ActiveModel/Error.html
[`full_message`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_message
[`where`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-where
[`add`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add
