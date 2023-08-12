**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 02f663dc709da76ced45deb2ba800a78
레일스에서의 레이아웃과 렌더링
==============================

이 가이드는 액션 컨트롤러와 액션 뷰의 기본 레이아웃 기능을 다룹니다.

이 가이드를 읽고 나면 다음을 알게 될 것입니다:

* 레일스에 내장된 다양한 렌더링 메소드를 사용하는 방법
* 여러 콘텐츠 섹션을 포함하는 레이아웃을 생성하는 방법
* 뷰를 DRY(Don't Repeat Yourself)하게 만들기 위해 파셜을 사용하는 방법
* 중첩된 레이아웃(하위 템플릿)을 사용하는 방법

--------------------------------------------------------------------------------

개요: 각 부분이 어떻게 연결되는지
-------------------------------------

이 가이드는 모델-뷰-컨트롤러(MVC) 삼각형에서 컨트롤러와 뷰의 상호작용에 초점을 맞춥니다. 컨트롤러는 레일스에서 요청 처리 과정 전체를 조율하는 역할을 담당하지만, 일반적으로 무거운 코드는 모델에게 넘깁니다. 그러나 사용자에게 응답을 보내야 할 때 컨트롤러는 뷰에게 작업을 넘깁니다. 이 넘김 작업이 이 가이드의 주제입니다.

대략적으로 말하면, 이 작업은 응답으로 보낼 내용을 결정하고 해당 응답을 생성하기 위한 적절한 메소드를 호출하는 것을 포함합니다. 응답이 완전한 뷰인 경우, 레일스는 뷰를 레이아웃으로 감싸고 부분 뷰를 가져오기 위해 추가 작업을 수행합니다. 이 가이드에서 이러한 경로를 모두 볼 수 있습니다.

응답 생성하기
------------------

컨트롤러의 관점에서 HTTP 응답을 생성하는 방법은 세 가지가 있습니다:

* 브라우저로 보내기 위해 전체 응답을 생성하기 위해 [`render`][controller.render]를 호출합니다.
* 브라우저로 HTTP 리디렉션 상태 코드를 보내기 위해 [`redirect_to`][]를 호출합니다.
* 브라우저로 보낼 HTTP 헤더만으로 구성된 응답을 생성하기 위해 [`head`][]를 호출합니다.


### 기본적으로 렌더링: 액션에서의 관례적인 설정

레일스가 "관례보다 설정"을 장려한다는 것을 들어보았을 것입니다. 기본 렌더링은 이에 대한 훌륭한 예입니다. 레일스에서 기본적으로 컨트롤러는 유효한 라우트에 해당하는 이름을 가진 뷰를 자동으로 렌더링합니다. 예를 들어, `BooksController` 클래스에 다음 코드가 있다면:

```ruby
class BooksController < ApplicationController
end
```

그리고 라우트 파일에 다음 코드가 있다면:

```ruby
resources :books
```

그리고 `app/views/books/index.html.erb`라는 뷰 파일이 있다면:

```html+erb
<h1>Books are coming soon!</h1>
```

레일스는 `/books`로 이동할 때 자동으로 `app/views/books/index.html.erb`를 렌더링하고 화면에 "Books are coming soon!"을 표시합니다.

그러나 곧 `Book` 모델을 생성하고 `BooksController`에 인덱스 액션을 추가할 것이므로, 곧 나타날 화면은 최소한으로 유용합니다:

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

"관례보다 설정" 원칙에 따라 인덱스 액션의 끝에 명시적인 렌더링이 없습니다. 규칙은 컨트롤러 액션의 끝에서 명시적으로 무언가를 렌더링하지 않으면, 레일스는 컨트롤러의 뷰 경로에서 `action_name.html.erb` 템플릿을 자동으로 찾아 렌더링합니다. 따라서 이 경우 레일스는 `app/views/books/index.html.erb` 파일을 렌더링합니다.

뷰에서 모든 책의 속성을 표시하려면 다음과 같은 ERB 템플릿을 사용할 수 있습니다:

```html+erb
<h1>Listing Books</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Show", book %></td>
        <td><%= link_to "Edit", edit_book_path(book) %></td>
        <td><%= link_to "Destroy", book, data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "New book", new_book_path %>
```

참고: 실제 렌더링은 [`ActionView::Template::Handlers`](https://api.rubyonrails.org/classes/ActionView/Template/Handlers.html) 모듈의 중첩된 클래스에 의해 수행됩니다. 이 가이드에서는 이 과정을 자세히 다루지 않지만, 뷰의 파일 확장자는 템플릿 핸들러의 선택을 제어하는 데 중요합니다.

### `render` 사용하기

대부분의 경우, 컨트롤러의 [`render`][controller.render] 메소드가 브라우저에서 사용할 애플리케이션 콘텐츠를 렌더링하는 데 필요한 작업을 수행합니다. `render`의 동작을 사용자 정의하는 다양한 방법이 있습니다. Rails 템플릿의 기본 뷰, 특정 템플릿, 파일, 인라인 코드 또는 아무것도 렌더링할 수 있습니다. 텍스트, JSON 또는 XML을 렌더링할 수 있습니다. 렌더링된 응답의 콘텐츠 유형 또는 HTTP 상태도 지정할 수 있습니다.

팁: 브라우저에서 검사하지 않고 `render` 호출의 정확한 결과를 보려면 `render_to_string`을 호출할 수 있습니다. 이 메소드는 `render`와 동일한 옵션을 사용하지만, 브라우저로 응답을 보내지 않고 문자열을 반환합니다.
#### 액션의 뷰 렌더링

동일한 컨트롤러 내에서 다른 템플릿에 해당하는 뷰를 렌더링하려면 `render`와 뷰의 이름을 사용할 수 있습니다:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

`update` 호출이 실패하면 이 컨트롤러의 `edit.html.erb` 템플릿을 렌더링합니다.

원한다면 문자열 대신 심볼을 사용하여 렌더링할 액션을 지정할 수도 있습니다:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit, status: :unprocessable_entity
  end
end
```

#### 다른 컨트롤러의 액션 템플릿 렌더링

액션 코드가 포함된 컨트롤러와는 완전히 다른 컨트롤러에서 템플릿을 렌더링하려면 `render`를 사용하여 렌더링할 템플릿의 전체 경로(`app/views`를 기준으로 상대 경로)를 전달할 수도 있습니다. 예를 들어, `app/controllers/admin`에 있는 `AdminProductsController`에서 코드를 실행하고 있다면 다음과 같이 `app/views/products`에 있는 액션의 결과를 템플릿으로 렌더링할 수 있습니다:

```ruby
render "products/show"
```

문자열에 포함된 슬래시 문자로 인해 Rails는 이 뷰가 다른 컨트롤러에 속한다는 것을 알 수 있습니다. 명시적으로 지정하려면 `:template` 옵션을 사용할 수도 있습니다(Rails 2.2 이전에는 필수였습니다):

```ruby
render template: "products/show"
```

#### 마무리

앞서 설명한 두 가지 렌더링 방법(동일한 컨트롤러 내의 다른 액션의 템플릿 렌더링 및 다른 컨트롤러의 액션의 템플릿 렌더링)은 사실상 동일한 작업의 변형입니다.

실제로 `BooksController` 클래스에서는 `update` 액션 내에서 책이 성공적으로 업데이트되지 않으면 `views/books` 디렉토리의 `edit.html.erb` 템플릿을 렌더링하는 다음과 같은 모든 `render` 호출이 동일한 결과를 가져옵니다:

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

어떤 것을 사용하느냐는 스타일과 관례의 문제이지만, 작성 중인 코드에 가장 적합한 가장 간단한 방법을 사용하는 것이 좋습니다.

#### `:inline`과 함께 `render` 사용하기

`render` 메소드는 뷰 없이도 사용할 수 있습니다. 이 경우 `:inline` 옵션을 사용하여 메소드 호출의 일부로 ERB를 제공해야 합니다. 다음은 이에 대한 예입니다:

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

경고: 이 옵션을 사용하는 것은 거의 좋은 이유가 없습니다. 컨트롤러에 ERB를 혼합하는 것은 Rails의 MVC 지향성을 해치며, 다른 개발자가 프로젝트의 로직을 따라가기 어렵게 만들 수 있습니다. 대신 별도의 erb 뷰를 사용하세요.

기본적으로 인라인 렌더링은 ERB를 사용합니다. `:type` 옵션을 사용하여 대신 Builder를 사용하도록 강제할 수 있습니다:

```ruby
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```

#### 텍스트 렌더링

`render`의 `:plain` 옵션을 사용하여 마크업 없는 일반 텍스트를 브라우저로 보낼 수 있습니다:

```ruby
render plain: "OK"
```

팁: 순수 텍스트를 렌더링하는 것은 주로 HTML이 아닌 다른 것을 기대하는 Ajax나 웹 서비스 요청에 응답할 때 가장 유용합니다.

참고: `:plain` 옵션을 사용하면 기본적으로 현재 레이아웃을 사용하지 않고 텍스트가 렌더링됩니다. 텍스트를 현재 레이아웃에 넣으려면 `layout: true` 옵션을 추가하고 레이아웃 파일에 `.text.erb` 확장자를 사용해야 합니다.

#### HTML 렌더링

`render`의 `:html` 옵션을 사용하여 HTML 문자열을 브라우저로 보낼 수 있습니다:

```ruby
render html: helpers.tag.strong('Not Found')
```

팁: 작은 HTML 코드 조각을 렌더링할 때 유용합니다. 그러나 마크업이 복잡한 경우 템플릿 파일로 이동하는 것이 좋습니다.

참고: `html:` 옵션을 사용할 때 HTML 엔티티는 `html_safe`-aware API로 구성되지 않은 문자열인 경우 이스케이프됩니다.

#### JSON 렌더링

JSON은 많은 Ajax 라이브러리에서 사용하는 JavaScript 데이터 형식입니다. Rails는 객체를 JSON으로 변환하고 해당 JSON을 브라우저로 렌더링하는 기능을 내장하고 있습니다:

```ruby
render json: @product
```

팁: 렌더링하려는 객체에 대해 `to_json`을 호출할 필요가 없습니다. `:json` 옵션을 사용하면 `render`가 자동으로 `to_json`을 호출합니다.
#### XML 렌더링

Rails는 객체를 XML로 변환하고 해당 XML을 호출자에게 렌더링하는 기능을 내장하고 있습니다:

```ruby
render xml: @product
```

팁: 렌더링하려는 객체에 대해 `to_xml`을 호출할 필요가 없습니다. `:xml` 옵션을 사용하면 `render`가 자동으로 `to_xml`을 호출합니다.

#### Vanilla JavaScript 렌더링

Rails는 Vanilla JavaScript를 렌더링할 수 있습니다:

```ruby
render js: "alert('Hello Rails');"
```

이는 지정된 문자열을 `text/javascript` MIME 유형으로 브라우저에 전송합니다.

#### Raw Body 렌더링

`render`의 `:body` 옵션을 사용하여 컨텐츠 유형을 설정하지 않고 브라우저에 원시 콘텐츠를 보낼 수 있습니다:

```ruby
render body: "raw"
```

팁: 이 옵션은 응답의 컨텐츠 유형에 관심이 없는 경우에만 사용해야 합니다. 대부분의 경우 `:plain` 또는 `:html`을 사용하는 것이 더 적절할 수 있습니다.

참고: 이 렌더 옵션에서 반환된 응답은 기본적으로 Action Dispatch 응답의 기본 컨텐츠 유형인 `text/plain`입니다.

#### Raw File 렌더링

Rails는 절대 경로에서 원시 파일을 렌더링할 수 있습니다. 이는 오류 페이지와 같은 정적 파일을 조건부로 렌더링하는 데 유용합니다.

```ruby
render file: "#{Rails.root}/public/404.html", layout: false
```

이는 원시 파일을 렌더링합니다(ERB나 다른 핸들러를 지원하지 않음). 기본적으로 현재 레이아웃 내에서 렌더링됩니다.

경고: `:file` 옵션을 사용하여 사용자 입력과 결합하는 경우 보안 문제가 발생할 수 있습니다. 공격자가 이 작업을 사용하여 파일 시스템의 보안에 민감한 파일에 액세스할 수 있습니다.

팁: 레이아웃이 필요하지 않은 경우 `send_file`이 더 빠르고 좋은 옵션일 수 있습니다.

#### 객체 렌더링

Rails는 `:render_in`에 응답하는 객체를 렌더링할 수 있습니다.

```ruby
render MyRenderable.new
```

이는 제공된 객체에서 현재 뷰 컨텍스트와 함께 `render_in`을 호출합니다.

또한 `:renderable` 옵션을 사용하여 객체를 제공할 수도 있습니다:

```ruby
render renderable: MyRenderable.new
```

#### `render`의 옵션

[`render`][controller.render] 메서드에 대한 호출은 일반적으로 여섯 가지 옵션을 허용합니다:

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`
* `:variants`

##### `:content_type` 옵션

기본적으로 Rails는 렌더링 작업의 결과를 `text/html` MIME 컨텐츠 유형으로 제공합니다(`:json` 옵션을 사용하면 `application/json`을 사용하고 `:xml` 옵션의 경우 `application/xml`을 사용합니다). 때로는 이를 변경하고 싶을 수 있으며, 이를 위해 `:content_type` 옵션을 설정할 수 있습니다:

```ruby
render template: "feed", content_type: "application/rss"
```

##### `:layout` 옵션

대부분의 `render` 옵션과 마찬가지로, 렌더링된 컨텐츠는 현재 레이아웃의 일부로 표시됩니다. 나중에 이 가이드에서 레이아웃에 대해 자세히 알아보고 사용하는 방법을 배우게 될 것입니다.

`:layout` 옵션을 사용하여 Rails에 현재 액션에 대한 레이아웃으로 특정 파일을 사용하도록 지시할 수 있습니다:

```ruby
render layout: "special_layout"
```

Rails에게 전혀 레이아웃을 사용하지 않고 렌더링하도록 지시할 수도 있습니다:

```ruby
render layout: false
```

##### `:location` 옵션

`:location` 옵션을 사용하여 HTTP `Location` 헤더를 설정할 수 있습니다:

```ruby
render xml: photo, location: photo_url(photo)
```

##### `:status` 옵션

Rails는 자동으로 올바른 HTTP 상태 코드를 가진 응답을 생성합니다(대부분의 경우, 이는 `200 OK`입니다). 이를 변경하려면 `:status` 옵션을 사용할 수 있습니다:

```ruby
render status: 500
render status: :forbidden
```

Rails는 숫자 상태 코드와 아래에 표시된 해당 심볼을 모두 이해합니다.

| 응답 클래스         | HTTP 상태 코드 | 심볼                            |
| ------------------- | -------------- | ------------------------------- |
| **정보**            | 100            | :continue                       |
|                     | 101            | :switching_protocols            |
|                     | 102            | :processing                     |
| **성공**            | 200            | :ok                             |
|                     | 201            | :created                        |
|                     | 202            | :accepted                       |
|                     | 203            | :non_authoritative_information  |
|                     | 204            | :no_content                     |
|                     | 205            | :reset_content                  |
|                     | 206            | :partial_content                |
|                     | 207            | :multi_status                   |
|                     | 208            | :already_reported               |
|                     | 226            | :im_used                        |
| **리다이렉션**      | 300            | :multiple_choices               |
|                     | 301            | :moved_permanently              |
|                     | 302            | :found                          |
|                     | 303            | :see_other                      |
|                     | 304            | :not_modified                   |
|                     | 305            | :use_proxy                      |
|                     | 307            | :temporary_redirect             |
|                     | 308            | :permanent_redirect             |
| **클라이언트 오류** | 400            | :bad_request                    |
|                     | 401            | :unauthorized                   |
|                     | 402            | :payment_required               |
|                     | 403            | :forbidden                      |
|                     | 404            | :not_found                      |
|                     | 405            | :method_not_allowed             |
|                     | 406            | :not_acceptable                 |
|                     | 407            | :proxy_authentication_required  |
|                     | 408            | :request_timeout                |
|                     | 409            | :conflict                       |
|                     | 410            | :gone                           |
|                     | 411            | :length_required                |
|                     | 412            | :precondition_failed            |
|                     | 413            | :payload_too_large              |
|                     | 414            | :uri_too_long                   |
|                     | 415            | :unsupported_media_type         |
|                     | 416            | :range_not_satisfiable          |
|                     | 417            | :expectation_failed             |
|                     | 421            | :misdirected_request            |
|                     | 422            | :unprocessable_entity           |
|                     | 423            | :locked                         |
|                     | 424            | :failed_dependency              |
|                     | 426            | :upgrade_required               |
|                     | 428            | :precondition_required          |
|                     | 429            | :too_many_requests              |
|                     | 431            | :request_header_fields_too_large|
|                     | 451            | :unavailable_for_legal_reasons  |
| **서버 오류**      | 500            | :internal_server_error          |
|                     | 501            | :not_implemented                |
|                     | 502            | :bad_gateway                    |
|                     | 503            | :service_unavailable            |
|                     | 504            | :gateway_timeout                |
|                     | 505            | :http_version_not_supported     |
|                     | 506            | :variant_also_negotiates        |
|                     | 507            | :insufficient_storage           |
|                     | 508            | :loop_detected                  |
|                     | 510            | :not_extended                   |
|                     | 511            | :network_authentication_required|
참고: 응답에서 콘텐츠 상태 코드(100-199, 204, 205 또는 304)와 함께 콘텐츠를 렌더링하려고 하면 응답에서 삭제됩니다.

##### `:formats` 옵션

Rails는 요청에서 지정된 형식(또는 기본값으로 `:html`)을 사용합니다. 심볼이나 배열로 `:formats` 옵션을 전달하여 이를 변경할 수 있습니다:

```ruby
render formats: :xml
render formats: [:json, :xml]
```

지정된 형식의 템플릿이 없는 경우 `ActionView::MissingTemplate` 오류가 발생합니다.

##### `:variants` 옵션

이를 통해 Rails에게 동일한 형식의 템플릿 변형을 찾도록 지시할 수 있습니다. 심볼이나 배열로 `:variants` 옵션을 전달하여 변형 목록을 지정할 수 있습니다.

사용 예는 다음과 같습니다.

```ruby
# HomeController#index에서 호출됨
render variants: [:mobile, :desktop]
```

이 변형 세트로 Rails는 다음과 같은 템플릿 세트를 찾고 존재하는 첫 번째 템플릿을 사용합니다.

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

지정된 형식의 템플릿이 없는 경우 `ActionView::MissingTemplate` 오류가 발생합니다.

렌더링 호출에서 변형을 설정하는 대신 컨트롤러 액션에서 요청 객체에 설정할 수도 있습니다.

```ruby
def index
  request.variant = determine_variant
end

  private
    def determine_variant
      variant = nil
      # 사용할 변형을 결정하는 코드
      variant = :mobile if session[:use_mobile]

      variant
    end
```

#### 레이아웃 찾기

현재 레이아웃을 찾기 위해 Rails는 컨트롤러와 동일한 기본 이름을 가진 `app/views/layouts` 폴더에서 파일을 찾습니다. 예를 들어, `PhotosController` 클래스에서 액션을 렌더링하면 `app/views/layouts/photos.html.erb` (또는 `app/views/layouts/photos.builder`)를 사용합니다. 이와 같은 컨트롤러별 레이아웃이 없는 경우 Rails는 `app/views/layouts/application.html.erb` 또는 `app/views/layouts/application.builder`를 사용합니다. `.erb` 레이아웃이 없는 경우 `.builder` 레이아웃을 사용합니다. Rails는 또한 개별 컨트롤러와 액션에 특정 레이아웃을 더 정확하게 할당하는 여러 가지 방법을 제공합니다.

##### 컨트롤러에 대한 레이아웃 지정

컨트롤러에서 기본 레이아웃 규칙을 재정의하기 위해 [`layout`][] 선언을 사용할 수 있습니다. 예를 들어:

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

이 선언으로 `ProductsController`에서 렌더링되는 모든 뷰는 레이아웃으로 `app/views/layouts/inventory.html.erb`를 사용합니다.

전체 애플리케이션에 특정 레이아웃을 할당하려면 `ApplicationController` 클래스에서 `layout` 선언을 사용하십시오:

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

이 선언으로 전체 애플리케이션의 모든 뷰는 레이아웃으로 `app/views/layouts/main.html.erb`를 사용합니다.


##### 런타임에서 레이아웃 선택

심볼을 사용하여 레이아웃 선택을 요청 처리 시기까지 연기할 수 있습니다:

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end
end
```

이제 현재 사용자가 특별한 사용자인 경우 제품을 보는 동안 특별한 레이아웃을 사용합니다.

Proc와 같은 인라인 메서드를 사용하여 레이아웃을 결정할 수도 있습니다. 예를 들어, Proc 객체를 전달하면 Proc에 제공하는 블록에 `controller` 인스턴스가 제공되므로 현재 요청을 기반으로 레이아웃을 결정할 수 있습니다:

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### 조건부 레이아웃

컨트롤러 수준에서 지정된 레이아웃은 `:only` 및 `:except` 옵션을 지원합니다. 이 옵션은 컨트롤러 내의 메서드 이름 또는 메서드 이름의 배열을 사용할 수 있습니다:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

이 선언으로 `rss` 및 `index` 메서드를 제외한 모든 것에 `product` 레이아웃이 사용됩니다.

##### 레이아웃 상속

레이아웃 선언은 계층 구조에서 아래로 전파되며, 더 구체적인 레이아웃 선언이 항상 더 일반적인 선언을 무시합니다. 예를 들어:

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `articles_controller.rb`

    ```ruby
    class ArticlesController < ApplicationController
    end
    ```

* `special_articles_controller.rb`

    ```ruby
    class SpecialArticlesController < ArticlesController
      layout "special"
    end
    ```

* `old_articles_controller.rb`

    ```ruby
    class OldArticlesController < SpecialArticlesController
      layout false

      def show
        @article = Article.find(params[:id])
      end

      def index
        @old_articles = Article.older
        render layout: "old"
      end
      # ...
    end
    ```

이 애플리케이션에서:

* 일반적으로 뷰는 `main` 레이아웃으로 렌더링됩니다.
* `ArticlesController#index`는 `main` 레이아웃을 사용합니다.
* `SpecialArticlesController#index`는 `special` 레이아웃을 사용합니다.
* `OldArticlesController#show`는 전혀 레이아웃을 사용하지 않습니다.
* `OldArticlesController#index`는 `old` 레이아웃을 사용합니다.
##### 템플릿 상속

레이아웃 상속 로직과 유사하게, 템플릿이나 부분 템플릿이 일반적인 경로에서 찾을 수 없는 경우, 컨트롤러는 상속 체인에서 렌더링할 템플릿이나 부분 템플릿을 찾습니다. 예를 들어:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
end
```

```ruby
# app/controllers/admin_controller.rb
class AdminController < ApplicationController
end
```

```ruby
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < AdminController
  def index
  end
end
```

`admin/products#index` 액션의 조회 순서는 다음과 같습니다:

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

이로 인해 `app/views/application/`은 공유 부분 템플릿을 위한 좋은 장소가 되며, 다음과 같이 ERB에서 렌더링할 수 있습니다:

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
이 목록에는 항목이 없습니다. <em>아직</em>.
```

#### 이중 렌더 오류 피하기

일찍이 대부분의 Rails 개발자들은 "Can only render or redirect once per action"라는 오류 메시지를 볼 수 있습니다. 이는 귀찮은 일이지만, 상대적으로 쉽게 해결할 수 있습니다. 일반적으로 이 오류는 `render` 작동 방식에 대한 기본적인 오해 때문에 발생합니다.

예를 들어, 다음과 같은 코드는 이 오류를 발생시킵니다:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

`@book.special?`가 `true`로 평가되면, Rails는 `@book` 변수를 `special_show` 뷰에 넣기 위해 렌더링 프로세스를 시작합니다. 하지만 이는 `show` 액션의 나머지 코드가 실행되는 것을 막지 않으며, Rails는 액션의 끝에 도달하면 `regular_show` 뷰를 렌더링하고 오류를 발생시킵니다. 해결책은 간단합니다: 단일 코드 경로에서 `render` 또는 `redirect` 호출이 한 번만 있는지 확인하세요. `return`이 도움이 될 수 있는 한 가지 방법입니다. 다음은 메서드의 수정된 버전입니다:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
    return
  end
  render action: "regular_show"
end
```

`render`에 의해 암묵적으로 수행되는 ActionController의 렌더링은 `render`가 호출되었는지 여부를 감지하므로 다음은 오류 없이 작동합니다:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

이는 `special?`가 설정된 책을 `special_show` 템플릿으로 렌더링하고, 다른 책은 기본 `show` 템플릿으로 렌더링합니다.

### `redirect_to` 사용하기

HTTP 요청에 대한 응답을 반환하는 다른 방법은 [`redirect_to`][]를 사용하는 것입니다. 앞에서 보았듯이, `render`는 Rails에게 어떤 뷰(또는 다른 에셋)를 사용하여 응답을 구성해야 하는지 알려줍니다. `redirect_to` 메서드는 완전히 다른 작업을 수행합니다: 브라우저에게 다른 URL에 대한 새 요청을 보내도록 지시합니다. 예를 들어, 다음 호출로 코드의 어느 곳에서든 현재 위치에서 애플리케이션의 사진 목록으로 리디렉션할 수 있습니다:

```ruby
redirect_to photos_url
```

[`redirect_back`][]을 사용하여 사용자를 방금 전에 있던 페이지로 돌려보낼 수도 있습니다. 이 위치는 브라우저에 의해 설정되지 않을 수 있는 `HTTP_REFERER` 헤더에서 가져옵니다. 따라서 이 경우에 사용할 `fallback_location`을 제공해야 합니다.

```ruby
redirect_back(fallback_location: root_path)
```

참고: `redirect_to`와 `redirect_back`은 메서드 실행에서 중단하고 즉시 반환하지 않고, 단지 HTTP 응답을 설정합니다. 메서드 이후에 발생하는 문장은 실행됩니다. 필요한 경우 명시적인 `return`이나 다른 중단 메커니즘을 사용하여 중단할 수 있습니다.


#### 다른 리디렉트 상태 코드 얻기

Rails는 `redirect_to`를 호출할 때 HTTP 상태 코드 302인 임시 리디렉트를 사용합니다. 301인 영구 리디렉트와 같은 다른 상태 코드를 사용하려면 `:status` 옵션을 사용할 수 있습니다:

```ruby
redirect_to photos_path, status: 301
```

`render`의 `:status` 옵션과 마찬가지로, `redirect_to`의 `:status`는 숫자와 심볼 헤더 표기를 모두 허용합니다.

#### `render`와 `redirect_to`의 차이점

경험이 부족한 개발자들은 종종 `redirect_to`를 Rails 코드에서 한 곳에서 다른 곳으로 실행을 이동하는 일종의 `goto` 명령으로 생각합니다. 이는 _옳지 않습니다_. 코드가 실행을 중지하고 브라우저로부터 새 요청을 기다리게 됩니다. 그저 HTTP 302 상태 코드를 보내어 브라우저가 다음에 어떤 요청을 보내야 하는지 알려준 것뿐입니다.

차이를 보기 위해 다음 액션들을 고려해 보세요:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

이 형태의 코드로는 `@book` 변수가 `nil`인 경우 문제가 발생할 가능성이 큽니다. 기억하세요, `render :action`은 대상 액션에서 어떤 코드도 실행하지 않으므로 `index` 뷰가 아마도 필요로 할 `@books` 변수를 설정할 어떤 것도 없습니다. 렌더링 대신 리디렉션하는 방법으로 이를 수정하는 한 가지 방법이 있습니다:
```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

이 코드를 사용하면 브라우저가 인덱스 페이지에 대한 새로운 요청을 만들고, `index` 메소드의 코드가 실행되며 모든 것이 잘 작동합니다.

이 코드의 유일한 단점은 브라우저로의 왕복이 필요하다는 것입니다: 브라우저가 `/books/1`로 쇼 액션을 요청하고 컨트롤러가 책이 없다는 것을 발견하면 컨트롤러는 브라우저에게 `/books/`로 이동하라는 302 리디렉션 응답을 보냅니다. 브라우저는 이에 따라 따르고 인덱스 액션을 요청하기 위해 컨트롤러에게 새로운 요청을 다시 보냅니다. 그런 다음 컨트롤러는 데이터베이스에서 모든 책을 가져와 인덱스 템플릿을 렌더링하여 브라우저로 다시 보내고, 브라우저는 화면에 표시합니다.

작은 애플리케이션에서는 이 추가된 지연이 문제가 되지 않을 수 있지만, 응답 시간이 중요한 경우에는 고려해야 할 사항입니다. 다음과 같은 가공된 예제로 이를 처리하는 한 가지 방법을 보여줄 수 있습니다:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "책을 찾을 수 없습니다"
    render "index"
  end
end
```

이 코드는 지정된 ID를 가진 책이 없음을 감지하고, 모델의 모든 책을 가진 `@books` 인스턴스 변수를 채우고, 직접 `index.html.erb` 템플릿을 렌더링하여 브라우저로 반환하고, 사용자에게 발생한 일에 대해 플래시 알림 메시지를 보냅니다.

### `head`를 사용하여 헤더만으로 응답 작성하기

[`head`][] 메소드는 헤더만으로 브라우저에 응답을 보낼 수 있습니다. `head` 메소드는 HTTP 상태 코드를 나타내는 숫자나 심볼 (참조 테이블 참조)을 받습니다. 옵션 인자는 헤더 이름과 값으로 이루어진 해시로 해석됩니다. 예를 들어, 오류 헤더만 반환할 수 있습니다:

```ruby
head :bad_request
```

이는 다음 헤더를 생성합니다:

```http
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

또는 다른 HTTP 헤더를 사용하여 다른 정보를 전달할 수 있습니다:

```ruby
head :created, location: photo_path(@photo)
```

이는 다음을 생성합니다:

```http
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

레이아웃 구조화
-------------------

Rails가 응답으로 뷰를 렌더링할 때, 이전에 이 가이드에서 다룬 현재 레이아웃을 찾는 규칙을 사용하여 뷰와 현재 레이아웃을 결합합니다. 레이아웃 내에서 전체 응답을 형성하기 위해 다양한 출력 조각을 결합하는 세 가지 도구에 액세스할 수 있습니다:

* 에셋 태그
* `yield` 및 [`content_for`][]
* 부분 뷰


### 에셋 태그 헬퍼

에셋 태그 헬퍼는 뷰를 피드, 자바스크립트, 스타일시트, 이미지, 비디오 및 오디오에 연결하는 HTML을 생성하는 메소드를 제공합니다. Rails에는 다음과 같은 여섯 가지 에셋 태그 헬퍼가 있습니다:

* [`auto_discovery_link_tag`][]
* [`javascript_include_tag`][]
* [`stylesheet_link_tag`][]
* [`image_tag`][]
* [`video_tag`][]
* [`audio_tag`][]

이 태그들은 레이아웃이나 다른 뷰에서 사용할 수 있지만, `auto_discovery_link_tag`, `javascript_include_tag`, `stylesheet_link_tag`은 주로 레이아웃의 `<head>` 섹션에서 사용됩니다.

경고: 에셋 태그 헬퍼는 지정된 위치에 에셋이 존재하는지 확인하지 않습니다. 단순히 당신이 무엇을 하고 있는지 알고 있다고 가정하고 링크를 생성합니다.


#### `auto_discovery_link_tag`로 피드에 연결하기

[`auto_discovery_link_tag`][] 헬퍼는 대부분의 브라우저와 피드 리더가 RSS, Atom 또는 JSON 피드의 존재를 감지하는 데 사용할 수 있는 HTML을 생성합니다. 링크의 유형 (`:rss`, `:atom`, 또는 `:json`), url_for에 전달되는 옵션의 해시, 태그에 대한 옵션의 해시를 인수로 받습니다:

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS 피드"}) %>
```

`auto_discovery_link_tag`에는 세 가지 태그 옵션이 있습니다:

* `:rel`은 링크의 `rel` 값을 지정합니다. 기본값은 "alternate"입니다.
* `:type`은 명시적인 MIME 타입을 지정합니다. Rails는 자동으로 적절한 MIME 타입을 생성합니다.
* `:title`은 링크의 제목을 지정합니다. 기본값은 대문자 `:type` 값입니다. 예를 들어, "ATOM" 또는 "RSS"입니다.
#### `javascript_include_tag`을 사용하여 JavaScript 파일에 링크하기

[`javascript_include_tag`][] 헬퍼는 제공된 각 소스에 대해 HTML `script` 태그를 반환합니다.

Asset Pipeline이 활성화된 Rails를 사용하는 경우, 이 헬퍼는 이전 버전의 Rails에서 사용된 `public/javascripts` 대신 `/assets/javascripts/`로 링크를 생성합니다. 이 링크는 Asset Pipeline에 의해 제공됩니다.

Rails 애플리케이션 또는 Rails 엔진 내의 JavaScript 파일은 `app/assets`, `lib/assets` 또는 `vendor/assets` 중 하나의 위치에 저장됩니다. 이러한 위치에 대한 자세한 설명은 [Asset Pipeline 가이드의 Asset Organization 섹션](asset_pipeline.html#asset-organization)에서 확인할 수 있습니다.

문서 루트에 대한 전체 경로 또는 URL을 지정할 수 있습니다. 예를 들어, `app/assets`, `lib/assets` 또는 `vendor/assets` 중 하나의 디렉토리 안에 있는 `javascripts` 디렉토리에 있는 JavaScript 파일에 링크하려면 다음과 같이 작성합니다:

```erb
<%= javascript_include_tag "main" %>
```

그러면 Rails는 다음과 같은 `script` 태그를 출력합니다:

```html
<script src='/assets/main.js'></script>
```

이 자산에 대한 요청은 Sprockets 젬에 의해 제공됩니다.

`app/assets/javascripts/main.js` 및 `app/assets/javascripts/columns.js`와 같은 여러 파일을 동시에 포함하려면 다음과 같이 작성합니다:

```erb
<%= javascript_include_tag "main", "columns" %>
```

`app/assets/javascripts/main.js` 및 `app/assets/javascripts/photos/columns.js`를 포함하려면 다음과 같이 작성합니다:

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

`http://example.com/main.js`를 포함하려면 다음과 같이 작성합니다:

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### `stylesheet_link_tag`을 사용하여 CSS 파일에 링크하기

[`stylesheet_link_tag`][] 헬퍼는 제공된 각 소스에 대해 HTML `<link>` 태그를 반환합니다.

"Asset Pipeline"이 활성화된 Rails를 사용하는 경우, 이 헬퍼는 `/assets/stylesheets/`로 링크를 생성합니다. 이 링크는 Sprockets 젬에 의해 처리됩니다. 스타일시트 파일은 `app/assets`, `lib/assets` 또는 `vendor/assets` 중 하나의 위치에 저장될 수 있습니다.

문서 루트에 대한 전체 경로 또는 URL을 지정할 수 있습니다. 예를 들어, `app/assets`, `lib/assets` 또는 `vendor/assets` 중 하나의 디렉토리 안에 있는 `stylesheets` 디렉토리에 있는 스타일시트 파일에 링크하려면 다음과 같이 작성합니다:

```erb
<%= stylesheet_link_tag "main" %>
```

`app/assets/stylesheets/main.css` 및 `app/assets/stylesheets/columns.css`를 포함하려면 다음과 같이 작성합니다:

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

`app/assets/stylesheets/main.css` 및 `app/assets/stylesheets/photos/columns.css`를 포함하려면 다음과 같이 작성합니다:

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

`http://example.com/main.css`를 포함하려면 다음과 같이 작성합니다:

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

기본적으로 `stylesheet_link_tag`는 `rel="stylesheet"`로 링크를 생성합니다. 이 기본값을 `:rel` 옵션을 지정하여 재정의할 수 있습니다:

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### `image_tag`을 사용하여 이미지에 링크하기

[`image_tag`][] 헬퍼는 지정된 파일에 대한 HTML `<img />` 태그를 생성합니다. 기본적으로 파일은 `public/images`에서 로드됩니다.

경고: 이미지의 확장자를 지정해야 합니다.

```erb
<%= image_tag "header.png" %>
```

원한다면 이미지에 대한 경로를 지정할 수 있습니다:

```erb
<%= image_tag "icons/delete.gif" %>
```

추가적인 HTML 옵션의 해시를 제공할 수 있습니다:

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

이미지가 사용자의 브라우저에서 이미지를 끈 상태로 설정한 경우에 사용할 대체 텍스트를 지정할 수 있습니다. 명시적으로 alt 텍스트를 지정하지 않으면 파일 이름을 대문자로 변환한 후 확장자를 제외한 값이 기본값으로 사용됩니다. 예를 들어, 다음 두 이미지 태그는 동일한 코드를 반환합니다:

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

특정 크기 태그를 "{너비}x{높이}" 형식으로 지정할 수도 있습니다:

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

위의 특수 태그 외에도 `:class`, `:id`, 또는 `:name`과 같은 표준 HTML 옵션의 해시를 제공할 수 있습니다:

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### `video_tag`을 사용하여 비디오에 링크하기

[`video_tag`][] 헬퍼는 지정된 파일에 대한 HTML5 `<video>` 태그를 생성합니다. 기본적으로 파일은 `public/videos`에서 로드됩니다.

```erb
<%= video_tag "movie.ogg" %>
```

다음과 같이 출력됩니다:

```erb
<video src="/videos/movie.ogg" />
```

`image_tag`와 마찬가지로 절대 경로 또는 `public/videos` 디렉토리를 기준으로 상대 경로를 지정할 수 있습니다. 또한 `image_tag`처럼 `size: "#{width}x#{height}"` 옵션을 지정할 수도 있습니다. 비디오 태그는 `id`, `class` 등과 같은 HTML 옵션도 지정할 수 있습니다.

비디오 태그는 HTML 옵션 해시를 통해 `<video>` HTML 옵션을 모두 지원합니다. 이 옵션에는 다음이 포함됩니다:

* `poster: "image_name.png"`는 비디오가 재생되기 전에 비디오 자리에 표시할 이미지를 제공합니다.
* `autoplay: true`는 페이지 로드 시 비디오를 자동으로 재생합니다.
* `loop: true`는 비디오가 끝에 도달하면 비디오를 반복 재생합니다.
* `controls: true`는 사용자가 비디오와 상호 작용할 수 있는 브라우저 제공 컨트롤을 제공합니다.
* `autobuffer: true`는 비디오가 페이지 로드 시 사용자에게 파일을 사전로드합니다.
`video_tag`에 비디오 배열을 전달하여 여러 비디오를 재생할 수도 있습니다:

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

이렇게 하면 다음과 같이 생성됩니다:

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### `audio_tag`를 사용하여 오디오 파일에 링크하기

[`audio_tag`][] 헬퍼는 지정된 파일에 HTML5 `<audio>` 태그를 생성합니다. 기본적으로 파일은 `public/audios`에서 로드됩니다.

```erb
<%= audio_tag "music.mp3" %>
```

원한다면 오디오 파일에 대한 경로를 제공할 수도 있습니다:

```erb
<%= audio_tag "music/first_song.mp3" %>
```

또한 `:id`, `:class` 등과 같은 추가 옵션의 해시를 제공할 수도 있습니다.

`video_tag`와 마찬가지로 `audio_tag`에는 특별한 옵션이 있습니다:

* `autoplay: true`는 페이지 로드 시 오디오를 자동으로 재생합니다.
* `controls: true`는 사용자가 오디오와 상호 작용할 수 있는 브라우저 제공 컨트롤을 제공합니다.
* `autobuffer: true`는 페이지 로드 시 사용자에게 파일을 사전로드합니다.

### `yield` 이해하기

레이아웃의 맥락에서 `yield`는 뷰에서 콘텐츠를 삽입해야 할 섹션을 식별합니다. 가장 간단한 방법은 하나의 `yield`를 가지고 있어서 현재 렌더링되는 뷰의 전체 내용이 삽입되는 것입니다:

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

또한 여러 개의 `yield` 영역을 가진 레이아웃을 만들 수도 있습니다:

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

뷰의 본문은 항상 이름 없는 `yield`에 렌더링됩니다. 이름 있는 `yield`에 콘텐츠를 렌더링하려면 `content_for` 메소드를 사용합니다.

### `content_for` 메소드 사용하기

[`content_for`][] 메소드를 사용하면 레이아웃의 이름 있는 `yield` 블록에 콘텐츠를 삽입할 수 있습니다. 예를 들어, 다음과 같은 뷰는 방금 본 레이아웃과 함께 작동합니다:

```html+erb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

이 페이지를 제공된 레이아웃에 렌더링한 결과는 다음과 같은 HTML입니다:

```html+erb
<html>
  <head>
  <title>A simple page</title>
  </head>
  <body>
  <p>Hello, Rails!</p>
  </body>
</html>
```

`content_for` 메소드는 레이아웃에 사이드바나 푸터와 같은 구분된 영역이 있고 해당 영역에 자체 콘텐츠 블록을 삽입해야 할 때 매우 유용합니다. 또한 페이지별 JavaScript나 CSS 파일을 헤더에 로드하는 태그를 삽입하는 데에도 유용합니다.

### 파셜 사용하기

파셜 템플릿 - 일반적으로 "파셜"이라고 불리는 것 - 은 렌더링 프로세스를 더 관리 가능한 청크로 분할하는 데 사용되는 또 다른 도구입니다. 파셜을 사용하면 특정 응답 조각을 렌더링하는 코드를 자체 파일로 이동할 수 있습니다.

#### 파셜 이름 지정하기

뷰의 일부로 파셜을 렌더링하려면 뷰 내에서 [`render`][view.render] 메소드를 사용합니다:

```html+erb
<%= render "menu" %>
```

이렇게 하면 렌더링 중인 뷰 내에서 `_menu.html.erb`라는 파일이 해당 지점에 렌더링됩니다. 앞에 밑줄 문자가 있는 것에 주목하세요: 파셜은 일반적인 뷰와 구분하기 위해 선행 밑줄 문자로 이름이 지정됩니다. 이는 다른 폴더에서 파셜을 가져올 때에도 마찬가지입니다:

```html+erb
<%= render "shared/menu" %>
```

이 코드는 `app/views/shared/_menu.html.erb`에서 파셜을 가져옵니다.


#### 파셜을 사용하여 뷰 단순화하기

파셜을 사용하는 한 가지 방법은 서브루틴의 동등물로서 사용하는 것입니다. 즉, 뷰에서 세부 정보를 이동하여 더 쉽게 이해할 수 있도록 하는 방법입니다. 예를 들어, 다음과 같은 뷰가 있을 수 있습니다:

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

여기서 `_ad_banner.html.erb`와 `_footer.html.erb` 파셜은 응용 프로그램의 많은 페이지에서 공유되는 콘텐츠를 포함할 수 있습니다. 특정 페이지에 집중할 때 이러한 섹션의 세부 정보를 볼 필요가 없습니다.

이 가이드의 이전 섹션에서 본 대로 `yield`는 레이아웃을 정리하는 데 매우 강력한 도구입니다. 그것은 순수한 루비이므로 거의 모든 곳에서 사용할 수 있습니다. 예를 들어, 여러 유사한 리소스에 대한 폼 레이아웃 정의를 DRY하게 유지하는 데에 사용할 수 있습니다:

* `users/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Name contains: <%= form.text_field :name_contains %>
      </p>
    <% end %>
    ```

* `roles/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Title contains: <%= form.text_field :title_contains %>
      </p>
    <% end %>
    ```
* `shared/_search_filters.html.erb`

    ```html+erb
    <%= form_with model: search do |form| %>
      <h1>검색 양식:</h1>
      <fieldset>
        <%= yield form %>
      </fieldset>
      <p>
        <%= form.submit "검색" %>
      </p>
    <% end %>
    ```

TIP: 애플리케이션의 모든 페이지에서 공유되는 콘텐츠에 대해서는 레이아웃에서 직접 부분을 사용할 수 있습니다.

#### 부분 레이아웃

부분은 뷰가 레이아웃을 사용할 수 있는 것처럼 자체 레이아웃 파일을 사용할 수 있습니다. 예를 들어, 다음과 같이 부분을 호출할 수 있습니다:

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

이는 `_link_area.html.erb`라는 부분을 찾아 `_graybar.html.erb` 레이아웃을 사용하여 렌더링합니다. 부분 레이아웃은 일반 부분과 마찬가지로 선행 언더스코어 네이밍을 따르며, 소속된 부분과 동일한 폴더에 배치됩니다(마스터 `layouts` 폴더에는 배치되지 않음).

또한 `:layout`과 같은 추가 옵션을 전달할 때는 명시적으로 `:partial`을 지정해야 함에 유의하세요.

#### 로컬 변수 전달

부분에도 로컬 변수를 전달할 수 있으므로 더욱 강력하고 유연하게 사용할 수 있습니다. 예를 들어, 이 기법을 사용하여 새로 만들기 페이지와 편집 페이지 간의 중복을 줄이면서도 약간의 고유한 콘텐츠를 유지할 수 있습니다:

* `new.html.erb`

    ```html+erb
    <h1>새로운 존</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>존 편집</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```html+erb
    <%= form_with model: zone do |form| %>
      <p>
        <b>존 이름</b><br>
        <%= form.text_field :name %>
      </p>
      <p>
        <%= form.submit %>
      </p>
    <% end %>
    ```

두 뷰에 동일한 부분이 렌더링되지만, 액션 뷰의 submit 도우미는 새로운 액션에 대해 "존 생성"을 반환하고 편집 액션에 대해 "존 업데이트"를 반환합니다.

특정 경우에만 부분에 로컬 변수를 전달하려면 `local_assigns`를 사용하세요.

* `index.html.erb`

    ```erb
    <%= render user.articles %>
    ```

* `show.html.erb`

    ```erb
    <%= render article, full: true %>
    ```

* `_article.html.erb`

    ```erb
    <h2><%= article.title %></h2>

    <% if local_assigns[:full] %>
      <%= simple_format article.body %>
    <% else %>
      <%= truncate article.body %>
    <% end %>
    ```

이렇게 하면 모든 로컬 변수를 선언할 필요 없이 부분을 사용할 수 있습니다.

모든 부분에는 부분과 동일한 이름의 로컬 변수도 있습니다(선행 언더스코어는 제외). `:object` 옵션을 통해 이 로컬 변수에 객체를 전달할 수 있습니다:

```erb
<%= render partial: "customer", object: @new_customer %>
```

`customer` 부분에서는 `customer` 변수가 상위 뷰의 `@new_customer`를 참조합니다.

모델의 인스턴스를 부분에 렌더링해야 하는 경우, 간단한 구문을 사용할 수 있습니다:

```erb
<%= render @customer %>
```

`@customer` 인스턴스 변수가 `Customer` 모델의 인스턴스를 포함하고 있다고 가정하면, 이것은 `_customer.html.erb`를 사용하여 렌더링하고 부분에 `customer`라는 로컬 변수를 전달합니다. 이 로컬 변수는 상위 뷰의 `@customer` 인스턴스 변수를 참조합니다.

#### 컬렉션 렌더링

부분은 컬렉션을 렌더링하는 데 매우 유용합니다. `:collection` 옵션을 통해 컬렉션을 부분에 전달하면, 컬렉션의 각 멤버에 대해 부분이 한 번씩 삽입됩니다:

* `index.html.erb`

    ```html+erb
    <h1>제품</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>제품 이름: <%= product.name %></p>
    ```

부분이 복수형 컬렉션으로 호출될 때, 부분의 개별 인스턴스는 렌더링되는 컬렉션의 멤버에 대한 변수인 부분 이름을 통해 액세스할 수 있습니다. 이 경우 부분은 `_product`이며, `_product` 부분 내에서 렌더링되는 인스턴스에 대해 `product`를 참조할 수 있습니다.

이에 대한 약식 표현도 있습니다. `@products`가 `Product` 인스턴스의 컬렉션이라면, `index.html.erb`에 다음과 같이 간단히 작성하여 동일한 결과를 얻을 수 있습니다:

```html+erb
<h1>제품</h1>
<%= render @products %>
```

Rails는 컬렉션의 모델 이름을 보고 사용할 부분의 이름을 결정합니다. 실제로 이 방법으로 이루어진 이질적인 컬렉션을 생성하고 렌더링할 수도 있으며, Rails는 컬렉션의 각 멤버에 대해 적절한 부분을 선택합니다:

* `index.html.erb`

    ```html+erb
    <h1>연락처</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    ```

* `customers/_customer.html.erb`

    ```html+erb
    <p>고객: <%= customer.name %></p>
    ```

* `employees/_employee.html.erb`

    ```html+erb
    <p>직원: <%= employee.name %></p>
    ```

이 경우, Rails는 컬렉션의 각 멤버에 대해 적절한 고객 또는 직원 부분을 사용합니다.
컬렉션이 비어있는 경우, `render`는 nil을 반환하므로 대체 콘텐츠를 제공하는 것은 매우 간단합니다.

```html+erb
<h1>제품</h1>
<%= render(@products) || "사용 가능한 제품이 없습니다." %>
```

#### 로컬 변수

파셜 내에서 사용자 정의 로컬 변수 이름을 사용하려면, 파셜 호출에서 `:as` 옵션을 지정하면 됩니다:

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

이 변경으로 인해, 파셜 내에서 `@products` 컬렉션의 인스턴스에 `item` 로컬 변수로 액세스할 수 있습니다.

`locals: {}` 옵션을 사용하여 렌더링하는 모든 파셜에 임의의 로컬 변수를 전달할 수도 있습니다:

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "제품 페이지"} %>
```

이 경우, 파셜은 값이 "제품 페이지"인 `title` 로컬 변수에 액세스할 수 있습니다.

#### 카운터 변수

Rails는 컬렉션에 의해 호출된 파셜 내에서도 카운터 변수를 사용할 수 있습니다. 이 변수는 파셜의 제목 뒤에 `_counter`가 붙은 이름으로 지정됩니다. 예를 들어, `@products` 컬렉션을 렌더링할 때 `_product.html.erb` 파셜은 `product_counter` 변수에 액세스할 수 있습니다. 이 변수는 렌더링된 파셜의 횟수를 인덱싱하며, 첫 번째 렌더링에서는 `0`의 값을 가집니다.

```erb
# index.html.erb
<%= render partial: "product", collection: @products %>
```

```erb
# _product.html.erb
<%= product_counter %> # 첫 번째 제품은 0, 두 번째 제품은 1...
```

`as:` 옵션을 사용하여 파셜 이름을 변경한 경우에도 동작합니다. 따라서 `as: :item`을 사용한 경우 카운터 변수는 `item_counter`가 됩니다.

#### 간격 템플릿

`spacer_template` 옵션을 사용하여 메인 파셜의 인스턴스 사이에 두 번째 파셜을 지정할 수도 있습니다:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails는 `_product_ruler` 파셜을 (데이터를 전달하지 않고) 각 `_product` 파셜 쌍 사이에 렌더링합니다.

#### 컬렉션 파셜 레이아웃

컬렉션을 렌더링할 때 `layout` 옵션을 사용할 수도 있습니다:

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

레이아웃은 컬렉션의 각 항목과 함께 렌더링됩니다. 현재 객체와 `object_counter` 변수도 레이아웃에서 사용할 수 있으며, 파셜 내에서와 동일한 방식으로 사용할 수 있습니다.

### 중첩된 레이아웃 사용

일부 컨트롤러를 지원하기 위해 일반적인 애플리케이션 레이아웃과 약간 다른 레이아웃이 필요한 경우, 메인 레이아웃을 반복하고 편집하는 대신 중첩된 레이아웃(때로는 서브 템플릿이라고도 함)을 사용하여 이를 수행할 수 있습니다. 다음은 예입니다:

다음과 같은 `ApplicationController` 레이아웃이 있다고 가정해 보겠습니다:

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "페이지 제목" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">상단 메뉴 항목</div>
      <div id="menu">메뉴 항목</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

`NewsController`에서 생성된 페이지에서 상단 메뉴를 숨기고 오른쪽 메뉴를 추가하려고 합니다:

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">오른쪽 메뉴 항목</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

이것으로 끝입니다. News 뷰는 새로운 레이아웃을 사용하여 상단 메뉴를 숨기고 "content" div 내에 새로운 오른쪽 메뉴를 추가합니다.

이 기술을 사용하여 다른 서브 템플릿 체계로 유사한 결과를 얻는 방법은 여러 가지가 있습니다. 중첩 수준에 제한이 없다는 점에 유의하십시오. 새로운 레이아웃을 News 레이아웃을 기반으로 하기 위해 `ActionView::render` 메서드를 `render template: 'layouts/news'`를 통해 사용할 수 있습니다. `News` 레이아웃을 서브 템플릿화하지 않을 것이라고 확신하는 경우, `content_for?(:news_content) ? yield(:news_content) : yield`를 단순히 `yield`로 대체할 수 있습니다.
[controller.render]: https://api.rubyonrails.org/classes/ActionController/Rendering.html#method-i-render
[`redirect_to`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to
[`head`]: https://api.rubyonrails.org/classes/ActionController/Head.html#method-i-head
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`redirect_back`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_back
[`content_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for
[`auto_discovery_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-auto_discovery_link_tag
[`javascript_include_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-javascript_include_tag
[`stylesheet_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-stylesheet_link_tag
[`image_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag
[`video_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-video_tag
[`audio_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-audio_tag
[view.render]: https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render
