**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cee957545ee75801aab30265bc416992
액티브 모델 기본 사항
===================

이 안내서는 모델 클래스를 사용하는 데 필요한 모든 내용을 제공해줄 것입니다. 액티브 모델은 액션 팩 도우미가 일반 루비 객체와 상호 작용할 수 있도록 해줍니다. 또한 액티브 모델은 레일즈 프레임워크 외부에서 사용하기 위한 사용자 정의 ORM을 구축하는 데 도움을 줍니다.

이 안내서를 읽은 후에는 다음을 알게 될 것입니다:

* 액티브 레코드 모델의 동작 방식.
* 콜백과 유효성 검사의 작동 방식.
* 직렬화의 작동 방식.
* 액티브 모델이 레일즈 국제화 (i18n) 프레임워크와 통합되는 방법.

--------------------------------------------------------------------------------

액티브 모델이란 무엇인가?
---------------------

액티브 모델은 액티브 레코드에 있는 일부 기능이 필요한 클래스를 개발하는 데 사용되는 다양한 모듈을 포함한 라이브러리입니다.
이 중 일부 모듈에 대해 아래에서 설명합니다.

### API

`ActiveModel::API`는 클래스가 Action Pack과 Action View와 함께 작동할 수 있는 기능을 제공합니다.

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # 이메일 전송
    end
  end
end
```

`ActiveModel::API`를 포함하면 다음과 같은 기능을 얻을 수 있습니다:

- 모델 이름 탐색
- 변환
- 번역
- 유효성 검사

또한 Active Record 객체와 마찬가지로 속성 해시로 객체를 초기화할 수 있는 기능도 제공합니다.

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

`ActiveModel::API`를 포함하는 모든 클래스는 Active Record 객체와 마찬가지로 `form_with`, `render` 및 기타 Action View 도우미 메서드와 함께 사용할 수 있습니다.

### 속성 메서드

`ActiveModel::AttributeMethods` 모듈은 클래스의 메서드에 사용자 정의 접두사와 접미사를 추가할 수 있습니다. 이는 접두사와 접미사를 정의하고 객체의 어떤 메서드가 이를 사용할지 정의하여 사용됩니다.

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

### 콜백

`ActiveModel::Callbacks`는 Active Record 스타일의 콜백을 제공합니다. 이를 통해 적절한 시간에 실행되는 콜백을 정의할 수 있습니다.
콜백을 정의한 후에는 해당 콜백을 before, after 및 around 사용자 정의 메서드로 래핑할 수 있습니다.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # 이 메서드는 객체에서 update가 호출될 때 호출됩니다.
    end
  end

  def reset_me
    # 이 메서드는 객체에서 update가 호출될 때 before_update 콜백으로 정의되어 호출됩니다.
  end
end
```

### 변환

클래스가 `persisted?` 및 `id` 메서드를 정의하면 해당 클래스에 `ActiveModel::Conversion` 모듈을 포함시킬 수 있으며, 해당 클래스의 객체에서 레일즈 변환 메서드를 호출할 수 있습니다.

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

객체의 속성에 대한 하나 이상의 변경이 발생하고 저장되지 않은 경우 해당 객체는 dirty 상태가 됩니다. `ActiveModel::Dirty`는 객체가 변경되었는지 여부를 확인할 수 있는 기능을 제공합니다. 또한 속성 기반의 접근자 메서드도 제공합니다. `first_name` 및 `last_name` 속성을 가진 Person 클래스를 고려해 봅시다:

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
    # 저장 작업 수행...
    changes_applied
  end
end
```

#### 변경된 모든 속성의 목록을 직접 쿼리하기

```irb
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "First Name"
irb> person.first_name
=> "First Name"

# 어떤 속성이든 저장되지 않은 변경 사항이 있는 경우 true를 반환합니다.
irb> person.changed?
=> true

# 저장하기 전에 변경된 속성의 목록을 반환합니다.
irb> person.changed
=> ["first_name"]

# 변경된 속성과 해당 원래 값으로 이루어진 해시를 반환합니다.
irb> person.changed_attributes
=> {"first_name"=>nil}

# 변경 사항을 속성 이름을 키로, 해당 필드의 이전 값과 새 값의 배열로 하는 변경 사항의 해시로 반환합니다.
irb> person.changes
=> {"first_name"=>[nil, "First Name"]}
```

#### 속성 기반의 접근자 메서드

특정 속성이 변경되었는지 여부를 추적합니다.
```irb
irb> person.first_name
=> "이름"

# attr_name_changed?
irb> person.first_name_changed?
=> true
```

속성의 이전 값을 추적합니다.

```irb
# attr_name_was accessor
irb> person.first_name_was
=> nil
```

변경된 속성의 이전 값과 현재 값을 추적합니다. 변경된 경우 배열을 반환하고 그렇지 않으면 nil을 반환합니다.

```irb
# attr_name_change
irb> person.first_name_change
=> [nil, "이름"]
irb> person.last_name_change
=> nil
```

### 유효성 검사

`ActiveModel::Validations` 모듈은 Active Record와 같이 객체를 유효성 검사할 수 있는 기능을 추가합니다.

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

### 네이밍

`ActiveModel::Naming`은 네이밍과 라우팅을 관리하기 쉽게 해주는 여러 클래스 메소드를 추가합니다. 이 모듈은 `model_name` 클래스 메소드를 정의하며, 이를 통해 `ActiveSupport::Inflector` 메소드를 사용하여 여러 접근자를 정의합니다.

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

### 모델

`ActiveModel::Model`을 사용하면 `ActiveRecord::Base`와 유사한 모델을 구현할 수 있습니다.

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # 이메일 전송
    end
  end
end
```

`ActiveModel::Model`을 포함하면 `ActiveModel::API`의 모든 기능을 사용할 수 있습니다.

### 직렬화

`ActiveModel::Serialization`은 객체에 대한 기본 직렬화 기능을 제공합니다. 직렬화하려는 속성을 포함하는 속성 해시를 선언해야 합니다. 속성은 심볼이 아닌 문자열이어야 합니다.

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

이제 `serializable_hash` 메소드를 사용하여 객체의 직렬화된 해시에 액세스할 수 있습니다.

```irb
irb> person = Person.new
irb> person.serializable_hash
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.serializable_hash
=> {"name"=>"Bob"}
```

#### ActiveModel::Serializers

Active Model은 JSON 직렬화/역직렬화를 위한 `ActiveModel::Serializers::JSON` 모듈도 제공합니다. 이 모듈은 이전에 설명한 `ActiveModel::Serialization` 모듈을 자동으로 포함합니다.

##### ActiveModel::Serializers::JSON

`ActiveModel::Serializers::JSON`을 사용하려면 포함하는 모듈을 `ActiveModel::Serialization`에서 `ActiveModel::Serializers::JSON`로 변경하면 됩니다.

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

`serializable_hash`와 유사한 `as_json` 메소드는 모델을 나타내는 해시를 제공합니다.

```irb
irb> person = Person.new
irb> person.as_json
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.as_json
=> {"name"=>"Bob"}
```

또한 JSON 문자열에서 모델의 속성을 정의할 수도 있습니다. 그러나 클래스에 `attributes=` 메소드를 정의해야 합니다.

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

이제 `from_json`을 사용하여 `Person`의 인스턴스를 생성하고 속성을 설정할 수 있습니다.

```irb
irb> json = { name: 'Bob' }.to_json
irb> person = Person.new
irb> person.from_json(json)
=> #<Person:0x00000100c773f0 @name="Bob">
irb> person.name
=> "Bob"
```

### 번역

`ActiveModel::Translation`은 객체와 Rails 국제화 (i18n) 프레임워크 간의 통합을 제공합니다.

```ruby
class Person
  extend ActiveModel::Translation
end
```

`human_attribute_name` 메소드를 사용하면 속성 이름을 더 읽기 쉬운 형식으로 변환할 수 있습니다. 읽기 쉬운 형식은 로케일 파일에서 정의됩니다.

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

### Lint 테스트

`ActiveModel::Lint::Tests`를 사용하면 객체가 Active Model API와 호환되는지 테스트할 수 있습니다.

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

Action Pack과 함께 작동하려면 모든 API를 구현할 필요는 없습니다. 이 모듈은 기능을 모두 제공하기 위한 가이드 역할만 합니다.

### SecurePassword

`ActiveModel::SecurePassword`를 사용하면 암호를 안전하게 저장할 수 있습니다. 이 모듈을 포함하면 기본적으로 `password` 접근자에 일부 유효성 검사가 정의된 `has_secure_password` 클래스 메소드가 제공됩니다.
#### 요구 사항

`ActiveModel::SecurePassword`는 [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt')에 의존하므로, `ActiveModel::SecurePassword`를 올바르게 사용하려면 `Gemfile`에 이 젬을 포함시켜야 합니다.
이를 작동시키기 위해서는 모델에 `XXX_digest`라는 이름의 접근자가 있어야 합니다.
여기서 `XXX`는 원하는 비밀번호의 속성 이름입니다.
다음과 같은 유효성 검사가 자동으로 추가됩니다:

1. 비밀번호는 반드시 존재해야 합니다.
2. 비밀번호는 확인과 일치해야 합니다 (`XXX_confirmation`이 함께 전달되는 경우).
3. 비밀번호의 최대 길이는 72입니다 (`bcrypt`에 필요한 ActiveModel::SecurePassword의 의존성).

#### 예제

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

# 비밀번호가 비어 있을 때.
irb> person.valid?
=> false

# 확인이 비밀번호와 일치하지 않을 때.
irb> person.password = 'aditya'
irb> person.password_confirmation = 'nomatch'
irb> person.valid?
=> false

# 비밀번호의 길이가 72를 초과할 때.
irb> person.password = person.password_confirmation = 'a' * 100
irb> person.valid?
=> false

# 비밀번호만 제공되고 password_confirmation이 없을 때.
irb> person.password = 'aditya'
irb> person.valid?
=> true

# 모든 유효성 검사가 통과되었을 때.
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
