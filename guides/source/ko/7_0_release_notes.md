**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e9aa14ccbfd8f02fea6c1b061215332c
루비 온 레일즈 7.0 릴리스 노트
===============================

Rails 7.0의 주요 기능:

* Ruby 2.7.0+가 필요하며, Ruby 3.0+가 선호됩니다.

--------------------------------------------------------------------------------

Rails 7.0으로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드하는 경우, 업그레이드하기 전에 좋은 테스트 커버리지를 갖는 것이 좋습니다. 또한, Rails 6.1로 먼저 업그레이드하고 애플리케이션이 예상대로 실행되는지 확인한 후에 Rails 7.0으로 업데이트를 시도해야 합니다. 업그레이드할 때 주의해야 할 사항은 [Ruby on Rails 업그레이드](upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0) 가이드에서 확인할 수 있습니다.

주요 기능
--------------

Railties
--------

자세한 변경 사항은 [변경 로그][railties]를 참조하십시오.

### 제거 사항

* `dbconsole`에서 사용되는 `config`를 제거했습니다.

### 폐기 예정 사항

### 주요 변경 사항

* Sprockets는 이제 선택적 종속성입니다.

    `rails` 젬은 더 이상 `sprockets-rails`에 의존하지 않습니다. 여전히 Sprockets를 사용해야 하는 경우, Gemfile에 `sprockets-rails`를 추가해야 합니다.

    ```
    gem "sprockets-rails"
    ```

Action Cable
------------

자세한 변경 사항은 [변경 로그][action-cable]를 참조하십시오.

### 제거 사항

### 폐기 예정 사항

### 주요 변경 사항

Action Pack
-----------

자세한 변경 사항은 [변경 로그][action-pack]를 참조하십시오.

### 제거 사항

* `ActionDispatch::Response.return_only_media_type_on_content_type`를 제거했습니다.

* `Rails.config.action_dispatch.hosts_response_app`을 제거했습니다.

* `ActionDispatch::SystemTestCase#host!`를 제거했습니다.

* `fixture_path`와 관련하여 `fixture_file_upload`에 상대 경로를 전달하는 것을 폐기했습니다.

### 폐기 예정 사항

### 주요 변경 사항

Action View
-----------

자세한 변경 사항은 [변경 로그][action-view]를 참조하십시오.

### 제거 사항

* `Rails.config.action_view.raise_on_missing_translations`를 제거했습니다.

### 폐기 예정 사항

### 주요 변경 사항

* `button_to`는 URL을 구성하는 데 Active Record 객체가 사용되는 경우 [method]에서 HTTP 동사를 추론합니다.

    ```ruby
    button_to("Do a POST", [:do_post_action, Workshop.find(1)])
    # 이전
    #=>   <input type="hidden" name="_method" value="post" autocomplete="off" />
    # 이후
    #=>   <input type="hidden" name="_method" value="patch" autocomplete="off" />
    ```

Action Mailer
-------------

자세한 변경 사항은 [변경 로그][action-mailer]를 참조하십시오.

### 제거 사항

* `ActionMailer::DeliveryJob` 및 `ActionMailer::Parameterized::DeliveryJob`를 `ActionMailer::MailDeliveryJob`로 대체했습니다.

### 폐기 예정 사항

### 주요 변경 사항

Active Record
-------------

자세한 변경 사항은 [변경 로그][active-record]를 참조하십시오.

### 제거 사항

* `connected_to`에서 `database` 키워드 인수를 제거했습니다.

* `ActiveRecord::Base.allow_unsafe_raw_sql`을 제거했습니다.

* `configs_for` 메서드에서 `:spec_name` 옵션을 제거했습니다.

* Rails 4.2 및 4.1 형식에서 `ActiveRecord::Base` 인스턴스를 YAML로 로드하는 지원을 제거했습니다.

* PostgreSQL 데이터베이스에서 `:interval` 열을 사용할 때 폐기 경고를 제거했습니다.

    이제 interval 열은 문자열 대신 `ActiveSupport::Duration` 객체를 반환합니다.

    이전 동작을 유지하려면 모델에 다음 줄을 추가할 수 있습니다.

    ```ruby
    attribute :column, :string
    ```

* 연결 사양 이름으로 `"primary"`를 사용하여 연결을 해결하는 것을 폐기했습니다.

* `ActiveRecord::Base` 객체를 인용하는 것을 폐기했습니다.

* 데이터베이스 값으로 형변환하는 것을 폐기했습니다.

* `type_cast`에 열을 전달하는 것을 폐기했습니다.

* `DatabaseConfig#config` 메서드를 폐기했습니다.

* 다음과 같은 rake 작업을 폐기했습니다:

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

* 비결정적인 순서로 검색하는 데 `Model.reorder(nil).first`를 사용하는 것을 폐기했습니다.

* `Tasks::DatabaseTasks.schema_up_to_date?`의 `environment` 및 `name` 인수를 폐기했습니다.

* `Tasks::DatabaseTasks.dump_filename`을 폐기했습니다.

* `Tasks::DatabaseTasks.schema_file`을 폐기했습니다.

* `Tasks::DatabaseTasks.spec`을 폐기했습니다.

* `Tasks::DatabaseTasks.current_config`을 폐기했습니다.

* `ActiveRecord::Connection#allowed_index_name_length`를 폐기했습니다.

* `ActiveRecord::Connection#in_clause_length`를 폐기했습니다.

* `ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name`을 폐기했습니다.

* `ActiveRecord::Base.connection_config`를 폐기했습니다.

* `ActiveRecord::Base.arel_attribute`를 폐기했습니다.

* `ActiveRecord::Base.configurations.default_hash`를 폐기했습니다.

* `ActiveRecord::Base.configurations.to_h`를 폐기했습니다.

* `ActiveRecord::Result#map!` 및 `ActiveRecord::Result#collect!`를 폐기했습니다.

* `ActiveRecord::Base#remove_connection`을 폐기했습니다.

### 폐기 예정 사항

* `Tasks::DatabaseTasks.schema_file_type`을 폐기했습니다.

### 주요 변경 사항

* 블록이 예상보다 일찍 반환될 때 트랜잭션을 롤백합니다.

    이 변경 이전에 트랜잭션 블록이 일찍 반환되면 트랜잭션이 커밋되었습니다.

    문제는 트랜잭션 블록 내에서 트랜잭션을 유발하는 시간 초과도 미완료된 트랜잭션을 커밋하게 만들었기 때문에, 이러한 실수를 피하기 위해 트랜잭션 블록이 롤백됩니다.

* 동일한 열에 대한 조건을 병합할 때 이제 두 조건을 모두 유지하지 않고 후행 조건으로 일관되게 대체합니다.

    ```ruby
    # Rails 6.1 (IN 절은 병합 대상 측의 동등 조건으로 대체됨)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    # Rails 6.1 (두 충돌 조건이 모두 존재, 폐기 예정)
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => []
    # Rails 6.1에서 Rails 7.0의 동작으로 마이그레이션하기 위한 rewhere
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob), rewhere: true) # => [bob]
    # Rails 7.0 (IN 절과 동일한 동작, 병합 대상 조건은 일관되게 대체됨)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => [bob]
    ```
액티브 스토리지
--------------

자세한 변경 사항은 [변경 로그][active-storage]를 참조하십시오.

### 제거 사항

### 폐기 예정 사항

### 주요 변경 사항

액티브 모델
------------

자세한 변경 사항은 [변경 로그][active-model]를 참조하십시오.

### 제거 사항

*   해시로 `ActiveModel::Errors` 인스턴스를 열거하는 것이 폐기 예정되었습니다.

*   폐기 예정인 `ActiveModel::Errors#to_h`를 제거하십시오.

*   폐기 예정인 `ActiveModel::Errors#slice!`를 제거하십시오.

*   폐기 예정인 `ActiveModel::Errors#values`를 제거하십시오.

*   폐기 예정인 `ActiveModel::Errors#keys`를 제거하십시오.

*   폐기 예정인 `ActiveModel::Errors#to_xml`를 제거하십시오.

*   `ActiveModel::Errors#messages`에 오류를 연결하는 지원을 폐기 예정입니다.

*   `ActiveModel::Errors#messages`에서 오류를 `clear`하는 지원을 폐기 예정입니다.

*   `ActiveModel::Errors#messages`에서 오류를 `delete`하는 지원을 폐기 예정입니다.

*   `ActiveModel::Errors#messages`에서 `[]=`를 사용하는 지원을 제거하십시오.

*   Rails 5.x 오류 형식을 Marshal 및 YAML로드하는 지원을 제거하십시오.

*   Rails 5.x `ActiveModel::AttributeSet` 형식을 Marshal로드하는 지원을 제거하십시오.

### 폐기 예정 사항

### 주요 변경 사항

액티브 서포트
--------------

자세한 변경 사항은 [변경 로그][active-support]를 참조하십시오.

### 제거 사항

*   폐기 예정인 `config.active_support.use_sha1_digests`를 제거하십시오.

*   폐기 예정인 `URI.parser`를 제거하십시오.

*   날짜 시간 범위에 값이 포함되어 있는지 확인하기 위해 `Range#include?`을 사용하는 지원이 폐기 예정되었습니다.

*   폐기 예정인 `ActiveSupport::Multibyte::Unicode.default_normalization_form`을 제거하십시오.

### 폐기 예정 사항

*   `Array`, `Range`, `Date`, `DateTime`, `Time`, `BigDecimal`, `Float`, `Integer`에서 `#to_s`에 형식을 전달하는 것을 `#to_fs`를 선호하는 것으로 폐기 예정입니다.

    이 폐기 예정은 Rails 애플리케이션이 일부 유형의 객체의 보간을 더 빠르게 만드는 Ruby 3.1 [최적화](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44)를 활용할 수 있도록하기 위한 것입니다.

    새로운 애플리케이션에서는 해당 클래스에 대해 `#to_s` 메서드가 재정의되지 않습니다. 기존 애플리케이션에서는 `config.active_support.disable_to_s_conversion`을 사용할 수 있습니다.

### 주요 변경 사항

액티브 잡
----------

자세한 변경 사항은 [변경 로그][active-job]를 참조하십시오.

### 제거 사항

*   이전 콜백이 `throw :abort`로 중단되었을 때 `after_enqueue`/`after_perform` 콜백을 중단하지 않았던 폐기 예정 동작을 제거하십시오.

*   폐기 예정인 `:return_false_on_aborted_enqueue` 옵션을 제거하십시오.

### 폐기 예정 사항

*   `Rails.config.active_job.skip_after_callbacks_if_terminated`을 폐기 예정입니다.

### 주요 변경 사항

액션 텍스트
----------

자세한 변경 사항은 [변경 로그][action-text]를 참조하십시오.

### 제거 사항

### 폐기 예정 사항

### 주요 변경 사항

액션 메일박스
----------

자세한 변경 사항은 [변경 로그][action-mailbox]를 참조하십시오.

### 제거 사항

*   폐기 예정인 `Rails.application.credentials.action_mailbox.mailgun_api_key`를 제거하십시오.

*   폐기 예정인 환경 변수 `MAILGUN_INGRESS_API_KEY`를 제거하십시오.

### 폐기 예정 사항

### 주요 변경 사항

Ruby on Rails 가이드
--------------------

자세한 변경 사항은 [변경 로그][guides]를 참조하십시오.

### 주요 변경 사항

크레딧
-------

Rails에 많은 시간을 투자한 많은 사람들에게 감사드립니다. Rails를 안정적이고 견고한 프레임워크로 만들어준 모든 사람들에게 경의를 표합니다.

[railties]:       https://github.com/rails/rails/blob/7-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/7-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/7-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/7-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/7-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/7-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/7-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/7-0-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/7-0-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/7-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/7-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/7-0-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/7-0-stable/actionmailbox/CHANGELOG.md
