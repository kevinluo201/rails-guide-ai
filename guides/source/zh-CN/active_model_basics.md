**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cee957545ee75801aab30265bc416992
Active Model基础知识
===================

本指南将为您提供开始使用模型类所需的所有内容。Active Model允许Action Pack助手与纯Ruby对象进行交互。Active Model还有助于构建用于Rails框架之外的自定义ORM。

阅读本指南后，您将了解以下内容：

* Active Record模型的行为。
* 回调和验证的工作原理。
* 序列化器的工作原理。
* Active Model如何与Rails国际化（i18n）框架集成。

--------------------------------------------------------------------------------

什么是Active Model？
---------------------

Active Model是一个包含各种模块的库，用于开发需要Active Record上存在的一些功能的类。下面解释了其中一些模块。

### API

`ActiveModel::API`添加了一个类与Action Pack和Action View一起使用的能力。

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # 发送电子邮件
    end
  end
end
```

当包含`ActiveModel::API`时，您将获得一些功能，例如：

- 模型名称反射
- 转换
- 翻译
- 验证

它还使您能够使用属性哈希初始化对象，就像任何Active Record对象一样。

```irb
irb> email_contact = EmailContact.new(name: 'David', email: 'david@example.com', message: 'Hello World')
irb> email_contact.name
=> "David"
irb> email_contact.email
=> "david@example.com"
irb> email_contact.valid?
=> true
irb> email_contact.persisted?
=> false
```

任何包含`ActiveModel::API`的类都可以与`form_with`、`render`和任何其他Action View助手方法一起使用，就像Active Record对象一样。

### 属性方法

`ActiveModel::AttributeMethods`模块可以在类的方法上添加自定义前缀和后缀。通过定义前缀和后缀以及对象上将使用它们的方法来使用它。

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_prefix 'reset_'
  attribute_method_suffix '_highest?'
  define_attribute_methods 'age'

  attr_accessor :age

  private
    def reset_attribute(attribute)
      send("#{attribute}=", 0)
    end

    def attribute_highest?(attribute)
      send(attribute) > 100
    end
end
```

```irb
irb> person = Person.new
irb> person.age = 110
irb> person.age_highest?
=> true
irb> person.reset_age
=> 0
irb> person.age_highest?
=> false
```

### 回调

`ActiveModel::Callbacks`提供了Active Record风格的回调。这提供了定义在适当时间运行的回调的能力。在定义回调之后，您可以使用自定义方法在之前、之后和周围包装它们。

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # 当在对象上调用update时，将调用此方法。
    end
  end

  def reset_me
    # 当在对象上调用update时，将调用此方法，因为定义了before_update回调。
  end
end
```

### 转换

如果一个类定义了`persisted?`和`id`方法，那么您可以在该类中包含`ActiveModel::Conversion`模块，并在该类的对象上调用Rails转换方法。

```ruby
class Person
  include ActiveModel::Conversion

  def persisted?
    false
  end

  def id
    nil
  end
end
```

```irb
irb> person = Person.new
irb> person.to_model == person
=> true
irb> person.to_key
=> nil
irb> person.to_param
=> nil
```

### Dirty

当对象的属性经历了一个或多个更改并且尚未保存时，该对象变为脏。`ActiveModel::Dirty`提供了检查对象是否已更改的能力。它还具有基于属性的访问器方法。让我们考虑一个具有`first_name`和`last_name`属性的Person类：

```ruby
class Person
  include ActiveModel::Dirty
  define_attribute_methods :first_name, :last_name

  def first_name
    @first_name
  end

  def first_name=(value)
    first_name_will_change!
    @first_name = value
  end

  def last_name
    @last_name
  end

  def last_name=(value)
    last_name_will_change!
    @last_name = value
  end

  def save
    # 执行保存操作...
    changes_applied
  end
end
```

#### 直接查询对象的所有更改属性列表

```irb
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "First Name"
irb> person.first_name
=> "First Name"

# 如果任何属性有未保存的更改，则返回true。
irb> person.changed?
=> true

# 返回在保存之前已更改的属性列表。
irb> person.changed
=> ["first_name"]

# 返回具有更改前原始值的属性的哈希。
irb> person.changed_attributes
=> {"first_name"=>nil}

# 返回更改的哈希，其中属性名称作为键，值作为该字段的旧值和新值的数组。
irb> person.changes
=> {"first_name"=>[nil, "First Name"]}
```

#### 基于属性的访问器方法

跟踪特定属性是否已更改。
```irb
irb> person.first_name
=> "名字"

# attr_name_changed?
irb> person.first_name_changed?
=> true
```

跟踪属性的先前值。

```irb
# attr_name_was accessor
irb> person.first_name_was
=> nil
```

跟踪更改属性的先前值和当前值。如果有更改，则返回数组，否则返回nil。

```irb
# attr_name_change
irb> person.first_name_change
=> [nil, "名字"]
irb> person.last_name_change
=> nil
```

### 验证

`ActiveModel::Validations` 模块添加了在 Active Record 中验证对象的能力。

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end
```

```irb
irb> person = Person.new
irb> person.token = "2b1f325"
irb> person.valid?
=> false
irb> person.name = 'vishnu'
irb> person.email = 'me'
irb> person.valid?
=> false
irb> person.email = 'me@vishnuatrai.com'
irb> person.valid?
=> true
irb> person.token = nil
irb> person.valid?
ActiveModel::StrictValidationFailed
```

### 命名

`ActiveModel::Naming` 添加了几个类方法，使命名和路由更易于管理。该模块通过使用一些 `ActiveSupport::Inflector` 方法定义了 `model_name` 类方法。

```ruby
class Person
  extend ActiveModel::Naming
end

Person.model_name.name                # => "Person"
Person.model_name.singular            # => "person"
Person.model_name.plural              # => "people"
Person.model_name.element             # => "person"
Person.model_name.human               # => "Person"
Person.model_name.collection          # => "people"
Person.model_name.param_key           # => "person"
Person.model_name.i18n_key            # => :person
Person.model_name.route_key           # => "people"
Person.model_name.singular_route_key  # => "person"
```

### 模型

`ActiveModel::Model` 允许实现类似于 `ActiveRecord::Base` 的模型。

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # 发送电子邮件
    end
  end
end
```

当包含 `ActiveModel::Model` 时，您将获得来自 `ActiveModel::API` 的所有功能。

### 序列化

`ActiveModel::Serialization` 为对象提供基本的序列化功能。您需要声明一个包含要序列化的属性的 attributes 哈希。属性必须是字符串，而不是符号。

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

现在，您可以使用 `serializable_hash` 方法访问对象的序列化哈希。

```irb
irb> person = Person.new
irb> person.serializable_hash
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.serializable_hash
=> {"name"=>"Bob"}
```

#### ActiveModel::Serializers

Active Model 还提供了 `ActiveModel::Serializers::JSON` 模块，用于 JSON 序列化/反序列化。此模块自动包含先前讨论的 `ActiveModel::Serialization` 模块。

##### ActiveModel::Serializers::JSON

要使用 `ActiveModel::Serializers::JSON`，您只需要将要包含的模块从 `ActiveModel::Serialization` 更改为 `ActiveModel::Serializers::JSON`。

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

`as_json` 方法类似于 `serializable_hash`，提供表示模型的哈希。

```irb
irb> person = Person.new
irb> person.as_json
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.as_json
=> {"name"=>"Bob"}
```

您还可以从 JSON 字符串定义模型的属性。但是，您需要在类上定义 `attributes=` 方法：

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    { 'name' => nil }
  end
end
```

现在，可以创建 `Person` 的实例并使用 `from_json` 设置属性。

```irb
irb> json = { name: 'Bob' }.to_json
irb> person = Person.new
irb> person.from_json(json)
=> #<Person:0x00000100c773f0 @name="Bob">
irb> person.name
=> "Bob"
```

### 翻译

`ActiveModel::Translation` 提供了您的对象与 Rails 国际化 (i18n) 框架之间的集成。

```ruby
class Person
  extend ActiveModel::Translation
end
```

使用 `human_attribute_name` 方法，您可以将属性名称转换为更易读的格式。可读性更强的格式在您的区域设置文件中定义。

* config/locales/app.pt-BR.yml

```yaml
pt-BR:
  activemodel:
    attributes:
      person:
        name: 'Nome'
```

```ruby
Person.human_attribute_name('name') # => "Nome"
```

### Lint 测试

`ActiveModel::Lint::Tests` 允许您测试对象是否符合 Active Model API。

* `app/models/person.rb`

    ```ruby
    class Person
      include ActiveModel::Model
    end
    ```

* `test/models/person_test.rb`

    ```ruby
    require "test_helper"

    class PersonTest < ActiveSupport::TestCase
      include ActiveModel::Lint::Tests

      setup do
        @model = Person.new
      end
    end
    ```

```bash
$ bin/rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

为了与 Action Pack 一起使用，不需要对象实现所有 API。此模块仅用于指导，以便您可以获得开箱即用的所有功能。

### SecurePassword

`ActiveModel::SecurePassword` 提供了一种安全地存储任何密码的方法。当您包含此模块时，将提供一个 `has_secure_password` 类方法，该方法默认情况下在 `password` 访问器上定义了某些验证。
#### 需求

`ActiveModel::SecurePassword` 依赖于 [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt')，
因此在你的 `Gemfile` 中包含这个 gem，以正确使用 `ActiveModel::SecurePassword`。
为了使其正常工作，模型必须有一个名为 `XXX_digest` 的访问器。
其中 `XXX` 是你所需密码的属性名称。
以下验证将自动添加：

1. 密码应该存在。
2. 密码应与其确认密码相等（如果提供了 `XXX_confirmation`）。
3. 密码的最大长度为 72（由 ActiveModel::SecurePassword 依赖的 `bcrypt` 所需）。

#### 示例

```ruby
class Person
  include ActiveModel::SecurePassword
  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest
end
```

```irb
irb> person = Person.new

# 当密码为空时。
irb> person.valid?
=> false

# 当确认密码与密码不匹配时。
irb> person.password = 'aditya'
irb> person.password_confirmation = 'nomatch'
irb> person.valid?
=> false

# 当密码长度超过 72 时。
irb> person.password = person.password_confirmation = 'a' * 100
irb> person.valid?
=> false

# 当只提供密码而没有提供确认密码时。
irb> person.password = 'aditya'
irb> person.valid?
=> true

# 当所有验证都通过时。
irb> person.password = person.password_confirmation = 'aditya'
irb> person.valid?
=> true

irb> person.recovery_password = "42password"

irb> person.authenticate('aditya')
=> #<Person> # == person
irb> person.authenticate('notright')
=> false
irb> person.authenticate_password('aditya')
=> #<Person> # == person
irb> person.authenticate_password('notright')
=> false

irb> person.authenticate_recovery_password('42password')
=> #<Person> # == person
irb> person.authenticate_recovery_password('notright')
=> false

irb> person.password_digest
=> "$2a$04$gF8RfZdoXHvyTjHhiU4ZsO.kQqV9oonYZu31PRE4hLQn3xM2qkpIy"
irb> person.recovery_password_digest
=> "$2a$04$iOfhwahFymCs5weB3BNH/uXkTG65HR.qpW.bNhEjFP3ftli3o5DQC"
```
