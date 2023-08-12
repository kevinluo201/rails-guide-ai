**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: df23e2b31bd56973a30f38f5a1c29b52
Ruby on Rails 5.0 릴리스 노트
===============================

Rails 5.0의 주요 기능:

* Action Cable
* Rails API
* Active Record Attributes API
* Test Runner
* Rake보다 `rails` CLI의 독점적 사용
* Sprockets 3
* Turbolinks 5
* Ruby 2.2.2+가 필요합니다.

이 릴리스 노트는 주요 변경 사항만 다룹니다. 다양한 버그 수정 및 변경 사항에 대해서는 변경 로그를 참조하거나 GitHub의 주요 Rails 저장소의 [커밋 목록](https://github.com/rails/rails/commits/5-0-stable)을 확인하십시오.

--------------------------------------------------------------------------------

Rails 5.0으로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드하는 경우, 업그레이드하기 전에 충분한 테스트 커버리지를 가지고 있는 것이 좋습니다. 또한, Rails 4.2로 먼저 업그레이드하고 애플리케이션이 예상대로 작동하는지 확인한 후에 Rails 5.0으로 업데이트를 시도해야 합니다. 업그레이드할 때 주의해야 할 사항은 [Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0) 가이드에서 확인할 수 있습니다.


주요 기능
--------------

### Action Cable

Action Cable은 Rails 5에서 새로운 프레임워크입니다. 이는 [WebSockets](https://en.wikipedia.org/wiki/WebSocket)을 Rails 애플리케이션의 나머지 부분과 매끄럽게 통합합니다.

Action Cable은 실시간 기능을 Ruby로 작성할 수 있도록 해주며, Rails 애플리케이션의 나머지 부분과 동일한 스타일과 형식으로 작성됩니다. 동시에 성능과 확장성을 유지합니다. 이는 클라이언트 측 JavaScript 프레임워크와 서버 측 Ruby 프레임워크를 모두 제공하는 풀 스택 오퍼링입니다. Active Record나 선택한 ORM으로 작성된 전체 도메인 모델에 액세스할 수 있습니다.

자세한 내용은 [Action Cable 개요](action_cable_overview.html) 가이드를 참조하십시오.

### API 애플리케이션

Rails를 사용하여 API 전용 애플리케이션을 만들 수 있습니다. 이는 [Twitter](https://dev.twitter.com) 또는 [GitHub](https://developer.github.com) API와 유사한 공개 및 사용자 정의 애플리케이션을 제공하는 데 유용합니다.

다음 명령을 사용하여 새로운 API Rails 앱을 생성할 수 있습니다:

```bash
$ rails new my_api --api
```

이는 주로 브라우저 애플리케이션에 유용한 미들웨어를 기본적으로 포함하지 않도록 애플리케이션을 구성합니다.

- `ApplicationController`을 `ActionController::API`에서 상속하도록 설정합니다. 마찬가지로, 이는 브라우저 애플리케이션에서 주로 사용되는 기능을 제공하는 Action Controller 모듈을 제외합니다.
- 새로운 리소스를 생성할 때 뷰, 헬퍼 및 에셋을 생성하지 않도록 생성기를 구성합니다.

이 애플리케이션은 API를 위한 기본 기능을 제공하며, 애플리케이션의 요구에 맞게 기능을 [구성할 수 있습니다](api_app.html).
더 많은 정보를 위해 [API 전용 애플리케이션을 위한 Rails 사용](api_app.html) 가이드를 참조하십시오.

### Active Record 속성 API

모델에 타입이 지정된 속성을 정의합니다. 필요한 경우 기존 속성의 타입을 무시합니다.
이를 통해 모델에 할당될 때 SQL로 값이 변환되고 변환되는 방식을 제어할 수 있습니다.
또한 `ActiveRecord::Base.where`에 전달되는 값의 동작을 변경하여 Active Record의 많은 부분에서 도메인 객체를 사용할 수 있게 해줍니다.
구현 세부 정보나 몽키패칭에 의존하지 않고도 사용할 수 있습니다.

이를 통해 달성할 수 있는 몇 가지 사항:

- Active Record에서 감지한 타입을 무시할 수 있습니다.
- 기본값을 제공할 수도 있습니다.
- 속성은 데이터베이스 열로 백업되지 않아도 됩니다.

```ruby
# db/schema.rb
create_table :store_listings, force: true do |t|
  t.decimal :price_in_cents
  t.string :my_string, default: "original default"
end
```

```ruby
# app/models/store_listing.rb
class StoreListing < ActiveRecord::Base
end
```

```ruby
store_listing = StoreListing.new(price_in_cents: '10.1')

# 이전
store_listing.price_in_cents # => BigDecimal.new(10.1)
StoreListing.new.my_string # => "original default"

class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer # 사용자 정의 타입
  attribute :my_string, :string, default: "new default" # 기본값
  attribute :my_default_proc, :datetime, default: -> { Time.now } # 기본값
  attribute :field_without_db_column, :integer, array: true
end

# 이후
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes # => {field_without_db_column: [1, 2, 3]}
```

**사용자 정의 타입 생성:**

값 타입에 정의된 메서드에 응답하는 한 사용자 정의 타입을 정의할 수 있습니다. `deserialize` 또는 `cast` 메서드는 타입 객체에 대해 호출되며, 데이터베이스나 컨트롤러에서의 원시 입력을 사용합니다. 예를 들어 Money 데이터와 같은 사용자 정의 변환을 수행할 때 유용합니다.

**쿼리:**

`ActiveRecord::Base.where`가 호출될 때, 모델 클래스에서 정의된 타입을 사용하여 값을 SQL로 변환하며, 타입 객체에 대해 `serialize` 메서드를 호출합니다.

이를 통해 객체는 SQL 쿼리를 수행할 때 값을 변환하는 방법을 지정할 수 있습니다.

**Dirty Tracking:**

속성의 타입은 Dirty Tracking이 수행되는 방식을 변경할 수 있습니다.

자세한 내용은 [문서](https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html)를 참조하십시오.


### 테스트 실행기

Rails에서 테스트를 실행하는 기능을 향상시키기 위해 새로운 테스트 실행기가 도입되었습니다.
이 테스트 실행기를 사용하려면 `bin/rails test`를 입력하면 됩니다.

테스트 실행기는 `RSpec`, `minitest-reporters`, `maxitest` 등을 참고하여 개발되었습니다.
다음과 같은 주요 개선 사항을 포함하고 있습니다:

- 테스트의 줄 번호를 사용하여 단일 테스트를 실행합니다.
- 테스트의 줄 번호를 지정하여 여러 테스트를 실행합니다.
- 실패 메시지를 개선하여 실패한 테스트를 다시 실행하기 쉽게 합니다.
- `-f` 옵션을 사용하여 실패 발생 시 테스트를 즉시 중단하고 전체 테스트 스위트를 기다리지 않습니다.
- `-d` 옵션을 사용하여 전체 테스트 실행이 완료될 때까지 테스트 출력을 연기합니다.
- `-b` 옵션을 사용하여 완전한 예외 백트레이스 출력을 제공합니다.
- minitest와 통합하여 `-s` 옵션으로 테스트 시드 데이터, `-n` 옵션으로 특정 테스트 이름으로 실행, `-v` 옵션으로 더 나은 상세 출력 등의 옵션을 사용할 수 있습니다.
- 컬러로 구분된 테스트 출력.
Railties
--------

자세한 변경 사항은 [Changelog][railties]를 참조하십시오.

### 제거 사항

*   디버거 지원이 제거되었습니다. 대신 byebug를 사용하십시오. `debugger`는 Ruby 2.2에서 지원되지 않습니다.
    ([commit](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))

*   `test:all` 및 `test:all:db` 작업이 폐기되었습니다.
    ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   `Rails::Rack::LogTailer`가 폐기되었습니다.
    ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   `RAILS_CACHE` 상수가 폐기되었습니다.
    ([commit](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   `serve_static_assets` 구성이 폐기되었습니다.
    ([commit](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   `doc:app`, `doc:rails`, `doc:guides` 문서 작업이 제거되었습니다.
    ([commit](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   기본 스택에서 `Rack::ContentLength` 미들웨어가 제거되었습니다.
    ([Commit](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### 폐기 사항

*   `config.static_cache_control`이 `config.public_file_server.headers`를 사용하도록 폐기되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   `config.serve_static_files`가 `config.public_file_server.enabled`를 사용하도록 폐기되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*   `rails` 작업 네임스페이스의 작업들이 `app` 네임스페이스를 사용하도록 폐기되었습니다.
    (예: `rails:update` 및 `rails:template` 작업은 `app:update` 및 `app:template`로 이름이 변경되었습니다.)
    ([Pull Request](https://github.com/rails/rails/pull/23439))

### 주목할만한 변경 사항

*   Rails 테스트 러너 `bin/rails test`가 추가되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/19216))

*   새로 생성된 애플리케이션 및 플러그인은 Markdown 형식의 `README.md`를 가지게 됩니다.
    ([commit](https://github.com/rails/rails/commit/89a12c931b1f00b90e74afffcdc2fc21f14ca663),
     [Pull Request](https://github.com/rails/rails/pull/22068))

*   `bin/rails restart` 작업이 추가되어 `tmp/restart.txt`를 터치하여 Rails 앱을 다시 시작할 수 있습니다.
    ([Pull Request](https://github.com/rails/rails/pull/18965))

*   `bin/rails initializers` 작업이 추가되어 Rails에 의해 호출되는 모든 정의된 초기화 파일을 순서대로 출력합니다.
    ([Pull Request](https://github.com/rails/rails/pull/19323))

*   개발 모드에서 캐싱을 활성화 또는 비활성화하기 위해 `bin/rails dev:cache`가 추가되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/20961))

*   개발 환경을 자동으로 업데이트하기 위해 `bin/update` 스크립트가 추가되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/20972))

*   Rake 작업을 `bin/rails`를 통해 프록시합니다.
    ([Pull Request](https://github.com/rails/rails/pull/22457),
     [Pull Request](https://github.com/rails/rails/pull/22288))

*   새로운 애플리케이션은 Linux 및 macOS에서 이벤트 기반 파일 시스템 모니터를 활성화합니다. 이 기능은 생성기에 `--skip-listen`을 전달하여 선택적으로 사용하지 않을 수 있습니다.
    ([commit](https://github.com/rails/rails/commit/de6ad5665d2679944a9ee9407826ba88395a1003),
    [commit](https://github.com/rails/rails/commit/94dbc48887bf39c241ee2ce1741ee680d773f202))

*   새로운 앱에서 환경 변수 `RAILS_LOG_TO_STDOUT`를 사용하여 프로덕션에서 STDOUT로 로그를 기록할 수 있습니다.
    ([Pull Request](https://github.com/rails/rails/pull/23734))

*   새로운 애플리케이션에 대해 IncludeSubdomains 헤더와 함께 HSTS를 활성화합니다.
    ([Pull Request](https://github.com/rails/rails/pull/23852))

*   애플리케이션 생성기는 Spring이 추가로 감시할 일반 파일을 알려주는 `config/spring.rb` 파일을 작성합니다.
    ([commit](https://github.com/rails/rails/commit/b04d07337fd7bc17e88500e9d6bcd361885a45f8))

*   새로운 앱을 생성할 때 Action Mailer를 건너뛰기 위해 `--skip-action-mailer`를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/18288))

*   `tmp/sessions` 디렉토리와 관련된 clear rake 작업이 제거되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/18314))

*   스캐폴드 생성기에 의해 생성된 `_form.html.erb`가 로컬 변수를 사용하도록 변경되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/13434))

*   프로덕션 환경에서 클래스의 자동로딩이 비활성화되었습니다.
    ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

Action Pack
-----------

자세한 변경 사항은 [Changelog][action-pack]를 참조하십시오.

### 제거 사항

*   `ActionDispatch::Request::Utils.deep_munge`가 제거되었습니다.
    ([commit](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   `ActionController::HideActions`가 제거되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/18371))

*   `respond_to` 및 `respond_with` 플레이스홀더 메서드가 제거되었습니다. 이 기능은
    [responders](https://github.com/plataformatec/responders) 젬으로 이동되었습니다.
    ([commit](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   폐기된 어설션 파일이 제거되었습니다.
    ([commit](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   URL 헬퍼에서 문자열 키 사용이 폐기되었습니다.
    ([commit](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   `*_path` 헬퍼의 `only_path` 옵션 사용이 폐기되었습니다.
    ([commit](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))
*   `NamedRouteCollection#helpers`를 삭제했습니다.
    ([커밋](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*   `:to` 옵션에 `#`이 없는 라우트 정의를 지원하는 기능을 삭제했습니다.
    ([커밋](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   `ActionDispatch::Response#to_ary`를 삭제했습니다.
    ([커밋](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   `ActionDispatch::Request#deep_munge`를 삭제했습니다.
    ([커밋](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   `ActionDispatch::Http::Parameters#symbolized_path_parameters`를 삭제했습니다.
    ([커밋](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   컨트롤러 테스트에서 `use_route` 옵션을 삭제했습니다.
    ([커밋](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   `assigns`와 `assert_template`를 삭제했습니다. 두 메서드는
    [rails-controller-testing](https://github.com/rails/rails-controller-testing)
    젬으로 이동되었습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/20138))

### 폐기 예정 기능

*   `*_filter` 콜백을 `*_action` 콜백으로 대체하기 위해 모든 콜백을 폐기 예정으로 지정했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/18410))

*   통합 테스트 메서드인 `*_via_redirect`을 폐기 예정으로 지정했습니다. 동일한 동작을 위해 요청 호출 후 수동으로 `follow_redirect!`를 사용하세요.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/18693))

*   `AbstractController#skip_action_callback`을 개별 `skip_callback` 메서드로 대체하기 위해 폐기 예정으로 지정했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/19060))

*   `render` 메서드의 `:nothing` 옵션을 폐기 예정으로 지정했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/20336))

*   `head` 메서드의 첫 번째 매개변수로 `Hash`를 전달하고 기본 상태 코드를 사용하는 것을 폐기 예정으로 지정했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/20407))

*   미들웨어 클래스 이름에 대해 문자열이나 심볼을 사용하는 것을 폐기 예정으로 지정했습니다. 대신 클래스 이름을 사용하세요.
    ([커밋](https://github.com/rails/rails/commit/83b767ce))

*   MIME 유형에 상수를 통해 접근하는 것을 폐기 예정으로 지정했습니다. 대신 심볼과 첨자 연산자를 사용하세요 (예: `Mime[:html]`).
    ([풀 리퀘스트](https://github.com/rails/rails/pull/21869))

*   `redirect_to :back`을 `RedirectBackError`의 가능성을 제거하기 위해 필수 `fallback_location` 인수를 받는 `redirect_back`으로 대체했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/22506))

*   `ActionDispatch::IntegrationTest`와 `ActionController::TestCase`에서 위치 매개변수를 키워드 인수로 대체하기 위해 폐기 예정으로 지정했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/18323))

*   `:controller`와 `:action` 경로 매개변수를 폐기 예정으로 지정했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/23980))

*   컨트롤러 인스턴스에서 `env` 메서드를 폐기 예정으로 지정했습니다.
    ([커밋](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   `ActionDispatch::ParamsParser`를 폐기 예정으로 지정하고 미들웨어 스택에서 제거했습니다. 파라미터 파서를 구성하기 위해 `ActionDispatch::Request.parameter_parsers=`를 사용하세요.
    ([커밋](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1),
    [커밋](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))

### 주목할만한 변경 사항

*   임의의 템플릿을 컨트롤러 액션 외부에서 렌더링하기 위해 `ActionController::Renderer`를 추가했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/18546))

*   `ActionController::TestCase`와 `ActionDispatch::Integration` HTTP 요청 메서드에서 키워드 인수 구문으로 마이그레이션했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/18323))

*   만료되지 않는 응답을 캐시하기 위해 `http_cache_forever`를 Action Controller에 추가했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/18394))

*   요청 변형에 더 쉽게 접근할 수 있도록 지원했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/18939))

*   해당 템플릿이 없는 액션에 대해 에러를 발생시키는 대신 `head :no_content`를 렌더링하도록 변경했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/19377))

*   컨트롤러에 대한 기본 폼 빌더를 재정의할 수 있는 기능을 추가했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/19736))

*   API 전용 앱을 지원하기 위해 `ActionController::API`를 추가했습니다. 이러한 종류의 애플리케이션을 위한 `ActionController::Base`의 대체제로 사용됩니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/19832))

*   `ActionController::Parameters`가 더 이상 `HashWithIndifferentAccess`를 상속하지 않도록 변경했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/20868))

*   `config.force_ssl`와 `config.ssl_options`를 쉽게 활성화하고 비활성화할 수 있도록 변경했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/21520))

*   `ActionDispatch::Static`에 임의의 헤더를 반환할 수 있는 기능을 추가했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/19135))

*   `protect_from_forgery`의 기본값을 `prepend`에서 `false`로 변경했습니다.
    ([커밋](https://github.com/rails/rails/commit/39794037817703575c35a75f1961b01b83791191))
* `ActionController::TestCase`는 Rails 5.1에서 자체 젬으로 이동될 예정입니다. 대신 `ActionDispatch::IntegrationTest`를 사용하십시오.
([커밋](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d))

* Rails는 기본적으로 약한 ETag를 생성합니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/17573))

* 명시적인 `render` 호출이 없고 해당하는 템플릿이 없는 컨트롤러 액션은 오류를 발생시키지 않고 암묵적으로 `head :no_content`를 렌더링합니다.
(풀 리퀘스트 [1](https://github.com/rails/rails/pull/19377),
[2](https://github.com/rails/rails/pull/23827))

* 폼별 CSRF 토큰을 전달하기 위한 옵션을 추가했습니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/22275))

* 통합 테스트에 요청 인코딩 및 응답 파싱 기능을 추가했습니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/21671))

* `ActionController#helpers`를 추가하여 컨트롤러 수준에서 뷰 컨텍스트에 액세스할 수 있습니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/24866))

* 삭제된 플래시 메시지는 세션에 저장되기 전에 제거됩니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/18721))

* `fresh_when` 및 `stale?`에 레코드 컬렉션을 전달할 수 있는 지원을 추가했습니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/18374))

* `ActionController::Live`가 `ActiveSupport::Concern`이 되었습니다. 이는 다른 모듈에 포함되기 위해서는 `ActiveSupport::Concern` 또는 `ActionController::Live`로 확장해야 한다는 것을 의미합니다. 일부 사람들은 미들웨어가 `ActionController::Live`를 사용할 때 발생하는 스레드에서 `:warden`를 잡을 수 없기 때문에 특별한 `Warden`/`Devise` 인증 실패 처리 코드를 포함하기 위해 다른 모듈을 사용할 수도 있습니다.
([이 이슈에서 자세한 내용 확인](https://github.com/rails/rails/issues/25581))

* `Response#strong_etag=` 및 `#weak_etag=` 및 `fresh_when` 및 `stale?`에 대한 유사한 옵션을 도입했습니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/24387))

Action View
-------------

자세한 변경 사항은 [Changelog][action-view]를 참조하십시오.

### 삭제된 내용

* 폐기된 `AbstractController::Base::parent_prefixes`를 제거했습니다.
([커밋](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

* `ActionView::Helpers::RecordTagHelper`를 제거했습니다. 이 기능은
[record_tag_helper](https://github.com/rails/record_tag_helper) 젬으로 분리되었습니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/18411))

* 더 이상 I18n에서 지원하지 않는 `translate` 헬퍼의 `:rescue_format` 옵션을 제거했습니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/20019))

### 주요 변경 사항

* 기본 템플릿 핸들러를 `ERB`에서 `Raw`로 변경했습니다.
([커밋](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

* 컬렉션 렌더링은 여러 개의 부분 템플릿을 캐시하고 한 번에 가져올 수 있습니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/18948),
[커밋](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

* 명시적 종속성에 와일드카드 매칭을 추가했습니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/20904))

* 제출 태그에 대한 기본 동작으로 `disable_with`를 사용합니다. 제출 시 버튼을 비활성화하여 중복 제출을 방지합니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/21135))

* 부분 템플릿 이름은 더 이상 유효한 Ruby 식별자일 필요가 없습니다.
([커밋](https://github.com/rails/rails/commit/da9038e))

* `datetime_tag` 헬퍼는 이제 `datetime-local` 타입의 입력 태그를 생성합니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/25469))

* `render partial:` 헬퍼로 렌더링하는 동안 블록을 허용합니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/17974))

Action Mailer
-------------

자세한 변경 사항은 [Changelog][action-mailer]를 참조하십시오.

### 삭제된 내용

* 이메일 뷰에서 폐기된 `*_path` 헬퍼를 제거했습니다.
([커밋](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

* 폐기된 `deliver` 및 `deliver!` 메서드를 제거했습니다.
([커밋](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### 주요 변경 사항

* 템플릿 조회는 이제 기본 로캘과 I18n 폴백을 준수합니다.
([커밋](https://github.com/rails/rails/commit/ecb1981b))

* 생성기를 통해 생성된 메일러에 `_mailer` 접미사를 추가했습니다. 이는 컨트롤러와 작업에서 사용되는 네이밍 컨벤션을 따릅니다.
([풀 리퀘스트](https://github.com/rails/rails/pull/18074))
* `assert_enqueued_emails`와 `assert_no_enqueued_emails`를 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/18403))

* `config.action_mailer.deliver_later_queue_name` 구성을 추가하여 메일러 큐 이름을 설정할 수 있습니다. ([Pull Request](https://github.com/rails/rails/pull/18587))

* Action Mailer 뷰에서 조각 캐싱을 지원하도록 추가했습니다. 템플릿이 캐싱을 수행할지 여부를 결정하기 위해 `config.action_mailer.perform_caching`이라는 새로운 구성 옵션을 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/22825))


Active Record
-------------

자세한 변경 사항은 [Changelog][active-record]를 참조하십시오.

### 제거 사항

* 중첩된 배열을 쿼리 값으로 전달하는 것을 허용하는 더 이상 사용되지 않는 동작을 제거했습니다. ([Pull Request](https://github.com/rails/rails/pull/17919))

* 더 이상 사용되지 않는 `ActiveRecord::Tasks::DatabaseTasks#load_schema`를 제거했습니다. 이 메서드는 `ActiveRecord::Tasks::DatabaseTasks#load_schema_for`로 대체되었습니다. ([commit](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))

* 더 이상 사용되지 않는 `serialized_attributes`를 제거했습니다. ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

* `has_many :through`에서 더 이상 사용되지 않는 자동 카운터 캐시를 제거했습니다. ([commit](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

* 더 이상 사용되지 않는 `sanitize_sql_hash_for_conditions`를 제거했습니다. ([commit](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

* 더 이상 사용되지 않는 `Reflection#source_macro`를 제거했습니다. ([commit](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

* 더 이상 사용되지 않는 `symbolized_base_class`와 `symbolized_sti_name`을 제거했습니다. ([commit](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

* 더 이상 사용되지 않는 `ActiveRecord::Base.disable_implicit_join_references=`를 제거했습니다. ([commit](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

* 문자열 접근자를 사용하여 연결 사양에 액세스하는 것을 더 이상 지원하지 않습니다. ([commit](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

* 인스턴스 종속적인 연관 관계를 미리로드하는 것을 더 이상 지원하지 않습니다. ([commit](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

* 배타적 하한 값을 가진 PostgreSQL 범위를 더 이상 지원하지 않습니다. ([commit](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

* 캐시된 Arel로 관계를 수정할 때 deprecation을 제거했습니다. 대신 `ImmutableRelation` 오류가 발생합니다. ([commit](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

* `ActiveRecord::Serialization::XmlSerializer`를 코어에서 제거했습니다. 이 기능은 [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) 젬으로 분리되었습니다. ([Pull Request](https://github.com/rails/rails/pull/21161))

* 코어에서 레거시 `mysql` 데이터베이스 어댑터 지원을 제거했습니다. 대부분의 사용자는 `mysql2`를 사용할 수 있습니다. 유지 관리자를 찾으면 별도의 젬으로 변환될 것입니다. ([Pull Request 1](https://github.com/rails/rails/pull/22642), [Pull Request 2](https://github.com/rails/rails/pull/22715))

* `protected_attributes` 젬 지원을 제거했습니다. ([commit](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

* PostgreSQL 9.1 버전 미만의 지원을 제거했습니다. ([Pull Request](https://github.com/rails/rails/pull/23434))

* `activerecord-deprecated_finders` 젬 지원을 제거했습니다. ([commit](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

* `ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES` 상수를 제거했습니다. ([commit](https://github.com/rails/rails/commit/a502703c3d2151d4d3b421b29fefdac5ad05df61))

### 폐기 사항

* 쿼리 값으로 클래스를 전달하는 것을 폐기했습니다. 대신 문자열을 전달해야 합니다. ([Pull Request](https://github.com/rails/rails/pull/17916))

* Active Record 콜백 체인을 중단하는 방법으로 `false`를 반환하는 것을 폐기했습니다. 권장하는 방법은 `throw(:abort)`입니다. ([Pull Request](https://github.com/rails/rails/pull/17227))

* `ActiveRecord::Base.errors_in_transactional_callbacks=`을 폐기했습니다. ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

* `Relation#uniq`를 사용하는 대신 `Relation#distinct`를 사용하도록 폐기했습니다. ([commit](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

* PostgreSQL `:point` 타입을 새로운 타입으로 폐기했습니다. 이 새로운 타입은 `Array` 대신 `Point` 객체를 반환합니다. ([Pull Request](https://github.com/rails/rails/pull/20448))

* 연관 관계 메서드에 참값 인수를 전달하여 강제로 연관 관계를 다시로드하는 것을 폐기했습니다. ([Pull Request](https://github.com/rails/rails/pull/20888))

* 연관 관계 `restrict_dependent_destroy` 오류의 키를 새로운 키 이름으로 폐기했습니다. ([Pull Request](https://github.com/rails/rails/pull/20668))

* `#tables`의 동작을 동기화했습니다. ([Pull Request](https://github.com/rails/rails/pull/21601))

* `SchemaCache#tables`, `SchemaCache#table_exists?`, `SchemaCache#clear_table_cache!`를 폐기하고 새로운 데이터 소스 대안을 사용하도록 폐기했습니다. ([Pull Request](https://github.com/rails/rails/pull/21715))

* SQLite3 및 MySQL 어댑터에서 `connection.tables`를 폐기했습니다. ([Pull Request](https://github.com/rails/rails/pull/21601))

* `#tables`에 인수를 전달하는 것을 폐기했습니다. 일부 어댑터(mysql2, sqlite3)의 `#tables` 메서드는 테이블과 뷰를 모두 반환하는 반면 다른 어댑터(postgresql)는 테이블만 반환합니다. 동작을 일관되게 만들기 위해 `#tables`은 향후에는 테이블만 반환합니다. ([Pull Request](https://github.com/rails/rails/pull/21601))
*   `table_exists?`를 사용하지 않도록 하였습니다. `#table_exists?` 메소드는 향후에는 테이블만 확인하도록 변경되었습니다. ([Pull Request](https://github.com/rails/rails/pull/21601))

*   `find_nth`에 `offset` 인자를 전달하는 것을 사용하지 않도록 하였습니다. 대신 관계에 있는 `offset` 메소드를 사용해주세요. ([Pull Request](https://github.com/rails/rails/pull/22053))

*   `DatabaseStatements`에서 `{insert|update|delete}_sql`을 사용하지 않도록 하였습니다. 대신 `{insert|update|delete}` 공개 메소드를 사용해주세요. ([Pull Request](https://github.com/rails/rails/pull/23086))

*   `use_transactional_fixtures`를 더 명확한 `use_transactional_tests`로 대체하였습니다. ([Pull Request](https://github.com/rails/rails/pull/19282))

*   `ActiveRecord::Connection#quote`에 컬럼을 전달하는 것은 사용하지 않도록 하였습니다. ([commit](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

*   `find_in_batches`에 `end` 옵션을 추가하여 배치 처리를 중지할 위치를 지정할 수 있도록 하였습니다. ([Pull Request](https://github.com/rails/rails/pull/12257))


### 주요 변경 사항

*   테이블을 생성할 때 `references`에 `foreign_key` 옵션을 추가하였습니다. ([commit](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

*   새로운 속성 API를 추가하였습니다. ([commit](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

*   `enum` 정의에 `:_prefix`/`:_suffix` 옵션을 추가하였습니다. ([Pull Request](https://github.com/rails/rails/pull/19813), [Pull Request](https://github.com/rails/rails/pull/20999))

*   `ActiveRecord::Relation`에 `#cache_key`를 추가하였습니다. ([Pull Request](https://github.com/rails/rails/pull/20884))

*   `timestamps`의 기본 `null` 값이 `false`로 변경되었습니다. ([commit](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

*   `ActiveRecord::SecureToken`을 추가하여 `SecureRandom`을 사용하여 모델의 속성에 대한 고유한 토큰 생성을 캡슐화하였습니다. ([Pull Request](https://github.com/rails/rails/pull/18217))

*   `drop_table`에 `:if_exists` 옵션을 추가하였습니다. ([Pull Request](https://github.com/rails/rails/pull/18597))

*   `ActiveRecord::Base#accessed_fields`를 추가하였습니다. 이를 사용하여 데이터베이스에서 필요한 데이터만 선택할 때 모델에서 읽은 필드를 빠르게 확인할 수 있습니다. ([commit](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

*   `ActiveRecord::Relation`에 `#or` 메소드를 추가하였습니다. WHERE 또는 HAVING 절을 결합하는 데 OR 연산자를 사용할 수 있습니다. ([commit](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

*   `ActiveRecord::Base.suppress`를 추가하였습니다. 이를 사용하여 주어진 블록 내에서 수신자를 저장하지 않도록 할 수 있습니다. ([Pull Request](https://github.com/rails/rails/pull/18910))

*   `belongs_to`는 이제 기본적으로 연관된 객체가 없을 경우 유효성 오류를 발생시킵니다. `optional: true`로 개별 연관 관계에서 이를 비활성화할 수 있습니다. 또한 `required` 옵션을 `optional` 옵션으로 대체하여 `belongs_to`에 대한 사용을 비추합니다. ([Pull Request](https://github.com/rails/rails/pull/18937))

*   `config.active_record.dump_schemas`를 추가하여 `db:structure:dump`의 동작을 구성할 수 있도록 하였습니다. ([Pull Request](https://github.com/rails/rails/pull/19347))

*   `config.active_record.warn_on_records_fetched_greater_than` 옵션을 추가하였습니다. ([Pull Request](https://github.com/rails/rails/pull/18846))

*   MySQL에서 네이티브 JSON 데이터 타입 지원을 추가하였습니다. ([Pull Request](https://github.com/rails/rails/pull/21110))

*   PostgreSQL에서 동시에 인덱스를 삭제할 수 있는 기능을 추가하였습니다. ([Pull Request](https://github.com/rails/rails/pull/21317))

*   연결 어댑터에 `#views`와 `#view_exists?` 메소드를 추가하였습니다. ([Pull Request](https://github.com/rails/rails/pull/21609))

*   `ActiveRecord::Base.ignored_columns`를 추가하여 일부 컬럼을 Active Record에서 숨길 수 있도록 하였습니다. ([Pull Request](https://github.com/rails/rails/pull/21720))

*   `connection.data_sources`와 `connection.data_source_exists?`를 추가하였습니다. 이 메소드들은 Active Record 모델을 지원하는 관계(일반적으로 테이블과 뷰)를 결정합니다. ([Pull Request](https://github.com/rails/rails/pull/21715))

*   픽스처 파일에서 YAML 파일 자체에서 모델 클래스를 설정할 수 있도록 하였습니다. ([Pull Request](https://github.com/rails/rails/pull/20574))

*   데이터베이스 마이그레이션 생성 시 기본적으로 `uuid`를 기본 키로 설정할 수 있도록 하였습니다. ([Pull Request](https://github.com/rails/rails/pull/21762))
* `ActiveRecord::Relation#left_joins`와 `ActiveRecord::Relation#left_outer_joins`를 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/12071))

* `after_{create,update,delete}_commit` 콜백을 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/22516))

* 마이그레이션 클래스에 제공되는 API를 버전화하여 기존 마이그레이션을 깨뜨리지 않고 매개변수 기본값을 변경하거나 사용자에게 재작성을 강요할 수 있도록 했습니다. ([Pull Request](https://github.com/rails/rails/pull/21538))

* `ApplicationRecord`는 모든 앱 모델의 새로운 슈퍼클래스로, 앱 컨트롤러가 `ActionController::Base` 대신 `ApplicationController`를 상속하는 것과 유사합니다. 이를 통해 앱에서 앱 전체 모델 동작을 구성할 수 있는 단일한 위치를 제공합니다. ([Pull Request](https://github.com/rails/rails/pull/22567))

* ActiveRecord `#second_to_last`와 `#third_to_last` 메서드를 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/23583))

* PostgreSQL 및 MySQL의 데이터베이스 메타데이터에 저장된 주석으로 데이터베이스 객체(테이블, 열, 인덱스)에 주석을 추가하는 기능을 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/22911))

* `mysql2` 어댑터에 준비된 문 지원을 추가했습니다. 이전에는 폐기된 `mysql` 레거시 어댑터에서만 지원되었습니다. 활성화하려면 `config/database.yml`에서 `prepared_statements: true`로 설정하십시오. ([Pull Request](https://github.com/rails/rails/pull/23461))

* 관계 객체에서 `ActionRecord::Relation#update`를 호출할 수 있는 기능을 추가했습니다. 이는 관계에 있는 모든 객체에서 유효성 검사와 콜백을 실행합니다. ([Pull Request](https://github.com/rails/rails/pull/11898))

* `save` 메서드에 `:touch` 옵션을 추가하여 타임스탬프를 업데이트하지 않고 레코드를 저장할 수 있도록 했습니다. ([Pull Request](https://github.com/rails/rails/pull/18225))

* PostgreSQL에 대한 표현식 인덱스와 연산자 클래스 지원을 추가했습니다. ([commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))

* 중첩된 속성의 오류에 인덱스를 추가하는 `:index_errors` 옵션을 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/19686))

* 양방향 삭제 종속성을 지원하도록 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/18548))

* 트랜잭션 테스트에서 `after_commit` 콜백을 지원하도록 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/18458))

* 테이블에 외래 키가 있는지 여부를 확인하기 위해 `foreign_key_exists?` 메서드를 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/18662))

* `:time` 옵션을 `touch` 메서드에 추가하여 현재 시간과 다른 시간으로 레코드를 업데이트할 수 있도록 했습니다. ([Pull Request](https://github.com/rails/rails/pull/18956))

* 트랜잭션 콜백을 변경하여 오류를 더 이상 무시하지 않도록 변경했습니다. 이 변경 전에는 트랜잭션 콜백 내에서 발생한 모든 오류가 로그에 기록되었습니다. (`raise_in_transactional_callbacks = true` 옵션을 사용하지 않는 한) 이제 이러한 오류는 더 이상 잡히지 않고 상위로 전달되며 다른 콜백과 동일한 동작을 수행합니다. ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

Active Model
------------

자세한 변경 사항은 [Changelog][active-model]를 참조하십시오.

### 삭제 사항

* `ActiveModel::Dirty#reset_#{attribute}` 및 `ActiveModel::Dirty#reset_changes`를 폐기했습니다. ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

* XML 직렬화를 제거했습니다. 이 기능은 [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) 젬으로 분리되었습니다. ([Pull Request](https://github.com/rails/rails/pull/21161))

* `ActionController::ModelNaming` 모듈을 제거했습니다. ([Pull Request](https://github.com/rails/rails/pull/18194))

### 폐기 사항

* Active Model 및 `ActiveModel::Validations` 콜백 체인을 중단하는 방법으로 `false`를 반환하는 것을 폐기했습니다. 권장하는 방법은 `throw(:abort)`입니다. ([Pull Request](https://github.com/rails/rails/pull/17227))

* 일관성 없는 동작을 가진 `ActiveModel::Errors#get`, `ActiveModel::Errors#set` 및 `ActiveModel::Errors#[]=` 메서드를 폐기했습니다. ([Pull Request](https://github.com/rails/rails/pull/18634))

* `validates_length_of`의 `:tokenizer` 옵션을 폐기했습니다. 대신 일반적인 Ruby를 사용하십시오. ([Pull Request](https://github.com/rails/rails/pull/19585))
* `ActiveModel::Errors#add_on_empty` 및 `ActiveModel::Errors#add_on_blank`를 사용하지 않도록 표시되었습니다. 대체할 기능은 없습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/18996))

### 주요 변경 사항

* `ActiveModel::Errors#details`를 추가하여 어떤 유효성 검사기가 실패했는지 확인할 수 있습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/18322))

* `ActiveRecord::AttributeAssignment`를 `ActiveModel::AttributeAssignment`로 추출하여 모든 객체에 포함 가능한 모듈로 사용할 수 있게 되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/10776))

* `ActiveModel::Dirty#[attr_name]_previously_changed?` 및 `ActiveModel::Dirty#[attr_name]_previous_change`를 추가하여 모델이 저장된 후에 기록된 변경 사항에 더 쉽게 액세스할 수 있게 되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/19847))

* `valid?` 및 `invalid?`에서 여러 컨텍스트를 동시에 유효성 검사할 수 있게 되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/21069))

* `validates_acceptance_of`를 `1` 외에도 `true`를 기본값으로 허용하도록 변경되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/18439))

Active Job
-----------

자세한 변경 사항은 [Changelog][active-job]를 참조하십시오.

### 주요 변경 사항

* `ActiveJob::Base.deserialize`는 작업 클래스로 위임됩니다. 이를 통해 작업이 직렬화될 때 임의의 메타데이터를 첨부하고 수행될 때 다시 읽을 수 있습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/18260))

* 각 작업에 대해 큐 어댑터를 개별적으로 구성할 수 있는 기능이 추가되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/16992))

* 생성된 작업은 이제 기본적으로 `app/jobs/application_job.rb`에서 상속됩니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/19034))

* `DelayedJob`, `Sidekiq`, `qu`, `que`, `queue_classic`에서 작업 ID를 `ActiveJob::Base`로 `provider_job_id`로 보고할 수 있도록 변경되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/20064), [풀 리퀘스트](https://github.com/rails/rails/pull/20056), [커밋](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

* `concurrent-ruby` 스레드 풀에 작업을 대기열에 넣는 간단한 `AsyncJob` 프로세서와 관련된 `AsyncAdapter`를 구현했습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/21257))

* 기본 어댑터를 인라인에서 비동기로 변경했습니다. 이는 테스트가 동기적으로 발생하는 동작에 실수로 의존하지 않도록 더 나은 기본값입니다. ([커밋](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))

Active Support
--------------

자세한 변경 사항은 [Changelog][active-support]를 참조하십시오.

### 제거된 기능

* 더 이상 사용되지 않는 `ActiveSupport::JSON::Encoding::CircularReferenceError`가 제거되었습니다. ([커밋](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

* 더 이상 사용되지 않는 메서드 `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=` 및 `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string`가 제거되었습니다. ([커밋](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

* 더 이상 사용되지 않는 `ActiveSupport::SafeBuffer#prepend`가 제거되었습니다. ([커밋](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

* `Kernel`에서 더 이상 사용되지 않는 메서드 `silence_stderr`, `silence_stream`, `capture`, `quietly`가 제거되었습니다. ([커밋](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

* 더 이상 사용되지 않는 `active_support/core_ext/big_decimal/yaml_conversions` 파일이 제거되었습니다. ([커밋](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

* 더 이상 사용되지 않는 메서드 `ActiveSupport::Cache::Store.instrument` 및 `ActiveSupport::Cache::Store.instrument=`가 제거되었습니다. ([커밋](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

* `Class#superclass_delegating_accessor`가 제거되었습니다. 대신 `Class#class_attribute`를 사용하십시오. ([풀 리퀘스트](https://github.com/rails/rails/pull/16938))

* `ThreadSafe::Cache`가 제거되었습니다. 대신 `Concurrent::Map`을 사용하십시오. ([풀 리퀘스트](https://github.com/rails/rails/pull/21679))

* Ruby 2.2에서 구현된 `Object#itself`가 제거되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/18244))

### 사용 중단된 기능

* `MissingSourceFile`이 `LoadError`를 대신하여 사용 중단되었습니다. ([커밋](https://github.com/rails/rails/commit/734d97d2))

* `alias_method_chain`이 Ruby 2.0에서 도입된 `Module#prepend`를 사용하여 사용 중단되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/19434))

* `ActiveSupport::Concurrency::Latch`가 `Concurrent::CountDownLatch`로 사용 중단되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/20866))

* `number_to_human_size`의 `:prefix` 옵션이 사용 중단되었습니다. 대체 기능은 없습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/21191))

* `Module#qualified_const_`가 내장된 `Module#const_` 메서드를 사용하도록 사용 중단되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/17845))

* 문자열을 콜백으로 정의하는 것이 사용 중단되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/22598))

* `ActiveSupport::Cache::Store#namespaced_key`, `ActiveSupport::Cache::MemCachedStore#escape_key`, `ActiveSupport::Cache::FileStore#key_file_path`가 사용 중단되었습니다. `normalize_key`를 사용하십시오. ([풀 리퀘스트](https://github.com/rails/rails/pull/22215), [커밋](https://github.com/rails/rails/commit/a8f773b0))

* `ActiveSupport::Cache::LocaleCache#set_cache_value`가 `write_cache_value`로 사용 중단되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/22215))
* `assert_nothing_raised`에 대한 인수 전달은 사용이 중지되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/23789))

* `Module.local_constants`는 `Module.constants(false)`를 선호합니다.
    ([Pull Request](https://github.com/rails/rails/pull/23936))


### 주요 변경 사항

* `ActiveSupport::MessageVerifier`에 `#verified` 및 `#valid_message?` 메서드를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/17727))

* 콜백 체인을 중단하는 방법이 변경되었습니다. 이제 콜백 체인을 중단하는 우선적인 방법은 명시적으로 `throw(:abort)`하는 것입니다.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

* `config.active_support.halt_callback_chains_on_return_false`라는 새로운 구성 옵션을 추가하여 ActiveRecord, ActiveModel 및 ActiveModel::Validations 콜백 체인이 'before' 콜백에서 `false`를 반환하여 중단될 수 있는지 여부를 지정할 수 있습니다.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

* 기본 테스트 순서를 `:sorted`에서 `:random`으로 변경했습니다.
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

* `Date`, `Time` 및 `DateTime`에 `#on_weekend?`, `#on_weekday?`, `#next_weekday`, `#prev_weekday` 메서드를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/18335),
     [Pull Request](https://github.com/rails/rails/pull/23687))

* `Date`, `Time`, `DateTime`에 `#next_week` 및 `#prev_week`에 `same_time` 옵션을 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

* `Date`, `Time`, `DateTime`에 `#yesterday` 및 `#tomorrow`의 `#prev_day` 및 `#next_day` 상응하는 메서드를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

* 무작위 base58 문자열을 생성하기 위해 `SecureRandom.base58`를 추가했습니다.
    ([commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b))

* `ActiveSupport::TestCase`에 `file_fixture`를 추가했습니다.
    이는 테스트 케이스에서 샘플 파일에 액세스하기 위한 간단한 메커니즘을 제공합니다.
    ([Pull Request](https://github.com/rails/rails/pull/18658))

* 지정된 요소를 제외한 열거 가능한 요소의 복사본을 반환하기 위해 `Enumerable` 및 `Array`에 `#without`를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/19157))

* `ActiveSupport::ArrayInquirer` 및 `Array#inquiry`를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

* 특정 시간대에서 시간을 구문 분석할 수 있도록 `ActiveSupport::TimeZone#strptime`을 추가했습니다.
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

* `Integer#zero?`와 유사한 `Integer#positive?` 및 `Integer#negative?` 쿼리 메서드를 추가했습니다.
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

* `ActiveSupport::OrderedOptions` get 메서드에 `KeyError`를 발생시키는 뱅 버전을 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/20208))

* 주어진 연도의 일 수 또는 인수가 제공되지 않은 경우 현재 연도를 반환하기 위해 `Time.days_in_year`를 추가했습니다.
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

* 응용 프로그램 소스 코드, 라우트, 로케일 등에서 변경 사항을 비동기적으로 감지하기 위해 이벤트 기반 파일 감시기를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/22254))

* 쓰레드별로 유지되는 클래스 및 모듈 변수를 선언하기 위해 `thread_m/cattr_accessor/reader/writer` 메서드 스위트를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/22630))

* `Array#second_to_last` 및 `Array#third_to_last` 메서드를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

* 응용 프로그램 코드의 실행 및 응용 프로그램 다시로드 프로세스에 참여하기 위해 `ActiveSupport::Executor` 및 `ActiveSupport::Reloader` API를 게시했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/23807))

* `ActiveSupport::Duration`은 이제 ISO8601 형식 지원 및 구문 분석을 지원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/16917))

* `ActiveSupport::JSON.decode`는 `parse_json_times`가 활성화되었을 때 ISO8601 로컬 시간을 구문 분석할 수 있습니다.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

* `ActiveSupport::JSON.decode`는 날짜 문자열에 대해 `Date` 객체를 반환합니다.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

* `TaggedLogging`에 여러 번 인스턴스화 할 수 있는 기능을 추가하여 서로 태그를 공유하지 않도록 허용했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/9065))
크레딧
-------

[Rails에 기여한 모든 사람들의 전체 목록](https://contributors.rubyonrails.org/)을 확인하여 Rails를 안정적이고 견고한 프레임워크로 만들기 위해 많은 시간을 투자한 많은 사람들에게 감사의 인사를 전합니다.

[railties]:       https://github.com/rails/rails/blob/5-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-0-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
