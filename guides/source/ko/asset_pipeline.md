**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0f0bbb2fd67f1843d30e360c15c03c61
자산 파이프라인
==================

이 가이드는 자산 파이프라인에 대해 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* 자산 파이프라인이 무엇이며 무엇을 하는지.
* 애플리케이션 자산을 올바르게 구성하는 방법.
* 자산 파이프라인의 이점.
* 파이프라인에 전처리기를 추가하는 방법.
* 젬과 함께 자산을 패키징하는 방법.

--------------------------------------------------------------------------------

자산 파이프라인이란 무엇인가?
---------------------------

자산 파이프라인은 JavaScript 및 CSS 자산의 전달을 처리하기 위한 프레임워크를 제공합니다. 이는 HTTP/2와 연결 및 최소화와 같은 기술을 활용하여 수행됩니다. 마지막으로, 다른 젬의 자산과 자동으로 결합되도록 애플리케이션을 허용합니다.

자산 파이프라인은 [importmap-rails](https://github.com/rails/importmap-rails), [sprockets](https://github.com/rails/sprockets) 및 [sprockets-rails](https://github.com/rails/sprockets-rails) 젬에 의해 구현되며 기본적으로 활성화되어 있습니다. 새로운 애플리케이션을 생성할 때 `--skip-asset-pipeline` 옵션을 전달하여 비활성화할 수 있습니다.

```bash
$ rails new appname --skip-asset-pipeline
```

참고: 이 가이드는 CSS에 대해 `sprockets`만 사용하고 JavaScript 처리에는 `importmap-rails`만 사용하는 기본 자산 파이프라인에 초점을 맞추고 있습니다. 이 두 가지의 주요 제한은 변환을 지원하지 않으므로 `Babel`, `Typescript`, `Sass`, `React JSX format` 또는 `TailwindCSS`와 같은 기능을 사용할 수 없다는 것입니다. JavaScript/CSS에 대해 변환을 필요로 하는 경우 [대체 라이브러리 섹션](#alternative-libraries)을 읽는 것을 권장합니다.

## 주요 기능

자산 파이프라인의 첫 번째 기능은 각 파일 이름에 SHA256 지문을 삽입하여 파일이 웹 브라우저와 CDN에 의해 캐시되도록 하는 것입니다. 이 지문은 파일 내용을 변경할 때 자동으로 업데이트되어 캐시가 무효화됩니다.

자산 파이프라인의 두 번째 기능은 JavaScript 파일을 제공할 때 [import maps](https://github.com/WICG/import-maps)를 사용하는 것입니다. 이를 통해 변환 및 번들링 없이 ES 모듈(ESM)용으로 만들어진 JavaScript 라이브러리를 사용하여 현대적인 애플리케이션을 구축할 수 있습니다. 이를 통해 **Webpack, yarn, node 또는 JavaScript 도구 체인의 다른 부분이 필요하지 않습니다**.

자산 파이프라인의 세 번째 기능은 모든 CSS 파일을 하나의 주요 `.css` 파일로 연결한 다음 최소화 또는 압축하는 것입니다. 이 가이드의 후반부에서 자세히 알아보겠지만, 이 전략을 원하는 대로 파일을 그룹화할 수 있습니다. 프로덕션 환경에서 Rails는 각 파일 이름에 SHA256 지문을 삽입하여 파일이 웹 브라우저에 의해 캐시되도록 합니다. 파일 내용을 변경할 때마다 이 지문을 수정하여 캐시를 무효화할 수 있습니다.

자산 파이프라인의 네 번째 기능은 CSS에 대해 고수준 언어를 사용하여 자산을 코딩할 수 있도록 하는 것입니다.

### 지문이란 무엇이며 왜 신경 써야 하나요?

지문은 파일의 이름을 파일의 내용에 따라 결정하는 기술입니다. 파일 내용이 변경되면 파일 이름도 변경됩니다. 정적이거나 자주 변경되지 않는 콘텐츠의 경우, 서로 다른 서버나 배포 날짜를 가리지 않고 두 개의 파일 버전이 동일한지 쉽게 확인할 수 있는 방법을 제공합니다.

파일 이름이 고유하고 내용에 기반한 경우, HTTP 헤더를 설정하여 캐시가 콘텐츠의 자체 복사본을 유지하도록 할 수 있습니다(콘텐츠 배달 네트워크(CDN), 인터넷 서비스 제공자(ISP), 네트워킹 장비 또는 웹 브라우저에서). 콘텐츠가 업데이트되면 지문이 변경됩니다. 이로 인해 원격 클라이언트는 콘텐츠의 새로운 복사본을 요청하게 됩니다. 이를 일반적으로 _캐시 무효화_라고 합니다.

Sprockets가 지문을 생성하는 기술은 일반적으로 이름 끝에 내용의 해시를 삽입하는 것입니다. 예를 들어 CSS 파일 `global.css`

```
global-908e25f4bf641868d8683022a5b62f54.css
```

이것은 Rails 자산 파이프라인에서 채택한 전략입니다.

지문은 개발 및 프로덕션 환경에서 기본적으로 활성화되어 있습니다. [`config.assets.digest`][] 옵션을 통해 구성에서 활성화 또는 비활성화할 수 있습니다.

### Import Maps란 무엇이며 왜 신경 써야 하나요?

Import Maps를 사용하면 브라우저에서 직접 버전화된 파일과 매핑되는 논리적인 이름을 사용하여 JavaScript 모듈을 가져올 수 있습니다. 따라서 변환 또는 번들링할 필요 없이 ES 모듈(ESM)용으로 만들어진 JavaScript 라이브러리를 사용하여 현대적인 JavaScript 애플리케이션을 구축할 수 있습니다.

이 접근 방식을 사용하면 하나의 큰 JavaScript 파일 대신 많은 작은 JavaScript 파일을 전송할 수 있습니다. 초기 전송 중에는 물질적인 성능 저하가 없으며, 사실 장기적으로는 더 나은 캐싱 동적을 제공하여 상당한 이점을 제공합니다.
자바스크립트 자산 파이프라인으로서의 Import Maps 사용 방법
-----------------------------

Import Maps는 기본 자바스크립트 프로세서로, import maps의 생성 로직은 [`importmap-rails`](https://github.com/rails/importmap-rails) 젬에 의해 처리됩니다.

경고: Import maps는 자바스크립트 파일에만 사용되며 CSS 전달에는 사용할 수 없습니다. CSS에 대해 알아보려면 [Sprockets 섹션](#how-to-use-sprockets)을 확인하세요.

젬 홈페이지에서 자세한 사용 방법을 찾을 수 있지만, `importmap-rails`의 기본 개념을 이해하는 것이 중요합니다.

### 작동 방식

Import maps는 본질적으로 "베어 모듈 지정자"라고 불리는 것에 대한 문자열 치환입니다. 이를 통해 JavaScript 모듈 임포트의 이름을 표준화할 수 있습니다.

예를 들어 다음과 같은 임포트 정의는 import map 없이는 작동하지 않습니다:

```javascript
import React from "react"
```

다음과 같이 정의해야 작동합니다:

```javascript
import React from "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

여기서 import map이 등장합니다. 우리는 `react` 이름을 `https://ga.jspm.io/npm:react@17.0.2/index.js` 주소에 고정시킵니다. 이와 같은 정보로 브라우저는 단순화된 `import React from "react"` 정의를 수용합니다. import map은 라이브러리 소스 주소에 대한 별칭으로 생각할 수 있습니다.

### 사용 방법

`importmap-rails`를 사용하면 라이브러리 경로를 이름에 고정시키는 importmap 구성 파일을 생성할 수 있습니다:

```ruby
# config/importmap.rb
pin "application"
pin "react", to: "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

구성된 모든 import map은 `<head>` 요소에 `<%= javascript_importmap_tags %>`를 추가하여 애플리케이션에 첨부됩니다. `javascript_importmap_tags`는 `head` 요소에 여러 스크립트를 렌더링합니다:

- 모든 구성된 import map을 포함하는 JSON:

```html
<script type="importmap">
{
  "imports": {
    "application": "/assets/application-39f16dc3f3....js"
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js"
  }
}
</script>
```

- 오래된 브라우저에서 `import maps`를 지원하기 위한 폴리필인 [`Es-module-shims`](https://github.com/guybedford/es-module-shims):

```html
<script src="/assets/es-module-shims.min" async="async" data-turbo-track="reload"></script>
```

- `app/javascript/application.js`에서 JavaScript를 로드하기 위한 진입점:

```html
<script type="module">import "application"</script>
```

### JavaScript CDNs을 통한 npm 패키지 사용

`importmap-rails` 설치의 일부로 추가되는 `./bin/importmap` 명령을 사용하여 import map에서 npm 패키지를 고정, 해제 또는 업데이트할 수 있습니다. 이 binstub은 [`JSPM.org`](https://jspm.org/)를 사용합니다.

다음과 같이 작동합니다:

```sh
./bin/importmap pin react react-dom
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/index.js
Pinning "react-dom" to https://ga.jspm.io/npm:react-dom@17.0.2/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
Pinning "scheduler" to https://ga.jspm.io/npm:scheduler@0.20.2/index.js

./bin/importmap json

{
  "imports": {
    "application": "/assets/application-37f365cbecf1fa2810a8303f4b6571676fa1f9c56c248528bc14ddb857531b95.js",
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js",
    "react-dom": "https://ga.jspm.io/npm:react-dom@17.0.2/index.js",
    "object-assign": "https://ga.jspm.io/npm:object-assign@4.1.1/index.js",
    "scheduler": "https://ga.jspm.io/npm:scheduler@0.20.2/index.js"
  }
}
```

보시다시피, react와 react-dom 두 패키지는 jspm 기본값으로 해결될 때 총 네 개의 종속성을 가집니다.

이제 이를 `application.js` 진입점에서 다른 모듈과 마찬가지로 사용할 수 있습니다:

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

특정 버전을 고정할 수도 있습니다:

```sh
./bin/importmap pin react@17.0.1
Pinning "react" to https://ga.jspm.io/npm:react@17.0.1/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

또는 핀을 제거할 수도 있습니다:

```sh
./bin/importmap unpin react
Unpinning "react"
Unpinning "object-assign"
```

개별 "production" (기본값) 및 "development" 빌드를 가진 패키지의 환경을 제어할 수도 있습니다:

```sh
./bin/importmap pin react --env development
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/dev.index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

핀을 지정할 때 [`unpkg`](https://unpkg.com/) 또는 [`jsdelivr`](https://www.jsdelivr.com/)와 같은 대체 CDN 공급자를 선택할 수도 있습니다 ([`jspm`](https://jspm.org/)이 기본값입니다):

```sh
./bin/importmap pin react --from jsdelivr
Pinning "react" to https://cdn.jsdelivr.net/npm/react@17.0.2/index.js
```

그러나 한 공급자에서 다른 공급자로 핀을 전환하는 경우, 두 번째 공급자에서 사용되지 않는 첫 번째 공급자에 의해 추가된 종속성을 정리해야 할 수도 있다는 점을 기억하세요.

모든 옵션을 보려면 `./bin/importmap` 을 실행하세요.

이 명령은 논리적인 패키지 이름을 CDN URL로 해석하기 위한 편의 래퍼일 뿐입니다. CDN URL을 직접 찾아서 핀할 수도 있습니다. 예를 들어, React에 Skypack을 사용하려면 다음을 `config/importmap.rb`에 추가하기만 하면 됩니다:

```ruby
pin "react", to: "https://cdn.skypack.dev/react"
```

### 고정된 모듈 사전로드

가장 깊게 중첩된 임포트에 도달하기 전에 브라우저가 하나의 파일을 다른 파일 뒤에 로드해야 하는 폭포 효과를 피하기 위해, importmap-rails는 [modulepreload 링크](https://developers.google.com/web/updates/2017/12/modulepreload)를 지원합니다. 고정된 모듈은 핀에 `preload: true`를 추가하여 사전로드될 수 있습니다.

앱 전체에서 사용되는 라이브러리나 프레임워크를 사전로드하는 것이 좋습니다. 이렇게 하면 브라우저가 이를 더 빨리 다운로드하도록 알려줍니다.

예시:

```ruby
# config/importmap.rb
pin "@github/hotkey", to: "https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js", preload: true
pin "md5", to: "https://cdn.jsdelivr.net/npm/md5@2.3.0/md5.js"

# app/views/layouts/application.html.erb
<%= javascript_importmap_tags %>

# importmap이 설정되기 전에 다음 링크를 포함합니다:
<link rel="modulepreload" href="https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js">
...
```
참고: 최신 문서는 [`importmap-rails`](https://github.com/rails/importmap-rails) 저장소를 참조하십시오.

Sprockets 사용 방법
-----------------------------

웹에 애플리케이션 자산을 노출시키는 가장 단순한 방법은 `public` 폴더의 하위 디렉토리인 `images`와 `stylesheets`와 같은 곳에 저장하는 것입니다. 그러나 대부분의 현대적인 웹 애플리케이션은 자산을 특정한 방식으로 처리해야 하기 때문에 수동으로 이 작업을 수행하는 것은 어렵습니다. 예를 들어 자산을 압축하고 지문을 추가하는 것입니다.

Sprockets는 구성된 디렉토리에 저장된 자산을 자동으로 전처리하고, 지문, 압축, 소스 맵 생성 및 기타 구성 가능한 기능을 사용하여 `public/assets` 폴더에 노출시킵니다.

자산은 여전히 `public` 계층에 배치할 수 있습니다. `public` 아래의 모든 자산은 [`config.public_file_server.enabled`][]가 true로 설정된 경우 애플리케이션 또는 웹 서버에서 정적 파일로 제공됩니다. 서비스되기 전에 일부 전처리를 수행해야 하는 파일에 대한 `manifest.js` 지시문을 정의해야 합니다.

프로덕션 환경에서 Rails는 기본적으로 이러한 파일을 `public/assets`로 사전 컴파일합니다. 그런 다음 웹 서버에서 정적 자산으로 제공됩니다. `app/assets`의 파일은 프로덕션에서 직접 제공되지 않습니다.


### 매니페스트 파일과 지시문

Sprockets로 자산을 컴파일할 때, Sprockets는 컴파일할 상위 대상을 결정해야 합니다. 일반적으로 `application.css`와 이미지입니다. 상위 대상은 Sprockets `manifest.js` 파일에 정의되어 있으며, 기본적으로 다음과 같이 보입니다:

```js
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_tree ../../javascript .js
//= link_tree ../../../vendor/javascript .js
```

이 파일에는 Sprockets에게 단일 CSS 또는 JavaScript 파일을 빌드하기 위해 필요한 파일을 지시하는 _지시문_이 포함되어 있습니다.

이는 `./app/assets/images` 디렉토리 또는 하위 디렉토리에 있는 모든 파일의 내용을 포함하며, `./app/javascript` 또는 `./vendor/javascript`에서 직접 JS로 인식되는 파일을 포함합니다.

`./app/assets/stylesheets` 디렉토리(하위 디렉토리는 포함되지 않음)에서 CSS를 로드합니다. `./app/assets/stylesheets` 폴더에 `application.css`와 `marketing.css` 파일이 있다고 가정하면, `<%= stylesheet_link_tag "application" %>` 또는 `<%= stylesheet_link_tag "marketing" %>`를 사용하여 해당 스타일시트를 뷰에서 로드할 수 있습니다.

기본적으로 JavaScript 파일은 `assets` 디렉토리에서 로드되지 않는 것을 알 수 있습니다. 이는 `./app/javascript`가 `importmap-rails` 젬의 기본 진입점이기 때문이며, `vendor` 폴더는 다운로드한 JS 패키지가 저장되는 곳입니다.

`manifest.js`에서는 디렉토리 전체 대신 특정 파일을 로드하기 위해 `link` 지시문을 지정할 수도 있습니다. `link` 지시문은 명시적인 파일 확장자를 제공해야 합니다.

Sprockets는 지정된 파일을 로드하고 필요한 경우 처리한 후 하나의 파일로 연결한 다음 (`config.assets.css_compressor` 또는 `config.assets.js_compressor`의 값에 따라) 압축합니다. 압축은 파일 크기를 줄여 브라우저가 파일을 더 빠르게 다운로드할 수 있도록 합니다.

### 컨트롤러별 자산

스캐폴드 또는 컨트롤러를 생성할 때, Rails는 해당 컨트롤러에 대한 Cascading Style Sheet 파일을 생성합니다. 또한 스캐폴드를 생성할 때, Rails는 `scaffolds.css` 파일을 생성합니다.

예를 들어, `ProjectsController`를 생성하면 Rails는 `app/assets/stylesheets/projects.css`에 새 파일을 추가합니다. 기본적으로 이러한 파일은 `manifest.js` 파일의 `link_directory` 지시문을 사용하여 즉시 애플리케이션에서 사용할 준비가 됩니다.

또한 다음과 같이 컨트롤러별 스타일시트 파일을 해당 컨트롤러에서만 사용하도록 선택할 수 있습니다:

```html+erb
<%= stylesheet_link_tag params[:controller] %>
```

이렇게 할 때, `application.css`에서 `require_tree` 지시문을 사용하지 않도록 주의해야 합니다. 그렇지 않으면 컨트롤러별 자산이 중복으로 포함될 수 있습니다.

### 자산 구성

파이프라인 자산은 애플리케이션 내에서 세 가지 위치 중 하나에 배치할 수 있습니다: `app/assets`, `lib/assets` 또는 `vendor/assets`.

* `app/assets`는 애플리케이션이 소유한 자산(사용자 정의 이미지 또는 스타일시트 등)을 위한 것입니다.

* `app/javascript`는 JavaScript 코드를 위한 것입니다.

* `vendor/[assets|javascript]`는 CSS 프레임워크 또는 JavaScript 라이브러리와 같이 외부 엔티티가 소유한 자산을 위한 것입니다. 다른 파일에 대한 참조를 포함하는 타사 코드(이미지, 스타일시트 등)도 자산 파이프라인에서 처리되어야 하므로 `asset_path`와 같은 도우미를 사용하여 다시 작성해야 합니다.

`manifest.js` 파일에서 다른 위치를 구성할 수도 있으며, [매니페스트 파일과 지시문](#manifest-files-and-directives)을 참조하십시오.

#### 검색 경로

파일이 매니페스트나 도우미에서 참조될 때, Sprockets는 `manifest.js`에서 지정된 모든 위치를 검색합니다. 검색 경로는 Rails 콘솔에서 [`Rails.application.config.assets.paths`](configuring.html#config-assets-paths)를 검사하여 확인할 수 있습니다.
#### 폴더 대신 인덱스 파일을 프록시로 사용하기

Sprockets는 특정 목적으로 `index`라는 이름의 파일(확장자와 함께)을 사용합니다.

예를 들어, 많은 모듈이 있는 CSS 라이브러리가 `lib/assets/stylesheets/library_name`에 저장되어 있다면, 파일 `lib/assets/stylesheets/library_name/index.css`는 이 라이브러리의 모든 파일에 대한 매니페스트로 작동합니다. 이 파일에는 필요한 모든 파일의 목록이 순서대로 포함될 수 있거나, 간단한 `require_tree` 지시문이 포함될 수 있습니다.

이는 마치 `public/library_name/index.html`에 있는 파일이 `/library_name`으로 요청을 통해 접근할 수 있는 방식과 비슷합니다. 이는 즉, 인덱스 파일을 직접 사용할 수 없다는 것을 의미합니다.

CSS 파일에서 전체 라이브러리에 접근하는 방법은 다음과 같습니다:

```css
/* ...
*= require library_name
*/
```

이를 통해 관련 코드를 다른 곳에 포함시키기 전에 관리를 간소화하고 코드를 깔끔하게 유지할 수 있습니다.

### 자산에 대한 링크 작성

Sprockets는 자산에 액세스하기 위해 새로운 메서드를 추가하지 않습니다. 여전히 익숙한 `stylesheet_link_tag`을 사용합니다:

```erb
<%= stylesheet_link_tag "application", media: "all" %>
```

Rails에 기본으로 포함되어 있는 [`turbo-rails`](https://github.com/hotwired/turbo-rails) 젬을 사용하는 경우, `data-turbo-track` 옵션을 포함하여 Turbo가 자산이 업데이트되었는지 확인하고 업데이트된 경우 페이지에 로드하도록 할 수 있습니다:

```erb
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
```

일반적인 뷰에서는 다음과 같이 `app/assets/images` 디렉토리의 이미지에 액세스할 수 있습니다:

```erb
<%= image_tag "rails.png" %>
```

애플리케이션에서 파이프라인이 활성화되어 있고(current environment context에서 비활성화되지 않은 경우), 이 파일은 Sprockets에 의해 제공됩니다. `public/assets/rails.png`에 파일이 존재하는 경우 웹 서버에 의해 제공됩니다.

또는 `public/assets/rails-f90d8a84c707a8dc923fca1ca1895ae8ed0a09237f6992015fef1e11be77c023.png`과 같은 SHA256 해시를 가진 파일에 대한 요청도 동일한 방식으로 처리됩니다. 이러한 해시가 생성되는 방법은 이 가이드의 [In Production](#in-production) 섹션에서 다루고 있습니다.

필요한 경우 이미지를 하위 디렉토리로 구성하고, 태그에서 디렉토리 이름을 지정하여 액세스할 수도 있습니다:

```erb
<%= image_tag "icons/rails.png" %>
```

경고: 자산을 사전 컴파일하는 경우(자세한 내용은 [In Production](#in-production) 참조), 존재하지 않는 자산에 대한 링크는 호출 페이지에서 예외를 발생시킵니다. 이는 빈 문자열에 대한 링크를 포함하여 `image_tag`와 다른 도우미를 사용할 때 주의해야 함을 의미합니다.

#### CSS와 ERB

자산 파이프라인은 자동으로 ERB를 평가합니다. 이는 CSS 자산에 `erb` 확장자를 추가하면(`application.css.erb`와 같이), `asset_path`와 같은 도우미를 CSS 규칙에서 사용할 수 있다는 것을 의미합니다:

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

이는 참조되는 특정 자산의 경로를 작성합니다. 이 예제에서는 `app/assets/images/image.png`와 같은 자산 로드 경로에 이미지가 있는 것이 좋습니다. 이 이미지가 이미 `public/assets`에 지문이 있는 파일로 존재하는 경우 해당 경로가 참조됩니다.

[데이터 URI](https://en.wikipedia.org/wiki/Data_URI_scheme)를 사용하려면 - 이미지 데이터를 CSS 파일에 직접 포함하는 방법 - `asset_data_uri` 도우미를 사용할 수 있습니다.

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

이는 CSS 소스에 올바르게 포맷된 데이터 URI를 삽입합니다.

닫는 태그는 `-%>` 스타일일 수 없습니다.

### 자산을 찾을 수 없을 때 오류 발생

sprockets-rails >= 3.2.0을 사용하는 경우, 자산 조회가 수행되고 아무 것도 찾을 수 없을 때 어떤 일이 발생하는지를 구성할 수 있습니다. "자산 대체"를 끄면 자산을 찾을 수 없을 때 오류가 발생합니다.

```ruby
config.assets.unknown_asset_fallback = false
```

"자산 대체"가 활성화된 경우, 자산을 찾을 수 없을 때 경로가 출력되고 오류가 발생하지 않습니다. 자산 대체 동작은 기본적으로 비활성화됩니다.

### 디제스트 비활성화

`config/environments/development.rb`를 업데이트하여 디제스트를 비활성화할 수 있습니다:

```ruby
config.assets.digest = false
```

이 옵션이 true인 경우, 자산 URL에 대해 디제스트가 생성됩니다.

### 소스 맵 활성화

`config/environments/development.rb`를 업데이트하여 소스 맵을 활성화할 수 있습니다:

```ruby
config.assets.debug = true
```

디버그 모드가 켜져 있으면 Sprockets는 각 자산에 대해 소스 맵을 생성합니다. 이를 통해 브라우저의 개발자 도구에서 각 파일을 개별적으로 디버깅할 수 있습니다.

자산은 서버가 시작된 후 첫 번째 요청에서 컴파일되고 캐시됩니다. Sprockets는 후속 요청에서 요청 오버헤드를 줄이기 위해 `must-revalidate` 캐시 제어 HTTP 헤더를 설정합니다 - 이 경우 브라우저는 304(수정되지 않음) 응답을 받습니다.
매니페스트에 있는 파일 중 하나라도 요청 사이에 변경되면 서버는 새로운 컴파일된 파일로 응답합니다.

프로덕션 환경에서
----------------

프로덕션 환경에서 Sprockets는 위에서 설명한 지문화 체계를 사용합니다. 기본적으로 Rails는 에셋이 사전 컴파일되었으며 웹 서버에서 정적 에셋으로 제공될 것으로 가정합니다.

사전 컴파일 단계에서 컴파일된 파일의 내용에서 SHA256이 생성되고 디스크에 기록될 때 파일 이름에 삽입됩니다. 이 지문화된 이름은 매니페스트 이름 대신에 Rails 헬퍼에서 사용됩니다.

예를 들어 다음과 같이 작성됩니다:

```erb
<%= stylesheet_link_tag "application" %>
```

다음과 같은 결과를 생성합니다:

```html
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" rel="stylesheet" />
```

지문화 동작은 [`config.assets.digest`] 초기화 옵션에 의해 제어됩니다(기본값은 `true`입니다).

참고: 일반적인 상황에서는 기본 `config.assets.digest` 옵션을 변경하지 않아야 합니다. 파일 이름에 지문이 없고 먼 미래 헤더가 설정되어 있으면 원격 클라이언트는 내용이 변경될 때 파일을 다시 가져와야 하는 것을 알 수 없습니다.


### 에셋 사전 컴파일

Rails는 에셋 매니페스트와 파이프라인의 다른 파일을 컴파일하는 명령을 번들로 제공합니다.

컴파일된 에셋은 [`config.assets.prefix`]에 지정된 위치에 작성됩니다. 기본적으로 이는 `/assets` 디렉토리입니다.

이 명령을 서버에서 배포 중에 호출하여 서버에서 직접 컴파일된 에셋의 컴파일된 버전을 생성할 수 있습니다. 로컬에서 컴파일하는 방법에 대한 정보는 다음 섹션을 참조하십시오.

명령은 다음과 같습니다:

```bash
$ RAILS_ENV=production rails assets:precompile
```

이 명령은 `config.assets.prefix`에 지정된 폴더를 `shared/assets`에 연결합니다. 이미 이 공유 폴더를 사용하는 경우에는 직접 배포 명령을 작성해야 합니다.

이 폴더가 배포 간에 공유되어야 하므로 이전 컴파일된 에셋을 참조하는 원격 캐시된 페이지가 캐시된 페이지의 수명 동안 작동할 수 있도록 해야 합니다.

참고. 항상 `.js` 또는 `.css`로 끝나는 예상 컴파일된 파일 이름을 지정해야 합니다.

이 명령은 또한 `.sprockets-manifest-randomhex.json` 파일을 생성합니다(`randomhex`는 16바이트 랜덤 16진수 문자열입니다). 이 파일에는 모든 에셋과 해당 지문이 포함된 목록이 포함되어 있습니다. 이는 Rails 헬퍼 메서드가 매핑 요청을 다시 Sprockets에 전달하지 않도록 하는 데 사용됩니다. 일반적인 매니페스트 파일은 다음과 같습니다:

```json
{"files":{"application-<fingerprint>.js":{"logical_path":"application.js","mtime":"2016-12-23T20:12:03-05:00","size":412383,
"digest":"<fingerprint>","integrity":"sha256-<random-string>"}},
"assets":{"application.js":"application-<fingerprint>.js"}}
```

응용 프로그램에서는 매니페스트에 더 많은 파일과 에셋이 나열되며, `<fingerprint>` 및 `<random-string>`도 생성됩니다.

매니페스트의 기본 위치는 `config.assets.prefix`에 지정된 위치의 루트입니다(기본값은 '/assets'입니다).

참고: 프로덕션에서 사전 컴파일된 파일이 누락되면 `Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError` 예외가 발생하며 누락된 파일의 이름을 나타냅니다.


#### 먼 미래 Expires 헤더

사전 컴파일된 에셋은 파일 시스템에 존재하며 웹 서버에서 직접 제공됩니다. 기본적으로 먼 미래 헤더가 없으므로 지문화의 이점을 얻으려면 서버 구성을 업데이트하여 해당 헤더를 추가해야 합니다.

아파치의 경우:

```apache
# Expires* 지시문은 Apache 모듈 `mod_expires`가 활성화되어 있어야 합니다.
<Location /assets/>
  # Last-Modified가 있는 경우 ETag 사용을 권장하지 않습니다.
  Header unset ETag
  FileETag None
  # RFC에 따르면 1년 동안만 캐시합니다.
  ExpiresActive On
  ExpiresDefault "access plus 1 year"
</Location>
```

NGINX의 경우:

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
}
```

### 로컬 사전 컴파일

가끔은 프로덕션 서버에서 에셋을 컴파일하고 싶지 않거나 할 수 없을 수 있습니다. 예를 들어, 프로덕션 파일 시스템에 제한된 쓰기 액세스 권한이 있거나 에셋에 대한 변경 없이 자주 배포할 계획일 수 있습니다.

이러한 경우에는 에셋을 _로컬로_ 사전 컴파일할 수 있습니다. 즉, 프로덕션 서버에서 각 배포마다 별도로 사전 컴파일할 필요가 없도록 컴파일된 제품용 에셋의 최종 집합을 소스 코드 저장소에 추가합니다. 이렇게 하면 프로덕션에서 각 배포마다 사전 컴파일된 에셋을 별도로 컴파일할 필요가 없습니다.

위와 같이 다음 단계를 수행할 수 있습니다.

```bash
$ RAILS_ENV=production rails assets:precompile
```

다음 주의 사항을 참고하세요:

* 사전 컴파일된 에셋이 있는 경우, 이들이 제공됩니다. 심지어 원래 (컴파일되지 않은) 에셋과 더 이상 일치하지 않더라도 개발 서버에서도 제공됩니다.

    개발 서버가 항상 에셋을 실시간으로 컴파일하도록 구성되어 있어야 합니다(즉, 항상 코드의 최신 상태를 반영해야 함). 이를 위해 개발 환경은 사전 컴파일된 에셋을 프로덕션과 다른 위치에 유지하도록 구성되어야 합니다. 그렇지 않으면 프로덕션에서 사용하기 위해 사전 컴파일된 에셋이 개발에서 요청을 덮어쓸 수 있습니다(즉, 에셋에 대한 변경 사항이 브라우저에 반영되지 않음).
다음 줄을 `config/environments/development.rb`에 추가하여 이 작업을 수행할 수 있습니다:

```ruby
config.assets.prefix = "/dev-assets"
```

* 배포 도구(예: Capistrano)에서 자산 사전 컴파일 작업을 비활성화해야 합니다.
* 필요한 압축기나 최소화기는 개발 시스템에서 사용할 수 있어야 합니다.

또한 `ENV["SECRET_KEY_BASE_DUMMY"]`를 설정하여 임시 파일에 저장된 무작위로 생성된 `secret_key_base`를 사용하도록 트리거할 수 있습니다. 이는 프로덕션에서 자산을 사전 컴파일하는 빌드 단계의 일부로 유용합니다. 이 빌드 단계에서는 프로덕션 비밀 정보에 액세스할 필요가 없습니다.

```bash
$ SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
```

### 실시간 컴파일

일부 상황에서는 실시간 컴파일을 사용하고자 할 수 있습니다. 이 모드에서는 파이프라인의 자산 요청이 모두 Sprockets에서 처리됩니다.

이 옵션을 활성화하려면 다음을 설정하세요:

```ruby
config.assets.compile = true
```

첫 번째 요청에서 자산이 컴파일되고 [자산 캐시 저장소](#assets-cache-store)에 설명된 대로 캐시되며, 도우미에서 사용되는 매니페스트 이름에 SHA256 해시가 포함됩니다.

Sprockets는 또한 `Cache-Control` HTTP 헤더를 `max-age=31536000`로 설정합니다. 이는 서버와 클라이언트 브라우저 사이의 모든 캐시에게 이 콘텐츠(제공된 파일)를 1년 동안 캐시할 수 있다는 신호를 보냅니다. 이로 인해 서버에서 이 자산에 대한 요청 수가 줄어들며, 자산이 로컬 브라우저 캐시나 중간 캐시에 있을 가능성이 큽니다.

이 모드는 더 많은 메모리를 사용하며, 기본 설정보다 성능이 떨어지므로 권장하지 않습니다.

### CDN

CDN은 [콘텐츠 전송 네트워크](https://en.wikipedia.org/wiki/Content_delivery_network)의 약자로, 주로 전 세계에 자산을 캐시하여 브라우저가 자산을 요청할 때 캐시된 사본이 브라우저와 지리적으로 가까운 위치에 있도록 설계되었습니다. 프로덕션에서 Rails 서버에서 자산을 직접 제공하는 경우, 가장 좋은 방법은 응용 프로그램 앞에 CDN을 사용하는 것입니다.

CDN을 사용하는 일반적인 패턴은 프로덕션 응용 프로그램을 "원본" 서버로 설정하는 것입니다. 이는 CDN에서 자산을 요청하고 캐시 미스가 발생하면 파일을 실시간으로 서버에서 가져와 캐시하는 것을 의미합니다. 예를 들어, `example.com`에서 Rails 응용 프로그램을 실행하고 `mycdnsubdomain.fictional-cdn.com`으로 구성된 CDN가 있는 경우, `mycdnsubdomain.fictional-cdn.com/assets/smile.png`로 요청이 발생하면 CDN은 한 번만 `example.com/assets/smile.png`로 서버에 요청하고 요청을 캐시합니다. 동일한 URL로 들어오는 CDN에 대한 다음 요청은 캐시된 사본에 도달합니다. CDN에서 자산을 직접 제공할 수 있는 경우 요청은 Rails 서버에 전달되지 않습니다. CDN에서 제공하는 자산은 브라우저와 지리적으로 가까우므로 요청이 더 빠르게 처리되며, 서버는 자산을 제공하는 데 시간을 소비하지 않고 가능한 빠르게 응용 프로그램 코드를 제공할 수 있습니다.

#### 정적 자산을 제공하기 위해 CDN 설정하기

CDN을 설정하려면 응용 프로그램을 인터넷에서 공개적으로 사용 가능한 URL(예: `example.com`)에서 실행해야 합니다. 그런 다음 클라우드 호스팅 공급자에서 CDN 서비스에 가입해야 합니다. 이를 위해 CDN의 "원본"을 웹 사이트 `example.com`로 구성해야 합니다. 원본 서버를 구성하는 방법에 대한 문서는 공급자의 문서를 확인하세요.

프로비저닝한 CDN은 `mycdnsubdomain.fictional-cdn.com`과 같은 응용 프로그램에 대한 사용자 지정 서브도메인을 제공해야 합니다(이 문서 작성 시점에서 fictional-cdn.com은 유효한 CDN 공급자가 아닙니다). CDN 서버를 구성한 후에는 브라우저가 Rails 서버 대신 CDN을 사용하여 자산을 가져오도록 알려야 합니다. 이를 위해 상대 경로 대신 Rails에서 자산 호스트로 CDN을 설정해야 합니다. Rails에서 자산 호스트를 설정하려면 `config/environments/production.rb`에서 [`config.asset_host`][]를 설정해야 합니다:

```ruby
config.asset_host = 'mycdnsubdomain.fictional-cdn.com'
```

참고: "호스트"만 제공하면 됩니다. 이는 서브도메인과 루트 도메인을 의미하며, `http://` 또는 `https://`와 같은 프로토콜이나 "스킴"을 지정할 필요가 없습니다. 웹 페이지가 요청될 때 생성된 자산 링크의 프로토콜은 기본적으로 웹 페이지에 액세스하는 방법과 일치합니다.

이 값을 [환경 변수](https://en.wikipedia.org/wiki/Environment_variable)를 통해 설정하여 사이트의 스테이징 복사본을 실행하는 것도 가능합니다.
```ruby
config.asset_host = ENV['CDN_HOST']
```

참고: 이 작업을 수행하려면 서버에서 `CDN_HOST`를 `mycdnsubdomain.fictional-cdn.com`으로 설정해야 합니다.

서버와 CDN을 구성한 후에는 다음과 같은 도우미에서 asset 경로를 사용할 수 있습니다.

```erb
<%= asset_path('smile.png') %>
```

이는 `http://mycdnsubdomain.fictional-cdn.com/assets/smile.png`와 같은 전체 CDN URL로 렌더링됩니다 (가독성을 위해 다이제스트는 생략됨).

CDN에 `smile.png`의 사본이 있는 경우, 브라우저에 제공되며 서버는 요청이 있었는지도 모릅니다. CDN에 사본이 없는 경우 "원본"인 `example.com/assets/smile.png`에서 찾아서 저장합니다.

CDN에서 일부 자산만 제공하려면 asset 도우미에서 사용자 정의 `:host` 옵션을 사용할 수 있습니다. 이는 [`config.action_controller.asset_host`][]에 설정된 값이 덮어쓰입니다.

```erb
<%= asset_path 'image.png', host: 'mycdnsubdomain.fictional-cdn.com' %>
```


#### CDN 캐싱 동작 사용자 정의

CDN은 콘텐츠를 캐시하는 방식으로 작동합니다. CDN에 오래된 또는 잘못된 콘텐츠가 있는 경우 애플리케이션에 도움이 되는 대신 손해를 입힐 수 있습니다. 이 섹션의 목적은 대부분의 CDN의 일반적인 캐싱 동작을 설명하는 것입니다. 특정 공급자는 약간 다르게 동작할 수 있습니다.

##### CDN 요청 캐싱

CDN은 자산을 캐시하는 데 좋다고 설명되지만, 실제로는 요청 전체를 캐시합니다. 이는 자산의 본문과 헤더를 포함합니다. 가장 중요한 것은 `Cache-Control`입니다. 이는 CDN(및 웹 브라우저)에 콘텐츠를 어떻게 캐시할지 알려줍니다. 이는 `/assets/i-dont-exist.png`와 같이 존재하지 않는 자산을 요청하면서 Rails 애플리케이션이 404를 반환하는 경우, 유효한 `Cache-Control` 헤더가 있는 경우 CDN이 404 페이지를 캐시할 수 있다는 것을 의미합니다.

##### CDN 헤더 디버깅

CDN에서 헤더가 올바르게 캐시되었는지 확인하는 한 가지 방법은 [curl](https://explainshell.com/explain?cmd=curl+-I+http%3A%2F%2Fwww.example.com)을 사용하여 서버와 CDN에서 헤더를 요청하는 것입니다. 두 헤더가 동일한지 확인할 수 있습니다:

```bash
$ curl -I http://www.example/assets/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK
Server: Cowboy
Date: Sun, 24 Aug 2014 20:27:50 GMT
Connection: keep-alive
Last-Modified: Thu, 08 May 2014 01:24:14 GMT
Content-Type: text/css
Cache-Control: public, max-age=2592000
Content-Length: 126560
Via: 1.1 vegur
```

CDN 사본과 비교:

```bash
$ curl -I http://mycdnsubdomain.fictional-cdn.com/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK Server: Cowboy Last-
Modified: Thu, 08 May 2014 01:24:14 GMT Content-Type: text/css
Cache-Control:
public, max-age=2592000
Via: 1.1 vegur
Content-Length: 126560
Accept-Ranges:
bytes
Date: Sun, 24 Aug 2014 20:28:45 GMT
Via: 1.1 varnish
Age: 885814
Connection: keep-alive
X-Served-By: cache-dfw1828-DFW
X-Cache: HIT
X-Cache-Hits:
68
X-Timer: S1408912125.211638212,VS0,VE0
```

CDN 문서에서 `X-Cache`나 추가 헤더에 대한 추가 정보를 확인하십시오.

##### CDNs와 Cache-Control 헤더

[`Cache-Control`][] 헤더는 요청을 캐시하는 방법을 설명합니다. CDN을 사용하지 않을 때 브라우저는 이 정보를 사용하여 콘텐츠를 캐시합니다. 이는 웹 사이트의 CSS나 JavaScript와 같이 수정되지 않는 자산에 매우 유용합니다. 일반적으로 Rails 서버에서 자산이 "public"임을 CDN(및 브라우저)에 알리고 캐시에 요청을 저장할 수 있도록 합니다. 또한 캐시를 무효화하기 전까지 캐시에 객체를 저장할 기간인 `max-age`를 설정하는 것이 일반적입니다. `max-age` 값은 최대 `31536000`인 초로 설정되며, 1년입니다. Rails 애플리케이션에서 다음과 같이 설정할 수 있습니다.

```ruby
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=31536000'
}
```

이제 애플리케이션이 자산을 제공할 때 CDN은 최대 1년 동안 자산을 저장합니다. 대부분의 CDN은 요청의 헤더도 캐시하므로 이 `Cache-Control`은 이후에 이 자산을 요청하는 모든 브라우저로 전달됩니다. 그러면 브라우저는 이 자산을 다시 요청하기 전에 매우 오랜 시간 동안 저장할 수 있습니다.


##### CDNs와 URL 기반 캐시 무효화

대부분의 CDN은 완전한 URL을 기반으로 자산의 콘텐츠를 캐시합니다. 이는 다음과 같은 요청이 완전히 다른 캐시임을 의미합니다.

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile-123.png
```

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

`Cache-Control`에 먼 훗날 `max-age`를 설정하려면 (그리고 설정해야 합니다) 자산을 변경할 때 캐시를 무효화해야 합니다. 예를 들어 이미지의 웃는 얼굴을 노란색에서 파란색으로 변경하는 경우 사이트의 모든 방문자가 새로운 파란색 얼굴을 받아야 합니다. Rails 자산 파이프라인을 사용할 때 `config.assets.digest`는 기본적으로 true로 설정되어 자산이 변경될 때마다 다른 파일 이름을 가지게 됩니다. 이렇게 하면 캐시에서 항목을 수동으로 무효화할 필요가 없습니다. 대신 다른 고유한 자산 이름을 사용하여 사용자에게 최신 자산을 제공할 수 있습니다.
파이프라인 사용자 정의
------------------------

### CSS 압축

CSS를 압축하는 옵션 중 하나는 YUI입니다. [YUI CSS
compressor](https://yui.github.io/yuicompressor/css.html)는
최소화를 제공합니다.

다음 줄은 YUI 압축을 활성화하며 `yui-compressor`
젬이 필요합니다.

```ruby
config.assets.css_compressor = :yui
```

### JavaScript 압축

JavaScript 압축의 가능한 옵션은 `:terser`, `:closure` 및
`:yui`입니다. 각각 `terser`, `closure-compiler` 또는
`yui-compressor` 젬을 사용해야 합니다.

예를 들어 `terser` 젬을 살펴보겠습니다.
이 젬은 [Terser](https://github.com/terser/terser)를 Ruby로 래핑합니다.
이는 코드에서 공백과 주석을 제거하고 지역 변수 이름을 줄이며,
`if` 및 `else` 문을 가능한 경우 삼항 연산자로 변경하는 등의
마이크로 최적화를 수행하여 코드를 압축합니다.

다음 줄은 JavaScript 압축을 위해 `terser`를 호출합니다.

```ruby
config.assets.js_compressor = :terser
```

참고: `terser`를 사용하려면 [ExecJS](https://github.com/rails/execjs#readme)
지원 런타임이 필요합니다. macOS 또는
Windows를 사용하는 경우 운영 체제에 JavaScript 런타임이 설치되어 있습니다.

참고: JavaScript 압축은 `importmap-rails` 또는 `jsbundling-rails` 젬을 통해
자산을 로드할 때 JavaScript 파일에도 작동합니다.

### 자산 압축

기본적으로 컴파일된 자산의 gzip 버전이 생성되며, 비-gzip 버전의 자산과 함께 생성됩니다.
gzip된 자산은 데이터 전송을 줄이는 데 도움이 됩니다. 이를 설정하려면 `gzip` 플래그를 설정하면 됩니다.

```ruby
config.assets.gzip = false # gzip된 자산 생성 비활성화
```

gzip된 자산을 제공하는 방법에 대한 지침은 웹 서버의 문서를 참조하십시오.

### 사용자 정의 압축기 사용

CSS 및 JavaScript에 대한 압축기 구성 설정은 모든 객체도 허용합니다.
이 객체는 유일한 인수로 문자열을 받는 `compress` 메서드를 가져야 하며,
문자열을 반환해야 합니다.

```ruby
class Transformer
  def compress(string)
    do_something_returning_a_string(string)
  end
end
```

이를 활성화하려면 `application.rb`의 구성 옵션에 새 객체를 전달하면 됩니다.

```ruby
config.assets.css_compressor = Transformer.new
```

### _assets_ 경로 변경

Sprockets가 기본적으로 사용하는 공개 경로는 `/assets`입니다.

이를 다른 값으로 변경할 수 있습니다.

```ruby
config.assets.prefix = "/some_other_path"
```

이는 자산 파이프라인을 사용하지 않았던 이전 프로젝트를 업데이트하거나
새 리소스에 이 경로를 사용하려는 경우에 유용한 옵션입니다.

### X-Sendfile 헤더

X-Sendfile 헤더는 웹 서버에게 응답을 무시하고 지정된 파일을 디스크에서 제공하도록 지시하는 것입니다.
이 옵션은 기본적으로 꺼져 있지만, 서버가 지원하는 경우 활성화할 수 있습니다.
활성화되면 파일을 제공하는 책임을 웹 서버에게 넘기므로 더 빠릅니다.
이 기능의 사용 방법은 [send_file](https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file)을 참조하십시오.

Apache와 NGINX는 이 옵션을 지원하며, `config/environments/production.rb`에서 활성화할 수 있습니다.

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # Apache용
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # NGINX용
```

경고: 기존 애플리케이션을 업그레이드하고 이 옵션을 사용하려는 경우,
이 구성 옵션을 `production.rb`에만 붙여넣고
`application.rb`이 아닌 프로덕션 동작을 정의하는 다른 환경에도 붙여넣는지 주의하세요.

팁: 자세한 내용은 프로덕션 웹 서버의 문서를 참조하십시오:

- [Apache](https://tn123.org/mod_xsendfile/)
- [NGINX](https://www.nginx.com/resources/wiki/start/topics/examples/xsendfile/)

자산 캐시 저장소
------------------

기본적으로 Sprockets는 개발 및 프로덕션 환경에서 자산을 `tmp/cache/assets`에 캐시합니다.
다음과 같이 변경할 수 있습니다.

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:memory_store,
                                                { size: 32.megabytes })
end
```

자산 캐시 저장소를 비활성화하려면:

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:null_store)
end
```

젬에 자산 추가하기
--------------------------

자산은 젬 형태로 외부 소스에서도 제공될 수 있습니다.

이에 대한 좋은 예는 `jquery-rails` 젬입니다.
이 젬에는 `Rails::Engine`에서 상속받은 엔진 클래스가 포함되어 있습니다.
이를 통해 Rails는 이 젬의 디렉토리가 자산을 포함할 수 있음을 알게 되며,
이 엔진의 `app/assets`, `lib/assets` 및 `vendor/assets` 디렉토리가
Sprockets의 검색 경로에 추가됩니다.

라이브러리 또는 젬을 전처리기로 만들기
------------------------------------------

Sprockets는 프로세서, 변환기, 압축기 및 익스포터를 사용하여
Sprockets 기능을 확장합니다. 자세한 내용은
[Sprockets 확장](https://github.com/rails/sprockets/blob/master/guides/extending_sprockets.md)를 참조하십시오.
여기에서는 텍스트/CSS (`.css`) 파일 끝에 주석을 추가하기 위해 전처리기를 등록했습니다.

```ruby
module AddComment
  def self.call(input)
    { data: input[:data] + "/* Hello From my sprockets extension */" }
  end
end
```

이제 입력 데이터를 수정하는 모듈이 있으므로 MIME 유형에 대한 전처리기로 등록할 시간입니다.
```ruby
Sprockets.register_preprocessor 'text/css', AddComment
```


대체 라이브러리
------------------------------------------

여러 해 동안 자산 처리에 대한 여러 가지 기본 접근 방식이 있었습니다. 웹이 진화하면서 JavaScript 중심의 애플리케이션이 점점 더 많이 등장하기 시작했습니다. 레일스 도큐트린에서는 [메뉴는 오마카세](https://rubyonrails.org/doctrine#omakase)라고 믿기 때문에 기본 설정인 **Sprockets with Import Maps**에 초점을 맞췄습니다.

우리는 다양한 JavaScript 및 CSS 프레임워크/확장에 대해 일반적으로 적용할 수 있는 해결책은 없다는 것을 알고 있습니다. 기본 설정만으로는 충분하지 않은 경우 레일스 생태계에는 다른 번들링 라이브러리가 있어 여러분을 지원해줄 수 있습니다.

### jsbundling-rails

[`jsbundling-rails`](https://github.com/rails/jsbundling-rails)은 JavaScript를 [esbuild](https://esbuild.github.io/), [rollup.js](https://rollupjs.org/) 또는 [Webpack](https://webpack.js.org/)을 사용하여 번들링하는 `importmap-rails` 방식의 대체 라이브러리입니다.

이 젬은 개발 중에 자동으로 출력을 생성하기 위해 `yarn build --watch` 프로세스를 제공합니다. 프로덕션에서는 `javascript:build` 작업을 `assets:precompile` 작업에 자동으로 연결하여 모든 패키지 종속성이 설치되었고 모든 엔트리 포인트에 대해 JavaScript가 빌드되었는지 확인합니다.

**`importmap-rails` 대신 언제 사용해야 할까요?** JavaScript 코드가 변환에 의존하는 경우, 즉 [Babel](https://babeljs.io/), [TypeScript](https://www.typescriptlang.org/) 또는 React `JSX` 형식을 사용하는 경우 `jsbundling-rails`를 사용하는 것이 올바른 방법입니다.

### Webpacker/Shakapacker

[`Webpacker`](webpacker.html)는 Rails 5와 6의 기본 JavaScript 전처리기 및 번들러였습니다. 이제는 사용되지 않습니다. [`shakapacker`](https://github.com/shakacode/shakapacker)라는 후속 제품이 존재하지만 레일스 팀이나 프로젝트에서 유지되지 않습니다.

이 목록의 다른 라이브러리와 달리 `webpacker`/`shakapacker`는 Sprockets와 완전히 독립적이며 JavaScript와 CSS 파일을 모두 처리할 수 있습니다. 자세한 내용은 [Webpacker 가이드](https://guides.rubyonrails.org/webpacker.html)를 참조하십시오.

참고: `jsbundling-rails`와 `webpacker`/`shakapacker` 사이의 차이점을 이해하기 위해 [Webpacker와의 비교](https://github.com/rails/jsbundling-rails/blob/main/docs/comparison_with_webpacker.md) 문서를 읽어보세요.

### cssbundling-rails

[`cssbundling-rails`](https://github.com/rails/cssbundling-rails)는 [Tailwind CSS](https://tailwindcss.com/), [Bootstrap](https://getbootstrap.com/), [Bulma](https://bulma.io/), [PostCSS](https://postcss.org/), 또는 [Dart Sass](https://sass-lang.com/)를 사용하여 CSS를 번들링하고 처리할 수 있도록 해주며, 자산 파이프라인을 통해 CSS를 전달합니다.

`jsbundling-rails`와 유사한 방식으로 작동하므로 개발 중에 스타일시트를 다시 생성하기 위해 `yarn build:css --watch` 프로세스를 응용 프로그램에 Node.js 종속성을 추가하고, 프로덕션에서는 `assets:precompile` 작업에 연결합니다.

**Sprockets와의 차이점은 무엇인가요?** Sprockets 자체로는 Sass를 CSS로 변환할 수 없으므로 Node.js가 필요합니다. `.sass` 파일에서 `.css` 파일을 생성하기 위해 Node.js가 필요합니다. `.css` 파일이 생성되면 `Sprockets`가 클라이언트에게 제공할 수 있습니다.

참고: `cssbundling-rails`는 CSS를 처리하기 위해 Node를 사용합니다. `dartsass-rails` 및 `tailwindcss-rails` 젬은 Tailwind CSS와 Dart Sass의 독립 실행형 버전을 사용하므로 Node 종속성이 없습니다. JavaScript를 처리하기 위해 `importmap-rails`를 사용하고 CSS를 위해 `dartsass-rails` 또는 `tailwindcss-rails`를 사용하는 경우 Node 종속성을 완전히 피할 수 있으므로 덜 복잡한 솔루션을 얻을 수 있습니다.

### dartsass-rails

애플리케이션에서 [`Sass`](https://sass-lang.com/)를 사용하려면 [`dartsass-rails`](https://github.com/rails/dartsass-rails)가 레거시 `sassc-rails` 젬의 대체품으로 제공됩니다. `dartsass-rails`는 `sassc-rails`에서 사용되는 2020년에 폐기된 [`LibSass`](https://sass-lang.com/blog/libsass-is-deprecated) 대신 `Dart Sass` 구현을 사용합니다.

`sassc-rails`와 달리 새로운 젬은 직접적으로 `Sprockets`와 통합되지 않습니다. 설치/마이그레이션 지침은 [젬 홈페이지](https://github.com/rails/dartsass-rails)를 참조하십시오.

경고: 인기 있는 `sassc-rails` 젬은 2019년 이후로 유지되지 않고 있습니다.

### tailwindcss-rails

[`tailwindcss-rails`](https://github.com/rails/tailwindcss-rails)는 Tailwind CSS v3 프레임워크의 [독립 실행형 버전](https://tailwindcss.com/blog/standalone-cli)을 위한 래퍼 젬입니다. `rails new` 명령에 `--css tailwind`가 제공되는 경우 새로운 애플리케이션에 사용됩니다. 개발 중에 자동으로 Tailwind 출력을 생성하기 위한 `watch` 프로세스를 제공합니다. 프로덕션에서는 `assets:precompile` 작업에 연결합니다.
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.assets.digest`]: configuring.html#config-assets-digest
[`config.assets.prefix`]: configuring.html#config-assets-prefix
[`config.action_controller.asset_host`]: configuring.html#config-action-controller-asset-host
[`config.asset_host`]: configuring.html#config-asset-host
[`Cache-Control`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
