**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 975163c53746728404fb3a3658fbd0f6
Action View Form Helpers
========================

웹 애플리케이션에서 폼은 사용자 입력을 위한 필수적인 인터페이스입니다. 그러나 폼 마크업은 폼 컨트롤의 이름과 여러 속성을 처리해야 하기 때문에 작성하고 유지 관리하기 번거로울 수 있습니다. Rails는 폼 마크업을 생성하기 위한 뷰 헬퍼를 제공하여 이 복잡성을 해결합니다. 그러나 이러한 헬퍼들은 서로 다른 사용 사례를 가지고 있으므로 개발자는 헬퍼 메서드의 차이점을 알고 사용하기 전에 알아야 합니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* 응용 프로그램에서 특정 모델을 나타내지 않는 검색 폼 및 유사한 일반적인 폼을 생성하는 방법.
* 특정 데이터베이스 레코드를 생성하고 편집하기 위한 모델 중심의 폼을 만드는 방법.
* 다양한 유형의 데이터에서 선택 상자를 생성하는 방법.
* Rails가 제공하는 날짜 및 시간 헬퍼.
* 파일 업로드 폼의 차이점.
* 외부 리소스로 폼을 전송하고 `authenticity_token`을 설정하는 방법.
* 복잡한 폼을 구축하는 방법.

--------------------------------------------------------------------------------

참고: 이 가이드는 사용 가능한 폼 헬퍼와 그 인수에 대한 완전한 문서가 아닙니다. 모든 사용 가능한 헬퍼에 대한 완전한 참조를 위해 [Rails API 문서](https://api.rubyonrails.org/classes/ActionView/Helpers.html)를 방문하십시오.

기본 폼 다루기
------------------------

주요 폼 헬퍼는 [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)입니다.

```erb
<%= form_with do |form| %>
  폼 내용
<% end %>
```

이와 같이 인수 없이 호출하면 제출되면 현재 페이지로 POST되는 폼 태그를 생성합니다. 예를 들어, 현재 페이지가 홈 페이지인 경우 생성된 HTML은 다음과 같습니다:

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  폼 내용
</form>
```

HTML에는 `hidden` 타입의 `input` 요소가 포함되어 있는 것을 알 수 있습니다. 이 `input`은 중요합니다. 왜냐하면 `GET`이 아닌 폼은 이 요소 없이는 제대로 제출되지 않기 때문입니다.
`authenticity_token`이라는 이름의 숨겨진 입력 요소는 Rails의 **크로스 사이트 요청 위조(CSRF) 보호**라는 보안 기능이며, 폼 헬퍼는 이를 모든 `GET`이 아닌 폼에 대해 생성합니다(이 보안 기능이 활성화된 경우). 이에 대해 더 자세히 알아보려면 [Rails 애플리케이션 보안](security.html#cross-site-request-forgery-csrf) 가이드를 참조하십시오.

### 일반적인 검색 폼

웹에서 가장 기본적인 폼 중 하나는 검색 폼입니다. 이 폼에는 다음이 포함됩니다:

* "GET" 메서드를 사용하는 폼 요소,
* 입력에 대한 레이블,
* 텍스트 입력 요소 및
* 제출 요소.

이 폼을 생성하려면 `form_with`와 해당 폼 빌더 객체를 사용합니다. 다음과 같이:

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Search for:" %>
  <%= form.text_field :query %>
  <%= form.submit "Search" %>
<% end %>
```

이렇게 하면 다음과 같은 HTML이 생성됩니다:

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Search for:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Search" data-disable-with="Search" />
</form>
```

팁: `form_with`에 `url: my_specified_path`를 전달하면 폼이 요청을 보낼 위치를 지정합니다. 그러나 아래에서 설명하는 대로 Active Record 객체를 폼에 전달할 수도 있습니다.

팁: 각 폼 입력에는 이름(`위의 예제에서는 "query"`)에서 ID 속성이 생성됩니다. 이 ID는 CSS 스타일링이나 JavaScript를 사용하여 폼 컨트롤을 조작하는 데 매우 유용할 수 있습니다.

중요: 검색 폼에는 "GET"을 사용하십시오. 이렇게 하면 사용자가 특정 검색을 즐겨찾기에 추가하고 다시 해당 검색으로 돌아갈 수 있습니다. 일반적으로 Rails는 작업에 적합한 HTTP 동사를 사용하도록 권장합니다.

### 폼 요소 생성을 위한 헬퍼

`form_with`에 의해 생성된 폼 빌더 객체는 텍스트 필드, 체크박스, 라디오 버튼과 같은 폼 요소를 생성하기 위한 다양한 헬퍼 메서드를 제공합니다. 이러한 메서드의 첫 번째 매개변수는 항상 입력의 이름입니다.
폼이 제출되면 이름은 폼 데이터와 함께 전달되어 컨트롤러의 `params`로 전달되며, 사용자가 해당 필드에 입력한 값과 함께 도달합니다. 예를 들어, 폼에 `<%= form.text_field :query %>`가 포함되어 있다면 컨트롤러에서 이 필드의 값을 `params[:query]`로 가져올 수 있습니다.
입력을 이름 지을 때, Rails는 `params`에서도 접근 가능한 배열이나 해시와 같은 비스칼라 값으로 매개변수를 제출할 수 있도록 특정 규칙을 사용합니다. 이에 대한 자세한 내용은 이 가이드의 [파라미터 네이밍 규칙 이해](#understanding-parameter-naming-conventions) 섹션에서 더 자세히 알아볼 수 있습니다. 이 도우미들의 정확한 사용법에 대한 자세한 내용은 [API 문서](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)를 참조하십시오.

#### 체크박스

체크박스는 사용자가 활성화 또는 비활성화할 수 있는 옵션 세트를 제공하는 폼 컨트롤입니다:

```erb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "나는 개를 소유하고 있습니다" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "나는 고양이를 소유하고 있습니다" %>
```

다음과 같이 생성됩니다:

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">나는 개를 소유하고 있습니다</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">나는 고양이를 소유하고 있습니다</label>
```

[`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box)의 첫 번째 매개변수는 입력의 이름입니다. 체크박스의 값(즉, `params`에 표시될 값)은 선택적으로 세 번째와 네 번째 매개변수를 사용하여 지정할 수 있습니다. 자세한 내용은 API 문서를 참조하십시오.

#### 라디오 버튼

라디오 버튼은 체크박스와 유사하지만, 사용자가 하나만 선택할 수 있는 옵션 세트를 지정하는 컨트롤입니다:

```erb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "나는 21세 미만입니다" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "나는 21세 이상입니다" %>
```

출력:

```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">나는 21세 미만입니다</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">나는 21세 이상입니다</label>
```

[`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button)의 두 번째 매개변수는 입력의 값입니다. 이 두 개의 라디오 버튼은 동일한 이름(`age`)을 공유하기 때문에 사용자는 그 중 하나만 선택할 수 있으며, `params[:age]`에는 `"child"` 또는 `"adult"`가 포함됩니다.

참고: 체크박스와 라디오 버튼에는 항상 레이블을 사용하십시오. 레이블은 특정 옵션과 텍스트를 연결하여 입력을 클릭하기 쉽게 만들어주는 역할을 합니다.

### 관련된 다른 도우미들

기타 양식 컨트롤 중 주목할만한 것은 텍스트 영역, 숨겨진 필드, 비밀번호 필드, 숫자 필드, 날짜 및 시간 필드 등이 있습니다:

```erb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```

출력:

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```

숨겨진 입력은 사용자에게 표시되지 않고 일반 텍스트 입력과 마찬가지로 데이터를 보유합니다. 그 안에 있는 값은 JavaScript로 변경할 수 있습니다.

중요: 검색, 전화, 날짜, 시간, 색상, 날짜 및 시간, 월, 주, URL, 이메일, 숫자 및 범위 입력은 HTML5 컨트롤입니다. 오래된 브라우저에서 일관된 경험을 제공하기 위해 앱을 사용하는 경우 HTML5 폴리필(CSS 및/또는 JavaScript로 제공)이 필요합니다. 이에 대한 [해결책이 부족하지 않습니다](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills), 하지만 현재 인기있는 도구 중 하나는 [Modernizr](https://modernizr.com/)입니다. Modernizr는 감지된 HTML5 기능의 존재에 따라 기능을 추가하는 간단한 방법을 제공합니다.
팁: 비밀번호 입력 필드를 사용하는 경우 (어떤 목적으로든), 응용 프로그램을 구성하여 해당 매개 변수가 로그에 기록되지 않도록 할 수 있습니다. 이에 대해는 [Rails 애플리케이션 보안](security.html#logging) 가이드에서 자세히 알아볼 수 있습니다.

모델 객체 다루기
--------------------------

### 양식과 객체 바인딩

`form_with`의 `:model` 인수를 사용하면 양식 빌더 객체를 모델 객체에 바인딩할 수 있습니다. 이는 양식이 해당 모델 객체에 대해 범위가 지정되고, 양식의 필드가 해당 모델 객체의 값으로 채워지게 됨을 의미합니다.

예를 들어, 다음과 같은 `@article` 모델 객체가 있다고 가정해 봅시다:

```ruby
@article = Article.find(42)
# => #<Article id: 42, title: "My Title", body: "My Body">
```

다음과 같은 양식이 있다면:

```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

다음과 같이 출력됩니다:

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="My Title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    My Body
  </textarea>
  <input type="submit" name="commit" value="Update Article" data-disable-with="Update Article">
</form>
```

여기서 주목해야 할 몇 가지 사항이 있습니다:

* 양식의 `action`은 자동으로 `@article`에 대한 적절한 값으로 채워집니다.
* 양식 필드는 `@article`의 해당 값으로 자동으로 채워집니다.
* 양식 필드 이름은 `article[...]`로 범위가 지정됩니다. 이는 `params[:article]`이 이 필드의 모든 값을 포함하는 해시가 됨을 의미합니다. 이 가이드의 [파라미터 네이밍 규칙 이해](#understanding-parameter-naming-conventions) 장에서 입력 이름의 중요성에 대해 더 읽어볼 수 있습니다.
* 제출 버튼은 자동으로 적절한 텍스트 값을 가집니다.

팁: 일반적으로 입력은 모델 속성과 일치할 것입니다. 그러나 그렇지 않아도 됩니다! 필요한 다른 정보가 있으면 속성과 마찬가지로 양식에 포함시킬 수 있으며, `params[:article][:my_nifty_non_attribute_input]`을 통해 액세스할 수 있습니다.

#### `fields_for` 도우미

[`fields_for`][] 도우미는 `<form>` 태그를 렌더링하지 않고도 유사한 바인딩을 생성합니다. 이를 사용하여 동일한 양식 내에서 추가 모델 객체의 필드를 렌더링할 수 있습니다. 예를 들어, `Person` 모델에 연관된 `ContactDetail` 모델이 있는 경우 다음과 같이 두 모델에 대한 단일 양식을 만들 수 있습니다:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

다음과 같은 출력이 생성됩니다:

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

`fields_for`에 의해 생성된 객체는 `form_with`에 의해 생성된 양식 빌더와 동일한 형태입니다.


### 레코드 식별에 의존하기

Article 모델은 응용 프로그램의 사용자에게 직접적으로 사용 가능하므로, Rails로 개발하는 최선의 방법을 따르기 위해 **리소스**로 선언해야 합니다:

```ruby
resources :articles
```

팁: 리소스를 선언하는 것에는 여러 가지 부작용이 있습니다. 리소스를 설정하고 사용하는 방법에 대한 자세한 내용은 [Rails 외부에서 라우팅](routing.html#resource-routing-the-rails-default) 가이드를 참조하십시오.

RESTful 리소스를 다룰 때는 **레코드 식별**에 의존하는 것이 훨씬 쉬워집니다. 간단히 말해서, 모델 인스턴스를 전달하기만 하면 Rails가 모델 이름과 나머지를 자동으로 처리할 수 있습니다. 이 두 가지 예제에서 긴 스타일과 짧은 스타일은 동일한 결과를 가집니다:

```ruby
## 새로운 article 생성
# 긴 스타일:
form_with(model: @article, url: articles_path)
# 짧은 스타일:
form_with(model: @article)

## 기존 article 편집
# 긴 스타일:
form_with(model: @article, url: article_path(@article), method: "patch")
# 짧은 스타일:
form_with(model: @article)
```

짧은 스타일 `form_with` 호출은 레코드가 새로운지 기존인지에 관계없이 편리하게 동일합니다. 레코드 식별은 `record.persisted?`를 통해 레코드가 새로운지 여부를 스스로 확인할 수 있습니다. 또한 제출할 경로와 객체의 클래스에 기반한 이름을 올바르게 선택합니다.
[단수 리소스](routing.html#singular-resources)가 있는 경우 `form_with`와 함께 작동하려면 `resource`와 `resolve`를 호출해야합니다.

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

경고: 모델에 STI (단일 테이블 상속)를 사용하는 경우 부모 클래스만 리소스로 선언되었을 때 자식 클래스의 레코드 식별에 의존할 수 없습니다. `:url` 및 `:scope` (모델 이름)를 명시적으로 지정해야합니다.

#### 네임스페이스 처리

네임스페이스 된 라우트를 생성한 경우 `form_with`에는 간편한 약어가 있습니다. 애플리케이션이 admin 네임스페이스를 가지고 있다면

```ruby
form_with model: [:admin, @article]
```

는 admin 네임스페이스 내의 `ArticlesController`로 제출되는 폼을 생성합니다 (업데이트의 경우 `admin_article_path(@article)`로 제출됨). 네임스페이스의 수준이 여러 개인 경우 구문은 유사합니다.

```ruby
form_with model: [:admin, :management, @article]
```

Rails의 라우팅 시스템과 관련된 규칙에 대한 자세한 정보는 [Rails Routing from the Outside In](routing.html) 가이드를 참조하십시오.

### PATCH, PUT 또는 DELETE 메서드를 사용하는 양식은 어떻게 작동합니까?

Rails 프레임워크는 응용 프로그램의 RESTful 디자인을 장려하므로 "GET" 및 "POST" 외에도 "PATCH", "PUT" 및 "DELETE" 요청을 많이 수행하게됩니다. 그러나 대부분의 브라우저는 양식 제출시 "GET" 및 "POST" 외의 메서드를 지원하지 _않습니다_.

Rails는 이 문제를 해결하기 위해 `"_method"`라는 이름의 숨겨진 입력을 사용하여 POST를 통해 다른 메서드를 에뮬레이션합니다. 이 입력은 원하는 메서드를 반영하도록 설정됩니다.

```ruby
form_with(url: search_path, method: "patch")
```

출력:

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->
</form>
```

POST된 데이터를 구문 분석할 때 Rails는 특수한 `_method` 매개 변수를 고려하여 그 안에 지정된 HTTP 메서드와 동일한 것으로 작동합니다 (이 예제에서는 "PATCH"입니다).

양식을 렌더링 할 때 제출 버튼은 `formmethod:` 키워드를 통해 선언 된 `method` 속성을 재정의 할 수 있습니다.

```erb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Delete", formmethod: :delete, data: { confirm: "Are you sure?" } %>
  <%= form.button "Update" %>
<% end %>
```

`<form>` 요소와 유사하게 대부분의 브라우저는 [formmethod][]를 통해 선언 된 양식 메서드를 재정의하는 것을 _지원하지 않습니다_.

Rails는 [formmethod][], [value][button-value] 및 [name][button-name] 속성의 조합을 통해 POST를 통해 다른 메서드를 에뮬레이션하여 이 문제를 해결합니다.

```html
<form accept-charset="UTF-8" action="/posts/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->

  <button type="submit" formmethod="post" name="_method" value="delete" data-confirm="Are you sure?">Delete</button>
  <button type="submit" name="button">Update</button>
</form>
```


쉽게 선택 상자 만들기
-----------------------------

HTML에서 선택 상자는 상당한 양의 마크업이 필요합니다. 이런 부담을 줄이기 위해 Rails는 도우미 메서드를 제공합니다.

예를 들어, 사용자가 선택할 도시 목록이 있는 경우 [`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select) 도우미를 다음과 같이 사용할 수 있습니다.

```erb
<%= form.select :city, ["Berlin", "Chicago", "Madrid"] %>
```

출력:

```html
<select name="city" id="city">
  <option value="Berlin">Berlin</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```

또한 레이블과 다른 `<option>` 값을 지정할 수 있습니다.

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
```

출력:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

이렇게하면 사용자는 전체 도시 이름을 볼 수 있지만 `params[:city]`는 `"BE"`, `"CHI"`, `"MD"` 중 하나가 됩니다.

마지막으로 `:selected` 인수를 사용하여 선택 상자에 대한 기본 선택을 지정할 수 있습니다.

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]], selected: "CHI" %>
```

출력:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

### 옵션 그룹

일부 경우에는 관련 옵션을 그룹화하여 사용자 경험을 개선하고 싶을 수 있습니다. 이를 위해 `select`에 `Hash` (또는 비교 가능한 `Array`)를 전달할 수 있습니다.
```erb
<%= form.select :city,
      {
        "유럽" => [ ["베를린", "BE"], ["마드리드", "MD"] ],
        "북미" => [ ["시카고", "CHI"] ],
      },
      selected: "CHI" %>
```

Output:

```html
<select name="city" id="city">
  <optgroup label="유럽">
    <option value="BE">베를린</option>
    <option value="MD">마드리드</option>
  </optgroup>
  <optgroup label="북미">
    <option value="CHI" selected="selected">시카고</option>
  </optgroup>
</select>
```

### 선택 상자와 모델 객체

다른 폼 컨트롤과 마찬가지로 선택 상자는 모델 속성에 바인딩될 수 있습니다. 예를 들어, 다음과 같은 `@person` 모델 객체가 있다고 가정해 봅시다:

```ruby
@person = Person.new(city: "MD")
```

다음과 같은 폼:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["베를린", "BE"], ["시카고", "CHI"], ["마드리드", "MD"]] %>
<% end %>
```

다음과 같은 선택 상자를 출력합니다:

```html
<select name="person[city]" id="person_city">
  <option value="BE">베를린</option>
  <option value="CHI">시카고</option>
  <option value="MD" selected="selected">마드리드</option>
</select>
```

적절한 옵션이 자동으로 `selected="selected"`로 표시되었음을 알 수 있습니다. 이 선택 상자는 모델에 바인딩되었기 때문에 `:selected` 인수를 지정할 필요가 없었습니다!

### 시간대와 국가 선택

Rails에서 시간대 지원을 활용하려면 사용자에게 어떤 시간대에 있는지 물어봐야 합니다. 이를 위해 미리 정의된 [`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html) 객체 목록에서 선택 옵션을 생성해야 할 수도 있지만, 이미 이를 감싸고 있는 [`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select) 헬퍼를 사용할 수 있습니다:

```erb
<%= form.time_zone_select :time_zone %>
```

Rails에는 국가 선택을 위한 `country_select` 헬퍼가 있었지만, 이는 [country_select 플러그인](https://github.com/stefanpenner/country_select)으로 분리되었습니다.

날짜 및 시간 폼 헬퍼 사용하기
--------------------------------

HTML5 날짜 및 시간 입력을 사용하지 않으려는 경우, Rails는 일반적인 선택 상자를 렌더링하는 대체 날짜 및 시간 폼 헬퍼를 제공합니다. 이러한 헬퍼는 각 시간 구성 요소(예: 연도, 월, 일 등)에 대해 선택 상자를 렌더링합니다. 예를 들어, 다음과 같은 `@person` 모델 객체가 있다고 가정해 봅시다:

```ruby
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

다음과 같은 폼:

```erb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

다음과 같은 선택 상자를 출력합니다:

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">1월</option>
  <option value="2">2월</option>
  <option value="3">3월</option>
  <option value="4">4월</option>
  <option value="5">5월</option>
  <option value="6">6월</option>
  <option value="7">7월</option>
  <option value="8">8월</option>
  <option value="9">9월</option>
  <option value="10">10월</option>
  <option value="11">11월</option>
  <option value="12" selected="selected">12월</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1일</option>
  ...
  <option value="21" selected="selected">21일</option>
  ...
  <option value="31">31일</option>
</select>
```

폼이 제출될 때, 전체 날짜를 나타내는 `params` 해시에는 단일 값이 없습니다. 대신 `"birth_date(1i)"`와 같은 특별한 이름을 가진 여러 값이 있습니다. Active Record는 이러한 특별한 이름을 가진 값을 모델 속성의 선언된 유형에 따라 전체 날짜나 시간으로 조립할 수 있습니다. 따라서 폼이 전체 날짜를 나타내는 단일 필드를 사용하는 경우와 마찬가지로 `params[:person]`을 `Person.new`나 `Person#update`에 전달할 수 있습니다.

[`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select) 헬퍼 외에도 Rails는 [`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select)와 [`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select)를 제공합니다.

### 개별 시간 구성 요소를 위한 선택 상자

Rails는 개별 시간 구성 요소에 대한 선택 상자를 렌더링하기 위한 헬퍼도 제공합니다: [`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year), [`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month), [`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day), [`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour), [`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute) 및 [`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second). 이러한 헬퍼는 폼 빌더 인스턴스에서 호출되지 않는 "베어" 메서드입니다. 예를 들어:

```erb
<%= select_year 1999, prefix: "party" %>
```

다음과 같은 선택 상자를 출력합니다:

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

이러한 헬퍼 각각에 대해 기본값으로 숫자 대신 날짜나 시간 객체를 지정할 수 있으며, 적절한 시간 구성 요소가 추출되어 사용됩니다.

임의의 객체 컬렉션에서 선택 항목 가져오기
----------------------------------------------

가끔은 임의의 객체 컬렉션에서 선택 항목 집합을 생성하고 싶을 때가 있습니다. 예를 들어, `City` 모델과 해당 `belongs_to :city` 연관성이 있는 경우:

```ruby
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```

```ruby
City.order(:name).map { |city| [city.name, city.id] }
# => [["Berlin", 3], ["Chicago", 1], ["Madrid", 2]]
```

그런 다음 다음 양식을 사용하여 사용자가 데이터베이스에서 도시를 선택할 수 있도록 할 수 있습니다:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

참고: `belongs_to` 연관성의 필드를 렌더링할 때는 연관성 자체의 이름이 아닌 외래 키의 이름(`위의 예에서는 city_id`)을 지정해야 합니다.

그러나 Rails는 컬렉션에서 명시적으로 반복하지 않고도 선택 항목을 생성하는 도우미를 제공합니다. 이러한 도우미는 컬렉션의 각 객체에 지정된 메서드를 호출하여 각 선택 항목의 값과 텍스트 레이블을 결정합니다.

### `collection_select` 도우미

셀렉트 박스를 생성하려면 [`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select)를 사용할 수 있습니다:

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

출력:

```html
<select name="person[city_id]" id="person_city_id">
  <option value="3">Berlin</option>
  <option value="1">Chicago</option>
  <option value="2">Madrid</option>
</select>
```

참고: `collection_select`에서는 먼저 값을 지정하는 메서드(`위의 예에서는 :id`)를 지정하고, 그 다음 텍스트 레이블 메서드(`위의 예에서는 :name`)를 지정합니다. 이는 `select` 도우미에 대한 선택 항목을 지정할 때 사용되는 순서와 반대입니다. 여기서는 텍스트 레이블이 먼저 오고 값이 두 번째로 옵니다.

### `collection_radio_buttons` 도우미

라디오 버튼 집합을 생성하려면 [`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons)를 사용할 수 있습니다:

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

출력:

```html
<input type="radio" name="person[city_id]" value="3" id="person_city_id_3">
<label for="person_city_id_3">Berlin</label>

<input type="radio" name="person[city_id]" value="1" id="person_city_id_1">
<label for="person_city_id_1">Chicago</label>

<input type="radio" name="person[city_id]" value="2" id="person_city_id_2">
<label for="person_city_id_2">Madrid</label>
```

### `collection_check_boxes` 도우미

체크 박스 집합을 생성하려면 [`collection_check_boxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes)를 사용할 수 있습니다. 예를 들어, `has_and_belongs_to_many` 연관성을 지원하기 위해:

```erb
<%= form.collection_check_boxes :interest_ids, Interest.order(:name), :id, :name %>
```

출력:

```html
<input type="checkbox" name="person[interest_id][]" value="3" id="person_interest_id_3">
<label for="person_interest_id_3">Engineering</label>

<input type="checkbox" name="person[interest_id][]" value="4" id="person_interest_id_4">
<label for="person_interest_id_4">Math</label>

<input type="checkbox" name="person[interest_id][]" value="1" id="person_interest_id_1">
<label for="person_interest_id_1">Science</label>

<input type="checkbox" name="person[interest_id][]" value="2" id="person_interest_id_2">
<label for="person_interest_id_2">Technology</label>
```

파일 업로드
---------------

일반적인 작업 중 하나는 사람의 사진이나 데이터를 처리하는 CSV 파일과 같은 파일을 업로드하는 것입니다. 파일 업로드 필드는 [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) 도우미로 렌더링할 수 있습니다.

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

파일 업로드에서 가장 중요한 것은 렌더링된 양식의 `enctype` 속성을 "multipart/form-data"로 설정해야 한다는 것입니다. 이는 `form_with` 내부에 `file_field`를 사용하면 자동으로 수행됩니다. 속성을 수동으로 설정할 수도 있습니다:

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :picture %>
<% end %>
```

`form_with` 규칙에 따라 위의 두 양식의 필드 이름도 다를 것입니다. 즉, 첫 번째 양식의 필드 이름은 `person[picture]`가 될 것이며 (`params[:person][:picture]`로 접근 가능), 두 번째 양식의 필드 이름은 `picture`가 될 것입니다 (`params[:picture]`로 접근 가능).

### 업로드되는 내용

`params` 해시의 객체는 [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html)의 인스턴스입니다. 다음 코드 조각은 업로드된 파일을 원래 파일과 동일한 이름으로 `#{Rails.root}/public/uploads`에 저장합니다.

```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

파일이 업로드되면 디스크, Amazon S3 등에 파일을 저장하는 위치, 모델과 연결하는 방법, 이미지 파일 크기 조정, 썸네일 생성 등 다양한 작업을 수행할 수 있습니다. [Active Storage](active_storage_overview.html)는 이러한 작업을 지원하기 위해 설계되었습니다.
Form Builders 사용자 정의
-------------------------

`form_with`와 `fields_for`에 의해 생성된 객체는 [`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html)의 인스턴스입니다. Form builders는 단일 객체에 대한 폼 요소를 표시하는 개념을 캡슐화합니다. 일반적인 방법으로 폼에 대한 도우미를 작성할 수 있지만, `ActionView::Helpers::FormBuilder`의 서브클래스를 생성하고 도우미를 추가할 수도 있습니다. 예를 들어,

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

다음과 같이 대체할 수 있습니다.

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

다음과 같이 `LabellingFormBuilder` 클래스를 정의함으로써:

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    label(attribute) + super
  end
end
```

자주 재사용한다면 `builder: LabellingFormBuilder` 옵션을 자동으로 적용하는 `labeled_form_with` 도우미를 정의할 수 있습니다.

```ruby
def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
  options[:builder] = LabellingFormBuilder
  form_with model: model, scope: scope, url: url, format: format, **options, &block
end
```

사용된 폼 빌더에 따라 다음과 같은 동작이 결정됩니다.

```erb
<%= render partial: f %>
```

`f`가 `ActionView::Helpers::FormBuilder`의 인스턴스인 경우, 이는 `form` 부분을 렌더링하고 부분의 객체를 폼 빌더로 설정합니다. 폼 빌더가 `LabellingFormBuilder` 클래스인 경우, 대신 `labelling_form` 부분이 렌더링됩니다.

매개변수 명명 규칙 이해하기
------------------------------------------

폼에서의 값은 `params` 해시의 최상위 수준에 있을 수도 있고 다른 해시에 중첩될 수도 있습니다. 예를 들어, Person 모델의 표준 `create` 액션에서는 `params[:person]`이 일반적으로 생성할 사람의 모든 속성을 포함한 해시입니다. `params` 해시는 배열, 해시의 배열 등을 포함할 수도 있습니다.

HTML 폼은 기본적으로 구조화된 데이터에 대해 알지 못합니다. 생성되는 것은 이름-값 쌍으로, 쌍은 일반 문자열입니다. 응용 프로그램에서 보는 배열과 해시는 Rails가 사용하는 일부 매개변수 명명 규칙의 결과입니다.

### 기본 구조

두 가지 기본 구조는 배열과 해시입니다. 해시는 `params`에서 값을 액세스하는 데 사용되는 구문과 동일합니다. 예를 들어, 폼에 다음과 같이 포함된 경우:

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

`params` 해시에는 다음과 같이 포함됩니다.

```ruby
{ 'person' => { 'name' => 'Henry' } }
```

그리고 `params[:person][:name]`은 컨트롤러에서 제출된 값을 검색합니다.

해시는 필요한 만큼 중첩될 수 있습니다. 예를 들어:

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

위의 폼은 `params` 해시가 다음과 같이 됩니다.

```ruby
{ 'person' => { 'address' => { 'city' => 'New York' } } }
```

일반적으로 Rails는 중복된 매개변수 이름을 무시합니다. 매개변수 이름이 빈 대괄호 `[]`로 끝나면 배열에 누적됩니다. 사용자가 여러 전화번호를 입력할 수 있도록 하려면, 폼에 다음과 같이 배치할 수 있습니다.

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

이렇게 하면 `params[:person][:phone_number]`에 입력된 전화번호가 포함된 배열이 됩니다.

### 이들을 결합하기

이러한 두 개념을 혼합할 수 있습니다. 해시의 요소 중 하나는 이전 예제와 같이 배열일 수도 있고, 해시의 배열일 수도 있습니다. 예를 들어, 폼에서 다음과 같은 폼 조각을 반복하여 임의의 수의 주소를 생성할 수 있습니다.

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

이렇게 하면 `params[:person][:addresses]`에 `line1`, `line2`, `city` 키를 가진 해시의 배열이 됩니다.

그러나 제한이 있습니다. 해시는 임의로 중첩될 수 있지만 "배열성"의 단계는 하나로 제한됩니다. 배열은 일반적으로 해시로 대체될 수 있습니다. 예를 들어, 모델 객체의 배열 대신 id, 배열 인덱스 또는 기타 매개변수로 키가 지정된 모델 객체의 해시를 가질 수 있습니다.
경고: 배열 매개변수는 `check_box` 도우미와 잘 작동하지 않습니다. HTML 사양에 따르면 선택되지 않은 체크박스는 값을 제출하지 않습니다. 그러나 체크박스가 항상 값을 제출하는 것이 편리한 경우가 많습니다. `check_box` 도우미는 동일한 이름을 가진 보조 숨겨진 입력을 생성하여 이를 가장합니다. 체크박스가 선택되지 않은 경우에는 숨겨진 입력만 제출되고 선택된 경우에는 둘 다 제출되지만 체크박스가 제출하는 값이 우선합니다.

### `fields_for` 도우미 `:index` 옵션

사람의 각 주소에 대한 필드 세트로 폼을 렌더링하려는 경우 [`fields_for`][] 도우미와 `:index` 옵션을 사용할 수 있습니다:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

사람이 ID가 23과 45인 두 개의 주소를 가지고 있다고 가정하면 위의 폼은 다음과 유사한 출력을 생성합니다:

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

이는 다음과 같은 `params` 해시를 생성합니다:

```ruby
{
  "person" => {
    "name" => "Bob",
    "address" => {
      "23" => {
        "city" => "Paris"
      },
      "45" => {
        "city" => "London"
      }
    }
  }
}
```

폼 입력은 모두 `"person"` 해시에 매핑되며, `fields_for`를 `person_form` 폼 빌더에 호출했기 때문입니다. 또한 `index: address.id`를 지정함으로써 각 도시 입력의 `name` 속성을 `person[address][#{address.id}][city]` 대신 `person[address][city]`로 렌더링했습니다. 따라서 `params` 해시를 처리할 때 수정해야 할 Address 레코드를 결정할 수 있습니다.

`:index` 옵션을 통해 다른 중요한 숫자나 문자열을 전달할 수도 있습니다. 심지어 배열 매개변수를 생성할 수도 있습니다.

더 복잡한 중첩을 생성하려면 입력 이름의 선행 부분을 명시적으로 지정할 수 있습니다. 예를 들어:

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

다음과 같은 입력을 생성합니다:

```html
<input id="person_address_primary_23_city" name="person[address][primary][23][city]" type="text" value="Paris" />
```

`text_field`와 같은 도우미에 직접 `:index` 옵션을 전달할 수도 있지만, 개별 입력 필드보다는 폼 빌더 수준에서 이를 지정하는 것이 일반적으로 덜 반복적입니다.

일반적으로 최종 입력 이름은 `fields_for` / `form_with`에 지정된 이름, `:index` 옵션 값 및 속성 이름의 연결로 구성됩니다.

마지막으로, `:index`에 ID를 지정하는 대신 주어진 이름에 `"[]"`를 추가할 수도 있습니다. 예를 들어:

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

원래 예제와 정확히 동일한 출력을 생성합니다.

외부 리소스에 대한 폼
---------------------------

Rails의 폼 도우미는 외부 리소스로 데이터를 게시하는 폼을 작성하는 데에도 사용할 수 있습니다. 그러나 때로는 리소스에 `authenticity_token`을 설정해야 할 수도 있습니다. 이는 `form_with` 옵션에 `authenticity_token: 'your_external_token'` 매개변수를 전달하여 수행할 수 있습니다:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  폼 내용
<% end %>
```

외부 리소스로 데이터를 제출할 때, 결제 게이트웨이와 같은 외부 API에 의해 폼에서 사용할 수 있는 필드가 제한될 수 있으며, `authenticity_token`을 생성하는 것이 바람직하지 않을 수 있습니다. 토큰을 보내지 않으려면 `:authenticity_token` 옵션에 `false`를 전달하면 됩니다:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  폼 내용
<% end %>
```
복잡한 양식 작성하기
----------------------

많은 앱들은 단일 객체를 편집하는 간단한 양식을 넘어서게 됩니다. 예를 들어, `Person`을 생성할 때 사용자가 동일한 양식에서 여러 주소 레코드(집, 직장 등)를 생성할 수 있도록 허용하고, 나중에 해당 사람을 편집할 때는 필요에 따라 주소를 추가, 제거 또는 수정할 수 있어야 합니다.

### 모델 구성하기

Active Record는 [`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for) 메서드를 통해 모델 수준의 지원을 제공합니다:

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses
end

class Address < ApplicationRecord
  belongs_to :person
end
```

이렇게 하면 `Person`에 `addresses_attributes=` 메서드가 생성되어 주소를 생성, 업데이트 및 (선택적으로) 삭제할 수 있게 됩니다.

### 중첩된 양식

다음 양식은 사용자가 `Person`과 연결된 주소를 생성할 수 있도록 합니다.

```html+erb
<%= form_with model: @person do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```


관련 객체가 중첩된 속성을 허용하면 `fields_for`는 연관성의 각 요소에 대해 한 번씩 블록을 렌더링합니다. 특히, 사람에게 주소가 없으면 아무것도 렌더링하지 않습니다. 일반적인 패턴은 컨트롤러가 하나 이상의 빈 자식을 빌드하여 사용자에게 적어도 하나의 필드 세트를 표시하도록 하는 것입니다. 아래 예제는 새로운 사람 양식에 2개의 주소 필드 세트가 렌더링되도록 합니다.

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```

`fields_for`는 폼 빌더를 생성합니다. 매개변수의 이름은 `accepts_nested_attributes_for`에서 예상하는 것과 같아야 합니다. 예를 들어, 2개의 주소를 가진 사용자를 생성할 때 제출된 매개변수는 다음과 같이 보일 것입니다.

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

`:addresses_attributes` 해시의 키의 실제 값은 중요하지 않습니다. 그러나 각 주소마다 정수의 문자열이어야 합니다.

연관된 객체가 이미 저장된 경우, `fields_for`는 저장된 레코드의 `id`와 함께 숨겨진 입력을 자동으로 생성합니다. `fields_for`에 `include_id: false`를 전달하여 이를 비활성화할 수 있습니다.

### 컨트롤러

일반적으로 모델에 전달하기 전에 컨트롤러에서 [허용된 매개변수를 선언](action_controller_overview.html#strong-parameters)해야 합니다.

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### 객체 삭제하기

`accepts_nested_attributes_for`에 `allow_destroy: true`를 전달하여 사용자가 연관된 객체를 삭제할 수 있도록 할 수 있습니다.

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

객체의 속성 해시에 `_destroy` 키가 포함되어 있고 값이 `true`(예: 1, '1', true 또는 'true')로 평가되는 경우 해당 객체가 삭제됩니다. 이 양식을 사용하면 사용자가 주소를 제거할 수 있습니다.

```erb
<%= form_with model: @person do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

컨트롤러의 허용된 매개변수를 업데이트하여 `_destroy` 필드도 포함되도록 잊지 마세요.

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### 빈 레코드 방지하기

사용자가 입력하지 않은 필드 세트를 무시하는 것이 종종 유용합니다. 이를 `accepts_nested_attributes_for`에 `:reject_if` 프로크를 전달하여 제어할 수 있습니다. 이 프로크는 양식에서 제출된 각 속성 해시와 함께 호출됩니다. 프로크가 `true`를 반환하면 Active Record는 해당 해시에 대해 연관된 객체를 빌드하지 않습니다. 아래 예제는 `kind` 속성이 설정된 경우에만 주소를 빌드하려고 합니다.
```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda { |attributes| attributes['kind'].blank? }
end
```

편의를 위해 대신 `:all_blank` 심볼을 전달할 수도 있으며, 이는 모든 속성이 빈 값인 레코드를 거부하되 `_destroy` 값을 제외합니다.

### 필드 동적 추가

미리 여러 개의 필드 세트를 렌더링하는 대신 사용자가 "새 주소 추가" 버튼을 클릭할 때만 필드를 추가하고 싶을 수 있습니다. Rails는 이를 위한 내장 지원을 제공하지 않습니다. 새로운 필드 세트를 생성할 때 연관된 배열의 키가 고유해야 함을 보장해야 합니다. 현재 JavaScript 날짜(시대 이후의 밀리초)는 일반적인 선택입니다.

Form Builder 없이 Tag Helpers 사용하기
----------------------------------------

폼 빌더의 컨텍스트 외부에서 폼 필드를 렌더링해야 하는 경우, Rails는 일반적인 폼 요소에 대한 태그 헬퍼를 제공합니다. 예를 들어, [`check_box_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-check_box_tag):

```erb
<%= check_box_tag "accept" %>
```

출력:

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

일반적으로, 이러한 헬퍼들은 폼 빌더와 동일한 이름을 가지며 `_tag` 접미사가 추가됩니다. 전체 목록은 [`FormTagHelper` API 문서](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)를 참조하세요.

`form_tag`와 `form_for` 사용하기
-------------------------------

Rails 5.1에서 `form_with`가 도입되기 전에는 기능이 [`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag)와 [`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for) 사이에 분할되어 있었습니다. 이 두 가지는 현재 소프트 디프리케이트되었습니다. 사용법에 대한 문서는 [이 가이드의 이전 버전](https://guides.rubyonrails.org/v5.2/form_helpers.html)에서 찾을 수 있습니다.
[`fields_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for
[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-formmethod
[button-name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-name
[button-value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-value
