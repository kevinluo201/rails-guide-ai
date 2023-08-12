**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37dd3507f05f7787a794868a2619e6d5
Active Record 유효성 검사
=========================

이 가이드는 Active Record의 유효성 검사 기능을 사용하여 데이터베이스에 객체가 들어가기 전에 객체의 상태를 검증하는 방법을 가르칩니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* 내장된 Active Record 유효성 검사 도우미를 사용하는 방법.
* 사용자 정의 유효성 검사 메서드를 만드는 방법.
* 유효성 검사 과정에서 생성된 오류 메시지를 처리하는 방법.

--------------------------------------------------------------------------------

유효성 검사 개요
--------------------

다음은 매우 간단한 유효성 검사의 예입니다:

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

보시다시피, 우리의 유효성 검사를 통해 `Person`이 `name` 속성이 없으면 유효하지 않다는 것을 알 수 있습니다. 두 번째 `Person`은 데이터베이스에 저장되지 않습니다.

더 자세히 알아보기 전에, 유효성 검사가 애플리케이션의 큰 그림에 어떻게 맞는지에 대해 이야기해 보겠습니다.

### 왜 유효성 검사를 사용하는가?

유효성 검사는 유효한 데이터만 데이터베이스에 저장되도록 보장하기 위해 사용됩니다. 예를 들어, 모든 사용자가 유효한 이메일 주소와 우편 주소를 제공하는 것이 애플리케이션에 중요할 수 있습니다. 모델 수준의 유효성 검사는 데이터베이스에 유효한 데이터만 저장되도록 보장하는 가장 좋은 방법입니다. 이들은 데이터베이스에 독립적이며, 최종 사용자에 의해 우회될 수 없으며, 테스트와 유지 보수가 편리합니다. Rails는 일반적인 요구 사항에 대한 내장된 도우미를 제공하며, 사용자 정의 유효성 검사 메서드를 만들 수도 있습니다.

데이터베이스에 저장되기 전에 데이터를 유효성 검사하는 다른 방법도 있습니다. 이 방법에는 네이티브 데이터베이스 제약 조건, 클라이언트 측 유효성 검사 및 컨트롤러 수준의 유효성 검사가 포함됩니다. 다음은 각각의 장단점을 요약한 것입니다:

* 데이터베이스 제약 조건과/또는 저장 프로시저는 유효성 검사 메커니즘을 데이터베이스 종속적으로 만들고 테스트와 유지 보수를 더 어렵게 만들 수 있습니다. 그러나 데이터베이스가 다른 애플리케이션에서 사용된다면 데이터베이스 수준에서 일부 제약 조건을 사용하는 것이 좋을 수 있습니다. 또한, 데이터베이스 수준의 유효성 검사는 그 외에 구현하기 어려운 몇 가지 사항(예: 많이 사용되는 테이블에서의 고유성)을 안전하게 처리할 수 있습니다.
* 클라이언트 측 유효성 검사는 유용할 수 있지만, 일반적으로 독립적으로 사용할 경우 신뢰성이 떨어집니다. JavaScript를 사용하여 구현된 경우, 사용자의 브라우저에서 JavaScript가 비활성화되면 우회될 수 있습니다. 그러나 다른 기술과 결합하여 사용되는 경우, 클라이언트 측 유효성 검사는 사용자가 사이트를 사용하는 동안 즉각적인 피드백을 제공하는 편리한 방법일 수 있습니다.
* 컨트롤러 수준의 유효성 검사는 사용하기 유혹이 있지만, 종종 복잡하고 테스트와 유지 보수가 어려워집니다. 가능한 경우 컨트롤러를 간단하게 유지하는 것이 좋습니다. 이렇게 하면 장기적으로 애플리케이션을 작업하기 쉽게 만들 수 있습니다.

특정한 경우에 이러한 방법을 선택하십시오. Rails 팀의 의견으로는 대부분의 경우 모델 수준의 유효성 검사가 가장 적합합니다.

### 언제 유효성 검사가 발생합니까?

Active Record 객체에는 데이터베이스의 행에 해당하는 객체와 그렇지 않은 객체 두 가지 종류가 있습니다. 예를 들어 `new` 메서드를 사용하여 새로운 객체를 생성하는 경우, 해당 객체는 아직 데이터베이스에 속하지 않습니다. 해당 객체에 `save`를 호출하면 적절한 데이터베이스 테이블에 저장됩니다. Active Record는 `new_record?` 인스턴스 메서드를 사용하여 객체가 이미 데이터베이스에 있는지 여부를 결정합니다. 다음은 Active Record 클래스를 보여주는 예입니다:

```ruby
class Person < ApplicationRecord
end
```

`bin/rails console` 출력을 살펴보면 어떻게 작동하는지 알 수 있습니다:

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

새로운 레코드를 생성하고 저장하면 데이터베이스에 SQL `INSERT` 작업이 전송됩니다. 기존 레코드를 업데이트하면 SQL `UPDATE` 작업이 전송됩니다. 유효성 검사는 일반적으로 이러한 명령이 데이터베이스로 전송되기 전에 실행됩니다. 유효성 검사가 실패하면 객체는 유효하지 않은 상태로 표시되고 Active Record는 `INSERT` 또는 `UPDATE` 작업을 수행하지 않습니다. 이렇게 하면 데이터베이스에 유효하지 않은 객체를 저장하는 것을 피할 수 있습니다. 특정한 유효성 검사가 객체가 생성되거나 저장되거나 업데이트될 때 실행되도록 선택할 수 있습니다.

주의: 객체의 상태를 데이터베이스에서 변경하는 여러 가지 방법이 있습니다. 일부 메서드는 유효성 검사를 트리거하지만, 일부는 그렇지 않을 수 있습니다. 따라서 조심하지 않으면 데이터베이스에 유효하지 않은 상태의 객체를 저장할 수 있습니다.
다음 메소드들은 유효성 검사를 트리거하며, 객체가 유효한 경우에만 데이터베이스에 객체를 저장합니다:

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

느낌표 버전 (예: `save!`)은 레코드가 유효하지 않은 경우 예외를 발생시킵니다.
느낌표가 없는 버전은 그렇지 않습니다: `save`와 `update`는 `false`를 반환하고,
`create`은 객체를 반환합니다.

### 유효성 검사 건너뛰기

다음 메소드들은 유효성 검사를 건너뛰고, 객체를 데이터베이스에 저장합니다. 이들은 주의해서 사용해야 합니다.

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

`save`도 `validate: false`를 인수로 전달하면 유효성 검사를 건너뛸 수 있습니다. 이 기술은 주의해서 사용해야 합니다.

* `save(validate: false)`

### `valid?`과 `invalid?`

Active Record 객체를 저장하기 전에 Rails는 유효성 검사를 실행합니다.
이 유효성 검사에서 오류가 발생하면 Rails는 객체를 저장하지 않습니다.

또한 직접 이러한 유효성 검사를 실행할 수도 있습니다. [`valid?`][]은 유효성 검사를 트리거하고,
객체에 오류가 없는 경우 `true`를 반환하고, 그렇지 않은 경우 `false`를 반환합니다.
위에서 보았듯이:

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

Active Record가 유효성 검사를 수행한 후, 실패한 경우 [`errors`][] 인스턴스 메소드를 통해
접근할 수 있으며, 이는 오류의 컬렉션을 반환합니다.
정의에 따라, 객체는 유효하다고 간주됩니다. 이 컬렉션을 실행한 후 비어 있습니다.

`new`로 인스턴스화된 객체는 `create`나 `save` 메소드와 같이 객체가 저장될 때에만
자동으로 실행되기 때문에 기술적으로 유효하지 않아도 오류를 보고하지 않습니다.

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

[`invalid?`][]은 `valid?`의 반대입니다. 유효성 검사를 트리거하며,
객체에 오류가 있는 경우 `true`를 반환하고, 그렇지 않은 경우 `false`를 반환합니다.


### `errors[]`

객체의 특정 속성이 유효한지 여부를 확인하려면 [`errors[:attribute]`][Errors#squarebrackets]를 사용할 수 있습니다.
`:attribute`에 대한 모든 오류 메시지의 배열을 반환합니다. 지정된 속성에 오류가 없으면 빈 배열이 반환됩니다.

이 메소드는 유효성 검사가 실행된 후에만 유용합니다. 왜냐하면 이 메소드는 오류 컬렉션을 검사하기 때문에
유효성 검사 자체를 트리거하지 않습니다. 위에서 설명한 `ActiveRecord::Base#invalid?` 메소드와는 다릅니다.
객체의 전체적인 유효성을 검증하지 않습니다. 객체의 개별 속성에 오류가 있는지 확인하기만 합니다.

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

[Working with Validation Errors](#working-with-validation-errors) 섹션에서 유효성 검사 오류에 대해 자세히 알아보겠습니다.


유효성 검사 도우미
------------------

Active Record는 클래스 정의 내에서 직접 사용할 수 있는 여러 사전 정의된 유효성 검사 도우미를 제공합니다.
이 도우미들은 일반적인 유효성 검사 규칙을 제공합니다. 유효성 검사가 실패할 때마다 오류가 객체의 `errors` 컬렉션에 추가되며,
이는 유효성 검사 중인 속성과 관련됩니다.

각 도우미는 임의의 속성 이름을 여러 개 받을 수 있으므로, 한 줄의 코드로 여러 속성에 동일한 유형의 유효성 검사를 추가할 수 있습니다.

모든 도우미는 `:on`과 `:message` 옵션을 받습니다. 이 옵션은 각각 유효성 검사가 실행되어야 하는 시점과
실패한 경우 `errors` 컬렉션에 추가될 메시지를 정의합니다. `:on` 옵션은 `:create` 또는 `:update` 값 중 하나를 가집니다.
각 유효성 검사 도우미마다 기본 오류 메시지가 있습니다. 이 메시지는 `:message` 옵션이 지정되지 않은 경우 사용됩니다.
사용 가능한 도우미 각각을 살펴보겠습니다.

INFO: 사용 가능한 기본 도우미 목록은 [`ActiveModel::Validations::HelperMethods`][]를 참조하세요.
### `acceptance`

이 메소드는 사용자 인터페이스의 체크박스가 폼을 제출할 때 체크되었는지를 확인합니다. 이는 일반적으로 사용자가 애플리케이션의 이용 약관에 동의하거나 특정 텍스트를 읽었는지 확인해야 할 때 사용됩니다.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

이 체크는 `terms_of_service`가 `nil`이 아닌 경우에만 수행됩니다.
이 도우미에 대한 기본 오류 메시지는 _"must be accepted"_입니다.
`message` 옵션을 통해 사용자 정의 메시지를 전달할 수도 있습니다.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: 'must be abided' }
end
```

또한 `:accept` 옵션을 받을 수도 있으며, 이는 허용되는 값들을 결정합니다.
기본값은 `['1', true]`이며 쉽게 변경할 수 있습니다.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'yes' }
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end
```

이 유효성 검사는 웹 애플리케이션에 매우 특화되어 있으며, 이 'acceptance'은 데이터베이스에 기록할 필요가 없습니다. 필드가 없는 경우 도우미는 가상 속성을 생성합니다. 데이터베이스에 필드가 있는 경우 `accept` 옵션은 `true`를 설정하거나 포함해야만 유효성 검사가 실행됩니다.

### `confirmation`

이 도우미는 두 개의 텍스트 필드가 정확히 동일한 내용을 받아야 할 때 사용합니다. 예를 들어, 이메일 주소나 비밀번호를 확인하려고 할 때 사용됩니다. 이 유효성 검사는 확인해야 할 필드 이름에 "_confirmation"이 추가된 가상 속성을 생성합니다.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

뷰 템플릿에서 다음과 같이 사용할 수 있습니다.

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

참고: 이 체크는 `email_confirmation`이 `nil`이 아닌 경우에만 수행됩니다. 확인을 요구하려면 확인 속성에 대한 존재 여부 검사를 추가해야 합니다 (`presence`에 대해서는 이 가이드의 이후 부분에서 살펴보겠습니다):

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

또한 `:case_sensitive` 옵션을 사용하여 확인 제약 조건이 대소문자를 구분할지 여부를 정의할 수 있습니다. 이 옵션의 기본값은 `true`입니다.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

이 도우미에 대한 기본 오류 메시지는 _"doesn't match confirmation"_입니다. `message` 옵션을 통해 사용자 정의 메시지를 전달할 수도 있습니다.

일반적으로 이 유효성 검사기를 사용할 때는 `:if` 옵션과 함께 사용하여 초기 필드가 변경되었을 때에만 "_confirmation" 필드를 유효성 검사하고 레코드를 저장할 때마다 검사하지 않도록 할 것입니다. [조건부 유효성 검사](#conditional-validation)에 대해 더 자세히 알아보겠습니다.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?
end
```

### `comparison`

이 체크는 두 개의 비교 가능한 값 사이의 비교를 유효성 검사합니다.

```ruby
class Promotion < ApplicationRecord
  validates :end_date, comparison: { greater_than: :start_date }
end
```

이 도우미에 대한 기본 오류 메시지는 _"failed comparison"_입니다. `message` 옵션을 통해 사용자 정의 메시지를 전달할 수도 있습니다.

다음 옵션들이 모두 지원됩니다:

* `:greater_than` - 값이 지정된 값보다 크다는 것을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be greater than %{count}"_입니다.
* `:greater_than_or_equal_to` - 값이 지정된 값보다 크거나 같다는 것을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be greater than or equal to %{count}"_입니다.
* `:equal_to` - 값이 지정된 값과 같다는 것을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be equal to %{count}"_입니다.
* `:less_than` - 값이 지정된 값보다 작다는 것을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be less than %{count}"_입니다.
* `:less_than_or_equal_to` - 값이 지정된 값보다 작거나 같다는 것을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be less than or equal to %{count}"_입니다.
* `:other_than` - 값이 지정된 값과 다른 것을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be other than %{count}"_입니다.

참고: 유효성 검사기는 비교 옵션이 제공되어야 합니다. 각 옵션은 값, 프로크, 또는 심볼을 허용합니다. Comparable을 포함하는 모든 클래스를 비교할 수 있습니다.
### `format`

이 도우미는 `:with` 옵션을 사용하여 지정된 정규 표현식과 일치하는지를 테스트하여 속성 값의 유효성을 검사합니다.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
end
```

반대로, `:without` 옵션을 사용하면 지정된 속성이 정규 표현식과 일치하지 않아야 함을 요구할 수 있습니다.

어느 경우든, 제공된 `:with` 또는 `:without` 옵션은 정규 표현식이거나 정규 표현식을 반환하는 proc 또는 lambda여야 합니다.

기본 오류 메시지는 _"is invalid"_입니다.

경고. 문자열의 시작과 끝을 일치시키기 위해 `\A`와 `\z`를 사용하고, `^`와 `$`는 줄의 시작/끝과 일치합니다. `^`와 `$`의 오용이 빈번하므로, 제공된 정규 표현식에서 이 두 앵커 중 하나를 사용하는 경우 `multiline: true` 옵션을 전달해야 합니다. 대부분의 경우 `\A`와 `\z`를 사용해야 합니다.

### `inclusion`

이 도우미는 속성 값이 주어진 집합에 포함되어 있는지를 검사합니다. 사실, 이 집합은 어떤 열거 가능한 객체든 될 수 있습니다.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
end
```

`inclusion` 도우미에는 수락될 값 집합을 받는 `:in` 옵션이 있습니다. `:in` 옵션은 동일한 목적을 위해 사용할 수 있는 `:within`이라는 별칭을 가지고 있습니다. 이전 예제는 `:message` 옵션을 사용하여 속성 값이 포함되도록 하는 방법을 보여줍니다. 전체 옵션에 대해서는 [메시지 문서](#message)를 참조하십시오.

이 도우미의 기본 오류 메시지는 _"is not included in the list"_입니다.

### `exclusion`

`inclusion`의 반대는... `exclusion`입니다!

이 도우미는 속성 값이 주어진 집합에 포함되지 않아야 함을 검사합니다. 사실, 이 집합은 어떤 열거 가능한 객체든 될 수 있습니다.

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} is reserved." }
end
```

`exclusion` 도우미에는 검증된 속성에 대해 수락되지 않을 값 집합을 받는 `:in` 옵션이 있습니다. `:in` 옵션은 동일한 목적을 위해 사용할 수 있는 `:within`이라는 별칭을 가지고 있습니다. 이 예제는 `:message` 옵션을 사용하여 속성 값이 포함되지 않도록 하는 방법을 보여줍니다. 메시지 인수에 대한 전체 옵션은 [메시지 문서](#message)를 참조하십시오.

기본 오류 메시지는 _"is reserved"_입니다.

전통적인 열거 가능한 객체(예: 배열) 대신에 열거 가능한 객체를 반환하는 proc, lambda 또는 심볼을 제공할 수도 있습니다. 열거 가능한 객체가 숫자, 시간 또는 날짜/시간 범위인 경우 `Range#cover?`로 테스트되고, 그렇지 않은 경우 `include?`로 테스트됩니다. proc 또는 lambda를 사용할 때는 유효성 검사 중인 인스턴스가 인수로 전달됩니다.

### `length`

이 도우미는 속성 값의 길이를 검사합니다. 다양한 옵션을 제공하여 길이 제약 조건을 다른 방식으로 지정할 수 있습니다.

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

가능한 길이 제약 조건 옵션은 다음과 같습니다:

* `:minimum` - 속성은 지정된 길이보다 작을 수 없습니다.
* `:maximum` - 속성은 지정된 길이보다 클 수 없습니다.
* `:in` (또는 `:within`) - 속성 길이는 주어진 범위에 포함되어야 합니다. 이 옵션의 값은 범위여야 합니다.
* `:is` - 속성 길이는 주어진 값과 같아야 합니다.

기본 오류 메시지는 수행되는 길이 유효성 검사의 유형에 따라 다릅니다. `:wrong_length`, `:too_long`, `:too_short` 옵션과 `%{count}`를 길이 제약 조건에 해당하는 숫자의 자리 표시자로 사용하여 이러한 메시지를 사용자 정의할 수 있습니다. 여전히 `:message` 옵션을 사용하여 오류 메시지를 지정할 수 있습니다.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} characters is the maximum allowed" }
end
```

기본 오류 메시지는 복수형입니다(예: "is too short (minimum is %{count} characters)"). 이러한 이유로 `:minimum`이 1인 경우 사용자 정의 메시지를 제공하거나 `presence: true`를 대신 사용해야 합니다. `:in` 또는 `:within`의 하한이 1인 경우, 사용자 정의 메시지를 제공하거나 `length` 이전에 `presence`를 호출해야 합니다.
참고: `:minimum` 및 `:maximum` 옵션을 제외하고는 한 번에 하나의 제약 옵션만 사용할 수 있습니다.

### `numericality`

이 도우미는 속성이 숫자 값만 가지는지를 확인합니다. 기본적으로 선택 사항인 부호 뒤에 정수 또는 부동 소수점 숫자가 옵니다.

정수 숫자만 허용하려면 `:only_integer`를 true로 설정하십시오. 그런 다음 다음 정규식을 사용하여 속성 값의 유효성을 검사합니다.

```ruby
/\A[+-]?\d+\z/
```

그렇지 않으면 `Float`를 사용하여 값을 숫자로 변환하려고 시도합니다. `Float`는 열의 정밀도 값 또는 최대 15 자리까지 `BigDecimal`로 변환됩니다.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

`:only_integer`에 대한 기본 오류 메시지는 _"must be an integer"_입니다.

`numericality` 외에도 이 도우미는 `:only_numeric` 옵션을 허용합니다. 이 옵션은 값이 `Numeric`의 인스턴스여야 하며, `String`인 경우 값을 구문 분석하려고 시도합니다.

참고: 기본적으로 `numericality`는 `nil` 값을 허용하지 않습니다. `allow_nil: true` 옵션을 사용하여 허용할 수 있습니다. `Integer` 및 `Float` 열의 경우 빈 문자열은 `nil`로 변환됩니다.

옵션이 지정되지 않은 경우의 기본 오류 메시지는 _"is not a number"_입니다.

허용 가능한 값에 제약 조건을 추가하기 위해 사용할 수 있는 많은 옵션이 있습니다.

* `:greater_than` - 지정된 값보다 큰 값이어야 함을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be greater than %{count}"_입니다.
* `:greater_than_or_equal_to` - 지정된 값보다 크거나 같은 값이어야 함을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be greater than or equal to %{count}"_입니다.
* `:equal_to` - 지정된 값과 같아야 함을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be equal to %{count}"_입니다.
* `:less_than` - 지정된 값보다 작은 값이어야 함을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be less than %{count}"_입니다.
* `:less_than_or_equal_to` - 지정된 값보다 작거나 같은 값이어야 함을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be less than or equal to %{count}"_입니다.
* `:other_than` - 지정된 값과 다른 값이어야 함을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be other than %{count}"_입니다.
* `:in` - 지정된 범위 내에 값이 있어야 함을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be in %{count}"_입니다.
* `:odd` - 홀수여야 함을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be odd"_입니다.
* `:even` - 짝수여야 함을 지정합니다. 이 옵션에 대한 기본 오류 메시지는 _"must be even"_입니다.

### `presence`

이 도우미는 지정된 속성이 비어 있지 않은지를 확인합니다. 값이 `nil`이거나 공백 문자열인지(빈 문자열이거나 공백으로만 구성된 문자열)를 확인하기 위해 [`Object#blank?`][] 메서드를 사용합니다.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

연관된 개체가 존재하는지 확인하려면 연관된 개체 자체가 존재하는지 확인해야 하며, 연관성을 매핑하는 데 사용되는 외래 키가 비어 있지 않은지만 확인하는 것은 아닙니다. 이렇게 하면 외래 키가 비어 있지 않을 뿐만 아니라 참조된 개체가 존재하는지도 확인됩니다.

```ruby
class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end
```

필수적으로 존재해야 하는 연관된 레코드를 유효성 검사하려면 연관성에 대해 `:inverse_of` 옵션을 지정해야 합니다.

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

참고: 연관된 개체가 존재하고 유효한지 확인하려면 `validates_associated`를 사용해야 합니다. 자세한 내용은 아래를 참조하십시오.

`has_one` 또는 `has_many` 관계를 통해 연관된 개체의 존재 여부를 유효성 검사하면 개체가 `blank?` 또는 `marked_for_destruction?`인지 확인합니다.

`false.blank?`가 true이므로 불리언 필드의 존재 여부를 확인하려면 다음 유효성 검사 중 하나를 사용해야 합니다.

```ruby
# 값은 true 또는 false 여야 함
validates :boolean_field_name, inclusion: [true, false]
# 값은 nil이 아니어야 함, 즉 true 또는 false
validates :boolean_field_name, exclusion: [nil]
```
이러한 유효성 검사 중 하나를 사용하면 값이 `nil`이 아닌 것을 보장하여 대부분의 경우 `NULL` 값이 발생하지 않습니다.

기본 오류 메시지는 _"비워 둘 수 없음"_입니다.


### `absence`

이 도우미는 지정된 속성이 없음을 검증합니다. 값이 nil이거나 공백 문자열(빈 문자열 또는 공백으로 구성된 문자열)이 아닌지 확인하기 위해 [`Object#present?`][] 메서드를 사용합니다.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

연관 객체가 없는지 확인하려면 연관된 객체 자체가 없는지 확인하고 매핑에 사용되는 외래 키가 아닌지 테스트해야 합니다.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

부재가 필요한 연관 레코드를 유효성 검사하려면 연관에 대한 `:inverse_of` 옵션을 지정해야 합니다.

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

참고: 연관이 존재하고 유효한지 확인하려면 `validates_associated`도 사용해야 합니다. 자세한 내용은 아래를 참조하세요.

`has_one` 또는 `has_many` 관계를 통해 연관된 객체의 부재를 검증하는 경우, 객체가 `present?`이거나 `marked_for_destruction?`인지 확인합니다.

`false.present?`가 false이므로 부울 필드의 부재를 검증하려면 `validates :field_name, exclusion: { in: [true, false] }`를 사용해야 합니다.

기본 오류 메시지는 _"비워져야 함"_입니다.


### `uniqueness`

이 도우미는 객체를 저장하기 바로 전에 속성 값이 고유한지 검증합니다.

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

검증은 모델의 테이블에 대한 SQL 쿼리를 수행하여 해당 속성에 동일한 값이 있는 기존 레코드를 검색함으로써 수행됩니다.

고유성 검사를 제한하는 데 사용할 수 있는 하나 이상의 속성을 지정하기 위해 `:scope` 옵션을 사용할 수 있습니다.

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "should happen once per year" }
end
```

경고. 이 유효성 검사는 데이터베이스에 고유성 제약 조건을 생성하지 않으므로, 두 개의 다른 데이터베이스 연결이 동일한 값을 가진 두 개의 레코드를 생성할 수 있습니다. 고유한 인덱스를 데이터베이스의 해당 열에 생성해야 합니다.

데이터베이스에 고유성 제약 조건을 추가하려면 마이그레이션에서 [`add_index`][] 문을 사용하고 `unique: true` 옵션을 포함해야 합니다.

`scope` 옵션을 사용하여 고유성 검증의 가능한 위반을 방지하기 위해 데이터베이스 제약 조건을 생성하려면 두 열에 대해 고유한 인덱스를 생성해야 합니다. 여러 열 인덱스에 대한 자세한 내용은 [MySQL 매뉴얼][]을 참조하고, 열 그룹을 참조하는 고유 제약 조건에 대한 예제는 [PostgreSQL 매뉴얼][]을 참조하세요.

또한 `:case_sensitive` 옵션을 사용하여 고유성 제약 조건이 대소문자를 구분하거나 대소문자를 구분하지 않거나 기본 데이터베이스 정렬을 따를지를 정의할 수 있습니다. 이 옵션은 기본적으로 기본 데이터베이스 정렬을 따릅니다.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

경고. 일부 데이터베이스는 대소문자를 구분하지 않는 검색을 수행하도록 구성되어 있습니다.

추가 조건을 지정하기 위해 `:conditions` 옵션을 사용하여 `WHERE` SQL 조각으로 고유성 제약 조건 조회를 제한할 수 있습니다(예: `conditions: -> { where(status: 'active') }`).

기본 오류 메시지는 _"이미 사용 중입니다"_입니다.

자세한 내용은 [`validates_uniqueness_of`][]를 참조하세요.

[MySQL 매뉴얼]: https://dev.mysql.com/doc/refman/en/multiple-column-indexes.html
[PostgreSQL 매뉴얼]: https://www.postgresql.org/docs/current/static/ddl-constraints.html

### `validates_associated`

이 도우미는 모델에 항상 유효성을 검사해야 하는 연관이 있는 경우에 사용해야 합니다. 객체를 저장하려고 할 때마다 연관된 각 객체에 대해 `valid?`이 호출됩니다.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

이 유효성 검사는 모든 연관 유형과 함께 작동합니다.

주의: 연관의 양쪽 끝에 `validates_associated`를 사용하지 마세요. 그렇게 하면 무한 루프에서 서로를 호출합니다.

[`validates_associated`][]에 대한 기본 오류 메시지는 _"유효하지 않음"_입니다. 각 연관된 객체에는 고유한 `errors` 컬렉션이 포함되며, 오류는 호출하는 모델로 전달되지 않습니다.

참고: [`validates_associated`][]는 ActiveRecord 객체와 함께 사용할 수 있으며, 지금까지의 내용은 [`ActiveModel::Validations`][]을 포함하는 모든 객체에서도 사용할 수 있습니다.
### `validates_each`

이 도우미는 블록에 대한 속성을 유효성 검사합니다. 미리 정의된 유효성 검사 기능이 없습니다. 블록을 사용하여 하나를 생성하고 [`validates_each`][]에 전달된 모든 속성이 이를 테스트합니다.

다음 예에서는 소문자로 시작하는 이름과 성을 거부합니다.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'must start with upper case') if /\A[[:lower:]]/.match?(value)
  end
end
```

블록은 레코드, 속성 이름 및 속성 값을 받습니다.

블록 내에서 유효한 데이터를 확인하기 위해 원하는 작업을 수행할 수 있습니다. 유효성 검사가 실패하면 모델에 오류를 추가하여 유효하지 않게 만들어야 합니다.


### `validates_with`

이 도우미는 유효성 검사를 위해 레코드를 별도의 클래스에 전달합니다.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors.add :base, "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

`validates_with`에는 기본 오류 메시지가 없습니다. 유효성 검사기 클래스에서 수동으로 레코드의 오류 컬렉션에 오류를 추가해야 합니다.

참고: `record.errors[:base]`에 추가된 오류는 레코드의 전체 상태와 관련이 있습니다.

validate 메서드를 구현하려면 유효성 검사를 수행할 레코드로 `record` 매개변수를 메서드 정의에서 허용해야 합니다.

특정 속성에 오류를 추가하려면 첫 번째 인수로 전달하십시오. 예를 들어 `record.errors.add(:first_name, "please choose another name")`과 같이 전달하십시오. 나중에 [validation errors][]에 대해 자세히 설명하겠습니다.

```ruby
def validate(record)
  if record.some_field != "acceptable"
    record.errors.add :some_field, "this field is unacceptable"
  end
end
```

[`validates_with`][] 도우미는 유효성 검사에 사용할 클래스 또는 클래스 목록을 가져옵니다.

```ruby
class Person < ApplicationRecord
  validates_with MyValidator, MyOtherValidator, on: :create
end
```

다른 모든 유효성 검사와 마찬가지로 `validates_with`는 `:if`, `:unless` 및 `:on` 옵션을 사용할 수 있습니다. 다른 옵션을 전달하면 해당 옵션을 `options`로 유효성 검사기 클래스에 전달합니다.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| record.send(field) == "Evil" }
      record.errors.add :base, "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

유효성 검사기는 응용 프로그램 수명 주기 전체에서 *한 번만* 초기화되며 각 유효성 검사 실행마다 초기화되지 않으므로 내부에서 인스턴스 변수를 사용하는 데 주의해야 합니다.

검증기가 인스턴스 변수를 사용할만큼 복잡하다면 일반적인 Ruby 객체를 사용할 수 있습니다.

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
      @person.errors.add :base, "This person is evil"
    end
  end

  # ...
end
```

나중에 [custom validations](#performing-custom-validations)에 대해 자세히 설명하겠습니다.

[validation errors](#working-with-validation-errors)

Common Validation Options
-------------------------

방금 설명한 유효성 검사기에서 지원하는 일부 공통 옵션이 있습니다. 이제 이들 중 일부를 살펴보겠습니다!

참고: 이러한 옵션은 모든 유효성 검사기에서 지원되는 것은 아닙니다. [`ActiveModel::Validations`][]의 API 문서를 참조하십시오.

방금 언급한 유효성 검사 방법 중 하나를 사용하면 유효성 검사와 함께 공유되는 일부 공통 옵션이 있습니다. 이제 이들을 살펴보겠습니다!

* [`:allow_nil`](#allow-nil): 속성이 `nil`인 경우 유효성 검사를 건너뜁니다.
* [`:allow_blank`](#allow-blank): 속성이 공백인 경우 유효성 검사를 건너뜁니다.
* [`:message`](#message): 사용자 정의 오류 메시지를 지정합니다.
* [`:on`](#on): 이 유효성 검사가 활성화되는 컨텍스트를 지정합니다.
* [`:strict`](#strict-validations): 유효성 검사 실패 시 예외를 발생시킵니다.
* [`:if` and `:unless`](#conditional-validation): 유효성 검사가 발생해야 하는지 여부를 지정합니다.


### `:allow_nil`

`:allow_nil` 옵션은 유효성 검사 대상 값이 `nil`인 경우 유효성 검사를 건너뜁니다.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }, allow_nil: true
end
```

```irb
irb> Coffee.create(size: nil).valid?
=> true
irb> Coffee.create(size: "mega").valid?
=> false
```

메시지 인수에 대한 전체 옵션은 [message documentation](#message)을 참조하십시오.

### `:allow_blank`

`:allow_blank` 옵션은 `:allow_nil` 옵션과 유사합니다. 이 옵션은 속성 값이 `blank?`인 경우 유효성 검사를 통과시킵니다. 예를 들어 `nil` 또는 빈 문자열과 같은 경우입니다.

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
이미 보셨듯이 `:message` 옵션을 사용하면 유효성 검사 실패 시 `errors` 컬렉션에 추가될 메시지를 지정할 수 있습니다. 이 옵션을 사용하지 않으면 Active Record는 각 유효성 검사 도우미에 대한 기본 오류 메시지를 사용합니다.

`:message` 옵션은 `String` 또는 `Proc`를 값으로 받을 수 있습니다.

`String` `:message` 값은 `%{value}`, `%{attribute}`, `%{model}` 중 하나 이상을 선택적으로 포함할 수 있으며, 유효성 검사 실패 시 동적으로 대체됩니다. 이 대체는 i18n gem을 사용하여 수행되며, 플레이스홀더는 정확히 일치해야 합니다. 공백은 허용되지 않습니다.

```ruby
class Person < ApplicationRecord
  # 하드코딩된 메시지
  validates :name, presence: { message: "반드시 입력해주세요" }

  # 동적 속성 값이 포함된 메시지. %{value}는 속성의 실제 값으로 대체됩니다. %{attribute}와 %{model}도 사용할 수 있습니다.
  validates :age, numericality: { message: "%{value}은(는) 잘못된 것 같습니다" }
end
```

`Proc` `:message` 값은 두 개의 인수를 받습니다. 유효성을 검사하는 객체와 `:model`, `:attribute`, `:value` 키-값 쌍을 포함하는 해시입니다.

```ruby
class Person < ApplicationRecord
  validates :username,
    uniqueness: {
      # object = 유효성을 검사하는 person 객체
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "안녕 #{object.name}, #{data[:value]}은(는) 이미 사용 중입니다."
      end
    }
end
```

### `:on`

`:on` 옵션을 사용하면 유효성 검사가 언제 실행될지 지정할 수 있습니다. 내장된 모든 유효성 검사 도우미의 기본 동작은 저장 시 실행되는 것입니다(새 레코드를 생성하거나 업데이트할 때 모두). 이를 변경하려면 `on: :create`를 사용하여 새 레코드가 생성될 때만 유효성 검사를 실행하거나 `on: :update`를 사용하여 레코드가 업데이트될 때만 유효성 검사를 실행할 수 있습니다.

```ruby
class Person < ApplicationRecord
  # 중복된 값으로 이메일을 업데이트할 수 있습니다
  validates :email, uniqueness: true, on: :create

  # 숫자가 아닌 나이로 레코드를 생성할 수 있습니다
  validates :age, numericality: true, on: :update

  # 기본값(생성 및 업데이트 모두에서 유효성 검사 실행)
  validates :name, presence: true
end
```

`on:`을 사용하여 사용자 정의 컨텍스트를 정의할 수도 있습니다. 사용자 정의 컨텍스트는 `valid?`, `invalid?`, 또는 `save`에 컨텍스트 이름을 전달하여 명시적으로 트리거해야 합니다.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end
```

```irb
irb> person = Person.new(age: '삼십삼')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["이미 사용 중입니다"], :age=>["숫자가 아닙니다"]}
```

`person.valid?(:account_setup)`은 모델을 저장하지 않고 유효성 검사를 모두 실행합니다. `person.save(context: :account_setup)`은 저장하기 전에 `account_setup` 컨텍스트에서 `person`을 유효성 검사합니다.

심볼의 배열을 전달하는 것도 허용됩니다.

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
=> {:title=>["입력해야 합니다"]}
```

명시적 컨텍스트로 트리거되는 경우 유효성 검사는 해당 컨텍스트뿐만 아니라 컨텍스트가 없는 모든 유효성 검사도 실행됩니다.

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
=> {:email=>["이미 사용 중입니다"], :age=>["숫자가 아닙니다"], :name=>["입력해야 합니다"]}
```

`on:`에 대한 더 많은 사용 사례는 [콜백 가이드](active_record_callbacks.html)에서 다룰 예정입니다.

엄격한 유효성 검사
------------------

객체가 유효하지 않을 때 `ActiveModel::StrictValidationFailed`를 발생시키도록 유효성 검사를 지정할 수도 있습니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end
```

```irb
irb> Person.new.valid?
ActiveModel::StrictValidationFailed: 이름을 입력해야 합니다
```

`:strict` 옵션에 사용자 정의 예외를 전달할 수도 있습니다.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end
```

```irb
irb> Person.new.valid?
TokenGenerationException: 토큰을 입력해야 합니다
```

조건부 유효성 검사
------------------

특정 조건이 충족될 때에만 객체를 유효성 검사해야 할 경우가 있습니다. 이 경우 `:if`와 `:unless` 옵션을 사용하여 심볼, `Proc`, 또는 배열을 전달할 수 있습니다. 유효성 검사가 **해당 조건에서만** 실행되어야 하는 경우 `:if` 옵션을 사용할 수 있습니다. 반대로 유효성 검사가 **해당 조건에서는 실행되지 않아야 하는 경우** `:unless` 옵션을 사용할 수 있습니다.
### `:if`와 `:unless`와 함께 심볼 사용하기

`validates` 메소드의 `:if`와 `:unless` 옵션에는 검증이 발생하기 전에 호출되는 메소드의 이름에 해당하는 심볼을 연결할 수 있습니다. 이것은 가장 일반적으로 사용되는 옵션입니다.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### `:if`와 `:unless`와 함께 Proc 사용하기

`Proc` 객체와 `:if`와 `:unless`를 연결하여 호출될 수 있습니다. `Proc` 객체를 사용하면 별도의 메소드 대신 인라인 조건을 작성할 수 있습니다. 이 옵션은 한 줄짜리 코드에 가장 적합합니다.

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

`lambda`는 `Proc`의 한 유형이므로 축약된 구문을 활용하여 인라인 조건을 작성하는 데에도 사용할 수 있습니다.

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### 조건부 검증 그룹화하기

가끔은 여러 검증이 하나의 조건을 사용하는 것이 유용할 수 있습니다. 이를 [`with_options`][]를 사용하여 쉽게 구현할 수 있습니다.

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

`with_options` 블록 내부의 모든 검증은 자동으로 `if: :is_admin?` 조건을 통과합니다.


### 검증 조건 결합하기

반대로, 여러 조건이 검증이 발생해야 하는지 여부를 정의하는 경우 `Array`를 사용할 수 있습니다. 또한, 동일한 검증에 `:if`와 `:unless`를 모두 적용할 수 있습니다.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

검증은 모든 `:if` 조건이 참으로 평가되고 `:unless` 조건 중 하나도 참으로 평가되지 않을 때에만 실행됩니다.

사용자 정의 검증 수행하기
-----------------------------

내장된 검증 도우미가 요구 사항을 충족시키지 못하는 경우, 필요에 맞게 사용자 정의 검증기나 검증 메소드를 작성할 수 있습니다.

### 사용자 정의 검증기

사용자 정의 검증기는 [`ActiveModel::Validator`][]를 상속하는 클래스입니다. 이러한 클래스는 레코드를 인수로 받아 검증을 수행하는 `validate` 메소드를 구현해야 합니다. 사용자 정의 검증기는 `validates_with` 메소드를 사용하여 호출됩니다.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "Provide a name starting with X, please!"
    end
  end
end

class Person < ApplicationRecord
  validates_with MyValidator
end
```

개별 속성을 검증하기 위해 사용자 정의 검증기를 추가하는 가장 쉬운 방법은 편리한 [`ActiveModel::EachValidator`][]를 사용하는 것입니다. 이 경우, 사용자 정의 검증기 클래스는 인스턴스, 검증할 속성 및 전달된 인스턴스의 속성 값에 해당하는 `validate_each` 메소드를 구현해야 합니다.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless URI::MailTo::EMAIL_REGEXP.match?(value)
      record.errors.add attribute, (options[:message] || "is not an email")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

예제에서 보여주는 것처럼, 표준 검증과 사용자 정의 검증기를 결합할 수도 있습니다.


### 사용자 정의 메소드

모델의 상태를 확인하고 유효하지 않을 때 `errors` 컬렉션에 오류를 추가하는 메소드를 생성할 수도 있습니다. 그런 다음 `validate` 클래스 메소드를 사용하여 이러한 메소드를 등록해야 합니다. 각 클래스 메소드에 대해 하나 이상의 심볼을 전달할 수 있으며, 해당 검증은 등록된 순서대로 실행됩니다.

`valid?` 메소드는 `errors` 컬렉션이 비어 있는지 확인하므로, 사용자 정의 검증 메소드는 유효성 검사가 실패할 때 오류를 추가해야 합니다.

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "can't be greater than total value")
    end
  end
end
```

기본적으로 이러한 검증은 `valid?`을 호출하거나 객체를 저장할 때마다 실행됩니다. 그러나 `validate` 메소드에 `:on` 옵션을 주어 이러한 사용자 정의 검증을 언제 실행할지 제어할 수도 있습니다. `:create` 또는 `:update` 중 하나로 `:on` 옵션을 사용할 수 있습니다.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "is not active") unless customer.active?
  end
end
```
자세한 내용은 위의 섹션을 참조하십시오.

### 유효성 검사기 나열

주어진 객체의 모든 유효성 검사기를 찾으려면 `validators`를 사용하십시오.

예를 들어, 다음과 같은 사용자 정의 유효성 검사기와 내장 유효성 검사기를 사용하는 모델이 있다고 가정해 봅시다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, on: :create
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates_with MyOtherValidator, strict: true
end
```

이제 "Person" 모델에서 `validators`를 사용하여 모든 유효성 검사기를 나열하거나 `validators_on`을 사용하여 특정 필드를 확인할 수 있습니다.

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


유효성 검사 오류 처리
------------------------------

[`valid?`][] 및 [`invalid?`][] 메서드는 유효성에 대한 요약 상태만 제공합니다. 그러나 [`errors`][] 컬렉션의 다양한 메서드를 사용하여 각 개별 오류에 대해 자세히 알아볼 수 있습니다.

다음은 가장 일반적으로 사용되는 메서드 목록입니다. 사용 가능한 모든 메서드 목록은 [`ActiveModel::Errors`][] 문서를 참조하십시오.


### `errors`

각 오류의 다양한 세부 정보를 자세히 살펴볼 수 있는 게이트웨이입니다.

이는 각 오류가 [`ActiveModel::Error`][] 객체로 표시되는 모든 오류를 포함하는 `ActiveModel::Errors` 클래스의 인스턴스를 반환합니다.

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
=> ["Name can’t be blank", "Name is too short (minimum is 3 characters)"]

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

특정 속성의 오류 메시지를 확인하려는 경우 [`errors[]`][Errors#squarebrackets]를 사용합니다. 지정된 속성에 대한 모든 오류 메시지가 포함된 문자열 배열을 반환하며, 각 문자열은 하나의 오류 메시지를 가리킵니다. 속성과 관련된 오류가 없는 경우 빈 배열을 반환합니다.

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
=> ["is too short (minimum is 3 characters)"]

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["can’t be blank", "is too short (minimum is 3 characters)"]
```

### `errors.where` 및 오류 객체

가끔은 메시지 외에도 각 오류에 대한 자세한 정보가 필요할 수 있습니다. 각 오류는 `ActiveModel::Error` 객체로 캡슐화되며, [`where`][] 메서드는 가장 일반적인 액세스 방법입니다.

`where`는 다양한 조건으로 필터링된 오류 객체의 배열을 반환합니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

`errors.where(:attr)`와 같이 첫 번째 매개변수로 `attribute`를 전달하여 `attribute`만 필터링할 수 있습니다. 두 번째 매개변수는 `errors.where(:attr, :type)`를 호출하여 원하는 `type`의 오류를 필터링하는 데 사용됩니다.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name)
=> [ ... ] # :name 속성에 대한 모든 오류

irb> person.errors.where(:name, :too_short)
=> [ ... ] # :name 속성에 대한 :too_short 오류
```

마지막으로, 주어진 유형의 오류 객체에 존재할 수 있는 모든 `options`로 필터링할 수 있습니다.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name, :too_short, minimum: 3)
=> [ ... ] # 이름이 너무 짧고 최소 길이가 2인 모든 이름 오류
```

이러한 오류 객체에서 다양한 정보를 읽을 수 있습니다.

```irb
irb> error = person.errors.where(:name).last

irb> error.attribute
=> :name
irb> error.type
=> :too_short
irb> error.options[:count]
=> 3
```

오류 메시지를 생성할 수도 있습니다.

```irb
irb> error.message
=> "is too short (minimum is 3 characters)"
irb> error.full_message
=> "Name is too short (minimum is 3 characters)"
```

[`full_message`][] 메서드는 속성 이름 앞에 대문자가 붙은 사용자 친화적인 메시지를 생성합니다. (`full_message`이 사용하는 형식을 사용자 정의하려면 [I18n 가이드](i18n.html#active-model-methods)를 참조하십시오.)


### `errors.add`

[`add`][] 메서드는 `attribute`, 오류 `type` 및 추가 옵션 해시를 사용하여 오류 객체를 생성합니다. 이는 자체 유효성 검사기를 작성할 때 매우 구체적인 오류 상황을 정의할 수 있으므로 유용합니다.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_plain, message: "is not cool enough"
  end
end
```
```irb
irb> person = Person.create
irb> person.errors.where(:name).first.type
=> :too_plain
irb> person.errors.where(:name).first.full_message
=> "이름이 충분히 멋지지 않습니다"
```


### `errors[:base]`

특정 속성과 관련이 있는 것이 아닌 객체의 전체 상태와 관련된 오류를 추가하려면 `:base`를 속성으로 사용해야 합니다.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :base, :invalid, message: "이 사람은 유효하지 않습니다. 이유는 ..."
  end
end
```

```irb
irb> person = Person.create
irb> person.errors.where(:base).first.full_message
=> "이 사람은 유효하지 않습니다. 이유는 ..."
```

### `errors.size`

`size` 메서드는 객체의 전체 오류 수를 반환합니다.

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

`clear` 메서드는 `errors` 컬렉션을 명시적으로 지우려는 경우에 사용됩니다. 물론, 유효하지 않은 객체에 `errors.clear`를 호출하는 것은 실제로 유효한 객체로 만들지 않습니다. `errors` 컬렉션이 비어 있지만 `valid?` 또는 이 객체를 데이터베이스에 저장하려는 다른 메서드를 호출하면 다음에 다시 유효성 검사가 실행됩니다. 유효성 검사 중 하나라도 실패하면 `errors` 컬렉션이 다시 채워집니다.

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

뷰에서 유효성 검사 오류 표시하기
-------------------------------------

모델을 생성하고 유효성 검사를 추가한 후 웹 폼을 통해 해당 모델을 생성하는 경우, 유효성 검사가 실패할 때 오류 메시지를 표시하고자 할 것입니다.

각 애플리케이션은 이러한 종류의 작업을 다르게 처리하므로 Rails는 이러한 메시지를 직접 생성하는 뷰 헬퍼를 포함하지 않습니다. 그러나 Rails가 일반적으로 유효성 검사와 상호 작용하기 위해 제공하는 다양한 메서드 덕분에 직접 구현할 수 있습니다. 또한, 스캐폴드를 생성할 때 Rails는 해당 모델에 대한 전체 오류 목록을 표시하는 `_form.html.erb`에 일부 ERB를 넣습니다.

`@article`이라는 인스턴스 변수에 저장된 모델이 있다고 가정하면 다음과 같이 보입니다.

```html+erb
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> prohibited this article from being saved:</h2>

    <ul>
      <% @article.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

또한, 폼을 생성하는 데 Rails 폼 헬퍼를 사용하는 경우, 필드에서 유효성 검사 오류가 발생하면 해당 입력 주위에 추가적인 `<div>`가 생성됩니다.

```html
<div class="field_with_errors">
  <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

그런 다음 이 div를 원하는 대로 스타일링할 수 있습니다. 예를 들어, Rails가 생성하는 기본 스캐폴드는 다음 CSS 규칙을 추가합니다.

```css
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

이는 오류가 있는 필드마다 2픽셀 빨간색 테두리가 생기게 됩니다.
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
