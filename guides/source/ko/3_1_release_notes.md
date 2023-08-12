**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: da25f37b5b3eddff86c5b5b2cd24007f
루비 온 레일즈 3.1 릴리스 노트
===============================

루비 온 레일즈 3.1의 주요 기능:

* 스트리밍
* 역방향 마이그레이션
* 에셋 파이프라인
* 기본 자바스크립트 라이브러리로 jQuery 사용

이 릴리스 노트는 주요 변경 사항만 다룹니다. 다양한 버그 수정 및 변경 사항에 대해서는 변경 로그를 참조하거나 GitHub의 레일즈 메인 저장소의 [커밋 목록](https://github.com/rails/rails/commits/3-1-stable)을 확인하십시오.

--------------------------------------------------------------------------------

레일즈 3.1로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드하는 경우, 업그레이드하기 전에 충분한 테스트 커버리지가 있는 것이 좋습니다. 또한, 레일즈 3로 먼저 업그레이드하고 애플리케이션이 예상대로 실행되는지 확인한 후에 레일즈 3.1로 업데이트를 시도하십시오. 그런 다음 다음 변경 사항을 주의 깊게 살펴보십시오:

### 레일즈 3.1은 적어도 루비 1.8.7을 필요로 합니다.

레일즈 3.1은 루비 1.8.7 이상을 필요로 합니다. 이전 루비 버전의 지원은 공식적으로 중단되었으며 가능한 빨리 업그레이드해야 합니다. 레일즈 3.1은 또한 루비 1.9.2와 호환됩니다.

팁: 루비 1.8.7 p248 및 p249에는 레일즈를 충돌시키는 마샬링 버그가 있습니다. 루비 엔터프라이즈 에디션은 1.8.7-2010.02 이후로 이를 수정했습니다. 1.9 버전에서는 루비 1.9.1을 사용할 수 없으며, 완전히 세그폴트가 발생하므로 1.9.x를 사용하려면 1.9.2로 이동하십시오.

### 애플리케이션에서 업데이트해야 할 사항

다음 변경 사항은 애플리케이션을 레일즈 3.1.3으로 업그레이드하기 위한 것입니다. 이는 레일즈 3.1.x의 최신 버전입니다.

#### Gemfile

`Gemfile`에 다음 변경 사항을 추가하십시오.

```ruby
gem 'rails', '= 3.1.3'
gem 'mysql2'

# 새로운 에셋 파이프라인을 위해 필요합니다.
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# 레일즈 3.1에서는 jQuery가 기본 자바스크립트 라이브러리입니다.
gem 'jquery-rails'
```

#### config/application.rb

* 에셋 파이프라인에는 다음 추가 사항이 필요합니다:

    ```ruby
    config.assets.enabled = true
    config.assets.version = '1.0'
    ```

* 애플리케이션이 "/assets" 경로를 사용하는 경우 에셋에 대한 접두사를 변경하여 충돌을 피할 수 있습니다:

    ```ruby
    # 기본값은 '/assets'입니다.
    config.assets.prefix = '/asset-files'
    ```

#### config/environments/development.rb

* RJS 설정 `config.action_view.debug_rjs = true`를 제거하십시오.

* 에셋 파이프라인을 사용하는 경우 다음을 추가하십시오.

    ```ruby
    # 에셋을 압축하지 않습니다.
    config.assets.compress = false

    # 에셋을 로드하는 줄을 확장합니다.
    config.assets.debug = true
    ```

#### config/environments/production.rb

* 다시 말하지만, 아래의 대부분의 변경 사항은 에셋 파이프라인을 위한 것입니다. 이에 대해 자세히 알아보려면 [에셋 파이프라인](asset_pipeline.html) 가이드를 참조하십시오.

    ```ruby
    # 자바스크립트와 CSS를 압축합니다.
    config.assets.compress = true

    # 컴파일되지 않은 에셋이 누락된 경우 에셋 파이프라인으로 폴백하지 않습니다.
    config.assets.compile = false

    # 에셋 URL에 대한 다이제스트를 생성합니다.
    config.assets.digest = true

    # 기본값은 Rails.root.join("public/assets")입니다.
    # config.assets.manifest = YOUR_PATH

    # 추가 에셋을 사전 컴파일합니다. (application.js, application.css 및 모든 JS/CSS가 이미 추가되었습니다.)
    # config.assets.precompile `= %w( admin.js admin.css )


    # SSL을 통해 앱에 대한 모든 액세스를 강제하고 Strict-Transport-Security를 사용하며 안전한 쿠키를 사용합니다.
    # config.force_ssl = true
    ```

#### config/environments/test.rb

```ruby
# 성능을 위해 캐시 제어를 사용하여 테스트용 정적 에셋 서버를 구성합니다.
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

#### config/initializers/wrap_parameters.rb

* 매개변수를 중첩된 해시로 래핑하려면 다음 내용으로 이 파일을 추가하십시오. 이는 새로운 애플리케이션에서 기본적으로 활성화됩니다.

    ```ruby
    # 이 파일을 수정할 때 서버를 다시 시작해야 합니다.
    # 이 파일에는 기본적으로 활성화된 ActionController::ParamsWrapper의 설정이 포함되어 있습니다.

    # JSON에 대한 매개변수 래핑을 활성화합니다. :format을 빈 배열로 설정하여 비활성화할 수 있습니다.
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters :format => [:json]
    end

    # 기본적으로 JSON에서 루트 요소를 비활성화합니다.
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
    ```

#### 뷰에서 에셋 도우미 참조에서 :cache 및 :concat 옵션 제거

* 에셋 파이프라인에서는 :cache 및 :concat 옵션이 더 이상 사용되지 않으므로 뷰에서 이러한 옵션을 삭제하십시오.

레일즈 3.1 애플리케이션 생성
--------------------------------

```bash
# 'rails' 루비젬이 설치되어 있어야 합니다.
$ rails new myapp
$ cd myapp
```

### 젬 벤더링

레일즈는 이제 애플리케이션 루트에 있는 `Gemfile`을 사용하여 애플리케이션을 시작하는 데 필요한 젬을 결정합니다. 이 `Gemfile`은 [Bundler](https://github.com/carlhuda/bundler) 젬에 의해 처리되며, 그런 다음 모든 종속성을 설치합니다. 심지어 시스템 젬에 의존하지 않도록 애플리케이션에 로컬로 모든 종속성을 설치할 수도 있습니다.
추가 정보: - [bundler 홈페이지](https://bundler.io/)

### 최신 버전 사용하기

`Bundler`와 `Gemfile`은 새로운 `bundle` 명령어를 통해 Rails 애플리케이션을 쉽게 동결할 수 있게 해줍니다. 만약 Git 저장소에서 직접 번들을 생성하고 싶다면, `--edge` 플래그를 사용할 수 있습니다:

```bash
$ rails new myapp --edge
```

만약 로컬에서 Rails 저장소를 체크아웃하고 그것을 사용하여 애플리케이션을 생성하고 싶다면, `--dev` 플래그를 사용할 수 있습니다:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

Rails 아키텍처 변경 사항
---------------------------

### 에셋 파이프라인

Rails 3.1에서 가장 큰 변경 사항은 에셋 파이프라인입니다. 이를 통해 CSS와 JavaScript가 일급 코드로 취급되며, 플러그인과 엔진에서도 사용할 수 있도록 적절한 구성을 제공합니다.

에셋 파이프라인은 [Sprockets](https://github.com/rails/sprockets)에 의해 구동되며, [에셋 파이프라인](asset_pipeline.html) 가이드에서 자세히 다루고 있습니다.

### HTTP 스트리밍

HTTP 스트리밍은 Rails 3.1에서 새롭게 추가된 기능입니다. 이를 통해 서버가 응답을 생성하는 동안 브라우저가 스타일시트와 JavaScript 파일을 다운로드할 수 있습니다. 이 기능은 Ruby 1.9.2 이상에서 사용할 수 있으며, 웹 서버에서도 지원해야 합니다. NGINX와 Unicorn의 인기있는 조합은 이 기능을 활용할 준비가 되어 있습니다.

### 기본 JS 라이브러리는 이제 jQuery입니다

jQuery는 Rails 3.1과 함께 제공되는 기본 JavaScript 라이브러리입니다. 하지만 Prototype을 사용한다면 간단히 전환할 수 있습니다.

```bash
$ rails new myapp -j prototype
```

### Identity Map

Active Record는 Rails 3.1에서 Identity Map을 지원합니다. Identity Map은 이전에 인스턴스화된 레코드를 유지하고, 다시 액세스할 때 연관된 객체를 반환합니다. Identity Map은 요청 단위로 생성되며, 요청 완료 시에 플러시됩니다.

Rails 3.1에서는 Identity Map이 기본적으로 비활성화되어 있습니다.

Railties
--------

* jQuery가 새로운 기본 JavaScript 라이브러리로 설정되었습니다.

* jQuery와 Prototype은 더 이상 vendored되지 않으며, 이제 `jquery-rails`와 `prototype-rails` 젬에서 제공됩니다.

* 애플리케이션 생성기는 임의의 문자열을 받을 수 있는 `-j` 옵션을 허용합니다. "foo"를 전달하면 "foo-rails" 젬이 `Gemfile`에 추가되고, 애플리케이션 JavaScript 매니페스트에서 "foo"와 "foo_ujs"가 필요합니다. 현재 "prototype-rails"와 "jquery-rails"만 존재하며, 이러한 파일들을 에셋 파이프라인을 통해 제공합니다.

* 애플리케이션 또는 플러그인 생성기는 `--skip-gemfile` 또는 `--skip-bundle`이 지정되지 않은 경우 `bundle install`을 실행합니다.

* 컨트롤러 및 리소스 생성기는 이제 자동으로 에셋 스텁을 생성합니다 (`--skip-assets`로 비활성화할 수 있음). 이 스텁은 CoffeeScript와 Sass를 사용하며, 이러한 라이브러리가 사용 가능한 경우에만 사용됩니다.

* 스캐폴드 및 애플리케이션 생성기는 Ruby 1.9에서 실행될 때 Ruby 1.9 스타일 해시를 생성합니다. 이전 스타일 해시를 생성하려면 `--old-style-hash`를 전달할 수 있습니다.

* 스캐폴드 컨트롤러 생성기는 XML 대신 JSON을 위한 형식 블록을 생성합니다.

* Active Record 로깅은 STDOUT으로 이동되고 콘솔에서 인라인으로 표시됩니다.

* `config.force_ssl` 구성을 추가하여 `Rack::SSL` 미들웨어를 로드하고 모든 요청을 HTTPS 프로토콜 아래로 강제할 수 있습니다.

* `rails plugin new` 명령이 추가되었습니다. 이 명령은 gemspec, 테스트 및 테스트용 더미 애플리케이션을 생성하는 Rails 플러그인을 생성합니다.

* 기본 미들웨어 스택에 `Rack::Etag` 및 `Rack::ConditionalGet`이 추가되었습니다.

* 기본 미들웨어 스택에 `Rack::Cache`가 추가되었습니다.

* 엔진은 주요 업데이트를 받았습니다. 이제 어떤 경로에서든 마운트할 수 있으며, 에셋을 활성화하고, 생성기를 실행할 수 있습니다.

Action Pack
-----------

### Action Controller

* CSRF 토큰의 정품성을 검증할 수 없는 경우 경고 메시지가 표시됩니다.

* 특정 컨트롤러에서 데이터를 HTTPS 프로토콜을 통해 전송하도록 브라우저를 강제하려면 컨트롤러에서 `force_ssl`을 지정합니다. 특정 액션에 제한을 두려면 `:only` 또는 `:except`를 사용할 수 있습니다.

* `config.filter_parameters`에서 지정된 민감한 쿼리 문자열 매개변수는 로그의 요청 경로에서 필터링됩니다.

* `to_param`에 대해 `nil`을 반환하는 URL 매개변수는 이제 쿼리 문자열에서 제거됩니다.

* `ActionController::ParamsWrapper`가 추가되어 매개변수를 중첩된 해시로 래핑하고, 새로운 애플리케이션에서는 JSON 요청에 대해 기본적으로 활성화됩니다. 이는 `config/initializers/wrap_parameters.rb`에서 사용자 정의할 수 있습니다.

* `config.action_controller.include_all_helpers`가 추가되었습니다. 기본적으로 `helper :all`이 `ActionController::Base`에서 수행되어 모든 헬퍼가 기본적으로 포함됩니다. `include_all_helpers`를 `false`로 설정하면 application_helper와 컨트롤러에 해당하는 헬퍼 (예: foo_controller의 경우 foo_helper)만 포함됩니다.

* `url_for` 및 명명된 URL 헬퍼는 이제 `:subdomain` 및 `:domain`을 옵션으로 사용할 수 있습니다.
* `Base.http_basic_authenticate_with`를 추가하여 단일 클래스 메소드 호출로 간단한 http 기본 인증을 수행합니다.

    ```ruby
    class PostsController < ApplicationController
      USER_NAME, PASSWORD = "dhh", "secret"

      before_filter :authenticate, :except => [ :index ]

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end

      private
        def authenticate
          authenticate_or_request_with_http_basic do |user_name, password|
            user_name == USER_NAME && password == PASSWORD
          end
        end
    end
    ```

    ..이제 다음과 같이 작성할 수 있습니다.

    ```ruby
    class PostsController < ApplicationController
      http_basic_authenticate_with :name => "dhh", :password => "secret", :except => :index

      def index
        render :text => "Everyone can see me!"
      end

      def edit
        render :text => "I'm only accessible if you know the password"
      end
    end
    ```

* 스트리밍 지원을 추가했습니다. 다음과 같이 활성화할 수 있습니다:

    ```ruby
    class PostsController < ActionController::Base
      stream
    end
    ```

    `:only` 또는 `:except`를 사용하여 일부 동작에 제한할 수 있습니다. 자세한 내용은 [`ActionController::Streaming`](https://api.rubyonrails.org/v3.1.0/classes/ActionController/Streaming.html)에서 문서를 읽어보세요.

* 리디렉션 라우트 메소드는 이제 URL의 해당 부분만 변경하는 옵션 해시나 호출 가능한 객체도 허용합니다. 

### 액션 디스패치

* `config.action_dispatch.x_sendfile_header`는 이제 기본값으로 `nil`을 사용하며, `config/environments/production.rb`에서 특정 값을 설정하지 않습니다. 이렇게 함으로써 서버에서 `X-Sendfile-Type`을 통해 설정할 수 있습니다.

* `ActionDispatch::MiddlewareStack`은 이제 상속 대신 합성을 사용하며 더 이상 배열이 아닙니다.

* `ActionDispatch::Request.ignore_accept_header`를 추가하여 accept 헤더를 무시할 수 있습니다.

* 기본 스택에 `Rack::Cache`를 추가했습니다.

* etag 책임을 `ActionDispatch::Response`에서 미들웨어 스택으로 이동했습니다.

* 루비 세계 전반에 대한 호환성을 위해 `Rack::Session` 저장소 API에 의존합니다. 이는 `Rack::Session`이 `#get_session`이 네 개의 인수를 받아들이고 `#destroy` 대신 `#destroy_session`을 요구하기 때문에 하위 호환성이 없습니다.

* 템플릿 조회는 이제 상속 체인에서 더 멀리 검색합니다.

### 액션 뷰

* `form_tag`에 `:authenticity_token` 옵션을 추가하여 사용자 정의 처리 또는 토큰을 생략할 수 있습니다. `:authenticity_token => false`를 전달하여 토큰을 생략할 수 있습니다.

* `ActionView::Renderer`를 생성하고 `ActionView::Context`에 대한 API를 지정했습니다.

* Rails 3.1에서는 장소 `SafeBuffer` 변이가 금지되었습니다.

* HTML5 `button_tag` 도우미를 추가했습니다.

* `file_field`는 자동으로 둘러싼 폼에 `:multipart => true`를 추가합니다.

* `:data` 옵션의 `:data` 해시에서 HTML5 `data-*` 속성을 생성하는 편리한 관용구를 추가했습니다.

    ```ruby
    tag("div", :data => {:name => 'Stephen', :city_state => %w(Chicago IL)})
    # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
    ```

키는 대시로 변환됩니다. 문자열과 심볼을 제외한 값은 JSON으로 인코딩됩니다.

* `csrf_meta_tag`는 `csrf_meta_tags`로 이름이 변경되었으며 하위 호환성을 위해 `csrf_meta_tag`에 별칭이 추가되었습니다.

* 이전 템플릿 핸들러 API는 사용되지 않으며, 새로운 API는 템플릿 핸들러가 `call`에 응답할 수 있도록 요구합니다.

* rhtml 및 rxml이 마침내 템플릿 핸들러에서 제거되었습니다.

* `config.action_view.cache_template_loading`이 다시 돌아와 템플릿을 캐시할지 여부를 결정할 수 있습니다.

* 제출 폼 도우미는 이제 "object_name_id"라는 ID를 생성하지 않습니다.

* `FormHelper#form_for`에서 `:html` 해시를 통해가 아닌 직접 옵션으로 `:method`를 지정할 수 있도록 허용합니다. `form_for(@post, remote: true, method: :delete)` 대신 `form_for(@post, remote: true, html: { method: :delete })`를 사용합니다.

* `JavaScriptHelper#j()`를 `JavaScriptHelper#escape_javascript()`의 별칭으로 제공합니다. 이는 JavaScriptHelper를 사용하여 템플릿 내에서 JSON 젬이 추가하는 `Object#j()` 메소드를 대체합니다.

* 날짜/시간 선택기에서 AM/PM 형식을 허용합니다.

* `auto_link`가 Rails에서 제거되어 [rails_autolink 젬](https://github.com/tenderlove/rails_autolink)으로 분리되었습니다.

Active Record
-------------

* 개별 모델의 테이블 이름을 단수/복수로 변환하는 클래스 메소드 `pluralize_table_names`를 추가했습니다. 이전에는 `ActiveRecord::Base.pluralize_table_names`를 통해 모든 모델에 대해 전역적으로 설정할 수 있었습니다.

    ```ruby
    class User < ActiveRecord::Base
      self.pluralize_table_names = false
    end
    ```

* 단수 관계에 속성을 블록 설정하는 기능을 추가했습니다. 블록은 인스턴스가 초기화된 후에 호출됩니다.

    ```ruby
    class User < ActiveRecord::Base
      has_one :account
    end

    user.build_account{ |a| a.credit_limit = 100.0 }
    ```

* `ActiveRecord::Base.attribute_names`를 추가하여 속성 이름 목록을 반환합니다. 모델이 추상적이거나 테이블이 존재하지 않는 경우 빈 배열을 반환합니다.

* CSV 픽스처는 사용이 중단되었으며, Rails 3.2.0에서 지원이 제거될 예정입니다.

* `ActiveRecord#new`, `ActiveRecord#create` 및 `ActiveRecord#update_attributes`는 모두 속성을 할당할 때 어떤 역할을 고려할지 지정할 수 있는 두 번째 해시를 옵션으로 받습니다. 이는 Active Model의 대량 할당 기능을 기반으로 구축되었습니다.
```ruby
class Post < ActiveRecord::Base
  attr_accessible :title
  attr_accessible :title, :published_at, :as => :admin
end

Post.new(params[:post], :as => :admin)
```

* `default_scope`는 이제 블록, 람다 또는 호출에 응답하는 다른 객체를 사용하여 지연 평가를 위해 사용할 수 있습니다.

* 기본 스코프는 이제 가능한 최신 시점에 평가되어 Model.unscoped를 통해 제거할 수 없는 기본 스코프를 암시적으로 포함하는 스코프가 생성되는 문제를 피할 수 있습니다.

* PostgreSQL 어댑터는 PostgreSQL 버전 8.2 이상만 지원합니다.

* `ConnectionManagement` 미들웨어는 랙 바디가 플러시된 후에 연결 풀을 정리하도록 변경되었습니다.

* Active Record에 `update_column` 메소드가 추가되었습니다. 이 새로운 메소드는 유효성 검사와 콜백을 건너뛰고 객체의 특정 속성을 업데이트합니다. `update_attributes` 또는 `update_attribute`를 사용하는 것이 권장되며, `updated_at` 열의 수정을 포함한 모든 콜백을 실행하지 않으려는 경우에만 사용해야 합니다. 이 메소드는 새로운 레코드에 대해 호출해서는 안 됩니다.

* `:through` 옵션을 가진 연관 관계는 이제 `:through` 또는 소스 연관 관계로 다른 연관 관계를 사용할 수 있습니다. 이는 `:through` 옵션과 `has_and_belongs_to_many` 연관 관계를 가진 다른 연관 관계를 포함하여 모든 연관 관계를 사용할 수 있음을 의미합니다.

* 현재 데이터베이스 연결에 대한 구성은 이제 `ActiveRecord::Base.connection_config`를 통해 액세스할 수 있습니다.

* 제한과 오프셋은 COUNT 쿼리에서 둘 다 제공되지 않는 한 제거됩니다.

```ruby
People.limit(1).count           # => 'SELECT COUNT(*) FROM people'
People.offset(1).count          # => 'SELECT COUNT(*) FROM people'
People.limit(1).offset(1).count # => 'SELECT COUNT(*) FROM people LIMIT 1 OFFSET 1'
```

* `ActiveRecord::Associations::AssociationProxy`가 분리되었습니다. 이제 연관 관계에 작용하는 `Association` 클래스(및 하위 클래스)와 컬렉션 연관 관계를 프록시하는 별도의 얇은 래퍼인 `CollectionProxy`가 있습니다. 이는 네임스페이스 오염을 방지하고 관심사를 분리하며 추가적인 리팩토링을 허용합니다.

* 단수 연관 관계(`has_one`, `belongs_to`)는 더 이상 프록시를 가지지 않고 연관된 레코드 또는 `nil`을 반환합니다. 따라서 `bob.mother.create`와 같은 문서화되지 않은 메소드를 사용해서는 안 되며, 대신 `bob.create_mother`를 사용해야 합니다.

* `has_many :through` 연관 관계에 `:dependent` 옵션을 지원합니다. 역사적 및 실용적인 이유로 `:delete_all`은 `association.delete(*records)`에 의해 사용되는 기본 삭제 전략이지만, 일반적인 has_many의 기본 전략은 `:nullify`입니다. 또한, 이 기능은 소스 반영이 belongs_to인 경우에만 작동합니다. 다른 상황에서는 직접 through 연관 관계를 수정해야 합니다.

* `has_and_belongs_to_many` 및 `has_many :through`에 대한 `association.destroy`의 동작이 변경되었습니다. 이제 연관 관계에서 'destroy' 또는 'delete'는 (필요에 따라) '링크를 제거하라'는 의미가 됩니다. 연관된 레코드를 (필수적으로) '제거하라'는 의미가 아닙니다.

* 이전에 `has_and_belongs_to_many.destroy(*records)`는 레코드 자체를 삭제했지만, 조인 테이블의 레코드는 삭제하지 않았습니다. 이제 조인 테이블의 레코드를 삭제합니다.

* 이전에 `has_many_through.destroy(*records)`는 레코드 자체와 조인 테이블의 레코드를 삭제했습니다. [참고: 이것은 항상 그렇지는 않았습니다. 이전 버전의 Rails는 레코드 자체만 삭제했습니다.] 이제 조인 테이블의 레코드만 삭제합니다.

* 이 변경은 일부로 역호환성이 있지만, 변경하기 전에 '폐기'할 방법이 없습니다. 이 변경은 다른 유형의 연관 관계에서 'destroy' 또는 'delete'의 의미에 일관성을 갖기 위해 수행되었습니다. 레코드 자체를 삭제하려면 `records.association.each(&:destroy)`를 사용할 수 있습니다.

* `change_table`에 `:bulk => true` 옵션을 추가하여 ALTER 문을 사용하여 블록에서 정의된 모든 스키마 변경을 수행할 수 있습니다.

```ruby
change_table(:users, :bulk => true) do |t|
  t.string :company_name
  t.change :birthdate, :datetime
end
```

* `has_and_belongs_to_many` 조인 테이블의 속성에 대한 지원이 제거되었습니다. `has_many :through`를 사용해야 합니다.

* `has_one` 및 `belongs_to` 연관 관계에 대한 `create_association!` 메소드가 추가되었습니다.

* 마이그레이션은 이제 역전 가능하며, Rails는 마이그레이션을 역전하는 방법을 자동으로 결정합니다. 역전 가능한 마이그레이션을 사용하려면 `change` 메소드를 정의하면 됩니다.

```ruby
class MyMigration < ActiveRecord::Migration
  def change
    create_table(:horses) do |t|
      t.column :content, :text
      t.column :remind_at, :datetime
    end
  end
end
```

* 일부 작업은 자동으로 역전될 수 없습니다. 그러한 작업을 역전하는 방법을 알고 있는 경우에는 마이그레이션에서 `up` 및 `down`을 정의해야 합니다. 역전할 수 없는 작업을 change에서 정의하면, 내려갈 때 `IrreversibleMigration` 예외가 발생합니다.

* 마이그레이션은 이제 클래스 메소드 대신 인스턴스 메소드를 사용합니다.
```ruby
class FooMigration < ActiveRecord::Migration
  def up # Not self.up
    # ...
  end
end
```

* 모델과 생성적인 마이그레이션 생성기에서 생성된 마이그레이션 파일은 일반적인 `up` 및 `down` 메서드 대신 역방향 마이그레이션의 `change` 메서드를 사용합니다.

* 연관된 문자열 SQL 조건을 보간하는 기능이 제거되었습니다. 대신에 proc를 사용해야 합니다.

```ruby
has_many :things, :conditions => 'foo = #{bar}'          # 이전
has_many :things, :conditions => proc { "foo = #{bar}" } # 이후
```

proc 내부에서 `self`는 연관성의 소유자인 객체입니다. 그러나 연관성을 이른바 "이저 로딩"하는 경우에는 `self`가 연관성이 있는 클래스입니다.

proc 내부에는 "일반적인" 조건을 사용할 수 있으므로 다음과 같이 작성할 수도 있습니다.

```ruby
has_many :things, :conditions => proc { ["foo = ?", bar] }
```

* 이전에는 `has_and_belongs_to_many` 연관성의 `:insert_sql` 및 `:delete_sql`에서 'record'를 호출하여 삽입되거나 삭제되는 레코드를 가져올 수 있었습니다. 이제 이는 proc의 인수로 전달됩니다.

* `ActiveRecord::Base#has_secure_password` (via `ActiveModel::SecurePassword`)를 추가하여 BCrypt 암호화 및 소금 처리와 함께 간단한 비밀번호 사용을 캡슐화했습니다.

```ruby
# 스키마: User(name:string, password_digest:string, password_salt:string)
class User < ActiveRecord::Base
  has_secure_password
end
```

* 모델이 생성될 때 `belongs_to` 또는 `references` 열에 대해 `add_index`가 기본적으로 추가됩니다.

* `belongs_to` 객체의 id를 설정하면 해당 객체에 대한 참조가 업데이트됩니다.

* `ActiveRecord::Base#dup` 및 `ActiveRecord::Base#clone`의 의미가 일반적인 Ruby dup 및 clone 의미와 더 가까워졌습니다.

* `ActiveRecord::Base#clone`을 호출하면 레코드의 얕은 복사본이 생성되며, 동결된 상태도 복사됩니다. 콜백은 호출되지 않습니다.

* `ActiveRecord::Base#dup`을 호출하면 레코드가 복제되며, after initialize 후크가 호출됩니다. 동결된 상태는 복사되지 않으며, 모든 연관성이 지워집니다. 복제된 레코드는 `new_record?`에 대해 `true`를 반환하고, `nil` id 필드를 가지며, 저장할 수 있습니다.

* 쿼리 캐시는 이제 준비된 문과 함께 작동합니다. 응용 프로그램에는 변경 사항이 필요하지 않습니다.

Active Model
------------

* `attr_accessible`는 역할을 지정하는 옵션 `:as`를 허용합니다.

* `InclusionValidator`, `ExclusionValidator`, `FormatValidator`는 이제 proc, lambda 또는 `call`에 응답하는 모든 것을 옵션으로 허용합니다. 이 옵션은 현재 레코드를 인수로 받아 `InclusionValidator`의 경우 `include?`에 응답하는 객체를 반환하고, `ExclusionValidator`의 경우 `include?`에 응답하는 객체를 반환하며, `FormatValidator`의 경우 정규 표현식 객체를 반환합니다.

* BCrypt 암호화 및 소금 처리와 함께 간단한 비밀번호 사용을 캡슐화하기 위해 `ActiveModel::SecurePassword`를 추가했습니다.

* `ActiveModel::AttributeMethods`는 필요에 따라 속성을 정의할 수 있게 합니다.

* 관찰자를 선택적으로 활성화 및 비활성화할 수 있도록 지원이 추가되었습니다.

* 대체 `I18n` 네임스페이스 조회는 더 이상 지원되지 않습니다.

Active Resource
---------------

* 모든 요청에 대한 기본 형식이 JSON으로 변경되었습니다. XML을 계속 사용하려면 클래스에서 `self.format = :xml`을 설정해야 합니다. 예를 들어,

```ruby
class User < ActiveResource::Base
  self.format = :xml
end
```

Active Support
--------------

* `ActiveSupport::Dependencies`는 이제 `load_missing_constant`에서 기존 상수를 찾으면 `NameError`를 발생시킵니다.

* `STDOUT` 및 `STDERR` 모두를 음소거하는 새로운 보고 방법인 `Kernel#quietly`가 추가되었습니다.

* `String#inquiry`를 사용하여 문자열을 `StringInquirer` 객체로 변환하는 편의 메서드가 추가되었습니다.

* 객체가 다른 객체에 포함되어 있는지 테스트하기 위해 `Object#in?`가 추가되었습니다.

* `LocalCache` 전략은 이제 실제 미들웨어 클래스이며 익명 클래스가 아닙니다.

* `ActiveSupport::Dependencies::ClassCache` 클래스가 도입되어 다시로드 가능한 클래스에 대한 참조를 보관합니다.

* `ActiveSupport::Dependencies::Reference`가 새로운 `ClassCache`를 직접 활용하도록 리팩터링되었습니다.

* Ruby 1.8에서 `Range#include?`의 별칭으로 `Range#cover?`를 백포트했습니다.

* Date/DateTime/Time에 `weeks_ago` 및 `prev_week`를 추가했습니다.

* `ActiveSupport::Dependencies.remove_unloadable_constants!`에 `before_remove_const` 콜백을 추가했습니다.

폐기 예정:

* `ActiveSupport::SecureRandom`은 Ruby 표준 라이브러리의 `SecureRandom`을 사용하기 위해 폐기되었습니다.

크레딧
-------

Rails를 안정적이고 견고한 프레임워크로 만들기 위해 많은 시간을 투자한 많은 사람들에게는 [Rails 기여자 전체 목록](https://contributors.rubyonrails.org/)을 참조하십시오. 그들 모두에게 경의를 표합니다.

Rails 3.1 릴리스 노트는 [Vijay Dev](https://github.com/vijaydev)가 작성했습니다.
