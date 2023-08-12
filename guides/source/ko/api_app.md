**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fe858c0828e87f595c5d8c23c4b6326e
API 전용 애플리케이션을 위해 Rails 사용하기
===========================================

이 가이드에서는 다음을 배울 수 있습니다:

* Rails가 API 전용 애플리케이션에 제공하는 기능
* Rails를 브라우저 기능 없이 시작하도록 구성하는 방법
* 포함할 미들웨어를 결정하는 방법
* 컨트롤러에서 사용할 모듈을 결정하는 방법

--------------------------------------------------------------------------------

API 애플리케이션이란 무엇인가?
------------------------------

일반적으로 사람들이 "API로 Rails를 사용한다"고 말할 때, 그들은 웹 애플리케이션과 함께 프로그래밍 방식으로 접근 가능한 API를 제공한다는 것을 의미합니다. 예를 들어, GitHub은 [API](https://developer.github.com)를 제공하여 사용자 정의 클라이언트에서 사용할 수 있습니다.

클라이언트 사이드 프레임워크의 등장으로 인해, 더 많은 개발자들이 Rails를 웹 애플리케이션과 다른 네이티브 애플리케이션 간에 공유되는 백엔드를 구축하는 데 사용하고 있습니다.

예를 들어, Twitter는 웹 애플리케이션으로 [공개 API](https://developer.twitter.com/)를 사용하며, 이는 JSON 리소스를 사용하는 정적 사이트로 구축됩니다.

Rails를 사용하여 서버와 폼 및 링크를 통해 통신하는 HTML을 생성하는 대신, 많은 개발자들은 웹 애플리케이션을 JSON API를 사용하는 HTML로 전달되는 단순히 API 클라이언트로 취급하고 JavaScript로 소비하는 방식으로 다루고 있습니다.

이 가이드에서는 API 클라이언트에 JSON 리소스를 제공하는 Rails 애플리케이션을 구축하는 방법을 다룹니다. 이에는 클라이언트 사이드 프레임워크도 포함됩니다.

JSON API를 위해 Rails를 사용하는 이유는 무엇인가요?
------------------------------------------------

Rails를 사용하여 JSON API를 구축하는 것에 대해 생각할 때, 많은 사람들이 가장 먼저 떠오르는 질문은 "Rails를 사용해서 JSON을 생성하는 것은 과하게 복잡하지 않을까요? Sinatra와 같은 것을 사용하는 게 더 좋지 않을까요?"입니다.

매우 간단한 API의 경우에는 사실일 수 있습니다. 그러나 매우 HTML 중심적인 애플리케이션에서도 대부분의 애플리케이션 로직은 뷰 레이어 외부에 존재합니다.

대부분의 사람들이 Rails를 사용하는 이유는, 많은 사소한 결정을 내리지 않고 빠르게 시작할 수 있는 기본 설정을 제공하기 때문입니다.

기본 설정을 제공하는 Rails의 일부 기능을 살펴보겠습니다. 이는 여전히 API 애플리케이션에 적용됩니다.

미들웨어 레이어에서 처리됩니다:

- 리로딩: Rails 애플리케이션은 투명한 리로딩을 지원합니다. 이는 애플리케이션이 커져서 모든 요청마다 서버를 다시 시작하는 것이 불가능해지더라도 작동합니다.
- 개발 모드: Rails 애플리케이션은 개발을 위한 스마트한 기본 설정을 제공하여 생산성을 저하시키지 않고 개발을 쾌적하게 만듭니다.
- 테스트 모드: 개발 모드와 동일합니다.
- 로깅: Rails 애플리케이션은 모든 요청을 로그로 기록합니다. 개발 모드의 로그에는 요청 환경, 데이터베이스 쿼리 및 기본적인 성능 정보가 포함됩니다.
- 보안: Rails는 [IP 스푸핑 공격](https://en.wikipedia.org/wiki/IP_address_spoofing)을 탐지하고 방지하며, [타이밍 공격](https://en.wikipedia.org/wiki/Timing_attack)에서 암호 서명을 처리합니다. IP 스푸핑 공격이나 타이밍 공격이 무엇인지 모르시나요? 정확히 그렇습니다.
- 매개변수 구문 분석: 매개변수를 URL 인코딩된 문자열 대신 JSON으로 지정하고 싶나요? 문제 없습니다. Rails는 JSON을 디코딩하고 `params`에서 사용할 수 있도록 해줍니다. 중첩된 URL 인코딩된 매개변수를 사용하고 싶나요? 그것도 가능합니다.
- 조건부 GET: Rails는 조건부 `GET` (`ETag` 및 `Last-Modified`) 처리 요청 헤더를 처리하고 올바른 응답 헤더와 상태 코드를 반환합니다. 컨트롤러에서 [`stale?`](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F)를 사용하기만 하면, Rails가 모든 HTTP 세부 사항을 처리해줍니다.
- HEAD 요청: Rails는 `HEAD` 요청을 투명하게 `GET` 요청으로 변환하고 응답에서 헤더만 반환합니다. 이로 인해 `HEAD` 요청이 모든 Rails API에서 신뢰성 있게 작동합니다.

물론 기존 Rack 미들웨어를 기반으로 이러한 기능을 구축할 수도 있지만, 이 목록은 "단순히 JSON을 생성하는" 경우에도 기본 Rails 미들웨어 스택이 많은 가치를 제공한다는 것을 보여줍니다.

Action Pack 레이어에서 처리됩니다:

- 리소스 기반 라우팅: RESTful JSON API를 구축하는 경우, Rails 라우터를 사용해야 합니다. HTTP에서 컨트롤러로의 깔끔하고 전통적인 매핑은 HTTP를 기반으로 API를 모델링하는 방법에 대해 생각할 필요가 없음을 의미합니다.
- URL 생성: 라우팅의 반대입니다. HTTP를 기반으로 한 좋은 API는 URL을 포함해야 합니다 (예: [GitHub Gist API](https://docs.github.com/en/rest/reference/gists) 참조).
- 헤더 및 리다이렉션 응답: `head :no_content` 및 `redirect_to user_url(current_user)`가 유용합니다. 물론 수동으로 응답 헤더를 추가할 수도 있지만, 왜 그렇게 해야 할까요?
- 캐싱: Rails는 페이지, 액션 및 프래그먼트 캐싱을 제공합니다. 프래그먼트 캐싱은 중첩된 JSON 객체를 구축할 때 특히 유용합니다.
- 기본, 다이제스트 및 토큰 인증: Rails는 세 가지 종류의 HTTP 인증을 기본으로 제공합니다.
- Instrumentation: Rails에는 액션 처리, 파일 또는 데이터 전송, 리다이렉션 및 데이터베이스 쿼리와 같은 다양한 이벤트에 대해 등록된 핸들러를 트리거하는 Instrumentation API가 있습니다. 각 이벤트의 페이로드에는 관련 정보가 포함됩니다 (액션 처리 이벤트의 경우, 페이로드에는 컨트롤러, 액션, 매개변수, 요청 형식, 요청 메서드 및 요청의 전체 경로가 포함됩니다).
- 생성기: 자원을 생성하고 모델, 컨트롤러, 테스트 스텁 및 라우트를 한 번에 생성한 다음 추가로 조정하는 것이 편리할 때가 많습니다. 마이그레이션 및 기타 작업도 마찬가지입니다.
- 플러그인: 많은 타사 라이브러리는 Rails를 지원하는 플러그인을 제공하여 라이브러리와 웹 프레임워크를 설정하고 연결하는 비용을 줄이거나 제거합니다. 이는 기본 생성기를 재정의하거나 Rake 작업을 추가하고 Rails의 선택 사항 (로거 및 캐시 백엔드와 같은)을 존중하는 것과 같은 작업을 포함합니다.
물론, Rails 부트 프로세스는 등록된 모든 구성 요소를 함께 연결합니다.
예를 들어, Rails 부트 프로세스는 Active Record를 구성할 때 `config/database.yml` 파일을 사용합니다.

**간단히 말하면**: 뷰 레이어를 제거하더라도 Rails의 어떤 부분이 여전히 적용 가능한지 생각해보지 않았을 수도 있지만, 대부분의 경우에 해당됩니다.

기본 구성
-----------------------

API 서버로 주로 사용될 Rails 애플리케이션을 구축하는 경우, 더 제한된 Rails 하위 집합으로 시작하고 필요에 따라 기능을 추가할 수 있습니다.

### 새로운 애플리케이션 생성

새로운 API Rails 앱을 생성할 수 있습니다:

```bash
$ rails new my_api --api
```

이렇게 하면 주로 브라우저 애플리케이션에서 유용한 미들웨어를 기본적으로 포함하지 않는 더 제한된 미들웨어 세트로 애플리케이션을 구성합니다.
- `ApplicationController`가 `ActionController::Base` 대신 `ActionController::API`를 상속하도록 구성합니다. 마찬가지로, 이렇게 하면 주로 브라우저 애플리케이션에서 사용되는 기능을 제공하는 Action Controller 모듈이 제외됩니다.
- 새로운 리소스를 생성할 때 뷰, 헬퍼 및 에셋을 생성하지 않도록 생성기를 구성합니다.

### 새로운 리소스 생성

새로 생성된 API가 리소스를 생성하는 방법을 확인하기 위해 새로운 Group 리소스를 생성해 보겠습니다. 각 그룹은 이름을 가지게 됩니다.

```bash
$ bin/rails g scaffold Group name:string
```

스캐폴드된 코드를 사용하기 전에 데이터베이스 스키마를 업데이트해야 합니다.

```bash
$ bin/rails db:migrate
```

이제 `GroupsController`를 열어보면 API Rails 앱에서는 JSON 데이터만 렌더링하는 것을 알 수 있습니다. 인덱스 액션에서는 `Group.all`을 쿼리하고 `@groups`라는 인스턴스 변수에 할당한 다음 `:json` 옵션과 함께 `render`에 전달하면 그룹이 자동으로 JSON으로 렌더링됩니다.

```ruby
# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show update destroy ]

  # GET /groups
  def index
    @groups = Group.all

    render json: @groups
  end

  # GET /groups/1
  def show
    render json: @group
  end

  # POST /groups
  def create
    @group = Group.new(group_params)

    if @group.save
      render json: @group, status: :created, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name)
    end
end
```

마지막으로 Rails 콘솔에서 데이터베이스에 몇 개의 그룹을 추가할 수 있습니다:

```irb
irb> Group.create(name: "Rails Founders")
irb> Group.create(name: "Rails Contributors")
```

앱에 데이터가 있으면 서버를 시작하고 <http://localhost:3000/groups.json>을 방문하여 JSON 데이터를 확인할 수 있습니다.

```json
[
{"id":1, "name":"Rails Founders", "created_at": ...},
{"id":2, "name":"Rails Contributors", "created_at": ...}
]
```

기존 애플리케이션 변경

기존 애플리케이션을 API로 변경하려면 다음 단계를 따르십시오.

`config/application.rb`에서 `Application` 클래스 정의의 맨 위에 다음 줄을 추가하십시오.

```ruby
config.api_only = true
```

`config/environments/development.rb`에서 [`config.debug_exception_response_format`][]을 설정하여 개발 모드에서 오류가 발생할 때 응답에 사용되는 형식을 구성하십시오.

디버깅 정보가 포함된 HTML 페이지를 렌더링하려면 `:default` 값을 사용하십시오.

```ruby
config.debug_exception_response_format = :default
```

응답 형식을 유지하면서 디버깅 정보를 렌더링하려면 `:api` 값을 사용하십시오.

```ruby
config.debug_exception_response_format = :api
```

기본적으로 `config.debug_exception_response_format`은 `config.api_only`가 true로 설정되었을 때 `:api`로 설정됩니다.

마지막으로, `app/controllers/application_controller.rb` 내부에서 다음과 같이 변경하십시오.

```ruby
class ApplicationController < ActionController::API
end
```


미들웨어 선택
--------------------

API 애플리케이션은 기본적으로 다음과 같은 미들웨어를 포함합니다:

- `ActionDispatch::HostAuthorization`
- `Rack::Sendfile`
- `ActionDispatch::Static`
- `ActionDispatch::Executor`
- `ActionDispatch::ServerTiming`
- `ActiveSupport::Cache::Strategy::LocalCache::Middleware`
- `Rack::Runtime`
- `ActionDispatch::RequestId`
- `ActionDispatch::RemoteIp`
- `Rails::Rack::Logger`
- `ActionDispatch::ShowExceptions`
- `ActionDispatch::DebugExceptions`
- `ActionDispatch::ActionableExceptions`
- `ActionDispatch::Reloader`
- `ActionDispatch::Callbacks`
- `ActiveRecord::Migration::CheckPending`
- `Rack::Head`
- `Rack::ConditionalGet`
- `Rack::ETag`

더 자세한 정보는 [내부 미들웨어](rails_on_rack.html#internal-middleware-stack) 섹션을 참조하십시오. Rack 가이드에서 제공하는 것입니다.

Active Record를 포함한 다른 플러그인은 추가적인 미들웨어를 추가할 수도 있습니다. 일반적으로 이러한 미들웨어는 구축 중인 애플리케이션의 유형에 대해 알지 못하고 API 전용 Rails 애플리케이션에서 의미가 있습니다.
애플리케이션의 모든 미들웨어 목록을 가져올 수 있습니다.

```bash
$ bin/rails middleware
```

### Rack::Cache 사용

Rails와 함께 사용할 때, `Rack::Cache`는 엔티티와 메타 스토어로 Rails 캐시 스토어를 사용합니다. 이는 예를 들어 Rails 앱에 memcache를 사용하는 경우 내장된 HTTP 캐시가 memcache를 사용할 것을 의미합니다.

`Rack::Cache`를 사용하려면 먼저 `Gemfile`에 `rack-cache` 젬을 추가하고 `config.action_dispatch.rack_cache`를 `true`로 설정해야 합니다. 기능을 활성화하려면 컨트롤러에서 `stale?`을 사용해야 합니다. 다음은 `stale?`을 사용하는 예입니다.

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

`stale?` 호출은 요청의 `If-Modified-Since` 헤더를 `@post.updated_at`과 비교합니다. 헤더가 마지막 수정보다 최신인 경우 이 액션은 "304 Not Modified" 응답을 반환합니다. 그렇지 않으면 응답을 렌더링하고 `Last-Modified` 헤더를 포함합니다.

일반적으로 이 메커니즘은 클라이언트별로 사용됩니다. `Rack::Cache`를 사용하면 여러 클라이언트 간에 이 캐싱 메커니즘을 공유할 수 있습니다. `stale?` 호출에서 교차 클라이언트 캐싱을 활성화할 수 있습니다.

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end
end
```

이렇게 하면 `Rack::Cache`는 URL의 `Last-Modified` 값을 Rails 캐시에 저장하고 동일한 URL에 대한 후속 들어오는 요청에 `If-Modified-Since` 헤더를 추가합니다.

HTTP 의미론을 사용하는 페이지 캐싱으로 생각할 수 있습니다.

### Rack::Sendfile 사용

Rails 컨트롤러 내에서 `send_file` 메서드를 사용하면 `X-Sendfile` 헤더가 설정됩니다. `Rack::Sendfile`은 실제 파일 전송 작업을 처리합니다.

프론트엔드 서버가 가속화된 파일 전송을 지원하는 경우, `Rack::Sendfile`은 실제 파일 전송 작업을 프론트엔드 서버로 오프로드합니다.

프론트엔드 서버가 이 목적을 위해 사용하는 헤더의 이름을 [`config.action_dispatch.x_sendfile_header`][]를 사용하여 해당 환경의 구성 파일에서 구성할 수 있습니다.

인기있는 프론트엔드와 함께 `Rack::Sendfile`을 사용하는 방법에 대해 자세히 알아보려면 [Rack::Sendfile 문서](https://www.rubydoc.info/gems/rack/Rack/Sendfile)를 참조하세요.

다음은 가속화된 파일 전송을 지원하는 경우이 헤더에 대한 몇 가지 값입니다:

```ruby
# Apache와 lighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

`Rack::Sendfile` 문서의 지침에 따라 서버를 이러한 옵션을 지원하도록 구성해야 합니다.

### ActionDispatch::Request 사용

`ActionDispatch::Request#params`는 JSON 형식의 클라이언트에서 매개변수를 가져와 컨트롤러 내에서 `params`로 사용할 수 있게 합니다.

이를 사용하려면 클라이언트는 JSON으로 인코딩된 매개변수를 사용하여 요청을 보내고 `Content-Type`을 `application/json`으로 지정해야 합니다.

다음은 jQuery를 사용한 예입니다.

```js
jQuery.ajax({
  type: 'POST',
  url: '/people',
  dataType: 'json',
  contentType: 'application/json',
  data: JSON.stringify({ person: { firstName: "Yehuda", lastName: "Katz" } }),
  success: function(json) { }
});
```

`ActionDispatch::Request`는 `Content-Type`을 확인하고 매개변수는 다음과 같습니다.

```ruby
{ person: { firstName: "Yehuda", lastName: "Katz" } }
```

### 세션 미들웨어 사용

API 앱에서는 세션을 사용하지 않아도 되기 때문에 세션 관리에 사용되는 다음 미들웨어가 제외됩니다. 그러나 API 클라이언트 중 하나가 브라우저인 경우 다시 추가할 수 있습니다:

- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

이러한 미들웨어를 다시 추가하려면 기본적으로 `session_options`가 전달되므로 `session_store.rb` 초기화 파일을 추가하고 `use ActionDispatch::Session::CookieStore`를 추가하여 세션을 평소와 같이 사용할 수 없습니다. (명확하게 말하면 세션은 작동할 수 있지만 세션 옵션은 무시됩니다. 즉, 세션 키는 `_session_id`로 기본 설정됩니다.)

초기화 파일 대신에 관련 옵션을 미들웨어가 빌드되기 전에 어딘가에 설정하고 선호하는 미들웨어에 전달해야 합니다. 다음과 같이 수행할 수 있습니다.

```ruby
# 이렇게 하면 아래에서 사용할 session_options도 구성됩니다.
config.session_store :cookie_store, key: '_interslice_session'

# 모든 세션 관리에 필요합니다 (session_store에 관계없이)
config.middleware.use ActionDispatch::Cookies

config.middleware.use config.session_store, config.session_options
```

### 기타 미들웨어

Rails에는 API 애플리케이션에서 사용할 수 있는 다른 여러 미들웨어가 포함되어 있습니다. 특히 API 클라이언트 중 하나가 브라우저인 경우 사용할 수 있습니다:

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`

이러한 미들웨어 중 하나를 추가하려면 다음과 같이 할 수 있습니다.

```ruby
config.middleware.use Rack::MethodOverride
```

### 미들웨어 제거

API 전용 미들웨어 세트에 기본적으로 포함된 사용하지 않을 미들웨어가 있는 경우 다음과 같이 제거할 수 있습니다.
```ruby
config.middleware.delete ::Rack::Sendfile
```

이러한 미들웨어를 제거하면 Action Controller에서 특정 기능의 지원이 제거됩니다.

컨트롤러 모듈 선택하기
---------------------------

API 애플리케이션 (`ActionController::API`를 사용)은 기본적으로 다음과 같은 컨트롤러 모듈을 제공합니다:

|   |   |
|---|---|
| `ActionController::UrlFor` | `url_for` 및 유사한 도우미 사용 가능 |
| `ActionController::Redirecting` | `redirect_to` 지원 |
| `AbstractController::Rendering` 및 `ActionController::ApiRendering` | 렌더링 기본 지원 |
| `ActionController::Renderers::All` | `render :json` 및 관련 기능 지원 |
| `ActionController::ConditionalGet` | `stale?` 지원 |
| `ActionController::BasicImplicitRender` | 명시적인 응답이 없는 경우 빈 응답 반환 |
| `ActionController::StrongParameters` | Active Model 대량 할당과 조합하여 매개변수 필터링 지원 |
| `ActionController::DataStreaming` | `send_file` 및 `send_data` 지원 |
| `AbstractController::Callbacks` | `before_action` 및 유사한 도우미 지원 |
| `ActionController::Rescue` | `rescue_from` 지원 |
| `ActionController::Instrumentation` | Action Controller에서 정의한 계측 후크 지원 (자세한 내용은 [계측 가이드](active_support_instrumentation.html#action-controller) 참조) |
| `ActionController::ParamsWrapper` | 매개변수 해시를 중첩된 해시로 래핑하여 POST 요청을 보낼 때 루트 요소를 지정할 필요가 없도록 함 |
| `ActionController::Head` | 내용이 없는 응답만 헤더로 반환하는 지원 |

다른 플러그인은 추가 모듈을 추가할 수도 있습니다. `ActionController::API`에 포함된 모든 모듈의 목록을 레일즈 콘솔에서 가져올 수 있습니다:

```irb
irb> ActionController::API.ancestors - ActionController::Metal.ancestors
=> [ActionController::API,
    ActiveRecord::Railties::ControllerRuntime,
    ActionDispatch::Routing::RouteSet::MountedHelpers,
    ActionController::ParamsWrapper,
    ... ,
    AbstractController::Rendering,
    ActionView::ViewPaths]
```

### 다른 모듈 추가하기

모든 Action Controller 모듈은 종속 모듈에 대해 알고 있으므로 컨트롤러에 모듈을 포함시키고 모든 종속성이 포함되고 설정됩니다.

추가할 수 있는 일반적인 모듈 몇 가지:

- `AbstractController::Translation`: `l` 및 `t` 로컬라이제이션 및 번역 메서드 지원
- 기본, 다이제스트 또는 토큰 HTTP 인증 지원:
  * `ActionController::HttpAuthentication::Basic::ControllerMethods`
  * `ActionController::HttpAuthentication::Digest::ControllerMethods`
  * `ActionController::HttpAuthentication::Token::ControllerMethods`
- `ActionView::Layouts`: 렌더링할 때 레이아웃 지원
- `ActionController::MimeResponds`: `respond_to` 지원
- `ActionController::Cookies`: `cookies` 지원, 서명 및 암호화된 쿠키 지원. 이를 위해서는 쿠키 미들웨어가 필요합니다.
- `ActionController::Caching`: API 컨트롤러에 대한 뷰 캐싱 지원. 이를 위해 컨트롤러 내에서 캐시 저장소를 수동으로 지정해야 합니다:

    ```ruby
    class ApplicationController < ActionController::API
      include ::ActionController::Caching
      self.cache_store = :mem_cache_store
    end
    ```

    Rails는 이 구성을 자동으로 전달하지 않습니다.

모듈을 추가하는 가장 좋은 위치는 `ApplicationController`입니다. 그러나 개별 컨트롤러에도 모듈을 추가할 수 있습니다.
[`config.debug_exception_response_format`]: configuring.html#config-debug-exception-response-format
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
