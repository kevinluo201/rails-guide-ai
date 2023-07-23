**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cee957545ee75801aab30265bc416992
Active Model 基礎
===================

本指南將為您提供使用模型類別的入門所需的所有資訊。Active Model 允許 Action Pack 助手與純 Ruby 物件互動。Active Model 也有助於構建用於 Rails 框架之外的自訂 ORM。

閱讀完本指南後，您將了解以下內容：

* Active Record 模型的行為。
* 回呼和驗證的運作方式。
* 序列化器的運作方式。
* Active Model 如何與 Rails 國際化 (i18n) 框架整合。

--------------------------------------------------------------------------------

什麼是 Active Model？
---------------------

Active Model 是一個包含各種模組的函式庫，用於開發需要 Active Record 上某些功能的類別。以下是其中一些模組的說明。

### API

`ActiveModel::API` 添加了一個類別與 Action Pack 和 Action View 直接配合運作的能力。

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # 發送郵件
    end
  end
end
```

當包含 `ActiveModel::API` 時，您將獲得一些功能，例如：

- 模型名稱的自動判斷
- 轉換
- 翻譯
- 驗證

它還使您能夠使用屬性哈希來初始化物件，就像任何 Active Record 物件一樣。

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

任何包含 `ActiveModel::API` 的類別都可以與 `form_with`、`render` 和其他 Action View 助手方法一起使用，就像 Active Record 物件一樣。

### 屬性方法

`ActiveModel::AttributeMethods` 模組可以在類別的方法上添加自訂前綴和後綴。通過定義前綴和後綴以及將使用它們的物件上的方法，來使用它。

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

### 回呼

`ActiveModel::Callbacks` 提供了 Active Record 風格的回呼。這提供了定義在適當時間運行的回呼的能力。在定義回呼之後，您可以使用 before、after 和 around 自訂方法包裝它們。

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # 當對象上調用 update 時，將調用此方法。
    end
  end

  def reset_me
    # 當對象上調用 update 時，將調用此方法，因為定義了 before_update 回呼。
  end
end
```

### 轉換

如果一個類別定義了 `persisted?` 和 `id` 方法，那麼您可以在該類別中包含 `ActiveModel::Conversion` 模組，並在該類別的物件上調用 Rails 的轉換方法。

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

當物件的屬性經歷了一個或多個更改且尚未保存時，該物件變為 dirty。`ActiveModel::Dirty` 提供了檢查物件是否已更改的能力。它還具有基於屬性的存取方法。讓我們考慮一個具有 `first_name` 和 `last_name` 屬性的 Person 類別：

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
    # 執行保存工作...
    changes_applied
  end
end
```

#### 直接查詢物件的所有已更改屬性的清單

```irb
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "First Name"
irb> person.first_name
=> "First Name"

# 如果任何屬性有未保存的更改，則返回 true。
irb> person.changed?
=> true

# 返回在保存之前已更改的屬性清單。
irb> person.changed
=> ["first_name"]

# 返回具有其原始值的已更改屬性的哈希。
irb> person.changed_attributes
=> {"first_name"=>nil}

# 返回更改的哈希，其中屬性名稱作為鍵，值作為該字段的舊值和新值的陣列。
irb> person.changes
=> {"first_name"=>[nil, "First Name"]}
```

#### 基於屬性的存取方法

追蹤特定屬性是否已更改。
```irb
irb> person.first_name
=> "名字"

# attr_name_changed?
irb> person.first_name_changed?
=> true
```

追蹤屬性的先前值。

```irb
# attr_name_was accessor
irb> person.first_name_was
=> nil
```

追蹤屬性的先前值和當前值。如果有變更，則返回一個陣列；否則返回 nil。

```irb
# attr_name_change
irb> person.first_name_change
=> [nil, "名字"]
irb> person.last_name_change
=> nil
```

### 驗證

`ActiveModel::Validations` 模組提供了在 Active Record 中驗證物件的能力。

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

`ActiveModel::Naming` 添加了幾個類方法，使命名和路由更容易管理。該模組定義了 `model_name` 類方法，該方法將使用一些 `ActiveSupport::Inflector` 方法定義了幾個存取器。

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

`ActiveModel::Model` 允許實現與 `ActiveRecord::Base` 類似的模型。

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # deliver email
    end
  end
end
```

當包含 `ActiveModel::Model` 時，您將獲得 `ActiveModel::API` 的所有功能。

### 序列化

`ActiveModel::Serialization` 提供了對您的物件進行基本序列化的功能。您需要聲明一個包含您想要序列化的屬性的屬性哈希。屬性必須是字符串，而不是符號。

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

現在，您可以使用 `serializable_hash` 方法訪問您的物件的序列化哈希。

```irb
irb> person = Person.new
irb> person.serializable_hash
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.serializable_hash
=> {"name"=>"Bob"}
```

#### ActiveModel::Serializers

Active Model 還提供了 `ActiveModel::Serializers::JSON` 模組，用於 JSON 序列化/反序列化。此模組自動包含先前討論的 `ActiveModel::Serialization` 模組。

##### ActiveModel::Serializers::JSON

要使用 `ActiveModel::Serializers::JSON`，您只需要將包含的模組從 `ActiveModel::Serialization` 更改為 `ActiveModel::Serializers::JSON`。

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

`as_json` 方法（與 `serializable_hash` 類似）提供了表示模型的哈希。

```irb
irb> person = Person.new
irb> person.as_json
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.as_json
=> {"name"=>"Bob"}
```

您還可以從 JSON 字符串定義模型的屬性。但是，您需要在類上定義 `attributes=` 方法：

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

現在，可以創建 `Person` 的實例並使用 `from_json` 設置屬性。

```irb
irb> json = { name: 'Bob' }.to_json
irb> person = Person.new
irb> person.from_json(json)
=> #<Person:0x00000100c773f0 @name="Bob">
irb> person.name
=> "Bob"
```

### 翻譯

`ActiveModel::Translation` 提供了您的物件與 Rails 國際化（i18n）框架之間的集成。

```ruby
class Person
  extend ActiveModel::Translation
end
```

使用 `human_attribute_name` 方法，您可以將屬性名轉換為更易讀的格式。可讀性更高的格式在您的語言文件中定義。

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

### Lint 測試

`ActiveModel::Lint::Tests` 允許您測試一個物件是否符合 Active Model API。

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

為了能夠與 Action Pack 一起使用，物件不需要實現所有 API。此模組僅旨在指導，以便您可以從預設情況下獲得所有功能。

### SecurePassword

`ActiveModel::SecurePassword` 提供了一種安全地存儲任何密碼的方法。當您包含此模組時，將提供一個 `has_secure_password` 類方法，該方法默認定義了對 `password` 存取器的某些驗證。
#### 需求

`ActiveModel::SecurePassword` 依賴於 [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt')，
因此在 `Gemfile` 中包含這個 gem，以正確使用 `ActiveModel::SecurePassword`。
為了使其正常運作，模型必須有一個名為 `XXX_digest` 的存取器。
其中 `XXX` 是您所需密碼的屬性名稱。
以下驗證將自動添加：

1. 密碼應該存在。
2. 密碼應該與其確認相等（如果提供了 `XXX_confirmation`）。
3. 密碼的最大長度為 72（`bcrypt` 所需，`ActiveModel::SecurePassword` 依賴於此）。

#### 範例

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

# 當密碼為空白時。
irb> person.valid?
=> false

# 當確認密碼與密碼不符時。
irb> person.password = 'aditya'
irb> person.password_confirmation = 'nomatch'
irb> person.valid?
=> false

# 當密碼長度超過 72 時。
irb> person.password = person.password_confirmation = 'a' * 100
irb> person.valid?
=> false

# 當只提供密碼而沒有提供確認密碼時。
irb> person.password = 'aditya'
irb> person.valid?
=> true

# 當所有驗證都通過時。
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
