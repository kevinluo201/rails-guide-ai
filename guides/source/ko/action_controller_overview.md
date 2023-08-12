**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3529115f04b9d5fe01401105d9c154e2
Action Controller 개요
==========================

이 가이드에서는 컨트롤러가 어떻게 작동하며 응용 프로그램의 요청 주기에 어떻게 맞추어지는지에 대해 알아볼 것입니다.

이 가이드를 읽은 후에는 다음을 할 수 있게 될 것입니다:

* 컨트롤러를 통해 요청의 흐름을 따를 수 있습니다.
* 컨트롤러로 전달되는 매개변수를 제한할 수 있습니다.
* 세션이나 쿠키에 데이터를 저장하고 그 이유를 알 수 있습니다.
* 필터를 사용하여 요청 처리 중에 코드를 실행할 수 있습니다.
* Action Controller의 내장 HTTP 인증을 사용할 수 있습니다.
* 데이터를 직접 사용자의 브라우저로 스트리밍할 수 있습니다.
* 민감한 매개변수를 필터링하여 응용 프로그램 로그에 표시되지 않도록 할 수 있습니다.
* 요청 처리 중에 발생할 수 있는 예외를 처리할 수 있습니다.
* 로드 밸런서와 업타임 모니터를 위한 내장된 헬스 체크 엔드포인트를 사용할 수 있습니다.

--------------------------------------------------------------------------------

컨트롤러는 무엇을 하는가?
--------------------------

Action Controller는 [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)에서의 C입니다. 라우터가 요청에 대해 어떤 컨트롤러를 사용할지 결정한 후, 컨트롤러는 요청을 이해하고 적절한 출력을 생성하는 역할을 담당합니다. 다행히도, Action Controller는 대부분의 기본 작업을 대신 처리하고 이를 가능한 간단하게 만들기 위해 스마트한 규칙을 사용합니다.

대부분의 전통적인 [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer) 응용 프로그램에서, 컨트롤러는 요청을 받아 (개발자로서는 보이지 않는) 모델에서 데이터를 가져오거나 저장하고, 뷰를 사용하여 HTML 출력을 생성합니다. 컨트롤러가 약간 다른 방식으로 작업해야 하는 경우에도 문제가 되지 않습니다. 이것은 컨트롤러가 작동하는 가장 일반적인 방법일 뿐입니다.

따라서 컨트롤러는 모델과 뷰 사이의 중간 역할을 수행합니다. 컨트롤러는 모델 데이터를 뷰에 제공하여 사용자에게 해당 데이터를 표시하고, 사용자 데이터를 모델에 저장하거나 업데이트합니다.

참고: 라우팅 프로세스에 대한 자세한 내용은 [Rails Routing from the Outside In](routing.html)을 참조하십시오.

컨트롤러 네이밍 규칙
----------------------------

Rails에서 컨트롤러의 네이밍 규칙은 컨트롤러 이름의 마지막 단어를 복수형으로 하는 것을 선호하지만 (예: `ApplicationController`), 엄격하게 요구되는 것은 아닙니다. 예를 들어, `ClientsController`는 `ClientController`보다 선호되며, `SiteAdminsController`는 `SiteAdminController` 또는 `SitesAdminsController`보다 선호됩니다.

이 규칙을 따르면 기본 라우트 생성기 (예: `resources` 등)를 사용할 때 각 `:path` 또는 `:controller`를 지정할 필요가 없으며, 이름이 지정된 라우트 헬퍼의 사용이 응용 프로그램 전체에서 일관되게 유지됩니다. 자세한 내용은 [Layouts and Rendering Guide](layouts_and_rendering.html)를 참조하십시오.

참고: 컨트롤러 네이밍 규칙은 모델의 네이밍 규칙과 다릅니다. 모델은 단수형으로 지정되어야 한다고 기대됩니다.


메서드와 액션
-------------------

컨트롤러는 `ApplicationController`를 상속하고 다른 클래스와 마찬가지로 메서드를 가지는 루비 클래스입니다. 응용 프로그램이 요청을 받으면 라우팅은 어떤 컨트롤러와 액션을 실행할지 결정하고, Rails는 해당 컨트롤러의 인스턴스를 생성하고 액션과 동일한 이름의 메서드를 실행합니다.

```ruby
class ClientsController < ApplicationController
  def new
  end
end
```

예를 들어, 사용자가 응용 프로그램에서 `/clients/new`로 이동하여 새 클라이언트를 추가하려고 한다면, Rails는 `ClientsController`의 인스턴스를 생성하고 `new` 메서드를 호출합니다. 위의 예제에서 빈 메서드는 문제없이 작동할 것입니다. 왜냐하면 Rails는 액션이 그렇지 않다고 명시하지 않는 한 기본적으로 `new.html.erb` 뷰를 렌더링하기 때문입니다. `new` 메서드에서 새 `Client`를 생성하면 `@client` 인스턴스 변수를 뷰에서 사용할 수 있습니다.

```ruby
def new
  @client = Client.new
end
```

[Layouts and Rendering Guide](layouts_and_rendering.html)에서 이에 대해 더 자세히 설명합니다.

`ApplicationController`은 [`ActionController::Base`][]를 상속하며, 여러 가지 유용한 메서드를 정의합니다. 이 가이드에서는 이 중 일부를 다룰 것이지만, 더 자세한 내용을 보고 싶다면 [API 문서](https://api.rubyonrails.org/classes/ActionController.html)나 소스 자체에서 모두 확인할 수 있습니다.

액션으로 호출할 수 있는 메서드는 공개 메서드만 호출할 수 있습니다. 보조 메서드나 필터와 같이 액션으로 사용되지 않을 메서드의 가시성을 낮추는 것(`private` 또는 `protected`)은 최선의 방법입니다.

경고: 일부 메서드 이름은 Action Controller에 의해 예약되어 있습니다. 이러한 메서드를 액션으로 잘못 재정의하거나 보조 메서드로 재정의하면 `SystemStackError`가 발생할 수 있습니다. 컨트롤러를 RESTful [Resource Routing][] 액션으로 제한한다면 이에 대해 걱정할 필요가 없습니다.

참고: 예약된 메서드를 액션 이름으로 사용해야 하는 경우, 예약되지 않은 액션 메서드에 예약된 메서드 이름을 매핑하는 사용자 정의 라우트를 사용하는 것이 해결 방법 중 하나입니다.
[리소스 라우팅]: routing.html#resource-routing-the-rails-default

매개변수
----------

일반적으로 컨트롤러 액션에서 사용자가 보낸 데이터나 다른 매개변수에 액세스하고 싶을 것입니다. 웹 애플리케이션에서는 두 가지 유형의 매개변수가 가능합니다. 첫 번째는 URL의 일부로 전송되는 매개변수로, 쿼리 문자열 매개변수라고 합니다. 쿼리 문자열은 URL의 "?" 이후의 모든 것입니다. 두 번째 유형의 매개변수는 일반적으로 POST 데이터라고 합니다. 이 정보는 일반적으로 사용자가 작성한 HTML 폼에서 가져옵니다. POST 데이터는 HTTP POST 요청의 일부로만 전송할 수 있기 때문에 POST 데이터라고 합니다. Rails는 쿼리 문자열 매개변수와 POST 매개변수를 구분하지 않으며, 둘 다 컨트롤러의 [`params`][] 해시에서 사용할 수 있습니다:

```ruby
class ClientsController < ApplicationController
  # 이 액션은 HTTP GET 요청으로 실행되기 때문에 쿼리 문자열 매개변수를 사용합니다.
  # 그러나 매개변수에 액세스하는 방법에는 차이가 없습니다.
  # 이 액션의 URL은 활성화된 클라이언트를 나열하기 위해 다음과 같이 보일 것입니다: /clients?status=activated
  def index
    if params[:status] == "activated"
      @clients = Client.activated
    else
      @clients = Client.inactivated
    end
  end

  # 이 액션은 POST 매개변수를 사용합니다. 이 매개변수는 일반적으로 사용자가 제출한 HTML 폼에서 가져옵니다.
  # 이 RESTful 요청의 URL은 "/clients"이고 데이터는 요청 본문의 일부로 전송됩니다.
  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client
    else
      # 이 줄은 "create" 뷰를 렌더링하는 기본 동작을 무시합니다.
      render "new"
    end
  end
end
```


### 해시 및 배열 매개변수

`params` 해시는 1차원 키와 값에 제한되지 않습니다. 중첩된 배열과 해시를 포함할 수 있습니다. 값을 배열로 보내려면 키 이름 뒤에 빈 대괄호 "[]"를 추가하면 됩니다:

```
GET /clients?ids[]=1&ids[]=2&ids[]=3
```

참고: 이 예제에서 실제 URL은 "/clients?ids%5b%5d=1&ids%5b%5d=2&ids%5b%5d=3"로 인코딩됩니다. "["와 "]" 문자는 URL에서 허용되지 않기 때문에 인코딩됩니다. 대부분의 경우 브라우저가 자동으로 인코딩해주고 Rails가 자동으로 디코딩해주기 때문에 이에 대해 걱정할 필요는 없지만, 수동으로 서버에 이러한 요청을 보내야 하는 경우 이를 염두에 두어야 합니다.

`params[:ids]`의 값은 이제 `["1", "2", "3"]`이 됩니다. 매개변수 값은 항상 문자열입니다. Rails는 유추하거나 형 변환을 시도하지 않습니다.

참고: `params`의 `[nil]` 또는 `[nil, nil, ...]`과 같은 값은 기본적으로 보안상의 이유로 `[]`로 대체됩니다. 자세한 내용은 [보안 가이드](security.html#unsafe-query-generation)를 참조하십시오.

해시를 보내려면 대괄호 내에 키 이름을 포함하면 됩니다:

```html
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
```

이 폼을 제출하면 `params[:client]`의 값은 `{ "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } }`가 됩니다. `params[:client][:address]`에 중첩된 해시에 주목하세요.

`params` 객체는 해시처럼 작동하지만, 키로 심볼과 문자열을 상호 교환하여 사용할 수 있습니다.

### JSON 매개변수

애플리케이션이 API를 공개하는 경우, JSON 형식의 매개변수를 수용할 가능성이 높습니다. 요청의 "Content-Type" 헤더가 "application/json"으로 설정되어 있는 경우, Rails는 자동으로 매개변수를 `params` 해시에 로드합니다. 이를 일반적으로 액세스할 수 있습니다.

예를 들어, 다음과 같은 JSON 내용을 보내는 경우:

```json
{ "company": { "name": "acme", "address": "123 Carrot Street" } }
```

컨트롤러는 `params[:company]`를 `{ "name" => "acme", "address" => "123 Carrot Street" }`로 받게 됩니다.

또한, 초기화 파일에서 `config.wrap_parameters`를 활성화하거나 컨트롤러에서 [`wrap_parameters`][]를 호출한 경우, JSON 매개변수에서 루트 요소를 안전하게 생략할 수 있습니다. 이 경우, 매개변수는 복제되고 컨트롤러 이름을 기반으로 선택된 키로 래핑됩니다. 따라서 위의 JSON 요청은 다음과 같이 작성할 수 있습니다:

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

그리고, 데이터를 `CompaniesController`로 보내는 경우, 다음과 같이 `:company` 키 내에 래핑됩니다:
```ruby
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: "123 Carrot Street" } }
```

[API 문서](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)를 참고하여 키의 이름이나 랩핑하려는 특정 매개변수를 사용자 정의할 수 있습니다.

참고: XML 매개변수 구문 분석 지원은 `actionpack-xml_parser`라는 젬으로 추출되었습니다.


### 라우팅 매개변수

`params` 해시에는 항상 `:controller` 및 `:action` 키가 포함되어 있지만, 이러한 값을 액세스하기 위해 [`controller_name`][] 및 [`action_name`][] 메서드를 사용해야 합니다. `:id`와 같이 라우팅에서 정의된 다른 매개변수도 사용할 수 있습니다. 예를 들어, 활성 또는 비활성 클라이언트를 표시하는 클라이언트 목록을 고려해보겠습니다. "예쁜" URL에서 `:status` 매개변수를 캡처하는 라우트를 추가할 수 있습니다:

```ruby
get '/clients/:status', to: 'clients#index', foo: 'bar'
```

이 경우, 사용자가 URL `/clients/active`을 열면 `params[:status]`가 "active"로 설정됩니다. 이 라우트를 사용할 때 `params[:foo]`도 쿼리 문자열로 전달된 것처럼 "bar"로 설정됩니다. 컨트롤러는 또한 `params[:action]`을 "index"로, `params[:controller]`를 "clients"로 받게 됩니다.


### `default_url_options`

컨트롤러에서 `default_url_options`라는 메서드를 정의하여 URL 생성에 대한 전역 기본 매개변수를 설정할 수 있습니다. 이 메서드는 원하는 기본값을 가진 해시를 반환해야 하며, 키는 심볼이어야 합니다:

```ruby
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

이러한 옵션은 URL을 생성할 때 시작점으로 사용되므로 `url_for` 호출에 전달된 옵션에 의해 덮어쓰일 수 있습니다.

위의 예제와 같이 `ApplicationController`에서 `default_url_options`를 정의하면 이러한 기본값이 모든 URL 생성에 사용됩니다. 이 메서드는 특정 컨트롤러에서도 정의할 수 있으며, 이 경우 해당 컨트롤러에서 생성된 URL에만 영향을 줍니다.

한 번의 요청에서는 실제로 생성된 URL마다 이 메서드가 호출되지 않습니다. 성능상의 이유로 반환된 해시는 캐시되며, 요청당 최대 한 번의 호출이 있습니다.

### 강력한 매개변수

강력한 매개변수를 사용하면 액션 컨트롤러 매개변수는 허용되기 전에 Active Model 대량 할당에 사용할 수 없습니다. 이는 사용자가 민감한 모델 속성을 실수로 업데이트할 수 있게 하는 것을 방지하기 위해 명시적으로 허용할 속성을 결정해야 한다는 것을 의미합니다.

또한, 매개변수를 필수로 표시할 수 있으며, 필수 매개변수가 모두 전달되지 않으면 미리 정의된 예외/복구 흐름을 통해 400 Bad Request가 반환됩니다.

```ruby
class PeopleController < ActionController::Base
  # 이것은 명시적인 허가 단계 없이 대량 할당을 사용하므로
  # ActiveModel::ForbiddenAttributesError 예외가 발생합니다.
  def create
    Person.create(params[:person])
  end

  # 이 경우 매개변수에 person 키가 있으면 문제없이 통과되며,
  # 그렇지 않으면 ActionController::ParameterMissing 예외가 발생합니다.
  # 이 예외는 ActionController::Base에서 잡히고 400 Bad Request 오류로 변환됩니다.
  def update
    person = current_account.people.find(params[:id])
    person.update!(person_params)
    redirect_to person
  end

  private
    # 허용할 매개변수를 캡슐화하기 위해 비공개 메서드를 사용하는 것은 좋은 패턴입니다.
    # 이렇게 하면 create와 update 사이에서 동일한 허가 목록을 재사용할 수 있습니다.
    # 또한, 이 메서드를 사용자별로 허용 가능한 속성을 확인하는 데 특화시킬 수도 있습니다.
    def person_params
      params.require(:person).permit(:name, :age)
    end
end
```

#### 허용된 스칼라 값

[`permit`][]을 다음과 같이 호출하면:

```ruby
params.permit(:id)
```

지정된 키(`:id`)가 `params`에 나타나고 허용된 스칼라 값이 연결되어 있다면 해당 키(`:id`)가 포함되도록 허용됩니다. 그렇지 않으면 키는 필터링되므로 배열, 해시 또는 다른 객체를 삽입할 수 없습니다.

허용된 스칼라 유형은 `String`, `Symbol`, `NilClass`, `Numeric`, `TrueClass`, `FalseClass`, `Date`, `Time`, `DateTime`, `StringIO`, `IO`, `ActionDispatch::Http::UploadedFile` 및 `Rack::Test::UploadedFile`입니다.

`params`의 값이 허용된 스칼라 값의 배열이어야 함을 선언하려면 키를 빈 배열로 매핑하십시오:

```ruby
params.permit(id: [])
```

때로는 해시 매개변수나 그 내부 구조의 유효한 키를 선언하는 것이 불가능하거나 편리하지 않을 수 있습니다. 이 경우 빈 해시로 매핑하십시오:

```ruby
params.permit(preferences: {})
```

하지만 이렇게 하면 임의의 입력이 가능해지므로 주의해야 합니다. 이 경우 `permit`은 반환된 구조에서 허용된 스칼라 값을 보장하고 다른 모든 것을 필터링합니다.
전체 매개변수 해시를 허용하기 위해 [`permit!`][] 메서드를 사용할 수 있습니다:

```ruby
params.require(:log_entry).permit!
```

이는 `:log_entry` 매개변수 해시와 그 하위 해시를 허용하며, 허용된 스칼라 값에 대한 확인을 수행하지 않습니다. 어떤 값이든 허용됩니다. `permit!`를 사용할 때는 극도의 주의가 필요합니다. 왜냐하면 현재 및 미래의 모델 속성을 대량 할당할 수 있도록 허용하기 때문입니다.


#### 중첩 매개변수

다음과 같이 중첩 매개변수에 `permit`를 사용할 수도 있습니다:

```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

이 선언은 `name`, `emails`, `friends` 속성을 허용합니다. `emails`는 허용된 스칼라 값의 배열이 될 것으로 예상되며, `friends`는 특정 속성을 가진 리소스의 배열이 될 것으로 예상됩니다. `friends`는 `name` 속성(허용된 스칼라 값 허용), `hobbies` 속성(허용된 스칼라 값의 배열 허용) 및 `family` 속성(여기에도 허용된 스칼라 값 허용)을 가져야 합니다.


#### 추가 예제

`new` 액션에서도 허용된 속성을 사용할 수 있습니다. 이 경우 `require`를 루트 키에 사용할 수 없기 때문에 문제가 발생합니다. 보통 `new`를 호출할 때 루트 키가 존재하지 않기 때문입니다:

```ruby
# `fetch`를 사용하여 기본값을 제공하고
# 거기서 Strong Parameters API를 사용할 수 있습니다.
params.fetch(:blog, {}).permit(:title, :author)
```

모델 클래스 메서드 `accepts_nested_attributes_for`를 사용하면 관련된 레코드를 업데이트하고 삭제할 수 있습니다. 이는 `id` 및 `_destroy` 매개변수를 기반으로 합니다:

```ruby
# :id와 :_destroy를 허용합니다.
params.require(:author).permit(:name, books_attributes: [:title, :id, :_destroy])
```

정수 키를 가진 해시는 다르게 처리되며, 속성을 직접 자식으로 선언할 수 있습니다. 이러한 종류의 매개변수는 `accepts_nested_attributes_for`를 `has_many` 연관과 함께 사용할 때 얻을 수 있습니다:

```ruby
# 다음 데이터를 허용하려면:
# {"book" => {"title" => "Some Book",
#             "chapters_attributes" => { "1" => {"title" => "First Chapter"},
#                                        "2" => {"title" => "Second Chapter"}}}}

params.require(:book).permit(:title, chapters_attributes: [:title])
```

제품 이름을 나타내는 매개변수와 해당 제품과 관련된 임의의 데이터 해시를 가지고 있는 시나리오를 상상해보세요. 제품 이름 속성과 전체 데이터 해시를 허용하려면 다음과 같이 할 수 있습니다:

```ruby
def product_params
  params.require(:product).permit(:name, data: {})
end
```


#### Strong Parameters의 범위를 벗어난 내용

강력한 매개변수 API는 가장 일반적인 사용 사례를 고려하여 설계되었습니다. 이는 모든 매개변수 필터링 문제를 처리하기 위한 마법의 해결책으로 고안된 것은 아닙니다. 그러나 API를 자유롭게 사용자 정의 코드와 혼합하여 상황에 맞게 적용할 수 있습니다.

세션
-------

각 사용자에 대해 응용 프로그램에는 요청 간에 지속되는 작은 양의 데이터를 저장할 수 있는 세션이 있습니다. 세션은 컨트롤러와 뷰에서만 사용할 수 있으며, 다양한 저장 메커니즘 중 하나를 사용할 수 있습니다:

* [`ActionDispatch::Session::CookieStore`][] - 모든 데이터를 클라이언트에 저장합니다.
* [`ActionDispatch::Session::CacheStore`][] - 데이터를 Rails 캐시에 저장합니다.
* [`ActionDispatch::Session::MemCacheStore`][] - 데이터를 memcached 클러스터에 저장합니다(이는 레거시 구현입니다. 대신 `CacheStore`를 사용하는 것이 좋습니다).
* [`ActionDispatch::Session::ActiveRecordStore`][activerecord-session_store] - Active Record를 사용하여 데이터를 데이터베이스에 저장합니다( [`activerecord-session_store`][activerecord-session_store] 젬이 필요합니다).
* 사용자 정의 스토어 또는 제3자 젬에서 제공하는 스토어

모든 세션 스토어는 각 세션에 대한 고유한 ID를 저장하기 위해 쿠키를 사용합니다(보안상의 이유로 세션 ID를 URL에 전달할 수 없습니다).

대부분의 스토어에서는 이 ID를 사용하여 서버에서 세션 데이터를 조회합니다. 예를 들어 데이터베이스 테이블에서 조회합니다. 하나의 예외가 있으며, 바로 기본적이고 권장되는 세션 스토어인 CookieStore입니다. CookieStore는 모든 세션 데이터를 쿠키 자체에 저장합니다(ID는 필요한 경우에도 사용할 수 있습니다). 이 방법은 매우 가볍고, 새로운 응용 프로그램에서 세션을 사용하기 위해 설정을 할 필요가 없습니다. 쿠키 데이터는 암호화되어 위변조 방지를 위해 서명되며, 액세스 권한이 있는 사람은 내용을 읽을 수 없도록 암호화됩니다(Rails는 편집된 경우 쿠키를 수용하지 않습니다).

CookieStore는 약 4 kB의 데이터를 저장할 수 있습니다. 다른 스토어보다 훨씬 적지만, 대부분 충분합니다. 세션에 대량의 데이터를 저장하는 것은 권장되지 않습니다. 특히 모델 인스턴스와 같은 복잡한 객체를 세션에 저장하는 것은 피해야 합니다. 서버가 요청 사이에서 이들을 재조립하지 못할 수 있으므로 오류가 발생할 수 있습니다.
사용자 세션이 중요한 데이터를 저장하지 않거나 오랜 기간 동안 유지되지 않아도 되는 경우 (예: 메시징에만 플래시를 사용하는 경우) `ActionDispatch::Session::CacheStore`를 사용할 수 있습니다. 이렇게 하면 세션을 응용 프로그램에 구성된 캐시 구현을 사용하여 저장할 수 있습니다. 이 방법의 장점은 추가 설정이나 관리 없이 기존의 캐시 인프라를 사용하여 세션을 저장할 수 있다는 것입니다. 단점은 세션이 일시적이며 언제든지 사라질 수 있다는 것입니다.

세션 저장에 대한 자세한 내용은 [보안 가이드](security.html)를 참조하십시오.

다른 세션 저장 메커니즘이 필요한 경우 초기화 파일에서 변경할 수 있습니다:

```ruby
Rails.application.config.session_store :cache_store
```

자세한 내용은 구성 가이드의 [`config.session_store`](configuring.html#config-session-store)를 참조하십시오.

Rails는 세션 데이터에 서명할 때 세션 키 (쿠키의 이름)를 설정합니다. 이를 초기화 파일에서 변경할 수도 있습니다:

```ruby
# 이 파일을 수정할 때 서버를 다시 시작하십시오.
Rails.application.config.session_store :cookie_store, key: '_your_app_session'
```

쿠키에 대한 도메인 이름을 지정하려면 `:domain` 키를 전달할 수도 있습니다:

```ruby
# 이 파일을 수정할 때 서버를 다시 시작하십시오.
Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: ".example.com"
```

Rails는 (CookieStore를 위해) `config/credentials.yml.enc`에 세션 데이터에 서명하는 데 사용되는 비밀 키를 설정합니다. `bin/rails credentials:edit`를 사용하여 이를 변경할 수 있습니다.

```yaml
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# Rails의 모든 MessageVerifiers에 대한 기본 비밀입니다. 이 비밀은 쿠키를 보호하는 데 사용됩니다.
secret_key_base: 492f...
```

참고: `CookieStore`를 사용할 때 `secret_key_base`를 변경하면 기존 세션이 무효화됩니다.



### 세션에 액세스하기

컨트롤러에서 `session` 인스턴스 메서드를 통해 세션에 액세스할 수 있습니다.

참고: 세션은 지연로드됩니다. 액션의 코드에서 세션에 액세스하지 않으면 세션은 로드되지 않습니다. 따라서 세션을 비활성화할 필요는 없으며, 그냥 액세스하지 않으면 됩니다.

세션 값은 해시와 같은 키/값 쌍으로 저장됩니다:

```ruby
class ApplicationController < ActionController::Base
  private
    # :current_user_id 키로 세션에 저장된 ID를 사용하여 User를 찾습니다.
    # 이는 Rails 응용 프로그램에서 사용자 로그인을 처리하는 일반적인 방법입니다.
    # 로그인은 세션 값을 설정하고 로그아웃은 제거합니다.
    def current_user
      @_current_user ||= session[:current_user_id] &&
        User.find_by(id: session[:current_user_id])
    end
end
```

세션에 무언가를 저장하려면 해시처럼 키에 할당하면 됩니다:

```ruby
class LoginsController < ApplicationController
  # 로그인을 "생성"하거나 "사용자를 로그인"합니다.
  def create
    if user = User.authenticate(params[:username], params[:password])
      # 사용자 ID를 세션에 저장하여 후속 요청에서 사용할 수 있도록 합니다.
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end
end
```

세션에서 무언가를 제거하려면 키/값 쌍을 삭제하면 됩니다:

```ruby
class LoginsController < ApplicationController
  # 로그인을 "삭제"하거나 "사용자를 로그아웃"합니다.
  def destroy
    # 세션에서 사용자 ID를 제거합니다.
    session.delete(:current_user_id)
    # 메모이즈된 현재 사용자를 지웁니다.
    @_current_user = nil
    redirect_to root_url, status: :see_other
  end
end
```

전체 세션을 재설정하려면 [`reset_session`][]을 사용하십시오.


### 플래시

플래시는 각 요청마다 지워지는 세션의 특별한 부분입니다. 이는 거기에 저장된 값이 다음 요청에서만 사용할 수 있음을 의미하며, 오류 메시지 등을 전달하는 데 유용합니다.

플래시는 [`flash`][] 메서드를 통해 액세스할 수 있습니다. 세션과 마찬가지로 플래시는 해시로 표현됩니다.

로그아웃하는 행위를 예로 들어보겠습니다. 컨트롤러는 다음 요청에서 사용자에게 표시될 메시지를 보낼 수 있습니다:

```ruby
class LoginsController < ApplicationController
  def destroy
    session.delete(:current_user_id)
    flash[:notice] = "성공적으로 로그아웃되었습니다."
    redirect_to root_url, status: :see_other
  end
end
```

리다이렉션의 일부로 플래시 메시지를 할당하는 것도 가능합니다. `:notice`, `:alert` 또는 일반적인 `:flash`를 할당할 수 있습니다:

```ruby
redirect_to root_url, notice: "성공적으로 로그아웃되었습니다."
redirect_to root_url, alert: "여기에 갇혔습니다!"
redirect_to root_url, flash: { referral_code: 1234 }
```

`destroy` 액션은 응용 프로그램의 `root_url`로 리다이렉션하며, 메시지가 표시됩니다. 이전 액션이 플래시에 넣은 내용을 다음 액션이 어떻게 처리할지는 전적으로 다음 액션에 달려 있습니다. 일반적으로 플래시에서 오류 알림이나 공지를 응용 프로그램의 레이아웃에 표시하는 것이 관례입니다.
```erb
<html>
  <!-- <head/> -->
  <body>
    <% flash.each do |name, msg| -%>
      <%= content_tag :div, msg, class: name %>
    <% end -%>

    <!-- more content -->
  </body>
</html>
```

이렇게하면 액션이 알림 또는 경고 메시지를 설정하면 레이아웃이 자동으로 표시됩니다.

알림과 경고에 제한되지 않고 세션에 저장할 수있는 모든 것을 전달 할 수 있습니다.

```erb
<% if flash[:just_signed_up] %>
  <p class="welcome">Welcome to our site!</p>
<% end %>
```

다른 요청으로 플래시 값을 전달하려면 [`flash.keep`][]를 사용하십시오.

```ruby
class MainController < ApplicationController
  # 이 작업은 root_url에 해당하지만 모든 요청이 여기로 리디렉션되어
  # 다른 리디렉션이 발생 할 때 값이 일반적으로 손실되지만
  # 'keep'을 사용하여 다른 요청에 대해 지속되도록 만들 수 있습니다.
  def index
    # 모든 플래시 값을 유지합니다.
    flash.keep

    # 특정 유형의 값 만 유지하려면 키를 사용할 수도 있습니다.
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```


#### `flash.now`

기본적으로 플래시에 값을 추가하면 다음 요청에서 사용할 수 있지만, 때로는 동일한 요청에서 해당 값을 액세스하고 싶을 수도 있습니다. 예를 들어, `create` 작업이 리소스를 저장하지 못하고 `new` 템플릿을 직접 렌더링하는 경우, 새로운 요청이 발생하지 않을 것이지만 플래시를 사용하여 메시지를 표시 할 수도 있습니다. 이를 위해 일반적인 `flash`와 동일한 방식으로 [`flash.now`][]를 사용할 수 있습니다.

```ruby
class ClientsController < ApplicationController
  def create
    @client = Client.new(client_params)
    if @client.save
      # ...
    else
      flash.now[:error] = "Could not save client"
      render action: "new"
    end
  end
end
```


쿠키
-------

애플리케이션은 클라이언트에 작은 양의 데이터를 저장 할 수 있습니다. 이를 쿠키라고하며, 요청 및 세션 간에 지속됩니다. Rails는 [`cookies`][] 메서드를 통해 쿠키에 쉽게 액세스 할 수 있습니다. 이 메서드는 `session`과 마찬가지로 해시처럼 작동합니다.

```ruby
class CommentsController < ApplicationController
  def new
    # 쿠키에 저장된 경우 댓글 작성자의 이름을 자동으로 채웁니다.
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:notice] = "Thanks for your comment!"
      if params[:remember_name]
        # 댓글 작성자의 이름을 기억합니다.
        cookies[:commenter_name] = @comment.author
      else
        # 댓글 작성자의 이름 쿠키를 삭제합니다.
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

세션 값에 키를 `nil`로 설정할 수 있지만, 쿠키 값을 삭제하려면 `cookies.delete(:key)`를 사용해야합니다.

Rails는 민감한 데이터를 저장하기 위해 서명 된 쿠키 저장소와 암호화 된 쿠키 저장소를 제공합니다. 서명 된 쿠키 저장소는 쿠키 값에 암호화 서명을 추가하여 무결성을 보호합니다. 암호화 된 쿠키 저장소는 서명뿐만 아니라 값을 암호화하여 최종 사용자가 읽을 수 없도록합니다. 자세한 내용은 [API 문서](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html)를 참조하십시오.

이러한 특수 쿠키 저장소는 할당 된 값을 직렬화하여 문자열로 변환하고 읽을 때 Ruby 객체로 역직렬화하기 위해 직렬화기를 사용합니다. [`config.action_dispatch.cookies_serializer`][]를 통해 사용할 직렬화기를 지정할 수 있습니다.

새로운 응용 프로그램의 기본 직렬화기는 `:json`입니다. JSON은 Ruby 객체에 대한 제한된 지원을 제공하는 것을 알아두십시오. 예를 들어, `Date`, `Time` 및 `Symbol` 객체 (해시 키 포함)는 `String`으로 직렬화되고 역직렬화됩니다.

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

이러한 또는 더 복잡한 객체를 저장해야하는 경우 다음 요청에서 이러한 값을 읽을 때 수동으로 값을 변환해야 할 수 있습니다.

쿠키 세션 저장소를 사용하는 경우 위 내용은 `session` 및 `flash` 해시에도 적용됩니다.


렌더링
---------

ActionController를 사용하면 HTML, XML 또는 JSON 데이터를 렌더링하는 것이 간편해집니다. 스캐폴딩을 사용하여 컨트롤러를 생성한 경우 다음과 같이 보일 것입니다.

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @users }
      format.json { render json: @users }
    end
  end
end
```

위 코드에서 `render xml: @users` 대신 `render xml: @users.to_xml`를 사용하지 않는 것을 알 수 있습니다. 객체가 문자열이 아닌 경우 Rails는 자동으로 `to_xml`을 호출합니다.
[레이아웃 및 렌더링 가이드](layouts_and_rendering.html)에서 렌더링에 대해 더 알아볼 수 있습니다.

필터
-------

필터는 컨트롤러 액션 "전", "후" 또는 "주위"에 실행되는 메소드입니다.

필터는 상속됩니다. 따라서 `ApplicationController`에 필터를 설정하면 응용 프로그램의 모든 컨트롤러에서 실행됩니다.

"전" 필터는 [`before_action`][]을 통해 등록됩니다. 요청 주기를 중단할 수 있습니다. 일반적인 "전" 필터는 사용자가 로그인해야만 액션이 실행되도록 요구하는 필터입니다. 필터 메소드는 다음과 같이 정의할 수 있습니다.

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private
    def require_login
      unless logged_in?
        flash[:error] = "이 섹션에 액세스하려면 로그인해야 합니다."
        redirect_to new_login_url # 요청 주기 중단
      end
    end
end
```

이 메소드는 사용자가 로그인되지 않은 경우 플래시에 오류 메시지를 저장하고 로그인 폼으로 리디렉션합니다. "전" 필터가 렌더링하거나 리디렉션하는 경우 액션이 실행되지 않습니다. 해당 필터 이후에 실행될 예정인 추가 필터가 있는 경우에도 취소됩니다.

이 예제에서 필터는 `ApplicationController`에 추가되며 응용 프로그램의 모든 컨트롤러에서 상속됩니다. 이로 인해 응용 프로그램의 모든 것이 사용하려면 사용자가 로그인해야 합니다. (사용자가 처음부터 로그인할 수 없기 때문에!) 모든 컨트롤러 또는 액션이 이를 필요로하지 않아야 합니다. [`skip_before_action`][]을 사용하여 특정 액션 이전에이 필터를 실행하지 않도록 할 수 있습니다.

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

이제 `LoginsController`의 `new` 및 `create` 액션은 사용자가 로그인하지 않아도 작동합니다. `:only` 옵션은 이 필터를 이러한 액션에 대해서만 건너 뛰도록하며, `:except` 옵션은 반대로 작동합니다. 이러한 옵션은 필터를 추가할 때도 사용할 수 있으므로 처음부터 선택한 액션에만 실행되는 필터를 추가할 수 있습니다.

참고: 다른 옵션으로 동일한 필터를 다른 옵션으로 여러 번 호출하는 것은 작동하지 않습니다. 이전 필터 정의가 덮어쓰기되기 때문입니다.


### 후 필터 및 주위 필터

"전" 필터 외에도 액션이 실행된 후에 필터를 실행하거나 액션 전후에 모두 실행할 수 있습니다.

"후" 필터는 [`after_action`][]을 통해 등록됩니다. "전" 필터와 유사하지만, 액션이 이미 실행되었으므로 클라이언트로 전송될 응답 데이터에 액세스할 수 있습니다. 당연히 "후" 필터는 액션 실행을 중지할 수 없습니다. "후" 필터는 성공적인 액션 후에만 실행되며, 요청 주기에서 예외가 발생할 때는 실행되지 않음에 유의하십시오.

"주위" 필터는 [`around_action`][]을 통해 등록됩니다. 연관된 액션을 실행하기 위해 양보하는 방식으로 실행됩니다. 이는 Rack 미들웨어가 작동하는 방식과 유사합니다.

예를 들어, 변경 사항에 승인 워크플로우가 있는 웹 사이트에서 관리자는 트랜잭션 내에서 변경 사항을 쉽게 미리 보기할 수 있습니다.

```ruby
class ChangesController < ApplicationController
  around_action :wrap_in_transaction, only: :show

  private
    def wrap_in_transaction
      ActiveRecord::Base.transaction do
        begin
          yield
        ensure
          raise ActiveRecord::Rollback
        end
      end
    end
end
```

"주위" 필터는 렌더링도 래핑합니다. 특히 위의 예에서 뷰 자체가 데이터베이스에서 읽기 (예 : 스코프를 통해)하는 경우 트랜잭션 내에서 수행되므로 미리 보기 데이터를 표시합니다.

yield하지 않고 직접 응답을 작성하여 액션을 실행하지 않을 수도 있습니다.


### 필터 사용하는 다른 방법

필터를 사용하는 가장 일반적인 방법은 개인 메소드를 생성하고 `before_action`, `after_action` 또는 `around_action`을 사용하여 필터를 추가하는 것입니다. 그러나 동일한 작업을 수행하는 두 가지 다른 방법이 있습니다.

첫 번째 방법은 블록을 `*_action` 메소드와 함께 직접 사용하는 것입니다. 블록은 컨트롤러를 인수로 받습니다. 위의 `require_login` 필터는 블록을 사용하여 다음과 같이 다시 작성할 수 있습니다.

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless controller.send(:logged_in?)
      flash[:error] = "이 섹션에 액세스하려면 로그인해야 합니다."
      redirect_to new_login_url
    end
  end
end
```

이 경우 필터는 `send`를 사용하여 컨트롤러의 범위에서 실행되지 않으므로 `logged_in?` 메소드가 비공개로 설정되어 있습니다. 이 방법은 이 특정 필터를 구현하는 권장되는 방법은 아니지만, 더 간단한 경우에는 유용할 수 있습니다.
특히 `around_action`에 대해서는 블록이 `action`에서도 yield됩니다:

```ruby
around_action { |_controller, action| time(&action) }
```

두 번째 방법은 클래스(실제로는 해당 메서드에 응답하는 모든 객체가 될 수 있음)를 사용하여 필터링을 처리하는 것입니다. 이는 더 복잡하고 두 가지 다른 방법으로는 읽기 쉽고 재사용 가능한 방식으로 구현할 수 없는 경우에 유용합니다. 예를 들어, 로그인 필터를 다시 클래스를 사용하여 다음과 같이 다시 작성할 수 있습니다:

```ruby
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.before(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "You must be logged in to access this section"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

다시 말하지만, 이 필터에 대한 이상적인 예제는 아닙니다. 왜냐하면 이 필터는 컨트롤러의 범위에서 실행되지 않고 인수로 컨트롤러가 전달되기 때문입니다. 필터 클래스는 필터와 동일한 이름의 메서드를 구현해야 합니다. 따라서 `before_action` 필터의 경우 클래스는 `before` 메서드를 구현해야 합니다. `around` 메서드는 액션을 실행하기 위해 `yield`해야 합니다.

요청 위조 보호
--------------------------

크로스 사이트 요청 위조(CSRF)는 사이트가 사용자를 속여 다른 사이트에 대한 요청을 만들도록 하는 공격 유형으로, 사용자의 동의나 지식 없이 해당 사이트에 데이터를 추가, 수정 또는 삭제할 수 있습니다.

이를 방지하기 위한 첫 번째 단계는 모든 "파괴적" 작업(생성, 업데이트 및 삭제)이 GET 요청이 아닌 요청으로만 액세스할 수 있도록 하는 것입니다. RESTful 규칙을 따르고 있다면 이미 이를 수행하고 있습니다. 그러나 악의적인 사이트는 여전히 쉽게 GET 요청이 아닌 요청을 보낼 수 있으며, 이 때 요청 위조 보호 기능이 필요합니다. 이름 그대로, 위조된 요청으로부터 보호합니다.

이를 위해 서버만 알고 있는 추측할 수 없는 토큰을 각 요청에 추가합니다. 이렇게 하면 올바른 토큰 없이 요청이 들어오면 액세스가 거부됩니다.

다음과 같이 폼을 생성하는 경우:

```erb
<%= form_with model: @user do |form| %>
  <%= form.text_field :username %>
  <%= form.text_field :password %>
<% end %>
```

토큰이 숨겨진 필드로 추가되는 것을 볼 수 있습니다:

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- fields -->
</form>
```

Rails는 [폼 헬퍼](form_helpers.html)를 사용하여 생성된 모든 폼에 이 토큰을 추가하므로 대부분의 경우 신경 쓸 필요가 없습니다. 폼을 수동으로 작성하거나 다른 이유로 토큰을 추가해야 하는 경우 `form_authenticity_token` 메서드를 통해 사용할 수 있습니다:

`form_authenticity_token`은 유효한 인증 토큰을 생성합니다. Rails가 자동으로 추가하지 않는 경우와 같이 Rails에서 사용할 수 없는 곳에 유용합니다. 예를 들어 사용자 정의 Ajax 호출에서 사용할 수 있습니다.

[보안 가이드](security.html)에는 이와 관련된 자세한 내용과 웹 애플리케이션 개발 시 알아야 할 다른 보안 관련 문제가 많이 포함되어 있습니다.

요청 및 응답 객체
--------------------------------

모든 컨트롤러에는 현재 실행 중인 요청 주기와 관련된 요청 및 응답 객체를 가리키는 두 가지 접근자 메서드가 있습니다. [`request`][] 메서드는 [`ActionDispatch::Request`][]의 인스턴스를 포함하고 [`response`][] 메서드는 클라이언트로 보내질 응답 객체를 반환합니다.


### `request` 객체

요청 객체에는 클라이언트로부터 수신된 요청에 대한 많은 유용한 정보가 포함되어 있습니다. 사용 가능한 메서드의 전체 목록을 보려면 [Rails API 문서](https://api.rubyonrails.org/classes/ActionDispatch/Request.html)와 [Rack 문서](https://www.rubydoc.info/github/rack/rack/Rack/Request)를 참조하십시오. 이 객체에서 액세스할 수 있는 속성 중 일부는 다음과 같습니다:

| `request`의 속성                          | 목적                                                                          |
| ----------------------------------------- | ---------------------------------------------------------------------------- |
| `host`                                    | 이 요청에 사용된 호스트 이름.                                                 |
| `domain(n=2)`                             | 오른쪽(최상위 도메인)에서 시작하는 `n`개의 세그먼트로 구성된 호스트 이름.       |
| `format`                                  | 클라이언트가 요청한 콘텐츠 유형.                                              |
| `method`                                  | 요청에 사용된 HTTP 메서드.                                                    |
| `get?`, `post?`, `patch?`, `put?`, `delete?`, `head?` | HTTP 메서드가 GET/POST/PATCH/PUT/DELETE/HEAD인 경우 true를 반환합니다. |
| `headers`                                 | 요청과 관련된 헤더를 포함하는 해시를 반환합니다.                               |
| `port`                                    | 요청에 사용된 포트 번호(정수).                                                |
| `protocol`                                | 사용된 프로토콜과 "://"를 포함하는 문자열을 반환합니다. 예: "http://"           |
| `query_string`                            | URL의 쿼리 문자열 부분, 즉 "?" 이후의 모든 것.                               |
| `remote_ip`                               | 클라이언트의 IP 주소.                                                         |
| `url`                                     | 요청에 사용된 전체 URL.                                                        |
#### `path_parameters`, `query_parameters`, 그리고 `request_parameters`

Rails는 요청과 함께 전송된 모든 매개변수를 `params` 해시에 수집합니다. 이 매개변수들은 쿼리 문자열이나 POST 본문으로 전송되었든 상관없이 수집됩니다. 요청 객체에는 이러한 매개변수에 대한 액세서가 세 가지 있으며, 이들은 매개변수가 어디에서 왔는지에 따라 액세스할 수 있습니다. [`query_parameters`][] 해시는 쿼리 문자열의 일부로 전송된 매개변수를 포함하고, [`request_parameters`][] 해시는 POST 본문의 일부로 전송된 매개변수를 포함합니다. [`path_parameters`][] 해시는 이 특정 컨트롤러와 액션으로 이어지는 경로의 일부로 인식된 매개변수를 포함합니다.


### `response` 객체

응답 객체는 일반적으로 직접 사용되지 않지만, 액션의 실행 및 데이터 렌더링 중에 구축되며 사용자에게 보내지는 데이터에 대한 액세스에 유용할 수 있습니다. 이러한 액세서 메서드 중 일부는 값을 변경할 수 있는 세터도 가지고 있습니다. 사용 가능한 메서드의 전체 목록을 보려면 [Rails API 문서](https://api.rubyonrails.org/classes/ActionDispatch/Response.html)와 [Rack 문서](https://www.rubydoc.info/github/rack/rack/Rack/Response)를 참조하십시오.

| `response`의 속성 | 목적                                                                                               |
| ----------------- | -------------------------------------------------------------------------------------------------- |
| `body`            | 클라이언트로 보내지는 데이터의 문자열입니다. 대부분 HTML입니다.                                      |
| `status`          | 응답의 HTTP 상태 코드입니다. 예를 들어, 성공적인 요청의 경우 200이나 파일을 찾을 수 없는 경우 404입니다. |
| `location`        | 클라이언트가 리디렉션되는 URL입니다. (있는 경우)                                                   |
| `content_type`    | 응답의 콘텐츠 유형입니다.                                                                          |
| `charset`         | 응답에 사용되는 문자 집합입니다. 기본값은 "utf-8"입니다.                                            |
| `headers`         | 응답에 사용되는 헤더입니다.                                                                         |

#### 사용자 정의 헤더 설정

응답에 사용자 정의 헤더를 설정하려면 `response.headers`를 사용하면 됩니다. 헤더 속성은 헤더 이름을 해당 값에 매핑하는 해시이며, Rails는 일부 헤더를 자동으로 설정합니다. 헤더를 추가하거나 변경하려면 헤더를 `response.headers`에 할당하면 됩니다.

```ruby
response.headers["Content-Type"] = "application/pdf"
```

참고: 위의 경우에는 `content_type` 세터를 직접 사용하는 것이 더 의미가 있습니다.

HTTP 인증
--------------------

Rails에는 세 가지 기본 HTTP 인증 메커니즘이 있습니다:

* 기본 인증 (Basic Authentication)
* 다이제스트 인증 (Digest Authentication)
* 토큰 인증 (Token Authentication)

### 기본 인증 (Basic Authentication)

기본 인증은 대부분의 브라우저와 다른 HTTP 클라이언트에서 지원하는 인증 방식입니다. 예를 들어, 사용자 이름과 비밀번호를 브라우저의 HTTP 기본 대화 상자에 입력하여 액세스할 수 있는 관리 섹션을 고려해보십시오. 내장된 인증을 사용하려면 [`http_basic_authenticate_with`][] 메서드를 사용하기만 하면 됩니다.

```ruby
class AdminsController < ApplicationController
  http_basic_authenticate_with name: "humbaba", password: "5baa61e4"
end
```

이렇게 하면 `AdminsController`에서 상속된 네임스페이스 컨트롤러를 만들 수 있습니다. 이 필터는 따라서 해당 컨트롤러의 모든 액션에서 실행되며, HTTP 기본 인증으로 보호됩니다.


### 다이제스트 인증 (Digest Authentication)

다이제스트 인증은 기본 인증보다 우수한 인증 방식입니다. 다이제스트 인증은 클라이언트가 네트워크를 통해 암호를 암호화되지 않은 상태로 보내지 않아도 되기 때문에 안전합니다 (HTTP 기본 인증은 HTTPS에서 안전합니다). Rails에서 다이제스트 인증을 사용하려면 [`authenticate_or_request_with_http_digest`][] 메서드를 사용하기만 하면 됩니다.

```ruby
class AdminsController < ApplicationController
  USERS = { "lifo" => "world" }

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_digest do |username|
        USERS[username]
      end
    end
end
```

위의 예에서 `authenticate_or_request_with_http_digest` 블록은 하나의 인수인 사용자 이름만 사용합니다. 블록은 비밀번호를 반환합니다. `authenticate_or_request_with_http_digest`에서 `false` 또는 `nil`을 반환하면 인증 실패가 발생합니다.


### 토큰 인증 (Token Authentication)

토큰 인증은 HTTP `Authorization` 헤더에서 Bearer 토큰의 사용을 가능하게 하는 방식입니다. 사용 가능한 토큰 형식은 다양하며, 이 문서의 범위를 벗어납니다.

예를 들어, 미리 발급된 인증 토큰을 사용하여 인증 및 액세스를 수행하려는 경우, Rails에서 토큰 인증을 구현하기 위해 [`authenticate_or_request_with_http_token`][] 메서드를 사용하기만 하면 됩니다.

```ruby
class PostsController < ApplicationController
  TOKEN = "secret"

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
    end
end
```

위의 예에서 `authenticate_or_request_with_http_token` 블록은 두 개의 인수인 토큰과 HTTP `Authorization` 헤더에서 구문 분석된 옵션을 포함하는 `Hash`를 사용합니다. 블록은 인증이 성공하면 `true`를 반환해야 합니다. `authenticate_or_request_with_http_token`에서 `false` 또는 `nil`을 반환하면 인증 실패가 발생합니다.
스트리밍 및 파일 다운로드
----------------------------

HTML 페이지를 렌더링하는 대신에 파일을 사용자에게 보내고 싶을 때가 있습니다. Rails의 모든 컨트롤러에는 [`send_data`][] 및 [`send_file`][] 메서드가 있으며, 이 두 메서드는 모두 데이터를 클라이언트로 스트리밍합니다. `send_file`은 디스크에 있는 파일의 이름을 제공하면 해당 파일의 내용을 스트리밍해주는 편리한 메서드입니다.

클라이언트로 데이터를 스트리밍하려면 `send_data`를 사용하세요:

```ruby
require "prawn"
class ClientsController < ApplicationController
  # 클라이언트에 대한 정보가 포함된 PDF 문서를 생성하고 반환합니다. 사용자는 PDF를 파일로 다운로드 받습니다.
  def download_pdf
    client = Client.find(params[:id])
    send_data generate_pdf(client),
              filename: "#{client.name}.pdf",
              type: "application/pdf"
  end

  private
    def generate_pdf(client)
      Prawn::Document.new do
        text client.name, align: :center
        text "주소: #{client.address}"
        text "이메일: #{client.email}"
      end.render
    end
end
```

위 예제의 `download_pdf` 액션은 실제로 PDF 문서를 생성하고 문자열로 반환하는 비공개 메서드를 호출합니다. 이 문자열은 파일 다운로드로 클라이언트로 스트리밍되며, 사용자에게 파일 이름이 제안됩니다. 사용자에게 파일을 다운로드하지 않도록 하려면, 예를 들어 HTML 페이지에 포함될 수 있는 이미지와 같은 경우, 파일이 다운로드되지 않도록 브라우저에게 알리기 위해 `:disposition` 옵션을 "inline"으로 설정할 수 있습니다. 이 옵션의 반대 및 기본값은 "attachment"입니다.


### 파일 전송

디스크에 이미 존재하는 파일을 보내려면 `send_file` 메서드를 사용하세요.

```ruby
class ClientsController < ApplicationController
  # 이미 생성되어 디스크에 저장된 파일을 스트리밍합니다.
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

이렇게 하면 파일을 4KB씩 읽어 스트리밍하므로 한 번에 전체 파일을 메모리에 로드하지 않습니다. `:stream` 옵션을 사용하여 스트리밍을 끌 수 있으며, `:buffer_size` 옵션을 사용하여 블록 크기를 조정할 수 있습니다.

`:type`이 지정되지 않은 경우, `:filename`에 지정된 파일 확장자에서 content-type이 추측됩니다. 확장자에 대한 content-type이 등록되어 있지 않은 경우, `application/octet-stream`이 사용됩니다.

경고: 클라이언트로부터 받은 데이터 (params, cookies 등)를 사용하여 디스크에서 파일을 찾을 때는 주의해야 합니다. 이는 파일에 접근할 수 없는 파일에 대한 액세스 권한을 부여할 수 있는 보안 위험을 가지고 있습니다.

팁: 가능하다면 정적 파일을 Rails를 통해 스트리밍하는 것은 권장되지 않습니다. 대신 웹 서버의 공용 폴더에 유지하여 사용자가 Apache 또는 다른 웹 서버를 사용하여 파일을 직접 다운로드하도록 하는 것이 훨씬 효율적입니다. 이렇게 하면 요청이 전체 Rails 스택을 통과하지 않도록 유지됩니다.

### RESTful 다운로드

`send_data`는 잘 작동하지만, RESTful 애플리케이션을 만드는 경우 파일 다운로드를 위한 별도의 액션을 만들 필요는 없습니다. REST 용어로는 위의 예제의 PDF 파일을 클라이언트 리소스의 또 다른 표현으로 간주할 수 있습니다. Rails는 "RESTful" 다운로드를 수행하는 간편한 방법을 제공합니다. 다음과 같이 예제를 다시 작성하여 PDF 다운로드를 `show` 액션의 일부로 만들 수 있습니다. 이때 스트리밍은 필요하지 않습니다:

```ruby
class ClientsController < ApplicationController
  # 사용자는 이 리소스를 HTML 또는 PDF로 요청할 수 있습니다.
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

이 예제가 작동하려면 Rails에 PDF MIME 유형을 추가해야 합니다. 이를 위해 `config/initializers/mime_types.rb` 파일에 다음 줄을 추가해야 합니다:

```ruby
Mime::Type.register "application/pdf", :pdf
```

참고: 구성 파일은 각 요청마다 다시로드되지 않으므로 변경 사항이 적용되려면 서버를 다시 시작해야 합니다.

이제 사용자는 URL에 ".pdf"를 추가함으로써 클라이언트의 PDF 버전을 요청할 수 있습니다:

```
GET /clients/1.pdf
```

### 임의 데이터의 실시간 스트리밍

Rails는 파일뿐만 아니라 다른 것도 스트리밍할 수 있습니다. 사실, 응답 객체에서 원하는 모든 것을 스트리밍할 수 있습니다. [`ActionController::Live`][] 모듈을 사용하면 브라우저와 지속적인 연결을 생성할 수 있습니다. 이 모듈을 사용하면 특정 시점에 브라우저로 임의의 데이터를 전송할 수 있습니다.
#### 라이브 스트리밍 통합

컨트롤러 클래스 내에 `ActionController::Live`를 포함하면 컨트롤러 내의 모든 액션에서 데이터를 스트리밍 할 수 있습니다. 다음과 같이 모듈을 혼합 할 수 있습니다.

```ruby
class MyController < ActionController::Base
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    100.times {
      response.stream.write "hello world\n"
      sleep 1
    }
  ensure
    response.stream.close
  end
end
```

위의 코드는 브라우저와 지속적인 연결을 유지하고 `"hello world\n"` 메시지를 1초마다 100번 보냅니다.

위의 예제에서 주목해야 할 몇 가지 사항이 있습니다. 응답 스트림을 닫는 것을 잊지 않아야합니다. 스트림을 닫지 않으면 소켓이 영원히 열린 상태가됩니다. 또한 응답 스트림에 쓰기 전에 콘텐츠 유형을 `text/event-stream`으로 설정해야합니다. 이는 응답이 커밋 된 후 ( `response.committed?`이 true 값을 반환 할 때) 헤더를 작성 할 수 없기 때문입니다. 커밋은 응답 스트림을 `write` 또는 `commit` 할 때 발생합니다.

#### 예제 사용법

가라오케 기계를 만들고 사용자가 특정 노래의 가사를 얻고 싶어한다고 가정 해 봅시다. 각 `Song`은 특정 줄 수를 가지고 있으며 각 줄은 `num_beats` 시간이 걸려 노래를 마칩니다.

만약 가사를 가라오케 스타일로 반환하려면 (이전 줄을 완료 한 후에만 줄을 보내는 것) `ActionController::Live`를 다음과 같이 사용할 수 있습니다.

```ruby
class LyricsController < ActionController::Base
  include ActionController::Live

  def show
    response.headers['Content-Type'] = 'text/event-stream'
    song = Song.find(params[:id])

    song.each do |line|
      response.stream.write line.lyrics
      sleep line.num_beats
    end
  ensure
    response.stream.close
  end
end
```

위의 코드는 가수가 이전 줄을 완료 한 후에만 다음 줄을 보냅니다.

#### 스트리밍 고려 사항

임의의 데이터를 스트리밍하는 것은 매우 강력한 도구입니다. 이전 예제에서 보여준 것처럼 응답 스트림을 통해 언제 어떤 데이터를 보낼지 선택할 수 있습니다. 그러나 다음 사항도 고려해야합니다.

* 각 응답 스트림은 새로운 스레드를 생성하고 원래 스레드의 스레드 로컬 변수를 복사합니다. 너무 많은 스레드 로컬 변수를 가지고있으면 성능에 부정적인 영향을 미칠 수 있습니다. 마찬가지로 많은 수의 스레드도 성능을 저하시킬 수 있습니다.
* 응답 스트림을 닫지 않으면 해당 소켓이 영원히 열린 상태가됩니다. 응답 스트림을 사용하는 경우 `close`를 호출해야합니다.
* WEBrick 서버는 모든 응답을 버퍼링하므로 `ActionController::Live`를 포함시키지 않습니다. 응답을 자동으로 버퍼링하지 않는 웹 서버를 사용해야합니다.

로그 필터링
-------------

Rails는 `log` 폴더에 각 환경에 대한 로그 파일을 유지합니다. 이 로그 파일은 응용 프로그램에서 실제로 발생하는 작업을 디버깅하는 데 매우 유용하지만, 라이브 응용 프로그램에서는 모든 정보를 로그 파일에 저장하고 싶지 않을 수 있습니다.

### 매개 변수 필터링

응용 프로그램 구성에서 [`config.filter_parameters`][]에 민감한 요청 매개 변수를 추가하여 로그 파일에서 필터링 할 수 있습니다. 이러한 매개 변수는 로그에서 [FILTERED]로 표시됩니다.

```ruby
config.filter_parameters << :password
```

참고 : 제공된 매개 변수는 부분 일치 정규 표현식에 의해 필터링됩니다. Rails는 `:passw`, `:secret` 및 `:token`과 같은 일반적인 응용 프로그램 매개 변수를 처리하기 위해 적절한 초기화 파일 (`initializers/filter_parameter_logging.rb`)에 기본 필터 목록을 추가합니다.

### 리디렉션 필터링

가끔 응용 프로그램이 리디렉션하는 민감한 위치를 로그 파일에서 필터링하는 것이 좋을 수 있습니다. 이를 위해 `config.filter_redirect` 구성 옵션을 사용할 수 있습니다.

```ruby
config.filter_redirect << 's3.amazonaws.com'
```

이를 문자열, 정규 표현식 또는 두 가지 모두의 배열로 설정할 수 있습니다.

```ruby
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

일치하는 URL은 '[FILTERED]'로 표시됩니다.

구조화
------

아마도 응용 프로그램에 버그가 있거나 데이터베이스에 더 이상 존재하지 않는 리소스로 링크를 따르는 등 예외가 처리되어야 할 것입니다. 예를 들어, 사용자가 데이터베이스에서 더 이상 존재하지 않는 리소스로 링크를 따를 경우 Active Record는 `ActiveRecord::RecordNotFound` 예외를 throw합니다.

Rails의 기본 예외 처리는 모든 예외에 대해 "500 Server Error" 메시지를 표시합니다. 요청이 로컬에서 이루어진 경우, 추적 정보와 추가 정보가 표시되어 무엇이 잘못되었는지 파악하고 처리할 수 있습니다. 요청이 원격으로 이루어진 경우 Rails는 사용자에게 간단한 "500 Server Error" 메시지를 표시하거나 라우팅 오류가있는 경우 "404 Not Found"를 표시하거나 레코드를 찾을 수 없는 경우 표시합니다. 때로는 이러한 오류가 어떻게 처리되고 사용자에게 어떻게 표시되는지 사용자 정의 할 수도 있습니다. Rails 응용 프로그램에서 사용 가능한 여러 수준의 예외 처리가 있습니다.
### 기본 500 및 404 템플릿

기본적으로, 프로덕션 환경에서 애플리케이션은 404 또는 500 오류 메시지를 렌더링합니다. 개발 환경에서는 처리되지 않은 예외가 간단히 발생합니다. 이러한 메시지는 `404.html` 및 `500.html`이라는 이름의 정적 HTML 파일에 포함되어 있습니다. 이 파일들을 사용자 정의하여 추가 정보와 스타일을 추가할 수 있지만, 이들은 정적 HTML이므로 ERB, SCSS, CoffeeScript 또는 레이아웃을 사용할 수 없습니다.

### `rescue_from`

에러를 처리할 때 더 복잡한 작업을 수행하려면 [`rescue_from`][]을 사용할 수 있습니다. 이는 특정 유형의 예외(또는 여러 유형)를 전체 컨트롤러와 해당 서브클래스에서 처리합니다.

`rescue_from` 지시문에 의해 잡히는 예외가 발생하면, 예외 객체가 핸들러에 전달됩니다. 핸들러는 `:with` 옵션에 전달되는 메서드 또는 `Proc` 객체일 수 있습니다. 명시적인 `Proc` 객체 대신에 직접 블록을 사용할 수도 있습니다.

다음은 `rescue_from`을 사용하여 모든 `ActiveRecord::RecordNotFound` 오류를 가로채고 처리하는 방법입니다.

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

물론, 이 예제는 복잡하지 않으며 기본 예외 처리를 개선하지 않습니다. 그러나 이러한 예외를 모두 잡을 수 있다면 원하는 대로 처리할 수 있습니다. 예를 들어, 사용자가 애플리케이션의 특정 섹션에 액세스할 수 없을 때 발생하는 예외 클래스를 만들 수 있습니다.

```ruby
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private
    def user_not_authorized
      flash[:error] = "You don't have access to this section."
      redirect_back(fallback_location: root_path)
    end
end

class ClientsController < ApplicationController
  # 사용자가 클라이언트에 액세스할 권한이 있는지 확인합니다.
  before_action :check_authorization

  # 액션에서 권한 관련 작업을 걱정할 필요가 없음을 주목하세요.
  def edit
    @client = Client.find(params[:id])
  end

  private
    # 사용자가 권한이 없으면 예외를 throw합니다.
    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

경고: `Exception` 또는 `StandardError`와 함께 `rescue_from`을 사용하면 Rails가 예외를 올바르게 처리하지 못하므로 심각한 부작용이 발생할 수 있습니다. 따라서 강력한 이유가 없는 한 권장하지 않습니다.

참고: 프로덕션 환경에서 실행 중인 경우 모든 `ActiveRecord::RecordNotFound` 오류는 404 오류 페이지를 렌더링합니다. 사용자 정의 동작이 필요하지 않은 경우 이를 처리할 필요가 없습니다.

참고: 특정 예외는 컨트롤러가 초기화되기 전에 발생하고 액션이 실행되기 전에 잡히므로 `ApplicationController` 클래스에서만 복구할 수 있습니다.

HTTPS 프로토콜 강제
--------------------

컨트롤러로의 통신이 HTTPS를 통해서만 가능하도록 보장하려면, 환경 설정에서 [`config.force_ssl`][]을 통해 [`ActionDispatch::SSL`][] 미들웨어를 활성화해야 합니다.


내장된 헬스 체크 엔드포인트
------------------------------

Rails는 `/up` 경로에서 접근 가능한 내장된 헬스 체크 엔드포인트도 함께 제공됩니다. 이 엔드포인트는 앱이 예외 없이 부팅되었을 경우 200 상태 코드를 반환하고, 그렇지 않을 경우 500 상태 코드를 반환합니다.

프로덕션 환경에서 많은 애플리케이션은 상태를 상위로 보고해야 하는데, 이는 장애 발생 시 엔지니어에게 알림을 보내는 업타임 모니터 또는 팟의 상태를 결정하는 로드 밸런서 또는 Kubernetes 컨트롤러 등에게 필요합니다. 이 헬스 체크는 다양한 상황에서 작동하는 일반적인 솔루션을 제공하기 위해 설계되었습니다.

새로 생성된 Rails 애플리케이션은 `/up`에 헬스 체크가 있지만, "config/routes.rb"에서 원하는 경로로 구성할 수 있습니다:

```ruby
Rails.application.routes.draw do
  get "healthz" => "rails/health#show", as: :rails_health_check
end
```

이제 헬스 체크는 `/healthz` 경로를 통해 접근할 수 있습니다.

참고: 이 엔드포인트는 데이터베이스나 레디스 클러스터와 같은 애플리케이션의 모든 종속성의 상태를 반영하지 않습니다. 애플리케이션별 요구 사항에 따라 "rails/health#show"를 자체 컨트롤러 액션으로 대체하세요.

애플리케이션을 다시 시작해야 하는 상황을 초래할 수 있으므로 체크할 내용을 신중하게 선택하세요. 이러한 장애 상황을 우아하게 처리할 수 있도록 애플리케이션을 설계해야 합니다.
[`ActionController::Base`]: https://api.rubyonrails.org/classes/ActionController/Base.html
[`params`]: https://api.rubyonrails.org/classes/ActionController/StrongParameters.html#method-i-params
[`wrap_parameters`]: https://api.rubyonrails.org/classes/ActionController/ParamsWrapper/Options/ClassMethods.html#method-i-wrap_parameters
[`controller_name`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-controller_name
[`action_name`]: https://api.rubyonrails.org/classes/AbstractController/Base.html#method-i-action_name
[`permit`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit
[`permit!`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit-21
[`require`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-require
[`ActionDispatch::Session::CookieStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CookieStore.html
[`ActionDispatch::Session::CacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CacheStore.html
[`ActionDispatch::Session::MemCacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/MemCacheStore.html
[activerecord-session_store]: https://github.com/rails/activerecord-session_store
[`reset_session`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-reset_session
[`flash`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/RequestMethods.html#method-i-flash
[`flash.keep`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-keep
[`flash.now`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-now
[`config.action_dispatch.cookies_serializer`]: configuring.html#config-action-dispatch-cookies-serializer
[`cookies`]: https://api.rubyonrails.org/classes/ActionController/Cookies.html#method-i-cookies
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`skip_before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-skip_before_action
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`request`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-request
[`response`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-response
[`path_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Http/Parameters.html#method-i-path_parameters
[`query_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-query_parameters
[`request_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-request_parameters
[`http_basic_authenticate_with`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic/ControllerMethods/ClassMethods.html#method-i-http_basic_authenticate_with
[`authenticate_or_request_with_http_digest`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Digest/ControllerMethods.html#method-i-authenticate_or_request_with_http_digest
[`authenticate_or_request_with_http_token`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token/ControllerMethods.html#method-i-authenticate_or_request_with_http_token
[`send_data`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_data
[`send_file`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file
[`ActionController::Live`]: https://api.rubyonrails.org/classes/ActionController/Live.html
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`config.force_ssl`]: configuring.html#config-force-ssl
[`ActionDispatch::SSL`]: https://api.rubyonrails.org/classes/ActionDispatch/SSL.html
