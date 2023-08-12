**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f6b613040c7aed4c76b6648b6fd963cf
Action View 개요
====================

이 가이드를 읽으면 다음을 알게 됩니다:

* Action View가 무엇이며 Rails와 함께 사용하는 방법.
* 템플릿, 부분 템플릿 및 레이아웃을 최적으로 사용하는 방법.
* 로컬라이즈된 뷰를 사용하는 방법.

--------------------------------------------------------------------------------

Action View란 무엇인가?
--------------------

Rails에서 웹 요청은 [Action Controller](action_controller_overview.html)와 Action View에 의해 처리됩니다. 일반적으로 Action Controller는 데이터베이스와의 통신 및 필요한 CRUD 작업에 관여합니다. 그런 다음 Action View는 응답을 컴파일하는 역할을 담당합니다.

Action View 템플릿은 HTML과 혼합된 태그 내에 내장된 루비를 사용하여 작성됩니다. 템플릿을 지저분하게 만드는 보일러플레이트 코드를 피하기 위해, 여러 개의 헬퍼 클래스가 폼, 날짜 및 문자열에 대한 공통 동작을 제공합니다. 또한 응용 프로그램이 발전함에 따라 새로운 헬퍼를 쉽게 추가할 수 있습니다.

참고: Action View의 일부 기능은 Active Record에 종속되어 있지만, 이는 Action View가 Active Record에 의존한다는 의미는 아닙니다. Action View는 어떤 종류의 루비 라이브러리와도 함께 사용할 수 있는 독립적인 패키지입니다.

Rails와 함께 Action View 사용하기
----------------------------

각 컨트롤러에는 `app/views` 디렉토리에 연관된 디렉토리가 있으며, 이 디렉토리에는 해당 컨트롤러와 관련된 뷰를 구성하는 템플릿 파일이 저장됩니다. 이 파일들은 각 컨트롤러 액션에서 생성된 뷰를 표시하는 데 사용됩니다.

스캐폴드 생성기를 사용하여 새 리소스를 생성할 때 Rails가 기본적으로 수행하는 작업을 살펴보겠습니다:

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

Rails에서는 뷰에 대한 네이밍 컨벤션을 사용합니다. 일반적으로 뷰는 해당 컨트롤러 액션과 동일한 이름을 가집니다. 위의 예시에서 볼 수 있듯이, `articles_controller.rb`의 index 컨트롤러 액션은 `app/views/articles` 디렉토리의 `index.html.erb` 뷰 파일을 사용합니다. 클라이언트에 반환되는 완전한 HTML은 이 ERB 파일, 그것을 감싸는 레이아웃 템플릿 및 뷰가 참조할 수 있는 모든 부분 템플릿의 조합으로 구성됩니다. 이 가이드에서는 이 세 가지 구성 요소에 대한 더 자세한 문서를 찾을 수 있습니다.

말했듯이, 최종 HTML 출력은 세 가지 Rails 요소인 `템플릿`, `부분 템플릿` 및 `레이아웃`의 조합입니다.
아래에 각각에 대한 간략한 개요가 제공됩니다.

템플릿
---------

Action View 템플릿은 여러 가지 방법으로 작성할 수 있습니다. 템플릿 파일의 확장자가 `.erb`인 경우 ERB (내장된 루비)와 HTML의 혼합을 사용합니다. 템플릿 파일의 확장자가 `.builder`인 경우 `Builder::XmlMarkup` 라이브러리가 사용됩니다.

Rails는 여러 개의 템플릿 시스템을 지원하며, 파일 확장자를 사용하여 구분합니다. 예를 들어, ERB 템플릿 시스템을 사용하는 HTML 파일의 확장자는 `.html.erb`입니다.

### ERB

ERB 템플릿 내에서는 `<% %>` 및 `<%= %>` 태그를 사용하여 루비 코드를 포함할 수 있습니다. `<% %>` 태그는 조건, 반복 또는 블록과 같이 아무런 값을 반환하지 않는 루비 코드를 실행하는 데 사용되고, `<%= %>` 태그는 출력을 원할 때 사용됩니다.

다음은 이름에 대한 루프를 고려해 보십시오:

```html+erb
<h1>Names of all the people</h1>
<% @people.each do |person| %>
  Name: <%= person.name %><br>
<% end %>
```

이 루프는 일반적인 내장 태그 (`<% %>`)를 사용하여 설정되고, 이름은 출력 내장 태그 (`<%= %>`를 사용하여 삽입됩니다. 이는 사용 제안뿐만 아니라 일반적인 출력 함수인 `print` 및 `puts`는 ERB 템플릿과 함께 뷰에 렌더링되지 않는다는 점에 유의하십시오. 따라서 다음과 같이 작성하는 것은 잘못된 방법입니다:

```html+erb
<%# 잘못된 방법 %>
Hi, Mr. <% puts "Frodo" %>
```

앞뒤의 공백을 제거하려면 `<%-` `-%>`를 `<%`와 `%>`와 교환하여 사용할 수 있습니다.

### Builder

Builder 템플릿은 ERB에 대한 프로그래밍적인 대안입니다. 특히 XML 콘텐츠를 생성하는 데 유용합니다. `.builder` 확장자를 가진 템플릿에는 `xml`이라는 이름의 XmlMarkup 객체가 자동으로 제공됩니다.

다음은 몇 가지 기본 예제입니다:

```ruby
xml.em("emphasized")
xml.em { xml.b("emph & bold") }
xml.a("A Link", "href" => "https://rubyonrails.org")
xml.target("name" => "compile", "option" => "fast")
```

이는 다음과 같이 생성됩니다:

```html
<em>emphasized</em>
<em><b>emph &amp; bold</b></em>
<a href="https://rubyonrails.org">A link</a>
<target option="fast" name="compile" />
```

블록이 있는 모든 메서드는 블록 내에 중첩된 마크업을 가진 XML 마크업 태그로 처리됩니다. 예를 들어, 다음과 같습니다:
```ruby
xml.div {
  xml.h1(@person.name)
  xml.p(@person.bio)
}
```

는 다음과 같은 결과물을 생성합니다:

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>A product of Danish Design during the Winter of '79...</p>
</div>
```

아래는 Basecamp에서 실제로 사용된 전체 RSS 예제입니다:

```ruby
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@feed_title)
    xml.link(@url)
    xml.description "Basecamp: Recent items"
    xml.language "en-us"
    xml.ttl "40"

    for item in @recent_items
      xml.item do
        xml.title(item_title(item))
        xml.description(item_description(item)) if item_description(item)
        xml.pubDate(item_pubDate(item))
        xml.guid(@person.firm.account.url + @recent_items.url(item))
        xml.link(@person.firm.account.url + @recent_items.url(item))
        xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
      end
    end
  end
end
```

### Jbuilder

[Jbuilder](https://github.com/rails/jbuilder)는 레일스 팀에 의해 유지되는 젬으로, 기본 레일스 `Gemfile`에 포함되어 있습니다. Builder와 유사하지만 XML 대신 JSON을 생성하는 데 사용됩니다.

Jbuilder를 사용하려면 `Gemfile`에 다음을 추가할 수 있습니다:

```ruby
gem 'jbuilder'
```

`.jbuilder` 확장자를 가진 템플릿에는 `json`이라는 Jbuilder 객체가 자동으로 제공됩니다.

다음은 기본 예제입니다:

```ruby
json.name("Alex")
json.email("alex@example.com")
```

다음과 같은 결과물을 생성합니다:

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

더 많은 예제와 정보는 [Jbuilder 문서](https://github.com/rails/jbuilder#jbuilder)를 참조하십시오.

### 템플릿 캐싱

기본적으로 레일스는 각 템플릿을 렌더링하는 데 사용되는 메소드로 컴파일합니다. 개발 환경에서는 템플릿을 수정할 때마다 파일의 수정 시간을 확인하고 다시 컴파일합니다.

부분 템플릿
--------

부분 템플릿, 일반적으로 "부분"이라고도 불리는 것은 렌더링 프로세스를 더 관리 가능한 청크로 나누기 위한 다른 도구입니다. 부분을 사용하면 템플릿에서 코드 조각을 별도의 파일로 추출하고 템플릿 전체에서 재사용할 수 있습니다.

### 부분 렌더링

뷰의 일부로서 부분을 렌더링하려면 뷰 내에서 `render` 메소드를 사용합니다:

```erb
<%= render "menu" %>
```

이렇게 하면 렌더링되는 뷰 내에서 `_menu.html.erb`라는 파일이 해당 지점에 렌더링됩니다. 선행 언더스코어 문자에 유의하십시오. 부분은 언더스코어 없이 참조되지만 언더스코어로 이름이 지정됩니다. 이는 다른 폴더에서 부분을 가져올 때도 마찬가지입니다:

```erb
<%= render "shared/menu" %>
```

이 코드는 `app/views/shared/_menu.html.erb`에서 부분을 가져옵니다.

### 뷰 단순화를 위한 부분 사용

부분을 사용하는 한 가지 방법은 부분을 서브루틴의 동등물로 취급하는 것입니다. 이렇게 하면 뷰에서 세부 정보를 추출하여 템플릿에서 무슨 일이 일어나고 있는지 쉽게 이해할 수 있습니다. 예를 들어, 다음과 같은 모양의 뷰가 있을 수 있습니다:

```html+erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "shared/footer" %>
```

여기서 `_ad_banner.html.erb`와 `_footer.html.erb` 부분은 애플리케이션의 여러 페이지에서 공유되는 내용을 포함할 수 있습니다. 특정 페이지에 집중할 때 이러한 섹션의 세부 정보를 볼 필요가 없습니다.

### `partial` 및 `locals` 옵션 없이 `render`

위의 예제에서 `render`는 `partial` 및 `locals` 2개의 옵션을 사용합니다. 그러나 이러한 옵션만 전달하려는 경우 이러한 옵션을 사용하지 않을 수 있습니다. 예를 들어:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

다음과 같이 할 수도 있습니다:

```erb
<%= render "product", product: @product %>
```

### `as` 및 `object` 옵션

기본적으로 `ActionView::Partials::PartialRenderer`는 템플릿과 동일한 이름을 가진 로컬 변수에 객체를 가지고 있습니다. 따라서 다음과 같은 경우:

```erb
<%= render partial: "product" %>
```

`_product` 부분에서는 로컬 변수 `product`에 `@product`를 얻게 됩니다. 마치 다음과 같이 작성한 것처럼입니다:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

`object` 옵션은 템플릿의 객체가 다른 곳에 있는 경우(예: 다른 인스턴스 변수나 로컬 변수에 있는 경우)에 유용하게 사용할 수 있습니다.

예를 들어, 다음과 같은 경우:

```erb
<%= render partial: "product", locals: { product: @item } %>
```

다음과 같이 할 수 있습니다:

```erb
<%= render partial: "product", object: @item %>
```

`as` 옵션을 사용하면 해당 로컬 변수에 대해 다른 이름을 지정할 수 있습니다. 예를 들어, `product` 대신 `item`으로 지정하려면 다음과 같이 할 수 있습니다:

```erb
<%= render partial: "product", object: @item, as: "item" %>
```

이는 다음과 동일합니다.
```erb
<%= render partial: "product", locals: { item: @item } %>
```

### 컬렉션 렌더링

일반적으로 템플릿은 컬렉션을 반복하고 각 요소에 대해 하위 템플릿을 렌더링해야합니다. 이 패턴은 배열을 받아 각 요소에 대해 부분을 렌더링하는 단일 메소드로 구현되었습니다.

따라서 다음과 같이 모든 제품을 렌더링하는 예제:

```erb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

한 줄로 다시 작성할 수 있습니다:

```erb
<%= render partial: "product", collection: @products %>
```

컬렉션과 함께 부분이 호출 될 때, 부분의 개별 인스턴스는 렌더링되는 컬렉션의 멤버에 대한 액세스 권한을 가집니다. 이 경우 부분은 `_product`이며, 내부에서 렌더링되는 컬렉션 멤버를 얻기 위해 `product`를 참조할 수 있습니다.

컬렉션을 렌더링하는 축약 구문을 사용할 수 있습니다. `@products`가 `Product` 인스턴스의 컬렉션인 경우, 다음과 같이 간단히 작성하여 동일한 결과를 얻을 수 있습니다:

```erb
<%= render @products %>
```

Rails는 컬렉션에서 모델 이름을 보고 사용할 부분의 이름을 결정합니다. 실제로 이 축약 구문을 사용하여 서로 다른 모델의 인스턴스로 구성된 컬렉션을 렌더링할 수도 있으며, Rails는 컬렉션의 각 멤버에 대해 적절한 부분을 선택합니다.

### Spacer 템플릿

`spacer_template` 옵션을 사용하여 주요 부분의 인스턴스 간에 렌더링할 두 번째 부분을 지정할 수도 있습니다:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails는 각 쌍의 `_product` 부분 사이에 데이터가 전달되지 않은 `_product_ruler` 부분을 렌더링합니다.

### 엄격한 로컬

기본적으로 템플릿은 키워드 인수로서 모든 `locals`를 허용합니다. 템플릿이 허용하는 `locals`를 정의하려면 `locals` 매직 코멘트를 추가하십시오:

```erb
<%# locals: (message:) -%>
<%= message %>
```

기본값도 제공할 수 있습니다:

```erb
<%# locals: (message: "Hello, world!") -%>
<%= message %>
```

또는 `locals`를 완전히 비활성화 할 수도 있습니다:

```erb
<%# locals: () %>
```

레이아웃
-------

레이아웃은 Rails 컨트롤러 액션의 결과 주위에 공통된 뷰 템플릿을 렌더링하는 데 사용될 수 있습니다. 일반적으로 Rails 애플리케이션에는 페이지가 렌더링 될 레이아웃이 몇 개 있습니다. 예를 들어, 사이트에는 로그인한 사용자를 위한 레이아웃과 마케팅 또는 판매 측면을 위한 다른 레이아웃이 있을 수 있습니다. 로그인한 사용자 레이아웃에는 여러 컨트롤러 액션에서 사용되어야 할 상위 탐색이 포함될 수 있습니다. SaaS 앱의 판매 레이아웃에는 "가격" 및 "문의하기" 페이지와 같은 상위 탐색이 포함될 수 있습니다. 각 레이아웃이 다른 모양과 느낌을 가지고 있다고 예상할 수 있습니다. [레이아웃 및 렌더링](https://guides.rubyonrails.org/layouts_and_rendering.html) 가이드에서 레이아웃에 대해 자세히 알아볼 수 있습니다.

### 부분 레이아웃

부분에는 자체 레이아웃이 적용될 수 있습니다. 이 레이아웃은 컨트롤러 액션에 적용되는 레이아웃과 다릅니다만, 유사한 방식으로 작동합니다.

예를 들어, 페이지에서 `div`로 래핑되어야 하는 기사를 표시하는 경우, 먼저 새로운 `Article`를 만듭니다:

```ruby
Article.create(body: 'Partial Layouts are cool!')
```

`show` 템플릿에서 `box` 레이아웃으로 래핑된 `_article` 부분을 렌더링합니다:

**articles/show.html.erb**

```erb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

`box` 레이아웃은 `_article` 부분을 간단히 `div`로 래핑합니다:

**articles/_box.html.erb**

```html+erb
<div class='box'>
  <%= yield %>
</div>
```

부분 레이아웃은 `render` 호출에 전달된 로컬 `article` 변수에 액세스 할 수 있습니다. 그러나 응용 프로그램 전체 레이아웃과 달리 부분 레이아웃은 여전히 밑줄 접두사를 가지고 있습니다.

`yield`를 호출하는 대신 부분 레이아웃 내에서 코드 블록을 렌더링 할 수도 있습니다. 예를 들어, `_article` 부분이 없는 경우 다음과 같이 할 수 있습니다:

**articles/show.html.erb**

```html+erb
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

위의 예제에서 이전 예제와 동일한 출력이 생성됩니다.

뷰 경로
----------

응답을 렌더링 할 때 컨트롤러는 다른 뷰가 위치한 곳을 해결해야합니다. 기본적으로 `app/views` 디렉토리 내부만 찾습니다.
`prepend_view_path`와 `append_view_path` 메소드를 사용하여 다른 위치를 추가하고 경로를 해결할 때 특정 우선순위를 부여할 수 있습니다.

### Prepend View Path

예를 들어, 서브도메인을 위한 다른 디렉토리에 뷰를 넣고 싶을 때 유용합니다.

다음과 같이 사용할 수 있습니다:

```ruby
prepend_view_path "app/views/#{request.subdomain}"
```

그러면 Action View는 뷰를 해결할 때 먼저 이 디렉토리를 찾습니다.

### Append View Path

마찬가지로 경로를 추가할 수 있습니다:

```ruby
append_view_path "app/views/direct"
```

이렇게 하면 `app/views/direct`가 경로의 끝에 추가됩니다.

Helpers
-------

Rails는 Action View와 함께 사용할 수 있는 많은 헬퍼 메소드를 제공합니다. 이에는 다음과 같은 메소드가 포함됩니다:

* 날짜, 문자열 및 숫자 형식 지정
* 이미지, 비디오, 스타일시트 등에 대한 HTML 링크 생성
* 콘텐츠의 안전한 처리
* 폼 생성
* 콘텐츠 로컬라이징

헬퍼에 대해 더 자세히 알아보려면 [Action View Helpers 가이드](action_view_helpers.html)와 [Action View Form Helpers 가이드](form_helpers.html)를 참조하십시오.

로컬라이즈된 뷰
---------------

Action View는 현재 로케일에 따라 다른 템플릿을 렌더링할 수 있습니다.

예를 들어, show 액션을 가진 `ArticlesController`가 있다고 가정해보겠습니다. 기본적으로 이 액션을 호출하면 `app/views/articles/show.html.erb`가 렌더링됩니다. 그러나 `I18n.locale = :de`로 설정하면 `app/views/articles/show.de.html.erb`가 대신 렌더링됩니다. 로컬라이즈된 템플릿이 없는 경우에는 로컬라이즈되지 않은 버전이 사용됩니다. 이는 모든 경우에 로컬라이즈된 뷰를 제공해야 하는 것은 아니지만, 가능한 경우에는 우선적으로 사용됩니다.

동일한 기술을 사용하여 public 디렉토리의 rescue 파일도 로컬라이즈할 수 있습니다. 예를 들어, `I18n.locale = :de`로 설정하고 `public/500.de.html` 및 `public/404.de.html`을 생성하면 로컬라이즈된 rescue 페이지를 사용할 수 있습니다.

Rails는 I18n.locale을 설정하는 데 사용하는 심볼을 제한하지 않기 때문에, 원하는 대로 다른 콘텐츠를 표시할 수 있는 이 시스템을 활용할 수 있습니다. 예를 들어, "전문가" 사용자와 "일반" 사용자가 다른 페이지를 보아야 하는 경우를 가정해보겠습니다. 다음을 `app/controllers/application_controller.rb`에 추가할 수 있습니다:

```ruby
before_action :set_expert_locale

def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
```

그런 다음 `app/views/articles/show.expert.html.erb`와 같은 특별한 뷰를 생성하여 전문가 사용자에게만 표시될 수 있습니다.

Rails 국제화 (I18n) API에 대해 더 자세히 알아보려면 [여기](i18n.html)를 참조하십시오.
