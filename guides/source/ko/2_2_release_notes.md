**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 29fda46e32914456eb8369ab3f2cb7d6
Ruby on Rails 2.2 릴리스 노트
===============================

Rails 2.2는 여러 가지 새로운 기능과 개선된 기능을 제공합니다. 이 목록은 주요 업그레이드를 다루지만 모든 작은 버그 수정과 변경 사항을 포함하지는 않습니다. 모든 것을 보려면 GitHub의 주요 Rails 저장소의 [커밋 목록](https://github.com/rails/rails/commits/2-2-stable)을 확인하십시오.

Rails와 함께 2.2는 [Ruby on Rails 가이드](https://guides.rubyonrails.org/)의 시작을 알리며, 지속적인 [Rails 가이드 해커페스트](http://hackfest.rubyonrails.org/guide)의 첫 번째 결과물입니다. 이 사이트는 Rails의 주요 기능에 대한 고품질 문서를 제공할 것입니다.

--------------------------------------------------------------------------------

인프라
--------------

Rails 2.2는 Rails를 원활하게 유지하고 전 세계와 연결하는 인프라에 대한 중요한 릴리스입니다.

### 국제화

Rails 2.2는 국제화를 위한 쉬운 시스템을 제공합니다 (또는 타이핑하기 지친 사람들을 위한 i18n).

* 주요 기여자: Rails i18 팀
* 자세한 정보 :
    * [공식 Rails i18n 웹사이트](http://rails-i18n.org)
    * [드디어. Ruby on Rails가 국제화되었습니다](https://web.archive.org/web/20140407075019/http://www.artweb-design.de/2008/7/18/finally-ruby-on-rails-gets-internationalized)
    * [Rails 로컬라이징 : 데모 애플리케이션](https://github.com/clemens/i18n_demo_app)

### Ruby 1.9 및 JRuby와의 호환성

스레드 안정성과 함께, Rails는 JRuby와 예정된 Ruby 1.9와 원활하게 작동하기 위해 많은 작업이 이루어졌습니다. Ruby 1.9는 이동하는 대상이므로 엣지 Rails를 엣지 Ruby에서 실행하는 것은 여전히 성공할 수도 실패할 수도 있지만, Rails는 Ruby 1.9가 출시되면 이에 대한 전환 준비가 되어 있습니다.

문서화
-------------

Rails의 내부 문서인 코드 주석은 여러 곳에서 개선되었습니다. 또한, [Ruby on Rails 가이드](https://guides.rubyonrails.org/) 프로젝트는 주요 Rails 구성 요소에 대한 정보의 궁극적인 출처입니다. 첫 번째 공식 릴리스에서 가이드 페이지에는 다음이 포함되어 있습니다:

* [Rails 시작하기](getting_started.html)
* [Rails 데이터베이스 마이그레이션](active_record_migrations.html)
* [Active Record 연관 관계](association_basics.html)
* [Active Record 쿼리 인터페이스](active_record_querying.html)
* [Rails에서 레이아웃 및 렌더링](layouts_and_rendering.html)
* [Action View 폼 도우미](form_helpers.html)
* [Rails 라우팅의 외부에서 시작하기](routing.html)
* [Action Controller 개요](action_controller_overview.html)
* [Rails 캐싱](caching_with_rails.html)
* [Rails 애플리케이션 테스트 가이드](testing.html)
* [Rails 애플리케이션 보안](security.html)
* [Rails 애플리케이션 디버깅](debugging_rails_applications.html)
* [Rails 플러그인 만들기 기본 사항](plugins.html)

모두 합쳐서, 가이드는 초보 및 중급 Rails 개발자를 위해 수천 개의 가이드 문서를 제공합니다.

이 가이드를 로컬에서 생성하려면 애플리케이션 내에서 다음을 실행하십시오:

```bash
$ rake doc:guides
```

이렇게 하면 가이드가 `Rails.root/doc/guides`에 생성되며, 즐겨 사용하는 브라우저에서 `Rails.root/doc/guides/index.html`을 열어 바로 서핑을 시작할 수 있습니다.

* [Xavier Noria](http://advogato.org/person/fxn/diary.html)와 [Hongli Lai](http://izumi.plan99.net/blog/)의 주요 기여
* 자세한 정보:
    * [Rails 가이드 해커페스트](http://hackfest.rubyonrails.org/guide)
    * [Git 브랜치에서 Rails 문서 개선에 도움 주기](https://weblog.rubyonrails.org/2008/5/2/help-improve-rails-documentation-on-git-branch)

HTTP와의 통합 개선: 기본 ETag 지원
----------------------------------------------------------

HTTP 헤더에서 ETag 및 마지막 수정 시간을 지원하는 것은 Rails가 최근에 수정되지 않은 리소스에 대한 요청을 받으면 빈 응답을 보낼 수 있게 합니다. 이를 통해 응답을 보내야 할 필요가 있는지 확인할 수 있습니다.

```ruby
class ArticlesController < ApplicationController
  def show_with_respond_to_block
    @article = Article.find(params[:id])

    # 요청이 stale?에 제공된 옵션과 다른 헤더를 보낸다면, 요청은 실제로 stale하며 respond_to 블록이 트리거됩니다
    # (그리고 stale? 호출의 옵션은 응답에 설정됩니다).
    #
    # 요청 헤더가 일치하는 경우, 요청은 fresh하며 respond_to 블록이 트리거되지 않습니다. 대신, 마지막 수정 및 ETag 헤더를 확인하고
    # 템플릿을 렌더링하는 대신 "304 Not Modified"만 보내도록 기본 렌더링이 발생합니다.
    if stale?(:last_modified => @article.published_at.utc, :etag => @article)
      respond_to do |wants|
        # 일반적인 응답 처리
      end
    end
  end

  def show_with_implied_render
    @article = Article.find(params[:id])

    # 응답 헤더를 설정하고 요청과 비교합니다. 요청이 stale한 경우
    # (즉, etag 또는 last-modified가 일치하지 않는 경우), 템플릿의 기본 렌더링이 발생합니다.
    # 요청이 fresh한 경우, 템플릿을 렌더링하는 대신 "304 Not Modified"를 반환합니다.
    fresh_when(:last_modified => @article.published_at.utc, :etag => @article)
  end
end
```

스레드 안정성
-------------

Rails의 스레드 안전성을 위한 작업이 Rails 2.2에서 롤아웃되고 있습니다. 웹 서버 인프라에 따라, 이는 메모리에 있는 Rails의 사본을 줄이고 더 나은 서버 성능과 다중 코어의 더 높은 활용도를 이끌어낼 수 있어 더 많은 요청을 처리할 수 있게 합니다.
프로덕션 모드에서 멀티스레드 디스패칭을 활성화하려면 `config/environments/production.rb`에 다음 줄을 추가하십시오:

```ruby
config.threadsafe!
```

* 자세한 정보 :
    * [Thread safety for your Rails](http://m.onkey.org/2008/10/23/thread-safety-for-your-rails)
    * [Thread safety project announcement](https://weblog.rubyonrails.org/2008/8/16/josh-peek-officially-joins-the-rails-core)
    * [Q/A: What Thread-safe Rails Means](http://blog.headius.com/2008/08/qa-what-thread-safe-rails-means.html)

Active Record
-------------

여기에서 이야기할 두 가지 큰 추가 기능은 트랜잭션 마이그레이션과 풀드 데이터베이스 트랜잭션입니다. 또한 조인 테이블 조건에 대한 새로운 (더 깔끔한) 구문과 몇 가지 작은 개선 사항이 있습니다.

### 트랜잭션 마이그레이션

과거에는 여러 단계의 Rails 마이그레이션에서 문제가 발생하는 경우가 많았습니다. 마이그레이션 중에 오류가 발생하면 오류 이전의 모든 것이 데이터베이스를 변경하고 오류 이후의 모든 것이 적용되지 않았습니다. 또한 마이그레이션 버전은 실행되었다고 저장되었으므로 문제를 수정한 후에는 간단히 `rake db:migrate:redo`로 다시 실행할 수 없었습니다. 트랜잭션 마이그레이션은 이를 해결하기 위해 마이그레이션 단계를 DDL 트랜잭션으로 래핑하여 하나라도 실패하면 전체 마이그레이션이 취소되도록 합니다. Rails 2.2에서는 트랜잭션 마이그레이션이 기본적으로 PostgreSQL에서 지원됩니다. 이 코드는 나중에 다른 데이터베이스 유형으로 확장할 수 있으며 IBM은 이미 DB2 어댑터를 지원하기 위해 이를 확장했습니다.

* 주요 기여자: [Adam Wiggins](http://about.adamwiggins.com/)
* 자세한 정보:
    * [DDL Transactions](http://adam.heroku.com/past/2008/9/3/ddl_transactions/)
    * [A major milestone for DB2 on Rails](http://db2onrails.com/2008/11/08/a-major-milestone-for-db2-on-rails/)

### 커넥션 풀링

커넥션 풀링을 사용하면 Rails가 최대 크기로 성장할 수 있는 데이터베이스 연결 풀에 대한 데이터베이스 요청을 분산할 수 있습니다 (기본적으로 5개이지만 `database.yml`에 `pool` 키를 추가하여 조정할 수 있습니다). 이는 많은 동시 사용자를 지원하는 응용 프로그램에서 병목 현상을 제거하는 데 도움이 됩니다. 포기하기 전에 기본적으로 5초의 `wait_timeout`가 있습니다. `ActiveRecord::Base.connection_pool`을 사용하면 필요한 경우 풀에 직접 액세스할 수 있습니다.

```yaml
development:
  adapter: mysql
  username: root
  database: sample_development
  pool: 10
  wait_timeout: 10
```

* 주요 기여자: [Nick Sieger](http://blog.nicksieger.com/)
* 자세한 정보:
    * [What's New in Edge Rails: Connection Pools](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-connection-pools)

### 조인 테이블 조건을 위한 해시

해시를 사용하여 조인 테이블에서 조건을 지정할 수 있습니다. 복잡한 조인을 통해 쿼리해야하는 경우 이것은 큰 도움이 됩니다.

```ruby
class Photo < ActiveRecord::Base
  belongs_to :product
end

class Product < ActiveRecord::Base
  has_many :photos
end

# 저작권이 없는 사진을 가진 모든 제품 가져오기:
Product.all(:joins => :photos, :conditions => { :photos => { :copyright => false }})
```

* 자세한 정보:
    * [What's New in Edge Rails: Easy Join Table Conditions](http://archives.ryandaigle.com/articles/2008/7/7/what-s-new-in-edge-rails-easy-join-table-conditions)

### 새로운 동적 검색기

Active Record의 동적 검색기 패밀리에 두 개의 새로운 메서드 집합이 추가되었습니다.

#### `find_last_by_attribute`

`find_last_by_attribute` 메서드는 `Model.last(:conditions => {:attribute => value})`와 동일합니다.

```ruby
# 런던에서 가입한 마지막 사용자 가져오기
User.find_last_by_city('London')
```

* 주요 기여자: [Emilio Tagua](http://www.workingwithrails.com/person/9147-emilio-tagua)

#### `find_by_attribute!`

`find_by_attribute!`의 새로운 bang! 버전은 `Model.first(:conditions => {:attribute => value}) || raise ActiveRecord::RecordNotFound`와 동일합니다. 일치하는 레코드를 찾을 수 없는 경우 `nil`을 반환하는 대신 이 메서드는 일치하는 항목을 찾을 수 없으면 예외를 발생시킵니다.

```ruby
# 'Moby'가 아직 가입하지 않았다면 ActiveRecord::RecordNotFound 예외 발생!
User.find_by_name!('Moby')
```

* 주요 기여자: [Josh Susser](http://blog.hasmanythrough.com)

### 연관 관계는 비공개/보호 범위를 존중합니다

Active Record 연관 관계 프록시는 이제 프록시된 객체의 메서드 범위를 존중합니다. 이전에 (User가 하나의 계정을 가지고 있다고 가정할 때) `@user.account.private_method`는 연관된 Account 객체의 비공개 메서드를 호출했습니다. 이는 Rails 2.2에서 실패합니다. 이 기능이 필요한 경우 `@user.account.send(:private_method)`를 사용해야 합니다 (또는 비공개 또는 보호된 메서드를 공개 메서드로 만들거나). `method_missing`을 재정의하는 경우 연관 관계가 정상적으로 작동하도록 동작을 일치시키기 위해 `respond_to`도 재정의해야 함을 유의하십시오.

* 주요 기여자: Adam Milligan
* 자세한 정보:
    * [Rails 2.2 Change: Private Methods on Association Proxies are Private](http://afreshcup.com/2008/10/24/rails-22-change-private-methods-on-association-proxies-are-private/)

### 다른 Active Record 변경 사항

* `rake db:migrate:redo`는 이제 다시 실행할 특정 마이그레이션을 대상으로하는 선택적 VERSION을 허용합니다.
* `config.active_record.timestamped_migrations = false`를 설정하여 UTC 타임스탬프 대신 숫자 접두사가 있는 마이그레이션을 사용할 수 있습니다.
* `:counter_cache => true`로 선언된 연관 관계의 카운터 캐시 열은 더 이상 0으로 초기화할 필요가 없습니다.
* `ActiveRecord::Base.human_name`은 모델 이름의 국제화를 고려한 인간 친화적인 번역을 제공합니다.

Action Controller
-----------------

컨트롤러 측면에서 라우트를 정리하는 데 도움이 되는 여러 변경 사항이 있습니다. 복잡한 응용 프로그램에서 메모리 사용량을 줄이기 위해 라우팅 엔진의 내부 변경 사항도 있습니다.
### 얕은 라우트 중첩

얕은 라우트 중첩은 깊게 중첩된 리소스를 사용하는 데 어려움을 해결하기 위한 솔루션을 제공합니다. 얕은 중첩을 사용하면 작업하려는 리소스를 고유하게 식별하기 위해 충분한 정보만 제공하면 됩니다.

```ruby
map.resources :publishers, :shallow => true do |publisher|
  publisher.resources :magazines do |magazine|
    magazine.resources :photos
  end
end
```

이렇게 하면 다음과 같은 경로를 인식할 수 있습니다.

```
/publishers/1           ==> publisher_path(1)
/publishers/1/magazines ==> publisher_magazines_path(1)
/magazines/2            ==> magazine_path(2)
/magazines/2/photos     ==> magazines_photos_path(2)
/photos/3               ==> photo_path(3)
```

* 주요 기여자: [S. Brent Faulkner](http://www.unwwwired.net/)
* 자세한 정보:
    * [Rails Routing from the Outside In](routing.html#nested-resources)
    * [What's New in Edge Rails: Shallow Routes](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-shallow-routes)

### 멤버 또는 컬렉션 라우트를 위한 메서드 배열

이제 새로운 멤버 또는 컬렉션 라우트에 대해 메서드 배열을 제공할 수 있습니다. 이렇게 하면 하나 이상의 동사를 처리해야 할 때 동사를 수용하는 경로를 정의하는 불편함을 제거할 수 있습니다. Rails 2.2에서는 다음과 같은 경로 선언이 가능합니다.

```ruby
map.resources :photos, :collection => { :search => [:get, :post] }
```

* 주요 기여자: [Brennan Dunn](http://brennandunn.com/)

### 특정 액션을 가진 리소스

기본적으로 `map.resources`를 사용하여 라우트를 생성하면 Rails는 일곱 가지 기본 액션 (index, show, create, new, edit, update, destroy)에 대한 라우트를 생성합니다. 그러나 이러한 라우트는 응용 프로그램의 메모리를 차지하고 Rails가 추가적인 라우팅 로직을 생성하게 됩니다. 이제 `:only` 및 `:except` 옵션을 사용하여 Rails가 리소스에 대해 생성할 라우트를 세밀하게 조정할 수 있습니다. 단일 액션, 액션 배열 또는 특수한 `:all` 또는 `:none` 옵션을 제공할 수 있습니다. 이러한 옵션은 중첩된 리소스에서 상속됩니다.

```ruby
map.resources :photos, :only => [:index, :show]
map.resources :products, :except => :destroy
```

* 주요 기여자: [Tom Stuart](http://experthuman.com/)

### 다른 액션 컨트롤러 변경 사항

* 이제 요청 라우팅 중에 발생한 예외에 대한 사용자 정의 오류 페이지를 쉽게 표시할 수 있습니다.
* HTTP Accept 헤더는 이제 기본적으로 비활성화되어 있습니다. 원하는 형식을 나타내기 위해 `/customers/1.xml`과 같은 형식화된 URL을 사용하는 것이 좋습니다. Accept 헤더가 필요한 경우 `config.action_controller.use_accept_header = true`로 다시 활성화할 수 있습니다.
* 벤치마킹 숫자는 이제 초 단위가 아닌 밀리초 단위로 보고됩니다.
* Rails는 이제 HTTP 전용 쿠키를 지원하며 (세션에 사용), 최신 브라우저에서 발생하는 일부 크로스 사이트 스크립팅 위험을 완화하는 데 도움이 됩니다.
* `redirect_to`는 이제 URI 스키마를 완전히 지원합니다 (예: svn`ssh: URI로 리디렉션 할 수 있습니다).
* `render`는 이제 `:js` 옵션을 지원하여 올바른 MIME 유형으로 일반 JavaScript를 렌더링할 수 있습니다.
* 요청 위조 보호는 이제 HTML 형식의 콘텐트 요청에만 적용됩니다.
* 다형성 URL은 전달된 매개변수가 nil인 경우 더 합리적으로 동작합니다. 예를 들어, nil 날짜로 `polymorphic_path([@project, @date, @area])`를 호출하면 `project_area_path`를 얻을 수 있습니다.

Action View
-----------

* `javascript_include_tag` 및 `stylesheet_link_tag`은 `:all`과 함께 사용할 수 있는 새로운 `:recursive` 옵션을 지원하여 한 줄의 코드로 전체 파일 트리를 로드할 수 있습니다.
* 포함된 Prototype JavaScript 라이브러리가 버전 1.6.0.3으로 업그레이드되었습니다.
* `RJS#page.reload`를 사용하여 JavaScript를 통해 브라우저의 현재 위치를 다시로드할 수 있습니다.
* `atom_feed` 도우미는 이제 XML 처리 지시문을 삽입할 수 있는 `:instruct` 옵션을 사용합니다.

Action Mailer
-------------

Action Mailer는 이제 메일러 레이아웃을 지원합니다. 적절한 이름의 레이아웃을 제공하여 HTML 이메일을 브라우저에서 볼 때와 같이 예쁘게 만들 수 있습니다. 예를 들어, `CustomerMailer` 클래스는 `layouts/customer_mailer.html.erb`를 사용하도록 예상합니다.

* 자세한 정보:
    * [What's New in Edge Rails: Mailer Layouts](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-mailer-layouts)

Action Mailer는 이제 GMail의 SMTP 서버를 내장 지원합니다. 이를 위해 자동으로 STARTTLS를 활성화합니다. 이 기능을 사용하려면 Ruby 1.8.7이 설치되어 있어야 합니다.

Active Support
--------------

Active Support는 이제 Rails 애플리케이션에 대한 내장형 메모이제이션, `each_with_object` 메서드, 대리자에 대한 접두사 지원 및 기타 다양한 새로운 유틸리티 메서드를 제공합니다.

### 메모이제이션

메모이제이션은 메서드를 한 번 초기화한 다음 그 값을 반복적으로 사용하기 위해 값을 저장하는 패턴입니다. 아마도 직접 응용 프로그램에서 이 패턴을 사용해 본 적이 있을 것입니다.

```ruby
def full_name
  @full_name ||= "#{first_name} #{last_name}"
end
```

메모이제이션을 사용하면 이 작업을 선언적인 방식으로 처리할 수 있습니다.

```ruby
extend ActiveSupport::Memoizable

def full_name
  "#{first_name} #{last_name}"
end
memoize :full_name
```

메모이제이션의 다른 기능으로는 `unmemoize`, `unmemoize_all`, `memoize_all`을 사용하여 메모이제이션을 켜거나 끌 수 있습니다.
* 주요 기여자: [Josh Peek](http://joshpeek.com/)
* 추가 정보:
    * [Edge Rails의 새로운 기능: 쉬운 메모이제이션](http://archives.ryandaigle.com/articles/2008/7/16/what-s-new-in-edge-rails-memoization)
    * [메모이제이션이란? 메모이제이션 가이드](http://www.railway.at/articles/2008/09/20/a-guide-to-memoization)

### each_with_object

`each_with_object` 메서드는 Ruby 1.9에서 역방향으로 가져온 메서드를 사용하여 `inject`에 대한 대안을 제공합니다. 이 메서드는 현재 요소와 메모를 블록에 전달하여 컬렉션을 반복합니다.

```ruby
%w(foo bar).each_with_object({}) { |str, hsh| hsh[str] = str.upcase } # => {'foo' => 'FOO', 'bar' => 'BAR'}
```

주요 기여자: [Adam Keys](http://therealadam.com/)

### 접두사가 있는 대리자

한 클래스에서 다른 클래스로 동작을 위임하는 경우, 이제 위임된 메서드를 식별하는 데 사용할 접두사를 지정할 수 있습니다. 예를 들어:

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => true
end
```

위 코드는 `vendor#account_email`과 `vendor#account_password`와 같은 위임된 메서드를 생성합니다. 사용자 정의 접두사를 지정할 수도 있습니다:

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => :owner
end
```

위 코드는 `vendor#owner_email`과 `vendor#owner_password`와 같은 위임된 메서드를 생성합니다.

주요 기여자: [Daniel Schierbeck](http://workingwithrails.com/person/5830-daniel-schierbeck)

### 기타 Active Support 변경 사항

* Ruby 1.9 호환성 수정을 포함한 `ActiveSupport::Multibyte`의 상당한 업데이트.
* `ActiveSupport::Rescuable`의 추가로 어떤 클래스든 `rescue_from` 구문을 혼합할 수 있습니다.
* 날짜/시간 비교를 용이하게 하기 위해 `Date` 및 `Time` 클래스에 `past?`, `today?`, `future?` 추가.
* `Array#second`부터 `Array#fifth`까지는 `Array#[1]`부터 `Array#[4]`의 별칭입니다.
* `Enumerable#many?`는 `collection.size > 1`을 캡슐화합니다.
* `Inflector#parameterize`는 입력의 URL에 적합한 버전을 생성하여 `to_param`에서 사용합니다.
* `Time#advance`는 소수점 단위의 일 및 주를 인식하여 `1.7.weeks.ago`, `1.5.hours.since` 등을 수행할 수 있습니다.
* 포함된 TzInfo 라이브러리가 버전 0.3.12로 업그레이드되었습니다.
* `ActiveSupport::StringInquirer`는 문자열의 동등성을 테스트하기 위한 예쁜 방법을 제공합니다: `ActiveSupport::StringInquirer.new("abc").abc? => true`

Railties
--------

Railties(레일즈 자체의 핵심 코드)에서 가장 큰 변경 사항은 `config.gems` 메커니즘에 있습니다.

### config.gems

배포 문제를 피하고 레일즈 애플리케이션을 더 독립적으로 만들기 위해 레일즈 애플리케이션이 필요로 하는 모든 젬의 사본을 `/vendor/gems`에 배치할 수 있습니다. 이 기능은 레일즈 2.1에서 처음 등장했지만, 레일즈 2.2에서는 복잡한 젬 간 종속성을 처리하는 데 훨씬 유연하고 견고해졌습니다. 레일즈에서의 젬 관리에는 다음 명령어가 포함됩니다:

* `config.gem _gem_name_`은 `config/environment.rb` 파일에서 사용합니다.
* `rake gems`는 구성된 모든 젬과 해당 젬(및 종속성)이 설치되었는지, 동결되었는지 또는 프레임워크인지를 나열합니다(프레임워크 젬은 젬 종속성 코드가 실행되기 전에 레일즈에서 로드하는 젬으로, 이러한 젬은 동결될 수 없습니다).
* `rake gems:install`은 컴퓨터에 누락된 젬을 설치합니다.
* `rake gems:unpack`은 필요한 젬의 사본을 `/vendor/gems`에 배치합니다.
* `rake gems:unpack:dependencies`는 필요한 젬과 해당 종속성의 사본을 `/vendor/gems`에 가져옵니다.
* `rake gems:build`는 누락된 네이티브 확장을 빌드합니다.
* `rake gems:refresh_specs`는 레일즈 2.1에서 생성된 벤더화된 젬을 레일즈 2.2의 저장 방식과 일치시킵니다.

명령줄에서 `GEM=_gem_name_`을 지정하여 단일 젬을 언팩하거나 설치할 수 있습니다.

* 주요 기여자: [Matt Jones](https://github.com/al2o3cr)
* 추가 정보:
    * [Edge Rails의 새로운 기능: 젬 종속성](http://archives.ryandaigle.com/articles/2008/4/1/what-s-new-in-edge-rails-gem-dependencies)
    * [Rails 2.1.2 및 2.2RC1: RubyGems를 업데이트하세요](https://afreshcup.com/home/2008/10/25/rails-212-and-22rc1-update-your-rubygems)
    * [Lighthouse에서의 자세한 토론](http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1128)

### 기타 Railties 변경 사항

* [Thin](http://code.macournoyer.com/thin/) 웹 서버의 팬이라면, `script/server`가 이제 Thin을 직접 지원한다는 것을 알게 될 것입니다.
* `script/plugin install &lt;plugin&gt; -r &lt;revision&gt;`은 git 기반 및 svn 기반 플러그인에서 작동합니다.
* `script/console`은 이제 `--debugger` 옵션을 지원합니다.
* 레일즈 소스에는 레일즈 자체를 빌드하기 위한 지속적인 통합 서버 설정 지침이 포함되어 있습니다.
* `rake notes:custom ANNOTATION=MYFLAG`을 사용하여 사용자 정의 주석을 나열할 수 있습니다.
* `Rails.env`를 `StringInquirer`로 래핑하여 `Rails.env.development?`와 같은 작업을 수행할 수 있습니다.
* 사용하지 않는 경고를 제거하고 젬 종속성을 올바르게 처리하기 위해 레일즈는 이제 rubygems 1.3.1 이상을 요구합니다.

사라진 기능
----------

이 릴리스에서는 일부 오래된 코드가 사라졌습니다:

* `Rails::SecretKeyGenerator`는 `ActiveSupport::SecureRandom`로 대체되었습니다.
* `render_component`는 사용이 중지되었습니다. 이 기능이 필요한 경우 [render_components 플러그인](https://github.com/rails/render_component/tree/master)을 사용할 수 있습니다.
* 부분을 렌더링할 때 암시적으로 로컬 변수를 할당하는 것은 사용이 중지되었습니다.

    ```ruby
    def partial_with_implicit_local_assignment
      @customer = Customer.new("Marcel")
      render :partial => "customer"
    end
    ```

    이전에 위 코드는 'customer' 부분 내에서 `customer`라는 로컬 변수를 사용할 수 있게 했습니다. 이제는 :locals 해시를 통해 모든 변수를 명시적으로 전달해야 합니다.
* `country_select`가 제거되었습니다. 자세한 정보와 플러그인 대체 방법은 [폐기 페이지](http://www.rubyonrails.org/deprecation/list-of-countries)를 참조하십시오.
* `ActiveRecord::Base.allow_concurrency`는 더 이상 효과가 없습니다.
* `ActiveRecord::Errors.default_error_messages`는 `I18n.translate('activerecord.errors.messages')`로 대체되었습니다.
* 국제화를 위한 `%s` 및 `%d` 보간 구문은 폐기되었습니다.
* `String#chars`는 `String#mb_chars`로 대체되었습니다.
* 소수 개월 또는 소수 연도의 기간은 폐기되었습니다. 대신 Ruby의 핵심 `Date` 및 `Time` 클래스 산술을 사용하십시오.
* `Request#relative_url_root`는 폐기되었습니다. 대신 `ActionController::Base.relative_url_root`를 사용하십시오.

크레딧
-------

릴리스 노트는 [Mike Gunderloy](http://afreshcup.com)가 작성했습니다.
