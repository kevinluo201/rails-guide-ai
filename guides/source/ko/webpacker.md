**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 148ef2d23e16b9e0df83b14e98526736
Webpacker
=========

이 가이드는 웹팩을 설치하고 사용하여 Rails 애플리케이션의 클라이언트 측에 대한 JavaScript, CSS 및 기타 에셋을 패키징하는 방법을 안내합니다. 그러나 [Webpacker는 더 이상 사용되지 않습니다](https://github.com/rails/webpacker#webpacker-has-been-retired-).

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* Webpacker가 무엇을 하는지 및 Sprockets와의 차이점은 무엇인지.
* Webpacker를 설치하고 원하는 프레임워크와 통합하는 방법.
* JavaScript 에셋에 Webpacker를 사용하는 방법.
* CSS 에셋에 Webpacker를 사용하는 방법.
* 정적 에셋에 Webpacker를 사용하는 방법.
* Webpacker를 사용하는 사이트를 배포하는 방법.
* 엔진이나 Docker 컨테이너와 같은 대체 Rails 컨텍스트에서 Webpacker를 사용하는 방법.

--------------------------------------------------------------

Webpacker란?
------------------

Webpacker는 [webpack](https://webpack.js.org) 빌드 시스템을 감싼 Rails 래퍼로, 표준 webpack 구성과 합리적인 기본값을 제공합니다.

### Webpack이란 무엇인가요?

webpack 또는 다른 프론트엔드 빌드 시스템의 목표는 개발자가 편리하게 프론트엔드 코드를 작성한 다음 브라우저에서 편리하게 패키징할 수 있도록 하는 것입니다. webpack을 사용하면 JavaScript, CSS 및 이미지 또는 폰트와 같은 정적 에셋을 관리할 수 있습니다. webpack을 사용하면 코드를 작성하고 애플리케이션의 다른 코드를 참조하고 코드를 변환하며 코드를 쉽게 다운로드할 수 있는 팩으로 결합할 수 있습니다.

자세한 내용은 [webpack 문서](https://webpack.js.org)를 참조하십시오.

### Webpacker는 Sprockets와 어떻게 다른가요?

Rails에는 Sprockets라는 에셋 패키징 도구도 함께 제공됩니다. Sprockets와 Webpacker는 모두 JavaScript를 브라우저 친화적인 파일로 컴파일하고, 제품 환경에서는 최소화하고 지문을 생성합니다. 개발 환경에서는 Sprockets와 Webpacker를 사용하여 파일을 증분적으로 변경할 수 있습니다.

Rails와 함께 사용하기 위해 설계된 Sprockets는 상대적으로 간단하게 통합할 수 있습니다. 특히, Ruby gem을 통해 Sprockets에 코드를 추가할 수 있습니다. 그러나 webpack은 더 최신의 JavaScript 도구와 NPM 패키지와 더 잘 통합되며 더 다양한 통합 범위를 제공합니다. 새로운 Rails 앱은 JavaScript에 webpack을 사용하고 CSS에 Sprockets를 사용하도록 구성되어 있지만, webpack에서도 CSS를 사용할 수 있습니다.

NPM 패키지를 사용하려는 경우와/또는 가장 최신의 JavaScript 기능과 도구에 액세스하려는 경우 새 프로젝트에서는 Sprockets 대신 Webpacker를 선택해야 합니다. 마이그레이션이 비용이 많이 드는 기존 애플리케이션, Gem을 사용하여 통합하려는 경우 또는 패키징할 코드가 매우 적은 경우에는 Sprockets를 선택해야 합니다.

Sprockets에 익숙하다면 다음 가이드가 어떻게 번역되는지에 대한 아이디어를 얻을 수 있습니다. 각 도구마다 약간 다른 구조가 있고 개념이 직접적으로 매핑되지 않는다는 점을 참고하십시오.

|작업              | Sprockets            | Webpacker         |
|------------------|----------------------|-------------------|
|JavaScript 첨부 |javascript_include_tag|javascript_pack_tag|
|CSS 첨부        |stylesheet_link_tag   |stylesheet_pack_tag|
|이미지 링크  |image_url             |image_pack_tag     |
|에셋 링크  |asset_url             |asset_pack_tag     |
|스크립트 요구  |//= require           |import 또는 require  |

Webpacker 설치하기
--------------------

Webpacker를 사용하려면 Yarn 패키지 매니저 버전 1.x 이상을 설치해야 하며, Node.js 버전 10.13.0 이상이 설치되어 있어야 합니다.

참고: Webpacker는 NPM과 Yarn에 의존합니다. NPM은 Node.js 및 브라우저 런타임용 오픈 소스 JavaScript 프로젝트를 게시하고 다운로드하는 주요 저장소입니다. Ruby gem을 위한 rubygems.org와 유사합니다. Yarn은 JavaScript 종속성의 설치와 관리를 가능하게 하는 명령줄 유틸리티로, Ruby의 Bundler와 유사한 기능을 제공합니다.

새 프로젝트에 Webpacker를 포함하려면 `rails new` 명령에 `--webpack`을 추가하십시오. 기존 프로젝트에 Webpacker를 추가하려면 프로젝트의 `Gemfile`에 `webpacker` 젬을 추가한 다음 `bundle install`을 실행한 후 `bin/rails webpacker:install`을 실행하십시오.

Webpacker 설치는 다음 로컬 파일을 생성합니다:

|파일                    |위치                |설명                                                                                         |
|------------------------|------------------------|----------------------------------------------------------------------------------------------------|
|JavaScript 폴더       | `app/javascript`       |프론트엔드 소스를 위한 장소                                                                   |
|Webpacker 구성 | `config/webpacker.yml` |Webpacker 젬을 구성합니다                                                                         |
|Babel 구성     | `babel.config.js`      |[Babel](https://babeljs.io) JavaScript 컴파일러를 위한 구성                               |
|PostCSS 구성   | `postcss.config.js`    |[PostCSS](https://postcss.org) CSS 후처리기를 위한 구성                             |
|Browserlist             | `.browserslistrc`      |[Browserlist](https://github.com/browserslist/browserslist)는 대상 브라우저 구성을 관리합니다   |


설치 과정에서 `yarn` 패키지 매니저를 호출하고, 기본적인 패키지 목록이 포함된 `package.json` 파일을 생성하며, 이러한 종속성을 설치하기 위해 Yarn을 사용합니다.

사용법
-----

### JavaScript에 Webpacker 사용하기

Webpacker가 설치되면 `app/javascript/packs` 디렉토리에 있는 JavaScript 파일은 기본적으로 자체 팩 파일로 컴파일됩니다.
`app/javascript/packs/application.js`라는 파일이 있다면, Webpacker는 `application`이라는 팩을 생성하고 코드 `<%= javascript_pack_tag "application" %>`를 사용하여 Rails 애플리케이션에 추가할 수 있습니다. 이렇게 설정하면 개발 환경에서는 `application.js` 파일이 변경될 때마다 Rails가 해당 팩을 사용하는 페이지를 로드할 때마다 다시 컴파일됩니다. 일반적으로 실제 `packs` 디렉토리의 파일은 대부분 다른 파일을 로드하는 매니페스트일 수 있지만 임의의 JavaScript 코드도 포함할 수 있습니다.

Webpacker가 생성하는 기본 팩은 프로젝트에 포함된 경우 Rails의 기본 JavaScript 패키지에 연결됩니다:

```javascript
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

이러한 패키지를 사용하려면 해당 패키지를 요구하는 팩을 포함해야 합니다.

`app/javascript/packs` 디렉토리에는 웹팩 엔트리 파일만 위치해야 한다는 점을 유의해야 합니다. 웹팩은 각 엔트리 포인트에 대해 별도의 의존성 그래프를 생성하므로 많은 팩은 컴파일 오버헤드를 증가시킬 수 있습니다. 그 외의 자산 소스 코드는 이 디렉토리 외부에 있어야 하지만 Webpacker는 소스 코드를 구조화하는 방법에 대해 제한이나 권고사항을 제시하지 않습니다. 다음은 예시입니다:

```sh
app/javascript:
  ├── packs:
  │   # 여기에는 웹팩 엔트리 파일만 있어야 합니다.
  │   └── application.js
  │   └── application.css
  └── src:
  │   └── my_component.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

일반적으로 팩 파일 자체는 대부분의 경우 필요한 파일을 로드하는 매니페스트입니다.

이러한 디렉토리를 변경하려면 `config/webpacker.yml` 파일에서 `source_path` (기본값 `app/javascript`)와 `source_entry_path` (기본값 `packs`)를 조정할 수 있습니다.

소스 파일 내에서 `import` 문은 가져오는 파일을 기준으로 상대적으로 해석됩니다. 예를 들어 `import Bar from "./foo"`는 현재 파일과 동일한 디렉토리에 있는 `foo.js` 파일을 찾고, `import Bar from "../src/foo"`는 형제 디렉토리에 있는 `src`라는 이름의 디렉토리에 있는 파일을 찾습니다.

### CSS에 Webpacker 사용하기

기본적으로 Webpacker는 PostCSS 프로세서를 사용하여 CSS와 SCSS를 지원합니다.

팩에 CSS 코드를 포함하려면 먼저 CSS 파일을 최상위 팩 파일에 JavaScript 파일처럼 포함해야 합니다. 예를 들어, CSS 최상위 매니페스트가 `app/javascript/styles/styles.scss`에 있다면 `import styles/styles`로 가져올 수 있습니다. 이렇게 하면 웹팩이 CSS 파일을 다운로드에 포함하도록 지시합니다. 실제로 페이지에 로드하려면 뷰에 `<%= stylesheet_pack_tag "application" %>`를 포함하면 됩니다. 여기서 `application`은 사용하고 있는 팩 이름과 동일합니다.

CSS 프레임워크를 사용하는 경우 `yarn`을 사용하여 프레임워크를 NPM 모듈로 로드하는 지침을 따라 Webpacker에 추가할 수 있습니다. 일반적으로 `yarn add <framework>`를 사용합니다. 프레임워크를 CSS 또는 SCSS 파일로 가져오는 방법에 대한 지침은 프레임워크에서 제공해야 합니다.


### 정적 자산에 Webpacker 사용하기

기본 Webpacker [구성](https://github.com/rails/webpacker/blob/master/lib/install/config/webpacker.yml#L21)은 정적 자산에 대해 기본적으로 작동해야 합니다.
구성에는 이미지와 폰트 파일 형식 확장자가 여러 개 포함되어 있어 웹팩이 생성된 `manifest.json` 파일에 이들을 포함할 수 있습니다.

웹팩을 사용하면 정적 자산을 JavaScript 파일에서 직접 가져올 수 있습니다. 가져온 값은 자산의 URL을 나타냅니다. 예를 들어:

```javascript
import myImageUrl from '../images/my-image.jpg'

// ...
let myImage = new Image();
myImage.src = myImageUrl;
myImage.alt = "I'm a Webpacker-bundled image";
document.body.appendChild(myImage);
```

Rails 뷰에서 Webpacker 정적 자산을 참조해야 하는 경우, 자산은 Webpacker로 번들된 JavaScript 파일에서 명시적으로 요구되어야 합니다. Sprockets와 달리 Webpacker는 기본적으로 정적 자산을 가져오지 않습니다. 기본 `app/javascript/packs/application.js` 파일에는 주어진 디렉토리에서 파일을 가져오기 위한 템플릿이 포함되어 있으며, 정적 파일을 가질 디렉토리마다 해당 템플릿을 주석 해제할 수 있습니다. 디렉토리는 `app/javascript`를 기준으로 상대적입니다. 템플릿은 `images` 디렉토리를 사용하지만 `app/javascript`에서 아무 것이나 사용할 수 있습니다:

```javascript
const images = require.context("../images", true)
const imagePath = name => images(name, true)
```

정적 자산은 `public/packs/media` 디렉토리 아래에 출력됩니다. 예를 들어, `app/javascript/images/my-image.jpg`에서 가져온 이미지는 `public/packs/media/images/my-image-abcd1234.jpg`에 출력됩니다. Rails 뷰에서 이 이미지에 대한 이미지 태그를 렌더링하려면 `image_pack_tag 'media/images/my-image.jpg'`를 사용하면 됩니다.

Webpacker의 정적 자산을 사용하기 위한 ActionView 도우미는 다음 표에 따라 자산 파이프라인 도우미에 해당합니다:
|ActionView 도우미 | Webpacker 도우미 |
|------------------|------------------|
|favicon_link_tag  |favicon_pack_tag  |
|image_tag         |image_pack_tag    |

또한, 일반 도우미 `asset_pack_path`는 파일의 로컬 위치를 가져와 Rails 뷰에서 사용하기 위해 해당 파일의 Webpacker 위치를 반환합니다.

또한, `app/javascript`의 CSS 파일에서 직접 파일을 참조하여 이미지에 액세스할 수도 있습니다.

### Rails 엔진에서의 Webpacker

Webpacker 버전 6부터 Webpacker는 "엔진 인식"이 아니므로, Sprockets를 사용할 때와 같은 기능을 제공하지 않습니다.

Webpacker를 사용하는 소비자를 지원하려는 Rails 엔진의 저자는 젬 자체와 함께 frontend 자산을 NPM 패키지로 배포하고, 호스트 앱이 어떻게 통합해야 하는지 설명하는 지침(또는 설치 프로그램)을 제공하는 것이 좋습니다. 이 접근 방식의 좋은 예는 [Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms)입니다.

### 핫 모듈 교체 (HMR)

Webpacker는 기본적으로 webpack-dev-server와 함께 HMR을 지원하며, `webpacker.yml` 내의 dev_server/hmr 옵션을 설정하여 토글할 수 있습니다.

더 많은 정보는 [webpack의 DevServer 문서](https://webpack.js.org/configuration/dev-server/#devserver-hot)를 확인하세요.

React에서 HMR을 지원하려면 react-hot-loader를 추가해야 합니다. [React Hot Loader의 _시작하기_ 가이드](https://gaearon.github.io/react-hot-loader/getstarted/)를 확인하세요.

스타일시트에 대해 webpack-dev-server를 실행하지 않는 경우 HMR을 비활성화하는 것을 잊지 마세요. 그렇지 않으면 "찾을 수 없음 오류"가 발생합니다.

다른 환경에서의 Webpacker
-----------------------------------

Webpacker는 기본적으로 `development`, `test`, `production` 세 가지 환경을 가지고 있습니다. `webpacker.yml` 파일에 추가적인 환경 설정을 추가하고 각 환경에 대해 다른 기본값을 설정할 수 있습니다. Webpacker는 추가적인 환경 설정을 위해 `config/webpack/<environment>.js` 파일도 로드합니다.

## 개발 환경에서 Webpacker 실행하기

Webpacker는 개발 환경에서 실행하기 위해 두 개의 binstub 파일을 제공합니다: `./bin/webpack`과 `./bin/webpack-dev-server`. 이 둘은 표준 `webpack.js`와 `webpack-dev-server.js` 실행 파일을 감싼 얇은 래퍼로, 올바른 설정 파일과 환경 변수가 로드되도록 보장합니다.

기본적으로 Webpacker는 Rails 페이지가 로드될 때 개발 환경에서 필요에 따라 자동으로 컴파일됩니다. 이는 별도의 프로세스를 실행할 필요가 없으며, 컴파일 오류는 표준 Rails 로그에 기록됩니다. 이를 `config/webpacker.yml` 파일에서 `compile: false`로 변경하여 변경할 수 있습니다. `bin/webpack`을 실행하면 팩을 강제로 컴파일합니다.

실시간 코드 리로딩을 사용하거나 필요한 만큼의 JavaScript가 있는 경우, `./bin/webpack-dev-server` 또는 `ruby ./bin/webpack-dev-server`를 실행해야 합니다. 이 프로세스는 `app/javascript/packs/*.js` 파일의 변경 사항을 감지하고 자동으로 다시 컴파일하고 브라우저를 다시 로드합니다.

Windows 사용자는 이러한 명령을 `bundle exec rails server`와 별도의 터미널에서 실행해야 합니다.

이 개발 서버를 시작하면 Webpacker는 자동으로 모든 webpack 자산 요청을 이 서버로 프록시합니다. 서버를 중지하면 요구에 따라 컴파일됩니다.

[Webpacker 문서](https://github.com/rails/webpacker)에서 `webpack-dev-server`를 제어하는 데 사용할 수 있는 환경 변수에 대한 정보를 제공합니다. [rails/webpacker 문서의 webpack-dev-server 사용법](https://github.com/rails/webpacker#development)에서 추가적인 참고 사항을 확인하세요.

### Webpacker 배포하기

Webpacker는 `bin/rails assets:precompile` 작업에 `webpacker:compile` 작업을 추가하므로, `assets:precompile`을 사용하던 기존 배포 파이프라인은 작동해야 합니다. 컴파일 작업은 팩을 컴파일하고 `public/packs`에 배치합니다.

추가 문서
------------------------

Webpacker를 인기 있는 프레임워크와 함께 사용하는 등 고급 주제에 대한 자세한 정보는 [Webpacker 문서](https://github.com/rails/webpacker)를 참조하세요.
