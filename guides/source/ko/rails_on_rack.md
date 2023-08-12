**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 48f8290cbf9190673c32a3eb9777acba
Rack의 Rails 통합
=============

이 가이드는 Rails와 Rack의 통합 및 다른 Rack 구성 요소와의 인터페이스에 대해 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* Rails 애플리케이션에서 Rack 미들웨어를 사용하는 방법.
* Action Pack의 내부 미들웨어 스택.
* 사용자 정의 미들웨어 스택을 정의하는 방법.

--------------------------------------------------------------------------------

경고: 이 가이드는 Rack 프로토콜과 미들웨어, URL 맵 및 `Rack::Builder`와 같은 Rack 개념에 대한 작동 지식을 가정합니다.

Rack 소개
--------------------

Rack는 루비로 웹 애플리케이션을 개발하기 위한 최소한의 모듈식 및 적응 가능한 인터페이스를 제공합니다. HTTP 요청과 응답을 가장 간단한 방식으로 래핑함으로써 웹 서버, 웹 프레임워크 및 그 사이(미들웨어라고도 함)의 소프트웨어의 API를 통합하고 정리합니다.

Rack의 작동 방식을 설명하는 것은 이 가이드의 범위를 벗어납니다. Rack의 기본 사항에 익숙하지 않은 경우 [자원](#resources) 섹션을 확인하십시오.

Rack의 Rails 통합
-------------

### Rails 애플리케이션의 Rack 객체

`Rails.application`은 Rails 애플리케이션의 주요 Rack 애플리케이션 객체입니다. Rack 호환 웹 서버는 `Rails.application` 객체를 사용하여 Rails 애플리케이션을 제공해야 합니다.

### `bin/rails server`

`bin/rails server`는 `Rack::Server` 객체를 생성하고 웹 서버를 시작하는 기본 작업을 수행합니다.

다음은 `bin/rails server`가 `Rack::Server`의 인스턴스를 생성하는 방법입니다.

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

`Rails::Server`는 `Rack::Server`를 상속하고 다음과 같이 `Rack::Server#start` 메서드를 호출합니다.

```ruby
class Server < ::Rack::Server
  def start
    # ...
    super
  end
end
```

### `rackup`

Rails의 `bin/rails server` 대신 `rackup`을 사용하려면 Rails 애플리케이션의 루트 디렉토리에 다음을 넣을 수 있습니다.

```ruby
# Rails.root/config.ru
require_relative "config/environment"
run Rails.application
```

그리고 서버를 시작합니다.

```bash
$ rackup config.ru
```

다양한 `rackup` 옵션에 대해 자세히 알아보려면 다음을 실행할 수 있습니다.

```bash
$ rackup --help
```

### 개발 및 자동 재로드

미들웨어는 한 번 로드되고 변경 사항을 모니터링하지 않습니다. 실행 중인 애플리케이션에 변경 사항이 반영되려면 서버를 다시 시작해야 합니다.

Action Dispatcher 미들웨어 스택
----------------------------------

Action Dispatcher의 많은 내부 구성 요소는 Rack 미들웨어로 구현됩니다. `Rails::Application`은 내부 및 외부 미들웨어를 결합하여 완전한 Rails Rack 애플리케이션을 형성하기 위해 `ActionDispatch::MiddlewareStack`을 사용합니다.

참고: `ActionDispatch::MiddlewareStack`은 `Rack::Builder`의 Rails 버전이며, Rails의 요구 사항을 충족하기 위해 더 나은 유연성과 기능을 갖추고 있습니다.

### 미들웨어 스택 검사

Rails에는 미들웨어 스택을 검사하는 편리한 명령이 있습니다.

```bash
$ bin/rails middleware
```

새로 생성된 Rails 애플리케이션의 경우 다음과 같은 결과가 나올 수 있습니다.

```ruby
use ActionDispatch::HostAuthorization
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
use ActionDispatch::ServerTiming
use ActiveSupport::Cache::Strategy::LocalCache::Middleware
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use ActionDispatch::RemoteIp
use Sprockets::Rails::QuietAssets
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use WebConsole::Middleware
use ActionDispatch::DebugExceptions
use ActionDispatch::ActionableExceptions
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::Migration::CheckPending
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ContentSecurityPolicy::Middleware
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
use Rack::TempfileReaper
run MyApp::Application.routes
```

여기에 표시된 기본 미들웨어(및 일부 다른 미들웨어)는 [내부 미들웨어](#internal-middleware-stack) 섹션에서 각각 요약되어 있습니다.

### 미들웨어 스택 구성

Rails은 `application.rb` 또는 환경별 구성 파일 `environments/<environment>.rb`을 통해 미들웨어 스택에 미들웨어를 추가, 제거 및 수정하기 위한 간단한 구성 인터페이스 [`config.middleware`][]를 제공합니다.


#### 미들웨어 추가

다음 중 하나의 방법을 사용하여 미들웨어 스택에 새로운 미들웨어를 추가할 수 있습니다.

* `config.middleware.use(new_middleware, args)` - 새로운 미들웨어를 미들웨어 스택의 맨 아래에 추가합니다.

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - 지정된 기존 미들웨어 앞에 새로운 미들웨어를 미들웨어 스택에 추가합니다.

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - 지정된 기존 미들웨어 뒤에 새로운 미들웨어를 미들웨어 스택에 추가합니다.

```ruby
# config/application.rb

# Rack::BounceFavicon을 맨 아래에 추가
config.middleware.use Rack::BounceFavicon

# ActionDispatch::Executor 다음에 Lifo::Cache를 추가합니다.
# Lifo::Cache에 { page_cache: false } 인수를 전달합니다.
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### 미들웨어 교체

`config.middleware.swap`을 사용하여 미들웨어 스택에서 기존 미들웨어를 교체할 수 있습니다.

```ruby
# config/application.rb

# ActionDispatch::ShowExceptions를 Lifo::ShowExceptions로 교체합니다.
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### 미들웨어 이동

`config.middleware.move_before` 및 `config.middleware.move_after`를 사용하여 미들웨어 스택에서 기존 미들웨어를 이동할 수 있습니다.

```ruby
# config/application.rb

# Lifo::ShowExceptions 앞으로 ActionDispatch::ShowExceptions를 이동합니다.
config.middleware.move_before Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

```ruby
# config/application.rb

# Lifo::ShowExceptions 뒤로 ActionDispatch::ShowExceptions를 이동합니다.
config.middleware.move_after Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

#### 미들웨어 삭제하기
다음 라인을 애플리케이션 구성에 추가하십시오:

```ruby
# config/application.rb
config.middleware.delete Rack::Runtime
```

이제 미들웨어 스택을 검사하면 `Rack::Runtime`이 포함되어 있지 않음을 알 수 있습니다.

```bash
$ bin/rails middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
...
run Rails.application.routes
```

세션 관련 미들웨어를 제거하려면 다음을 수행하십시오:

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash
```

브라우저 관련 미들웨어를 제거하려면,

```ruby
# config/application.rb
config.middleware.delete Rack::MethodOverride
```

존재하지 않는 항목을 삭제하려면 `delete!`를 사용하십시오.

```ruby
# config/application.rb
config.middleware.delete! ActionDispatch::Executor
```

### 내부 미들웨어 스택

Action Controller의 많은 기능은 미들웨어로 구현됩니다. 다음 목록은 각각의 목적을 설명합니다:

**`ActionDispatch::HostAuthorization`**

* DNS 리바인딩 공격으로부터 보호하기 위해 요청을 보낼 수 있는 호스트를 명시적으로 허용합니다. 구성 지침은 [구성 가이드](configuring.html#actiondispatch-hostauthorization)를 참조하십시오.

**`Rack::Sendfile`**

* 서버별로 X-Sendfile 헤더를 설정합니다. [`config.action_dispatch.x_sendfile_header`][] 옵션을 통해 구성할 수 있습니다.


**`ActionDispatch::Static`**

* public 디렉토리에서 정적 파일을 제공하는 데 사용됩니다. [`config.public_file_server.enabled`][]가 `false`인 경우 비활성화됩니다.


**`Rack::Lock`**

* `env["rack.multithread"]` 플래그를 `false`로 설정하고 응용 프로그램을 Mutex로 래핑합니다.

**`ActionDispatch::Executor`**

* 개발 중에 스레드 안전한 코드 다시로드에 사용됩니다.

**`ActionDispatch::ServerTiming`**

* 요청에 대한 성능 측정을 포함하는 [`Server-Timing`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server-Timing) 헤더를 설정합니다.

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* 메모리 캐싱에 사용됩니다. 이 캐시는 스레드 안전하지 않습니다.

**`Rack::Runtime`**

* 요청을 실행하는 데 걸린 시간(초 단위)을 포함하는 X-Runtime 헤더를 설정합니다.

**`Rack::MethodOverride`**

* `params[:_method]`가 설정된 경우 메서드를 재정의할 수 있도록 합니다. PUT 및 DELETE HTTP 메서드 유형을 지원하는 미들웨어입니다.

**`ActionDispatch::RequestId`**

* 고유한 `X-Request-Id` 헤더를 응답에서 사용할 수 있게 하며 `ActionDispatch::Request#request_id` 메서드를 활성화합니다.

**`ActionDispatch::RemoteIp`**

* IP 스푸핑 공격을 확인합니다.

**`Sprockets::Rails::QuietAssets`**

* 자산 요청에 대한 로거 출력을 억제합니다.

**`Rails::Rack::Logger`**

* 요청이 시작되었음을 로그에 알립니다. 요청이 완료되면 모든 로그를 플러시합니다.

**`ActionDispatch::ShowExceptions`**

* 응용 프로그램에서 반환된 예외를 구조화된 형식으로 래핑하는 예외 앱을 호출하여 예외를 복구합니다.

**`ActionDispatch::DebugExceptions`**

* 요청이 로컬인 경우 예외를 로깅하고 디버깅 페이지를 표시하는 데 책임이 있습니다.

**`ActionDispatch::ActionableExceptions`**

* Rails의 오류 페이지에서 작업을 디스패치하는 방법을 제공합니다.

**`ActionDispatch::Reloader`**

* 개발 중에 코드 다시로드를 지원하기 위한 준비 및 정리 콜백을 제공합니다.

**`ActionDispatch::Callbacks`**

* 요청을 디스패치하기 전후에 실행될 콜백을 제공합니다.

**`ActiveRecord::Migration::CheckPending`**

* 보류 중인 마이그레이션을 확인하고 보류 중인 마이그레이션이 있는 경우 `ActiveRecord::PendingMigrationError`를 발생시킵니다.

**`ActionDispatch::Cookies`**

* 요청에 대한 쿠키를 설정합니다.

**`ActionDispatch::Session::CookieStore`**

* 세션을 쿠키에 저장하는 데 책임이 있습니다.

**`ActionDispatch::Flash`**

* 플래시 키를 설정합니다. [`config.session_store`][]가 값을 설정한 경우에만 사용할 수 있습니다.


**`ActionDispatch::ContentSecurityPolicy::Middleware`**

* Content-Security-Policy 헤더를 구성하기 위한 DSL을 제공합니다.

**`Rack::Head`**

* HEAD 요청을 `GET` 요청으로 변환하고 해당 요청을 처리합니다.

**`Rack::ConditionalGet`**

* 페이지가 변경되지 않은 경우 서버가 아무것도 응답하지 않도록 "조건부 `GET`"를 지원합니다.

**`Rack::ETag`**

* 모든 문자열 본문에 ETag 헤더를 추가합니다. ETag는 캐시를 유효성 검사하는 데 사용됩니다.

**`Rack::TempfileReaper`**

* 멀티파트 요청을 버퍼링하는 데 사용되는 임시 파일을 정리합니다.

팁: 위의 미들웨어 중 어떤 것이든 사용자 정의 Rack 스택에서 사용할 수 있습니다.

자원
---------

### Rack 배우기

* [공식 Rack 웹사이트](https://rack.github.io)
* [Rack 소개](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### 미들웨어 이해하기

* [Rack 미들웨어에 대한 Railscast](http://railscasts.com/episodes/151-rack-middleware)
[`config.middleware`]: configuring.html#config-middleware
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.session_store`]: configuring.html#config-session-store
