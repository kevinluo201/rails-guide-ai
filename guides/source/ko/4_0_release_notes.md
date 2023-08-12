**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b21dbc892c0a841f1bc1fafdf5ee0126
루비 온 레일즈 4.0 릴리스 노트
===============================

Rails 4.0의 주요 기능:

* 루비 2.0 우선; 1.9.3+ 필요
* 강력한 매개변수
* Turbolinks
* 러시안 돌 캐싱

이 릴리스 노트는 주요 변경 사항만 다룹니다. 다양한 버그 수정 및 변경 사항에 대해서는 변경 로그를 참조하거나 GitHub의 주요 Rails 저장소의 [커밋 목록](https://github.com/rails/rails/commits/4-0-stable)을 확인하십시오.

--------------------------------------------------------------------------------

Rails 4.0으로 업그레이드
----------------------

기존 애플리케이션을 업그레이드하는 경우, 업그레이드하기 전에 좋은 테스트 커버리지를 갖고 있는 것이 좋습니다. 또한, Rails 3.2로 먼저 업그레이드하고 애플리케이션이 예상대로 실행되는지 확인한 후에 Rails 4.0으로 업데이트를 시도해야 합니다. 업그레이드할 때 주의해야 할 사항은 [Ruby on Rails 업그레이드](upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0) 가이드에서 확인할 수 있습니다.


Rails 4.0 애플리케이션 생성
--------------------------------

```bash
# 'rails' RubyGem이 설치되어 있어야 합니다.
$ rails new myapp
$ cd myapp
```

### 젬 벤더링

Rails는 이제 애플리케이션 루트에있는 `Gemfile`을 사용하여 애플리케이션을 시작하는 데 필요한 젬을 결정합니다. 이 `Gemfile`은 [Bundler](https://github.com/carlhuda/bundler) 젬에 의해 처리되며, 모든 종속성을 설치합니다. 심지어 시스템 젬에 의존하지 않도록 모든 종속성을 애플리케이션에 로컬로 설치할 수도 있습니다.

자세한 정보: [Bundler 홈페이지](https://bundler.io)

### 최신 버전 사용하기

`Bundler`와 `Gemfile`을 사용하면 새로운 전용 `bundle` 명령을 사용하여 Rails 애플리케이션을 쉽게 동결할 수 있습니다. Git 저장소에서 직접 번들을 생성하려면 `--edge` 플래그를 전달할 수 있습니다.

```bash
$ rails new myapp --edge
```

Rails 저장소의 로컬 체크아웃이 있고 해당 체크아웃을 사용하여 애플리케이션을 생성하려면 `--dev` 플래그를 전달할 수 있습니다.

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

주요 기능
--------------

[![Rails 4.0](images/4_0_release_notes/rails4_features.png)](https://guides.rubyonrails.org/images/4_0_release_notes/rails4_features.png)

### 업그레이드

* **루비 1.9.3** ([커밋](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)) - 루비 2.0 우선; 1.9.3+ 필요
* **[새로운 폐기 정책](https://www.youtube.com/watch?v=z6YgD6tVPQs)** - 폐기된 기능은 Rails 4.0에서 경고로 표시되며, Rails 4.1에서 제거될 예정입니다.
* **ActionPack 페이지 및 액션 캐싱** ([커밋](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)) - 페이지 및 액션 캐싱이 별도의 젬으로 분리되었습니다. 페이지 및 액션 캐싱은 수동으로 캐시를 만료시켜야 하는 번거로움이 있습니다 (기본 모델 객체가 업데이트 될 때 수동으로 캐시 만료). 대신 러시안 돌 캐싱을 사용하십시오.
* **ActiveRecord 옵저버** ([커밋](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)) - 옵저버가 별도의 젬으로 분리되었습니다. 옵저버는 페이지 및 액션 캐싱에만 필요하며, 스파게티 코드로 이어질 수 있습니다.
* **ActiveRecord 세션 저장소** ([커밋](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)) - ActiveRecord 세션 저장소가 별도의 젬으로 분리되었습니다. SQL에 세션을 저장하는 것은 비용이 많이 듭니다. 대신 쿠키 세션, 메모리 캐시 세션 또는 사용자 정의 세션 저장소를 사용하십시오.
* **ActiveModel 대량 할당 보호** ([커밋](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)) - Rails 3 대량 할당 보호가 폐기되었습니다. 대신 강력한 매개변수를 사용하십시오.
* **ActiveResource** ([커밋](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)) - ActiveResource가 별도의 젬으로 분리되었습니다. ActiveResource는 널리 사용되지 않았습니다.
* **vendor/plugins 제거** ([커밋](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)) - 설치된 젬을 관리하기 위해 `Gemfile`을 사용하십시오.
### ActionPack

* **강력한 매개변수** ([커밋](https://github.com/rails/rails/commit/a8f6d5c6450a7fe058348a7f10a908352bb6c7fc)) - 허용된 매개변수만을 사용하여 모델 객체를 업데이트합니다 (`params.permit(:title, :text)`).
* **라우팅 관심사** ([커밋](https://github.com/rails/rails/commit/0dd24728a088fcb4ae616bb5d62734aca5276b1b)) - 라우팅 DSL에서 공통 하위 경로를 분리합니다 (`/posts/1/comments`와 `/videos/1/comments`에서 `comments`를 분리합니다).
* **ActionController::Live** ([커밋](https://github.com/rails/rails/commit/af0a9f9eefaee3a8120cfd8d05cbc431af376da3)) - `response.stream`을 사용하여 JSON을 스트리밍합니다.
* **선언적 ETag** ([커밋](https://github.com/rails/rails/commit/ed5c938fa36995f06d4917d9543ba78ed506bb8d)) - 액션 ETag 계산의 일부가 될 컨트롤러 수준의 etag 추가를 추가합니다.
* **[러시안 돌 캐싱](https://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)** ([커밋](https://github.com/rails/rails/commit/4154bf012d2bec2aae79e4a49aa94a70d3e91d49)) - 뷰의 중첩된 조각을 캐시합니다. 각 조각은 종속성 집합 (캐시 키)에 따라 만료됩니다. 캐시 키는 일반적으로 템플릿 버전 번호와 모델 객체입니다.
* **Turbolinks** ([커밋](https://github.com/rails/rails/commit/e35d8b18d0649c0ecc58f6b73df6b3c8d0c6bb74)) - 초기 HTML 페이지를 하나만 제공합니다. 사용자가 다른 페이지로 이동할 때, pushState를 사용하여 URL을 업데이트하고 AJAX를 사용하여 제목과 본문을 업데이트합니다.
* **ActionView를 ActionController에서 분리** ([커밋](https://github.com/rails/rails/commit/78b0934dd1bb84e8f093fb8ef95ca99b297b51cd)) - ActionView가 ActionPack에서 분리되어 Rails 4.1에서 별도의 젬으로 이동될 예정입니다.
* **ActiveModel에 의존하지 않음** ([커밋](https://github.com/rails/rails/commit/166dbaa7526a96fdf046f093f25b0a134b277a68)) - ActionPack은 더 이상 ActiveModel에 의존하지 않습니다.

### 일반

 * **ActiveModel::Model** ([커밋](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)) - `ActiveModel::Model`은 일반적인 Ruby 객체가 ActionPack과 함께 작동할 수 있도록 하는 믹스인입니다 (예: `form_for`를 위해).
 * **새로운 스코프 API** ([커밋](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)) - 스코프는 항상 호출 가능한 것을 사용해야 합니다.
 * **스키마 캐시 덤프** ([커밋](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)) - Rails 부팅 시간을 개선하기 위해, 데이터베이스에서 스키마를 직접로드하는 대신 덤프 파일에서 스키마를 로드합니다.
 * **트랜잭션 격리 수준 지정 지원** ([커밋](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)) - 반복 가능한 읽기 또는 개선된 성능 (잠금이 적은) 중 어떤 것이 더 중요한지 선택할 수 있습니다.
 * **Dalli** ([커밋](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)) - Dalli 메모리 캐시 클라이언트를 사용하여 메모리 캐시 스토어를 사용합니다.
 * **시작 및 완료 알림** ([커밋](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)) - Active Support instrumentation은 시작 및 완료 알림을 구독자에게 보고합니다.
 * **기본적으로 스레드 안전** ([커밋](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)) - Rails는 추가 구성 없이 스레드 기반 앱 서버에서 실행할 수 있습니다.

참고: 사용 중인 젬이 스레드 안전한지 확인하세요.

 * **PATCH 동사** ([커밋](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)) - Rails에서는 PUT을 대체하는 PATCH를 사용합니다. PATCH는 리소스의 부분적인 업데이트에 사용됩니다.

### 보안

* **match는 모두 캐치하지 않음** ([커밋](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)) - 라우팅 DSL에서 match는 HTTP 동사를 지정해야 합니다.
* **기본적으로 HTML 엔티티 이스케이프** ([커밋](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)) - erb에서 렌더링된 문자열은 `raw`로 래핑되지 않은 경우 이스케이프됩니다.
* **새로운 보안 헤더** ([커밋](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)) - Rails는 모든 HTTP 요청과 함께 다음 헤더를 전송합니다: `X-Frame-Options` (브라우저가 페이지를 프레임에 포함하지 못하도록하여 클릭재킹을 방지합니다), `X-XSS-Protection` (브라우저에게 스크립트 주입을 중지하도록 요청합니다) 및 `X-Content-Type-Options` (브라우저가 jpeg을 exe로 열지 못하도록 방지합니다).
기능을 gem으로 추출하기
---------------------------

Rails 4.0에서는 여러 기능이 gem으로 추출되었습니다. 기능을 다시 사용하려면 `Gemfile`에 추출된 gem을 추가하기만 하면 됩니다.

* 해시 기반 및 동적 검색 메서드 ([GitHub](https://github.com/rails/activerecord-deprecated_finders))
* Active Record 모델에서 대량 할당 보호 ([GitHub](https://github.com/rails/protected_attributes), [Pull Request](https://github.com/rails/rails/pull/7251))
* ActiveRecord::SessionStore ([GitHub](https://github.com/rails/activerecord-session_store), [Pull Request](https://github.com/rails/rails/pull/7436))
* Active Record Observers ([GitHub](https://github.com/rails/rails-observers), [Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2))
* Active Resource ([GitHub](https://github.com/rails/activeresource), [Pull Request](https://github.com/rails/rails/pull/572), [Blog](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource))
* Action Caching ([GitHub](https://github.com/rails/actionpack-action_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Page Caching ([GitHub](https://github.com/rails/actionpack-page_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Sprockets ([GitHub](https://github.com/rails/sprockets-rails))
* 성능 테스트 ([GitHub](https://github.com/rails/rails-perftest), [Pull Request](https://github.com/rails/rails/pull/8876))

문서
-------------

* 가이드는 GitHub Flavored Markdown으로 다시 작성되었습니다.

* 가이드는 반응형 디자인을 가지고 있습니다.

Railties
--------

자세한 변경 사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md)를 참조하십시오.

### 주목할만한 변경 사항

* 새로운 테스트 위치 `test/models`, `test/helpers`, `test/controllers`, `test/mailers`가 추가되었습니다. 해당하는 rake 작업도 추가되었습니다. ([Pull Request](https://github.com/rails/rails/pull/7878))

* 앱의 실행 파일은 이제 `bin/` 디렉토리에 있습니다. `bin/bundle`, `bin/rails`, `bin/rake`를 얻으려면 `rake rails:update:bin`을 실행하십시오.

* 기본적으로 Threadsafe가 켜져 있습니다.

* `rails new`에 `--builder` (또는 `-b`)를 전달하여 사용자 정의 빌더를 사용하는 기능이 제거되었습니다. 대신 애플리케이션 템플릿을 사용하는 것을 고려하십시오. ([Pull Request](https://github.com/rails/rails/pull/9401))

### 폐기 예정

* `config.threadsafe!`는 더 세밀한 제어를 제공하는 `config.eager_load`로 대체되었습니다.

* `Rails::Plugin`은 사라졌습니다. `vendor/plugins`에 플러그인을 추가하는 대신 gems 또는 path 또는 git 종속성을 사용하십시오.

Action Mailer
-------------

자세한 변경 사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionmailer/CHANGELOG.md)를 참조하십시오.

### 주목할만한 변경 사항

### 폐기 예정

Active Model
------------

자세한 변경 사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/activemodel/CHANGELOG.md)를 참조하십시오.

### 주목할만한 변경 사항

* `ActiveModel::ForbiddenAttributesProtection`를 추가하여 비허용된 속성이 전달될 때 대량 할당으로부터 속성을 보호하는 간단한 모듈을 추가했습니다.

* `ActiveModel::Model`을 추가하여 Ruby 객체가 Action Pack과 함께 작동할 수 있도록 하는 mixin을 만들었습니다.

### 폐기 예정

Active Support
--------------

자세한 변경 사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/activesupport/CHANGELOG.md)를 참조하십시오.

### 주목할만한 변경 사항

* `ActiveSupport::Cache::MemCacheStore`에서 폐기 예정인 `memcache-client` gem을 `dalli`로 대체했습니다.

* 메모리 및 처리 오버헤드를 줄이기 위해 `ActiveSupport::Cache::Entry`를 최적화했습니다.

* Inflections는 이제 로케일별로 정의할 수 있습니다. `singularize`와 `pluralize`는 추가 인수로 로케일을 받습니다.

* `Object#try`는 이제 수신 객체가 메서드를 구현하지 않으면 NoMethodError를 발생시키지 않고 대신 nil을 반환합니다. 그러나 `Object#try!`를 사용하면 이전 동작을 그대로 얻을 수 있습니다.

* `String#to_date`는 이제 유효하지 않은 날짜가 주어지면 `ArgumentError: invalid date`를 발생시킵니다. 이제 `Date.parse`와 동일하며, 3.x보다 더 많은 유효하지 않은 날짜를 허용합니다. 예를 들어:
```ruby
# ActiveSupport 3.x
"asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
"333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

# ActiveSupport 4
"asdf".to_date # => ArgumentError: invalid date
"333".to_date # => Fri, 29 Nov 2013
```

### Deprecations

* `ActiveSupport::TestCase#pending` 메서드를 폐기하고 대신 minitest의 `skip`을 사용하십시오.

* `ActiveSupport::Benchmarkable#silence`는 스레드 안전성이 부족하여 폐기되었습니다. Rails 4.1에서 대체 없이 제거될 예정입니다.

* `ActiveSupport::JSON::Variable`이 폐기되었습니다. 사용자 정의 JSON 문자열 리터럴을 위해 자체 `#as_json` 및 `#encode_json` 메서드를 정의하십시오.

* 호환성 메서드 `Module#local_constant_names`를 폐기하고 대신 `Module#local_constants`를 사용하십시오(심볼을 반환합니다).

* `ActiveSupport::BufferedLogger`가 폐기되었습니다. `ActiveSupport::Logger` 또는 Ruby 표준 라이브러리의 로거를 사용하십시오.

* `assert_present` 및 `assert_blank`를 `assert object.blank?` 및 `assert object.present?`로 대체하십시오.

Action Pack
-----------

자세한 변경 사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md)을 참조하십시오.

### 주요 변경 사항

* 개발 모드에서 예외 페이지의 스타일시트를 변경하였습니다. 또한 모든 예외 페이지에서 예외를 발생시킨 코드의 줄과 단편도 표시됩니다.

### 폐기 사항


Active Record
-------------

자세한 변경 사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md)을 참조하십시오.

### 주요 변경 사항

* `change` 마이그레이션을 작성하는 방법을 개선하여 이전의 `up` 및 `down` 메서드가 더 이상 필요하지 않습니다.

    * `drop_table` 및 `remove_column` 메서드는 필요한 정보가 제공되는 한 되돌릴 수 있습니다.
      `remove_column` 메서드는 이전에 여러 열 이름을 허용했으며, 대신 `remove_columns`를 사용하십시오(되돌릴 수 없음).
      `change_table` 메서드도 되돌릴 수 있으며, 블록에서 `remove`, `change`, `change_default`를 호출하지 않는 한 가능합니다.

    * `reversible` 메서드를 사용하면 마이그레이션을 위로 또는 아래로 마이그레이션할 때 실행할 코드를 지정할 수 있습니다.
      [마이그레이션 가이드](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#using-reversible)를 참조하십시오.

    * `revert` 메서드는 전체 마이그레이션 또는 지정된 블록을 되돌릴 수 있습니다.
      아래로 마이그레이션하는 경우, 지정된 마이그레이션/블록은 일반적으로 실행됩니다.
      [마이그레이션 가이드](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#reverting-previous-migrations)를 참조하십시오.

* PostgreSQL 배열 타입 지원을 추가하였습니다. 어떤 데이터 유형이든 배열 열을 생성할 수 있으며, 마이그레이션 및 스키마 덤프 지원이 완벽합니다.

* `Relation#load`를 추가하여 레코드를 명시적으로 로드하고 `self`를 반환합니다.

* `Model.all`은 이제 배열 대신 `ActiveRecord::Relation`을 반환합니다. 배열이 필요한 경우 `Relation#to_a`를 사용하십시오. 특정 경우에는 업그레이드 시에 문제가 발생할 수 있습니다.

* 보류 중인 마이그레이션이 있는 경우 오류를 발생시키는 `ActiveRecord::Migration.check_pending!`를 추가하였습니다.

* `ActiveRecord::Store`에 사용자 정의 코더 지원을 추가하였습니다. 다음과 같이 사용자 정의 코더를 설정할 수 있습니다:

        store :settings, accessors: [ :color, :homepage ], coder: JSON
* `mysql`와 `mysql2` 연결은 데이터의 소실을 방지하기 위해 기본적으로 `SQL_MODE=STRICT_ALL_TABLES`를 설정합니다. 이는 `database.yml`에서 `strict: false`를 지정하여 비활성화할 수 있습니다.

* IdentityMap를 제거합니다.

* EXPLAIN 쿼리의 자동 실행을 제거합니다. `active_record.auto_explain_threshold_in_seconds` 옵션은 더 이상 사용되지 않으며 제거되어야 합니다.

* `ActiveRecord::NullRelation`과 `ActiveRecord::Relation#none`을 추가하여 Relation 클래스에 null object 패턴을 구현합니다.

* HABTM 조인 테이블을 생성하기 위한 `create_join_table` 마이그레이션 헬퍼를 추가합니다.

* PostgreSQL hstore 레코드를 생성할 수 있도록 합니다.

### 폐지 사항

* 구식 해시 기반 검색 API를 폐지했습니다. 이는 이전에 "검색 옵션"을 허용했던 메서드들이 더 이상 사용되지 않음을 의미합니다.

* `find_by_...`과 `find_by_...!`를 제외한 모든 동적 메서드가 폐지되었습니다. 다음과 같이 코드를 다시 작성할 수 있습니다:

      * `find_all_by_...`은 `where(...)`를 사용하여 다시 작성할 수 있습니다.
      * `find_last_by_...`은 `where(...).last`를 사용하여 다시 작성할 수 있습니다.
      * `scoped_by_...`은 `where(...)`를 사용하여 다시 작성할 수 있습니다.
      * `find_or_initialize_by_...`은 `find_or_initialize_by(...)`를 사용하여 다시 작성할 수 있습니다.
      * `find_or_create_by_...`은 `find_or_create_by(...)`를 사용하여 다시 작성할 수 있습니다.
      * `find_or_create_by_...!`은 `find_or_create_by!(...)`를 사용하여 다시 작성할 수 있습니다.

크레딧
-------

Rails를 안정적이고 견고한 프레임워크로 만들기 위해 많은 시간을 투자한 많은 사람들에게 [Rails 기여자 전체 목록](https://contributors.rubyonrails.org/)을 참조하십시오. 그들에게 모두 감사드립니다.
