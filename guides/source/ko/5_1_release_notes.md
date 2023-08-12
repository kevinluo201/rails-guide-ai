**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ddd82b1a207070829b1ec46e4bb40d80
Ruby on Rails 5.1 릴리스 노트
===============================

Rails 5.1의 주요 기능:

* Yarn 지원
* 선택적 Webpack 지원
* jQuery는 더 이상 기본 종속성이 아님
* 시스템 테스트
* 암호화된 비밀
* 매개 변수화된 메일러
* 직접 및 해결된 라우트
* form_for 및 form_tag의 통합 form_with

이 릴리스 노트는 주요 변경 사항만 다룹니다. 다양한 버그 수정 및 변경 사항에 대해서는 변경 로그를 참조하거나 GitHub의 주요 Rails 저장소의 [커밋 목록](https://github.com/rails/rails/commits/5-1-stable)을 확인하십시오.

--------------------------------------------------------------------------------

Rails 5.1로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드하는 경우, 업그레이드하기 전에 좋은 테스트 커버리지를 갖는 것이 좋습니다. 또한, Rails 5.1로 업데이트하기 전에 Rails 5.0으로 먼저 업그레이드하고 애플리케이션이 예상대로 작동하는지 확인하십시오. 업그레이드할 때 주의해야 할 사항은 [Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1) 가이드에서 확인할 수 있습니다.

주요 기능
--------------

### Yarn 지원

[Pull Request](https://github.com/rails/rails/pull/26836)

Rails 5.1은 Yarn을 통해 npm에서 JavaScript 종속성을 관리할 수 있습니다. 이를 통해 React, VueJS 또는 다른 npm 라이브러리와 같은 라이브러리를 쉽게 사용할 수 있습니다. Yarn 지원은 자산 파이프라인과 통합되어 모든 종속성이 Rails 5.1 앱과 원활하게 작동합니다.

### 선택적 Webpack 지원

[Pull Request](https://github.com/rails/rails/pull/27288)

Rails 앱은 새로운 [Webpacker](https://github.com/rails/webpacker) 젬을 사용하여 JavaScript 자산 번들러인 [Webpack](https://webpack.js.org/)과 더 쉽게 통합할 수 있습니다. Webpack 통합을 활성화하려면 새로운 애플리케이션을 생성할 때 `--webpack` 플래그를 사용하십시오.

이는 이미지, 글꼴, 소리 및 기타 자산에 대해 계속해서 사용할 수 있는 자산 파이프라인과 완전히 호환됩니다. 자산 파이프라인을 통해 일부 JavaScript 코드를 관리하고 다른 코드를 Webpack을 통해 처리할 수도 있습니다. 이 모든 것은 기본적으로 활성화된 Yarn에 의해 관리됩니다.

### jQuery는 더 이상 기본 종속성이 아님

[Pull Request](https://github.com/rails/rails/pull/27113)

이전 버전의 Rails에서는 `data-remote`, `data-confirm` 및 기타 Rails의 Unobtrusive JavaScript 기능을 제공하기 위해 jQuery가 기본적으로 필요했습니다. 이제는 UJS가 일반적인 JavaScript를 사용하도록 다시 작성되어 jQuery가 필요하지 않습니다. 이 코드는 이제 Action View 내부에 `rails-ujs`로 제공됩니다.

필요한 경우에는 여전히 jQuery를 사용할 수 있지만, 기본적으로는 필요하지 않습니다.

### 시스템 테스트

[Pull Request](https://github.com/rails/rails/pull/26703)

Rails 5.1은 시스템 테스트라는 형태로 Capybara 테스트를 작성하는 데 내장된 지원을 제공합니다. 이제 Capybara 및 데이터베이스 클리닝 전략을 구성할 필요가 없습니다. Rails 5.1은 Chrome에서 테스트를 실행하기 위한 래퍼를 제공하며, 실패 스크린샷과 같은 추가 기능도 제공합니다.
### 암호화된 비밀

[Pull Request](https://github.com/rails/rails/pull/28038)

Rails는 이제 [sekrets](https://github.com/ahoward/sekrets) 젬에서 영감을 받아 애플리케이션 비밀을 안전하게 관리할 수 있게 되었습니다.

`bin/rails secrets:setup`을 실행하여 새로운 암호화된 비밀 파일을 설정할 수 있습니다. 이는 또한 저장소 외부에 저장되어야 하는 마스터 키를 생성합니다. 비밀 자체는 암호화된 형태로 리비전 컨트롤 시스템에 안전하게 체크인할 수 있습니다.

비밀은 프로덕션에서 `RAILS_MASTER_KEY` 환경 변수나 키 파일에 저장된 키를 사용하여 복호화됩니다.

### 매개변수화된 메일러

[Pull Request](https://github.com/rails/rails/pull/27825)

메일러 클래스의 모든 메소드에 사용되는 공통 매개변수를 지정하여 인스턴스 변수, 헤더 및 기타 공통 설정을 공유할 수 있도록 합니다.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end
end
```

```ruby
InvitationsMailer.with(inviter: person_a, invitee: person_b)
                 .account_invitation.deliver_later
```

### 직접 및 해결된 라우트

[Pull Request](https://github.com/rails/rails/pull/23138)

Rails 5.1은 라우팅 DSL에 `resolve` 및 `direct`라는 두 가지 새로운 메소드를 추가합니다. `resolve` 메소드는 모델의 다형성 매핑을 사용자 정의하는 데 사용됩니다.

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_for @basket do |form| %>
  <!-- basket form -->
<% end %>
```

이렇게 하면 일반적인 `/baskets/:id` 대신 단수 URL `/basket`이 생성됩니다.

`direct` 메소드는 사용자 정의 URL 헬퍼를 생성할 수 있습니다.

```ruby
direct(:homepage) { "https://rubyonrails.org" }

homepage_url # => "https://rubyonrails.org"
```

블록의 반환 값은 `url_for` 메소드에 대한 유효한 인수여야 합니다. 따라서 유효한 문자열 URL, 해시, 배열, Active Model 인스턴스 또는 Active Model 클래스를 전달할 수 있습니다.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### form_for 및 form_tag의 통합 form_with

[Pull Request](https://github.com/rails/rails/pull/26976)

Rails 5.1 이전에는 HTML 폼을 처리하기 위해 두 가지 인터페이스가 있었습니다. 모델 인스턴스에 대한 `form_for`와 사용자 정의 URL에 대한 `form_tag`입니다.

Rails 5.1은 `form_with`를 사용하여 이러한 두 인터페이스를 결합하고 URL, 스코프 또는 모델을 기반으로 폼 태그를 생성할 수 있습니다.

URL만 사용하는 경우:

```erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 다음과 같이 생성됩니다. %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

스코프를 추가하면 입력 필드 이름에 접두사가 붙습니다:

```erb
<%= form_with scope: :post, url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 다음과 같이 생성됩니다. %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```
모델을 사용하면 URL과 범위를 추론합니다:

```erb
<%= form_with model: Post.new do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 다음을 생성합니다 %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

기존 모델은 업데이트 폼을 만들고 필드 값을 채웁니다:

```erb
<%= form_with model: Post.first do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# 다음을 생성합니다 %>

<form action="/posts/1" method="post" data-remote="true">
  <input type="hidden" name="_method" value="patch">
  <input type="text" name="post[title]" value="<게시물 제목>">
</form>
```

호환성
-----------------

다음 변경 사항은 업그레이드 시 즉시 조치가 필요할 수 있습니다.

### 여러 연결을 사용하는 트랜잭션 테스트

트랜잭션 테스트는 이제 모든 Active Record 연결을 데이터베이스 트랜잭션으로 래핑합니다.

테스트가 추가 스레드를 생성하고 해당 스레드가 데이터베이스 연결을 얻는 경우, 해당 연결은 이제 특별하게 처리됩니다:

스레드는 관리되는 트랜잭션 내부에 있는 단일 연결을 공유합니다. 이렇게 하면 모든 스레드가 동일한 상태의 데이터베이스를 볼 수 있으며, 가장 바깥쪽 트랜잭션을 무시합니다. 이전에는 이러한 추가 연결에서 픽스처 행을 볼 수 없었습니다.

스레드가 중첩 트랜잭션에 진입하면 격리를 유지하기 위해 일시적으로 연결의 독점적인 사용권을 얻습니다.

현재 테스트가 생성된 스레드에서 별도의 트랜잭션 외부 연결을 얻는 것에 의존하는 경우, 더 명시적인 연결 관리로 전환해야 합니다.

현재 테스트가 스레드를 생성하고 해당 스레드가 명시적인 데이터베이스 트랜잭션을 사용하면서 상호 작용하는 경우, 이 변경 사항은 교착 상태를 발생시킬 수 있습니다.

이 새로운 동작에서 제외되는 쉬운 방법은 해당 테스트 케이스에서 트랜잭션 테스트를 비활성화하는 것입니다.

Railties
--------

자세한 변경 사항은 [Changelog][railties]를 참조하십시오.

### 제거 사항

*   사용되지 않는 `config.static_cache_control` 제거.
    ([commit](https://github.com/rails/rails/commit/c861decd44198f8d7d774ee6a74194d1ac1a5a13))

*   사용되지 않는 `config.serve_static_files` 제거.
    ([commit](https://github.com/rails/rails/commit/0129ca2eeb6d5b2ea8c6e6be38eeb770fe45f1fa))

*   사용되지 않는 파일 `rails/rack/debugger` 제거.
    ([commit](https://github.com/rails/rails/commit/7563bf7b46e6f04e160d664e284a33052f9804b8))

*   사용되지 않는 작업 제거: `rails:update`, `rails:template`, `rails:template:copy`,
    `rails:update:configs` 및 `rails:update:bin`.
    ([commit](https://github.com/rails/rails/commit/f7782812f7e727178e4a743aa2874c078b722eef))

*   `routes` 작업을 위한 `CONTROLLER` 환경 변수 제거.
    ([commit](https://github.com/rails/rails/commit/f9ed83321ac1d1902578a0aacdfe55d3db754219))

*   `rails new` 명령에서 -j (--javascript) 옵션 제거.
    ([Pull Request](https://github.com/rails/rails/pull/28546))

### 주목할만한 변경 사항

*   모든 환경에서 로드되는 `config/secrets.yml`에 공유 섹션 추가.
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   `config/secrets.yml` 구성 파일은 이제 모든 키를 심볼로 로드합니다.
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   기본 스택에서 jquery-rails 제거. Action View와 함께 제공되는 rails-ujs가 기본 UJS 어댑터로 포함됩니다.
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   새로운 앱에서 yarn binstub과 package.json을 사용하여 Yarn 지원 추가.
    ([Pull Request](https://github.com/rails/rails/pull/26836))

*   `--webpack` 옵션을 통해 새로운 앱에서 Webpack 지원을 추가하고 이를 rails/webpacker 젬에 위임합니다.
    ([Pull Request](https://github.com/rails/rails/pull/27288))
* 새로운 앱을 생성할 때, `--skip-git` 옵션이 제공되지 않으면 Git 저장소를 초기화합니다.
    ([Pull Request](https://github.com/rails/rails/pull/27632))

* `config/secrets.yml.enc`에 암호화된 비밀을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/28038))

* `rails initializers`에서 railtie 클래스 이름을 표시합니다.
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

자세한 변경 사항은 [Changelog][action-cable]를 참조하십시오.

### 주목할만한 변경 사항

* `cable.yml`에서 Redis 및 이벤트 기반 Redis 어댑터에 `channel_prefix` 지원을 추가하여 동일한 Redis 서버를 여러 애플리케이션에서 사용할 때 이름 충돌을 피합니다.
    ([Pull Request](https://github.com/rails/rails/pull/27425))

* 데이터를 브로드캐스트하기 위한 `ActiveSupport::Notifications` 훅을 추가합니다.
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

자세한 변경 사항은 [Changelog][action-pack]를 참조하십시오.

### 제거된 사항

* `ActionDispatch::IntegrationTest` 및 `ActionController::TestCase` 클래스의 `#process`, `#get`, `#post`, `#patch`, `#put`, `#delete`, `#head`에서 키워드가 아닌 인수를 지원하는 기능을 제거했습니다.
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

* `ActionDispatch::Callbacks.to_prepare` 및 `ActionDispatch::Callbacks.to_cleanup`를 제거했습니다.
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

* 컨트롤러 필터와 관련된 메서드를 제거했습니다.
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

* `render`에서 `:text` 및 `:nothing` 지원을 제거했습니다.
    ([Commit](https://github.com/rails/rails/commit/79a5ea9eadb4d43b62afacedc0706cbe88c54496),
    [Commit](https://github.com/rails/rails/commit/57e1c99a280bdc1b324936a690350320a1cd8111))

* `ActionController::Parameters`에서 `HashWithIndifferentAccess` 메서드를 호출하는 기능을 제거했습니다.
    ([Commit](https://github.com/rails/rails/pull/26746/commits/7093ceb480ad6a0a91b511832dad4c6a86981b93))

### 폐지 예정 사항

* `config.action_controller.raise_on_unfiltered_parameters`를 폐지 예정으로 지정했습니다. Rails 5.1에서는 어떠한 효과도 없습니다.
    ([Commit](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### 주목할만한 변경 사항

* 라우팅 DSL에 `direct` 및 `resolve` 메서드를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/23138))

* 응용 프로그램에서 시스템 테스트를 작성하기 위한 새로운 `ActionDispatch::SystemTestCase` 클래스를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

자세한 변경 사항은 [Changelog][action-view]를 참조하십시오.

### 제거된 사항

* `ActionView::Template::Error`의 `#original_exception`을 제거했습니다.
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

* `strip_tags`에서 `encode_special_chars` 옵션을 제거했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### 폐지 예정 사항

* Erubis ERB 핸들러를 Erubi로 대체하기 위해 Erubis ERB 핸들러를 폐지 예정으로 지정했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### 주목할만한 변경 사항

* Raw 템플릿 핸들러(기본 템플릿 핸들러)는 이제 HTML-safe 문자열을 출력합니다.
    ([commit](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

* `datetime_field` 및 `datetime_field_tag`를 `datetime-local` 필드를 생성하도록 변경했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/25469))

* HTML 태그에 대한 새로운 Builder 스타일 구문(`tag.div`, `tag.br` 등)을 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/25543))

* `form_tag` 및 `form_for` 사용법을 통합하기 위해 `form_with`를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/26976))

* `current_page?`에 `check_parameters` 옵션을 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

자세한 변경 사항은 [Changelog][action-mailer]를 참조하십시오.

### 주목할만한 변경 사항

* 첨부 파일이 포함되고 본문이 인라인으로 설정된 경우 사용자 정의 콘텐츠 유형을 설정할 수 있도록 허용했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/27227))

* `default` 메서드에 람다를 값으로 전달할 수 있도록 허용했습니다.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

* 매일러 액션 간에 공유하기 위해 메일러에 매개변수화된 호출 지원을 추가했습니다.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

* 메일러 액션에 대한 인자를 `process.action_mailer` 이벤트의 `args` 키 아래에 전달 인자로 전달했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/27900))

Active Record
-------------

자세한 변경 사항은 [Changelog][active-record]를 참조하십시오.

### 제거된 사항
* `ActiveRecord::QueryMethods#select`에 인수와 블록을 동시에 전달하는 기능이 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

* `activerecord.errors.messages.restrict_dependent_destroy.one` 및 `activerecord.errors.messages.restrict_dependent_destroy.many` i18n 스코프가 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/00e3973a311))

* 단수 및 컬렉션 관련 연관 리더에서 force-reload 인수가 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/09cac8c67af))

* `#quote`에 열을 전달하는 기능이 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/e646bad5b7c))

* `#tables`에서 `name` 인수가 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

* `#tables` 및 `#table_exists?`의 동작이 변경되어 테이블과 뷰를 반환하는 대신 테이블만 반환하도록 변경되었습니다.
    ([커밋](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

* `ActiveRecord::StatementInvalid#initialize` 및 `ActiveRecord::StatementInvalid#original_exception`에서 `original_exception` 인수가 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

* 쿼리에서 클래스를 값으로 전달하는 기능이 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

* LIMIT에서 쉼표를 사용하여 쿼리하는 기능이 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

* `#destroy_all`에서 `conditions` 매개변수가 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/d31a6d1384cd740c8518d0bf695b550d2a3a4e9b))

* `#delete_all`에서 `conditions` 매개변수가 제거되었습니다.
    ([커밋](https://github.com/rails/rails/pull/27503/commits/e7381d289e4f8751dcec9553dcb4d32153bd922b))

* `#load_schema_for` 메서드가 `#load_schema`로 대체되었습니다.
    ([커밋](https://github.com/rails/rails/commit/419e06b56c3b0229f0c72d3e4cdf59d34d8e5545))

* `#raise_in_transactional_callbacks` 구성이 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/8029f779b8a1dd9848fee0b7967c2e0849bf6e07))

* `#use_transactional_fixtures` 구성이 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/3955218dc163f61c932ee80af525e7cd440514b3))

### 폐지 사항

* `error_on_ignored_order_or_limit` 플래그가 `error_on_ignored_order`로 대체되었습니다.
    ([커밋](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

* `sanitize_conditions`가 `sanitize_sql`로 대체되었습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/25999))

* 연결 어댑터에서 `supports_migrations?`가 폐지되었습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/28172))

* `Migrator.schema_migrations_table_name`이 `SchemaMigration.table_name`으로 대체되었습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/28351))

* 인용 및 형 변환에 `#quoted_id`를 사용하는 것이 폐지되었습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/27962))

* `#index_name_exists?`에 `default` 인수를 전달하는 것이 폐지되었습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/26930))

### 주목할만한 변경 사항

* 기본 기본 키를 BIGINT로 변경했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/26266))

* MySQL 5.7.5+ 및 MariaDB 5.2.0+에서 가상/생성된 컬럼을 지원합니다.
    ([커밋](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

* 일괄 처리에서 제한을 지원하도록 추가되었습니다.
    ([커밋](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

* 트랜잭션 테스트는 이제 모든 Active Record 연결을 데이터베이스 트랜잭션으로 래핑합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/28726))

* `mysqldump` 명령어의 출력에서 주석을 기본적으로 건너뜁니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/23301))

* `ActiveRecord::Relation#count`를 개선하여 레코드를 세는 데 블록이 전달되면 Ruby의 `Enumerable#count`를 사용하도록 변경되었습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/24203))

* SQL 오류를 억제하지 않기 위해 `psql` 명령에 `"-v ON_ERROR_STOP=1"` 플래그를 전달합니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/24773))

* `ActiveRecord::Base.connection_pool.stat`을 추가했습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/26988))

* `ActiveRecord::Migration`에서 직접 상속하면 오류가 발생합니다.
    마이그레이션이 작성된 Rails 버전을 지정하세요.
    ([커밋](https://github.com/rails/rails/commit/249f71a22ab21c03915da5606a063d321f04d4d3))

* `through` 연관이 모호한 반영 이름을 가지고 있을 때 오류가 발생합니다.
    ([커밋](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

자세한 변경 사항은 [변경 로그][active-model]를 참조하세요.

### 제거 사항

* `ActiveModel::Errors`에서 폐지된 메서드가 제거되었습니다.
    ([커밋](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

* 길이 유효성 검사기에서 `:tokenizer` 옵션이 폐지되었습니다.
    ([커밋](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

* 콜백의 반환 값이 false일 때 콜백을 중단하는 동작이 폐지되었습니다.
    ([커밋](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### 주목할만한 변경 사항

* 모델 속성에 할당된 원래 문자열이 더 이상 잘못되게 동결되지 않습니다.
    ([풀 리퀘스트](https://github.com/rails/rails/pull/28729))

[active-model]: https://github.com/rails/rails/blob/master/activemodel/CHANGELOG.md
액티브 잡
-----------

자세한 변경 사항은 [Changelog][active-job]를 참조하십시오.

### 삭제 사항

*   `.queue_adapter`에 어댑터 클래스를 전달하는 것에 대한 지원이 폐기되었습니다.
    ([commit](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   `ActiveJob::DeserializationError`에서 `#original_exception`이 폐기되었습니다.
    ([commit](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### 주목할만한 변경 사항

*   `ActiveJob::Base.retry_on` 및 `ActiveJob::Base.discard_on`을 통해 선언적 예외 처리가 추가되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/25991))

*   재시도가 실패한 후에 사용자 정의 로직에서 `job.arguments`와 같은 것에 액세스 할 수 있도록 작업 인스턴스를 제공합니다.
    ([commit](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

액티브 서포트
--------------

자세한 변경 사항은 [Changelog][active-support]를 참조하십시오.

### 삭제 사항

*   `ActiveSupport::Concurrency::Latch` 클래스가 제거되었습니다.
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   `halt_callback_chains_on_return_false`가 제거되었습니다.
    ([Commit](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))

*   반환 값이 false인 경우 콜백을 중단하는 폐기된 동작이 제거되었습니다.
    ([Commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### 폐기 사항

*   최상위 `HashWithIndifferentAccess` 클래스가 `ActiveSupport::HashWithIndifferentAccess`를 선호하도록 약간 폐기되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/28157))

*   `set_callback` 및 `skip_callback`의 `:if` 및 `:unless` 조건 옵션에 문자열을 전달하는 것이 폐기되었습니다.
    ([Commit](https://github.com/rails/rails/commit/0952552))

### 주목할만한 변경 사항

*   DST 변경을 통해 일관된 지속 시간 구문 분석 및 이동을 수정했습니다.
    ([Commit](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [Pull Request](https://github.com/rails/rails/pull/26597))

*   Unicode를 버전 9.0.0으로 업데이트했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/27822))

*   #ago 및 #since에 대한 별칭으로 Duration#before 및 #after를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/27721))

*   현재 객체에 정의되지 않은 메소드 호출을 프록시 객체로 위임하기 위해 `Module#delegate_missing_to`를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/23930))

*   현재 날짜 및 시간의 전체 날짜를 나타내는 범위를 반환하는 `Date#all_day`를 추가했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/24930))

*   테스트를 위한 `assert_changes` 및 `assert_no_changes` 메소드를 도입했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/25393))

*   `travel` 및 `travel_to` 메소드는 이제 중첩 호출 시 예외를 발생시킵니다.
    ([Pull Request](https://github.com/rails/rails/pull/24890))

*   `DateTime#change`를 usec 및 nsec를 지원하도록 업데이트했습니다.
    ([Pull Request](https://github.com/rails/rails/pull/28242))

크레딧
-------

Rails에 많은 시간을 투자한 많은 사람들을 위해 [Rails 기여자 전체 목록](https://contributors.rubyonrails.org/)을 참조하십시오. 모두에게 경의를 표합니다.

[railties]:       https://github.com/rails/rails/blob/5-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-1-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
