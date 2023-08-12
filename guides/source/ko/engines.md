**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2aedcd7fcf6f0b83538e8a8220d38afd
엔진 시작하기
============================

이 가이드에서는 엔진에 대해 알아보고, 깨끗하고 매우 쉬운 인터페이스를 통해 호스트 애플리케이션에 추가 기능을 제공하는 방법을 배울 것입니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* 엔진을 구성하는 요소
* 엔진을 생성하는 방법
* 엔진을 위한 기능을 구축하는 방법
* 엔진을 애플리케이션에 연결하는 방법
* 애플리케이션에서 엔진 기능을 재정의하는 방법
* 로드 및 구성 훅을 사용하여 Rails 프레임워크를 로드하지 않는 방법

--------------------------------------------------------------------------------

엔진이란 무엇인가?
-----------------

엔진은 호스트 애플리케이션에 기능을 제공하는 작은 애플리케이션으로 간주될 수 있습니다. Rails 애플리케이션은 사실상 "강화된" 엔진으로, `Rails::Application` 클래스가 `Rails::Engine`에서 많은 동작을 상속받습니다.

따라서 엔진과 애플리케이션은 거의 동일한 것으로 생각할 수 있으며, 이 가이드 전체에서 볼 수 있듯이 약간의 차이점이 있습니다. 엔진과 애플리케이션은 공통된 구조도 가지고 있습니다.

엔진은 플러그인과도 밀접한 관련이 있습니다. 두 가지는 공통된 `lib` 디렉토리 구조를 공유하며, `rails plugin new` 생성기를 사용하여 생성됩니다. 차이점은 엔진이 Rails에서 "전체 플러그인"으로 간주된다는 것입니다(생성기 명령에 전달되는 `--full` 옵션으로 표시됨). 여기에서는 실제로 `--mountable` 옵션을 사용할 것이며, 이 옵션은 `--full`의 모든 기능과 추가 기능을 포함합니다. 이 가이드에서는 이러한 "전체 플러그인"을 단순히 "엔진"이라고 부를 것입니다. 엔진은 플러그인일 수 있고, 플러그인은 엔진일 수 있습니다.

이 가이드에서 생성할 엔진의 이름은 "blorgh"입니다. 이 엔진은 호스트 애플리케이션에 블로깅 기능을 제공하여 새로운 글과 댓글을 작성할 수 있게 합니다. 이 가이드의 초반부에서는 엔진 자체에서만 작업하게 될 것이지만, 나중에는 애플리케이션에 연결하는 방법을 볼 수 있습니다.

엔진은 호스트 애플리케이션으로부터 격리될 수도 있습니다. 이는 애플리케이션이 `articles_path`와 같은 라우팅 헬퍼로 제공되는 경로를 가지고 있고, `articles_path`라는 이름의 경로를 제공하는 엔진을 사용할 수 있으며, 두 가지가 충돌하지 않는다는 것을 의미합니다. 이와 함께 컨트롤러, 모델 및 테이블 이름도 네임스페이스화됩니다. 이 가이드의 후반부에서 이를 수행하는 방법을 볼 수 있습니다.

항상 애플리케이션이 엔진보다 우선되어야 한다는 것을 명심하는 것이 중요합니다. 애플리케이션은 환경에서 무엇이 일어나는지에 대한 최종 결정권을 가지고 있습니다. 엔진은 애플리케이션을 크게 변경하는 것이 아니라 개선하는 데에만 사용되어야 합니다.

다른 엔진의 데모를 보려면 [Devise](https://github.com/plataformatec/devise)를 확인해보세요. 이 엔진은 부모 애플리케이션에 인증 기능을 제공합니다. 또한 [Thredded](https://github.com/thredded/thredded)는 포럼 기능을 제공하는 엔진입니다. [Spree](https://github.com/spree/spree)는 전자 상거래 플랫폼을 제공하며, [Refinery CMS](https://github.com/refinery/refinerycms)는 CMS 엔진입니다.

마지막으로, James Adam, Piotr Sarnacki, Rails Core 팀 및 다른 많은 사람들의 노력 덕분에 엔진이 가능해졌습니다. 만약 그들을 만나게 된다면 감사의 인사를 잊지 마세요!

엔진 생성하기
--------------------

엔진을 생성하려면 플러그인 생성기를 실행하고 필요에 따라 옵션을 전달해야 합니다. "blorgh" 예제의 경우 터미널에서 다음 명령을 실행하여 "mountable" 엔진을 생성해야 합니다:

```bash
$ rails plugin new blorgh --mountable
```

플러그인 생성기의 전체 옵션 목록은 다음과 같이 입력하여 볼 수 있습니다:

```bash
$ rails plugin --help
```

`--mountable` 옵션은 생성기에게 "mountable" 및 네임스페이스 격리된 엔진을 생성하려는 것을 알려줍니다. 이 생성기는 `--full` 옵션과 동일한 뼈대 구조를 제공합니다. `--full` 옵션은 다음과 같은 뼈대 구조를 제공하는 엔진을 생성하려는 것을 생성기에게 알려줍니다:

  * `app` 디렉토리 트리
  * `config/routes.rb` 파일:

    ```ruby
    Rails.application.routes.draw do
    end
    ```

  * `lib/blorgh/engine.rb` 파일: 이 파일은 표준 Rails 애플리케이션의 `config/application.rb` 파일과 기능적으로 동일합니다.

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
      end
    end
    ```

`--mountable` 옵션은 `--full` 옵션에 다음을 추가합니다:

  * 에셋 매니페스트 파일 (`blorgh_manifest.js` 및 `application.css`)
  * 네임스페이스화된 `ApplicationController` 스텁
  * 네임스페이스화된 `ApplicationHelper` 스텁
  * 엔진을 위한 레이아웃 뷰 템플릿
  * `config/routes.rb`에 대한 네임스페이스 격리:
```ruby
Blorgh::Engine.routes.draw do
end
```

* `lib/blorgh/engine.rb`에 대한 네임스페이스 격리:

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

또한 `--mountable` 옵션은 엔진을 `test/dummy`에 있는 더미 테스트 응용 프로그램에 마운트하기 위해 다음을 추가하여 더미 응용 프로그램의 라우트 파일인 `test/dummy/config/routes.rb`에 다음을 추가합니다.

```ruby
mount Blorgh::Engine => "/blorgh"
```

### 엔진 내부

#### 중요한 파일

이 새로운 엔진 디렉토리의 루트에는 `blorgh.gemspec` 파일이 있습니다. 나중에 응용 프로그램에 엔진을 포함시킬 때, Rails 응용 프로그램의 `Gemfile`에 다음 줄을 추가하여 수행합니다.

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

`bundle install`을 실행하는 것을 잊지 마세요. `Gemfile` 내에서 gem으로 지정함으로써, Bundler는 이 파일을 구문 분석하고 `lib` 디렉토리 내의 `lib/blorgh.rb`라는 파일을 요구합니다. 이 파일은 `lib/blorgh/engine.rb` 파일(위치: `lib/blorgh/engine.rb`)을 요구하고 `Blorgh`라는 기본 모듈을 정의합니다.

```ruby
require "blorgh/engine"

module Blorgh
end
```

TIP: 일부 엔진은 이 파일을 사용하여 엔진의 전역 구성 옵션을 넣습니다. 이는 비교적 좋은 아이디어이므로 구성 옵션을 제공하려면 엔진의 `module`이 정의된 파일이 완벽합니다. 모듈 내에 메서드를 배치하면 됩니다.

`lib/blorgh/engine.rb` 내부에는 엔진의 기본 클래스가 있습니다.

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

`Rails::Engine` 클래스를 상속함으로써 이 gem은 Rails에게 지정된 경로에 엔진이 있다고 알리고, 엔진을 응용 프로그램 내에 올바르게 마운트하여 모델, 메일러, 컨트롤러 및 뷰를 위한 `app` 디렉토리를 로드 경로에 추가하는 작업과 같은 작업을 수행합니다.

여기서 `isolate_namespace` 메서드는 특별한 주목을 받아야 합니다. 이 호출은 컨트롤러, 모델, 라우트 및 기타 요소를 응용 프로그램 내의 유사한 구성 요소와 분리하여 고유한 네임스페이스로 분리하는 역할을 합니다. 이를 사용하지 않으면 엔진의 구성 요소가 응용 프로그램에 "유출"되어 원하지 않는 중단을 야기하거나 응용 프로그램 내에서 동일한 이름을 가진 중요한 엔진 구성 요소가 덮어쓰일 수 있습니다. 이러한 충돌의 예 중 하나는 헬퍼입니다. `isolate_namespace`를 호출하지 않으면 엔진의 헬퍼가 응용 프로그램의 컨트롤러에 포함됩니다.

참고: `isolate_namespace` 줄은 **Engine** 클래스 정의 내에 남겨두는 것이 **매우** 권장됩니다. 그렇지 않으면 엔진에서 생성된 클래스가 응용 프로그램과 충돌할 수 있습니다.

네임스페이스의 격리는 `bin/rails generate model`과 같은 호출로 생성된 모델(예: `bin/rails generate model article`)이 `Article`이 아니라 `Blorgh::Article`로 호출되고, 모델의 테이블은 `articles`가 아닌 `blorgh_articles`로 네임스페이스가 지정됩니다. 모델 네임스페이싱과 유사하게 `ArticlesController`라는 컨트롤러는 `Blorgh::ArticlesController`가 되며, 해당 컨트롤러의 뷰는 `app/views/articles`가 아닌 `app/views/blorgh/articles`에 있습니다. 메일러, 작업 및 헬퍼도 네임스페이스가 지정됩니다.

마지막으로, 라우트도 엔진 내에서 격리됩니다. 이는 네임스페이스의 가장 중요한 부분 중 하나이며, 이 가이드의 [라우트](#routes) 섹션에서 자세히 설명됩니다.

#### `app` 디렉토리

`app` 디렉토리 내에는 응용 프로그램에서 익숙한 `assets`, `controllers`, `helpers`, `jobs`, `mailers`, `models` 및 `views` 디렉토리가 있습니다. 엔진을 작성할 때 더 자세히 살펴보겠습니다.

`app/assets` 디렉토리 내에는 `images` 및 `stylesheets` 디렉토리가 있습니다. 이는 응용 프로그램과 유사하므로 익숙할 것입니다. 여기서 다른 점은 각 디렉토리에 엔진 이름이 포함된 하위 디렉토리가 있다는 것입니다. 이 엔진이 네임스페이스로 사용될 것이므로 해당 자산도 네임스페이스로 지정되어야 합니다.

`app/controllers` 디렉토리 내에는 `blorgh` 디렉토리가 있으며, 이 디렉토리에는 `application_controller.rb`라는 파일이 있습니다. 이 파일은 엔진의 컨트롤러에 대한 공통 기능을 제공합니다. `blorgh` 디렉토리는 엔진의 다른 컨트롤러가 들어갈 위치입니다. 이 네임스페이스 디렉토리에 배치함으로써 다른 엔진이나 응용 프로그램 내에서 동일한 이름의 컨트롤러와 충돌할 가능성을 방지할 수 있습니다.

참고: 엔진 내의 `ApplicationController` 클래스는 응용 프로그램과 동일한 방식으로 이름이 지정되어 있으므로 응용 프로그램을 엔진으로 쉽게 변환할 수 있습니다.
참고: 부모 애플리케이션이 `classic` 모드에서 실행되는 경우, 엔진 컨트롤러가 주 애플리케이션 컨트롤러가 아닌 엔진의 애플리케이션 컨트롤러를 상속받는 상황에 직면할 수 있습니다. 이를 방지하기 위한 가장 좋은 방법은 부모 애플리케이션에서 `zeitwerk` 모드로 전환하는 것입니다. 그렇지 않으면 `require_dependency`를 사용하여 엔진의 애플리케이션 컨트롤러가 로드되도록 해야 합니다. 예를 들어:

```ruby
# `classic` 모드에서만 필요합니다.
require_dependency "blorgh/application_controller"

module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

경고: `require`를 사용하지 마십시오. 개발 환경에서 클래스의 자동 재로드를 깨뜨릴 수 있습니다. `require_dependency`를 사용하여 클래스가 올바른 방식으로 로드되고 언로드되도록 보장합니다.

`app/controllers`와 마찬가지로 `app/helpers`, `app/jobs`, `app/mailers` 및 `app/models` 디렉토리 아래에 `blorgh` 하위 디렉토리가 있으며, 공통 기능을 수집하는 `application_*.rb` 파일이 포함되어 있습니다. 이 하위 디렉토리에 파일을 배치하고 객체를 네임스페이스화함으로써 다른 엔진 또는 애플리케이션 내에서 동일한 이름의 요소와 충돌할 가능성을 방지할 수 있습니다.

마지막으로 `app/views` 디렉토리에는 `layouts` 폴더가 있으며, `blorgh/application.html.erb` 파일이 포함되어 있습니다. 이 파일을 통해 엔진에 대한 레이아웃을 지정할 수 있습니다. 이 엔진을 독립적인 엔진으로 사용하는 경우, 레이아웃에 대한 모든 사용자 정의를 이 파일이 아닌 애플리케이션의 `app/views/layouts/application.html.erb` 파일에 추가해야 합니다.

엔진 사용자에게 레이아웃을 강제로 적용하지 않으려면 이 파일을 삭제하고 엔진의 컨트롤러에서 다른 레이아웃을 참조할 수 있습니다.

#### `bin` 디렉토리

이 디렉토리에는 `bin/rails`라는 파일이 하나 포함되어 있으며, 이를 사용하여 애플리케이션 내에서와 마찬가지로 `rails` 하위 명령과 생성기를 사용할 수 있습니다. 따라서 다음과 같은 명령을 실행하여 이 엔진에 대해 새로운 컨트롤러와 모델을 쉽게 생성할 수 있습니다.

```bash
$ bin/rails generate model
```

물론, `Engine` 클래스에서 `isolate_namespace`를 사용하는 엔진 내에서 이러한 명령으로 생성된 모든 것은 네임스페이스화됩니다.

#### `test` 디렉토리

`test` 디렉토리는 엔진의 테스트가 위치할 곳입니다. 엔진을 테스트하기 위해 `test/dummy`에 내장된 Rails 애플리케이션의 축소판이 있습니다. 이 애플리케이션은 `test/dummy/config/routes.rb` 파일에서 엔진을 마운트합니다.

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

이 줄은 엔진을 `/blorgh` 경로에 마운트하며, 애플리케이션에서는 해당 경로에서만 접근할 수 있게 합니다.

테스트 디렉토리 내에는 `test/integration` 디렉토리가 있으며, 엔진의 통합 테스트를 배치해야 합니다. `test` 디렉토리에 다른 디렉토리도 생성할 수 있습니다. 예를 들어, 모델 테스트를 위해 `test/models` 디렉토리를 생성할 수 있습니다.

엔진 기능 제공
------------------------------

이 가이드에서 다루는 엔진은 기사 제출 및 댓글 기능을 제공하며, [시작 가이드](getting_started.html)와 유사한 스레드를 따릅니다.

참고: 이 섹션에서는 `blorgh` 엔진 디렉토리의 루트에서 명령을 실행해야 합니다.

### 기사 리소스 생성

블로그 엔진을 위해 먼저 생성해야 할 것은 `Article` 모델과 관련된 컨트롤러입니다. 이를 빠르게 생성하기 위해 Rails 스캐폴드 생성기를 사용할 수 있습니다.

```bash
$ bin/rails generate scaffold article title:string text:text
```

이 명령은 다음 정보를 출력합니다:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_articles.rb
create    app/models/blorgh/article.rb
invoke    test_unit
create      test/models/blorgh/article_test.rb
create      test/fixtures/blorgh/articles.yml
invoke  resource_route
 route    resources :articles
invoke  scaffold_controller
create    app/controllers/blorgh/articles_controller.rb
invoke    erb
create      app/views/blorgh/articles
create      app/views/blorgh/articles/index.html.erb
create      app/views/blorgh/articles/edit.html.erb
create      app/views/blorgh/articles/show.html.erb
create      app/views/blorgh/articles/new.html.erb
create      app/views/blorgh/articles/_form.html.erb
invoke    test_unit
create      test/controllers/blorgh/articles_controller_test.rb
create      test/system/blorgh/articles_test.rb
invoke    helper
create      app/helpers/blorgh/articles_helper.rb
invoke      test_unit
```

스캐폴드 생성기가 처음으로 수행하는 작업은 `active_record` 생성기를 호출하는 것입니다. 이는 리소스에 대한 마이그레이션과 모델을 생성합니다. 그러나 여기서 주목할 점은 마이그레이션이 `create_articles`가 아닌 `create_blorgh_articles`로 호출된다는 것입니다. 이는 `Blorgh::Engine` 클래스의 정의에서 호출된 `isolate_namespace` 메서드 때문입니다. 모델은 네임스페이스화되어 `app/models/blorgh/article.rb`에 배치됩니다. `Engine` 클래스 내에서 `isolate_namespace` 호출로 인해 `app/models/article.rb`가 아닌 `app/models/blorgh/article.rb`에 배치됩니다.

다음으로, 이 모델에 대해 `test_unit` 생성기가 호출되어 모델 테스트(`test/models/blorgh/article_test.rb`)와 픽스처(`test/fixtures/blorgh/articles.yml`)를 생성합니다.

그 다음으로, 리소스에 대한 라인이 `config/routes.rb` 파일에 삽입됩니다. 이 라인은 단순히 `resources :articles`이며, 엔진의 `config/routes.rb` 파일은 다음과 같이 됩니다:
```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

여기에서 라우트는 `YourApp::Application` 클래스가 아닌 `Blorgh::Engine` 객체에 그려집니다. 이렇게 함으로써 엔진 라우트가 엔진 자체에 제한되고 [테스트 디렉토리](#test-directory) 섹션에 표시된대로 특정 지점에 마운트될 수 있습니다. 또한 이로 인해 엔진의 라우트가 응용 프로그램 내의 라우트와 격리되게 됩니다. 이 가이드의 [라우트](#routes) 섹션에서 자세히 설명합니다.

다음으로 `scaffold_controller` 생성기를 호출하여 `Blorgh::ArticlesController`라는 컨트롤러(위치: `app/controllers/blorgh/articles_controller.rb`)와 관련된 뷰(위치: `app/views/blorgh/articles`)를 생성합니다. 이 생성기는 또한 컨트롤러에 대한 테스트(`test/controllers/blorgh/articles_controller_test.rb` 및 `test/system/blorgh/articles_test.rb`)와 헬퍼(`app/helpers/blorgh/articles_helper.rb`)를 생성합니다.

이 생성기가 생성한 모든 것은 깔끔하게 네임스페이스화되어 있습니다. 컨트롤러의 클래스는 `Blorgh` 모듈 내에서 정의됩니다:

```ruby
module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

참고: `ArticlesController` 클래스는 응용 프로그램의 `ApplicationController`가 아닌 `Blorgh::ApplicationController`를 상속받습니다.

`app/helpers/blorgh/articles_helper.rb` 내부의 헬퍼도 네임스페이스화되어 있습니다:

```ruby
module Blorgh
  module ArticlesHelper
    # ...
  end
end
```

이렇게 함으로써 다른 엔진이나 애플리케이션에서도 article 리소스를 가질 수 있을 때 충돌을 방지할 수 있습니다.

`bin/rails db:migrate`를 엔진의 루트에서 실행하여 스캐폴드 생성기에 의해 생성된 마이그레이션을 실행한 다음 `test/dummy`에서 `bin/rails server`를 실행하면 엔진이 지금까지 생성한 내용을 확인할 수 있습니다. `http://localhost:3000/blorgh/articles`를 열면 생성된 기본 스캐폴드가 표시됩니다. 클릭해보세요! 첫 번째 엔진의 첫 번째 기능을 생성했습니다.

콘솔에서 실험하려면 `bin/rails console`도 Rails 애플리케이션과 마찬가지로 작동합니다. 기억하세요: `Article` 모델은 네임스페이스화되었으므로 `Blorgh::Article`로 호출해야 합니다.

```irb
irb> Blorgh::Article.find(1)
=> #<Blorgh::Article id: 1 ...>
```

마지막으로, 이 엔진의 `articles` 리소스는 엔진의 루트여야 합니다. 엔진이 마운트된 루트 경로로 이동하면 사용자는 글 목록이 표시되어야 합니다. 이를 위해 `config/routes.rb` 파일 내에 다음 줄을 삽입하면 됩니다:

```ruby
root to: "articles#index"
```

이제 사람들은 모든 글을 보려면 엔진의 루트로만 이동하면 되고 `/articles`를 방문할 필요가 없습니다. 이는 `http://localhost:3000/blorgh/articles` 대신 이제 `http://localhost:3000/blorgh`로 이동하면 됩니다.

### 댓글 리소스 생성

이제 엔진이 새로운 글을 생성할 수 있으므로 댓글 기능도 추가하는 것이 합리적입니다. 이를 위해 댓글 모델, 댓글 컨트롤러를 생성한 다음 글 스캐폴드를 수정하여 댓글을 표시하고 새 댓글을 생성할 수 있도록 해야 합니다.

엔진 루트에서 모델 생성기를 실행합니다. `Comment` 모델을 생성하고 관련 테이블에 `article_id` 정수 및 `text` 텍스트 열 두 개를 가지도록 지정합니다.

```bash
$ bin/rails generate model Comment article_id:integer text:text
```

다음과 같은 출력이 표시됩니다:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_comments.rb
create    app/models/blorgh/comment.rb
invoke    test_unit
create      test/models/blorgh/comment_test.rb
create      test/fixtures/blorgh/comments.yml
```

이 생성기 호출은 필요한 모델 파일만 생성하며, `blorgh` 디렉토리 아래에 파일을 네임스페이스화하고 `Blorgh::Comment`라는 모델 클래스를 생성합니다. 이제 마이그레이션을 실행하여 `blorgh_comments` 테이블을 생성합니다:

```bash
$ bin/rails db:migrate
```

글에 댓글을 표시하려면 `app/views/blorgh/articles/show.html.erb`를 편집하고 "Edit" 링크 앞에 다음 줄을 추가합니다:

```html+erb
<h3>Comments</h3>
<%= render @article.comments %>
```

이 줄은 `Blorgh::Article` 모델에 정의된 `has_many` 연관 관계가 있어야 합니다. 현재는 그런 연관 관계가 없습니다. 연관 관계를 정의하려면 `app/models/blorgh/article.rb`를 열고 다음 줄을 모델에 추가합니다:

```ruby
has_many :comments
```

모델은 다음과 같이 변합니다:

```ruby
module Blorgh
  class Article < ApplicationRecord
    has_many :comments
  end
end
```

참고: `has_many`가 `Blorgh` 모듈 내의 클래스 내에서 정의되었기 때문에 Rails는 이 객체에 `Blorgh::Comment` 모델을 사용하려는 것을 알 수 있으므로 여기에서 `:class_name` 옵션을 지정할 필요가 없습니다.

다음으로, 글에 댓글을 생성할 수 있는 폼이 필요합니다. 이를 추가하려면 `app/views/blorgh/articles/show.html.erb`에서 `render @article.comments` 호출 다음에 다음 줄을 추가합니다:

```erb
<%= render "blorgh/comments/form" %>
```

다음으로, 이 줄이 렌더링할 부분이 존재해야 합니다. `app/views/blorgh/comments`에 새 디렉토리를 만들고 그 안에 `_form.html.erb`이라는 새 파일을 생성합니다. 다음 내용을 포함하여 필요한 부분을 생성합니다.
```html+erb
<h3>새 댓글</h3>
<%= form_with model: [@article, @article.comments.build] do |form| %>
  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>
  <%= form.submit %>
<% end %>
```

이 양식이 제출되면 엔진 내에서 `/articles/:article_id/comments` 경로로 `POST` 요청을 시도합니다.
현재 이 경로는 존재하지 않지만 `config/routes.rb` 내의 `resources :articles` 줄을 다음과 같이 변경하여 생성할 수 있습니다:

```ruby
resources :articles do
  resources :comments
end
```

이렇게 하면 양식에서 요구하는 중첩된 댓글 경로가 생성됩니다.

이제 경로는 존재하지만 해당 경로로 이동하는 컨트롤러는 존재하지 않습니다. 이를 생성하려면 엔진 루트에서 다음 명령을 실행하십시오:

```bash
$ bin/rails generate controller comments
```

이렇게 하면 다음과 같은 항목이 생성됩니다:

```
create  app/controllers/blorgh/comments_controller.rb
invoke  erb
 exist    app/views/blorgh/comments
invoke  test_unit
create    test/controllers/blorgh/comments_controller_test.rb
invoke  helper
create    app/helpers/blorgh/comments_helper.rb
invoke    test_unit
```

양식은 `Blorgh::CommentsController`의 `create` 동작에 대한 `POST` 요청을 `/articles/:article_id/comments`로 보냅니다.
이 동작은 `app/controllers/blorgh/comments_controller.rb`의 클래스 정의 내에 다음 줄을 넣어 생성할 수 있습니다:

```ruby
def create
  @article = Article.find(params[:article_id])
  @comment = @article.comments.create(comment_params)
  flash[:notice] = "댓글이 생성되었습니다!"
  redirect_to articles_path
end

private
  def comment_params
    params.require(:comment).permit(:text)
  end
```

이것은 새 댓글 양식을 작동시키기 위해 필요한 최종 단계입니다. 그러나 댓글을 표시하는 것은 아직 완벽하지 않습니다. 현재 댓글을 생성하면 다음 오류가 표시됩니다:

```
Missing partial blorgh/comments/_comment with {:handlers=>[:erb, :builder],
:formats=>[:html], :locale=>[:en, :en]}. Searched in:   *
"/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"   *
"/Users/ryan/Sites/side_projects/blorgh/app/views"
```

엔진은 댓글을 렌더링하는 데 필요한 부분을 찾을 수 없습니다. Rails는 먼저 응용 프로그램(`test/dummy`)의 `app/views` 디렉토리를 찾은 다음 엔진의 `app/views` 디렉토리를 찾습니다. 찾을 수 없으면 이 오류가 발생합니다. 엔진은 `Blorgh::Comment` 클래스에서 받은 모델 객체로 `blorgh/comments/_comment`를 찾도록 지정합니다.

이 부분은 현재 댓글 텍스트를 렌더링하는 데 책임이 있습니다. `app/views/blorgh/comments/_comment.html.erb`에 새 파일을 만들고 다음 줄을 넣으십시오:

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

`comment_counter` 지역 변수는 `<%= render @article.comments %>` 호출에서 제공되며 자동으로 정의되고 각 댓글을 반복하면서 카운터를 증가시킵니다. 이 예제에서는 댓글이 생성될 때마다 작은 숫자를 각 댓글 옆에 표시하는 데 사용됩니다.

이로써 블로깅 엔진의 댓글 기능이 완료되었습니다. 이제 응용 프로그램에서 사용해 보는 것이 시간입니다.

응용 프로그램에 연결하기
---------------------------

응용 프로그램에서 엔진을 사용하는 것은 매우 쉽습니다. 이 섹션에서는 엔진을 응용 프로그램에 마운트하고 초기 설정 및 응용 프로그램에서 제공하는 `User` 클래스와 엔진 내의 기사 및 댓글에 소유권을 제공하기 위해 엔진을 연결하는 방법에 대해 다룹니다.

### 엔진 마운트하기

먼저, 엔진을 응용 프로그램의 `Gemfile`에 지정해야 합니다. 테스트용 응용 프로그램이 없는 경우 다음과 같이 엔진 디렉토리 외부에서 `rails new` 명령을 사용하여 하나를 생성하십시오:

```bash
$ rails new unicorn
```

일반적으로 `Gemfile` 내에서 엔진을 지정하는 것은 일반적인 젬처럼 지정하는 것으로 수행됩니다.

```ruby
gem 'devise'
```

그러나 `blorgh` 엔진을 로컬 머신에서 개발 중이므로 `Gemfile`에서 `:path` 옵션을 지정해야 합니다:

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

그런 다음 `bundle`을 실행하여 젬을 설치합니다.

앞에서 설명한대로 `Gemfile`에 젬을 넣으면 Rails가 로드될 때 로드됩니다. 엔진은 먼저 엔진에서 `lib/blorgh.rb`를 요구한 다음 주요 기능을 정의하는 파일인 `lib/blorgh/engine.rb`를 요구합니다.

응용 프로그램 내에서 엔진의 기능을 사용할 수 있도록 하려면 응용 프로그램의 `config/routes.rb` 파일에 마운트해야 합니다:

```ruby
mount Blorgh::Engine, at: "/blog"
```

이 줄은 응용 프로그램에서 엔진을 `/blog`에 마운트합니다. 응용 프로그램이 `bin/rails server`로 실행될 때 `http://localhost:3000/blog`에서 액세스할 수 있습니다.

참고: Devise와 같은 다른 엔진은 라우트에서 `devise_for`와 같은 사용자 정의 도우미를 지정하여 조금 다르게 처리합니다. 이 도우미는 엔진의 기능 일부를 미리 정의된 경로에 마운트하는 것과 동일한 작업을 수행합니다.
### 엔진 설정

엔진에는 `blorgh_articles`와 `blorgh_comments` 테이블에 대한 마이그레이션이 포함되어 있습니다. 이 마이그레이션은 엔진의 모델이 올바르게 쿼리할 수 있도록 응용 프로그램의 데이터베이스에 생성되어야 합니다. 이러한 마이그레이션을 응용 프로그램으로 복사하려면 응용 프로그램의 루트에서 다음 명령을 실행하십시오.

```bash
$ bin/rails blorgh:install:migrations
```

마이그레이션을 복사해야 할 여러 개의 엔진이 있는 경우 `railties:install:migrations`를 대신 사용하십시오.

```bash
$ bin/rails railties:install:migrations
```

마이그레이션을 위한 소스 엔진에서 사용자 정의 경로를 지정할 수도 있습니다. MIGRATIONS_PATH를 지정하여 다음과 같이 실행하십시오.

```bash
$ bin/rails railties:install:migrations MIGRATIONS_PATH=db_blourgh
```

여러 개의 데이터베이스가 있는 경우 DATABASE를 지정하여 대상 데이터베이스를 지정할 수도 있습니다.

```bash
$ bin/rails railties:install:migrations DATABASE=animals
```

이 명령은 처음 실행될 때 엔진에서 모든 마이그레이션을 복사합니다. 다음 번 실행될 때는 이미 복사된 마이그레이션만 복사합니다. 이 명령의 첫 실행은 다음과 같은 내용을 출력합니다.

```
Copied migration [timestamp_1]_create_blorgh_articles.blorgh.rb from blorgh
Copied migration [timestamp_2]_create_blorgh_comments.blorgh.rb from blorgh
```

첫 번째 타임스탬프 (`[timestamp_1]`)는 현재 시간이고, 두 번째 타임스탬프 (`[timestamp_2]`)는 현재 시간에 1초를 더한 값입니다. 이는 엔진의 마이그레이션이 응용 프로그램의 기존 마이그레이션 이후에 실행되도록 하기 위한 것입니다.

응용 프로그램의 컨텍스트에서 이러한 마이그레이션을 실행하려면 `bin/rails db:migrate`를 실행하면 됩니다. `http://localhost:3000/blog`를 통해 엔진에 액세스할 때, 기사는 비어 있을 것입니다. 이는 응용 프로그램 내에서 생성된 테이블이 엔진 내에서 생성된 테이블과 다르기 때문입니다. 새로 마운트된 엔진을 사용해보세요. 엔진이 단순히 엔진일 때와 동일한 것을 알 수 있습니다.

한 엔진에서만 마이그레이션을 실행하려면 `SCOPE`를 지정하여 실행할 수 있습니다.

```bash
$ bin/rails db:migrate SCOPE=blorgh
```

이는 엔진을 제거하기 전에 엔진의 마이그레이션을 되돌리고 싶을 때 유용할 수 있습니다. blorgh 엔진의 모든 마이그레이션을 되돌리려면 다음과 같은 코드를 실행할 수 있습니다.

```bash
$ bin/rails db:migrate SCOPE=blorgh VERSION=0
```

### 응용 프로그램에서 제공하는 클래스 사용

#### 응용 프로그램에서 제공하는 모델 사용

엔진을 생성할 때, 엔진과 응용 프로그램 간의 연결을 제공하기 위해 응용 프로그램의 특정 클래스를 사용하고자 할 수 있습니다. `blorgh` 엔진의 경우, 기사와 댓글에 작성자를 추가하는 것이 매우 의미가 있을 것입니다.

일반적인 응용 프로그램은 기사나 댓글의 작성자를 나타내기 위해 `User` 클래스를 사용할 수 있습니다. 그러나 응용 프로그램에서 이 클래스를 `Person`과 같은 다른 이름으로 호출하는 경우도 있을 수 있습니다. 이러한 이유로 엔진은 `User` 클래스에 특정하게 연결을 하지 않아야 합니다.

이 경우를 간단하게 유지하기 위해, 응용 프로그램은 응용 프로그램의 사용자를 나타내는 `User` 클래스를 가지고 있을 것입니다 (이를 더 구성 가능하게 만드는 방법에 대해서는 나중에 설명하겠습니다). 응용 프로그램 내에서 다음 명령을 사용하여 이 클래스를 생성할 수 있습니다.

```bash
$ bin/rails generate model user name:string
```

`bin/rails db:migrate` 명령을 여기에서 실행하여 응용 프로그램이 나중에 사용할 `users` 테이블을 가지고 있는지 확인해야 합니다.

또한, 간단하게 유지하기 위해, 기사 폼에 `author_name`이라는 새로운 텍스트 필드가 추가될 것입니다. 여기에 사용자는 자신의 이름을 입력할 수 있습니다. 그런 다음 엔진은 이 이름을 가져와서 새로운 `User` 객체를 생성하거나 해당 이름을 가진 기존 객체를 찾습니다. 그런 다음 엔진은 기사를 찾거나 생성된 `User` 객체와 연결합니다.

먼저, `author_name` 텍스트 필드를 엔진 내의 `app/views/blorgh/articles/_form.html.erb` 부분에 추가해야 합니다. 다음 코드를 사용하여 `title` 필드 위에 추가할 수 있습니다.

```html+erb
<div class="field">
  <%= form.label :author_name %><br>
  <%= form.text_field :author_name %>
</div>
```

다음으로, `Blorgh::ArticlesController#article_params` 메서드를 업데이트하여 새로운 폼 매개변수를 허용해야 합니다.

```ruby
def article_params
  params.require(:article).permit(:title, :text, :author_name)
end
```

그런 다음, `Blorgh::Article` 모델은 `author_name` 필드를 실제 `User` 객체로 변환하고 해당 기사의 `author`로 연결하기 전에 일부 코드가 필요합니다. 또한, 이 필드에 대한 setter와 getter 메서드가 정의되도록 `attr_accessor`를 설정해야 합니다.

이 모든 작업을 수행하려면 `app/models/blorgh/article.rb`에 `author_name`에 대한 `attr_accessor`, 작성자에 대한 연결 및 `before_validation` 호출을 추가해야 합니다. `author` 연결은 일단 `User` 클래스에 대해 하드코딩될 것입니다.
```ruby
module Blorgh
  mattr_accessor :author_class

  def self.author_class
    @@author_class
  end
end
```

Now, the `author_class` can be set in the application's configuration file
(`config/application.rb`) by adding the following line:

```ruby
Blorgh.author_class = "User"
```

This will set the `author_class` to the `User` class by default.

#### Configuring the Engine in an Application

To configure the engine in the application, create an initializer file
(`config/initializers/blorgh.rb`) and add the following code:

```ruby
Blorgh.configure do |config|
  config.author_class = "User"
end
```

This will set the `author_class` to the `User` class for the engine.

#### Overriding Engine Views

To override the engine's views with custom views in the application, create a
directory called `blorgh` inside the `app/views` directory of the application.
Inside the `blorgh` directory, create a directory called `articles`. Finally,
copy the engine's view file (`app/views/blorgh/articles/show.html.erb`) into
the `articles` directory. The application will now use this custom view instead
of the default view provided by the engine.

#### Overriding Engine Controllers

To override the engine's controllers with custom controllers in the application,
create a directory called `blorgh` inside the `app/controllers` directory of the
application. Inside the `blorgh` directory, create a file called
`articles_controller.rb`. In this file, define a controller class that inherits
from the engine's `ArticlesController` and override any methods as needed. The
application will now use this custom controller instead of the default
controller provided by the engine.

#### Overriding Engine Models

To override the engine's models with custom models in the application, create a
directory called `blorgh` inside the `app/models` directory of the application.
Inside the `blorgh` directory, create a file called `article.rb`. In this file,
define a model class that inherits from the engine's `Article` model and
override any methods or add any additional methods as needed. The application
will now use this custom model instead of the default model provided by the
engine.
```ruby
def self.author_class
  @@author_class.constantize
end
```

위의 코드를 `set_author`에 적용하면 다음과 같이 됩니다:

```ruby
self.author = Blorgh.author_class.find_or_create_by(name: author_name)
```

결과적으로 코드가 조금 더 짧아지고 동작이 더 암묵적으로 표현됩니다. `author_class` 메소드는 항상 `Class` 객체를 반환해야 합니다.

`author_class` 메소드를 `String` 대신 `Class`를 반환하도록 변경했으므로, `Blorgh::Article` 모델의 `belongs_to` 정의도 수정해야 합니다:

```ruby
belongs_to :author, class_name: Blorgh.author_class.to_s
```

이 설정을 애플리케이션 내에서 설정하려면 초기화 파일을 사용해야 합니다. 초기화 파일을 사용하면 설정이 애플리케이션이 시작되기 전에 설정되며, 이 설정은 이 설정이 존재하는 것에 의존하는 엔진의 모델을 호출하는 애플리케이션이 시작되기 전에 설정됩니다.

`blorgh` 엔진이 설치된 애플리케이션 내에서 `config/initializers/blorgh.rb` 경로에 새로운 초기화 파일을 생성하고 다음 내용을 넣으세요:

```ruby
Blorgh.author_class = "User"
```

경고: 여기에서는 클래스의 `String` 버전을 사용하는 것이 매우 중요합니다. 클래스를 사용하면 Rails가 해당 클래스를 로드하고 관련 테이블을 참조하려고 시도합니다. 테이블이 이미 존재하지 않는 경우 문제가 발생할 수 있습니다. 따라서 `String`을 사용하고 나중에 엔진에서 `constantize`를 사용하여 클래스로 변환해야 합니다.

새로운 글을 작성해 보세요. 이전과 완전히 동일한 방식으로 작동하는 것을 볼 수 있습니다. 다만 이번에는 엔진이 `config/initializers/blorgh.rb`의 설정을 사용하여 클래스가 무엇인지 알아내는 것입니다.

이제 클래스가 무엇인지에 대한 엄격한 종속성은 없으며, 클래스의 API만 필요합니다. 엔진은 이 클래스가 `find_or_create_by` 메소드를 정의하고 해당 클래스의 객체를 반환하여 글이 작성될 때 글과 연결될 수 있도록 요구합니다. 물론 이 객체는 참조할 수 있는 식별자를 가져야 합니다.

#### 일반 엔진 설정

엔진 내에서 초기화, 국제화 또는 기타 설정 옵션을 사용하고 싶은 경우, 좋은 소식은 Rails 엔진이 Rails 애플리케이션과 거의 동일한 기능을 공유하기 때문에 이러한 기능을 완전히 사용할 수 있다는 것입니다. 사실, Rails 애플리케이션의 기능은 실제로 엔진이 제공하는 기능의 상위 집합입니다!

초기화 파일(엔진이 로드되기 전에 실행되어야 하는 코드)을 사용하려면 `config/initializers` 폴더에 넣으세요. 이 디렉토리의 기능은 [초기화 섹션](configuring.html#initializers)에서 Configuring 가이드에서 설명되며, 애플리케이션 내의 `config/initializers` 디렉토리와 동일한 방식으로 작동합니다. 표준 초기화 파일을 사용하려면 동일한 방식으로 사용하면 됩니다.

로케일의 경우, 로케일 파일을 애플리케이션과 마찬가지로 `config/locales` 디렉토리에 넣으세요.

엔진 테스트하기
-----------------

엔진을 생성할 때, 엔진 내에 작은 더미 애플리케이션이 `test/dummy`에 생성됩니다. 이 애플리케이션은 엔진을 테스트하기 매우 간단하게 만들기 위해 엔진을 마운트할 수 있는 지점으로 사용됩니다. 이 디렉토리 내에서 컨트롤러, 모델 또는 뷰를 생성하여 이를 사용하여 엔진을 테스트할 수 있습니다.

`test` 디렉토리는 일반적인 Rails 테스트 환경처럼 다루어져야 합니다. 유닛, 기능 및 통합 테스트를 수행할 수 있어야 합니다.

### 기능 테스트

기능 테스트를 작성할 때 고려해야 할 사항은 테스트가 엔진이 아닌 애플리케이션 - `test/dummy` 애플리케이션 -에서 실행된다는 것입니다. 이는 테스트 환경의 설정 때문에 발생합니다. 엔진은 주요 기능을 테스트하기 위해 애플리케이션을 호스트로 사용해야 하기 때문에 특히 컨트롤러와 같은 컨트롤러의 기능 테스트에서 일반적인 `GET`을 수행할 때 다음과 같이 작동하지 않을 수 있습니다:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def test_index
      get foos_url
      # ...
    end
  end
end
```

이는 애플리케이션이 이러한 요청을 엔진으로 라우팅하는 방법을 명시적으로 알려주지 않는 한 작동하지 않을 수 있습니다. 이를 위해 설정 코드에서 `@routes` 인스턴스 변수를 엔진의 라우트 세트로 설정해야 합니다:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_index
      get foos_url
      # ...
    end
  end
end
```
이는 응용 프로그램이 엔진의 경로를 사용하여 `index` 액션으로 `GET` 요청을 계속 수행하려는 것을 알려줍니다. 응용 프로그램의 경로 대신 엔진의 경로를 사용합니다.

이는 또한 테스트에서 엔진의 URL 도우미가 예상대로 작동하도록 보장합니다.

엔진 기능 개선
------------------------------

이 섹션에서는 주요 Rails 응용 프로그램에 엔진 MVC 기능을 추가하거나 재정의하는 방법을 설명합니다.

### 모델 및 컨트롤러 재정의

엔진 모델과 컨트롤러는 부모 응용 프로그램에서 확장하거나 장식하기 위해 다시 열 수 있습니다.

오버라이드는 `app/overrides`라는 전용 디렉토리에 구성할 수 있으며, 오토로더에서 무시되고 `to_prepare` 콜백에서 사전로드됩니다:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        load override
      end
    end
  end
end
```

#### `class_eval`을 사용하여 기존 클래스 다시 열기

예를 들어, 엔진 모델을 재정의하려면

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    # ...
  end
end
```

그냥 그 클래스를 _다시 열리게_하는 파일을 만들면 됩니다:

```ruby
# MyApp/app/overrides/models/blorgh/article_override.rb
Blorgh::Article.class_eval do
  # ...
end
```

오버라이드가 클래스나 모듈을 _다시 열리게_하는 것이 매우 중요합니다. `class`나 `module` 키워드를 사용하면 해당 클래스나 모듈이 메모리에 없는 경우에만 정의되므로 엔진에 정의가 있을 때는 올바르지 않습니다. 위에서 보여준대로 `class_eval`을 사용하면 다시 열리게 됩니다.

#### ActiveSupport::Concern을 사용하여 기존 클래스 다시 열기

`Class#class_eval`은 간단한 조정에는 좋지만, 더 복잡한 클래스 수정의 경우 [`ActiveSupport::Concern`](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)을 사용하는 것이 좋습니다. ActiveSupport::Concern은 런타임에서 상호 연결된 종속 모듈 및 클래스의 로드 순서를 관리하여 코드를 크게 모듈화할 수 있도록 해줍니다.

`Article#time_since_created`를 **추가**하고 `Article#summary`를 **재정의**하는 예제:

```ruby
# MyApp/app/models/blorgh/article.rb

class Blorgh::Article < ApplicationRecord
  include Blorgh::Concerns::Models::Article

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    include Blorgh::Concerns::Models::Article
  end
end
```

```ruby
# Blorgh/lib/concerns/models/article.rb

module Blorgh::Concerns::Models::Article
  extend ActiveSupport::Concern

  # `included do`는 모듈이 포함된 컨텍스트(즉, Blorgh::Article)에서 블록을 평가하도록합니다.
  # 모듈 자체에서 블록을 평가하는 것이 아닙니다.
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_validation :set_author

    private
      def set_author
        self.author = User.find_or_create_by(name: author_name)
      end
  end

  def summary
    "#{title}"
  end

  module ClassMethods
    def some_class_method
      'some class method string'
    end
  end
end
```

### 오토로딩과 엔진

오토로딩 및 상수 다시로드에 대한 자세한 내용은 [오토로딩 및 상수 다시로드](autoloading_and_reloading_constants.html#autoloading-and-engines) 가이드를 확인하십시오.


### 뷰 재정의

Rails는 렌더링할 뷰를 찾을 때 먼저 응용 프로그램의 `app/views` 디렉토리를 확인합니다. 그곳에서 뷰를 찾을 수 없는 경우 이 디렉토리를 가진 모든 엔진의 `app/views` 디렉토리를 확인합니다.

응용 프로그램이 `Blorgh::ArticlesController`의 인덱스 액션의 뷰를 렌더링하도록 요청받으면, 응용 프로그램은 먼저 응용 프로그램 내에서 경로 `app/views/blorgh/articles/index.html.erb`를 찾습니다. 그곳에서 찾을 수 없으면 엔진 내부에서 찾습니다.

응용 프로그램에서 이 뷰를 재정의하려면 단순히 `app/views/blorgh/articles/index.html.erb`에 새 파일을 만들면 됩니다. 그런 다음 이 뷰가 일반적으로 출력하는 내용을 완전히 변경할 수 있습니다.

지금 `app/views/blorgh/articles/index.html.erb`에 새 파일을 만들고 다음 내용을 넣어보세요:

```html+erb
<h1>Articles</h1>
<%= link_to "New Article", new_article_path %>
<% @articles.each do |article| %>
  <h2><%= article.title %></h2>
  <small>By <%= article.author %></small>
  <%= simple_format(article.text) %>
  <hr>
<% end %>
```

### 라우트

엔진 내부의 라우트는 기본적으로 응용 프로그램과 격리됩니다. 이는 `Engine` 클래스 내부의 `isolate_namespace` 호출에 의해 수행됩니다. 이는 응용 프로그램과 엔진이 동일한 이름의 경로를 가질 수 있고 충돌하지 않습니다.

엔진 내부의 라우트는 다음과 같이 `config/routes.rb` 내부의 `Engine` 클래스에서 그려집니다:

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

이와 같이 격리된 경로를 가지고 있기 때문에 응용 프로그램 내에서 엔진의 영역에 링크를 거는 경우 엔진의 라우팅 프록시 메서드를 사용해야 합니다. `articles_path`와 같은 일반적인 라우팅 메서드 호출은 응용 프로그램과 엔진 모두 해당 도우미가 정의되어 있으면 원하지 않는 위치로 이동할 수 있습니다.

예를 들어, 다음 예제는 응용 프로그램에서 렌더링된 경우 응용 프로그램의 `articles_path`로 이동하거나 엔진에서 렌더링된 경우 엔진의 `articles_path`로 이동합니다.
```erb
<%= link_to "블로그 글", articles_path %>
```

이 경로가 항상 엔진의 `articles_path` 라우팅 헬퍼 메서드를 사용하도록 하려면,
같은 이름을 공유하는 라우팅 프록시 메서드에서 해당 메서드를 호출해야 합니다.

```erb
<%= link_to "블로그 글", blorgh.articles_path %>
```

엔진 내에서 애플리케이션을 참조하려면 `main_app` 헬퍼를 사용하세요:

```erb
<%= link_to "홈", main_app.root_path %>
```

엔진 내에서 이를 사용하면 **항상** 애플리케이션의 루트로 이동합니다. `main_app` "라우팅 프록시" 메서드 호출을 생략하면, 호출된 위치에 따라 엔진 또는 애플리케이션의 루트로 이동할 수 있습니다.

엔진 내에서 렌더링된 템플릿이 애플리케이션의 라우팅 헬퍼 메서드 중 하나를 사용하려고 시도하면 정의되지 않은 메서드 호출로 이어질 수 있습니다. 이러한 문제가 발생하는 경우, 엔진 내부에서 `main_app` 접두사 없이 애플리케이션의 라우팅 메서드를 호출하지 않는지 확인하세요.

### 에셋

엔진 내의 에셋은 전체 애플리케이션과 동일한 방식으로 작동합니다. 엔진 클래스가 `Rails::Engine`을 상속하기 때문에, 애플리케이션은 엔진의 `app/assets` 및 `lib/assets` 디렉토리에서 에셋을 찾을 수 있습니다.

엔진의 다른 구성 요소와 마찬가지로, 에셋은 네임스페이스화되어야 합니다. 즉, `style.css`라는 에셋이 있다면 `app/assets/stylesheets/[엔진 이름]/style.css`에 배치되어야 합니다. 이 에셋이 네임스페이스화되지 않은 경우, 호스트 애플리케이션에 동일한 이름의 에셋이 있을 수 있으므로 애플리케이션의 에셋이 우선되고 엔진의 에셋은 무시됩니다.

예를 들어, `app/assets/stylesheets/blorgh/style.css`에 위치한 에셋이 있다고 가정해 봅시다. 이 에셋을 애플리케이션 내에서 포함시키려면, `stylesheet_link_tag`를 사용하고 엔진 내부에 있는 것처럼 에셋을 참조하면 됩니다:

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

또한 처리된 파일에서 Asset Pipeline require 문을 사용하여 이러한 에셋을 다른 에셋의 종속성으로 지정할 수도 있습니다:

```css
/*
 *= require blorgh/style
 */
```

INFO. Sass 또는 CoffeeScript와 같은 언어를 사용하려면, 엔진의 `.gemspec`에 해당 라이브러리를 추가해야 합니다.

### 에셋과 사전 컴파일

엔진의 에셋이 호스트 애플리케이션에서 필요하지 않은 경우도 있습니다. 예를 들어, 엔진에만 존재하는 관리자 기능을 만들었다고 가정해 봅시다. 이 경우, 호스트 애플리케이션은 `admin.css` 또는 `admin.js`를 요구하지 않아도 됩니다. 오직 젬의 관리자 레이아웃만 이러한 에셋이 필요합니다. 호스트 앱이 `"blorgh/admin.css"`를 스타일시트에 포함시키는 것은 의미가 없습니다. 이 상황에서는 사전 컴파일을 위해 이러한 에셋을 명시적으로 정의해야 합니다. 이렇게 하면 `bin/rails assets:precompile`이 실행될 때 Sprockets가 엔진 에셋을 추가합니다.

`engine.rb`에서 사전 컴파일을 위해 에셋을 정의할 수 있습니다:

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile += %w( admin.js admin.css )
end
```

자세한 내용은 [Asset Pipeline 가이드](asset_pipeline.html)를 참조하세요.

### 다른 젬 종속성

엔진 내에서 젬 종속성은 엔진의 루트에 있는 `.gemspec` 파일 내에서 지정해야 합니다. 그 이유는 엔진이 젬으로 설치될 수 있기 때문입니다. 종속성을 `Gemfile` 내에 지정하면 전통적인 젬 설치에서 인식되지 않으므로 설치되지 않고 엔진이 제대로 작동하지 않을 수 있습니다.

전통적인 `gem install` 중에 엔진과 함께 설치되어야 하는 종속성을 지정하려면, 엔진의 `.gemspec` 파일 내의 `Gem::Specification` 블록 안에 지정하세요:

```ruby
s.add_dependency "moo"
```

애플리케이션의 개발 종속성으로만 설치되어야 하는 종속성을 지정하려면 다음과 같이 지정하세요:

```ruby
s.add_development_dependency "moo"
```

두 종류의 종속성은 애플리케이션 내에서 `bundle install`을 실행할 때 모두 설치됩니다. 젬의 개발 종속성은 엔진의 개발 및 테스트가 실행될 때에만 사용됩니다.

엔진이 필요할 때 즉시 종속성을 요구하려면 엔진의 초기화 이전에 종속성을 요구해야 합니다. 예를 들어:

```ruby
require "other_engine/engine"
require "yet_another_engine/engine"

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```

로드 및 구성 훅
----------------------------

Rails 코드는 종종 애플리케이션의 로드 시 참조될 수 있습니다. Rails는 이러한 프레임워크의 로드 순서를 관리하기 때문에, `ActiveRecord::Base`와 같은 프레임워크를 미리 로드하면 애플리케이션이 Rails와의 암묵적 계약을 위반합니다. 또한, 애플리케이션의 부팅 시 `ActiveRecord::Base`와 같은 코드를 로드하면 부팅 시간이 느려지고 로드 순서와 부팅에 충돌이 발생할 수 있습니다.
로드 및 구성 훅은 Rails와의 로드 계약을 위반하지 않고 이 초기화 프로세스에 훅을 걸 수 있는 API입니다. 이를 통해 부팅 성능 저하를 완화하고 충돌을 피할 수 있습니다.

### Rails 프레임워크 로딩 피하기

루비는 동적 언어이기 때문에 일부 코드는 다른 Rails 프레임워크를 로드할 수 있습니다. 예를 들어 다음 스니펫을 살펴보세요:

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

이 스니펫은 이 파일이 로드될 때 `ActiveRecord::Base`를 만나게 됩니다. 이 만남은 루비가 해당 상수의 정의를 찾아서 요구하게 됩니다. 이로 인해 전체 Active Record 프레임워크가 부팅 시 로드됩니다.

`ActiveSupport.on_load`는 코드 로딩을 실제로 필요할 때까지 지연시킬 수 있는 메커니즘입니다. 위의 스니펫은 다음과 같이 변경할 수 있습니다:

```ruby
ActiveSupport.on_load(:active_record) do
  include MyActiveRecordHelper
end
```

이 새로운 스니펫은 `ActiveRecord::Base`가 로드될 때만 `MyActiveRecordHelper`를 포함합니다.

### 훅이 언제 호출되나요?

Rails 프레임워크에서 이러한 훅은 특정 라이브러리가 로드될 때 호출됩니다. 예를 들어, `ActionController::Base`가 로드될 때 `:action_controller_base` 훅이 호출됩니다. 이는 `:action_controller_base` 훅을 가진 모든 `ActiveSupport.on_load` 호출이 `ActionController::Base`의 컨텍스트에서 호출된다는 것을 의미합니다 (`self`는 `ActionController::Base`가 됩니다).

### 로드 훅 사용으로 코드 수정하기

코드 수정은 일반적으로 간단합니다. `ActiveRecord::Base`와 같은 Rails 프레임워크를 참조하는 코드 라인이 있다면 해당 코드를 로드 훅으로 래핑할 수 있습니다.

**`include` 호출 수정하기**

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

다음과 같이 변경됩니다:

```ruby
ActiveSupport.on_load(:active_record) do
  # 여기서 self는 ActiveRecord::Base를 참조하므로
  # .include를 호출할 수 있습니다.
  include MyActiveRecordHelper
end
```

**`prepend` 호출 수정하기**

```ruby
ActionController::Base.prepend(MyActionControllerHelper)
```

다음과 같이 변경됩니다:

```ruby
ActiveSupport.on_load(:action_controller_base) do
  # 여기서 self는 ActionController::Base를 참조하므로
  # .prepend를 호출할 수 있습니다.
  prepend MyActionControllerHelper
end
```

**클래스 메서드 호출 수정하기**

```ruby
ActiveRecord::Base.include_root_in_json = true
```

다음과 같이 변경됩니다:

```ruby
ActiveSupport.on_load(:active_record) do
  # 여기서 self는 ActiveRecord::Base를 참조합니다.
  self.include_root_in_json = true
end
```

### 사용 가능한 로드 훅

다음은 사용자 코드에서 사용할 수 있는 로드 훅입니다. 다음 클래스의 초기화 프로세스에 훅을 걸기 위해 사용 가능한 훅을 사용하세요.

| 클래스                                | 훅                                 |
| -------------------------------------| ------------------------------------ |
| `ActionCable`                        | `action_cable`                       |
| `ActionCable::Channel::Base`         | `action_cable_channel`               |
| `ActionCable::Connection::Base`      | `action_cable_connection`            |
| `ActionCable::Connection::TestCase`  | `action_cable_connection_test_case`  |
| `ActionController::API`              | `action_controller_api`              |
| `ActionController::API`              | `action_controller`                  |
| `ActionController::Base`             | `action_controller_base`             |
| `ActionController::Base`             | `action_controller`                  |
| `ActionController::TestCase`         | `action_controller_test_case`        |
| `ActionDispatch::IntegrationTest`    | `action_dispatch_integration_test`   |
| `ActionDispatch::Response`           | `action_dispatch_response`           |
| `ActionDispatch::Request`            | `action_dispatch_request`            |
| `ActionDispatch::SystemTestCase`     | `action_dispatch_system_test_case`   |
| `ActionMailbox::Base`                | `action_mailbox`                     |
| `ActionMailbox::InboundEmail`        | `action_mailbox_inbound_email`       |
| `ActionMailbox::Record`              | `action_mailbox_record`              |
| `ActionMailbox::TestCase`            | `action_mailbox_test_case`           |
| `ActionMailer::Base`                 | `action_mailer`                      |
| `ActionMailer::TestCase`             | `action_mailer_test_case`            |
| `ActionText::Content`                | `action_text_content`                |
| `ActionText::Record`                 | `action_text_record`                 |
| `ActionText::RichText`               | `action_text_rich_text`              |
| `ActionText::EncryptedRichText`      | `action_text_encrypted_rich_text`    |
| `ActionView::Base`                   | `action_view`                        |
| `ActionView::TestCase`               | `action_view_test_case`              |
| `ActiveJob::Base`                    | `active_job`                         |
| `ActiveJob::TestCase`                | `active_job_test_case`               |
| `ActiveRecord::Base`                 | `active_record`                      |
| `ActiveRecord::TestFixtures`         | `active_record_fixtures`             |
| `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter`    | `active_record_postgresqladapter`    |
| `ActiveRecord::ConnectionAdapters::Mysql2Adapter`        | `active_record_mysql2adapter`        |
| `ActiveRecord::ConnectionAdapters::TrilogyAdapter`       | `active_record_trilogyadapter`       |
| `ActiveRecord::ConnectionAdapters::SQLite3Adapter`       | `active_record_sqlite3adapter`       |
| `ActiveStorage::Attachment`          | `active_storage_attachment`          |
| `ActiveStorage::VariantRecord`       | `active_storage_variant_record`      |
| `ActiveStorage::Blob`                | `active_storage_blob`                |
| `ActiveStorage::Record`              | `active_storage_record`              |
| `ActiveSupport::TestCase`            | `active_support_test_case`           |
| `i18n`                               | `i18n`                               |

### 사용 가능한 구성 훅

구성 훅은 특정 프레임워크에 훅되지 않고 전체 애플리케이션의 컨텍스트에서 실행됩니다.

| 훅                   | 사용 사례                                                                           |
| ---------------------- | ---------------------------------------------------------------------------------- |
| `before_configuration` | 초기화자가 실행되기 전에 실행되는 첫 번째 구성 가능 블록입니다.           |
| `before_initialize`    | 프레임워크가 초기화되기 전에 실행되는 두 번째 구성 가능 블록입니다.             |
| `before_eager_load`    | [`config.eager_load`][]가 false로 설정되어 있지 않은 경우에만 실행되는 세 번째 구성 가능 블록입니다. |
| `after_initialize`     | 프레임워크가 초기화된 후에 실행되는 마지막 구성 가능 블록입니다.                |

구성 훅은 Engine 클래스에서 호출할 수 있습니다.

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    config.before_configuration do
      puts 'I am called before any initializers'
    end
  end
end
```
[`config.eager_load`]: configuring.html#config-eager-load
