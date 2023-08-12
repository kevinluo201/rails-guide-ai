**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b2cb0ab668ead9e8bd48cbd1bcac9b59
액티브 레코드 기본 사항
====================

이 가이드는 액티브 레코드에 대한 소개입니다.

이 가이드를 읽은 후에는 다음을 알게됩니다:

* 객체 관계 매핑과 액티브 레코드가 무엇이며 레일스에서 어떻게 사용되는지.
* 액티브 레코드가 모델-뷰-컨트롤러 패러다임에 어떻게 맞는지.
* 액티브 레코드 모델을 사용하여 관계형 데이터베이스에 저장된 데이터를 조작하는 방법.
* 액티브 레코드 스키마 네이밍 규칙.
* 데이터베이스 마이그레이션, 유효성 검사, 콜백 및 연관 관계의 개념.

--------------------------------------------------------------------------------

액티브 레코드란?
----------------------

액티브 레코드는 [MVC][]의 M입니다. 모델은 비즈니스 데이터와 로직을 나타내는 시스템의 레이어입니다. 액티브 레코드는 데이터를 영구 저장소인 데이터베이스에 저장해야하는 비즈니스 객체의 생성과 사용을 용이하게합니다. 액티브 레코드는 액티브 레코드 패턴의 구현으로, 이 패턴 자체가 객체 관계 매핑 시스템에 대한 설명입니다.

### 액티브 레코드 패턴

[액티브 레코드는 Martin Fowler의 책인 _Patterns of Enterprise Application Architecture_에서 설명되었습니다. 액티브 레코드에서 객체는 영구 데이터와 해당 데이터에 작용하는 동작을 모두 가지고 있습니다. 액티브 레코드는 데이터 액세스 로직을 객체의 일부로 보장함으로써 해당 객체의 사용자가 데이터베이스에 쓰고 읽는 방법을 학습할 수 있도록합니다.

### 객체 관계 매핑

[객체 관계 매핑][ORM]은 응용 프로그램의 풍부한 객체를 관계형 데이터베이스 관리 시스템의 테이블에 연결하는 기술입니다. ORM을 사용하면 응용 프로그램의 객체의 속성과 관계를 SQL 문을 직접 작성하지 않고도 쉽게 저장하고 검색할 수 있습니다.

참고: 관계형 데이터베이스 관리 시스템 (RDBMS) 및 구조화된 쿼리 언어 (SQL)에 대한 기본 지식은 액티브 레코드를 완전히 이해하기 위해 도움이됩니다. 자세한 내용은 [이 튜토리얼][sqlcourse] (또는 [이 튜토리얼][rdbmsinfo])을 참조하거나 다른 방법으로 공부하시기 바랍니다.

### ORM 프레임워크로서의 액티브 레코드

액티브 레코드는 다음과 같은 여러 메커니즘을 제공합니다.

* 모델과 해당 데이터를 나타냅니다.
* 이러한 모델 간의 연관 관계를 나타냅니다.
* 관련된 모델을 통해 상속 계층 구조를 나타냅니다.
* 데이터베이스에 영속화되기 전에 모델을 유효성 검사합니다.
* 객체 지향 방식으로 데이터베이스 작업을 수행합니다.


액티브 레코드에서의 구성보다 관례
----------------------------------------------

다른 프로그래밍 언어나 프레임워크를 사용하여 애플리케이션을 작성할 때 많은 구성 코드를 작성해야 할 수도 있습니다. 일반적으로 ORM 프레임워크에 대해서도 마찬가지입니다. 그러나 레일스가 채택한 관례를 따른다면 액티브 레코드 모델을 생성할 때 매우 적은 구성 코드 (경우에 따라 구성 코드가 전혀 필요하지 않음)만 작성해야합니다. 이 아이디어는 대부분의 경우 애플리케이션을 동일한 방식으로 구성한다면 이것이 기본 방식이어야한다는 것입니다. 따라서 표준 관례를 따를 수없는 경우에만 명시적인 구성이 필요합니다.

### 네이밍 규칙

기본적으로 액티브 레코드는 모델과 데이터베이스 테이블 간의 매핑 방법을 찾기 위해 일부 네이밍 규칙을 사용합니다. 레일스는 클래스 이름을 복수형으로 변환하여 해당 데이터베이스 테이블을 찾습니다. 따라서 `Book` 클래스의 경우 **books**라는 데이터베이스 테이블이 있어야합니다. 레일스의 복수화 메커니즘은 정규 및 비정규 단어 모두를 복수화 (및 단수화) 할 수있는 매우 강력합니다. 두 개 이상의 단어로 구성된 클래스 이름을 사용할 때 모델 클래스 이름은 Ruby 관례를 따라야하며 CamelCase 형식을 사용해야하며 테이블 이름은 snake_case 형식을 사용해야합니다. 예시:

* 모델 클래스 - 각 단어의 첫 글자를 대문자로 표기한 단수형 (예 : `BookClub`).
* 데이터베이스 테이블 - 단어 사이에 밑줄을 사용한 복수형 (예 : `book_clubs`).

| 모델 / 클래스    | 테이블 / 스키마 |
| ---------------- | -------------- |
| `Article`        | `articles`     |
| `LineItem`       | `line_items`   |
| `Deer`           | `deers`        |
| `Mouse`          | `mice`         |
| `Person`         | `people`       |

### 스키마 규칙

액티브 레코드는 데이터베이스 테이블의 열에 대해 네이밍 규칙을 사용합니다. 이 규칙은 열의 목적에 따라 다릅니다.

* **외래 키** - 이러한 필드는 `singularized_table_name_id` 패턴을 따라야합니다 (예 : `item_id`, `order_id`). 이는 액티브 레코드가 모델 간의 연관 관계를 생성할 때 찾을 필드입니다.
* **기본 키** - 기본적으로 액티브 레코드는 테이블의 기본 키로 `id`라는 정수 열을 사용합니다 (PostgreSQL 및 MySQL의 경우 `bigint`, SQLite의 경우 `integer`). [액티브 레코드 마이그레이션](active_record_migrations.html)을 사용하여 테이블을 생성하는 경우이 열이 자동으로 생성됩니다.
또한 Active Record 인스턴스에 추가 기능을 추가할 수 있는 몇 가지 선택적인 열 이름이 있습니다.

* `created_at` - 레코드가 처음 생성될 때 현재 날짜와 시간으로 자동 설정됩니다.
* `updated_at` - 레코드가 생성되거나 업데이트될 때마다 현재 날짜와 시간으로 자동 설정됩니다.
* `lock_version` - 모델에 [낙관적 잠금](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html)을 추가합니다.
* `type` - 모델이 [단일 테이블 상속](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance)을 사용한다는 것을 지정합니다.
* `(association_name)_type` - [다형성 연관](association_basics.html#polymorphic-associations)의 유형을 저장합니다.
* `(table_name)_count` - 연관에 속하는 객체의 수를 캐시하는 데 사용됩니다. 예를 들어, `Comment`의 여러 인스턴스를 가진 `Article` 클래스의 `comments_count` 열은 각 기사에 대해 존재하는 댓글 수를 캐시합니다.

참고: 이러한 열 이름은 선택 사항이지만, 사실 Active Record에 의해 예약되어 있습니다. 추가 기능을 원하지 않는 한 예약된 키워드를 피하십시오. 예를 들어, `type`은 단일 테이블 상속 (STI)를 사용하여 테이블을 지정하는 데 사용되는 예약된 키워드입니다. STI를 사용하지 않는 경우 "context"와 같은 유사한 키워드를 시도하여 여전히 모델링하는 데이터를 정확하게 설명할 수 있습니다.

Active Record 모델 생성하기
-----------------------------

애플리케이션을 생성할 때 `app/models/application_record.rb`에 추상 `ApplicationRecord` 클래스가 생성됩니다. 이것은 앱의 모든 모델의 기본 클래스이며, 일반적인 루비 클래스를 Active Record 모델로 변환하는 역할을 합니다.

Active Record 모델을 생성하려면 `ApplicationRecord` 클래스를 상속하고 이제 사용할 수 있습니다:

```ruby
class Product < ApplicationRecord
end
```

이렇게 하면 `Product` 모델이 생성되며, 데이터베이스의 `products` 테이블에 매핑됩니다. 이렇게 함으로써 해당 테이블의 각 행의 열을 모델 인스턴스의 속성과 매핑할 수도 있습니다. 예를 들어, `products` 테이블이 다음과 같은 SQL (또는 그 확장) 문을 사용하여 생성된 경우:

```sql
CREATE TABLE products (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
);
```

위의 스키마는 `id`와 `name` 두 개의 열을 가진 테이블을 선언합니다. 이 테이블의 각 행은 이러한 두 매개변수를 가진 특정 제품을 나타냅니다. 따라서 다음과 같은 코드를 작성할 수 있습니다:

```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

네이밍 컨벤션 재정의하기
---------------------------------

다른 네이밍 컨벤션을 따르거나 레거시 데이터베이스와 함께 Rails 애플리케이션을 사용해야 하는 경우 문제가 없습니다. 기본 컨벤션을 쉽게 재정의할 수 있습니다.

`ApplicationRecord`은 `ActiveRecord::Base`를 상속하므로 애플리케이션의 모델에는 여러 가지 유용한 메소드가 사용 가능합니다. 예를 들어, `ActiveRecord::Base.table_name=` 메소드를 사용하여 사용할 테이블 이름을 사용자 정의할 수 있습니다:

```ruby
class Product < ApplicationRecord
  self.table_name = "my_products"
end
```

이렇게 하면 테이블 이름을 사용자 정의할 수 있습니다. 그러나 테스트 정의에서 `set_fixture_class` 메소드를 사용하여 픽스처를 호스팅하는 클래스 이름을 수동으로 정의해야 합니다:

```ruby
# test/models/product_test.rb
class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
  # ...
end
```

또한 `ActiveRecord::Base.primary_key=` 메소드를 사용하여 테이블의 기본 키로 사용할 열을 재정의할 수도 있습니다:

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

참고: **Active Record는 `id`라는 이름의 비 기본 키 열을 사용하는 것을 지원하지 않습니다.**

참고: 비 기본 키인 `id`라는 이름의 열을 생성하려고 하면 Rails가 다음과 같은 마이그레이션 중에 오류를 throw합니다.
`you can't redefine the primary key column 'id' on 'my_products'.`
`To define a custom primary key, pass { id: false } to create_table.`

CRUD: 데이터 읽기 및 쓰기
------------------------------

CRUD는 데이터를 조작하는 데 사용하는 네 가지 동사의 머리글자입니다: **C**reate, **R**ead, **U**pdate, **D**elete. Active Record는 테이블에 저장된 데이터를 읽고 조작할 수 있는 메소드를 자동으로 생성합니다.

### Create

Active Record 객체는 해시, 블록 또는 생성 후 속성을 수동으로 설정하여 생성할 수 있습니다. `new` 메소드는 새로운 객체를 반환하고 `create`는 객체를 반환하고 데이터베이스에 저장합니다.

예를 들어, `name`과 `occupation` 속성을 가진 `User` 모델이 있다고 가정할 때, `create` 메소드 호출은 데이터베이스에 새로운 레코드를 생성하고 저장합니다:

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```
`new` 메소드를 사용하여 객체를 저장하지 않고 인스턴스화할 수 있습니다:

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

`user.save`를 호출하면 레코드가 데이터베이스에 커밋됩니다.

마지막으로, 블록이 제공된 경우, `create`와 `new`는 초기화를 위해 새로운 객체를 블록에 전달하며, 결과 객체를 데이터베이스에 영속화하는 것은 `create`만 수행합니다:

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### 조회

Active Record는 데이터베이스 내의 데이터에 액세스하기 위한 다양한 데이터 액세스 메소드를 제공합니다. 아래는 Active Record가 제공하는 몇 가지 데이터 액세스 방법의 예시입니다.

```ruby
# 모든 사용자를 포함하는 컬렉션 반환
users = User.all
```

```ruby
# 첫 번째 사용자 반환
user = User.first
```

```ruby
# 이름이 David인 첫 번째 사용자 반환
david = User.find_by(name: 'David')
```

```ruby
# 이름이 David이고 직업이 Code Artist인 사용자를 찾아 생성일을 역순으로 정렬
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

Active Record 모델을 쿼리하는 방법에 대해 자세히 알아보려면 [Active Record 쿼리 인터페이스](active_record_querying.html) 가이드를 참조하십시오.

### 업데이트

Active Record 객체를 검색한 후에는 해당 속성을 수정하고 데이터베이스에 저장할 수 있습니다.

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

속성 이름을 원하는 값에 매핑하는 해시를 사용하여 다음과 같이 간단하게 작성할 수도 있습니다:

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

이는 한 번에 여러 속성을 업데이트할 때 가장 유용합니다.

콜백 또는 유효성 검사 없이 여러 레코드를 일괄적으로 업데이트하려면 `update_all`을 사용하여 데이터베이스를 직접 업데이트할 수 있습니다:

```ruby
User.update_all max_login_attempts: 3, must_change_password: true
```

### 삭제

마찬가지로, 검색한 Active Record 객체를 삭제하여 데이터베이스에서 제거할 수 있습니다.

```ruby
user = User.find_by(name: 'David')
user.destroy
```

여러 레코드를 일괄적으로 삭제하려면 `destroy_by` 또는 `destroy_all` 메소드를 사용할 수 있습니다:

```ruby
# 이름이 David인 모든 사용자 찾아 삭제
User.destroy_by(name: 'David')

# 모든 사용자 삭제
User.destroy_all
```

유효성 검사
-----------

Active Record를 사용하면 데이터베이스에 쓰기 전에 모델의 상태를 유효성 검사할 수 있습니다. 속성 값이 비어 있지 않고, 고유하며, 이미 데이터베이스에 존재하지 않으며, 특정 형식을 따르는지 등을 확인하기 위해 여러 메소드를 사용할 수 있습니다.

`save`, `create`, `update`와 같은 메소드는 모델을 데이터베이스에 저장하기 전에 유효성을 검사합니다. 모델이 유효하지 않을 경우 이러한 메소드는 `false`를 반환하고 데이터베이스 작업은 수행되지 않습니다. 이러한 메소드에는 유효성 검사 실패 시 `ActiveRecord::RecordInvalid` 예외를 발생시키는 느낌표 대응 메소드(`save!`, `create!`, `update!`)도 있습니다. 간단한 예를 들어 설명하겠습니다:

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> user = User.new
irb> user.save
=> false
irb> user.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

유효성 검사에 대해 자세히 알아보려면 [Active Record 유효성 검사 가이드](active_record_validations.html)를 참조하십시오.

콜백
-----

Active Record 콜백을 사용하면 모델의 라이프사이클에서 특정 이벤트에 코드를 연결할 수 있습니다. 이를 통해 새 레코드를 생성, 업데이트, 삭제할 때와 같은 이벤트가 발생할 때 코드를 실행하여 모델에 동작을 추가할 수 있습니다.

```ruby
class User < ApplicationRecord
  after_create :log_new_user

  private
    def log_new_user
      puts "A new user was registered"
    end
end
```

```irb
irb> @user = User.create
A new user was registered
```

콜백에 대해 자세히 알아보려면 [Active Record 콜백 가이드](active_record_callbacks.html)를 참조하십시오.

마이그레이션
------------

Rails는 마이그레이션을 통해 데이터베이스 스키마의 변경을 편리하게 관리할 수 있는 방법을 제공합니다. 마이그레이션은 도메인 특화 언어(DSL)로 작성되며, Active Record가 지원하는 모든 데이터베이스에 대해 실행되는 파일에 저장됩니다.

다음은 `publications`라는 새로운 테이블을 생성하는 마이그레이션의 예입니다:

```ruby
class CreatePublications < ActiveRecord::Migration[7.1]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.references :publisher, polymorphic: true
      t.boolean :single_issue

      t.timestamps
    end
  end
end
```

위 코드는 데이터베이스에 독립적입니다. MySQL, PostgreSQL, SQLite 등에서 실행됩니다.

Rails는 데이터베이스에 커밋된 마이그레이션을 추적하고, 동일한 데이터베이스의 `schema_migrations`라는 인접한 테이블에 저장합니다.
마이그레이션을 실행하고 테이블을 생성하려면 `bin/rails db:migrate`를 실행하고,
롤백하여 테이블을 삭제하려면 `bin/rails db:rollback`을 실행합니다.

마이그레이션에 대해 더 자세히 알아보려면 [Active Record 마이그레이션 가이드](active_record_migrations.html)를 참조하십시오.

연관 관계
------------

Active Record 연관 관계를 사용하면 모델 간의 관계를 정의할 수 있습니다.
연관 관계는 일대일, 일대다 및 다대다 관계를 설명하는 데 사용할 수 있습니다. 예를 들어, "작가는 여러 책을 가지고 있다"라는 관계는 다음과 같이 정의할 수 있습니다:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

작가 클래스에는 이제 작가에게 책을 추가하고 제거하는 등의 메서드가 있습니다.

연관 관계에 대해 더 자세히 알아보려면 [Active Record 연관 관계 가이드](association_basics.html)를 참조하십시오.
[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[MFAR]: https://www.martinfowler.com/eaaCatalog/activeRecord.html
[ORM]: https://en.wikipedia.org/wiki/Object-relational_mapping
[sqlcourse]: https://www.khanacademy.org/computing/computer-programming/sql
[rdbmsinfo]: https://www.devart.com/what-is-rdbms/
