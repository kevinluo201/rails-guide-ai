**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 1d652e6ccda9c901ca3f6a003c95f83e
Ruby on Rails 6.1 릴리스 노트
===============================

Rails 6.1의 주요 기능:

* 데이터베이스별 연결 전환
* 수평 샤딩
* 엄격한 로딩 연관 관계
* 위임된 타입
* 연관 관계 비동기 삭제

이 릴리스 노트는 주요 변경 사항만 다룹니다. 다양한 버그 수정 및 변경 사항에 대해서는 변경 로그를 참조하거나 GitHub의 주요 Rails 저장소의 [커밋 목록](https://github.com/rails/rails/commits/6-1-stable)을 확인하십시오.

--------------------------------------------------------------------------------

Rails 6.1로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드하는 경우, 업그레이드하기 전에 좋은 테스트 커버리지를 갖는 것이 좋습니다. 또한, Rails 6.0으로 먼저 업그레이드하고 애플리케이션이 예상대로 작동하는지 확인한 후에 Rails 6.1로 업데이트를 시도하십시오. 업그레이드할 때 주의해야 할 사항은 [Ruby on Rails 업그레이드](upgrading_ruby_on_rails.html#upgrading-from-rails-6-0-to-rails-6-1) 가이드에서 확인할 수 있습니다.

주요 기능
--------------

### 데이터베이스별 연결 전환

Rails 6.1은 [데이터베이스별 연결 전환 기능](https://github.com/rails/rails/pull/40370)을 제공합니다. 6.0에서 `reading` 역할로 전환하면 모든 데이터베이스 연결도 읽기 전용 역할로 전환되었습니다. 이제 6.1에서는 설정에서 `legacy_connection_handling`을 `false`로 설정하면 해당 추상 클래스에 대해 `connected_to`를 호출하여 단일 데이터베이스의 연결을 전환할 수 있도록 합니다.

### 수평 샤딩

Rails 6.0은 데이터베이스를 기능적으로 분할(다중 파티션, 다른 스키마)할 수 있지만 수평 샤딩(동일한 스키마, 다중 파티션)을 지원하지 못했습니다. Rails는 Active Record의 모델에서 클래스당 한 번의 연결만 가질 수 있기 때문에 수평 샤딩을 지원할 수 없었습니다. 이제 이 문제가 해결되어 Rails에서 [수평 샤딩](https://github.com/rails/rails/pull/38531)이 가능합니다.

### 엄격한 로딩 연관 관계

[엄격한 로딩 연관 관계](https://github.com/rails/rails/pull/37400)를 사용하면 모든 연관 관계가 이른바 N+1 문제가 발생하기 전에 이른 시기에 로드되도록 보장할 수 있습니다.

### 위임된 타입

[위임된 타입](https://github.com/rails/rails/pull/39341)은 단일 테이블 상속의 대안입니다. 이를 통해 클래스 계층 구조를 나타낼 수 있으며, 슈퍼클래스는 자체 테이블로 표현되는 구체적인 클래스가 될 수 있습니다. 각 하위 클래스는 추가 속성을 위한 자체 테이블을 갖습니다.

### 연관 관계 비동기 삭제

[연관 관계 비동기 삭제](https://github.com/rails/rails/pull/40157)는 애플리케이션이 백그라운드 작업에서 연관 관계를 `destroy`할 수 있는 기능을 추가합니다. 이를 통해 데이터를 삭제할 때 타임아웃 및 성능 문제를 피할 수 있습니다.

Railties
--------

자세한 변경 사항은 [변경 로그][railties]를 참조하십시오.

### 제거 사항

*   폐기된 `rake notes` 작업 제거.

*   `rails dbconsole` 명령에서 폐기된 `connection` 옵션 제거.

*   `rails notes`에서 `SOURCE_ANNOTATION_DIRECTORIES` 환경 변수 지원 제거.

*   `rails server` 명령에서 폐기된 `server` 인수 제거.

*   서버 IP를 지정하기 위해 `HOST` 환경 변수 사용을 폐기.

*   폐기된 `rake dev:cache` 작업 제거.

*   폐기된 `rake routes` 작업 제거.

*   폐기된 `rake initializers` 작업 제거.

### 폐기 사항

### 주요 변경 사항

Action Cable
------------

자세한 변경 사항은 [변경 로그][action-cable]를 참조하십시오.

### 제거 사항

### 폐기 사항

### 주요 변경 사항

Action Pack
-----------

자세한 변경 사항은 [변경 로그][action-pack]를 참조하십시오.

### 제거 사항

*   폐기된 `ActionDispatch::Http::ParameterFilter` 제거.

*   컨트롤러 수준에서 폐기된 `force_ssl` 제거.

### 폐기 사항

*   `config.action_dispatch.return_only_media_type_on_content_type` 폐기.

### 주요 변경 사항

*   `ActionDispatch::Response#content_type`을 전체 Content-Type 헤더를 반환하도록 변경.

Action View
-----------

자세한 변경 사항은 [변경 로그][action-view]를 참조하십시오.

### 제거 사항

*   `ActionView::Template::Handlers::ERB`에서 폐기된 `escape_whitelist` 제거.

*   `ActionView::Resolver`에서 폐기된 `find_all_anywhere` 제거.

*   `ActionView::Template::HTML`에서 폐기된 `formats` 제거.

*   `ActionView::Template::RawFile`에서 폐기된 `formats` 제거.

*   `ActionView::Template::Text`에서 폐기된 `formats` 제거.

*   `ActionView::PathSet`에서 폐기된 `find_file` 제거.

*   `ActionView::LookupContext`에서 폐기된 `rendered_format` 제거.

*   `ActionView::ViewPaths`에서 폐기된 `find_file` 제거.

*   `ActionView::Base#initialize`의 첫 번째 인수로 `ActionView::LookupContext`가 아닌 객체를 전달하는 것을 폐기.

*   `ActionView::Base#initialize`에서 폐기된 `format` 인수.

*   `ActionView::Template#refresh` 폐기.

*   `ActionView::Template#original_encoding` 폐기.

*   `ActionView::Template#variants` 폐기.
* `ActionView::Template#formats`를 삭제합니다.

* `ActionView::Template#virtual_path=`를 삭제합니다.

* `ActionView::Template#updated_at`를 삭제합니다.

* `ActionView::Template#initialize`에서 필요한 `updated_at` 인수를 삭제합니다.

* `ActionView::Template.finalize_compiled_template_methods`를 삭제합니다.

* `config.action_view.finalize_compiled_template_methods`를 삭제합니다.

* 블록을 사용하여 `ActionView::ViewPaths#with_fallback`를 호출하는 지원을 삭제합니다.

* `render template:`에 절대 경로를 전달하는 지원을 삭제합니다.

* `render file:`에 상대 경로를 전달하는 지원을 삭제합니다.

* 두 개의 인수를 받지 않는 템플릿 핸들러를 지원하지 않습니다.

* `ActionView::Template::PathResolver`에서 패턴 인수를 삭제합니다.

* 일부 뷰 헬퍼에서 객체에서 비공개 메서드를 호출하는 지원을 삭제합니다.

### 폐기

### 주요 변경 사항

* `ActionView::Base` 하위 클래스가 `#compiled_method_container`를 구현해야 합니다.

* `ActionView::Template#initialize`에서 `locals` 인수가 필요합니다.

* `javascript_include_tag` 및 `stylesheet_link_tag` 자산 도우미는 자산 사전로드에 대한 힌트를 현대적인 브라우저에 제공하는 `Link` 헤더를 생성합니다. 이 기능은 `config.action_view.preload_links_header`를 `false`로 설정하여 비활성화할 수 있습니다.

액션 메일러
-------------

자세한 변경 사항은 [Changelog][action-mailer]를 참조하십시오.

### 삭제

* [Action Mailbox](https://github.com/rails/rails/tree/6-1-stable/actionmailbox)를 선호하는 방식으로 폐기된 `ActionMailer::Base.receive`를 삭제합니다.

### 폐기

### 주요 변경 사항

액티브 레코드
-------------

자세한 변경 사항은 [Changelog][active-record]를 참조하십시오.

### 삭제

* `ActiveRecord::ConnectionAdapters::DatabaseLimits`에서 폐기된 메서드를 삭제합니다.

    `column_name_length`
    `table_name_length`
    `columns_per_table`
    `indexes_per_table`
    `columns_per_multicolumn_index`
    `sql_query_length`
    `joins_per_query`

* `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_multi_insert?`를 삭제합니다.

* `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_foreign_keys_in_create?`를 삭제합니다.

* `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_ranges?`를 삭제합니다.

* `ActiveRecord::Base#update_attributes` 및 `ActiveRecord::Base#update_attributes!`를 삭제합니다.

* `ActiveRecord::ConnectionAdapter::SchemaStatements#assume_migrated_upto_version`에서 `migrations_path` 인수를 삭제합니다.

* `config.active_record.sqlite3.represent_boolean_as_integer`를 삭제합니다.

* `ActiveRecord::DatabaseConfigurations`에서 폐기된 메서드를 삭제합니다.

    `fetch`
    `each`
    `first`
    `values`
    `[]=`

* `ActiveRecord::Result#to_hash` 메서드를 삭제합니다.

* `ActiveRecord::Relation` 메서드에서 안전하지 않은 원시 SQL을 사용하는 지원을 삭제합니다.

### 폐기

* `ActiveRecord::Base.allow_unsafe_raw_sql`을 폐기합니다.

* `connected_to`에서 `database` kwarg를 폐기합니다.

* `legacy_connection_handling`이 false로 설정된 경우 `connection_handlers`를 폐기합니다.

### 주요 변경 사항

* MySQL: 고유성 유효성 검사기는 이제 기본 데이터베이스 콜레이션을 준수하며, 기본적으로 대소문자를 구분하지 않습니다.

* `relation.create`은 초기화 블록 및 콜백에서 클래스 수준의 쿼리 메서드에 스코프를 더 이상 누출하지 않습니다.

    이전:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => nil
    end
    ```

    이후:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => #<User name: "David", ...>
    end
    ```

* 네임드 스코프 체인은 이제 클래스 수준의 쿼리 메서드에 스코프를 더 이상 누출하지 않습니다.

    ```ruby
    class User < ActiveRecord::Base
      scope :david, -> { User.where(name: "David") }
    end
    ```

    이전:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'John' AND name = 'David'
    ```

    이후:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'David'
    ```

* `where.not`은 이제 NOR 대신 NAND 프리디케이트를 생성합니다.

    이전:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE name != 'Jon' AND role != 'admin'
    ```

    이후:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE NOT (name = 'Jon' AND role = 'admin')
    ```

* 새로운 데이터베이스별 연결 처리를 사용하려면 `legacy_connection_handling`을 false로 변경하고 `connection_handlers`에서 폐기된 접근자를 제거해야 합니다. `connects_to` 및 `connected_to`의 공개 메서드는 변경하지 않아도 됩니다.

액티브 스토리지
--------------

자세한 변경 사항은 [Changelog][active-storage]를 참조하십시오.

### 삭제

* `ActiveStorage::Transformers::ImageProcessing`에 `:combine_options` 작업을 전달하는 지원을 삭제합니다.

* `ActiveStorage::Transformers::MiniMagickTransformer`를 삭제합니다.

* `config.active_storage.queue`를 삭제합니다.

* `ActiveStorage::Downloading`을 삭제합니다.

### 폐기

* `Blob.create_after_upload`을 `Blob.create_and_upload`을 선호하는 방식으로 폐기합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34827))

### 주요 변경 사항

* `Blob.create_and_upload`를 추가하여 새로운 blob을 생성하고 주어진 `io`를 서비스에 업로드합니다.
    ([Pull Request](https://github.com/rails/rails/pull/34827))
* `ActiveStorage::Blob#service_name` 열이 추가되었습니다. 업그레이드 후에 마이그레이션을 실행해야 합니다. `bin/rails app:update`를 실행하여 해당 마이그레이션을 생성하십시오.

액티브 모델
------------

자세한 변경 사항은 [Changelog][active-model]를 참조하십시오.

### 삭제

### 폐기

### 주요 변경 사항

* 액티브 모델의 오류는 이제 모델에서 발생하는 오류를 더 쉽게 처리하고 상호 작용할 수 있는 인터페이스를 가진 객체입니다.
    [이 기능](https://github.com/rails/rails/pull/32313)은 쿼리 인터페이스를 포함하며, 더 정확한 테스트와 오류 세부 정보에 대한 액세스를 가능하게 합니다.
액티브 서포트
--------------

자세한 변경 사항은 [변경 로그][active-support]를 참조하십시오.

### 제거

*   `config.i18n.fallbacks`가 비어 있을 때 `I18n.default_locale`로의 폴백 제거.

*   `LoggerSilence` 상수 제거.

*   `ActiveSupport::LoggerThreadSafeLevel#after_initialize` 제거.

*   `Module#parent_name`, `Module#parent` 및 `Module#parents` 제거.

*   `active_support/core_ext/module/reachable` 파일 제거.

*   `active_support/core_ext/numeric/inquiry` 파일 제거.

*   `active_support/core_ext/array/prepend_and_append` 파일 제거.

*   `active_support/core_ext/hash/compact` 파일 제거.

*   `active_support/core_ext/hash/transform_values` 파일 제거.

*   `active_support/core_ext/range/include_range` 파일 제거.

*   `ActiveSupport::Multibyte::Chars#consumes?` 및 `ActiveSupport::Multibyte::Chars#normalize` 제거.

*   `ActiveSupport::Multibyte::Unicode.pack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.unpack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.normalize`,
    `ActiveSupport::Multibyte::Unicode.downcase`,
    `ActiveSupport::Multibyte::Unicode.upcase` 및 `ActiveSupport::Multibyte::Unicode.swapcase` 제거.

*   `ActiveSupport::Notifications::Instrumenter#end=` 제거.

### 폐기

*   `ActiveSupport::Multibyte::Unicode.default_normalization_form` 폐기.

### 주목할만한 변경 사항

액티브 잡
----------

자세한 변경 사항은 [변경 로그][active-job]를 참조하십시오.

### 제거

### 폐기

*   `config.active_job.return_false_on_aborted_enqueue` 폐기.

### 주목할만한 변경 사항

*   작업을 큐에 넣는 것이 중단되면 `false`를 반환합니다.

액션 텍스트
----------

자세한 변경 사항은 [변경 로그][action-text]를 참조하십시오.

### 제거

### 폐기

### 주목할만한 변경 사항

*   리치 텍스트 속성의 이름 뒤에 `?`를 추가하여 리치 텍스트 콘텐츠의 존재 여부를 확인하는 메서드 추가.
    ([Pull Request](https://github.com/rails/rails/pull/37951))

*   주어진 HTML 콘텐츠로 트릭스 편집기를 찾고 채우는 `fill_in_rich_text_area` 시스템 테스트 케이스 도우미 추가.
    ([Pull Request](https://github.com/rails/rails/pull/35885))

*   데이터베이스 픽스처에서 `<action-text-attachment>` 요소를 생성하기 위한 `ActionText::FixtureSet.attachment` 추가.
    ([Pull Request](https://github.com/rails/rails/pull/40289))

액션 메일박스
----------

자세한 변경 사항은 [변경 로그][action-mailbox]를 참조하십시오.

### 제거

### 폐기

*   `Rails.application.credentials.action_mailbox.api_key` 및 `MAILGUN_INGRESS_API_KEY`를 `Rails.application.credentials.action_mailbox.signing_key` 및 `MAILGUN_INGRESS_SIGNING_KEY`로 대체하기 위해 `Rails.application.credentials.action_mailbox.api_key` 및 `MAILGUN_INGRESS_API_KEY`를 폐기.

### 주목할만한 변경 사항

루비 온 레일스 가이드
--------------------

자세한 변경 사항은 [변경 로그][guides]를 참조하십시오.

### 주목할만한 변경 사항

크레딧
-------

[Rails에 기여한 전체 기여자 목록](https://contributors.rubyonrails.org/)을 확인하여 Rails를 안정적이고 견고한 프레임워크로 만드는 데 많은 시간을 투자한 많은 사람들에게 감사의 인사를 전합니다.

[railties]:       https://github.com/rails/rails/blob/6-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-1-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/6-1-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-1-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-1-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-1-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/6-1-stable/actionmailbox/CHANGELOG.md
