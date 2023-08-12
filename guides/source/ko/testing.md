**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 6da9945dc313b748574b8aca256f1435
Rails 애플리케이션 테스트
==========================

이 가이드는 Rails에서 애플리케이션을 테스트하기 위한 내장된 메커니즘을 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* Rails 테스트 용어.
* 애플리케이션의 단위, 기능, 통합 및 시스템 테스트 작성 방법.
* 다른 인기있는 테스트 접근 방식과 플러그인.

--------------------------------------------------------------------------------

왜 Rails 애플리케이션을 테스트해야 할까요?
--------------------------------------------

Rails는 테스트 작성을 매우 쉽게 만들어줍니다. 모델과 컨트롤러를 생성하는 동안 스켈레톤 테스트 코드를 생성하는 것으로 시작합니다.

Rails 테스트를 실행함으로써 코드가 원하는 기능을 준수하는지 확인할 수 있으며, 일부 중요한 코드 리팩토링 이후에도 그렇습니다.

Rails 테스트는 브라우저 요청을 시뮬레이션할 수 있으므로 브라우저를 통해 테스트하지 않고도 애플리케이션의 응답을 테스트할 수 있습니다.

테스트 소개
-----------------------

테스트 지원은 Rails의 기반에 직접적으로 구현되었습니다. 이는 "테스트가 새롭고 멋지기 때문에 테스트 실행을 지원하기 위해 추가하자"는 아이디어가 아니었습니다.

### Rails는 처음부터 테스트를 위해 설정됩니다

Rails는 `rails new` _application_name_을 사용하여 Rails 프로젝트를 생성하는 즉시 `test` 디렉토리를 생성합니다. 이 디렉토리의 내용을 나열하면 다음과 같습니다:

```bash
$ ls -F test
application_system_test_case.rb  controllers/                     helpers/                         mailers/                         system/
channels/                        fixtures/                        integration/                     models/                          test_helper.rb
```

`helpers`, `mailers`, `models` 디렉토리는 각각 뷰 헬퍼, 메일러 및 모델에 대한 테스트를 보관하는 데 사용됩니다. `channels` 디렉토리는 Action Cable 연결 및 채널에 대한 테스트를 보관하는 데 사용됩니다. `controllers` 디렉토리는 컨트롤러, 라우트 및 뷰에 대한 테스트를 보관하는 데 사용됩니다. `integration` 디렉토리는 컨트롤러 간 상호작용에 대한 테스트를 보관하는 데 사용됩니다.

시스템 테스트 디렉토리는 애플리케이션의 전체 브라우저 테스트에 사용되는 시스템 테스트를 보관합니다. 시스템 테스트를 사용하면 사용자가 경험하는 방식으로 애플리케이션을 테스트할 수 있으며 JavaScript도 테스트할 수 있습니다. 시스템 테스트는 Capybara를 상속받고 애플리케이션의 브라우저 테스트를 수행합니다.

픽스처는 테스트 데이터를 구성하는 방법으로 `fixtures` 디렉토리에 저장됩니다.

관련된 테스트가 처음 생성될 때 `jobs` 디렉토리도 생성됩니다.

`test_helper.rb` 파일은 테스트의 기본 구성을 보유합니다.

`application_system_test_case.rb` 파일은 시스템 테스트의 기본 구성을 보유합니다.

### 테스트 환경

기본적으로 모든 Rails 애플리케이션은 개발, 테스트 및 프로덕션 세 가지 환경을 갖고 있습니다.

각 환경의 구성은 유사하게 수정할 수 있습니다. 이 경우 `config/environments/test.rb`에서 찾을 수 있는 옵션을 변경하여 테스트 환경을 수정할 수 있습니다.

참고: 테스트는 `RAILS_ENV=test`에서 실행됩니다.

### Rails와 Minitest의 만남

기억하시다시피, [Rails 시작하기](getting_started.html) 가이드에서 `bin/rails generate model` 명령을 사용했습니다. 첫 번째 모델을 생성하고, 그 외에도 `test` 디렉토리에 테스트 스텁이 생성되었습니다:

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

`test/models/article_test.rb`에 있는 기본 테스트 스텁은 다음과 같습니다:

```ruby
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

이 파일을 한 줄씩 살펴보면 Rails 테스트 코드와 용어에 대해 이해하는 데 도움이 됩니다.

```ruby
require "test_helper"
```

이 파일을 요구함으로써 `test_helper.rb` 파일이 로드되어 테스트를 실행하는 기본 구성이 로드됩니다. 이 파일을 작성하는 모든 테스트에 포함시킬 것이므로 이 파일에 추가된 모든 메서드는 모든 테스트에서 사용할 수 있습니다.

```ruby
class ArticleTest < ActiveSupport::TestCase
```

`ArticleTest` 클래스는 `ActiveSupport::TestCase`를 상속받기 때문에 _테스트 케이스_를 정의합니다. `ArticleTest`는 따라서 `ActiveSupport::TestCase`에서 사용 가능한 모든 메서드를 가지고 있습니다. 이 가이드의 후반부에서 제공되는 일부 메서드를 살펴볼 것입니다.

`Minitest::Test`를 상속받은 클래스에서 정의된 `test_`로 시작하는 모든 메서드는 단순히 테스트라고 부릅니다. 따라서 `test_password`와 `test_valid_password`와 같이 정의된 메서드는 합법적인 테스트 이름이며, 테스트 케이스가 실행될 때 자동으로 실행됩니다.

Rails는 `test` 메서드도 추가합니다. 이 메서드는 테스트 이름과 블록을 인수로 받습니다. 이 메서드는 `test_`로 접두사가 붙은 메서드 이름을 가진 일반적인 `Minitest::Unit` 테스트를 생성합니다. 따라서 메서드 이름을 걱정할 필요가 없으며, 다음과 같이 작성할 수 있습니다:

```ruby
test "the truth" do
  assert true
end
```

이는 다음과 같이 작성하는 것과 거의 동일합니다:
```ruby
def test_the_truth
  assert true
end
```

일반적인 메소드 정의를 사용할 수 있지만, `test` 매크로를 사용하면 더 읽기 쉬운 테스트 이름을 사용할 수 있습니다.

참고: 메소드 이름은 공백을 밑줄로 대체하여 생성됩니다. 결과는 유효한 루비 식별자일 필요는 없지만 - 이름에 구두점 문자 등이 포함될 수 있습니다. 이는 루비에서 기술적으로 모든 문자열이 메소드 이름이 될 수 있기 때문입니다. 이는 `define_method`와 `send` 호출을 사용하여 제대로 작동하도록 요구할 수도 있지만, 형식적으로 이름에는 제한이 거의 없습니다.

다음으로, 첫 번째 어설션을 살펴보겠습니다:

```ruby
assert true
```

어설션은 기대되는 결과를 위해 객체(또는 표현식)를 평가하는 코드 줄입니다. 예를 들어, 어설션은 다음을 확인할 수 있습니다:

* 이 값 = 저 값인가요?
* 이 객체는 nil인가요?
* 이 코드 줄은 예외를 throw합니까?
* 사용자의 비밀번호는 5자 이상인가요?

모든 테스트에는 하나 이상의 어설션이 포함될 수 있으며, 허용되는 어설션의 수에는 제한이 없습니다. 모든 어설션이 성공적으로 완료되면 테스트가 통과됩니다.

#### 첫 번째 실패하는 테스트

테스트 실패가 어떻게 보고되는지 보려면, `article_test.rb` 테스트 케이스에 실패하는 테스트를 추가할 수 있습니다.

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save
end
```

이 새로 추가된 테스트를 실행해 보겠습니다 (`6`은 테스트가 정의된 줄 번호입니다).

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 44656

# Running:

F

Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Expected true to be nil or false


bin/rails test test/models/article_test.rb:6



Finished in 0.023918s, 41.8090 runs/s, 41.8090 assertions/s.

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
```

출력에서 `F`는 실패를 나타냅니다. 실패한 테스트의 이름과 해당 추적이 `Failure` 아래에 표시되는 것을 볼 수 있습니다. 다음 몇 줄에는 스택 추적이 포함되어 있으며, 어설션에 의해 실제 값과 기대 값이 언급된 메시지가 뒤따릅니다. 기본 어설션 메시지는 오류를 정확하게 지정하는 데 충분한 정보를 제공합니다. 어설션 실패 메시지를 더 읽기 쉽게 만들기 위해, 모든 어설션은 선택적인 메시지 매개변수를 제공합니다. 다음과 같이 표시됩니다:

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save, "Saved the article without a title"
end
```

이 테스트를 실행하면 더 친근한 어설션 메시지가 표시됩니다:

```
Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Saved the article without a title
```

이제 이 테스트를 통과시키기 위해 _title_ 필드에 대한 모델 수준의 유효성 검사를 추가할 수 있습니다.

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

이제 테스트가 통과해야 합니다. 다시 테스트를 실행하여 확인해 보겠습니다:

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 31252

# Running:

.

Finished in 0.027476s, 36.3952 runs/s, 36.3952 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

이제, 주목하신 것처럼, 우리는 먼저 원하는 기능에 실패하는 테스트를 작성하고, 그런 다음 기능을 추가하는 코드를 작성하고, 마지막으로 테스트가 통과하는지 확인했습니다. 이러한 소프트웨어 개발 접근 방식은
[_테스트 주도 개발_ (TDD)](http://c2.com/cgi/wiki?TestDrivenDevelopment)이라고 합니다.

#### 에러의 모습

에러가 어떻게 보고되는지 보려면, 다음과 같은 에러가 포함된 테스트를 살펴보겠습니다:

```ruby
test "should report error" do
  # some_undefined_variable is not defined elsewhere in the test case
  some_undefined_variable
  assert true
end
```

이제 테스트를 실행하여 콘솔에서 더 많은 출력을 볼 수 있습니다:

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1808

# Running:

.E

Error:
ArticleTest#test_should_report_error:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9



Finished in 0.040609s, 49.2500 runs/s, 24.6250 assertions/s.

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

출력에서 'E'는 에러가 있는 테스트를 나타냅니다.

참고: 각 테스트 메소드의 실행은 오류나 어설션 실패가 발생하면 즉시 중지되며, 테스트 스위트는 다음 메소드로 계속 진행됩니다. 모든 테스트 메소드는 임의의 순서로 실행됩니다. 테스트 순서를 구성하려면 [`config.active_support.test_order`][] 옵션을 사용할 수 있습니다.

테스트가 실패하면 해당하는 백트레이스가 표시됩니다. 기본적으로 Rails는 해당 백트레이스를 필터링하고 응용 프로그램과 관련된 줄만 인쇄합니다. 이렇게 함으로써 프레임워크의 노이즈를 제거하고 코드에 집중할 수 있습니다. 그러나 전체 백트레이스를 볼 수 있는 상황도 있습니다. 이 동작을 활성화하려면 `-b` (또는 `--backtrace`) 인수를 설정하십시오:
```bash
$ bin/rails test -b test/models/article_test.rb
```

이 테스트를 통과시키기 위해 `assert_raises`를 사용하여 수정할 수 있습니다:

```ruby
test "에러를 보고해야 함" do
  # some_undefined_variable은 테스트 케이스에서 다른 곳에서 정의되지 않았습니다.
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

이제 이 테스트는 통과해야 합니다.


### 사용 가능한 어설션

지금까지 사용 가능한 어설션의 일부를 살펴보았습니다. 어설션은 테스트의 작업자입니다. 계획대로 진행되고 있는지 확인하기 위해 실제로 체크를 수행하는 역할을 합니다.

다음은 Rails에서 사용하는 기본 테스트 라이브러리인 [`Minitest`](https://github.com/minitest/minitest)에서 사용할 수 있는 어설션의 일부입니다. `[msg]` 매개변수는 테스트 실패 메시지를 더 명확하게 만들기 위해 지정할 수 있는 선택적인 문자열 메시지입니다.

| 어설션                                                         | 목적 |
| ---------------------------------------------------------------- | ------- |
| `assert( test, [msg] )`                                          | `test`가 true인지 확인합니다.|
| `assert_not( test, [msg] )`                                      | `test`가 false인지 확인합니다.|
| `assert_equal( expected, actual, [msg] )`                        | `expected == actual`이 true인지 확인합니다.|
| `assert_not_equal( expected, actual, [msg] )`                    | `expected != actual`이 true인지 확인합니다.|
| `assert_same( expected, actual, [msg] )`                         | `expected.equal?(actual)`이 true인지 확인합니다.|
| `assert_not_same( expected, actual, [msg] )`                     | `expected.equal?(actual)`이 false인지 확인합니다.|
| `assert_nil( obj, [msg] )`                                       | `obj.nil?`이 true인지 확인합니다.|
| `assert_not_nil( obj, [msg] )`                                   | `obj.nil?`이 false인지 확인합니다.|
| `assert_empty( obj, [msg] )`                                     | `obj`가 `empty?`인지 확인합니다.|
| `assert_not_empty( obj, [msg] )`                                 | `obj`가 `empty?`가 아닌지 확인합니다.|
| `assert_match( regexp, string, [msg] )`                          | 문자열이 정규 표현식과 일치하는지 확인합니다.|
| `assert_no_match( regexp, string, [msg] )`                       | 문자열이 정규 표현식과 일치하지 않는지 확인합니다.|
| `assert_includes( collection, obj, [msg] )`                      | `obj`가 `collection`에 포함되어 있는지 확인합니다.|
| `assert_not_includes( collection, obj, [msg] )`                  | `obj`가 `collection`에 포함되어 있지 않은지 확인합니다.|
| `assert_in_delta( expected, actual, [delta], [msg] )`            | 숫자 `expected`와 `actual`이 `delta` 범위 내에 있는지 확인합니다.|
| `assert_not_in_delta( expected, actual, [delta], [msg] )`        | 숫자 `expected`와 `actual`이 `delta` 범위 내에 없는지 확인합니다.|
| `assert_in_epsilon ( expected, actual, [epsilon], [msg] )`       | 숫자 `expected`와 `actual`의 상대 오차가 `epsilon`보다 작은지 확인합니다.|
| `assert_not_in_epsilon ( expected, actual, [epsilon], [msg] )`   | 숫자 `expected`와 `actual`의 상대 오차가 `epsilon`보다 작지 않은지 확인합니다.|
| `assert_throws( symbol, [msg] ) { block }`                       | 주어진 블록이 지정된 심볼을 던지는지 확인합니다.|
| `assert_raises( exception1, exception2, ... ) { block }`         | 주어진 블록이 주어진 예외 중 하나를 발생시키는지 확인합니다.|
| `assert_instance_of( class, obj, [msg] )`                        | `obj`가 `class`의 인스턴스인지 확인합니다.|
| `assert_not_instance_of( class, obj, [msg] )`                    | `obj`가 `class`의 인스턴스가 아닌지 확인합니다.|
| `assert_kind_of( class, obj, [msg] )`                            | `obj`가 `class`의 인스턴스이거나 `class`에서 상속된 것인지 확인합니다.|
| `assert_not_kind_of( class, obj, [msg] )`                        | `obj`가 `class`의 인스턴스가 아니고 `class`에서 상속되지 않았는지 확인합니다.|
| `assert_respond_to( obj, symbol, [msg] )`                        | `obj`가 `symbol`에 응답하는지 확인합니다.|
| `assert_not_respond_to( obj, symbol, [msg] )`                    | `obj`가 `symbol`에 응답하지 않는지 확인합니다.|
| `assert_operator( obj1, operator, [obj2], [msg] )`               | `obj1.operator(obj2)`가 true인지 확인합니다.|
| `assert_not_operator( obj1, operator, [obj2], [msg] )`           | `obj1.operator(obj2)`가 false인지 확인합니다.|
| `assert_predicate ( obj, predicate, [msg] )`                     | `obj.predicate`가 true인지 확인합니다. 예: `assert_predicate str, :empty?`|
| `assert_not_predicate ( obj, predicate, [msg] )`                 | `obj.predicate`가 false인지 확인합니다. 예: `assert_not_predicate str, :empty?`|
| `flunk( [msg] )`                                                 | 실패를 보장합니다. 아직 완료되지 않은 테스트를 명시적으로 표시하는 데 유용합니다.|

위는 minitest가 지원하는 어설션의 일부입니다. 자세하고 최신 목록은
[Minitest API documentation](http://docs.seattlerb.org/minitest/)을 확인하십시오.
특히 [`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html)를 참조하십시오.

테스트 프레임워크의 모듈식 특성 때문에 자체 어설션을 만들 수도 있습니다. 실제로 Rails도 그렇게 합니다. 목적을 달성하기 위해 몇 가지 특수한 어설션을 포함시켜 작업을 더 쉽게 만듭니다.

참고: 자체 어설션을 만드는 것은 이 튜토리얼에서 다루지 않는 고급 주제입니다.

### Rails 특정 어설션

Rails는 `minitest` 프레임워크에 몇 가지 사용자 정의 어설션을 추가합니다.
| 어설션(assertion) | 목적 |
| ----------------- | ---- |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | 블록에서 평가된 결과로 인해 표현식의 반환 값의 숫자 차이를 테스트합니다. |
| [`assert_no_difference(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | 전달된 블록을 호출하기 전과 후에 평가된 표현식의 숫자 결과가 변경되지 않았음을 확인합니다. |
| [`assert_changes(expressions, message = nil, from:, to:, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes) | 전달된 블록을 호출한 후에 표현식의 평가 결과가 변경되었는지 테스트합니다. |
| [`assert_no_changes(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes) | 전달된 블록을 호출한 후에 표현식의 평가 결과가 변경되지 않았음을 테스트합니다. |
| [`assert_nothing_raised { block }`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised) | 주어진 블록이 예외를 발생시키지 않도록 보장합니다. |
| [`assert_recognizes(expected_options, path, extras={}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | 주어진 경로의 라우팅이 올바르게 처리되었고, 예상된 옵션 해시에 있는 파싱된 옵션이 경로와 일치하는지 확인합니다. 기본적으로 Rails가 주어진 라우트를 인식하는지 확인합니다. |
| [`assert_generates(expected_path, options, defaults={}, extras = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | 주어진 옵션을 사용하여 주어진 경로를 생성할 수 있는지 확인합니다. 이는 `assert_recognizes`의 반대입니다. extras 매개변수는 쿼리 문자열에 있을 수 있는 추가 요청 매개변수의 이름과 값에 대한 정보를 전달하는 데 사용됩니다. message 매개변수를 사용하여 사용자 정의 오류 메시지를 지정할 수 있습니다. |
| [`assert_response(type, message = nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | 응답이 특정 상태 코드와 함께 전달되는지 확인합니다. `:success`를 지정하여 200-299를 나타냅니다. `:redirect`를 지정하여 300-399를 나타냅니다. `:missing`을 지정하여 404를 나타냅니다. `:error`를 지정하여 500-599 범위와 일치시킵니다. 명시적인 상태 번호나 해당 상태 번호의 기호적 동등물을 전달할 수도 있습니다. 자세한 정보는 [상태 코드의 전체 목록](https://rubydoc.info/gems/rack/Rack/Utils#HTTP_STATUS_CODES-constant) 및 그들의 [매핑](https://rubydoc.info/gems/rack/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant)이 작동하는 방식을 참조하십시오. |
| [`assert_redirected_to(options = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | 응답이 주어진 옵션과 일치하는 URL로 리디렉션되는지 확인합니다. `assert_redirected_to root_path`와 같은 이름 있는 라우트 또는 `assert_redirected_to @article`과 같은 Active Record 객체를 전달할 수도 있습니다.|

다음 장에서는 이러한 어설션들의 사용법을 볼 수 있습니다.

### 테스트 케이스에 대한 간단한 참고 사항

`Minitest::Assertions`에 정의된 `assert_equal`과 같은 모든 기본 어설션은 우리 자신의 테스트 케이스에서 사용하는 클래스에도 사용할 수 있습니다. 실제로 Rails는 다음과 같은 클래스를 상속할 수 있도록 제공합니다:

* [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](https://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::IntegrationTest`](https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActionDispatch::SystemTestCase`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](https://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

이러한 각 클래스는 `Minitest::Assertions`를 포함하므로 테스트에서 모든 기본 어설션을 사용할 수 있습니다.

참고: `Minitest`에 대한 자세한 정보는 [문서](http://docs.seattlerb.org/minitest)를 참조하십시오.

### Rails 테스트 러너

`bin/rails test` 명령을 사용하여 모든 테스트를 한 번에 실행할 수 있습니다.

또는 `bin/rails test` 명령에 테스트 케이스가 포함된 파일 이름을 전달하여 단일 테스트 파일을 실행할 수 있습니다.

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1559

# Running:

..

Finished in 0.027034s, 73.9810 runs/s, 110.9715 assertions/s.

2 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

이렇게 하면 테스트 케이스에서 모든 테스트 메서드가 실행됩니다.

또는 `-n` 또는 `--name` 플래그와 테스트의 메서드 이름을 제공하여 테스트 케이스에서 특정 테스트 메서드를 실행할 수 있습니다.

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Run options: -n test_the_truth --seed 43583

# Running:

.

Finished tests in 0.009064s, 110.3266 tests/s, 110.3266 assertions/s.

1 tests, 1 assertions, 0 failures, 0 errors, 0 skips
```

라인 번호를 제공하여 특정 라인에서 테스트를 실행할 수도 있습니다.

```bash
$ bin/rails test test/models/article_test.rb:6 # 특정 테스트 및 라인 실행
```

디렉토리 경로를 제공하여 테스트 디렉토리 전체를 실행할 수도 있습니다.

```bash
$ bin/rails test test/controllers # 특정 디렉토리의 모든 테스트 실행
```

테스트 러너는 실패를 빠르게 감지하거나 테스트 출력을 테스트 실행의 끝에서 연기하는 등 다른 많은 기능을 제공합니다. 다음과 같이 테스트 러너의 문서를 확인하십시오.

```bash
$ bin/rails test -h
Usage: rails test [options] [files or directories]

You can run a single test by appending a line number to a filename:

    bin/rails test test/models/user_test.rb:27

You can run multiple files and directories at the same time:

    bin/rails test test/controllers test/integration/login_test.rb

By default test failures and errors are reported inline during a run.

minitest options:
    -h, --help                       Display this help.
        --no-plugins                 Bypass minitest plugin auto-loading (or set $MT_NO_PLUGINS).
    -s, --seed SEED                  Sets random seed. Also via env. Eg: SEED=n rake
    -v, --verbose                    Verbose. Show progress processing files.
    -n, --name PATTERN               Filter run on /regexp/ or string.
        --exclude PATTERN            Exclude /regexp/ or string from run.

Known extensions: rails, pride
    -w, --warnings                   Run with Ruby warnings enabled
    -e, --environment ENV            Run tests in the ENV environment
    -b, --backtrace                  Show the complete backtrace
    -d, --defer-output               Output test failures and errors after the test run
    -f, --fail-fast                  Abort test run on first failure or error
    -c, --[no-]color                 Enable color in the output
    -p, --pride                      Pride. Show your testing pride!
```
### CI에서 테스트 실행하기

CI 환경에서 모든 테스트를 실행하려면 하나의 명령어만 필요합니다:

```bash
$ bin/rails test
```

[System Tests](#system-testing)를 사용하는 경우 `bin/rails test`는 실행되지 않습니다. 시간이 오래 걸릴 수 있기 때문입니다. 이를 실행하려면 `bin/rails test:system`을 실행하는 다른 CI 단계를 추가하거나, 모든 테스트(시스템 테스트 포함)를 실행하는 `bin/rails test:all`로 첫 번째 단계를 변경하십시오.

병렬 테스트
----------------

병렬 테스트를 통해 테스트 스위트를 병렬화할 수 있습니다. 프로세스를 포크하는 것이 기본 방법이지만, 스레딩도 지원됩니다. 병렬로 테스트를 실행하면 전체 테스트 스위트를 실행하는 시간이 줄어듭니다.

### 프로세스를 사용한 병렬 테스트

기본 병렬화 방법은 Ruby의 DRb 시스템을 사용하여 프로세스를 포크하는 것입니다. 프로세스는 제공된 워커 수에 따라 포크됩니다. 기본값은 사용 중인 기기의 실제 코어 수입니다. 그러나 parallelize 메소드에 전달된 숫자로 변경할 수 있습니다.

병렬화를 활성화하려면 `test_helper.rb`에 다음을 추가하십시오:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

전달된 워커 수는 프로세스가 포크될 횟수입니다. 로컬 테스트 스위트와 CI를 병렬화하는 방식을 다르게 설정하려면, 테스트 실행에 사용할 워커 수를 쉽게 변경할 수 있도록 환경 변수가 제공됩니다:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

테스트를 병렬화할 때 Active Record는 각 프로세스에 대해 데이터베이스를 생성하고 데이터베이스에 스키마를 로드하는 작업을 자동으로 처리합니다. 데이터베이스는 해당 워커에 해당하는 숫자로 접미사가 붙습니다. 예를 들어, 2개의 워커가 있는 경우 테스트는 각각 `test-database-0` 및 `test-database-1`을 생성합니다.

전달된 워커 수가 1 이하인 경우 프로세스는 포크되지 않고 테스트는 병렬화되지 않으며 원래의 `test-database` 데이터베이스를 사용합니다.

두 개의 훅이 제공됩니다. 하나는 프로세스가 포크될 때 실행되고, 다른 하나는 포크된 프로세스가 닫히기 전에 실행됩니다. 이러한 훅은 앱이 여러 데이터베이스를 사용하거나 워커 수에 따라 다른 작업을 수행하는 경우 유용할 수 있습니다.

`parallelize_setup` 메소드는 프로세스가 포크된 직후에 호출됩니다. `parallelize_teardown` 메소드는 프로세스가 닫히기 전에 호출됩니다.

```ruby
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # 데이터베이스 설정
  end

  parallelize_teardown do |worker|
    # 데이터베이스 정리
  end

  parallelize(workers: :number_of_processors)
end
```

이러한 메소드는 스레드를 사용하여 병렬 테스트를 수행할 때는 필요하지 않으며 사용할 수 없습니다.

### 스레드를 사용한 병렬 테스트

스레드를 사용하거나 JRuby를 사용하는 경우 스레드 병렬화 옵션이 제공됩니다. 스레드 병렬화 옵션은 Minitest의 `Parallel::Executor`를 기반으로 합니다.

병렬화 방법을 포크 대신 스레드를 사용하도록 변경하려면 `test_helper.rb`에 다음을 추가하십시오.

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)
end
```

JRuby나 TruffleRuby에서 생성된 Rails 애플리케이션은 자동으로 `with: :threads` 옵션을 포함합니다.

`parallelize`에 전달된 워커 수는 테스트가 사용할 스레드 수를 결정합니다. 로컬 테스트 스위트와 CI를 병렬화하는 방식을 다르게 설정하려면, 테스트 실행에 사용할 워커 수를 쉽게 변경할 수 있도록 환경 변수가 제공됩니다:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

### 병렬 트랜잭션 테스트

Rails는 테스트 케이스를 테스트가 완료된 후 롤백되는 데이터베이스 트랜잭션으로 자동으로 래핑합니다. 이를 통해 테스트 케이스는 서로 독립적이며 데이터베이스의 변경 사항은 단일 테스트 내에서만 볼 수 있습니다.

스레드에서 병렬 트랜잭션을 실행하는 코드를 테스트하려는 경우, 트랜잭션이 이미 테스트 트랜잭션 아래에 중첩되어 있기 때문에 트랜잭션이 서로 블로킹될 수 있습니다.

`self.use_transactional_tests = false`를 설정하여 테스트 케이스 클래스에서 트랜잭션을 비활성화할 수 있습니다:

```ruby
class WorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "parallel transactions" do
    # 트랜잭션을 생성하는 일부 스레드 시작
  end
end
```

참고: 트랜잭션 테스트가 비활성화된 경우, 테스트가 완료된 후 변경 사항이 자동으로 롤백되지 않으므로 테스트가 생성하는 데이터를 수동으로 정리해야 합니다.

### 테스트 병렬화 임계값

테스트를 병렬로 실행하면 데이터베이스 설정 및 픽스처 로딩과 같은 작업에 오버헤드가 발생합니다. 이로 인해 Rails는 50개 미만의 테스트가 포함된 실행을 병렬화하지 않습니다.

이 임계값을 `test.rb`에서 구성할 수 있습니다:
```ruby
config.active_support.test_parallelization_threshold = 100
```

그리고 테스트 케이스 수준에서 병렬화를 설정할 때:

```ruby
class ActiveSupport::TestCase
  parallelize threshold: 100
end
```

테스트 데이터베이스
-----------------

거의 모든 Rails 애플리케이션은 데이터베이스와 활발하게 상호 작용하며, 결과적으로 테스트도 데이터베이스와 상호 작용해야합니다. 효율적인 테스트를 작성하기 위해서는 이 데이터베이스를 설정하고 샘플 데이터로 채워야하는 방법을 이해해야합니다.

기본적으로 모든 Rails 애플리케이션에는 개발, 테스트 및 프로덕션 세 가지 환경이 있습니다. 각각의 데이터베이스는 `config/database.yml`에서 구성됩니다.

전용 테스트 데이터베이스를 사용하면 테스트 데이터를 격리된 환경에서 설정하고 상호 작용할 수 있습니다. 이렇게하면 테스트에서 개발 또는 프로덕션 데이터베이스의 데이터에 대해 걱정하지 않고도 테스트 데이터를 자유롭게 조작할 수 있습니다.

### 테스트 데이터베이스 스키마 유지

테스트를 실행하려면 테스트 데이터베이스에 현재 스키마가 필요합니다.
테스트 도우미는 테스트 데이터베이스에 보류 중인 마이그레이션 여부를 확인합니다.
`db/schema.rb` 또는 `db/structure.sql`을 테스트 데이터베이스에로드하려고합니다.
마이그레이션이 아직 보류 중인 경우 오류가 발생합니다.
일반적으로이는 스키마가 완전히 마이그레이션되지 않았음을 나타냅니다.
개발 데이터베이스에 대해 마이그레이션 실행 (`bin/rails db:migrate`)을
스키마를 최신 상태로 업데이트합니다.

참고 : 기존 마이그레이션에 수정 사항이있는 경우 테스트 데이터베이스를 다시 빌드해야합니다.
이 작업은 `bin/rails db:test:prepare`를 실행하여 수행 할 수 있습니다.

### 픽스처에 대한 기본 정보

좋은 테스트를 위해서는 테스트 데이터를 설정하는 데 몇 가지 생각을해야합니다.
Rails에서는 이를 정의하고 사용자 정의하는 픽스처를 처리 할 수 있습니다.
[픽스처 API 문서](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)에서 자세한 문서를 찾을 수 있습니다.

#### 픽스처란?

_픽스처_는 샘플 데이터를위한 화려한 용어입니다. 픽스처을 사용하면 테스트가 실행되기 전에 테스트 데이터베이스를 미리 정의 된 데이터로 채울 수 있습니다. 픽스처는 데이터베이스에 독립적이며 YAML로 작성됩니다. 모델 당 하나의 파일이 있습니다.

참고 : 픽스처는 테스트에 필요한 모든 객체를 생성하기 위해 설계되지 않았으며, 일반적인 경우에만 적용할 수있는 기본 데이터에 대해서만 사용될 때 가장 잘 관리됩니다.

`test/fixtures` 디렉토리 아래에서 픽스처를 찾을 수 있습니다. 새로운 모델을 만들기 위해 `bin/rails generate model`을 실행하면 Rails가이 디렉토리에 픽스처 스텁을 자동으로 생성합니다.

#### YAML

YAML 형식의 픽스처는 샘플 데이터를 설명하는 사람 친화적인 방법입니다. 이러한 유형의 픽스처는 **.yml** 파일 확장명을 가지고 있습니다 (예 : `users.yml`).

다음은 샘플 YAML 픽스처 파일입니다.

```yaml
# lo & behold! I am a YAML comment!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Systems development

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: guy with keyboard
```

각 픽스처는 이름 다음에 들여 쓴 콜론으로 구분 된 키 / 값 쌍의 목록이 제공됩니다. 레코드는 일반적으로 공백 줄로 구분됩니다. 첫 번째 열에서 # 문자를 사용하여 픽스처 파일에 주석을 추가 할 수 있습니다.

[연관](/association_basics.html)을 사용하는 경우
두 가지 다른 픽스처 사이에 참조 노드를 정의 할 수 있습니다. 다음은
`belongs_to` / `has_many` 연관을 사용한 예입니다.

```yaml
# test/fixtures/categories.yml
about:
  name: About
```

```yaml
# test/fixtures/articles.yml
first:
  title: Welcome to Rails!
  category: about
```

```yaml
# test/fixtures/action_text/rich_texts.yml
first_content:
  record: first (Article)
  name: content
  body: <div>Hello, from <strong>a fixture</strong></div>
```

`fixtures/articles.yml`에서 찾은 `first` Article의 `category` 키의 값이 `about`이고, `fixtures/action_text/rich_texts.yml`에서 찾은 `first_content` 항목의 `record` 키의 값이 `first (Article)`임에 유의하십시오. 이는 Active Record에게 전자의 경우 `fixtures/categories.yml`에서 찾은 Category `about`를로드하도록하고, 후자의 경우 `fixtures/articles.yml`에서 찾은 Article `first`를로드하도록 Action Text에 알려줍니다.

참고 : 연관을 이름으로 참조하기 위해 연관된 픽스처에 `id:` 속성을 지정하는 대신 픽스처 이름을 사용할 수 있습니다. Rails는 일관된 기본 키를 자동으로 할당합니다. 이 연관 동작에 대한 자세한 내용은 [픽스처 API 문서](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)를 읽어보십시오.

#### 파일 첨부 픽스처

다른 Active Record를 지원하는 모델과 마찬가지로 Active Storage 첨부 레코드는
ActiveRecord::Base 인스턴스에서 상속되므로 픽스처로 채울 수 있습니다.

`thumbnail` 첨부 파일을 가진 `Article` 모델을 고려해보십시오.
픽스처 데이터 YAML과 함께:

```ruby
class Article
  has_one_attached :thumbnail
end
```

```yaml
# test/fixtures/articles.yml
first:
  title: An Article
```
`test/fixtures/files/first.png`에 [image/png][] 인코딩된 파일이 있다고 가정하면, 다음 YAML 픽스처 항목은 관련된 `ActiveStorage::Blob` 및 `ActiveStorage::Attachment` 레코드를 생성합니다:

```yaml
# test/fixtures/active_storage/blobs.yml
first_thumbnail_blob: <%= ActiveStorage::FixtureSet.blob filename: "first.png" %>
```

```yaml
# test/fixtures/active_storage/attachments.yml
first_thumbnail_attachment:
  name: thumbnail
  record: first (Article)
  blob: first_thumbnail_blob
```


#### ERB를 이용한 작업

ERB를 사용하면 템플릿 내에서 루비 코드를 포함할 수 있습니다. YAML 픽스처 형식은 Rails가 픽스처를 로드할 때 ERB로 사전 처리됩니다. 이를 통해 루비를 사용하여 샘플 데이터를 생성하는 데 도움을 받을 수 있습니다. 예를 들어, 다음 코드는 천 개의 사용자를 생성합니다:

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```

#### 픽스처의 동작

Rails는 기본적으로 `test/fixtures` 디렉토리에서 모든 픽스처를 자동으로 로드합니다. 로드 과정은 다음 세 단계로 이루어집니다:

1. 픽스처에 해당하는 테이블에서 기존 데이터를 제거합니다.
2. 테이블에 픽스처 데이터를 로드합니다.
3. 픽스처 데이터를 직접 액세스하려는 경우에 대비해 픽스처 데이터를 메서드로 덤프합니다.

팁: 데이터베이스에서 기존 데이터를 제거하기 위해 Rails는 외래 키 및 체크 제약 조건과 같은 참조 무결성 트리거를 비활성화하려고 시도합니다. 테스트 실행 중 귀찮은 권한 오류가 발생하는 경우, 데이터베이스 사용자가 테스트 환경에서 이러한 트리거를 비활성화할 권한이 있는지 확인하십시오. (PostgreSQL의 경우, 모든 트리거를 비활성화할 수 있는 권한은 슈퍼유저만 가질 수 있습니다. PostgreSQL 권한에 대해 자세히 알아보려면 [여기](https://www.postgresql.org/docs/current/sql-altertable.html)를 참조하십시오).

#### 픽스처는 Active Record 객체입니다

픽스처는 Active Record의 인스턴스입니다. 위의 3번 항목에서 언급한 대로, 테스트 케이스의 로컬 범위로 자동으로 사용 가능한 메서드로 제공되므로 객체에 직접 액세스할 수 있습니다. 예를 들어:

```ruby
# 이름이 david인 픽스처에 대한 User 객체를 반환합니다.
users(:david)

# david의 id라는 속성을 반환합니다.
users(:david).id

# User 클래스에서 사용 가능한 메서드에도 액세스할 수 있습니다.
david = users(:david)
david.call(david.partner)
```

한 번에 여러 개의 픽스처를 가져오려면 픽스처 이름 목록을 전달할 수 있습니다. 예를 들어:

```ruby
# david와 steve 픽스처를 포함하는 배열을 반환합니다.
users(:david, :steve)
```


모델 테스트
-------------

모델 테스트는 애플리케이션의 다양한 모델을 테스트하는 데 사용됩니다.

Rails 모델 테스트는 `test/models` 디렉토리에 저장됩니다. Rails는 모델 테스트 스켈레톤을 생성하기 위한 제너레이터를 제공합니다.

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

모델 테스트는 `ActionMailer::TestCase`와 같은 자체 슈퍼클래스를 갖지 않습니다. 대신 [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)를 상속합니다.

시스템 테스트
--------------

시스템 테스트를 사용하면 실제 또는 헤드리스 브라우저에서 애플리케이션과 사용자 상호작용을 테스트할 수 있습니다. 시스템 테스트는 내부적으로 Capybara를 사용합니다.

Rails 시스템 테스트를 생성하려면 애플리케이션의 `test/system` 디렉토리를 사용합니다. Rails는 시스템 테스트 스켈레톤을 생성하기 위한 제너레이터를 제공합니다.

```bash
$ bin/rails generate system_test users
      invoke test_unit
      create test/system/users_test.rb
```

다음은 새로 생성된 시스템 테스트의 예입니다:

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
end
```

기본적으로 시스템 테스트는 Chrome 브라우저를 사용하는 Selenium 드라이버로 실행되며, 화면 크기는 1400x1400입니다. 다음 섹션에서는 기본 설정을 변경하는 방법에 대해 설명합니다.

### 기본 설정 변경

Rails는 시스템 테스트의 기본 설정을 변경하는 것을 매우 간단하게 만들었습니다. 모든 설정이 추상화되어 테스트 작성에 집중할 수 있습니다.

새로운 애플리케이션이나 스캐폴드를 생성하면 `test` 디렉토리에 `application_system_test_case.rb` 파일이 생성됩니다. 이곳에 시스템 테스트의 모든 구성이 있어야 합니다.

기본 설정을 변경하려면 시스템 테스트가 "구동되는" 기본 설정을 변경하면 됩니다. 예를 들어, Selenium 대신 Cuprite로 드라이버를 변경하려면 `Gemfile`에 `cuprite` 젬을 추가한 다음 `application_system_test_case.rb` 파일에서 다음을 수행하면 됩니다:

```ruby
require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
```

드라이버 이름은 `driven_by`의 필수 인수입니다. `driven_by`에 전달할 수 있는 선택적 인수는 브라우저를 위한 `:using` (이는 Selenium에서만 사용됨), 스크린샷의 크기를 변경하기 위한 `:screen_size` 및 드라이버에서 지원하는 옵션을 설정하는 데 사용할 수 있는 `:options`입니다.
```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```

헤드리스 브라우저를 사용하려면 `:using` 인자에 `headless_chrome` 또는 `headless_firefox`를 추가하여 Headless Chrome 또는 Headless Firefox를 사용할 수 있습니다.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

원격 브라우저를 사용하려면, 예를 들어 [Docker의 Headless Chrome](https://github.com/SeleniumHQ/docker-selenium)를 사용하려면 `options`를 통해 원격 `url`을 추가해야 합니다.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  options = ENV["SELENIUM_REMOTE_URL"].present? ? { url: ENV["SELENIUM_REMOTE_URL"] } : {}
  driven_by :selenium, using: :headless_chrome, options: options
end
```

이 경우에는 `webdrivers` 젬이 더 이상 필요하지 않습니다. 완전히 제거하거나 `Gemfile`에 `require:` 옵션을 추가할 수 있습니다.

```ruby
# ...
group :test do
  gem "webdrivers", require: !ENV["SELENIUM_REMOTE_URL"] || ENV["SELENIUM_REMOTE_URL"].empty?
end
```

이제 원격 브라우저에 연결할 수 있어야 합니다.

```bash
$ SELENIUM_REMOTE_URL=http://localhost:4444/wd/hub bin/rails test:system
```

테스트 중인 애플리케이션이 Docker 컨테이너와 같은 원격에서 실행되는 경우, Capybara는 원격 서버를 호출하는 방법에 대한 추가 입력이 필요합니다.
[원격 서버 호출](https://github.com/teamcapybara/capybara#calling-remote-servers)에 대한 자세한 내용은 Capybara 문서를 참조하십시오.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  def setup
    Capybara.server_host = "0.0.0.0" # 모든 인터페이스에 바인딩
    Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}" if ENV["SELENIUM_REMOTE_URL"].present?
    super
  end
  # ...
end
```

이제 Docker 컨테이너나 CI에서 실행 중인지 여부에 관계없이 원격 브라우저와 서버에 연결할 수 있어야 합니다.

Capybara 구성이 Rails에서 제공하는 것보다 더 많은 설정이 필요한 경우, 이 추가 구성은 `application_system_test_case.rb` 파일에 추가할 수 있습니다.

추가 설정에 대한 자세한 내용은 [Capybara 문서](https://github.com/teamcapybara/capybara#setup)를 참조하십시오.

### 스크린샷 도우미

`ScreenshotHelper`는 테스트의 스크린샷을 캡처하는 데 도움이 되는 도우미입니다.
테스트가 실패한 지점에서 브라우저를 확인하거나 디버깅을 위해 나중에 스크린샷을 확인하는 데 유용합니다.

두 가지 메서드가 제공됩니다: `take_screenshot`과 `take_failed_screenshot`.
`take_failed_screenshot`은 Rails의 `before_teardown` 내에서 자동으로 포함됩니다.

`take_screenshot` 도우미 메서드는 테스트의 어느 곳에서나 포함시켜 브라우저의 스크린샷을 캡처할 수 있습니다.

### 시스템 테스트 구현

이제 블로그 애플리케이션에 시스템 테스트를 추가해 보겠습니다. 인덱스 페이지를 방문하고 새로운 블로그 글을 작성하는 시스템 테스트를 작성하여 시스템 테스트 작성 방법을 보여줄 것입니다.

스캐폴드 생성기를 사용한 경우, 시스템 테스트 스켈레톤이 자동으로 생성되었습니다. 스캐폴드 생성기를 사용하지 않은 경우, 시스템 테스트 스켈레톤을 생성하기 위해 다음 명령을 실행합니다.

```bash
$ bin/rails generate system_test articles
```

위 명령의 출력으로 다음과 같은 테스트 파일 플레이스홀더가 생성되어야 합니다.

```
      invoke  test_unit
      create    test/system/articles_test.rb
```

이제 해당 파일을 열고 첫 번째 어서션을 작성합니다.

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "viewing the index" do
    visit articles_path
    assert_selector "h1", text: "Articles"
  end
end
```

테스트는 블로그 글 목록 페이지에 `h1`이 있는지 확인하고 통과해야 합니다.

시스템 테스트를 실행합니다.

```bash
$ bin/rails test:system
```

참고: 기본적으로 `bin/rails test`를 실행하면 시스템 테스트가 실행되지 않습니다.
실제로 실행하려면 `bin/rails test:system`을 실행해야 합니다.
시스템 테스트를 포함하여 모든 테스트를 실행하려면 `bin/rails test:all`을 실행할 수도 있습니다.

#### 블로그 글 작성 시스템 테스트 작성

이제 블로그에 새로운 글을 작성하는 흐름을 테스트해 보겠습니다.

```ruby
test "should create Article" do
  visit articles_path

  click_on "New Article"

  fill_in "Title", with: "Creating an Article"
  fill_in "Body", with: "Created this article successfully!"

  click_on "Create Article"

  assert_text "Creating an Article"
end
```

첫 번째 단계는 `visit articles_path`를 호출하는 것입니다. 이는 테스트를 블로그 글 목록 페이지로 이동시킵니다.

그런 다음 `click_on "New Article"`은 인덱스 페이지에서 "New Article" 버튼을 찾습니다. 이로써 브라우저가 `/articles/new`로 리디렉션됩니다.

그런 다음 테스트는 지정된 텍스트로 글의 제목과 내용을 채웁니다. 필드를 채운 후 "Create Article"을 클릭하여 데이터베이스에 새로운 글을 생성하는 POST 요청을 보냅니다.

우리는 다시 블로그 글 목록 페이지로 리디렉션되고, 거기에서 새로운 글의 제목이 글 목록 페이지에 있는지 어서션합니다.

#### 다중 화면 크기 테스트

데스크톱 테스트 외에도 모바일 크기에 대한 테스트를 수행하려면, `ActionDispatch::SystemTestCase`를 상속하는 다른 클래스를 생성하고 테스트 스위트에서 사용할 수 있습니다. 이 예제에서는 `/test` 디렉토리에 `mobile_system_test_case.rb`라는 파일을 생성하고 다음 구성을 사용합니다.
```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

이 구성을 사용하려면 `test/system` 내부에 `MobileSystemTestCase`에서 상속받은 테스트를 생성하십시오.
이제 여러 가지 다른 구성을 사용하여 앱을 테스트할 수 있습니다.

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase
  test "인덱스 방문" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### 더 나아가기

시스템 테스트의 아름다움은 통합 테스트와 유사하다는 점입니다.
컨트롤러, 모델 및 뷰와의 사용자 상호 작용을 테스트하지만,
시스템 테스트는 실제 사용자가 사용하는 것처럼 응용 프로그램을 테스트하는 것입니다.
앞으로 사용자가 응용 프로그램에서 수행하는 것과 같은 모든 작업을 테스트할 수 있습니다.
댓글 작성, 기사 삭제, 초안 게시 등.

통합 테스트
-------------------

통합 테스트는 응용 프로그램의 다양한 부분이 상호 작용하는 방식을 테스트하는 데 사용됩니다.
일반적으로 응용 프로그램 내에서 중요한 작업 흐름을 테스트하는 데 사용됩니다.

Rails 통합 테스트를 생성하기 위해 응용 프로그램의 `test/integration` 디렉토리를 사용합니다.
Rails는 통합 테스트 스켈레톤을 생성하기 위한 생성기를 제공합니다.

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

다음은 새로 생성된 통합 테스트의 예입니다.

```ruby
require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

여기서 테스트는 `ActionDispatch::IntegrationTest`에서 상속됩니다. 이를 통해 통합 테스트에서 사용할 수 있는 추가적인 도우미가 제공됩니다.

### 통합 테스트에서 사용 가능한 도우미

`ActionDispatch::IntegrationTest`에서 상속받는 것 외에도, 통합 테스트를 작성할 때 사용할 수 있는 몇 가지 추가적인 도우미가 제공됩니다. 세 가지 카테고리의 도우미에 대해 간단히 소개하겠습니다.

통합 테스트 실행기와 관련된 도우미는 [`ActionDispatch::Integration::Runner`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html)를 참조하십시오.

요청을 수행할 때, [`ActionDispatch::Integration::RequestHelpers`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html)를 사용할 수 있습니다.

세션을 수정하거나 통합 테스트의 상태를 변경해야하는 경우, [`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html)을 참조하십시오.

### 통합 테스트 구현하기

블로그 응용 프로그램에 통합 테스트를 추가해 보겠습니다. 모든 것이 제대로 작동하는지 확인하기 위해 새로운 블로그 글을 작성하는 기본적인 작업 흐름으로 시작하겠습니다.

먼저 통합 테스트 스켈레톤을 생성합니다.

```bash
$ bin/rails generate integration_test blog_flow
```

이 명령의 출력으로 테스트 파일 플레이스홀더가 생성되었는지 확인할 수 있습니다.

```
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

이제 해당 파일을 열고 첫 번째 어서션을 작성합니다.

```ruby
require "test_helper"

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "환영 페이지를 볼 수 있음" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

"Testing Views" 섹션에서 요청의 결과 HTML을 쿼리하기 위해 `assert_select`를 살펴보겠습니다. 이는 요청의 응답을 테스트하기 위해 주요 HTML 요소와 그 내용의 존재를 확인하는 데 사용됩니다.

루트 경로를 방문하면 뷰를 위해 `welcome/index.html.erb`가 렌더링되어야 합니다. 따라서 이 어서션은 통과해야 합니다.

#### 글 작성 통합

블로그에서 새로운 글을 작성하고 결과 글을 볼 수 있는 능력을 테스트해 보겠습니다.

```ruby
test "글 작성 가능" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "글 작성 가능", body: "글을 성공적으로 작성합니다." } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "Title:\n  글 작성 가능"
end
```

이 테스트를 이해하기 위해 테스트를 분석해 보겠습니다.

먼저 Articles 컨트롤러의 `:new` 액션을 호출합니다. 이 응답은 성공적이어야 합니다.

이후 Articles 컨트롤러의 `:create` 액션으로 POST 요청을 보냅니다.

```ruby
post "/articles",
  params: { article: { title: "글 작성 가능", body: "글을 성공적으로 작성합니다." } }
assert_response :redirect
follow_redirect!
```

요청 이후의 두 줄은 새로운 글을 작성할 때 설정한 리디렉션을 처리하기 위한 것입니다.

참고: 리디렉션 이후에 추가 요청을 수행할 계획이 있다면 `follow_redirect!`를 호출하는 것을 잊지 마십시오.

마지막으로 응답이 성공적이었고 새로운 글이 페이지에서 읽을 수 있는지 어서션합니다.

#### 더 나아가기

블로그를 방문하고 새로운 글을 작성하는 매우 작은 작업 흐름을 성공적으로 테스트할 수 있었습니다. 이를 더 발전시키기 위해 댓글 작성, 글 삭제, 댓글 편집 등을 테스트할 수 있습니다. 통합 테스트는 응용 프로그램의 모든 종류의 사용 사례를 실험해 볼 수 있는 좋은 장소입니다.
컨트롤러에 대한 기능 테스트
-------------------------------------

Rails에서 컨트롤러의 다양한 액션을 테스트하는 것은 기능 테스트를 작성하는 한 방법입니다. 컨트롤러는 애플리케이션으로 들어오는 웹 요청을 처리하고 렌더링된 뷰로 응답합니다. 기능 테스트를 작성할 때는 액션이 요청을 처리하는 방식과 예상되는 결과 또는 응답(일부 경우에는 HTML 뷰)을 테스트합니다.

### 기능 테스트에 포함해야 할 내용

다음과 같은 사항을 테스트해야 합니다:

* 웹 요청이 성공했는가?
* 사용자가 올바른 페이지로 리디렉션되었는가?
* 사용자가 성공적으로 인증되었는가?
* 뷰에서 사용자에게 적절한 메시지가 표시되었는가?
* 응답에 올바른 정보가 표시되었는가?

기능 테스트를 실제로 보려면 스캐폴드 생성기를 사용하여 컨트롤러를 생성하면 됩니다:

```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

이렇게 하면 `Article` 리소스에 대한 컨트롤러 코드와 테스트가 생성됩니다.
`test/controllers` 디렉토리의 `articles_controller_test.rb` 파일을 확인할 수 있습니다.

이미 컨트롤러가 있고 기본 액션의 테스트 스캐폴드 코드를 생성하려는 경우 다음 명령을 사용할 수 있습니다:

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

`articles_controller_test.rb` 파일에서 `test_should_get_index`라는 테스트를 살펴보겠습니다.

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

`test_should_get_index` 테스트에서 Rails는 `index`라는 액션에 대한 요청을 시뮬레이션하고 요청이 성공했는지 확인하며 올바른 응답 본문이 생성되었는지도 확인합니다.

`get` 메서드는 웹 요청을 시작하고 결과를 `@response`에 채웁니다. 최대 6개의 인수를 받을 수 있습니다:

* 요청하는 컨트롤러 액션의 URI입니다.
  이는 문자열 또는 라우트 헬퍼(예: `articles_url`) 형식으로 될 수 있습니다.
* `params`: 액션에 전달할 요청 매개변수의 해시로 옵션입니다.
  (예: 쿼리 문자열 매개변수 또는 article 변수).
* `headers`: 요청과 함께 전달될 헤더를 설정합니다.
* `env`: 필요에 따라 요청 환경을 사용자 정의합니다.
* `xhr`: 요청이 Ajax 요청인지 여부입니다. Ajax 요청으로 표시하려면 true로 설정할 수 있습니다.
* `as`: 요청을 다른 콘텐츠 유형으로 인코딩하는 데 사용됩니다.

모든 키워드 인수는 선택 사항입니다.

예: 첫 번째 `Article`에 대한 `:show` 액션을 호출하고 `HTTP_REFERER` 헤더를 전달하는 경우:

```ruby
get article_url(Article.first), headers: { "HTTP_REFERER" => "http://example.com/home" }
```

다른 예: 마지막 `Article`에 대한 `:update` 액션을 호출하고 `params`의 `title`에 대한 새로운 텍스트를 Ajax 요청으로 전달하는 경우:

```ruby
patch article_url(Article.last), params: { article: { title: "updated" } }, xhr: true
```

하나 더 예: 새로운 article을 생성하기 위해 `:create` 액션을 호출하고 `params`의 `title`에 대한 텍스트를 JSON 요청으로 전달하는 경우:

```ruby
post articles_path, params: { article: { title: "Ahoy!" } }, as: :json
```

참고: `articles_controller_test.rb`의 `test_should_create_article` 테스트를 실행하면 새로 추가된 모델 수준의 유효성 검사 때문에 실패합니다.

모든 테스트가 통과하도록 `articles_controller_test.rb`의 `test_should_create_article` 테스트를 수정해 보겠습니다:

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }
  end

  assert_redirected_to article_path(Article.last)
end
```

이제 모든 테스트를 실행해 보면 통과해야 합니다.

참고: [기본 인증](getting_started.html#basic-authentication) 섹션의 단계를 따랐다면 모든 테스트를 통과하려면 모든 요청 헤더에 인증을 추가해야 합니다:

```ruby
post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
```

기능 테스트에 사용할 수 있는 요청 유형

HTTP 프로토콜에 익숙하다면 `get`이 요청 유형 중 하나임을 알고 있을 것입니다. Rails 기능 테스트에서는 다음과 같은 6개의 요청 유형을 지원합니다:

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

모든 요청 유형에 대해 사용할 수 있는 동등한 메서드가 있습니다. 일반적인 C.R.U.D. 애플리케이션에서는 `get`, `post`, `put`, `delete`를 더 자주 사용할 것입니다.
참고: 기능 테스트는 지정된 요청 유형이 액션에서 허용되는지 여부를 확인하지 않습니다. 우리는 결과에 더 관심이 있습니다. 요청 테스트는 이러한 사용 사례를 위해 존재하여 테스트를 더 목적적으로 만듭니다.

### XHR(Ajax) 요청 테스트

Ajax 요청을 테스트하려면 `get`, `post`, `patch`, `put`, `delete` 메서드에 `xhr: true` 옵션을 지정할 수 있습니다. 예를 들어:

```ruby
test "ajax request" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal "hello world", @response.body
  assert_equal "text/javascript", @response.media_type
end
```

### 종말의 세 해시

요청이 수행되고 처리된 후에는 사용할 준비가 된 3개의 해시 객체가 있습니다.

* `cookies` - 설정된 모든 쿠키
* `flash` - 플래시에 있는 모든 객체
* `session` - 세션 변수에 있는 모든 객체

일반적인 해시 객체와 마찬가지로 문자열로 키를 참조하여 값을 액세스할 수 있습니다. 또한 심볼 이름으로도 참조할 수 있습니다. 예를 들어:

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### 사용 가능한 인스턴스 변수

요청이 이루어진 **후**에 기능 테스트에서 세 개의 인스턴스 변수에도 액세스할 수 있습니다.

* `@controller` - 요청을 처리하는 컨트롤러
* `@request` - 요청 객체
* `@response` - 응답 객체


```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Articles", @response.body
  end
end
```

### 헤더 및 CGI 변수 설정

[HTTP 헤더](https://tools.ietf.org/search/rfc2616#section-5.3) 및 [CGI 변수](https://tools.ietf.org/search/rfc3875#section-4.1)는 헤더로 전달할 수 있습니다.

```ruby
# HTTP 헤더 설정
get articles_url, headers: { "Content-Type": "text/plain" } # 사용자 정의 헤더로 요청 시뮬레이션

# CGI 변수 설정
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # 사용자 정의 환경 변수로 요청 시뮬레이션
```

### `flash` 알림 테스트

이전에 언급했듯이, 종말의 세 해시 중 하나는 `flash`입니다.

새로운 Article을 성공적으로 생성할 때마다 블로그 애플리케이션에 `flash` 메시지를 추가하려고 합니다.

`test_should_create_article` 테스트에 다음 단언문을 추가하여 시작해 보겠습니다.

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { title: "Some title" } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal "Article was successfully created.", flash[:notice]
end
```

지금 테스트를 실행하면 실패가 표시됩니다.

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 32266

# Running:

F

Finished in 0.114870s, 8.7055 runs/s, 34.8220 assertions/s.

  1) Failure:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- expected
+++ actual
@@ -1 +1 @@
-"Article was successfully created."
+nil

1 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

이제 컨트롤러에 flash 메시지를 구현해 보겠습니다. `:create` 액션은 이제 다음과 같아야 합니다.

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = "Article was successfully created."
    redirect_to @article
  else
    render "new"
  end
end
```

이제 테스트를 실행하면 통과되는 것을 볼 수 있습니다.

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 18981

# Running:

.

Finished in 0.081972s, 12.1993 runs/s, 48.7972 assertions/s.

1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### 모두 함께 사용하기

이 시점에서 Articles 컨트롤러는 `:index`, `:new`, `:create` 액션을 테스트합니다. 기존 데이터를 처리하는 방법은 어떻게 될까요?

`:show` 액션에 대한 테스트를 작성해 보겠습니다.

```ruby
test "should show article" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

픽스처에 대한 이전 토론에서 기억하는 대로 `articles()` 메서드를 사용하여 Articles 픽스처에 액세스할 수 있습니다.

기존 Article을 삭제하는 방법은 어떨까요?

```ruby
test "should destroy article" do
  article = articles(:one)
  assert_difference("Article.count", -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

기존 Article을 업데이트하는 테스트도 추가할 수 있습니다.

```ruby
test "should update article" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "updated" } }

  assert_redirected_to article_path(article)
  # 업데이트된 데이터를 가져오기 위해 연관성을 다시 로드하고 제목이 업데이트되었는지 확인합니다.
  article.reload
  assert_equal "updated", article.title
end
```

이 세 가지 테스트에서 중복이 보입니다. 모두 동일한 Article 픽스처 데이터에 액세스합니다. `ActiveSupport::Callbacks`에서 제공하는 `setup` 및 `teardown` 메서드를 사용하여 이를 D.R.Y.할 수 있습니다.

테스트는 이제 다음과 같아야 합니다. 간결함을 위해 다른 테스트는 무시합니다.
```ruby
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # 각각의 테스트 전에 호출됨
  setup do
    @article = articles(:one)
  end

  # 각각의 테스트 후에 호출됨
  teardown do
    # 컨트롤러가 캐시를 사용하는 경우, 이후에 재설정하는 것이 좋음
    Rails.cache.clear
  end

  test "should show article" do
    # setup에서 정의한 @article 인스턴스 변수를 재사용
    get article_url(@article)
    assert_response :success
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "should update article" do
    patch article_url(@article), params: { article: { title: "updated" } }

    assert_redirected_to article_path(@article)
    # 업데이트된 데이터를 가져오기 위해 연관된 데이터를 다시 로드하고, title이 업데이트되었는지 확인
    @article.reload
    assert_equal "updated", @article.title
  end
end
```

Rails의 다른 콜백과 마찬가지로 `setup`과 `teardown` 메서드는 블록, 람다 또는 메서드 이름을 전달하여 사용할 수 있습니다.

### 테스트 헬퍼(subtitle)

코드 중복을 피하기 위해 사용자 고유의 테스트 헬퍼를 추가할 수 있습니다.
로그인 헬퍼는 좋은 예입니다:

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "should show profile" do
    # 헬퍼는 이제 모든 컨트롤러 테스트 케이스에서 재사용 가능
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

#### 별도의 파일 사용

헬퍼가 `test_helper.rb`를 혼란스럽게 만드는 경우, 별도의 파일로 추출할 수 있습니다.
`test/lib` 또는 `test/test_helpers`에 저장하는 것이 좋습니다.

```ruby
# test/test_helpers/multiple_assertions.rb
module MultipleAssertions
  def assert_multiple_of_forty_two(number)
    assert (number % 42 == 0), "expected #{number} to be a multiple of 42"
  end
end
```

이러한 헬퍼는 필요한 경우에 명시적으로 요구하고 필요한 경우에 포함시킬 수 있습니다.

```ruby
require "test_helper"
require "test_helpers/multiple_assertions"

class NumberTest < ActiveSupport::TestCase
  include MultipleAssertions

  test "420 is a multiple of forty two" do
    assert_multiple_of_forty_two 420
  end
end
```

또는 해당 부모 클래스에 직접 포함시킬 수도 있습니다.

```ruby
# test/test_helper.rb
require "test_helpers/sign_in_helper"

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

#### 헬퍼 미리 요구하기

`test_helper.rb`에서 헬퍼를 미리 요구하는 것이 편리할 수 있습니다. 이렇게 하면 테스트 파일에서 암시적으로 헬퍼에 액세스할 수 있습니다. 다음과 같이 globbing을 사용하여 이를 수행할 수 있습니다.

```ruby
# test/test_helper.rb
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }
```

이렇게 하면 개별 테스트에서 필요한 파일만 수동으로 요구하는 것보다 부팅 시간이 늘어날 수 있습니다.

라우트 테스트
--------------

Rails 애플리케이션의 다른 모든 것과 마찬가지로 라우트를 테스트할 수 있습니다. 라우트 테스트는 `test/controllers/`에 위치하거나 컨트롤러 테스트의 일부입니다.

참고: 애플리케이션이 복잡한 라우트를 가지고 있는 경우, Rails는 테스트하기 위해 유용한 여러 가지 도우미를 제공합니다.

Rails에서 사용 가능한 라우팅 어설션에 대한 자세한 정보는 [`ActionDispatch::Assertions::RoutingAssertions`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html)의 API 문서를 참조하십시오.

뷰 테스트
-------------

요청에 대한 응답을 테스트하여 주요 HTML 요소와 그 내용의 존재를 확인하는 것은 애플리케이션의 뷰를 테스트하는 일반적인 방법입니다. 라우트 테스트와 마찬가지로, 뷰 테스트는 `test/controllers/`에 위치하거나 컨트롤러 테스트의 일부입니다. `assert_select` 메서드를 사용하여 응답의 HTML 요소를 쿼리할 수 있습니다. 이는 간단하면서도 강력한 구문을 사용합니다.

`assert_select`에는 두 가지 형태가 있습니다:

`assert_select(selector, [equality], [message])`는 선택한 요소에 대해 선택자를 통해 동등성 조건을 충족하는지 확인합니다. 선택자는 CSS 선택자 표현식(String) 또는 치환 값이 있는 표현식일 수 있습니다.

`assert_select(element, selector, [equality], [message])`는 _element_ (Nokogiri::XML::Node 또는 Nokogiri::XML::NodeSet의 인스턴스) 및 해당 하위 요소부터 시작하여 선택한 요소에 대해 선택자를 통해 동등성 조건을 충족하는지 확인합니다.

예를 들어, 다음과 같이 응답의 제목 요소의 내용을 확인할 수 있습니다:

```ruby
assert_select "title", "Welcome to Rails Testing Guide"
```

더 깊이 들어가기 위해 중첩된 `assert_select` 블록을 사용할 수도 있습니다.

다음 예제에서는 외부 블록에서 선택한 요소 컬렉션 내에서 내부 `assert_select`가 실행됩니다:

```ruby
assert_select "ul.navigation" do
  assert_select "li.menu_item"
end
```

선택한 요소 컬렉션은 각 요소에 대해 개별적으로 `assert_select`를 호출할 수 있도록 반복될 수 있습니다.

예를 들어, 응답에 두 개의 정렬된 목록이 포함되어 있고, 각각에는 네 개의 중첩된 목록 요소가 있다면 다음 테스트는 모두 통과합니다.

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

이 주장은 매우 강력합니다. 더 고급 사용법은 [문서](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb)를 참조하십시오.

### 추가적인 뷰 기반 어설션

주로 뷰 테스트에 사용되는 추가적인 어설션들이 있습니다:

| 어설션                                                 | 목적 |
| --------------------------------------------------------- | ------- |
| `assert_select_email`                                     | 이메일 본문에 대한 어설션을 할 수 있습니다. |
| `assert_select_encoded`                                   | 인코딩된 HTML에 대한 어설션을 할 수 있습니다. 이는 각 요소의 내용을 디코딩하고 디코딩되지 않은 요소로 블록을 호출함으로써 수행됩니다.|
| `css_select(selector)` 또는 `css_select(element, selector)` | _selector_로 선택된 모든 요소의 배열을 반환합니다. 두 번째 변형에서는 먼저 기본 _element_와 일치하고 그 자식들 중에서 _selector_ 표현식과 일치하려고 시도합니다. 일치하는 요소가 없으면 두 변형 모두 빈 배열을 반환합니다.|

`assert_select_email`을 사용하는 예제입니다:

```ruby
assert_select_email do
  assert_select "small", "Please click the 'Unsubscribe' link if you want to opt-out."
end
```

테스트 헬퍼
---------------

헬퍼는 뷰에서 사용할 수 있는 메소드를 정의할 수 있는 간단한 모듈입니다.

헬퍼를 테스트하기 위해서는 헬퍼 메소드의 출력이 예상한 대로 일치하는지 확인하기만 하면 됩니다. 헬퍼와 관련된 테스트는 `test/helpers` 디렉토리에 위치합니다.

다음과 같은 헬퍼가 있다고 가정해 봅시다:

```ruby
module UsersHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

다음과 같이 이 메소드의 출력을 테스트할 수 있습니다:

```ruby
class UsersHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

또한, 테스트 클래스가 `ActionView::TestCase`를 확장하므로 `link_to` 또는 `pluralize`와 같은 Rails의 헬퍼 메소드에 액세스할 수 있습니다.

메일러 테스트
--------------------

메일러 클래스를 테스트하기 위해서는 몇 가지 특정 도구가 필요합니다.

### 메일러 테스트하기

메일러 클래스도 다른 Rails 애플리케이션의 모든 부분과 마찬가지로 예상대로 작동하는지 테스트해야 합니다.

메일러 클래스를 테스트하는 목표는 다음과 같습니다:

* 이메일이 처리되고(생성되고 전송되고)
* 이메일 내용이 올바른지(제목, 보낸 사람, 본문 등)
* 올바른 시간에 올바른 이메일이 전송되고 있는지 확인하기

#### 모든 면에서

메일러를 테스트하는 두 가지 측면이 있습니다. 유닛 테스트와 기능 테스트입니다. 유닛 테스트에서는 메일러를 독립적으로 실행하여 엄격하게 제어된 입력과 미리 작성된 값(픽스처)과의 출력을 비교합니다. 기능 테스트에서는 메일러가 생성한 세부 정보를 테스트하는 것보다는 컨트롤러와 모델이 메일러를 올바르게 사용하는지 테스트합니다. 올바른 이메일이 올바른 시간에 전송되었는지를 증명하기 위해 테스트합니다.

### 유닛 테스트

메일러가 예상한 대로 작동하는지 테스트하기 위해 유닛 테스트를 사용하여 메일러의 실제 결과와 미리 작성된 예제와 비교할 수 있습니다.

#### 픽스처의 복수형

메일러의 유닛 테스트를 위해 픽스처는 출력이 어떻게 보여야 하는지의 예제를 제공하는 데 사용됩니다. 이 예제 이메일은 다른 픽스처와 달리 Active Record 데이터가 아니라 예제 이메일이므로 다른 픽스처와 별도의 하위 디렉토리에 보관됩니다. `test/fixtures` 내의 디렉토리 이름은 메일러의 이름과 직접적으로 대응합니다. 따라서 `UserMailer`라는 메일러의 경우 픽스처는 `test/fixtures/user_mailer` 디렉토리에 있어야 합니다.

메일러를 생성한 경우, 생성기는 메일러 액션에 대한 스텁 픽스처를 생성하지 않습니다. 위에서 설명한 대로 직접 파일을 생성해야 합니다.

#### 기본 테스트 케이스

다음은 `UserMailer`라는 메일러의 `invite` 액션을 사용하여 친구에게 초대장을 보내는 메일러를 테스트하는 유닛 테스트입니다. 이는 `invite` 액션에 대한 생성기에 의해 생성된 기본 테스트의 수정 버전입니다.

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 이메일을 생성하고 추가적인 어설션을 위해 저장합니다
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # 이메일을 전송하고, 큐에 추가되었는지 테스트합니다
    assert_emails 1 do
      email.deliver_now
    end

    # 전송된 이메일의 본문이 예상한 내용을 포함하는지 테스트합니다
    assert_equal ["me@example.com"], email.from
    assert_equal ["friend@example.com"], email.to
    assert_equal "You have been invited by me@example.com", email.subject
    assert_equal read_fixture("invite").join, email.body.to_s
  end
end
```
테스트에서는 이메일을 생성하고 반환된 객체를 `email` 변수에 저장합니다. 그런 다음 첫 번째 어설션에서 이메일이 전송되었는지 확인하고, 두 번째 어설션에서는 이메일이 예상한 내용을 포함하는지 확인합니다. `read_fixture` 도우미는 이 파일에서 내용을 읽는 데 사용됩니다.

참고: `email.body.to_s`는 (HTML 또는 텍스트) 부분이 하나만 있는 경우에 나타납니다. 메일러가 둘 다 제공하는 경우에는 `email.text_part.body.to_s` 또는 `email.html_part.body.to_s`를 사용하여 특정 부분에 대한 픽스처를 테스트할 수 있습니다.

`invite` 픽스처의 내용은 다음과 같습니다.

```
Hi friend@example.com,

You have been invited.

Cheers!
```

이제 메일러에 대한 테스트를 작성하는 방법에 대해 조금 더 이해할 시간입니다. `config/environments/test.rb`의 `ActionMailer::Base.delivery_method = :test` 줄은 전송 방법을 테스트 모드로 설정하여 이메일이 실제로 전송되지 않고 (테스트 중에 사용자에게 스팸 메일을 보내지 않기 위해 유용함) 대신에 배열 (`ActionMailer::Base.deliveries`)에 추가되도록 합니다.

참고: `ActionMailer::Base.deliveries` 배열은 `ActionMailer::TestCase` 및 `ActionDispatch::IntegrationTest` 테스트에서만 자동으로 재설정됩니다. 이러한 테스트 케이스 외부에서 깨끗한 상태를 유지하려면 `ActionMailer::Base.deliveries.clear`로 수동으로 재설정할 수 있습니다.

#### 대기 중인 이메일 테스트

`assert_enqueued_email_with` 어설션을 사용하여 이메일이 예상한 메일러 메서드 인수 및/또는 매개변수화된 메일러 매개변수와 함께 대기열에 들어갔는지 확인할 수 있습니다. 이를 통해 `deliver_later` 메서드로 대기열에 들어간 모든 이메일과 일치시킬 수 있습니다.

기본 테스트 케이스와 마찬가지로 이메일을 생성하고 반환된 객체를 `email` 변수에 저장합니다. 다음 예제에서는 인수와/또는 매개변수를 전달하는 여러 가지 변형을 포함합니다.

이 예제는 올바른 인수로 이메일이 대기열에 들어갔는지 확인합니다.

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 이메일을 생성하고 추가적인 어설션을 위해 저장합니다.
    email = UserMailer.create_invite("me@example.com", "friend@example.com")

    # 이메일이 올바른 인수로 대기열에 들어갔는지 테스트합니다.
    assert_enqueued_email_with UserMailer, :create_invite, args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

이 예제는 해시 형태의 인수를 `args`로 전달하여 메일러 메서드의 올바른 이름이 지정된 인수로 대기열에 들어갔는지 확인합니다.

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 이메일을 생성하고 추가적인 어설션을 위해 저장합니다.
    email = UserMailer.create_invite(from: "me@example.com", to: "friend@example.com")

    # 이메일이 올바른 이름이 지정된 인수로 대기열에 들어갔는지 테스트합니다.
    assert_enqueued_email_with UserMailer, :create_invite, args: [{ from: "me@example.com",
                                                                    to: "friend@example.com" }] do
      email.deliver_later
    end
  end
end
```

이 예제는 매개변수화된 메일러가 올바른 매개변수와 인수로 대기열에 들어갔는지 확인합니다. 메일러 매개변수는 `params`로 전달되고 메일러 메서드의 인수는 `args`로 전달됩니다.

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 이메일을 생성하고 추가적인 어설션을 위해 저장합니다.
    email = UserMailer.with(all: "good").create_invite("me@example.com", "friend@example.com")

    # 이메일이 올바른 메일러 매개변수와 인수로 대기열에 들어갔는지 테스트합니다.
    assert_enqueued_email_with UserMailer, :create_invite, params: { all: "good" },
                                                           args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

이 예제는 매개변수화된 메일러가 올바른 매개변수로 대기열에 들어갔는지 테스트하는 대체 방법을 보여줍니다.

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 이메일을 생성하고 추가적인 어설션을 위해 저장합니다.
    email = UserMailer.with(to: "friend@example.com").create_invite

    # 이메일이 올바른 메일러 매개변수로 대기열에 들어갔는지 테스트합니다.
    assert_enqueued_email_with UserMailer.with(to: "friend@example.com"), :create_invite do
      email.deliver_later
    end
  end
end
```

### 기능 및 시스템 테스트

단위 테스트는 이메일의 속성을 테스트하는 데 사용되고, 기능 및 시스템 테스트는 사용자 상호작용이 이메일을 적절하게 전달하도록 테스트하는 데 사용됩니다. 예를 들어, 친구 초대 작업이 이메일을 적절하게 보내는지 확인할 수 있습니다.

```ruby
# 통합 테스트
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    # ActionMailer::Base.deliveries의 차이를 어설션합니다.
    assert_emails 1 do
      post invite_friend_url, params: { email: "friend@example.com" }
    end
  end
end
```

```ruby
# 시스템 테스트
require "test_helper"

class UsersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "inviting a friend" do
    visit invite_users_url
    fill_in "Email", with: "friend@example.com"
    assert_emails 1 do
      click_on "Invite"
    end
  end
end
```

참고: `assert_emails` 메서드는 특정 전송 방법에 종속되지 않으며 `deliver_now` 또는 `deliver_later` 메서드로 전달된 이메일과 함께 작동합니다. 이메일이 명시적으로 대기열에 들어갔는지 어설션하려면 `assert_enqueued_email_with` ([위의 예제 참조](#대기-중인-이메일-테스트)) 또는 `assert_enqueued_emails` 메서드를 사용할 수 있습니다. 자세한 정보는 [여기의 문서](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html)에서 확인할 수 있습니다.
테스트 작업
------------

사용자 정의 작업은 응용 프로그램 내에서 다른 수준에서 대기열에 넣을 수 있으므로,
작업 자체를 테스트해야하며(대기열에 넣을 때의 동작) 다른 엔티티가 올바르게 대기열에 넣는지도 확인해야합니다.

### 기본 테스트 케이스

기본적으로 작업을 생성할 때 `test/jobs` 디렉토리 아래에 연결된 테스트도 생성됩니다. 여기에 청구 작업이 포함된 예제 테스트가 있습니다.

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "계정이 청구됨" do
    BillingJob.perform_now(account, product)
    assert account.reload.charged_for?(product)
  end
end
```

이 테스트는 매우 간단하며 작업이 예상대로 작동했는지만 확인합니다.

### 사용자 정의 어설션 및 다른 구성 요소 내 작업 테스트

Active Job은 테스트의 가독성을 높이기 위해 사용할 수있는 여러 사용자 정의 어설션을 함께 제공합니다. 사용 가능한 어설션의 전체 목록은 [`ActiveJob::TestHelper`](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html)의 API 문서를 참조하십시오.

작업을 호출하는 위치 (예 : 컨트롤러 내부)에서 작업이 올바르게 대기열에 넣어지거나 수행되었는지 확인하는 것은 좋은 관행입니다. 이것은 Active Job이 제공하는 사용자 정의 어설션에서 유용합니다. 예를 들어, 모델 내에서 작업이 대기열에 넣어졌는지 확인할 수 있습니다.

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "청구 작업 예약" do
    assert_enqueued_with(job: BillingJob) do
      product.charge(account)
    end
    assert_not account.reload.charged_for?(product)
  end
end
```

기본 어댑터 인 `:test`는 작업이 대기열에 넣어질 때 작업을 수행하지 않습니다. 작업을 수행하려면 수행하려는 시기를 지정해야합니다.

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "청구 작업 예약" do
    perform_enqueued_jobs(only: BillingJob) do
      product.charge(account)
    end
    assert account.reload.charged_for?(product)
  end
end
```

이전에 수행된 작업 및 대기열에있는 작업은 모든 테스트 실행 전에 지워지므로 각 테스트 범위 내에서 이미 실행 된 작업이 없다고 가정할 수 있습니다.

Action Cable 테스트
--------------------

Action Cable은 응용 프로그램 내에서 다른 수준에서 사용되므로,
채널, 연결 클래스 자체 및 다른 엔티티가 올바른 메시지를 브로드캐스트하는지 테스트해야합니다.

### 연결 테스트 케이스

Action Cable로 새로운 Rails 응용 프로그램을 생성할 때 기본 연결 클래스 (`ApplicationCable::Connection`)에 대한 테스트도 생성됩니다. `test/channels/application_cable` 디렉토리 아래에 있습니다.

연결 테스트는 연결 식별자가 올바르게 할당되었는지 또는 잘못된 연결 요청이 거부되었는지 확인하는 것을 목표로합니다. 다음은 예입니다.

```ruby
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "매개 변수로 연결" do
    # `connect` 메소드를 호출하여 연결이 열리는 것을 시뮬레이션합니다.
    connect params: { user_id: 42 }

    # 테스트에서 `connection`을 통해 연결 개체에 액세스 할 수 있습니다.
    assert_equal connection.user_id, "42"
  end

  test "매개 변수없이 연결 거부" do
    # `assert_reject_connection` 매처를 사용하여
    # 연결이 거부되었는지 확인합니다.
    assert_reject_connection { connect }
  end
end
```

통합 테스트와 동일한 방식으로 요청 쿠키를 지정할 수도 있습니다.

```ruby
test "쿠키로 연결" do
  cookies.signed[:user_id] = "42"

  connect

  assert_equal connection.user_id, "42"
end
```

자세한 내용은 [`ActionCable::Connection::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html)의 API 문서를 참조하십시오.

### 채널 테스트 케이스

채널을 생성할 때 기본적으로 `test/channels` 디렉토리 아래에 연결된 테스트도 생성됩니다. 여기에 채팅 채널이 포함된 예제 테스트가 있습니다.

```ruby
require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  test "방을 위한 구독 및 스트림" do
    # `subscribe`를 호출하여 구독 생성을 시뮬레이션합니다.
    subscribe room: "15"

    # 테스트에서 `subscription`을 통해 채널 개체에 액세스 할 수 있습니다.
    assert subscription.confirmed?
    assert_has_stream "chat_15"
  end
end
```

이 테스트는 매우 간단하며 채널이 연결을 특정 스트림에 구독하는지만 확인합니다.

기본 연결 식별자를 지정할 수도 있습니다. 다음은 웹 알림 채널의 예제 테스트입니다.

```ruby
require "test_helper"

class WebNotificationsChannelTest < ActionCable::Channel::TestCase
  test "사용자를 위한 구독 및 스트림" do
    stub_connection current_user: users(:john)

    subscribe

    assert_has_stream_for users(:john)
  end
end
```

자세한 내용은 [`ActionCable::Channel::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html)의 API 문서를 참조하십시오.

### 사용자 정의 어설션 및 다른 구성 요소 내 브로드캐스트 테스트

Action Cable은 테스트의 가독성을 높이기 위해 사용할 수있는 여러 사용자 정의 어설션을 함께 제공합니다. 사용 가능한 어설션의 전체 목록은 [`ActionCable::TestHelper`](https://api.rubyonrails.org/classes/ActionCable/TestHelper.html)의 API 문서를 참조하십시오.

올바른 메시지가 다른 구성 요소 (예 : 컨트롤러 내부)에서 브로드캐스트되었는지 확인하는 것은 좋은 관행입니다. 이것은 Action Cable이 제공하는 사용자 정의 어설션에서 유용합니다. 예를 들어, 모델 내에서는 다음과 같이 확인할 수 있습니다.
```ruby
require "test_helper"

class ProductTest < ActionCable::TestCase
  test "충전 후 상태를 브로드캐스트한다" do
    assert_broadcast_on("products:#{product.id}", type: "charged") do
      product.charge(account)
    end
  end
end
```

`Channel.broadcast_to`로 만들어진 브로드캐스팅을 테스트하려면 `Channel.broadcasting_for`을 사용하여 기본 스트림 이름을 생성해야 합니다:

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end
```

```ruby
# test/jobs/chat_relay_job_test.rb
require "test_helper"

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "방에 메시지를 브로드캐스트한다" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "안녕하세요!") do
      ChatRelayJob.perform_now(room, "안녕하세요!")
    end
  end
end
```

Eager Loading 테스트
---------------------

일반적으로 애플리케이션은 `development` 또는 `test` 환경에서 eager load하지 않아 성능을 향상시킵니다. 그러나 `production` 환경에서는 eager load합니다.

프로젝트의 어떤 파일이든 어떤 이유로든 로드할 수 없는 경우, 배포하기 전에 감지하는 것이 좋습니다.

### 지속적 통합

프로젝트에 CI가 있는 경우 CI에서 eager load하는 것은 애플리케이션이 eager load되는지 확인하는 쉬운 방법입니다.

CI는 일반적으로 테스트 스위트가 실행 중임을 나타내는 환경 변수를 설정합니다. 예를 들어 `CI`일 수 있습니다:

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

Rails 7부터는 새로 생성된 애플리케이션이 기본적으로 이렇게 구성됩니다.

### 베어 테스트 스위트

지속적 통합이 없는 프로젝트인 경우 `Rails.application.eager_load!`를 호출하여 테스트 스위트에서 eager load할 수 있습니다:

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "오류 없이 모든 파일을 eager load한다" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk compliance" do
  it "오류 없이 모든 파일을 eager load한다" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

추가 테스트 자료
----------------------------

### 시간에 따라 변하는 코드 테스트

Rails는 내장된 도우미 메서드를 제공하여 시간에 민감한 코드가 예상대로 작동하는지 확인할 수 있습니다.

다음 예제는 [`travel_to`][travel_to] 도우미를 사용합니다:

```ruby
# 사용자가 등록한 후 한 달 후에 선물을 줄 수 있습니다.
user = User.create(name: "Gaurish", activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?

travel_to Date.new(2004, 11, 24) do
  # `travel_to` 블록 내에서 `Date.current`가 스텁으로 사용됩니다.
  assert_equal Date.new(2004, 10, 24), user.activation_date
  assert user.applicable_for_gifting?
end

# 변경 사항은 `travel_to` 블록 내에서만 표시됩니다.
assert_equal Date.new(2004, 10, 24), user.activation_date
```

더 많은 정보를 보려면 [`ActiveSupport::Testing::TimeHelpers`][time_helpers_api] API 참조를 확인하세요.
[`config.active_support.test_order`]: configuring.html#config-active-support-test-order
[image/png]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types
[travel_to]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to
[time_helpers_api]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html
