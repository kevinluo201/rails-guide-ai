**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9c6201fd526077579ef792e0c4e2150d
클래식에서 Zeitwerk로의 전환 HOWTO
=========================

이 가이드는 Rails 애플리케이션을 `classic`에서 `zeitwerk` 모드로 마이그레이션하는 방법에 대해 문서화합니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* `classic`과 `zeitwerk` 모드란 무엇인가
* `classic`에서 `zeitwerk`로 전환하는 이유
* `zeitwerk` 모드를 활성화하는 방법
* 애플리케이션이 `zeitwerk` 모드에서 실행되는지 확인하는 방법
* 명령줄에서 프로젝트가 올바르게 로드되는지 확인하는 방법
* 테스트 스위트에서 프로젝트가 올바르게 로드되는지 확인하는 방법
* 가능한 예외 상황에 대처하는 방법
* Zeitwerk에서 활용할 수 있는 새로운 기능

--------------------------------------------------------------------------------

`classic`과 `zeitwerk` 모드란 무엇인가?
--------------------------------------------------------

처음부터 Rails 5까지, Rails는 Active Support에서 구현된 autoloader를 사용했습니다. 이 autoloader는 `classic`로 알려져 있으며, Rails 6.x에서도 사용할 수 있습니다. Rails 7에는 이 autoloader가 더 이상 포함되어 있지 않습니다.

Rails 6부터는 Rails가 [Zeitwerk](https://github.com/fxn/zeitwerk) 젬에 위임하는 새로운 자동로드 방식을 함께 제공합니다. 이것이 `zeitwerk` 모드입니다. 기본적으로 6.0과 6.1 프레임워크 기본값을 로드하는 애플리케이션은 `zeitwerk` 모드에서 실행되며, Rails 7에서는 이 모드만 사용할 수 있습니다.


`classic`에서 `zeitwerk`로 전환하는 이유는 무엇인가?
----------------------------------------

`classic` autoloader는 매우 유용했지만, 때때로 autoloading이 약간 까다롭고 혼란스러워지는 몇 가지 [문제](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#common-gotchas)가 있었습니다. Zeitwerk는 이를 해결하기 위해 개발되었으며, 다른 [동기](https://github.com/fxn/zeitwerk#motivation) 중 하나입니다.

Rails 6.x로 업그레이드할 때는 `zeitwerk` 모드로 전환하는 것이 좋습니다. `classic` 모드는 폐기되었습니다.

Rails 7은 전환 기간을 마감하고 `classic` 모드를 포함하지 않습니다.

두려워하지 마세요.
-----------

Zeitwerk는 가능한 한 classic autoloader와 호환되도록 설계되었습니다. 오늘 올바르게 autoloading되는 작동 중인 애플리케이션이 있다면 전환은 쉬울 것입니다. 많은 프로젝트들이 원활한 전환을 보고했습니다.

이 안내서는 자신감을 가지고 autoloader를 변경하는 데 도움이 될 것입니다.

해결할 수 없는 상황에 직면하면, 어떤 이유에서든 해결 방법을 모르는 상황에 직면하면, [rails/rails](https://github.com/rails/rails/issues/new)에 이슈를 열고 [`@fxn`](https://github.com/fxn)을 태그하는 것을 주저하지 마십시오.


`zeitwerk` 모드를 활성화하는 방법
-------------------------------

### Rails 5.x 이하에서 실행 중인 애플리케이션

6.0 이전의 Rails 버전에서는 `zeitwerk` 모드를 사용할 수 없습니다. 최소한 Rails 6.0 이상이어야 합니다.

### Rails 6.x에서 실행 중인 애플리케이션

Rails 6.x에서는 두 가지 시나리오가 있습니다.

애플리케이션이 Rails 6.0 또는 6.1의 프레임워크 기본값을 로드하고 `classic` 모드에서 실행 중인 경우, 수동으로 옵트 아웃해야 합니다. 다음과 유사한 내용이 있어야 합니다:

```ruby
# config/application.rb
config.load_defaults 6.0
config.autoloader = :classic # 이 줄을 삭제하세요
```

알림대로 오버라이드를 삭제하면 됩니다. `zeitwerk` 모드가 기본값입니다.

반면, 애플리케이션이 이전의 프레임워크 기본값을 로드하는 경우 `zeitwerk` 모드를 명시적으로 활성화해야 합니다:

```ruby
# config/application.rb
config.load_defaults 5.2
config.autoloader = :zeitwerk
```

### Rails 7에서 실행 중인 애플리케이션

Rails 7에서는 `zeitwerk` 모드만 사용할 수 있으므로 활성화할 필요가 없습니다.

실제로 `config.autoloader=` 세터는 Rails 7에서 심지어 존재하지 않습니다. `config/application.rb`에서 사용한다면 해당 줄을 삭제하세요.


애플리케이션이 `zeitwerk` 모드에서 실행되는지 확인하는 방법은 무엇인가?
------------------------------------------------------

애플리케이션이 `zeitwerk` 모드에서 실행 중인지 확인하려면 다음을 실행하세요.

```
bin/rails runner 'p Rails.autoloaders.zeitwerk_enabled?'
```

위 명령이 `true`를 출력하면 `zeitwerk` 모드가 활성화된 것입니다.


내 애플리케이션은 Zeitwerk 규칙을 준수합니까?
-----------------------------------------------------

### config.eager_load_paths

규칙 준수 테스트는 eager로드된 파일에 대해서만 실행됩니다. 따라서 Zeitwerk 규칙 준수를 확인하려면 모든 autoload 경로를 eager load 경로에 포함하는 것이 좋습니다.

기본적으로 이미 이렇게 설정되어 있지만, 프로젝트에 사용자 정의 autoload 경로가 다음과 같이 구성된 경우:

```ruby
config.autoload_paths << "#{Rails.root}/extras"
```

이러한 경로는 eager load되지 않으며 확인되지 않습니다. 이를 eager load 경로에 추가하는 것은 간단합니다:

```ruby
config.autoload_paths << "#{Rails.root}/extras"
config.eager_load_paths << "#{Rails.root}/extras"
```

### zeitwerk:check

`zeitwerk` 모드가 활성화되고 eager load 경로 구성이 확인되었다면 다음을 실행하세요:

```
bin/rails zeitwerk:check
```

성공적인 확인은 다음과 같습니다:

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

애플리케이션 구성에 따라 추가 출력이 있을 수 있지만, 마지막 "All is good!"가 확인해야 할 내용입니다.
이전 섹션에서 설명한 이중 확인이 실제로 사용자 정의 autoload 경로가 열정적인 로드 경로 외부에 있어야 함을 결정하면, 작업은 이를 감지하고 경고합니다. 그러나 테스트 스위트가 해당 파일을 성공적으로 로드하면 좋습니다.

이제 예상된 상수를 정의하지 않는 파일이 있다면, 작업은 알려줍니다. 이 작업은 한 번에 한 파일씩 수행되며, 한 파일의 로드 실패가 다른 체크와 관련 없는 다른 실패로 연쇄될 수 있으므로 오류 보고서가 혼란스러울 수 있습니다.

상수가 한 개 보고되면 해당 상수를 수정하고 작업을 다시 실행하십시오. "모두 좋습니다!"라는 메시지가 나올 때까지 반복하십시오.

예를 들어 다음과 같습니다.

```
% bin/rails zeitwerk:check
잠시만 기다려 주세요, 애플리케이션을 열정적으로 로드하고 있습니다.
파일 app/models/vat.rb에서 상수 Vat을 정의하기를 기대했습니다.
```

VAT는 유럽의 세금을 의미합니다. 파일 `app/models/vat.rb`은 `VAT`을 정의하지만 오토로더는 `Vat`을 예상합니다. 왜 그럴까요?

### 약어

이는 가장 일반적인 불일치 유형으로, 약어와 관련이 있습니다. 왜 이러한 오류 메시지가 표시되는지 이해해 봅시다.

클래식 오토로더는 `VAT`을 자동으로 로드할 수 있습니다. 왜냐하면 누락된 상수의 이름인 `VAT`을 입력으로 사용하여 `underscore`를 호출하면 `vat`이 생성되고, `vat.rb`라는 파일을 찾습니다. 이렇게 작동합니다.

새로운 오토로더의 입력은 파일 시스템입니다. `vat.rb` 파일이 주어지면 Zeitwerk은 `vat`에 대해 `camelize`를 호출하여 `Vat`을 생성하고, 파일이 상수 `Vat`을 정의하기를 기대합니다. 이것이 오류 메시지의 의미입니다.

이를 수정하는 것은 간단합니다. 인플렉터에 이 약어에 대해 알려주기만 하면 됩니다.

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "VAT"
end
```

이렇게 하면 Active Support가 전역적으로 인플렉트하는 방식이 변경됩니다. 이것은 괜찮을 수 있지만, autoloaders에서 사용하는 인플렉터에 대해 재정의를 전달할 수도 있습니다.

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.inflector.inflect("vat" => "VAT")
```

이 옵션을 사용하면 더 많은 제어권을 가질 수 있습니다. `vat.rb` 또는 `vat`이라는 디렉토리만 `VAT`으로 인플렉션됩니다. `vat_rules.rb`라는 파일은 이에 영향을 받지 않고 `VatRules`를 정의할 수 있습니다. 이는 프로젝트에 이러한 유형의 네이밍 불일치가 있는 경우에 유용할 수 있습니다.

이렇게 설정하면 체크가 통과됩니다!

```
% bin/rails zeitwerk:check
잠시만 기다려 주세요, 애플리케이션을 열정적으로 로드하고 있습니다.
모두 좋습니다!
```

모두 좋다면, 프로젝트를 테스트 스위트에서 계속 유효성을 검사하는 것이 좋습니다. [_테스트 스위트에서 Zeitwerk 규정 준수 확인하기_](#check-zeitwerk-compliance-in-the-test-suite) 섹션에서 이를 수행하는 방법에 대해 설명합니다.

### 관심사

`concerns` 하위 디렉토리를 사용하여 표준 구조에서 autoload 및 eager load할 수 있습니다.

```
app/models
app/models/concerns
```

기본적으로 `app/models/concerns`는 autoload 경로에 속하므로 루트 디렉토리로 간주됩니다. 따라서 기본적으로 `app/models/concerns/foo.rb`는 `Concerns::Foo`가 아닌 `Foo`를 정의해야 합니다.

애플리케이션이 `Concerns`를 네임스페이스로 사용하는 경우 두 가지 옵션이 있습니다.

1. 해당 클래스와 모듈에서 `Concerns` 네임스페이스를 제거하고 클라이언트 코드를 업데이트합니다.
2. `app/models/concerns`를 autoload 경로에서 제거하여 상태를 그대로 유지합니다.

  ```ruby
  # config/initializers/zeitwerk.rb
  ActiveSupport::Dependencies.
    autoload_paths.
    delete("#{Rails.root}/app/models/concerns")
  ```

### Autoload 경로에 `app`이 포함된 경우

일부 프로젝트에서는 `app/api/base.rb`와 같은 파일이 `API::Base`를 정의하도록 하기 위해 `app`을 autoload 경로에 추가하려고 합니다.

Rails는 `app`의 모든 하위 디렉토리를 자동으로 autoload 경로에 추가합니다(일부 예외가 있음). 이로 인해 `app/models/concerns`와 유사한 중첩된 루트 디렉토리가 있는 또 다른 상황이 발생합니다. 그러한 설정은 더 이상 작동하지 않습니다.

그러나 해당 구조를 유지할 수 있으며, 초기화 파일에서 `app/api`를 autoload 경로에서 제거하기만 하면 됩니다.

```ruby
# config/initializers/zeitwerk.rb
ActiveSupport::Dependencies.
  autoload_paths.
  delete("#{Rails.root}/app/api")
```

autoloaded/eager loaded할 파일이 없는 하위 디렉토리에 주의해야 합니다. 예를 들어, 애플리케이션이 [ActiveAdmin](https://activeadmin.info/)을 위한 리소스를 가진 `app/admin`를 가지고 있다면, 무시해야 합니다. `assets` 및 관련 항목도 마찬가지입니다.

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.ignore(
  "app/admin",
  "app/assets",
  "app/javascripts",
  "app/views"
)
```

이러한 구성 없이 애플리케이션은 해당 트리를 eager load합니다. 파일이 상수를 정의하지 않기 때문에 `app/admin`에서 오류가 발생하고, 예기치 않은 부작용으로 `Views` 모듈을 정의합니다.

보시다시피, autoload 경로에 `app`을 가지고 있는 것은 기술적으로 가능하지만 약간 까다로울 수 있습니다.

### Autoload된 상수와 명시적인 네임스페이스

파일에서 `Hotel`과 같이 네임스페이스가 정의된 경우:
```
app/models/hotel.rb         # 호텔을 정의합니다.
app/models/hotel/pricing.rb # Hotel::Pricing을 정의합니다.
```

`Hotel` 상수는 `class` 또는 `module` 키워드를 사용하여 설정해야 합니다. 예를 들어:

```ruby
class Hotel
end
```

이렇게 하는 것이 좋습니다.

다음과 같은 대안은 작동하지 않습니다.

```ruby
Hotel = Class.new
```

또는

```ruby
Hotel = Struct.new
```

`Hotel::Pricing`과 같은 하위 객체를 찾을 수 없습니다.

이 제한은 명시적인 네임스페이스에만 적용됩니다. 네임스페이스를 정의하지 않는 클래스와 모듈은 이러한 관용구를 사용하여 정의할 수 있습니다.

### 파일당 상수 하나 (동일한 최상위 수준에서)

`classic` 모드에서는 기술적으로 동일한 최상위 수준에서 여러 상수를 정의하고 모두 다시로드할 수 있습니다. 예를 들어 다음과 같이 주어진 경우

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

`Bar`는 자동로드될 수 없지만, `Foo`를 자동로드하면 `Bar`도 자동로드됩니다.

`zeitwerk` 모드에서는 이러한 경우 `Bar`를 자체 파일 `bar.rb`로 이동해야 합니다. 파일당 최상위 상수 하나.

이는 위의 예제와 동일한 최상위 수준의 상수에만 영향을 미칩니다. 내부 클래스와 모듈은 괜찮습니다. 예를 들어 다음과 같이 고려해보십시오.

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

응용 프로그램이 `Foo`를 다시로드하면 `Foo::InnerClass`도 다시로드됩니다.

### `config.autoload_paths`에서의 Glob

다음과 같이 와일드카드를 사용하는 구성에 주의하십시오.

```ruby
config.autoload_paths += Dir["#{config.root}/extras/**/"]
```

`config.autoload_paths`의 각 요소는 최상위 네임스페이스(`Object`)를 나타내야 합니다. 이는 작동하지 않습니다.

이를 수정하려면 와일드카드를 제거하십시오.

```ruby
config.autoload_paths << "#{config.root}/extras"
```

### 엔진에서 클래스와 모듈 장식

응용 프로그램이 엔진에서 클래스나 모듈을 장식하는 경우, 아마도 어딘가에서 다음과 같은 작업을 수행하고 있을 것입니다.

```ruby
config.to_prepare do
  Dir.glob("#{Rails.root}/app/overrides/**/*_override.rb").sort.each do |override|
    require_dependency override
  end
end
```

이를 업데이트해야 합니다. `main` 자동로더에게 오버라이드 디렉토리를 무시하도록 지시해야 하며, `load`를 사용하여 로드해야 합니다. 다음과 같이 수행하십시오.

```ruby
overrides = "#{Rails.root}/app/overrides"
Rails.autoloaders.main.ignore(overrides)
config.to_prepare do
  Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
    load override
  end
end
```

### `before_remove_const`

Rails 3.1에서는 클래스나 모듈이 이 메서드에 응답하고 다시로드될 예정인 경우 호출되는 `before_remove_const` 콜백을 지원하기 시작했습니다. 이 콜백은 그 외에는 문서화되지 않았으며, 코드에서 사용할 가능성은 거의 없습니다.

그러나 사용하는 경우 다음과 같이 다시 작성할 수 있습니다.

```ruby
class Country < ActiveRecord::Base
  def self.before_remove_const
    expire_redis_cache
  end
end
```

다음과 같이 변경합니다.

```ruby
# config/initializers/country.rb
if Rails.application.config.reloading_enabled?
  Rails.autoloaders.main.on_unload("Country") do |klass, _abspath|
    klass.expire_redis_cache
  end
end
```

### Spring과 `test` 환경

Spring은 무언가 변경되면 응용 프로그램 코드를 다시로드합니다. `test` 환경에서는 이를 작동하려면 다시로드를 활성화해야 합니다.

```ruby
# config/environments/test.rb
config.cache_classes = false
```

또는, Rails 7.1부터는 다음과 같이 할 수 있습니다.

```ruby
# config/environments/test.rb
config.enable_reloading = true
```

그렇지 않으면 다음과 같은 오류가 발생합니다.

```
reloading is disabled because config.cache_classes is true
```

또는

```
reloading is disabled because config.enable_reloading is false
```

이에는 성능에 영향을 주지 않습니다.

### Bootsnap

반드시 최소한 Bootsnap 1.4.4에 종속되어 있는지 확인하십시오.


테스트 스위트에서 Zeitwerk 준수 확인
-------------------------------------------

`zeitwerk:check` 작업은 마이그레이션 중에 유용합니다. 프로젝트가 준수하는 경우, 이 확인 작업을 자동화하는 것이 좋습니다. 이를 위해서는 응용 프로그램을 이그러로드하는 것만으로 충분합니다. 실제로 `zeitwerk:check`가 하는 일입니다.

### 지속적 통합

프로젝트에 지속적 통합이 있는 경우, 테스트 스위트가 실행될 때 응용 프로그램을 이그러로드하는 것이 좋습니다. 응용 프로그램을 어떤 이유로든 이그러로드할 수 없는 경우, 그것을 생산 환경보다는 CI에서 알고 싶을 것입니다. 그렇지 않습니까?

CI는 일반적으로 테스트 스위트가 실행되고 있는지를 나타내는 환경 변수를 설정합니다. 예를 들어, `CI`일 수 있습니다.

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

Rails 7부터는 새로 생성된 응용 프로그램이 기본적으로 이렇게 구성됩니다.

### 베어 테스트 스위트

지속적 통합이 없는 프로젝트의 경우, `Rails.application.eager_load!`를 호출하여 테스트 스위트에서 이그러로드할 수 있습니다.

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "eager loads all files without errors" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk compliance" do
  it "eager loads all files without errors" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

`require` 호출 삭제
--------------------------

내 경험상, 프로젝트에서는 일반적으로 이 작업을 수행하지 않습니다. 그러나 몇 가지 예를 보았고, 다른 몇 가지 예를 들은 적이 있습니다.
```
Rails 애플리케이션에서는 `require`를 사용하여 `lib`에서 코드를 또는 젬 종속성 또는 표준 라이브러리와 같은 3rd party에서 코드를 로드합니다. **`require`를 사용하여 autoload 가능한 애플리케이션 코드를 로드하지 마십시오**. `classic`에서 이미 왜 이것이 좋지 않은 아이디어인지 확인하려면 [여기](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#autoloading-and-require)를 참조하십시오.

```ruby
require "nokogiri" # 좋음
require "net/http" # 좋음
require "user"     # 나쁨, 삭제하세요 (app/models/user.rb를 가정합니다)
```

해당 유형의 `require` 호출을 삭제해주세요.

활용할 수 있는 새로운 기능
-----------------------------

### `require_dependency` 호출 삭제

Zeitwerk로 알려진 `require_dependency` 사용 사례는 모두 제거되었습니다. 프로젝트를 검색하고 삭제해야 합니다.

애플리케이션이 단일 테이블 상속을 사용하는 경우 Autoloading and Reloading Constants (Zeitwerk Mode) 가이드의 [단일 테이블 상속 섹션](autoloading_and_reloading_constants.html#single-table-inheritance)을 참조하세요.

### 클래스 및 모듈 정의에서 정규화된 이름 사용 가능

이제 클래스 및 모듈 정의에서 상수 경로를 안정적으로 사용할 수 있습니다:

```ruby
# 이 클래스 본문에서의 Autoloading은 이제 Ruby의 의미와 일치합니다.
class Admin::UsersController < ApplicationController
  # ...
end
```

주의할 점은 실행 순서에 따라 `classic` 오토로더가 때로는 `Foo::Wadus`를 자동로드할 수 있었던 것입니다.

```ruby
class Foo::Bar
  Wadus
end
```

이는 `Foo`가 중첩에 없기 때문에 Ruby의 의미와 일치하지 않으며 `zeitwerk` 모드에서 전혀 작동하지 않습니다. 이러한 특수한 경우를 발견하면 정규화된 이름 `Foo::Wadus`를 사용할 수 있습니다:

```ruby
class Foo::Bar
  Foo::Wadus
end
```

또는 중첩에 `Foo`를 추가할 수 있습니다:

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

### 모든 곳에서 스레드 안전성

`classic` 모드에서 상수 자동로딩은 스레드 안전하지 않지만, 예를 들어 웹 요청을 스레드 안전하게 만들기 위해 Rails에는 잠금이 있습니다.

`zeitwerk` 모드에서 상수 자동로딩은 스레드 안전합니다. 예를 들어, `runner` 명령으로 실행되는 멀티스레드 스크립트에서 이제 자동로드를 할 수 있습니다.

### 이저 로딩과 자동로딩의 일관성

`classic` 모드에서 `app/models/foo.rb`가 `Bar`를 정의하는 경우 해당 파일을 자동로드할 수 없지만 이저 로딩은 작동합니다. 이는 이저 로딩으로 먼저 테스트하고 실행이 나중에 자동로딩에서 실패할 수 있으므로 오류의 원인이 될 수 있습니다.

`zeitwerk` 모드에서는 두 로딩 모드 모두 일관성이 있으며, 동일한 파일에서 실패하고 오류가 발생합니다.
