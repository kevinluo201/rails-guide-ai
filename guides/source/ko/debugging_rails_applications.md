**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3cf93e3667cdacd242332d2d352d53fa
Rails 애플리케이션 디버깅
============================

이 가이드는 Ruby on Rails 애플리케이션을 디버깅하는 기술을 소개합니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* 디버깅의 목적
* 테스트에서 식별하지 못하는 애플리케이션의 문제와 이슈를 추적하는 방법
* 디버깅하는 다양한 방법
* 스택 트레이스를 분석하는 방법

--------------------------------------------------------------------------------

디버깅을 위한 뷰 헬퍼
--------------------------

하나의 일반적인 작업은 변수의 내용을 검사하는 것입니다. Rails는 이를 수행하기 위해 세 가지 다른 방법을 제공합니다:

* `debug`
* `to_yaml`
* `inspect`

### `debug`

`debug` 헬퍼는 YAML 형식을 사용하여 객체를 렌더링하는 `<pre>` 태그를 반환합니다. 이를 통해 어떤 객체에서도 사람이 읽을 수 있는 데이터를 생성할 수 있습니다. 예를 들어, 다음과 같은 코드가 뷰에 있다면:

```html+erb
<%= debug @article %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

다음과 같은 결과를 볼 수 있습니다:

```yaml
--- !ruby/object Article
attributes:
  updated_at: 2008-09-05 22:55:47
  body: It's a very helpful guide for debugging your Rails app.
  title: Rails debugging guide
  published: t
  id: "1"
  created_at: 2008-09-05 22:55:47
attributes_cache: {}


Title: Rails debugging guide
```

### `to_yaml`

대신, 어떤 객체에 대해 `to_yaml`을 호출하면 YAML로 변환됩니다. 이 변환된 객체를 `simple_format` 헬퍼 메서드에 전달하여 출력을 형식화할 수 있습니다. 이것이 `debug`가 마법을 부리는 방법입니다.

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

위의 코드는 다음과 같이 렌더링됩니다:

```yaml
--- !ruby/object Article
attributes:
updated_at: 2008-09-05 22:55:47
body: It's a very helpful guide for debugging your Rails app.
title: Rails debugging guide
published: t
id: "1"
created_at: 2008-09-05 22:55:47
attributes_cache: {}

Title: Rails debugging guide
```

### `inspect`

객체 값을 표시하는 데 유용한 다른 메서드는 `inspect`입니다. 특히 배열이나 해시와 함께 작업할 때 유용합니다. 이는 객체 값을 문자열로 출력합니다. 예를 들어:

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

다음과 같이 렌더링됩니다:

```
[1, 2, 3, 4, 5]

Title: Rails debugging guide
```

로거
----------

런타임 중에 정보를 로그 파일에 저장하는 것도 유용할 수 있습니다. Rails는 각 런타임 환경에 대해 별도의 로그 파일을 유지합니다.

### 로거란?

Rails는 로그 정보를 작성하기 위해 `ActiveSupport::Logger` 클래스를 사용합니다. `Log4r`와 같은 다른 로거도 대체될 수 있습니다.

`config/application.rb` 또는 다른 환경 파일에서 대체 로거를 지정할 수 있습니다. 예를 들어:

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

또는 `Initializer` 섹션에 다음 중 _아무거나_ 추가하세요.

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

팁: 기본적으로 각 로그는 `Rails.root/log/` 아래에 생성되며, 로그 파일은 애플리케이션이 실행되는 환경에 따라 이름이 지정됩니다.

### 로그 레벨

로그에 기록될 때, 메시지의 로그 레벨이 구성된 로그 레벨보다 같거나 높은 경우 해당 로그에 출력됩니다. 현재 로그 레벨을 알고 싶다면 `Rails.logger.level` 메서드를 호출할 수 있습니다.

사용 가능한 로그 레벨은 `:debug`, `:info`, `:warn`, `:error`, `:fatal`, `:unknown`이며, 각각 0부터 5까지의 로그 레벨 번호에 해당합니다. 기본 로그 레벨을 변경하려면 `Rails.logger.level`을 사용하세요.
```ruby
config.log_level = :warn # 어떤 환경 초기화 파일에서든지 또는
Rails.logger.level = 0 # 언제든지

이는 개발 또는 스테이징에서 로그를 기록하고, 불필요한 정보로 생산 로그를 넘치게 하지 않고자 할 때 유용합니다.

팁: 기본 Rails 로그 레벨은 `:debug`입니다. 그러나 기본 생성된 `config/environments/production.rb`에서 `production` 환경에 대해 `:info`로 설정되어 있습니다.

### 메시지 보내기

현재 로그에 쓰려면 컨트롤러, 모델 또는 메일러 내에서 `logger.(debug|info|warn|error|fatal|unknown)` 메소드를 사용하세요:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
logger.info "요청 처리 중..."
logger.fatal "응용 프로그램 종료, 복구할 수 없는 오류 발생!!!"
```

여기에 추가 로깅이 적용된 메소드의 예제가 있습니다:

```ruby
class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(article_params)
    logger.debug "새로운 글: #{@article.attributes.inspect}"
    logger.debug "글은 유효해야 함: #{@article.valid?}"

    if @article.save
      logger.debug "글이 저장되었으며 사용자가 리디렉션됩니다..."
      redirect_to @article, notice: '글이 성공적으로 생성되었습니다.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ...

  private
    def article_params
      params.require(:article).permit(:title, :body, :published)
    end
end
```

이 컨트롤러 액션이 실행될 때 생성되는 로그의 예제입니다:

```
Started POST "/articles" for 127.0.0.1 at 2018-10-18 20:09:23 -0400
Processing by ArticlesController#create as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"XLveDrKzF1SwaiNRPTaMtkrsTzedtebPPkmxEFIU0ordLjICSnXsSNfrdMa4ccyBjuGwnnEiQhEoMN6H1Gtz3A==", "article"=>{"title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>"0"}, "commit"=>"Create Article"}
새로운 글: {"id"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>false, "created_at"=>nil, "updated_at"=>nil}
글은 유효해야 함: true
   (0.0ms)  begin transaction
  ↳ app/controllers/articles_controller.rb:31
  Article Create (0.5ms)  INSERT INTO "articles" ("title", "body", "published", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["title", "Debugging Rails"], ["body", "I'm learning how to print in logs."], ["published", 0], ["created_at", "2018-10-19 00:09:23.216549"], ["updated_at", "2018-10-19 00:09:23.216549"]]
  ↳ app/controllers/articles_controller.rb:31
   (2.3ms)  commit transaction
  ↳ app/controllers/articles_controller.rb:31
글이 저장되었으며 사용자가 리디렉션됩니다...
Redirected to http://localhost:3000/articles/1
Completed 302 Found in 4ms (ActiveRecord: 0.8ms)
```

이와 같이 추가 로깅을 추가하면 로그에서 예상치 못한 또는 이상한 동작을 쉽게 찾을 수 있습니다. 추가 로깅을 추가할 때 로그 레벨을 합리적으로 사용하여 생산 로그를 쓸모없는 정보로 채우지 않도록 주의하세요.

### 자세한 쿼리 로그

로그에서 데이터베이스 쿼리 출력을 볼 때, 단일 메소드 호출 시 여러 개의 데이터베이스 쿼리가 왜 트리거되는지 즉시 알기 어려울 수 있습니다:

```
irb(main):001:0> Article.pamplemousse
  Article Load (0.4ms)  SELECT "articles".* FROM "articles"
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

`bin/rails console` 세션에서 `ActiveRecord.verbose_query_logs = true`를 실행하여 자세한 쿼리 로그를 활성화하고 메소드를 다시 실행하면, 이러한 개별적인 데이터베이스 호출을 생성하는 단일 코드 라인이 명확해집니다:

```
irb(main):003:0> Article.pamplemousse
  Article Load (0.2ms)  SELECT "articles".* FROM "articles"
  ↳ app/models/article.rb:5
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
  ↳ app/models/article.rb:6
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```
각 데이터베이스 문 아래에는 데이터베이스 호출로 이어지는 메서드의 소스 파일 이름(및 라인 번호)을 가리키는 화살표가 표시됩니다. 이를 통해 N+1 쿼리로 인해 발생하는 성능 문제를 식별하고 해결할 수 있습니다. N+1 쿼리는 여러 추가 쿼리를 생성하는 단일 데이터베이스 쿼리입니다.

Rails 5.2 이후 개발 환경 로그에서는 자세한 쿼리 로그가 기본적으로 활성화됩니다.

경고: 운영 환경에서 이 설정을 사용하는 것을 권장하지 않습니다. 이 설정은 루비의 `Kernel#caller` 메서드에 의존하며, 메서드 호출의 스택 추적을 생성하기 위해 많은 메모리를 할당하는 경향이 있습니다. 대신 쿼리 로그 태그를 사용하세요(아래 참조).

### 자세한 Enqueue 로그

위의 "자세한 쿼리 로그"와 유사하게, 백그라운드 작업을 예약하는 메서드의 소스 위치를 출력할 수 있습니다.

개발 환경에서 기본적으로 활성화되어 있습니다. 다른 환경에서 활성화하려면 `application.rb` 또는 환경 초기화 파일에 다음을 추가하세요:

```rb
config.active_job.verbose_enqueue_logs = true
```

자세한 쿼리 로그와 마찬가지로, 운영 환경에서는 권장하지 않습니다.

SQL 쿼리 주석
------------------

SQL 문은 컨트롤러 또는 작업의 이름과 같은 런타임 정보를 포함하는 태그로 주석 처리할 수 있습니다. 이를 통해 느린 쿼리를 기록할 때(예: [MySQL](https://dev.mysql.com/doc/refman/en/slow-query-log.html), [PostgreSQL](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT)), 현재 실행 중인 쿼리를 확인할 때 또는 엔드 투 엔드 추적 도구에 유용합니다.

활성화하려면 `application.rb` 또는 환경 초기화 파일에 다음을 추가하세요:

```rb
config.active_record.query_log_tags_enabled = true
```

기본적으로 응용 프로그램의 이름, 컨트롤러의 이름과 액션 또는 작업의 이름이 로그에 기록됩니다. 기본 형식은 [SQLCommenter](https://open-telemetry.github.io/opentelemetry-sqlcommenter/)입니다. 예를 들면 다음과 같습니다:

```
Article Load (0.2ms)  SELECT "articles".* FROM "articles" /*application='Blog',controller='articles',action='index'*/

Article Update (0.3ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ? WHERE "posts"."id" = ? /*application='Blog',job='ImproveTitleJob'*/  [["title", "Improved Rails debugging guide"], ["updated_at", "2022-10-16 20:25:40.091371"], ["id", 1]]
```

[`ActiveRecord::QueryLogs`](https://api.rubyonrails.org/classes/ActiveRecord/QueryLogs.html)의 동작은 SQL 쿼리와 연결하는 데 도움이 되는 모든 것을 포함하도록 수정할 수 있습니다. 예를 들어 응용 프로그램 로그의 요청 및 작업 ID, 계정 및 테넌트 식별자 등입니다.

### 태그된 로깅

다중 사용자, 다중 계정 애플리케이션을 실행할 때 로그를 사용자 정의 규칙을 사용하여 필터링하는 것이 유용합니다. Active Support의 `TaggedLogging`을 사용하면 하위 도메인, 요청 ID 및 디버깅에 도움이 되는 기타 사항을 로그 라인에 표시하여 이러한 애플리케이션의 디버깅을 지원할 수 있습니다.

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # "[BCX] Stuff" 로그
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # "[BCX] [Jason] Stuff" 로그
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # "[BCX] [Jason] Stuff" 로그
```

### 로그의 성능에 미치는 영향

로그 기록은 항상 Rails 애플리케이션의 성능에 약간의 영향을 미칩니다. 특히 디스크에 로그를 기록할 때 그 영향이 커집니다. 또한 몇 가지 주의사항이 있습니다:

`:debug` 레벨을 사용하는 것은 `:fatal`보다 성능에 더 큰 영향을 미칩니다. 왜냐하면 더 많은 문자열이 평가되고 로그 출력(예: 디스크)에 기록되기 때문입니다.

코드에서 `Logger`에 대한 호출이 너무 많은 경우 또 다른 잠재적인 문제가 될 수 있습니다:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

위의 예에서는 허용된 출력 레벨에 디버그가 포함되어 있지 않아도 성능에 영향을 줄 수 있습니다. 그 이유는 루비가 이러한 문자열을 평가해야 하기 때문입니다. 이 과정에는 상당히 무거운 `String` 객체의 인스턴스화와 변수의 보간이 포함됩니다.
따라서, 로거 메서드에 블록을 전달하는 것이 권장됩니다. 이는 출력 레벨이 허용된 레벨과 동일하거나 포함되어 있는 경우에만 평가되기 때문에 (즉, 지연 로딩), 성능 절약을 위해 블록을 전달하는 것이 좋습니다. 같은 코드를 다시 작성하면 다음과 같습니다:

```ruby
logger.debug { "Person attributes hash: #{@person.attributes.inspect}" }
```

블록의 내용 및 따라서 문자열 보간은 디버그가 활성화된 경우에만 평가됩니다. 이러한 성능 절약은 로깅이 많은 양으로 이루어진 경우에만 실제로 눈에 띄지만, 이는 좋은 관행입니다.

INFO: 이 섹션은 [Jon Cairns의 스택 오버플로우 답변](https://stackoverflow.com/questions/16546730/logging-in-rails-is-there-any-performance-hit/16546935#16546935)에 의해 작성되었으며 [cc by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/)로 라이선스가 부여되었습니다.

`debug` 젬을 사용한 디버깅
------------------------------

코드가 예상치 못한 방식으로 동작할 때, 문제를 진단하기 위해 로그나 콘솔에 출력해 볼 수 있습니다. 그러나 때로는 이러한 오류 추적이 문제의 근본 원인을 찾는 데 효과적이지 않을 때도 있습니다. 실제로 실행 중인 소스 코드로 진입해야 하는 경우 디버거가 가장 좋은 동반자입니다.

디버거는 또한 Rails 소스 코드에 대해 배우고 싶지만 어디서부터 시작해야 할지 모를 때도 도움이 될 수 있습니다. 애플리케이션에 대한 요청을 디버그하고 이 가이드를 사용하여 작성한 코드에서 기본적인 Rails 코드로 이동하는 방법을 배울 수 있습니다.

Rails 7은 CRuby로 생성된 새로운 애플리케이션의 `Gemfile`에 `debug` 젬을 포함하고 있습니다. 기본적으로 `development` 및 `test` 환경에서 사용할 수 있습니다. 사용법에 대해서는 [문서](https://github.com/ruby/debug)를 확인하십시오.

### 디버깅 세션 진입

기본적으로 디버깅 세션은 `debug` 라이브러리가 필요한 경우, 즉 앱이 부팅될 때 시작됩니다. 하지만 걱정하지 마세요, 세션은 애플리케이션에 영향을 미치지 않습니다.

디버깅 세션에 진입하려면 `binding.break` 및 그 별칭인 `binding.b` 및 `debugger`를 사용할 수 있습니다. 다음 예제에서는 `debugger`를 사용합니다:

```rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    debugger
  end
  # ...
end
```

앱이 디버깅 문을 평가하면 디버깅 세션에 진입합니다:

```rb
Processing by PostsController#index as HTML
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg)
```

디버깅 세션을 언제든지 종료하고 `continue` (또는 `c`) 명령을 사용하여 애플리케이션 실행을 계속할 수 있습니다. 또는 디버깅 세션과 애플리케이션 모두를 종료하려면 `quit` (또는 `q`) 명령을 사용하십시오.

### 컨텍스트

디버깅 세션에 진입한 후에는 Rails 콘솔이나 IRB에 있는 것처럼 Ruby 코드를 입력할 수 있습니다.

```rb
(rdbg) @posts    # ruby
[]
(rdbg) self
#<PostsController:0x0000000000aeb0>
(rdbg)
```

변수 이름이 디버거 명령과 충돌하는 경우 유용한 `p` 또는 `pp` 명령을 사용하여 Ruby 표현식을 평가할 수도 있습니다.
```rb
(rdbg) p headers    # 명령어
=> {"X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "X-Download-Options"=>"noopen", "X-Permitted-Cross-Domain-Policies"=>"none", "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg) pp headers    # 명령어
{"X-Frame-Options"=>"SAMEORIGIN",
 "X-XSS-Protection"=>"1; mode=block",
 "X-Content-Type-Options"=>"nosniff",
 "X-Download-Options"=>"noopen",
 "X-Permitted-Cross-Domain-Policies"=>"none",
 "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg)
```

직접 평가하는 것 외에도 디버거는 다양한 명령어를 통해 다양한 정보를 수집하는 데 도움이 됩니다. 예를 들어 다음과 같은 명령어가 있습니다.

- `info` (또는 `i`) - 현재 프레임에 대한 정보를 제공합니다.
- `backtrace` (또는 `bt`) - 추가 정보와 함께 백트레이스를 표시합니다.
- `outline` (또는 `o`, `ls`) - 현재 스코프에서 사용 가능한 메서드, 상수, 로컬 변수 및 인스턴스 변수를 나열합니다.

#### `info` 명령어

`info`는 현재 프레임에서 볼 수 있는 로컬 및 인스턴스 변수의 값을 개요 형식으로 제공합니다.

```rb
(rdbg) info    # 명령어
%self = #<PostsController:0x0000000000af78>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fd91a037e38 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fd91a03ea08 @mon_data=#<Monitor:0x00007fd91a03e8c8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = []
@rendered_format = nil
```

#### `backtrace` 명령어

옵션 없이 사용하면 `backtrace`는 스택의 모든 프레임을 나열합니다.

```rb
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  #2    AbstractController::Base#process_action(method_name="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/base.rb:214
  #3    ActionController::Rendering#process_action(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/rendering.rb:53
  #4    block in process_action at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/callbacks.rb:221
  #5    block in run_callbacks at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:118
  #6    ActionText::Rendering::ClassMethods#with_renderer(renderer=#<PostsController:0x0000000000af78>) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/rendering.rb:20
  #7    block {|controller=#<PostsController:0x0000000000af78>, action=#<Proc:0x00007fd91985f1c0 /Users/st0012/...|} in <class:Engine> (4 levels) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/engine.rb:69
  #8    [C] BasicObject#instance_exec at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:127
  ..... 그리고 더 많음
```

각 프레임에는 다음이 포함됩니다.

- 프레임 식별자
- 호출 위치
- 추가 정보 (예: 블록 또는 메서드 인수)

이를 통해 앱에서 무슨 일이 일어나고 있는지에 대한 좋은 감을 얻을 수 있습니다. 그러나 아마도 다음 사항을 알아채게 될 것입니다.

- 프레임이 너무 많습니다 (일반적으로 Rails 앱에서는 50개 이상).
- 대부분의 프레임은 Rails 또는 사용하는 다른 라이브러리에서 가져온 것입니다.

`backtrace` 명령에는 프레임을 필터링하는 데 도움이 되는 2가지 옵션이 있습니다.

- `backtrace [num]` - `num`개의 프레임만 표시합니다. 예: `backtrace 10`.
- `backtrace /pattern/` - 식별자 또는 위치가 패턴과 일치하는 프레임만 표시합니다. 예: `backtrace /MyModel/`.

이러한 옵션을 함께 사용하는 것도 가능합니다. `backtrace [num] /pattern/`입니다.

#### `outline` 명령어

`outline`은 `pry` 및 `irb`의 `ls` 명령어와 유사합니다. 현재 스코프에서 액세스할 수 있는 내용을 보여줍니다. 다음을 포함합니다.

- 로컬 변수
- 인스턴스 변수
- 클래스 변수
- 메서드 및 소스

```rb
ActiveSupport::Configurable#methods: config
AbstractController::Base#methods:
  action_methods  action_name  action_name=  available_action?  controller_path  inspect
  response_body
ActionController::Metal#methods:
  content_type       content_type=  controller_name  dispatch          headers
  location           location=      media_type       middleware_stack  middleware_stack=
  middleware_stack?  performed?     request          request=          reset_session
  response           response=      response_body=   response_code     session
  set_request!       set_response!  status           status=           to_a
ActionView::ViewPaths#methods:
  _prefixes  any_templates?  append_view_path   details_for_lookup  formats     formats=  locale
  locale=    lookup_context  prepend_view_path  template_exists?    view_paths
AbstractController::Rendering#methods: view_assigns

# .....

PostsController#methods: create  destroy  edit  index  new  show  update
instance variables:
  @_action_has_layout  @_action_name    @_config  @_lookup_context                      @_request
  @_response           @_response_body  @_routes  @marked_for_same_origin_verification  @posts
  @rendered_format
class variables: @@raise_on_missing_translations  @@raise_on_open_redirects
```

### 중단점

디버거에서 중단점을 삽입하고 트리거하는 여러 가지 방법이 있습니다. 코드에 직접 디버깅 문(예: `debugger`)을 추가하는 것 외에도 다음 명령어로 중단점을 삽입할 수도 있습니다.

- `break` (또는 `b`)
  - `break` - 모든 중단점을 나열합니다.
  - `break <num>` - 현재 파일의 `num` 줄에 중단점을 설정합니다.
  - `break <file:num>` - `file`의 `num` 줄에 중단점을 설정합니다.
  - `break <Class#method>` 또는 `break <Class.method>` - `Class#method` 또는 `Class.method`에 중단점을 설정합니다.
  - `break <expr>.<method>` - `<expr>` 결과의 `<method>` 메서드에 중단점을 설정합니다.
- `catch <Exception>` - `Exception`이 발생할 때 중단점을 설정합니다.
- `watch <@ivar>` - 현재 객체의 `@ivar`의 결과가 변경될 때 중단점을 설정합니다 (느립니다).
그리고 그것들을 제거하려면 다음을 사용할 수 있습니다:

- `delete` (또는 `del`)
  - `delete` - 모든 중단점 삭제
  - `delete <num>` - id가 `num`인 중단점 삭제

#### `break` 명령어

**지정된 줄 번호에 중단점 설정 - 예: `b 28`**

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # 그리고 72개의 프레임 (`bt` 명령어를 사용하여 모든 프레임 표시)
(rdbg) b 28    # break 명령어
#0  BP - Line  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (line)
```

```rb
(rdbg) c    # continue 명령어
[23, 32] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    23|   def create
    24|     @post = Post.new(post_params)
    25|     debugger
    26|
    27|     respond_to do |format|
=>  28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
    30|         format.json { render :show, status: :created, location: @post }
    31|       else
    32|         format.html { render :new, status: :unprocessable_entity }
=>#0    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  #1    ActionController::MimeResponds#respond_to(mimes=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/mime_responds.rb:205
  # 그리고 74개의 프레임 (`bt` 명령어를 사용하여 모든 프레임 표시)

#0  BP - Line  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (line)에서 중지
```

주어진 메서드 호출에 중단점 설정 - 예: `b @post.save`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # 그리고 72개의 프레임 (`bt` 명령어를 사용하여 모든 프레임 표시)
(rdbg) b @post.save    # break 명령어
#0  BP - Method  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43

```

```rb
(rdbg) c    # continue 명령어
[39, 48] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb
    39|         SuppressorRegistry.suppressed[name] = previous_state
    40|       end
    41|     end
    42|
    43|     def save(**) # :nodoc:
=>  44|       SuppressorRegistry.suppressed[self.class.name] ? true : super
    45|     end
    46|
    47|     def save!(**) # :nodoc:
    48|       SuppressorRegistry.suppressed[self.class.name] ? true : super
=>#0    ActiveRecord::Suppressor#save(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:44
  #1    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  # 그리고 75개의 프레임 (`bt` 명령어를 사용하여 모든 프레임 표시)

#0  BP - Method  @post.save at /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43에서 중지
```

#### `catch` 명령어

예외가 발생할 때 중지 - 예: `catch ActiveRecord::RecordInvalid`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # 그리고 72개의 프레임 (`bt` 명령어를 사용하여 모든 프레임 표시)
(rdbg) catch ActiveRecord::RecordInvalid    # 명령어
#1  BP - Catch  "ActiveRecord::RecordInvalid"
```

```rb
(rdbg) c    # continue 명령어
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # 그리고 88개의 프레임 (`bt` 명령어를 사용하여 모든 프레임 표시)

#1  BP - Catch  "ActiveRecord::RecordInvalid"에서 중지
```
#### `watch` 명령어

인스턴스 변수가 변경될 때 멈춥니다. 예: `watch @_response_body`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # 그리고 72개의 프레임 (모든 프레임을 보려면 `bt` 명령어 사용)
(rdbg) watch @_response_body    # 명령어
#0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =
```

```rb
(rdbg) c    # 계속 명령어
[173, 182] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb
   173|       body = [body] unless body.nil? || body.respond_to?(:each)
   174|       response.reset_body!
   175|       return unless body
   176|       response.body = body
   177|       super
=> 178|     end
   179|
   180|     # Tests if render or redirect has already happened.
   181|     def performed?
   182|       response_body || response.committed?
=>#0    ActionController::Metal#response_body=(body=["<html><body>You are being <a href=\"ht...) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb:178 #=> ["<html><body>You are being <a href=\"ht...
  #1    ActionController::Redirecting#redirect_to(options=#<Post id: 13, title: "qweqwe", content:..., response_options={:allow_other_host=>false}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/redirecting.rb:74
  # 그리고 82개의 프레임 (모든 프레임을 보려면 `bt` 명령어 사용)

#0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =  -> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
(rdbg)
```

#### 중단점 옵션

다양한 종류의 중단점 외에도, 더 고급 디버깅 워크플로우를 위해 옵션을 지정할 수도 있습니다. 현재 디버거는 4개의 옵션을 지원합니다:

- `do: <cmd 또는 expr>` - 중단점이 트리거될 때 지정된 명령어/표현식을 실행하고 프로그램을 계속합니다:
  - `break Foo#bar do: bt` - `Foo#bar`가 호출될 때 스택 프레임을 출력합니다.
- `pre: <cmd 또는 expr>` - 중단점이 트리거될 때 멈추기 전에 지정된 명령어/표현식을 실행합니다:
  - `break Foo#bar pre: info` - `Foo#bar`가 호출될 때 멈추기 전에 주변 변수를 출력합니다.
- `if: <expr>` - 중단점은 `<expr>`의 결과가 true인 경우에만 멈춥니다:
  - `break Post#save if: params[:debug]` - `params[:debug]`가 true인 경우에만 `Post#save`에서 멈춥니다.
- `path: <path_regexp>` - 중단점은 트리거하는 이벤트(예: 메소드 호출)가 지정된 경로에서 발생하는 경우에만 멈춥니다:
  - `break Post#save if: app/services/a_service` - 메소드 호출이 Ruby 정규식 `/app\/services\/a_service/`와 일치하는 메소드에서 `Post#save`에서 멈춥니다.

또한 앞서 언급한 디버그 문에서도 `do:`, `pre:`, `if:`와 같은 첫 3개의 옵션을 사용할 수 있다는 점에 유의해주세요. 예를 들면:

```rb
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger(do: "info")
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # 그리고 72개의 프레임 (모든 프레임을 보려면 `bt` 명령어 사용)
(rdbg:binding.break) info
%self = #<PostsController:0x00000000017480>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fce3ad336b8 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fce3ad397e8 @mon_data=#<Monitor:0x00007fce3ad396a8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = #<ActiveRecord::Relation [#<Post id: 2, title: "qweqwe", content: "qweqwe", created_at: "...
@rendered_format = nil
```
#### 디버깅 워크플로우 프로그래밍하기

이러한 옵션을 사용하여 다음과 같이 디버깅 워크플로우를 한 줄로 스크립트화할 수 있습니다.

```rb
def create
  debugger(do: "catch ActiveRecord::RecordInvalid do: bt 10")
  # ...
end
```

그런 다음 디버거는 스크립트된 명령을 실행하고 catch 중단점을 삽입합니다.

```rb
(rdbg:binding.break) catch ActiveRecord::RecordInvalid do: bt 10
#0  BP - Catch  "ActiveRecord::RecordInvalid"
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # 그리고 88개의 프레임 (`bt` 명령을 사용하여 모든 프레임을 확인하세요)
```

catch 중단점이 트리거되면 스택 프레임이 출력됩니다.

```rb
Stop by #0  BP - Catch  "ActiveRecord::RecordInvalid"

(rdbg:catch) bt 10
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  #2    block in save! at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/transactions.rb:302
```

이 기술을 사용하면 반복적인 수동 입력을 피하고 디버깅 경험을 원활하게 만들 수 있습니다.

더 많은 명령어와 구성 옵션은 [문서](https://github.com/ruby/debug)에서 찾을 수 있습니다.

`web-console` 젬을 사용한 디버깅
------------------------------------

Web Console은 `debug`와 비슷하지만 브라우저에서 실행됩니다. 뷰나 컨트롤러의 컨텍스트에서 어떤 페이지에서든 콘솔을 요청할 수 있습니다. 콘솔은 HTML 콘텐츠 옆에 렌더링됩니다.

### 콘솔

컨트롤러 액션이나 뷰 내에서 `console` 메서드를 호출하여 콘솔을 호출할 수 있습니다.

예를 들어, 컨트롤러에서:

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

뷰에서:

```html+erb
<% console %>

<h2>New Post</h2>
```

이렇게 하면 뷰 내에 콘솔이 렌더링됩니다. `console` 호출의 위치에 대해 신경 쓸 필요가 없습니다. 호출된 위치에 렌더링되지 않고 HTML 콘텐츠 옆에 렌더링됩니다.

콘솔은 순수한 Ruby 코드를 실행합니다. 사용자 정의 클래스를 정의하고 인스턴스를 생성하며 새로운 모델을 만들고 변수를 검사할 수 있습니다.

참고: 한 번에 하나의 콘솔만 렌더링될 수 있습니다. 그렇지 않으면 `web-console`은 두 번째 `console` 호출에서 오류를 발생시킵니다.

### 변수 검사

`instance_variables`를 호출하여 컨텍스트에서 사용 가능한 모든 인스턴스 변수를 나열할 수 있습니다. 로컬 변수를 나열하려면 `local_variables`를 사용할 수 있습니다.

### 설정

* `config.web_console.allowed_ips`: 허용된 IPv4 또는 IPv6 주소 및 네트워크 목록 (기본값: `127.0.0.1/8, ::1`).
* `config.web_console.whiny_requests`: 콘솔 렌더링이 방지될 때 메시지를 로그에 기록할지 여부 (기본값: `true`).

`web-console`은 서버에서 원격으로 일반 Ruby 코드를 평가하기 때문에 프로덕션 환경에서 사용하지 마십시오.

메모리 누수 디버깅
----------------------

루비 애플리케이션(레일즈 포함)은 루비 코드나 C 코드 수준에서 메모리 누수가 발생할 수 있습니다.

이 섹션에서는 Valgrind와 같은 도구를 사용하여 이러한 누수를 찾고 수정하는 방법을 알아보겠습니다.

### Valgrind

[Valgrind](http://valgrind.org/)는 C 기반 메모리 누수와 경합 조건을 감지하는 애플리케이션입니다.

Valgrind 도구를 사용하면 많은 메모리 관리 및 스레딩 버그를 자동으로 감지하고 프로그램을 자세히 프로파일링할 수 있습니다. 예를 들어, 인터프리터의 C 확장이 `malloc()`을 호출하지만 `free()`를 제대로 호출하지 않으면 이 메모리는 앱이 종료될 때까지 사용할 수 없습니다.
Valgrind와 Ruby를 설치하고 사용하는 방법에 대한 자세한 정보는 Evan Weaver의 [Valgrind and Ruby](https://blog.evanweaver.com/2008/02/05/valgrind-and-ruby/)를 참조하십시오.

### 메모리 누수 찾기

Derailed에서 메모리 누수를 감지하고 수정하는 방법에 대한 훌륭한 기사가 있습니다. [여기에서 읽을 수 있습니다](https://github.com/schneems/derailed_benchmarks#is-my-app-leaking-memory).

디버깅을 위한 플러그인
---------------------

일부 Rails 플러그인을 사용하면 오류를 찾고 응용 프로그램을 디버깅하는 데 도움이 됩니다. 디버깅에 유용한 플러그인 목록은 다음과 같습니다:

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master) 쿼리의 원본을 추적하여 로그에 추가합니다.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master) Rails 응용 프로그램에서 오류가 발생할 때 이메일 알림을 보내기 위한 메일러 객체와 기본 템플릿을 제공합니다.
* [Better Errors](https://github.com/charliesome/better_errors) 기존의 Rails 오류 페이지를 소스 코드 및 변수 검사와 같은 상세한 정보를 포함한 새로운 페이지로 대체합니다.
* [RailsPanel](https://github.com/dejan/rails_panel) 개발.log를 계속 추적하지 않아도 되는 Rails 개발용 Chrome 확장 프로그램입니다. 브라우저에서 Rails 앱 요청에 대한 모든 정보를 개발자 도구 패널에서 확인할 수 있습니다. 데이터베이스/렌더링/전체 시간, 매개변수 목록, 렌더링된 뷰 등을 제공합니다.
* [Pry](https://github.com/pry/pry) IRB 대체 및 런타임 개발자 콘솔입니다.

참고 자료
----------

* [web-console 홈페이지](https://github.com/rails/web-console)
* [debug 홈페이지](https://github.com/ruby/debug)
