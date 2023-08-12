**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 95d91c83726e012162afc60c78688099
루비 온 레일즈 4.1 릴리스 노트
===============================

Rails 4.1의 주요 기능:

* Spring 애플리케이션 프리로더
* `config/secrets.yml`
* 액션 팩 변형
* 액션 메일러 미리보기

이 릴리스 노트는 주요 변경 사항만 다룹니다. 다양한 버그 수정 및 변경 사항에 대해서는 변경 로그를 참조하거나 GitHub의 주요 Rails 저장소의 [커밋 목록](https://github.com/rails/rails/commits/4-1-stable)을 확인하십시오.

--------------------------------------------------------------------------------

Rails 4.1로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드하는 경우 테스트 커버리지가 좋은 것이 좋습니다. 또한, Rails 4.1로 업데이트하기 전에 Rails 4.0으로 먼저 업그레이드하고 애플리케이션이 예상대로 실행되는지 확인하십시오. 업그레이드할 때 주의해야 할 사항은 [Ruby on Rails 업그레이드](upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1) 가이드에서 확인할 수 있습니다.


주요 기능
--------------

### Spring 애플리케이션 프리로더

Spring은 Rails 애플리케이션 프리로더입니다. 테스트, rake 작업 또는 마이그레이션을 실행할 때마다 애플리케이션을 매번 부팅할 필요 없이 백그라운드에서 애플리케이션을 실행하여 개발 속도를 높입니다.

새로운 Rails 4.1 애플리케이션은 "springified" binstub과 함께 제공됩니다. 이는 `bin/rails`와 `bin/rake`가 자동으로 프리로드된 spring 환경을 활용하도록 설정되어 있음을 의미합니다.

**rake 작업 실행하기:**

```bash
$ bin/rake test:models
```

**Rails 명령 실행하기:**

```bash
$ bin/rails console
```

**Spring 검사:**

```bash
$ bin/spring status
Spring is running:

 1182 spring server | my_app | started 29 mins ago
 3656 spring app    | my_app | started 23 secs ago | test mode
 3746 spring app    | my_app | started 10 secs ago | development mode
```

사용 가능한 모든 기능을 보려면 [Spring README](https://github.com/rails/spring/blob/master/README.md)를 참조하십시오.

기존 애플리케이션을 이 기능을 사용하도록 마이그레이션하는 방법은 [Ruby on Rails 업그레이드](upgrading_ruby_on_rails.html#spring) 가이드를 참조하십시오.

### `config/secrets.yml`

Rails 4.1은 `config` 폴더에 새로운 `secrets.yml` 파일을 생성합니다. 기본적으로 이 파일에는 애플리케이션의 `secret_key_base`가 포함되어 있지만, 외부 API의 액세스 키와 같은 다른 비밀도 저장할 수 있습니다.

이 파일에 추가된 비밀은 `Rails.application.secrets`를 통해 접근할 수 있습니다. 예를 들어, 다음과 같은 `config/secrets.yml`이 있는 경우:

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

개발 환경에서 `Rails.application.secrets.some_api_key`는 `SOMEKEY`를 반환합니다.

기존 애플리케이션을 이 기능을 사용하도록 마이그레이션하는 방법은 [Ruby on Rails 업그레이드](upgrading_ruby_on_rails.html#config-secrets-yml) 가이드를 참조하십시오.

### 액션 팩 변형

우리는 종종 전화기, 태블릿 및 데스크톱 브라우저에 대해 다른 HTML/JSON/XML 템플릿을 렌더링하고 싶어합니다. 변형을 사용하면 쉽게 할 수 있습니다.

요청 변형은 `:tablet`, `:phone` 또는 `:desktop`과 같은 요청 형식의 특수화입니다.

`before_action`에서 변형을 설정할 수 있습니다:

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

액션에서 형식과 마찬가지로 변형에 응답할 수 있습니다:

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # app/views/projects/show.html+tablet.erb를 렌더링합니다.
    html.phone { extra_setup; render ... }
  end
end
```

각 형식과 변형에 대해 별도의 템플릿을 제공할 수 있습니다:

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

인라인 구문을 사용하여 변형 정의를 간소화할 수도 있습니다:

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```
### 액션 메일러 미리보기

액션 메일러 미리보기는 이메일이 어떻게 보이는지 확인하기 위해 특정 URL을 방문하여 렌더링하는 방법을 제공합니다.

확인하려는 메일 객체를 반환하는 메서드를 가진 미리보기 클래스를 구현합니다:

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

미리보기는 http://localhost:3000/rails/mailers/notifier/welcome에서 사용할 수 있으며,
그리고 이들의 목록은 http://localhost:3000/rails/mailers에서 확인할 수 있습니다.

기본적으로, 이러한 미리보기 클래스는 `test/mailers/previews`에 위치합니다.
`preview_path` 옵션을 사용하여 이를 구성할 수 있습니다.

자세한 내용은
[문서](https://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails)
를 참조하세요.

### 액티브 레코드 열거형

데이터베이스에서 정수로 매핑되지만 이름으로 쿼리할 수 있는 열거형 속성을 선언합니다.

```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => 모든 아카이브된 Conversation을 위한 Relation

Conversation.statuses # => { "active" => 0, "archived" => 1 }
```

자세한 내용은
[문서](https://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html)
를 참조하세요.

### 메시지 검증기

메시지 검증기는 서명된 메시지를 생성하고 검증하는 데 사용될 수 있습니다. 이는
기억하기 토큰 및 친구와 같은 민감한 데이터를 안전하게 전송하는 데 유용합니다.

`Rails.application.message_verifier` 메서드는 secret_key_base와 주어진
메시지 검증기 이름에서 파생된 키로 메시지에 서명하는 새로운 메시지 검증기를 반환합니다:

```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# ActiveSupport::MessageVerifier::InvalidSignature 예외 발생
```

### Module#concerning

클래스 내에서 책임을 분리하기 위한 자연스러운, 저의식적인 방법:

```ruby
class Todo < ActiveRecord::Base
  concerning :EventTracking do
    included do
      has_many :events
    end

    def latest_event
      # ...
    end

    private
      def some_internal_method
        # ...
      end
  end
end
```

이 예제는 `EventTracking` 모듈을 인라인으로 정의하고 `ActiveSupport::Concern`로 확장한 다음
`Todo` 클래스에 혼합하는 것과 동일합니다.

자세한 내용은
[문서](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html)
를 참조하세요.

### 원격 `<script>` 태그로부터의 CSRF 보호

크로스 사이트 요청 위조(CSRF) 보호는 이제 JavaScript 응답을 가진 GET 요청도 포함합니다.
이는 제3자 사이트가 JavaScript URL을 참조하고 실행하여 민감한 데이터를 추출하려는 것을 방지합니다.

이는 `.js` URL을 사용하는 테스트 중 CSRF 보호가 실패하게 됩니다.
테스트를 XmlHttpRequests를 예상하는 것으로 명시적으로 업그레이드하세요.
`post :create, format: :js` 대신에 명시적인 `xhr :post, :create, format: :js`로 전환하세요.


Railties
--------

자세한 변경 사항은
[변경 로그](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md)
를 참조하세요.

### 삭제 사항

* `update:application_controller` rake 작업이 제거되었습니다.

* 폐기된 `Rails.application.railties.engines`가 제거되었습니다.

* 폐기된 `threadsafe!`가 Rails Config에서 제거되었습니다.

* 폐기된 `ActiveRecord::Generators::ActiveModel#update_attributes`가
  `ActiveRecord::Generators::ActiveModel#update`를 사용하도록 대체되었습니다.

* 폐기된 `config.whiny_nils` 옵션이 제거되었습니다.

* 테스트 실행을 위한 폐기된 rake 작업인 `rake test:uncommitted`와
  `rake test:recent`가 제거되었습니다.

### 주목할만한 변경 사항

* [Spring 애플리케이션
  프리로더](https://github.com/rails/spring)가
  새로운 애플리케이션에 기본으로 설치됩니다. 이는 `Gemfile`의 개발 그룹을 사용하므로
  프로덕션에는 설치되지 않습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/12958))

* 테스트 실패에 대한 필터되지 않은 백트레이스를 보여주기 위한 `BACKTRACE` 환경 변수가 추가되었습니다.
  ([커밋](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553))

* 환경 구성에서 `MiddlewareStack#unshift`를 노출시켰습니다.
  ([풀 리퀘스트](https://github.com/rails/rails/pull/12479))

* 메시지 검증기를 반환하는 `Application#message_verifier` 메서드가 추가되었습니다.
  ([풀 리퀘스트](https://github.com/rails/rails/pull/12995))

* 기본 생성된 테스트 도우미에서 필요한 `test_help.rb` 파일은
  `db/schema.rb` (또는 `db/structure.sql`)와 테스트 데이터베이스를 자동으로 최신 상태로 유지합니다.
  스키마를 다시로드하여 보류 중인 마이그레이션을 모두 해결하지 못하는 경우 오류가 발생합니다.
  `config.active_record.maintain_test_schema = false`로 설정하여 비활성화할 수 있습니다.
  ([풀 리퀘스트](https://github.com/rails/rails/pull/13528))
* `Rails.gem_version`를 소개하여 `Gem::Version.new(Rails.version)`을 반환하는 편리한 메소드로 소개하며, 버전 비교를 더 신뢰할 수 있는 방법을 제안합니다. ([Pull Request](https://github.com/rails/rails/pull/14103))

Action Pack
-----------

자세한 변경 사항은 [Changelog](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md)를 참조하십시오.

### 삭제 사항

* 통합 테스트를 위한 더 이상 사용되지 않는 Rails 애플리케이션 대체 기능을 제거하고 대신 `ActionDispatch.test_app`을 설정하십시오.

* 더 이상 사용되지 않는 `page_cache_extension` 구성을 제거하십시오.

* 더 이상 사용되지 않는 `ActionController::RecordIdentifier`를 제거하고 대신 `ActionView::RecordIdentifier`를 사용하십시오.

* Action Controller에서 더 이상 사용되지 않는 상수를 제거하십시오:

| 제거된 항목                         | 후계자                           |
|:-----------------------------------|:--------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### 주목할 만한 변경 사항

* `protect_from_forgery`는 크로스 오리진 `<script>` 태그도 방지합니다. 테스트를 업데이트하여 `xhr :get, :foo, format: :js` 대신 `get :foo, format: :js`를 사용하십시오. ([Pull Request](https://github.com/rails/rails/pull/13345))

* `#url_for`은 배열 내부에 옵션을 가진 해시를 사용합니다. ([Pull Request](https://github.com/rails/rails/pull/9599))

* `session#fetch` 메소드를 추가하였으며, [Hash#fetch](https://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch)와 유사하게 동작하지만 반환된 값은 항상 세션에 저장됩니다. ([Pull Request](https://github.com/rails/rails/pull/12692))

* Action View를 Action Pack에서 완전히 분리하였습니다. ([Pull Request](https://github.com/rails/rails/pull/11032))

* 깊은 munge에 의해 영향을 받은 키를 로그에 기록합니다. ([Pull Request](https://github.com/rails/rails/pull/13813))

* 보안 취약점 CVE-2013-0155를 해결하기 위해 사용된 params "깊은 munging"에서 제외되기 위한 새로운 구성 옵션 `config.action_dispatch.perform_deep_munge`을 추가하였습니다. ([Pull Request](https://github.com/rails/rails/pull/13188))

* 서명된 및 암호화된 쿠키 저장소에 대한 직렬화기를 지정하기 위한 새로운 구성 옵션 `config.action_dispatch.cookies_serializer`를 추가하였습니다. (Pull Requests [1](https://github.com/rails/rails/pull/13692), [2](https://github.com/rails/rails/pull/13945) / [자세한 내용](upgrading_ruby_on_rails.html#cookies-serializer))

* `render :plain`, `render :html` 및 `render :body`를 추가하였습니다. ([Pull Request](https://github.com/rails/rails/pull/14062) / [자세한 내용](upgrading_ruby_on_rails.html#rendering-content-from-string))


Action Mailer
-------------

자세한 변경 사항은 [Changelog](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md)를 참조하십시오.

### 주목할 만한 변경 사항

* 37 Signals mail_view gem을 기반으로 한 메일러 미리보기 기능을 추가하였습니다. ([Commit](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261))

* Action Mailer 메시지 생성에 대한 계측을 수행합니다. 메시지 생성에 걸리는 시간이 로그에 기록됩니다. ([Pull Request](https://github.com/rails/rails/pull/12556))


Active Record
-------------

자세한 변경 사항은 [Changelog](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md)를 참조하십시오.

### 삭제 사항

* 다음 `SchemaCache` 메소드에 대한 nil 전달을 더 이상 지원하지 않습니다: `primary_keys`, `tables`, `columns` 및 `columns_hash`.

* `ActiveRecord::Migrator#migrate`에서 더 이상 사용되지 않는 블록 필터를 제거하였습니다.

* `ActiveRecord::Migrator`에서 더 이상 사용되지 않는 String 생성자를 제거하였습니다.

* 호출 가능한 객체를 전달하지 않고 `scope`를 사용하는 것은 더 이상 지원되지 않습니다.

* `transaction_joinable=`를 `begin_transaction`과 `:joinable` 옵션을 사용하는 것으로 대체하였습니다.

* `decrement_open_transactions`를 제거하였습니다.

* `increment_open_transactions`를 제거하였습니다.

* `PostgreSQLAdapter#outside_transaction?` 메소드를 제거하였습니다. 대신 `#transaction_open?`을 사용하십시오.

* `ActiveRecord::Fixtures.find_table_name`을 `ActiveRecord::Fixtures.default_fixture_model_name`으로 대체하였습니다.

* `SchemaStatements`에서 `columns_for_remove`를 제거하였습니다.

* `SchemaStatements#distinct`를 제거하였습니다.

* `ActiveRecord::TestCase`를 Rails 테스트 스위트로 이동하였습니다. 이 클래스는 더 이상 공개되지 않으며 내부적으로만 사용됩니다.

* 연관성에서 `:dependent`에 대한 더 이상 지원되지 않는 `:restrict` 옵션을 제거하였습니다.

* 연관성에서 더 이상 지원되지 않는 `:delete_sql`, `:insert_sql`, `:finder_sql` 및 `:counter_sql` 옵션을 제거하였습니다.

* Column에서 더 이상 사용되지 않는 `type_cast_code` 메소드를 제거하였습니다.

* `ActiveRecord::Base#connection` 메소드를 제거하였습니다. 클래스를 통해 액세스하십시오.

* `auto_explain_threshold_in_seconds`에 대한 사용 중지 경고를 제거하였습니다.

* `Relation#count`에서 더 이상 지원되지 않는 `:distinct` 옵션을 제거하였습니다.

* `partial_updates`, `partial_updates?` 및 `partial_updates=` 메소드를 제거하였습니다.

* `scoped` 메소드를 제거하였습니다.

* `default_scopes?` 메소드를 제거하였습니다.

* 4.0에서 사용 중지된 암묵적 조인 참조를 제거하였습니다.
* `activerecord-deprecated_finders`를 종속성에서 제거했습니다.
  자세한 내용은 [젬 README](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders)를 참조하세요.

* `implicit_readonly`의 사용을 제거했습니다. 레코드를 `readonly`로 표시하려면 명시적으로 `readonly` 메서드를 사용하세요.
  ([Pull Request](https://github.com/rails/rails/pull/10769))

### 폐기 예정 기능

* 어디에서도 사용되지 않는 `quoted_locking_column` 메서드를 폐기 예정으로 표시했습니다.

* 내부에서 더 이상 사용되지 않는 `ConnectionAdapters::SchemaStatements#distinct`를 폐기 예정으로 표시했습니다.
  ([Pull Request](https://github.com/rails/rails/pull/10556))

* 테스트 데이터베이스가 이제 자동으로 유지되므로 `rake db:test:*` 작업을 폐기 예정으로 표시했습니다.
  railties 릴리스 노트를 참조하세요. ([Pull Request](https://github.com/rails/rails/pull/13528))

* 대체할 내용이 없는 `ActiveRecord::Base.symbolized_base_class`와 `ActiveRecord::Base.symbolized_sti_name`을 사용하지 않는 상태로 폐기 예정으로 표시했습니다.
  [Commit](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)

### 주목할만한 변경 사항

* 연결된 조건으로 인해 기본 범위가 더 이상 재정의되지 않습니다.

  이 변경 전에 모델에서 `default_scope`를 정의하면 동일한 필드의 연결된 조건에 의해 재정의되었습니다. 이제 다른 범위와 마찬가지로 병합됩니다. [자세한 내용](upgrading_ruby_on_rails.html#changes-on-default-scopes).

* `ActiveRecord::Base.to_param`을 추가하여 모델의 속성 또는 메서드에서 파생된 편리한 "예쁜" URL을 지원합니다.
  ([Pull Request](https://github.com/rails/rails/pull/12891))

* `ActiveRecord::Base.no_touching`을 추가하여 모델에서 터치를 무시할 수 있도록 합니다.
  ([Pull Request](https://github.com/rails/rails/pull/12772))

* `MysqlAdapter`와 `Mysql2Adapter`에 대해 불리언 유형 캐스팅을 통일했습니다.
  `type_cast`는 `true`에 대해 `1`을 반환하고 `false`에 대해 `0`을 반환합니다. ([Pull Request](https://github.com/rails/rails/pull/12425))

* `.unscope`는 이제 `default_scope`에서 지정된 조건을 제거합니다.
  ([Commit](https://github.com/rails/rails/commit/94924dc32baf78f13e289172534c2e71c9c8cade))

* 기존의 이름이 지정된 where 조건을 덮어쓰는 `ActiveRecord::QueryMethods#rewhere`를 추가했습니다.
  ([Commit](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2))

* `ActiveRecord::Base#cache_key`를 확장하여 사용할 수 있는 타임스탬프 속성 목록을 선택적으로 사용할 수 있도록 했습니다. 가장 높은 타임스탬프가 사용됩니다.
  ([Commit](https://github.com/rails/rails/commit/e94e97ca796c0759d8fcb8f946a3bbc60252d329))

* 쿼리할 수 있는 이름으로 데이터베이스에서 정수로 매핑되는 열거형 속성을 선언하기 위해 `ActiveRecord::Base#enum`을 추가했습니다.
  ([Commit](https://github.com/rails/rails/commit/db41eb8a6ea88b854bf5cd11070ea4245e1639c5))

* JSON 값에 대해 쓰기 시에 유형 캐스팅을 수행하여 데이터베이스에서 읽는 값과 일관성을 유지합니다.
  ([Pull Request](https://github.com/rails/rails/pull/12643))

* hstore 값에 대해 쓰기 시에 유형 캐스팅을 수행하여 데이터베이스에서 읽는 값과 일관성을 유지합니다.
  ([Commit](https://github.com/rails/rails/commit/5ac2341fab689344991b2a4817bd2bc8b3edac9d))

* 타사 생성기에서 `next_migration_number`에 액세스할 수 있도록 했습니다.
  ([Pull Request](https://github.com/rails/rails/pull/12407))

* `update_attributes`를 호출할 때 `nil` 인수가 전달되면 `ArgumentError`를 throw합니다. 구체적으로, 전달된 인수가 `stringify_keys`에 응답하지 않으면 오류가 throw됩니다.
  ([Pull Request](https://github.com/rails/rails/pull/9860))

* `CollectionAssociation#first`/`#last` (예: `has_many`)는 전체 컬렉션을 로드하는 대신 `LIMIT`된 쿼리를 사용하여 결과를 가져옵니다.
  ([Pull Request](https://github.com/rails/rails/pull/12137))

* Active Record 모델 클래스의 `inspect`는 새로운 연결을 초기화하지 않습니다. 따라서 데이터베이스가 없을 때 `inspect`를 호출하면 더 이상 예외가 발생하지 않습니다.
  ([Pull Request](https://github.com/rails/rails/pull/11014))

* `count`에 대한 열 제한을 제거하고 SQL이 잘못된 경우 데이터베이스에서 예외를 발생시킵니다.
  ([Pull Request](https://github.com/rails/rails/pull/10710))

* Rails는 이제 역 관계를 자동으로 감지합니다. 연관성에 `:inverse_of` 옵션을 설정하지 않으면 Active Record는 휴리스틱을 기반으로 역 관계를 추측합니다.
  ([Pull Request](https://github.com/rails/rails/pull/10886))

* ActiveRecord::Relation에서 별칭이 지정된 속성을 처리합니다. 심볼 키를 사용할 때 ActiveRecord는 이제 별칭이 지정된 속성 이름을 데이터베이스에서 실제로 사용되는 열 이름으로 변환합니다.
  ([Pull Request](https://github.com/rails/rails/pull/7839))

* 픽스처 파일의 ERB는 더 이상 주 객체의 컨텍스트에서 평가되지 않습니다. 여러 픽스처에서 사용되는 도우미 메서드는 `ActiveRecord::FixtureSet.context_class`에 포함된 모듈에 정의되어야 합니다.
  ([Pull Request](https://github.com/rails/rails/pull/13022))

* RAILS_ENV가 명시적으로 지정된 경우 테스트 데이터베이스를 생성하거나 삭제하지 않습니다.
  ([Pull Request](https://github.com/rails/rails/pull/13629))

* `Relation`은 이제 `#map!` 및 `#delete_if`와 같은 변경자 메서드를 갖지 않습니다. 이러한 메서드를 사용하기 전에 `#to_a`를 호출하여 `Array`로 변환하세요.
  ([Pull Request](https://github.com/rails/rails/pull/13314))
* `find_in_batches`, `find_each`, `Result#each` 및 `Enumerable#index_by`는 이제 크기를 계산할 수 있는 `Enumerator`를 반환합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/13938))

* `scope`, `enum` 및 연관 관계는 이제 "위험한" 이름 충돌 시 예외를 발생시킵니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/13450), [풀 리퀘스트](https://github.com/rails/rails/pull/13896))

* `second`부터 `fifth` 메서드는 `first` 검색기와 같은 역할을 합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/13757))

* `touch`가 `after_commit` 및 `after_rollback` 콜백을 실행하도록 변경되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/12031))

* `sqlite >= 3.8.0`에서 부분 인덱스를 사용할 수 있도록 변경되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/13350))

* `change_column_null`을 되돌릴 수 있도록 변경되었습니다. ([커밋](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96))

* 마이그레이션 후 스키마 덤프를 비활성화하는 플래그가 추가되었습니다. 이는 새로운 애플리케이션의 프로덕션 환경에서 기본적으로 `false`로 설정됩니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/13948))

Active Model
------------

자세한 변경 사항은 [Changelog](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md)를 참조하십시오.

### 폐기 사항

* `Validator#setup`을 폐기하였습니다. 이제 검증기의 생성자에서 수동으로 수행해야 합니다. ([커밋](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a))

### 주요 변경 사항

* `ActiveModel::Dirty`에 `reset_changes` 및 `changes_applied`라는 새로운 API 메서드가 추가되었습니다. 이들은 변경 상태를 제어합니다.

* 검증을 정의할 때 여러 컨텍스트를 지정할 수 있는 기능이 추가되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/13754))

* `attribute_changed?`는 이제 속성이 주어진 값으로 `:from` 및/또는 `:to` 변경되었는지 확인하기 위해 해시를 인수로 받을 수 있습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/13131))


Active Support
--------------

자세한 변경 사항은 [Changelog](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md)를 참조하십시오.


### 제거 사항

* `MultiJSON` 종속성이 제거되었습니다. 따라서 `ActiveSupport::JSON.decode`는 이제 `MultiJSON`에 대한 옵션 해시를 더 이상 허용하지 않습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/10576) / [자세한 내용](upgrading_ruby_on_rails.html#changes-in-json-handling))

* JSON으로 사용자 정의 객체를 인코딩하기 위해 사용되는 `encode_json` 후크가 제거되었습니다. 이 기능은 [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) 젬으로 분리되었습니다. ([관련 풀 리퀘스트](https://github.com/rails/rails/pull/12183) / [자세한 내용](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 대체 없이 폐기된 `ActiveSupport::JSON::Variable`이 제거되었습니다.

* 대체 없이 폐기된 `String#encoding_aware?` 코어 익스텐션(`core_ext/string/encoding`)이 제거되었습니다.

* 대체 없이 폐기된 `Module#local_constant_names`이 `Module#local_constants`로 대체되었습니다.

* 대체 없이 폐기된 `DateTime.local_offset`이 `DateTime.civil_from_format`으로 대체되었습니다.

* 대체 없이 폐기된 `Logger` 코어 익스텐션(`core_ext/logger.rb`)이 제거되었습니다.

* 대체 없이 폐기된 `Time#time_with_datetime_fallback`, `Time#utc_time` 및 `Time#local_time`이 `Time#utc` 및 `Time#local`로 대체되었습니다.

* 대체 없이 폐기된 `Hash#diff`가 제거되었습니다.

* 대체 없이 폐기된 `Date#to_time_in_current_zone`이 `Date#in_time_zone`으로 대체되었습니다.

* 대체 없이 폐기된 `Proc#bind`가 제거되었습니다.

* 대체 없이 폐기된 `Array#uniq_by` 및 `Array#uniq_by!`가 기본 `Array#uniq` 및 `Array#uniq!`로 대체되었습니다.

* 대체 없이 폐기된 `ActiveSupport::BasicObject`가 `ActiveSupport::ProxyObject`로 대체되었습니다.

* 대체 없이 폐기된 `BufferedLogger`가 `ActiveSupport::Logger`로 대체되었습니다.

* 대체 없이 폐기된 `assert_present` 및 `assert_blank` 메서드가 `assert object.blank?` 및 `assert object.present?`로 대체되었습니다.

* 필터 객체의 `#filter` 메서드가 제거되었으며 대응하는 메서드를 사용하십시오 (예: 전처리 필터에는 `#before`를 사용하십시오).

* 기본 변형에서 'cow' => 'kine' 불규칙한 변형이 제거되었습니다. ([커밋](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9))

### 폐기 사항

* `Numeric#{ago,until,since,from_now}`을 폐기하였습니다. 사용자는 값을 명시적으로 AS::Duration으로 변환해야 합니다. 예: `5.ago` => `5.seconds.ago` ([풀 리퀘스트](https://github.com/rails/rails/pull/12389))

* `active_support/core_ext/object/to_json` require 경로를 폐기하였습니다. 대신 `active_support/core_ext/object/json`을 require하십시오. ([풀 리퀘스트](https://github.com/rails/rails/pull/12203))

* `ActiveSupport::JSON::Encoding::CircularReferenceError`를 폐기하였습니다. 이 기능은 [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) 젬으로 분리되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/12785) / [자세한 내용](upgrading_ruby_on_rails.html#changes-in-json-handling))

* `ActiveSupport.encode_big_decimal_as_string` 옵션을 폐기하였습니다. 이 기능은 [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) 젬으로 분리되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/13060) / [자세한 내용](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 사용자 정의 `BigDecimal` 직렬화를 폐기하였습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/13911))

### 주요 변경 사항

* `ActiveSupport`의 JSON 인코더가 순수 루비에서 사용자 정의 인코딩을 수행하는 대신 JSON 젬을 활용하도록 다시 작성되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/12183) / [자세한 내용](upgrading_ruby_on_rails.html#changes-in-json-handling))

* JSON 젬과의 호환성이 개선되었습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/12862) / [자세한 내용](upgrading_ruby_on_rails.html#changes-in-json-handling))

* `ActiveSupport::Testing::TimeHelpers#travel` 및 `#travel_to`가 추가되었습니다. 이 메서드들은 `Time.now` 및 `Date.today`을 stub하여 현재 시간을 주어진 시간이나 기간으로 변경합니다.
* `ActiveSupport::Testing::TimeHelpers#travel_back`를 추가했습니다. 이 메소드는 `travel`과 `travel_to`에 의해 추가된 스텁을 제거하여 현재 시간을 원래 상태로 돌려줍니다. ([Pull Request](https://github.com/rails/rails/pull/13884))

* `Numeric#in_milliseconds`를 추가했습니다. 예를 들어 `1.hour.in_milliseconds`와 같이 사용하여 `getTime()`과 같은 JavaScript 함수에 전달할 수 있습니다. ([Commit](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643))

* `Date#middle_of_day`, `DateTime#middle_of_day` 및 `Time#middle_of_day` 메소드를 추가했습니다. 또한 `midday`, `noon`, `at_midday`, `at_noon` 및 `at_middle_of_day`를 별칭으로 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/10879))

* `Date#all_week/month/quarter/year`를 추가하여 날짜 범위를 생성할 수 있도록 했습니다. ([Pull Request](https://github.com/rails/rails/pull/9685))

* `Time.zone.yesterday`와 `Time.zone.tomorrow`를 추가했습니다. ([Pull Request](https://github.com/rails/rails/pull/12822))

* `String#remove(pattern)`을 추가하여 `String#gsub(pattern,'')`의 일반적인 패턴을 간단하게 사용할 수 있도록 했습니다. ([Commit](https://github.com/rails/rails/commit/5da23a3f921f0a4a3139495d2779ab0d3bd4cb5f))

* `Hash#compact`와 `Hash#compact!`를 추가하여 해시에서 값이 nil인 항목을 제거할 수 있도록 했습니다. ([Pull Request](https://github.com/rails/rails/pull/13632))

* `blank?`와 `present?`는 싱글톤을 반환하도록 수정되었습니다. ([Commit](https://github.com/rails/rails/commit/126dc47665c65cd129967cbd8a5926dddd0aa514))

* 새로운 `I18n.enforce_available_locales` 구성을 기본값으로 `true`로 설정하여 `I18n`이 전달된 모든 로케일이 `available_locales` 목록에 선언되어야 함을 보장하도록 했습니다. ([Pull Request](https://github.com/rails/rails/pull/13341))

* `Module#concerning`을 도입했습니다. 이는 클래스 내에서 책임을 분리하는 자연스럽고 간단한 방법입니다. ([Commit](https://github.com/rails/rails/commit/1eee0ca6de975b42524105a59e0521d18b38ab81))

* `Object#presence_in`을 추가하여 허용된 목록에 값을 추가하는 것을 간소화했습니다. ([Commit](https://github.com/rails/rails/commit/4edca106daacc5a159289eae255207d160f22396))


크레딧
-------

Rails에 많은 시간을 투자한 많은 사람들에게 감사의 인사를 전합니다. Rails를 안정적이고 견고한 프레임워크로 만들어준 모든 분들에게 경의를 표합니다.
[Rails 기여자 전체 목록](https://contributors.rubyonrails.org/)을 참조하세요.
