**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 7dbd0564d604e07d111b2a827bef559f
레일스 커맨드 라인
======================

이 가이드를 읽으면 다음을 알게 됩니다:

* 레일스 애플리케이션을 생성하는 방법
* 모델, 컨트롤러, 데이터베이스 마이그레이션 및 유닛 테스트를 생성하는 방법
* 개발 서버를 시작하는 방법
* 대화형 셸을 통해 객체를 실험하는 방법

--------------------------------------------------------------------------------

참고: 이 튜토리얼은 [레일스 시작 가이드](getting_started.html)를 읽어 기본적인 레일스 지식이 있다고 가정합니다.

레일스 앱 생성
--------------------

먼저, `rails new` 커맨드를 사용하여 간단한 레일스 애플리케이션을 생성해 보겠습니다.

이 애플리케이션을 사용하여 이 가이드에서 설명하는 모든 커맨드를 플레이하고 발견할 수 있습니다.

INFO: 이미 레일스 젬이 설치되어 있지 않은 경우 `gem install rails`를 입력하여 설치할 수 있습니다.

### `rails new`

`rails new` 커맨드에 전달하는 첫 번째 인자는 애플리케이션 이름입니다.

```bash
$ rails new my_app
     create
     create  README.md
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

레일스는 이렇게 작은 커맨드에 대해 엄청난 양의 작업을 설정합니다! 이제 우리는 필요한 모든 코드를 가지고 간단한 애플리케이션을 실행할 수 있는 전체 레일스 디렉토리 구조를 갖게 되었습니다.

일부 파일을 생성하지 않거나 일부 라이브러리를 건너뛰고 싶다면 `rails new` 커맨드에 다음 중 하나의 인자를 추가할 수 있습니다:

| 인자                    | 설명                                                 |
| ----------------------- | ----------------------------------------------------------- |
| `--skip-git`            | git init, .gitignore 및 .gitattributes를 건너뛰기               |
| `--skip-docker`         | Dockerfile, .dockerignore 및 bin/docker-entrypoint를 건너뛰기    |
| `--skip-keeps`          | 소스 컨트롤 .keep 파일 건너뛰기                             |
| `--skip-action-mailer`  | Action Mailer 파일 건너뛰기                                    |
| `--skip-action-mailbox` | Action Mailbox 젬 건너뛰기                                     |
| `--skip-action-text`    | Action Text 젬 건너뛰기                                        |
| `--skip-active-record`  | Active Record 파일 건너뛰기                                    |
| `--skip-active-job`     | Active Job 건너뛰기                                             |
| `--skip-active-storage` | Active Storage 파일 건너뛰기                                   |
| `--skip-action-cable`   | Action Cable 파일 건너뛰기                                     |
| `--skip-asset-pipeline` | Asset Pipeline 건너뛰기                                         |
| `--skip-javascript`     | JavaScript 파일 건너뛰기                                       |
| `--skip-hotwire`        | Hotwire 통합 건너뛰기                                          |
| `--skip-jbuilder`       | jbuilder 젬 건너뛰기                                           |
| `--skip-test`           | 테스트 파일 건너뛰기                                             |
| `--skip-system-test`    | 시스템 테스트 파일 건너뛰기                                      |
| `--skip-bootsnap`       | bootsnap 젬 건너뛰기                                           |

이것은 `rails new`가 받아들이는 옵션 중 일부에 불과합니다. 전체 옵션 목록은 `rails new --help`를 입력하면 확인할 수 있습니다.

### 다른 데이터베이스 사전 구성

새로운 레일스 애플리케이션을 생성할 때, 애플리케이션이 사용할 데이터베이스 종류를 지정할 수 있습니다. 이렇게 하면 몇 분과 많은 타이핑을 절약할 수 있습니다.

`--database=postgresql` 옵션을 사용해보겠습니다:

```bash
$ rails new petstore --database=postgresql
      create
      create  app/controllers
      create  app/helpers
...
```

`config/database.yml`에 어떤 내용이 들어 있는지 확인해 보겠습니다:

```yaml
# PostgreSQL. Versions 9.3 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On macOS with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On Windows:
#   gem install pg
#       Choose the win32 build.
#       Install PostgreSQL and put its /bin directory on your path.
#
# Configure Using Gemfile
# gem "pg"
#
default: &default
  adapter: postgresql
  encoding: unicode

  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: petstore_development
...
```

우리가 선택한 PostgreSQL에 해당하는 데이터베이스 구성을 생성했습니다.

커맨드 라인 기본 사항
-------------------

레일스를 일상적으로 사용하는 데 절대적으로 필수적인 몇 가지 커맨드가 있습니다. 아마도 다음과 같은 순서로 사용할 것입니다:

* `bin/rails console`
* `bin/rails server`
* `bin/rails test`
* `bin/rails generate`
* `bin/rails db:migrate`
* `bin/rails db:create`
* `bin/rails routes`
* `bin/rails dbconsole`
* `rails new app_name`

현재 디렉토리에 따라 종종 다르게 사용할 수 있는 레일스 커맨드 목록을 얻으려면 `rails --help`를 입력하면 됩니다. 각 커맨드에는 설명이 포함되어 있으며 필요한 항목을 찾을 수 있도록 도와줍니다.

```bash
$ rails --help
Usage:
  bin/rails COMMAND [options]

You must specify a command. The most common commands are:

  generate     Generate new code (short-cut alias: "g")
  console      Start the Rails console (short-cut alias: "c")
  server       Start the Rails server (short-cut alias: "s")
  ...

All commands can be run with -h (or --help) for more information.

In addition to those commands, there are:
about                               List versions of all Rails ...
assets:clean[keep]                  Remove old compiled assets
assets:clobber                      Remove compiled assets
assets:environment                  Load asset compile environment
assets:precompile                   Compile all the assets ...
...
db:fixtures:load                    Load fixtures into the ...
db:migrate                          Migrate the database ...
db:migrate:status                   Display status of migrations
db:rollback                         Roll the schema back to ...
db:schema:cache:clear               Clears a db/schema_cache.yml file
db:schema:cache:dump                Create a db/schema_cache.yml file
db:schema:dump                      Create a database schema file (either db/schema.rb or db/structure.sql ...
db:schema:load                      Load a database schema file (either db/schema.rb or db/structure.sql ...
db:seed                             Load the seed data ...
db:version                          Retrieve the current schema ...
...
restart                             Restart app by touching ...
tmp:create                          Create tmp directories ...
```
### `bin/rails server`

`bin/rails server` 명령은 Rails와 함께 번들로 제공되는 Puma라는 웹 서버를 실행합니다. 웹 브라우저를 통해 애플리케이션에 접근하려는 경우에 사용합니다.

추가 작업 없이 `bin/rails server`를 실행하면 다음과 같이 새로운 Rails 앱이 실행됩니다:

```bash
$ cd my_app
$ bin/rails server
=> Booting Puma
=> Rails 7.0.0 application starting in development
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Version 3.12.1 (ruby 2.5.7-p206), codename: Llamas in Pajamas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
```

이 세 가지 명령만으로 3000번 포트에서 실행되는 Rails 서버를 만들었습니다. 브라우저에서 [http://localhost:3000](http://localhost:3000)을 열면 기본적인 Rails 앱이 실행되는 것을 볼 수 있습니다.

INFO: "s"라는 별칭을 사용하여 서버를 시작할 수도 있습니다: `bin/rails s`.

`-p` 옵션을 사용하여 서버를 다른 포트에서 실행할 수 있습니다. `-e` 옵션을 사용하여 기본 개발 환경을 변경할 수 있습니다.

```bash
$ bin/rails server -e production -p 4000
```

`-b` 옵션은 Rails를 지정된 IP에 바인딩합니다. 기본값은 localhost입니다. `-d` 옵션을 전달하여 서버를 데몬으로 실행할 수도 있습니다.

### `bin/rails generate`

`bin/rails generate` 명령은 템플릿을 사용하여 다양한 항목을 생성합니다. `bin/rails generate`만 실행하면 사용 가능한 생성기 목록이 표시됩니다:

INFO: 생성기 명령을 호출하기 위해 "g"라는 별칭을 사용할 수도 있습니다: `bin/rails g`.

```bash
$ bin/rails generate
Usage:
  bin/rails generate GENERATOR [args] [options]

...
...

Please choose a generator below.

Rails:
  assets
  channel
  controller
  generator
  ...
  ...
```

NOTE: 생성기 젬을 통해 더 많은 생성기를 설치할 수 있으며, 플러그인의 일부로 생성기를 설치할 수도 있으며, 직접 생성기를 만들 수도 있습니다!

생성기를 사용하면 앱이 작동하는 데 필요한 **보일러플레이트 코드**(기본 코드)를 작성하는 데 많은 시간을 절약할 수 있습니다.

컨트롤러 생성기를 사용하여 직접 컨트롤러를 만들어 보겠습니다. 어떤 명령을 사용해야 할까요? 생성기에 물어보겠습니다:

INFO: 모든 Rails 콘솔 유틸리티에는 도움말 텍스트가 있습니다. 대부분의 *nix 유틸리티와 마찬가지로 `--help` 또는 `-h`를 추가해 볼 수 있습니다. 예를 들어 `bin/rails server --help`와 같이 사용할 수 있습니다.

```bash
$ bin/rails generate controller
Usage:
  bin/rails generate controller NAME [action action] [options]

...
...

Description:
    ...

    To create a controller within a module, specify the controller name as a path like 'parent_module/controller_name'.

    ...

Example:
    `bin/rails generate controller CreditCards open debit credit close`

    Credit card controller with URLs like /credit_cards/debit.
        Controller: app/controllers/credit_cards_controller.rb
        Test:       test/controllers/credit_cards_controller_test.rb
        Views:      app/views/credit_cards/debit.html.erb [...]
        Helper:     app/helpers/credit_cards_helper.rb
```

컨트롤러 생성기는 `generate controller ControllerName action1 action2` 형식의 매개변수를 기대합니다. **hello**라는 액션을 가진 `Greetings` 컨트롤러를 만들어 보겠습니다. 이 액션은 우리에게 좋은 메시지를 전달할 것입니다.

```bash
$ bin/rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get 'greetings/hello'
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke    test_unit
```

이것이 생성한 모든 것입니다. 애플리케이션에 일련의 디렉토리가 있도록 하고, 컨트롤러 파일, 뷰 파일, 기능 테스트 파일, 뷰를 위한 헬퍼, JavaScript 파일 및 스타일시트 파일을 생성했습니다.

컨트롤러를 확인하고 약간 수정해 보겠습니다(`app/controllers/greetings_controller.rb`):

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Hello, how are you today?"
  end
end
```

그런 다음 메시지를 표시하기 위해 뷰를 수정해 보겠습니다(`app/views/greetings/hello.html.erb`):

```erb
<h1>A Greeting for You!</h1>
<p><%= @message %></p>
```

`bin/rails server`를 사용하여 서버를 실행해 보세요.

```bash
$ bin/rails server
=> Booting Puma...
```

URL은 [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello)입니다.

INFO: 일반적인 Rails 애플리케이션의 경우 URL은 일반적으로 http://(호스트)/(컨트롤러)/(액션)과 같은 패턴을 따르며, http://(호스트)/(컨트롤러)와 같은 URL은 해당 컨트롤러의 **index** 액션에 해당합니다.

Rails에는 데이터 모델을 위한 생성기도 함께 제공됩니다.

```bash
$ bin/rails generate model
Usage:
  bin/rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

...

ActiveRecord options:
      [--migration], [--no-migration]        # Indicates when to generate migration
                                             # Default: true

...

Description:
    Generates a new model. Pass the model name, either CamelCased or
    under_scored, and an optional list of attribute pairs as arguments.

...
```

NOTE: `type` 매개변수에 대한 사용 가능한 필드 유형 목록은 `SchemaStatements` 모듈의 `add_column` 메서드에 대한 [API 문서](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column)를 참조하십시오. `index` 매개변수는 해당 열에 대한 인덱스를 생성합니다.
그러나 모델을 직접 생성하는 대신 (나중에 할 것입니다), 스캐폴드를 설정해 봅시다. Rails에서의 **스캐폴드**는 모델, 해당 모델에 대한 데이터베이스 마이그레이션, 조작을 위한 컨트롤러, 데이터를 보고 조작하기 위한 뷰 및 위의 각각에 대한 테스트 스위트로 이루어진 완전한 세트입니다.

우리는 "HighScore"라는 간단한 리소스를 설정할 것입니다. 이 리소스는 우리가 플레이하는 비디오 게임의 최고 점수를 추적할 것입니다.

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20190416145729_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    create      test/system/high_scores_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke      test_unit
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    create      app/views/high_scores/_high_score.json.jbuilder
```

이 생성기는 HighScore에 대한 모델, 뷰, 컨트롤러, **리소스** 라우트 및 데이터베이스 마이그레이션(`high_scores` 테이블을 생성)을 생성합니다. 그리고 그에 대한 테스트도 추가됩니다.

마이그레이션은 데이터베이스의 스키마를 수정하기 위해 몇 줄의 루비 코드 (위의 출력에서 `20190416145729_create_high_scores.rb` 파일)를 실행하는 것을 요구합니다. 어떤 데이터베이스인가요? `bin/rails db:migrate` 명령을 실행할 때 Rails가 생성하는 SQLite3 데이터베이스입니다. 이 명령에 대해 더 자세히 이야기하겠습니다.

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: 유닛 테스트에 대해 이야기해 봅시다. 유닛 테스트는 코드를 테스트하고 단언을 수행하는 코드입니다. 유닛 테스트에서는 코드의 일부분, 예를 들어 모델의 메소드를 가져와서 입력과 출력을 테스트합니다. 유닛 테스트는 여러분의 친구입니다. 코드를 유닛 테스트하는 것이 여러분의 삶의 질이 크게 향상될 것이라는 사실을 조금 더 빨리 받아들이는 것이 좋습니다. 정말로요. 자세한 내용은 [테스팅 가이드](testing.html)를 참조하세요.

Rails가 생성한 인터페이스를 살펴보겠습니다.

```bash
$ bin/rails server
```

브라우저에서 [http://localhost:3000/high_scores](http://localhost:3000/high_scores)를 열어보세요. 이제 새로운 최고 점수 (Space Invaders에서 55,160점!)를 생성할 수 있습니다.

### `bin/rails console`

`console` 명령은 명령줄에서 Rails 애플리케이션과 상호작용할 수 있게 해줍니다. 내부적으로 `bin/rails console`은 IRB를 사용하므로, 이전에 사용한 적이 있다면 익숙할 것입니다. 이는 코드로 빠르게 아이디어를 테스트하고 웹사이트에 영향을 주지 않고 서버 측에서 데이터를 변경하는 데 유용합니다.

INFO: 콘솔을 호출하기 위해 "c" 별칭을 사용할 수도 있습니다: `bin/rails c`.

`console` 명령이 작동해야 하는 환경을 지정할 수 있습니다.

```bash
$ bin/rails console -e staging
```

데이터를 변경하지 않고 코드를 테스트하려면 `bin/rails console --sandbox`를 사용할 수 있습니다.

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 7.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### `app` 및 `helper` 객체

`bin/rails console` 내에서 `app` 및 `helper` 인스턴스에 액세스할 수 있습니다.

`app` 메소드를 사용하면 이름이 지정된 라우트 헬퍼에 액세스하거나 요청을 수행할 수 있습니다.

```irb
irb> app.root_path
=> "/"

irb> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

`helper` 메소드를 사용하면 Rails 및 애플리케이션의 헬퍼에 액세스할 수 있습니다.

```irb
irb> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

irb> helper.my_custom_helper
=> "my custom helper"
```

### `bin/rails dbconsole`

`bin/rails dbconsole`은 사용 중인 데이터베이스를 파악하고 해당 데이터베이스와 함께 사용하는 명령줄 인터페이스로 이동시킵니다 (또한 해당 명령줄 인터페이스에 제공해야 할 명령줄 매개변수도 파악합니다!). MySQL (MariaDB 포함), PostgreSQL 및 SQLite3을 지원합니다.

INFO: `dbconsole`을 호출하기 위해 "db" 별칭을 사용할 수도 있습니다: `bin/rails db`.

여러 개의 데이터베이스를 사용하는 경우, `bin/rails dbconsole`은 기본적으로 기본 데이터베이스에 연결합니다. `--database` 또는 `--db`를 사용하여 연결할 데이터베이스를 지정할 수 있습니다.

```bash
$ bin/rails dbconsole --database=animals
```

### `bin/rails runner`

`runner`는 Rails의 환경에서 Ruby 코드를 비대화식으로 실행합니다. 예를 들어:

```bash
$ bin/rails runner "Model.long_running_method"
```

INFO: `runner`를 호출하기 위해 "r" 별칭을 사용할 수도 있습니다: `bin/rails r`.

`runner` 명령이 작동해야 하는 환경을 `-e` 스위치를 사용하여 지정할 수 있습니다.

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```
실행 파일(runner)을 사용하여 파일에 작성된 루비 코드를 실행할 수도 있습니다.

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `bin/rails destroy`

`destroy`는 `generate`의 반대 개념으로 생각할 수 있습니다. generate가 무엇을 했는지 알아내고 그것을 취소합니다.

INFO: destroy 명령을 호출하기 위해 별칭 "d"를 사용할 수도 있습니다: `bin/rails d`.

```bash
$ bin/rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```

```bash
$ bin/rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

### `bin/rails about`

`bin/rails about`은 루비, 루비젬, 레일스, 레일스 하위 구성 요소, 애플리케이션 폴더, 현재 레일스 환경 이름, 앱의 데이터베이스 어댑터 및 스키마 버전에 대한 버전 번호 정보를 제공합니다. 도움을 요청하거나 보안 패치가 영향을 미칠 수 있는지 확인하거나 기존 레일스 설치에 대한 통계를 얻을 때 유용합니다.

```bash
$ bin/rails about
About your application's environment
Rails version             7.0.0
Ruby version              2.7.0 (x86_64-linux)
RubyGems version          2.7.3
Rack version              2.0.4
JavaScript Runtime        Node.js (V8)
Middleware:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Application root          /home/foobar/my_app
Environment               development
Database adapter          sqlite3
Database schema version   20180205173523
```

### `bin/rails assets:`

`bin/rails assets:precompile`을 사용하여 `app/assets`의 에셋을 미리 컴파일하고, `bin/rails assets:clean`을 사용하여 이전에 컴파일된 에셋을 제거할 수 있습니다. `assets:clean` 명령은 새로운 에셋이 빌드되는 동안 여전히 이전 에셋에 링크되어 있는 롤링 배포를 가능하게 합니다.

`public/assets`를 완전히 지우려면 `bin/rails assets:clobber`를 사용할 수 있습니다.

### `bin/rails db:`

`db:` 레일스 네임스페이스의 가장 일반적인 명령은 `migrate`와 `create`입니다. 모든 마이그레이션 레일스 명령(`up`, `down`, `redo`, `reset`)을 시도해 보는 것이 좋습니다. `bin/rails db:version`은 문제 해결 시 현재 데이터베이스 버전을 알려주는 데 유용합니다.

마이그레이션에 대한 자세한 정보는 [마이그레이션](active_record_migrations.html) 가이드에서 찾을 수 있습니다.

### `bin/rails notes`

`bin/rails notes`는 특정 키워드로 시작하는 주석을 코드에서 검색합니다. 사용법에 대한 정보는 `bin/rails notes --help`를 참조할 수 있습니다.

기본적으로 `.builder`, `.rb`, `.rake`, `.yml`, `.yaml`, `.ruby`, `.css`, `.js`, `.erb` 확장자를 가진 파일에서 `app`, `config`, `db`, `lib`, `test` 디렉토리에서 FIXME, OPTIMIZE, TODO 주석을 검색합니다.

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

#### 주석

`--annotations` 인수를 사용하여 특정 주석을 전달할 수 있습니다. 기본적으로 FIXME, OPTIMIZE, TODO를 검색합니다.
주석은 대소문자를 구분한다는 점에 유의하세요.

```bash
$ bin/rails notes --annotations FIXME RELEASE
app/controllers/admin/users_controller.rb:
  * [101] [RELEASE] We need to look at this before next release
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 17] [FIXME]
```

#### 태그

`config.annotations.register_tags`를 사용하여 검색할 기본 태그를 추가할 수 있습니다. 태그 목록을 받습니다.

```ruby
config.annotations.register_tags("DEPRECATEME", "TESTME")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] do A/B testing on this
  * [ 42] [TESTME] this needs more functional tests
  * [132] [DEPRECATEME] ensure this method is deprecated in next release
```

#### 디렉토리

`config.annotations.register_directories`를 사용하여 검색할 기본 디렉토리를 추가할 수 있습니다. 디렉토리 이름 목록을 받습니다.

```ruby
config.annotations.register_directories("spec", "vendor")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```

#### 확장자

`config.annotations.register_extensions`를 사용하여 검색할 기본 파일 확장자를 추가할 수 있습니다. 확장자 목록과 해당 정규식을 받습니다.

```ruby
config.annotations.register_extensions("scss", "sass") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/assets/stylesheets/application.css.sass:
  * [ 34] [TODO] Use pseudo element for this class

app/assets/stylesheets/application.css.scss:
  * [  1] [TODO] Split into multiple components

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```
### `bin/rails routes`

`bin/rails routes`는 정의된 모든 라우트를 나열하며, 앱의 라우팅 문제를 추적하거나 익숙해지려는 앱의 URL에 대한 개요를 제공하는 데 유용합니다.

### `bin/rails test`

INFO: Rails에서의 유닛 테스트에 대한 좋은 설명은 [Rails 애플리케이션 테스트 가이드](testing.html)에서 찾을 수 있습니다.

Rails에는 minitest라는 테스트 프레임워크가 함께 제공됩니다. Rails의 안정성은 테스트의 사용에 기인합니다. `test:` 네임스페이스에서 사용 가능한 명령은 작성할 것으로 희망하는 다양한 테스트를 실행하는 데 도움이 됩니다.

### `bin/rails tmp:`

`Rails.root/tmp` 디렉토리는 *nix /tmp 디렉토리와 마찬가지로 프로세스 ID 파일 및 캐시된 액션과 같은 임시 파일을 보관하는 곳입니다.

`tmp:` 네임스페이스 명령은 `Rails.root/tmp` 디렉토리를 지우고 생성하는 데 도움이 됩니다:

* `bin/rails tmp:cache:clear`는 `tmp/cache`를 지웁니다.
* `bin/rails tmp:sockets:clear`는 `tmp/sockets`를 지웁니다.
* `bin/rails tmp:screenshots:clear`는 `tmp/screenshots`를 지웁니다.
* `bin/rails tmp:clear`는 모든 캐시, 소켓 및 스크린샷 파일을 지웁니다.
* `bin/rails tmp:create`는 캐시, 소켓 및 PID를 위한 tmp 디렉토리를 생성합니다.

### 기타

* `bin/rails initializers`는 Rails에서 호출되는 순서대로 정의된 모든 초기화 파일을 출력합니다.
* `bin/rails middleware`는 앱에서 활성화된 Rack 미들웨어 스택을 나열합니다.
* `bin/rails stats`는 코드에 대한 통계를 살펴보는 데 유용하며, KLOC(천 줄 코드) 및 코드 대 테스트 비율과 같은 정보를 표시합니다.
* `bin/rails secret`는 세션 비밀키로 사용할 의사 랜덤 키를 제공합니다.
* `bin/rails time:zones:all`은 Rails가 알고 있는 모든 시간대를 나열합니다.

### 사용자 정의 Rake 작업

사용자 정의 Rake 작업은 `.rake` 확장자를 가지며 `Rails.root/lib/tasks`에 위치합니다. `bin/rails generate task` 명령으로 이러한 사용자 정의 Rake 작업을 생성할 수 있습니다.

```ruby
desc "나의 멋진 작업에 대한 간단하지만 포괄적인 설명입니다"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # 여기에 마법을 부릅니다
  # 유효한 Ruby 코드는 모두 허용됩니다
end
```

사용자 정의 Rake 작업에 인수를 전달하려면:

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

네임스페이스에 작업을 그룹화할 수 있습니다:

```ruby
namespace :db do
  desc "이 작업은 아무것도 하지 않습니다"
  task :nothing do
    # 정말로 아무것도 하지 않습니다
  end
end
```

작업을 호출하는 방법은 다음과 같습니다:

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # 인수 문자열 전체를 따옴표로 묶어야 합니다
$ bin/rails "task_name[value 1,value2,value3]" # 여러 인수는 쉼표로 구분합니다
$ bin/rails db:nothing
```

애플리케이션 모델과 상호 작용하거나 데이터베이스 쿼리를 수행해야 하는 경우 작업은 `environment` 작업에 의존해야 합니다. 이 작업은 애플리케이션 코드를 로드합니다.

```ruby
task task_that_requires_app_code: [:environment] do
  User.create!
end
```
