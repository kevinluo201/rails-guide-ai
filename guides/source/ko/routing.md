**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fb66c6f4aafffdb8f8d44e8a2076c9b0
밖에서 안으로의 Rails 라우팅
=================================

이 가이드는 사용자가 볼 수 있는 Rails 라우팅의 기능을 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* `config/routes.rb`의 코드를 해석하는 방법.
* 선호하는 리소스 스타일이나 `match` 메소드를 사용하여 자신만의 라우트를 작성하는 방법.
* 컨트롤러 액션으로 전달되는 라우트 매개변수를 선언하는 방법.
* 라우트 헬퍼를 사용하여 자동으로 경로와 URL을 생성하는 방법.
* 제약 조건을 생성하고 Rack 엔드포인트를 마운트하는 등의 고급 기술.

--------------------------------------------------------------------------------

Rails 라우터의 목적
-------------------------------

Rails 라우터는 URL을 인식하고 컨트롤러의 액션이나 Rack 애플리케이션으로 보냅니다. 또한 경로와 URL을 생성하여 뷰에서 문자열을 하드코딩할 필요가 없도록 합니다.

### URL을 코드에 연결하기

당신의 Rails 애플리케이션이 다음과 같은 들어오는 요청을 받을 때:

```
GET /patients/17
```

라우터에게 컨트롤러 액션과 일치시키도록 요청합니다. 첫 번째 일치하는 라우트가 다음과 같다면:

```ruby
get '/patients/:id', to: 'patients#show'
```

요청은 `patients` 컨트롤러의 `show` 액션으로 `{ id: '17' }`을 `params`로 전달하여 보냅니다.

참고: Rails는 여기서 컨트롤러 이름에 snake_case를 사용합니다. 예를 들어 `MonsterTrucksController`와 같이 여러 단어로 이루어진 컨트롤러가 있다면 `monster_trucks#show`를 사용해야 합니다.

### 코드에서 경로와 URL 생성하기

경로와 URL을 생성할 수도 있습니다. 위의 라우트를 다음과 같이 수정하면:

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

그리고 컨트롤러에 다음과 같은 코드가 포함되어 있다면:

```ruby
@patient = Patient.find(params[:id])
```

그리고 해당하는 뷰에 다음과 같은 코드가 포함되어 있다면:

```erb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

라우터는 경로 `/patients/17`을 생성합니다. 이렇게 하면 뷰의 취약성이 줄어들고 코드를 이해하기 쉬워집니다. 라우트 헬퍼에서 id를 지정할 필요가 없다는 점에 유의하세요.

### Rails 라우터 구성하기

애플리케이션이나 엔진의 라우트는 `config/routes.rb` 파일에 있으며 일반적으로 다음과 같이 보입니다:

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

이것은 일반적인 루비 소스 파일이므로 라우트를 정의하는 데 도움이 되는 모든 기능을 사용할 수 있지만, 변수 이름이 라우터의 DSL 메소드와 충돌할 수 있으므로 주의해야 합니다.

참고: 라우터 DSL의 범위를 설정하기 위해 라우트 정의를 둘러싸는 `Rails.application.routes.draw do ... end` 블록은 필수이며 삭제해서는 안 됩니다.

리소스 라우팅: Rails의 기본값
-----------------------------------

리소스 라우팅을 사용하면 특정 리소스 컨트롤러에 대한 모든 일반적인 라우트를 빠르게 선언할 수 있습니다. [`resources`][]에 대한 단일 호출로 `index`, `show`, `new`, `edit`, `create`, `update`, `destroy` 액션에 필요한 모든 라우트를 선언할 수 있습니다.


### 웹 상의 리소스

브라우저는 특정 HTTP 메소드(`GET`, `POST`, `PATCH`, `PUT`, `DELETE` 등)를 사용하여 URL을 요청하여 Rails에서 페이지를 요청합니다. 각 메소드는 리소스에 대한 작업을 수행하는 요청입니다. 리소스 라우트는 여러 관련 요청을 단일 컨트롤러의 액션에 매핑합니다.

당신의 Rails 애플리케이션이 다음과 같은 들어오는 요청을 받을 때:

```
DELETE /photos/17
```

라우터에게 컨트롤러 액션과 매핑하도록 요청합니다. 첫 번째 일치하는 라우트가 다음과 같다면:

```ruby
resources :photos
```

Rails는 그 요청을 `photos` 컨트롤러의 `destroy` 액션에 `{ id: '17' }`을 `params`로 전달하여 보냅니다.

### CRUD, 동사, 그리고 액션

Rails에서 리소스풀한 라우트는 HTTP 동사와 URL을 컨트롤러 액션에 매핑합니다. 관례적으로 각 액션은 데이터베이스의 특정 CRUD 작업에도 매핑됩니다. 다음과 같은 라우팅 파일의 단일 항목은:

```ruby
resources :photos
```

당신의 애플리케이션에서 `Photos` 컨트롤러에 대해 일곱 가지 다른 라우트를 생성합니다:

| HTTP 동사 | 경로             | 컨트롤러#액션 | 사용 용도                                    |
| --------- | ---------------- | ----------------- | -------------------------------------------- |
| GET       | /photos          | photos#index      | 모든 사진의 목록을 표시                 |
| GET       | /photos/new      | photos#new        | 새 사진을 만들기 위한 HTML 폼 반환 |
| POST      | /photos          | photos#create     | 새 사진을 만듭니다                           |
| GET       | /photos/:id      | photos#show       | 특정 사진을 표시                     |
| GET       | /photos/:id/edit | photos#edit       | 사진을 편집하기 위한 HTML 폼 반환      |
| PATCH/PUT | /photos/:id      | photos#update     | 특정 사진을 업데이트합니다                      |
| DELETE    | /photos/:id      | photos#destroy    | 특정 사진을 삭제합니다                      |
참고: 라우터는 HTTP 동사와 URL을 사용하여 들어오는 요청과 일치시킵니다. 따라서 네 개의 URL이 일곱 가지 다른 작업에 매핑됩니다.

참고: Rails 라우트는 지정된 순서대로 일치되므로 `resources :photos` 위에 `get 'photos/poll'`이 있는 경우 `resources` 줄의 `show` 액션 라우트가 `get` 줄보다 먼저 일치됩니다. 이를 수정하려면 `get` 줄을 `resources` 줄 **위로** 이동하여 먼저 일치되도록 해야 합니다.

### 경로 및 URL 도우미

리소스 라우트를 생성하면 응용 프로그램의 컨트롤러에 일련의 도우미도 노출됩니다. `resources :photos`의 경우:

* `photos_path`는 `/photos`를 반환합니다.
* `new_photo_path`는 `/photos/new`를 반환합니다.
* `edit_photo_path(:id)`는 `/photos/:id/edit`를 반환합니다. (예를 들어, `edit_photo_path(10)`은 `/photos/10/edit`를 반환합니다.)
* `photo_path(:id)`는 `/photos/:id`를 반환합니다. (예를 들어, `photo_path(10)`은 `/photos/10`를 반환합니다.)

이러한 도우미 각각에는 현재 호스트, 포트 및 경로 접두사가 접두어로 붙은 동일한 경로를 반환하는 `_url` 도우미가 있습니다.

TIP: 라우트에 대한 라우트 도우미 이름을 찾으려면 아래의 [기존 라우트 나열](#기존-라우트-나열)을 참조하십시오.

### 동시에 여러 리소스 정의

하나 이상의 리소스에 대한 라우트를 생성해야 하는 경우 `resources`에 대한 단일 호출로 모두 정의하여 타이핑을 조금 줄일 수 있습니다:

```ruby
resources :photos, :books, :videos
```

이것은 다음과 정확히 동일합니다:

```ruby
resources :photos
resources :books
resources :videos
```

### 단수 리소스

때로는 클라이언트가 항상 ID를 참조하지 않고 조회하는 리소스가 있습니다. 예를 들어, 현재 로그인한 사용자의 프로필을 항상 `/profile`에 표시하고 싶을 수 있습니다. 이 경우 단수 리소스를 사용하여 `/profile` (대신 `/profile/:id`)를 `show` 액션에 매핑할 수 있습니다:

```ruby
get 'profile', to: 'users#show'
```

`to:`에 `String`을 전달하면 `controller#action` 형식을 기대합니다. `Symbol`을 사용하는 경우 `to:` 옵션은 `action:`으로 대체되어야 합니다. `#` 없이 `String`을 사용하는 경우 `to:` 옵션은 `controller:`로 대체되어야 합니다:

```ruby
get 'profile', action: :show, controller: 'users'
```

이 리소스 라우트:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

응용 프로그램에서 `Geocoders` 컨트롤러에 매핑되는 여섯 가지 다른 경로를 생성합니다:

| HTTP 동사 | 경로                  | 컨트롤러#액션       | 사용 용도                                      |
| --------- | --------------------- | ------------------ | ---------------------------------------------- |
| GET       | /geocoder/new         | geocoders#new      | 지오코더 생성을 위한 HTML 양식 반환             |
| POST      | /geocoder             | geocoders#create   | 새로운 지오코더 생성                            |
| GET       | /geocoder             | geocoders#show     | 유일한 지오코더 리소스 표시                    |
| GET       | /geocoder/edit        | geocoders#edit     | 지오코더 편집을 위한 HTML 양식 반환             |
| PATCH/PUT | /geocoder             | geocoders#update   | 유일한 지오코더 리소스 업데이트                |
| DELETE    | /geocoder             | geocoders#destroy  | 지오코더 리소스 삭제                           |

참고: 단수 경로 (`/account`)와 복수 경로 (`/accounts/45`)에 동일한 컨트롤러를 사용하려는 경우, 단수 리소스는 복수 컨트롤러에 매핑됩니다. 예를 들어, `resource :photo`와 `resources :photos`는 동일한 컨트롤러 (`PhotosController`)에 매핑되는 단수 및 복수 경로를 모두 생성합니다.

단수 리소스 라우트는 다음 도우미를 생성합니다:

* `new_geocoder_path`는 `/geocoder/new`를 반환합니다.
* `edit_geocoder_path`는 `/geocoder/edit`를 반환합니다.
* `geocoder_path`는 `/geocoder`를 반환합니다.

참고: `resolve` 호출은 [레코드 식별](form_helpers.html#relying-on-record-identification)을 통해 `Geocoder` 인스턴스를 라우트로 변환하기 위해 필요합니다.

복수 리소스와 마찬가지로 `_url`로 끝나는 동일한 도우미는 호스트, 포트 및 경로 접두사도 포함합니다.

### 컨트롤러 네임스페이스 및 라우팅

컨트롤러 그룹을 네임스페이스로 구성할 수도 있습니다. 가장 일반적으로는 여러 관리 컨트롤러를 `Admin::` 네임스페이스 아래에 그룹화하고 이러한 컨트롤러를 `app/controllers/admin` 디렉토리에 배치할 수 있습니다. [`namespace`][] 블록을 사용하여 해당 그룹으로 라우팅할 수 있습니다:

```ruby
namespace :admin do
  resources :articles, :comments
end
```

이렇게 하면 `articles` 및 `comments` 컨트롤러 각각에 대해 여러 경로가 생성됩니다. `Admin::ArticlesController`의 경우 Rails는 다음을 생성합니다:

| HTTP 동사 | 경로                          | 컨트롤러#액션         | 명명된 라우트 도우미          |
| --------- | ----------------------------- | --------------------- | ---------------------------- |
| GET       | /admin/articles               | admin/articles#index  | admin_articles_path          |
| GET       | /admin/articles/new           | admin/articles#new    | new_admin_article_path       |
| POST      | /admin/articles               | admin/articles#create | admin_articles_path          |
| GET       | /admin/articles/:id           | admin/articles#show   | admin_article_path(:id)      |
| GET       | /admin/articles/:id/edit      | admin/articles#edit   | edit_admin_article_path(:id) |
| PATCH/PUT | /admin/articles/:id           | admin/articles#update | admin_article_path(:id)      |
| DELETE    | /admin/articles/:id           | admin/articles#destroy| admin_article_path(:id)      |
대신에 `/admin` 접두사 없이 `/articles`를 `Admin::ArticlesController`로 라우팅하려면 [`scope`][] 블록을 사용하여 모듈을 지정할 수 있습니다:

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

이것은 단일 라우트에 대해서도 수행할 수 있습니다:

```ruby
resources :articles, module: 'admin'
```

대신에 `/admin/articles`를 `ArticlesController`로 라우팅하려면 `scope` 블록을 사용하여 경로를 지정할 수 있습니다:

```ruby
scope '/admin' do
  resources :articles, :comments
end
```

이것은 단일 라우트에 대해서도 수행할 수 있습니다:

```ruby
resources :articles, path: '/admin/articles'
```

이러한 경우에도 이름이 지정된 라우트 헬퍼는 `scope`를 사용하지 않은 경우와 동일합니다. 마지막 경우에는 다음 경로가 `ArticlesController`로 매핑됩니다:

| HTTP 동사 | 경로                     | 컨트롤러#액션    | 이름이 지정된 라우트 헬퍼     |
| --------- | ------------------------ | -------------------- | ---------------------- |
| GET       | /admin/articles          | articles#index       | articles_path          |
| GET       | /admin/articles/new      | articles#new         | new_article_path       |
| POST      | /admin/articles          | articles#create      | articles_path          |
| GET       | /admin/articles/:id      | articles#show        | article_path(:id)      |
| GET       | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id) |
| PATCH/PUT | /admin/articles/:id      | articles#update      | article_path(:id)      |
| DELETE    | /admin/articles/:id      | articles#destroy     | article_path(:id)      |

팁: `namespace` 블록 내에서 다른 컨트롤러 네임스페이스를 사용해야하는 경우 절대 컨트롤러 경로를 지정할 수 있습니다. 예: `get '/foo', to: '/foo#index'`.


### 중첩된 리소스

자주 발생하는 경우 다른 리소스의 논리적인 하위 리소스를 가질 수 있습니다. 예를 들어, 애플리케이션에 다음과 같은 모델이 포함되어 있는 경우:

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

중첩된 라우트를 사용하면 이 관계를 라우팅에 포착할 수 있습니다. 이 경우 다음 라우트 선언을 포함할 수 있습니다:

```ruby
resources :magazines do
  resources :ads
end
```

매거진에 대한 라우트뿐만 아니라 이 선언은 광고를 `AdsController`로 라우팅합니다. 광고 URL은 매거진이 필요합니다:

| HTTP 동사 | 경로                                 | 컨트롤러#액션 | 사용 용도                                                                   |
| --------- | ------------------------------------ | ----------------- | -------------------------------------------------------------------------- |
| GET       | /magazines/:magazine_id/ads          | ads#index         | 특정 매거진에 대한 모든 광고 목록을 표시합니다.                          |
| GET       | /magazines/:magazine_id/ads/new      | ads#new           | 특정 매거진에 속하는 새 광고를 생성하기 위한 HTML 폼을 반환합니다. |
| POST      | /magazines/:magazine_id/ads          | ads#create        | 특정 매거진에 속하는 새 광고를 생성합니다.                           |
| GET       | /magazines/:magazine_id/ads/:id      | ads#show          | 특정 매거진에 속하는 특정 광고를 표시합니다.                     |
| GET       | /magazines/:magazine_id/ads/:id/edit | ads#edit          | 특정 매거진에 속하는 특정 광고를 편집하기 위한 HTML 폼을 반환합니다. |
| PATCH/PUT | /magazines/:magazine_id/ads/:id      | ads#update        | 특정 매거진에 속하는 특정 광고를 업데이트합니다.                      |
| DELETE    | /magazines/:magazine_id/ads/:id      | ads#destroy       | 특정 매거진에 속하는 특정 광고를 삭제합니다.                      |

이는 `magazine_ads_url` 및 `edit_magazine_ad_path`와 같은 라우팅 헬퍼도 생성합니다. 이러한 헬퍼는 첫 번째 매개변수로 Magazine의 인스턴스를 사용합니다 (`magazine_ads_url(@magazine)`).

#### 중첩 제한

원한다면 다른 중첩된 리소스 내에 리소스를 중첩시킬 수 있습니다. 예를 들어:

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

깊게 중첩된 리소스는 빠르게 불편해집니다. 이 경우, 예를 들어, 애플리케이션은 다음과 같은 경로를 인식할 것입니다:

```
/publishers/1/magazines/2/photos/3
```

해당하는 라우트 헬퍼는 `publisher_magazine_photo_url`이며, 세 단계에서 객체를 지정해야합니다. 실제로 이 상황은 혼란스러울 정도로 복잡하므로 [Jamis Buck의 인기있는 글](http://weblog.jamisbuck.org/2007/2/5/nesting-resources)에서는 좋은 Rails 디자인을 위한 규칙을 제안합니다:

팁: 리소스는 1단계 이상 중첩되어서는 안됩니다.

#### 얕은 중첩

깊은 중첩을 피하는 한 가지 방법은 부모 아래에 컬렉션 액션을 생성하여 계층 구조를 파악하는 것입니다. 그러나 멤버 액션을 중첩하지 않습니다. 즉, 리소스를 고유하게 식별하는 데 필요한 최소한의 정보로 라우트를 구축하는 것입니다. 다음과 같이 수행할 수 있습니다:

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

이 아이디어는 기술적인 라우트와 깊은 중첩 사이의 균형을 맞춥니다. 이를 위해 `:shallow` 옵션을 사용하여 간단한 구문을 사용할 수도 있습니다:

```ruby
resources :articles do
  resources :comments, shallow: true
end
```
첫 번째 예제와 정확히 동일한 경로를 생성합니다. 부모 리소스에서 `:shallow` 옵션을 지정할 수도 있으며, 이 경우 모든 중첩된 리소스가 shallow 됩니다:

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

여기서 articles 리소스에 대해 다음과 같은 경로가 생성됩니다:

| HTTP 동사 | 경로                                         | 컨트롤러#액션 | 네임드 라우트 헬퍼       |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_comment_path        |
| GET       | /comments/:id(.:format)                      | comments#show     | comment_path             |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | comment_path             |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | comment_path             |
| GET       | /articles/:article_id/quotes(.:format)       | quotes#index      | article_quotes_path      |
| POST      | /articles/:article_id/quotes(.:format)       | quotes#create     | article_quotes_path      |
| GET       | /articles/:article_id/quotes/new(.:format)   | quotes#new        | new_article_quote_path   |
| GET       | /quotes/:id/edit(.:format)                   | quotes#edit       | edit_quote_path          |
| GET       | /quotes/:id(.:format)                        | quotes#show       | quote_path               |
| PATCH/PUT | /quotes/:id(.:format)                        | quotes#update     | quote_path               |
| DELETE    | /quotes/:id(.:format)                        | quotes#destroy    | quote_path               |
| GET       | /articles/:article_id/drafts(.:format)       | drafts#index      | article_drafts_path      |
| POST      | /articles/:article_id/drafts(.:format)       | drafts#create     | article_drafts_path      |
| GET       | /articles/:article_id/drafts/new(.:format)   | drafts#new        | new_article_draft_path   |
| GET       | /drafts/:id/edit(.:format)                   | drafts#edit       | edit_draft_path          |
| GET       | /drafts/:id(.:format)                        | drafts#show       | draft_path               |
| PATCH/PUT | /drafts/:id(.:format)                        | drafts#update     | draft_path               |
| DELETE    | /drafts/:id(.:format)                        | drafts#destroy    | draft_path               |
| GET       | /articles(.:format)                          | articles#index    | articles_path            |
| POST      | /articles(.:format)                          | articles#create   | articles_path            |
| GET       | /articles/new(.:format)                      | articles#new      | new_article_path         |
| GET       | /articles/:id/edit(.:format)                 | articles#edit     | edit_article_path        |
| GET       | /articles/:id(.:format)                      | articles#show     | article_path             |
| PATCH/PUT | /articles/:id(.:format)                      | articles#update   | article_path             |
| DELETE    | /articles/:id(.:format)                      | articles#destroy  | article_path             |

DSL의 [`shallow`][] 메소드는 모든 중첩을 shallow로 만드는 스코프를 생성합니다. 이전 예제와 동일한 경로를 생성합니다:

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

shallow 경로를 사용자 정의하기 위해 `scope`에 대해 두 가지 옵션이 있습니다. `:shallow_path`는 멤버 경로에 지정된 매개변수를 접두어로 추가합니다:

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

여기서 comments 리소스에 대해 다음과 같은 경로가 생성됩니다:

| HTTP 동사 | 경로                                         | 컨트롤러#액션 | 네임드 라우트 헬퍼       |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /sekret/comments/:id/edit(.:format)          | comments#edit     | edit_comment_path        |
| GET       | /sekret/comments/:id(.:format)               | comments#show     | comment_path             |
| PATCH/PUT | /sekret/comments/:id(.:format)               | comments#update   | comment_path             |
| DELETE    | /sekret/comments/:id(.:format)               | comments#destroy  | comment_path             |

`:shallow_prefix` 옵션은 네임드 라우트 헬퍼에 지정된 매개변수를 추가합니다:

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

여기서 comments 리소스에 대해 다음과 같은 경로가 생성됩니다:

| HTTP 동사 | 경로                                         | 컨트롤러#액션 | 네임드 라우트 헬퍼          |
| --------- | -------------------------------------------- | ----------------- | --------------------------- |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path       |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path       |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path    |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_sekret_comment_path    |
| GET       | /comments/:id(.:format)                      | comments#show     | sekret_comment_path         |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | sekret_comment_path         |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | sekret_comment_path         |


### 라우팅 관심사

라우팅 관심사는 다른 리소스 및 경로 내에서 재사용될 수 있는 공통 경로를 선언할 수 있도록 해줍니다. 관심사를 정의하려면 [`concern`][] 블록을 사용하세요:

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

이러한 관심사는 리소스 내에서 코드 중복을 피하고 경로 간에 동작을 공유하기 위해 사용할 수 있습니다:

```ruby
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

위의 코드는 다음과 동일합니다:

```ruby
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```
또한 [`concerns`][]를 호출하여 어디에서든 사용할 수도 있습니다. 예를 들어, `scope` 또는 `namespace` 블록에서:

```ruby
namespace :articles do
  concerns :commentable
end
```


### 객체에서 경로와 URL 생성하기

라우팅 헬퍼를 사용하는 것 외에도 Rails는 매개변수 배열에서 경로와 URL을 생성할 수도 있습니다. 예를 들어, 다음과 같은 라우트가 있다고 가정해보겠습니다:

```ruby
resources :magazines do
  resources :ads
end
```

`magazine_ad_path`를 사용할 때, 숫자 ID 대신 `Magazine`와 `Ad`의 인스턴스를 전달할 수 있습니다:

```erb
<%= link_to '광고 세부 정보', magazine_ad_path(@magazine, @ad) %>
```

또한 [`url_for`][ActionView::RoutingUrlFor#url_for]을 객체 집합과 함께 사용할 수도 있으며, Rails는 자동으로 원하는 라우트를 결정합니다:

```erb
<%= link_to '광고 세부 정보', url_for([@magazine, @ad]) %>
```

이 경우, Rails는 `@magazine`가 `Magazine`이고 `@ad`가 `Ad`임을 알아차리고 `magazine_ad_path` 헬퍼를 사용합니다. `link_to`와 같은 헬퍼에서는 전체 `url_for` 호출 대신 객체만 지정할 수 있습니다:

```erb
<%= link_to '광고 세부 정보', [@magazine, @ad] %>
```

만약 단지 매거진에 대한 링크를 만들고 싶다면:

```erb
<%= link_to '매거진 세부 정보', @magazine %>
```

다른 액션의 경우, 배열의 첫 번째 요소로 액션 이름을 삽입하면 됩니다:

```erb
<%= link_to '광고 편집', [:edit, @magazine, @ad] %>
```

이를 통해 모델의 인스턴스를 URL로 다룰 수 있으며, 리소스 스타일을 사용하는 것의 주요 장점입니다.


### 더 많은 RESTful 액션 추가하기

RESTful 라우팅이 기본적으로 생성하는 일곱 개의 라우트에 제한되지 않습니다. 원한다면, 컬렉션 또는 컬렉션의 개별 멤버에 적용되는 추가적인 라우트를 추가할 수 있습니다.

#### 멤버 라우트 추가하기

멤버 라우트를 추가하려면, 리소스 블록에 [`member`][] 블록을 추가하면 됩니다:

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

이렇게 하면 GET으로 `/photos/1/preview`를 인식하고, `PhotosController`의 `preview` 액션으로 라우팅하며, 리소스 ID 값은 `params[:id]`로 전달됩니다. 또한 `preview_photo_url` 및 `preview_photo_path` 헬퍼가 생성됩니다.

멤버 라우트 블록 내에서 각 라우트 이름은 인식될 HTTP 동사를 지정합니다. 여기서 [`get`][], [`patch`][], [`put`][], [`post`][], 또는 [`delete`][]를 사용할 수 있습니다. 여러 개의 `member` 라우트가 없는 경우, 블록을 제거하고 라우트에 `:on`을 전달할 수도 있습니다:

```ruby
resources :photos do
  get 'preview', on: :member
end
```

`:on` 옵션을 생략할 수도 있으며, 이 경우 리소스 ID 값은 `params[:id]` 대신 `params[:photo_id]`에서 사용할 수 있습니다. 라우트 헬퍼도 `preview_photo_url` 및 `preview_photo_path`에서 `photo_preview_url` 및 `photo_preview_path`로 이름이 변경됩니다.


#### 컬렉션 라우트 추가하기

[`collection`][] 블록을 사용하여 컬렉션에 라우트를 추가할 수 있습니다:

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

이렇게 하면 GET으로 `/photos/search`와 같은 경로를 인식하고, `PhotosController`의 `search` 액션으로 라우팅합니다. 또한 `search_photos_url` 및 `search_photos_path` 라우트 헬퍼가 생성됩니다.

멤버 라우트와 마찬가지로, 라우트에 `:on`을 전달할 수 있습니다:

```ruby
resources :photos do
  get 'search', on: :collection
end
```

참고: 첫 번째 위치 인수로 심볼을 사용하여 추가 리소스 라우트를 정의하는 경우, 문자열을 사용하는 것과 동일하지 않음을 유의해야 합니다. 심볼은 컨트롤러 액션을 추론하고, 문자열은 경로를 추론합니다.


#### 추가적인 새로운 액션을 위한 라우트 추가하기

`:on` 단축키를 사용하여 대체 새로운 액션을 추가하려면:

```ruby
resources :comments do
  get 'preview', on: :new
end
```

이렇게 하면 GET으로 `/comments/new/preview`와 같은 경로를 인식하고, `CommentsController`의 `preview` 액션으로 라우팅합니다. 또한 `preview_new_comment_url` 및 `preview_new_comment_path` 라우트 헬퍼가 생성됩니다.

팁: 리소스풀한 라우트에 많은 추가 액션을 추가하고 있다면, 다른 리소스의 존재를 가리키고 있는지 스스로 묻는 것이 좋습니다.


리소스풀하지 않은 라우트
----------------------

리소스 라우팅 외에도 Rails는 임의의 URL을 액션에 라우팅하는 강력한 지원을 제공합니다. 여기서는 리소스풀한 라우팅에 의해 자동으로 생성되는 라우트 그룹을 얻을 수 없습니다. 대신, 각 라우트를 애플리케이션 내에서 개별적으로 설정해야 합니다.

일반적으로 리소스풀한 라우팅을 사용해야 하지만, 간단한 라우팅이 더 적합한 경우에는 여전히 많은 곳에서 사용할 수 있습니다. 애플리케이션의 모든 부분을 리소스풀한 프레임워크에 강제로 맞추려고 할 필요는 없습니다.
특히 간단한 라우팅은 레거시 URL을 새로운 Rails 액션에 매핑하는 것을 매우 쉽게 만듭니다.

### 바운드 파라미터

일반적인 라우트를 설정할 때, Rails는 수신되는 HTTP 요청의 일부로 매핑되는 일련의 심볼을 제공합니다. 예를 들어, 다음과 같은 라우트를 고려해보세요:

```ruby
get 'photos(/:id)', to: 'photos#display'
```

이 라우트로 처리되는 `/photos/1`의 수신 요청(이전 파일에서 일치하는 라우트가 없기 때문에)의 결과는 `PhotosController`의 `display` 액션을 호출하고 최종 파라미터 `"1"`을 `params[:id]`로 사용할 수 있게 됩니다. 이 라우트는 `:id`가 선택적 매개변수이므로 괄호로 표시됩니다. 따라서 `/photos`의 수신 요청도 `PhotosController#display`로 라우팅됩니다.

### 동적 세그먼트

일반적인 라우트 내에서 원하는 만큼 많은 동적 세그먼트를 설정할 수 있습니다. 어떤 세그먼트든지 액션에서 `params`의 일부로 사용할 수 있습니다. 다음과 같은 라우트를 설정하면:

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

`/photos/1/2`의 수신 경로는 `PhotosController`의 `show` 액션으로 전달됩니다. `params[:id]`는 `"1"`이고 `params[:user_id]`는 `"2"`입니다.

팁: 기본적으로 동적 세그먼트는 점을 허용하지 않습니다. 이는 점이 형식화된 라우트의 구분자로 사용되기 때문입니다. 동적 세그먼트 내에서 점을 사용해야 하는 경우, 이를 무시하는 제약 조건을 추가하십시오. 예를 들어, `id: /[^\/]+/`는 슬래시를 제외한 모든 것을 허용합니다.

### 정적 세그먼트

세그먼트 앞에 콜론을 붙이지 않고 라우트를 생성할 때 정적 세그먼트를 지정할 수 있습니다:

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

이 라우트는 `/photos/1/with_user/2`와 같은 경로에 응답합니다. 이 경우 `params`는 `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`가 됩니다.

### 쿼리 문자열

`params`에는 쿼리 문자열의 모든 매개변수도 포함됩니다. 예를 들어, 다음과 같은 라우트가 있는 경우:

```ruby
get 'photos/:id', to: 'photos#show'
```

`/photos/1?user_id=2`의 수신 경로는 `Photos` 컨트롤러의 `show` 액션으로 전달됩니다. `params`는 `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`가 됩니다.

### 기본값 정의

`:defaults` 옵션에 대한 해시를 제공하여 라우트에서 기본값을 정의할 수 있습니다. 이는 동적 세그먼트로 지정하지 않은 매개변수에도 적용됩니다. 예를 들어:

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails는 `photos/12`를 `PhotosController`의 `show` 액션과 일치시키고 `params[:format]`을 `"jpg"`로 설정합니다.

다음과 같이 [`defaults`][] 블록을 사용하여 여러 항목에 대한 기본값을 정의할 수도 있습니다:

```ruby
defaults format: :json do
  resources :photos
end
```

참고: 쿼리 매개변수를 통해 기본값을 재정의할 수 없습니다. 이는 보안상의 이유로입니다. URL 경로에서 동적 세그먼트를 대체하여 재정의할 수 있는 유일한 기본값은 동적 세그먼트입니다.


### 라우트 이름 지정

`:as` 옵션을 사용하여 모든 라우트에 이름을 지정할 수 있습니다:

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

이렇게 하면 응용 프로그램에서 이름이 지정된 라우트 도우미인 `logout_path`와 `logout_url`이 생성됩니다. `logout_path`를 호출하면 `/exit`가 반환됩니다.

또한 다음과 같이 사용하여 리소스에 의해 정의된 라우팅 메서드를 재정의할 수도 있습니다. 사용자가 정의되기 전에 사용자 정의 라우트를 배치하면 다음과 같습니다:

```ruby
get ':username', to: 'users#show', as: :user
resources :users
```

이렇게 하면 컨트롤러, 도우미 및 뷰에서 사용할 수 있는 `user_path` 메서드가 정의되며 `/bob`와 같은 경로로 이동합니다. `UsersController`의 `show` 액션에서 `params[:username]`에는 사용자의 사용자 이름이 포함됩니다. 매개변수 이름을 `:username`으로 사용하지 않으려면 라우트 정의에서 `:username`을 변경하십시오.

### HTTP 동사 제약

일반적으로 특정 동사로 라우트를 제한하기 위해 [`get`][], [`post`][], [`put`][], [`patch`][], [`delete`][] 메서드를 사용해야 합니다. [`match`][] 메서드를 `:via` 옵션과 함께 사용하여 여러 동사를 한 번에 일치시킬 수 있습니다:

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

`via: :all`을 사용하여 모든 동사를 특정 라우트에 일치시킬 수도 있습니다:

```ruby
match 'photos', to: 'photos#show', via: :all
```

참고: `GET` 및 `POST` 요청을 단일 액션으로 라우팅하는 것은 보안상의 문제가 있습니다. 일반적으로 좋은 이유가 없는 한 모든 동사를 액션에 라우팅하지 않는 것이 좋습니다.

참고: Rails에서 `GET`은 CSRF 토큰을 확인하지 않습니다. `GET` 요청에서 데이터베이스에 기록하면 안 됩니다. 자세한 내용은 CSRF 대책에 대한 [보안 가이드](security.html#csrf-countermeasures)를 참조하십시오.
### 세그먼트 제약 조건

동적 세그먼트에 대한 형식을 강제하기 위해 `:constraints` 옵션을 사용할 수 있습니다:

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

이 경로는 `/photos/A12345`와 같은 경로와 일치하지만 `/photos/893`과 같은 경로와는 일치하지 않습니다. 동일한 경로를 더 간결하게 표현할 수도 있습니다:

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints`는 정규 표현식을 사용하며 정규 표현식 앵커를 사용할 수 없다는 제한이 있습니다. 예를 들어, 다음 경로는 작동하지 않습니다:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

그러나 모든 경로가 시작과 끝에서 앵커가 되기 때문에 앵커를 사용할 필요가 없음에 유의하세요.

예를 들어, 다음 경로는 항상 숫자로 시작하는 `1-hello-world`와 같은 `to_param` 값을 가진 `articles`와 숫자로 시작하지 않는 `david`와 같은 `to_param` 값을 가진 `users`가 동일한 루트 네임스페이스를 공유할 수 있도록 합니다:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### 요청 기반 제약 조건

요청 객체의 `String`을 반환하는 [Request 객체](action_controller_overview.html#the-request-object)의 모든 메서드를 기반으로 경로를 제약할 수도 있습니다.

세그먼트 제약 조건을 지정하는 방법은 세그먼트 제약 조건을 지정하는 방법과 동일합니다:

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

[`constraints`][] 블록을 사용하여 제약 조건을 지정할 수도 있습니다:

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

참고: 요청 제약 조건은 [Request 객체](action_controller_overview.html#the-request-object)의 해시 키와 동일한 이름의 메서드를 호출하고 반환 값을 해시 값과 비교하여 작동합니다. 따라서 제약 조건 값은 해당 Request 객체 메서드의 반환 유형과 일치해야 합니다. 예를 들어: `constraints: { subdomain: 'api' }`는 예상대로 `api` 서브도메인과 일치합니다. 그러나 심볼 `constraints: { subdomain: :api }`를 사용하면 일치하지 않습니다. 왜냐하면 `request.subdomain`은 문자열 `'api'`를 반환하기 때문입니다.

참고: `format` 제약 조건에는 예외가 있습니다. Request 객체의 메서드이지만 모든 경로의 암묵적 선택적 매개변수입니다. 세그먼트 제약 조건이 우선하며 `format` 제약 조건은 해시를 통해 강제로 적용될 때만 적용됩니다. 예를 들어, `get 'foo', constraints: { format: 'json' }`는 형식이 기본적으로 선택적이기 때문에 `GET  /foo`와 일치합니다. 그러나 `get 'foo', constraints: lambda { |req| req.format == :json }`와 같이 [람다](#advanced-constraints)를 사용하면 명시적인 JSON 요청에만 경로가 일치합니다.


### 고급 제약 조건

더 복잡한 제약 조건이 있는 경우 Rails에서 사용할 `matches?` 메서드에 응답하는 객체를 제공할 수 있습니다. 예를 들어, 특정 목록에 있는 모든 사용자를 `RestrictedListController`로 라우팅하려면 다음과 같이 할 수 있습니다:

```ruby
class RestrictedListConstraint
  def initialize
    @ips = RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: RestrictedListConstraint.new
end
```

`lambda`로 제약 조건을 지정할 수도 있습니다:

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

`matches?` 메서드와 람다는 `request` 객체를 인수로 받습니다.

#### 블록 형식의 제약 조건

블록 형식으로 제약 조건을 지정할 수도 있습니다. 이는 여러 경로에 동일한 규칙을 적용해야 할 때 유용합니다. 예를 들어:

```ruby
class RestrictedListConstraint
  # ...위의 예와 동일
end

Rails.application.routes.draw do
  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

`lambda`를 사용할 수도 있습니다:

```ruby
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

### 경로 글로빙과 와일드카드 세그먼트

경로 글로빙은 특정 매개변수가 경로의 나머지 부분과 일치해야 함을 지정하는 방법입니다. 예를 들어:

```ruby
get 'photos/*other', to: 'photos#unknown'
```

이 경로는 `photos/12` 또는 `/photos/long/path/to/12`와 일치하며 `params[:other]`를 `"12"` 또는 `"long/path/to/12"`로 설정합니다. 별표(*)로 접두사가 붙은 세그먼트를 "와일드카드 세그먼트"라고 합니다.

와일드카드 세그먼트는 경로의 어느 곳에서나 발생할 수 있습니다. 예를 들어:

```ruby
get 'books/*section/:title', to: 'books#show'
```

는 `books/some/section/last-words-a-memoir`와 일치하며 `params[:section]`이 `'some/section'`이고 `params[:title]`이 `'last-words-a-memoir'`입니다.

기술적으로 경로에는 하나 이상의 와일드카드 세그먼트가 있을 수 있습니다. 매처는 세그먼트를 매개변수에 직관적인 방식으로 할당합니다. 예를 들어:

```ruby
get '*a/foo/*b', to: 'test#index'
```

는 `zoo/woo/foo/bar/baz`와 일치하며 `params[:a]`가 `'zoo/woo'`이고 `params[:b]`가 `'bar/baz'`입니다.
참고: `'/foo/bar.json'`를 요청하면 `params[:pages]`가 `'foo/bar'`이 되고 요청 형식은 JSON이 됩니다. 이전 3.0.x 동작을 되돌리려면 다음과 같이 `format: false`를 제공할 수 있습니다:

```ruby
get '*pages', to: 'pages#show', format: false
```

참고: 형식 세그먼트를 필수로 만들어 생략할 수 없게 하려면 다음과 같이 `format: true`를 제공할 수 있습니다:

```ruby
get '*pages', to: 'pages#show', format: true
```

### 리다이렉션

라우터에서 [`redirect`][] 도우미를 사용하여 어떤 경로를 다른 경로로 리다이렉션할 수 있습니다:

```ruby
get '/stories', to: redirect('/articles')
```

일치하는 경로에서 동적 세그먼트를 재사용하여 리다이렉션할 수도 있습니다:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

`redirect`에 블록을 제공할 수도 있으며, 이 블록은 심볼화된 경로 매개변수와 요청 객체를 받습니다:

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

기본 리다이렉션은 301 "영구 이동" 리다이렉션입니다. 일부 웹 브라우저나 프록시 서버는 이 유형의 리다이렉션을 캐시하여 이전 페이지에 액세스할 수 없게 만들 수 있습니다. 응답 상태를 변경하려면 `:status` 옵션을 사용할 수 있습니다:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

이러한 경우 모두 선행 호스트(`http://www.example.com`)를 제공하지 않으면 Rails는 현재 요청에서 해당 세부 정보를 가져옵니다.


### Rack 애플리케이션으로 라우팅

`'articles#index'`와 같은 문자열은 `ArticlesController`의 `index` 액션에 해당하는 것입니다. 매처의 끝점으로 [Rack 애플리케이션](rails_on_rack.html)을 지정할 수 있습니다:

```ruby
match '/application.js', to: MyRackApp, via: :all
```

`MyRackApp`이 `call`을 응답하고 `[status, headers, body]`를 반환하는 한, 라우터는 Rack 애플리케이션과 액션의 차이를 알지 못합니다. 이는 `via: :all`의 적절한 사용입니다. Rack 애플리케이션이 적절하다고 판단하는 모든 동사를 처리할 수 있도록 허용해야 합니다.

참고: 궁금한 사람들을 위해 `'articles#index'`는 실제로 `ArticlesController.action(:index)`로 확장되며 유효한 Rack 애플리케이션을 반환합니다.

참고: 프록/람다는 `call`에 응답하는 객체이므로 매우 간단한 라우트(예: 헬스 체크용)를 인라인으로 구현할 수 있습니다:<br>`get '/health', to: ->(env) { [204, {}, ['']] }`

매처의 끝점으로 Rack 애플리케이션을 지정하는 경우 수신 애플리케이션에서 경로가 변경되지 않습니다. 다음 경로로 Rack 애플리케이션이 요청을 받아들이기를 원한다면 다음과 같이 설정해야 합니다:

```ruby
match '/admin', to: AdminApp, via: :all
```

Rack 애플리케이션이 루트 경로에서 요청을 받아들이기를 원한다면 [`mount`][]를 사용하세요:

```ruby
mount AdminApp, at: '/admin'
```


### `root` 사용

[`root`][] 메서드를 사용하여 Rails가 `'/'`를 어떤 경로로 라우팅해야 하는지 지정할 수 있습니다:

```ruby
root to: 'pages#main'
root 'pages#main' # 위의 단축형
```

`root` 경로는 파일의 맨 위에 두어야 합니다. 가장 인기 있는 경로이므로 먼저 일치시켜야 합니다.

참고: `root` 경로는 `GET` 요청만 액션으로 라우팅합니다.

네임스페이스와 스코프 내에서도 `root`를 사용할 수 있습니다. 예를 들어:

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```


### 유니코드 문자 경로

유니코드 문자 경로를 직접 지정할 수 있습니다. 예를 들어:

```ruby
get 'こんにちは', to: 'welcome#index'
```

### 직접 경로

[`direct`][]를 호출하여 직접 사용자 정의 URL 도우미를 만들 수 있습니다. 예를 들어:

```ruby
direct :homepage do
  "https://rubyonrails.org"
end

# >> homepage_url
# => "https://rubyonrails.org"
```

블록의 반환 값은 `url_for` 메서드에 유효한 인수여야 합니다. 따라서 유효한 문자열 URL, 해시, 배열, Active Model 인스턴스 또는 Active Model 클래스를 전달할 수 있습니다.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```


### `resolve` 사용

[`resolve`][] 메서드를 사용하면 모델의 다형성 매핑을 사용자 정의할 수 있습니다. 예를 들어:

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_with model: @basket do |form| %>
  <!-- basket form -->
<% end %>
```

이렇게 하면 일반적인 `/baskets/:id` 대신 단수 URL `/basket`이 생성됩니다.


리소스 경로 사용자 정의
------------------------------

[`resources`][]가 생성하는 기본 경로와 도우미는 대부분의 경우 잘 작동하지만 어떤 경우에는 사용자 정의해야 할 수도 있습니다. Rails는 리소스 헬퍼의 거의 모든 일반적인 부분을 사용자 정의할 수 있도록 허용합니다.
### 컨트롤러 지정하기

`:controller` 옵션을 사용하여 명시적으로 리소스에 사용할 컨트롤러를 지정할 수 있습니다. 예를 들어:

```ruby
resources :photos, controller: 'images'
```

이렇게 하면 `/photos`로 시작하는 경로를 인식하지만 `Images` 컨트롤러로 라우팅합니다:

| HTTP 동사 | 경로             | 컨트롤러#액션 | 네임드 라우트 헬퍼   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | images#index      | photos_path          |
| GET       | /photos/new      | images#new        | new_photo_path       |
| POST      | /photos          | images#create     | photos_path          |
| GET       | /photos/:id      | images#show       | photo_path(:id)      |
| GET       | /photos/:id/edit | images#edit       | edit_photo_path(:id) |
| PATCH/PUT | /photos/:id      | images#update     | photo_path(:id)      |
| DELETE    | /photos/:id      | images#destroy    | photo_path(:id)      |

참고: 이 리소스에 대한 경로를 생성하기 위해 `photos_path`, `new_photo_path` 등을 사용할 수 있습니다.

네임스페이스가 있는 컨트롤러의 경우 디렉토리 표기법을 사용할 수 있습니다. 예를 들어:

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

이렇게 하면 `Admin::UserPermissions` 컨트롤러로 라우팅됩니다.

참고: 디렉토리 표기법만 지원됩니다. Ruby 상수 표기법(예: `controller: 'Admin::UserPermissions'`)으로 컨트롤러를 지정하면 라우팅 문제가 발생하고 경고가 표시됩니다.

### 제약 조건 지정하기

`:constraints` 옵션을 사용하여 암시적인 `id`에 필요한 형식을 지정할 수 있습니다. 예를 들어:

```ruby
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

이 선언은 `:id` 매개변수를 지정된 정규 표현식과 일치하도록 제약합니다. 따라서 이 경우 라우터는 `/photos/1`을 이 경로에 일치시키지 않습니다. 대신 `/photos/RR27`이 일치합니다.

블록 형식을 사용하여 여러 경로에 동일한 제약 조건을 지정할 수도 있습니다:

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

참고: 물론 이 문맥에서 비리소스 경로에서 사용 가능한 더 고급 제약 조건을 사용할 수 있습니다.

팁: 기본적으로 `:id` 매개변수는 점을 허용하지 않습니다. 이는 점이 형식화된 경로의 구분자로 사용되기 때문입니다. `:id` 내에서 점을 사용해야 하는 경우 이를 무시하는 제약 조건을 추가할 수 있습니다. 예를 들어 `id: /[^\/]+/`는 슬래시를 제외한 모든 것을 허용합니다.

### 네임드 라우트 헬퍼 오버라이딩하기

`:as` 옵션을 사용하여 명명된 라우트 헬퍼의 일반적인 이름을 재정의할 수 있습니다. 예를 들어:

```ruby
resources :photos, as: 'images'
```

이렇게 하면 `/photos`로 시작하는 경로를 인식하고 요청을 `PhotosController`로 라우팅하지만 `:as` 옵션의 값으로 헬퍼의 이름을 지정합니다.

| HTTP 동사 | 경로             | 컨트롤러#액션 | 네임드 라우트 헬퍼   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | photos#index      | images_path          |
| GET       | /photos/new      | photos#new        | new_image_path       |
| POST      | /photos          | photos#create     | images_path          |
| GET       | /photos/:id      | photos#show       | image_path(:id)      |
| GET       | /photos/:id/edit | photos#edit       | edit_image_path(:id) |
| PATCH/PUT | /photos/:id      | photos#update     | image_path(:id)      |
| DELETE    | /photos/:id      | photos#destroy    | image_path(:id)      |

### `new` 및 `edit` 세그먼트 오버라이딩하기

`:path_names` 옵션을 사용하여 자동으로 생성된 경로에서 `new` 및 `edit` 세그먼트를 재정의할 수 있습니다:

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

이렇게 하면 다음과 같은 경로를 인식합니다:

```
/photos/make
/photos/1/change
```

참고: 이 옵션으로 실제 액션 이름은 변경되지 않습니다. 표시된 두 경로는 여전히 `new` 및 `edit` 액션으로 라우팅됩니다.

팁: 모든 경로에 대해 이 옵션을 일관되게 변경하려는 경우 아래와 같이 스코프를 사용할 수 있습니다:

```ruby
scope path_names: { new: 'make' } do
  # 나머지 라우트
end
```

### 네임드 라우트 헬퍼에 접두사 추가하기

`:as` 옵션을 사용하여 Rails가 경로에 대해 생성하는 네임드 라우트 헬퍼에 접두사를 추가할 수 있습니다. 이 옵션을 사용하여 경로 범위를 사용하는 경로 간의 이름 충돌을 방지할 수 있습니다. 예를 들어:

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

이렇게 하면 `/admin/photos`에 대한 경로 헬퍼가 `photos_path`, `new_photos_path` 등에서 `admin_photos_path`, `new_admin_photo_path` 등으로 변경됩니다. 스코프에 `as: 'admin_photos'`를 추가하지 않으면 스코프가 없는 `resources :photos`에는 경로 헬퍼가 없습니다.

일부 경로 헬퍼에 접두사를 추가하려면 `scope`와 함께 `:as`를 사용하세요:

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

이전과 마찬가지로 `/admin` 범위의 리소스 헬퍼는 `admin_photos_path` 및 `admin_accounts_path`로 변경되며, 스코프가 없는 리소스는 `photos_path` 및 `accounts_path`를 사용할 수 있습니다.
참고: `namespace` 범위는 자동으로 `:as`뿐만 아니라 `:module` 및 `:path` 접두사도 추가합니다.

#### 매개변수화된 범위

이름이 지정된 매개변수로 경로를 접두사로 지정할 수 있습니다:

```ruby
scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
  resources :articles
end
```

이렇게 하면 `/1/articles/9`와 같은 경로를 제공하며, 컨트롤러, 헬퍼 및 뷰에서 경로의 `account_id` 부분을 `params[:account_id]`로 참조할 수 있습니다.

또한 `account_`로 접두사가 붙은 경로 및 URL 헬퍼가 생성되며, 이를 통해 객체를 전달할 수 있습니다:

```ruby
account_article_path(@account, @article) # => /1/article/9
url_for([@account, @article])            # => /1/article/9
form_with(model: [@account, @article])   # => <form action="/1/article/9" ...>
```

[제약 조건](#segment-constraints)을 사용하여 범위를 ID와 유사한 문자열에만 일치하도록 제한하고 있습니다. 제약 조건을 필요에 맞게 변경하거나 완전히 생략할 수 있습니다. `:as` 옵션은 엄격히 필요하지 않지만, `url_for([@account, @article])` 또는 [`form_with`][]와 같이 `url_for`에 의존하는 도우미에서 평가할 때 Rails에서 오류가 발생합니다.


### 생성되는 라우트 제한하기

기본적으로 Rails는 응용 프로그램의 모든 RESTful 경로에 대해 일곱 가지 기본 동작(`index`, `show`, `new`, `create`, `edit`, `update` 및 `destroy`)에 대한 경로를 생성합니다. `:only` 및 `:except` 옵션을 사용하여 이 동작을 세밀하게 조정할 수 있습니다. `:only` 옵션은 지정된 경로만 생성하도록 Rails에 지시합니다:

```ruby
resources :photos, only: [:index, :show]
```

이제 `/photos`로의 `GET` 요청은 성공하지만, `/photos`로의 `POST` 요청(일반적으로 `create` 동작으로 라우팅될 것)은 실패합니다.

`:except` 옵션은 Rails가 생성하지 _않을_ 경로 또는 경로 목록을 지정합니다:

```ruby
resources :photos, except: :destroy
```

이 경우, Rails는 `destroy`에 대한 경로( `/photos/:id`로의 `DELETE` 요청)를 제외한 모든 일반적인 경로를 생성합니다.

TIP: 응용 프로그램에 많은 RESTful 경로가 있는 경우, 실제로 필요한 경로만 생성하기 위해 `:only` 및 `:except`를 사용하면 메모리 사용량을 줄이고 라우팅 프로세스를 빠르게 할 수 있습니다.

### 번역된 경로

`scope`를 사용하여 `resources`에서 생성된 경로 이름을 변경할 수 있습니다:

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

이제 Rails는 `CategoriesController`에 대한 경로를 생성합니다.

| HTTP 동사 | 경로                       | 컨트롤러#액션  | 이름이 지정된 경로 헬퍼      |
| --------- | -------------------------- | ------------------ | ----------------------- |
| GET       | /kategorien                | categories#index   | categories_path         |
| GET       | /kategorien/neu            | categories#new     | new_category_path       |
| POST      | /kategorien                | categories#create  | categories_path         |
| GET       | /kategorien/:id            | categories#show    | category_path(:id)      |
| GET       | /kategorien/:id/bearbeiten | categories#edit    | edit_category_path(:id) |
| PATCH/PUT | /kategorien/:id            | categories#update  | category_path(:id)      |
| DELETE    | /kategorien/:id            | categories#destroy | category_path(:id)      |

### 단수형 재정의

리소스의 단수형을 재정의하려면 [`inflections`][]를 통해 인플렉터에 추가 규칙을 추가해야 합니다:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```


### 중첩된 리소스에서 `:as` 사용하기

`:as` 옵션은 중첩된 경로 도우미에서 자동으로 생성된 리소스 이름을 재정의합니다. 예를 들어:

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

이렇게 하면 `magazine_periodical_ads_url` 및 `edit_magazine_periodical_ad_path`와 같은 라우팅 도우미가 생성됩니다.

### 이름이 지정된 경로 매개변수 재정의

`:param` 옵션은 기본 리소스 식별자인 `:id`(라우트를 생성하는 데 사용되는 [동적 세그먼트](routing.html#dynamic-segments)의 이름)를 재정의합니다. 컨트롤러에서 `params[<:param>]`을 사용하여 해당 세그먼트에 액세스할 수 있습니다.

```ruby
resources :videos, param: :identifier
```

```
    videos GET  /videos(.:format)                  videos#index
           POST /videos(.:format)                  videos#create
 new_video GET  /videos/new(.:format)              videos#new
edit_video GET  /videos/:identifier/edit(.:format) videos#edit
```

```ruby
Video.find_by(identifier: params[:identifier])
```

연결된 모델의 `ActiveRecord::Base#to_param`을 재정의하여 URL을 구성할 수 있습니다:

```ruby
class Video < ApplicationRecord
  def to_param
    identifier
  end
end
```

```ruby
video = Video.find_by(identifier: "Roman-Holiday")
edit_video_path(video) # => "/videos/Roman-Holiday/edit"
```

매우 큰 라우트 파일을 여러 개의 작은 파일로 분할하기
-------------------------------------------------------

수천 개의 경로가 있는 대형 응용 프로그램에서는 단일 `config/routes.rb` 파일이 불편하고 읽기 어려울 수 있습니다.

Rails는 [`draw`][] 매크로를 사용하여 거대한 단일 `routes.rb` 파일을 여러 개의 작은 파일로 분할하는 방법을 제공합니다.

관리자 영역에 대한 모든 경로를 포함하는 `admin.rb` 경로, API 관련 리소스를 위한 다른 `api.rb` 파일 등을 가질 수 있습니다.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  get 'foo', to: 'foo#bar'

  draw(:admin) # `config/routes/admin.rb`에 위치한 다른 라우트 파일을 로드합니다.
end
```
```ruby
# config/routes/admin.rb

namespace :admin do
  resources :comments
end
```

`Rails.application.routes.draw` 블록 내에서 `draw(:admin)`을 호출하면, 인자로 주어진 이름과 동일한 라우트 파일을 로드하려고 시도합니다 (이 예제에서는 `admin.rb`).
해당 파일은 `config/routes` 디렉토리나 하위 디렉토리 (예: `config/routes/admin.rb` 또는 `config/routes/external/admin.rb`)에 위치해야 합니다.

`admin.rb` 라우팅 파일 내에서 일반적인 라우팅 DSL을 사용할 수 있지만, 메인 `config/routes.rb` 파일에서처럼 `Rails.application.routes.draw` 블록으로 둘러싸면 안 됩니다.


### 실제 필요하지 않은 경우에는 이 기능을 사용하지 마세요

여러 개의 라우팅 파일을 가지고 있는 것은 발견 가능성과 이해하기 어렵게 만듭니다. 대부분의 애플리케이션에서는 몇 백 개의 라우트를 가지고 있더라도 개발자가 단일 라우팅 파일을 가지는 것이 더 쉽습니다. Rails 라우팅 DSL은 이미 `namespace`와 `scope`를 사용하여 라우트를 구성할 수 있는 방법을 제공합니다.


라우트 검사 및 테스트
-----------------------------

Rails는 라우트를 검사하고 테스트할 수 있는 기능을 제공합니다.

### 현재 라우트 목록 확인

애플리케이션에서 사용 가능한 모든 라우트 목록을 확인하려면, 서버가 **개발** 환경에서 실행 중인 동안 브라우저에서 <http://localhost:3000/rails/info/routes>를 방문하거나 터미널에서 `bin/rails routes` 명령을 실행하면 됩니다.

두 방법 모두 `config/routes.rb`에 나열된 순서와 동일한 순서로 모든 라우트를 나열합니다. 각 라우트에는 다음과 같은 정보가 표시됩니다:

* 라우트 이름 (있는 경우)
* 사용된 HTTP 동사 (라우트가 모든 동사에 응답하지 않는 경우)
* 일치하는 URL 패턴
* 라우트의 라우팅 매개변수

예를 들어, RESTful 라우트에 대한 `bin/rails routes` 출력의 일부를 살펴보겠습니다:

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

`--expanded` 옵션을 사용하여 확장된 테이블 형식 모드를 활성화할 수도 있습니다.

```bash
$ bin/rails routes --expanded

--[ Route 1 ]----------------------------------------------------
Prefix            | users
Verb              | GET
URI               | /users(.:format)
Controller#Action | users#index
--[ Route 2 ]----------------------------------------------------
Prefix            |
Verb              | POST
URI               | /users(.:format)
Controller#Action | users#create
--[ Route 3 ]----------------------------------------------------
Prefix            | new_user
Verb              | GET
URI               | /users/new(.:format)
Controller#Action | users#new
--[ Route 4 ]----------------------------------------------------
Prefix            | edit_user
Verb              | GET
URI               | /users/:id/edit(.:format)
Controller#Action | users#edit
```

`-g` 옵션을 사용하여 라우트를 검색할 수도 있습니다. 이 옵션은 URL 헬퍼 메서드 이름, HTTP 동사 또는 URL 경로와 부분적으로 일치하는 라우트를 출력합니다.

```bash
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

특정 컨트롤러에 매핑되는 라우트만 보려면 `-c` 옵션을 사용할 수 있습니다.

```bash
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

팁: `bin/rails routes`의 출력은 터미널 창을 넓히면 (줄이 줄바꿈되지 않을 정도로) 훨씬 가독성이 좋아집니다.

### 라우트 테스트

라우트는 애플리케이션의 나머지 부분과 마찬가지로 테스트 전략에 포함되어야 합니다. Rails는 라우트 테스트를 간단하게 만들기 위해 세 가지 내장된 어서션을 제공합니다:

* [`assert_generates`][]
* [`assert_recognizes`][]
* [`assert_routing`][]


#### `assert_generates` 어서션

[`assert_generates`][]는 특정 옵션이 특정 경로를 생성하는지를 확인하며, 기본 라우트나 사용자 정의 라우트와 함께 사용할 수 있습니다. 예를 들어:

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### `assert_recognizes` 어서션

[`assert_recognizes`][]는 `assert_generates`의 반대입니다. 주어진 경로가 인식되고 애플리케이션의 특정 위치로 라우팅되는지 확인합니다. 예를 들어:

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

`:method` 인자를 제공하여 HTTP 동사를 지정할 수도 있습니다:

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### `assert_routing` 어서션

[`assert_routing`][] 어서션은 경로가 옵션을 생성하고, 옵션이 경로를 생성하는지를 모두 확인합니다. 따라서 `assert_generates`와 `assert_recognizes`의 기능을 결합합니다:

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```

[`resources`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
[`namespace`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-namespace
[`scope`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-scope
[`shallow`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-shallow
[`concern`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concern
[`concerns`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concerns
[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`delete`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-delete
[`get`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-get
[`member`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-member
[`patch`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-patch
[`post`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-post
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`collection`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-collection
[`defaults`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-defaults
[`match`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-match
[`constraints`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints
[`redirect`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Redirection.html#method-i-redirect
[`mount`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-mount
[`root`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-root
[`direct`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-direct
[`resolve`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve
[`form_with`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[`inflections`]: https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-inflections
[`draw`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-draw
[`assert_generates`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates
[`assert_recognizes`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes
[`assert_routing`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_routing
