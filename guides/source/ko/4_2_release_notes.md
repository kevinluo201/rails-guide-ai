**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4d8311a1435138a81e26a7e8f537dbde
Ruby on Rails 4.2 릴리스 노트
===============================

Rails 4.2의 주요 기능:

* Active Job
* 비동기 메일
* 적절한 레코드
* 웹 콘솔
* 외래 키 지원

이 릴리스 노트는 주요 변경 사항만 다룹니다. 다른 기능, 버그 수정 및 변경 사항에 대해서는 변경 로그를 참조하거나 GitHub의 주요 Rails 저장소의 [커밋 목록](https://github.com/rails/rails/commits/4-2-stable)을 확인하십시오.

--------------------------------------------------------------------------------

Rails 4.2로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드하는 경우, 업그레이드하기 전에 좋은 테스트 커버리지를 갖는 것이 좋습니다. 또한, Rails 4.1로 먼저 업그레이드하고 애플리케이션이 예상대로 작동하는지 확인한 후에 Rails 4.2로 업그레이드를 시도하십시오. 업그레이드할 때 주의해야 할 사항은 [Ruby on Rails 업그레이드 가이드](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2)에서 확인할 수 있습니다.

주요 기능
--------------

### Active Job

Active Job은 Rails 4.2에서 새로운 프레임워크입니다. 이는 [Resque](https://github.com/resque/resque), [Delayed Job](https://github.com/collectiveidea/delayed_job), [Sidekiq](https://github.com/mperham/sidekiq) 등의 큐잉 시스템 위에 공통 인터페이스를 제공합니다.

Active Job API로 작성된 작업은 해당 어댑터를 통해 지원되는 큐 중 하나에서 실행됩니다. Active Job은 작업을 즉시 실행하는 인라인 러너와 함께 미리 구성되어 있습니다.

작업은 종종 Active Record 객체를 인수로 사용해야 합니다. Active Job은 객체 자체를 직렬화하는 대신 객체 참조를 URI(Uniform Resource Identifier)로 전달합니다. 새로운 [Global ID](https://github.com/rails/globalid) 라이브러리는 URI를 생성하고 참조하는 객체를 찾습니다. Active Record 객체를 작업 인수로 전달하는 것은 내부적으로 Global ID를 사용하여 작동합니다.

예를 들어, `trashable`이 Active Record 객체인 경우 다음 작업은 직렬화 없이 정상적으로 실행됩니다:

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

자세한 내용은 [Active Job Basics](active_job_basics.html) 가이드를 참조하십시오.

### 비동기 메일

Active Job을 기반으로 한 Action Mailer는 이제 `deliver_later` 메소드를 제공하여 이메일을 큐를 통해 전송할 수 있습니다. 따라서 큐가 비동기적인 경우(기본 인라인 큐는 블로킹) 컨트롤러나 모델이 차단되지 않습니다.

`deliver_now`를 사용하면 즉시 이메일을 전송할 수 있습니다.

### 적절한 레코드

적절한 레코드는 Active Record의 성능 향상을 위한 일련의 개선 사항으로, 일반적인 `find` 및 `find_by` 호출 및 일부 연관 쿼리를 최대 2배 빠르게 만듭니다.

이는 일반적인 SQL 쿼리를 준비된 문으로 캐시하고 유사한 호출에서 재사용하여 후속 호출에서 대부분의 쿼리 생성 작업을 건너뛰는 방식으로 작동합니다. 자세한 내용은 [Aaron Patterson의 블로그 게시물](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html)을 참조하십시오.

Active Record는 사용자의 개입이나 코드 변경 없이 지원되는 작업에서 자동으로 이 기능을 활용합니다. 다음은 지원되는 작업의 몇 가지 예시입니다:

```ruby
Post.find(1)  # 첫 번째 호출은 준비된 문을 생성하고 캐시합니다
Post.find(2)  # 후속 호출은 캐시된 준비된 문을 재사용합니다

Post.find_by_title('first post')
Post.find_by_title('second post')

Post.find_by(title: 'first post')
Post.find_by(title: 'second post')

post.comments
post.comments(true)
```

위의 예시에서 알 수 있듯이, 준비된 문은 메소드 호출에 전달된 값들을 캐시하지 않습니다. 대신, 값들을 위한 자리 표시자를 가지고 있습니다.

다음 경우에는 캐싱이 사용되지 않습니다:
- 모델에는 기본 범위가 있습니다.
- 모델은 단일 테이블 상속을 사용합니다.
- `find`를 사용하여 id 목록을 찾을 수 있습니다. 예:

    ```ruby
    # 캐시되지 않음
    Post.find(1, 2, 3)
    Post.find([1,2])
    ```

- SQL 조각을 사용하여 `find_by`를 찾을 수 있습니다.

    ```ruby
    Post.find_by('published_at < ?', 2.weeks.ago)
    ```

### 웹 콘솔

Rails 4.2로 생성된 새로운 애플리케이션에는 [Web Console](https://github.com/rails/web-console) 젬이 기본으로 포함됩니다. Web Console은 모든 오류 페이지에 대화형 Ruby 콘솔을 추가하며 `console` 뷰와 컨트롤러 도우미를 제공합니다.

오류 페이지의 대화형 콘솔을 사용하면 예외가 발생한 위치의 컨텍스트에서 코드를 실행할 수 있습니다. `console` 도우미는 뷰나 컨트롤러의 어느 곳에서 호출되든 렌더링이 완료된 후 최종 컨텍스트로 대화형 콘솔을 시작합니다.

### 외래 키 지원

마이그레이션 DSL은 이제 외래 키를 추가하고 제거하는 것을 지원합니다. 이들은 `schema.rb`에도 덤프됩니다. 현재 `mysql`, `mysql2` 및 `postgresql` 어댑터만 외래 키를 지원합니다.

```ruby
# `articles.author_id`를 참조하는 외래 키를 `authors.id`에 추가합니다.
add_foreign_key :articles, :authors

# `articles.author_id`를 참조하는 외래 키를 `users.lng_id`에 추가합니다.
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# `accounts.branch_id`의 외래 키를 제거합니다.
remove_foreign_key :accounts, :branches

# `accounts.owner_id`의 외래 키를 제거합니다.
remove_foreign_key :accounts, column: :owner_id
```

[add_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key) 및 [remove_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)에 대한 API 문서를 참조하여 자세한 설명을 확인하십시오.


호환성
-----------------

이전에 폐기된 기능이 제거되었습니다. 이 릴리스에서의 새로운 폐기 사항에 대해서는 개별 구성 요소를 참조하십시오.

다음 변경 사항은 업그레이드 시 즉시 조치가 필요할 수 있습니다.

### 문자열 인수로 `render`

이전에 컨트롤러 액션에서 `render "foo/bar"`를 호출하면 `render file: "foo/bar"`와 동일한 의미였습니다. Rails 4.2에서는 이를 `render template: "foo/bar"`로 변경했습니다. 파일을 렌더링해야하는 경우 코드를 명시적인 형식 (`render file: "foo/bar"`)으로 변경하십시오.

### `respond_with` / 클래스 수준 `respond_to`

`respond_with`와 해당하는 클래스 수준의 `respond_to`가 [responders](https://github.com/plataformatec/responders) 젬으로 이동되었습니다. 사용하려면 `Gemfile`에 `gem 'responders', '~> 2.0'`를 추가하십시오.

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

인스턴스 수준의 `respond_to`는 영향을 받지 않습니다.

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

### `rails server`의 기본 호스트

Rack의 [변경 사항](https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc)으로 인해 `rails server`는 이제 기본적으로 `localhost`에서 `0.0.0.0` 대신에 수신합니다. 이는 개발 환경에서의 표준 작업 흐름에는 최소한의 영향을 미칠 것입니다. http://127.0.0.1:3000 및 http://localhost:3000은 여전히 자신의 컴퓨터에서 이전과 같이 작동할 것입니다.

그러나이 변경으로 인해 개발 환경이 가상 머신에 있고 호스트 머신에서 액세스하려는 경우와 같이 다른 기계에서 Rails 서버에 액세스할 수 없게됩니다. 이러한 경우에는 `rails server -b 0.0.0.0`로 서버를 시작하여 이전 동작을 복원하십시오.

이렇게하면 개발 서버에 신뢰할 수있는 네트워크의 기계 만 액세스 할 수 있도록 방화벽을 올바르게 구성해야합니다.
### `render`를 위한 상태 옵션 기호 변경

[Rack의 변경](https://github.com/rack/rack/commit/be28c6a2ac152fe4adfbef71f3db9f4200df89e8)으로 인해 `render` 메소드에서 `:status` 옵션으로 허용되는 기호가 변경되었습니다:

- 306: `:reserved`가 제거되었습니다.
- 413: `:request_entity_too_large`가 `:payload_too_large`로 이름이 변경되었습니다.
- 414: `:request_uri_too_long`이 `:uri_too_long`으로 이름이 변경되었습니다.
- 416: `:requested_range_not_satisfiable`이 `:range_not_satisfiable`로 이름이 변경되었습니다.

알 수 있듯이, 알 수 없는 기호로 `render`를 호출하는 경우 응답 상태는 기본적으로 500으로 설정됩니다.

### HTML 살균기

HTML 살균기가 [Loofah](https://github.com/flavorjones/loofah)와 [Nokogiri](https://github.com/sparklemotion/nokogiri)를 기반으로 한 새로운, 더 견고한 구현으로 대체되었습니다. 새로운 살균기는 보안성이 더 높으며, 살균 기능이 더 강력하고 유연합니다.

새로운 알고리즘으로 인해, 특정한 입력에 대한 살균 결과가 다를 수 있습니다.

이전 살균기의 정확한 출력이 필요한 경우, `Gemfile`에 [rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer) 젬을 추가하여 이전 동작을 사용할 수 있습니다. 이 젬은 선택적으로 사용되므로, 사용되지 않습니다.

`rails-deprecated_sanitizer`는 Rails 4.2에서만 지원되며, Rails 5.0에서는 유지되지 않을 것입니다.

새로운 살균기의 변경 사항에 대한 자세한 내용은 [이 블로그 포스트](https://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/)를 참조하십시오.

### `assert_select`

`assert_select`는 이제 [Nokogiri](https://github.com/sparklemotion/nokogiri)를 기반으로 합니다. 결과적으로, 이전에 유효한 선택자 중 일부는 더 이상 지원되지 않습니다. 애플리케이션이 다음과 같은 철자를 사용하는 경우 업데이트해야 합니다:

*   속성 선택자의 값에 알파벳이 아닌 문자가 포함되어 있는 경우, 따옴표로 감싸야 할 수 있습니다.

    ```ruby
    # 이전
    a[href=/]
    a[href$=/]

    # 이제
    a[href="/"]
    a[href$="/"]
    ```

*   잘못된 HTML을 포함하는 HTML 소스로부터 구성된 DOM은 다를 수 있습니다.

    예를 들어:

    ```ruby
    # content: <div><i><p></i></div>

    # 이전:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => false
    assert_select('i > p')    # => true

    # 이제:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => true
    assert_select('i > p')    # => false
    ```

*   선택된 데이터에 엔티티가 포함되어 있는 경우, 비교에 사용되는 값이 이제 평가됩니다.

    ```ruby
    # content: <p>AT&amp;T</p>

    # 이전:
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # 이제:
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

또한 대체 구문이 변경되었습니다.

이제 `:match` CSS와 유사한 선택자를 사용해야 합니다:

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

또한, 단언이 실패할 때 정규식 대체 구문이 다릅니다. 여기에서 `/hello/`:

```ruby
assert_select(":match('id', ?)", /hello/)
```

는 `"(?-mix:hello)"`로 변합니다:

```
Expected at least 1 element matching "div:match('id', "(?-mix:hello)")", found 0..
Expected 0 to be >= 1.
```

`assert_select`에 대한 자세한 내용은 [Rails Dom Testing](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b) 문서를 참조하십시오.


Railties
--------

자세한 변경 사항은 [Changelog][railties]를 참조하십시오.

### 제거 사항

*   앱 생성기에서 `--skip-action-view` 옵션이 제거되었습니다. ([Pull Request](https://github.com/rails/rails/pull/17042))

*   `rails application` 명령어가 대체 없이 제거되었습니다. ([Pull Request](https://github.com/rails/rails/pull/11616))

### 폐지 사항

*   프로덕션 환경에서 누락된 `config.log_level`이 폐지되었습니다. ([Pull Request](https://github.com/rails/rails/pull/16622))

*   `rake test:all`이 `test` 폴더의 모든 테스트를 실행하도록 변경되었으므로, `rake test:all`이 폐지되었습니다. ([Pull Request](https://github.com/rails/rails/pull/17348))
* `rake test:all:db`를 `rake test:db`로 대체하여 사용하지 않도록 설정했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/17348))

* `Rails::Rack::LogTailer`를 대체 없이 사용하지 않도록 설정했습니다.
    ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### 주요 변경 사항

* 기본 애플리케이션 `Gemfile`에 `web-console`를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/11667))

* 모델 생성기에 `required` 옵션을 추가하여 연관 관계를 생성할 수 있도록 했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/16062))

* 사용자 정의 구성 옵션을 정의하기 위해 `x` 네임스페이스를 도입했습니다:

    ```ruby
    # config/environments/production.rb
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries  = 3
    config.x.super_debugger              = true
    ```

    이러한 옵션은 구성 객체를 통해 사용할 수 있습니다:

    ```ruby
    Rails.configuration.x.payment_processing.schedule # => :daily
    Rails.configuration.x.payment_processing.retries  # => 3
    Rails.configuration.x.super_debugger              # => true
    ```

    ([Commit](https://github.com/rails/rails/commit/611849772dd66c2e4d005dcfe153f7ce79a8a7db))

* 현재 환경에 대한 구성을 로드하기 위해 `Rails::Application.config_for`를 도입했습니다.

    ```yaml
    # config/exception_notification.yml
    production:
      url: http://127.0.0.1:8080
      namespace: my_app_production
    development:
      url: http://localhost:3001
      namespace: my_app_development
    ```

    ```ruby
    # config/environments/production.rb
    Rails.application.configure do
      config.middleware.use ExceptionNotifier, config_for(:exception_notification)
    end
    ```

    ([Pull Request](https://github.com/rails/rails/pull/16129))

* 앱 생성기에 `--skip-turbolinks` 옵션을 도입하여 turbolinks 통합을 생성하지 않도록 했습니다.
    ([Commit](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

* 애플리케이션을 부트스트래핑할 때 자동 설정 코드를 위한 관례로 `bin/setup` 스크립트를 도입했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/15189))

* 개발 환경에서 `config.assets.digest`의 기본값을 `true`로 변경했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/15155))

* `rake notes`에 새로운 확장을 등록하기 위한 API를 도입했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14379))

* Rails 템플릿에서 사용하기 위한 `after_bundle` 콜백을 도입했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/16359))

* `Rails.gem_version`을 편의 메서드로 도입하여 `Gem::Version.new(Rails.version)`을 반환하도록 했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

자세한 변경 사항은 [Changelog][action-pack]을 참조하세요.

### 제거 사항

* `respond_with`와 클래스 수준의 `respond_to`를 Rails에서 제거하고 `responders` 젬(버전 2.0)으로 이동했습니다. 이 기능을 계속 사용하려면 `Gemfile`에 `gem 'responders', '~> 2.0'`을 추가하세요.
    ([Pull Request](https://github.com/rails/rails/pull/16526),
     [자세한 내용](https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders))

* 폐기된 `AbstractController::Helpers::ClassMethods::MissingHelperError`를 `AbstractController::Helpers::MissingHelperError`로 대체했습니다.
    ([Commit](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### 폐지 사항

* `*_path` 도우미의 `only_path` 옵션을 폐지했습니다.
    ([Commit](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9))

* `assert_tag`, `assert_no_tag`, `find_tag`, `find_all_tag`를 `assert_select`로 대체하여 사용하지 않도록 설정했습니다.
    ([Commit](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

* 라우터의 `:to` 옵션을 심볼이나 "#" 문자를 포함하지 않는 문자열로 설정하는 것을 폐지했습니다:

    ```ruby
    get '/posts', to: MyRackApp    => (변경 없음)
    get '/posts', to: 'post#index' => (변경 없음)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```

    ([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

* URL 도우미에서 문자열 키를 사용하는 것을 폐지했습니다:

    ```ruby
    # 잘못된 예
    root_path('controller' => 'posts', 'action' => 'index')

    # 올바른 예
    root_path(controller: 'posts', action: 'index')
    ```

    ([Pull Request](https://github.com/rails/rails/pull/17743))

### 주요 변경 사항

* `*_filter` 메서드 패밀리가 문서에서 제거되었습니다. 이들의 사용은 `*_action` 메서드 패밀리를 사용하는 것이 권장됩니다:

    ```
    after_filter          => after_action
    append_after_filter   => append_after_action
    append_around_filter  => append_around_action
    append_before_filter  => append_before_action
    around_filter         => around_action
    before_filter         => before_action
    prepend_after_filter  => prepend_after_action
    prepend_around_filter => prepend_around_action
    prepend_before_filter => prepend_before_action
    skip_after_filter     => skip_after_action
    skip_around_filter    => skip_around_action
    skip_before_filter    => skip_before_action
    skip_filter           => skip_action_callback
    ```

    현재 애플리케이션이 이러한 메서드에 의존하는 경우 대체인 `*_action` 메서드를 사용해야 합니다. 이러한 메서드는 향후 폐지될 예정이며, Rails에서 제거될 것입니다.

    (Commit [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de),
    [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4))

* `render nothing: true` 또는 `nil` 본문을 렌더링할 때 응답 본문에 빈 공백을 추가하지 않습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14883))
*   Rails는 이제 템플릿의 다이제스트를 ETag에 자동으로 포함합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16527))

*   URL 헬퍼에 전달되는 세그먼트는 이제 자동으로 이스케이프됩니다.
    ([커밋](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

*   전역적으로 허용되는 매개변수를 구성하기 위해 `always_permitted_parameters` 옵션을 도입했습니다.
    이 구성의 기본값은 `['controller', 'action']`입니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15933))

*   [RFC 4791](https://tools.ietf.org/html/rfc4791)의 HTTP 메서드 `MKCALENDAR`를 추가했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15121))

*   `*_fragment.action_controller` 알림은 이제 페이로드에 컨트롤러와 액션 이름을 포함합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/14137))

*   라우팅 에러 페이지를 향상시켜 루트 검색을 위한 퍼지 매칭을 추가했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/14619))

*   CSRF 실패 로깅을 비활성화하는 옵션을 추가했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/14280))

*   Rails 서버가 정적 자산을 제공하도록 설정되어 있을 때, 클라이언트가 지원하고 사전 생성된 gzip 파일(`.gz`)이 디스크에 있는 경우 gzip 자산이 제공됩니다.
    기본적으로 자산 파이프라인은 압축 가능한 모든 자산에 대해 `.gz` 파일을 생성합니다.
    gzip 파일을 제공하면 데이터 전송을 최소화하고 자산 요청을 가속화할 수 있습니다. 프로덕션 환경에서 Rails 서버에서 자산을 제공하는 경우 항상 [CDN을 사용](https://guides.rubyonrails.org/v4.2/asset_pipeline.html#cdns)하세요.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16466))

*   통합 테스트에서 `process` 헬퍼를 호출할 때 경로는 선행 슬래시를 가져야 합니다. 이전에는 생략할 수 있었지만, 이는 구현의 부산물이었으며 의도적인 기능이 아닙니다. 예를 들면:

    ```ruby
    test "list all posts" do
      get "/posts"
      assert_response :success
    end
    ```

Action View
-----------

자세한 변경 사항은 [변경 로그][action-view]를 참조하세요.

### 폐기 사항

*   `AbstractController::Base.parent_prefixes`를 폐기했습니다.
    뷰를 찾을 위치를 변경하려면 `AbstractController::Base.local_prefixes`를 재정의하세요.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15026))

*   `ActionView::Digestor#digest(name, format, finder, options = {})`를 폐기했습니다.
    인수는 해시로 전달해야 합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/14243))

### 주목할만한 변경 사항

*   `render "foo/bar"`는 이제 `render template: "foo/bar"`로 확장되며, `render file: "foo/bar"`로 확장되지 않습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16888))

*   폼 헬퍼는 이제 숨겨진 필드 주위에 인라인 CSS가 있는 `<div>` 요소를 생성하지 않습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/14738))

*   컬렉션과 함께 렌더링되는 부분에 사용되는 `#{partial_name}_iteration` 특수 로컬 변수를 도입했습니다. `index`, `size`, `first?`, `last?` 메서드를 통해 반복의 현재 상태에 액세스할 수 있습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/7698))

*   플레이스홀더 I18n은 `label` I18n과 동일한 규칙을 따릅니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

자세한 변경 사항은 [변경 로그][action-mailer]를 참조하세요.

### 폐기 사항

*   메일러에서 `*_path` 헬퍼를 폐기했습니다. 항상 `*_url` 헬퍼를 대신 사용하세요.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15840))

*   `deliver` / `deliver!`를 `deliver_now` / `deliver_now!`로 대체하여 폐기했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16582))

### 주목할만한 변경 사항

*   템플릿에서 `link_to`와 `url_for`는 기본적으로 절대 URL을 생성합니다. `only_path: false`를 전달할 필요가 없어졌습니다.
    ([커밋](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

*   이메일을 비동기적으로 전달하기 위해 애플리케이션의 큐에 작업을 인큐하는 `deliver_later`를 도입했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16485))

*   개발 환경 이외에서 메일러 미리보기를 활성화하기 위한 `show_previews` 구성 옵션을 추가했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15970))


Active Record
-------------

자세한 변경 사항은 [변경 로그][active-record]를 참조하세요.

### 삭제 사항

*   `cache_attributes`와 관련된 메서드를 제거했습니다. 모든 속성이 캐시됩니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15429))

*   폐기된 메서드 `ActiveRecord::Base.quoted_locking_column`을 제거했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15612))

*   폐기된 `ActiveRecord::Migrator.proper_table_name`을 제거했습니다. 대신 `ActiveRecord::Migration`의 `proper_table_name` 인스턴스 메서드를 사용하세요.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15512))

*   사용되지 않는 `:timestamp` 타입을 제거했습니다. 모든 경우에 대해 `:datetime`으로 별칭을 지정합니다. XML 직렬화와 같이 Active Record 외부로 열 유형이 전송되는 경우 일관성 문제를 해결합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15184))
### 폐기된 기능

* `after_commit` 및 `after_rollback` 내부에서 오류를 무시하는 것이 폐기되었습니다.
([Pull Request](https://github.com/rails/rails/pull/16537))

* `has_many :through` 연관 관계에서 카운터 캐시의 자동 감지를 지원하는 기능이 폐기되었습니다. 대신, `has_many` 및 `belongs_to` 연관 관계에서 카운터 캐시를 수동으로 지정해야 합니다.
([Pull Request](https://github.com/rails/rails/pull/15754))

* `.find` 또는 `.exists?`에 Active Record 객체를 전달하는 것이 폐기되었습니다. 먼저 객체에 `id`를 호출해야 합니다.
(Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
[2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

* 제외된 시작 값을 가진 PostgreSQL 범위 값에 대한 반쪽짜리 지원이 폐기되었습니다. 현재 우리는 PostgreSQL 범위를 Ruby 범위로 매핑합니다. 이 변환은 완전히 불가능합니다. 왜냐하면 Ruby 범위는 제외된 시작을 지원하지 않기 때문입니다.

현재의 시작 값을 증가시키는 현재의 해결책은 올바르지 않으며 이제 폐기되었습니다. 우리가 어떻게 증가시킬지 모르는 하위 유형에서는 (`succ`가 정의되지 않은 경우) 제외된 시작을 가진 범위에 대해 `ArgumentError`를 발생시킵니다.
([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

* 연결 없이 `DatabaseTasks.load_schema`를 호출하는 것이 폐기되었습니다. 대신 `DatabaseTasks.load_schema_current`를 사용하세요.
([Commit](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

* 대체 없이 `sanitize_sql_hash_for_conditions`가 폐기되었습니다. 쿼리 및 업데이트를 수행하기 위해 `Relation`을 사용하는 것이 우선적인 API입니다.
([Commit](https://github.com/rails/rails/commit/d5902c9e))

* `add_timestamps` 및 `t.timestamps`를 `:null` 옵션을 전달하지 않고 사용하는 것이 폐기되었습니다. Rails 5에서 기본값인 `null: true`가 `null: false`로 변경될 것입니다.
([Pull Request](https://github.com/rails/rails/pull/16481))

* 더 이상 Active Record에서 필요하지 않은 `Reflection#source_macro`가 대체 없이 폐기되었습니다.
([Pull Request](https://github.com/rails/rails/pull/16373))

* 대체 없이 `serialized_attributes`가 폐기되었습니다.
([Pull Request](https://github.com/rails/rails/pull/15704))

* 열이 없을 때 `column_for_attribute`에서 `nil`을 반환하는 것이 폐기되었습니다. Rails 5.0에서는 null 객체를 반환합니다.
([Pull Request](https://github.com/rails/rails/pull/15878))

* 인스턴스 상태에 따라 (인수를 사용하는 스코프로 정의된) 연관 관계와 함께 `.joins`, `.preload` 및 `.eager_load`를 사용하는 것이 폐기되었습니다. 대체 없이 사용하세요.
([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### 주목할만한 변경 사항

* `SchemaDumper`는 `create_table`에 `force: :cascade`를 사용합니다. 이렇게 하면 외래 키가 있는 경우 스키마를 다시로드할 수 있습니다.

* 단수 관련 연관 관계에 `:required` 옵션을 추가했습니다. 이는 관련 연관 관계에 대한 존재 유효성 검사를 정의합니다.
([Pull Request](https://github.com/rails/rails/pull/16056))

* `ActiveRecord::Dirty`는 이제 가변 값에 대한 인플레이스 변경을 감지합니다. Active Record 모델의 직렬화된 속성은 변경되지 않을 때 더 이상 저장되지 않습니다. 이는 PostgreSQL의 문자열 열 및 json 열과 같은 다른 유형과도 작동합니다.
(Pull Requests [1](https://github.com/rails/rails/pull/15674),
[2](https://github.com/rails/rails/pull/15786),
[3](https://github.com/rails/rails/pull/15788))

* 현재 환경의 데이터베이스를 비우기 위한 `db:purge` Rake 작업을 도입했습니다.
([Commit](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

* 레코드가 유효하지 않은 경우 `ActiveRecord::RecordInvalid`를 발생시키는 `ActiveRecord::Base#validate!`를 도입했습니다.
([Pull Request](https://github.com/rails/rails/pull/8639))

* `valid?`의 별칭으로 `validate`를 도입했습니다.
([Pull Request](https://github.com/rails/rails/pull/14456))

* `touch`는 이제 한 번에 여러 속성을 터치할 수 있습니다.
([Pull Request](https://github.com/rails/rails/pull/14423))

* PostgreSQL 어댑터는 이제 PostgreSQL 9.4+에서 `jsonb` 데이터 유형을 지원합니다.
([Pull Request](https://github.com/rails/rails/pull/16220))

* PostgreSQL 및 SQLite 어댑터는 더 이상 문자열 열에 255자의 기본 제한을 추가하지 않습니다.
([Pull Request](https://github.com/rails/rails/pull/14579))

* PostgreSQL 어댑터에서 `citext` 열 유형을 지원합니다.
([Pull Request](https://github.com/rails/rails/pull/12523))

* PostgreSQL 어댑터에서 사용자가 생성한 범위 유형을 지원합니다.
([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

* `sqlite3:///some/path`는 이제 절대 시스템 경로 `/some/path`로 해석됩니다. 상대 경로의 경우 `sqlite3:some/path`를 대신 사용하세요.
(이전에 `sqlite3:///some/path`는 상대 경로 `some/path`로 해석되었습니다. 이 동작은 Rails 4.1에서 폐기되었습니다).
([Pull Request](https://github.com/rails/rails/pull/14569))

* MySQL 5.6 이상에서 소수 초를 지원하도록 되었습니다.
(Pull Request [1](https://github.com/rails/rails/pull/8240),
[2](https://github.com/rails/rails/pull/14359))
*   모델을 예쁘게 출력하기 위해 `ActiveRecord::Base#pretty_print`를 추가했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload`는 이제 `m = Model.find(m.id)`와 동일하게 동작하며,
    즉 사용자 정의 `SELECT`에서 추가 속성을 유지하지 않습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15866))

*   `ActiveRecord::Base#reflections`는 이제 심볼 키 대신 문자열 키를 반환합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/17718))

*   마이그레이션에서 `references` 메서드는 외래 키의 유형을 지정하기 위한 `type` 옵션을 지원합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16231))

Active Model
------------

자세한 변경 사항은 [변경 로그][active-model]를 참조하십시오.

### 제거 사항

*   대체 없이 폐기된 `Validator#setup`을 제거했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/10716))

### 폐기 사항

*   `reset_#{attribute}`을 `restore_#{attribute}` 대신 사용하기 위해 폐기했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16180))

*   `ActiveModel::Dirty#reset_changes`을 `clear_changes_information` 대신 사용하기 위해 폐기했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16180))

### 주목할만한 변경 사항

*   `valid?`의 별칭으로 `validate`를 도입했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/14456))

*   `ActiveModel::Dirty`에서 변경된(더러워진) 속성을 이전 값으로 복원하기 위해 `restore_attributes` 메서드를 도입했습니다.
    (풀 리퀘스트 [1](https://github.com/rails/rails/pull/14861),
    [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password`는 이제 기본적으로 공백 비밀번호(즉, 공백만 포함하는 비밀번호)를 허용합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16412))

*   `has_secure_password`는 유효성 검사가 활성화되어 있는 경우 주어진 비밀번호가 72자 미만인지 확인합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15708))

Active Support
--------------

자세한 변경 사항은 [변경 로그][active-support]를 참조하십시오.

### 제거 사항

*   폐기된 `Numeric#ago`, `Numeric#until`, `Numeric#since`, `Numeric#from_now`을 제거했습니다.
    ([커밋](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   `ActiveSupport::Callbacks`에 대한 문자열 기반 종료자를 제거했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15100))

### 폐기 사항

*   대체 없이 `Kernel#silence_stderr`, `Kernel#capture`, `Kernel#quietly`를 폐기했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/13392))

*   `Class#superclass_delegating_accessor`를 사용하기 위해 `Class#class_attribute`을 사용하도록 폐기했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/14271))

*   `ActiveSupport::SafeBuffer#prepend!`를 `ActiveSupport::SafeBuffer#prepend`가 동일한 기능을 수행하도록 폐기했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/14529))

### 주목할만한 변경 사항

*   테스트 케이스가 실행되는 순서를 지정하기 위한 새로운 구성 옵션 `active_support.test_order`를 도입했습니다. 현재 이 옵션은 `:sorted`로 기본 설정되어 있지만, Rails 5.0에서 `:random`으로 변경될 예정입니다.
    ([커밋](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   블록 내에서 명시적 수신자 없이 `Object#try`와 `Object#try!`를 사용할 수 있습니다.
    ([커밋](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830),
    [풀 리퀘스트](https://github.com/rails/rails/pull/17361))

*   `travel_to` 테스트 도우미는 이제 `usec` 구성 요소를 0으로 잘라냅니다.
    ([커밋](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   항등 함수로 `Object#itself`를 도입했습니다.
    (커밋 [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810),
    [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   블록 내에서 명시적 수신자 없이 `Object#with_options`를 사용할 수 있습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16339))

*   지정된 단어 수로 문자열을 자르기 위해 `String#truncate_words`를 도입했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/16190))

*   해시의 값은 변경되어야 하지만 키는 그대로인 일반적인 패턴을 단순화하기 위해 `Hash#transform_values`와 `Hash#transform_values!`를 추가했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/15819))

*   `humanize` 인플렉터 도우미는 이제 선행하는 밑줄을 제거합니다.
    ([커밋](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   `Concern#class_methods`를 `module ClassMethods` 대신 사용할 수 있도록, 그리고 `module Foo; extend ActiveSupport::Concern; end` 보일러플레이트를 피하기 위해 `Kernel#concern`을 도입했습니다.
    ([커밋](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   상수 자동로딩 및 다시로딩에 관한 새로운 [가이드](autoloading_and_reloading_constants_classic_mode.html)를 추가했습니다.

크레딧
-------

Rails에 기여한 많은 사람들에게 감사드립니다. Rails를 안정적이고 견고한 프레임워크로 만들기 위해 많은 시간을 투자한 많은 사람들에게 경의를 표합니다.

[railties]:       https://github.com/rails/rails/blob/4-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/4-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/4-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/4-2-stable/actionmailer/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/4-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/4-2-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
