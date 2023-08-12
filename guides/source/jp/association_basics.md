**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 516604959485cfefb0e0d775d767699b
Active Recordの関連付け
==========================

このガイドでは、Active Recordの関連付け機能について説明します。

このガイドを読み終えると、以下のことがわかるようになります。

* Active Recordモデル間の関連付けを宣言する方法
* Active Recordのさまざまな種類の関連付けを理解する方法
* 関連付けを作成することでモデルに追加されるメソッドを使用する方法

--------------------------------------------------------------------------------

なぜ関連付けが必要なのか？
-----------------

Railsでは、_関連付け_は2つのActive Recordモデル間の接続です。なぜモデル間に関連付けが必要なのでしょうか？それは、コード内で一般的な操作をよりシンプルかつ簡単にするためです。

例えば、著者のモデルと本のモデルを含むシンプルなRailsアプリケーションを考えてみましょう。各著者は多くの本を持つことができます。

関連付けがない場合、モデルの宣言は次のようになります。

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

さて、既存の著者に新しい本を追加したいとしましょう。次のようなことを行う必要があります。

```ruby
@book = Book.create(published_at: Time.now, author_id: @author.id)
```

また、著者を削除し、その著者のすべての本も削除する必要がある場合を考えてみましょう。

```ruby
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

Active Recordの関連付けを使用すると、これらの操作を簡略化できます。2つのモデル間に接続があることをRailsに宣言的に伝えることで、これらの操作などを行うことができます。以下は、著者と本の設定のための修正されたコードです。

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

この変更により、特定の著者の新しい本を作成することが簡単になります。

```ruby
@book = @author.books.create(published_at: Time.now)
```

著者とそのすべての本を削除することも*はるかに*簡単になります。

```ruby
author.destroy
```

さまざまな種類の関連付けについて詳しく学ぶには、このガイドの次のセクションを読んでください。それに続いて、関連付けを使用するためのヒントやトリック、そしてRailsでの関連付けのメソッドとオプションの完全なリファレンスがあります。

関連付けの種類
-------------------------

Railsは、特定のユースケースを考慮した6つの関連付けをサポートしています。

以下は、すべてのサポートされている種類のリストです。詳細な情報や使用方法、メソッドのパラメータなどについては、それぞれのAPIドキュメントへのリンクを参照してください。

* [`belongs_to`][]
* [`has_one`][]
* [`has_many`][]
* [`has_many :through`][`has_many`]
* [`has_one :through`][`has_one`]
* [`has_and_belongs_to_many`][]

関連付けはマクロスタイルの呼び出しを使用して実装されているため、モデルに機能を宣言的に追加することができます。例えば、あるモデルが別のモデルに`belongs_to`することを宣言することで、Railsに2つのモデルのインスタンス間の[主キー](https://en.wikipedia.org/wiki/Primary_key)-[外部キー](https://en.wikipedia.org/wiki/Foreign_key)情報を維持するように指示し、モデルにいくつかのユーティリティメソッドが追加されます。

このガイドの残りの部分では、さまざまな形式の関連付けの宣言と使用方法について学びます。しかし、まずは、各関連付けタイプが適切な状況で使用される場面について簡単に紹介します。


### `belongs_to`関連付け

[`belongs_to`][]関連付けは、他のモデルとの接続を設定し、宣言するモデルの各インスタンスが他のモデルの1つのインスタンスに「所属する」という関係を構築します。例えば、アプリケーションに著者と本が含まれており、各本が正確に1人の著者に割り当てられる場合、次のように本のモデルを宣言します。

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

![belongs_to関連付けダイアグラム](images/association_basics/belongs_to.png)

注意：`belongs_to`関連付けは、単数形の用語を使用する必要があります。上記の例で`Book`モデルの`author`関連付けで複数形の形を使用し、`Book.create(authors: author)`というインスタンスを作成しようとすると、「未初期化定数Book::Authorsがあります」というエラーが表示されます。これは、Railsが自動的に関連付け名からクラス名を推測するためです。関連付け名が誤って複数形になっている場合、推測されるクラス名も誤って複数形になります。

対応するマイグレーションは次のようになるでしょう。

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

`belongs_to`単体では、一方向の一対一の接続を生成します。したがって、上記の例では各本が著者を「知っている」一方、著者は自分の本については知りません。
[双方向の関連付け](#bi-directional-associations)を設定するには、この場合はAuthorモデルで他のモデルに対して`has_one`または`has_many`を組み合わせて`belongs_to`を使用します。

`optional`がtrueに設定されている場合、`belongs_to`は参照の一貫性を保証しません。したがって、使用ケースに応じて、参照カラムにデータベースレベルの外部キー制約を追加する必要があるかもしれません。
```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```

### `has_one`関連付け

[`has_one`][]関連付けは、他のモデルがこのモデルへの参照を持っていることを示します。この関連付けを介してそのモデルを取得することができます。

例えば、アプリケーションの各サプライヤーが1つのアカウントしか持たない場合、次のようにサプライヤーモデルを宣言します。

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

`belongs_to`との主な違いは、リンクカラム`supplier_id`が他のテーブルにあることです。

![has_one関連付けのダイアグラム](images/association_basics/has_one.png)

対応するマイグレーションは次のようになります。

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

使用ケースによっては、アカウントテーブルのサプライヤーカラムに一意のインデックスと/または外部キー制約を作成する必要がある場合があります。この場合、カラムの定義は次のようになります。

```ruby
create_table :accounts do |t|
  t.belongs_to :supplier, index: { unique: true }, foreign_key: true
  # ...
end
```

この関連付けは、他のモデルで`belongs_to`と組み合わせて使用する場合、[双方向](#bi-directional-associations)になります。

### `has_many`関連付け

[`has_many`][]関連付けは、`has_one`に似ていますが、別のモデルとの1対多の関連付けを示します。通常、`belongs_to`関連付けの「反対側」にこの関連付けが見つかります。この関連付けは、モデルの各インスタンスが他のモデルの0個以上のインスタンスを持つことを示します。例えば、著者と書籍を含むアプリケーションでは、著者モデルは次のように宣言されます。

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

注意：`has_many`関連付けの場合、他のモデルの名前は複数形にする必要があります。

![has_many関連付けのダイアグラム](images/association_basics/has_many.png)

対応するマイグレーションは次のようになります。

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

使用ケースによっては、booksテーブルのauthorカラムに非一意のインデックスとオプションで外部キー制約を作成することが良いアイデアです。

```ruby
create_table :books do |t|
  t.belongs_to :author, index: true, foreign_key: true
  # ...
end
```

### `has_many :through`関連付け

[`has_many :through`][`has_many`]関連付けは、他のモデルと多対多の関連付けを設定するためによく使用されます。この関連付けは、宣言モデルが3番目のモデルを介して他のモデルの0個以上のインスタンスと一致することを示します。例えば、患者が医師を診るために予約をする医療機関を考えてみましょう。関連する宣言は次のようになります。

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

![has_many :through関連付けのダイアグラム](images/association_basics/has_many_through.png)

対応するマイグレーションは次のようになります。

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

結合モデルのコレクションは、[`has_many`関連付けメソッド](#has-many-association-reference)を介して管理できます。
例えば、次のように割り当てる場合：

```ruby
physician.patients = patients
```

新しい結合モデルが自動的に新しく関連付けられたオブジェクトのために作成されます。
以前存在していたものの一部が欠落している場合、それらの結合行は自動的に削除されます。

警告：結合モデルの自動削除は直接的なものであり、削除コールバックはトリガされません。

`has_many :through`関連付けは、ネストされた`has_many`関連付けを介した「ショートカット」の設定にも便利です。例えば、ドキュメントにはセクションが多くあり、セクションには段落が多くあります。ドキュメントのすべての段落の単純なコレクションを取得したい場合があります。次のように設定することができます。

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

`through: :sections`が指定されているため、Railsは次を理解します。

```ruby
@document.paragraphs
```

### `has_one :through`関連付け

[`has_one :through`][`has_one`]関連付けは、他のモデルとの1対1の関連付けを設定します。この関連付けは、宣言モデルが3番目のモデルを介して別のモデルの1つのインスタンスと一致することを示します。
例えば、各サプライヤーには1つのアカウントがあり、各アカウントには1つのアカウント履歴が関連付けられている場合、サプライヤーモデルは次のようになります：
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

対応するマイグレーションは次のようになるでしょう：

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

### `has_and_belongs_to_many` 関連

[`has_and_belongs_to_many`][] 関連は、他のモデルと直接的な多対多の関係を作成します。この関連は、宣言するモデルの各インスタンスが他のモデルの0個以上のインスタンスを参照することを示します。例えば、アセンブリとパーツを含むアプリケーションの場合、各アセンブリは多くのパーツを持ち、各パーツは多くのアセンブリに現れることがあります。以下のようにモデルを宣言することができます：

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

![has_and_belongs_to_many 関連のダイアグラム](images/association_basics/habtm.png)

対応するマイグレーションは次のようになるでしょう：

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

### `belongs_to` と `has_one` の選択

2つのモデル間に1対1の関係を設定する場合、1つに `belongs_to` を追加し、もう1つに `has_one` を追加する必要があります。どちらがどちらかをどのように知ることができますか？

外部キーをどこに配置するか（`belongs_to` 関連を宣言するクラスのテーブルに配置する）という違いがありますが、データの実際の意味にも注意を払う必要があります。`has_one` 関連は、何かの1つがあなたのものであることを示します。つまり、何かがあなたを指し示すということです。例えば、サプライヤーがアカウントを所有していると言う方が、アカウントがサプライヤーを所有していると言うよりも意味があります。これは、正しい関係が次のようになることを示唆しています：

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

対応するマイグレーションは次のようになるでしょう：

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

注意：`t.bigint :supplier_id` を使用することで、外部キーの命名が明確で明示的になります。Railsの現在のバージョンでは、`t.references :supplier` を使用することで、この実装の詳細を抽象化することができます。

### `has_many :through` と `has_and_belongs_to_many` の選択

Railsでは、モデル間の多対多の関係を宣言するために2つの異なる方法が提供されています。1つ目の方法は `has_and_belongs_to_many` を使用する方法で、直接関連を作成することができます：

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

2つ目の方法は `has_many :through` を使用する方法で、関連を結合モデルを介して間接的に作成します：

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

簡単なルールは、関連モデルを独立したエンティティとして扱う必要がある場合は `has_many :through` 関連を設定することです。関連モデルで何か特別な操作を行う必要がない場合は、`has_and_belongs_to_many` 関連を設定する方が簡単です（ただし、データベースに結合テーブルを作成する必要があることを忘れないでください）。

`has_many :through` は、結合モデルにバリデーション、コールバック、または追加の属性が必要な場合に使用します。

### ポリモーフィック関連

関連に関して少し高度なトピックとして、_ポリモーフィック関連_ があります。ポリモーフィック関連では、モデルは複数の他のモデルに所属することができます。例えば、従業員モデルまたは製品モデルに所属する写真モデルがあるかもしれません。次のように宣言することができます：

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

ポリモーフィックな `belongs_to` 宣言は、他のどのモデルでも使用できるインターフェースを設定することと考えることができます。`Employee` モデルのインスタンスからは、写真のコレクションを取得することができます：`@employee.pictures`。
同様に、`@product.pictures`を取得することもできます。

`Picture`モデルのインスタンスがある場合、`@picture.imageable`を使用して親にアクセスできます。これを動作させるには、ポリモーフィックなインターフェースを宣言するモデルに外部キーカラムとタイプカラムの両方を宣言する必要があります。

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

このマイグレーションは、`t.references`形式を使用することで簡略化できます。

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

![ポリモーフィック関連図](images/association_basics/polymorphic.png)

### セルフジョイン

データモデルを設計する際に、自身に関連を持つモデルがある場合があります。たとえば、すべての従業員を単一のデータベースモデルに格納したいが、マネージャーと部下のような関係を追跡できるようにしたい場合があります。このような状況は、セルフジョイン関連を使用してモデル化できます。

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true
end
```

この設定を使用すると、`@employee.subordinates`と`@employee.manager`を取得できます。

マイグレーション/スキーマでは、モデル自体に参照カラムを追加します。

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

注意：`foreign_key`に渡される`to_table`オプションなど、他のオプションの詳細については、[`SchemaStatements#add_reference`][connection.add_reference]を参照してください。


Tips、Tricks、および警告
--------------------------

RailsアプリケーションでActive Record関連を効率的に使用するために知っておくべきいくつかのことがあります。

* キャッシュの制御
* 名前の衝突を回避する
* スキーマの更新
* 関連のスコープの制御
* 双方向の関連

### キャッシュの制御

すべての関連メソッドはキャッシュを中心に構築されており、最新のクエリの結果をさらなる操作で使用できるようにします。キャッシュはメソッド間で共有されます。たとえば：

```ruby
# データベースから本を取得
author.books.load

# キャッシュされた本のコピーを使用
author.books.size

# キャッシュされた本のコピーを使用
author.books.empty?
```

ただし、アプリケーションの他の部分でデータが変更された可能性があるため、キャッシュを再読み込みする必要がある場合は、関連に対して`reload`を呼び出すだけです。

```ruby
# データベースから本を取得
author.books.load

# キャッシュされた本のコピーを使用
author.books.size

# キャッシュされた本のコピーを破棄し、データベースに戻る
author.books.reload.empty?
```

### 名前の衝突を回避する

関連には任意の名前を自由に使用することはできません。関連はその名前のメソッドをモデルに追加するため、`ActiveRecord::Base`のインスタンスメソッドと同じ名前を関連に付けることは良いアイデアではありません。関連メソッドはベースメソッドを上書きし、問題を引き起こします。たとえば、`attributes`や`connection`は関連には適切な名前ではありません。

### スキーマの更新

関連は非常に便利ですが、魔法ではありません。関連に合わせてデータベーススキーマを維持する責任があります。実際には、作成する関連の種類によって2つのことを行う必要があります。`belongs_to`関連では外部キーを作成する必要があり、`has_and_belongs_to_many`関連では適切な結合テーブルを作成する必要があります。

#### `belongs_to`関連のための外部キーの作成

`belongs_to`関連を宣言するときは、必要に応じて外部キーを作成する必要があります。たとえば、次のモデルを考えてみてください。

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

この宣言は、booksテーブルに対応する外部キーカラムをバックアップする必要があります。新しいテーブルの場合、マイグレーションは次のようになるかもしれません。

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

既存のテーブルの場合、次のようになるかもしれません。

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[7.1]
  def change
    add_reference :books, :author
  end
end
```

注意：データベースレベルで[参照整合性を強制する][foreign_keys]場合は、上記の‘reference’カラム宣言に`foreign_key: true`オプションを追加してください。


#### `has_and_belongs_to_many`関連のための結合テーブルの作成

`has_and_belongs_to_many`関連を作成する場合は、明示的に結合テーブルを作成する必要があります。`:join_table`オプションを使用して結合テーブルの名前を明示的に指定しない限り、Active Recordはクラス名の辞書順を使用して名前を作成します。したがって、authorとbookモデルの間の結合は、クラス名の辞書順で「authors_books」というデフォルトの結合テーブル名が付けられます。


警告：モデル名の優先順位は、`String`の`<=>`演算子を使用して計算されます。これは、文字列の長さが異なり、最短の長さまで比較した結果が等しい場合、長い文字列が短い文字列よりも辞書的な優先順位が高いと見なされることを意味します。例えば、テーブルの名前が "paper_boxes" と "papers" の場合、"paper_boxes" の長さのために "papers_paper_boxes" という結合テーブル名が生成されると予想されますが、実際には "paper_boxes_papers" という結合テーブル名が生成されます（アンダースコア '\_' は一般的なエンコーディングでは 's' よりも辞書的に _小さい_ からです）。

どのような名前であっても、適切なマイグレーションを使用して結合テーブルを手動で生成する必要があります。例えば、次の関連付けを考えてみましょう：

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

これらは、`assemblies_parts` テーブルを作成するためのマイグレーションでバックアップする必要があります。このテーブルは、プライマリキーなしで作成する必要があります：

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

`create_table` に `id: false` を渡すのは、そのテーブルがモデルを表していないためです。これは関連付けが正しく機能するために必要です。`has_and_belongs_to_many` の関連付けでモデルのIDが破損したり、IDの競合に関する例外が発生したりする場合は、この部分を忘れている可能性があります。

簡単のために、`create_join_table` メソッドを使用することもできます：

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

### 関連付けのスコープの制御

デフォルトでは、関連付けは現在のモジュールのスコープ内でのみオブジェクトを検索します。これは、Active Record モデルをモジュール内で宣言する場合に重要です。例えば：

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

これは正常に動作します。なぜなら、`Supplier` クラスと `Account` クラスが同じスコープ内で定義されているからです。しかし、次の例は動作しません。なぜなら、`Supplier` と `Account` が異なるスコープで定義されているからです。

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

異なる名前空間のモデルと関連付けるには、関連付けの宣言で完全なクラス名を指定する必要があります。

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

### 双方向の関連付け

関連付けは通常、2つの方向で動作することがあります。そのため、2つの異なるモデルで宣言する必要があります。

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Active Record は、関連付け名に基づいてこれら2つのモデルが双方向の関連付けを共有していることを自動的に識別しようとします。この情報により、Active Record は次のことができます。

* すでにロードされたデータに対して不要なクエリを防ぐ：

    ```irb
    irb> author = Author.first
    irb> author.books.all? do |book|
    irb>   book.author.equal?(author) # ここで追加のクエリが実行されません
    irb> end
    => true
    ```

* 不整合なデータを防ぐ（`Author` オブジェクトが1つしかロードされていないため）：

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Changed Name"
    irb> author.name == book.author.name
    => true
    ```

* より多くのケースで関連付けを自動的に保存する：

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => true
    ```

* [存在](active_record_validations.html#presence)と[不在](active_record_validations.html#absence)のバリデーションをより多くのケースで行う：

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

Active Record は、標準的な名前を持つほとんどの関連付けに対して自動的な識別をサポートしています。ただし、`:through` オプションまたは `:foreign_key` オプションを含む双方向の関連付けは、自動的に識別されません。

また、逆の関連付けにカスタムスコープがある場合、および [`config.active_record.automatic_scope_inversing`][] が true に設定されている場合（新しいアプリケーションのデフォルト値）、関連付け自体にカスタムスコープがある場合も、自動的な識別が阻害されます。

例えば、次のモデル宣言を考えてみましょう：

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

`:foreign_key` オプションのため、Active Record はもはや自動的に双方向の関連付けを認識しません。これにより、アプリケーションが次のような問題を引き起こす可能性があります：
* 同じデータに対して不要なクエリを実行する（この例ではN+1のクエリが発生する）：

    ```irb
    irb> author = Author.first
    irb> author.books.any? do |book|
    irb>   book.author.equal?(author) # これは各本ごとに作者のクエリを実行します
    irb> end
    => false
    ```

* 不整合なデータを持つモデルの複数のコピーを参照する：

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "変更された名前"
    irb> author.name == book.author.name
    => false
    ```

* 関連を自動保存できない：

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => false
    ```

* 存在または不在を検証できない：

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    ```

Active Recordは、双方向の関連を明示的に宣言するための`:inverse_of`オプションを提供しています：

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

`has_many`関連の宣言に`:inverse_of`オプションを含めることで、Active Recordは双方向の関連を認識し、最初の例と同様の動作をします。


詳細な関連のリファレンス
------------------------------

以下のセクションでは、各種の関連の詳細、および関連を宣言する際に使用できるオプションについて説明します。

### `belongs_to`関連のリファレンス

データベースの観点から、`belongs_to`関連は、このモデルのテーブルに、他のテーブルへの参照を表すカラムが含まれていることを意味します。
これは、1対1または1対多の関係を設定するために使用できます。
他のクラスのテーブルが1対1の関係で参照を含む場合は、代わりに`has_one`を使用する必要があります。

#### `belongs_to`で追加されるメソッド

`belongs_to`関連を宣言すると、宣言するクラスには、関連に関連する8つのメソッドが自動的に追加されます：

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`
* `association_changed?`
* `association_previously_changed?`

これらのメソッドのすべてで、`association`は、`belongs_to`への最初の引数として渡されたシンボルに置き換えられます。たとえば、次のような宣言がある場合：

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

`Book`モデルの各インスタンスには、次のメソッドがあります：

* `author`
* `author=`
* `build_author`
* `create_author`
* `create_author!`
* `reload_author`
* `reset_author`
* `author_changed?`
* `author_previously_changed?`

注意：新しい`has_one`または`belongs_to`関連を初期化する場合は、`has_many`または`has_and_belongs_to_many`関連に使用される`association.build`メソッドではなく、`build_`接頭辞を使用して関連を構築する必要があります。1つ作成するには、`create_`接頭辞を使用します。

##### `association`

`association`メソッドは、関連するオブジェクト（あれば）を返します。関連するオブジェクトが見つからない場合は、`nil`を返します。

```ruby
@book.author = @author
```

このオブジェクトのために関連オブジェクトがすでにデータベースから取得されている場合、キャッシュされたバージョンが返されます。この動作をオーバーライドして（およびデータベースの読み取りを強制するために）、親オブジェクトで`#reload_association`を呼び出します。

```ruby
@book.reload_author
```

関連オブジェクトのキャッシュされたバージョンをアンロードし、次にアクセスされる場合はデータベースからクエリされるようにするには、親オブジェクトで`#reset_association`を呼び出します。

```ruby
@book.reset_author
```

##### `association=(associate)`

`association=`メソッドは、このオブジェクトに関連オブジェクトを割り当てます。内部的には、関連オブジェクトから主キーを抽出し、このオブジェクトの外部キーを同じ値に設定することを意味します。

```ruby
@book.author = @author
```

##### `build_association(attributes = {})`

`build_association`メソッドは、関連する型の新しいオブジェクトを返します。このオブジェクトは、渡された属性からインスタンス化され、このオブジェクトの外部キーを介してリンクが設定されますが、関連オブジェクトはまだ保存されません。

```ruby
@book.build_author(author_number: 123,
                   author_name: "John Doe")
```

##### `create_association(attributes = {})`

`create_association`メソッドは、関連する型の新しいオブジェクトを返します。このオブジェクトは、渡された属性からインスタンス化され、このオブジェクトの外部キーを介してリンクが設定され、関連オブジェクトが関連モデルで指定されたすべてのバリデーションを通過した場合、関連オブジェクトが保存されます。

```ruby
@book.create_author(author_number: 123,
                    author_name: "John Doe")
```

##### `create_association!(attributes = {})`

`create_association`と同様ですが、レコードが無効な場合に`ActiveRecord::RecordInvalid`を発生させます。

##### `association_changed?`

`association_changed?`メソッドは、新しい関連オブジェクトが割り当てられ、次の保存で外部キーが更新される場合にtrueを返します。
```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.author_changed? # => true

@book.save!
@book.author_changed? # => false
```

##### `association_previously_changed?`

`association_previously_changed?`メソッドは、前回の保存で関連付けが新しい関連オブジェクトを参照するように更新された場合にtrueを返します。

```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_previously_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.save!
@book.author_previously_changed? # => true
```

#### `belongs_to`のオプション

Railsはほとんどの場合にうまく機能するように、賢明なデフォルト値を使用していますが、`belongs_to`関連付けの動作をカスタマイズしたい場合があります。このようなカスタマイズは、関連付けを作成するときにオプションとスコープブロックを渡すことで簡単に行うことができます。たとえば、次のような2つのオプションを使用する関連付けです。

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at,
    counter_cache: true
end
```

[`belongs_to`][]関連付けは、次のオプションをサポートしています。

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

`:autosave`オプションを`true`に設定すると、Railsはロードされた関連メンバーを保存し、破棄されるメンバーを保存するために、親オブジェクトを保存するたびに呼び出されます。`:autosave`オプションを`false`に設定することは、`:autosave`オプションを設定しないこととは異なります。`autosave`オプションが存在しない場合、新しい関連オブジェクトは保存されますが、更新された関連オブジェクトは保存されません。

##### `:class_name`

他のモデルの名前が関連付けの名前から派生できない場合は、`class_name`オプションを使用してモデル名を指定できます。たとえば、本が著者に所属しているが、実際の著者を含むモデルの名前が`Patron`である場合、次のように設定します。

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron"
end
```

##### `:counter_cache`

`:counter_cache`オプションを使用すると、所属するオブジェクトの数を効率的に取得できます。次のモデルを考えてみましょう。

```ruby
class Book < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :books
end
```

これらの宣言では、`@author.books.size`の値を取得するには、`COUNT(*)`クエリを実行するためにデータベースに問い合わせる必要があります。この呼び出しを避けるために、所属するモデルにカウンターキャッシュを追加できます。

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end

class Author < ApplicationRecord
  has_many :books
end
```

この宣言では、Railsはキャッシュ値を最新の状態に保ち、`size`メソッドの応答としてその値を返します。

`counter_cache`オプションは、`belongs_to`宣言を含むモデルに指定されますが、実際のカラムは関連する（`has_many`）モデルに追加する必要があります。上記の場合、`Author`モデルに`books_count`という名前のカラムを追加する必要があります。

デフォルトのカラム名を上書きするには、`counter_cache`宣言で`true`の代わりにカスタムカラム名を指定します。たとえば、`books_count`の代わりに`count_of_books`を使用するには次のようにします。

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: :count_of_books
end

class Author < ApplicationRecord
  has_many :books
end
```

注意：`belongs_to`側の関連付けにのみ`counter_cache`オプションを指定する必要があります。

カウンターキャッシュカラムは、`attr_readonly`を介して所有者モデルの読み取り専用属性リストに追加されます。

所有者モデルの主キーの値を変更し、カウントされるモデルの外部キーも更新しない場合、カウンターキャッシュに古いデータが残る可能性があります。つまり、孤立したモデルもカウンターにカウントされます。古いカウンターキャッシュを修正するには、[`reset_counters`][]を使用してください。


##### `:dependent`

`:dependent`オプションを次のように設定すると：

* `:destroy`：オブジェクトが破棄されると、関連するオブジェクトに`destroy`が呼び出されます。
* `:delete`：オブジェクトが破棄されると、関連するすべてのオブジェクトがその`destroy`メソッドを呼び出さずに直接データベースから削除されます。
* `:destroy_async`：オブジェクトが破棄されると、`ActiveRecord::DestroyAssociationAsyncJob`ジョブがキューに入れられ、関連するオブジェクトに`destroy`が呼び出されます。これを動作させるには、Active Jobを設定する必要があります。データベースで外部キー制約によってバックアップされている場合は、このオプションを使用しないでください。外部キー制約のアクションは、所有者を削除するトランザクション内で発生します。
警告：`belongs_to`のオプションとして、他のクラスと`has_many`の関連付けがある場合には指定しないでください。これを行うと、データベースに孤立したレコードが残る可能性があります。

##### `:foreign_key`

Railsでは、このモデルで外部キーを保持するために使用されるカラムは、関連付けの名前に接尾辞 `_id` を追加したものと想定されます。`:foreign_key`オプションを使用すると、外部キーの名前を直接設定できます。

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                      foreign_key: "patron_id"
end
```

TIP: いずれの場合でも、Railsは外部キーカラムを自動的に作成しません。マイグレーションの一部として明示的に定義する必要があります。

##### `:primary_key`

Railsでは、テーブルの主キーとして`id`カラムが使用されると想定されています。`:primary_key`オプションを使用すると、異なるカラムを指定できます。

例えば、`users`テーブルに`guid`を主キーとして持つ場合、`todos`テーブルには`guid`カラムに外部キー`user_id`を持たせたい場合、次のように`primary_key`を使用してこれを実現できます。

```ruby
class User < ApplicationRecord
  self.primary_key = 'guid' # 主キーはidではなくguid
end

class Todo < ApplicationRecord
  belongs_to :user, primary_key: 'guid'
end
```

`@user.todos.create`を実行すると、`@todo`レコードの`user_id`の値は`@user`の`guid`の値になります。

##### `:inverse_of`

`:inverse_of`オプションは、この関連付けの逆の関連付けである`has_many`または`has_one`関連付けの名前を指定します。
詳細については、[双方向関連付け](#bi-directional-associations)セクションを参照してください。

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:polymorphic`

`:polymorphic`オプションに`true`を渡すと、これが多態性関連付けであることを示します。多態性関連付けについては、このガイドの前の部分で詳しく説明されています。

##### `:touch`

`:touch`オプションを`true`に設定すると、関連するオブジェクトの`updated_at`または`updated_on`タイムスタンプが、このオブジェクトが保存または削除されるたびに現在の時刻に設定されます。

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: true
end

class Author < ApplicationRecord
  has_many :books
end
```

この場合、本を保存または削除すると、関連する著者のタイムスタンプが更新されます。特定のタイムスタンプ属性を更新することもできます。

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at
end
```

##### `:validate`

`:validate`オプションを`true`に設定すると、新しい関連オブジェクトはこのオブジェクトを保存するときに常に検証されます。デフォルトでは、これは`false`であり、新しい関連オブジェクトはこのオブジェクトを保存するときに検証されません。

##### `:optional`

`:optional`オプションを`true`に設定すると、関連オブジェクトの存在が検証されません。デフォルトでは、このオプションは`false`に設定されています。

#### `belongs_to`のスコープ

`belongs_to`で使用されるクエリをカスタマイズしたい場合があります。このようなカスタマイズは、スコープブロックを使用して行うことができます。例えば：

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

スコープブロック内で標準の[クエリメソッド](active_record_querying.html)のいずれかを使用できます。以下では、次のものについて説明します：

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

`where`メソッドを使用すると、関連するオブジェクトが満たす必要のある条件を指定できます。

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

##### `includes`

`includes`メソッドを使用して、この関連付けが使用されるときに一緒にプリロードする必要がある2次関連付けを指定できます。例えば、次のモデルを考えてみてください：

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

頻繁にチャプターから直接著者を取得する場合（`@chapter.book.author`）、チャプターから本への関連付けに著者を含めることで、コードをより効率的にすることができます。

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

注意：直接の関連付けには`includes`を使用する必要はありません。つまり、`Book belongs_to :author`の場合、必要な時に自動的に著者がプリロードされます。

##### `readonly`

`readonly`を使用すると、関連するオブジェクトは関連付けを介して取得された場合に読み取り専用になります。
##### `select`

`select`メソッドを使用すると、関連するオブジェクトに関するデータを取得するために使用されるSQLの`SELECT`句をオーバーライドすることができます。デフォルトでは、Railsはすべての列を取得します。

TIP: `belongs_to`関連付けで`select`メソッドを使用する場合は、正しい結果を保証するために`:foreign_key`オプションも設定する必要があります。

#### 関連するオブジェクトが存在するかどうかを確認する

`association.nil?`メソッドを使用して、関連するオブジェクトが存在するかどうかを確認できます。

```ruby
if @book.author.nil?
  @msg = "この本には著者が見つかりませんでした"
end
```

#### オブジェクトはいつ保存されますか？

`belongs_to`関連付けにオブジェクトを割り当てると、オブジェクトは自動的に保存されません。関連するオブジェクトも保存されません。

### `has_one`関連付けの参照

`has_one`関連付けは、別のモデルとの1対1のマッチを作成します。データベースの用語では、この関連付けは他のクラスが外部キーを含むことを示しています。このクラスが外部キーを含む場合は、代わりに`belongs_to`を使用する必要があります。

#### `has_one`によって追加されるメソッド

`has_one`関連付けを宣言すると、宣言したクラスには自動的に関連する6つのメソッドが追加されます。

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`

これらのメソッドのすべてで、`association`は`has_one`に渡された最初の引数として渡されたシンボルで置き換えられます。たとえば、次の宣言がある場合：

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

`Supplier`モデルの各インスタンスには、次のメソッドがあります：

* `account`
* `account=`
* `build_account`
* `create_account`
* `create_account!`
* `reload_account`
* `reset_account`

NOTE: 新しい`has_one`または`belongs_to`関連付けを初期化する場合は、`association.build`メソッドではなく、関連付けをビルドするために`build_`接頭辞を使用する必要があります。作成するには、`create_`接頭辞を使用します。

##### `association`

`association`メソッドは関連するオブジェクトを返します。関連するオブジェクトが見つからない場合は`nil`を返します。

```ruby
@account = @supplier.account
```

関連するオブジェクトがこのオブジェクトのためにすでにデータベースから取得されている場合、キャッシュされたバージョンが返されます。この動作をオーバーライドして（データベースの読み取りを強制するために）、親オブジェクトで`#reload_association`を呼び出します。

```ruby
@account = @supplier.reload_account
```

関連するオブジェクトのキャッシュされたバージョンをアンロードし、次にアクセスする場合はデータベースからクエリするために、親オブジェクトで`#reset_association`を呼び出します。

```ruby
@supplier.reset_account
```

##### `association=(associate)`

`association=`メソッドは、関連するオブジェクトをこのオブジェクトに割り当てます。内部的には、このオブジェクトから主キーを抽出し、関連するオブジェクトの外部キーを同じ値に設定します。

```ruby
@supplier.account = @account
```

##### `build_association(attributes = {})`

`build_association`メソッドは、関連する型の新しいオブジェクトを返します。このオブジェクトは、渡された属性からインスタンス化され、その外部キーを介したリンクが設定されますが、関連するオブジェクトはまだ保存されません。

```ruby
@account = @supplier.build_account(terms: "Net 30")
```

##### `create_association(attributes = {})`

`create_association`メソッドは、関連する型の新しいオブジェクトを返します。このオブジェクトは、渡された属性からインスタンス化され、その外部キーを介したリンクが設定され、関連するモデルで指定されたすべてのバリデーションを通過した場合、関連するオブジェクトは保存されます。

```ruby
@account = @supplier.create_account(terms: "Net 30")
```

##### `create_association!(attributes = {})`

`create_association`と同じですが、レコードが無効な場合に`ActiveRecord::RecordInvalid`を発生させます。

#### `has_one`のオプション

Railsはほとんどの状況でうまく機能するように、賢明なデフォルト値を使用していますが、`has_one`関連付けの動作をカスタマイズしたい場合があります。このようなカスタマイズは、関連付けを作成する際にオプションを渡すことで簡単に行うことができます。たとえば、次のような2つのオプションを使用する関連付けがあります：

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing", dependent: :nullify
end
```

[`has_one`][]関連付けは、次のオプションをサポートしています：

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

`:as`オプションを設定すると、これが多態性の関連付けであることを示します。多態性の関連付けについては、[このガイドの前の部分](#polymorphic-associations)で詳しく説明されています。

##### `:autosave`

`:autosave`オプションを`true`に設定すると、Railsはロードされた関連メンバーを保存し、削除されるメンバーを保存するようにします。親オブジェクトを保存するたびに、`:autosave`オプションが`false`に設定されていない限り、新しい関連オブジェクトは保存されますが、更新された関連オブジェクトは保存されません。
##### `:class_name`

もし他のモデルの名前が関連名から導き出されない場合、`class_name`オプションを使用してモデル名を指定することができます。例えば、サプライヤーがアカウントを持っているが、実際のアカウントを含むモデルの名前が`Billing`である場合、以下のように設定します。

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing"
end
```

##### `:dependent`

所有者が破棄されたときに関連するオブジェクトに何が起こるかを制御します。

* `:destroy`は関連するオブジェクトも破棄します。
* `:delete`は関連するオブジェクトをデータベースから直接削除します（コールバックは実行されません）。
* `:destroy_async`：オブジェクトが破棄されると、`ActiveRecord::DestroyAssociationAsyncJob`ジョブがエンキューされ、関連するオブジェクトに対して破棄が呼び出されます。これを動作させるにはActive Jobを設定する必要があります。データベースに外部キー制約がある場合は、このオプションを使用しないでください。外部キー制約のアクションは、所有者を削除するトランザクション内で発生します。
* `:nullify`は外部キーを`NULL`に設定します。ポリモーフィックな関連では、ポリモーフィックなタイプのカラムも`NULL`に設定されます。コールバックは実行されません。
* `:restrict_with_exception`は関連するレコードが存在する場合に`ActiveRecord::DeleteRestrictionError`例外を発生させます。
* `:restrict_with_error`は関連オブジェクトが存在する場合にエラーを所有者に追加します。

`NOT NULL`のデータベース制約を持つ関連に対して`nullify`オプションを設定または残さないようにする必要があります。このような関連に`dependent`を破棄に設定しない場合、関連オブジェクトを変更できなくなります。なぜなら、初期の関連オブジェクトの外部キーが許可されていない`NULL`の値に設定されるからです。

##### `:foreign_key`

Railsは、他のモデルの外部キーを保持するために使用されるカラムが、このモデルの名前に接尾辞 `_id` が追加されたものであると想定しています。 `:foreign_key`オプションを使用すると、外部キーの名前を直接設定できます。

```ruby
class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
end
```

TIP: いずれの場合も、Railsは外部キーカラムを自動的に作成しません。マイグレーションの一部として明示的に定義する必要があります。

##### `:inverse_of`

`:inverse_of`オプションは、この関連の逆の`belongs_to`関連の名前を指定します。詳細については、[双方向関連](#bi-directional-associations)のセクションを参照してください。

```ruby
class Supplier < ApplicationRecord
  has_one :account, inverse_of: :supplier
end

class Account < ApplicationRecord
  belongs_to :supplier, inverse_of: :account
end
```

##### `:primary_key`

Railsは、このモデルの主キーを保持するために使用されるカラムが `id` であると想定しています。このデフォルトをオーバーライドし、`primary_key`オプションで明示的に主キーを指定できます。

##### `:source`

`:source`オプションは、`has_one :through`関連のソース関連名を指定します。

##### `:source_type`

`:source_type`オプションは、ポリモーフィックな関連を介して進行する`has_one :through`関連のソース関連タイプを指定します。

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

`:through`オプションは、クエリを実行するための結合モデルを指定します。`has_one :through`関連については、[このガイドの前の部分](#the-has-one-through-association)で詳しく説明されています。

##### `:touch`

`:touch`オプションを`true`に設定すると、このオブジェクトが保存または破棄されるたびに関連オブジェクトの`updated_at`または`updated_on`タイムスタンプが現在の時刻に設定されます。

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: true
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

この場合、サプライヤーの保存または破棄により、関連するアカウントのタイムスタンプが更新されます。特定のタイムスタンプ属性を更新することもできます。

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: :suppliers_updated_at
end
```

##### `:validate`

`:validate`オプションを`true`に設定すると、このオブジェクトを保存するときに新しい関連オブジェクトが検証されます。デフォルトでは、これは`false`です。このオブジェクトを保存するときに新しい関連オブジェクトは検証されません。

#### `has_one`のスコープ

`has_one`を使用するクエリをカスタマイズしたい場合があります。このようなカスタマイズは、スコープブロックを使用して実現できます。例えば：

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```
スコープブロック内では、標準の[クエリメソッド](active_record_querying.html)のいずれかを使用できます。以下にそれぞれについて説明します。

##### `where`

`where`メソッドを使用すると、関連するオブジェクトが満たす必要のある条件を指定できます。

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where "confirmed = 1" }
end
```

##### `includes`

`includes`メソッドを使用して、この関連が使用されるときに一緒に読み込むべき2次関連を指定できます。例えば、次のモデルを考えてみてください。

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

もし頻繁に代表者をサプライヤから直接取得する場合（`@supplier.account.representative`）、サプライヤからアカウントへの関連に代表者を含めることで、コードをより効率的にすることができます。

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

`readonly`メソッドを使用すると、関連するオブジェクトは読み取り専用になります。

##### `select`

`select`メソッドを使用すると、関連するオブジェクトのデータを取得するために使用されるSQLの`SELECT`句を上書きすることができます。デフォルトでは、Railsはすべての列を取得します。

#### 関連するオブジェクトは存在するか？

`association.nil?`メソッドを使用すると、関連するオブジェクトが存在するかどうかを確認できます。

```ruby
if @supplier.account.nil?
  @msg = "このサプライヤにはアカウントが見つかりませんでした"
end
```

#### オブジェクトはいつ保存されますか？

`has_one`関連付けにオブジェクトを割り当てると、そのオブジェクトは自動的に保存されます（外部キーを更新するため）。さらに、置き換えられるオブジェクトも自動的に保存されます。なぜなら、その外部キーも変更されるからです。

これらの保存のいずれかがバリデーションエラーにより失敗した場合、代入文は`false`を返し、代入自体はキャンセルされます。

親オブジェクト（`has_one`関連付けを宣言しているオブジェクト）が保存されていない場合（つまり、`new_record?`が`true`を返す場合）、子オブジェクトは保存されません。親オブジェクトが保存されると、子オブジェクトも自動的に保存されます。

オブジェクトを保存せずに`has_one`関連付けにオブジェクトを割り当てたい場合は、`build_association`メソッドを使用します。

### `has_many`関連付けの参照

`has_many`関連付けは、他のモデルとの一対多の関係を作成します。データベースの用語では、この関連付けは、他のクラスがこのクラスのインスタンスを参照する外部キーを持つことを意味します。

#### `has_many`によって追加されるメソッド

`has_many`関連付けを宣言すると、宣言するクラスには自動的に関連する17のメソッドが追加されます。

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

これらのメソッドのすべてで、`collection`は`has_many`に渡された最初の引数のシンボルに置き換えられ、`collection_singular`はそのシンボルの単数形に置き換えられます。例えば、次の宣言がある場合：

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

`Author`モデルの各インスタンスには、次のメソッドがあります：

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

`collection`メソッドは、関連するすべてのオブジェクトの関連を返します。関連するオブジェクトがない場合は、空の関連を返します。

```ruby
@books = @author.books
```

##### `collection<<(object, ...)`

[`collection<<`][]メソッドは、1つ以上のオブジェクトをコレクションに追加し、それらのオブジェクトの外部キーを呼び出し元モデルの主キーに設定します。

```ruby
@author.books << @book1
```

##### `collection.delete(object, ...)`

[`collection.delete`][]メソッドは、1つ以上のオブジェクトをコレクションから削除し、それらのオブジェクトの外部キーを`NULL`に設定します。

```ruby
@author.books.delete(@book1)
```

警告: `dependent: :destroy`に関連付けられている場合、オブジェクトは破棄され、`dependent: :delete_all`に関連付けられている場合は削除されます。

##### `collection.destroy(object, ...)`

[`collection.destroy`][]メソッドは、1つ以上のオブジェクトをコレクションから削除し、各オブジェクトに対して`destroy`を実行します。

```ruby
books.destroy(@book1)
```

警告: オブジェクトは常にデータベースから削除され、`:dependent`オプションは無視されます。

##### `collection=(objects)`

`collection=`メソッドは、コレクションを指定されたオブジェクトのみにするようにします。必要に応じて追加および削除が行われます。変更はデータベースに永続化されます。
##### `collection_singular_ids`

`collection_singular_ids`メソッドは、コレクション内のオブジェクトのIDの配列を返します。

```ruby
@book_ids = @author.book_ids
```

##### `collection_singular_ids=(ids)`

`collection_singular_ids=`メソッドは、指定されたプライマリキーの値で識別されるオブジェクトのみを含むコレクションを作成し、必要に応じて追加および削除を行います。変更内容はデータベースに永続化されます。

##### `collection.clear`

[`collection.clear`][]メソッドは、`dependent`オプションで指定された戦略に従って、コレクションからすべてのオブジェクトを削除します。オプションが指定されていない場合、デフォルトの戦略に従います。`has_many :through`関連のデフォルト戦略は`delete_all`であり、`has_many`関連のデフォルト戦略は外部キーを`NULL`に設定することです。

```ruby
@author.books.clear
```

警告: `dependent: :destroy`または`dependent: :destroy_async`に関連付けられているオブジェクトは削除されます。`dependent: :delete_all`と同様です。

##### `collection.empty?`

[`collection.empty?`][]メソッドは、コレクションに関連付けられたオブジェクトが存在しない場合に`true`を返します。

```erb
<% if @author.books.empty? %>
  No Books Found
<% end %>
```

##### `collection.size`

[`collection.size`][]メソッドは、コレクション内のオブジェクトの数を返します。

```ruby
@book_count = @author.books.size
```

##### `collection.find(...)`

[`collection.find`][]メソッドは、コレクションのテーブル内のオブジェクトを検索します。

```ruby
@available_book = @author.books.find(1)
```

##### `collection.where(...)`

[`collection.where`][]メソッドは、指定された条件に基づいてコレクション内のオブジェクトを検索しますが、オブジェクトは遅延ロードされるため、オブジェクトにアクセスされるとデータベースがクエリされます。

```ruby
@available_books = author.books.where(available: true) # クエリはまだ実行されていない
@available_book = @available_books.first # ここでデータベースがクエリされる
```

##### `collection.exists?(...)`

[`collection.exists?`][]メソッドは、指定された条件を満たすオブジェクトがコレクションのテーブルに存在するかどうかをチェックします。

##### `collection.build(attributes = {})`

[`collection.build`][]メソッドは、関連する型の新しいオブジェクトまたはオブジェクトの配列を返します。オブジェクトは渡された属性からインスタンス化され、外部キーを介してリンクが作成されますが、関連するオブジェクトはまだ保存されません。

```ruby
@book = author.books.build(published_at: Time.now,
                            book_number: "A12345")

@books = author.books.build([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create(attributes = {})`

[`collection.create`][]メソッドは、関連する型の新しいオブジェクトまたはオブジェクトの配列を返します。オブジェクトは渡された属性からインスタンス化され、外部キーを介してリンクが作成され、関連オブジェクトは関連モデルで指定されたすべてのバリデーションをパスした後に保存されます。

```ruby
@book = author.books.create(published_at: Time.now,
                             book_number: "A12345")

@books = author.books.create([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create!(attributes = {})`

`collection.create`と同様ですが、レコードが無効な場合に`ActiveRecord::RecordInvalid`を発生させます。

##### `collection.reload`

[`collection.reload`][]メソッドは、関連するすべてのオブジェクトのリレーションを返し、データベースの読み取りを強制します。関連するオブジェクトが存在しない場合、空のリレーションが返されます。

```ruby
@books = author.books.reload
```

#### `has_many`のオプション

Railsは、ほとんどの状況でうまく機能するように適切なデフォルトを使用しますが、`has_many`関連の動作をカスタマイズしたい場合があります。このようなカスタマイズは、関連を作成する際にオプションを渡すことで簡単に行うことができます。たとえば、次の関連は2つのオプションを使用しています。

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :delete_all, validate: false
end
```

[`has_many`][]関連は、次のオプションをサポートしています。

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

`:as`オプションを設定すると、これが多態性関連であることを示します。詳細は[このガイドの前の部分](#polymorphic-associations)で説明されています。

##### `:autosave`

`:autosave`オプションを`true`に設定すると、Railsはロードされた関連メンバーを保存し、削除がマークされたメンバーを破棄します。親オブジェクトを保存するたびに、`:autosave`オプションが`false`に設定されていない限り、新しい関連オブジェクトは保存されますが、更新された関連オブジェクトは保存されません。

##### `:class_name`

他のモデルの名前が関連名から派生できない場合、`class_name`オプションを使用してモデル名を指定できます。たとえば、著者が多数の本を持っているが、実際の本を含むモデルの名前が`Transaction`である場合、次のように設定します。

```ruby
class Author < ApplicationRecord
  has_many :books, class_name: "Transaction"
end
```

##### `:counter_cache`

このオプションは、カスタム名の `:counter_cache` を設定するために使用されます。[belongs_to association](#options-for-belongs-to)で `:counter_cache` の名前をカスタマイズした場合にのみ、このオプションが必要です。

##### `:dependent`

所有者が破棄されたときに関連するオブジェクトに何が起こるかを制御します。

* `:destroy` は、関連するすべてのオブジェクトも破棄されます
* `:delete_all` は、関連するすべてのオブジェクトがデータベースから直接削除されます（コールバックは実行されません）
* `:destroy_async`：オブジェクトが破棄されると、`ActiveRecord::DestroyAssociationAsyncJob` ジョブがキューに入れられ、関連するオブジェクトに対して破棄が呼び出されます。これを動作させるには、Active Job を設定する必要があります。
* `:nullify` は、外部キーを `NULL` に設定します。ポリモーフィック関連では、ポリモーフィックタイプカラムも `NULL` になります。コールバックは実行されません。
* `:restrict_with_exception` は、関連するレコードがある場合に `ActiveRecord::DeleteRestrictionError` 例外が発生します
* `:restrict_with_error` は、関連するオブジェクトがある場合にエラーが所有者に追加されます

`:destroy` と `:delete_all` オプションは、コレクションから削除されたときに関連するオブジェクトを破棄するように `collection.delete` と `collection=` メソッドの意味も変えます。

##### `:foreign_key`

慣例として、Railsは他のモデルの外部キーを保持するために使用されるカラムが、このモデルの名前に `_id` のサフィックスが追加されたものであると想定します。 `:foreign_key` オプションを使用すると、外部キーの名前を直接設定できます。

```ruby
class Author < ApplicationRecord
  has_many :books, foreign_key: "cust_id"
end
```

TIP: いずれの場合も、Railsは外部キーカラムを自動的に作成しません。マイグレーションの一部として明示的に定義する必要があります。

##### `:inverse_of`

`:inverse_of` オプションは、この関連の逆の `belongs_to` 関連の名前を指定します。
詳細については、[双方向関連](#bi-directional-associations)のセクションを参照してください。

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:primary_key`

慣例として、Railsは関連の主キーを保持するために使用されるカラムが `id` であると想定します。 `:primary_key` オプションを使用して、主キーを明示的に指定することもできます。

`users` テーブルには `id` が主キーとして設定されていますが、`guid` カラムも存在します。要件としては、`todos` テーブルは `guid` カラムの値を外部キーとして保持し、`id` の値ではないことです。次のように実現できます。

```ruby
class User < ApplicationRecord
  has_many :todos, primary_key: :guid
end
```

これで `@todo = @user.todos.create` を実行すると、`@todo` レコードの `user_id` の値は `@user` の `guid` の値になります。

##### `:source`

`:source` オプションは、`has_many :through` 関連のソース関連名を指定します。ソース関連の名前を自動的に推測できない場合にのみ、このオプションを使用する必要があります。

##### `:source_type`

`:source_type` オプションは、ポリモーフィック関連を介して進行する `has_many :through` 関連のソース関連タイプを指定します。

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

`:through` オプションは、クエリを実行するための結合モデルを指定します。 `has_many :through` 関連は、[このガイドの前述のセクション](#the-has-many-through-association)で説明されているように、多対多の関係を実装する方法を提供します。

##### `:validate`

`:validate` オプションを `false` に設定すると、このオブジェクトを保存するときに新しい関連オブジェクトは検証されません。デフォルトでは、新しい関連オブジェクトはこのオブジェクトが保存されるときに検証されます。

#### `has_many` のスコープ

`has_many` で使用するクエリをカスタマイズしたい場合があります。そのようなカスタマイズは、スコープブロックを使用して実現できます。例えば：

```ruby
class Author < ApplicationRecord
  has_many :books, -> { where processed: true }
end
```

スコープブロック内で、標準の[クエリメソッド](active_record_querying.html)のいずれかを使用できます。以下で説明するものがあります。

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

`where` メソッドを使用すると、関連するオブジェクトが満たす必要のある条件を指定できます。

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where "confirmed = 1" },
    class_name: "Book"
end
```
ハッシュを使用して条件を設定することもできます：

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where confirmed: true },
    class_name: "Book"
end
```

ハッシュスタイルの`where`オプションを使用すると、この関連付けを介したレコード作成は自動的にハッシュを使用してスコープが設定されます。この場合、`author.confirmed_books.create`または`author.confirmed_books.build`を使用すると、confirmed列の値が`true`である本が作成されます。

##### `extending`

`extending`メソッドは、関連付けプロキシを拡張するための名前付きモジュールを指定します。関連付けの拡張については、[このガイドの後半で詳しく説明します](#association-extensions)。

##### `group`

`group`メソッドは、検索SQLの`GROUP BY`句を使用して結果セットを属性名でグループ化します。

```ruby
class Author < ApplicationRecord
  has_many :chapters, -> { group 'books.id' },
                      through: :books
end
```

##### `includes`

`includes`メソッドを使用して、この関連付けが使用されるときに一緒にプリロードする必要がある2次関連付けを指定できます。たとえば、次のモデルを考えてみてください：

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

もしも頻繁に著者から直接チャプターを取得する場合（`author.books.chapters`）、著者から本への関連付けにチャプターを含めることで、コードをより効率的にすることができます：

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

`limit`メソッドを使用すると、関連付けを介してフェッチされるオブジェクトの総数を制限することができます。

```ruby
class Author < ApplicationRecord
  has_many :recent_books,
    -> { order('published_at desc').limit(100) },
    class_name: "Book"
end
```

##### `offset`

`offset`メソッドを使用すると、関連付けを介してオブジェクトをフェッチするための開始オフセットを指定できます。たとえば、`-> { offset(11) }`は最初の11レコードをスキップします。

##### `order`

`order`メソッドは、関連するオブジェクトが受け取られる順序を指定します（SQLの`ORDER BY`句で使用される構文）。

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order "date_confirmed DESC" }
end
```

##### `readonly`

`readonly`メソッドを使用すると、関連するオブジェクトは関連付けを介して取得されるときに読み取り専用になります。

##### `select`

`select`メソッドを使用すると、関連するオブジェクトのデータを取得するために使用されるSQLの`SELECT`句をオーバーライドできます。デフォルトでは、Railsはすべての列を取得します。

警告：独自の`select`を指定する場合は、関連するモデルの主キーと外部キーの列を含める必要があります。含めない場合、Railsはエラーをスローします。

##### `distinct`

`distinct`メソッドを使用して、コレクションに重複を含まないようにすることができます。これは主に`through`オプションと一緒に使用します。

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

上記の場合、2つの読み取りがあり、`person.articles`は同じ記事を指しているにもかかわらず、両方を表示します。

では、`distinct`を設定しましょう：

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

上記の場合、2つの読み取りがあります。ただし、`person.articles`は一意のレコードのみを表示するため、1つの記事のみが表示されます。

挿入時に永続化された関連付け内のすべてのレコードが一意であることを確認するために（関連付けを検査すると重複したレコードが見つからないことを確認できるようにするため）、テーブル自体に一意のインデックスを追加する必要があります。たとえば、`readings`という名前のテーブルがあり、記事を人に1回しか追加できないようにする場合、次のようにマイグレーションに追加できます：

```ruby
add_index :readings, [:person_id, :article_id], unique: true
```
この一意のインデックスを持っている場合、同じ記事を2回人に追加しようとすると、`ActiveRecord::RecordNotUnique`エラーが発生します。

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
ActiveRecord::RecordNotUnique
```

`include?`のようなユニーク性をチェックする方法は競合状態になりますので、関連付けでの一意性を強制するために`include?`を使用しないでください。例えば、上記の記事の例を使用して、次のコードは競合状態になる可能性があります。複数のユーザーが同時にこれを試みることができるためです。

```ruby
person.articles << article unless person.articles.include?(article)
```

#### オブジェクトはいつ保存されますか？

`has_many`関連付けにオブジェクトを割り当てると、そのオブジェクトは自動的に保存されます（外部キーを更新するため）。1つの文で複数のオブジェクトを割り当てる場合、それらはすべて保存されます。

これらの保存のいずれかが検証エラーによって失敗した場合、代入文は`false`を返し、代入自体はキャンセルされます。

親オブジェクト（`has_many`関連付けを宣言しているオブジェクト）が保存されていない場合（つまり、`new_record?`が`true`を返す場合）、追加されたときに子オブジェクトは保存されません。親が保存されると、関連付けの保存されていないメンバーは自動的に保存されます。

オブジェクトを保存せずに`has_many`関連付けにオブジェクトを割り当てたい場合は、`collection.build`メソッドを使用してください。

### `has_and_belongs_to_many`関連付けの参照

`has_and_belongs_to_many`関連付けは、別のモデルとの多対多の関係を作成します。データベースの用語では、これは各クラスを参照する外部キーを含む中間の結合テーブルを介して2つのクラスを関連付けます。

#### `has_and_belongs_to_many`によって追加されるメソッド

`has_and_belongs_to_many`関連付けを宣言すると、関連付けを持つクラスには自動的に関連するいくつかのメソッドが追加されます。

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

これらのメソッドのすべてで、`collection`は`has_and_belongs_to_many`に渡された最初の引数として渡されたシンボルに置き換えられ、`collection_singular`はそのシンボルの単数形に置き換えられます。例えば、次の宣言がある場合：

```ruby
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

`Part`モデルの各インスタンスには、次のメソッドがあります：

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

##### 追加のカラムメソッド

`has_and_belongs_to_many`関連付けの結合テーブルに、2つの外部キー以外の追加のカラムがある場合、これらのカラムはその関連付けを介して取得されたレコードの属性として追加されます。追加の属性を持つレコードは常に読み取り専用です。なぜなら、Railsはこれらの属性の変更を保存できないからです。

警告：`has_and_belongs_to_many`関連付けの結合テーブルで追加の属性を使用することは非推奨です。多対多の関係で2つのモデルを結合するテーブルでこのような複雑な動作が必要な場合は、`has_and_belongs_to_many`の代わりに`has_many :through`関連付けを使用する必要があります。

##### `collection`

`collection`メソッドは、関連するすべてのオブジェクトのRelationを返します。関連するオブジェクトがない場合、空のRelationが返されます。

```ruby
@assemblies = @part.assemblies
```

##### `collection<<(object, ...)`

[`collection<<`][]メソッドは、結合テーブルにレコードを作成することで、1つ以上のオブジェクトをコレクションに追加します。

```ruby
@part.assemblies << @assembly1
```

注意：このメソッドは`collection.concat`および`collection.push`としてもエイリアスされています。

##### `collection.delete(object, ...)`

[`collection.delete`][]メソッドは、結合テーブルから1つ以上のオブジェクトを削除することで、コレクションからオブジェクトを削除します。これによってオブジェクトは破壊されません。

```ruby
@part.assemblies.delete(@assembly1)
```

##### `collection.destroy(object, ...)`

[`collection.destroy`][]メソッドは、結合テーブルから1つ以上のオブジェクトを削除することで、コレクションからオブジェクトを削除します。これによってオブジェクトは破壊されません。

```ruby
@part.assemblies.destroy(@assembly1)
```

##### `collection=(objects)`

`collection=`メソッドは、指定されたオブジェクトのみを含むコレクションにします。必要に応じて追加と削除を行います。変更はデータベースに永続化されます。

##### `collection_singular_ids`

`collection_singular_ids`メソッドは、コレクション内のオブジェクトのIDの配列を返します。

```ruby
@assembly_ids = @part.assembly_ids
```

##### `collection_singular_ids=(ids)`

`collection_singular_ids=`メソッドは、指定された主キー値で識別されるオブジェクトのみを含むコレクションにします。必要に応じて追加と削除を行います。変更はデータベースに永続化されます。
##### `collection.clear`

[`collection.clear`][]メソッドは、結合テーブルから行を削除することで、コレクションからすべてのオブジェクトを削除します。これにより関連するオブジェクトは破棄されません。

##### `collection.empty?`

[`collection.empty?`][]メソッドは、コレクションに関連するオブジェクトが含まれていない場合に`true`を返します。

```html+erb
<% if @part.assemblies.empty? %>
  この部品はどのアセンブリにも使用されていません
<% end %>
```

##### `collection.size`

[`collection.size`][]メソッドは、コレクション内のオブジェクトの数を返します。

```ruby
@assembly_count = @part.assemblies.size
```

##### `collection.find(...)`

[`collection.find`][]メソッドは、コレクションのテーブル内のオブジェクトを検索します。

```ruby
@assembly = @part.assemblies.find(1)
```

##### `collection.where(...)`

[`collection.where`][]メソッドは、指定された条件に基づいてコレクション内のオブジェクトを検索しますが、オブジェクトは遅延ロードされます。つまり、オブジェクトにアクセスされるときにのみデータベースがクエリされます。

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

##### `collection.exists?(...)`

[`collection.exists?`][]メソッドは、指定された条件を満たすオブジェクトがコレクションのテーブルに存在するかどうかをチェックします。

##### `collection.build(attributes = {})`

[`collection.build`][]メソッドは、関連する型の新しいオブジェクトを返します。このオブジェクトは、渡された属性からインスタンス化され、結合テーブルを介したリンクが作成されますが、関連するオブジェクトはまだ保存されません。

```ruby
@assembly = @part.assemblies.build({ assembly_name: "Transmission housing" })
```

##### `collection.create(attributes = {})`

[`collection.create`][]メソッドは、関連する型の新しいオブジェクトを返します。このオブジェクトは、渡された属性からインスタンス化され、結合テーブルを介したリンクが作成され、関連するモデルで指定されたすべてのバリデーションを通過した場合、関連するオブジェクトが保存されます。

```ruby
@assembly = @part.assemblies.create({ assembly_name: "Transmission housing" })
```

##### `collection.create!(attributes = {})`

`collection.create`と同じですが、レコードが無効な場合に`ActiveRecord::RecordInvalid`を発生させます。

##### `collection.reload`

[`collection.reload`][]メソッドは、関連するすべてのオブジェクトのリレーションを返し、データベースの読み込みを強制します。関連するオブジェクトが存在しない場合は、空のリレーションを返します。

```ruby
@assemblies = @part.assemblies.reload
```

#### `has_and_belongs_to_many`のオプション

Railsは、ほとんどの場合にうまく機能するように適切なデフォルトを使用していますが、`has_and_belongs_to_many`関連付けの動作をカスタマイズしたい場合があります。このようなカスタマイズは、関連付けを作成する際にオプションを渡すことで簡単に行うことができます。たとえば、次の関連付けでは2つのオプションを使用しています。

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { readonly },
                                       autosave: true
end
```

[`has_and_belongs_to_many`][]関連付けは、次のオプションをサポートしています。

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
* `:validate`

##### `:association_foreign_key`

Railsは、他のモデルを指す外部キーを保持するために使用される結合テーブルの列が、そのモデルの名前に接尾辞 `_id` を追加したものであると想定しています。`:association_foreign_key`オプションを使用すると、外部キーの名前を直接設定できます。

TIP: `:foreign_key`と`:association_foreign_key`オプションは、多対多の自己結合を設定する場合に便利です。たとえば:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:autosave`

`:autosave`オプションを`true`に設定すると、Railsはロードされた関連メンバーを保存し、削除されるメンバーを破棄します。親オブジェクトを保存するときに、`:autosave`オプションを`false`に設定することは、`:autosave`オプションを設定しないこととは異なります。`:autosave`オプションが存在しない場合、新しい関連オブジェクトは保存されますが、更新された関連オブジェクトは保存されません。

##### `:class_name`

関連するモデルの名前が関連名から派生できない場合、`:class_name`オプションを使用してモデル名を指定できます。たとえば、部品には多くのアセンブリがあるが、アセンブリを含むモデルの実際の名前が`Gadget`である場合、次のように設定します。

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```

##### `:foreign_key`

Railsは、このモデルを指す外部キーを保持するために使用される結合テーブルの列が、このモデルの名前に接尾辞 `_id` を追加したものであると想定しています。`:foreign_key`オプションを使用すると、外部キーの名前を直接設定できます。

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:join_table`

デフォルトの結合テーブルの名前が望んでいるものではない場合、`join_table`オプションを使用してデフォルトをオーバーライドできます。
##### `:validate`

もし `:validate` オプションを `false` に設定すると、このオブジェクトを保存する際に新しい関連オブジェクトはバリデーションされません。デフォルトでは、新しい関連オブジェクトはこのオブジェクトを保存する際にバリデーションされます。

#### `has_and_belongs_to_many` のスコープ

`has_and_belongs_to_many` をカスタマイズしたい場合、スコープブロックを使用してカスタマイズすることができます。例えば:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

スコープブロック内では、標準の [クエリメソッド](active_record_querying.html) のいずれかを使用することができます。以下に説明するものを使用することができます:

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

`where` メソッドを使用すると、関連オブジェクトが満たす必要のある条件を指定することができます。

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

ハッシュを使用して条件を設定することもできます:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

ハッシュスタイルの `where` を使用する場合、この関連を介したレコードの作成は自動的にハッシュを使用してスコープが設定されます。この場合、`@parts.assemblies.create` や `@parts.assemblies.build` を使用すると、`factory` カラムの値が "Seattle" であるアセンブリが作成されます。

##### `extending`

`extending` メソッドは、関連プロキシを拡張するための名前付きモジュールを指定します。関連拡張については、[このガイドの後半で詳しく説明します](#association-extensions)。

##### `group`

`group` メソッドは、検索 SQL 内の `GROUP BY` 句を使用して結果セットを属性名でグループ化します。

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```

##### `includes`

`includes` メソッドを使用して、この関連が使用される際に一緒に読み込まれるべき二次関連を指定することができます。

##### `limit`

`limit` メソッドを使用すると、関連を通じて取得されるオブジェクトの総数を制限することができます。

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```

##### `offset`

`offset` メソッドを使用すると、関連を通じてオブジェクトを取得する際の開始オフセットを指定することができます。例えば、`offset(11)` を設定すると、最初の11レコードをスキップします。

##### `order`

`order` メソッドは、関連オブジェクトが受け取られる順序を指定します（SQL の `ORDER BY` 句で使用される構文）。

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```

##### `readonly`

`readonly` メソッドを使用すると、関連オブジェクトは関連を介して取得された際に読み取り専用になります。

##### `select`

`select` メソッドを使用すると、関連オブジェクトのデータを取得するために使用される SQL の `SELECT` 句をオーバーライドすることができます。デフォルトでは、Rails はすべてのカラムを取得します。

##### `distinct`

`distinct` メソッドを使用して、コレクションから重複を削除します。

#### オブジェクトはいつ保存されるのか？

`has_and_belongs_to_many` 関連にオブジェクトを割り当てると、そのオブジェクトは自動的に保存されます（結合テーブルを更新するため）。1つの文で複数のオブジェクトを割り当てる場合、それらはすべて保存されます。

これらの保存のいずれかがバリデーションエラーにより失敗した場合、割り当てステートメントは `false` を返し、割り当て自体はキャンセルされます。

親オブジェクト（`has_and_belongs_to_many` 関連を宣言するオブジェクト）が未保存の場合（つまり、`new_record?` が `true` を返す場合）、追加されたときに子オブジェクトは保存されません。親が保存されると、関連の未保存のメンバーは自動的に保存されます。

オブジェクトを `has_and_belongs_to_many` 関連に保存せずに割り当てる場合は、`collection.build` メソッドを使用します。

### 関連コールバック

通常のコールバックは、Active Record オブジェクトのライフサイクルにフックして、さまざまなポイントでそれらのオブジェクトと一緒に作業することができます。例えば、オブジェクトが保存される直前に何かを実行するために `:before_save` コールバックを使用することができます。

関連コールバックは通常のコールバックと似ていますが、コレクションのライフサイクルのイベントによってトリガーされます。利用可能な関連コールバックは次の4つです:

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

関連コールバックは、関連宣言にオプションを追加することで定義します。例えば:

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_credit_limit

  def check_credit_limit(book)
    # ...
  end
end
```

Rails は追加または削除されるオブジェクトをコールバックに渡します。
複数のコールバックを1つのイベントにスタックするには、配列として渡すことができます。

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

`before_add` コールバックが `:abort` をスローすると、オブジェクトはコレクションに追加されません。同様に、`before_remove` コールバックが `:abort` をスローすると、オブジェクトはコレクションから削除されません。

```ruby
# 限度額に達している場合、本は追加されません
def check_credit_limit(book)
  throw(:abort) if limit_reached?
end
```

注意：これらのコールバックは、関連付けコレクションを介して関連付けられたオブジェクトが追加または削除された場合にのみ呼び出されます。

```ruby
# `before_add` コールバックがトリガーされます
author.books << book
author.books = [book, book2]

# `before_add` コールバックはトリガーされません
book.update(author_id: 1)
```

### 関連付け拡張

Railsが関連付けプロキシオブジェクトに自動的に組み込む機能に制限されることはありません。匿名モジュールを使用してこれらのオブジェクトを拡張し、新しいファインダー、クリエーター、またはその他のメソッドを追加することもできます。例えば：

```ruby
class Author < ApplicationRecord
  has_many :books do
    def find_by_book_prefix(book_number)
      find_by(category_id: book_number[0..2])
    end
  end
end
```

多くの関連付けで共有する必要がある拡張がある場合は、名前付きの拡張モジュールを使用できます。例えば：

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

拡張は、`proxy_association` アクセサのこれらの3つの属性を使用して関連付けプロキシの内部を参照することができます：

* `proxy_association.owner` は、関連付けが一部であるオブジェクトを返します。
* `proxy_association.reflection` は、関連付けを記述するリフレクションオブジェクトを返します。
* `proxy_association.target` は、`belongs_to` または `has_one` の関連オブジェクト、または `has_many` または `has_and_belongs_to_many` の関連オブジェクトのコレクションを返します。

### 関連付け所有者を使用した関連付けスコープ

関連付けの所有者は、関連付けスコープにさらなる制御を必要とする場合に、スコープブロックに単一の引数として渡すことができます。ただし、注意点として、関連付けのプリロードは不可能になります。

```ruby
class Supplier < ApplicationRecord
  has_one :account, ->(supplier) { where active: supplier.active? }
end
```

単一テーブル継承（STI）
------------------------------

時には、異なるモデル間でフィールドと動作を共有したい場合があります。例えば、Car、Motorcycle、Bicycleモデルがあるとします。これらすべてに対して `color` と `price` フィールドといくつかのメソッドを共有したいが、それぞれに固有の動作と別々のコントローラも必要です。

まず、ベースとなるVehicleモデルを生成します：

```bash
$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}
```

"タイプ" フィールドを追加していることに注意してください。すべてのモデルが単一のデータベーステーブルに保存されるため、Railsはこのカラムに保存されるモデルの名前を保存します。この例では、これは "Car"、"Motorcycle"、または "Bicycle" になります。STIは、テーブルに "type" フィールドがないと機能しません。

次に、Vehicleから継承するCarモデルを生成します。これには、`--parent=PARENT` オプションを使用できます。これにより、指定された親から継承するモデルが生成され、同等のマイグレーションは生成されません（テーブルが既に存在するため）。

例えば、Carモデルを生成するには：

```bash
$ bin/rails generate model car --parent=Vehicle
```

生成されたモデルは次のようになります：

```ruby
class Car < Vehicle
end
```

これは、Vehicleに追加されたすべての動作がCarでも利用可能であることを意味します。関連付け、パブリックメソッドなど。

Carを作成すると、`vehicles` テーブルに "Car" が `type` フィールドとして保存されます：

```ruby
Car.create(color: 'Red', price: 10000)
```

次のSQLが生成されます：

```sql
INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

Carレコードのクエリは、車である車両のみを検索します：

```ruby
Car.all
```

次のようなクエリが実行されます：

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```

委譲されたタイプ
----------------

[`単一テーブル継承（STI）`](#単一テーブル継承sti)は、サブクラスとその属性の間にほとんどの違いがない場合に最も効果的ですが、1つのテーブルを作成するためにすべてのサブクラスの属性を含みます。

このアプローチの欠点は、テーブルが膨張することです。他の何も使用していないサブクラスに固有の属性も含まれるためです。

次の例では、同じ "Entry" クラスから継承する2つのActive Recordモデルがあります。このクラスには `subject` 属性が含まれています。
```ruby
# スキーマ: entries[ id, type, subject, created_at, updated_at]
class Entry < ApplicationRecord
end

class Comment < Entry
end

class Message < Entry
end
```

`delegated_type`を使用することで、この問題を解決できます。

デリゲートされたタイプを使用するためには、データを特定の方法でモデル化する必要があります。要件は以下の通りです。

* スーパークラスが、そのテーブルにおけるすべてのサブクラス間で共有される属性を格納する。
* 各サブクラスは、スーパークラスを継承し、それに固有の追加属性のために別のテーブルを持つ必要がある。

これにより、意図しない形ですべてのサブクラス間で共有される属性を単一のテーブルに定義する必要がなくなります。

上記の例にこれを適用するために、モデルを再生成する必要があります。
まず、スーパークラスとして機能する基本的な`Entry`モデルを生成しましょう。

```bash
$ bin/rails generate model entry entryable_type:string entryable_id:integer
```

次に、デリゲーションのための新しい`Message`と`Comment`モデルを生成します。

```bash
$ bin/rails generate model message subject:string body:string
$ bin/rails generate model comment content:string
```

ジェネレータを実行した後、次のようなモデルが生成されます。

```ruby
# スキーマ: entries[ id, entryable_type, entryable_id, created_at, updated_at ]
class Entry < ApplicationRecord
end

# スキーマ: messages[ id, subject, body, created_at, updated_at ]
class Message < ApplicationRecord
end

# スキーマ: comments[ id, content, created_at, updated_at ]
class Comment < ApplicationRecord
end
```

### `delegated_type`の宣言

まず、スーパークラスの`Entry`で`delegated_type`を宣言します。

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
end
```

`entryable`パラメータは、デリゲーションに使用するフィールドを指定し、`Message`と`Comment`をデリゲートクラスとして含めます。

`Entry`クラスには`entryable_type`と`entryable_id`のフィールドがあります。これは、`delegated_type`の定義で`entryable`の名前に`_type`、`_id`の接尾辞が追加されたフィールドです。
`entryable_type`はデリゲート先のサブクラスの名前を格納し、`entryable_id`はデリゲート先のサブクラスのレコードIDを格納します。

次に、モジュールを定義してデリゲートされたタイプを実装する必要があります。これは、`has_one`関連付けに`as: :entryable`パラメータを宣言することで行います。

```ruby
module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

そして、作成したモジュールをサブクラスに含めます。

```ruby
class Message < ApplicationRecord
  include Entryable
end

class Comment < ApplicationRecord
  include Entryable
end
```

この定義が完了すると、`Entry`デリゲータは次のメソッドを提供します。

| メソッド | 戻り値 |
|---|---|
| `Entry#entryable_class` | MessageまたはComment |
| `Entry#entryable_name` | "message"または"comment" |
| `Entry.messages` | `Entry.where(entryable_type: "Message")` |
| `Entry#message?` | `entryable_type == "Message"`の場合にtrueを返す |
| `Entry#message` | `entryable_type == "Message"`の場合にメッセージレコードを返し、それ以外の場合は`nil`を返す |
| `Entry#message_id` | `entryable_type == "Message"`の場合に`entryable_id`を返し、それ以外の場合は`nil`を返す |
| `Entry.comments` | `Entry.where(entryable_type: "Comment")` |
| `Entry#comment?` | `entryable_type == "Comment"`の場合にtrueを返す |
| `Entry#comment` | `entryable_type == "Comment"`の場合にコメントレコードを返し、それ以外の場合は`nil`を返す |
| `Entry#comment_id` | `entryable_type == "Comment"`の場合に`entryable_id`を返し、それ以外の場合は`nil`を返す |

### オブジェクトの作成

新しい`Entry`オブジェクトを作成する際に、同時に`entryable`サブクラスを指定できます。

```ruby
Entry.create! entryable: Message.new(subject: "hello!")
```

### 追加のデリゲーションの追加

`Entry`デリゲータを拡張し、`delegates`を定義してサブクラスへのポリモーフィズムを使用してさらに強化することができます。
例えば、`Entry`からサブクラスへの`title`メソッドのデリゲートを定義する場合は次のようにします。

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
