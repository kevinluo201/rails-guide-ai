**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c7252bf18650c5a9a85fc144305c4615
루비 온 레일즈 5.2 릴리스 노트
===============================

Rails 5.2의 주요 기능:

* Active Storage
* Redis Cache Store
* HTTP/2 Early Hints
* Credentials
* Content Security Policy

이 릴리스 노트는 주요 변경 사항만 다룹니다. 다양한 버그 수정 및 변경 사항에 대해서는 변경 로그를 참조하거나 GitHub의 주요 Rails 저장소의 [커밋 목록](https://github.com/rails/rails/commits/5-2-stable)을 확인하십시오.

--------------------------------------------------------------------------------

Rails 5.2로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드하는 경우, 업그레이드하기 전에 좋은 테스트 커버리지를 갖는 것이 좋습니다. 또한, Rails 5.2로 업데이트하기 전에 먼저 Rails 5.1로 업그레이드하고 애플리케이션이 예상대로 실행되는지 확인하십시오. 업그레이드 시 주의해야 할 사항은 [Ruby on Rails 업그레이드](upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2) 가이드에서 확인할 수 있습니다.

주요 기능
--------------

### Active Storage

[Pull Request](https://github.com/rails/rails/pull/30020)

[Active Storage](https://github.com/rails/rails/tree/5-2-stable/activestorage)는 파일을 Amazon S3, Google Cloud Storage 또는 Microsoft Azure Storage와 같은 클라우드 스토리지 서비스에 업로드하고 해당 파일을 Active Record 객체에 첨부하는 기능을 제공합니다. 개발 및 테스트를 위한 로컬 디스크 기반 서비스를 제공하며, 백업 및 마이그레이션을 위해 하위 서비스에 파일을 미러링하는 기능을 지원합니다. Active Storage에 대해 더 자세히 알아보려면 [Active Storage 개요](active_storage_overview.html) 가이드를 참조하십시오.

### Redis Cache Store

[Pull Request](https://github.com/rails/rails/pull/31134)

Rails 5.2에는 내장된 Redis 캐시 스토어가 포함되어 있습니다. 이에 대해 더 자세히 알아보려면 [Rails와 함께 캐싱: 개요](caching_with_rails.html#activesupport-cache-rediscachestore) 가이드를 참조하십시오.

### HTTP/2 Early Hints

[Pull Request](https://github.com/rails/rails/pull/30744)

Rails 5.2는 [HTTP/2 Early Hints](https://tools.ietf.org/html/rfc8297)를 지원합니다. Early Hints를 사용하여 서버를 시작하려면 `bin/rails server`에 `--early-hints`를 전달하십시오.

### Credentials

[Pull Request](https://github.com/rails/rails/pull/30067)

`config/credentials.yml.enc` 파일을 추가하여 프로덕션 앱 비밀을 저장합니다. 이를 통해 `config/master.key` 파일이나 `RAILS_MASTER_KEY` 환경 변수로 암호화된 저장소에 제3자 서비스의 인증 자격 증명을 저장할 수 있습니다. 이는 결국 Rails 5.1에서 도입된 `Rails.application.secrets`와 암호화된 비밀을 대체할 것입니다. 또한, Rails 5.2는 [Credentials의 기반이 되는 API를 공개](https://github.com/rails/rails/pull/30940)하여 다른 암호화된 구성, 키 및 파일을 쉽게 처리할 수 있습니다. 이에 대해 더 자세히 알아보려면 [Rails 애플리케이션 보안](security.html#custom-credentials) 가이드를 참조하십시오.

### Content Security Policy

[Pull Request](https://github.com/rails/rails/pull/31162)

Rails 5.2에는 응용 프로그램에 대한 [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)를 구성할 수 있는 새로운 DSL이 포함되어 있습니다. 전역 기본 정책을 구성한 다음 리소스별로 재정의하거나 멀티 테넌트 애플리케이션에서 계정 서브도메인과 같은 퍼-리퀘스트 값을 헤더에 주입하기 위해 람다를 사용할 수 있습니다. 이에 대해 더 자세히 알아보려면 [Rails 애플리케이션 보안](security.html#content-security-policy) 가이드를 참조하십시오.
Railties
--------

자세한 변경 사항은 [Changelog][railties]를 참조하십시오.

### 폐기 예정 기능

*   생성기 및 템플릿에서 `capify!` 메서드를 폐기합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29493))

*   `rails dbconsole` 및 `rails console` 명령에 환경 이름을 일반 인수로 전달하는 것은 폐기 예정입니다.
    대신 `-e` 옵션을 사용해야 합니다.
    ([Commit](https://github.com/rails/rails/commit/48b249927375465a7102acc71c2dfb8d49af8309))

*   `Rails::Application`의 하위 클래스를 사용하여 Rails 서버를 시작하는 것을 폐기합니다.
    ([Pull Request](https://github.com/rails/rails/pull/30127))

*   Rails 플러그인 템플릿에서 `after_bundle` 콜백을 폐기합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29446))

### 주목할만한 변경 사항

*   모든 환경에 대해 로드되는 `config/database.yml`에 공유 섹션을 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/28896))

*   플러그인 생성기에 `railtie.rb`를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/29576))

*   `tmp:clear` 작업에서 스크린샷 파일을 지우도록 수정했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/29534))

*   `bin/rails app:update`를 실행할 때 사용하지 않는 구성 요소를 건너뛰도록 수정했습니다.
    초기 앱 생성 시 Action Cable, Active Record 등을 건너뛴 경우 업데이트 작업도 해당 건너뛰기를 따릅니다.
    ([Pull Request](https://github.com/rails/rails/pull/29645))

*   3단계 데이터베이스 구성을 사용할 때 `rails dbconsole` 명령에 사용자 정의 연결 이름을 전달할 수 있도록 허용했습니다.
    예: `bin/rails dbconsole -c replica`.
    ([Commit](https://github.com/rails/rails/commit/1acd9a6464668d4d54ab30d016829f60b70dbbeb))

*   `console` 및 `dbconsole` 명령을 실행할 때 환경 이름의 단축을 올바르게 확장합니다.
    ([Commit](https://github.com/rails/rails/commit/3777701f1380f3814bd5313b225586dec64d4104))

*   기본 `Gemfile`에 `bootsnap`을 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/29313))

*   `rails runner`로 stdin에서 스크립트를 실행하는 플랫폼에 독립적인 방법으로 `-`를 지원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/26343))

*   새로운 Rails 애플리케이션을 생성할 때 `Gemfile`에 `ruby x.x.x` 버전을 추가하고 현재 Ruby 버전을 포함하는 `.ruby-version` 루트 파일을 생성합니다.
    ([Pull Request](https://github.com/rails/rails/pull/30016))

*   플러그인 생성기에 `--skip-action-cable` 옵션을 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/30164))

*   플러그인 생성기에 `git_source`를 `Gemfile`에 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/30110))

*   Rails 플러그인에서 `bin/rails`를 실행할 때 사용하지 않는 구성 요소를 건너뛰도록 수정했습니다.
    ([Commit](https://github.com/rails/rails/commit/62499cb6e088c3bc32a9396322c7473a17a28640))

*   생성기 작업의 들여쓰기를 최적화했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/30166))

*   라우트 들여쓰기를 최적화했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/30241))

*   플러그인 생성기에 `--skip-yarn` 옵션을 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/30238))

*   생성기의 `gem` 메서드에 대해 여러 버전 인수를 지원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/30323))

*   개발 및 테스트 환경에서 앱 이름에서 `secret_key_base`를 유도합니다.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   기본 `Gemfile`에 `mini_magick`을 주석으로 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/30633))

*   `rails new` 및 `rails plugin new`는 기본적으로 `Active Storage`를 가져옵니다.
    `--skip-active-storage`로 `Active Storage`를 건너뛸 수 있도록 하고, `--skip-active-record`를 사용할 때 자동으로 건너뛰도록 합니다.
    ([Pull Request](https://github.com/rails/rails/pull/30101))

Action Cable
------------

자세한 변경 사항은 [Changelog][action-cable]를 참조하십시오.

### 제거된 기능

*   폐기된 이벤트 기반 Redis 어댑터를 제거했습니다.
    ([Commit](https://github.com/rails/rails/commit/48766e32d31651606b9f68a16015ad05c3b0de2c))

### 주목할만한 변경 사항

*   `cable.yml`에서 `host`, `port`, `db`, `password` 옵션을 지원합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29528))

*   PostgreSQL 어댑터를 사용할 때 긴 스트림 식별자를 해시합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29297))

Action Pack
-----------

자세한 변경 사항은 [Changelog][action-pack]를 참조하십시오.
### 삭제 사항

*   `ActionController::ParamsParser::ParseError`를 삭제합니다.
    ([커밋](https://github.com/rails/rails/commit/e16c765ac6dcff068ff2e5554d69ff345c003de1))

### 폐기 사항

*   `ActionDispatch::TestResponse`의 `#success?`, `#missing?`, `#error?` 별칭을 폐기합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30104))

### 주목할만한 변경 사항

*   조각 캐싱에 재활용 가능한 캐시 키 지원을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29092))

*   키 변동을 디버그하기 쉽도록 조각의 캐시 키 형식을 변경합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29092))

*   GCM을 사용한 AEAD 암호화된 쿠키 및 세션을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/28132))

*   기본적으로 위조로부터 보호합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29742))

*   서버 측에서 서명/암호화된 쿠키 만료를 강제합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30121))

*   쿠키 `:expires` 옵션은 `ActiveSupport::Duration` 객체를 지원합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30121))

*   Capybara 등록된 `:puma` 서버 구성을 사용합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30638))

*   키 회전 지원을 갖춘 쿠키 미들웨어를 단순화합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29716))

*   HTTP/2를 위한 Early Hints를 활성화할 수 있는 기능을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30744))

*   시스템 테스트에 headless chrome 지원을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30876))

*   `redirect_back` 메서드에 `:allow_other_host` 옵션을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30850))

*   `assert_recognizes`가 마운트된 엔진을 탐색하도록 변경합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/22435))

*   Content-Security-Policy 헤더를 구성하기 위한 DSL을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31162),
    [커밋](https://github.com/rails/rails/commit/619b1b6353a65e1635d10b8f8c6630723a5a6f1a),
    [커밋](https://github.com/rails/rails/commit/4ec8bf68ff92f35e79232fbd605012ce1f4e1e6e))

*   현대 브라우저에서 지원하는 가장 인기 있는 오디오/비디오/폰트 MIME 유형을 등록합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31251))

*   시스템 테스트의 기본 스크린샷 출력을 `inline`에서 `simple`로 변경합니다.
    ([커밋](https://github.com/rails/rails/commit/9d6e288ee96d6241f864dbf90211c37b14a57632))

*   시스템 테스트에 headless firefox 지원을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31365))

*   기본 헤더 세트에 안전한 `X-Download-Options` 및 `X-Permitted-Cross-Domain-Policies`를 추가합니다.
    ([커밋](https://github.com/rails/rails/commit/5d7b70f4336d42eabfc403e9f6efceb88b3eff44))

*   사용자가 다른 서버를 수동으로 지정하지 않은 경우에만 Puma를 기본 서버로 설정하는 시스템 테스트를 변경합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31384))

*   기본 헤더 세트에 `Referrer-Policy` 헤더를 추가합니다.
    ([커밋](https://github.com/rails/rails/commit/428939be9f954d39b0c41bc53d85d0d106b9d1a1))

*   `ActionController::Parameters#each`의 `Hash#each` 동작과 일치합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/27790))

*   Rails UJS를 위한 자동 nonce 생성 지원을 추가합니다.
    ([커밋](https://github.com/rails/rails/commit/b2f0a8945956cd92dec71ec4e44715d764990a49))

*   https://hstspreload.org/의 최소 max-age 요구 사항을 충족하기 위해 기본 HSTS max-age 값을 31536000초(1년)로 업데이트합니다.
    ([커밋](https://github.com/rails/rails/commit/30b5f469a1d30c60d1fb0605e84c50568ff7ed37))

*   `cookies`에 `to_hash`의 별칭 메서드 `to_h`를 추가합니다.
    `session`에 `to_h`의 별칭 메서드 `to_hash`를 추가합니다.
    ([커밋](https://github.com/rails/rails/commit/50a62499e41dfffc2903d468e8b47acebaf9b500))

Action View
-----------

자세한 변경 사항은 [변경 로그][action-view]를 참조하세요.

### 삭제 사항

*   폐기된 Erubis ERB 핸들러를 삭제합니다.
    ([커밋](https://github.com/rails/rails/commit/7de7f12fd140a60134defe7dc55b5a20b2372d06))

### 폐기 사항

*   `image_tag`로 생성된 이미지에 기본 대체 텍스트를 추가하던 `image_alt` 도우미를 폐기합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30213))

### 주목할만한 변경 사항

*   [JSON Feeds](https://jsonfeed.org/version/1)를 지원하기 위해 `auto_discovery_link_tag`에 `:json` 유형을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29158))

*   `image_tag` 도우미에 `srcset` 옵션을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29349))

*   `field_error_proc`가 `optgroup` 및 선택 분할 `option`을 래핑하는 문제를 수정합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31088))

*   `form_with`를 기본적으로 ID를 생성하도록 변경합니다.
    ([커밋](https://github.com/rails/rails/commit/260d6f112a0ffdbe03e6f5051504cb441c1e94cd))

*   `preload_link_tag` 도우미를 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31251))

*   그룹화된 선택 항목에 그룹 메서드로 호출 가능한 객체 사용을 허용합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31578))

[action-view]: https://github.com/rails/rails/blob/master/actionview/CHANGELOG.md
액션 메일러
-------------

자세한 변경 사항은 [Changelog][action-mailer]을 참조하십시오.

### 주목할만한 변경 사항

*   액션 메일러 클래스가 전달 작업을 구성할 수 있도록 허용합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29457))

*   `assert_enqueued_email_with` 테스트 도우미를 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/30695))

액티브 레코드
-------------

자세한 변경 사항은 [Changelog][active-record]을 참조하십시오.

### 제거 사항

*   `#migration_keys`를 제거합니다.
    ([Pull Request](https://github.com/rails/rails/pull/30337))

*   액티브 레코드 객체의 형변환 시 `quoted_id`에 대한 지원을 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/82472b3922bda2f337a79cef961b4760d04f9689))

*   `index_name_exists?`에서 `default` 인수를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/8f5b34df81175e30f68879479243fbce966122d7))

*   연관성에서 `:class_name`에 클래스를 전달하는 지원을 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/e65aff70696be52b46ebe57207ebd8bb2cfcdbb6))

*   `initialize_schema_migrations_table` 및 `initialize_internal_metadata_table` 메서드를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/c9660b5777707658c414b430753029cd9bc39934))

*   `supports_migrations?` 메서드를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/9438c144b1893f2a59ec0924afe4d46bd8d5ffdd))

*   `supports_primary_key?` 메서드를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/c56ff22fc6e97df4656ddc22909d9bf8b0c2cbb1))

*   `ActiveRecord::Migrator.schema_migrations_table_name` 메서드를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/7df6e3f3cbdea9a0460ddbab445c81fbb1cfd012))

*   `#indexes`에서 `name` 인수를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/d6b779ecebe57f6629352c34bfd6c442ac8fba0e))

*   `#verify!`에서 인수를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/9c6ee1bed0292fc32c23dc1c68951ae64fc510be))

*   `.error_on_ignored_order_or_limit` 구성을 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/e1066f450d1a99c9a0b4d786b202e2ca82a4c3b3))

*   `#scope_chain` 메서드를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/ef7784752c5c5efbe23f62d2bbcc62d4fd8aacab))

*   `#sanitize_conditions` 메서드를 제거합니다.
    ([Commit](https://github.com/rails/rails/commit/8f5413b896099f80ef46a97819fe47a820417bc2))

### 폐지 사항

*   `supports_statement_cache?`를 폐지합니다.
    ([Pull Request](https://github.com/rails/rails/pull/28938))

*   `ActiveRecord::Calculations`의 `count` 및 `sum`에 동시에 인수와 블록을 전달하는 것을 폐지합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29262))

*   `Relation`에서 `arel`로 위임하는 것을 폐지합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29619))

*   `TransactionState`의 `set_state` 메서드를 폐지합니다.
    ([Commit](https://github.com/rails/rails/commit/608ebccf8f6314c945444b400a37c2d07f21b253))

*   대체 없이 `expand_hash_conditions_for_aggregates`를 폐지합니다.
    ([Commit](https://github.com/rails/rails/commit/7ae26885d96daee3809d0bd50b1a440c2f5ffb69))

### 주목할만한 변경 사항

*   인수 없이 동적 픽스처 접근자 메서드를 호출할 때 이제 해당 유형의 모든 픽스처를 반환합니다. 이전에는 이 메서드가 항상 빈 배열을 반환했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/28692))

*   Active Record 속성 리더를 재정의할 때 변경된 속성과의 일관성 문제를 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/28661))

*   MySQL에 대한 내림차순 인덱스 지원을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/28773))

*   `bin/rails db:forward` 첫 번째 마이그레이션을 수정합니다.
    ([Commit](https://github.com/rails/rails/commit/b77d2aa0c336492ba33cbfade4964ba0eda3ef84))

*   현재 마이그레이션이 존재하지 않을 때 마이그레이션 이동 시 `UnknownMigrationVersionError` 오류를 발생시킵니다.
    ([Commit](https://github.com/rails/rails/commit/bb9d6eb094f29bb94ef1f26aa44f145f17b973fe))

*   데이터베이스 구조 덤프를 위한 rake 작업에서 `SchemaDumper.ignore_tables`을 존중합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29077))

*   `ActiveRecord::Base#cache_version`을 추가하여 새로운 버전화된 항목을 통해 재사용 가능한 캐시 키를 지원합니다. 이로 인해 `ActiveRecord::Base#cache_key`는 더 이상 타임스탬프를 포함하지 않는 안정적인 키를 반환합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   캐스팅된 값이 null인 경우 바인드 매개변수를 생성하지 않도록 수정합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29282))

*   성능을 향상시키기 위해 대량 INSERT를 사용하여 픽스처를 삽입합니다.
    ([Pull Request](https://github.com/rails/rails/pull/29504))

*   중첩 조인을 나타내는 두 개의 관계를 병합할 때 병합된 관계의 조인을 LEFT OUTER JOIN으로 변환하지 않습니다.
    ([Pull Request](https://github.com/rails/rails/pull/27063))

*   트랜잭션을 사용하여 상태를 자식 트랜잭션에 적용하도록 수정합니다. 이전에 중첩된 트랜잭션이 있고 외부 트랜잭션이 롤백되면 내부 트랜잭션의 레코드는 여전히 영속화된 것으로 표시되었습니다. 부모 트랜잭션이 롤백될 때 부모 트랜잭션의 상태를 자식 트랜잭션에 적용함으로써 이 문제를 수정했습니다. 이로써 내부 트랜잭션의 레코드가 영속화되지 않은 것으로 표시됩니다.
    ([Commit](https://github.com/rails/rails/commit/0237da287eb4c507d10a0c6d94150093acc52b03))
*   조인을 포함하는 스코프와 함께 이른 로딩/사전 로딩 연관을 수정하십시오.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29413))

*   `sql.active_record` 알림 구독자에서 발생하는 오류를 `ActiveRecord::StatementInvalid` 예외로 변환하지 않도록 방지하십시오.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29692))

*   레코드의 일괄 처리(`find_each`, `find_in_batches`, `in_batches`) 작업 시에는 쿼리 캐싱을 건너뛰십시오.
    ([커밋](https://github.com/rails/rails/commit/b83852e6eed5789b23b13bac40228e87e8822b4d))

*   sqlite3의 부울 직렬화를 1과 0을 사용하도록 변경하십시오.
    SQLite는 1과 0을 참과 거짓으로 인식하지만, 이전에 직렬화되었던 't'와 'f'를 기본적으로 인식하지 않습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29699))

*   다중 매개변수 할당을 사용하여 생성된 값은 이제 단일 필드 형식 입력란에 렌더링될 때 후처리된 값(post-type-cast value)을 사용합니다.
    ([커밋](https://github.com/rails/rails/commit/1519e976b224871c7f7dd476351930d5d0d7faf6))

*   모델을 생성할 때 `ApplicationRecord`가 더 이상 생성되지 않습니다. 생성하려면 `rails g application_record`를 사용하십시오.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29916))

*   `Relation#or`는 이제 `references`만 다른 두 개의 관계를 인식합니다. `references`는 `where`에 의해 암묵적으로 호출될 수 있기 때문입니다.
    ([커밋](https://github.com/rails/rails/commit/ea6139101ccaf8be03b536b1293a9f36bc12f2f7))

*   `Relation#or`를 사용할 때 공통 조건을 추출하고 OR 조건 앞에 배치하십시오.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29950))

*   `binary` 픽스처 도우미 메서드를 추가하십시오.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30073))

*   STI에 대한 역 관계를 자동으로 추측하십시오.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/23425))

*   락 대기 시간이 초과될 때 `LockWaitTimeout` 오류 클래스를 추가하고 발생시킵니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30360))

*   `sql.active_record` 계측의 페이로드 이름을 더 구체적으로 업데이트하십시오.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30619))

*   데이터베이스에서 인덱스를 제거할 때 주어진 알고리즘을 사용하십시오.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/24199))

*   `Set`을 `Relation#where`에 전달하는 것은 이제 배열을 전달하는 것과 동일하게 동작합니다.
    ([커밋](https://github.com/rails/rails/commit/9cf7e3494f5bd34f1382c1ff4ea3d811a4972ae2))

*   PostgreSQL `tsrange`는 이제 하위 초 정밀도를 유지합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30725))

*   더티 레코드에서 `lock!`을 호출할 때 예외를 발생시킵니다.
    ([커밋](https://github.com/rails/rails/commit/63cf15877bae859ff7b4ebaf05186f3ca79c1863))

*   SQLite 어댑터를 사용할 때 인덱스의 열 순서가 `db/schema.rb`에 작성되지 않는 버그를 수정하십시오.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30970))

*   지정된 `VERSION`으로 `bin/rails db:migrate`를 수정하십시오. 빈 `VERSION`으로 `bin/rails db:migrate`는 `VERSION` 없이 동작합니다. `VERSION`의 형식을 확인하십시오: 마이그레이션 버전 번호 또는 마이그레이션 파일의 이름을 허용합니다. `VERSION`의 형식이 잘못된 경우 오류를 발생시킵니다. 대상 마이그레이션이 존재하지 않는 경우 오류를 발생시킵니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30714))

*   문장 시간 초과가 초과될 때 `StatementTimeout` 오류 클래스를 추가하고 발생시킵니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31129))

*   `update_all`은 이제 값을 `Type#cast`로 전달하기 전에 `Type#serialize`로 전달합니다. 따라서 `update_all(foo: 'true')`는 부울 값을 올바르게 유지합니다.
    ([커밋](https://github.com/rails/rails/commit/68fe6b08ee72cc47263e0d2c9ff07f75c4b42761))

*   관계 쿼리 메서드에서 사용할 때 원시 SQL 조각을 명시적으로 표시해야 합니다.
    ([커밋](https://github.com/rails/rails/commit/a1ee43d2170dd6adf5a9f390df2b1dde45018a48),
    [커밋](https://github.com/rails/rails/commit/e4a921a75f8702a7dbaf41e31130fe884dea93f9))

*   데이터베이스 마이그레이션에는 마이그레이션 업 시에만 관련이 있는 코드에 `#up_only`를 추가하십시오. 예를 들어 새로운 열을 채울 때 사용합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31082))
* 사용자 요청으로 인해 문을 취소 할 때 발생하는 새로운 오류 클래스 `QueryCanceled` 추가
    ([Pull Request](https://github.com/rails/rails/pull/31235))

* `Relation`의 인스턴스 메소드와 충돌하는 스코프 정의를 허용하지 않음
    ([Pull Request](https://github.com/rails/rails/pull/31179))

* `add_index`에 대한 PostgreSQL 연산자 클래스 지원 추가
    ([Pull Request](https://github.com/rails/rails/pull/19090))

* 데이터베이스 쿼리 호출자 로깅
    ([Pull Request](https://github.com/rails/rails/pull/26815),
    [Pull Request](https://github.com/rails/rails/pull/31519),
    [Pull Request](https://github.com/rails/rails/pull/31690))

* 컬럼 정보 재설정시 하위 클래스에서 속성 메소드 정의 해제
    ([Pull Request](https://github.com/rails/rails/pull/31475))

* `limit` 또는 `offset`와 함께 `delete_all`에 대한 서브셀렉트 사용
    ([Commit](https://github.com/rails/rails/commit/9e7260da1bdc0770cf4ac547120c85ab93ff3d48))

* `limit()`와 함께 사용될 때 `first(n)`의 일관성 문제 수정
    `first(n)` 파인더는 이제 `limit()`를 존중하여 `relation.to_a.first(n)`과 일관성을 유지하며 `last(n)`의 동작과도 일치합니다.
    ([Pull Request](https://github.com/rails/rails/pull/27597))

* 저장되지 않은 부모 인스턴스에서 중첩된 `has_many :through` 연관 관계 수정
    ([Commit](https://github.com/rails/rails/commit/027f865fc8b262d9ba3ee51da3483e94a5489b66))

* 삭제된 레코드를 통해 레코드를 삭제 할 때 연관 조건을 고려
    ([Commit](https://github.com/rails/rails/commit/ae48c65e411e01c1045056562319666384bb1b63))

* `save` 또는 `save!` 호출 후에 파괴된 객체 변이 허용하지 않음
    ([Commit](https://github.com/rails/rails/commit/562dd0494a90d9d47849f052e8913f0050f3e494))

* `left_outer_joins`와 관련된 관계 병합기 문제 수정
    ([Pull Request](https://github.com/rails/rails/pull/27860))

* PostgreSQL 외부 테이블 지원
    ([Pull Request](https://github.com/rails/rails/pull/31549))

* Active Record 객체가 복제 될 때 트랜잭션 상태 지우기
    ([Pull Request](https://github.com/rails/rails/pull/31751))

* `composed_of` 컬럼을 사용하여 where 메소드에 Array 객체를 인수로 전달 할 때 확장되지 않는 문제 수정
    ([Pull Request](https://github.com/rails/rails/pull/31724))

* `reflection.klass`가 `polymorphic?`를 잘못 사용하지 않도록 수정
    ([Commit](https://github.com/rails/rails/commit/63fc1100ce054e3e11c04a547cdb9387cd79571a))

* MySQL 및 PostgreSQL의 `#columns_for_distinct` 수정하여 `ActiveRecord::FinderMethods#limited_ids_for`가 올바른 기본 키 값을 사용하도록 함
    `ORDER BY` 열에 다른 테이블의 기본 키가 포함되어 있어도
    ([Commit](https://github.com/rails/rails/commit/851618c15750979a75635530200665b543561a44))

* has_one/belongs_to 관계에서 `dependent: :destroy` 문제 수정
    자식이 삭제되지 않을 때 부모 클래스가 삭제되는 문제
    ([Commit](https://github.com/rails/rails/commit/b0fc04aa3af338d5a90608bf37248668d59fc881))

* 유휴 데이터베이스 연결 (이전에는 고아 연결만)은 이제 연결 풀 리퍼에 의해 주기적으로 제거됩니다.
    ([Commit](https://github.com/rails/rails/pull/31221/commits/9027fafff6da932e6e64ddb828665f4b01fc8902))

Active Model
------------

자세한 변경 사항은 [Changelog][active-model]를 참조하십시오.

### 주목할만한 변경 사항

* `ActiveModel::Errors`에서 `#keys`, `#values` 메소드 수정
    `#keys`는 빈 메시지가 없는 키만 반환하도록 변경됩니다.
    `#values`는 비어 있지 않은 값만 반환하도록 변경됩니다.
    ([Pull Request](https://github.com/rails/rails/pull/28584))

* `ActiveModel::Errors`에 대한 `#merge!` 메소드 추가
    ([Pull Request](https://github.com/rails/rails/pull/29714))

* 길이 유효성 검사기 옵션에 Proc 또는 Symbol 전달 허용
    ([Pull Request](https://github.com/rails/rails/pull/30674))

* `_confirmation`의 값이 `false`인 경우 `ConfirmationValidator` 유효성 검사 실행
    ([Pull Request](https://github.com/rails/rails/pull/31058))

* proc 기본값을 사용하는 속성 API를 사용하는 모델을 마샬 할 수 있도록 수정
    ([Commit](https://github.com/rails/rails/commit/0af36c62a5710e023402e37b019ad9982e69de4b))

* 직렬화에서 옵션을 포함한 모든 다중 `:includes`를 잃지 않도록 수정
    ([Commit](https://github.com/rails/rails/commit/853054bcc7a043eea78c97e7705a46abb603cc44))

Active Support
--------------

자세한 변경 사항은 [Changelog][active-support]를 참조하십시오.

### 제거 사항

* 콜백에 대한 `:if` 및 `:unless` 문자열 필터 제거
    ([Commit](https://github.com/rails/rails/commit/c792354adcbf8c966f274915c605c6713b840548))

* `halt_callback_chains_on_return_false` 옵션 제거
    ([Commit](https://github.com/rails/rails/commit/19fbbebb1665e482d76cae30166b46e74ceafe29))

[active-model]: https://github.com/rails/rails/blob/master/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/master/activesupport/CHANGELOG.md
### 폐기 사항

*   `Module#reachable?` 메서드를 폐기합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30624))

*   `secrets.secret_token`을 폐기합니다.
    ([커밋](https://github.com/rails/rails/commit/fbcc4bfe9a211e219da5d0bb01d894fcdaef0a0e))

### 주목할만한 변경 사항

*   `HashWithIndifferentAccess`에 `fetch_values`를 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/28316))

*   `Time#change`에 `:offset` 지원을 추가합니다.
    ([커밋](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   `ActiveSupport::TimeWithZone#change`에 `:offset` 및 `:zone` 지원을 추가합니다.
    ([커밋](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   폐기 알림에 젬 이름과 폐기 예정 기간을 전달합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/28800))

*   버전별 캐시 엔트리 지원을 추가합니다. 이를 통해 캐시 스토어가 캐시 키를 재활용하여 저장 공간을 크게 절약할 수 있습니다. Active Record의 `#cache_key`와 `#cache_version`의 분리 및 Action Pack의 프래그먼트 캐싱에서의 사용과 함께 작동합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29092))

*   스레드 격리된 속성 싱글톤을 제공하기 위해 `ActiveSupport::CurrentAttributes`를 추가합니다. 주요 사용 사례는 모든 요청에 대한 속성을 전체 시스템에서 쉽게 사용할 수 있도록 하는 것입니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29180))

*   `#singularize` 및 `#pluralize`는 지정된 로케일에 대해 불가산 명사를 존중합니다.
    ([커밋](https://github.com/rails/rails/commit/352865d0f835c24daa9a2e9863dcc9dde9e5371a))

*   `class_attribute`에 기본 옵션을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29270))

*   `Date#prev_occurring` 및 `Date#next_occurring`을 추가하여 지정된 이전/다음 요일을 반환합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/26600))

*   모듈 및 클래스 속성 접근자에 기본 옵션을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29294))

*   캐시: `write_multi`.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29366))

*   기본적으로 `ActiveSupport::MessageEncryptor`가 AES 256 GCM 암호화를 사용하도록 설정합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29263))

*   테스트에서 시간을 `Time.now`로 고정하는 `freeze_time` 도우미를 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29681))

*   `Hash#reverse_merge!`의 순서를 `HashWithIndifferentAccess`와 일관되게 만듭니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/28077))

*   `ActiveSupport::MessageVerifier` 및 `ActiveSupport::MessageEncryptor`에 목적과 만료 지원을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29892))

*   `String#camelize`를 업데이트하여 잘못된 옵션이 전달될 때 피드백을 제공합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30039))

*   `Module#delegate_missing_to`는 이제 대상이 null인 경우 `DelegationError`를 발생시킵니다. 이는 `Module#delegate`와 유사합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30191))

*   `ActiveSupport::EncryptedFile` 및 `ActiveSupport::EncryptedConfiguration`를 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30067))

*   프로덕션 앱 비밀을 저장하기 위해 `config/credentials.yml.enc`를 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30067))

*   `MessageEncryptor` 및 `MessageVerifier`에 키 회전 지원을 추가합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/29716))

*   `HashWithIndifferentAccess#transform_keys`에서 `HashWithIndifferentAccess`의 인스턴스를 반환합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30728))

*   `Hash#slice`는 이제 정의되어 있으면 Ruby 2.5+의 내장 정의로 대체됩니다.
    ([커밋](https://github.com/rails/rails/commit/01ae39660243bc5f0a986e20f9c9bff312b1b5f8))

*   `IO#to_json`은 이제 배열로 변환하려는 대신 `to_s` 표현을 반환합니다. 이로 인해 `IO#to_json`을 읽을 수 없는 개체에 대해 호출하면 `IOError`가 발생하는 버그가 수정됩니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30953))

*   `Date#prev_day` 및 `Date#next_day`와 일치하는 `Time#prev_day` 및 `Time#next_day`에 동일한 메서드 시그니처를 추가합니다. `Time#prev_day` 및 `Time#next_day`에 인수를 전달할 수 있도록 합니다.
    ([커밋](https://github.com/rails/rails/commit/61ac2167eff741bffb44aec231f4ea13d004134e))

*   `Date#prev_month` 및 `Date#next_month`와 일치하는 `Time#prev_month` 및 `Time#next_month`에 동일한 메서드 시그니처를 추가합니다. `Time#prev_month` 및 `Time#next_month`에 인수를 전달할 수 있도록 합니다.
    ([커밋](https://github.com/rails/rails/commit/f2c1e3a793570584d9708aaee387214bc3543530))

*   `Date#prev_year` 및 `Date#next_year`와 일치하는 `Time#prev_year` 및 `Time#next_year`에 동일한 메서드 시그니처를 추가합니다. `Time#prev_year` 및 `Time#next_year`에 인수를 전달할 수 있도록 합니다.
    ([커밋](https://github.com/rails/rails/commit/ee9d81837b5eba9d5ec869ae7601d7ffce763e3e))
* `humanize`에서 약어 지원 수정.
    ([커밋](https://github.com/rails/rails/commit/0ddde0a8fca6a0ca3158e3329713959acd65605d))

* TWZ 범위에서 `Range#include?` 허용.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31081))

* 캐시: 값이 1kB보다 큰 경우에는 압축 기능을 기본으로 활성화.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31147))

* Redis 캐시 스토어.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31134),
    [풀 리퀘스트](https://github.com/rails/rails/pull/31866))

* `TZInfo::AmbiguousTime` 오류 처리.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31128))

* MemCacheStore: 만료 카운터 지원.
    ([커밋](https://github.com/rails/rails/commit/b22ee64b5b30c6d5039c292235e10b24b1057f6d))

* `ActiveSupport::TimeZone.all`이 `ActiveSupport::TimeZone::MAPPING`에 있는 시간대만 반환하도록 변경.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31176))

* `ActiveSupport::SecurityUtils.secure_compare`의 기본 동작 변경. 가변 길이 문자열에 대해서도 길이 정보가 노출되지 않도록 함. 이전 `ActiveSupport::SecurityUtils.secure_compare`를 `fixed_length_secure_compare`로 이름 변경하고, 전달된 문자열의 길이 불일치 시 `ArgumentError`를 발생시키도록 함.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/24510))

* ETag 헤더와 같은 민감하지 않은 다이제스트를 생성하기 위해 SHA-1 사용.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31289),
    [풀 리퀘스트](https://github.com/rails/rails/pull/31651))

* `assert_changes`는 `from:` 및 `to:` 인수 조합에 관계없이 표현식이 변경되었는지 항상 확인함.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31011))

* `ActiveSupport::Cache::Store`에서 `read_multi`에 대한 누락된 인스트루먼테이션 추가.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30268))

* `assert_difference`의 첫 번째 인수로 해시 지원. 이를 통해 동일한 어설션에서 여러 숫자 차이를 지정할 수 있음.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31600))

* 캐싱: MemCache 및 Redis `read_multi` 및 `fetch_multi` 속도 향상. 백엔드를 확인하기 전에 로컬 인메모리 캐시에서 읽음.
    ([커밋](https://github.com/rails/rails/commit/a2b97e4ffef971607a1be8fc7909f099b6840f36))

Active Job
----------

자세한 변경 사항은 [변경 로그][active-job]를 참조하십시오.

### 주요 변경 사항

* `ActiveJob::Base.discard_on`에 블록을 전달하여 폐기 작업의 사용자 정의 처리를 허용.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/30622))

Ruby on Rails 가이드
--------------------

자세한 변경 사항은 [변경 로그][guides]를 참조하십시오.

### 주요 변경 사항

* [Rails에서의 스레딩 및 코드 실행](threading_and_code_execution.html) 가이드 추가.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/27494))

* [Active Storage 개요](active_storage_overview.html) 가이드 추가.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/31037))

크레딧
-------

Rails에 많은 시간을 투자한 많은 사람들을 위해 [Rails 기여자 전체 목록](https://contributors.rubyonrails.org/)을 참조하십시오. 모든 분들에게 경의를 표합니다.

[railties]:       https://github.com/rails/rails/blob/5-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-2-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-2-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-2-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-2-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/5-2-stable/guides/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-2-stable/activesupport/CHANGELOG.md
