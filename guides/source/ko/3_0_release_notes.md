**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: dd2584972aa8eae419ed5d55a287e27d
Ruby on Rails 3.0 릴리스 노트
===============================

Rails 3.0은 포니와 무지개입니다! 그것은 당신에게 저녁 식사를 해주고 빨래를 접어줄 것입니다. 그것이 도착하기 전에 어떻게 생활이 가능했는지 궁금해 할 것입니다. 이것은 우리가 지금까지 한 가장 좋은 버전의 Rails입니다!

하지만 정말로, 이것은 정말 좋은 것입니다. Merb 팀이 합류하면서 가져온 좋은 아이디어들, 프레임워크 중립성에 대한 초점, 가볍고 빠른 내부, 그리고 맛있는 API가 모두 포함되어 있습니다. Merb 1.x에서 Rails 3.0으로 오신 경우 많은 부분을 알아볼 수 있을 것입니다. Rails 2.x에서 오신 경우에도 마찬가지로 좋아하실 것입니다.

우리의 내부 정리에 관심이 없더라도, Rails 3.0은 기쁨을 줄 것입니다. 우리는 새로운 기능과 개선된 API를 가지고 있습니다. Rails 개발자로서 지금이 가장 좋은 시기입니다. 일부 하이라이트는 다음과 같습니다:

* RESTful 선언에 중점을 둔 새로운 라우터
* Action Controller를 모델로 한 새로운 Action Mailer API (이제 멀티파트 메시지를 보내는 고통이 없습니다!)
* 관계 대수 위에 구축된 새로운 Active Record 체인 가능한 쿼리 언어
* Prototype, jQuery 등을 위한 드라이버가 있는 비침입적인 JavaScript 도우미 (인라인 JS의 끝)
* Bundler를 사용한 명시적인 종속성 관리

이 모든 것에 더해, 우리는 예쁜 경고와 함께 이전 API를 폐기하려고 최선을 다했습니다. 이것은 기존 애플리케이션을 최신의 모범 사례로 전부 다시 작성하지 않고도 Rails 3로 이전할 수 있다는 것을 의미합니다.

이 릴리스 노트는 주요 업그레이드를 다루지만, 모든 작은 버그 수정과 변경 사항은 포함되어 있지 않습니다. Rails 3.0은 250명 이상의 작성자에 의해 거의 4,000개의 커밋으로 구성됩니다! 모든 것을 보려면 GitHub의 주요 Rails 저장소의 [커밋 목록](https://github.com/rails/rails/commits/3-0-stable)을 확인하십시오.

--------------------------------------------------------------------------------

Rails 3를 설치하려면:

```bash
# 설정에 따라 sudo를 사용하세요
$ gem install rails
```


Rails 3으로 업그레이드하기
--------------------

기존 애플리케이션을 업그레이드하는 경우, 진행하기 전에 좋은 테스트 커버리지를 갖는 것이 좋습니다. 또한 먼저 Rails 2.3.5로 업그레이드하고 애플리케이션이 예상대로 실행되는지 확인한 후에 Rails 3로 업데이트를 시도해야 합니다. 그런 다음 다음 변경 사항을 주의해야 합니다:

### Rails 3는 적어도 Ruby 1.8.7을 필요로 합니다

Rails 3.0은 Ruby 1.8.7 이상을 필요로 합니다. 이전 Ruby 버전의 지원은 공식적으로 중단되었으며 가능한 빨리 업그레이드해야 합니다. Rails 3.0은 또한 Ruby 1.9.2와 호환됩니다.

팁: Ruby 1.8.7 p248 및 p249에는 Rails 3.0을 충돌시키는 마샬링 버그가 있습니다. Ruby Enterprise Edition은 1.8.7-2010.02 릴리스 이후로 이를 수정했습니다. 1.9 버전에서는 Rails 3.0에서 바로 세그폴트가 발생하기 때문에 Ruby 1.9.1은 사용할 수 없습니다. 따라서 1.9.x에서 Rails 3를 사용하려면 원활한 작업을 위해 1.9.2로 전환해야 합니다.

### Rails Application 객체

동일한 프로세스에서 여러 개의 Rails 애플리케이션을 실행할 수 있도록 지원하기 위한 기초 작업의 일환으로, Rails 3에서는 Application 객체 개념을 도입합니다. 애플리케이션 객체는 모든 애플리케이션별 구성을 보유하며 이전 버전의 Rails의 `config/environment.rb`와 매우 유사한 성격을 가지고 있습니다.

이제 각 Rails 애플리케이션은 해당하는 애플리케이션 객체를 가져야 합니다. 애플리케이션 객체는 `config/application.rb`에 정의됩니다. 기존 애플리케이션을 Rails 3로 업그레이드하는 경우, 이 파일을 추가하고 `config/environment.rb`에서 적절한 구성을 `config/application.rb`로 이동해야 합니다.

### script/*이 script/rails로 대체됨

새로운 `script/rails`는 이전에 `script` 디렉토리에 있던 모든 스크립트를 대체합니다. 그러나 직접 `script/rails`를 실행하지는 않습니다. `rails` 명령은 Rails 애플리케이션의 루트에서 호출되었는지 감지하고 스크립트를 실행합니다. 의도된 사용법은 다음과 같습니다:

```bash
$ rails console                      # script/console 대신 사용
$ rails g scaffold post title:string # script/generate scaffold post title:string 대신 사용
```

모든 옵션의 목록을 보려면 `rails --help`를 실행하세요.

### 종속성과 config.gem

`config.gem` 메서드는 사라지고 `bundler`와 `Gemfile`을 사용하여 대체되었습니다. [Vendoring Gems](#vendoring-gems)을 참조하세요.

### 업그레이드 프로세스

업그레이드 프로세스를 돕기 위해 [Rails Upgrade](https://github.com/rails/rails_upgrade)라는 플러그인이 만들어졌습니다.

플러그인을 설치한 후 `rake rails:upgrade:check`를 실행하여 업데이트해야 할 부분을 확인할 수 있습니다(업데이트 방법에 대한 정보 링크 포함). 또한 현재 `config.gem` 호출을 기반으로 `Gemfile`을 생성하는 작업과 현재 라우트 파일에서 새로운 라우트 파일을 생성하는 작업을 제공합니다. 플러그인을 얻으려면 다음을 실행하세요:
```bash
$ ruby script/plugin install git://github.com/rails/rails_upgrade.git
```

이 작업이 어떻게 작동하는지 예제를 [Rails Upgrade is now an Official Plugin](http://omgbloglol.com/post/364624593/rails-upgrade-is-now-an-official-plugin)에서 확인할 수 있습니다.

Rails Upgrade 도구 외에도 도움이 필요한 경우, IRC와 [rubyonrails-talk](https://discuss.rubyonrails.org/c/rubyonrails-talk)에서 동일한 작업을 수행하고 동일한 문제를 겪고 있는 사람들이 있을 수 있습니다. 업그레이드하는 동안 자신의 경험을 블로그에 기록하여 다른 사람들이 지식을 공유할 수 있도록 해주세요!

Rails 3.0 애플리케이션 생성
--------------------------------

```bash
# 'rails' RubyGem이 설치되어 있어야 합니다.
$ rails new myapp
$ cd myapp
```

### Gems 벤더링

Rails는 이제 애플리케이션 시작에 필요한 젬을 결정하기 위해 애플리케이션 루트에 `Gemfile`을 사용합니다. 이 `Gemfile`은 [Bundler](https://github.com/bundler/bundler)에 의해 처리되어 모든 종속성이 설치됩니다. 심지어 애플리케이션에 종속성을 로컬로 설치하여 시스템 젬에 의존하지 않도록 할 수도 있습니다.

자세한 정보: - [bundler 홈페이지](https://bundler.io/)

### 최신 버전 사용하기

`Bundler`와 `Gemfile`을 사용하면 새로운 `bundle` 명령을 통해 Rails 애플리케이션을 쉽게 동결할 수 있으므로 `rake freeze`는 더 이상 관련이 없어졌습니다.

Git 저장소에서 직접 번들을 만들려면 `--edge` 플래그를 전달할 수 있습니다.

```bash
$ rails new myapp --edge
```

로컬에서 Rails 저장소를 체크아웃하고 해당 저장소를 사용하여 애플리케이션을 생성하려면 `--dev` 플래그를 전달할 수 있습니다.

```bash
$ ruby /path/to/rails/bin/rails new myapp --dev
```

Rails 아키텍처 변경 사항
---------------------------

Rails의 아키텍처에는 여섯 가지 주요 변경 사항이 있습니다.

### Railties 재구성

Railties는 전체 Rails 프레임워크에 대한 일관된 플러그인 API를 제공하도록 업데이트되었으며, 생성기와 Rails 바인딩의 완전한 재작성을 포함하여 개발자는 이제 생성기와 응용 프로그램 프레임워크의 모든 중요한 단계에 일관되고 정의된 방식으로 연결할 수 있습니다.

### 모든 Rails 핵심 구성 요소가 분리되었습니다.

Merb와 Rails의 병합을 통해 Rails 핵심 구성 요소 간의 강한 결합을 제거하는 작업 중 하나였습니다. 이제 이 작업이 완료되어 모든 Rails 핵심 구성 요소가 플러그인 개발에 사용할 수 있는 동일한 API를 사용하고 있습니다. 이는 만든 플러그인이나 DataMapper 또는 Sequel과 같은 핵심 구성 요소 대체가 Rails 핵심 구성 요소가 사용할 수 있는 모든 기능에 액세스하고 확장할 수 있음을 의미합니다.

### Active Model 추상화

핵심 구성 요소의 분리 작업 중 일부는 Active Record와 Action Pack 사이의 모든 연결을 제거하는 것이었습니다. 이 작업은 이제 완료되었습니다. 새로운 ORM 플러그인은 이제 Active Model 인터페이스를 구현하기만 하면 Action Pack과 원활하게 작동할 수 있습니다.

### 컨트롤러 추상화

핵심 구성 요소의 분리 작업 중 또 다른 큰 부분은 HTTP 개념과 분리된 기본 슈퍼클래스를 생성하여 뷰의 렌더링 등을 처리하는 것이었습니다. `AbstractController`의 생성을 통해 `ActionController`와 `ActionMailer`를 크게 단순화할 수 있었으며, 이를 통해 모든 라이브러리에서 공통 코드를 제거하고 Abstract Controller로 이동할 수 있었습니다.

### Arel 통합

[Arel](https://github.com/brynary/arel) (또는 Active Relation)은 Active Record의 기반이 되어 Rails에서 필요로 합니다. Arel은 Active Record를 단순화하는 SQL 추상화를 제공하며, Active Record의 관계 기능의 기반이 됩니다.

### 메일 추출

Action Mailer는 처음부터 몽키 패치, 사전 구문 분석기, 전송 및 수신 대리인을 가지고 있었으며, 소스 트리에 TMail을 벤더링한 것 외에도 많은 이메일 메시지 관련 기능이 포함되어 있었습니다. 버전 3에서는 모든 이메일 메시지 관련 기능을 [Mail](https://github.com/mikel/mail) 젬으로 추상화했습니다. 이를 통해 코드 중복이 줄어들고 Action Mailer와 이메일 파서 사이에 정의 가능한 경계를 만들 수 있습니다.

문서화
-------------

Rails 트리의 문서는 모든 API 변경 사항과 함께 업데이트되고 있으며, [Rails Edge Guides](https://edgeguides.rubyonrails.org/)는 하나씩 업데이트되어 Rails 3.0의 변경 사항을 반영하고 있습니다. 그러나 [guides.rubyonrails.org](https://guides.rubyonrails.org/)의 가이드는 안정 버전의 Rails만 계속 포함할 것이며 (현재 버전 2.3.5), 3.0이 출시될 때까지 업데이트되지 않을 것입니다.

자세한 정보: - [Rails 문서화 프로젝트](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)
국제화
--------------------

Rails 3에서는 I18n 지원을 위해 많은 작업이 이루어졌으며, 최신 [I18n](https://github.com/svenfuchs/i18n) 젬을 통해 많은 속도 향상이 이루어졌습니다.

* I18n을 어떤 객체에도 추가할 수 있습니다. `ActiveModel::Translation`과 `ActiveModel::Validations`를 포함하여 객체에 I18n 동작을 추가할 수 있습니다. 또한 번역을 위한 `errors.messages` 대체 기능도 제공됩니다.
* 속성에는 기본 번역을 설정할 수 있습니다.
* Form Submit 태그는 객체의 상태에 따라 올바른 상태 (생성 또는 업데이트)를 자동으로 가져오고, 따라서 올바른 번역을 가져옵니다.
* I18n을 사용한 레이블은 이제 속성 이름만 전달하여 작동합니다.

추가 정보: - [Rails 3 I18n 변경 사항](http://blog.plataformatec.com.br/2010/02/rails-3-i18n-changes/)


Railties
--------

주요 Rails 프레임워크의 분리로 인해 Railties는 큰 개편을 거쳐 다른 프레임워크, 엔진 또는 플러그인을 연결하는 것이 가능하고 확장 가능하도록 되었습니다.

* 각 애플리케이션은 이제 자체 네임 스페이스를 가지며, 예를 들어 `YourAppName.boot`으로 애플리케이션을 시작하면 다른 애플리케이션과의 상호 작용이 훨씬 쉬워집니다.
* `Rails.root/app` 아래에 있는 모든 것이 로드 경로에 추가되므로 `app/observers/user_observer.rb`를 만들면 Rails에서 수정 없이 로드합니다.
* Rails 3.0은 모든 종류의 Rails 전역 구성 옵션을 중앙 저장소로 제공하는 `Rails.config` 객체를 제공합니다.

    응용 프로그램 생성에는 test-unit, Active Record, Prototype 및 Git 설치를 건너뛰는 추가 플래그가 추가되었습니다. 또한 새로운 `--dev` 플래그가 추가되어 `Gemfile`이 Rails 체크아웃을 가리키도록 애플리케이션을 설정합니다 (이는 `rails` 바이너리의 경로에 따라 결정됩니다). 자세한 내용은 `rails --help`를 참조하십시오.

Railties 생성기는 Rails 3.0에서 큰 관심을 받았으며, 기본적으로 다음과 같습니다:

* 생성기가 완전히 다시 작성되어 하위 호환성이 없어졌습니다.
* Rails 템플릿 API와 생성기 API가 병합되었습니다 (이전과 동일합니다).
* 생성기는 더 이상 특수 경로에서 로드되지 않으며, Ruby 로드 경로에서 찾습니다. 따라서 `rails generate foo`를 호출하면 `generators/foo_generator`를 찾습니다.
* 새로운 생성기는 후크를 제공하여 템플릿 엔진, ORM, 테스트 프레임워크 등이 쉽게 연결할 수 있습니다.
* 새로운 생성기를 사용하여 `Rails.root/lib/templates`에 복사본을 배치하여 템플릿을 재정의할 수 있습니다.
* `Rails::Generators::TestCase`도 제공되어 직접 생성기를 만들고 테스트할 수 있습니다.

또한, Railties 생성기에 의해 생성된 뷰에는 몇 가지 개선 사항이 있습니다:

* 뷰는 이제 `div` 태그 대신 `p` 태그를 사용합니다.
* 생성된 스캐폴드는 이제 편집 및 새로운 뷰에서 중복 코드 대신 `_form` 부분을 사용합니다.
* 스캐폴드 폼은 `f.submit`을 사용하여 객체의 상태에 따라 "Create ModelName" 또는 "Update ModelName"을 반환합니다.

마지막으로 몇 가지 개선 사항이 rake 작업에 추가되었습니다:

* `rake db:forward`가 추가되어 마이그레이션을 개별적으로 또는 그룹으로 진행할 수 있습니다.
* `rake routes CONTROLLER=x`가 추가되어 한 컨트롤러의 라우트만 볼 수 있습니다.

Railties는 이제 다음을 사용하지 않도록 권장합니다:

* `RAILS_ROOT` 대신 `Rails.root`,
* `RAILS_ENV` 대신 `Rails.env`, 그리고
* `RAILS_DEFAULT_LOGGER` 대신 `Rails.logger`.

`PLUGIN/rails/tasks` 및 `PLUGIN/tasks`는 더 이상 로드되지 않으며, 모든 작업은 이제 `PLUGIN/lib/tasks`에 있어야 합니다.

추가 정보:

* [Rails 3 생성기 탐색](http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators)
* [Rails 모듈 (Rails 3에서)](http://quaran.to/blog/2010/02/03/the-rails-module/)

Action Pack
-----------

Action Pack에서는 중요한 내부 및 외부 변경 사항이 있었습니다.


### 추상 컨트롤러

추상 컨트롤러는 Action Controller의 일반적인 부분을 추출하여 재사용 가능한 모듈로 만들었습니다. 이 모듈은 어떤 라이브러리든 템플릿 렌더링, 부분 렌더링, 헬퍼, 번역, 로깅, 요청 응답 주기의 어떤 부분이든 사용할 수 있습니다. 이 추상화를 통해 `ActionMailer::Base`가 이제 `AbstractController`를 상속하고 Rails DSL을 Mail 젬에 래핑하는 것이 가능해졌습니다.

또한, Action Controller를 정리하기 위해 코드를 단순화하기 위해 추상 컨트롤러를 사용했습니다.

그러나 추상 컨트롤러는 사용자가 직접 사용하는 API가 아니므로 일상적인 Rails 사용에서는 이를 마주치지 않을 것입니다.

추가 정보: - [Rails Edge 아키텍처](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### 액션 컨트롤러

* `application_controller.rb`에서는 이제 기본적으로 `protect_from_forgery`가 활성화되어 있습니다.
* `cookie_verifier_secret`는 폐기되었으며, 대신 `Rails.application.config.cookie_secret`를 통해 할당되고 `config/initializers/cookie_verification_secret.rb`로 이동되었습니다.
* `session_store`는 `ActionController::Base.session`에서 구성되었으며, 이제 `Rails.application.config.session_store`로 이동되었습니다. 기본값은 `config/initializers/session_store.rb`에 설정되어 있습니다.
* `cookies.secure`를 사용하여 쿠키에 암호화된 값을 설정할 수 있습니다. `cookie.secure[:key] => value`와 같은 방식으로 암호화된 값 설정이 가능합니다.
* `cookies.permanent`를 사용하여 쿠키 해시에 영구적인 값을 설정할 수 있습니다. `cookie.permanent[:key] => value`는 검증 실패 시 서명된 값에 대해 예외를 발생시킵니다.
* 이제 `:notice => 'This is a flash message'` 또는 `:alert => 'Something went wrong'`를 `respond_to` 블록 내부의 `format` 호출에 전달할 수 있습니다. `flash[]` 해시는 이전과 동일하게 작동합니다.
* 컨트롤러에 `respond_with` 메서드가 추가되어 기존의 `format` 블록을 간소화합니다.
* `ActionController::Responder`가 추가되어 응답 생성 방식을 유연하게 설정할 수 있습니다.
폐기 사항:

* `filter_parameter_logging`은 `config.filter_parameters << :password`를 사용하기 위해 폐기되었습니다.

추가 정보:

* [Rails 3에서 렌더 옵션](https://blog.engineyard.com/2010/render-options-in-rails-3)
* [ActionController::Responder를 사랑하는 세 가지 이유](https://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder)


### Action Dispatch

Action Dispatch는 Rails 3.0에서 새롭게 도입되었으며, 라우팅에 대한 새로운, 더 깨끗한 구현을 제공합니다.

* 라우터의 큰 정리 및 재작성, Rails 라우터는 이제 독립적인 소프트웨어인 `rack_mount`로, 위에는 Rails DSL이 있는 것입니다.
* 각 애플리케이션에서 정의된 라우트는 이제 애플리케이션 모듈 내에서 이름 공간으로 정의됩니다. 예를 들어:

    ```ruby
    # 이전:

    ActionController::Routing::Routes.draw do |map|
      map.resources :posts
    end

    # 이제:

    AppName::Application.routes do
      resources :posts
    end
    ```

* 라우터에 `match` 메서드를 추가하였으며, 일치하는 라우트에는 어떤 Rack 애플리케이션도 전달할 수 있습니다.
* 라우터에 `constraints` 메서드를 추가하였으며, 정의된 제약 조건으로 라우터를 보호할 수 있습니다.
* 라우터에 `scope` 메서드를 추가하였으며, 다른 언어나 다른 액션을 위해 라우트에 이름 공간을 지정할 수 있습니다. 예를 들어:

    ```ruby
    scope 'es' do
      resources :projects, :path_names => { :edit => 'cambiar' }, :path => 'proyecto'
    end

    # /es/proyecto/1/cambiar로 edit 액션을 얻을 수 있습니다.
    ```

* 라우터에 `root` 메서드를 추가하였으며, `match '/', :to => path`의 단축키로 사용할 수 있습니다.
* 일치하는 라우트에 선택적 세그먼트를 전달할 수 있으며, 예를 들어 `match "/:controller(/:action(/:id))(.:format)"`와 같이 각 괄호로 묶인 세그먼트는 선택적입니다.
* 블록을 통해 라우트를 표현할 수 있으며, 예를 들어 `controller :home { match '/:action' }`와 같이 호출할 수 있습니다.

참고. 이전 스타일의 `map` 명령은 여전히 이전과 같이 작동하지만, 이는 3.1 버전에서 제거될 예정입니다.

폐기 사항

* REST가 아닌 애플리케이션을 위한 catch all 라우트 (`/:controller/:action/:id`)는 이제 주석 처리되었습니다.
* 라우트 `:path_prefix`는 더 이상 존재하지 않으며, `:name_prefix`는 주어진 값 끝에 "_"를 자동으로 추가합니다.

추가 정보:
* [Rails 3 라우터: Rack it Up](http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/)
* [Rails 3에서 개편된 라우트](https://medium.com/fusion-of-thoughts/revamped-routes-in-rails-3-b6d00654e5b0)
* [Rails 3에서 일반적인 액션](http://yehudakatz.com/2009/12/20/generic-actions-in-rails-3/)


### Action View

#### Unobtrusive JavaScript

Action View 헬퍼에서는 주요한 재작성이 이루어져 Unobtrusive JavaScript (UJS) 훅을 구현하고 이전의 인라인 AJAX 명령을 제거하였습니다. 이로써 Rails는 호환되는 UJS 드라이버를 사용하여 헬퍼에서 UJS 훅을 구현할 수 있게 되었습니다.

이전의 `remote_<method>` 헬퍼들은 Rails 코어에서 제거되고 [Prototype Legacy Helper](https://github.com/rails/prototype_legacy_helper)로 이동되었습니다. HTML에 UJS 훅을 넣기 위해서는 이제 `:remote => true`를 전달하면 됩니다. 예를 들어:

```ruby
form_for @post, :remote => true
```

다음과 같이 생성됩니다:

```html
<form action="http://host.com" id="create-post" method="post" data-remote="true">
```

#### 블록을 사용하는 헬퍼

`form_for`나 `div_for`와 같이 블록에서 콘텐츠를 삽입하는 헬퍼들은 이제 `<%=`를 사용합니다:

```html+erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

이와 같은 종류의 사용자 정의 헬퍼는 출력 버퍼에 직접 추가하는 대신 문자열을 반환해야 합니다.

`cache`나 `content_for`와 같이 다른 작업을 수행하는 헬퍼들은 이 변경에 영향을 받지 않으며, 이전과 같이 `&lt;%`를 사용해야 합니다.

#### 기타 변경 사항

* HTML 출력을 이스케이프하기 위해 `h(string)`을 호출할 필요가 없으며, 모든 뷰 템플릿에서 기본적으로 활성화되어 있습니다. 이스케이프되지 않은 문자열이 필요한 경우 `raw(string)`을 호출하면 됩니다.
* 헬퍼들은 이제 기본적으로 HTML5를 출력합니다.
* 폼 레이블 헬퍼는 이제 단일 값으로 I18n에서 값을 가져옵니다. 따라서 `f.label :name`은 `:name` 번역을 가져옵니다.
* I18n select 레이블은 이제 :en.helpers.select 대신 :en.support.select이어야 합니다.
* ERB 템플릿 내에서 Ruby 보간을 끝에 마이너스 기호를 추가하여 HTML 출력에서 줄 바꿈을 제거하기 위해 더 이상 마이너스 기호를 추가할 필요가 없습니다.
* Action View에 `grouped_collection_select` 헬퍼를 추가하였습니다.
* `content_for?`를 추가하여 뷰에서 렌더링하기 전에 콘텐츠의 존재 여부를 확인할 수 있습니다.
* 폼 헬퍼에 `:value => nil`을 전달하면 필드의 `value` 속성이 기본값 대신 nil로 설정됩니다.
* 폼 헬퍼에 `:id => nil`을 전달하면 해당 필드가 `id` 속성 없이 렌더링됩니다.
* `image_tag`에 `:alt => nil`을 전달하면 `img` 태그가 `alt` 속성 없이 렌더링됩니다.

Active Model
------------

Active Model은 Rails 3.0에서 새롭게 도입되었습니다. 이는 어떤 ORM 라이브러리든 Rails와 상호 작용하기 위해 Active Model 인터페이스를 구현하는 추상화 계층을 제공합니다.
### ORM 추상화 및 액션 팩 인터페이스

핵심 구성 요소의 결합을 분리하기 위해 액션 팩에서 Active Record와의 모든 연결을 추출하는 작업이 완료되었습니다. 이제 모든 새로운 ORM 플러그인은 Action Pack과 원활하게 작동하기 위해 Active Model 인터페이스를 구현하기만 하면 됩니다.

추가 정보: - [어떤 루비 객체도 ActiveRecord처럼 느껴지게 만들기](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### 유효성 검사

유효성 검사는 Active Record에서 Active Model로 이동되어, Rails 3에서 ORM 라이브러리 간에 작동하는 유효성 검사 인터페이스를 제공합니다.

* 이제 `validates :attribute, options_hash` 단축 메서드를 사용하여 모든 validates 클래스 메서드에 대한 옵션을 전달할 수 있습니다. validate 메서드에 여러 옵션을 전달할 수 있습니다.
* `validates` 메서드에는 다음과 같은 옵션이 있습니다:
    * `:acceptance => Boolean`.
    * `:confirmation => Boolean`.
    * `:exclusion => { :in => Enumerable }`.
    * `:inclusion => { :in => Enumerable }`.
    * `:format => { :with => Regexp, :on => :create }`.
    * `:length => { :maximum => Fixnum }`.
    * `:numericality => Boolean`.
    * `:presence => Boolean`.
    * `:uniqueness => Boolean`.

참고: Rails 버전 2.3 스타일의 유효성 검사 메서드는 Rails 3.0에서 모두 지원됩니다. 새로운 validates 메서드는 기존 API의 대체품이 아닌 모델 유효성 검사를 보조하는 추가 도구로 설계되었습니다.

또한 Active Model을 사용하는 객체 간에 재사용할 수 있는 유효성 검사기 객체를 전달할 수도 있습니다:

```ruby
class TitleValidator < ActiveModel::EachValidator
  Titles = ['Mr.', 'Mrs.', 'Dr.']
  def validate_each(record, attribute, value)
    unless Titles.include?(value)
      record.errors[attribute] << 'must be a valid title'
    end
  end
end
```

```ruby
class Person
  include ActiveModel::Validations
  attr_accessor :title
  validates :title, :presence => true, :title => true
end

# 또는 Active Record의 경우

class Person < ActiveRecord::Base
  validates :title, :presence => true, :title => true
end
```

또한 내부 검사를 지원합니다:

```ruby
User.validators
User.validators_on(:login)
```

추가 정보:

* [Rails 3에서 섹시한 유효성 검사](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)
* [Rails 3 유효성 검사 설명](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)


Active Record
-------------

Active Record는 Rails 3.0에서 많은 주목을 받았으며, Active Model로의 추상화, Arel을 사용한 쿼리 인터페이스의 완전한 업데이트, 유효성 검사 업데이트 및 여러 개선 및 수정이 포함되었습니다. Rails 2.x API는 3.1 버전까지 지원되는 호환성 레이어를 통해 사용할 수 있습니다.


### 쿼리 인터페이스

Active Record는 Arel을 통해 새로운 API를 제공하여 핵심 메서드에서 관계를 반환합니다. Rails 2.3.x에서 기존 API는 여전히 지원되며, Rails 3.1에서는 폐기되지 않으며, Rails 3.2에서 제거되기 전까지 제거되지 않을 것입니다. 그러나 새로운 API는 다음과 같은 새로운 메서드를 제공하여 관계를 반환하도록 하여 연결할 수 있습니다:

* `where` - 관계에 대한 조건을 제공합니다.
* `select` - 데이터베이스에서 반환할 모델의 속성을 선택합니다.
* `group` - 속성을 기준으로 관계를 그룹화합니다.
* `having` - 그룹 관계를 제한하는 표현식을 제공합니다 (GROUP BY 제약 조건).
* `joins` - 다른 테이블과 관계를 조인합니다.
* `clause` - 조인 관계를 제한하는 표현식을 제공합니다 (JOIN 제약 조건).
* `includes` - 사전로드된 다른 관계를 포함합니다.
* `order` - 표현식을 기준으로 관계를 정렬합니다.
* `limit` - 지정된 레코드 수로 관계를 제한합니다.
* `lock` - 테이블에서 반환된 레코드를 잠급니다.
* `readonly` - 데이터의 읽기 전용 복사본을 반환합니다.
* `from` - 여러 테이블에서 관계를 선택하는 방법을 제공합니다.
* `scope` - (이전에 `named_scope`) 관계를 반환하며, 다른 관계 메서드와 연결할 수 있습니다.
* `with_scope` - 및 `with_exclusive_scope`도 관계를 반환하므로 연결할 수 있습니다.
* `default_scope` - 관계와 함께 작동합니다.

추가 정보:

* [Active Record 쿼리 인터페이스](http://m.onkey.org/2010/1/22/active-record-query-interface)
* [Rails 3에서 SQL을 Growl하라](http://hasmanyquestions.wordpress.com/2010/01/17/let-your-sql-growl-in-rails-3/)


### 개선 사항

* Active Record 객체에 `:destroyed?` 추가.
* Active Record 연관 관계에 `:inverse_of` 추가. 이미 로드된 연관 관계의 인스턴스를 데이터베이스에 액세스하지 않고 가져올 수 있습니다.


### 패치 및 폐기

또한 Active Record 브랜치에서 많은 수정 사항이 있었습니다:

* SQLite 2 지원이 SQLite 3로 대체되었습니다.
* 열 순서에 대한 MySQL 지원.
* PostgreSQL 어댑터의 `TIME ZONE` 지원이 수정되어 잘못된 값이 삽입되지 않습니다.
* PostgreSQL에서 테이블 이름에 여러 스키마 지원.
* PostgreSQL에서 XML 데이터 유형 열 지원.
* `table_name`이 이제 캐시됩니다.
* Oracle 어댑터에도 많은 버그 수정이 포함되어 있습니다.
다음과 같은 사용 중단 사항도 있습니다:

* Active Record 클래스의 `named_scope`은 사용 중단되었으며 `scope`로 이름이 변경되었습니다.
* `scope` 메서드에서는 `:conditions => {}` 파인더 메서드 대신 관계 메서드를 사용해야 합니다. 예를 들어 `scope :since, lambda {|time| where("created_at > ?", time) }`와 같이 사용합니다.
* `save(false)`는 `save(:validate => false)`로 대체되었습니다.
* Active Record의 I18n 오류 메시지는 `:en.activerecord.errors.template`에서 `:en.errors.template`로 변경되어야 합니다.
* `model.errors.on`은 `model.errors[]`로 대체되었습니다.
* validates_presence_of => validates... :presence => true
* `ActiveRecord::Base.colorize_logging` 및 `config.active_record.colorize_logging`은 `Rails::LogSubscriber.colorize_logging` 또는 `config.colorize_logging`으로 대체되었습니다.

참고: State Machine의 구현은 Active Record edge에 몇 달 동안 있었지만, Rails 3.0 릴리스에서 제거되었습니다.


Active Resource
---------------

Active Resource도 Active Model로 분리되어 Action Pack과 함께 Active Resource 객체를 사용할 수 있게 되었습니다.

* Active Model을 통한 유효성 검사가 추가되었습니다.
* 관찰 훅이 추가되었습니다.
* HTTP 프록시 지원이 추가되었습니다.
* 다이제스트 인증을 지원하도록 추가되었습니다.
* 모델 네이밍이 Active Model로 이동되었습니다.
* Active Resource 속성이 동등한 액세스를 가진 해시로 변경되었습니다.
* 동등한 검색 범위에 대한 `first`, `last` 및 `all` 별칭이 추가되었습니다.
* `find_every`는 더 이상 반환할 것이 없을 때 `ResourceNotFound` 오류를 반환하지 않습니다.
* `valid?`가 아닌 경우 `ResourceInvalid`를 발생시키는 `save!`가 추가되었습니다.
* Active Resource 모델에 `update_attribute` 및 `update_attributes`가 추가되었습니다.
* `exists?`가 추가되었습니다.
* `SchemaDefinition`이 `Schema`로 이름이 변경되었고 `define_schema`가 `schema`로 변경되었습니다.
* 오류를 로드하기 위해 원격 오류의 `content-type` 대신 Active Resources의 `format`을 사용합니다.
* 스키마 블록에 `instance_eval`을 사용합니다.
* `@response`가 #code 또는 #message에 응답하지 않을 때 `ActiveResource::ConnectionError#to_s`를 수정하여 Ruby 1.9 호환성을 처리합니다.
* JSON 형식의 오류 지원이 추가되었습니다.
* 숫자 배열과 함께 `load`가 작동하도록 보장합니다.
* 원격 리소스에서 410 응답을 인식하여 리소스가 삭제되었음을 나타냅니다.
* Active Resource 연결에 SSL 옵션을 설정할 수 있는 기능이 추가되었습니다.
* 연결 시간 제한 설정은 `Net::HTTP` `open_timeout`에도 영향을 줍니다.

사용 중단 사항:

* `save(false)`는 `save(:validate => false)`로 대체되었습니다.
* Ruby 1.9.2에서 `URI.parse`와 `.decode`는 사용 중단되었으며 라이브러리에서 더 이상 사용되지 않습니다.


Active Support
--------------

Active Support에서는 Active Support 라이브러리 전체를 요구하지 않고도 일부를 가져올 수 있도록 cherry pickable하게 만드는 데 큰 노력이 기울여졌습니다. 이를 통해 Rails의 다양한 핵심 구성 요소를 더 가볍게 실행할 수 있게 되었습니다.

Active Support의 주요 변경 사항은 다음과 같습니다:

* 사용되지 않는 메서드를 제거하여 라이브러리를 크게 정리했습니다.
* Active Support는 더 이상 TZInfo, Memcache Client 및 Builder의 vendored 버전을 제공하지 않습니다. 이들은 모두 종속성으로 포함되어 `bundle install` 명령을 통해 설치됩니다.
* `ActiveSupport::SafeBuffer`에 안전한 버퍼가 구현되었습니다.
* `Array.uniq_by` 및 `Array.uniq_by!`가 추가되었습니다.
* `Array#rand`를 제거하고 Ruby 1.9에서 `Array#sample`을 백포트했습니다.
* `TimeZone.seconds_to_utc_offset`이 잘못된 값을 반환하는 버그를 수정했습니다.
* `ActiveSupport::Notifications` 미들웨어가 추가되었습니다.
* `ActiveSupport.use_standard_json_time_format`의 기본값이 이제 true로 설정됩니다.
* `ActiveSupport.escape_html_entities_in_json`의 기본값이 이제 false로 설정됩니다.
* `Integer#multiple_of?`는 인수로 0을 허용하며, 수신자가 0이 아닌 경우에만 false를 반환합니다.
* `string.chars`가 `string.mb_chars`로 이름이 변경되었습니다.
* `ActiveSupport::OrderedHash`는 이제 YAML을 통해 역직렬화할 수 있습니다.
* LibXML 및 Nokogiri를 사용하는 XmlMini에 기반한 SAX 기반 파서가 추가되었습니다.
* `#present?`인 경우 객체를 반환하고 그렇지 않으면 `nil`을 반환하는 `Object#presence`가 추가되었습니다.
* `#include?`의 반대인 `#exclude?` 코어 확장이 추가되었습니다.
* `ActiveSupport`의 `DateTime`에 `to_i`가 추가되어 `DateTime` 속성이 있는 모델에서 `to_yaml`이 올바르게 작동합니다.
* `Enumerable#include?`에 대응하는 `Enumerable#exclude?`가 추가되어 `!x.include?`를 피할 수 있습니다.
* Rails에 대한 기본적으로 XSS 이스케이핑을 사용합니다.
* `ActiveSupport::HashWithIndifferentAccess`에서 깊은 병합을 지원합니다.
* `Enumerable#sum`은 이제 `:size`에 응답하지 않는 모든 열거 가능한 항목에서 작동합니다.
* 길이가 0인 기간의 `inspect`는 빈 문자열 대신 '0 seconds'를 반환합니다.
* `ModelName`에 `element` 및 `collection`이 추가되었습니다.
* `String#to_time` 및 `String#to_datetime`은 소수점 초를 처리합니다.
* 전후 콜백에서 사용되는 `:before` 및 `:after`에 응답하는 around 필터 객체에 대한 새로운 콜백 지원을 추가했습니다.
* `ActiveSupport::OrderedHash#to_a` 메서드는 정렬된 배열 집합을 반환합니다. Ruby 1.9의 `Hash#to_a`와 일치합니다.
* `MissingSourceFile`은 상수로 존재하지만 이제 `LoadError`와 동일합니다.
* 클래스 수준의 속성을 선언하고 하위 클래스에서 상속 및 덮어쓸 수 있는 클래스 속성인 `Class#class_attribute`가 추가되었습니다.
* `ActiveRecord::Associations`에서 `DeprecatedCallbacks`를 마침내 제거했습니다.
* `Object#metaclass`는 이제 Ruby와 일치하기 위해 `Kernel#singleton_class`입니다.
다음 메소드들은 Ruby 1.8.7과 1.9에서 사용 가능하므로 제거되었습니다.

* `Integer#even?`과 `Integer#odd?`
* `String#each_char`
* `String#start_with?`와 `String#end_with?` (3인칭 별칭은 유지됨)
* `String#bytesize`
* `Object#tap`
* `Symbol#to_proc`
* `Object#instance_variable_defined?`
* `Enumerable#none?`

REXML의 보안 패치는 Ruby 1.8.7의 초기 패치 레벨에서 필요하기 때문에 Active Support에 남아 있습니다. Active Support는 패치를 적용해야 할지 여부를 알고 있습니다.

다음 메소드들은 더 이상 프레임워크에서 사용되지 않기 때문에 제거되었습니다.

* `Kernel#daemonize`
* `Object#remove_subclasses_of`, `Object#extend_with_included_modules_from`, `Object#extended_by`
* `Class#remove_class`
* `Regexp#number_of_captures`, `Regexp.unoptionalize`, `Regexp.optionalize`, `Regexp#number_of_captures`

Action Mailer
-------------

Action Mailer는 TMail이 이메일 라이브러리로 대체되어 새로운 API를 갖게 되었습니다. Action Mailer 자체도 거의 완전히 다시 작성되었으며, 거의 모든 코드가 수정되었습니다. 그 결과로 Action Mailer는 이제 단순히 Abstract Controller를 상속하고 Mail 젬을 Rails DSL로 감싸는 역할을 합니다. 이로 인해 Action Mailer의 코드 양과 다른 라이브러리의 중복이 크게 줄어들었습니다.

* 모든 메일러는 이제 기본적으로 `app/mailers`에 있습니다.
* `attachments`, `headers`, `mail` 세 가지 메소드를 사용하여 새로운 API로 이메일을 보낼 수 있습니다.
* Action Mailer는 `attachments.inline` 메소드를 사용하여 인라인 첨부 파일을 지원합니다.
* Action Mailer의 이메일 전송 메소드는 이제 `Mail::Message` 객체를 반환하며, 이 객체에 `deliver` 메시지를 보내서 이메일을 보낼 수 있습니다.
* 모든 전송 방법은 이제 Mail 젬으로 추상화되었습니다.
* 메일 전송 방법은 모든 유효한 메일 헤더 필드와 그 값 쌍의 해시를 받을 수 있습니다.
* `mail` 전송 방법은 Action Controller의 `respond_to`와 유사하게 작동하며, 템플릿을 명시적으로 또는 암시적으로 렌더링할 수 있습니다. Action Mailer는 필요에 따라 이메일을 멀티파트 이메일로 변환합니다.
* 메일 블록 내의 `format.mime_type` 호출에 proc를 전달하여 특정 유형의 텍스트를 명시적으로 렌더링하거나 레이아웃이나 다른 템플릿을 추가할 수 있습니다. proc 내부의 `render` 호출은 Abstract Controller에서 지원하며 동일한 옵션을 지원합니다.
* 메일러 단위 테스트는 이제 기능 테스트로 이동되었습니다.
* Action Mailer는 이제 모든 헤더 필드와 본문의 자동 인코딩을 Mail 젬에 위임합니다.
* Action Mailer는 이메일 본문과 헤더를 자동으로 인코딩합니다.

사용이 중단된 기능:

* `:charset`, `:content_type`, `:mime_version`, `:implicit_parts_order`는 모두 `ActionMailer.default :key => value` 스타일의 선언을 선호합니다.
* 메일러 동적 `create_method_name`과 `deliver_method_name`은 사용이 중단되었으며, 이제 `method_name`을 호출하면 `Mail::Message` 객체가 반환됩니다.
* `ActionMailer.deliver(message)`는 사용이 중단되었으며, 대신 `message.deliver`를 호출하십시오.
* `template_root`는 사용이 중단되었으며, `format.mime_type` 메소드 내부의 proc에서 렌더 호출에 옵션을 전달하십시오.
* 인스턴스 변수를 정의하기 위해 `body` 메소드는 사용이 중단되었습니다 (`body {:ivar => value}`). 메소드 내에서 인스턴스 변수를 직접 선언하면 뷰에서 사용할 수 있습니다.
* 메일러가 `app/models`에 있는 것은 사용이 중단되었으며, 대신 `app/mailers`를 사용하십시오.

추가 정보:

* [Rails 3에서 새로운 Action Mailer API](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)
* [루비를 위한 새로운 Mail 젬](http://lindsaar.net/2010/1/23/mail-gem-version-2-released)

크레딧
-------

Rails 3에 많은 시간을 투자한 많은 사람들에게 감사의 인사를 전합니다. 자세한 정보는 [Rails 기여자 목록](https://contributors.rubyonrails.org/)을 참조하십시오.

Rails 3.0 릴리스 노트는 [Mikel Lindsaar](http://lindsaar.net)에 의해 작성되었습니다.
