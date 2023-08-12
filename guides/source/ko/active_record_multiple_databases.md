**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 67ad41dc27cc9079db9a7e31dffa5aac
Active Record을 사용한 여러 개의 데이터베이스
==============================================

이 가이드는 Rails 애플리케이션에서 여러 개의 데이터베이스를 사용하는 방법에 대해 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* 여러 개의 데이터베이스를 위해 애플리케이션을 설정하는 방법
* 자동 연결 전환 작동 방식
* 여러 개의 데이터베이스에 대한 수평 샤딩 사용 방법
* 지원되는 기능과 아직 진행 중인 작업

--------------------------------------------------------------------------------

애플리케이션이 인기를 얻고 사용량이 증가함에 따라 새로운 사용자와 그들의 데이터를 지원하기 위해 애플리케이션을 확장해야 할 수 있습니다. 애플리케이션은 데이터베이스 수준에서 확장될 수도 있습니다. Rails는 이제 여러 개의 데이터베이스를 지원하므로 데이터를 한 곳에 모두 저장할 필요가 없습니다.

현재 다음 기능이 지원됩니다:

* 각각에 대한 여러 개의 작성 데이터베이스와 복제본
* 작업 중인 모델에 대한 자동 연결 전환
* HTTP 동사와 최근 작성에 따라 작성자와 복제본 간의 자동 전환
* 여러 개의 데이터베이스를 생성, 삭제, 마이그레이션 및 상호 작용하기 위한 Rails 작업

다음 기능은 아직 지원되지 않습니다:

* 복제본의 로드 밸런싱

## 애플리케이션 설정

Rails는 대부분의 작업을 대신 처리하려고 노력하지만 여러 개의 데이터베이스를 사용할 준비를 위해 몇 가지 단계를 수행해야 합니다.

예를 들어, 단일 작성 데이터베이스를 가진 애플리케이션이 있고 새로운 테이블을 추가하기 위해 새로운 데이터베이스를 추가해야 한다고 가정해 봅시다. 새로운 데이터베이스의 이름은 "animals"입니다.

`database.yml`은 다음과 같이 보입니다:

```yaml
production:
  database: my_primary_database
  adapter: mysql2
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
```

첫 번째 구성에 대한 복제본과 "animals"라는 두 번째 데이터베이스와 해당 복제본을 추가해 보겠습니다. 이를 위해 `database.yml`을 2계층에서 3계층 구성으로 변경해야 합니다.

기본 구성이 제공되면 "default" 구성으로 사용됩니다. `"primary"`라는 이름의 구성이 없으면 Rails는 각 환경에 대해 첫 번째 구성을 기본값으로 사용합니다. 기본 구성은 기본 Rails 파일 이름을 사용합니다. 예를 들어, 기본 구성은 스키마 파일에 `schema.rb`를 사용하고, 다른 모든 항목은 `[CONFIGURATION_NAMESPACE]_schema.rb`를 파일 이름으로 사용합니다.

```yaml
production:
  primary:
    database: my_primary_database
    username: root
    password: <%= ENV['ROOT_PASSWORD'] %>
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    username: root_readonly
    password: <%= ENV['ROOT_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
  animals:
    database: my_animals_database
    username: animals_root
    password: <%= ENV['ANIMALS_ROOT_PASSWORD'] %>
    adapter: mysql2
    migrations_paths: db/animals_migrate
  animals_replica:
    database: my_animals_database
    username: animals_readonly
    password: <%= ENV['ANIMALS_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
```

여러 개의 데이터베이스를 사용할 때 몇 가지 중요한 설정이 있습니다.

첫 번째로, `primary`와 `primary_replica`의 데이터베이스 이름은 동일해야 합니다. 왜냐하면 동일한 데이터를 포함하기 때문입니다. `animals`와 `animals_replica`의 경우도 마찬가지입니다.

두 번째로, 작성자와 복제본의 사용자 이름은 서로 달라야 하며, 복제본 사용자의 데이터베이스 권한은 읽기만 가능하도록 설정되어야 합니다.

복제본 데이터베이스를 사용할 때는 `database.yml`의 복제본에 `replica: true` 항목을 추가해야 합니다. 그렇지 않으면 Rails는 어떤 것이 복제본이고 어떤 것이 작성자인지 알 방법이 없습니다. Rails는 마이그레이션과 같은 특정 작업을 복제본에 대해 실행하지 않습니다.

마지막으로, 새로운 작성자 데이터베이스의 경우 `migrations_paths`를 해당 데이터베이스의 마이그레이션을 저장할 디렉토리로 설정해야 합니다. 이 가이드에서는 나중에 `migrations_paths`에 대해 자세히 살펴보겠습니다.

이제 새로운 데이터베이스가 있으므로 연결 모델을 설정해 보겠습니다. 새로운 데이터베이스를 사용하려면 새로운 추상 클래스를 만들고 animals 데이터베이스에 연결해야 합니다.

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals, reading: :animals_replica }
end
```

그런 다음 `ApplicationRecord`를 업데이트하여 새로운 복제본을 인식하도록 해야 합니다.

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }
end
```

애플리케이션 레코드에 다른 이름의 클래스를 사용하는 경우 `primary_abstract_class`를 설정해야 합니다. 이렇게 하면 Rails가 `ActiveRecord::Base`가 어떤 클래스와 연결을 공유해야 하는지 알 수 있습니다.

```ruby
class PrimaryApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

기본/primary_replica에 연결하는 클래스는 일반적인 Rails 애플리케이션과 마찬가지로 기본 추상 클래스를 상속할 수 있습니다.
```ruby
class Person < ApplicationRecord
end
```

기본적으로 Rails는 기본 및 복제에 대해 `writing` 및 `reading` 데이터베이스 역할을 기대합니다. 기존 시스템이 이미 설정된 역할이 있을 수 있으며 변경하고 싶지 않을 수 있습니다. 이 경우 응용 프로그램 구성에서 새로운 역할 이름을 설정할 수 있습니다.

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

테이블에 대해 여러 개별 모델을 동일한 데이터베이스에 연결하는 대신 단일 모델에서 데이터베이스에 연결하는 것이 중요합니다. 데이터베이스 클라이언트에는 열 수 있는 연결 수에 대한 제한이 있으며 이렇게하면 모델 클래스 이름을 연결 사양 이름으로 사용하기 때문에 연결 수가 증가합니다.

이제 `database.yml`과 새로운 모델이 설정되었으므로 데이터베이스를 생성할 시간입니다. Rails 6.0에는 Rails에서 여러 개의 데이터베이스를 사용하기 위해 필요한 모든 레일 작업이 포함되어 있습니다.

`bin/rails -T`를 실행하여 실행할 수 있는 모든 명령을 확인할 수 있습니다. 다음과 같이 표시됩니다.

```bash
$ bin/rails -T
bin/rails db:create                          # DATABASE_URL 또는 config/database.yml에 대한 데이터베이스 생성
bin/rails db:create:animals                  # 현재 환경에 대한 animals 데이터베이스 생성
bin/rails db:create:primary                  # 현재 환경에 대한 primary 데이터베이스 생성
bin/rails db:drop                            # DATABASE_URL 또는 config/database.yml에 대한 데이터베이스 삭제
bin/rails db:drop:animals                    # 현재 환경에 대한 animals 데이터베이스 삭제
bin/rails db:drop:primary                    # 현재 환경에 대한 primary 데이터베이스 삭제
bin/rails db:migrate                         # 데이터베이스 마이그레이션 (옵션: VERSION=x, VERBOSE=false, SCOPE=blog)
bin/rails db:migrate:animals                 # 현재 환경에 대한 animals 데이터베이스 마이그레이션
bin/rails db:migrate:primary                 # 현재 환경에 대한 primary 데이터베이스 마이그레이션
bin/rails db:migrate:status                  # 마이그레이션 상태 표시
bin/rails db:migrate:status:animals          # animals 데이터베이스에 대한 마이그레이션 상태 표시
bin/rails db:migrate:status:primary          # primary 데이터베이스에 대한 마이그레이션 상태 표시
bin/rails db:reset                           # 현재 환경의 스키마에 따라 모든 데이터베이스를 삭제하고 다시 생성하고 시드를 로드합니다
bin/rails db:reset:animals                   # 현재 환경의 스키마에 따라 animals 데이터베이스를 삭제하고 다시 생성하고 시드를 로드합니다
bin/rails db:reset:primary                   # 현재 환경의 스키마에 따라 primary 데이터베이스를 삭제하고 다시 생성하고 시드를 로드합니다
bin/rails db:rollback                        # 이전 버전으로 스키마 롤백 (단계 지정: STEP=n)
bin/rails db:rollback:animals                # 현재 환경의 animals 데이터베이스 롤백 (단계 지정: STEP=n)
bin/rails db:rollback:primary                # 현재 환경의 primary 데이터베이스 롤백 (단계 지정: STEP=n)
bin/rails db:schema:dump                     # 데이터베이스 스키마 파일 생성 (db/schema.rb 또는 db/structure.sql ...)
bin/rails db:schema:dump:animals             # 데이터베이스 스키마 파일 생성 (db/schema.rb 또는 db/structure.sql ...)
bin/rails db:schema:dump:primary             # 모든 DB에서 이식 가능한 db/schema.rb 파일 생성 ...
bin/rails db:schema:load                     # 데이터베이스 스키마 파일 로드 (db/schema.rb 또는 db/structure.sql ...)
bin/rails db:schema:load:animals             # 데이터베이스 스키마 파일 로드 (db/schema.rb 또는 db/structure.sql ...)
bin/rails db:schema:load:primary             # 데이터베이스 스키마 파일 로드 (db/schema.rb 또는 db/structure.sql ...)
bin/rails db:setup                           # 모든 데이터베이스 생성, 모든 스키마 로드 및 시드 데이터로 초기화 (먼저 모든 데이터베이스를 삭제하려면 db:reset 사용)
bin/rails db:setup:animals                   # animals 데이터베이스 생성, 스키마 로드 및 시드 데이터로 초기화 (먼저 데이터베이스를 삭제하려면 db:reset:animals 사용)
bin/rails db:setup:primary                   # primary 데이터베이스 생성, 스키마 로드 및 시드 데이터로 초기화 (먼저 데이터베이스를 삭제하려면 db:reset:primary 사용)
```

`bin/rails db:create`와 같은 명령을 실행하면 primary 및 animals 데이터베이스가 모두 생성됩니다. 데이터베이스 사용자를 생성하는 명령은 없으며, 읽기 전용 사용자를 지원하기 위해 수동으로 생성해야 합니다. animals 데이터베이스만 생성하려면 `bin/rails db:create:animals`를 실행할 수 있습니다.

## 스키마 및 마이그레이션 관리 없이 데이터베이스에 연결하기

스키마 관리, 마이그레이션, 시드 등과 같은 데이터베이스 관리 작업 없이 외부 데이터베이스에 연결하려면 `database_tasks: false`라는 데이터베이스별 구성 옵션을 설정할 수 있습니다. 기본적으로 true로 설정되어 있습니다.

```yaml
production:
  primary:
    database: my_database
    adapter: mysql2
  animals:
    database: my_animals_database
    adapter: mysql2
    database_tasks: false
```

## 생성기 및 마이그레이션

여러 개의 데이터베이스에 대한 마이그레이션은 구성에서 데이터베이스 키의 이름으로 접두사가 있는 자체 폴더에 있어야 합니다.
또한, Rails에게 마이그레이션을 찾을 위치를 알려주기 위해 데이터베이스 구성에서 `migrations_paths`를 설정해야 합니다.

예를 들어, `animals` 데이터베이스는 `db/animals_migrate` 디렉토리에서 마이그레이션을 찾고,
`primary`는 `db/migrate`에서 찾습니다. Rails 생성기는 이제 `--database` 옵션을 사용하여
올바른 디렉토리에 파일을 생성합니다. 다음과 같이 명령을 실행할 수 있습니다:

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

Rails 생성기를 사용하는 경우, 스캐폴드 및 모델 생성기는 추상 클래스를 자동으로 생성합니다. 명령 줄에 데이터베이스 키를 전달하기만 하면 됩니다.

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

데이터베이스 이름과 `Record`로 된 클래스가 생성됩니다. 이 예제에서 데이터베이스는 `Animals`이므로 `AnimalsRecord`가 생성됩니다:

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

생성된 모델은 자동으로 `AnimalsRecord`를 상속합니다.

```ruby
class Dog < AnimalsRecord
end
```

참고: Rails는 작성자의 복제본 데이터베이스를 알지 못하기 때문에 추상 클래스에 이를 추가해야 합니다.

Rails는 새로운 클래스를 한 번만 생성합니다. 새로운 스캐폴드가 생성되거나 스캐폴드가 삭제되면 덮어쓰지 않거나 삭제하지 않습니다.

이미 추상 클래스가 있고 그 이름이 `AnimalsRecord`와 다른 경우, `--parent` 옵션을 전달하여 다른 추상 클래스를 사용하려는 것을 나타낼 수 있습니다:

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

이렇게 하면 `AnimalsRecord`를 생성하지 않고 다른 부모 클래스를 사용하도록 Rails에게 알립니다.

## 자동 역할 전환 활성화

마지막으로, 애플리케이션에서 읽기 전용 복제본을 사용하려면 자동 전환을 위한 미들웨어를 활성화해야 합니다.

자동 전환은 HTTP 동사와 요청한 사용자의 최근 쓰기 여부에 따라 애플리케이션이 작성자에서 복제본 또는 복제본에서 작성자로 전환할 수 있도록 합니다.

애플리케이션이 POST, PUT, DELETE 또는 PATCH 요청을 받는 경우 애플리케이션은 자동으로 작성자 데이터베이스에 쓰기를 수행합니다. 쓰기 후 지정된 시간 동안 애플리케이션은 주 데이터베이스에서 읽습니다. GET 또는 HEAD 요청의 경우 애플리케이션은 최근 쓰기가 없는 경우 복제본에서 읽습니다.

자동 연결 전환 미들웨어를 활성화하려면 다음과 같이 자동 전환 생성기를 실행할 수 있습니다:

```bash
$ bin/rails g active_record:multi_db
```

그런 다음 다음 줄의 주석을 해제합니다:

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

Rails는 "자신의 쓰기를 읽기"를 보장하며, GET 또는 HEAD 요청이 `delay` 창 안에 있는 경우 해당 요청을 작성자에게 보냅니다. 기본적으로 지연 시간은 2초로 설정됩니다. 데이터베이스 인프라에 따라 이 값을 변경해야 합니다. Rails는 지연 시간 창 내에서 다른 사용자를 위해 "최근 쓰기를 읽기"를 보장하지 않으며, GET 및 HEAD 요청을 최근에 쓴 복제본에 보내지 않습니다.

Rails의 자동 연결 전환은 비교적 원시적이며, 의도적으로 많은 작업을 수행하지 않습니다. 목표는 앱 개발자가 사용자 정의 가능한 자동 연결 전환을 수행하는 시스템을 구축하는 것입니다.

Rails의 설정을 통해 전환 방식과 기준을 쉽게 변경할 수 있습니다. 예를 들어, 세션 대신 쿠키를 사용하여 연결 전환을 결정하려는 경우 다음과 같이 사용자 정의 클래스를 작성할 수 있습니다:

```ruby
class MyCookieResolver << ActiveRecord::Middleware::DatabaseSelector::Resolver
  def self.call(request)
    new(request.cookies)
  end

  def initialize(cookies)
    @cookies = cookies
  end

  attr_reader :cookies

  def last_write_timestamp
    self.class.convert_timestamp_to_time(cookies[:last_write])
  end

  def update_last_write_timestamp
    cookies[:last_write] = self.class.convert_time_to_timestamp(Time.now)
  end

  def save(response)
  end
end
```

그런 다음 미들웨어에 전달합니다:

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## 수동 연결 전환 사용

일부 경우에는 자동 연결 전환만으로는 충분하지 않을 수 있습니다. 예를 들어, 특정 요청에 대해 항상 복제본에 연결하려는 경우가 있을 수 있습니다. 심지어 POST 요청 경로에서도 그렇게 하려는 경우입니다.

이 경우 Rails는 필요한 연결로 전환하기 위해 `connected_to` 메서드를 제공합니다.
```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # 이 블록 안의 모든 코드는 reading 역할에 연결됩니다.
end
```

`connected_to` 호출에서의 "role"은 해당 연결 핸들러(또는 역할)에 연결된 연결을 찾습니다. `reading` 연결 핸들러는 `connects_to`를 통해 `reading` 역할 이름으로 연결된 모든 연결을 보유합니다.

`connected_to`를 사용하여 역할을 지정하면 기존 연결을 찾고 연결 사양 이름을 사용하여 전환합니다. 따라서 `connected_to(role: :nonexistent)`와 같이 알 수 없는 역할을 전달하면 'nonexistent' 역할에 대한 'ActiveRecord::Base'의 연결 풀을 찾을 수 없다는 오류가 발생합니다.

쿼리가 읽기 전용인지 확인하려면 `prevent_writes: true`를 전달하십시오. 이렇게 하면 쓰기처럼 보이는 쿼리가 데이터베이스로 전송되지 않도록 방지합니다. 또한 읽기 전용 모드에서 복제 데이터베이스를 구성해야 합니다.

```ruby
ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
  # Rails는 각 쿼리를 확인하여 읽기 쿼리인지 확인합니다.
end
```

## 수평 샤딩

수평 샤딩은 각 데이터베이스 서버의 행 수를 줄이고 "샤드" 간에 동일한 스키마를 유지하는 방식으로 데이터베이스를 분할하는 것입니다. 이는 일반적으로 "다중 테넌트" 샤딩이라고 불립니다.

Rails에서 수평 샤딩을 지원하기 위한 API는 Rails 6.0부터 존재하는 다중 데이터베이스 / 수직 샤딩 API와 유사합니다.

샤드는 다음과 같이 3단계 구성 파일에 선언됩니다.

```yaml
production:
  primary:
    database: my_primary_database
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    adapter: mysql2
    replica: true
  primary_shard_one:
    database: my_primary_shard_one
    adapter: mysql2
  primary_shard_one_replica:
    database: my_primary_shard_one
    adapter: mysql2
    replica: true
```

모델은 `connects_to` API를 통해 `shards` 키를 사용하여 연결됩니다.

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

첫 번째 샤드 이름으로 `default`를 사용할 필요는 없습니다. Rails는 `connects_to` 해시의 첫 번째 샤드 이름을 "default" 연결로 가정합니다. 이 연결은 스키마가 샤드 간에 동일한 유형 데이터 및 기타 정보를 로드하는 데 내부적으로 사용됩니다.

그런 다음 모델은 `connected_to` API를 통해 수동으로 연결을 전환할 수 있습니다. 샤딩을 사용하는 경우 `role`과 `shard`를 모두 전달해야 합니다.

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # ":default" 샤드에 레코드를 생성합니다.
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # 레코드를 찾을 수 없습니다. ":default" 샤드에 생성되었기 때문입니다.
end
```

수평 샤딩 API는 읽기 복제본도 지원합니다. `connected_to` API에서 역할과 샤드를 전환할 수 있습니다.

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # 샤드 하나의 읽기 복제본에서 레코드 조회
end
```

## 자동 샤드 전환 활성화

응용 프로그램은 제공된 미들웨어를 사용하여 요청마다 자동으로 샤드를 전환할 수 있습니다.

`ShardSelector` 미들웨어는 자동으로 샤드를 전환하기 위한 프레임워크를 제공합니다. Rails는 어떤 샤드로 전환할지 결정하기 위한 기본적인 프레임워크를 제공하며 필요한 경우 응용 프로그램에서 사용자 정의 전환 전략을 작성할 수 있습니다.

`ShardSelector`는 미들웨어에서 사용할 수 있는 옵션 집합(`lock`만 현재 지원됨)을 사용하여 동작을 변경할 수 있습니다. `lock`는 기본적으로 true이며 블록 내에서 요청이 샤드 전환을 금지합니다. `lock`가 false인 경우 샤드 전환을 허용합니다. 테넌트 기반 샤딩의 경우 `lock`는 항상 true로 설정되어 애플리케이션 코드가 잘못된 테넌트 간에 전환되지 않도록 해야 합니다.

자동 샤드 전환을 위한 파일을 생성하는 데 데이터베이스 선택기와 동일한 생성기를 사용할 수 있습니다.

```bash
$ bin/rails g active_record:multi_db
```

그런 다음 파일에서 다음을 주석 해제합니다.

```ruby
Rails.application.configure do
  config.active_record.shard_selector = { lock: true }
  config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end
```

응용 프로그램은 응용 프로그램 특정 모델에 따라 resolver 코드를 제공해야 합니다. 예를 들면 다음과 같습니다.

```ruby
config.active_record.shard_resolver = ->(request) {
  subdomain = request.subdomain
  tenant = Tenant.find_by_subdomain!(subdomain)
  tenant.shard
}
```

## 세분화된 데이터베이스 연결 전환

Rails 6.1에서는 모든 데이터베이스가 전역적으로 아닌 하나의 데이터베이스에 대해 연결을 전환할 수 있습니다.

세분화된 데이터베이스 연결 전환을 사용하면 다른 연결에 영향을 주지 않고도 추상 연결 클래스를 통해 연결을 전환할 수 있습니다. 이는 `AnimalsRecord` 쿼리를 레플리카에서 읽도록 전환하면서 `ApplicationRecord` 쿼리가 기본 연결로 이동하도록 하는 데 유용합니다.
```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # animals_replica에서 읽기
  Person.first  # primary에서 읽기
end
```

또한 샤드에 대해 연결을 세밀하게 교체하는 것도 가능합니다.

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # shard_one_replica에서 읽기. shard_one_replica에 대한 연결이 없는 경우 ConnectionNotEstablished 오류가 발생합니다.
  Person.first # primary writer에서 읽기
end
```

주 데이터베이스 클러스터만 전환하려면 `ApplicationRecord`을 사용합니다:

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # primary_shard_one_replica에서 읽기
  Dog.first # animals_primary에서 읽기
end
```

`ActiveRecord::Base.connected_to`는 전역적으로 연결을 전환할 수 있는 기능을 유지합니다.

### 다중 데이터베이스 간 조인을 처리하는 연관 관계 처리

Rails 7.0+에서 Active Record는 여러 데이터베이스 간 조인을 수행하는 연관 관계를 처리하는 옵션을 제공합니다. has many through 또는 has one through 연관 관계를 조인을 비활성화하고 2개 이상의 쿼리를 수행하려는 경우 `disable_joins: true` 옵션을 전달합니다.

예를 들어:

```ruby
class Dog < AnimalsRecord
  has_many :treats, through: :humans, disable_joins: true
  has_many :humans

  has_one :home
  has_one :yard, through: :home, disable_joins: true
end

class Home
  belongs_to :dog
  has_one :yard
end

class Yard
  belongs_to :home
end
```

이전에 `disable_joins` 없이 `@dog.treats` 또는 `disable_joins` 없이 `@dog.yard`를 호출하면 오류가 발생했습니다. 이는 데이터베이스가 클러스터 간 조인을 처리할 수 없기 때문입니다. `disable_joins` 옵션을 사용하면 Rails는 클러스터 간 조인을 시도하지 않고 여러 select 쿼리를 생성하여 조인을 피합니다. 위의 연관 관계의 경우 `@dog.treats`는 다음 SQL을 생성합니다:

```sql
SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
```

`@dog.yard`는 다음 SQL을 생성합니다:

```sql
SELECT "home"."id" FROM "homes" WHERE "homes"."dog_id" = ? [["dog_id", 1]]
SELECT "yards".* FROM "yards" WHERE "yards"."home_id" = ? [["home_id", 1]]
```

이 옵션에 대해 알아야 할 몇 가지 중요한 사항이 있습니다:

1. 조인 대신 2개 이상의 쿼리(연관 관계에 따라 다름)가 수행되므로 성능에 영향을 줄 수 있습니다. `humans`의 select가 많은 수의 ID를 반환하면 `treats`의 select에서 너무 많은 ID가 전송될 수 있습니다.
2. 조인을 수행하지 않으므로 order 또는 limit가 있는 쿼리는 다른 테이블에 적용할 수 없으므로 메모리에서 정렬됩니다.
3. 이 설정은 조인을 비활성화하려는 모든 연관 관계에 추가해야 합니다. Rails는 연관 관계 로딩이 지연되므로 `@dog.treats`에서 `treats`를 로드하려면 이미 생성해야 할 SQL을 알아야 합니다.

### 스키마 캐싱

각 데이터베이스에 스키마 캐시를 로드하려면 각 데이터베이스 구성에 `schema_cache_path`를 설정하고 응용 프로그램 구성에서 `config.active_record.lazily_load_schema_cache = true`를 설정해야 합니다. 이렇게 하면 데이터베이스 연결이 설정될 때 캐시가 지연 로드됩니다.

## 주의 사항

### 복제본의 로드 밸런싱

Rails는 복제본의 자동 로드 밸런싱도 지원하지 않습니다. 이는 인프라에 매우 의존적입니다. 우리는 앞으로 기본적이고 원시적인 로드 밸런싱을 구현할 수 있지만, 대규모 애플리케이션의 경우 이는 Rails 외부에서 처리해야 할 사항입니다.
