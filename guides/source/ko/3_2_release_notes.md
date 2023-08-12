**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 30550ed8fa3c0983f3d99a0e91571a98
루비 온 레일즈 3.2 릴리스 노트
===============================

Rails 3.2의 주요 기능:

* 개발 모드가 더 빨라짐
* 새로운 라우팅 엔진
* 자동 쿼리 설명
* 태그가 지정된 로깅

이 릴리스 노트는 주요 변경 사항만 다룹니다. 다양한 버그 수정 및 변경 사항에 대해서는 변경 로그를 참조하거나 GitHub의 주요 Rails 저장소의 [커밋 목록](https://github.com/rails/rails/commits/3-2-stable)을 확인하십시오.

--------------------------------------------------------------------------------

Rails 3.2로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드하는 경우, 업데이트하기 전에 좋은 테스트 커버리지를 갖고 있는 것이 좋습니다. 또한, Rails 3.2로 업데이트하기 전에 Rails 3.1로 먼저 업그레이드하고 애플리케이션이 예상대로 작동하는지 확인하십시오. 그런 다음 다음 변경 사항을 주의 깊게 살펴보십시오:

### Rails 3.2는 적어도 Ruby 1.8.7 이상을 필요로 합니다.

Rails 3.2는 Ruby 1.8.7 이상을 필요로 합니다. 이전 버전의 Ruby에 대한 지원은 공식적으로 중단되었으며 가능한 빨리 업그레이드해야 합니다. Rails 3.2는 또한 Ruby 1.9.2와 호환됩니다.

팁: Ruby 1.8.7 p248 및 p249에는 Rails를 충돌시키는 마샬링 버그가 있습니다. Ruby Enterprise Edition은 1.8.7-2010.02 버전 이후로 이를 수정했습니다. 1.9 버전에서는 Ruby 1.9.1을 사용할 수 없으며, 그냥 세그폴트가 발생하므로 1.9.x를 사용하려면 1.9.2 또는 1.9.3으로 전환하십시오.

### 애플리케이션에서 업데이트해야 할 내용

* `Gemfile`을 다음과 같이 업데이트하십시오.
    * `rails = 3.2.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

* Rails 3.2에서는 `vendor/plugins`를 사용하지 않게 되었으며, Rails 4.0에서는 완전히 제거될 예정입니다. 이러한 플러그인을 젬으로 추출하여 `Gemfile`에 추가하는 방법으로 대체할 수 있습니다. 젬으로 만들지 않을 경우, `lib/my_plugin/*`로 이동시키고 `config/initializers/my_plugin.rb`에 적절한 초기화 코드를 추가할 수 있습니다.

* `config/environments/development.rb`에 다음과 같은 몇 가지 새로운 구성 변경 사항을 추가해야 합니다:

    ```ruby
    # Active Record 모델의 대량 할당 보호에 대한 예외 발생
    config.active_record.mass_assignment_sanitizer = :strict

    # 이 시간 이상 걸리는 쿼리에 대한 쿼리 계획 로깅 (SQLite, MySQL, PostgreSQL에서 작동)
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    `mass_assignment_sanitizer` 구성은 `config/environments/test.rb`에도 추가해야 합니다:

    ```ruby
    # Active Record 모델의 대량 할당 보호에 대한 예외 발생
    config.active_record.mass_assignment_sanitizer = :strict
    ```

### 엔진에서 업데이트해야 할 내용

`script/rails`의 주석 아래에 있는 코드를 다음 내용으로 대체하십시오:

```ruby
ENGINE_ROOT = File.expand_path('../..', __FILE__)
ENGINE_PATH = File.expand_path('../../lib/your_engine_name/engine', __FILE__)

require "rails/all"
require "rails/engine/commands"
```

Rails 3.2 애플리케이션 생성하기
--------------------------------

```bash
# 'rails' RubyGem이 설치되어 있어야 합니다.
$ rails new myapp
$ cd myapp
```

### 젬 벤더링

Rails는 이제 애플리케이션 루트에 있는 `Gemfile`을 사용하여 애플리케이션을 시작하는 데 필요한 젬을 결정합니다. 이 `Gemfile`은 [Bundler](https://github.com/carlhuda/bundler) 젬에 의해 처리되며, 모든 종속성을 설치합니다. 심지어 시스템 젬에 의존하지 않도록 애플리케이션에 종속성을 로컬로 설치할 수도 있습니다.

자세한 정보: [Bundler 홈페이지](https://bundler.io/)

### 최신 버전 사용하기

`Bundler`와 `Gemfile`을 사용하면 새로운 전용 `bundle` 명령을 사용하여 Rails 애플리케이션을 쉽게 동결할 수 있습니다. Git 저장소에서 직접 번들을 생성하려면 `--edge` 플래그를 전달할 수 있습니다:

```bash
$ rails new myapp --edge
```

로컬에서 Rails 저장소를 체크아웃한 경우, 해당 저장소를 사용하여 애플리케이션을 생성하려면 `--dev` 플래그를 전달할 수 있습니다:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

주요 기능
--------------

### 더 빠른 개발 모드 및 라우팅

Rails 3.2는 더 빠른 개발 모드를 제공합니다. [Active Reload](https://github.com/paneq/active_reload)에서 영감을 받아 Rails는 파일이 실제로 변경될 때만 클래스를 다시 로드합니다. 이는 큰 애플리케이션에서 성능 향상을 가져옵니다. 새로운 [Journey](https://github.com/rails/journey) 엔진 덕분에 라우트 인식도 훨씬 빨라졌습니다.

### 자동 쿼리 설명

Rails 3.2는 Arel이 생성한 쿼리를 설명하기 위해 `ActiveRecord::Relation`에 `explain` 메서드를 정의하는 좋은 기능을 제공합니다. 예를 들어, `puts Person.active.limit(5).explain`와 같은 코드를 실행하면 Arel이 생성한 쿼리가 설명됩니다. 이를 통해 적절한 인덱스와 추가적인 최적화를 확인할 수 있습니다.

개발 모드에서 실행 시간이 0.5초 이상 걸리는 쿼리는 *자동으로* 설명됩니다. 물론 이 임계값은 변경할 수 있습니다.

### 태그가 지정된 로깅
멀티 사용자, 멀티 계정 애플리케이션을 실행할 때 누가 무엇을 했는지에 대한 로그를 필터링할 수 있는 것은 큰 도움이 됩니다. Active Support의 TaggedLogging은 서브도메인, 요청 ID 등을 로그 라인에 표시하여 이러한 애플리케이션의 디버깅을 지원합니다.

문서
-------------

Rails 3.2부터는 Rails 가이드가 Kindle 및 iPad, iPhone, Mac, Android 등의 무료 Kindle Reading 앱을 위해 사용할 수 있습니다.

Railties
--------

* 의존성 파일이 변경된 경우에만 클래스를 다시로드하여 개발 속도를 높입니다. `config.reload_classes_only_on_change`를 false로 설정하여 이 기능을 비활성화할 수 있습니다.

* 새로운 애플리케이션은 environments 구성 파일에 `config.active_record.auto_explain_threshold_in_seconds` 플래그를 얻습니다. `development.rb`에서 `0.5`의 값을 가지고 있으며 `production.rb`에서는 주석 처리되어 있습니다. `test.rb`에는 언급되지 않았습니다.

* `config.exceptions_app`을 추가하여 예외가 발생할 때 `ShowException` 미들웨어에서 호출되는 예외 애플리케이션을 설정할 수 있습니다. 기본값은 `ActionDispatch::PublicExceptions.new(Rails.public_path)`입니다.

* `ShowExceptions` 미들웨어에서 추출된 기능을 포함하는 `DebugExceptions` 미들웨어를 추가했습니다.

* `rake routes`에서 마운트된 엔진의 라우트를 표시합니다.

* `config.railties_order`를 사용하여 railties의 로딩 순서를 변경할 수 있습니다. 다음과 같이 설정할 수 있습니다.

    ```ruby
    config.railties_order = [Blog::Engine, :main_app, :all]
    ```

* API 요청에 내용이 없는 경우에는 204 No Content를 반환합니다. 이로써 scaffold가 jQuery와 함께 작동합니다.

* `Rails::Rack::Logger` 미들웨어를 업데이트하여 `config.log_tags`에 설정된 태그를 `ActiveSupport::TaggedLogging`에 적용합니다. 이를 통해 서브도메인 및 요청 ID와 같은 디버깅에 매우 유용한 디버그 정보로 로그 라인에 태그를 지정하기 쉬워집니다.

* 기본 옵션을 `~/.railsrc`에 설정할 수 있습니다. 홈 디렉토리의 `.railsrc` 구성 파일에 `rails new`가 실행될 때마다 사용할 추가 명령줄 인수를 지정할 수 있습니다.

* `destroy`에 대한 별칭 `d`를 추가했습니다. 엔진에도 작동합니다.

* scaffold 및 model 생성기의 속성은 기본적으로 문자열로 설정됩니다. 다음과 같이 사용할 수 있습니다. `bin/rails g scaffold Post title body:text author`

* scaffold/model/migration 생성기가 "index" 및 "uniq" 수정자를 허용합니다. 예를 들어,

    ```bash
    bin/rails g scaffold Post title:string:index author:uniq price:decimal{7,2}
    ```

    이렇게 하면 `title` 및 `author`에 대한 인덱스가 생성되며 후자는 고유 인덱스가 됩니다. decimal과 같은 일부 유형은 사용자 정의 옵션을 허용합니다. 예에서 `price`는 정밀도와 스케일이 각각 7과 2로 설정된 decimal 열이 됩니다.

* 기본 `Gemfile`에서 `turn` 젬이 제거되었습니다.

* `rails generate plugin`을 `rails plugin new` 명령으로 대체하여 이전 플러그인 생성기를 제거했습니다.

* 이전의 `config.paths.app.controller` API를 `config.paths["app/controller"]`로 대체했습니다.

### 폐기 예정

* `Rails::Plugin`은 폐기 예정이며 Rails 4.0에서 제거될 예정입니다. `vendor/plugins`에 플러그인을 추가하는 대신 경로나 git 종속성을 사용하여 젬이나 bundler를 사용하세요.

Action Mailer
-------------

* `mail` 버전을 2.4.0으로 업그레이드했습니다.

* Rails 3.0 이후로 폐기된 이전 Action Mailer API를 제거했습니다.

Action Pack
-----------

### Action Controller

* `ActiveSupport::Benchmarkable`을 `ActionController::Base`의 기본 모듈로 만들어 `#benchmark` 메소드를 컨트롤러 컨텍스트에서 다시 사용할 수 있도록 했습니다.

* `caches_page`에 `:gzip` 옵션을 추가했습니다. 기본 옵션은 `page_cache_compression`을 사용하여 전역적으로 구성할 수 있습니다.

* 레이아웃을 `:only` 및 `:except` 조건으로 지정할 때 Rails는 이제 기본 레이아웃(예: "layouts/application")을 사용합니다. 이전에는 조건이 실패할 경우 기본 레이아웃이 사용되지 않았습니다.

    ```ruby
    class CarsController
      layout 'single_car', :only => :show
    end
    ```

    Rails는 `:show` 액션이 요청될 때 `layouts/single_car`를 사용하고, 다른 액션에 대한 요청이 들어올 때 `layouts/application`(또는 `layouts/cars`가 있는 경우)를 사용합니다.

* `form_for`는 `:as` 옵션이 제공되는 경우 CSS 클래스와 ID로 `#{action}_#{as}`를 사용하도록 변경되었습니다. 이전 버전에서는 `#{as}_#{action}`을 사용했습니다.

* Active Record 모델의 `ActionController::ParamsWrapper`는 이제 `attr_accessible` 속성을 설정한 경우에만 래핑합니다. 그렇지 않으면 클래스 메소드 `attribute_names`에서 반환된 속성만 래핑됩니다. 이로써 중첩된 속성을 `attr_accessible`에 추가하여 래핑하는 문제가 해결됩니다.

* 각 before 콜백이 중단될 때마다 "Filter chain halted as CALLBACKNAME rendered or redirected"를 로그에 기록합니다.

* `ActionDispatch::ShowExceptions`가 리팩토링되었습니다. 컨트롤러가 예외를 표시할지 여부를 선택합니다. 컨트롤러에서 `show_detailed_exceptions?`를 재정의하여 어떤 요청이 오류에 대한 디버깅 정보를 제공해야 하는지 지정할 수 있습니다.

* Responders는 이제 응답 본문이 없는 API 요청에 대해 204 No Content를 반환합니다(새로운 scaffold와 동일).

* `ActionController::TestCase`의 쿠키가 리팩토링되었습니다. 테스트 케이스에서 쿠키를 할당할 때는 이제 `cookies[]`를 사용해야 합니다.
```ruby
cookies[:email] = 'user@example.com'
get :index
assert_equal 'user@example.com', cookies[:email]
```

쿠키를 지우려면 `clear`를 사용하십시오.

```ruby
cookies.clear
get :index
assert_nil cookies[:email]
```

이제 HTTP_COOKIE를 작성하지 않고 쿠키 저장소는 요청 간에 지속되므로 테스트를 위해 환경을 조작해야하는 경우 쿠키 저장소가 생성되기 전에 수행해야합니다.

* `send_file`은 `:type`이 제공되지 않은 경우 파일 확장자에서 MIME 유형을 추측합니다.

* PDF, ZIP 및 기타 형식에 대한 MIME 유형 항목이 추가되었습니다.

* `fresh_when/stale?`이 옵션 해시 대신 레코드를 사용할 수 있도록 허용되었습니다.

* CSRF 토큰이 누락된 경우 경고 로그 수준이 `:debug`에서 `:warn`으로 변경되었습니다.

* 자산은 기본적으로 요청 프로토콜을 사용하거나 요청이 없는 경우 상대 경로로 기본 설정해야합니다.

#### 폐기 예정 기능

* 명시적 레이아웃이 설정된 부모 컨트롤러의 컨트롤러에서 암시적 레이아웃 조회를 폐기 예정으로 설정했습니다:

    ```ruby
    class ApplicationController
      layout "application"
    end

    class PostsController < ApplicationController
    end
    ```

    위의 예에서 `PostsController`는 더 이상 자동으로 게시물 레이아웃을 조회하지 않습니다. 이 기능이 필요한 경우 `ApplicationController`에서 `layout "application"`을 제거하거나 `PostsController`에서 명시적으로 `nil`로 설정할 수 있습니다.

* `ActionController::UnknownAction`을 `AbstractController::ActionNotFound` 대신 폐기 예정으로 설정했습니다.

* `ActionController::DoubleRenderError`을 `AbstractController::DoubleRenderError` 대신 폐기 예정으로 설정했습니다.

* 누락된 액션에 대해 `method_missing`을 `action_missing`으로 폐기 예정으로 설정했습니다.

* `ActionController#rescue_action`, `ActionController#initialize_template_class` 및 `ActionController#assign_shortcuts`을 폐기 예정으로 설정했습니다.

### 액션 디스패치

* `config.action_dispatch.default_charset`을 추가하여 `ActionDispatch::Response`의 기본 문자 집합을 구성할 수 있습니다.

* `ActionDispatch::RequestId` 미들웨어를 추가하여 고유한 X-Request-Id 헤더를 응답에 사용할 수 있게하고 `ActionDispatch::Request#uuid` 메서드를 활성화합니다. 이를 통해 스택 전체에서 요청을 추적하고 Syslog와 같은 혼합 로그에서 개별 요청을 식별하는 것이 쉬워집니다.

* `ShowExceptions` 미들웨어는 이제 응용 프로그램이 실패할 때 예외를 렌더링하는 책임이있는 예외 응용 프로그램을 허용합니다. 응용 프로그램은 예외의 사본과 `PATH_INFO`가 상태 코드로 다시 작성된 상태로 호출됩니다.

* `config.action_dispatch.rescue_responses`와 같은 railtie를 통해 구성 가능한 구조 응답을 허용합니다.

#### 폐기 예정 기능

* 컨트롤러 수준에서 기본 문자 집합을 설정하는 기능을 폐기 예정으로 설정했습니다. 대신 새로운 `config.action_dispatch.default_charset`을 사용하십시오.

### 액션 뷰

* `ActionView::Helpers::FormBuilder`에 `button_tag` 지원을 추가했습니다. 이 지원은 `submit_tag`의 기본 동작을 모방합니다.

    ```erb
    <%= form_for @post do |f| %>
      <%= f.button %>
    <% end %>
    ```

* 날짜 도우미는 `:use_two_digit_numbers => true`라는 새로운 옵션을 허용합니다. 이 옵션은 월과 일을 선택 상자로 렌더링하고 해당 값을 변경하지 않고 선행 0이 있는 상태로 표시합니다. 예를 들어, '2011-08-01'과 같은 ISO 8601 스타일의 날짜를 표시하는 데 유용합니다.

* 폼의 id 속성의 고유성을 보장하기 위해 폼에 대한 네임스페이스를 제공할 수 있습니다. 생성된 HTML id에는 밑줄로 시작하는 네임스페이스 속성이 접두어로 붙습니다.

    ```erb
    <%= form_for(@offer, :namespace => 'namespace') do |f| %>
      <%= f.label :version, 'Version' %>:
      <%= f.text_field :version %>
    <% end %>
    ```

* `select_year`의 옵션 수를 1000으로 제한합니다. 사용자 정의 제한을 설정하려면 `:max_years_allowed` 옵션을 전달하십시오.

* `content_tag_for` 및 `div_for`는 이제 레코드 컬렉션을 사용할 수 있습니다. 블록에서 수신 인수를 설정하면 레코드를 첫 번째 인수로 제공합니다. 따라서 다음과 같이 수행 할 필요가 없습니다.

    ```ruby
    @items.each do |item|
      content_tag_for(:li, item) do
        Title: <%= item.title %>
      end
    end
    ```

    다음과 같이 수행 할 수 있습니다.

    ```ruby
    content_tag_for(:li, @items) do |item|
      Title: <%= item.title %>
    end
    ```

* `font_path` 도우미 메서드를 추가하여 `public/fonts`에서 글꼴 자산의 경로를 계산합니다.

#### 폐기 예정 기능

* `render :template => "foo.html.erb"`와 같이 render :template 및 관련 항목에 형식이나 핸들러를 전달하는 것은 폐기 예정입니다. 대신 옵션으로 :handlers 및 :formats를 직접 제공할 수 있습니다. `render :template => "foo", :formats => [:html, :js], :handlers => :erb`와 같이 사용할 수 있습니다.

### Sprockets

* Sprockets 로깅을 제어하기 위해 `config.assets.logger` 구성 옵션을 추가했습니다. 로깅을 끄려면 `false`로 설정하고 `Rails.logger`로 기본 설정하려면 `nil`로 설정하십시오.

Active Record
-------------

* 'on' 및 'ON' 값을 가진 부울 열은 true로 형변환됩니다.

* `timestamps` 메서드가 `created_at` 및 `updated_at` 열을 생성 할 때 기본적으로 null이 아닌 열로 만듭니다.

* `ActiveRecord::Relation#explain`을 구현했습니다.

* 사용자가 블록 내에서 자동 EXPLAIN을 선택적으로 비활성화 할 수있는 `ActiveRecord::Base.silence_auto_explain`를 구현했습니다.

* 느린 쿼리에 대한 자동 EXPLAIN 로깅을 구현했습니다. 새로운 구성 매개 변수 `config.active_record.auto_explain_threshold_in_seconds`는 느린 쿼리로 간주 될 내용을 결정합니다. 이 기능을 비활성화하려면 nil로 설정하십시오. 기본값은 개발 모드에서 0.5이고 테스트 및 프로덕션 모드에서는 nil입니다. Rails 3.2는 SQLite, MySQL (mysql2 어댑터) 및 PostgreSQL에서이 기능을 지원합니다.
* `ActiveRecord::Base.store`를 추가하여 간단한 단일 열 키/값 저장소를 선언할 수 있습니다.

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [ :color, :homepage ]
    end

    u = User.new(color: 'black', homepage: '37signals.com')
    u.color                          # 저장된 속성에 접근
    u.settings[:country] = 'Denmark' # 접근자로 지정되지 않은 속성도 가능
    ```

* 특정 범위에 대해서만 마이그레이션을 실행할 수 있는 기능을 추가했습니다. 이는 특정 엔진에서 마이그레이션을 실행할 때 유용하며, 엔진을 제거해야 하는 변경 사항을 되돌릴 때 사용할 수 있습니다.

    ```
    rake db:migrate SCOPE=blog
    ```

* 엔진에서 복사된 마이그레이션은 이제 엔진의 이름과 함께 범위가 지정됩니다. 예를 들어 `01_create_posts.blog.rb`와 같이 됩니다.

* `ActiveRecord::Relation#pluck` 메서드를 구현하여 기본 테이블에서 직접 열 값의 배열을 반환합니다. 이는 직렬화된 속성과 함께도 작동합니다.

    ```ruby
    Client.where(:active => true).pluck(:id)
    # SELECT id from clients where active = 1
    ```

* 생성된 연관 메서드는 오버라이딩과 구성을 허용하기 위해 별도의 모듈 내에 생성됩니다. MyModel이라는 클래스의 경우, 모듈은 `MyModel::GeneratedFeatureMethods`로 이름이 지정됩니다. 이 모듈은 Active Model에서 정의된 `generated_attributes_methods` 모듈 바로 다음에 모델 클래스에 포함됩니다. 따라서 연관 메서드는 동일한 이름의 속성 메서드를 오버라이드합니다.

* 고유한 쿼리를 생성하기 위해 `ActiveRecord::Relation#uniq`를 추가했습니다.

    ```ruby
    Client.select('DISTINCT name')
    ```

    ..다음과 같이 작성할 수 있습니다:

    ```ruby
    Client.select(:name).uniq
    ```

    이는 관계에서 고유성을 되돌릴 수도 있습니다:

    ```ruby
    Client.select(:name).uniq.uniq(false)
    ```

* SQLite, MySQL 및 PostgreSQL 어댑터에서 인덱스 정렬 순서를 지원합니다.

* 연관 관계에 대한 `:class_name` 옵션은 문자열 외에도 심볼을 사용할 수 있도록 허용되었습니다. 이는 초보자를 혼동시키지 않기 위해, 그리고 `:foreign_key`와 같은 다른 옵션들이 심볼 또는 문자열을 허용하도록 일관성을 유지하기 위함입니다.

    ```ruby
    has_many :clients, :class_name => :Client # 심볼은 대문자로 지정되어야 함에 유의하세요
    ```

* 개발 모드에서 `db:drop`은 `db:create`와 대칭이 되도록 테스트 데이터베이스도 삭제합니다.

* 대소문자 구분 없는 고유성 유효성 검사는 MySQL에서 이미 대소문자 구분 없는 정렬을 사용하는 열인 경우 LOWER를 호출하지 않도록 합니다.

* 트랜잭션 픽스처는 모든 활성 데이터베이스 연결을 등록합니다. 트랜잭션 픽스처를 비활성화하지 않고 다른 연결에서 모델을 테스트할 수 있습니다.

* Active Record에 `first_or_create`, `first_or_create!`, `first_or_initialize` 메서드를 추가했습니다. 이는 이전의 `find_or_create_by` 동적 메서드보다 더 나은 접근 방식입니다. 레코드를 찾는 데 사용되는 인수와 생성하는 데 사용되는 인수가 명확하게 구분됩니다.

    ```ruby
    User.where(:first_name => "Scarlett").first_or_create!(:last_name => "Johansson")
    ```

* Active Record 객체에 `with_lock` 메서드를 추가했습니다. 이 메서드는 트랜잭션을 시작하고 객체를 (비관적으로) 잠그고 블록에 양도합니다. 이 메서드는 하나의 (선택적) 매개변수를 사용하고 `lock!`에 전달합니다.

    다음과 같이 작성할 수 있습니다:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        transaction do
          lock!
          # ... 취소 로직
        end
      end
    end
    ```

    다음과 같이 작성할 수도 있습니다:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        with_lock do
          # ... 취소 로직
        end
      end
    end
    ```

### 폐기된 기능

* 스레드에서 연결을 자동으로 닫는 것은 폐기되었습니다. 예를 들어 다음 코드는 폐기되었습니다:

    ```ruby
    Thread.new { Post.find(1) }.join
    ```

    이를 다음과 같이 변경해야 합니다:

    ```ruby
    Thread.new {
      Post.find(1)
      Post.connection.close
    }.join
    ```

    응용 프로그램 코드에서 스레드를 생성하는 사람들만이 이 변경 사항에 대해 걱정해야 합니다.

* `set_table_name`, `set_inheritance_column`, `set_sequence_name`, `set_primary_key`, `set_locking_column` 메서드는 폐기되었습니다. 대신 할당 메서드를 사용하세요. 예를 들어, `set_table_name` 대신 `self.table_name=`을 사용하세요.

    ```ruby
    class Project < ActiveRecord::Base
      self.table_name = "project"
    end
    ```

    또는 직접 `self.table_name` 메서드를 정의하세요:

    ```ruby
    class Post < ActiveRecord::Base
      def self.table_name
        "special_" + super
      end
    end

    Post.table_name # => "special_posts"
    ```

Active Model
------------

* `ActiveModel::Errors#added?`를 추가하여 특정 오류가 추가되었는지 확인할 수 있습니다.

* `strict => true`로 엄격한 유효성 검사를 정의할 수 있는 기능을 추가했습니다. 이는 항상 예외를 발생시키는 경우에 사용됩니다.

* `mass_assignment_sanitizer`를 쉽게 대체할 수 있는 API를 제공합니다. 또한 `:logger` (기본값) 및 `:strict` 산돌기 동작을 모두 지원합니다.

### 폐기된 기능

* `ActiveModel::AttributeMethods`의 `define_attr_method`를 폐기했습니다. 이는 Active Record의 `set_table_name`과 같은 메서드를 지원하기 위해 존재했으며, 이러한 메서드들 자체가 폐기되고 있기 때문입니다.

* `Model.model_name.partial_path`를 `model.to_partial_path`로 대체하여 폐기했습니다.

Active Resource
---------------

* 리디렉션 응답인 303 See Other 및 307 Temporary Redirect가 이제 301 Moved Permanently 및 302 Found와 같은 동작을 합니다.

Active Support
--------------

* `ActiveSupport:TaggedLogging`을 추가하여 태깅 기능을 제공하는 표준 `Logger` 클래스를 래핑할 수 있습니다.

    ```ruby
    Logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    Logger.tagged("BCX") { Logger.info "Stuff" }
    # "[BCX] Stuff"를 로그에 기록

    Logger.tagged("BCX", "Jason") { Logger.info "Stuff" }
    # "[BCX] [Jason] Stuff"를 로그에 기록

    Logger.tagged("BCX") { Logger.tagged("Jason") { Logger.info "Stuff" } }
    # "[BCX] [Jason] Stuff"를 로그에 기록
    ```
* `Date`, `Time` 및 `DateTime`의 `beginning_of_week` 메소드는 주의 시작일을 나타내는 선택적 인수를 허용합니다.

* `ActiveSupport::Notifications.subscribed`는 블록이 실행되는 동안 이벤트에 대한 구독을 제공합니다.

* 표준 API의 해당 메소드와 유사하지만 정규화된 상수 이름을 허용하는 `Module#qualified_const_defined?`, `Module#qualified_const_get` 및 `Module#qualified_const_set` 메소드를 정의했습니다.

* `#demodulize`와 상보적인 역할을 하는 `#deconstantize`를 추가했습니다. 이는 정규화된 상수 이름에서 가장 오른쪽 세그먼트를 제거합니다.

* `safe_constantize`를 추가했습니다. 이는 문자열을 상수로 변환하지만 상수 (또는 일부)가 존재하지 않을 경우 예외를 발생시키지 않고 `nil`을 반환합니다.

* `Array#extract_options!`를 사용할 때 `ActiveSupport::OrderedHash`는 이제 추출 가능한 것으로 표시됩니다.

* `Array#unshift`의 별칭으로 `Array#prepend`를 추가하고 `Array#<<`의 별칭으로 `Array#append`를 추가했습니다.

* Ruby 1.9의 빈 문자열 정의가 유니코드 공백으로 확장되었습니다. 또한 Ruby 1.8에서 이디오그래픽 공백 U`3000은 공백으로 간주됩니다.

* 인플렉터는 약어를 이해합니다.

* 범위를 생성하는 방법으로 `Time#all_day`, `Time#all_week`, `Time#all_quarter` 및 `Time#all_year`를 추가했습니다.

    ```ruby
    Event.where(:created_at => Time.now.all_week)
    Event.where(:created_at => Time.now.all_day)
    ```

* `Class#cattr_accessor` 및 관련 메소드에 `instance_accessor: false`를 옵션으로 추가했습니다.

* `ActiveSupport::OrderedHash`는 이제 매개변수를 스플래트로 받는 블록을 사용할 때 `#each` 및 `#each_pair`에 대해 다른 동작을 합니다.

* 개발 및 테스트에 사용하기 위해 `ActiveSupport::Cache::NullStore`를 추가했습니다.

* 표준 라이브러리의 `SecureRandom`을 선호하여 `ActiveSupport::SecureRandom`을 제거했습니다.

### 폐지 사항

* `ActiveSupport::Base64`는 `::Base64`를 선호합니다.

* Ruby 메모이제이션 패턴을 선호하여 `ActiveSupport::Memoizable`을 폐지했습니다.

* 대체 없이 `Module#synchronize`를 폐지했습니다. Ruby의 표준 라이브러리에서 모니터를 사용하십시오.

* `ActiveSupport::MessageEncryptor#encrypt` 및 `ActiveSupport::MessageEncryptor#decrypt`를 폐지했습니다.

* `ActiveSupport::BufferedLogger#silence`를 폐지했습니다. 특정 블록에 대한 로그를 억제하려면 해당 블록의 로그 레벨을 변경하십시오.

* `ActiveSupport::BufferedLogger#open_log`를 폐지했습니다. 이 메소드는 처음부터 공개되지 않아야 합니다.

* 로그 파일의 디렉토리를 자동으로 생성하는 `ActiveSupport::BufferedLogger`의 동작은 폐지되었습니다. 인스턴스화하기 전에 로그 파일의 디렉토리를 생성하십시오.

* `ActiveSupport::BufferedLogger#auto_flushing`을 폐지했습니다. 이제 파일 핸들의 동기화 수준을 설정하거나 파일 시스템을 조정하십시오. 이제 FS 캐시가 플러싱을 제어합니다.

    ```ruby
    f = File.open('foo.log', 'w')
    f.sync = true
    ActiveSupport::BufferedLogger.new f
    ```

* `ActiveSupport::BufferedLogger#flush`를 폐지했습니다. 파일 핸들에서 동기화를 설정하거나 파일 시스템을 조정하십시오.

크레딧
-------

Rails에 많은 시간을 투자한 많은 사람들을 위해 [Rails의 전체 기여자 목록](http://contributors.rubyonrails.org/)을 참조하십시오. 그들 모두에게 감사드립니다.

Rails 3.2 릴리스 노트는 [Vijay Dev](https://github.com/vijaydev)가 편집했습니다.
