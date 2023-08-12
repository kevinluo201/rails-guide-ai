**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 320082396ef549e27ab4cb837ec975dd
Active Record 콜백
=======================

이 가이드는 Active Record 객체의 라이프 사이클에 훅을 걸 수 있는 방법을 가르칩니다.

이 가이드를 읽고 나면 다음을 알게 될 것입니다:

* Active Record 객체의 라이프 사이클 동안 특정 이벤트가 언제 발생하는지
* 객체 라이프 사이클의 이벤트에 응답하는 콜백 메소드를 작성하는 방법
* 콜백에 대한 공통 동작을 캡슐화하는 특수한 클래스를 작성하는 방법

--------------------------------------------------------------------------------

객체 라이프 사이클
---------------------

Rails 애플리케이션의 정상적인 동작 중에는 객체가 생성, 업데이트 및 삭제될 수 있습니다. Active Record는 이러한 *객체 라이프 사이클*에 훅을 제공하여 애플리케이션과 데이터를 제어할 수 있게 해줍니다.

콜백을 사용하면 객체의 상태 변경 전후에 로직을 트리거할 수 있습니다.

```ruby
class Baby < ApplicationRecord
  after_create -> { puts "축하합니다!" }
end
```

```irb
irb> @baby = Baby.create
축하합니다!
```

보시다시피 많은 라이프 사이클 이벤트가 있으며, 이러한 이벤트 중 어느 것에든지 전, 후 또는 주위에 훅을 걸 수 있습니다.

콜백 개요
------------------

콜백은 객체의 라이프 사이클의 특정 시점에 호출되는 메소드입니다. 콜백을 사용하면 Active Record 객체가 생성, 저장, 업데이트, 삭제, 유효성 검사 또는 데이터베이스에서 로드될 때마다 실행되는 코드를 작성할 수 있습니다.

### 콜백 등록

사용 가능한 콜백을 사용하려면 등록해야 합니다. 콜백을 일반적인 메소드로 구현하고 매크로 스타일의 클래스 메소드를 사용하여 콜백으로 등록할 수 있습니다:

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  private
    def ensure_login_has_a_value
      if login.blank?
        self.login = email unless email.blank?
      end
    end
end
```

매크로 스타일의 클래스 메소드는 블록을 받을 수도 있습니다. 블록 내의 코드가 한 줄에 들어갈 정도로 짧다면 이 스타일을 사용하는 것이 좋습니다:

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

또는 콜백에 트리거될 proc를 전달할 수도 있습니다.

```ruby
class User < ApplicationRecord
  before_create ->(user) { user.name = user.login.capitalize if user.name.blank? }
end
```

마지막으로, 자체 콜백 객체를 정의할 수도 있습니다. 이에 대해서는 나중에 자세히 다룰 것입니다 [아래](#callback-classes).

```ruby
class User < ApplicationRecord
  before_create MaybeAddName
end

class MaybeAddName
  def self.before_create(record)
    if record.name.blank?
      record.name = record.login.capitalize
    end
  end
end
```

콜백은 특정 라이프 사이클 이벤트에서만 트리거되도록 등록할 수도 있습니다. 이를 통해 콜백이 언제와 어떤 문맥에서 트리거되는지 완전히 제어할 수 있습니다.

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on은 배열도 받을 수 있습니다
  after_validation :set_location, on: [ :create, :update ]

  private
    def normalize_name
      self.name = name.downcase.titleize
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

콜백 메소드를 private으로 선언하는 것이 좋은 관행입니다. public으로 남겨두면 모델 외부에서 호출될 수 있으며 객체 캡슐화 원칙을 위반할 수 있습니다.

경고. 콜백 내에서 객체에 부작용을 일으키는 `update`, `save` 또는 다른 메소드 호출을 피하십시오. 예를 들어 콜백 내에서 `update(attribute: "value")`를 호출하지 마십시오. 이렇게 하면 모델의 상태가 변경되어 커밋 중 예기치 않은 부작용이 발생할 수 있습니다. 대신 `before_create` / `before_update` 또는 이전 콜백에서 값을 직접 할당할 수 있습니다.

사용 가능한 콜백
-------------------

다음은 사용 가능한 모든 Active Record 콜백 목록입니다. 해당 작업 중에 호출되는 순서와 동일한 순서로 나열되어 있습니다:

### 객체 생성

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


### 객체 업데이트

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


경고. `after_save`는 생성 및 업데이트 모두에서 실행되지만, 항상 더 구체적인 콜백인 `after_create` 및 `after_update`보다는 _후에_ 실행됩니다. 매크로 호출이 실행된 순서와는 관계없이입니다.

### 객체 삭제

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]


참고: `before_destroy` 콜백은 `dependent: :destroy` 연관 관계 앞에 배치해야 합니다(`prepend: true` 옵션을 사용하거나). 이렇게 하면 `dependent: :destroy`에 의해 레코드가 삭제되기 전에 실행되도록 보장할 수 있습니다.

경고. `after_commit`은 `after_save`, `after_update` 및 `after_destroy`와는 매우 다른 보장을 제공합니다. 예를 들어 `after_save`에서 예외가 발생하면 트랜잭션이 롤백되고 데이터가 유지되지 않습니다. 반면 `after_commit`에서 발생하는 모든 것은 트랜잭션이 이미 완료되고 데이터가 데이터베이스에 유지되었음을 보장할 수 있습니다. [트랜잭션 콜백](#transaction-callbacks)에 대해 자세히 알아보세요.
### `after_initialize`와 `after_find`

Active Record 객체가 인스턴스화될 때마다 [`after_initialize`][] 콜백이 호출됩니다. `new`를 직접 사용하거나 데이터베이스에서 레코드를 로드할 때 호출됩니다. Active Record `initialize` 메소드를 직접 오버라이드할 필요 없이 사용할 수 있습니다.

데이터베이스에서 레코드를 로드할 때 [`after_find`][] 콜백이 호출됩니다. 둘 다 정의되어 있는 경우 `after_find`은 `after_initialize`보다 먼저 호출됩니다.

참고: `after_initialize`와 `after_find` 콜백에는 `before_*` 상응하는 콜백이 없습니다.

다른 Active Record 콜백과 마찬가지로 등록할 수 있습니다.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "객체를 초기화했습니다!"
  end

  after_find do |user|
    puts "객체를 찾았습니다!"
  end
end
```

```irb
irb> User.new
객체를 초기화했습니다!
=> #<User id: nil>

irb> User.first
객체를 찾았습니다!
객체를 초기화했습니다!
=> #<User id: 1>
```


### `after_touch`

[`after_touch`][] 콜백은 Active Record 객체가 터치될 때마다 호출됩니다.

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "객체를 터치했습니다"
  end
end
```

```irb
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
객체를 터치했습니다
=> true
```

`belongs_to`와 함께 사용할 수 있습니다:

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    puts '책이 터치되었습니다'
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      puts '책/도서관이 터치되었습니다'
    end
end
```

```irb
irb> @book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @book.touch # @book.library.touch를 트리거합니다
책이 터치되었습니다
책/도서관이 터치되었습니다
=> true
```


콜백 실행
-----------------

다음 메소드는 콜백을 트리거합니다:

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `destroy_by`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update`
* `update!`
* `valid?`

또한, `after_find` 콜백은 다음 검색 메소드에 의해 트리거됩니다:

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

`after_initialize` 콜백은 클래스의 새로운 객체가 초기화될 때마다 트리거됩니다.

참고: `find_by_*` 및 `find_by_*!` 메소드는 모든 속성에 대해 자동으로 생성되는 동적 검색기입니다. [동적 검색기 섹션](active_record_querying.html#dynamic-finders)에서 자세히 알아보세요.

콜백 건너뛰기
------------------

유효성 검사와 마찬가지로 다음 메소드를 사용하여 콜백을 건너뛸 수 있습니다:

* `decrement!`
* `decrement_counter`
* `delete`
* `delete_all`
* `delete_by`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `touch_all`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`
* `upsert`
* `upsert_all`

그러나 이러한 메소드는 중요한 비즈니스 규칙과 애플리케이션 로직이 콜백에 저장될 수 있으므로 주의해서 사용해야 합니다. 잠재적인 영향을 이해하지 않고 우회하는 경우 잘못된 데이터가 발생할 수 있습니다.

실행 중단
-----------------

모델에 새로운 콜백을 등록하면 실행을 위해 대기열에 추가됩니다. 이 대기열에는 모델의 모든 유효성 검사, 등록된 콜백 및 실행될 데이터베이스 작업이 포함됩니다.

전체 콜백 체인은 트랜잭션으로 래핑됩니다. 콜백 중 하나가 예외를 발생시키면 실행 체인이 중단되고 ROLLBACK이 발생합니다. 체인을 의도적으로 중단하려면 다음을 사용하세요:

```ruby
throw :abort
```

경고. `ActiveRecord::Rollback` 또는 `ActiveRecord::RecordInvalid`가 아닌 예외는 콜백 체인이 중단된 후 Rails에 의해 다시 발생됩니다. 또한, `save` 및 `update`와 같이 (`true` 또는 `false`를 반환하려고 시도하는) 예외를 발생시키는 메소드를 예상하지 않는 코드를 중단시킬 수 있습니다.

참고: `after_destroy`, `before_destroy` 또는 `around_destroy` 콜백 내에서 `ActiveRecord::RecordNotDestroyed`가 발생하면 다시 발생되지 않고 `destroy` 메소드는 `false`를 반환합니다.

관계형 콜백
--------------------

콜백은 모델 간의 관계를 통해 작동하며, 관계를 통해 정의할 수도 있습니다. 사용자가 여러 개의 게시물을 가지는 예를 가정해 보겠습니다. 사용자가 삭제되면 사용자의 게시물도 삭제되어야 합니다. `User` 모델에 `Article` 모델과의 관계를 통해 `after_destroy` 콜백을 추가해 보겠습니다:

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts '게시물이 삭제되었습니다'
  end
end
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
게시물이 삭제되었습니다
=> #<User id: 1>
```
조건부 콜백
---------------------

유효성 검사와 마찬가지로, 콜백 메소드의 호출을 주어진 조건을 만족하는 경우에만 할 수 있습니다. 이를 위해 `:if`와 `:unless` 옵션을 사용할 수 있으며, 심볼, `Proc` 또는 배열을 사용할 수 있습니다.

콜백이 호출되어야 하는 조건을 지정하려면 `:if` 옵션을 사용할 수 있습니다. 콜백이 호출되지 않아야 하는 조건을 지정하려면 `:unless` 옵션을 사용할 수 있습니다.

### `심볼`을 사용한 `:if`와 `:unless` 사용

`심볼`을 `:if`와 `:unless` 옵션과 연결할 수 있으며, 이는 콜백 앞에서 호출되는 예측 메소드의 이름과 일치합니다.

`:if` 옵션을 사용할 때, 예측 메소드가 `false`를 반환하면 콜백은 실행되지 않습니다. `:unless` 옵션을 사용할 때, 예측 메소드가 `true`를 반환하면 콜백은 실행되지 않습니다. 이것이 가장 일반적인 옵션입니다.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

이 형식의 등록을 사용하면 콜백이 실행되어야 하는지 확인하기 위해 여러 다른 예측을 등록할 수도 있습니다. 이에 대해서는 [아래](#multiple-callback-conditions)에서 다룰 것입니다.

### `Proc`를 사용한 `:if`와 `:unless` 사용

`:if`와 `:unless`를 `Proc` 객체와 연결할 수도 있습니다. 이 옵션은 일반적으로 한 줄짜리 유효성 검사 메소드를 작성할 때 가장 적합합니다.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

Proc는 객체의 컨텍스트에서 평가되므로 다음과 같이 작성할 수도 있습니다.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```

### 여러 개의 콜백 조건 사용

`:if`와 `:unless` 옵션은 프로크나 메소드 이름 심볼의 배열도 허용합니다.

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

프로크를 조건 목록에 포함시킬 수도 있습니다.

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, Proc.new { untrusted_author? }]
end
```

### `:if`와 `:unless` 모두 사용하기

콜백은 `:if`와 `:unless`를 동시에 선언할 수 있습니다.

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: Proc.new { forum.parental_control? },
    unless: Proc.new { author.trusted? }
end
```

콜백은 `:if` 조건이 모두 `true`이고 `:unless` 조건이 모두 `false`일 때만 실행됩니다.

콜백 클래스
----------------

작성한 콜백 메소드가 다른 모델에서 재사용할만큼 유용할 수도 있습니다. Active Record는 콜백 메소드를 캡슐화하는 클래스를 생성하여 재사용할 수 있도록 합니다.

다음은 파일 시스템에서 폐기된 파일의 정리를 처리하기 위한 `after_destroy` 콜백을 가진 클래스를 생성하는 예입니다. 이 동작은 `PictureFile` 모델에만 해당되지 않을 수 있으며, 공유하고 싶을 수 있으므로 별도의 클래스로 캡슐화하는 것이 좋습니다. 이렇게 하면 해당 동작을 테스트하고 변경하는 것이 훨씬 쉬워집니다.

```ruby
class FileDestroyerCallback
  def after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

위와 같이 클래스 내에서 선언된 콜백 메소드는 모델 객체를 매개변수로 받습니다. 이는 클래스를 사용하는 모든 모델에서 작동합니다.

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback.new
end
```

콜백을 인스턴스 메소드로 선언했기 때문에 새로운 `FileDestroyerCallback` 객체를 인스턴스화해야 합니다. 이는 콜백이 인스턴스화된 객체의 상태를 사용하는 경우에 특히 유용합니다. 그러나 대부분의 경우 콜백을 클래스 메소드로 선언하는 것이 더 의미가 있을 수 있습니다.

```ruby
class FileDestroyerCallback
  def self.after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

콜백 메소드가 이렇게 선언된 경우 모델에서 새로운 `FileDestroyerCallback` 객체를 인스턴스화할 필요가 없습니다.

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback
end
```

콜백 클래스 내에 원하는 만큼 많은 콜백을 선언할 수 있습니다.

트랜잭션 콜백
---------------------

### 일관성 유지

데이터베이스 트랜잭션이 완료되면 추가적인 두 개의 콜백이 트리거됩니다: [`after_commit`][]과 [`after_rollback`][]. 이러한 콜백은 `after_save` 콜백과 매우 유사하지만, 데이터베이스 변경 사항이 커밋되거나 롤백될 때까지 실행되지 않습니다. 이러한 콜백은 액티브 레코드 모델이 데이터베이스 트랜잭션의 일부가 아닌 외부 시스템과 상호작용해야 할 때 가장 유용합니다.
예를 들어, 이전 예제에서 `PictureFile` 모델은 해당 레코드가 삭제된 후 파일을 삭제해야 하는 경우를 고려해보십시오. `after_destroy` 콜백이 호출된 후에 예외가 발생하고 트랜잭션이 롤백되면 파일이 삭제되고 모델은 일관성이 없는 상태로 남게됩니다. 예를 들어, 아래 코드에서 `picture_file_2`가 유효하지 않고 `save!` 메소드가 오류를 발생시키는 경우를 가정해보십시오.

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

`after_commit` 콜백을 사용하여 이러한 경우를 처리할 수 있습니다.

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

참고: `:on` 옵션은 콜백이 언제 발생할지를 지정합니다. `:on` 옵션을 제공하지 않으면 콜백은 모든 동작에 대해 발생합니다.

### 문맥이 중요합니다

`after_commit` 콜백은 일반적으로 생성, 업데이트 또는 삭제에만 사용되므로 이러한 작업에 대한 별칭이 있습니다:

* [`after_create_commit`][]
* [`after_update_commit`][]
* [`after_destroy_commit`][]

```ruby
class PictureFile < ApplicationRecord
  after_destroy_commit :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

경고. 트랜잭션이 완료되면 해당 트랜잭션 내에서 생성, 업데이트 또는 삭제된 모든 모델에 대해 `after_commit` 또는 `after_rollback` 콜백이 호출됩니다. 그러나 이러한 콜백 중 하나에서 예외가 발생하면 예외가 전달되고 나머지 `after_commit` 또는 `after_rollback` 메소드는 실행되지 않습니다. 따라서 콜백 코드가 예외를 발생시킬 수 있는 경우 콜백 내에서 예외를 처리하고 처리하여 다른 콜백이 실행될 수 있도록해야합니다.

경고. `after_commit` 또는 `after_rollback` 콜백 내에서 실행되는 코드 자체는 트랜잭션 내에 포함되지 않습니다.

경고. `after_create_commit` 및 `after_update_commit`을 동일한 메소드 이름으로 사용하는 경우 마지막으로 정의된 콜백만 효과가 있도록 허용됩니다. 이들은 모두 내부적으로 `after_commit`에 별칭을 지정하며 동일한 메소드 이름으로 이전에 정의된 콜백을 덮어씁니다.

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'User was saved to database'
    end
end
```

```irb
irb> @user = User.create # 아무것도 출력되지 않음

irb> @user.save # @user를 업데이트
User was saved to database
```

### `after_save_commit`

[`after_save_commit`][]도 있으며, 이는 생성 및 업데이트에 대해 `after_commit` 콜백을 함께 사용하는 별칭입니다.

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'User was saved to database'
    end
end
```

```irb
irb> @user = User.create # User를 생성
User was saved to database

irb> @user.save # @user를 업데이트
User was saved to database
```

### 트랜잭션 콜백 순서

여러 트랜잭션 `after_` 콜백(`after_commit`, `after_rollback` 등)을 정의할 때 순서는 정의된 순서와 반대로됩니다.

```ruby
class User < ActiveRecord::Base
  after_commit { puts("this actually gets called second") }
  after_commit { puts("this actually gets called first") }
end
```

참고: 이는 `after_destroy_commit`와 같은 모든 `after_*_commit` 변형에도 적용됩니다.
[`after_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_create
[`after_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_commit
[`after_rollback`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_rollback
[`after_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_save
[`after_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-after_validation
[`around_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_create
[`around_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_save
[`before_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_create
[`before_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_save
[`before_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-before_validation
[`after_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_update
[`around_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_update
[`before_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_update
[`after_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_destroy
[`around_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_destroy
[`before_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_destroy
[`after_find`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_find
[`after_initialize`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_initialize
[`after_touch`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_touch
[`after_create_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_create_commit
[`after_destroy_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_destroy_commit
[`after_save_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_save_commit
[`after_update_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_update_commit
