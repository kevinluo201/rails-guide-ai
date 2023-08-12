**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b2cb0ab668ead9e8bd48cbd1bcac9b59
Active Recordの基礎
====================

このガイドはActive Recordの紹介です。

このガイドを読み終えると、以下のことがわかります：

* オブジェクトリレーショナルマッピングとActive Recordが何であり、Railsでどのように使用されるか。
* Active Recordがモデル-ビュー-コントローラーパラダイムにどのようにフィットするか。
* Active Recordモデルを使用してリレーショナルデータベースに格納されたデータを操作する方法。
* Active Recordスキーマの命名規則。
* データベースマイグレーション、バリデーション、コールバック、および関連の概念。

--------------------------------------------------------------------------------

Active Recordとは何ですか？
----------------------

Active Recordは[MVC][]のMであり、ビジネスデータとロジックを表すシステムのレイヤーであるモデルです。Active Recordは、永続的なストレージをデータに必要とするビジネスオブジェクトの作成と使用を容易にします。これは、Active Recordパターンの実装であり、それ自体がオブジェクトリレーショナルマッピングシステムの説明です。

### Active Recordパターン

[Active Recordは、Martin Fowlerの書籍「Patterns of Enterprise Application Architecture」で説明されています][MFAR]。Active Recordでは、オブジェクトは永続的なデータとそのデータに対して動作する振る舞いを持っています。Active Recordは、データアクセスロジックをオブジェクトの一部として確保することで、そのオブジェクトのユーザーにデータベースへの書き込みと読み取りの方法を教育するという意見を持っています。

### オブジェクトリレーショナルマッピング

[オブジェクトリレーショナルマッピング][ORM]（ORMとしても知られています）は、アプリケーションの豊かなオブジェクトをリレーショナルデータベース管理システムのテーブルに接続する技術です。ORMを使用すると、アプリケーションのオブジェクトのプロパティや関係をSQL文を直接書かずに簡単にデータベースに保存および取得することができます。

注意：リレーショナルデータベース管理システム（RDBMS）と構造化クエリ言語（SQL）の基本知識は、Active Recordを完全に理解するために役立ちます。詳細については、[このチュートリアル][sqlcourse]（または[このチュートリアル][rdbmsinfo]）を参照するか、他の手段で学習してください。

### ORMフレームワークとしてのActive Record

Active Recordには、次のようないくつかのメカニズムがありますが、最も重要なのは次の能力です：

* モデルとそのデータを表現すること。
* これらのモデル間の関連を表現すること。
* 関連するモデルを介した継承階層を表現すること。
* データベースに永続化される前にモデルを検証すること。
* オブジェクト指向のスタイルでデータベース操作を実行すること。

Active Recordにおける設定の規約
----------------------------------------------

他のプログラミング言語やフレームワークを使用してアプリケーションを作成する場合、多くの設定コードを記述する必要がある場合があります。これは、一般的にORMフレームワークに当てはまります。ただし、Railsが採用している規約に従う場合、Active Recordモデルを作成する際には非常に少ない設定（場合によってはまったく設定不要）しか必要ありません。アイデアは、ほとんどの場合にアプリケーションを同じように設定する場合は、これがデフォルトの方法であるべきだということです。したがって、標準の規約に従えない場合にのみ、明示的な設定が必要になります。

### 命名規則

デフォルトでは、Active Recordはいくつかの命名規則を使用して、モデルとデータベーステーブルのマッピング方法を判断します。Railsはクラス名を複数形にして対応するデータベーステーブルを見つけます。したがって、クラス`Book`にはデータベーステーブルが**books**という名前である必要があります。Railsの複数形化の仕組みは非常に強力であり、通常の単語と非規則的な単語の両方を複数形にすることができます。2つ以上の単語で構成されるクラス名を使用する場合、モデルクラス名はRubyの規則に従い、CamelCase形式を使用する必要がありますが、テーブル名はsnake_case形式を使用する必要があります。例：

* モデルクラス - 各単語の最初の文字を大文字にした単数形（例：`BookClub`）。
* データベーステーブル - 単語をアンダースコアで区切った複数形（例：`book_clubs`）。

| モデル / クラス    | テーブル / スキーマ |
| ---------------- | -------------- |
| `Article`        | `articles`     |
| `LineItem`       | `line_items`   |
| `Deer`           | `deers`        |
| `Mouse`          | `mice`         |
| `Person`         | `people`       |

### スキーマの規約

Active Recordは、データベーステーブルの列に対して命名規則を使用します。これらの列の目的に応じて異なる命名規則があります。

* **外部キー** - これらのフィールドは、`singularized_table_name_id`（例：`item_id`、`order_id`）というパターンに従って名前を付ける必要があります。これらは、モデル間の関連を作成する際にActive Recordが探すフィールドです。
* **主キー** - デフォルトでは、Active Recordは`id`という名前の整数列をテーブルの主キーとして使用します（PostgreSQLとMySQLでは`bigint`、SQLiteでは`integer`）。[Active Record Migrations](active_record_migrations.html)を使用してテーブルを作成する場合、この列は自動的に作成されます。
Active Recordのインスタンスに追加の機能を追加するいくつかのオプションの列名もあります。

* `created_at` - レコードが最初に作成されたときに現在の日付と時刻に自動的に設定されます。
* `updated_at` - レコードが作成または更新されるたびに現在の日付と時刻に自動的に設定されます。
* `lock_version` - モデルに[楽観的ロック](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html)を追加します。
* `type` - モデルが[単一テーブル継承](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance)を使用することを指定します。
* `(association_name)_type` - [多態性関連](association_basics.html#polymorphic-associations)のタイプを格納します。
* `(table_name)_count` - 関連するオブジェクトの数をキャッシュするために使用されます。たとえば、`Comment`のインスタンスを多数持つ`Article`クラスの`comments_count`列は、各記事の存在するコメントの数をキャッシュします。

注意: これらの列名はオプションですが、実際にはActive Recordによって予約されています。余分な機能を必要としない限り、予約されたキーワードを避けてください。たとえば、`type`は単一テーブル継承（STI）を使用してテーブルを指定するための予約キーワードです。STIを使用していない場合は、データモデリングを正確に説明する類似のキーワード（例：「context」）を試してみてください。

Active Recordモデルの作成
-----------------------------

アプリケーションを生成すると、`app/models/application_record.rb`に抽象的な`ApplicationRecord`クラスが作成されます。これはアプリ内のすべてのモデルの基本クラスであり、通常のRubyクラスをActive Recordモデルに変換します。

Active Recordモデルを作成するには、`ApplicationRecord`クラスをサブクラス化してください。

```ruby
class Product < ApplicationRecord
end
```

これにより、`Product`モデルが作成され、データベースの`products`テーブルにマッピングされます。これにより、そのテーブルの各行の列をモデルのインスタンスの属性とマッピングすることもできます。たとえば、`products`テーブルが次のようなSQL（またはその拡張）ステートメントを使用して作成されたとします。

```sql
CREATE TABLE products (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
);
```

上記のスキーマは、`id`と`name`の2つの列を持つテーブルを宣言しています。このテーブルの各行は、これらの2つのパラメータを持つ特定の製品を表します。したがって、次のようなコードを書くことができます。

```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

命名規則のオーバーライド
---------------------------------

異なる命名規則に従う必要がある場合や、Railsアプリケーションをレガシーデータベースで使用する必要がある場合はどうすればよいでしょうか？問題ありません、デフォルトの規則を簡単にオーバーライドできます。

`ApplicationRecord`は`ActiveRecord::Base`を継承しているため、アプリケーションのモデルには多くの便利なメソッドが利用できます。たとえば、`ActiveRecord::Base.table_name=`メソッドを使用して使用するテーブル名をカスタマイズできます。

```ruby
class Product < ApplicationRecord
  self.table_name = "my_products"
end
```

これを行う場合、テスト定義で`set_fixture_class`メソッドを使用してフィクスチャ（`my_products.yml`）をホストするクラス名を手動で定義する必要があります。

```ruby
# test/models/product_test.rb
class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
  # ...
end
```

また、`ActiveRecord::Base.primary_key=`メソッドを使用してテーブルの主キーとして使用する列をオーバーライドすることもできます。

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

注意: **Active Recordは、主キー以外の列に`id`という名前を使用することはサポートしていません。**

注意: 主キーではない`id`という名前の列を作成しようとすると、Railsは次のようなマイグレーション中にエラーをスローします。
`you can't redefine the primary key column 'id' on 'my_products'.`
`To define a custom primary key, pass { id: false } to create_table.`

CRUD: データの読み書き
------------------------------

CRUDは、データを操作するために使用する4つの動詞の頭文字です: **C**reate（作成）、**R**ead（読み取り）、**U**pdate（更新）、**D**elete（削除）。Active Recordは、テーブル内に格納されたデータを読み取り、操作するためのメソッドを自動的に作成します。

### Create（作成）

Active Recordオブジェクトは、ハッシュ、ブロック、または作成後に属性を手動で設定することによって作成できます。`new`メソッドは新しいオブジェクトを返し、`create`はオブジェクトを作成してデータベースに保存します。

たとえば、属性`name`と`occupation`を持つ`User`モデルがある場合、`create`メソッド呼び出しは新しいレコードをデータベースに作成して保存します。

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```
`new`メソッドを使用すると、オブジェクトを保存せずにインスタンス化することができます。

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

`user.save`を呼び出すと、レコードがデータベースにコミットされます。

最後に、ブロックが提供された場合、`create`と`new`の両方が新しいオブジェクトをそのブロックに初期化するために使用されますが、`create`のみが結果のオブジェクトをデータベースに永続化します。

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### Read

Active Recordは、データベース内のデータにアクセスするための豊富なAPIを提供します。以下は、Active Recordが提供するさまざまなデータアクセスメソッドの例です。

```ruby
# すべてのユーザーのコレクションを返す
users = User.all
```

```ruby
# 最初のユーザーを返す
user = User.first
```

```ruby
# 名前がDavidの最初のユーザーを返す
david = User.find_by(name: 'David')
```

```ruby
# 名前がDavidで職業がCode Artistのユーザーをすべて検索し、created_atで逆の時系列順に並べ替える
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

Active Recordモデルのクエリについて詳しくは、[Active Record Query Interface](active_record_querying.html)ガイドを参照してください。

### Update

Active Recordオブジェクトを取得した後、その属性を変更してデータベースに保存することができます。

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

属性を一度に複数更新する場合は、属性名を所望の値にマッピングするハッシュを使用すると便利です。

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

これは、複数の属性を更新する場合に最も便利です。

コールバックやバリデーションを行わずに複数のレコードを一括で更新する場合は、`update_all`を使用してデータベースを直接更新できます。

```ruby
User.update_all max_login_attempts: 3, must_change_password: true
```

### Delete

同様に、取得したActive Recordオブジェクトは破棄することができ、それによりデータベースから削除されます。

```ruby
user = User.find_by(name: 'David')
user.destroy
```

複数のレコードを一括で削除する場合は、`destroy_by`または`destroy_all`メソッドを使用できます。

```ruby
# 名前がDavidのすべてのユーザーを検索して削除する
User.destroy_by(name: 'David')

# すべてのユーザーを削除する
User.destroy_all
```

バリデーション
-----------

Active Recordを使用すると、データベースに書き込む前にモデルの状態を検証することができます。モデルをチェックし、属性の値が空でないこと、一意であり、すでにデータベースに存在しないこと、特定の形式に従っていることなどを検証するために使用できるいくつかのメソッドがあります。

`save`、`create`、`update`などのメソッドは、モデルをデータベースに永続化する前に検証を行います。モデルが無効な場合、これらのメソッドは`false`を返し、データベース操作は実行されません。これらのメソッドには、バリデーションが失敗した場合に`ActiveRecord::RecordInvalid`例外を発生させるより厳しいバージョン（`save!`、`create!`、`update!`）もあります。以下は簡単な例です。

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

バリデーションについて詳しくは、[Active Record Validations
guide](active_record_validations.html)を参照してください。

コールバック
---------

Active Recordコールバックを使用すると、モデルのライフサイクルの特定のイベントにコードを関連付けることができます。これにより、新しいレコードを作成、更新、削除するときなど、これらのイベントが発生したときにコードを実行してモデルに動作を追加することができます。

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

コールバックについて詳しくは、[Active Record Callbacks
guide](active_record_callbacks.html)を参照してください。

マイグレーション
----------

Railsは、マイグレーションを介してデータベーススキーマの変更を管理する便利な方法を提供します。マイグレーションは、ドメイン固有の言語で記述され、Active Recordがサポートするデータベースに対して実行されるファイルに保存されます。

以下は、`publications`という新しいテーブルを作成するマイグレーションの例です。

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

上記のコードはデータベースに依存しないため、MySQL、PostgreSQL、SQLiteなどで実行されます。

Railsは、どのマイグレーションがデータベースにコミットされたかを追跡し、同じデータベース内の隣接するテーブルでそれらを保存します。テーブルの名前は`schema_migrations`です。
マイグレーションを実行してテーブルを作成するには、`bin/rails db:migrate`を実行します。テーブルをロールバックして削除するには、`bin/rails db:rollback`を実行します。

マイグレーションについては、[Active Recordマイグレーションガイド](active_record_migrations.html)で詳細を学ぶことができます。

関連付け
------------

Active Recordの関連付けを使用すると、モデル間の関係を定義することができます。関連付けは、一対一、一対多、多対多の関係を記述するために使用できます。たとえば、「Authorは多くのBooksを持つ」という関係は、次のように定義できます。

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

Authorクラスには、著者に本を追加したり削除したりするためのメソッドなどが追加されます。

関連付けについては、[Active Record関連付けガイド](association_basics.html)で詳細を学ぶことができます。
[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[MFAR]: https://www.martinfowler.com/eaaCatalog/activeRecord.html
[ORM]: https://en.wikipedia.org/wiki/Object-relational_mapping
[sqlcourse]: https://www.khanacademy.org/computing/computer-programming/sql
[rdbmsinfo]: https://www.devart.com/what-is-rdbms/
