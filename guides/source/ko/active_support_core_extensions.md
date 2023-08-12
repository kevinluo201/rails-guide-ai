**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fdd2e5c41171c61b555549ced4d68a82
Active Support Core Extensions
==============================

Active Support는 Ruby on Rails의 구성 요소로서 Ruby 언어 확장 및 유틸리티를 제공하는 역할을 합니다.

이는 Rails 애플리케이션 및 Ruby on Rails 자체 개발을 위해 언어 수준에서 더 풍부한 기능을 제공합니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* Core Extensions가 무엇인지.
* 모든 확장을 로드하는 방법.
* 원하는 확장만 선택하는 방법.
* Active Support가 제공하는 확장이 무엇인지.

--------------------------------------------------------------------------------

Core Extensions를 로드하는 방법
---------------------------

### 독립형 Active Support

가능한 한 작은 기본 풋프린트를 갖기 위해 Active Support는 기본적으로 최소한의 종속성을 로드합니다. 이는 원하는 확장만 로드할 수 있도록 작은 조각으로 나뉘어져 있습니다. 또한 관련된 확장을 한 번에 로드할 수 있는 편리한 진입점도 제공합니다.

따라서 다음과 같이 간단한 require를 사용한 후:

```ruby
require "active_support"
```

Active Support 프레임워크에서 필요한 확장만 로드됩니다.

#### 정의 선택하기

이 예제는 [`Hash#with_indifferent_access`][Hash#with_indifferent_access]를 로드하는 방법을 보여줍니다. 이 확장은 `Hash`를 [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess]로 변환하여 키를 문자열 또는 심볼로 액세스할 수 있게 합니다.

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

각각의 코어 확장으로 정의된 메소드에는 해당 메소드가 정의된 위치를 나타내는 노트가 있습니다. `with_indifferent_access`의 경우 노트는 다음과 같이 읽힙니다:

NOTE: `active_support/core_ext/hash/indifferent_access.rb`에 정의됨.

즉, 다음과 같이 요구할 수 있습니다:

```ruby
require "active_support"
require "active_support/core_ext/hash/indifferent_access"
```

Active Support는 필요한 종속성만 로드하도록 신중하게 검토되었습니다.

#### 그룹화된 Core Extensions 로드하기

다음 단계는 `Hash`에 대한 모든 확장을 로드하는 것입니다. 일반적인 원칙으로, `SomeClass`에 대한 확장은 `active_support/core_ext/some_class`를 로드함으로써 한 번에 사용할 수 있습니다.

따라서 `Hash`에 대한 모든 확장(포함하여 `with_indifferent_access`)을 로드하려면 다음과 같이 합니다:

```ruby
require "active_support"
require "active_support/core_ext/hash"
```

#### 모든 Core Extensions 로드하기

모든 코어 확장을 로드하려면 다음 파일을 사용할 수 있습니다:

```ruby
require "active_support"
require "active_support/core_ext"
```

#### 모든 Active Support 로드하기

마지막으로, 모든 Active Support를 사용하려면 다음을 실행하십시오:

```ruby
require "active_support/all"
```

이는 실제로 전체 Active Support를 미리 메모리에 로드하지 않습니다. 일부는 `autoload`를 통해 구성되어 사용될 때만 로드됩니다.

### Ruby on Rails 애플리케이션 내에서의 Active Support

Ruby on Rails 애플리케이션은 [`config.active_support.bare`][]이 true인 경우를 제외하고 모든 Active Support를 로드합니다. 이 경우 애플리케이션은 프레임워크 자체가 필요로 하는 것만 선택하여 로드할 수 있으며, 이전 섹션에서 설명한 대로 원하는 정밀도 수준에서 선택할 수도 있습니다.


모든 객체에 대한 확장
-------------------------

### `blank?` 및 `present?`

다음 값은 Rails 애플리케이션에서 공백으로 간주됩니다:

* `nil` 및 `false`,

* 공백만으로 구성된 문자열 (아래 참고),

* 빈 배열 및 해시, 그리고

* `empty?`에 응답하고 비어있는 다른 객체.

INFO: 문자열에 대한 술어는 유니코드를 인식하는 문자 클래스 `[:space:]`를 사용하므로 예를 들어 U+2029 (단락 구분자)는 공백으로 간주됩니다.

WARNING: 숫자는 언급되지 않습니다. 특히, 0과 0.0은 **공백이 아닙니다**.

예를 들어, `ActionController::HttpAuthentication::Token::ControllerMethods`의 다음 메소드는 토큰이 존재하는지 확인하기 위해 [`blank?`][Object#blank?]를 사용합니다:

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

[`present?`][Object#present?] 메소드는 `!blank?`와 동일합니다. 다음 예제는 `ActionDispatch::Http::Cache::Response`에서 가져온 것입니다:

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  # ...
end
```

NOTE: `active_support/core_ext/object/blank.rb`에 정의됨.


### `presence`

[`presence`][Object#presence] 메소드는 수신자가 `present?`인 경우 수신자 자체를 반환하고, 그렇지 않은 경우 `nil`을 반환합니다. 다음과 같은 관용구에 유용합니다:
```ruby
host = config[:host].presence || 'localhost'
```

주의: `active_support/core_ext/object/blank.rb`에서 정의됨.


### `duplicable?`

Ruby 2.5부터 대부분의 객체는 `dup` 또는 `clone`을 통해 복제될 수 있습니다:

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (Method에 대한 allocator가 정의되지 않음)
```

Active Support는 이에 대한 쿼리를 위해 [`duplicable?`][Object#duplicable?]을 제공합니다:

```ruby
"foo".duplicable?           # => true
"".duplicable?              # => true
Rational(1).duplicable?     # => true
Complex(1).duplicable?      # => true
1.method(:+).duplicable?    # => false
```

경고: 모든 클래스는 `dup` 및 `clone`을 제거하거나 예외를 발생시켜 복제를 허용하지 않을 수 있습니다. 따라서 주어진 임의의 객체가 복제 가능한지 여부를 알 수 있는 것은 `rescue`뿐입니다. `duplicable?`은 위의 하드코딩된 목록에 의존하지만 `rescue`보다 훨씬 빠릅니다. 사용 사례에 하드코딩된 목록이 충분하다고 알고 있다면 사용하십시오.

주의: `active_support/core_ext/object/duplicable.rb`에서 정의됨.


### `deep_dup`

[`deep_dup`][Object#deep_dup] 메서드는 주어진 객체의 깊은 복사본을 반환합니다. 일반적으로 다른 객체를 포함하는 객체를 `dup`하는 경우, Ruby는 그들을 `dup`하지 않으므로 객체의 얕은 복사본을 생성합니다. 예를 들어 문자열이 포함된 배열이 있다면 다음과 같이 보일 것입니다:

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# 객체가 복제되었으므로 요소는 복제본에만 추가되었습니다.
array     # => ['string']
duplicate # => ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# 첫 번째 요소는 복제되지 않았으므로 두 배열 모두에서 변경됩니다.
array     # => ['foo']
duplicate # => ['foo', 'another-string']
```

보시다시피 `Array` 인스턴스를 복제한 후에는 다른 객체를 얻었으므로 복제본을 수정할 수 있고 원래 객체는 변경되지 않습니다. 그러나 배열의 요소에 대해서는 그렇지 않습니다. `dup`는 깊은 복사를 수행하지 않으므로 배열 내부의 문자열은 여전히 동일한 객체입니다.

객체의 깊은 복사본이 필요한 경우 `deep_dup`을 사용해야 합니다. 다음은 예입니다:

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     # => ['string']
duplicate # => ['foo']
```

객체가 복제할 수 없는 경우 `deep_dup`은 그냥 해당 객체를 반환합니다:

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

주의: `active_support/core_ext/object/deep_dup.rb`에서 정의됨.


### `try`

객체가 `nil`이 아닌 경우에만 해당 객체에서 메서드를 호출하려면 조건문을 사용하여 달성할 수 있지만, 이는 불필요한 코드를 추가하는 것입니다. 대안은 [`try`][Object#try]를 사용하는 것입니다. `try`는 `nil`에게 보내지면 `nil`을 반환하는 `Object#public_send`와 유사합니다.

다음은 예입니다:

```ruby
# try를 사용하지 않은 경우
unless @number.nil?
  @number.next
end

# try를 사용한 경우
@number.try(:next)
```

다른 예로 `ActiveRecord::ConnectionAdapters::AbstractAdapter`의 다음 코드에서 `@logger`가 `nil`일 수 있습니다. 코드가 `try`를 사용하고 불필요한 확인을 피합니다.

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try`는 인수 없이 블록을 사용하여 호출할 수도 있으며, 이 경우 객체가 `nil`이 아닌 경우에만 실행됩니다:

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

`try`는 메서드가 없는 오류를 무시하고 `nil`을 반환합니다. 철자 오류에 대비하려면 [`try!`][Object#try!]를 사용하십시오:

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

주의: `active_support/core_ext/object/try.rb`에서 정의됨.


### `class_eval(*args, &block)`

[`class_eval`][Kernel#class_eval]을 사용하여 모든 객체의 싱글톤 클래스의 컨텍스트에서 코드를 평가할 수 있습니다:

```ruby
class Proc
  def bind(object)
    block, time = self, Time.current
    object.class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end
```

주의: `active_support/core_ext/kernel/singleton_class.rb`에서 정의됨.


### `acts_like?(duck)`

[`acts_like?`][Object#acts_like?] 메서드는 간단한 규칙에 따라 어떤 클래스가 다른 클래스처럼 동작하는지 확인하는 방법을 제공합니다: `String`과 동일한 인터페이스를 제공하는 클래스는 같은 방식으로 동작합니다.
```ruby
def acts_like_string?
end
```

이것은 단지 표시자이며, 그 몸체나 반환 값은 관련이 없습니다. 그런 다음 클라이언트 코드는 다음과 같이 덕 타입 안전성을 쿼리 할 수 있습니다.

```ruby
some_klass.acts_like?(:string)
```

Rails에는 `Date` 또는 `Time`처럼 작동하고이 계약을 따르는 클래스가 있습니다.

참고 : `active_support/core_ext/object/acts_like.rb`에 정의되어 있습니다.


### `to_param`

Rails의 모든 객체는 쿼리 문자열이나 URL 조각으로 나타내는 무언가를 반환하는 메소드 [`to_param`][Object#to_param]에 응답합니다.

기본적으로 `to_param`은 단순히 `to_s`를 호출합니다.

```ruby
7.to_param # => "7"
```

`to_param`의 반환 값은 **이스케이프되지 않아야**합니다.

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

Rails의 여러 클래스에서이 메소드를 덮어 씁니다.

예를 들어 `nil`, `true`, `false`는 자신을 반환합니다. [`Array#to_param`][Array#to_param]은 요소에 `to_param`을 호출하고 결과를 "/"로 결합합니다.

```ruby
[0, true, String].to_param # => "0/true/String"
```

특히 Rails 라우팅 시스템은 `:id` 플레이스 홀더의 값을 얻기 위해 모델에 `to_param`을 호출합니다. `ActiveRecord::Base#to_param`은 모델의 `id`를 반환하지만 모델에서 해당 메소드를 재정의 할 수 있습니다. 예를 들어 다음과 같이 정의된 경우

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

우리는 다음과 같이 얻습니다.

```ruby
user_path(@user) # => "/users/357-john-smith"
```

경고. 컨트롤러는 `to_param`의 재정의를 인식해야합니다. 왜냐하면 "357-john-smith"와 같은 요청이 들어오면 `params[:id]`의 값입니다.

참고 : `active_support/core_ext/object/to_param.rb`에 정의되어 있습니다.


### `to_query`

[`to_query`][Object#to_query] 메소드는 주어진 `key`를 `to_param`의 반환 값과 연결하는 쿼리 문자열을 구성합니다. 예를 들어 다음과 같은 `to_param` 정의가있는 경우 :

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

우리는 다음과 같이 얻습니다.

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

이 메소드는 필요한 경우 키와 값 모두에 대해 이스케이프합니다.

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

따라서 출력은 쿼리 문자열에서 사용할 준비가되어 있습니다.

배열은 각 요소에 대해 `key[]`로 `to_query`를 적용한 결과를 반환하고 결과를 "&"로 결합합니다.

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

해시도 `to_query`에 응답하지만 다른 시그니처로 응답합니다. 인수가 전달되지 않으면 호출은 값에 대해 `to_query(key)`를 호출하여 키 / 값 할당의 정렬 된 시리즈를 생성합니다. 그런 다음 결과를 "&"로 결합합니다.

```ruby
{ c: 3, b: 2, a: 1 }.to_query # => "a=1&b=2&c=3"
```

메소드 [`Hash#to_query`][Hash#to_query]는 키에 대한 선택적 이름 공간을 허용합니다.

```ruby
{ id: 89, name: "John Smith" }.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

참고 : `active_support/core_ext/object/to_query.rb`에 정의되어 있습니다.


### `with_options`

[`with_options`][Object#with_options] 메소드는 일련의 메소드 호출에서 공통 옵션을 추출하는 방법을 제공합니다.

기본 옵션 해시가 주어지면 `with_options`는 블록에 대한 프록시 객체를 생성합니다. 블록 내에서 프록시에 대해 호출 된 메소드는 옵션을 병합하여 수신자로 전달됩니다. 예를 들어 다음과 같은 중복을 제거 할 수 있습니다.

```ruby
class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

다음과 같이:

```ruby
class Account < ApplicationRecord
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end
```

이 관용구는 독자에게 _그룹화_를 전달 할 수도 있습니다. 예를 들어 사용자에 따라 언어가 다른 뉴스 레터를 보내려면 메일러의 어딘가에서 다음과 같이 로케일에 따라 그룹화 된 비트를 사용할 수 있습니다.

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

TIP : `with_options`는 호출을 수신자로 전달하므로 중첩 될 수 있습니다. 각 중첩 수준은 자체의 기본값을 추가하여 상속 된 기본값을 병합합니다.

참고 : `active_support/core_ext/object/with_options.rb`에 정의되어 있습니다.


### JSON 지원

Active Support는 일반적으로 루비 객체에 대해 `json` 젬이 제공하는 것보다 더 나은 `to_json` 구현을 제공합니다. 이는 `Hash` 및 `Process::Status`와 같은 일부 클래스가 적절한 JSON 표현을 제공하기 위해 특별한 처리가 필요하기 때문입니다.
참고: `active_support/core_ext/object/json.rb`에 정의되어 있습니다.

### 인스턴스 변수

Active Support는 인스턴스 변수에 쉽게 액세스하기 위한 여러 가지 메소드를 제공합니다.

#### `instance_values`

[`instance_values`][Object#instance_values] 메소드는 "@" 없이 인스턴스 변수 이름을 해당 값과 매핑하는 해시를 반환합니다. 키는 문자열입니다:

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

참고: `active_support/core_ext/object/instance_variables.rb`에 정의되어 있습니다.


#### `instance_variable_names`

[`instance_variable_names`][Object#instance_variable_names] 메소드는 배열을 반환합니다. 각 이름은 "@" 기호를 포함합니다.

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

참고: `active_support/core_ext/object/instance_variables.rb`에 정의되어 있습니다.


### 경고 및 예외 억제

[`silence_warnings`][Kernel#silence_warnings] 및 [`enable_warnings`][Kernel#enable_warnings] 메소드는 블록의 기간 동안 `$VERBOSE`의 값을 변경하고, 그 후에 다시 원래 값으로 재설정합니다:

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

[`suppress`][Kernel#suppress] 메소드를 사용하여 예외를 억제할 수도 있습니다. 이 메소드는 임의의 예외 클래스를 여러 개 받습니다. 블록 실행 중 예외가 발생하고 인수 중 하나의 `kind_of?`인 경우, `suppress`는 예외를 캡처하고 조용히 반환합니다. 그렇지 않으면 예외는 캡처되지 않습니다:

```ruby
# 사용자가 잠겨 있으면 증가는 손실되지만 큰 문제는 없습니다.
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

참고: `active_support/core_ext/kernel/reporting.rb`에 정의되어 있습니다.


### `in?`

[`in?`][Object#in?] 예측자는 객체가 다른 객체에 포함되어 있는지 테스트합니다. 전달된 인수가 `include?`에 응답하지 않으면 `ArgumentError` 예외가 발생합니다.

`in?`의 예:

```ruby
1.in?([1, 2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

참고: `active_support/core_ext/object/inclusion.rb`에 정의되어 있습니다.


`Module`의 확장
----------------------

### 속성

#### `alias_attribute`

모델 속성은 리더, 라이터 및 프리디케이트를 가지고 있습니다. [`alias_attribute`][Module#alias_attribute]를 사용하여 세 가지 메소드가 모두 정의된 모델 속성의 별칭을 지정할 수 있습니다. 다른 별칭 메소드와 마찬가지로, 새 이름은 첫 번째 인수이고 이전 이름은 두 번째 인수입니다 (하나의 기억 기호는 할당을 수행하는 경우와 동일한 순서로 들어간다는 것입니다):

```ruby
class User < ApplicationRecord
  # 이메일 열을 "login"으로 참조할 수 있습니다.
  # 인증 코드에 의미가 있을 수 있습니다.
  alias_attribute :login, :email
end
```

참고: `active_support/core_ext/module/aliasing.rb`에 정의되어 있습니다.


#### 내부 속성

서브클래스화될 클래스에서 속성을 정의할 때 이름 충돌은 위험합니다. 이는 라이브러리에 대해서 매우 중요합니다.

Active Support는 [`attr_internal_reader`][Module#attr_internal_reader], [`attr_internal_writer`][Module#attr_internal_writer], 및 [`attr_internal_accessor`][Module#attr_internal_accessor] 매크로를 정의합니다. 이들은 내장된 Ruby `attr_*`와 동일하게 동작하지만 충돌 가능성이 적은 방식으로 인스턴스 변수의 이름을 지정합니다.

매크로 [`attr_internal`][Module#attr_internal]은 `attr_internal_accessor`의 동의어입니다:

```ruby
# 라이브러리
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# 클라이언트 코드
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

이전 예에서 `:log_level`이 라이브러리의 공개 인터페이스에 속하지 않고 개발에만 사용되는 경우가 될 수 있습니다. 잠재적인 충돌을 모르는 클라이언트 코드는 서브클래스를 정의하고 자체 `:log_level`을 정의합니다. `attr_internal` 덕분에 충돌이 발생하지 않습니다.

기본적으로 내부 인스턴스 변수는 선행 밑줄로 이름이 지정됩니다. 위의 예에서는 `@_log_level`입니다. 그것은 `Module.attr_internal_naming_format`을 통해 구성할 수 있습니다. `sprintf`와 유사한 형식 문자열을 전달할 수 있으며, 여기에 이름이 배치될 위치입니다. 기본값은 `"@_%s"`입니다.

Rails는 몇 가지 위치에서 내부 속성을 사용합니다. 예를 들어 뷰에 대해 사용됩니다:

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

참고: `active_support/core_ext/module/attr_internal.rb`에 정의되어 있습니다.


#### 모듈 속성

[`mattr_reader`][Module#mattr_reader], [`mattr_writer`][Module#mattr_writer], 및 [`mattr_accessor`][Module#mattr_accessor] 매크로는 클래스에 대해 정의된 `cattr_*` 매크로와 동일합니다. 사실, `cattr_*` 매크로는 `mattr_*` 매크로의 별칭입니다. [클래스 속성](#class-attributes)을 참조하세요.
예를 들어, Active Storage의 로거 API는 `mattr_accessor`를 사용하여 생성됩니다:

```ruby
module ActiveStorage
  mattr_accessor :logger
end
```

참고: `active_support/core_ext/module/attribute_accessors.rb`에서 정의됨.


### 부모

#### `module_parent`

중첩된 이름이 있는 모듈의 [`module_parent`][Module#module_parent] 메서드는 해당 상수를 포함하는 모듈을 반환합니다:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent # => X::Y
M.module_parent       # => X::Y
```

모듈이 익명이거나 최상위에 속하는 경우, `module_parent`는 `Object`를 반환합니다.

경고: 이 경우 `module_parent_name`은 `nil`을 반환한다는 점에 유의하세요.

참고: `active_support/core_ext/module/introspection.rb`에서 정의됨.


#### `module_parent_name`

중첩된 이름이 있는 모듈의 [`module_parent_name`][Module#module_parent_name] 메서드는 해당 상수를 포함하는 모듈의 완전한 이름을 반환합니다:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent_name # => "X::Y"
M.module_parent_name       # => "X::Y"
```

최상위 또는 익명 모듈의 경우 `module_parent_name`은 `nil`을 반환합니다.

경고: 이 경우 `module_parent`는 `Object`를 반환한다는 점에 유의하세요.

참고: `active_support/core_ext/module/introspection.rb`에서 정의됨.


#### `module_parents`

[`module_parents`][Module#module_parents] 메서드는 수신자에서 `module_parent`를 호출하고 `Object`에 도달할 때까지 상위로 이동합니다. 체인은 배열로 반환되며, 아래에서 위로 정렬됩니다:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parents # => [X::Y, X, Object]
M.module_parents       # => [X::Y, X, Object]
```

참고: `active_support/core_ext/module/introspection.rb`에서 정의됨.


### 익명

모듈은 이름이 있을 수도 있고 없을 수도 있습니다:

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

[`anonymous?`][Module#anonymous?] 예측자를 사용하여 모듈에 이름이 있는지 확인할 수 있습니다:

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

도달할 수 없다는 것은 익명이라는 것을 의미하지 않습니다:

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

하지만 익명 모듈은 정의에 따라 도달할 수 없습니다.

참고: `active_support/core_ext/module/anonymous.rb`에서 정의됨.


### 메서드 위임

#### `delegate`

[`delegate`][Module#delegate] 매크로는 메서드를 전달하는 간단한 방법을 제공합니다.

어떤 응용 프로그램에서 사용자는 `User` 모델에 로그인 정보를 가지고 있지만 이름 및 기타 데이터는 별도의 `Profile` 모델에 있습니다:

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

이 구성으로 인해 사용자의 이름은 프로필을 통해 `user.profile.name`으로 얻을 수 있지만, 이러한 속성에 여전히 직접 액세스할 수 있는 것이 편리할 수 있습니다:

```ruby
class User < ApplicationRecord
  has_one :profile

  def name
    profile.name
  end
end
```

이것이 `delegate`가 하는 일입니다:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate :name, to: :profile
end
```

이것은 더 짧고 의도가 더 명확합니다.

대상에서 메서드는 공개되어야 합니다.

`delegate` 매크로는 여러 메서드를 허용합니다:

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

문자열에 보간되는 경우, `:to` 옵션은 메서드가 위임되는 객체로 평가되는 표현식이어야 합니다. 일반적으로 문자열 또는 심볼입니다. 이러한 표현식은 수신자의 컨텍스트에서 평가됩니다:

```ruby
# Rails 상수에 위임
delegate :logger, to: :Rails

# 수신자의 클래스에 위임
delegate :table_name, to: :class
```

경고: `:prefix` 옵션이 `true`인 경우 이는 덜 일반적입니다. 아래를 참조하세요.

기본적으로 위임이 `NoMethodError`를 발생시키고 대상이 `nil`인 경우 예외가 전파됩니다. `:allow_nil` 옵션을 사용하여 대신 `nil`이 반환되도록 할 수 있습니다:

```ruby
delegate :name, to: :profile, allow_nil: true
```

`:allow_nil`을 사용하면 사용자에게 프로필이 없는 경우 `user.name` 호출이 `nil`을 반환합니다.

`prefix` 옵션은 생성된 메서드의 이름에 접두사를 추가합니다. 예를 들어 더 나은 이름을 얻기 위해 유용할 수 있습니다:

```ruby
delegate :street, to: :address, prefix: true
```

이전 예제는 `street` 대신 `address_street`를 생성합니다.
경고: 이 경우 생성된 메서드의 이름은 대상 객체와 대상 메서드 이름으로 구성되므로 `:to` 옵션은 메서드 이름이어야 합니다.

사용자 정의 접두사도 구성할 수 있습니다:

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

이전 예제에서 매크로는 `size` 대신 `avatar_size`를 생성합니다.

옵션 `:private`는 메서드 범위를 변경합니다:

```ruby
delegate :date_of_birth, to: :profile, private: true
```

위임된 메서드는 기본적으로 공개(public)입니다. 이를 변경하려면 `private: true`를 전달하십시오.

참고: `active_support/core_ext/module/delegation.rb`에 정의됨


#### `delegate_missing_to`

`User` 객체에서 누락된 모든 것을 `Profile` 객체로 위임하고 싶다고 상상해보십시오.
[`delegate_missing_to`][Module#delegate_missing_to] 매크로를 사용하면 이를 쉽게 구현할 수 있습니다.

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate_missing_to :profile
end
```

대상은 객체 내에서 호출 가능한 모든 것이 될 수 있습니다. 예를 들어 인스턴스 변수, 메서드, 상수 등입니다. 대상의 공개 메서드만 위임됩니다.

참고: `active_support/core_ext/module/delegation.rb`에 정의됨.


### 메서드 재정의

`define_method`을 사용하여 메서드를 정의해야 하지만 해당 이름의 메서드가 이미 존재하는지 알 수 없는 경우가 있습니다. 활성화된 경우 경고가 발생합니다. 큰 문제는 아니지만 깔끔하지 않습니다.

메서드 [`redefine_method`][Module#redefine_method]는 필요한 경우 기존 메서드를 제거하여 이러한 잠재적인 경고를 방지합니다.

또한 [`silence_redefinition_of_method`][Module#silence_redefinition_of_method]을 사용하여
대체 메서드를 직접 정의해야 하는 경우(예: `delegate`를 사용하는 경우)에도 사용할 수 있습니다.

참고: `active_support/core_ext/module/redefine_method.rb`에 정의됨.


`Class`에 대한 확장
---------------------

### 클래스 속성

#### `class_attribute`

메서드 [`class_attribute`][Class#class_attribute]는 계층 구조의 모든 수준에서 재정의할 수 있는 상속 가능한 클래스 속성을 하나 이상 선언합니다.

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

예를 들어 `ActionMailer::Base`에서는 다음과 같이 정의됩니다:

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

이들은 인스턴스 수준에서도 액세스하고 재정의할 수 있습니다.

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1, A에서 가져옴
a2.x # => 2, a2에서 재정의됨
```

작성자 인스턴스 메서드의 생성은 옵션 `:instance_writer`를 `false`로 설정하여 방지할 수 있습니다.

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false, default: "my"
  end
end
```

모델은 이 옵션을 속성 설정에 대한 대량 할당을 방지하는 방법으로 유용하게 사용할 수 있습니다.

옵션 `:instance_reader`를 `false`로 설정하여 리더 인스턴스 메서드의 생성을 방지할 수도 있습니다.

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

편의를 위해 `class_attribute`은 인스턴스 리더가 반환하는 것의 부정을 두 번 한 인스턴스 예측자도 정의합니다. 위의 예에서는 `x?`라고 불릴 것입니다.

`instance_reader`가 `false`인 경우 인스턴스 예측자는 리더 메서드와 마찬가지로 `NoMethodError`를 반환합니다.

인스턴스 예측자를 사용하지 않으려면 `instance_predicate: false`를 전달하면 정의되지 않습니다.

참고: `active_support/core_ext/class/attribute.rb`에 정의됨.


#### `cattr_reader`, `cattr_writer`, 및 `cattr_accessor`

매크로 [`cattr_reader`][Module#cattr_reader], [`cattr_writer`][Module#cattr_writer], 및 [`cattr_accessor`][Module#cattr_accessor]는 클래스에 대한 `attr_*`와 유사하지만 클래스에 대한 것입니다. 이미 존재하지 않는 경우 클래스 변수를 `nil`로 초기화하고 해당 클래스 메서드를 생성합니다.

```ruby
class MysqlAdapter < AbstractAdapter
  # @@emulate_booleans에 액세스하기 위한 클래스 메서드를 생성합니다.
  cattr_accessor :emulate_booleans
end
```

또한 `cattr_*`에 기본값으로 속성을 설정하기 위해 블록을 전달할 수도 있습니다.

```ruby
class MysqlAdapter < AbstractAdapter
  # 기본값이 true인 @@emulate_booleans에 액세스하기 위한 클래스 메서드를 생성합니다.
  cattr_accessor :emulate_booleans, default: true
end
```
편의를 위해 인스턴스 메소드도 생성됩니다. 이들은 클래스 속성에 대한 프록시 역할을 합니다. 따라서 인스턴스는 클래스 속성을 변경할 수 있지만 `class_attribute`와 같이 재정의할 수는 없습니다(위에서 설명한 대로). 예를 들어 다음과 같이 주어진 경우

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

우리는 뷰에서 `field_error_proc`에 접근할 수 있습니다.

리더 인스턴스 메소드의 생성은 `:instance_reader`를 `false`로 설정하여 방지할 수 있으며, 쓰기 인스턴스 메소드의 생성은 `:instance_writer`를 `false`로 설정하여 방지할 수 있습니다. 두 메소드의 생성을 방지하려면 `:instance_accessor`를 `false`로 설정하면 됩니다. 모든 경우에 값은 정확히 `false`이어야 하며 다른 false 값은 허용되지 않습니다.

```ruby
module A
  class B
    # first_name 인스턴스 리더가 생성되지 않습니다.
    cattr_accessor :first_name, instance_reader: false
    # last_name= 인스턴스 라이터가 생성되지 않습니다.
    cattr_accessor :last_name, instance_writer: false
    # surname 인스턴스 리더나 surname= 라이터가 생성되지 않습니다.
    cattr_accessor :surname, instance_accessor: false
  end
end
```

모델은 `:instance_accessor`를 `false`로 설정하여 속성을 설정하는 대량 할당을 방지하는 방법으로 유용할 수 있습니다.

참고: `active_support/core_ext/module/attribute_accessors.rb`에서 정의됩니다.


### 하위 클래스와 자손

#### `subclasses`

[`subclasses`][Class#subclasses] 메소드는 수신자의 하위 클래스를 반환합니다:

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

이러한 클래스가 반환되는 순서는 지정되지 않습니다.

참고: `active_support/core_ext/class/subclasses.rb`에서 정의됩니다.


#### `descendants`

[`descendants`][Class#descendants] 메소드는 수신자보다 `<`인 모든 클래스를 반환합니다:

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

이러한 클래스가 반환되는 순서는 지정되지 않습니다.

참고: `active_support/core_ext/class/subclasses.rb`에서 정의됩니다.


`String`에 대한 확장
----------------------

### 출력 안전성

#### 동기

HTML 템플릿에 데이터를 삽입하는 것은 추가적인 주의가 필요합니다. 예를 들어, `@review.title`을 그대로 HTML 페이지에 보간할 수는 없습니다. 첫째로, 리뷰 제목이 "Flanagan & Matz rules!"인 경우 출력은 "&amp;amp;"로 이스케이프되지 않아 올바르게 형성되지 않을 것입니다. 더욱이, 응용 프로그램에 따라 사용자가 손으로 만든 리뷰 제목을 설정하여 악성 HTML을 삽입할 수 있는 보안 취약점이 될 수 있습니다. 위험에 대한 자세한 정보는 [보안 가이드](security.html#cross-site-scripting-xss)의 크로스 사이트 스크립팅에 대한 섹션을 참조하십시오.

#### 안전한 문자열

Active Support에는 _(html) 안전한_ 문자열 개념이 있습니다. 안전한 문자열은 HTML에 그대로 삽입될 수 있음을 나타냅니다. 이는 이스케이프되었는지 여부와 관계없이 신뢰할 수 있습니다.

문자열은 기본적으로 _안전하지 않습니다_:

```ruby
"".html_safe? # => false
```

[`html_safe`][String#html_safe] 메소드를 사용하여 주어진 문자열에서 안전한 문자열을 얻을 수 있습니다:

```ruby
s = "".html_safe
s.html_safe? # => true
```

`html_safe`는 어떠한 이스케이핑도 수행하지 않으며, 단지 단언입니다:

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

특정 문자열에 `html_safe`를 호출하는 것이 안전한지 확인하는 것은 사용자의 책임입니다.

안전한 문자열에 `concat`/`<<`로 인플레이스로 또는 `+`로 추가하면 결과는 안전한 문자열입니다. 안전하지 않은 인수는 이스케이프됩니다:

```ruby
"".html_safe + "<" # => "&lt;"
```

안전한 인수는 직접 추가됩니다:

```ruby
"".html_safe + "<".html_safe # => "<"
```

이러한 메소드는 일반적인 뷰에서 사용해서는 안 됩니다. 안전하지 않은 값은 자동으로 이스케이프됩니다:

```erb
<%= @review.title %> <%# 필요한 경우 이스케이프됩니다 %>
```
무언가를 그대로 삽입하려면 `html_safe`를 호출하는 대신 [`raw`][] 헬퍼를 사용하십시오:

```erb
<%= raw @cms.current_template %> <%# @cms.current_template을 그대로 삽입합니다. %>
```

또는 동등하게 `<%==`를 사용하십시오:

```erb
<%== @cms.current_template %> <%# @cms.current_template을 그대로 삽입합니다. %>
```

`raw` 헬퍼는 `html_safe`를 호출합니다:

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

참고: `active_support/core_ext/string/output_safety.rb`에 정의되어 있습니다.


#### 변환

일반적으로 문자열을 변경할 수 있는 모든 메소드는 안전하지 않은 문자열을 반환합니다. 위에서 설명한 것처럼 문자열을 연결하는 경우를 제외하고는요. 이러한 메소드에는 `downcase`, `gsub`, `strip`, `chomp`, `underscore` 등이 있습니다.

`gsub!`와 같은 제자리 변환의 경우 수신자 자체가 안전하지 않은 상태가 됩니다.

INFO: 안전성 비트는 실제로 무엇인가를 변경했는지 여부에 상관없이 항상 손실됩니다.

#### 변환 및 강제 변환

안전한 문자열에 대해 `to_s`를 호출하면 안전한 문자열이 반환되지만, `to_str`로 강제 변환하면 안전하지 않은 문자열이 반환됩니다.

#### 복사

안전한 문자열에 대해 `dup` 또는 `clone`을 호출하면 안전한 문자열이 생성됩니다.

### `remove`

[`remove`][String#remove] 메소드는 패턴의 모든 발생을 제거합니다:

```ruby
"Hello World".remove(/Hello /) # => "World"
```

파괴적인 버전인 `String#remove!`도 있습니다.

참고: `active_support/core_ext/string/filters.rb`에 정의되어 있습니다.


### `squish`

[`squish`][String#squish] 메소드는 선행 및 후행 공백을 제거하고 공백의 연속을 하나의 공백으로 대체합니다:

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

파괴적인 버전인 `String#squish!`도 있습니다.

이 메소드는 ASCII 및 유니코드 공백 모두를 처리합니다.

참고: `active_support/core_ext/string/filters.rb`에 정의되어 있습니다.


### `truncate`

[`truncate`][String#truncate] 메소드는 주어진 `length` 이후에 수신자의 복사본을 반환합니다:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

생략 부분은 `:omission` 옵션으로 사용자 정의할 수 있습니다:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

특히 생략 문자열의 길이를 고려하여 문자열을 자릅니다.

자연스러운 중단점에서 문자열을 자르려면 `:separator`를 전달하십시오:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

옵션 `:separator`는 정규식일 수 있습니다:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

위의 예에서 "dear"가 먼저 잘리지만 `:separator`가 이를 방지합니다.

참고: `active_support/core_ext/string/filters.rb`에 정의되어 있습니다.


### `truncate_bytes`

[`truncate_bytes`][String#truncate_bytes] 메소드는 최대 `bytesize` 바이트로 자른 수신자의 복사본을 반환합니다:

```ruby
"👍👍👍👍".truncate_bytes(15)
# => "👍👍👍…"
```

생략 부분은 `:omission` 옵션으로 사용자 정의할 수 있습니다:

```ruby
"👍👍👍👍".truncate_bytes(15, omission: "🖖")
# => "👍👍🖖"
```

참고: `active_support/core_ext/string/filters.rb`에 정의되어 있습니다.


### `truncate_words`

[`truncate_words`][String#truncate_words] 메소드는 주어진 단어 수 이후에 수신자의 복사본을 반환합니다:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

생략 부분은 `:omission` 옵션으로 사용자 정의할 수 있습니다:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

자연스러운 중단점에서 문자열을 자르려면 `:separator`를 전달하십시오:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! I shall be late..."
```

옵션 `:separator`는 정규식일 수 있습니다:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

참고: `active_support/core_ext/string/filters.rb`에 정의되어 있습니다.


### `inquiry`

[`inquiry`][String#inquiry] 메소드는 문자열을 `StringInquirer` 객체로 변환하여 동등성 검사를 더 예쁘게 만듭니다.

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

참고: `active_support/core_ext/string/inquiry.rb`에 정의되어 있습니다.


### `starts_with?` 및 `ends_with?`

Active Support는 `String#start_with?` 및 `String#end_with?`의 3인칭 별칭을 정의합니다:

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```
참고: `active_support/core_ext/string/starts_ends_with.rb`에 정의되어 있습니다.

### `strip_heredoc`

[`strip_heredoc`][String#strip_heredoc] 메서드는 heredoc에서 들여쓰기를 제거합니다.

예를 들어,

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    This command does such and such.

    Supported options are:
      -h         This message
      ...
  USAGE
end
```

사용자는 사용법 메시지가 왼쪽 여백에 맞춰져 있는 것을 볼 수 있습니다.

기술적으로, 이 메서드는 문자열 전체에서 가장 들여쓰기가 적은 줄을 찾아 해당하는 양의 선행 공백을 제거합니다.

참고: `active_support/core_ext/string/strip.rb`에 정의되어 있습니다.


### `indent`

[`indent`][String#indent] 메서드는 수신자의 줄을 들여쓰기합니다:

```ruby
<<EOS.indent(2)
def some_method
  some_code
end
EOS
# =>
  def some_method
    some_code
  end
```

두 번째 인수인 `indent_string`은 어떤 들여쓰기 문자열을 사용할지 지정합니다. 기본값은 `nil`이며, 이는 메서드가 첫 번째 들여쓰기된 줄을 살펴보고 없는 경우 공백으로 대체합니다.

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

`indent_string`은 일반적으로 공백이나 탭이지만, 어떤 문자열이든 될 수 있습니다.

세 번째 인수인 `indent_empty_lines`는 빈 줄을 들여쓸지 여부를 나타내는 플래그입니다. 기본값은 false입니다.

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

[`indent!`][String#indent!] 메서드는 들여쓰기를 직접 수행합니다.

참고: `active_support/core_ext/string/indent.rb`에 정의되어 있습니다.


### 접근

#### `at(position)`

[`at`][String#at] 메서드는 문자열의 `position` 위치에 있는 문자를 반환합니다:

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

참고: `active_support/core_ext/string/access.rb`에 정의되어 있습니다.


#### `from(position)`

[`from`][String#from] 메서드는 문자열의 `position` 위치에서 시작하는 부분 문자열을 반환합니다:

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

참고: `active_support/core_ext/string/access.rb`에 정의되어 있습니다.


#### `to(position)`

[`to`][String#to] 메서드는 문자열의 `position` 위치까지의 부분 문자열을 반환합니다:

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

참고: `active_support/core_ext/string/access.rb`에 정의되어 있습니다.


#### `first(limit = 1)`

[`first`][String#first] 메서드는 문자열의 처음 `limit`개의 문자를 포함하는 부분 문자열을 반환합니다.

`str.first(n)` 호출은 `n` > 0인 경우 `str.to(n-1)`과 동일하며, `n` == 0인 경우 빈 문자열을 반환합니다.

참고: `active_support/core_ext/string/access.rb`에 정의되어 있습니다.


#### `last(limit = 1)`

[`last`][String#last] 메서드는 문자열의 마지막 `limit`개의 문자를 포함하는 부분 문자열을 반환합니다.

`str.last(n)` 호출은 `n` > 0인 경우 `str.from(-n)`과 동일하며, `n` == 0인 경우 빈 문자열을 반환합니다.

참고: `active_support/core_ext/string/access.rb`에 정의되어 있습니다.


### 변형

#### `pluralize`

[`pluralize`][String#pluralize] 메서드는 수신자의 복수형을 반환합니다:

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

위의 예시에서 보듯이, Active Support는 일부 불규칙한 복수형과 셀 수 없는 명사를 알고 있습니다. 내장된 규칙은 `config/initializers/inflections.rb`에서 확장할 수 있습니다. 이 파일은 `rails new` 명령으로 기본적으로 생성되며 주석에 지침이 포함되어 있습니다.

`pluralize`는 선택적인 `count` 매개변수도 받을 수 있습니다. `count == 1`인 경우 단수형이 반환됩니다. `count`의 다른 값에 대해서는 복수형이 반환됩니다:

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

Active Record는 이 메서드를 사용하여 모델에 해당하는 기본 테이블 이름을 계산합니다:

```ruby
# active_record/model_schema.rb
def undecorated_table_name(model_name)
  table_name = model_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

참고: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.


#### `singularize`

[`singularize`][String#singularize] 메서드는 `pluralize`의 반대입니다:

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

연관은 이 메서드를 사용하여 해당하는 기본 연관 클래스의 이름을 계산합니다:

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```
참고: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.


#### `camelize`

[`camelize`][String#camelize] 메서드는 수신자를 카멜 케이스로 변환하여 반환합니다:

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

일반적으로 이 메서드는 경로를 루비 클래스나 모듈 이름으로 변환하는 메서드로 생각할 수 있습니다. 슬래시는 네임스페이스를 구분합니다:

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

예를 들어, 액션 팩은 특정 세션 저장소를 제공하는 클래스를 로드하기 위해 이 메서드를 사용합니다:

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize`는 선택적 인수를 받을 수 있으며, `:upper` (기본값) 또는 `:lower`일 수 있습니다. 후자의 경우 첫 글자가 소문자로 변환됩니다:

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

이는 해당 규칙을 따르는 언어에서 메서드 이름을 계산하는 데 유용할 수 있습니다. 예를 들어 JavaScript입니다.

INFO: `camelize`를 `underscore`의 역으로 생각할 수 있지만, 그렇지 않은 경우도 있습니다. 예를 들어, `"SSLError".underscore.camelize`는 `"SslError"`를 반환합니다. 이와 같은 경우를 지원하기 위해 Active Support에서 `config/initializers/inflections.rb`에서 약어를 지정할 수 있습니다:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize`은 [`camelcase`][String#camelcase]에 별칭이 지정되어 있습니다.

참고: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.


#### `underscore`

[`underscore`][String#underscore] 메서드는 카멜 케이스에서 경로로 변환합니다:

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

또한 "::"를 "/"로 변환합니다:

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

그리고 소문자로 시작하는 문자열을 이해합니다:

```ruby
"visualEffect".underscore # => "visual_effect"
```

`underscore`는 인수를 받지 않습니다.

예를 들어, Rails는 컨트롤러 클래스의 소문자 이름을 얻기 위해 `underscore`를 사용합니다:

```ruby
# actionpack/lib/abstract_controller/base.rb
def controller_path
  @controller_path ||= name.delete_suffix("Controller").underscore
end
```

예를 들어, `params[:controller]`에서 이 값을 얻을 수 있습니다.

INFO: `underscore`를 `camelize`의 역으로 생각할 수 있지만, 그렇지 않은 경우도 있습니다. 예를 들어, `"SSLError".underscore.camelize`는 `"SslError"`를 반환합니다.

참고: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.


#### `titleize`

[`titleize`][String#titleize] 메서드는 수신자의 단어를 대문자로 변환합니다:

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize`는 [`titlecase`][String#titlecase]에 별칭이 지정되어 있습니다.

참고: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.


#### `dasherize`

[`dasherize`][String#dasherize] 메서드는 수신자의 밑줄을 대시로 대체합니다:

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

모델의 XML 직렬화기는 이 메서드를 사용하여 노드 이름을 대시로 변환합니다:

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

참고: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.


#### `demodulize`

정규화된 상수 이름이 있는 문자열을 주면, [`demodulize`][String#demodulize] 메서드는 해당 상수 이름, 즉 가장 오른쪽 부분을 반환합니다:

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""
```

예를 들어, Active Record는 카운터 캐시 열의 이름을 계산하기 위해 이 메서드를 사용합니다:

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

참고: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.


#### `deconstantize`

정규화된 상수 참조 표현식이 있는 문자열을 주면, [`deconstantize`][String#deconstantize] 메서드는 가장 오른쪽 세그먼트를 제거하고 일반적으로 상수의 컨테이너 이름을 남깁니다:

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

참고: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.


#### `parameterize`

[`parameterize`][String#parameterize] 메서드는 수신자를 예쁜 URL에서 사용할 수 있는 방식으로 정규화합니다.

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

문자열의 대소문자를 보존하려면 `preserve_case` 인수를 true로 설정하세요. 기본적으로 `preserve_case`는 false로 설정됩니다.

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

사용자 정의 구분자를 사용하려면 `separator` 인수를 재정의하세요.
```ruby
"Employee Salary".downcase_first # => "employee Salary"
"".downcase_first                # => ""
```

NOTE: Defined in `active_support/core_ext/string/inflections.rb`.
```ruby
123.to_fs(:human)                  # => "123"
1234.to_fs(:human)                 # => "1.2 Thousand"
12345.to_fs(:human)                # => "12.3 Thousand"
1234567.to_fs(:human)              # => "1.2 Million"
1234567890.to_fs(:human)           # => "1.2 Billion"
1234567890123.to_fs(:human)        # => "1.2 Trillion"
1234567890123456.to_fs(:human)     # => "1.2 Quadrillion"
1234567890123456789.to_fs(:human)  # => "1.2 Quintillion"
```

NOTE: Defined in `active_support/core_ext/numeric/number_to_human.rb`.
```ruby
123.to_fs(:human)               # => "123"
1234.to_fs(:human)              # => "1.23 천"
12345.to_fs(:human)             # => "12.3 천"
1234567.to_fs(:human)           # => "1.23 백만"
1234567890.to_fs(:human)        # => "1.23 십억"
1234567890123.to_fs(:human)     # => "1.23 조"
1234567890123456.to_fs(:human)  # => "1.23 경"

NOTE: `active_support/core_ext/numeric/conversions.rb`에 정의되어 있습니다.

`Integer`에 대한 확장
-----------------------

### `multiple_of?`

[`multiple_of?`][Integer#multiple_of?] 메서드는 정수가 인수의 배수인지 테스트합니다:

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

NOTE: `active_support/core_ext/integer/multiple.rb`에 정의되어 있습니다.


### `ordinal`

[`ordinal`][Integer#ordinal] 메서드는 수신자 정수에 해당하는 서수 접미사 문자열을 반환합니다:

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

NOTE: `active_support/core_ext/integer/inflections.rb`에 정의되어 있습니다.


### `ordinalize`

[`ordinalize`][Integer#ordinalize] 메서드는 수신자 정수에 해당하는 서수 문자열을 반환합니다. 비교를 위해, `ordinal` 메서드는 **오직** 접미사 문자열만 반환합니다.

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

NOTE: `active_support/core_ext/integer/inflections.rb`에 정의되어 있습니다.


### 시간

다음 메서드들:

* [`months`][Integer#months]
* [`years`][Integer#years]

시간 선언과 계산을 가능하게 합니다. 예를 들어 `4.months + 5.years`와 같이 사용할 수 있습니다. 이들의 반환 값은 Time 객체에 더하거나 빼는 데에도 사용될 수 있습니다.

이러한 메서드들은 [`from_now`][Duration#from_now], [`ago`][Duration#ago] 등과 함께 사용하여 정확한 날짜 계산에 사용할 수 있습니다. 예를 들어:

```ruby
# Time.current.advance(months: 1)과 동일합니다.
1.month.from_now

# Time.current.advance(years: 2)와 동일합니다.
2.years.from_now

# Time.current.advance(months: 4, years: 5)와 동일합니다.
(4.months + 5.years).from_now
```

경고. 다른 기간에 대해서는 `Numeric`의 시간 확장을 참조하십시오.

NOTE: `active_support/core_ext/integer/time.rb`에 정의되어 있습니다.


`BigDecimal`에 대한 확장
--------------------------

### `to_s`

`to_s` 메서드는 기본적으로 "F" 지정자를 제공합니다. 이는 `to_s`를 단순히 호출하면 공학 표기법 대신 부동 소수점 표현이 반환됨을 의미합니다:

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

공학 표기법도 지원됩니다:

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

`Enumerable`에 대한 확장
--------------------------

### `sum`

[`sum`][Enumerable#sum] 메서드는 Enumerable의 요소들을 더합니다:

```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

덧셈은 요소들이 `+`를 지원한다고 가정합니다:

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{ a: 1, b: 2, c: 3 }.sum          # => [:a, 1, :b, 2, :c, 3]
```

빈 컬렉션의 합은 기본적으로 0입니다. 그러나 이는 사용자 정의할 수 있습니다:

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

블록이 주어지면, `sum`은 컬렉션의 요소를 반복하고 반환된 값들을 합산하는 이터레이터가 됩니다:

```ruby
(1..5).sum { |n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

빈 수신자의 합도 이 형태로 사용자 정의할 수 있습니다:

```ruby
[].sum(1) { |n| n**3 } # => 1
```

NOTE: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.


### `index_by`

[`index_by`][Enumerable#index_by] 메서드는 Enumerable의 요소들을 키로 색인화된 해시를 생성합니다.

이는 컬렉션을 반복하고 각 요소를 블록에 전달합니다. 요소는 블록에서 반환된 값으로 키가 됩니다:

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

경고. 키는 일반적으로 고유해야 합니다. 블록이 다른 요소에 대해 동일한 값을 반환하면 해당 키에 대한 컬렉션이 구축되지 않습니다. 마지막 항목이 이길 것입니다.

NOTE: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.


### `index_with`

[`index_with`][Enumerable#index_with] 메서드는 Enumerable의 요소들을 키로 하는 해시를 생성합니다. 값은 전달된 기본값이거나 블록에서 반환됩니다.

```ruby
post = Post.new(title: "hey there", body: "what's up?")

%i( title body ).index_with { |attr_name| post.public_send(attr_name) }
# => { title: "hey there", body: "what's up?" }

WEEKDAYS.index_with(Interval.all_day)
# => { monday: [ 0, 1440 ], … }
```

참고: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.


### `many?`

메소드 [`many?`][Enumerable#many?]은 `collection.size > 1`을 축약한 것입니다:

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

선택적 블록이 주어진 경우, `many?`는 true를 반환하는 요소만을 고려합니다:

```ruby
@see_more = videos.many? { |video| video.category == params[:category] }
```

참고: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.


### `exclude?`

예측자 [`exclude?`][Enumerable#exclude?]는 주어진 객체가 컬렉션에 **속하지 않는지** 테스트합니다. 이는 내장된 `include?`의 부정입니다:

```ruby
to_visit << node if visited.exclude?(node)
```

참고: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.


### `including`

메소드 [`including`][Enumerable#including]는 전달된 요소를 포함하는 새로운 enumerable을 반환합니다:

```ruby
[ 1, 2, 3 ].including(4, 5)                    # => [ 1, 2, 3, 4, 5 ]
["David", "Rafael"].including %w[ Aaron Todd ] # => ["David", "Rafael", "Aaron", "Todd"]
```

참고: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.


### `excluding`

메소드 [`excluding`][Enumerable#excluding]은 지정된 요소가 제거된 enumerable의 사본을 반환합니다:

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
```

`excluding`은 [`without`][Enumerable#without]에 별칭이 지정되어 있습니다.

참고: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.


### `pluck`

메소드 [`pluck`][Enumerable#pluck]는 각 요소에서 주어진 키를 추출합니다:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pluck(:id, :name) # => [[1, "David"], [2, "Rafael"]]
```

참고: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.


### `pick`

메소드 [`pick`][Enumerable#pick]은 첫 번째 요소에서 주어진 키를 추출합니다:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pick(:name) # => "David"
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pick(:id, :name) # => [1, "David"]
```

참고: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.


`Array`에 대한 확장
---------------------

### 접근

Active Support는 배열의 API를 보완하여 특정한 접근 방법을 쉽게 할 수 있도록 합니다. 예를 들어, [`to`][Array#to]는 전달된 인덱스까지의 요소들로 이루어진 하위 배열을 반환합니다:

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

마찬가지로, [`from`][Array#from]은 전달된 인덱스부터 끝까지의 요소들로 이루어진 배열을 반환합니다. 인덱스가 배열의 길이보다 큰 경우, 빈 배열을 반환합니다.

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

메소드 [`including`][Array#including]는 전달된 요소를 포함하는 새로운 배열을 반환합니다:

```ruby
[ 1, 2, 3 ].including(4, 5)          # => [ 1, 2, 3, 4, 5 ]
[ [ 0, 1 ] ].including([ [ 1, 0 ] ]) # => [ [ 0, 1 ], [ 1, 0 ] ]
```

메소드 [`excluding`][Array#excluding]은 지정된 요소가 제외된 배열의 사본을 반환합니다.
이는 성능상의 이유로 `Enumerable#excluding` 대신 `Array#-`를 사용하는 최적화입니다.

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
[ [ 0, 1 ], [ 1, 0 ] ].excluding([ [ 1, 0 ] ])                  # => [ [ 0, 1 ] ]
```

메소드 [`second`][Array#second], [`third`][Array#third], [`fourth`][Array#fourth], [`fifth`][Array#fifth]는 해당하는 요소를 반환하며, [`second_to_last`][Array#second_to_last]와 [`third_to_last`][Array#third_to_last](`first`와 `last`는 내장됨)도 마찬가지입니다. 사회적 지혜와 긍정적인 건설성 덕분에 [`forty_two`][Array#forty_two]도 사용할 수 있습니다.

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

참고: `active_support/core_ext/array/access.rb`에 정의되어 있습니다.


### 추출

메소드 [`extract!`][Array#extract!]는 블록이 true 값을 반환하는 요소를 제거하고 반환합니다.
블록이 주어지지 않은 경우, 대신 Enumerator가 반환됩니다.

```ruby
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
numbers # => [0, 2, 4, 6, 8]
```
참고: `active_support/core_ext/array/extract.rb`에서 정의됨.


### 옵션 추출

메소드 호출의 마지막 인자가 해시일 경우, `&block` 인자를 제외하고 괄호를 생략할 수 있습니다:

```ruby
User.exists?(email: params[:email])
```

이러한 문법적 설탕은 Rails에서 많이 사용되며, 너무 많은 위치 인자가 있는 경우에는 대신에 이름이 지정된 매개변수를 흉내내는 인터페이스를 제공합니다. 특히 옵션에 대해 후행 해시를 사용하는 것은 매우 관용적입니다.

그러나 메소드가 가변 인자를 기대하고 선언에서 `*`를 사용하는 경우, 이러한 옵션 해시는 인자 배열의 항목이 되어 역할을 잃게 됩니다.

이러한 경우에는 [`extract_options!`][Array#extract_options!]를 사용하여 옵션 해시에 특별한 처리를 할 수 있습니다. 이 메소드는 배열의 마지막 항목의 타입을 확인합니다. 만약 해시라면 해당 항목을 꺼내고 반환하고, 그렇지 않으면 빈 해시를 반환합니다.

예를 들어 `caches_action` 컨트롤러 매크로의 정의를 살펴보겠습니다:

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  # ...
end
```

이 메소드는 임의의 수의 액션 이름과 선택적인 옵션 해시를 마지막 인자로 받습니다. `extract_options!`를 호출하여 옵션 해시를 얻고, 간단하고 명시적인 방법으로 `actions`에서 제거합니다.

참고: `active_support/core_ext/array/extract_options.rb`에서 정의됨.


### 변환

#### `to_sentence`

[`to_sentence`][Array#to_sentence] 메소드는 배열을 항목을 열거하는 문장으로 변환한 문자열을 반환합니다:

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

이 메소드는 세 가지 옵션을 받습니다:

* `:two_words_connector`: 길이가 2인 배열에 사용되는 연결자입니다. 기본값은 " and "입니다.
* `:words_connector`: 3개 이상의 요소를 가진 배열의 요소를 연결하는 데 사용되는 연결자입니다. 마지막 두 요소를 제외한 나머지 요소에 대해서만 적용됩니다. 기본값은 ", "입니다.
* `:last_word_connector`: 3개 이상의 요소를 가진 배열의 마지막 항목을 연결하는 데 사용되는 연결자입니다. 기본값은 ", and "입니다.

이 옵션들의 기본값은 로캘에 따라 다를 수 있으며, 그 키는 다음과 같습니다:

| 옵션                     | I18n 키                             |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

참고: `active_support/core_ext/array/conversions.rb`에서 정의됨.


#### `to_fs`

[`to_fs`][Array#to_fs] 메소드는 기본적으로 `to_s`와 같은 역할을 합니다.

그러나 배열에 `id`에 응답하는 항목이 포함되어 있는 경우, 심볼 `:db`를 인자로 전달할 수 있습니다. 이는 일반적으로 Active Record 객체의 컬렉션과 함께 사용됩니다. 반환되는 문자열은 다음과 같습니다:

```ruby
[].to_fs(:db)            # => "null"
[user].to_fs(:db)        # => "8456"
invoice.lines.to_fs(:db) # => "23,567,556,12"
```

위의 예에서 정수는 각각 `id`에 대한 호출에서 가져온 것으로 가정합니다.

참고: `active_support/core_ext/array/conversions.rb`에서 정의됨.


#### `to_xml`

[`to_xml`][Array#to_xml] 메소드는 수신자의 XML 표현을 포함하는 문자열을 반환합니다:

```ruby
Contributor.limit(2).order(:rank).to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors type="array">
#   <contributor>
#     <id type="integer">4356</id>
#     <name>Jeremy Kemper</name>
#     <rank type="integer">1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id type="integer">4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank type="integer">2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

이를 위해 각 항목에 대해 `to_xml`을 보내고 결과를 루트 노드 아래에 수집합니다. 모든 항목은 `to_xml`에 응답해야 하며, 그렇지 않으면 예외가 발생합니다.

기본적으로 루트 요소의 이름은 첫 번째 항목의 클래스 이름의 underscored 및 dasherized 복수형입니다. 나머지 요소들이 해당 유형에 속하고(`is_a?`로 확인) 해시가 아닌 경우에만 적용됩니다. 위의 예에서는 "contributors"입니다.

첫 번째 항목의 유형과 다른 유형의 요소가 있는 경우, 루트 노드는 "objects"가 됩니다.
```ruby
[Contributor.first, Commit.first].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <id type="integer">4583</id>
#     <name>Aaron Batalion</name>
#     <rank type="integer">53</rank>
#     <url-id>aaron-batalion</url-id>
#   </object>
#   <object>
#     <author>Joshua Peek</author>
#     <authored-timestamp type="datetime">2009-09-02T16:44:36Z</authored-timestamp>
#     <branch>origin/master</branch>
#     <committed-timestamp type="datetime">2009-09-02T16:44:36Z</committed-timestamp>
#     <committer>Joshua Peek</committer>
#     <git-show nil="true"></git-show>
#     <id type="integer">190316</id>
#     <imported-from-svn type="boolean">false</imported-from-svn>
#     <message>Kill AMo observing wrap_with_notifications since ARes was only using it</message>
#     <sha1>723a47bfb3708f968821bc969a9a3fc873a3ed58</sha1>
#   </object>
# </objects>
```

만약 수신자가 해시 배열이라면 기본적으로 루트 요소도 "objects"입니다:

```ruby
[{ a: 1, b: 2 }, { c: 3 }].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <b type="integer">2</b>
#     <a type="integer">1</a>
#   </object>
#   <object>
#     <c type="integer">3</c>
#   </object>
# </objects>
```

경고. 컬렉션이 비어있는 경우 기본적으로 루트 요소는 "nil-classes"입니다. 이는 예기치 않은 상황이며, 위의 기여자 목록의 루트 요소가 "contributors"가 아니라 "nil-classes"가 됩니다. 일관된 루트 요소를 보장하기 위해 `:root` 옵션을 사용할 수 있습니다.

자식 노드의 이름은 기본적으로 루트 노드의 단수형 이름입니다. 위의 예에서는 "contributor"와 "object"를 보았습니다. `:children` 옵션을 사용하여 이러한 노드 이름을 설정할 수 있습니다.

기본 XML 빌더는 `Builder::XmlMarkup`의 새로운 인스턴스입니다. `:builder` 옵션을 통해 사용자 정의 빌더를 구성할 수 있습니다. `:dasherize`와 같은 옵션도 사용할 수 있으며, 이는 빌더로 전달됩니다:

```ruby
Contributor.limit(2).order(:rank).to_xml(skip_types: true)
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors>
#   <contributor>
#     <id>4356</id>
#     <name>Jeremy Kemper</name>
#     <rank>1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id>4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank>2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

참고: `active_support/core_ext/array/conversions.rb`에 정의되어 있습니다.


### Wrapping

[`Array.wrap`][Array.wrap] 메소드는 인자가 이미 배열(또는 배열과 유사한)인 경우를 제외하고 인자를 배열로 감싸줍니다.

구체적으로는:

* 인자가 `nil`인 경우 빈 배열이 반환됩니다.
* 그렇지 않은 경우, 인자가 `to_ary`에 응답하는 경우 `to_ary`가 호출되고, `to_ary`의 값이 `nil`이 아닌 경우 반환됩니다.
* 그렇지 않은 경우, 인자를 단일 요소로 갖는 배열이 반환됩니다.

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

이 메소드는 `Kernel#Array`와 비슷한 목적을 가지고 있지만 몇 가지 차이점이 있습니다:

* 인자가 `to_ary`에 응답하는 경우 메소드가 호출됩니다. `Kernel#Array`는 반환된 값이 `nil`인 경우 `to_a`를 시도하지만, `Array.wrap`은 인자를 단일 요소로 갖는 배열을 즉시 반환합니다.
* `to_ary`에서 반환된 값이 `nil`이나 `Array` 객체가 아닌 경우, `Kernel#Array`는 예외를 발생시키지만 `Array.wrap`은 예외를 발생시키지 않고 값을 반환합니다.
* 인자가 `to_ary`에 응답하지 않는 경우 `to_a`를 호출하지 않으며, 인자를 단일 요소로 갖는 배열을 반환합니다.

특히 몇 가지 열거 가능한 객체에 대해 비교해 볼 가치가 있는 마지막 점입니다:

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

또한 스플래트 연산자를 사용하는 관련된 관용구도 있습니다:

```ruby
[*object]
```

참고: `active_support/core_ext/array/wrap.rb`에 정의되어 있습니다.


### Duplicating

[`Array#deep_dup`][Array#deep_dup] 메소드는 `Object#deep_dup` 메소드를 사용하여 자신과 내부의 모든 객체를 재귀적으로 복제합니다. 이는 `Array#map`과 유사하게 작동하며, 각 객체에 `deep_dup` 메소드를 보냅니다.

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

참고: `active_support/core_ext/object/deep_dup.rb`에 정의되어 있습니다.


### Grouping

#### `in_groups_of(number, fill_with = nil)`

[`in_groups_of`][Array#in_groups_of] 메소드는 배열을 일정한 크기의 연속된 그룹으로 나눕니다. 그룹을 포함한 배열을 반환합니다:

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

또는 블록이 전달되면 차례대로 반환합니다:

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

첫 번째 예제는 `in_groups_of`가 요청한 크기를 갖도록 필요한 만큼 `nil` 요소로 마지막 그룹을 채우는 방법을 보여줍니다. 두 번째 선택적 인수를 사용하여 이 패딩 값을 변경할 수 있습니다:

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

또한 `false`를 전달하여 마지막 그룹을 채우지 않도록 메서드에 지시할 수 있습니다:

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

결과적으로 `false`는 패딩 값으로 사용할 수 없습니다.

참고: `active_support/core_ext/array/grouping.rb`에 정의되어 있습니다.


#### `in_groups(number, fill_with = nil)`

메서드 [`in_groups`][Array#in_groups]는 배열을 특정한 수의 그룹으로 분할합니다. 이 메서드는 그룹을 포함하는 배열을 반환합니다:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

또는 블록이 전달되면 차례대로 반환합니다:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) { |group| p group }
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

위의 예제에서 `in_groups`는 요청에 따라 일부 그룹을 필요한 만큼 추가 `nil` 요소로 채웁니다. 그룹은 최대 한 개의 추가 요소를 얻을 수 있으며, 오른쪽에 있는 요소입니다. 그리고 이러한 요소를 가진 그룹은 항상 마지막 그룹입니다.

두 번째 선택적 인수를 사용하여 이 패딩 값을 변경할 수 있습니다:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

또한 `false`를 전달하여 작은 그룹을 채우지 않도록 메서드에 지시할 수 있습니다:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

결과적으로 `false`는 패딩 값으로 사용할 수 없습니다.

참고: `active_support/core_ext/array/grouping.rb`에 정의되어 있습니다.


#### `split(value = nil)`

메서드 [`split`][Array#split]은 배열을 구분자로 나누고 결과적으로 생성된 청크를 반환합니다.

블록이 전달되면 구분자는 블록이 true를 반환하는 배열의 요소입니다:

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

그렇지 않으면, 기본값이 `nil`인 인수로 받은 값이 구분자입니다:

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

팁: 이전 예제에서 연속하는 구분자는 빈 배열로 결과됨을 관찰하세요.

참고: `active_support/core_ext/array/grouping.rb`에 정의되어 있습니다.


`Hash`의 확장
--------------------

### 변환

#### `to_xml`

메서드 [`to_xml`][Hash#to_xml]은 수신자의 XML 표현을 포함하는 문자열을 반환합니다:

```ruby
{ foo: 1, bar: 2 }.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```

이를 위해 메서드는 쌍을 순회하고 _값_에 따라 노드를 구축합니다. 쌍 `key`, `value`가 주어진 경우:

* `value`가 해시인 경우 `:root`로 `key`와 함께 재귀 호출이 있습니다.

* `value`가 배열인 경우 `:root`로 `key`와 함께 재귀 호출이 있으며, `key`를 단수화한 `:children`로 재귀 호출이 있습니다.

* `value`가 호출 가능한 객체인 경우 1개 또는 2개의 인수를 기대해야 합니다. 인수의 개수에 따라 `options` 해시가 첫 번째 인수로 `key`를 `:root`로, 두 번째 인수로 단수화된 `key`를 전달하여 호출됩니다. 반환 값은 새로운 노드가 됩니다.

* `value`가 `to_xml`에 응답하는 경우 `:root`로 호출됩니다.

* 그렇지 않으면, `key`를 태그로 하는 노드가 생성되고 `value`의 문자열 표현이 텍스트 노드로 추가됩니다. `value`가 `nil`인 경우 "nil" 속성이 "true"로 설정됩니다. `:skip_types` 옵션이 존재하고 true인 경우, 다음 매핑에 따라 "type" 속성이 추가됩니다:
```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "심볼",
  "Integer"    => "정수",
  "BigDecimal" => "실수",
  "Float"      => "부동소수점",
  "TrueClass"  => "부울",
  "FalseClass" => "부울",
  "Date"       => "날짜",
  "DateTime"   => "날짜시간",
  "Time"       => "날짜시간"
}
```

기본적으로 루트 노드는 "해시"이지만 `:root` 옵션을 통해 구성할 수 있습니다.

기본 XML 빌더는 `Builder::XmlMarkup`의 새로운 인스턴스입니다. `:builder` 옵션으로 자체 빌더를 구성할 수 있습니다. `:dasherize`와 같은 옵션도 받을 수 있으며, 이는 빌더로 전달됩니다.

참고: `active_support/core_ext/hash/conversions.rb`에서 정의됨.


### 병합

Ruby에는 두 개의 해시를 병합하는 내장 메소드 `Hash#merge`가 있습니다:

```ruby
{ a: 1, b: 1 }.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support는 편리한 해시 병합 방법 몇 가지를 정의합니다.

#### `reverse_merge`와 `reverse_merge!`

`merge`에서 인수의 해시에 있는 키가 충돌하는 경우, `merge`에서는 인수의 해시의 키가 이길 수 있습니다. 이러한 관용구를 사용하여 기본값이 있는 옵션 해시를 간단하게 지원할 수 있습니다:

```ruby
options = { length: 30, omission: "..." }.merge(options)
```

Active Support는 이와 같은 대체 표기법을 선호하는 경우 [`reverse_merge`][Hash#reverse_merge]를 정의합니다:

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

그리고 변경사항을 직접 적용하는 뱅 버전 [`reverse_merge!`][Hash#reverse_merge!]도 정의합니다:

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

경고. `reverse_merge!`는 호출자의 해시를 변경할 수 있으므로 좋은 아이디어일 수도 나쁜 아이디어일 수도 있습니다.

참고: `active_support/core_ext/hash/reverse_merge.rb`에서 정의됨.


#### `reverse_update`

[`reverse_update`][Hash#reverse_update] 메소드는 위에서 설명한 `reverse_merge!`의 별칭입니다.

경고. `reverse_update`에는 뱅이 없습니다.

참고: `active_support/core_ext/hash/reverse_merge.rb`에서 정의됨.


#### `deep_merge`와 `deep_merge!`

이전 예제에서 볼 수 있듯이, 두 해시에 모두 키가 있는 경우 인수의 해시의 값이 이길 수 있습니다.

Active Support는 [`Hash#deep_merge`][Hash#deep_merge]를 정의합니다. 깊은 병합에서는 두 해시에 모두 키가 있고, 그 값이 다시 해시인 경우, 결과 해시의 값은 그들의 병합이 됩니다:

```ruby
{ a: { b: 1 } }.deep_merge(a: { c: 2 })
# => {:a=>{:b=>1, :c=>2}}
```

[`deep_merge!`][Hash#deep_merge!] 메소드는 자리에서 깊은 병합을 수행합니다.

참고: `active_support/core_ext/hash/deep_merge.rb`에서 정의됨.


### 깊은 복제

[`Hash#deep_dup`][Hash#deep_dup] 메소드는 Active Support의 `Object#deep_dup` 메소드를 사용하여 자체와 모든 키와 값들을 재귀적으로 복제합니다. 이는 `Enumerator#each_with_object`와 비슷하게 작동하며, 각 쌍에 `deep_dup` 메소드를 보냅니다.

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

참고: `active_support/core_ext/object/deep_dup.rb`에서 정의됨.


### 키로 작업하기

#### `except`와 `except!`

[`except`][Hash#except] 메소드는 인수 목록에 있는 키가 있는 경우 해당 키가 제거된 해시를 반환합니다:

```ruby
{ a: 1, b: 2 }.except(:a) # => {:b=>2}
```

수신자가 `convert_key`에 응답하는 경우, 각 인수에 대해 해당 메소드가 호출됩니다. 이를 통해 `except`가 인덱스에 무관한 해시와 잘 작동할 수 있습니다:

```ruby
{ a: 1 }.with_indifferent_access.except(:a)  # => {}
{ a: 1 }.with_indifferent_access.except("a") # => {}
```

뱅 버전인 [`except!`][Hash#except!]도 있으며, 제거 작업을 직접 수행합니다.

참고: `active_support/core_ext/hash/except.rb`에서 정의됨.


#### `stringify_keys`와 `stringify_keys!`

[`stringify_keys`][Hash#stringify_keys] 메소드는 수신자의 키를 문자열로 변환한 해시를 반환합니다. 이를 위해 각 키에 `to_s`를 보냅니다:

```ruby
{ nil => nil, 1 => 1, a: :a }.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

키 충돌의 경우, 값은 해시에 가장 최근에 삽입된 값이 됩니다:

```ruby
{ "a" => 1, a: 2 }.stringify_keys
# 결과는
# => {"a"=>2}
```

이 방법은 예를 들어 심볼과 문자열을 모두 옵션으로 쉽게 받아들일 수 있도록 도움이 될 수 있습니다. 예를 들어 `ActionView::Helpers::FormHelper`에서는 다음과 같이 정의됩니다.

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  # ...
end
```

두 번째 줄은 "type" 키에 안전하게 접근할 수 있으며, 사용자가 `:type` 또는 "type"을 전달할 수 있도록 합니다.

또한 [`stringify_keys!`][Hash#stringify_keys!]라는 느낌표 변형도 있으며, 이는 키를 자리에 문자열로 변환합니다.

이 외에도 주어진 해시와 그 안에 중첩된 모든 해시의 모든 키를 문자열로 변환하는 [`deep_stringify_keys`][Hash#deep_stringify_keys]와 [`deep_stringify_keys!`][Hash#deep_stringify_keys!]를 사용할 수 있습니다. 결과의 예는 다음과 같습니다.

```ruby
{ nil => nil, 1 => 1, nested: { a: 3, 5 => 5 } }.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

참고: `active_support/core_ext/hash/keys.rb`에 정의됨.


#### `symbolize_keys`와 `symbolize_keys!`

[`symbolize_keys`][Hash#symbolize_keys] 메서드는 수신자의 키의 심볼 버전을 반환하는 해시를 반환합니다. 가능한 경우 `to_sym`을 보내어 이를 수행합니다.

```ruby
{ nil => nil, 1 => 1, "a" => "a" }.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

경고. 이전 예제에서는 하나의 키만 심볼로 변환되었습니다.

키 충돌의 경우, 값은 해시에 가장 최근에 삽입된 값이 됩니다.

```ruby
{ "a" => 1, a: 2 }.symbolize_keys
# => {:a=>2}
```

예를 들어 `ActionText::TagHelper`에서는 심볼과 문자열을 모두 옵션으로 쉽게 받아들일 수 있도록 다음과 같이 정의됩니다.

```ruby
def rich_text_area_tag(name, value = nil, options = {})
  options = options.symbolize_keys

  options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
  # ...
end
```

세 번째 줄은 `:input` 키에 안전하게 접근할 수 있으며, 사용자가 `:input` 또는 "input"을 전달할 수 있도록 합니다.

또한 느낌표 변형인 [`symbolize_keys!`][Hash#symbolize_keys!]도 있으며, 이는 키를 자리에 심볼로 변환합니다.

이 외에도 주어진 해시와 그 안에 중첩된 모든 해시의 모든 키를 심볼로 변환하는 [`deep_symbolize_keys`][Hash#deep_symbolize_keys]와 [`deep_symbolize_keys!`][Hash#deep_symbolize_keys!]를 사용할 수 있습니다. 결과의 예는 다음과 같습니다.

```ruby
{ nil => nil, 1 => 1, "nested" => { "a" => 3, 5 => 5 } }.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

참고: `active_support/core_ext/hash/keys.rb`에 정의됨.


#### `to_options`와 `to_options!`

[`to_options`][Hash#to_options]와 [`to_options!`][Hash#to_options!] 메서드는 각각 `symbolize_keys`와 `symbolize_keys!`의 별칭입니다.

참고: `active_support/core_ext/hash/keys.rb`에 정의됨.


#### `assert_valid_keys`

[`assert_valid_keys`][Hash#assert_valid_keys] 메서드는 임의의 수의 인수를 받아들이고, 수신자가 해당 목록 외의 키를 가지고 있는지 확인합니다. 그렇다면 `ArgumentError`가 발생합니다.

```ruby
{ a: 1 }.assert_valid_keys(:a)  # 통과
{ a: 1 }.assert_valid_keys("a") # ArgumentError
```

예를 들어 Active Record는 연관 관계를 빌드할 때 알 수 없는 옵션을 허용하지 않습니다. 이는 `assert_valid_keys`를 통해 해당 제어를 구현합니다.

참고: `active_support/core_ext/hash/keys.rb`에 정의됨.


### 값과 함께 작업하기

#### `deep_transform_values`와 `deep_transform_values!`

[`deep_transform_values`][Hash#deep_transform_values] 메서드는 블록 작업에 의해 변환된 모든 값을 포함하는 새로운 해시를 반환합니다. 이는 루트 해시와 모든 중첩된 해시 및 배열의 값도 포함합니다.

```ruby
hash = { person: { name: 'Rob', age: '28' } }

hash.deep_transform_values { |value| value.to_s.upcase }
# => {person: {name: "ROB", age: "28"}}
```

느낌표 변형인 [`deep_transform_values!`][Hash#deep_transform_values!]도 있으며, 이는 블록 작업을 사용하여 모든 값을 파괴적으로 변환합니다.

참고: `active_support/core_ext/hash/deep_transform_values.rb`에 정의됨.


### 슬라이싱

[`slice!`][Hash#slice!] 메서드는 주어진 키만 포함하도록 해시를 대체하고 제거된 키/값 쌍을 포함하는 해시를 반환합니다.

```ruby
hash = { a: 1, b: 2 }
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

참고: `active_support/core_ext/hash/slice.rb`에 정의됨.


### 추출

[`extract!`][Hash#extract!] 메서드는 주어진 키와 일치하는 키/값 쌍을 제거하고 반환합니다.

```ruby
hash = { a: 1, b: 2 }
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

`extract!` 메서드는 수신자와 동일한 하위 클래스의 해시를 반환합니다.
```ruby
hash = { a: 1, b: 2 }.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

참고: `active_support/core_ext/hash/slice.rb`에서 정의됨.


### Indifferent Access

[`with_indifferent_access`][Hash#with_indifferent_access] 메소드는 수신자로부터 [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess]를 반환합니다:

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

참고: `active_support/core_ext/hash/indifferent_access.rb`에서 정의됨.


`Regexp`에 대한 확장
----------------------

### `multiline?`

[`multiline?`][Regexp#multiline?] 메소드는 정규식이 `/m` 플래그가 설정되어 있는지, 즉 점이 개행 문자와 일치하는지 여부를 나타냅니다.

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails는 라우팅 코드에서도 이 메소드를 사용합니다. 다중 라인 정규식은 라우팅 요구 사항에 허용되지 않으며, 이 플래그는 이러한 제약 조건을 쉽게 적용할 수 있도록 도와줍니다.

```ruby
def verify_regexp_requirements(requirements)
  # ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option is not allowed in routing requirements: #{requirement.inspect}"
  end
  # ...
end
```

참고: `active_support/core_ext/regexp.rb`에서 정의됨.


`Range`에 대한 확장
---------------------

### `to_fs`

Active Support는 `Range#to_fs`를 `to_s`의 대안으로 정의하며, 선택적인 형식 인수를 이해합니다. 현재 이 글을 작성하는 시점에서 지원되는 비기본 형식은 `:db`뿐입니다:

```ruby
(Date.today..Date.tomorrow).to_fs
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_fs(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

위의 예시에서 보듯이 `:db` 형식은 `BETWEEN` SQL 절을 생성합니다. 이는 Active Record에서 조건에 대한 범위 값을 지원하기 위해 사용됩니다.

참고: `active_support/core_ext/range/conversions.rb`에서 정의됨.

### `===`와 `include?`

`Range#===`와 `Range#include?` 메소드는 주어진 인스턴스의 끝 사이에 어떤 값이 속하는지 여부를 나타냅니다:

```ruby
(2..3).include?(Math::E) # => true
```

Active Support는 이러한 메소드를 확장하여 인수가 다시 범위인 경우 수신자 자체에 대한 끝이 인수 범위에 속하는지 테스트합니다:

```ruby
(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false
(1..10) === (3..11) # => false
(1...9) === (3..9)  # => false

(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false
(1..10).include?(3..11) # => false
(1...9).include?(3..9)  # => false
```

참고: `active_support/core_ext/range/compare_range.rb`에서 정의됨.

### `overlap?`

[`Range#overlap?`][Range#overlap?] 메소드는 두 개의 주어진 범위가 비어 있지 않은 교차점을 가지고 있는지 여부를 나타냅니다:

```ruby
(1..10).overlap?(7..11)  # => true
(1..10).overlap?(0..7)   # => true
(1..10).overlap?(11..27) # => false
```

참고: `active_support/core_ext/range/overlap.rb`에서 정의됨.


`Date`에 대한 확장
--------------------

### 계산

INFO: 다음 계산 메소드는 1582년 10월에 엣지 케이스가 있습니다. 5일부터 14일까지는 존재하지 않습니다. 이 안내서는 간결함을 위해 이러한 날짜 주변의 동작을 문서화하지 않지만, 기대하는 동작을 수행한다는 것을 충분히 말할 수 있습니다. 즉, `Date.new(1582, 10, 4).tomorrow`는 `Date.new(1582, 10, 15)`를 반환합니다. 기대되는 동작에 대한 Active Support 테스트 스위트의 `test/core_ext/date_ext_test.rb`를 확인하십시오.

#### `Date.current`

Active Support는 [`Date.current`][Date.current]를 현재 시간대의 오늘로 정의합니다. 이는 `Date.today`와 유사하지만, 정의된 경우 사용자 시간대를 존중합니다. 또한 [`Date.yesterday`][Date.yesterday]와 [`Date.tomorrow`][Date.tomorrow], 그리고 인스턴스 술어 [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?], [`future?`][DateAndTime::Calculations#future?], [`on_weekday?`][DateAndTime::Calculations#on_weekday?] 및 [`on_weekend?`][DateAndTime::Calculations#on_weekend?]을 정의합니다. 이들은 모두 `Date.current`를 기준으로 상대적입니다.

사용자 시간대를 존중하는 메소드를 사용하여 날짜를 비교할 때는 `Date.today` 대신 `Date.current`를 사용해야 합니다. 사용자 시간대가 시스템 시간대보다 미래에 있을 수 있는 경우가 있으며, `Date.today`가 기본적으로 사용하는 시스템 시간대와 비교할 때 이를 고려해야 합니다. 이는 `Date.today`가 `Date.yesterday`와 같을 수 있다는 것을 의미합니다.

참고: `active_support/core_ext/date/calculations.rb`에서 정의됨.


#### 명명된 날짜

##### `beginning_of_week`, `end_of_week`

[`beginning_of_week`][DateAndTime::Calculations#beginning_of_week]와 [`end_of_week`][DateAndTime::Calculations#end_of_week] 메소드는 각각 주의 시작과 끝 날짜를 반환합니다. 주는 월요일부터 시작한다고 가정하지만, 인수를 전달하여 변경할 수 있으며, 스레드 로컬 `Date.beginning_of_week` 또는 [`config.beginning_of_week`][]를 설정할 수도 있습니다.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

`beginning_of_week`는 [`at_beginning_of_week`][DateAndTime::Calculations#at_beginning_of_week]로 별칭이 지정되어 있으며, `end_of_week`는 [`at_end_of_week`][DateAndTime::Calculations#at_end_of_week]로 별칭이 지정되어 있습니다.

참고: `active_support/core_ext/date_and_time/calculations.rb`에서 정의됩니다.


##### `monday`, `sunday`

[`monday`][DateAndTime::Calculations#monday]와 [`sunday`][DateAndTime::Calculations#sunday] 메소드는 각각 이전 월요일과 다음 일요일의 날짜를 반환합니다.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.monday                     # => Mon, 03 May 2010
d.sunday                     # => Sun, 09 May 2010

d = Date.new(2012, 9, 10)    # => Mon, 10 Sep 2012
d.monday                     # => Mon, 10 Sep 2012

d = Date.new(2012, 9, 16)    # => Sun, 16 Sep 2012
d.sunday                     # => Sun, 16 Sep 2012
```

참고: `active_support/core_ext/date_and_time/calculations.rb`에서 정의됩니다.


##### `prev_week`, `next_week`

[`next_week`][DateAndTime::Calculations#next_week] 메소드는 영어로 된 요일 이름을 가진 심볼(기본값은 스레드 로컬 [`Date.beginning_of_week`][Date.beginning_of_week] 또는 [`config.beginning_of_week`][], 또는 `:monday`)을 받아 해당 요일에 해당하는 날짜를 반환합니다.

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.next_week              # => Mon, 10 May 2010
d.next_week(:saturday)   # => Sat, 15 May 2010
```

[`prev_week`][DateAndTime::Calculations#prev_week] 메소드는 다음과 같이 작동합니다:

```ruby
d.prev_week              # => Mon, 26 Apr 2010
d.prev_week(:saturday)   # => Sat, 01 May 2010
d.prev_week(:friday)     # => Fri, 30 Apr 2010
```

`prev_week`는 [`last_week`][DateAndTime::Calculations#last_week]로 별칭이 지정되어 있습니다.

`next_week`와 `prev_week`는 `Date.beginning_of_week` 또는 `config.beginning_of_week`이 설정되어 있을 때 예상대로 작동합니다.

참고: `active_support/core_ext/date_and_time/calculations.rb`에서 정의됩니다.


##### `beginning_of_month`, `end_of_month`

[`beginning_of_month`][DateAndTime::Calculations#beginning_of_month]와 [`end_of_month`][DateAndTime::Calculations#end_of_month] 메소드는 해당 월의 시작과 끝 날짜를 반환합니다.

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_month     # => Sat, 01 May 2010
d.end_of_month           # => Mon, 31 May 2010
```

`beginning_of_month`는 [`at_beginning_of_month`][DateAndTime::Calculations#at_beginning_of_month]로 별칭이 지정되어 있으며, `end_of_month`는 [`at_end_of_month`][DateAndTime::Calculations#at_end_of_month]로 별칭이 지정되어 있습니다.

참고: `active_support/core_ext/date_and_time/calculations.rb`에서 정의됩니다.


##### `quarter`, `beginning_of_quarter`, `end_of_quarter`

[`quarter`][DateAndTime::Calculations#quarter] 메소드는 수신자의 달력 연도의 분기를 반환합니다:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.quarter                # => 2
```

[`beginning_of_quarter`][DateAndTime::Calculations#beginning_of_quarter]와 [`end_of_quarter`][DateAndTime::Calculations#end_of_quarter] 메소드는 수신자의 달력 연도의 분기의 시작과 끝 날짜를 반환합니다:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_quarter   # => Thu, 01 Apr 2010
d.end_of_quarter         # => Wed, 30 Jun 2010
```

`beginning_of_quarter`는 [`at_beginning_of_quarter`][DateAndTime::Calculations#at_beginning_of_quarter]로 별칭이 지정되어 있으며, `end_of_quarter`는 [`at_end_of_quarter`][DateAndTime::Calculations#at_end_of_quarter]로 별칭이 지정되어 있습니다.

참고: `active_support/core_ext/date_and_time/calculations.rb`에서 정의됩니다.


##### `beginning_of_year`, `end_of_year`

[`beginning_of_year`][DateAndTime::Calculations#beginning_of_year]와 [`end_of_year`][DateAndTime::Calculations#end_of_year] 메소드는 해당 연도의 시작과 끝 날짜를 반환합니다:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_year      # => Fri, 01 Jan 2010
d.end_of_year            # => Fri, 31 Dec 2010
```

`beginning_of_year`는 [`at_beginning_of_year`][DateAndTime::Calculations#at_beginning_of_year]로 별칭이 지정되어 있으며, `end_of_year`는 [`at_end_of_year`][DateAndTime::Calculations#at_end_of_year]로 별칭이 지정되어 있습니다.

참고: `active_support/core_ext/date_and_time/calculations.rb`에서 정의됩니다.


#### 기타 날짜 계산

##### `years_ago`, `years_since`

[`years_ago`][DateAndTime::Calculations#years_ago] 메소드는 과거로부터 주어진 수의 연도 전과 동일한 날짜를 반환합니다:

```ruby
date = Date.new(2010, 6, 7)
date.years_ago(10) # => Wed, 07 Jun 2000
```

[`years_since`][DateAndTime::Calculations#years_since] 메소드는 미래로 이동합니다:

```ruby
date = Date.new(2010, 6, 7)
date.years_since(10) # => Sun, 07 Jun 2020
```

해당 날짜가 존재하지 않는 경우 해당 월의 마지막 날짜가 반환됩니다:

```ruby
Date.new(2012, 2, 29).years_ago(3)     # => Sat, 28 Feb 2009
Date.new(2012, 2, 29).years_since(3)   # => Sat, 28 Feb 2015
```

[`last_year`][DateAndTime::Calculations#last_year]는 `#years_ago(1)`의 약어입니다.

참고: `active_support/core_ext/date_and_time/calculations.rb`에서 정의됩니다.


##### `months_ago`, `months_since`

[`months_ago`][DateAndTime::Calculations#months_ago]와 [`months_since`][DateAndTime::Calculations#months_since] 메소드는 월에 대해 유사하게 작동합니다:

```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sun, 28 Feb 2010
Date.new(2010, 4, 30).months_since(2) # => Wed, 30 Jun 2010
```

해당 날짜가 존재하지 않는 경우 해당 월의 마지막 날짜가 반환됩니다:

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sun, 28 Feb 2010
Date.new(2009, 12, 31).months_since(2) # => Sun, 28 Feb 2010
```

[`last_month`][DateAndTime::Calculations#last_month]는 `#months_ago(1)`의 약어입니다.
참고: `active_support/core_ext/date_and_time/calculations.rb`에 정의되어 있습니다.


##### `weeks_ago`

[`weeks_ago`][DateAndTime::Calculations#weeks_ago] 메소드는 주 단위로 작동합니다:

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Mon, 17 May 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Mon, 10 May 2010
```

참고: `active_support/core_ext/date_and_time/calculations.rb`에 정의되어 있습니다.


##### `advance`

다른 날짜로 이동하는 가장 일반적인 방법은 [`advance`][Date#advance]입니다. 이 메소드는 `:years`, `:months`, `:weeks`, `:days` 키를 가진 해시를 받아서 해당하는 키만큼 날짜를 진행시킵니다:

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Mon, 20 Jun 2011
date.advance(months: 2, days: -2) # => Wed, 04 Aug 2010
```

이전 예제에서 증가분이 음수일 수 있다는 점에 유의하세요.

참고: `active_support/core_ext/date/calculations.rb`에 정의되어 있습니다.


#### 구성 요소 변경

[`change`][Date#change] 메소드를 사용하면 주어진 연도, 월 또는 일을 제외한 수신자와 동일한 새로운 날짜를 얻을 수 있습니다:

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Wed, 23 Nov 2011
```

이 메소드는 존재하지 않는 날짜에 대해 허용하지 않으며, 변경이 잘못된 경우 `ArgumentError`가 발생합니다:

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: invalid date
```

참고: `active_support/core_ext/date/calculations.rb`에 정의되어 있습니다.


#### 기간

[`Duration`][ActiveSupport::Duration] 객체를 날짜에 더하거나 빼는 것이 가능합니다:

```ruby
d = Date.current
# => Mon, 09 Aug 2010
d + 1.year
# => Tue, 09 Aug 2011
d - 3.hours
# => Sun, 08 Aug 2010 21:00:00 UTC +00:00
```

이들은 `since` 또는 `advance`로 호출됩니다. 예를 들어, 달력 개혁에서 올바른 이동을 얻을 수 있습니다:

```ruby
Date.new(1582, 10, 4) + 1.day
# => Fri, 15 Oct 1582
```


#### 타임스탬프

INFO: 다음 메소드는 가능한 경우 `Time` 객체를 반환하고, 그렇지 않으면 `DateTime`을 반환합니다. 설정된 경우 사용자의 시간대를 존중합니다.

##### `beginning_of_day`, `end_of_day`

[`beginning_of_day`][Date#beginning_of_day] 메소드는 하루의 시작 시간 (00:00:00)의 타임스탬프를 반환합니다:

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Mon Jun 07 00:00:00 +0200 2010
```

[`end_of_day`][Date#end_of_day] 메소드는 하루의 끝 시간 (23:59:59)의 타임스탬프를 반환합니다:

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Mon Jun 07 23:59:59 +0200 2010
```

`beginning_of_day`는 [`at_beginning_of_day`][Date#at_beginning_of_day], [`midnight`][Date#midnight], [`at_midnight`][Date#at_midnight]에 별칭이 지정되어 있습니다.

참고: `active_support/core_ext/date/calculations.rb`에 정의되어 있습니다.


##### `beginning_of_hour`, `end_of_hour`

[`beginning_of_hour`][DateTime#beginning_of_hour] 메소드는 시간의 시작 시간 (hh:00:00)의 타임스탬프를 반환합니다:

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Mon Jun 07 19:00:00 +0200 2010
```

[`end_of_hour`][DateTime#end_of_hour] 메소드는 시간의 끝 시간 (hh:59:59)의 타임스탬프를 반환합니다:

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Mon Jun 07 19:59:59 +0200 2010
```

`beginning_of_hour`는 [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]에 별칭이 지정되어 있습니다.

참고: `active_support/core_ext/date_time/calculations.rb`에 정의되어 있습니다.

##### `beginning_of_minute`, `end_of_minute`

[`beginning_of_minute`][DateTime#beginning_of_minute] 메소드는 분의 시작 시간 (hh:mm:00)의 타임스탬프를 반환합니다:

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Mon Jun 07 19:55:00 +0200 2010
```

[`end_of_minute`][DateTime#end_of_minute] 메소드는 분의 끝 시간 (hh:mm:59)의 타임스탬프를 반환합니다:

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Mon Jun 07 19:55:59 +0200 2010
```

`beginning_of_minute`은 [`at_beginning_of_minute`][DateTime#at_beginning_of_minute]에 별칭이 지정되어 있습니다.

INFO: `beginning_of_hour`, `end_of_hour`, `beginning_of_minute`, `end_of_minute`은 `Time`과 `DateTime`에 구현되어 있지만 **`Date`에는 구현되어 있지 않습니다**. `Date` 인스턴스에서 시간의 시작 또는 끝을 요청하는 것은 의미가 없기 때문입니다.

참고: `active_support/core_ext/date_time/calculations.rb`에 정의되어 있습니다.


##### `ago`, `since`

[`ago`][Date#ago] 메소드는 초 단위의 숫자를 인수로 받아서 그만큼 이전의 타임스탬프를 반환합니다:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.ago(1)         # => Thu, 10 Jun 2010 23:59:59 EDT -04:00
```

마찬가지로, [`since`][Date#since] 메소드는 앞으로 이동합니다:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.since(1)       # => Fri, 11 Jun 2010 00:00:01 EDT -04:00
```
참고: `active_support/core_ext/date/calculations.rb`에 정의되어 있습니다.


`DateTime`에 대한 확장
------------------------

경고: `DateTime`은 DST 규칙을 인식하지 않으므로 일부 메서드는 DST 변경이 진행 중인 경우에 대한 예외 상황이 있을 수 있습니다. 예를 들어 [`seconds_since_midnight`][DateTime#seconds_since_midnight]는 해당 날짜에 실제로 반환되는 양을 반환하지 않을 수 있습니다.

### 계산

`DateTime` 클래스는 `Date`의 하위 클래스이므로 `active_support/core_ext/date/calculations.rb`를 로드하면 이러한 메서드와 해당 별칭을 상속받지만 항상 datetimes를 반환합니다.

다음 메서드는 `active_support/core_ext/date/calculations.rb`를 로드할 필요가 없으므로 다음 메서드에 대해 다시 구현되었습니다:

* [`beginning_of_day`][DateTime#beginning_of_day] / [`midnight`][DateTime#midnight] / [`at_midnight`][DateTime#at_midnight] / [`at_beginning_of_day`][DateTime#at_beginning_of_day]
* [`end_of_day`][DateTime#end_of_day]
* [`ago`][DateTime#ago]
* [`since`][DateTime#since] / [`in`][DateTime#in]

반면, [`advance`][DateTime#advance] 및 [`change`][DateTime#change]은 더 많은 옵션을 지원하도록 정의되어 있으며, 아래에서 문서화되어 있습니다.

다음 메서드는 `DateTime` 인스턴스와 함께 사용될 때만 의미가 있는 `active_support/core_ext/date_time/calculations.rb`에만 구현되었습니다:

* [`beginning_of_hour`][DateTime#beginning_of_hour] / [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]
* [`end_of_hour`][DateTime#end_of_hour]


#### Named Datetimes

##### `DateTime.current`

Active Support는 [`DateTime.current`][DateTime.current]를 `Time.now.to_datetime`과 유사하게 정의합니다. 다만 사용자의 시간대를 존중합니다. [`past?`][DateAndTime::Calculations#past?] 및 [`future?`][DateAndTime::Calculations#future?] 인스턴스 예측은 `DateTime.current`와 관련하여 정의됩니다.

참고: `active_support/core_ext/date_time/calculations.rb`에 정의되어 있습니다.


#### 다른 확장

##### `seconds_since_midnight`

[`seconds_since_midnight`][DateTime#seconds_since_midnight] 메서드는 자정 이후의 초 단위 시간을 반환합니다:

```ruby
now = DateTime.current     # => Mon, 07 Jun 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

참고: `active_support/core_ext/date_time/calculations.rb`에 정의되어 있습니다.


##### `utc`

[`utc`][DateTime#utc] 메서드는 수신자의 동일한 datetime을 UTC로 표현합니다.

```ruby
now = DateTime.current # => Mon, 07 Jun 2010 19:27:52 -0400
now.utc                # => Mon, 07 Jun 2010 23:27:52 +0000
```

이 메서드는 [`getutc`][DateTime#getutc]로도 별칭이 지정됩니다.

참고: `active_support/core_ext/date_time/calculations.rb`에 정의되어 있습니다.


##### `utc?`

[`utc?`][DateTime#utc?] 예측자는 수신자가 UTC를 시간대로 가지고 있는지 여부를 나타냅니다:

```ruby
now = DateTime.now # => Mon, 07 Jun 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

참고: `active_support/core_ext/date_time/calculations.rb`에 정의되어 있습니다.


##### `advance`

다른 datetime으로 이동하는 가장 일반적인 방법은 [`advance`][DateTime#advance]입니다. 이 메서드는 `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes` 및 `:seconds` 키를 가진 해시를 받아 현재 키가 나타내는 만큼 datetime을 진행시킵니다.

```ruby
d = DateTime.current
# => Thu, 05 Aug 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => Tue, 06 Sep 2011 12:34:32 +0000
```

이 메서드는 먼저 `Date#advance`에 `:years`, `:months`, `:weeks` 및 `:days`를 전달하여 목적지 날짜를 계산합니다. 그 후, `DateTime#since`를 호출하여 진행할 초 단위 수를 전달하여 시간을 조정합니다. 이 순서는 관련이 있으며 다른 순서는 일부 예외 상황에서 다른 datetime을 제공할 수 있습니다. `Date#advance`의 예제가 적용되며, 시간 비트와 관련된 순서 관련성을 보여줄 수 있습니다.

날짜 비트(이전에 문서화된대로 상대적인 처리 순서도 있음)를 먼저 이동한 다음 시간 비트를 이동하면 다음과 같은 계산 결과가 나옵니다:

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sun, 28 Feb 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Mon, 29 Mar 2010 00:00:00 +0000
```

그러나 반대로 계산하면 결과가 다릅니다:

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Thu, 01 Apr 2010 00:00:00 +0000
```

경고: `DateTime`이 DST를 인식하지 않기 때문에 경고나 오류 없이 존재하지 않는 시간 지점에 도달할 수 있습니다.

참고: `active_support/core_ext/date_time/calculations.rb`에 정의되어 있습니다.


#### 구성 요소 변경

[`change`][DateTime#change] 메서드를 사용하면 주어진 옵션(`:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start`)을 제외한 수신자와 동일한 새 datetime을 얻을 수 있습니다:

```ruby
now = DateTime.current
# => Tue, 08 Jun 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Wed, 08 Jun 2011 01:56:22 -0600
```
시간이 0으로 설정되면 분과 초도 0으로 설정됩니다(값이 지정되지 않은 경우):

```ruby
now.change(hour: 0)
# => Tue, 08 Jun 2010 00:00:00 +0000
```

마찬가지로, 분이 0으로 설정되면 초도 0으로 설정됩니다(값이 지정되지 않은 경우):

```ruby
now.change(min: 0)
# => Tue, 08 Jun 2010 01:00:00 +0000
```

이 메소드는 존재하지 않는 날짜에 대해 허용되지 않으며, 변경이 잘못된 경우 `ArgumentError`가 발생합니다:

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: invalid date
```

참고: `active_support/core_ext/date_time/calculations.rb`에서 정의됩니다.


#### 기간

[`Duration`][ActiveSupport::Duration] 객체는 날짜와 시간에 추가하거나 빼는 데 사용될 수 있습니다:

```ruby
now = DateTime.current
# => Mon, 09 Aug 2010 23:15:17 +0000
now + 1.year
# => Tue, 09 Aug 2011 23:15:17 +0000
now - 1.week
# => Mon, 02 Aug 2010 23:15:17 +0000
```

이들은 `since` 또는 `advance`에 대한 호출로 변환됩니다. 예를 들어, 여기에서 우리는 캘린더 개혁의 올바른 점프를 얻습니다:

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Fri, 15 Oct 1582 00:00:00 +0000
```

`Time`에 대한 확장
--------------------

### 계산

이들은 유사합니다. 위의 문서를 참조하고 다음 차이점을 고려하십시오:

* [`change`][Time#change]는 추가적인 `:usec` 옵션을 허용합니다.
* `Time`은 DST를 이해하므로 다음과 같이 올바른 DST 계산을 얻을 수 있습니다.

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# 바르셀로나에서 2010/03/28 02:00 +0100은 DST로 인해 2010/03/28 03:00 +0200이 됩니다.
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Sun Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Sun Mar 28 03:00:00 +0200 2010
```

* [`since`][Time#since] 또는 [`ago`][Time#ago]가 `Time`으로 표현할 수 없는 시간으로 이동하는 경우 `DateTime` 객체가 반환됩니다.


#### `Time.current`

Active Support는 [`Time.current`][Time.current]를 현재 시간대의 오늘로 정의합니다. 이는 `Time.now`와 유사하지만 정의된 경우 사용자 시간대를 존중합니다. 또한 [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?] 및 [`future?`][DateAndTime::Calculations#future?]와 같은 인스턴스 예측자를 정의합니다. 이들은 모두 `Time.current`에 상대적입니다.

사용자 시간대를 존중하는 메소드를 사용하여 시간 비교를 할 때는 `Time.now` 대신 `Time.current`을 사용하십시오. 사용자 시간대가 기본적으로 시스템 시간대보다 미래에 있을 수 있는 경우가 있습니다. 이는 `Time.now.to_date`가 `Date.yesterday`와 같을 수 있다는 것을 의미합니다.

참고: `active_support/core_ext/time/calculations.rb`에서 정의됩니다.


#### `all_day`, `all_week`, `all_month`, `all_quarter` 및 `all_year`

[`all_day`][DateAndTime::Calculations#all_day] 메소드는 현재 시간의 전체 일을 나타내는 범위를 반환합니다.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

마찬가지로, [`all_week`][DateAndTime::Calculations#all_week], [`all_month`][DateAndTime::Calculations#all_month], [`all_quarter`][DateAndTime::Calculations#all_quarter] 및 [`all_year`][DateAndTime::Calculations#all_year]은 모두 시간 범위를 생성하는 목적으로 사용됩니다.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_week
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Sun, 15 Aug 2010 23:59:59 UTC +00:00
now.all_week(:sunday)
# => Sun, 16 Sep 2012 00:00:00 UTC +00:00..Sat, 22 Sep 2012 23:59:59 UTC +00:00
now.all_month
# => Sat, 01 Aug 2010 00:00:00 UTC +00:00..Tue, 31 Aug 2010 23:59:59 UTC +00:00
now.all_quarter
# => Thu, 01 Jul 2010 00:00:00 UTC +00:00..Thu, 30 Sep 2010 23:59:59 UTC +00:00
now.all_year
# => Fri, 01 Jan 2010 00:00:00 UTC +00:00..Fri, 31 Dec 2010 23:59:59 UTC +00:00
```

참고: `active_support/core_ext/date_and_time/calculations.rb`에서 정의됩니다.


#### `prev_day`, `next_day`

[`prev_day`][Time#prev_day]와 [`next_day`][Time#next_day]는 이전 또는 다음 날짜의 시간을 반환합니다:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_day               # => 2010-05-07 00:00:00 +0900
t.next_day               # => 2010-05-09 00:00:00 +0900
```

참고: `active_support/core_ext/time/calculations.rb`에서 정의됩니다.


#### `prev_month`, `next_month`

[`prev_month`][Time#prev_month]와 [`next_month`][Time#next_month]는 이전 또는 다음 달의 동일한 날짜를 반환합니다:
```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_month             # => 2010-04-08 00:00:00 +0900
t.next_month             # => 2010-06-08 00:00:00 +0900
```

만약 해당 날짜가 존재하지 않는다면, 해당 월의 마지막 날이 반환됩니다:

```ruby
Time.new(2000, 5, 31).prev_month # => 2000-04-30 00:00:00 +0900
Time.new(2000, 3, 31).prev_month # => 2000-02-29 00:00:00 +0900
Time.new(2000, 5, 31).next_month # => 2000-06-30 00:00:00 +0900
Time.new(2000, 1, 31).next_month # => 2000-02-29 00:00:00 +0900
```

참고: `active_support/core_ext/time/calculations.rb`에 정의되어 있습니다.


#### `prev_year`, `next_year`

[`prev_year`][Time#prev_year]와 [`next_year`][Time#next_year]는 같은 날짜/월을 가진 작년이나 내년의 시간을 반환합니다:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_year              # => 2009-05-08 00:00:00 +0900
t.next_year              # => 2011-05-08 00:00:00 +0900
```

윤년의 2월 29일인 경우, 28일이 반환됩니다:

```ruby
t = Time.new(2000, 2, 29) # => 2000-02-29 00:00:00 +0900
t.prev_year               # => 1999-02-28 00:00:00 +0900
t.next_year               # => 2001-02-28 00:00:00 +0900
```

참고: `active_support/core_ext/time/calculations.rb`에 정의되어 있습니다.


#### `prev_quarter`, `next_quarter`

[`prev_quarter`][DateAndTime::Calculations#prev_quarter]와 [`next_quarter`][DateAndTime::Calculations#next_quarter]는 이전 또는 다음 분기에 같은 날짜를 가진 날짜를 반환합니다:

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 +0300
t.prev_quarter             # => 2010-02-08 00:00:00 +0200
t.next_quarter             # => 2010-08-08 00:00:00 +0300
```

만약 해당 날짜가 존재하지 않는다면, 해당 월의 마지막 날이 반환됩니다:

```ruby
Time.local(2000, 7, 31).prev_quarter  # => 2000-04-30 00:00:00 +0300
Time.local(2000, 5, 31).prev_quarter  # => 2000-02-29 00:00:00 +0200
Time.local(2000, 10, 31).prev_quarter # => 2000-07-31 00:00:00 +0300
Time.local(2000, 11, 31).next_quarter # => 2001-03-01 00:00:00 +0200
```

`prev_quarter`는 [`last_quarter`][DateAndTime::Calculations#last_quarter]에 별칭이 지정되어 있습니다.

참고: `active_support/core_ext/date_and_time/calculations.rb`에 정의되어 있습니다.


### 시간 생성자

Active Support는 사용자 시간대가 정의된 경우 `Time.current`를 `Time.zone.now`로 정의하고, 그렇지 않은 경우 `Time.now`로 정의합니다:

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

`DateTime`과 유사하게, [`past?`][DateAndTime::Calculations#past?]와 [`future?`][DateAndTime::Calculations#future?]는 `Time.current`를 기준으로 상대적입니다.

생성될 시간이 실행 플랫폼에서 지원하는 `Time` 범위를 벗어난다면, 마이크로초는 삭제되고 `DateTime` 객체가 반환됩니다.

#### 기간

[`Duration`][ActiveSupport::Duration] 객체는 시간 객체에 더하거나 빼는 데 사용될 수 있습니다:

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
# => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

이들은 `since` 또는 `advance` 호출로 변환됩니다. 예를 들어, 달력 개혁에서 올바른 이동을 얻을 수 있습니다:

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

`File`에 대한 확장
--------------------

### `atomic_write`

클래스 메소드 [`File.atomic_write`][File.atomic_write]를 사용하면, 반쪽짜리 콘텐츠를 읽는 독자가 없도록 파일에 쓸 수 있습니다.

파일의 이름이 인수로 전달되고, 메소드는 쓰기 위해 열린 파일 핸들을 얻습니다. 블록이 완료되면 `atomic_write`는 파일 핸들을 닫고 작업을 완료합니다.

예를 들어, Action Pack은 `all.css`와 같은 에셋 캐시 파일을 작성하기 위해 이 메소드를 사용합니다:

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

`atomic_write`는 임시 파일을 생성합니다. 블록 내의 코드가 실제로 쓰는 파일입니다. 완료되면 임시 파일이 이름을 변경하며, 이는 POSIX 시스템에서 원자적인 작업입니다. 대상 파일이 이미 존재하는 경우 `atomic_write`는 덮어쓰고 소유자와 권한을 유지합니다. 그러나 몇 가지 경우에는 `atomic_write`가 파일 소유권이나 권한을 변경할 수 없으며, 이 오류는 사용자/파일 시스템이 해당 파일에 액세스할 수 있도록 신뢰합니다.

참고. `atomic_write`가 수행하는 chmod 작업으로 인해 대상 파일에 ACL이 설정된 경우, 이 ACL은 재계산/수정됩니다.

```
경고. `atomic_write`와 함께 추가할 수 없습니다.

보조 파일은 임시 파일용 표준 디렉토리에 작성되지만, 두 번째 인수로 원하는 디렉토리를 전달할 수 있습니다.

참고: `active_support/core_ext/file/atomic.rb`에서 정의됨.


`NameError`에 대한 확장
-------------------------

Active Support는 `NameError`에 [`missing_name?`][NameError#missing_name?]을 추가하여 예외가 인수로 전달된 이름 때문에 발생했는지를 테스트합니다.

이름은 심볼 또는 문자열로 제공될 수 있습니다. 심볼은 벌크 상수 이름과 비교되고, 문자열은 완전한 정규화된 상수 이름과 비교됩니다.

팁: 심볼은 `:"ActiveRecord::Base"`와 같이 완전한 정규화된 상수 이름을 나타낼 수 있으므로, 심볼에 대한 동작은 기술적으로 그렇게 되어 있기 때문이 아니라 편의를 위해 정의되었습니다.

예를 들어, `ArticlesController`의 액션이 호출될 때 Rails는 낙관적으로 `ArticlesHelper`를 사용하려고 시도합니다. 도우미 모듈이 존재하지 않아도 괜찮으므로 해당 상수 이름에 대한 예외가 발생하면 무시되어야 합니다. 그러나 `articles_helper.rb`가 실제로 알 수 없는 상수로 인해 `NameError`를 발생시킬 수도 있습니다. 이 경우 `missing_name?` 메서드는 두 가지 경우를 구별하는 방법을 제공합니다:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

참고: `active_support/core_ext/name_error.rb`에서 정의됨.


`LoadError`에 대한 확장
-------------------------

Active Support는 `LoadError`에 [`is_missing?`][LoadError#is_missing?]을 추가합니다.

`is_missing?` 메서드는 예외가 해당 파일(확장자 ".rb"를 제외한 경우) 때문에 발생했는지를 테스트합니다.

예를 들어, `ArticlesController`의 액션이 호출될 때 Rails는 `articles_helper.rb`를 로드하려고 시도하지만 해당 파일이 존재하지 않을 수 있습니다. 이는 괜찮습니다. 도우미 모듈은 필수적이지 않으므로 Rails는 로드 오류를 무시합니다. 그러나 도우미 모듈이 실제로 존재하고 또 다른 라이브러리를 필요로 하는 경우에는 해당 예외를 다시 발생시켜야 합니다. `is_missing?` 메서드는 두 가지 경우를 구별하는 방법을 제공합니다:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

참고: `active_support/core_ext/load_error.rb`에서 정의됨.


Pathname에 대한 확장
-------------------------

### `existence`

[`existence`][Pathname#existence] 메서드는 지정된 파일이 존재하는 경우 수신자를 반환하고, 그렇지 않은 경우 `nil`을 반환합니다. 다음과 같은 관용구에 유용합니다:

```ruby
content = Pathname.new("file").existence&.read
```

참고: `active_support/core_ext/pathname/existence.rb`에서 정의됨.
[`config.active_support.bare`]: configuring.html#config-active-support-bare
[Object#blank?]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[Object#present?]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[Object#presence]: https://api.rubyonrails.org/classes/Object.html#method-i-presence
[Object#duplicable?]: https://api.rubyonrails.org/classes/Object.html#method-i-duplicable-3F
[Object#deep_dup]: https://api.rubyonrails.org/classes/Object.html#method-i-deep_dup
[Object#try]: https://api.rubyonrails.org/classes/Object.html#method-i-try
[Object#try!]: https://api.rubyonrails.org/classes/Object.html#method-i-try-21
[Kernel#class_eval]: https://api.rubyonrails.org/classes/Kernel.html#method-i-class_eval
[Object#acts_like?]: https://api.rubyonrails.org/classes/Object.html#method-i-acts_like-3F
[Array#to_param]: https://api.rubyonrails.org/classes/Array.html#method-i-to_param
[Object#to_param]: https://api.rubyonrails.org/classes/Object.html#method-i-to_param
[Hash#to_query]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_query
[Object#to_query]: https://api.rubyonrails.org/classes/Object.html#method-i-to_query
[Object#with_options]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[Object#instance_values]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_values
[Object#instance_variable_names]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_variable_names
[Kernel#enable_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-enable_warnings
[Kernel#silence_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-silence_warnings
[Kernel#suppress]: https://api.rubyonrails.org/classes/Kernel.html#method-i-suppress
[Object#in?]: https://api.rubyonrails.org/classes/Object.html#method-i-in-3F
[Module#alias_attribute]: https://api.rubyonrails.org/classes/Module.html#method-i-alias_attribute
[Module#attr_internal]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal
[Module#attr_internal_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_accessor
[Module#attr_internal_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_reader
[Module#attr_internal_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_writer
[Module#mattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_accessor
[Module#mattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_reader
[Module#mattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_writer
[Module#module_parent]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent
[Module#module_parent_name]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent_name
[Module#module_parents]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parents
[Module#anonymous?]: https://api.rubyonrails.org/classes/Module.html#method-i-anonymous-3F
[Module#delegate]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate
[Module#delegate_missing_to]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate_missing_to
[Module#redefine_method]: https://api.rubyonrails.org/classes/Module.html#method-i-redefine_method
[Module#silence_redefinition_of_method]: https://api.rubyonrails.org/classes/Module.html#method-i-silence_redefinition_of_method
[Class#class_attribute]: https://api.rubyonrails.org/classes/Class.html#method-i-class_attribute
[Module#cattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_accessor
[Module#cattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_reader
[Module#cattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_writer
[Class#subclasses]: https://api.rubyonrails.org/classes/Class.html#method-i-subclasses
[Class#descendants]: https://api.rubyonrails.org/classes/Class.html#method-i-descendants
[`raw`]: https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-raw
[String#html_safe]: https://api.rubyonrails.org/classes/String.html#method-i-html_safe
[String#remove]: https://api.rubyonrails.org/classes/String.html#method-i-remove
[String#squish]: https://api.rubyonrails.org/classes/String.html#method-i-squish
[String#truncate]: https://api.rubyonrails.org/classes/String.html#method-i-truncate
[String#truncate_bytes]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_bytes
[String#truncate_words]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_words
[String#inquiry]: https://api.rubyonrails.org/classes/String.html#method-i-inquiry
[String#strip_heredoc]: https://api.rubyonrails.org/classes/String.html#method-i-strip_heredoc
[String#indent!]: https://api.rubyonrails.org/classes/String.html#method-i-indent-21
[String#indent]: https://api.rubyonrails.org/classes/String.html#method-i-indent
[String#at]: https://api.rubyonrails.org/classes/String.html#method-i-at
[String#from]: https://api.rubyonrails.org/classes/String.html#method-i-from
[String#to]: https://api.rubyonrails.org/classes/String.html#method-i-to
[String#first]: https://api.rubyonrails.org/classes/String.html#method-i-first
[String#last]: https://api.rubyonrails.org/classes/String.html#method-i-last
[String#pluralize]: https://api.rubyonrails.org/classes/String.html#method-i-pluralize
[String#singularize]: https://api.rubyonrails.org/classes/String.html#method-i-singularize
[String#camelcase]: https://api.rubyonrails.org/classes/String.html#method-i-camelcase
[String#camelize]: https://api.rubyonrails.org/classes/String.html#method-i-camelize
[String#underscore]: https://api.rubyonrails.org/classes/String.html#method-i-underscore
[String#titlecase]: https://api.rubyonrails.org/classes/String.html#method-i-titlecase
[String#titleize]: https://api.rubyonrails.org/classes/String.html#method-i-titleize
[String#dasherize]: https://api.rubyonrails.org/classes/String.html#method-i-dasherize
[String#demodulize]: https://api.rubyonrails.org/classes/String.html#method-i-demodulize
[String#deconstantize]: https://api.rubyonrails.org/classes/String.html#method-i-deconstantize
[String#parameterize]: https://api.rubyonrails.org/classes/String.html#method-i-parameterize
[String#tableize]: https://api.rubyonrails.org/classes/String.html#method-i-tableize
[String#classify]: https://api.rubyonrails.org/classes/String.html#method-i-classify
[String#constantize]: https://api.rubyonrails.org/classes/String.html#method-i-constantize
[String#humanize]: https://api.rubyonrails.org/classes/String.html#method-i-humanize
[String#foreign_key]: https://api.rubyonrails.org/classes/String.html#method-i-foreign_key
[String#upcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-upcase_first
[String#downcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-downcase_first
[String#to_date]: https://api.rubyonrails.org/classes/String.html#method-i-to_date
[String#to_datetime]: https://api.rubyonrails.org/classes/String.html#method-i-to_datetime
[String#to_time]: https://api.rubyonrails.org/classes/String.html#method-i-to_time
[Numeric#bytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-bytes
[Numeric#exabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-exabytes
[Numeric#gigabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-gigabytes
[Numeric#kilobytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-kilobytes
[Numeric#megabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-megabytes
[Numeric#petabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-petabytes
[Numeric#terabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-terabytes
[Duration#ago]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-ago
[Duration#from_now]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-from_now
[Numeric#days]: https://api.rubyonrails.org/classes/Numeric.html#method-i-days
[Numeric#fortnights]: https://api.rubyonrails.org/classes/Numeric.html#method-i-fortnights
[Numeric#hours]: https://api.rubyonrails.org/classes/Numeric.html#method-i-hours
[Numeric#minutes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-minutes
[Numeric#seconds]: https://api.rubyonrails.org/classes/Numeric.html#method-i-seconds
[Numeric#weeks]: https://api.rubyonrails.org/classes/Numeric.html#method-i-weeks
[Integer#multiple_of?]: https://api.rubyonrails.org/classes/Integer.html#method-i-multiple_of-3F
[Integer#ordinal]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinal
[Integer#ordinalize]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinalize
[Integer#months]: https://api.rubyonrails.org/classes/Integer.html#method-i-months
[Integer#years]: https://api.rubyonrails.org/classes/Integer.html#method-i-years
[Enumerable#sum]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-sum
[Enumerable#index_by]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_by
[Enumerable#index_with]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_with
[Enumerable#many?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-many-3F
[Enumerable#exclude?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-exclude-3F
[Enumerable#including]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-including
[Enumerable#excluding]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-excluding
[Enumerable#without]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-without
[Enumerable#pluck]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pluck
[Enumerable#pick]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pick
[Array#excluding]: https://api.rubyonrails.org/classes/Array.html#method-i-excluding
[Array#fifth]: https://api.rubyonrails.org/classes/Array.html#method-i-fifth
[Array#forty_two]: https://api.rubyonrails.org/classes/Array.html#method-i-forty_two
[Array#fourth]: https://api.rubyonrails.org/classes/Array.html#method-i-fourth
[Array#from]: https://api.rubyonrails.org/classes/Array.html#method-i-from
[Array#including]: https://api.rubyonrails.org/classes/Array.html#method-i-including
[Array#second]: https://api.rubyonrails.org/classes/Array.html#method-i-second
[Array#second_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-second_to_last
[Array#third]: https://api.rubyonrails.org/classes/Array.html#method-i-third
[Array#third_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-third_to_last
[Array#to]: https://api.rubyonrails.org/classes/Array.html#method-i-to
[Array#extract!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract-21
[Array#extract_options!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract_options-21
[Array#to_sentence]: https://api.rubyonrails.org/classes/Array.html#method-i-to_sentence
[Array#to_fs]: https://api.rubyonrails.org/classes/Array.html#method-i-to_fs
[Array#to_xml]: https://api.rubyonrails.org/classes/Array.html#method-i-to_xml
[Array.wrap]: https://api.rubyonrails.org/classes/Array.html#method-c-wrap
[Array#deep_dup]: https://api.rubyonrails.org/classes/Array.html#method-i-deep_dup
[Array#in_groups_of]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups_of
[Array#in_groups]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups
[Array#split]: https://api.rubyonrails.org/classes/Array.html#method-i-split
[Hash#to_xml]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_xml
[Hash#reverse_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge-21
[Hash#reverse_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge
[Hash#reverse_update]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_update
[Hash#deep_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge-21
[Hash#deep_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge
[Hash#deep_dup]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_dup
[Hash#except!]: https://api.rubyonrails.org/classes/Hash.html#method-i-except-21
[Hash#except]: https://api.rubyonrails.org/classes/Hash.html#method-i-except
[Hash#deep_stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys-21
[Hash#deep_stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys
[Hash#stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys-21
[Hash#stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys
[Hash#deep_symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys-21
[Hash#deep_symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys
[Hash#symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys-21
[Hash#symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys
[Hash#to_options!]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options-21
[Hash#to_options]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options
[Hash#assert_valid_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-assert_valid_keys
[Hash#deep_transform_values!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values-21
[Hash#deep_transform_values]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values
[Hash#slice!]: https://api.rubyonrails.org/classes/Hash.html#method-i-slice-21
[Hash#extract!]: https://api.rubyonrails.org/classes/Hash.html#method-i-extract-21
[ActiveSupport::HashWithIndifferentAccess]: https://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html
[Hash#with_indifferent_access]: https://api.rubyonrails.org/classes/Hash.html#method-i-with_indifferent_access
[Regexp#multiline?]: https://api.rubyonrails.org/classes/Regexp.html#method-i-multiline-3F
[Range#overlap?]: https://api.rubyonrails.org/classes/Range.html#method-i-overlaps-3F
[Date.current]: https://api.rubyonrails.org/classes/Date.html#method-c-current
[Date.tomorrow]: https://api.rubyonrails.org/classes/Date.html#method-c-tomorrow
[Date.yesterday]: https://api.rubyonrails.org/classes/Date.html#method-c-yesterday
[DateAndTime::Calculations#future?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-future-3F
[DateAndTime::Calculations#on_weekday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekday-3F
[DateAndTime::Calculations#on_weekend?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekend-3F
[DateAndTime::Calculations#past?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-past-3F
[`config.beginning_of_week`]: configuring.html#config-beginning-of-week
[DateAndTime::Calculations#at_beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_week
[DateAndTime::Calculations#at_end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_week
[DateAndTime::Calculations#beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_week
[DateAndTime::Calculations#end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_week
[DateAndTime::Calculations#monday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-monday
[DateAndTime::Calculations#sunday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-sunday
[Date.beginning_of_week]: https://api.rubyonrails.org/classes/Date.html#method-c-beginning_of_week
[DateAndTime::Calculations#last_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_week
[DateAndTime::Calculations#next_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_week
[DateAndTime::Calculations#prev_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_week
[DateAndTime::Calculations#at_beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_month
[DateAndTime::Calculations#at_end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_month
[DateAndTime::Calculations#beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_month
[DateAndTime::Calculations#end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_month
[DateAndTime::Calculations#quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-quarter
[DateAndTime::Calculations#at_beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_quarter
[DateAndTime::Calculations#at_end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_quarter
[DateAndTime::Calculations#beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_quarter
[DateAndTime::Calculations#end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_quarter
[DateAndTime::Calculations#at_beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_year
[DateAndTime::Calculations#at_end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_year
[DateAndTime::Calculations#beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_year
[DateAndTime::Calculations#end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_year
[DateAndTime::Calculations#last_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_year
[DateAndTime::Calculations#years_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_ago
[DateAndTime::Calculations#years_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_since
[DateAndTime::Calculations#last_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_month
[DateAndTime::Calculations#months_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_ago
[DateAndTime::Calculations#months_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_since
[DateAndTime::Calculations#weeks_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-weeks_ago
[Date#advance]: https://api.rubyonrails.org/classes/Date.html#method-i-advance
[Date#change]: https://api.rubyonrails.org/classes/Date.html#method-i-change
[ActiveSupport::Duration]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html
[Date#at_beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-at_beginning_of_day
[Date#at_midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-at_midnight
[Date#beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-beginning_of_day
[Date#end_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-end_of_day
[Date#midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-midnight
[DateTime#at_beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_minute
[DateTime#beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_minute
[DateTime#end_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_minute
[Date#ago]: https://api.rubyonrails.org/classes/Date.html#method-i-ago
[Date#since]: https://api.rubyonrails.org/classes/Date.html#method-i-since
[DateTime#ago]: https://api.rubyonrails.org/classes/DateTime.html#method-i-ago
[DateTime#at_beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_day
[DateTime#at_beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_hour
[DateTime#at_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_midnight
[DateTime#beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_day
[DateTime#beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_hour
[DateTime#end_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_day
[DateTime#end_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_hour
[DateTime#in]: https://api.rubyonrails.org/classes/DateTime.html#method-i-in
[DateTime#midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-midnight
[DateTime.current]: https://api.rubyonrails.org/classes/DateTime.html#method-c-current
[DateTime#seconds_since_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-seconds_since_midnight
[DateTime#getutc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-getutc
[DateTime#utc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc
[DateTime#utc?]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc-3F
[DateTime#advance]: https://api.rubyonrails.org/classes/DateTime.html#method-i-advance
[DateTime#since]: https://api.rubyonrails.org/classes/DateTime.html#method-i-since
[DateTime#change]: https://api.rubyonrails.org/classes/DateTime.html#method-i-change
[Time#ago]: https://api.rubyonrails.org/classes/Time.html#method-i-ago
[Time#change]: https://api.rubyonrails.org/classes/Time.html#method-i-change
[Time#since]: https://api.rubyonrails.org/classes/Time.html#method-i-since
[DateAndTime::Calculations#next_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_day-3F
[DateAndTime::Calculations#prev_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_day-3F
[DateAndTime::Calculations#today?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-today-3F
[DateAndTime::Calculations#tomorrow?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-tomorrow-3F
[DateAndTime::Calculations#yesterday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-yesterday-3F
[DateAndTime::Calculations#all_day]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_day
[DateAndTime::Calculations#all_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_month
[DateAndTime::Calculations#all_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_quarter
[DateAndTime::Calculations#all_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_week
[DateAndTime::Calculations#all_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_year
[Time.current]: https://api.rubyonrails.org/classes/Time.html#method-c-current
[Time#next_day]: https://api.rubyonrails.org/classes/Time.html#method-i-next_day
[Time#prev_day]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_day
[Time#next_month]: https://api.rubyonrails.org/classes/Time.html#method-i-next_month
[Time#prev_month]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_month
[Time#next_year]: https://api.rubyonrails.org/classes/Time.html#method-i-next_year
[Time#prev_year]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_year
[DateAndTime::Calculations#last_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_quarter
[DateAndTime::Calculations#next_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_quarter
[DateAndTime::Calculations#prev_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_quarter
[File.atomic_write]: https://api.rubyonrails.org/classes/File.html#method-c-atomic_write
[NameError#missing_name?]: https://api.rubyonrails.org/classes/NameError.html#method-i-missing_name-3F
[LoadError#is_missing?]: https://api.rubyonrails.org/classes/LoadError.html#method-i-is_missing-3F
[Pathname#existence]: https://api.rubyonrails.org/classes/Pathname.html#method-i-existence
