**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2cf37358fedc8b51ed3ab7f408ecfc76
레일즈 시작하기
=================

이 가이드는 루비 온 레일즈를 시작하는 방법을 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* 레일즈를 설치하고 새로운 레일즈 애플리케이션을 생성하고 데이터베이스에 연결하는 방법.
* 레일즈 애플리케이션의 일반적인 레이아웃.
* MVC (모델, 뷰, 컨트롤러)와 RESTful 디자인의 기본 원칙.
* 레일즈 애플리케이션의 시작 부분을 빠르게 생성하는 방법.

--------------------------------------------------------------------------------

가이드 전제 조건
-----------------

이 가이드는 루비 온 레일즈를 처음 시작하는 사람들을 대상으로 설계되었습니다. 레일즈에 대한 사전 지식이 없다고 가정하고 있지 않습니다.

레일즈는 루비 프로그래밍 언어에서 실행되는 웹 애플리케이션 프레임워크입니다. 루비에 대한 사전 지식이 없는 경우, 레일즈에 바로 뛰어들면 매우 가파른 학습 곡선을 경험할 것입니다. 루비 학습을 위한 온라인 자료의 목록이 여러 개 있습니다:

* [공식 루비 프로그래밍 언어 웹사이트](https://www.ruby-lang.org/en/documentation/)
* [무료 프로그래밍 도서 목록](https://github.com/EbookFoundation/free-programming-books/blob/master/books/free-programming-books-langs.md#ruby)

일부 자료는 여전히 훌륭하지만, 오래된 루비 버전을 다루고 있을 수 있으며, 레일즈 개발에서 일상적으로 볼 수 있는 몇 가지 구문을 포함하지 않을 수도 있습니다.

레일즈란 무엇인가?
------------------

레일즈는 루비 프로그래밍 언어로 작성된 웹 애플리케이션 개발 프레임워크입니다. 모든 개발자가 시작하기 위해 필요한 것에 대한 가정을 통해 프로그래밍 웹 애플리케이션을 더 쉽게 만들기 위해 설계되었습니다. 다른 언어와 프레임워크보다 더 적은 코드를 작성하면서 더 많은 작업을 수행할 수 있습니다. 경험 많은 레일즈 개발자들은 또한 웹 애플리케이션 개발을 더 재미있게 만든다고 보고합니다.

레일즈는 의견이 강한 소프트웨어입니다. 레일즈는 일을 수행하는 "최선" 방법이 있다고 가정하고, 이 방법을 장려하고 때로는 대안을 비난하기 위해 설계되었습니다. "레일즈의 방식"을 배우면 생산성이 크게 향상될 것입니다. 다른 언어에서 옛 습관을 가져와서 레일즈 개발에 적용하려고 하거나 다른 곳에서 배운 패턴을 사용하려고 계속하면 덜 만족스러운 경험을 할 수 있습니다.

레일즈 철학에는 두 가지 주요 원칙이 포함되어 있습니다:

* **중복하지 마세요(Don't Repeat Yourself, DRY):** DRY는 소프트웨어 개발의 원칙으로, "시스템 내에서 모든 지식 조각은 단일하고 모호하지 않은 권위있는 표현을 가져야 한다"고 말합니다. 동일한 정보를 반복해서 작성하지 않으면, 코드가 유지보수 가능하고 확장 가능하며 버그가 덜 발생합니다.
* **구성보다 관례(Convention Over Configuration):** 레일즈는 웹 애플리케이션에서 많은 작업을 수행하는 가장 좋은 방법에 대한 의견을 가지고 있으며, 이러한 관례를 기본값으로 사용하도록 설계되었습니다. 끝없는 구성 파일을 통해 세부 사항을 지정해야 하는 대신 레일즈는 이러한 관례를 기본값으로 사용합니다.

새로운 레일즈 프로젝트 생성하기
-------------------------------

이 가이드를 읽는 가장 좋은 방법은 단계별로 따라가는 것입니다. 이 예제 애플리케이션을 실행하기 위해서는 모든 단계가 필수이며 추가적인 코드나 단계는 필요하지 않습니다.

이 가이드를 따라하면 `blog`라는 레일즈 프로젝트, 매우 간단한 블로그를 생성할 것입니다. 애플리케이션을 구축하기 전에 레일즈가 설치되어 있는지 확인해야 합니다.

참고: 아래 예제는 UNIX와 유사한 운영 체제에서 터미널 프롬프트를 나타내기 위해 `$`를 사용하고 있습니다. Windows를 사용하는 경우 프롬프트는 `C:\source_code>`와 같이 보일 것입니다.

### 레일즈 설치하기

레일즈를 설치하기 전에 시스템에 필요한 사전 준비 조건이 설치되어 있는지 확인해야 합니다. 이에는 다음이 포함됩니다:

* 루비
* SQLite3

#### 루비 설치하기

명령 줄 프롬프트를 엽니다. macOS에서는 Terminal.app을 열고, Windows에서는 시작 메뉴에서 "실행"을 선택하고 `cmd.exe`를 입력합니다. 달러 기호 `$`로 시작하는 명령은 명령 줄에서 실행되어야 합니다. 현재 버전의 루비가 설치되어 있는지 확인합니다:

```bash
$ ruby --version
ruby 2.7.0
```

레일즈는 루비 버전 2.7.0 이상을 필요로 합니다. 최신 루비 버전을 사용하는 것이 좋습니다. 반환된 버전 번호가 해당 번호보다 작은 경우(예: 2.3.7 또는 1.8.7), 새로운 루비 사본을 설치해야 합니다.

Windows에서 레일즈를 설치하려면 먼저 [루비 인스톨러](https://rubyinstaller.org/)를 설치해야 합니다.

대부분의 운영 체제에 대한 더 많은 설치 방법은 [ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/)을 참조하십시오.

#### SQLite3 설치하기

SQLite3 데이터베이스의 설치도 필요합니다. 많은 인기있는 UNIX와 유사한 운영 체제에는 적절한 버전의 SQLite3가 함께 제공됩니다. 다른 운영 체제에서는 [SQLite3 웹사이트](https://www.sqlite.org)에서 설치 지침을 찾을 수 있습니다.
설치가 올바르게 되었는지 확인하고 로드 `PATH`에 있는지 확인하십시오:

```bash
$ sqlite3 --version
```

프로그램은 버전을 보고해야합니다.

#### Rails 설치

Rails를 설치하려면 RubyGems에서 제공하는 `gem install` 명령을 사용하십시오:

```bash
$ gem install rails
```

모든 것이 올바르게 설치되었는지 확인하려면 새 터미널에서 다음을 실행할 수 있어야합니다:

```bash
$ rails --version
```

"Rails 7.0.0"과 같은 내용이 표시되면 계속 진행할 준비가되었습니다.

### 블로그 애플리케이션 생성

Rails에는 개발 작업을 시작하기 위해 필요한 모든 것을 생성하여 개발 생활을 더 쉽게하는 일련의 스크립트인 생성기가 있습니다. 이 중 하나는 새로운 애플리케이션 생성기입니다. 이 생성기는 새로운 Rails 애플리케이션의 기반을 제공하여 직접 작성하지 않아도되도록합니다.

이 생성기를 사용하려면 터미널을 열고 파일을 생성할 수있는 디렉토리로 이동 한 다음 다음을 실행하십시오:

```bash
$ rails new blog
```

이렇게하면 `blog` 디렉토리에 Blog라는 Rails 애플리케이션이 생성되고 `Gemfile`에 이미 언급 된 gem 종속성이 `bundle install`을 사용하여 설치됩니다.

TIP: Rails 애플리케이션 생성기가 허용하는 모든 명령 줄 옵션을 보려면 `rails new --help`를 실행하십시오.

블로그 애플리케이션을 생성 한 후 해당 폴더로 전환하십시오:

```bash
$ cd blog
```

`blog` 디렉토리에는 Rails 애플리케이션의 구조를 구성하는 생성 된 파일 및 폴더가 여러 개 있습니다. 이 튜토리얼에서 대부분의 작업은 `app` 폴더에서 수행되지만 Rails가 기본적으로 생성하는 각 파일 및 폴더의 기능에 대한 기본적인 설명은 다음과 같습니다.

| 파일/폴더 | 목적 |
| ----------- | ------- |
|app/|애플리케이션의 컨트롤러, 모델, 뷰, 헬퍼, 메일러, 채널, 작업 및 자산을 포함합니다. 이 가이드의 나머지 부분에서이 폴더에 중점을 둘 것입니다.|
|bin/|앱을 시작하는 `rails` 스크립트가 포함되어 있으며 앱을 설정, 업데이트, 배포 또는 실행하는 데 사용되는 다른 스크립트를 포함 할 수 있습니다.|
|config/|애플리케이션의 라우트, 데이터베이스 등에 대한 구성이 포함되어 있습니다. 이에 대한 자세한 내용은 [Rails 애플리케이션 구성](configuring.html)을 참조하십시오.|
|config.ru|애플리케이션을 시작하는 데 사용되는 Rack 기반 서버의 Rack 구성입니다. Rack에 대한 자세한 내용은 [Rack 웹 사이트](https://rack.github.io/)를 참조하십시오.|
|db/|현재 데이터베이스 스키마와 데이터베이스 마이그레이션을 포함합니다.|
|Gemfile<br>Gemfile.lock|이 파일을 사용하여 Rails 애플리케이션에 필요한 gem 종속성을 지정할 수 있습니다. 이 파일은 Bundler gem에 의해 사용됩니다. Bundler에 대한 자세한 내용은 [Bundler 웹 사이트](https://bundler.io)를 참조하십시오.|
|lib/|애플리케이션의 확장 모듈입니다.|
|log/|애플리케이션 로그 파일입니다.|
|public/|정적 파일 및 컴파일 된 자산이 포함되어 있습니다. 앱이 실행되면이 디렉토리가 그대로 노출됩니다.|
|Rakefile|명령 줄에서 실행할 수있는 작업을 찾아로드하는 파일입니다. 작업 정의는 Rails의 구성 요소 전체에 정의됩니다. `Rakefile`을 변경하는 대신 애플리케이션의 `lib/tasks` 디렉토리에 파일을 추가하여 작업을 추가해야합니다.|
|README.md|애플리케이션에 대한 간단한 사용 설명서입니다. 이 파일을 편집하여 애플리케이션이 무엇을하는지, 설정하는 방법 등을 다른 사람들에게 알려야합니다.|
|storage/|디스크 서비스에 대한 Active Storage 파일입니다. [Active Storage 개요](active_storage_overview.html)에서 다룹니다.|
|test/|단위 테스트, 픽스처 및 기타 테스트 장치입니다. [Rails 애플리케이션 테스트](testing.html)에서 다룹니다.|
|tmp/|캐시 및 pid 파일과 같은 임시 파일입니다.|
|vendor/|모든 타사 코드를위한 장소입니다. 일반적인 Rails 애플리케이션에는 vendored gem이 포함됩니다.|
|.gitattributes|이 파일은 git 저장소의 특정 경로에 대한 메타 데이터를 정의합니다. 이 메타 데이터는 git 및 기타 도구에서 동작을 향상시키기 위해 사용될 수 있습니다. 자세한 내용은 [gitattributes 문서](https://git-scm.com/docs/gitattributes)를 참조하십시오.|
|.gitignore|이 파일은 git이 무시해야하는 파일 (또는 패턴)을 지정합니다. 파일을 무시하는 방법에 대한 자세한 내용은 [GitHub - 파일 무시](https://help.github.com/articles/ignoring-files)를 참조하십시오.|
|.ruby-version|이 파일에는 기본 Ruby 버전이 포함되어 있습니다.

안녕, Rails!
-------------

먼저 화면에 텍스트를 표시해 봅시다. 이를 위해 Rails 애플리케이션 서버를 실행해야합니다.

### 웹 서버 시작

실제로 이미 기능이있는 Rails 애플리케이션이 있습니다. 이를 보려면 개발 컴퓨터에서 웹 서버를 시작해야합니다. 이를 위해 `blog` 디렉토리에서 다음 명령을 실행하면됩니다:

```bash
$ bin/rails server
```
팁: Windows를 사용하는 경우, 스크립트를 직접 `bin` 폴더 아래의 Ruby 인터프리터에 전달해야 합니다. 예: `ruby bin\rails server`.

팁: JavaScript 자산 압축은 시스템에 JavaScript 런타임이 있어야 합니다. 런타임이 없으면 자산 압축 중에 `execjs` 오류가 발생합니다. 일반적으로 macOS와 Windows에는 JavaScript 런타임이 설치되어 있습니다. `therubyrhino`는 JRuby 사용자에게 권장되는 런타임이며, JRuby로 생성된 앱의 `Gemfile`에 기본으로 추가됩니다. 지원되는 모든 런타임은 [ExecJS](https://github.com/rails/execjs#readme)에서 확인할 수 있습니다.

이렇게 하면 기본적으로 Rails와 함께 제공되는 웹 서버인 Puma가 시작됩니다. 애플리케이션을 확인하려면 브라우저 창을 열고 <http://localhost:3000>으로 이동하면 됩니다. Rails의 기본 정보 페이지가 표시됩니다:

![Rails 시작 페이지 스크린샷](images/getting_started/rails_welcome.png)

웹 서버를 중지하려면 실행 중인 터미널 창에서 Ctrl+C를 누르세요. 개발 환경에서는 파일에서 변경 사항이 자동으로 서버에 반영되므로 일반적으로 서버를 다시 시작할 필요가 없습니다.

Rails 시작 페이지는 새로운 Rails 애플리케이션의 _스모크 테스트_입니다. 이 페이지는 소프트웨어가 페이지를 제공할 수 있도록 올바르게 구성되어 있는지 확인합니다.

### "Hello", Rails라고 말하기

Rails가 "Hello"라고 말하려면 *route*, *controller* 및 *view*를 최소한으로 생성해야 합니다. route는 요청을 controller action에 매핑합니다. controller action은 요청을 처리하기 위해 필요한 작업을 수행하고 view에 대한 데이터를 준비합니다. view는 원하는 형식으로 데이터를 표시합니다.

구현 관점에서 route는 Ruby [DSL(Domain-Specific Language)](https://en.wikipedia.org/wiki/Domain-specific_language)로 작성된 규칙입니다. controller는 Ruby 클래스이며, public 메서드는 action입니다. view는 일반적으로 HTML과 Ruby의 혼합으로 작성된 템플릿입니다.

먼저 `config/routes.rb` 파일의 `Rails.application.routes.draw` 블록 맨 위에 route를 추가해 보겠습니다:

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
```

위의 route는 `GET /articles` 요청을 `ArticlesController`의 `index` action에 매핑합니다.

`ArticlesController`와 `index` action을 생성하려면, 이미 적절한 route가 있으므로 controller generator를 실행합니다(`--skip-routes` 옵션을 사용합니다):

```bash
$ bin/rails generate controller Articles index --skip-routes
```

Rails가 여러 파일을 생성합니다:

```
create  app/controllers/articles_controller.rb
invoke  erb
create    app/views/articles
create    app/views/articles/index.html.erb
invoke  test_unit
create    test/controllers/articles_controller_test.rb
invoke  helper
create    app/helpers/articles_helper.rb
invoke    test_unit
```

이 중 가장 중요한 파일은 controller 파일인 `app/controllers/articles_controller.rb`입니다. 이 파일을 살펴보겠습니다:

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```

`index` action은 비어 있습니다. action이 명시적으로 view를 렌더링하지 않거나 HTTP 응답을 트리거하지 않는 경우, Rails는 자동으로 controller와 action의 이름과 일치하는 view를 렌더링합니다. Convention Over Configuration! view는 `app/views` 디렉토리에 있습니다. 따라서 `index` action은 기본적으로 `app/views/articles/index.html.erb`를 렌더링합니다.

`app/views/articles/index.html.erb`를 열고, 내용을 다음과 같이 바꿉니다:

```html
<h1>Hello, Rails!</h1>
```

웹 서버를 중지하고 컨트롤러 생성기를 실행했다면, `bin/rails server`로 다시 시작하세요. 이제 <http://localhost:3000/articles>를 방문하면 텍스트가 표시됩니다!

### 애플리케이션 홈 페이지 설정

현재 <http://localhost:3000>은 여전히 Ruby on Rails 로고가 있는 페이지가 표시됩니다. 이제 "Hello, Rails!" 텍스트도 <http://localhost:3000>에 표시하겠습니다. 이를 위해 애플리케이션의 *루트 경로*를 적절한 controller와 action에 매핑하는 route를 추가하겠습니다.

`config/routes.rb`를 열고, 다음 `root` route를 `Rails.application.routes.draw` 블록 맨 위에 추가합니다:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

이제 <http://localhost:3000>을 방문하면 "Hello, Rails!" 텍스트가 표시되어 `root` route가 `ArticlesController`의 `index` action에도 매핑되는 것을 확인할 수 있습니다.

팁: 라우팅에 대해 더 알아보려면 [Rails Routing from the Outside In](routing.html)을 참조하세요.

자동로딩
-----------

Rails 애플리케이션은 애플리케이션 코드를 로드하기 위해 `require`를 사용하지 **않습니다**.

`ArticlesController`가 `ApplicationController`를 상속받는 것을 알 수 있을 것입니다. 그러나 `app/controllers/articles_controller.rb`에는 다음과 같은 내용이 없습니다.

```ruby
require "application_controller" # 이렇게 하지 마세요.
```

Application 클래스와 모듈은 어디에서나 사용할 수 있으며, `app` 아래의 어떤 것도 `require`로 로드할 필요가 없습니다. 이 기능은 _자동로딩_이라고 하며, [_Autoloading and Reloading Constants_](autoloading_and_reloading_constants.html)에서 자세히 알아볼 수 있습니다.
두 가지 사용 사례에 대해서만 `require` 호출이 필요합니다:

* `lib` 디렉토리 아래의 파일을 로드하기 위해.
* `Gemfile`에서 `require: false`를 가진 젬 종속성을 로드하기 위해.

MVC와 당신
-----------

지금까지 우리는 라우트, 컨트롤러, 액션, 뷰에 대해 이야기했습니다. 이 모든 것들은 [MVC (Model-View-Controller)](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) 패턴을 따르는 웹 애플리케이션의 전형적인 구성 요소입니다. MVC는 응용 프로그램의 책임을 분할하여 이해하기 쉽게 만드는 디자인 패턴입니다. Rails는 이 디자인 패턴을 규칙으로 따릅니다.

컨트롤러와 뷰가 있으므로 다음 조각을 생성해 봅시다: 모델.

### 모델 생성

*모델*은 데이터를 나타내는 데 사용되는 루비 클래스입니다. 또한 모델은 Rails의 *Active Record*라는 기능을 통해 응용 프로그램의 데이터베이스와 상호 작용할 수 있습니다.

모델을 정의하기 위해 모델 생성기를 사용할 것입니다:

```bash
$ bin/rails generate model Article title:string body:text
```

참고: 모델 이름은 **단수형**입니다. 왜냐하면 인스턴스화된 모델은 단일 데이터 레코드를 나타냅니다. 이 규칙을 기억하는 데 도움이 되도록 모델의 생성자를 호출하는 방법을 생각해보세요: `Article.new(...)`를 작성하려고 합니다. **하지만** `Articles.new(...)`를 작성하려고 하지 않습니다.

이렇게 하면 여러 파일이 생성됩니다:

```
invoke  active_record
create    db/migrate/<timestamp>_create_articles.rb
create    app/models/article.rb
invoke    test_unit
create      test/models/article_test.rb
create      test/fixtures/articles.yml
```

우리가 집중할 두 개의 파일은 마이그레이션 파일 (`db/migrate/<timestamp>_create_articles.rb`)과 모델 파일 (`app/models/article.rb`)입니다.

### 데이터베이스 마이그레이션

*마이그레이션*은 응용 프로그램의 데이터베이스 구조를 변경하는 데 사용됩니다. Rails 애플리케이션에서 마이그레이션은 데이터베이스에 독립적으로 작성되기 때문에 루비로 작성됩니다.

새로운 마이그레이션 파일의 내용을 살펴보겠습니다:

```ruby
class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

`create_table` 호출은 `articles` 테이블이 어떻게 구성되어야 하는지를 지정합니다. 기본적으로 `create_table` 메서드는 자동으로 증가하는 기본 키로 `id` 열을 추가합니다. 따라서 테이블의 첫 번째 레코드는 `id`가 1이고, 다음 레코드는 `id`가 2이며, 이런 식으로 됩니다.

`create_table` 블록 내에서 `title`과 `body` 두 개의 열이 정의되었습니다. 이들은 우리가 생성 명령에 포함했기 때문에 생성기에 의해 추가되었습니다 (`bin/rails generate model Article title:string body:text`).

블록의 마지막 줄에는 `t.timestamps` 호출이 있습니다. 이 메서드는 `created_at`과 `updated_at`이라는 두 개의 추가 열을 정의합니다. 우리가 보게 될 것처럼, Rails는 이를 관리하여 모델 객체를 생성하거나 업데이트할 때 값을 설정합니다.

다음 명령을 사용하여 마이그레이션을 실행해 봅시다:

```bash
$ bin/rails db:migrate
```

명령은 테이블이 생성되었음을 나타내는 출력을 표시합니다:

```
==  CreateArticles: migrating ===================================
-- create_table(:articles)
   -> 0.0018s
==  CreateArticles: migrated (0.0018s) ==========================
```

팁: 마이그레이션에 대해 더 알아보려면 [Active Record 마이그레이션](
active_record_migrations.html)을 참조하세요.

이제 모델을 사용하여 테이블과 상호 작용할 수 있습니다.

### 데이터베이스와 상호 작용하기 위해 모델 사용

모델을 조금 사용해 보기 위해 Rails의 *콘솔*이라는 기능을 사용할 것입니다. 콘솔은 `irb`와 같은 대화형 코딩 환경이지만 Rails와 우리의 애플리케이션 코드를 자동으로 로드합니다.

다음 명령으로 콘솔을 실행해 봅시다:

```bash
$ bin/rails console
```

다음과 같은 `irb` 프롬프트가 표시됩니다:

```irb
Loading development environment (Rails 7.0.0)
irb(main):001:0>
```

이 프롬프트에서 새로운 `Article` 객체를 초기화할 수 있습니다:

```irb
irb> article = Article.new(title: "Hello Rails", body: "I am on Rails!")
```

이 객체는 *초기화*된 것에 주목해야 합니다. 이 객체는 전혀 데이터베이스에 저장되지 않았습니다. 현재 콘솔에서만 사용할 수 있습니다. 객체를 데이터베이스에 저장하려면 [`save`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save)를 호출해야 합니다:

```irb
irb> article.save
(0.1ms)  begin transaction
Article Create (0.4ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "Hello Rails"], ["body", "I am on Rails!"], ["created_at", "2020-01-18 23:47:30.734416"], ["updated_at", "2020-01-18 23:47:30.734416"]]
(0.9ms)  commit transaction
=> true
```

위의 출력은 `INSERT INTO "articles" ...` 데이터베이스 쿼리를 보여줍니다. 이는 해당 article이 테이블에 삽입되었음을 나타냅니다. 그리고 `article` 객체를 다시 살펴보면 흥미로운 일이 발생한 것을 볼 수 있습니다:

```irb
irb> article
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```
객체의 `id`, `created_at`, `updated_at` 속성이 설정되었습니다.
우리가 객체를 저장할 때 Rails가 이 작업을 대신해주었습니다.

데이터베이스에서 이 글을 가져오려면 모델에서 [`find`](
https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find)
를 호출하고 `id`를 인수로 전달할 수 있습니다:

```irb
irb> Article.find(1)
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

데이터베이스에서 모든 글을 가져오려면 모델에서 [`all`](
https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all)
을 호출할 수 있습니다:

```irb
irb> Article.all
=> #<ActiveRecord::Relation [#<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">]>
```

이 메서드는 [`ActiveRecord::Relation`](
https://api.rubyonrails.org/classes/ActiveRecord/Relation.html) 객체를 반환하며,
이는 슈퍼파워를 가진 배열로 생각할 수 있습니다.

팁: 모델에 대해 더 알아보려면 [Active Record Basics](
active_record_basics.html)와 [Active Record Query Interface](
active_record_querying.html)를 참조하세요.

모델은 MVC 퍼즐의 마지막 조각입니다. 다음으로, 모든 조각을 연결해보겠습니다.

### 글 목록 표시하기

`app/controllers/articles_controller.rb`의 컨트롤러로 돌아가서
`index` 액션을 데이터베이스에서 모든 글을 가져오도록 변경해보겠습니다:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

컨트롤러 인스턴스 변수는 뷰에서 접근할 수 있습니다. 즉, `app/views/articles/index.html.erb`에서
`@articles`를 참조할 수 있습니다. 해당 파일을 열고, 다음 내용으로 대체해보세요:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

위 코드는 HTML과 *ERB*의 혼합입니다. ERB는 문서에 포함된 Ruby 코드를 평가하는 템플릿 시스템입니다.
여기에서는 `<% %>`와 `<%= %>` 두 가지 유형의 ERB 태그를 볼 수 있습니다. `<% %>` 태그는 "평가된 Ruby 코드를 실행하세요"를 의미합니다.
`<%= %>` 태그는 "평가된 Ruby 코드를 실행하고, 그 결과 값을 출력하세요"를 의미합니다. 일반적인 Ruby 프로그램에서 작성할 수 있는 것은
이 ERB 태그 안에 넣을 수 있지만, 가독성을 위해 ERB 태그의 내용을 짧게 유지하는 것이 좋습니다.

`@articles.each`의 반환 값을 출력하고 싶지 않으므로, 해당 코드를 `<% %>`로 감쌌습니다.
하지만, 각 글의 `article.title`의 반환 값을 출력하고 싶으므로, 해당 코드를 `<%= %>`로 감쌌습니다.

<http://localhost:3000>을 방문하여 최종 결과를 확인할 수 있습니다. (반드시 `bin/rails server`가 실행 중이어야 합니다!) 다음은 이 과정에서 발생하는 일입니다:

1. 브라우저가 요청을 보냅니다: `GET http://localhost:3000`.
2. Rails 애플리케이션이 이 요청을 받습니다.
3. Rails 라우터가 루트 경로를 `ArticlesController`의 `index` 액션에 매핑합니다.
4. `index` 액션은 `Article` 모델을 사용하여 데이터베이스에서 모든 글을 가져옵니다.
5. Rails는 자동으로 `app/views/articles/index.html.erb` 뷰를 렌더링합니다.
6. 뷰에서의 ERB 코드가 HTML로 평가됩니다.
7. 서버는 HTML을 포함한 응답을 브라우저로 보냅니다.

MVC 조각을 모두 연결하고, 첫 번째 컨트롤러 액션을 가지게 되었습니다! 다음으로, 두 번째 액션으로 넘어갑니다.

CRUDit Where CRUDit Is Due
--------------------------

거의 모든 웹 애플리케이션은 [CRUD (Create, Read, Update, and Delete)](
https://en.wikipedia.org/wiki/Create,_read,_update,_and_delete) 작업을 포함합니다.
심지어 애플리케이션의 대부분의 작업이 CRUD일 수도 있습니다. Rails는 이를 인식하고, CRUD 작업을 간소화하기 위한 많은 기능을 제공합니다.

이러한 기능을 탐색하기 위해 애플리케이션에 더 많은 기능을 추가해보겠습니다.

### 단일 글 표시하기

현재 데이터베이스에서 모든 글을 나열하는 뷰가 있습니다. 이제 제목과 내용을 보여주는 새로운 뷰를 추가해보겠습니다.

먼저, 새로운 라우트를 추가하여 새로운 컨트롤러 액션에 매핑합니다 (다음에 추가할 것입니다). `config/routes.rb`를 열고, 마지막에 표시된 마지막 라우트를 삽입하세요:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

새로운 라우트는 또 다른 `get` 라우트이지만, 경로에 추가적인 것이 있습니다: `:id`. 이는 라우트 *매개변수*를 나타냅니다.
라우트 매개변수는 요청의 경로 일부를 캡처하고, 해당 값을 컨트롤러 액션에서 접근할 수 있는 `params` 해시에 넣습니다.
예를 들어, `GET http://localhost:3000/articles/1`과 같은 요청을 처리할 때, `1`은 `:id`의 값으로 캡처되며,
`ArticlesController`의 `show` 액션에서 `params[:id]`로 접근할 수 있습니다.
이제 `index` 액션 아래에 `show` 액션을 `app/controllers/articles_controller.rb`에 추가합시다:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

`show` 액션은 라우트 매개변수로 캡처된 ID를 사용하여 `Article.find`를 호출합니다([이전에 언급한 바와 같음](#using-a-model-to-interact-with-the-database)). 반환된 article은 `@article` 인스턴스 변수에 저장되므로 뷰에서 접근할 수 있습니다. 기본적으로 `show` 액션은 `app/views/articles/show.html.erb`를 렌더링합니다.

다음 내용으로 `app/views/articles/show.html.erb`를 생성합시다:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

이제 <http://localhost:3000/articles/1>을 방문하면 해당 article을 볼 수 있습니다!

마무리로, article의 페이지로 이동할 수 있는 편리한 방법을 추가해봅시다. `app/views/articles/index.html.erb`에서 각 article의 제목을 해당 페이지로 링크하겠습니다:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

### Resourceful Routing

지금까지 CRUD의 "R"(Read)에 대해 다루었습니다. 이후에는 "C"(Create), "U"(Update), "D"(Delete)를 다룰 예정입니다. 이러한 조합의 라우트, 컨트롤러 액션 및 뷰가 함께 작동하여 엔티티에 대한 CRUD 작업을 수행하는 경우, 해당 엔티티를 *리소스*(resource)라고 합니다. 예를 들어, 우리의 애플리케이션에서는 article이 리소스라고 할 수 있습니다.

Rails는 [`resources`](
https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources)라는 라우트 메서드를 제공합니다. 이 메서드는 컬렉션의 리소스(예: articles)에 대한 모든 관례적인 라우트를 매핑합니다. 따라서 "C", "U", "D" 섹션으로 진행하기 전에 `config/routes.rb`에 있는 두 개의 `get` 라우트를 `resources`로 대체합시다:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

`bin/rails routes` 명령을 실행하여 매핑된 라우트를 확인할 수 있습니다:

```bash
$ bin/rails routes
      Prefix Verb   URI Pattern                  Controller#Action
        root GET    /                            articles#index
    articles GET    /articles(.:format)          articles#index
 new_article GET    /articles/new(.:format)      articles#new
     article GET    /articles/:id(.:format)      articles#show
             POST   /articles(.:format)          articles#create
edit_article GET    /articles/:id/edit(.:format) articles#edit
             PATCH  /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
```

`resources` 메서드는 리소스를 경로와 URL 헬퍼 메서드로 설정합니다. "Prefix" 열의 값과 `_url` 또는 `_path` 접미사는 이러한 헬퍼의 이름을 형성합니다. 예를 들어, 위의 `article_path` 헬퍼는 article이 주어졌을 때 `"/articles/#{article.id}"`를 반환합니다. 이를 사용하여 `app/views/articles/index.html.erb`의 링크를 정리할 수 있습니다:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

그러나 [`link_to`](
https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to) 헬퍼를 사용하여 더 나아가겠습니다. `link_to` 헬퍼는 첫 번째 인수를 링크의 텍스트로, 두 번째 인수를 링크의 대상으로 사용하여 링크를 렌더링합니다. 두 번째 인수로 모델 객체를 전달하면 `link_to`는 객체를 경로로 변환하기 위해 적절한 경로 헬퍼를 호출합니다. 예를 들어, article을 전달하면 `link_to`는 `article_path`를 호출합니다. 따라서 `app/views/articles/index.html.erb`는 다음과 같이 변경됩니다:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

좋습니다!

팁: 라우팅에 대해 자세히 알아보려면 [Rails Routing from the Outside In](routing.html)을 참조하세요.

### 새로운 Article 생성

이제 CRUD의 "C"(Create)로 넘어갑니다. 일반적으로 웹 애플리케이션에서 새로운 리소스를 생성하는 것은 여러 단계의 프로세스입니다. 먼저, 사용자는 작성할 폼을 요청합니다. 그런 다음, 사용자는 폼을 제출합니다. 오류가 없으면 리소스가 생성되고 어떤 종류의 확인 메시지가 표시됩니다. 그렇지 않으면 폼이 오류 메시지와 함께 다시 표시되고, 프로세스가 반복됩니다.

Rails 애플리케이션에서는 이러한 단계를 일반적으로 컨트롤러의 `new` 및 `create` 액션으로 처리합니다. `show` 액션 아래에 이러한 액션들의 일반적인 구현을 `app/controllers/articles_controller.rb`에 추가합시다:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

`new` 액션은 새로운 article을 인스턴스화하지만 저장하지는 않습니다. 이 article은 폼을 구성할 때 뷰에서 사용됩니다. 기본적으로 `new` 액션은 `app/views/articles/new.html.erb`를 렌더링합니다. 이제 해당 파일을 생성합니다.
`create` 액션은 제목과 내용의 값을 가진 새로운 기사를 생성하고 저장을 시도합니다. 기사가 성공적으로 저장되면, 액션은 브라우저를 기사의 페이지인 `"http://localhost:3000/articles/#{@article.id}"`로 리디렉션합니다.
그렇지 않으면, 액션은 `app/views/articles/new.html.erb`를 렌더링하여 폼을 다시 표시하고 [422 Unprocessable Entity](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/422) 상태 코드로 반환합니다.
여기서 제목과 내용은 더미 값입니다. 폼을 생성한 후에는 이를 변경할 것입니다.

참고: [`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to)는 브라우저가 새 요청을 만들도록 하지만, [`render`](https://api.rubyonrails.org/classes/AbstractController/Rendering.html#method-i-render)는 현재 요청에 대해 지정된 뷰를 렌더링합니다.
데이터베이스나 애플리케이션 상태를 변경한 후에는 `redirect_to`를 사용하는 것이 중요합니다.
그렇지 않으면 사용자가 페이지를 새로 고침하면 브라우저가 동일한 요청을 보내고 변경이 반복됩니다.

#### 폼 빌더 사용하기

우리는 Rails의 *폼 빌더*라는 기능을 사용하여 폼을 생성할 것입니다. 폼 빌더를 사용하면 최소한의 코드로 구성된 폼을 출력할 수 있으며 Rails 규칙을 따릅니다.

다음 내용으로 `app/views/articles/new.html.erb`를 생성해 봅시다:

```html+erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

[`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with) 도우미 메서드는 폼 빌더를 인스턴스화합니다. `form_with` 블록에서는
폼 빌더의 [`label`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-label) 및 [`text_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_field)와 같은 메서드를 호출하여 적절한 폼 요소를 출력합니다.

`form_with` 호출의 결과 출력은 다음과 같을 것입니다:

```html
<form action="/articles" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="...">

  <div>
    <label for="article_title">Title</label><br>
    <input type="text" name="article[title]" id="article_title">
  </div>

  <div>
    <label for="article_body">Body</label><br>
    <textarea name="article[body]" id="article_body"></textarea>
  </div>

  <div>
    <input type="submit" name="commit" value="Create Article" data-disable-with="Create Article">
  </div>
</form>
```

팁: 폼 빌더에 대해 자세히 알아보려면 [Action View Form Helpers](form_helpers.html)를 참조하세요.

#### 강력한 매개변수 사용하기

제출된 폼 데이터는 캡처된 라우트 매개변수와 함께 `params` 해시에 넣어집니다. 따라서 `create` 액션은 `params[:article][:title]`을 통해 제출된 제목에 접근하고 `params[:article][:body]`를 통해 제출된 내용에 접근할 수 있습니다.
이 값을 개별적으로 `Article.new`에 전달할 수도 있지만, 이는 장황하고 오류가 발생할 수 있습니다. 또한 필드를 추가할수록 더 나빠질 것입니다.

대신, 값이 포함된 단일 해시를 전달할 것입니다. 그러나 여전히 해당 해시에서 허용되는 값이 무엇인지 지정해야 합니다. 그렇지 않으면 악의적인 사용자가 추가 폼 필드를 제출하고 개인 데이터를 덮어쓸 수 있습니다. 실제로, 필터되지 않은 `params[:article]` 해시를 직접 `Article.new`에 전달하면 Rails가 `ForbiddenAttributesError`를 발생시켜 문제에 대해 경고합니다.
따라서 `params`를 필터링하기 위해 Rails의 *강력한 매개변수*라는 기능을 사용할 것입니다. `params`에 대해 [강력한 형식](https://en.wikipedia.org/wiki/Strong_and_weak_typing)으로 생각할 수 있습니다.

`app/controllers/articles_controller.rb`의 맨 아래에 `article_params`라는 이름의 비공개 메서드를 추가하고 `create`에서 이를 사용하도록 변경해 봅시다:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

팁: 강력한 매개변수에 대해 자세히 알아보려면 [Action Controller 개요 § 강력한 매개변수](action_controller_overview.html#strong-parameters)를 참조하세요.

#### 유효성 검사 및 오류 메시지 표시

우리가 보았듯이, 리소스를 생성하는 것은 여러 단계의 프로세스입니다. 유효하지 않은 사용자 입력을 처리하는 것은 그 프로세스의 또 다른 단계입니다. Rails는 유효하지 않은 사용자 입력을 처리하기 위해 *유효성 검사*라는 기능을 제공합니다. 유효성 검사는 모델 객체가 저장되기 전에 확인되는 규칙입니다. 검사 중 하나라도 실패하면 저장이 중단되고 적절한 오류 메시지가 모델 객체의 `errors` 속성에 추가됩니다.

`app/models/article.rb`에 모델에 일부 유효성 검사를 추가해 봅시다:

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

첫 번째 유효성 검사는 `title` 값이 있어야 함을 선언합니다. `title`은 문자열이므로, 이는 `title` 값이 적어도 하나의 공백이 아닌 문자를 포함해야 함을 의미합니다.

두 번째 유효성 검사는 `body` 값도 있어야 함을 선언합니다. 또한 `body` 값은 적어도 10자 이상이어야 함을 선언합니다.

참고: `title` 및 `body` 속성이 어디에 정의되어 있는지 궁금할 수 있습니다. Active Record는 자동으로 모든 테이블 열에 대한 모델 속성을 정의하므로 모델 파일에서 해당 속성을 선언할 필요가 없습니다.
우리의 유효성 검사가 준비되었으므로 `app/views/articles/new.html.erb`를 수정하여 `title`과 `body`에 대한 모든 오류 메시지를 표시하도록 합시다:

```html+erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

[`full_messages_for`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_messages_for) 메서드는 지정된 속성에 대한 사용자 친화적인 오류 메시지의 배열을 반환합니다. 해당 속성에 대한 오류가 없는 경우 배열은 비어 있습니다.

이 모든 것이 어떻게 함께 작동하는지 이해하기 위해 `new` 및 `create` 컨트롤러 액션을 다시 살펴보겠습니다:

```ruby
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
```

<http://localhost:3000/articles/new>를 방문하면 `GET /articles/new` 요청이 `new` 액션에 매핑됩니다. `new` 액션은 `@article`을 저장하지 않으므로 유효성 검사가 수행되지 않고 오류 메시지가 없습니다.

폼을 제출하면 `POST /articles` 요청이 `create` 액션에 매핑됩니다. `create` 액션은 `@article`을 저장하려고 시도합니다. 따라서 유효성 검사가 수행됩니다. 유효성 검사에 실패하면 `@article`이 저장되지 않고 `app/views/articles/new.html.erb`가 오류 메시지와 함께 렌더링됩니다.

TIP: 유효성 검사에 대해 자세히 알아보려면 [Active Record Validations](active_record_validations.html)을 참조하십시오. 유효성 검사 오류 메시지에 대해 자세히 알아보려면 [Active Record Validations § Working with Validation Errors](active_record_validations.html#working-with-validation-errors)를 참조하십시오.

#### 마무리

이제 <http://localhost:3000/articles/new>를 방문하여 기사를 작성할 수 있습니다. 마무리하려면 `app/views/articles/index.html.erb`의 맨 아래에서 해당 페이지로 링크를 추가하겠습니다:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

### 기사 업데이트

CRUD의 "CR"을 다루었습니다. 이제 "U" (업데이트)로 넘어갑시다. 리소스 업데이트는 리소스 생성과 매우 유사합니다. 둘 다 여러 단계로 이루어진 프로세스입니다. 먼저 사용자가 데이터를 편집하는 양식을 요청합니다. 그런 다음 사용자가 양식을 제출합니다. 오류가 없으면 리소스가 업데이트됩니다. 그렇지 않으면 양식이 오류 메시지와 함께 다시 표시되고 프로세스가 반복됩니다.

이러한 단계는 일반적으로 컨트롤러의 `edit` 및 `update` 액션에서 처리됩니다. `app/controllers/articles_controller.rb`에 이러한 액션들의 전형적인 구현을 `create` 액션 아래에 추가해 봅시다:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

`edit` 및 `update` 액션이 `new` 및 `create` 액션과 유사하게 보이는지 주목하세요.

`edit` 액션은 데이터베이스에서 기사를 가져와 `@article`에 저장하여 양식 작성 시 사용할 수 있도록 합니다. 기본적으로 `edit` 액션은 `app/views/articles/edit.html.erb`를 렌더링합니다.

`update` 액션은 데이터베이스에서 기사를 다시 가져오고 `article_params`로 필터링된 제출된 양식 데이터로 업데이트를 시도합니다. 유효성 검사가 실패하지 않고 업데이트가 성공하면 액션은 브라우저를 기사 페이지로 리디렉션합니다. 그렇지 않으면 액션은 오류 메시지와 함께 양식을 다시 표시하기 위해 `app/views/articles/edit.html.erb`를 렌더링합니다.

#### 뷰 코드 공유를 위한 부분 사용하기

`edit` 양식은 `new` 양식과 동일합니다. 코드도 같을 것입니다. 이는 Rails 폼 빌더와 리소스풀 라우팅 덕분입니다. 폼 빌더는 모델 객체가 이전에 저장되었는지에 따라 적절한 종류의 요청을 수행하도록 폼을 자동으로 구성합니다.

코드가 동일하기 때문에 공유 뷰인 *부분*으로 추출하겠습니다. 다음 내용으로 `app/views/articles/_form.html.erb`를 생성합니다:

```html+erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```
위의 코드는 `app/views/articles/new.html.erb`에 있는 폼과 동일하지만, `@article`의 모든 발생을 `article`로 대체한 것입니다. 부분은 공유 코드이므로 컨트롤러 액션에서 설정된 특정 인스턴스 변수에 의존하지 않는 것이 가장 좋은 방법입니다. 대신, 우리는 부분에 article을 로컬 변수로 전달할 것입니다.

`app/views/articles/new.html.erb`를 [`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render)를 통해 부분을 사용하도록 업데이트해 보겠습니다.

```html+erb
<h1>New Article</h1>

<%= render "form", article: @article %>
```

참고: 부분의 파일 이름은 밑줄로 시작해야 합니다. 예를 들어 `_form.html.erb`입니다. 그러나 렌더링할 때는 밑줄을 제외하고 참조해야 합니다. 예를 들어 `render "form"`입니다.

그리고 이제 매우 유사한 `app/views/articles/edit.html.erb`를 만들어 보겠습니다.

```html+erb
<h1>Edit Article</h1>

<%= render "form", article: @article %>
```

팁: 부분에 대해 더 알아보려면 [Rails에서 레이아웃과 렌더링 § 부분 사용하기](layouts_and_rendering.html#using-partials)를 참조하세요.

#### 마무리

이제 편집 페이지를 방문하여 기사를 업데이트할 수 있습니다. 예를 들어 <http://localhost:3000/articles/1/edit>입니다. 마무리하려면 `app/views/articles/show.html.erb`의 맨 아래에 편집 페이지로의 링크를 추가해 보겠습니다.

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
</ul>
```

### 기사 삭제하기

마지막으로 CRUD의 "D" (Delete)에 도달했습니다. 리소스를 삭제하는 것은 생성 또는 업데이트보다 간단한 프로세스입니다. 라우트와 컨트롤러 액션이 필요합니다. 그리고 리소스 라우팅 (`resources :articles`)은 이미 `ArticlesController`의 `destroy` 액션에 `DELETE /articles/:id` 요청을 매핑하는 라우트를 제공합니다.

그러니까, `app/controllers/articles_controller.rb`에 `update` 액션 아래에 전형적인 `destroy` 액션을 추가해 보겠습니다.

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

`destroy` 액션은 데이터베이스에서 기사를 가져오고, 그것에 대해 [`destroy`](https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy)를 호출합니다. 그런 다음, 브라우저를 루트 경로로 리디렉션하고 상태 코드 [303 See Other](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/303)를 설정합니다.

기사에 대한 주요 액세스 포인트이기 때문에 루트 경로로 리디렉션하기로 선택했습니다. 그러나 다른 상황에서는 예를 들어 `articles_path`로 리디렉션할 수도 있습니다.

이제 `app/views/articles/show.html.erb`의 맨 아래에 링크를 추가하여 기사를 자체 페이지에서 삭제할 수 있습니다.

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>
```

위의 코드에서는 "Destroy" 링크의 `data` 옵션을 사용하여 "Destroy" 링크의 `data-turbo-method` 및 `data-turbo-confirm` HTML 속성을 설정합니다. 이러한 속성은 기본적으로 새로운 Rails 애플리케이션에 포함된 Turbo에 연결됩니다. `data-turbo-method="delete"`는 링크가 `GET` 요청 대신 `DELETE` 요청을 수행하도록합니다. `data-turbo-confirm="Are you sure?"`는 링크를 클릭할 때 확인 대화 상자가 표시되도록합니다. 사용자가 대화 상자를 취소하면 요청이 중단됩니다.

그리고 이게 다입니다! 이제 기사를 나열, 표시, 생성, 업데이트 및 삭제할 수 있습니다! InCRUDable!

두 번째 모델 추가하기
---------------------

이제 애플리케이션에 두 번째 모델을 추가할 시간입니다. 두 번째 모델은 기사에 대한 댓글을 처리할 것입니다.

### 모델 생성하기

이전에 `Article` 모델을 생성할 때 사용한 동일한 생성기를 볼 것입니다. 이번에는 기사에 대한 댓글을 저장할 `Comment` 모델을 생성합니다. 터미널에서 다음 명령을 실행하세요.

```bash
$ bin/rails generate model Comment commenter:string body:text article:references
```

이 명령은 네 개의 파일을 생성합니다.

| 파일                                         | 목적                                                                                                 |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| db/migrate/20140120201010_create_comments.rb | 데이터베이스에 댓글 테이블을 생성하는 마이그레이션 (이름에는 다른 타임스탬프가 포함됩니다)                   |
| app/models/comment.rb                        | Comment 모델                                                                                         |
| test/models/comment_test.rb                  | Comment 모델의 테스트 환경                                                                             |
| test/fixtures/comments.yml                   | 테스트에 사용할 샘플 댓글                                                                               |

먼저 `app/models/comment.rb`를 살펴보세요.

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

이것은 이전에 보았던 `Article` 모델과 매우 유사합니다. 차이점은 `belongs_to :article`라인으로, Active Record _연관_을 설정합니다. 연관에 대해 조금 더 알아보겠습니다.
쉘 명령어에서 사용되는 (`:references`) 키워드는 모델에 대한 특수한 데이터 유형입니다.
이는 제공된 모델 이름 뒤에 `_id`가 추가된 새로운 열을 데이터베이스 테이블에 생성하여 정수 값을 저장할 수 있게 합니다. 더 잘 이해하기 위해 마이그레이션을 실행한 후 `db/schema.rb` 파일을 분석하세요.

모델 외에도 Rails는 해당하는 데이터베이스 테이블을 생성하기 위해 마이그레이션을 생성합니다:

```ruby
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

`t.references` 라인은 `article_id`라는 정수 열을 생성하고 해당 열에 대한 인덱스와 `articles` 테이블의 `id` 열을 가리키는 외래 키 제약 조건을 생성합니다. 마이그레이션을 실행하세요:

```bash
$ bin/rails db:migrate
```

Rails는 현재 데이터베이스에 이미 실행된 마이그레이션을 제외한 마이그레이션만 실행합니다. 따라서 이 경우에는 다음과 같이 표시됩니다:

```
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```

### 모델 연결하기

Active Record 연관 관계를 사용하면 두 모델 간의 관계를 쉽게 선언할 수 있습니다.
댓글과 게시물의 경우, 다음과 같이 관계를 작성할 수 있습니다:

* 각 댓글은 하나의 게시물에 속합니다.
* 하나의 게시물에는 여러 개의 댓글이 있을 수 있습니다.

사실, 이는 Rails가 이 관계를 선언하기 위해 사용하는 구문과 매우 유사합니다. 이미 `Comment` 모델 내부의 코드 라인을 보았습니다(app/models/comment.rb), 각 댓글이 게시물에 속하도록 만드는 코드입니다:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

관계의 다른 쪽을 추가하려면 `app/models/article.rb`를 편집해야 합니다:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

이 두 선언은 많은 자동 동작을 가능하게 합니다. 예를 들어, `@article`이라는 인스턴스 변수에 게시물이 포함되어 있다면 `@article.comments`를 사용하여 해당 게시물에 속하는 모든 댓글을 배열로 가져올 수 있습니다.

팁: Active Record 연관 관계에 대한 자세한 내용은 [Active Record 연관 관계](association_basics.html) 가이드를 참조하세요.

### 댓글을 위한 라우트 추가하기

`articles` 컨트롤러와 마찬가지로, `comments`를 볼 수 있는 경로를 추가해야 합니다. 다시 `config/routes.rb` 파일을 열고 다음과 같이 편집하세요:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

이렇게 하면 `comments`가 `articles`의 중첩 리소스로 생성됩니다. 이는 게시물과 댓글 간에 계층적인 관계를 캡처하는 데 사용됩니다.

팁: 라우팅에 대한 자세한 내용은 [Rails 라우팅](routing.html) 가이드를 참조하세요.

### 컨트롤러 생성하기

모델이 준비되었으므로 해당하는 컨트롤러를 생성하는 데 집중할 수 있습니다. 이전에 사용한 동일한 생성기를 다시 사용하겠습니다:

```bash
$ bin/rails generate controller Comments
```

이렇게 하면 세 개의 파일과 하나의 빈 디렉토리가 생성됩니다:

| 파일/디렉토리                               | 목적                                    |
| -------------------------------------------- | ---------------------------------------- |
| app/controllers/comments_controller.rb       | Comments 컨트롤러                        |
| app/views/comments/                          | 컨트롤러의 뷰가 여기에 저장됩니다.       |
| test/controllers/comments_controller_test.rb | 컨트롤러에 대한 테스트                   |
| app/helpers/comments_helper.rb               | 뷰 헬퍼 파일                            |

블로그와 마찬가지로, 독자는 게시물을 읽은 후 직접 댓글을 작성하고 댓글을 추가한 후에는 댓글이 나열된 게시물 보기 페이지로 돌아갑니다. 따라서 `CommentsController`는 댓글을 생성하고 스팸 댓글이 도착했을 때 삭제하는 메서드를 제공합니다.

따라서 먼저 `Article` 보기 템플릿(`app/views/articles/show.html.erb`)을 수정하여 새 댓글을 작성할 수 있도록 연결합니다:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

이렇게 하면 `Article` 보기 페이지에 댓글을 생성하는 폼이 추가되며, `CommentsController`의 `create` 액션을 호출하여 새 댓글을 생성합니다. 여기서 `form_with` 호출은 배열을 사용하여 중첩된 경로를 생성합니다. 예를 들어 `/articles/1/comments`와 같은 중첩된 경로를 생성합니다.
`app/controllers/comments_controller.rb`에 있는 `create`를 연결해 보겠습니다:

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

여기서는 기사 컨트롤러보다 약간 더 복잡성을 볼 수 있습니다. 이는 설정한 중첩의 부작용입니다. 각 댓글 요청은 댓글이 첨부된 기사를 추적해야 하므로, 해당 기사를 얻기 위해 `Article` 모델의 `find` 메소드를 초기 호출합니다.

또한, 코드는 관련된 연관 관계의 일부 메소드를 활용합니다. `@article.comments`에서 `create` 메소드를 사용하여 댓글을 생성하고 저장합니다. 이렇게 하면 댓글이 해당 기사에 속하도록 자동으로 연결됩니다.

새로운 댓글을 만든 후에는 `article_path(@article)` 도우미를 사용하여 사용자를 원래 기사로 돌려보냅니다. 이미 보았듯이, 이는 `ArticlesController`의 `show` 액션을 호출하고, 이는 다시 `show.html.erb` 템플릿을 렌더링합니다. 이곳에 댓글을 표시하려고 하므로, `app/views/articles/show.html.erb`에 추가해 보겠습니다.

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Comments</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

이제 블로그에 기사와 댓글을 추가하고 올바른 위치에 표시할 수 있습니다.

![Article with Comments](images/getting_started/article_with_comments.png)

리팩토링
-----------

이제 기사와 댓글이 작동하는 것을 확인했으므로, `app/views/articles/show.html.erb` 템플릿을 살펴보겠습니다. 이 템플릿은 길고 어색해지고 있습니다. 이를 개선하기 위해 부분 템플릿을 사용할 수 있습니다.

### 부분 컬렉션 렌더링

먼저, 기사의 모든 댓글을 표시하는 댓글 부분을 만들어 보겠습니다. `app/views/comments/_comment.html.erb` 파일을 생성하고 다음 내용을 넣어주세요:

```html+erb
<p>
  <strong>Commenter:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comment:</strong>
  <%= comment.body %>
</p>
```

그런 다음 `app/views/articles/show.html.erb`를 다음과 같이 변경할 수 있습니다:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

이제 `render` 메소드는 `@article.comments` 컬렉션에 있는 각 댓글에 대해 한 번씩 `app/views/comments/_comment.html.erb` 부분을 렌더링합니다. `render` 메소드는 `@article.comments` 컬렉션을 반복하면서 각 댓글을 해당하는 부분 이름과 동일한 로컬 변수에 할당합니다. 이 경우에는 `comment`로 지정되며, 이는 부분에서 사용할 수 있습니다.

### 부분 폼 렌더링

이제 새 댓글 섹션을 독립적인 부분으로 이동해 보겠습니다. 다시 말하지만, `app/views/comments/_form.html.erb`라는 파일을 만들고 다음 내용을 넣어주세요:

```html+erb
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

그런 다음 `app/views/articles/show.html.erb`를 다음과 같이 변경할 수 있습니다:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= render 'comments/form' %>
```

두 번째 `render`는 렌더링하려는 부분 템플릿인 `comments/form`을 정의합니다. Rails는 이 문자열에서 슬래시를 인식하여 `app/views/comments` 디렉토리의 `_form.html.erb` 파일을 렌더링하려는 것을 알아차립니다.

`@article` 객체는 뷰에서 렌더링된 모든 부분에서 사용할 수 있습니다. 이는 인스턴스 변수로 정의했기 때문입니다.

### Concern 사용

Concern은 큰 컨트롤러나 모델을 이해하고 관리하기 쉽게 만드는 방법입니다. 또한, 여러 모델(또는 컨트롤러)이 동일한 관심사를 공유할 때 재사용성의 이점도 있습니다. Concern은 모델이나 컨트롤러가 책임질 기능의 명확하게 정의된 조각을 나타내는 메소드를 포함하는 모듈을 사용하여 구현됩니다. 다른 언어에서는 모듈을 종종 믹스인이라고 합니다.
컨트롤러나 모델에서 모듈을 사용하는 것과 동일한 방식으로 concern을 사용할 수 있습니다. `rails new blog`로 앱을 처음 생성할 때 `app/` 폴더 내에 다음과 같이 두 개의 폴더가 생성되었습니다:

```
app/controllers/concerns
app/models/concerns
```

아래 예시에서는 concern을 사용하여 블로그에 새로운 기능을 구현하고, concern을 생성한 후 코드를 리팩토링하여 코드를 더 DRY하고 유지보수 가능하게 만들 것입니다.

블로그 글은 여러 가지 상태를 가질 수 있습니다 - 예를 들어, 모두에게 보이는 상태(`public`)이거나 작성자에게만 보이는 상태(`private`)일 수 있습니다. 또한 모두에게는 보이지 않지만 검색 가능한 상태(`archived`)일 수도 있습니다. 댓글도 마찬가지로 숨겨질 수 있거나 보이게 될 수 있습니다. 이는 각 모델에 `status` 열을 사용하여 나타낼 수 있습니다.

먼저, 다음 마이그레이션을 실행하여 `Articles`와 `Comments`에 `status`를 추가해 보겠습니다:

```bash
$ bin/rails generate migration AddStatusToArticles status:string
$ bin/rails generate migration AddStatusToComments status:string
```

그리고 다음 명령을 사용하여 생성된 마이그레이션으로 데이터베이스를 업데이트합니다:

```bash
$ bin/rails db:migrate
```

기존 글과 댓글에 대한 상태를 선택하려면 생성된 마이그레이션 파일에 `default: "public"` 옵션을 추가하여 기본값을 설정한 다음 마이그레이션을 다시 실행할 수 있습니다. 또는 `rails console`에서 `Article.update_all(status: "public")`와 `Comment.update_all(status: "public")`을 호출할 수도 있습니다.


팁: 마이그레이션에 대해 더 알아보려면 [Active Record Migrations](active_record_migrations.html)을 참조하세요.

또한 `app/controllers/articles_controller.rb`에서 `:status` 키를 strong parameter의 일부로 허용해야 합니다:

```ruby

  private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
```

그리고 `app/controllers/comments_controller.rb`에서도 마찬가지로 해야 합니다:

```ruby

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

`article` 모델 내에서 `bin/rails db:migrate` 명령을 사용하여 `status` 열을 추가한 후 다음과 같이 추가해야 합니다:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

그리고 `Comment` 모델에서도 다음과 같이 추가해야 합니다:

```ruby
class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

그런 다음 `index` 액션 템플릿인 `app/views/articles/index.html.erb`에서 `archived?` 메소드를 사용하여 아카이브된 글을 표시하지 않도록 해야 합니다:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

마찬가지로, 댓글 부분 뷰인 `app/views/comments/_comment.html.erb`에서 `archived?` 메소드를 사용하여 아카이브된 댓글을 표시하지 않도록 해야 합니다:

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>
```

그러나 이제 다시 모델을 살펴보면 로직이 중복되어 있는 것을 알 수 있습니다. 미래에 블로그의 기능을 확장하여 개인 메시지를 포함시킬 경우, 로직을 다시 중복해서 작성해야 할 수도 있습니다. 이때 concerns가 유용합니다.

Concern은 모델의 책임에 대한 집중된 하위 집합에만 책임이 있습니다. concern 내의 메소드는 모두 모델의 가시성과 관련이 있습니다. 새로운 concern(모듈)인 `Visible`이라고 부르겠습니다. `app/models/concerns` 폴더 내에 `visible.rb`라는 새 파일을 생성하고, 모델에서 중복된 상태 메소드를 저장합니다.

`app/models/concerns/visible.rb`

```ruby
module Visible
  def archived?
    status == 'archived'
  end
end
```

Concern에 상태 유효성 검사를 추가할 수도 있지만, 이는 약간 복잡합니다. 유효성 검사는 클래스 수준에서 호출되는 메소드이기 때문입니다. `ActiveSupport::Concern` ([API 가이드](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html))를 사용하면 더 간단하게 포함시킬 수 있습니다:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  def archived?
    status == 'archived'
  end
end
```

이제 각 모델에서 중복된 로직을 제거하고 새로운 `Visible` 모듈을 포함시킬 수 있습니다:


`app/models/article.rb`에서:

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

그리고 `app/models/comment.rb`에서:

```ruby
class Comment < ApplicationRecord
  include Visible

  belongs_to :article
end
```
클래스 메서드는 concerns에 추가할 수도 있습니다. 메인 페이지에서 공개된 기사나 댓글의 수를 표시하려면 다음과 같이 Visible에 클래스 메서드를 추가할 수 있습니다.

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      where(status: 'public').count
    end
  end

  def archived?
    status == 'archived'
  end
end
```

그런 다음 뷰에서 일반적인 클래스 메서드처럼 호출할 수 있습니다.

```html+erb
<h1>Articles</h1>

Our blog has <%= Article.public_count %> articles and counting!

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

마무리로, 폼에 선택 상자를 추가하고 사용자가 새 기사를 작성하거나 새 댓글을 게시할 때 상태를 선택할 수 있도록 할 것입니다. 또한 기본 상태를 `public`으로 지정할 수도 있습니다. `app/views/articles/_form.html.erb`에 다음을 추가할 수 있습니다.

```html+erb
<div>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</div>
```

그리고 `app/views/comments/_form.html.erb`에 다음을 추가합니다.

```html+erb
<p>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</p>
```

댓글 삭제
-----------------

블로그의 또 다른 중요한 기능은 스팸 댓글을 삭제할 수 있는 것입니다. 이를 위해 뷰에 어떤 종류의 링크를 구현하고 `CommentsController`에 `destroy` 액션을 구현해야 합니다.

먼저, `app/views/comments/_comment.html.erb` 부분에 삭제 링크를 추가합니다.

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>

  <p>
    <%= link_to "Destroy Comment", [comment.article, comment], data: {
                  turbo_method: :delete,
                  turbo_confirm: "Are you sure?"
                } %>
  </p>
<% end %>
```

이 새로운 "Destroy Comment" 링크를 클릭하면 `DELETE /articles/:article_id/comments/:id`를 `CommentsController`로 전송하게 되고, 이를 사용하여 삭제할 댓글을 찾을 수 있습니다. 따라서 컨트롤러에 `destroy` 액션을 추가합니다(`app/controllers/comments_controller.rb`).

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), status: :see_other
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
end
```

`destroy` 액션은 보고 있는 기사를 찾고, `@article.comments` 컬렉션 내에서 댓글을 찾은 다음 데이터베이스에서 삭제하고 기사의 show 액션으로 돌아갑니다.

### 관련된 객체 삭제

기사를 삭제하면 관련된 댓글도 삭제되어야 합니다. 그렇지 않으면 데이터베이스에서 공간을 차지하기만 할 것입니다. Rails는 연관 관계의 `dependent` 옵션을 사용하여 이를 구현할 수 있습니다. `app/models/article.rb`의 Article 모델을 다음과 같이 수정합니다.

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

보안
--------

### 기본 인증

블로그를 온라인으로 게시하면 누구나 기사를 추가, 편집 및 삭제하거나 댓글을 삭제할 수 있습니다.

Rails는 이러한 상황에서 잘 작동하는 HTTP 인증 시스템을 제공합니다.

`ArticlesController`에서 인증되지 않은 사용자의 액세스를 차단하는 방법이 필요합니다. 여기서는 Rails의 `http_basic_authenticate_with` 메서드를 사용할 수 있으며, 해당 메서드가 허용하는 경우 요청된 액션에 대한 액세스를 허용합니다.

인증 시스템을 사용하려면 `ArticlesController`의 맨 위에 지정합니다. 우리의 경우, 사용자가 `index`와 `show`를 제외한 모든 액션에서 인증되어야 하므로 다음과 같이 작성합니다.

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # snippet for brevity
```

또한 인증된 사용자만 댓글을 삭제할 수 있도록 하려면 `CommentsController`(`app/controllers/comments_controller.rb`)에 다음을 작성합니다.

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # snippet for brevity
```

이제 새 기사를 작성하려고 하면 기본 HTTP 인증 도전을 받게 됩니다.

![Basic HTTP Authentication Challenge](images/getting_started/challenge.png)

올바른 사용자 이름과 비밀번호를 입력한 후에는 다른 사용자 이름과 비밀번호가 요구되거나 브라우저가 닫힐 때까지 인증 상태가 유지됩니다.
레일즈 애플리케이션에는 다른 인증 방법이 있습니다. 레일즈에서 인기있는 인증 애드온으로는 [Devise](https://github.com/plataformatec/devise) 레일즈 엔진과 [Authlogic](https://github.com/binarylogic/authlogic) 젬이 있으며, 기타 여러 가지도 있습니다.

### 기타 보안 고려 사항

보안은 특히 웹 애플리케이션에서 넓고 상세한 영역입니다. 레일즈 애플리케이션의 보안에 대한 자세한 내용은 [Ruby on Rails 보안 가이드](security.html)에서 다루고 있습니다.


다음 단계는?
------------

첫 번째 레일즈 애플리케이션을 확인했으므로 자유롭게 업데이트하고 실험할 수 있습니다.

도움 없이 모든 것을 해야하는 것은 아닙니다. 레일즈를 시작하고 실행하는 데 도움이 필요한 경우 다음 지원 리소스를 참조하십시오:

* [Ruby on Rails 가이드](index.html)
* [Ruby on Rails 메일링 리스트](https://discuss.rubyonrails.org/c/rubyonrails-talk)


구성 주의 사항
---------------------

레일즈를 사용하는 가장 쉬운 방법은 모든 외부 데이터를 UTF-8로 저장하는 것입니다. 그렇지 않으면 Ruby 라이브러리와 레일즈가 원시 데이터를 UTF-8로 변환할 수 있지만 항상 신뢰할 수 없으므로 모든 외부 데이터가 UTF-8로 저장되도록 하는 것이 좋습니다.

이 영역에서 실수를 한 경우 가장 일반적인 증상은 브라우저에 검은색 다이아몬드와 물음표가 나타나는 것입니다. 또 다른 일반적인 증상은 "Ã¼"와 같은 문자가 "ü" 대신 나타나는 것입니다. 레일즈는 이러한 문제의 일반적인 원인을 완화하기 위해 일련의 내부 단계를 수행하여 자동으로 감지하고 수정합니다. 그러나 UTF-8로 저장되지 않은 외부 데이터가 있는 경우 레일즈에서 자동으로 감지하고 수정할 수 없는 이러한 종류의 문제가 때때로 발생할 수 있습니다.

UTF-8로 저장되지 않은 데이터의 두 가지 매우 일반적인 출처:

* 텍스트 편집기: 대부분의 텍스트 편집기 (예: TextMate)는 파일을 기본적으로 UTF-8로 저장합니다. 텍스트 편집기가 그렇지 않은 경우 템플릿에 입력한 특수 문자 (예: é)가 브라우저에서 다이아몬드와 물음표로 표시될 수 있습니다. 이는 i18n 번역 파일에도 적용됩니다. 기본적으로 UTF-8로 기본 설정되지 않은 대부분의 편집기 (예: 일부 버전의 Dreamweaver)는 기본 설정을 UTF-8로 변경하는 방법을 제공합니다. 변경하십시오.
* 데이터베이스: 레일즈는 데이터베이스에서 데이터를 UTF-8로 변환하는 것을 기본값으로 설정합니다. 그러나 데이터베이스가 내부적으로 UTF-8을 사용하지 않는 경우 사용자가 입력한 모든 문자를 저장할 수 없을 수 있습니다. 예를 들어, 데이터베이스가 내부적으로 Latin-1을 사용하고 사용자가 러시아어, 히브리어 또는 일본어 문자를 입력한 경우 데이터는 데이터베이스에 입력되면 영원히 손실됩니다. 가능하면 데이터베이스의 내부 저장소로 UTF-8을 사용하십시오.
