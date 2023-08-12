**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 311d5225fa32d069369256501f31c507
Active Record Migrations
========================

마이그레이션은 Active Record의 기능으로, 데이터베이스 스키마를 시간이 지남에 따라 진화시킬 수 있게 해줍니다. 순수한 SQL로 스키마 수정을 작성하는 대신, 마이그레이션은 Ruby DSL을 사용하여 테이블에 대한 변경 사항을 설명할 수 있습니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* 생성에 사용할 수 있는 생성기(generator).
* 데이터베이스를 조작하는 데 사용할 수 있는 Active Record의 메서드.
* 마이그레이션 및 스키마를 조작하는 레일스 명령어.
* 마이그레이션과 `schema.rb`의 관계.

--------------------------------------------------------------------------------

마이그레이션 개요
------------------

마이그레이션은 일관된 방식으로 데이터베이스 스키마를 시간에 따라 변경하는 편리한 방법입니다. 이를 위해 Ruby DSL을 사용하여 SQL을 직접 작성할 필요가 없으므로 스키마와 변경 사항이 데이터베이스에 독립적으로 유지될 수 있습니다.

각 마이그레이션을 데이터베이스의 새로운 '버전'으로 생각할 수 있습니다. 스키마는 아무 것도 없는 상태로 시작되며, 각 마이그레이션은 테이블, 열 또는 항목을 추가하거나 제거하여 스키마를 수정합니다. Active Record는 이 타임라인을 따라 스키마를 업데이트하는 방법을 알고 있으며, 현재 버전의 최신 버전으로 가져옵니다. Active Record는 또한 `db/schema.rb` 파일을 업데이트하여 데이터베이스의 최신 구조와 일치시킵니다.

다음은 마이그레이션의 예입니다:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

이 마이그레이션은 `products`라는 테이블을 추가하고, `name`이라는 문자열 열과 `description`이라는 텍스트 열을 추가합니다. `id`라는 기본 키 열도 암시적으로 추가됩니다. 이는 모든 Active Record 모델의 기본 키이기 때문입니다. `timestamps` 매크로는 `created_at`과 `updated_at` 두 개의 열을 추가합니다. 이 특별한 열은 Active Record에 의해 자동으로 관리됩니다.

우리는 앞으로 어떤 변경 사항이 발생할 것인지를 정의합니다. 이 마이그레이션이 실행되기 전에는 테이블이 없을 것입니다. 실행 후에는 테이블이 존재할 것입니다. Active Record는 이 마이그레이션을 반대로 실행하는 방법도 알고 있습니다. 이 마이그레이션을 롤백하면 테이블이 제거됩니다.

스키마를 변경하는 문장을 지원하는 트랜잭션을 지원하는 데이터베이스에서는 각 마이그레이션은 트랜잭션으로 래핑됩니다. 데이터베이스가 이를 지원하지 않는 경우 마이그레이션이 실패하면 성공한 부분은 롤백되지 않습니다. 수동으로 변경 사항을 롤백해야 합니다.

참고: 트랜잭션 내에서 실행할 수 없는 특정 쿼리가 있습니다. 어댑터가 DDL 트랜잭션을 지원하는 경우 단일 마이그레이션에 대해 `disable_ddl_transaction!`을 사용하여 트랜잭션을 비활성화할 수 있습니다.

### 되돌릴 수 없는 작업 가능하게 만들기

Active Record가 되돌릴 수 없는 작업을 수행하도록 마이그레이션을 원하는 경우 `reversible`를 사용할 수 있습니다:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      change_table :products do |t|
        direction.up   { t.change :price, :string }
        direction.down { t.change :price, :integer }
      end
    end
  end
end
```

이 마이그레이션은 `price` 열의 유형을 문자열로 변경하거나 마이그레이션을 되돌릴 때 정수로 변경합니다. `direction.up` 및 `direction.down`에 전달되는 블록에 주목하세요.

대신 `change` 대신 `up` 및 `down`을 사용할 수도 있습니다:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def up
    change_table :products do |t|
      t.change :price, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :price, :integer
    end
  end
end
```

INFO: [`reversible`](#using-reversible)에 대한 자세한 내용은 나중에 설명합니다.

마이그레이션 생성
----------------------

### 독립적인 마이그레이션 생성

마이그레이션은 `db/migrate` 디렉토리에 파일로 저장되며, 각 마이그레이션 클래스마다 하나의 파일이 있습니다. 파일의 이름은 `YYYYMMDDHHMMSS_create_products.rb` 형식입니다. 즉, UTC 타임스탬프가 마이그레이션을 식별하고 밑줄 다음에 마이그레이션의 이름이 옵니다. 마이그레이션 클래스의 이름(CamelCased 버전)은 파일 이름의 후반부와 일치해야 합니다. 예를 들어 `20080906120000_create_products.rb`는 `CreateProducts` 클래스를 정의해야 하며, `20080906120001_add_details_to_products.rb`는 `AddDetailsToProducts`를 정의해야 합니다. 레일스는 이 타임스탬프를 사용하여 어떤 순서로 마이그레이션이 실행되어야 하는지 결정하므로 다른 애플리케이션에서 마이그레이션을 복사하거나 직접 파일을 생성할 때 순서를 고려해야 합니다.

물론 타임스탬프를 계산하는 것은 재미있지 않으므로 Active Record는 이를 대신 처리하는 생성기를 제공합니다:

```bash
$ bin/rails generate migration AddPartNumberToProducts
```

이렇게 하면 적절한 이름의 빈 마이그레이션을 생성합니다.

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
  end
end
```

이 생성기는 파일 이름에 타임스탬프를 추가하는 것보다 더 많은 작업을 수행할 수 있습니다.
네이밍 규칙과 추가 (선택적) 인수에 따라 마이그레이션을 작성할 수도 있습니다.

### 새로운 열 추가

마이그레이션 이름이 "AddColumnToTable" 또는 "RemoveColumnFromTable" 형식이고
열 이름과 유형 목록이 뒤따르는 경우 [`add_column`][] 및
[`remove_column`][] 문이 포함된 마이그레이션이 생성됩니다.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

다음과 같은 마이그레이션을 생성합니다.

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
  end
end
```

새 열에 인덱스를 추가하려면 다음과 같이 할 수도 있습니다.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

다음과 같은 [`add_column`][] 및 [`add_index`][] 문이 생성됩니다.

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

하나의 마법처럼 생성된 열에 제한이 없습니다. 예를 들어:

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

`products` 테이블에 두 개의 추가 열을 추가하는 스키마 마이그레이션을 생성합니다.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

### 열 제거

마찬가지로, 명령줄에서 열을 제거하는 마이그레이션을 생성할 수도 있습니다.

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

다음과 같은 [`remove_column`][] 문이 생성됩니다.

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :part_number, :string
  end
end
```

### 새로운 테이블 생성

마이그레이션 이름이 "CreateXXX" 형식이고
열 이름과 유형 목록이 뒤따르는 경우 해당 열을 포함하는 테이블 XXX를 생성하는 마이그레이션이 생성됩니다. 예를 들어:

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```

다음과 같은 마이그레이션을 생성합니다.

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :part_number

      t.timestamps
    end
  end
end
```

항상 생성된 것은 시작점일 뿐입니다.
`db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb` 파일을 편집하여 필요한 대로 추가하거나 제거할 수 있습니다.

### 참조를 사용하여 연관 관계 생성

또한 생성기는 열 유형으로 `references` (또는 `belongs_to`로도 사용 가능)를 허용합니다. 예를 들어,

```bash
$ bin/rails generate migration AddUserRefToProducts user:references
```

다음과 같은 [`add_reference`][] 호출을 생성합니다.

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

이 마이그레이션은 `user_id` 열을 생성합니다. [참조](#references)는
열, 인덱스, 외래 키 또는 다형성 연관 관계 열을 생성하는 축약형입니다.

또한 `JoinTable`이 이름에 포함되어 있으면 조인 테이블을 생성하는 생성기도 있습니다.

```bash
$ bin/rails generate migration CreateJoinTableCustomerProduct customer product
```

다음과 같은 마이그레이션을 생성합니다.

```ruby
class CreateJoinTableCustomerProduct < ActiveRecord::Migration[7.1]
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
    end
  end
end
```


### 모델 생성기

모델, 리소스 및 스캐폴드 생성기는 새로운 모델을 추가하는 데 적합한 마이그레이션을 생성합니다.
이 마이그레이션은 이미 관련 테이블을 생성하는 지침을 포함하고 있습니다. 원하는 열을 Rails에 알려주면
해당 열을 추가하는 문도 생성됩니다. 예를 들어 다음을 실행하면:

```bash
$ bin/rails generate model Product name:string description:text
```

다음과 같은 마이그레이션을 생성합니다.

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

원하는 만큼 많은 열 이름/유형 쌍을 추가할 수 있습니다.

### 수정자 전달

일부 자주 사용되는 [유형 수정자](#column-modifiers)는 명령줄에서 직접 전달할 수 있습니다. 중괄호로 묶여 있으며 필드 유형 뒤에 따라옵니다.

예를 들어 다음을 실행하면:

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

다음과 같은 마이그레이션을 생성합니다.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

TIP: 생성기 도움말 출력 (`bin/rails generate --help`)을 참조하여
자세한 내용을 확인하세요.

마이그레이션 작성
------------------

생성기 중 하나를 사용하여 마이그레이션을 생성한 후 작업을 시작할 시간입니다!

### 테이블 생성

[`create_table`][] 메서드는 가장 기본적인 메서드 중 하나이지만 대부분의 경우
모델, 리소스 또는 스캐폴드 생성기를 사용하여 생성됩니다. 일반적인 사용법은 다음과 같습니다.
```ruby
create_table :products do |t|
  t.string :name
end
```

이 메소드는 `name`이라는 열을 가진 `products` 테이블을 생성합니다.

기본적으로 `create_table`은 암묵적으로 `id`라는 기본 키를 생성합니다. `:primary_key` 옵션을 사용하여 열의 이름을 변경하거나, 전혀 기본 키를 사용하지 않으려면 `id: false` 옵션을 전달할 수 있습니다.

데이터베이스 특정 옵션을 전달해야 하는 경우 `:options` 옵션에 SQL 조각을 넣을 수 있습니다. 예를 들어:

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

이렇게 하면 테이블을 생성하는 데 사용되는 SQL 문에 `ENGINE=BLACKHOLE`이 추가됩니다.

`create_table` 블록 내에서 생성된 열에 대해 인덱스를 생성하려면 `index: true` 또는 옵션 해시를 `:index` 옵션에 전달하면 됩니다.

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

또한, `:comment` 옵션을 사용하여 데이터베이스 자체에 저장되고 MySQL Workbench나 PgAdmin III와 같은 데이터베이스 관리 도구로 볼 수 있는 테이블에 대한 설명을 추가할 수 있습니다. 대규모 데이터베이스를 사용하는 애플리케이션의 마이그레이션에서는 데이터 모델을 이해하고 문서를 생성하는 데 도움이 되므로 주석을 지정하는 것이 좋습니다. 현재 MySQL과 PostgreSQL 어댑터만 주석을 지원합니다.


### 조인 테이블 생성

마이그레이션 메소드 [`create_join_table`][]은 HABTM (has and belongs to many) 조인 테이블을 생성합니다. 일반적인 사용법은 다음과 같습니다:

```ruby
create_join_table :products, :categories
```

이 마이그레이션은 `categories_products`라는 테이블을 생성하고 `category_id`와 `product_id`라는 두 개의 열을 가집니다.

이 열은 기본적으로 `:null` 옵션이 `false`로 설정되어 있으므로 이 테이블에 레코드를 저장하려면 값을 제공해야 합니다. `:column_options` 옵션을 지정하여 이를 재정의할 수 있습니다:

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

기본적으로 조인 테이블의 이름은 `create_join_table`에 제공된 첫 번째 두 인수의 합집합으로 결정됩니다.

테이블의 이름을 사용자 정의하려면 `:table_name` 옵션을 제공하면 됩니다:

```ruby
create_join_table :products, :categories, table_name: :categorization
```

이렇게 하면 조인 테이블의 이름이 요청한 대로 `categorization`이 됩니다.

또한, `create_join_table`은 블록을 허용하며, 이를 사용하여 인덱스 (기본적으로 생성되지 않음)나 추가 열을 추가할 수 있습니다.

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```


### 테이블 변경

기존 테이블을 변경하려면 [`change_table`][]을 사용할 수 있습니다.

이는 `create_table`과 유사한 방식으로 사용되지만 블록 내에서 제공되는 객체는 특수한 기능에 액세스할 수 있습니다. 예를 들어:

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

이 마이그레이션은 `description`과 `name` 열을 제거하고 `part_number`라는 새로운 문자열 열을 생성하며 이를 인덱스로 추가합니다. 마지막으로 `upccode` 열의 이름을 `upc_code`로 변경합니다.


### 열 변경

`remove_column` 및 `add_column` 메소드와 유사하게, Rails는 [`change_column`][] 마이그레이션 메소드도 제공합니다.

```ruby
change_column :products, :part_number, :text
```

이렇게 하면 `products` 테이블의 `part_number` 열이 `:text` 필드로 변경됩니다.

참고: `change_column` 명령은 **되돌릴 수 없습니다**. [이전](#되돌릴-수-있게-하기)에서 설명한 대로 직접 `reversible` 마이그레이션을 제공해야 합니다.

`change_column` 외에도 [`change_column_null`][] 및 [`change_column_default`][] 메소드는 특정 열의 null 제약 조건과 기본값을 변경하는 데 사용됩니다.

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

이렇게 하면 `products`의 `:name` 필드가 `NOT NULL` 열로 설정되고 `:approved` 필드의 기본값이 true에서 false로 변경됩니다. 이러한 변경 사항은 미래 트랜잭션에만 적용되며, 기존 레코드에는 적용되지 않습니다.

null 제약 조건을 true로 설정하면 해당 열은 null 값을 허용하며, `NOT NULL` 제약 조건이 적용되고 레코드를 데이터베이스에 유지하기 위해 값을 전달해야 합니다.

참고: 위의 `change_column_default` 마이그레이션을 `change_column_default :products, :approved, false`로 작성할 수도 있지만, 이전 예제와 달리 이는 마이그레이션을 되돌릴 수 없게 만듭니다.


### 열 수정자

열을 생성하거나 변경할 때 열 수정자를 적용할 수 있습니다:

* `comment`      열에 대한 설명을 추가합니다.
* `collation`    `string` 또는 `text` 열의 정렬을 지정합니다.
* `default`      열에 기본값을 설정할 수 있습니다. 동적 값 (예: 날짜)을 사용하는 경우 기본값은 처음에만 계산됩니다 (즉, 마이그레이션이 적용된 날짜에 계산됩니다). `NULL`의 경우 `nil`을 사용합니다.
* `limit`        `string` 열의 최대 문자 수 및 `text/binary/integer` 열의 최대 바이트 수를 설정합니다.
* `null`         열에서 `NULL` 값을 허용하거나 허용하지 않습니다.
* `precision`    `decimal/numeric/datetime/time` 열의 정밀도를 지정합니다.
* `scale`        `decimal` 및 `numeric` 열의 스케일을 지정하며 소수점 이하의 숫자 자릿수를 나타냅니다.
참고: `add_column` 또는 `change_column`에는 인덱스를 추가하는 옵션이 없습니다.
인덱스를 추가하려면 별도로 `add_index`를 사용해야 합니다.

일부 어댑터는 추가 옵션을 지원할 수도 있습니다. 자세한 내용은 어댑터별 API 문서를 참조하십시오.

참고: 마이그레이션을 생성할 때 명령줄에서 `null` 및 `default`를 지정할 수 없습니다.

### 참조

`add_reference` 메서드를 사용하면 하나 이상의 연관 관계 사이의 연결로 작동하는 적절한 이름의 열을 생성할 수 있습니다.

```ruby
add_reference :users, :role
```

이 마이그레이션은 users 테이블에 role_id 열을 생성합니다. `index: false` 옵션으로 명시적으로 지정하지 않는 한 이 열에 대한 인덱스도 생성됩니다.

INFO: 자세한 내용은 [Active Record Associations][] 가이드를 참조하십시오.

`add_belongs_to` 메서드는 `add_reference`의 별칭입니다.

```ruby
add_belongs_to :taggings, :taggable, polymorphic: true
```

다형성 연관 관계에 사용할 수 있는 두 개의 열을 taggings 테이블에 생성합니다: `taggable_type` 및 `taggable_id`.

INFO: [다형성 연관 관계][]에 대해 자세히 알아보려면 이 가이드를 참조하십시오.

`foreign_key` 옵션을 사용하여 외래 키를 생성할 수 있습니다.

```ruby
add_reference :users, :role, foreign_key: true
```

`add_reference` 옵션에 대한 자세한 내용은 [API 문서](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference)를 참조하십시오.

참조는 다음과 같이 제거할 수도 있습니다:

```ruby
remove_reference :products, :user, foreign_key: true, index: false
```

[Active Record Associations]: association_basics.html
[polymorphic associations]: association_basics.html#polymorphic-associations

### 외래 키

참조 무결성을 보장하기 위해 외래 키 제약 조건을 추가하는 것이 권장되지만 필수는 아닙니다.
[Active Record와 참조 무결성](#active-record-and-referential-integrity)을 참조하십시오.

```ruby
add_foreign_key :articles, :authors
```

이 [`add_foreign_key`][] 호출은 `articles` 테이블에 새로운 제약 조건을 추가합니다.
이 제약 조건은 `articles.author_id`와 일치하는 `authors` 테이블의 `id` 열이 있는 행이 있음을 보장합니다.

`from_table` 열 이름을 `to_table` 이름에서 유도할 수 없는 경우 `:column` 옵션을 사용할 수 있습니다. 참조된 기본 키가 `:id`가 아닌 경우 `:primary_key` 옵션을 사용하십시오.

예를 들어, `articles.reviewer`가 `authors.email`을 참조하는 외래 키를 추가하려면:

```ruby
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

이렇게 하면 `articles` 테이블에 제약 조건이 추가되어 `authors` 테이블에 `email` 열이 `articles.reviewer` 필드와 일치하는 행이 있음을 보장합니다.

`add_foreign_key`에서 `name`, `on_delete`, `if_not_exists`, `validate`, `deferrable`와 같은 여러 옵션을 지원합니다.

외래 키는 [`remove_foreign_key`][]를 사용하여 제거할 수도 있습니다:

```ruby
# Active Record가 열 이름을 자동으로 찾도록 함
remove_foreign_key :accounts, :branches

# 특정 열에 대한 외래 키 제거
remove_foreign_key :accounts, column: :owner_id
```

참고: Active Record는 단일 열 외래 키만 지원합니다. 복합 외래 키를 사용하려면 `execute` 및 `structure.sql`을 사용해야 합니다. [스키마 덤프와 함께 사용하기](#schema-dumping-and-you)를 참조하십시오.

### 헬퍼가 충분하지 않을 때

Active Record에서 제공하는 헬퍼가 충분하지 않은 경우 [`execute`][] 메서드를 사용하여 임의의 SQL을 실행할 수 있습니다:

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

자세한 내용과 각 메서드의 예제는 API 문서를 확인하십시오.

특히 [`ActiveRecord::ConnectionAdapters::SchemaStatements`][]의 문서를 참조하십시오. 이 문서에서는 `change`, `up`, `down` 메서드에서 사용할 수 있는 메서드를 제공합니다.

`create_table`에서 생성된 객체에 대한 사용 가능한 메서드에 대해서는 [`ActiveRecord::ConnectionAdapters::TableDefinition`][]을 참조하십시오.

`change_table`에서 생성된 객체에 대해서는 [`ActiveRecord::ConnectionAdapters::Table`][]을 참조하십시오.


### `change` 메서드 사용

`change` 메서드는 마이그레이션을 작성하는 주요 방법입니다. Active Record가 마이그레이션 작업을 자동으로 되돌릴 수 있는 경우 대부분의 경우에 작동합니다. `change`가 지원하는 일부 작업은 다음과 같습니다:

* [`add_check_constraint`][]
* [`add_column`][]
* [`add_foreign_key`][]
* [`add_index`][]
* [`add_reference`][]
* [`add_timestamps`][]
* [`change_column_comment`][] (`:from` 및 `:to` 옵션을 제공해야 함)
* [`change_column_default`][] (`:from` 및 `:to` 옵션을 제공해야 함)
* [`change_column_null`][]
* [`change_table_comment`][] (`:from` 및 `:to` 옵션을 제공해야 함)
* [`create_join_table`][]
* [`create_table`][]
* `disable_extension`
* [`drop_join_table`][]
* [`drop_table`][] (블록을 제공해야 함)
* `enable_extension`
* [`remove_check_constraint`][] (제약 조건 식을 제공해야 함)
* [`remove_column`][] (유형을 제공해야 함)
* [`remove_columns`][] (`:type` 옵션을 제공해야 함)
* [`remove_foreign_key`][] (두 번째 테이블을 제공해야 함)
* [`remove_index`][]
* [`remove_reference`][]
* [`remove_timestamps`][]
* [`rename_column`][]
* [`rename_index`][]
* [`rename_table`][]

[`change_table`][]은 위에 나열된 작업과 같은 복구 가능한 작업만 호출하는 한 복구 가능합니다.

`remove_column`은 세 번째 인수로 열 유형을 제공하면 복구 가능합니다. 원래의 열 옵션도 제공하십시오. 그렇지 않으면 Rails가 롤백할 때 열을 정확히 재생성할 수 없습니다:

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

다른 메서드를 사용해야 하는 경우 `reversible`을 사용하거나 `change` 메서드 대신 `up` 및 `down` 메서드를 작성해야 합니다.
### `reversible` 사용하기

복잡한 마이그레이션은 Active Record가 되돌릴 수 없는 처리를 필요로 할 수 있습니다. [`reversible`][]을 사용하여 마이그레이션을 실행할 때 무엇을 해야하는지와 되돌릴 때 무엇을 해야하는지를 지정할 수 있습니다. 예를 들어:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # 배급업체 뷰 생성
        execute <<-SQL
          CREATE VIEW distributors_view AS
          SELECT id, zipcode
          FROM distributors;
        SQL
      end
      direction.down do
        execute <<-SQL
          DROP VIEW distributors_view;
        SQL
      end
    end

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
end
```

`reversible`을 사용하면 지시문이 올바른 순서로 실행되도록 보장됩니다. 이전 예제 마이그레이션이 되돌려진 경우 `down` 블록은 `home_page_url` 열이 제거되고 `email_address` 열이 이름이 변경된 후에 `distributors` 테이블이 삭제되기 전에 실행됩니다.


### `up`/`down` 메소드 사용하기

`change` 메소드 대신 `up` 및 `down` 메소드를 사용하여 이전 스타일의 마이그레이션을 사용할 수도 있습니다.

`up` 메소드는 스키마에 대한 변환을 설명해야하며, 마이그레이션의 `up` 메소드에 의해 수행 된 변환을 되돌리는 `down` 메소드를 작성해야합니다. 다시 말해, `up` 다음에 `down`을 수행하면 데이터베이스 스키마는 변경되지 않아야합니다.

예를 들어, `up` 메소드에서 테이블을 생성하면 `down` 메소드에서 해당 테이블을 삭제해야합니다. 변환을 `up` 메소드에서 수행 된 정확히 반대 순서로 수행하는 것이 좋습니다. `reversible` 섹션의 예제는 다음과 같습니다:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # 배급업체 뷰 생성
    execute <<-SQL
      CREATE VIEW distributors_view AS
      SELECT id, zipcode
      FROM distributors;
    SQL

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end

  def down
    rename_column :users, :email_address, :email
    remove_column :users, :home_page_url

    execute <<-SQL
      DROP VIEW distributors_view;
    SQL

    drop_table :distributors
  end
end
```

### 되돌릴 수 없도록 오류 발생시키기

마이그레이션 중에는 데이터를 파괴하는 것과 같이 되돌릴 수 없는 작업을 수행 할 수도 있습니다.

이러한 경우 `down` 블록에서 `ActiveRecord::IrreversibleMigration`을 발생시킬 수 있습니다.

마이그레이션을 되돌리려고하면 수행 할 수 없다는 오류 메시지가 표시됩니다.

### 이전 마이그레이션 되돌리기

Active Record의 [`revert`][] 메소드를 사용하여 마이그레이션을 되돌릴 수 있습니다:

```ruby
require_relative "20121212123456_example_migration"

class FixupExampleMigration < ActiveRecord::Migration[7.1]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

`revert` 메소드는 역으로 실행 할 지침 블록도 허용합니다. 이는 이전 마이그레이션의 일부를 되돌리는 데 유용할 수 있습니다.

예를 들어, `ExampleMigration`이 커밋되고 나중에 배급업체 뷰가 더 이상 필요하지 않다고 결정된 경우를 상상해보십시오.

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.1]
  def change
    revert do
      # ExampleMigration에서 복사한 코드
      reversible do |direction|
        direction.up do
          # 배급업체 뷰 생성
          execute <<-SQL
            CREATE VIEW distributors_view AS
            SELECT id, zipcode
            FROM distributors;
          SQL
        end
        direction.down do
          execute <<-SQL
            DROP VIEW distributors_view;
          SQL
        end
      end

      # 마이그레이션의 나머지 부분은 정상입니다.
    end
  end
end
```

동일한 마이그레이션은 `revert`를 사용하지 않고 작성 할 수도 있지만 다음과 같은 몇 가지 단계가 더 필요합니다:

1. `create_table`과 `reversible`의 순서를 반대로합니다.
2. `create_table`을 `drop_table`로 대체합니다.
3. 마지막으로 `up`을 `down`으로, `down`을 `up`으로 대체합니다.

이 모든 것은 `revert`에서 처리됩니다.


마이그레이션 실행하기
------------------

Rails는 일부 마이그레이션 세트를 실행하기 위한 일련의 명령을 제공합니다.

가장 처음 사용하는 마이그레이션 관련 레일즈 명령은 아마도 `bin/rails db:migrate`일 것입니다. 가장 기본적인 형태로는 아직 실행되지 않은 모든 마이그레이션의 `change` 또는 `up` 메소드를 실행합니다. 이러한 마이그레이션이 없으면 종료됩니다. 마이그레이션은 마이그레이션의 날짜를 기준으로 순서대로 실행됩니다.

`db:migrate` 명령을 실행하면 `db:schema:dump` 명령도 실행되어 `db/schema.rb` 파일이 데이터베이스의 구조와 일치하도록 업데이트됩니다.

대상 버전을 지정하면 Active Record는 지정된 버전에 도달 할 때까지 필요한 마이그레이션(변경, up, down)을 실행합니다. 버전은 마이그레이션 파일 이름의 숫자 접두사입니다. 예를 들어, 버전 20080906120000으로 마이그레이션을 마이그레이션하려면 다음을 실행하십시오:
```bash
$ bin/rails db:migrate VERSION=20080906120000
```

만약 버전 20080906120000이 현재 버전보다 큰 경우 (즉, 위로 마이그레이션하는 경우), 이는 20080906120000을 포함하여 그 이전의 모든 마이그레이션에 대해 `change` (또는 `up`) 메소드를 실행하고 이후의 마이그레이션은 실행하지 않습니다. 아래로 마이그레이션하는 경우, 이는 20080906120000을 제외한 모든 마이그레이션에 대해 `down` 메소드를 실행합니다.

### 롤백

마지막 마이그레이션을 롤백하는 것은 일반적인 작업입니다. 예를 들어, 마이그레이션에서 실수를 한 경우 이를 수정하고 싶을 때 이전 마이그레이션과 관련된 버전 번호를 찾아내는 대신 다음을 실행할 수 있습니다.

```bash
$ bin/rails db:rollback
```

이는 최신 마이그레이션을 롤백하며, `change` 메소드를 되돌리거나 `down` 메소드를 실행합니다. 여러 개의 마이그레이션을 되돌리려면 `STEP` 매개변수를 제공할 수 있습니다.

```bash
$ bin/rails db:rollback STEP=3
```

마지막 3개의 마이그레이션이 롤백됩니다.

`db:migrate:redo` 명령은 롤백을 수행한 후 다시 마이그레이션을 실행하는 단축키입니다. `db:rollback` 명령과 마찬가지로 `STEP` 매개변수를 사용하여 한 번 이상 이전 버전으로 이동해야 하는 경우에 사용할 수 있습니다. 예를 들어:

```bash
$ bin/rails db:migrate:redo STEP=3
```

이러한 Rails 명령은 `db:migrate`로 수행할 수 없는 작업을 수행하지 않습니다. 버전을 명시적으로 지정할 필요가 없기 때문에 편의를 위해 제공됩니다.

### 데이터베이스 설정

`bin/rails db:setup` 명령은 데이터베이스를 생성하고 스키마를 로드하며 시드 데이터로 초기화합니다.

### 데이터베이스 재설정

`bin/rails db:reset` 명령은 데이터베이스를 삭제하고 다시 설정합니다. 이는 `bin/rails db:drop db:setup`과 기능적으로 동일합니다.

참고: 이는 모든 마이그레이션을 실행하는 것과 동일하지 않습니다. 현재의 `db/schema.rb` 또는 `db/structure.sql` 파일의 내용만 사용합니다. 마이그레이션을 롤백할 수 없는 경우 `bin/rails db:reset`은 도움이 되지 않을 수 있습니다. 스키마 덤프에 대해 자세히 알아보려면 [스키마 덤프 및 관련 정보][] 섹션을 참조하십시오.

[스키마 덤프 및 관련 정보]: #스키마-덤프-및-관련-정보

### 특정 마이그레이션 실행

특정 마이그레이션을 위로 또는 아래로 실행해야 하는 경우 `db:migrate:up` 및 `db:migrate:down` 명령을 사용할 수 있습니다. 적절한 버전을 지정하면 해당 마이그레이션의 `change`, `up` 또는 `down` 메소드가 호출됩니다. 예를 들어:

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

이 명령을 실행하면 버전 "20080906120000"을 가진 마이그레이션의 `change` 메소드 (또는 `up` 메소드)가 실행됩니다.

먼저, 이 명령은 마이그레이션이 존재하고 이미 수행되었는지 확인하고, 그렇다면 아무 작업도 수행하지 않습니다.

지정된 버전이 존재하지 않는 경우, Rails는 예외를 throw합니다.

```bash
$ bin/rails db:migrate VERSION=zomg
rails aborted!
ActiveRecord::UnknownMigrationVersionError:

No migration with version number zomg.
```

### 다른 환경에서 마이그레이션 실행

기본적으로 `bin/rails db:migrate`는 `development` 환경에서 실행됩니다.

다른 환경에서 마이그레이션을 실행하려면 명령을 실행하는 동안 `RAILS_ENV` 환경 변수를 지정할 수 있습니다. 예를 들어 `test` 환경에서 마이그레이션을 실행하려면 다음과 같이 실행할 수 있습니다.

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### 마이그레이션 실행 결과 변경

기본적으로 마이그레이션은 수행한 작업과 소요 시간을 정확히 알려줍니다. 테이블을 생성하고 인덱스를 추가하는 마이그레이션은 다음과 같은 출력을 생성할 수 있습니다.

```
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

마이그레이션에서는 이를 제어할 수 있는 여러 가지 메소드가 제공됩니다:

| 메소드                     | 목적
| -------------------------- | -------
| [`suppress_messages`][]    | 블록을 인수로 받아 블록에서 생성된 출력을 억제합니다.
| [`say`][]                  | 메시지 인수를 받아 그대로 출력합니다. 두 번째 부울 인수를 전달하여 들여쓸지 여부를 지정할 수 있습니다.
| [`say_with_time`][]        | 텍스트와 블록 실행 시간을 함께 출력합니다. 블록이 정수를 반환하면 영향을 받은 행 수로 간주합니다.

예를 들어, 다음과 같은 마이그레이션을 살펴보세요:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    suppress_messages do
      create_table :products do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say "Created a table"

    suppress_messages { add_index :products, :name }
    say "and an index!", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end
```

다음 출력을 생성합니다.

```
==  CreateProducts: 마이그레이션 중 =================================================
-- 테이블이 생성되었습니다.
   -> 그리고 인덱스도 생성되었습니다!
-- 잠시 기다립니다.
   -> 10.0013초
   -> 250개 행
==  CreateProducts: 마이그레이션 완료 (10.0054초) =======================================
```

Active Record가 아무런 출력을 하지 않도록 하려면 `bin/rails db:migrate VERBOSE=false`를 실행하면 모든 출력이 억제됩니다.


기존 마이그레이션 변경하기
----------------------------

가끔 마이그레이션을 작성할 때 실수를 할 수 있습니다. 이미 마이그레이션을 실행했다면, 마이그레이션을 편집하고 다시 마이그레이션을 실행할 수는 없습니다. Rails는 이미 마이그레이션을 실행했다고 생각하기 때문에 `bin/rails db:migrate`를 실행할 때 아무 작업도 수행하지 않습니다. 마이그레이션을 롤백해야 하며(예: `bin/rails db:rollback`), 마이그레이션을 편집한 후 수정된 버전을 실행하기 위해 `bin/rails db:migrate`를 실행해야 합니다.

일반적으로 기존 마이그레이션을 편집하는 것은 좋은 생각이 아닙니다. 이렇게 하면 여러분과 동료들에게 추가 작업을 만들고, 기존 버전의 마이그레이션이 이미 프로덕션 서버에서 실행되었다면 큰 문제를 야기할 수 있습니다.

대신, 필요한 변경 작업을 수행하는 새로운 마이그레이션을 작성해야 합니다. 아직 소스 컨트롤에 커밋되지 않은(또는 개발 환경 이상으로 전파되지 않은) 새로 생성된 마이그레이션을 편집하는 것은 비교적 무해합니다.

새로운 마이그레이션을 작성할 때 이전 마이그레이션을 전체 또는 일부분을 되돌리기 위해 `revert` 메소드를 사용할 수 있습니다(자세한 내용은 [이전 마이그레이션 되돌리기][] 참조).

[이전 마이그레이션 되돌리기]: #이전-마이그레이션-되돌리기

스키마 덤프와 당신
--------------------

### 스키마 파일은 무엇을 위한 것인가요?

마이그레이션은 강력하지만, 데이터베이스 스키마의 권위적인 소스는 아닙니다. **데이터베이스가 진실의 원천입니다.**

기본적으로 Rails는 현재 데이터베이스 스키마의 상태를 캡처하기 위해 `db/schema.rb`를 생성합니다.

마이그레이션 전체 이력을 재생하는 것보다 `bin/rails db:schema:load`를 통해 스키마 파일을 로드하여 새로운 애플리케이션 데이터베이스 인스턴스를 생성하는 것이 더 빠르고 오류가 적습니다. [이전 마이그레이션][]은 변경되는 외부 종속성을 사용하거나 마이그레이션과 별도로 진화하는 애플리케이션 코드에 의존하는 경우 올바르게 적용되지 않을 수 있습니다.

스키마 파일은 또한 Active Record 객체가 가지고 있는 속성을 빠르게 확인하고자 할 때 유용합니다. 이 정보는 모델의 코드에 없으며 종종 여러 마이그레이션에 분산되어 있지만, 스키마 파일에는 이 정보가 잘 요약되어 있습니다.

[이전 마이그레이션]: #이전-마이그레이션

### 스키마 덤프의 종류

Rails가 생성하는 스키마 덤프의 형식은 `config/application.rb`에 정의된 [`config.active_record.schema_format`][] 설정에 의해 제어됩니다. 기본적으로 형식은 `:ruby`로 설정되어 있으며, 대체로 `:sql`로 설정할 수도 있습니다.

#### 기본 `:ruby` 스키마 사용

`:ruby`가 선택되면 스키마는 `db/schema.rb`에 저장됩니다. 이 파일을 보면 하나의 큰 마이그레이션과 매우 유사한 것을 알 수 있습니다:

```ruby
ActiveRecord::Schema[7.1].define(version: 2008_09_06_171750) do
  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "part_number"
  end
end
```

많은 면에서 이것이 바로 그것입니다. 이 파일은 데이터베이스를 검사하고 `create_table`, `add_index` 등을 사용하여 데이터베이스의 구조를 표현하기 위해 생성됩니다.

#### `:sql` 스키마 덤프 사용

그러나 `db/schema.rb`는 트리거, 시퀀스, 저장 프로시저 등과 같이 데이터베이스가 지원하는 모든 것을 표현할 수 없습니다.

마이그레이션에서는 루비 마이그레이션 DSL이 지원하지 않는 데이터베이스 구조를 생성하기 위해 `execute`를 사용할 수 있지만, 스키마 덤퍼로 다시 구성할 수 없을 수도 있습니다.

이러한 기능을 사용하는 경우 스키마 형식을 `:sql`로 설정하여 새로운 데이터베이스 인스턴스를 생성하는 데 유용한 정확한 스키마 파일을 얻을 수 있습니다.

스키마 형식이 `:sql`로 설정되면 데이터베이스 구조는 데이터베이스에 특화된 도구를 사용하여 `db/structure.sql`에 덤프됩니다. 예를 들어, PostgreSQL의 경우 `pg_dump` 유틸리티를 사용합니다. MySQL과 MariaDB의 경우 이 파일에는 다양한 테이블에 대한 `SHOW CREATE TABLE`의 출력이 포함됩니다.

`db/structure.sql`에서 스키마를 로드하려면 `bin/rails db:schema:load`를 실행하면 됩니다. 이 파일을 로드하기 위해 포함된 SQL 문을 실행합니다. 정의에 따라 이렇게 하면 데이터베이스의 구조를 완벽하게 복사할 수 있습니다.


### 스키마 덤프와 소스 컨트롤
스키마 파일은 일반적으로 새로운 데이터베이스를 생성하는 데 사용되므로 스키마 파일을 소스 컨트롤에 체크하는 것이 강력히 권장됩니다.

스키마 파일에서 병합 충돌이 발생할 수 있습니다. 이러한 충돌을 해결하려면 `bin/rails db:migrate`를 실행하여 스키마 파일을 다시 생성하십시오.

INFO: 새로 생성된 Rails 앱은 이미 마이그레이션 폴더가 git 트리에 포함되어 있으므로 추가한 새로운 마이그레이션을 추가하고 커밋하기만 하면 됩니다.

Active Record와 참조 무결성
---------------------------------------

Active Record 방식은 지능이 데이터베이스가 아닌 모델에 속한다고 주장합니다. 따라서 일부 지능을 데이터베이스로 다시 밀어넣는 트리거나 제약 조건과 같은 기능은 권장되지 않습니다.

`validates :foreign_key, uniqueness: true`와 같은 유효성 검사는 모델이 데이터 무결성을 강제하는 한 가지 방법입니다. 연관성에 대한 `:dependent` 옵션은 부모가 삭제될 때 자동으로 자식 객체를 삭제할 수 있도록 합니다. 응용 프로그램 수준에서 작동하는 것과 마찬가지로 이러한 기능은 참조 무결성을 보장할 수 없으므로 일부 사람들은 데이터베이스에 [외래 키 제약 조건][]을 추가하여 보완합니다.

Active Record는 이러한 기능과 직접 작업하기 위한 모든 도구를 제공하지는 않지만 `execute` 메서드를 사용하여 임의의 SQL을 실행할 수 있습니다.

[외래 키 제약 조건]: #foreign-keys

마이그레이션과 시드 데이터
------------------------

Rails의 마이그레이션 기능의 주요 목적은 일관된 프로세스를 사용하여 스키마를 수정하는 명령을 내리는 것입니다. 마이그레이션은 데이터를 추가하거나 수정하는 데에도 사용될 수 있습니다. 이는 생성할 수 없는 기존 데이터베이스(예: 프로덕션 데이터베이스)에서 유용합니다.

```ruby
class AddInitialProducts < ActiveRecord::Migration[7.1]
  def up
    5.times do |i|
      Product.create(name: "Product ##{i}", description: "A product.")
    end
  end

  def down
    Product.delete_all
  end
end
```

데이터베이스가 생성된 후 초기 데이터를 추가하려면 Rails에는 프로세스를 가속화하는 '시드' 기능이 내장되어 있습니다. 이는 개발 및 테스트 환경에서 데이터베이스를 자주 다시로드하거나 프로덕션에 초기 데이터를 설정할 때 특히 유용합니다.

이 기능을 사용하려면 `db/seeds.rb` 파일을 열고 일부 루비 코드를 추가한 다음 `bin/rails db:seed`를 실행하십시오.

참고: 여기에 있는 코드는 어떤 환경에서든지 언제든지 실행할 수 있도록 idempotent해야 합니다.

```ruby
["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
  MovieGenre.find_or_create_by!(name: genre_name)
end
```

이는 일반적으로 빈 애플리케이션의 데이터베이스를 설정하는 더 깔끔한 방법입니다.

이전 마이그레이션
--------------

`db/schema.rb` 또는 `db/structure.sql`은 데이터베이스의 현재 상태를 스냅샷으로 만들어 해당 데이터베이스를 다시 구축하는 권한 있는 소스입니다. 이를 통해 이전의 마이그레이션 파일을 삭제하거나 정리할 수 있습니다.

`db/migrate/` 디렉토리에서 마이그레이션 파일을 삭제하면 `bin/rails db:migrate`가 해당 파일이 아직 존재할 때 실행되었던 환경에서는 해당 환경에 특정한 마이그레이션 타임스탬프에 대한 참조를 내부적으로 유지하는 Rails 내부 데이터베이스 테이블인 `schema_migrations`에 남게 됩니다. 이 테이블은 특정 환경에서 마이그레이션이 실행되었는지 여부를 추적하는 데 사용됩니다.

`bin/rails db:migrate:status` 명령을 실행하면 각 마이그레이션의 상태(적용 또는 취소)를 표시하는데, `db/migrate/` 디렉토리에서 더 이상 찾을 수 없는 삭제된 마이그레이션 파일 옆에 `********** NO FILE **********`이 표시될 것입니다.

### 엔진에서의 마이그레이션

그러나 [엔진][Engines]에는 주의할 점이 있습니다. 엔진에서 마이그레이션을 설치하기 위한 Rake 작업은 idempotent하며, 즉 호출 횟수에 관계없이 항상 동일한 결과를 가져옵니다. 이전 설치로 인해 부모 애플리케이션에 존재하는 마이그레이션은 건너뛰고, 누락된 마이그레이션은 새로운 타임스탬프와 함께 복사됩니다. 이전 엔진 마이그레이션을 삭제하고 설치 작업을 다시 실행하면 새로운 타임스탬프가 있는 새 파일을 얻게 되며, `db:migrate`가 다시 실행되려고 할 것입니다.

따라서 일반적으로 엔진에서 오는 마이그레이션을 보존하는 것이 좋습니다. 다음과 같은 특별한 주석이 있습니다:

```ruby
# This migration comes from blorgh (originally 20210621082949)
```

 [Engines]: engines.html
[`add_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`add_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[`remove_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_column
[`create_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_table
[`create_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_join_table
[`change_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table
[`change_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column
[`change_column_default`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_default
[`change_column_null`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_null
[`execute`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-execute
[`ActiveRecord::ConnectionAdapters::SchemaStatements`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
[`ActiveRecord::ConnectionAdapters::TableDefinition`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html
[`ActiveRecord::ConnectionAdapters::Table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html
[`add_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_check_constraint
[`add_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key
[`add_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_timestamps
[`change_column_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_comment
[`change_table_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table_comment
[`drop_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_join_table
[`drop_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_table
[`remove_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_check_constraint
[`remove_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key
[`remove_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_index
[`remove_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_reference
[`remove_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_timestamps
[`rename_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_column
[`remove_columns`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_columns
[`rename_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_index
[`rename_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_table
[`reversible`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-reversible
[`revert`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-revert
[`say`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say
[`say_with_time`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say_with_time
[`suppress_messages`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-suppress_messages
[`config.active_record.schema_format`]: configuring.html#config-active-record-schema-format
