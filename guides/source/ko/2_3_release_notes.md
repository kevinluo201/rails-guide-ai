**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 77b47af4826df984dead9f6263cfd135
루비 온 레일즈 2.3 릴리스 노트
===============================

레일즈 2.3은 랙 통합, 레일즈 엔진에 대한 새로운 지원, 액티브 레코드를 위한 중첩 트랜잭션, 동적 및 기본 스코프, 통합 렌더링, 더 효율적인 라우팅, 애플리케이션 템플릿 및 조용한 백트레이스 등 다양한 새로운 기능과 개선된 기능을 제공합니다. 이 목록은 주요 업그레이드를 다루지만 모든 작은 버그 수정과 변경 사항을 포함하지는 않습니다. 모든 것을 보려면 GitHub의 주요 레일즈 저장소의 [커밋 목록](https://github.com/rails/rails/commits/2-3-stable)을 확인하거나 개별 레일즈 구성 요소의 `CHANGELOG` 파일을 검토하십시오.

--------------------------------------------------------------------------------

애플리케이션 아키텍처
------------------------

레일즈 애플리케이션의 아키텍처에는 두 가지 주요 변경 사항이 있습니다: [Rack](https://rack.github.io/) 모듈식 웹 서버 인터페이스의 완전한 통합 및 레일즈 엔진에 대한 새로운 지원입니다.

### Rack 통합

레일즈는 이제 CGI 과거와 결별하고 모든 곳에서 Rack을 사용합니다. 이로 인해 많은 내부 변경 사항이 필요하고 발생했습니다 (하지만 CGI를 사용하는 경우 걱정하지 마세요. 레일즈는 이제 프록시 인터페이스를 통해 CGI를 지원합니다). 그래도 이는 레일즈 내부의 주요 변경 사항입니다. 2.3으로 업그레이드한 후에는 로컬 환경과 프로덕션 환경에서 테스트해야 합니다. 테스트해야 할 몇 가지 사항은 다음과 같습니다.

* 세션
* 쿠키
* 파일 업로드
* JSON/XML API

다음은 랙 관련 변경 사항의 요약입니다.

* `script/server`가 Rack을 사용하도록 변경되었으며, 이는 모든 Rack 호환 서버를 지원합니다. `script/server`는 rackup 구성 파일이 있는 경우 해당 파일을 사용합니다. 기본적으로 `config.ru` 파일을 찾지만 `-c` 스위치로 이를 재정의할 수 있습니다.
* FCGI 핸들러가 Rack을 통해 실행됩니다.
* `ActionController::Dispatcher`는 자체 기본 미들웨어 스택을 유지합니다. 미들웨어를 삽입, 재정렬 및 제거할 수 있습니다. 스택은 부팅 시 체인으로 컴파일됩니다. 미들웨어 스택은 `environment.rb`에서 구성할 수 있습니다.
* `rake middleware` 작업이 추가되어 미들웨어 스택을 검사할 수 있습니다. 이는 미들웨어 스택의 순서를 디버깅하는 데 유용합니다.
* 통합 테스트 러너가 전체 미들웨어 및 애플리케이션 스택을 실행하도록 수정되었습니다. 이로 인해 통합 테스트는 Rack 미들웨어를 테스트하는 데 완벽합니다.
* `ActionController::CGIHandler`는 Rack을 통해 역호환성 있는 CGI 래퍼입니다. `CGIHandler`는 이전 CGI 개체를 가져와 해당 환경 정보를 Rack 호환 형식으로 변환합니다.
* `CgiRequest` 및 `CgiResponse`가 제거되었습니다.
* 세션 스토어는 이제 지연로드됩니다. 요청 중에 세션 개체에 액세스하지 않으면 세션 데이터를 로드하지 않습니다 (쿠키 구문 분석, 메모리 캐시에서 데이터 로드 또는 Active Record 개체 조회).
* 쿠키 값을 설정하기 위해 테스트에서 더 이상 `CGI::Cookie.new`를 사용할 필요가 없습니다. `request.cookies["foo"]`에 `String` 값을 할당하면 쿠키가 예상대로 설정됩니다.
* `CGI::Session::CookieStore`는 `ActionController::Session::CookieStore`로 대체되었습니다.
* `CGI::Session::MemCacheStore`는 `ActionController::Session::MemCacheStore`로 대체되었습니다.
* `CGI::Session::ActiveRecordStore`는 `ActiveRecord::SessionStore`로 대체되었습니다.
* `ActionController::Base.session_store = :active_record_store`를 사용하여 세션 스토어를 변경할 수 있습니다.
* 기본 세션 옵션은 여전히 `ActionController::Base.session = { :key => "..." }`로 설정됩니다. 그러나 `:session_domain` 옵션은 `:domain`으로 이름이 변경되었습니다.
* 일반적으로 요청 전체를 래핑하는 뮤텍스가 미들웨어인 `ActionController::Lock`으로 이동되었습니다.
* `ActionController::AbstractRequest`와 `ActionController::Request`가 통합되었습니다. 새로운 `ActionController::Request`는 `Rack::Request`에서 상속됩니다. 이는 테스트 요청에서 `response.headers['type']`에 대한 액세스에 영향을 줍니다. 대신 `response.content_type`을 사용하십시오.
* `ActiveRecord::QueryCache` 미들웨어는 `ActiveRecord`가 로드된 경우 자동으로 미들웨어 스택에 삽입됩니다. 이 미들웨어는 요청 당 Active Record 쿼리 캐시를 설정하고 플러시합니다.
* 레일즈 라우터와 컨트롤러 클래스는 Rack 사양을 따릅니다. `SomeController.call(env)`와 같이 컨트롤러를 직접 호출할 수 있습니다. 라우터는 라우팅 매개변수를 `rack.routing_args`에 저장합니다.
* `ActionController::Request`는 `Rack::Request`에서 상속됩니다.
* `config.action_controller.session = { :session_key => 'foo', ...` 대신 `config.action_controller.session = { :key => 'foo', ...`를 사용하십시오.
* `ParamsParser` 미들웨어를 사용하면 XML, JSON 또는 YAML 요청을 사전 처리하여 이후에 `Rack::Request` 개체로 정상적으로 읽을 수 있습니다.

### 레일즈 엔진에 대한 새로운 지원

일부 업그레이드 없이 몇 가지 버전이 지난 후, 레일즈 2.3은 레일즈 엔진(다른 애플리케이션에 포함될 수 있는 레일즈 애플리케이션)에 대한 새로운 기능을 제공합니다. 첫째, 엔진의 라우팅 파일은 이제 자동으로 로드되고 다시 로드됩니다. 마치 `routes.rb` 파일처럼 (이는 다른 플러그인의 라우팅 파일에도 적용됩니다). 둘째, 플러그인에 app 폴더가 있는 경우 app/[models|controllers|helpers]가 자동으로 레일즈 로드 경로에 추가됩니다. 엔진은 이제 뷰 경로를 추가하는 것도 지원하며, 액션 메일러 및 액션 뷰도 엔진 및 다른 플러그인의 뷰를 사용합니다.
문서
-------------

[Ruby on Rails 가이드](https://guides.rubyonrails.org/) 프로젝트는 Rails 2.3을 위해 여러 가이드를 출판했습니다. 또한, [별도의 사이트](https://edgeguides.rubyonrails.org/)에서 Edge Rails를 위한 가이드의 최신 사본을 유지합니다. 다른 문서 작업에는 [Rails 위키](http://newwiki.rubyonrails.org/)의 재시작 및 Rails Book을 위한 초기 계획이 포함됩니다.

* 더 많은 정보: [Rails 문서 프로젝트](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)

Ruby 1.9.1 지원
------------------

Rails 2.3은 Ruby 1.8 또는 최신 버전인 Ruby 1.9.1에서 실행 중인 경우 자체 테스트를 모두 통과해야 합니다. 그러나 1.9.1로 전환하는 경우, Ruby 1.9.1 호환성을 위해 데이터 어댑터, 플러그인 및 기타 종속 코드뿐만 아니라 Rails 코어도 확인해야 합니다.

Active Record
-------------

Rails 2.3에서 Active Record는 많은 새로운 기능과 버그 수정을 제공합니다. 주요 기능으로는 중첩된 속성, 중첩된 트랜잭션, 동적 및 기본 스코프, 일괄 처리가 포함됩니다.

### 중첩된 속성

Active Record는 이제 중첩된 모델의 속성을 직접 업데이트할 수 있도록 지원합니다. 다음과 같이 지정하면 됩니다:

```ruby
class Book < ActiveRecord::Base
  has_one :author
  has_many :pages

  accepts_nested_attributes_for :author, :pages
end
```

중첩된 속성을 활성화하면 다음과 같은 기능이 가능해집니다: 연관된 자식 레코드와 함께 레코드의 자동 (및 원자적) 저장, 자식에 대한 유효성 검사 및 중첩된 폼 지원(나중에 설명함).

또한 `:reject_if` 옵션을 사용하여 중첩된 속성을 통해 추가된 새 레코드에 대한 요구 사항을 지정할 수도 있습니다:

```ruby
accepts_nested_attributes_for :author,
  :reject_if => proc { |attributes| attributes['name'].blank? }
```

* 주요 기여자: [Eloy Duran](http://superalloy.nl/)
* 더 많은 정보: [중첩된 모델 폼](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)

### 중첩된 트랜잭션

Active Record는 이제 많이 요청된 기능인 중첩된 트랜잭션을 지원합니다. 이제 다음과 같은 코드를 작성할 수 있습니다:

```ruby
User.transaction do
  User.create(:username => 'Admin')
  User.transaction(:requires_new => true) do
    User.create(:username => 'Regular')
    raise ActiveRecord::Rollback
  end
end

User.find(:all)  # => Admin만 반환
```

중첩된 트랜잭션을 사용하면 내부 트랜잭션을 롤백할 때 외부 트랜잭션의 상태에는 영향을 주지 않습니다. 트랜잭션을 중첩하려면 `:requires_new` 옵션을 명시적으로 추가해야 합니다. 그렇지 않으면 중첩된 트랜잭션은 현재 Rails 2.2에서처럼 부모 트랜잭션의 일부가 됩니다. 내부적으로 중첩된 트랜잭션은 [savepoints를 사용](http://rails.lighthouseapp.com/projects/8994/tickets/383)하여 실제로 중첩된 트랜잭션을 지원하지 않는 데이터베이스에서도 지원됩니다. 또한 테스트 중에 트랜잭션 픽스처와 잘 작동하도록 이러한 트랜잭션을 잘 처리하기 위해 약간의 마법이 사용됩니다.

* 주요 기여자: [Jonathan Viney](http://www.workingwithrails.com/person/4985-jonathan-viney) 및 [Hongli Lai](http://izumi.plan99.net/blog/)

### 동적 스코프

Rails에서 동적 패인더(동적으로 `find_by_color_and_flavor`와 같은 메소드를 만들 수 있는 기능)와 네임드 스코프(재사용 가능한 쿼리 조건을 친숙한 이름으로 캡슐화할 수 있는 기능)에 대해 알고 있을 것입니다. 이제 동적 스코프 메소드를 사용할 수 있습니다. 아이디어는 실시간으로 필터링과 메소드 체이닝을 모두 가능하게 하는 구문을 조합하는 것입니다. 예를 들어:

```ruby
Order.scoped_by_customer_id(12)
Order.scoped_by_customer_id(12).find(:all,
  :conditions => "status = 'open'")
Order.scoped_by_customer_id(12).scoped_by_status("open")
```

동적 스코프를 사용하기 위해 정의할 필요는 없습니다. 그저 작동합니다.

* 주요 기여자: [Yaroslav Markin](http://evilmartians.com/)
* 더 많은 정보: [Edge Rails의 새로운 기능: 동적 스코프 메소드](http://archives.ryandaigle.com/articles/2008/12/29/what-s-new-in-edge-rails-dynamic-scope-methods)

### 기본 스코프

Rails 2.3에서는 네임드 스코프와 유사한 _기본 스코프_ 개념을 도입할 예정입니다. 이는 모델 내의 모든 네임드 스코프 또는 find 메소드에 적용됩니다. 예를 들어, `default_scope :order => 'name ASC'`와 같이 작성하면 해당 모델에서 레코드를 검색할 때마다 이름으로 정렬된 상태로 반환됩니다(옵션을 재정의하지 않는 한).

* 주요 기여자: Paweł Kondzior
* 더 많은 정보: [Edge Rails의 새로운 기능: 기본 스코핑](http://archives.ryandaigle.com/articles/2008/11/18/what-s-new-in-edge-rails-default-scoping)

### 일괄 처리

`find_in_batches`를 사용하여 Active Record 모델에서 대량의 레코드를 메모리에 덜 사용하고 처리할 수 있습니다:

```ruby
Customer.find_in_batches(:conditions => {:active => true}) do |customer_group|
  customer_group.each { |customer| customer.update_account_balance! }
end
```

`find_in_batches`에 대부분의 `find` 옵션을 전달할 수 있습니다. 그러나 레코드가 반환되는 순서를 지정할 수 없으며(기본적으로 기본 키의 오름차순으로 반환됩니다. 기본 키는 정수여야 함), `:limit` 옵션을 사용할 수 없습니다. 대신, 각 일괄 처리에서 반환되는 레코드 수를 설정하기 위해 `:batch_size` 옵션을 사용합니다(기본값은 1000입니다).

새로운 `find_each` 메소드는 `find_in_batches`를 감싸고 개별 레코드를 반환하며, 기본적으로 일괄 처리로 검색을 수행합니다(기본값은 1000입니다):

```ruby
Customer.find_each do |customer|
  customer.update_account_balance!
end
```
이 방법은 일괄 처리에만 사용해야 함을 유의하십시오. 작은 레코드 수 (1000개 미만)의 경우에는 일반적인 find 메서드를 사용하고 자체 루프를 사용해야 합니다.

* 자세한 정보 (그 당시 편의 메서드는 'each'로 호출되었습니다):
    * [Rails 2.3: 일괄 검색](http://afreshcup.com/2009/02/23/rails-23-batch-finding/)
    * [Edge Rails의 새로운 기능: 일괄 검색](http://archives.ryandaigle.com/articles/2009/2/23/what-s-new-in-edge-rails-batched-find)

### 콜백에 대한 다중 조건

Active Record 콜백을 사용할 때, 이제 동일한 콜백에 `:if`와 `:unless` 옵션을 결합하고 배열로 여러 조건을 제공할 수 있습니다:

```ruby
before_save :update_credit_rating, :if => :active,
  :unless => [:admin, :cash_only]
```
* 주요 기여자: L. Caviola

### HAVING 절을 사용한 검색

Rails는 이제 그룹화된 검색에서 레코드를 필터링하기 위해 `find`에 `:having` 옵션을 가지고 있습니다. SQL에 대한 깊은 이해를 가진 사람들은 이를 통해 그룹화된 결과를 기반으로 필터링할 수 있음을 알고 있습니다:

```ruby
developers = Developer.find(:all, :group => "salary",
  :having => "sum(salary) > 10000", :select => "salary")
```

* 주요 기여자: [Emilio Tagua](https://github.com/miloops)

### MySQL 연결 재연결

MySQL은 연결에 재연결 플래그를 지원합니다. 이 플래그가 true로 설정되면, 클라이언트는 연결이 끊어진 경우 포기하기 전에 서버에 재연결을 시도합니다. Rails 애플리케이션에서 이 동작을 얻기 위해 `database.yml`에서 MySQL 연결에 `reconnect = true`를 설정할 수 있습니다. 기본값은 `false`이므로 기존 애플리케이션의 동작은 변경되지 않습니다.

* 주요 기여자: [Dov Murik](http://twitter.com/dubek)
* 자세한 정보:
    * [자동 재연결 동작 제어](http://dev.mysql.com/doc/refman/5.6/en/auto-reconnect.html)
    * [MySQL 자동 재연결 재고](http://groups.google.com/group/rubyonrails-core/browse_thread/thread/49d2a7e9c96cb9f4)

### 기타 Active Record 변경 사항

* 일부 데이터베이스에서 `has_and_belongs_to_many` 사전로드를 위해 생성된 SQL에서 추가된 `AS`가 제거되어 더 잘 작동하도록 되었습니다.
* `ActiveRecord::Base#new_record?`는 이제 기존 레코드와 마주칠 때 `nil` 대신 `false`를 반환합니다.
* 일부 `has_many :through` 연관에서 테이블 이름을 인용하는 버그가 수정되었습니다.
* 이제 `updated_at` 타임스탬프에 특정한 타임스탬프를 지정할 수 있습니다: `cust = Customer.create(:name => "ABC Industries", :updated_at => 1.day.ago)`
* 실패한 `find_by_attribute!` 호출에 대한 더 나은 오류 메시지.
* Active Record의 `to_xml` 지원은 `:camelize` 옵션의 추가로 약간 더 유연해졌습니다.
* `before_update` 또는 `before_create`에서 콜백을 취소하는 버그가 수정되었습니다.
* JDBC를 통해 데이터베이스를 테스트하기 위한 Rake 작업이 추가되었습니다.
* `validates_length_of`는 `:in` 또는 `:within` 옵션과 함께 사용자 정의 오류 메시지를 사용할 수 있습니다 (제공된 경우).
* 스코프된 선택에서 카운트가 제대로 작동하므로 `Account.scoped(:select => "DISTINCT credit_limit").count`와 같은 작업을 수행할 수 있습니다.
* `ActiveRecord::Base#invalid?`는 이제 `ActiveRecord::Base#valid?`의 반대로 작동합니다.

Action Controller
-----------------

이 릴리스에서 Action Controller는 렌더링, 라우팅 및 기타 영역에서 몇 가지 중요한 변경 사항을 도입합니다.

### 통합된 렌더링

`ActionController::Base#render`는 렌더링에 대해 더 똑똑해졌습니다. 이제 렌더링할 내용을 알려주기만 하면 올바른 결과를 얻을 수 있습니다. 이전 버전의 Rails에서는 렌더링에 명시적인 정보를 제공해야 하는 경우가 많았습니다:

```ruby
render :file => '/tmp/random_file.erb'
render :template => 'other_controller/action'
render :action => 'show'
```

이제 Rails 2.3에서는 렌더링할 내용만 제공하면 됩니다:

```ruby
render '/tmp/random_file.erb'
render 'other_controller/action'
render 'show'
render :show
```

Rails는 렌더링할 내용에 선행 슬래시, 내장 슬래시 또는 슬래시가 없는지에 따라 파일, 템플릿 및 액션 중에서 선택합니다. 액션을 렌더링할 때 문자열 대신 심볼을 사용할 수도 있습니다. 다른 렌더링 스타일(`:inline`, `:text`, `:update`, `:nothing`, `:json`, `:xml`, `:js`)은 여전히 명시적인 옵션이 필요합니다.

### Application Controller 이름 변경

`application.rb`의 특수한 이름 지정에 항상 괴로워했던 사람 중 하나라면 기뻐하십시오! Rails 2.3에서는 `application_controller.rb`로 변경되었습니다. 또한 `rake rails:update:application_controller`라는 새로운 rake 작업이 추가되어 자동으로 수행되며, 일반적인 `rake rails:update` 프로세스의 일부로 실행됩니다.

* 자세한 정보:
    * [application.rb의 사망](https://afreshcup.com/home/2008/11/17/rails-2x-the-death-of-applicationrb)
    * [Edge Rails의 새로운 기능: Application.rb의 이중성은 더 이상 없음](http://archives.ryandaigle.com/articles/2008/11/19/what-s-new-in-edge-rails-application-rb-duality-is-no-more)

### HTTP 다이제스트 인증 지원

Rails는 이제 HTTP 다이제스트 인증을 내장 지원합니다. 사용하려면, 전송된 자격 증명과 해시된 비밀번호를 비교하기 위해 사용자의 비밀번호를 반환하는 블록을 인수로 하는 `authenticate_or_request_with_http_digest`를 호출하면 됩니다:

```ruby
class PostsController < ApplicationController
  Users = {"dhh" => "secret"}
  before_filter :authenticate

  def secret
    render :text => "Password Required!"
  end

  private
  def authenticate
    realm = "Application"
    authenticate_or_request_with_http_digest(realm) do |name|
      Users[name]
    end
  end
end
```
* 주요 기여자: [Gregg Kellogg](http://www.kellogg-assoc.com/)
* 추가 정보: [Edge Rails의 새로운 기능: HTTP Digest 인증](http://archives.ryandaigle.com/articles/2009/1/30/what-s-new-in-edge-rails-http-digest-authentication)

### 더 효율적인 라우팅

Rails 2.3에서는 몇 가지 중요한 라우팅 변경 사항이 있습니다. `formatted_` 라우트 헬퍼가 사라지고, 옵션으로 `:format`을 전달하는 것을 선호합니다. 이렇게 하면 모든 리소스의 라우트 생성 프로세스가 50% 줄어들며, 메모리를 상당히 절약할 수 있습니다(대형 애플리케이션에서 최대 100MB까지). 코드가 `formatted_` 헬퍼를 사용하는 경우, 현재로서는 여전히 작동하지만 이 동작은 사용 중지되었으며, 새로운 표준을 사용하여 해당 라우트를 다시 작성하면 애플리케이션이 더 효율적으로 동작합니다. 또 다른 큰 변경 사항은 Rails가 이제 `routes.rb`뿐만 아니라 여러 개의 라우팅 파일을 지원한다는 것입니다. `RouteSet#add_configuration_file`을 사용하여 언제든지 추가로 라우트를 가져올 수 있으며, 현재로드된 라우트를 지우지 않고 사용할 수 있습니다. 이 변경 사항은 주로 엔진에 유용하지만, 일괄적으로 라우트를 로드해야 하는 모든 애플리케이션에서 사용할 수 있습니다.

* 주요 기여자: [Aaron Batalion](http://blog.hungrymachine.com/)

### Rack 기반의 지연 로드 세션

Action Controller 세션 저장소의 기반을 Rack 수준으로 옮기는 큰 변경 사항이 있었습니다. 이 작업에는 코드에서 많은 작업이 필요했지만, Rails 애플리케이션에는 완전히 투명하게 적용될 것입니다(보너스로 이전 CGI 세션 핸들러에 대한 약간의 패치가 제거되었습니다). 그러나 단 한 가지 이유로 여전히 중요합니다: 비-Rails Rack 애플리케이션은 Rails 애플리케이션과 동일한 세션 저장소 핸들러(따라서 동일한 세션)에 액세스할 수 있습니다. 또한, 세션은 이제 지연 로드됩니다(프레임워크의 나머지 부분과 일관성을 유지하기 위해). 이는 더 이상 세션을 명시적으로 비활성화할 필요가 없다는 것을 의미합니다. 그냥 세션을 참조하지 않으면 로드되지 않습니다.

### MIME 유형 처리 변경 사항

Rails에서 MIME 유형을 처리하는 코드에 몇 가지 변경 사항이 있습니다. 첫째, `MIME::Type`은 이제 `=~` 연산자를 구현하여 유형의 존재를 확인해야 할 때 훨씬 깔끔하게 만들어줍니다:

```ruby
if content_type && Mime::JS =~ content_type
  # 멋진 작업 수행
end

Mime::JS =~ "text/javascript"        => true
Mime::JS =~ "application/javascript" => true
```

다른 변경 사항은 프레임워크가 다양한 위치에서 JavaScript를 확인할 때 이제 `Mime::JS`를 사용하여 대체 유형을 깔끔하게 처리한다는 것입니다.

* 주요 기여자: [Seth Fitzsimmons](http://www.workingwithrails.com/person/5510-seth-fitzsimmons)

### `respond_to`의 최적화

Rails 2.3에서는 Rails-Merb 팀 합병의 첫 번째 성과 중 일부로, `respond_to` 메서드에 대한 최적화가 포함되어 있습니다. 이 메서드는 많은 Rails 애플리케이션에서 사용되어 컨트롤러가 수신 요청의 MIME 유형에 따라 결과를 다르게 포맷할 수 있도록 합니다. `method_missing` 호출을 제거하고 프로파일링과 조정을 통해, 세 가지 형식으로 전환하는 간단한 `respond_to`에서 초당 서비스되는 요청 수가 8% 향상되었습니다. 가장 좋은 점은 이 속도 향상을 활용하기 위해 애플리케이션 코드에 전혀 변경이 필요하지 않다는 것입니다.

### 개선된 캐싱 성능

Rails는 이제 원격 캐시 저장소에서 읽은 내용을 요청당 지역 캐시로 유지하여 불필요한 읽기를 줄이고 사이트 성능을 향상시킵니다. 이 작업은 원래 `MemCacheStore`에만 제한되었지만, 필요한 메서드를 구현하는 모든 원격 저장소에서 사용할 수 있습니다.

* 주요 기여자: [Nahum Wild](http://www.motionstandingstill.com/)

### 지역화된 뷰

Rails는 설정한 로케일에 따라 지역화된 뷰를 제공할 수 있습니다. 예를 들어, `Posts` 컨트롤러에 `show` 액션이 있다고 가정해보겠습니다. 기본적으로 이는 `app/views/posts/show.html.erb`를 렌더링합니다. 그러나 `I18n.locale = :da`로 설정하면 `app/views/posts/show.da.html.erb`를 렌더링합니다. 지역화된 템플릿이 없는 경우에는 원본 버전이 사용됩니다. Rails는 또한 현재 Rails 프로젝트에서 사용 가능한 번역 배열을 반환하는 `I18n#available_locales` 및 `I18n::SimpleBackend#available_locales`를 포함합니다.

또한, 동일한 체계를 사용하여 public 디렉토리의 rescue 파일도 지역화할 수 있습니다. 예를 들어, `public/500.da.html` 또는 `public/404.en.html`과 같이 작업합니다.

### 부분 스코핑을 위한 번역

번역 API의 변경으로 부분 내에서 키 번역을 작성하기가 더 쉽고 반복적이지 않습니다. `people/index.html.erb` 템플릿에서 `translate(".foo")`를 호출하면 실제로 `I18n.translate("people.index.foo")`를 호출하게 됩니다. 키 앞에 점을 붙이지 않으면 API가 스코프되지 않습니다. 이전과 마찬가지로.
### 기타 액션 컨트롤러 변경 사항

* ETag 처리가 약간 정리되었습니다. 더 이상 응답에 본문이 없거나 `send_file`을 사용하여 파일을 보낼 때 ETag 헤더를 보내지 않습니다.
* Rails는 IP 스푸핑을 확인하는 사실이 일반적으로 올바르게 설정되지 않은 휴대 전화와의 무거운 트래픽을 처리하는 사이트에 불편을 줄 수 있습니다. 이 경우 `ActionController::Base.ip_spoofing_check = false`를 설정하여 확인을 완전히 비활성화 할 수 있습니다.
* `ActionController::Dispatcher`는 이제 자체 미들웨어 스택을 구현하며, `rake middleware`를 실행하여 확인할 수 있습니다.
* 쿠키 세션은 이제 지속적인 세션 식별자를 가지며, 서버 측 저장소와 API 호환성을 가지고 있습니다.
* 이제 `send_file` 및 `send_data`의 `:type` 옵션에 심볼을 사용할 수 있습니다. 예를 들어 `send_file("fabulous.png", :type => :png)`와 같이 사용할 수 있습니다.
* `map.resources`의 `:only` 및 `:except` 옵션은 중첩된 리소스에서 더 이상 상속되지 않습니다.
* 번들된 memcached 클라이언트가 버전 1.6.4.99로 업데이트되었습니다.
* `expires_in`, `stale?`, `fresh_when` 메서드는 이제 프록시 캐싱과 잘 작동하도록 `:public` 옵션을 허용합니다.
* `:requirements` 옵션은 추가적인 RESTful 멤버 라우트와 제대로 작동합니다.
* Shallow 라우트는 이제 네임스페이스를 올바르게 존중합니다.
* `polymorphic_url`은 불규칙한 복수형 이름을 가진 객체를 더 잘 처리합니다.

액션 뷰
-----------

Rails 2.3의 액션 뷰는 중첩된 모델 폼, `render`의 개선, 날짜 선택 도우미에 대한 유연한 프롬프트 등 다양한 기능 개선을 제공합니다.

### 중첩된 객체 폼

부모 모델이 자식 객체에 대한 중첩된 속성을 허용하는 경우 (Active Record 섹션에서 설명한 대로), `form_for` 및 `field_for`를 사용하여 중첩된 폼을 생성할 수 있습니다. 이러한 폼은 임의로 깊게 중첩될 수 있으므로, 과도한 코드 없이 단일 뷰에서 복잡한 객체 계층 구조를 편집할 수 있습니다. 예를 들어, 다음과 같은 모델이 주어진 경우:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders

  accepts_nested_attributes_for :orders, :allow_destroy => true
end
```

Rails 2.3에서 다음과 같은 뷰를 작성할 수 있습니다:

```html+erb
<% form_for @customer do |customer_form| %>
  <div>
    <%= customer_form.label :name, 'Customer Name:' %>
    <%= customer_form.text_field :name %>
  </div>

  <!-- 여기서는 customer_form 빌더 인스턴스에 대해 fields_for를 호출합니다.
   블록은 주문 컬렉션의 각 멤버에 대해 호출됩니다. -->
  <% customer_form.fields_for :orders do |order_form| %>
    <p>
      <div>
        <%= order_form.label :number, 'Order Number:' %>
        <%= order_form.text_field :number %>
      </div>

  <!-- 모델의 allow_destroy 옵션을 통해 자식 레코드를 삭제할 수 있습니다. -->
      <% unless order_form.object.new_record? %>
        <div>
          <%= order_form.label :_delete, 'Remove:' %>
          <%= order_form.check_box :_delete %>
        </div>
      <% end %>
    </p>
  <% end %>

  <%= customer_form.submit %>
<% end %>
```

* 주요 기여자: [Eloy Duran](http://superalloy.nl/)
* 자세한 정보:
    * [중첩된 모델 폼](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)
    * [complex-form-examples](https://github.com/alloy/complex-form-examples)
    * [Edge Rails의 새로운 기능: 중첩된 객체 폼](http://archives.ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes)

### 부분 렌더링의 스마트한 처리

`render` 메서드는 지난 몇 년 동안 계속 더욱 똑똑해지고 있으며, 이제는 더욱 더 똑똑해졌습니다. 객체나 컬렉션과 적절한 부분 뷰가 있고, 네이밍이 일치하는 경우, 이제는 객체를 그대로 렌더링하면 작동합니다. 예를 들어, Rails 2.3에서는 다음과 같은 렌더링 호출이 뷰에서 작동합니다 (합리적인 네이밍을 가정합니다):

```ruby
# render :partial => 'articles/_article',
# :object => @article에 해당하는 것과 동일합니다.
render @article

# render :partial => 'articles/_article',
# :collection => @articles에 해당하는 것과 동일합니다.
render @articles
```

* 자세한 정보: [Edge Rails의 새로운 기능: render가 더 이상 고려되지 않음](http://archives.ryandaigle.com/articles/2008/11/20/what-s-new-in-edge-rails-render-stops-being-high-maintenance)

### 날짜 선택 도우미에 대한 프롬프트

Rails 2.3에서는 날짜 선택 도우미 (`date_select`, `time_select`, `datetime_select`)에 대해 커스텀 프롬프트를 제공할 수 있습니다. 컬렉션 선택 도우미와 마찬가지로 프롬프트 문자열이나 각 구성 요소에 대한 개별 프롬프트 문자열의 해시를 제공할 수 있습니다. 또는 `:prompt`를 `true`로 설정하여 사용자 정의 일반 프롬프트를 사용할 수도 있습니다:

```ruby
select_datetime(DateTime.now, :prompt => true)

select_datetime(DateTime.now, :prompt => "Choose date and time")

select_datetime(DateTime.now, :prompt =>
  {:day => 'Choose day', :month => 'Choose month',
   :year => 'Choose year', :hour => 'Choose hour',
   :minute => 'Choose minute'})
```

* 주요 기여자: [Sam Oliver](http://samoliver.com/)

### AssetTag 타임스탬프 캐싱

Rails은 정적 자산 경로에 타임스탬프를 추가하여 "캐시 버스터"로 사용하는 것에 익숙할 것입니다. 이를 통해 서버에서 이미지나 스타일시트와 같은 오래된 복사본이 사용자의 브라우저 캐시에서 제공되지 않도록 보장할 수 있습니다. Action View의 `cache_asset_timestamps` 구성 옵션을 사용하여 이 동작을 수정할 수 있습니다. 캐시를 활성화하면 Rails는 자산을 처음 제공할 때 타임스탬프를 한 번 계산하고 해당 값을 저장합니다. 이는 정적 자산을 제공하기 위해 (비용이 많이 드는) 파일 시스템 호출을 줄이는 것을 의미합니다. 그러나 이는 또한 서버가 실행 중일 때 자산을 수정하고 클라이언트에서 변경 사항이 반영되기를 기대할 수 없다는 것을 의미합니다.
### 객체로서의 자산 호스트

에지 레일에서는 자산 호스트를 호출하는 특정 객체로 선언할 수 있는 기능을 제공하여 자산 호스팅에 대한 유연성을 높였습니다. 이를 통해 자산 호스팅에 필요한 복잡한 로직을 구현할 수 있습니다.

* 자세한 정보: [asset-hosting-with-minimum-ssl](https://github.com/dhh/asset-hosting-with-minimum-ssl/tree/master)

### grouped_options_for_select 도우미 메서드

Action View에는 이미 select 컨트롤을 생성하는 데 도움이 되는 여러 도우미가 있었지만, 이제 `grouped_options_for_select`라는 새로운 도우미가 추가되었습니다. 이 도우미는 문자열의 배열이나 해시를 받아 `option` 태그로 둘러싸인 `optgroup` 태그의 문자열로 변환합니다. 예를 들면 다음과 같습니다:

```ruby
grouped_options_for_select([["Hats", ["Baseball Cap","Cowboy Hat"]]],
  "Cowboy Hat", "Choose a product...")
```

결과는 다음과 같습니다:

```html
<option value="">Choose a product...</option>
<optgroup label="Hats">
  <option value="Baseball Cap">Baseball Cap</option>
  <option selected="selected" value="Cowboy Hat">Cowboy Hat</option>
</optgroup>
```

### 폼 선택 도우미를 위한 비활성화된 옵션 태그

`select` 및 `options_for_select`와 같은 폼 선택 도우미는 이제 결과 태그에서 비활성화된 옵션을 지정할 수 있는 `:disabled` 옵션을 지원합니다. 이 옵션은 단일 값이나 값의 배열을 받을 수 있습니다:

```ruby
select(:post, :category, Post::CATEGORIES, :disabled => 'private')
```

결과는 다음과 같습니다:

```html
<select name="post[category]">
<option>story</option>
<option>joke</option>
<option>poem</option>
<option disabled="disabled">private</option>
</select>
```

또한 런타임에서 컬렉션의 옵션 중 어떤 것이 선택되거나 비활성화될지를 결정하기 위해 익명 함수를 사용할 수도 있습니다:

```ruby
options_from_collection_for_select(@product.sizes, :name, :id, :disabled => lambda{|size| size.out_of_stock?})
```

* 주요 기여자: [Tekin Suleyman](http://tekin.co.uk/)
* 자세한 정보: [New in rails 2.3 - disabled option tags and lambdas for selecting and disabling options from collections](https://tekin.co.uk/2009/03/new-in-rails-23-disabled-option-tags-and-lambdas-for-selecting-and-disabling-options-from-collections)

### 템플릿 로딩에 대한 주의 사항

Rails 2.3에서는 특정 환경에서 캐시된 템플릿을 활성화하거나 비활성화할 수 있는 기능이 포함되었습니다. 캐시된 템플릿은 렌더링될 때 새로운 템플릿 파일을 확인하지 않기 때문에 속도가 향상되지만, 서버를 다시 시작하지 않고는 템플릿을 "실시간"으로 교체할 수 없다는 의미입니다.

대부분의 경우, 템플릿 캐싱은 프로덕션 환경에서 켜져 있어야 합니다. 이를 위해 `production.rb` 파일에서 설정을 변경할 수 있습니다:

```ruby
config.action_view.cache_template_loading = true
```

이 줄은 새로운 Rails 2.3 애플리케이션에서 기본적으로 생성됩니다. 이전 버전의 Rails에서 업그레이드한 경우, Rails은 개발 환경에서는 템플릿을 캐시하지 않고 테스트 및 프로덕션 환경에서는 템플릿을 캐시하도록 기본 설정됩니다.

### 다른 Action View 변경 사항

* CSRF 보호를 위한 토큰 생성이 간소화되었습니다. 이제 Rails는 세션 ID를 사용하는 대신 `ActiveSupport::SecureRandom`에 의해 생성된 간단한 무작위 문자열을 사용합니다.
* `auto_link`는 이제 생성된 이메일 링크에 `:target` 및 `:class`와 같은 옵션을 올바르게 적용합니다.
* `autolink` 도우미가 더 깔끔하고 직관적으로 리팩토링되었습니다.
* `current_page?`는 이제 URL에 여러 쿼리 매개변수가 있는 경우에도 올바르게 작동합니다.

Active Support
--------------

Active Support에는 `Object#try`가 도입되는 등 몇 가지 흥미로운 변경 사항이 있습니다.

### Object#try

많은 사람들이 객체에서 작업을 시도하기 위해 `try()`를 사용하는 개념을 채택했습니다. 특히 뷰에서 `nil` 체크를 피하기 위해 `<%= @person.try(:name) %>`과 같은 코드를 작성할 수 있습니다. 이제 Rails에 직접 내장되어 있습니다. Rails에서 구현된 대로, 개체가 `nil`인 경우 항상 `nil`을 반환하며, 비공개 메서드에 대해서는 `NoMethodError`를 발생시킵니다.

* 자세한 정보: [try()](http://ozmm.org/posts/try.html)

### Object#tap Backport

`Object#tap`은 [Ruby 1.9](http://www.ruby-doc.org/core-1.9/classes/Object.html#M000309) 및 1.8.7에 추가된 `returning` 메서드와 유사한 기능을 제공합니다. 이 메서드는 블록에 양보한 후 양보된 개체를 반환합니다. Rails는 이제 이를 이전 버전의 Ruby에서도 사용할 수 있도록 코드를 포함하고 있습니다.

### XMLmini를 위한 교체 가능한 파서

Active Support에서 XML 파싱을 더 유연하게 만들기 위해 다른 파서를 교체할 수 있도록 지원합니다. 기본적으로 표준 REXML 구현을 사용하지만, 적절한 젬이 설치되어 있는 경우 자체 애플리케이션에서 더 빠른 LibXML 또는 Nokogiri 구현을 지정할 수 있습니다:

```ruby
XmlMini.backend = 'LibXML'
```

* 주요 기여자: [Bart ten Brinke](http://www.movesonrails.com/)
* 주요 기여자: [Aaron Patterson](http://tenderlovemaking.com/)

### TimeWithZone을 위한 소수 초

`Time` 및 `TimeWithZone` 클래스에는 XML 호환 문자열로 시간을 반환하기 위한 `xmlschema` 메서드가 포함되어 있습니다. Rails 2.3부터 `TimeWithZone`은 `Time`과 동일한 인수를 사용하여 반환된 문자열의 소수 초 부분의 자릿수를 지정할 수 있습니다:

```ruby
Time.zone.now.xmlschema(6) # => "2009-01-16T13:00:06.13653Z"
```
* 주요 기여자: [Nicholas Dainty](http://www.workingwithrails.com/person/13536-nicholas-dainty)

### JSON 키 인용

"json.org" 사이트에서 사양을 찾아보면, JSON 구조의 모든 키는 문자열이어야 하며, 이중 따옴표로 인용되어야 한다는 것을 알 수 있습니다. Rails 2.3부터는 숫자 키를 포함하여 올바른 처리를 수행합니다.

### 다른 Active Support 변경 사항

* `Enumerable#none?`을 사용하여 요소 중 일치하는 것이 없는지 확인할 수 있습니다.
* Active Support [대리자](https://afreshcup.com/home/2008/10/19/coming-in-rails-22-delegate-prefixes)를 사용하는 경우, 새로운 `:allow_nil` 옵션을 사용하여 대상 객체가 nil인 경우 예외를 발생시키지 않고 `nil`을 반환할 수 있습니다.
* `ActiveSupport::OrderedHash`: 이제 `each_key`와 `each_value`를 구현합니다.
* `ActiveSupport::MessageEncryptor`는 쿠키와 같은 신뢰할 수 없는 위치에 저장하기 위해 정보를 암호화하는 간단한 방법을 제공합니다.
* Active Support의 `from_xml`은 이제 XmlSimple에 의존하지 않습니다. 대신, Rails는 필요한 기능만 갖춘 자체 XmlMini 구현을 포함하고 있습니다. 이를 통해 Rails는 함께 운반하고 있던 번들 복사본인 XmlSimple을 사용하지 않을 수 있습니다.
* 비공개 메서드를 메모이제이션하는 경우, 결과는 이제 비공개입니다.
* `String#parameterize`는 선택적 구분자를 허용합니다: `"Quick Brown Fox".parameterize('_') => "quick_brown_fox"`.
* `number_to_phone`은 이제 7자리 전화번호를 허용합니다.
* `ActiveSupport::Json.decode`는 이제 `\u0000` 스타일의 이스케이프 시퀀스를 처리합니다.

Railties
--------

위에서 다룬 Rack 변경 사항 외에도 Railties(Rails 자체의 핵심 코드)에는 Rails Metal, 애플리케이션 템플릿 및 조용한 백트레이스와 같은 중요한 변경 사항이 있습니다.

### Rails Metal

Rails Metal은 Rails 애플리케이션 내에서 초고속 엔드포인트를 제공하는 새로운 메커니즘입니다. Metal 클래스는 라우팅과 액션 컨트롤러를 우회하여 원시 속도를 제공합니다(물론 액션 컨트롤러의 모든 기능을 포기해야 합니다). 이는 Rails를 미들웨어 스택이 노출된 Rack 애플리케이션으로 만들기 위한 최근 기반 작업을 기반으로 합니다. Metal 엔드포인트는 애플리케이션이나 플러그인에서 로드할 수 있습니다.

* 자세한 정보:
    * [Rails Metal 소개](https://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal)
    * [Rails Metal: Rails의 강력한 마이크로 프레임워크](http://soylentfoo.jnewland.com/articles/2008/12/16/rails-metal-a-micro-framework-with-the-power-of-rails-m)
    * [Metal: Rails 앱 내에서 초고속 엔드포인트](http://www.railsinside.com/deployment/180-metal-super-fast-endpoints-within-your-rails-apps.html)
    * [Edge Rails의 새로운 기능: Rails Metal](http://archives.ryandaigle.com/articles/2008/12/18/what-s-new-in-edge-rails-rails-metal)

### 애플리케이션 템플릿

Rails 2.3에는 Jeremy McAnally의 [rg](https://github.com/jm/rg) 애플리케이션 생성기가 포함되어 있습니다. 이것은 Rails에 템플릿 기반의 애플리케이션 생성이 내장되어 있다는 것을 의미합니다. 매번 `rails` 명령을 실행할 때마다 모든 애플리케이션에 포함되는 플러그인 세트가 있는 경우(다른 많은 사용 사례 중 하나), 템플릿을 한 번 설정하고 사용할 수 있습니다. 기존 애플리케이션에 템플릿을 적용하는 rake 작업도 있습니다:

```bash
$ rake rails:template LOCATION=~/template.rb
```

이렇게 하면 템플릿에서 변경 사항을 기존 프로젝트의 코드 위에 적용합니다.

* 주요 기여자: [Jeremy McAnally](http://www.jeremymcanally.com/)
* 자세한 정보: [Rails 템플릿](http://m.onkey.org/2008/12/4/rails-templates)

### 조용한 백트레이스

thoughtbot의 [Quiet Backtrace](https://github.com/thoughtbot/quietbacktrace) 플러그인을 기반으로 한 Rails 2.3는 핵심에 `ActiveSupport::BacktraceCleaner`와 `Rails::BacktraceCleaner`를 구현하여 백트레이스에서 특정 라인을 선택적으로 제거할 수 있게 되었습니다. 이는 필터(백트레이스 라인에 대한 정규식 기반 치환 수행)와 사일런서(백트레이스 라인을 완전히 제거)를 모두 지원합니다. Rails는 새로운 애플리케이션에서 가장 일반적인 노이즈를 제거하기 위해 자동으로 사일런서를 추가하고, 사용자 고유의 추가 사항을 담을 `config/backtrace_silencers.rb` 파일을 생성합니다. 이 기능은 백트레이스의 모든 젬에서 더 예쁜 출력을 가능하게 합니다.

### 개발 모드에서 더 빠른 부팅 시간과 지연 로딩/오토로드

Rails(및 해당 종속성)의 일부가 실제로 필요할 때만 메모리에 로드되도록 하는 작업이 수행되었습니다. 핵심 프레임워크인 Active Support, Active Record, Action Controller, Action Mailer 및 Action View는 이제 개별 클래스를 지연 로드하기 위해 `autoload`를 사용합니다. 이 작업은 메모리 사용량을 줄이고 전반적인 Rails 성능을 향상시키는 데 도움이 될 것입니다.

또한 (새로운 `preload_frameworks` 옵션을 사용하여) 핵심 라이브러리가 시작할 때 자동으로 로드되어야 하는지 여부를 지정할 수도 있습니다. 이는 Rails가 조각조각으로 자체를 자동으로 로드하도록 기본값으로 설정되어 있으므로, 모든 것을 한 번에 가져와야 하는 경우도 있습니다 - Passenger와 JRuby는 모두 Rails의 모든 것을 함께 로드하길 원합니다.

### rake gem 작업 재작성

다양한 <code>rake gem</code> 작업의 내부가 크게 개선되어 다양한 경우에 시스템이 더 잘 작동하도록 되었습니다. 이제 gem 시스템은 개발 및 런타임 종속성의 차이를 알고 있으며, 더 견고한 언패킹 시스템을 갖추고 있으며, 젬의 상태를 조회할 때 더 나은 정보를 제공하며, 처음부터 모든 것을 구축할 때 "닭과 달걀" 종속성 문제에 덜 취약합니다. 또한 JRuby에서 gem 명령을 사용하거나 이미 판매된 젬의 외부 복사본을 가져오려고 시도하는 종속성에 대한 수정 사항도 있습니다.
* 주요 기여자: [David Dollar](http://www.workingwithrails.com/person/12240-david-dollar)

### 다른 Railties 변경 사항

* CI 서버를 업데이트하여 Rails를 빌드하는 방법에 대한 지침이 업데이트되고 확장되었습니다.
* 내부 Rails 테스트는 `Test::Unit::TestCase`에서 `ActiveSupport::TestCase`로 전환되었으며, Rails 코어는 테스트를 위해 Mocha를 필요로 합니다.
* 기본 `environment.rb` 파일이 정리되었습니다.
* dbconsole 스크립트는 이제 모든 숫자로 된 비밀번호를 사용하여 충돌하지 않고 사용할 수 있습니다.
* `Rails.root`는 이제 `Pathname` 객체를 반환하므로 `File.join`을 사용하는 기존 코드를 직접 사용할 수 있습니다.
* 기본적으로 모든 Rails 애플리케이션에서 CGI 및 FCGI 디스패치와 관련된 /public의 여러 파일이 더 이상 생성되지 않습니다(필요한 경우 `rails` 명령을 실행할 때 `--with-dispatchers`를 추가하거나 `rake rails:update:generate_dispatchers`로 나중에 추가할 수 있습니다).
* Rails 가이드가 AsciiDoc에서 Textile 마크업으로 변환되었습니다.
* Scaffolded 뷰와 컨트롤러가 약간 정리되었습니다.
* `script/server`는 이제 특정 경로에서 Rails 애플리케이션을 마운트하기 위해 `--path` 인수를 허용합니다.
* 구성된 젬이 누락된 경우, 젬 rake 작업은 환경의 많은 부분을 건너뛸 것입니다. 이로 인해 젬이 누락되어 rake gems:install을 실행할 수 없는 "닭과 달걀" 문제를 해결할 수 있습니다.
* 젬은 이제 정확히 한 번만 풀어집니다. 이는 파일에 읽기 전용 권한이 있는 젬(hoe 등)과 관련된 문제를 해결합니다.

사용 중지됨
----------

이 릴리스에서는 일부 오래된 코드가 사용 중지되었습니다:

* inspector, reaper 및 spawner 스크립트에 의존하는 특정 배포 방식을 사용하는 (비교적 드문) Rails 개발자 중 하나라면, 이제 해당 스크립트가 코어 Rails에 포함되지 않았음을 알아야 합니다. 필요한 경우 [irs_process_scripts](https://github.com/rails/irs_process_scripts) 플러그인을 통해 복사본을 얻을 수 있습니다.
* `render_component`는 Rails 2.3에서 "사용 중지"에서 "존재하지 않음"으로 변경되었습니다. 필요한 경우 [render_component 플러그인](https://github.com/rails/render_component/tree/master)을 설치할 수 있습니다.
* Rails 컴포넌트 지원이 제거되었습니다.
* 통합 테스트를 기반으로 성능을 살펴보기 위해 `script/performance/request`를 실행하는 사람 중 하나였다면, 이제 핵심 Rails에서 해당 스크립트가 제거되었음을 알아야 합니다. 정확히 동일한 기능을 되돌리려면 새로운 request_profiler 플러그인을 설치할 수 있습니다.
* `ActionController::Base#session_enabled?`은 세션이 지연로드되므로 사용 중지되었습니다.
* `protect_from_forgery`의 `:digest` 및 `:secret` 옵션은 사용 중지되었으며 효과가 없습니다.
* 일부 통합 테스트 도우미가 제거되었습니다. `response.headers["Status"]` 및 `headers["Status"]`는 더 이상 아무것도 반환하지 않습니다. Rack은 반환 헤더에 "Status"를 허용하지 않습니다. 그러나 여전히 `status` 및 `status_message` 도우미를 사용할 수 있습니다. `response.headers["cookie"]` 및 `headers["cookie"]`는 더 이상 CGI 쿠키를 반환하지 않습니다. 원시 쿠키 헤더를 확인하려면 `headers["Set-Cookie"]`를 검사하거나 클라이언트로 전송된 쿠키의 해시를 얻기 위해 `cookies` 도우미를 사용할 수 있습니다.
* `formatted_polymorphic_url`은 사용 중지되었습니다. 대신 `polymorphic_url`을 `:format`과 함께 사용하십시오.
* `ActionController::Response#set_cookie`의 `:http_only` 옵션은 `:httponly`로 이름이 변경되었습니다.
* `to_sentence`의 `:connector` 및 `:skip_last_comma` 옵션은 `:words_connector`, `:two_words_connector` 및 `:last_word_connector` 옵션으로 대체되었습니다.
* 비어있는 `file_field` 컨트롤로 멀티파트 폼을 게시하면 컨트롤러에 빈 문자열이 제출되었습니다. 이제 Rack의 멀티파트 파서와 이전 Rails의 차이로 인해 nil이 제출됩니다.

크레딧
-------

릴리스 노트는 [Mike Gunderloy](http://afreshcup.com)가 작성했습니다. 이 버전의 Rails 2.3 릴리스 노트는 Rails 2.3의 RC2를 기반으로 컴파일되었습니다.
