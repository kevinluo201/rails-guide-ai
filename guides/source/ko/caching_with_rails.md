**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bef23603f5d822054701f5cbf2578d95
Rails에서의 캐싱: 개요
===============================

이 가이드는 캐싱을 사용하여 Rails 애플리케이션의 성능을 향상시키는 방법에 대한 소개입니다.

캐싱은 요청-응답 주기 동안 생성된 콘텐츠를 저장하고 유사한 요청에 대해 재사용하는 것을 의미합니다.

캐싱은 종종 애플리케이션의 성능을 향상시키는 가장 효과적인 방법입니다. 캐싱을 통해 단일 서버와 단일 데이터베이스에서 실행되는 웹 사이트는 수천 개의 동시 사용자 부하를 견딜 수 있습니다.

Rails는 기본적으로 캐싱 기능을 제공합니다. 이 가이드에서는 각각의 캐싱 기능의 범위와 목적을 알려줍니다. 이러한 기술을 숙달하면 Rails 애플리케이션은 초당 수백만 개의 뷰를 처리할 수 있으며 응답 시간이 급증하지 않거나 서버 비용이 증가하지 않습니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* Fragment와 Russian doll 캐싱
* 캐싱 종속성 관리 방법
* 대체 캐시 저장소
* 조건부 GET 지원

--------------------------------------------------------------------------------

기본 캐싱
-------------

이것은 페이지, 액션 및 프래그먼트 캐싱 기술의 소개입니다. Rails는 기본적으로 프래그먼트 캐싱을 제공합니다. 페이지 및 액션 캐싱을 사용하려면 `Gemfile`에 `actionpack-page_caching` 및 `actionpack-action_caching`을 추가해야 합니다.

기본적으로 캐싱은 프로덕션 환경에서만 활성화됩니다. `rails dev:cache`를 실행하거나 `config/environments/development.rb`에서 [`config.action_controller.perform_caching`][]을 `true`로 설정하여 로컬에서 캐싱을 시도할 수 있습니다.

참고: `config.action_controller.perform_caching`의 값을 변경하면 Action Controller가 제공하는 캐싱에만 영향을 미칩니다. 예를 들어, 저수준 캐싱에는 영향을 주지 않습니다. 이에 대해서는 [아래](#low-level-caching)에서 다룹니다.


### 페이지 캐싱

페이지 캐싱은 웹 서버(Apache 또는 NGINX)를 통해 생성된 페이지의 요청을 전체 Rails 스택을 거치지 않고 처리할 수 있는 Rails 메커니즘입니다. 이는 매우 빠르지만 인증이 필요한 페이지와 같은 모든 상황에 적용할 수는 없습니다. 또한, 웹 서버가 파일 시스템에서 직접 파일을 제공하기 때문에 캐시 만료를 구현해야 합니다.

참고: 페이지 캐싱은 Rails 4에서 제거되었습니다. [actionpack-page_caching gem](https://github.com/rails/actionpack-page_caching)을 참조하십시오.

### 액션 캐싱

페이지 캐싱은 before 필터가 있는 액션에 사용할 수 없습니다. 예를 들어, 인증이 필요한 페이지와 같은 페이지에는 페이지 캐싱을 사용할 수 없습니다. 이때 액션 캐싱이 필요합니다. 액션 캐싱은 페이지 캐싱과 유사하게 작동하지만 들어오는 웹 요청이 캐시가 제공되기 전에 Rails 스택에 도달하여 before 필터를 실행할 수 있도록 합니다. 이를 통해 인증 및 기타 제한 사항을 실행하면서 캐시된 출력 결과를 제공할 수 있습니다.

참고: 액션 캐싱은 Rails 4에서 제거되었습니다. [actionpack-action_caching gem](https://github.com/rails/actionpack-action_caching)을 참조하십시오. 새로 선호되는 방법에 대해서는 [DHH의 키 기반 캐시 만료 개요](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)를 참조하십시오.

### 프래그먼트 캐싱

동적 웹 애플리케이션은 일부 구성 요소로 페이지를 구성하는 경우가 많습니다. 이러한 구성 요소는 모두 동일한 캐싱 특성을 가지지 않을 수 있습니다. 페이지의 다른 부분을 별도로 캐시하고 만료할 필요가 있는 경우 프래그먼트 캐싱을 사용할 수 있습니다.

프래그먼트 캐싱은 뷰 로직의 일부를 캐시 블록으로 래핑하고 다음 요청이 들어올 때 캐시 저장소에서 제공될 수 있도록 합니다.

예를 들어, 페이지의 각 제품을 캐시하려면 다음 코드를 사용할 수 있습니다:

```html+erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

애플리케이션이 이 페이지에 첫 번째 요청을 받으면 Rails는 고유한 키로 새 캐시 항목을 작성합니다. 키는 다음과 같은 형식입니다:

```
views/products/index:bea67108094918eeba42cd4a6e786901/products/1
```

가운데 문자열은 템플릿 트리 다이제스트입니다. 이는 캐시하는 뷰 프래그먼트의 내용을 기반으로 계산된 해시 다이제스트입니다. 뷰 프래그먼트(예: HTML 변경)를 변경하면 다이제스트가 변경되어 기존 파일이 만료됩니다.

캐시 항목에는 제품 레코드에서 파생된 캐시 버전이 저장됩니다. 제품이 변경되면 캐시 버전이 변경되고 이전 버전을 포함하는 모든 캐시된 프래그먼트는 무시됩니다.

팁: Memcached와 같은 캐시 저장소는 자동으로 오래된 캐시 파일을 삭제합니다.

특정 조건에 따라 프래그먼트를 캐시하려면 `cache_if` 또는 `cache_unless`를 사용할 수 있습니다:

```erb
<% cache_if admin?, product do %>
  <%= render product %>
<% end %>
```

#### 컬렉션 캐싱

`render` 도우미는 컬렉션에 대해 렌더링된 개별 템플릿도 캐시할 수 있습니다. `each`를 사용한 이전 예제를 한 단계 더 발전시켜 컬렉션을 렌더링할 때 `cached: true`를 전달하여 모든 캐시 템플릿을 한 번에 읽을 수 있습니다.
```html+erb
<%= render partial: 'products/product', collection: @products, cached: true %>
```

이전 렌더에서 캐시된 모든 템플릿은 한 번에 빠른 속도로 가져옵니다. 또한 아직 캐시되지 않은 템플릿은 캐시에 기록되고 다음 렌더에서 다중으로 가져옵니다.

### 러시안 돌 캐싱

캐시된 프래그먼트를 다른 캐시된 프래그먼트 안에 중첩시킬 수 있습니다. 이를 러시안 돌 캐싱이라고 합니다.

러시안 돌 캐싱의 장점은 단일 제품이 업데이트되면 다른 내부 프래그먼트들이 외부 프래그먼트를 재생성할 때 재사용될 수 있다는 것입니다.

이전 섹션에서 설명한대로, 캐시된 파일은 캐시된 파일이 직접 의존하는 레코드의 `updated_at` 값이 변경되면 만료됩니다. 그러나 이는 프래그먼트가 중첩된 캐시를 만료시키지 않습니다.

예를 들어, 다음과 같은 뷰를 살펴보겠습니다:

```erb
<% cache product do %>
  <%= render product.games %>
<% end %>
```

이 뷰는 다음 뷰를 렌더링합니다:

```erb
<% cache game do %>
  <%= render game %>
<% end %>
```

게임의 어떤 속성이 변경되면 `updated_at` 값이 현재 시간으로 설정되어 캐시가 만료됩니다. 그러나 제품 객체에 대해서는 `updated_at`이 변경되지 않으므로 해당 캐시는 만료되지 않고 앱은 오래된 데이터를 제공합니다. 이를 해결하기 위해 모델을 `touch` 메서드로 연결합니다:

```ruby
class Product < ApplicationRecord
  has_many :games
end

class Game < ApplicationRecord
  belongs_to :product, touch: true
end
```

`touch`를 `true`로 설정하면 게임 레코드의 `updated_at`을 변경하는 모든 작업은 연관된 제품에 대해서도 변경하므로 캐시가 만료됩니다.

### 공유된 부분 캐싱

다른 MIME 유형의 파일 간에 부분 및 관련 캐싱을 공유할 수 있습니다. 예를 들어, 공유된 부분 캐싱을 사용하면 템플릿 작성자는 HTML 및 JavaScript 파일 간에 부분을 공유할 수 있습니다. 템플릿이 템플릿 리졸버 파일 경로에 수집될 때 템플릿 언어 확장자만 포함되고 MIME 유형은 포함되지 않습니다. 이로 인해 템플릿은 여러 MIME 유형에 사용할 수 있습니다. HTML 및 JavaScript 요청은 다음 코드에 응답합니다:

```ruby
render(partial: 'hotels/hotel', collection: @hotels, cached: true)
```

`hotels/hotel.erb`라는 파일이 로드됩니다.

다른 옵션은 렌더링할 부분의 전체 파일 이름을 포함하는 것입니다.

```ruby
render(partial: 'hotels/hotel.html.erb', collection: @hotels, cached: true)
```

예를 들어, 이 부분을 JavaScript 파일에 포함시킬 수 있습니다.

### 종속성 관리

캐시를 올바르게 무효화하려면 캐싱 종속성을 올바르게 정의해야 합니다. 일반적인 경우 Rails는 일반적인 경우를 처리하기 때문에 별도로 지정할 필요가 없습니다. 그러나 때로는 사용자 정의 도우미와 같은 경우에 명시적으로 정의해야 할 때도 있습니다.

#### 암시적 종속성

대부분의 템플릿 종속성은 템플릿 자체에서 `render` 호출로부터 유도될 수 있습니다. `ActionView::Digestor`가 해독할 수 있는 몇 가지 `render` 호출의 예는 다음과 같습니다:

```ruby
render partial: "comments/comment", collection: commentable.comments
render "comments/comments"
render 'comments/comments'
render('comments/comments')

render "header"는 render("comments/header")로 변환됩니다.

render(@topic)는 render("topics/topic")로 변환됩니다.
render(topics)는 render("topics/topic")로 변환됩니다.
render(message.topics)는 render("topics/topic")로 변환됩니다.
```

반면에 일부 호출은 캐싱이 올바르게 작동하도록 변경해야 합니다. 예를 들어, 사용자 정의 컬렉션을 전달하는 경우 다음과 같이 변경해야 합니다:

```ruby
render @project.documents.where(published: true)
```

다음과 같이 변경해야 합니다:

```ruby
render partial: "documents/document", collection: @project.documents.where(published: true)
```

#### 명시적 종속성

때로는 전혀 유도할 수 없는 템플릿 종속성이 있을 수 있습니다. 이는 일반적으로 도우미에서 렌더링이 발생할 때의 경우입니다. 다음은 예입니다:

```html+erb
<%= render_sortable_todolists @project.todolists %>
```

이를 호출하기 위해 특수한 주석 형식을 사용해야 합니다:

```html+erb
<%# Template Dependency: todolists/todolist %>
<%= render_sortable_todolists @project.todolists %>
```

단일 테이블 상속 설정과 같은 경우 여러 명시적 종속성이 있을 수 있습니다. 각 템플릿을 모두 작성하는 대신 와일드카드를 사용하여 디렉토리 내의 모든 템플릿과 일치시킬 수 있습니다:

```html+erb
<%# Template Dependency: events/* %>
<%= render_categorizable_events @person.events %>
```

컬렉션 캐싱의 경우, 부분 템플릿이 깨끗한 캐시 호출로 시작하지 않는 경우 특별한 주석 형식을 템플릿 어디에나 추가함으로써 여전히 컬렉션 캐싱의 이점을 얻을 수 있습니다. 예를 들어:

```html+erb
<%# Template Collection: notification %>
<% my_helper_that_calls_cache(some_arg, notification) do %>
  <%= notification.name %>
<% end %>
```
#### 외부 종속성

예를 들어 캐시된 블록 내에서 도우미 메서드를 사용하고 해당 도우미를 업데이트하는 경우 캐시를 업데이트해야합니다. 어떻게 하는지는 중요하지 않지만 템플릿 파일의 MD5가 변경되어야합니다. 한 가지 권장 사항은 다음과 같이 주석에서 명시적으로 표시하는 것입니다.

```html+erb
<%# Helper Dependency Updated: Jul 28, 2015 at 7pm %>
<%= some_helper_method(person) %>
```

### 저수준 캐싱

뷰 프래그먼트를 캐시하는 대신 특정 값을 또는 쿼리 결과를 캐시해야하는 경우가 있습니다. Rails의 캐싱 메커니즘은 직렬화 가능한 정보를 저장하는 데 효과적입니다.

저수준 캐싱을 구현하는 가장 효율적인 방법은 `Rails.cache.fetch` 메서드를 사용하는 것입니다. 이 메서드는 캐시로의 읽기 및 쓰기를 모두 수행합니다. 단일 인수만 전달되는 경우 키가 가져와지고 캐시에서 값이 반환됩니다. 블록이 전달되면 캐시 미스의 경우 해당 블록이 실행됩니다. 블록의 반환 값은 지정된 캐시 키 아래에 캐시에 쓰여지고 해당 반환 값이 반환됩니다. 캐시 히트의 경우 블록을 실행하지 않고 캐시된 값이 반환됩니다.

다음 예를 고려해보십시오. 어떤 애플리케이션에는 경쟁 웹 사이트에서 제품의 가격을 조회하는 인스턴스 메서드를 가진 `Product` 모델이 있습니다. 이 메서드가 반환하는 데이터는 저수준 캐싱에 적합합니다.

```ruby
class Product < ApplicationRecord
  def competing_price
    Rails.cache.fetch("#{cache_key_with_version}/competing_price", expires_in: 12.hours) do
      Competitor::API.find_price(id)
    end
  end
end
```

참고: 이 예제에서는 `cache_key_with_version` 메서드를 사용하여 캐시 키를 생성했으므로 결과적인 캐시 키는 `products/233-20140225082222765838000/competing_price`와 같은 것이 될 것입니다. `cache_key_with_version`은 모델의 클래스 이름, `id` 및 `updated_at` 속성을 기반으로하는 문자열을 생성합니다. 이는 일반적인 관례이며 제품이 업데이트 될 때마다 캐시를 무효화하는 이점이 있습니다. 일반적으로 저수준 캐싱을 사용할 때 캐시 키를 생성해야합니다.

#### Active Record 객체의 인스턴스 캐싱 피하기

다음 예를 고려해보십시오. 캐시에 슈퍼 사용자를 나타내는 Active Record 객체의 목록을 저장하는 경우입니다.

```ruby
# super_admins는 비용이 많이 드는 SQL 쿼리이므로 자주 실행하지 마십시오.
Rails.cache.fetch("super_admin_users", expires_in: 12.hours) do
  User.super_admins.to_a
end
```

이러한 패턴을 __피해야합니다__. 왜냐하면 인스턴스가 변경될 수 있기 때문입니다. 프로덕션 환경에서는 속성이 다를 수 있거나 레코드가 삭제 될 수 있습니다. 그리고 개발 환경에서는 코드를 변경할 때 캐시 저장소가 코드를 다시로드 할 때 신뢰성이 없이 작동합니다.

대신 ID 또는 다른 원시 데이터 유형을 캐시하십시오. 예를 들어:

```ruby
# super_admins는 비용이 많이 드는 SQL 쿼리이므로 자주 실행하지 마십시오.
ids = Rails.cache.fetch("super_admin_user_ids", expires_in: 12.hours) do
  User.super_admins.pluck(:id)
end
User.where(id: ids).to_a
```

### SQL 캐싱

쿼리 캐싱은 각 쿼리에서 반환된 결과 집합을 캐시하는 Rails 기능입니다. Rails는 동일한 요청에 대해 동일한 쿼리를 다시 만나면 데이터베이스에 대한 쿼리를 실행하는 대신 캐시된 결과 집합을 사용합니다.

예를 들어:

```ruby
class ProductsController < ApplicationController
  def index
    # find 쿼리 실행
    @products = Product.all

    # ...

    # 동일한 쿼리 다시 실행
    @products = Product.all
  end
end
```

두 번째로 동일한 쿼리가 데이터베이스에 대해 실행되는 경우 실제로 데이터베이스에 접근하지 않습니다. 첫 번째로 쿼리 결과가 반환되면 쿼리 캐시에 저장되고 두 번째로는 메모리에서 가져옵니다.

그러나 쿼리 캐시는 액션의 시작에서 생성되고 해당 액션의 끝에서 파기되므로 액션의 지속 시간 동안만 유지됩니다. 더 영구한 방식으로 쿼리 결과를 저장하려면 저수준 캐싱을 사용할 수 있습니다.

캐시 저장소
------------

Rails는 SQL 및 페이지 캐싱 외에도 캐시된 데이터를 위한 다른 저장소를 제공합니다.

### 구성

`config.cache_store` 구성 옵션을 설정하여 응용 프로그램의 기본 캐시 저장소를 설정할 수 있습니다. 다른 매개 변수는 캐시 저장소의 생성자에 전달할 수 있습니다.

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

또는 구성 블록 외부에서 `ActionController::Base.cache_store`를 설정할 수 있습니다.

`Rails.cache`를 호출하여 캐시에 액세스할 수 있습니다.

#### 연결 풀 옵션

기본적으로 [`:mem_cache_store`](#activesupport-cache-memcachestore) 및
[`:redis_cache_store`](#activesupport-cache-rediscachestore)는 연결 풀링을 사용하도록 구성되어 있습니다. 따라서 Puma 또는 다른 스레드 기반 서버를 사용하는 경우 여러 스레드가 동시에 캐시 저장소에 대한 쿼리를 수행할 수 있습니다.
연결 풀링을 비활성화하려면 캐시 스토어를 구성할 때 `:pool` 옵션을 `false`로 설정하십시오:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

또한 `:pool` 옵션에 개별 옵션을 제공하여 기본 풀 설정을 재정의할 수도 있습니다:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: { size: 32, timeout: 1 }
```

* `:size` - 이 옵션은 프로세스당 연결 수를 설정합니다 (기본값은 5입니다).

* `:timeout` - 이 옵션은 연결을 기다리는 시간(초)을 설정합니다 (기본값은 5입니다). 타임아웃 내에 사용 가능한 연결이 없으면 `Timeout::Error`가 발생합니다.

### `ActiveSupport::Cache::Store`

[`ActiveSupport::Cache::Store`][]는 Rails에서 캐시와 상호 작용하기 위한 기반을 제공합니다. 이것은 추상 클래스이며, 그 자체로 사용할 수 없습니다. 대신, 저장 엔진에 연결된 클래스의 구체적인 구현을 사용해야 합니다. Rails는 여러 구현을 함께 제공하며, 아래에서 설명합니다.

주요 API 메서드는 [`read`][ActiveSupport::Cache::Store#read], [`write`][ActiveSupport::Cache::Store#write], [`delete`][ActiveSupport::Cache::Store#delete], [`exist?`][ActiveSupport::Cache::Store#exist?], 그리고 [`fetch`][ActiveSupport::Cache::Store#fetch]입니다.

캐시 스토어의 생성자에 전달된 옵션은 해당 API 메서드의 기본 옵션으로 처리됩니다.


### `ActiveSupport::Cache::MemoryStore`

[`ActiveSupport::Cache::MemoryStore`][]는 메모리에 항목을 유지합니다. 캐시 스토어는 초기화할 때 `:size` 옵션을 전송하여 제한된 크기를 가집니다 (기본값은 32MB입니다). 캐시가 할당된 크기를 초과하면 정리가 발생하고 가장 최근에 사용되지 않은 항목이 제거됩니다.

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

여러 개의 Ruby on Rails 서버 프로세스를 실행하는 경우 (Phusion Passenger 또는 puma 클러스터 모드를 사용하는 경우), Rails 서버 프로세스 인스턴스는 서로 캐시 데이터를 공유할 수 없습니다. 이 캐시 스토어는 대규모 애플리케이션 배포에 적합하지 않습니다. 그러나 소규모이고 저 트래픽인 사이트나 몇 개의 서버 프로세스만 있는 사이트, 그리고 개발 및 테스트 환경에는 잘 작동할 수 있습니다.

새로운 Rails 프로젝트는 기본적으로 개발 환경에서 이 구현을 사용하도록 구성됩니다.

참고: `:memory_store`를 사용할 때 프로세스가 캐시 데이터를 공유하지 않기 때문에 Rails 콘솔을 통해 캐시를 수동으로 읽거나 쓰거나 만료시킬 수 없습니다.


### `ActiveSupport::Cache::FileStore`

[`ActiveSupport::Cache::FileStore`][]는 파일 시스템을 사용하여 항목을 저장합니다. 캐시를 초기화할 때 저장소 파일이 저장될 디렉토리 경로를 지정해야 합니다.

```ruby
config.cache_store = :file_store, "/path/to/cache/directory"
```

이 캐시 스토어를 사용하면 동일한 호스트에서 여러 서버 프로세스가 캐시를 공유할 수 있습니다. 이 캐시 스토어는 한 두 개의 호스트에서 서비스되는 저~중간 트래픽 사이트에 적합합니다. 서로 다른 호스트에서 실행되는 서버 프로세스는 공유 파일 시스템을 사용하여 캐시를 공유할 수 있지만, 이러한 설정은 권장되지 않습니다.

캐시는 디스크가 가득 찰 때까지 계속 증가하므로 정기적으로 오래된 항목을 지우는 것이 좋습니다.

이것은 명시적인 `config.cache_store`가 제공되지 않은 경우 기본 캐시 스토어 구현입니다 (기본값은 `"#{root}/tmp/cache/"`입니다).


### `ActiveSupport::Cache::MemCacheStore`

[`ActiveSupport::Cache::MemCacheStore`][]는 Danga의 `memcached` 서버를 사용하여 응용 프로그램에 중앙 집중식 캐시를 제공합니다. Rails는 기본적으로 번들된 `dalli` 젬을 사용합니다. 현재 이것은 제품 웹 사이트에서 가장 인기 있는 캐시 스토어입니다. 매우 높은 성능과 내구성을 가진 단일 공유 캐시 클러스터를 제공하는 데 사용할 수 있습니다.

캐시를 초기화할 때 클러스터의 모든 memcached 서버의 주소를 지정하거나 `MEMCACHE_SERVERS` 환경 변수가 적절하게 설정되었는지 확인해야 합니다.

```ruby
config.cache_store = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
```

둘 다 지정되지 않은 경우 memcached가 로컬호스트의 기본 포트(`127.0.0.1:11211`)에서 실행 중으로 가정하지만, 이는 큰 사이트에는 이상적인 설정이 아닙니다.

```ruby
config.cache_store = :mem_cache_store # $MEMCACHE_SERVERS, 그런 다음 127.0.0.1:11211로 대체됩니다.
```

지원되는 주소 유형에 대한 자세한 내용은 [`Dalli::Client` 문서](https://www.rubydoc.info/gems/dalli/Dalli/Client#initialize-instance_method)를 참조하십시오.

이 캐시의 [`write`][ActiveSupport::Cache::MemCacheStore#write] (및 `fetch`) 메서드는 memcached에 특정 기능을 활용하는 추가 옵션을 허용합니다.


### `ActiveSupport::Cache::RedisCacheStore`

[`ActiveSupport::Cache::RedisCacheStore`][]는 Redis가 메모리 한계에 도달하면 자동으로 삭제되는 기능을 활용하여 Memcached 캐시 서버와 유사하게 동작합니다.

배포 참고: Redis는 기본적으로 키를 만료시키지 않으므로 전용 Redis 캐시 서버를 사용해야 합니다. 지속적인 Redis 서버에 휘발성 캐시 데이터를 채우지 마세요! 자세한 내용은 [Redis 캐시 서버 설정 가이드](https://redis.io/topics/lru-cache)를 참조하십시오.

캐시 전용 Redis 서버의 경우 `maxmemory-policy`를 allkeys의 변형 중 하나로 설정하십시오. Redis 4+는 가장 적게 사용된 항목을 삭제하는 (`allkeys-lfu`)를 지원하며, 이는 훌륭한 기본 선택입니다. Redis 3 이전 버전은 가장 최근에 사용된 항목을 삭제하는 (`allkeys-lru`)를 사용해야 합니다.
캐시 읽기 및 쓰기 타임아웃을 비교적 낮게 설정하십시오. 캐시된 값을 다시 생성하는 것이 1초 이상 기다리는 것보다 빠를 수 있습니다. 읽기 및 쓰기 타임아웃은 기본적으로 1초로 설정되어 있지만, 네트워크 지연이 일정한 경우 더 낮게 설정할 수 있습니다.

기본적으로 캐시 저장소는 요청 중에 연결이 실패하면 Redis에 다시 연결을 시도하지 않습니다. 자주 연결이 끊어지는 경우 다시 연결을 시도하도록 설정할 수 있습니다.

캐시 읽기 및 쓰기는 예외를 발생시키지 않고, 캐시에 아무 것도 없는 것처럼 `nil`을 반환합니다. 캐시에서 예외가 발생하는지 확인하기 위해 `error_handler`를 제공하여 예외 수집 서비스에 보고할 수 있습니다. 이 함수는 `method` (원래 호출된 캐시 저장소 메서드), `returning` (일반적으로 `nil`인 사용자에게 반환된 값) 및 `exception` (복구된 예외)라는 세 개의 키워드 인수를 받아야 합니다.

시작하려면 Gemfile에 redis 젬을 추가하십시오:

```ruby
gem 'redis'
```

마지막으로, 관련된 `config/environments/*.rb` 파일에 구성을 추가하십시오:

```ruby
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
```

더 복잡한 프로덕션 Redis 캐시 저장소는 다음과 같을 수 있습니다:

```ruby
cache_servers = %w(redis://cache-01:6379/0 redis://cache-02:6379/0)
config.cache_store = :redis_cache_store, { url: cache_servers,

  connect_timeout:    30,  # 기본값은 20초입니다
  read_timeout:       0.2, # 기본값은 1초입니다
  write_timeout:      0.2, # 기본값은 1초입니다
  reconnect_attempts: 1,   # 기본값은 0입니다

  error_handler: -> (method:, returning:, exception:) {
    # 에러를 Sentry에 경고로 보고합니다
    Sentry.capture_exception exception, level: 'warning',
      tags: { method: method, returning: returning }
  }
}
```


### `ActiveSupport::Cache::NullStore`

[`ActiveSupport::Cache::NullStore`][]는 각 웹 요청에 대해 범위가 지정되며, 요청이 끝날 때 저장된 값을 지웁니다. 개발 및 테스트 환경에서 사용하기 위해 만들어졌습니다. `Rails.cache`와 직접 상호작용하는 코드가 있지만 캐싱이 코드 변경 결과를 보는 데 방해되는 경우 매우 유용할 수 있습니다.

```ruby
config.cache_store = :null_store
```


### 사용자 정의 캐시 저장소

`ActiveSupport::Cache::Store`를 확장하고 적절한 메서드를 구현하여 사용자 정의 캐시 저장소를 만들 수 있습니다. 이렇게 하면 Rails 애플리케이션에 여러 개의 캐싱 기술을 교체할 수 있습니다.

사용자 정의 캐시 저장소를 사용하려면 캐시 저장소를 새로운 사용자 정의 클래스의 인스턴스로 설정하면 됩니다.

```ruby
config.cache_store = MyCacheStore.new
```

캐시 키
----------

캐시에서 사용되는 키는 `cache_key` 또는 `to_param`에 응답하는 모든 객체가 될 수 있습니다. 사용자 정의 키를 생성해야 하는 경우 클래스에 `cache_key` 메서드를 구현할 수 있습니다. Active Record는 클래스 이름과 레코드 ID를 기반으로 키를 생성합니다.

해시 및 값 배열을 캐시 키로 사용할 수 있습니다.

```ruby
# 이것은 유효한 캐시 키입니다
Rails.cache.read(site: "mysite", owners: [owner_1, owner_2])
```

`Rails.cache`에서 사용하는 키는 실제로 스토리지 엔진에서 사용되는 키와 다를 수 있습니다. 네임스페이스로 수정되거나 기술적인 제약 사항에 맞게 변경될 수 있습니다. 이는 즉, `Rails.cache`에 값을 저장한 다음 `dalli` 젬으로 가져오려고 하면 작동하지 않는다는 것을 의미합니다. 그러나 memcached 크기 제한을 초과하거나 구문 규칙을 위반할 필요도 없습니다.

조건부 GET 지원
-----------------------

조건부 GET은 HTTP 사양의 기능으로, 웹 서버가 브라우저에게 GET 요청의 응답이 마지막 요청 이후로 변경되지 않았으며 브라우저 캐시에서 안전하게 가져올 수 있다고 알리는 방법을 제공합니다.

이를 위해 `HTTP_IF_NONE_MATCH` 및 `HTTP_IF_MODIFIED_SINCE` 헤더를 사용하여 고유한 콘텐츠 식별자와 콘텐츠가 마지막으로 변경된 시간 정보를 주고받습니다. 브라우저가 콘텐츠 식별자 (ETag) 또는 마지막으로 수정된 시간 정보가 서버의 버전과 일치하는 요청을 보내면 서버는 수정되지 않은 상태를 나타내는 빈 응답과 함께 보내기만 하면 됩니다.

마지막으로 수정된 타임스탬프와 버전을 사용하여 요청이 오래된 경우 (즉, 다시 처리해야 함) 이 블록을 실행하십시오.

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    if stale?(last_modified: @product.updated_at.utc, etag: @product.cache_key_with_version)
      respond_to do |wants|
        # ... 일반적인 응답 처리
      end
    end
  end
end
```
옵션 해시 대신 모델을 전달할 수도 있습니다. Rails는 `updated_at` 및 `cache_key_with_version` 메서드를 사용하여 `last_modified` 및 `etag`를 설정합니다.

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    if stale?(@product)
      respond_to do |wants|
        # ... 일반적인 응답 처리
      end
    end
  end
end
```

특별한 응답 처리가 없고 기본 렌더링 메커니즘을 사용하는 경우(`respond_to`를 사용하지 않거나 직접 렌더링을 호출하지 않는 경우) `fresh_when`에 간단한 도우미가 있습니다.

```ruby
class ProductsController < ApplicationController
  # 요청이 최신인 경우 :not_modified를 자동으로 보내고
  # 최신이 아닌 경우 기본 템플릿 (product.*)을 렌더링합니다.

  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, etag: @product
  end
end
```

가끔은 절대로 만료되지 않는 정적 페이지와 같은 응답을 캐시하고 싶을 때가 있습니다. 이를 위해 `http_cache_forever` 도우미를 사용할 수 있으며, 이렇게 하면 브라우저와 프록시가 영원히 캐시합니다.

기본적으로 캐시된 응답은 개인적이며 사용자의 웹 브라우저에만 캐시됩니다. 프록시가 응답을 캐시할 수 있도록하려면 `public: true`를 설정하여 모든 사용자에게 캐시된 응답을 제공할 수 있음을 나타냅니다.

이 도우미를 사용하면 `last_modified` 헤더가 `Time.new(2011, 1, 1).utc`로 설정되고 `expires` 헤더가 100년으로 설정됩니다.

경고: 브라우저/프록시가 캐시된 응답을 강제로 지우지 않는 한 캐시된 응답을 무효화할 수 없으므로이 메서드를 신중하게 사용하십시오.

```ruby
class HomeController < ApplicationController
  def index
    http_cache_forever(public: true) do
      render
    end
  end
end
```

### 강한 ETag 대 약한 ETag

Rails는 기본적으로 약한 ETag를 생성합니다. 약한 ETag는 의미적으로 동등한 응답이 완전히 일치하지 않더라도 동일한 ETag를 가질 수 있도록합니다. 이는 응답 본문의 작은 변경으로 페이지를 다시 생성하지 않고 싶을 때 유용합니다.

약한 ETag는 앞에 `W/`가 붙어 강한 ETag와 구별됩니다.

```
W/"618bbc92e2d35ea1945008b42799b0e7" → 약한 ETag
"618bbc92e2d35ea1945008b42799b0e7" → 강한 ETag
```

약한 ETag와 달리 강한 ETag는 응답이 정확히 동일하고 바이트 단위로 동일함을 의미합니다. 큰 비디오나 PDF 파일에서 범위 요청을 수행할 때 유용합니다. Akamai와 같은 일부 CDN은 강한 ETag 만 지원합니다. 강한 ETag를 생성해야하는 경우 다음과 같이 수행 할 수 있습니다.

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, strong_etag: @product
  end
end
```

강한 ETag를 직접 응답에 설정할 수도 있습니다.

```ruby
response.strong_etag = response.body # => "618bbc92e2d35ea1945008b42799b0e7"
```

개발 중 캐싱
----------------------

개발 모드에서 응용 프로그램의 캐싱 전략을 테스트하고 싶은 경우가 많습니다. Rails는 `dev:cache`라는 rails 명령을 제공하여 캐싱을 쉽게 켜고 끌 수 있습니다.

```bash
$ bin/rails dev:cache
개발 모드가 캐시됩니다.
$ bin/rails dev:cache
개발 모드가 더 이상 캐시되지 않습니다.
```

기본적으로 개발 모드 캐싱이 *꺼져있을 때*, Rails는 [`:null_store`](#activesupport-cache-nullstore)를 사용합니다.

참고 자료
----------

* [DHH의 키 기반 캐시 만료에 관한 기사](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
* [Ryan Bates의 Railscast 캐시 다이제스트에 관한 기사](http://railscasts.com/episodes/387-cache-digests)
[`config.action_controller.perform_caching`]: configuring.html#config-action-controller-perform-caching
[`ActiveSupport::Cache::Store`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
[ActiveSupport::Cache::Store#delete]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-delete
[ActiveSupport::Cache::Store#exist?]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-exist-3F
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#read]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-read
[ActiveSupport::Cache::Store#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-write
[`ActiveSupport::Cache::MemoryStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[`ActiveSupport::Cache::FileStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[`ActiveSupport::Cache::MemCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemCacheStore#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html#method-i-write
[`ActiveSupport::Cache::RedisCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[`ActiveSupport::Cache::NullStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/NullStore.html
