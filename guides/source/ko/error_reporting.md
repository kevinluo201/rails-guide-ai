**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e904ad42aee9a68f37b4e79e0b70b685
Rails 애플리케이션에서의 오류 보고
========================

이 가이드는 Ruby on Rails 애플리케이션에서 발생하는 예외를 관리하는 방법을 소개합니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* Rails의 오류 보고기를 사용하여 오류를 캡처하고 보고하는 방법
* 오류 보고 서비스를 위한 사용자 정의 구독자를 만드는 방법

--------------------------------------------------------------------------------

오류 보고
------------------------

Rails [오류 보고기](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html)는 응용 프로그램에서 발생하는 예외를 수집하고 원하는 서비스나 위치로 보고하기 위한 표준 방법을 제공합니다.

오류 보고기는 다음과 같은 보일러플레이트 오류 처리 코드를 대체하는 것을 목표로 합니다:

```ruby
begin
  do_something
rescue SomethingIsBroken => error
  MyErrorReportingService.notify(error)
end
```

일관된 인터페이스로 변경됩니다:

```ruby
Rails.error.handle(SomethingIsBroken) do
  do_something
end
```

Rails는 모든 실행(예: HTTP 요청, 작업 및 `rails runner` 호출)을 오류 보고기로 감싸므로 앱에서 처리되지 않은 오류는 자동으로 오류 보고 서비스로 보고됩니다.

이는 제3자 오류 보고 라이브러리가 더 이상 Rack 미들웨어를 삽입하거나 어떤 monkey-patching도 수행하지 않아도 처리되지 않은 예외를 캡처할 수 있도록 합니다. ActiveSupport를 사용하는 라이브러리는 또한 이를 사용하여 로그에서 이전에 손실되었던 경고를 비침입적으로 보고할 수 있습니다.

Rails의 오류 보고기를 사용하는 것은 필수가 아닙니다. 오류를 캡처하는 다른 방법도 여전히 작동합니다.

### 보고자에 구독하기

오류 보고기를 사용하려면 _구독자_가 필요합니다. 구독자는 `report` 메서드를 가진 모든 객체입니다. 애플리케이션에서 오류가 발생하거나 수동으로 보고될 때 Rails 오류 보고기는 이 메서드를 오류 객체와 일부 옵션과 함께 호출합니다.

[Sentry](https://github.com/getsentry/sentry-ruby/blob/e18ce4b6dcce2ebd37778c1e96164684a1e9ebfc/sentry-rails/lib/sentry/rails/error_subscriber.rb) 및 [Honeybadger](https://docs.honeybadger.io/lib/ruby/integration-guides/rails-exception-tracking/)와 같은 일부 오류 보고 라이브러리는 구독자를 자동으로 등록합니다. 자세한 내용은 공급업체의 문서를 참조하십시오.

사용자 정의 구독자도 만들 수 있습니다. 예를 들어:

```ruby
# config/initializers/error_subscriber.rb
class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    MyErrorReportingService.report_error(error, context: context, handled: handled, level: severity)
  end
end
```

구독자 클래스를 정의한 후 [`Rails.error.subscribe`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-subscribe) 메서드를 호출하여 등록합니다:

```ruby
Rails.error.subscribe(ErrorSubscriber.new)
```

원하는 만큼 많은 구독자를 등록할 수 있습니다. Rails는 등록된 순서대로 차례대로 호출합니다.

참고: Rails 오류 보고기는 환경과 관계없이 항상 등록된 구독자를 호출합니다. 그러나 많은 오류 보고 서비스는 기본적으로 프로덕션에서만 오류를 보고합니다. 필요한대로 환경을 구성하고 테스트해야 합니다.

### 오류 보고기 사용하기

오류 보고기를 사용하는 방법은 세 가지가 있습니다:

#### 오류 보고 및 무시하기

[`Rails.error.handle`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-handle)는 블록 내에서 발생하는 모든 오류를 보고합니다. 그런 다음 오류를 **무시**하고 블록 외부의 코드가 계속 실행됩니다.

```ruby
result = Rails.error.handle do
  1 + '1' # TypeError 발생
end
result # => nil
1 + 1 # 이 코드는 실행됩니다
```

블록 내에서 오류가 발생하지 않으면 `Rails.error.handle`은 블록의 결과를 반환하고, 그렇지 않으면 `nil`을 반환합니다. `fallback`을 제공하여 이를 재정의할 수 있습니다:

```ruby
user = Rails.error.handle(fallback: -> { User.anonymous }) do
  User.find_by(params[:id])
end
```

#### 오류 보고 및 다시 발생하기

[`Rails.error.record`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-record)는 모든 등록된 구독자에게 오류를 보고한 다음 오류를 다시 발생시키므로 코드의 나머지 부분은 실행되지 않습니다.

```ruby
Rails.error.record do
  1 + '1' # TypeError 발생
end
1 + 1 # 이 코드는 실행되지 않습니다
```

블록 내에서 오류가 발생하지 않으면 `Rails.error.record`는 블록의 결과를 반환합니다.

#### 수동으로 오류 보고하기

[`Rails.error.report`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-report)를 호출하여 수동으로 오류를 보고할 수도 있습니다:

```ruby
begin
  # 코드
rescue StandardError => e
  Rails.error.report(e)
end
```

전달하는 옵션은 모든 구독자에게 전달됩니다.

### 오류 보고 옵션

3가지 보고 API(`#handle`, `#record`, `#report`)는 다음과 같은 옵션을 지원하며, 이는 모든 등록된 구독자로 전달됩니다:

- `handled`: 오류가 처리되었는지를 나타내는 `Boolean` 값입니다. 기본값은 `true`입니다. `#record`는 이 값을 `false`로 설정합니다.
- `severity`: 오류의 심각도를 나타내는 `Symbol`입니다. 예상되는 값은 `:error`, `:warning`, `:info`입니다. `#handle`은 이 값을 `:warning`으로 설정하고, `#record`는 `:error`로 설정합니다.
- `context`: 요청이나 사용자 정보와 같은 오류에 대한 추가 컨텍스트를 제공하기 위한 `Hash`입니다.
- `source`: 오류의 소스에 대한 `String`입니다. 기본 소스는 `"application"`입니다. 내부 라이브러리에서 보고된 오류는 다른 소스를 설정할 수 있습니다. 예를 들어 Redis 캐시 라이브러리는 `"redis_cache_store.active_support"`를 사용할 수 있습니다. 구독자는 소스를 사용하여 관심 없는 오류를 무시할 수 있습니다.
```ruby
Rails.error.handle(context: { user_id: user.id }, severity: :info) do
  # ...
end
```

### 에러 클래스로 필터링하기

`Rails.error.handle`과 `Rails.error.record`를 사용하여 특정 클래스의 에러만 보고할 수도 있습니다. 예를 들어:

```ruby
Rails.error.handle(IOError) do
  1 + '1' # TypeError가 발생합니다
end
1 + 1 # TypeError는 IOError가 아니므로 실행되지 않습니다
```

여기에서 `TypeError`는 Rails 에러 리포터에 의해 캡처되지 않습니다. `IOError`와 그 자손 클래스의 인스턴스만 보고됩니다. 다른 에러는 일반적으로 발생합니다.

### 전역 컨텍스트 설정하기

`context` 옵션을 통해 컨텍스트를 설정하는 것 외에도 [`#set_context`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-set_context) API를 사용할 수 있습니다. 예를 들어:

```ruby
Rails.error.set_context(section: "checkout", user_id: @user.id)
```

이 방법으로 설정된 모든 컨텍스트는 `context` 옵션과 병합됩니다.

```ruby
Rails.error.set_context(a: 1)
Rails.error.handle(context: { b: 2 }) { raise }
# 보고된 컨텍스트는: {:a=>1, :b=>2}
Rails.error.handle(context: { b: 3 }) { raise }
# 보고된 컨텍스트는: {:a=>1, :b=>3}
```

### 라이브러리용

에러 리포팅 라이브러리는 `Railtie`에서 구독자를 등록할 수 있습니다:

```ruby
module MySdk
  class Railtie < ::Rails::Railtie
    initializer "my_sdk.error_subscribe" do
      Rails.error.subscribe(MyErrorSubscriber.new)
    end
  end
end
```

에러 구독자를 등록했지만 여전히 Rack 미들웨어와 같은 다른 에러 메커니즘이 있는 경우, 에러가 여러 번 보고될 수 있습니다. 다른 메커니즘을 제거하거나 보고 기능을 조정하여 이전에 본 예외를 보고하지 않도록 설정해야 합니다.
