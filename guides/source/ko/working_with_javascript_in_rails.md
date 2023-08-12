**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c1e56036aa9fd68276daeec5a9407096
JavaScript을 사용하는 Rails 작업
================================

이 가이드에서는 JavaScript 기능을 Rails 애플리케이션에 통합하는 옵션에 대해 다룹니다.
외부 JavaScript 패키지를 사용하는 옵션 및 Rails에서 Turbo를 사용하는 방법에 대한 옵션을 알 수 있습니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다.

* Node.js, Yarn 또는 JavaScript 번들러가 필요하지 않은 Rails 사용 방법.
* import maps, esbuild, rollup 또는 webpack을 사용하여 JavaScript를 번들하는 방법.
* Turbo가 무엇인지 및 사용 방법.
* Rails에서 제공하는 Turbo HTML 도우미 사용 방법.

--------------------------------------------------------------------------------

Import Maps
-----------

[Import maps](https://github.com/rails/importmap-rails)를 사용하면 브라우저에서 직접 버전화된 파일에
논리적 이름을 매핑하여 JavaScript 모듈을 가져올 수 있습니다. Import maps는 Rails 7부터 기본으로
제공되며, 변환 또는 번들링 없이 대부분의 NPM 패키지를 사용하여 현대적인 JavaScript 애플리케이션을
빌드할 수 있습니다.

import maps를 사용하는 애플리케이션은 [Node.js](https://nodejs.org/en/) 또는
[Yarn](https://yarnpkg.com/)이 필요하지 않습니다. JavaScript 종속성을 관리하기 위해 Rails와
`importmap-rails`를 사용할 계획이 있다면, Node.js 또는 Yarn을 설치할 필요가 없습니다.

import maps를 사용할 때는 별도의 빌드 프로세스가 필요하지 않으며, `bin/rails server`로 서버를 시작하면 됩니다.

### importmap-rails 설치하기

Rails 7+에서는 Importmap for Rails가 자동으로 포함되지만, 기존 애플리케이션에 수동으로 설치할 수도 있습니다:

```bash
$ bin/bundle add importmap-rails
```

설치 작업 실행:

```bash
$ bin/rails importmap:install
```

### importmap-rails로 NPM 패키지 추가하기

import map을 사용하는 애플리케이션에 새 패키지를 추가하려면 터미널에서 `bin/importmap pin` 명령을 실행하세요:

```bash
$ bin/importmap pin react react-dom
```

그런 다음, `application.js`에서 패키지를 일반적으로 가져옵니다:

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

JavaScript 번들러로 NPM 패키지 추가하기
--------

import maps는 새로운 Rails 애플리케이션의 기본 설정이지만, 전통적인 JavaScript 번들링을 선호하는 경우
[esbuild](https://esbuild.github.io/), [webpack](https://webpack.js.org/) 또는
[rollup.js](https://rollupjs.org/guide/en/) 중에서 선택하여 새로운 Rails 애플리케이션을 생성할 수 있습니다.

새로운 Rails 애플리케이션에서 import maps 대신 번들러를 사용하려면 `rails new`에 `—javascript` 또는
`-j` 옵션을 전달하세요:

```bash
$ rails new my_new_app --javascript=webpack
OR
$ rails new my_new_app -j webpack
```

이러한 번들링 옵션은 간단한 구성과 [jsbundling-rails](https://github.com/rails/jsbundling-rails) 젬을 통한
자산 파이프라인과의 통합을 제공합니다.

번들링 옵션을 사용할 때는 `bin/dev`를 사용하여 Rails 서버를 시작하고 개발용 JavaScript를 빌드하세요.

### Node.js와 Yarn 설치하기

Rails 애플리케이션에서 JavaScript 번들러를 사용하는 경우, Node.js와 Yarn을 설치해야 합니다.

[Node.js 웹사이트](https://nodejs.org/en/download/)에서 설치 지침을 찾아 설치하고 다음 명령으로 올바르게 설치되었는지 확인하세요:

```bash
$ node --version
```

Node.js 런타임의 버전이 출력되어야 합니다. 버전이 `8.16.0`보다 큰지 확인하세요.

Yarn은 [Yarn 웹사이트](https://classic.yarnpkg.com/en/docs/install)의 설치 지침을 따르세요. 다음 명령을 실행하면 Yarn 버전이 출력됩니다:

```bash
$ yarn --version
```

`1.22.0`과 같은 메시지가 표시되면 Yarn이 올바르게 설치된 것입니다.

Import Maps와 JavaScript 번들러 중 선택하기
-----------------------------------------------------

새로운 Rails 애플리케이션을 생성할 때는 import maps와 JavaScript 번들링 솔루션 중에서 선택해야 합니다.
각 애플리케이션은 다른 요구 사항을 가지고 있으며, 대형 복잡한 애플리케이션의 경우 다른 옵션으로
마이그레이션하는 데 시간이 걸릴 수 있으므로 요구 사항을 신중히 고려해야 합니다.

import maps는 복잡성을 줄이고 개발자 경험을 향상시키며 성능 향상을 제공하는 잠재력을 가지고 있다고
Rails 팀은 믿기 때문에 기본 옵션으로 선택되었습니다.

많은 애플리케이션, 특히 JavaScript 요구 사항에 대부분 [Hotwire](https://hotwired.dev/) 스택을
사용하는 애플리케이션의 경우, import maps가 장기적으로 올바른 옵션일 것입니다. Rails 7에서
import maps를 기본으로 선택한 이유에 대해 자세히 알아보려면
[여기](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b)
를 읽어보세요.

다른 애플리케이션은 여전히 전통적인 JavaScript 번들러가 필요할 수 있습니다. 다음 요구 사항이 있는 경우
전통적인 번들러를 선택해야 합니다:

* JSX 또는 TypeScript와 같은 변환 단계가 필요한 경우.
* CSS를 포함하거나 [Webpack loaders](https://webpack.js.org/loaders/)를 사용하는 JavaScript
  라이브러리를 사용해야 하는 경우.
* [tree-shaking](https://webpack.js.org/guides/tree-shaking/)이 필요한 경우.
* [cssbundling-rails 젬](https://github.com/rails/cssbundling-rails)을 통해 Bootstrap, Bulma, PostCSS
  또는 Dart CSS를 설치할 경우. 이 젬에서 제공하는 Tailwind와 Sass를 제외한 모든 옵션은
  `rails new`에서 다른 옵션을 지정하지 않으면 자동으로 `esbuild`를 설치합니다.
터보
-----

수입 맵 또는 전통적인 번들러를 선택하든지 상관없이 Rails는 [Turbo](https://turbo.hotwired.dev/)를 함께 제공하여 애플리케이션의 속도를 높이고 작성해야 할 JavaScript 양을 크게 줄일 수 있습니다.

Turbo를 사용하면 서버가 HTML을 직접 전달하여 기존의 프론트엔드 프레임워크 대신 Rails 애플리케이션의 서버 측을 JSON API 이상으로 줄일 수 있습니다.

### Turbo Drive

[Turbo Drive](https://turbo.hotwired.dev/handbook/drive)는 전체 페이지를 허물고 다시 구축하지 않고 각 탐색 요청마다 페이지 로드 속도를 높입니다. Turbo Drive는 Turbolinks의 개선 및 대체 기능입니다.

### Turbo Frames

[Turbo Frames](https://turbo.hotwired.dev/handbook/frames)는 페이지의 미리 정의된 부분을 업데이트하여 페이지의 나머지 내용에 영향을 주지 않고 요청에 따라 업데이트할 수 있습니다.

Turbo Frames를 사용하여 사용자 정의 JavaScript 없이 제자리 편집, 지연 로드 콘텐츠, 쉽게 서버 렌더링된 탭 인터페이스를 구축할 수 있습니다.

Rails는 Turbo Frames의 사용을 간소화하기 위해 [turbo-rails](https://github.com/hotwired/turbo-rails) 젬을 통해 HTML 도우미를 제공합니다.

이 젬을 사용하면 다음과 같이 `turbo_frame_tag` 도우미를 사용하여 Turbo Frame을 애플리케이션에 추가할 수 있습니다.

```erb
<%= turbo_frame_tag dom_id(post) do %>
  <div>
     <%= link_to post.title, post_path(post) %>
  </div>
<% end %>
```

### Turbo Streams

[Turbo Streams](https://turbo.hotwired.dev/handbook/streams)는 자체 실행되는 `<turbo-stream>` 요소로 래핑된 HTML 조각으로 페이지 변경 사항을 전달합니다. Turbo Streams를 사용하면 다른 사용자가 웹 소켓을 통해 수행한 변경 사항을 방송하고 전체 페이지 로드 없이 양식 제출 후 페이지의 일부를 업데이트할 수 있습니다.

Rails는 [turbo-rails](https://github.com/hotwired/turbo-rails) 젬을 통해 Turbo Streams의 사용을 간소화하기 위해 HTML 및 서버 측 도우미를 제공합니다.

이 젬을 사용하면 컨트롤러 액션에서 Turbo Streams를 렌더링할 수 있습니다.

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Rails는 `.turbo_stream.erb` 뷰 파일을 자동으로 찾아 해당 뷰를 렌더링합니다.

Turbo Stream 응답은 컨트롤러 액션에서 인라인으로 렌더링될 수도 있습니다.

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream { render turbo_stream: turbo_stream.prepend('posts', partial: 'post') }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

마지막으로, Turbo Streams는 모델이나 백그라운드 작업에서 내장된 도우미를 사용하여 시작될 수 있습니다. 이러한 방송은 모든 사용자에게 웹소켓 연결을 통해 콘텐츠를 업데이트하는 데 사용될 수 있으며, 페이지 콘텐츠를 신선하게 유지하고 애플리케이션을 활성화시킵니다.

모델에서 Turbo Stream를 방송하려면 다음과 같이 모델 콜백을 결합합니다.

```ruby
class Post < ApplicationRecord
  after_create_commit { broadcast_append_to('posts') }
end
```

다음과 같이 업데이트를 받아야 할 페이지에 설정된 웹소켓 연결과 함께 사용됩니다.

```erb
<%= turbo_stream_from "posts" %>
```

Rails/UJS 기능 대체
----------------------------------------

Rails 6에는 UJS(Unobtrusive JavaScript)라는 도구가 포함되어 있습니다. UJS를 사용하면 개발자는 `<a>` 태그의 HTTP 요청 메서드를 재정의하거나 작업을 실행하기 전에 확인 대화 상자를 추가할 수 있습니다. UJS는 Rails 7 이전에는 기본값이었지만, Turbo를 사용하는 것이 권장됩니다.

### Method

링크를 클릭하면 항상 HTTP GET 요청이 발생합니다. 애플리케이션이 [RESTful](https://en.wikipedia.org/wiki/Representational_State_Transfer)이라면 일부 링크는 실제로 서버의 데이터를 변경하는 작업이며, GET 요청이 아닌 요청으로 수행되어야 합니다. `data-turbo-method` 속성을 사용하여 해당 링크에 "post", "put", "delete"와 같은 명시적인 메서드를 지정할 수 있습니다.

Turbo는 애플리케이션의 `<a>` 태그를 스캔하여 `turbo-method` 데이터 속성을 사용하고 있을 때 지정된 메서드를 사용하여 기본 GET 작업을 무시합니다.

예를 들어:

```erb
<%= link_to "Delete post", post_path(post), data: { turbo_method: "delete" } %>
```

다음과 같이 생성됩니다:

```html
<a data-turbo-method="delete" href="...">Delete post</a>
```

`data-turbo-method`를 사용하여 링크의 메서드를 변경하는 대신 Rails `button_to` 도우미를 사용할 수도 있습니다. 접근성을 위해 실제 버튼과 폼이 GET 이외의 작업에 대한 우선적인 선택사항입니다.

### Confirmations

사용자에게 추가적인 확인을 요청하려면 링크와 폼에 `data-turbo-confirm` 속성을 추가할 수 있습니다. 링크 클릭 또는 폼 제출 시 사용자에게 속성의 텍스트가 포함된 JavaScript `confirm()` 대화 상자가 표시됩니다. 사용자가 취소를 선택하면 작업이 실행되지 않습니다.

예를 들어, `link_to` 도우미를 사용하는 경우:

```erb
<%= link_to "Delete post", post_path(post), data: { turbo_method: "delete", turbo_confirm: "Are you sure?" } %>
```

다음과 같이 생성됩니다:

```html
<a href="..." data-turbo-confirm="Are you sure?" data-turbo-method="delete">Delete post</a>
```
사용자가 "게시물 삭제" 링크를 클릭하면 "확실합니까?" 확인 대화 상자가 표시됩니다.

속성은 `button_to` 헬퍼와 함께 사용할 수도 있지만, `button_to` 헬퍼가 내부적으로 렌더링하는 양식에 추가해야 합니다:

```erb
<%= button_to "게시물 삭제", post, method: :delete, form: { data: { turbo_confirm: "확실합니까?" } } %>
```

### Ajax 요청

JavaScript에서 GET이 아닌 요청을 보낼 때는 `X-CSRF-Token` 헤더가 필요합니다.
이 헤더가 없으면 요청은 Rails에서 허용되지 않습니다.

참고: 이 토큰은 Rails에서 Cross-Site Request Forgery (CSRF) 공격을 방지하기 위해 필요합니다. [보안 가이드](security.html#cross-site-request-forgery-csrf)에서 자세히 알아보세요.

[Rails Request.JS](https://github.com/rails/request.js)는
Rails에서 필요한 요청 헤더를 추가하는 로직을 캡슐화합니다. 패키지에서 `FetchRequest` 클래스를 가져와서
요청 메서드, URL, 옵션을 전달하여 인스턴스를 만들고, `await request.perform()`를 호출한 다음
응답을 처리해야 할 작업을 수행하면 됩니다.

예를 들어:

```javascript
import { FetchRequest } from '@rails/request.js'

....

async myMethod () {
  const request = new FetchRequest('post', 'localhost:3000/posts', {
    body: JSON.stringify({ name: 'Request.JS' })
  })
  const response = await request.perform()
  if (response.ok) {
    const body = await response.text
  }
}
```

다른 라이브러리를 사용하여 Ajax 호출을 할 때는 보안 토큰을 기본 헤더로 직접 추가해야 합니다. 토큰을 얻으려면
애플리케이션 뷰에서 [`csrf_meta_tags`][]가 출력하는 `<meta name='csrf-token' content='THE-TOKEN'>` 태그를 확인하십시오. 다음과 같이 수행할 수 있습니다:

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
