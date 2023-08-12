**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 320082396ef549e27ab4cb837ec975dd
Active Record コールバック
=======================

このガイドでは、Active Record オブジェクトのライフサイクルにフックする方法を学びます。

このガイドを読み終えると、以下のことがわかるようになります：

* Active Record オブジェクトのライフサイクルの特定のイベントがいつ発生するか
* オブジェクトのライフサイクルのイベントに応答するためのコールバックメソッドの作成方法
* コールバックのための共通の動作をカプセル化するための特別なクラスの作成方法

--------------------------------------------------------------------------------

オブジェクトのライフサイクル
---------------------

Rails アプリケーションの通常の動作中には、オブジェクトが作成、更新、削除されることがあります。Active Record はこの「オブジェクトのライフサイクル」にフックを提供して、アプリケーションとそのデータを制御できるようにします。

コールバックを使用すると、オブジェクトの状態の変更前後にロジックをトリガーすることができます。

```ruby
class Baby < ApplicationRecord
  after_create -> { puts "Congratulations!" }
end
```

```irb
irb> @baby = Baby.create
Congratulations!
```

ご覧の通り、多くのライフサイクルイベントがあり、これらのいずれかにフックすることができます。フックするタイミングは、イベントの前、後、またはその周りにすることができます。

コールバックの概要
------------------

コールバックは、オブジェクトのライフサイクルの特定の時点で呼び出されるメソッドです。コールバックを使用すると、Active Record オブジェクトが作成、保存、更新、削除、バリデーション、データベースからの読み込みのいずれかの操作が行われるたびに実行されるコードを書くことができます。

### コールバックの登録

利用可能なコールバックを使用するには、それらを登録する必要があります。コールバックを通常のメソッドとして実装し、マクロスタイルのクラスメソッドを使用してコールバックとして登録します。

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

マクロスタイルのクラスメソッドはブロックも受け取ることができます。ブロック内のコードが1行に収まるほど短い場合は、このスタイルを使用することを検討してください。

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

また、コールバックにトリガされるように proc を渡すこともできます。

```ruby
class User < ApplicationRecord
  before_create ->(user) { user.name = user.login.capitalize if user.name.blank? }
end
```

最後に、独自のカスタムコールバックオブジェクトを定義することもできます。これについては後ほど詳しく説明します [下記](#callback-classes)。

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

コールバックは、特定のライフサイクルイベントのみで発火するようにも登録できます。これにより、コールバックがいつ、どのコンテキストでトリガされるかを完全に制御できます。

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on は配列も受け取ります
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

コールバックメソッドは private として宣言することが良い慣例です。public のままにしておくと、モデルの外部から呼び出すことができ、オブジェクトのカプセル化の原則に違反する可能性があります。

警告. コールバック内でオブジェクトに副作用をもたらす `update`、`save` などのメソッドの呼び出しを避けてください。たとえば、コールバック内で `update(attribute: "value")` を呼び出さないでください。これはモデルの状態を変更する可能性があり、コミット中に予期しない副作用が発生する可能性があります。代わりに、`before_create` / `before_update` またはそれ以前のコールバックで値を直接代入することができます（たとえば、`self.attribute = "value"`）。

利用可能なコールバック
-------------------

以下は、利用可能なすべての Active Record コールバックのリストです。リストは、各操作中に呼び出される順序と同じ順序で表示されます。

### オブジェクトの作成

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


### オブジェクトの更新

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


警告. `after_save` は作成と更新の両方で実行されますが、常により具体的なコールバックである `after_create` と `after_update` の後に実行されます。マクロ呼び出しが実行された順序に関係なくです。

### オブジェクトの削除

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]


注意: `before_destroy` コールバックは `dependent: :destroy` の関連付けの前に配置する必要があります（または `prepend: true` オプションを使用する必要があります）。これにより、`dependent: :destroy` によってレコードが削除される前に実行されることが保証されます。

警告. `after_commit` は `after_save`、`after_update`、`after_destroy` とは異なる保証を提供します。たとえば、`after_save` 内で例外が発生した場合、トランザクションはロールバックされ、データは永続化されません。一方、`after_commit` で行われるすべての操作は、トランザクションが既に完了し、データがデータベースに永続化されていることを保証します。詳細については、[トランザクションコールバック](#transaction-callbacks) を参照してください。
### `after_initialize` と `after_find`

Active Record オブジェクトがインスタンス化されると、[`after_initialize`][] コールバックが呼び出されます。これは、`new` を直接使用するか、データベースからレコードがロードされた場合に呼び出されます。Active Record の `initialize` メソッドを直接オーバーライドする必要がない場合に便利です。

データベースからレコードをロードする際には、[`after_find`][] コールバックが呼び出されます。`after_initialize` と `after_find` の両方が定義されている場合、`after_find` は `after_initialize` の前に呼び出されます。

注意: `after_initialize` と `after_find` のコールバックには `before_*` の対応はありません。

これらは他の Active Record コールバックと同様に登録することができます。

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "オブジェクトが初期化されました！"
  end

  after_find do |user|
    puts "オブジェクトが見つかりました！"
  end
end
```

```irb
irb> User.new
オブジェクトが初期化されました！
=> #<User id: nil>

irb> User.first
オブジェクトが見つかりました！
オブジェクトが初期化されました！
=> #<User id: 1>
```


### `after_touch`

[`after_touch`][] コールバックは、Active Record オブジェクトがタッチされるたびに呼び出されます。

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "オブジェクトがタッチされました"
  end
end
```

```irb
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
オブジェクトがタッチされました
=> true
```

`belongs_to` と一緒に使用することもできます:

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    puts 'Book がタッチされました'
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      puts 'Book/Library がタッチされました'
    end
end
```

```irb
irb> @book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @book.touch # @book.library.touch をトリガーします
Book がタッチされました
Book/Library がタッチされました
=> true
```


コールバックの実行
-----------------

以下のメソッドはコールバックをトリガーします:

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

さらに、`after_find` コールバックは以下の検索メソッドによってトリガーされます:

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

`after_initialize` コールバックは、クラスの新しいオブジェクトが初期化されるたびにトリガーされます。

注意: `find_by_*` と `find_by_*!` メソッドは、すべての属性に対して自動的に生成される動的な検索メソッドです。これについては、[動的な検索メソッドのセクション](active_record_querying.html#dynamic-finders)で詳しく説明しています。


コールバックのスキップ
------------------

バリデーションと同様に、以下のメソッドを使用してコールバックをスキップすることもできます:

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

ただし、これらのメソッドは注意して使用する必要があります。重要なビジネスルールやアプリケーションロジックはコールバックに保持されている場合があります。潜在的な影響を理解せずにこれらのメソッドをバイパスすると、無効なデータが生成される可能性があります。


実行の停止
-----------------

モデルに新しいコールバックを登録すると、実行のためにキューに入れられます。このキューには、モデルのバリデーション、登録されたコールバック、および実行されるデータベース操作が含まれます。

コールバックチェーン全体はトランザクションでラップされています。コールバックのいずれかが例外を発生させると、実行チェーンが停止され、ROLLBACK が発行されます。チェーンを意図的に停止するには、次のようにします:

```ruby
throw :abort
```

警告. `ActiveRecord::Rollback` または `ActiveRecord::RecordInvalid` 以外の例外は、コールバックチェーンが停止した後に Rails によって再度発生します。さらに、通常 `true` または `false` を返そうとする `save` や `update` などのメソッドが例外を発生させることによって、コードが壊れる可能性があります。

注意: `after_destroy`、`before_destroy`、または `around_destroy` コールバック内で `ActiveRecord::RecordNotDestroyed` が発生した場合、再発されず、`destroy` メソッドは `false` を返します。


関連するコールバック
--------------------

コールバックはモデルの関係性を通じて機能し、関係性によって定義することもできます。ユーザーが多くの記事を持つという例を考えてみましょう。ユーザーが削除されると、ユーザーの記事も削除されるべきです。`User` モデルに `Article` モデルへの関係性を通じて `after_destroy` コールバックを追加しましょう:

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Article destroyed'
  end
end
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
Article destroyed
=> #<User id: 1>
```
条件付きコールバック
---------------------

バリデーションと同様に、コールバックメソッドの呼び出しも、与えられた述語の条件を満たす場合にのみ行うことができます。これは、`:if` オプションと `:unless` オプションを使用して行うことができます。これらのオプションは、シンボル、`Proc`、または配列を受け取ることができます。

コールバックが呼び出される条件を指定したい場合は、`:if` オプションを使用します。コールバックが呼び出されない条件を指定したい場合は、`:unless` オプションを使用します。

### `:if` と `:unless` を `Symbol` と組み合わせて使用する

`:if` オプションと `:unless` オプションを、コールバックの直前に呼び出される述語メソッドの名前に対応するシンボルと関連付けることができます。

`:if` オプションを使用する場合、述語メソッドが `false` を返す場合はコールバックは実行されません。`:unless` オプションを使用する場合、述語メソッドが `true` を返す場合はコールバックは実行されません。これが最も一般的なオプションです。

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

この形式の登録では、コールバックが実行されるかどうかをチェックするために呼び出される複数の異なる述語を登録することもできます。これについては、[後述](#multiple-callback-conditions)します。

### `:if` と `:unless` を `Proc` と組み合わせて使用する

`:if` オプションと `:unless` オプションを `Proc` オブジェクトと組み合わせて使用することもできます。このオプションは、通常は1行のバリデーションメソッドを書く場合に最適です。

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

Proc はオブジェクトのコンテキストで評価されるため、次のように書くこともできます。

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```

### 複数のコールバック条件

`:if` オプションと `:unless` オプションは、複数の Proc やメソッド名のシンボルの配列も受け入れます。

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

配列の条件に Proc を簡単に含めることもできます。

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, Proc.new { untrusted_author? }]
end
```

### `:if` と `:unless` の両方を使用する

コールバックは、`if` の条件がすべて評価され、`unless` の条件がすべて `true` に評価されない場合にのみ実行されます。

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: Proc.new { forum.parental_control? },
    unless: Proc.new { author.trusted? }
end
```

トランザクションコールバック
---------------------

### 一貫性の確保

データベーストランザクションの完了時にトリガされる追加の2つのコールバックがあります: [`after_commit`][] と [`after_rollback`][]。これらのコールバックは、データベースの変更がコミットまたはロールバックされるまで実行されません。これらは、アクティブレコードモデルがデータベーストランザクションの一部ではない外部システムとやり取りする必要がある場合に特に便利です。
例えば、前の例を考えてみましょう。`PictureFile`モデルでは、対応するレコードが破棄された後にファイルを削除する必要があります。`after_destroy`コールバックが呼び出された後に例外が発生し、トランザクションがロールバックされる場合、ファイルは削除され、モデルは不整合な状態になります。たとえば、以下のコードで`picture_file_2`が有効でなく、`save!`メソッドがエラーを発生させるとします。

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

`after_commit`コールバックを使用することで、この場合を考慮することができます。

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

注意：`:on`オプションは、コールバックがいつ発生するかを指定します。`:on`オプションを指定しない場合、コールバックはすべてのアクションに対して発生します。

### コンテキストによる違い

`after_commit`コールバックは、作成、更新、または削除のみに使用することが一般的です。そのため、これらの操作のエイリアスが用意されています。

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

警告：トランザクションが完了すると、そのトランザクション内で作成、更新、または削除されたすべてのモデルに対して`after_commit`または`after_rollback`コールバックが呼び出されます。ただし、これらのコールバックのいずれかで例外が発生した場合、例外は上位に伝播し、残りの`after_commit`または`after_rollback`メソッドは実行されません。そのため、コールバックコードが例外を発生させる可能性がある場合は、コールバック内で例外をキャッチして処理する必要があります。

警告：`after_commit`または`after_rollback`コールバック内で実行されるコード自体はトランザクションで囲まれていません。

警告：同じメソッド名で`after_create_commit`と`after_update_commit`の両方を使用すると、最後に定義されたコールバックのみが効果を持ちます。これは、両方が内部的に`after_commit`にエイリアスされており、同じメソッド名で以前に定義されたコールバックを上書きするためです。

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
irb> @user = User.create # 何も表示されない

irb> @user.save # @userを更新
User was saved to database
```

### `after_save_commit`

[`after_save_commit`][]もあります。これは、作成と更新の両方に対して`after_commit`コールバックを使用するためのエイリアスです。

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
irb> @user = User.create # Userを作成
User was saved to database

irb> @user.save # @userを更新
User was saved to database
```

### トランザクション内のコールバックの順序

複数のトランザクション内の`after_`コールバック（`after_commit`、`after_rollback`など）を定義する場合、定義された順序とは逆の順序で呼び出されます。

```ruby
class User < ActiveRecord::Base
  after_commit { puts("this actually gets called second") }
  after_commit { puts("this actually gets called first") }
end
```

注意：これは、`after_destroy_commit`などのすべての`after_*_commit`バリエーションにも適用されます。
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
