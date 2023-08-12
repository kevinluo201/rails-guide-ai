**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b1c2c8ad5c4bacb2e3b92aa320c4da3d
루비 온 레일즈 6.0 릴리스 노트
===============================

Rails 6.0의 주요 기능:

* 액션 메일박스
* 액션 텍스트
* 병렬 테스트
* 액션 케이블 테스트

이 릴리스 노트는 주요 변경 사항만 다룹니다. 다양한 버그 수정 및 변경 사항에 대해서는 변경 로그를 참조하거나 GitHub의 주요 Rails 저장소의 [커밋 목록](https://github.com/rails/rails/commits/6-0-stable)을 확인하십시오.

--------------------------------------------------------------------------------

Rails 6.0으로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드하는 경우, 업그레이드하기 전에 충분한 테스트 커버리지를 가지고 있는 것이 좋습니다. 또한, Rails 5.2로 먼저 업그레이드하고 애플리케이션이 예상대로 작동하는지 확인한 후에 Rails 6.0으로 업데이트를 시도해야 합니다. 업그레이드할 때 주의해야 할 사항은 [Ruby on Rails 업그레이드](upgrading_ruby_on_rails.html#upgrading-from-rails-5-2-to-rails-6-0) 가이드에서 확인할 수 있습니다.

주요 기능
--------------

### 액션 메일박스

[Pull Request](https://github.com/rails/rails/pull/34786)

[액션 메일박스](https://github.com/rails/rails/tree/6-0-stable/actionmailbox)는 컨트롤러와 유사한 메일박스로 들어오는 이메일을 라우팅할 수 있게 해줍니다. 액션 메일박스에 대해 더 자세히 알아보려면 [액션 메일박스 기본 사항](action_mailbox_basics.html) 가이드를 참조하십시오.

### 액션 텍스트

[Pull Request](https://github.com/rails/rails/pull/34873)

[액션 텍스트](https://github.com/rails/rails/tree/6-0-stable/actiontext)는 Rails에 풍부한 텍스트 콘텐츠와 편집 기능을 제공합니다. 이에는 [Trix 편집기](https://trix-editor.org)가 포함되어 있으며, 서식, 링크, 인용구, 목록, 포함된 이미지 및 갤러리 등 모든 것을 처리합니다. Trix 편집기에서 생성된 풍부한 텍스트 콘텐츠는 애플리케이션의 기존 Active Record 모델과 연관된 자체 RichText 모델에 저장됩니다. 포함된 이미지(또는 기타 첨부 파일)는 Active Storage를 사용하여 자동으로 저장되고 포함된 RichText 모델과 연결됩니다.

액션 텍스트에 대해 더 자세히 알아보려면 [액션 텍스트 개요](action_text_overview.html) 가이드를 참조하십시오.

### 병렬 테스트

[Pull Request](https://github.com/rails/rails/pull/31900)

[병렬 테스트](testing.html#parallel-testing)를 사용하면 테스트 스위트를 병렬로 실행할 수 있습니다. 프로세스 포크가 기본 방법이지만 스레딩도 지원됩니다. 병렬로 테스트를 실행하면 전체 테스트 스위트를 실행하는 시간이 줄어듭니다.

### 액션 케이블 테스트

[Pull Request](https://github.com/rails/rails/pull/33659)

[액션 케이블 테스트 도구](testing.html#testing-action-cable)를 사용하면 연결, 채널, 브로드캐스트와 같은 액션 케이블 기능을 테스트할 수 있습니다.

Railties
--------

자세한 변경 사항은 [변경 로그][railties]를 참조하십시오.

### 제거 사항

* 플러그인 템플릿 내에서 사용되는 `after_bundle` 도우미를 제거했습니다.
    ([커밋](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

* `config.ru`에서 응용 프로그램 클래스를 `run`의 인수로 사용하는 것을 지원하지 않도록 제거했습니다.
    ([커밋](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))

* 레일즈 명령에서 `environment` 인수를 제거했습니다.
    ([커밋](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

* 생성기 및 템플릿에서 `capify!` 메서드를 제거했습니다.
    ([커밋](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

* `config.secret_token`을 제거했습니다.
    ([커밋](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### 폐지 사항

* `rails server`에 Rack 서버 이름을 일반 인수로 전달하는 것을 폐지했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/32058))
* `HOST` 환경 변수를 사용하여 서버 IP를 지정하는 기능을 지원하지 않도록 지원 중단합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32540))

* `config_for`에서 반환된 해시에 대해 심볼이 아닌 키로 액세스하는 것을 지원하지 않도록 지원 중단합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35198))

### 주목할만한 변경 사항

* `rails server` 명령에 서버를 지정하기 위해 명시적인 `--using` 또는 `-u` 옵션을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32058))

* `rails routes`의 출력을 확장된 형식으로 볼 수 있는 기능을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32130))

* 인라인 Active Job 어댑터를 사용하여 시드 데이터베이스 작업을 실행합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34953))

* 애플리케이션의 데이터베이스를 변경하기 위한 `rails db:system:change` 명령을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34832))

* `rails test:channels` 명령을 추가하여 Action Cable 채널만 테스트할 수 있도록 합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34947))

* DNS rebinding 공격에 대한 보호 기능을 도입합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33145))

* 생성기 명령을 실행하는 동안 실패 시 중단할 수 있는 기능을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34420))

* Rails 6에서 Webpacker를 기본 JavaScript 컴파일러로 설정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33079))

* `rails db:migrate:status` 명령에 여러 데이터베이스 지원을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34137))

* 생성기에서 여러 데이터베이스의 다른 마이그레이션 경로를 사용할 수 있는 기능을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34021))

* 다중 환경 인증 정보를 지원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33521))

* 테스트 환경에서 기본 캐시 저장소로 `null_store`를 사용합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33773))

Action Cable
------------

자세한 변경 사항은 [Changelog][action-cable]을 참조하십시오.

### 제거 사항

* `ActionCable.startDebugging()` 및 `ActionCable.stopDebugging()`을 `ActionCable.logger.enabled`로 대체합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

### 지원 중단 사항

* Rails 6.0에서 Action Cable에 대한 지원 중단 사항은 없습니다.

### 주목할만한 변경 사항

* `cable.yml`에서 PostgreSQL 구독 어댑터에 대한 `channel_prefix` 옵션을 지원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35276))

* `ActionCable::Server::Base`에 사용자 정의 구성을 전달할 수 있도록 합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34714))

* `:action_cable_connection` 및 `:action_cable_channel` 로드 후크를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35094))

* `Channel::Base#broadcast_to` 및 `Channel::Base.broadcasting_for`를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35021))

* `ActionCable::Connection`에서 `reject_unauthorized_connection`을 호출할 때 연결을 닫습니다.
    ([Pull Request](https://github.com/rails/rails/pull/34194))

* Action Cable JavaScript 패키지를 CoffeeScript에서 ES2015로 변환하고 npm 배포에서 소스 코드를 게시합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

* WebSocket 어댑터 및 로거 어댑터의 구성을 `ActionCable`의 속성에서 `ActionCable.adapters`로 이동합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

* Redis 어댑터에 `id` 옵션을 추가하여 Action Cable의 Redis 연결을 구분합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

자세한 변경 사항은 [Changelog][action-pack]을 참조하십시오.

### 제거 사항

* `combined_fragment_cache_key`를 선호하는 `fragment_cache_key` 도우미를 사용 중단합니다.
    ([Commit](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

* `ActionDispatch::TestResponse`에서 사용 중단된 메서드를 제거합니다:
    `#success?`를 `#successful?`로, `#missing?`을 `#not_found?`로, `#error?`를 `#server_error?`로 대체합니다.
    ([Commit](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### 지원 중단 사항

* `ActionDispatch::Http::ParameterFilter`를 `ActiveSupport::ParameterFilter`를 선호하는 것으로 사용 중단합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34039))

* 컨트롤러 레벨의 `force_ssl`을 `config.force_ssl`로 대체하는 것으로 사용 중단합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32277))

[action-cable]: https://github.com/rails/rails/blob/master/actioncable/CHANGELOG.md
[action-pack]: https://github.com/rails/rails/blob/master/actionpack/CHANGELOG.md
### 주목할만한 변경 사항

*   `ActionDispatch::Response#content_type`을 Content-Type 헤더로 반환하도록 변경.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/36034))

*   리소스 파라미터에 콜론이 포함되어 있으면 `ArgumentError`를 발생시킴.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/35236))

*   특정 브라우저 기능을 정의하기 위해 블록을 사용하여 `ActionDispatch::SystemTestCase.driven_by` 호출 가능.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/35081))

*   DNS 리바인딩 공격으로부터 보호하기 위한 `ActionDispatch::HostAuthorization` 미들웨어 추가.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/33145))

*   `ActionController::TestCase`에서 `parsed_body` 사용 가능하도록 함.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/34717))

*   `as:` 이름 지정 사양 없이 동일한 컨텍스트에서 여러 루트 라우트가 존재하는 경우 `ArgumentError` 발생.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/34494))

*   파라미터 파싱 오류 처리를 위해 `#rescue_from` 사용 가능하도록 함.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/34341))

*   파라미터를 반복하는 데 사용할 수 있는 `ActionController::Parameters#each_value` 추가.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/33979))

*   `send_data` 및 `send_file`에서 Content-Disposition 파일 이름 인코딩.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/33829))

*   `ActionController::Parameters#each_key` 노출.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/33758))

*   서명된/암호화된 쿠키 내부에 목적 및 만료 메타데이터 추가하여 쿠키의 값을 다른 쿠키로 복사하는 것을 방지.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/32937))

*   충돌하는 `respond_to` 호출에 대해 `ActionController::RespondToMismatchError` 발생.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/33446))

*   요청 형식에 대한 템플릿이 누락된 경우에 대한 명시적인 오류 페이지 추가.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29286))

*   `ActionDispatch::DebugExceptions.register_interceptor` 도입, 렌더링되기 전에 예외를 처리하기 위한 방법.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/23868))

*   요청당 하나의 Content-Security-Policy nonce 헤더 값만 출력.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/32602))

*   명시적으로 컨트롤러에 포함될 수 있는 Rails 기본 헤더 구성을 위한 모듈 추가.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/32484))

*   `ActionDispatch::Request::Session`에 `#dig` 추가.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/32446))

액션 뷰
-----------

자세한 변경 사항은 [변경 로그][action-view]를 참조하십시오.

### 제거 사항

*   폐기된 `image_alt` 헬퍼 제거.
    ([커밋](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f))

*   기능이 이미 `record_tag_helper` 젬으로 이동된 빈 `RecordTagHelper` 모듈 제거.
    ([커밋](https://github.com/rails/rails/commit/5c5ddd69b1e06fb6b2bcbb021e9b8dae17e7cb31))

### 폐기 사항

*   대체 없이 `ActionView::Template.finalize_compiled_template_methods`를 폐기.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/35036))

*   대체 없이 `config.action_view.finalize_compiled_template_methods`를 폐기.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/35036))

*   `options_from_collection_for_select` 뷰 헬퍼에서 비공개 모델 메서드 호출 폐기.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/33547))

### 주목할만한 변경 사항

*   개발 모드에서 파일 변경 시에만 Action View 캐시를 지우고 개발 속도 향상.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/35629))

*   모든 Rails npm 패키지를 `@rails` 스코프로 이동.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/34905))

*   등록된 MIME 유형에서만 형식을 허용.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/35604), [풀 리퀘스트](https://github.com/rails/rails/pull/35753))

*   템플릿 및 부분 렌더링 서버 출력에 할당 추가.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/34136))

*   `date_select` 태그에 `year_format` 옵션 추가하여 연도 이름을 사용자 정의할 수 있도록 함.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/32190))

*   자동 Content Security Policy를 위한 자동 nonce 생성을 지원하기 위해 `javascript_include_tag` 헬퍼에 `nonce: true` 옵션 추가.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/32607))

*   `ActionView::Template` 최종화기 비활성화 또는 활성화를 위한 `action_view.finalize_compiled_template_methods` 구성 추가.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/32418))

[action-view]: https://github.com/rails/rails/blob/master/actionview/CHANGELOG.md
*   `rails_ujs`에서 JavaScript `confirm` 호출을 독립적이고 오버라이드 가능한 메서드로 추출합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32404))

*   UTF-8 인코딩을 강제하는 `action_controller.default_enforce_utf8` 구성 옵션을 추가합니다. 기본값은 `false`입니다.
    ([Pull Request](https://github.com/rails/rails/pull/32125))

*   로케일 키에 대한 I18n 키 스타일 지원을 submit 태그에 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/26799))

Action Mailer
-------------

자세한 변경 사항은 [Changelog][action-mailer]를 참조하세요.

### 제거된 사항

### 폐기된 사항

*   Action Mailbox를 선호하는 대신 `ActionMailer::Base.receive`를 폐기합니다.
    ([Commit](https://github.com/rails/rails/commit/e3f832a7433a291a51c5df397dc3dd654c1858cb))

*   `DeliveryJob`와 `Parameterized::DeliveryJob`를 `MailDeliveryJob`를 선호하는 대신 폐기합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

### 주목할만한 변경 사항

*   일반 및 매개변수화된 메일을 전달하기 위해 `MailDeliveryJob`를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

*   사용자 정의 이메일 전달 작업이 Action Mailer 테스트 어설션과 함께 작동하도록 허용합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   블록을 사용하여 다중 파트 이메일에 대한 템플릿 이름을 지정할 수 있도록 합니다.
    ([Pull Request](https://github.com/rails/rails/pull/22534))

*   `deliver.action_mailer` 알림의 페이로드에 `perform_deliveries`를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   `perform_deliveries`가 false인 경우 이메일 전송이 건너뛰어졌음을 나타내는 로깅 메시지를 개선합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   블록 없이 `assert_enqueued_email_with`를 호출할 수 있도록 합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   `assert_emails` 블록에서 대기 중인 메일 전달 작업을 수행합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32231))

*   `ActionMailer::Base`에서 옵저버와 인터셉터를 등록 해제할 수 있도록 합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32207))

Active Record
-------------

자세한 변경 사항은 [Changelog][active-record]를 참조하세요.

### 제거된 사항

*   트랜잭션 객체에서 폐기된 `#set_state`를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/6c745b0c5152a4437163a67707e02f4464493983))

*   데이터베이스 어댑터에서 폐기된 `#supports_statement_cache?`를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553))

*   데이터베이스 어댑터에서 폐기된 `#insert_fixtures`를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece))

*   `ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?`를 폐기합니다.
    ([Commit](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf))

*   블록이 전달될 때 `sum`에 열 이름을 전달하는 지원을 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/91ddb30083430622188d76eb9f29b78131df67f9))

*   블록이 전달될 때 `count`에 열 이름을 전달하는 지원을 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/67356f2034ab41305af7218f7c8b2fee2d614129))

*   관계에서 누락된 메서드를 Arel로 위임하는 지원을 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0))

*   관계에서 누락된 메서드를 클래스의 비공개 메서드로 위임하는 지원을 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d))

*   `#cache_key`에 대한 타임스탬프 이름 지정 지원을 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea))

*   `ActiveRecord::Migrator.migrations_path=`를 폐기합니다.
    ([Commit](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d))

*   `expand_hash_conditions_for_aggregates`를 폐기합니다.
    ([Commit](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e))


### 폐기된 사항

*   고유성 유효성 검사를 위한 대소문자 구별 정렬 비교에 대한 불일치를 폐기합니다.
    ([Commit](https://github.com/rails/rails/commit/9def05385f1cfa41924bb93daa187615e88c95b9))

*   수신자 범위가 유출된 경우 클래스 레벨 질의 메서드 사용을 폐기합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35280))

*   `config.active_record.sqlite3.represent_boolean_as_integer`를 폐기합니다.
    ([Commit](https://github.com/rails/rails/commit/f59b08119bc0c01a00561d38279b124abc82561b))

*   `migrations_paths`를 `connection.assume_migrated_upto_version`에 전달하는 것을 폐기합니다.
    ([Commit](https://github.com/rails/rails/commit/c1b14aded27e063ead32fa911aa53163d7cfc21a))

*   `ActiveRecord::Result#to_hash`를 `ActiveRecord::Result#to_a`로 대체하기 위해 `ActiveRecord::Result#to_hash`를 폐기합니다.
    ([Commit](https://github.com/rails/rails/commit/16510d609c601aa7d466809f3073ec3313e08937))

*   `DatabaseLimits`의 메서드인 `column_name_length`, `table_name_length`,
    `columns_per_table`, `indexes_per_table`, `columns_per_multicolumn_index`,
    `sql_query_length`, `joins_per_query`를 폐기합니다.
    ([Commit](https://github.com/rails/rails/commit/e0a1235f7df0fa193c7e299a5adee88db246b44f))

*   `update_attributes`/`!`를 `update`/`!`로 대체하기 위해 `update_attributes`/`!`를 폐기합니다.
    ([Commit](https://github.com/rails/rails/commit/5645149d3a27054450bd1130ff5715504638a5f5))

### 주목할만한 변경 사항

*   `sqlite3` 젬의 최소 버전을 1.4로 올립니다.
    ([Pull Request](https://github.com/rails/rails/pull/35844))
*   `rails db:prepare`를 추가하여 데이터베이스가 존재하지 않을 경우 생성하고 마이그레이션을 실행합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35768))

*   `after_save_commit` 콜백을 추가하여 `after_commit :hook, on: [ :create, :update ]`를 간편하게 사용할 수 있습니다.
    ([Pull Request](https://github.com/rails/rails/pull/35804))

*   관련된 레코드를 관계에서 추출하기 위해 `ActiveRecord::Relation#extract_associated`를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35784))

*   SQL 코멘트를 ActiveRecord::Relation 쿼리에 추가하기 위해 `ActiveRecord::Relation#annotate`를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35617))

*   데이터베이스에 Optimizer Hints를 설정하는 기능을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35615))

*   대량의 삽입을 수행하기 위한 `insert_all`/`insert_all!`/`upsert_all` 메서드를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35631))

*   현재 환경의 각 데이터베이스 테이블을 잘라내고 시드를 로드하는 `rails db:seed:replant`를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34779))

*   `unscope(:select).select(fields)`의 단축키인 `reselect` 메서드를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33611))

*   모든 enum 값에 대한 부정적인 스코프를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35381))

*   조건부 삭제를 위한 `#destroy_by`와 `#delete_by`를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35316))

*   자동으로 데이터베이스 연결을 전환하는 기능을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35073))

*   블록의 실행 동안 데이터베이스에 대한 쓰기를 방지하는 기능을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34505))

*   다중 데이터베이스를 지원하기 위한 연결 전환을 위한 API를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34052))

*   마이그레이션의 기본값으로 타임스탬프에 정밀도를 설정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34970))

*   MySQL에서 텍스트와 blob 크기를 변경하기 위한 `:size` 옵션을 지원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35071))

*   `dependent: :nullify` 전략에서 다형성 관계에 대해 외래 키와 외래 타입 열을 모두 NULL로 설정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/28078))

*   `ActiveRecord::Relation#exists?`에 `ActionController::Parameters`의 허용된 인스턴스를 인수로 전달할 수 있도록 합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34891))

*   Ruby 2.6에서 도입된 무한 범위를 지원하기 위해 `#where`에 대한 지원을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34906))

*   MySQL의 기본 create table 옵션으로 `ROW_FORMAT=DYNAMIC`을 설정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34742))

*   `ActiveRecord.enum`에 의해 생성된 스코프를 비활성화할 수 있는 기능을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34605))

*   열에 대한 암시적 정렬을 구성할 수 있도록 합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34480))

*   PostgreSQL 최소 버전을 9.3으로 올리고, 9.1과 9.2의 지원을 중단합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34520))

*   enum의 값들을 변경하려고 할 때 에러를 발생시키고, 값을 동결합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34517))

*   `ActiveRecord::StatementInvalid` 오류의 SQL을 별도의 오류 속성으로 만들고, SQL 바인드를 별도의 오류 속성으로 포함시킵니다.
    ([Pull Request](https://github.com/rails/rails/pull/34468))

*   `create_table`에 `:if_not_exists` 옵션을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/31382))

*   `rails db:schema:cache:dump`와 `rails db:schema:cache:clear`에 다중 데이터베이스 지원을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34181))

*   `ActiveRecord::Base.connected_to`의 데이터베이스 해시에 해시 및 URL 구성을 지원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34196))

*   MySQL에 대한 기본 표현식과 표현식 인덱스 지원을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34307))

*   `change_table` 마이그레이션 헬퍼에 대한 `index` 옵션을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/23593))
* 마이그레이션에서 `transaction`이 되돌아갈 때 이전에는 되돌아간 마이그레이션 내의 명령이 되돌아가지 않았습니다. 이 변경 사항은 이를 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/31604))

* `ActiveRecord::Base.configurations=`을 심볼화된 해시로 설정할 수 있도록 허용합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33968))

* 레코드가 실제로 저장된 경우에만 카운터 캐시를 업데이트하도록 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33913))

* SQLite 어댑터에 표현식 인덱스 지원을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33874))

* 연관된 레코드에 대한 autosave 콜백을 하위 클래스에서 재정의할 수 있도록 허용합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33378))

* 최소 MySQL 버전을 5.5.8로 올립니다.
    ([Pull Request](https://github.com/rails/rails/pull/33853))

* MySQL에서 기본적으로 utf8mb4 문자 집합을 사용하도록 변경합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33608))

* `#inspect`에서 민감한 데이터를 필터링하는 기능을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33756), [Pull Request](https://github.com/rails/rails/pull/34208))

* `ActiveRecord::Base.configurations`를 해시 대신 객체를 반환하도록 변경합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33637))

* 어드바이저리 락을 비활성화하기 위한 데이터베이스 구성을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33691))

* SQLite3 어댑터의 `alter_table` 메서드를 수정하여 외래 키를 복원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33585))

* `remove_foreign_key`의 `:to_table` 옵션을 반전 가능하도록 허용합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33530))

* 지정된 정밀도를 가진 MySQL 시간 유형의 기본값을 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33280))

* `touch` 옵션이 `Persistence#touch` 메서드와 일관되도록 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33107))

* 마이그레이션에서 중복된 열 정의에 대해 예외를 발생시킵니다.
    ([Pull Request](https://github.com/rails/rails/pull/33029))

* 최소 SQLite 버전을 3.8로 올립니다.
    ([Pull Request](https://github.com/rails/rails/pull/32923))

* 부모 레코드가 중복된 자식 레코드와 함께 저장되지 않도록 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32952))

* `Associations::CollectionAssociation#size`와 `Associations::CollectionAssociation#empty?`가 로드된 연관된 ID를 사용하도록 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32617))

* 모든 레코드가 요청한 연관을 가지고 있지 않을 때 다형성 연관의 연관을 미리로드하는 기능을 추가합니다.
    ([Commit](https://github.com/rails/rails/commit/75ef18c67c29b1b51314b6c8a963cee53394080b))

* `ActiveRecord::Relation`에 `touch_all` 메서드를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/31513))

* `ActiveRecord::Base.base_class?` 예측자를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32417))

* `ActiveRecord::Store.store_accessor`에 사용자 정의 접두사/접미사 옵션을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32306))

* `ActiveRecord::Base.find_or_create_by`/`!`에서 SELECT/INSERT 경합 조건을 처리하기 위해 `ActiveRecord::Base.create_or_find_by`/`!`를 추가합니다. 이는 데이터베이스의 고유 제약 조건을 활용합니다.
    ([Pull Request](https://github.com/rails/rails/pull/31989))

* 단일 값 플럭스를 위한 약식인 `Relation#pick`을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/31941))

Active Storage
--------------

자세한 변경 사항은 [Changelog][active-storage]를 참조하십시오.

### 제거 사항

### 폐지 사항

* `config.active_storage.queue`를 `config.active_storage.queues.analysis`와 `config.active_storage.queues.purge`로 대체하기 위해 폐지합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34838))

* `ActiveStorage::Downloading`을 `ActiveStorage::Blob#open`으로 대체하기 위해 폐지합니다.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

* 이미지 변형을 생성하기 위해 `mini_magick`을 직접 사용하는 것을 `image_processing`을 선호하도록 폐지합니다.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

* Active Storage의 ImageProcessing 변환기에서 `:combine_options`를 대체 없이 폐지합니다.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

### 주요 변경 사항

* BMP 이미지 변형 생성을 지원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/36051))

* TIFF 이미지 변형 생성을 지원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34824))

* 프로그레시브 JPEG 이미지 변형 생성을 지원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34455))
*   `ActiveStorage.routes_prefix`를 추가하여 Active Storage에서 생성된 라우트를 구성할 수 있습니다.
    ([Pull Request](https://github.com/rails/rails/pull/33883))

*   디스크 서비스에서 요청한 파일이 없을 때 `ActiveStorage::DiskController#show`에서 404 Not Found 응답을 생성합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   `ActiveStorage::Blob#download` 및 `ActiveStorage::Blob#open`에서 요청한 파일이 없을 때 `ActiveStorage::FileNotFoundError`를 발생시킵니다.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   Active Storage 예외가 상속하는 일반적인 `ActiveStorage::Error` 클래스를 추가합니다.
    ([Commit](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))

*   레코드에 할당된 업로드된 파일을 즉시 저장하는 대신 레코드가 저장될 때 저장소에 유지합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33303))

*   첨부 파일 컬렉션에 할당할 때 기존 파일을 추가하는 대신 교체할 수 있는 옵션을 추가합니다 (`@user.update!(images: [ ... ])`). 이 동작을 제어하기 위해 `config.active_storage.replace_on_assign_to_many`를 사용합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33303),
     [Pull Request](https://github.com/rails/rails/pull/36716))

*   기존의 Active Record 반사 메커니즘을 사용하여 정의된 첨부 파일을 반영할 수 있는 기능을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33018))

*   `ActiveStorage::Blob#open`을 추가하여 블롭을 디스크의 임시 파일로 다운로드하고 임시 파일을 반환합니다.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Google Cloud Storage에서 스트리밍 다운로드를 지원합니다. `google-cloud-storage` 젬의 1.11+ 버전이 필요합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32788))

*   Active Storage 변형에 `mini_magick`을 직접 사용하는 대신 `image_processing` 젬을 사용합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32471))

Active Model
------------

자세한 변경 사항은 [Changelog][active-model]를 참조하세요.

### 제거됨

### 폐기됨

### 주요 변경 사항

*   `ActiveModel::Errors#full_message`의 형식을 사용자 정의할 수 있는 구성 옵션을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32956))

*   `has_secure_password`에 대한 속성 이름을 구성할 수 있는 지원을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/26764))

*   `ActiveModel::Errors`에 `#slice!` 메서드를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34489))

*   특정 오류의 존재 여부를 확인하기 위해 `ActiveModel::Errors#of_kind?`를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34866))

*   타임스탬프에 대한 `ActiveModel::Serializers::JSON#as_json` 메서드를 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/31503))

*   Active Record를 제외한 경우에도 타입 캐스트 이전의 값을 사용하여 numericality 유효성 검사기를 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33654))

*   `BigDecimal` 및 `Float`의 numericality 동등성 유효성 검사를 수정하여 유효성 검사의 양쪽 끝에서 `BigDecimal`로 캐스트합니다.
    ([Pull Request](https://github.com/rails/rails/pull/32852))

*   다중 매개변수 시간 해시를 캐스팅할 때 연도 값을 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34990))

*   부울 속성의 거짓인 부울 심볼을 false로 캐스팅합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35794))

*   `ActiveModel::Type::Date`에 대한 `value_from_multiparameter_assignment`에서 매개변수를 변환하는 동안 올바른 날짜를 반환합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29651))

*   에러 번역을 가져올 때 `:errors` 네임스페이스보다 먼저 부모 로케일로 되돌아가도록 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/35424))

Active Support
--------------

자세한 변경 사항은 [Changelog][active-support]를 참조하세요.

### 제거됨

*   `Inflections`에서 폐기된 `#acronym_regex` 메서드를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/0ce67d3cd6d1b7b9576b07fecae3dd5b422a5689))

*   `Module#reachable?` 메서드를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/6eb1d56a333fd2015610d31793ed6281acd66551))

*   대체 없이 `` Kernel#` ``를 제거합니다.
    ([Pull Request](https://github.com/rails/rails/pull/31253))

### 폐기됨

*   `String#first` 및 `String#last`에 대한 음수 정수 인수 사용을 폐기합니다.
    ([Pull Request](https://github.com/rails/rails/pull/33058))

*   `ActiveSupport::Multibyte::Unicode#downcase/upcase/swapcase`를 `String#downcase/upcase/swapcase` 대신 폐기합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34123))
* `ActiveSupport::Multibyte::Unicode#normalize` 및 `ActiveSupport::Multibyte::Chars#normalize`을 `String#unicode_normalize`를 사용하여 폐기합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/34202))

* `ActiveSupport::Multibyte::Chars.consumes?`을 `String#is_utf8?`을 사용하여 폐기합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/34215))

* `ActiveSupport::Multibyte::Unicode#pack_graphemes(array)` 및 `ActiveSupport::Multibyte::Unicode#unpack_graphemes(string)`을 각각 `array.flatten.pack("U*")` 및 `string.scan(/\X/).map(&:codepoints)`로 대체하여 폐기합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/34254))

### 주목할만한 변경 사항

* 병렬 테스트를 지원합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/31900))

* `String#strip_heredoc`가 문자열의 동결 상태를 보존하도록 합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/32037))

* 멀티바이트 문자 또는 그래프 클러스터를 깨지 않고 문자열을 최대 바이트 크기로 자르기 위해 `String#truncate_bytes`를 추가합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/27319))

* `delegate` 메서드에 `private` 옵션을 추가하여 비공개 메서드로 위임할 수 있도록 합니다. 이 옵션은 `true/false` 값을 받습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/31944))

* `ActiveSupport::Inflector#ordinal` 및 `ActiveSupport::Inflector#ordinalize`에 대한 I18n을 통한 번역 지원을 추가합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/32168))

* `Date`, `DateTime`, `Time` 및 `TimeWithZone`에 `before?` 및 `after?` 메서드를 추가합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/32185))

* 혼합된 유니코드/이스케이프된 문자 입력에서 `URI.unescape`가 실패하는 버그를 수정합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/32183))

* 압축이 활성화되었을 때 `ActiveSupport::Cache`가 저장 크기를 대량으로 증가시키는 버그를 수정합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/32539))

* Redis 캐시 스토어에서 `delete_matched`가 더 이상 Redis 서버를 차단하지 않습니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/32614))

* `ActiveSupport::TimeZone.all`이 `ActiveSupport::TimeZone::MAPPING`에서 정의된 모든 시간대에 대해 tzinfo 데이터가 누락되었을 때 실패하는 버그를 수정합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/32613))

* `Enumerable#index_with`를 추가하여 열거 가능한 항목에서 블록에서 반환되는 값 또는 기본 인수의 값을 사용하여 해시를 생성할 수 있도록 합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/32523))

* `Range#===` 및 `Range#cover?` 메서드가 `Range` 인수와 함께 작동하도록 합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/32938))

* RedisCacheStore의 `increment/decrement` 작업에서 키 만료를 지원합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/33254))

* 로그 구독자 이벤트에 CPU 시간, 유휴 시간 및 할당 기능을 추가합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/33449))

* Active Support 알림 시스템에 이벤트 객체 지원을 추가합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/33451))

* `ActiveSupport::Cache#fetch`에 `nil` 항목을 캐시하지 않도록 새로운 `skip_nil` 옵션을 도입하여 지원합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/25437))

* 블록에서 true 값을 반환하는 요소를 제거하고 반환하는 `Array#extract!` 메서드를 추가합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/33137))

* HTML 안전한 문자열을 슬라이싱한 후에도 HTML 안전한 상태를 유지합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/33808))

* 로깅을 통해 상수 자동로드를 추적할 수 있도록 지원합니다. ([커밋](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

* `unfreeze_time`을 `travel_back`의 별칭으로 정의합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/33813))

* `ActiveSupport::TaggedLogging.new`를 인수로 받은 로거 인스턴스를 변경하는 대신 새로운 로거 인스턴스를 반환하도록 변경합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/27792))

* `#delete_prefix`, `#delete_suffix` 및 `#unicode_normalize` 메서드를 HTML 안전하지 않은 메서드로 처리합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/33990))

* `ActiveSupport::HashWithIndifferentAccess`의 `#without`에서 심볼 인수로 실패하는 버그를 수정합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/34012))

* `Module#parent`, `Module#parents` 및 `Module#parent_name`을 각각 `module_parent`, `module_parents`, `module_parent_name`으로 이름을 변경합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/34051))

* `ActiveSupport::ParameterFilter`를 추가합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/34039))

* 소수점이 있는 경우 기간이 전체 초로 반올림되는 버그를 수정합니다. ([풀 리퀘스트](https://github.com/rails/rails/pull/34135))
* `ActiveSupport::HashWithIndifferentAccess`에서 `#to_options`를 `#symbolize_keys`의 별칭으로 만듭니다. ([Pull Request](https://github.com/rails/rails/pull/34360))

* Concern에 동일한 블록이 여러 번 포함되어도 더 이상 예외를 발생시키지 않습니다. ([Pull Request](https://github.com/rails/rails/pull/34553))

* `ActiveSupport::CacheStore#fetch_multi`에 전달된 키 순서를 보존합니다. ([Pull Request](https://github.com/rails/rails/pull/34700))

* `String#safe_constantize`를 수정하여 잘못된 대소문자 상수 참조에 대해 `LoadError`를 발생시키지 않습니다. ([Pull Request](https://github.com/rails/rails/pull/34892))

* `Hash#deep_transform_values`와 `Hash#deep_transform_values!`를 추가합니다. ([Commit](https://github.com/rails/rails/commit/b8dc06b8fdc16874160f61dcf58743fcc10e57db))

* `ActiveSupport::HashWithIndifferentAccess#assoc`를 추가합니다. ([Pull Request](https://github.com/rails/rails/pull/35080))

* `CurrentAttributes`에 `before_reset` 콜백을 추가하고 `after_reset`을 `resets`의 별칭으로 정의합니다. ([Pull Request](https://github.com/rails/rails/pull/35063))

* `ActiveSupport::Notifications.unsubscribe`를 수정하여 정규식이나 다중 패턴 구독자를 올바르게 처리합니다. ([Pull Request](https://github.com/rails/rails/pull/32861))

* Zeitwerk를 사용한 새로운 자동로딩 메커니즘을 추가합니다. ([Commit](https://github.com/rails/rails/commit/e53430fa9af239e21e11548499d814f540d421e5))

* `Array#including`과 `Enumerable#including`을 추가하여 컬렉션을 편리하게 확장합니다. ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

* `Array#without`와 `Enumerable#without`를 `Array#excluding`과 `Enumerable#excluding`으로 이름을 변경합니다. 이전 메서드 이름은 별칭으로 유지됩니다. ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

* `transliterate`와 `parameterize`에 `locale`을 제공하는 기능을 추가합니다. ([Pull Request](https://github.com/rails/rails/pull/35571))

* `Time#advance`를 수정하여 1001-03-07 이전의 날짜와 작동하도록 합니다. ([Pull Request](https://github.com/rails/rails/pull/35659))

* `ActiveSupport::Notifications::Instrumenter#instrument`를 업데이트하여 블록을 전달하지 않도록 허용합니다. ([Pull Request](https://github.com/rails/rails/pull/35705))

* 하위 클래스 추적기에서 알 수 없는 하위 클래스가 가비지 수집될 수 있도록 약한 참조를 사용합니다. ([Pull Request](https://github.com/rails/rails/pull/31442))

* `with_info_handler` 메서드를 사용하여 테스트 메서드를 호출하여 minitest-hooks 플러그인이 작동하도록 합니다. ([Commit](https://github.com/rails/rails/commit/758ba117a008b6ea2d3b92c53b6a7a8d7ccbca69))

* `ActiveSupport::SafeBuffer#*`에서 `html_safe?` 상태를 보존합니다. ([Pull Request](https://github.com/rails/rails/pull/36012))

Active Job
----------

자세한 변경 사항은 [Changelog][active-job]를 참조하십시오.

### 제거

* Qu gem의 지원을 제거합니다. ([Pull Request](https://github.com/rails/rails/pull/32300))

### 사용 중지

### 주목할만한 변경 사항

* Active Job 인수에 대한 사용자 정의 직렬화기 지원을 추가합니다. ([Pull Request](https://github.com/rails/rails/pull/30941))

* Active Job을 enqueued된 시간대에서 실행할 수 있도록 지원을 추가합니다. ([Pull Request](https://github.com/rails/rails/pull/32085))

* `retry_on`/`discard_on`에 여러 예외를 전달할 수 있도록 합니다. ([Commit](https://github.com/rails/rails/commit/3110caecbebdad7300daaf26bfdff39efda99e25))

* 블록 없이 `assert_enqueued_with`와 `assert_enqueued_email_with`를 호출할 수 있도록 합니다. ([Pull Request](https://github.com/rails/rails/pull/33258))

* `enqueue`와 `enqueue_at`의 알림을 `after_enqueue` 콜백 대신 `around_enqueue` 콜백으로 감싸도록 변경합니다. ([Pull Request](https://github.com/rails/rails/pull/33171))

* 블록 없이 `perform_enqueued_jobs`를 호출할 수 있도록 합니다. ([Pull Request](https://github.com/rails/rails/pull/33626))

* 블록 없이 `assert_performed_with`를 호출할 수 있도록 합니다. ([Pull Request](https://github.com/rails/rails/pull/33635))

* 작업 단언 도우미에 `:queue` 옵션을 추가합니다. ([Pull Request](https://github.com/rails/rails/pull/33635))

* Active Job 재시도 및 폐기 주변에 훅을 추가합니다. ([Pull Request](https://github.com/rails/rails/pull/33751))

* 작업 수행 시 인수의 하위 집합을 테스트하기 위한 방법을 추가합니다. ([Pull Request](https://github.com/rails/rails/pull/33995))

* Active Job 테스트 도우미에서 역직렬화된 인수를 작업에 포함합니다. ([Pull Request](https://github.com/rails/rails/pull/34204))

* Active Job 단언 도우미가 `only` 키워드에 대해 Proc를 허용하도록 합니다. ([Pull Request](https://github.com/rails/rails/pull/34339))

* 단언 도우미에서 작업 인수의 마이크로초와 나노초를 제거합니다. ([Pull Request](https://github.com/rails/rails/pull/35713))

Ruby on Rails 가이드
--------------------

자세한 변경 사항은 [Changelog][guides]를 참조하십시오.
### 주목할만한 변경 사항

*   Active Record 가이드에 여러 개의 데이터베이스 추가.
    ([Pull Request](https://github.com/rails/rails/pull/36389))

*   상수 자동로딩 문제 해결에 대한 문제 해결 섹션 추가.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Action Mailbox Basics 가이드 추가.
    ([Pull Request](https://github.com/rails/rails/pull/34812))

*   Action Text 개요 가이드 추가.
    ([Pull Request](https://github.com/rails/rails/pull/34878))

크레딧
-------

Rails를 안정적이고 견고한 프레임워크로 만들기 위해 많은 시간을 투자한 많은 사람들에게
[Rails 기여자 전체 목록](https://contributors.rubyonrails.org/)을 참조하세요.
그들 모두에게 경의를 표합니다.

[railties]:       https://github.com/rails/rails/blob/6-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-0-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-0-stable/activesupport/CHANGELOG.md
