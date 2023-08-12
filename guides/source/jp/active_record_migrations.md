**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 311d5225fa32d069369256501f31c507
Active Record Migrations
========================

マイグレーションは、Active Recordの機能であり、データベーススキーマを時間とともに進化させることができます。純粋なSQLではなく、RubyのDSLを使用してテーブルの変更を記述することができます。

このガイドを読むことで、以下のことがわかります。

* 作成するために使用できるジェネレーター。
* データベースを操作するためにActive Recordが提供するメソッド。
* マイグレーションとスキーマを操作するためのrailsコマンド。
* マイグレーションと`schema.rb`の関係。

--------------------------------------------------------------------------------

マイグレーションの概要
------------------

マイグレーションは、一貫した方法でデータベーススキーマを時間とともに変更する便利な方法です。RubyのDSLを使用してSQLを手動で書く必要がないため、スキーマと変更はデータベースに依存しないようになります。

各マイグレーションをデータベースの新しい「バージョン」と考えることができます。スキーマは何も含まれていない状態で始まり、各マイグレーションはテーブル、列、またはエントリを追加または削除してスキーマを変更します。Active Recordは、データベースの最新バージョンにスキーマを更新する方法を知っています。また、`db/schema.rb`ファイルもデータベースの最新の構造に合わせて更新します。

以下はマイグレーションの例です。

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

このマイグレーションは、`products`というテーブルを追加し、`name`という文字列の列と`description`というテキストの列を追加します。`id`という主キー列も暗黙的に追加されます。これはすべてのActive Recordモデルのデフォルトの主キーです。`timestamps`マクロは、`created_at`と`updated_at`という2つの列を追加します。これらの特別な列は、存在する場合にActive Recordによって自動的に管理されます。

前進する変更を定義することに注意してください。このマイグレーションが実行される前にはテーブルは存在しません。実行後、テーブルが存在します。Active Recordは、このマイグレーションを逆にする方法も知っています。このマイグレーションをロールバックすると、テーブルが削除されます。

スキーマを変更するステートメントをトランザクションでサポートしているデータベースでは、各マイグレーションはトランザクションでラップされます。データベースがこれをサポートしていない場合、マイグレーションが失敗した場合、成功した部分はロールバックされません。手動で変更をロールバックする必要があります。

注意: トランザクション内で実行できないクエリがあります。アダプタがDDLトランザクションをサポートしている場合は、単一のマイグレーションでそれらを無効にするために`disable_ddl_transaction!`を使用できます。

### 反転不可能な操作を可能にする

Active Recordが逆にする方法を知らないマイグレーションを実行する場合は、`reversible`を使用できます。

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

このマイグレーションは、`price`列の型を文字列に変更し、マイグレーションが元に戻されると整数に戻します。`direction.up`と`direction.down`に渡されるブロックに注目してください。

または、`change`の代わりに`up`と`down`を使用することもできます。

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

INFO: [`reversible`](#using-reversible)についての詳細は後述します。

マイグレーションの生成
----------------------

### スタンドアロンなマイグレーションの作成

マイグレーションは、`db/migrate`ディレクトリにファイルとして保存されます。各マイグレーションクラスごとに1つのファイルがあります。ファイルの名前は`YYYYMMDDHHMMSS_create_products.rb`の形式です。つまり、マイグレーションを識別するUTCタイムスタンプの後にアンダースコアが続き、マイグレーションの名前が続きます。たとえば、`20080906120000_create_products.rb`は`CreateProducts`クラスを定義し、`20080906120001_add_details_to_products.rb`は`AddDetailsToProducts`を定義する必要があります。Railsはこのタイムスタンプを使用して、実行するべきマイグレーションとその順序を決定します。したがって、他のアプリケーションからマイグレーションをコピーするか、自分でファイルを生成する場合は、その順序に注意してください。

もちろん、タイムスタンプを計算するのは楽しくありませんので、Active Recordはそれを作成するためのジェネレータを提供しています。

```bash
$ bin/rails generate migration AddPartNumberToProducts
```
これにより、適切な名前の空のマイグレーションが作成されます。

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
  end
end
```

このジェネレータは、ファイル名にタイムスタンプを前置するだけでなく、さらに多くのことができます。
命名規則と追加の（オプションの）引数に基づいて、マイグレーションを詳細化することもできます。

### 新しい列の追加

マイグレーション名が「AddColumnToTable」または「RemoveColumnFromTable」の形式であり、
列名と型のリストが続く場合、[`add_column`][]および[`remove_column`][]ステートメントを含むマイグレーションが作成されます。

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

これにより、次のマイグレーションが生成されます。

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
  end
end
```

新しい列にインデックスを追加する場合も同様に行うことができます。

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

これにより、適切な[`add_column`][]および[`add_index`][]ステートメントが生成されます。

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

魔法のように生成される列は1つに制限されません。例えば：

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

これにより、スキーママイグレーションが生成され、`products`テーブルに2つの追加の列が追加されます。

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

### 列の削除

同様に、コマンドラインから列を削除するマイグレーションを生成することもできます。

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

これにより、適切な[`remove_column`][]ステートメントが生成されます。

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :part_number, :string
  end
end
```

### 新しいテーブルの作成

マイグレーション名が「CreateXXX」の形式であり、列名と型のリストが続く場合、テーブルXXXを作成し、
リストされた列を持つマイグレーションが生成されます。例えば：

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```

これにより、次のマイグレーションが生成されます。

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

いつものように、生成されたものは出発点に過ぎません。
`db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb`ファイルを編集して、必要に応じて追加または削除することができます。

### 参照を使用した関連の作成

また、ジェネレータは列の型として`references`（または`belongs_to`としても利用可能）を受け入れます。例えば、

```bash
$ bin/rails generate migration AddUserRefToProducts user:references
```

次の[`add_reference`][]呼び出しが生成されます。

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

このマイグレーションは`user_id`列を作成します。[参照](#references)は、列、インデックス、外部キー、または多態性の関連列を作成するための省略形です。

また、`JoinTable`が名前の一部である場合、ジョインテーブルを生成するジェネレータもあります。

```bash
$ bin/rails generate migration CreateJoinTableCustomerProduct customer product
```

次のマイグレーションが生成されます。

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


### モデルジェネレータ

モデル、リソース、およびスキャフォールドジェネレータは、新しいモデルを追加するために適切なマイグレーションを作成します。
このマイグレーションには、関連するテーブルを作成するための手順も含まれています。欲しい列をRailsに伝えると、
これらの列を追加するためのステートメントも作成されます。例えば、次のコマンドを実行すると：

```bash
$ bin/rails generate model Product name:string description:text
```

次のようなマイグレーションが作成されます。

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

列名/型のペアを追加することができます。

### 修飾子の指定

一部のよく使用される[type modifiers](#column-modifiers)は、コマンドラインで直接指定することができます。これらは波括弧で囲まれ、フィールドの型に続きます。

例えば、次のコマンドを実行すると：

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

次のようなマイグレーションが作成されます。

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

TIP: ジェネレータのヘルプ出力（`bin/rails generate --help`）を参照して、詳細を確認してください。

マイグレーションの作成
------------------

ジェネレータのいずれかを使用してマイグレーションを作成したら、作業を開始する時が来ました！

### テーブルの作成

[`create_table`][]メソッドは、最も基本的なメソッドの1つですが、ほとんどの場合、
モデル、リソース、またはスキャフォールドジェネレータを使用して生成されます。典型的な使用方法は、

```ruby
create_table :products do |t|
  t.string :name
end
```

このメソッドは、`name`というカラムを持つ`products`テーブルを作成します。

デフォルトでは、`create_table`は暗黙的に`id`という主キーを作成します。
`primary_key`オプションを使用してカラムの名前を変更することもできます。
または、主キーを使用しない場合は、`id: false`オプションを渡すこともできます。

データベース固有のオプションを渡す必要がある場合は、`options`オプションにSQLフラグメントを配置することができます。例えば：

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

これにより、テーブルを作成するために使用されるSQLステートメントに`ENGINE=BLACKHOLE`が追加されます。

`create_table`ブロック内で作成されたカラムには、`index: true`またはオプションハッシュを`index`オプションに渡すことでインデックスを作成することができます。

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

また、`comment`オプションを使用して、データベース自体に保存され、MySQL WorkbenchやPgAdmin IIIなどのデータベース管理ツールで表示できるテーブルの説明を指定することもできます。大規模なデータベースを持つアプリケーションでは、データモデルを理解し、ドキュメントを生成するのに役立つため、マイグレーションでコメントを指定することを強くお勧めします。現在、MySQLとPostgreSQLのアダプタのみがコメントをサポートしています。


### 結合テーブルの作成

マイグレーションメソッド[`create_join_table`][]は、HABTM（has and belongs to many）結合テーブルを作成します。典型的な使用例は次のとおりです。

```ruby
create_join_table :products, :categories
```

このマイグレーションは、`categories_products`という2つのカラム`category_id`と`product_id`を持つテーブルを作成します。

これらのカラムは、デフォルトで`null`オプションが`false`に設定されているため、このテーブルにレコードを保存するためには値を指定する必要があります。`column_options`オプションを指定することで、これを上書きすることができます。

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

デフォルトでは、`create_join_table`の最初の2つの引数の結合で結合テーブルの名前が決まります。

テーブルの名前をカスタマイズするには、`table_name`オプションを指定します。

```ruby
create_join_table :products, :categories, table_name: :categorization
```

これにより、結合テーブルの名前が要求されたように`categorization`になります。

また、`create_join_table`はブロックを受け入れることができます。このブロックを使用して、デフォルトでは作成されないインデックスや任意の追加のカラムを追加することができます。

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```


### テーブルの変更

既存のテーブルを変更する場合は、[`change_table`][]を使用します。

これは`create_table`と同様の方法で使用されますが、ブロック内で利用可能な特殊な関数にアクセスできます。例えば：

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

このマイグレーションでは、`description`と`name`のカラムを削除し、`part_number`という新しい文字列カラムを作成し、それにインデックスを追加します。最後に、`upccode`カラムを`upc_code`に名前変更します。


### カラムの変更

`remove_column`メソッドと`add_column`メソッドと同様に、Railsは[`change_column`][]マイグレーションメソッドも提供しています。

```ruby
change_column :products, :part_number, :text
```

これにより、`products`テーブルの`part_number`カラムが`text`フィールドに変更されます。

注意：`change_column`コマンドは**元に戻せない**です。
元に戻せるマイグレーションを自分で提供する必要があります。前述のように。

`change_column`の他にも、[`change_column_null`][]と[`change_column_default`][]メソッドが、カラムの`null`制約とデフォルト値を変更するために特に使用されます。

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

これにより、`products`の`name`フィールドが`NOT NULL`カラムに設定され、`approved`フィールドのデフォルト値がtrueからfalseに変更されます。これらの変更は将来のトランザクションにのみ適用され、既存のレコードには適用されません。

null制約をtrueに設定すると、カラムはnull値を受け入れることを意味します。それ以外の場合は、`NOT NULL`制約が適用され、レコードをデータベースに永続化するために値を渡す必要があります。

注意：上記の`change_column_default`マイグレーションを`change_column_default :products, :approved, false`と書くこともできますが、前の例とは異なり、この方法ではマイグレーションを元に戻せなくなります。


### カラム修飾子

カラムを作成または変更する際に、カラム修飾子を適用することができます。

* `comment`：カラムにコメントを追加します。
* `collation`：`string`または`text`カラムの照合順序を指定します。
* `default`：カラムにデフォルト値を設定します。動的な値（日付など）を使用している場合は、デフォルト値は最初の一度だけ計算されます（つまり、マイグレーションが適用された日に計算されます）。`NULL`の場合は`nil`を使用します。
* `limit`：`string`カラムの最大文字数、および`text/binary/integer`カラムの最大バイト数を設定します。
* `null`：カラムで`NULL`値を許可または拒否します。
* `precision`：`decimal/numeric/datetime/time`カラムの精度を指定します。
* `scale`：`decimal`および`numeric`カラムのスケールを指定します。これは小数点以下の桁数を表します。
注意：`add_column`または`change_column`にはインデックスを追加するオプションはありません。
インデックスは`add_index`を使用して別途追加する必要があります。

一部のアダプタは追加のオプションをサポートしている場合があります。詳細については、アダプタ固有のAPIドキュメントを参照してください。

注意：マイグレーションを生成する際には、`null`と`default`はコマンドラインで指定できません。

### 参照

`add_reference`メソッドを使用すると、1つ以上の関連付けの間の接続として適切に名前付けられた列を作成できます。

```ruby
add_reference :users, :role
```

このマイグレーションは、usersテーブルに`role_id`列を作成します。`index: false`オプションで明示的に指定しない限り、この列に対してもインデックスが作成されます。

INFO: 詳細については、[Active Record Associations][]ガイドを参照してください。

`add_belongs_to`メソッドは`add_reference`のエイリアスです。

```ruby
add_belongs_to :taggings, :taggable, polymorphic: true
```

polymorphicオプションにより、taggingsテーブルにポリモーフィック関連付けに使用できる2つの列、`taggable_type`と`taggable_id`が作成されます。

INFO: [polymorphic associations][]について詳しくは、このガイドを参照してください。

`foreign_key`オプションを使用して外部キーを作成できます。

```ruby
add_reference :users, :role, foreign_key: true
```

`add_reference`のその他のオプションについては、[APIドキュメント](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference)を参照してください。

参照は次のように削除することもできます。

```ruby
remove_reference :products, :user, foreign_key: true, index: false
```

[Active Record Associations]: association_basics.html
[polymorphic associations]: association_basics.html#polymorphic-associations

### 外部キー

必須ではありませんが、[参照整合性を保証するために外部キー制約を追加することがあります](#active-record-and-referential-integrity)。

```ruby
add_foreign_key :articles, :authors
```

この[`add_foreign_key`][]呼び出しは、`articles`テーブルに新しい制約を追加します。この制約は、`articles.author_id`が一致する`authors`テーブルの行が存在することを保証します。

`from_table`の列名が`to_table`の名前から派生できない場合は、`column`オプションを使用できます。参照される主キーが`id`でない場合は、`primary_key`オプションを使用します。

例えば、`articles.reviewer`が`authors.email`を参照する外部キーを追加する場合：

```ruby
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

これにより、`articles`テーブルに、`articles.reviewer`フィールドと一致する`authors`テーブルの`email`列が存在することを保証する制約が追加されます。

`add_foreign_key`では、`name`、`on_delete`、`if_not_exists`、`validate`、`deferrable`などの他のオプションもサポートされています。

[`remove_foreign_key`][]を使用して外部キーを削除することもできます。

```ruby
# Active Recordに列名を推測させる
remove_foreign_key :accounts, :branches

# 特定の列の外部キーを削除する
remove_foreign_key :accounts, column: :owner_id
```

注意：Active Recordは単一列の外部キーのみをサポートしています。複合外部キーを使用するには、`execute`および`structure.sql`が必要です。[Schema Dumping and You](#schema-dumping-and-you)を参照してください。

### ヘルパーだけでは十分でない場合

Active Recordが提供するヘルパーが十分でない場合は、[`execute`][]メソッドを使用して任意のSQLを実行できます。

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

個々のメソッドの詳細と例については、APIドキュメントを確認してください。

特に、[`ActiveRecord::ConnectionAdapters::SchemaStatements`][]のドキュメントでは、`change`、`up`、`down`メソッドで使用できるメソッドが提供されています。

`create_table`で生成されるオブジェクトに関するメソッドについては、[`ActiveRecord::ConnectionAdapters::TableDefinition`][]を参照してください。

`change_table`で生成されるオブジェクトについては、[`ActiveRecord::ConnectionAdapters::Table`][]を参照してください。


### `change`メソッドの使用

`change`メソッドは、マイグレーションを記述する主要な方法です。Active Recordがマイグレーションのアクションを自動的に逆向きにする方法を知っている場合、ほとんどの場合に使用できます。以下に、`change`がサポートするいくつかのアクションを示します。

* [`add_check_constraint`][]
* [`add_column`][]
* [`add_foreign_key`][]
* [`add_index`][]
* [`add_reference`][]
* [`add_timestamps`][]
* [`change_column_comment`][]（`:from`と`:to`オプションを指定する必要があります）
* [`change_column_default`][]（`:from`と`:to`オプションを指定する必要があります）
* [`change_column_null`][]
* [`change_table_comment`][]（`:from`と`:to`オプションを指定する必要があります）
* [`create_join_table`][]
* [`create_table`][]
* `disable_extension`
* [`drop_join_table`][]
* [`drop_table`][]（ブロックを指定する必要があります）
* `enable_extension`
* [`remove_check_constraint`][]（制約式を指定する必要があります）
* [`remove_column`][]（型を指定する必要があります）
* [`remove_columns`][]（`:type`オプションを指定する必要があります）
* [`remove_foreign_key`][]（2番目のテーブルを指定する必要があります）
* [`remove_index`][]
* [`remove_reference`][]
* [`remove_timestamps`][]
* [`rename_column`][]
* [`rename_index`][]
* [`rename_table`][]

[`change_table`][]も逆向きに実行できますが、ブロックが上記の操作のような逆向き操作のみを呼び出す場合です。

`remove_column`は、3番目の引数として列の型を指定すれば逆向きに実行できます。元の列のオプションも指定してください。そうしないと、Railsはロールバック時に列を正確に再作成できません。

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

他のメソッドを使用する必要がある場合は、`reversible`を使用するか、`change`メソッドの代わりに`up`メソッドと`down`メソッドを記述するかする必要があります。
### `reversible`の使用

複雑なマイグレーションでは、Active Recordが逆操作を知らない処理が必要になる場合があります。[`reversible`][]を使用して、マイグレーションを実行するときに何を行うか、および元に戻すときに何を行うかを指定できます。例えば：

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # ディストリビューターのビューを作成する
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

`reversible`を使用すると、指示が正しい順序で実行されることも保証されます。前の例のマイグレーションが元に戻されると、`down`ブロックは`home_page_url`列が削除され、`email_address`列が名前変更された後、`distributors`テーブルが削除される直前に実行されます。


### `up`/`down`メソッドの使用

`change`メソッドの代わりに`up`メソッドと`down`メソッドを使用して、古いスタイルのマイグレーションも行うことができます。

`up`メソッドは、スキーマに加えたい変換を記述する必要があります。マイグレーションの`down`メソッドは、`up`メソッドによって行われた変換を元に戻す必要があります。つまり、`up`の後に`down`を実行してもデータベースのスキーマは変更されないはずです。

例えば、`up`メソッドでテーブルを作成した場合、`down`メソッドでテーブルを削除する必要があります。変換は、`up`メソッドで行った順序とまったく逆の順序で行うことが賢明です。`reversible`セクションの例は次のようになります：

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # ディストリビューターのビューを作成する
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

### 元に戻せないようにエラーをスローする

マイグレーションが元に戻せない操作を行う場合、`down`ブロックで`ActiveRecord::IrreversibleMigration`を発生させることができます。

マイグレーションを元に戻そうとすると、実行できないというエラーメッセージが表示されます。

### 前のマイグレーションを元に戻す

Active Recordの`revert`メソッドを使用して、マイグレーションをロールバックすることもできます。

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

`revert`メソッドは、逆操作のブロックも受け入れます。これは、前のマイグレーションの一部を元に戻すために便利です。

例えば、`ExampleMigration`がコミットされ、後でディストリビューターのビューが不要になったと判断された場合を想像してみましょう。

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.1]
  def change
    revert do
      # ExampleMigrationからコピーしたコード
      reversible do |direction|
        direction.up do
          # ディストリビューターのビューを作成する
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

      # マイグレーションの残りは問題ありません
    end
  end
end
```

同じマイグレーションは、`revert`を使用せずに書くこともできますが、これにはさらにいくつかの手順が必要です：

1. `create_table`と`reversible`の順序を逆にする。
2. `create_table`を`drop_table`に置き換える。
3. 最後に、`up`を`down`に、`down`を`up`に置き換えます。

これはすべて`revert`によって処理されます。


マイグレーションの実行
------------------

Railsは、特定のセットのマイグレーションを実行するためのコマンドを提供しています。

おそらく最初に使用するマイグレーションに関連するRailsコマンドは、`bin/rails db:migrate`でしょう。基本的な形式では、まだ実行されていないすべてのマイグレーションの`change`または`up`メソッドを実行します。そのようなマイグレーションが存在しない場合は、終了します。マイグレーションは、マイグレーションの日付に基づいて順番に実行されます。

`db:migrate`コマンドを実行すると、`db:schema:dump`コマンドも実行され、`db/schema.rb`ファイルがデータベースの構造に合わせて更新されます。

ターゲットバージョンを指定すると、Active Recordは指定したバージョンに到達するまで必要なマイグレーション（change、up、down）を実行します。バージョンは、マイグレーションのファイル名の数値の接頭辞です。例えば、バージョン20080906120000にマイグレーションするには、次のコマンドを実行します：
```bash
$ bin/rails db:migrate VERSION=20080906120000
```

バージョン20080906120000が現在のバージョンよりも大きい場合（つまり、上方向に移行している場合）、これは20080906120000を含むすべてのマイグレーションの`change`（または`up`）メソッドを実行し、それ以降のマイグレーションは実行しません。下方向に移行する場合、これは20080906120000を含まないすべてのマイグレーションの`down`メソッドを実行します。

### ロールバック

よくあるタスクは、最後のマイグレーションをロールバックすることです。たとえば、それに間違いがあり修正したい場合、前のマイグレーションに関連付けられたバージョン番号を追跡する代わりに、次のコマンドを実行できます。

```bash
$ bin/rails db:rollback
```

これにより、最新のマイグレーションがロールバックされます。`change`メソッドが元に戻されるか、`down`メソッドが実行されます。複数のマイグレーションを元に戻す必要がある場合は、`STEP`パラメータを指定できます。

```bash
$ bin/rails db:rollback STEP=3
```

最後の3つのマイグレーションが元に戻されます。

`db:migrate:redo`コマンドは、ロールバックしてから再度マイグレーションを実行するためのショートカットです。`db:rollback`コマンドと同様に、複数のバージョンを戻る必要がある場合は`STEP`パラメータを使用できます。例えば：

```bash
$ bin/rails db:migrate:redo STEP=3
```

これらのRailsコマンドは、`db:migrate`で実行できないことは何もありません。バージョンを明示的に指定する必要がないため、便利なものです。

### データベースのセットアップ

`bin/rails db:setup`コマンドは、データベースを作成し、スキーマをロードし、シードデータで初期化します。

### データベースのリセット

`bin/rails db:reset`コマンドは、データベースを削除して再設定します。これは`bin/rails db:drop db:setup`と機能的に同等です。

注意：これはすべてのマイグレーションを実行するのとは異なります。現在の`db/schema.rb`または`db/structure.sql`ファイルの内容のみ使用します。マイグレーションをロールバックできない場合、`bin/rails db:reset`は役に立たない場合があります。スキーマのダンプについて詳しくは、[Schema Dumping and You][]セクションを参照してください。

[Schema Dumping and You]: #schema-dumping-and-you

### 特定のマイグレーションの実行

特定のマイグレーションを上方向または下方向に実行する必要がある場合、`db:migrate:up`および`db:migrate:down`コマンドを使用できます。適切なバージョンを指定し、対応するマイグレーションの`change`、`up`、または`down`メソッドが呼び出されます。例：

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

このコマンドを実行すると、バージョンが「20080906120000」のマイグレーションの`change`メソッド（または`up`メソッド）が実行されます。

まず、このコマンドはマイグレーションが存在し、既に実行されているかどうかをチェックし、そうであれば何もしません。

指定されたバージョンが存在しない場合、Railsは例外をスローします。

```bash
$ bin/rails db:migrate VERSION=zomg
rails aborted!
ActiveRecord::UnknownMigrationVersionError:

No migration with version number zomg.
```

### 異なる環境でのマイグレーションの実行

デフォルトでは、`bin/rails db:migrate`は`development`環境で実行されます。

他の環境でマイグレーションを実行するには、コマンドを実行する際に`RAILS_ENV`環境変数を指定できます。たとえば、`test`環境でマイグレーションを実行するには、次のように実行できます。

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### マイグレーションの実行結果の変更

デフォルトでは、マイグレーションは実行内容と所要時間を正確に表示します。テーブルの作成とインデックスの追加を行うマイグレーションは、次のような出力を生成する場合があります。

```
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

マイグレーションでこれを制御するために、いくつかのメソッドが提供されています。

| メソッド                    | 目的
| -------------------------- | -------
| [`suppress_messages`][]    | ブロックを引数として取り、ブロックによって生成される出力を抑制します。
| [`say`][]                  | メッセージ引数を取り、そのまま出力します。2番目の真偽値引数を渡すことで、インデントするかどうかを指定できます。
| [`say_with_time`][]        | ブロックの実行にかかった時間とともにテキストを出力します。ブロックが整数を返す場合、それは影響を受けた行数と見なされます。

たとえば、次のマイグレーションを考えてみましょう。

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

以下の出力が生成されます：

```
==  CreateProducts: マイグレーション中 =================================================
-- テーブルが作成されました
   -> インデックスも作成されました！
-- 少し待っています
   -> 10.0013秒
   -> 250行
==  CreateProducts: マイグレーション完了 (10.0054秒) =======================================
```

Active Recordが何も出力しないようにしたい場合は、`bin/rails db:migrate VERBOSE=false`を実行すると、すべての出力が抑制されます。


既存のマイグレーションの変更
----------------------------

マイグレーションを書く際に間違いを comit することがあります。もし既にマイグレーションを実行している場合、単にマイグレーションを編集して再度実行することはできません。Railsは既にマイグレーションを実行したと思っているため、`bin/rails db:migrate`を実行しても何もしません。修正されたバージョンを実行するには、マイグレーションをロールバックする必要があります（たとえば、`bin/rails db:rollback`を使用して）。その後、マイグレーションを編集し、修正版を実行するために`bin/rails db:migrate`を実行します。

一般的に、既存のマイグレーションを編集することは良いアイデアではありません。それによって、自分自身や同僚に余分な作業が生じ、既存のバージョンのマイグレーションが既に本番環境のマシンで実行されている場合には大きな問題が発生します。

代わりに、必要な変更を実行する新しいマイグレーションを作成するべきです。まだソースコントロールにコミットされていない（または一般的には、開発マシン以外には伝播していない）新しく生成されたマイグレーションを編集することは比較的無害です。

新しいマイグレーションを書く際に、以前のマイグレーションを全体または一部取り消すために`revert`メソッドを使用することができます（詳細は[前のマイグレーションの取り消し][]を参照してください）。

[前のマイグレーションの取り消し]: #前のマイグレーションの取り消し

スキーマのダンプとあなた
------------------------

### スキーマファイルとは何ですか？

マイグレーションは強力ですが、データベースのスキーマの正確な情報源ではありません。**データベースが真実の情報源です。**

デフォルトでは、Railsは現在のデータベーススキーマの状態をキャプチャしようとする`db/schema.rb`を生成します。

`bin/rails db:schema:load`を使用してスキーマファイルを読み込むことで、アプリケーションのデータベースの新しいインスタンスを作成する方が、マイグレーションの履歴全体を再生するよりも速く、エラーが少なくなります。
[古いマイグレーション][]は、それらのマイグレーションが変化する外部依存関係を使用したり、マイグレーションとは別に進化するアプリケーションコードに依存したりする場合、正しく適用されない場合があります。

スキーマファイルは、Active Recordオブジェクトが持つ属性を素早く確認するためにも便利です。この情報はモデルのコードには含まれておらず、頻繁に複数のマイグレーションに分散していますが、スキーマファイルにはこれらの情報がまとめられています。

[古いマイグレーション]: #古いマイグレーション

### スキーマダンプの種類

Railsによって生成されるスキーマダンプの形式は、`config/application.rb`で定義された[`config.active_record.schema_format`][]設定によって制御されます。デフォルトでは、形式は`:ruby`であり、代わりに`:sql`に設定することもできます。

#### デフォルトの`:ruby`スキーマの使用

`:ruby`が選択されている場合、スキーマは`db/schema.rb`に保存されます。このファイルを見ると、非常に大きなマイグレーションのように見えることに気づくでしょう：

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

多くの点で、これがまさにその通りです。このファイルは、データベースを調査し、`create_table`、`add_index`などを使用してその構造を表現することで作成されます。

#### `:sql`スキーマダンパーの使用

ただし、`db/schema.rb`ではトリガーやシーケンス、ストアドプロシージャなど、データベースがサポートする可能性のあるすべてのものを表現することはできません。

マイグレーションがRubyのマイグレーションDSLではサポートされていないデータベース構造を作成するために`execute`を使用する場合、スキーマダンパーによって再構成することができない場合があります。

このような機能を使用している場合は、スキーマ形式を`:sql`に設定して、新しいデータベースインスタンスを作成するために役立つ正確なスキーマファイルを取得する必要があります。

スキーマ形式が`:sql`に設定されている場合、データベースの構造は、データベース固有のツールを使用して`db/structure.sql`にダンプされます。たとえば、PostgreSQLの場合は`pg_dump`ユーティリティが使用されます。MySQLとMariaDBの場合、このファイルにはさまざまなテーブルの`SHOW CREATE TABLE`の出力が含まれます。

`db/structure.sql`からスキーマをロードするには、`bin/rails db:schema:load`を実行します。このファイルの読み込みは、それが含むSQLステートメントを実行することによって行われます。定義によれば、これによりデータベースの構造の完全なコピーが作成されます。


### スキーマダンプとソースコントロール
スキーマファイルは新しいデータベースを作成するために一般的に使用されるため、ソースコントロールにスキーマファイルをチェックインすることを強くお勧めします。

スキーマファイルでマージの競合が発生することがあります。これらの競合を解決するには、`bin/rails db:migrate`を実行してスキーマファイルを再生成してください。

INFO: 新しく生成されたRailsアプリには、マイグレーションフォルダが既にgitツリーに含まれているため、追加する新しいマイグレーションを追加してコミットするだけで済みます。

Active Recordと参照整合性
---------------------------------------

Active Recordの方法では、知識はデータベースではなくモデルに属するとされています。そのため、トリガーや制約など、一部の知識をデータベースに戻す機能は推奨されません。

`validates :foreign_key, uniqueness: true`のようなバリデーションは、モデルがデータの整合性を強制する方法の一つです。関連付けの`dependent`オプションは、親が削除されると自動的に子オブジェクトを削除することができます。アプリケーションレベルで動作するものと同様に、これらは参照整合性を保証することはできず、一部の人々はデータベースに[外部キー制約][]を追加して補完します。

Active Recordは直接これらの機能を操作するためのすべてのツールを提供していませんが、`execute`メソッドを使用して任意のSQLを実行することができます。

[外部キー制約]: #foreign-keys

マイグレーションとシードデータ
------------------------

Railsのマイグレーション機能の主な目的は、一貫したプロセスを使用してスキーマを変更するコマンドを発行することです。マイグレーションはデータを追加または変更するためにも使用することができます。これは、プロダクションデータベースなど、破棄して再作成できない既存のデータベースで特に有用です。

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

データベースが作成された後に初期データを追加するには、Railsには組み込みの「シード」機能があり、プロセスを高速化します。これは、開発およびテスト環境でデータベースを頻繁にリロードする場合や、プロダクションの初期データを設定する場合に特に便利です。

この機能を使用するには、`db/seeds.rb`を開き、いくつかのRubyコードを追加し、`bin/rails db:seed`を実行します。

注意: ここでのコードは、どの環境でもいつでも実行できるように、冪等性を持つ必要があります。

```ruby
["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
  MovieGenre.find_or_create_by!(name: genre_name)
end
```

これは、空のアプリケーションのデータベースを設定するための一般的にはるかにクリーンな方法です。

古いマイグレーション
--------------

`db/schema.rb`または`db/structure.sql`は、データベースの現在の状態のスナップショットであり、そのデータベースを再構築するための権威あるソースです。これにより、古いマイグレーションファイルを削除または整理することができます。

`db/migrate/`ディレクトリ内のマイグレーションファイルを削除すると、`bin/rails db:migrate`がそれらのファイルがまだ存在していた時に実行された環境では、特定の環境内で実行されたマイグレーションタイムスタンプへの参照が、内部のRailsデータベーステーブルである`schema_migrations`に保持されます。このテーブルは、特定の環境でマイグレーションが実行されたかどうかを追跡するために使用されます。

`bin/rails db:migrate:status`コマンドを実行すると、各マイグレーションのステータス（上または下）が表示されますが、`db/migrate/`ディレクトリに存在しない削除されたマイグレーションファイルの横には`********** NO FILE **********`と表示されるはずです。

### エンジンからのマイグレーション

ただし、[エンジン][]には注意点があります。エンジンからのマイグレーションをインストールするためのRakeタスクは冪等性を持ちます。つまり、何度呼び出しても同じ結果になります。以前のインストールにより親アプリケーションに存在するマイグレーションはスキップされ、欠落しているマイグレーションは新しいタイムスタンプでコピーされます。古いエンジンのマイグレーションを削除してインストールタスクを再実行すると、新しいタイムスタンプ付きの新しいファイルが作成され、`db:migrate`が再度実行されます。

したがって、通常はエンジンからのマイグレーションを保持することが望ましいです。次のような特別なコメントがあります。

```ruby
# This migration comes from blorgh (originally 20210621082949)
```

 [エンジン]: engines.html
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
