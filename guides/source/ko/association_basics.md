**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 516604959485cfefb0e0d775d767699b
Active Record 연관 관계
==========================

이 가이드는 Active Record의 연관 관계 기능을 다룹니다.

이 가이드를 읽은 후에는 다음을 알게됩니다.

* Active Record 모델간의 연관 관계를 선언하는 방법
* 다양한 유형의 Active Record 연관 관계 이해
* 연관 관계를 생성하여 모델에 추가된 메서드 사용

--------------------------------------------------------------------------------

왜 연관 관계가 필요한가?
-----------------

Rails에서 _연관 관계_는 두 개의 Active Record 모델 간의 연결을 의미합니다. 모델 간에 연관 관계가 필요한 이유는 코드에서 일반적인 작업을 더 간단하고 쉽게 만들기 위해서입니다.

예를 들어, 저자와 책 모델이 포함된 간단한 Rails 애플리케이션을 고려해보겠습니다. 각 저자는 여러 책을 가질 수 있습니다.

연관 관계가 없는 경우, 모델 선언은 다음과 같을 것입니다:

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

이제 기존 저자에 대해 새 책을 추가하려면 다음과 같이 수행해야 합니다:

```ruby
@book = Book.create(published_at: Time.now, author_id: @author.id)
```

또는 저자를 삭제하고 해당 저자의 모든 책도 삭제해야 하는 경우:

```ruby
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
author.destroy
```

Active Record 연관 관계를 사용하면 이러한 작업을 단순화할 수 있습니다. 두 모델 간에 연결이 있다고 Rails에 선언적으로 알리면 이러한 작업을 스트림라인할 수 있습니다. 저자와 책을 설정하기 위한 수정된 코드는 다음과 같습니다:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

이 변경으로 특정 저자에 대한 새 책을 만드는 것이 더 쉬워집니다:

```ruby
@book = @author.books.create(published_at: Time.now)
```

저자와 해당 저자의 모든 책을 삭제하는 것은 *훨씬* 쉬워집니다:

```ruby
author.destroy
```

다양한 유형의 연관 관계에 대해 자세히 알아보려면 이 가이드의 다음 섹션을 읽으십시오. 그 다음 연관 관계와 함께 작업하는 데 도움이 되는 팁과 트릭, 그리고 Rails에서 연관 관계에 대한 메서드와 옵션에 대한 완전한 참조가 이어집니다.

연관 관계의 유형
-------------------------

Rails는 특정 사용 사례를 고려한 여섯 가지 유형의 연관 관계를 지원합니다.

다음은 모든 지원되는 유형의 목록입니다. 더 자세한 정보를 얻으려면 API 문서로 이동하여 사용 방법, 메서드 매개 변수 등에 대한 자세한 정보를 확인하십시오.

* [`belongs_to`][]
* [`has_one`][]
* [`has_many`][]
* [`has_many :through`][`has_many`]
* [`has_one :through`][`has_one`]
* [`has_and_belongs_to_many`][]

연관 관계는 매크로 스타일의 호출을 사용하여 모델에 기능을 선언적으로 추가할 수 있도록 구현되었습니다. 예를 들어, 한 모델이 다른 모델에 `belongs_to`한다고 선언함으로써 Rails에 두 모델의 인스턴스 사이의 [기본 키](https://en.wikipedia.org/wiki/Primary_key)-[외래 키](https://en.wikipedia.org/wiki/Foreign_key) 정보를 유지하도록 지시하고 모델에 추가된 여러 유틸리티 메서드를 얻을 수 있습니다.

이 가이드의 나머지 부분에서는 다양한 형태의 연관 관계를 선언하고 사용하는 방법을 알아보겠습니다. 그러나 먼저 각 연관 관계 유형이 적합한 상황에 대해 간단히 소개하겠습니다.


### `belongs_to` 연관 관계

[`belongs_to`][] 연관 관계는 다른 모델과의 연결을 설정하여 선언 모델의 각 인스턴스가 다른 모델의 한 인스턴스에 "속한다"는 것을 의미합니다. 예를 들어, 애플리케이션이 저자와 책을 포함하고 각 책이 정확히 하나의 저자에 할당될 수 있는 경우, 책 모델을 다음과 같이 선언할 수 있습니다:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

![belongs_to 연관 관계 다이어그램](images/association_basics/belongs_to.png)

참고: `belongs_to` 연관 관계는 반드시 단수형을 사용해야 합니다. 위의 예에서 `Book` 모델의 `author` 연관 관계에 복수형을 사용하고 `Book.create(authors: author)`와 같이 인스턴스를 생성하려고 하면 "uninitialized constant Book::Authors"라는 오류가 발생합니다. 이는 Rails가 자동으로 연관 관계 이름에서 클래스 이름을 추론하기 때문입니다. 연관 관계 이름이 잘못 복수형으로 지정된 경우, 추론된 클래스 이름도 잘못 복수형으로 지정됩니다.

해당 마이그레이션은 다음과 같을 수 있습니다:

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

`belongs_to`를 단독으로 사용하면 단방향 일대일 연결을 생성합니다. 따라서 위의 예에서 각 책은 저자를 "알고" 있지만, 저자는 자신의 책을 알지 못합니다.
[양방향 연관 관계](#양방향-연관-관계)를 설정하려면 다른 모델, 이 경우 Author 모델에 `has_one` 또는 `has_many`와 함께 `belongs_to`를 사용하십시오.

`optional`이 true로 설정된 경우 `belongs_to`는 참조 일관성을 보장하지 않으므로 사용 사례에 따라 참조 열에 데이터베이스 수준의 외래 키 제약 조건을 추가해야 할 수도 있습니다.
```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```

### `has_one` 연관관계

[`has_one`][] 연관관계는 다른 모델이 이 모델을 참조하는 것을 나타냅니다. 이 연관관계를 통해 해당 모델을 가져올 수 있습니다.

예를 들어, 응용 프로그램에서 각 공급업체가 하나의 계정만 가지는 경우 공급업체 모델은 다음과 같이 선언됩니다:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

`belongs_to`와의 주요 차이점은 링크 열 `supplier_id`가 다른 테이블에 위치한다는 것입니다:

![has_one 연관관계 다이어그램](images/association_basics/has_one.png)

해당 마이그레이션은 다음과 같을 수 있습니다:

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end
  end
end
```

사용 사례에 따라 계정 테이블의 공급업체 열에 고유 인덱스와/또는 외래 키 제약 조건을 생성해야 할 수도 있습니다. 이 경우, 열 정의는 다음과 같을 수 있습니다:

```ruby
create_table :accounts do |t|
  t.belongs_to :supplier, index: { unique: true }, foreign_key: true
  # ...
end
```

이 관계는 다른 모델의 `belongs_to`와 함께 사용할 때 [양방향](#양방향-연관관계)일 수 있습니다.

### `has_many` 연관관계

[`has_many`][] 연관관계는 `has_one`과 유사하지만, 다른 모델과의 일대다 연결을 나타냅니다. 이 연관관계는 일반적으로 `belongs_to` 연관관계의 "다른 쪽"에 자주 사용됩니다. 이 연관관계는 모델의 각 인스턴스가 다른 모델의 0개 이상의 인스턴스를 가지고 있음을 나타냅니다. 예를 들어, 작가와 책이 포함된 응용 프로그램에서 작가 모델은 다음과 같이 선언될 수 있습니다:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

참고: 다른 모델의 이름은 `has_many` 연관관계를 선언할 때 복수형으로 표현됩니다.

![has_many 연관관계 다이어그램](images/association_basics/has_many.png)

해당 마이그레이션은 다음과 같을 수 있습니다:

```ruby
class CreateAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

사용 사례에 따라 books 테이블의 작가 열에는 일반적으로 고유하지 않은 인덱스와 선택적으로 외래 키 제약 조건을 생성하는 것이 좋습니다:

```ruby
create_table :books do |t|
  t.belongs_to :author, index: true, foreign_key: true
  # ...
end
```

### `has_many :through` 연관관계

[`has_many :through`][`has_many`] 연관관계는 다른 모델과의 다대다 연결을 설정하는 데 자주 사용됩니다. 이 연관관계는 선언 모델이 세 번째 모델을 통해 다른 모델의 0개 이상의 인스턴스와 일치할 수 있음을 나타냅니다. 예를 들어, 환자가 의사를 만나기 위해 예약을 하는 의료 실습을 고려해보십시오. 관련된 연관관계 선언은 다음과 같을 수 있습니다:

```ruby
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :physician
  belongs_to :patient
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end
```

![has_many :through 연관관계 다이어그램](images/association_basics/has_many_through.png)

해당 마이그레이션은 다음과 같을 수 있습니다:

```ruby
class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :physicians do |t|
      t.string :name
      t.timestamps
    end

    create_table :patients do |t|
      t.string :name
      t.timestamps
    end

    create_table :appointments do |t|
      t.belongs_to :physician
      t.belongs_to :patient
      t.datetime :appointment_date
      t.timestamps
    end
  end
end
```

결합 모델의 컬렉션은 [`has_many` 연관관계 메서드](#has-many-association-reference)를 통해 관리할 수 있습니다.
예를 들어, 다음과 같이 할당하면:

```ruby
physician.patients = patients
```

새로운 결합 모델이 자동으로 새로 연결된 객체에 대해 생성됩니다.
이전에 존재했던 일부 객체가 누락된 경우, 해당하는 결합 행이 자동으로 삭제됩니다.

경고: 결합 모델의 자동 삭제는 직접적으로 이루어지며, 삭제 콜백은 트리거되지 않습니다.

`has_many :through` 연관관계는 중첩된 `has_many` 연관관계를 통해 "단축키"를 설정하는 데에도 유용합니다. 예를 들어, 문서에는 섹션이 많이 있고, 섹션에는 단락이 많이 있는 경우, 때로는 문서의 모든 단락의 간단한 컬렉션을 얻고 싶을 수 있습니다. 다음과 같이 설정할 수 있습니다:

```ruby
class Document < ApplicationRecord
  has_many :sections
  has_many :paragraphs, through: :sections
end

class Section < ApplicationRecord
  belongs_to :document
  has_many :paragraphs
end

class Paragraph < ApplicationRecord
  belongs_to :section
end
```

`through: :sections`가 지정되면, Rails는 이제 다음을 이해합니다:

```ruby
@document.paragraphs
```

### `has_one :through` 연관관계

[`has_one :through`][`has_one`] 연관관계는 다른 모델과의 일대일 연결을 설정합니다. 이 연관관계는 선언 모델이 세 번째 모델을 통해 다른 모델의 하나의 인스턴스와 일치할 수 있음을 나타냅니다.
예를 들어, 각 공급업체가 하나의 계정을 가지고 있고, 각 계정이 하나의 계정 이력과 연관된 경우, 공급업체 모델은 다음과 같을 수 있습니다:```
```ruby
class Supplier < ApplicationRecord
  has_one :account
  has_one :account_history, through: :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  has_one :account_history
end

class AccountHistory < ApplicationRecord
  belongs_to :account
end
```

![has_one :through Association Diagram](images/association_basics/has_one_through.png)

해당 마이그레이션은 다음과 같을 수 있습니다:

```ruby
class CreateAccountHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account
      t.integer :credit_rating
      t.timestamps
    end
  end
end
```

### `has_and_belongs_to_many` 연관관계

[`has_and_belongs_to_many`][] 연관관계는 다른 모델과 직접적인 다대다 연결을 만듭니다. 이 연관관계는 선언 모델의 각 인스턴스가 다른 모델의 0개 이상의 인스턴스를 참조한다는 것을 나타냅니다. 예를 들어, 어셈블리와 부품이 포함된 응용 프로그램이 있고, 각 어셈블리에는 많은 부품이 있고 각 부품이 많은 어셈블리에 나타날 경우, 다음과 같이 모델을 선언할 수 있습니다:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

![has_and_belongs_to_many Association Diagram](images/association_basics/habtm.png)

해당 마이그레이션은 다음과 같을 수 있습니다:

```ruby
class CreateAssembliesAndParts < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies do |t|
      t.string :name
      t.timestamps
    end

    create_table :parts do |t|
      t.string :part_number
      t.timestamps
    end

    create_table :assemblies_parts, id: false do |t|
      t.belongs_to :assembly
      t.belongs_to :part
    end
  end
end
```

### `belongs_to`와 `has_one` 중에서 선택하기

두 모델 간에 일대일 관계를 설정하려면, 한 모델에 `belongs_to`를 추가하고 다른 모델에 `has_one`을 추가해야 합니다. 어떤 것이 어떤 것인지 어떻게 알 수 있을까요?

구분은 외래 키를 어디에 배치하는지에 있습니다(`belongs_to` 연관관계를 선언하는 클래스의 테이블에 배치됩니다). 그러나 데이터의 실제 의미에 대해서도 고려해야 합니다. `has_one` 관계는 어떤 것이 당신의 것인지를 나타냅니다. 예를 들어, 공급업체가 계정을 소유한다고 말하는 것이 계정이 공급업체를 소유한다고 말하는 것보다 더 의미가 있습니다. 이를 바탕으로 올바른 관계는 다음과 같습니다:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

해당 마이그레이션은 다음과 같을 수 있습니다:

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.bigint  :supplier_id
      t.string  :account_number
      t.timestamps
    end

    add_index :accounts, :supplier_id
  end
end
```

참고: `t.bigint :supplier_id`를 사용하면 외래 키의 이름을 명확하고 명시적으로 지정할 수 있습니다. 현재 버전의 Rails에서는 `t.references :supplier`를 사용하여 이 구현 세부 사항을 추상화할 수 있습니다.

### `has_many :through`와 `has_and_belongs_to_many` 중에서 선택하기

Rails는 모델 간의 다대다 관계를 선언하는 두 가지 다른 방법을 제공합니다. 첫 번째 방법은 `has_and_belongs_to_many`를 사용하는 것으로, 연관관계를 직접적으로 만들 수 있습니다:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

두 번째 방법은 `has_many :through`를 사용하는 것으로, 조인 모델을 통해 간접적으로 연관관계를 만듭니다:

```ruby
class Assembly < ApplicationRecord
  has_many :manifests
  has_many :parts, through: :manifests
end

class Manifest < ApplicationRecord
  belongs_to :assembly
  belongs_to :part
end

class Part < ApplicationRecord
  has_many :manifests
  has_many :assemblies, through: :manifests
end
```

가장 간단한 기준은 연관관계 모델을 독립적인 엔티티로 사용해야 하는지 여부에 따라 `has_many :through` 관계를 설정해야 합니다. 관계 모델과 아무런 작업을 수행할 필요가 없는 경우, `has_and_belongs_to_many` 관계를 설정하는 것이 더 간단할 수 있습니다(단, 데이터베이스에서 조인 테이블을 생성해야 합니다).

`has_many :through`를 사용해야 하는 경우, 관계 모델에서 유효성 검사, 콜백 또는 추가 속성이 필요한 경우입니다.

### 다형적 연관관계

연관관계의 약간 더 고급 기능은 _다형적 연관관계_입니다. 다형적 연관관계를 사용하면 모델이 하나 이상의 다른 모델에 속할 수 있습니다. 예를 들어, 직원 모델 또는 제품 모델에 속하는 사진 모델이 있을 수 있습니다. 다음과 같이 선언할 수 있습니다:

```ruby
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end
```

다형적 `belongs_to` 선언은 다른 모든 모델이 사용할 수 있는 인터페이스를 설정하는 것으로 생각할 수 있습니다. `Employee` 모델의 인스턴스에서 사진 컬렉션을 검색할 수 있습니다: `@employee.pictures`.
비슷하게, `@product.pictures`를 검색할 수 있습니다.

`Picture` 모델의 인스턴스가 있는 경우, `@picture.imageable`을 통해 해당 모델의 부모에 접근할 수 있습니다. 이를 작동시키기 위해 다음과 같이 다형성 인터페이스를 선언하는 모델에 외래 키 열과 유형 열을 모두 선언해야 합니다:

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string  :name
      t.bigint  :imageable_id
      t.string  :imageable_type
      t.timestamps
    end

    add_index :pictures, [:imageable_type, :imageable_id]
  end
end
```

이 마이그레이션은 `t.references` 형식을 사용하여 단순화할 수 있습니다:

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true
      t.timestamps
    end
  end
end
```

![다형성 관계 다이어그램](images/association_basics/polymorphic.png)

### Self Joins

데이터 모델을 설계할 때, 자체적으로 관계를 가져야 하는 모델을 때때로 찾을 수 있습니다. 예를 들어, 모든 직원을 단일 데이터베이스 모델에 저장하고 관리자와 부하 직원과 같은 관계를 추적할 수 있을 수도 있습니다. 이러한 상황은 자체 조인 관계로 모델링할 수 있습니다:

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true
end
```

이 설정을 사용하면 `@employee.subordinates`와 `@employee.manager`를 검색할 수 있습니다.

마이그레이션/스키마에서 모델 자체에 참조 열을 추가해야 합니다.

```ruby
class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :manager, foreign_key: { to_table: :employees }
      t.timestamps
    end
  end
end
```

참고: `foreign_key`에 전달되는 `to_table` 옵션 및 기타 옵션에 대한 자세한 내용은 [`SchemaStatements#add_reference`][connection.add_reference]를 참조하세요.


팁, 트릭 및 경고
--------------------------

Rails 애플리케이션에서 Active Record 연관 관계를 효율적으로 사용하기 위해 알아야 할 몇 가지 사항입니다:

* 캐싱 제어
* 이름 충돌 피하기
* 스키마 업데이트
* 연관 관계 범위 제어
* 양방향 연관 관계

### 캐싱 제어

모든 연관 관계 메서드는 캐싱을 기반으로 작동하며, 가장 최근 쿼리의 결과를 추가 작업에 사용할 수 있도록 유지합니다. 캐시는 메서드 간에도 공유됩니다. 예를 들어:

```ruby
# 데이터베이스에서 책을 검색합니다.
author.books.load

# 캐시된 책 사본을 사용합니다.
author.books.size

# 캐시된 책 사본을 사용합니다.
author.books.empty?
```

그러나 애플리케이션의 다른 부분에서 데이터가 변경될 수 있기 때문에 캐시를 다시로드하려면 연관 관계에 `reload`를 호출하면 됩니다:

```ruby
# 데이터베이스에서 책을 검색합니다.
author.books.load

# 캐시된 책 사본을 사용합니다.
author.books.size

# 캐시된 책 사본을 폐기하고 데이터베이스로 돌아갑니다.
author.books.reload.empty?
```

### 이름 충돌 피하기

연관 관계에는 원하는 이름을 자유롭게 사용할 수 없습니다. 연관 관계를 생성하면 해당 이름의 메서드가 모델에 추가되기 때문에 `ActiveRecord::Base`의 인스턴스 메서드와 동일한 이름을 연관 관계에 지정하는 것은 좋지 않습니다. 연관 관계 메서드는 기본 메서드를 덮어쓰고 문제를 발생시킬 수 있습니다. 예를 들어, `attributes` 또는 `connection`은 연관 관계에 대한 좋지 않은 이름입니다.

### 스키마 업데이트

연관 관계는 매우 유용하지만 마법은 아닙니다. 연관 관계와 일치하는 데이터베이스 스키마를 유지하는 것은 사용자의 책임입니다. 실제로, 이는 생성하는 연관 관계의 종류에 따라 두 가지를 의미합니다. `belongs_to` 연관 관계의 경우 외래 키를 생성해야 하며, `has_and_belongs_to_many` 연관 관계의 경우 적절한 조인 테이블을 생성해야 합니다.

#### `belongs_to` 연관 관계에 대한 외래 키 생성

`belongs_to` 연관 관계를 선언할 때, 외래 키를 적절하게 생성해야 합니다. 예를 들어, 다음과 같은 모델을 고려해 보세요:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

이 선언은 books 테이블에 해당하는 외래 키 열을 백업해야 합니다. 새로운 테이블의 경우, 마이그레이션은 다음과 같을 수 있습니다:

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.datetime   :published_at
      t.string     :book_number
      t.references :author
    end
  end
end
```

기존 테이블의 경우, 다음과 같을 수 있습니다:

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[7.1]
  def change
    add_reference :books, :author
  end
end
```

참고: 데이터베이스 수준에서 [참조 무결성을 강제하려면][foreign_keys], 위의 '참조' 열 선언에 `foreign_key: true` 옵션을 추가하세요.


#### `has_and_belongs_to_many` 연관 관계에 대한 조인 테이블 생성

`has_and_belongs_to_many` 연관 관계를 생성하는 경우, 명시적으로 조인 테이블을 생성해야 합니다. `:join_table` 옵션을 사용하여 조인 테이블의 이름을 명시적으로 지정하지 않는 한, Active Record는 클래스 이름의 사전 순서를 사용하여 이름을 생성합니다. 따라서 작가와 책 모델 간의 조인은 "authors_books"라는 기본 조인 테이블 이름을 제공합니다.
경고: 모델 이름 사이의 우선순위는 `String`의 `<=>` 연산자를 사용하여 계산됩니다. 이는 문자열이 서로 다른 길이를 가지고 있고, 문자열이 가장 짧은 길이까지 비교했을 때 동일한 경우, 더 긴 문자열이 더 낮은 사전 우선순위를 가진다는 것을 의미합니다. 예를 들어, "paper_boxes"와 "papers"라는 테이블은 "paper_boxes"라는 이름의 길이 때문에 "papers_paper_boxes"라는 조인 테이블 이름이 생성될 것으로 예상할 수 있지만, 실제로는 "paper_boxes_papers"라는 조인 테이블 이름이 생성됩니다 (공통 인코딩에서 밑줄 '\_'은 's'보다 사전적으로 _작습니다_).

어떤 이름이든 적절한 마이그레이션을 사용하여 조인 테이블을 수동으로 생성해야 합니다. 예를 들어, 다음과 같은 연관 관계를 고려해 보십시오:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

이러한 연관 관계는 `assemblies_parts` 테이블을 생성하는 마이그레이션으로 백업되어야 합니다. 이 테이블은 기본 키 없이 생성되어야 합니다:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.bigint :assembly_id
      t.bigint :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end
```

`create_table`에 `id: false`를 전달하는 이유는 해당 테이블이 모델을 나타내지 않기 때문입니다. 이는 연관 관계가 올바르게 작동하도록 필요합니다. `has_and_belongs_to_many` 연관 관계에서 모델 ID가 손상되거나 ID 충돌에 대한 예외와 같은 이상한 동작을 관찰하는 경우, 이 부분을 잊은 것입니다.

간단하게 `create_join_table` 메서드를 사용할 수도 있습니다:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :assemblies, :parts do |t|
      t.index :assembly_id
      t.index :part_id
    end
  end
end
```

### 연관 관계 범위 제어

기본적으로 연관 관계는 현재 모듈의 범위 내에서만 객체를 찾습니다. 이는 Active Record 모델을 모듈 내에서 선언할 때 중요할 수 있습니다. 예를 들어:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end

    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

이는 잘 작동합니다. 왜냐하면 `Supplier`와 `Account` 클래스가 동일한 범위 내에서 정의되었기 때문입니다. 그러나 다음은 작동하지 _않습니다_. 왜냐하면 `Supplier`와 `Account`가 서로 다른 범위에서 정의되었기 때문입니다:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

다른 네임스페이스의 모델과 모델을 연결하려면 연관 관계 선언에서 완전한 클래스 이름을 지정해야 합니다:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account,
        class_name: "MyApplication::Billing::Account"
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier,
        class_name: "MyApplication::Business::Supplier"
    end
  end
end
```

### 양방향 연관 관계

연관 관계는 일반적으로 두 방향에서 작동하도록 설계되어 있으며, 두 개의 다른 모델에서 선언해야 합니다:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Active Record는 연관 관계 이름을 기반으로 이 두 모델이 양방향 연관 관계를 공유한다는 것을 자동으로 식별하려고 시도합니다. 이 정보를 통해 Active Record는 다음을 수행할 수 있습니다:

* 이미로드된 데이터에 대한 불필요한 쿼리 방지:

    ```irb
    irb> author = Author.first
    irb> author.books.all? do |book|
    irb>   book.author.equal?(author) # 여기서 추가 쿼리가 실행되지 않음
    irb> end
    => true
    ```

* 일관되지 않은 데이터 방지 (로드된 `Author` 객체가 하나뿐이므로):

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "변경된 이름"
    irb> author.name == book.author.name
    => true
    ```

* 더 많은 경우에 자동으로 연관 관계 저장:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => true
    ```

* [존재](active_record_validations.html#presence) 및 [부재](active_record_validations.html#absence) 유효성 검사를 더 많은 경우에 적용:

    ```irb
    irb> book = Book.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => true
    ```

Active Record는 대부분의 표준 이름을 가진 연관 관계에 대해 자동 식별을 지원합니다. 그러나 `:through` 또는 `:foreign_key` 옵션을 포함하는 양방향 연관 관계는 자동으로 식별되지 않습니다.

역방향 연관 관계의 사용자 정의 스코프도 자동 식별을 방지하며, [`config.active_record.automatic_scope_inversing`][]이 true로 설정되어 있지 않은 한, 연관 관계 자체의 사용자 정의 스코프도 자동 식별을 방지합니다 (새로운 애플리케이션의 기본값).

예를 들어, 다음과 같은 모델 선언을 고려해 보십시오:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

`:foreign_key` 옵션 때문에 Active Record는 더 이상 양방향 연관 관계를 자동으로 인식하지 않습니다. 이로 인해 응용 프로그램이 다음과 같은 문제가 발생할 수 있습니다:
* 동일한 데이터에 대해 불필요한 쿼리를 실행합니다 (이 예제에서는 N+1 쿼리를 발생시킵니다):

    ```irb
    irb> author = Author.first
    irb> author.books.any? do |book|
    irb>   book.author.equal?(author) # 이는 각 책마다 작가 쿼리를 실행합니다
    irb> end
    => false
    ```

* 일관되지 않은 데이터로 모델의 여러 복사본을 참조합니다:

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "변경된 이름"
    irb> author.name == book.author.name
    => false
    ```

* 연관된 객체를 자동으로 저장하지 못합니다:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => false
    ```

* 존재 또는 부재를 유효성 검사하지 못합니다:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    ```

Active Record는 양방향 연관을 명시적으로 선언할 수 있는 `:inverse_of` 옵션을 제공합니다:

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

`has_many` 연관 선언에 `:inverse_of` 옵션을 포함시킴으로써,
Active Record는 이제 양방향 연관을 인식하고 초기 예제와 같이 동작합니다.


자세한 연관 참조
------------------------------

다음 섹션에서는 각 유형의 연관에 대한 세부 정보를 제공하며, 연관을 선언할 때 사용할 수 있는 옵션 및 추가하는 메서드를 설명합니다.

### `belongs_to` 연관 참조

데이터베이스 용어로 `belongs_to` 연관은 이 모델의 테이블에 다른 테이블을 참조하는 열이 포함되어 있다는 것을 나타냅니다.
이를 통해 일대일 또는 일대다 관계를 설정할 수 있습니다.
다른 클래스의 테이블이 일대일 관계에서 참조를 포함하고 있는 경우, 대신 `has_one`을 사용해야 합니다.

#### `belongs_to`에 의해 추가된 메서드

`belongs_to` 연관을 선언하면, 선언된 클래스에는 연관에 관련된 8개의 메서드가 자동으로 추가됩니다:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`
* `association_changed?`
* `association_previously_changed?`

이러한 메서드 중에서 `association`은 `belongs_to`에 전달된 첫 번째 인수로 전달된 심볼로 대체됩니다. 예를 들어, 다음과 같이 선언된 경우:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

`Book` 모델의 각 인스턴스에는 다음과 같은 메서드가 있습니다:

* `author`
* `author=`
* `build_author`
* `create_author`
* `create_author!`
* `reload_author`
* `reset_author`
* `author_changed?`
* `author_previously_changed?`

참고: 새로운 `has_one` 또는 `belongs_to` 연관을 초기화할 때는 `has_many` 또는 `has_and_belongs_to_many` 연관에 사용되는 `association.build` 메서드 대신 `build_` 접두사를 사용하여 연관을 빌드해야 합니다. 하나를 생성하려면 `create_` 접두사를 사용하세요.

##### `association`

`association` 메서드는 연관된 객체를 반환합니다. 연관된 객체가 없는 경우 `nil`을 반환합니다.

```ruby
@author = @book.author
```

연관된 객체가 이미 이 객체에 대해 데이터베이스에서 검색되었을 경우, 캐시된 버전이 반환됩니다. 이 동작을 재정의하려면 (및 데이터베이스 읽기를 강제로 실행하려면) 부모 객체에서 `#reload_association`을 호출하세요.

```ruby
@author = @book.reload_author
```

연관된 객체의 캐시된 버전을 언로드하여 (있는 경우) 다음 액세스에서 데이터베이스에서 쿼리되도록 하려면 부모 객체에서 `#reset_association`을 호출하세요.

```ruby
@book.reset_author
```

##### `association=(associate)`

`association=` 메서드는 이 객체에 연관된 객체를 할당합니다. 내부적으로 이는 연관된 객체에서 기본 키를 추출하고 이 객체의 외래 키를 동일한 값으로 설정하는 것을 의미합니다.

```ruby
@book.author = @author
```

##### `build_association(attributes = {})`

`build_association` 메서드는 연관된 유형의 새로운 객체를 반환합니다. 이 객체는 전달된 속성에서 인스턴스화되며, 이 객체의 외래 키를 통한 링크가 설정되지만 연관된 객체는 아직 저장되지 않습니다.

```ruby
@author = @book.build_author(author_number: 123,
                             author_name: "John Doe")
```

##### `create_association(attributes = {})`

`create_association` 메서드는 연관된 유형의 새로운 객체를 반환합니다. 이 객체는 전달된 속성에서 인스턴스화되며, 이 객체의 외래 키를 통한 링크가 설정되며, 연관된 모델에서 지정된 모든 유효성 검사를 통과하면 연관된 객체가 저장됩니다.

```ruby
@author = @book.create_author(author_number: 123,
                              author_name: "John Doe")
```

##### `create_association!(attributes = {})`

`create_association`과 동일한 작업을 수행하지만, 레코드가 유효하지 않은 경우 `ActiveRecord::RecordInvalid`를 발생시킵니다.

##### `association_changed?`

`association_changed?` 메서드는 새로운 연관된 객체가 할당되었고 외래 키가 다음 저장에서 업데이트될 것인지 여부를 반환합니다.
```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.author_changed? # => true

@book.save!
@book.author_changed? # => false
```

##### `association_previously_changed?`

`association_previously_changed?` 메소드는 이전 저장이 새로운 연관 객체를 참조하도록 연관을 업데이트했을 경우 true를 반환합니다.

```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_previously_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.save!
@book.author_previously_changed? # => true
```

#### `belongs_to` 옵션

Rails는 대부분의 상황에서 잘 작동하는 지능적인 기본값을 사용하지만, `belongs_to` 연관 참조의 동작을 사용자 정의하고 싶을 때가 있을 수 있습니다. 이러한 사용자 정의는 연관을 생성할 때 옵션과 스코프 블록을 전달하여 쉽게 수행할 수 있습니다. 예를 들어, 다음과 같이 두 가지 옵션을 사용하는 연관을 생성하는 예입니다:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at,
    counter_cache: true
end
```

[`belongs_to`][] 연관은 다음과 같은 옵션을 지원합니다:

* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:primary_key`
* `:inverse_of`
* `:polymorphic`
* `:touch`
* `:validate`
* `:optional`

##### `:autosave`

`:autosave` 옵션을 `true`로 설정하면, Rails는 부모 객체를 저장할 때 로드된 연관 멤버를 저장하고, 삭제 대상으로 표시된 멤버를 삭제합니다. `:autosave`를 `false`로 설정하는 것은 `:autosave` 옵션을 설정하지 않는 것과 같지 않습니다. `:autosave` 옵션이 없으면 새로운 연관 객체는 저장되지만, 업데이트된 연관 객체는 저장되지 않습니다.

##### `:class_name`

다른 모델의 이름을 연관 이름에서 유도할 수 없는 경우, `:class_name` 옵션을 사용하여 모델 이름을 제공할 수 있습니다. 예를 들어, 책이 작가에 속하지만 작가를 포함하는 모델의 실제 이름이 `Patron`인 경우 다음과 같이 설정할 수 있습니다:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron"
end
```

##### `:counter_cache`

`:counter_cache` 옵션은 소속된 객체의 수를 효율적으로 찾을 수 있도록 합니다. 다음과 같은 모델을 고려해 보겠습니다:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :books
end
```

이러한 선언을 사용하면 `@author.books.size`의 값을 얻기 위해 데이터베이스에 `COUNT(*)` 쿼리를 수행해야 합니다. 이 호출을 피하려면 소속 모델에 카운터 캐시를 추가할 수 있습니다:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end

class Author < ApplicationRecord
  has_many :books
end
```

이 선언을 사용하면 Rails는 캐시 값을 최신 상태로 유지한 다음 `size` 메소드에 대한 응답으로 해당 값을 반환합니다.

`counter_cache` 옵션은 `belongs_to` 선언을 포함하는 모델에 지정되지만, 실제 열은 소속된 (`has_many`) 모델에 추가해야 합니다. 위의 경우 `Author` 모델에 `books_count`라는 열을 추가해야 합니다.

기본 열 이름을 사용자 정의 열 이름으로 재정의하려면 `counter_cache` 선언에서 `true` 대신 사용자 정의 열 이름을 지정하면 됩니다. 예를 들어, `books_count` 대신 `count_of_books`를 사용하려면:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: :count_of_books
end

class Author < ApplicationRecord
  has_many :books
end
```

참고: `:counter_cache` 옵션은 연관의 `belongs_to` 쪽에만 지정하면 됩니다.

카운터 캐시 열은 `attr_readonly`를 통해 소유 모델의 읽기 전용 속성 목록에 추가됩니다.

소유 모델의 기본 키 값을 변경하고, 카운트된 모델의 외래 키도 업데이트하지 않은 경우 카운터 캐시에 잘못된 데이터가 남을 수 있습니다. 즉, 고아 모델은 여전히 카운터에 포함됩니다. 잘못된 카운터 캐시를 수정하려면 [`reset_counters`][]를 사용하세요.


##### `:dependent`

`:dependent` 옵션을 다음 중 하나로 설정하면:

* `:destroy` - 객체가 삭제될 때 연관된 객체에 `destroy`가 호출됩니다.
* `:delete` - 객체가 삭제될 때 연관된 모든 객체가 `destroy` 메소드를 호출하지 않고 직접 데이터베이스에서 삭제됩니다.
* `:destroy_async` - 객체가 삭제될 때 `ActiveRecord::DestroyAssociationAsyncJob` 작업이 예약되어 연관된 객체에 대해 `destroy`가 호출됩니다. 이 작업을 사용하려면 Active Job이 설정되어 있어야 합니다. 데이터베이스에서 외래 키 제약 조건으로 지원되는 경우 이 옵션을 사용하지 마세요. 외래 키 제약 조건은 소유자를 삭제하는 동일한 트랜잭션 내에서 발생합니다.
경고: 다른 클래스의 `has_many` 연관 관계와 연결된 `belongs_to` 연관 관계에 이 옵션을 지정해서는 안됩니다. 이렇게 하면 데이터베이스에 고아 레코드가 남을 수 있습니다.

##### `:foreign_key`

관례적으로 Rails는 이 모델에서 외래 키를 보유하는 열의 이름이 접미사 `_id`가 추가된 연관 관계의 이름으로 가정합니다. `:foreign_key` 옵션을 사용하면 외래 키의 이름을 직접 설정할 수 있습니다:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                      foreign_key: "patron_id"
end
```

팁: 어떤 경우에도 Rails는 외래 키 열을 자동으로 생성하지 않습니다. 마이그레이션의 일부로 명시적으로 정의해야 합니다.

##### `:primary_key`

관례적으로 Rails는 테이블의 기본 키로 `id` 열을 사용한다고 가정합니다. `:primary_key` 옵션을 사용하면 다른 열을 지정할 수 있습니다.

예를 들어, `users` 테이블에 `guid`를 기본 키로 사용하는 경우를 가정해 봅시다. `todos` 테이블에는 `guid` 열에 외래 키 `user_id`를 보유하도록 별도의 테이블을 만들고 싶다면 다음과 같이 `primary_key`를 사용할 수 있습니다:

```ruby
class User < ApplicationRecord
  self.primary_key = 'guid' # 기본 키는 id가 아닌 guid입니다.
end

class Todo < ApplicationRecord
  belongs_to :user, primary_key: 'guid'
end
```

`@user.todos.create`를 실행하면 `@todo` 레코드의 `user_id` 값은 `@user`의 `guid` 값이 됩니다.

##### `:inverse_of`

`:inverse_of` 옵션은 이 연관 관계의 역방향인 `has_many` 또는 `has_one` 연관 관계의 이름을 지정합니다.
자세한 내용은 [양방향 연관 관계](#bi-directional-associations) 섹션을 참조하세요.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:polymorphic`

`:polymorphic` 옵션에 `true`를 전달하면 다형성 연관 관계임을 나타냅니다. 다형성 연관 관계에 대해 자세히 설명한 내용은 <a href="#polymorphic-associations">이 가이드의 이전 부분</a>에서 다루었습니다.

##### `:touch`

`:touch` 옵션을 `true`로 설정하면 연관된 객체가 저장되거나 삭제될 때 연관된 객체의 `updated_at` 또는 `updated_on` 타임스탬프가 현재 시간으로 설정됩니다:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: true
end

class Author < ApplicationRecord
  has_many :books
end
```

이 경우, 책을 저장하거나 삭제하면 연관된 작가의 타임스탬프가 업데이트됩니다. 특정 타임스탬프 속성을 업데이트하도록 지정할 수도 있습니다:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at
end
```

##### `:validate`

`:validate` 옵션을 `true`로 설정하면 이 객체를 저장할 때 새로운 연관된 객체가 유효성을 검사합니다. 기본적으로 이 값은 `false`이며, 이 객체를 저장할 때 새로운 연관된 객체의 유효성을 검사하지 않습니다.

##### `:optional`

`:optional` 옵션을 `true`로 설정하면 연관된 객체의 존재 여부를 검증하지 않습니다.
기본적으로 이 옵션은 `false`로 설정됩니다.

#### `belongs_to`를 위한 스코프

`belongs_to`에서 사용되는 쿼리를 사용자 정의하고 싶을 때가 있을 수 있습니다. 이러한 사용자 정의는 스코프 블록을 통해 구현할 수 있습니다. 예를 들어:

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

스코프 블록 내에서 표준 [쿼리 메서드](active_record_querying.html)를 사용할 수 있습니다. 아래에서는 몇 가지 방법에 대해 설명합니다:

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

`where` 메서드를 사용하면 연관된 객체가 충족해야 하는 조건을 지정할 수 있습니다.

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

##### `includes`

`includes` 메서드를 사용하여 이 연관 관계를 사용할 때 eager loading되어야 하는 2차 연관 관계를 지정할 수 있습니다. 예를 들어, 다음과 같은 모델을 고려해 보세요:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

자주 챕터에서 직접 작가를 검색하는 경우 (`@chapter.book.author`), 챕터에서 책으로의 연관 관계에 작가를 포함시켜 코드를 조금 더 효율적으로 만들 수 있습니다:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book, -> { includes :author }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

참고: 즉시 연관 관계에는 `includes`를 사용할 필요가 없습니다. 즉, `Book belongs_to :author`와 같이 작가는 필요할 때 자동으로 eager loading됩니다.

##### `readonly`

`readonly`를 사용하면 연관된 객체는 연관 관계를 통해 검색될 때 읽기 전용으로 설정됩니다.
##### `select`

`select` 메소드를 사용하면 연관된 객체에 대한 데이터를 검색하는 데 사용되는 SQL `SELECT` 절을 재정의할 수 있습니다. 기본적으로 Rails는 모든 열을 검색합니다.

팁: `belongs_to` 연관에 `select` 메소드를 사용하는 경우 `:foreign_key` 옵션도 설정하여 올바른 결과를 보장해야 합니다.

#### 연관된 객체가 존재하는지 확인하기

`association.nil?` 메소드를 사용하여 연관된 객체가 있는지 확인할 수 있습니다:

```ruby
if @book.author.nil?
  @msg = "이 책에는 작가가 없습니다"
end
```

#### 객체는 언제 저장되나요?

`belongs_to` 연관에 객체를 할당하는 것은 객체를 자동으로 저장하지 않습니다. 연관된 객체도 저장하지 않습니다.

### `has_one` 연관 참조

`has_one` 연관은 다른 모델과 일대일 매칭을 생성합니다. 데이터베이스 용어로 이 연관은 다른 클래스가 외래 키를 포함한다고 말합니다. 이 클래스가 외래 키를 포함하는 경우 `belongs_to`를 사용해야 합니다.

#### `has_one`에 의해 추가된 메소드

`has_one` 연관을 선언하면 선언된 클래스에는 연관된 연관에 관련된 6개의 메소드가 자동으로 추가됩니다:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`

이러한 메소드에서 `association`은 `has_one`에 전달된 첫 번째 인수로 대체됩니다. 예를 들어 다음 선언이 주어진 경우:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

`Supplier` 모델의 각 인스턴스에는 다음과 같은 메소드가 있습니다:

* `account`
* `account=`
* `build_account`
* `create_account`
* `create_account!`
* `reload_account`
* `reset_account`

참고: 새로운 `has_one` 또는 `belongs_to` 연관을 초기화할 때 `has_many` 또는 `has_and_belongs_to_many` 연관에 사용되는 `association.build` 메소드 대신 `build_` 접두사를 사용하여 연관을 빌드해야 합니다. 하나를 생성하려면 `create_` 접두사를 사용하세요.

##### `association`

`association` 메소드는 연관된 객체를 반환합니다. 연관된 객체가 없는 경우 `nil`을 반환합니다.

```ruby
@account = @supplier.account
```

연관된 객체가 이미 이 객체에 대해 데이터베이스에서 검색되었을 경우 캐시된 버전이 반환됩니다. 이 동작을 재정의하려면 (데이터베이스 읽기를 강제로 수행하기 위해) 부모 객체에서 `#reload_association`을 호출하세요.

```ruby
@account = @supplier.reload_account
```

연관된 객체의 캐시된 버전을 언로드하여 (다음 액세스가 있을 경우) 데이터베이스에서 쿼리하여 얻을 수 있도록 하려면 부모 객체에서 `#reset_association`을 호출하세요.

```ruby
@supplier.reset_account
```

##### `association=(associate)`

`association=` 메소드는 이 객체에 연관된 객체를 할당합니다. 내부적으로 이는 이 객체에서 기본 키를 추출하고 연관된 객체의 외래 키를 동일한 값으로 설정하는 것을 의미합니다.

```ruby
@supplier.account = @account
```

##### `build_association(attributes = {})`

`build_association` 메소드는 연관된 유형의 새로운 객체를 반환합니다. 이 객체는 전달된 속성에서 인스턴스화되고, 외래 키를 통한 링크가 설정되지만 연관된 객체는 아직 저장되지 않습니다.

```ruby
@account = @supplier.build_account(terms: "Net 30")
```

##### `create_association(attributes = {})`

`create_association` 메소드는 연관된 유형의 새로운 객체를 반환합니다. 이 객체는 전달된 속성에서 인스턴스화되고, 외래 키를 통한 링크가 설정되며, 연관된 모델에서 지정된 모든 유효성을 통과하면 연관된 객체가 저장됩니다.

```ruby
@account = @supplier.create_account(terms: "Net 30")
```

##### `create_association!(attributes = {})`

`create_association`과 동일하지만 레코드가 유효하지 않은 경우 `ActiveRecord::RecordInvalid`를 발생시킵니다.

#### `has_one`에 대한 옵션

Rails는 대부분의 상황에서 잘 작동하는 지능적인 기본값을 사용하지만, `has_one` 연관 참조의 동작을 사용자 정의하고 싶을 때가 있을 수 있습니다. 이러한 사용자 정의는 연관을 생성할 때 옵션을 전달하여 쉽게 수행할 수 있습니다. 예를 들어, 다음 연관은 두 가지 옵션을 사용합니다:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing", dependent: :nullify
end
```

[`has_one`][] 연관은 다음 옵션을 지원합니다:

* `:as`
* `:autosave`
* `:class_name`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:touch`
* `:validate`

##### `:as`

`:as` 옵션을 설정하면 이것이 다형적 연관임을 나타냅니다. 다형적 연관에 대해 자세히 설명한 내용은 [이 가이드의 이전 부분](#polymorphic-associations)에서 다루었습니다.

##### `:autosave`

`:autosave` 옵션을 `true`로 설정하면 Rails는 로드된 연관 멤버를 저장하고, 삭제할 멤버를 삭제합니다. 이를 위해 부모 객체를 저장할 때마다 `:autosave`를 `false`로 설정하는 것과는 다릅니다. `:autosave` 옵션이 없는 경우 새로운 연관된 객체는 저장되지만, 업데이트된 연관된 객체는 저장되지 않습니다.
##### `:class_name`

만약 다른 모델의 이름을 연관 이름에서 유도할 수 없는 경우, `:class_name` 옵션을 사용하여 모델 이름을 지정할 수 있습니다. 예를 들어, 공급업체가 계정을 가지고 있지만, 실제로 계정을 포함하는 모델의 이름이 `Billing`인 경우 다음과 같이 설정할 수 있습니다:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing"
end
```

##### `:dependent`

소유자가 삭제될 때 연관된 객체에 대해 어떤 작업을 수행할지를 제어합니다:

* `:destroy`는 연관된 객체도 삭제합니다.
* `:delete`는 연관된 객체를 데이터베이스에서 직접 삭제합니다(콜백은 실행되지 않습니다).
* `:destroy_async`: 객체가 삭제되면 `ActiveRecord::DestroyAssociationAsyncJob` 작업이 예약되어 연관된 객체에 대해 destroy를 호출합니다. 이 작업을 사용하려면 Active Job이 설정되어 있어야 합니다. 데이터베이스에서 외래 키 제약 조건을 사용하는 경우 이 옵션을 사용하지 마십시오. 외래 키 제약 조건은 소유자를 삭제하는 동일한 트랜잭션 내에서 발생합니다.
* `:nullify`는 외래 키를 `NULL`로 설정합니다. 다형성 유형 열은 다형성 연관에서도 null로 설정됩니다. 콜백은 실행되지 않습니다.
* `:restrict_with_exception`는 연관된 레코드가 있는 경우 `ActiveRecord::DeleteRestrictionError` 예외를 발생시킵니다.
* `:restrict_with_error`는 연관된 객체가 있는 경우 소유자에 오류를 추가합니다.

`NOT NULL` 데이터베이스 제약 조건이 있는 연관에 대해 `:nullify` 옵션을 설정하거나 남겨두지 않는 것이 중요합니다. 연관을 삭제하지 않고 `dependent`를 설정하지 않으면 연관된 객체를 변경할 수 없습니다. 초기 연관된 객체의 외래 키가 허용되지 않는 `NULL` 값으로 설정됩니다.

##### `:foreign_key`

관례적으로 Rails는 다른 모델에 대한 외래 키를 이 모델의 이름에 `_id` 접미사를 추가한 것으로 가정합니다. `:foreign_key` 옵션을 사용하면 외래 키의 이름을 직접 설정할 수 있습니다:

```ruby
class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
end
```

팁: 어떤 경우에도 Rails는 외래 키 열을 자동으로 생성하지 않습니다. 마이그레이션의 일부로 명시적으로 정의해야 합니다.

##### `:inverse_of`

`:inverse_of` 옵션은 이 연관의 역으로 작용하는 `belongs_to` 연관의 이름을 지정합니다.
자세한 내용은 [양방향 연관](#bi-directional-associations) 섹션을 참조하십시오.

```ruby
class Supplier < ApplicationRecord
  has_one :account, inverse_of: :supplier
end

class Account < ApplicationRecord
  belongs_to :supplier, inverse_of: :account
end
```

##### `:primary_key`

관례적으로 Rails는 이 모델의 기본 키를 `id`로 사용하는 것으로 가정합니다. `:primary_key` 옵션을 사용하여 기본 키의 이름을 직접 지정할 수 있습니다.

##### `:source`

`:source` 옵션은 `has_one :through` 연관에 대한 소스 연관 이름을 지정합니다.

##### `:source_type`

`:source_type` 옵션은 다형성 연관을 통해 진행되는 `has_one :through` 연관에 대한 소스 연관 유형을 지정합니다.

```ruby
class Author < ApplicationRecord
  has_one :book
  has_one :hardback, through: :book, source: :format, source_type: "Hardback"
  has_one :dust_jacket, through: :hardback
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Paperback < ApplicationRecord; end

class Hardback < ApplicationRecord
  has_one :dust_jacket
end

class DustJacket < ApplicationRecord; end
```

##### `:through`

`:through` 옵션은 쿼리를 수행하기 위해 사용할 조인 모델을 지정합니다. `has_one :through` 연관에 대해 자세히 설명된 내용은 [이 가이드의 이전 섹션](#the-has-one-through-association)에서 다루었습니다.

##### `:touch`

`:touch` 옵션을 `true`로 설정하면, 이 객체가 저장되거나 삭제될 때 연관된 객체의 `updated_at` 또는 `updated_on` 타임스탬프가 현재 시간으로 설정됩니다:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: true
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

이 경우, 공급업체를 저장하거나 삭제하면 연관된 계정의 타임스탬프가 업데이트됩니다. 특정 타임스탬프 속성을 업데이트하도록 지정할 수도 있습니다:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: :suppliers_updated_at
end
```

##### `:validate`

`:validate` 옵션을 `true`로 설정하면, 이 객체를 저장할 때 새로운 연관된 객체가 유효성 검사됩니다. 기본적으로 이 값은 `false`이며, 이 객체를 저장할 때 새로운 연관된 객체는 유효성 검사되지 않습니다.

#### `has_one`에 대한 스코프

`has_one`을 사용하는 쿼리를 사용자 정의하고자 할 때가 있을 수 있습니다. 이러한 사용자 정의는 스코프 블록을 통해 구현할 수 있습니다. 예를 들어:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```
스코프 블록 내에서는 표준 [쿼리 메서드](active_record_querying.html) 중 하나를 사용할 수 있습니다. 다음은 아래에서 설명하는 메서드입니다.

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

`where` 메서드를 사용하여 연관된 객체가 충족해야하는 조건을 지정할 수 있습니다.

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where "confirmed = 1" }
end
```

##### `includes`

`includes` 메서드를 사용하여 이 연관이 사용될 때 eager loading되어야하는 2차 연관을 지정할 수 있습니다. 예를 들어, 다음과 같은 모델을 고려해보십시오.

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

자주 공급업체에서 직접 대표를 검색하는 경우 (`@supplier.account.representative`), 공급업체에서 계정으로 대표를 포함하여 코드를 조금 더 효율적으로 만들 수 있습니다.

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { includes :representative }
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

##### `readonly`

`readonly` 메서드를 사용하면 연관된 객체가 연관을 통해 검색 될 때 읽기 전용으로 설정됩니다.

##### `select`

`select` 메서드를 사용하면 연관된 객체에 대한 데이터를 검색하는 데 사용되는 SQL `SELECT` 절을 재정의 할 수 있습니다. 기본적으로 Rails는 모든 열을 검색합니다.

#### 연관된 객체가 있는지 확인하기

`association.nil?` 메서드를 사용하여 연관된 객체가 있는지 확인할 수 있습니다.

```ruby
if @supplier.account.nil?
  @msg = "No account found for this supplier"
end
```

#### 객체가 언제 저장되나요?

`has_one` 연관에 객체를 할당하면 해당 객체가 자동으로 저장됩니다 (외래 키를 업데이트하기 위해). 또한 대체되는 객체도 자동으로 저장되며, 외래 키도 변경됩니다.

이러한 저장 중 하나라도 유효성 검사 오류로 인해 실패하면 할당 문이 `false`를 반환하고 할당 자체가 취소됩니다.

부모 객체 (`has_one` 연관을 선언하는 객체)가 저장되지 않은 경우 (즉, `new_record?`가 `true`를 반환하는 경우) 자식 객체는 저장되지 않습니다. 부모 객체가 저장될 때 자동으로 저장됩니다.

객체를 저장하지 않고 `has_one` 연관에 객체를 할당하려면 `build_association` 메서드를 사용하십시오.

### `has_many` 연관 참조

`has_many` 연관은 다른 모델과의 일대다 관계를 생성합니다. 데이터베이스 용어로 이 연관은 다른 클래스가 이 클래스의 인스턴스를 참조하는 외래 키를 가질 것이라고 말합니다.

#### `has_many`에 의해 추가된 메서드

`has_many` 연관을 선언하면 선언 클래스에는 연관된 메서드와 관련된 17개의 메서드가 자동으로 추가됩니다.

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

이러한 메서드 중 `collection`은 `has_many`에 전달된 첫 번째 인수로 대체되고, `collection_singular`은 해당 심볼의 단수형 버전으로 대체됩니다. 예를 들어, 다음 선언이 주어진 경우:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

`Author` 모델의 각 인스턴스에는 다음 메서드가 있습니다.

```ruby
books
books<<(object, ...)
books.delete(object, ...)
books.destroy(object, ...)
books=(objects)
book_ids
book_ids=(ids)
books.clear
books.empty?
books.size
books.find(...)
books.where(...)
books.exists?(...)
books.build(attributes = {}, ...)
books.create(attributes = {})
books.create!(attributes = {})
books.reload
```

##### `collection`

`collection` 메서드는 연관된 모든 객체의 Relation을 반환합니다. 연관된 객체가 없으면 빈 Relation을 반환합니다.

```ruby
@books = @author.books
```

##### `collection<<(object, ...)`

[`collection<<`][] 메서드는 하나 이상의 객체를 컬렉션에 추가하여 외래 키를 호출 모델의 기본 키로 설정합니다.

```ruby
@author.books << @book1
```

##### `collection.delete(object, ...)`

[`collection.delete`][] 메서드는 하나 이상의 객체를 컬렉션에서 제거하여 외래 키를 `NULL`로 설정합니다.

```ruby
@author.books.delete(@book1)
```

경고: 또한 `dependent: :destroy`와 관련된 경우 객체가 파괴되고 `dependent: :delete_all`과 관련된 경우 삭제됩니다.

##### `collection.destroy(object, ...)`

[`collection.destroy`][] 메서드는 각 객체에 대해 `destroy`를 실행하여 컬렉션에서 하나 이상의 객체를 제거합니다.

```ruby
@author.books.destroy(@book1)
```

경고: `:dependent` 옵션을 무시하고 객체가 항상 데이터베이스에서 제거됩니다.

##### `collection=(objects)`

`collection=` 메서드는 컬렉션을 제공된 객체로만 구성하도록 만들어 추가 및 삭제를 적절하게 수행합니다. 변경 사항은 데이터베이스에 유지됩니다.
##### `collection_singular_ids`

`collection_singular_ids` 메소드는 컬렉션에 있는 객체들의 id 배열을 반환합니다.

```ruby
@book_ids = @author.book_ids
```

##### `collection_singular_ids=(ids)`

`collection_singular_ids=` 메소드는 컬렉션에 주어진 기본 키 값으로 식별된 객체만 포함하도록 만듭니다. 필요한 경우 추가 및 삭제를 통해 변경 사항이 데이터베이스에 유지됩니다.

##### `collection.clear`

[`collection.clear`][] 메소드는 `dependent` 옵션에 지정된 전략에 따라 컬렉션에서 모든 객체를 제거합니다. 옵션이 지정되지 않은 경우 기본 전략을 따릅니다. `has_many :through` 연관에서의 기본 전략은 `delete_all`이고, `has_many` 연관에서의 기본 전략은 외래 키를 `NULL`로 설정하는 것입니다.

```ruby
@author.books.clear
```

경고: `dependent: :destroy` 또는 `dependent: :destroy_async`와 연관된 경우 객체가 삭제됩니다. 마치 `dependent: :delete_all`과 같이요.

##### `collection.empty?`

[`collection.empty?`][] 메소드는 컬렉션이 관련된 객체를 포함하지 않는 경우 `true`를 반환합니다.

```erb
<% if @author.books.empty? %>
  No Books Found
<% end %>
```

##### `collection.size`

[`collection.size`][] 메소드는 컬렉션에 있는 객체의 수를 반환합니다.

```ruby
@book_count = @author.books.size
```

##### `collection.find(...)`

[`collection.find`][] 메소드는 컬렉션의 테이블에서 객체를 찾습니다.

```ruby
@available_book = @author.books.find(1)
```

##### `collection.where(...)`

[`collection.where`][] 메소드는 제공된 조건에 따라 컬렉션 내에서 객체를 찾지만, 객체는 게으르게 로드되므로 객체에 액세스할 때만 데이터베이스가 쿼리됩니다.

```ruby
@available_books = author.books.where(available: true) # 아직 쿼리되지 않음
@available_book = @available_books.first # 이제 데이터베이스가 쿼리됩니다.
```

##### `collection.exists?(...)`

[`collection.exists?`][] 메소드는 컬렉션의 테이블에서 제공된 조건을 충족하는 객체가 있는지 확인합니다.

##### `collection.build(attributes = {})`

[`collection.build`][] 메소드는 연관된 유형의 새로운 개체를 단일 또는 배열로 반환합니다. 개체는 전달된 속성에서 인스턴스화되고, 외래 키를 통한 링크가 생성되지만, 연관된 객체는 아직 저장되지 않습니다.

```ruby
@book = author.books.build(published_at: Time.now,
                            book_number: "A12345")

@books = author.books.build([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create(attributes = {})`

[`collection.create`][] 메소드는 연관된 유형의 새로운 개체를 단일 또는 배열로 반환합니다. 개체는 전달된 속성에서 인스턴스화되고, 외래 키를 통한 링크가 생성되며, 연관된 객체가 연관 모델에서 지정된 모든 유효성 검사를 통과하면 연관된 객체가 저장됩니다.

```ruby
@book = author.books.create(published_at: Time.now,
                             book_number: "A12345")

@books = author.books.create([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create!(attributes = {})`

`collection.create`와 동일하지만, 레코드가 유효하지 않은 경우 `ActiveRecord::RecordInvalid`를 발생시킵니다.

##### `collection.reload`

[`collection.reload`][] 메소드는 모든 연관된 객체의 Relation을 반환하며, 데이터베이스를 읽도록 강제합니다. 연관된 객체가 없는 경우 빈 Relation을 반환합니다.

```ruby
@books = author.books.reload
```

#### `has_many`에 대한 옵션

Rails는 대부분의 상황에서 잘 작동하는 지능적인 기본값을 사용하지만, `has_many` 연관 참조의 동작을 사용자 정의하고 싶을 때가 있을 수 있습니다. 이러한 사용자 정의는 연관을 생성할 때 옵션을 전달하여 쉽게 수행할 수 있습니다. 예를 들어, 다음과 같이 두 가지 옵션을 사용하는 연관을 사용하는 경우가 있습니다.

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :delete_all, validate: false
end
```

[`has_many`][] 연관은 다음과 같은 옵션을 지원합니다:

* `:as`
* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:validate`

##### `:as`

`:as` 옵션을 설정하면 이것이 다형 연관임을 나타냅니다. [이 가이드의 앞부분](#polymorphic-associations)에서 설명한 것과 같습니다.

##### `:autosave`

`:autosave` 옵션을 `true`로 설정하면, Rails는 로드된 연관 멤버를 저장하고, 삭제할 멤버를 삭제합니다. 부모 객체를 저장할 때마다 `:autosave`를 `false`로 설정하는 것은 `:autosave` 옵션을 설정하지 않는 것과 같지 않습니다. `:autosave` 옵션이 없는 경우, 새로운 연관된 객체는 저장되지만, 업데이트된 연관된 객체는 저장되지 않습니다.

##### `:class_name`

다른 모델의 이름을 연관 이름에서 유도할 수 없는 경우, `:class_name` 옵션을 사용하여 모델 이름을 제공할 수 있습니다. 예를 들어, 작가가 많은 책을 가지고 있지만, 책을 포함하는 실제 모델의 이름이 `Transaction`인 경우 다음과 같이 설정할 수 있습니다:

```ruby
class Author < ApplicationRecord
  has_many :books, class_name: "Transaction"
end
```
##### `:counter_cache`

이 옵션은 사용자 정의된 `:counter_cache`의 이름을 구성하는 데 사용될 수 있습니다. [belongs_to association](#options-for-belongs-to)에서 `:counter_cache`의 이름을 사용자 정의한 경우에만 이 옵션이 필요합니다.

##### `:dependent`

소유자가 삭제될 때 연관된 객체에 대해 어떤 작업이 수행되는지를 제어합니다:

* `:destroy`는 모든 연관된 객체가 삭제됩니다.
* `:delete_all`은 모든 연관된 객체가 데이터베이스에서 직접 삭제됩니다(따라서 콜백은 실행되지 않음).
* `:destroy_async`: 객체가 삭제되면 `ActiveRecord::DestroyAssociationAsyncJob` 작업이 예약되어 연관된 객체에 대해 destroy를 호출합니다. 이 작업을 수행하려면 Active Job이 설정되어 있어야 합니다.
* `:nullify`는 외래 키를 `NULL`로 설정합니다. 다형성 유형 열은 다형성 연관에서도 null로 설정됩니다. 콜백은 실행되지 않습니다.
* `:restrict_with_exception`은 연관된 레코드가 있는 경우 `ActiveRecord::DeleteRestrictionError` 예외가 발생합니다.
* `:restrict_with_error`는 연관된 객체가 있는 경우 오류가 소유자에 추가됩니다.

`:destroy` 및 `:delete_all` 옵션은 `collection.delete` 및 `collection=` 메서드의 의미도 변경하여 컬렉션에서 제거될 때 연관된 객체를 삭제합니다.

##### `:foreign_key`

관례적으로 Rails는 다른 모델에 대한 외래 키를 보유하는 데 사용되는 열의 이름이 이 모델의 이름에 `_id` 접미사가 추가된 것으로 가정합니다. `:foreign_key` 옵션을 사용하면 외래 키의 이름을 직접 설정할 수 있습니다:

```ruby
class Author < ApplicationRecord
  has_many :books, foreign_key: "cust_id"
end
```

TIP: Rails는 어떤 경우에도 외래 키 열을 자동으로 생성하지 않습니다. 마이그레이션의 일부로 명시적으로 정의해야 합니다.

##### `:inverse_of`

`:inverse_of` 옵션은 이 연관에 대한 역방향 `belongs_to` 연관의 이름을 지정합니다.
자세한 내용은 [양방향 연관](#bi-directional-associations) 섹션을 참조하십시오.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:primary_key`

관례적으로 Rails는 연관의 기본 키를 보유하는 데 사용되는 열이 `id`라고 가정합니다. `:primary_key` 옵션을 사용하여 기본 키를 명시적으로 지정할 수 있습니다.

`users` 테이블에는 `id`가 기본 키로 사용되지만 `guid` 열도 있습니다. 요구 사항은 `todos` 테이블이 `guid` 열 값을 외래 키로 보유하고 `id` 값이 아닌 경우입니다. 다음과 같이 이를 달성할 수 있습니다:

```ruby
class User < ApplicationRecord
  has_many :todos, primary_key: :guid
end
```

이제 `@todo = @user.todos.create`를 실행하면 `@todo` 레코드의 `user_id` 값은 `@user`의 `guid` 값이 됩니다.

##### `:source`

`:source` 옵션은 `has_many :through` 연관에 대한 소스 연관 이름을 지정합니다. 소스 연관 이름을 연관 이름에서 자동으로 추론할 수 없는 경우에만 이 옵션을 사용해야 합니다.

##### `:source_type`

`:source_type` 옵션은 다형성 연관을 통해 진행되는 `has_many :through` 연관에 대한 소스 연관 유형을 지정합니다.

```ruby
class Author < ApplicationRecord
  has_many :books
  has_many :paperbacks, through: :books, source: :format, source_type: "Paperback"
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Hardback < ApplicationRecord; end
class Paperback < ApplicationRecord; end
```

##### `:through`

`:through` 옵션은 쿼리를 수행하기 위해 사용할 조인 모델을 지정합니다. `has_many :through` 연관은 [이 가이드의 이전 섹션](#the-has-many-through-association)에서 설명한 것처럼 다대다 관계를 구현하는 방법을 제공합니다.

##### `:validate`

`:validate` 옵션을 `false`로 설정하면 이 객체를 저장할 때 새로운 연관된 객체가 유효성 검사되지 않습니다. 기본적으로 이 값은 `true`이며 이 객체를 저장할 때 새로운 연관된 객체가 유효성 검사됩니다.

#### `has_many`에 대한 스코프

`has_many`에서 사용되는 쿼리를 사용자 정의하려는 경우가 있을 수 있습니다. 이러한 사용자 정의는 스코프 블록을 통해 구현할 수 있습니다. 예를 들어:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { where processed: true }
end
```

스코프 블록 내에서 표준 [쿼리 메서드](active_record_querying.html) 중 하나를 사용할 수 있습니다. 다음은 아래에서 설명하는 몇 가지 메서드입니다:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

`where` 메서드를 사용하면 연관된 객체가 충족해야 하는 조건을 지정할 수 있습니다.

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where "confirmed = 1" },
    class_name: "Book"
end
```
해시를 통해 조건을 설정할 수도 있습니다:

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where confirmed: true },
    class_name: "Book"
end
```

해시 스타일의 `where` 옵션을 사용하면 이 연관 관계를 통해 레코드를 생성할 때 자동으로 해시를 사용하여 스코프가 지정됩니다. 이 경우 `author.confirmed_books.create` 또는 `author.confirmed_books.build`를 사용하면 confirmed 열의 값이 `true`인 책이 생성됩니다.

##### `extending`

`extending` 메소드는 연관 관계 프록시를 확장할 이름 있는 모듈을 지정합니다. 연관 관계 확장에 대해서는 [이 가이드의 나중에](#association-extensions) 자세히 설명됩니다.

##### `group`

`group` 메소드는 검색기 SQL에서 `GROUP BY` 절을 사용하여 결과 집합을 그룹화하기 위해 속성 이름을 제공합니다.

```ruby
class Author < ApplicationRecord
  has_many :chapters, -> { group 'books.id' },
                      through: :books
end
```

##### `includes`

`includes` 메소드를 사용하여 이 연관 관계가 사용될 때 함께 로드되어야 하는 2차 연관 관계를 지정할 수 있습니다. 예를 들어, 다음과 같은 모델을 고려해 보십시오:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

자주 작가로부터 직접 챕터를 검색하는 경우 (`author.books.chapters`), 작가에서 책으로의 연관 관계에 챕터를 포함하여 코드를 조금 더 효율적으로 만들 수 있습니다:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { includes :chapters }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

##### `limit`

`limit` 메소드를 사용하면 연관 관계를 통해 검색되는 객체의 총 수를 제한할 수 있습니다.

```ruby
class Author < ApplicationRecord
  has_many :recent_books,
    -> { order('published_at desc').limit(100) },
    class_name: "Book"
end
```

##### `offset`

`offset` 메소드를 사용하면 연관 관계를 통해 객체를 가져오는 시작 오프셋을 지정할 수 있습니다. 예를 들어, `-> { offset(11) }`는 처음 11개의 레코드를 건너뜁니다.

##### `order`

`order` 메소드는 연관된 객체가 받게 될 순서를 지정합니다(SQL `ORDER BY` 절에서 사용되는 구문).

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order "date_confirmed DESC" }
end
```

##### `readonly`

`readonly` 메소드를 사용하면 연관된 객체가 연관 관계를 통해 검색될 때 읽기 전용으로 설정됩니다.

##### `select`

`select` 메소드를 사용하면 연관된 객체에 대한 데이터를 검색하는 데 사용되는 SQL `SELECT` 절을 재정의할 수 있습니다. 기본적으로 Rails는 모든 열을 검색합니다.

경고: 직접 `select`를 지정하는 경우, 연관된 모델의 기본 키와 외래 키 열을 포함해야 합니다. 그렇지 않으면 Rails에서 오류가 발생합니다.

##### `distinct`

`distinct` 메소드를 사용하여 컬렉션에서 중복을 제거할 수 있습니다. 이는 주로 `:through` 옵션과 함께 사용됩니다.

```ruby
class Person < ApplicationRecord
  has_many :readings
  has_many :articles, through: :readings
end
```

```irb
irb> person = Person.create(name: 'John')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 5, name: "a1">, #<Article id: 5, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 12, person_id: 5, article_id: 5>, #<Reading id: 13, person_id: 5, article_id: 5>]
```

위의 경우 두 개의 readings가 있으며 `person.articles`는 같은 article을 가리키는 두 개의 readings를 모두 가져옵니다.

이제 `distinct`를 설정해 봅시다:

```ruby
class Person
  has_many :readings
  has_many :articles, -> { distinct }, through: :readings
end
```

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 7, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 16, person_id: 7, article_id: 7>, #<Reading id: 17, person_id: 7, article_id: 7>]
```

위의 경우에도 두 개의 readings가 있습니다. 그러나 `person.articles`는 컬렉션이 고유한 레코드만 로드하기 때문에 하나의 article만 표시됩니다.

만약 삽입 시에 영속한 연관 관계의 모든 레코드가 고유하도록(연관 관계를 검사할 때 중복 레코드를 발견하지 않을 수 있도록) 하려면 테이블 자체에 고유한 인덱스를 추가해야 합니다. 예를 들어, `readings`라는 테이블이 있고, article이 한 명의 사람에게만 추가될 수 있도록 하려면 다음과 같이 마이그레이션에 추가할 수 있습니다:

```ruby
add_index :readings, [:person_id, :article_id], unique: true
```
이 고유한 인덱스를 가지고 있을 때, 동일한 기사를 사람에게 두 번 추가하려고 하면 `ActiveRecord::RecordNotUnique` 오류가 발생합니다:

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
ActiveRecord::RecordNotUnique
```

`include?`와 같은 것을 사용하여 고유성을 확인하는 것은 경합 조건에 영향을 받습니다. 연관성에서 고유성을 강제하기 위해 `include?`를 사용하지 마십시오. 예를 들어, 위의 기사 예에서 다음 코드는 경합 조건이 발생할 수 있으므로 문제가 됩니다.

```ruby
person.articles << article unless person.articles.include?(article)
```

#### 객체가 언제 저장되는가?

`has_many` 연관을 할당할 때, 해당 객체는 자동으로 저장됩니다(외래 키를 업데이트하기 위해). 하나의 문장에서 여러 개의 객체를 할당하는 경우, 모두 저장됩니다.

이러한 저장 중 하나가 유효성 검사 오류로 인해 실패하면, 할당 문장은 `false`를 반환하고 할당 자체가 취소됩니다.

부모 객체(`has_many` 연관을 선언하는 객체)가 저장되지 않은 경우(즉, `new_record?`가 `true`를 반환하는 경우), 추가될 때 자식 객체는 저장되지 않습니다. 부모가 저장될 때 연관의 모든 저장되지 않은 멤버가 자동으로 저장됩니다.

객체를 저장하지 않고 `has_many` 연관에 객체를 할당하려면 `collection.build` 메서드를 사용하십시오.

### `has_and_belongs_to_many` 연관 참조

`has_and_belongs_to_many` 연관은 다른 모델과의 다대다 관계를 생성합니다. 데이터베이스 용어로는 두 클래스를 중간 조인 테이블을 통해 연결하며, 각 클래스를 참조하는 외래 키를 포함합니다.

#### `has_and_belongs_to_many`에 의해 추가된 메서드

`has_and_belongs_to_many` 연관을 선언하면, 선언하는 클래스에는 연관된 메서드와 관련된 여러 메서드가 자동으로 추가됩니다:

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

이러한 모든 메서드에서 `collection`은 `has_and_belongs_to_many`에 전달된 첫 번째 인수로 대체되고, `collection_singular`은 해당 심볼의 단수형 버전으로 대체됩니다. 예를 들어, 다음 선언이 주어진 경우:

```ruby
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

`Part` 모델의 각 인스턴스에는 다음과 같은 메서드가 있습니다:

```ruby
assemblies
assemblies<<(object, ...)
assemblies.delete(object, ...)
assemblies.destroy(object, ...)
assemblies=(objects)
assembly_ids
assembly_ids=(ids)
assemblies.clear
assemblies.empty?
assemblies.size
assemblies.find(...)
assemblies.where(...)
assemblies.exists?(...)
assemblies.build(attributes = {}, ...)
assemblies.create(attributes = {})
assemblies.create!(attributes = {})
assemblies.reload
```

##### 추가 열 메서드

`has_and_belongs_to_many` 연관의 조인 테이블에 두 외래 키 이외의 추가 열이 있는 경우, 이러한 열은 해당 연관을 통해 검색된 레코드에 속성으로 추가됩니다. 추가 속성이 있는 레코드는 항상 읽기 전용이며, Rails는 해당 속성에 대한 변경 사항을 저장할 수 없기 때문입니다.

경고: `has_and_belongs_to_many` 연관에서 조인 테이블의 추가 속성 사용은 사용이 중단되었습니다. 다대다 관계에서 두 모델을 조인하는 테이블에서 이러한 복잡한 동작이 필요한 경우, `has_and_belongs_to_many` 대신 `has_many :through` 연관을 사용해야 합니다.

##### `collection`

`collection` 메서드는 연관된 모든 객체의 Relation을 반환합니다. 연관된 객체가 없는 경우, 빈 Relation을 반환합니다.

```ruby
@assemblies = @part.assemblies
```

##### `collection<<(object, ...)`

[`collection<<`][] 메서드는 하나 이상의 객체를 컬렉션에 추가하여 조인 테이블에 레코드를 생성합니다.

```ruby
@part.assemblies << @assembly1
```

참고: 이 메서드는 `collection.concat` 및 `collection.push`로 별칭이 지정되어 있습니다.

##### `collection.delete(object, ...)`

[`collection.delete`][] 메서드는 하나 이상의 객체를 컬렉션에서 제거하여 조인 테이블에서 레코드를 삭제합니다. 이는 객체를 삭제하지 않습니다.

```ruby
@part.assemblies.delete(@assembly1)
```

##### `collection.destroy(object, ...)`

[`collection.destroy`][] 메서드는 하나 이상의 객체를 컬렉션에서 제거하여 조인 테이블에서 레코드를 삭제합니다. 이는 객체를 삭제하지 않습니다.

```ruby
@part.assemblies.destroy(@assembly1)
```

##### `collection=(objects)`

`collection=` 메서드는 컬렉션을 제공된 객체만 포함하도록 만들어 추가 및 삭제를 적절하게 수행합니다. 변경 사항은 데이터베이스에 유지됩니다.

##### `collection_singular_ids`

`collection_singular_ids` 메서드는 컬렉션의 객체의 id 배열을 반환합니다.

```ruby
@assembly_ids = @part.assembly_ids
```

##### `collection_singular_ids=(ids)`

`collection_singular_ids=` 메서드는 컬렉션을 제공된 기본 키 값으로 식별된 객체만 포함하도록 만들어 추가 및 삭제를 적절하게 수행합니다. 변경 사항은 데이터베이스에 유지됩니다.
##### `collection.clear`

[`collection.clear`][] 메서드는 조인 테이블에서 행을 삭제하여 컬렉션에서 모든 객체를 제거합니다. 이는 연관된 객체를 파괴하지 않습니다.

##### `collection.empty?`

[`collection.empty?`][] 메서드는 컬렉션이 연관된 객체를 포함하지 않으면 `true`를 반환합니다.

```html+erb
<% if @part.assemblies.empty? %>
  이 부품은 어셈블리에 사용되지 않습니다.
<% end %>
```

##### `collection.size`

[`collection.size`][] 메서드는 컬렉션에 있는 객체의 수를 반환합니다.

```ruby
@assembly_count = @part.assemblies.size
```

##### `collection.find(...)`

[`collection.find`][] 메서드는 컬렉션의 테이블에서 객체를 찾습니다.

```ruby
@assembly = @part.assemblies.find(1)
```

##### `collection.where(...)`

[`collection.where`][] 메서드는 제공된 조건에 따라 컬렉션 내에서 객체를 찾지만, 객체는 게으르게 로드되므로 객체에 액세스할 때만 데이터베이스가 쿼리됩니다.

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

##### `collection.exists?(...)`

[`collection.exists?`][] 메서드는 컬렉션의 테이블에서 제공된 조건을 충족하는 객체가 있는지 확인합니다.

##### `collection.build(attributes = {})`

[`collection.build`][] 메서드는 연관된 유형의 새로운 객체를 반환합니다. 이 객체는 전달된 속성에서 인스턴스화되며, 조인 테이블을 통한 링크가 생성되지만 연관된 객체는 아직 저장되지 않습니다.

```ruby
@assembly = @part.assemblies.build({ assembly_name: "Transmission housing" })
```

##### `collection.create(attributes = {})`

[`collection.create`][] 메서드는 연관된 유형의 새로운 객체를 반환합니다. 이 객체는 전달된 속성에서 인스턴스화되며, 조인 테이블을 통한 링크가 생성되며, 연관된 객체가 연관 모델에서 지정된 모든 유효성 검사를 통과하면 연관된 객체가 저장됩니다.

```ruby
@assembly = @part.assemblies.create({ assembly_name: "Transmission housing" })
```

##### `collection.create!(attributes = {})`

`collection.create`와 동일하지만 레코드가 유효하지 않은 경우 `ActiveRecord::RecordInvalid`를 발생시킵니다.

##### `collection.reload`

[`collection.reload`][] 메서드는 모든 연관된 객체의 관계를 반환하며, 데이터베이스를 읽도록 강제합니다. 연관된 객체가 없는 경우 빈 관계를 반환합니다.

```ruby
@assemblies = @part.assemblies.reload
```

#### `has_and_belongs_to_many`에 대한 옵션

Rails는 대부분의 상황에서 잘 작동하는 지능적인 기본값을 사용하지만, `has_and_belongs_to_many` 연관 참조의 동작을 사용자 정의하고자 할 때가 있을 수 있습니다. 이러한 사용자 정의는 연관을 생성할 때 옵션을 전달하여 쉽게 수행할 수 있습니다. 예를 들어, 다음 연관은 두 가지 옵션을 사용합니다:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { readonly },
                                       autosave: true
end
```

[`has_and_belongs_to_many`][] 연관은 다음 옵션을 지원합니다:

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
* `:validate`

##### `:association_foreign_key`

Rails는 일반적으로 다른 모델을 가리키는 외래 키를 보유하기 위해 조인 테이블에서 사용되는 열이 해당 모델의 이름에 `_id` 접미사가 추가된 것으로 가정합니다. `:association_foreign_key` 옵션을 사용하여 외래 키의 이름을 직접 설정할 수 있습니다:

TIP: `:foreign_key` 및 `:association_foreign_key` 옵션은 다대다 자체 조인을 설정할 때 유용합니다. 예를 들어:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:autosave`

`:autosave` 옵션을 `true`로 설정하면, Rails는 로드된 연관 멤버를 저장하고 삭제할 멤버를 저장할 때마다 부모 객체를 저장합니다. `:autosave`를 `false`로 설정하는 것은 `:autosave` 옵션을 설정하지 않는 것과 같지 않습니다. `:autosave` 옵션이 없으면 새로운 연관된 객체가 저장되지만, 업데이트된 연관된 객체는 저장되지 않습니다.

##### `:class_name`

다른 모델의 이름을 연관 이름에서 유도할 수 없는 경우, `:class_name` 옵션을 사용하여 모델 이름을 제공할 수 있습니다. 예를 들어, 부품에는 많은 어셈블리가 있지만, 어셈블리를 포함하는 실제 모델의 이름이 `Gadget`인 경우 다음과 같이 설정할 수 있습니다:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```

##### `:foreign_key`

Rails는 일반적으로 이 모델을 가리키는 외래 키를 보유하기 위해 조인 테이블에서 사용되는 열이 이 모델의 이름에 `_id` 접미사가 추가된 것으로 가정합니다. `:foreign_key` 옵션을 사용하여 외래 키의 이름을 직접 설정할 수 있습니다:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:join_table`

렉시컬 순서에 따라 기본 조인 테이블의 이름이 원하는 것이 아닌 경우, `:join_table` 옵션을 사용하여 기본값을 재정의할 수 있습니다.
##### `:validate`

`validate` 옵션을 `false`로 설정하면, 이 객체를 저장할 때 새로운 연관된 객체들은 유효성 검사를 받지 않습니다. 기본적으로 이 값은 `true`로 설정되어 있어, 이 객체를 저장할 때 새로운 연관된 객체들은 유효성 검사를 받습니다.

#### `has_and_belongs_to_many`를 위한 스코프

`has_and_belongs_to_many`를 사용할 때 사용되는 쿼리를 사용자 정의하고 싶을 때가 있을 수 있습니다. 이러한 사용자 정의는 스코프 블록을 통해 구현할 수 있습니다. 예를 들어:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

스코프 블록 내에서 표준 [쿼리 메서드](active_record_querying.html)를 사용할 수 있습니다. 아래에서는 다음과 같은 메서드들에 대해 설명합니다:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

`where` 메서드를 사용하면 연관된 객체가 충족해야 하는 조건을 지정할 수 있습니다.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

해시를 사용하여 조건을 설정할 수도 있습니다:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

해시 스타일의 `where`를 사용하면, 이 연관 관계를 통해 레코드를 생성할 때 자동으로 해당 해시를 사용하여 스코프가 지정됩니다. 이 경우, `@parts.assemblies.create` 또는 `@parts.assemblies.build`를 사용하면 `factory` 열의 값이 "Seattle"인 어셈블리가 생성됩니다.

##### `extending`

`extending` 메서드는 연관 관계 프록시를 확장할 이름 있는 모듈을 지정합니다. 연관 관계 확장에 대해서는 [이 가이드의 뒷부분](#association-extensions)에서 자세히 설명합니다.

##### `group`

`group` 메서드는 `GROUP BY` 절을 사용하여 결과 집합을 속성 이름으로 그룹화합니다.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```

##### `includes`

`includes` 메서드를 사용하여 이 연관 관계를 사용할 때 eager 로딩되어야 하는 2차 연관 관계를 지정할 수 있습니다.

##### `limit`

`limit` 메서드를 사용하면 연관 관계를 통해 검색되는 객체의 총 개수를 제한할 수 있습니다.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```

##### `offset`

`offset` 메서드를 사용하면 연관 관계를 통해 객체를 검색할 때 시작 오프셋을 지정할 수 있습니다. 예를 들어, `offset(11)`을 설정하면 처음 11개의 레코드를 건너뜁니다.

##### `order`

`order` 메서드는 연관된 객체가 받는 순서를 지정합니다 (SQL `ORDER BY` 절에서 사용되는 구문을 사용합니다).

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```

##### `readonly`

`readonly` 메서드를 사용하면 연관된 객체를 검색할 때 해당 객체들은 읽기 전용으로 설정됩니다.

##### `select`

`select` 메서드를 사용하면 연관된 객체에 대한 데이터를 검색하는 데 사용되는 SQL `SELECT` 절을 재정의할 수 있습니다. 기본적으로 Rails는 모든 열을 검색합니다.

##### `distinct`

`distinct` 메서드를 사용하여 컬렉션에서 중복을 제거할 수 있습니다.

#### 객체는 언제 저장되나요?

`has_and_belongs_to_many` 연관 관계에 객체를 할당하면, 해당 객체는 자동으로 저장됩니다 (조인 테이블을 업데이트하기 위해). 하나의 문장에서 여러 개의 객체를 할당하면, 모두 저장됩니다.

이러한 저장 중 하나라도 유효성 검사 오류로 인해 실패하면, 할당 문장은 `false`를 반환하고 할당 자체가 취소됩니다.

부모 객체(`has_and_belongs_to_many` 연관 관계를 선언하는 객체)가 저장되지 않은 경우 (즉, `new_record?`가 `true`를 반환하는 경우), 추가될 때 자식 객체는 저장되지 않습니다. 연관 관계의 저장되지 않은 모든 멤버는 부모가 저장될 때 자동으로 저장됩니다.

객체를 `has_and_belongs_to_many` 연관 관계에 할당하고 해당 객체를 저장하지 않으려면 `collection.build` 메서드를 사용하세요.

### 연관 관계 콜백

일반적인 콜백은 Active Record 객체의 라이프 사이클에 훅을 걸어, 해당 객체를 다양한 시점에서 작업할 수 있도록 합니다. 예를 들어, `:before_save` 콜백을 사용하여 객체가 저장되기 직전에 어떤 작업을 수행할 수 있습니다.

연관 관계 콜백은 일반적인 콜백과 유사하지만, 컬렉션의 라이프 사이클 이벤트에 의해 트리거됩니다. 사용 가능한 연관 관계 콜백은 다음과 같이 4개가 있습니다:

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

연관 관계 콜백은 연관 관계 선언에 옵션을 추가하여 정의할 수 있습니다. 예를 들어:

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_credit_limit

  def check_credit_limit(book)
    # ...
  end
end
```

Rails는 콜백에 추가되거나 제거되는 객체를 콜백에 전달합니다.
하나의 이벤트에 대해 콜백을 배열로 전달하여 쌓을 수 있습니다.

```ruby
class Author < ApplicationRecord
  has_many :books,
    before_add: [:check_credit_limit, :calculate_shipping_charges]

  def check_credit_limit(book)
    # ...
  end

  def calculate_shipping_charges(book)
    # ...
  end
end
```

`before_add` 콜백이 `:abort`를 던지면 객체가 컬렉션에 추가되지 않습니다. 마찬가지로, `before_remove` 콜백이 `:abort`를 던지면 객체가 컬렉션에서 제거되지 않습니다.

```ruby
# 한도에 도달하면 책이 추가되지 않습니다.
def check_credit_limit(book)
  throw(:abort) if limit_reached?
end
```

참고: 이러한 콜백은 연관된 객체가 연관 컬렉션을 통해 추가되거나 제거될 때만 호출됩니다.

```ruby
# `before_add` 콜백이 트리거됩니다.
author.books << book
author.books = [book, book2]

# `before_add` 콜백이 트리거되지 않습니다.
book.update(author_id: 1)
```

### 연관 확장

Rails가 자동으로 연관 프록시 객체에 빌드하는 기능에 제한되지 않습니다. 익명 모듈을 통해 이러한 객체를 확장하여 새로운 검색기, 생성기 또는 기타 메서드를 추가할 수도 있습니다. 예를 들어:

```ruby
class Author < ApplicationRecord
  has_many :books do
    def find_by_book_prefix(book_number)
      find_by(category_id: book_number[0..2])
    end
  end
end
```

여러 연관에서 공유해야하는 확장이 있는 경우 이름이 지정된 확장 모듈을 사용할 수 있습니다. 예를 들어:

```ruby
module FindRecentExtension
  def find_recent
    where("created_at > ?", 5.days.ago)
  end
end

class Author < ApplicationRecord
  has_many :books, -> { extending FindRecentExtension }
end

class Supplier < ApplicationRecord
  has_many :deliveries, -> { extending FindRecentExtension }
end
```

확장은 `proxy_association` 접근자의 이 세 가지 속성을 사용하여 연관 프록시의 내부를 참조할 수 있습니다.

* `proxy_association.owner`는 연관이 일부인 객체를 반환합니다.
* `proxy_association.reflection`은 연관을 설명하는 reflection 객체를 반환합니다.
* `proxy_association.target`은 `belongs_to` 또는 `has_one`의 연관 객체 또는 `has_many` 또는 `has_and_belongs_to_many`의 연관 객체 컬렉션을 반환합니다.

### 연관 소유자를 사용한 연관 범위 지정

연관의 소유자는 연관 범위에 대해 더 많은 제어를 필요로하는 경우 범위 블록에 단일 인수로 전달될 수 있습니다. 그러나 주의할 점으로는 연관을 사전로드(preload)하는 것이 더 이상 불가능해집니다.

```ruby
class Supplier < ApplicationRecord
  has_one :account, ->(supplier) { where active: supplier.active? }
end
```

단일 테이블 상속 (STI)
------------------------------

가끔은 다른 모델 간에 필드와 동작을 공유하고 싶을 수 있습니다. 예를 들어 Car, Motorcycle 및 Bicycle 모델이 있다고 가정해보겠습니다. 우리는 `color` 및 `price` 필드와 일부 메서드를 모두 공유하고 싶지만, 각각에 대해 특정 동작 및 분리된 컨트롤러를 가지고 싶습니다.

먼저, 기본 Vehicle 모델을 생성해 보겠습니다:

```bash
$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}
```

"타입" 필드를 추가하고 있는 것을 알아보셨나요? 모든 모델이 단일 데이터베이스 테이블에 저장되기 때문에 Rails는 이 열에 저장되는 모델의 이름을 저장합니다. 예를 들어 "Car", "Motorcycle" 또는 "Bicycle"가 될 수 있습니다. STI는 테이블에 "타입" 필드가 없으면 작동하지 않습니다.

다음으로, Vehicle에서 상속하는 Car 모델을 생성해 보겠습니다. 이를 위해 `--parent=PARENT` 옵션을 사용할 수 있습니다. 이 옵션은 지정된 부모에서 상속하는 모델을 생성하고 해당하는 마이그레이션은 생성하지 않습니다(테이블이 이미 존재하기 때문에).

예를 들어, Car 모델을 생성하려면:

```bash
$ bin/rails generate model car --parent=Vehicle
```

생성된 모델은 다음과 같이 보일 것입니다:

```ruby
class Car < Vehicle
end
```

이는 Vehicle에 추가된 모든 동작이 Car에서도 사용할 수 있다는 것을 의미합니다. 연관, 공개 메서드 등이 포함됩니다.

차를 생성하면 "타입" 필드로 "Car"가 포함된 `vehicles` 테이블에 저장됩니다:

```ruby
Car.create(color: 'Red', price: 10000)
```

다음과 같은 SQL을 생성합니다:

```sql
INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

Car 레코드를 쿼리하면 차만 검색됩니다:

```ruby
Car.all
```

다음과 같은 쿼리가 실행됩니다:

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```

위임된 유형
----------------

[`단일 테이블 상속 (STI)`](#single-table-inheritance-sti)는 하위 클래스와 해당 속성 간에 차이가 거의 없을 때 가장 잘 작동하지만, 하나의 테이블을 만들기 위해 모든 하위 클래스의 모든 속성을 포함해야 합니다.

이 접근 방식의 단점은 테이블에 불필요한 데이터가 포함되어 있다는 것입니다. 다른 것에서 사용되지 않는 하위 클래스에 특정한 속성도 포함됩니다.

다음 예제에서는 동일한 "Entry" 클래스에서 상속하는 두 개의 Active Record 모델이 있습니다. 이 클래스에는 `subject` 속성이 포함되어 있습니다.
```ruby
# 스키마: entries[ id, type, subject, created_at, updated_at]
class Entry < ApplicationRecord
end

class Comment < Entry
end

class Message < Entry
end
```

위임된 타입은 `delegated_type`를 통해 이 문제를 해결합니다.

위임된 타입을 사용하려면 데이터를 특정한 방식으로 모델링해야 합니다. 요구 사항은 다음과 같습니다:

* 모든 하위 클래스 간에 공유된 속성을 슈퍼 클래스에 저장하는 슈퍼 클래스가 있어야 합니다.
* 각 하위 클래스는 슈퍼 클래스를 상속받아 해당 클래스에 특정한 추가 속성을 위한 별도의 테이블을 가져야 합니다.

이렇게 하면 의도하지 않게 모든 하위 클래스 간에 공유되는 단일 테이블에서 속성을 정의할 필요가 없어집니다.

위의 예제에 이를 적용하기 위해 모델을 다시 생성해야 합니다.
먼저, 슈퍼 클래스로 작동할 기본 `Entry` 모델을 생성해 봅시다:

```bash
$ bin/rails generate model entry entryable_type:string entryable_id:integer
```

그런 다음 위임을 위해 새로운 `Message`와 `Comment` 모델을 생성합니다:

```bash
$ bin/rails generate model message subject:string body:string
$ bin/rails generate model comment content:string
```

생성기를 실행한 후에는 다음과 같은 모델이 생성됩니다:

```ruby
# 스키마: entries[ id, entryable_type, entryable_id, created_at, updated_at ]
class Entry < ApplicationRecord
end

# 스키마: messages[ id, subject, body, created_at, updated_at ]
class Message < ApplicationRecord
end

# 스키마: comments[ id, content, created_at, updated_at ]
class Comment < ApplicationRecord
end
```

### `delegated_type` 선언

먼저, 슈퍼 클래스 `Entry`에서 `delegated_type`을 선언합니다.

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
end
```

`entryable` 매개변수는 위임에 사용할 필드를 지정하고, `Message`와 `Comment`를 대리 클래스로 포함합니다.

`Entry` 클래스에는 `entryable_type`과 `entryable_id` 필드가 있습니다. 이는 `delegated_type` 정의에서 `entryable` 이름에 `_type`, `_id` 접미사가 추가된 필드입니다.
`entryable_type`은 대리자의 하위 클래스 이름을 저장하고, `entryable_id`는 대리자 하위 클래스의 레코드 ID를 저장합니다.

다음으로, `has_one` 연관 관계에 `as: :entryable` 매개변수를 선언하여 위임된 타입을 구현하는 모듈을 정의해야 합니다.

```ruby
module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

그런 다음 생성한 모듈을 하위 클래스에 포함시킵니다.

```ruby
class Message < ApplicationRecord
  include Entryable
end

class Comment < ApplicationRecord
  include Entryable
end
```

이 정의가 완료되면, `Entry` 위임자는 다음과 같은 메서드를 제공합니다:

| 메서드 | 반환값 |
|---|---|
| `Entry#entryable_class` | Message 또는 Comment |
| `Entry#entryable_name` | "message" 또는 "comment" |
| `Entry.messages` | `Entry.where(entryable_type: "Message")` |
| `Entry#message?` | `entryable_type == "Message"`인 경우 true를 반환합니다. |
| `Entry#message` | `entryable_type == "Message"`인 경우 메시지 레코드를 반환하고, 그렇지 않으면 `nil`을 반환합니다. |
| `Entry#message_id` | `entryable_type == "Message"`인 경우 `entryable_id`를 반환하고, 그렇지 않으면 `nil`을 반환합니다. |
| `Entry.comments` | `Entry.where(entryable_type: "Comment")` |
| `Entry#comment?` | `entryable_type == "Comment"`인 경우 true를 반환합니다. |
| `Entry#comment` | `entryable_type == "Comment"`인 경우 코멘트 레코드를 반환하고, 그렇지 않으면 `nil`을 반환합니다. |
| `Entry#comment_id` | `entryable_type == "Comment"`인 경우 `entryable_id`를 반환하고, 그렇지 않으면 `nil`을 반환합니다. |

### 객체 생성

새로운 `Entry` 객체를 생성할 때, 동시에 `entryable` 하위 클래스를 지정할 수 있습니다.

```ruby
Entry.create! entryable: Message.new(subject: "hello!")
```

### 추가 위임 추가

`Entry` 위임자를 확장하고 `delegates`를 정의하여 하위 클래스에 다형성을 사용하여 더욱 향상시킬 수 있습니다.
예를 들어, `Entry`에서 `title` 메서드를 하위 클래스로 위임하려면 다음과 같이 할 수 있습니다:

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ]
  delegates :title, to: :entryable
end

class Message < ApplicationRecord
  include Entryable

  def title
    subject
  end
end

class Comment < ApplicationRecord
  include Entryable

  def title
    content.truncate(20)
  end
end
```

[`belongs_to`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
[`has_and_belongs_to_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_and_belongs_to_many
[`has_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many
[`has_one`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one
[connection.add_reference]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[foreign_keys]: active_record_migrations.html#foreign-keys
[`config.active_record.automatic_scope_inversing`]: configuring.html#config-active-record-automatic-scope-inversing
[`reset_counters`]: https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-reset_counters
[`collection<<`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-3C-3C
[`collection.build`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-build
[`collection.clear`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-clear
[`collection.create`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create
[`collection.create!`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create-21
[`collection.delete`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-delete
[`collection.destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-destroy
[`collection.empty?`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-empty-3F
[`collection.exists?`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F
[`collection.find`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-find
[`collection.reload`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-reload
[`collection.size`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-size
[`collection.where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
