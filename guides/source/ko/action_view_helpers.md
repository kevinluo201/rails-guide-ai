**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37d2486eee8522a64c5f97f86900b8a6
액션 뷰 헬퍼
====================

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* 날짜, 문자열 및 숫자를 형식화하는 방법
* 이미지, 비디오, 스타일시트 등에 대한 링크 방법
* 콘텐츠를 안전하게 처리하는 방법
* 콘텐츠를 로컬화하는 방법

--------------------------------------------------------------------------------

액션 뷰에서 제공하는 헬퍼 개요
-------------------------------------------

WIP: 여기에 나열된 헬퍼가 모두 있는 것은 아닙니다. 전체 목록은 [API 문서](https://api.rubyonrails.org/classes/ActionView/Helpers.html)를 참조하십시오.

다음은 액션 뷰에서 사용 가능한 헬퍼에 대한 간략한 개요 요약입니다. 더 자세한 내용은 [API 문서](https://api.rubyonrails.org/classes/ActionView/Helpers.html)를 검토하는 것이 좋지만, 이것은 좋은 시작점으로 사용할 수 있습니다.

### AssetTagHelper

이 모듈은 이미지, JavaScript 파일, 스타일시트 및 피드와 같은 자산에 대한 HTML 링크를 생성하는 메서드를 제공합니다.

기본적으로 Rails는 이러한 자산을 현재 호스트의 public 폴더에서 링크합니다. 그러나 `config.asset_host`를 설정하여 Rails가 전용 자산 서버에서 자산에 링크하도록 지시할 수 있습니다. 일반적으로 `config/environments/production.rb`에 설정합니다. 예를 들어, 자산 호스트가 `assets.example.com`인 경우:

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```


#### auto_discovery_link_tag

브라우저와 피드 리더가 RSS, Atom 또는 JSON 피드를 자동으로 감지하는 데 사용할 수 있는 링크 태그를 반환합니다.

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

#### image_path

`app/assets/images` 디렉토리의 이미지 자산에 대한 경로를 계산합니다. 문서 루트에서의 전체 경로가 전달됩니다. `image_tag`에서 내부적으로 이미지 경로를 구축하는 데 사용됩니다.

```ruby
image_path("edit.png") # => /assets/edit.png
```

config.assets.digest가 true로 설정되어 있는 경우 파일 이름에 fingerprint가 추가됩니다.

```ruby
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

`app/assets/images` 디렉토리의 이미지 자산에 대한 URL을 계산합니다. 이는 내부적으로 `image_path`를 호출하고 현재 호스트 또는 자산 호스트와 병합합니다.

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

소스에 대한 HTML 이미지 태그를 반환합니다. 소스는 전체 경로이거나 `app/assets/images` 디렉토리에 있는 파일일 수 있습니다.

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

제공된 각 소스에 대한 HTML 스크립트 태그를 반환합니다. 현재 페이지에 포함시킬 `app/assets/javascripts` 디렉토리에 있는 JavaScript 파일의 파일 이름 (`.js` 확장자는 선택 사항)을 전달하거나 문서 루트와 관련된 전체 경로를 전달할 수 있습니다.

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

`app/assets/javascripts` 디렉토리의 JavaScript 자산에 대한 경로를 계산합니다. 소스 파일 이름에 확장자가 없으면 `.js`가 추가됩니다. 문서 루트에서의 전체 경로가 전달됩니다. `javascript_include_tag`에서 내부적으로 스크립트 경로를 구축하는 데 사용됩니다.

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

`app/assets/javascripts` 디렉토리의 JavaScript 자산에 대한 URL을 계산합니다. 이는 내부적으로 `javascript_path`를 호출하고 현재 호스트 또는 자산 호스트와 병합합니다.

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

지정된 소스에 대한 스타일시트 링크 태그를 반환합니다. 확장자를 지정하지 않으면 `.css`가 자동으로 추가됩니다.

```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" rel="stylesheet" />
```

#### stylesheet_path

`app/assets/stylesheets` 디렉토리의 스타일시트 자산에 대한 경로를 계산합니다. 소스 파일 이름에 확장자가 없으면 `.css`가 추가됩니다. 문서 루트에서의 전체 경로가 전달됩니다. `stylesheet_link_tag`에서 내부적으로 스타일시트 경로를 구축하는 데 사용됩니다.

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

`app/assets/stylesheets` 디렉토리의 스타일시트 자산에 대한 URL을 계산합니다. 이는 내부적으로 `stylesheet_path`를 호출하고 현재 호스트 또는 자산 호스트와 병합합니다.

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

이 헬퍼는 Atom 피드를 쉽게 구축할 수 있도록 도와줍니다. 다음은 전체 사용 예입니다:

**config/routes.rb**

```ruby
resources :articles
```

**app/controllers/articles_controller.rb**

```ruby
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```ruby
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

### BenchmarkHelper

#### benchmark

템플릿에서 블록의 실행 시간을 측정하고 결과를 로그에 기록할 수 있게 해줍니다. 비용이 많이 드는 작업이나 가능한 병목 현상을 감지하기 위해 이 블록을 사용하세요.
```html+erb
<% benchmark "데이터 파일 처리" do %>
  <%= expensive_files_operation %>
<% end %>
```

이렇게 하면 로그에 "데이터 파일 처리 (0.34523)"와 같은 내용이 추가됩니다. 이를 사용하여 코드를 최적화할 때 시간을 비교하는 데 사용할 수 있습니다.

### CacheHelper

#### cache

전체 액션이나 페이지가 아닌 뷰의 일부를 캐시하는 메소드입니다. 이 기술은 메뉴, 뉴스 주제 목록, 정적 HTML 조각 등과 같은 조각을 캐시하는 데 유용합니다. 이 메소드는 캐시할 내용을 포함하는 블록을 사용합니다. 자세한 내용은 `AbstractController::Caching::Fragments`를 참조하십시오.

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

`capture` 메소드를 사용하면 템플릿의 일부를 변수로 추출할 수 있습니다. 그런 다음 이 변수를 템플릿이나 레이아웃의 어디에서든 사용할 수 있습니다.

```html+erb
<% @greeting = capture do %>
  <p>Welcome! The date and time is <%= Time.now %></p>
<% end %>
```

추출된 변수는 다른 곳에서 사용할 수 있습니다.

```html+erb
<html>
  <head>
    <title>Welcome!</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### content_for

`content_for`를 호출하면 나중에 사용할 마크업 블록을 식별자에 저장합니다. 식별자를 `yield`의 인수로 전달하여 다른 템플릿이나 레이아웃에서 저장된 내용에 대한 후속 호출을 수행할 수 있습니다.

예를 들어, 표준 애플리케이션 레이아웃과 특정 JavaScript가 필요한 특별한 페이지가 있다고 가정해 봅시다. `content_for`를 사용하여 이 JavaScript를 특별한 페이지에 포함시킬 수 있습니다. 이렇게 하면 사이트의 나머지 부분을 불필요하게 늘리지 않고 특별한 페이지에 JavaScript를 포함시킬 수 있습니다.

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>Welcome!</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Welcome! The date and time is <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>This is a special page.</p>

<% content_for :special_script do %>
  <script>alert('Hello!')</script>
<% end %>
```

### DateHelper

#### distance_of_time_in_words

두 개의 Time 또는 Date 객체 또는 정수(초) 사이의 시간 차이를 대략적으로 보고합니다. `include_seconds`를 true로 설정하면 더 자세한 근사치를 얻을 수 있습니다.

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => 1분 미만
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => 20초 미만
```

#### time_ago_in_words

`distance_of_time_in_words`와 유사하지만 `to_time`이 `Time.now`로 고정된 경우입니다.

```ruby
time_ago_in_words(3.minutes.from_now) # => 3분
```

### DebugHelper

YAML로 덤프된 객체를 가진 `pre` 태그를 반환합니다. 이는 객체를 검사하는 매우 가독성 있는 방법을 제공합니다.

```ruby
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1, 2, 3] }
debug(my_hash)
```

```html
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

### FormHelper

Form 헬퍼는 모델을 사용하는 것에 비해 표준 HTML 요소만 사용하는 것보다 모델과 함께 작업하기가 훨씬 쉽도록 설계되었습니다. 이 헬퍼는 폼에 대한 HTML을 생성하며, 각 입력 유형(예: 텍스트, 비밀번호, 선택 등)에 대한 메소드를 제공합니다. 폼이 제출될 때(즉, 사용자가 제출 버튼을 클릭하거나 JavaScript를 통해 form.submit이 호출될 때) 폼 입력은 params 객체에 번들로 묶여 컨트롤러로 전달됩니다.

폼 헬퍼에 대해 더 자세히 알아보려면 [Action View Form Helpers Guide](form_helpers.html)를 참조하십시오.

### JavaScriptHelper

뷰에서 JavaScript를 사용하는 데 필요한 기능을 제공합니다.

#### escape_javascript

JavaScript 세그먼트에 대해 개행 문자와 작은따옴표, 큰따옴표를 이스케이프합니다.

#### javascript_tag

제공된 코드를 감싼 JavaScript 태그를 반환합니다.

```ruby
javascript_tag "alert('All is good')"
```

```html
<script>
//<![CDATA[
alert('All is good')
//]]>
</script>
```

### NumberHelper

숫자를 포맷된 문자열로 변환하는 메소드를 제공합니다. 전화번호, 통화, 백분율, 정밀도, 위치 표기법 및 파일 크기에 대한 메소드가 제공됩니다.

#### number_to_currency

숫자를 통화 문자열(예: $13.65)로 포맷합니다.

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### number_to_human

숫자를 사용자가 읽기 쉽도록 예쁘게 출력(포맷 및 근사치)합니다. 매우 큰 숫자에 유용합니다.

```ruby
number_to_human(1234)    # => 1.23 Thousand
number_to_human(1234567) # => 1.23 Million
```

#### number_to_human_size

바이트 크기를 이해하기 쉬운 표현으로 포맷합니다. 사용자에게 파일 크기를 보고하는 데 유용합니다.

```ruby
number_to_human_size(1234)    # => 1.21 KB
number_to_human_size(1234567) # => 1.18 MB
```

#### number_to_percentage

숫자를 백분율 문자열로 포맷합니다.
```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

전화번호를 (기본적으로 미국 형식으로) 포맷합니다.

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

구분 기호를 사용하여 천 단위로 숫자를 포맷합니다.

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

지정된 `precision` 수준으로 숫자를 포맷합니다. 기본값은 3입니다.

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

SanitizeHelper 모듈은 텍스트에서 원하지 않는 HTML 요소를 제거하는 일련의 메소드를 제공합니다.

#### sanitize

이 sanitize 도우미는 모든 태그를 HTML 인코딩하고 특정하게 허용되지 않은 모든 속성을 제거합니다.

```ruby
sanitize @article.body
```

`:attributes` 또는 `:tags` 옵션 중 하나라도 전달되면, 명시된 속성과 태그만 허용되고 그 외에는 허용되지 않습니다.

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

예를 들어 기본값에 table 태그를 추가하는 경우와 같이 여러 번 사용하기 위해 기본값을 변경할 수 있습니다.

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

CSS 코드 블록을 정리합니다.

#### strip_links(html)

링크 태그를 제외한 모든 텍스트에서 링크 태그를 제거합니다.

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('emails to <a href="mailto:me@email.com">me@email.com</a>.')
# => emails to me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visit</a>.')
# => Blog: Visit.
```

#### strip_tags(html)

HTML 태그와 주석을 포함한 모든 HTML 태그를 제거합니다.
이 기능은 rails-html-sanitizer 젬에 의해 제공됩니다.

```ruby
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!
```

```ruby
strip_tags("<b>Bold</b> no more!  <a href='more.html'>See more</a>")
# => Bold no more!  See more
```

참고: 출력에는 여전히 이스케이프되지 않은 '<', '>', '&' 문자가 포함될 수 있으며 브라우저를 혼란스럽게 할 수 있습니다.

### UrlHelper

라우팅 서브시스템에 의존하는 링크를 만들고 URL을 가져오는 메소드를 제공합니다.

#### url_for

제공된 `options` 세트에 대한 URL을 반환합니다.

##### 예제

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

`url_for`에서 파생된 URL에 링크합니다. 주로 RESTful 리소스 링크를 생성하는 데 사용됩니다. 이 예제에서는 모델을 `link_to`에 전달하는 것으로 축약됩니다.

**예제**

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>
```

링크 대상이 이름 매개변수에 맞지 않는 경우 블록을 사용할 수도 있습니다. ERB 예제:

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
<% end %>
```

다음과 같이 출력됩니다.

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Check it out!</span>
</a>
```

자세한 내용은 [API 문서를 참조하세요](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to).

#### button_to

전달된 URL로 제출하는 폼을 생성합니다. 폼에는 `name`의 값을 가진 제출 버튼이 있습니다.

##### 예제

```html+erb
<%= button_to "Sign in", sign_in_path %>
```

다음과 같이 대략적으로 출력됩니다.

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

자세한 내용은 [API 문서를 참조하세요](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to).

### CsrfHelper

크로스 사이트 요청 위조(CSRF) 보호 매개변수와 토큰의 이름을 가진 메타 태그 "csrf-param" 및 "csrf-token"을 반환합니다.

```html
<%= csrf_meta_tags %>
```

참고: 일반적인 폼은 숨겨진 필드를 생성하므로 이러한 태그를 사용하지 않습니다. 자세한 내용은 [Rails 보안 가이드](security.html#cross-site-request-forgery-csrf)를 참조하세요.
[`config.asset_host`]: configuring.html#config-asset-host
