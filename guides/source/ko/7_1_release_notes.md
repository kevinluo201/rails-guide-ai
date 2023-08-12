**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 82080185bf1d0c30f22fa131b42e4187
Ruby on Rails 7.1 릴리스 노트
===============================

Rails 7.1의 주요 기능:

--------------------------------------------------------------------------------

Rails 7.1으로 업그레이드
----------------------

기존 애플리케이션을 업그레이드하는 경우, 업그레이드하기 전에 좋은 테스트 커버리지를 갖는 것이 좋습니다. 또한, Rails 7.0으로 먼저 업그레이드하고 애플리케이션이 예상대로 실행되는지 확인한 후에 Rails 7.1로 업데이트를 시도해야 합니다. 업그레이드할 때 주의해야 할 사항은 [Ruby on Rails 업그레이드](upgrading_ruby_on_rails.html#upgrading-from-rails-7-0-to-rails-7-1) 가이드에서 확인할 수 있습니다.

주요 기능
--------------

Railties
--------

자세한 변경 사항은 [변경 로그][railties]를 참조하십시오.

### 제거

### 폐기 예정

### 주목할만한 변경 사항

Action Cable
------------

자세한 변경 사항은 [변경 로그][action-cable]를 참조하십시오.

### 제거

### 폐기 예정

### 주목할만한 변경 사항

Action Pack
-----------

자세한 변경 사항은 [변경 로그][action-pack]를 참조하십시오.

### 제거

*   `Request#content_type`에서 폐기된 동작 제거

*   `config.action_dispatch.trusted_proxies`에 단일 값을 할당하는 폐기된 기능 제거

*   시스템 테스트를 위한 `poltergeist` 및 `webkit` (capybara-webkit) 드라이버 등록 폐기

### 폐기 예정

*   `config.action_dispatch.return_only_request_media_type_on_content_type` 폐기

*   `AbstractController::Helpers::MissingHelperError` 폐기

*   `ActionDispatch::IllegalStateError` 폐기

### 주목할만한 변경 사항

Action View
-----------

자세한 변경 사항은 [변경 로그][action-view]를 참조하십시오.

### 제거

*   `ActionView::Path` 상수 폐기

*   부분 뷰에 인스턴스 변수를 로컬로 전달하는 폐기된 지원 폐기

### 폐기 예정

### 주목할만한 변경 사항

Action Mailer
-------------

자세한 변경 사항은 [변경 로그][action-mailer]를 참조하십시오.

### 제거

### 폐기 예정

### 주목할만한 변경 사항

Active Record
-------------

자세한 변경 사항은 [변경 로그][active-record]를 참조하십시오.

### 제거

*   `ActiveRecord.legacy_connection_handling` 지원 폐기

*   `ActiveRecord::Base` 구성 접근자 폐기

*   `configs_for`에서 `:include_replicas` 지원 폐기. 대신 `:include_hidden` 사용.

*   `config.active_record.partial_writes` 폐기

*   `Tasks::DatabaseTasks.schema_file_type` 폐기

### 폐기 예정

### 주목할만한 변경 사항

Active Storage
--------------

자세한 변경 사항은 [변경 로그][active-storage]를 참조하십시오.

### 제거

*   Active Storage 구성에서 잘못된 기본 콘텐츠 유형 폐기

*   `ActiveStorage::Current#host` 및 `ActiveStorage::Current#host=` 메서드 폐기

*   첨부 파일 컬렉션에 할당할 때 폐기된 동작 제거. 컬렉션에 추가하지 않고 대신 컬렉션을 대체합니다.

*   첨부 파일 연관 관계에서 `purge` 및 `purge_later` 메서드 폐기

### 폐기 예정

### 주목할만한 변경 사항

Active Model
------------

자세한 변경 사항은 [변경 로그][active-model]를 참조하십시오.

### 제거

### 폐기 예정

### 주목할만한 변경 사항

Active Support
--------------

자세한 변경 사항은 [변경 로그][active-support]를 참조하십시오.

### 제거

*   `Enumerable#sum`의 재정의 폐기

*   `ActiveSupport::PerThreadRegistry` 폐기

*   `Array`, `Range`, `Date`, `DateTime`, `Time`, `BigDecimal`, `Float`, `Integer`에서 `#to_s`에 형식을 전달하는 폐기된 옵션 제거

*   `ActiveSupport::TimeWithZone.name`의 재정의 폐기

*   `active_support/core_ext/uri` 파일 폐기

*   `active_support/core_ext/range/include_time_with_zone` 파일 폐기

*   `ActiveSupport::SafeBuffer`에 의한 객체를 `String`으로 암묵적 변환 폐기

*   `Digest::UUID`에서 정의된 상수가 아닌 네임스페이스 ID를 제공할 때 잘못된 RFC 4122 UUID를 생성하는 폐기된 지원 폐기

### 폐기 예정

*   `config.active_support.disable_to_s_conversion` 폐기

*   `config.active_support.remove_deprecated_time_with_zone_name` 폐기

*   `config.active_support.use_rfc4122_namespaced_uuids` 폐기

### 주목할만한 변경 사항

Active Job
----------

자세한 변경 사항은 [변경 로그][active-job]를 참조하십시오.

### 제거

### 폐기 예정

### 주목할만한 변경 사항

Action Text
----------

자세한 변경 사항은 [변경 로그][action-text]를 참조하십시오.

### 제거

### 폐기 예정

### 주목할만한 변경 사항

Action Mailbox
----------

자세한 변경 사항은 [변경 로그][action-mailbox]를 참조하십시오.

### 제거

### 폐기 예정

### 주목할만한 변경 사항

Ruby on Rails 가이드
--------------------

자세한 변경 사항은 [변경 로그][guides]를 참조하십시오.

### 주목할만한 변경 사항

크레딧
-------

Rails에 많은 시간을 투자한 많은 사람들에게 감사드립니다. Rails를 안정적이고 견고한 프레임워크로 만들어준 모든 분들에게 경의를 표합니다.

[railties]:       https://github.com/rails/rails/blob/main/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/main/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/main/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/main/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/main/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/main/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/main/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/main/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/main/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/main/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/main/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/main/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/main/actionmailbox/CHANGELOG.md
